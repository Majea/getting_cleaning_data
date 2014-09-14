Code book for making the wearable computing data tidy
=====================================================

Introduction
------------
Please refer to README.md for the complete description of the goal of this project. Next are the different steps taken to retrieve the data set and make it tidy.

this project is expected to provide a tidy data set created by the run_analysis.R script. The variable "dataset_tidy" contains the tidy data set as specified by item 5 in README.md.

Please notice that background information about the data used here can be found at the following location: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones. The most relevant information for understanding the data set are also available in the dataset_and_attributes_info.md file in this project.

This document contains information regarding the logic related to the data processing. Implementation details are documented in the run_analysis.R script.

Result variables
----------------
- *dataset_tidy*: this is the final result of the processing. It's a tidy data set compliant with the description provided in README.md.

The variable *dataset_tidy* is saved on disk in the file "*dataset_tidy.txt*". it can be reloaded using the read.table function.

Intermediate variables
----------------------
The following variables are created during the processing, though they are not part of the final result. They are removed from the workspace at the end of the script. Users can just comment the last "remove" instruction at the end of the script to make the variables visible.
- *dataUri*: the URI to use to download the data set
- *dataFileName*: the name of the data set on the local disk after it was downloaded. It's a zip file.
- *X_test*: the features data for the testing set 
- *X_train*: the features data for the training set
- *featureNames*: a 2 column table mapping an index (column 1) with a name (column 2). Column 1 refers to the index of a column in the X_test or X_train variable. Column 2 provides the name of the corresponding column in X_test or X_train.
- *subject_test*: the subjects of the observation for the test set. There are 30 possible subjects. Each subject row matches the row with the same index in the features data set.
- *subject_train*: the subjects of the observation for the training set. 
- *y_test*: the activity that the subject was performing while the observation was taken. There are 6 possible activities. Each y_test row matches the row with the same index in the test features data set.
- *y_train*: the activity that the subject was performing while the observation was taken. There are 6 possible activities. Each y_test row matches the row with the same index in the training features data set.
- *activityLabels*: provides a name for the different activities. y_train and y_test contains integers whose matching activity name can be found in this activityLabels variable. The first column contains the integer used in y_train and y_test while the second column contains the corresponding activity name. 
- *full_test*: the complete testing set. It includes the subjects, the activities and all the features for the test set.
- *full_train*: the complete training set. It includes the subjects, the activities and all the features for the training set.
- *merged*: the complete data set. It includes the subjects, the activities and all the features for both the training and the testing sets.
- *colsBase*: temporary variable
- *cols*: a boolean vector indicating whether we have to keep a specific column in "merged" variable for building the tidy data set. 
- *dataset_data*: the data set with only the columns listed by cols variable. It contains the activities, the subjects and all features related to means and standard deviation. Please see the steps description below for more details.
- *filteredFeatureNames*: the names of the columns in "dataset_data".
- *i*: a temporary variable used a counter in "for" loop.


Processing steps
----------------

1. download the original data set from: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip*
2. unzip the data set. The data set is unzipped in the "UCI HAR Dataset". in that folder, there is a README.txt and a feature_info.txt file describing the full data set in details.
3. load the data set in memory. We don't have to include the inertial signals, so we have to load the 6 following files: X_train.txt, y_train.txt, subject_train.txt, X_test.txt, y_test.txt and subject_test.txt. The data sets are loaded in the following variables: X_train, y_train, subject_train, X_test, y_test and subject_test. We'll also need the names of the different features  and activities later, so we also load "features.txt" in the variable "featureNames" and "activity_labels.txt" in the variable "activityLabels".
4. merge the training and test sets. The 6 variables X_train, y_train, subject_train, X_test, y_test and subject_test from step 3 are merged into a single data set, stored in the variable "merged". y and subject are considered as 2 additional columns while the test and training set rows all contain different samples (= new rows). "subject" is added as first column while "y" is added as last column.
5. extract only the measurements on the mean and standard deviation for each measurement. In other words, we are here filtering the data set so that we only keep the features which are either means or standard deviations. We can see in feature_info.txt that those feature contain "mean()", "meanFreq()"" and "std()" in their names. So only those will be kept. In https://class.coursera.org/getdata-007/forum/thread?thread_id=49, there is a discussion whether we should only consider those features whose names end with these strings or all those whose names include that string. I consider that we should here include all means and standard deviations, regardless of the position of the "mean()" or "std()" strings. I also consider that the "meanFreq" string is a mean, since it's giving a mean frequency as per its description in "features_info.txt". However, I don't consider the angles variables such as angle(Z,gravityMean) as means since their main prupose is to give angles. So, to summarize, I keep in the data set the columns whose names contain either "mean()", "meanFreq()" or "std()". I also keep the last column, which correspond to the initial y files, since they will be needed for the next step. The resulting dataset is kept in the "dataset_data" variable.
6. Uses descriptive activity names to name the activities in the data set. Here we replace the different numbers in the last column of the data set by the activity labels. The mapping between the numbers in the last column of "merged" and the labels is described in the "activity_labels.txt" file.
7. Appropriately labels the data set with descriptive variable names. The different columns of the data set are named according to the content of the featureNames variable. That variable contains the index of the "merged" column in the first column and the name of the "merged" column in the second column. It's important to remember that the data set columns were filtered at step 5, and so the "featureNames" variable has to be filtered as well. The last column of the merged data set contains the activities and so, it is named "activities". 
8. From the data set "dataset_data" created in previous step, creates a second, independent tidy data set with the average of each variable for each activity and each subject.# tidy data is: (1) each variable forms a column, (2) each observation forms a row, (3) each table/file stores data about one kind of observation. So, we need to have each row = 1 activity and 1 subject and the other variables in column. In other words, activity and subject define the primary key of the table and each pair (subject, activity) identifies an observation. The result is stored in the "dataset_tidy" variable and it contains 1 line for each different pair of subject and activity. subjects and activities are the first 2 columns of the table. The other columns contains the means of the different features for that particular pair (subject, activity).



