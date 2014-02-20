main:
init:
        move.l #$7000,a7        ; Set Stackpointer to $7000
        jsr pinit
        jsr setup_interrupt_vectors
        and.w #$F8FF,sr
inf_loop:
        jsr delay
        jsr skbak
        bra inf_loop
        

pinit:
        jsr $20EC
        rts

delay:
        move.l #1000,d0
        jsr $2000
        rts

skbak:
        or.w #$700,sr
        jsr $2020
        and.w #$F8FF,sr
        rts
skavv:
        tst.b $10082
        jsr $2048
        rte
skavh:
        tst.b $10080
        jsr $20A6
        rte

setup_interrupt_vectors:
        lea skavv,a1
        move.l a1,$68
        lea skavh,a1
        move.l a1,$74
        rts
