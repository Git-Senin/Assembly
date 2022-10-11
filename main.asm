; NAME: Lawrence Cole

.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

.data
array1 WORD 1111h, 2222h, 3333h, 4444h, 5555h, 6666h
array2 WORD LENGTHOF array1 DUP(?)


.code
main PROC
    
    mov ecx, LENGTHOF array1    ; Original Length to counter

    mov esi, OFFSET array1      ; array1 start address to esi
    add esi, SIZEOF array1      ; esi past end of array1 address
    sub esi, TYPE array1        ; esi last element

    mov ebx, OFFSET array2      ; array2 start address to ebx

    
l1:
    
    mov dx, [esi]              ; array1 value to dx
    mov [ebx], dx              ; dx to array2 address

    sub esi, TYPE array1
    add ebx, TYPE array1

    loop l1

    INVOKE ExitProcess, 0
main ENDP
END main
 