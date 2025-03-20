    	.ORIG x3000     	; Set the starting address of the program to x3000
   	 
        ; Call the readS function
        JSR readS       ; Call the readS function, the result is in R0

    	HALT           	; Halt the program TRAP x25
        
        ; readS function
readS   
        ; Write message on the console
        LEA R0, STRING  ; Load adress of the string into R0
        PUTS        ; Call TRAP x22 to print the string in R0
        
        ; Read first digit
        GETC            ; Read character from keyboard 
        OUT             ; Print to screen
        LD R1, NEG48    ; Load -48 from memory
        ADD R0, R0, R1  ; Convert ASCII to numeric value by substracting 48
        ST R0, DIG1  ; Store R0 in 
        
        ; Read second digit
        GETC            ; Read character from keyboard 
        OUT             ; Print to screen
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

STRING  .STRINGZ "Input a 2 digit decimal number:" ; 
DIG1    .BLKW 1
DIG2    .BLKW 1
NEG48   .FILL -48   ; Store -48 in memory    	
    	.END


