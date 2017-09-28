CC=iverilog
TARGET=register_bank

CFLAGS=-o $(TARGET)

OBJECTS=register_bank.v test.v

GRAPHL=gtkwave

#graph: all
#	$(GRAPHL) *.vcd

all: $(OBJECTS)
	$(CC) $(CFLAGS) $(OBJECTS)
	
clean: 
	rm *.vcd $(TARGET)
	
