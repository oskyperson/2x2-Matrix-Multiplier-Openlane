# Export a few environment variables
export PROJECT_ROOT=$(shell pwd)
export OPENLANE2_ROOT=$(HOME)/openlane2

# Run OpenLane on Designs
blocks=$(shell cd openlane && find * -maxdepth 0 -type d)
.PHONY: $(blocks)
$(blocks): % :
	$(MAKE) -C openlane $*

# TODO: Add more targets for other tasks (maybe even Caravel targets)