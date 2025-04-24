###############################################################################
# Created by write_sdc
###############################################################################
current_design intro_2_stopwatch
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name CLK_10MHZ -period 100.0000 [get_ports {CLK_10MHZ}]
set_clock_transition 0.1500 [get_clocks {CLK_10MHZ}]
set_clock_uncertainty 0.2500 CLK_10MHZ
set_propagated_clock [get_clocks {CLK_10MHZ}]
set_input_delay 20.0000 -clock [get_clocks {CLK_10MHZ}] -add_delay [get_ports {BTN[0]}]
set_input_delay 20.0000 -clock [get_clocks {CLK_10MHZ}] -add_delay [get_ports {BTN[1]}]
set_input_delay 20.0000 -clock [get_clocks {CLK_10MHZ}] -add_delay [get_ports {BTN[2]}]
set_input_delay 20.0000 -clock [get_clocks {CLK_10MHZ}] -add_delay [get_ports {BTN[3]}]
set_output_delay 20.0000 -clock [get_clocks {CLK_10MHZ}] -add_delay [get_ports {D0_AN_0}]
set_output_delay 20.0000 -clock [get_clocks {CLK_10MHZ}] -add_delay [get_ports {D0_AN_1}]
set_output_delay 20.0000 -clock [get_clocks {CLK_10MHZ}] -add_delay [get_ports {D0_AN_2}]
set_output_delay 20.0000 -clock [get_clocks {CLK_10MHZ}] -add_delay [get_ports {D0_AN_3}]
set_output_delay 20.0000 -clock [get_clocks {CLK_10MHZ}] -add_delay [get_ports {D0_SEG[0]}]
set_output_delay 20.0000 -clock [get_clocks {CLK_10MHZ}] -add_delay [get_ports {D0_SEG[1]}]
set_output_delay 20.0000 -clock [get_clocks {CLK_10MHZ}] -add_delay [get_ports {D0_SEG[2]}]
set_output_delay 20.0000 -clock [get_clocks {CLK_10MHZ}] -add_delay [get_ports {D0_SEG[3]}]
set_output_delay 20.0000 -clock [get_clocks {CLK_10MHZ}] -add_delay [get_ports {D0_SEG[4]}]
set_output_delay 20.0000 -clock [get_clocks {CLK_10MHZ}] -add_delay [get_ports {D0_SEG[5]}]
set_output_delay 20.0000 -clock [get_clocks {CLK_10MHZ}] -add_delay [get_ports {D0_SEG[6]}]
set_output_delay 20.0000 -clock [get_clocks {CLK_10MHZ}] -add_delay [get_ports {D0_SEG[7]}]
###############################################################################
# Environment
###############################################################################
set_load -pin_load 0.0334 [get_ports {D0_AN_0}]
set_load -pin_load 0.0334 [get_ports {D0_AN_1}]
set_load -pin_load 0.0334 [get_ports {D0_AN_2}]
set_load -pin_load 0.0334 [get_ports {D0_AN_3}]
set_load -pin_load 0.0334 [get_ports {D0_SEG[7]}]
set_load -pin_load 0.0334 [get_ports {D0_SEG[6]}]
set_load -pin_load 0.0334 [get_ports {D0_SEG[5]}]
set_load -pin_load 0.0334 [get_ports {D0_SEG[4]}]
set_load -pin_load 0.0334 [get_ports {D0_SEG[3]}]
set_load -pin_load 0.0334 [get_ports {D0_SEG[2]}]
set_load -pin_load 0.0334 [get_ports {D0_SEG[1]}]
set_load -pin_load 0.0334 [get_ports {D0_SEG[0]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {CLK_10MHZ}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {BTN[3]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {BTN[2]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {BTN[1]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {BTN[0]}]
###############################################################################
# Design Rules
###############################################################################
set_max_transition 0.7500 [current_design]
set_max_capacitance 0.2000 [current_design]
set_max_fanout 10.0000 [current_design]
