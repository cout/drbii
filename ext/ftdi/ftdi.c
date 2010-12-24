#include <ftdi.h>
#include <ruby.h>

static VALUE rb_mFtdi;
static VALUE rb_cFtdi_Context;

static void check_ftdi_result(struct ftdi_context * ctx, int result)
{
  if (result < 0)
  {
    char * error_string = ftdi_get_error_string(ctx);
    rb_raise(rb_eRuntimeError, "ftdi error: %s", error_string);
  }
}

static VALUE ftdi_context_s_new(VALUE klass)
{
  /* TODO: not exception-safe */
  /* TODO: check for null return value */
  /* TODO: need to call init? */
  struct ftdi_context * ctx = ftdi_new();
  VALUE v_ctx = Data_Wrap_Struct(rb_cFtdi_Context, 0, ftdi_free, ctx);

  return v_ctx;
}

static VALUE ftdi_context_open(VALUE self, VALUE v_desc)
{
  struct ftdi_context * ctx;
  char const * desc;
  int result;

  Data_Get_Struct(self, struct ftdi_context, ctx);
  desc = StringValuePtr(v_desc);

  result = ftdi_usb_open_string(ctx, desc);
  check_ftdi_result(ctx, result);

  return Qnil;
}

static VALUE ftdi_context_set_baudrate(VALUE self, VALUE v_baud)
{
  struct ftdi_context * ctx;
  int baud = NUM2INT(v_baud);
  int result;

  Data_Get_Struct(self, struct ftdi_context, ctx);

  result = ftdi_set_baudrate(ctx, baud);
  check_ftdi_result(ctx, result);

  return Qnil;
}

static VALUE ftdi_context_set_bitmode(VALUE self, VALUE v_bitmask, VALUE v_mode)
{
  struct ftdi_context * ctx;
  unsigned char bitmask = NUM2INT(v_bitmask);
  unsigned char mode = NUM2INT(v_mode);
  int result;

  Data_Get_Struct(self, struct ftdi_context, ctx);

  result = ftdi_set_bitmode(ctx, bitmask, mode);
  check_ftdi_result(ctx, result);

  return Qnil;
}

static VALUE ftdi_context_read_data(VALUE self, VALUE v_size)
{
  struct ftdi_context * ctx;
  int size = NUM2INT(v_size);
  VALUE v_buf = rb_str_buf_new(size);
  char * buf = StringValuePtr(v_buf);
  int result;

  Data_Get_Struct(self, struct ftdi_context, ctx);

  result = ftdi_read_data(ctx, (unsigned char *)buf, size);
  check_ftdi_result(ctx, result);

  RSTRING(v_buf)->len = result;

  return Qnil;
}

static VALUE ftdi_context_write_data(VALUE self, VALUE v_str)
{
  struct ftdi_context * ctx;
  char * buf = StringValuePtr(v_str);
  int size = RSTRING(v_str)->len;
  int result;

  Data_Get_Struct(self, struct ftdi_context, ctx);

  result = ftdi_write_data(ctx, (unsigned char *)buf, size);
  check_ftdi_result(ctx, result);

  return Qnil;
}

void Init_ftdi()
{
  rb_mFtdi = rb_define_module("Ftdi");

  rb_cFtdi_Context = rb_define_class_under(rb_mFtdi, "Context", rb_cObject);
  rb_define_singleton_method(rb_cFtdi_Context, "new", ftdi_context_s_new, 0);
  rb_define_method(rb_cFtdi_Context, "open", ftdi_context_open, 1);
  rb_define_method(rb_cFtdi_Context, "baudrate=", ftdi_context_set_baudrate, 1);
  rb_define_method(rb_cFtdi_Context, "set_bitmode", ftdi_context_set_bitmode, 2);
  rb_define_method(rb_cFtdi_Context, "read_data", ftdi_context_read_data, 1);
  rb_define_method(rb_cFtdi_Context, "write_data", ftdi_context_write_data, 1);

  rb_define_const(rb_mFtdi, "BITMODE_RESET", INT2NUM(BITMODE_RESET));
  rb_define_const(rb_mFtdi, "BITMODE_BITBANG", INT2NUM(BITMODE_BITBANG));
  rb_define_const(rb_mFtdi, "BITMODE_MPSSE", INT2NUM(BITMODE_MPSSE));
  rb_define_const(rb_mFtdi, "BITMODE_SYNCBB", INT2NUM(BITMODE_SYNCBB));
  rb_define_const(rb_mFtdi, "BITMODE_MCU", INT2NUM(BITMODE_MCU));
  rb_define_const(rb_mFtdi, "BITMODE_OPTO", INT2NUM(BITMODE_OPTO));
  rb_define_const(rb_mFtdi, "BITMODE_CBUS", INT2NUM(BITMODE_CBUS));
  rb_define_const(rb_mFtdi, "BITMODE_SYNCFF", INT2NUM(BITMODE_SYNCFF));

  rb_define_const(rb_mFtdi, "INTERFACE_ANY", INT2NUM(INTERFACE_ANY));
  rb_define_const(rb_mFtdi, "INTERFACE_A", INT2NUM(INTERFACE_A));
  rb_define_const(rb_mFtdi, "INTERFACE_B", INT2NUM(INTERFACE_B));
  rb_define_const(rb_mFtdi, "INTERFACE_C", INT2NUM(INTERFACE_C));
  rb_define_const(rb_mFtdi, "INTERFACE_D", INT2NUM(INTERFACE_D));
}

