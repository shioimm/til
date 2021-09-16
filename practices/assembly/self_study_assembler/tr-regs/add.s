	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 11, 0	sdk_version 11, 3
	.globl	_main                           ## -- Begin function main
	.p2align	4, 0x90
_main:                                  ## @main
	.cfi_startproc
## %bb.0:
	movl	$0, -4(%rsp)
	movl	$123, -8(%rsp)
	movl	-8(%rsp), %eax
	addl	$1, %eax
	movl	%eax, -8(%rsp)
	movl	$456, -12(%rsp)                 ## imm = 0x1C8
	movl	-8(%rsp), %eax
	addl	-12(%rsp), %eax
	movl	%eax, -12(%rsp)
	movl	-12(%rsp), %eax
	retq
	.cfi_endproc
                                        ## -- End function
.subsections_via_symbols
