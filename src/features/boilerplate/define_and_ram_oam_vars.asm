;-------------
; RAM Vars
;-------------

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

SECTION "RAM OAM Vars",WRAM0[$C100]
player_y:
db
player_x:
db
player_tile:
db
player_flags:
db



