INCLUDE "hardware.inc"
INCLUDE "header.asm"
INCLUDE "tiles.asm"
INCLUDE "map.asm"

SECTION "Game Start",ROM0[$150];put code in bank0 HOME memory on [$150] adress
START:
	ei				;enable interrupts, for read input buttons in future
	ld  sp,$FFFE	;sp is the CPU's implementation of the stack concept. It's a 16-bit register that points to the top of the stack.
	ld  a,IEF_VBLANK;enable vblank interrupt, meaning put %00000001 to A register
	ld  [rIE],a		;put A to [rIE], meaning value at i/o IE memory adress [$FFFF] become %00000001 (according to hardware.inc), now V-Blank interrupts can be catch 60 time in second

;todo
.waitVBlank		 	;loop
	ld a, [rLY]		
	cp 144 			 ;Check if the LCD is past VBlank, meaning ComPare A and 144 number
	jr c, .waitVBlank;if previous Comparison is TRUE then execute code next (below), else go to right local label .waitVBlank, meaning do looping
	ld  a,0			;for off LCD we need to reset bit 7, (xor A)
	ldh [rLCDC],a 	;LCD off
	ldh [rSTAT],a

	ld  a,%11100100  ;shade palette (11 10 01 00)
	ldh [rBGP],a 	 ;setup palettes
	ldh [rOCPD],a
	ldh [rOBP0],a

	; call CLEAR_MAP;	clear nintendo logo
	; call LOAD_TILES;load tiles
	; call LOAD_MAP	;load tiles map, meaning how tiles located on screen
	; call INIT_PLAYER
	; call INIT_RABBITS
	; call INIT_TIMERS

	ld  a,%11010011  ;turn on LCD, BG0, OBJ0, etc
	ldh [rLCDC],a    ;load LCD flags

	; call DMA_COPY    ;move DMA routine to HRAM
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



CLEAR_MAP:			;clear NINTENDO start logo
	ld  hl,_SCRN0    ;load map0 ram
	ld  bc,$400
.clear_map_loop
	ld  a,$0
	ld  [hli],a      ;clear tile, increment hl
	dec bc
	ld  a,b
	or  c
	jr  nz,.clear_map_loop
	ret

LOAD_TILES:
	ld  hl,TILE_DATA
	ld  de,_VRAM
	ld  bc,TILE_COUNT; in tiles.asm
.load_tiles_loop
	ld  a,[hli]      ;grab a byte
	ld  [de],a       ;store the byte in VRAM
	inc de
	dec bc
	ld  a,b
	or  c
	jr  nz,.load_tiles_loop
	ret

LOAD_MAP:
	ld  hl,MAP_DATA  ;same as LOAD_TILES
	ld  de,_SCRN0
	ld  bc,$400
.load_map_loop
	ld  a,[hli]
	ld  [de],a
	inc de
	dec bc
	ld  a,b
	or  c
	jr  nz,.load_map_loop
	ret

;-------------
; RAM Vars
;-------------

SECTION "RAM Vars",WRAM0[$C000]
vblank_flag:
db