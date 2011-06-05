require_relative 'spec_helper'

# To run this spec, you must have at least one USB device connected
# to the computer that you have permission to open.

describe Usb::DeviceHandle do
  before(:each) do
    # Find a device that we have permission to open, and open a handle.
    catch :found_device do
      # Devies we have permission to open tend to have higher addresses,
      # so try them in reverse order by address.
      Usb.devices.sort_by{|d| d.address}.reverse.each do |device|
        begin
          @handle = device.open_handle
          @device = device
          throw :found_device
        rescue Usb::AccessDeniedError
          puts "Access denied to #{@device}."
        end
      end
      flunk "Unable to open any USB devices: permission denied."
    end
  end

  it "is a class that represents an open handle to a device" do
    Usb::DeviceHandle.should be_a_kind_of Class
  end

  it "holds a reference to the device" do
    @handle.should be_a_kind_of Usb::DeviceHandle
    puts @handle.instance_variables.inspect
    puts "??: " + @handle.device.inspect
    (@handle.device == @device).should be_true
    @handle.device.should be_equal @device
  end

  it "can be created from a Usb::Device" do
    Usb::DeviceHandle.open(@device).should be_a_kind_of Usb::DeviceHandle
    Usb::DeviceHandle.new(@device).should be_a_kind_of Usb::DeviceHandle
  end

  it "can be used in a block to guarantee that it gets closed sooner" do
    Usb::DeviceHandle.open(@device) do |handle|
      handle.should be_a_kind_of Usb::DeviceHandle
    end

    @device.open_handle do |handle|
      handle.should be_a_kind_of Usb::DeviceHandle
    end
  end

  it "can be closed" do
    @handle.should_not be_closed
    @handle.close
    @handle.should be_closed
  end

  it "should not be used after it is closed" do
    @handle.close
    # TODO: call some functions and show them crashing, e.g.:
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
    @handle.should_not == @device
  end

end

