require 'drbii/protocol/drb_functions'
require 'drbii/protocol/atm_sub_functions'
require 'drbii/protocol/switch_test_sub_functions'
require 'drbii/protocol/realtime_data_sub_functions'

require 'logger'

class DRBII
  # BAUD_LOWSPEED = 976
  # BAUD_HIGHSPEED = 7812

  BAUD_LOWSPEED = 7812
  BAUD_HIGHSPEED = 62500

  def initialize(io, baud=BAUD_LOWSPEED)
    @io = io
    @io.baudrate = baud
    @logger = Logger.new(STDOUT)
  end

  def handshake
    wait_for_no_more_data()
  end

  def setup_hispeed_data_transfer
    loop do
      @io.write DrbFunctions::SetupHiSpeedDataTransfer
    end

    loop do
      @logger.info "Reading handshake byte"
      s = @io.read_timeout(1, 1)

      if s then
        b = s.unpack('C') 
        @logger.info("Got 0x#{'%x' % b}")
        break if b == HANDSHAKE
      else
        # TODO: distinguish between timeout and null
        @logger.info("No response")
        sleep 1
      end
    end

    @logger.info "Switching to speed #{BAUD_HIGHSPEED}"
    @io.baudrate = BAUD_HIGHSPEED
  end

  def wait_for_no_more_data()
    @logger.info "Waiting for end of data stream"
    while @io.read_timeout(1, 1) do
      # ...
    end
    @logger.info "Reached end of data stream"
  end

  # TODO: support asynchronous operation

  def get_byte(address)
    @io.write(address)
    s = @io.read(1)
    return s.unpack('C')
  end

  def get_word(address)
    @io.write(address)
    s = @io.read(2)
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

