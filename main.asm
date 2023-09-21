; 'main.asm'
; Contains entry point of the program.

SYS_EXIT equ 1

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
    extern print___bye
    extern utility___clear_all_buffers
    extern input___read_operation_choice
    extern input___read_continue_choice
    extern op___perform_chosen_operation
    ; Buffers
    extern input___continue_choice_ascii_buffer

_start:
    call print___separator
    call print___title

    _start_main_loop:
        call utility___clear_all_buffers
        call print___separator
        call print___operation_options
        call print___separator
        call print___select_operation
        call input___read_operation_choice
        call print___separator
        call op___perform_chosen_operation
        call print___separator
        call print___ask_if_user_wants_to_continue
        call input___read_continue_choice
        mov al, byte [input___continue_choice_ascii_buffer]
        cmp al, "1" ; 1 - continue, 0 - exit
        je _start_main_loop


    _start_exit:
        call print___bye
        mov eax, SYS_EXIT
        mov ebx, 0
        int 0x80
