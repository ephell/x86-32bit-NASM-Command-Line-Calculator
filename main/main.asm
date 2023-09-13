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
    USER_NUM_ASCII_BUFFER_LEN equ 13 ; 10 + 3 for null terminator, new line feed and '-' for negative numbers
    CALCULATION_RESULT_ASCII_BUFFER_LEN equ 13 ; 10 + 3 for null terminator, new line feed and '-' for negative numbers
    DECIMAL_BUFFER_LEN equ 4

section .bss
    user_choice_ascii_buffer resb USER_CHOICE_ASCII_BUFFER_LEN
    user_num_1_ascii_buffer resb USER_NUM_ASCII_BUFFER_LEN 
    user_num_1_decimal_buffer resd DECIMAL_BUFFER_LEN ; For storage after conversion from ASCII
    user_num_2_ascii_buffer resb USER_NUM_ASCII_BUFFER_LEN 
    user_num_2_decimal_buffer resd DECIMAL_BUFFER_LEN ; For storage after conversion from ASCII
    calculation_result_ascii_buffer resb CALCULATION_RESULT_ASCII_BUFFER_LEN
    calculation_result_decimal_buffer resd DECIMAL_BUFFER_LEN

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
        ; Read stdin buffer
        mov eax, SYS_READ
        mov ebx, STDIN
        mov ecx, user_choice_ascii_buffer
        mov edx, USER_CHOICE_ASCII_BUFFER_LEN
        int 0x80

        mov esi, user_choice_ascii_buffer ; Load buffer
        xor edi, edi ; Clear edi register

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
            ; Clear buffer before reading input again
            push USER_CHOICE_ASCII_BUFFER_LEN
            push user_choice_ascii_buffer
            call clear_buffer
            add esp, 8
            jmp read_user_operation_choice_start

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
        ; Read stdin buffer
        mov eax, SYS_READ
        mov ebx, STDIN
        mov ecx, user_choice_ascii_buffer
        mov edx, USER_CHOICE_ASCII_BUFFER_LEN
        int 0x80

        mov esi, user_choice_ascii_buffer ; Load buffer
        xor edi, edi ; Clear edi register

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
            ; Clear buffer before reading input again
            push USER_CHOICE_ASCII_BUFFER_LEN
            push user_choice_ascii_buffer
            call clear_buffer
            add esp, 8
            jmp read_user_continue_choice_start

        read_user_continue_choice_y_selected:
            xor eax, eax
            mov eax, 1
            jmp read_user_continue_choice_end

        read_user_continue_choice_n_selected:
            xor eax, eax
            mov eax, 0

    read_user_continue_choice_end:
        mov esp, ebp
        pop ebp
        ret

read_number:
    ; Read user input from STDIN, convert string to decimal and store in buffer.
    ; Arg_1 (ebp+8) - address to buffer that user's input from STDIN (ASCII).
    ; Arg_2 (ebp+12) - address to buffer that will hold decimal representation.
    push ebp
    mov ebp, esp

    read_number_start:
        ; Read stdin buffer
        mov eax, SYS_READ
        mov ebx, STDIN
        mov ecx, [ebp + 8]
        mov edx, USER_NUM_ASCII_BUFFER_LEN
        int 0x80

        mov esi, [ebp + 8] ; Load ASCII buffer
        xor edi, edi ; Clear edi register

        ; Check for invalid input scenarios:
        ; - User pressed Enter without typing anything
        ; - User typed only a dash and pressed Enter
        mov al, byte [esi]  ; Get the first character from the ASCII buffer
        cmp al, 0xa ; Check if it's a new line character (Enter key)
        je read_number_invalid_input
        cmp al, "-" ; Check if the first character is a dash
        je read_number_check_second_character
        jmp read_number_verify_all_chars_in_buffer_are_digits ; If there's no dash, jump into verifying loop
        ; Prevents the user from entering a dash and immediately pressing Enter
        read_number_check_second_character:
            inc esi
            cmp byte [esi], 0xa
            je read_number_invalid_input
            
        read_number_verify_all_chars_in_buffer_are_digits:
            mov al, byte [esi + edi] ; Get first char in the ASCII buffer
            cmp al, 0xa ; Check if it's a new line character
            je read_number_convert_from_ascii_to_decimal
            ; Check if the read byte is a digit
            cmp al, "0"
            jl read_number_invalid_input
            cmp al, "9"
            jg read_number_invalid_input
            inc edi
            jmp read_number_verify_all_chars_in_buffer_are_digits

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

    ; Perform operation based on user's choice
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
        mov eax, [user_num_1_decimal_buffer]
        mov ebx, [user_num_2_decimal_buffer]
        add eax, ebx
        mov [calculation_result_decimal_buffer], eax
        jmp start_user_selected_operation_finish
   
    start_operation_subtraction:
        mov eax, [user_num_1_decimal_buffer]
        mov ebx, [user_num_2_decimal_buffer]
        sub eax, ebx
        mov [calculation_result_decimal_buffer], eax
        jmp start_user_selected_operation_finish

    start_operation_multiplication:
        jmp start_user_selected_operation_finish

    start_operation_division:
        jmp start_user_selected_operation_finish

    start_user_selected_operation_finish:
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

    call clear_all_buffers

    mov esp, ebp
    pop ebp
    ret

convert_string_to_number:
    ; Arg_1 (ebp+8) - address to buffer that holds number to be converted in ASCII.
    ; Arg_2 (ebp+12) - address to buffer that will hold the converted number in decimal.
    push ebp
    mov ebp, esp

    mov esi, [ebp + 8] ; Load ASCII buffer address from the stack

    ; Clear registers
    xor ebx, ebx ; Clear ebx (used during conversion to store final number value)
    xor ecx, ecx ; Clear ecx (used for storing a flag to indicate whether the number is negative or not)

    ; Check if the string in ASCII buffer starts with a '-' (negative number)
    movzx eax, byte [esi] ; Load first char from buffer
    cmp al, "-" ; Check if the character is a dash
    jne convert_string_to_number_loop ; Jump to the conversion loop if it's not a dash
    inc esi ; If it's a dash, move the buffer pointer to the second character
    mov ecx, 1 ; Set a flag to indicate whether the number is negative or not (1 if negative, 0 if positive)

    convert_string_to_number_loop:
        movzx eax, byte [esi] ; Load next character from buffer
        inc esi
        cmp al, 0x0a ; Check if loaded byte is a new line character
        je convert_string_to_number_save_converted_number
        sub al, '0'; Convert from ASCII to number
        imul ebx, 10 ; Multiply ebx by 10
        add ebx, eax ; ebx = ebx * 10 + eax
        jmp convert_string_to_number_loop

    convert_string_to_number_save_converted_number:
        mov edx, [ebp + 12] ; Loading the decimal buffer address into edx
        test ecx, ecx; Check the number flag that was set at the start
        jz convert_string_to_number_store_value_into_buffer ; If zero (positive)
        neg ebx ; Negate the final number (if flag is non zero)
        convert_string_to_number_store_value_into_buffer:
            mov [edx], ebx
        
    mov esp, ebp
    pop ebp
    ret

convert_number_to_string:
    ; Arg_1 (ebp+8) - address to buffer that holds number to be converted in decimal.
    ; Arg_2 (ebp+12) - address to buffer that will hold the converted number in ASCII.
    push ebp
    mov ebp, esp

    mov ebx, [ebp + 8] ; Load decimal buffer containing number to be converted
    mov eax, [ebx] ; Load the literal value in the buffer into eax

    convert_number_to_string_check_if_number_is_negative:
        cmp eax, 0
        jge convert_number_to_string_push_to_stack ; Jump if value is non-negative

        ; If the value in buffer is negative
        neg eax ; Convert the value to positive
        mov ebx, [ebp + 12] ; Load the starting address of the ASCII buffer
        mov [ebx], byte "-" ; Add '-' to the first element of the buffer
        inc ebx ; Increment buffer pointer so it points to the second element (an empty space)
        mov [ebp + 12], ebx ; Overwrite the old buffer starting address with the new one
    
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
    xor edi, edi ; Clear edi register
    convert_number_to_string_pop_from_stack:
        mov ebx, [ebp + 12] ; Load the address of the buffer
        pop dword [ebx + edi] ; Pop character from stack
        inc edi
        cmp esp, ebp ; If pointing to the same address then there are no more chars
        jne convert_number_to_string_pop_from_stack
        ; Add null terminator and new line feed
        mov byte [ebx + edi], 0
        mov byte [ebx + edi + 1], 0xa

    mov esp, ebp
    pop ebp
    ret

clear_buffer:
    ; Set all bytes to 0 in buffer.
    ; Arg_1 (ebp+8) - address of the buffer to clear.
    ; Arg_2 (ebp+12) - length of the buffer.
    push ebp
    mov ebp, esp

    mov esi, [ebp + 8] ; Load the buffer to clear
    mov ecx, [ebp + 12] ; Load the length of the buffer
    xor eax, eax ; Set eax to 0 (the value to clear the buffer with)

    clear_buffer_loop:
        mov [esi], al ; Set the current byte in the buffer to 0
        inc esi ; Move to the next byte
        loop clear_buffer_loop ; Continue until ecx reaches 0

    mov esp, ebp
    pop ebp
    ret

clear_all_buffers:
    push ebp
    mov ebp, esp

    ; Clear all ASCII buffers
    push USER_CHOICE_ASCII_BUFFER_LEN
    push user_choice_ascii_buffer
    call clear_buffer
    push USER_NUM_ASCII_BUFFER_LEN 
    push user_num_1_ascii_buffer
    call clear_buffer
    push USER_NUM_ASCII_BUFFER_LEN 
    push user_num_2_ascii_buffer
    call clear_buffer
    push CALCULATION_RESULT_ASCII_BUFFER_LEN 
    push calculation_result_ascii_buffer
    call clear_buffer

    ; Clear all decimal buffers
    push DECIMAL_BUFFER_LEN
    push user_num_1_decimal_buffer
    call clear_buffer
    push DECIMAL_BUFFER_LEN 
    push user_num_2_decimal_buffer
    call clear_buffer
    push DECIMAL_BUFFER_LEN 
    push calculation_result_decimal_buffer
    call clear_buffer

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
