#include <stdio.h>
#include <mruby.h>
#include <mruby/irep.h>
#include "#{SOURCE}"

int main(void) {
  mrb_state *mrb = mrb_open();

  if (!mrb) {
    /* handle error */
    return 128;
  }

  mrb_load_irep(mrb, ev3_app_ruby_symbol);

  if (mrb->exc) {
    mrb_print_error(mrb);
    mrb_print_backtrace(mrb);
    mrb_close(mrb);

    return 1;
  }

  mrb_close(mrb);

  return 0;
}
