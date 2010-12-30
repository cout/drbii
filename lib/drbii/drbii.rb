require 'drbii/protocol/drb_functions'
require 'drbii/protocol/atm_sub_functions'
require 'drbii/protocol/switch_test_sub_functions'
require 'drbii/protocol/diagnostics_data_sub_functions'

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

  def do_cmd(cmd, *args)
    # All commands are echo'd back
    s = ([cmd] + args).pack('C')
    @io.write(s)
    result = @io.read_timeout(1, 1)
    if result != cmd then
      raise RuntimeError, "Expected #{cmd} but got #{result}"
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
  end

  def setup_atm(subfunc)
    raise NotImplementedError
  end

  def send_diagnostic_data_to_sci(subfunc)
    do_cmd(DrbFunctions::SendDiagnosticDataToSCI, subfunc)
    s = @io.read_timeout(1, 1)
    return s.unpack('C')
  end

  def send_16bit_memory_location(addr1, addr2)
    do_cmd(DrbFunctions::SendDiagnosticDataToSCI, addr1, addr2)
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
    while @io.read_timeout(1, 1) do
      # ...
    end
    @logger.info "Reached end of data stream"
  end
end

