/*
 * 引用: head first c
 * 第8章 スタティックライブラリとダイナミックライブラリ 1
*/

#include "checksum.h"

/* 文字列の中身が変更されていないことを感知する */
int checksum(char *message)
{
  int c = 0;

  while (*message) {
    c += c ^ (int)(*message);
    message++;
  }

  return c;
}
