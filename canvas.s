; Hardware spec
.ROMDMG
.NAME "PONGDEMO"
.CARTRIDGETYPE 0
.RAMSIZE 0
.COMPUTEGBCHECKSUM
.COMPUTEGBCOMPLEMENTCHECK
.LICENSEECODENEW "00"
.EMPTYFILL $00

.MEMORYMAP
	SLOTSIZE $4000
	DEFAULTSLOT 0
	SLOT 0 $0000
	SLOT 1 $4000
.ENDME

.ROMBANKSIZE $4000
.ROMBANKS 2

.BANK 0 SLOT 0

; Variables, placed at the begining of the ram ($C000)
; DB: Declare Byte, = 8 bits
; DW: Declare Word, = 16 bits
.ENUM $C000
	RacketLY DB ; RacketLY := $C000
	RacketRY DB ; RacketRY := $C001
	BallX DB    ; BallX := $C002
	BallY DB    ; ...
	SpeedX DB
	SpeedY DB
	Gravity DB
.ENDE

.ORG $0040 ; Write at the address $0040 (vblank interuption)
	call VBlank
	reti

.ORG $0100 ; Write at the address $0100 (starting point of the prog)
	nop; adviced from nintendo. nop just skip the line.
	jp start

.ORG $0104
;Logo Nintendo, mandatory...
.DB $CE,$ED,$66,$66,$CC,$0D,$00,$0B,$03,$73,$00,$83,$00,$0C
.DB $00,$0D,$00,$08,$11,$1F,$88,$89,$00,$0E,$DC,$CC,$6E,$E6
.DB $DD,$DD,$D9,$99,$BB,$BB,$67,$63,$6E,$0E,$EC,$CC,$DD,$DC
.DB $99,$9F,$BB,$B9,$33,$3E

.org $0150 ; Write after $0150. Safe zone after the header.
; ///////// INIT \\\\\\\\\
start:
	di		; disable interrupt
	ld sp,$FFF4     ; set the StackPointer
	xor a		; a=0
	ldh ($26),a     ; ($FF26) = 0, turn the sound off
waitvlb: 		; wait for the line 144 to be refreshed:
	ldh a,($44)
	cp 144          ; if a < 144 jump to waitvlb
	jr c, waitvlb
                        ; now we are in the vblank,
                        ; the screen is not eddited for a few
                        ; cycles.
			; turn the screen off:
	xor a
	ldh ($40), a    ; ($FF40) = 0, turn the screen off

			; Load 3 titles
	ld b,3*8*2
	ld de,Tiles
	ld hl,$8000
ldt:			; while b != 0
	ld a,(de)
	ldi (hl),a	; *hl <- *de; hl++
	inc de		; de ++
	dec b		; b--
	jr nz,ldt	; end while

			; clear the background (the nintendo logo)
	ld de,32*32
	ld hl,$9800
clmap:			; while de != 0
	xor a;
	ldi (hl),a	; *hl <- 0; hl++
	dec de		; de --
	ld a,e
	or d
	jr nz,clmap	; end while
	; The Z flag can't be used when dec on 16bit reg :(

			; clean the sprites pos (OAM)
	ld hl,$FE00
	ld b,40*4
clspr:			; while b != 0
	ld (hl),$00	; *hl <- O
	inc l		; hl ++ (no ldi hl or inc hl: bug hardware!)
	dec b		; b --
	jr nz,clspr	; end while

			; set the background offset to 0
	xor a
	ldh ($42),a
	ldh ($43),a


			; load the racket sprite
	ld hl,$FE00

; LOAD LEFT RACKET SPRITES
;
; [$FE00-$FE10[ = racket L [Y, X, sprite num, 0]*4
;	ld b,4
;	xor a		; a <- 0
;ldspr1:			; while b != 0
;	ld (hl),a	; sprite.y <- a
;	add 8		; a += 8
;	inc l
;	ld (hl),$10	; sprite.x <- 0x10
;	inc l
;	ld (hl),$01	; sprite.tile <- tile[1]
;	inc l
;	ld (hl),$00	; sprite.attribute <- 0
;	inc l
;	dec b		; b --
;	jr nz,ldspr1	; end while
;

; [$FE10-$FE14[ = ball [Y, X, sprite num, 0]
			; load the ball sprite
	ld (hl),$80	; ball.x <- 0x80
	inc l
	ld (hl),$80	; ball.y <- 0x80
	inc l
	ld (hl),$02	; ball.tile <- tile[2]
	inc l
	ld (hl),$00	; ball.attribute <- 0
	inc l

; LOAD RIGHT RACKET SPRITES
; [$FE14, $FE24[ = racket R [Y, X, sprite num, 0]*4
;	ld b,4
;	xor a
;ldspr2:
;	ld (hl),a
;	add 8
;	inc l
;	ld (hl),$80
;	inc l
;	ld (hl),$01
;	inc l
;	ld (hl),$00
;	inc l
;	dec b
;	jr nz,ldspr2

; /// init variables \\\
; RACKETS POS
;	ld a, $20
;	ld (RacketLY),a
;	ld (RacketRY),a
; BALL POS
	ld a,$80
	ld (BallX),a
	ld (BallY),a
; BALL SPEED
	ld a,0
	ld (SpeedX),a
	ld (SpeedY),a
; GRAVITY
	ld a,$1
	ld (Gravity),a
; \\\ init variables ///

; /// init color palettes \\\
	ld a,%11100100	; 11=Black 10=Dark Grey 01=Grey 00=White/trspt
	ldh ($47),a	; background palette
	ldh ($48),a	; sprite 0 palette
	ldh ($49),a	; sprite 1 palette
	ld a,%10010011 	; screen on, bg on, tiles at $8000
	ldh ($40),a
; \\\ init the color palettes ///

; /// re enable interruptions \\\
	ld a,%00010000
	ldh ($41),a	; enable VBlank interruption
	ld a,%00000001
	ldh ($FF),a	; twice, BECAUSE IT'S FUN
	ei		; interrutions are back!
; \\\ re enable interruptions ///

; \\\\\\\\\ INIT /////////

; ///////// MAIN LOOP \\\\\\\\\
loop:
	jr loop
; \\\\\\\\\ MAIN LOOP /////////

; ///////// VBlank Interuption \\\\\\\\\
VBlank:
	push af
	push hl



; ### YOUR CODE HERE

	ld a,(SpeedX)  ; put SpeedX value in accumulator
	ld hl,Gravity
	ld b,(hl) ; put Gravity value in b
	sub b          ; decrease SpeedX
	ld (SpeedX),a  

	ld a, (BallX)
	add (SpeedX)
	ld (BallX), a


; ### THE BALL IS AUTOMATICALLY PLOTTED AT (BallX), (BallY)
; ### You can use the SpeedX and SpeedY variables.
; ### You can call the functions lowbeep and hibeep to make sound.
; ### You can uncomment the section bellow to do stuff when the
; ### arrows are pressed.


; /// TEST ARROWS \\\
;	ld a,%00100000	; Select arrow keys
;	ldh ($00),a
;	ldh a,($00)	; Read arrow keys
;	ld b,a
;
;	bit $3,b	; Test third bit (down)
;	jr nz,nod
; ### IF ARROW DOWN IS PRESSED
; ###
; ###
; ###
;nod:
;	bit $2,b	; Test second bit (up)
; ### IF ARROW UP IS PRESSED
; ###
; ###
; ###
;nou:
; ### For more options with inputs, see the pandocs.
; \\\ TEST ARROWS ///



; //// Update ball pos \\\\
	ld hl,$FE10
	ld a,(BallY)
	ld (hl),a
	inc l
	ld a,(BallX)
	ld (hl),a
; \\\\ Update ball pos ////

	pop hl
	pop af
	ret
; \\\\\\\\\ VBlank Interuption /////////

; /// Low beep function \\\
lowbeep:	; Beep
	call setsnd
	ld a,%00000000
	ldh ($13),a
	ld a,%11000111
	ldh ($14),a
	ret
; \\\ Low beep function ///

; /// Hi beep function \\\
hibeep:		; Another beep
	call setsnd
	ld a,%11000000
	ldh ($13),a
	ld a,%11000111
	ldh ($14),a
	ret
; \\\ Hi beep function ///

; /// Set sound function \\\
setsnd:
	ld a,%10000000
	ldh ($26),a
	ld a,%01110111
	ldh ($24),a
	ld a,%00010001
	ldh ($25),a
	ld a,%10111000
	ldh ($11),a
	ld a,%11110000
	ldh ($12),a
	ret
; \\\ Set sound function ///


Tiles:
.INCBIN "tiles.bin"
