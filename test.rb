$LOAD_PATH.unshift File.join File.dirname(__FILE__), 'lib'
$LOAD_PATH.unshift File.join File.dirname(__FILE__), 'ext'
$LOAD_PATH.unshift File.dirname(__FILE__)
require 'ruby-usb-pro'
require_relative 'spec/wixel_usb_test'

puts "hi"
wixel = WixelUsbTest.new(WixelUsbTest.devices.first)
puts wixel.blink_period
wixel.start_bootloader!
