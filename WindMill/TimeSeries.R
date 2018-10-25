setwd("~/Desktop/WindMill")
require(readxl) 
require("tswge")
require(xts)
df<-read_excel("Location-1PowerData-Mnthly.xlsx", sheet=1)
df$Gen_Date<-as.Date(df$Gen_Date)

plotts.wge(df$Gen_Kwh)
acf(df$Gen_Kwh,plot=TRUE)
parzen.wge(df$Gen_Kwh, dbcalc = TRUE, trunc = 0, plot=TRUE)

plotts.sample.wge(df$Gen_Kwh)