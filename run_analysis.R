###Coursera class project
####Wearable computing data
###data downloaded from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip



library(data.table)
library(dplyr)
library(plyr)



##load activity and features
setwd("~/coursera_class2/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset")
activityLabels <- read.table("activity_labels.txt", sep = " ", col.names = c("ActivityId", "Activity"))
features <- fread("features.txt", sep = " ", col.names = c("FeatureId", "Feature"))

#Filtering features for mean & std only
features <- filter(features, features$`FeatureId` %in% grep("mean\\(\\)|std\\(\\)", features$Feature))


#loading train data

#Loading "train" details by activity
setwd("~/coursera_class2/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/train")
subjectTrain <- fread("subject_train.txt", col.names = "subject")

#Loading "train" activity 
yTrain <- fread("y_train.txt", col.names = "ActivityId")

#Loading "training" set based on required features
xTrain <- fread("X_train.txt") %>% select(features$`FeatureId`)
xTrain <- `colnames<-`(xTrain, features$Feature)




#loading test data
setwd("~/coursera_class2/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/test")
subjectTest <- fread("subject_test.txt", col.names = "subject")

yTest<- fread("y_test.txt", col.names = "ActivityId")

#Loading "testing" set based on features
xTest <- fread("X_test.txt") %>% select(features$`FeatureId`)
xTest <- `colnames<-`(xTest, features$Feature)



##merge train data
Trainmerge <- merge(yTrain, activityLabels)
dtTrain <- cbind(subjectTrain, Trainmerge, xTrain)


##merge test data
Testmerge <- merge(yTest, activityLabels)
dtTest <- cbind(subjectTest, Testmerge, xTest)


##merge train and test data
mergeDF <- rbind(dtTrain, dtTest)



##create new tidy dataframe
collist <- colnames(mergeDF)
MeltDF <- melt(mergeDF, id=c("subject","ActivityId", "Activity"), measure.vars=c(collist[4:69]))
aggtable <- aggregate(MeltDF[,-c(1,2,3,4)], by=list("subject" = MeltDF$subject, "Activity" = MeltDF$Activity), FUN=mean)
aggtable <- aggtable[order(aggtable$subject, aggtable$Activity),]

##print to file
setwd("~/coursera_class2/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset")
write.csv(aggtable, file = "tidy_data_output.csv")








