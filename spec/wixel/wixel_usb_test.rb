class WixelUsbTest
  attr_accessor :handle

  Opts = {:vendor_id => 0x1FFB, :product_id => 0x22FF}

  def self.devices(opts={})
    Usb.devices(Opts.merge(opts))
  end

  def self.open(opts={}, &block)
    Usb::DeviceHandle.open(Opts.merge(opts), &block)
  end

  def initialize(usb_device)
    @handle = usb_device.open_handle
  end

  def blink_period
    handle.control_read_transfer(0xC0, 1, 0, 0, 2).unpack('v')[0]
  end

  def blink_period=(period)
    handle.control_write_transfer 0x40, 1, period, 0
  end

  def name=(name)
    handle.control_write_transfer 0x40, 2, 0, 0, name
  end

  def name
    handle.control_read_transfer 0xC0, 2, 0, 0, 255
  end

  def start_bootloader!
    handle.control_write_transfer 0x40, 0xFF, 0, 0
    close
  end

  def close
    handle.close
  end
end

