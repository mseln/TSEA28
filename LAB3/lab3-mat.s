;;;;;;;;;;;;;;;;;;
; LAB3 - DIGITALUR
;;;;;;;;;;;;;;;;;;
; $900-903 tid - S S : M M
; a6 pekar pa SJUSEGTAB
; a5 pekar pa $900
;;;;;;;;;;;;;;;;;;
start:
	move.l #$7000,a7	; init stack
	or.w #$0700,SR		; set interrupt lvl 7 for initiation
	move.l #0,d6		; used for Mux-counter
	move.l #0,d5
	LEA sjusegtab,a6	; point out SJUSEGTAB
	move.l #$900,a5
	move.l #$00,(a5)	; load time to $900-$903, SS:MM
	LEA bcd,a0
	move.l a0,$74		; BCD on interrupt lvl 5
	LEA mux,a0
	move.l a0,$68		; MUX on interrupt lvl 2

	jsr piainit		; init PIA
	and.w #$F8FF,SR		; set interrupt lvl 0

do_nothing:
	nop
	nop
	nop
	nop
	nop
	nop
	bra do_nothing
;;;;;;;;;;;;;;;;;
bcd:
	tst.b $10080		; acknowledge interrupt
	move.b (a5)+,d0	; load time
	move.b (a5)+,d1
	move.b (a5)+,d2
	move.b (a5)+,d3
	addq.b #1,d0		; add 1 sec
	cmp.b #10,d0		
	blt done		
	move.b #0,d0		
	addq.b #1,d1		; add 10 sec 
	cmp.b #6,d1
	blt done
	move.b #0,d1
	addq.b #1,d2		; add 1 min
	cmp.b #10,d2
	blt done
	move.b #0,d2
	addq.b #1,d3		; add 10 min
	cmp.b #6,d3
	blt done
	move.b #0,d3
done:
	move.b d3,-(a5)
	move.b d2,-(a5)
	move.b d1,-(a5)
	move.b d0,-(a5)
	RTE
;;;;;;;;;;;;;;;;;
mux:
	move.b d6,$10082	; chooses output display 0-3
	move.b 0(a5,d6.w),d5	; d6 contains which number to print
	move.b 0(a6,d5.w),d5	; load sjusegtab with d6-offset into d5
	move.b d5,$10080	; display number	
	addq.b #1,d6
	cmp.b #4,d6
	bne mux_done
	move.l #0,d6
mux_done:
	RTE
;;;;;;;;;;;;;;;;;
piainit:
	move.b #0,$10084	; address DDRA
	move.b #$7F,$10080	; A0-A6 output
	move.b #7,$10084	; address PIAA, CA7 interrupt
	move.b #0,$10086	; address DDRB
	move.b #3,$10082	; B0-B1 outputs
	move.b #7,$10086	; address PIAB, CB7 interrupt
	rts
;;;;;;;;;;;;;;;;
sjusegtab:
	dc.b $3F		; '0'
	dc.b $06		; '1'
	dc.b $5B		; '2'
	dc.b $4F		; '3'
	dc.b $66		; '4'
	dc.b $6C		; '5'
	dc.b $7C		; '6'
	dc.b $23		; '7'
	dc.b $7F		; '8'
	dc.b $6F		; '9'
