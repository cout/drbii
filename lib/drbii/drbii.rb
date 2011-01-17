require 'drbii/protocol/drb_functions'
require 'drbii/protocol/atm_sub_functions'
require 'drbii/protocol/switch_test_sub_functions'
require 'drbii/protocol/diagnostics_data_sub_functions'

require 'logger'

class DRBII
  attr_reader :fastserial

  # BAUD_LOWSPEED = 976
  # BAUD_HIGHSPEED = 7812

  BAUD_LOWSPEED = 7812
  BAUD_HIGHSPEED = 62500

  # BAUD_LOWSPEED = 9608
  # BAUD_HIGHSPEED = 62500

  def initialize(io, baud=BAUD_LOWSPEED)
    @io = io
    @io.baudrate = baud
    @logger = Logger.new(STDOUT)

    # TODO: use 0xf2 to verify whether we are in fastserial mode during
    # the handshake
    @fastserial = false
  end

  def handshake
    wait_for_no_more_data()
  end

  def do_cmd(cmd, *args)
    raise "Cannot send command #{cmd.inspect} while in fastserial mode" if @fastserial

    @logger.info "Sending command #{cmd.inspect} with args #{args.inspect}"

    s = cmd.cmd.chr
    @io.write(s)

    # All commands are echo'd back by the SMEC
    result = @io.read_timeout(1, 1)
    if result[-1] != s[0] then
      raise RuntimeError, "Expected #{s.inspect} but got #{result.inspect}"
    end

    @logger.info "Command byte was echoed back successfully; writing command arguments"
    args.each do |arg|
      # TODO: how to synchronize these writes?
      @io.write(arg.chr)
    end
  end

  def output_error_codes
    do_cmd(DrbFunctions::OutputErrorCodes)

    codes = [ ]

    loop do
      c = @io.read_timeout(1, 1)
      case c
      when 0xfe
        break
      when nil
        raise "Timeout"
      else
        codes.concat(c.unpack('C'))
      end
    end

    return codes
  end

  def output_error_bits
    do_cmd(DrbFunctions::OutputErrorBits)
    hblb = @io.read_timeout(2, 1)
    return hblb.unpack('CC')
  end

  def setup_hispeed_data_transfer
    do_cmd(DrbFunctions::SetupHiSpeedDataTransfer)
    @logger.info "Switching to speed #{BAUD_HIGHSPEED}"
    @io.baudrate = BAUD_HIGHSPEED
    s = @io.read_timeout(1, 1)
    if s != DrbFunctions::SetupHiSpeedDataTransfer.cmd.chr then
      raise "Expected #{DrbFunctions::SetupHiSpeedDataTransfer.cmd.chr.inspect} but got #{s.inspect}"
    end
    @fastserial = true
  end

  def setup_atm(subfunc)
    raise NotImplementedError
  end

  def send_diagnostic_data_to_sci(subfunc)
    do_cmd(DrbFunctions::SendDiagnosticDataToSCI, subfunc)
    s = @io.read_timeout(1, 1)
    return s.unpack('C')
  end

  def send_memory_location(memory_location, offset=0)
    if @fastserial then
      return send_memory_location_fastserial(memory_location, offset)
    else
      return send_16bit_memory_location(memory_location, offset)
    end
  end

  def send_16bit_memory_location(memory_location, offset=0)
    @logger.info("send_16bit_memory_location(#{memory_location.inspect})")

    # TODO: correct byte order?
    address_16bit = memory_location.address + offset
    addr1 = (address_16bit & 0xFF00) >> 8
    addr2 = address_16bit & 0xFF

    do_cmd(DrbFunctions::Send16BitMemoryLocation, addr1, addr2)
    s = @io.read_timeout(1, 1)
    s = @io.read_timeout(1, 1)

    @logger.info("send_16bit_memory_location -> #{s.inspect}")

    return s.unpack('C')
  end

  def send_memory_location_fastserial(memory_location, offset=0)
    raise "Not in fastserial mode" if not @fastserial

    @logger.info("send_memory_location_fastserial(#{memory_location.inspect})")

    # TODO: correct byte order?
    addr = memory_location.address + offset

    @io.write([addr].pack('C'))
    s = @io.read_timeout(1, 1) # echo back memory address (TODO: validate)
    s = @io.read_timeout(1, 1) # then get the actual result

    @logger.info("send_memory_location_fastserial -> #{s.inspect}")

    return s.unpack('C')
  end

  def confirm_fastserial_mode
    raise "Not in fastserial mode" if not @fastserial

    @io.write("\xf2")
    s = @io.read_timeout(1, 1)

    return s == "\xf2"
  end

  def exit_fastserial_mode
    raise "Not in fastserial mode" if not @fastserial

    @io.write(0xfe.chr)
    s = @io.read_timeout(1, 1)

    return s.unpack('C')
  end

  def send_ecuid_to_sci
    raise NotImplementedError
  end

  def clear_error_codes
    do_cmd(DrbFunctions::ClearErrorCodes)
    result = @io.read_timeout(3, 1)
    return result.unpack('CCC')
    # TODO: validate that result is [ 0xe0, 0xe0, 0xe0 ] ?
  end

  def control_asd_relay(arg)
    raise NotImplementedError
  end

  def set_min_idle_speed(arg)
    raise NotImplementedError
  end

  def switch_test(arg)
    raise NotImplementedError
  end

  def init_byte_mode_download
    raise NotImplementedError
  end

  def reset_emr(arg1, arg2)
    raise NotImplementedError
  end

  def wait_for_no_more_data()
    @logger.info "Waiting for end of data stream"
    while @io.read_timeout(1, 1) != "" do
      # ...
    end
    @logger.info "Reached end of data stream"
  end
end

