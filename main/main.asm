SYS_EXIT equ 1
SYS_READ equ 3
SYS_WRITE equ 4
STDIN equ 0
STDOUT equ 1

section .data
    STARTUP_MSG db "x86 ASM Calculator.", 0xa
    STARTUP_MSG_LEN equ $ - STARTUP_MSG
    SEPARATOR_MSG db "----------------------------------------", 0xa
    SEPARATOR_MSG_LEN equ $ - SEPARATOR_MSG
    USER_CHOICE_BUFFER_LEN equ 255
    INVALID_CHOICE_MSG db "Invalid choice.", 0xa
    INVALID_CHOICE_MSG_LEN equ $ - INVALID_CHOICE_MSG

section .bss
    user_choice_buffer resb 255
    converted_string resd 1

section .text
    global _start

_start:
    call output_startup_message
    call read_user_choice
    call print_user_choice
    call convert_string_to_number

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
    mov edx, USER_CHOICE_BUFFER_LEN
    int 0x80

    ; Making sure all bytes in buffer are numbers
    xor edi, edi ; Zero out loop counter
    mov esi, user_choice_buffer ; Load buffer
    read_user_choice_loop:
        mov al, byte [esi + edi] ; Get first char in the buffer
        cmp al, 0xa ; Check if it's a new line character
        je read_user_choice_quit ; Jump if new line character

        ; Check if read byte represents a digit in hex
        cmp al, "0"
        jl read_user_choice_invalid_input
        cmp al, "9"
        jg read_user_choice_invalid_input
        
        inc edi
        jmp read_user_choice_loop

    read_user_choice_invalid_input:
        mov eax, SYS_WRITE
        mov ebx, STDOUT
        mov ecx, INVALID_CHOICE_MSG
        mov edx, INVALID_CHOICE_MSG_LEN
        int 0x80
        jmp read_user_choice_quit

    read_user_choice_quit:
        mov esp, ebp
        pop ebp
        ret

convert_string_to_number:
    push ebp
    mov ebp, esp

    xor ebx, ebx ; Clear ebx
    mov esi, user_choice_buffer ; Load user choice string

    convert_string_to_number_loop:
        movzx eax, byte [esi] ; Load next character from buffer
        inc esi

        cmp al, 0x0a ; Check if loaded byte is a new line character
        je convert_string_to_number_finish

        sub al, '0'; Convert from ASCII to number
        imul ebx, 10 ; Multiply ebx by 10
        add ebx, eax ; ebx = ebx * 10 + eax
        jmp convert_string_to_number_loop

    convert_string_to_number_finish:
        mov [converted_string], ebx ; Store value in buffer
        mov esp, ebp
        pop ebp
        ret

print_user_choice:
    push ebp
    mov ebp, esp

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, user_choice_buffer
    mov edx, USER_CHOICE_BUFFER_LEN
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
