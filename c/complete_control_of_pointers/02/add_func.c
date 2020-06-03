/*
 * 新・標準プログラマーズライブラリ C言語 ポインタ完全制覇
 * 第2章 実験してみよう Cはメモリをどう使うのか 5
*/

int add_func(int a, int b)
{
  int result;
  result = a + b;

  return result;
}

/*
 * _add_func:                              ## @add_func
 * ## %bb.0:
 * 	pushq	%rbp
 * 	movq	%rsp, %rbp
 * 	movl	%edi, -4(%rbp)
 * 	movl	%esi, -8(%rbp)
 * 	movl	-4(%rbp), %esi
 * 	addl	-8(%rbp), %esi
 * 	movl	%esi, -12(%rbp)
 * 	movl	-12(%rbp), %eax
 * 	popq	%rbp
 * 	retq
 *                                         ## -- End function
*/
