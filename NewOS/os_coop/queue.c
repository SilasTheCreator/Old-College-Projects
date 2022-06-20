#include <stdint.h>
#include "pcb.h"
#define NULL 0

pcbq_t RR_q;
pcb_t *Running;

void initq(pcbq_t *q) {
    q->head = q->tail = 0;
}

void enqueue_priority(pcbq_t *q, pcb_t *item){
    pcb_t *cur = q->head;
    item->next = NULL;
    if(q->head == NULL){
        q->head = q->tail = item;
        return;
    }
    else if(item->priority > q->head->priority){
        q->head = item;
        q->head->next = cur;
    }else if(item->priority < q->tail->priority){
        q->tail->next = item;
        q->tail = item;
    }else{
        while(cur->next != NULL && cur->next->priority >= cur->priority){
            cur = cur->next;
        }
        item->next = cur->next;
        cur->next = item;
    }
}

void enqueue(pcbq_t *q, pcb_t *item) {
    item->next = 0;  
    if (q->tail == 0) {
        q->tail = q->head = item;
    } else {
        q->tail->next = item;
        q->tail = item;
    }
}

void default_handler();
pcb_t *dequeue(pcbq_t *q) {
    if (q->head == 0) {
        default_handler();
    }
    pcb_t *item = q->head;
    q->head = q->head->next;
    return item;
}

void init_rrq() {
    Running = 0;
    initq(&RR_q);
}

// returns 1 if no process is on the ready Q
int rr_schedule() {
    if (Running == 0) {
        default_handler();
    }
    if (RR_q.head == 0)
        return 1;    // running process is the only one in the system
    enqueue_priority(&RR_q, Running);
    Running = dequeue(&RR_q);
    return 0;
}

void rr_schedule_first() {
    if (RR_q.head == 0)
        default_handler();
    Running = dequeue(&RR_q);
}

void rr_enqueue(pcb_t *pcb) {
    enqueue_priority(&RR_q, pcb);
}

