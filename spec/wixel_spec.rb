require_relative 'spec_helper'
require_relative 'wixel/wixel_usb_test'

# To run this spec, you must have a Wixel running the
# test_usb app connected to the computer.

$wixel_device = WixelUsbTest.devices.first

if $wixel_device.nil?
  puts "WARNING: wixel_spec.rb can not run because no Wixel running the test_usb app was found."
end

describe WixelUsbTest do
  before(:each) do
    @wixel = WixelUsbTest.new($wixel_device)
  end

  it "can set and get the blink period" do
    @wixel.blink_period = 200
    @wixel.blink_period.should == 200
  end

end if $wixel_device
