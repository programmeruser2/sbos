bits 16
org 0x7c00
start:
  ; setup segments
  xor ax, ax
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov sp, kernel_stack 
loop:
  ; execution falls through to here
  ; overwrite the timer handler because otherwise the previous handler will mess with it 
  mov ax, 0x20 
  mov word [ax], cs 
  add ax, 0x2 
  mov word [ax], timer_handler 
  ; loop 
  jmp $ 
timer_handler: 
  pusha 
  push ds 
  push es 
  push fs 
  push gs 
  push ax 
  xor ax, ax 
  mov ds, ax 
  mov es, ax 
  mov fs, ax 
  mov gs, ax
  pop ax 
panic: 
  mov si, panic_msg 
  call print_line
print:
  ; prints string in si
.print_repeat:
  lodsb
  cmp al, 0
  je .print_end
  mov ah, 0x0e
  int 0x10
  jmp .print_repeat
.print_end:
  ret
print_newline:
  mov ah, 0x0e
  mov al, 0x0d ; carriage return
  int 0x10
  mov ah, 0x0e
  mov al, 0x0a ; newline 
  int 0x10
  ret
print_line:
  call print
  call print_newline
  ret 
kernel_stack: equ 0x7b00 
panic_msg: db "Panic", 0 
times 510-($-$$) db 0
dw 0xaa55 
