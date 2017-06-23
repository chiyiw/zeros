#define REG_SCREEN_CTRL 0x3d4
#define REG_SCREEN_DATA 0x3d5
#define FONT_COLOR 0x0f
#define MAX_SCREEN_COLUMN 80
#define MAX_SCREEN_ROW 25
typedef unsigned short u16;
typedef unsigned char u8;
char *video_memory = 0xb8000;
u8 cursor_x;
u8 cursor_y;

u16 get_cursor_offset()
{
    u16 offset = 0;
    port_byte_out(REG_SCREEN_CTRL, 14);
    offset = port_byte_in(REG_SCREEN_DATA) << 8;    // 高8位  0000 0001 << 8 = 0000 0001 0000 0000 
    port_byte_out(REG_SCREEN_CTRL, 15);
    offset += port_byte_in(REG_SCREEN_DATA);        // 低8位  offset(0000 0001 0000 0000) + 0000 0010 
    return offset;
}

void set_cursor_offset(u16 offset)
{
    port_byte_out(REG_SCREEN_CTRL, 14);     // reg 14: high byte of cursor's offset
    port_byte_out(REG_SCREEN_DATA, offset >> 8);
    port_byte_out(REG_SCREEN_CTRL, 15);     // reg 15: low byte of cursor's offset
    port_byte_out(REG_SCREEN_DATA, offset & 0x00ff);
}

void move_cursor(u8 row, u8 col)
{
    u16 offset = row * 80 + col;
    set_cursor_offset(offset);
    cursor_x = col;
    cursor_y = row;
}

void clear_screen()
{
    int i;
    for (i=0; i < 80*25; i++)
    {
        video_memory[i*2] = ' ';
        video_memory[i*2+1] = FONT_COLOR;
    }
    move_cursor(0, 0);
}

void put_char(char c, u8 color)
{
    if (c == '\r') {
        cursor_x = 0;
    }else if (c == '\n') {
        cursor_y ++;
    }else{
        video_memory[(cursor_y*MAX_SCREEN_COLUMN+cursor_x)*2] = c;
        video_memory[(cursor_y*MAX_SCREEN_COLUMN+cursor_x)*2+1] = color;
        cursor_x++;
        if (cursor_x >= MAX_SCREEN_COLUMN) {
            cursor_x = 0;
            cursor_y++;
        }
    }
    move_cursor(cursor_y, cursor_x);
}

void put_c(char c)
{
    put_char(c, FONT_COLOR);
}

void print(char *str)
{
    while(*str != '\0')
    {
        put_c(*str++);
    }
}
