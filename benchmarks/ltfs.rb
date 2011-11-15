#!/usr/bin/env ruby

["write", "read"].each do |rw|
  ["4k", "64k", "1024k"].each do |bs|

    puts "initializing LTFS tape"
    unless system("mkltfs --device=/dev/IBMtape0")
      puts "error running mkltfs"
      exit 1
    end

    puts "mounting tape"
    unless system("ltfs /mnt/tape")
      puts "error mounting ltfs"
      exit 1
    end

    puts "running test: #{rw} @ #{bs}"
    ENV['RW'] = rw
    ENV['BS'] = bs
    unless system("fio ltfs.fio")
      puts "error running fio"
      exit 1
    end

    puts "unmounting tape"
    system("umount /mnt/tape")
  end
end
