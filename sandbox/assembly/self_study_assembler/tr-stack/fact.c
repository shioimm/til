// 独習アセンブラ
int fact( int n) {
  if (n == 1) {
    return n;
  } else {
    return n * fact(n - 1);
  }
}

int main(void) {
  int n = fact(3);
  return 0;
}
// $ gcc -S -fno-pic -fomit-frame-pointer fact.c
