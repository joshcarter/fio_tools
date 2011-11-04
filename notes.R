library("ggplot2")

# Individual block size
bw <- read.table("writer_bw_4096.log", col.names=c("time", "rate", "writer", "block_size"), sep=",")
qplot(time / 1000, rate / 1024, data = bw, xlab="Time (s)", ylab="Bandwidth (MB/s)")

# Compound block graph
bw <- read.table("writer_bw.log", col.names=c("time", "rate", "writer", "block_size"), sep=",")
qplot(time / 1000, rate / 1024, facets = block_size ~ ., data = bw, xlab="Time (s)", ylab="Bandwidth (MB/s)")

# ...with smoothed line of best fit
qplot(time / 1000, rate / 1024, facets = block_size ~ ., data = bw, xlab="Time (s)", ylab="Bandwidth (MB/s)", geom=c("point", "smooth"))

# Single graph with block_size mapped to color
qplot(time / 1000, rate / 1024, color = factor(block_size), data = bw, xlab="Time (s)", ylab="Bandwidth (MB/s)")

# Plot only lower part of data, mapping block_size to color
p <- ggplot(bw) + aes(time, rate) + ylim(0,20) + xlab("Time (s)") + ylab("Bandwidth (MB/s)")
p + geom_point(aes(color = factor(block_size)))


# Attempting to plot only outliers (XXX not working)
p2 <- ggplot(bw) + aes(time / 1000, rate / 1024) + ylim(21,max(bw$rate / 1024))
p2 + stat_bin2d(bins = 1)

# Rate summaries
summary(bw[bw$block_size==4096,]$rate)
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    935    5598   30720   23860   31630   54010 
summary(bw[bw$block_size==65536,]$rate)
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
   8393   19410   30660   26290   30850   56230 
summary(bw[bw$block_size==16384,]$rate)
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
   3802   21160   30660   25060   30940   58400 


# Compound latency graph
lat <- read.table("writer_clat.log", col.names=c("time", "latency", "writer", "block_size"), sep=",")
lsmall <- lat[sample(nrow(lat), 10000), ]
qplot(time / 1000, log(latency), facets = block_size ~ ., data = lat, xlab="Time (s)", ylab="Latency (log(usec))", alpha = I(1 / 50))

# Latency summaries
summary(lat[lat$block_size==4096,]$latency)
    Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
     1.0      7.0     12.0    500.1     17.0 393100.0 
summary(lat[lat$block_size==16384,]$latency)
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
      2       8      21    2235      41  509400 
summary(lat[lat$block_size==65536,]$latency)
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
      3      71     163    5987     212  402000 
