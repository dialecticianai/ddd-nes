#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use FindBin qw($Bin);
use lib "$Bin/../../../lib";
use NES::Test;

load_rom "$Bin/../audio.nes";

# Frame 10: before SFX trigger — 3 channels playing, no SFX
at_frame 10 => sub {
    assert_ram 0x12 => sub { $_ > 0 }, "Frame counter incrementing";
    assert_ram 0x10 => 0, "sfx_active = 0 (no SFX yet)";
    assert_ram 0x11 => 0, "sfx_trigger = 0";
    assert_audio_playing();
    assert_frame_cycles sub { $_ > 29000 && $_ < 30500 },
        "Frame cycles in NTSC range";
};

# Frame 25: SFX should have been triggered (frame 20) and be active
at_frame 25 => sub {
    assert_ram 0x11 => 0, "sfx_trigger consumed (reset to 0)";
    assert_ram 0x10 => sub { $_ >= 0 }, "sfx_active countdown";
    assert_audio_playing();
};

# Frame 40: SFX should have completed (started frame ~21, 10 frames = done by ~31)
at_frame 40 => sub {
    assert_ram 0x13 => 1, "sfx_completed = 1";
    assert_ram 0x10 => 0, "sfx_active = 0 (SFX expired)";
    assert_audio_playing();
    assert_frame_cycles sub { $_ > 29000 && $_ < 30500 },
        "Frame cycles normal after SFX";
};

done_testing();
