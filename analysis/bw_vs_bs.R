library("ggplot2")
source("fio_log_parsers.R")

summarize_bw <- function(df) {
  collapsed_df <- NULL

  for (d in levels(df[,"dir"])) {
    for (b in levels(df[,"block_size"])) {
      subset <- df[df[,"block_size"] == b & df[,"dir"] == d,]
    
      summary <- data.frame(
        block_size = b,
        dir = d,
        rate_min = min(subset$rate),
        rate_mean = mean(subset$rate),
        rate_sd = sd(subset$rate))

      if (is.null(collapsed_df)) {
        collapsed_df <- summary      
      } else {
        collapsed_df <- rbind(collapsed_df, summary)
      }
    }
  }

  return(collapsed_df)
}

#
# Basic plot, using only summary data from summarize_bw().
#
bw_summary_bars <- function(summary_df) {
  p <- ggplot(summary_df) +
    aes(block_size, rate_mean) +
    xlab("Block Size (b)") +
    ylab("Bandwidth (MB/s)") +
    scale_x_discrete(
      breaks = c(512, 2048, 16384, 65536, 262144, 1048576),
      labels = c("512", "2K", "16K", "64K", "256K", "1M")) +
    scale_y_continuous() +
    facet_grid(. ~ dir) +
    geom_bar(alpha = I(1/2)) +
    geom_errorbar(aes(ymin = rate_mean - rate_sd, ymax = rate_mean + rate_sd))
    
  return(p)
}

#
# Plot using entire bandwidth data frame.
#
bw_boxplot <- function(df) {
  p <- ggplot(df) +
    aes(block_size, rate) +
    xlab("Block Size (b)") +
    ylab("Bandwidth (MB/s)") +
    scale_x_discrete(
      breaks = c(512, 2048, 16384, 65536, 262144, 1048576),
      labels = c("512", "2K", "16K", "64K", "256K", "1M")) +
    scale_y_continuous() +
    facet_grid(. ~ dir) +
    stat_boxplot(outlier.colour = "grey20", outlier.size = 1)
    
  return(p)
}

#
# Display bandwidth view over time, broken down by op and block size.
#
bw_vs_time <- function(df) {
  p <- ggplot(df) +
    aes(time, rate) +
    xlab("Time (s)") +
    ylab("Bandwidth (MB/s)") +
    facet_grid(. ~ dir) +
    geom_smooth(aes(color = block_size))
  
  return(p)
}

bw_vs_time3 <- function(df, mark_x_min, mark_x_max) {
  ymax = max(df$rate)
  
  p <- ggplot(df) +
    aes(time, rate) +
    xlab("Time (s)") +
    ylab("Bandwidth (MB/s)") +
    ylim(0, ymax) +
    scale_y_continuous(
      breaks = c(100, 1000),
      labels = c("100MB/s", "1GB/s")) +
    facet_grid(block_size ~ dir) +
    geom_rect(
      aes(
        xmin=30,
        xmax=50,
        ymin=0,
        ymax=120),
      fill="cadetblue3") +
    geom_point()
  
  return(p)
}

#
# Bandwidth vs. time for single op/block size (e.g. drive conditioning run).
#
simple_bw_vs_time <- function(df) {
  p <- ggplot(df) +
    aes(time, rate) +
    xlab("Time (s)") +
    ylab("Bandwidth (MB/s)") +
    geom_smooth()

  return(p)
}

#
# Compare two bandwidth summary frames.
#
# TODO: better labeling of color <-> product
# TODO: greyscale color scheme
#
bw_summary_comparison <- function(summary1, summary2) {
  y_max <- max(
    max(summary1$rate_mean + summary1$rate_sd),
    max(summary2$rate_mean + summary2$rate_sd))

  p <- ggplot(summary1) +
    aes(block_size, rate_mean) +
    xlab("Block Size (b)") +
    ylab("Bandwidth (MB/s)") +
    scale_x_discrete(
      breaks = c(512, 2048, 16384, 65536, 262144, 1048576),
      labels = c("512", "2K", "16K", "64K", "256K", "1M")) +
    scale_y_continuous(limits = c(0, y_max)) +
    facet_grid(. ~ dir) +
    geom_bar(fill = "blue", alpha = I(1/2)) +
    geom_errorbar(aes(ymin = rate_mean - rate_sd, ymax = rate_mean + rate_sd), color = "blue") +
    geom_bar(fill = "red", alpha = I(1/2), data = summary2) +
    geom_errorbar(aes(ymin = rate_mean - rate_sd, ymax = rate_mean + rate_sd), color = "red", data = summary2)
    
  return(p)
}