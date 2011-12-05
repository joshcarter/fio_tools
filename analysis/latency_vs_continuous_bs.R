source("fio_log_parsers.R")

summarize_lat_continuous_bs <- function(df) {
  collapsed_df <- NULL

  for (d in levels(df[,"dir"])) {
    for (b in unique(df[,"block_size"])) {
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

plot_summary_continuous_bs <- function(summary_df) {
  p <- ggplot(summary_df) +
    aes(block_size, lat_mean) +
    xlab("Block Size (b)") +
    ylab("Log10 Latency (usec)") +
    scale_x_continuous(
      breaks = c(512, 131072, 262144, 1048576),
      labels = c("512", "128K", "256K", "1M")) +
    scale_y_log10(
      breaks = c(10, 100, 1000, 10000, 100000),
      labels = c("10us", "100us", "1ms", "10ms", "100ms")) +
    # facet_grid(. ~ dir) +
    geom_point()
    # geom_errorbar(aes(ymin = lat_mean - lat_sd, ymax = lat_mean + lat_sd))
    
  return(p)
}


# Notes, read size analysis:
# 
# > reads <- df_c2[df_c2[,"dir"] == "read",]
# > reads
#    block_size  dir lat_min  lat_mean    lat_sd
# 1      524288 read    4848 5055.2448 370.54119
# 2        4096 read     161  229.6487 161.43902
# 3      262144 read    2482 2646.6355 221.20568
# 4       32768 read     446  549.1733 157.44317
# 5        2048 read     138  210.6575 222.36026
# 6        1024 read     131  186.3303 102.28513
# 7       16384 read     296  372.4132 115.32800
# 8       65536 read     742  860.3734 200.05780
# 9         512 read      76  182.5980  98.11091
# 10    1048576 read    8787 9832.1301 275.60452
# 11     131072 read    1048 1452.7578 208.57754
# mod <- lm(lat_mean ~ block_size, data = reads)
# > summary(mod)
# 
# Call:
# lm(formula = lat_mean ~ block_size, data = reads)
# 
# Residuals:
#     Min      1Q  Median      3Q     Max 
# -39.629 -24.630   5.273  26.017  41.453 
# 
# Coefficients:
#              Estimate Std. Error t value Pr(>|t|)    
# (Intercept) 2.165e+02  1.136e+01   19.07 1.38e-08 ***
# block_size  9.191e-03  3.111e-05  295.43  < 2e-16 ***
# ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1 
# 
# Residual standard error: 32.17 on 9 degrees of freedom
# Multiple R-squared: 0.9999, Adjusted R-squared: 0.9999 
# F-statistic: 8.728e+04 on 1 and 9 DF,  p-value: < 2.2e-16 
# 
# > coef(mod)
#  (Intercept)   block_size 
# 2.165470e+02 9.191488e-03 
# > pred <- predict(mod, reads)
# > reads$pred = pred
# > p + geom_line(aes(block_size, pred), color = "blue")

# Small writes:
# > small_writes <- df_c2[df_c2[,"block_size"] < 262144 & df_c2[,"dir"] == "read",]
# > small_writes
#    block_size  dir lat_min  lat_mean    lat_sd
# 2        4096 read     161  229.6487 161.43902
# 4       32768 read     446  549.1733 157.44317
# 5        2048 read     138  210.6575 222.36026
# 6        1024 read     131  186.3303 102.28513
# 7       16384 read     296  372.4132 115.32800
# 8       65536 read     742  860.3734 200.05780
# 9         512 read      76  182.5980  98.11091
# 11     131072 read    1048 1452.7578 208.57754
# > mod <- lm(lat_mean ~ block_size, data = small_writes)
# > summary(mod)
# 
# Call:
# lm(formula = lat_mean ~ block_size, data = small_writes)
# 
# Residuals:
#     Min      1Q  Median      3Q     Max 
# -22.087 -19.236  -6.333  18.246  33.068 
# 
# Coefficients:
#              Estimate Std. Error t value Pr(>|t|)    
# (Intercept) 1.965e+02  1.029e+01   19.10 1.33e-06 ***
# block_size  9.753e-03  1.926e-04   50.64 3.98e-09 ***
# ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1 
# 
# Residual standard error: 23.44 on 6 degrees of freedom
# Multiple R-squared: 0.9977, Adjusted R-squared: 0.9973 
# F-statistic:  2564 on 1 and 6 DF,  p-value: 3.978e-09 
# 
# > coef(mod)
#  (Intercept)   block_size 
# 1.965251e+02 9.752809e-03 
 
# Large writes:
# > large_writes <- df_c2[df_c2[,"block_size"] >= 262144 & df_c2[,"dir"] == "read",]
# > large_writes
#    block_size  dir lat_min lat_mean   lat_sd
# 1      524288 read    4848 5055.245 370.5412
# 3      262144 read    2482 2646.636 221.2057
# 10    1048576 read    8787 9832.130 275.6045
# > mod <- lm(lat_mean ~ block_size, data = large_writes)
# > summary(mod)
# 
# Call:
# lm(formula = lat_mean ~ block_size, data = large_writes)
# 
# Residuals:
#      1      3     10 
#  8.643 -5.762 -2.881 
# 
# Coefficients:
#              Estimate Std. Error t value Pr(>|t|)   
# (Intercept) 2.582e+02  1.320e+01   19.56  0.03252 * 
# block_size  9.133e-03  1.904e-05  479.81  0.00133 **
# ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1 
# 
# Residual standard error: 10.78 on 1 degrees of freedom
# Multiple R-squared:     1,  Adjusted R-squared:     1 
# F-statistic: 2.302e+05 on 1 and 1 DF,  p-value: 0.001327 
# 
# > coef(mod)
#  (Intercept)   block_size 
# 2.581929e+02 9.133166e-03 
