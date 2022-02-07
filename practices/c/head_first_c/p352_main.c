// Head First C P353

#include <p352_encrypt.h>
#include <p352_checksum.h>
#include <stdio.h>

int main()
{
  char s[] = "Speac friend and enter.";

  encrypt(s);
  printf("encrypted: '%s\n'", s);
  printf("checksum: %i\n", checksum(s));

  encrypt(s);
  printf("decrypted: '%s\n'", s);
  printf("checksum: %i\n", checksum(s));

  return 0;
}
