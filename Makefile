CC=iverilog

CFLAGS=-o

OBJECTS_SRC=$(shell ls src/*.v)
OBJECTS=$(OBJECTS_SRC:src/%.v=%)

TEST_OBJECTS=$(shell ls tests/*.v)

EXECHDL=vvp
#DATAFILE=$(shell grep $(OBJECTS) -e "\$dumpfile\(.*\)" | sed -E "s:.*dumpfile\(\"(.*)\"\);:\1:")

GRAPHL=gtkwave

all: $(OBJECTS_SRC)
	@echo $(OBJECTS)
	@echo $(OBJECTS_SRC)
	$(CC) $(CFLAGS) bin/main $(OBJECTS_SRC)

$(OBJECTS): % : $(OBJECTS_SRC) tests/test_%.v
	$(CC) $(CFLAGS) bin/$@ $?

graphs/%.vcd : %
	mem/set_memory.sh mem/imem.dat mem/$^.imem
	$(EXECHDL) bin/$^
	mv *.vcd graphs/$^.vcd

$(OBJECTS:%=graph-%): graph-% : graphs/%.vcd
	$(GRAPHL) $^

clean: 
	rm -f *.vcd $(TARGET)
	
