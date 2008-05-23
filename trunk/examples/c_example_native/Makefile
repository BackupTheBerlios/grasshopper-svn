TARGET = main

SRC = $(TARGET).c mt481c2m32b2tg.c pio.c sdram.c

CC = avr32-gcc
CFLAGS = -mcpu=ap7000 
# Define all object files.^M
OBJ = $(SRC:.c=.o) 

all: crt0.o prog

prog: $(OBJ)
	$(CC) $(CFLAGS) -Xlinker -T -Xlinker avr32elf_ap7000.x -mpart=ap7000 -nostartfiles -o $(TARGET).elf $(OBJ) crt0.o

%.o: %.c
	$(CC) $(CFLAGS) -c $<

crt0.o: crt0.S
	avr32-gcc -c -mcpu=ap7000 -I. -I.. crt0.S


download:
	avr32-objcopy -O binary $(TARGET).elf $(TARGET).bin
	avr32program program -v -e -f cfi@0 $(TARGET).bin

clean:
	rm *.o $(TARGET).elf
