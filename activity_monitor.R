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

activity_monitor <- function()
{

# Load the Libraries
library(ggplot2)
library(gridExtra)
library(lattice)
library(plyr)
library(scales)  

options("scipen"=100, "digits"=2)

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


# Read the data and format it
data <- read.csv(fname, stringsAsFactors = FALSE)

data_raw <- data[ ,1:2]
data_raw$steps <- as.numeric(as.vector(data_raw$steps))
data_raw$date <- as.Date(as.vector(data_raw$date))

# Aggregate the data to find total number of steps per day
total_raw <- aggregate(data_raw$steps, by = list(data_raw$date), FUN = sum)
names(total_raw) <- c("Date", "Steps")

# Get the mean and median for the total number of steps per day
mean_raw <- mean(total_raw$Steps, na.rm = TRUE)
median_raw <- median(total_raw$Steps, na.rm = TRUE)

# Plot the histogram and highlight the mean and median
g0 <- ggplot(total_raw, aes(x = Date, y = Steps), legend = TRUE)
gplot0 <- g0 + geom_histogram(stat = "identity", alpha = 1/3, fill = "blue") + 
    ylab("Total #of Steps/Day") + xlab("Date (dd-mm-yyy)") + labs(title = "Steps taken per day (with NAs in data)") + 
    scale_x_date(labels = date_format("%d-%m-%Y")) +
    theme(plot.title = element_text(size = 14, face = "bold", colour = "brown"), axis.text=element_text(size=12, angle = 90)) +
    geom_hline(aes(yintercept = mean(Steps, na.rm = TRUE), color = paste("Mean = ", round(mean(Steps, na.rm = TRUE),2))), data = total_raw, show_guide = TRUE) + 
    geom_hline(aes(yintercept = median(Steps, na.rm = TRUE), color = paste("Median = ", round(median(Steps, na.rm = TRUE),2))), data = total_raw,  show_guide = TRUE) + 
    guides(colour = guide_legend("Summary"))

print(gplot0)


# Find the total number of NAs
invalid <- nrow(data[!is.na(data$steps), ])

# Get the data and process it to remove the NAs. NAs are replaced by mean of total number of steps aggregated for the specific Interval
data_valid <- data[ ,1:2]

for(i in 1:nrow(data_valid))
{
    if(is.na(data_valid[i, 1])) 
    {
        data_valid[i, 1] <- get_mean(data[i, 3], data, "interval") 
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
    ylab("Total #of Steps/Day") + xlab("Date (dd-mm-yyy)") +
    labs(title = "Steps taken per day (removing NAs from Data)") + scale_x_date(labels = date_format("%d-%m-%Y")) +
    theme(plot.title = element_text(size = 14, face = "bold", colour = "brown"), axis.text.x=element_text(size=12, angle = 90)) +
    geom_hline(aes(yintercept = mean(Steps), color = paste("Mean = ", round(mean(Steps),2))), data = total, show_guide = TRUE) + 
    geom_hline(aes(yintercept = median(Steps), color = paste("Median = ", round(median(Steps),2))), data = total,  show_guide = TRUE) + 
    guides(colour = guide_legend("Summary"))

#grid.arrange(gplot0, gplot1, nrow = 2, ncol=1)
print(gplot1)


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
    geom_point(data = max_cord, aes(x = Interval, y = Steps, colour = paste("Max Value: Interval = ", round(Interval,2), ", #Steps = " ,round(Steps,2))), size = 4, show_guide = TRUE) + 
    geom_hline(aes(yintercept = mean(Steps), color = paste("Mean = ", round(mean(Steps),2))), data = average, show_guide = TRUE) + 
    ylab("Avg. #of Steps/Intv.") + labs(title = "Average daily activity pattern") +
    theme(plot.title = element_text(size = 14, face = "bold", colour = "brown")) +
    guides(colour = guide_legend("Summary"))

print(gplot2)


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


#grid.arrange(gplot2, gplot3, nrow = 2, ncol=1)
print(gplot3)


library(cluster)
library(xtable)
library(knitr)

fit <- kmeans(average, 5, nstart = 100)
clusplot(average, fit$cluster, color = TRUE, shade = TRUE, main = "Clustering the Number of steps using PCA")

cent <- fit$centers
names(cent) <- c("Interval", "Average Activity (Mean number of Steps)")
cent <- cent[sort.list(cent[,2],decreasing = TRUE ), ]
kable(cent, digits = 2,align = "c", row.names = FALSE)

}