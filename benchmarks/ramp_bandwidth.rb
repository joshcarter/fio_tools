#!/usr/bin/env ruby

block_sizes = [4 * 1024, 16 * 1024, 64 * 1024, 256 * 1024, 1024 * 1024]

block_sizes.each do |bs|
  rate = 1024 * 1024
  step = 1024 * 1024
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

      # Reset log file
      File.open("ramp_#{log}.log", "w").close
    end

    rate += step
  end
end
