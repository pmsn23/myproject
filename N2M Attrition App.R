require(RCurl)
require(shiny)
require(shinydashboard)
require(DT)
require(ggplot2)
require(GGally)
require(party)
require(randomForest)
require(reshape)
require(corrgram)
require(pROC)
require(Metrics)
require(ROSE)
require(tidyquant) 
require(lime)   
require(caret)


#read the data in
URL <- 'https://raw.githubusercontent.com/nateewall/DDSAnalytics_Churn/master/CustomerAttritionData.csv'
df<-read.csv(text=getURL(URL), header=TRUE) 
#remove id and duplicated variables
df <- df[,-c(9,10,22,27)]
#sample the data and create train & test indicator variables
smp_size <- floor(0.70 * nrow(df))
set.seed(269)
train_ind <- sample(seq_len(nrow(df)), size = smp_size)

train <- df[train_ind, ] #training
test <- df[-train_ind, ]#testing

#ref <- reformulate(setdiff(colnames(train), "Attrition"), response="Attrition")
#balance the data to over sample from Attrition = 'Yes' and undersample from Attrition = 'No'
train.both <- ovun.sample(Attrition ~ ., data = train, method = "both", p=0.4, N=1000, seed = 1)$data

#train the random forest
predictors <- names(train.both[,-2])
outcome <- "Attrition"

objControl <- trainControl(method = "repeatedcv", number=10,repeats = 2,
                           summaryFunction = twoClassSummary,
                           classProbs = TRUE)
#train the random forest using control from above as well as center & scale the variables
rFout <- train(train.both[,predictors], train.both[,outcome], 
               method = "rf",
               metric = "ROC",
               trControl=objControl,  
               preProc = c("center", "scale"),
               verbose = F)

objModel <- train(train.both[,predictors], train.both[,outcome], 
                  method = "gbm",
                  metric = "ROC",
                  trControl=objControl,  
                  preProc = c("center", "scale"),
                  verbose = F)


#declare UI interface
ui <- dashboardPage(
  dashboardHeader(title = "Attrition Analysis"),
  #declare the side bar tabs & names
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard",tabName = "dashboard", icon = icon("dashboard")),
      menuItem("EDA",tabname="EDA",icon=icon("th"), startExpanded = FALSE,
               menuSubItem("Plots",tabName = "plots",icon = icon("bar-chart-o"))),
      menuItem("Predictions",tabname="predict",icon=icon("balance-scale"), startExpanded = FALSE,
               menuSubItem("Randomforest",tabName = "forest",icon = icon("random")),
               menuSubItem("Gradient Boost", tabName = "GBM",icon = icon("superpowers")),
               menuSubItem("Decision Tree",tabName = 'tree',icon=icon("tree"))),
      menuItem("Conculison",tabName = 'result',icon = icon("thumbs-up", lib = "glyphicon")),
      menuItem("Data",tabName = 'data',icon=icon("table"))
    )
  ),
  #declare what goes in the body of the dashboard and the layout
  dashboardBody(
    tabItems(
      tabItem(tabName = 'dashboard',
              h2("DDSAnalytics - Talent Management Analysis"),
              uiOutput("Intro"),
              tags$head(tags$style("#Intro{color: black;
                                 font-size: 20px;
                                   }"))
      ),
      tabItem(tabName = "eda",
              h2("Exploratory Data Analysis")),
      #get user input on variable to explore
      tabItem(tabName = 'plots',
              h2("Visualization"),
              fluidRow(
                sidebarLayout(
                  sidebarPanel(width=3,
                    selectInput("var",
                                label = "Select variable",
                                choices = c(
                                  "Age" = 1,
                                  "Business Travel" = 3,
                                  "Daily Rate" = 4,
                                  "Department" = 5,
                                  "Distance From Home" = 6,
                                  "Education" = 7,
                                  "Education Field" = 8,
                                  "Environment Satisfaction" = 9,
                                  "Gender"= 10,
                                  "Hourly Rate" = 11,
                                  "Job Involvement" = 12,
                                  "Job Level" = 13,
                                  "Job Role" = 14,
                                  "Job Satisfaction" = 15,
                                  "Maritial Status" = 16,
                                  "Monthly Income" = 17,
                                  "Monthly Rate" = 18,
                                  "Number of Companies Worked" = 19,
                                  "Over Time" = 20,
                                  "Percent Salary Hike" = 21,
                                  "Performance Rating" = 22,
                                  "Relationship Satisfaction" = 23,
                                  "Stock Option Level" = 24,
                                  "Total Working Years" = 25,
                                  "Training Times Last year" = 26,
                                  "Work Life Balance" = 27,
                                  "Years at Company" = 28,
                                  "Years in Current Role" = 29,
                                  "Years Since Last Promotion" = 30,
                                  "Years with Current Manager" = 31
                                ),
                                selected = 20),
                    #get user input on what variable to split or add to x axis
                    selectInput("facet_row",
                                label = "Facet Row",
                                choices = c(
                                  "Age" = 1,
                                  "Attrition" = 2,
                                  "Business Travel" = 3,
                                  "Daily Rate" = 4,
                                  "Department" = 5,
                                  "Distance From Home" = 6,
                                  "Education" = 7,
                                  "Education Field" = 8,
                                  "Environment Satisfaction" = 9,
                                  "Gender"= 10,
                                  "Hourly Rate" = 11,
                                  "Job Involvement" = 12,
                                  "Job Level" = 13,
                                  "Job Role" = 14,
                                  "Job Satisfaction" = 15,
                                  "Maritial Status" = 16,
                                  "Monthly Income" = 17,
                                  "Monthly Rate" = 18,
                                  "Number of Companies Worked" = 19,
                                  "Over Time" = 20,
                                  "Percent Salary Hike" = 21,
                                  "Performance Rating" = 22,
                                  "Relationship Satisfaction" = 23,
                                  "Stock Option Level" = 24,
                                  "Total Working Years" = 25,
                                  "Training Times Last year" = 26,
                                  "Work Life Balance" = 27,
                                  "Years at Company" = 28,
                                  "Years in Current Role" = 29,
                                  "Years Since Last Promotion" = 30,
                                  "Years with Current Manager" = 31
                                ),
                                selected = 14),
                    #plot histogram or scatter
                    selectInput("type",
                                label = "Plot Type",
                                choices = c(
                                  "Bar" = 1,
                                  "Scatter" = 2),
                                selected = 2)
                  ),
                  #also we provide the histogram of all numeric and the correlations
                  mainPanel(
                    tabsetPanel(type = "tabs",
                    tabPanel("Basic Plot",plotOutput("AtrStack")),
                    tabPanel("Histogram",plotOutput("Histogram")),
                    tabPanel("Corrgram",plotOutput("Corrgram"))
                    )
                  )))),
      #first reviw the random forest model's Important variables & performance
      tabItem(tabName = "forest",
              h2("Randomforest Model"),
              fluidRow(
                sidebarLayout(
                  sidebarPanel(width=3,
                    selectInput("FIErfvar",
                                label = "Attrition",width="120px",
                                choices = c(
                                  "Yes" = 1,
                                  "No" = 2),
                                selected = 1)
                    ),
              mainPanel(
                tabsetPanel(type = "tabs",
                            tabPanel("VarImpRF",
                                     plotOutput("rFo")),
                            tabPanel('Performance',
                                     plotOutput("rfROC"),
                                     verbatimTextOutput("PerformanceRF")),
                            tabPanel('Assessment',
                                      plotOutput("FIErf"))
                        ))))),
      #decision tree from top 5 ROC
      tabItem(tabName = "tree",
              h2("Decision Tree"),
              plotOutput("Rtree")),
      #gradient boosting machine & results
      tabItem(tabName = "GBM",
              h2("Gradient Boosting Model"),
              fluidRow(
                sidebarLayout(
                  sidebarPanel(width=3,
                    selectInput("FIEgbmvar",
                                label = "Attrition",width="120px",
                                choices = c(
                                  "Yes" = 1,
                                  "No" = 2),
                                selected = 1)
                  ),
              mainPanel(
                tabsetPanel(type = "tabs",
                            tabPanel("VarImpGBM",
                                     plotOutput("GBM")),
                            tabPanel("Performance",
                                     plotOutput("gbmROC"),
                                     verbatimTextOutput("PerformanceGBM")),
                            tabPanel("Assessment",
                                     plotOutput("FIE"))
                ))))),
      #conclusions & next steps
      tabItem(tabName = "result",
              h2("Conclusion"),
              uiOutput("Decision"),
              tags$head(tags$style("#Decision{color: black;
                                   font-size: 20px;
                                   }"))
              ),
      #data used
      tabItem(tabName = "data",
              h2("Employee Data"),
              DT::dataTableOutput("rawtable"),
              downloadButton("downloadData", "Download as CSV"))
    )
  )
)

server <- function(input, output) { 
  #--------------------------------EDA Plot---------------------------------#
  #plot for the bar or scatter plots of variables based on user selection
  output$AtrStack <- renderPlot({
    #declare variable selections to use in plots
    ec<-as.numeric(input$var)
    fr<-as.numeric(input$facet_row)
    ty<-as.numeric(input$type)
    x<-df[, ec]
    f<-names(df[fr])
    if (fr==0){
      f<-names(df[2])
    }
    x_axsis<-names(df[ec])
    y_axsis<-names(df[fr])
    #bar plot
    if (ty==1){
      ggplot(df,aes(x=x,fill=Attrition))+
        geom_bar(width=0.5)+
        facet_wrap(as.formula(paste("~",f)))+
        xlab(x_axsis)+
        ylab("Total Count")+
        labs(fill='Attrition')
    }
    #scatter plot
    else {
      ggplot(df, aes_string(x=x, y=f, shape="Attrition", color="Attrition")) +
        geom_jitter(position = position_jitter(width = 0.25)) +
        xlab(x_axsis)+
        ylab(y_axsis)
    }
  }, height=499, width=709)
  
  #histogram of all numerics
  output$Histogram <- renderPlot({

    ggplot(data=melt(df), mapping=aes(x=value)) + 
      geom_histogram(bins=20, col= 'Blue') + 
      facet_wrap (~variable, scales = "free_x")
  },height=499, width=709)
  
  #correlation plot of all numerics
  output$Corrgram<-renderPlot({
    corrgram(df)
  },height=499, width=709)

  #decision tree of to 5 variables selected from RF
  treeoutput<-ctree(Attrition~OverTime+JobRole+MonthlyIncome
                    +StockOptionLevel+EnvironmentSatisfaction,
                    data=train.both)
  output$Rtree<-renderPlot({
    plot(treeoutput, inner_panel=node_inner(treeoutput, pval = TRUE, id = FALSE))
  }, height=599, width=999)
  
  #--------------------------------Random Forest----------------------------------#

  #plot the variable importance
  output$rFo<-renderPlot({
    plot(varImp(rFout))
  }, height=499, width=709)
  
  #get probability predictions
  probPredRf <- predict(object=rFout, test[,predictors], type = "prob")
  
  #plot the ROC
  rf.ROC <- roc(predictor=probPredRf$Yes,
                response=test$Attrition,
                levels=rev(levels(test$Attrition)))
  
  #produce the plot
  output$rfROC<-renderPlot({
    plot(rf.ROC,main="Random Forest ROC")
  }, height=399, width=709)
  
  predRf <- ifelse(probPredRf$Yes > 0.5,"Yes","No")
  xrf <- table(test$Attrition, predRf)
  
  # Performance analysis
  tnrf <- xrf[1]
  tprf <- xrf[4]
  fprf <- xrf[3]
  fnrf <- xrf[2]
  
  accuracyrf <- (tprf + tnrf) / (tprf + tnrf + fprf + fnrf)
  misclassification_raterf <- 1 - accuracyrf
  recallrf <- tprf / (tprf + fnrf)
  precisionrf <- tprf / (tprf + fprf)
  null_error_raterf <- tnrf / (tprf + tnrf + fprf + fnrf)
  
  output$PerformanceRF<-renderText({
    paste(
      paste0("Accuracy:", accuracyrf),
      paste0("Misclassification Rate:", misclassification_raterf),
      paste0("Recall:", recallrf),
      paste0("Precision:", precisionrf),
      paste0("Null Error Rate:", null_error_raterf),
      sep="\n"
    )
  }
  )
  
  #output the feature importance on 5 of the observations to understnad variable contributing to label
  output$FIErf<-renderPlot({
    Sel<-as.numeric(input$FIErfvar)
    # Run lime() on training set
    explainerrf <- lime::lime(
      as.data.frame(train[,-2]), 
      model          = rFout, 
      bin_continuous = FALSE)
    
    # Run explain() on explainer
    if (Sel==1){
      explanationrf <- lime::explain(
        as.data.frame(test[which(test$Attrition == "Yes"),-2][1:6,]), 
        explainer    = explainerrf, 
        n_labels     = 1, 
        n_features   = 6,
        kernel_width = 0.5)
      plot_features(explanationrf) +
        labs(title = "Feature Importance Visualizations",
             subtitle = "First 6 obs where Attrition='Yes'")
      
    }
    else{
      explanationrf <- lime::explain(
        as.data.frame(test[which(test$Attrition == "No"),-2][1:6,]), 
        explainer    = explainerrf, 
        n_labels     = 1, 
        n_features   = 6,
        kernel_width = 0.5)      
      plot_features(explanationrf) +
        labs(title = "Feature Importance Visualizations",
             subtitle = "First 6 obs where Attrition='No'")
    }
    
  }, height=499, width=709)
  
  #------------------------------------GBM---------------------------------------#
  #Code for training the Gradient Boosting model
  
  relInf <-summary(objModel)
  #plot the varialbes by relative influence
  output$GBM<-renderPlot({
    ggplot(relInf, aes(x=reorder(var, rel.inf), y=rel.inf)) +
      geom_bar(stat='identity') +
      coord_flip()
  },height=499, width=709)
  
  #get probability predictions
  probPred <- predict(object=objModel, test[,predictors], type = "prob")
  
  #plot the ROC
  gbm.ROC <- roc(predictor=probPred$Yes,
                 response=test$Attrition,
                 levels=rev(levels(test$Attrition)))
  
  #produce the plot
  output$gbmROC<-renderPlot({
    plot(gbm.ROC,main="GBM ROC")
  },height=399, width=709)
  
  #create the prediction
  pred <- ifelse(probPred$Yes > 0.4,"Yes","No")
  x <- table(test$Attrition, pred)
  
  # Performance analysis
  tn <- x[1]
  tp <- x[4]
  fp <- x[3]
  fn <- x[2]
  
  #calculate these measures
  accuracy <- (tp + tn) / (tp + tn + fp + fn)
  misclassification_rate <- 1 - accuracy
  recall <- tp / (tp + fn)
  precision <- tp / (tp + fp)
  null_error_rate <- tn / (tp + tn + fp + fn)
  #include those results in output. (hard coded for simplicity sake need to redo)
  output$PerformanceGBM<-renderText({
    paste(
      paste0("Accuracy:", accuracy),
      paste0("Misclassification Rate:", misclassification_rate),
      paste0("Recall:", recall),
      paste0("Precision:", precision),
      paste0("Null Error Rate:", null_error_rate),
      sep="\n"
    )
  })
  
  #output the feature importance on 5 of the observations to understnad variable contributing to label
  output$FIE<-renderPlot({
    LimVar<-as.numeric(input$FIEgbmvar)
    # Run lime() on training set
    explainer <- lime::lime(
      as.data.frame(train[,-2]), 
      model          = objModel, 
      bin_continuous = FALSE)
    
    if (LimVar==1){
      # Run explain() on explainer
      explanation <- lime::explain(
        as.data.frame(test[which(test$Attrition =='Yes'),-2][1:6,]), 
        explainer    = explainer, 
        n_labels     = 1, 
        n_features   = 6,
        kernel_width = 0.5)    
        plot_features(explanation) +
        labs(title = "Feature Importance Visualizations",
             subtitle = "First 6 obs where Attrition='Yes'")
    }
    else{
      # Run explain() on explainer
      explanation <- lime::explain(
        as.data.frame(test[which(test$Attrition =='No'),-2][1:5,]), 
        explainer    = explainer, 
        n_labels     = 1, 
        n_features   = 6,
        kernel_width = 0.5)
        plot_features(explanation) +
        labs(title = "Feature Importance Visualizations",
             subtitle = "First 6 obs where Attrition='No'")
    }
  }, height=499, width=709)
  
  #------------------------Output Raw Data-----------------------------#
  #render data table
  output$rawtable = DT::renderDataTable({
    DT::datatable(train, options = list(scrollX = TRUE))
  })
  
  output$Intro<-renderUI({
    (HTML("<ul><p style>
          <li>DDSAnalytics Specializes in Talent Management for Fortune 1000 Company.</li> 
          <li>Talent Management is the process of developing and retaining employees.</li>
          <li>To gain over competition DDSAnalytics wanted leverage data science for talent management.</li>
          <li>N<sup>2</sup>M Data Science Team is commissioned to conduct analysis on their existing employee data in reducing (or) preventing employee turnover.</li>
          <li>DDSAnalytics existing employee data has 1470 records with 35 variables including those who left the company</li>
          <li>N<sup>2</sup>M will utilize various machine learning & data science techniques to understand the features contributing to employee attrition</li>
          <li>The goal is to identify the top5 reason, apply the methodology to predict attrition for the HR team to act on the findings.</li>
          </ul>"))
  })
  
  output$Decision<-renderUI({
    (HTML("<ul><p style>
          Based on the results of our algorithm below are some of the top variables for identifying employee at risk of attrition
          <li>Overtime</li>
          <li>Job Role</li>
          <li>Monthly Income</li>
          <li>Age</li>
          <li>Daily Rate</li>

          Based on the results of classification it does appear that attrition can loosely be categorized into two groups:
          
          One group appears to largely be driven by older employees with more work experience who work overtime in largely sales roles. Many of them have worked for multiple companies in the past, but maybe are still farely new to this corporation.

          The other group seems to be made up of younger, early career employees in technical roles. They seem to make less money than the other group, and for many this is there first company they have worked for.
          
          Depending on the priorities of the company they could proactively target one group by offering different benefits that are considered valuable to the group of interest.
    </ul>"))
  })
  
  #write to csv
  data<-train
  output$downloadData <-downloadHandler(
  filename = function() {
    paste("data-", Sys.Date(),".csv",sep="")
  },
  content = function(file) {
    write.csv(data,file) 
  })
}

shinyApp(ui, server)
