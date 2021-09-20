// 独習アセンブラ
char *str = "Hello\n";

int main(void) {
  asm ("movl str, %ecx");
  asm ("movl $14, %edx");
  asm ("movl $4,  %eax"); // システムコール4(write)
  asm ("movl $1,  %ebx"); // 標準出力
  asm ("int $0x80");      // システムコール呼び出し
}

// int main(void) {
//   asm ("movl str, %ecx\n\
//         movl $14, %edx\n\
//         movl $4,  %eax\n\
//         movl $1,  %ebx\n\
//         int  $0x80");
// }

// $ gcc -o write write.c -no-pie
