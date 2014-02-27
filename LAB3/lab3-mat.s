;;;;;;;;;;;;;;;;;;;;
; LAB3 - DIGITALUR ;
;;;;;;;;;;;;;;;;;;;;

START:
	move.l #$7000,a7	; initiera stack
	
	jsr PIAINIT		; initiera PIA


;;;;;;;;;;;;;;;;;;;;;;
PIAINIT:
	move.b #0,$10084	;adressera DDRA
	move.b #7F,$10080	;a0-a7 utgångar
