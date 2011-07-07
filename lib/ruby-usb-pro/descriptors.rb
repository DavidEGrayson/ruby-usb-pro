# USB Device Descriptor.
# These fields are documented in Table 9-8 in the USB Specification 2.0.
class Usb::DeviceDescriptor < Struct.new(:bLength, :bDescriptorType,
  :bcdUSB, :bDeviceClass, :bDeviceSubClass, :bDeviceProtocol,
  :bMaxPacketSize0, :idVendor, :idProduct, :bcdDevice,
  :iManufacturer, :iProduct, :iSerialNumber, :bNumConfigurations)

end

module Usb::Descriptors
  DescriptorFactories = {}
  ClassSpecificDescriptorFactories = {}

  class Descriptor
    attr_accessor :children

    def initialize
      raise NotImplementedError, "Descriptor is an abstract class." if self.class == Descriptor
      @children = []
    end

    def self.can_be_child_of(*klasses)
      proc = Proc.new do |descriptor|
        klasses.each do |klass|
          return true if descriptor.is_a? klass
        end
        return false
      end
      define_method :can_be_child_of?, proc
    end

    def self.descriptor_type(descriptor_type)
      @descriptor_type = descriptor_type
      DescriptorFactories[descriptor_type] = self
      uint8 :bDescriptorType
    end

    def self.class_specific(class_code, descriptor_type, descriptor_subtype)
      if descriptor_type.is_a?(Symbol)
        descriptor_type = Usb::DescriptorTypes::Table[descriptor_type]
        raise ArgumentError, "Unrecognized descriptor_type :#{descriptor_type}." if descriptor_type.nil?
      end
      descriptor_type |= 0x20  # Set the class-specific bit

      x = (ClassSpecificDescriptorFactories[class_code] ||= {})
      x = (x[descriptor_type] ||= {})
      x[descriptor_subtype] = self

      @descriptor_type = descriptor_type
      @descriptor_subtype = descriptor_subtype

      uint8 :bDescriptorType
      uint8 :bDescriptorSubtype

      proc = Proc.new do |descriptor|
        descriptor.bDescriptorType == descriptor_type & ~0x20
      end
      define_method :can_be_child_of?, proc
    end

    def self.inherited(descriptor_class)
      descriptor_class.instance_eval do
        @fields = []
        @format = ''
        @length = 0
        uint8 :bLength
      end
    end

    private
    def self.field(name, type, length)
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
      raise Usb::DescriptorParsingError, "Expected bLength of #{self} to be #{@length}, but got #{bLength}" if bLength != @length

      desc = new
      values = binary.unpack(@format)
      values.each_with_index do |value, n|
        desc.instance_variable_set @fields[n], value
      end
      return desc
    end
  end

  class Configuration < Descriptor
    descriptor_type Usb::DescriptorTypes::Configuration 
    uint16 :wTotalLength
    uint8 :bNumInterfaces
    uint8 :bConfigurationValue
    uint8 :iConfiguration
    uint8 :bmAttributes
    uint8 :bMaxPower

    attr_accessor :descendents

    def initialize()
      super
      @descendents = []
    end

    def self_powered?
      (@bmAttributes & 0x40) != 0
    end

    def remote_wakeup?
      (@bmAttributes & 0x20) != 0
    end

    def interfaces
      interfaces = []
      children.each do |child|
        interfaces[child.bInterfaceNumber] = child if child.is_a? Interface
      end
      interfaces
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

    def self.get_factory(binary, device_class_code=0)
      descriptor_type = binary[1].ord
      if (descriptor_type & 0x20) != 0
        descriptor_subtype = binary[2].ord
        x = ClassSpecificDescriptorFactories[device_class_code]
        raise Usb::DescriptorParsingError, "No class-specific descriptors known for class code #{'0x%02x'%device_class_code}." unless x
        x = x[descriptor_type]
        raise Usb::DescriptorParsingError, "No class-specific descriptors known for class code #{'0x%02x'%device_class_code} and bDescriptorType=#{'0x%02x'%descriptor_type}." unless x
        x = x[descriptor_subtype]
        raise Usb::DescriptorParsingError, "No class-specific descriptors known for class code #{'0x%02x'%device_class_code}, bDescriptorType=#{'0x%02x'%descriptor_type}, bDescriptorSubtype=#{'0x%02x'%descriptor_subtype}." unless x
        return x
      else
        factory = DescriptorFactories[descriptor_type]
        raise Usb::DescriptorParsingError, "Unrecognized descriptor type: #{descriptor_type}." if factory.nil?
        return factory
      end
    end

    def self.from_binary(binary, device_class_code)
      config = super(binary)

      remaining_binary = binary[@length..-1]

      current_device_class_code = device_class_code
      each_descriptor_binary remaining_binary do |db|
        factory = get_factory(db, current_device_class_code)
        new_desc = factory.from_binary(db)
        config.descendents << new_desc
        # TODO: ask new_desc what the 'current_device_class_code' should
        # be for its descendents and figure out how to maintain that    
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
    can_be_child_of Configuration
    descriptor_type 4
    uint8 :bInterfaceNumber
    uint8 :bAlternateSetting
    uint8 :bNumEndpoints
    uint8 :bInterfaceClass
    uint8 :bInterfaceSubClass
    uint8 :bInterfaceProtocol
    uint8 :iInterface
  end

  # See Table 9-13 in USB2.0.
  class Endpoint < Descriptor
    can_be_child_of Interface
    descriptor_type 5
    uint8 :bEndpointAddress
    uint8 :bmAttributes
    uint16 :wMaxPacketSize
    uint8 :bInterval

    def number
      @bEndpointAddress & 0x7F
    end

    def direction
      (@bEndpointAddress & 0x80) == 0 ? :out : :in
    end

    def transfer_type
      case @bmAttributes & 3
        when 0 then :control
        when 1 then :isochronous
        when 2 then :bulk
        when 3 then :interrupt
      end
    end

    def synchronization_type
      case (@bmAttributes >> 2) & 3
        when 0 then :no_synchronization
        when 1 then :asynchronous
        when 2 then :adaptive
        when 3 then :synchronous
      end
    end

    def usage_type
      case (@bmAttributes >> 4) & 3
        when 0 then :data
        when 1 then :feedback
        when 2 then :implicit_feedback_data
      end
    end

    def in?
      direction == :in
    end

    def out?
      direction == :out
    end

    # TODO: make transfer_type?, synchronization_type?, usage_type? and related functions
  end

end

