// Head First C P407

#include <stddef.h>
#include <unistd.h>

int main()
{
  char *myenv[] = { "JUICE=apple", NULL };
  execle("p407_diner_info", "p407_diner_info", "4", NULL, myenv);

  return 0;
}
