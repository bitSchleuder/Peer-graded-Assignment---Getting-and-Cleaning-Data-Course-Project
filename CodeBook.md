# Code Book
by Florian Schebelle

This Code Book is part of the run_analysis.R file. This book contains additional infromations on the source data, the transformations and the result data.

## The Data Source
A full description is available at the site where the data was obtained:

[The UCI Machine Learning Repository](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)

[Here are the data for the project](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)

The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone.

## Background to data
The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain. See 'features_info.txt' for more details. 

## Structure of the data
For each record it is provided:

- Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
- Triaxial Angular velocity from the gyroscope. 
- A 561-feature vector with time and frequency domain variables. 
- Its activity label. 
- An identifier of the subject who carried out the experiment.

## Transformation details
### 1. Merges the training and the test sets to create one data set.
The following data files where used for the entirely data set:
* features.txt
* activity_labels.txt
* subject_train.txt
* x_train.txt
* y_train.txt
* subject_test.txt
* x_test.txt
* y_test.txt

The data sets are loaded into the following script varaibles:
```
features <- read.table('./features.txt',header=FALSE);
activityLabels <- read.table('./activity_labels.txt',header=FALSE);
trainingSubject <- read.table('./train/subject_train.txt',header=FALSE);
trainingData <- read.table('./train/x_train.txt',header=FALSE);
trainingActivities <- read.table('./train/y_train.txt',header=FALSE);
testSubject <- read.table('./test/subject_test.txt',header=FALSE);
testData <- read.table('./test/x_test.txt',header=FALSE);
testActivities <- read.table('./test/y_test.txt',header=FALSE);
```

After The merge of all files, the plain result is stored in data.txt file.
```
# finalize training data
trainingData <- cbind(trainingSubject,trainingActivities, trainingData);
# finalize test data
testData <- cbind(testSubject,testActivities, testData);
# Merge test and train
data <- rbind(trainingData, testData);
```
### 2. Extracts only the measurements on the mean and standard deviation for each measurement.
The loada features data set was filtered by the R function grep:
```
features <- features[grep(".*mean.*|.*std.*", features$V2),];
```
The features data set contains 2 columns. V1 is the feature ID, V2 is the used function in plain text.

after this command, the loaded features set is condensed into a set containing only values with *mean* and *std*.

### 4. Appropriately labels the data set with descriptive variable names
after filtering the features, the next step is converting the existing variable names into better readable one.
```
features$V2 <- gsub("^(t)", "Time", features$V2);
features$V2 <- gsub("^(f)", "Frequency", features$V2);
features$V2 <- gsub("-mean", "MeanDeviation", features$V2);
features$V2 <- gsub("-std", "StandardDeviation", features$V2);
features$V2 <- gsub("Freq", "Frequency", features$V2);
features$V2 <- gsub("Acc", "Acceleration", features$V2);
features$V2 <- gsub("Mag", "Magnitude", features$V2);
features$V2 <- gsub('[-()]', '', features$V2);
```

### 3. Uses descriptive activity names to name the activities in the data set
The available activity lables are merged into the training and test activity data. The following code shows only the trainig´ng data part.
```
trainingActivities$ActivityID <- activityLabels[trainingActivities$ActivityID,2];
```

### 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
The aggregation of the merged raw data is provided by the function *ddply* from the library *plyr*.
The SubjectID was added for the subject from the training and test data (trainingSubject, testSubject).
The ActivityID was added for the activiity lable from the training and test data (trainingActivities, testActivities).
```
aggregatedData <- ddply(data, .(SubjectID, ActivityID), function(x) colMeans(x[, 3:68]))
```

### Result
The following files will be generated by the run_analysis.R script:
*data.txt (raw merged data)
*aggregateddata.txt (aggregated by subject and activity)

The run_analysis.R script uses the extracted folder "UCI HAR Dataset" for storing all output data sets.