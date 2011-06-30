# USB Device Descriptor.
# These fields are documented in Table 9-8 in the USB Specification 2.0.
class Usb::DeviceDescriptor < Struct.new(:bLength, :bDescriptorType,
  :bcdUSB, :bDeviceClass, :bDeviceSubClass, :bDeviceProtocol,
  :bMaxPacketSize0, :idVendor, :idProduct, :bcdDevice,
  :iManufacturer, :iProduct, :iSerialNumber, :bNumConfigurations)

end

module Usb::Descriptors

end

class Usb::Descriptors::Configuration
  attr_accessor :wLength
  attr_accessor :bNumInterfaces
  attr_accessor :bConfigurationValue
  attr_accessor :iConfiguration
  attr_accessor :bmAttributes
  attr_accessor :bMaxPower

  def self.from_binary(binary)
    config = new
    bLength, bDescriptorType, wTotalLength, config.bNumInterfaces, config.bConfigurationValue, config.iConfiguration, config.bmAttributes, config.bMaxPower = binary.unpack('CCvCCCCC')

    raise Usb::DescriptorParsingError, "Expected bLength of configuration descriptor to be 9, but got #{bLength}." if bLength != 9
    
    raise Usb::DescriptorParsingError, "..."

    config
  end
end
