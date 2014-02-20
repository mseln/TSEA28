;; LAB2b
;; $7000 - stackpekare, d0 - delay, d2 - ball, d3 - left
;; d4 - right
;; d5 - direction, d6 - serve
start:
	move.l $7000,a7		;set stackpointer
	movem.l #0,d0-d7	;clear registers
	jsr setup-interrupt
	jsr setup-pia
	and.w $f8ff,SR		;set interruptlevel 0

game-init:
	move.b #ff,d6		;mark serve
	move.b #1,d2		;ball at right edge

game:
	cmp.b #0,d2		;ball out-of-bounds?
	beq out-of-bound
	move.b 500,d0
	jsr delay
	jsr update-ball
	bra game
	
out-of-bound:
	jsr score
	bra game
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
update-ball:
	or.w #$700,SR		;block interrupts
	cmp.b #ff,d6		;serve?
	beq update-led
	cmp.b #0,d5		;check direction
	bne move-right
	lsl.b #1,d2		;move left
	bra update-led
move-right
	lsr.b #1,d2
update-led:
	move.b d2,$10080
	and.w #$f8ff,SR		;allow interrupts
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
score:
	or.w #$0700,SR		;block interrupts
	cmp.b #0,d5		;check direction
	beq score-right
score-left:
	or.w #$700,SR		;block interrupts
	add.b #1,d3		;add 1 to left score
	move.b #ff,d5		;direction right
	move.b #128,d2		;ball left-end
	bra score-done
score-right:
	or.w #$700,SR		;block interrupts
	add.b #1,d4
	move.b #0,d5		;direction left
	move.b #1,d2		;ball right-end
score-done:
	move.b #$ff,d6		;mark serve
	and.w #$f8ff,SR		;allow interrupts
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
delay:
	sub.b #1,d0
	cmp.b #0,d0
	bne delay
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setup-pia:
	move.b #0,$10084	;address DDRA
	move.b #$ff,$10080	;set port 0-7 for output - ballindicator
	move.b #5,$10084	;address PIAA and set CRA-7 for interrupt 
	move.b #0,$10086	;address DDRB
	;move.b #$ff,$10082	;set 0-7 as outputs
	move.b #5,$10086	;address PIAB and set CRB-7 for interrupt
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setup-interrupt:
	LEA leftinterrupt,a1
	LEA rightinterrupt,a2
	move.l a1,$68
	move.l a2,$74
	rts 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
leftinterrupt:
	tst.b $10082		;acknowledge lvl2 interrupt	
	cmp.b #128,d2		;ball at left edge?
	bne not-left-end	
	cmp.b #0,d6		;ball in-game?
	beq switch-right
	move.b #0,d6		;put ball in-game
	bra done-left
switch-right:
	neg.b d5		;change ball-direction
	bra done-left
not-left-end:
	cmp.b #ff,d6		;right-serve?
	beq done-left
	jsr score-right
done-left:
	rte
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
rightinterrupt:
	tst.b $10080		;acknowledge lvl5 interrupt
	cmp.b #1,d2		;ball at right edge?
	bne not-right-end
	cmp.b #0,d6		;ball in-game?
	beq switch-left
	move.b #0,d6		;put ball in-game
	bra done-right
switch-left:
	neg.b d5
	bra done-right
not-right-end:
	cmp.b #ff,d6		;left-serve?
	beq done-right		
	jsr score-left
done-right:
	rte
