;; LAB2b
;; $7000 - stackpekare, d0 - delay, d2 - ball, d3 - left
;; d4 - right
;; d5 - direction, d6 - serve
start:
	move.l #$7000,a7		;set stackpointer
	move.l #0,d0	;clear registers
	move.l #0,d1	;clear registers
	move.l #0,d2	;clear registers
	move.l #0,d3	;clear registers
	move.l #0,d4	;clear registers
	move.l #0,d5	;clear registers
	move.l #0,d6	;clear registers
	move.l #0,d7	;clear registers
	jsr setup_interrupt
	jsr setup_pia
	and.w #$f8ff,SR		;set interruptlevel 0

game_init:
	move.b #$ff,d6		;mark serve
	move.b #1,d2		;ball at right edge
    move.l #$8000,d7
game:
	cmp.b #0,d2		;ball out_of_bounds?
	beq out_of_bound
	move.l d7,d0		;delaytime
	jsr delay
	jsr update_ball
	bra game
	
out_of_bound:
	jsr score
	bra game
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
update_ball:
	or.w #$700,SR		;block interrupts
	cmp.b #$ff,d6		;serve?
	beq update_led
move_ball:
	cmp.b #0,d5		;check direction
	bne move_right
move_left:
	lsl.b #1,d2		;move left
	bra update_led
move_right
	lsr.b #1,d2
update_led:
	move.b d2,$10080
	and.w #$f8ff,SR		;allow interrupts
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
score:
	or.w #$0700,SR		;block interrupts
	cmp.b #0,d5		;check direction
	beq score_right
score_left:
	or.w #$700,SR		;block interrupts
	add.b #1,d3		;add 1 to left score
	move.b #$ff,d5		;set direction right
	move.b #128,d2		;ball at left_end
	bra score_done
score_right:
	or.w #$700,SR		;block interrupts
	add.b #1,d4
	move.b #0,d5		;set direction left
	move.b #1,d2		;ball at right_end
score_done:
	move.b #$ff,d6		;mark serve
	and.w #$f8ff,SR		;allow interrupts
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
delay:
	sub.l #1,d0
	cmp.l #0,d0
	bne delay
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setup_pia:
	move.b #0,$10084	;address DDRA
	move.b #$ff,$10080	;set port 0_7 for output _ ballindicator
	move.b #5,$10084	;address PIAA and set CRA_7 for interrupt 
	move.b #0,$10086	;address DDRB
	;move.b #$ff,$10082	;set 0_7 as outputs
	move.b #5,$10086	;address PIAB and set CRB_7 for interrupt
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setup_interrupt:
	LEA leftinterrupt,a1
	LEA rightinterrupt,a2
	move.l a1,$68
	move.l a2,$74
	rts 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
leftinterrupt:
	tst.b $10082		;acknowledge lvl2 interrupt	
	cmp.b #128,d2		;ball at left edge?
	bne not_left_end	
	cmp.b #0,d6		;ball in_game?
	beq switch_right
	move.b #0,d6		;put ball in_game
	bra done_left
switch_right:
	eor.b #$FF,d5		;change ball_direction
	bra done_left
not_left_end:
	cmp.b #$ff,d6		;right_serve?
	beq done_left
	jsr score_right
done_left:
	rte
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
rightinterrupt:
	tst.b $10080		;acknowledge lvl5 interrupt
	cmp.b #1,d2		;ball at right edge?
	bne not_right_end
	cmp.b #0,d6		;ball in_game?
	beq switch_left
	move.b #0,d6		;put ball in_game
	bra done_right
switch_left:
	eor.b #$FF,d5
	bra done_right
not_right_end:
	cmp.b #$ff,d6		;left_serve?
	beq done_right		
	jsr score_left
done_right:
	rte
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

