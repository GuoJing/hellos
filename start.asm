[BITS 32]
global start
start:
	mov esp, _sys_stack
	jmp stublet

ALIGN 4
mboot:
	;;  Multiboot macros to make a few lines later more readable
	MULTIBOOT_PAGE_ALIGN	equ	1 << 0
	MULTIBOOT_MEMORY_INFO	equ	1 << 1
	MULTIBOOT_AOUT_KLUDGE	equ	1 << 16
	MULTIBOOT_HEADER_MAGIC	equ	0x1BADB002
	MULTIBOOT_HEADER_FLAGS	equ	MULTIBOOT_PAGE_ALIGN | MULTIBOOT_MEMORY_INFO | MULTIBOOT_AOUT_KLUDGE
	MULTIBOOT_CHECKSUM	equ	-(MULTIBOOT_HEADER_MAGIC + MULTIBOOT_HEADER_FLAGS)
	EXTERN code, bss, end

	;;  This is the GRUB Multiboot header. A boot signature
	dd MULTIBOOT_HEADER_MAGIC
	dd MULTIBOOT_HEADER_FLAGS
	dd MULTIBOOT_CHECKSUM

	dd mboot
	dd code
	dd bss
	dd end
	dd start

stublet:
	extern main
	call main
	jmp $

global gdt_flush
extern gp
gdt_flush
	lgdt[gp]
	mov ax, 0x10
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	;; 0x08 is the offset to our code segment: Far jump!
	jmp 0x80:flush2

flush2:
	;; return back to the C code
	ret

global idt_load
extern idtp
idt_load:
	lidt[idtp]
	ret

SECTION .bss
	resb	8192

_sys_stack:
