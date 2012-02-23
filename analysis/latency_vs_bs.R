library("ggplot2")
source("fio_log_parsers.R")

# We need for our model, for each block size and direction:
# - Minimum latency
# - Mean latency
# - Standard deviation
#
# This function generates a new data frame that summarizes just those
# aspects, given a latency log.
summarize_lat <- function(df) {
  collapsed_df <- NULL

  for (d in levels(df[,"dir"])) {
    for (b in levels(df[,"block_size"])) {
      subset <- df[df[,"block_size"] == b & df[,"dir"] == d,]
    
      summary <- data.frame(
        block_size = b,
        dir = d,
        lat_min = min(subset$latency),
        lat_mean = mean(subset$latency),
        lat_sd = sd(subset$latency))

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
# Basic plot, using only summary data from summarize_lat().
#
plot_summary <- function(summary_df) {
  p <- ggplot(summary_df) +
    aes(block_size, lat_mean) +
    xlab("Block Size (b)") +
    ylab("Log10 Latency (usec)") +
    scale_x_discrete(
      breaks = c(512, 2048, 16384, 65536, 262144, 1048576),
      labels = c("512", "2K", "16K", "64K", "256K", "1M")) +
    scale_y_log10(
      breaks = c(10, 100, 1000, 10000, 100000),
      labels = c("10us", "100us", "1ms", "10ms", "100ms")) +
    facet_grid(. ~ dir) +
    geom_point()
    # geom_errorbar(aes(ymin = lat_mean - lat_sd, ymax = lat_mean + lat_sd))
    
  return(p)
}

#
# Plot using entire latency data frame.
#
complete_boxplot <- function(df) {
  p <- ggplot(df) +
    aes(block_size, latency) +
    xlab("Block Size (b)") +
    ylab("Log10 Latency (usec)") +
    scale_x_discrete(
      breaks = c(512, 2048, 16384, 65536, 262144, 1048576),
      labels = c("512", "2K", "16K", "64K", "256K", "1M")) +
    scale_y_log10(
      breaks = c(10, 100, 1000, 10000, 100000),
      labels = c("10us", "100us", "1ms", "10ms", "100ms")) +
    facet_grid(. ~ dir) +
    stat_boxplot(outlier.colour = "grey20", outlier.size = 1)
    
  return(p)
}

#
# Histogram with panels for dir/block size, showing latency distribution.
#
complete_hist <- function(df) {
  p <- ggplot(df) +
    aes(latency, ..ndensity..) +
    xlab("Log10 Latency (usec)") +
    ylab("Density") +
    scale_x_log10(
      breaks = c(10, 100, 1000, 10000, 100000),
      labels = c("10us", "100us", "1ms", "10ms", "100ms")) +
    scale_y_continuous(
      breaks = c(1),
      labels = c("1")) +
    facet_grid(block_size ~ dir) +
    geom_histogram(binwidth = 0.05)
    
  return(p)
}

#
# Detail histogram for given direction and block size.
#
detail_hist <- function(df, block_size, dir) {
  subset <- df[df[,"block_size"] == block_size & df[,"dir"] == dir,]

  p <- ggplot(subset) +
    aes(latency, ..ndensity..) +
    xlab("Log10 Latency (usec)") +
    ylab("Density") +
    scale_x_log10(
      breaks = c(10, 100, 1000, 10000, 100000),
      labels = c("10us", "100us", "1ms", "10ms", "100ms")) +
    scale_y_continuous(
      breaks = c(1),
      labels = c("1")) +
    geom_histogram(binwidth = 0.1)
    
  return(p)
}

drop_below_min <- function(x, min) { if (x < min) NA else x }

model_samples <- function(mean, sd, min, nsamples) {
  samples <- rnorm(mean, sd, nsamples)

  # FIXME: drops samples below minimum, will cause returned samples
  # to be less than nsamples.
  samples <- na.omit(sapply(samples, drop_below_min, min))
  
  return(data.frame(latency = samples))
}

#
# Compare actual data vs. samples from model
#
# Sample use:
#
# df <- read_lat_log("latency_vs_block_size_clat.log")
# write_4k_real = df[df[,"block_size"] == 4096 & df[,"dir"] == "write",]
# > min(write_4k_real$latency)
# [1] 170
# write_4k_model <- model_samples(1000, 1000, 170, 1000)
# comparison_hist(write_4k_real, write_4k_model)
#
comparison_hist <- function(df1, df2) {
  p <- ggplot(df1) +
    aes(latency, ..density..) +
    xlab("Log10 Latency (usec)") +
    ylab("Density") +
    scale_x_log10(
      breaks = c(10, 100, 1000, 10000, 100000),
      labels = c("10us", "100us", "1ms", "10ms", "100ms")) +
    scale_y_continuous(
      breaks = c(1, 10),
      labels = c("1", "10")) +
    geom_histogram(binwidth = 0.1, fill = "blue", alpha = I(1/2)) +
    geom_histogram(binwidth = 0.1, fill = "red", alpha = I(1/2), data = df2)
    
  return(p)
}
