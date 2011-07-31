require_relative 'spec_helper'

# To run this spec, you must have at least one USB device connected
# to the computer that you have permission to open.

# Find a device that we have permission to open, and open a handle.
catch :found_device do
  # Devices we have permission to open tend to have higher addresses,
  # so try them in reverse order by address.
  Usb.devices.sort_by{|d| d.address}.reverse.each do |device|
    begin
      device.open_handle
      $openable_device = device
    throw :found_device
      rescue Usb::AccessDeniedError
    end
  end
  puts "WARNING: device_handle_spec.rb can not run because permission is denied to open any of the USB devices connected."
end

describe Usb::DeviceHandle do
  before(:each) do
    @handle = $openable_device.open_handle
  end

  it "is a class that represents an open handle to a device" do
    Usb::DeviceHandle.should be_a_kind_of Class
  end

  it "can only be tested if you have permission to open a connected USB device, such as a Pololu Wixel" do
    @handle.should_not be_nil
  end

  it "holds a reference to the device" do
    @handle.device.should be $openable_device
  end

  it "can be created from a Usb::Device" do
    h1 = Usb::DeviceHandle.open($openable_device)
    h1.should be_a_kind_of Usb::DeviceHandle
    h1.should_not be_closed
    h2 = Usb::DeviceHandle.new($openable_device)
    h2.should be_a_kind_of Usb::DeviceHandle
    h2.should_not be_closed
  end

  it "can be closed" do
    @handle.should_not be_closed
    @handle.close
    @handle.should be_closed
  end

  # This behavior is the same as Ruby's built-in File class."
  it "should not be used after it is closed" do
    @handle.close
    lambda { @handle.lang_ids }.should raise_error Usb::ClosedError
  end

  it "can not be closed twice" do
    @handle.close
    lambda { @handle.close }.should raise_error Usb::ClosedError
  end

  it "is ok to close the duplicates" do
    @handle.dup.close
    lambda { @handle.lang_ids }.should_not raise_error
  end

  it "is ok to close the original (it is not special)" do
    h2 = @handle.dup
    @handle.close
    lambda { h2.lang_ids }.should_not raise_error
  end

  it "is ok to close and then duplicate" do
    @handle.close
    @handle.dup.should be_closed
  end

  it "is not equal to its duplicates because duplicating opens a new libusb_device_handle" do
    h2 = @handle.dup
    (@handle == h2).should be false
    (@handle === h2).should be false
    (@handle.eql? h2).should be false
    (@handle.equal? h2).should be false
  end

  it "all closed handles are equal" do
    h0 = @handle
    h1 = @handle.dup
    h0.should_not == h1
    h0.close
    h1.close
    h0.should == h1
  end

  it "is not equal to things that aren't handles" do
    @handle.should_not == $openable_device
  end

  it "can be used in a block to guarantee that it gets closed sooner" do
    t = false
    h = $openable_device.open_handle do |handle|
      t = true
      handle.should be_a_kind_of Usb::DeviceHandle
      handle
    end
    t.should be true
    h.should be_closed

    t = false
    h = Usb::DeviceHandle.open $openable_device do |handle|
      t = true
      handle.should be_a_kind_of Usb::DeviceHandle
      handle
    end
    t.should be true
    h.should be_closed
  end

  it "can get a list of language ids" do
    lang_ids = @handle.lang_ids
    lang_ids.should be_a_kind_of Array
    lang_ids.first.should be_a_kind_of Fixnum
  end

  it "can get string descriptors as UTF-16LE strings" do
    str = @handle.string_descriptor(1)
    str.should be_a_kind_of String
    str.encoding.should == Encoding::UTF_16LE
  end

  it "can get string descriptors of a particular language" do
    @handle.string_descriptor(1, Usb::LangIds::English_US)
  end

  it "fails correctly" do
    lambda { @handle.string_descriptor(99) }.should raise_error Usb::PipeError
  end

  it "can get the configuration descriptor as binary" do
    cdb = @handle.configuration_descriptor_binary(0)
    cdb.should be_a_kind_of String
    cdb.encoding.should be Encoding::ASCII_8BIT if cdb.respond_to?(:encoding)
    cdb.length.should == cdb.unpack("xxv")[0]
  end

  it "can get the configuration descriptor as binary" do
    cd = @handle.configuration_descriptor(0)
    cd.should be_a_kind_of Usb::Descriptors::Configuration
  end

end if $openable_device
