; Name: Lawrence Cole
; Project 2
; Encryption Program

.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

ReadConsoleA PROTO, hConsoleInput:DWORD, lpbuffer: PTR BYTE, nNumberOfCharsToRead:DWORD,lpNumberOfCharsRead:PTR DWORD, lpReserved:DWORD
WriteConsoleA PROTO, hConsoleOutput:DWORD,lpBuffer:PTR BYTE,nNumberOfCharsToWrite:DWORD,lpNumberofCharsWritten:PTR DWORD,lpReserved:DWORD

CreateFileA PROTO, lpFilename:PTR BYTE, dwDesiredAccess:DWORD, dwShareMode:DWORD, lpSecurityAttributes:DWORD, dwCreationDisposition:DWORD, dwFlagsAndAttributes:DWORD, hTemplateFile:DWORD
WriteFile PROTO, hFile:DWORD, lpBuffer:PTR BYTE, nNumberOfBytesToWrite:DWORD, lpNumberOfBytesWritten:PTR DWORD, lpOverlapped:PTR DWORD

GetStdHandle PROTO, nStdHandle:DWORD
CloseHandle PROTO, hObject:DWORD

.data
STD_INPUT_HANDLE    EQU -10
STD_OUTPUT_HANDLE   EQU -11
GENERIC_WRITE       EQU <40000000h>
ALWAYS_CREATE       EQU <2>
NORMAL_FLAGS        EQU <128>
length_of_input DWORD ?
START_PROMPT    BYTE "Type anything of your choice: ",0
buffer          BYTE 300 DUP(?)  
amount_of_e     BYTE ?
modulo          BYTE ?
filename        BYTE "encryption.txt",0
fileHandle      DWORD ?
bytesWritten    DWORD ?

.code
main PROC
START_OF_PROGRAM:
    ; Tell the user to type anything of their choice, or just 'q' to quit.
    PUSH LENGTHOF START_PROMPT
    PUSH OFFSET START_PROMPT
    CALL WriteOutput
    
    ; Read the user's input
    PUSH SIZEOF buffer  ; size of buffer
    PUSH OFFSET buffer  ; buffer offset
    CALL ReadInput
    SUB EAX, 2
    mov length_of_input, eax  

    ; If the user entered just 'q', end the program
    CMP EAX, 1
    JNE COMPARISON_END
    CMP buffer, 'q'
    JE END_OF_PROGRAM
    COMPARISON_END:
    
    ; Else, count the number of lowercase e's in the input
    PUSH LENGTHOF buffer
    PUSH OFFSET buffer
    CALL CountLetterE
    mov amount_of_e, al
    
    ; Find the number of e's modulo 8 (the remainder when divided by 8)
    movzx ax, al
    mov bl, 8
    DIV bl
    mov modulo, ah

    ; If the modulo is 0, encrypt the data by flipping all of the bits of each character in the input
    CMP modulo, 0
    JNE MODULO_NOT_0 

    ; Flip bits
    mov eax, length_of_input    ; length
    PUSH EAX                
    PUSH OFFSET buffer          ; offset
    CALL FlipBits
    JMP EXPORT_ENCRYPTION

    ; If the modulo is not 0, encrypt the data by rolling the bits of each character to the left a number of times equal to the modulo
    MODULO_NOT_0:
    movzx eax, modulo           ; modulo
    PUSH EAX
    mov eax, length_of_input    ; length
    PUSH EAX
    PUSH OFFSET buffer          ; offset
    CALL RollString

    ; Write the length of the input, the modulo number, and then the encrypted input to the text file
    EXPORT_ENCRYPTION:
    INVOKE CreateFileA, ADDR filename, GENERIC_WRITE, 0, 0, ALWAYS_CREATE, NORMAL_FLAGS, 0  ; Create File
    mov fileHandle, eax
    INVOKE WriteFile, fileHandle, ADDR length_of_input, 1, ADDR bytesWritten, 0             ; Write length of input
    INVOKE WriteFile, fileHandle, ADDR modulo, 1,           ADDR bytesWritten, 0            ; Write modulo number
    INVOKE WriteFile, fileHandle, ADDR buffer, length_of_input, ADDR bytesWritten, 0        ; Write encrypted Input

    ; Repeat from step 2
    JMP START_OF_PROGRAM
END_OF_PROGRAM:
    INVOKE CloseHandle, fileHandle
    INVOKE ExitProcess, 0
main ENDP

;------------------------------------------------------------------------
;                           Procedures
;------------------------------------------------------------------------

;------------------------------------------------------------------------
RollString PROC
;
; rolls each character to the left equal to the modulo
;
; Receives: esi = offset
;           ecx = length
;
; Returns: nothing
;------------------------------------------------------------------------
    push ebp
    mov ebp, esp

    push esi
    push ecx   
    push eax
    push edx
; Procedure
    mov esi, [ebp + 8]  ; offset
    mov ecx, [ebp + 12] ; length
    mov edx, [ebp + 16] ; modulo amount
l1:            
    mov al, [esi]   ; value to al
    push ecx        ; save outer loop

    mov ecx, edx    ; set nest loop counter
    roll_modulo:
        rol al, 1   ; roll char modulo times
    loop roll_modulo
    mov [esi], al   ; set element to new bits

    pop ecx         ; return outer loop
    inc esi         ; next element
loop l1

; End of Procedure
    pop edx
    pop eax
    pop ecx
    pop esi

    mov esp, ebp
    pop ebp
    ret 12
RollString ENDP
;------------------------------------------------------------------------
;------------------------------------------------------------------------
FlipBits PROC
;
; flips bits of each byte in string
;
; Receives: esi = offset
;           ecx = length
;
; Returns: nothing
;------------------------------------------------------------------------
    push ebp
    mov ebp, esp

    push esi
    push ecx   
    push eax

; Procedure

    mov esi, [ebp + 8]  ; offset
    mov ecx, [ebp + 12] ; length
l1:            
    mov al, [esi]       ; Value to al
    xor al, 11111111b
    mov [esi], al       ; ah to value
    inc esi             ; next element
loop l1

; End of Procedure

    pop eax
    pop ecx
    pop esi

    mov esp, ebp
    pop ebp
    ret 8
FlipBits ENDP
;------------------------------------------------------------------------
;------------------------------------------------------------------------
CountLetterE PROC
;
; Counts and returns 'e's in given string
;
; Receives: esi = offset
;           ecx = length
;
; Returns: AL = amount of e's in String
;------------------------------------------------------------------------

    push ebp
    mov ebp, esp

    push esi
    push ecx   
; Procedure

    mov esi, [ebp + 8]  ; offset
    mov ecx, [ebp + 12] ; length
    mov al, 0
l1:
    mov bl, BYTE PTR [esi] ; get char
    CMP bl, 'e'
    JNE NEXT_INDEX
    inc al
    NEXT_INDEX:
    inc esi ; next element
loop l1

; End of Procedure
    pop ecx
    pop esi

    mov esp, ebp
    pop ebp
    ret 8
CountLetterE ENDP
;------------------------------------------------------------------------
;------------------------------------------------------------------------
ReadInput PROC
;
; Reads a string from the console
;
; Receives: [ebp + 8] = the pointer to the buffer where the input string will be stored
;           [ebp + 12] = the size limit of the buffer
; (make sure to leave 2 spaces for the end-of-line characters)
;
; Returns: EAX = the number of bytes read during the input
;------------------------------------------------------------------------

    ; Prologue - set up the stack frame
    push ebp
    mov ebp, esp

    ; Local variables
    ; [ebp - 4] = the input handle
    ; [ebp - 8] = the number of bytes successfully read
    sub esp, 8

    ; Preserve registers
    ; Windows functions do not preserve EAX, EBX, ECX, or EDX
    ; They need to be preserved even if they go unused
    push ebx
    push ecx
    push edx

    ; Procedure code
    invoke GetStdHandle, STD_INPUT_HANDLE                               ; get the input handle
    mov [ebp - 4], eax                                                  ; save the input handle in a local variable

    lea edx, [ebp - 8]                                                  ; EDX = pointer to variable holding bytes read

    invoke ReadConsoleA, [ebp - 4], [ebp + 8], [ebp + 12], edx, 0       ; read the input
    mov eax, [ebp - 8]                                                  ; set return value

    ; Epilogue - clean up stack frame and return
    pop edx
    pop ecx
    pop ebx
    mov esp, ebp
    pop ebp
    ret 8
ReadInput ENDP
;------------------------------------------------------------------------
;------------------------------------------------------------------------
WriteOutput PROC
;
; Writes a string to the console
;
; Receives: [ebp + 8] = the pointer to the buffer where the output string is stored
;           [ebp + 12] = the number of characters to write
;
; Returns: EAX = the number of bytes written
;------------------------------------------------------------------------

    ; Prologue - set up the stack frame
    push ebp
    mov ebp, esp

    ; Local variables
    ; [ebp - 4] = the output handle
    ; [ebp - 8] = the number of bytes successfully written
    sub esp, 8

    ; Preserve registers
    ; Windows functions do not preserve EAX, EBX, ECX, or EDX
    ; They need to be preserved even if they go unused
    push ebx
    push ecx
    push edx

    ; Procedure code
    invoke GetStdHandle, STD_OUTPUT_HANDLE                          ; get the output handle
    mov [ebp - 4], eax                                              ; save the output handle in a local variable

    lea edx, [ebp - 8]                                              ; EDX = pointer to variable holding bytes written

    invoke WriteConsoleA, [ebp - 4], [ebp + 8], [ebp + 12], edx, 0   ; read the input
    mov eax, [ebp - 8]                                              ; set return value

    ; Epilogue - clean up the stack frame and return
    pop edx
    pop ecx
    pop ebx
    mov esp, ebp
    pop ebp
    ret 8
WriteOutput ENDP
;------------------------------------------------------------------------

END main 