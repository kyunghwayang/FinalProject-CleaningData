library(dplyr)
library(data.table)

# read files
testSubjects <- read.table("./data/test/subject_test.txt")
testSet <- read.table("./data/test/X_test.txt")
testLabels <- read.table("./data/test/y_test.txt")

trainSubjects <- read.table("./data/train/subject_train.txt")
trainSet <- read.table("./data/train/X_train.txt")
trainLabels <- read.table("./data/train/y_train.txt")

measureChart <- read.table("./data/features.txt")
measureChartList <- measureChart$V2 # convert to a list.

# testing any duplicate in the list.
# indeed there are some duplicates in the feature.
# This, however, is ignored in the following computation.
# length(measureChartList)
# uniqueList <- unique(measureChartList)
# length(uniqueList)


# rename columns before merging
testSubjects <- rename(testSubjects, subid= V1)
trainSubjects <- rename(trainSubjects, subid = V1)
testLabels <- rename(testLabels, activity=V1)
trainLabels <- rename(trainLabels, activity=V1)

# create test and train tables, separately and add a category column.
test <- cbind(testSet, testLabels, testSubjects)
test$category <-"test"
train <- cbind(trainSet, trainLabels, trainSubjects)
train$category <-"train"

# Merge the two tables using rbind.
data <- rbind(test, train)

## column organization: 
## set(561 variables),activity(6 types), subid(1:30), and category(test/train)


# create a function to rename all the columns
# old: table with old column names
# new_names
# renameColumns <- function(old, new_names, num=561){
#   old_names <- names(old)
#   for(i in 1:num){
#     new <- new_names[i]
#     old <- rename(old, new=old_names[i])
#   }
#   return(old)
# }

## Because there are some dupilcates in the variale names, use a different func.
renameColumns2 <- function(old, new_names, num=561){
  for(i in 1:num){
    names(old)[i] = new_names[i]
  }  
  return(old)
}

data<-renameColumns2(data, measureChartList)


# select column numbers of data, if colum names include 
# any of the string vector
selectColumns <- function (data, str){
  col <- integer()
  names <- names(data)
  k<-1
  
  for(i in 1: length(names)){
    for(j in 1: length(str)){
      if(grepl(str[j], names[i])) {
        col[k] <-i
        k<-k+1
        }
    }
  }
  return(col)
}

selected_col <- selectColumns(data, c("[M|m][E|e][A|a}[N|n]", "[S|s][T|t]?[D|d]"))
numOfMeasures <-length(selected_col)

# subset: columnns that include mean and sd.
# include activity, subjectID, and category.
last<-length(names(data))
mean_sd_data <- data[, c(selected_col, last-2, last-1, last)]


# change the activity values to descriptive one. 
changeColumnValues <- function(data, col_name, descriptiveValues, n=6){
  for(i in 1:nrow(data)){
    for(j in 1:length(descriptiveValues)){
      if(data[i, col_name]==j) { data[i, col_name] = descriptiveValues[j] }
    }
  }
  return(data)
}

activities <- c("WALKING",
                "WALKING_UPSTAIRS", 
                "WALKING_DOWNSTAIRS",
                "SITTING",
                "STANDING",
                "LAYING")

mean_sd_data <-changeColumnValues(mean_sd_data, "activity", activities)

# Replace column names: replace () with "" and "-" with "_"

replaceNames <- function(data, old_str, new_str){

  if(old_str=="()") old_str="\\(\\)"
  
  for(i in 1: length(names(data))){
    names(data)[i]<-gsub(old_str, new_str, names(data)[i])
  }
  return(data)
}

mean_sd_data <- replaceNames(mean_sd_data, "()","")
mean_sd_data <- replaceNames(mean_sd_data, "-", "_")


# Last step: Reshaping the table.
# From the data set in step 4, 
# creates a second, independent tidy data set
# with the average of each variable 
# for each activity and each subject


melt <- melt(as.data.table(mean_sd_data), 
             id=c("subid", "activity"), 
             measure.var=c(1:numOfMeasures))
melt <-arrange(melt, subid, activity)
meltMean <-dcast(melt, subid+activity~variable, mean)
meltMean 

# write the table
write.table(meltMean, file = "mean_sd_summary.txt", sep = "\t",
            row.names = FALSE)