// Linuxとpthreadsによるマルチスレッドプログラミング入門 P256

#ifndef POSTAL_NUMBER_H
#define POSTAL_NUMBER_H

#include <stddef.h>

typedef struct {
  char code[16];
  char pref[128];
  char city[256];
  char town[256];
} PostalNumber;

extern size_t PostalNumberLoadDB(void);
extern size_t PostalNumberSearch(const char *key, PostalNumber *result, size_t resultsize);

#endif /* POSTAL_NUMBER_H */
