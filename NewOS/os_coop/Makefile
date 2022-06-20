# Bootable hello world
LD=ld
CC =gcc
NASM=nasm
OBJCOPY=objcopy

COPTS=-g -m32 -fno-stack-protector -c
NASMOPTS=-g -f elf -F dwarf

all: boot1 boot2

boot1: boot1.asm kernel.exe
	$(NASM) -DENTRY=0x$(shell nm kernel.exe | grep main | cut -d " " -f 1) boot1.asm

boot2: kernel.exe
	$(OBJCOPY) -j .text* -j .data* -j .rodata* -S -O binary kernel.exe boot2

kernel.exe: kernel_c.o kernel_asm.o queue_c.o interrupts_c.o interrupts_asm.o dispatcher_asm.o process_c.o
	$(LD) -g -melf_i386 -Ttext 0x10000 -e main -o $@ $^

%_c.o: %.c
	$(CC) $(COPTS) -o $@ $<

%_asm.o: %.asm
	$(NASM) $(NASMOPTS) -o $@ $<

.PHONY: clean install run debug
clean:
	rm *.o *.exe boot1 boot2 a.img

install:
	yes | bximage -mode=create -fd=1.44M -q a.img
	/sbin/mkdosfs a.img
	dd if=boot1 of=a.img bs=1 count=512 conv=notrunc
	mcopy -o boot2 a:BOOT2

run:
	qemu-system-i386 -boot a -fda a.img

debug:
	qemu-system-i386 -S -s -boot a -fda a.img &
	ddd --debugger 'gdb -ex "target remote localhost:1234" -ex "break main" -ex "continue"' kernel.exe

debug_qonly:
	qemu-system-i386 -S -s -boot a -fda a.img