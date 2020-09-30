// 参照: 例解UNIX/Linuxプログラミング教室P349

#include <signal.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>

void alarm_handler(int sig) {}

ssize_t timeout_read(int fd, void *buf, size_t count, int seconds)
{
  int ret;
  struct sigaction act;
  act.sa_hander = alarm_handler;
  act.sa_flags  = 0;
  sigemptyset(&act.sa_mask);
  sigaction(SIGINT, &act, NULL);
  alarm(seconds);
  ret = read(fd, buf, count);
  alarm(0);
  return ret;
}

int main()
{
  char buf[1024];
  ssize_t ret;
  printf("Please type your name: ");
  fflush(stdout);
  ret = timeout_read(STDIN_FILENO, buf, sizeof(buf), 3);

  if (ret == -1) {
    printf("timed out\n");
  } else {
    write(STDOUT_FILENO, buf, ret);
  }
}
