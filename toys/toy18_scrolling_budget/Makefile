CA65 = /opt/homebrew/bin/ca65
LD65 = /opt/homebrew/bin/ld65
PNG2CHR = ../../tools/png2chr.pl

ASM_SRC = scroll.s
CFG_FILE = nes.cfg
ROM = scroll.nes
OBJ = scroll.o
DBG = scroll.dbg
CHR = tiles.chr
PNG = tiles.png

CA65_FLAGS = -g
LD65_FLAGS = --dbgfile $(DBG)

all: $(ROM)

$(CHR): $(PNG) $(PNG2CHR)
	$(PNG2CHR) $< $@

$(OBJ): $(ASM_SRC) $(CHR)
	$(CA65) $(CA65_FLAGS) $< -o $@

$(ROM): $(OBJ) $(CFG_FILE)
	$(LD65) $(OBJ) -C $(CFG_FILE) -o $@ $(LD65_FLAGS)

clean:
	rm -f $(OBJ) $(ROM) $(DBG) $(CHR) *.lst

test: $(ROM)
	prove -v t/

.PHONY: all clean test
