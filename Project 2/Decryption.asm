; Name: Lawrence Cole
; Project 2
; Decryption Program

.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

WriteConsoleA PROTO, hConsoleOutput:DWORD,lpBuffer:PTR BYTE,nNumberOfCharsToWrite:DWORD,lpNumberofCharsWritten:PTR DWORD,lpReserved:DWORD
CreateFileA PROTO, lpFilename:PTR BYTE, dwDESIredAccess:DWORD, dwShareMode:DWORD, lpSecurityAttributes:DWORD, dwCreationDisposition:DWORD, dwFlagsAndAttributes:DWORD, hTemplateFile:DWORD
GetLastError PROTO
GetStdHandle PROTO, nStdHandle:DWORD
CloseHandle PROTO, hObject:DWORD
ReadFile PROTO, hFile:DWORD, lpBuffer:PTR BYTE, nNumberOfBytesToRead:DWORD, lpNumberOfBytesRead:PTR DWORD, lpOverlapped:PTR DWORD

.data
STD_INPUT_HANDLE    EQU -10
STD_OUTPUT_HANDLE   EQU -11
GENERIC_READ        EQU <80000000h>
OPEN_EXISTING       EQU <3>
NORMal_FLAGS        EQU <128>
buffer              BYTE 300 DUP(?)
filename            BYTE "encryption.txt",0
ERROR_MESSAGE       BYTE "The File does not exist.",0
encryption_length   BYTE ?
modulo              BYTE ?
fileHandle          DWORD ?
bytesRead           DWORD ?

.code
main PROC
    INVOKE CreateFileA, ADDR filename, GENERIC_READ, 0, 0, OPEN_EXISTING, NORMal_FLAGS, 0  ; Read File
    MOV fileHandle, EAX
    INVOKE GetLastError

    ; If the text file does not exist, output an error message and quit
    CMP EAX, 2
    JNE FILE_EXISTS

        ; Error Message
    PUSH LENGTHOF ERROR_MESSAGE 
    PUSH OFFSET ERROR_MESSAGE
    CALL WriteOutput
    JMP END_OF_PROGRAM

    ; If it does exist, read the first input length and modulo number from the text file
    FILE_EXISTS:
    INVOKE ReadFile, fileHandle, ADDR buffer, SIZEOF buffer, ADDR bytesRead, 0 ; read file into buffer
    MOV al, buffer[0]
    MOV encryption_length, al   ; read length of input
    MOV al, buffer[1]
    MOV modulo, al              ; read modulo number

    ; If there is nothing to read, end the program
    CMP bytesRead, 0
    JNE SOMETHING_READ
    JMP END_OF_PROGRAM

    ; Use the length of the input to read the first batch of input
    SOMETHING_READ:
    MOV ESI, OFFSET buffer  ; get input offset 
    ADD ESI, 2              ; from buffer offset

    ; If the modulo number is 0, decrypt the data by flipping all of the bits of each character of the input
    CMP modulo, 0
    JNE MODULO_NOT_0
    
    MOVZX EAX, encryption_length
    PUSH EAX                        ; Length
    PUSH ESI                        ; Offset for input
    CALL UndoFlippedBits            
    JMP WRITE_DECRYPTED_TO_CONSOLE

    ; If the modulo is not 0, decrypt the data by rolling each character to the right a number of times equal to the modulo
    MODULO_NOT_0:
    MOVZX EAX, modulo
    PUSH EAX                        ; modulo
    MOVZX EAX, encryption_length
    PUSH EAX                        ; Length
    PUSH ESI                        ; Offset for input
    CALL UndoRolledString

    ; Write the decrypted input to the console
    WRITE_DECRYPTED_TO_CONSOLE:
    MOVZX EAX, encryption_length
    PUSH EAX                        ; length
    PUSH ESI                        ; offset for input
    CALL WriteOutput

    ; Repeat from step 2
    JMP FILE_EXISTS
END_OF_PROGRAM:
    INVOKE CloseHandle, fileHandle
    INVOKE ExitProcess, 0
main ENDP

;------------------------------------------------------------------------
;                           Procedures
;------------------------------------------------------------------------

;------------------------------------------------------------------------
UndoRolledString PROC
;
; rolls each character to the left equal to the modulo
;
; Receives: ESI = offset
;           ECX = length
;
; Returns: nothing
;------------------------------------------------------------------------
    PUSH EBP
    MOV EBP, ESP

    PUSH ESI
    PUSH ECX   
    PUSH EAX
    PUSH EDX
; Procedure
    MOV ESI, [EBP + 8]  ; offset
    MOV ECX, [EBP + 12] ; length
    MOV EDX, [EBP + 16] ; modulo amount
l1:            
    MOV al, [ESI]   ; value to al
    PUSH ECX        ; save outer loop

    MOV ECX, EDX    ; set nest loop counter
    roll_modulo:
        ror al, 1   ; roll char modulo times
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
UndoRolledString ENDP
;------------------------------------------------------------------------
;------------------------------------------------------------------------
UndoFlippedBits PROC
;
; flips bits of each byte in string
;
; Receives: ESI = offset
;           ECX = length
;
; Returns: nothing
;------------------------------------------------------------------------
    PUSH EBP
    MOV EBP, ESP

    PUSH ESI
    PUSH ECX   
    PUSH EAX

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
UndoFlippedBits ENDP
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
    PUSH EBP
    MOV EBP, ESP

    ; Local variables
    ; [EBP - 4] = the output handle
    ; [EBP - 8] = the number of bytes successfully written
    sub ESP, 8

    ; Preserve registers
    ; Windows functions do not preserve EAX, EBX, ECX, or EDX
    ; They need to be preserved even if they go unused
    PUSH EBX
    PUSH ECX
    PUSH EDX

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