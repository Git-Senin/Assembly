; Name: Lawrence Cole
; Programming Lab 5
; Procedures
.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO,dwExitCode:DWORD

.data
array1 BYTE 1,2,3,4
array2 BYTE 8,8,8,8,8,8,8,8

.code
main PROC

    mov eax, 0
    call p1       ; EAX = 3
    call p1      ; EAX = 6
    call p1      ; EAX = 9

    mov ebx, OFFSET array1      ; address of array1
    mov ecx, LENGTHOF array1    ; # of elements in array 1
    call p2      ; array1 = 2, 3, 4, 5 ; ECX = 4

    add ebx, 4                      ; if you didn't restore the values of ebx or ecx after the last procedure
    add ecx, 4                      ; then these lines will not work as intended
    call p2      ; array2 = 9,9,9,9,9,9,9,9 ; ECX = 8

    mov ecx, 10
    call p3      ; EAX = 9, ECX = 10, EDX = 29

    INVOKE ExitProcess, 0

main ENDP


;---------- Procedures ----------

; Add 3 eax
p1 proc
    add eax, 3  ; adds 3 to eax
    ret
    p1 endp

; Loop over Array(Bytes)
; add 1 to each element
; preserves registers
p2 proc 
    pusha               ; preserve all registers
    mov esi, ebx        ; address to pointer register
    l1:                 ; Iterate thru array
        
        mov al, [esi]   ; pointer value to 8-bit register
        inc al          ; increase register
        mov [esi], al   ; register to pointer value

        inc esi         ; increment pointer 

        loop l1
    popa                ; preserve all registers
    ret
    p2 endp

; Calls p1
; subtract 10 from eax
; return result in edx
; preserves registers
p3 proc
    push ecx     ; preserve ecx, eax
    push eax

    l1:          ; loop p1
        call p1
        loop l1
    sub eax, 10  ; subtract 10 from result
    mov edx, eax ; store return value in edx
   
    pop eax      ; preserve ecx, eax
    pop ecx      
    ret
    p3 endp

;--------------------------------------------------
END main