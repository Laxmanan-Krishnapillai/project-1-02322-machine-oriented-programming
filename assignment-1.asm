.ORIG x3000
    LD R0, A       ; Load A into R0
    LD R1, B       ; Load B into R1
  
    NOT R2, R0
    ADD R2, R2, #1
X   
    AND R2, R2, R1 
    BRz DONE
    ADD R1, R1, #-1 ;
    ADD R0, R0, #1
    BRnzp X          ; If B > 0, repeat loop
DONE    ST R1, C       ; Store result in C
    TRAP x25       ; Halt program

; A   .BLKW 1
; B   .BLKW 1
C   .BLKW 1
A   .FILL #2
B   .FILL #8
.END
