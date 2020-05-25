/*
 * 引用: head first c
 * 第8章 スタティックライブラリとダイナミックライブラリ 1
*/

#include "encrypt.h"

/* 文字列を暗号化する */
void encrypt(char *message)
{
  while (*message) {
    *message = *message ^ 31;
    message++;
  }
}
