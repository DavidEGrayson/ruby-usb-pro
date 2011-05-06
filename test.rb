#!/usr/bin/env ruby
require_relative 'rusb'

puts Libusb.inspect
puts Libusb::Context.inspect
context = Libusb::Context.new
Libusb.get_device_list(context)
list = Libusb.get_device_list
puts list.inspect
