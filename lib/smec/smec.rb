require 'serialport'
require 'timeout'
require 'logger'

class SMEC
  BAUD_LOWSPEED = 976
  BAUD_HIGHSPEED = 7812
  HANDSHAKE = 0x12

  def initialize(dev='/dev/ttyUSB0', speed=BAUD_LOWSPEED)
    @logger = Logger.new(STDOUT)

    @logger.info "Opening port #{dev} at speed #{speed}"
    @sp = SerialPort.new(dev, :baud => speed)
  end

  def handshake
    wait_for_no_more_data()

    loop do
      @logger.info "Sending handshake byte (0x#{'%x' % HANDSHAKE})"
      port_write(HANDSHAKE.chr)

      @logger.info "Reading handshake byte"
      s = io_timeout { port_read(1) }
      b = s.unpack('C')

      @logger.info("Got 0x#{'%x' % b}")
      break if b == HANDSHAKE
    end

    @logger.info "Switching to speed #{BAUD_HIGHSPEED}"
    @sp.set_modem_params(:baud => BAUD_HIGHSPEED)
  end

  def wait_for_no_more_data()
    @logger.info "Waiting for end of data stream"
    io_timeout { port_read() }
    @logger.info "Reached end of data stream"
  end

  def io_timeout(&block)
    begin
      return timeout(1, &block)
    rescue TimeoutError
    end
  end

  def port_read(n=nil)
    s = @sp.read(n)
    return invert(s)
  end

  def invert(s)
    a = s.unpack('C*')
    a.map! { |x| ~x }
    return a.pack('C*')
  end

  def port_write(s)
    s = invert(s)
    return @sp.write(s)
  end

  # TODO: support asynchronous operation

  def get_byte(address)
    port_write(address)
    s = port_read(1)
    return s.unpack('C')
  end

  def get_word(address)
    port_write(address)
    s = port_read(2)
    return s.unpack('I')
  end

  def read_location(location)
    # TODO: use polymorphism
    case location.type
    when 'Byte'
      return get_byte(location.address)
    when 'Word'
      return get_word(location.address)
    end
  end
end

if __FILE__ == $0 then
  smec = SMEC.new
  smec.handshake
end

