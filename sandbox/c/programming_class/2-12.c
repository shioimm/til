// 例解UNIX/Linuxプログラミング教室 P92

#include <sys/types.h>
#include <sys/uio.h>
#include <sys/wait.h>
#include <stdlib.h>
#include <unistd.h>

size_t x1;
ssize_t x2;
pid_t x3;

int main() {}

// Ubuntu
// $ gcc -g 2-12.c
// $ gdb a.out
//   (gdb) ptype x1
//   type = unsigned long
//   (gdb) ptype x2
//   type = long
//   (gdb) ptype 3
//   type = int

// macOS
// gcc -g 2-12.c
// lldb a.out
//   (lldb) target create "a.out"
//   Current executable set to 'a.out' (x86_64).
//   (lldb) image lookup --type size_t
//   1 match found in /Users/misakishioi/til/exercises/c/programming_class/a.out:
//   id = {0xffffffff0000003f}, name = "size_t", byte-size = 8, decl = _size_t.h:31, compiler_type = "typedef size_t"
//        typedef 'size_t': id = {0xffffffff0000004a}, name = "__darwin_size_t", byte-size = 8, decl = _types.h:92, compiler_type = "typedef __darwin_size_t"
//        typedef '__darwin_size_t': id = {0xffffffff00000055}, name = "long unsigned int", qualified = "unsigned long", byte-size = 8, compiler_type = "unsigned long"
//
//   (lldb) image lookup --type ssize_t
//   1 match found in /Users/misakishioi/til/exercises/c/programming_class/a.out:
//   id = {0xffffffff00000071}, name = "ssize_t", byte-size = 8, decl = _ssize_t.h:31, compiler_type = "typedef ssize_t"
//        typedef 'ssize_t': id = {0xffffffff0000007c}, name = "__darwin_ssize_t", byte-size = 8, decl = _types.h:119, compiler_type = "typedef __darwin_ssize_t"
//        typedef '__darwin_ssize_t': id = {0xffffffff00000087}, name = "long int", qualified = "long", byte-size = 8, compiler_type = "long"
//
//   (lldb) image lookup --type pid_t
//   1 match found in /Users/misakishioi/til/exercises/c/programming_class/a.out:
//   id = {0xffffffff000000a3}, name = "pid_t", byte-size = 4, decl = _pid_t.h:31, compiler_type = "typedef pid_t"
//        typedef 'pid_t': id = {0xffffffff000000ae}, name = "__darwin_pid_t", byte-size = 4, decl = _types.h:72, compiler_type = "typedef __darwin_pid_t"
//        typedef '__darwin_pid_t': id = {0xffffffff000000b9}, name = "__int32_t", byte-size = 4, decl = _types.h:44, compiler_type = "typedef __int32_t"
//        typedef '__int32_t': id = {0xffffffff000000c4}, name = "int", byte-size = 4, compiler_type = "int"
