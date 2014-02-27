; LAB3 - DIGITALUR
;;;;;;;;;;;;;;;;;;
; $900-903 tid - S S : M M
; a6 pekar pa SJUSEGTAB
; a5 pekar pa $900
START:
	move.l #$7000,a7	; init stack

	LEA SJUSEGTAB,a6	; point out SJUSEGTAB
	move.l #$900,a5
	move.l #$00,(a5)	; load time to $900-$903, SS:MM
	LEA BCD,a0
	move.l a0,$74		; BCD on interrupt lvl 5
	LEA MUX,a0
	move.l a0,$68		; MUX on interrupt lvl 2


	jsr PIAINIT		; init PIA
;;;;;;;;;;;;;;;;;
BCD:
	tst.b $10080		; acknowledge interrupt
	move.b $900,d0		; load time
	addq.b #1,d0
	cmp.b #10,d0
	blt done		; branch on less than 10
	move.b #0,$900		; 
	; ...
done:
	RTE
;;;;;;;;;;;;;;;;;
MUX:
	
	RTE
;;;;;;;;;;;;;;;;;
PIAINIT:
	move.b #0,$10084	; address DDRA
	move.b #$7F,$10080	; A0-A6 output
	move.b #7,$10084	; address PIAA, CA7 interrupt
	move.b #0,$10086	; address DDRB
	move.b #3,$10082	; B0-B1 outputs
	move.b #7,$10086	; address PIAB, CB7 interrupt
	rts
;;;;;;;;;;;;;;;;
SJUSEGTAB:
	dc.b	#$3F		; '0'
	dc.b	#$06		; '1'
	dc.b	#$5B		; '2'
	dc.b	#$4F		; '3'
	dc.b	#$66		; '4'
	dc.b	#$6C		; '5'
	dc.b	#$7C		; '6'
	dc.b	#$23		; '7'
	dc.b	#$7F		; '8'
	dc.b	#$6F		; '9'


