#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use FindBin qw($Bin);
use lib "$Bin/../../../lib";
use NES::Test;

load_rom "$Bin/../math.nes";

at_frame 4 => sub {
    # === Multiply tests ===
    # Test 1: 7 * 6 = 42
    assert_ram 0x0300 => 42,  "7*6 lo = 42";
    assert_ram 0x0301 => 0,   "7*6 hi = 0";

    # Test 2: 13 * 20 = 260 ($0104)
    assert_ram 0x0302 => 0x04, "13*20 lo = 0x04";
    assert_ram 0x0303 => 0x01, "13*20 hi = 0x01";

    # Test 3: 255 * 255 = 65025 ($FE01)
    assert_ram 0x0304 => 0x01, "255*255 lo = 0x01";
    assert_ram 0x0305 => 0xFE, "255*255 hi = 0xFE";

    # Test 4: 0 * 99 = 0
    assert_ram 0x0306 => 0,   "0*99 lo = 0";
    assert_ram 0x0307 => 0,   "0*99 hi = 0";

    # === Divide tests ===
    # Test 1: 42 / 7 = 6 remainder 0
    assert_ram 0x0310 => 6,   "42/7 quotient = 6";
    assert_ram 0x0311 => 0,   "42/7 remainder = 0";

    # Test 2: 100 / 3 = 33 remainder 1
    assert_ram 0x0312 => 33,  "100/3 quotient = 33";
    assert_ram 0x0313 => 1,   "100/3 remainder = 1";

    # Test 3: 255 / 1 = 255 remainder 0
    assert_ram 0x0314 => 255, "255/1 quotient = 255";
    assert_ram 0x0315 => 0,   "255/1 remainder = 0";

    # Test 4: 5 / 10 = 0 remainder 5
    assert_ram 0x0316 => 0,   "5/10 quotient = 0";
    assert_ram 0x0317 => 5,   "5/10 remainder = 5";

    # Frame cycles
    assert_frame_cycles sub { $_ > 29000 && $_ < 30500 },
        "Frame cycles in NTSC range";
};

done_testing();
