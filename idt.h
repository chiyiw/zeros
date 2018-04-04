#include "include/type.h"
#include "include/screen.h"

// 64 bit
struct idt_item_struct
{
    u16 addr_low;   // 处理函数地址(低16位)
    u16 seg_sel;    // 段选择子
    u8 zero;
    u8 flag;
    u16 addr_high;
} __attribute__((packed)); // 取消编译器的对齐优化，采用定义的结构对齐

// 48 bit
struct idt_ptr_struct
{
    u16 limit;  // 段限长
    u32 base;   // idt基址
} __attribute__((packed));

struct idt_item_struct idt_items[256];
struct idt_ptr_struct idt_ptr;

void idt_item_set(u8 i, u32 handler_addr)
{
    idt_items[i].addr_low = handler_addr & 0xffff;
    idt_items[i].addr_high = handler_addr >> 16;
    idt_items[i].seg_sel = 0x08;
    idt_items[i].zero = 0;
    idt_items[i].flag = 0x8e;
}

extern void isr0();

void isr_handler()
{
    print("interrupt received ");
}

extern void irq0();

// 0号中断请求，timer中断
void irq_handler()
{
    // 发送0x20, 允许后续中断产生
    port_byte_out(0x20, 0x20);  
    // TODO if irq in 8..15, should set slave pic
    // port_byte_out(0xa0, 0x20);
    print("0");
}

extern void irq1();

// 1号中断请求，键盘中断
void irq1_handler()
{
    port_byte_out(0x20, 0x20);
    // 获取键盘键序号
    u8 c = port_byte_in(0x60);
    if (c == 30)
        put_c('A');
    else
        put_c('?');
}

extern void idt_load(u32);

void idt_init()
{
    idt_ptr.base = (u32)&idt_items;
    idt_ptr.limit = 256 * sizeof(struct idt_item_struct) -1;

    int i;
    for (i=0; i<32; i++)
        idt_item_set(i, (u32)isr0);

    port_byte_out(0x20, 0x11); // 设置pic工作方式
    port_byte_out(0xa0, 0x11);
    port_byte_out(0x21, 0x20); // 设置中断请求序号偏移
    port_byte_out(0xa1, 0x28);
    port_byte_out(0x21, 0x04); // 配置级联
    port_byte_out(0xa1, 0x02);
    port_byte_out(0x21, 0x01);
    port_byte_out(0xa1, 0x01);
    // 设置中断屏蔽字，1为屏蔽中断
    // 此处为 1111 1101，即只开启1号(键盘)中断
    port_byte_out(0x21, 0xfd);  
    port_byte_out(0xa1, 0xff);

    for (i=32; i<37; i++)
        idt_item_set(i, (u32)irq0);
    idt_item_set(33, (u32)irq1);

    idt_load((u32)&idt_ptr);
}
