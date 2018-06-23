[global idt_load]
idt_load:
    mov eax, [esp+4]
    lidt [eax]
    ret

[extern isr_handler]
[global isr0]
isr0:
    cli
    pusha
    call isr_handler
    popa
    sti
    iret

[extern irq_handler]
[global irq0]
irq0:
    cli
    pusha
    call irq_handler
    popa
    sti
    iret

[extern irq1_handler]
[global irq1]
irq1:
    cli
    pusha
    call irq1_handler
    popa
    sti
    iret