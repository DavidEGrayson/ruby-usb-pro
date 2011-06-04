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

  class ClosedError < Exception
  end

  class Device
    def initialize
      raise NotImplementedError, "To get a Usb::Device object, use Usb::get_device_list"
    end

    def bus_number; end  # Source code is in rusb.c
    def address; end     # Source code is in rusb.c
    def max_packet_size(endpoint_number); end  # Source code is in rusb.c
    def max_iso_packet_size(endpoint_number); end

    def closed?; end     # Source code is in rusb.c
    def close; end       # Source code is in rusb.c

    def open_handle; end # Source code is in rusb.c

    def unref
      close
    end
  end

  class DeviceHandle
    def initialize
      raise NotImplementedError, "To open a device handle, use Usb::DeviceHandle.open."
    end
  end
end

require 'rusb'
