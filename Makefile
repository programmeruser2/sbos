SRC = sbos.asm
.PHONY: all test
all: sbos.iso
sbos.iso: sbos.img
	mkdir -p iso
	cp sbos.img iso/sbos.img
	mkisofs -o sbos.iso -b sbos.img -no-emul-boot iso
sbos.img: sbos.asm
	nasm -f bin sbos.asm -o sbos.img
test: sbos.img
	qemu-system-i386 -drive file=sbos.img,index=0,if=floppy,format=raw 
debug: sbos.img
	qemu-system-i386 -s -S -drive file=sbos.img,index=0,if=floppy,format=raw 
sbos_debug.elf: sbos.asm
	sed '/org 0x7c00/d' ./sbos.asm > /tmp/sbos_debug.asm	
	nasm -felf32 -g3 -F dwarf /tmp/sbos_debug.asm -o sbos_debug.o
	ld -Ttext=0x7c00 -melf_i386 sbos_debug.o -o sbos_debug.elf 
	rm *.o /tmp/sbos_debug.asm 
gdb:
	gdb -ex 'target remote localhost:1234' -ex 'set architecture i8086' -ex 'break *0x7c00' -ex 'continue' sbos_debug.elf




