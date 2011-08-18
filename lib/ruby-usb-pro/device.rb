module Usb
  def self.devices(conditions={})
    get_device_list.select { |d| d.match?(conditions) }
  end

  def get_device_list(context=nil); end # Source code is in rusb.c.    
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

  def eql?(other); end  # Source code in rusb.c

  def get_config_descriptor_binary(index); end # Souce code is in rusb.c

  private
  def get_device_descriptor; end  # Source code is in rusb.c
  public

  def unref
    close
  end

  def device_descriptor
    # TODO: move this function to DeviceHandle to make it
    # portable to Windows?  OR try to do this:
    # http://www.osronline.com/showthread.cfm?link=207549
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
    "%X.%02X" % [revision_bcd >> 8, revision_bcd & 0xFF]
  end

  def serial_number
    open_handle do |handle|
      handle.string_descriptor device_descriptor.iSerialNumber
    end
  end

  def ==(other)
    eql?(other)
  end

  def ===(other)
    eql?(other)
  end

  def same_device_as?(other)
    bus_number == other.bus_number && address == other.address
  end

  def match?(conditions)
    conditions.each do |method_name, value|
      return false if send(method_name) != value
    end
    return true
  end

  def open_handle(&block)
    Usb::DeviceHandle.open self, &block
  end

end

