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
    cd = Usb::Descriptors::Configuration.from_binary wixel_config_descriptor, Usb::Cdc::ClassCode
    cd.should be_a_kind_of Usb::Descriptors::Configuration

    # https://github.com/pololu/wixel-sdk/blob/3601f299c7dd38ab2a9e0ec93451e82aeeeabb46/libraries/src/usb_cdc_acm/usb_cdc_acm.c#L127

    # Configuration
    cd.bLength.should == 9
    cd.bDescriptorType.should == Usb::DescriptorTypes::Configuration
    cd.wTotalLength.should == wixel_config_descriptor.length
    cd.bNumInterfaces.should == 2
    cd.bConfigurationValue.should == 1
    cd.iConfiguration.should == 0
    cd.bmAttributes.should == 0xC0
    cd.should be_self_powered
    cd.should_not be_remote_wakeup
    cd.bMaxPower.should == 50
    cd.children.length.should == 2

    # Communications Interface
    comm = cd.children[0]
    comm.should be_a_kind_of Usb::Descriptors::Interface
    comm.should be cd.interfaces[0]
    comm.should be cd.descendents[0]
    comm.bLength.should == 9
    comm.bDescriptorType.should == Usb::DescriptorTypes::Interface
    comm.bInterfaceNumber.should == 0
    comm.bAlternateSetting.should == 0
    comm.bNumEndpoints.should == 1
    comm.bInterfaceClass.should == Usb::Cdc::ClassCode
    comm.bInterfaceSubClass.should == Usb::Cdc::SubclassCodes::AbstractControlModel
    comm.iInterface.should == 0
    comm.children.length.should == 5

    # Header Functional Descriptor
    comm.children[0].should be_a_kind_of Usb::Cdc::HeaderDescriptor
    comm.children[0].instance_eval do
      bLength.should == 5
      bDescriptorType.should == Usb::DescriptorTypes::Interface | 0x20
      bDescriptorSubtype.should == Usb::Cdc::HeaderDescriptor.descriptor_subtype_code
      bcdCDC.should == 0x120
    end

    
    
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

  it "can be a child of a configuration descriptor" do
    intf = Usb::Descriptors::Interface.new
    cd = Usb::Descriptors::Configuration.new
    intf.should be_can_be_child_of cd
  end
end
