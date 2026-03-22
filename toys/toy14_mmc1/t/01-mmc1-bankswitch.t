#!/usr/bin/env perl
# Test: MMC1 serial protocol bank switching
use strict;
use warnings;
use Test::More;
use FindBin qw($Bin);
use lib "$Bin/../../../lib";
use NES::Test;

load_rom "$Bin/../mmc1.nes";

at_frame 4 => sub {
    # Bank 0 marker: $AA
    assert_ram 0x11 => 0xAA, "Bank 0 marker via MMC1 serial switch";

    # Bank 1 marker: $BB
    assert_ram 0x12 => 0xBB, "Bank 1 marker via MMC1 serial switch";

    # Bank 2 marker: $CC
    assert_ram 0x13 => 0xCC, "Bank 2 marker via MMC1 serial switch";

    # current_bank should be 2 (last bank switched to)
    assert_ram 0x10 => 0x02, "current_bank tracks last MMC1 switch";
};

done_testing();
