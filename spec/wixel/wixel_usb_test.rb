class WixelUsbTest < Usb::DeviceHandle
  UsbProperties = {:vendor_id => 0x1FFB, :product_id => 0x22FF}

  def blink_period
    control_read_transfer(0xC0, 1, 0, 0, 2).unpack('v')[0]
  end

  def blink_period=(period)
    control_write_transfer 0x40, 1, period, 0
  end

  def name=(name)
    control_write_transfer 0x40, 2, 0, 0, name
  end

  def name
    control_read_transfer 0xC0, 2, 0, 0, 255
  end

  def start_bootloader!
    control_write_transfer 0x40, 0xFF, 0, 0
    close
  end
end

