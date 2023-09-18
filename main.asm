SYS_EXIT equ 1
SYS_WRITE equ 4
STDOUT equ 1

section .data
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
    CALCULATION_RESULT_ASCII_BUFFER_LEN equ 255
    CALCULATION_RESULT_NUMBER_BUFFER_LEN equ 32
    DIVISION_QUOTIENT_ASCII_BUFFER_LEN equ 255
    DIVISION_QUOTIENT_NUMBER_BUFFER_LEN equ 32
    DIVISION_DECIMAL_ASCII_BUFFER_LEN equ 255
    DIVISION_DECIMAL_NUMBER_BUFFER_LEN equ 32
    DIVISION_DECIMAL_PRECISION equ 10
    DIVISION_SIGN_FLAG_BUFFER_LEN equ 32

section .bss
    calculation_result_ascii_buffer resb CALCULATION_RESULT_ASCII_BUFFER_LEN
    calculation_result_number_buffer resb CALCULATION_RESULT_NUMBER_BUFFER_LEN
    division_quotient_ascii_buffer resb DIVISION_QUOTIENT_ASCII_BUFFER_LEN
    division_quotient_number_buffer resb DIVISION_QUOTIENT_NUMBER_BUFFER_LEN
    division_decimal_ascii_buffer resb DIVISION_DECIMAL_ASCII_BUFFER_LEN
    division_decimal_number_buffer resb DIVISION_DECIMAL_NUMBER_BUFFER_LEN
    division_decimal_temp_ascii_buffer resb 1
    division_is_negative_dividend resb DIVISION_SIGN_FLAG_BUFFER_LEN
    division_is_negative_divisor resb DIVISION_SIGN_FLAG_BUFFER_LEN
    division_is_negative_final_result resb DIVISION_SIGN_FLAG_BUFFER_LEN

section .text
    global _start
    ; --------------------------------------
    ; Imports
    ; --------------------------------------
    ; Functions
    extern print___separator
    extern print___title
    extern print___operation_options
    extern print___select_operation
    extern print___ask_if_user_wants_to_continue
    extern utility___count_string_length
    extern utility___convert_str_to_num
    extern utility___convert_num_to_str
    extern utility___clear_buffer
    extern input___read_operation_choice
    extern input___read_continue_choice
    extern input___read_number
    ; Buffers
    extern input___operation_choice_buffer
    extern input___continue_choice_ascii_buffer
    extern input___operand_1_ascii_buffer
    extern input___operand_1_number_buffer
    extern input___operand_2_ascii_buffer
    extern input___operand_2_number_buffer
    ; Constants
    extern INPUT___OPERATION_CHOICE_BUFFER_LEN
    extern INPUT___CONTINUE_CHOICE_BUFFER_LEN
    extern INPUT___OPERAND_ASCII_BUFFER_LEN
    extern INPUT___OPERAND_NUMBER_BUFFER_LEN

_start:
    call print___separator
    call print___title

    _start_main_loop:
        call clear_all_buffers
        call print___separator ; Separator
        call print___operation_options
        call print___separator ; Separator
        call print___select_operation
        call input___read_operation_choice
        call print___separator ; Separator
        call start_operation
        call print___separator ; Separator
        call print___ask_if_user_wants_to_continue
        call input___read_continue_choice
        mov al, byte [input___continue_choice_ascii_buffer]
        cmp al, "1" ; 1 - continue, 0 - exit
        je _start_main_loop

    mov eax, SYS_EXIT
    mov ebx, 0
    int 0x80

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
    mov al, byte [input___operation_choice_buffer]
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
        mov [calculation_result_number_buffer], eax
        jmp start_operation___convert_result_from_number_to_ascii
   
    subtraction:
        mov eax, [input___operand_1_number_buffer]
        mov ebx, [input___operand_2_number_buffer]
        sub eax, ebx
        mov [calculation_result_number_buffer], eax
        jmp start_operation___convert_result_from_number_to_ascii

    multiplication:
        mov eax, [input___operand_1_number_buffer]
        mov ebx, [input___operand_2_number_buffer]
        imul eax, ebx
        mov [calculation_result_number_buffer], eax
        jmp start_operation___convert_result_from_number_to_ascii

    division:
        division___get_result_sign:
            division___get_result_sign___check_if_dividend_is_negative:
                mov eax, [input___operand_1_number_buffer]
                test eax, eax
                jns division___get_result_sign___check_if_divisor_is_negative
                mov byte [division_is_negative_dividend], 1 ; Set flag to indicate negativity

            division___get_result_sign___check_if_divisor_is_negative:
                mov eax, [input___operand_2_number_buffer]
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
                    mov [division_decimal_number_buffer], eax

                    ; Convert quotient part to ASCII
                    push division_decimal_temp_ascii_buffer
                    push division_decimal_number_buffer
                    call utility___convert_num_to_str
                    add esp, 8
                    ; Clear division_decimal_number_buffer
                    push DIVISION_DECIMAL_NUMBER_BUFFER_LEN
                    push division_decimal_number_buffer
                    call utility___clear_buffer
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
            call utility___count_string_length
            mov ecx, edi
            mov esi, division_quotient_ascii_buffer
            mov edi, calculation_result_ascii_buffer
            cld
            rep movsb

            ; Add decimal point and null terminator after the quotient in the calculation result buffer
            xor edi, edi
            push calculation_result_ascii_buffer
            call utility___count_string_length
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
            call utility___count_string_length
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
            jmp start_operation___return

        division___print_result_too_small_to_display:
            mov eax, SYS_WRITE
            mov ebx, STDOUT
            mov ecx, MSG_RESULT_TOO_SMALL_TO_BE_DISPLAYED
            mov edx, MSG_LEN_RESULT_TOO_SMALL_TO_BE_DISPLAYED
            int 0x80
            jmp start_operation___return

    start_operation___convert_result_from_number_to_ascii:
        push calculation_result_ascii_buffer
        push calculation_result_number_buffer
        call utility___convert_num_to_str

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

    start_operation___return:
        mov esp, ebp
        pop ebp
        ret

clear_all_buffers:
    push ebp
    mov ebp, esp

    ; Clear all ASCII buffers
    push INPUT___OPERATION_CHOICE_BUFFER_LEN
    push input___operation_choice_buffer
    call utility___clear_buffer
    push INPUT___CONTINUE_CHOICE_BUFFER_LEN
    push input___continue_choice_ascii_buffer
    call utility___clear_buffer
    push INPUT___OPERAND_ASCII_BUFFER_LEN 
    push input___operand_1_ascii_buffer
    call utility___clear_buffer
    push INPUT___OPERAND_ASCII_BUFFER_LEN 
    push input___operand_2_ascii_buffer
    call utility___clear_buffer
    push CALCULATION_RESULT_ASCII_BUFFER_LEN 
    push calculation_result_ascii_buffer
    call utility___clear_buffer
    push DIVISION_QUOTIENT_ASCII_BUFFER_LEN
    push division_quotient_ascii_buffer
    call utility___clear_buffer
    push DIVISION_DECIMAL_ASCII_BUFFER_LEN
    push division_decimal_ascii_buffer
    call utility___clear_buffer

    ; Clear all number buffers
    push INPUT___OPERAND_NUMBER_BUFFER_LEN
    push input___operand_1_number_buffer
    call utility___clear_buffer
    push INPUT___OPERAND_NUMBER_BUFFER_LEN 
    push input___operand_2_number_buffer
    call utility___clear_buffer
    push CALCULATION_RESULT_NUMBER_BUFFER_LEN 
    push calculation_result_number_buffer
    call utility___clear_buffer
    push DIVISION_QUOTIENT_NUMBER_BUFFER_LEN
    push division_quotient_number_buffer
    call utility___clear_buffer
    push DIVISION_DECIMAL_NUMBER_BUFFER_LEN
    push division_decimal_number_buffer
    call utility___clear_buffer

    ; Clear division flag buffers
    push DIVISION_SIGN_FLAG_BUFFER_LEN
    push division_is_negative_dividend
    call utility___clear_buffer
    push DIVISION_SIGN_FLAG_BUFFER_LEN
    push division_is_negative_divisor
    call utility___clear_buffer
    push DIVISION_SIGN_FLAG_BUFFER_LEN
    push division_is_negative_final_result
    call utility___clear_buffer

    mov esp, ebp
    pop ebp
    ret
