;****************************************************************
;* RUNTEST7.P8.S
;*
;* A ProDOS 8 program to run the built-in Apple IIGS ROM
;* diagnostic for the Real Time Clock (Test #7).
;*
;* This program starts in 8-bit emulation mode, switches to
;* 16-bit native mode to call the test, and then switches back.
;*
;* Assembled with Merlin32.
;****************************************************************

            ORG     $2000               ; ProDOS 8 programs start at $2000
            DSK     RUNTEST7.P8         ; Set the output filename
            TYP     'SYS'               ; Set ProDOS file type to SYS ($F1)
            MX      %11                 ; Default to 8-bit Accumulator and Index

;--- ProDOS 8 MLI (Machine Language Interface) Calls
MLI         EQU     $BF00               ; ProDOS MLI entry point
QUIT        EQU     $65                 ; MLI QUIT command code

;--- Zero Page Variables
PRINT_PTR   EQU     $06                 ; Zero page pointer for print routine (2 bytes)

;--- Monitor Routines
COUT        EQU     $FDED               ; 8-bit monitor character out routine

;--- ROM Diagnostic Constants (from the PDF document)
DIAG_TABLE  EQU     $FF7402             ; Start of the test pointer table in ROM
TST_STATUS  EQU     $0315               ; 5-byte status area for error codes
TEST_NUM    EQU     7                   ; We want to run Test #7 (Real Time Clock)

;****************************************************************
;* MAIN PROGRAM
;****************************************************************
START       
            ;--- Step 1: Clear the 5-byte test status area in memory.
            LDX     #4                  ; Loop counter for 5 bytes (4 down to 0)
CLEAR_LOOP  LDA     #0                  ; Load a zero
            STA     TST_STATUS,X        ; Store it in the status area
            DEX                         ; Decrement index
            BPL     CLEAR_LOOP          ; Loop until all 5 bytes are cleared

            ;--- Step 2: Calculate the address of the pointer for Test #7.
            LDA     #TEST_NUM           ; Load the test number (7)
            ASL A                       ; Multiply by 2 to get the byte offset
            TAX                         ; Transfer the offset to X-register
            LDA     DIAG_TABLE,X        ; Load the 16-bit pointer from the table
            STA     SCRATCH             ; Store it in a temporary location

            ;--- Step 3: Call the native mode diagnostic routine.
            JSR     CALL_NATIVE_TEST

            ;--- Step 4: Check the carry flag for the result.
            BCS     TEST_FAILED         ; Branch if Carry is Set (failure)

;--- Test Passed ---
TEST_PASSED
            LDA     #<MSG_PASS          ; Load low byte of message address
            STA     PRINT_PTR
            LDA     #>MSG_PASS          ; Load high byte of message address
            STA     PRINT_PTR+1
            JSR     PRINT_MSG           ; Print the message
            JMP     EXIT_PROG           ; Then exit

;--- Test Failed ---
TEST_FAILED
            LDA     #<MSG_FAIL          ; Load low byte of message address
            STA     PRINT_PTR
            LDA     #>MSG_FAIL          ; Load high byte of message address
            STA     PRINT_PTR+1
            JSR     PRINT_MSG           ; Print the message
            JMP     EXIT_PROG           ; Then exit


;****************************************************************
;* SUBROUTINES
;****************************************************************

;--- Switch to native mode, call test, switch back to emulation ---
CALL_NATIVE_TEST
            PHP                         ; Save processor status (including emulation bit)
            CLC
            XCE                         ; Switch to native 65816 mode
            
            SEP     #%00110000          ; Set M and X flags for 8-bit registers
            PHK                         ; Push current program bank to stack
            PLB                         ; Pull it into the Data Bank Register (DBR)
            
            ;--- JSL (addr) is not a valid addressing mode.
            ;--- We modify the JSL instruction below with the correct
            ;--- address before executing it.
            LDA     SCRATCH             ; Get low byte of target address
            STA     JSL_TARGET+1        ; Patch the low byte of the JSL instruction
            LDA     SCRATCH+1           ; Get high byte of target address
            STA     JSL_TARGET+2        ; Patch the high byte of the JSL instruction

JSL_TARGET  JSL $FF0000                 ; *** EXECUTE THE 16-BIT ROM TEST ***
                                        ; The $0000 part is patched at runtime.
            
            SEC
            XCE                         ; Switch back to 8-bit emulation mode
            PLP                         ; Restore original processor status
            RTS

;--- Print a null-terminated string using the 8-bit monitor COUT ---
;--- Uses (Indirect),Y addressing. Pointer is at PRINT_PTR.
PRINT_MSG
            LDY     #0                  ; Start Y index at 0
PRINT_LOOP  LDA     (PRINT_PTR),Y       ; Load character from string, indexed by Y
            BEQ     PRINT_DONE          ; If it's zero (null), we're done
            JSR     COUT                ; Print the character
            INY                         ; Increment index
            BRA     PRINT_LOOP          ; Loop
PRINT_DONE  RTS                         ; Return from subroutine

;--- Exit the program cleanly using the ProDOS 8 MLI ---
EXIT_PROG
            LDA     #QUIT               ; Load the QUIT command code
            JSR     MLI                 ; Call the Machine Language Interface
            ; Should not return from here
            BRK

;****************************************************************
;* DATA AREA
;****************************************************************
SCRATCH     DS      2                   ; Temporary storage for the routine's address

MSG_PASS    ASC     "Test 7 (Real Time Clock): PASS"
            ASC     $0D                 ; Carriage return
            HEX     00                  ; Null terminator for 8-bit print routine

MSG_FAIL    ASC     "Test 7 (Real Time Clock): FAIL"
            ASC     $0D                 ; Carriage return
            HEX     00                  ; Null terminator

            END

