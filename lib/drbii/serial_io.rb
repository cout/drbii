require 'serialport'
require 'timeout'

class SerialIO
  def initialize(dev='/dev/ttyUSB0')
    @sp = SerialPort.new(dev)
  end

  def baudrate=(baud)
    @sp.set_modem_params(:baud => baud)
  end

  def read(n=nil)
    s = @sp.read(n)
    return invert(s)
  end

  def read_timeout(t, n=nil)
    return io_timeout(t) { read(n) }
  end

  def write(s)
    s = invert(s)
    return @sp.write(s)
  end

  def write_timeout(t, s)
    return io_timeout(t) { write(s) }
  end

  def invert(s)
    # a = s.unpack('C*')
    # a.map! { |x| ~x }
    # return a.pack('C*')
    return s
  end

  def io_timeout(&block)
    begin
      return timeout(1, &block)
    rescue TimeoutError
    end
  end
end

