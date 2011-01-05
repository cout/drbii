require 'ftdic'

ftdi = FtdiC::Context.new
ftdi.open(ARGV[0] || 'i:0x0403:0x6001')
# ftdi.set_bitmode(0xFF, FtdiC::BITMODE_BITBANG)
# ftdi.set_bitmode(0xFF, FtdiC::BITMODE_RESET)
ftdi.set_bitmode(0xFF, FtdiC::BITMODE_SYNCBB)
ftdi.baudrate = 7812

# cmd = 0x14.chr + 0x10.chr
# ftdi.write_data(cmd)

loop do
  p ftdi.read_data(100)
end

