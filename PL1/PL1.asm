; NAME: Lawrence Cole

.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

.data
; YOUR VARIABLES GO HERE
sum DWORD 0

.code
main PROC
    ; YOUR CODE GOES HERE
    mov eax, 3
    mov ebx, 1
    mov ecx, 5
    mov edx, 7

    add eax, ebx
    add ecx, edx
     
    sub ecx, eax

    mov sum, ecx

    INVOKE ExitProcess, 0
main ENDP
END main
