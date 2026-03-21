#!/usr/bin/env perl
# Test: Attribute table encoding and multi-palette setup
use strict;
use warnings;
use Test::More;
use FindBin qw($Bin);
use lib "$Bin/../../../lib";
use NES::Test;

load_rom "$Bin/../attr.nes";

at_frame 4 => sub {
    # --- Verify 4 background palettes ---
    # Palette 0: black, red, dark red, white
    assert_palette 0x3F00 => 0x0F;
    assert_palette 0x3F01 => 0x16;
    assert_palette 0x3F02 => 0x06;
    assert_palette 0x3F03 => 0x30;

    # Palette 1: black, green, dark green, light green
    assert_palette 0x3F04 => 0x0F;
    assert_palette 0x3F05 => 0x1A;
    assert_palette 0x3F06 => 0x0A;
    assert_palette 0x3F07 => 0x2A;

    # Palette 2: black, blue, dark blue, light blue
    assert_palette 0x3F08 => 0x0F;
    assert_palette 0x3F09 => 0x12;
    assert_palette 0x3F0A => 0x02;
    assert_palette 0x3F0B => 0x22;

    # Palette 3: black, purple, dark purple, light purple
    assert_palette 0x3F0C => 0x0F;
    assert_palette 0x3F0D => 0x14;
    assert_palette 0x3F0E => 0x04;
    assert_palette 0x3F0F => 0x24;

    # --- Verify attribute bytes ---
    # $23C0: TL=0, TR=1, BL=2, BR=3 → $E4
    assert_nametable 0x23C0 => 0xE4;

    # $23C1: all quadrants = palette 2 → $AA
    assert_nametable 0x23C1 => 0xAA;

    # --- Verify tiles present in covered regions ---
    # Row 0, col 0 (inside attribute byte $23C0, TL quadrant)
    assert_tile 0, 0 => 0x01;
    # Row 0, col 4 (inside attribute byte $23C1)
    assert_tile 4, 0 => 0x01;
    # Row 2, col 2 (inside attribute byte $23C0, BL quadrant)
    assert_tile 2, 2 => 0x01;
    # Row 3, col 7 (inside attribute byte $23C1, BR quadrant)
    assert_tile 7, 3 => 0x01;

    # Verify a tile outside the filled region is blank
    assert_tile 10, 10 => 0x00;
};

done_testing();
