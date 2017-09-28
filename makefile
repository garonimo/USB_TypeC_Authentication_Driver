###############################################################################
#
# ICARUS VERILOG & GTKWAVE MAKEFILE
# MADE BY WILLIAM GIBB FOR HACDC
# williamgibb@gmail.com
#
# USE THE FOLLOWING COMMANDS WITH THIS MAKEFILE
#	"make check" - compiles your verilog design - good for checking code
#	"make simulate" - compiles your design+TB & simulates your design
#	"make display" - compiles, simulates and displays waveforms
#
###############################################################################
#
# CHANGE THESE THREE LINES FOR YOUR DESIGN
#
#TOOL INPUT
SRC = USB_Host_model.v driver.v Responder.v get_digests.v challenge.v Error_response.v
TEST_FILE = Parameters.v Error_response.v
TESTBENCH = tb.v
TBOUTPUT = USB_Host_model.vcd #THIS NEEDS TO MATCH THE OUTPUT FILE
			#FROM YOUR TESTBENCH
###############################################################################
# BE CAREFUL WHEN CHANGING ITEMS BELOW THIS LINE
###############################################################################
#TOOLS
COMPILER = iverilog
SIMULATOR = vvp
VIEWER = gtkwave
#TOOL OPTIONS
COFLAGS = -v -o
SFLAGS = -v
SOUTPUT = -vcd		#SIMULATOR OUTPUT TYPE
#TOOL OUTPUT
COUTPUT = simulacion			#COMPILER OUTPUT
###############################################################################
#MAKE DIRECTIVES


all: $(TBOUTPUT)
	$(VIEWER) $(TBOUTPUT) &
#MAKE DEPENDANCIES
$(TBOUTPUT): $(COUTPUT)
	$(SIMULATOR) $(SOPTIONS) $(COUTPUT) $(SOUTPUT)

$(COUTPUT): $(TESTBENCH) $(SRC)
	$(COMPILER) $(COFLAGS) $(COUTPUT) $(TESTBENCH) $(SRC)

check : $(TESTBENCH) $(SRC)
	$(COMPILER) -v $(SRC)

simulate: $(COUTPUT)
	$(SIMULATOR) $(SFLAGS) $(COUTPUT) $(SOUTPUT)

compile_test:
	@iverilog -o prueba $(TEST_FILE)
	@echo "Test file(s): $(TEST_FILE) compiled succesfully"
	@rm prueba
