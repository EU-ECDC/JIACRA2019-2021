############### JIACRA IV #################
#
#### Save Used Data for Analysis Function ####
#
# This function selects the relevant columns from the dataset, pivots the data to have columns for each year,
# renames the columns appropriately, and then saves the resulting data frame as a CSV file. The file name is based
# on the specified class, pathogen, and dataset type. The goal of this function is to be able to revisit which exact
# data has been generated for each specific analysis. The function is designed to work within the univariate analysis
# function (analysis_fun).
#
# Input:
#   - dat: The input data frame containing the dataset.
#   - dataset_type: A string specifying the type of dataset ("AMCh_AMRh", "AMCa_AMRh", "AMRa_AMRh", or "AMCa_AMRa").
#   - class: A string specifying the class of antimicrobial to consider.
#   - pathogen: A string specifying the pathogen to consider.
#   - column_names: a list containing column names for the input data frame. 
#                   Defaults to the column_names from the calling environment of the univariate function.
#   - animal: (optional) A string specifying the animal type for further filtering.
#
# Output:
#   - A CSV file containing the data used for analysis saved in folder “data_used_analysis”.

save_used_data <- function(dat, 
                           dataset_type = dataset_type,
                           class, 
                           pathogen,
                           column_names = parent.frame()$column_names, 
                           animal = animal) {
  
  # Select the relevant columns based on column_names and rename them
  dat2 <- dat %>%
    select(Year, ReportingCountry, column_names$x_variable, column_names$y_variable, column_names$total_variable)
  
  if (!is.null(animal)) {
    dat2 <- dat %>% 
      select(Year, ReportingCountry, Animal, column_names$x_variable, column_names$y_variable, column_names$total_variable)
  }
  # Pivot the data wide to have separate columns for each variable (x_variable, y_variable, total_variable) for each year
  dat2 <- tidyr::pivot_wider(dat2, 
                             names_from = Year, 
                             values_from = c(starts_with(column_names$x_variable), starts_with(column_names$y_variable), starts_with(column_names$total_variable)))
  
  # Determine the file path and name to use based on dataset_type
  if (dataset_type == "AMCh_AMRh") {
    # Variables for AMCh_AMRh dataset
    file_name <- paste("data_used_analysis/", "2_", class, "-", pathogen, ".csv", sep = "")
  } else if (dataset_type == "AMCa_AMRh") {
    # Variables for AMCa_AMRh dataset
    file_name <- paste("data_used_analysis/", "5_", class, "-", pathogen, ".csv", sep = "")
  } else if (dataset_type == "AMRa_AMRh") {
    # Variables for AMRa_AMRh dataset
    file_name <- paste("data_used_analysis/", "4_", class, "-", pathogen, "-", animal, ".csv", sep = "")
  } else if (dataset_type == "AMCa_AMRa") {
    # Variables for AMCa_AMRa dataset
    file_name <- paste("data_used_analysis/", "3_", class, "-", pathogen, "-", animal, ".csv", sep = "")
  } else {
    stop("Invalid dataset_type specified.")
  }
  
  # Define the desired column order
  column_order <- c("ReportingCountry", 
                    paste0(column_names$x_variable, "_", unique(dat$Year)),
                    paste0(column_names$y_variable, "_", unique(dat$Year)),
                    paste0(column_names$total_variable, "_", unique(dat$Year)))
  
  # Reorder the columns based on the desired order
  dat2 <- dat2 %>%
    select(column_order)
  
  # Rename the columns
  colnames(dat2) <- c("ReportingCountry", 
                      paste0(column_names$x_variable, "_", unique(dat$Year)),
                      paste0(column_names$y_variable, "_", unique(dat$Year)),
                      paste0(column_names$total_variable, "_", unique(dat$Year)))
  
  # Write the data to a CSV file
  write.csv(dat2, file_name, row.names = FALSE)
}
