// 参照: 例解UNIX/Linuxプログラミング教室P287

#include <sys/uio.h>    // read, write
#include <sys/socket.h> // socketpair, shutdown
#include <sys/types.h>  // socketpair, fork, read, write
#include <unistd.h>     // close, dup2, execlp, fork, read, write

int popen2_sockerpair(const char *command)
{
  int fd[2];

  if (socketpair(AF_UNIX, SOCK_STREAM, 0, fd) < 0) {
    return -1;
  }
  if (fork() == 0) {
    dup2(fd[0], 0);
    dup2(fd[0], 1);
    close(fd[0]);
    close(fd[1]);
    execlp("sh", "/bin/sh", "-c", command, (char * )NULL);
  }

  close(fd[0]);

  return fd[1];
}

int main()
{
  char buf[1024];
  int n, fd;

  fd = popen2_sockerpair("sort");
  write(fd, "orange\n", 7);
  write(fd, "apple\n",  6);
  write(fd, "banana\n", 7);
  shutdown(fd, SHUT_WR);

  while (1) {
    n = read(fd, buf, sizeof(buf));
    if (n <= 0) {
      break;
    }
    write(1, buf, n);
  }

  close(fd);
}
