INCLUDE "hardware.inc"
  INCLUDE "header.asm"
	INCLUDE "tiles.asm"
     INCLUDE "map.asm"

SECTION "Program Start",ROM0[$150]
START:
; =======================rLCDC off========================================
	call LCD_OFF
	call CLEAR_TILE_MAP
	call LOAD_TILES
	call LOAD_TILE_MAP

	call CLEAR_OAM		;test fun
; ======================rLCDC on=========================================
	call LCD_ON
	call DMA_COPY    	;move DMA routine to HRAM

LOOP:
	call WAIT_VBLANK
	; call READ_JOYPAD
	call _HRAM		 ;call DMA routine from HRAM
	jp LOOP

;-------------
; Subroutines
;-------------
LCD_OFF:
di
	; ei				 ;enable interrupts
	; ld  sp,$FFFE
	; ld  a,IEF_VBLANK ;enable vblank interrupt
	; ld  [rIE],a	
.waitVBlank
    ld a, [rLY]
    cp 144 ; Check if the LCD is past VBlank
    jr c, .waitVBlank

	ld  a,$0
	ldh [rLCDC],a 	 ;LCD off
	ldh [rSTAT],a

	ld  a,%11100100  ;shade palette (11 10 01 00)
	ldh [rBGP],a 	 ;setup palettes
	ldh [rOCPD],a
	ldh [rOBP0],a
	ret

LCD_ON:
	; ld a, %11100100
    ; ld [rBGP], a
	ld  a,%11010011  ;turn on LCD, BG0, OBJ0, etc
	; ld  a,%1000001  ;turn on LCD, BG0, OBJ0, etc
	ldh [rLCDC],a    ;load LCD flags
	ret

WAIT_VBLANK:
	ld  hl,VBLANK_FLAG; ?copy 16 bit to HL register?
.wait_vblank_loop
	halt
	nop  			 ;Hardware bug
	ld  a,$0
	cp  [hl]
	jr  z,.wait_vblank_loop
	ld  [hl],a
	ld  a,[vblank_count]
	inc a
	ld  [vblank_count],a
	ret

DMA_COPY:
	ld  de,$FF80  	 ;DMA routine, gets placed in HRAM 
	rst $28
	DB  $00,$0D
	DB  $F5, $3E, $C1, $EA, $46, $FF, $3E, $28, $3D, $20, $FD, $F1, $D9
	ret

CLEAR_TILE_MAP:			;tilemap function
	; ld  hl,$8000	;test only
	ld  hl,_SCRN0   ;load map0 ram (locate in VRAM), _SCRN0 EQU $9800 ; $9800->$9BFF ; tilemap one at $9800-$9BFF ; HL == $9800
	ld  bc,$400	 	;??? BC == $400. Maybe B == $40  C == $0
.clear_map_loop
	ld  a,$0	 	;A == 0
	ld  [hli],a		;clear tile (actually clear 1 HEX adress of tilemap first ), meaning put 0 to HL-memory adress _SCRN0, then do increment HL by one, 
	dec bc			;??? incrementing and decrementing is addition and subtraction by one. Meaning $400 - $1 = $3ff
	ld  a,b			;load B to A. Mean  	
	or  c			;
	jr  nz,.clear_map_loop
	ret			
;============================================================
; CLEAR_MAP_2:
; 	ld hl,_SCRN0	
; 	ld bc,$3ff		;numbers of byte in _SCRN0 tile-map0, we can put $400
CLEAR_OAM:
	ld  hl,_OAMRAM  
	ld  bc,160		;$a0 == 160 byte in OAM
.clear_oam_loop
	ld  a,0	 	
	ld  [hli],a		
	dec bc			
	ld  a,b			
	or  c			
	jr  nz,.clear_oam_loop
	ret			
;============================================================
LOAD_TILES:
	ld  hl,TILE_DATA
	ld  de,_VRAM
	ld  bc,TILE_COUNT
.load_tiles_loop
	ld  a,[hli]      ;grab a byte
	ld  [de],a       ;store the byte in VRAM
	inc de
	dec bc
	ld  a,b
	or  c
	jr  nz,.load_tiles_loop
	ret

LOAD_TILE_MAP:
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

; READ_JOYPAD:
; 	ld  a,%00100000  ;select dpad
; 	ld  [rP1],a
; 	ld  a,[rP1]		 ;takes a few cycles to get accurate reading
; 	ld  a,[rP1]
; 	ld  a,[rP1]
; 	ld  a,[rP1]
; 	cpl 			 ;complement a
; 	and %00001111    ;select dpad buttons
; 	swap a
; 	ld  b,a

; 	ld  a,%00010000  ;select other buttons
; 	ld  [rP1],a  
; 	ld  a,[rP1]
; 	ld  a,[rP1]
; 	ld  a,[rP1]
; 	ld  a,[rP1]
; 	cpl
; 	and %00001111
; 	or  b
; 					 ;lower nybble is other
; 	ld  b,a
; 	ld  a,[joypad_down]
; 	cpl
; 	and b
; 	ld  [joypad_pressed],a
; 					 ;upper nybble is dpad
; 	ld  a,b
; 	ld  [joypad_down],a
; 	ret

; JOY_RIGHT:
; 	and %00010000
; 	cp  %00010000
; 	jp  nz,JOY_FALSE
; 	ld  a,$1
; 	ret
; JOY_LEFT:
; 	and %00100000
; 	cp  %00100000
; 	jp  nz,JOY_FALSE
; 	ld  a,$1
; 	ret
; JOY_UP:
; 	and %01000000
; 	cp  %01000000
; 	jp  nz,JOY_FALSE
; 	ld  a,$1
; 	ret
; JOY_DOWN:
; 	and %10000000
; 	cp  %10000000
; 	jp  nz,JOY_FALSE
; 	ld  a,$1
; 	ret
; JOY_A:
; 	and %00000001
; 	cp  %00000001
; 	jp  nz,JOY_FALSE
; 	ld  a,$1
; 	ret
; JOY_B:
; 	and %00000010
; 	cp  %00000010
; 	jp  nz,JOY_FALSE
; 	ld  a,$1
; 	ret
; JOY_SELECT:
; 	and %00000100
; 	cp  %00000100
; 	jp  nz,JOY_FALSE
; 	ld  a,$1
; 	ret
; JOY_START:
; 	and %00001000
; 	cp  %00001000
; 	jp  nz,JOY_FALSE
; 	ld  a,$1
; 	ret
; JOY_FALSE:
; 	ld  a,$0
; 	ret

SECTION "RAM Vars",WRAM0[$C000]
VBLANK_FLAG:
db 
vblank_count:
db
joypad_down:
db                   ;dow/up/lef/rig/sta/sel/a/b
joypad_pressed:
db

