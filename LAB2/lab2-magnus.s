main:
init:
        move.l #$7000,a7        ; Set Stackpointer to $7000
        jsr pinit
        jsr setup_interrupt_vectors
        
        move.b #255,d7
        trap #14
        jsr setup_str1
        jsr setup_str2
        jsr setup_str3
inf_loop:
        move.l #1000,d0
        move.l #$4100,a4
        move.l #17,d5
        jsr print_str

        move.l #1000,d0
        move.l #$4140,a4
        move.l #15,d5
        jsr print_str

        move.l #1000,d0
        move.l #$4180,a4
        move.l #16,d5
        jsr print_str
        
        jsr delay
        bra inf_loop
        

pinit:
        clr.b $00010084
        clr.b $00010086
        move.b #255,$00010080
        move.b #255,$00010082
        move.b #31,$00010084
        move.b #31,$00010086
        tst.b $00010080
        tst.b $00010082
        rts

delay:
        move.l d1,-(a7)
one_ms:
        move.l #104,d1
count:
        sub.l #1,d1
        bpl.s count
        subq.l #1,d0
        bpl.s one_ms
        move.l (a7)+,D1
        rts

