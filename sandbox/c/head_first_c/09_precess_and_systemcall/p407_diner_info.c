// Head First C P407

#include <stdio.h>
#include <stdlib.h> // getenv

int main(int argc, char *argv[])
{
  printf("cafeteria: %s\n", argv[1]);
  printf("juice: %s\n", getenv("JUICE")); // 環境変数の読み取り

  return 0;
}
