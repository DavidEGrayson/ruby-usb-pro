module Usb
  class TimeoutError < Exception
  end

  class BusyError < Exception
  end

  class AccessDeniedError < Exception
  end

  class NoDeviceError < Exception
  end

  class NotFoundError < Exception
  end

  class BusyError < Exception
  end

  class TimeoutError < Exception
  end

  class OverflowError < Exception
  end

  class PipeError < Exception
  end

  class Device
    def bus_number; end  # Source code is in rusb.c
    def address; end     # Source code is in rusb.c
    def max_packet_size(endpoint_number); end  # Source code is in rusb.c
  end
end

require 'rusb'
