#!/usr/bin/env perl
# Test: AABB collision detection — 3 scenarios
use strict;
use warnings;
use Test::More;
use FindBin qw($Bin);
use lib "$Bin/../../../lib";
use NES::Test;

load_rom "$Bin/../collide.nes";

# After enough NMIs for all 3 scenarios (frames 1, 2, 3) to complete
at_frame 10 => sub {
    # Scenario 1: overlapping (A=80,80  B=84,83  dx=4 dy=3) → collision
    assert_ram 0x0010 => 1, "Scenario 1: overlapping entities → collision";

    # Scenario 2: far apart (A=80,80  B=200,200  dx=120 dy=120) → no collision
    assert_ram 0x0011 => 0, "Scenario 2: far apart entities → no collision";

    # Scenario 3: edge touching (A=80,80  B=87,80  dx=7 dy=0) → collision
    assert_ram 0x0012 => 1, "Scenario 3: edge-touching entities → collision";

    # Frame counter sanity check
    assert_ram 0x0013 => sub { $_ >= 3 }, "frame_counter >= 3 (all scenarios ran)";
};

done_testing();
