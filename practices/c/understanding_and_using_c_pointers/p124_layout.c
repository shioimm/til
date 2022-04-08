// 詳説Cポインタ P124

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char *glogal_ptr   = "FOO";
char  global_arr[] = "FOO";

int main(void)
{
  static char *static_local_ptr   = "FOO";
  char        *local_ptr          = "FOO";
  static char  static_local_arr[] = "FOO";
  char         local_arr[]        = "FOO";
  char        *local_heap         = malloc(strlen("FOO") + 1);
  strcpy(local_heap, "FOO");

  printf("Global Pointer..       %p\n", glogal_ptr);
  printf("Global Array..         %p\n", glogal_ptr);
  printf("Static Local Pointer.. %p\n", static_local_ptr);
  printf("Local Pointer..        %p\n", local_ptr);
  printf("Static Local Array..   %p\n", static_local_arr);
  printf("Local Array..          %p\n", local_arr);
  printf("Local Heap..           %p\n", local_heap);

  return 0;
}

// Global Pointer..       0x10fed3ef6
// Global Array..         0x10fed3ef6
// Static Local Pointer.. 0x10fed3ef6
// Local Pointer..        0x10fed3ef6
// Static Local Array..   0x10fed8038
// Local Array..          0x7ffedfd2f6ec
// Local Heap..           0x7f82454059d0
