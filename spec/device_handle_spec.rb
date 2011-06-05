require_relative 'spec_helper'

describe Usb::DeviceHandle do
  it "is a class the represents an open handle to a device" do
    Usb::DeviceHandle.should be_a_kind_of Class
  end

  it "can not be created in Ruby" do
    lambda { Usb::DeviceHandle.new }.should raise_error NotImplementedError 
  end
end

