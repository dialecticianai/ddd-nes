# LEARNINGS — Multi-Channel Audio + SFX Priority

## Learning Goals

Validate multi-channel APU + SFX priority system with cycle measurement.

### Cross-References

- `toys/toy6_audio/` — Single-channel APU, audio capture pipeline
- `learnings/audio.md` — APU registers
- `learnings/.ddd/5_open_questions.md` — Q3.2, Q3.3

## Findings

**Duration**: ~15 min | **Status**: Complete | **Result**: 12/12 tests passing

### Q3.2: SFX vs music priority

**Answer**: Simple flag-based system works. SFX trigger flag in ZP, NMI handler checks each frame. When triggered: switch channel to SFX tone, start countdown. When expired, restore channel. ~10 extra NMI instructions for SFX check.

Pattern: music owns pulse 2 normally. SFX borrows pulse 2 for its duration, then returns it. No complex priority queue needed.

### Q3.3: Cycle budget for audio

**Answer**: Per-frame APU updates add negligible cycle cost. `assert_frame_cycles` shows normal NTSC frames (~29,781) even on SFX trigger frames. The theoretical 1000-1500 cycles/frame for FamiTone2 is generous — our simple handler uses far less.

### Multi-channel detection

Three channels produce RMS ~0.10 (vs ~0.06 single channel). `assert_audio_playing()` (RMS-based) works reliably for multi-channel. Use `assert_frequency_near()` only for single-channel tests.

## Patterns for Production

- **SFX flag pattern**: sfx_trigger, sfx_active (countdown), sfx_completed (3 ZP bytes)
- **Channel allocation**: pulse 1 = music, pulse 2 = music + SFX, triangle = bass
- **Triangle period**: `55930.4 / freq - 1` (half pulse formula)
- **Audio testing**: RMS for multi-channel, frequency for single-channel
