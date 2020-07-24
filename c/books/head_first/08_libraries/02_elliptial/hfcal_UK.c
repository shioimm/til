/*
 * 引用: head first c
 * 第8章 スタティックライブラリとダイナミックライブラリ 2
*/
#include <stdio.h>
#include "hfcal.h"

void display_calories(float weight, float distance, float coeff)
{
  printf("体重: %3.2fkg\n", weight / 2.2046);
  printf("距離: %3.2fkm\n", distance * 1.609344);
  printf("消費カロリー: %4.2fカロリー\n", coeff * weight * distance);
}
