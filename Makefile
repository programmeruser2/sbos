SRC = sbos.asm
.PHONY: all test
all: sbos.iso
sbos.iso: sbos.img
	mkdir -p iso
	cp sbos.img iso/sbos.img
	mkisofs -o sbos.iso -b sbos.img -no-emul-boot iso
sbos.img:
	nasm -f bin sbos.asm -o sbos.img
test: sbos.img
	qemu-system-i386 -drive file=sbos.img,index=0,if=floppy,format=raw 
debug: sbos.img
	qemu-system-i386 -s -S -drive file=sbos.img,index=0,if=floppy,format=raw 


