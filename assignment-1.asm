        .ORIG x3000         ; Set the starting address of the program to x3000
        
    	LD R0, A   	        ; Load the value at memory location A into register R0
    	LD R1, B   	        ; Load the value at memory location B into register R1

     
X    	NOT R2, R0          ; A: Perform the bitwise NOT operation on the value in R0, store the result in R2
    	ADD, R2, R2, #1     ; B: Add 1 to R2 (this is equivalent to -R0)
   
    	ADD R2, R2, R1      ; Add the value in R1 (B) to R2, store the result back in R2
    	
    	BRz DONE            ; C: If the result in R2 is zero (i.e., R2 == 0), branch to the DONE label
    	
    	ADD R1, R1, #-1     ; Decrement R1 (subtract 1 from B)
    	
    	ADD R0, R0, #1      ; D: Increment R0
    	
    	BRnzp X      	    ; Branch to label X if the result of the previous operation is non-zero (positive or negative) 
DONE	ST R1, C   	        ; Store the value in R1 into memory location C
	    TRAP x25   	        ; Halt the program (TRAP x25 is the HALT instruction in LC-3)

A       .BLKW 1             ; Reserve one memory word for variable A
B       .BLKW 1             ; Reserve one memory word for variable B
C       .BLKW 1             ; Reserve one memory word for variable C, here we have the midpoint at the end of the program
        .END
