print("\n^______^")  -- based on @tehn's snows.lua

scale_intervals = {
	{ 2, 2, 1, 2, 2, 2, 1 },  -- major
	{ 2, 1, 2, 2, 1, 2, 2 },  -- minor
	{ 2, 2, 3, 2, 3 },  -- major pentatonic
	{ 3, 2, 2, 3, 2 },  -- minor pentatonic
	{ 2, 1, 2, 2, 2, 1, 2 },  -- dorian
	{ 4, 1, 2, 4, 1 },  -- okinawa
	{ 2, 2, 2, 2, 2, 2 },  -- whole tone
	{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 }  -- chromatic
}

scales = {}

notes = {}
notes[1] = {45,43,50}
notes[2] = {55,64}
notes[3] = {69,74,76,79}
notes[4] = {86,83,81,72,79}

led_level = {
	selected = 15,
	deselected = 3,
	root = 10,
	natural = 4,
	sharp_flat = 1,
	off_scale = 0
}

note = {1,1,1,1}  -- note[n] is the index of the current note in notes[n]
position = {0,0,0,0}  -- position of each arc encoder
speed = {0,0,0,0}  -- speed of each arc encoder

REDRAW_FRAMERATE = 30
SELECTION_START = 40
NOTE_NAMES = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"}
SCALE = 8         -- current scale
MODE = 4		      -- 1: main, 2: notes, 3: window, 4: scale
KEY_HOLD = false  -- true if the key is held down
KEY_HELD = false  -- true if there was valid activity on the last key hold

-- ========================================================================== --
-- MODES
-- ========================================================================== --

-- rings -------------------------------------------------------------------- --

function redraw_rings()
	for n=1,4 do 
		draw_sequence(n)
		draw_point(n,position[n])
	end
end

function arc_rings(n,d)
	-- any movement on the arc will stop the ring
	speed[n] = KEY_HOLD and 0 or clamp(speed[n] + d,-32,32)
end

-- notes -------------------------------------------------------------------- --

-- DRAFT
function redraw_notes()
	n = 2
	arc_led_all(n, 0)
	for i = 1,n do
		arc_led(n, i, 1)
	end
	arc_led(n, 33, 1)
end

function arc_notes(n,d)
	print("arc_notes :: arc ", n, d)
end

-- window ------------------------------------------------------------------- --

-- DRAFT
function redraw_window()
	n = 3
	arc_led_all(n, 0)
	for i = 1,n do
		arc_led(n, i, 1)
	end
end

function arc_window(n,d)
	print("arc_window :: arc ", n, d)
end

-- scale -------------------------------------------------------------------- --

-- DRAFT
function redraw_scale()
	-- arc 1
	draw_selection(SCALE, #scale_intervals, 1)

	-- arc 2
	draw_root_selection(2)

	-- arc 3
	draw_selection(scales[SCALE].octave + 1, 5, 3)  -- octave is 0-indexed

	-- arc 4
	draw_scale(4)
end

function arc_scale(n,d)
	if n == 1 then
		SCALE = clamp(SCALE + d, 1, #scale_intervals)
	elseif n == 2 then
		scales[SCALE].root = wrap(scales[SCALE].root + d, 0, 11)
	elseif n == 3 then
		scales[SCALE].octave = clamp(scales[SCALE].octave + d, 0, 4)
	elseif n == 4 then
		local mod_bound = #scales[SCALE].scale - 1
		scales[SCALE].mod = clamp(scales[SCALE].mod - d, -mod_bound, mod_bound)
	end
end

-- ========================================================================== --
-- UTILITY
-- ========================================================================== --

function build_scales()
	for i,scale in ipairs(scale_intervals) do
		scales[i] = {}
		scales[i].root = 0  -- 0 -> C, 1 -> C#, ..., up to 11 -> B
		scales[i].octave = 2  -- starting octave, from 0 to 5
		scales[i].scale = sum(scale) == 12 and scale or { 2, 2, 3, 2, 3 }
		scales[i].mod = 0  -- number of in-scale notes to modulate, up to #scale

		for arc=1,4 do
			scales[i][arc] = {}
			scales[i][arc].notes = {1}  -- index of in-scale note in window
			scales[i][arc].window_start = 0  -- in semitones from base note
			scales[i][arc].window = {}  -- in-scale notes in the window
			scales[i][arc].full_scale = {}  -- full scale notes in the octave
		end
	end
end

function draw_root_selection(arc)
	local buffer = 1
	local led = SELECTION_START

	if scales[SCALE].root == 0 then 
		arc_led(arc, led, led_level.selected) 
	else
		arc_led(arc, led, led_level.root) 
	end

	for i=1,11 do
		led = led + buffer + 1  -- move to next LED
		if scales[SCALE].root == i then
			arc_led(arc, led, led_level.selected)
		elseif note_is_natural(i) then
			arc_led(arc, led, led_level.natural)
		else
			arc_led(arc, led, led_level.sharp_flat)
		end
	end
end

-- **1-indexed** indicator for the selection of some `n_options`.
-- `selection` is the (1-based) index among the `n_options`.
-- `buffer` is the number of empty LEDs between options, and 
-- `start` is the first LED index.
function draw_selection(selection, n_options, arc, buffer, start)
	buffer = buffer or 2
	start = start or SELECTION_START

	local led = start

	for i=1,n_options do
		level = selection == i and led_level.selected or led_level.deselected
		arc_led(arc, led, level)
		led = wrap(led + buffer + 1, 1, 64)
	end
end

function draw_scale(arc)
	local octave = scales[SCALE].octave
	local mod_sum = 0  -- total intervals attributed to the modulation
	local led = 35  -- first LED for scale on arc
	local interval, interval_i, note

	if scales[SCALE].mod > 0 then
		for i=1,scales[SCALE].mod do
			mod_sum = mod_sum + scales[SCALE].scale[i]
		end
	elseif scales[SCALE].mod < 0 then
		for i=#scales[SCALE].scale + scales[SCALE].mod + 1,#scales[SCALE].scale do
			mod_sum = mod_sum - scales[SCALE].scale[i]
		end
	end

	while octave - scales[SCALE].octave < 5 do
		-- draw first note
		note = octave * 12 + scales[SCALE].root + mod_sum

		if 0 <= note and note <= 128 then
			-- add to full scale?
			draw_note(note, led, arc) 
		end

		for i=1,#scales[SCALE].scale do
			interval_i = wrap(i + scales[SCALE].mod, 1, #scales[SCALE].scale)
			interval = scales[SCALE].scale[interval_i]
			note = note + interval
			led = led + interval

			if 0 <= note and note <= 128 then
				-- add to full scale?
				draw_note(note, led, arc)
			end
		end

		octave = octave + 1
	end
end

-- Draw MIDI note `note` on arc `arc` at LED `led` based on the current scale.
function draw_note(note, led, arc)
	led = wrap(led, 1, 64)

	if (note - scales[SCALE].root) % 12 == 0 then
		arc_led(arc, led, led_level.root)  -- root note
	elseif note_is_natural(note) then
		arc_led(arc, led, led_level.natural)  -- natural note
	else
		arc_led(arc, led, led_level.sharp_flat)  -- sharp or flat note
	end
end

-- Build window of *in-scale* notes spanning 2 (chromatic) octaves, 
-- starting at MIDI note `window_start`. The sequence of `notes` are 
-- indexes from this window.
function scales:reset_window(window_start, arc)
	self[SCALE][arc].window_start = window_start

	local base_note = self[SCALE].root + self[SCALE].mod + self[SCALE].octave * 12
	local window_start = base_note + window_start
	local offset = 0  -- scale notes between root and window start
	local offset_st = 0  -- semitones of scale notes before window start
	
	-- iterate through semitones before window start to calculate offset
	for i = 0,window_start % 12 do
		if i >= offset_st + self[SCALE].scale[offset + 1] then
			offset_st = offset_st + self[SCALE].scale[offset + 1]
			offset = offset + 1
		end
	end

	self[SCALE][arc].window = {}

	local midi_note  -- MIDI index of note in the scale
	local interval

	-- build two octaves of scale notes (inclusive)
	table.insert(self[SCALE][arc].window, midi_note)

	for i=0,#self[SCALE].scale * 2 do
		interval = self[SCALE].scale[(offset + i) % #self[SCALE].scale + 1]
		midi_note = window_start // 12 + interval
		table.insert(self[SCALE][arc].window, midi_note)
	end
end

-- -- convert sequence index of note (`note`) to a MIDI note 0-128.
-- function scales[i]:seq_to_midi(note, arc)
-- 	-- ...

-- 	return self.root 
		
-- 		+ interval
-- end

-- -- convert `scales[i][arc].notes[j]` indices to midi notes
-- function note_to_midi(note)
-- 	local 
-- 	return 
-- end

-- calculate the sum of numeric values in a table
function sum(t)
	local s = 0
	for i,v in ipairs(t) do s = s + v end
	return s
end

-- play MIDI. each encoder corresponds to the corresponding MIDI channel.
function play_note(n)
	position[n] = position[n] + speed[n]
	ch = n  -- MIDI channel is the same as the arc ring number

	-- passed the 0 point going in reverse
	if position[n] < 0 then
		midi_note_off(notes[n][note[n]],127,ch)
		note[n] = ((note[n] - 2) % #notes[n]) + 1  -- previous note
		midi_note_on(notes[n][note[n]],127,ch)
		position[n] = position[n] % 1024
		--ps("%d %d",n,note[n])

	-- passed the 0 point going forward
	elseif position[n] > 1023 then
		midi_note_off(notes[n][note[n]],127,ch)
		note[n] = (note[n] % #notes[n]) + 1  -- next note
		midi_note_on(notes[n][note[n]],127,ch)
		position[n] = position[n] % 1024
		--ps("%d %d",n,note[n])
	end
end

-- draw the note sequence for ring `n`.
-- each note is represented by an LED, and the current note is highlighted.
function draw_sequence(n)
	local next_note

	-- define next note based on speed
	if speed[n] < 0 then
		next_note = ((note[n] - 2) % #notes[n]) + 1
	else
		next_note = (note[n] % #notes[n]) + 1
	end

	-- sprocket
	for m=1,#notes[n] do
		-- set past notes and future ones as dim
		if m > next_note then arc_led(n, 2 * ((m - next_note) % 64) + 1, 1) end
		if m < next_note then arc_led(n, 2 * ((m - next_note) % 32) + 1, 1) end

		-- highlight next note
		if m == next_note then arc_led(n, 1, 9) end
	end

end

-- Draw a "point" between 1-1024 using a few LEDs on the arc.
-- (cr: @tehn, from snows.lua)
function draw_point(n,x)
	local c = x >> 4  -- bitwise shift right (divide by 2^4, round down)
	arc_led_rel(n,c%64+1,15)
	arc_led_rel(n,(c+1)%64+1,x%16)
	arc_led_rel(n,(c+63)%64+1,15-(x%16))
end

function note_is_natural(note)
  if note % 12 == 1 
    or note % 12 == 3 
    or note % 12 == 6 
    or note % 12 == 8 
    or note % 12 == 10 then
    return false
  else
    return true
  end
end

function set_arc_res(mode)
	if mode == 1 then
		for n=1,4 do arc_res(n, 1) end
	elseif mode == 2 then
		for n=1,4 do arc_res(n, 16) end
	elseif mode == 3 then
		for n=1,4 do arc_res(n, 8) end
	elseif mode == 4 then
		for n=1,4 do arc_res(n, 8) end
	end
end

-- ========================================================================== --
-- RUN
-- ========================================================================== --

function tick()
	for n=1,4 do 
		arc_led_all(n,0)  -- refresh
		play_note(n)   -- continue playing
	end

	if MODE == 1 then
		redraw_rings()
	elseif MODE == 2 then
		redraw_notes()
	elseif MODE == 3 then
		redraw_window()
	elseif MODE == 4 then
		redraw_scale()
	end
	arc_refresh()
end

function arc(n,d)
	if MODE == 1 then
		arc_rings(n,d)
	elseif MODE == 2 then
		arc_notes(n,d)
	elseif MODE == 3 then
		arc_window(n,d)
	elseif MODE == 4 then
		arc_scale(n,d)
	end

	-- update movement during key hold
	KEY_HELD = KEY_HOLD
end

function arc_key(z)
	KEY_HOLD = z == 1 and true or false

	if z == 0 then
		if KEY_HELD then
			KEY_HELD = false
		else
			MODE = (MODE % 4) + 1  -- cycle through modes
			set_arc_res(MODE)
		end
	end
end

arc_refresh()
set_arc_res(MODE)
build_scales()
ticker = metro.new(tick, 1000//REDRAW_FRAMERATE)

-- ========================================================================== --
-- HELPER FUNCTIONS                                                           --
-- ========================================================================== --
-- function to print table
function print_table(t, indent)
  indent = indent or 0
  for k, v in pairs(t) do
    local prefix = string.rep(" ", indent)
    if type(v) == "table" then
      print(prefix .. tostring(k) .. ":")
      print_table(v, indent + 2)
    else
      print(prefix .. tostring(k) .. ": " .. tostring(v))
    end
  end
end