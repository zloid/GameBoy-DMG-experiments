INCLUDE "hardware.inc"
  INCLUDE "header.asm"
	INCLUDE "tiles.asm"
     INCLUDE "map.asm"

SECTION "Program Start",ROM0[$150]
START:
; =======================rLCDC off========================================
	call LCD_OFF
	
	ei				 ;enable interrupts
	ld  sp,$FFFE
	ld  a,IEF_VBLANK ;enable vblank interrupt
	ld  [rIE],a	

	call CLEAR_TILE_MAP
	call LOAD_TILES
	call LOAD_TILE_MAP
	call CLEAR_OAM
;========================================================================
	call CLEAR_RAM
	call INIT_PLAYER
	; call INIT_TIMERS		
; ======================rLCDC on=========================================	 
	call LCD_ON
	call DMA_COPY    	;move DMA routine to HRAM

LOOP:
	call WAIT_VBLANK	
	call READ_JOYPAD
	call MOVE_PLAYER
	call _HRAM		 ;call DMA routine from HRAM
	jp LOOP
 
;-------------
; Subroutines
;-------------
LCD_OFF:

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
	ld  hl,vblank_flag; ?copy to HL register?
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

; CLEAR_OAM:
; 	ld  hl,_OAMRAM  
; 	ld  b,160		;$a0 == 160 byte in OAM
; .clear_oam_loop
; 	ld  a,0	 	
; 	ld  [hli],a		
; 	dec b			
; 	ld  a,b			
; 	jr  nz,.clear_oam_loop
; 	ret			

CLEAR_OAM:
  ld  hl,_OAMRAM
  ld  bc,$A0
.clear_oam_loop
  ld  a,$0
  ld  [hli],a
  dec bc
  ld  a,b
  or  c
  jr  nz,.clear_oam_loop
  ret
;========================TEST====================================
CLEAR_RAM:
  ld  hl,$C100
  ld  bc,$A0
.clear_ram_loop
  ld  a,$0
  ld  [hli],a
  dec bc
  ld  a,b
  or  c
  jr  nz,.clear_ram_loop
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

;=================================================================================
INIT_TIMERS:
	ld a,$0
	ld [player_frame_time],a
	; ld [crop_count],a
	; ld [player_update_time],a
	; ld a,$9
	ret

READ_JOYPAD:
	ld  a,%00100000  ;select dpad
	ld  [rP1],a
	ld  a,[rP1]		 ;takes a few cycles to get accurate reading
	ld  a,[rP1]
	ld  a,[rP1]
	ld  a,[rP1]
	cpl 			 ;complement a
	and %00001111    ;select dpad buttons
	swap a
	ld  b,a

	ld  a,%00010000  ;select other buttons
	ld  [rP1],a  
	ld  a,[rP1]
	ld  a,[rP1]
	ld  a,[rP1]
	ld  a,[rP1]
	cpl
	and %00001111
	or  b
					 ;lower nybble is other
	ld  b,a
	ld  a,[joypad_down]
	cpl
	and b
	ld  [joypad_pressed],a
					 ;upper nybble is dpad
	ld  a,b
	ld  [joypad_down],a
	ret

JOY_RIGHT:
	and %00010000
	cp  %00010000
	jp  nz,JOY_FALSE
	ld  a,$1
	ret
JOY_LEFT:
	and %00100000
	cp  %00100000
	jp  nz,JOY_FALSE
	ld  a,$1
	ret
JOY_UP:
	and %01000000
	cp  %01000000
	jp  nz,JOY_FALSE
	ld  a,$1
	ret
JOY_DOWN:
	and %10000000
	cp  %10000000
	jp  nz,JOY_FALSE
	ld  a,$1
	ret
JOY_A:
	and %00000001
	cp  %00000001
	jp  nz,JOY_FALSE
	ld  a,$1
	ret
JOY_B:
	and %00000010
	cp  %00000010
	jp  nz,JOY_FALSE
	ld  a,$1
	ret
JOY_SELECT:
	and %00000100
	cp  %00000100
	jp  nz,JOY_FALSE
	ld  a,$1
	ret
JOY_START:
	and %00001000
	cp  %00001000
	jp  nz,JOY_FALSE
	ld  a,$1
	ret
JOY_FALSE:
	ld  a,$0
	ret
	

INIT_PLAYER:
	ld  a,$50
	ld  [player_x],a
	ld  [player_y],a
	; ld  [crop_x],a
	; ld  [crop_y],a
	ld  a,$2
	ld  [player_tile],a
	; ld  a,$6
	; ld  [bullet_tile],a
	ld  a,$0
	ld  [player_flags],a
	; ld  [bullet_flags],a
	; ld  [bullet_x],a
	; ld  [bullet_y],a
	; ld  [bullet_reset],a
	; ld  [blood_count_flags],a
	; ld  [crop_flags],a
	; ld  [crop_count_flags],a

	; ld  a,$B
	; ld  [crop_tile],a

	; ld  a,152
	; ld  [crop_count_y],a
	; ld  a,105
	; ld  [crop_count_x],a

	; ld  a,$98
	; ld  [blood_count_y],a
	; ld  a,$31
	; ld  [blood_count_x],a
	; ld  a,$15
	; ld  [blood_count_tile],a
	; ld  [crop_count_tile],a
	ret

MOVE_PLAYER:
	ld  a,[player_frame_time] ;animate player tile
	cp  $8
	jr  nz,.move_speed
	ld  a,$0
	ld  [player_frame_time],a
	ld  a,[player_tile]
	inc a
	cp  $6
	jr  z,.tile_reset

	ld  b,a
	ld  a,[joypad_down]       ;dpad pressed? 
	and %11110000
	jr  z,.tile_reset

	ld  a,b
	ld  [player_tile],a
.move_speed
	ld  a,[vblank_count]
	cp  $1
	jp  nz,.move_done
	ld  a,$0
	ld  [vblank_count],a
	jp  .move_right
.tile_reset
	ld  a,$4
	ld  [player_tile],a
	jp .move_speed
.move_right
	ld  a,[player_x] 		   ;right bound
	cp  $A0
	jr  z,.move_left

	ld  a,[joypad_down]
	call JOY_RIGHT
	jr  nz,.move_left
	ld  a,[player_x]
	inc a
	ld  [player_x],a

	ld  a,[player_flags]        ;flip tile
	res 5,a
	ld  [player_flags],a
.move_left
	ld  a,[player_x]			;left bound
	cp  $8
	jr  z,.move_up

	ld  a,[joypad_down]
	call JOY_LEFT
	jr  nz,.move_up
	ld  a,[player_x]
	dec a
	ld  [player_x],a

	ld  a,[player_flags]        ;flip tile
	set 5,a
	ld  [player_flags],a
.move_up
	ld  a,[player_y] 			;up bound
	cp  $10
	jr  z,.move_down

	ld  a,[joypad_down]
	call JOY_UP
	jr  nz,.move_down
	ld  a,[player_y]
	dec a
	ld  [player_y],a
.move_down
	ld  a,[player_y] 			;left bound
	cp  $90
	jr  z,.move_done

	ld  a,[joypad_down]
	call JOY_DOWN
	jr  nz,.move_done
	ld  a,[player_y]
	inc a
	ld  [player_y],a
.move_done
	ret

;-------------
; RAM Vars
;-------------
; $D2 == 210
SECTION "RAM Vars",WRAM0[$C000]
vblank_flag: 
db
rabbit_spawn_time:
db
vblank_count:
db
joypad_down:
db 				     			 ;dow/up/lef/rig/sta/sel/a/b
joypad_pressed:
db
player_frame_time:
db
; player_update_time:
; db
; crop_count:
; db

SECTION "RAM OAM Vars",WRAM0[$C100]
player_y:
db
player_x:
db
player_tile:
db
player_flags:
db
; crop_y:
; db
; crop_x:
; db
; crop_tile:
; db
; crop_flags:
; db
; crop_count_y:
; db
; crop_count_x:
; db
  								 
;-------------
; End of file
;-------------