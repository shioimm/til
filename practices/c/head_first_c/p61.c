// Head First C P61

#include <stdio.h>

void skip(char *msg)
{
  // puts関数にはアドレスを渡す必要がある
  puts(msg + 6); // msgのメモリアドレス + 6オフセット
}

int main()
{
  char *msg_from_amy = "Don't call me.";
  skip(msg_from_amy);

  return 0;
}
