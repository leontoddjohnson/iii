-- copied from https://monome.org/docs/iii/code

---------------------------------------------------------------------
-- GRID
---------------------------------------------------------------------

--- callback function for grid key
function event_grid(x, y, z) end

--- set coordinates x,y to value z, or if rel is true, add z to existing value
function grid_led(x, y, z, rel) end

--- returns value at coordinates x,y
function grid_led_get(x, y) end

--- set all values to z, or if rel is true, add z to all existing values
function grid_led_all(z, rel) end

--- set global intensity to brightness b, triggers refresh
function grid_intensity(b) end

--- refresh LED values
function grid_refresh() end

--- returns x size
function grid_size_x() end

--- returns y size
function grid_size_y() end


---------------------------------------------------------------------
-- ARC
---------------------------------------------------------------------

--- callback function for arc knob ring n delta d
function event_arc(n, d) end

--- callback function for arc knob ring n delta d
function event_arc_key(n, d) end

--- set knob resolution for ring n to div (default 1, use higher values for less resolution)
function arc_res(n, div) end

--- set ring n segment x to value z, or if rel is true, add z to existing value
function arc_led(n, x, z, rel) end

--- set all values of ring n to z, or if rel is true, add z to existing values
function arc_led_ring(n, z, rel) end

--- set all values to z, or if rel is true, add z to existing values
function arc_led_all(z, rel) end

--- set global intensity to brightness b, triggers refresh
function arc_intensity(b) end

--- refresh LED values
function arc_refresh() end


---------------------------------------------------------------------
-- MIDI
---------------------------------------------------------------------

--- callback function for incoming USB MIDI
function event_midi(byte1, byte2, byte3) end

--- returns decoded midi byte array data as a labeled table
function midi_to_msg(data) end

--- table can be data bytes or msg, sent to USB MIDI port
function midi_out(table) end

--- shortcut function for sending note on
function midi_note_on(note, vel, ch) end

--- shortcut function for sending note off
function midi_note_off(note, vel, ch) end

--- shortcut function for sending cc
function midi_cc(cc, val, ch) end


---------------------------------------------------------------------
-- METRO
---------------------------------------------------------------------

-- see https://monome.org/docs/iii/code#metro

---------------------------------------------------------------------
-- SLEW
---------------------------------------------------------------------

-- see https://monome.org/docs/iii/code#slew

---------------------------------------------------------------------
-- PSET
---------------------------------------------------------------------

--- assign name to pset files to be written and read
function pset_init(name) end

--- writes pset number index with data table
function pset_write(index, table) end

--- deletes pset at index
function pset_delete(index) end

--- read pset number index into table
--- `table = pset_read(index)`
function pset_read(index) end


---------------------------------------------------------------------
-- UTILS
---------------------------------------------------------------------

--- send text to lua interpreter, execute command
function dostring(lua_command) end

--- returns time in seconds with usec precision
function get_time() end

--- print a formatted string, like printf
function ps(formatted_string, ...) end

--- print table
function pt(table) end

--- returns n clamped between min and max
function clamp(n, min, max) end

--- returns n rounded to nearest quant (default 1)
function round(n, quant) end

--- returns n transposed from range (slo,shi) to range (dlo,dhi)
function linlin(n, slo, shi, dlo, dhi) end

--- returns n wrapped within range (min,max)
function wrap(n, min, max) end


---------------------------------------------------------------------
-- SYSTEM
---------------------------------------------------------------------

--- returns device name
function device_id() end

--- list files
function ls() end

--- display file
function cat(file) end

--- remove file
function rm(file) end

--- display current memory availability
function mem() end

--- garbage collector (see lua docs)
function gc() end

--- run file
function require_file(file) end

--- set file to be run at startup, omit file to remove current startup
function first(file) end