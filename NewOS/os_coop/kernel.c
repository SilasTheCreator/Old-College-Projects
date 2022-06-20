#include "screen.h"
#include "interrupts.h"
#include "queue.h"
#include <limits.h>
#include <stdint.h>


// -----  Prototypes -----
void p1();
void p2();
void p3();
void go();
void idle();
int create_process(void *code, uint32_t priority);
int convert_num_h(unsigned int num, char buf[]);
void convert_num(unsigned int num, char buf[]);
void setup_PIC();
void outportb(uint16_t port, uint8_t value);
void init_timer_dev(int ms);

// ----- Macros -----
#define FOREVER while(1)
#define BLANK_LINE "                                                                                "
#define BLANK_LINE_SIZE 80
#define IDT_TABLE_ITEMS 256
#define NULL 0

// ----- Globals -----
// idt_entry_t idt[IDT_TABLE_ITEMS];


// ----- Main -----

int main(){
    k_clearscr();
    print_border(0, 0, 24, 79);

    init_idt();
    init_rrq();
    init_timer_dev(50);
    setup_PIC();

    create_process(idle, 5);
    create_process(p1, 10);
    create_process(p2, 10);
    create_process(p3, 12);

    go();

    FOREVER;
}

// ----- Screen functions -----

void k_clearscr() {
    for (int row = 0; row < 25; row++)
        k_print(BLANK_LINE, BLANK_LINE_SIZE, row, 0);

}

void print_border(int sr, int sc, int er, int ec) {
    k_print("+", 1, sr, sc);
    k_print("+", 1, sr, ec);
    k_print("+", 1, er, sc);
    k_print("+", 1, er, ec);
    for (int col = sc+1; col < ec; col++) {
        k_print("-", 1, sr, col);
        k_print("-", 1, er, col);
    }   
    for (int row = sr+1; row < er; row++) {
        k_print("|", 1, row, sc);
        k_print("|", 1, row, ec);
    }
}

//Number conversions to prevent wingdings in process

int convert_num_h(unsigned int num, char buf[]) {
  if (num == 0) {
    return 0;
  }
  int idx = convert_num_h(num / 10, buf);
  buf[idx] = num % 10 + '0';
  buf[idx+1] = '\0';
  return idx + 1;
}


void convert_num(unsigned int num, char buf[]) {
  if (num == 0) {
    buf[0] = '0';
    buf[1] = '\0';
  } else {
    convert_num_h(num, buf);
  }
}

// Process and Idle code

void idle(){
    while(1){
        k_print("Process Idle running.../", 24, 24, 0);
        k_print("Process Idle running...\\", 24, 24, 0);
    }
}

void p1() {
    int i = 0;
    char intBuf[3] = {'0'};
    char* message = NULL;
    for(int k = 0; k< INT_MAX/1000; k++){
        message = "Process 1: ";
        k_print(message, 11, 5, 1);
        convert_num(i, intBuf);
        k_print(intBuf, 3, 5, 13);

        i = ((i+1) % 500);
    }
}

void p2() {
    int i = 0;
    char intBuf[3] = {'0'};
    char* message = NULL;
    for(int k = 0; k< INT_MAX/1000; k++){
        message = "Process 2: ";
        k_print(message, 11, 6, 1);
        convert_num(i, intBuf);
        k_print(intBuf, 3, 6, 13);

        i = ((i+1) % 500);
    }
}

void p3() {
    int i = 0;
    char intBuf[3] = {'0'};
    char* message = NULL;
    for(int k = 0; k< INT_MAX/1000; k++){
        message = "Process 3: ";
        k_print(message, 11, 7, 1);
        convert_num(i, intBuf);
        k_print(intBuf, 3, 7, 13);

        i = ((i+1) % 500);
    }

}

//PIC Setup

void setup_PIC() {
    // set up cascading mode:
    outportb(0x20, 0x11); // start 8259 master initialization
    outportb(0xA0, 0x11); // start 8259 slave initialization
    outportb(0x21, 0x20); // set master base interrupt vector (idt 32-38)
    outportb(0xA1, 0x28); // set slave base interrupt vector (idt 39-45)
    // Tell the master that he has a slave:
    outportb(0x21, 0x04); // set cascade ...
    outportb(0xA1, 0x02); // on IRQ2
    // Enabled 8086 mode:
    outportb(0x21, 0x01); // finish 8259 initialization
    outportb(0xA1, 0x01);
    // Reset the IRQ masks
    outportb(0x21, 0x0);
    outportb(0xA1, 0x0);
    // Now, enable the clock IRQ only 
    outportb(0x21, 0xfe); // Turn on the clock IRQ
    outportb(0xA1, 0xff); // Turn off all others
}