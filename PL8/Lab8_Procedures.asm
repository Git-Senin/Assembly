.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD
MessageBoxA PROTO, hWnd:DWORD, lpText:PTR BYTE, lpCaption:PTR BYTE,uType:DWORD

.code

;-------------------------------------------
Display PROC
; Displays a null-terminated string in a Windows message box
; Receives: 
;   the pointer to the string to display
;   (push the pointer onto the stack before calling)
; Returns: Nothing
;-------------------------------------------
    ; Create stack frame - prologue
    push ebp
    mov ebp, esp

    ; Create local variable:
    ; the word "Message" for the window caption
    sub esp, 8
    mov [ebp - 8], dword ptr 7373654Dh
    mov [ebp - 4], dword ptr 00656761h

    ; Save registers
    pushad

    ; Procedure code
    lea ebx, [ebp - 8]                              ; get the local variable's address
    INVOKE MessageBoxA, 0, [ebp + 8], ebx, 0        ; display the message window

    ; Clean up stack frame and return - epilogue
    popad
    mov esp, ebp
    pop ebp
    ret 4
Display ENDP


END