/*
 * 納得C言語 [第18回]演習問題Ⅴ
 * http://www.isl.ne.jp/pcsp/beginC/C_Language_18.html
*/

#include <stdio.h>
#include <stdlib.h>

typedef struct {
  int english;
  int japanese;
  int math;
  int science;
  int social;
} scores;

typedef struct {
  int no;
  char name[256];
  int s_year;
  char s_class[256];
  scores s_scores;
} student;

void show(student *p);
void input(student *p);
void file_out(student *p);
void file_in(student *p);

int main()
{
  int command = 1;
  student school[256];
  student *p;
  p = school;

  while(command != 0){
    printf("Enter command.\n");
    printf("1: Show\n2: Input\n3: File Out\n0: Exit >>\n");
    scanf("%d", &command);

    switch(command) {
      case 1:
        show(p);
        break;
      case 2:
        input(p);
        break;
      case 3:
        file_out(p);
        break;
      case 0:
        printf("Exit...\n");
        break;
      default:
        printf("invalid command.\n");
        break;
    }
  }

  return 0;
}

void show(student *p)
{
  int i;

  printf("　　　　　　　　　　　　　　　　　　|　　　　　　　Scores\n");
  printf("No     　 　　　　Name　Year  Class　 |　Eng 　Jpn　 Math　Sci　 Soc\n");
  printf("-------------------------------------------------------------------\n");

  for (i = 1; ((p+i)->no) != 0; i++) {
    printf("%7d　　%10s　　%d　　　%s　 |　 %d　　%d　　%d　　%d　　%d \n",
           (p+i)->no,
           (p+i)->name,
           (p+i)->s_year,
           (p+i)->s_class,
           (p+i)->s_scores.english,
           (p+i)->s_scores.japanese,
           (p+i)->s_scores.math,
           (p+i)->s_scores.science,
           (p+i)->s_scores.social);
  }
}

void input(student *p)
{
  int i = 1;

  while(1) {
    printf("%d... \n", i + 1);
    printf("No: ");
    scanf("%d", &(p+i)->no);

    if (((p+i)->no) == 0) {
      printf("Exit...\n");
      break;
    }
    printf("Name: ");
    scanf("%s", (p+i)->name);
    printf("SchoolYear: ");
    scanf("%d", &(p+i)->s_year);
    printf("Class: ");
    scanf("%s", (p+i)->s_class);
    printf("Scores:\n");
    printf("  English: ");
    scanf("%d", &(p+i)->s_scores.english);
    printf("  Japanese: ");
    scanf("%d", &(p+i)->s_scores.japanese);
    printf("  Math: ");
    scanf("%d", &(p+i)->s_scores.math);
    printf("  Science: ");
    scanf("%d", &(p+i)->s_scores.science);
    printf("  Social: ");
    scanf("%d", &(p+i)->s_scores.social);

    i++;
  }
}

void file_out(student *p)
{
  FILE *fp;
  int i = 0;

  if (!(fp = fopen("07_output.txt", "w"))) {
    printf("The file could't be opened.");
    exit(1);
  }

  while (((p+i)->no) != 0) {
    fprintf(fp, "%d　%s %d %s %d %d %d %d %d\n",
            (p+i)->no,
            (p+i)->name,
            (p+i)->s_year,
            (p+i)->s_class,
            (p+i)->s_scores.english,
            (p+i)->s_scores.japanese,
            (p+i)->s_scores.math,
            (p+i)->s_scores.science,
            (p+i)->s_scores.social);
    i++;
  }

  fclose(fp);
  printf("The file has been saved.");
}

void file_in(student *p)
{
  FILE *fp;
  char str[256];
  int i = 0;

  if (!(fp = fopen("07_output.txt", "r"))) {
    printf("The file could't be opened.");
    exit(1);
  }

  while ((fscanf(fp, "%d　%s %d %s %d %d %d %d %d\n",
            &(p+i)->no,
            (p+i)->name,
            &(p+i)->s_year,
            (p+i)->s_class,
            &(p+i)->s_scores.english,
            &(p+i)->s_scores.japanese,
            &(p+i)->s_scores.math,
            &(p+i)->s_scores.science,
            &(p+i)->s_scores.social)) != EOF) {
        i++;
      }
  }

  fclose(fp);
  printf("The file has been saved.");
}
