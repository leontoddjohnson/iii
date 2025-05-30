-- ========================================================================== --
-- ARC HELPER FUNCTIONS FOR iii
-- ========================================================================== --

-- Draw a "point" between 1-1024 using a few LEDs on the arc.
-- (cr: @tehn, from snows.lua)
local function point(n,x)
	local c = x >> 4  -- bitwise shift right (divide by 2^4, round down)
	arc_led_rel(n,c%64+1,15)
	arc_led_rel(n,(c+1)%64+1,x%16)
	arc_led_rel(n,(c+63)%64+1,15-(x%16))
end

-- determine if MIDI note is sharp or flat
local function note_is_natural(note)
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

-- ========================================================================== --
-- ARC HELPER FUNCTIONS ON NORNS
-- ========================================================================== --

local music = require 'musicutil'

-- Generate *one* octave of intervening intervals given a scale name,
-- e.g. {2, 2, 1, 2, 2, 2, 1} for a major scale.
-- See musicutil for full list of scale names.
local function scale_intervals(scale)
  scale = music.generate_scale(1, scale, 1) or {}
  intervals = {}
  for i = 2, #scale do
    table.insert(intervals, scale[i] - scale[i - 1])
  end
  return intervals
end