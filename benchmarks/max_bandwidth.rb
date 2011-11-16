#!/usr/bin/env ruby

require 'pp'

module Enumerable
  def sum
    self.inject(0) { |acc,i| acc + i }
  end
 
  def mean
    self.sum / self.length.to_f
  end
 
  def sample_variance
    avg = self.mean
    sum = self.inject(0) { |acc, i| acc + (i - avg) ** 2}
    1 / self.length.to_f * sum
  end
 
  def standard_deviation
    Math.sqrt(self.sample_variance)
  end
end

def bw_stats(pat)
  samples = []

  File.open("#{pat}_bw.log") do |log|
    log.each_line do |line|
      time, bandwidth, direction, block_size = line.split(",")

      samples << bandwidth.to_i
    end
  end

  [samples.mean, samples.standard_deviation]
end

def clear_logs(pat)
  ["bw", "clat", "lat", "slat"].each do |log|
    File.unlink("#{pat}_#{log}.log")
  end
end


block_sizes = [4 * 1024, 16 * 1024, 64 * 1024, 256 * 1024, 1024 * 1024]
maximums = {}

# Determine maximum bandwidth at each block size
block_sizes.each do |bs|
  ENV['BS'] = bs.to_s

  unless system("fio max_bandwidth.fio")
    puts "fio returned error"
    break
  end

  maximums[bs] = bw_stats("max")

  clear_logs("max")
end

puts "maximums:"
pp maximums



__END__


block_sizes.each do |bs|
  rate = 1 * 1024 * 1024
  step = 1 * 1024 * 1024
  rate = bs if (rate < bs)

  loop do
    ENV['RATE'] = rate.to_s
    ENV['BS'] = bs.to_s
    ENV['RATEMIN'] = (rate * 0.8).to_i.to_s

    unless system("fio ramp_bandwidth.fio")
      puts "fio returned error"
      break
    end

    ["bw", "clat"].each do |log|
      File.open("ramp_#{log}.log") do |infile|
        File.open("ramp_merged_#{log}.log", "a") do |outfile|
          infile.each_line do |line|
            outfile.puts "#{line.chomp}, #{rate / 1024}"
          end
        end
      end

      clear_logs("ramp")
    end

    rate += step
  end
end
