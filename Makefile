BOARD=tangnano9k
FAMILY=GW1N-9C

# FAMILY=GW1N-9C
DEVICE=GW1NR-LV9QN88PC6/I5

all: output.fs

# compile rust_hdl code
output.v: Cargo.toml src/*.rs Makefile
	cargo run --release

# Synthesis
output.json: output.v tangnano9k.cst
	yosys -p "read_verilog output.v; synth_gowin -top top -json output.json"

# Place and Route
output_pnr.json: output.json
	nextpnr-gowin --json output.json --freq 27 --write output_pnr.json --device ${DEVICE} --family ${FAMILY} --cst ${BOARD}.cst

# Generate Bitstream
# export PATH="$HOME/.local/bin:$PATH"
output.fs: output_pnr.json
	gowin_pack -d ${FAMILY} -o output.fs output_pnr.json

# Program Board
load: output.fs
	openFPGALoader -b ${BOARD} output.fs -f


# Generate Simulation
output_test.o: output.v output_tb.v
	iverilog -o output_test.o -s test output.v output_tb.v

# Run Simulation
test: output_test.o
	vvp output_test.o

# Cleanup build artifacts
clean:
	rm output.vcd output.fs output_test.o

.PHONY: load clean test
.INTERMEDIATE: output_pnr.json output.json output_test.o
