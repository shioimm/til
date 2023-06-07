// Linuxによる並行プログラミング入門 P41

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

int main()
{
  int fd[2], rfd;
  char c;
  pipe(fd); // fd[0], fd[1]をpipeバッファに接続

  if (fork() == 0) { // 子プロセスではfd[1]への書き込みを行う
    close(fd[0]);
    rfd = open("practices/concurrent_programming_with_linux_101/p041_oldfile", O_RDONLY);

    while (read(rfd, &c, 1) != 0) {
      write(fd[1], &c, 1);
    }

    close(fd[1]);
    close(rfd);
  } else { // 親プロセスでは標準出力への書き込みを行う
    close(fd[1]);
    while (read(fd[0], &c, 1) != 0) {
      write(1, &c, 1);
    }
    close(fd[0]);
  }
  // p041_oldfileをread -> fd[1]へwrite -> fd[0]をread -> 1へwrite
}
