; Name: Lawrence Cole
; Programming Lab 7
; Bit String Calculator

.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO,dwExitCode:DWORD

.data
bitstring DWORD 11111111111111111111111111111111b ; 00000000 0000000 0 0 0000000 00000000 b
result DWORD ?

op1 DWORD ?  ; operand   1
opa DWORD ?  ; arithmetic
op2 DWORD ?  ; operand   2

.code
main PROC
; op1
    PUSH bitstring
    SHR bitstring, 17
    MOV eax, bitstring
    MOV op1, eax
    POP bitstring

; opA
    PUSH bitstring
    SHL bitstring, 15
    SHR bitstring, 30
    MOV eax, bitstring
    MOV opa, eax
    POP bitstring

; op2
    PUSH bitstring
    SHL bitstring, 17
    SHR bitstring, 17
    MOV eax, bitstring
    MOV op2, eax
    POP bitstring
    
    CMP opa, 0 ; if 00
    JL invalid
    JE addition
    CMP opa, 1 ; if 01
    JE subtraction
    CMP opa, 2 ; if 10
    JE multiplication
    cmp opa, 3 ; if 11
    JE division
    JG invalid

    addition: 
    mov eax, op1
    add eax, op2
    JMP endOperation

    subtraction:
    mov eax, op1
    sub eax, op2
    JMP endOperation

    multiplication: 
    mov edx, 0
    mov eax, op1
    mul op2
    JMP endOperation

    division:
    mov edx, 0
    mov eax, op1
    div op2
    JMP endOperation

    endOperation:
    mov result, eax

    invalid:
    INVOKE ExitProcess, 0

    main ENDP

END main 