SYS_EXIT equ 1
SYS_READ equ 3
SYS_WRITE equ 4
STDIN equ 0
STDOUT equ 1

section .data
    MSG_TITLE db "-------------------x86 ASM Calculator-------------------", 0xa
    MSG_LEN_TITLE equ $ - MSG_TITLE
    MSG_SEPARATOR db "--------------------------------------------------------", 0xa
    MSG_LEN_SEPARATOR equ $ - MSG_SEPARATOR
    MSG_SELECT_OPERATION db "Select operation: "
    MSG_LEN_SELECT_OPERATION equ $ - MSG_SELECT_OPERATION
    MSG_OP_ADDITION db "1. Addition.", 0xa
    MSG_LEN_OP_ADDITION equ $ - MSG_OP_ADDITION
    MSG_OP_SUBTRACTION db "2. Subtraction.", 0xa
    MSG_LEN_OP_SUBTRACTION equ $ - MSG_OP_SUBTRACTION
    MSG_OP_MULTIPLICATION db "3. Multiplication.", 0xa
    MSG_LEN_OP_MULTIPLICATION equ $ - MSG_OP_MULTIPLICATION
    MSG_OP_DIVISION db "4. Division.", 0xa
    MSG_LEN_OP_DIVISION equ $ - MSG_OP_DIVISION
    MSG_PERFORM_ANOTHER_OPERATION db "Would you like to perform another operation? (y/n): "
    MSG_LEN_PERFORM_ANOTHER_OPERATION equ $ - MSG_PERFORM_ANOTHER_OPERATION

print_separator:
    push ebp
    mov ebp, esp

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, MSG_SEPARATOR
    mov edx, MSG_LEN_SEPARATOR
    int 0x80

    mov esp, ebp
    pop ebp
    ret

print_title:
    push ebp
    mov ebp, esp

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, MSG_TITLE
    mov edx, MSG_LEN_TITLE
    int 0x80

    mov esp, ebp
    pop ebp
    ret

print_operation_options:
    push ebp
    mov ebp, esp

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

    mov esp, ebp
    pop ebp
    ret

print_select_operation:
    push ebp
    mov ebp, esp

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, MSG_SELECT_OPERATION
    mov edx, MSG_LEN_SELECT_OPERATION
    int 0x80

    mov esp, ebp
    pop ebp
    ret

print_ask_if_user_wants_to_continue:
    push ebp
    mov ebp, esp

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, MSG_PERFORM_ANOTHER_OPERATION
    mov edx, MSG_LEN_PERFORM_ANOTHER_OPERATION
    int 0x80

    mov esp, ebp
    pop ebp
    ret
