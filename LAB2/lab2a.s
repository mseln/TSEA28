start:
	move.l #$7000,a7 	;stack
	move.l #$1100,$68	;avbrott niv 2
	move.l #$1200,$74	;avbrott niv 5
	
	jsr $c300		;las in subrutiner
	jsr $20ec		;initiera PIA
	and.w #$F8FF,SR		;satt avbrottsniva till 0

programloop:
	move.l #1000,d0		
	jsr $2000		;DELAY
	or.w #$0700,SR		;set interrupt lvl 7
	jsr $2020		;SKBAK skriver ut 'BAKGRUNDSPROGRAM'
	and.w #$f8ff,SR
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
