-- based on @tehn's snows.lua

print("\n^______^")
note = {}
note[1] = {45,43,50}
note[2] = {55,64}
note[3] = {69,74,76,79}
note[4] = {86,83,81,72,79}

seq = {1,1,1,1}  -- seq[n] is the index of the current note in note[n]
pos = {0,0,0,0}  -- position of each arc encoder
sp = {0,0,0,0}  -- speed of each arc encoder

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
	sp[n] = clamp(sp[n] + d,-32,32)
end

function arc_key(z)
	for n=1,4 do sp[n] = 0 end
end

m = metro.new(tick, 1000/REDRAW_FRAMERATE)

-- ========================================================================== --
-- UTILITY
-- ========================================================================== --

-- draw and update the current position of ring `n`, also send MIDI.
-- each encoder corresponds to the corresponding MIDI channel.
function update_point(n)
	pos[n] = pos[n] + sp[n]
	ch = n  -- MIDI channel is the same as the arc ring number

	-- passed the 0 point going in reverse
	if pos[n] < 0 then
		midi_note_off(note[n][seq[n]],127,ch)
		seq[n] = ((seq[n] - 2) % #note[n]) + 1  -- previous note
		midi_note_on(note[n][seq[n]],127,ch)
		pos[n] = pos[n] % 1024
		--ps("%d %d",n,seq[n])

	-- passed the 0 point going forward
	elseif pos[n] > 1023 then
		midi_note_off(note[n][seq[n]],127,ch)
		seq[n] = (seq[n] % #note[n]) + 1  -- next note
		midi_note_on(note[n][seq[n]],127,ch)
		pos[n] = pos[n] % 1024
		--ps("%d %d",n,seq[n])
	end

	point(n,pos[n])
end

-- draw the note sequence for ring `n`.
-- Each note is represented by an LED, and the current note is highlighted.
function draw_sequence(n)
	for m=1,#note[n] do arc_led(n,32+m*2,1) end
	arc_led_rel(n,32+seq[n]*2,9)
end

-- Draw a "point" between 1-1024 using a few LEDs on the arc.
-- (cr: @tehn, from snows.lua)
function point(n,x)
	local c = x >> 4  -- bitwise shift right (divide by 2^4, round down)
	arc_led_rel(n,c%64+1,15)
	arc_led_rel(n,(c+1)%64+1,x%16)
	arc_led_rel(n,(c+63)%64+1,15-(x%16))
end
