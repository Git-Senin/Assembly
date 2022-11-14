; Name: Lawrence Cole
; Programming Lab 8
; A Multimodule Program 
.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

EXTERN Display@0 : PROC

.data
mystring BYTE "Hello World!",0
argument DWORD 11

.code
main PROC

    PUSH OFFSET mystring
    Call Display@0

    PUSH argument
    CALL GreaterThanTen

    INVOKE ExitProcess, 00

    main ENDP

;-------------------------------------------
GreaterThanTen PROC
; Takes one DWORD argument and returns 1 in EAX 
; if argument is greater than the number 10, 
; or 0 in EAX if the argument is not greater than 10
;-------------------------------------------
    push ebp
    mov ebp, esp

    mov eax, [ebp + 8]

    cmp eax, 10
    JG greater
    JLE lessthenORequalto

    greater:
    mov eax, 1
    JMP endOperation

    lessthenORequalto:
    mov eax, 0
    JMP endOperation


    endOperation:
    mov esp, ebp
    pop ebp
    ret 4
GreaterThanTen ENDP
END main 

Display PROTO
INVOKE Display
