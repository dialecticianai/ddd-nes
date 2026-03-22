# Makefile for unrom - UNROM mapper 2 bank switching test

CA65 = /opt/homebrew/bin/ca65
LD65 = /opt/homebrew/bin/ld65

ASM_SRC = unrom.s
CFG_FILE = nes.cfg
ROM = unrom.nes
OBJ = unrom.o
DBG = unrom.dbg

CA65_FLAGS = -g
LD65_FLAGS = --dbgfile $(DBG)

all: $(ROM)

$(OBJ): $(ASM_SRC)
	$(CA65) $(CA65_FLAGS) $< -o $@

$(ROM): $(OBJ) $(CFG_FILE)
	$(LD65) $(OBJ) -C $(CFG_FILE) -o $@ $(LD65_FLAGS)

clean:
	rm -f $(OBJ) $(ROM) $(DBG) *.lst

test: $(ROM)
	prove -v t/

.PHONY: all clean test
