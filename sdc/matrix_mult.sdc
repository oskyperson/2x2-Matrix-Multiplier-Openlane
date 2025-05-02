###############################################################################
# Created by write_sdc
###############################################################################
current_design matrix_mult
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name clk -period 100.0000 [get_ports {clk}]
set_clock_transition 0.1500 [get_clocks {clk}]
set_clock_uncertainty 0.2500 clk
set_propagated_clock [get_clocks {clk}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {bit_period[0]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {bit_period[10]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {bit_period[11]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {bit_period[12]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {bit_period[13]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {bit_period[1]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {bit_period[2]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {bit_period[3]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {bit_period[4]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {bit_period[5]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {bit_period[6]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {bit_period[7]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {bit_period[8]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {bit_period[9]}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {confirmation}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {n_rst}]
set_input_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {serial_in}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {data_read}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {serial_out}]
set_output_delay 20.0000 -clock [get_clocks {clk}] -add_delay [get_ports {tx_busy}]
###############################################################################
# Environment
###############################################################################
set_load -pin_load 0.0334 [get_ports {data_read}]
set_load -pin_load 0.0334 [get_ports {serial_out}]
set_load -pin_load 0.0334 [get_ports {tx_busy}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {clk}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {confirmation}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {n_rst}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {serial_in}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {bit_period[13]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {bit_period[12]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {bit_period[11]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {bit_period[10]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {bit_period[9]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {bit_period[8]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {bit_period[7]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {bit_period[6]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {bit_period[5]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {bit_period[4]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {bit_period[3]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {bit_period[2]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {bit_period[1]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {bit_period[0]}]
###############################################################################
# Design Rules
###############################################################################
set_max_transition 0.7500 [current_design]
set_max_capacitance 0.2000 [current_design]
set_max_fanout 10.0000 [current_design]
