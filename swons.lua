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

note_selected = {1, 1, 1, 1}  -- selected note of sequence (in notes mode)

led_level = {
	selected = 15,
	highlighted = 8,
	deselected = 3,
	root = 10,
	natural = 4,
	sharp_flat = 1,
	off_scale = 0
}

note_playing = {1,1,1,1}  -- the index of the current note in the sequence
position = {0,0,0,0}  -- position of each arc encoder
speed = {0,0,0,0}  -- speed of each arc encoder

REDRAW_FRAMERATE = 30
SELECTION_START = 40
WINDOW_SIZE = 15  -- size of the window in semitones
MAX_NOTES = 16
MAX_SCALES = 28
NOTE_NAMES = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"}
SCALE = 3         -- current scale
MODE = 1		      -- 1: main, 2: notes, 3: window, 4: scale
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
	if KEY_HOLD then
		-- stop ring, and stop playing note
		speed[n] = 0
		local midi_note = window_note(n, scales[SCALE][n].notes[note_playing[n]])
		midi_note_off(midi_note, 127, n)

	else
		-- any movement on the arc will stop the ring
		speed[n] = clamp(speed[n] + d, -32, 32)
	end
end

-- notes -------------------------------------------------------------------- --

function redraw_notes()
	local n_notes, led_start, led, window_start, note
	local buffer = 1

	for n=1,4 do
		-- top portion: sequence note selection
		n_notes = #scales[SCALE][n].notes
		led_start = - ((n_notes + buffer * (n_notes - 1)) // 2) % 64 + 1
		draw_selection(note_selected[n], n_notes, n, buffer, led_start)

		-- draw playing note as long as it is not already selected
		if note_playing[n] ~= note_selected[n] then
			led = wrap(led_start + (buffer + 1) * (note_playing[n] - 1), 1, 64)
			arc_led(n, led, led_level.highlighted)
		end

		-- bottom portion: notes in the window
		led = 32 + WINDOW_SIZE // 2
		window_start = scales[SCALE][n].window_start

		for i=1,WINDOW_SIZE do
			-- draw the note in the window
			note = scales[SCALE].full_scale[window_start + i]
			if note then draw_note(note, led, n) end

			-- draw the note in the sequence
			note = window_note(n, scales[SCALE][n].notes[note_selected[n]])
			if note == scales[SCALE].full_scale[window_start + i] then
				arc_led(n, led, led_level.selected)
			end
			
			led = led - 1
		end
	end
end

function arc_notes(n,d)
	local n_notes = #scales[SCALE][n].notes
	local note, range

	if KEY_HOLD then
		if d > 0 and n_notes < MAX_NOTES then
			-- let any new note be the first note in the window
			table.insert(scales[SCALE][n].notes, 1)
		elseif d < 0 and n_notes > 1 then
			if note_selected[n] == n_notes then
				-- if the last note is selected, select the previous one
				note_selected[n] = wrap(note_selected[n] - 1, 1, n_notes - 1)
			end
			-- remove the last note in the sequence
			table.remove(scales[SCALE][n].notes)
		end
	elseif d > 0 then
		-- select note (index) in the sequence
		note_selected[n] = wrap(note_selected[n] + 1, 1, n_notes)
	elseif d < 0 then
		-- assign scale note to sequence note
		note = scales[SCALE][n].notes[note_selected[n]]
		range = window_length(n)
		scales[SCALE][n].notes[note_selected[n]] = wrap(note + 1, 1, range)
	end
end

-- window ------------------------------------------------------------------- --

function redraw_window()
	for arc = 1,4 do
		draw_window(arc)
	end
end

function arc_window(n,d)
	local last_value = scales[SCALE][n].window_start
	local v

	-- if KEY_HOLD, move by 12 semitones (1 octave) at a time
	if KEY_HOLD 
		and 0 <= last_value + d * 12
		and last_value + d * 12 <= 60 - WINDOW_SIZE + 1 then
		v = last_value + d * 12
		scales[SCALE][n].window_start = clamp(v, 0, 60 - WINDOW_SIZE + 1)
	elseif not KEY_HOLD then
		v = last_value + d
		scales[SCALE][n].window_start = clamp(v, 0, 60 - WINDOW_SIZE + 1)
	end
end

-- scale -------------------------------------------------------------------- --

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

		-- stop notes playing
		local midi_note
		for m=1,4 do
			midi_note = window_note(n, scales[SCALE][m].notes[note_playing[m]])
			midi_note_off(midi_note, 127, m)
		end
	elseif n == 2 then
		scales[SCALE].root = wrap(scales[SCALE].root + d, 0, 11)
	elseif n == 3 then
		scales[SCALE].octave = clamp(scales[SCALE].octave + d, 0, 4)
	elseif n == 4 then
		local mod_bound = #scales[SCALE].scale - 1
		scales[SCALE].mod = clamp(scales[SCALE].mod - d, -mod_bound, mod_bound)
	end
	scales[SCALE].full_scale = {}
end

-- ========================================================================== --
-- UTILITY
-- ========================================================================== --

function build_scales()
	for i,scale in ipairs(scale_intervals) do
		if i > MAX_SCALES then return end

		scales[i] = {}
		scales[i].root = 0  -- 0 -> C, 1 -> C#, ..., up to 11 -> B
		scales[i].octave = 2  -- starting octave, from 0 to 5
		scales[i].scale = sum(scale) == 12 and scale or { 2, 2, 3, 2, 3 }
		scales[i].mod = 0  -- number of in-scale notes to modulate, up to #scale
		scales[i].full_scale = {}  -- five octaves of scale indicated on arc

		for arc=1,4 do
			scales[i][arc] = {}
			scales[i][arc].notes = {1, 1, 2}  -- index of in-scale note in window
			scales[i][arc].window_start = 0  -- in semitones from base note
		end
	end

	-- initialize the first scale (w/ arbitrary arc) and associated windows
	draw_scale(1, false)
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

function draw_scale(arc, draw)
	local octave = scales[SCALE].octave
	local mod_sum = 0  -- total intervals attributed to the modulation
	local led = 35  -- first LED for scale on arc
	local interval, interval_i, note

	draw = draw == nil and true or false

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
			scales[SCALE].full_scale[wrap(led - 35 + 1, 1, 64)] = note
			if draw then draw_note(note, led, arc) end
		end

		for i=1,#scales[SCALE].scale do
			interval_i = wrap(i + scales[SCALE].mod, 1, #scales[SCALE].scale)
			interval = scales[SCALE].scale[interval_i]
			note = note + interval
			led = led + interval

			if 0 <= note and note <= 128 then
				scales[SCALE].full_scale[wrap(led - 35 + 1, 1, 64)] = note
				if draw then draw_note(note, led, arc) end
			end
		end

		octave = octave + 1
	end
end

-- Draw the window of the current scale for `arc`. `draw` is a boolean that determines whether to actually draw the notes or just build the window.
function draw_window(arc)
	-- LED 34 is the last LED before the start of the scale
	local start = scales[SCALE][arc].window_start
	local stop = scales[SCALE][arc].window_start + WINDOW_SIZE - 1
	local note, note_i

	for i=start,stop do
		note = scales[SCALE].full_scale[i+1]
		note_i = wrap(i + 35, 1, 64)
		if note then draw_note(note, note_i, arc) end
	end
end

-- get a MIDI note from an index of the window using window_start.
-- last scale value is returned if index is out of bounds.
function window_note(arc, index)
	local note_i = scales[SCALE][arc].window_start
  local last_note_i = scales[SCALE][arc].window_start - 1
  local i = 0

	-- get the nth not null value in full_scale
  while i < index and note_i < scales[SCALE][arc].window_start + WINDOW_SIZE do
    note_i = note_i + 1
    if scales[SCALE].full_scale[note_i] then
      i = i + 1
      last_note_i = note_i
    end
  end

	return scales[SCALE].full_scale[last_note_i]
end

function window_length(arc)
	for i=1,WINDOW_SIZE+1 do
		if window_note(arc, i) == window_note(arc, i+1) then
			return i
		end
	end

	return 1
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
	local midi_note = window_note(n, scales[SCALE][n].notes[note_playing[n]])

	-- passed the 0 point going in reverse
	if position[n] < 0 then
		midi_note_off(midi_note,127,ch)

		-- play previous note
		note_playing[n] = ((note_playing[n] - 2) % #scales[SCALE][n].notes) + 1
		midi_note = window_note(n, scales[SCALE][n].notes[note_playing[n]])
		midi_note_on(midi_note,127,ch)
		ps("[" .. n .. "]" .. midi_note .. " --> " .. midi_note_name(midi_note))
		position[n] = position[n] % 1024

	-- passed the 0 point going forward
	elseif position[n] > 1023 then
		midi_note_off(midi_note,127,ch)

		-- play next note
		note_playing[n] = (note_playing[n] % #scales[SCALE][n].notes) + 1
		midi_note = window_note(n, scales[SCALE][n].notes[note_playing[n]])
		midi_note_on(midi_note,127,ch)
		ps("[" .. n .. "] " .. midi_note .. " --> " .. midi_note_name(midi_note))
		position[n] = position[n] % 1024
	end
end

-- draw the note sequence for ring `n`.
-- each note is represented by an LED, and the current note is highlighted.
function draw_sequence(n)
	local next_note
	
	-- define next note based on speed
	if speed[n] < 0 then
		next_note = ((note_playing[n] - 2) % #scales[SCALE][n].notes) + 1
	else
		next_note = (note_playing[n] % #scales[SCALE][n].notes) + 1
	end

	-- sprocket
	for m=1,#scales[SCALE][n].notes do
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

function midi_note_name(note)
	if not note or note < 0 or note > 127 then
		return "invalid note"
	end

	local octave = note  // 12
	local note_name = NOTE_NAMES[note % 12 + 1]
	return note_name .. ' ' .. octave
end