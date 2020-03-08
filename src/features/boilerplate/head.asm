; =======================CALL SECTION========================================
START:
; =======================rLCDC off========================================
	call LCD_OFF

	ei				 ;enable interrupts
	ld  sp,$FFFE
	ld  a,IEF_VBLANK ;enable vblank interrupt
	ld  [rIE],a

	call CLEAR_TILE_MAP
	; call LOAD_TILES
	; call LOAD_TILE_MAP
	call CLEAR_OAM
;========================================================================
	call CLEAR_RAM
	; call INIT_PLAYER
; ======================rLCDC on=========================================
	call LCD_ON
	call DMA_COPY    	;move DMA routine to HRAM

