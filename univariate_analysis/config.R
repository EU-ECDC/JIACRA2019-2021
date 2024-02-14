############### JIACRA IV #################
#
## Config file
#
# Install packages ----------------------------------------------------------------
# Install packages if necessary
# install.packages("tidyverse")
# install.packages("readxl")
# install.packages("openxlsx") # for reading xlsx files
# install.packages("aod") # Necessary for Williams function quasibin()
# install.packages("glue") # Necessary for glue() output functions
# install.packages("janitor")
# install.packages("locfit") # Package for expit(), to create smoother graph lines
# install.packages("RColorBrewer") # Package for plotting colour palettes
# install.packages("latex2exp")
# Load packages ---------------------------------------------------------
library(tidyverse)
library(readxl)
library(openxlsx) # for reading xlsx files
library(aod) # Necessary for Williams function quasibin()
library(glue) # Necessary for glue() output functions
library(janitor)
library(locfit) # Package for expit(), to create smoother graph lines
library(RColorBrewer) # Package for plotting colour palettes
library(latex2exp)
# Scripts ------------------------------------------------------------------
source("scripts/model_fun.R") # Model function
source("scripts/outliers_assessment.R") # Outlier assessment function
source("scripts/univariate_plot.R") # Univariate plot function
source("scripts/save_used_data.R") # Save used data function
# end ---------------------------------------------------------------------
