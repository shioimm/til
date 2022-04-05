// Head First C P186
#include "p186_encrypt.h"

void encrypt(char *message)
{
  while (*message) {
    *message = *message ^ 31;
    message++;
  }
}
