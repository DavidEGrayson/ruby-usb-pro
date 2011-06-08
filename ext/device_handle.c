#include "ruby-usb-pro.h"

static VALUE cDeviceHandle;
static VALUE symDevice;

static VALUE dh_initialize(VALUE self, VALUE device)
{
  libusb_device_handle * handle;
  int result = libusb_open(device_extract(device), &handle);
  if (result < 0){ raise_usb_exception(result); }

  RDATA(self)->data = handle;
  rb_ivar_set(self, symDevice, device);
  return self;
}

static void dh_free(void * p)
{
  if (p != NULL)
  {
    libusb_close(p);
  }
}

libusb_device_handle * dh_extract(VALUE self)
{
  libusb_device_handle * device;
  Data_Get_Struct(self, libusb_device_handle, device);
  if (RDATA(self)->dfree != dh_free)
  {
    rb_raise(rb_eTypeError, "Invalid type: expected a device handle.");
  }
  if (device == NULL)
  {
    rb_raise(eClosedError, "Device Handle has been closed.");
  }
  return device;
}

static VALUE dh_close(VALUE self)
{
  libusb_close(dh_extract(self));
  RDATA(self)->data = NULL;
  return Qnil;
}

static VALUE dh_alloc(VALUE klass)
{
  return Data_Wrap_Struct(klass, NULL, dh_free, NULL);
}

VALUE dh_new(VALUE device)
{
  return rb_class_new_instance(1, &device, cDeviceHandle);
}

static VALUE dh_equal(VALUE self, VALUE other)
{
  // TODO: for == and ===, allow 'other' to be a subclass of Usb::Device
  // but keep the behavior of eql? the same
  return ( CLASS_OF(other) == cDeviceHandle && 
					 RDATA(self)->data == RDATA(other)->data ) ? Qtrue : Qfalse;
}

void Init_device_handle()
{
  VALUE mUsb = rb_const_get(rb_cObject, rb_intern("Usb"));
  cDeviceHandle = rb_const_get(mUsb, rb_intern("DeviceHandle"));
  rb_define_alloc_func(cDeviceHandle, dh_alloc);
  rb_define_method(cDeviceHandle, "initialize", dh_initialize, 1);
  rb_define_method(cDeviceHandle, "close", dh_close, 0);
  rb_define_method(cDeviceHandle, "closed?", usb_object_closed, 0);
  rb_define_method(cDeviceHandle, "eql?", dh_equal, 1);
  symDevice = rb_intern("@device");
}
