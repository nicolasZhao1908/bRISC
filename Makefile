SIM ?= verilator
TOPLEVEL_LANG ?= verilog

VERILOG_INCLUDE_DIRS += $(PWD)/rtl
VERILOG_SOURCES += $(PWD)/rtl/utility/fully_associative_cache.sv


# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = fully_associative_cache

# MODULE is the basename of the Python test file
MODULE = tb.test_utility.test_fully_associative_cache

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim