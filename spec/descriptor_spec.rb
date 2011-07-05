require_relative 'spec_helper'

wixel_config_descriptor = "\x09\x02\x43\x00\x02\x01\x00\xc0\x32\x09\x04\x00\x00\x01\x02\x02\x01\x00\x05\x24\x00\x20\x01\x04\x24\x02\x02\x05\x24\x06\x00\x01\x05\x24\x01\x00\x01\x07\x05\x81\x03\x0a\x00\x01\x09\x04\x01\x00\x02\x0a\x00\x00\x00\x07\x05\x04\x02\x40\x00\x00\x07\x05\x84\x02\x40\x00\x00"

describe Usb::Descriptors::Descriptor do
  it "is an abstract class" do
    Usb::Descriptors::Descriptor.should be_a_kind_of Class
    lambda { Usb::Descriptors::Descriptor.new }.should raise_error Exception
  end
end

describe Usb::Descriptors::Configuration do
  it "is a descriptor class" do
    Usb::Descriptors::Configuration.should be_a_kind_of Class
    Usb::Descriptors::Configuration.superclass.should == Usb::Descriptors::Descriptor
  end

  it "can be generated from binary" do
    cd = Usb::Descriptors::Configuration.from_binary(wixel_config_descriptor, Usb::Cdc::ClassCode)
    cd.should be_a_kind_of Usb::Descriptors::Configuration

    raise cd.inspect
  end
end

describe Usb::Descriptors::Interface do
  it "is a descriptor class" do
    Usb::Descriptors::Interface.should be_a_kind_of Class
    Usb::Descriptors::Interface.superclass.should == Usb::Descriptors::Descriptor
  end

  it "is has length 9 (bytes)" do
    Usb::Descriptors::Interface.length.should == 9
  end
end
