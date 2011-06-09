#include "ruby-usb-pro.h"

static VALUE cDevice;
static VALUE cDeviceDescriptor;

static VALUE eAccessDeniedError;
static VALUE eNoDeviceError;
static VALUE eNotFoundError;
static VALUE eBusyError;
static VALUE eTimeoutError;
static VALUE eOverflowError;
static VALUE ePipeError;
VALUE eClosedError;

/** Usb exceptions **********************************************************/

NORETURN(void raise_usb_exception(int error_code))
{
  switch(error_code)
  {
  case LIBUSB_ERROR_IO: rb_raise(rb_eIOError, "USB I/O Error");
	case LIBUSB_ERROR_INVALID_PARAM: rb_raise(rb_eArgError, "Invalid parameter passed to libusb.");
	case LIBUSB_ERROR_ACCESS: rb_raise(eAccessDeniedError, "Access denied to USB device.");
	case LIBUSB_ERROR_NO_DEVICE: rb_raise(eNoDeviceError, "No USB device.");
	case LIBUSB_ERROR_NOT_FOUND: rb_raise(eNotFoundError, "Entity Not Found.");
  case LIBUSB_ERROR_BUSY: rb_raise(eBusyError, "Busy.");
  case LIBUSB_ERROR_TIMEOUT: rb_raise(eTimeoutError, "USB operation timed out.");
  case LIBUSB_ERROR_OVERFLOW: rb_raise(eOverflowError, "Overflow.");
	case LIBUSB_ERROR_PIPE: rb_raise(ePipeError, "Pipe error.");
	case LIBUSB_ERROR_INTERRUPTED: rb_raise(rb_eInterrupt, "USB operation interrupted.");
	case LIBUSB_ERROR_NO_MEM: rb_raise(rb_eNoMemError, "No memory.");
  case LIBUSB_ERROR_NOT_SUPPORTED: rb_raise(rb_eNotImpError, "USB operation not supported.");
  case LIBUSB_ERROR_OTHER: rb_raise(rb_eException, "Libusb error code %d.", error_code);
	default: rb_raise(rb_eNotImpError, "tmphax"); // TODO: better error message		
  }
}

/** Usb::Context ************************************************************/

typedef struct context_wrapper
{
  libusb_context * context;
} context_wrapper;

static void context_free(void * p)
{
  context_wrapper * cw = p;
  if (cw->context)
  {
    libusb_exit(cw->context);
  }
  free(cw);
}

static VALUE context_alloc(VALUE klass)
{
	context_wrapper * cw = malloc(sizeof(context_wrapper));
  cw->context = NULL;
  return Data_Wrap_Struct(klass, 0, context_free, cw);
}

// TODO: allow copying of contexts.  Need to implement our own
// reference counting.
static VALUE context_disallow_copy(VALUE copy, VALUE orig)
{
  rb_raise(rb_eNotImpError, "Copying libusb contexts is not implemented.");
}

static VALUE context_initialize(VALUE self)
{
  context_wrapper * cw;
  Data_Get_Struct(self, context_wrapper, cw);
  int result = libusb_init(&cw->context);
  if (result < 0){ raise_usb_exception(result); }
	return self;
}

static void initialize_default_context_if_needed()
{
  static unsigned char tried = 0;
  if (!tried)
  {
		tried = 1;
    int result = libusb_init(NULL);
    if (result < 0){ raise_usb_exception(result); }
    //libusb_set_debug(NULL, 3);
  }
}

/** Usb::Device *************************************************************/

static void device_free(void * p)
{
  //printf("Unreffing device %p\n", p);
  libusb_unref_device(p);
}

static VALUE device_copy(VALUE copy, VALUE orig)
{
  if (copy == orig)
	{
		return copy;
	}

  libusb_device * device = (libusb_device *)(RDATA(orig)->data);
  if (device)
  {
    libusb_ref_device(device);
    RDATA(copy)->data = device;
  }
  RDATA(copy)->dmark = RDATA(orig)->dmark; // should be NULL
  RDATA(copy)->dfree = RDATA(orig)->dfree; // should be device_free
}

static VALUE get_device_list(int argc, VALUE * argv, VALUE self)
{
  VALUE oContext;
  libusb_context * context = NULL;
  rb_scan_args(argc, argv, "01", &oContext);
  if (NIL_P(oContext))
  {
		initialize_default_context_if_needed();
	}
	else
	{
    printf("context is given\n");
    context_wrapper * cw;
    Data_Get_Struct(oContext, context_wrapper, cw);
    context = cw->context;
	}

  // Get the list from libusb.
  libusb_device ** list;
  ssize_t size = libusb_get_device_list(context, &list);
  if (size < 0)
	{ 
		raise_usb_exception(size);
	}

  // Create a Ruby array of Usb::Devices.
  VALUE array = rb_ary_new2(size);
  for(int i = 0; i < size; i++)
  {
    VALUE oDevice = Data_Wrap_Struct(cDevice, 0, device_free, list[i]);
    rb_ary_push(array, oDevice);
	}

  // Free libusb's list.
  libusb_free_device_list(list, 0);

  return array;
}

libusb_device * device_extract(VALUE self)
{
  libusb_device * device;
  Data_Get_Struct(self, libusb_device, device);
  if (RDATA(self)->dfree != device_free)
  {
    rb_raise(rb_eTypeError, "Invalid type: expected a device.");
  }
  if (device == NULL)
  {
    rb_raise(eClosedError, "Device has been closed.");
  }
  return device;
}

static VALUE device_equal(VALUE self, VALUE other)
{
  // TODO: for == and ===, allow 'other' to be a subclass of Usb::Device
  // but keep the behavior of eql? the same
  return ( CLASS_OF(other) == cDevice && 
					 RDATA(self)->data == RDATA(other)->data ) ? Qtrue : Qfalse;
}

VALUE usb_object_closed(VALUE self)
{
  return RDATA(self)->data ? Qfalse : Qtrue;
}

static VALUE device_get_bus_number(VALUE self)
{
  return INT2FIX(libusb_get_bus_number(device_extract(self)));
}

static VALUE device_get_addess(VALUE self)
{
  return INT2FIX(libusb_get_device_address(device_extract(self)));
}

static VALUE device_get_max_packet_size(VALUE self, VALUE endpoint)
{
  // TODO: if this function simply uses libusb_get_device_rescriptor, implement it in ruby
  libusb_device * device = device_extract(self);
  int result = libusb_get_max_packet_size(device, NUM2INT(endpoint));
  if (result < 0){ raise_usb_exception(result); }
  return INT2FIX(result);
}

static VALUE device_get_max_iso_packet_size(VALUE self, VALUE endpoint)
{
  libusb_device * device = device_extract(self);
  int result = libusb_get_max_iso_packet_size(device, NUM2INT(endpoint));
  if (result < 0){ raise_usb_exception(result); }
  return INT2FIX(result);
}

static VALUE device_close(VALUE self)
{
  libusb_unref_device(device_extract(self));
  RDATA(self)->data = NULL;
  return Qnil;
}

static VALUE device_get_device_descriptor(VALUE self)
{
  struct libusb_device_descriptor desc;
  int result = libusb_get_device_descriptor(device_extract(self), &desc);
  if (result < 0){ raise_usb_exception(result); }

  VALUE args[14] = {
    INT2FIX(desc.bLength),
    INT2FIX(desc.bDescriptorType),
    INT2FIX(desc.bcdUSB),
    INT2FIX(desc.bDeviceClass),
    INT2FIX(desc.bDeviceSubClass),
    INT2FIX(desc.bDeviceProtocol),
    INT2FIX(desc.bMaxPacketSize0),
    INT2FIX(desc.idVendor),
    INT2FIX(desc.idProduct),
    INT2FIX(desc.bcdDevice),
    INT2FIX(desc.iManufacturer),
    INT2FIX(desc.iProduct),
    INT2FIX(desc.iSerialNumber),
    INT2FIX(desc.bNumConfigurations) };
  return rb_class_new_instance(14, args, cDeviceDescriptor);
}

void Init_rusb()
{
  VALUE mUsb = rb_const_get(rb_cObject, rb_intern("Usb"));
  rb_define_protected_method(rb_singleton_class(mUsb), "get_device_list", get_device_list, -1);

  eAccessDeniedError = rb_const_get(mUsb, rb_intern("AccessDeniedError"));
  eNoDeviceError = rb_const_get(mUsb, rb_intern("NoDeviceError"));
  eNotFoundError = rb_const_get(mUsb, rb_intern("NotFoundError"));
  eBusyError = rb_const_get(mUsb, rb_intern("BusyError"));
  eTimeoutError = rb_const_get(mUsb, rb_intern("TimeoutError"));
	eOverflowError = rb_const_get(mUsb, rb_intern("OverflowError"));
  ePipeError = rb_const_get(mUsb, rb_intern("PipeError"));
  eClosedError = rb_const_get(mUsb, rb_intern("ClosedError"));

  cDeviceDescriptor = rb_const_get(mUsb, rb_intern("DeviceDescriptor"));

  Init_device_handle();

  VALUE cContext = rb_const_get(mUsb, rb_intern("Context"));
  rb_define_alloc_func(cContext, context_alloc);
  rb_define_method(cContext, "initialize", context_initialize, 0);
  rb_define_method(cContext, "initialize_copy", context_disallow_copy, 1);

  cDevice = rb_const_get(mUsb, rb_intern("Device"));
  rb_define_method(cDevice, "bus_number", device_get_bus_number, 0); 
  rb_define_method(cDevice, "address", device_get_addess, 0);
	rb_define_method(cDevice, "max_packet_size", device_get_max_packet_size, 1);
	rb_define_method(cDevice, "max_iso_packet_size", device_get_max_iso_packet_size, 1);
  rb_define_method(cDevice, "initialize_copy", device_copy, 1);
  rb_define_method(cDevice, "close", device_close, 0);
  rb_define_method(cDevice, "closed?", usb_object_closed, 0);
  rb_define_method(cDevice, "get_device_descriptor", device_get_device_descriptor, 0);
  rb_define_method(cDevice, "eql?", device_equal, 1);
  rb_define_method(cDevice, "open_handle_core", dh_new, 0);
}
