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

  it "can be opened with a block" do
    wixel_local = nil
    WixelUsbTest.open do |wixel|
      wixel.blink_period = 199
      wixel.blink_period.should == 199
      wixel_local = wixel
      "success"
    end.should == "success"
    wixel_local.should be_closed
  end

  it "devices can be listed" do
    devices = WixelUsbTest.devices
    devices.should include $wixel_device

    pending "implementation of UsbDevice#serial_number"
    WixelUsbTest.devices(:serial_number => $wixel_device.serial_number).should == [$wixel_device]
  end

  it "has a device function which always returns a single device" do
    WixelUsbTest.device.should == $wixel_device
  end

  it "can set and get the blink period" do
    @wixel.blink_period = 200
    @wixel.blink_period.should == 200
    @wixel.blink_period = 400
    @wixel.blink_period.should == 400
  end

  it "can get and set the name" do
    @wixel.name = ""
    @wixel.name.should == ""

    @wixel.name = "Peter"
    @wixel.name.should == "Peter"
  end

  it "max name length is 255" do
    lambda { @wixel.name = "x"*256 }.should raise_error Usb::PipeError
    @wixel.name.should == "Peter"
    
    strange_name = "\x00"*255
    @wixel.name = strange_name
    @wixel.name.should == strange_name
  end

end if $wixel_device
