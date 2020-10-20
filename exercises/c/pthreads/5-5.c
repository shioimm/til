// Linuxとpthreadsによるマルチスレッドプログラミング入門 P157

#include <pthread.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>
#include <errno.h>

#define WIDTH      78
#define HEIGHT     23
#define MAX_BIRD   1
#define DRAW_CYCLE 50

int stopRequest;

void mSleep(int msec)
{
  struct timespec ts;
  ts.tv_sec = msec / 1000;
  ts.tv_nsec = (msec % 1000) * 1000000;
  nanosleep(&ts, NULL);
}

int pthread_cond_timedwait_msec(pthread_cond_t *cond, pthread_mutex_t *mutex, long msec)
{
  struct timespec ts;
  clock_gettime(CLOCK_REALTIME, &ts);
  ts.tv_sec += msec / 1000;
  ts.tv_nsec += (msec % 1000) * 1000000;

  if (ts.tv_nsec >= 1000000000) {
    ts.tv_sec++;
    ts.tv_nsec -= 1000000000;
  }

  return pthread_cond_timedwait(cond, mutex, &ts);
}

void clearScreen()
{
  fputs("\033[2J", stdout);
}

void moveCursor(int x, int y)
{
  printf("\033[%d;%dH", y, x);
}

void saveCursor()
{
  printf("\0337");
}

void restoreCursor()
{
  printf("\0338");
}

typedef struct {
  char            mark;
  double          x, y;
  double          angle;
  double          speed;
  double          destX, destY;
  int             busy;
  pthread_mutex_t mutex;
  pthread_cond_t  cond;
} Bird;

Bird birdList[MAX_BIRD];

void BirdInitCenter(Bird *bird, char mark_)
{
  bird->mark  = mark_;
  pthread_mutex_init(&bird->mutex, NULL);
  pthread_cond_init(&bird->cond,   NULL);
  bird->x     = (double)WIDTH / 2.0;
  bird->y     = (double)HEIGHT / 2.0;
  bird->angle = 0;
  bird->speed = 2;
  bird->destX = bird->x;
  bird->destY = bird->y;
  bird->busy  = 0;
}

void BirdDestroy(Bird *bird)
{
  pthread_mutex_destroy(&bird->mutex);
  pthread_cond_destroy(&bird->cond);
}

void BirdMove(Bird *bird)
{
  int i;
  pthread_mutex_lock(&bird->mutex);
  bird->x += cos(bird->angle);
  bird->y += sin(bird->angle);
  pthread_mutex_unlock(&bird->mutex);
}

int BirdIsAt(Bird *bird, int x, int y)
{
  int res;
  pthread_mutex_lock(&bird->mutex);
  res = ((int)(bird->x) == x) && ((int)(bird->y) == y);
  pthread_mutex_unlock(&bird->mutex);
  return res;
}

void BirdSetDirection(Bird *bird)
{
  pthread_mutex_lock(&bird->mutex);
  double dx   = bird->destX - bird->x;
  double dy   = bird->destY - bird->y;
  bird->angle = atan2(dy, dx);
  bird->speed = sqrt(dx * dx + dy * dy) / 5.0;
  if (bird->speed < 2) {
    bird->speed = 2;
  }

  pthread_mutex_unlock(&bird->mutex);
}

double BirdDistanceToDestination(Bird *bird)
{
  double dx, dy, res;
  pthread_mutex_lock(&bird->mutex);
  dx  = bird->destX - bird->x;
  dy  = bird->destY - bird->y;
  res = sqrt(dx * dx + dy * dy);
  pthread_mutex_unlock(&bird->mutex);
  return res;
}

int BirdSetDestination(Bird *bird, double x, double y)
{
  if (bird->busy) {
    return 0;
  }

  pthread_mutex_lock(&bird->mutex);
  bird->destX = x;
  bird->destY = y;
  pthread_cond_signal(&bird->cond);
  pthread_mutex_unlock(&bird->mutex);

  return 1;
}

int BirdWaitForSetDestination(Bird *bird, long msec)
{
  int res;
  pthread_mutex_lock(&bird->mutex);

  switch (pthread_cond_timedwait_msec(&bird->cond, &bird->mutex, msec)) {
  case 0:
    res = 1;
    break;
  case ETIMEDOUT:
    res = 0;
    break;
  default:
    printf("Fatal error on pthread_cond_wait.\n");
    exit(1);
  }

  pthread_mutex_unlock(&bird->mutex);
  return res;
}

void *doMove(void *arg)
{
  Bird *bird = (Bird *)arg;

  while (!stopRequest) {
    bird->busy = 0;

    if (BirdWaitForSetDestination(bird, 100)) {
      continue;
    }

    if (BirdDistanceToDestination(bird) < 1) {
      continue;
    }

    bird->busy = 1;
    BirdSetDirection(bird);

    while ((BirdDistanceToDestination(bird) >= 1) && !stopRequest) {
      BirdMove(bird);
      mSleep((int)(1000.0 / bird->speed));
    }
  }
  return NULL;
}

void drawScreen()
{
  int x, y;
  char ch;
  int i;

  saveCursor();
  moveCursor(0, 0);

  for (y = 0; y < HEIGHT; y++) {
    for (x = 0; x < WIDTH; x++) {
      ch = 0;
      for (i = 0; i < MAX_BIRD; i++) {
        if (BirdIsAt(&birdList[i], x, y)) {
          ch = birdList[i].mark;
          break;
        }
      }

      if (ch != 0) {
        putchar(ch);
      } else if ((y == 0) || (y == HEIGHT - 1)) {
        putchar('-');
      } else if ((x == 0) || (x == WIDTH - 1)) {
        putchar('|');
      } else {
        putchar(' ');
      }
    }
    putchar('\n');
  }
  restoreCursor();
  fflush(stdout);
}

void *doDraw(void *arg)
{
  while (!stopRequest) {
    drawScreen();
    mSleep(DRAW_CYCLE);
  }
  return NULL;
}

int main()
{
  pthread_t drawThread;
  pthread_t moveThread;

  int i;
  char buf[40], *cp;
  double destX, destY;

  clearScreen();
  BirdInitCenter(&birdList[0], '@');

  pthread_create(&moveThread, NULL, doMove, (void *)&birdList[0]);
  pthread_create(&drawThread, NULL, doDraw, NULL);

  while (1) {
    printf("Destination? ");
    fflush(stdout);
    fgets(buf, sizeof(buf), stdin);
    if (strncmp(buf, "stop", 4) == 0) {
      break;
    }

    destX = strtod(buf, &cp);
    destY = strtod(cp, &cp);

    if (!BirdSetDestination(&birdList[0], destX, destY)) {
      printf("Bird is busy now. Try later.\n");
    }
  }
  stopRequest = 1;

  pthread_join(drawThread, NULL);
  pthread_join(moveThread, NULL);
  BirdDestroy(&birdList[0]);

  return 0;
}
