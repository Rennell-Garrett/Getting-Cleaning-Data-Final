#Load Packages

require(dplyr)
require(data.table)

# url for project data for project
download.data = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

# Download Data for project
pdata = download.file(download.data, "download_data.zip")

# unzip then store in a folder
unzip("download_data.zip", exdir = "getting&cleaning/download_data")

#List Directories & Files
mydir = "getting&cleaning/download_data/UCI HAR Dataset/"
file_list <- list.files(mydir, full.names = T)
test.dir = "~/getting&cleaning/download_data/UCI HAR Dataset/test/Inertial Signals"
test.list = list.files(test.dir, full.names = T)
test_list_names = list.files(test.dir, full.names = F)

train.dir = "~/getting&cleaning/download_data/UCI HAR Dataset/train"
train.list = list.files(train.dir, full.names = T)

train.dir2 = "~/getting&cleaning/download_data/UCI HAR Dataset/train/Inertial Signals"
train.list2 = list.files(train.dir2, full.names = T)

## import files and convert to data table for faster processing
activity_labels = fread(file_list[1]) 
features_info <- read.csv(file_list[2], sep=";", comment.char="#") %>% tbl_dt  %>%filter(7:48)
features = fread(file_list[3]) %>% select(2)

#Import Files To Analyze for the Project
body_acc_x_test = fread(test.list[1]) 
body_acc_y_test = fread(test.list[2]) 
body_acc_z_test = fread(test.list[3]) 
body_gyro_x_test = fread(test.list[4]) 
body_gyro_y_test = fread(test.list[5]) 
body_gyro_z_test = fread(test.list[6])
total_acc_x_test = fread(test.list[7]) 
total_acc_y_test = fread(test.list[8]) 
total_acc_z_test = fread(test.list[9]) 

#Import Test Set
subject_test <- fread("~/getting&cleaning/download_data/UCI HAR Dataset/test/subject_test.txt")
X_test <- fread("~/getting&cleaning/download_data/UCI HAR Dataset/test/X_test.txt")
y_test <- fread("~/getting&cleaning/download_data/UCI HAR Dataset/test/y_test.txt")

#Import Training Set
subject_train <- fread("~/getting&cleaning/download_data/UCI HAR Dataset/train/subject_train.txt")
X_train <- fread("~/getting&cleaning/download_data/UCI HAR Dataset/train/X_train.txt")
y_train <- fread("~/getting&cleaning/download_data/UCI HAR Dataset/train/y_train.txt")

# Combine The Variables
train_data = cbind(subject_train, y_train,X_train)
test_data = cbind(subject_test, y_test, X_test)

#Combine Test and train
combined_data = rbind(train_data, test_data) %>% tbl_dt

#Create Variable Names
variable_names = unlist(c("Subject",  "Activity", features))

# add variable names to the dataset
names(combined_data) = variable_names

#Mean & std 
mean_std = select(combined_data,1:2, contains("mean"),contains("std"))

# Create Descriptive name for Activity Labels
currentActivity = 1
for (currentActivityLabel in activity_labels$V2) {
  mean_std$Activity = gsub(currentActivity, currentActivityLabel, mean_std$Activity)
  currentActivity <- currentActivity + 1
}


# Create tidy dataset
mean_std$Subject = as.factor(mean_std$Subject)
mean_std$Activity = as.factor(mean_std$Activity)


tidy_data = aggregate(mean_std, by=list(Activity = mean_std$Activity, Subject = mean_std$Subject), mean)
# Remove duplicate columns
tidy_data[,3] = NULL
tidy_data[,3] = NULL
write.csv(tidy_data, "tidy_data.csv")
 
