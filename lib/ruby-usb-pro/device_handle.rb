class Usb::DeviceHandle
  def initialize(device); end # Source code is in device_handle.c

  attr_reader :device

  def self.open(arg, &block)
    if arg.is_a? Usb::Device
      device = arg
    else
      devices = Usb.devices(arg)
      raise NotFoundError, "No devices found matching #{arg.inspect}." if devices.empty?
      device = devices.first
    end
    device.open_handle(&block)
  end

  def dup
    dev = device.open_handle
    dev.close if closed?
    dev
  end

  def ==(other)
    eql?(other)
  end

  def ===(other)
    eql?(other)
  end

  def eql?(other); end  # Source code in rusb.c
  def close; end  # Source code is in device_handle.c

  def closed?; end  # Source code is in device_handle.c
end
