start:
                move.l #$7000,a7        ; Set Stackpointer to $7000
                jsr setuppia

                move.l #$0001024,d1     ; adress to interrupt func
                move.l d1,$0068         ; lvl 1 interrupt
                move.l d1,$0074         ; lvl 1 interrupt

infloop:
                bra infloop
                ; jsr setupstr
                ; move #$4100,a4          ; In argument to printstring
                ; jsr printstring         ; the string to be printed starts at #$4100

                ; jsr clearinput          ; Clear input from keypad
                ; jsr hardsetcode
                ; jsr checkcode
                jsr addkey
end:
                move.b #255,d7
                trap #14


inter:          
                ; jsr setupstr
                ; move #$4100,a4          ; In argument to printstring
                move #$11,d5
                ; jsr printstring         ; the string to be printed starts at #$4100
                rts



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
                move.b #13,$10084        ; Valj in/utgangsregistret
                move.b #00,$10086        ; Valj datariktningsregistret (DDRB)
                move.b #00,$10082        ; Satt alla pinnar som ingangar
                move.b #13,$10086        ; Valj in/utgangsregistret
                rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; In argument: Pekare till strangen i a4
;              Langd pa strangen i d5
printstring:
                move.b (a4)+,d4
                jsr printchar
                add #-1,d5
                beq done
                bra printstring
done:
                rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;
; In argument:  None
; Out argument: None
;
; Function: Turns the LED connected to the PIAA on
deactivatealarm:
                move #00,$10080
                rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; In argument:  None
; Out argument: None
;
; Function: Turns the LED connected to the PIAA on
activatealarm:
                move #01,$10080
                rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; In argument:  None
; Out argument: Pressed button is returned at memaddr d4
getkey:
; Forberedelseuppgift: Skriv denna subrutin!
                
                rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; In argument:  Vald tangent i d4
; Out argument: None
;
; Function: Flyttar $4001-$4003 bakat en byte till
; $4000-$4002. Lagrar sedan innehallet i d4 pa adress $4003.
addkey:
                move.b $4001,d3
                move.b d3,$4000

                move.b $4002,d3
                move.b d3,$4001
                
                move.b $4003,d3
                move.b d3,$4002
                
                move.b d4,d3
                move.b d3,$4003

                rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; In argument:  None
; Out argument: None
;
; Function: Sets the memory at $4000-$4003 to $FF
clearinput:
                move.b #$ff,$4000
                move.b #$ff,$4001
                move.b #$ff,$4002
                move.b #$ff,$4003

                ; test correct code
                ; move.b #$01,$4000
                ; move.b #$03,$4001
                ; move.b #$03,$4002
                ; move.b #$07,$4003
                rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; In argument:  None
; Out argument: Returnerar 1 i d4 om koden var korrekt, annars 0 i d4
checkcode:
; Function: Checks if the code is correct
                move.l #$ffffffff,d2          ; Clear d2
                move.l #$ffffffff,d3          ; Clear d3
                
                move.b $4000,d2               ; Check if m[$4000] == m[$4010]
                move.b $4010,d3
                cmp d2,d3
                bne wrong_code

                move.b $4001,d2               ; Check if m[$4001] == m[$4011]
                move.b $4011,d3
                cmp d2,d3
                bne wrong_code

                move.b $4002,d2               ; Check if m[$4002] == m[$4012]
                move.b $4012,d3
                cmp d2,d3
                bne wrong_code

                move.b $4003,d2               ; Check if m[$4003] == m[$4013]
                move.b $4013,d3
                cmp d2,d3
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
hardsetcode:
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
                move.b #17,d5           ; Move 16 to d5 (length of string)

                move.b #$42,(a1)+       ; B
                move.b #$41,(a1)+       ; A
                move.b #$4b,(a1)+       ; K
                move.b #$47,(a1)+       ; G

                move.b #$52,(a1)+       ; R
                move.b #$55,(a1)+       ; U
                move.b #$4e,(a1)+       ; N
                move.b #$44,(a1)+       ; D
                
                move.b #$53,(a1)+       ; S
                move.b #$50,(a1)+       ; P
                move.b #$52,(a1)+       ; R
                move.b #$4f,(a1)+       ; O

                move.b #$47,(a1)+       ; G
                move.b #$52,(a1)+       ; R
                move.b #$41,(a1)+       ; A
                move.b #$4d,(a1)+       ; M

                move.b #$a,(a1)+        ; \n

                rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; In argument:  None
; Out argument: None
pwm:
; Function: PWM function, uses d3 for duty cycle. Runs until d1 is zero.
                move.b #$88,d3
pwm_loop:
                move.b #$ff,d2

duty_loop:
                cmp.b d2,d3

                bne no_act
                jsr activatealarm
no_act:
                cmp.b #$00,d1
                beq pwm_done

                add.b #-1,d2
                bne duty_loop

                jsr deactivatealarm
                bra pwm_loop

pwm_done:
                jsr deactivatealarm
                rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
