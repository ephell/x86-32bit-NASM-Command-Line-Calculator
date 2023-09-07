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
    USER_CHOICE_BUFFER_SIZE equ 255
    INVALID_CHOICE_MSG db "Invalid choice."
    INVALID_CHOICE_MSG_LEN equ $ - INVALID_CHOICE_MSG

section .bss
    user_choice_buffer resb 255
    user_choice resb 1

section .text
    global _start

_start:
    call output_startup_message
    call read_user_choice
    call print_user_choice

    mov eax, 1
    mov ebx, 0
    int 0x80

read_user_choice:
    push ebp
    mov ebp, esp

    ; Read stdin buffer
    mov eax, SYS_READ
    mov ebx, STDIN
    mov ecx, user_choice_buffer
    mov edx, USER_CHOICE_BUFFER_SIZE
    int 0x80

    mov esi, user_choice_buffer 
    ; Get first byte in the buffer
    mov al, [esi] 
    ; Check if byte represents a digit in hex
    cmp al, 0x30 ; Hex rep. of 0 in ASCII (just "0" also works)
    jl invalid_choice
    cmp al, 0x39 ; Hex rep. of 9 in ASCII (just "9" also works)
    jg invalid_choice
    ; Save the byte
    jmp save_choice
        
    invalid_choice:
        mov eax, SYS_WRITE
        mov ebx, STDOUT
        mov ecx, INVALID_CHOICE_MSG
        mov edx, INVALID_CHOICE_MSG_LEN
        int 0x80
        jmp quit

    save_choice:
        mov [user_choice], al
        jmp quit

    quit:
        mov esp, ebp
        pop ebp
        ret

print_user_choice:
    push ebp
    mov ebp, esp

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, user_choice
    mov edx, 1
    int 0x80

    mov esp, ebp
    pop ebp
    ret

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
