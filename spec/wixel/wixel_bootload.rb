$LOAD_PATH.unshift File.join File.dirname(__FILE__), '..', '..', 'lib'
$LOAD_PATH.unshift File.join File.dirname(__FILE__), '..', '..', 'ext'
require 'ruby-usb-pro'
require_relative 'wixel_usb_test'

WixelUsbTest.open do |wixel| 
  wixel.start_bootloader!
end

puts "Successfully put wixel in to bootloader mode."
