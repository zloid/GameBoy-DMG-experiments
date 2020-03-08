;***************************************************************************
;* BOILERPLATE SECTION
;***************************************************************************
INCLUDE "features/boilerplate/constants/hardware.inc"
INCLUDE "features/boilerplate/header/header.asm"
INCLUDE "features/boilerplate/define_and_ram_oam_vars.asm"
;***************************************************************************
;* DEFINE SECTION - ROM0[$150] memory adress
;***************************************************************************
;======1======
INCLUDE "features/boilerplate/constants/PROGRAM_START_ROM0_$150.asm"
INCLUDE "features/boilerplate/ROM0_$150/main_functions.asm"
INCLUDE "features/boilerplate/ROM0_$150/ss.asm"

INCLUDE "features/showTiles/ROM0/mapZ.asm"
;======2======
; INCLUDE "features/showTiles/ROM0_$150/main_functions.asm"
;***************************************************************************
;* MAIN LOOP SECTION
;***************************************************************************
INCLUDE "features/boilerplate/call_before_main_game_loop.asm"
MAIN_GAME_LOOP:
	call WAIT_VBLANK
	call SS	 
	jp MAIN_GAME_LOOP