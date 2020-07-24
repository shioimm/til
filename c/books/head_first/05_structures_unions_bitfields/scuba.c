/*
 * 引用: head first c
 * 第5章 構造体、共用体、ビットフィールド 3
*/

#include <stdio.h>

typedef struct { /* 匿名struct */
  float tank_capacity;
  int tank_psi;
  const char *suit_material;
} equipment;

typedef struct scuba {
  const char *name;
  equipment kit;
} diver;

void badge(diver d)
{
  printf("名前: %s\nタンク: %2.2f(%i)\nスーツ: %s\n",
         d.name, d.kit.tank_capacity, d.kit.tank_psi, d.kit.suit_material);
}

int main()
{
  diver randy = { "ランディ", { 5.5, 3500, "ネオブレン" } };
  badge(randy);
  return 0;
}
