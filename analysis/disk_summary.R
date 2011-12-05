# Beginnings of analysis tools for fio logs. Don't use any of these 
# functions blindly at the moment, they may not do what you want.

source("fio_log_parsers.R")
library("ggplot2")

#
# Bandwidth
#
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
    xlab("") +
    facet_grid(op ~ .)

  return(p)
}

bw_scatterplot <- function(bw) {
  p <- bw_base(bw) + 
    geom_point(aes(color = block_size)) +
    facet_grid(. ~ op)
  
  return(p)
}

read_random <- function() {
  return(read_combined_bw(write = "random-write_bw.log", read = "random-read_bw.log"));
}

read_sequential <- function() {
  return(read_combined_bw(write = "sequential-write_bw.log", read = "sequential-read_bw.log"));
}

generate_bw_graphs <- function() {

  # TODO: combine all stats into single data frame and/or scale Y axis so 
  # random and sequential share same scale.
  
  bw <- read_random()
  bw_boxplots(bw)
  ggsave(file = "bw_boxplot_random.pdf", width = 3.5, height = 3.5)
  bw_scatterplot(bw)
  ggsave(file = "bw_scatterplot_random.pdf", width = 7.0, height = 3.5)

  bw <- read_sequential()
  bw_boxplots(bw)
  ggsave(file = "bw_boxplot_sequential.pdf", width = 3.5, height = 3.5)
  bw_scatterplot(bw)
  ggsave(file = "bw_scatterplot_sequential.pdf", width = 7.0, height = 3.5)
}

#
# Latency
#

read_combined_lat <- function(write, read) {
  read <- data.frame(read_lat_log(read), op = "read")
  write <- data.frame(read_lat_log(write), op = "write")

  return(rbind(read, write))
}

lat_base <- function(lat) {
  p <- ggplot(lat) +
    aes(time, latency) +
    xlab("Time (s)") +
    ylab("Latency (usec)") +
    facet_grid(. ~ block_size)
    
  return(p)
}

lat_densityplot <- function(lat) {
  # Cap size of sample to make plot manageable
  if (nrow(lat) > 10000) {
    lat <- lat[sample(nrow(lat), 10000), ]
  }

  p <- lat_base(lat) +
    scale_y_log10(breaks = c(10, 100, 1000, 10000, 100000), labels = c("10us", "100us", "1ms", "10ms", "100ms")) +
    stat_density2d(geom="point", n = 50, aes(size = ..density..), contour = F) +
    scale_area(to = c(0.2, 1.5))
    
  return(p)
}

generate_lat_graphs <- function() {
# lat <- read_combined_lat(write = "sequential-write_clat.log", read = "sequential-read_clat.log")

  lat <- read_lat_log("sequential-write_clat.log")
  lat_densityplot(lat)
  ggsave("lat_densityplot_sequential_write.pdf", width = 7.0, height = 3.5)

  lat <- read_lat_log("sequential-read_clat.log")
  lat_densityplot(lat)
  ggsave("lat_densityplot_sequential_read.pdf", width = 7.0, height = 3.5)

  lat <- read_lat_log("random-write_clat.log")
  lat_densityplot(lat)
  ggsave("lat_densityplot_random_write.pdf", width = 7.0, height = 3.5)

  lat <- read_lat_log("random-read_clat.log")
  lat_densityplot(lat)
  ggsave("lat_densityplot_random_read.pdf", width = 7.0, height = 3.5)
}