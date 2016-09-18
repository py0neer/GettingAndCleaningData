## Johns Hopkins - Getting and Cleaning Data
## Course Project

# Load the applied libraries
library(plyr)
library(reshape2)

# Get the path where this script runs
path_proj <- getwd()

# Get the data - Download the file and put the file  in the `data` folder
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")

# Unzip the file 
unzip(zipfile="./data/Dataset.zip",exdir="./data")

# For computation change the working directory to the folder where the raw data is stored
path_data <- file.path("./data" , "UCI HAR Dataset")
setwd(path_data)

# Read the training data
X_train <- read.table("./train/X_train.txt")
y_train <- read.table("./train/y_train.txt")
subject_train <- read.table("./train/subject_train.txt")

# Read the testing data
X_test <- read.table("./test/X_test.txt")
y_test <- read.table("./test/y_test.txt")
subject_test <- read.table("./test/subject_test.txt")

# Read feature informations, activity labels about measurements
features <- read.table("features.txt")
activity_labels <- read.table("activity_labels.txt")
colnames(activity_labels) <- c("act_id","act_label")

# Merge measurements in training and test datasets
X_complete <- rbind(X_train, X_test)

# Merge activities in training and test datasets
y_complete <- rbind(y_train, y_test)
colnames(y_complete) <- c("act_id")

# Merge subject groups in traing and test datasets
subject_complete <- rbind(subject_train, subject_test)
colnames(subject_complete) <- c("subj_grp")

# Extract only the measurements on the mean and standard deviation for each measurement
idx <- grep("std|mean|Mean", features$V2)
X_complete <- X_complete[idx]

# Uses descriptive activity names to name the activities in the data set
y_activity <- join(y_complete,activity_labels)

# Appropriately labels the data set with descriptive variable names 
desc_var_names <- features$V2[idx]
colnames(X_complete) <- as.character(desc_var_names)

# Bind activities, subjects and measurements together
X_all_complete <- cbind(y_activity, subject_complete, X_complete)

# Melting subjects, activities and measurements
X_melt <- melt(X_all_complete, id=c("subj_grp", "act_label"), 
               measure.vars = as.character(desc_var_names))

# Casting melting dataframe to get average of each variable for each activity and each subject
subj_act_data <- dcast(X_melt, subj_grp + act_label ~ variable, mean)

# Finaly go back to the project folder and write tidy data to file
setwd(path_proj)
write.table(subj_act_data, "tidy_data.txt", row.names=FALSE)
