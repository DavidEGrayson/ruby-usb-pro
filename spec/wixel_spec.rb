require_relative 'spec_helper'

# To run this spec, you must have a Wixel running the
# test_usb app connected to the computer.

$wixel_device = Usb.devices(:vendor_id => 0x1FFB, :product_id => 0x22FF).first

if $wixel_device.nil?
  puts "WARNING: wixel_spec.rb can not run because no Wixel running the test_usb app was found."
end

class WixelUsbTest
  attr_accessor :handle
  def initialize(usb_device)
    @handle = usb_device.open_handle
  end

  def blink_period
    handle.control_read_transfer(0xC0, 1, 0, 0, 2).unpack('v')[0]
  end

  def blink_period=(period)
    handle.control_write_transfer(0x40, 1, period, 0, 0)
  end

  def close
    handle.close
  end
end

describe WixelUsbTest do
  before(:each) do
    @wixel = WixelUsbTest.new($wixel_device)
  end

  it "can set and get the blink period" do
    @wixel.blink_period.should == 1000
  end
end if $wixel_device
