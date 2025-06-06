#include <sys/syscall.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <termios.h>
#include <unistd.h>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>    /* Definition of MAP_* and PROT_* constants */


//x86-64        rdi    rsi    rdx    r10    r8     r9     -
socket = SYS_socket
bind = SYS_bind
listen = SYS_listen
accept = SYS_accept
read = SYS_read
open = SYS_open
write = SYS_write
af_inet = AF_INET
sock_stream = SOCK_STREAM
o_rdonly = O_RDONLY
tciflush equ TCIFLUSH
timer_create = SYS_timer_create
clock = CLOCK_MONOTONIC
malloc =  MALLOC
mmap2 = SYS_mmap
prot_write = PROT_WRITE
map_private = MAP_PRIVATE
  map_anonymous = MAP_ANONYMOUS
einval = EINVAL
