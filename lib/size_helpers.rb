module SizeHelpers
  SCALES = {
    2 ** 10 => :k,
    2 ** 20 => :m,
    2 ** 30 => :g,
    2 ** 40 => :t,
    2 ** 50 => :p,
    2 ** 60 => :e }
   
  SCALES.each_pair do |bytes, scale|
    define_method(scale) { bytes * self }
  end

  def human_readable
    SCALES.keys.sort
  end
end
