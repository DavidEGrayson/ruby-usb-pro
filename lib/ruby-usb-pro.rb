# TODO: make .vendor_name function for devices using http://www.linux-usb.org/usb.ids

require 'ruby-usb-pro/errors'
require 'ruby-usb-pro/context'
require 'ruby-usb-pro/device_descriptor'
require 'ruby-usb-pro/device'
require 'ruby-usb-pro/device_handle'
require 'rusb'  # This native extension must be required last.
