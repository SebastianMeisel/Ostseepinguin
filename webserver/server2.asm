format ELF64
public _start

socket = 41
bind = 49
listen = 50
accept = 43
read = 0
write = 1
open = 2
ioctl = 16
exit = 60
close = 3
af_inet = 2
sock_stream = 1
o_rdonly = 0

termios_size equ 36
tcflsh equ 0

section '.text' executable
_start:
    mov rdi, af_inet
    mov rsi, sock_stream
    mov rdx, 0
    mov rax, socket
    syscall

    mov r12, rax ; socket fd
    mov rdi, r12
    mov rsi, address
    mov rdx, 16
    mov rax, bind
    syscall

    mov rdi, r12
    mov rsi, 10
    mov rax, listen
    syscall

accept_loop:
    mov rdi, r12
    mov rsi, 0
    mov rdx, 0
    mov rax, accept
    syscall

    mov r13, rax ; client socket fd

    ; Check for keypress to break loop
    mov rdi, 1 ; File descriptor for standard input (stdin)
    mov rsi, buffer_key ; Address of buffer to store keypress
    mov rdx, 1 ; Number of bytes to read (single character)
    mov rax, read ; Read from stdin
    syscall ; Read from stdin with non-blocking flag set

    cmp rax, 0 ; Check if read returned zero (no key pressed)
    je no_keypress ; Jump if no key pressed

    ; Key pressed, break the loop
    jmp break_loop

no_keypress:
    ; No key pressed, continue with other operations

    mov rdi, r13
    mov rsi, buffer
    mov rdx, 256
    mov rax, read
    syscall

    mov rdi, path
    mov rsi, o_rdonly
    mov rax, open
    syscall

    mov r14, rax ; save index.html fd

    mov rdi, rax
    mov rsi, buffer2
    mov rdx, 256
    mov rax, read
    syscall

    mov rdi, r13
    mov rsi, buffer2
    mov rdx, 256
    mov rax, write
    syscall

    jmp accept_loop

break_loop:
    ; Key pressed, break the loop

    mov rdi, r13
    mov rax, close
    syscall

    mov rdi, r14
    mov rax, close
    syscall

    mov rdi, 0
    mov rax, exit
    syscall

section '.data' writeable
address:
    dw af_inet
    dw 0x901f
    dd 0
    dq 0
buffer:
    db 256 dup(0)
buffer2:
    db 256 dup(0)
path:
    db 'index.html', 0
buffer_key:
    db 1
