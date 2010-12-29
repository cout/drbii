require 'drbii/smec'
require 'drbii/memory_map'
require 'drbii/ftdi_io'

if __FILE__ == $0 then
  source_filename = ARGV[0]
  mmap = MemoryMap.new(source_filename)

  ftdi_dev = ARGV[1]
  ftdi = FtdiIO.new(ftdi_dev, true)

  drbii = DRBII.new(ftdi)
  drbii.handshake()
  puts mmap.read_location(mmap['RPM'])
end

