SGB_PACKET_SIZE equ $10

MSU1_EntryPoint:
; a should contain the song ID by now
	;di
	;push af
	;push de
	;push bc
	;push hl
	;call Wait7000
	
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
	
	ld a, b	; restore song ID 
	ld [wMSU1PacketSend + 6], a ; set song number
	
	ld hl, wMSU1PacketSend
	call SendSGBPacket
	
	;pop hl
	;pop bc
	;pop de
	;pop af
	ret;i

MSU1SoundTemplate::
	DATA_SND $1800, $0, 5 ; 5 bytes
	db   1 ; restart flag
	dw   0 ; track number
	db $FF ; volume
	db   3 ; play mode
	ds 6,0 ; padding
