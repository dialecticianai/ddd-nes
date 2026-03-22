#!/usr/bin/env perl
# Test: Game state machine transitions via Start button
use strict;
use warnings;
use Test::More;
use FindBin qw($Bin);
use lib "$Bin/../../../lib";
use NES::Test;

load_rom "$Bin/../state.nes";

# After init (frame 4): should be in MENU state (0)
at_frame 4 => sub {
    assert_ram 0x10 => 0x00, "Initial state is MENU (0)";
    # Frame counter should be > 0 (NMI has been running)
    assert_ram 0x11 => sub { $_ > 0 }, "Frame counter is incrementing";
};

# Press Start → MENU to GAMEPLAY
press_button 'Start';

at_frame 6 => sub {
    assert_ram 0x10 => 0x01, "After Start: state is GAMEPLAY (1)";
};

# Press Start → GAMEPLAY to PAUSED
press_button 'Start';

at_frame 8 => sub {
    assert_ram 0x10 => 0x02, "After Start: state is PAUSED (2)";
};

# Press Start → PAUSED back to GAMEPLAY
press_button 'Start';

at_frame 10 => sub {
    assert_ram 0x10 => 0x01, "After Start: state is GAMEPLAY (1) again";
};

done_testing();
