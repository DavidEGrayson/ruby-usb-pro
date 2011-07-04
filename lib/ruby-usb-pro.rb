# TODO: make .vendor_name function for devices using http://www.linux-usb.org/usb.ids
# TODO: make a descriptor parser for configuration descriptors

require 'ruby-usb-pro/errors'
require 'ruby-usb-pro/constants'
require 'ruby-usb-pro/context'
require 'ruby-usb-pro/device'
require 'ruby-usb-pro/device_handle'
require 'ruby-usb-pro/descriptors'
require 'rusb'

require 'ruby-usb-pro/class/cdc.rb'
