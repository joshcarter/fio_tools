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

complete_hist <- function(df) {
  p <- ggplot(df) +
    aes(latency, ..density..) +
    xlab("Log10 Latency (usec)") +
    ylab("Density") +
    scale_x_log10(
      breaks = c(10, 100, 1000, 10000, 100000),
      labels = c("10us", "100us", "1ms", "10ms", "100ms")) +
    scale_y_continuous(
      breaks = c(1, 10),
      labels = c("1", "10")) +
    facet_grid(block_size ~ dir) +
    geom_histogram(binwidth = 0.2)
    
  return(p)
}