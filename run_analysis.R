###################################################################################################
#
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
#
###################################################################################################
# Init workspace
# Cleanup
rm(list=ls());
# load libraries
library(reshape2);
library(plyr);

# set up base variables
fileName <- "getdata%2Fprojectfiles%2FUCI HAR Dataset.zip";
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip";
wdName <- "UCI HAR Dataset";
wdPath <- paste(normalizePath(getwd()),wdName, sep="/", collapse=NULL);

# Reset current location in case the script runs twice
setwd(sub(wdName, "", wdPath, ignore.case = TRUE));

# Test for existing donwload file. If needed, download the file
if(!file.exists(fileName)){
  download.file(fileUrl, fileName, method="curl");
}
# Test for extracted zip file
if(!dir.exists(wdName)){
  unzip(fileName);
}
setwd(wdPath);

#
# read all file data
features <- read.table('./features.txt',header=FALSE)
# coerc features to character
features$V2 <- as.character(features$V2)
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
features <- features[grep(".*mean.*|.*std.*", features$V2),];

# 4. Appropriately labels the data set with descriptive variable names
features$V2 <- gsub("^(t)", "Time", features$V2);
features$V2 <- gsub("^(f)", "Frequency", features$V2);
features$V2 <- gsub("-mean", "MeanDeviation", features$V2);
features$V2 <- gsub("-std", "StandardDeviation", features$V2);
features$V2 <- gsub("Freq", "Frequency", features$V2);
features$V2 <- gsub("Acc", "Acceleration", features$V2);
features$V2 <- gsub("Mag", "Magnitude", features$V2);
features$V2 <- gsub('[-()]', '', features$V2);

activityLabels <- read.table('./activity_labels.txt',header=FALSE);

# train
trainingSubject <- read.table('./train/subject_train.txt',header=FALSE);
colnames(trainingSubject) = "SubjectID"; 

# prepare training data
trainingData <- read.table('./train/x_train.txt',header=FALSE);
# Reduce data set
trainingData <- trainingData[features$V1];
colnames(trainingData) = features$V2; 

# prepare training activities
trainingActivities <- read.table('./train/y_train.txt',header=FALSE);
colnames(trainingActivities) <- "ActivityID";
# 3. Uses descriptive activity names to name the activities in the data set
trainingActivities$ActivityID <- activityLabels[trainingActivities$ActivityID,2];

# test
testSubject <- read.table('./test/subject_test.txt',header=FALSE);
colnames(testSubject) = "SubjectID";

testData <- read.table('./test/x_test.txt',header=FALSE);
# Reduce data set
testData <- testData[features$V1]
colnames(testData) = features$V2; 

testActivities <- read.table('./test/y_test.txt',header=FALSE);
colnames(testActivities) <- "ActivityID";
# 3. Uses descriptive activity names to name the activities in the data set
testActivities$ActivityID <- activityLabels[testActivities$ActivityID,2];

# 1. Merges the training and the test sets to create one data set.
# finalize training data
trainingData <- cbind(trainingSubject,trainingActivities, trainingData);
# finalize test data
testData <- cbind(testSubject,testActivities, testData);
# Merge test and train
data <- rbind(trainingData, testData);
# save result table
write.table(data, "data.txt", row.name=FALSE);
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
# copy data from source
aggregatedData <- data;

# aggregate activities and subjects
aggregatedData <- ddply(data, .(SubjectID, ActivityID), function(x) colMeans(x[, 3:68]))
# save result table
write.table(aggregatedData, "aggregateddata.txt", row.name=FALSE);
