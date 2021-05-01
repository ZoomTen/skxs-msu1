include "consts/hardware.asm"
include "consts/sgb_macros.asm"

hSGB	equ $FFFE
wMSU1PacketSend equ $DE00

SECTION "Add SGB init", ROM0[$21D]
	;call $2BB8	; SRAMTest
	call SGBInitAndSRAMTest

SECTION "Redirection", ROM0[$263F]
	jp PlayMusicRedirect
	nop
PlayMusic_ORG_Continue:
	
SECTION "Bank 0 free space", ROM0[$3000]
include "patches/sgb_functions.asm"

SGBInitAndSRAMTest:
	xor a
	ldh [hSGB], a
	call .TestSGB
	jr nc, .noSGB
	ld a, 1
	ldh [hSGB],a 
	call .PushBootstrap
.noSGB
	jp $2BB8

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
	jr nz, .push_bootstrap
	ld hl, JumpToMSU1EntryPoint	; execute MSU1 init
	jp SendSGBPacket

MltReq1Packet: MLT_REQ 1
MltReq2Packet: MLT_REQ 2
JumpToMSU1EntryPoint:: JUMP $1810, 0, 0, 0

PlayMusicRedirect:
; @a = music to play
	cp $53
	jp c, $2677
	
	ld a, [hSGB]
	and a
	jr nz, .doSGB
	
	ld a, e
	jp $2643

.doSGB
	ld a, e
	cp 89
	jp c, $2643
	sub 89
	inc a
	call MSU1_EntryPoint
	ret

include "patches/msu1.asm"
include "patches/msu1/_bootstrap.asm"
