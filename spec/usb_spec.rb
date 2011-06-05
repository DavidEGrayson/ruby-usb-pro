require_relative 'spec_helper'

describe Usb do
  it "is a module" do
    Usb.should be_a_kind_of Module
  end

  it "can list devices" do
    devices = Usb.get_device_list
    devices.size.should > 0
    devices.each do |device|
      device.should be_a_kind_of Usb::Device
    end
  end
end

describe Usb::Context do
  it "is a class" do
    Usb::Context.should be_a_kind_of Class
  end
end

describe Usb::Device do
  before :each do
    @devices = Usb::get_device_list
    @device = @devices.last
  end

  it "is a class that represents a USB device connected to the computer" do
    Usb::Device.should be_a_kind_of Class
  end

  it "can be closed" do
    @device.should_not be_closed
    @device.close
    @device.should be_closed
  end

  it "can also be closed with the unref method (which is equivalent to close)" do
    @device.unref
    @device.should be_closed
  end

  it "should not be used after it is closed" do
    @device.close
    lambda { @device.bus_number }.should raise_error Usb::ClosedError
    lambda { @device.address }.should raise_error Usb::ClosedError
    lambda { @device.max_packet_size(:foo) }.should raise_error Usb::ClosedError
  end

  it "can not be closed twice" do
    @device.close
    lambda { @device.close }.should raise_error Usb::ClosedError
  end

  it "is ok to close the duplicates" do
    @device.dup.close
    lambda { @device.bus_number }.should_not raise_error
  end

  it "is ok to close the original (it is not special)" do
    device2 = @device.dup
    @device.close
    lambda { device2.bus_number }.should_not raise_error
  end

  it "is ok to close and then duplicate" do
    @device.close
    @device.dup.should be_closed
  end

  describe :bus_number do
    it "should be between 0 and 20 (most computers only have 1-5 busses)" do
      @devices.each do |device|
        device.bus_number.should be_between 0,20
      end
    end
  end

  describe :device_address do
    it "should be between 0 and 127 as per the USB spec" do
      @devices.each do |device|
        device.address.should be_between 0, 127
      end
    end
  end

  describe :max_packet_size do
    it "makes sure its argument is an int" do
      lambda { @device.max_packet_size(2**64) }.should raise_error RangeError
      lambda { @device.max_packet_size(:foo) }.should raise_error TypeError
    end

    it "doesn't actually work" do
      # TODO: why doesn't max_packet_size work?
      lambda { @device.max_packet_size(0) }.should raise_error Usb::NotFoundError
    end
  end

  describe :max_iso_packet_size do
    it "makes sure its argument is an int" do
      lambda { @device.max_iso_packet_size(2**64) }.should raise_error RangeError
      lambda { @device.max_iso_packet_size(:foo) }.should raise_error TypeError
    end

    it "doesn't actually work" do
      # TODO: why doesn't max_packet_size work?
      lambda { @device.max_iso_packet_size(0) }.should raise_error Usb::NotFoundError
    end
  end

  it "has a device descriptor" do
    dd = @device.device_descriptor
    dd.should be_a_kind_of Usb::DeviceDescriptor
  end

  it "can be used to open a DeviceHandle" do
    pending "imeplementation of open_handle"
    @device.open_handle.should be_a_kind_of Usb::DeviceHandle
    Usb::DeviceHandle.open(@device).should be_a_kind_of Usb::DeviceHandle
  end

  it "can not be created in Ruby" do
    lambda { Usb::Device.new }.should raise_error NotImplementedError
  end
end

describe Usb::DeviceHandle do
  it "is a class the represents an open handle to a device" do
    Usb::DeviceHandle.should be_a_kind_of Class
  end

  it "can not be created in Ruby" do
    lambda { Usb::DeviceHandle.new }.should raise_error NotImplementedError 
  end
end

describe Usb::DeviceDescriptor do
  it "is a class that represents the USB Device Descriptor struct" do
    Usb::DeviceDescriptor.should be_a_kind_of Class
  end

  it "can be constructed by passing in 14 values in the right order" do
    dd = Usb::DeviceDescriptor.new(*((0..13).to_a))

    fields = [:bLength, :bDescriptorType,
    :bcdUSB, :bDeviceClass, :bDeviceSubClass, :bDeviceProtocol,
    :bMaxPacketSize0, :idVendor, :idProduct, :bcdDevice,
    :iManufacturer, :iProduct, :iSerialNumber, :bNumConfigurations]
    fields.each_with_index do |field, index|
      dd.send(field).should == index
    end
  end
end
