int add(int a, int b)
{
    return a + b;
}

void main() {
    char *video_memory = (char*)0xb8000;
    video_memory[0] = 'H';
    video_memory[1] = 0x7f;
    video_memory[2] = 'i';
    video_memory[3] = 0x6e;
    
    add(2,3);

    while(1){}
}
