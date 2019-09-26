DEBUG=./debug

all: zeros.img

zeros.img: boot.bin kernel.bin
	cat boot.bin kernel.bin > zeros.img

boot.bin: boot.asm
	nasm boot.asm -o boot.bin -l ${DEBUG}/boot.lst

kernel.bin: start.o idt.o kernel.o
	ld -o kernel.bin -Ttext 0x1000 start.o idt.o kernel.o -m elf_i386 --oformat binary

start.o: start.asm
	nasm start.asm -f elf32 -o start.o -l ${DEBUG}/start.lst

idt.o: idt.asm
	nasm idt.asm -f elf32 -o idt.o -l ${DEBUG}/idt.lst

kernel.o: kernel.c include/io_port.h include/screen.h include/keyboard.h idt.h idt.o
	gcc -m32 -ffreestanding -c kernel.c -o kernel.o -std=gnu99 -Wall -Wextra -Wno-unused-parameter -O0 -g

kernel.debug: kernel.o boot.bin idt.o
	ld -o kernel.debug -Ttext 0x1000 start.o idt.o kernel.o -m elf_i386 -Map=${DEBUG}/symbol.map

debug: all kernel.debug
	pgrep qemu- | xargs kill -s 9
	qemu-system-i386 zeros.img -s -S -nographic &
	gdb -tui \
	-ex "file kernel.debug" \
	-ex "target remote localhost:1234" \
	-ex "set disassembly-flavor intel" \
	-ex "set disassemble-next-line on" \
	-ex "layout regs" \
	-ex "focus cmd" \
	-ex "b main" \
	-ex "c"

debug-clion: all
	qemu-system-i386 zeros.img -s -S

.PHONY: clean
clean:
	-rm *.o *.debug *.bin *.img

run: all
	qemu-system-i386 zeros.img

iso: kernel.o idt.o
	nasm -f elf32 iso/grub.asm -o iso/grub.o
	ld -m elf_i386 -T iso/link.ld -o iso/boot/iso.bin iso/grub.o idt.o kernel.o
	genisoimage -R                              \
                -b boot/grub/stage2_eltorito    \
                -no-emul-boot                   \
                -boot-load-size 4               \
                -input-charset utf8             \
                -boot-info-table                \
                -o zeros.iso                    \
                iso/
	rm iso/boot/iso.bin iso/grub.o
	qemu-system-i386 -cdrom zeros.iso
