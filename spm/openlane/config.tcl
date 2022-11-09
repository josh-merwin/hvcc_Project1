# User config
set ::env(DESIGN_NAME) mul32
set ::env(VERILOG_FILES) "/spm/hdl/src/spm.v /spm/hdl/src/mul32.v"
set ::env(PDK) "sky130A"


# Fill this
set ::env(CLOCK_PERIOD) "10.0"
set ::env(CLOCK_PORT) "clk"

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}

