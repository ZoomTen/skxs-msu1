PlayMusicRedirect:
; @a = music to play

; If SFX, run it on Gameboy
	cp $53
	jp c, $2677

	ld a, [hSGB]
	and a
	jr nz, .doSGB

; Run Gameboy music if not on SGB
	ld a, e
	jp $2643

.doSGB
	ld a, e
	cp 89
	jp c, $2643
	sub 89
	inc a
	jp MSU1_EntryPoint
