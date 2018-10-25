setwd("~/Desktop/WindMill")
require(readxl) 
require("plotly")
require("tswge")
df<-read_excel("BogamPowerData.xlsx", sheet = 1)
names(df)[1]<-"Date"
names(df)[8]<-"kwh_day"
names(df)[9]<-"kwh_mtd"
names(df)[10]<-"kwh_ytd"
names(df)[11]<-"plf_day"
names(df)[12]<-"plf_mtd"
names(df)[13]<-"plf_ytd"

ggplot(data = df, aes(x = Date, y = kwh_day))+
  geom_line(color = "#00AFBB", size = 2)

plotts.wge(df$kwh_day)

Realizaton=gen.arma.wge(df$kwh_day,.95,0,plot=TRUE,sn=0)

acf(Realizaton[1:75],plot=TRUE)
acf(Realizaton[75:150],plot=TRUE)

acf(Realizaton[1:150],plot=TRUE)
