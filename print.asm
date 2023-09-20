; 'print.asm'
; Contains various functions for printing messages to the console.

SYS_WRITE equ 4
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
    MSG_ENTER_OPERAND_1 db "Enter operand 1: "
    MSG_LEN_ENTER_OPERAND_1 equ $ - MSG_ENTER_OPERAND_1
    MSG_ENTER_OPERAND_2 db "Enter operand 2: "
    MSG_LEN_ENTER_OPERAND_2 equ $ - MSG_ENTER_OPERAND_2
    MSG_ADDITION_PREFIX db "(Addition) "
    MSG_LEN_ADDITION_PREFIX equ $ - MSG_ADDITION_PREFIX
    MSG_SUBTRACTION_PREFIX db "(Subtraction) "
    MSG_LEN_SUBTRACTION_PREFIX equ $ - MSG_SUBTRACTION_PREFIX
    MSG_MULTIPLICATION_PREFIX db "(Multiplication) "
    MSG_LEN_MULTIPLICATION_PREFIX equ $ - MSG_MULTIPLICATION_PREFIX
    MSG_DIVISION_PREFIX db "(Division) "
    MSG_LEN_DIVISION_PREFIX equ $ - MSG_DIVISION_PREFIX
    MSG_CALCULATION_RESULT db "Result: "
    MSG_LEN_CALCULATION_RESULT equ $ - MSG_CALCULATION_RESULT
    MSG_CANT_DIVIDE_BY_ZERO db "Can't divide by zero!", 0xa
    MSG_LEN_CANT_DIVIDE_BY_ZERO equ $ - MSG_CANT_DIVIDE_BY_ZERO
    MSG_RESULT_TOO_SMALL_TO_BE_DISPLAYED db "Result is too small to be displayed!", 0xa
    MSG_LEN_RESULT_TOO_SMALL_TO_BE_DISPLAYED equ $ - MSG_RESULT_TOO_SMALL_TO_BE_DISPLAYED


section .text
    ; --------------------------------------
    ; Exports
    ; --------------------------------------
    ; Functions
    global print___separator
    global print___title
    global print___operation_options
    global print___select_operation
    global print___ask_if_user_wants_to_continue
    global print___enter_operand_1
    global print___enter_operand_2
    global print___operation_name
    global print___cant_divide_by_zero
    global print___result_too_small_to_be_displayed
    global print___calculation_result
    ; --------------------------------------
    ; Imports
    ; --------------------------------------
    ; Buffers
    extern op___result___ascii_buffer
    ; Constants
    extern OP___RESULT___ASCII_BUFFER_LEN

print___separator:
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

print___title:
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

print___operation_options:
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

print___select_operation:
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

print___ask_if_user_wants_to_continue:
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

print___enter_operand_1:
    push ebp
    mov ebp, esp

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, MSG_ENTER_OPERAND_1
    mov edx, MSG_LEN_ENTER_OPERAND_1
    int 0x80

    mov esp, ebp
    pop ebp
    ret

print___enter_operand_2:
    push ebp
    mov ebp, esp

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, MSG_ENTER_OPERAND_2
    mov edx, MSG_LEN_ENTER_OPERAND_2
    int 0x80

    mov esp, ebp
    pop ebp
    ret

print___operation_name:
    ; Print the name of the operation that was selected.
    ; Arg_1 (ebp+8) - address to buffer that holds the operation code.
    push ebp
    mov ebp, esp

    mov esi, [ebp + 8]
    mov al, byte [esi]
    cmp al, "1"
    je print___operation_name___addition
    cmp al, "2"
    je print___operation_name___subtraction
    cmp al, "3"
    je print___operation_name___multiplication
    cmp al, "4"
    je print___operation_name___division
    ; If none of the above match
    jmp print___operation_name___return

    print___operation_name___addition:
        mov eax, SYS_WRITE
        mov ebx, STDOUT
        mov ecx, MSG_ADDITION_PREFIX
        mov edx, MSG_LEN_ADDITION_PREFIX
        int 0x80
        jmp print___operation_name___return

    print___operation_name___subtraction:
        mov eax, SYS_WRITE
        mov ebx, STDOUT
        mov ecx, MSG_SUBTRACTION_PREFIX
        mov edx, MSG_LEN_SUBTRACTION_PREFIX
        int 0x80
        jmp print___operation_name___return

    print___operation_name___multiplication:
        mov eax, SYS_WRITE
        mov ebx, STDOUT
        mov ecx, MSG_MULTIPLICATION_PREFIX
        mov edx, MSG_LEN_MULTIPLICATION_PREFIX
        int 0x80
        jmp print___operation_name___return

    print___operation_name___division:
        mov eax, SYS_WRITE
        mov ebx, STDOUT
        mov ecx, MSG_DIVISION_PREFIX
        mov edx, MSG_LEN_DIVISION_PREFIX
        int 0x80

    print___operation_name___return:
        mov esp, ebp
        pop ebp
        ret

print___cant_divide_by_zero:
    push ebp
    mov ebp, esp

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, MSG_CANT_DIVIDE_BY_ZERO
    mov edx, MSG_LEN_CANT_DIVIDE_BY_ZERO
    int 0x80

    mov esp, ebp
    pop ebp
    ret

print___result_too_small_to_be_displayed:
    push ebp
    mov ebp, esp

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, MSG_RESULT_TOO_SMALL_TO_BE_DISPLAYED
    mov edx, MSG_LEN_RESULT_TOO_SMALL_TO_BE_DISPLAYED
    int 0x80

    mov esp, ebp
    pop ebp
    ret

print___calculation_result:
    ; Arg_1 (ebp+8) - address to buffer that holds the result.
    ; Arg_2 (ebp+12) - length of the buffer.
    push ebp
    mov ebp, esp

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, MSG_CALCULATION_RESULT
    mov edx, MSG_LEN_CALCULATION_RESULT
    int 0x80

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, op___result___ascii_buffer
    mov edx, OP___RESULT___ASCII_BUFFER_LEN
    int 0x80

    mov esp, ebp
    pop ebp
    ret
