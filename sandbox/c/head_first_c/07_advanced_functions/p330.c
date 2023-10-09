// Head First C P330

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int compare_scores(const void* score_a, const void* score_b)
{
  // (*int)  - voidへのポインタをintへのポインタへキャスト
  // *(*int) - intへのポインタから値を取得
  int a = *(int*)score_a;
  int b = *(int*)score_b;

  return a - b;
}

int compare_scores_desc(const void* score_a, const void* score_b)
{
  int a = *(int*)score_a;
  int b = *(int*)score_b;

  return b - a;
}

typedef struct {
  int width;
  int height;
} rectangle;

int compare_areas(const void* a, const void* b)
{
  rectangle* ra = (rectangle*)a;
  rectangle* rb = (rectangle*)b;

  int area_a = (ra->width * ra->height);
  int area_b = (rb->width * rb->height);

  return area_a - area_b;
}

int compare_names(const void* a, const void* b)
{
  // 文字列 - 文字へのポインタ
  // 文字列へのポインタ - 文字へのポインタのポインタ
  // (char**) - 文字へのポインタへのポインタへキャスト
  char **sa = (char**)a;
  char **sb = (char**)b;

  // *sa- **saの値 = 文字へのポインタ
  return (strcmp(*sa, *sb) < 0);
}

int compare_area_descs(const void* a, const void* b)
{
  return compare_areas(b, a);
}

int compare_name_descs(const void* a, const void* b)
{
  return compare_names(b, a);
}

int main()
{
  int scores[] = { 543, 323, 32, 554, 11, 3, 112 };
  int i;
  qsort(scores, 7, sizeof(int), compare_scores_desc);

  puts("Scores:");
  for (i = 0; i < 7; i++) {
    printf("score: %i\n", scores[i]);
  }

  char *names[] = { "Karen", "Mark", "Brett", "Molly" };
  qsort(names, 4, sizeof(char*), compare_names);

  puts("Names:");
  for (i = 0; i < 4; i++) {
    printf("name: %s\n", names[i]);
  }

  return 0;
}
