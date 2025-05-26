-- see https://github.com/monome/iii/?tab=readme-ov-file#lua-library
-- still waiting for official documentation ...

-- grid --------------------------------------------------------------------- --

function grid(x,y,z) end
function grid_led_all(z) end
function grid_led(x, y, z) end
function grid_led_rel(x, y, z, zmin, zmax) end
function grid_led_get(x, y) end
function grid_refresh() end
function grid_size_x() end
function grid_size_y() end

-- arc ---------------------------------------------------------------------- --

function arc(ring, delta) end
function arc_key(z) end
-- sets knob tick division (sensitivity) 1-1024, 1 = max resolution
function arc_res(ring, div) end
function arc_led(ring, led, level) end
-- adds level to current value, level_min/level_max optional
function arc_led_rel(ring, led, level, level_min, level_max) end
function arc_led_all(ring, level) end
function arc_refresh() end

-- midi --------------------------------------------------------------------- --

-- callback for raw bytes sent to the USB-MIDI port.
function midi_rx(ch,status,data1,data2) end
function midi_note_on(note,vel,ch) end
function midi_note_off(note,vel,ch) end
function midi_cc(cc,val,ch) end
function midi_tx(ch,status,data1,data2) end

-- metro ------------------------------------------------------------------- --

-- iii supports fifteen timed metronome objects.
-- see https://github.com/monome/iii/?tab=readme-ov-file#metro

-- id = metro.new(callback, time_ms, count_optional)
-- metro.stop(id)

-- slew ------------------------------------------------------------------- --

-- Use slew to smoothly count between two values over a specified time.
-- see https://github.com/monome/iii/?tab=readme-ov-file#slew

-- id = slew.new(callback, start_val, end_val, time_ms, quant)
-- slew.stop(id)

-- pset --------------------------------------------------------------------- --

-- *needs work as of 26 May '25*
-- see https://github.com/monome/iii/?tab=readme-ov-file#presets

-- Example:
-- table = pset_read(index)
-- pset_write(index, table)

function pset_read(index) end
function pset_write(index, table) end

-- utils ------------------------------------------------------------------ --

-- executes the string cmd. *Be careful!*
function dostring() end

-- returns time since boot in milliseconds. Helpful for measuring intervals.
function get_time() end

-- print string
function ps(formatted_string,...) end

-- print table
function pt(table_to_print) end

function clamp(n,min,max) end
function round(number,quant) end
function linlin(slo,shi,dlo,dhi,f) end
function wrap(n,min,max) end