#!/usr/bin/env ruby
require 'helper'
require_relative '../lib/ruby-usb-pro'

class TestUsb < Test::Unit::TestCase
  should "be able to list devices" do
    Libusb.get_device_list.each do |device|
      puts "#{device} #{device.bus_number} #{device.address}"
      #puts device.max_packet_size(1)
    end
  end
end



