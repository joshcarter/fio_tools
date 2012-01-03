require 'set'

class FioJob
  attr_reader :name, :description, :options

  @@directory = File.expand_path(File.join(File.dirname(__FILE__), 'jobs'))

  def self.all
    Dir.open(@@directory).entries.grep(/.fio$/).map do |name|
      FioJob.new(name)
    end
  end
  
  def initialize(name)
    @name = name.gsub(/.fio$/, '')
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
    
    puts "running #{@name}"
    
    run_options.each_pair do |opt, val|
      puts "- #{opt} = #{val}"
      ENV[opt.to_s] = val.to_s
    end
    
    # TODO: more here
  end
end
