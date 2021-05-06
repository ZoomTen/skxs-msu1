MSU1_EntryPoint:
; @a = Music ID to play
	ld b, a
	ld c,  SGB_PACKET_SIZE
	ld hl, MSU1SoundTemplate
	ld de, wMSU1PacketSend
.copy_template
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, .copy_template

; Insert the song ID into the packet template
	ld a, b
	ld [wMSU1PacketSend + 6], a

; There's only a few non-looping music, so
; we can handle the lack of LUTs
	cp 29
	jr z, .no_loop
	cp 28
	jr z, .no_loop
	cp 27
	jr z, .no_loop
	cp 20
	jr z, .no_loop
	cp 19
	jr z, .no_loop
	cp 18
	jr z, .no_loop

.okay
; Send over the packet from RAM
	ld hl, wMSU1PacketSend
	call SendSGBPacket
	ret

.no_loop
	ld a, 1
	ld [wMSU1PacketSend + 9], a
	jr .okay

MSU1SoundTemplate::
	DATA_SND $1800, $0, 5 ; 5 bytes
	db   1 ; restart flag
	dw   0 ; track number
	db $FF ; volume
	db   3 ; play mode
	ds 6,0 ; padding
