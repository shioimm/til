// 詳説Cポインタ P81

#include <stdio.h>

int add(int x, int y)
{
  return x + y;
}

int sub(int x, int y)
{
  return x - y;
}

typedef int (*Operation)(int, int);

Operation select(char opcode)
{
  switch(opcode) {
    case '+': return add;
    case '-': return sub;
  }
}

int evaluate(char opcode, int x, int y)
{
  Operation op = select(opcode);
  return op(x, y);
}

int main(void)
{
  printf("%d\n", evaluate('+', 5, 6));
  printf("%d\n", evaluate('-', 5, 6));

  return 0;
}
