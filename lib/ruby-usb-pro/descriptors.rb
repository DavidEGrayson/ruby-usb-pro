# USB Device Descriptor.
# These fields are documented in Table 9-8 in the USB Specification 2.0.
class Usb::DeviceDescriptor < Struct.new(:bLength, :bDescriptorType,
  :bcdUSB, :bDeviceClass, :bDeviceSubClass, :bDeviceProtocol,
  :bMaxPacketSize0, :idVendor, :idProduct, :bcdDevice,
  :iManufacturer, :iProduct, :iSerialNumber, :bNumConfigurations)

end

module Usb::Descriptors
  class Configuration
    attr_accessor :wLength
    attr_accessor :bNumInterfaces
    attr_accessor :bConfigurationValue
    attr_accessor :iConfiguration
    attr_accessor :bmAttributes
    attr_accessor :bMaxPower

    attr_accessor :descendents
    attr_accessor :children

    SubDescriptors = {}

    def initialize()
      @descendents = []
      @children = []
    end

    def self.next_descriptor_binary(binary)
      raise ArgumentError if binary.empty?
      bLength = binary[0].ord
      raise Usb::DescriptorParsingError, "Unexpected end of descriptors: bLength=#{bLength} but only #{binary.length} bytes remaining." if binary.length < bLength 
      descriptor = binary[0, bLength]
      binary.replace(binary[bLength..-1])
      return descriptor
    end

    def self.from_binary(binary)
      config = new
      bLength, bDescriptorType, wTotalLength, config.bNumInterfaces, config.bConfigurationValue, config.iConfiguration, config.bmAttributes, config.bMaxPower = binary.unpack('CCvCCCCC')

      raise Usb::DescriptorParsingError, "Expected bLength of configuration descriptor to be 9, but got #{bLength}." if bLength != 9

      binary = binary[9..-1]

      while !binary.empty?
        # Get the descriptor's binary data.
        db = next_descriptor_binary(binary)
        descriptor_type = db[1].ord

        # Create a ruby object for the descriptor.
        klass = SubDescriptors[descriptor_type]
        raise Usb::DescriptorParsingError, "Unrecognized descriptor type: #{descriptor_type}." if klass.nil?

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

  class Descriptor
    def self.descriptor_type(descriptor_type)
      Configuration::SubDescriptors[descriptor_type] = self
    end
  end

  class Interface < Descriptor
    descriptor_type 4

    attr_accessor :bInterfaceNumber
    attr_accessor :bAlternateSetting
    attr_accessor :bNumEndpoints
    attr_accessor :bInterfaceClass
    attr_accessor :bInterfaceSubClass
    attr_accessor :bInterfaceProtocol
    attr_accessor :iInterface

    def self.from_binary(binary)
      i = new
      bLength, i.bInterfaceNumber, i.bAlternateSetting, i.bNumEndpoints, i.bInterfaceClass, i.bInterfaceSubClass, i.bInterfaceProtocol, i.iInterface = binary.unpack "CxCCCCCCC"

      raise Usb::DescriptorParsingError, "Expected bLength of interface descriptor to be 9, but got #{bLength}." if bLength != 9
    end
  end

end


