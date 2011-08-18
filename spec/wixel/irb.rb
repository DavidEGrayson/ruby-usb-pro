#!/usr/bin/env ruby

# Runs irb so you can play around with the WixelUsbTest
# class interactively.
require 'irb'
require_relative File.join '..', 'spec_helper'
require_relative 'wixel_usb_test'

begin
  @w = WixelUsbTest.open
  class << self; attr_accessor :w; end
  puts "Handle to Wixel has been opened.  Type 'w' to access it."
rescue Exception
  puts "Unable to open Wixel: #$!"
end
IRB.start __FILE__

