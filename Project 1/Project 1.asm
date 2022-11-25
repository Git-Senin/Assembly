; Name: Lawrence Cole
; Project 1
; Binary to ASCII Converter

.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

EXTERN ReadInput@0 : PROC
EXTERN WriteOutput@0 : PROC


.data
START_MESSAGE byte "    Please Enter a binary string or enter 'q' to quit: ",0
INVALID_MESSAGE byte "    Your input is invalid. ",0
OUTPUT_MESSAGE byte "    Your value is : ",0
buffer byte "**************",0
result DWORD ?
ZERO EQU 48
ONE EQU 49

.code
main PROC
    
START_OF_PROGRAM:

    ; Tell the user to enter a binary string or enter 'q' to quit
    PUSH LENGTHOF START_MESSAGE
    PUSH OFFSET START_MESSAGE
    CALL WriteOutput@0

    ; Read the user's input
    PUSH SIZEOF buffer  ; size of buffer
    PUSH OFFSET buffer  ; buffer offset
    CALL ReadInput@0
    SUB EAX, 2

    ; If the user entered 'q', end the program
    CMP buffer, 'q'
    JE END_OF_PROGRAM

    ; Else, read through each character in their string
    ; If the string is the wrong length, tell the user it is wrong and start over from step 1
    CMP EAX, 8          
    JNE ERROR_MESSAGE

    ; If the string contains characters other than '0' or '1', tell the user it is wrong and start over from step 1
    PUSH 8              
    PUSH OFFSET buffer  
    CALL ValidateInput
    cmp edx, 1
    JNE ERROR_MESSAGE

    ; If the string is correct (a mix of eight 0's and 1's), proceed with the conversion
    ; Convert the string into a binary value using bitwise operations
    PUSH 8              
    PUSH OFFSET buffer
    CALL BinaryToDecimal
    mov result, edx

    ; Once you have the value, display it to the user
    PUSH LENGTHOF OUTPUT_MESSAGE
    PUSH OFFSET OUTPUT_MESSAGE
    CALL WriteOutput@0

    ; get length of result
    PUSH OFFSET result
    CALL LengthOfResult

    ; value to string
    PUSH OFFSET result
    CALL DecimalToString
    PUSH eax
    PUSH OFFSET result
    CALL WriteOutput@0

    ; Repeat the process from step 1
    JMP START_OF_PROGRAM

ERROR_MESSAGE:
    PUSH LENGTHOF INVALID_MESSAGE
    PUSH OFFSET INVALID_MESSAGE
    CALL WriteOutput@0
    JMP START_OF_PROGRAM

END_OF_PROGRAM:
    INVOKE ExitProcess, 00
main ENDP
;------------------------------------------------------------------------
;                           Procedures
;------------------------------------------------------------------------

ReadInput PROTO
INVOKE ReadInput

WriteOutput PROTO
INVOKE WriteOutput

ValidateInput PROC
; 
; Validates input
;   
; Recieves: esi = offset
;           ecx = length
;   
; Returns: T or F in EDX
;          T = 1
;          F = 0
;------------------------------------------------------------------------
    push ebp
    mov ebp, esp

    push esi
    push ecx
    push eax
;Procedure
    mov edx, 1          ; init edx true
    mov esi, [ebp + 8]  ; offset
    mov ecx, [ebp + 12] ; length
l1: 
    mov ah, 0 ; set bool false
    mov al, BYTE PTR [esi]  ; get char

    CMP al, ZERO    ; check for 0
    je SET_TRUE
    CMP al, ONE     ; check for 1
    je SET_TRUE

    JMP FINISH_INDEX
    SET_TRUE:
    mov ah, 1 ; set bool true

    FINISH_INDEX:
    mov al, ah; exit if false
    cmp al, 1
    JNE RETURN_FALSE

    inc esi ; next element
loop l1 ; loop tru string

    JMP RETURN_BOOL
    RETURN_FALSE:
    mov EDX, 0

    RETURN_BOOL:
;end
    pop eax
    pop ecx
    pop esi
    
    mov esp, ebp
    pop ebp
    ret 8
ValidateInput ENDP
;------------------------------------------------------------------------
BinaryToDecimal PROC
;
; Takes in string and converts it to decimal
;
; Recieves: esi = offset
;           ecx = length
; 
; Returns: Decimal Value in EDX
; 
;------------------------------------------------------------------------
    push ebp
    mov ebp, esp
    push esi
    push ecx
    push eax
    PUSH ebx
;Procedure
    mov esi, [ebp + 8]  ; offset
    mov ecx, [ebp + 12] ; length
    mov edx, 0  ; value
l1:
    ; index char value
    push ecx
    mov cl, BYTE PTR [esi] 
    movzx ebx, cl         
    pop ecx
    ; to decimal
    sub ebx, 48 
    mov eax, 2
    ; 2 * Value + index
    MUL edx     
    add eax, ebx
    ; move to edx
    mov edx, eax
    ; next element
    inc esi 
loop l1
;end
    pop ebx
    pop eax
    pop ecx
    pop esi
    mov esp, ebp
    pop ebp
    ret 8
BinaryToDecimal ENDP
;------------------------------------------------------------------------
DecimalToString PROC
;
; Converts Decimal to String
;
; Recives: esi = offset
;
; Returns: nothing
;
;------------------------------------------------------------------------
    push ebp
    mov ebp, esp
    pusha
;Procedure
    
    mov esi, [ebp + 8]      ; offset
    mov bh, 0               ; bool
    
    mov ax, WORD PTR [esi]  ; 255
    mov bl, 100             ; 100
    DIV bl                  
    mov [esi], bh

    cmp al, 0               ; if no coeff
    JNG j1
    add al, 48              ; to ascii
    mov [esi], al           ; "2"
    inc esi                 ; next indice
    inc bh                  ; else lead coeff

;--------------------------------------------
j1: ; ah = 55
    movzx ax, ah            ; 55
    mov bl, 10              ; 10
    DIV bl
    
    cmp bh, 0               ; if no coeff
    JE j1_NCOEF

j1_place:    
    add al, 48
    mov [esi], al           ; "5"
    inc esi                 ; next indice
    inc bh                  ; else lead coeff
    JMP j2

j1_NCOEF:                   
    cmp al, 0               ; go back to place if > 0 and no coeff
    JG j1_place
    ; else next indice

;--------------------------------------------
j2: ; ah = 5
    movzx ax, ah            ; 5
    mov bl, 1               ; 1
    DIV bl

    cmp bh, 0               ; if no coeff
    JE j2_NCOEF

j2_place:
    add al, 48
    mov [esi], al           ; "5"
    jmp j4

j2_NCOEF:
    cmp al, 0
    JG j2_place

j4:
;end
    popa
    mov esp, ebp
    pop ebp
    ret 4
DecimalToString ENDP
;------------------------------------------------------------------------
LengthOfResult PROC
;
; Recieves: DWORD
;
; returns: length of DWORD
;
;------------------------------------------------------------------------
    push ebp
    mov ebp, esp
    push esi

;Procedure
    mov esi, [ebp + 8]
    mov eax, [esi]
    CMP eax, 100
    JGE j1
    CMP eax, 10
    JGE j2
    JMP j3
j1:
    mov eax, 3
    JMP j4
j2:
    mov eax, 2
    JMP j4
j3:
    mov eax, 1
j4:
;End

    pop esi
    mov esp, ebp
    pop ebp
    ret 4
LengthOfResult ENDP
;------------------------------------------------------------------------



END main 
