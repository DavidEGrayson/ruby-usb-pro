# USB Device Descriptor.
# These fields are documented in Table 9-8 in the USB Specification 2.0.
class Usb::DeviceDescriptor < Struct.new(:bLength, :bDescriptorType,
  :bcdUSB, :bDeviceClass, :bDeviceSubClass, :bDeviceProtocol,
  :bMaxPacketSize0, :idVendor, :idProduct, :bcdDevice,
  :iManufacturer, :iProduct, :iSerialNumber, :bNumConfigurations)

end

module Usb::Descriptors
  class Descriptor
    def initialize
      raise NotImplementedError, "Descriptor is an abstract class." if self.class == Descriptor
    end

    def self.descriptor_type(descriptor_type)
      Configuration::SubDescriptors[descriptor_type] = self
    end

    private
    def self.field(name, type, length)
      @fields ||= []
      @format ||= 'xx'
      @length ||= 2

      @fields << ('@' + name.to_s).to_sym
      @format += type
      @length += length

      public; attr_accessor name
    end

    def self.uint8(name)
      field name, 'C', 1
    end

    def self.uint16(name)
      field name, 'v', 2
    end

    def self.uint32(name)
      field name, 'V', 3
    end
    
    public

    def self.length
      @length
    end

    def self.from_binary(binary)
      bLength = binary[0].ord
      raise Usb::DescriptorParsingError, "Expected bLength of #{self.class.name} descriptor to be #{@length}, but got #{bLength}" if bLength != @length

      desc = new
      values = binary.unpack(@format)
      values.each_with_index do |value, n|
        desc.instance_variable_set @fields[n], value
      end
      return desc
    end
  end

  class Configuration < Descriptor
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

    def self.each_descriptor_binary(binary)
      binary = binary.dup
      while !binary.empty?
        yield next_descriptor_binary(binary)
      end
    end

    def self.from_binary(binary)
      config = new
      bLength, bDescriptorType, wTotalLength, config.bNumInterfaces, config.bConfigurationValue, config.iConfiguration, config.bmAttributes, config.bMaxPower = binary.unpack('CCvCCCCC')

      raise Usb::DescriptorParsingError, "Expected bLength of configuration descriptor to be 9, but got #{bLength}." if bLength != 9

      binary = binary[9..-1]

      each_descriptor_binary(binary) do |db|
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

  class Interface < Descriptor
    descriptor_type 4
    uint8 :bInterfaceNumber
    uint8 :bAlternateSetting
    uint8 :bNumEndpoints
    uint8 :bInterfaceClass
    uint8 :bInterfaceSubClass
    uint8 :bInterfaceProtocol
    uint8 :iInterface
  end

end

