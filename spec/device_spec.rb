require_relative 'spec_helper'

describe Usb::Device do
  before :each do
    @devices = Usb::get_device_list
    @device = @devices.last
  end

  it "is a class that represents a USB device connected to the computer" do
    Usb::Device.should be_a_kind_of Class
  end

  it "can be matched against conditions" do
    @device.should be_match :product_id => @device.product_id
    @device.should be_match :revision => @device.revision
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
    lambda { @device.same_device_as?(nil) }.should raise_error Usb::ClosedError
    lambda { @device.device_descriptor }.should raise_error Usb::ClosedError
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

  it "is equal to its duplicates" do
    d2 = @device.dup
    (@device == d2).should be true
    (@device === d2).should be true
    (@device.eql? d2).should be true
    (@device.equal? d2).should be false
  end

  it "all closed devices are equal" do
    d0 = @devices[0]
    d1 = @devices[1]
    d0.should_not == d1
    d0.close
    d1.close
    d0.should == d1
  end

  it "is not equal to things that aren't devices" do
    @device.close
    @deivce.should_not == Object.new
  end

  it "same_device_as? tells you whether two different Usb::Devices describe the same physical device" do
    # Assumption: The order of the devices returned by libusb is deterministic.
    d1 = @devices.first

    # TODO: implement contexts and change this to
    # d2 = Usb::Context.new.devices.first
    # d2.should_not == d1
    # Then this will be a better test of same_device_as?
    d2 = Usb::devices.first

    d1.should be_same_device_as d2
    d1.should_not be_same_device_as @devices[1]
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

  it "can convert bcd revision codes to strings" do
    Usb::Device.revision_bcd_to_string(0x0000).should == '0.00'
    Usb::Device.revision_bcd_to_string(0x0123).should == '1.23'
    Usb::Device.revision_bcd_to_string(0x9000).should == '90.00'
    Usb::Device.revision_bcd_to_string(0xFEDC).should == 'FE.DC'
    Usb::Device.revision_bcd_to_string(0x1234).should == '12.34'
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

  it "has some fields that aren't really needed" do
    dd = Usb::devices.first.device_descriptor
    dd.bLength.should == 18
    dd.bDescriptorType.should == 1
  end
end
