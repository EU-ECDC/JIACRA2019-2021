############### JIACRA IV #################
#
#### Univariate Plot Function ####
#
# This function creates a scatter plot with data points and model trend lines for each unique year in the dataset. The trend lines
# are based on the specified regression model type. The function also adds a legend indicating the years and saves
# the plot as a PDF file for further analysis. It is designed to be used within the univariate analysis function (analysis_fun).
#
# Input:
#   - dat: The input data frame containing the dataset.
#   - best_model: A string specifying the best model type ("linear," "log," or "quadratic").
#   - class: A string specifying the class label. Defaults to the class from the calling environment.
#   - pathogen: A string specifying the pathogen label. Defaults to the pathogen from the calling environment.
#   - class_label: A string specifying the class label for plot axes.
#   - pathogen_label: A string specifying the pathogen label for plot axes.
#   - years: A vector specifying the years to include in the plot.
#   - ymax: A numeric value for setting the y-axis limit in the plot.
#   - dataset_type: A string specifying the type of dataset ("AMCh_AMRh", "AMCa_AMRh", "AMRa_AMRh", or "AMCa_AMRa"). Defaults to dataset_type from the calling environment.
#   - column_names: (optional) a list containing column names for the input data frame. Defaults to column_names from the calling environment.
#   - animal: (optional) A string specifying the animal type for further filtering. Defaults to animal from the calling environment.
#
# Output:
#   - A scatter plot containing all data points for the specified years and regression model 
#     if a significant fit is achieved (printed to the console and saved in folder “Plots”).
#
# Note: The function relies on the model_fun function for fitting regression models.

univariate_plot <- function(dat, 
                            best_model = "best_model",
                            class = parent.frame()$class,
                            pathogen = parent.frame()$pathogen,
                            class_label = class_label,
                            pathogen_label = pathogen_label, 
                            years = years, 
                            ymax = ymax,
                            dataset_type =  parent.frame()$dataset_type,
                            column_names = parent.frame()$column_names,
                            animal = parent.frame()$animal) {
  
  # Set max bubble size
  bf <- max(sqrt(dat[[column_names$total_variable]])) / 5
  
  # Calculate the size of the points with a threshold
  cex_size <- ifelse(sqrt(dat[[column_names$total_variable]]) / bf < 0.5, 0.5, sqrt(dat[[column_names$total_variable]]) / bf)
  
  par(mar = c(5, 6, 1, 2), las = 1)
  dat$Year <- as.factor(dat$Year)
  
  # Determine the axis labels to use based on dataset_type
  if (class == 'CS') {
    xlabel <- bquote("Consumption of total antimicrobials (DDDs per 1000 inhabitants per days)")
    ylabel <- bquote("Probability of complete susceptibility in "~italic("E. coli")~" from humans")
  } else if (!is.null(animal) && animal == "ESBL") {
    xlabel <- bquote("Consumption of cephalosporins in food-producing animals (mg per kg estimated biomass of animals)")
    ylabel <- bquote("Prevalence of ESBL and/or AmpC in food-producing animals")
  } else if (!is.null(animal) && pathogen == 'SLMSPP' && animal == "SIMR") {
    xlabel <- bquote("Probability of resistance in "~italic('Salmonella') ~" SIMR from food-producing animals")
    ylabel <- bquote("Probability of resistance in "~italic(.(pathogen_label)) ~" from humans")
  } else if (dataset_type == "AMCh_AMRh") {
    # Variables for AMCh_AMRh dataset
    xlabel <- bquote("Consumption of" ~ .(class_label) ~ "(DDDs per 1000 inhabitants per days)")
    ylabel <- bquote("Probability of resistance in "~italic(.(pathogen_label)) ~ " from humans")
  } else if (dataset_type == "AMCa_AMRh") {
    # Variables for AMCa_AMRh dataset
    xlabel <- bquote("Consumption of"~.(class_label)~"(mg per kg estimated biomass of animals)")
    ylabel <- bquote("Probability of resistance in "~italic(.(pathogen_label)) ~" from humans")
  } else if (dataset_type == "AMRa_AMRh") {
    # Variables for AMRa_AMRh dataset
    xlabel <- bquote("Probability of resistance in "~italic(.(pathogen_label)) ~"from"~.(animal))
    ylabel <- bquote("Probability of resistance in "~italic(.(pathogen_label)) ~" from humans")
  } else if (dataset_type == "AMCa_AMRa" & !is.null(animal) & animal == 'animals') {
    xlabel <- bquote("Consumption of"~.(class_label)~"(mg per kg estimated biomass of animals)")
    ylabel <- bquote("Probability of resistance in "~italic(.(pathogen_label)) ~" from food-producing animals")
  } else if (dataset_type == "AMCa_AMRa") {
    # Variables for AMCa_AMRa dataset
    xlabel <- bquote("Consumption of"~.(class_label)~"(mg per kg estimated biomass of animals)")
    ylabel <- bquote("Probability of resistance in "~italic(.(pathogen_label)) ~" from"~.(animal))
  } else {
    stop("Invalid dataset_type specified. Error setting plot labels")
  }
  
  # Define color palettes for different numbers of years
  color_palettes <- list(
    one_year = c("#7CBDC4"),             # Color for 1 year (2020)
    two_years = c("#65B32E", "#82428D"), # Colors for 2 years (2019, 2021)
    three_years = c("#65B32E", "#7CBDC4", "#82428D"), # Colors for 3 years (2019, 2020, 2021)
    four_or_more_years = brewer.pal(length(unique(dat$Year)), "Set1") # Predetermined palette for 4 or more years
  )
  # In case there is only one year and that it is 2021, then choose color for 2021
  if (length(unique(years)) == 1 && "2021" %in% years) {
    color_palettes$one_year <- "#82428D"
  }
  
  # Sort the unique years to ensure consistent order
  sorted_years <- sort(unique(dat$Year))
  
  # Determine the color palette based on the number of years
  if (length(unique(years)) == 1) {
    palette <- color_palettes$one_year
  } else if (length(unique(years)) == 2) {
    # Ensure that the order of factor levels for the Year variable matches the sorted_years
    dat$Year <- factor(dat$Year, levels = sorted_years)
    palette <- color_palettes$two_years
  } else if (length(unique(years)) == 3) {
    palette <- color_palettes$three_years
  } else {
    palette <- color_palettes$four_or_more_years
  }
  
  # Create a color vector for each data point
  dat$YearColor <- palette[as.numeric(factor(dat$Year, levels = sorted_years))]
  
  # Sort the years vector to match the order of the palette
  sorted_years_vector <- factor(years, levels = sorted_years)
  
  plot <- plot(dat[[column_names$x_variable]], (dat[[column_names$y_variable]] / dat[[column_names$total_variable]]),
               ylim = c(0, ymax),
               cex = cex_size,
               xlab = xlabel,
               ylab = ylabel,
               cex.lab = 1.2,
               col = dat$YearColor)
  
  for (year in sorted_years_vector) { 
    # Filter data for the current year
    dat_year <- dat[dat$Year == year, ]
    
    # Fit the model for the current year
    m_year <- model_fun(dat_year, best_model)
    
    # Extract model coefficient estimates
    est_year <- summary(m_year@fm)$coefficients
    est_year_pval <- est_year[2, 4]
    
    # Create a vector to store line types based on p-values (dashed for p-value < 0.10 and solid for < 0.05)
    pval_lty <- ifelse(est_year_pval < 0.05, "solid", 
                       ifelse(est_year_pval < 0.10, "dashed", "blank"))
    
    # Determine the line color based on the number of years
    line_color <- palette[match(year, sorted_years_vector)] 
    
    # Add trend lines for each year
    ord <- order(dat[[column_names$x_variable]])
    xgrid <- seq(min(dat[[column_names$x_variable]]), max(dat[[column_names$x_variable]]), by = 0.001)
    
    if (est_year_pval < 0.10) { 
      if (best_model == "linear") {
        lines(xgrid, expit(est_year[1, 1] + est_year[2, 1] * xgrid), lwd = 1.4, lty = pval_lty, col = line_color)
      } else if (best_model == "log") {
        lines(xgrid, expit(est_year[1, 1] + est_year[2, 1] * log2b(xgrid)), lwd = 1.4, lty = pval_lty, col = line_color)
      } else if (best_model == "quadratic") {
        lines(xgrid, expit(est_year[1, 1] + est_year[2, 1] * (xgrid)^2), lwd = 1.4, lty = pval_lty, col = line_color)
      }
    }
  }
  
  # Add a legend for analyses using time period and for those using year.
  if (!is.null(animal) && animal == 'animals' && pathogen == 'ESCCOL') {
    legend("top", legend = c('2018-2019', '2019-2020', '2020-2021'), 
                 fill = palette, horiz = TRUE, inset = 0.03, box.lty = 0, cex = 1.2)
  } else {
  legend("top", legend = unique(sorted_years_vector), 
         fill = palette, horiz = TRUE, inset = 0.03, box.lty = 0, cex = 1.2)
  }
  
  # Determine the file path and name to use based on dataset_type
  if (dataset_type == "AMCh_AMRh") {
    # Variables for AMCh_AMRh dataset
    file_name <- glue("Plots/2_{class}-{pathogen}.pdf")
  } else if (dataset_type == "AMCa_AMRh") {
    # Variables for AMCa_AMRh dataset
    file_name <- glue("Plots/5_{class}-{pathogen}.pdf")
  } else if (dataset_type == "AMRa_AMRh") {
    # Variables for AMRa_AMRh dataset
    file_name <- glue("Plots/4_{class}-{pathogen}-{animal}.pdf")
  } else if (dataset_type == "AMCa_AMRa") {
    # Variables for AMCa_AMRa dataset
    file_name <- glue("Plots/3_{class}-{pathogen}-{animal}.pdf")
  } else {
    stop("Invalid dataset_type specified.")
  }
  
  # Save the plot to a PDF file
  
  model_plot <- recordPlot() ## Record plot
  plot.new()
  print(model_plot) ## Print plot
  
  cairo_pdf(file_name, width = 10, height = 7,pointsize=12, family="Tahoma") ## Set up cairo
  print(model_plot)
  dev.off()
  
  cat("\n")
  return(plot)
}

