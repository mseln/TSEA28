;; LAB2b
;; $7000 - stackpekare, d0 - delay, d2 - ball, d3,d4 - score,
;; d5 - direction, d6 - serve
start:
	move.l $7000,a7		;set stackpointer
	movem.l #0,d0-d7	;clear registers
	and.w $f8ff,SR		;set interruptlevel 0
	jsr setup-interrupt
	jsr setup-pia


setup-game:
	move.b #$ff,d6		;mark serve
setup-serve:
	cmp.b #0,d5
	bne left-serve
	move.b #1,d2		;right-serve
	bra game
left-serve:
	move.b #128,d2		;left-serve
game:
	jsr delay
	cmp.b #0,d6		;check not-serve?
	bne update-ball

move-ball:
	cmp.b #0,d5		;check direction
	bne move-right
	lsl.b #1,d2		;move ball left
	bra update-ball
move-right:
	lsr.b #1,d2		;move ball right
update-ball:
	move.b d2,$10080
	cmp.b #0,d2		;ball out-of-bounds?
	beq score
	bra game

score:
	cmp.b #0,d5		;check direction
	bne leftscore
	add.b #1,d4		;add 1 to right score
	bra setup-game
leftscore:
	add.b #1,d4		;add 1 to left score
	bra setup-game


setup-pia:
	move.b #0,$10084	;address DDRA
	move.b #$ff,$10080	;set port 0-7 for output - ballindicator
	move.b #5,$10084	;address PIAA and set CRA-7 for interrupt 
	move.b #0,$10086	;address DDRB
	;move.b #$ff,$10082	;set 0,1,2,3 as output
	move.b #5,$10086	;address PIAB and set CRB-7 for interrupt
	rts

setup-interrupt:
	LEA leftinterrupt,a1
	LEA rightinterrupt,a2
	move.l a1,$68
	move.l a2,$74
	rts 

leftinterrupt:
	tst.b $10082		;acknowledge lvl2 interrupt
	cmp.b #0,d6
	rte

rightinterrupt:
	tst.b $10080		;acknowledge lvl5 interrupt

	rte
