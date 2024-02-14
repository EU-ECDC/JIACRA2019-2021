############### JIACRA IV #################
#
#### Univariate Analysis function ####
#
# This script conducts a univariate regression model analysis of Antimicrobial Consumption (AMC) 
# and Antimicrobial Resistance (AMR) in humans and animals using the provided dataset. 
#
# Input:
#   - dat: the input data frame containing relevant variables.
#   - dataset_type: a string specifying the type of dataset ("AMCh_AMRh", "AMCa_AMRh", "AMRa_AMRh", or "AMCa_AMRa").
#   - model: a string specifying the model type ("linear," "log," "quadratic," or "best_model").
#   - class: a string specifying the class of antimicrobial to consider.
#   - pathogen: a string specifying the pathogen to consider.
#   - animal: (optional) a string specifying the animal type for animal specific analyses.
#   - ymax: a numeric value for setting the y-axis limit in the plot.
#   - years: a vector of years to be included in the analysis.
#
# Output:
#   - A summary table of the model (countries, odds ratio, significance) printed to the console, 
#   - Data used in a .csv file saved in folder “data_used_analysis”.
#   - Plot containing all data points for the specified years and regression line if a significant
#     fit is achieved. It plots a solid regression line for p-value < 0.05 and dashed regression line if 
#     p-value between 0.10 and 0.05 (printed to the console and saved in folder “Plots”).
#   - Outliers assessment by year printed to the console.
#
# Note: Ensure that the necessary functions (model_fun, save_used_data, univariate_plot, outliers_assessment) are available.

analysis_fun <- function(dat, 
                         dataset_type,
                         model = "best_model", 
                         class = "class", 
                         pathogen = "pathogen", 
                         animal = NULL,
                         ymax = 1, 
                         years = c(2019, 2020, 2021)) {
  
  #### Testing ####
  # These lines are for testing purposes.
  # Uncomment and modify the code below to perform specific tests
  
  #dat = AMCa_AMRa
  #dataset_type = 'AMCa_AMRa'
  #model = "best_model"
  #class = "CEPH"
  #pathogen = "ESCCOL"
  #animal = "pigs"
  #ymax = 1
  #years = c(2019,2020,2021)
  
  # Check and set the selected model type
  model <- switch(model,
                  "linear" = "linear",
                  "log" = "log",
                  "quadratic" = "quadratic",
                  "best_model" = "best_model",
                  "best_model")
  
  # Determine the variables to use based on dataset_type
  if (dataset_type == "AMCh_AMRh") {
    # Variables for AMCh_AMRh dataset
    x_variable <- dat$DID_TOTAL
    y_variable <- dat$NS
    total_variable <- dat$Tested
  } else if (dataset_type == "AMCa_AMRh") {
    # Variables for AMCa_AMRh dataset
    x_variable <- dat$PCU_ANIMALS
    y_variable <- dat$NS
    total_variable <- dat$Tested
  } else if (dataset_type == "AMRa_AMRh") {
    # Variables for AMRa_AMRh dataset
    x_variable <- dat$PR_a
    y_variable <- dat$NS
    total_variable <- dat$Tested
  } else if (dataset_type == "AMCa_AMRa") {
    # Variables for AMCa_AMRa dataset
    x_variable <- dat$PCU_ANIMALS
    y_variable <- dat$NS_a
    total_variable <- dat$Tested_a
  } else {
    stop("Invalid dat_type specified.")
  }
  
  # Define the mapping of dataset_type to column names
  column_mapping <- list(
    "AMCh_AMRh" = list(
      x_variable = "DID_TOTAL",
      y_variable = "NS",
      total_variable = "Tested"
    ),
    "AMCa_AMRh" = list(
      x_variable = "PCU_ANIMALS",
      y_variable = "NS",
      total_variable = "Tested"
    ),
    "AMRa_AMRh" = list(
      x_variable = "PR_a",
      y_variable = "NS",
      total_variable = "Tested"
    ),
    "AMCa_AMRa" = list(
      x_variable = "PCU_ANIMALS",
      y_variable = "NS_a",
      total_variable = "Tested_a"
    )
  )
  
  # Check if the dataset_type is valid
  if (!(dataset_type %in% names(column_mapping))) {
    stop("Invalid dataset_type specified.")
  }
  
  # Extract column names based on dataset_type
  column_names <- column_mapping[[dataset_type]]
  
  # Filter the data based on Class, Pathogen, and Tested conditions
  dat <- dat %>%
    filter(Class == class, Pathogen == pathogen, !!column_names$total_variable >= 10, Year %in% years) %>%
    drop_na(!!column_names$x_variable, !!column_names$y_variable, !!column_names$total_variable)
  
  # When parameter animal is inputted filter also by animal
  if (!is.null(animal)) {
    dat <- dat %>% 
      filter(Animal == animal) %>% 
      drop_na(Animal)
  }
  
  # Apply log and quadratic transformation
  dat <- dat %>%
    mutate(!!paste0(column_names$x_variable, ".log") := log2b(.data[[column_names$x_variable]])) %>% 
    mutate(!!paste0(column_names$x_variable, ".2") := .data[[column_names$x_variable]]^2)
  
  
  # Extract labels for pathogen and class
  pathogen_label <- dat$pathogen_name[1]
  class_label <- dat$class_name[1]
  
  # Create a variable containing the combination of antimicrobial and pathogen
  dat$name = paste(dat$Class, dat$Pathogen, sep="-")
  
  # Save the data used in the analysis in a .csv
  save_used_data(dat, dataset_type, class, pathogen, column_names, animal)
  
  # Print pathogen name and animal
  if (!is.null(animal)) {
    cat("  \n###",  pathogen_label, "in", animal, "\n")
  } else {
    cat("  \n###",  pathogen_label, "\n")
  }
  
  # Construct the formula for the models as character vectors
  formula1 <- paste("cbind(", column_names$y_variable, ",", column_names$total_variable, "- ", column_names$y_variable, ") ~ ", column_names$x_variable)
  formula2 <- paste("cbind(", column_names$y_variable, ",", column_names$total_variable, "- ", column_names$y_variable, ") ~ ", paste0(column_names$x_variable, ".log"))
  formula3 <- paste("cbind(", column_names$y_variable, ",", column_names$total_variable, "- ", column_names$y_variable, ") ~ ", paste0(column_names$x_variable, ".2"))
  
  # Convert character vectors to formulas
  formula1 <- as.formula(formula1)
  formula2 <- as.formula(formula2)
  formula3 <- as.formula(formula3)
  
  # Fit the models
  m1 <- glm(formula1, family = "binomial", data = dat)
  m2 <- glm(formula2, family = "binomial", data = dat)
  m3 <- glm(formula3, family = "binomial", data = dat)
  
  # Ranking the models according to AIC
  if(model=="linear"){
    best_model <- "linear"
  } else if(model=="log"){
    best_model <- "log"
  } else if(model=="quadratic"){
    best_model <- "quadratic"
  } else {
    best_model <- c("linear","log","quadratic")[which.min(AIC(m1,m2,m3)[,2])]
  }
  
  results_list <- list()  # Create an empty list to store results
  
  # Loop through the specified years
  for (year in years) {
    # Filter data for the current year
    sel <- (dat$Year == year)
    dat_year <- dat[sel, ]
    dat_year <- dat_year %>% as.data.frame(row.names = 1:nrow(.))
    
    # Fit the model for the current year
    m_year <- model_fun(dat_year, best_model, column_names)
    
    # Extract model coefficient estimates and construct a data frame for the current year
    est_year = summary(m_year@fm)$coefficients
    row.names(est_year) = c("beta0", "beta1")
    orest_year = data.frame(
      OR.estimate = exp(est_year[2, 1]),
      CI.left = exp(est_year[2, 1] - 1.96 * est_year[2, 2]),
      CI.right = exp(est_year[2, 1] + 1.96 * est_year[2, 2]),
      pvalue = est_year[2, 4]
    )
    row.names(orest_year) = c("")
    orest_year$year = year
    
    # Ensure correct order of country names when using synthetic data considering their numeric part 
    # Extract numeric part
    MS_numeric_part <- as.numeric(gsub("\\D", "", dat_year$ReportingCountry))
    
    # Order the vector based on the numeric part
    ordered_MS <- dat_year$ReportingCountry[order(MS_numeric_part)]
    
    # Construct a string summarizing the countries and append it to the data frame
    countries = paste(paste(ordered_MS, collapse = ", "),
                      paste("(n=", length(unique(dat_year$ReportingCountry)), ")", sep = ""))
    orest_year = cbind(orest_year, countries)
    
    # Append results to the list
    results_list[[as.character(year)]] <- orest_year
  }
  
  # Combine results from all years into one data frame
  orest <- do.call(rbind, results_list)
  rownames(orest) <- NULL
  
  # Format the results table output

  if (best_model == 'quadratic'){
    orest$OR.estimate <- round(orest$OR.estimate, digits = 4)
    orest$CI95 <- paste(
      sprintf("%.4f", round(orest$CI.left, digits = 4)), 
      sprintf("%.4f", round(orest$CI.right, digits = 4)), 
      sep = "-"
    )
  } else {
    orest$OR.estimate <- round(orest$OR.estimate, digits = 2)
    orest$CI95 <- paste(
      sprintf("%.2f", round(orest$CI.left, digits = 2)), 
      sprintf("%.2f", round(orest$CI.right, digits = 2)), 
      sep = "-"
    )
  }
  orest$pvalue <- format.pval(round(orest$pvalue, digits = 3), eps = 0.001, digits = 3, nsmall = 3)
  orest$CI.left <- NULL
  orest$CI.right <- NULL
  orest$model <- best_model
  orest <- orest[, c(3, 4, 6, 1, 2, 5)]
  
  # Create a table using knitr::kable and print it to the console
  table <- knitr::kable(orest, col.names = c("Year", "Countries", "Model", "Odds ratio", "p-value", "95% CI"))
  print(table)
  
  #### Plotting ####
  univariate_plot(dat, best_model, class, pathogen, class_label, pathogen_label, years, ymax, dataset_type, column_names, animal)
  
  #### Outlier Assesment ####
  outliers_assessment(dat, best_model, years)
}




