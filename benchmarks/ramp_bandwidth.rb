#!/usr/bin/env ruby

rate = 100 * 1024
step = 100 * 1024
block_sizes = ['4k', '16k', '64k']

loop do
  ENV['RATE'] = rate.to_s
  ENV['BS'] = block_sizes.first
  ENV['RATEMIN'] = (rate * 0.8).to_i.to_s

  unless system("fio ramp_bandwidth.fio")
    puts "error running fio"
    exit -1
  end

  rate += step
end
