[extern isr_handler]
[extern irq_handler]
[extern irq1_handler]

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

[global irq0]
irq0:
    cli
    pusha
    call irq_handler
    popa
    sti
    iret

[global irq1]
irq1:
    cli
    pusha
    call irq1_handler
    popa
    sti
    iret