// 独習アセンブラ
int main(void) {
  register int i, j;
  i = 123;
  i = i + 1;
  j = 456;
  j = i + j;
  return j;
}

// $ gcc -S -fno-pic -fomit-frame-pointer add.c
