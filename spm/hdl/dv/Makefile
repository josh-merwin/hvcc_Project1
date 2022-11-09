VFLAGS = -Wall -Winfloop
SRC_DIR = ../src
SRC = $(SRC_DIR)/spm.v $(SRC_DIR)/mul32.v

sim: $(SRC) mul32_tb.v
	iverilog $(VFLAGS) -o mul32_tb.vvp $(SRC) mul32_tb.v 
	vvp mul32_tb.vvp

wave: mul32_tb.vcd mul32_tb.gtkw
	gtkwave mul32_tb.vcd mul32_tb.gtkw    

all: sim wave


.PHONY: clean

clean:
	rm -f *.vvp *.vcd
