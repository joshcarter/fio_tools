require 'rubygems'
require 'ruby-units'

class Disk
  attr_reader :name, :model, :size

  def self.all
    unless File.exists?("/sys/block")
      raise "System does not support /sys/block"
    end

    Dir.open("/sys/block").entries.grep(/^sd/).map do |d|
      Disk.new(d)
    end
  end

  def initialize(name)
    model = File.read("/sys/block/#{name}/device/model").chomp.strip
    size = File.read("/sys/block/#{name}/size").chomp.to_i * 512 

    @name = name
    @model = model
    @size = Unit.new [size, "byte"]
  end

  def inspect
    "#{@name} (#{@model} #{@size.to_s('%0.1f Gibyte')})"
  end
end
