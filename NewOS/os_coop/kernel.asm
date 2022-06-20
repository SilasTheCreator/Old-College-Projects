GLOBAL k_print
GLOBAL outportb
GLOBAL init_timer_dev

k_print:
    push ebp
    mov ebp, esp

    pusha
    pushf

    mov  esi, [ebp+8]
    mov  ecx, [ebp+12]
    mov  edi, [ebp+16]
    imul edi, 80
    add  edi, [ebp+20]
    imul edi, 2
    add  edi, 0xB8000

k_print_loop:
    cmp ecx, 0
    jle k_print_finish
    cmp edi, 0xB8000+25*80*2
    jge k_print_finish

    movsb
    mov BYTE [edi], 31
    inc edi
    dec ecx
    jmp k_print_loop

k_print_finish:
    popf
    popa
    pop ebp
    ret

outportb:
	push ebp
	mov ebp, esp
	push eax
	push edx

	mov eax, [ebp+12]
	mov edx, [ebp+8]
	out dx, al

	pop edx
	pop eax
	pop ebp
	ret

init_timer_dev:
	push ebp
	mov ebp, esp
	pushfd
	pushad
	
	mov edx, [ebp+8]
	mov ax, 1193
	imul dx, ax

	mov al, 0b00110110
	out 0x43, al

	mov ax, dx
	out 0x40, al
	xchg ah, al
	out 0x40, al

	popad
	popfd
	pop ebp
	ret