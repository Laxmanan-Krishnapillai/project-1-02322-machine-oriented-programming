.ORIG x3000     	; Set the starting address of the program to x3000
MAIN
    ; Call the resultS function
LOOP    LD R6, STACK_START  ; Load initial stack pointer (x4000)
    JSR readS
    JSR CHECK_PRIME
    ADD R0, R0, #0
    JSR resultS      ; Call the resultS function
    BR LOOP
    HALT           	; Halt the program TRAP x25

readS   
        ; Write message on the console
        LEA R0, STRING  ; Load adress of the string into R0
        PUTS        ; Call TRAP x22 to print the string in R0
        
        ; Read first digit
        TRAP x23        ; Read character from keyboard and echo 
        LD R1, NEG48    ; Load -48 from memory
        ADD R0, R0, R1  ; Convert ASCII to numeric value by substracting 48
        ST R0, DIG1  ; Store R0 in 
 
        ; Read second digit
        TRAP x23        ; Read character from keyboard and echo
        ADD R0, R0, R1  ; Convert ASCII to numeric value by substracting 48
        ST R0, DIG2  ; Store R0 in 
        
        ; Multiply the first integer to factor in the digit placement and add to second digit
        LD R0, DIG1    ; Load the first digit to multiply
        
        AND R1, R1, #0  ; Clearing R1
        AND R2, R2, #0  ; Clearing R2

        ADD R1, R0, R0   ; R1 = R0 * 2  (x2)
        ADD R2, R1, R1   ; R2 = R1 * 2  (x4)
        ADD R2, R2, R2   ; R2 = R2 * 2  (x8)
        ADD R2, R2, R1   ; R2 = (x8) + (x2) = x10
        
        LD R0, DIG2    ; Load the the sedond digit
        ADD R0, R2, R0  ; add the second digit value to the multiplied first digit

        RET             ; Return from the function

; Function: resultS
; Input: R0 (integer)
; Output: Prints a message based on whether R0 is zero or non-zeroresultS   
resultS       
        BRz NOTPRIME    ; Branches to NOTPRIME if R0 == 0
        
        LEA R0, PRIME   ; LOAD PRIME message to R0
        PUTS            ; Call TRAP x22 to print the string in R0
        RET             ; Return from the function
        
NOTPRIME
        LEA R0, NPRIME  ; LOAD NPRIME message to R0
        PUTS            ; Call TRAP x22 to print the string in R0
        RET             ; Return from the function    	
;---------------------------
; Checks if a number is prime. Takes input from R0 and returns 1 in R0 if true else returns 0 in R0
CHECK_PRIME
    ; Check if input number is 2
    ADD R0, R0, #-2
    BRz IS_PRIME_EARLY_RETURN
    ADD R0, R0, #2

    ; Save registers in stack
    ADD R4, R7, #0
    JSR PUSH
    ADD R4, R1, #0
    JSR PUSH
    ADD R4, R2, #0
    JSR PUSH
    ADD R4, R3, #0
    JSR PUSH
    ; Load divisor
    AND R1, R1, #0
    ADD R1, R1, #2
CHECK_LOOP
    JSR SQUARE ; SQUARE Divisor^2
    NOT R2, R2
    ADD R2, R2, #1
    ADD R2, R2, R0 ; Check if Divisor^2 <= N
    BRn IS_PRIME
    JSR MODULO
    ADD R3, R3, #0
    BRz NOT_PRIME
    ADD R1, R1, #1
    BR CHECK_LOOP

IS_PRIME
    AND R0, R0, #0
    ADD R0, R0, #1
    BR RESTORE_REGS

NOT_PRIME
    AND R0, R0, #0
    BR RESTORE_REGS

IS_PRIME_EARLY_RETURN
    AND R0, R0, #0
    ADD R0, R0, #0
    RET
RESTORE_REGS
    JSR POP
    ADD R3, R4, #0

    JSR POP
    ADD R2, R4, #0

    JSR POP
    ADD R1, R4, #0

    JSR POP
    ADD R7, R4, #0
    RET

; Squaring value
SQUARE
    ; Save the current return address (R7)
    ADD R4, R7, #0
    JSR PUSH

    ADD R4, R0, #0
    JSR PUSH

    ADD R4, R1, #0
    JSR PUSH

    ADD R0, R1, #0
    AND R2, R2, #0 ; Sum
SQUARE_LOOP    
    ADD R2, R2, R1
    ADD R0, R0, #-1
    BRp SQUARE_LOOP
    
    JSR POP
    ADD R1, R4, #0

    JSR POP
    ADD R0, R4, #0

    JSR POP
    ADD R7, R4, #0
    RET

MODULO
    ADD R4, R7, #0
    JSR PUSH

    ADD R4, R0, #0
    JSR PUSH

    ADD R4, R1, #0
    JSR PUSH

    AND R3, R3, #0 ; Remainder
    NOT R1, R1 ; 
    ADD R1, R1, #1 ; 2's complement
MOD_LOOP
    ADD R0, R0, R1
    BRn END_MOD
    ADD R3, R0, #0
    BR MOD_LOOP
END_MOD
    JSR POP
    ADD R1, R4, #0

    JSR POP
    ADD R0, R4, #0

    JSR POP
    ADD R7, R4, #0
    RET
PUSH
    ADD R6, R6, #-1      ; Decrement SP
    STR R4, R6, #0       ; Store value from R4
    RET
POP
    LDR R4, R6, #0       ; Load value into R4
    ADD R6, R6, #1       ; Increment SP
    RET

; Stack Base Address
STACK_START .FILL x4000
MAX          .FILL xC005
EMPTY        .FILL x4000
PRIME   .STRINGZ "The number is prime\n" ; Storing the string to output "The number is prime"
NPRIME  .STRINGZ "The number is not prime\n" ; Storing the string to output "The number is not prime"
NUM     .FILL 0         ; Store 2 in this case the argument. Used to test the function and can be changed.  	
STRING  .STRINGZ "Input a 2 digit decimal number:" ; 
DIG1    .BLKW 1
DIG2    .BLKW 1
NEG48   .FILL -48   ; Store -48 in memory    
.END



