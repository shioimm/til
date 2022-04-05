// Head First C P448

#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <sys/wait.h>

void error(char *msg)
{
  fprintf(stderr, "%s: %s\n", msg, strerror(errno));
  exit(1);
}

int main(int argc, char *argv)
{
  char *phrase = [1];
  char *vars[] = { "RSS_FEED=http://example.com", NULL };
  int fd[2];

  if (pipe(fd) == -1) {
    error("Can't create pipe");
  }

  pid_t pid = fork();

  if (pid == -1) {
    error("Can't fork");
  }

  if (!pid) {
    dup2(fd[1], 1);
    close(fd[0]);
  } else {
    if (execle("/usr/bin/python", "/usr/bin/python", "./rssgossip.py", "-u", phrase, NULL, vars) == -1) {
      error("Can't execute rssgossip.py");
    }
  }

  dup(fd[0], 0);
  close(fd[1]);

  char line[255];

  while (fgets(line, 255, fd[0])) {
    if (line[0] == '\t') {
      open_url(line + 1);
    }
  }

  return 0;
}
