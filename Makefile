all: os.img

os.img: head.bin kernel.bin
	cat head.bin kernel.bin > os.img

kernel.bin: kernel.o
	ld -m elf_i386 -o kernel.bin -Ttext 0x1000 kernel.o --oformat binary

kernel.o: kernel.c
	gcc -m32 -ffreestanding -c kernel.c -o kernel.o

head.bin: head.asm
	nasm head.asm -l head.lst -o head.bin

.PHONY: clean
clean:
	-rm *.o *.bin *.lst

run: all
	qemu-system-i386 os.img
