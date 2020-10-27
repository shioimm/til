// Linuxとpthreadsによるマルチスレッドプログラミング入門 P200

#include "6-1.h"
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
#define MAX_BIRD   6
#define QUEUE_SIZE 10

typedef struct {
  char   mark;
  double x, y;
  double angle;
  double speed;
  pthread_mutex_t mutex;
  pthread_cond_t  cond;
  XYQueue         *destQue;
} Bird;

static int             stopRequest;
static int             drawRequest;
Bird                   birdList[MAX_BIRD];
static pthread_mutex_t drawMutex;
static pthread_cond_t  drawCond;

static void requestDraw(void);

void mSleep(int msec)
{
  struct timespec ts;
  ts.tv_sec  = msec / 1000;
  ts.tv_nsec = (msec % 1000) * 1000000;
  nanosleep(&ts, NULL);
}

int pthread_cond_timedwait_msec(pthread_cond_t *cond, pthread_mutex_t *mutex, long msec)
{
  struct timespec ts;
  clock_gettime(CLOCK_REALTIME, &ts);
  ts.tv_sec  += msec / 1000;
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

void BirdInitCenter(Bird *bird, char mark_)
{
  bird->mark    = mark_;
  pthread_mutex_init(&bird->mutex, NULL);
  pthread_cond_init(&bird->cond,   NULL);
  bird->x       = (double)WIDTH / 2.0;
  bird->y       = (double)HEIGHT / 2.0;
  bird->angle   = 0;
  bird->speed   = 2;
  bird->destQue = XYQueueCreate(QUEUE_SIZE);
}

void BirdDestroy(Bird *bird)
{
  pthread_mutex_destroy(&bird->mutex);
  pthread_cond_destroy(&bird->cond);
  XYQueueDestroy(bird->destQue);
}

void BirdMove(Bird *bird)
{
  int i;

  pthread_mutex_lock(&bird->mutex);
  bird->x += cos(bird->angle);
  bird->y += sin(bird->angle);
  pthread_mutex_unlock(&bird->mutex);
  requestDraw();
}

int BirdIsAt(Bird *bird, int x, int y)
{
  int res;

  pthread_mutex_lock(&bird->mutex);
  res = ((int)(bird->x) == x) && ((int)(bird->y) == y);
  pthread_mutex_unlock(&bird->mutex);

  return res;
}

void BirdSetDirection(Bird *bird, double destX, double destY)
{
  pthread_mutex_lock(&bird->mutex);

  double dx   = destX - bird->x;
  double dy   = destY - bird->y;
  bird->angle = atan2(dy, dx);
  bird->speed = sqrt(dx * dx + dy * dy) / 5.0;

  if (bird->speed < 2) {
    bird->speed = 2;
  }

  pthread_mutex_unlock(&bird->mutex);
}

double BirdDistance(Bird *bird, double x, double y)
{
  double dx, dy, res;

  pthread_mutex_lock(&bird->mutex);
  dx  = x - bird->x;
  dy  = y - bird->y;
  res = sqrt(dx * dx + dy * dy);
  pthread_mutex_unlock(&bird->mutex);

  return res;
}

int BirdSetDestination(Bird *bird, double x, double y)
{
  return XYQueueAdd(bird->destQue, x, y);
}

int BirdWaitForSetDestination(Bird *bird, double *destX, double *destY, long msec)
{
  if (!XYQueueWait(bird->destQue, msec)) {
    return 0;
  }

  if (!XYQueueGet(bird->destQue, destX, destY)) {
    return 0;
  }
  return 1;
}

void *doMove(void *arg)
{
  double destX, destY;
  Bird  *bird = (Bird *)arg;

  while (!stopRequest) {
    if (!BirdWaitForSetDestination(bird, &destX, &destY, 100)) {
      continue;
    }

    BirdSetDirection(bird, destX, destY);

    while ((BirdDistance(bird, destX, destY) >= 1) && !stopRequest) {
      BirdMove(bird);
      mSleep((int)(1000.0 / bird->speed));
    }
  }
  return NULL;
}

static void requestDraw()
{
  pthread_mutex_lock(&drawMutex);
  drawRequest = 1;
  pthread_cond_signal(&drawCond);
  pthread_mutex_unlock(&drawMutex);
}

static void drawScreen()
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
  int err;

  pthread_mutex_lock(&drawMutex);

  while (!stopRequest) {
    err = pthread_cond_timedwait_msec(&drawCond, &drawMutex, 1000);

    if ((err != 0) && (err != ETIMEDOUT)) {
      printf("Fatal error on pthread_cond_timedwait\n");
      exit(1);
    }

    while (drawRequest && !stopRequest) {
      drawRequest = 0;
      pthread_mutex_unlock(&drawMutex);
      drawScreen();
      pthread_mutex_lock(&drawMutex);
    }
  }
  pthread_mutex_unlock(&drawMutex);

  return NULL;
}

int main()
{
  pthread_t drawThread;
  pthread_t moveThread;
  int       i;
  char      buf[40], *cp;
  double    destX, destY;

  // 初期化
  pthread_mutex_init(&drawMutex, NULL);
  pthread_cond_init(&drawCond,   NULL);
  clearScreen();
  BirdInitCenter(&birdList[0], '@');

  // 動作スレッド
  pthread_create(&moveThread, NULL, doMove, (void *)&birdList[0]);

  // 描画スレッド
  pthread_create(&drawThread, NULL, doDraw, NULL);
  requestDraw();

  while (1) {
    printf("Destination? ");
    fflush(stdout);
    fgets(buf, sizeof(buf), stdin);

    if (strncmp(buf, "stop", 4) == 0) {
      break;
    }

    // 座標の読み取り
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
  pthread_mutex_destroy(&drawMutex);
  pthread_cond_destroy(&drawCond);

  return 0;
}
