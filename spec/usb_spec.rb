require_relative 'spec_helper'

describe Usb do
  it "is a module" do
    Usb.should be_a_kind_of Module
  end

  it "can list devices" do
    devices = Usb.get_device_list
    devices.size.should > 0
    devices.each do |device|
      device.should be_a_kind_of Usb::Device
      device.bus_number.should be_between 0, 20
      device.address.should be_between 0, 127
    end
  end
end

describe Usb::Context do
  it "is a class" do
    Usb::Context.should be_a_kind_of Class
  end
end

describe Usb::Device do
  before do
    @device = Usb::get_device_list.last
  end

  it "can be safely duplicated" do
    GC.start
    c1 = GC.count

    # The duplicated object works.
    @device.dup.address.should be_between 0, 127

    # The duplicated object gets garbage collected.
    GC.start; (GC.count - c1).should == 1

    # But the original object still works.
    @device.address.should be_between 0, 127

    # Another duplicated object works.
    d2 = @device.clone
    d2.address.should be_between 0, 127

    # We can throw away the original.
    @device = nil
    GC.start; (GC.count - c1).should == 2

    # But the duplicated one still works.
    d2.address.should be_between 0, 127            
  end
end



describe "Usb::Device#max_packet_size" do
  before do
    @device = Usb::get_device_list.last
  end

  it "makes sure its argument is an int" do
    lambda { @device.max_packet_size(2**64) }.should raise_error RangeError
    lambda { @device.max_packet_size(:foo) }.should raise_error TypeError
  end

  it "doesn't actually work" do
    # TODO: why doesn't max_packet_size work?
    lambda { @device.max_packet_size(0) }.should raise_error Usb::NotFoundError
  end
end
