# PLAN — Multi-Channel Audio + SFX Priority

## Overview

**Goal**: Validate multi-channel APU + SFX priority with cycle measurement

**Scope**: Single ROM, 3 channels, NMI SFX handler, cycle verification

**Methodology**: TDD with Phase 2 tools (assert_audio_playing, assert_ram, assert_frame_cycles)

---

## Steps

### Step 1: Build Multi-Channel ROM with SFX

**Goal**: 3-channel APU output with NMI-driven SFX system.

Initialize APU with the standard init sequence from toy6. Set up pulse 1 (400 Hz), pulse 2 (300 Hz), and triangle (200 Hz) during init. The NMI handler checks `sfx_trigger` — if set, switches pulse 2 to 800 Hz and starts a 10-frame countdown. Each NMI decrements the counter, and when it expires, restores pulse 2 to 300 Hz and sets `sfx_completed`.

The main loop triggers the SFX at a known frame count (frame 20) by setting `sfx_trigger = 1`.

Triangle channel uses different registers ($4008-$400B) and period formula (period = 111860.8 / freq / 2 - 1 for triangle since it steps through 32 phases).

**Success Criteria**:
- `make` builds the ROM
- Audio output is audible (via capture)
- SFX trigger/complete cycle works

**Commit**: `feat(audio_multi): Step 1 — multi-channel audio with SFX priority`

---

### Step 2: Automated Tests

**Goal**: Verify audio, SFX state, and cycle budget.

Test at frame 10 (before SFX): audio playing, sfx_active = 0. Test at frame 25 (during SFX): sfx_active > 0. Test at frame 40 (after SFX): sfx_completed = 1, sfx_active = 0. Verify frame cycles in range throughout.

**Success Criteria**:
- `prove -v t/` passes all tests
- Audio playing verified
- SFX lifecycle verified (inactive → active → completed)
- Frame cycles in NTSC range

**Commit**: `feat(audio_multi): Step 2 — automated multi-channel + SFX tests`

---

### Step 3: Finalize

**Commit**: `docs(audio_multi): complete toy22 with findings`

---

## Risks

1. **Triangle period formula**: Different from pulse. Triangle cycles through 32 phases, so effective frequency is half the period calculation. Need to verify with the wiki or empirically.
2. **Audio capture with 3 channels**: FFT will show mixed frequencies. assert_audio_playing (RMS) should still work, but assert_frequency_near might pick up the wrong channel. Use RMS-based assertions primarily.
3. **SFX timing**: NMI frame count may differ from harness frame count by ±1. Use generous timing windows in tests.

## Dependencies

- `toys/toy6_audio/` — APU init pattern, audio capture pipeline
- `lib/NES/Test.pm` — assert_audio_playing, assert_ram, assert_frame_cycles
- `tools/analyze-audio.py` — FFT analysis
