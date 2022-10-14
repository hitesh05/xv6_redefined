#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "syscall.h"
#include "defs.h"

// Fetch the uint64 at addr from the current process.
int fetchaddr(uint64 addr, uint64 *ip)
{
  struct proc *p = myproc();
  if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    return -1;
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    return -1;
  return 0;
}

// Fetch the nul-terminated string at addr from the current process.
// Returns length of string, not including nul, or -1 for error.
int fetchstr(uint64 addr, char *buf, int max)
{
  struct proc *p = myproc();
  if (copyinstr(p->pagetable, buf, addr, max) < 0)
    return -1;
  return strlen(buf);
}

static uint64
argraw(int n)
{
  struct proc *p = myproc();
  switch (n)
  {
  case 0:
    return p->trapframe->a0;
  case 1:
    return p->trapframe->a1;
  case 2:
    return p->trapframe->a2;
  case 3:
    return p->trapframe->a3;
  case 4:
    return p->trapframe->a4;
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
  *ip = argraw(n);
}

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
  *ip = argraw(n);
}

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
}

// Prototypes for the functions that handle system calls.
extern uint64 sys_fork(void);
extern uint64 sys_exit(void);
extern uint64 sys_wait(void);
extern uint64 sys_pipe(void);
extern uint64 sys_read(void);
extern uint64 sys_kill(void);
extern uint64 sys_exec(void);
extern uint64 sys_fstat(void);
extern uint64 sys_chdir(void);
extern uint64 sys_dup(void);
extern uint64 sys_getpid(void);
extern uint64 sys_sbrk(void);
extern uint64 sys_sleep(void);
extern uint64 sys_uptime(void);
extern uint64 sys_open(void);
extern uint64 sys_write(void);
extern uint64 sys_mknod(void);
extern uint64 sys_unlink(void);
extern uint64 sys_link(void);
extern uint64 sys_mkdir(void);
extern uint64 sys_close(void);
extern uint64 sys_trace(void); // prototype for sys_trace added
extern uint64 sys_sigalarm(void);
extern uint64 sys_settickets(void);  // for LBS
extern uint64 sys_setpriority(void); // added for PBS scheduler
extern uint64 sys_waitx(void);
extern uint64 sys_sigreturn(void);
extern uint64 sys_alarmtest(void);
// An array mapping syscall numbers from syscall.h
// to the function that handles the system call.
static uint64 (*syscalls[])(void) = {
    [SYS_fork] sys_fork,
    [SYS_exit] sys_exit,
    [SYS_wait] sys_wait,
    [SYS_pipe] sys_pipe,
    [SYS_read] sys_read,
    [SYS_kill] sys_kill,
    [SYS_exec] sys_exec,
    [SYS_fstat] sys_fstat,
    [SYS_chdir] sys_chdir,
    [SYS_dup] sys_dup,
    [SYS_getpid] sys_getpid,
    [SYS_sbrk] sys_sbrk,
    [SYS_sleep] sys_sleep,
    [SYS_uptime] sys_uptime,
    [SYS_open] sys_open,
    [SYS_write] sys_write,
    [SYS_mknod] sys_mknod,
    [SYS_unlink] sys_unlink,
    [SYS_link] sys_link,
    [SYS_mkdir] sys_mkdir,
    [SYS_close] sys_close,
    [SYS_trace] sys_trace, // mapped sys_trace to syscall number (22)
    [SYS_setpriority] sys_setpriority,
    [SYS_settickets] sys_settickets,
    [SYS_waitx] sys_waitx,
    [SYS_sigalarm] sys_sigalarm,
    [SYS_sigreturn] sys_sigreturn,
    [SYS_alarmtest] sys_alarmtest,
};

typedef struct info
{
  char *name;
  int num;
} info;
// checkthis
info syscall_info[] = {
    {"fork", 0},
    {"exit", 1},
    {"wait", 1},
    {"pipe", 0},
    {"read", 3},
    {"kill", 2},
    {"exec", 2},
    {"fstat", 1},
    {"chdir", 1},
    {"dup", 1},
    {"getpid", 0},
    {"sbrk", 1},
    {"sleep", 1},
    {"uptime", 0},
    {"open", 2},
    {"write", 3},
    {"mknod", 3},
    {"unlink", 1},
    {"link", 2},
    {"mkdir", 1},
    {"close", 1},
    {"trace", 1},
    {"sigalarm", 2},
    {"setpriority", 2}, // CHECK
    {"settickets", 1},
    {"waitx", 3},
    {"sigalarm", 2},
    {"sigreturn", 0},
    {"alarmtest", 0},
};

void syscall(void)
{
  int num;
  struct proc *p = myproc();

  num = p->trapframe->a7; // return reg
  if (num > 0 && num < NELEM(syscalls) && syscalls[num])
  {
    int numargs = syscall_info[num - 1].num;
    int Args[numargs]; // to store value of registers acc to the number of args of the syscall
    int j = 0;
    while (j < numargs)
    {
      Args[j] = argraw(j);
      j++;
    }

    int shift = 1 << num; // mask for num
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();

    if (p->mask & shift)
    {
      printf("%d: syscall %s ", p->pid, syscall_info[num - 1].name);
      printf("(");
      int i = 0;
      while (i < numargs)
      {
        printf("%d ", Args[i]);
        i++;
      }
      printf(")");
      printf(" -> %d\n", p->trapframe->a0);
    }
  }
  else
  {
    printf("%d %s: unknown sys call %d\n",
           p->pid, p->name, num);
    p->trapframe->a0 = -1;
  }
}
