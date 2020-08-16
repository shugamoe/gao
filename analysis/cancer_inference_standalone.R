library(readr)
library(dplyr)

train_model <- function(full_dat, trim){
  require(caret)
  require(dplyr)
  # require(doParallel)
  # require(doMC)

  a <- seq(log(0.001), log(100), length.out = 25)
  b <- exp(a) # Left biased lambda search

  # Lasso lambda params
  hyper_grid <- expand.grid(alpha = 1, lambda = b)

  full_dat <- full_dat %>%
    filter(status != "unknown") %>%
    select(-c(ind, case))

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
    ctrl <- trainControl(method = "cv",
                         returnData = T,
                         classProbs = T,
                         summaryFunction = twoClassSummary)
  }

  options(expressions = 500000)
  # registerDoMC(2)
  # Nslots <- as.numeric(Sys.getenv("SLURM_CPUS_ON_NODE"))
  # cat(as.character(Nslots), "\n")
  # cl <- makeCluster(Nslots, outfile = "")
  #
  # registerDoParallel(cl)
  #

  set.seed(8162020)
  model <- train(status ~ .,
                 data = full_dat,
                 method = "glmnet",
                 metric = "ROC",
                 trControl = ctrl,
                 tuneGrid = hyper_grid
  )
}

train_model(read_rds("./chr21.rds"), 3) %>%
  write_rds("./model.chr21.rds")
train_model(read_rds("./chr22.rds"), 3) %>%
  write_rds("./model.chr22.rds")
train_model(read_rds("./chr2122.rds"), 3) %>%
  write_rds("./model.chr2122.rds")

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

