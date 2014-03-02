
init:
        move.w #$7000,a7
        move.l #$0,$3000
main_loop: 
        jsr bcd
        bra main_loop

#########################################################
#   function    bcd,                                    #
#   desc.       decimal counter                         #
#       inarg:  none                                    #
#       outarg: none                                    #
#########################################################
bcd:
        movem.l a1-a6/d1-d7,-(a7)       ; Push registers to stack

        move.l #$3000,a1                ; Pointer to time memory
        move.b #$0,d1                   ; Reset counter
        move.b #$1,d3
bcd_loop:
        move.b (a1),d2                  ; Fetch time to d2
        add.b d3,d2                     ; Increase time by one
        jsr bcd_carry                   ; Check if carry
        move.b d2,(a1)+                 ; Save time to and increase pointer

        add.b #1,d1
        cmp.b #4,d1                     ; Repeat 4 times
        bne bcd_loop
bcd_done:
        movem.l (a7)+,a1-a6/d1-d7       ; Pop registers from stack
        rts
#################    ############    ####################


#########################################################
#   function    bcd_carry,                              #
#   desc.       checks if decimalbase is overflowing    #
#       inarg:  number to check in d2                   #
#       outarg: carry in d3                             #
#########################################################
bcd_carry:
        move.b #$0,d3                   ; Reset carry flag
        cmp.b #$A,d2                    ; Check if carry
        bne no_carry
        move.b #$0,d2                   ; Set d2 to 0 if carry
        move.b #$1,d3                   ; Set carry flag
no_carry:
        rts
#################    ############    ####################


#########################################################
#   function     seg_mux                                #
#   desc. muxing through the 7-seg led                  #
#       inarg:  none                                    #
#       outarg: none                                    #
#########################################################
seg_mux:
        movem.l a1-a6/d1-d7,-(a7)       ; Push registers to stack
        move.l #$3010,a1                ; Pointer active 7seg to memory
        move.b (a1),d1                  ; Fetch which segment is active

        jsr fetch_num                   ; Fetch number to be shown
        move.b d1,$10086                ; set PIAB 
        move.b d3,$10080                ; set PIAA

        add.b #$1,d1                    ; Change state (00 -> 01 -> 10 -> 11)
        and.b #$3,d1                    ; Set all except the last 2 dig to 0
        move.l d1,(a1)                  ; Save new active segment
        
        movem.l (a7)+,a1-a6/d1-d7       ; Pop registers from stack
#################    ############    ####################


#########################################################
#   function     seg_mux                                #
#   desc. muxing through the 7-seg led                  #
#       inarg:  none                                    #
#       outarg: number from memory in d3                #
#########################################################
fetch_num:
        move.l #$0,d2                   ; Reset d2
        move.b #$3000,d2
        add.b d1,d2
        move.l d2,a2                    ; Pointer to memory which shall be returned
        move (a2),d3
        rts        

#################    ############    ####################

seg_mem:
        dc.b $FC; 7seg 0 
        dc.b $60; 7seg 1 
        dc.b $6A; 7seg 2 
        dc.b $F2; 7seg 3 
        dc.b $66; 7seg 4 
        dc.b $B6; 7seg 5 
        dc.b $BE; 7seg 6 
        dc.b $E0; 7seg 7 
        dc.b $FE; 7seg 8 
        dc.b $F6; 7seg 9 
