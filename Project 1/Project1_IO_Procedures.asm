.386
.model flat, stdcall
.stack 4096
GetStdHandle PROTO, nStdHandle:DWORD
ReadConsoleA PROTO, hConsoleInput:DWORD, lpbuffer: PTR BYTE, nNumberOfCharsToRead:DWORD,lpNumberOfCharsRead:PTR DWORD, lpReserved:DWORD
WriteConsoleA PROTO, hConsoleOutput:DWORD,lpBuffer:PTR BYTE,nNumberOfCharsToWrite:DWORD,lpNumberofCharsWritten:PTR DWORD,lpReserved:DWORD


.data
STD_INPUT_HANDLE EQU -10
STD_OUTPUT_HANDLE EQU -11

.code
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
END