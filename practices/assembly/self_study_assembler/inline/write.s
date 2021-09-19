	.file	"write.c"
	.text
	.globl	str
	.section	.rodata
.LC0:
	.string	"Hello\n"
	.data
	.align 8
	.type	str, @object
	.size	str, 8
str:
	.quad	.LC0
	.text
	.globl	main
	.type	main, @function
main:
.LFB0:
	.cfi_startproc
#APP
# 5 "write.c" 1
	movl str, %ecx
# 0 "" 2
# 6 "write.c" 1
	movl $14, %edx
# 0 "" 2
# 7 "write.c" 1
	movl $4,  %eax
# 0 "" 2
# 8 "write.c" 1
	movl $1,  %ebx
# 0 "" 2
# 9 "write.c" 1
	int $0x80
# 0 "" 2
#NO_APP
	movl	$0, %eax
	ret
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.ident	"GCC: (Debian 10.2.1-6) 10.2.1 20210110"
	.section	.note.GNU-stack,"",@progbits
