require 'drbii/drbii'
require 'drbii/memory_map'
require 'drbii/io/ftdi_io'
require 'drbii/io/null_io'

if __FILE__ == $0 then
  source_filename = ARGV[0] or raise "need source filename"
  mmap = MemoryMap.read_source(source_filename)

  ftdi_dev = ARGV[1] || 'i:0x0403:0x6001'
  io = FtdiIO.new(ftdi_dev, true)
  # io = NullIO.new

  drbii = DRBII.new(io)
  drbii.handshake()
  drbii.setup_hispeed_data_transfer()
  rpm = mmap['RPM'].read(drbii)
  puts "RPM: #{rpm}"
end

