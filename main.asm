; Hello Sprite
; originl version February 17, 2007
; John Harrison
; An extension of Hello World, based mostly from GALP

;* 2008-May-01 --- V1.0a
;*                 replaced reference of sprite.inc with sprite.inc

INCLUDE "gbhw.inc" ; standard hardware definitions from devrs.com
INCLUDE "ibmpc1.inc" ; ASCII character set from devrs.com
INCLUDE "sprite.inc" ; specific defs

SPEED		EQU	$0fff
SpriteScratch	EQU	$FF90 
IsJump		EQU	$FF91 
JumpHeight	EQU	50 
PlayerXV	EQU	$FF92
PlayerYV	EQU	$FF93


; create variables
;	LoByteVar	xpos	; these are examples of how variables
;	LoByteVar	spry	; can be created. They are based on a
;	LoByteVar	sprx	; macro in sprite.inc

	SpriteAttr	PCSprite ; this is a structure of 4 variables. See sprite.inc

	; BIG MEME AHOY, that macro shit above ^^ needs an indent, variables
	; can't have an indent when being defined


; IRQs
SECTION	"Vblank",HOME[$0040]
	jp	DMACODELOC ; *hs* update sprites every time the Vblank interrupt is called (~60Hz)
SECTION	"LCDC",HOME[$0048]
	reti
SECTION	"Timer_Overflow",HOME[$0050]
	reti
SECTION	"Serial",HOME[$0058]
	reti
SECTION	"p1thru4",HOME[$0060]
	reti

; ****************************************************************************************
; boot loader jumps to here.
; ****************************************************************************************
SECTION	"start",HOME[$0100]
nop
jp	begin

; ****************************************************************************************
; ROM HEADER and ASCII character set
; ****************************************************************************************
; ROM header
	ROM_HEADER	ROM_NOMBC, ROM_SIZE_32KBYTE, RAM_SIZE_0KBYTE
INCLUDE "memory.asm"
TileData:
	chr_IBMPC1	1,8 ; LOAD ENTIRE CHARACTER SET

; ****************************************************************************************
; Main code Initialization:
; set the stack pointer, enable interrupts, set the palette, set the screen relative to the window
; copy the ASCII character table, clear the screen
; ****************************************************************************************
begin:
	nop
	di
	ld	sp, $ffff		; set the stack pointer to highest mem location + 1

; NEXT FOUR LINES FOR SETTING UP SPRITES *hs*
	call	initdma			; move routine to HRAM
	ld	a, IEF_VBLANK
	ld	[rIE],a			; ENABLE ONLY VBLANK INTERRUPT
	ei				; LET THE INTS FLY

init:
	; Init our vars
	ld	a,0
	ld	[IsJump],a
	ld	[PlayerXV],a
	ld	[PlayerYV],a

	; Setup the palletes
	ld	a, %11100100 		; Window palette colors, from darkest to lightest
	ld	[rBGP], a		; set background and window pallette
	ldh	[rOBP0],a		; set sprite pallette 0 (choose palette 0 or 1 when describing the sprite)
	ldh	[rOBP1],a		; set sprite pallette 1

	; Setup the display
	ld	a,0			; SET SCREEN TO TO UPPER RIGHT HAND CORNER
	ld	[rSCX], a
	ld	[rSCY], a
	; Load in the sprite data, killing the LCD first
	call	StopLCD			; YOU CAN NOT LOAD $8000 WITH LCD ON
	ld	hl, TileData
	ld	de, _VRAM		; $8000
	ld	bc, 8*256 		; the ASCII character set: 256 characters, each with 8 bytes of display data
	call	mem_CopyMono	; load tile data

	; Clear sprite table
	ld	a,0
	ld	hl,OAMDATALOC
	ld	bc,OAMDATALENGTH
	call	mem_Set

	; Start the LCD
	ld	a, LCDCF_ON|LCDCF_BG8000|LCDCF_BG9800|LCDCF_BGON|LCDCF_OBJ8|LCDCF_OBJON ; *hs* see gbspec.txt lines 1525-1565 and gbhw.inc lines 70-86
	ld	[rLCDC], a
	; Zero VRAM
	ld	a, 32		; ASCII FOR BLANK SPACE
	ld	hl, _SCRN0
	ld	bc, SCRN_VX_B * SCRN_VY_B
	call	mem_SetVRAM
	
sprsetup:
	; Setup first `sprite` in OAM
	PutSpriteYAddr	PCSprite,SCRN_Y-8	; set PCSprite location
	PutSpriteXAddr	PCSprite,0
 	ld	a,1		;	; ibmpc1.inc ASCII character 1 is happy face :-)
 	ld 	[PCSpriteTileNum],a      ;sprite 1's tile address
 	ld	a,%00000000         	;set flags (see gbhw.inc lines 33-42)
 	ld	[PCSpriteFlags],a        ;save flags
MainLoop:
	;di
	halt
	nop				; always put NOP after HALT (gbspec.txt lines 514-578)
	
	; Meme the PC sprite
	ld	a,[IsJump]
	inc	a
 	ld 	[PCSpriteTileNum],a      ;sprite 1's tile address	
	ld	[SpriteScratch],a
	
	ld	bc,SPEED
	call	simpleDelay
	call	GetKeys
	push	af
	and	PADF_RIGHT
	call	nz,right
	pop	af
	push	af
	and	PADF_LEFT
	call	nz,left
	pop	af
	push	af
	and	PADF_UP
	call	nz,up
	pop	af
	;push	af
	;and	PADF_DOWN
	;call	nz,down
	;pop	af
	push	af
	and	PADF_START
	call	nz,Yflip
	pop	af

	call	physics

	jr	MainLoop

; ****************************************************************************************
; Prologue
; Wait patiently 'til somebody kills you
; ****************************************************************************************
wait:
	halt
	nop
	jr	wait
	
; ****************************************************************************************
; hard-coded data
; ****************************************************************************************

left:
	ld	a,[PlayerXV]
	dec	a
	ld	[PlayerXV],a
	ret
right:
	ld	a,[PlayerXV]
	inc	a
	ld	[PlayerXV],a
	ret

physics:
	; Start with x
	;cp		SCRN_X-8	; already on RHS of screen?
	;ret		z
	ld		a,[PlayerXV]
	ld		b,a
	GetSpriteXAddr	PCSprite
	add		b
	PutSpriteXAddr	PCSprite,a
	


	; Move onto the y
	
	
	
	
	
	GetSpriteYAddr	PCSprite
	; Make sure the player's not on the ground
	cp	SCRN_Y-30
	ret	c	; If the player's below the ground, ret
	;ret	z	
	
	ld	a,[PlayerYV]
	sub	1		; Gwavity my dude
	ld	[PlayerYV],a
	ld	b,a
	GetSpriteYAddr	PCSprite
	sub	b		; Drop player based on YV	

	; Make sure the player's above ground
	cp	SCRN_Y-30
	jr	c,.yv_reset


	ld	[PCSpriteTileNum],a

	PutSpriteYAddr	PCSprite,a
	

	ret
.yv_reset:
	ld	a,SCRN_Y-30
	PutSpriteYAddr  PCSprite,a
	ld	a,0
	ld	[PlayerYV],a
	ret
	


movedown:
	GetSpriteYAddr	PCSprite
	cp		SCRN_Y-8
	ret		z
	inc		a
	PutSpriteYAddr	PCSprite,a
	ret


up:
	GetSpriteYAddr	PCSprite
	cp	SCRN_Y-8
	ret	nz			; Make sure user's on ground [LAZY]
	
	ld	a,100
	ld	[PlayerYV],a

	ret
;down:	GetSpriteYAddr	PCSprite
;	cp		SCRN_Y-8	; already at bottom of screen?
;	ret		z
;	inc		a
;	PutSpriteYAddr	PCSprite,a
;	ret
Yflip:	ld	a,[PCSpriteFlags]
	xor	OAMF_YFLIP		; toggle flip of sprite vertically
	ld	[PCSpriteFlags],a
	ret
simpleDelay:
	dec	bc
	ld	a,b
	or	c
	jr	nz, simpleDelay
	ret

; GetKeys: adapted from APOCNOW.ASM and gbspec.txt
GetKeys:                 ;gets keypress
	ld 	a,P1F_5			; set bit 5
	ld 	[rP1],a			; select P14 by setting it low. See gbspec.txt lines 1019-1095
	ld 	a,[rP1]
 	ld 	a,[rP1]			; wait a few cycles
	cpl				; complement A. "You are a very very nice Accumulator..."
	and 	$0f			; look at only the first 4 bits
	swap 	a			; move bits 3-0 into 7-4
	ld 	b,a			; and store in b

 	ld	a,P1F_4			; select P15
 	ld 	[rP1],a
	ld	a,[rP1]
	ld	a,[rP1]
	ld	a,[rP1]
	ld	a,[rP1]
	ld	a,[rP1]
	ld	a,[rP1]			; wait for the bouncing to stop
	cpl				; as before, complement...
 	and $0f				; and look only for the last 4 bits
 	or b				; combine with the previous result
 	ret				; do we need to reset joypad? (gbspec line 1082)


; *hs* START
initdma:
	ld	de, DMACODELOC
	ld	hl, dmacode
	ld	bc, dmaend-dmacode
	call	mem_CopyVRAM			; copy when VRAM is available
	ret
dmacode:
	push	af
	ld	a, OAMDATALOCBANK		; bank where OAM DATA is stored
	ldh	[rDMA], a			; Start DMA
	ld	a, $28				; 160ns
dma_wait:
	dec	a
	jr	nz, dma_wait
	pop	af
	reti
dmaend:
; *hs* END

; ****************************************************************************************
; StopLCD:
; turn off LCD if it is on
; and wait until the LCD is off
; ****************************************************************************************
StopLCD:
        ld      a,[rLCDC]
        rlca                    ; Put the high bit of LCDC into the Carry flag
        ret     nc              ; Screen is off already. Exit.

; Loop until we are in VBlank

.wait:
        ld      a,[rLY]
        cp      145             ; Is display on scan line 145 yet?
        jr      nz,.wait        ; no, keep waiting

; Turn off the LCD

        ld      a,[rLCDC]
        res     7,a             ; Reset bit 7 of LCDC
        ld      [rLCDC],a

        ret
