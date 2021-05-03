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
	rendered/01_hometown.flac \
	rendered/03_trouble.flac \
	rendered/11_crossroads.flac \
	rendered/23_title.flac \
	rendered/10_rocky.flac

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

rendered/%.flac: flp/%.flp
	WINEPREFIX="$(WINEPREFIX)" $(WINE) "$(FLSTUDIO)" \
		/r /eflac "$(WINEPWD)\\$(subst /,\\,$<)" >/dev/null 2>&1
	mv $(subst .flp,.flac,$<) $@

msu1/skxs_msu1.msu: $(MSUCONFIG) $(SOUND) $(EXT_FLAC)
	for i in external_flac/*.flac; do \
		[ -f "$$i" ] || continue; \
		cp -f $$i rendered; \
	done
	mkdir -p msu1
	$(WINE) $(MSUPCM) $< 2>/dev/null
	touch msu1/skxs_msu1.msu

clean:
	rm -f flp/*.flac
	rm -rf rendered msu1
