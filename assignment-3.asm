.ORIG x3000
MAIN
    LD R0, PRIME         ; Load the number to check from memory
    LD R6, STACK_START   ; Initialize stack pointer (x4000)
    JSR CHECK_PRIME      ; Call the CHECK_PRIME subroutine
    HALT                 ; Halt execution

;---------------------------
; CHECK_PRIME - Determines if a number is prime.
; Input:  R0 (number to check)
; Output: R0 = 1 if prime, 0 otherwise
; Uses:   R1 (divisor), R2 (temp for comparisons), R3 (temp for remainder)
;         R4 (temp storage for stack operations), R7 (return address)
CHECK_PRIME
    ADD R0, R0, #-2        ; Subtract 2 from the input number
    BRz IS_PRIME_EARLY_RETURN ; If the number is 2, return 1 (prime)
    BRn NOT_PRIME_EARLY_RETURN
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
NOT_PRIME_EARLY_RETURN      ; If the number is less than 2 return 1 (not Prime)
    AND R0, R0, #0
    RET
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

;---------------------------
; PUSH - Pushes value in R4 onto stack
; Uses:   R6 (stack pointer)
PUSH
    ADD R6, R6, #-1      ; Move stack pointer down
    STR R4, R6, #0       ; Store value at stack location
    RET

;---------------------------
; POP - Pops value from stack into R4
; Uses:   R6 (stack pointer)
POP
    LDR R4, R6, #0       ; Load top value from stack into R4
    ADD R6, R6, #1       ; Move stack pointer up
    RET

;---------------------------
; Constants and memory locations
STACK_START .FILL x4000  ; Stack base address
PRIME       .FILL #1  ; Number to check
.END
