#include "ruby-usb-pro.h"

static VALUE cDeviceHandle;

VALUE dh_new(VALUE device)
{
  libusb_device_handle * handle;
  int result = libusb_open(device_extract(device), &handle);
  if (result < 0){ raise_usb_exception(result); }

  VALUE oHandle = Data_Wrap_Struct(cDeviceHandle, 0, libusb_close, handle);
  rb_iv_set(oHandle, "device", device);
  printf("Setting the instance variable device\n");
  printf("Success? %d\n", rb_ivar_defined(oHandle, rb_intern("device")));
  return oHandle;
}

void Init_device_handle()
{
  VALUE mUsb = rb_const_get(rb_cObject, rb_intern("Usb"));
  cDeviceHandle = rb_const_get(mUsb, rb_intern("DeviceHandle"));
}
