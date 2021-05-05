SGBInitAndSRAMTest:
	xor a
	ldh [hSGB], a
	call .TestSGB
	jr nc, .noSGB
	ld a, 1
	ldh [hSGB],a
	call .PushBootstrap
.noSGB
	jp $2BB8 ; SRAMTest

.TestSGB:
; from pokegold
	ld hl, MltReq2Packet
	call SendSGBPacket
	call Wait7000
	ldh a, [rJOYP]
	and %11
	cp %11
	jr nz, .has_sgb

	ld a, $20
	ldh [rJOYP], a
	ldh a, [rJOYP]
	ldh a, [rJOYP]
	call Wait7000
	call Wait7000
	ld a, $30
	ldh [rJOYP], a
	call Wait7000
	call Wait7000
	ld a, $10
	ldh [rJOYP], a
rept 6
	ldh a, [rJOYP]
endr
	call Wait7000
	call Wait7000
	ld a, $30
	ldh [rJOYP], a
	ldh a, [rJOYP]
	ldh a, [rJOYP]
	ldh a, [rJOYP]
	call Wait7000
	call Wait7000

	ldh a, [rJOYP]
	and %11
	cp %11
	jr nz, .has_sgb

	call .done
	and a
	ret

.has_sgb
	call .done
	scf
	ret

.done
	ld hl, MltReq1Packet
	call SendSGBPacket
	jp Wait7000

.PushBootstrap:
	ld hl, Packets_bootstrap
	ld c, [hl]	; amount of packets to send
	inc hl
.push_bootstrap
	call SendSGBPacket
	dec c
	ret z
	jr .push_bootstrap

MSU1_Init:
	ld hl, JumpToMSU1EntryPoint	; execute MSU1 init
	jp SendSGBPacket

MltReq1Packet: MLT_REQ 1
MltReq2Packet: MLT_REQ 2
JumpToMSU1EntryPoint:: JUMP $1810, 0, 0, 0

