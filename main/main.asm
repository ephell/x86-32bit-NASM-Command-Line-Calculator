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
    MSG_INVALID_CHOICE db "Invalid choice. Try again: "
    MSG_LEN_INVALID_CHOICE equ $ - MSG_INVALID_CHOICE
    MSG_ENTER_FIRST_NUMBER db "Enter first number: "
    MSG_LEN_ENTER_FIRST_NUMBER equ $ - MSG_ENTER_FIRST_NUMBER
    MSG_ENTER_SECOND_NUMBER db "Enter second number: "
    MSG_LEN_ENTER_SECOND_NUMBER equ $ - MSG_ENTER_SECOND_NUMBER
    MSG_INVALID_INPUT db "Invalid input. Try again: "
    MSG_LEN_INVALID_INPUT equ $ - MSG_INVALID_INPUT
    MSG_CALCULATION_RESULT db "Result: "
    MSG_LEN_CALCULATION_RESULT equ $ - MSG_CALCULATION_RESULT
    MSG_PERFORM_ANOTHER_OPERATION db "Would you like to perform another operation? (y/n): "
    MSG_LEN_PERFORM_ANOTHER_OPERATION equ $ - MSG_PERFORM_ANOTHER_OPERATION
    USER_CHOICE_ASCII_BUFFER_LEN equ 255
    USER_NUM_ASCII_BUFFER_LEN equ 12 ; 10 + 2 for null terminator and new line feed
    CALCULATION_RESULT_ASCII_BUFFER_LEN equ 12 ; 10 + 2 for null terminator and new line feed

section .bss
    user_choice_ascii_buffer resb USER_CHOICE_ASCII_BUFFER_LEN
    user_num_1_ascii_buffer resb USER_NUM_ASCII_BUFFER_LEN 
    user_num_1_decimal_buffer resd 1 ; For storage after conversion from ASCII
    user_num_2_ascii_buffer resb USER_NUM_ASCII_BUFFER_LEN 
    user_num_2_decimal_buffer resd 1 ; For storage after conversion from ASCII
    calculation_result_ascii_buffer resb CALCULATION_RESULT_ASCII_BUFFER_LEN
    calculation_result_decimal_buffer resd 1

section .text
    global _start

_start:
    call print_title

    _start_main_loop:
        call print_operation_options
        call print_select_operation
        call read_user_operation_choice
        call start_user_selected_operation
        call print_ask_if_user_wants_to_continue
        call read_user_continue_choice
        cmp eax, 1 ; eax stores user's choice (1 - yes, 0 - no)
        je _start_main_loop

    mov eax, 1
    mov ebx, 0
    int 0x80

read_user_operation_choice:
    ; Reads what operation user selects (addition, subtraction etc.).
    push ebp
    mov ebp, esp

    read_user_operation_choice_start:
        ; Clear the buffer from previous inputs
        call clear_user_choice_ascii_buffer

        ; Read stdin buffer
        mov eax, SYS_READ
        mov ebx, STDIN
        mov ecx, user_choice_ascii_buffer
        mov edx, USER_CHOICE_ASCII_BUFFER_LEN
        int 0x80

        ; Making sure all bytes in buffer are numbers
        xor edi, edi ; Zero out loop counter
        mov esi, user_choice_ascii_buffer ; Load buffer

        read_user_operation_choice_loop:
            mov al, byte [esi + edi] ; Get first char in the buffer
            cmp al, 0xa ; Check if it's a new line character
            je read_user_operation_choice_invalid_input

            ; Check if read byte is a digit (and a valid option)
            cmp al, "1"
            jl read_user_operation_choice_invalid_input
            cmp al, "4"
            jg read_user_operation_choice_invalid_input
            
            ; Jump if input is valid (1-4)
            jmp read_user_operation_choice_remove_null_terminator

        read_user_operation_choice_invalid_input:
            mov eax, SYS_WRITE
            mov ebx, STDOUT
            mov ecx, MSG_INVALID_CHOICE
            mov edx, MSG_LEN_INVALID_CHOICE
            int 0x80
            jmp read_user_operation_choice_start ; Read input again if invalid

        read_user_operation_choice_remove_null_terminator:
            mov eax, dword [user_choice_ascii_buffer]
            xor ah, ah
            mov [user_choice_ascii_buffer], eax

    mov esp, ebp
    pop ebp
    ret

read_user_continue_choice:
    ; Reads if user wants to continue after an operation (calculation) was done.
    push ebp
    mov ebp, esp

    read_user_continue_choice_start:
        ; Clear the buffer from previous inputs
        call clear_user_choice_ascii_buffer

        ; Read stdin buffer
        mov eax, SYS_READ
        mov ebx, STDIN
        mov ecx, user_choice_ascii_buffer
        mov edx, USER_CHOICE_ASCII_BUFFER_LEN
        int 0x80

        ; Making sure all bytes in buffer are numbers
        xor edi, edi ; Zero out loop counter
        mov esi, user_choice_ascii_buffer ; Load buffer

        read_user_continue_choice_loop:
            mov al, byte [esi + edi] ; Get first char in the buffer
            cmp al, 0xa ; Check if it's a new line character
            je read_user_continue_choice_invalid_input

            ; Check for a valid option
            cmp al, "y"
            je read_user_continue_choice_y_selected
            cmp al, "Y"
            je read_user_continue_choice_y_selected
            cmp al, "n"
            je read_user_continue_choice_n_selected
            cmp al, "N"
            je read_user_continue_choice_n_selected
            
            ; If input is larger than 2 bytes, consider it invalid (choice + null terminator)
            inc edi
            cmp edi, 1
            je read_user_continue_choice_invalid_input
            jmp read_user_continue_choice_loop

        read_user_continue_choice_invalid_input:
            mov eax, SYS_WRITE
            mov ebx, STDOUT
            mov ecx, MSG_INVALID_CHOICE
            mov edx, MSG_LEN_INVALID_CHOICE
            int 0x80
            jmp read_user_continue_choice_start ; Read input again if invalid

        read_user_continue_choice_y_selected:
            xor eax, eax
            mov eax, 1
            jmp read_user_continue_choice_end

        read_user_continue_choice_n_selected:
            xor eax, eax
            mov eax, 0
            jmp read_user_continue_choice_end

    read_user_continue_choice_end:
        mov esp, ebp
        pop ebp
        ret

clear_user_choice_ascii_buffer:
    push ebp
    mov ebp, esp

    mov esi, user_choice_ascii_buffer ; Load the buffer to clear
    mov ecx, USER_CHOICE_ASCII_BUFFER_LEN ; Load the length of the buffer
    xor eax, eax ; Set eax to 0 (the value to clear the buffer with)

    clear_user_choice_ascii_buffer_loop:
        mov [esi], al ; Set the current byte in the buffer to 0
        inc esi ; Move to the next byte
        loop clear_user_choice_ascii_buffer_loop ; Continue until ecx reaches 0

    mov esp, ebp
    pop ebp
    ret

read_number:
    ; Read user input from STDIN, convert string to decimal and store in buffer.
    ; Arg_1 (ebp+8) - address to buffer that user's input from STDIN (ASCII).
    ; Arg_2 (ebp+12) - address to buffer that will hold decimal representation.
    ; Push both memory addresses on to the stack before calling this function.
    push ebp
    mov ebp, esp

    read_number_start:
        ; Read stdin buffer
        mov eax, SYS_READ
        mov ebx, STDIN
        mov ecx, [ebp + 8]
        mov edx, USER_NUM_ASCII_BUFFER_LEN
        int 0x80

        xor edi, edi ; Zero out loop counter
        mov esi, [ebp + 8] ; Load ASCII buffer

        read_number_loop:
            mov al, byte [esi + edi] ; Get first char in the ASCII buffer
            cmp al, 0xa ; Check if it's a new line character
            je read_number_convert_from_ascii_to_decimal

            ; Check if the read byte represents a digit in hex
            cmp al, "1"
            jl read_number_invalid_input
            cmp al, "9"
            jg read_number_invalid_input
            
            inc edi
            jmp read_number_loop

        read_number_invalid_input:
            mov eax, SYS_WRITE
            mov ebx, STDOUT
            mov ecx, MSG_INVALID_INPUT
            mov edx, MSG_LEN_INVALID_INPUT
            int 0x80
            jmp read_number_start ; Read input again if invalid

        read_number_convert_from_ascii_to_decimal:
            push dword [ebp + 12] ; Pushing the decimal buffer
            push dword [ebp + 8] ; Pushing the ASCII buffer
            call convert_string_to_number
            jmp read_number_end

    read_number_end:
        mov esp, ebp
        pop ebp
        ret

start_user_selected_operation:
    push ebp
    mov ebp, esp

    ; Separator
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, MSG_SEPARATOR
    mov edx, MSG_LEN_SEPARATOR
    int 0x80

    mov eax, dword [user_choice_ascii_buffer]
    cmp eax, "1"
    je start_operation_addition
    cmp eax, "2"
    je start_operation_subtraction
    cmp eax, "3"
    je start_operation_multiplication
    cmp eax, "4"
    je start_operation_division

    start_operation_addition:
        ; Output 'Enter first number: '
        mov eax, SYS_WRITE
        mov ebx, STDOUT
        mov ecx, MSG_ENTER_FIRST_NUMBER
        mov edx, MSG_LEN_ENTER_FIRST_NUMBER
        int 0x80
        ; Read first number
        push user_num_1_decimal_buffer
        push user_num_1_ascii_buffer
        call read_number

        ; Output 'Enter second number: '
        mov eax, SYS_WRITE
        mov ebx, STDOUT
        mov ecx, MSG_ENTER_SECOND_NUMBER
        mov edx, MSG_LEN_ENTER_SECOND_NUMBER
        int 0x80
        ; Read second number
        push user_num_2_decimal_buffer
        push user_num_2_ascii_buffer
        call read_number

        ; Do addition
        mov eax, [user_num_1_decimal_buffer]
        mov ebx, [user_num_2_decimal_buffer]
        add eax, ebx
        mov [calculation_result_decimal_buffer], eax

        ; Convert decimal result to ASCII
        push calculation_result_ascii_buffer
        push calculation_result_decimal_buffer
        call convert_number_to_string

        ; Output 'Result: (string in result buffer)'
        mov eax, SYS_WRITE
        mov ebx, STDOUT
        mov ecx, MSG_CALCULATION_RESULT
        mov edx, MSG_LEN_CALCULATION_RESULT
        int 0x80
        mov eax, SYS_WRITE
        mov ebx, STDOUT
        mov ecx, calculation_result_ascii_buffer
        mov edx, CALCULATION_RESULT_ASCII_BUFFER_LEN
        int 0x80

        ; Separator
        mov eax, SYS_WRITE
        mov ebx, STDOUT
        mov ecx, MSG_SEPARATOR
        mov edx, MSG_LEN_SEPARATOR
        int 0x80

        jmp start_user_selected_operation_finish
        
    start_operation_subtraction:
        ;
        jmp start_user_selected_operation_finish

    start_operation_multiplication:
        ;
        jmp start_user_selected_operation_finish

    start_operation_division:
        ;
        jmp start_user_selected_operation_finish

    start_user_selected_operation_finish:
        mov esp, ebp
        pop ebp
        ret

convert_string_to_number:
    ; Arg_1 (ebp+8) - address to buffer that holds number to be converted in ASCII.
    ; Arg_2 (ebp+12) - address to buffer that will hold the converted number in decimal.
    ; Push both memory addresses on to the stack before calling this function.
    push ebp
    mov ebp, esp

    xor ebx, ebx ; Clear ebx
    mov esi, [ebp + 8] ; Load ASCII buffer (user's string input)

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
        mov edx, [ebp + 12] ; Loading the decimal buffer address into edx
        mov [edx], ebx ; Storing converted value into decimal buffer
        
    mov esp, ebp
    pop ebp
    ret

convert_number_to_string:
    ; Arg_1 (ebp+8) - address to buffer that holds number to be converted in decimal.
    ; Arg_2 (ebp+12) - address to buffer that will hold the converted number in ASCII.
    ; Push both memory addresses on to the stack before calling this function.
    push ebp
    mov ebp, esp

    mov ebx, [ebp + 8] ; Load decimal buffer containing number to be converted
    mov eax, [ebx] ; Load the literal value in the buffer into eax
    xor edi, edi

    ; Convert from decimal to ASCII and push converted characters onto the stack.
    convert_number_to_string_push_to_stack:
        mov edx, 0 ; Fill higher order bits
        mov ecx, 10 ; Divisor
        div ecx
        add edx, "0" ; Convert the remainder to ASCII
        push edx ; Push the converted character onto the stack
        test eax, eax ; If quotient is not 0, keep converting
        jne convert_number_to_string_push_to_stack

    ; Pop characters from the stack into buffer that will contain converted number
    convert_number_to_string_pop_from_stack:
        mov ebx, [ebp + 12] ; Load the address of the buffer
        pop dword [ebx + edi]
        inc edi
        cmp esp, ebp ; If pointing to the same address then there are no more chars
        jne convert_number_to_string_pop_from_stack
        ; Add null terminator and new line feed
        mov byte [ebx + edi], 0
        mov byte [ebx + edi + 1], 0xa

    mov esp, ebp
    pop ebp
    ret

print_title:
    push ebp
    mov ebp, esp

    ; Separator
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, MSG_SEPARATOR
    mov edx, MSG_LEN_SEPARATOR
    int 0x80

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

    ; Separator
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, MSG_SEPARATOR
    mov edx, MSG_LEN_SEPARATOR
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
