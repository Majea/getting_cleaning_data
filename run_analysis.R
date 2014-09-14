###
### This script downloads data taken from wearable device sensors, loads it and creates a tidy data set out of it. 
### Please refer to README.md for details about the goal of this script and CodeBook.md for details 
### about the different steps taken here to build the tidy data set.
### The comments in this script describes the implementation details while the CodeBook.md file describes the logical steps taken to build the tidy
### data set. The justification of the different steps is also described in the CodeBook.md. 
### The steps listed in this script refer to the same steps listed in the CodeBook.md file.
###

library(plyr)

# step 1: download the original data set
# ======================================
dataFileName <- "wearable.zip"
dataUri <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if(!file.exists(dataFileName)){
    download.file(dataUri, dataFileName, mode="wb")
}

# step 2: unzip the data set.
# ==========================
unzip(dataFileName)

# step 3: load the data set in memory: X_train.txt, y_train.txt, X_test.txt, y_test.txt and features.txt
# ====================================
X_train <- read.table("UCI HAR Dataset\\train\\X_train.txt",  colClasses="numeric")
# y is supposed to contain categories/classes => not meant to be used for numeric calculations. keeping it as character is safer
y_train <- read.table("UCI HAR Dataset\\train\\y_train.txt",  colClasses="character") 
subject_train <- read.table("UCI HAR Dataset\\train\\subject_train.txt", colClasses="character") # this is the subject id => use as character, like for y
X_test <- read.table("UCI HAR Dataset\\test\\X_test.txt",  colClasses="numeric")
y_test <- read.table("UCI HAR Dataset\\test\\y_test.txt",  colClasses="character")
subject_test <- read.table("UCI HAR Dataset\\test\\subject_test.txt",  colClasses="character")
featureNames <- read.table("UCI HAR Dataset\\features.txt", stringsAsFactors = FALSE) # col 1 = col index in X_xxx and col 2 = feature name
activityLabels <- read.table("UCI HAR Dataset\\activity_labels.txt", stringsAsFactors = FALSE) # col 1 = number in the y_xxx files and col 2 = corresponding activity label 

{
    ### assertions check: I'm verifying that what I just loaded is consistent with what I observed manually outside R.
    # an error here means there is a programming error, so it shouldn't fail after I've debugged the code  ;-)
    # there must be 7352 rows in training set (number of lines in y_train.txt) 
    # there must be 2947 rows in the test set (number of lines in the y_test.txt)
    # there must be 561 columns in X_train and X_test (number of features specified in README.txt)
    if (nrow(X_train)!=7352) stop("wrong number of lines in X_train")
    if (nrow(y_train)!=7352) stop("wrong number of lines in y_train")
    if (nrow(subject_train)!=7352) stop("wrong number of lines in subject_train")
    if (nrow(X_test)!=2947) stop("wrong number of lines in X_test")
    if (nrow(y_test)!=2947) stop("wrong number of lines in y_test")
    if (nrow(subject_test)!=2947) stop("wrong number of lines in subject_test")
    if (ncol(X_train)!=561) stop("wrong number of columns in X_train")
    if (ncol(y_train)!=1) stop("wrong number of columns in y_train")
    if (ncol(subject_train)!=1) stop("wrong number of columns in subject_train")
    if (ncol(X_test)!=561) stop("wrong number of columns in X_test")
    if (ncol(y_test)!=1) stop("wrong number of columns in y_test")
    if (ncol(subject_test)!=1) stop("wrong number of columns in subject_test")
    if (nrow(featureNames)!=561) stop("wrong number of features in featureNames")
    if (ncol(featureNames)!=2) stop("wrong number of columns in featureNames")
    if (sum(sapply(X_train, is.numeric))!=561) stop("X_train should contain numeric values")
    if (sum(sapply(X_test, is.numeric))!=561) stop("X_test should contain numeric values")
    if (sum(sapply(y_train, is.numeric))!=0) stop("y_train should contain character values")
    if (sum(sapply(y_test, is.numeric))!=0) stop("y_test should contain character values")
    if (sum(sapply(subject_train, is.numeric))!=0) stop("subject_train should contain character values")
    if (sum(sapply(subject_test, is.numeric))!=0) stop("subject_test should contain character values")
    if (nrow(activityLabels) != nrow(unique(y_test))) stop("inconsistent number of labels for the activities")
}

# step 4: merge the training and test sets.
# =========================================
# first, we'll have to put the features X back with the observations y
# the number of rows of y match the number of rows of X. In other words, the content of y is a new column for our merged data set.
full_train <- cbind(subject_train, X_train, y_train)
full_test <- cbind(subject_test, X_test, y_test)

# second, we have to merge the X_test and X_train. 
# These are just different samples of the same data sets (1 sample = 1 row), so they have the same columns
# so we can append the rows of the test set X_test at the end of the training set X_train
merged <- rbind(full_train, full_test)

{
    ### assertions check: I'm verifying that what I have now is consistent
    # an error here means there is a programming error, so it shouldn't fail after I've debugged the code  ;-)
    # there must be 10299 rows in training set (number of instances specified on web site) 
    # there must be 563 columns in merged (number of features specified in README.txt + the observation we'll train or verify with + subject list)
    if (nrow(merged)!=10299) stop("wrong number of lines in merged data set")
    if (ncol(merged)!=563) stop("wrong number of columns in merged data set")
}

# step 5: extract only the measurements on the mean and standard deviation for each measurement. 
# ==============================================================================================
# I keep in the data set the columns whose names contain either "mean()" or "std()". I keep the last column (y files) as well.
# see CodeBook.md for the justification.

colsBase <- grepl("mean\\(\\)", featureNames[,2]) | grepl("std\\(\\)", featureNames[,2]) | grepl("meanFreq\\(\\)", featureNames[,2])  
# comment: yeah, I know I could use a single regex but I'm too lazy... 
#          also, "mean" and "std" would work as well (2 regex instead of 3), but I prefer to have an exhaustive list for clarity
cols <- c(TRUE, colsBase, TRUE) # also keep the first column (subjects) and the last column (y values)
dataset_data <- merged[, cols]

{
    ### assertion check:  I'm verifying that what I have now is consistent
    # an error here means there is a programming error, so it shouldn't fail after I've debugged the code  ;-)
    if (sum(cols)==ncol(merged)) stop("merged data set was not filtered")
    # we should have the same number of columns in dataset_data than there are TRUEs in cols
    if (sum(cols)!=ncol(dataset_data)) stop("inconsistent number of columns in dataset_data data set")
}

# step 6: Uses descriptive activity names to name the activities in the data set. 
# ===============================================================================
# we need to replace the values in the dataset_data data set by the corresponding labels in the activitiesLabel data set
# a possible way to do that is to join the 2 data sets by using the last column of "dataset_data" and the first column of "activitiesLabels" as common column.
# unfortunately, merge function requires to name the columns, something I didn't do yet. So I'll do the old way: using a for loop.
for (i in 1:nrow(dataset_data))
    dataset_data[i, ncol(dataset_data)] <- activityLabels[activityLabels[, 1]==dataset_data[i, ncol(dataset_data)], 2]

# step 7: Appropriately labels the data set with descriptive variable names. 
# ==========================================================================
# we need to use the name of the features that we loaded in the featureNames variable and then put them in the "dataset_data" data set. 
# The dataset_data data set doesn't contain all the columns anymore. We have to filter the featureNames as well.
filteredFeatureNames <- featureNames[colsBase, 2]
# add the name of the last column: "activities"
filteredFeatureNames <- c("subjects", filteredFeatureNames, "activities")
{
    ### assertion check:  I'm verifying that what I have now is consistent
    # an error here means there is a programming error, so it shouldn't fail after I've debugged the code  ;-)
    if (length(filteredFeatureNames)!=ncol(dataset_data)) stop("the number of names for the columns is not equal to the number of columns")
}
# assign the column names to the data set
colnames(dataset_data) <- filteredFeatureNames


# step 8: From the data set "dataset_data", creates a second, independent tidy data set with the average of each variable for each activity and each subject.
# ===========================================================================================================================================================
# first make the subject column numeric. This will help order the resulting dataset correctly and contribute to the table readability.
dataset_data[,1] <- as.numeric(dataset_data[,1])
# Activities are stored in last column, called "activities" and the subject are stored in the first column, called "subjects".
dataset_tidy <- ddply(dataset_data, c("subjects", "activities"), function(data){
    # through ddply, this method is called once for each subset. So we have to compute the mean for all columns except subject and activities, here.
    colMeans(data[,2:(ncol(data)-1)])
})

{
    ### assertion check:  I'm verifying that what I have now is consistent
    # an error here means there is a programming error, so it shouldn't fail after I've debugged the code  ;-)
    # we have 30 subjects and all of them have been doing the 6 activities => we have 180 rows in the tidy dataset
    if (nrow(dataset_tidy)!=180) stop("wrong number of rows in tidy dataset")
    # even if we have merged data, we still have the same features, and we still have subject and activities columns: number of columns didn't change
    if (ncol(dataset_tidy)!=ncol(dataset_data)) stop("wrong number of columns in tidy data set")
}

# we have the result of the project: dataset_tidy. Let's save it in a file called "dataset_tidy.txt"
write.table(dataset_tidy, file="dataset_tidy.txt", row.names=FALSE)

### cleanup code: remove all variables that are not the result of this project. In other words, only keep dataset_data and dataset_tidy
remove(X_test, X_train, activityLabels, featureNames, full_test, full_train, merged, subject_test, subject_train, y_test, y_train, dataset_data,
       cols, colsBase, dataFileName, dataUri, filteredFeatureNames, i)
