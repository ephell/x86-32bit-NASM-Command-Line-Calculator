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
    NUMBER_BUFFER_LEN equ 4

section .bss
    user_choice_ascii_buffer resb USER_CHOICE_ASCII_BUFFER_LEN
    user_num_1_ascii_buffer resb USER_NUM_ASCII_BUFFER_LEN 
    user_num_1_number_buffer resd NUMBER_BUFFER_LEN
    user_num_2_ascii_buffer resb USER_NUM_ASCII_BUFFER_LEN 
    user_num_2_number_buffer resd NUMBER_BUFFER_LEN
    calculation_result_ascii_buffer resb CALCULATION_RESULT_ASCII_BUFFER_LEN
    calculation_result_number_buffer resd NUMBER_BUFFER_LEN

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
    ; Read and validate the user's choice of operation (e.g., addition, subtraction).
    push ebp
    mov ebp, esp

    mov esi, user_choice_ascii_buffer ; Load buffer address

    read_user_operation_choice___read_input:
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
    je start_operation___addition
    cmp al, "2"
    je start_operation___subtraction
    cmp al, "3"
    je start_operation___multiplication
    cmp al, "4"
    je start_operation___division

    start_operation___addition:
        mov eax, [user_num_1_number_buffer]
        mov ebx, [user_num_2_number_buffer]
        add eax, ebx
        mov [calculation_result_number_buffer], eax
        jmp start_user_selected_operation___convert_and_print_result
   
    start_operation___subtraction:
        mov eax, [user_num_1_number_buffer]
        mov ebx, [user_num_2_number_buffer]
        sub eax, ebx
        mov [calculation_result_number_buffer], eax
        jmp start_user_selected_operation___convert_and_print_result

    start_operation___multiplication:
        mov eax, [user_num_1_number_buffer]
        mov ebx, [user_num_2_number_buffer]
        imul eax, ebx
        mov [calculation_result_number_buffer], eax
        jmp start_user_selected_operation___convert_and_print_result

    start_operation___division:
        jmp start_user_selected_operation___convert_and_print_result

    start_user_selected_operation___convert_and_print_result:
        ; Convert number result to ASCII
        push calculation_result_ascii_buffer
        push calculation_result_number_buffer
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
        div ecx
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
        inc edi
        cmp al, 0xa
        jne count_string_length___loop

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
