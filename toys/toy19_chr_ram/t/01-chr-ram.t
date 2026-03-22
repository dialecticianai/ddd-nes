#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use FindBin qw($Bin);
use lib "$Bin/../../../lib";
use NES::Test;

load_rom "$Bin/../chrram.nes";

at_frame 4 => sub {
    # Frame counter running (NMI active)
    assert_ram 0x10 => sub { $_ > 0 }, "Frame counter incrementing";

    # Verify tiles placed in nametable
    assert_tile  5,  3 => 0x00, "Tile 0x00 at (5,3)";
    assert_tile 10,  7 => 0x01, "Tile 0x01 at (10,7)";
    assert_tile 15,  5 => 0x02, "Tile 0x02 at (15,5)";
    assert_tile 20, 10 => 0x03, "Tile 0x03 at (20,10)";

    # Untouched position should be 0
    assert_tile 0, 0 => 0x00, "Empty nametable position = 0x00";

    # Verify palette
    assert_palette 0x3F00 => 0x0F, "Palette BG = black";
    assert_palette 0x3F01 => 0x16, "Palette 1 = red";
    assert_palette 0x3F02 => 0x12, "Palette 2 = blue";
    assert_palette 0x3F03 => 0x30, "Palette 3 = white";

    # Phase 2: cycle count
    assert_frame_cycles sub { $_ > 29000 && $_ < 30500 },
        "Frame cycles in NTSC range";
};

done_testing();
