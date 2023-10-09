// Head First C P456

#include <stdio.h>
#include <signal.h>
#include <stdlib.h>

void bye(int sig)
{
  puts("bye\n");
  exit(1);
}

int catch_signal(int sig, void (*handler)(int))
{
  struct sigaction action;
  action.sa_handler = handler;
  sigemptyset(&action.sa_mask);
  action.sa_flags = 0;

  return sigaction(sig, &action, NULL);
}

int main()
{
  if (catch_signal(SIGINT, bye) == -1) {
    fprintf(stderr, "Can't set handler");
    exit(2);
  }

  char name[20];
  printf("name: ");
  fgets(name, 30, stdin);
  printf("Hello %s\n", name);

  return 0;
}
