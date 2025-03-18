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
        TRAP x23           ; Read character (echoed)
        LD   R1, NEG48     ; Load constant -48 (to convert ASCII)
        ADD  R0, R0, R1    ; Convert ASCII to numeric digit
        ST   R0, DIG1      ; Store first digit

        ; Read second digit
        TRAP x23           ; Read character (echoed)
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
        ; Special case: if number is 2, early return
        ADD  R0, R0, #-2
        BRz  IS_PRIME_EARLY_RETURN
        ADD  R0, R0, #2

        ; Save registers R7, R1, R2, R3 on the stack
        ADD  R4, R7, #0
        JSR  PUSH
        ADD  R4, R1, #0
        JSR  PUSH
        ADD  R4, R2, #0
        JSR  PUSH
        ADD  R4, R3, #0
        JSR  PUSH

        ; Initialize divisor to 2 in R1
        AND  R1, R1, #0
        ADD  R1, R1, #2

CHECK_LOOP
        JSR  SQUARE        ; Compute square of divisor (result in R2)
        ; Compare divisor^2 with N
        NOT  R2, R2
        ADD  R2, R2, #1
        ADD  R2, R2, R0   ; If (divisor^2 - N) is negative then divisor^2 <= N
        BRn  IS_PRIME     ; If so, no factor found yet: assume prime

        JSR  MODULO       ; Compute N modulo divisor (result in R3)
        ADD  R3, R3, #0   ; Check if remainder is zero
        BRz  NOT_PRIME    ; If yes, number is not prime

        ADD  R1, R1, #1   ; Increment divisor
        BR   CHECK_LOOP

IS_PRIME
        AND  R0, R0, #0
        ADD  R0, R0, #1   ; Set R0 = 1 (prime)
        BR   RESTORE_REGS

NOT_PRIME
        AND  R0, R0, #0   ; Set R0 = 0 (not prime)
        BR   RESTORE_REGS

IS_PRIME_EARLY_RETURN
        ; For number 2, set result as prime (or adjust as desired)
        AND  R0, R0, #0
        ADD  R0, R0, #0
        RET

RESTORE_REGS
        JSR  POP
        ADD  R3, R4, #0

        JSR  POP
        ADD  R2, R4, #0

        JSR  POP
        ADD  R1, R4, #0

        JSR  POP
        ADD  R7, R4, #0
        RET

;------------------------------------------------------------
; Function: SQUARE
; Description: Computes the square of R1 by repeated addition.
; Output: R2 contains R1 squared.
SQUARE
        ; Save registers R7, R0, R1 on the stack
        ADD  R4, R7, #0
        JSR  PUSH

        ADD  R4, R0, #0
        JSR  PUSH

        ADD  R4, R1, #0
        JSR  PUSH

        ; Compute square: initialize R0 = R1 and clear R2
        ADD  R0, R1, #0
        AND  R2, R2, #0

SQUARE_LOOP    
        ADD  R2, R2, R1   ; Sum R1 repeatedly
        ADD  R0, R0, #-1  ; Decrement counter
        BRp  SQUARE_LOOP

        ; Restore registers
        JSR  POP
        ADD  R1, R4, #0

        JSR  POP
        ADD  R0, R4, #0

        JSR  POP
        ADD  R7, R4, #0
        RET

;------------------------------------------------------------
; Function: MODULO
; Description: Computes the remainder of R0 divided by R1.
; Output: R3 contains the remainder.
MODULO
        ; Save registers R7, R0, R1 on the stack
        ADD  R4, R7, #0
        JSR  PUSH

        ADD  R4, R0, #0
        JSR  PUSH

        ADD  R4, R1, #0
        JSR  PUSH

        AND  R3, R3, #0   ; Clear R3 (remainder)

        ; Compute two's complement of R1 for subtraction
        NOT  R1, R1
        ADD  R1, R1, #1

MOD_LOOP
        ADD  R0, R0, R1  ; Subtract divisor from dividend
        BRn  END_MOD     ; If result negative, stop
        ADD  R3, R0, #0  ; Update remainder
        BR   MOD_LOOP

END_MOD
        ; Restore registers
        JSR  POP
        ADD  R1, R4, #0

        JSR  POP
        ADD  R0, R4, #0

        JSR  POP
        ADD  R7, R4, #0
        RET

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
PRIME       .STRINGZ "The number is prime\n"
NPRIME      .STRINGZ "The number is not prime\n"
NUM         .FILL 0             ; (Optional test number)
STRING      .STRINGZ "Input a 2 digit decimal number:"
DIG1        .BLKW 1
DIG2        .BLKW 1
NEG48       .FILL -48           ; Constant for ASCII conversion

        .END
