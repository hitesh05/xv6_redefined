# xv6_redefined
## Overview

In this project we have made 2  system calls in xv6 operating system namely

<ol> <li> strace</li><li>sigreturn and sigalarm</li> <li> Scheduling with FCFS,Round Robin, Priority Based, MLFQ, Lottery based Scheduler</li> <li>Copy on write fork</li> </ol>

## Run instructions

There are 4 schedulers which can be run and by Default it is Round Robin. Others Flags are FCFS, PBS,MLFQ & LBS. To run with a scheduler do ``` make qemu SCHEDULER=<FLAG>```

## Task 1

Impement syscall strace:

<ul> <li>It intercepts and records the system calls which are called by a process during its
execution.</li>
<li>It takes one argument, an integer mask, whose bits specify which system
calls to trace</li>
</ul>

To make a syscall following steps are done: 

<ul> <li>Open file syscall.h and usys.pl and add the syscall</li> <li>Open file sysproc.c and add the file definition </li></ul>


    uint64
    sys_trace(void)
    {
      int n; // mask
      argint(0, &n);
      myproc()->mask = n;
      return 0;
    }

<ul><li> Open syscall.c and add syscall.c function and definition </li></ul>

```
    [SYS_sigalarm] sys_trace,
       {"trace", 1},
    int shift = 1 << num; // mask for num

```

Now we'll modify the proc functions, open the following files

<ul><li>Open file proc.h, and add variables</li>
    <li>Open proc.c and modify fork()</li>
<li>Add new file strace.c</li>
</ul>

Similarly we can add other system call, sigalarm and sigreturn by changing the similar above files and add a new condition in trap.c

```
		if (p != 0 && which_dev == 2 && p->checkifAlarmOn == 0)
		{
			// Save trapframe

			p->sigticks++;
			if (p->sigticks >= p->maxticks)
			{
				p->checkifAlarmOn = 1;
				struct trapframe *tf = kalloc();
				memmove(tf, p->trapframe, PGSIZE);
				p->alarm_handler = tf;

				p->trapframe->epc = p->handler;
			}
		}
```

Similarly new variables will be added in proc.h to keep in check the state of function when sigalarm is called.

```
struct trapframe * alarm_handler;
uint64 handler;

int checkifAlarmOn;
int sigticks;
int maxticks;
```

## Task 2

### FCFS

<ul><li>Implemented a policy that selects the process with the lowest creation time (creation time
    refers to the tick number when the process was created). </li>
<li>
    This will be non pre emptive in nature and was done by disabling timer interrupts in trap.c</li>
    <li>
    A new variable ctime was added in struct proc to store the creation time of the process in allocproc</li>
</ul>

```
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
```


### PBS

<ul><li>Similarly a **pre-emptive** Priority Based Scheduler is implemented  and m, the process which has the highest priority is given to CPU first.</li><li> Three variables sprior (static priority) ,  niceness and dprior (dynamic priority) were added to struct proc in order to store priority. </li>
<li>By default static priority is allocated to be 60 and schedules process less number of times</li>
    <li>A new system call set_priority was also
added to change the static priority of the process and reschedule it if its dynamic priority decreased
as a result of change. This is done in a similar way to which above system call is explained. </li>
</ul>

```
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
```

### MLFQ

<ul><li>Implemented a simplified preemptive MLFQ scheduler that allows processes to move
    between different priority queues based on their behavior and CPU bursts.</li><li>It has 5 priority levels and they are different for each timer ticks.</li> <li>Initially the process is on the highest time slice and keeps getting pre empted once it gets pushed to lower queues, priority 0 is the highest and priority 4 is lowest.</li>
    <li>We also have to check if a process volunatarily gives up its position, then anothe processer should takes it place</li>
<li>Starving is also prevented by implementing aging</li>
    <li>Round Robin is done for the priority number 4 i.e. lowest priority </li>
</ul>

```
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
```



### LBS

<ul><li> This is a preemptive scheduler that assigns a time slice to the process randomly in
proportion to the number of tickets it owns. </li>
<li> A system call set tickets is implemented using the steps mentioned above and sets number of tickets of calling a process, a process with higher tickets recieves a greater proportion of CPU cycles.</li>
    <li>It assigns the tickets using the rand() function i.e. randomly hence the name lottery based scheduler. This means the tickets and cycles will be random and implemented as detailed</li>
</ul>

```
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
```

### Task 3

### Copy on Write Fork
