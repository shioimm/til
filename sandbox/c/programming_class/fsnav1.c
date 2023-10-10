// 参照: 例解UNIX/Linuxプログラミング教室P254

#include <limits.h>
#include <errno.h>
#include <sys/types.h> // closedir, opendir, readdir
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>    // closedir, opendir, readdir
#include <termios.h>   // tcgetattr, tcsetattr
#include <unistd.h>    // chdir, getcwd, tcgetattr, tcsetattr, link, symink, unlink

void restoreterm(void);
void showlist(void);
void showcwd(void);
void goup(void);
void godown(void);
void delfile(void);

struct termios termsave, termcur;

void restoreterm()
{
  tcsetattr(STDIN_FILENO, TCSANOW, &termsave);
}

void showlist()
{
  DIR *dirp;
  struct dirent *dep;

  if ((dirp = opendir(".")) == NULL) {
    fprintf(stderr, "cannot open directory.\n");
    return;
  }

  errno = 0;

  while ((dep = readdir(dirp)) != NULL) {
    printf("%s\n", dep->d_name);
  }

  if (errno == 0) {
    putchar('\n');
  } else {
    perror("\nreaddir");
  }

  closedir(dirp);
}

void showcwd()
{
  char buf[PATH_MAX + 1];

  getcwd(buf, sizeof(buf));

  printf("%s\n", buf);
}

void goup()
{
  chdir("..");
}

void godown()
{
  char buf[PATH_MAX + 1], *p;

  tcsetattr(STDIN_FILENO, TCSANOW, &termsave);
  fputs("directory? ", stderr);
  fgets(buf, sizeof(buf), stdin);

  if ((p = strchr(buf, '\n')) != NULL) {
    *p = '\0';
  }

  if (chdir(buf) != 0) {
    perror("chdir");
  }

  tcsetattr(STDIN_FILENO, TCSANOW, &termcur);
}

void delfile()
{
  char buf[PATH_MAX + 1], *p;

  tcsetattr(STDIN_FILENO, TCSANOW, &termsave);
  fputs("file to remove? ", stderr);
  fgets(buf, sizeof(buf), stdin);

  if ((p = strchr(buf, '\n')) != NULL) {
    *p = '\0';
  }
  if (unlink(buf) != 0) {
    perror("unlink");
  }
  tcsetattr(STDIN_FILENO, TCSANOW, &termcur);
}

int main()
{
  int c;

  tcgetattr(STDIN_FILENO, &termsave);
  termcur = termsave;

  if (atexit(restoreterm) != 0) {
    perror("atexit");
    exit(1);
  }

  termcur.c_lflag &= ~(ICANON | ECHO);
  termcur.c_cc[VMIN] = 1;
  termcur.c_cc[VTIME] = 0;
  tcsetattr(STDIN_FILENO, TCSANOW, &termcur);
  setbuf(stdin, NULL);

  for (;;) {
    c = getchar();

    switch (c) {
      case 'l':
        showlist();
        break;
      case 'u':
        goup();
        showcwd();
        break;
      case 'd':
        godown();
        showcwd();
        break;
      case '?':
        showcwd();
        break;
      case 'q':
        exit(0);
      case 'r':
        delfile();
        break;
      default:
        fprintf(stderr, "unknown command '%c'\n", c);
        break;
    }
  }

  return 0;
}
