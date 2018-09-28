# My Projects
## Case Study 1: R Shiny Dashboard.
Have tried to use Shiny Dashboard (SD) with Employee Attrition Exploratory Analysis & Machine Learning. Thanks to Nathan Wall (team member) Dr. John Santerre.

We have created Frame work for dynamic scatter plot, bar chart, used the attrition variable as color and shape to differentiate

Have created visuals of histogram and corrogram

Tried Gradient Boost, Randomforest and the traditional decision tree to understand which ML algorithm is effective

Executed this model before invoking Shiny Server, as these models behaves differently inside the shiny

Have created ROC curve, Variable Importance and Assessment

Created Future Importance Assessment visualization which is dynamic based on Attrition (yes/no)

## Case Study 2: Twitter Sentiment Analysis using NLP & MongoDb

Core Idea behind this is to try Spark Streaming & inbuilt machine learning along with noSQL DB.

Learned how to setup the Spark and invoke from Python. However, were not able to extensively use it in this study.

Created a Python Program to connect to twitter hose to get live tweets based on key words of our interest. 

Used Data Science Keywords like '#bigdata, #AI, #datascience, #machinelearning, #ml, #iot

Passed the tweets through Stanford NLP to find the sentiment score and Google Geo Code for Latitude and Longitude.

Created RestPlus API with options to view all tweets, by location, sentiment value

## Case Study 3: Darknet Text mining

Started on the project idea from Data & Network Security class, using the data created by University of AZ Artificial Intelligence Lab. Refer to https://www.azsecure-data.org for more details.

Downloaded the SQL data of Dream Market Product and Seller data, created the tables in mySQL

With Python established connection to mySQL and NLTK to tokenize the contend after removing stop words, special characters.

This is inprogress text mining analysis.. Hope to find something interesting from the data and network security perspective.

## Case Study 4: Interactive Explorer of WindMill Data

Got couple of Wind Mill Power Generation Data, was performing Exploratory Data Analysis in iPython NoteBook. Like R Shiny in case study1, I explored Bokeh for this exercise. I was Inspired by the Bokeh Movie Explorer and Shiny Movie Explorer, created this application.

Loaded the data into mySQL, created drop down for the two sites, slider for year, month and drop down for x-axis and y-axis. I was able to confirm my findings visually with variations in month/year.

Was able to take advantage of the server option with NATIN to map global static IP to the port 8080 and share the interactive chart.

bokeh serve --show WindMill.py --allow-websocket-origin=99.999.999.999:8080

## Case Study 5: Telephone Bank Marketing for Term Deposit

This dataset was obtained from UCI repository, it has 41188 records with 21 attributes of Portuguese Banking Customer, Campaign and call details. Objective of this study is to predict if the customer would sign in for term deposit. Cleaning up the data, had to apply PCA, logit and SVM and predict. This dataset is biased towards 'no' to term-deposit. Had to explore different techniques to see which one gets the best results.

