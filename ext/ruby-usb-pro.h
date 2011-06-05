#ifndef _RUBY_USB_PRO_H
#define _RUBY_USB_PRO_H

#include <ruby.h>
#include <libusb-1.0/libusb.h>

libusb_device * device_extract(VALUE device);

VALUE dh_new(VALUE device);
NORETURN(void raise_usb_exception(int error_code));

#endif
