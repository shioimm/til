// Head First C P435

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
  FILE *f = fopen("stories.txt", "w");

  if (!f) {
    error("Can't open stories.txt");
  }

  pid_t pid = fork();

  if (pid == -1) {
    error("Can't fork");
  }

  if (!pid) {
    if (dup2(fileno(f), 1) == -1) {
      error("Can't redirect");
    }
  } else {
    if (execle("/usr/bin/python", "/usr/bin/python", "./rssgossip.py", phrase, NULL, vars) == -1) {
      error("Can't execute rssgossip.py");
    }
  }

  int pid_status;

  if (waitpid(pid, &pid_status, 0) == -1) {
    error("Error for waiting child process");
  }

  return 0;
}
