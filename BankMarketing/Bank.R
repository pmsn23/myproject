setwd("~/Lab1/bank-additional")
bank<-read.csv ("banklite.csv",  header=TRUE, sep = ';')
dropcol<-c("X","duration","cons_price_idx","cons_conf_idx","age","campaign","pdays","previous",
           "emp_var_rate","euribor3m","nr_employed","job","marital","education","Default","Housing","Loan")
bank<-bank[ , !(names(bank) %in% dropcol)]

bank[bank$response == 0 , "response"] <- "No"
bank[bank$response == 1 , "response"] <- "Yes"

bank[bank$Cellular == 0 , "Cellular"] <- "No"
bank[bank$Cellular == 1 , "Cellular"] <- "Yes"

#bank[bank$Housing == 0 , "Housing"] <- "No"
#bank[bank$Housing == 1 , "Housing"] <- "Yes"

#bank[bank$Loan == 0 , "Loan"] <- "No"
#bank[bank$Loan == 1 , "Loan"] <- "Yes"

#bank[bank$Default == 0 , "Default"] <- "No"
#bank[bank$Default == 1 , "Default"] <- "Yes"

bank$response<-as.factor(bank$response)
#bank$Default<-as.factor(bank$Default)
#bank$Housing<-as.factor(bank$Housing)
#bank$Loan<-as.factor(bank$Loan)
bank$Cellular<-as.factor(bank$Cellular)

saveRDS(bank, file = "PGbanklite.rds")
