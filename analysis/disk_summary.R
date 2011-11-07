library("ggplot2")

div1000 <- function(x) { x / 1000 }
div1024 <- function(x) { x / 1024 }

#
# Bandwidth
#
read_bw_log <- function(file_name) {
  if (file.exists(file_name)) {
    # Read from log file
    df <- read.table(file_name, col.names=c("time", "rate", "stream", "block_size"), sep=",")
    
    if (nrow(df) == 0) {
      simpleError(cat("file is empty:", file_name))
    }
    
    # Improve formatting
    df <- data.frame(time = sapply(df$time, div1000), rate = sapply(df$rate, div1024), block_size = factor(df$block_size))
  
    return(df)
  }
  else {
    simpleError(cat("file does not exist:", file_name))
  }
}

read_combined_bw <- function(write, read) {
  read <- data.frame(read_bw_log(read), op = "read")
  write <- data.frame(read_bw_log(write), op = "write")

  return(rbind(read, write))
}

bw_base <- function(bw) {
  # Scale y-max to median + 3 standard deviations
  y_max = median(bw$rate) + (sd(bw$rate) * 2)
  # Round up to nearest 10
  y_max = ceiling(y_max / 10) * 10
  
  p <- ggplot(bw) +
    aes(time, rate) +
    ylim(0,y_max) +
    xlab("Time (s)") +
    ylab("Bandwidth (MB/s)")

  return(p)
}

bw_boxplots <- function(bw) {
  p <- bw_base(bw) +
    geom_boxplot(aes(color = block_size)) +
    coord_flip() +
    facet_grid(op ~ .)

  return(p)
}

read_random <- function() {
  return(read_combined_bw(write = "random-write_bw.log", read = "random-read_bw.log"));
}

read_sequential <- function() {
  return(read_combined_bw(write = "sequential-write_bw.log", read = "sequential-read_bw.log"));
}

bw_scatterplot <- function(bw, ylim_low, ylim_high) {
  p <- ggplot(bw) + aes(time, rate) + ylim(ylim_low, ylim_high) + xlab("Time (s)") + ylab("Bandwidth (MB/s)")
  p + geom_point(aes(color = block_size))

}

#
# Latency
#
read_lat_log <- function(file_name) {
  if (file.exists(file_name)) {
    # Read from log file
    df <- read.table(file_name, col.names=c("time", "latency", "stream", "block_size"), sep=",")
    
    if (nrow(df) == 0) {
      simpleError(cat("file is empty:", file_name))
    }
    
    # Improve formatting
    df <- data.frame(time = sapply(df$time, div1000), latency = df$latency, block_size = factor(df$block_size))
  
    return(df)
  }
  else {
    simpleError(cat("file does not exist:", file_name))
  }
}bw

read_latency_log <- function(file_name) {
  if (file.exists(file_name)) {
    return(read.table(file_name, col.names=c("time", "latency", "stream", "block_size"), sep=","))
  }

  return(NULL);
}

