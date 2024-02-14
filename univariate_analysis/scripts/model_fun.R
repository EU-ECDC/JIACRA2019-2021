############### JIACRA IV #################
#
#### Model function ####
#
# This script defines a function to be used within the univariate analysis function (analysis_fun) to fit
# a regression model based on the specified best_model parameter. The function is designed to handle 
# different model types, including linear, log, and quadratic models, providing flexibility in analyzing
# the relationship between variables in the context of AMC and AMR.
#
# Input:
#   - dat: the input data frame containing relevant variables.
#   - best_model: a string specifying the best_model type ("linear", "log", or "quadratic").
#   - column_names: a list containing column names for the input data frame. 
#                   Defaults to the column_names from the calling environment of the univariate analysis function (analysis_fun).
#
# Output:
#   - A fitted model object using quasibin and logit link function.

model_fun <- function(dat, 
                      best_model, 
                      column_names = parent.frame()$column_names) {
  # Construct the formula based on the best_model parameter
  formula <- switch(
    best_model,
    linear = paste("cbind(", column_names$y_variable, ",", column_names$total_variable, "- ", column_names$y_variable, ") ~ ", column_names$x_variable),
    log = paste("cbind(", column_names$y_variable, ",", column_names$total_variable, "- ", column_names$y_variable, ") ~ ", paste0(column_names$x_variable, ".log")),
    quadratic = paste("cbind(", column_names$y_variable, ",", column_names$total_variable, "- ", column_names$y_variable, ") ~ ", paste0(column_names$x_variable, ".2")),
    stop("Invalid best_model specified.")
  )
  formula <- as.formula(formula)
  return(quasibin(formula, data = dat, link = c("logit")))
}

#### Useful non-standard functions ####

logit <- function(x) log(x/(1-x)) # Calculate logit transformation
logit001 <- function(x) log((x+0.001)/(1.001-x)) # Logit with offset 0.001 when 0 and 1 proportions are present, used for plotting
log2b <- function(x) log2(x+0.001) # Log-2-transformation with offset 0.001 for log2 model
