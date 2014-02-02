setup:
        move.l #$7000,a7
        move.l #$30504c39,$4000
        move.l #$4d5b2d07,$4004
        move.l #$4d59537f,$4008
        move.l #$1d264522,$400c
        move.l #$86c02367,$5000
        move.l #$8451fa75,$5004
        move.l #$c209dfed,$5008
        move.l #$a8789adf,$500c

start:
        move.b #10,d0
        move.l #$0,d1
        move.l #$4000,a0
        move.l #$5000,a1
loop
        move.l a0,a2
        move.b (a1)+,d1
        and.b  #15,d1
        add.l  d1,a2
        move.b #25,d4
        add.b  (a2),d4
        jsr    printchar
        add.b  #-1,d0
        bne    loop

        move.b #228,d7
        trap   #14

printchar:
                move.b d5,-(a7)         ; Spara undan d5 pa stacken
waittx:
                move.b $10040,d5        ; Serieportens statusregister
                and.b #2,d5             ; Isolera bit 1 (Ready to transmit)
                beq waittx              ; Vanta tills serieporten ar klar att sanda
                move.b d4,$10042        ; Skicka ut
                move.b (a7)+,d5         ; Aterstall d5
                rts                     ; Tips: Satt en breakpoint har om du har problem med trace!
