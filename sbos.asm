bits 16
org 0x7c00
prompt: db "$ ", 0
interpret_error_msg: db "Unknown command '", 0
line_buffer: equ 0x7e00 ; line buffer
commands: ; list of commands
  db "echo",
  db echo_command,
  db 0, 
  db 0 ; terminator
start:
  ; setup segments
  mov bp, 0x7c00
  xor ax, ax
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov sp, bp
loop:
  ; execution falls through to here
  ; loop
  mov si, prompt
  call print
  call read_line
  mov si, line_buffer
  call interpret
  jmp loop
print:
  ; prints string in si
  mov ah, 0x0e
.print_repeat:
  lodsb
  cmp al, 0
  je .print_end
  int 0x10
  jmp .print_repeat
.print_end:
  ret
print_newline:
  mov ah, 0x0e
  mov al, 0x0d ; carriage return
  int 0x10
  mov al, 0x0a ; newline 
  int 0x10
  ret
print_line:
  call print
  call print_newline
read_line:
  ; reads one line into line_buffer
  mov di, line_buffer
  ; clear string buffer
  mov [di], byte 0
  mov cx, 0 ; string length 
.read_line_repeat:
  ; read char
  mov ah, 0x00
  int 0x16
  ; is it a backspace?
  cmp al, 0x08
  ; jump to backspace handler
  je .read_line_backspace
  ; echo char
  mov ah, 0x0e
  ; char is already in al register
  int 0x10 
  ; is it a carriage return (enter)?
  cmp al, 0x0d
  ; if so, break out of loop
  je .read_line_end
  ; else, add to buffer
  stosb
  ; increment string length
  inc cx
  jmp .read_line_repeat
.read_line_backspace:
  ; do nothing if string length is 0
  cmp cx, 0
  je .read_line_repeat
  ; decrement pointer and length
  dec di
  dec cx
  ; move cursor back
  mov ah, 0x0e
  mov al, 0x08
  int 0x10
  ; output empty character
  mov al, ' '
  int 0x10
  ; and move the cursor back again with a backspace char
  mov al, 0x08
  int 0x10
  jmp .read_line_repeat
.read_line_end:
  ; add null terminator
  mov al, 0
  stosb
  ; print newline char
  mov ah, 0x0e
  mov al, 0x0a
  int 0x10
  ret
compare_strings:
  ; compares strings in the registers si and di, returns 0 in ax if false and 1 in ax otherwise
.compare_strings_loop:
  mov ax, [si]
  cmp [di], ax
  jne .compare_strings_not_equals
  cmp [si], byte 0
  je .compare_strings_equals
  inc si
  inc di
.compare_strings_not_equals:
  mov ax, 0
  ret
.compare_strings_equals:
  mov ax, 1
  ret
; interpreter
interpret:
  ; command string is in si register
  mov bx, 0
.interpret_loop:
  cmp [commands + bx], byte 0
  je .interpret_error
  mov di, [commands + bx]
  ; compare strings
  call compare_strings
  cmp ax, 1
  je .interpret_end
  add bx, 2
.interpret_end:
  add bx, 1
  call [commands + bx]
  ret
.interpret_error:
  mov di, si ; relocation
  mov si, interpret_error_msg
  call print
  mov si, di ; put back into si
  call print
  mov ah, 0x0e
  mov al, "'"
  int 0x10
  call print_newline
  ret

; commands
echo_command:
  call read_line
  mov si, line_buffer
  call print_line

times 510-($-$$) db 0
dw 0xaa55