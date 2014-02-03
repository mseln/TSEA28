                move.l #$7000,a7        ; Set Stackpointer to $7000
                ; move.b #$24,$4122
                ; jsr setupstr
                ; jsr print_wrong
                
                jsr setupblink
                jsr setuppia
                bra alarm_on
                move.b #255,d7
                trap #14
main:
                move.l #$7000,a7        ; Set Stackpointer to $7000
                jsr setuppia
                jsr setupstr
                jsr setupcode
                jsr setupblink
                jsr setuppwm
                bra alarm_off
alarm_on:
                ; jsr activate_alarm
alarm_on_state:
                jsr update_pwm
                jsr pwm
                ; jsr blink
                ; jsr update_led
                jsr getkey
                cmp.b #$f,d4
                beq submit
                bra alarm_on_state
submit:
                jsr checkcode
                cmp.b #$1,d4
                beq alarm_off             ; Correct!
incorrect:
                move.b $4122,d6
                add.b  #1,d6
                move.b d6,$4122

                jsr print_wrong

                bra alarm_on_state

alarm_off:
                move.b #$00,$4122         ; Reset number of tries
                jsr deactivate_alarm
alarm_off_state:
                jsr getkey
                cmp.b #$a,d4
                bne alarm_off_state
                bra alarm_on   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; In argument: ASCII-coded charactarer at register d4
; Varning - Denna rutin gar inte att stega sig igenom med TRACE da den
; anvander serieporten pa ett satt som ar inkompatibelt med TRACE.
printchar:
                move.b d5,-(a7)         ; Spara undan d5 pa stacken
waittx:
                move.b $10040,d5        ; Serieportens statusregister
                and.b #2,d5             ; Isolera bit 1 (Ready to transmit)
                beq waittx              ; Vanta tills serieporten ar klar att sanda
                move.b d4,$10042        ; Skicka ut
                move.b (a7)+,d5         ; Aterstall d5
                rts                     ; Tips: Satt en breakpoint har om du har problem med trace!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setuppia:
                move.b #00,$10084        ; Valj datariktningsregistret (DDRA)
                move.b #01,$10080        ; Satt pinne 0 pa PIAA som utgang
                move.b #04,$10084        ; Valj in/utgangsregistret
                move.b #00,$10086        ; Valj datariktningsregistret (DDRB)
                move.b #00,$10082        ; Satt alla pinnar som ingangar
                move.b #04,$10086        ; Valj in/utgangsregistret
                rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; In argument: Pekare till strangen i a4
;              Langd pa strangen i d5
printstring:
                move.b (a4)+,d4
                jsr printchar
                add.b #-1,d5
                beq done
                bra printstring
done:
                rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print_wrong:
                move.b $4122,d2
                move.b #$00,d3
                cmp.b  #9,d2
                ble lt_ten

gt_ten:
                add.b  #-10,d2
                add.b  #1,d3
                cmp.b  #9,d2
                bgt gt_ten
lt_ten:
                add.b  #$30,d2
                add.b  #$30,d3

                move.b d3,$410f           ; Number 1
                move.b d2,$4110           ; Number 2
                
                move.l #$4100,a4          ; In arguments to printstring
                move.b #20,d5             ; string is at $4100 with length 20
                jsr printstring

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;
; In argument:  None
; Out argument: None
;
; Function: Turns the LED connected to the PIAA on
deactivate_alarm:
                move.b #00,$10080
                rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; In argument:  None
; Out argument: None
;
; Function: Turns the LED connected to the PIAA on
activate_alarm:
                move.b #01,$10080
                rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; In argument:  None
; Out argument: None
;
; Function: Turns the LED connected to the PIAA on
update_led:
                move.b $4208,$10080
                rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; In argument:  None
; Out argument: Pressed button is returned at memaddr d4
getkey:
; Forberedelseuppgift: Skriv denna subrutin!
                move.b #$00,d4

                move.b $10080,d5       ; Read hexkeyboard
                move.b $4020,d6        ; Old input

                move.b d5,$4020        ; Save new input to $4020
                move.b d6,$4022        ; Save old input to $4022

                and.b  #$10,d5          ; Get new strobe
                and.b  #$10,d6          ; Get old strobe
                lsr.b  #4,d5           ; Get strobe to bit 1
                lsr.b  #4,d6           ; Get strobe to bit 1

                cmp.b  #$0,d6          ; Was strobe low?
                bne strobe_high
strobe_low:
                cmp.b  #$1,d5          ; Is strobe rising?
                bne status_quo
                move.b $4020,d4        ; Fetch input
                and.b  #$0f,d4          ; Zero out the four MSB bits
                jsr addkey
                rts                    ; Return input to d4
strobe_high:
status_quo:     
                move.b #$00,d4
                rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; In argument:  Vald tangent i d4
; Out argument: None
;
; Function: Flyttar $4001-$4003 bakat en byte till
; $4000-$4002. Lagrar sedan innehallet i d4 pa adress $4003.
addkey:
                cmp.b  #9,d4
                bgt to_big
                move.l $4000,d3
                lsl.l  #8,d3
                move.l d3,$4000
                move.b d4,$4003
to_big:
                rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; In argument:  None
; Out argument: None
;
; Function: Sets the memory at $4000-$4003 to $FF
clearinput:
                move.l #$ffffffff,$4000

                ; move.l #$01030307,$4000
                rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; In argument:  None
; Out argument: Returnerar 1 i d4 om koden var korrekt, annars 0 i d4
checkcode:
; Function: Checks if the code is correct
                move.l $4000,d2               ; Check input
                move.l $4010,d3
                cmp.l d2,d3
                bne wrong_code
right_code:
                move.b #1,d4
                rts
wrong_code:
                move.b #0,d4
                rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; In argument:  None
; Out argument: None
setupcode:
; Function hardkodar den korrekta koden i $4010-$4013
                move.b #$01,$4010
                move.b #$03,$4011
                move.b #$03,$4012
                move.b #$07,$4013
                rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; In argument:  None
; Out argument: Length of string in d5
setupstr:
; Function sets up the string "BAKGRUNDSPROGRAM\n" to the memory 
; adress $4100-$4110
                move.l #$4100,a1        ; Where to put the string
                move.b #20,d5           ; Move 14 to d5 (length of string)

                move.b #'F',(a1)+       ; F
                move.b #'e',(a1)+       ; e
                move.b #'l',(a1)+       ; l
                move.b #'a',(a1)+       ; a

                move.b #'k',(a1)+       ; k
                move.b #'t',(a1)+       ; t
                move.b #'i',(a1)+       ; i
                move.b #'g',(a1)+       ; g
                
                move.b #' ',(a1)+       ;  
                move.b #'k',(a1)+       ; k
                move.b #'o',(a1)+       ; o
                move.b #'d',(a1)+       ; d

                move.b #'!',(a1)+       ; !
                move.b #' ',(a1)+       ;  
                move.b #'(',(a1)+       ; (
                move.b #'x',(a1)+       ; x

                move.b #'x',(a1)+       ; x
                move.b #')',(a1)+       ; )
                move.b #$a,(a1)+        ; \n
                move.b #$d,(a1)+        ; \n

                rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

setupblink:
                move.l #0008000,$4200   ; Time
                move.l #0,$4204         ; Counter
                move.b #0,$4208         ; State
                rts
blink:          
                move.l $4204,d2         ; Fetch counter
                add.l  #1,d2            ; Increase counter
                move.l d2,$4204         ; Save counter

                move.l $4200,d3         ; Fetch Time
                cmp.l  d2,d3            ; Compare couter
                beq change_state
                rts
change_state:
                move.l #0,$4204         ; Reset counter
                move.b $4208,d2         ; Fetch state
                add.b  #1,d2            ; Change state
                and.b  #01,d2           ; 
                move.l d2,$4208         ; Save state
                rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; In argument:  None
; Out argument: None
setuppwm:
                move.b #1,$4140        ; delta counter
                move.b #0,$4141        ; counter
                rts
invert_dc:
                move.b $4140,d2
                neg.b d2
                move.b d2,$4140
                rts
update_pwm:
                move.b $4140,d2         ; fetch delta
                move.b $4141,d3         ; fetch counter
                add.b d2,d3

                cmp.b #$80,d2
                bne not_to_big
                jsr invert_dc
not_to_big:
                cmp.b #$0,d2
                bne not_to_small
                jsr invert_dc
not_to_small:
                move.b d2,$4140         ; save delta
                move.b d3,$4141         ; save counter
                rts

pwm:
; Function: PWM function, uses d3 for duty cycle. Runs until d1 is zero.
                move.b $4141,d3          ; fetch counter
                move.b #$80,d2
                move.l #00,$4208         ; state = 0 (led off)
                jsr update_led
duty_loop:
                cmp.b d2,d3
                bne no_act
                move.l #01,$4208         ; state = 1 (led on)
                jsr update_led
no_act:
                add.b #-1,d2
                bne duty_loop

                rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
