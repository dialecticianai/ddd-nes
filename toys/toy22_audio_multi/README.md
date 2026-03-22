# Multi-Channel Audio (toy22)

3-channel APU playback with NMI-driven SFX priority system.

## Purpose

Validates simultaneous pulse 1 + pulse 2 + triangle playback and a simple SFX interrupt/resume mechanism. Measures NMI cycle cost. Last Phase 2 toy — completes audio questions.

## Key API

```
Channels: pulse1=400Hz, pulse2=300Hz, triangle=200Hz
SFX: set sfx_trigger=1 → NMI switches pulse2 to 800Hz for 10 frames → restores
ZP: sfx_active($10), sfx_trigger($11), frame_counter($12), sfx_completed($13)
```

## Core Concepts

- APU init: standard routine ($4000-$4013), then per-channel register setup
- Triangle period = `55930.4 / freq - 1` (half pulse formula, 32-step waveform)
- SFX flag-based: trigger → borrow pulse 2 → countdown → restore → completed
- NMI overhead: negligible (~10 instructions for SFX check per frame)

## Gotchas

- Writing to $4003/$4007 resets pulse phase (causes pop) — avoid during vibrato
- Triangle has no volume control (only mute/unmute via $4008 bit 7)
- Multi-channel FFT shows mixed frequencies — use RMS-based `assert_audio_playing()` instead of `assert_frequency_near()`
- SFX frame timing may be ±1 vs test harness frame count — use generous windows

## Quick Test

```bash
cd toys/toy22_audio_multi && make && prove -v t/
```
