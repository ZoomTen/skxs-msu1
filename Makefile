.SUFFIXES:
.SECONDEXPANSION:
.PRECIOUS: %.gbc
.SECONDARY:
.PHONY: all clean


# tools
FLIPS ?= tools/flips/flips

RGBDS ?= /usr/bin
ASM   ?= $(RGBDS)/rgbasm
LINK  ?= $(RGBDS)/rgblink
FIX   ?= $(RGBDS)/rgbfix

ASM_FLAGS := -h -L -Weverything


# pseudo targets
patches := skxs_msu1.bps
all: $(patches)

clean:
	rm -f $(patches) $(patches:.bps=.gbc) $(patches:.bps=.map) $(patches:.bps=.sym) patch.o
	$(MAKE) clean -C patches/msu1/


# general rules
patch.o: patches/msu1/_bootstrap.asm patches.asm patches/*
	$(ASM) $(ASM_FLAGS) -o $@ patches.asm

skxs_msu1.gbc: patch.o
	$(LINK) -m skxs_msu1.map -n skxs_msu1.sym -O baserom.gbc -o $@ $^
	$(FIX) -l 0x33 -s -v $@

skxs_msu1.bps: skxs_msu1.gbc
	$(FLIPS) --create --bps-delta baserom.gbc $^ $@

patches/msu1/_bootstrap.asm: patches/msu1/snes/bootstrap.asm
	$(MAKE) -C patches/msu1/
