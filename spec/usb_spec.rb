require_relative 'spec_helper'

describe Libusb do
  it "can list devices" do
    devices = Libusb.get_device_list
    devices.size.should > 0
    devices.each do |device|
      puts "#{device} #{device.bus_number} #{device.address}"
      #puts device.max_packet_size(1)
    end
  end
end
