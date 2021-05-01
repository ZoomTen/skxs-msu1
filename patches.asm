include "consts/hardware.asm"
include "consts/sgb_macros.asm"
include "consts/equ.asm"

SECTION "Add SGB init", ROM0[$21D]
	call SGBInitAndSRAMTest

SECTION "Redirection", ROM0[$263F]
	jp PlayMusicRedirect
	nop
PlayMusic_ORG_Continue:

SECTION "Bank 0 free space", ROM0[$3000]
include "patches/sgb_functions.asm"
include "patches/sgb_init.asm"
include "patches/play_music.asm"
include "patches/msu1.asm"
include "patches/msu1/_bootstrap.asm"
