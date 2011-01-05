require 'drbii/drbii'
require 'drbii/memory_map'
require 'drbii/io/ftdi_io'

if __FILE__ == $0 then
  source_filename = ARGV[0] or raise "need source filename"
  mmap = MemoryMap.read_source(source_filename)

  ftdi_dev = ARGV[1] || 'i:0x0403:0x6001'
  ftdi = FtdiIO.new(ftdi_dev, true)

  drbii = DRBII.new(ftdi)
  drbii.handshake()
  puts mmap['RPM'].read(drbii)
end

