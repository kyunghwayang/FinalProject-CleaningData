# FinalProject-CleaningData

Codes:
subid: subject id, 1:30 
activity: 6 types, "WALKING, LKING_UPSTAIRS, WALKING_DOWNSTAIRS, STTING, STANDING, LAYING; obtained from activity_labels file (source file)
other variables are from feature file(source file)

Analyis
1. Merging the datasets into one:
There are two sets of measured data in the original source files: testing and training, associated with each subject id and activity measured. 
First, test_data_frame and train_data_frame were created.
Second, as there was no specific variable name, variable names are assigned. "subid" and "activity".
Third, a new column was added to each data set, named category, which contains whether it is testing data or training data.
Finally, the data sets were merged into one. 

2. Subsetting the merged data set 
First, the column names of the merged data set were changed to descriptive ones, using feature document (source files)
Second, select columns using string matches (mean and std).
Third, create a subset of the merged data set.

3. Changing the values of the "activity" column.
Each value was changed to a character string. The "activity labels" file was used as a reference. 

4. Changing the column names of the subset to remove special characters.
The column names include () and -, which caused problems. () was removed and - was changed to _. 

5. Reshaping the subset. 
First, the subset was melted using id="subid" and "activity". 
Second, the melted table was arranged by subid and activity, including all the measured data as variable.
Third, the melted table was dcasted by subid and activity and the mean of each variable was calculated.

6. Write the data table to a file.
