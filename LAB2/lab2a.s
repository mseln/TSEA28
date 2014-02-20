start:
	move.l #$7000,a7 	;stack
	lea  avbrott2,a1	;avbrott niv 2
    move.l a1,$68
	lea  avbrott5,a1	;avbrott niv 2
    move.l a1,$74
	
	jsr $20ec		;initiera PIA
	and.w #$F8FF,SR		;satt avbrottsniva till 0

programloop:
	move.l #1000,d0		
	jsr $2000		;DELAY
	or.w #$0700,SR		;set interrupt lvl 7
	jsr $2020		;SKBAK skriver ut 'BAKGRUNDSPROGRAM'
	and.w #$F8FF,SR     ;set interrupt lvl 0
	bra programloop
	

;;; AVBROTT NIV 2 $1100
avbrott2:
	tst.b $10082		;acknowledge
	jsr $2048		;SKAVV
	rte

;;; AVBROTT NIV 5 $1200
avbrott5:
	tst.b $10080		;acknowledge
	jsr $20a6		;SKAVH skriver ut avbrott hoger
	rte			
