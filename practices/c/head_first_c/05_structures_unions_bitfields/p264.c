// Head First C P264

#include <stdio.h>

// ビットフィールド - 使用するメモリのサイズをビット単位で指定
typedef struct {
  unsigned int first_visit:  1;
  unsigned int come_again:   1;
  unsigned int fingers_lost: 4;
  unsigned int shark_attack: 1;
  unsigned int days_a_week:  3;
} survey;
