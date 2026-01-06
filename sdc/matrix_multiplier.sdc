###############################################################################
# Created by write_sdc
###############################################################################
current_design matrix_multiplier
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name hz100 -period 25.0000 [get_ports {hz100}]
set_clock_transition 0.1500 [get_clocks {hz100}]
set_clock_uncertainty 0.2500 hz100
set_propagated_clock [get_clocks {hz100}]
set_input_delay 5.0000 -clock [get_clocks {hz100}] -add_delay [get_ports {cs}]
set_input_delay 5.0000 -clock [get_clocks {hz100}] -add_delay [get_ports {mosi}]
set_input_delay 5.0000 -clock [get_clocks {hz100}] -add_delay [get_ports {spi_clk}]
set_output_delay 5.0000 -clock [get_clocks {hz100}] -add_delay [get_ports {miso}]
set_output_delay 5.0000 -clock [get_clocks {hz100}] -add_delay [get_ports {ready}]
###############################################################################
# Environment
###############################################################################
set_load -pin_load 0.0334 [get_ports {miso}]
set_load -pin_load 0.0334 [get_ports {ready}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {cs}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {hz100}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {mosi}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {spi_clk}]
###############################################################################
# Design Rules
###############################################################################
set_max_transition 0.4000 [current_design]
set_max_capacitance 0.2000 [current_design]
set_max_fanout 10.0000 [current_design]
