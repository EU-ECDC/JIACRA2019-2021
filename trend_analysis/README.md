# Time Trend Analysis Scripts

## Overview

The time trend analysis is based on country specific longitudinal models for consumption and resistance (or complete susceptibility). For each country, this results in a pair of slopes, one slope summarizing the time (i.e. yearly) trend for consumption, and one for resistance (or complete susceptibility). The significance and the sign of each estimated slope allows a categorization of each country in nine categories expressing e.g. a (significant) decreasing time trend in consumption and resistance (or complete susceptibility), or, no significant time trend in consumption and a (significant) decreasing time trend in resistance (or complete susceptibility), etc.

The time trend analysis requires the use of SAS for fitting longitudinal mixed models and the categorization and visualization is done in R.The generated plots are saved as .jpeg or .pdf.

## Methodology

### Longitudinal Mixed Model for Consumption

The longitudinal mixed model for consumption is defined as:

```math
\log(\text{consumption}_{ij} + 0.001) \sim \mathcal{N}(\alpha_{i}^c + \beta_{i}^c t_{ij}, \sigma^2)
```

for country $i=1 \ldots n$, and time points $t_{ij}, j=1 ...n_i$, with $n$ as the number of countries and $n_i$ as the number of time points for country $i$. The country-specific intercepts $\alpha_{i}^c$ and country-specific slopes $\beta_{i}^c$ vary across countries according to a bivariate normal distribution. Note that the slope parameter $\beta_{i}^c$ refers to a relative change over time on the original consumption scale.

### Generalized Linear Mixed Model for Probability of Resistance

For the probability of resistance (or complete susceptibility), the longitudinal model is a generalized linear mixed model defined as:

```math
\text{{number resistant}}_{ij} \sim \text{{Binomial}}(\text{{number of isolates}}_{ij}, \pi_{ij}) 
```

$$ \log\left(\frac{\pi_{ij}}{1 - \pi_{ij}}\right) = \alpha_{i}^r + \beta_{i}^r t_{ij} $$

for country $i=1 \ldots n$, and time points $t_{ij}, j=1 \ldots n_i$, with $n$ as the number of countries and $n_i$ as the number of time points for country $i$. The country-specific intercepts $\alpha_{i}^r$ and country-specific slopes $\beta_{i}^r$ vary across countries according to a bivariate normal distribution. Note that the slope parameter $\beta_{i}^r$ refers to a relative change over time on the odds scale $\frac{\pi_{ij}}{1 - \pi_{ij}}$.

All slope parameters were tested for statistical significance (difference from 0, representing no time trend). Each country was classified into exactly one of nine categories based on its standardized estimates for the pair of slopes $(\beta_{i}^c, \beta_{i}^r)$: not statistically different from 0, and if statistically different, the estimate being positive (increasing trend) or negative (decreasing trend) (Table 1).

**Table 1: Categorization of outcomes from the time trend analyses using country-specific longitudinal modeling for consumption and resistance or complete susceptibility.**

|Consumption →  Resistance ↓             | $\hat{\beta}_{i}^r < 0$                                            | $\hat{\beta}_{i}^r = 0$ (not rejected)                 | $\hat{\beta}_{i}^r > 0$                                            |
|------------------|------------------|------------------|------------------|
| $\hat{\beta}_{i}^c < 0$                | Decreasing trend in consumption and decreasing trend in resistance | Decreasing trend in consumption and no trend in resistance | Decreasing trend in consumption and increasing trend in resistance |
| $\hat{\beta}_{}i^c = 0$ (not rejected) | No trend in consumption and decreasing trend in resistance         | No trend in consumption and no trend in resistance         | No trend in consumption and increasing trend in resistance         |
| $\hat{\beta}_{i}^c > 0$                | Increasing trend in consumption and decreasing trend in resistance | Increasing trend in consumption and no trend in resistance | Increasing trend in consumption and increasing trend in resistance |

The above categorization is visualized in a scatter plot of the pairs of slopes $(\beta_{i}^c, \beta_{i}^r)$ using R.

## Prerequisites

Before running the script, make sure you have the following:

-   SAS installed on your system.
-   R and Rstudio installed on your system.
-   The required R packages installed. You can install them using the `install.packages()` function.

## Data

The time trend analyses performed for JIACRA IV are based on antimicrobial consumption and resistance data from human and food-producing animals for the time period 2014-2021.

The number of countries 𝑛 can vary across different substances and animal species, as well as the number of time points $n_i$ can differ from country to country. Only countries with at least five pairwise time points ($n_i$ ≥ 5) are included in the analyses. For countries with incomplete longitudinal patterns (i.e. data for a specific year is missing), it is assumed that the missing observations are "missing completely at random" (missingness is unrelated to any study variable). For more details on linear and generalized linear mixed models, and missing data, check the JIACRA IV report methodology section.

The dataset provided to reproduce the time trend analysis contains country-anonymised synthetic data for *Escherichia coli* and third- and fourth-generation cephalosporins in animals. It is intended for sharing purposes and serves as a starting point for performing your own analyses. The structure of the dataset can be adapted to meet the specific needs of your analysis, keeping in mind that any changes to the dataset structure may require corresponding adjustments in the analysis code.

### Data Structure

The dataset structure should adhere to the following format, with one row per country and one column per item:

-   **ISO:** Character value 2-letter ISO country code

-   **ID:** Numeric identifier value associated to a unique ISO country code (e.g., 1, 2, 3...)

-   **year:** Numeric value indicating the year of observation (e.g., 2014, 2015...)

-   **year0:** Numeric value indicating the year relative to the baseline (e.g., 0, 1, 2...)

-   **Consumption_CEPH:** Numeric value representing consumption of cephalosporins

-   **Log_Con_CEPH:** Log-transformed consumption of cephalosporins

-   **trialCEPH:** Numeric value representing the total number of isolates tested for antimicrobial resistance for cephalosporins

-   **eventCEPH:** Numeric value representing the number of non-susceptible isolates for cephalosporins

> **Note:** Column names like `Consumption_Cephalosporins`, `Log_Con_CEPH`, `trialCEPH`, and `eventCEPH` are provided as examples. For different antimicrobial classes, adapt these column names accordingly. Ensure consistency with your specific dataset and analysis code.

## Usage

To perform the analyses outlined in this repository, follow the steps below:

1.  **Ensure Data Structure:**
    -   Make sure your dataset adheres to the required data structure described in the "Data Structure" section of this documentation. Adjust column names accordingly for different antimicrobial classes.
2.  **Run SAS Code:**
    -   Ensure you have SAS installed on your system.
    -   Open and run the provided SAS code (`GLMM animal CEPH trends.sas`) on your dataset following the instructions within the code.
    -   Verify that the SAS code execution produces the necessary output files, such as `logcons_CTX_ints.csv`, `logcons_CTX_slopes.csv`, `logitres_CTX_ints.csv`, and `logitres_CTX_slopes.csv`.
3.  **Run R Code:**
    -   Ensure you have R installed on your system.
    -   Open and run the provided R code (`trend_analysis_CEPH.R`) to produce the required plots based on the output files obtained from the SAS analysis.
    -   Adjust any input file paths or parameters within the R code as needed.

> **Note:** This repository showcases the analysis for a specific antimicrobial class, namely third- and fourth-generation cephalosporins in animals, for explanatory purposes. Make sure to adapt variable names, file paths and configurations in both SAS and R code based on your specific environment and dataset. For any questions or issues, refer to the documentation within the code files or reach out for assistance.

## Outputs

The SAS code produces two .csv files per antimicrobial class:

-   **`"X:\YOUR DIRECTORY\logcons_CEPH_ints.csv"`**: CSV file containing the estimated country-specific consumption intercepts exported from **`WORK.dat_logcons_CEPH_ints`**.

-   **`"X:\YOUR DIRECTORY\logcons_CEPH_slopes.csv"`**: CSV file containing the estimated country-specific consumption slopes exported from **`WORK.dat_logcons_CEPH_slopes`**.

-   **`"X:\YOUR DIRECTORY\logres_CEPH_ints.csv"`**: CSV file containing the estimated country-specific resistance intercepts exported from **`WORK.dat_logres_CEPH_ints`**.

-   **`"X:\YOUR DIRECTORY\logres_CEPH_slopes.csv"`**: CSV file containing the estimated country-specific resistance slopes exported from **`WORK.dat_logres_CEPH_slopes`**.

The output .csv files are then used by the R script to produce the trend analysis plots. The plots are saved in the `Plots` subfolder. They can be saved either in .jpeg or .pdf based on the user's choice.

## Authors

The trend analysis scripts are the result of joint collaborative efforts between experts from the European Centre for Disease Prevention and Control (ECDC), the European Food Safety Authority (EFSA), and the European Medicines Agency (EMA). Liselotte Diaz Högberg, Joana Gomes Dias, Elias Iosifidis, Vivian Leung, Gaetano Marrone, Dominique Monnet, Cèlia Ventura-Gabarro, Vera Vlahović-Palčevski and Therese Westrell (ECDC); Marc Aerts, Pierre-Alexandre Belœil, Ernesto Liebana, Valentina Rizzi and Bernd-Alois Tenhagen (Chair) (EFSA), and Claire Chauvin, Barbara Freischem, Hector Gonzalez Dorta, Helen Jukes, Zoltan Kunsagi, Filipa Mendes Oliveira, Oskar Nilsson, Cristina Ribeiro-Silva, Chantal Quinten and Engeline van Duijkeren (EMA).

## Correspondence

For questions or assistance, you can contact:

-   ECDC: [arhai\@ecdc.europa.eu](mailto:arhai@ecdc.europa.eu)
-   EFSA: [zoonoses\@efsa.europa.eu](mailto:zoonoses@efsa.europa.eu)
-   EMA: <https://www.ema.europa.eu/en/about-us/contacts/send-question-european-medicines-agency>
