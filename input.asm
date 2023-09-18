SYS_READ equ 3
SYS_WRITE equ 4
STDIN equ 0
STDOUT equ 1

section .data
    ; Messages
    MSG_INVALID_CHOICE db "Invalid choice. Try again: "
    MSG_LEN_INVALID_CHOICE equ $ - MSG_INVALID_CHOICE
    MSG_INVALID_INPUT db "Invalid input. Try again: "
    MSG_LEN_INVALID_INPUT equ $ - MSG_INVALID_INPUT
    ; Constants
    INPUT___OPERATION_CHOICE_BUFFER_LEN equ 255
    INPUT___CONTINUE_CHOICE_BUFFER_LEN equ 255
    INPUT___OPERAND_ASCII_BUFFER_LEN equ 255
    INPUT___OPERAND_NUMBER_BUFFER_LEN equ 32

section .bss
    input___operation_choice_buffer resb INPUT___OPERATION_CHOICE_BUFFER_LEN
    input___continue_choice_ascii_buffer resb INPUT___CONTINUE_CHOICE_BUFFER_LEN
    input___operand_1_ascii_buffer resb INPUT___OPERAND_ASCII_BUFFER_LEN 
    input___operand_1_number_buffer resb INPUT___OPERAND_NUMBER_BUFFER_LEN
    input___operand_2_ascii_buffer resb INPUT___OPERAND_ASCII_BUFFER_LEN 
    input___operand_2_number_buffer resb INPUT___OPERAND_NUMBER_BUFFER_LEN

section .text
    ; --------------------------------------
    ; Imports
    ; --------------------------------------
    ; Functions
    extern utility___count_string_length
    extern utility___clear_buffer
    extern utility___convert_str_to_num
    ; --------------------------------------
    ; Exports
    ; --------------------------------------
    ; Functions
    global input___read_operation_choice
    global input___read_continue_choice
    global input___read_number
    ; Buffers
    global input___operation_choice_buffer
    global input___continue_choice_ascii_buffer
    global input___operand_1_ascii_buffer
    global input___operand_1_number_buffer
    global input___operand_2_ascii_buffer
    global input___operand_2_number_buffer
    ; Constants
    global INPUT___OPERATION_CHOICE_BUFFER_LEN
    global INPUT___CONTINUE_CHOICE_BUFFER_LEN
    global INPUT___OPERAND_ASCII_BUFFER_LEN
    global INPUT___OPERAND_NUMBER_BUFFER_LEN

input___read_operation_choice:
    ; Read and validate the user's choice of operation (e.g., addition, subtraction).
    push ebp
    mov ebp, esp

    input___read_operation_choice___read_input:
        mov esi, input___operation_choice_buffer ; Load buffer address
        mov eax, SYS_READ
        mov ebx, STDIN
        mov ecx, esi
        mov edx, INPUT___OPERATION_CHOICE_BUFFER_LEN
        int 0x80

    input___read_operation_choice___validate_input:
        xor edi, edi
        push esi
        call utility___count_string_length
        ; Reject input if it is empty (only a newline character)
        cmp edi, 1 
        je input___read_operation_choice___reject_input
        ; Reject input if it is longer than 2 characters (only 1 character + null terminator allowed)
        cmp edi, 2
        jg input___read_operation_choice___reject_input
        ; Reject input if the first character in the buffer does not correspond to an operation
        mov al, byte [esi]
        cmp al, "1"
        jl input___read_operation_choice___reject_input
        cmp al, "4"
        jg input___read_operation_choice___reject_input
        ; If all checks pass
        jmp input___read_operation_choice___return

    input___read_operation_choice___reject_input:
        mov eax, SYS_WRITE
        mov ebx, STDOUT
        mov ecx, MSG_INVALID_CHOICE
        mov edx, MSG_LEN_INVALID_CHOICE
        int 0x80
        ; Clear buffer before reading input again
        push INPUT___OPERATION_CHOICE_BUFFER_LEN
        push input___operation_choice_buffer
        call utility___clear_buffer
        jmp input___read_operation_choice___read_input

    input___read_operation_choice___return:
        mov esp, ebp
        pop ebp
        ret

input___read_continue_choice:
    ; Read if user wants to continue after an operation was done.
    ; Stores the choice in eax register (1 - yes, 0 - no).
    push ebp
    mov ebp, esp

    mov esi, input___continue_choice_ascii_buffer ; Load buffer address

    input___read_continue_choice___read_input:
        ; Read stdin buffer
        mov eax, SYS_READ
        mov ebx, STDIN
        mov ecx, esi
        mov edx, INPUT___OPERATION_CHOICE_BUFFER_LEN
        int 0x80

    input___read_continue_choice___validate_input:
        xor edi, edi
        push esi
        call utility___count_string_length
        ; Reject input if it is empty (only a newline character)
        cmp edi, 1 
        je input___read_continue_choice___reject_input
        ; Reject input if it is longer than 2 characters (only 1 character + null terminator allowed)
        cmp edi, 2
        jg input___read_continue_choice___reject_input        
        ; Reject input if the first character in the buffer is not 'y', 'Y', 'n' or 'N'
        mov al, byte [esi]
        cmp al, "y"
        je input___read_continue_choice___y_selected
        cmp al, "Y"
        je input___read_continue_choice___y_selected
        cmp al, "n"
        je input___read_continue_choice___n_selected
        cmp al, "N"
        je input___read_continue_choice___n_selected
        ; If neither of the characters match
        jmp input___read_continue_choice___reject_input

    input___read_continue_choice___y_selected:
        ; Clear buffer before setting the flag (1 - continue)
        push INPUT___OPERATION_CHOICE_BUFFER_LEN
        push input___continue_choice_ascii_buffer
        call utility___clear_buffer
        ; Set flag
        mov [input___continue_choice_ascii_buffer], byte "1"
        jmp input___read_continue_choice___return

    input___read_continue_choice___n_selected:
        ; Clear buffer before setting the flag (0 - do not continue)
        push INPUT___OPERATION_CHOICE_BUFFER_LEN
        push input___continue_choice_ascii_buffer
        call utility___clear_buffer
        ; Set flag
        mov [input___continue_choice_ascii_buffer], byte "0"
        jmp input___read_continue_choice___return

    input___read_continue_choice___reject_input:
        mov eax, SYS_WRITE
        mov ebx, STDOUT
        mov ecx, MSG_INVALID_CHOICE
        mov edx, MSG_LEN_INVALID_CHOICE
        int 0x80
        ; Clear buffer before reading input again
        push INPUT___OPERATION_CHOICE_BUFFER_LEN
        push input___continue_choice_ascii_buffer
        call utility___clear_buffer
        jmp input___read_continue_choice___read_input

    input___read_continue_choice___return:
        mov esp, ebp
        pop ebp
        ret

input___read_number:
    ; Read user input from stdin, convert string to number and store in buffer.
    ; Arg_1 (ebp+8) - address to buffer that holds users' input in ASCII.
    ; Arg_2 (ebp+12) - address to buffer that will hold the number.
    push ebp
    mov ebp, esp

    input___read_number___read_input:
        mov esi, [ebp + 8] ; Load ASCII buffer address (reload the original each time)
        mov eax, SYS_READ
        mov ebx, STDIN
        mov ecx, esi
        mov edx, INPUT___OPERAND_ASCII_BUFFER_LEN
        int 0x80

    input___read_number___validate_input:
        xor edi, edi
        mov al, byte [esi] ; Get the first character from the ASCII buffer
        ; Reject input if it is empty (only a new line character)
        cmp al, 0xa
        je input___read_number___reject_input
        ; Reject input if user typed "-" + Enter (new line character)
        cmp al, "-"
        jne input___read_number___verify_all_chars_in_buffer_are_digits ; No need to check second char if number is positive
        inc esi ; Make buffer pointer point at the second char
        cmp byte [esi], 0xa
        je input___read_number___reject_input
    
    input___read_number___verify_all_chars_in_buffer_are_digits:
        mov al, byte [esi + edi]
        cmp al, 0xa
        je input___read_number___convert_from_ascii_to_number
        ; Check if the read byte is a digit
        cmp al, "0"
        jl input___read_number___reject_input
        cmp al, "9"
        jg input___read_number___reject_input
        inc edi
        ; Continue reading untill new line character
        jmp input___read_number___verify_all_chars_in_buffer_are_digits

    input___read_number___reject_input:
        mov eax, SYS_WRITE
        mov ebx, STDOUT
        mov ecx, MSG_INVALID_INPUT
        mov edx, MSG_LEN_INVALID_INPUT
        int 0x80
        jmp input___read_number___read_input

    input___read_number___convert_from_ascii_to_number:
        push dword [ebp + 12] ; Pushing the number buffer
        push dword [ebp + 8] ; Pushing the ASCII buffer
        call utility___convert_str_to_num

    mov esp, ebp
    pop ebp
    ret
