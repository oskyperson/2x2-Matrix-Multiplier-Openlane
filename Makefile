# Project Directory
export PROJECT_ROOT=$(shell pwd)

# Change OPENLANE2_ROOT if your OpenLane 2 root is somewhere else
export OPENLANE2_ROOT=$(HOME)/openlane2

# Change PDK_ROOT if your PDK root is not the default
export PDK_ROOT=$(HOME)/.volare
export PDK = sky130A
export PDK_PATH = $(PDK_ROOT)/$(PDK)

# Identify names of existing designs
designs = $(shell cd openlane && find * -maxdepth 0 -type d)
# List designs
.PHONY: list_designs
list_designs:
	@echo $(designs)

# OpenLane command
openlane_cmd = \
	"openlane \
	--run-tag $(OPENLANE_RUN_TAG) \
	$(PROJECT_ROOT)/openlane/$*/config.json"

# KLayout Command
klayout_cmd = \
	"klayout $(PROJECT_ROOT)/gds/$*.gds \
	-l $(PDK_PATH)/libs.tech/klayout/tech/$(PDK).lyp"

# Harden a Design with OpenLane 2
export OPENLANE_RUN_TAG = $(shell date '+%y_%m_%d_%H_%M')
.PHONY: $(designs)
$(designs) : % : $(PROJECT_ROOT)/openlane/%/config.json
	mkdir -p $(PROJECT_ROOT)/openlane/$*/runs/$(OPENLANE_RUN_TAG) 
	rm -rf $(PROJECT_ROOT)/openlane/$*/runs/$*
	ln -s $$(realpath $(PROJECT_ROOT)/openlane/$*/runs/$(OPENLANE_RUN_TAG)) openlane/$*/runs/$*
	nix-shell --run $(openlane_cmd) --pure $(OPENLANE2_ROOT)/shell.nix
	@mkdir -p $(PROJECT_ROOT)/signoff/$*/
	@cp $(PROJECT_ROOT)/openlane/$*/runs/$*/final/*.csv $(PROJECT_ROOT)/signoff/$*/
	@cp $(PROJECT_ROOT)/openlane/$*/runs/$*/final/def/* $(PROJECT_ROOT)/def/$*.def
	@cp $(PROJECT_ROOT)/openlane/$*/runs/$*/final/sdc/* $(PROJECT_ROOT)/sdc/$*.sdc
	@cp $(PROJECT_ROOT)/openlane/$*/runs/$*/final/gds/* $(PROJECT_ROOT)/gds/$*.gds
	@cp $(PROJECT_ROOT)/openlane/$*/runs/$*/final/lef/* $(PROJECT_ROOT)/lef/$*.lef
	@cp $(PROJECT_ROOT)/openlane/$*/runs/$*/*magic-streamout/*.mag $(PROJECT_ROOT)/mag/$*.mag
	@cp $(PROJECT_ROOT)/openlane/$*/runs/$*/final/pnl/* $(PROJECT_ROOT)/verilog/gl/$*.v
	@cp $(PROJECT_ROOT)/openlane/$*/runs/$*/final/spice/* $(PROJECT_ROOT)/spi/lvs/$*.spice
	@cp $(PROJECT_ROOT)/openlane/$*/runs/$*/final/spef/nom/* $(PROJECT_ROOT)/spef/multicorner/$*.nom.spef
	@cp $(PROJECT_ROOT)/openlane/$*/runs/$*/final/spef/nom/* $(PROJECT_ROOT)/spef/$*.spef
	@cp $(PROJECT_ROOT)/openlane/$*/runs/$*/final/spef/min/* $(PROJECT_ROOT)/spef/multicorner/$*.min.spef
	@cp $(PROJECT_ROOT)/openlane/$*/runs/$*/final/spef/max/* $(PROJECT_ROOT)/spef/multicorner/$*.max.spef
	@cp $(PROJECT_ROOT)/openlane/$*/runs/$*/final/lib/nom*tt*/* $(PROJECT_ROOT)/lib/$*.lib
	@cp $(PROJECT_ROOT)/openlane/$*/runs/$*/resolved.json $(PROJECT_ROOT)/signoff/$*/
	@mkdir -p $(PROJECT_ROOT)/signoff/$*/openlane-signoff/timing-reports
	@cp $(PROJECT_ROOT)/openlane/$*/runs/$*/*magic-drc/reports/* $(PROJECT_ROOT)/signoff/$*/openlane-signoff/
	@cp $(PROJECT_ROOT)/openlane/$*/runs/$*/*netgen-lvs/reports/lvs.netgen.rpt $(PROJECT_ROOT)/signoff/$*/openlane-signoff/
	@cp $(PROJECT_ROOT)/openlane/$*/runs/$*/*netgen-lvs/reports/lvs.netgen.rpt $(PROJECT_ROOT)/signoff/$*/openlane-signoff/
	@cp $(PROJECT_ROOT)/openlane/$*/runs/$*/*netgen-lvs/netgen-lvs.log $(PROJECT_ROOT)/signoff/$*/openlane-signoff/
	@cp -r $(PROJECT_ROOT)/openlane/$*/runs/$*/*openroad-stapostpnr/summary.rpt $(PROJECT_ROOT)/signoff/$*/openlane-signoff/timing-reports
	@find $(PROJECT_ROOT)/openlane/$*/runs/$*/*openroad-stapostpnr/*/*.rpt -type 'f' -print0 | \
	xargs -0 -I {} sh -c '\
		file="{}"; \
		target_dir=$(PROJECT_ROOT)/signoff/$*/openlane-signoff/timing-reports/$$(basename $$(dirname $$file)); \
		mkdir -p $$target_dir; \
		cp $$file $$target_dir/;'

	@find $(PROJECT_ROOT)/openlane/$*/runs/$*/final/sdf -type 'f' -print0 | \
	xargs -0 -I {} sh -c '\
		file="{}"; \
		target_dir=$(PROJECT_ROOT)/signoff/$*/sdf/$$(basename $$(dirname $$file)); \
		mkdir -p $$target_dir; \
		cp $$file $$target_dir/$*.sdf;'

# Open GDSII of design in KLayout
.PHONY: gdsview_%_klayout
gdsview_%_klayout:
	@if echo "$(designs)" | grep -qw "$*"; then \
		if [ -f "$(PROJECT_ROOT)/gds/$*.gds" ]; then \
			echo "Open GDSII layout of $* in KLayout..."; \
			nix-shell --run $(klayout_cmd) --pure $(OPENLANE2_ROOT)/shell.nix; \
		else \
			echo "Error: Design $* exists, but no GDSII file found"; \
			false; \
		fi; \
	else \
		echo "Error: Design $* does not exist"; \
		false; \
	fi

# TODO: Add more targets for other tasks (maybe even more Caravel targets)