COMMENT &
    INSTRUCTIONS:
    1. Place a breakpoint on each of the lines with a breakpoint comment, and then run the debugger.

    2. While the debugger is stopped on the first line, make sure you have the Registers, Watch, 
       and Memory windows visible. 
       
       If you do not see some of them, you can open them by going to Debug > Windows at the toolbar 
       at the top of the Visual Studio window and finding them in the list. Once they are open you 
       can move them wherever you want in Visual Studio.

    3. Hit the Continue button (with a green arrow) to run your code until the next 
       breakpoint (breakpoint 2)

    4. In the watch window, enter "listptr" to begin a watch for the listptr variable. Right click 
       listptr in the watch window and select "hexadecimal display" to show its value in hexadecimal.

    5. In the memory window, enter the value of the listptr variable in the address bar at the top 
       and hit enter (the value you enter must be a hexadecimal or you may encounter an error).

    6. You should now see the location in memory where the variables used in this program are stored.

       The first 32 values are the values of the list array (1b, 13, 12, etc.). They are stored in 
       the same order that they are entered in the .data section of this program
       
       After the list you should see 20 00 00 00. This is the value of the listlen variable. It is a 
       DWORD so it takes up 4 bytes, and it is stored in little-endian order, so to find the actual 
       hex value of the variable we have to reverse the order of its bytes: 00000020. This is 
       hexadecimal for 32, which is the initial value of the variable (as seen in the .data segment)

       The next 4 bytes are the listptr variable. The value will change each time you run the program.
       If you reverse the order of the 4 bytes, it should match the value you see in the watch window.

       If any of these 3 values don't match what you expect them to be, then stop the program and 
       follow the instructions from the beginning.

    7. Each time you run the program the memory location used for variables changes. If you restart 
       the program you will need to re-enter the value of listptr into the Memory window address bar 
       while you are stopped at breakpoint 2.

    8. Whenever you hit Continue or Step Over in the debugger, any values in memory that change are 
       written in red in the Memory, Registers, and Watch windows. 

    9. Type your answers below and submit this code file with your answers to the Lab 2 assignment page. 
       You will need to stop the debugger to enter your answers, so you may want to write them in a 
       different file or on some paper and then type them below once you've finished running the program.


    QUESTIONS: 
    1. Enter your name here: 

            Lawrence Cole

    2. Press Continue once and you will stop at breakpoint 3. Make a note of the values you see in 
       your Memory and Watch windows.
       Now press Continue once. Your program should still be stopped at breakpoint 3. 
       
       What value changed when you hit Continue? How did it change?

            EAX and EIP changed, EAX is set to 0 whilst EIP increased in value

    3. Press continue one more time. Your program should still be at breakpoint 3.
       
       Did any memory values change this time? If so, what changed?

            Registers EAX, ECX, ESI, EDI, and EFL changed and a value has changed to 01

    4. Remove breakpoint 3 and then press Continue. Your program should now be stopped at breakpoint 4. 
       At this point the program has completed Code Section 1.

       Look at the values of the list array in memory. What did Code Section 1 do to the list?
            
            The list now counts up to 1f every element, Code Section 1 iterates and changes values

    5. Press Continue again and you will be stopped at breakpoint 5. At this point, each time you 
       press continue you will remain at breakpoint 5, but the values in the list will change.
       Take a look at the ECX register, either in the Registers window or by viewing it in the Watch window.

       What happens to ECX each time you hit continue? Why do you think it is doing that?
            
            ECX is counting down which could be keeping count for iterating through the list

    6. If you keep pressing Continue you will eventually move on to breakpoint 6. You can also 
       remove breakpoint 5 and then hit Continue once to jump straight to breakpoint 6.
       This is the end of Code Section 2 and the end of the whole program.

       Look at the values of the list array in memory. What did Code Section 2 do to the list?

            Code Section 2 reversed the list array
&

.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

ol EQU <OFFSET list>

.data
list BYTE 1bh, 13h, 12h, 0ah, 1ch, 02h, 10h, 1ah, 1fh, 14h, 09h, 0bh, 11h, 19h, 18h, 1eh
     BYTE 00h, 15h, 01h, 05h, 17h, 06h, 03h, 1dh, 0ch, 04h, 07h, 08h, 0dh, 0eh, 0fh, 16h
listlen DWORD 32
listptr DWORD ?

.code
main PROC
    mov ecx, listlen        ; put breakpoint 1 here
    mov esi, ol
    mov listptr, esi
    mov eax, 0              ; put breakpoint 2 here

;-------- Code Section 1 --------
l1: 
    mov eax, esi            ; put breakpoint 3 here
    cmp eax, ol
    je l2

    mov al, [esi]
    mov ah, [edi]
    cmp al, ah
    jae l2

    mov [esi], ah
    mov [edi], al
    dec esi
    dec edi
    jmp l1
l2:
    mov esi, listptr
    mov edi, esi
    inc esi
    mov listptr, esi
    loop l1


;-------- Code Section 2 --------

    CALL findend            ; put breakpoint 4 here
    mov edx, ol
    mov ecx, 0
    add ecx, listlen
    shr ecx, 1
l3:
    mov bl, [eax]           ; put breakpoint 5 here
    mov bh, [edx]
    mov [edx], bl
    mov [eax], bh
    inc edx
    dec eax
    loop l3

    INVOKE ExitProcess, 0   ; put breakpoint 6 here
main ENDP

findend PROC
    mov eax, ol
    add eax, listlen
    dec eax 
    ret
findend ENDP
END main
