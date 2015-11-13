activity_monitor <- function()
{
  
  library(ggplot2)
  library(gridExtra)
  library(lattice)
  library(plyr)


  url <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip"
  
  # Download the zip file
  if (!dir.exists("./activity_monitor")) {dir.create("./activity_monitor")}
  download.file(url, "./activity_monitor/activity_data.zip")
  
  fname <- unzip("./activity_monitor/activity_data.zip", list = TRUE)$Name
  unzip("./activity_monitor/activity_data.zip", files = fname, exdir = "./activity_monitor", overwrite = TRUE)
  
  fname <- paste("./activity_monitor", fname, sep = "/")
  
  #fname <- "./activity_monitor/activity.csv"

  data <- read.csv(fname, stringsAsFactors = FALSE)
  
  # Initiate the plotting device
  png("Activity_Steps_per_Day.png", width = 800, height = 800)
  
  data_raw <- data[ ,1:2]
  data_raw$steps <- as.numeric(as.vector(data_raw$steps))
  data_raw$date <- as.Date(as.vector(data_raw$date))
  
  total_raw <- aggregate(data_raw$steps, by = list(data_raw$date), FUN = sum)
  names(total_raw) <- c("Date", "Steps")
  
  mean_raw <- mean(total_raw$Steps)
  median_raw <- median(total_raw$Steps)
  
  g0 <- ggplot(total_raw, aes(x = Date, y = Steps), legend = TRUE)
  gplot0 <- g0 + geom_histogram(stat = "identity", alpha = 1/3, fill = "blue") + 
    ylab("Total #of Steps/Day") + labs(title = "total number of steps taken per day (keeping the NA values)") +
    theme(plot.title = element_text(size = 14, face = "bold", colour = "brown")) +
    geom_hline(aes(yintercept = mean(Steps, na.rm = TRUE), color = paste("Mean = ", round(mean(Steps, na.rm = TRUE),2))), data = total_raw, show_guide = TRUE) + 
    geom_hline(aes(yintercept = median(Steps, na.rm = TRUE), color = paste("Median = ", round(median(Steps, na.rm = TRUE),2))), data = total_raw,  show_guide = TRUE) + 
    guides(colour = guide_legend("Summary"))
  
  
  invalid <- nrow(data[!is.na(data$steps), ])
  
  data_valid <- data[ ,1:2]
  
  for(i in 1:nrow(data_valid))
      {
        if(is.na(data_valid[i, 1])) 
          {
            data_valid[i, 1] <- get_mean_date(data[i, 2], data)
          }
      }
  
  data_valid$steps <- as.numeric(as.vector(data_valid$steps))
  data_valid$date <- as.Date(as.vector(data_valid$date))
  
  total <- aggregate(data_valid$steps, by = list(data_valid$date), FUN = sum)
  names(total) <- c("Date", "Steps")
  
  mean_total <- mean(total$Steps)
  median_total <- median(total$Steps)
  

  g1 <- ggplot(total, aes(x = Date, y = Steps), legend = TRUE)
  gplot1 <- g1 + geom_histogram(stat = "identity", alpha = 1/3, fill = "blue") + 
                 ylab("Total #of Steps/Day") + labs(title = "total number of steps taken per day (removing the NA values)") +
                 theme(plot.title = element_text(size = 14, face = "bold", colour = "brown")) +
                 geom_hline(aes(yintercept = mean(Steps), color = paste("Mean = ", round(mean(Steps),2))), data = total, show_guide = TRUE) + 
                 geom_hline(aes(yintercept = median(Steps), color = paste("Median = ", round(median(Steps),2))), data = total,  show_guide = TRUE) + 
                 guides(colour = guide_legend("Summary"))
  
  grid.arrange(gplot0, gplot1, nrow = 2, ncol=1)

  dev.off()
  
  # Initiate the plotting device
  png("Activity_Steps_per_Interval.png", width = 800, height = 800)
  
  data_int <- data[ , -2]
  
  for(i in 1:nrow(data_int))
  {
    if(is.na(data_int[i, 1])) 
    {
      data_int[i, 1] <- get_mean(data[i, 3], data)
    }
  }
  
  data_int$steps <- as.numeric(as.vector(data_int$steps))
  data_int$interval <- as.numeric(as.vector(data_int$interval))
  
  average <- aggregate(data_int$steps, by = list(data_int$interval), FUN = mean)
  names(average) <- c("Interval", "Steps")
  
  max_cord <- average[order(-average$Steps), ]
  max_cord <- max_cord[1, ]
  
  g2 <- ggplot(average, aes(x = Interval, y = Steps), legend = TRUE)
  gplot2 <- g2 + geom_line() + 
                 geom_point(data = max_cord, aes(x = Interval, y = Steps, colour = paste("Interval = ", round(Interval,2), ", #Steps = " ,round(Steps,2))), size = 4, show_guide = TRUE) + 
                 ylab("Avg. #of Steps/Intv.") + labs(title = "average daily activity pattern") +
                 theme(plot.title = element_text(size = 14, face = "bold", colour = "brown")) +
                 guides(colour = guide_legend("Max. Average"))
  
  
  data_wkd <- data
  
  for(i in 1:nrow(data_wkd))
  {
    if(is.na(data_wkd[i, 1])) 
    {
      data_wkd[i, 1] <- get_mean(data[i, 3], data)
    }
  }
  
  data_wkd$steps <- as.numeric(as.vector(data_wkd$steps))
  data_wkd$interval <- as.numeric(as.vector(data_wkd$interval))
  data_wkd$date <- as.Date(as.vector(data_wkd$date)) 
  data_wkd <- mutate(data_wkd, wkd = ifelse(weekdays(data_wkd$date) %in% c("Sunday", "Saturday"), "WEEKENDS", "WEEKDAYS"))

  average_wkd <- aggregate(data_wkd$steps, by = list(data_wkd$wkd, data_wkd$interval), FUN = mean)
  
  names(average_wkd) <- c("Wkd", "Interval", "Steps")
  mean_weekends <- mean(data_wkd[data_wkd$wkd == "WEEKENDS", "steps"], na.rm = TRUE)
  mean_weekdays <- mean(data_wkd[data_wkd$wkd == "WEEKDAYS", "steps"], na.rm = TRUE)
  df <- data.frame(Wkd = c("WEEKDAYS", "WEEKENDS"), mean = c(mean_weekdays, mean_weekends))
  
  g3 <- ggplot(average_wkd, aes(x = Interval, y = Steps), legend = TRUE)
  gplot3 <- g3 + geom_line() + 
                 facet_wrap(~Wkd, ncol = 1) +
                 ylab("Avg. #of Steps/Intv.") + labs(title = "differences in activity patterns between weekdays and weekends") +
                 theme(plot.title = element_text(size = 14, face = "bold", colour = "brown")) +
                 geom_hline(data = df, aes(yintercept = mean, color = paste(Wkd, " = ", round(mean,2))), show_guide = TRUE) + 
                 guides(colour = guide_legend("Mean"))
                 
  
  grid.arrange(gplot2, gplot3, nrow = 2, ncol=1)
  
  dev.off()
  
  print(paste("Total Number of NAs replaced with appropriate values = ", invalid, sep = ""))
  
}

get_mean <- function(x, data_func)
{
  
data_filt <- subset(data_func, interval == x )
dataset <- data_filt[!is.na(data_filt$steps), 1]

if(!is.na(mean(dataset, na.rm = TRUE)))
   {
      mean_set <- mean(dataset, na.rm = TRUE)
   }else{
      mean_set <- 0
   }

return(mean_set)

}

get_mean_date <- function(x, data_func)
{
  
  data_filt <- subset(data_func, date == x )
  dataset <- data_filt[!is.na(data_filt$steps), 1]
  
  if(!is.na(mean(dataset, na.rm = TRUE)))
  {
    mean_set <- mean(dataset, na.rm = TRUE)
  }else{
    mean_set <- 0
  }
  
  return(mean_set)
  
}
