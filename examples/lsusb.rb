require 'rubygems'
require 'ruby-usb-pro'

def print_descriptors(desc, indent='')
  puts indent + desc.class.name
  desc.children.each do |child|
    print_descriptors child, indent + '  '
  end
end

Usb::devices.sort_by { |d| [-d.bus_number, -d.address] }.each do |dev|
  puts "Bus %03d Device %03d: ID %04x:%04x" % [dev.bus_number, dev.address, dev.vendor_id, dev.product_id]
end

#wixel_config_descriptor = "\x09\x02\x43\x00\x02\x01\x00\xc0\x32\x09\x04\x00\x00\x01\x02\x02\x01\x00\x05\x24\x00\x20\x01\x04\x24\x02\x02\x05\x24\x06\x00\x01\x05\x24\x01\x00\x01\x07\x05\x81\x03\x0a\x00\x01\x09\x04\x01\x00\x02\x0a\x00\x00\x00\x07\x05\x04\x02\x40\x00\x00\x07\x05\x84\x02\x40\x00\x00"
#cd = Usb::Descriptors::Configuration.from_binary wixel_config_descriptor, Usb::Cdc::ClassCode
#print_descriptors cd

