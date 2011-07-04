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

  attr_accessor :descendents
  attr_accessor :children

  def initialize()
    @descendents = []
    @children = []
  end

  def self.next_descriptor_binary(binary)
    raise ArgumentError if binary.empty?
    bLength = binary[0]
    raise Usb::DescriptorParsingError, "Unexpected end of descriptors: bLength=#{bLength} but only #{binary.length} bytes remaining." if binary.length < bLength 
    descriptor = binary[1, bLength-1]
    binary.replace(binary[bLength..-1])
    return descriptor
  end

  def self.from_binary(binary)
    config = new
    bLength, bDescriptorType, wTotalLength, config.bNumInterfaces, config.bConfigurationValue, config.iConfiguration, config.bmAttributes, config.bMaxPower = binary.unpack('CCvCCCCC')

    raise Usb::DescriptorParsingError, "Expected bLength of configuration descriptor to be 9, but got #{bLength}." if bLength != 9
    
    binary = binary[9,-1]

    while !binary.empty?
      # Get the descriptor's binary data (all bytes except bLength).
      db = next_descriptor_binary(binary)
      descriptorType = db[0]

      # Create a ruby object for the descriptor.
      klass = SubDescriptors[descriptorType]
      raise Usb::DescriptorParsingError, "Invalid descriptor type: #{descriptorType}." if klass.nil?

      config.descendents << klass.from_binary(db)
    end

    # Organize the descriptors in a heirarchy.
    current_ancestors = [config]
    config.descendents.each do |desc|
      while !desc.can_be_child_of?(current_ancestors.last)
        current_ancestors.pop
      end
      current_ancestors.last.children << desc
      current_ancestors << desc
    end

    config
  end
end
