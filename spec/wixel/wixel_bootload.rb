$LOAD_PATH.unshift File.join File.dirname(__FILE__), '..', '..', 'lib'
$LOAD_PATH.unshift File.join File.dirname(__FILE__), '..', '..', 'ext'
require 'ruby-usb-pro'
require_relative 'wixel_usb_test'

wixel = WixelUsbTest.new(WixelUsbTest.devices.first)
wixel.start_bootloader!
puts "Successfully put wixel in to bootloader mode."
