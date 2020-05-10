/*
 * 引用: head first c
 * 第4章 複数のソースファイルの使用
*/

#include "encrypt.h"

void encrypt(char *message)
{
  while(*message) {
    *message = *message ^ 31;
    message++;
  }
}
