        .ORIG x3000          ; Program starting address

;------------------------------------------------------------
; Main Program Entry Point
MAIN    
        LD   R6, STACK_START ; Load initial stack pointer (x4000)
LOOP    
        JSR  readS         ; Read a 2-digit number from the keyboard
        JSR  CHECK_PRIME   ; Check if the number is prime
        JSR  resultS       ; Display the corresponding message
        BR   LOOP          ; Repeat indefinitely
        HALT               ; Halt (should never be reached)

;------------------------------------------------------------
; Function: readS
; Description: Reads a 2-digit number from the keyboard.
;              Converts two ASCII digits into a numeric value.
; Output: R0 contains the resulting integer.
readS
        ; Save registers
        ADD R4, R7, #0
        JSR PUSH
        ADD R4, R2, #0
        JSR PUSH
        ADD R4, R1, #0
        JSR PUSH
        ; Prompt for input
        LEA  R0, STRING
        PUTS

        ; Read first digit
        GETC               ; Read character from keyboard 
        OUT                ; Print to screen
        LD   R1, NEG48     ; Load constant -48 (to convert ASCII)
        ADD  R0, R0, R1    ; Convert ASCII to numeric digit
        ST   R0, DIG1      ; Store first digit

        ; Read second digit
        GETC               ; Read character from keyboard 
        OUT                ; Print to screen
        ADD  R0, R0, R1    ; Convert ASCII to numeric digit
        ST   R0, DIG2      ; Store second digit

        ; Combine digits into a 2-digit number
        LD   R0, DIG1      ; Load first digit
        AND  R1, R1, #0    ; Clear R1
        AND  R2, R2, #0    ; Clear R2

        ADD  R1, R0, R0    ; R1 = first digit * 2
        ADD  R2, R1, R1    ; R2 = first digit * 4
        ADD  R2, R2, R2    ; R2 = first digit * 8
        ADD  R2, R2, R1    ; R2 = first digit * 10

        LD   R0, DIG2      ; Load second digit
        ADD  R0, R2, R0    ; Result = (10 * first digit) + second digit
        ADD R4, R7, #0

        ; Restore registers
        JSR POP
        ADD R1, R4, #0
        JSR POP
        ADD R2, R4, #0
        JSR POP
        ADD R7, R4, #0

        RET

;------------------------------------------------------------
; Function: resultS
; Description: Displays the prime/non-prime message.
; Input: R0 (prime check result: non-zero means prime)
resultS
        ADD R0, R0, #0
        BRz  NOTPRIME      ; Branch if result is zero (not prime)

        LEA  R0, PRIME     ; Load "prime" message address
        PUTS
        RET

NOTPRIME
        LEA  R0, NPRIME    ; Load "not prime" message address
        PUTS
        RET

;------------------------------------------------------------
; Function: CHECK_PRIME
; Description: Checks if the number in R0 is prime.
;              Returns 1 in R0 if prime, 0 otherwise.
; Input: R0 (number to check)
CHECK_PRIME
    ADD R0, R0, #-2        ; Subtract 2 from the input number
    BRz IS_PRIME_EARLY_RETURN ; If the number is 2, return 1 (prime)
    ADD R0, R0, #2         ; Restore original value if not 2

    ; Save registers on the stack (since JSR modifies R7)
    ADD R4, R7, #0         ; Save return address (R7)
    JSR PUSH
    ADD R4, R1, #0         ; Save R1
    JSR PUSH
    ADD R4, R2, #0         ; Save R2
    JSR PUSH
    ADD R4, R3, #0         ; Save R3
    JSR PUSH

    ; Initialize divisor to 2
    AND R1, R1, #0
    ADD R1, R1, #2         ; R1 = 2

CHECK_LOOP
    JSR SQUARE             ; Compute divisor^2
    NOT R2, R2             ; Negate result for comparison
    ADD R2, R2, #1         ; Two's complement (negate)
    ADD R2, R2, R0         ; Check if divisor^2 > number
    BRn IS_PRIME           ; If divisor^2 > number, stop checking

    JSR MODULO             ; Check if number is divisible by divisor
    ADD R3, R3, #0         ; Check if remainder is zero
    BRz NOT_PRIME          ; If remainder is zero, the number is not prime

    ADD R1, R1, #1         ; Increment divisor
    BR CHECK_LOOP          ; Repeat process with next divisor

IS_PRIME
    AND R0, R0, #0         ; Set R0 to 1 (indicating prime)
    ADD R0, R0, #1
    BR RESTORE_REGS        ; Restore registers and return

NOT_PRIME
    AND R0, R0, #0         ; Set R0 to 0 (indicating not prime)
    BR RESTORE_REGS        ; Restore registers and return

IS_PRIME_EARLY_RETURN
    AND R0, R0, #0         ; Set R0 to 1 (indicating prime)
    ADD R0, R0, #1
    RET                    ; Return immediately

RESTORE_REGS
    JSR POP                ; Restore R3
    ADD R3, R4, #0

    JSR POP                ; Restore R2
    ADD R2, R4, #0

    JSR POP                ; Restore R1
    ADD R1, R4, #0

    JSR POP                ; Restore return address (R7)
    ADD R7, R4, #0
    RET                    ; Return to caller

;---------------------------
; SQUARE - Computes square of R1 (R1 * R1)
; Input:  R1 (number to square)
; Output: R2 (result of squaring R1)
; Uses:   R0 (loop counter), R4 (temporary storage)
SQUARE
    ; Save registers before computation
    ADD R4, R7, #0
    JSR PUSH
    ADD R4, R0, #0
    JSR PUSH
    ADD R4, R1, #0
    JSR PUSH

    ADD R0, R1, #0        ; Copy R1 into R0 as loop counter
    AND R2, R2, #0        ; Initialize result (R2) to 0

SQUARE_LOOP    
    ADD R2, R2, R1        ; Add R1 to sum
    ADD R0, R0, #-1       ; Decrease counter
    BRp SQUARE_LOOP       ; Loop until R0 reaches zero

    ; Restore registers after computation
    JSR POP
    ADD R1, R4, #0
    JSR POP
    ADD R0, R4, #0
    JSR POP
    ADD R7, R4, #0
    RET                    ; Return to caller

;---------------------------
; MODULO - Computes R0 % R1 (remainder after division)
; Input:  R0 (dividend), R1 (divisor)
; Output: R3 (remainder)
; Uses:   R4 (temporary storage)
MODULO
    ; Save registers
    ADD R4, R7, #0
    JSR PUSH
    ADD R4, R0, #0
    JSR PUSH
    ADD R4, R1, #0
    JSR PUSH

    AND R3, R3, #0        ; Initialize remainder to 0
    NOT R1, R1            ; Compute -R1 (two's complement)
    ADD R1, R1, #1

MOD_LOOP
    ADD R0, R0, R1        ; Subtract divisor from dividend
    BRn END_MOD           ; If negative, stop
    ADD R3, R0, #0        ; Store remainder
    BR MOD_LOOP           ; Repeat

END_MOD
    ; Restore registers
    JSR POP
    ADD R1, R4, #0
    JSR POP
    ADD R0, R4, #0
    JSR POP
    ADD R7, R4, #0
    RET                    ; Return remainder in R3

;------------------------------------------------------------
; Function: PUSH
; Description: Pushes the contents of R4 onto the stack.
PUSH
        ADD  R6, R6, #-1   ; Decrement SP
        STR  R4, R6, #0    ; Store R4 on stack
        RET

;------------------------------------------------------------
; Function: POP
; Description: Pops a value from the stack into R4.
POP
        LDR  R4, R6, #0    ; Load value from stack into R4
        ADD  R6, R6, #1    ; Increment SP
        RET

;------------------------------------------------------------
; Data Section
STACK_START .FILL x4000          ; Initial stack pointer address
MAX         .FILL xC005
EMPTY       .FILL x4000
PRIME       .STRINGZ "\nThe number is prime\n"
NPRIME      .STRINGZ "\nThe number is not prime\n"
NUM         .FILL 0             ; (Optional test number)
STRING      .STRINGZ "Input a 2 digit decimal number: "
DIG1        .BLKW 1
DIG2        .BLKW 1
NEG48       .FILL -48           ; Constant for ASCII conversion

        .END
