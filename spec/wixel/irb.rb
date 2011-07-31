#!/usr/bin/env ruby

# Runs irb so you can play around with the WixelUsbTest
# class interactively.
require 'irb'
require_relative File.join '..', 'spec_helper'
require_relative 'wixel_usb_test'
(w = WixelUsbTest.open) rescue puts "Unable to open handle to Wixel: #$!"
IRB.start __FILE__
