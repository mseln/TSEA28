*******************************************************************************
*       Din nuvarande f?rberedelseuppgift f?r lab 2 ser ut som f?ljer
*******************************************************************************

*******************************************************************************
*       Detta program skriver ut ett meddelande genom att anropa en
*     subrutin som tar emot en formatsträng i a0 samt parametrar på stacken
*     För att lösa denna uppgift måste du reda ut vad som har hamnat på
*           stacken i samband med att detta program körs
*******************************************************************************

; test:
;        move.l #$51A4,a7
;        move.l #26383,-(a7)
;        move.l #5618,-(a7)
;        move.l #22282,-(a7)
;        move.w d0,-(a7)
;        move.l a1,-(a7)
;        move.l d1,-(a7)
;        move.l d4,-(a7)
;        move.w d2,-(a7)
;        move.w d3,-(a7)
;
;        move.b #255,d7
;        trap #14

huvudprogram:
        move.l #$5200,a7    * För att lösa uppgiften måste du antagligen
                            * lista ut vad det ska stå här istället för XXXX
        * Pusha argumenten till skrivut på stacken
        move.l #26383,-(a7)
        move.l #5618,-(a7)
        move.l #22282,-(a7)
        move.l #thestring,a0
        jsr skrivut
        add.l  #12,a7  * Poppa (och glöm bort) argumentet till skrivut
        move.b #255,d7
        trap #14
skrivut:
       move.w d0,-(a7)
       move.l a1,-(a7)
       move.l d1,-(a7)
       move.l d4,-(a7)

       move.l a7,a1
       add.l  #18,a1
       clr.l  d1
       clr.l  d4

        * Teckenloop stegar igenom strängen och letar efter escapetecken (%)
teckenloop:    
       move.b (a0)+,d0
       cmp.b  #0,d0
       beq    klar
       cmp.b  #'%',d0
       beq    escapetecken

normalprint:   
       move.b d0,d4
       jsr    printchar
       bra    teckenloop

escapetecken:  
       move.b (a0)+,d0
       cmp.b  #0,d0
       beq    klar

       cmp.b  #'%',d0
       beq    normalprint

       cmp.b  #'x',d0
       bne    teckenloop

       move.l (a1)+,d1
       jsr    skriv_hex
       bra    teckenloop


klar:
       move.l (a7)+,d4
       move.l (a7)+,d1
       move.l (a7)+,a1
       move.w (a7)+,d0
       rts
       
       
       * Skriv ut ett nummer hexadecimalt
skriv_hex:
       move.w d2,-(a7)
       move.w d3,-(a7)
       cmp.l  #0,d1
       beq    skriv_noll
       move.b #9,d0

hexloop_innan_etta:
       add.b  #-1,d0
       beq    hex_klar
       rol.l  #4,d1
       move.b d1,d2
       and.b  #$f,d2
       beq    hexloop_innan_etta

       jsr    skriv_hextecken

hexloop_efter_etta
       add.b  #-1,d0
       beq    hex_klar
       rol.l  #4,d1
       move.b d1,d2
       and.b  #$f,d2
       jsr    skriv_hextecken
       bra    hexloop_efter_etta
       
skriv_noll:
       move.b #'0',d4
       jsr printchar
hex_klar:
       move.w (a7)+,d3
       move.w (a7)+,d2
       rts

       * Skriv ut en siffra mellan 0-15 på hexadecimal form på serieporten
skriv_hextecken:
       cmp.b  #10,d2 *** <--- Här sätter vi en breakpoint
       bge    tio_eller_mer
       add.b  #'0',d2
       move.b d2,d4
       jsr    printchar
       rts
tio_eller_mer:
       add.b  #'A'-10,d2
       move.b d2,d4
       jsr    printchar
       rts
       
       

        * Skriv ut tecknet i d4.b på serieporten
printchar:     
        move.b d5,-(a7)
waittx:        
        move.b $10040,d5
        and.b #2,d5
        beq waittx
        move.b d4,$10042
        move.b (a7)+,d5
        rts

thestring:
        dc.b 'Och dagens vinnare har nummer $%x-$%x-$%x',13,10,0
