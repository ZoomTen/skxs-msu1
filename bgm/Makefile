# Wine variables should be empty when building on Windows
WINE ?= /usr/bin/wine
WINEPREFIX ?= /home/zumid/_old_home/.PlayOnLinux/wineprefix/FLS12

# This is the drive letter that points to /.
WINEDRIVELETTER := R

WINEPWD := $(subst /,\\,$(WINEDRIVELETTER):$(shell pwd))

FLSTUDIO := C:/Program Files (x86)/Image-Line/FL Studio 12/FL.exe
MSUPCM := ../tools/msupcm.exe

MSUCONFIG := pcm.json

SOUND := \
	rendered/01_hometown.wav \
	rendered/03_trouble.wav \
	rendered/11_crossroads.wav \
	rendered/23_title.wav \
	rendered/10_rocky.wav \
	rendered/21_intro.wav \
	rendered/13_academic.wav \
	rendered/08_town1.wav \
	rendered/12_observing.wav \
	rendered/16_racing.wav \
	rendered/22_scrapyard.wav \
	rendered/18_level_up_fanfare.wav \
	rendered/19_got_exp_fanfare.wav \
	rendered/20_monster_defeat_fanfare.wav \
	rendered/17_meteor_shower.wav

EXT_FLAC := $(shell find external_flac -type f -iname "*.flac")

.PHONY: all preamble copy

all: preamble msu1/skxs_msu1.msu

preamble:
	mkdir -p rendered
	@echo '    ----------------------------------------'
	@echo '    -   This Makefile will automatically   -'
	@echo '    -     build for FL Studio v12.5+       -'
	@echo '    ----------------------------------------'
	@echo '    - WARNING: THIS WILL OPEN THE FL GUI!! -'
	@echo '    ----------------------------------------'
	@echo '    - WARNING: Please CLOSE any FL Studio  -'
	@echo '    -          windows currently open.     -'
	@echo '    ----------------------------------------'
	@echo '    - Make sure you have Edirol Orchestral -'
	@echo '    -  and SGM v2.01 soundfont installed   -'
	@echo '    -  and accessible by FL Studio first!! -'
	@echo '    ----------------------------------------'

rendered/%.wav: flp/%.flp
	WINEPREFIX="$(WINEPREFIX)" $(WINE) "$(FLSTUDIO)" \
		/r /ewav "$(WINEPWD)\\$(subst /,\\,$<)" >/dev/null 2>&1
	mv $(subst .flp,.wav,$<) $@

msu1/skxs_msu1.msu: $(MSUCONFIG) $(SOUND) $(EXT_FLAC)
	for i in external_flac/*.flac; do \
		[ -f "$$i" ] || continue; \
		cp -f $$i rendered; \
	done
	mkdir -p msu1
	$(WINE) $(MSUPCM) $< 2>/dev/null
	touch msu1/skxs_msu1.msu

clean:
	rm -f flp/*.wav
	rm -rf rendered msu1
