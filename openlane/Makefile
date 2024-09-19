# Some environment variables
export OPENLANE_RUN_TAG = $(shell date '+%y_%m_%d_%H_%M')
designs = $(shell find * -maxdepth 0 -type d)
current_design = null

# OpenLane command(s)
openlane_cmd = \
	"openlane \
	--run-tag $(OPENLANE_RUN_TAG) \
	$*/config.json"
openlane_cmd_interactive = "flow.tcl -it -file $$(realpath ./$*/interactive.tcl)"

# List designs
list:
	@echo $(designs)

# Harden a Design
# More information on this target can be found here:
# https://github.com/efabless/caravel_user_project_ol2/blob/main/openlane/Makefile
.PHONY: $(designs)
$(designs) : export current_design=$@
$(designs) : % : ./%/config.json
	mkdir -p ./$*/runs/$(OPENLANE_RUN_TAG) 
	rm -rf ./$*/runs/$*
	ln -s $$(realpath ./$*/runs/$(OPENLANE_RUN_TAG)) ./$*/runs/$*
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