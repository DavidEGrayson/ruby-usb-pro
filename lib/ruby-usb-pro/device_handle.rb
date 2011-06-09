class Usb::DeviceHandle
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

  def string_descriptor(index, language_id=nil)
    language_id ||= lang_ids.first || 0
    control_transfer(0x80, 6, (3 << 8) | index, language_id, 255)
  end

  def lang_ids
    @lang_ids ||= get_lang_ids
  end

  private
  def get_lang_ids
    ids_string = string_descriptor(0, 0)
    i = 0
    ids = []
    while(i+1 < ids_string.length)
      ids << ids_string[0].ord + ids_string[1].ord * 256
      i+= 2
    end
    return ids
  end
end
