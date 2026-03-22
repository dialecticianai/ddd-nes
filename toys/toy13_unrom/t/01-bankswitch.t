#!/usr/bin/env perl
# Test: UNROM bank switching — verify marker bytes from each bank
use strict;
use warnings;
use Test::More;
use FindBin qw($Bin);
use lib "$Bin/../../../lib";
use NES::Test;

load_rom "$Bin/../unrom.nes";

# After PPU init + bank switches, markers should be in RAM
# ZP layout: $10 = current_bank, $11 = marker0, $12 = marker1, $13 = marker2
at_frame 4 => sub {
    # Bank 0 marker: $AA
    assert_ram 0x11 => 0xAA, "Bank 0 marker read correctly";

    # Bank 1 marker: $BB
    assert_ram 0x12 => 0xBB, "Bank 1 marker read correctly";

    # Bank 2 marker: $CC
    assert_ram 0x13 => 0xCC, "Bank 2 marker read correctly";

    # current_bank should be 2 (last bank switched to)
    assert_ram 0x10 => 0x02, "current_bank tracks last switch";
};

done_testing();
