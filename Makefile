all: os.img

os.img: head.bin kernel.bin kernel.debug
	cat head.bin kernel.bin > os.img

kernel.bin: kernel.o main_entry.o idt.o
	ld -o kernel.bin -Ttext 0x1000 main_entry.o idt.o kernel.o -m elf_i386 --oformat binary

kernel.debug: kernel.o main_entry.o idt.o
	ld -o kernel.debug -Ttext 0x1000 main_entry.o idt.o kernel.o -m elf_i386

kernel.o: kernel.c include/io_port.h include/screen.h include/keyboard.h idt.h idt.o
	gcc -m32 -ffreestanding -c kernel.c -o kernel.o -std=gnu99 -Wall -Wextra -Wno-unused-parameter -O0 -g

head.bin: head.asm
	nasm head.asm -l head.lst -o head.bin

main_entry.o: main_entry.asm
	nasm main_entry.asm -f elf32 -o main_entry.o -l main_entry.lst

idt.o: idt.asm
	nasm idt.asm -f elf32 -o idt.o -l idt.lst

debug: all
	qemu-system-i386 os.img -s -S &
	gdb -tui \
	-ex "file kernel.debug" \
	-ex "target remote localhost:1234" \
	-ex "set disassembly-flavor intel" \
	-ex "set disassemble-next-line on" \
	-ex "layout regs" \
	-ex "focus cmd" \
	-ex "b main" \
	-ex "c"

debug-cline: all
	qemu-system-i386 os.img -s -S

.PHONY: clean
clean:
	-rm *.o *.lst *.debug *.bin *.img

run: all
	qemu-system-i386 os.img
