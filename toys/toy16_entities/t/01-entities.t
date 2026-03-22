#!/usr/bin/env perl
# Test: Entity storage and OAM synchronization
use strict;
use warnings;
use Test::More;
use FindBin qw($Bin);
use lib "$Bin/../../../lib";
use NES::Test;

load_rom "$Bin/../entity.nes";

# After NMI has synced entities to OAM (frame 4)
at_frame 4 => sub {
    # --- Entity table verification ($0300-$031F) ---

    # Entity 0: x=32, y=40, tile=$01, attr=$00, type=1
    assert_ram 0x0300 => 32,   "Entity 0 x = 32";
    assert_ram 0x0301 => 40,   "Entity 0 y = 40";
    assert_ram 0x0302 => 0x01, "Entity 0 tile = 0x01";
    assert_ram 0x0303 => 0x00, "Entity 0 attr = 0x00";
    assert_ram 0x0304 => 1,    "Entity 0 type = 1 (active)";

    # Entity 1: x=80, y=60, tile=$02, attr=$00, type=1
    assert_ram 0x0308 => 80,   "Entity 1 x = 80";
    assert_ram 0x0309 => 60,   "Entity 1 y = 60";
    assert_ram 0x030A => 0x02, "Entity 1 tile = 0x02";
    assert_ram 0x030B => 0x00, "Entity 1 attr = 0x00";
    assert_ram 0x030C => 1,    "Entity 1 type = 1 (active)";

    # Entity 2: x=128, y=100, tile=$03, attr=$01, type=1
    assert_ram 0x0310 => 128,  "Entity 2 x = 128";
    assert_ram 0x0311 => 100,  "Entity 2 y = 100";
    assert_ram 0x0312 => 0x03, "Entity 2 tile = 0x03";
    assert_ram 0x0313 => 0x01, "Entity 2 attr = 0x01";
    assert_ram 0x0314 => 1,    "Entity 2 type = 1 (active)";

    # Entity 3: x=200, y=150, tile=$04, attr=$02, type=1
    assert_ram 0x0318 => 200,  "Entity 3 x = 200";
    assert_ram 0x0319 => 150,  "Entity 3 y = 150";
    assert_ram 0x031A => 0x04, "Entity 3 tile = 0x04";
    assert_ram 0x031B => 0x02, "Entity 3 attr = 0x02";
    assert_ram 0x031C => 1,    "Entity 3 type = 1 (active)";

    # --- OAM sprite verification (entity → OAM sync) ---

    # Sprite 0: Y=40, tile=$01, attr=$00, X=32
    assert_sprite 0, y => 40, tile => 0x01, attr => 0x00, x => 32;

    # Sprite 1: Y=60, tile=$02, attr=$00, X=80
    assert_sprite 1, y => 60, tile => 0x02, attr => 0x00, x => 80;

    # Sprite 2: Y=100, tile=$03, attr=$01, X=128
    assert_sprite 2, y => 100, tile => 0x03, attr => 0x01, x => 128;

    # Sprite 3: Y=150, tile=$04, attr=$02, X=200
    assert_sprite 3, y => 150, tile => 0x04, attr => 0x02, x => 200;

    # --- Meta checks ---
    assert_ram 0x0010 => 4, "entity_count = 4";
    assert_ram 0x0011 => sub { $_ > 0 }, "frame_counter is incrementing";
};

done_testing();
