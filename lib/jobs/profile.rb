desc 'Basic block device profile'
command :profile do |c|
  desc 'device to test (WARNING: all data will be destroyed!)'
  arg_name 'device'
  c.flag [:d, :device]
  
  desc 'run time at each block size/load'
  arg_name 'time'
  default_value '1m'
  c.flag [:t, :runtime]

  c.action do |global_options,options,args|
    fio_opts = {}

    fio_opts[:bs] = (0..11).to_a.map { |i| 512 << i } # 512..1M
    fio_opts[:rw] = ["randread", "randwrite"]
    fio_opts[:log] = global_options[:log]
    fio_opts[:runtime] = options[:runtime]

    if options[:device]
      dev = Disk.new(options[:device])
      fio_opts[:filename] = dev.path
      fio_opts[:size] = (dev.size >> "Gibyte").floor.scalar.to_s + "g"
    else
      puts "Available devices:"
      puts
      Disk.all.map { |d| puts " - #{d.inspect}" }
      puts

      raise "must specify device"
    end

    FioJob.new("profile.fio").run fio_opts
  end
end

