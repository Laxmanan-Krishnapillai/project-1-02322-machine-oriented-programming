.ORIG x3000

MAIN
    LD R0, PRIME ; Answer
    LD R1, DIVISOR
LOOP
    JSR MULTIPLY ; Multiply Divisor * Divisor
    NOT R2, R2
    ADD R2, R2, #1
    ADD R2, R2, R0 ; Check if Divisor^2 <= N
    BRn IS_PRIME
    JSR MODULO
    ADD R3, R3, #0
    BRz NOT_PRIME
    ADD R1, R1, #1
    BR LOOP
    JSR MULTIPLY

IS_PRIME
    AND R0, R0, #0
    ADD R0, R0, #1
    HALT
    .FILL x0000  ; Fills the next memory location with a harmless value
NOT_PRIME
    AND R0, R0, #0
    HALT
    .FILL x0000  ; Prevents accidental execution of garbage memory
    
; Multiplication
MULTIPLY
    ST R0, SAVE_R0
    ST R1, SAVE_R1
    ADD R0, R1, #0
    AND R2, R2, #0 ; Sum
MULT_LOOP    
    ADD R2, R2, R1
    ADD R0, R0, #-1
    BRp MULT_LOOP
    LD R0, SAVE_R0
    LD R1, SAVE_R1
    RET

MODULO
    ST R0, SAVE_R0 ; Quotient
    ST R1, SAVE_R1 ; Divisor
    AND R3, R3, #0 ; Remainder
    NOT R1, R1 ; 
    ADD R1, R1, #1 ; 2's complement
MOD_LOOP
    ADD R0, R0, R1
    BRn END_MOD
    ADD R3, R0, #0
    BR MOD_LOOP
END_MOD
    LD R0, SAVE_R0
    LD R1, SAVE_R1
    RET

PRIME .FILL #131
DIVISOR .FILL #2

SAVE_R0 .BLKW 1
SAVE_R1 .BLKW 1
.END