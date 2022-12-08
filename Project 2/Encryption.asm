; Name: Lawrence Cole
; Project 2
; Encryption Program

.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

ReadConsoleA PROTO, hConsoleInput:DWORD, lpbuffer: PTR BYTE, nNumberOfCharsToRead:DWORD,lpNumberOfCharsRead:PTR DWORD, lpReserved:DWORD
WriteConsoleA PROTO, hConsoleOutput:DWORD,lpBuffer:PTR BYTE,nNumberOfCharsToWrite:DWORD,lpNumberofCharsWritten:PTR DWORD,lpReserved:DWORD
CreateFileA PROTO, lpFilename:PTR BYTE, dwDESIredAccess:DWORD, dwShareMode:DWORD, lpSecurityAttributes:DWORD, dwCreationDisposition:DWORD, dwFlagsAndAttributes:DWORD, hTemplateFile:DWORD
WriteFile PROTO, hFile:DWORD, lpBuffer:PTR BYTE, nNumberOfBytesToWrite:DWORD, lpNumberOfBytesWritten:PTR DWORD, lpOverlapped:PTR DWORD
GetStdHandle PROTO, nStdHandle:DWORD
CloseHandle PROTO, hObject:DWORD

.data
STD_INPUT_HANDLE    EQU -10
STD_OUTPUT_HANDLE   EQU -11
GENERIC_WRITE       EQU <40000000h>
ALWAYS_CREATE       EQU <2>
NORMAL_FLAGS        EQU <128>
buffer              BYTE 300 DUP(?)  
START_PROMPT        BYTE "Type anything of your choice, or just 'q' to quit: ",0
filename            BYTE "encryption.txt",0
amount_of_e         BYTE ?
modulo              BYTE ?
fileHandle          DWORD ?
bytesWritten        DWORD ?
length_of_input     DWORD ?

.code
main PROC
    ; Tell the user to type anything of their choice, or just 'q' to quit.
    PUSH LENGTHOF START_PROMPT
    PUSH OFFSET START_PROMPT
    CALL WriteOutput
    
    ; Read the user's input
    STEP_2:
    PUSH SIZEOF buffer  ; size of buffer
    PUSH OFFSET buffer  ; buffer offset
    CALL ReadInput
    SUB EAX, 2
    MOV length_of_input, EAX  

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
    MOV amount_of_e, al
    
    ; Find the number of e's modulo 8 (the remainder when divided by 8)
    MOVZX ax, al
    MOV bl, 8
    DIV bl
    MOV modulo, ah

    ; If the modulo is 0, encrypt the data by flipping all of the bits of each character in the input
    CMP modulo, 0
    JNE MODULO_NOT_0 

        ; Flip bits
    MOV EAX, length_of_input    ; length
    PUSH EAX                
    PUSH OFFSET buffer          ; offset
    CALL FlipBits
    JMP EXPORT_ENCRYPTION

    ; If the modulo is not 0, encrypt the data by rolling the bits of each character to the left a number of times equal to the modulo
    MODULO_NOT_0:
    MOVZX EAX, modulo           ; modulo
    PUSH EAX
    MOV EAX, length_of_input    ; length
    PUSH EAX
    PUSH OFFSET buffer          ; offset
    CALL RollString

    ; Write the length of the input, the modulo number, and then the encrypted input to the text file
    EXPORT_ENCRYPTION:
    INVOKE CreateFileA, ADDR filename, GENERIC_WRITE, 0, 0, ALWAYS_CREATE, NORMAL_FLAGS, 0  ; Create File
    MOV fileHandle, EAX
    INVOKE WriteFile, fileHandle, ADDR length_of_input, 1, ADDR bytesWritten, 0             ; Write length of input
    INVOKE WriteFile, fileHandle, ADDR modulo, 1,           ADDR bytesWritten, 0            ; Write modulo number
    INVOKE WriteFile, fileHandle, ADDR buffer, length_of_input, ADDR bytesWritten, 0        ; Write encrypted Input

    ; Repeat from step 2
    JMP STEP_2
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
; Receives: ESI = offset
;           ECX = length
;
; Returns: nothing
;------------------------------------------------------------------------
    push EBP
    MOV EBP, ESP

    push ESI
    push ECX   
    push EAX
    push EDX
; Procedure
    MOV ESI, [EBP + 8]  ; offset
    MOV ECX, [EBP + 12] ; length
    MOV EDX, [EBP + 16] ; modulo amount
l1:            
    MOV al, [ESI]   ; value to al
    push ECX        ; save outer loop

    MOV ECX, EDX    ; set nest loop counter
    roll_modulo:
        rol al, 1   ; roll char modulo times
    loop roll_modulo
    MOV [ESI], al   ; set element to new bits

    pop ECX         ; return outer loop
    inc ESI         ; next element
loop l1

; End of Procedure
    pop EDX
    pop EAX
    pop ECX
    pop ESI

    MOV ESP, EBP
    pop EBP
    ret 12
RollString ENDP
;------------------------------------------------------------------------
;------------------------------------------------------------------------
FlipBits PROC
;
; flips bits of each byte in string
;
; Receives: ESI = offset
;           ECX = length
;
; Returns: nothing
;------------------------------------------------------------------------
    push EBP
    MOV EBP, ESP

    push ESI
    push ECX   
    push EAX

; Procedure

    MOV ESI, [EBP + 8]  ; offset
    MOV ECX, [EBP + 12] ; length
l1:            
    MOV al, [ESI]       ; Value to al
    xor al, 11111111b
    MOV [ESI], al       ; ah to value
    inc ESI             ; next element
loop l1

; End of Procedure

    pop EAX
    pop ECX
    pop ESI

    MOV ESP, EBP
    pop EBP
    ret 8
FlipBits ENDP
;------------------------------------------------------------------------
;------------------------------------------------------------------------
CountLetterE PROC
;
; Counts and returns 'e's in given string
;
; Receives: ESI = offset
;           ECX = length
;
; Returns: AL = amount of e's in String
;------------------------------------------------------------------------

    push EBP
    MOV EBP, ESP

    push ESI
    push ECX   
; Procedure

    MOV ESI, [EBP + 8]  ; offset
    MOV ECX, [EBP + 12] ; length
    MOV al, 0
l1:
    MOV bl, BYTE PTR [ESI] ; get char
    CMP bl, 'e'
    JNE NEXT_INDEX
    inc al
    NEXT_INDEX:
    inc ESI ; next element
loop l1

; End of Procedure
    pop ECX
    pop ESI

    MOV ESP, EBP
    pop EBP
    ret 8
CountLetterE ENDP
;------------------------------------------------------------------------
;------------------------------------------------------------------------
ReadInput PROC
;
; Reads a string from the console
;
; Receives: [EBP + 8] = the pointer to the buffer where the input string will be stored
;           [EBP + 12] = the size limit of the buffer
; (make sure to leave 2 spaces for the end-of-line characters)
;
; Returns: EAX = the number of bytes read during the input
;------------------------------------------------------------------------

    ; Prologue - set up the stack frame
    push EBP
    MOV EBP, ESP

    ; Local variables
    ; [EBP - 4] = the input handle
    ; [EBP - 8] = the number of bytes successfully read
    sub ESP, 8

    ; Preserve registers
    ; Windows functions do not preserve EAX, EBX, ECX, or EDX
    ; They need to be preserved even if they go unused
    push EBX
    push ECX
    push EDX

    ; Procedure code
    invoke GetStdHandle, STD_INPUT_HANDLE                               ; get the input handle
    MOV [EBP - 4], EAX                                                  ; save the input handle in a local variable

    lea EDX, [EBP - 8]                                                  ; EDX = pointer to variable holding bytes read

    invoke ReadConsoleA, [EBP - 4], [EBP + 8], [EBP + 12], EDX, 0       ; read the input
    MOV EAX, [EBP - 8]                                                  ; set return value

    ; Epilogue - clean up stack frame and return
    pop EDX
    pop ECX
    pop EBX
    MOV ESP, EBP
    pop EBP
    ret 8
ReadInput ENDP
;------------------------------------------------------------------------
;------------------------------------------------------------------------
WriteOutput PROC
;
; Writes a string to the console
;
; Receives: [EBP + 8] = the pointer to the buffer where the output string is stored
;           [EBP + 12] = the number of characters to write
;
; Returns: EAX = the number of bytes written
;------------------------------------------------------------------------

    ; Prologue - set up the stack frame
    push EBP
    MOV EBP, ESP

    ; Local variables
    ; [EBP - 4] = the output handle
    ; [EBP - 8] = the number of bytes successfully written
    sub ESP, 8

    ; Preserve registers
    ; Windows functions do not preserve EAX, EBX, ECX, or EDX
    ; They need to be preserved even if they go unused
    push EBX
    push ECX
    push EDX

    ; Procedure code
    invoke GetStdHandle, STD_OUTPUT_HANDLE                          ; get the output handle
    MOV [EBP - 4], EAX                                              ; save the output handle in a local variable

    lea EDX, [EBP - 8]                                              ; EDX = pointer to variable holding bytes written

    invoke WriteConsoleA, [EBP - 4], [EBP + 8], [EBP + 12], EDX, 0   ; read the input
    MOV EAX, [EBP - 8]                                              ; set return value

    ; Epilogue - clean up the stack frame and return
    pop EDX
    pop ECX
    pop EBX
    MOV ESP, EBP
    pop EBP
    ret 8
WriteOutput ENDP
;------------------------------------------------------------------------

END main 