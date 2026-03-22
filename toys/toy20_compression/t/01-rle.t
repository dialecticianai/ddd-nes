#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use FindBin qw($Bin);
use lib "$Bin/../../../lib";
use NES::Test;

load_rom "$Bin/../rle.nes";

# Expected output: FF FF FF FF FF 03 42 AA AA AA 07 55 55 55 55
# 15 bytes total, starting at $0300

at_frame 4 => sub {
    # Output count
    assert_ram 0x10 => 15, "Output count = 15 bytes";

    # Run 1: 5x $FF
    assert_ram 0x0300 => 0xFF, "Byte 0: FF (run 1)";
    assert_ram 0x0304 => 0xFF, "Byte 4: FF (run 1 end)";

    # Literal: $03
    assert_ram 0x0305 => 0x03, "Byte 5: 03 (literal)";

    # Literal: $42
    assert_ram 0x0306 => 0x42, "Byte 6: 42 (literal)";

    # Run 2: 3x $AA
    assert_ram 0x0307 => 0xAA, "Byte 7: AA (run 2)";
    assert_ram 0x0309 => 0xAA, "Byte 9: AA (run 2 end)";

    # Literal: $07
    assert_ram 0x030A => 0x07, "Byte 10: 07 (literal)";

    # Run 3: 4x $55
    assert_ram 0x030B => 0x55, "Byte 11: 55 (run 3)";
    assert_ram 0x030E => 0x55, "Byte 14: 55 (run 3 end)";

    # NES RAM is NOT zero-initialized (learned in toy2), so don't check past end

    # Frame cycles
    assert_frame_cycles sub { $_ > 29000 && $_ < 30500 },
        "Frame cycles in NTSC range";
};

done_testing();
