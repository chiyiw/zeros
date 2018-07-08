#ifndef _KEYBOARD_H
#define _KEYBOARD_H

#include "io_port.h"
#include "screen.h"

char key[58] = { ' ', ' ', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '+', ' ',
                ' ', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', ' ',
                ' ', 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', '`', ' ', 
                '\\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', ' ', ' ', ' ', ' '};

void keyboard_irq_handler()
{
    // 获取键盘键序号
    u8 c = port_byte_in(0x60);
    if (c >= 0 && c <= 57)
        put_c(key[c]);
}

#endif