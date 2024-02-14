/************************************************************
* Trend Analyses for Log Consumption and Logit Resistance  *
*************************************************************/
/* This SAS script performs trend analyses on log consumption and logit resistance
   for a specific antimicrobial class, namely third- and fourth-generation cephalosporins in animals.
   The analysis includes importing CSV datasets with a determined structure (see README.md) and 
   conducting time trend longitudinal analyses using random intercept and random slope models.
   Estimated country-specific slopes and intercepts are exported to CSV files for further processing.
   
   The generated outputs from this script contribute to a broader analysis conducted in R,
   which categorizes and visualizes data in 9 different combinations of increasing or decreasing
   trends in log consumption and logit resistance. The results are utilized to create plots
   saved in various formats such as .jpeg or .pdf.
   
   Please note that variable names, file paths, and starting parameters for nlmixed in logit(resistance) in this code should be adapted
   based on your specific environment and dataset.
*/

/********************************************************************************************************
* Importing the (E. coli, cephalosporins) CSV dataset for the SAS analysis
*******************************************************************************************************/
PROC  import out=work.datYs 
            datafile="X:\YOUR DIRECTORY\datCEPH.csv"  /* Specify your own drive and (sub)directories */
            dbms=csv replace;
     getnames=yes;
     datarow=2; 
RUN;


/************************************************************************************************************************************
* Time trend longitudinal analysis of log(consumption), using a random intercept and random slope linear mixed model for normal data
************************************************************************************************************************************/
/* The longitudinal analysis using PROC nlmixed */
PROC nlmixed data=datYs;
   mean = intercept + rint + slope*year0 + rslope*year0;
   model log_Con_CEPH ~ normal(mean, s2);
   random rint rslope ~ normal([0,0],[g11,g21,g22]) subject=ID; /* ID = country identifier */
   predict intercept + rint out=dat_logcons_CEPH_ints; /* Computing the country-specific intercepts */
   predict slope + rslope out=dat_logcons_CEPH_slopes; /* Computing the country-specific slopes */
RUN;

/* Exporting the country-specific intercepts and slopes to CSV files */
PROC export data=work.dat_logcons_CEPH_ints 
            outfile="X:\YOUR DIRECTORY\SAS_output\logcons_CEPH_ints.csv"  /* Exporting the intercepts to CSV file */
            dbms=csv replace;
     putnames=yes;
RUN;

PROC export data=work.dat_logcons_CEPH_slopes 
            outfile="X:\YOUR DIRECTORY\SAS_output\logcons_CEPH_slopes.csv" /* Exporting the slopes to CSV file */
            dbms=csv replace;
     putnames=yes;
RUN;


/*************************************************************************************************************************************************
* Time trend longitudinal analysis of logit(resistance), using a random intercept and random slope generalized linear mixed model for binary data
*************************************************************************************************************************************************/
/* The longitudinal analysis using PROC nlmixed, first without random effects, then with only a random intercept, and finally with random intercept and slope */

PROC logistic data=work.datYs; /* First fitting a basic logistic regression model, whose estimates can be used as starting values for the longitudinal model with only a random intercept */
   model eventCEPH/trialCEPH = year0;
RUN;

PROC nlmixed data=work.datYs qpoints=200; /* Next fitting a random intercepts model, whose estimates can be used as starting values for the longitudinal model with a random intercept and slope */
   parms intercept=-3.6 slope=-0.12 g11=0; /* Starting values based on the basic logistic fit */
   eta = intercept + rint + slope*year0;
   p = exp(eta)/(1 + exp(eta));
   model eventCEPH ~ binomial(trialCEPH, p) ;
   random rint ~ normal(0, exp(g11)) subject=ID;
RUN;

PROC nlmixed data=work.datYs; /* The final full analysis with a random intercept and a random slope */
   parms intercept=-3.96 slope=-0.12 g11=0.11 cov21=0.1 g22=-0.1; /* Starting values based on the nlmixed fit with only a random intercept */
   eta = intercept + rint + slope*year0 + rslope*year0;
   p = exp(eta)/(1 + exp(eta));
   model eventCEPH ~ binomial(trialCEPH, p) ;
   random rint rslope ~ normal([0,0],[exp(g11),cov21,exp(g22)]) subject=ID;
   predict slope + rslope out=dat_logitres_CEPH_slopes; /* Computing the country-specific intercepts */
   predict intercept + rint out=dat_logitres_CEPH_ints; /* Computing the country-specific slopes */
RUN;

/* Exporting the country-specific intercepts and slopes to CSV files */
PROC export data=work.dat_logitres_CEPH_ints 
            outfile="X:\YOUR DIRECTORY\SAS_output\logitres_CEPH_ints.csv" /* Exporting the intercepts to CSV file */
            dbms=csv replace;
     putnames=yes;
RUN;

PROC export data=work.dat_logitres_CEPH_slopes 
            outfile="X:\YOUR DIRECTORY\SAS_output\logitres_CEPH_slopes.csv" /* Exporting the slopes to CSV file */
            dbms=csv replace;
     putnames=yes;
RUN;
