init:
        move.l #$7000,a7
        move.l #$0,$3000
        
        jsr setuppia
        jsr setuppwm
        and.w #$F8FF,SR         ;set interruptlevel 0
main_loop:
        jsr pwm
        bra main_loop

#########################################################
#   function    bcd,                                    #
#   desc.       decimal counter                         #
#       inarg:  none                                    #
#       outarg: none                                    #
#########################################################
bcd:
        tst.b $10082                    ; acknowledge lvl5 interrupt
        movem.l a0-a6/d0-d7,-(a7)       ; Push registers to stack

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
        move.l #$FFFF,$4010
        movem.l (a7)+,a0-a6/d0-d7       ; Pop registers from stack
        rte
#################    ############    ####################


#########################################################
#   function    bcd_carry,                              #
#   desc.       checks if decimalbase is overflowing    #
#       inarg:  number to check in d2                   #
#       outarg: carry in d3                             #
#########################################################
bcd_carry:
        move.b #$0,d3                   ; Reset carry flag
        
        move.b d1,d4
        and.b #$1,d4
        beq.b carry_up_to_9

        cmp.b #$6,d2                    ; Check if carry
        bne no_carry
        move.b #$0,d2                   ; Set d2 to 0 if carry
        move.b #$1,d3                   ; Set carry flag

carry_up_to_9:
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
        movem.l a0-a6/d0-d7,-(a7)       ; Push registers to stack
        tst.b $10080                    ; acknowledge lvl5 interrupt
        move.l #$3010,a1                ; Pointer active 7seg to memory
        move.b (a1),d1                  ; Fetch which segment is active

        and.l #$3,d1
        jsr fetch_num                   ; Fetch number to be shown

        and.l #$F,d3
        lea seg_mem,a0                  ; Tabellstart till A0
        add.l d3,a0
        move.b (a0),d0


        move.b d1,$10082                ; set PIAB 
        move.b d0,$10080                ; set PIAA

        add.b #$1,d1                    ; Change state (00 -> 01 -> 10 -> 11)
        move.b d1,(a1)                  ; Save new active segment
        
        move.l $4008,d0
        tst.l d0
        beq nop_duty
        add.l #-1,d0
nop_duty:
        move.l d0,$4008

        movem.l (a7)+,a0-a6/d0-d7       ; Pop registers from stack
        rte
#################    ############    ####################


#########################################################
#   function     seg_mux                                #
#   desc. muxing through the 7-seg led                  #
#       inarg:  none                                    #
#       outarg: number from memory in d3                #
#########################################################
fetch_num:
        move.l #$3000,d2
        add.b d1,d2
        move.l d2,a2                    ; Pointer to memory which shall be returned
        move.b (a2),d3
        rts        
#################    ############    ####################

#########################################################
#   function     setuppia                               #
#   desc. muxing                                        #
#       inarg:  none                                    #
#       outarg: none                                    #
#########################################################
setuppia:
        move.b #$00,$10084        ; Valj datariktningsregistret (DDRA)
        move.b #$FF,$10080        ; Satt alla pinnar pa PIAA som utgang
        move.b #$07,$10084        ; Valj in/utgangsregistret och satt interrupt CRA_7
        move.b #$00,$10086        ; Valj datariktningsregistret (DDRB)
        move.b #$FF,$10082        ; Satt alla pinnar pa PIAB som utgang 
        move.b #$07,$10086        ; Valj in/utgangsregistret och satt interrupt CRB_7
        
        move.l #bcd,$68
        move.l #seg_mux,$74
        rts
#################    ############    ####################

seg_mem:
        dc.b $FC; 7seg 0 
        dc.b $60; 7seg 1 
        dc.b $DA; 7seg 2 
        dc.b $F2; 7seg 3 
        dc.b $66; 7seg 4 
        dc.b $B6; 7seg 5 
        dc.b $BE; 7seg 6 
        dc.b $E0; 7seg 7 
        dc.b $FE; 7seg 8 
        dc.b $F6; 7seg 9

 
#########################################################
#   function     setuppwm                               #
#   desc. setting up pwm                                #
#       inarg:  none                                    #
#       outarg: none                                    #
#########################################################
setuppwm:
        move.l #1000,$4004
        move.l #$FE,$4008
        move.l #1000,$4000
        rts
#################    ############    ####################

#########################################################
#   function     pwm                                    #
#   desc. pwming all numbers                            #
#       inarg:  none                                    #
#       outarg: none                                    #
#########################################################
pwm:    
        move.l $4004,d1
        move.l $4008,d2
        
        add.l #-1,d1
        bmi reset        

        cmp.l d1,d2
        bne nop
        jsr turn_off_7seg
reset:
        move.l #$FFFF,d1 
nop:
        move.l d1,$4004
        rts
#################    ############    ####################

#########################################################
#   function     new_pwm                                #
#   desc. init new pwm loop                             #
#       inarg:  none                                    #
#       outarg: none                                    #
#########################################################
new_pwm:
        move.l #1000,$4000
        rts
#################    ############    ####################

#########################################################
#   function     new_duty                               #
#   desc. init new pwm loop                             #
#       inarg:  none                                    #
#       outarg: none                                    #
#########################################################
new_duty:
        move.l $4000,d0
        add.l #-1,d0
        
        rts
#################    ############    ####################

#########################################################
#   function     turn_off_7seg                          #
#   desc. pwming all numbers                            #
#       inarg:  none                                    #
#       outarg: none                                    #
#########################################################
turn_off_7seg:
        move.b #0,$10080                ; set PIAA
        rts
#################    ############    ####################
