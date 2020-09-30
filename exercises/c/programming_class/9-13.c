// 参照: 例解UNIX/Linuxプログラミング教室P350

#include <assert.h>
#include <stdio.h>
#include <sys/select.h>
#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>

ssize_t timeout_read(int fd, void *buf, size_t count, int seconds)
{
  int ret;
  struct timeval timeout = { seconds, 0 };
  fd_set rfd_set;

  FD_ZERO(&rfd_set);
  FD_SET(STDIN_FILENO, &rfd_set);

  ret = select(STDIN_FILENO + 1, &rfd_set, NULL, NULL, &timeout);

  if (ret == -1) {
    perror("select");
  } else if (ret == 0) {
    ret = -1;
  } else {
    assert(FD_ISSET(STDIN_FILENO, &rfd_set));
    ret = read(fd, buf, count);
  }

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
