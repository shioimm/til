// 例解UNIX/Linuxプログラミング教室 P73-74

#include <termios.h>
#include <unistd.h>

int main()
{
  struct termios tp;
  tcgetattr(STDIN_FILENO, &tp);
}
