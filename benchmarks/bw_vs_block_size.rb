#!/usr/bin/env ruby

require 'pp'

block_sizes = (0..11).to_a.map { |i| 512 << i } # 512..1M
ops = ["read", "write"]

block_sizes.each do |bs|
  ops.each do |op|
    ENV['BS'] = bs.to_s
    ENV['RW'] = op

    unless system("fio bw_vs_block_size.fio")
      puts "fio returned error"
      break
    end
  end
end
