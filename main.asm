;
; FinalProjectASM.asm
;
; Created: 12/1/2021 1:09:39 PM
; Author : NoahA
;


;REGISTER INFO:
;R22-R31 are designated for LED array data
;R16 is for location
;R17-R21 is general purpose

	.DEF location = R16

; initialize constants
	.EQU latchpin0 = 7	;Port D
	.EQU clockpin0 = 6
	.EQU datapin0 = 5	
	
	.EQU latchpin1 = 2	;Port B
	.EQU clockpin1 = 1
	.EQU datapin1 = 0	

	.EQU latchpin2 = 5	;Port B
	.EQU clockpin2 = 4
	.EQU datapin2 = 3

	.EQU locpin = 2		;Port D
	.EQU colorpin = 3
	.EQU keypin = 4





;setup io pins
	sbi DDRB, latchpin2		;PB5 is output
	sbi DDRB, clockpin2		;PB4 is output
	sbi DDRB, datapin2		;PB3 is output

	sbi DDRB, latchpin1		;PB2 is output
	sbi DDRB, clockpin1		;PB1 is output
	sbi DDRB, datapin1		;PB0 is output

	sbi DDRD, latchpin0		;PD7 is output
	sbi DDRD, clockpin0		;PD6 is output
	sbi DDRD, datapin0		;PD5 is output

	cbi DDRD, locpin		;PD2 is input
	cbi DDRD, colorpin		;PD3 is input
	cbi DDRD, keypin		;PD4 is input

;initialize shift registers


	LDI R22, 0b10010010
	LDI R23, 0b01001000

	LDI R24, 0b01001001
	LDI R25, 0b00100100

	LDI R26, 0b00100100
	LDI R27, 0b10010010	

	LDI R28, 0b01001001
	LDI R29, 0b00100100	

	LDI R30, 0b10010010
	LDI R31, 0b01001000	

	/*

	LDI R22, 0b00000000
	LDI R23, 0b00000000

	LDI R24, 0b00000000
	LDI R25, 0b00000000

	LDI R26, 0b00000000
	LDI R27, 0b00000000	

	LDI R28, 0b00000000
	LDI R29, 0b00000000	

	LDI R30, 0b00000000
	LDI R31, 0b00000000	
	*/



	rcall display

	ldi location, 1

start:

	SBIC PIND, locpin
	rjmp debounceLocButton

	SBIC PIND, keypin
	rjmp debounceKeyButton

	SBIC PIND, colorpin
	rjmp debounceColorButton
	 
rjmp start



debounceLocButton:
		ldi r18, 0				;load register 17 with 0

		rcall delay				;100ms delay
	
deb1:	SBIS PIND, locpin		;check if button is low
		rjmp start				;if button is not pressed go to mainloop

		inc r18					;if button is pressed inc counter
		cpi r18, 4				;button was pressed 4 times in a row
		brne locT1				;go to timer
		rjmp deb1				;else go to deb1

locT1:
		SBIS PIND, locpin		;check if button is low
		rjmp locButtonPressed	;if button is not pressed exit loop

		rjmp locT1					;if button was pressed go to t1


debounceKeyButton:
		ldi r18, 0				;load register 17 with 0

		rcall delay				;100ms delay
	
deb2:	SBIS PIND, keypin		;check if button is low
		rjmp start				;if button is not pressed go to mainloop

		inc r18					;if button is pressed inc counter
		cpi r18, 4				;button was pressed 4 times in a row
		brne keyT1				;go to timer
		rjmp deb2				;else go to deb1

keyT1:
		SBIS PIND, keypin		;check if button is low
		rjmp keyButtonPressed	;if button is not pressed exit loop

		rjmp keyT1					;if button was pressed go to t1

debounceColorButton:
		ldi r18, 0				;load register 17 with 0

		rcall delay				;100ms delay
	
deb3:	SBIS PIND, colorpin		;check if button is low
		rjmp start				;if button is not pressed go to mainloop

		inc r18					;if button is pressed inc counter
		cpi r18, 4				;button was pressed 4 times in a row
		brne colorButtonPressed	;go to colorbutton func
		rjmp deb3				;else go to deb1

locButtonPressed:
	
	cpi location, 25
	breq locMax

	inc location
	rjmp start

locMax:

	ldi location, 1

rjmp start


keyButtonPressed:
	CPI R22, 0b10010010
	BRNE wrongKey
	CPI R23, 0b01001000
	BRNE wrongKey

	CPI R24, 0b01001001
	BRNE wrongKey
	CPI R25, 0b00100100
	BRNE wrongKey

	CPI R26, 0b00100100
	BRNE wrongKey
	CPI R27, 0b10010010	
	BRNE wrongKey

	CPI R28, 0b01001001
	BRNE wrongKey
	CPI R29, 0b00100100	
	BRNE wrongKey

	CPI R30, 0b10010010
	BRNE wrongKey
	CPI R31, 0b01001000	
	BRNE wrongKey

	SBR R23, 0b00000001
	rcall display
	rjmp start

wrongKey:
	CBR R23, 0b00000001
	rcall display
	rjmp start
		
rjmp start


colorButtonPressed:

loc1:
cpi location, 1
brne loc2

	MOV R17, R23
	ANDI R17, 0b11100000

	cpi R17, 0b10000000
	breq loc1r

	cpi r17, 0b01000000
	breq loc1g

	cpi r17, 0b00100000
	breq loc1b



	loc1r:
		cbr R23, 0b11100000
		sbr R23, 0b01000000

		rcall display
		rjmp start

	loc1g:
		cbr R23, 0b11100000
		sbr R23, 0b00100000

		rcall display
		rjmp start

	loc1b:
		cbr R23, 0b11100000
		sbr R23, 0b10000000

		rcall display
		rjmp start


loc2:
cpi location, 2
brne loc3

	MOV R17, R23
	ANDI R17, 0b00011100

	cpi R17, 0b00010000
	breq loc2r

	cpi r17, 0b00001000
	breq loc2g

	cpi r17, 0b00000100
	breq loc2b

	loc2r:
		cbr R23, 0b00011100
		sbr R23, 0b00001000

		rcall display
		rjmp start

	loc2g:
		cbr R23, 0b00011100
		sbr R23, 0b00000100

		rcall display
		rjmp start

	loc2b:
		cbr R23, 0b00011100
		sbr R23, 0b00010000

		rcall display
		rjmp start


loc3:
cpi location, 3
brne loc4

	MOV R17, R22
	MOV R18, R23
	ANDI R17, 0b11000000
	ANDI R18, 0b00000010

	cpi R18, 0b00000010
	breq loc3r

	CPI R17, 0b10000000
	breq loc3g

	cpi r17, 0b01000000
	breq loc3b

	loc3r:
		CBR R23, 0b00000010
		SBR R22, 0b10000000
		
		rcall display
		rjmp start

	loc3g:
		CBR R22, 0b10000000
		SBR R22, 0b01000000

		rcall display
		rjmp start

	loc3b:
		CBR R22, 0b01000000
		SBR R23, 0b00000010

		rcall display
		rjmp start

	
loc4:
cpi location, 4
brne loc5

	MOV R17, R22
	ANDI R17, 0b00111000

	cpi R17, 0b00100000
	breq loc4r

	cpi r17, 0b00010000
	breq loc4g

	cpi r17, 0b00001000
	breq loc4b

	loc4r:
		cbr R22, 0b00111000
		sbr R22, 0b00010000

		rcall display
		rjmp start

	loc4g:
		cbr R22, 0b00111000
		sbr R22, 0b00001000

		rcall display
		rjmp start

	loc4b:
		cbr R22, 0b00111000
		sbr R22, 0b00100000

		rcall display
		rjmp start



loc5:
cpi location, 5
brne loc6

	MOV R17, R22
	ANDI R17, 0b00000111

	cpi R17, 0b00000100
	breq loc5r

	cpi r17, 0b00000010
	breq loc5g

	cpi r17, 0b00000001
	breq loc5b

	loc5r:
		cbr R22, 0b00000111
		sbr R22, 0b00000010

		rcall display
		rjmp start

	loc5g:
		cbr R22, 0b00000111
		sbr R22, 0b00000001

		rcall display
		rjmp start

	loc5b:
		cbr R22, 0b00000111
		sbr R22, 0b00000100

		rcall display
		rjmp start

loc6:
cpi location, 6
brne loc7

	MOV R17, R25
	ANDI R17, 0b11100000

	cpi R17, 0b10000000
	breq loc6r

	cpi r17, 0b01000000
	breq loc6g

	cpi r17, 0b00100000
	breq loc6b

	loc6r:
		cbr R25, 0b11100000
		sbr R25, 0b01000000

		rcall display
		rjmp start

	loc6g:
		cbr R25, 0b11100000
		sbr R25, 0b00100000

		rcall display
		rjmp start

	loc6b:
		cbr R25, 0b11100000
		sbr R25, 0b10000000

		rcall display
		rjmp start

loc7:
cpi location, 7
brne loc8

	MOV R17, R25
	ANDI R17, 0b00011100

	cpi R17, 0b00010000
	breq loc7r

	cpi r17, 0b00001000
	breq loc7g

	cpi r17, 0b00000100
	breq loc7b

	loc7r:
		cbr R25, 0b00011100
		sbr R25, 0b00001000

		rcall display
		rjmp start

	loc7g:
		cbr R25, 0b00011100
		sbr R25, 0b00000100

		rcall display
		rjmp start

	loc7b:
		cbr R25, 0b00011100
		sbr R25, 0b00010000

		rcall display
		rjmp start


loc8:
cpi location, 8
brne loc9

	MOV R17, R24
	MOV R18, R25
	ANDI R17, 0b11000000
	ANDI R18, 0b00000010

	cpi R18, 0b00000010
	breq loc8r

	CPI R17, 0b10000000
	breq loc8g

	cpi r17, 0b01000000
	breq loc8b

	loc8r:
		CBR R25, 0b00000010
		SBR R24, 0b10000000
		
		rcall display
		rjmp start

	loc8g:
		CBR R24, 0b10000000
		SBR R24, 0b01000000

		rcall display
		rjmp start

	loc8b:
		CBR R24, 0b01000000
		SBR R25, 0b00000010

		rcall display
		rjmp start

loc9:
cpi location, 9
brne loc10

	MOV R17, R24
	ANDI R17, 0b00111000

	cpi R17, 0b00100000
	breq loc9r

	cpi r17, 0b00010000
	breq loc9g

	cpi r17, 0b00001000
	breq loc9b

	loc9r:
		cbr R24, 0b00111000
		sbr R24, 0b00010000

		rcall display
		rjmp start

	loc9g:
		cbr R24, 0b00111000
		sbr R24, 0b00001000

		rcall display
		rjmp start

	loc9b:
		cbr R24, 0b00111000
		sbr R24, 0b00100000

		rcall display
		rjmp start

loc10:
cpi location, 10
brne loc11

	MOV R17, R24
	ANDI R17, 0b00000111

	cpi R17, 0b00000100
	breq loc10r

	cpi r17, 0b00000010
	breq loc10g

	cpi r17, 0b00000001
	breq loc10b

	loc10r:
		cbr R24, 0b00000111
		sbr R24, 0b00000010

		rcall display
		rjmp start

	loc10g:
		cbr R24, 0b00000111
		sbr R24, 0b00000001

		rcall display
		rjmp start

	loc10b:
		cbr R24, 0b00000111
		sbr R24, 0b00000100

		rcall display
		rjmp start

loc11:
cpi location, 11
brne loc12

	MOV R17, R27
	ANDI R17, 0b11100000

	cpi R17, 0b10000000
	breq loc11r

	cpi r17, 0b01000000
	breq loc11g

	cpi r17, 0b00100000
	breq loc11b

	loc11r:
		cbr R27, 0b11100000
		sbr R27, 0b01000000

		rcall display
		rjmp start

	loc11g:
		cbr R27, 0b11100000
		sbr R27, 0b00100000

		rcall display
		rjmp start

	loc11b:
		cbr R27, 0b11100000
		sbr R27, 0b10000000

		rcall display
		rjmp start

loc12:
cpi location, 12
brne loc13

	MOV R17, R27
	ANDI R17, 0b00011100

	cpi R17, 0b00010000
	breq loc12r

	cpi r17, 0b00001000
	breq loc12g

	cpi r17, 0b00000100
	breq loc12b

	loc12r:
		cbr R27, 0b00011100
		sbr R27, 0b00001000

		rcall display
		rjmp start

	loc12g:
		cbr R27, 0b00011100
		sbr R27, 0b00000100

		rcall display
		rjmp start

	loc12b:
		cbr R27, 0b00011100
		sbr R27, 0b00010000

		rcall display
		rjmp start

loc13:
cpi location, 13
brne loc14

	MOV R17, R26
	MOV R18, R27
	ANDI R17, 0b11000000
	ANDI R18, 0b00000010

	cpi R18, 0b00000010
	breq loc13r

	CPI R17, 0b10000000
	breq loc13g

	cpi r17, 0b01000000
	breq loc13b

	loc13r:
		CBR R27, 0b00000010
		SBR R26, 0b10000000
		
		rcall display
		rjmp start

	loc13g:
		CBR R26, 0b10000000
		SBR R26, 0b01000000

		rcall display
		rjmp start

	loc13b:
		CBR R26, 0b01000000
		SBR R27, 0b00000010

		rcall display
		rjmp start

loc14:
cpi location, 14
brne loc15

	MOV R17, R26
	ANDI R17, 0b00111000

	cpi R17, 0b00100000
	breq loc14r

	cpi r17, 0b00010000
	breq loc14g

	cpi r17, 0b00001000
	breq loc14b

	loc14r:
		cbr R26, 0b00111000
		sbr R26, 0b00010000

		rcall display
		rjmp start

	loc14g:
		cbr R26, 0b00111000
		sbr R26, 0b00001000

		rcall display
		rjmp start

	loc14b:
		cbr R26, 0b00111000
		sbr R26, 0b00100000

		rcall display
		rjmp start

loc15:
cpi location, 15
brne loc16

	MOV R17, R26
	ANDI R17, 0b00000111

	cpi R17, 0b00000100
	breq loc15r

	cpi r17, 0b00000010
	breq loc15g

	cpi r17, 0b00000001
	breq loc15b

	loc15r:
		cbr R26, 0b00000111
		sbr R26, 0b00000010

		rcall display
		rjmp start

	loc15g:
		cbr R26, 0b00000111
		sbr R26, 0b00000001

		rcall display
		rjmp start

	loc15b:
		cbr R26, 0b00000111
		sbr R26, 0b00000100

		rcall display
		rjmp start

loc16:
cpi location, 16
brne loc17

	MOV R17, R29
	ANDI R17, 0b11100000

	cpi R17, 0b10000000
	breq loc16r

	cpi r17, 0b01000000
	breq loc16g

	cpi r17, 0b00100000
	breq loc16b

	loc16r:
		cbr R29, 0b11100000
		sbr R29, 0b01000000

		rcall display
		rjmp start

	loc16g:
		cbr R29, 0b11100000
		sbr R29, 0b00100000

		rcall display
		rjmp start

	loc16b:
		cbr R29, 0b11100000
		sbr R29, 0b10000000

		rcall display
		rjmp start

loc17:
cpi location, 17
brne loc18

	MOV R17, R29
	ANDI R17, 0b00011100

	cpi R17, 0b00010000
	breq loc17r

	cpi r17, 0b00001000
	breq loc17g

	cpi r17, 0b00000100
	breq loc17b

	loc17r:
		cbr R29, 0b00011100
		sbr R29, 0b00001000

		rcall display
		rjmp start

	loc17g:
		cbr R29, 0b00011100
		sbr R29, 0b00000100

		rcall display
		rjmp start

	loc17b:
		cbr R29, 0b00011100
		sbr R29, 0b00010000

		rcall display
		rjmp start

loc18:
cpi location, 18
brne loc19

	MOV R17, R28
	MOV R18, R29
	ANDI R17, 0b11000000
	ANDI R18, 0b00000010

	cpi R18, 0b00000010
	breq loc18r

	CPI R17, 0b10000000
	breq loc18g

	cpi r17, 0b01000000
	breq loc18b

	loc18r:
		CBR R29, 0b00000010
		SBR R28, 0b10000000
		
		rcall display
		rjmp start

	loc18g:
		CBR R28, 0b10000000
		SBR R28, 0b01000000

		rcall display
		rjmp start

	loc18b:
		CBR R28, 0b01000000
		SBR R29, 0b00000010

		rcall display
		rjmp start

loc19:
cpi location, 19
brne loc20

	MOV R17, R28
	ANDI R17, 0b00111000

	cpi R17, 0b00100000
	breq loc19r

	cpi r17, 0b00010000
	breq loc19g

	cpi r17, 0b00001000
	breq loc19b

	loc19r:
		cbr R28, 0b00111000
		sbr R28, 0b00010000

		rcall display
		rjmp start

	loc19g:
		cbr R28, 0b00111000
		sbr R28, 0b00001000

		rcall display
		rjmp start

	loc19b:
		cbr R28, 0b00111000
		sbr R28, 0b00100000

		rcall display
		rjmp start

loc20:
cpi location, 20
brne loc21

	MOV R17, R28
	ANDI R17, 0b00000111

	cpi R17, 0b00000100
	breq loc20r

	cpi r17, 0b00000010
	breq loc20g

	cpi r17, 0b00000001
	breq loc20b

	loc20r:
		cbr R28, 0b00000111
		sbr R28, 0b00000010

		rcall display
		rjmp start

	loc20g:
		cbr R28, 0b00000111
		sbr R28, 0b00000001

		rcall display
		rjmp start

	loc20b:
		cbr R28, 0b00000111
		sbr R28, 0b00000100

		rcall display
		rjmp start



loc21:
cpi location, 21
brne loc22

	MOV R17, R31
	ANDI R17, 0b11100000

	cpi R17, 0b10000000
	breq loc21r

	cpi r17, 0b01000000
	breq loc21g

	cpi r17, 0b00100000
	breq loc21b

	loc21r:
		cbr R31, 0b11100000
		sbr R31, 0b01000000

		rcall display
		rjmp start

	loc21g:
		cbr R31, 0b11100000
		sbr R31, 0b00100000

		rcall display
		rjmp start

	loc21b:
		cbr R31, 0b11100000
		sbr R31, 0b10000000

		rcall display
		rjmp start

loc22:
cpi location, 22
brne loc23

	MOV R17, R31
	ANDI R17, 0b00011100

	cpi R17, 0b00010000
	breq loc22r

	cpi r17, 0b00001000
	breq loc22g

	cpi r17, 0b00000100
	breq loc22b

	loc22r:
		cbr R31, 0b00011100
		sbr R31, 0b00001000

		rcall display
		rjmp start

	loc22g:
		cbr R31, 0b00011100
		sbr R31, 0b00000100

		rcall display
		rjmp start

	loc22b:
		cbr R31, 0b00011100
		sbr R31, 0b00010000

		rcall display
		rjmp start

loc23:
cpi location, 23
brne loc24

	MOV R17, R30
	MOV R18, R31
	ANDI R17, 0b11000000
	ANDI R18, 0b00000010

	cpi R18, 0b00000010
	breq loc23r

	CPI R17, 0b10000000
	breq loc23g

	cpi r17, 0b01000000
	breq loc23b

	loc23r:
		CBR R31, 0b00000010
		SBR R30, 0b10000000
		
		rcall display
		rjmp start

	loc23g:
		CBR R30, 0b10000000
		SBR R30, 0b01000000

		rcall display
		rjmp start

	loc23b:
		CBR R30, 0b01000000
		SBR R31, 0b00000010

		rcall display
		rjmp start

loc24:
cpi location, 24
brne loc25

	MOV R17, R30
	ANDI R17, 0b00111000

	cpi R17, 0b00100000
	breq loc24r

	cpi r17, 0b00010000
	breq loc24g

	cpi r17, 0b00001000
	breq loc24b

	loc24r:
		cbr R30, 0b00111000
		sbr R30, 0b00010000

		rcall display
		rjmp start

	loc24g:
		cbr R30, 0b00111000
		sbr R30, 0b00001000

		rcall display
		rjmp start

	loc24b:
		cbr R30, 0b00111000
		sbr R30, 0b00100000

		rcall display
		rjmp start

loc25:

	MOV R17, R30
	ANDI R17, 0b00000111

	cpi R17, 0b00000100
	breq loc25r

	cpi r17, 0b00000010
	breq loc25g

	cpi r17, 0b00000001
	breq loc25b

	loc25r:
		cbr R30, 0b00000111
		sbr R30, 0b00000010

		rcall display
		rjmp start

	loc25g:
		cbr R30, 0b00000111
		sbr R30, 0b00000001

		rcall display
		rjmp start

	loc25b:
		cbr R30, 0b00000111
		sbr R30, 0b00000100

		rcall display
		rjmp start


	

rjmp start



display:	;R22 - R31 will be displayed, R22, R23 will be called to displayNumber0 and so on
	
	MOV R20, R22
	rcall displayNumber0
	MOV R20, R23
	rcall displayNumber0

	MOV R20, R24
	rcall displayNumber1
	MOV R20, R25
	rcall displayNumber1
	MOV R20, R26
	rcall displayNumber1
	MOV R20, R27
	rcall displayNumber1

	MOV R20, R28
	rcall displayNumber2
	MOV R20, R29
	rcall displayNumber2
	MOV R20, R30
	rcall displayNumber2
	MOV R20, R31
	rcall displayNumber2


ret 
	


;display the number in the R20 register to row 1, must be called twice
;r20 is data r18 is counter
displayNumber0:

	LDI R18, 8

loop0:
	rol R20
	brcs s01
	cbi PORTD, datapin0
	rjmp s02
s01: sbi PORTD, datapin0
s02: sbi PORTD, clockpin0
	cbi PORTD, clockpin0

	dec R18
	cpi R18, 0
	brne loop0

	sbi PORTD, latchpin0
	cbi PORTD, latchpin0

	ret

;display the number in the R20 register to row 2 & 3, must be called 4 times
;r20 is data r18 is counter
displayNumber1:

	LDI R18, 8

loop1:
	rol R20
	brcs s11
	cbi PORTB, datapin1
	rjmp s12
s11: sbi PORTB, datapin1
s12: sbi PORTB, clockpin1
	cbi PORTB, clockpin1

	dec R18
	cpi R18, 0
	brne loop1

	sbi PORTB, latchpin1
	cbi PORTB, latchpin1

	ret

;display the number in the R20 register to row 4 & 5, must be called 4 times
;r20 is data r18 is counter
displayNumber2:

	LDI R18, 8

loop2:
	rol R20
	brcs s21
	cbi PORTB, datapin2
	rjmp s22
s21: sbi PORTB, datapin2
s22: sbi PORTB, clockpin2
	cbi PORTB, clockpin2

	dec R18
	cpi R18, 0
	brne loop2

	sbi PORTB, latchpin2
	cbi PORTB, latchpin2

	ret


delay:
	ldi   r18,10      ; r18 <-- Counter for outer loop
d1: ldi   r19,255     ; r19 <-- Counter for level 2 loop
d2: ldi   r20,255     ; r20 <-- Counter for inner loop
d3: dec   r20
nop               ; no operation
brne  d3
dec   r19
brne  d2
dec   r18
brne  d1
ret

