;***************************************************************************
;* BOILERPLATE TOP
;***************************************************************************
INCLUDE "features/boilerplate/constants/hardware.inc"
INCLUDE "features/boilerplate/header/header.asm"
INCLUDE "features/boilerplate/define_and_ram_oam_vars.asm"
;***************************************************************************
;* ROM0
;***************************************************************************
;======1======
INCLUDE "features/boilerplate/ROM0/0-PROGRAM_START_ROM0_$150.asm"
INCLUDE "features/boilerplate/ROM0/main_functions.asm"
;======2======
INCLUDE "features/showTiles/ROM0/0-map.asm"
INCLUDE "features/showTiles/ROM0/1-tiles.asm"
INCLUDE "features/showTiles/ROM0/main_functions.asm"
;***************************************************************************
;* MAIN LOOP
;***************************************************************************
INCLUDE "features/boilerplate/call_before_main_game_loop/call_before_main_game_loop.asm"
INCLUDE "features/showTiles/call_before_main_game_loop/call_before_main_game_loop.asm"
MAIN_GAME_LOOP:
	call WAIT_VBLANK
	jp MAIN_GAME_LOOP

