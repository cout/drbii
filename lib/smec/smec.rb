require 'serialport'
require 'timeout'
require 'logger'

class SMEC
  HANDSHAKE = 0x12

  def initialize(dev='/dev/ttyUSB0', speed=976)
    @logger = Logger.new(STDOUT)

    @logger.info "Opening port #{dev} at speed #{speed}"
    @sp = SerialPort.new(dev, :baud => speed)
  end

  def handshake
    wait_for_no_more_data()

    loop do
      @logger.info "Sending handshake byte (0x#{'%x' % HANDSHAKE})"
      write(HANDSHAKE.chr)

      @logger.info "Reading handshake byte"
      return if io_timeout { read(1) } == HANDSHAKE.chr
    end
  end

  def wait_for_no_more_data()
    @logger.info "Waiting for end of data stream"
    io_timeout { read() }
    @logger.info "Reached end of data stream"
  end

  def io_timeout(&block)
    begin
      return timeout(1, &block)
    rescue TimeoutError
    end
  end

  def read(n=nil)
    return @sp.read(n)
  end

  def write(s)
    return @sp.write(s)
  end

  def getbyte(loc)
    write(loc)
    return read(1)
  end
end

if __FILE__ == $0 then
  smec = SMEC.new
  smec.handshake
end

