#include "pcb.h"

//Prototype
void go();
void rr_enqueue(pcb_t *pcb);
void enqueue_priority(pcbq_t *q, pcb_t *item);


#define HEAP_SIZE 1024*20
char memory[HEAP_SIZE];
uint32_t mtop = 0;

uint32_t next_pid = 0;

void default_handler();

void *malloc(uint32_t size) {
    if (mtop + size >= HEAP_SIZE)
        return 0;
    void *mem = memory + mtop;
    mtop += size;
    return mem;
}

void rr_enqueue(pcb_t *pcb);

int create_process(void *code_addr, uint32_t priority) {
    uint32_t *st = (uint32_t *) malloc(1024);
    if (st == 0) {
        return -1;
    }

    st += 1024;
    st--;
    *st = (uint32_t)&go; //go function
    st--;
    *st = 0x200;  // eflags

    st--;
    *st = 16;  //  CS

    st--;
    *st = (uint32_t) code_addr;

    for (int i = 0; i < 8; i++) {
        st--;
        *st = 0;
    }

    for (int i = 0; i < 4; i++) {
        st--;
        *st = 8;
    }

    pcb_t *pcb = (pcb_t *) malloc(sizeof(pcb_t));
    if (pcb == 0)
        return -2;

    pcb->esp = (uint32_t) st;
    pcb->pid = next_pid++;
    pcb->priority = priority; 


    rr_enqueue(pcb);

    return 0;

}


