; Name: Lawrence Cole
; Project 2
; Decryption Program

.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

WriteConsoleA PROTO, hConsoleOutput:DWORD,lpBuffer:PTR BYTE,nNumberOfCharsToWrite:DWORD,lpNumberofCharsWritten:PTR DWORD,lpReserved:DWORD
CreateFileA PROTO, lpFilename:PTR BYTE, dwDesiredAccess:DWORD, dwShareMode:DWORD, lpSecurityAttributes:DWORD, dwCreationDisposition:DWORD, dwFlagsAndAttributes:DWORD, hTemplateFile:DWORD
GetLastError PROTO
GetStdHandle PROTO, nStdHandle:DWORD
CloseHandle PROTO, hObject:DWORD
ReadFile PROTO, hFile:DWORD, lpBuffer:PTR BYTE, nNumberOfBytesToRead:DWORD, lpNumberOfBytesRead:PTR DWORD, lpOverlapped:PTR DWORD

.data
STD_INPUT_HANDLE    EQU -10
STD_OUTPUT_HANDLE   EQU -11
GENERIC_READ        EQU <80000000h>
OPEN_EXISTING       EQU <3>
NORMAL_FLAGS        EQU <128>
buffer              BYTE 300 DUP(?)

filename            BYTE "encryption.txt",0
ERROR_MESSAGE       BYTE "File does not exist.",0
fileHandle          DWORD ?
bytesRead           DWORD ?
encryption_length   BYTE ?
modulo              BYTE ?

.code
main PROC
START_OF_PROGRAM:
    INVOKE CreateFileA, ADDR filename, GENERIC_READ, 0, 0, OPEN_EXISTING, NORMAL_FLAGS, 0  ; Read File
    mov fileHandle, eax
    INVOKE GetLastError

    ; If the text file does not exist, output an error message and quit
    CMP eax, 2
    JNE FILE_EXISTS

    ; Error Message
    PUSH LENGTHOF ERROR_MESSAGE 
    PUSH OFFSET ERROR_MESSAGE
    CALL WriteOutput
    JMP END_OF_PROGRAM

    ; If it does exist, read the first input length and modulo number from the text file
    FILE_EXISTS:
    INVOKE ReadFile, fileHandle, ADDR buffer, SIZEOF buffer, ADDR bytesRead, 0 ; read file into buffer
    mov al, buffer[0]
    mov encryption_length, al   ; read length of input
    mov al, buffer[1]
    mov modulo, al              ; read modulo number

    ; If there is nothing to read, end the program
    CMP bytesRead, 0
    JNE SOMETHING_READ
    JMP END_OF_PROGRAM

    ; Use the length of the input to read the first batch of input
    SOMETHING_READ:
    mov esi, offset buffer  ; get input offset 
    add esi, 2              ; from buffer offset

    ; If the modulo number is 0, decrypt the data by flipping all of the bits of each character of the input
    CMP modulo, 0
    JNE MODULO_NOT_0
    
    movzx eax, encryption_length
    PUSH EAX                        ; Length
    PUSH ESI                        ; Offset for input
    CALL UndoFlippedBits            
    JMP WRITE_DECRYPTED_TO_CONSOLE

    ; If the modulo is not 0, decrypt the data by rolling each character to the right a number of times equal to the modulo
    MODULO_NOT_0:
    movzx eax, modulo
    push EAX                        ; modulo
    movzx eax, encryption_length
    push EAX                        ; Length
    PUSH ESI                        ; Offset for input
    CALL UndoRolledString

    ; Write the decrypted input to the console
    WRITE_DECRYPTED_TO_CONSOLE:
    movzx eax, encryption_length
    push eax
    PUSH ESI
    CALL WriteOutput

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
UndoRolledString PROC
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
        ror al, 1   ; roll char modulo times
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
UndoRolledString ENDP
;------------------------------------------------------------------------
;------------------------------------------------------------------------
UndoFlippedBits PROC
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
UndoFlippedBits ENDP
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