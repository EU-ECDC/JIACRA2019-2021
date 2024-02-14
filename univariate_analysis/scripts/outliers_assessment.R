############### JIACRA IV #################
#
#### Outlier Assessment Function ####
#
# This script defines a function to be used within the univariate analysis function (analysis_fun) for assessing 
# outliers in a regression model. The function fits a regression model for each specified year, systematically 
# excluding one country at a time, and assesses whether the removal of each country influences the significance
# of the model fitting.
#
# Input:
#   - dat: the input data frame containing relevant variables.
#   - best_model: a string specifying the best_model type ("linear," "log," or "quadratic").
#   - years: a vector of years for which the outlier assessment will be performed.
#   - column_names: a list containing column names for the input data frame.
#                   Defaults to the column_names from the calling environment of the univariate analysis function (analysis_fun).
#
# Output:
#   - Outlier assessment results printed to the console, indicating changes in significance when excluding a country.
#
# Note: The function relies on the model_fun function for fitting regression models.

outliers_assessment <- function(dat,
                                best_model, 
                                years, 
                                column_names =  parent.frame()$column_names) {
  cat("\n","_________________________________________________________________","\n")
  cat("\n", "OUTLIER ASSESSMENT" , "\n" )
  for (year in years) {
    # Filter data for the current year
    dat_year <- dat[dat$Year == year, ]

    # Change country variable as character for reporting
    dat_year$ReportingCountry <- as.character(dat_year$ReportingCountry)
    
    # Fit the model for the current year
    m_year <- model_fun(dat_year, best_model, column_names)
    
    # Extract model coefficient estimates
    est_year <- summary(m_year@fm)$coefficients
    row.names(est_year) <- c("beta0", "beta1")
    
    no_outliers_detected <- TRUE  # Flag to check if any outliers were detected
    fail_model <- FALSE  # Flag to check when model works
    
    for (i in 1:nrow(dat_year)) {
      # Fitting the data again without one country (i)
      dat_O <- dat_year[-i, ]
      
      # Check if all values in the x_variable are zero
      if (all(dat_O[, column_names$x_variable] == 0)) {
        cat("\nOutliers assessment not feasible due to all zero values in X-variable\n")
        fail_model <- TRUE
        break  # Stop outlier assessment
      }
      
      m_O <- model_fun(dat_O, best_model)
      est_year_O <- summary(m_O@fm)$coefficients
      row.names(est_year_O) <- c("beta0", "beta1")
      
      # Calculate OR and its 95% CI
      OR.estimate <- exp(est_year[2, 1])
      OR.estimate_O <- exp(est_year_O[2, 1])
      
      pvalue <- est_year[2, 4]
      pvalue_O <- est_year_O[2, 4]
      
      # Check if the significance level changed
      sgn <- (pvalue < 0.05)
      sgn_O <- (pvalue_O < 0.05)
      sgn_infl <- (sgn_O != sgn)
      
      if (sgn_infl) {
        cat("\nYear", year, "\n")
        cat("\nCountry:", as_glue({ dat_year[i, "ReportingCountry"]}), "\n")
        cat("\nOR:", as_glue({round(OR.estimate_O, 3)}), "\n")
        cat("\nX-variable:", as_glue({round(dat_year[i, column_names$x_variable], 3)}), "\n")
        cat("\nY-variable:", as_glue({round(dat_year[i, column_names$y_variable]/dat_year[i, column_names$total_variable], 3)}), "\n")
        cat("\np-value without", as_glue({ dat_year[i, "ReportingCountry"]}), ':',
            as_glue({ format(round(pvalue_O, 3)) }), "\n")
        no_outliers_detected <- FALSE  # Outlier detected
      }
    }
    
    if (!fail_model) {
      if (no_outliers_detected) {
        cat("\nYear:", year, "\n")
        cat("\n No outliers detected", "\n")
      }
    }
    cat("\n","_________________________________________________________________","\n")
  }
}
