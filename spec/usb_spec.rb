require_relative 'spec_helper'

describe Usb do
  it "is a module" do
    Usb.class.should == Module
  end

  it "can list devices" do
    devices = Usb.get_device_list
    devices.size.should > 0
    devices.sort_by! { |device| [device.bus_number, device.address] }
    devices.each do |device|
      device.class.should == Usb::Device
      puts "#{device} #{device.bus_number} #{device.address}"
      lambda { device.max_packet_size(0) }.should raise_error Usb::NotFoundError
      lambda { device.max_packet_size(:foo) }.should raise_error TypeError
    end
  end
end
