require_relative 'spec_helper'

describe Usb do
  it "is a module" do
    Usb.should be_a_kind_of Module
  end

  it "can list devices" do
    devices = Usb.devices
    devices.size.should > 1
    devices.each do |device|
      device.should be_a_kind_of Usb::Device
    end
  end

  it "can list devices by certain criteria" do
    all_devices = Usb.devices
    device = all_devices.first
    vendor_id = device.vendor_id
    devices = all_devices.select { |d| d.vendor_id == vendor_id }
    devices.size.should > 0
    Usb.devices(:vendor_id => vendor_id).should == devices

    product_id = device.vendor_id
    devices.select! { |d| d.product_id == product_id }
    Usb.devices(:vendor_id => vendor_id, :product_id => product_id).should == devices

    revision = device.revision
    devices.select! { |d| d.revision == revision }
    Usb.devices(:vendor_id => vendor_id, :product_id => product_id, :revision=>revision).should == devices

    Usb.devices(:vendor_id => vendor_id, :product_id => product_id, :revision=>revision).should == devices
  end

  it "should not have a public get_device_list function" do
    lambda { Usb.get_device_list }.should raise_error NoMethodError
  end
end

