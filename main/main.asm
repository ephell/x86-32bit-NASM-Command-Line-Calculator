SYS_EXIT equ 1
SYS_READ equ 3
SYS_WRITE equ 4
STDIN equ 0
STDOUT equ 1

section .data
    STARTUP_MSG db "x86 ASM Calcultor.", 0xa
    STARTUP_MSG_LEN equ $ - STARTUP_MSG
    SEPARATOR_MSG db "----------------------------------------", 0xa
    SEPARATOR_MSG_LEN equ $ - SEPARATOR_MSG

section .bss

section .text
    global _start

_start:
    call output_startup_message

    mov eax, 1
    mov ebx, 0
    int 0x80

output_startup_message:
    push ebp
    mov ebp, esp

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, SEPARATOR_MSG
    mov edx, SEPARATOR_MSG_LEN
    int 0x80

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, STARTUP_MSG
    mov edx, STARTUP_MSG_LEN
    int 0x80

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, SEPARATOR_MSG
    mov edx, SEPARATOR_MSG_LEN
    int 0x80

    mov esp, ebp
    pop ebp
    ret
