module Usb
  def self.devices(conditions={})
    get_device_list.select { |d| d.match?(conditions) }
  end
end

class Usb::Device
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

  def device_descriptor
    # Cache the result because libusb actually does some I/O to retrieve it.
    # TODO: verify this
    @device_descriptor ||= get_device_descriptor
  end

  def vendor_id
    device_descriptor.idVendor
  end

  def product_id
    device_descriptor.idProduct
  end

  def revision_bcd
    device_descriptor.bcdDevice
  end

  def device_class
    device_descriptor.bDeviceClass
  end

  def device_subclass
    device_descriptor.bDeviceSubClass
  end

  def device_protocol
    device_descriptor.bDeviceProtocol
  end

  def revision_bcd
    device_descriptor.bcdDevice
  end

  def revision
    self.class.revision_bcd_to_string(revision_bcd)
  end

  def self.revision_bcd_to_string(revision_bcd)
    if revision_bcd < 0x1000
      ('%03X' % revision_bcd).insert(1, '.')
    else
      ('%04X' % revision_bcd).insert(2, '.')
    end
  end

  def ==(other)
    eql?(other)
  end

  def ===(other)
    eql?(other)
  end

  def eql?(other); end  # Source code in rusb.c

  def same_device_as?(other)
    bus_number == other.bus_number && address == other.address
  end

  def match?(conditions)
    conditions.each do |method_name, value|
      return false if send(method_name) != value
    end
    return true
  end

  private
  def get_device_descriptor; end  # Source code is in rusb.c
end

