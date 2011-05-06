// /home/david/.rvm/src/ruby-1.9.2-p180/include/ruby.h
#include <ruby.h>
#include <libusb-1.0/libusb.h>

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

void Init_my_test()
{
  VALUE mLibusb = rb_define_module("Libusb");
  VALUE cContext = rb_define_class_under(mLibusb, "Context", rb_cObject);
  rb_define_alloc_func(cContext, context_alloc);
  rb_define_method(cContext, "initialize", context_initialize, 0);
  rb_define_method(cContext, "initialize_copy", context_disallow_copy, 1);
}
