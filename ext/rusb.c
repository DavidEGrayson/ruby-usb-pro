// /home/david/.rvm/src/ruby-1.9.2-p180/include/ruby.h
#include <ruby.h>
#include <libusb-1.0/libusb.h>

static VALUE cDevice;

static VALUE eAccessDeniedError;
static VALUE eNoDeviceError;
static VALUE eNotFoundError;
static VALUE eBusyError;
static VALUE eTimeoutError;
static VALUE eOverflowError;
static VALUE ePipeError;

/** Libusb exceptions **********************************************************/

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
	default: rb_raise(rb_eNotImpError, "tmphax");		
  }
}

/** Libusb::Context ************************************************************/

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
  }
}

/** Libusb::Device *************************************************************/

static void device_free(void * p)
{
  printf("Unreffing device %p\n", p); //tmphax
  libusb_unref_device(p);
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

  // Create a Ruby array of Libusb::Devices.
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

VALUE get_bus_number(VALUE self)
{
  libusb_device * device;
  Data_Get_Struct(self, libusb_device, device);
  return INT2FIX(libusb_get_bus_number(device));
}

VALUE get_device_addess(VALUE self)
{
  libusb_device * device;
  Data_Get_Struct(self, libusb_device, device);
  return INT2FIX(libusb_get_device_address(device));
}

VALUE get_max_packet_size(VALUE self, VALUE oEndpoint)
{
  libusb_device * device;
  Data_Get_Struct(self, libusb_device, device); 
  int result = libusb_get_max_packet_size(device, NUM2INT(oEndpoint));
  if (result < 0){ raise_usb_exception(result); }
  return INT2FIX(result);
}

void Init_rusb()
{
  VALUE mLibusb = rb_define_module("Libusb");
  rb_define_singleton_method(mLibusb, "get_device_list", get_device_list, -1); 

  eAccessDeniedError = rb_define_class_under(mLibusb, "AccessDeniedError", rb_eException);
  eNoDeviceError = rb_define_class_under(mLibusb, "NoDeviceError", rb_eException);
  eNotFoundError = rb_define_class_under(mLibusb, "NotFoundError", rb_eException);
  eBusyError = rb_define_class_under(mLibusb, "BusyError", rb_eException);
  eTimeoutError = rb_define_class_under(mLibusb, "TimeoutError", rb_eException);
	eOverflowError = rb_define_class_under(mLibusb, "OverflowError", rb_eException);
  ePipeError = rb_define_class_under(mLibusb, "PipeError", rb_eException);

  VALUE cContext = rb_define_class_under(mLibusb, "Context", rb_cObject);
  rb_define_alloc_func(cContext, context_alloc);
  rb_define_method(cContext, "initialize", context_initialize, 0);
  rb_define_method(cContext, "initialize_copy", context_disallow_copy, 1);

  cDevice = rb_define_class_under(mLibusb, "Device", rb_cObject);
  rb_define_method(cDevice, "bus_number", get_bus_number, 0); 
  rb_define_method(cDevice, "address", get_device_addess, 0);
	rb_define_method(cDevice, "max_packet_size", get_max_packet_size, 1);
}
