div1000 <- function(x) { x / 1000 }
div1024 <- function(x) { x / 1024 }

read_bw_log <- function(file_name) {
  if (file.exists(file_name)) {
    # Read from log file
    df <- read.table(file_name, col.names=c("time", "rate", "dir", "block_size"), sep=",")
    
    if (nrow(df) == 0) {
      simpleError(cat("file is empty:", file_name))
    }
    
    # Improve formatting
    df <- data.frame(time = sapply(df$time, div1000), rate = sapply(df$rate, div1024), dir = factor(df$dir, levels=c(0,1), labels=c("read", "write")), block_size = factor(df$block_size))
  
    return(df)
  }
  else {
    simpleError(cat("file does not exist:", file_name))
  }
}

read_lat_log <- function(file_name) {
  if (file.exists(file_name)) {
    # Read from log file
    df <- read.table(file_name, col.names=c("time", "latency", "dir", "block_size"), sep=",")
    
    if (nrow(df) == 0) {
      simpleError(cat("file is empty:", file_name))
    }
    
    # Improve formatting
    df <- data.frame(
      time = sapply(df$time, div1000),
      latency = df$latency,
      dir = factor(df$dir, levels=c(0, 1), labels=c("read", "write")),
      block_size = factor(df$block_size))
  
    return(df)
  }
  else {
    simpleError(cat("file does not exist:", file_name))
  }
}

# Treat block_size as a continuous variable, not a factor.
read_lat_log_continuous_bs <- function(file_name) {
  if (file.exists(file_name)) {
    # Read from log file
    df <- read.table(file_name, col.names=c("time", "latency", "dir", "block_size"), sep=",")
    
    if (nrow(df) == 0) {
      simpleError(cat("file is empty:", file_name))
    }
    
    # Improve formatting
    df <- data.frame(
      time = sapply(df$time, div1000),
      latency = df$latency,
      dir = factor(df$dir, levels=c(0, 1), labels=c("read", "write")),
      block_size = df$block_size)
  
    return(df)
  }
  else {
    simpleError(cat("file does not exist:", file_name))
  }
}

read_summary_log <- function(file_name) {
  if (file.exists(file_name)) {
    # Read from log file
    df <- read.table(file_name, col.names=c("time", "block_size", "dir", "rate", "iops", "lat_mean", "lat_sd"), sep=",")
  
    if (nrow(df) == 0) {
      simpleError(cat("file is empty:", file_name))
    }
  
    # Improve formatting
    df <- data.frame(
      time = sapply(df$time, div1000),
      block_size = factor(df$block_size),
      rate = sapply(df$rate, div1024),
      dir = factor(df$dir, levels=c(0, 1), labels=c("read", "write")),
      iops = df$iops,
      lat_mean = df$lat_mean,
      lat_sd = df$lat_sd)

    return(df)
  }
  else {
    simpleError(cat("file does not exist:", file_name))
  }
}