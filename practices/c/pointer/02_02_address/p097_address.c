// 前橋 和弥  “新・標準プログラマーズライブラリ C言語 ポインタ完全制覇 P97
#include <stdio.h>
#include <stdlib.h>

int        global_variable;
static int file_static_variable;

void func1(void)
{
  int        local_variable;
  static int local_static_variable;
  printf("(func1) &local_variable..        %p\n", (void*)&local_variable);
  printf("(func1) &local_static_variable.. %p\n", (void*)&local_static_variable);
}

void func2(void)
{
  int local_variable;
  printf("(func2) &local_variable..        %p\n", (void*)&local_variable);
}

int main(void)
{
  int *p;
  // 関数へのポインタ
  printf("(main)  func1..                  %p\n", (void*)func1);
  printf("(main)  func2..                  %p\n", (void*)func2);
  // 文字列リテラル ("abc"が格納されている領域の先頭アドレス)
  printf("(main)  string literal..         %p\n", (void*)"abc");
  // ファイル内static変数
  printf("(main)  &file_static_variable..  %p\n", (void*)&file_static_variable);
  // グローバル変数
  printf("(main)  &global_variable..       %p\n", (void*)&global_variable);
  // ローカル変数の表示
  func1();
  func2();
  // mallocにより確保した領域
  p = malloc(sizeof(int));
  printf("(main)  malloc address..         %p\n", (void*)p);

  return 0;
}

// (main)  func1..                  0x10e63fcf0
// (main)  func2..                  0x10e63fd30
// (main)  string literal..         0x10e63ff3e
// ---
// (func1) &local_static_variable.. 0x10e644018
// (main)  &file_static_variable..  0x10e64401c
// (main)  &global_variable..       0x10e644020
// ---
// (main)  malloc address..         0x7f85334059d0
// (func1) &local_variable..        0x7ffee15c371c
// (func2) &local_variable..        0x7ffee15c371c
