library(readr)
library(dplyr)
library(coefplot)
library(MLeval)

train_model <- function(full_dat, trim, name){
  require(caret)
  require(dplyr)
  require(doParallel)
  # require(doMC)

  a <- seq(log(0.001), log(100), length.out = 100)
  b <- exp(a) # Left biased lambda search

  # Lasso lambda params
  hyper_grid <- expand.grid(alpha = 1, lambda = b)

  full_dat <- full_dat %>%
    filter(status != "unknown") %>%
    select(-c(ind, case))
  
  # Proof of concept
  # 
  # full_dat <- full_dat[c(1:1000), c(1:100)]
 
  # Train/Test partition
  set.seed(8162020)
  train_index <- createDataPartition(full_dat$status, p = .9,
                                     list = FALSE,
                                     times = 1)
  dat_train <- full_dat[train_index[,1],]
  dat_test <- full_dat[-train_index[,1],]
  

  if (trim == 1){ # Most trimmed/smallest model (smallest in memory)
    ctrl <- trainControl(method = "cv", # 10 folds default
                         # Save memory
                         trim = T,
                         returnData = F,
                         classProbs = T,
                         summaryFunction = twoClassSummary)

  } else if (trim == 2) {
    ctrl <- trainControl(method = "cv",
                         returnData = T,
                         trim = T,
                         classProbs = T,
                         summaryFunction = twoClassSummary)
  
  } else if (trim == 3) { # Fattest model (biggest in memory)
    ctrl <- trainControl(method = "repeatedcv",
                         number = 10,
                         repeats = 10,
                         returnData = T,
                         classProbs = T,
                         savePredictions = T,
                         summaryFunction = twoClassSummary)
  }

  options(expressions = 500000)
  # registerDoMC(2)
  Nslots <- as.numeric(Sys.getenv("SLURM_CPUS_ON_NODE"))
  cat(as.character(Nslots), "\n")
  cl <- makeCluster(Nslots, outfile = "")

  registerDoParallel(cl)
  
  print("Training model . . . ")
  model <- train(status ~ .,
                 data = dat_train,
                 method = "glmnet",
                 metric = "ROC",
                 trControl = ctrl,
                 tuneGrid = hyper_grid,
                 preProcess = "scale")
  stopCluster(cl)
  print("Model training complete.")
  print("Extracting probabilities. . .")
  probs <- extractProb(list(model), 
                       testX = dat_test %>% select(-status),
                       testY = dat_test$status) %>%
    filter(dataType == "Test") %>%
    select(cancer, control, obs) %>%
    mutate(Group = !!name)
  print("Probabilities Extracted")
  
  return(list(model = model, probs = probs))
}

model.21 <- train_model(read_rds("./chr21.rds"), trim=3, name="Chromosome 21")
model.21.probs <- model.21$probs
model.21 <- model.21$model


model.22 <- train_model(read_rds("./chr22.rds"), 3, name="Chromosome 22")
model.22.probs <- model.22$probs
model.22 <- model.22$model

model.2122 <- train_model(read_rds("./chr2122.rds"), 3, name="Chromosomes 21/22")
model.2122.probs <- model.2122$probs
model.2122 <- model.2122$model

models.probs <- bind_rows(model.21.probs, model.22.probs, model.2122.probs)


model.21.coefs <- coef(model.21$finalModel, model.21$bestTune$lambda)
write_rds(model.21.coefs, "./output/model.21.coefs.rds")

model.22.coefs <- coef(model.22$finalModel, model.22$bestTune$lambda)
write_rds(model.22.coefs, "./output/model.22.coefs.rds")

model.2122.coefs <- coef(model.2122$finalModel, model.2122$bestTune$lambda)
write_rds(model.2122.coefs, "./output/model.2122.coefs.rds")

models.bestTune <- list(model.21 = model.21$bestTune, model.22 = model.22$bestTune, model.2122 = model.2122$bestTune)
write_rds(models.bestTune, "./output/models.bestTune.rds")

models.perf <- evalm(models.probs, 
              title = "ROC Curve Comparison", 
              # gnames=c("Chromosome 21", "Chromosome 22", "Chromosomes 21/22"), 
              showplots = F, plots = c("r"), rlinethick = 1,
              positive="cancer")
ggplot2::ggsave("models.perf.png",
                plot = models.perf$roc,
                device = "png",
                path="./output/",
                width=10.5, height=8, units = "in",
                dpi="retina")

roc_plot <- dotplot(resamples(list(`21` = model.21,
                                   `22` = model.22,
                                   `21/22` = model.2122)), metric = c("ROC"),
                   scales = list(x = list(relation = "free",
                                          rot = 90
                   )),
                   main = "ROC Comparison")
write_rds(roc_plot, "./output/roc_plot.rds")



models.coefplot <- multiplot(list(`Chromosome 21` = model.21$finalModel, 
                           `Chromosome 22` = model.22$finalModel,
                           `Chromosome 21/22` = model.2122$finalModel),
                      pointSize = 1.75) +
  theme_minimal()
# write_rds(models.coefplot, "./output/models.coefplot.rds")

# save(models.perf, models.coefplot, model.21.coefs, model.22.coefs, model.2122.coefs, models.bestTune, file = "./trained_model_info.rda")


# 
# train_model(read_rds("./chr21.rds"), 1) %>%
# write_rds("./model.chr21.skinny.most.rds")
# train_model(read_rds("./chr22.rds"), 1) %>%
# write_rds("./model.chr22.skinny.most.rds")
# train_model(read_rds("./chr2122.rds"), 1) %>%
# write_rds("./model.chr2122.skinny.most.rds")

# train_model(read_rds("./chr21.rds"), 2) %>%
# write_rds("./model.chr21.skinny.rds")
# train_model(read_rds("./chr22.rds"), 2) %>%
# write_rds("./model.chr22.skinny.rds")
# train_model(read_rds("./chr2122.rds"), 2) %>%
# write_rds("./model.chr2122.skinny.rds")

