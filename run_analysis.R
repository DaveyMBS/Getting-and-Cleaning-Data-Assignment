## Check that required library 'reshape2' is installed and
## install if not

if (!("reshape2" %in% rownames(installed.packages())) ) {
 install.packages("reshape2")
} 

## Load required library 'reshape2'
library(reshape2)

## Download and unzip raw data
fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
dir.create("C:/Clean_Data_Assignment", showWarnings = FALSE)
download.file(fileurl, destfile = "C:/Clean_Data_Assignment/zipdata.zip")
setwd("C:/Clean_Data_Assignment")
unzip("C:/Clean_Data_Assignment/zipdata.zip")
setwd("C:/Clean_Data_Assignment/UCI HAR Dataset")

## Read in all text files:

## Obtain activity labels based on activity ids
activity_labels <- read.table("activity_labels.txt", col.names = c("activity_id", "activity_name"))

## Obtain data column names 
features <- read.table("features.txt")
transposed <- t(features)
colNames <- transposed[2,]

## Obtain test data and label column names 
x_test <- read.table("./test/X_test.txt", col.names = colNames)
y_test <- read.table("./test/y_test.txt", col.names = "activity_id")
subject_test <- read.table("./test/subject_test.txt", col.names = "subject_id")
testdat <- cbind(subject_test, y_test, x_test)

## Obtain training data and label column names
x_train <- read.table("./train/X_train.txt", col.names = colNames)
y_train <- read.table("./train/y_train.txt", col.names = "activity_id")
subject_train <- read.table("./train/subject_train.txt", col.names = "subject_id")
traindat <- cbind(subject_train, y_train, x_train)

## Combine all data (test and training) into a single data set
alldat <- rbind(testdat, traindat)

## Subset the data relating to means and standard deviations
## from the single data set

## Create index of columns relating to means and standard deviations
meanindex <- grep("mean",names(alldat),ignore.case=TRUE)
stdindex <- grep("std",names(alldat),ignore.case=TRUE)
index <- c(meanindex, stdindex)
index_names <- names(alldat)[index]

## Subset data from alldat using index
meanstddat <- alldat[, index_names]
ids <- alldat[, 1:2]
meanstddat <- cbind(ids, meanstddat)

## Apply activity labels to subset data
activitydat <- merge(activity_labels, meanstddat, by.x = "activity_id", by.y = "activity_id", all = TRUE)

## Final step is to create a new data frame with 
## the average of each variable for each activity and each subject

## Reshape subset data based on activity_id, activity_name and subject_id
melted <- melt(activitydat,id=c("activity_id","activity_name","subject_id"))

## Produce data frame with averages of each variable
recast <- dcast(melted, activity_id + activity_name + subject_id ~ variable, mean)

## Output dataframe containing the variable averages 
## as file "tidied_data.txt"
write.table(recast, file = "./tidied_data.txt")
