-- based on @tehn's snows.lua

print("\n^______^")
scale = {}
scale[1] = { 2, 2, 1, 2, 2, 2, 1 }  -- major
scale[2] = { 2, 1, 2, 2, 1, 2, 2 }  -- minor
scale[3] = { 2, 2, 3, 2, 3 } -- major pentatonic
scale[4] = { 3, 2, 2, 3, 2 } -- minor pentatonic
scale[5] = { 2, 1, 2, 2, 2, 1, 2 }  -- dorian
scale[6] = { 4, 1, 2, 4, 1 }  -- okinawa

notes = {}
notes[1] = {45,43,50}
notes[2] = {55,64}
notes[3] = {69,74,76,79}
notes[4] = {86,83,81,72,79}

note = {1,1,1,1}  -- note[n] is the index of the current note in notes[n]
position = {0,0,0,0}  -- position of each arc encoder
speed = {0,0,0,0}  -- speed of each arc encoder

REDRAW_FRAMERATE = 30

-- ========================================================================== --
-- RUN
-- ========================================================================== --

arc_refresh()

function tick()
	for n=1,4 do
		arc_led_all(n,0)
		update_point(n)
		draw_sequence(n)
	end
	arc_refresh()
end

function arc(n,d)
	-- any movement on the arc will stop the ring
	speed[n] = KEY_HOLD and 0 or clamp(speed[n] + d,-32,32)
end

function arc_key(z)
	KEY_HOLD = z == 1 and true or false
end

m = metro.new(tick, 1000//REDRAW_FRAMERATE)

-- ========================================================================== --
-- UTILITY
-- ========================================================================== --

-- draw and update the current position of ring `n`, also send MIDI.
-- each encoder corresponds to the corresponding MIDI channel.
function update_point(n)
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

	point(n,position[n])
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
function point(n,x)
	local c = x >> 4  -- bitwise shift right (divide by 2^4, round down)
	arc_led_rel(n,c%64+1,15)
	arc_led_rel(n,(c+1)%64+1,x%16)
	arc_led_rel(n,(c+63)%64+1,15-(x%16))
end
