; ==============feature #1 boilerplate==============

INCLUDE "features/boilerplate/constants/hardware.inc"
INCLUDE "features/boilerplate/header/header.asm"
; INCLUDE "features/boilerplate/tiles/tiles.asm"
; INCLUDE "features/boilerplate/map/map.asm"
; INCLUDE "features/boilerplate/index.asm"

; ==============ram_oam_vars SECTION==============
INCLUDE "features/boilerplate/head.asm"

MAIN_GAME_LOOP:
	call WAIT_VBLANK
    
	 
	jp MAIN_GAME_LOOP
  
INCLUDE "features/boilerplate/define_and_ram_oam_vars.asm"