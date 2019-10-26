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
Trainmerge <- merge(yTrain, activityLabels, sort = F)
dtTrain <- cbind(subjectTrain, Trainmerge, xTrain)


##merge test data
Testmerge <- merge(yTest, activityLabels, sort = F)
dtTest <- cbind(subjectTest, Testmerge, xTest)


##merge train and test data
mergeDF <- rbind(dtTrain, dtTest)

##mergeDF <- colnames(mergeDF) <- gsub('[-()]', '')


##create new tidy dataframe
##to make col easier to call I'm naming it "test"
colnames(mergeDF)[6] <- "test"


##this kinda works, problem is earlier on
x <- mergeDF %>% group_by(subject, Activity) %>% summarise_at(vars("test"), mean)


aggtable <- aggregate(mergeDF[,-c(1,2,3)], 
                      by=list("subject" = mergeDF$subject, "Activity"
                              = mergeDF$Activity), mean)
aggtable <- aggtable[order(aggtable$subject,aggtable$Activity),]


##print to file
setwd("~/coursera_class2/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset")

write.table(aggtable, file = "tidy_data_output.txt", row.name=FALSE)







