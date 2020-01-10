INCLUDE "hardware.inc"
INCLUDE "header.asm"

SECTION "Program Start",ROMO[$150]
START:
	ei				 ;enable interrupts
	ld  sp,$FFFE	 ; sp is the CPU's implementation of the stack concept. It's a 16-bit register that points to the top of the stack.
	ld  a,IEF_VBLANK ;enable vblank interrupt
	ld  [rIE],a

	ld  a,$0
	ldh [rLCDC],a 	 ;LCD off
	ldh [rSTAT],a

	ld  a,%11100100  ;shade palette (11 10 01 00)
	ldh [rBGP],a 	 ;setup palettes
	ldh [rOCPD],a
	ldh [rOBP0],a

	call CLEAR_MAP
	call LOAD_TILES
	call LOAD_MAP
	call INIT_PLAYER
	call INIT_RABBITS
	call INIT_TIMERS

	ld  a,%11010011  ;turn on LCD, BG0, OBJ0, etc
	ldh [rLCDC],a    ;load LCD flags

	call DMA_COPY    ;move DMA routine to HRAM
LOOP:
	; call WAIT_VBLANK
	; call READ_JOYPAD
	; call MOVE_PLAYER
	; call PLAYER_SHOOT
	; call UPDATE_BULLET
	; call SPAWN_RABBITS
	; call ANIMATE_RABBITS
	; call UPDATE_RABBITS
	; call UPDATE_PLAYER
	; call PLAYER_WATER
	; call _HRAM		 ;call DMA routine from HRAM
	jp LOOP
