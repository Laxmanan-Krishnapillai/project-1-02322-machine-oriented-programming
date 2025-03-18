.ORIG x3000
MAIN
    LD R0, PRIME
    LD R6, STACK_START  ; Load initial stack pointer (x4000)
    JSR CHECK_PRIME
    HALT
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

PRIME .FILL #3571
.END

