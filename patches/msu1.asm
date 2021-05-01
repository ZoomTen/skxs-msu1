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

; Send over the packet from RAM
	ld hl, wMSU1PacketSend
	call SendSGBPacket
	ret

MSU1SoundTemplate::
	DATA_SND $1800, $0, 5 ; 5 bytes
	db   1 ; restart flag
	dw   0 ; track number
	db $FF ; volume
	db   3 ; play mode
	ds 6,0 ; padding
