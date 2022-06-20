#ifndef PCB_H
#define PCB_H

#include <stdint.h>

struct pcb {
    uint32_t esp;
    uint32_t pid;
    struct pcb *next;
    uint32_t priority;
};
typedef struct pcb pcb_t;

struct pcbq {
    pcb_t *head;
    pcb_t *tail;   
};
typedef struct pcbq pcbq_t;

#endif