class Usb::DeviceHandle
  MaxDescriptorLength = 1024

  def initialize(device); end # Source code is in device_handle.c

  attr_reader :device

  def self.open(arg, &block)
    if arg.is_a? Usb::Device
      device = arg
    else
      devices = Usb.devices(arg)
      raise NotFoundError, "No devices found matching #{arg.inspect}." if devices.empty?
      device = devices.first
    end
    device.open_handle(&block)
  end

  def dup
    dev = device.open_handle
    dev.close if closed?
    dev
  end

  def ==(other)
    eql?(other)
  end

  def ===(other)
    eql?(other)
  end

  def eql?(other); end  # Source code in rusb.c

  def close; end  # Source code is in device_handle.c
  def closed?; end  # Source code is in device_handle.c

  # USB 2.0 Spec section 9.4.3
  def get_descriptor(type, index, language_id=0)
    type = Usb::DescriptorType.find(type) if type.is_a? Symbol
    raise "Expected type to be a symbol or integer" unless type.is_a? Integer
    control_read_transfer(0x80, Usb::Requests::GetDescriptor, type*256 + index, language_id, MaxDescriptorLength)
  end

  def string_descriptor(index, language_id=nil)
    language_id ||= lang_ids.first || 0
    string = get_descriptor Usb::DescriptorTypes::String, index, language_id
    string = string[2,255]
    string.force_encoding(Encoding::UTF_16LE) if string.respond_to?(:force_encoding)
    return string
  end

  def configuration_descriptor(index)
    @cached_config_descriptors ||= []
    @cached_config_descriptors[index] ||= Usb::Descriptors::Configuration.from_binary configuration_descriptor_binary(index)
  end

  def configuration_descriptor_binary(index)
    @cached_config_descriptors_binary ||= []
    @cached_config_descriptors_binary[index] ||= get_descriptor Usb::DescriptorTypes::Configuration, index
  end

  def lang_ids
    @lang_ids ||= get_lang_ids
  end

  def control_read_transfer(bmRequestType, bRequest, wValue, wIndex, wLength)
    # Source code is in device_handle.c
  end

  private
  def get_lang_ids
    ids_string = string_descriptor(0, 0).force_encoding(Encoding::ASCII_8BIT)
    i = 0
    ids = []
    while(i+1 < ids_string.length)
      ids << ids_string[0].ord + ids_string[1].ord * 256
      i+= 2
    end
    return ids
  end
end
