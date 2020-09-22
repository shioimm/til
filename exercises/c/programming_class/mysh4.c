// 参照: 例解UNIX/Linuxプログラミング教室P218

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h> // wait, WIFEXITED, WEXITSTATUS
#include <sys/stat.h> // open
#include <fcntl.h>    // open
#include <unistd.h>   // close, execvp, fork
#include "mysub.h"
#include "myvec.h"

enum {
  MAXARGV = 100
};

int main()
{
  char cmd[1024];
  char *av[MAXARGV], *outfile;
  int i, ac, status, bg;
  pid_t cpid, zpid;

  for (;;) {
    while ((zpid = waitpid(-1, &status, WNOHANG)) > 0) {
      fprintf(stderr, "process: %d salvaged\n", zpid);
    }
    if (zpid == -1 && errno != ECHILD) {
      perror("waitpid(2)");
      exit(1);
    }

    getstr("@ ", cmd, sizeof(cmd));

    if (feof(stdin)) {
      exit(0);
    } else if (ferror(stdin)) {
      perror("getstr");
      exit(1);
    }

    if ((ac = strtovec(cmd, av, MAXARGV)) > MAXARGV) {
      fputs("too many arguments\n", stderr);
      continue;
    }
    ac--;

    if (ac == 0) {
      continue;
    }

    outfile = NULL;
    for (i = 0; i < ac; i++) {
      if (!strcmp(av[i], ">")) {
        av[i] = NULL;
        ac = i;
        outfile = av[i + 1];
        break;
      }
    }

    if (!strcmp(av[ac - 1], "&")) {
      av[ac - 1] = NULL;
      ac--;
      bg = 1;
      if (ac == 0) {
        fputs("invalid null command\n", stderr);
        continue;
      }
    } else {
      bg = 0;
    }

    if ((cpid = fork()) == -1) {
      perror("fork");
      exit(1);
    } else if (cpid == 0){
      if (outfile != NULL) {
        close(1);
        if (open(outfile, O_WRONLY|O_CREAT|O_TRUNC, 0666) == -1) {
          perror(outfile);
          exit(1);
        }
      }

      execvp(av[0], av);
      perror(av[0]);
      exit(1);
    }

    if (!bg) {
      if (waitpid(cpid, &status, 0) == (pid_t) - 1) {
        perror("waitpid");
        exit(1);
      }
      fprintf(stderr, "proccess %d finished\n", cpid);
    }
  }
  exit(0);
}
