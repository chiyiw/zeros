#include "include/screen.h"
#include "idt.h"

void main() {
    clear_screen();
    move_cursor(5, 0);
 
    print("\r\n---------------------------------------");
    print("\r\n|            Hello, ZerOS!            |");
    print("\r\n---------------------------------------");

    print("\r\n\r\n> ");

    idt_init();
    __asm__ __volatile__("int $0x2");
    __asm__ __volatile__("sti");
}
