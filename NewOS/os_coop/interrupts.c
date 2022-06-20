#include "interrupts.h"

// ----- macros -----
#define IDT_TABLE_ITEMS 256

// ---- data types -----
#include <stdint.h>

struct idt_entry {
    uint16_t base_low16;
    uint16_t selector8;
    uint8_t  always_zero8;
    uint8_t  access8;
    uint16_t base_hi16;
} __attribute__((packed));

typedef struct idt_entry idt_entry_t;

struct idtr {
    uint16_t limit;
    uint32_t base;
} __attribute__((packed));

typedef struct idtr idtr_t;

// ----- Prototypes -----
void default_handler();
void dispatch();

// ----- Globals -----
idt_entry_t idt[IDT_TABLE_ITEMS];

// ----- functions -----

void init_idt_entry(idt_entry_t *entry, uint32_t base, uint16_t selector, uint8_t access) {
    entry->base_low16 = (uint16_t) (base & 0x0000FFFF);
    entry->selector8 = selector;
    entry->always_zero8 = 0;
    entry->access8 = access;
    entry->base_hi16 = (uint16_t) (0x0000FFFF & (base >> 16));

}

void lidt(idtr_t *idtr);
void init_idt() {
    for (int idx = 0; idx <= 31; idx++)
        init_idt_entry(idt+idx, (uint32_t) default_handler, 16, 0x8e); 
         
    init_idt_entry(idt+32, (uint32_t) dispatch, 16, 0x8e);

    for (int idx = 33; idx <= 255; idx++)
        init_idt_entry(idt+idx, 0, 0, 0); 
 
    idtr_t idtr;
    idtr.limit = sizeof(idt) - 1;
    idtr.base = (uint32_t) idt; 
    lidt(&idtr);
}

#include "screen.h"
void default_handler() {
    k_print("ERROR", 5, 0, 0);
    while (1);
}