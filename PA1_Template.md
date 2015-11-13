---
title: "Activity_Monitoring"
author: "Nithya"
date: "November 4, 2015"
output: html_document
---

Purpose of this document is to explain in detail the alogorithm used to plot the exploratory graphs that analyze the outputs of an Activity Monitor. This device collects data at 5 minute intervals through out the day. The data consists of two months of data from an anonymous individual collected during the months of October and November, 2012 and include the number of steps taken in 5 minute intervals each day.

Data Format :
The variables included in this dataset are:
 - steps: Number of steps taking in a 5-minute interval (missing values are coded as NA)
 - date: The date on which the measurement was taken in YYYY-MM-DD format
 - interval: Identifier for the 5-minute interval in which measurement was taken
 
Technical Details :
Below we will go through the code snippets that together constitute the exploratory analysis alogorithm here. The same is avaibale in activity_monitor.R code in the github repo - *"https://github.com/nithsubr/RepData_PeerAssessment1"*"

Before we start, let us define a funtion that calculates the mean and is used inside our main algorithm :

```r
get_mean <- function(x, data_func, measure)
{

# Get the data filtered by interval / date

if (measure == "interval")
{
  data_filt <- subset(data_func, interval == x )  
}else
{
  data_filt <- subset(data_func, date == x )
}

# Remove the NAs
dataset <- data_filt[!is.na(data_filt$steps), 1]

# Calculate the mean
if(!is.na(mean(dataset, na.rm = TRUE)))
   {
      mean_set <- mean(dataset, na.rm = TRUE)
   }else{
      mean_set <- 0
   }

# Return the Mean
return(mean_set)

}
```

Below is the code that generates the exploratory graphics:

1. Loading and preprocessing the data


```r
  # Load the Libraries
  library(ggplot2)
  library(gridExtra)
  library(lattice)
  library(plyr)
  
  # URL for Activity Monitor Data
  url <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip"
  
  # Download the zip file
  if (!dir.exists("./activity_monitor")) {dir.create("./activity_monitor")}
  download.file(url, "./activity_monitor/activity_data.zip")
  
  # Get the file name (activity.csv) and unzip the .zip file
  fname <- unzip("./activity_monitor/activity_data.zip", list = TRUE)$Name
  unzip("./activity_monitor/activity_data.zip", files = fname, exdir = "./activity_monitor", overwrite = TRUE)
  
  # Get the location for reading the file for futher processing
  fname <- paste("./activity_monitor", fname, sep = "/")
```

As you can see, here 
 - We load a few libraries that would be required.
 - We read the .zip file for the URL
 - We unzip the .zip file and extract the activity dataset (.csv)


2. Plot#1 - **"total number of steps taken per day (keeping the NA values)"**


```r
  # Read the data and format it
  data <- read.csv(fname, stringsAsFactors = FALSE)
  
  data_raw <- data[ ,1:2]
  data_raw$steps <- as.numeric(as.vector(data_raw$steps))
  data_raw$date <- as.Date(as.vector(data_raw$date))
  
  # Aggregate the data to find total number of steps per day
  total_raw <- aggregate(data_raw$steps, by = list(data_raw$date), FUN = sum)
  names(total_raw) <- c("Date", "Steps")
  
  # Get the mean and median for the total number of steps per day
  mean_raw <- mean(total_raw$Steps)
  median_raw <- median(total_raw$Steps)
  
  # Plot the histogram and highlight the mean and median
  g0 <- ggplot(total_raw, aes(x = Date, y = Steps), legend = TRUE)
  gplot0 <- g0 + geom_histogram(stat = "identity", alpha = 1/3, fill = "blue") + 
    ylab("Total #of Steps/Day") + labs(title = "Steps taken per day (with NAs in data)") +
    theme(plot.title = element_text(size = 14, face = "bold", colour = "brown")) +
    geom_hline(aes(yintercept = mean(Steps, na.rm = TRUE), color = paste("Mean = ", round(mean(Steps, na.rm = TRUE),2))), data = total_raw, show_guide = TRUE) + 
    geom_hline(aes(yintercept = median(Steps, na.rm = TRUE), color = paste("Median = ", round(median(Steps, na.rm = TRUE),2))), data = total_raw,  show_guide = TRUE) + 
    guides(colour = guide_legend("Summary"))
```

Here we - 
 - Read the raw data into R
 - Process the Data to get into the tidy format
 - Calculate the aggeragets - "Sum" of all the steps on a daily basis
 - Calculate the Mean and Median figures to me plotted on the graph as horizontal lines.
 - Plot the Graphs


3. Plot#2 - **"total number of steps taken per day (removing the NA values)"**


```r
  # Find the total number of NAs
  invalid <- nrow(data[!is.na(data$steps), ])
  
  # Get the data and process it to remove the NAs. NAs are replaced by mean of total number of steps aggregated for the specific date
  data_valid <- data[ ,1:2]

  for(i in 1:nrow(data_valid))
      {
        if(is.na(data_valid[i, 1])) 
          {
            data_valid[i, 1] <- get_mean(data[i, 2], data, "date")
          }
      }
  
  data_valid$steps <- as.numeric(as.vector(data_valid$steps))
  data_valid$date <- as.Date(as.vector(data_valid$date))
  
  # Aggregate the data by calculating the total number of steps per date
  total <- aggregate(data_valid$steps, by = list(data_valid$date), FUN = sum)
  names(total) <- c("Date", "Steps")
  
  # Calculate the mean and median of total number of steps per date
  mean_total <- mean(total$Steps)
  median_total <- median(total$Steps)
  
  # Plot the histogram and highlight the mean and median
  g1 <- ggplot(total, aes(x = Date, y = Steps), legend = TRUE)
  gplot1 <- g1 + geom_histogram(stat = "identity", alpha = 1/3, fill = "blue") + 
                 ylab("Total #of Steps/Day") + 
                 labs(title = "Steps taken per day (removing NAs from Data)") +
                 theme(plot.title = element_text(size = 14, face = "bold", colour = "brown")) +
                 geom_hline(aes(yintercept = mean(Steps), color = paste("Mean = ", round(mean(Steps),2))), data = total, show_guide = TRUE) + 
                 geom_hline(aes(yintercept = median(Steps), color = paste("Median = ", round(median(Steps),2))), data = total,  show_guide = TRUE) + 
                 guides(colour = guide_legend("Summary"))
  
  grid.arrange(gplot0, gplot1, nrow = 2, ncol=1)
```

```
## Warning: Removed 8 rows containing missing values (position_stack).
```

![plot of chunk Plot 2 - steps taken per day (removing the NA values)](figure/Plot 2 - steps taken per day (removing the NA values)-1.png) 

Here we are - 
 - Getting the data in required format
 - Get the mean # steps for each interval
 - Get the total number of NAs to be printed at the end
 - Calculate the Mean and Median figures to me plotted on the graph as horizontal lines.
 - Plot the graph


4. Plot#3 - **"average daily activity pattern"**

```r
  # Get the data and process it to remove the NAs. NAs are replaced by mean of total number of steps aggregated for the specific interval
  data_int <- data[ , -2]
  
  for(i in 1:nrow(data_int))
  {
    if(is.na(data_int[i, 1])) 
    {
      data_int[i, 1] <- get_mean(data[i, 3], data, "interval")
    }
  }
  
  data_int$steps <- as.numeric(as.vector(data_int$steps))
  data_int$interval <- as.numeric(as.vector(data_int$interval))
  
  # Aggregate the data by finding the mean on total number of steps per interval
  average <- aggregate(data_int$steps, by = list(data_int$interval), FUN = mean)
  names(average) <- c("Interval", "Steps")
  
  # Get the max value of mean of total number of steps and also get the specific interval
  max_cord <- average[order(-average$Steps), ]
  max_cord <- max_cord[1, ]
  
  # Plot the line graph and highlight the maximum
  g2 <- ggplot(average, aes(x = Interval, y = Steps), legend = TRUE)
  gplot2 <- g2 + geom_line() + 
                 geom_point(data = max_cord, aes(x = Interval, y = Steps, colour = paste("Interval = ",                                  round(Interval,2), ", #Steps = " ,round(Steps,2))), size = 4, show_guide = TRUE) + 
                 ylab("Avg. #of Steps/Intv.") + labs(title = "Average daily activity pattern") +
                 theme(plot.title = element_text(size = 14, face = "bold", colour = "brown")) +
                 guides(colour = guide_legend("Max. Average"))
```

Here we are - 
 - Getting the data in required format
 - Get the mean # steps for each interval
 - Calculate the Max number of Steps and the interval to be highlighted on the plot
 - Plot the graph


5. Plot#4 - **"differences in activity patterns between weekdays and weekends"** 

```r
  # Get the data and process it to remove the NAs. NAs are replaced by mean of total number of steps aggregated for the specific interval
  data_wkd <- data
  
  for(i in 1:nrow(data_wkd))
  {
    if(is.na(data_wkd[i, 1])) 
    {
      data_wkd[i, 1] <- get_mean(data[i, 3], data, "interval")
    }
  }
  
  data_wkd$steps <- as.numeric(as.vector(data_wkd$steps))
  data_wkd$interval <- as.numeric(as.vector(data_wkd$interval))
  data_wkd$date <- as.Date(as.vector(data_wkd$date)) 
  
  # Divide the data into 2 groups based on whether the date is a Weekday / Weekend
  data_wkd <- mutate(data_wkd, wkd = ifelse(weekdays(data_wkd$date) %in% c("Sunday", "Saturday"), "WEEKENDS", "WEEKDAYS"))

  # Get the Aggregated values by calculating the mean of number of steps per interval
  average_wkd <- aggregate(data_wkd$steps, by = list(data_wkd$wkd, data_wkd$interval), FUN = mean)
  names(average_wkd) <- c("Wkd", "Interval", "Steps")
  
  # Get the Averages - for weekends and weekdays separately
  mean_weekends <- mean(data_wkd[data_wkd$wkd == "WEEKENDS", "steps"], na.rm = TRUE)
  mean_weekdays <- mean(data_wkd[data_wkd$wkd == "WEEKDAYS", "steps"], na.rm = TRUE)
  df <- data.frame(Wkd = c("WEEKDAYS", "WEEKENDS"), mean = c(mean_weekdays, mean_weekends))
  
  # Plot the line graph with 2 facets - Weekend and Weekday and also highlight the respective means
  g3 <- ggplot(average_wkd, aes(x = Interval, y = Steps), legend = TRUE)
  gplot3 <- g3 + geom_line() + 
                 facet_wrap(~Wkd, ncol = 1) +
                 ylab("Avg. #of Steps/Intv.") + labs(title = "Activity patterns weekdays Vs weekends") +
                 theme(plot.title = element_text(size = 14, face = "bold", colour = "brown")) +
                 geom_hline(data = df, aes(yintercept = mean, color = paste(Wkd, " = ", round(mean,2))), show_guide = TRUE) + 
                 guides(colour = guide_legend("Mean"))
                 
  
  grid.arrange(gplot2, gplot3, nrow = 2, ncol=1)
```

![plot of chunk Plot 4 - activity patterns between weekdays and weekends](figure/Plot 4 - activity patterns between weekdays and weekends-1.png) 

```r
  # Print out the number of NAs removed on the console
  print(paste("Total Number of NAs replaced with appropriate values = ", invalid, sep = ""))
```

```
## [1] "Total Number of NAs replaced with appropriate values = 15264"
```

Here we are - 
 - Getting the data in required format
 - Split the data into measurements collected on Weekdays and Weekends
 - Calculate the Mean number of Steps for both Weekdays and Weekends to be plotted
 - Plot the graph
 - Print out the messgae with the total number of NAs in the data
 
