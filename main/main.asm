SYS_EXIT equ 1
SYS_READ equ 3
SYS_WRITE equ 4
STDIN equ 0
STDOUT equ 1

section .data
    MSG_STARTUP db "------------x86 ASM Calculator------------", 0xa
    MSG_LEN_STARTUP equ $ - MSG_STARTUP
    MSG_SEPARATOR db "------------------------------------------", 0xa
    MSG_LEN_SEPARATOR equ $ - MSG_SEPARATOR
    MSG_SELECT_OPERATION db "Select operation:", 0xa
    MSG_LEN_SELECT_OPERATION equ $ - MSG_SELECT_OPERATION
    MSG_OP_ADDITION db "1. Addition.", 0xa
    MSG_LEN_OP_ADDITION equ $ - MSG_OP_ADDITION
    MSG_OP_SUBTRACTION db "2. Subtraction.", 0xa
    MSG_LEN_OP_SUBTRACTION equ $ - MSG_OP_SUBTRACTION
    MSG_OP_MULTIPLICATION db "3. Multiplication.", 0xa
    MSG_LEN_OP_MULTIPLICATION equ $ - MSG_OP_MULTIPLICATION
    MSG_OP_DIVISION db "4. Division.", 0xa
    MSG_LEN_OP_DIVISION equ $ - MSG_OP_DIVISION
    MSG_INVALID_CHOICE db "Invalid choice.", 0xa
    MSG_LEN_INVALID_CHOICE equ $ - MSG_INVALID_CHOICE
    USER_CHOICE_BUFFER_LEN equ 255

section .bss
    user_choice_buffer resb 255
    converted_string resd 1

section .text
    global _start

_start:
    call output_startup_message
    call read_user_choice
    ; call print_user_choice
    call convert_string_to_number

    mov eax, 1
    mov ebx, 0
    int 0x80

read_user_choice:
    push ebp
    mov ebp, esp

    read_user_choice_start:
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
            je read_user_choice_end

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
            mov ecx, MSG_INVALID_CHOICE
            mov edx, MSG_LEN_INVALID_CHOICE
            int 0x80
            jmp read_user_choice_start

    read_user_choice_end:
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
    mov ecx, MSG_SEPARATOR
    mov edx, MSG_LEN_SEPARATOR
    int 0x80

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, MSG_STARTUP
    mov edx, MSG_LEN_STARTUP
    int 0x80

    ; Separator
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, MSG_SEPARATOR
    mov edx, MSG_LEN_SEPARATOR
    int 0x80

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, MSG_SELECT_OPERATION
    mov edx, MSG_LEN_SELECT_OPERATION
    int 0x80

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, MSG_OP_ADDITION
    mov edx, MSG_LEN_OP_ADDITION
    int 0x80

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, MSG_OP_SUBTRACTION
    mov edx, MSG_LEN_OP_SUBTRACTION
    int 0x80

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, MSG_OP_MULTIPLICATION
    mov edx, MSG_LEN_OP_MULTIPLICATION
    int 0x80

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, MSG_OP_DIVISION
    mov edx, MSG_LEN_OP_DIVISION
    int 0x80

    ; Separator
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, MSG_SEPARATOR
    mov edx, MSG_LEN_SEPARATOR
    int 0x80

    mov esp, ebp
    pop ebp
    ret
