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

extern void idt_load(u32);

void idt_init()
{
    idt_ptr.base = (u32)&idt_items;
    idt_ptr.limit = 256 * sizeof(struct idt_item_struct) -1;

    int i;
    for (i=0; i<32; i++)
        idt_item_set(i, (u32)isr0);

    idt_load((u32)&idt_ptr);
}
