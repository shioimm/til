// Head First C P352

#include "p352_encrypt.h"

void encrypt(char *message)
{
  while (*message) {
    *message = *message ^ 31;
    message++;
  }
}
