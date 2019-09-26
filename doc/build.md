

## 关于 iso 打包

apt-get install grub-pc-bin
https://wiki.osdev.org/Bootable_El-Torito_CD_with_GRUB_Legacy

## boch

bochs -f bochsrc.txt -q

## 为什么使用 ld -Ttext 0x1000 ?

通常情况下，一个 test.c 经过三个步骤成为 可执行文件.

```bash
gcc -m32 -S test.c -g -o test.s  # 编译为汇编代码
as --32 test.s -o test.o         # 汇编为可重定位文件
ld -m elf_i386 a.o -o a.out      # 链接为可执行文件

> nm a.o
00000000 T main

> nm a.out
080490c8 R __bss_start
080490c8 R _edata
080490c8 R _end
08048074 T main
         U _start
```

链接时根据 elf_i386 规范，设置了偏移，默认偏移值为 0x08048000, 即二进制指令会加载到
内存的这个地址上去运行，符号表中的 标号 是对应内存地址的别名.

ld 用于把多个 可重定位文件(Relocatable File) 链接为 二进制文件。
其整合了 代码段、数据段、调试信息等内容，可以通过 -Map 选项查看链接后的符号表。

> 符号相当于对内存地址的别名
`0x00001010    idt_load` 代表在代码中引用符号 idt_load 实际上是引用的 0x1010

-Ttext 选项用于设置代码段偏移，如果不设置，默认值为 0x8048000，这是 Unix 标准ELF放置
代码段的位置。

由于 0x8048000 对于16位寄存器来说无法放置，因此我们在编译时设置为自定义值 0x1000，代表
符号表偏移, 这使得在代码中引用某个符号时，引用的地址是 0x1000 + 原地址.

GDB 可以通过 info address symbol 查看某个 symbol 加载的目的内存地址.

```bash
(gdb) info address _start
Symbol "_start" is at 0x1000 in a file compiled without debugging.

(gdb) x/32x 0x1000
0x1000 <_start>:            0x00000000    0x00000000    0x00000000    0x00000000
0x1010 <idt_load>:          0x00000000    0x00000000    0x00000000    0x00000000
0x1020 <irq0>:              0x00000000    0x00000000    0x00000000    0x00000000
0x1030 <port_byte_in>:      0x00000000    0x00000000    0x00000000    0x00000000
0x1040 <port_byte_in+16>:   0x00000000    0x00000000    0x00000000    0x00000000
0x1050 <port_byte_out+3>:   0x00000000    0x00000000    0x00000000    0x00000000
0x1060 <port_byte_out+19>:  0x00000000    0x00000000    0x00000000    0x00000000
0x1070 <port_word_in+5>:    0x00000000    0x00000000    0x00000000    0x00000000
(gdb)

```

可以看到内存的 `_start` 符号代表 0x1000，其他符号也是从该处开始映射. 但 0x1000 处的内容
是空的，因为还没从第二扇区读入内存，读入后，跳转到 0x1000 处执行，使得符号与实际指令地址一
致.
