// Physical memory allocator, for user processes,
// kernel stacks, page-table pages,
// and pipe buffers. Allocates whole 4096-byte pages.

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"

void freerange(void *pa_start, void *pa_end);

extern char end[]; // first address after kernel.
				   // defined by kernel.ld.

struct run
{
	struct run *next;
};

struct
{
	struct spinlock lock;
	struct run *freelist;
} kmem;

struct
{
	struct spinlock lock;
	int count[PHYSTOP / PGSIZE];
} refcnt;

void krefincr(uint64 pa)
{
	// acquire(&refcnt.lock);
	// int pn = (uint64)pa / PGSIZE;
	// refcnt.count[pn]++;
	// release(&refcnt.lock);
	acquire(&kmem.lock);
	int pn = pa / PGSIZE;
	if (pa > PHYSTOP)
	{
		panic("Physical Address limit exceeded");
	}
	// if ((uint64)pa > PHYSTOP || refcnt.count[pn] < 1)
	// 	panic("krefincr");

	refcnt.count[pn]++;
	release(&kmem.lock);
}

void krefdecr(uint64 pa)
{
	// acquire(&refcnt.lock);
	// int pn = (uint64)pa / PGSIZE;
	// refcnt.count[pn]--;
	// release(&refcnt.lock);
	// printf("here\n");
	acquire(&kmem.lock);
	// printf("here1\n");
	int pn = pa / PGSIZE;
	if (pa > PHYSTOP)
	{
		panic("Physical Address limit exceeded");
	}
	// if ((uint64)pa > PHYSTOP)
	// 	panic("krefdecr");

	refcnt.count[pn]--;
	// printf("%d\n", refcnt.count[pn]);
	release(&kmem.lock);
}

// int krefget(void *pa)
// {
// 	int cnt;
// 	acquire(&refcnt.lock);
// 	int pn = (uint64)pa / PGSIZE;
// 	cnt = refcnt.count[pn];
// 	release(&refcnt.lock);
// 	return cnt;
// }

void kinit()
{
	initlock(&kmem.lock, "kmem");
	// initlock(&refcnt.lock, "refcnt");

	// ** Must reset count array before freerange
	// for (int i = 0; i < (PGROUNDUP(PHYSTOP) - KERNBASE) / PGSIZE; i++)
	// 	refcnt.count[i] = 1;

	freerange(end, (void *)PHYSTOP);
}

void freerange(void *pa_start, void *pa_end)
{
	char *p;
	int pn;
	p = (char *)PGROUNDUP((uint64)pa_start);
	for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
	{
		pn = (uint64)p / PGSIZE;
		refcnt.count[pn] = 1;
		kfree(p);
	}
}

// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void kfree(void *pa)
{
	struct run *r;

	if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
		panic("kfree");

	r = (struct run *)pa;

	acquire(&kmem.lock);
	int pn = (uint64)r / PGSIZE;
	if (refcnt.count[pn] < 1)
	{
		release(&kmem.lock);
		panic("kfree_decr");
	}

	refcnt.count[pn] -= 1;
	if (refcnt.count[pn] > 0)
	{
		release(&kmem.lock);
		return;
	}
	release(&kmem.lock);

	struct run *d;

	if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
		panic("kfree");

	// Fill with junk to catch dangling refs.
	memset(pa, 1, PGSIZE);

	d = (struct run *)pa;

	acquire(&kmem.lock);
	d->next = kmem.freelist;
	kmem.freelist = d;
	release(&kmem.lock);
}

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
	struct run *r;

	acquire(&kmem.lock);
	r = kmem.freelist;
	if (r)
	{
		int pn = (uint64)r / PGSIZE;
		if (refcnt.count[pn] > 0)
		{
			release(&kmem.lock);
			return 0;
			// panic("refcnt kalloc");
		}
		refcnt.count[pn] = 1;
		kmem.freelist = r->next;
	}
	release(&kmem.lock);

	if (r)
	{
		memset((char *)r, 5, PGSIZE); // fill with junk
	}
	return (void *)r;
}
