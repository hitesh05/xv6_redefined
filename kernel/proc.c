#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "stdlib.h"

struct cpu cpus[NCPU];

struct proc proc[NPROC];

struct proc *initproc;

int nextpid = 1;
struct spinlock pid_lock;

extern void forkret(void);
static void freeproc(struct proc *p);

extern char trampoline[]; // trampoline.S

// helps ensure that wakeups of wait()ing
// parents are not lost. helps obey the
// memory model when using p->parent.
// must be acquired before any p->lock.
struct spinlock wait_lock;

#ifdef MLFQ
const int num_levels = 5;
Queue mlfq[5];
#endif

// #ifdef PBS
int calculateDynamicPriority(struct proc *process)
{
	process->niceness = 5;
	if (process->runTimePrev == 0)
	{
		if (process->sleepTimePrev == 0)
		{
			process->niceness = process->sleepTimePrev * 10;
			process->niceness /= (process->runTimePrev + process->sleepTimePrev);
		}
	}
	int retval = 0, checker = process->sprior - process->niceness + 5;
	if (checker > 100)
	{
		retval = 100;
	}
	else if (checker < 0)
	{
		;
	}
	else
	{
		retval = checker;
	}
	return retval;
}
// #endif

int set_priority(int static_prior, int pid)
{
	int old_prior = -1, checkIfAvailable = 0;
	if (static_prior < 0 || static_prior > 100)
	{
		printf("Priority is not right\n");
		return -1;
	}
	struct proc *i;
	for (i = proc; i < &proc[NPROC]; i++)
	{
		acquire(&i->lock);
		if (i->pid == pid)
		{
			checkIfAvailable = 1;
			release(&i->lock);
			break;
		}
		release(&i->lock);
	}
	if (checkIfAvailable == 1)
	{
		acquire(&i->lock);
		old_prior = i->sprior;
		i->sprior = static_prior;
		i->niceness = 5;
		i->dprior = calculateDynamicPriority(i);
		release(&i->lock);
	}
	else
	{
		return -1;
	}
	return old_prior;
}

#ifdef MLFQ
void pinit(void)
{
	int i = 0;
	while (i < num_levels)
	{
		mlfq[i].head = 0;
		mlfq[i].tail = 0;
		mlfq[i].size = 0;
		i++;
	}
}

void push(Queue *q, struct proc *pr)
{
	int tail = q->tail;
	q->p[tail] = pr;
	q->tail++;

	int x = NPROC + 1;
	if (q->tail == x)
	{
		q->tail = 0;
	}
	q->size++;
}

void pop(Queue *q)
{
	q->head++;
	int x = NPROC + 1;
	if (q->head == x)
	{
		q->head = 0;
	}

	q->size--;
}

struct proc *front(Queue *q)
{
	if (q->head != q->tail)
	{
		return q->p[q->head];
	}
	else
	{
		return 0;
	}
}

void qerase(Queue *q, int pid)
{
	int head = q->head;
	int tail = q->tail;
	int x = NPROC + 1;

	for (int curr = head; curr != tail; curr = (curr + 1) % x)
	{
		if (q->p[curr]->pid != pid)
		{
			continue;
		}
		struct proc *pr = q->p[curr];
		int z = (curr + 1) % x;
		q->p[curr] = q->p[z];
		q->p[z] = pr;
	}
	if (q->tail == 0)
	{
		q->tail = NPROC;
	}
	else
	{
		q->tail--;
	}
	q->size--;
}
#endif

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
	struct proc *p;

	for (p = proc; p < &proc[NPROC]; p++)
	{
		char *pa = kalloc();
		if (pa == 0)
			panic("kalloc");
		uint64 va = KSTACK((int)(p - proc));
		kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
	}
}

// initialize the proc table.
void procinit(void)
{
	struct proc *p;

	initlock(&pid_lock, "nextpid");
	initlock(&wait_lock, "wait_lock");
	for (p = proc; p < &proc[NPROC]; p++)
	{
		initlock(&p->lock, "proc");
		// p->state = UNUSED;
		p->kstack = KSTACK((int)(p - proc));
	}
}

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
	int id = r_tp();
	return id;
}

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
	int id = cpuid();
	struct cpu *c = &cpus[id];
	return c;
}

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
	push_off();
	struct cpu *c = mycpu();
	struct proc *p = c->proc;
	pop_off();
	return p;
}

int allocpid()
{
	int pid;

	acquire(&pid_lock);
	pid = nextpid;
	nextpid = nextpid + 1;
	release(&pid_lock);

	return pid;
}

// Look in the process table for an UNUSED proc.
// If found, initialize state required to run in the kernel,
// and return with p->lock held.
// If there are no free procs, or a memory allocation fails, return 0.
static struct proc *
allocproc(void)
{
	struct proc *p;

	for (p = proc; p < &proc[NPROC]; p++)
	{
		acquire(&p->lock);
		if (p->state == UNUSED)
		{
			goto found;
		}
		else
		{
			release(&p->lock);
		}
	}
	return 0;

found:
	p->pid = allocpid();
	p->state = USED;

#ifdef LBS
	// lbs init
	p->tickets = 1;
	p->time_spent = 0;
	p->time_avail = 0;
#endif

#ifdef MLFQ
	// mlfq init
	int slices[5] = {1, 2, 4, 8, 16};
	p->curr_queue = 0;
	p->ticks_spent = 0;
	p->enter_time = ticks;
	p->time_slice = slices[p->curr_queue];
	p->in_queue = 0;
	int i = 0;
	while (i < num_levels)
	{
		p->queue[i] = 0;
		i++;
	}
//
#endif

	// Allocate a trapframe page.
	if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
	{
		freeproc(p);
		release(&p->lock);
		return 0;
	}

	// An empty user page table.
	p->pagetable = proc_pagetable(p);
	if (p->pagetable == 0)
	{
		freeproc(p);
		release(&p->lock);
		return 0;
	}

	// Set up new context to start executing at forkret,
	// which returns to user space.
	memset(&p->context, 0, sizeof(p->context));
	p->context.ra = (uint64)forkret;
	p->context.sp = p->kstack + PGSIZE;

	// #ifdef PBS
	// PBS declaration
	p->creationTime = ticks;
	p->sprior = 60;
	p->niceness = 5;
	p->runTime = 0;
	p->endTime = 0;
	p->runTimePrev = 0;
	p->sleepTimePrev = 0;
	p->sleepStartTime = 0;
	p->sigticks=0;
	// #endif

	return p;
}

// free a proc structure and the data hanging from it,
// including user pages.
// p->lock must be held.
static void
freeproc(struct proc *p)
{
	if (p->trapframe)
		kfree((void *)p->trapframe);
	p->trapframe = 0;
	if (p->pagetable)
		proc_freepagetable(p->pagetable, p->sz);
	p->pagetable = 0;
	p->sz = 0;
	p->pid = 0;
	p->parent = 0;
	p->name[0] = 0;
	p->chan = 0;
	p->killed = 0;
	p->xstate = 0;
	p->state = UNUSED;
}

// Create a user page table for a given process, with no user memory,
// but with trampoline and trapframe pages.
pagetable_t
proc_pagetable(struct proc *p)
{
	pagetable_t pagetable;

	// An empty page table.
	pagetable = uvmcreate();
	if (pagetable == 0)
		return 0;

	// map the trampoline code (for system call return)
	// at the highest user virtual address.
	// only the supervisor uses it, on the way
	// to/from user space, so not PTE_U.
	if (mappages(pagetable, TRAMPOLINE, PGSIZE,
				 (uint64)trampoline, PTE_R | PTE_X) < 0)
	{
		uvmfree(pagetable, 0);
		return 0;
	}

	// map the trapframe page just below the trampoline page, for
	// trampoline.S.
	if (mappages(pagetable, TRAPFRAME, PGSIZE,
				 (uint64)(p->trapframe), PTE_R | PTE_W) < 0)
	{
		uvmunmap(pagetable, TRAMPOLINE, 1, 0);
		uvmfree(pagetable, 0);
		return 0;
	}

	return pagetable;
}

// Free a process's page table, and free the
// physical memory it refers to.
void proc_freepagetable(pagetable_t pagetable, uint64 sz)
{
	uvmunmap(pagetable, TRAMPOLINE, 1, 0);
	uvmunmap(pagetable, TRAPFRAME, 1, 0);
	uvmfree(pagetable, sz);
}

// a user program that calls exec("/init")
// assembled from ../user/initcode.S
// od -t xC ../user/initcode
uchar initcode[] = {
	0x17, 0x05, 0x00, 0x00, 0x13, 0x05, 0x45, 0x02,
	0x97, 0x05, 0x00, 0x00, 0x93, 0x85, 0x35, 0x02,
	0x93, 0x08, 0x70, 0x00, 0x73, 0x00, 0x00, 0x00,
	0x93, 0x08, 0x20, 0x00, 0x73, 0x00, 0x00, 0x00,
	0xef, 0xf0, 0x9f, 0xff, 0x2f, 0x69, 0x6e, 0x69,
	0x74, 0x00, 0x00, 0x24, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00};

// Set up first user process.
void userinit(void)
{
	struct proc *p;

	p = allocproc();
	initproc = p;

	// allocate one user page and copy initcode's instructions
	// and data into it.
	uvmfirst(p->pagetable, initcode, sizeof(initcode));
	p->sz = PGSIZE;

	// prepare for the very first "return" from kernel to user.
	p->trapframe->epc = 0;	   // user program counter
	p->trapframe->sp = PGSIZE; // user stack pointer

	safestrcpy(p->name, "initcode", sizeof(p->name));
	p->cwd = namei("/");

	p->state = RUNNABLE;

	release(&p->lock);
}

// Grow or shrink user memory by n bytes.
// Return 0 on success, -1 on failure.
int growproc(int n)
{
	uint64 sz;
	struct proc *p = myproc();

	sz = p->sz;
	if (n > 0)
	{
		if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
		{
			return -1;
		}
	}
	else if (n < 0)
	{
		sz = uvmdealloc(p->pagetable, sz, sz + n);
	}
	p->sz = sz;
	return 0;
}
int waitx(uint64 addr, uint *wtime, uint *rtime)
{
	struct proc *np;
	int havekids;
	int pid;
	struct proc *p = myproc();

	acquire(&wait_lock);

	for (;;)
	{
		// Scan through table looking for exited children.
		havekids = 0;
		for (np = proc; np < &proc[NPROC]; np++)
		{
			if (np->parent == p)
			{
				// make sure the child isn't still in exit() or swtch().
				acquire(&np->lock);

				havekids = 1;
				if (np->state == ZOMBIE)
				{
					// Found one.
					pid = np->pid;
					// #ifdef PBS
					*rtime = np->runTime;
					// printf("%d %d %d\n", np->endTime, np->creationTime, np->runTime);
					*wtime = np->endTime - np->creationTime - np->runTime;
					// #endif
					if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
											 sizeof(np->xstate)) < 0)
					{
						release(&np->lock);
						release(&wait_lock);
						return -1;
					}
					freeproc(np);
					release(&np->lock);
					release(&wait_lock);
					return pid;
				}
				release(&np->lock);
			}
		}

		// No point waiting if we don't have any children.
		if (!havekids || p->killed)
		{
			release(&wait_lock);
			return -1;
		}

		// Wait for a child to exit.
		sleep(p, &wait_lock); // DOC: wait-sleep
	}
}

// Create a new process, copying the parent.
// Sets up child kernel stack to return as if from fork() system call.
int fork(void) // checkthis
{
	int i, pid;
	struct proc *np;
	struct proc *p = myproc();

	// Allocate process.
	if ((np = allocproc()) == 0)
	{
		return -1;
	}

	// Copy user memory from parent to child.
	if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
	{
		freeproc(np);
		release(&np->lock);
		return -1;
	}

	np->mask = p->mask; // copying mask so that we can also trace child processes
#ifdef LBS
	np->tickets = p->tickets; // child inherits same number of tickets as parent
#endif

	np->sz = p->sz;

	// copy saved user registers.
	*(np->trapframe) = *(p->trapframe);

	// Cause fork to return 0 in the child.
	np->trapframe->a0 = 0;

	// increment reference counts on open file descriptors.
	for (i = 0; i < NOFILE; i++)
		if (p->ofile[i])
			np->ofile[i] = filedup(p->ofile[i]);
	np->cwd = idup(p->cwd);

	safestrcpy(np->name, p->name, sizeof(p->name));

	pid = np->pid;

	release(&np->lock);

	acquire(&wait_lock);
	np->parent = p;
	release(&wait_lock);

	acquire(&np->lock);
	np->state = RUNNABLE;
	release(&np->lock);

#ifdef MLFQ
	push(&mlfq[0], np);
	np->in_queue = 1;
#endif

	return pid;
}

// Pass p's abandoned children to init.
// Caller must hold wait_lock.
void reparent(struct proc *p)
{
	struct proc *pp;

	for (pp = proc; pp < &proc[NPROC]; pp++)
	{
		if (pp->parent == p)
		{
			pp->parent = initproc;
			wakeup(initproc);
		}
	}
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait().
void exit(int status)
{
	struct proc *p = myproc();

	if (p == initproc)
		panic("init exiting");

	// Close all open files.
	for (int fd = 0; fd < NOFILE; fd++)
	{
		if (p->ofile[fd])
		{
			struct file *f = p->ofile[fd];
			fileclose(f);
			p->ofile[fd] = 0;
		}
	}

	begin_op();
	iput(p->cwd);
	end_op();
	p->cwd = 0;

	acquire(&wait_lock);

	// Give any children to init.
	reparent(p);

	// Parent might be sleeping in wait().
	wakeup(p->parent);

	acquire(&p->lock);

	p->xstate = status;
	p->state = ZOMBIE;
	p->endTime = ticks;
	release(&wait_lock);

	// Jump into the scheduler, never to return.
	sched();
	panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int wait(uint64 addr)
{
	struct proc *pp;
	int havekids, pid;
	struct proc *p = myproc();

	acquire(&wait_lock);

	for (;;)
	{
		// Scan through table looking for exited children.
		havekids = 0;
		for (pp = proc; pp < &proc[NPROC]; pp++)
		{
			if (pp->parent == p)
			{
				// make sure the child isn't still in exit() or swtch().
				acquire(&pp->lock);

				havekids = 1;
				if (pp->state == ZOMBIE)
				{
					// Found one.
					pid = pp->pid;
					if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
											 sizeof(pp->xstate)) < 0)
					{
						release(&pp->lock);
						release(&wait_lock);
						return -1;
					}
					freeproc(pp);
					release(&pp->lock);
					release(&wait_lock);
					pp->endTime = ticks;
					return pid;
				}
				release(&pp->lock);
			}
		}

		// No point waiting if we don't have any children.
		if (!havekids || killed(p))
		{
			release(&wait_lock);
			return -1;
		}

		// Wait for a child to exit.
		sleep(p, &wait_lock); // DOC: wait-sleep
	}
}

void upd_time(void)
{
	struct proc *pr = proc;

	while (pr < &proc[NPROC])
	{
		acquire(&pr->lock);
		if(pr->state==4)
	// printf("%d\n",pr->state);	
		if (pr->state == RUNNING)
		{
			// #ifdef PBS
			pr->runTime++;
			pr->runTimePrev++;
// #endif
#ifdef LBS
			pr->time_spent++;
#endif
#ifdef MLFQ
			pr->queue[pr->curr_queue]++;
			pr->time_slice--;
#endif
		}
		release(&pr->lock);
		pr++;
	}
}

#ifdef MLFQ
struct proc *mlfq_sched(void)
{
	// aging
	struct proc *pr = proc;
	int x = NPROC;
	while (pr < &proc[x])
	{
		if (pr->state == RUNNABLE)
		{
			if (ticks - pr->enter_time >= 256)
			{
				int test = pr->in_queue;
				if (test)
				{
					int level = pr->curr_queue;
					qerase(&mlfq[level], pr->pid);
					pr->in_queue = 0;
				}
				if (pr->curr_queue != 0)
				{
					pr->curr_queue--;
				}
				else
				{
					pr->curr_queue = 0;
				}

				pr->enter_time = ticks;
			}
		}
		pr++;
	}

	pr = proc;
	while (pr < &proc[x])
	{
		if (pr->state == RUNNABLE)
		{
			int test = pr->in_queue;
			if (!test)
			{
				int level = pr->curr_queue;
				push(&mlfq[level], pr);
				pr->in_queue = 1;
			}
		}
		pr++;
	}

	int lev = 0;
	while (lev < num_levels)
	{

		while (mlfq[lev].size)
		{
			struct proc *pr = front(&mlfq[lev]);
			pop(&mlfq[lev]);
			pr->in_queue = 0;
			if (pr->state != RUNNABLE)
			{
				continue;
			}
			else
			{
				pr->enter_time = ticks;
				return pr;
			}
		}
		lev++;
	}

	return 0;
}
#endif

// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run.
//  - swtch to start running that process.
//  - eventually that process transfers control
//    via swtch back to the scheduler.
// #include "string.h"
void scheduler(void)
{
	struct proc *p;
	struct cpu *c = mycpu();

	c->proc = 0;
	for (;;)
	{
		// Avoid deadlock by ensuring that devices can interrupt.
		intr_on();
#ifdef DEFAULT
		for (p = proc; p < &proc[NPROC]; p++)
		{
			acquire(&p->lock);
			if (p->state == RUNNABLE)
			{
				// Switch to chosen process.  It is the process's job
				// to release its lock and then reacquire it
				// before jumping back to us.
				p->state = RUNNING;

				c->proc = p;
				swtch(&c->context, &p->context);
				// printf("%d %s\n",p->state,p->name);
				// Process is done running for now.
				// It should have changed its p->state before coming back.
				c->proc = 0;
			}
			release(&p->lock);
		}
#endif
#ifdef LBS
		for (p = proc; p < &proc[NPROC]; p++)
		{
			acquire(&p->lock);
			if (p->state == RUNNABLE)
			{
				// Switch to chosen process.  It is the process's job
				// to release its lock and then reacquire it
				// before jumping back to us.
				p->time_avail = (rand() % 64) * p->tickets;
				p->state = RUNNING;
				c->proc = p;
				swtch(&c->context, &p->context);

				// Process is done running for now.
				// It should have changed its p->state before coming back.
				c->proc = 0;
			}
			release(&p->lock);
		}
#endif
#ifdef FCFS
		// for (;;)
		// {
			// Avoid deadlock by ensuring that devices can interrupt.
			intr_on();
			struct proc *check = NULL;
			for (p = proc; p < &proc[NPROC]; p++)
			{
				if (p->state == RUNNABLE)
				{
					if (check == NULL)
					{
						check = p;
					}
					else if (p->creationTime < check->creationTime)
					{
						check = p;
					}
				}
			}
			if (check != NULL)
			{
				acquire(&check->lock);

				// Switch to chosen process.  It is the process's job
				// to release its lock and then reacquire it
				// before jumping back to us.
				check->state = RUNNING;
				c->proc = check;
				swtch(&c->context, &check->context);

				// Process is done running for now.
				// It should have changed its p->state before coming back.
				c->proc = 0;
				release(&check->lock);
			}
		// }
#endif
#ifdef PBS
		// for (;;)
		// {
			// Avoid deadlock by ensuring that devices can interrupt.
			intr_on();
			struct proc *check = NULL;
			for (p = proc; p < &proc[NPROC]; p++)
			{
				acquire(&p->lock);
				p->dprior = calculateDynamicPriority(p);
				if (p->state == RUNNABLE)
				{
					if (check == NULL)
					{
						check = p;
					}
					else if (p->dprior < check->dprior)
					{
						check = p;
					}
					else if (p->dprior == check->dprior)
					{
						if (p->countTimeCalled < check->countTimeCalled) // checkthis
						{
							check = p;
						}
						else if (p->countTimeCalled == check->countTimeCalled) // checkthis
						{
							if (p->creationTime > check->creationTime)
							{
								check = p;
							}
						}
					}
				}
				release(&p->lock);
			}
			if (check != NULL)
			{
				acquire(&check->lock);

				// Switch to chosen process.  It is the process's job
				// to release its lock and then reacquire it
				// before jumping back to us.
				check->countTimeCalled += 1;
				check->state = RUNNING;
				// checkthis
				c->proc = check;
				check->sleepTimePrev = 0;
				check->runTimePrev = 0;
				swtch(&c->context, &check->context);

				// Process is done running for now.
				// It should have changed its p->state before coming back.
				c->proc = 0;
				release(&check->lock);
			}
		// }
#endif

#ifdef MLFQ
		p = mlfq_sched();
		if (!p)
		{
			continue;
		}
		else
		{
			// acquire(&p->lock);
			int slices[5] = {1, 2, 4, 8, 16};
			int level = p->curr_queue;
			p->time_slice = slices[level];
			c->proc = p;
			p->state = RUNNING;
			swtch(&c->context, &p->context);
			c->proc = 0;
			p->enter_time = ticks;
			// release(&p->lock);
		}
#endif
	}
}

// Switch to scheduler.  Must hold only p->lock
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->noff, but that would
// break in the few places where a lock is held but
// there's no process.
void sched(void)
{
	int intena;
	struct proc *p = myproc();

	if (!holding(&p->lock))
		panic("sched p->lock");
	if (mycpu()->noff != 1)
		panic("sched locks");
	if (p->state == RUNNING)
		panic("sched running");
	if (intr_get())
		panic("sched interruptible");

	intena = mycpu()->intena;
	swtch(&p->context, &mycpu()->context);
	mycpu()->intena = intena;
}

// Give up the CPU for one scheduling round.
void yield(void)
{
	struct proc *p = myproc();
	acquire(&p->lock);
	p->state = RUNNABLE;
	sched();
	release(&p->lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
	static int first = 1;

	// Still holding p->lock from scheduler.
	release(&myproc()->lock);

	if (first)
	{
		// File system initialization must be run in the context of a
		// regular process (e.g., because it calls sleep), and thus cannot
		// be run from main().
		first = 0;
		fsinit(ROOTDEV);
	}

	usertrapret();
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
	struct proc *p = myproc();

	// Must acquire p->lock in order to
	// change p->state and then call sched.
	// Once we hold p->lock, we can be
	// guaranteed that we won't miss any wakeup
	// (wakeup locks p->lock),
	// so it's okay to release lk.

	acquire(&p->lock); // DOC: sleeplock1
	release(lk);

	// Go to sleep.
	p->chan = chan;
	p->state = SLEEPING;

	sched();

	// Tidy up.
	p->chan = 0;

	// Reacquire original lock.
	release(&p->lock);
	acquire(lk);
}

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
	struct proc *p;

	for (p = proc; p < &proc[NPROC]; p++)
	{
		if (p != myproc())
		{
			acquire(&p->lock);
			if (p->state == SLEEPING && p->chan == chan)
			{
				p->state = RUNNABLE;
#ifdef LBS
				p->time_spent = 0;
#endif
				// #ifdef PBS
				if (p->sleepStartTime != 0)
				{
					p->sleepTimePrev = ticks - p->sleepStartTime;
					p->totalSleep += p->sleepTimePrev;
				}
// #endif
#ifdef MLFQ
				p->enter_time = ticks;
				p->queue[p->curr_queue] = 0;
				p->in_queue = 1;
				int slices[5] = {1, 2, 4, 8, 16};
				p->time_slice = slices[p->curr_queue];
				push(&mlfq[p->curr_queue], p);
#endif
			}
			release(&p->lock);
		}
	}
}

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
	struct proc *p;

	for (p = proc; p < &proc[NPROC]; p++)
	{
		acquire(&p->lock);
		if (p->pid == pid)
		{
			p->killed = 1;
			if (p->state == SLEEPING)
			{
#ifdef LBS
				p->time_spent = 0;
#endif
				// #ifdef PBS
				p->sleepTimePrev = ticks - p->sleepStartTime;
				// #endif
				// Wake process from sleep().
				p->state = RUNNABLE;
#ifdef MLFQ
				p->enter_time = ticks;
				p->queue[p->curr_queue] = 0;
				p->in_queue = 1;
				int slices[5] = {1, 2, 4, 8, 16};
				p->time_slice = slices[p->curr_queue];
				push(&mlfq[p->curr_queue], p);
#endif
			}
			release(&p->lock);
			return 0;
		}
		release(&p->lock);
	}
	return -1;
}

void setkilled(struct proc *p)
{
	acquire(&p->lock);
	p->killed = 1;
	release(&p->lock);
}

int killed(struct proc *p)
{
	int k;

	acquire(&p->lock);
	k = p->killed;
	release(&p->lock);
	return k;
}

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
	struct proc *p = myproc();
	if (user_dst)
	{
		return copyout(p->pagetable, dst, src, len);
	}
	else
	{
		memmove((char *)dst, src, len);
		return 0;
	}
}

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
	struct proc *p = myproc();
	if (user_src)
	{
		return copyin(p->pagetable, dst, src, len);
	}
	else
	{
		memmove(dst, (char *)src, len);
		return 0;
	}
}

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck mastatechine further.
void procdump(void)
{
	static char *states[] = {
		[UNUSED] "unused",
		[USED] "used",
		[SLEEPING] "sleep ",
		[RUNNABLE] "runble",
		[RUNNING] "run   ",
		[ZOMBIE] "zombie"};
	struct proc *p;
	char *state;
// #ifdef PBS
//   printf("\nPID Priority State rtime wtime nrun\n");
//   for (p = proc; p < &proc[NPROC]; p++)
//   {
//     // acquire(&p->lock);
//     if (p->state == UNUSED)
//       continue;
//     if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
//       state = states[p->state];
//     else
//       state = "???";
//     printf("%d     %d     %s   %d    %d    %d\n", p->pid, p->dynamicpriority, state, p->runtime, p->totalsleeptime, p->schedcount);
//     // release(&p->lock);
//   }
//   return;
// #endif
	printf("\n");
	for (p = proc; p < &proc[NPROC]; p++)
	{
		if (p->state == UNUSED)
			continue;
		if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
			state = states[p->state];
		else
			state = "???";
		printf("%d %s %s %d %d", p->pid, state, p->name, p->runTime, p->countTimeCalled);
		printf("\n");
	}
}

// int settickets(int num){

// }
int alarmtest(void)
{
	
}