// 例解UNIX/Linuxプログラミング教室 P95

int *x1();   // x1 is func returning pointer to int
int (*x2)(); // x2 is pointer to func returning int
int *(x3()); // x3 is func returning pointer to int
int (*x4()); // x4 is func returning pointer to int

int *x5[];   // x5 is array of pointer to int
int (*x6)[]; // x6 is pointer to array of int
int *(x7[]); // x7 is array of pointer to int
int (*x8[]); // x8 is array of pointer to int

int main() {}
