; 'op.asm'
; Contains logic for performing arithmetic operations on numbers.

SYS_WRITE equ 4
STDOUT equ 1

section .data
    ; Messages
    MSG_ENTER_FIRST_NUMBER db "Enter first number: "
    MSG_LEN_ENTER_FIRST_NUMBER equ $ - MSG_ENTER_FIRST_NUMBER
    MSG_ENTER_SECOND_NUMBER db "Enter second number: "
    MSG_LEN_ENTER_SECOND_NUMBER equ $ - MSG_ENTER_SECOND_NUMBER
    MSG_CALCULATION_RESULT db "Result: "
    MSG_LEN_CALCULATION_RESULT equ $ - MSG_CALCULATION_RESULT
    MSG_CANT_DIVIDE_BY_ZERO db "Can't divide by zero!", 0xa
    MSG_LEN_CANT_DIVIDE_BY_ZERO equ $ - MSG_CANT_DIVIDE_BY_ZERO
    MSG_RESULT_TOO_SMALL_TO_BE_DISPLAYED db "Result is too small to be displayed!", 0xa
    MSG_LEN_RESULT_TOO_SMALL_TO_BE_DISPLAYED equ $ - MSG_RESULT_TOO_SMALL_TO_BE_DISPLAYED
    ; Constants
    OP___RESULT___ASCII_BUFFER_LEN equ 255
    OP___RESULT___NUMBER_BUFFER_LEN equ 32
    OP___DIV___QUOTIENT_ASCII_BUFFER_LEN equ 255
    OP___DIV___QUOTIENT_NUMBER_BUFFER_LEN equ 32
    OP___DIV___DECIMAL_ASCII_BUFFER_LEN equ 255
    OP___DIV___DECIMAL_NUMBER_BUFFER_LEN equ 32
    OP___DIV___DECIMAL_TEMP_ASCII_BUFFER_LEN equ 1
    OP___DIV___SIGN_FLAG_BUFFER_LEN equ 32
    OP___DIV___DECIMAL_PRECISION equ 10

section .bss
    op___result___ascii_buffer resb OP___RESULT___ASCII_BUFFER_LEN
    op___result___number_buffer resb OP___RESULT___NUMBER_BUFFER_LEN
    op___div___quotient_ascii_buffer resb OP___DIV___QUOTIENT_ASCII_BUFFER_LEN
    op___div___quotient_number_buffer resb OP___DIV___QUOTIENT_NUMBER_BUFFER_LEN
    op___div___decimal_ascii_buffer resb OP___DIV___DECIMAL_ASCII_BUFFER_LEN
    op___div___decimal_number_buffer resb OP___DIV___DECIMAL_NUMBER_BUFFER_LEN
    op___div___decimal_temp_ascii_buffer resb OP___DIV___DECIMAL_TEMP_ASCII_BUFFER_LEN
    op___div___is_negative_dividend_buffer resb OP___DIV___SIGN_FLAG_BUFFER_LEN
    op___div___is_negative_divisor_buffer resb OP___DIV___SIGN_FLAG_BUFFER_LEN
    op___div___is_negative_final_result_buffer resb OP___DIV___SIGN_FLAG_BUFFER_LEN

section .text
    global _start
    ; --------------------------------------
    ; Imports
    ; --------------------------------------
    ; Functions
    extern utility___count_string_length
    extern utility___convert_num_to_str
    extern utility___clear_buffer
    extern input___read_number
    ; Buffers
    extern input___operation_choice_ascii_buffer
    extern input___operand_1_ascii_buffer
    extern input___operand_1_number_buffer
    extern input___operand_2_ascii_buffer
    extern input___operand_2_number_buffer
    ; --------------------------------------
    ; Exports
    ; --------------------------------------
    ; Functions
    global op___start_operation
    ; Buffers
    global op___result___ascii_buffer
    global op___result___number_buffer
    global op___div___quotient_ascii_buffer
    global op___div___quotient_number_buffer
    global op___div___decimal_ascii_buffer
    global op___div___decimal_number_buffer
    global op___div___decimal_temp_ascii_buffer
    global op___div___is_negative_dividend_buffer
    global op___div___is_negative_divisor_buffer
    global op___div___is_negative_final_result_buffer
    ; Constants
    global OP___RESULT___ASCII_BUFFER_LEN
    global OP___RESULT___NUMBER_BUFFER_LEN
    global OP___DIV___QUOTIENT_ASCII_BUFFER_LEN
    global OP___DIV___QUOTIENT_NUMBER_BUFFER_LEN
    global OP___DIV___DECIMAL_ASCII_BUFFER_LEN
    global OP___DIV___DECIMAL_NUMBER_BUFFER_LEN
    global OP___DIV___DECIMAL_TEMP_ASCII_BUFFER_LEN
    global OP___DIV___SIGN_FLAG_BUFFER_LEN

op___start_operation:
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
    push input___operand_1_number_buffer
    push input___operand_1_ascii_buffer
    call input___read_number

    ; Output 'Enter second number: '
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, MSG_ENTER_SECOND_NUMBER
    mov edx, MSG_LEN_ENTER_SECOND_NUMBER
    int 0x80
    
    ; Read second number
    push input___operand_2_number_buffer
    push input___operand_2_ascii_buffer
    call input___read_number

    ; Perform operation based on user's choice
    mov al, byte [input___operation_choice_ascii_buffer]
    cmp al, "1"
    je addition
    cmp al, "2"
    je subtraction
    cmp al, "3"
    je multiplication
    cmp al, "4"
    je division

    addition:
        mov eax, [input___operand_1_number_buffer]
        mov ebx, [input___operand_2_number_buffer]
        add eax, ebx
        mov [op___result___number_buffer], eax
        jmp op___start_operation___convert_result_from_number_to_ascii
   
    subtraction:
        mov eax, [input___operand_1_number_buffer]
        mov ebx, [input___operand_2_number_buffer]
        sub eax, ebx
        mov [op___result___number_buffer], eax
        jmp op___start_operation___convert_result_from_number_to_ascii

    multiplication:
        mov eax, [input___operand_1_number_buffer]
        mov ebx, [input___operand_2_number_buffer]
        imul eax, ebx
        mov [op___result___number_buffer], eax
        jmp op___start_operation___convert_result_from_number_to_ascii

    division:
        division___get_result_sign:
            division___get_result_sign___check_if_dividend_is_negative:
                mov eax, [input___operand_1_number_buffer]
                test eax, eax
                jns division___get_result_sign___check_if_divisor_is_negative
                mov byte [op___div___is_negative_dividend_buffer], 1 ; Set flag to indicate negativity

            division___get_result_sign___check_if_divisor_is_negative:
                mov eax, [input___operand_2_number_buffer]
                test eax, eax
                jns division___get_result_sign___set_flag
                mov byte [op___div___is_negative_divisor_buffer], 1 ; Set flag to indicate negativity

            division___get_result_sign___set_flag:
                mov eax, [op___div___is_negative_dividend_buffer]
                mov ebx, [op___div___is_negative_divisor_buffer]
                add eax, ebx
                cmp eax, 1 ; If sum of flags is 1, then the final result will be negative
                je division___get_result_sign___set_flag___set_negative
                mov byte [op___div___is_negative_final_result_buffer], 0
                jmp division___get_quotient_part

                division___get_result_sign___set_flag___set_negative:
                    mov byte [op___div___is_negative_final_result_buffer], 1

        division___get_quotient_part:
            xor edx, edx ; Prepare edx for division
            mov eax, [input___operand_1_number_buffer] ; Load dividend
            mov ecx, [input___operand_2_number_buffer] ; Load divisor
            cmp ecx, 0 ; Prevent division by 0
            je division___print_cant_divide_by_zero
            ; Sign-extend eax into edx:eax if dividend is negative
            test eax, eax 
            jns division___get_quotient_part___divide
            cdq

            division___get_quotient_part___divide:
                idiv ecx
                mov [op___div___quotient_number_buffer], eax
                push edx ; Save remainder on the stack

            division___get_quotient_part___check_zero_quotient:
                ; If quotient is zero and negative flag is set, then
                ; append "-" and "0" to the quotient ASCII buffer. Otherwise
                ; convert the quotient to ASCII straight away.
                cmp eax, 0
                jnz division___get_quotient_part___convert_to_ascii
                mov eax, [op___div___is_negative_final_result_buffer]
                cmp eax, 0
                je division___get_quotient_part___convert_to_ascii
                mov byte [op___div___quotient_ascii_buffer], "-"
                mov byte [op___div___quotient_ascii_buffer + 1], "0"
                jmp division___get_decimal_part

            division___get_quotient_part___convert_to_ascii:
                push op___div___quotient_ascii_buffer
                push op___div___quotient_number_buffer
                call utility___convert_num_to_str
                add esp, 8

        division___get_decimal_part:
            division___get_decimal_part___prepare_divisor:
                ; Make sure the divisor is positive
                mov ebx, [input___operand_2_number_buffer]
                test ebx, ebx
                jns division___get_decimal_part___prepare_remainder
                neg ebx
                mov [input___operand_2_number_buffer], ebx
            
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
                    mov ebx, [input___operand_2_number_buffer]
                    idiv ebx

                    ; Save remainder of division on the stack
                    push edx

                    ; Store quotient part in buffer
                    mov [op___div___decimal_number_buffer], eax

                    ; Convert quotient part to ASCII
                    push op___div___decimal_temp_ascii_buffer
                    push op___div___decimal_number_buffer
                    call utility___convert_num_to_str
                    add esp, 8
                    ; Clear op___div___decimal_number_buffer
                    push OP___DIV___DECIMAL_NUMBER_BUFFER_LEN
                    push op___div___decimal_number_buffer
                    call utility___clear_buffer
                    add esp, 8

                    ; Restore remainder and decimal part length from the stack
                    pop edx
                    pop edi

                    ; Move the converted digit to the buffer that stores whole decimal part
                    mov al, byte [op___div___decimal_temp_ascii_buffer]
                    lea ecx, op___div___decimal_ascii_buffer
                    mov [ecx + edi], al
                    inc edi ; Increment the decimal part digit count
                    push edi ; Save digit count on the stack

                    ; Check if remainder is 0 (meaning decimal part calculation can stop)
                    cmp edx, 0
                    je division___concatenate_quotient_and_decimal_parts

                    ; Check if we have reached the maximum wanted precision
                    cmp edi, OP___DIV___DECIMAL_PRECISION
                    jl division___get_decimal_part___calculate___loop

        division___concatenate_quotient_and_decimal_parts:
            ; Copy quotient buffer content to calculation result buffer
            xor edi, edi
            push op___div___quotient_ascii_buffer
            call utility___count_string_length
            mov ecx, edi
            mov esi, op___div___quotient_ascii_buffer
            mov edi, op___result___ascii_buffer
            cld
            rep movsb

            ; Add decimal point and null terminator after the quotient in the calculation result buffer
            xor edi, edi
            push op___result___ascii_buffer
            call utility___count_string_length
            mov esi, op___result___ascii_buffer
            mov byte [esi + edi], "."
            inc edi
            mov byte [esi + edi], 0
            
            ; Set ebx to point to byte after "." in the calculation result buffer
            lea ebx, op___result___ascii_buffer
            add ebx, edi 

            ; Copy decimal buffer content to calculation result buffer after the "."
            xor edi, edi
            push op___div___decimal_ascii_buffer
            call utility___count_string_length
            mov ecx, edi
            mov esi, op___div___decimal_ascii_buffer
            mov edi, ebx
            cld
            rep movsb

            ; Add new line feed and null terminator 
            ; Makes separator print on a new line after printing the result
            mov byte [edi], 0xa
            mov byte [edi + 1], 0

            jmp op___start_operation___print_calculation_result

        division___print_cant_divide_by_zero:
            mov eax, SYS_WRITE
            mov ebx, STDOUT
            mov ecx, MSG_CANT_DIVIDE_BY_ZERO
            mov edx, MSG_LEN_CANT_DIVIDE_BY_ZERO
            int 0x80
            jmp op___start_operation___return

        division___print_result_too_small_to_display:
            mov eax, SYS_WRITE
            mov ebx, STDOUT
            mov ecx, MSG_RESULT_TOO_SMALL_TO_BE_DISPLAYED
            mov edx, MSG_LEN_RESULT_TOO_SMALL_TO_BE_DISPLAYED
            int 0x80
            jmp op___start_operation___return

    op___start_operation___convert_result_from_number_to_ascii:
        push op___result___ascii_buffer
        push op___result___number_buffer
        call utility___convert_num_to_str

    op___start_operation___print_calculation_result:
        ; Output 'Result: (string in result buffer)'
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

    op___start_operation___return:
        mov esp, ebp
        pop ebp
        ret
