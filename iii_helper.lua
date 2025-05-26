-- ========================================================================== --
-- ARC HELPER FUNCTIONS FOR iii
-- ========================================================================== --

-- Draw a "point" between 1-1024 using a few LEDs on the arc.
-- (cr: @tehn, from snows.lua)
function point(n,x)
	local c = x >> 4  -- bitwise shift right (divide by 2^4, round down)
	arc_led_rel(n,c%64+1,15)
	arc_led_rel(n,(c+1)%64+1,x%16)
	arc_led_rel(n,(c+63)%64+1,15-(x%16))
end