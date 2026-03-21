# Makefile for tiles - NES ROM build
# PNG → CHR → NES pipeline

# Paths (macOS Homebrew cc65)
CA65 = /opt/homebrew/bin/ca65
LD65 = /opt/homebrew/bin/ld65
PNG2CHR = ../../tools/png2chr.pl

# Source files
ASM_SRC = tiles.s
CFG_FILE = nes.cfg
ROM = tiles.nes
OBJ = tiles.o
DBG = tiles.dbg
CHR = tiles.chr
PNG = tiles.png

# Build flags
CA65_FLAGS = -g
LD65_FLAGS = --dbgfile $(DBG)

all: $(ROM)

# PNG → CHR conversion
$(CHR): $(PNG) $(PNG2CHR)
	$(PNG2CHR) $< $@

$(OBJ): $(ASM_SRC) $(CHR)
	$(CA65) $(CA65_FLAGS) $< -o $@

$(ROM): $(OBJ) $(CFG_FILE)
	$(LD65) $(OBJ) -C $(CFG_FILE) -o $@ $(LD65_FLAGS)

clean:
	rm -f $(OBJ) $(ROM) $(DBG) $(CHR) *.lst

run: $(ROM)
	open -a Mesen $(ROM)

test: $(ROM)
	prove -v t/

.PHONY: all clean run test
