// /home/david/.rvm/src/ruby-1.9.2-p180/include/ruby.h
#include <ruby.h>
#include <libusb-1.0/libusb.h>

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
  // TODO: throw exception here if result != 0
	return self;
}

/** Libusb::Device *************************************************************/

VALUE get_device_list(int argc, VALUE * argv, VALUE self)
{
  VALUE oContext;
  libusb_context * context = NULL;
  rb_scan_args(argc, argv, "01", &oContext);
  if (!NIL_P(oContext))
	{
    printf("context is given\n");
    context_wrapper * cw;
    Data_Get_Struct(oContext, context_wrapper, cw);
    context = cw->context;
	}

  libusb_device ** list;
  ssize_t size = libusb_get_device_list(context, &list);
	// TODO: detect errors

  return INT2NUM(size);
}

void Init_rusb()
{
  VALUE mLibusb = rb_define_module("Libusb");
  rb_define_singleton_method(mLibusb, "get_device_list", get_device_list, -1); 

  VALUE cContext = rb_define_class_under(mLibusb, "Context", rb_cObject);
  rb_define_alloc_func(cContext, context_alloc);
  rb_define_method(cContext, "initialize", context_initialize, 0);
  rb_define_method(cContext, "initialize_copy", context_disallow_copy, 1);

  VALUE cDevice = rb_define_class_under(mLibusb, "Device", rb_cObject);
  

}
