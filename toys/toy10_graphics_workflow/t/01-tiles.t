#!/usr/bin/env perl
# Test: Nametable tile placements from custom CHR-ROM data
use strict;
use warnings;
use Test::More;
use FindBin qw($Bin);
use lib "$Bin/../../../lib";
use NES::Test;

load_rom "$Bin/../tiles.nes";

# After PPU init + rendering enabled, tiles should be in nametable
at_frame 4 => sub {
    # Verify 7 tile placements documented in tiles.s
    assert_tile  5,  3 => 0x01;  # solid dark gray
    assert_tile 10,  7 => 0x02;  # solid light gray
    assert_tile 15,  5 => 0x03;  # solid white
    assert_tile 20, 10 => 0x04;  # checkerboard
    assert_tile  8, 15 => 0x05;  # diagonal stripes
    assert_tile 25, 20 => 0x06;  # horizontal stripes
    assert_tile 12, 25 => 0x07;  # border frame

    # Verify an unwritten position is still tile $00 (blank)
    assert_tile  0,  0 => 0x00;
};

done_testing();
