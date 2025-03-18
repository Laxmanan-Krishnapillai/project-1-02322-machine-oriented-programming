    	.ORIG x3000     	; Set the starting address of the program to x3000
   	 
        ; Call the resultS function
        LD R0, NUM      ; Loads an integer into R0 which is the argument for the function
        JSR resultS      ; Call the resultS function

    	HALT           	; Halt the program TRAP x25
        
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
        

PRIME   .STRINGZ "The number is prime" ; Storing the string to output "The number is prime"
NPRIME  .STRINGZ "The number is not prime" ; Storing the string to output "The number is not prime"
NUM     .FILL 0         ; Store 2 in this case the argument. Used to test the function and can be changed.  	
    	
    	
    	.END


