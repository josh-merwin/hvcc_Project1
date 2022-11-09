
pnr:
	docker run -v $$OPENLANE_ROOT:/openlane \
		            -v $$PDK_ROOT:/foss/pdks \
                -v ~/designs/spm:/spm  \
                -e PDK_ROOT=$$PDK_ROOT \
                -e STD_CELL_LIBRARY=sky130_fd_sc_hd \
                -u $$(id -u $$USER):$$(id -g $$USER) \
                -e DISPLAY=$$DISPLAY \
		-e MISMATCHES_OK=1 \
                -v /tmp/.X11-unix:/tmp/.X11-unix \
                -v $$HOME/.Xauthority:/.Xauthority \
                --network host \
                -it efabless/openlane:2022.02.23_02.50.41 bash

