require 'timeout'
require 'ftdi'

class FtdiIO
  def initialize(dev, bitbang=true)
    @ftdi = Ftdi::Context.new
    @ftdi.open(dev)

    if bitbang then
      @ftdi.set_bitmode(0xFF, Ftdi::BITMODE_BITBANG)
    end
  end

  def baudrate=(baud)
    @ftdi.baudrate = baud
  end

  def read(n)
    return @ftdi.read_data(n)
  end

  def read_timeout(t, n)
    return io_timeout(t) { read(n) }
  end

  def write(s)
    return @ftdi.write_data(s)
  end

  def write_timeout(t, s)
    return io_timeout(t) { write(s) }
  end

  def io_timeout(t=1, &block)
    begin
      return timeout(t, &block)
    rescue TimeoutError
    end
  end
end

