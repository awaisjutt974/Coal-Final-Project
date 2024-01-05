.include "m328pdef.inc"
.include "delay.inc"
.include "UART.inc"
.include "LCD_1602.inc"

.def LCD = r16
.def BACKLIGHT = r17
.def MODE = r19

.org 0x00
	LCD_init			; initilize the 16x2 LCD
	LCD_backlight_ON	; Turn On the LCD Backlight

	
	Serial_begin ; initilize UART serial communication

	ldi LCD, 0b00000001
	; if LCD[0] == 1
	; then fourPrints
	; if LCD[1] == 1
	; then blinkingDisplay
	ldi BACKLIGHT, 0xFF
	; if BACKLIGHT == 0xFF
	; then Backlight is ON
	; if BACKLIGHT == 0x00
	; then Backlight is OFF
	ldi MODE, 0x00
	; if MODE == 0x00
	; then LCD Mode
	; if MODE == 0xFF
	; then FireBase Mode

loop:
	call getSerialData
	cpi MODE, 0xFF
	breq loop
	cpi LCD, 0x00
	breq loop
	SBRC LCD, 0
		call fourPrints
	SBRC LCD, 1
		call blinkingDisplay
rjmp loop

getSerialData:
	Serial_read
	cpi r20, '1'
	breq buttonOne
	cpi r20, '2'
	breq buttonTwo
	cpi r20, '3'
	breq jmpButtonThree
	cpi r20, '4'
	breq jmpButtonFour
	cpi r20, '5'
	breq jmpButtonFive
	endGetSerialData:
	ret

jmpButtonThree:
	rjmp buttonThree		

jmpButtonFour:
	rjmp buttonFour

jmpButtonFive:
	rjmp buttonFive

buttonOne:
	ldi LCD, 0b00000001
	rjmp endGetSerialData

buttonTwo:
	cpi MODE, 0xFF
	breq endGetSerialData
	ldi LCD, 0x00
	LCD_Clear
	rjmp endGetSerialData

buttonThree:
	ldi LCD, 0b00000010
	rjmp endGetSerialData

buttonFour:
	cpi MODE, 0xFF
	breq buttonFourEnd
	cpi BACKLIGHT, 0xFF
	breq backLight_OFF
	LCD_backlight_ON
	ldi BACKLIGHT, 0xFF
	rjmp buttonFourEnd
	backLight_OFF:
		LCD_backlight_OFF
		ldi BACKLIGHT, 0x00
buttonFourEnd:
	rjmp endGetSerialData

toFireBase:
	rjmp FireBase

buttonFive:
	cpi MODE, 0x00
	breq toFireBase
	ldi MODE, 0x00
	LCD_Clear
	rjmp endGetSerialData
	FireBase:
	ldi MODE, 0xFF
	LCD_backlight_ON
	LCD_Clear
	LDI ZL, LOW (2 * system_string)
	LDI ZH, HIGH (2 * system_string)
	LCD_send_a_string
	LCD_send_a_command 0xC0
	LDI ZL, LOW (2 * firebase_string)
	LDI ZH, HIGH (2 * firebase_string)
	LCD_send_a_string
	rjmp endGetSerialData

fourPrints:
	LCD_Clear
	LDI ZL, LOW (2 * hello_string)
	LDI ZH, HIGH (2 * hello_string)
	LCD_send_a_string
	LCD_send_a_command 0xC0
	LDI ZL, LOW (2 * world_string)
	LDI ZH, HIGH (2 * world_string)
	LCD_send_a_string
	delay 1000
	delay 1000
	delay 1000
	LCD_Clear
	LDI ZL, LOW (2 * coal_string)
	LDI ZH, HIGH (2 * coal_string)
	LCD_send_a_string
	LCD_send_a_command 0xC0
	LDI ZL, LOW (2 * project_string)
	LDI ZH, HIGH (2 * project_string)
	LCD_send_a_string
	delay 1000
	delay 1000
	delay 1000
	LCD_Clear
	LDI ZL, LOW (2 * controlling_string)
	LDI ZH, HIGH (2 * controlling_string)
	LCD_send_a_string
	LCD_send_a_command 0xC0
	LDI ZL, LOW (2 * character_string)
	LDI ZH, HIGH (2 * character_string)
	LCD_send_a_string
	delay 1000
	delay 1000
	delay 1000
	LCD_Clear
	LDI ZL, LOW (2 * by_string)
	LDI ZH, HIGH (2 * by_string)
	LCD_send_a_string
	LCD_send_a_command 0xC0
	LDI ZL, LOW (2 * hamza_string)
	LDI ZH, HIGH (2 * hamza_string)
	LCD_send_a_string
	delay 1000
	delay 1000
	delay 1000
	ret

blinkingDisplay:
	LCD_Clear
	LDI ZL, LOW (2 * avr_string)
	LDI ZH, HIGH (2 * avr_string)
	LCD_send_a_string
	LCD_send_a_command 0xC0
	LDI ZL, LOW (2 * sir_string)
	LDI ZH, HIGH (2 * sir_string)
	LCD_send_a_string
	delay 300
	ret



hello_string:		.db	"      Hello     ", 0
world_string:		.db	"      World     ", 0
coal_string:		.db	"     COAL LAB   ", 0
project_string:		.db	"     Project    ", 0
controlling_string: .db	"   Controlling  ", 0
character_string:	.db	"    Character   ", 0
by_string:			.db	"  Presented By: ", 0
hamza_string:		.db	"   Ameer Hamza  ", 0
avr_string:			.db "  AVR Assembly  ", 0
sir_string:			.db "  Sir. Tehseen  ", 0
system_string:		.db "    System On   ", 0
firebase_string:	.db "  FireBase Mode ", 0
