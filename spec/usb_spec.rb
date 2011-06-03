require_relative 'spec_helper'

describe Usb do
  it "is a module" do
    Usb.should be_a_kind_of Module
  end

  it "can list devices" do
    devices = Usb.get_device_list
    devices.size.should > 1
    devices.sort_by! { |device| [device.bus_number, device.address] }
    devices.each do |device|
      device.should be_a_kind_of Usb::Device
      device.bus_number.should be_between 0, 20
      device.address.should be_between 0, 127
    end
  end
end

describe "Usb::Device#max_packet_size" do
  before do
    @device = Usb::get_device_list.first
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
