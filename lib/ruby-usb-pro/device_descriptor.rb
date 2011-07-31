# USB Device Descriptor.
# These fields are documented in Table 9-8 in the USB Specification 2.0.
class Usb::DeviceDescriptor < Struct.new(:bLength, :bDescriptorType,
  :bcdUSB, :bDeviceClass, :bDeviceSubClass, :bDeviceProtocol,
  :bMaxPacketSize0, :idVendor, :idProduct, :bcdDevice,
  :iManufacturer, :iProduct, :iSerialNumber, :bNumConfigurations)

end
