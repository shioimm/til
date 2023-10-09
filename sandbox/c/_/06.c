/*
 * 納得C言語 [第15回]演習問題Ⅳ　第1問
 * http://www.isl.ne.jp/pcsp/beginC/C_Language_15.html
*/

#include <stdio.h>

typedef struct {
 int april;
 int may;
 int june;
} salary;

typedef struct {
 int no;
 char name[256];
 char department[256];
 char position[256];
 salary sal;
} employee;

float avg(employee *p);

int main()
{
  int i = 0;
  employee list[256];
  employee *p;
  p = list;

  while (1) {
    printf("No: ");
    scanf("%d", &(p+i)->no);

    if ((p+i)->no == 0) {
      break;
    }

    printf("Name: ");
    scanf("%s",(p+i)->name);
    printf("Department: ");
    scanf("%s",(p+i)->department);
    printf("Position: ");
    scanf("%s",(p+i)->position);
    printf("Salary\n");
    printf("Apr: ");
    scanf("%d",&(p+i)->sal.april);
    printf("May: ");
    scanf("%d",&(p+i)->sal.may);
    printf("June: ");
    scanf("%d",&(p+i)->sal.june);
    i++;

    printf("\n");
    printf("　　　　　　　　　　　　　　　　　　　　　　Salary\n");
    printf("No　      　  Name　　Dep　  Pos　　　Apr　　　May　　　Jun　　　Avg\n");

    for(i = 0; (p+i)->no!=0; i++) {
      printf("%8d%10s%8s%6s%9d%9d%9d%9.2f\n",
             (p+i)->no,
             (p+i)->name,
             (p+i)->department,
             (p+i)->position,
             (p+i)->sal.april,
             (p+i)->sal.may,
             (p+i)->sal.june,
             avg(p+i));
    }
  }

  return 0;
}

float avg(employee *p)
{
  return (p->sal.april + p->sal.may + p->sal.june) / 3;
}
