class Usb::DeviceHandle
  MaxDescriptorLength = 1024

  # To define which USB devices are considered to be part of
  # the subclass, subclasses of DeviceHandle should either overwrite
  # UsbProperties or overwrite self.devices.
  UsbProperties = {}

  def initialize(device); end # Source code is in device_handle.c

  attr_reader :device

  def self.devices(arg={})
    Usb.devices(self::UsbProperties.merge(arg))
  end

  def self.device(arg={})
    if arg.is_a? Usb::Device
      arg
    elsif arg.is_a? Hash
      device_list = devices(arg)
      raise Usb::NotFoundError, "No devices found matching #{arg.inspect}." if device_list.empty?
      device_list.first
    else
      raise TypeError, "Expected a Usb::Device or Hash."
    end
  end

  def self.open(arg={}, &block)
    handle = new device arg
    return handle unless block_given?
    begin
      return yield(handle)
    ensure
      handle.close
    end
  end

  def dup
    dev = self.class.new(device)
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

  def control_write_transfer(bmRequestType, bRequest, wValue, wIndex, data=nil)
  end

  private
  def get_lang_ids
    ids_string = string_descriptor(0, 0).force_encoding(Encoding::ASCII_8BIT)
    i = 0
    ids = []
    while(i+1 < ids_string.length)
      ids << ids_string[i].ord + ids_string[i+1].ord * 256
      i+= 2
    end
    return ids
  end
end
