SRC = sbos.asm
.PHONY: all test
all: sbos.iso
sbos.iso: sbos.img
	mkdir -p iso
	cp sbos.img iso/sbos.img
	mkisofs -o sbos.iso -b sbos.img -no-emul-boot iso
sbos.img:
	nasm -f bin sbos.asm -o sbos.img
test: sbos.iso
	qemu-system-i386 -cdrom sbos.iso
