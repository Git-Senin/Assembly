; Name: Lawrence Cole
; Programming Lab 6
; Control Structures

.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO,dwExitCode:DWORD

.data
mystring BYTE   "Hello World",0
stringlength BYTE LENGTHOF mystring

.code
main PROC
    
    ;   counter
    mov al, stringlength
    sub al, 1
    mov cl, al

    mov edx, 0                  ; index
    mov ebx, OFFSET mystring    ; string pointer

    mov esi, ebx                ; string pointer to esi
    l1:
        mov al, [esi]   ; current value to al
        cmp cl, 0       ; exit on end of string
        je J4
        cmp al, 64      ; if on non-letter 
        jle J3       

    J1: cmp al, 97      ; if Lowercase
        jge J2          
        call toLowerCase
        jmp J3          ; Skip Uppercase

    J2: cmp al, 123     ; if on non-letter
        jge J3
        call toUpperCase

    J3: inc edx         ; next index
        inc esi
        loop l1

    J4:
    INVOKE ExitProcess, 0

main ENDP



;---------- Procedures ----------

toUpperCase proc
; EDX = index
; EBX = String Pointer
; no return
    pusha           ; push all registers

    ; subtract 32 from offset value
    mov esi, ebx    ; address to pointer register
    add esi, edx    ; index
    mov al, [esi]   ; move value from pointer register to 8 bit register
    sub al, 32      ; subtract 32 from register
    mov [esi], al   ; 8 bit register to address

    popa            ; pop all registers

    ret
    toUpperCase endp
    
toLowerCase proc
; EDX = index
; EBX = String Pointer
; no return
    pusha           ; push all registers

    ; add 32 to offset value
    mov esi, ebx    ; address to pointer register
    add esi, edx    ; index
    mov al, [esi]   ; move value from pointer register to 8 bit register
    add al, 32      ; add 32 from register
    mov [esi], al   ; 8 bit register to address

    popa            ; pop all registers

    ret
    toLowerCase endp

END main 