#!/usr/bin/env perl
# Test: Metatile decompression to nametable + attribute table
use strict;
use warnings;
use Test::More;
use FindBin qw($Bin);
use lib "$Bin/../../../lib";
use NES::Test;

load_rom "$Bin/../meta.nes";

at_frame 4 => sub {
    # --- Verify decompressed nametable tiles ---
    # Row 0: MT0.TL MT0.TR MT1.TL MT1.TR MT2.TL MT2.TR MT3.TL MT3.TR
    # MT0: tiles $01, $02, $03, $04
    assert_tile 0, 0 => 0x01;  # MT0 TL
    assert_tile 1, 0 => 0x02;  # MT0 TR
    assert_tile 0, 1 => 0x03;  # MT0 BL
    assert_tile 1, 1 => 0x04;  # MT0 BR

    # MT1: tiles $05, $06, $07, $01
    assert_tile 2, 0 => 0x05;  # MT1 TL
    assert_tile 3, 0 => 0x06;  # MT1 TR
    assert_tile 2, 1 => 0x07;  # MT1 BL
    assert_tile 3, 1 => 0x01;  # MT1 BR

    # MT2: tiles $02, $03, $04, $05
    assert_tile 4, 0 => 0x02;  # MT2 TL
    assert_tile 5, 0 => 0x03;  # MT2 TR
    assert_tile 4, 1 => 0x04;  # MT2 BL
    assert_tile 5, 1 => 0x05;  # MT2 BR

    # MT3: tiles $06, $07, $01, $02
    assert_tile 6, 0 => 0x06;  # MT3 TL
    assert_tile 7, 0 => 0x07;  # MT3 TR
    assert_tile 6, 1 => 0x01;  # MT3 BL
    assert_tile 7, 1 => 0x02;  # MT3 BR

    # Blank tile outside decompressed region
    assert_tile 10, 10 => 0x00;

    # --- Verify attribute bytes ---
    # $23C0: MT0 palette=0 (TL), MT1 palette=1 (TR) → (1 << 2) | 0 = $04
    assert_nametable 0x23C0 => 0x04;

    # $23C1: MT2 palette=2 (TL), MT3 palette=3 (TR) → (3 << 2) | 2 = $0E
    assert_nametable 0x23C1 => 0x0E;

    # --- Verify palettes ---
    assert_palette 0x3F00 => 0x0F;  # palette 0 bg
    assert_palette 0x3F01 => 0x16;  # palette 0 color 1
    assert_palette 0x3F05 => 0x1A;  # palette 1 color 1
    assert_palette 0x3F09 => 0x12;  # palette 2 color 1
    assert_palette 0x3F0D => 0x14;  # palette 3 color 1
};

done_testing();
