require 'pp'

class LogFile
  LOG_TYPES = ["bw", "lat", "clat", "slat"]
  
  def initialize(name)
    @name = name
  end
  
  def summarize_to(outname)
    latencies = []
    bytes = []
    start_time = nil
    end_time = nil
    current_bs = nil
    
    File.open(outname, "w") do |outfile|
      File.open(@name) do |infile|
        infile.each_line do |line|
          time, lat, ddir, block_size = line.split(',')
          time = time.to_i
          lat = lat.to_i
          block_size = block_size.to_i
          
          if start_time.nil?
            start_time = time
            current_bs = block_size
          elsif (time > start_time + 1000) || (current_bs != block_size)
            lat_mean, lat_sd = summarize latencies
            
            outfile.printf("%8d, %8d, %8d, %8.2f, %8.2f\n",
              end_time,
              current_bs,
              sum(bytes) / 1024,
              lat_mean,
              lat_sd)
            
            start_time = time
            current_bs = block_size
            latencies = []
            bytes = []
          end
          
          end_time = time
          latencies << lat
          bytes << block_size
        end
      end
    end
  end
  
  def self.clear_all(name)
    LOG_TYPES.each do |log|
      File.unlink("#{name}_#{log}.log")
    end
  end
  
private
  
  def sum(a)
    a.inject(0) { |acc,i| acc + i }
  end
  
  def summarize(a)
    sum = sum(a)
    mean = sum.to_f / a.length
    variance = a.inject(0) { |acc, i| acc += (i - mean) ** 2 } / a.length
    # Note, this is population stddev, not sample, since we have the
    # full population's worth of data
    standard_deviation = Math.sqrt(variance)

    [mean, standard_deviation]
  end
end