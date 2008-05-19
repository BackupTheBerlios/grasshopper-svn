
	.section	.reset,"ax"

	.global _start
	.type	_start,@function
_start:
	/* Jump to wherever the linker thinks we are... */
	lddpc	pc, .Ltext_vaddr

	.align	2
.Ltext_vaddr:
	.word	_stext

	.text
	.global	_stext
_stext:
/* HJB inserted */
	lddpc   sp, .Lstartup_stack
	mcall	.LAddressSDRAMInitInC
_debug_break:
/*  HJB END inserted */

	/* Zero marks the end of the outermost frame.  */
	mov	r7, 0

	/*  Set up the stack pointer to a fixed value */
	lda.w	r10, _estack

	/*  If _stack is -1 don't set sp, the stack is then probably
	    set by some other means i.e. by a bootloader. */
	cp	r10, -1
	movne	sp, r10

	/* Check if we should load argv from the stack
	   Program needing to do that should set
	   _argv_from_stack symbol to something other than 0x0*/
	lda.w	r10, _argv_from_stack
	cp	r10, 0
	breq	0f

	/* Look for argc in *(sp - 4) and
           argv = sp - 4 - 4*argc */
	ld.w	r12, sp[-4]
	cp.w	r12, 0
	breq	0f
	sub	r11, sp, r12 << 2
	sub	r11, 4
	/* Make room for the arguments on the stack */
	ld.w	r10, r11[0]
	sub	sp, r10, 4
	andl	sp, 0xFFFC
0:

	/* Push r11 and r12 to the stack in case we have some program arguments */
	pushm	r11, r12


	/* Copy the data segment into RAM if necessary. If data_lma
	   is equal to data then VMA==LMA and no copying is necessary.
	   The linker script must make sure that the data segment is at
	   least dword-aligned.  */
	lda.w	r11, _data_lma
	lda.w	r12, _data
	cp.w	r11, r12
	breq	1f
	lda.w	r10, _edata
2:	ld.d	r8, r11++
	st.d	r12++, r8
	cp.w	r12, r10
	brlt	2b

	/* Zero the memory in the .bss section.  */
1:	lda.w	r10, _end
	lda.w	r12, _edata

	mov	r8, 0
	mov	r9, 0
2:	st.d	r12++, r8
	cp.w	r12, r10
	brlt	2b

	/* User dependent initialization */
	call	_init_startup

	/* Register _fini function with atexit
	   The _fini function is responsible for calling destructiors */
	lda.w	r12, _fini
	call	atexit

	/* Call _init in order to initialize constructors etc */
	call	_init

	popm	r11, r12

	/*Initialize argv*/
	call	_init_argv

	/* Call main and call exit when it returns */
	call	main
	call	exit

/* HJB inserted */
	.align 4
.LAddressSDRAMInitInC:
	.word 	init_sdram_startup

.Lstartup_stack:
        .long _startup_stack
/* HJB END inserted */

	.weak	_argv_from_stack
	.weak	_data_lma
