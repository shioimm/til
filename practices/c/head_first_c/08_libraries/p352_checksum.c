// Head First C P352

#include "p352_checksum.h"

int checksum(char *message)
{
  int c = 0;

  while (*message) {
    c += c ^ (int)(*message);
    message++;
  }

  return c;
}
