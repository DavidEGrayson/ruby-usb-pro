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
      device.bus_number.should be_between 0, 20
      device.address.should be_between 0, 127
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
    @device = Usb::get_device_list.last
  end

  it "can be closed" do
    @device.should_not be_closed
    @device.close
    @device.should be_closed
  end

  it "can also be closed with the unref method" do
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
end

describe "Usb::Device#max_packet_size" do
  before :each do
    @device = Usb::get_device_list.last
  end

  it "makes sure its argument is an int" do
    lambda { @device.max_packet_size(2**64) }.should raise_error RangeError
    lambda { @device.max_packet_size(:foo) }.should raise_error TypeError
  end

  it "doesn't actually work" do
    # TODO: why doesn't max_packet_size work?
    lambda { @device.max_packet_size(0) }.should raise_error Usb::NotFoundError
  end
end




