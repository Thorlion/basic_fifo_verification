##################################################################################################
# SystemVerilog Simulation Makefile (Questasim 10.2c)
##################################################################################################

# ---------------- Variables ----------------

TB_NAME  := tb_top_fifo

# Default test name, can be overridden via command line
TESTNAME ?= base_test

VLIB     := /mnt/d/QuestaSim/win64/vlib.exe
VLOG     := /mnt/d/QuestaSim/win64/vlog.exe
VSIM     := /mnt/d/QuestaSim/win64/vsim.exe

COMPLOG  := comp.log
SIMLOG   := sim.log
WLF      := wave.wlf

# ---------------- Targets ----------------

.PHONY: all build run wave clean help

all: build run

build:
	# Create the default 'work' library required by Questasim
	$(VLIB) work
	$(VLOG) \
		-mfcu \
		-sv \
		-f compile.f \
		-l $(COMPLOG)

run:
	$(VSIM) \
		-c \
		-voptargs="+acc" \
		-wlf $(WLF) \
		-l $(SIMLOG) \
		+TESTNAME=$(TESTNAME) \
		$(TB_NAME) \
		-do "run -all; quit"

wave:
	# Launch Questasim GUI to view the generated waveform dataset
	cmd.exe /c start "" $(VSIM) -gui -view $(WLF)
clean:
	rm -rf work
	rm -rf *.log *.wlf transcript
	rm -rf modelsim.ini

help:
	@echo "make build"
	@echo "make run"
	@echo "make run TESTNAME=write_only_test"
	@echo "make all"
	@echo "make wave"
	@echo "make clean"