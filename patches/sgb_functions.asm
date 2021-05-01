; Taken from pokered
SendSGBPacket:
; hl = SGB packet to transfer
	ld a, [hl]
	and %00000111
	ret z

	ld b, a
.loop2
	push bc
	xor a
	ldh [rJOYP], a
	ld a, $30
	ldh [rJOYP], a
	ld b, $10
.nextByte
	ld e, $08
	ld a, [hli]
	ld d, a
.nextBit0
	bit 0, d
	ld a, $10
	jr nz, .next0
	ld a, $20
.next0
	ldh [rJOYP], a
	ld a, $30
	ldh [rJOYP], a
	rr d
	dec e
	jr nz, .nextBit0
	dec b
	jr nz, .nextByte
	ld a, $20
	ldh [rJOYP], a
	ld a, $30
	ldh [rJOYP], a
	call Wait7000
	pop bc
	dec b
	ret z
	jr .loop2

Wait7000:
; waits about 7000 cycles before sending the next command
	ld de, 7000/9
.loop
	nop
	nop
	nop
	dec de
	ld a, d
	or e
	jr nz, .loop
	ret
