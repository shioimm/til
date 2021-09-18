	.file	"fact.c"
	.text
	.globl	fact
	.type	fact, @function
fact:
.LFB0:
	.cfi_startproc
	subq	$24, %rsp
	.cfi_def_cfa_offset 32
	movl	%edi, 12(%rsp)
	cmpl	$1, 12(%rsp)
	jne	.L2
	movl	12(%rsp), %eax
	jmp	.L3
.L2:
	movl	12(%rsp), %eax
	subl	$1, %eax
	movl	%eax, %edi
	call	fact
	imull	12(%rsp), %eax
.L3:
	addq	$24, %rsp
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE0:
	.size	fact, .-fact
	.globl	main
	.type	main, @function
main:
.LFB1:
	.cfi_startproc
	subq	$24, %rsp
	.cfi_def_cfa_offset 32
	movl	$3, %edi
	call	fact
	movl	%eax, 12(%rsp)
	movl	$0, %eax
	addq	$24, %rsp
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE1:
	.size	main, .-main
	.ident	"GCC: (Debian 10.2.1-6) 10.2.1 20210110"
	.section	.note.GNU-stack,"",@progbits
