#include "include/io.h"
#include "include/screen.h"

void main() {
    clear_screen();
    move_cursor(5,0);
    // put_char('a');
    // put_char('\r');
    // put_char('\n');
    // print("hello\r\nhahaadsgatrafadbtrbfbevbeqrqegevdffegqerberwhergearhewbadsgatrafadbtrbfbevbeqrqegevdffegqerbe rwhergearhewbadsgat rafadbtrbfbevbeqrqegevdffegqerbe rwhergearhewbadsgatrafadbtrbfbevbeqrqegevdffegqerberwhergearhewb");

    print("\r\n---------------------------------------");
    print("\r\n|            Hello, ZerOS!            |");
    print("\r\n---------------------------------------");

    print("\r\n\r\n> ");

    while(1){}
}
