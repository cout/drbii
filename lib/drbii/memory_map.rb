require 'drbii/memory_location'

require 'yaml'

class MemoryMap
  def initialize(locations)
    @locations = locations
  end

  def [](name)
    return @locations[name]
  end

  def self.read_source(filename)
    locations = { }

    File.open(filename) do |input|
      input.each_line do |line|
        line.chomp!
        case line
        when /^(.*?)\s*==\s*(.*?)\s*;MPScan;(.*)/
          full_name = $1
          address = $2.to_i
          fields = $3.split(';')
          location = MemoryLocation.new(address, *fields)
          locations[location.name] = location
        end
      end
    end

    return self.new(locations)
  end
end

if __FILE__ == $0 then
  require 'pp'
  filename = ARGV[0]
  map = MemoryMap.read_source(filename)
  pp map
end

