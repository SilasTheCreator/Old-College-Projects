EXTERN Running
EXTERN rr_schedule_first
EXTERN rr_schedule

GLOBAL go
GLOBAL dispatch

go:
    call rr_schedule_first
    jmp  go_rest

dispatch:
    pusha
    push ds
    push es
    push fs
    push gs
    mov  esi, [Running]
    mov  [esi], esp
    call rr_schedule
go_rest:
    mov  esi, [Running]
    mov  esp, [esi]
    pop  gs
    pop  fs,
    pop  es
    pop  ds
    popa
    push eax
    mov al, 0x20
    out 0x20, al
    pop eax
    iret