;startadress $1000
;Minnesadresser
;$4000-$4003 4 senaste inmatade siffrorna
;$4010-$4013 rätt kod
;$4020
;$7000 stackpekare

start:
	move.l #$7000,a7	;satt SP till $7000
	jsr setuppia
	jsr clearinput

programloop:
	jsr getkey
	bra programloop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printchar:
	move.b d5,-(a7) ; Spara undan d5 pa stacken
waittx:
	move.b $10040,d5 ; Serieportens statusregister
	and.b #2,d5 ; Isolera bit 1 (Ready to transmit)
	beq waittx ; Vanta tills serieporten r klar att sanda
	move.b d4,$10042 ; Skicka ut
	move.b (a7)+,d5 ; Aterstall d5
	rts ; Tips: Satt en breakpoint har om du har problem med trace!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setuppia:
	move.b #0,$10084 ; Valj datariktningsregistret (DDRA)
	move.b #1,$10080 ; Satt pinne 0 pa PIAA som utgang
	move.b #4,$10084 ; Valj in/utgangsregistret
	move.b #0,$10086 ; Valj datariktningsregistret (DDRB)
	move.b #0,$10082 ; Satt alla pinnar som ingangar
	move.b #4,$10086 ; Valj in/utgangsregistret
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printstring:
	move.b a4,-(a7)
	lea string,a4
	move.b d5,-(a7)
	move.b #15,d5
stringloop:
	cmp.b #0,d5
	beq stringdone
	move.b (a4)+,d4
	add.b #-1,d5
	jsr printchar
	bra stringloop
stringdone:
	move.b (a7)+,d5
	move.b (a7)+,a4
	rts
;;;;;;;;;;;;;;;;;;;;;;;;
deactivatealarm:
	move.b #0,d0
	move.b d0,$10080 ;skriv 0 till utporten, lampan
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
activatealarm:
	move.b #1,d0
	move.b d0,$10080	;skriv 1 till utporten
	rts
;;;;;;;;;;;;;;;;;;;;;;;;
getkey:
	move.b #16,d0	;isolera strobe
loop:
	move.b $10082,d1;jllas in port B till d1
	and.b d1,d0	;kolla om strobe är på
	beq pressed
	rts
pressed:
	move.b d1,d4 	;flytta knapp till d4
	cmp.b #15,d4	;F nedtryckt?
	beq unlock
	cmp.b #10,d4	;A nedtryckt?
	beq lock
number:
        move.b $10082,d1
        move.b #15,d0
        and.b d1,d0	;vanta till strobe=0
        bne number
        jsr addkey	;lagg till knapp
        rts
unlock:
	jsr checkcode
	rts
lock:
	jsr activatealarm
	rts
;;;;;;;;;;;;;;;;;;;;
addkey:
	lsl.l #8,$4000
	move.b d4,$4003
	rts
;;;;;;;;;;;;;;;;;;;;;
clearinput:
	move.l #$FFFFFFFF,$4000-$4003
	rts
;;;;;;;;;;;;;;;;;;;;;;;;
checkcode:
	move.b #4,d7
	move.l #$4004,a0
	move.l #$4014,a1
loop:
	move.b -(a0),d0
	move.b -(a1),d1
	cmp.b #0,d7
	beq correct
	cmp.b d0,d1
	beq loop
wrongcode:
	jsr printstring
	rts
correct:
	jsr deactivatealarm
	rts
;;;;;;;;;;;;;;;;;;;;;;
string:
	dc.b 'Felaktig kod!',$d,$a


