#!/usr/bin/env ruby

require "open4"

["write", "read"].each do |rw|
  ["4k", "64k", "1024k"].each do |bs|

    puts "running test: #{rw} @ #{bs}"
    ENV['RW'] = rw
    ENV['BS'] = bs

    pid, stdin, stdout, stderr = Open4::popen4 "fio ltfs.fio"

    ignored, status = Process::waitpid2 pid

    File.open("ltfs_fio_#{rw}_#{bs}.log", "w") do |file|
      file.print stdout.read
    end

    if status.exitstatus != 0
      puts "error running fio (#{status.exitstatus})"
      exit 1
    end
  end
end



__END__

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

