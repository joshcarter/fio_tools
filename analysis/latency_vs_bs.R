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
    
  return(p)
}