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
    MSG_CANT_DIVIDE_BY_ZERO db "Can't divide by zero!", 0xa
    MSG_LEN_CANT_DIVIDE_BY_ZERO equ $ - MSG_CANT_DIVIDE_BY_ZERO
    MSG_RESULT_TOO_SMALL_TO_BE_DISPLAYED db "Result is too small to be displayed!", 0xa
    MSG_LEN_RESULT_TOO_SMALL_TO_BE_DISPLAYED equ $ - MSG_RESULT_TOO_SMALL_TO_BE_DISPLAYED
    USER_CHOICE_ASCII_BUFFER_LEN equ 255
    USER_NUM_ASCII_BUFFER_LEN equ 255
    CALCULATION_RESULT_ASCII_BUFFER_LEN equ 255
    NUMBER_BUFFER_LEN equ 8
    DIVISION_DECIMAL_PRECISION equ 10
    DIVISION_SIGN_FLAG_BUFFER_LEN equ 8


section .bss
    user_choice_ascii_buffer resb USER_CHOICE_ASCII_BUFFER_LEN
    user_num_1_ascii_buffer resb USER_NUM_ASCII_BUFFER_LEN 
    user_num_1_number_buffer resd NUMBER_BUFFER_LEN
    user_num_2_ascii_buffer resb USER_NUM_ASCII_BUFFER_LEN 
    user_num_2_number_buffer resd NUMBER_BUFFER_LEN
    calculation_result_ascii_buffer resb CALCULATION_RESULT_ASCII_BUFFER_LEN
    calculation_result_number_buffer resd NUMBER_BUFFER_LEN
    division_quotient_ascii_buffer resb CALCULATION_RESULT_ASCII_BUFFER_LEN
    division_quotient_number_buffer resd NUMBER_BUFFER_LEN
    division_decimal_ascii_buffer resb CALCULATION_RESULT_ASCII_BUFFER_LEN
    division_decimal_number_buffer resd NUMBER_BUFFER_LEN
    division_decimal_temp_ascii_buffer resb 1
    division_is_negative_dividend resd DIVISION_SIGN_FLAG_BUFFER_LEN
    division_is_negative_divisor resd DIVISION_SIGN_FLAG_BUFFER_LEN
    division_is_negative_final_result resd DIVISION_SIGN_FLAG_BUFFER_LEN

section .text
    global _start

_start:
    call print_separator
    call print_title

    _start_main_loop:
        call print_separator ; Separator
        call print_operation_options
        call print_separator ; Separator
        call print_select_operation
        call read_user_operation_choice
        call print_separator ; Separator
        call start_operation
        call print_separator ; Separator
        call print_ask_if_user_wants_to_continue
        call read_user_continue_choice
        cmp eax, 1 ; eax stores user's choice (1 - yes, 0 - no)
        je _start_main_loop

    mov eax, 1
    mov ebx, 0
    int 0x80

read_user_operation_choice:
    ; Read and validate the user's choice of operation (e.g., addition, subtraction).
    push ebp
    mov ebp, esp

    read_user_operation_choice___read_input:
        mov esi, user_choice_ascii_buffer ; Load buffer address
        mov eax, SYS_READ
        mov ebx, STDIN
        mov ecx, esi
        mov edx, USER_CHOICE_ASCII_BUFFER_LEN
        int 0x80

    read_user_operation_choice___validate_input:
        xor edi, edi
        push esi
        call count_string_length
        ; Reject input if it is empty (only a newline character)
        cmp edi, 1 
        je read_user_operation_choice___reject_input
        ; Reject input if it is longer than 2 characters (only 1 character + null terminator allowed)
        cmp edi, 2
        jg read_user_operation_choice___reject_input
        ; Reject input if the first character in the buffer does not correspond to an operation
        mov al, byte [esi]
        cmp al, "1"
        jl read_user_operation_choice___reject_input
        cmp al, "4"
        jg read_user_operation_choice___reject_input
        ; If all checks pass
        jmp read_user_operation_choice___return

    read_user_operation_choice___reject_input:
        mov eax, SYS_WRITE
        mov ebx, STDOUT
        mov ecx, MSG_INVALID_CHOICE
        mov edx, MSG_LEN_INVALID_CHOICE
        int 0x80
        ; Clear buffer before reading input again
        push USER_CHOICE_ASCII_BUFFER_LEN
        push user_choice_ascii_buffer
        call clear_buffer
        jmp read_user_operation_choice___read_input

    read_user_operation_choice___return:
        mov esp, ebp
        pop ebp
        ret

read_user_continue_choice:
    ; Read if user wants to continue after an operation was done.
    ; Stores the choice in eax register (1 - yes, 0 - no).
    push ebp
    mov ebp, esp

    mov esi, user_choice_ascii_buffer ; Load buffer address

    read_user_continue_choice___read_input:
        ; Read stdin buffer
        mov eax, SYS_READ
        mov ebx, STDIN
        mov ecx, esi
        mov edx, USER_CHOICE_ASCII_BUFFER_LEN
        int 0x80

    read_user_continue_choice___validate_input:
        xor edi, edi
        push esi
        call count_string_length
        ; Reject input if it is empty (only a newline character)
        cmp edi, 1 
        je read_user_continue_choice___reject_input
        ; Reject input if it is longer than 2 characters (only 1 character + null terminator allowed)
        cmp edi, 2
        jg read_user_continue_choice___reject_input        
        ; Reject input if the first character in the buffer is not 'y', 'Y', 'n' or 'N'
        mov al, byte [esi]
        cmp al, "y"
        je read_user_continue_choice___y_selected
        cmp al, "Y"
        je read_user_continue_choice___y_selected
        cmp al, "n"
        je read_user_continue_choice___n_selected
        cmp al, "N"
        je read_user_continue_choice___n_selected
        ; If neither of the characters match
        jmp read_user_continue_choice___reject_input

    read_user_continue_choice___y_selected:
        xor eax, eax
        mov eax, 1
        jmp read_user_continue_choice___return

    read_user_continue_choice___n_selected:
        xor eax, eax
        mov eax, 0
        jmp read_user_continue_choice___return

    read_user_continue_choice___reject_input:
        mov eax, SYS_WRITE
        mov ebx, STDOUT
        mov ecx, MSG_INVALID_CHOICE
        mov edx, MSG_LEN_INVALID_CHOICE
        int 0x80
        ; Clear buffer before reading input again
        push USER_CHOICE_ASCII_BUFFER_LEN
        push user_choice_ascii_buffer
        call clear_buffer
        jmp read_user_continue_choice___read_input

    read_user_continue_choice___return:
        mov esp, ebp
        pop ebp
        ret

read_number:
    ; Read user input from stdin, convert string to number and store in buffer.
    ; Arg_1 (ebp+8) - address to buffer that holds users' input in ASCII.
    ; Arg_2 (ebp+12) - address to buffer that will hold the number.
    push ebp
    mov ebp, esp

    read_number___read_input:
        mov esi, [ebp + 8] ; Load ASCII buffer address (reload the original each time)
        mov eax, SYS_READ
        mov ebx, STDIN
        mov ecx, esi
        mov edx, USER_NUM_ASCII_BUFFER_LEN
        int 0x80

    read_number___validate_input:
        xor edi, edi
        mov al, byte [esi] ; Get the first character from the ASCII buffer
        ; Reject input if it is empty (only a new line character)
        cmp al, 0xa
        je read_number___reject_input
        ; Reject input if user typed "-" + Enter (new line character)
        cmp al, "-"
        jne read_number___verify_all_chars_in_buffer_are_digits ; No need to check second char if number is positive
        inc esi ; Make buffer pointer point at the second char
        cmp byte [esi], 0xa
        je read_number___reject_input
    
    read_number___verify_all_chars_in_buffer_are_digits:
        mov al, byte [esi + edi]
        cmp al, 0xa
        je read_number___convert_from_ascii_to_number
        ; Check if the read byte is a digit
        cmp al, "0"
        jl read_number___reject_input
        cmp al, "9"
        jg read_number___reject_input
        inc edi
        ; Continue reading untill new line character
        jmp read_number___verify_all_chars_in_buffer_are_digits

    read_number___reject_input:
        mov eax, SYS_WRITE
        mov ebx, STDOUT
        mov ecx, MSG_INVALID_INPUT
        mov edx, MSG_LEN_INVALID_INPUT
        int 0x80
        jmp read_number___read_input

    read_number___convert_from_ascii_to_number:
        push dword [ebp + 12] ; Pushing the number buffer
        push dword [ebp + 8] ; Pushing the ASCII buffer
        call convert_string_to_number

    mov esp, ebp
    pop ebp
    ret

start_operation:
    ; Start the operation selected by the user (e.g., addition, subtraction).
    push ebp
    mov ebp, esp

    ; Output 'Enter first number: '
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, MSG_ENTER_FIRST_NUMBER
    mov edx, MSG_LEN_ENTER_FIRST_NUMBER
    int 0x80

    ; Read first number
    push user_num_1_number_buffer
    push user_num_1_ascii_buffer
    call read_number

    ; Output 'Enter second number: '
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, MSG_ENTER_SECOND_NUMBER
    mov edx, MSG_LEN_ENTER_SECOND_NUMBER
    int 0x80
    
    ; Read second number
    push user_num_2_number_buffer
    push user_num_2_ascii_buffer
    call read_number

    ; Perform operation based on user's choice
    mov al, byte [user_choice_ascii_buffer]
    cmp al, "1"
    je addition
    cmp al, "2"
    je subtraction
    cmp al, "3"
    je multiplication
    cmp al, "4"
    je division

    addition:
        mov eax, [user_num_1_number_buffer]
        mov ebx, [user_num_2_number_buffer]
        add eax, ebx
        mov [calculation_result_number_buffer], eax
        jmp start_operation___convert_result_from_number_to_ascii
   
    subtraction:
        mov eax, [user_num_1_number_buffer]
        mov ebx, [user_num_2_number_buffer]
        sub eax, ebx
        mov [calculation_result_number_buffer], eax
        jmp start_operation___convert_result_from_number_to_ascii

    multiplication:
        mov eax, [user_num_1_number_buffer]
        mov ebx, [user_num_2_number_buffer]
        imul eax, ebx
        mov [calculation_result_number_buffer], eax
        jmp start_operation___convert_result_from_number_to_ascii

    division:
        division___get_result_sign:
            division___get_result_sign___check_if_dividend_is_negative:
                mov eax, [user_num_1_number_buffer]
                test eax, eax
                jns division___get_result_sign___check_if_divisor_is_negative
                mov byte [division_is_negative_dividend], 1 ; Set flag to indicate negativity

            division___get_result_sign___check_if_divisor_is_negative:
                mov eax, [user_num_2_number_buffer]
                test eax, eax
                jns division___get_result_sign___set_flag
                mov byte [division_is_negative_divisor], 1 ; Set flag to indicate negativity

            division___get_result_sign___set_flag:
                mov eax, [division_is_negative_dividend]
                mov ebx, [division_is_negative_divisor]
                add eax, ebx
                cmp eax, 1 ; If sum of flags is 1, then the final result will be negative
                je division___get_result_sign___set_flag___set_negative
                mov byte [division_is_negative_final_result], 0
                jmp division___get_quotient_part

                division___get_result_sign___set_flag___set_negative:
                    mov byte [division_is_negative_final_result], 1

        division___get_quotient_part:
            xor edx, edx ; Prepare edx for division
            mov eax, [user_num_1_number_buffer] ; Load dividend
            mov ecx, [user_num_2_number_buffer] ; Load divisor
            cmp ecx, 0 ; Prevent division by 0
            je division___print_cant_divide_by_zero
            ; Sign-extend eax into edx:eax if dividend is negative
            test eax, eax 
            jns division___get_quotient_part___divide
            cdq

            division___get_quotient_part___divide:
                idiv ecx
                mov [division_quotient_number_buffer], eax
                push edx ; Save remainder on the stack

            division___get_quotient_part___check_zero_quotient:
                ; If quotient is zero and negative flag is set, then
                ; append "-" and "0" to the quotient ASCII buffer. Otherwise
                ; convert the quotient to ASCII straight away.
                cmp eax, 0
                jnz division___get_quotient_part___convert_to_ascii
                mov eax, [division_is_negative_final_result]
                cmp eax, 0
                je division___get_quotient_part___convert_to_ascii
                mov byte [division_quotient_ascii_buffer], "-"
                mov byte [division_quotient_ascii_buffer + 1], "0"
                jmp division___get_decimal_part

            division___get_quotient_part___convert_to_ascii:
                push division_quotient_ascii_buffer
                push division_quotient_number_buffer
                call convert_number_to_string
                add esp, 8

        division___get_decimal_part:
            division___get_decimal_part___prepare_divisor:
                ; Make sure the divisor is positive
                mov ebx, [user_num_2_number_buffer]
                test ebx, ebx
                jns division___get_decimal_part___prepare_remainder
                neg ebx
                mov [user_num_2_number_buffer], ebx
            
            division___get_decimal_part___prepare_remainder:
                ; Make sure the remainder is positive
                pop edx ; Restore remainder from the stack
                test edx, edx
                jns division___get_decimal_part___calculate
                neg edx

            division___get_decimal_part___calculate:         
                ; Initiate decimal part length counter
                xor edi, edi
                push edi
                division___get_decimal_part___calculate___loop:
                    ; Multiply remainder by 10
                    mov eax, edx
                    imul eax, 10

                    ; Check for overflow. If it occured then it means the decimal 
                    ; part is too small to be displayed.
                    jo division___print_result_too_small_to_display

                    ; Divide the scaled remainder by the original divisor
                    xor edx, edx
                    mov ebx, [user_num_2_number_buffer]
                    idiv ebx

                    ; Save remainder of division on the stack
                    push edx

                    ; Store quotient part in buffer
                    mov [division_decimal_number_buffer], eax

                    ; Convert quotient part to ASCII
                    push division_decimal_temp_ascii_buffer
                    push division_decimal_number_buffer
                    call convert_number_to_string
                    add esp, 8
                    ; Clear division_decimal_number_buffer
                    push NUMBER_BUFFER_LEN
                    push division_decimal_number_buffer
                    call clear_buffer
                    add esp, 8

                    ; Restore remainder and decimal part length from the stack
                    pop edx
                    pop edi

                    ; Move the converted digit to the buffer that stores whole decimal part
                    mov al, byte [division_decimal_temp_ascii_buffer]
                    lea ecx, division_decimal_ascii_buffer
                    mov [ecx + edi], al
                    inc edi ; Increment the decimal part digit count
                    push edi ; Save digit count on the stack

                    ; Check if remainder is 0 (meaning decimal part calculation can stop)
                    cmp edx, 0
                    je division___concatenate_quotient_and_decimal_parts

                    ; Check if we have reached the maximum wanted precision
                    cmp edi, DIVISION_DECIMAL_PRECISION
                    jl division___get_decimal_part___calculate___loop

        division___concatenate_quotient_and_decimal_parts:
            ; Copy quotient buffer content to calculation result buffer
            xor edi, edi
            push division_quotient_ascii_buffer
            call count_string_length
            mov ecx, edi
            mov esi, division_quotient_ascii_buffer
            mov edi, calculation_result_ascii_buffer
            cld
            rep movsb

            ; Add decimal point and null terminator after the quotient in the calculation result buffer
            xor edi, edi
            push calculation_result_ascii_buffer
            call count_string_length
            mov esi, calculation_result_ascii_buffer
            mov byte [esi + edi], "."
            inc edi
            mov byte [esi + edi], 0
            
            ; Set ebx to point to byte after "." in the calculation result buffer
            lea ebx, calculation_result_ascii_buffer
            add ebx, edi 

            ; Copy decimal buffer content to calculation result buffer after the "."
            xor edi, edi
            push division_decimal_ascii_buffer
            call count_string_length
            mov ecx, edi
            mov esi, division_decimal_ascii_buffer
            mov edi, ebx
            cld
            rep movsb

            ; Add new line feed and null terminator 
            ; Makes separator print on a new line after printing the result
            mov byte [edi], 0xa
            mov byte [edi + 1], 0

            jmp start_operation___print_calculation_result

        division___print_cant_divide_by_zero:
            mov eax, SYS_WRITE
            mov ebx, STDOUT
            mov ecx, MSG_CANT_DIVIDE_BY_ZERO
            mov edx, MSG_LEN_CANT_DIVIDE_BY_ZERO
            int 0x80
            jmp start_operation___clear_all_buffers

        division___print_result_too_small_to_display:
            mov eax, SYS_WRITE
            mov ebx, STDOUT
            mov ecx, MSG_RESULT_TOO_SMALL_TO_BE_DISPLAYED
            mov edx, MSG_LEN_RESULT_TOO_SMALL_TO_BE_DISPLAYED
            int 0x80
            jmp start_operation___clear_all_buffers

    start_operation___convert_result_from_number_to_ascii:
        push calculation_result_ascii_buffer
        push calculation_result_number_buffer
        call convert_number_to_string

    start_operation___print_calculation_result:
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

    start_operation___clear_all_buffers:
        call clear_all_buffers

    mov esp, ebp
    pop ebp
    ret

convert_string_to_number:
    ; Convert ASCII representation of a number into a literal number and store in buffer.
    ; Arg_1 (ebp+8) - address to buffer that holds number to be converted in ASCII.
    ; Arg_2 (ebp+12) - address to buffer that will hold the converted number.
    push ebp
    mov ebp, esp

    mov esi, [ebp + 8] ; Load ASCII buffer address from the stack

    ; Clear registers
    xor ebx, ebx ; Clear ebx (used during conversion to store final number value)
    xor ecx, ecx ; Clear ecx (used for storing a flag to indicate whether the number is negative or not)

    ; Check if the string in ASCII buffer starts with a '-' (negative number)
    movzx eax, byte [esi] ; Load first char from buffer
    cmp al, "-" ; Check if the character is a dash
    jne convert_string_to_number___loop ; Jump to the conversion loop if it's not a dash
    inc esi ; If it's a dash, move the buffer pointer to the second character
    mov ecx, 1 ; Set a flag to indicate whether the number is negative or not (1 if negative, 0 if positive)

    convert_string_to_number___loop:
        movzx eax, byte [esi] ; Load next character from buffer
        inc esi
        cmp al, 0x0a ; Check if loaded byte is a new line character
        je convert_string_to_number___save_converted_number
        sub al, '0'; Convert from ASCII to number
        imul ebx, 10 ; Multiply ebx by 10
        add ebx, eax ; ebx = ebx * 10 + eax
        jmp convert_string_to_number___loop

    convert_string_to_number___save_converted_number:
        mov edx, [ebp + 12] ; Loading the number buffer address into edx
        test ecx, ecx; Check the number flag that was set at the start
        jz convert_string_to_number___store_value_into_buffer ; If zero (positive)
        neg ebx ; Negate the final number (if flag is non zero)
        convert_string_to_number___store_value_into_buffer:
            mov [edx], ebx
        
    mov esp, ebp
    pop ebp
    ret

convert_number_to_string:
    ; Convert a literal number to its ASCII representation and store in buffer.
    ; Arg_1 (ebp+8) - address to buffer that holds the number to be converted.
    ; Arg_2 (ebp+12) - address to buffer that will hold the converted number.
    push ebp
    mov ebp, esp

    mov ebx, [ebp + 8] ; Load number buffer address
    mov eax, [ebx] ; Load the literal value in the buffer into eax

    convert_number_to_string___check_if_number_is_negative:
        cmp eax, 0
        jge convert_number_to_string___push_to_stack ; Jump if value is non-negative

        ; If the value in buffer is negative
        neg eax ; Convert the value to positive
        mov ebx, [ebp + 12] ; Load the starting address of the ASCII buffer
        mov [ebx], byte "-" ; Add '-' to the first element of the buffer
        inc ebx ; Increment buffer pointer so it points to the second element (an empty space)
        mov [ebp + 12], ebx ; Overwrite the old buffer starting address with the new one
    
    ; Convert from number to ASCII and push converted characters onto the stack.
    convert_number_to_string___push_to_stack:
        mov edx, 0 ; Fill higher order bits
        mov ecx, 10 ; Divisor
        idiv ecx
        add edx, "0" ; Convert the remainder to ASCII
        push edx ; Push the converted character onto the stack
        test eax, eax ; If quotient is not 0, keep converting
        jne convert_number_to_string___push_to_stack

    ; Pop characters from the stack into buffer that will contain the converted number
    xor edi, edi ; Clear edi register
    convert_number_to_string___pop_from_stack:
        mov ebx, [ebp + 12] ; Load the address of the buffer
        pop dword [ebx + edi] ; Pop character from stack
        inc edi
        cmp esp, ebp ; If pointing to the same address then there are no more chars
        jne convert_number_to_string___pop_from_stack
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

    clear_buffer___loop:
        mov [esi], al ; Set the current byte in the buffer to 0
        inc esi ; Move to the next byte
        loop clear_buffer___loop ; Continue until ecx reaches 0

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
    push CALCULATION_RESULT_ASCII_BUFFER_LEN
    push division_quotient_ascii_buffer
    call clear_buffer
    push CALCULATION_RESULT_ASCII_BUFFER_LEN
    push division_decimal_ascii_buffer
    call clear_buffer

    ; Clear all number buffers
    push NUMBER_BUFFER_LEN
    push user_num_1_number_buffer
    call clear_buffer
    push NUMBER_BUFFER_LEN 
    push user_num_2_number_buffer
    call clear_buffer
    push NUMBER_BUFFER_LEN 
    push calculation_result_number_buffer
    call clear_buffer
    push NUMBER_BUFFER_LEN
    push division_quotient_number_buffer
    call clear_buffer
    push NUMBER_BUFFER_LEN
    push division_decimal_number_buffer
    call clear_buffer

    ; Clear division flag buffers
    push DIVISION_SIGN_FLAG_BUFFER_LEN
    push division_is_negative_dividend
    call clear_buffer
    push DIVISION_SIGN_FLAG_BUFFER_LEN
    push division_is_negative_divisor
    call clear_buffer
    push DIVISION_SIGN_FLAG_BUFFER_LEN
    push division_is_negative_final_result
    call clear_buffer

    mov esp, ebp
    pop ebp
    ret

count_string_length:
    ; Counts length of string stored in a buffer. Value is saved in edi register. Includes the null terminator.
    ; Arg_1 (ebp+8) - buffer that holds the string.
    push ebp
    mov ebp, esp

    xor edi, edi
    mov esi, [ebp + 8]
    
    count_string_length___loop:
        mov al, byte [esi + edi]
        cmp al, 0
        je count_string_length___return
        inc edi
        jne count_string_length___loop

    count_string_length___return:
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
