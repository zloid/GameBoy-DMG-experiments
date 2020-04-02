; each module-block (features) must go in own location (BOILERPLATE_TOP, ROM0, CALL_BEFORE_MAIN_GAME_LOOP, MAIN_GAME_LOOP) 
; at order: ==0==, ==1==, ==2==, next order, etc. 
;***************************************************************************
;* BOILERPLATE_TOP
;***************************************************************************
;======0======
INCLUDE "features/boilerplate/constants/hardware.inc"
INCLUDE "features/boilerplate/header/header.asm"
INCLUDE "features/boilerplate/define_and_ram_oam_vars.asm"
;***************************************************************************
;* ROM0
;***************************************************************************
;======0======
INCLUDE "features/boilerplate/ROM0/0-PROGRAM_START_ROM0_$150.asm"
INCLUDE "features/boilerplate/ROM0/main_functions.asm"
;======1======
; inside each block must be order: 0-..., 1-..., 2-..., etc.
; after numbered goes random order: 0-..., 1-..., 2-..., "without number" 
INCLUDE "features/showTiles/ROM0/0-map.asm"
INCLUDE "features/showTiles/ROM0/1-tiles.asm"
INCLUDE "features/showTiles/ROM0/main_functions.asm"
;======2======
; ... next feature module ...
;======3======
; ... next feature module ...
;***************************************************************************
;* CALL_BEFORE_MAIN_GAME_LOOP
;***************************************************************************
;======0======
INCLUDE "features/boilerplate/call_before_main_game_loop/call_before_main_game_loop.asm"
;======1======
INCLUDE "features/showTiles/call_before_main_game_loop/call_before_main_game_loop.asm"
;======2======
; ... next feature module ...
;======3======
; ... next feature module ...
;***************************************************************************
MAIN_GAME_LOOP:
;***************************************************************************
	;======0======
	call WAIT_VBLANK
	;======1======
	; ... next feature module ...
	;======2======
	; ... next feature module ...
;***************************************************************************
	; jump to start of this loop, don't touch this
	jp MAIN_GAME_LOOP
;***************************************************************************	
