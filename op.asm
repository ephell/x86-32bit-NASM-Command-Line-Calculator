; 'op.asm'
; Contains logic for performing arithmetic operations on numbers.

SYS_WRITE equ 4
STDOUT equ 1

section .data
    ; Messages
    MSG_OPERATION_RESULT db "Result: "
    MSG_LEN_OPERATION_RESULT equ $ - MSG_OPERATION_RESULT
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
    extern print___cant_divide_by_zero
    extern print___result_too_small
    extern print___result_too_large
    extern print___calculation_result
    extern print___operation_name
    extern print___operand_1_overflow
    extern print___operand_2_overflow
    extern input___read_operand_1
    extern input___read_operand_2
    ; Buffers
    extern input___operation_choice_ascii_buffer
    extern input___operand_1_ascii_buffer
    extern input___operand_1_number_buffer
    extern input___operand_2_ascii_buffer
    extern input___operand_2_number_buffer
    extern input___operand_1_overflow_flag_buffer
    extern input___operand_2_overflow_flag_buffer
    ; --------------------------------------
    ; Exports
    ; --------------------------------------
    ; Functions
    global op___perform_chosen_operation
    global op___print_result
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

op___perform_chosen_operation:
    push ebp
    mov ebp, esp

    ; Read operands from user input
    call input___read_operand_1
    call input___read_operand_2

    ; Check for overflow flags in any of the operands
    cmp byte [input___operand_1_overflow_flag_buffer], "1"
    je op___perform_chosen_operation___operand_1_overflow
    cmp byte [input___operand_2_overflow_flag_buffer], "1"
    je op___perform_chosen_operation___operand_2_overflow

    ; Select operation based on user input
    mov al, byte [input___operation_choice_ascii_buffer]
    cmp al, "1"
    je addition
    cmp al, "2"
    je subtraction
    cmp al, "3"
    je multiplication
    cmp al, "4"
    je division

    op___perform_chosen_operation___return:
        mov esp, ebp
        pop ebp
        ret

    op___perform_chosen_operation___print_result_and_return:
        call op___print_result
        jmp op___perform_chosen_operation___return

    op___perform_chosen_operation___operand_1_overflow:
        push input___operation_choice_ascii_buffer
        call print___operation_name
        call print___operand_1_overflow
        jmp op___perform_chosen_operation___return

    op___perform_chosen_operation___operand_2_overflow:
        push input___operation_choice_ascii_buffer
        call print___operation_name
        call print___operand_2_overflow
        jmp op___perform_chosen_operation___return

    op___perform_chosen_operation___result_overflow:
        push input___operation_choice_ascii_buffer
        call print___operation_name
        call print___result_too_large
        jmp op___perform_chosen_operation___return

addition:
    mov eax, [input___operand_1_number_buffer]
    mov ebx, [input___operand_2_number_buffer]
    add eax, ebx
    ; Check for overflow
    jo op___perform_chosen_operation___result_overflow
    mov [op___result___number_buffer], eax
    ; Convert result from number to ASCII
    push op___result___ascii_buffer
    push op___result___number_buffer
    call utility___convert_num_to_str
    jmp op___perform_chosen_operation___print_result_and_return

subtraction:
    mov eax, [input___operand_1_number_buffer]
    mov ebx, [input___operand_2_number_buffer]
    sub eax, ebx
    ; Check for overflow
    jo op___perform_chosen_operation___result_overflow
    mov [op___result___number_buffer], eax
    ; Convert result from number to ASCII
    push op___result___ascii_buffer
    push op___result___number_buffer
    call utility___convert_num_to_str
    jmp op___perform_chosen_operation___print_result_and_return

multiplication:
    mov eax, [input___operand_1_number_buffer]
    mov ebx, [input___operand_2_number_buffer]
    imul eax, ebx
    ; Check for overflow
    jo op___perform_chosen_operation___result_overflow
    mov [op___result___number_buffer], eax
    ; Convert result from number to ASCII
    push op___result___ascii_buffer
    push op___result___number_buffer
    call utility___convert_num_to_str
    jmp op___perform_chosen_operation___print_result_and_return

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
        je division___division_by_zero
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
                jo division___result_too_small

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

        jmp op___perform_chosen_operation___print_result_and_return

    division___division_by_zero:
        push input___operation_choice_ascii_buffer
        call print___operation_name
        call print___cant_divide_by_zero
        jmp op___perform_chosen_operation___return

    division___result_too_small:
        push input___operation_choice_ascii_buffer
        call print___operation_name
        call print___result_too_small
        jmp op___perform_chosen_operation___return

op___print_result:
    push ebp
    mov ebp, esp

    push input___operation_choice_ascii_buffer
    call print___operation_name

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, MSG_OPERATION_RESULT
    mov edx, MSG_LEN_OPERATION_RESULT
    int 0x80

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, op___result___ascii_buffer
    mov edx, OP___RESULT___ASCII_BUFFER_LEN
    int 0x80

    mov esp, ebp
    pop ebp
    ret
