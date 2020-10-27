// Linuxとpthreadsによるマルチスレッドプログラミング入門 P257

#include "postalnumber.h"
#include <stdio.h>
#include <string.h>

#define DBFILE       "KEN_ALL_UTF8.CSV"
#define MAX_RECORDS  150000

static PostalNumber db[MAX_RECORDS];
static size_t nDb = 0;

static void trim(const char *str, char *dst, size_t dstSize);
static char *fetch(char *str);

size_t PostalNumberLoadDB()
{
  nDb = 0;
  FILE *fp = fopen(DBFILE, "r");

  if (fp == NULL) {
    return nDb;
  }

  char buf[1024], *cp, *xcp;

  while (fgets(buf, sizeof(buf) - 1, fp) != NULL) {
    buf[sizeof(buf) - 1] = '\0';
    cp  = buf;
    cp  = fetch(cp);
    cp  = fetch(cp);
    xcp = fetch(cp);
    trim(cp, db[nDb].code, sizeof(db[nDb].code));

    if (db[nDb].code[0] == '\0') {
      continue;
    }

    cp  = fetch(xcp);
    cp  = fetch(cp);
    cp  = fetch(cp);
    xcp = fetch(xcp);
    trim(cp, db[nDb].pref, sizeof(db[nDb].pref));

    cp  = xcp;
    xcp = fetch(cp);
    trim(cp, db[nDb].city, sizeof(db[nDb].city));

    cp  = xcp;
    xcp = fetch(cp);
    trim(cp, db[nDb].town, sizeof(db[nDb].town));

    if (++nDb >= MAX_RECORDS) {
      break;
    }
  }
  fclose(fp);
  return nDb;
}

size_t PostalNumberSearch(const char *key, PostalNumber *result, size_t resultsize)
{
  size_t count = 0;
  size_t i     = 0;

  while ((count < resultsize) && (i < nDb)) {
    if ((strcmp(db[i].code, key) == 0)
         || (strstr(db[i].pref, key) != NULL)
         || (strstr(db[i].city, key) != NULL)
         || (strstr(db[i].town, key) != NULL)) {
      result[count++] = db[i];
    }
    i++;
  }
  return count;
}

static char *fetch(char *str)
{
  while ((*str != ',') && (*str != '\n') && (*str != '\r') && (*str != '\0')) {
    str++;
  }

  if (*str != '\0') {
    *(str++) = '\0';
  }

  return str;
}

static void trim(const char *str, char *dst, size_t dstSize)
{
  char *xdst = dst;
  dstSize--;

  while ((*str == ' ') || (*str == '"')) {
    str++;
  }
  while ((*str != '\0') && (dstSize > 0)) {
    *(xdst++) = *(str++);
    dstSize--;
  }
  do {
    *(xdst--) = '\0';
  } while ((dst <= xdst) && ((*xdst == ' ') || (*xdst == '"')));
}
