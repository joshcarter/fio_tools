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
    @options = []

    File.open(File.join(@@directory, name)) do |file|
      file.each_line do |line|
        key, val = line.split "="

        next if key.nil?
        next if val.nil?
        
        val = val.chomp
        @description = val if (key == "description")
        @options << key if (val.match /\$\{\w+\}/)
      end
    end
  end

  def inspect
    "#{@name}: #{@description}"
  end
end
