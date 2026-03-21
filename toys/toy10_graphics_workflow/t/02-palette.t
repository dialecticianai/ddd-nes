#!/usr/bin/env perl
# Test: Palette loaded correctly
use strict;
use warnings;
use Test::More;
use FindBin qw($Bin);
use lib "$Bin/../../../lib";
use NES::Test;

load_rom "$Bin/../tiles.nes";

at_frame 4 => sub {
    # Background palette 0: $3F00-$3F03
    assert_palette 0x3F00 => 0x0F;  # black
    assert_palette 0x3F01 => 0x12;  # dark blue
    assert_palette 0x3F02 => 0x21;  # light blue
    assert_palette 0x3F03 => 0x30;  # white
};

done_testing();
