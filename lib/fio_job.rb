require 'rubygems'
require 'set'
require 'fileutils'
require 'open4'

class FioJob
  attr_reader :name, :description, :options

  @@directory = File.expand_path(File.join(File.dirname(__FILE__), 'jobs'))
  @@fio = '/usr/local/bin/fio'

  def self.all
    Dir.open(@@directory).entries.grep(/.fio$/).map do |name|
      FioJob.new(name)
    end
  end

  def self.fio=(path_to_fio)
    @@fio = path_to_fio
  end
  
  def initialize(name)
    @name = name.gsub(/.fio$/, '')
    @file = File.join(@@directory, name)
    @options = Set.new

    File.open(File.join(@@directory, name)) do |file|
      file.each_line do |line|
        key, val = line.split "="

        next if key.nil?
        next if val.nil?
        
        val = val.chomp
        @description = val if (key == "description")
        @options << key.to_sym if (val.match /\$\{\w+\}/)
      end
    end
  end

  def inspect
    "#{@name}: #{@description}"
  end
  
  def run(run_options = {})
    missing_options = @options - run_options.keys.to_set
    
    unless missing_options.empty?
      raise "cannot run #{@name}, must provide run options: #{missing_options.to_a.join(', ')}"
    end
    
    puts "Running FIO job: #{@name}"

    FileUtils.mkdir_p(run_options[:log])

    Dir.chdir(run_options[:log]) do
      with_env_options(run_options) do
        run_fio
      end
    end
  end
  
  private

  def with_env_options(options, &block)
    # Store options with Array parameters
    array_opts = nil
    array_vals = nil

    options.each_pair do |opt, val|
      if val.kind_of? Array
        # Need to loop over values
        if array_opts.nil?
          array_opts = [ opt ]
          array_vals = val
        else
          array_opts << opt
          array_vals = array_vals.product val
        end
      else
        # Set fixed env variable
        puts "- #{opt} = #{val}"
        ENV[opt.to_s.upcase] = val.to_s
      end
    end

    array_vals.each do |val_array|
      array_opts.each_with_index do |opt, i|
        val = val_array[i]

        puts "- #{opt} = #{val}"
        ENV[opt.to_s.upcase] = val.to_s
      end

      block.call
    end
  end

  def run_fio
    pid, stdin, stdout, stderr = Open4::popen4 "#{@@fio} #{@file}"

    ignored, status = Process::waitpid2 pid

    File.open("fio.log", "a") do |file|
      file.print stdout.read
    end

    if status.exitstatus != 0
      STDERR.puts stderr.read
      raise "error running fio (#{status.exitstatus})"
    end
  end
end
