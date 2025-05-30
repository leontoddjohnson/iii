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

The top portion shows the notes in the sequence. The selected note is brightest, the currently playing note is slighly less bright, and the rest are dim.

The bottom portion shows two octaves of notes from the scale. The selected note placement is the brightest, the root notes are slightly less bright, and the rest are dim.

- **ENC (clockwise)**: select a note
- **ENC (counter clockwise)**: place the note on the scale (de-selected is a rest)
- **KEY + ENC**: add/remove the last note of the sequence (up to 16 notes)\*

\**New notes are randomly placed.*

**window**

Each sequence consists of notes from the scale within a 2-octave window\* of the main scale (see below). The window is indicated by two bright lights surrounding the beginning and end of the window (i.e., the first note of the window is after the first bright light). Aside from these, the root notes are brightest, natural notes are less bright, sharps and flats are dim, and notes off the scale are dark.

\**The "window" is 25 notes from a chromatic scale.*

- **ENC**: define the window for the ring
- **KEY + ENC**: increment the scale window in octaves

**scale**

Unless defined otherwise (see below), there are 9 scales to choose from, respectively: major, natural minor, melodic minor, harmonic minor, major pentatonic, minor pentatonic, dorian, okinawa, chromatic. These scales are played using the 128 MIDI notes, where note `0` is *C-1*, and the rest follow in semitones (up to 10 full octaves).

The ring around **ENC 4** shows a visualization of the scale across 5 chromatic octaves inclusive (61 notes), from the lower left of the ring to the lower right. Here, the root note is the brightest, natural notes are less bright, sharps and flats are dim, and notes off the scale are dark.

- **ENC 1**: select a scale
- **ENC 2**: select root note (C, C#, D, ..., B)\*
- **ENC 3**: set starting octave (can be from 1 to 5)
- **ENC 4**: cycle scale (set "starting" note)

\**The UI here is similar to the scale window, with no root.*

You can add up to 32 scales to the top of the Lua file. Scales are defined by a sequence of semitone intervals *whose sum is equal to 12* (e.g., `{2, 2, 1, 2, 2, 2, 1}` represents a major scale).