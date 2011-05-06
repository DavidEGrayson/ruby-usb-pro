#!/usr/bin/env ruby
require_relative 'rusb'

Libusb.get_device_list.each do |device|
  puts "#{device} #{device.bus_number} #{device.address}"
  puts device.max_packet_size(1)
end

