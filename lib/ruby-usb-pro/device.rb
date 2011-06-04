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

  private
  def get_device_descriptor; end  # Source code is in rusb.c
end

