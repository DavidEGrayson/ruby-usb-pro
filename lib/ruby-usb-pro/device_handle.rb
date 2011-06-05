class Usb::DeviceHandle
  def initialize(device); end # source code is in rusb.c

  attr_reader :device

  def self.open(arg)
    if arg.is_a? Usb::Device
      device = arg
    else
      devices = Usb.devices(arg)
      raise NotFoundError, "No devices found matching #{arg.inspect}." if devices.empty?
      device = devices.first
    end
    device.open_handle
  end

  def dup
    return device.open_handle
  end
end
