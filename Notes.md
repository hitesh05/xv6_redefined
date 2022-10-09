qemu - emulator

## System calls

**user directory**
created hello.c program
linkers are used to link printf call

*usys.pl* is where all the system calls are. add any new syscall to this file first
*user.h* function signature

**kernel directory**
*main.c* -> mainc(void) -> initialisations -> tvinit() (trap vectors)
*tvinit.c*
*trap.c* -> trapframe is passed (user state is saved in trapframe)
*syscall.c* -> all system calls are routed through here
*syscall.h*
*sysproc.c*
*proc.c*
