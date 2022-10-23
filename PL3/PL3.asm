; NAME: Lawrence Cole

.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

.data

array BYTE 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31

.code
main PROC

    mov ebx, 0                  ; index
    mov ecx, 31                 ; counter

    startloop:

        mov al,[array + ebx]    ; first into al
        inc ebx                 ; increase index 

        xchg al, [array + ebx]  ; al swap second 
        dec ebx                 ; decrease index

        mov [array + ebx], al   ; mov al to first
        
        inc ebx                 ; next pair aka
        inc ebx                 ; increase index by 2

    loop startloop

    INVOKE ExitProcess, 0
main ENDP
END main
