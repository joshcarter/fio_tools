#!/usr/bin/env ruby

require 'rubygems'
require 'open4'
require 'pp'

block_sizes = (0..11).to_a.map { |i| 512 << i } # 512..1M
ops = ["randread", "randwrite"]

block_sizes.each do |bs|
  ops.each do |op|
    puts "running test: #{op} @ #{bs}"
    ENV['BS'] = bs.to_s
    ENV['RW'] = op
    ENV['PATH'] += ':/usr/local/bin'

    pid, stdin, stdout, stderr = Open4::popen4 "/usr/bin/env fio bw_vs_block_size.fio"

    ignored, status = Process::waitpid2 pid

    File.open("ltfs_fio_#{op}_#{bs}.log", "w") do |file|
      file.print stdout.read
    end

    if status.exitstatus != 0
      puts "error running fio (#{status.exitstatus})"
      puts stderr.read
      exit 1
    end
  end
end
