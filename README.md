# iii

[iii](https://monome.org/docs/iii/) scripts for arc.

## swons

> Based on @tehn's *snows*. 

Use single **KEY** presses to cycle between the following modes:

**rings** (main)

Note sequence "sprockets" through at the top of the ring each time the moving point hits 12 o'clock. Dimly lit notes are passed or to come, and the *next* note is always brightly lit at the 12 o'clock position. 

- **ENC**: adjust ring speed and direction
- **KEY + ENC\***: stop movement

\**Any dial adjustment will do.*

**notes**

The top portion shows the notes in the sequence. The bottom portion shows the scale.

- **ENC (right)**: select a note\*
- **ENC (left)**: place the note on the scale (de-selected is a rest)
- **KEY + ENC**: add/remove the last note of the sequence (up to 16 notes)

\**The selected note is brightest, current playing note is slighly dimmer, and the rest are dim.*

**scale**

Notes of each scale (7 semitone intervals) are defined in Lua file. E.g., `scale[1] = {2, 2, 1, 2, 2, 2, 1}` represents a major scale. **ENC 4** shows a visualization of the scale, 4 (3?) octaves in total.

- **ENC 1**: select a scale (defined in Lua file)
- **ENC 2**: select root note (A, A#, B, ..., to G#)\*
- **ENC 3**: set starting octave
- **ENC 4**: cycle scale (set "starting" note)
- **KEY + ENC $i$**: define 12(?)-note window for ring $i$\*

\**Sharp/flat notes are dimmer.*

```lua
-- NOTE
-- mark key hold\ on `z == 1`. If encoder is changed, don't cycle to next mode ... on key off (`z == 0`), refresh.
```

## other ideas

- **cycles** 
  - MIDI cycles to Ableton, but on Ableton, only allow certain notes to come through in chord?