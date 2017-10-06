CC=iverilog
TARGET=register_bank

CFLAGS=-o $(TARGET)

OBJECTS=register_bank.v test.v

EXECHDL=vvp
DATAFILE=$(shell grep $(OBJECTS) -e "\$dumpfile\(.*\)" | sed -E "s:.*dumpfile\(\"(.*)\"\);:\1:")

GRAPHL=gtkwave

all: $(OBJECTS)
	$(CC) $(CFLAGS) $(OBJECTS)
	
$(DATAFILE) : all
	$(EXECHDL) $(TARGET)

exec: $(DATAFILE)

graph: $(DATAFILE)
	$(GRAPHL) $(DATAFILE)

clean: 
	rm -f *.vcd $(TARGET)
	
