class Usb::DeviceHandle
  def initialize
    raise NotImplementedError, "To open a device handle, use Usb::DeviceHandle.open."
  end
end
