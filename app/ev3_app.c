#include <mruby.h>
#include <mruby/irep.h>
#include "mrblib/ev3_app.c"

int
main(void)
{
  mrb_state *mrb = mrb_open();
  if (!mrb) { /* handle error */ }
  mrb_load_irep(mrb, ev3_app_ruby_symbol);
  mrb_close(mrb);
  return 0;
}

