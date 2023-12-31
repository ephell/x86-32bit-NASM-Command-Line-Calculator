APP = main

ADDITIONAL_SRCS = print.asm utility.asm input.asm op.asm
ADDITIONAL_OBJS = $(patsubst %.asm,%.o,$(ADDITIONAL_SRCS))

.PHONY: all clean

all: $(APP)

$(APP): main.o $(ADDITIONAL_OBJS)
	ld -m elf_i386 -o $(APP) main.o $(ADDITIONAL_OBJS)
%.o: %.asm
	nasm -f elf32 -o $@ -gdwarf $<

clean:
	rm -f $(APP) main.o $(ADDITIONAL_OBJS)
