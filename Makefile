all: os.img

os.img: head.bin kernel.bin
	cat head.bin kernel.bin > os.img

kernel.bin: kernel.o main_entry.o
	ld -o kernel.bin -Ttext 0x1000 main_entry.o kernel.o -m elf_i386 --oformat binary

kernel.o: kernel.c
	gcc -m32 -ffreestanding -c kernel.c -o kernel.o

head.bin: head.asm
	nasm head.asm -l head.lst -o head.bin

main_entry.o: main_entry.asm
	nasm main_entry.asm -f elf32 -o main_entry.o 

.PHONY: clean
clean:
	-rm *.o *.bin *.lst

run: all
	qemu-system-i386 os.img
