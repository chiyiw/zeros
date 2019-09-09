[org 0x7c00]

mov ax, 0x9000          ; 初始化栈顶地址
mov bp, ax
mov sp, bp

call load_kernel        ; 从磁盘第二扇区载入内核
call clear_screen

lgdt [gdt_descriptor]   ; 载入GDT
cli                     ; 屏蔽中断
mov eax, cr0
or eax, 0x01
mov cr0, eax            ; 切换到保护模式

jmp dword CODE_SEG:init_pm  ; 通过段选择子:偏移地址方式跳转

[bits 32]
init_pm:
    mov ax, DATA_SEG    ; 切换到保护模式后对段选择子进行修正
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ebp, 0x90000    ; 修改栈顶位置，之前由于寻址方式为ss:sp, 寻址方式已经改变
    mov esp, ebp
    jmp BEGIN_PM

BEGIN_PM:
    mov ebx, STRING         ; 输出字符串
    mov edx, VIDEO_MEMORY
    mov ah, WHITE_ON_BLACK
    call print_string_pm

    call KERNEL_ADDR        ; 跳到内核执行

    hlt
    jmp $


print_string_pm:
    mov al, [ebx]
    cmp al, 0
    je done
    mov [edx], ax

    add ebx, 1
    add edx, 2
    jmp print_string_pm
done:
    ret

[bits 16]
load_kernel:
    pusha
    mov bx, KERNEL_ADDR ; 将从磁盘读取的数据加载到内存的es:bx处，此时es=0x0000
    mov ah, 0x02        ; BIOS的13h中断，02为读取扇区
    ; mov dl, 0x80      ; 设备序号
    mov ch, 0x00        ; 磁道序号
    mov dh, 0x00        ; 磁头序号
    mov cl, 0x02        ; 扇区序号（boot_sect占用了第一个扇区，此处从第二个扇区开始读取）
    mov al, 12          ; 要读取的扇区数
    int 0x13            ; 调用BIOS的13h中断（从磁盘读取数据到内存）
    
    jc disk_error       ; 中断调用时会设置 CF(carry flag)=1，如果未设置，则发生了错误

    mov bl, 12          ; BIOS真正读取到的扇区数存储在 al中
    cmp bl, al          ; 此处检查是否读取到了一个扇区
    jne disk_error
    popa
    ret
disk_error:
    mov ah, 0x0e
    mov al, 'x'
    popa
    int 0x10

clear_screen:       ; 通过重置显示模式来清屏，会导致光标回到（0，0）
    mov ah,0x00
    mov al,0x03
    int 0x10
    ret


KERNEL_ADDR equ 0x1000      ; 内核载入地址
VIDEO_MEMORY equ 0xb8000    ; 显存位置
WHITE_ON_BLACK equ 0x0c     ; 背景色
STRING db 'we are in protected mode', 0


gdt_start:

gdt_null:
    dd 0x00         ; dd 4个字节 = 4 db = 2 dw 
    dd 0x00

gdt_code:
    dw 0xffff       ; 段限长 0 ~ 15 位，如果段属性 G(第11位)=0, 则单位为 B, G=1，则单位为 4KB。 
    dw 0x0          ; 基地址的  0 ~ 15 位
    db 0x0          ; 基地址的 17 ~ 23 位
    db 10011010b    ; 段属性  0 ~ 7 位。 0-3:TYPE  4:S  5-6:DPL  7:P （要倒着读）
    db 11001111b    ; 段限长 16 ~ 19 位， 段属性  8 ~ 11 位
    db 0x0          ; 基地址的 24 ~ 31 位

gdt_data:
    dw 0xffff
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0

gdt_end:


gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

times 510-($-$$) db 0
dw 0xaa55
