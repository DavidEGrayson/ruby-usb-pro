require 'rubygems'
require 'ruby-usb-pro'

Usb::devices.sort_by { |d| [-d.bus_number, -d.address] }.each do |dev|
  puts "Bus %03d Device %03d: ID %04x:%04x" % [dev.bus_number, dev.address, dev.vendor_id, dev.product_id]
end
