// Head First C P186

#include <stdio.h>
#include "p186_encrypt.h"

int main()
{
  char msg[80];

  while (fgets(msg, 80, stdin)) {
    encrypt(msg);
    printf("%s\n", msg);
  }

  return 0;
}

// p186_message_hider.cとp186_encrypt.cで"p186_encrypt.h"をincludeする
// $ gcc p186_message_hider.c p186_encrypt.c -o p186_message_hider && ./p186_message_hider
