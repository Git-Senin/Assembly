; Name: Lawrence Cole
; Programming Lab 9
; Searching Strings 
.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

.data
string byte "She sells seashells down by the seashore."
oldletter byte 's'
newletter byte 't'

.code
main PROC

    mov ecx, LENGTHOF string            ; Loop Counter
    mov esi, OFFSET string              ; begin of string
    mov edi, OFFSET string
    cld                                 ; direction = forward
L1: 
    LODSB                               ; [esi] into al and inc esi
    cmp al, oldletter                   ; compare current letter to oldletter
    JNE LOOP_END                        ; exit loop if not 's'
    mov al, newletter                   ; prepare newLetter in al
    LOOP_END:
    STOSB                               ; replace current letter with letter in al
    loop L1
    
    INVOKE ExitProcess, 00

main ENDP
END main 
