# OpenLane Guide for SoCET Students

This repository is meant to be a starting point for anyone in SoCET that wants to learn how to use OpenLane. The structure and contents of this repository facilitate the use of OpenLane 2 to harden a design. An overview of OpenLane, instructions on how to harden a design, and important Makefile targets are covered in this guide.

## OpenLane Overview
OpenLane is a powerful and versatile library that enables the implementation of digital ASIC designs using open-source and commercial EDA tools. OpenLane abstracts how each tool works by allowing the user to configure them. Once you’ve installed OpenLane, running a digital design through the flow requires the following:

- Verified RTL code (i.e., the Verilog/SystemVerilog of your design)
- The flow configuration file (`config.json`)
- A process design kit (PDK) – usually open-source sky130 PDK or GF180MCU PDK

The `config.json` file provides all the variables to set the flow; if it doesn’t specify a value for a certain variable, the flow will use default values. The default PDK is the **SkyWater/Google 130nm** PDK, but any other PDKs can be specified in the `config.json`. The sky130 PDK automatically downloads when you run the flow for the first time. In the configuration file you can specify the HDL code of your design (in Verilog/SystemVerilog), the clock port, and the desired clock period. More information on OpenLane for beginners can be found [here](https://openlane2.readthedocs.io/en/latest/getting_started/newcomers/index.html).

## Instructions to Harden a Design

1. Install OpenLane 2. Follow instructions on the [Nix-based Installation](https://openlane2.readthedocs.io/en/latest/getting_started/common/nix_installation/index.html).

2. After OpenLane 2 is installed, clone this repository (`socet_openlane_flow`) in your **LOCAL** computer (don't use asicfab). If you have Windows, use WSL (the OpenLane installation guide tells you how to setup WSL). Update the `OPENLANE2_ROOT` variable in the Makefile if your `openlane2` root is not in your home directory.

3. The sky130 PDK is built and cached using **Volare**, which is also installed when you install OpenLane. By default, Volare keeps the downloaded PDKs in the `.volare` folder in your home directory, unless you specify otherwise. If you wish to modify your PDK path (i.e., the location of sky130 PDK files), just modify variable `VOLARE_ROOT`. If not, continue to the next step.

4. This repo has a file structure that mimics that of the Caravel User Project template repo from Efabless (for reference, see repo [here](https://github.com/efabless/caravel_user_project)). Place all your Verilog files in the `verilog` directory. This directory has 3 folders: `dv`, `gl`, and `rtl`. Folder `dv` is for all testbench code. Folder `gl` is for the synthesized gate-level netlists (these are produced when you run OpenLane). Folder `rtl` is for your RTL code (i.e., the Verilog code of your designs). Place all your RTL Verilog files in the `rtl` folder - create a single subfolder for each top-level design, and feel free to add as many files or sub-folders within this folder. If you wish, you can also add your testbench files in the `dv` folder; however, this repo currently doesn't have any Makefile targets that handle RTL and gate-level simulations.

5. Within the `openlane` directory in this repo, create a folder with the name of your design. Inside this folder, create a `config.json` file that will configure the flow. The minimum configuration variables that must be specified of this file are `DESIGN_NAME`, `VERILOG_FILES`, `CLOCK_PERIOD`, and `CLOCK_PORT`. Take a look at some of the example `config.json` files in this repo to understand what other variables do. You can also refer to the [OpenLane 2 website](https://openlane2.readthedocs.io/en/latest/) to learn more about of other configuration variables and under which circumstances they can be used.

6. After adding your RTL Verilog/SystemVerilog files and the `config.json` file to the appropriate directories in this repo, you are now ready to harden (i.e., create the physical layout) of your design. Run `make <design name>` to harden your design. For example, if the top-level design name is `sample_proj`, then run `make sample_proj`. Make sure this design name matches the name of the folder you added in the `openlane` directory. Try running some of the example designs before running yours to get an idea of how the flow works what to expect in the terminal output. You'll most likely get errors during synthesis, which are related to errors in your RTL code, so carefully read the reported errors in the terminal and log file to debug these.

7. For the design to harden successfully, there must be no DRC violations, no LVS violations, and minimal antenna violations. If you ever get any of these violations, reference the OpenLane docs to fix them.

## Other Makefile Targets

- `make gdsview_%_klayout` - This command will open a view of the GDS file (i.e., the complete physical layout of your design) in KLayout. Replace `%` with the name of your design. If your design name is `sample_proj`, then you can open the GDS file by running `make gdsview_sample_proj_klayout`.

- `make clean` - This command will remove the `runs` directory from all the folders in the `openlane` directory. This folder gets created and stores all the log files and temporary design outputs through every step of the flow for each run.

- More Makefile targets comming soon!