# SPEC — Multi-Channel Audio + SFX Priority

## Purpose

Validate multi-channel APU playback (pulse 1, pulse 2, triangle) and a simple SFX priority mechanism. Measures NMI cycle cost for per-frame APU updates. Last Phase 2 toy — completes the audio questions.

**Axis of complexity**: Multi-channel init + SFX interrupt/resume + NMI cycle measurement.

## Overview

The ROM initializes 3 APU channels with different tones. An NMI-driven SFX system monitors a trigger flag: when set, pulse 2 switches to an SFX tone for a fixed duration, then resumes the original tone. Tests verify audio is playing, SFX triggers correctly (via RAM state), and frame cycles are in range.

## Behavioral Contract

### Channel Setup (init-time)
- Pulse 1: 400 Hz tone (continuous "music")
- Pulse 2: 300 Hz tone (continuous "music", will be interrupted by SFX)
- Triangle: 200 Hz tone (continuous "bass")

### SFX System (NMI-driven)
- ZP flag `sfx_active` ($10): 0 = no SFX, >0 = SFX countdown timer
- When `sfx_trigger` ($11) is set to 1: pulse 2 switches to 800 Hz "beep", sfx_active = 10 (10 frames)
- Each NMI: if sfx_active > 0, decrement. When it hits 0, restore pulse 2 to 300 Hz.
- sfx_trigger is set by the main loop at a specific frame count

### RAM Layout
- $10: sfx_active (countdown timer, 0 = no SFX)
- $11: sfx_trigger (write 1 to start SFX)
- $12: frame_counter
- $13: sfx_completed (set to 1 when SFX finishes, proves the cycle completed)

## Success Criteria

- Audio is playing after init (assert_audio_playing)
- SFX trigger flag is consumed by NMI handler (sfx_trigger resets to 0)
- SFX completed flag is set after duration expires
- Frame cycles in NTSC range (including NMI APU work)
- All tests pass with `prove -v t/`

## Out of Scope

- Music sequencer / pattern playback
- FamiTone2 integration
- DPCM channel
- Volume envelopes
- Frequency sweep effects
