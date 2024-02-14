#### Trend analyses ####
# This R script analyzes trends in log consumption and logit resistance of
# combinations of antimicrobial classes and E. coli. It processes SAS script 
# output files, containing the country-specific slopes and integers from longitudinal models,
# categorizes and visualizes data in 9 different combinations of increasing or decreasing 
# trends in log consumption and logit resistance. The generated plots are saved as .jpeg or .pdf.

# This R script showcases the analysis for a specific antimicrobial class, 
# namely third- and fourth-generation cephalosporins in humans, for explanatory purposes.
# Please note that variable names, file paths, plot parameters in this code should be adapted
# based on your specific environment and dataset.

# Setting working directory
setwd("X:/Your/Path/Directory")

# Load necessary packages
library(latex2exp)  # LaTeX-style expressions in plots

#### CEPH ####

# Plot configuration
par(mar=c(5,6,1,2),las=1) # Determining the four margins and style of axis labels 
jpegplots <- TRUE  # Produce JPEG if TRUE, PDF if false
inchf <- 1/2.54    # Width and height for PDF version
tcex <- 1.2        # Determines countries' text size
f <- 3.55          # Determines width and height of plot
ps <- 12           # Point size

## LOG(CONSUMPTION)

# Reading data from SAS output
sas.outputc.slopes <- read.csv("SAS_output/logcons_CEPH_slopes.csv",header=T)
sas.outputc.ints <- read.csv("SAS_output/logcons_CEPH_ints.csv",header=T)

beta.sasc <- data.frame(ISO=sas.outputc.slopes$ISO,
                        slope=sas.outputc.slopes$Pred,
                        slope.se=sas.outputc.slopes$StdErrPred,
                        slope.t=sas.outputc.slopes$tValue,
                        slope.lower=sas.outputc.slopes$Lower,
                        slope.upper=sas.outputc.slopes$Upper,
                        int=sas.outputc.ints$Pred,
                        int.se=sas.outputc.ints$StdErrPred,
                        int.lower=sas.outputc.ints$Lower,
                        int.upper=sas.outputc.ints$Upper)

# Selecting unique countries values
sel.unique.ISO <- unique(rank(sas.outputc.slopes$ISO,ties.method = "min"))
beta.sasc.fin <- beta.sasc[sel.unique.ISO,]

# Setting row names
nms <- length(sel.unique.ISO)
row.names(beta.sasc.fin) <- 1:nrow(beta.sasc.fin)
beta.sasc.fin$slope.sign <- ((beta.sasc.fin$slope.lower>0)|(beta.sasc.fin$slope.upper<0))

# Selecting subsets based on increasing/decreasing slopes and significance
selnegc <- (beta.sasc.fin$slope<0) & (beta.sasc.fin$slope.sign==T) 
selposc <- (beta.sasc.fin$slope>0) & (beta.sasc.fin$slope.sign==T) 
selnsc <- (beta.sasc.fin$slope.sign==F) 
selc <- (-1*selnegc+0*selnsc+1*selposc)

## LOGIT(RESISTANCE)

# Reading data from SAS output
sas.outputr.slopes <- read.csv("SAS_output/logitres_CEPH_slopes.csv",header=T)
sas.outputr.ints <- read.csv("SAS_output/logitres_CEPH_ints.csv",header=T)

# Creating a data frame for logit resistance
beta.sasr <- data.frame(ISO=sas.outputr.slopes$ISO,
                        slope=sas.outputr.slopes$Pred,
                        slope.se=sas.outputr.slopes$StdErrPred,
                        slope.t=sas.outputr.slopes$tValue,
                        slope.lower=sas.outputr.slopes$Lower,
                        slope.upper=sas.outputr.slopes$Upper,
                        int=sas.outputr.ints$Pred,
                        int.se=sas.outputr.ints$StdErrPred,
                        int.lower=sas.outputr.ints$Lower,
                        int.upper=sas.outputr.ints$Upper)

# Selecting unique ISO values
sel.unique.ISO <- unique(rank(sas.outputr.slopes$ISO,ties.method = "min"))
beta.sasr.fin <- beta.sasr[sel.unique.ISO,]

# Setting row names
row.names(beta.sasr.fin) <- 1:nrow(beta.sasr.fin)
beta.sasr.fin$slope.sign <- ((beta.sasr.fin$slope.lower>0)|(beta.sasr.fin$slope.upper<0))

# Selecting subsets based on increasing/decreasing slopes and significance
selnegr <- (beta.sasr.fin$slope<0) & (beta.sasr.fin$slope.sign==T) 
selposr <- (beta.sasr.fin$slope>0) & (beta.sasr.fin$slope.sign==T) 
selnsr <- (beta.sasr.fin$slope.sign==F) 
selr <- (-1*selnegr+0*selnsr+1*selposr)

## CHANGE IN LOGIT(RESISTANCE) AS FUNCTION OF CHANGE IN LOG(CONSUMPTION)

# The 9 combinations of increasing/decreasing slopes and significance AMR and AMC.
selcprp<-selposc&selposr
selcnrn<-selnegc&selnegr
selcnrp<-selnegc&selposr
selcprn<-selposc&selnegr
selcnsrns<-selnsc&selnsr
selcprns<-selposc&selnsr
selcnrns<-selnegc&selnsr
selcnsrp<-selnsc&selposr
selcnsrn<-selnsc&selnegr

### Plot with t-values

# Condition to choose the type of output
if (jpegplots){
  jpeg('Plots/Animal/trends-ESCCOL-CEPH-tvals.jpeg',width = 10*f, height = 7*f,units="cm",pointsize=ps,res=300)
}else{
  pdf('Plots/Animal/trends-ESCCOL-CEPH-tvals.pdf',width = 10*f*inchf, height = 7*f*inchf,pointsize=ps)
}

# Plotting the trends with t-values
plot(beta.sasr.fin$slope.t ~ beta.sasc.fin$slope.t,
     type="n",
     xlab="Annual change in log(consumption of third- and fourth-generation cephalosporins) in animals, averaged over time",
     ylab="Annual change in logit(probability of resistance in"~italic("E. coli)")~" from animals, averaged over time",
     cex.lab = 1.2)

# Adding reference lines
abline(h=0,col="black",lty=1,lwd=1)
abline(v=0,col="black",lty=1,lwd=1)

# Adding grey shaded non-significant areas
xgridr <- seq(min(beta.sasc.fin$slope.t)-1,max(beta.sasc.fin$slope.t)+1,by=0.1)
lxgridr <- length(xgridr)
cp <- qt(0.975,df=nms-2)
cubr <- rep(cp,lxgridr)
clbr <- rep(-cp,lxgridr)
polygon(c(xgridr, rev(xgridr)),c(cubr,rev(clbr)),col=adjustcolor("grey", alpha.f=0.2) ,border = NA)

xgridc <- seq(min(beta.sasr.fin$slope.t)-1,max(beta.sasr.fin$slope.t)+1,by=0.1)
lxgridc <- length(xgridc)
cubc <- rep(cp,lxgridc)
clbc <- rep(-cp,lxgridc)
polygon(c(cubc,rev(clbc)),c(xgridc, rev(xgridc)),col = adjustcolor("grey", alpha.f = 1), border = NA, density = 20, angle = 180, lty=3)

# Adding colored text labels for each combination
#1
colcnrn <- rgb(0, 245, 0, max = 255)  # Bright Green 
if (sum(selcnrn)>0) text(beta.sasr.fin$slope.t[selcnrn]~beta.sasc.fin$slope.t[selcnrn], labels=beta.sasr.fin$ISO[selcnrn], cex=tcex, font=2,col=colcnrn)
#2
colcnsrn <- rgb(0, 128, 0, max = 255)  # Dark Green
if (sum(selcnsrn)>0) text(beta.sasr.fin$slope.t[selcnsrn]~beta.sasc.fin$slope.t[selcnsrn], labels=beta.sasr.fin$ISO[selcnsrn], cex=tcex, font=2,col=colcnsrn)
#3
colcprn <- rgb(150, 200, 230, max = 255)  # Light Blue
if (sum(selcprn)>0) text(beta.sasr.fin$slope.t[selcprn]~beta.sasc.fin$slope.t[selcprn], labels=beta.sasr.fin$ISO[selcprn], cex=tcex, font=2,col=colcprn)
#4
colcnrns <- rgb(255,215,0,max=255)  # Yellow
if (sum(selcnrns)>0) text(beta.sasr.fin$slope.t[selcnrns]~beta.sasc.fin$slope.t[selcnrns], labels=beta.sasr.fin$ISO[selcnrns], cex=tcex, font=2,col=colcnrns)
#5
colcnsrns <- rgb(255, 140, 0, max = 255)  # Middle Orange
if (sum(selcnsrns)>0) text(beta.sasr.fin$slope.t[selcnsrns]~beta.sasc.fin$slope.t[selcnsrns], labels=beta.sasr.fin$ISO[selcnsrns], cex=tcex, font=2,col=colcnsrns)
#6
colcprns <- rgb(0, 0, 0, max = 255)  # Black
if (sum(selcprns)>0) text(beta.sasr.fin$slope.t[selcprns]~beta.sasc.fin$slope.t[selcprns], labels=beta.sasr.fin$ISO[selcprns], cex=tcex, font=2,col=colcprns)
#7
colcnrp <- rgb(139, 69, 19, max = 255)  # Brown
if (sum(selcnrp)>0) text(beta.sasr.fin$slope.t[selcnrp]~beta.sasc.fin$slope.t[selcnrp], labels=beta.sasr.fin$ISO[selcnrp], cex=tcex, font=2,col=colcnrp)
#8
colcnsrp <- rgb(128, 0, 255, max = 255)  # Purple
if (sum(selcnsrp)>0) text(beta.sasr.fin$slope.t[selcnsrp]~beta.sasc.fin$slope.t[selcnsrp], labels=beta.sasr.fin$ISO[selcnsrp], cex=tcex, font=2,col=colcnsrp)
#9
colcprp <- rgb(255, 0, 0, max = 255)  # Red
if (sum(selcprp)>0) text(beta.sasr.fin$slope.t[selcprp]~beta.sasc.fin$slope.t[selcprp], labels=beta.sasr.fin$ISO[selcprp], cex=tcex, font=2,col=colcprp)

# Adding legend
legend(x="bottomleft",
       lty=0,
       pch=15,
       col=c(colcnrn,colcnsrn,colcprn,colcnrns,colcnsrns,colcprns,colcnrp,colcnsrp,colcprp),
       legend=c(TeX("$Res \\downarrow Con \\downarrow$"), TeX("$Res \\downarrow Con -$"),
                TeX("$Res \\downarrow Con \\uparrow$"), TeX("$Res - Con \\downarrow$"),
                TeX("$Res - Con -$"), TeX("$Res - Con \\uparrow$"), 
                TeX("$Res \\uparrow Con \\downarrow$"), TeX("$Res \\uparrow Con -$"), 
                TeX("$Res \\uparrow Con \\uparrow$")),
       cex = 1.2,
       text.font=1.5,
       pt.cex = 1.5,
       border = 5)

# Saving the plot
dev.off()
