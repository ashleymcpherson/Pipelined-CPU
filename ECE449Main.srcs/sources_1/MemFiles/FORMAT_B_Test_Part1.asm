	ORG  0x0210
	
		IN R0 ; 02  ; This example tests how data dependencies are handled
		IN R1 ; 03  ; The values to be loaded into the corresponding resgister.
		IN R2 ; 01
		IN R3 ; 05  ;  End of initialization
		ADD R1, R1, R2 ;r1 = 3 + 1 = 4
		SUB R2, R1, R0 ;r2 = 4 - 2 = 2
		SUB R1, R3, R2 ;r1 = 5 - 2 = 3

	END
