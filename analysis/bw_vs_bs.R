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

