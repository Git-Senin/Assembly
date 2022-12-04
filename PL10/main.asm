; Name: Lawrence Cole
; Programming Lab 10
; File I/O and Structures 

.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

CreateFileA PROTO, lpFilename:PTR BYTE, dwDesiredAccess:DWORD, dwShareMode:DWORD, lpSecurityAttributes:DWORD, dwCreationDisposition:DWORD, dwFlagsAndAttributes:DWORD, hTemplateFile:DWORD
WriteFile PROTO, hFile:DWORD, lpBuffer:PTR BYTE, nNumberOfBytesToWrite:DWORD, lpNumberOfBytesWritten:PTR DWORD, lpOverlapped:PTR DWORD
CloseHandle PROTO, hObject:DWORD
GetLocalTime PROTO, lpSystemTime:PTR SYSTEMTIME

.data
SYSTEMTIME STRUCT
    wYear WORD ?
    wMonth WORD ?
    wDayOfWeek WORD ?
    wDay WORD ?
    wHour WORD ?
    wMinute WORD ?
    wSecond WORD ?
    wMilliseconds WORD ?
SYSTEMTIME ENDS

GENERIC_WRITE   EQU <40000000h>
ALWAYS_CREATE   EQU <2>
NORMAL_FLAGS    EQU <128>

; Note: computer times are given in 24 hour format
nightPrompt     BYTE "This program was last run at night."              ; output this if the hour is between 0-5
morningPrompt   BYTE "This program was last run in the morning."        ; output this if the hour is between 6-11
afternoonPrompt BYTE "This program was last run in the afternoon."      ; output this if the hour is between 12-17
eveningPrompt   BYTE "This program was last run in the evening."        ; output this if the hour is between 18-23
filename        BYTE "lab10_output.txt",0
fileHandle      DWORD ?
bytesWritten    DWORD ?

sysTime SYSTEMTIME <>

.code
main PROC

    INVOKE CreateFileA, ADDR filename, GENERIC_WRITE, 0, 0, ALWAYS_CREATE, NORMAL_FLAGS, 0
    mov fileHandle, eax

    INVOKE GetLocalTime, ADDR sysTime
    movzx eax, sysTime.wHour

    cmp eax, 5
    JNG NIGHT
    CMP eax, 11
    JNG MORNING
    CMP eax, 17
    JNG AFTERNOON
    CMP eax, 23
    JNG EVENING
    JMP END_COMPARISON

    NIGHT:
    INVOKE WriteFile, fileHandle, ADDR nightPrompt, LENGTHOF nightPrompt, ADDR bytesWritten, 0
    JMP END_COMPARISON

    MORNING:
    INVOKE WriteFile, fileHandle, ADDR morningPrompt, LENGTHOF morningPrompt, ADDR bytesWritten, 0
    JMP END_COMPARISON

    AFTERNOON:
    INVOKE WriteFile, fileHandle, ADDR afternoonPrompt, LENGTHOF afternoonPrompt, ADDR bytesWritten, 0
    JMP END_COMPARISON

    EVENING:
    INVOKE WriteFile, fileHandle, ADDR eveningPrompt, LENGTHOF eveningPrompt, ADDR bytesWritten, 0
    JMP END_COMPARISON

    END_COMPARISON:
    INVOKE CloseHandle, fileHandle
    INVOKE ExitProcess, 0
main ENDP

END main 