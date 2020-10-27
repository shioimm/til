// 例解UNIX/Linuxプログラミング教室 P104

#include <stdio.h>
#include <stdarg.h>

int tiny_printf(const char *fmt, ...)
{
  va_list pvar;
  va_start(pvar, fmt);

  while (*fmt != '\0') {
    if (*fmt != '%') {
      putchar(*fmt);
    } else if (*++fmt == 'd') {
      putchar('0' + va_arg(pvar, int));
    } else {
      return -1;
    }
    fmt++;
  }
  va_end(pvar);

  return 0;
}

int main()
{
  tiny_printf("hello: \n");
  tiny_printf("hello: %d \n", 1);
  tiny_printf("hello: %d %d\n", 1, 2);

  return 0;
}
