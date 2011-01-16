require 'timeout'
require 'logger'

class NullIO
  def initialize
    @logger = Logger.new(STDOUT)
  end

  def baudrate=(baud)
    @logger.info "Setting baud rate to #{baud}"
  end

  def read(n)
    @logger.info "Reading #{n} bytes"
    return "" # TODO
  end

  def read_timeout(n, t)
    return io_timeout(t) { read(n) }
  end

  def write(s)
    @logger.info "Writing #{s.inspect}"
    # TODO
  end

  def write_timeout(s, t)
    return io_timeout(t) { write(s) }
  end

  def io_timeout(t=1, &block)
    begin
      return timeout(t, &block)
    rescue TimeoutError
      @logger.info "Timeout after #{t} seconds"
    end
  end
end

