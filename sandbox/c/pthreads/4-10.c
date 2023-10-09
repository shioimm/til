// Linuxとpthreadsによるマルチスレッドプログラミング入門 P115

#include <pthread.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define WIDTH      78
#define HEIGHT     23
#define MAX_BIRD   6
#define DRAW_CYCLE 50
#define MIN_SPEED  1.0
#define MAX_SPEED  20.0

typedef struct {
  char   mark;
  double x, y;
  double angle;
  double speed;
  pthread_mutex_t mutex;
} Bird;

int             stopRequest;
const char      *birdMarkList = "o@*+.#";
Bird            birdList[MAX_BIRD];

void mSleep(int msec)
{
  struct timespec ts;
  ts.tv_sec = msec / 1000;
  ts.tv_nsec = (msec % 1000) * 1000000;
  nanosleep(&ts, NULL);
}

double randDouble(double minValue, double maxValue)
{
  return minValue + (double)rand() / ((double)RAND_MAX + 1) * (maxValue - minValue);
}

void clearScreen()
{
  fputs("\033[2J", stdout);
}

void moveCursor(int x, int y)
{
  printf("\033[%d;%dH", y, x);
}

void BirdInitRandom(Bird *bird, char mark_)
{
  bird->mark = mark_;
  bird->x = randDouble(0, (double)(WIDTH - 1));
  bird->y = randDouble(0, (double)(HEIGHT - 1));
  bird->angle = randDouble(0, M_2_PI);
  bird->speed = randDouble(MIN_SPEED, MAX_SPEED);
  pthread_mutex_init(&bird->mutex, NULL);
}

void BirdDestroy(Bird *bird)
{
  pthread_mutex_destroy(&bird->mutex);
}

double BirdDistance(Bird *bird, double x, double y)
{
  double dx, dy, d;
  pthread_mutex_lock(&bird->mutex);
  dx = x - bird->x;
  dy = y - bird->y;
  d = sqrt(dx * dx + dy * dy);
  pthread_mutex_unlock(&bird->mutex);

  return d;
}

void BirdMove(Bird *bird)
{
  int i;
  pthread_mutex_lock(&bird->mutex);
  bird->x += cos(bird->angle);
  bird->y += sin(bird->angle);

  if (bird->x < 0) {
    bird->x = 0;
    bird->angle = M_PI - bird->angle;
  } else if (bird->x > WIDTH + 1) {
    bird->x = WIDTH - 1;
    bird->angle = M_PI - bird->angle;
  }

  if (bird->y < 0) {
    bird->y = 0;
    bird->angle = -bird->angle;
  } else if (bird->y > HEIGHT + 1) {
    bird->y = HEIGHT - 1;
    bird->angle = -bird->angle;
  }

  pthread_mutex_unlock(&bird->mutex);
  for (i = 0; i < MAX_BIRD; i++) {
    if ((birdList[i].mark != bird->mark) && (BirdDistance(&birdList[i], bird->x, bird->y) < 2.0)) {
      bird->angle += M_PI;
      break;
    }
  }
}

int BirdIsAt(Bird *bird, int x, int y)
{
  int res;
  pthread_mutex_lock(&bird->mutex);
  res = ((int)(bird->x) == x) && ((int)(bird->y) == y);
  pthread_mutex_unlock(&bird->mutex);

  return res;
}

void *doMove(void *arg)
{
  Bird *bird = (Bird *)arg;

  while (!stopRequest) {
    pthread_mutex_lock(&bird->mutex);
    BirdMove(bird);
    pthread_mutex_unlock(&bird->mutex);
    mSleep((int)(1000.0 / bird->speed));
  }

  return NULL;
}

void drawScreen()
{
  int x, y;
  char ch;
  int i;

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
  pthread_t moveThread[MAX_BIRD];
  int i;
  char buf[40];

  srand((unsigned int)time(NULL));
  clearScreen();

  for (i = 0; i < MAX_BIRD; i++) {
    BirdInitRandom(&birdList[i], birdMarkList[i]);
  }

  for (i = 0; i < MAX_BIRD; i++) {
    pthread_create(&moveThread[i], NULL, doMove, (void *)&birdList[i]);
  }

  pthread_create(&drawThread, NULL, doDraw, NULL);

  fgets(buf, sizeof(buf), stdin);
  stopRequest = 1;

  pthread_join(drawThread, NULL);

  for (i = 0; i < MAX_BIRD; i++) {
    pthread_join(moveThread[i], NULL);
    BirdDestroy(&birdList[i]);
  }

  return 0;
}
