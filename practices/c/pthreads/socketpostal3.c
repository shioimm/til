// Linuxとpthreadsによるマルチスレッドプログラミング入門 P244

#include "postalnumber.h"
#include "intqueue.h"
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <signal.h>
#include <pthread.h>

#define PORTNO      25000
#define SEARCH_SIZE 100
#define N_WORKER    4
#define N_QUE       2

static void getString(FILE *fp, char *buf, size_t buflen)
{
  int ch;
  buflen--;

  while ((ch = fgetc(fp)) != EOF) {
    if (ch == '\r') {
      continue;
    }
    if (ch == '\n') {
      break;
    }
    if (buflen > 0) {
      *(buf++) = ch;
      buflen--;
    }
  }
  *buf = '\0';
}

static void searchPostalNumber(FILE *fp)
{
  fprintf(fp, "Search ? ");
  fflush(fp);
  char buf[128];
  getString(fp, buf, sizeof(buf));
  fprintf(fp, "Search for '%s': \n", buf);
  PostalNumber res[SEARCH_SIZE];
  size_t n = PostalNumberSearch(buf, res, SEARCH_SIZE);

  for (size_t i = 0; i < n; i++) {
    fprintf(fp, " %s %s %s %s\n", res[i].code, res[i].pref, res[i].city, res[i].town);
  }
}

static IntQueue *socQueue;

static void *doWorker(void *arg)
{
  int id = (int)arg;

  printf("Start worker#%d\n", id);

  while (1) {
    int soc;

    if (!IntQueueWait(socQueue, 1000)) {
      continue;
    }
    if (!IntQueueGet(socQueue, &soc)) {
      continue;
    }

    FILE *fp;

    if ((fp = fdopen(soc, "r+")) == NULL) {
      printf("Failed to create FILE stream\n");
      close(soc);
      break;
    }

    searchPostalNumber(fp);
    fclose(fp);
  }
  printf("Finish worker#%d\n", id);

  return NULL;
}

int main()
{
  PostalNumberLoadDB();

  pthread_t worker[N_WORKER];

  for (int i = 0; i < N_WORKER; i++) {
    if (pthread_create(&worker[i], NULL, doWorker, (void *)i) != 0) {
      printf("Failed to create thread, abort\n");
      return 1;
    }
  }

  if ((socQueue = IntQueueCreate(N_QUE)) == NULL) {
    printf("Failed to create IntQueue, abort\n");
    return 1;
  }

  int listener;
  if ((listener = socket(PF_INET, SOCK_STREAM, 0)) < 0) {
    printf("Can't create listener socket\n");
    return 1;
  }

  signal(SIGPIPE, SIG_IGN);

  int val = 1;
  setsockopt(listener, SOL_SOCKET, SO_REUSEADDR, &val, sizeof(val));

  struct sockaddr_in saddr;
  memset(&saddr, 0, sizeof(saddr));
  saddr.sin_family      = AF_INET;
  saddr.sin_addr.s_addr = INADDR_ANY;
  saddr.sin_port        = htons(PORTNO);

  if (bind(listener, (struct sockaddr *)&saddr, sizeof(saddr)) < 0) {
    printf("Can't bind socket to port\n");
    close(listener);
    return 1;
  }

  if (listen(listener, 1) < 0) {
    printf("Failed to listen on port: %d\n", PORTNO);
    close(listener);
    return 1;
  }

  printf("Waiting for connection on port: %d\n", PORTNO);

  while (1) {
    int                soc;
    struct sockaddr_in caddr;
    socklen_t          caddrlen = sizeof(caddr);

    if ((soc = accept(listener, (struct sockaddr *)&caddr, &caddrlen)) < 0) {
      printf("Error on accept listening socket\n");
      break;
    }

    char ipstr[INET_ADDRSTRLEN];
    printf("Connect from %s\n", inet_ntop(AF_INET, &caddr.sin_addr, ipstr, sizeof(ipstr)));

    if (!IntQueueAdd(socQueue, soc)) {
      printf("Socket que overflow\n");
      close(soc);
    }
  }
  close(listener);

  for (int i = 0; i < N_WORKER; i++) {
    pthread_join(worker[i], NULL);
  }
  IntQueueDestroy(socQueue);

  return 0;
}
