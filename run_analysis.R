# Source of data for this project: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
library(plyr)

# 1. Merge the training and the test sets to create one data set.
#set working directory to the location where the UCI HAR Dataset was unzipped
setwd("C:/Users/PLANEUM55/Documents/Formation/Data\ Scientist/Getting\ and\ Cleanig\ data/Course\ Project/");

# Clean up workspace
rm(list=ls())


# Directories and files
uci_hard_dir        = "getdata_projectfiles_UCI HAR\ Dataset/UCI\ HAR\ Dataset"
features_file        = paste(uci_hard_dir, "/features.txt", sep = "")
activityLabel_file  = paste(uci_hard_dir, "/activity_labels.txt", sep = "")
xTrain_file         = paste(uci_hard_dir, "/train/X_train.txt", sep = "")
yTrain_file         = paste(uci_hard_dir, "/train/y_train.txt", sep = "")
subjectTrain_file   = paste(uci_hard_dir, "/train/subject_train.txt", sep = "")
xTest_file          = paste(uci_hard_dir, "/test/X_test.txt", sep = "")
yTest_file          = paste(uci_hard_dir, "/test/y_test.txt", sep = "")
subjectTest_file    = paste(uci_hard_dir, "/test/subject_test.txt", sep = "")

# Read in the data from files
features        = read.table(features_file,header=FALSE); #imports features.txt
activityLabel   = read.table(activityLabel_file,header=FALSE); #imports activity_labels.txt
subjectTrain    = read.table(subjectTrain_file,header=FALSE); #imports subject_train.txt
xTrain          = read.table(xTrain_file,header=FALSE); #imports x_train.txt
yTrain          = read.table(yTrain_file,header=FALSE); #imports y_train.txt
xTest           = read.table(xTest_file,header=FALSE); #imports x_test.txt
yTest           = read.table(yTest_file,header=FALSE); #imports y_test.txt
subjectTest     = read.table(subjectTest_file,header=FALSE); #imports subject_test.txt

# Assigin column names to the data imported above
colnames(activityLabel) = c('activityId','activityLabel');
colnames(subjectTrain)  = "subjectId";
colnames(xTrain)        = features[,2]; 
colnames(yTrain)        = "activityId";
colnames(subjectTest)   = "subjectId";
colnames(xTest)         = features[,2]; 
colnames(yTest)         = "activityId";


# cCreate the final training set by merging yTrain, subjectTrain, and xTrain
trainingData = cbind(yTrain,subjectTrain,xTrain);

# Create the final test set by merging the xTest, yTest and subjectTest data
testData = cbind(yTest,subjectTest,xTest);

# Combine training and test data to create a final data set
finalData = rbind(trainingData,testData);


# 2. Extract only the measurements on the mean and standard deviation for each measurement. 
finalData_mean = finalData[,grepl("mean|std|subjectId|activityId", names(finalData))]

# 3. Use descriptive activity names to name the activities in the data set
# Merge the finalData set with the acitivityType table to include descriptive activity names
finalData_mean = merge(finalData_mean,activityLabel,by='activityId',all.x=TRUE);

# 4. Appropriately label the data set with descriptive activity names. 
# Remove parentheses
names(finalData_mean) <- gsub('\\(|\\)',"",names(finalData_mean), perl = TRUE)
# Make syntactically valid names
names(finalData_mean) <- make.names(names(finalData_mean))
# Make clearer names
names(finalData_mean) <- gsub('Acc',"Acceleration",names(finalData_mean))
names(finalData_mean) <- gsub('GyroJerk',"AngularAcceleration",names(finalData_mean))
names(finalData_mean) <- gsub('Gyro',"AngularSpeed",names(finalData_mean))
names(finalData_mean) <- gsub('Mag',"Magnitude",names(finalData_mean))
names(finalData_mean) <- gsub('^t',"TimeDomain.",names(finalData_mean))
names(finalData_mean) <- gsub('^f',"FrequencyDomain.",names(finalData_mean))
names(finalData_mean) <- gsub('\\.mean',".Mean",names(finalData_mean))
names(finalData_mean) <- gsub('\\.std',".StandardDeviation",names(finalData_mean))
names(finalData_mean) <- gsub('Freq\\.',"Frequency.",names(finalData_mean))
names(finalData_mean) <- gsub('Freq$',"Frequency",names(finalData_mean))


# 5. Create a second, independent tidy data set with the average of each variable for each activity and each subject. 
finalData_Activity = ddply(finalData_mean, c("subjectId","activityId"), numcolwise(mean))
write.table(finalData_Activity, file = "finalData_Activity.txt")

