#include <ftdi.h>
#include <ruby.h>

static VALUE rb_mFtdiCC;
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

  struct ftdi_context * ctx = ftdi_new();

  if (ctx == 0)
  {
    rb_raise(rb_eRuntimeError, "unable to create ftdi context");
  }
 
  return Data_Wrap_Struct(rb_cFtdi_Context, 0, ftdi_free, ctx);
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

static VALUE ftdi_context_close(VALUE self)
{
  struct ftdi_context * ctx;
  int result;

  Data_Get_Struct(self, struct ftdi_context, ctx);

  result = ftdi_usb_close(ctx);
  check_ftdi_result(ctx, result);

  return Qnil;
}

static VALUE ftdi_context_type(VALUE self)
{
  struct ftdi_context * ctx;

  Data_Get_Struct(self, struct ftdi_context, ctx);

  return INT2NUM(ctx->type);

}

static VALUE ftdi_context_chipid(VALUE self)
{
  struct ftdi_context * ctx;
  int result;
  unsigned int chipid;

  Data_Get_Struct(self, struct ftdi_context, ctx);
  result = ftdi_read_chipid(ctx, &chipid);
  check_ftdi_result(ctx, result);

  return UINT2NUM(chipid);

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
  rb_mFtdiC = rb_define_module("FtdiC");

  rb_cFtdi_Context = rb_define_class_under(rb_mFtdiC, "Context", rb_cObject);
  rb_define_singleton_method(rb_cFtdi_Context, "new", ftdi_context_s_new, 0);
  rb_define_method(rb_cFtdi_Context, "open", ftdi_context_open, 1);
  rb_define_method(rb_cFtdi_Context, "close", ftdi_context_close, 0);
  rb_define_method(rb_cFtdi_Context, "type", ftdi_context_type, 0);
  rb_define_method(rb_cFtdi_Context, "chipid", ftdi_context_chipid, 0);
  rb_define_method(rb_cFtdi_Context, "baudrate=", ftdi_context_set_baudrate, 1);
  rb_define_method(rb_cFtdi_Context, "set_bitmode", ftdi_context_set_bitmode, 2);
  rb_define_method(rb_cFtdi_Context, "read_data", ftdi_context_read_data, 1);
  rb_define_method(rb_cFtdi_Context, "write_data", ftdi_context_write_data, 1);

  rb_define_const(rb_mFtdiC, "BITMODE_RESET", INT2NUM(BITMODE_RESET));
  rb_define_const(rb_mFtdiC, "BITMODE_BITBANG", INT2NUM(BITMODE_BITBANG));
  rb_define_const(rb_mFtdiC, "BITMODE_MPSSE", INT2NUM(BITMODE_MPSSE));
  rb_define_const(rb_mFtdiC, "BITMODE_SYNCBB", INT2NUM(BITMODE_SYNCBB));
  rb_define_const(rb_mFtdiC, "BITMODE_MCU", INT2NUM(BITMODE_MCU));
  rb_define_const(rb_mFtdiC, "BITMODE_OPTO", INT2NUM(BITMODE_OPTO));
  rb_define_const(rb_mFtdiC, "BITMODE_CBUS", INT2NUM(BITMODE_CBUS));
  rb_define_const(rb_mFtdiC, "BITMODE_SYNCFF", INT2NUM(BITMODE_SYNCFF));

  rb_define_const(rb_mFtdiC, "INTERFACE_ANY", INT2NUM(INTERFACE_ANY));
  rb_define_const(rb_mFtdiC, "INTERFACE_A", INT2NUM(INTERFACE_A));
  rb_define_const(rb_mFtdiC, "INTERFACE_B", INT2NUM(INTERFACE_B));
  rb_define_const(rb_mFtdiC, "INTERFACE_C", INT2NUM(INTERFACE_C));
  rb_define_const(rb_mFtdiC, "INTERFACE_D", INT2NUM(INTERFACE_D));

  rb_define_const(rb_mFtdiC, "TYPE_AM", INT2NUM(TYPE_AM));
  rb_define_const(rb_mFtdiC, "TYPE_BM", INT2NUM(TYPE_BM));
  rb_define_const(rb_mFtdiC, "TYPE_R", INT2NUM(TYPE_R));
  rb_define_const(rb_mFtdiC, "TYPE_2232H", INT2NUM(TYPE_2232H));
  rb_define_const(rb_mFtdiC, "TYPE_4232H", INT2NUM(TYPE_4232H));

  rb_define_const(rb_mFtdiC, "NONE", INT2NUM(NONE));
  rb_define_const(rb_mFtdiC, "ODD", INT2NUM(ODD));
  rb_define_const(rb_mFtdiC, "EVEN", INT2NUM(EVEN));
  rb_define_const(rb_mFtdiC, "MARK", INT2NUM(MARK));
  rb_define_const(rb_mFtdiC, "SPACE", INT2NUM(SPACE));

  rb_define_const(rb_mFtdiC, "STOP_BIT_1", INT2NUM(STOP_BIT_1));
  rb_define_const(rb_mFtdiC, "STOP_BIT_15", INT2NUM(STOP_BIT_15));
  rb_define_const(rb_mFtdiC, "STOP_BIT_2", INT2NUM(STOP_BIT_2));

  rb_define_const(rb_mFtdiC, "BITS_7", INT2NUM(BITS_7));
  rb_define_const(rb_mFtdiC, "BITS_8", INT2NUM(BITS_8));

  rb_define_const(rb_mFtdiC, "BREAK_OFF", INT2NUM(BREAK_OFF));
  rb_define_const(rb_mFtdiC, "BREAK_ON", INT2NUM(BREAK_ON));

  rb_define_const(rb_mFtdiC, "MPSSE_WRITE_NEG", INT2NUM(MPSSE_WRITE_NEG));
  rb_define_const(rb_mFtdiC, "MPSSE_BITMODE", INT2NUM(MPSSE_BITMODE));
  rb_define_const(rb_mFtdiC, "MPSSE_READ_NEG", INT2NUM(MPSSE_READ_NEG));
  rb_define_const(rb_mFtdiC, "MPSSE_LSB", INT2NUM(MPSSE_LSB));
  rb_define_const(rb_mFtdiC, "MPSSE_DO_WRITE", INT2NUM(MPSSE_DO_WRITE));
  rb_define_const(rb_mFtdiC, "MPSSE_DO_READ", INT2NUM(MPSSE_DO_READ));
  rb_define_const(rb_mFtdiC, "MPSSE_WRITE_TMS", INT2NUM(MPSSE_WRITE_TMS));

  rb_define_const(rb_mFtdiC, "SET_BITS_LOW", INT2NUM(SET_BITS_LOW));
  rb_define_const(rb_mFtdiC, "SET_BITS_HIGH", INT2NUM(SET_BITS_HIGH));
  rb_define_const(rb_mFtdiC, "GET_BITS_LOW", INT2NUM(GET_BITS_LOW));
  rb_define_const(rb_mFtdiC, "GET_BITS_HIGH", INT2NUM(GET_BITS_HIGH));
  rb_define_const(rb_mFtdiC, "LOOPBACK_START", INT2NUM(LOOPBACK_START));
  rb_define_const(rb_mFtdiC, "TCK_DIVISOR", INT2NUM(TCK_DIVISOR));
}

