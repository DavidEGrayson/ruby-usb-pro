require_relative 'my_test'

puts Libusb.inspect
puts Libusb::Context.inspect
context = Libusb::Context.new

