#!/usr/bin/env perl
# Test: Scrolling vblank budget — column streaming + cycle counting
use strict;
use warnings;
use Test::More;
use FindBin qw($Bin);
use lib "$Bin/../../../lib";
use NES::Test;

load_rom "$Bin/../scroll.nes";

# Frame 4: NMI running, scroll advancing
at_frame 4 => sub {
    assert_ram 0x11 => sub { $_ > 0 }, "Frame counter incrementing";
    assert_ram 0x10 => sub { $_ > 0 }, "Scroll X advancing";

    # Phase 2: verify frame cycle count
    assert_frame_cycles sub { $_ > 29000 && $_ < 30500 },
        "Frame cycles in NTSC range (~29,781)";
};

# Frame 14: should have crossed 8-pixel boundary, column written
at_frame 14 => sub {
    assert_ram 0x12 => sub { $_ >= 1 }, "At least 1 column written";
    assert_frame_cycles sub { $_ > 29000 && $_ < 30500 },
        "Frame cycles normal with column write";
};

# Frame 30: multiple columns, verify nametable data
at_frame 30 => sub {
    assert_ram 0x12 => sub { $_ >= 3 }, "At least 3 columns written";

    # Initial fill was $01. Column streaming writes $02.
    # First boundary crossing: scroll_x=8, scroll_col=1, column = (1+2)&31 = 3
    # Second: scroll_x=16, scroll_col=2, column = (2+2)&31 = 4
    # Third: scroll_x=24, scroll_col=3, column = (3+2)&31 = 5
    assert_tile 0, 0 => 0x01, "Untouched tile still 0x01";
    assert_tile 3, 0 => 0x02, "Column 3 row 0 = 0x02 (first streamed column)";
    assert_tile 3, 15 => 0x02, "Column 3 row 15 = 0x02 (streamed)";
    assert_tile 3, 29 => 0x02, "Column 3 row 29 = 0x02 (streamed)";
};

done_testing();
