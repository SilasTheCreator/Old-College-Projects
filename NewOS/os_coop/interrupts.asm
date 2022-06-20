
GLOBAL lidt
; void lidt()
lidt:
    push ebp
    mov  ebp,esp
    push eax
    mov  eax, [ebp+8]
    lidt [eax]
    pop  eax
    pop  ebp
    ret