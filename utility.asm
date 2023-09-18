; 'utility.asm'
; Contains various utility functions.

section .text
    ; --------------------------------------
    ; Imports
    ; --------------------------------------
    ; Buffers
    extern input___operation_choice_ascii_buffer
    extern input___continue_choice_ascii_buffer
    extern input___operand_1_ascii_buffer
    extern input___operand_1_number_buffer
    extern input___operand_2_ascii_buffer
    extern input___operand_2_number_buffer
    extern calculation_result_ascii_buffer
    extern calculation_result_number_buffer
    extern division_quotient_ascii_buffer
    extern division_quotient_number_buffer
    extern division_decimal_ascii_buffer
    extern division_decimal_number_buffer
    extern division_decimal_temp_ascii_buffer
    extern division_is_negative_dividend_buffer
    extern division_is_negative_divisor_buffer
    extern division_is_negative_final_result_buffer
    ; Constants
    extern INPUT___OPERATION_CHOICE_BUFFER_LEN
    extern INPUT___CONTINUE_CHOICE_BUFFER_LEN
    extern INPUT___OPERAND_ASCII_BUFFER_LEN
    extern INPUT___OPERAND_NUMBER_BUFFER_LEN
    extern CALCULATION_RESULT_ASCII_BUFFER_LEN
    extern CALCULATION_RESULT_NUMBER_BUFFER_LEN
    extern DIVISION_QUOTIENT_ASCII_BUFFER_LEN
    extern DIVISION_QUOTIENT_NUMBER_BUFFER_LEN
    extern DIVISION_DECIMAL_ASCII_BUFFER_LEN
    extern DIVISION_DECIMAL_NUMBER_BUFFER_LEN
    extern DIVISION_SIGN_FLAG_BUFFER_LEN
    ; --------------------------------------
    ; Exports
    ; --------------------------------------
    ; Functions
    global utility___count_string_length
    global utility___convert_str_to_num
    global utility___convert_num_to_str
    global utility___clear_buffer
    global utility___clear_all_buffers

utility___count_string_length:
    ; Counts length of string stored in a buffer. Value is saved in edi register. Includes the null terminator.
    ; Arg_1 (ebp+8) - buffer that holds the string.
    push ebp
    mov ebp, esp

    xor edi, edi
    mov esi, [ebp + 8]
    
    utility___count_string_length___loop:
        mov al, byte [esi + edi]
        cmp al, 0
        je utility___count_string_length___return
        inc edi
        jne utility___count_string_length___loop

    utility___count_string_length___return:
        mov esp, ebp
        pop ebp
        ret   

utility___convert_str_to_num:
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
    jne utility___convert_str_to_num___loop ; Jump to the conversion loop if it's not a dash
    inc esi ; If it's a dash, move the buffer pointer to the second character
    mov ecx, 1 ; Set a flag to indicate whether the number is negative or not (1 if negative, 0 if positive)

    utility___convert_str_to_num___loop:
        movzx eax, byte [esi] ; Load next character from buffer
        inc esi
        cmp al, 0x0a ; Check if loaded byte is a new line character
        je utility___convert_str_to_num___save_converted_number
        sub al, '0'; Convert from ASCII to number
        imul ebx, 10 ; Multiply ebx by 10
        add ebx, eax ; ebx = ebx * 10 + eax
        jmp utility___convert_str_to_num___loop

    utility___convert_str_to_num___save_converted_number:
        mov edx, [ebp + 12] ; Loading the number buffer address into edx
        test ecx, ecx; Check the number flag that was set at the start
        jz utility___convert_str_to_num___store_value_into_buffer ; If zero (positive)
        neg ebx ; Negate the final number (if flag is non zero)
        utility___convert_str_to_num___store_value_into_buffer:
            mov [edx], ebx
        
    mov esp, ebp
    pop ebp
    ret

utility___convert_num_to_str:
    ; Convert a literal number to its ASCII representation and store in buffer.
    ; Arg_1 (ebp+8) - address to buffer that holds the number to be converted.
    ; Arg_2 (ebp+12) - address to buffer that will hold the converted number.
    push ebp
    mov ebp, esp

    mov ebx, [ebp + 8] ; Load number buffer address
    mov eax, [ebx] ; Load the literal value in the buffer into eax

    utility___convert_num_to_str___check_if_number_is_negative:
        cmp eax, 0
        jge utility___convert_num_to_str___push_to_stack ; Jump if value is non-negative

        ; If the value in buffer is negative
        neg eax ; Convert the value to positive
        mov ebx, [ebp + 12] ; Load the starting address of the ASCII buffer
        mov [ebx], byte "-" ; Add '-' to the first element of the buffer
        inc ebx ; Increment buffer pointer so it points to the second element (an empty space)
        mov [ebp + 12], ebx ; Overwrite the old buffer starting address with the new one
    
    ; Convert from number to ASCII and push converted characters onto the stack.
    utility___convert_num_to_str___push_to_stack:
        mov edx, 0 ; Fill higher order bits
        mov ecx, 10 ; Divisor
        idiv ecx
        add edx, "0" ; Convert the remainder to ASCII
        push edx ; Push the converted character onto the stack
        test eax, eax ; If quotient is not 0, keep converting
        jne utility___convert_num_to_str___push_to_stack

    ; Pop characters from the stack into buffer that will contain the converted number
    xor edi, edi ; Clear edi register
    utility___convert_num_to_str___pop_from_stack:
        mov ebx, [ebp + 12] ; Load the address of the buffer
        pop dword [ebx + edi] ; Pop character from stack
        inc edi
        cmp esp, ebp ; If pointing to the same address then there are no more chars
        jne utility___convert_num_to_str___pop_from_stack
        ; Add null terminator and new line feed
        mov byte [ebx + edi], 0
        mov byte [ebx + edi + 1], 0xa

    mov esp, ebp
    pop ebp
    ret

utility___clear_buffer:
    ; Set all bytes to 0 in buffer.
    ; Arg_1 (ebp+8) - address of the buffer to clear.
    ; Arg_2 (ebp+12) - length of the buffer.
    push ebp
    mov ebp, esp

    mov esi, [ebp + 8] ; Load the buffer to clear
    mov ecx, [ebp + 12] ; Load the length of the buffer
    xor eax, eax ; Set eax to 0 (the value to clear the buffer with)

    utility___clear_buffer___loop:
        mov [esi], al ; Set the current byte in the buffer to 0
        inc esi ; Move to the next byte
        loop utility___clear_buffer___loop ; Continue until ecx reaches 0

    mov esp, ebp
    pop ebp
    ret

utility___clear_all_buffers:
    push ebp
    mov ebp, esp

    ; Clear all ASCII buffers
    push INPUT___OPERATION_CHOICE_BUFFER_LEN
    push input___operation_choice_ascii_buffer
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
    push division_is_negative_dividend_buffer
    call utility___clear_buffer
    push DIVISION_SIGN_FLAG_BUFFER_LEN
    push division_is_negative_divisor_buffer
    call utility___clear_buffer
    push DIVISION_SIGN_FLAG_BUFFER_LEN
    push division_is_negative_final_result_buffer
    call utility___clear_buffer

    mov esp, ebp
    pop ebp
    ret

