[extern isr_handler]

[global idt_load]
idt_load:
    mov eax, [esp+4]
    lidt [eax]
    ret

[global isr0]
isr0:
    cli
    pusha
    call isr_handler
    popa
    sti
    iret
