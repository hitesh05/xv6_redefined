
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	bb013103          	ld	sp,-1104(sp) # 80008bb0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	bbe70713          	addi	a4,a4,-1090 # 80008c10 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	44c78793          	addi	a5,a5,1100 # 800064b0 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fdbad67>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	fa478793          	addi	a5,a5,-92 # 80001052 <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000102:	715d                	addi	sp,sp,-80
    80000104:	e486                	sd	ra,72(sp)
    80000106:	e0a2                	sd	s0,64(sp)
    80000108:	fc26                	sd	s1,56(sp)
    8000010a:	f84a                	sd	s2,48(sp)
    8000010c:	f44e                	sd	s3,40(sp)
    8000010e:	f052                	sd	s4,32(sp)
    80000110:	ec56                	sd	s5,24(sp)
    80000112:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000114:	04c05663          	blez	a2,80000160 <consolewrite+0x5e>
    80000118:	8a2a                	mv	s4,a0
    8000011a:	84ae                	mv	s1,a1
    8000011c:	89b2                	mv	s3,a2
    8000011e:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000120:	5afd                	li	s5,-1
    80000122:	4685                	li	a3,1
    80000124:	8626                	mv	a2,s1
    80000126:	85d2                	mv	a1,s4
    80000128:	fbf40513          	addi	a0,s0,-65
    8000012c:	00003097          	auipc	ra,0x3
    80000130:	92c080e7          	jalr	-1748(ra) # 80002a58 <either_copyin>
    80000134:	01550c63          	beq	a0,s5,8000014c <consolewrite+0x4a>
      break;
    uartputc(c);
    80000138:	fbf44503          	lbu	a0,-65(s0)
    8000013c:	00000097          	auipc	ra,0x0
    80000140:	794080e7          	jalr	1940(ra) # 800008d0 <uartputc>
  for(i = 0; i < n; i++){
    80000144:	2905                	addiw	s2,s2,1
    80000146:	0485                	addi	s1,s1,1
    80000148:	fd299de3          	bne	s3,s2,80000122 <consolewrite+0x20>
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4a>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7119                	addi	sp,sp,-128
    80000166:	fc86                	sd	ra,120(sp)
    80000168:	f8a2                	sd	s0,112(sp)
    8000016a:	f4a6                	sd	s1,104(sp)
    8000016c:	f0ca                	sd	s2,96(sp)
    8000016e:	ecce                	sd	s3,88(sp)
    80000170:	e8d2                	sd	s4,80(sp)
    80000172:	e4d6                	sd	s5,72(sp)
    80000174:	e0da                	sd	s6,64(sp)
    80000176:	fc5e                	sd	s7,56(sp)
    80000178:	f862                	sd	s8,48(sp)
    8000017a:	f466                	sd	s9,40(sp)
    8000017c:	f06a                	sd	s10,32(sp)
    8000017e:	ec6e                	sd	s11,24(sp)
    80000180:	0100                	addi	s0,sp,128
    80000182:	8b2a                	mv	s6,a0
    80000184:	8aae                	mv	s5,a1
    80000186:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000188:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    8000018c:	00011517          	auipc	a0,0x11
    80000190:	bc450513          	addi	a0,a0,-1084 # 80010d50 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	c14080e7          	jalr	-1004(ra) # 80000da8 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019c:	00011497          	auipc	s1,0x11
    800001a0:	bb448493          	addi	s1,s1,-1100 # 80010d50 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a4:	89a6                	mv	s3,s1
    800001a6:	00011917          	auipc	s2,0x11
    800001aa:	c4290913          	addi	s2,s2,-958 # 80010de8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    800001ae:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001b0:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001b2:	4da9                	li	s11,10
  while(n > 0){
    800001b4:	07405b63          	blez	s4,8000022a <consoleread+0xc6>
    while(cons.r == cons.w){
    800001b8:	0984a783          	lw	a5,152(s1)
    800001bc:	09c4a703          	lw	a4,156(s1)
    800001c0:	02f71763          	bne	a4,a5,800001ee <consoleread+0x8a>
      if(killed(myproc())){
    800001c4:	00002097          	auipc	ra,0x2
    800001c8:	af4080e7          	jalr	-1292(ra) # 80001cb8 <myproc>
    800001cc:	00003097          	auipc	ra,0x3
    800001d0:	800080e7          	jalr	-2048(ra) # 800029cc <killed>
    800001d4:	e535                	bnez	a0,80000240 <consoleread+0xdc>
      sleep(&cons.r, &cons.lock);
    800001d6:	85ce                	mv	a1,s3
    800001d8:	854a                	mv	a0,s2
    800001da:	00002097          	auipc	ra,0x2
    800001de:	24e080e7          	jalr	590(ra) # 80002428 <sleep>
    while(cons.r == cons.w){
    800001e2:	0984a783          	lw	a5,152(s1)
    800001e6:	09c4a703          	lw	a4,156(s1)
    800001ea:	fcf70de3          	beq	a4,a5,800001c4 <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ee:	0017871b          	addiw	a4,a5,1
    800001f2:	08e4ac23          	sw	a4,152(s1)
    800001f6:	07f7f713          	andi	a4,a5,127
    800001fa:	9726                	add	a4,a4,s1
    800001fc:	01874703          	lbu	a4,24(a4)
    80000200:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    80000204:	079c0663          	beq	s8,s9,80000270 <consoleread+0x10c>
    cbuf = c;
    80000208:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000020c:	4685                	li	a3,1
    8000020e:	f8f40613          	addi	a2,s0,-113
    80000212:	85d6                	mv	a1,s5
    80000214:	855a                	mv	a0,s6
    80000216:	00002097          	auipc	ra,0x2
    8000021a:	7ec080e7          	jalr	2028(ra) # 80002a02 <either_copyout>
    8000021e:	01a50663          	beq	a0,s10,8000022a <consoleread+0xc6>
    dst++;
    80000222:	0a85                	addi	s5,s5,1
    --n;
    80000224:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    80000226:	f9bc17e3          	bne	s8,s11,800001b4 <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    8000022a:	00011517          	auipc	a0,0x11
    8000022e:	b2650513          	addi	a0,a0,-1242 # 80010d50 <cons>
    80000232:	00001097          	auipc	ra,0x1
    80000236:	c2a080e7          	jalr	-982(ra) # 80000e5c <release>

  return target - n;
    8000023a:	414b853b          	subw	a0,s7,s4
    8000023e:	a811                	j	80000252 <consoleread+0xee>
        release(&cons.lock);
    80000240:	00011517          	auipc	a0,0x11
    80000244:	b1050513          	addi	a0,a0,-1264 # 80010d50 <cons>
    80000248:	00001097          	auipc	ra,0x1
    8000024c:	c14080e7          	jalr	-1004(ra) # 80000e5c <release>
        return -1;
    80000250:	557d                	li	a0,-1
}
    80000252:	70e6                	ld	ra,120(sp)
    80000254:	7446                	ld	s0,112(sp)
    80000256:	74a6                	ld	s1,104(sp)
    80000258:	7906                	ld	s2,96(sp)
    8000025a:	69e6                	ld	s3,88(sp)
    8000025c:	6a46                	ld	s4,80(sp)
    8000025e:	6aa6                	ld	s5,72(sp)
    80000260:	6b06                	ld	s6,64(sp)
    80000262:	7be2                	ld	s7,56(sp)
    80000264:	7c42                	ld	s8,48(sp)
    80000266:	7ca2                	ld	s9,40(sp)
    80000268:	7d02                	ld	s10,32(sp)
    8000026a:	6de2                	ld	s11,24(sp)
    8000026c:	6109                	addi	sp,sp,128
    8000026e:	8082                	ret
      if(n < target){
    80000270:	000a071b          	sext.w	a4,s4
    80000274:	fb777be3          	bgeu	a4,s7,8000022a <consoleread+0xc6>
        cons.r--;
    80000278:	00011717          	auipc	a4,0x11
    8000027c:	b6f72823          	sw	a5,-1168(a4) # 80010de8 <cons+0x98>
    80000280:	b76d                	j	8000022a <consoleread+0xc6>

0000000080000282 <consputc>:
{
    80000282:	1141                	addi	sp,sp,-16
    80000284:	e406                	sd	ra,8(sp)
    80000286:	e022                	sd	s0,0(sp)
    80000288:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000028a:	10000793          	li	a5,256
    8000028e:	00f50a63          	beq	a0,a5,800002a2 <consputc+0x20>
    uartputc_sync(c);
    80000292:	00000097          	auipc	ra,0x0
    80000296:	564080e7          	jalr	1380(ra) # 800007f6 <uartputc_sync>
}
    8000029a:	60a2                	ld	ra,8(sp)
    8000029c:	6402                	ld	s0,0(sp)
    8000029e:	0141                	addi	sp,sp,16
    800002a0:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002a2:	4521                	li	a0,8
    800002a4:	00000097          	auipc	ra,0x0
    800002a8:	552080e7          	jalr	1362(ra) # 800007f6 <uartputc_sync>
    800002ac:	02000513          	li	a0,32
    800002b0:	00000097          	auipc	ra,0x0
    800002b4:	546080e7          	jalr	1350(ra) # 800007f6 <uartputc_sync>
    800002b8:	4521                	li	a0,8
    800002ba:	00000097          	auipc	ra,0x0
    800002be:	53c080e7          	jalr	1340(ra) # 800007f6 <uartputc_sync>
    800002c2:	bfe1                	j	8000029a <consputc+0x18>

00000000800002c4 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002c4:	1101                	addi	sp,sp,-32
    800002c6:	ec06                	sd	ra,24(sp)
    800002c8:	e822                	sd	s0,16(sp)
    800002ca:	e426                	sd	s1,8(sp)
    800002cc:	e04a                	sd	s2,0(sp)
    800002ce:	1000                	addi	s0,sp,32
    800002d0:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002d2:	00011517          	auipc	a0,0x11
    800002d6:	a7e50513          	addi	a0,a0,-1410 # 80010d50 <cons>
    800002da:	00001097          	auipc	ra,0x1
    800002de:	ace080e7          	jalr	-1330(ra) # 80000da8 <acquire>

  switch(c){
    800002e2:	47d5                	li	a5,21
    800002e4:	0af48663          	beq	s1,a5,80000390 <consoleintr+0xcc>
    800002e8:	0297ca63          	blt	a5,s1,8000031c <consoleintr+0x58>
    800002ec:	47a1                	li	a5,8
    800002ee:	0ef48763          	beq	s1,a5,800003dc <consoleintr+0x118>
    800002f2:	47c1                	li	a5,16
    800002f4:	10f49a63          	bne	s1,a5,80000408 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f8:	00002097          	auipc	ra,0x2
    800002fc:	7b6080e7          	jalr	1974(ra) # 80002aae <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000300:	00011517          	auipc	a0,0x11
    80000304:	a5050513          	addi	a0,a0,-1456 # 80010d50 <cons>
    80000308:	00001097          	auipc	ra,0x1
    8000030c:	b54080e7          	jalr	-1196(ra) # 80000e5c <release>
}
    80000310:	60e2                	ld	ra,24(sp)
    80000312:	6442                	ld	s0,16(sp)
    80000314:	64a2                	ld	s1,8(sp)
    80000316:	6902                	ld	s2,0(sp)
    80000318:	6105                	addi	sp,sp,32
    8000031a:	8082                	ret
  switch(c){
    8000031c:	07f00793          	li	a5,127
    80000320:	0af48e63          	beq	s1,a5,800003dc <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000324:	00011717          	auipc	a4,0x11
    80000328:	a2c70713          	addi	a4,a4,-1492 # 80010d50 <cons>
    8000032c:	0a072783          	lw	a5,160(a4)
    80000330:	09872703          	lw	a4,152(a4)
    80000334:	9f99                	subw	a5,a5,a4
    80000336:	07f00713          	li	a4,127
    8000033a:	fcf763e3          	bltu	a4,a5,80000300 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    8000033e:	47b5                	li	a5,13
    80000340:	0cf48763          	beq	s1,a5,8000040e <consoleintr+0x14a>
      consputc(c);
    80000344:	8526                	mv	a0,s1
    80000346:	00000097          	auipc	ra,0x0
    8000034a:	f3c080e7          	jalr	-196(ra) # 80000282 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000034e:	00011797          	auipc	a5,0x11
    80000352:	a0278793          	addi	a5,a5,-1534 # 80010d50 <cons>
    80000356:	0a07a683          	lw	a3,160(a5)
    8000035a:	0016871b          	addiw	a4,a3,1
    8000035e:	0007061b          	sext.w	a2,a4
    80000362:	0ae7a023          	sw	a4,160(a5)
    80000366:	07f6f693          	andi	a3,a3,127
    8000036a:	97b6                	add	a5,a5,a3
    8000036c:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000370:	47a9                	li	a5,10
    80000372:	0cf48563          	beq	s1,a5,8000043c <consoleintr+0x178>
    80000376:	4791                	li	a5,4
    80000378:	0cf48263          	beq	s1,a5,8000043c <consoleintr+0x178>
    8000037c:	00011797          	auipc	a5,0x11
    80000380:	a6c7a783          	lw	a5,-1428(a5) # 80010de8 <cons+0x98>
    80000384:	9f1d                	subw	a4,a4,a5
    80000386:	08000793          	li	a5,128
    8000038a:	f6f71be3          	bne	a4,a5,80000300 <consoleintr+0x3c>
    8000038e:	a07d                	j	8000043c <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000390:	00011717          	auipc	a4,0x11
    80000394:	9c070713          	addi	a4,a4,-1600 # 80010d50 <cons>
    80000398:	0a072783          	lw	a5,160(a4)
    8000039c:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a0:	00011497          	auipc	s1,0x11
    800003a4:	9b048493          	addi	s1,s1,-1616 # 80010d50 <cons>
    while(cons.e != cons.w &&
    800003a8:	4929                	li	s2,10
    800003aa:	f4f70be3          	beq	a4,a5,80000300 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003ae:	37fd                	addiw	a5,a5,-1
    800003b0:	07f7f713          	andi	a4,a5,127
    800003b4:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b6:	01874703          	lbu	a4,24(a4)
    800003ba:	f52703e3          	beq	a4,s2,80000300 <consoleintr+0x3c>
      cons.e--;
    800003be:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003c2:	10000513          	li	a0,256
    800003c6:	00000097          	auipc	ra,0x0
    800003ca:	ebc080e7          	jalr	-324(ra) # 80000282 <consputc>
    while(cons.e != cons.w &&
    800003ce:	0a04a783          	lw	a5,160(s1)
    800003d2:	09c4a703          	lw	a4,156(s1)
    800003d6:	fcf71ce3          	bne	a4,a5,800003ae <consoleintr+0xea>
    800003da:	b71d                	j	80000300 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003dc:	00011717          	auipc	a4,0x11
    800003e0:	97470713          	addi	a4,a4,-1676 # 80010d50 <cons>
    800003e4:	0a072783          	lw	a5,160(a4)
    800003e8:	09c72703          	lw	a4,156(a4)
    800003ec:	f0f70ae3          	beq	a4,a5,80000300 <consoleintr+0x3c>
      cons.e--;
    800003f0:	37fd                	addiw	a5,a5,-1
    800003f2:	00011717          	auipc	a4,0x11
    800003f6:	9ef72f23          	sw	a5,-1538(a4) # 80010df0 <cons+0xa0>
      consputc(BACKSPACE);
    800003fa:	10000513          	li	a0,256
    800003fe:	00000097          	auipc	ra,0x0
    80000402:	e84080e7          	jalr	-380(ra) # 80000282 <consputc>
    80000406:	bded                	j	80000300 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000408:	ee048ce3          	beqz	s1,80000300 <consoleintr+0x3c>
    8000040c:	bf21                	j	80000324 <consoleintr+0x60>
      consputc(c);
    8000040e:	4529                	li	a0,10
    80000410:	00000097          	auipc	ra,0x0
    80000414:	e72080e7          	jalr	-398(ra) # 80000282 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000418:	00011797          	auipc	a5,0x11
    8000041c:	93878793          	addi	a5,a5,-1736 # 80010d50 <cons>
    80000420:	0a07a703          	lw	a4,160(a5)
    80000424:	0017069b          	addiw	a3,a4,1
    80000428:	0006861b          	sext.w	a2,a3
    8000042c:	0ad7a023          	sw	a3,160(a5)
    80000430:	07f77713          	andi	a4,a4,127
    80000434:	97ba                	add	a5,a5,a4
    80000436:	4729                	li	a4,10
    80000438:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000043c:	00011797          	auipc	a5,0x11
    80000440:	9ac7a823          	sw	a2,-1616(a5) # 80010dec <cons+0x9c>
        wakeup(&cons.r);
    80000444:	00011517          	auipc	a0,0x11
    80000448:	9a450513          	addi	a0,a0,-1628 # 80010de8 <cons+0x98>
    8000044c:	00002097          	auipc	ra,0x2
    80000450:	2da080e7          	jalr	730(ra) # 80002726 <wakeup>
    80000454:	b575                	j	80000300 <consoleintr+0x3c>

0000000080000456 <consoleinit>:

void
consoleinit(void)
{
    80000456:	1141                	addi	sp,sp,-16
    80000458:	e406                	sd	ra,8(sp)
    8000045a:	e022                	sd	s0,0(sp)
    8000045c:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000045e:	00008597          	auipc	a1,0x8
    80000462:	bb258593          	addi	a1,a1,-1102 # 80008010 <etext+0x10>
    80000466:	00011517          	auipc	a0,0x11
    8000046a:	8ea50513          	addi	a0,a0,-1814 # 80010d50 <cons>
    8000046e:	00001097          	auipc	ra,0x1
    80000472:	8aa080e7          	jalr	-1878(ra) # 80000d18 <initlock>

  uartinit();
    80000476:	00000097          	auipc	ra,0x0
    8000047a:	330080e7          	jalr	816(ra) # 800007a6 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000047e:	00242797          	auipc	a5,0x242
    80000482:	48278793          	addi	a5,a5,1154 # 80242900 <devsw>
    80000486:	00000717          	auipc	a4,0x0
    8000048a:	cde70713          	addi	a4,a4,-802 # 80000164 <consoleread>
    8000048e:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000490:	00000717          	auipc	a4,0x0
    80000494:	c7270713          	addi	a4,a4,-910 # 80000102 <consolewrite>
    80000498:	ef98                	sd	a4,24(a5)
}
    8000049a:	60a2                	ld	ra,8(sp)
    8000049c:	6402                	ld	s0,0(sp)
    8000049e:	0141                	addi	sp,sp,16
    800004a0:	8082                	ret

00000000800004a2 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004a2:	7179                	addi	sp,sp,-48
    800004a4:	f406                	sd	ra,40(sp)
    800004a6:	f022                	sd	s0,32(sp)
    800004a8:	ec26                	sd	s1,24(sp)
    800004aa:	e84a                	sd	s2,16(sp)
    800004ac:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004ae:	c219                	beqz	a2,800004b4 <printint+0x12>
    800004b0:	08054663          	bltz	a0,8000053c <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004b4:	2501                	sext.w	a0,a0
    800004b6:	4881                	li	a7,0
    800004b8:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004bc:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004be:	2581                	sext.w	a1,a1
    800004c0:	00008617          	auipc	a2,0x8
    800004c4:	b8060613          	addi	a2,a2,-1152 # 80008040 <digits>
    800004c8:	883a                	mv	a6,a4
    800004ca:	2705                	addiw	a4,a4,1
    800004cc:	02b577bb          	remuw	a5,a0,a1
    800004d0:	1782                	slli	a5,a5,0x20
    800004d2:	9381                	srli	a5,a5,0x20
    800004d4:	97b2                	add	a5,a5,a2
    800004d6:	0007c783          	lbu	a5,0(a5)
    800004da:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004de:	0005079b          	sext.w	a5,a0
    800004e2:	02b5553b          	divuw	a0,a0,a1
    800004e6:	0685                	addi	a3,a3,1
    800004e8:	feb7f0e3          	bgeu	a5,a1,800004c8 <printint+0x26>

  if(sign)
    800004ec:	00088b63          	beqz	a7,80000502 <printint+0x60>
    buf[i++] = '-';
    800004f0:	fe040793          	addi	a5,s0,-32
    800004f4:	973e                	add	a4,a4,a5
    800004f6:	02d00793          	li	a5,45
    800004fa:	fef70823          	sb	a5,-16(a4)
    800004fe:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80000502:	02e05763          	blez	a4,80000530 <printint+0x8e>
    80000506:	fd040793          	addi	a5,s0,-48
    8000050a:	00e784b3          	add	s1,a5,a4
    8000050e:	fff78913          	addi	s2,a5,-1
    80000512:	993a                	add	s2,s2,a4
    80000514:	377d                	addiw	a4,a4,-1
    80000516:	1702                	slli	a4,a4,0x20
    80000518:	9301                	srli	a4,a4,0x20
    8000051a:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000051e:	fff4c503          	lbu	a0,-1(s1)
    80000522:	00000097          	auipc	ra,0x0
    80000526:	d60080e7          	jalr	-672(ra) # 80000282 <consputc>
  while(--i >= 0)
    8000052a:	14fd                	addi	s1,s1,-1
    8000052c:	ff2499e3          	bne	s1,s2,8000051e <printint+0x7c>
}
    80000530:	70a2                	ld	ra,40(sp)
    80000532:	7402                	ld	s0,32(sp)
    80000534:	64e2                	ld	s1,24(sp)
    80000536:	6942                	ld	s2,16(sp)
    80000538:	6145                	addi	sp,sp,48
    8000053a:	8082                	ret
    x = -xx;
    8000053c:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000540:	4885                	li	a7,1
    x = -xx;
    80000542:	bf9d                	j	800004b8 <printint+0x16>

0000000080000544 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000544:	1101                	addi	sp,sp,-32
    80000546:	ec06                	sd	ra,24(sp)
    80000548:	e822                	sd	s0,16(sp)
    8000054a:	e426                	sd	s1,8(sp)
    8000054c:	1000                	addi	s0,sp,32
    8000054e:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000550:	00011797          	auipc	a5,0x11
    80000554:	8c07a023          	sw	zero,-1856(a5) # 80010e10 <pr+0x18>
  printf("panic: ");
    80000558:	00008517          	auipc	a0,0x8
    8000055c:	ac050513          	addi	a0,a0,-1344 # 80008018 <etext+0x18>
    80000560:	00000097          	auipc	ra,0x0
    80000564:	02e080e7          	jalr	46(ra) # 8000058e <printf>
  printf(s);
    80000568:	8526                	mv	a0,s1
    8000056a:	00000097          	auipc	ra,0x0
    8000056e:	024080e7          	jalr	36(ra) # 8000058e <printf>
  printf("\n");
    80000572:	00008517          	auipc	a0,0x8
    80000576:	b8650513          	addi	a0,a0,-1146 # 800080f8 <digits+0xb8>
    8000057a:	00000097          	auipc	ra,0x0
    8000057e:	014080e7          	jalr	20(ra) # 8000058e <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000582:	4785                	li	a5,1
    80000584:	00008717          	auipc	a4,0x8
    80000588:	64f72623          	sw	a5,1612(a4) # 80008bd0 <panicked>
  for(;;)
    8000058c:	a001                	j	8000058c <panic+0x48>

000000008000058e <printf>:
{
    8000058e:	7131                	addi	sp,sp,-192
    80000590:	fc86                	sd	ra,120(sp)
    80000592:	f8a2                	sd	s0,112(sp)
    80000594:	f4a6                	sd	s1,104(sp)
    80000596:	f0ca                	sd	s2,96(sp)
    80000598:	ecce                	sd	s3,88(sp)
    8000059a:	e8d2                	sd	s4,80(sp)
    8000059c:	e4d6                	sd	s5,72(sp)
    8000059e:	e0da                	sd	s6,64(sp)
    800005a0:	fc5e                	sd	s7,56(sp)
    800005a2:	f862                	sd	s8,48(sp)
    800005a4:	f466                	sd	s9,40(sp)
    800005a6:	f06a                	sd	s10,32(sp)
    800005a8:	ec6e                	sd	s11,24(sp)
    800005aa:	0100                	addi	s0,sp,128
    800005ac:	8a2a                	mv	s4,a0
    800005ae:	e40c                	sd	a1,8(s0)
    800005b0:	e810                	sd	a2,16(s0)
    800005b2:	ec14                	sd	a3,24(s0)
    800005b4:	f018                	sd	a4,32(s0)
    800005b6:	f41c                	sd	a5,40(s0)
    800005b8:	03043823          	sd	a6,48(s0)
    800005bc:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005c0:	00011d97          	auipc	s11,0x11
    800005c4:	850dad83          	lw	s11,-1968(s11) # 80010e10 <pr+0x18>
  if(locking)
    800005c8:	020d9b63          	bnez	s11,800005fe <printf+0x70>
  if (fmt == 0)
    800005cc:	040a0263          	beqz	s4,80000610 <printf+0x82>
  va_start(ap, fmt);
    800005d0:	00840793          	addi	a5,s0,8
    800005d4:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d8:	000a4503          	lbu	a0,0(s4)
    800005dc:	16050263          	beqz	a0,80000740 <printf+0x1b2>
    800005e0:	4481                	li	s1,0
    if(c != '%'){
    800005e2:	02500a93          	li	s5,37
    switch(c){
    800005e6:	07000b13          	li	s6,112
  consputc('x');
    800005ea:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005ec:	00008b97          	auipc	s7,0x8
    800005f0:	a54b8b93          	addi	s7,s7,-1452 # 80008040 <digits>
    switch(c){
    800005f4:	07300c93          	li	s9,115
    800005f8:	06400c13          	li	s8,100
    800005fc:	a82d                	j	80000636 <printf+0xa8>
    acquire(&pr.lock);
    800005fe:	00010517          	auipc	a0,0x10
    80000602:	7fa50513          	addi	a0,a0,2042 # 80010df8 <pr>
    80000606:	00000097          	auipc	ra,0x0
    8000060a:	7a2080e7          	jalr	1954(ra) # 80000da8 <acquire>
    8000060e:	bf7d                	j	800005cc <printf+0x3e>
    panic("null fmt");
    80000610:	00008517          	auipc	a0,0x8
    80000614:	a1850513          	addi	a0,a0,-1512 # 80008028 <etext+0x28>
    80000618:	00000097          	auipc	ra,0x0
    8000061c:	f2c080e7          	jalr	-212(ra) # 80000544 <panic>
      consputc(c);
    80000620:	00000097          	auipc	ra,0x0
    80000624:	c62080e7          	jalr	-926(ra) # 80000282 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000628:	2485                	addiw	s1,s1,1
    8000062a:	009a07b3          	add	a5,s4,s1
    8000062e:	0007c503          	lbu	a0,0(a5)
    80000632:	10050763          	beqz	a0,80000740 <printf+0x1b2>
    if(c != '%'){
    80000636:	ff5515e3          	bne	a0,s5,80000620 <printf+0x92>
    c = fmt[++i] & 0xff;
    8000063a:	2485                	addiw	s1,s1,1
    8000063c:	009a07b3          	add	a5,s4,s1
    80000640:	0007c783          	lbu	a5,0(a5)
    80000644:	0007891b          	sext.w	s2,a5
    if(c == 0)
    80000648:	cfe5                	beqz	a5,80000740 <printf+0x1b2>
    switch(c){
    8000064a:	05678a63          	beq	a5,s6,8000069e <printf+0x110>
    8000064e:	02fb7663          	bgeu	s6,a5,8000067a <printf+0xec>
    80000652:	09978963          	beq	a5,s9,800006e4 <printf+0x156>
    80000656:	07800713          	li	a4,120
    8000065a:	0ce79863          	bne	a5,a4,8000072a <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    8000065e:	f8843783          	ld	a5,-120(s0)
    80000662:	00878713          	addi	a4,a5,8
    80000666:	f8e43423          	sd	a4,-120(s0)
    8000066a:	4605                	li	a2,1
    8000066c:	85ea                	mv	a1,s10
    8000066e:	4388                	lw	a0,0(a5)
    80000670:	00000097          	auipc	ra,0x0
    80000674:	e32080e7          	jalr	-462(ra) # 800004a2 <printint>
      break;
    80000678:	bf45                	j	80000628 <printf+0x9a>
    switch(c){
    8000067a:	0b578263          	beq	a5,s5,8000071e <printf+0x190>
    8000067e:	0b879663          	bne	a5,s8,8000072a <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    80000682:	f8843783          	ld	a5,-120(s0)
    80000686:	00878713          	addi	a4,a5,8
    8000068a:	f8e43423          	sd	a4,-120(s0)
    8000068e:	4605                	li	a2,1
    80000690:	45a9                	li	a1,10
    80000692:	4388                	lw	a0,0(a5)
    80000694:	00000097          	auipc	ra,0x0
    80000698:	e0e080e7          	jalr	-498(ra) # 800004a2 <printint>
      break;
    8000069c:	b771                	j	80000628 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    8000069e:	f8843783          	ld	a5,-120(s0)
    800006a2:	00878713          	addi	a4,a5,8
    800006a6:	f8e43423          	sd	a4,-120(s0)
    800006aa:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006ae:	03000513          	li	a0,48
    800006b2:	00000097          	auipc	ra,0x0
    800006b6:	bd0080e7          	jalr	-1072(ra) # 80000282 <consputc>
  consputc('x');
    800006ba:	07800513          	li	a0,120
    800006be:	00000097          	auipc	ra,0x0
    800006c2:	bc4080e7          	jalr	-1084(ra) # 80000282 <consputc>
    800006c6:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c8:	03c9d793          	srli	a5,s3,0x3c
    800006cc:	97de                	add	a5,a5,s7
    800006ce:	0007c503          	lbu	a0,0(a5)
    800006d2:	00000097          	auipc	ra,0x0
    800006d6:	bb0080e7          	jalr	-1104(ra) # 80000282 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006da:	0992                	slli	s3,s3,0x4
    800006dc:	397d                	addiw	s2,s2,-1
    800006de:	fe0915e3          	bnez	s2,800006c8 <printf+0x13a>
    800006e2:	b799                	j	80000628 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006e4:	f8843783          	ld	a5,-120(s0)
    800006e8:	00878713          	addi	a4,a5,8
    800006ec:	f8e43423          	sd	a4,-120(s0)
    800006f0:	0007b903          	ld	s2,0(a5)
    800006f4:	00090e63          	beqz	s2,80000710 <printf+0x182>
      for(; *s; s++)
    800006f8:	00094503          	lbu	a0,0(s2)
    800006fc:	d515                	beqz	a0,80000628 <printf+0x9a>
        consputc(*s);
    800006fe:	00000097          	auipc	ra,0x0
    80000702:	b84080e7          	jalr	-1148(ra) # 80000282 <consputc>
      for(; *s; s++)
    80000706:	0905                	addi	s2,s2,1
    80000708:	00094503          	lbu	a0,0(s2)
    8000070c:	f96d                	bnez	a0,800006fe <printf+0x170>
    8000070e:	bf29                	j	80000628 <printf+0x9a>
        s = "(null)";
    80000710:	00008917          	auipc	s2,0x8
    80000714:	91090913          	addi	s2,s2,-1776 # 80008020 <etext+0x20>
      for(; *s; s++)
    80000718:	02800513          	li	a0,40
    8000071c:	b7cd                	j	800006fe <printf+0x170>
      consputc('%');
    8000071e:	8556                	mv	a0,s5
    80000720:	00000097          	auipc	ra,0x0
    80000724:	b62080e7          	jalr	-1182(ra) # 80000282 <consputc>
      break;
    80000728:	b701                	j	80000628 <printf+0x9a>
      consputc('%');
    8000072a:	8556                	mv	a0,s5
    8000072c:	00000097          	auipc	ra,0x0
    80000730:	b56080e7          	jalr	-1194(ra) # 80000282 <consputc>
      consputc(c);
    80000734:	854a                	mv	a0,s2
    80000736:	00000097          	auipc	ra,0x0
    8000073a:	b4c080e7          	jalr	-1204(ra) # 80000282 <consputc>
      break;
    8000073e:	b5ed                	j	80000628 <printf+0x9a>
  if(locking)
    80000740:	020d9163          	bnez	s11,80000762 <printf+0x1d4>
}
    80000744:	70e6                	ld	ra,120(sp)
    80000746:	7446                	ld	s0,112(sp)
    80000748:	74a6                	ld	s1,104(sp)
    8000074a:	7906                	ld	s2,96(sp)
    8000074c:	69e6                	ld	s3,88(sp)
    8000074e:	6a46                	ld	s4,80(sp)
    80000750:	6aa6                	ld	s5,72(sp)
    80000752:	6b06                	ld	s6,64(sp)
    80000754:	7be2                	ld	s7,56(sp)
    80000756:	7c42                	ld	s8,48(sp)
    80000758:	7ca2                	ld	s9,40(sp)
    8000075a:	7d02                	ld	s10,32(sp)
    8000075c:	6de2                	ld	s11,24(sp)
    8000075e:	6129                	addi	sp,sp,192
    80000760:	8082                	ret
    release(&pr.lock);
    80000762:	00010517          	auipc	a0,0x10
    80000766:	69650513          	addi	a0,a0,1686 # 80010df8 <pr>
    8000076a:	00000097          	auipc	ra,0x0
    8000076e:	6f2080e7          	jalr	1778(ra) # 80000e5c <release>
}
    80000772:	bfc9                	j	80000744 <printf+0x1b6>

0000000080000774 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000774:	1101                	addi	sp,sp,-32
    80000776:	ec06                	sd	ra,24(sp)
    80000778:	e822                	sd	s0,16(sp)
    8000077a:	e426                	sd	s1,8(sp)
    8000077c:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000077e:	00010497          	auipc	s1,0x10
    80000782:	67a48493          	addi	s1,s1,1658 # 80010df8 <pr>
    80000786:	00008597          	auipc	a1,0x8
    8000078a:	8b258593          	addi	a1,a1,-1870 # 80008038 <etext+0x38>
    8000078e:	8526                	mv	a0,s1
    80000790:	00000097          	auipc	ra,0x0
    80000794:	588080e7          	jalr	1416(ra) # 80000d18 <initlock>
  pr.locking = 1;
    80000798:	4785                	li	a5,1
    8000079a:	cc9c                	sw	a5,24(s1)
}
    8000079c:	60e2                	ld	ra,24(sp)
    8000079e:	6442                	ld	s0,16(sp)
    800007a0:	64a2                	ld	s1,8(sp)
    800007a2:	6105                	addi	sp,sp,32
    800007a4:	8082                	ret

00000000800007a6 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007a6:	1141                	addi	sp,sp,-16
    800007a8:	e406                	sd	ra,8(sp)
    800007aa:	e022                	sd	s0,0(sp)
    800007ac:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007ae:	100007b7          	lui	a5,0x10000
    800007b2:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007b6:	f8000713          	li	a4,-128
    800007ba:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007be:	470d                	li	a4,3
    800007c0:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007c4:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007c8:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007cc:	469d                	li	a3,7
    800007ce:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007d2:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007d6:	00008597          	auipc	a1,0x8
    800007da:	88258593          	addi	a1,a1,-1918 # 80008058 <digits+0x18>
    800007de:	00010517          	auipc	a0,0x10
    800007e2:	63a50513          	addi	a0,a0,1594 # 80010e18 <uart_tx_lock>
    800007e6:	00000097          	auipc	ra,0x0
    800007ea:	532080e7          	jalr	1330(ra) # 80000d18 <initlock>
}
    800007ee:	60a2                	ld	ra,8(sp)
    800007f0:	6402                	ld	s0,0(sp)
    800007f2:	0141                	addi	sp,sp,16
    800007f4:	8082                	ret

00000000800007f6 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007f6:	1101                	addi	sp,sp,-32
    800007f8:	ec06                	sd	ra,24(sp)
    800007fa:	e822                	sd	s0,16(sp)
    800007fc:	e426                	sd	s1,8(sp)
    800007fe:	1000                	addi	s0,sp,32
    80000800:	84aa                	mv	s1,a0
  push_off();
    80000802:	00000097          	auipc	ra,0x0
    80000806:	55a080e7          	jalr	1370(ra) # 80000d5c <push_off>

  if(panicked){
    8000080a:	00008797          	auipc	a5,0x8
    8000080e:	3c67a783          	lw	a5,966(a5) # 80008bd0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000812:	10000737          	lui	a4,0x10000
  if(panicked){
    80000816:	c391                	beqz	a5,8000081a <uartputc_sync+0x24>
    for(;;)
    80000818:	a001                	j	80000818 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000081a:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000081e:	0ff7f793          	andi	a5,a5,255
    80000822:	0207f793          	andi	a5,a5,32
    80000826:	dbf5                	beqz	a5,8000081a <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000828:	0ff4f793          	andi	a5,s1,255
    8000082c:	10000737          	lui	a4,0x10000
    80000830:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    80000834:	00000097          	auipc	ra,0x0
    80000838:	5c8080e7          	jalr	1480(ra) # 80000dfc <pop_off>
}
    8000083c:	60e2                	ld	ra,24(sp)
    8000083e:	6442                	ld	s0,16(sp)
    80000840:	64a2                	ld	s1,8(sp)
    80000842:	6105                	addi	sp,sp,32
    80000844:	8082                	ret

0000000080000846 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000846:	00008717          	auipc	a4,0x8
    8000084a:	39273703          	ld	a4,914(a4) # 80008bd8 <uart_tx_r>
    8000084e:	00008797          	auipc	a5,0x8
    80000852:	3927b783          	ld	a5,914(a5) # 80008be0 <uart_tx_w>
    80000856:	06e78c63          	beq	a5,a4,800008ce <uartstart+0x88>
{
    8000085a:	7139                	addi	sp,sp,-64
    8000085c:	fc06                	sd	ra,56(sp)
    8000085e:	f822                	sd	s0,48(sp)
    80000860:	f426                	sd	s1,40(sp)
    80000862:	f04a                	sd	s2,32(sp)
    80000864:	ec4e                	sd	s3,24(sp)
    80000866:	e852                	sd	s4,16(sp)
    80000868:	e456                	sd	s5,8(sp)
    8000086a:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000086c:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000870:	00010a17          	auipc	s4,0x10
    80000874:	5a8a0a13          	addi	s4,s4,1448 # 80010e18 <uart_tx_lock>
    uart_tx_r += 1;
    80000878:	00008497          	auipc	s1,0x8
    8000087c:	36048493          	addi	s1,s1,864 # 80008bd8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000880:	00008997          	auipc	s3,0x8
    80000884:	36098993          	addi	s3,s3,864 # 80008be0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000888:	00594783          	lbu	a5,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000088c:	0ff7f793          	andi	a5,a5,255
    80000890:	0207f793          	andi	a5,a5,32
    80000894:	c785                	beqz	a5,800008bc <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000896:	01f77793          	andi	a5,a4,31
    8000089a:	97d2                	add	a5,a5,s4
    8000089c:	0187ca83          	lbu	s5,24(a5)
    uart_tx_r += 1;
    800008a0:	0705                	addi	a4,a4,1
    800008a2:	e098                	sd	a4,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800008a4:	8526                	mv	a0,s1
    800008a6:	00002097          	auipc	ra,0x2
    800008aa:	e80080e7          	jalr	-384(ra) # 80002726 <wakeup>
    
    WriteReg(THR, c);
    800008ae:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008b2:	6098                	ld	a4,0(s1)
    800008b4:	0009b783          	ld	a5,0(s3)
    800008b8:	fce798e3          	bne	a5,a4,80000888 <uartstart+0x42>
  }
}
    800008bc:	70e2                	ld	ra,56(sp)
    800008be:	7442                	ld	s0,48(sp)
    800008c0:	74a2                	ld	s1,40(sp)
    800008c2:	7902                	ld	s2,32(sp)
    800008c4:	69e2                	ld	s3,24(sp)
    800008c6:	6a42                	ld	s4,16(sp)
    800008c8:	6aa2                	ld	s5,8(sp)
    800008ca:	6121                	addi	sp,sp,64
    800008cc:	8082                	ret
    800008ce:	8082                	ret

00000000800008d0 <uartputc>:
{
    800008d0:	7179                	addi	sp,sp,-48
    800008d2:	f406                	sd	ra,40(sp)
    800008d4:	f022                	sd	s0,32(sp)
    800008d6:	ec26                	sd	s1,24(sp)
    800008d8:	e84a                	sd	s2,16(sp)
    800008da:	e44e                	sd	s3,8(sp)
    800008dc:	e052                	sd	s4,0(sp)
    800008de:	1800                	addi	s0,sp,48
    800008e0:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    800008e2:	00010517          	auipc	a0,0x10
    800008e6:	53650513          	addi	a0,a0,1334 # 80010e18 <uart_tx_lock>
    800008ea:	00000097          	auipc	ra,0x0
    800008ee:	4be080e7          	jalr	1214(ra) # 80000da8 <acquire>
  if(panicked){
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	2de7a783          	lw	a5,734(a5) # 80008bd0 <panicked>
    800008fa:	e7c9                	bnez	a5,80000984 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008fc:	00008797          	auipc	a5,0x8
    80000900:	2e47b783          	ld	a5,740(a5) # 80008be0 <uart_tx_w>
    80000904:	00008717          	auipc	a4,0x8
    80000908:	2d473703          	ld	a4,724(a4) # 80008bd8 <uart_tx_r>
    8000090c:	02070713          	addi	a4,a4,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000910:	00010a17          	auipc	s4,0x10
    80000914:	508a0a13          	addi	s4,s4,1288 # 80010e18 <uart_tx_lock>
    80000918:	00008497          	auipc	s1,0x8
    8000091c:	2c048493          	addi	s1,s1,704 # 80008bd8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000920:	00008917          	auipc	s2,0x8
    80000924:	2c090913          	addi	s2,s2,704 # 80008be0 <uart_tx_w>
    80000928:	00f71f63          	bne	a4,a5,80000946 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000092c:	85d2                	mv	a1,s4
    8000092e:	8526                	mv	a0,s1
    80000930:	00002097          	auipc	ra,0x2
    80000934:	af8080e7          	jalr	-1288(ra) # 80002428 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000938:	00093783          	ld	a5,0(s2)
    8000093c:	6098                	ld	a4,0(s1)
    8000093e:	02070713          	addi	a4,a4,32
    80000942:	fef705e3          	beq	a4,a5,8000092c <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000946:	00010497          	auipc	s1,0x10
    8000094a:	4d248493          	addi	s1,s1,1234 # 80010e18 <uart_tx_lock>
    8000094e:	01f7f713          	andi	a4,a5,31
    80000952:	9726                	add	a4,a4,s1
    80000954:	01370c23          	sb	s3,24(a4)
  uart_tx_w += 1;
    80000958:	0785                	addi	a5,a5,1
    8000095a:	00008717          	auipc	a4,0x8
    8000095e:	28f73323          	sd	a5,646(a4) # 80008be0 <uart_tx_w>
  uartstart();
    80000962:	00000097          	auipc	ra,0x0
    80000966:	ee4080e7          	jalr	-284(ra) # 80000846 <uartstart>
  release(&uart_tx_lock);
    8000096a:	8526                	mv	a0,s1
    8000096c:	00000097          	auipc	ra,0x0
    80000970:	4f0080e7          	jalr	1264(ra) # 80000e5c <release>
}
    80000974:	70a2                	ld	ra,40(sp)
    80000976:	7402                	ld	s0,32(sp)
    80000978:	64e2                	ld	s1,24(sp)
    8000097a:	6942                	ld	s2,16(sp)
    8000097c:	69a2                	ld	s3,8(sp)
    8000097e:	6a02                	ld	s4,0(sp)
    80000980:	6145                	addi	sp,sp,48
    80000982:	8082                	ret
    for(;;)
    80000984:	a001                	j	80000984 <uartputc+0xb4>

0000000080000986 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000986:	1141                	addi	sp,sp,-16
    80000988:	e422                	sd	s0,8(sp)
    8000098a:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    8000098c:	100007b7          	lui	a5,0x10000
    80000990:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000994:	8b85                	andi	a5,a5,1
    80000996:	cb91                	beqz	a5,800009aa <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000998:	100007b7          	lui	a5,0x10000
    8000099c:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800009a0:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    800009a4:	6422                	ld	s0,8(sp)
    800009a6:	0141                	addi	sp,sp,16
    800009a8:	8082                	ret
    return -1;
    800009aa:	557d                	li	a0,-1
    800009ac:	bfe5                	j	800009a4 <uartgetc+0x1e>

00000000800009ae <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009ae:	1101                	addi	sp,sp,-32
    800009b0:	ec06                	sd	ra,24(sp)
    800009b2:	e822                	sd	s0,16(sp)
    800009b4:	e426                	sd	s1,8(sp)
    800009b6:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009b8:	54fd                	li	s1,-1
    int c = uartgetc();
    800009ba:	00000097          	auipc	ra,0x0
    800009be:	fcc080e7          	jalr	-52(ra) # 80000986 <uartgetc>
    if(c == -1)
    800009c2:	00950763          	beq	a0,s1,800009d0 <uartintr+0x22>
      break;
    consoleintr(c);
    800009c6:	00000097          	auipc	ra,0x0
    800009ca:	8fe080e7          	jalr	-1794(ra) # 800002c4 <consoleintr>
  while(1){
    800009ce:	b7f5                	j	800009ba <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009d0:	00010497          	auipc	s1,0x10
    800009d4:	44848493          	addi	s1,s1,1096 # 80010e18 <uart_tx_lock>
    800009d8:	8526                	mv	a0,s1
    800009da:	00000097          	auipc	ra,0x0
    800009de:	3ce080e7          	jalr	974(ra) # 80000da8 <acquire>
  uartstart();
    800009e2:	00000097          	auipc	ra,0x0
    800009e6:	e64080e7          	jalr	-412(ra) # 80000846 <uartstart>
  release(&uart_tx_lock);
    800009ea:	8526                	mv	a0,s1
    800009ec:	00000097          	auipc	ra,0x0
    800009f0:	470080e7          	jalr	1136(ra) # 80000e5c <release>
}
    800009f4:	60e2                	ld	ra,24(sp)
    800009f6:	6442                	ld	s0,16(sp)
    800009f8:	64a2                	ld	s1,8(sp)
    800009fa:	6105                	addi	sp,sp,32
    800009fc:	8082                	ret

00000000800009fe <krefincr>:
	struct spinlock lock;
	int count[PHYSTOP / PGSIZE];
} refcnt;

void krefincr(uint64 pa)
{
    800009fe:	1101                	addi	sp,sp,-32
    80000a00:	ec06                	sd	ra,24(sp)
    80000a02:	e822                	sd	s0,16(sp)
    80000a04:	e426                	sd	s1,8(sp)
    80000a06:	1000                	addi	s0,sp,32
    80000a08:	84aa                	mv	s1,a0
	// acquire(&refcnt.lock);
	// int pn = (uint64)pa / PGSIZE;
	// refcnt.count[pn]++;
	// release(&refcnt.lock);
	acquire(&kmem.lock);
    80000a0a:	00010517          	auipc	a0,0x10
    80000a0e:	44650513          	addi	a0,a0,1094 # 80010e50 <kmem>
    80000a12:	00000097          	auipc	ra,0x0
    80000a16:	396080e7          	jalr	918(ra) # 80000da8 <acquire>
	int pn = pa / PGSIZE;
	if (pa > PHYSTOP)
    80000a1a:	4745                	li	a4,17
    80000a1c:	076e                	slli	a4,a4,0x1b
    80000a1e:	02976c63          	bltu	a4,s1,80000a56 <krefincr+0x58>
    80000a22:	00c4d793          	srli	a5,s1,0xc
    80000a26:	2781                	sext.w	a5,a5
		panic("Physical Address limit exceeded");
	}
	// if ((uint64)pa > PHYSTOP || refcnt.count[pn] < 1)
	// 	panic("krefincr");

	refcnt.count[pn]++;
    80000a28:	0791                	addi	a5,a5,4
    80000a2a:	078a                	slli	a5,a5,0x2
    80000a2c:	00010717          	auipc	a4,0x10
    80000a30:	44470713          	addi	a4,a4,1092 # 80010e70 <refcnt>
    80000a34:	97ba                	add	a5,a5,a4
    80000a36:	4798                	lw	a4,8(a5)
    80000a38:	2705                	addiw	a4,a4,1
    80000a3a:	c798                	sw	a4,8(a5)
	release(&kmem.lock);
    80000a3c:	00010517          	auipc	a0,0x10
    80000a40:	41450513          	addi	a0,a0,1044 # 80010e50 <kmem>
    80000a44:	00000097          	auipc	ra,0x0
    80000a48:	418080e7          	jalr	1048(ra) # 80000e5c <release>
}
    80000a4c:	60e2                	ld	ra,24(sp)
    80000a4e:	6442                	ld	s0,16(sp)
    80000a50:	64a2                	ld	s1,8(sp)
    80000a52:	6105                	addi	sp,sp,32
    80000a54:	8082                	ret
		panic("Physical Address limit exceeded");
    80000a56:	00007517          	auipc	a0,0x7
    80000a5a:	60a50513          	addi	a0,a0,1546 # 80008060 <digits+0x20>
    80000a5e:	00000097          	auipc	ra,0x0
    80000a62:	ae6080e7          	jalr	-1306(ra) # 80000544 <panic>

0000000080000a66 <krefdecr>:

void krefdecr(uint64 pa)
{
    80000a66:	1101                	addi	sp,sp,-32
    80000a68:	ec06                	sd	ra,24(sp)
    80000a6a:	e822                	sd	s0,16(sp)
    80000a6c:	e426                	sd	s1,8(sp)
    80000a6e:	1000                	addi	s0,sp,32
    80000a70:	84aa                	mv	s1,a0
	// acquire(&refcnt.lock);
	// int pn = (uint64)pa / PGSIZE;
	// refcnt.count[pn]--;
	// release(&refcnt.lock);
	// printf("here\n");
	acquire(&kmem.lock);
    80000a72:	00010517          	auipc	a0,0x10
    80000a76:	3de50513          	addi	a0,a0,990 # 80010e50 <kmem>
    80000a7a:	00000097          	auipc	ra,0x0
    80000a7e:	32e080e7          	jalr	814(ra) # 80000da8 <acquire>
	// printf("here1\n");
	int pn = pa / PGSIZE;
	if (pa > PHYSTOP)
    80000a82:	4745                	li	a4,17
    80000a84:	076e                	slli	a4,a4,0x1b
    80000a86:	02976c63          	bltu	a4,s1,80000abe <krefdecr+0x58>
    80000a8a:	00c4d793          	srli	a5,s1,0xc
    80000a8e:	2781                	sext.w	a5,a5
		panic("Physical Address limit exceeded");
	}
	// if ((uint64)pa > PHYSTOP)
	// 	panic("krefdecr");

	refcnt.count[pn]--;
    80000a90:	0791                	addi	a5,a5,4
    80000a92:	078a                	slli	a5,a5,0x2
    80000a94:	00010717          	auipc	a4,0x10
    80000a98:	3dc70713          	addi	a4,a4,988 # 80010e70 <refcnt>
    80000a9c:	97ba                	add	a5,a5,a4
    80000a9e:	4798                	lw	a4,8(a5)
    80000aa0:	377d                	addiw	a4,a4,-1
    80000aa2:	c798                	sw	a4,8(a5)
	// printf("%d\n", refcnt.count[pn]);
	release(&kmem.lock);
    80000aa4:	00010517          	auipc	a0,0x10
    80000aa8:	3ac50513          	addi	a0,a0,940 # 80010e50 <kmem>
    80000aac:	00000097          	auipc	ra,0x0
    80000ab0:	3b0080e7          	jalr	944(ra) # 80000e5c <release>
}
    80000ab4:	60e2                	ld	ra,24(sp)
    80000ab6:	6442                	ld	s0,16(sp)
    80000ab8:	64a2                	ld	s1,8(sp)
    80000aba:	6105                	addi	sp,sp,32
    80000abc:	8082                	ret
		panic("Physical Address limit exceeded");
    80000abe:	00007517          	auipc	a0,0x7
    80000ac2:	5a250513          	addi	a0,a0,1442 # 80008060 <digits+0x20>
    80000ac6:	00000097          	auipc	ra,0x0
    80000aca:	a7e080e7          	jalr	-1410(ra) # 80000544 <panic>

0000000080000ace <kfree>:
// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void kfree(void *pa)
{
    80000ace:	1101                	addi	sp,sp,-32
    80000ad0:	ec06                	sd	ra,24(sp)
    80000ad2:	e822                	sd	s0,16(sp)
    80000ad4:	e426                	sd	s1,8(sp)
    80000ad6:	e04a                	sd	s2,0(sp)
    80000ad8:	1000                	addi	s0,sp,32
	struct run *r;

	if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    80000ada:	03451793          	slli	a5,a0,0x34
    80000ade:	e7cd                	bnez	a5,80000b88 <kfree+0xba>
    80000ae0:	84aa                	mv	s1,a0
    80000ae2:	00243797          	auipc	a5,0x243
    80000ae6:	fb678793          	addi	a5,a5,-74 # 80243a98 <end>
    80000aea:	08f56f63          	bltu	a0,a5,80000b88 <kfree+0xba>
    80000aee:	47c5                	li	a5,17
    80000af0:	07ee                	slli	a5,a5,0x1b
    80000af2:	08f57b63          	bgeu	a0,a5,80000b88 <kfree+0xba>
		panic("kfree");

	r = (struct run *)pa;

	acquire(&kmem.lock);
    80000af6:	00010517          	auipc	a0,0x10
    80000afa:	35a50513          	addi	a0,a0,858 # 80010e50 <kmem>
    80000afe:	00000097          	auipc	ra,0x0
    80000b02:	2aa080e7          	jalr	682(ra) # 80000da8 <acquire>
	int pn = (uint64)r / PGSIZE;
    80000b06:	00c4d793          	srli	a5,s1,0xc
    80000b0a:	2781                	sext.w	a5,a5
	if (refcnt.count[pn] < 1)
    80000b0c:	00478713          	addi	a4,a5,4
    80000b10:	00271693          	slli	a3,a4,0x2
    80000b14:	00010717          	auipc	a4,0x10
    80000b18:	35c70713          	addi	a4,a4,860 # 80010e70 <refcnt>
    80000b1c:	9736                	add	a4,a4,a3
    80000b1e:	4718                	lw	a4,8(a4)
    80000b20:	06e05c63          	blez	a4,80000b98 <kfree+0xca>
	{
		release(&kmem.lock);
		panic("kfree_decr");
	}

	refcnt.count[pn] -= 1;
    80000b24:	377d                	addiw	a4,a4,-1
    80000b26:	0007061b          	sext.w	a2,a4
    80000b2a:	0791                	addi	a5,a5,4
    80000b2c:	078a                	slli	a5,a5,0x2
    80000b2e:	00010697          	auipc	a3,0x10
    80000b32:	34268693          	addi	a3,a3,834 # 80010e70 <refcnt>
    80000b36:	97b6                	add	a5,a5,a3
    80000b38:	c798                	sw	a4,8(a5)
	if (refcnt.count[pn] > 0)
    80000b3a:	06c04f63          	bgtz	a2,80000bb8 <kfree+0xea>
	{
		release(&kmem.lock);
		return;
	}
	release(&kmem.lock);
    80000b3e:	00010917          	auipc	s2,0x10
    80000b42:	31290913          	addi	s2,s2,786 # 80010e50 <kmem>
    80000b46:	854a                	mv	a0,s2
    80000b48:	00000097          	auipc	ra,0x0
    80000b4c:	314080e7          	jalr	788(ra) # 80000e5c <release>

	if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
		panic("kfree");

	// Fill with junk to catch dangling refs.
	memset(pa, 1, PGSIZE);
    80000b50:	6605                	lui	a2,0x1
    80000b52:	4585                	li	a1,1
    80000b54:	8526                	mv	a0,s1
    80000b56:	00000097          	auipc	ra,0x0
    80000b5a:	34e080e7          	jalr	846(ra) # 80000ea4 <memset>

	d = (struct run *)pa;

	acquire(&kmem.lock);
    80000b5e:	854a                	mv	a0,s2
    80000b60:	00000097          	auipc	ra,0x0
    80000b64:	248080e7          	jalr	584(ra) # 80000da8 <acquire>
	d->next = kmem.freelist;
    80000b68:	01893783          	ld	a5,24(s2)
    80000b6c:	e09c                	sd	a5,0(s1)
	kmem.freelist = d;
    80000b6e:	00993c23          	sd	s1,24(s2)
	release(&kmem.lock);
    80000b72:	854a                	mv	a0,s2
    80000b74:	00000097          	auipc	ra,0x0
    80000b78:	2e8080e7          	jalr	744(ra) # 80000e5c <release>
}
    80000b7c:	60e2                	ld	ra,24(sp)
    80000b7e:	6442                	ld	s0,16(sp)
    80000b80:	64a2                	ld	s1,8(sp)
    80000b82:	6902                	ld	s2,0(sp)
    80000b84:	6105                	addi	sp,sp,32
    80000b86:	8082                	ret
		panic("kfree");
    80000b88:	00007517          	auipc	a0,0x7
    80000b8c:	4f850513          	addi	a0,a0,1272 # 80008080 <digits+0x40>
    80000b90:	00000097          	auipc	ra,0x0
    80000b94:	9b4080e7          	jalr	-1612(ra) # 80000544 <panic>
		release(&kmem.lock);
    80000b98:	00010517          	auipc	a0,0x10
    80000b9c:	2b850513          	addi	a0,a0,696 # 80010e50 <kmem>
    80000ba0:	00000097          	auipc	ra,0x0
    80000ba4:	2bc080e7          	jalr	700(ra) # 80000e5c <release>
		panic("kfree_decr");
    80000ba8:	00007517          	auipc	a0,0x7
    80000bac:	4e050513          	addi	a0,a0,1248 # 80008088 <digits+0x48>
    80000bb0:	00000097          	auipc	ra,0x0
    80000bb4:	994080e7          	jalr	-1644(ra) # 80000544 <panic>
		release(&kmem.lock);
    80000bb8:	00010517          	auipc	a0,0x10
    80000bbc:	29850513          	addi	a0,a0,664 # 80010e50 <kmem>
    80000bc0:	00000097          	auipc	ra,0x0
    80000bc4:	29c080e7          	jalr	668(ra) # 80000e5c <release>
		return;
    80000bc8:	bf55                	j	80000b7c <kfree+0xae>

0000000080000bca <freerange>:
{
    80000bca:	7139                	addi	sp,sp,-64
    80000bcc:	fc06                	sd	ra,56(sp)
    80000bce:	f822                	sd	s0,48(sp)
    80000bd0:	f426                	sd	s1,40(sp)
    80000bd2:	f04a                	sd	s2,32(sp)
    80000bd4:	ec4e                	sd	s3,24(sp)
    80000bd6:	e852                	sd	s4,16(sp)
    80000bd8:	e456                	sd	s5,8(sp)
    80000bda:	e05a                	sd	s6,0(sp)
    80000bdc:	0080                	addi	s0,sp,64
	p = (char *)PGROUNDUP((uint64)pa_start);
    80000bde:	6785                	lui	a5,0x1
    80000be0:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000be4:	9526                	add	a0,a0,s1
    80000be6:	74fd                	lui	s1,0xfffff
    80000be8:	8ce9                	and	s1,s1,a0
	for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000bea:	97a6                	add	a5,a5,s1
    80000bec:	02f5ec63          	bltu	a1,a5,80000c24 <freerange+0x5a>
    80000bf0:	892e                	mv	s2,a1
		refcnt.count[pn] = 1;
    80000bf2:	00010b17          	auipc	s6,0x10
    80000bf6:	27eb0b13          	addi	s6,s6,638 # 80010e70 <refcnt>
    80000bfa:	4a85                	li	s5,1
    80000bfc:	6a05                	lui	s4,0x1
	for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000bfe:	6989                	lui	s3,0x2
		pn = (uint64)p / PGSIZE;
    80000c00:	00c4d793          	srli	a5,s1,0xc
		refcnt.count[pn] = 1;
    80000c04:	2781                	sext.w	a5,a5
    80000c06:	0791                	addi	a5,a5,4
    80000c08:	078a                	slli	a5,a5,0x2
    80000c0a:	97da                	add	a5,a5,s6
    80000c0c:	0157a423          	sw	s5,8(a5)
		kfree(p);
    80000c10:	8526                	mv	a0,s1
    80000c12:	00000097          	auipc	ra,0x0
    80000c16:	ebc080e7          	jalr	-324(ra) # 80000ace <kfree>
	for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000c1a:	87a6                	mv	a5,s1
    80000c1c:	94d2                	add	s1,s1,s4
    80000c1e:	97ce                	add	a5,a5,s3
    80000c20:	fef970e3          	bgeu	s2,a5,80000c00 <freerange+0x36>
}
    80000c24:	70e2                	ld	ra,56(sp)
    80000c26:	7442                	ld	s0,48(sp)
    80000c28:	74a2                	ld	s1,40(sp)
    80000c2a:	7902                	ld	s2,32(sp)
    80000c2c:	69e2                	ld	s3,24(sp)
    80000c2e:	6a42                	ld	s4,16(sp)
    80000c30:	6aa2                	ld	s5,8(sp)
    80000c32:	6b02                	ld	s6,0(sp)
    80000c34:	6121                	addi	sp,sp,64
    80000c36:	8082                	ret

0000000080000c38 <kinit>:
{
    80000c38:	1141                	addi	sp,sp,-16
    80000c3a:	e406                	sd	ra,8(sp)
    80000c3c:	e022                	sd	s0,0(sp)
    80000c3e:	0800                	addi	s0,sp,16
	initlock(&kmem.lock, "kmem");
    80000c40:	00007597          	auipc	a1,0x7
    80000c44:	45858593          	addi	a1,a1,1112 # 80008098 <digits+0x58>
    80000c48:	00010517          	auipc	a0,0x10
    80000c4c:	20850513          	addi	a0,a0,520 # 80010e50 <kmem>
    80000c50:	00000097          	auipc	ra,0x0
    80000c54:	0c8080e7          	jalr	200(ra) # 80000d18 <initlock>
	freerange(end, (void *)PHYSTOP);
    80000c58:	45c5                	li	a1,17
    80000c5a:	05ee                	slli	a1,a1,0x1b
    80000c5c:	00243517          	auipc	a0,0x243
    80000c60:	e3c50513          	addi	a0,a0,-452 # 80243a98 <end>
    80000c64:	00000097          	auipc	ra,0x0
    80000c68:	f66080e7          	jalr	-154(ra) # 80000bca <freerange>
}
    80000c6c:	60a2                	ld	ra,8(sp)
    80000c6e:	6402                	ld	s0,0(sp)
    80000c70:	0141                	addi	sp,sp,16
    80000c72:	8082                	ret

0000000080000c74 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000c74:	1101                	addi	sp,sp,-32
    80000c76:	ec06                	sd	ra,24(sp)
    80000c78:	e822                	sd	s0,16(sp)
    80000c7a:	e426                	sd	s1,8(sp)
    80000c7c:	1000                	addi	s0,sp,32
	struct run *r;

	acquire(&kmem.lock);
    80000c7e:	00010497          	auipc	s1,0x10
    80000c82:	1d248493          	addi	s1,s1,466 # 80010e50 <kmem>
    80000c86:	8526                	mv	a0,s1
    80000c88:	00000097          	auipc	ra,0x0
    80000c8c:	120080e7          	jalr	288(ra) # 80000da8 <acquire>
	r = kmem.freelist;
    80000c90:	6c84                	ld	s1,24(s1)
	if (r)
    80000c92:	c8b5                	beqz	s1,80000d06 <kalloc+0x92>
	{
		int pn = (uint64)r / PGSIZE;
    80000c94:	00c4d793          	srli	a5,s1,0xc
    80000c98:	2781                	sext.w	a5,a5
		if (refcnt.count[pn] > 0)
    80000c9a:	00478713          	addi	a4,a5,4
    80000c9e:	00271693          	slli	a3,a4,0x2
    80000ca2:	00010717          	auipc	a4,0x10
    80000ca6:	1ce70713          	addi	a4,a4,462 # 80010e70 <refcnt>
    80000caa:	9736                	add	a4,a4,a3
    80000cac:	4718                	lw	a4,8(a4)
    80000cae:	04e04263          	bgtz	a4,80000cf2 <kalloc+0x7e>
		{
			release(&kmem.lock);
			return 0;
			// panic("refcnt kalloc");
		}
		refcnt.count[pn] = 1;
    80000cb2:	0791                	addi	a5,a5,4
    80000cb4:	078a                	slli	a5,a5,0x2
    80000cb6:	00010717          	auipc	a4,0x10
    80000cba:	1ba70713          	addi	a4,a4,442 # 80010e70 <refcnt>
    80000cbe:	97ba                	add	a5,a5,a4
    80000cc0:	4705                	li	a4,1
    80000cc2:	c798                	sw	a4,8(a5)
		kmem.freelist = r->next;
    80000cc4:	609c                	ld	a5,0(s1)
    80000cc6:	00010517          	auipc	a0,0x10
    80000cca:	18a50513          	addi	a0,a0,394 # 80010e50 <kmem>
    80000cce:	ed1c                	sd	a5,24(a0)
	}
	release(&kmem.lock);
    80000cd0:	00000097          	auipc	ra,0x0
    80000cd4:	18c080e7          	jalr	396(ra) # 80000e5c <release>

	if (r)
	{
		memset((char *)r, 5, PGSIZE); // fill with junk
    80000cd8:	6605                	lui	a2,0x1
    80000cda:	4595                	li	a1,5
    80000cdc:	8526                	mv	a0,s1
    80000cde:	00000097          	auipc	ra,0x0
    80000ce2:	1c6080e7          	jalr	454(ra) # 80000ea4 <memset>
	}
	return (void *)r;
}
    80000ce6:	8526                	mv	a0,s1
    80000ce8:	60e2                	ld	ra,24(sp)
    80000cea:	6442                	ld	s0,16(sp)
    80000cec:	64a2                	ld	s1,8(sp)
    80000cee:	6105                	addi	sp,sp,32
    80000cf0:	8082                	ret
			release(&kmem.lock);
    80000cf2:	00010517          	auipc	a0,0x10
    80000cf6:	15e50513          	addi	a0,a0,350 # 80010e50 <kmem>
    80000cfa:	00000097          	auipc	ra,0x0
    80000cfe:	162080e7          	jalr	354(ra) # 80000e5c <release>
			return 0;
    80000d02:	4481                	li	s1,0
    80000d04:	b7cd                	j	80000ce6 <kalloc+0x72>
	release(&kmem.lock);
    80000d06:	00010517          	auipc	a0,0x10
    80000d0a:	14a50513          	addi	a0,a0,330 # 80010e50 <kmem>
    80000d0e:	00000097          	auipc	ra,0x0
    80000d12:	14e080e7          	jalr	334(ra) # 80000e5c <release>
	if (r)
    80000d16:	bfc1                	j	80000ce6 <kalloc+0x72>

0000000080000d18 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000d18:	1141                	addi	sp,sp,-16
    80000d1a:	e422                	sd	s0,8(sp)
    80000d1c:	0800                	addi	s0,sp,16
  lk->name = name;
    80000d1e:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000d20:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000d24:	00053823          	sd	zero,16(a0)
}
    80000d28:	6422                	ld	s0,8(sp)
    80000d2a:	0141                	addi	sp,sp,16
    80000d2c:	8082                	ret

0000000080000d2e <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000d2e:	411c                	lw	a5,0(a0)
    80000d30:	e399                	bnez	a5,80000d36 <holding+0x8>
    80000d32:	4501                	li	a0,0
  return r;
}
    80000d34:	8082                	ret
{
    80000d36:	1101                	addi	sp,sp,-32
    80000d38:	ec06                	sd	ra,24(sp)
    80000d3a:	e822                	sd	s0,16(sp)
    80000d3c:	e426                	sd	s1,8(sp)
    80000d3e:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000d40:	6904                	ld	s1,16(a0)
    80000d42:	00001097          	auipc	ra,0x1
    80000d46:	f5a080e7          	jalr	-166(ra) # 80001c9c <mycpu>
    80000d4a:	40a48533          	sub	a0,s1,a0
    80000d4e:	00153513          	seqz	a0,a0
}
    80000d52:	60e2                	ld	ra,24(sp)
    80000d54:	6442                	ld	s0,16(sp)
    80000d56:	64a2                	ld	s1,8(sp)
    80000d58:	6105                	addi	sp,sp,32
    80000d5a:	8082                	ret

0000000080000d5c <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000d5c:	1101                	addi	sp,sp,-32
    80000d5e:	ec06                	sd	ra,24(sp)
    80000d60:	e822                	sd	s0,16(sp)
    80000d62:	e426                	sd	s1,8(sp)
    80000d64:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d66:	100024f3          	csrr	s1,sstatus
    80000d6a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000d6e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000d70:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000d74:	00001097          	auipc	ra,0x1
    80000d78:	f28080e7          	jalr	-216(ra) # 80001c9c <mycpu>
    80000d7c:	5d3c                	lw	a5,120(a0)
    80000d7e:	cf89                	beqz	a5,80000d98 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000d80:	00001097          	auipc	ra,0x1
    80000d84:	f1c080e7          	jalr	-228(ra) # 80001c9c <mycpu>
    80000d88:	5d3c                	lw	a5,120(a0)
    80000d8a:	2785                	addiw	a5,a5,1
    80000d8c:	dd3c                	sw	a5,120(a0)
}
    80000d8e:	60e2                	ld	ra,24(sp)
    80000d90:	6442                	ld	s0,16(sp)
    80000d92:	64a2                	ld	s1,8(sp)
    80000d94:	6105                	addi	sp,sp,32
    80000d96:	8082                	ret
    mycpu()->intena = old;
    80000d98:	00001097          	auipc	ra,0x1
    80000d9c:	f04080e7          	jalr	-252(ra) # 80001c9c <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000da0:	8085                	srli	s1,s1,0x1
    80000da2:	8885                	andi	s1,s1,1
    80000da4:	dd64                	sw	s1,124(a0)
    80000da6:	bfe9                	j	80000d80 <push_off+0x24>

0000000080000da8 <acquire>:
{
    80000da8:	1101                	addi	sp,sp,-32
    80000daa:	ec06                	sd	ra,24(sp)
    80000dac:	e822                	sd	s0,16(sp)
    80000dae:	e426                	sd	s1,8(sp)
    80000db0:	1000                	addi	s0,sp,32
    80000db2:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000db4:	00000097          	auipc	ra,0x0
    80000db8:	fa8080e7          	jalr	-88(ra) # 80000d5c <push_off>
  if(holding(lk))
    80000dbc:	8526                	mv	a0,s1
    80000dbe:	00000097          	auipc	ra,0x0
    80000dc2:	f70080e7          	jalr	-144(ra) # 80000d2e <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000dc6:	4705                	li	a4,1
  if(holding(lk))
    80000dc8:	e115                	bnez	a0,80000dec <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000dca:	87ba                	mv	a5,a4
    80000dcc:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000dd0:	2781                	sext.w	a5,a5
    80000dd2:	ffe5                	bnez	a5,80000dca <acquire+0x22>
  __sync_synchronize();
    80000dd4:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000dd8:	00001097          	auipc	ra,0x1
    80000ddc:	ec4080e7          	jalr	-316(ra) # 80001c9c <mycpu>
    80000de0:	e888                	sd	a0,16(s1)
}
    80000de2:	60e2                	ld	ra,24(sp)
    80000de4:	6442                	ld	s0,16(sp)
    80000de6:	64a2                	ld	s1,8(sp)
    80000de8:	6105                	addi	sp,sp,32
    80000dea:	8082                	ret
    panic("acquire");
    80000dec:	00007517          	auipc	a0,0x7
    80000df0:	2b450513          	addi	a0,a0,692 # 800080a0 <digits+0x60>
    80000df4:	fffff097          	auipc	ra,0xfffff
    80000df8:	750080e7          	jalr	1872(ra) # 80000544 <panic>

0000000080000dfc <pop_off>:

void
pop_off(void)
{
    80000dfc:	1141                	addi	sp,sp,-16
    80000dfe:	e406                	sd	ra,8(sp)
    80000e00:	e022                	sd	s0,0(sp)
    80000e02:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000e04:	00001097          	auipc	ra,0x1
    80000e08:	e98080e7          	jalr	-360(ra) # 80001c9c <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000e0c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000e10:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000e12:	e78d                	bnez	a5,80000e3c <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000e14:	5d3c                	lw	a5,120(a0)
    80000e16:	02f05b63          	blez	a5,80000e4c <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000e1a:	37fd                	addiw	a5,a5,-1
    80000e1c:	0007871b          	sext.w	a4,a5
    80000e20:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000e22:	eb09                	bnez	a4,80000e34 <pop_off+0x38>
    80000e24:	5d7c                	lw	a5,124(a0)
    80000e26:	c799                	beqz	a5,80000e34 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000e28:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000e2c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000e30:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000e34:	60a2                	ld	ra,8(sp)
    80000e36:	6402                	ld	s0,0(sp)
    80000e38:	0141                	addi	sp,sp,16
    80000e3a:	8082                	ret
    panic("pop_off - interruptible");
    80000e3c:	00007517          	auipc	a0,0x7
    80000e40:	26c50513          	addi	a0,a0,620 # 800080a8 <digits+0x68>
    80000e44:	fffff097          	auipc	ra,0xfffff
    80000e48:	700080e7          	jalr	1792(ra) # 80000544 <panic>
    panic("pop_off");
    80000e4c:	00007517          	auipc	a0,0x7
    80000e50:	27450513          	addi	a0,a0,628 # 800080c0 <digits+0x80>
    80000e54:	fffff097          	auipc	ra,0xfffff
    80000e58:	6f0080e7          	jalr	1776(ra) # 80000544 <panic>

0000000080000e5c <release>:
{
    80000e5c:	1101                	addi	sp,sp,-32
    80000e5e:	ec06                	sd	ra,24(sp)
    80000e60:	e822                	sd	s0,16(sp)
    80000e62:	e426                	sd	s1,8(sp)
    80000e64:	1000                	addi	s0,sp,32
    80000e66:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000e68:	00000097          	auipc	ra,0x0
    80000e6c:	ec6080e7          	jalr	-314(ra) # 80000d2e <holding>
    80000e70:	c115                	beqz	a0,80000e94 <release+0x38>
  lk->cpu = 0;
    80000e72:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000e76:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000e7a:	0f50000f          	fence	iorw,ow
    80000e7e:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000e82:	00000097          	auipc	ra,0x0
    80000e86:	f7a080e7          	jalr	-134(ra) # 80000dfc <pop_off>
}
    80000e8a:	60e2                	ld	ra,24(sp)
    80000e8c:	6442                	ld	s0,16(sp)
    80000e8e:	64a2                	ld	s1,8(sp)
    80000e90:	6105                	addi	sp,sp,32
    80000e92:	8082                	ret
    panic("release");
    80000e94:	00007517          	auipc	a0,0x7
    80000e98:	23450513          	addi	a0,a0,564 # 800080c8 <digits+0x88>
    80000e9c:	fffff097          	auipc	ra,0xfffff
    80000ea0:	6a8080e7          	jalr	1704(ra) # 80000544 <panic>

0000000080000ea4 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ea4:	1141                	addi	sp,sp,-16
    80000ea6:	e422                	sd	s0,8(sp)
    80000ea8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000eaa:	ce09                	beqz	a2,80000ec4 <memset+0x20>
    80000eac:	87aa                	mv	a5,a0
    80000eae:	fff6071b          	addiw	a4,a2,-1
    80000eb2:	1702                	slli	a4,a4,0x20
    80000eb4:	9301                	srli	a4,a4,0x20
    80000eb6:	0705                	addi	a4,a4,1
    80000eb8:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000eba:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ebe:	0785                	addi	a5,a5,1
    80000ec0:	fee79de3          	bne	a5,a4,80000eba <memset+0x16>
  }
  return dst;
}
    80000ec4:	6422                	ld	s0,8(sp)
    80000ec6:	0141                	addi	sp,sp,16
    80000ec8:	8082                	ret

0000000080000eca <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000eca:	1141                	addi	sp,sp,-16
    80000ecc:	e422                	sd	s0,8(sp)
    80000ece:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000ed0:	ca05                	beqz	a2,80000f00 <memcmp+0x36>
    80000ed2:	fff6069b          	addiw	a3,a2,-1
    80000ed6:	1682                	slli	a3,a3,0x20
    80000ed8:	9281                	srli	a3,a3,0x20
    80000eda:	0685                	addi	a3,a3,1
    80000edc:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000ede:	00054783          	lbu	a5,0(a0)
    80000ee2:	0005c703          	lbu	a4,0(a1)
    80000ee6:	00e79863          	bne	a5,a4,80000ef6 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000eea:	0505                	addi	a0,a0,1
    80000eec:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000eee:	fed518e3          	bne	a0,a3,80000ede <memcmp+0x14>
  }

  return 0;
    80000ef2:	4501                	li	a0,0
    80000ef4:	a019                	j	80000efa <memcmp+0x30>
      return *s1 - *s2;
    80000ef6:	40e7853b          	subw	a0,a5,a4
}
    80000efa:	6422                	ld	s0,8(sp)
    80000efc:	0141                	addi	sp,sp,16
    80000efe:	8082                	ret
  return 0;
    80000f00:	4501                	li	a0,0
    80000f02:	bfe5                	j	80000efa <memcmp+0x30>

0000000080000f04 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000f04:	1141                	addi	sp,sp,-16
    80000f06:	e422                	sd	s0,8(sp)
    80000f08:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000f0a:	ca0d                	beqz	a2,80000f3c <memmove+0x38>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000f0c:	00a5f963          	bgeu	a1,a0,80000f1e <memmove+0x1a>
    80000f10:	02061693          	slli	a3,a2,0x20
    80000f14:	9281                	srli	a3,a3,0x20
    80000f16:	00d58733          	add	a4,a1,a3
    80000f1a:	02e56463          	bltu	a0,a4,80000f42 <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000f1e:	fff6079b          	addiw	a5,a2,-1
    80000f22:	1782                	slli	a5,a5,0x20
    80000f24:	9381                	srli	a5,a5,0x20
    80000f26:	0785                	addi	a5,a5,1
    80000f28:	97ae                	add	a5,a5,a1
    80000f2a:	872a                	mv	a4,a0
      *d++ = *s++;
    80000f2c:	0585                	addi	a1,a1,1
    80000f2e:	0705                	addi	a4,a4,1
    80000f30:	fff5c683          	lbu	a3,-1(a1)
    80000f34:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000f38:	fef59ae3          	bne	a1,a5,80000f2c <memmove+0x28>

  return dst;
}
    80000f3c:	6422                	ld	s0,8(sp)
    80000f3e:	0141                	addi	sp,sp,16
    80000f40:	8082                	ret
    d += n;
    80000f42:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000f44:	fff6079b          	addiw	a5,a2,-1
    80000f48:	1782                	slli	a5,a5,0x20
    80000f4a:	9381                	srli	a5,a5,0x20
    80000f4c:	fff7c793          	not	a5,a5
    80000f50:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000f52:	177d                	addi	a4,a4,-1
    80000f54:	16fd                	addi	a3,a3,-1
    80000f56:	00074603          	lbu	a2,0(a4)
    80000f5a:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000f5e:	fef71ae3          	bne	a4,a5,80000f52 <memmove+0x4e>
    80000f62:	bfe9                	j	80000f3c <memmove+0x38>

0000000080000f64 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000f64:	1141                	addi	sp,sp,-16
    80000f66:	e406                	sd	ra,8(sp)
    80000f68:	e022                	sd	s0,0(sp)
    80000f6a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000f6c:	00000097          	auipc	ra,0x0
    80000f70:	f98080e7          	jalr	-104(ra) # 80000f04 <memmove>
}
    80000f74:	60a2                	ld	ra,8(sp)
    80000f76:	6402                	ld	s0,0(sp)
    80000f78:	0141                	addi	sp,sp,16
    80000f7a:	8082                	ret

0000000080000f7c <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000f7c:	1141                	addi	sp,sp,-16
    80000f7e:	e422                	sd	s0,8(sp)
    80000f80:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000f82:	ce11                	beqz	a2,80000f9e <strncmp+0x22>
    80000f84:	00054783          	lbu	a5,0(a0)
    80000f88:	cf89                	beqz	a5,80000fa2 <strncmp+0x26>
    80000f8a:	0005c703          	lbu	a4,0(a1)
    80000f8e:	00f71a63          	bne	a4,a5,80000fa2 <strncmp+0x26>
    n--, p++, q++;
    80000f92:	367d                	addiw	a2,a2,-1
    80000f94:	0505                	addi	a0,a0,1
    80000f96:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000f98:	f675                	bnez	a2,80000f84 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000f9a:	4501                	li	a0,0
    80000f9c:	a809                	j	80000fae <strncmp+0x32>
    80000f9e:	4501                	li	a0,0
    80000fa0:	a039                	j	80000fae <strncmp+0x32>
  if(n == 0)
    80000fa2:	ca09                	beqz	a2,80000fb4 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000fa4:	00054503          	lbu	a0,0(a0)
    80000fa8:	0005c783          	lbu	a5,0(a1)
    80000fac:	9d1d                	subw	a0,a0,a5
}
    80000fae:	6422                	ld	s0,8(sp)
    80000fb0:	0141                	addi	sp,sp,16
    80000fb2:	8082                	ret
    return 0;
    80000fb4:	4501                	li	a0,0
    80000fb6:	bfe5                	j	80000fae <strncmp+0x32>

0000000080000fb8 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000fb8:	1141                	addi	sp,sp,-16
    80000fba:	e422                	sd	s0,8(sp)
    80000fbc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000fbe:	872a                	mv	a4,a0
    80000fc0:	8832                	mv	a6,a2
    80000fc2:	367d                	addiw	a2,a2,-1
    80000fc4:	01005963          	blez	a6,80000fd6 <strncpy+0x1e>
    80000fc8:	0705                	addi	a4,a4,1
    80000fca:	0005c783          	lbu	a5,0(a1)
    80000fce:	fef70fa3          	sb	a5,-1(a4)
    80000fd2:	0585                	addi	a1,a1,1
    80000fd4:	f7f5                	bnez	a5,80000fc0 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000fd6:	00c05d63          	blez	a2,80000ff0 <strncpy+0x38>
    80000fda:	86ba                	mv	a3,a4
    *s++ = 0;
    80000fdc:	0685                	addi	a3,a3,1
    80000fde:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000fe2:	fff6c793          	not	a5,a3
    80000fe6:	9fb9                	addw	a5,a5,a4
    80000fe8:	010787bb          	addw	a5,a5,a6
    80000fec:	fef048e3          	bgtz	a5,80000fdc <strncpy+0x24>
  return os;
}
    80000ff0:	6422                	ld	s0,8(sp)
    80000ff2:	0141                	addi	sp,sp,16
    80000ff4:	8082                	ret

0000000080000ff6 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000ff6:	1141                	addi	sp,sp,-16
    80000ff8:	e422                	sd	s0,8(sp)
    80000ffa:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000ffc:	02c05363          	blez	a2,80001022 <safestrcpy+0x2c>
    80001000:	fff6069b          	addiw	a3,a2,-1
    80001004:	1682                	slli	a3,a3,0x20
    80001006:	9281                	srli	a3,a3,0x20
    80001008:	96ae                	add	a3,a3,a1
    8000100a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    8000100c:	00d58963          	beq	a1,a3,8000101e <safestrcpy+0x28>
    80001010:	0585                	addi	a1,a1,1
    80001012:	0785                	addi	a5,a5,1
    80001014:	fff5c703          	lbu	a4,-1(a1)
    80001018:	fee78fa3          	sb	a4,-1(a5)
    8000101c:	fb65                	bnez	a4,8000100c <safestrcpy+0x16>
    ;
  *s = 0;
    8000101e:	00078023          	sb	zero,0(a5)
  return os;
}
    80001022:	6422                	ld	s0,8(sp)
    80001024:	0141                	addi	sp,sp,16
    80001026:	8082                	ret

0000000080001028 <strlen>:

int
strlen(const char *s)
{
    80001028:	1141                	addi	sp,sp,-16
    8000102a:	e422                	sd	s0,8(sp)
    8000102c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    8000102e:	00054783          	lbu	a5,0(a0)
    80001032:	cf91                	beqz	a5,8000104e <strlen+0x26>
    80001034:	0505                	addi	a0,a0,1
    80001036:	87aa                	mv	a5,a0
    80001038:	4685                	li	a3,1
    8000103a:	9e89                	subw	a3,a3,a0
    8000103c:	00f6853b          	addw	a0,a3,a5
    80001040:	0785                	addi	a5,a5,1
    80001042:	fff7c703          	lbu	a4,-1(a5)
    80001046:	fb7d                	bnez	a4,8000103c <strlen+0x14>
    ;
  return n;
}
    80001048:	6422                	ld	s0,8(sp)
    8000104a:	0141                	addi	sp,sp,16
    8000104c:	8082                	ret
  for(n = 0; s[n]; n++)
    8000104e:	4501                	li	a0,0
    80001050:	bfe5                	j	80001048 <strlen+0x20>

0000000080001052 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80001052:	1141                	addi	sp,sp,-16
    80001054:	e406                	sd	ra,8(sp)
    80001056:	e022                	sd	s0,0(sp)
    80001058:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    8000105a:	00001097          	auipc	ra,0x1
    8000105e:	c32080e7          	jalr	-974(ra) # 80001c8c <cpuid>
    pinit();
    #endif
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80001062:	00008717          	auipc	a4,0x8
    80001066:	b8670713          	addi	a4,a4,-1146 # 80008be8 <started>
  if(cpuid() == 0){
    8000106a:	c139                	beqz	a0,800010b0 <main+0x5e>
    while(started == 0)
    8000106c:	431c                	lw	a5,0(a4)
    8000106e:	2781                	sext.w	a5,a5
    80001070:	dff5                	beqz	a5,8000106c <main+0x1a>
      ;
    __sync_synchronize();
    80001072:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80001076:	00001097          	auipc	ra,0x1
    8000107a:	c16080e7          	jalr	-1002(ra) # 80001c8c <cpuid>
    8000107e:	85aa                	mv	a1,a0
    80001080:	00007517          	auipc	a0,0x7
    80001084:	06850513          	addi	a0,a0,104 # 800080e8 <digits+0xa8>
    80001088:	fffff097          	auipc	ra,0xfffff
    8000108c:	506080e7          	jalr	1286(ra) # 8000058e <printf>
    kvminithart();    // turn on paging
    80001090:	00000097          	auipc	ra,0x0
    80001094:	0d8080e7          	jalr	216(ra) # 80001168 <kvminithart>
    // printf("kvminit done\n");
    trapinithart();   // install kernel trap vector
    80001098:	00002097          	auipc	ra,0x2
    8000109c:	b5a080e7          	jalr	-1190(ra) # 80002bf2 <trapinithart>
    // printf("trapinit done\n");
    plicinithart();   // ask PLIC for device interrupts
    800010a0:	00005097          	auipc	ra,0x5
    800010a4:	450080e7          	jalr	1104(ra) # 800064f0 <plicinithart>
    // printf("plicinit done\n");
  }

  // printf("about to call sceduler\n");
  // srand(time(NULL));
  scheduler();        
    800010a8:	00001097          	auipc	ra,0x1
    800010ac:	1bc080e7          	jalr	444(ra) # 80002264 <scheduler>
    consoleinit();
    800010b0:	fffff097          	auipc	ra,0xfffff
    800010b4:	3a6080e7          	jalr	934(ra) # 80000456 <consoleinit>
    printfinit();
    800010b8:	fffff097          	auipc	ra,0xfffff
    800010bc:	6bc080e7          	jalr	1724(ra) # 80000774 <printfinit>
    printf("\n");
    800010c0:	00007517          	auipc	a0,0x7
    800010c4:	03850513          	addi	a0,a0,56 # 800080f8 <digits+0xb8>
    800010c8:	fffff097          	auipc	ra,0xfffff
    800010cc:	4c6080e7          	jalr	1222(ra) # 8000058e <printf>
    printf("xv6 kernel is booting\n");
    800010d0:	00007517          	auipc	a0,0x7
    800010d4:	00050513          	mv	a0,a0
    800010d8:	fffff097          	auipc	ra,0xfffff
    800010dc:	4b6080e7          	jalr	1206(ra) # 8000058e <printf>
    printf("\n");
    800010e0:	00007517          	auipc	a0,0x7
    800010e4:	01850513          	addi	a0,a0,24 # 800080f8 <digits+0xb8>
    800010e8:	fffff097          	auipc	ra,0xfffff
    800010ec:	4a6080e7          	jalr	1190(ra) # 8000058e <printf>
    kinit();         // physical page allocator
    800010f0:	00000097          	auipc	ra,0x0
    800010f4:	b48080e7          	jalr	-1208(ra) # 80000c38 <kinit>
    kvminit();       // create kernel page table
    800010f8:	00000097          	auipc	ra,0x0
    800010fc:	326080e7          	jalr	806(ra) # 8000141e <kvminit>
    kvminithart();   // turn on paging
    80001100:	00000097          	auipc	ra,0x0
    80001104:	068080e7          	jalr	104(ra) # 80001168 <kvminithart>
    procinit();      // process table
    80001108:	00001097          	auipc	ra,0x1
    8000110c:	ace080e7          	jalr	-1330(ra) # 80001bd6 <procinit>
    trapinit();      // trap vectors
    80001110:	00002097          	auipc	ra,0x2
    80001114:	aba080e7          	jalr	-1350(ra) # 80002bca <trapinit>
    trapinithart();  // install kernel trap vector
    80001118:	00002097          	auipc	ra,0x2
    8000111c:	ada080e7          	jalr	-1318(ra) # 80002bf2 <trapinithart>
    plicinit();      // set up interrupt controller
    80001120:	00005097          	auipc	ra,0x5
    80001124:	3ba080e7          	jalr	954(ra) # 800064da <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001128:	00005097          	auipc	ra,0x5
    8000112c:	3c8080e7          	jalr	968(ra) # 800064f0 <plicinithart>
    binit();         // buffer cache
    80001130:	00002097          	auipc	ra,0x2
    80001134:	57c080e7          	jalr	1404(ra) # 800036ac <binit>
    iinit();         // inode table
    80001138:	00003097          	auipc	ra,0x3
    8000113c:	c20080e7          	jalr	-992(ra) # 80003d58 <iinit>
    fileinit();      // file table
    80001140:	00004097          	auipc	ra,0x4
    80001144:	bbe080e7          	jalr	-1090(ra) # 80004cfe <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001148:	00005097          	auipc	ra,0x5
    8000114c:	4b0080e7          	jalr	1200(ra) # 800065f8 <virtio_disk_init>
    userinit();      // first user process
    80001150:	00001097          	auipc	ra,0x1
    80001154:	e78080e7          	jalr	-392(ra) # 80001fc8 <userinit>
    __sync_synchronize();
    80001158:	0ff0000f          	fence
    started = 1;
    8000115c:	4785                	li	a5,1
    8000115e:	00008717          	auipc	a4,0x8
    80001162:	a8f72523          	sw	a5,-1398(a4) # 80008be8 <started>
    80001166:	b789                	j	800010a8 <main+0x56>

0000000080001168 <kvminithart>:
}

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void kvminithart()
{
    80001168:	1141                	addi	sp,sp,-16
    8000116a:	e422                	sd	s0,8(sp)
    8000116c:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    8000116e:	12000073          	sfence.vma
	// wait for any previous writes to the page table memory to finish.
	sfence_vma();

	w_satp(MAKE_SATP(kernel_pagetable));
    80001172:	00008797          	auipc	a5,0x8
    80001176:	a7e7b783          	ld	a5,-1410(a5) # 80008bf0 <kernel_pagetable>
    8000117a:	83b1                	srli	a5,a5,0xc
    8000117c:	577d                	li	a4,-1
    8000117e:	177e                	slli	a4,a4,0x3f
    80001180:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001182:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80001186:	12000073          	sfence.vma

	// flush stale entries from the TLB.
	sfence_vma();
}
    8000118a:	6422                	ld	s0,8(sp)
    8000118c:	0141                	addi	sp,sp,16
    8000118e:	8082                	ret

0000000080001190 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001190:	7139                	addi	sp,sp,-64
    80001192:	fc06                	sd	ra,56(sp)
    80001194:	f822                	sd	s0,48(sp)
    80001196:	f426                	sd	s1,40(sp)
    80001198:	f04a                	sd	s2,32(sp)
    8000119a:	ec4e                	sd	s3,24(sp)
    8000119c:	e852                	sd	s4,16(sp)
    8000119e:	e456                	sd	s5,8(sp)
    800011a0:	e05a                	sd	s6,0(sp)
    800011a2:	0080                	addi	s0,sp,64
    800011a4:	84aa                	mv	s1,a0
    800011a6:	89ae                	mv	s3,a1
    800011a8:	8ab2                	mv	s5,a2
	if (va >= MAXVA)
    800011aa:	57fd                	li	a5,-1
    800011ac:	83e9                	srli	a5,a5,0x1a
    800011ae:	4a79                	li	s4,30
		panic("walk");

	for (int level = 2; level > 0; level--)
    800011b0:	4b31                	li	s6,12
	if (va >= MAXVA)
    800011b2:	04b7f263          	bgeu	a5,a1,800011f6 <walk+0x66>
		panic("walk");
    800011b6:	00007517          	auipc	a0,0x7
    800011ba:	f4a50513          	addi	a0,a0,-182 # 80008100 <digits+0xc0>
    800011be:	fffff097          	auipc	ra,0xfffff
    800011c2:	386080e7          	jalr	902(ra) # 80000544 <panic>
		{
			pagetable = (pagetable_t)PTE2PA(*pte);
		}
		else
		{
			if (!alloc || (pagetable = (pde_t *)kalloc()) == 0)
    800011c6:	060a8663          	beqz	s5,80001232 <walk+0xa2>
    800011ca:	00000097          	auipc	ra,0x0
    800011ce:	aaa080e7          	jalr	-1366(ra) # 80000c74 <kalloc>
    800011d2:	84aa                	mv	s1,a0
    800011d4:	c529                	beqz	a0,8000121e <walk+0x8e>
				return 0;
			memset(pagetable, 0, PGSIZE);
    800011d6:	6605                	lui	a2,0x1
    800011d8:	4581                	li	a1,0
    800011da:	00000097          	auipc	ra,0x0
    800011de:	cca080e7          	jalr	-822(ra) # 80000ea4 <memset>
			*pte = PA2PTE(pagetable) | PTE_V;
    800011e2:	00c4d793          	srli	a5,s1,0xc
    800011e6:	07aa                	slli	a5,a5,0xa
    800011e8:	0017e793          	ori	a5,a5,1
    800011ec:	00f93023          	sd	a5,0(s2)
	for (int level = 2; level > 0; level--)
    800011f0:	3a5d                	addiw	s4,s4,-9
    800011f2:	036a0063          	beq	s4,s6,80001212 <walk+0x82>
		pte_t *pte = &pagetable[PX(level, va)];
    800011f6:	0149d933          	srl	s2,s3,s4
    800011fa:	1ff97913          	andi	s2,s2,511
    800011fe:	090e                	slli	s2,s2,0x3
    80001200:	9926                	add	s2,s2,s1
		if (*pte & PTE_V)
    80001202:	00093483          	ld	s1,0(s2)
    80001206:	0014f793          	andi	a5,s1,1
    8000120a:	dfd5                	beqz	a5,800011c6 <walk+0x36>
			pagetable = (pagetable_t)PTE2PA(*pte);
    8000120c:	80a9                	srli	s1,s1,0xa
    8000120e:	04b2                	slli	s1,s1,0xc
    80001210:	b7c5                	j	800011f0 <walk+0x60>
		}
	}
	return &pagetable[PX(0, va)];
    80001212:	00c9d513          	srli	a0,s3,0xc
    80001216:	1ff57513          	andi	a0,a0,511
    8000121a:	050e                	slli	a0,a0,0x3
    8000121c:	9526                	add	a0,a0,s1
}
    8000121e:	70e2                	ld	ra,56(sp)
    80001220:	7442                	ld	s0,48(sp)
    80001222:	74a2                	ld	s1,40(sp)
    80001224:	7902                	ld	s2,32(sp)
    80001226:	69e2                	ld	s3,24(sp)
    80001228:	6a42                	ld	s4,16(sp)
    8000122a:	6aa2                	ld	s5,8(sp)
    8000122c:	6b02                	ld	s6,0(sp)
    8000122e:	6121                	addi	sp,sp,64
    80001230:	8082                	ret
				return 0;
    80001232:	4501                	li	a0,0
    80001234:	b7ed                	j	8000121e <walk+0x8e>

0000000080001236 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
	pte_t *pte;
	uint64 pa;

	if (va >= MAXVA)
    80001236:	57fd                	li	a5,-1
    80001238:	83e9                	srli	a5,a5,0x1a
    8000123a:	00b7f463          	bgeu	a5,a1,80001242 <walkaddr+0xc>
		return 0;
    8000123e:	4501                	li	a0,0
		return 0;
	if ((*pte & PTE_U) == 0)
		return 0;
	pa = PTE2PA(*pte);
	return pa;
}
    80001240:	8082                	ret
{
    80001242:	1141                	addi	sp,sp,-16
    80001244:	e406                	sd	ra,8(sp)
    80001246:	e022                	sd	s0,0(sp)
    80001248:	0800                	addi	s0,sp,16
	pte = walk(pagetable, va, 0);
    8000124a:	4601                	li	a2,0
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	f44080e7          	jalr	-188(ra) # 80001190 <walk>
	if (pte == 0)
    80001254:	c105                	beqz	a0,80001274 <walkaddr+0x3e>
	if ((*pte & PTE_V) == 0)
    80001256:	611c                	ld	a5,0(a0)
	if ((*pte & PTE_U) == 0)
    80001258:	0117f693          	andi	a3,a5,17
    8000125c:	4745                	li	a4,17
		return 0;
    8000125e:	4501                	li	a0,0
	if ((*pte & PTE_U) == 0)
    80001260:	00e68663          	beq	a3,a4,8000126c <walkaddr+0x36>
}
    80001264:	60a2                	ld	ra,8(sp)
    80001266:	6402                	ld	s0,0(sp)
    80001268:	0141                	addi	sp,sp,16
    8000126a:	8082                	ret
	pa = PTE2PA(*pte);
    8000126c:	00a7d513          	srli	a0,a5,0xa
    80001270:	0532                	slli	a0,a0,0xc
	return pa;
    80001272:	bfcd                	j	80001264 <walkaddr+0x2e>
		return 0;
    80001274:	4501                	li	a0,0
    80001276:	b7fd                	j	80001264 <walkaddr+0x2e>

0000000080001278 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001278:	715d                	addi	sp,sp,-80
    8000127a:	e486                	sd	ra,72(sp)
    8000127c:	e0a2                	sd	s0,64(sp)
    8000127e:	fc26                	sd	s1,56(sp)
    80001280:	f84a                	sd	s2,48(sp)
    80001282:	f44e                	sd	s3,40(sp)
    80001284:	f052                	sd	s4,32(sp)
    80001286:	ec56                	sd	s5,24(sp)
    80001288:	e85a                	sd	s6,16(sp)
    8000128a:	e45e                	sd	s7,8(sp)
    8000128c:	0880                	addi	s0,sp,80
	uint64 a, last;
	pte_t *pte;

	if (size == 0)
    8000128e:	c205                	beqz	a2,800012ae <mappages+0x36>
    80001290:	8aaa                	mv	s5,a0
    80001292:	8b3a                	mv	s6,a4
		panic("mappages: size");

	a = PGROUNDDOWN(va);
    80001294:	77fd                	lui	a5,0xfffff
    80001296:	00f5fa33          	and	s4,a1,a5
	last = PGROUNDDOWN(va + size - 1);
    8000129a:	15fd                	addi	a1,a1,-1
    8000129c:	00c589b3          	add	s3,a1,a2
    800012a0:	00f9f9b3          	and	s3,s3,a5
	a = PGROUNDDOWN(va);
    800012a4:	8952                	mv	s2,s4
    800012a6:	41468a33          	sub	s4,a3,s4
		if (*pte & PTE_V)
			panic("mappages: remap");
		*pte = PA2PTE(pa) | perm | PTE_V;
		if (a == last)
			break;
		a += PGSIZE;
    800012aa:	6b85                	lui	s7,0x1
    800012ac:	a015                	j	800012d0 <mappages+0x58>
		panic("mappages: size");
    800012ae:	00007517          	auipc	a0,0x7
    800012b2:	e5a50513          	addi	a0,a0,-422 # 80008108 <digits+0xc8>
    800012b6:	fffff097          	auipc	ra,0xfffff
    800012ba:	28e080e7          	jalr	654(ra) # 80000544 <panic>
			panic("mappages: remap");
    800012be:	00007517          	auipc	a0,0x7
    800012c2:	e5a50513          	addi	a0,a0,-422 # 80008118 <digits+0xd8>
    800012c6:	fffff097          	auipc	ra,0xfffff
    800012ca:	27e080e7          	jalr	638(ra) # 80000544 <panic>
		a += PGSIZE;
    800012ce:	995e                	add	s2,s2,s7
	for (;;)
    800012d0:	012a04b3          	add	s1,s4,s2
		if ((pte = walk(pagetable, a, 1)) == 0)
    800012d4:	4605                	li	a2,1
    800012d6:	85ca                	mv	a1,s2
    800012d8:	8556                	mv	a0,s5
    800012da:	00000097          	auipc	ra,0x0
    800012de:	eb6080e7          	jalr	-330(ra) # 80001190 <walk>
    800012e2:	cd19                	beqz	a0,80001300 <mappages+0x88>
		if (*pte & PTE_V)
    800012e4:	611c                	ld	a5,0(a0)
    800012e6:	8b85                	andi	a5,a5,1
    800012e8:	fbf9                	bnez	a5,800012be <mappages+0x46>
		*pte = PA2PTE(pa) | perm | PTE_V;
    800012ea:	80b1                	srli	s1,s1,0xc
    800012ec:	04aa                	slli	s1,s1,0xa
    800012ee:	0164e4b3          	or	s1,s1,s6
    800012f2:	0014e493          	ori	s1,s1,1
    800012f6:	e104                	sd	s1,0(a0)
		if (a == last)
    800012f8:	fd391be3          	bne	s2,s3,800012ce <mappages+0x56>
		pa += PGSIZE;
	}
	return 0;
    800012fc:	4501                	li	a0,0
    800012fe:	a011                	j	80001302 <mappages+0x8a>
			return -1;
    80001300:	557d                	li	a0,-1
}
    80001302:	60a6                	ld	ra,72(sp)
    80001304:	6406                	ld	s0,64(sp)
    80001306:	74e2                	ld	s1,56(sp)
    80001308:	7942                	ld	s2,48(sp)
    8000130a:	79a2                	ld	s3,40(sp)
    8000130c:	7a02                	ld	s4,32(sp)
    8000130e:	6ae2                	ld	s5,24(sp)
    80001310:	6b42                	ld	s6,16(sp)
    80001312:	6ba2                	ld	s7,8(sp)
    80001314:	6161                	addi	sp,sp,80
    80001316:	8082                	ret

0000000080001318 <kvmmap>:
{
    80001318:	1141                	addi	sp,sp,-16
    8000131a:	e406                	sd	ra,8(sp)
    8000131c:	e022                	sd	s0,0(sp)
    8000131e:	0800                	addi	s0,sp,16
    80001320:	87b6                	mv	a5,a3
	if (mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001322:	86b2                	mv	a3,a2
    80001324:	863e                	mv	a2,a5
    80001326:	00000097          	auipc	ra,0x0
    8000132a:	f52080e7          	jalr	-174(ra) # 80001278 <mappages>
    8000132e:	e509                	bnez	a0,80001338 <kvmmap+0x20>
}
    80001330:	60a2                	ld	ra,8(sp)
    80001332:	6402                	ld	s0,0(sp)
    80001334:	0141                	addi	sp,sp,16
    80001336:	8082                	ret
		panic("kvmmap");
    80001338:	00007517          	auipc	a0,0x7
    8000133c:	df050513          	addi	a0,a0,-528 # 80008128 <digits+0xe8>
    80001340:	fffff097          	auipc	ra,0xfffff
    80001344:	204080e7          	jalr	516(ra) # 80000544 <panic>

0000000080001348 <kvmmake>:
{
    80001348:	1101                	addi	sp,sp,-32
    8000134a:	ec06                	sd	ra,24(sp)
    8000134c:	e822                	sd	s0,16(sp)
    8000134e:	e426                	sd	s1,8(sp)
    80001350:	e04a                	sd	s2,0(sp)
    80001352:	1000                	addi	s0,sp,32
	kpgtbl = (pagetable_t)kalloc();
    80001354:	00000097          	auipc	ra,0x0
    80001358:	920080e7          	jalr	-1760(ra) # 80000c74 <kalloc>
    8000135c:	84aa                	mv	s1,a0
	memset(kpgtbl, 0, PGSIZE);
    8000135e:	6605                	lui	a2,0x1
    80001360:	4581                	li	a1,0
    80001362:	00000097          	auipc	ra,0x0
    80001366:	b42080e7          	jalr	-1214(ra) # 80000ea4 <memset>
	kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000136a:	4719                	li	a4,6
    8000136c:	6685                	lui	a3,0x1
    8000136e:	10000637          	lui	a2,0x10000
    80001372:	100005b7          	lui	a1,0x10000
    80001376:	8526                	mv	a0,s1
    80001378:	00000097          	auipc	ra,0x0
    8000137c:	fa0080e7          	jalr	-96(ra) # 80001318 <kvmmap>
	kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001380:	4719                	li	a4,6
    80001382:	6685                	lui	a3,0x1
    80001384:	10001637          	lui	a2,0x10001
    80001388:	100015b7          	lui	a1,0x10001
    8000138c:	8526                	mv	a0,s1
    8000138e:	00000097          	auipc	ra,0x0
    80001392:	f8a080e7          	jalr	-118(ra) # 80001318 <kvmmap>
	kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001396:	4719                	li	a4,6
    80001398:	004006b7          	lui	a3,0x400
    8000139c:	0c000637          	lui	a2,0xc000
    800013a0:	0c0005b7          	lui	a1,0xc000
    800013a4:	8526                	mv	a0,s1
    800013a6:	00000097          	auipc	ra,0x0
    800013aa:	f72080e7          	jalr	-142(ra) # 80001318 <kvmmap>
	kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext - KERNBASE, PTE_R | PTE_X);
    800013ae:	00007917          	auipc	s2,0x7
    800013b2:	c5290913          	addi	s2,s2,-942 # 80008000 <etext>
    800013b6:	4729                	li	a4,10
    800013b8:	80007697          	auipc	a3,0x80007
    800013bc:	c4868693          	addi	a3,a3,-952 # 8000 <_entry-0x7fff8000>
    800013c0:	4605                	li	a2,1
    800013c2:	067e                	slli	a2,a2,0x1f
    800013c4:	85b2                	mv	a1,a2
    800013c6:	8526                	mv	a0,s1
    800013c8:	00000097          	auipc	ra,0x0
    800013cc:	f50080e7          	jalr	-176(ra) # 80001318 <kvmmap>
	kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP - (uint64)etext, PTE_R | PTE_W);
    800013d0:	4719                	li	a4,6
    800013d2:	46c5                	li	a3,17
    800013d4:	06ee                	slli	a3,a3,0x1b
    800013d6:	412686b3          	sub	a3,a3,s2
    800013da:	864a                	mv	a2,s2
    800013dc:	85ca                	mv	a1,s2
    800013de:	8526                	mv	a0,s1
    800013e0:	00000097          	auipc	ra,0x0
    800013e4:	f38080e7          	jalr	-200(ra) # 80001318 <kvmmap>
	kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800013e8:	4729                	li	a4,10
    800013ea:	6685                	lui	a3,0x1
    800013ec:	00006617          	auipc	a2,0x6
    800013f0:	c1460613          	addi	a2,a2,-1004 # 80007000 <_trampoline>
    800013f4:	040005b7          	lui	a1,0x4000
    800013f8:	15fd                	addi	a1,a1,-1
    800013fa:	05b2                	slli	a1,a1,0xc
    800013fc:	8526                	mv	a0,s1
    800013fe:	00000097          	auipc	ra,0x0
    80001402:	f1a080e7          	jalr	-230(ra) # 80001318 <kvmmap>
	proc_mapstacks(kpgtbl);
    80001406:	8526                	mv	a0,s1
    80001408:	00000097          	auipc	ra,0x0
    8000140c:	738080e7          	jalr	1848(ra) # 80001b40 <proc_mapstacks>
}
    80001410:	8526                	mv	a0,s1
    80001412:	60e2                	ld	ra,24(sp)
    80001414:	6442                	ld	s0,16(sp)
    80001416:	64a2                	ld	s1,8(sp)
    80001418:	6902                	ld	s2,0(sp)
    8000141a:	6105                	addi	sp,sp,32
    8000141c:	8082                	ret

000000008000141e <kvminit>:
{
    8000141e:	1141                	addi	sp,sp,-16
    80001420:	e406                	sd	ra,8(sp)
    80001422:	e022                	sd	s0,0(sp)
    80001424:	0800                	addi	s0,sp,16
	kernel_pagetable = kvmmake();
    80001426:	00000097          	auipc	ra,0x0
    8000142a:	f22080e7          	jalr	-222(ra) # 80001348 <kvmmake>
    8000142e:	00007797          	auipc	a5,0x7
    80001432:	7ca7b123          	sd	a0,1986(a5) # 80008bf0 <kernel_pagetable>
}
    80001436:	60a2                	ld	ra,8(sp)
    80001438:	6402                	ld	s0,0(sp)
    8000143a:	0141                	addi	sp,sp,16
    8000143c:	8082                	ret

000000008000143e <uvmunmap>:

// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000143e:	715d                	addi	sp,sp,-80
    80001440:	e486                	sd	ra,72(sp)
    80001442:	e0a2                	sd	s0,64(sp)
    80001444:	fc26                	sd	s1,56(sp)
    80001446:	f84a                	sd	s2,48(sp)
    80001448:	f44e                	sd	s3,40(sp)
    8000144a:	f052                	sd	s4,32(sp)
    8000144c:	ec56                	sd	s5,24(sp)
    8000144e:	e85a                	sd	s6,16(sp)
    80001450:	e45e                	sd	s7,8(sp)
    80001452:	0880                	addi	s0,sp,80
	uint64 a;
	pte_t *pte;

	if ((va % PGSIZE) != 0)
    80001454:	03459793          	slli	a5,a1,0x34
    80001458:	e795                	bnez	a5,80001484 <uvmunmap+0x46>
    8000145a:	8a2a                	mv	s4,a0
    8000145c:	892e                	mv	s2,a1
    8000145e:	8ab6                	mv	s5,a3
		panic("uvmunmap: not aligned");

	for (a = va; a < va + npages * PGSIZE; a += PGSIZE)
    80001460:	0632                	slli	a2,a2,0xc
    80001462:	00b609b3          	add	s3,a2,a1
	{
		if ((pte = walk(pagetable, a, 0)) == 0)
			panic("uvmunmap: walk");
		if ((*pte & PTE_V) == 0)
			panic("uvmunmap: not mapped");
		if (PTE_FLAGS(*pte) == PTE_V)
    80001466:	4b85                	li	s7,1
	for (a = va; a < va + npages * PGSIZE; a += PGSIZE)
    80001468:	6b05                	lui	s6,0x1
    8000146a:	0735e863          	bltu	a1,s3,800014da <uvmunmap+0x9c>
			uint64 pa = PTE2PA(*pte);
			kfree((void *)pa);
		}
		*pte = 0;
	}
}
    8000146e:	60a6                	ld	ra,72(sp)
    80001470:	6406                	ld	s0,64(sp)
    80001472:	74e2                	ld	s1,56(sp)
    80001474:	7942                	ld	s2,48(sp)
    80001476:	79a2                	ld	s3,40(sp)
    80001478:	7a02                	ld	s4,32(sp)
    8000147a:	6ae2                	ld	s5,24(sp)
    8000147c:	6b42                	ld	s6,16(sp)
    8000147e:	6ba2                	ld	s7,8(sp)
    80001480:	6161                	addi	sp,sp,80
    80001482:	8082                	ret
		panic("uvmunmap: not aligned");
    80001484:	00007517          	auipc	a0,0x7
    80001488:	cac50513          	addi	a0,a0,-852 # 80008130 <digits+0xf0>
    8000148c:	fffff097          	auipc	ra,0xfffff
    80001490:	0b8080e7          	jalr	184(ra) # 80000544 <panic>
			panic("uvmunmap: walk");
    80001494:	00007517          	auipc	a0,0x7
    80001498:	cb450513          	addi	a0,a0,-844 # 80008148 <digits+0x108>
    8000149c:	fffff097          	auipc	ra,0xfffff
    800014a0:	0a8080e7          	jalr	168(ra) # 80000544 <panic>
			panic("uvmunmap: not mapped");
    800014a4:	00007517          	auipc	a0,0x7
    800014a8:	cb450513          	addi	a0,a0,-844 # 80008158 <digits+0x118>
    800014ac:	fffff097          	auipc	ra,0xfffff
    800014b0:	098080e7          	jalr	152(ra) # 80000544 <panic>
			panic("uvmunmap: not a leaf");
    800014b4:	00007517          	auipc	a0,0x7
    800014b8:	cbc50513          	addi	a0,a0,-836 # 80008170 <digits+0x130>
    800014bc:	fffff097          	auipc	ra,0xfffff
    800014c0:	088080e7          	jalr	136(ra) # 80000544 <panic>
			uint64 pa = PTE2PA(*pte);
    800014c4:	8129                	srli	a0,a0,0xa
			kfree((void *)pa);
    800014c6:	0532                	slli	a0,a0,0xc
    800014c8:	fffff097          	auipc	ra,0xfffff
    800014cc:	606080e7          	jalr	1542(ra) # 80000ace <kfree>
		*pte = 0;
    800014d0:	0004b023          	sd	zero,0(s1)
	for (a = va; a < va + npages * PGSIZE; a += PGSIZE)
    800014d4:	995a                	add	s2,s2,s6
    800014d6:	f9397ce3          	bgeu	s2,s3,8000146e <uvmunmap+0x30>
		if ((pte = walk(pagetable, a, 0)) == 0)
    800014da:	4601                	li	a2,0
    800014dc:	85ca                	mv	a1,s2
    800014de:	8552                	mv	a0,s4
    800014e0:	00000097          	auipc	ra,0x0
    800014e4:	cb0080e7          	jalr	-848(ra) # 80001190 <walk>
    800014e8:	84aa                	mv	s1,a0
    800014ea:	d54d                	beqz	a0,80001494 <uvmunmap+0x56>
		if ((*pte & PTE_V) == 0)
    800014ec:	6108                	ld	a0,0(a0)
    800014ee:	00157793          	andi	a5,a0,1
    800014f2:	dbcd                	beqz	a5,800014a4 <uvmunmap+0x66>
		if (PTE_FLAGS(*pte) == PTE_V)
    800014f4:	3ff57793          	andi	a5,a0,1023
    800014f8:	fb778ee3          	beq	a5,s7,800014b4 <uvmunmap+0x76>
		if (do_free)
    800014fc:	fc0a8ae3          	beqz	s5,800014d0 <uvmunmap+0x92>
    80001500:	b7d1                	j	800014c4 <uvmunmap+0x86>

0000000080001502 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001502:	1101                	addi	sp,sp,-32
    80001504:	ec06                	sd	ra,24(sp)
    80001506:	e822                	sd	s0,16(sp)
    80001508:	e426                	sd	s1,8(sp)
    8000150a:	1000                	addi	s0,sp,32
	pagetable_t pagetable;
	pagetable = (pagetable_t)kalloc();
    8000150c:	fffff097          	auipc	ra,0xfffff
    80001510:	768080e7          	jalr	1896(ra) # 80000c74 <kalloc>
    80001514:	84aa                	mv	s1,a0
	if (pagetable == 0)
    80001516:	c519                	beqz	a0,80001524 <uvmcreate+0x22>
		return 0;
	memset(pagetable, 0, PGSIZE);
    80001518:	6605                	lui	a2,0x1
    8000151a:	4581                	li	a1,0
    8000151c:	00000097          	auipc	ra,0x0
    80001520:	988080e7          	jalr	-1656(ra) # 80000ea4 <memset>
	return pagetable;
}
    80001524:	8526                	mv	a0,s1
    80001526:	60e2                	ld	ra,24(sp)
    80001528:	6442                	ld	s0,16(sp)
    8000152a:	64a2                	ld	s1,8(sp)
    8000152c:	6105                	addi	sp,sp,32
    8000152e:	8082                	ret

0000000080001530 <uvmfirst>:

// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001530:	7179                	addi	sp,sp,-48
    80001532:	f406                	sd	ra,40(sp)
    80001534:	f022                	sd	s0,32(sp)
    80001536:	ec26                	sd	s1,24(sp)
    80001538:	e84a                	sd	s2,16(sp)
    8000153a:	e44e                	sd	s3,8(sp)
    8000153c:	e052                	sd	s4,0(sp)
    8000153e:	1800                	addi	s0,sp,48
	char *mem;

	if (sz >= PGSIZE)
    80001540:	6785                	lui	a5,0x1
    80001542:	04f67863          	bgeu	a2,a5,80001592 <uvmfirst+0x62>
    80001546:	8a2a                	mv	s4,a0
    80001548:	89ae                	mv	s3,a1
    8000154a:	84b2                	mv	s1,a2
		panic("uvmfirst: more than a page");
	mem = kalloc();
    8000154c:	fffff097          	auipc	ra,0xfffff
    80001550:	728080e7          	jalr	1832(ra) # 80000c74 <kalloc>
    80001554:	892a                	mv	s2,a0
	memset(mem, 0, PGSIZE);
    80001556:	6605                	lui	a2,0x1
    80001558:	4581                	li	a1,0
    8000155a:	00000097          	auipc	ra,0x0
    8000155e:	94a080e7          	jalr	-1718(ra) # 80000ea4 <memset>
	mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W | PTE_R | PTE_X | PTE_U);
    80001562:	4779                	li	a4,30
    80001564:	86ca                	mv	a3,s2
    80001566:	6605                	lui	a2,0x1
    80001568:	4581                	li	a1,0
    8000156a:	8552                	mv	a0,s4
    8000156c:	00000097          	auipc	ra,0x0
    80001570:	d0c080e7          	jalr	-756(ra) # 80001278 <mappages>
	memmove(mem, src, sz);
    80001574:	8626                	mv	a2,s1
    80001576:	85ce                	mv	a1,s3
    80001578:	854a                	mv	a0,s2
    8000157a:	00000097          	auipc	ra,0x0
    8000157e:	98a080e7          	jalr	-1654(ra) # 80000f04 <memmove>
}
    80001582:	70a2                	ld	ra,40(sp)
    80001584:	7402                	ld	s0,32(sp)
    80001586:	64e2                	ld	s1,24(sp)
    80001588:	6942                	ld	s2,16(sp)
    8000158a:	69a2                	ld	s3,8(sp)
    8000158c:	6a02                	ld	s4,0(sp)
    8000158e:	6145                	addi	sp,sp,48
    80001590:	8082                	ret
		panic("uvmfirst: more than a page");
    80001592:	00007517          	auipc	a0,0x7
    80001596:	bf650513          	addi	a0,a0,-1034 # 80008188 <digits+0x148>
    8000159a:	fffff097          	auipc	ra,0xfffff
    8000159e:	faa080e7          	jalr	-86(ra) # 80000544 <panic>

00000000800015a2 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800015a2:	1101                	addi	sp,sp,-32
    800015a4:	ec06                	sd	ra,24(sp)
    800015a6:	e822                	sd	s0,16(sp)
    800015a8:	e426                	sd	s1,8(sp)
    800015aa:	1000                	addi	s0,sp,32
	if (newsz >= oldsz)
		return oldsz;
    800015ac:	84ae                	mv	s1,a1
	if (newsz >= oldsz)
    800015ae:	00b67d63          	bgeu	a2,a1,800015c8 <uvmdealloc+0x26>
    800015b2:	84b2                	mv	s1,a2

	if (PGROUNDUP(newsz) < PGROUNDUP(oldsz))
    800015b4:	6785                	lui	a5,0x1
    800015b6:	17fd                	addi	a5,a5,-1
    800015b8:	00f60733          	add	a4,a2,a5
    800015bc:	767d                	lui	a2,0xfffff
    800015be:	8f71                	and	a4,a4,a2
    800015c0:	97ae                	add	a5,a5,a1
    800015c2:	8ff1                	and	a5,a5,a2
    800015c4:	00f76863          	bltu	a4,a5,800015d4 <uvmdealloc+0x32>
		int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
		uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
	}

	return newsz;
}
    800015c8:	8526                	mv	a0,s1
    800015ca:	60e2                	ld	ra,24(sp)
    800015cc:	6442                	ld	s0,16(sp)
    800015ce:	64a2                	ld	s1,8(sp)
    800015d0:	6105                	addi	sp,sp,32
    800015d2:	8082                	ret
		int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800015d4:	8f99                	sub	a5,a5,a4
    800015d6:	83b1                	srli	a5,a5,0xc
		uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800015d8:	4685                	li	a3,1
    800015da:	0007861b          	sext.w	a2,a5
    800015de:	85ba                	mv	a1,a4
    800015e0:	00000097          	auipc	ra,0x0
    800015e4:	e5e080e7          	jalr	-418(ra) # 8000143e <uvmunmap>
    800015e8:	b7c5                	j	800015c8 <uvmdealloc+0x26>

00000000800015ea <uvmalloc>:
	if (newsz < oldsz)
    800015ea:	0ab66563          	bltu	a2,a1,80001694 <uvmalloc+0xaa>
{
    800015ee:	7139                	addi	sp,sp,-64
    800015f0:	fc06                	sd	ra,56(sp)
    800015f2:	f822                	sd	s0,48(sp)
    800015f4:	f426                	sd	s1,40(sp)
    800015f6:	f04a                	sd	s2,32(sp)
    800015f8:	ec4e                	sd	s3,24(sp)
    800015fa:	e852                	sd	s4,16(sp)
    800015fc:	e456                	sd	s5,8(sp)
    800015fe:	e05a                	sd	s6,0(sp)
    80001600:	0080                	addi	s0,sp,64
    80001602:	8aaa                	mv	s5,a0
    80001604:	8a32                	mv	s4,a2
	oldsz = PGROUNDUP(oldsz);
    80001606:	6985                	lui	s3,0x1
    80001608:	19fd                	addi	s3,s3,-1
    8000160a:	95ce                	add	a1,a1,s3
    8000160c:	79fd                	lui	s3,0xfffff
    8000160e:	0135f9b3          	and	s3,a1,s3
	for (a = oldsz; a < newsz; a += PGSIZE)
    80001612:	08c9f363          	bgeu	s3,a2,80001698 <uvmalloc+0xae>
    80001616:	894e                	mv	s2,s3
		if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) != 0)
    80001618:	0126eb13          	ori	s6,a3,18
		mem = kalloc();
    8000161c:	fffff097          	auipc	ra,0xfffff
    80001620:	658080e7          	jalr	1624(ra) # 80000c74 <kalloc>
    80001624:	84aa                	mv	s1,a0
		if (mem == 0)
    80001626:	c51d                	beqz	a0,80001654 <uvmalloc+0x6a>
		memset(mem, 0, PGSIZE);
    80001628:	6605                	lui	a2,0x1
    8000162a:	4581                	li	a1,0
    8000162c:	00000097          	auipc	ra,0x0
    80001630:	878080e7          	jalr	-1928(ra) # 80000ea4 <memset>
		if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) != 0)
    80001634:	875a                	mv	a4,s6
    80001636:	86a6                	mv	a3,s1
    80001638:	6605                	lui	a2,0x1
    8000163a:	85ca                	mv	a1,s2
    8000163c:	8556                	mv	a0,s5
    8000163e:	00000097          	auipc	ra,0x0
    80001642:	c3a080e7          	jalr	-966(ra) # 80001278 <mappages>
    80001646:	e90d                	bnez	a0,80001678 <uvmalloc+0x8e>
	for (a = oldsz; a < newsz; a += PGSIZE)
    80001648:	6785                	lui	a5,0x1
    8000164a:	993e                	add	s2,s2,a5
    8000164c:	fd4968e3          	bltu	s2,s4,8000161c <uvmalloc+0x32>
	return newsz;
    80001650:	8552                	mv	a0,s4
    80001652:	a809                	j	80001664 <uvmalloc+0x7a>
			uvmdealloc(pagetable, a, oldsz);
    80001654:	864e                	mv	a2,s3
    80001656:	85ca                	mv	a1,s2
    80001658:	8556                	mv	a0,s5
    8000165a:	00000097          	auipc	ra,0x0
    8000165e:	f48080e7          	jalr	-184(ra) # 800015a2 <uvmdealloc>
			return 0;
    80001662:	4501                	li	a0,0
}
    80001664:	70e2                	ld	ra,56(sp)
    80001666:	7442                	ld	s0,48(sp)
    80001668:	74a2                	ld	s1,40(sp)
    8000166a:	7902                	ld	s2,32(sp)
    8000166c:	69e2                	ld	s3,24(sp)
    8000166e:	6a42                	ld	s4,16(sp)
    80001670:	6aa2                	ld	s5,8(sp)
    80001672:	6b02                	ld	s6,0(sp)
    80001674:	6121                	addi	sp,sp,64
    80001676:	8082                	ret
			kfree(mem);
    80001678:	8526                	mv	a0,s1
    8000167a:	fffff097          	auipc	ra,0xfffff
    8000167e:	454080e7          	jalr	1108(ra) # 80000ace <kfree>
			uvmdealloc(pagetable, a, oldsz);
    80001682:	864e                	mv	a2,s3
    80001684:	85ca                	mv	a1,s2
    80001686:	8556                	mv	a0,s5
    80001688:	00000097          	auipc	ra,0x0
    8000168c:	f1a080e7          	jalr	-230(ra) # 800015a2 <uvmdealloc>
			return 0;
    80001690:	4501                	li	a0,0
    80001692:	bfc9                	j	80001664 <uvmalloc+0x7a>
		return oldsz;
    80001694:	852e                	mv	a0,a1
}
    80001696:	8082                	ret
	return newsz;
    80001698:	8532                	mv	a0,a2
    8000169a:	b7e9                	j	80001664 <uvmalloc+0x7a>

000000008000169c <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void freewalk(pagetable_t pagetable)
{
    8000169c:	7179                	addi	sp,sp,-48
    8000169e:	f406                	sd	ra,40(sp)
    800016a0:	f022                	sd	s0,32(sp)
    800016a2:	ec26                	sd	s1,24(sp)
    800016a4:	e84a                	sd	s2,16(sp)
    800016a6:	e44e                	sd	s3,8(sp)
    800016a8:	e052                	sd	s4,0(sp)
    800016aa:	1800                	addi	s0,sp,48
    800016ac:	8a2a                	mv	s4,a0
	// there are 2^9 = 512 PTEs in a page table.
	for (int i = 0; i < 512; i++)
    800016ae:	84aa                	mv	s1,a0
    800016b0:	6905                	lui	s2,0x1
    800016b2:	992a                	add	s2,s2,a0
	{
		pte_t pte = pagetable[i];
		if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    800016b4:	4985                	li	s3,1
    800016b6:	a821                	j	800016ce <freewalk+0x32>
		{
			// this PTE points to a lower-level page table.
			uint64 child = PTE2PA(pte);
    800016b8:	8129                	srli	a0,a0,0xa
			freewalk((pagetable_t)child);
    800016ba:	0532                	slli	a0,a0,0xc
    800016bc:	00000097          	auipc	ra,0x0
    800016c0:	fe0080e7          	jalr	-32(ra) # 8000169c <freewalk>
			pagetable[i] = 0;
    800016c4:	0004b023          	sd	zero,0(s1)
	for (int i = 0; i < 512; i++)
    800016c8:	04a1                	addi	s1,s1,8
    800016ca:	03248163          	beq	s1,s2,800016ec <freewalk+0x50>
		pte_t pte = pagetable[i];
    800016ce:	6088                	ld	a0,0(s1)
		if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    800016d0:	00f57793          	andi	a5,a0,15
    800016d4:	ff3782e3          	beq	a5,s3,800016b8 <freewalk+0x1c>
		}
		else if (pte & PTE_V)
    800016d8:	8905                	andi	a0,a0,1
    800016da:	d57d                	beqz	a0,800016c8 <freewalk+0x2c>
		{
			panic("freewalk: leaf");
    800016dc:	00007517          	auipc	a0,0x7
    800016e0:	acc50513          	addi	a0,a0,-1332 # 800081a8 <digits+0x168>
    800016e4:	fffff097          	auipc	ra,0xfffff
    800016e8:	e60080e7          	jalr	-416(ra) # 80000544 <panic>
		}
	}
	kfree((void *)pagetable);
    800016ec:	8552                	mv	a0,s4
    800016ee:	fffff097          	auipc	ra,0xfffff
    800016f2:	3e0080e7          	jalr	992(ra) # 80000ace <kfree>
}
    800016f6:	70a2                	ld	ra,40(sp)
    800016f8:	7402                	ld	s0,32(sp)
    800016fa:	64e2                	ld	s1,24(sp)
    800016fc:	6942                	ld	s2,16(sp)
    800016fe:	69a2                	ld	s3,8(sp)
    80001700:	6a02                	ld	s4,0(sp)
    80001702:	6145                	addi	sp,sp,48
    80001704:	8082                	ret

0000000080001706 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001706:	1101                	addi	sp,sp,-32
    80001708:	ec06                	sd	ra,24(sp)
    8000170a:	e822                	sd	s0,16(sp)
    8000170c:	e426                	sd	s1,8(sp)
    8000170e:	1000                	addi	s0,sp,32
    80001710:	84aa                	mv	s1,a0
	if (sz > 0)
    80001712:	e999                	bnez	a1,80001728 <uvmfree+0x22>
		uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
	freewalk(pagetable);
    80001714:	8526                	mv	a0,s1
    80001716:	00000097          	auipc	ra,0x0
    8000171a:	f86080e7          	jalr	-122(ra) # 8000169c <freewalk>
}
    8000171e:	60e2                	ld	ra,24(sp)
    80001720:	6442                	ld	s0,16(sp)
    80001722:	64a2                	ld	s1,8(sp)
    80001724:	6105                	addi	sp,sp,32
    80001726:	8082                	ret
		uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    80001728:	6605                	lui	a2,0x1
    8000172a:	167d                	addi	a2,a2,-1
    8000172c:	962e                	add	a2,a2,a1
    8000172e:	4685                	li	a3,1
    80001730:	8231                	srli	a2,a2,0xc
    80001732:	4581                	li	a1,0
    80001734:	00000097          	auipc	ra,0x0
    80001738:	d0a080e7          	jalr	-758(ra) # 8000143e <uvmunmap>
    8000173c:	bfe1                	j	80001714 <uvmfree+0xe>

000000008000173e <uvmcopy>:
	pte_t *pte;
	uint64 pa, i;
	uint flags;
	// char *mem;

	for (i = 0; i < sz; i += PGSIZE)
    8000173e:	c271                	beqz	a2,80001802 <uvmcopy+0xc4>
{
    80001740:	7139                	addi	sp,sp,-64
    80001742:	fc06                	sd	ra,56(sp)
    80001744:	f822                	sd	s0,48(sp)
    80001746:	f426                	sd	s1,40(sp)
    80001748:	f04a                	sd	s2,32(sp)
    8000174a:	ec4e                	sd	s3,24(sp)
    8000174c:	e852                	sd	s4,16(sp)
    8000174e:	e456                	sd	s5,8(sp)
    80001750:	e05a                	sd	s6,0(sp)
    80001752:	0080                	addi	s0,sp,64
    80001754:	8aaa                	mv	s5,a0
    80001756:	8a2e                	mv	s4,a1
    80001758:	89b2                	mv	s3,a2
	for (i = 0; i < sz; i += PGSIZE)
    8000175a:	4481                	li	s1,0
    8000175c:	a0b9                	j	800017aa <uvmcopy+0x6c>
	{
		if ((pte = walk(old, i, 0)) == 0)
			panic("uvmcopy: pte should exist");
    8000175e:	00007517          	auipc	a0,0x7
    80001762:	a5a50513          	addi	a0,a0,-1446 # 800081b8 <digits+0x178>
    80001766:	fffff097          	auipc	ra,0xfffff
    8000176a:	dde080e7          	jalr	-546(ra) # 80000544 <panic>
		if ((*pte & PTE_V) == 0)
			panic("uvmcopy: page not present");
    8000176e:	00007517          	auipc	a0,0x7
    80001772:	a6a50513          	addi	a0,a0,-1430 # 800081d8 <digits+0x198>
    80001776:	fffff097          	auipc	ra,0xfffff
    8000177a:	dce080e7          	jalr	-562(ra) # 80000544 <panic>
			flags &= (~PTE_W);
			// flags = (flags | PTE_C) & (~PTE_W);
			// *pte = (*pte & ~PTE_W) | PTE_C;
		}
		flags |= PTE_C;
		krefincr(pa);
    8000177e:	854a                	mv	a0,s2
    80001780:	fffff097          	auipc	ra,0xfffff
    80001784:	27e080e7          	jalr	638(ra) # 800009fe <krefincr>
    80001788:	12000073          	sfence.vma

		// if ((mem = kalloc()) == 0)
		//   goto err;
		// memmove(mem, (char *)pa, PGSIZE);

		if (mappages(new, i, PGSIZE, (uint64)pa, flags) != 0)
    8000178c:	100b6713          	ori	a4,s6,256
    80001790:	86ca                	mv	a3,s2
    80001792:	6605                	lui	a2,0x1
    80001794:	85a6                	mv	a1,s1
    80001796:	8552                	mv	a0,s4
    80001798:	00000097          	auipc	ra,0x0
    8000179c:	ae0080e7          	jalr	-1312(ra) # 80001278 <mappages>
    800017a0:	ed0d                	bnez	a0,800017da <uvmcopy+0x9c>
	for (i = 0; i < sz; i += PGSIZE)
    800017a2:	6785                	lui	a5,0x1
    800017a4:	94be                	add	s1,s1,a5
    800017a6:	0534f463          	bgeu	s1,s3,800017ee <uvmcopy+0xb0>
		if ((pte = walk(old, i, 0)) == 0)
    800017aa:	4601                	li	a2,0
    800017ac:	85a6                	mv	a1,s1
    800017ae:	8556                	mv	a0,s5
    800017b0:	00000097          	auipc	ra,0x0
    800017b4:	9e0080e7          	jalr	-1568(ra) # 80001190 <walk>
    800017b8:	d15d                	beqz	a0,8000175e <uvmcopy+0x20>
		if ((*pte & PTE_V) == 0)
    800017ba:	611c                	ld	a5,0(a0)
    800017bc:	0017f713          	andi	a4,a5,1
    800017c0:	d75d                	beqz	a4,8000176e <uvmcopy+0x30>
		pa = PTE2PA(*pte);
    800017c2:	00a7d913          	srli	s2,a5,0xa
    800017c6:	0932                	slli	s2,s2,0xc
		flags = PTE_FLAGS(*pte);
    800017c8:	2781                	sext.w	a5,a5
		if (flags & PTE_W)
    800017ca:	0047f713          	andi	a4,a5,4
			flags &= (~PTE_W);
    800017ce:	3fb7fb13          	andi	s6,a5,1019
		if (flags & PTE_W)
    800017d2:	f755                	bnez	a4,8000177e <uvmcopy+0x40>
		flags = PTE_FLAGS(*pte);
    800017d4:	3ff7fb13          	andi	s6,a5,1023
    800017d8:	b75d                	j	8000177e <uvmcopy+0x40>
		}
	}
	return 0;

err:
	uvmunmap(new, 0, i / PGSIZE, 1);
    800017da:	4685                	li	a3,1
    800017dc:	00c4d613          	srli	a2,s1,0xc
    800017e0:	4581                	li	a1,0
    800017e2:	8552                	mv	a0,s4
    800017e4:	00000097          	auipc	ra,0x0
    800017e8:	c5a080e7          	jalr	-934(ra) # 8000143e <uvmunmap>
	return -1;
    800017ec:	557d                	li	a0,-1
}
    800017ee:	70e2                	ld	ra,56(sp)
    800017f0:	7442                	ld	s0,48(sp)
    800017f2:	74a2                	ld	s1,40(sp)
    800017f4:	7902                	ld	s2,32(sp)
    800017f6:	69e2                	ld	s3,24(sp)
    800017f8:	6a42                	ld	s4,16(sp)
    800017fa:	6aa2                	ld	s5,8(sp)
    800017fc:	6b02                	ld	s6,0(sp)
    800017fe:	6121                	addi	sp,sp,64
    80001800:	8082                	ret
	return 0;
    80001802:	4501                	li	a0,0
}
    80001804:	8082                	ret

0000000080001806 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void uvmclear(pagetable_t pagetable, uint64 va)
{
    80001806:	1141                	addi	sp,sp,-16
    80001808:	e406                	sd	ra,8(sp)
    8000180a:	e022                	sd	s0,0(sp)
    8000180c:	0800                	addi	s0,sp,16
	pte_t *pte;

	pte = walk(pagetable, va, 0);
    8000180e:	4601                	li	a2,0
    80001810:	00000097          	auipc	ra,0x0
    80001814:	980080e7          	jalr	-1664(ra) # 80001190 <walk>
	if (pte == 0)
    80001818:	c901                	beqz	a0,80001828 <uvmclear+0x22>
		panic("uvmclear");
	*pte &= ~PTE_U;
    8000181a:	611c                	ld	a5,0(a0)
    8000181c:	9bbd                	andi	a5,a5,-17
    8000181e:	e11c                	sd	a5,0(a0)
}
    80001820:	60a2                	ld	ra,8(sp)
    80001822:	6402                	ld	s0,0(sp)
    80001824:	0141                	addi	sp,sp,16
    80001826:	8082                	ret
		panic("uvmclear");
    80001828:	00007517          	auipc	a0,0x7
    8000182c:	9d050513          	addi	a0,a0,-1584 # 800081f8 <digits+0x1b8>
    80001830:	fffff097          	auipc	ra,0xfffff
    80001834:	d14080e7          	jalr	-748(ra) # 80000544 <panic>

0000000080001838 <copyout>:
// Return 0 on success, -1 on error.
int copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
	uint64 n, va0, pa0;

	while (len > 0)
    80001838:	cad1                	beqz	a3,800018cc <copyout+0x94>
{
    8000183a:	711d                	addi	sp,sp,-96
    8000183c:	ec86                	sd	ra,88(sp)
    8000183e:	e8a2                	sd	s0,80(sp)
    80001840:	e4a6                	sd	s1,72(sp)
    80001842:	e0ca                	sd	s2,64(sp)
    80001844:	fc4e                	sd	s3,56(sp)
    80001846:	f852                	sd	s4,48(sp)
    80001848:	f456                	sd	s5,40(sp)
    8000184a:	f05a                	sd	s6,32(sp)
    8000184c:	ec5e                	sd	s7,24(sp)
    8000184e:	e862                	sd	s8,16(sp)
    80001850:	e466                	sd	s9,8(sp)
    80001852:	1080                	addi	s0,sp,96
    80001854:	8baa                	mv	s7,a0
    80001856:	8aae                	mv	s5,a1
    80001858:	8b32                	mv	s6,a2
    8000185a:	89b6                	mv	s3,a3
	{
		va0 = PGROUNDDOWN(dstva);
    8000185c:	74fd                	lui	s1,0xfffff
    8000185e:	8ced                	and	s1,s1,a1
		// if(len!=1)
		// printf("hiii %d\n",len);
		if (va0 > MAXVA)
    80001860:	4785                	li	a5,1
    80001862:	179a                	slli	a5,a5,0x26
    80001864:	0697e663          	bltu	a5,s1,800018d0 <copyout+0x98>
    80001868:	6c85                	lui	s9,0x1
    8000186a:	04000c37          	lui	s8,0x4000
    8000186e:	0c05                	addi	s8,s8,1
    80001870:	0c32                	slli	s8,s8,0xc
    80001872:	a025                	j	8000189a <copyout+0x62>
		if (pa0 == 0)
			return -1;
		n = PGSIZE - (dstva - va0);
		if (n > len)
			n = len;
		memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001874:	409a84b3          	sub	s1,s5,s1
    80001878:	0009061b          	sext.w	a2,s2
    8000187c:	85da                	mv	a1,s6
    8000187e:	9526                	add	a0,a0,s1
    80001880:	fffff097          	auipc	ra,0xfffff
    80001884:	684080e7          	jalr	1668(ra) # 80000f04 <memmove>

		len -= n;
    80001888:	412989b3          	sub	s3,s3,s2
		src += n;
    8000188c:	9b4a                	add	s6,s6,s2
	while (len > 0)
    8000188e:	02098d63          	beqz	s3,800018c8 <copyout+0x90>
		if (va0 > MAXVA)
    80001892:	058a0163          	beq	s4,s8,800018d4 <copyout+0x9c>
		va0 = PGROUNDDOWN(dstva);
    80001896:	84d2                	mv	s1,s4
		dstva = va0 + PGSIZE;
    80001898:	8ad2                	mv	s5,s4
		if (cowalloc(pagetable, va0) < 0)
    8000189a:	85a6                	mv	a1,s1
    8000189c:	855e                	mv	a0,s7
    8000189e:	00001097          	auipc	ra,0x1
    800018a2:	36c080e7          	jalr	876(ra) # 80002c0a <cowalloc>
    800018a6:	02054963          	bltz	a0,800018d8 <copyout+0xa0>
		pa0 = walkaddr(pagetable, va0);
    800018aa:	85a6                	mv	a1,s1
    800018ac:	855e                	mv	a0,s7
    800018ae:	00000097          	auipc	ra,0x0
    800018b2:	988080e7          	jalr	-1656(ra) # 80001236 <walkaddr>
		if (pa0 == 0)
    800018b6:	cd1d                	beqz	a0,800018f4 <copyout+0xbc>
		n = PGSIZE - (dstva - va0);
    800018b8:	01948a33          	add	s4,s1,s9
    800018bc:	415a0933          	sub	s2,s4,s5
		if (n > len)
    800018c0:	fb29fae3          	bgeu	s3,s2,80001874 <copyout+0x3c>
    800018c4:	894e                	mv	s2,s3
    800018c6:	b77d                	j	80001874 <copyout+0x3c>
	}
	return 0;
    800018c8:	4501                	li	a0,0
    800018ca:	a801                	j	800018da <copyout+0xa2>
    800018cc:	4501                	li	a0,0
}
    800018ce:	8082                	ret
			return -1;
    800018d0:	557d                	li	a0,-1
    800018d2:	a021                	j	800018da <copyout+0xa2>
    800018d4:	557d                	li	a0,-1
    800018d6:	a011                	j	800018da <copyout+0xa2>
			return -1;
    800018d8:	557d                	li	a0,-1
}
    800018da:	60e6                	ld	ra,88(sp)
    800018dc:	6446                	ld	s0,80(sp)
    800018de:	64a6                	ld	s1,72(sp)
    800018e0:	6906                	ld	s2,64(sp)
    800018e2:	79e2                	ld	s3,56(sp)
    800018e4:	7a42                	ld	s4,48(sp)
    800018e6:	7aa2                	ld	s5,40(sp)
    800018e8:	7b02                	ld	s6,32(sp)
    800018ea:	6be2                	ld	s7,24(sp)
    800018ec:	6c42                	ld	s8,16(sp)
    800018ee:	6ca2                	ld	s9,8(sp)
    800018f0:	6125                	addi	sp,sp,96
    800018f2:	8082                	ret
			return -1;
    800018f4:	557d                	li	a0,-1
    800018f6:	b7d5                	j	800018da <copyout+0xa2>

00000000800018f8 <copyin>:
// Return 0 on success, -1 on error.
int copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
	uint64 n, va0, pa0;

	while (len > 0)
    800018f8:	c6bd                	beqz	a3,80001966 <copyin+0x6e>
{
    800018fa:	715d                	addi	sp,sp,-80
    800018fc:	e486                	sd	ra,72(sp)
    800018fe:	e0a2                	sd	s0,64(sp)
    80001900:	fc26                	sd	s1,56(sp)
    80001902:	f84a                	sd	s2,48(sp)
    80001904:	f44e                	sd	s3,40(sp)
    80001906:	f052                	sd	s4,32(sp)
    80001908:	ec56                	sd	s5,24(sp)
    8000190a:	e85a                	sd	s6,16(sp)
    8000190c:	e45e                	sd	s7,8(sp)
    8000190e:	e062                	sd	s8,0(sp)
    80001910:	0880                	addi	s0,sp,80
    80001912:	8b2a                	mv	s6,a0
    80001914:	8a2e                	mv	s4,a1
    80001916:	8c32                	mv	s8,a2
    80001918:	89b6                	mv	s3,a3
	{
		va0 = PGROUNDDOWN(srcva);
    8000191a:	7bfd                	lui	s7,0xfffff
		pa0 = walkaddr(pagetable, va0);
		if (pa0 == 0)
			return -1;
		n = PGSIZE - (srcva - va0);
    8000191c:	6a85                	lui	s5,0x1
    8000191e:	a015                	j	80001942 <copyin+0x4a>
		if (n > len)
			n = len;
		memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001920:	9562                	add	a0,a0,s8
    80001922:	0004861b          	sext.w	a2,s1
    80001926:	412505b3          	sub	a1,a0,s2
    8000192a:	8552                	mv	a0,s4
    8000192c:	fffff097          	auipc	ra,0xfffff
    80001930:	5d8080e7          	jalr	1496(ra) # 80000f04 <memmove>

		len -= n;
    80001934:	409989b3          	sub	s3,s3,s1
		dst += n;
    80001938:	9a26                	add	s4,s4,s1
		srcva = va0 + PGSIZE;
    8000193a:	01590c33          	add	s8,s2,s5
	while (len > 0)
    8000193e:	02098263          	beqz	s3,80001962 <copyin+0x6a>
		va0 = PGROUNDDOWN(srcva);
    80001942:	017c7933          	and	s2,s8,s7
		pa0 = walkaddr(pagetable, va0);
    80001946:	85ca                	mv	a1,s2
    80001948:	855a                	mv	a0,s6
    8000194a:	00000097          	auipc	ra,0x0
    8000194e:	8ec080e7          	jalr	-1812(ra) # 80001236 <walkaddr>
		if (pa0 == 0)
    80001952:	cd01                	beqz	a0,8000196a <copyin+0x72>
		n = PGSIZE - (srcva - va0);
    80001954:	418904b3          	sub	s1,s2,s8
    80001958:	94d6                	add	s1,s1,s5
		if (n > len)
    8000195a:	fc99f3e3          	bgeu	s3,s1,80001920 <copyin+0x28>
    8000195e:	84ce                	mv	s1,s3
    80001960:	b7c1                	j	80001920 <copyin+0x28>
	}
	return 0;
    80001962:	4501                	li	a0,0
    80001964:	a021                	j	8000196c <copyin+0x74>
    80001966:	4501                	li	a0,0
}
    80001968:	8082                	ret
			return -1;
    8000196a:	557d                	li	a0,-1
}
    8000196c:	60a6                	ld	ra,72(sp)
    8000196e:	6406                	ld	s0,64(sp)
    80001970:	74e2                	ld	s1,56(sp)
    80001972:	7942                	ld	s2,48(sp)
    80001974:	79a2                	ld	s3,40(sp)
    80001976:	7a02                	ld	s4,32(sp)
    80001978:	6ae2                	ld	s5,24(sp)
    8000197a:	6b42                	ld	s6,16(sp)
    8000197c:	6ba2                	ld	s7,8(sp)
    8000197e:	6c02                	ld	s8,0(sp)
    80001980:	6161                	addi	sp,sp,80
    80001982:	8082                	ret

0000000080001984 <copyinstr>:
int copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
	uint64 n, va0, pa0;
	int got_null = 0;

	while (got_null == 0 && max > 0)
    80001984:	c6c5                	beqz	a3,80001a2c <copyinstr+0xa8>
{
    80001986:	715d                	addi	sp,sp,-80
    80001988:	e486                	sd	ra,72(sp)
    8000198a:	e0a2                	sd	s0,64(sp)
    8000198c:	fc26                	sd	s1,56(sp)
    8000198e:	f84a                	sd	s2,48(sp)
    80001990:	f44e                	sd	s3,40(sp)
    80001992:	f052                	sd	s4,32(sp)
    80001994:	ec56                	sd	s5,24(sp)
    80001996:	e85a                	sd	s6,16(sp)
    80001998:	e45e                	sd	s7,8(sp)
    8000199a:	0880                	addi	s0,sp,80
    8000199c:	8a2a                	mv	s4,a0
    8000199e:	8b2e                	mv	s6,a1
    800019a0:	8bb2                	mv	s7,a2
    800019a2:	84b6                	mv	s1,a3
	{
		va0 = PGROUNDDOWN(srcva);
    800019a4:	7afd                	lui	s5,0xfffff
		pa0 = walkaddr(pagetable, va0);
		if (pa0 == 0)
			return -1;
		n = PGSIZE - (srcva - va0);
    800019a6:	6985                	lui	s3,0x1
    800019a8:	a035                	j	800019d4 <copyinstr+0x50>
		char *p = (char *)(pa0 + (srcva - va0));
		while (n > 0)
		{
			if (*p == '\0')
			{
				*dst = '\0';
    800019aa:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800019ae:	4785                	li	a5,1
			dst++;
		}

		srcva = va0 + PGSIZE;
	}
	if (got_null)
    800019b0:	0017b793          	seqz	a5,a5
    800019b4:	40f00533          	neg	a0,a5
	}
	else
	{
		return -1;
	}
}
    800019b8:	60a6                	ld	ra,72(sp)
    800019ba:	6406                	ld	s0,64(sp)
    800019bc:	74e2                	ld	s1,56(sp)
    800019be:	7942                	ld	s2,48(sp)
    800019c0:	79a2                	ld	s3,40(sp)
    800019c2:	7a02                	ld	s4,32(sp)
    800019c4:	6ae2                	ld	s5,24(sp)
    800019c6:	6b42                	ld	s6,16(sp)
    800019c8:	6ba2                	ld	s7,8(sp)
    800019ca:	6161                	addi	sp,sp,80
    800019cc:	8082                	ret
		srcva = va0 + PGSIZE;
    800019ce:	01390bb3          	add	s7,s2,s3
	while (got_null == 0 && max > 0)
    800019d2:	c8a9                	beqz	s1,80001a24 <copyinstr+0xa0>
		va0 = PGROUNDDOWN(srcva);
    800019d4:	015bf933          	and	s2,s7,s5
		pa0 = walkaddr(pagetable, va0);
    800019d8:	85ca                	mv	a1,s2
    800019da:	8552                	mv	a0,s4
    800019dc:	00000097          	auipc	ra,0x0
    800019e0:	85a080e7          	jalr	-1958(ra) # 80001236 <walkaddr>
		if (pa0 == 0)
    800019e4:	c131                	beqz	a0,80001a28 <copyinstr+0xa4>
		n = PGSIZE - (srcva - va0);
    800019e6:	41790833          	sub	a6,s2,s7
    800019ea:	984e                	add	a6,a6,s3
		if (n > max)
    800019ec:	0104f363          	bgeu	s1,a6,800019f2 <copyinstr+0x6e>
    800019f0:	8826                	mv	a6,s1
		char *p = (char *)(pa0 + (srcva - va0));
    800019f2:	955e                	add	a0,a0,s7
    800019f4:	41250533          	sub	a0,a0,s2
		while (n > 0)
    800019f8:	fc080be3          	beqz	a6,800019ce <copyinstr+0x4a>
    800019fc:	985a                	add	a6,a6,s6
    800019fe:	87da                	mv	a5,s6
			if (*p == '\0')
    80001a00:	41650633          	sub	a2,a0,s6
    80001a04:	14fd                	addi	s1,s1,-1
    80001a06:	9b26                	add	s6,s6,s1
    80001a08:	00f60733          	add	a4,a2,a5
    80001a0c:	00074703          	lbu	a4,0(a4)
    80001a10:	df49                	beqz	a4,800019aa <copyinstr+0x26>
				*dst = *p;
    80001a12:	00e78023          	sb	a4,0(a5)
			--max;
    80001a16:	40fb04b3          	sub	s1,s6,a5
			dst++;
    80001a1a:	0785                	addi	a5,a5,1
		while (n > 0)
    80001a1c:	ff0796e3          	bne	a5,a6,80001a08 <copyinstr+0x84>
			dst++;
    80001a20:	8b42                	mv	s6,a6
    80001a22:	b775                	j	800019ce <copyinstr+0x4a>
    80001a24:	4781                	li	a5,0
    80001a26:	b769                	j	800019b0 <copyinstr+0x2c>
			return -1;
    80001a28:	557d                	li	a0,-1
    80001a2a:	b779                	j	800019b8 <copyinstr+0x34>
	int got_null = 0;
    80001a2c:	4781                	li	a5,0
	if (got_null)
    80001a2e:	0017b793          	seqz	a5,a5
    80001a32:	40f00533          	neg	a0,a5
}
    80001a36:	8082                	ret

0000000080001a38 <calculateDynamicPriority>:
Queue mlfq[5];
#endif

// #ifdef PBS
int calculateDynamicPriority(struct proc *process)
{
    80001a38:	1141                	addi	sp,sp,-16
    80001a3a:	e422                	sd	s0,8(sp)
    80001a3c:	0800                	addi	s0,sp,16
	process->niceness = 5;
    80001a3e:	4795                	li	a5,5
    80001a40:	1af52223          	sw	a5,420(a0)
	if (process->runTimePrev == 0)
    80001a44:	19452783          	lw	a5,404(a0)
    80001a48:	e791                	bnez	a5,80001a54 <calculateDynamicPriority+0x1c>
	{
		if (process->sleepTimePrev == 0)
    80001a4a:	18c52783          	lw	a5,396(a0)
    80001a4e:	e399                	bnez	a5,80001a54 <calculateDynamicPriority+0x1c>
		{
			process->niceness = process->sleepTimePrev * 10;
			process->niceness /= (process->runTimePrev + process->sleepTimePrev);
    80001a50:	1a052223          	sw	zero,420(a0)
		}
	}
	int retval = 0, checker = process->sprior - process->niceness + 5;
    80001a54:	19c52783          	lw	a5,412(a0)
    80001a58:	2795                	addiw	a5,a5,5
    80001a5a:	1a452503          	lw	a0,420(a0)
    80001a5e:	40a7853b          	subw	a0,a5,a0
	}
	else
	{
		retval = checker;
	}
	return retval;
    80001a62:	0005079b          	sext.w	a5,a0
    80001a66:	fff7c793          	not	a5,a5
    80001a6a:	97fd                	srai	a5,a5,0x3f
    80001a6c:	8d7d                	and	a0,a0,a5
    80001a6e:	0005071b          	sext.w	a4,a0
    80001a72:	06400793          	li	a5,100
    80001a76:	00e7d463          	bge	a5,a4,80001a7e <calculateDynamicPriority+0x46>
    80001a7a:	06400513          	li	a0,100
}
    80001a7e:	2501                	sext.w	a0,a0
    80001a80:	6422                	ld	s0,8(sp)
    80001a82:	0141                	addi	sp,sp,16
    80001a84:	8082                	ret

0000000080001a86 <set_priority>:
// #endif

int set_priority(int static_prior, int pid)
{
    80001a86:	7139                	addi	sp,sp,-64
    80001a88:	fc06                	sd	ra,56(sp)
    80001a8a:	f822                	sd	s0,48(sp)
    80001a8c:	f426                	sd	s1,40(sp)
    80001a8e:	f04a                	sd	s2,32(sp)
    80001a90:	ec4e                	sd	s3,24(sp)
    80001a92:	e852                	sd	s4,16(sp)
    80001a94:	e456                	sd	s5,8(sp)
    80001a96:	0080                	addi	s0,sp,64
    80001a98:	89ae                	mv	s3,a1
	int old_prior = -1, checkIfAvailable = 0;
	if (static_prior < 0 || static_prior > 100)
    80001a9a:	8aaa                	mv	s5,a0
    80001a9c:	06400793          	li	a5,100
	{
		printf("Priority is not right\n");
		return -1;
	}
	struct proc *i;
	for (i = proc; i < &proc[NPROC]; i++)
    80001aa0:	00230497          	auipc	s1,0x230
    80001aa4:	81848493          	addi	s1,s1,-2024 # 802312b8 <proc>
    80001aa8:	00237a17          	auipc	s4,0x237
    80001aac:	c10a0a13          	addi	s4,s4,-1008 # 802386b8 <tickslock>
	if (static_prior < 0 || static_prior > 100)
    80001ab0:	02a7e763          	bltu	a5,a0,80001ade <set_priority+0x58>
	{
		acquire(&i->lock);
    80001ab4:	00848913          	addi	s2,s1,8
    80001ab8:	854a                	mv	a0,s2
    80001aba:	fffff097          	auipc	ra,0xfffff
    80001abe:	2ee080e7          	jalr	750(ra) # 80000da8 <acquire>
		if (i->pid == pid)
    80001ac2:	5c9c                	lw	a5,56(s1)
    80001ac4:	03378763          	beq	a5,s3,80001af2 <set_priority+0x6c>
		{
			checkIfAvailable = 1;
			release(&i->lock);
			break;
		}
		release(&i->lock);
    80001ac8:	854a                	mv	a0,s2
    80001aca:	fffff097          	auipc	ra,0xfffff
    80001ace:	392080e7          	jalr	914(ra) # 80000e5c <release>
	for (i = proc; i < &proc[NPROC]; i++)
    80001ad2:	1d048493          	addi	s1,s1,464
    80001ad6:	fd449fe3          	bne	s1,s4,80001ab4 <set_priority+0x2e>
		i->dprior = calculateDynamicPriority(i);
		release(&i->lock);
	}
	else
	{
		return -1;
    80001ada:	59fd                	li	s3,-1
    80001adc:	a881                	j	80001b2c <set_priority+0xa6>
		printf("Priority is not right\n");
    80001ade:	00006517          	auipc	a0,0x6
    80001ae2:	72a50513          	addi	a0,a0,1834 # 80008208 <digits+0x1c8>
    80001ae6:	fffff097          	auipc	ra,0xfffff
    80001aea:	aa8080e7          	jalr	-1368(ra) # 8000058e <printf>
		return -1;
    80001aee:	59fd                	li	s3,-1
    80001af0:	a835                	j	80001b2c <set_priority+0xa6>
			release(&i->lock);
    80001af2:	854a                	mv	a0,s2
    80001af4:	fffff097          	auipc	ra,0xfffff
    80001af8:	368080e7          	jalr	872(ra) # 80000e5c <release>
		acquire(&i->lock);
    80001afc:	854a                	mv	a0,s2
    80001afe:	fffff097          	auipc	ra,0xfffff
    80001b02:	2aa080e7          	jalr	682(ra) # 80000da8 <acquire>
		old_prior = i->sprior;
    80001b06:	19c4a983          	lw	s3,412(s1)
		i->sprior = static_prior;
    80001b0a:	1954ae23          	sw	s5,412(s1)
		i->niceness = 5;
    80001b0e:	4795                	li	a5,5
    80001b10:	1af4a223          	sw	a5,420(s1)
		i->dprior = calculateDynamicPriority(i);
    80001b14:	8526                	mv	a0,s1
    80001b16:	00000097          	auipc	ra,0x0
    80001b1a:	f22080e7          	jalr	-222(ra) # 80001a38 <calculateDynamicPriority>
    80001b1e:	1aa4a023          	sw	a0,416(s1)
		release(&i->lock);
    80001b22:	854a                	mv	a0,s2
    80001b24:	fffff097          	auipc	ra,0xfffff
    80001b28:	338080e7          	jalr	824(ra) # 80000e5c <release>
	}
	return old_prior;
}
    80001b2c:	854e                	mv	a0,s3
    80001b2e:	70e2                	ld	ra,56(sp)
    80001b30:	7442                	ld	s0,48(sp)
    80001b32:	74a2                	ld	s1,40(sp)
    80001b34:	7902                	ld	s2,32(sp)
    80001b36:	69e2                	ld	s3,24(sp)
    80001b38:	6a42                	ld	s4,16(sp)
    80001b3a:	6aa2                	ld	s5,8(sp)
    80001b3c:	6121                	addi	sp,sp,64
    80001b3e:	8082                	ret

0000000080001b40 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    80001b40:	7139                	addi	sp,sp,-64
    80001b42:	fc06                	sd	ra,56(sp)
    80001b44:	f822                	sd	s0,48(sp)
    80001b46:	f426                	sd	s1,40(sp)
    80001b48:	f04a                	sd	s2,32(sp)
    80001b4a:	ec4e                	sd	s3,24(sp)
    80001b4c:	e852                	sd	s4,16(sp)
    80001b4e:	e456                	sd	s5,8(sp)
    80001b50:	e05a                	sd	s6,0(sp)
    80001b52:	0080                	addi	s0,sp,64
    80001b54:	89aa                	mv	s3,a0
	struct proc *p;

	for (p = proc; p < &proc[NPROC]; p++)
    80001b56:	0022f497          	auipc	s1,0x22f
    80001b5a:	76248493          	addi	s1,s1,1890 # 802312b8 <proc>
	{
		char *pa = kalloc();
		if (pa == 0)
			panic("kalloc");
		uint64 va = KSTACK((int)(p - proc));
    80001b5e:	8b26                	mv	s6,s1
    80001b60:	00006a97          	auipc	s5,0x6
    80001b64:	4a0a8a93          	addi	s5,s5,1184 # 80008000 <etext>
    80001b68:	04000937          	lui	s2,0x4000
    80001b6c:	197d                	addi	s2,s2,-1
    80001b6e:	0932                	slli	s2,s2,0xc
	for (p = proc; p < &proc[NPROC]; p++)
    80001b70:	00237a17          	auipc	s4,0x237
    80001b74:	b48a0a13          	addi	s4,s4,-1208 # 802386b8 <tickslock>
		char *pa = kalloc();
    80001b78:	fffff097          	auipc	ra,0xfffff
    80001b7c:	0fc080e7          	jalr	252(ra) # 80000c74 <kalloc>
    80001b80:	862a                	mv	a2,a0
		if (pa == 0)
    80001b82:	c131                	beqz	a0,80001bc6 <proc_mapstacks+0x86>
		uint64 va = KSTACK((int)(p - proc));
    80001b84:	416485b3          	sub	a1,s1,s6
    80001b88:	8591                	srai	a1,a1,0x4
    80001b8a:	000ab783          	ld	a5,0(s5)
    80001b8e:	02f585b3          	mul	a1,a1,a5
    80001b92:	2585                	addiw	a1,a1,1
    80001b94:	00d5959b          	slliw	a1,a1,0xd
		kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001b98:	4719                	li	a4,6
    80001b9a:	6685                	lui	a3,0x1
    80001b9c:	40b905b3          	sub	a1,s2,a1
    80001ba0:	854e                	mv	a0,s3
    80001ba2:	fffff097          	auipc	ra,0xfffff
    80001ba6:	776080e7          	jalr	1910(ra) # 80001318 <kvmmap>
	for (p = proc; p < &proc[NPROC]; p++)
    80001baa:	1d048493          	addi	s1,s1,464
    80001bae:	fd4495e3          	bne	s1,s4,80001b78 <proc_mapstacks+0x38>
	}
}
    80001bb2:	70e2                	ld	ra,56(sp)
    80001bb4:	7442                	ld	s0,48(sp)
    80001bb6:	74a2                	ld	s1,40(sp)
    80001bb8:	7902                	ld	s2,32(sp)
    80001bba:	69e2                	ld	s3,24(sp)
    80001bbc:	6a42                	ld	s4,16(sp)
    80001bbe:	6aa2                	ld	s5,8(sp)
    80001bc0:	6b02                	ld	s6,0(sp)
    80001bc2:	6121                	addi	sp,sp,64
    80001bc4:	8082                	ret
			panic("kalloc");
    80001bc6:	00006517          	auipc	a0,0x6
    80001bca:	65a50513          	addi	a0,a0,1626 # 80008220 <digits+0x1e0>
    80001bce:	fffff097          	auipc	ra,0xfffff
    80001bd2:	976080e7          	jalr	-1674(ra) # 80000544 <panic>

0000000080001bd6 <procinit>:

// initialize the proc table.
void procinit(void)
{
    80001bd6:	7139                	addi	sp,sp,-64
    80001bd8:	fc06                	sd	ra,56(sp)
    80001bda:	f822                	sd	s0,48(sp)
    80001bdc:	f426                	sd	s1,40(sp)
    80001bde:	f04a                	sd	s2,32(sp)
    80001be0:	ec4e                	sd	s3,24(sp)
    80001be2:	e852                	sd	s4,16(sp)
    80001be4:	e456                	sd	s5,8(sp)
    80001be6:	e05a                	sd	s6,0(sp)
    80001be8:	0080                	addi	s0,sp,64
	struct proc *p;

	initlock(&pid_lock, "nextpid");
    80001bea:	00006597          	auipc	a1,0x6
    80001bee:	63e58593          	addi	a1,a1,1598 # 80008228 <digits+0x1e8>
    80001bf2:	0022f517          	auipc	a0,0x22f
    80001bf6:	29650513          	addi	a0,a0,662 # 80230e88 <pid_lock>
    80001bfa:	fffff097          	auipc	ra,0xfffff
    80001bfe:	11e080e7          	jalr	286(ra) # 80000d18 <initlock>
	initlock(&wait_lock, "wait_lock");
    80001c02:	00006597          	auipc	a1,0x6
    80001c06:	62e58593          	addi	a1,a1,1582 # 80008230 <digits+0x1f0>
    80001c0a:	0022f517          	auipc	a0,0x22f
    80001c0e:	29650513          	addi	a0,a0,662 # 80230ea0 <wait_lock>
    80001c12:	fffff097          	auipc	ra,0xfffff
    80001c16:	106080e7          	jalr	262(ra) # 80000d18 <initlock>
	for (p = proc; p < &proc[NPROC]; p++)
    80001c1a:	0022f497          	auipc	s1,0x22f
    80001c1e:	69e48493          	addi	s1,s1,1694 # 802312b8 <proc>
	{
		initlock(&p->lock, "proc");
    80001c22:	00006b17          	auipc	s6,0x6
    80001c26:	61eb0b13          	addi	s6,s6,1566 # 80008240 <digits+0x200>
		p->state = UNUSED;
		p->kstack = KSTACK((int)(p - proc));
    80001c2a:	8aa6                	mv	s5,s1
    80001c2c:	00006a17          	auipc	s4,0x6
    80001c30:	3d4a0a13          	addi	s4,s4,980 # 80008000 <etext>
    80001c34:	04000937          	lui	s2,0x4000
    80001c38:	197d                	addi	s2,s2,-1
    80001c3a:	0932                	slli	s2,s2,0xc
	for (p = proc; p < &proc[NPROC]; p++)
    80001c3c:	00237997          	auipc	s3,0x237
    80001c40:	a7c98993          	addi	s3,s3,-1412 # 802386b8 <tickslock>
		initlock(&p->lock, "proc");
    80001c44:	85da                	mv	a1,s6
    80001c46:	00848513          	addi	a0,s1,8
    80001c4a:	fffff097          	auipc	ra,0xfffff
    80001c4e:	0ce080e7          	jalr	206(ra) # 80000d18 <initlock>
		p->state = UNUSED;
    80001c52:	0204a023          	sw	zero,32(s1)
		p->kstack = KSTACK((int)(p - proc));
    80001c56:	415487b3          	sub	a5,s1,s5
    80001c5a:	8791                	srai	a5,a5,0x4
    80001c5c:	000a3703          	ld	a4,0(s4)
    80001c60:	02e787b3          	mul	a5,a5,a4
    80001c64:	2785                	addiw	a5,a5,1
    80001c66:	00d7979b          	slliw	a5,a5,0xd
    80001c6a:	40f907b3          	sub	a5,s2,a5
    80001c6e:	e4bc                	sd	a5,72(s1)
	for (p = proc; p < &proc[NPROC]; p++)
    80001c70:	1d048493          	addi	s1,s1,464
    80001c74:	fd3498e3          	bne	s1,s3,80001c44 <procinit+0x6e>
	}
}
    80001c78:	70e2                	ld	ra,56(sp)
    80001c7a:	7442                	ld	s0,48(sp)
    80001c7c:	74a2                	ld	s1,40(sp)
    80001c7e:	7902                	ld	s2,32(sp)
    80001c80:	69e2                	ld	s3,24(sp)
    80001c82:	6a42                	ld	s4,16(sp)
    80001c84:	6aa2                	ld	s5,8(sp)
    80001c86:	6b02                	ld	s6,0(sp)
    80001c88:	6121                	addi	sp,sp,64
    80001c8a:	8082                	ret

0000000080001c8c <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    80001c8c:	1141                	addi	sp,sp,-16
    80001c8e:	e422                	sd	s0,8(sp)
    80001c90:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001c92:	8512                	mv	a0,tp
	int id = r_tp();
	return id;
}
    80001c94:	2501                	sext.w	a0,a0
    80001c96:	6422                	ld	s0,8(sp)
    80001c98:	0141                	addi	sp,sp,16
    80001c9a:	8082                	ret

0000000080001c9c <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001c9c:	1141                	addi	sp,sp,-16
    80001c9e:	e422                	sd	s0,8(sp)
    80001ca0:	0800                	addi	s0,sp,16
    80001ca2:	8792                	mv	a5,tp
	int id = cpuid();
	struct cpu *c = &cpus[id];
    80001ca4:	2781                	sext.w	a5,a5
    80001ca6:	079e                	slli	a5,a5,0x7
	return c;
}
    80001ca8:	0022f517          	auipc	a0,0x22f
    80001cac:	21050513          	addi	a0,a0,528 # 80230eb8 <cpus>
    80001cb0:	953e                	add	a0,a0,a5
    80001cb2:	6422                	ld	s0,8(sp)
    80001cb4:	0141                	addi	sp,sp,16
    80001cb6:	8082                	ret

0000000080001cb8 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001cb8:	1101                	addi	sp,sp,-32
    80001cba:	ec06                	sd	ra,24(sp)
    80001cbc:	e822                	sd	s0,16(sp)
    80001cbe:	e426                	sd	s1,8(sp)
    80001cc0:	1000                	addi	s0,sp,32
	push_off();
    80001cc2:	fffff097          	auipc	ra,0xfffff
    80001cc6:	09a080e7          	jalr	154(ra) # 80000d5c <push_off>
    80001cca:	8792                	mv	a5,tp
	struct cpu *c = mycpu();
	struct proc *p = c->proc;
    80001ccc:	2781                	sext.w	a5,a5
    80001cce:	079e                	slli	a5,a5,0x7
    80001cd0:	0022f717          	auipc	a4,0x22f
    80001cd4:	1b870713          	addi	a4,a4,440 # 80230e88 <pid_lock>
    80001cd8:	97ba                	add	a5,a5,a4
    80001cda:	7b84                	ld	s1,48(a5)
	pop_off();
    80001cdc:	fffff097          	auipc	ra,0xfffff
    80001ce0:	120080e7          	jalr	288(ra) # 80000dfc <pop_off>
	return p;
}
    80001ce4:	8526                	mv	a0,s1
    80001ce6:	60e2                	ld	ra,24(sp)
    80001ce8:	6442                	ld	s0,16(sp)
    80001cea:	64a2                	ld	s1,8(sp)
    80001cec:	6105                	addi	sp,sp,32
    80001cee:	8082                	ret

0000000080001cf0 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001cf0:	1141                	addi	sp,sp,-16
    80001cf2:	e406                	sd	ra,8(sp)
    80001cf4:	e022                	sd	s0,0(sp)
    80001cf6:	0800                	addi	s0,sp,16
	static int first = 1;

	// Still holding p->lock from scheduler.
	release(&myproc()->lock);
    80001cf8:	00000097          	auipc	ra,0x0
    80001cfc:	fc0080e7          	jalr	-64(ra) # 80001cb8 <myproc>
    80001d00:	0521                	addi	a0,a0,8
    80001d02:	fffff097          	auipc	ra,0xfffff
    80001d06:	15a080e7          	jalr	346(ra) # 80000e5c <release>

	if (first)
    80001d0a:	00007797          	auipc	a5,0x7
    80001d0e:	cb67a783          	lw	a5,-842(a5) # 800089c0 <first.2458>
    80001d12:	eb89                	bnez	a5,80001d24 <forkret+0x34>
		// be run from main().
		first = 0;
		fsinit(ROOTDEV);
	}

	usertrapret();
    80001d14:	00001097          	auipc	ra,0x1
    80001d18:	f8e080e7          	jalr	-114(ra) # 80002ca2 <usertrapret>
}
    80001d1c:	60a2                	ld	ra,8(sp)
    80001d1e:	6402                	ld	s0,0(sp)
    80001d20:	0141                	addi	sp,sp,16
    80001d22:	8082                	ret
		first = 0;
    80001d24:	00007797          	auipc	a5,0x7
    80001d28:	c807ae23          	sw	zero,-868(a5) # 800089c0 <first.2458>
		fsinit(ROOTDEV);
    80001d2c:	4505                	li	a0,1
    80001d2e:	00002097          	auipc	ra,0x2
    80001d32:	faa080e7          	jalr	-86(ra) # 80003cd8 <fsinit>
    80001d36:	bff9                	j	80001d14 <forkret+0x24>

0000000080001d38 <allocpid>:
{
    80001d38:	1101                	addi	sp,sp,-32
    80001d3a:	ec06                	sd	ra,24(sp)
    80001d3c:	e822                	sd	s0,16(sp)
    80001d3e:	e426                	sd	s1,8(sp)
    80001d40:	e04a                	sd	s2,0(sp)
    80001d42:	1000                	addi	s0,sp,32
	acquire(&pid_lock);
    80001d44:	0022f917          	auipc	s2,0x22f
    80001d48:	14490913          	addi	s2,s2,324 # 80230e88 <pid_lock>
    80001d4c:	854a                	mv	a0,s2
    80001d4e:	fffff097          	auipc	ra,0xfffff
    80001d52:	05a080e7          	jalr	90(ra) # 80000da8 <acquire>
	pid = nextpid;
    80001d56:	00007797          	auipc	a5,0x7
    80001d5a:	c6e78793          	addi	a5,a5,-914 # 800089c4 <nextpid>
    80001d5e:	4384                	lw	s1,0(a5)
	nextpid = nextpid + 1;
    80001d60:	0014871b          	addiw	a4,s1,1
    80001d64:	c398                	sw	a4,0(a5)
	release(&pid_lock);
    80001d66:	854a                	mv	a0,s2
    80001d68:	fffff097          	auipc	ra,0xfffff
    80001d6c:	0f4080e7          	jalr	244(ra) # 80000e5c <release>
}
    80001d70:	8526                	mv	a0,s1
    80001d72:	60e2                	ld	ra,24(sp)
    80001d74:	6442                	ld	s0,16(sp)
    80001d76:	64a2                	ld	s1,8(sp)
    80001d78:	6902                	ld	s2,0(sp)
    80001d7a:	6105                	addi	sp,sp,32
    80001d7c:	8082                	ret

0000000080001d7e <proc_pagetable>:
{
    80001d7e:	1101                	addi	sp,sp,-32
    80001d80:	ec06                	sd	ra,24(sp)
    80001d82:	e822                	sd	s0,16(sp)
    80001d84:	e426                	sd	s1,8(sp)
    80001d86:	e04a                	sd	s2,0(sp)
    80001d88:	1000                	addi	s0,sp,32
    80001d8a:	892a                	mv	s2,a0
	pagetable = uvmcreate();
    80001d8c:	fffff097          	auipc	ra,0xfffff
    80001d90:	776080e7          	jalr	1910(ra) # 80001502 <uvmcreate>
    80001d94:	84aa                	mv	s1,a0
	if (pagetable == 0)
    80001d96:	c121                	beqz	a0,80001dd6 <proc_pagetable+0x58>
	if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001d98:	4729                	li	a4,10
    80001d9a:	00005697          	auipc	a3,0x5
    80001d9e:	26668693          	addi	a3,a3,614 # 80007000 <_trampoline>
    80001da2:	6605                	lui	a2,0x1
    80001da4:	040005b7          	lui	a1,0x4000
    80001da8:	15fd                	addi	a1,a1,-1
    80001daa:	05b2                	slli	a1,a1,0xc
    80001dac:	fffff097          	auipc	ra,0xfffff
    80001db0:	4cc080e7          	jalr	1228(ra) # 80001278 <mappages>
    80001db4:	02054863          	bltz	a0,80001de4 <proc_pagetable+0x66>
	if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001db8:	4719                	li	a4,6
    80001dba:	06093683          	ld	a3,96(s2)
    80001dbe:	6605                	lui	a2,0x1
    80001dc0:	020005b7          	lui	a1,0x2000
    80001dc4:	15fd                	addi	a1,a1,-1
    80001dc6:	05b6                	slli	a1,a1,0xd
    80001dc8:	8526                	mv	a0,s1
    80001dca:	fffff097          	auipc	ra,0xfffff
    80001dce:	4ae080e7          	jalr	1198(ra) # 80001278 <mappages>
    80001dd2:	02054163          	bltz	a0,80001df4 <proc_pagetable+0x76>
}
    80001dd6:	8526                	mv	a0,s1
    80001dd8:	60e2                	ld	ra,24(sp)
    80001dda:	6442                	ld	s0,16(sp)
    80001ddc:	64a2                	ld	s1,8(sp)
    80001dde:	6902                	ld	s2,0(sp)
    80001de0:	6105                	addi	sp,sp,32
    80001de2:	8082                	ret
		uvmfree(pagetable, 0);
    80001de4:	4581                	li	a1,0
    80001de6:	8526                	mv	a0,s1
    80001de8:	00000097          	auipc	ra,0x0
    80001dec:	91e080e7          	jalr	-1762(ra) # 80001706 <uvmfree>
		return 0;
    80001df0:	4481                	li	s1,0
    80001df2:	b7d5                	j	80001dd6 <proc_pagetable+0x58>
		uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001df4:	4681                	li	a3,0
    80001df6:	4605                	li	a2,1
    80001df8:	040005b7          	lui	a1,0x4000
    80001dfc:	15fd                	addi	a1,a1,-1
    80001dfe:	05b2                	slli	a1,a1,0xc
    80001e00:	8526                	mv	a0,s1
    80001e02:	fffff097          	auipc	ra,0xfffff
    80001e06:	63c080e7          	jalr	1596(ra) # 8000143e <uvmunmap>
		uvmfree(pagetable, 0);
    80001e0a:	4581                	li	a1,0
    80001e0c:	8526                	mv	a0,s1
    80001e0e:	00000097          	auipc	ra,0x0
    80001e12:	8f8080e7          	jalr	-1800(ra) # 80001706 <uvmfree>
		return 0;
    80001e16:	4481                	li	s1,0
    80001e18:	bf7d                	j	80001dd6 <proc_pagetable+0x58>

0000000080001e1a <proc_freepagetable>:
{
    80001e1a:	1101                	addi	sp,sp,-32
    80001e1c:	ec06                	sd	ra,24(sp)
    80001e1e:	e822                	sd	s0,16(sp)
    80001e20:	e426                	sd	s1,8(sp)
    80001e22:	e04a                	sd	s2,0(sp)
    80001e24:	1000                	addi	s0,sp,32
    80001e26:	84aa                	mv	s1,a0
    80001e28:	892e                	mv	s2,a1
	uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001e2a:	4681                	li	a3,0
    80001e2c:	4605                	li	a2,1
    80001e2e:	040005b7          	lui	a1,0x4000
    80001e32:	15fd                	addi	a1,a1,-1
    80001e34:	05b2                	slli	a1,a1,0xc
    80001e36:	fffff097          	auipc	ra,0xfffff
    80001e3a:	608080e7          	jalr	1544(ra) # 8000143e <uvmunmap>
	uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001e3e:	4681                	li	a3,0
    80001e40:	4605                	li	a2,1
    80001e42:	020005b7          	lui	a1,0x2000
    80001e46:	15fd                	addi	a1,a1,-1
    80001e48:	05b6                	slli	a1,a1,0xd
    80001e4a:	8526                	mv	a0,s1
    80001e4c:	fffff097          	auipc	ra,0xfffff
    80001e50:	5f2080e7          	jalr	1522(ra) # 8000143e <uvmunmap>
	uvmfree(pagetable, sz);
    80001e54:	85ca                	mv	a1,s2
    80001e56:	8526                	mv	a0,s1
    80001e58:	00000097          	auipc	ra,0x0
    80001e5c:	8ae080e7          	jalr	-1874(ra) # 80001706 <uvmfree>
}
    80001e60:	60e2                	ld	ra,24(sp)
    80001e62:	6442                	ld	s0,16(sp)
    80001e64:	64a2                	ld	s1,8(sp)
    80001e66:	6902                	ld	s2,0(sp)
    80001e68:	6105                	addi	sp,sp,32
    80001e6a:	8082                	ret

0000000080001e6c <freeproc>:
{
    80001e6c:	1101                	addi	sp,sp,-32
    80001e6e:	ec06                	sd	ra,24(sp)
    80001e70:	e822                	sd	s0,16(sp)
    80001e72:	e426                	sd	s1,8(sp)
    80001e74:	1000                	addi	s0,sp,32
    80001e76:	84aa                	mv	s1,a0
	if (p->trapframe)
    80001e78:	7128                	ld	a0,96(a0)
    80001e7a:	c509                	beqz	a0,80001e84 <freeproc+0x18>
		kfree((void *)p->trapframe);
    80001e7c:	fffff097          	auipc	ra,0xfffff
    80001e80:	c52080e7          	jalr	-942(ra) # 80000ace <kfree>
	p->trapframe = 0;
    80001e84:	0604b023          	sd	zero,96(s1)
	if (p->pagetable)
    80001e88:	6ca8                	ld	a0,88(s1)
    80001e8a:	c511                	beqz	a0,80001e96 <freeproc+0x2a>
		proc_freepagetable(p->pagetable, p->sz);
    80001e8c:	68ac                	ld	a1,80(s1)
    80001e8e:	00000097          	auipc	ra,0x0
    80001e92:	f8c080e7          	jalr	-116(ra) # 80001e1a <proc_freepagetable>
	p->pagetable = 0;
    80001e96:	0404bc23          	sd	zero,88(s1)
	p->sz = 0;
    80001e9a:	0404b823          	sd	zero,80(s1)
	p->pid = 0;
    80001e9e:	0204ac23          	sw	zero,56(s1)
	p->parent = 0;
    80001ea2:	0404b023          	sd	zero,64(s1)
	p->name[0] = 0;
    80001ea6:	16048023          	sb	zero,352(s1)
	p->chan = 0;
    80001eaa:	0204b423          	sd	zero,40(s1)
	p->killed = 0;
    80001eae:	0204a823          	sw	zero,48(s1)
	p->xstate = 0;
    80001eb2:	0204aa23          	sw	zero,52(s1)
	p->state = UNUSED;
    80001eb6:	0204a023          	sw	zero,32(s1)
}
    80001eba:	60e2                	ld	ra,24(sp)
    80001ebc:	6442                	ld	s0,16(sp)
    80001ebe:	64a2                	ld	s1,8(sp)
    80001ec0:	6105                	addi	sp,sp,32
    80001ec2:	8082                	ret

0000000080001ec4 <allocproc>:
{
    80001ec4:	7179                	addi	sp,sp,-48
    80001ec6:	f406                	sd	ra,40(sp)
    80001ec8:	f022                	sd	s0,32(sp)
    80001eca:	ec26                	sd	s1,24(sp)
    80001ecc:	e84a                	sd	s2,16(sp)
    80001ece:	e44e                	sd	s3,8(sp)
    80001ed0:	1800                	addi	s0,sp,48
	for (p = proc; p < &proc[NPROC]; p++)
    80001ed2:	0022f497          	auipc	s1,0x22f
    80001ed6:	3e648493          	addi	s1,s1,998 # 802312b8 <proc>
    80001eda:	00236997          	auipc	s3,0x236
    80001ede:	7de98993          	addi	s3,s3,2014 # 802386b8 <tickslock>
		acquire(&p->lock);
    80001ee2:	00848913          	addi	s2,s1,8
    80001ee6:	854a                	mv	a0,s2
    80001ee8:	fffff097          	auipc	ra,0xfffff
    80001eec:	ec0080e7          	jalr	-320(ra) # 80000da8 <acquire>
		if (p->state == UNUSED)
    80001ef0:	509c                	lw	a5,32(s1)
    80001ef2:	cf81                	beqz	a5,80001f0a <allocproc+0x46>
			release(&p->lock);
    80001ef4:	854a                	mv	a0,s2
    80001ef6:	fffff097          	auipc	ra,0xfffff
    80001efa:	f66080e7          	jalr	-154(ra) # 80000e5c <release>
	for (p = proc; p < &proc[NPROC]; p++)
    80001efe:	1d048493          	addi	s1,s1,464
    80001f02:	ff3490e3          	bne	s1,s3,80001ee2 <allocproc+0x1e>
	return 0;
    80001f06:	4481                	li	s1,0
    80001f08:	a041                	j	80001f88 <allocproc+0xc4>
	p->pid = allocpid();
    80001f0a:	00000097          	auipc	ra,0x0
    80001f0e:	e2e080e7          	jalr	-466(ra) # 80001d38 <allocpid>
    80001f12:	dc88                	sw	a0,56(s1)
	p->state = USED;
    80001f14:	4785                	li	a5,1
    80001f16:	d09c                	sw	a5,32(s1)
	if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001f18:	fffff097          	auipc	ra,0xfffff
    80001f1c:	d5c080e7          	jalr	-676(ra) # 80000c74 <kalloc>
    80001f20:	89aa                	mv	s3,a0
    80001f22:	f0a8                	sd	a0,96(s1)
    80001f24:	c935                	beqz	a0,80001f98 <allocproc+0xd4>
	p->pagetable = proc_pagetable(p);
    80001f26:	8526                	mv	a0,s1
    80001f28:	00000097          	auipc	ra,0x0
    80001f2c:	e56080e7          	jalr	-426(ra) # 80001d7e <proc_pagetable>
    80001f30:	89aa                	mv	s3,a0
    80001f32:	eca8                	sd	a0,88(s1)
	if (p->pagetable == 0)
    80001f34:	cd35                	beqz	a0,80001fb0 <allocproc+0xec>
	memset(&p->context, 0, sizeof(p->context));
    80001f36:	07000613          	li	a2,112
    80001f3a:	4581                	li	a1,0
    80001f3c:	06848513          	addi	a0,s1,104
    80001f40:	fffff097          	auipc	ra,0xfffff
    80001f44:	f64080e7          	jalr	-156(ra) # 80000ea4 <memset>
	p->context.ra = (uint64)forkret;
    80001f48:	00000797          	auipc	a5,0x0
    80001f4c:	da878793          	addi	a5,a5,-600 # 80001cf0 <forkret>
    80001f50:	f4bc                	sd	a5,104(s1)
	p->context.sp = p->kstack + PGSIZE;
    80001f52:	64bc                	ld	a5,72(s1)
    80001f54:	6705                	lui	a4,0x1
    80001f56:	97ba                	add	a5,a5,a4
    80001f58:	f8bc                	sd	a5,112(s1)
	p->creationTime = ticks;
    80001f5a:	00007797          	auipc	a5,0x7
    80001f5e:	ca67a783          	lw	a5,-858(a5) # 80008c00 <ticks>
    80001f62:	16f4ae23          	sw	a5,380(s1)
	p->sprior = 60;
    80001f66:	03c00793          	li	a5,60
    80001f6a:	18f4ae23          	sw	a5,412(s1)
	p->niceness = 5;
    80001f6e:	4795                	li	a5,5
    80001f70:	1af4a223          	sw	a5,420(s1)
	p->runTime = 0;
    80001f74:	1804a023          	sw	zero,384(s1)
	p->endTime = 0;
    80001f78:	1804a223          	sw	zero,388(s1)
	p->runTimePrev = 0;
    80001f7c:	1804aa23          	sw	zero,404(s1)
	p->sleepTimePrev = 0;
    80001f80:	1804a623          	sw	zero,396(s1)
	p->sleepStartTime = 0;
    80001f84:	1804a823          	sw	zero,400(s1)
}
    80001f88:	8526                	mv	a0,s1
    80001f8a:	70a2                	ld	ra,40(sp)
    80001f8c:	7402                	ld	s0,32(sp)
    80001f8e:	64e2                	ld	s1,24(sp)
    80001f90:	6942                	ld	s2,16(sp)
    80001f92:	69a2                	ld	s3,8(sp)
    80001f94:	6145                	addi	sp,sp,48
    80001f96:	8082                	ret
		freeproc(p);
    80001f98:	8526                	mv	a0,s1
    80001f9a:	00000097          	auipc	ra,0x0
    80001f9e:	ed2080e7          	jalr	-302(ra) # 80001e6c <freeproc>
		release(&p->lock);
    80001fa2:	854a                	mv	a0,s2
    80001fa4:	fffff097          	auipc	ra,0xfffff
    80001fa8:	eb8080e7          	jalr	-328(ra) # 80000e5c <release>
		return 0;
    80001fac:	84ce                	mv	s1,s3
    80001fae:	bfe9                	j	80001f88 <allocproc+0xc4>
		freeproc(p);
    80001fb0:	8526                	mv	a0,s1
    80001fb2:	00000097          	auipc	ra,0x0
    80001fb6:	eba080e7          	jalr	-326(ra) # 80001e6c <freeproc>
		release(&p->lock);
    80001fba:	854a                	mv	a0,s2
    80001fbc:	fffff097          	auipc	ra,0xfffff
    80001fc0:	ea0080e7          	jalr	-352(ra) # 80000e5c <release>
		return 0;
    80001fc4:	84ce                	mv	s1,s3
    80001fc6:	b7c9                	j	80001f88 <allocproc+0xc4>

0000000080001fc8 <userinit>:
{
    80001fc8:	1101                	addi	sp,sp,-32
    80001fca:	ec06                	sd	ra,24(sp)
    80001fcc:	e822                	sd	s0,16(sp)
    80001fce:	e426                	sd	s1,8(sp)
    80001fd0:	1000                	addi	s0,sp,32
	p = allocproc();
    80001fd2:	00000097          	auipc	ra,0x0
    80001fd6:	ef2080e7          	jalr	-270(ra) # 80001ec4 <allocproc>
    80001fda:	84aa                	mv	s1,a0
	initproc = p;
    80001fdc:	00007797          	auipc	a5,0x7
    80001fe0:	c0a7be23          	sd	a0,-996(a5) # 80008bf8 <initproc>
	uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001fe4:	03400613          	li	a2,52
    80001fe8:	00007597          	auipc	a1,0x7
    80001fec:	9e858593          	addi	a1,a1,-1560 # 800089d0 <initcode>
    80001ff0:	6d28                	ld	a0,88(a0)
    80001ff2:	fffff097          	auipc	ra,0xfffff
    80001ff6:	53e080e7          	jalr	1342(ra) # 80001530 <uvmfirst>
	p->sz = PGSIZE;
    80001ffa:	6785                	lui	a5,0x1
    80001ffc:	e8bc                	sd	a5,80(s1)
	p->trapframe->epc = 0;	   // user program counter
    80001ffe:	70b8                	ld	a4,96(s1)
    80002000:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
	p->trapframe->sp = PGSIZE; // user stack pointer
    80002004:	70b8                	ld	a4,96(s1)
    80002006:	fb1c                	sd	a5,48(a4)
	safestrcpy(p->name, "initcode", sizeof(p->name));
    80002008:	4641                	li	a2,16
    8000200a:	00006597          	auipc	a1,0x6
    8000200e:	23e58593          	addi	a1,a1,574 # 80008248 <digits+0x208>
    80002012:	16048513          	addi	a0,s1,352
    80002016:	fffff097          	auipc	ra,0xfffff
    8000201a:	fe0080e7          	jalr	-32(ra) # 80000ff6 <safestrcpy>
	p->cwd = namei("/");
    8000201e:	00006517          	auipc	a0,0x6
    80002022:	23a50513          	addi	a0,a0,570 # 80008258 <digits+0x218>
    80002026:	00002097          	auipc	ra,0x2
    8000202a:	6d4080e7          	jalr	1748(ra) # 800046fa <namei>
    8000202e:	14a4bc23          	sd	a0,344(s1)
	p->state = RUNNABLE;
    80002032:	478d                	li	a5,3
    80002034:	d09c                	sw	a5,32(s1)
	release(&p->lock);
    80002036:	00848513          	addi	a0,s1,8
    8000203a:	fffff097          	auipc	ra,0xfffff
    8000203e:	e22080e7          	jalr	-478(ra) # 80000e5c <release>
}
    80002042:	60e2                	ld	ra,24(sp)
    80002044:	6442                	ld	s0,16(sp)
    80002046:	64a2                	ld	s1,8(sp)
    80002048:	6105                	addi	sp,sp,32
    8000204a:	8082                	ret

000000008000204c <growproc>:
{
    8000204c:	1101                	addi	sp,sp,-32
    8000204e:	ec06                	sd	ra,24(sp)
    80002050:	e822                	sd	s0,16(sp)
    80002052:	e426                	sd	s1,8(sp)
    80002054:	e04a                	sd	s2,0(sp)
    80002056:	1000                	addi	s0,sp,32
    80002058:	892a                	mv	s2,a0
	struct proc *p = myproc();
    8000205a:	00000097          	auipc	ra,0x0
    8000205e:	c5e080e7          	jalr	-930(ra) # 80001cb8 <myproc>
    80002062:	84aa                	mv	s1,a0
	sz = p->sz;
    80002064:	692c                	ld	a1,80(a0)
	if (n > 0)
    80002066:	01204c63          	bgtz	s2,8000207e <growproc+0x32>
	else if (n < 0)
    8000206a:	02094663          	bltz	s2,80002096 <growproc+0x4a>
	p->sz = sz;
    8000206e:	e8ac                	sd	a1,80(s1)
	return 0;
    80002070:	4501                	li	a0,0
}
    80002072:	60e2                	ld	ra,24(sp)
    80002074:	6442                	ld	s0,16(sp)
    80002076:	64a2                	ld	s1,8(sp)
    80002078:	6902                	ld	s2,0(sp)
    8000207a:	6105                	addi	sp,sp,32
    8000207c:	8082                	ret
		if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    8000207e:	4691                	li	a3,4
    80002080:	00b90633          	add	a2,s2,a1
    80002084:	6d28                	ld	a0,88(a0)
    80002086:	fffff097          	auipc	ra,0xfffff
    8000208a:	564080e7          	jalr	1380(ra) # 800015ea <uvmalloc>
    8000208e:	85aa                	mv	a1,a0
    80002090:	fd79                	bnez	a0,8000206e <growproc+0x22>
			return -1;
    80002092:	557d                	li	a0,-1
    80002094:	bff9                	j	80002072 <growproc+0x26>
		sz = uvmdealloc(p->pagetable, sz, sz + n);
    80002096:	00b90633          	add	a2,s2,a1
    8000209a:	6d28                	ld	a0,88(a0)
    8000209c:	fffff097          	auipc	ra,0xfffff
    800020a0:	506080e7          	jalr	1286(ra) # 800015a2 <uvmdealloc>
    800020a4:	85aa                	mv	a1,a0
    800020a6:	b7e1                	j	8000206e <growproc+0x22>

00000000800020a8 <fork>:
{
    800020a8:	7139                	addi	sp,sp,-64
    800020aa:	fc06                	sd	ra,56(sp)
    800020ac:	f822                	sd	s0,48(sp)
    800020ae:	f426                	sd	s1,40(sp)
    800020b0:	f04a                	sd	s2,32(sp)
    800020b2:	ec4e                	sd	s3,24(sp)
    800020b4:	e852                	sd	s4,16(sp)
    800020b6:	e456                	sd	s5,8(sp)
    800020b8:	0080                	addi	s0,sp,64
	struct proc *p = myproc();
    800020ba:	00000097          	auipc	ra,0x0
    800020be:	bfe080e7          	jalr	-1026(ra) # 80001cb8 <myproc>
    800020c2:	892a                	mv	s2,a0
	if ((np = allocproc()) == 0)
    800020c4:	00000097          	auipc	ra,0x0
    800020c8:	e00080e7          	jalr	-512(ra) # 80001ec4 <allocproc>
    800020cc:	12050363          	beqz	a0,800021f2 <fork+0x14a>
    800020d0:	89aa                	mv	s3,a0
	if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    800020d2:	05093603          	ld	a2,80(s2)
    800020d6:	6d2c                	ld	a1,88(a0)
    800020d8:	05893503          	ld	a0,88(s2)
    800020dc:	fffff097          	auipc	ra,0xfffff
    800020e0:	662080e7          	jalr	1634(ra) # 8000173e <uvmcopy>
    800020e4:	04054a63          	bltz	a0,80002138 <fork+0x90>
	np->mask = p->mask; // copying mask so that we can also trace child processes
    800020e8:	00092783          	lw	a5,0(s2)
    800020ec:	00f9a023          	sw	a5,0(s3)
	np->sz = p->sz;
    800020f0:	05093783          	ld	a5,80(s2)
    800020f4:	04f9b823          	sd	a5,80(s3)
	*(np->trapframe) = *(p->trapframe);
    800020f8:	06093683          	ld	a3,96(s2)
    800020fc:	87b6                	mv	a5,a3
    800020fe:	0609b703          	ld	a4,96(s3)
    80002102:	12068693          	addi	a3,a3,288
    80002106:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    8000210a:	6788                	ld	a0,8(a5)
    8000210c:	6b8c                	ld	a1,16(a5)
    8000210e:	6f90                	ld	a2,24(a5)
    80002110:	01073023          	sd	a6,0(a4)
    80002114:	e708                	sd	a0,8(a4)
    80002116:	eb0c                	sd	a1,16(a4)
    80002118:	ef10                	sd	a2,24(a4)
    8000211a:	02078793          	addi	a5,a5,32
    8000211e:	02070713          	addi	a4,a4,32
    80002122:	fed792e3          	bne	a5,a3,80002106 <fork+0x5e>
	np->trapframe->a0 = 0;
    80002126:	0609b783          	ld	a5,96(s3)
    8000212a:	0607b823          	sd	zero,112(a5)
    8000212e:	0d800493          	li	s1,216
	for (i = 0; i < NOFILE; i++)
    80002132:	15800a13          	li	s4,344
    80002136:	a805                	j	80002166 <fork+0xbe>
		freeproc(np);
    80002138:	854e                	mv	a0,s3
    8000213a:	00000097          	auipc	ra,0x0
    8000213e:	d32080e7          	jalr	-718(ra) # 80001e6c <freeproc>
		release(&np->lock);
    80002142:	00898513          	addi	a0,s3,8
    80002146:	fffff097          	auipc	ra,0xfffff
    8000214a:	d16080e7          	jalr	-746(ra) # 80000e5c <release>
		return -1;
    8000214e:	5afd                	li	s5,-1
    80002150:	a079                	j	800021de <fork+0x136>
			np->ofile[i] = filedup(p->ofile[i]);
    80002152:	00003097          	auipc	ra,0x3
    80002156:	c3e080e7          	jalr	-962(ra) # 80004d90 <filedup>
    8000215a:	009987b3          	add	a5,s3,s1
    8000215e:	e388                	sd	a0,0(a5)
	for (i = 0; i < NOFILE; i++)
    80002160:	04a1                	addi	s1,s1,8
    80002162:	01448763          	beq	s1,s4,80002170 <fork+0xc8>
		if (p->ofile[i])
    80002166:	009907b3          	add	a5,s2,s1
    8000216a:	6388                	ld	a0,0(a5)
    8000216c:	f17d                	bnez	a0,80002152 <fork+0xaa>
    8000216e:	bfcd                	j	80002160 <fork+0xb8>
	np->cwd = idup(p->cwd);
    80002170:	15893503          	ld	a0,344(s2)
    80002174:	00002097          	auipc	ra,0x2
    80002178:	da2080e7          	jalr	-606(ra) # 80003f16 <idup>
    8000217c:	14a9bc23          	sd	a0,344(s3)
	safestrcpy(np->name, p->name, sizeof(p->name));
    80002180:	4641                	li	a2,16
    80002182:	16090593          	addi	a1,s2,352
    80002186:	16098513          	addi	a0,s3,352
    8000218a:	fffff097          	auipc	ra,0xfffff
    8000218e:	e6c080e7          	jalr	-404(ra) # 80000ff6 <safestrcpy>
	pid = np->pid;
    80002192:	0389aa83          	lw	s5,56(s3)
	release(&np->lock);
    80002196:	00898493          	addi	s1,s3,8
    8000219a:	8526                	mv	a0,s1
    8000219c:	fffff097          	auipc	ra,0xfffff
    800021a0:	cc0080e7          	jalr	-832(ra) # 80000e5c <release>
	acquire(&wait_lock);
    800021a4:	0022fa17          	auipc	s4,0x22f
    800021a8:	cfca0a13          	addi	s4,s4,-772 # 80230ea0 <wait_lock>
    800021ac:	8552                	mv	a0,s4
    800021ae:	fffff097          	auipc	ra,0xfffff
    800021b2:	bfa080e7          	jalr	-1030(ra) # 80000da8 <acquire>
	np->parent = p;
    800021b6:	0529b023          	sd	s2,64(s3)
	release(&wait_lock);
    800021ba:	8552                	mv	a0,s4
    800021bc:	fffff097          	auipc	ra,0xfffff
    800021c0:	ca0080e7          	jalr	-864(ra) # 80000e5c <release>
	acquire(&np->lock);
    800021c4:	8526                	mv	a0,s1
    800021c6:	fffff097          	auipc	ra,0xfffff
    800021ca:	be2080e7          	jalr	-1054(ra) # 80000da8 <acquire>
	np->state = RUNNABLE;
    800021ce:	478d                	li	a5,3
    800021d0:	02f9a023          	sw	a5,32(s3)
	release(&np->lock);
    800021d4:	8526                	mv	a0,s1
    800021d6:	fffff097          	auipc	ra,0xfffff
    800021da:	c86080e7          	jalr	-890(ra) # 80000e5c <release>
}
    800021de:	8556                	mv	a0,s5
    800021e0:	70e2                	ld	ra,56(sp)
    800021e2:	7442                	ld	s0,48(sp)
    800021e4:	74a2                	ld	s1,40(sp)
    800021e6:	7902                	ld	s2,32(sp)
    800021e8:	69e2                	ld	s3,24(sp)
    800021ea:	6a42                	ld	s4,16(sp)
    800021ec:	6aa2                	ld	s5,8(sp)
    800021ee:	6121                	addi	sp,sp,64
    800021f0:	8082                	ret
		return -1;
    800021f2:	5afd                	li	s5,-1
    800021f4:	b7ed                	j	800021de <fork+0x136>

00000000800021f6 <upd_time>:
{
    800021f6:	7179                	addi	sp,sp,-48
    800021f8:	f406                	sd	ra,40(sp)
    800021fa:	f022                	sd	s0,32(sp)
    800021fc:	ec26                	sd	s1,24(sp)
    800021fe:	e84a                	sd	s2,16(sp)
    80002200:	e44e                	sd	s3,8(sp)
    80002202:	e052                	sd	s4,0(sp)
    80002204:	1800                	addi	s0,sp,48
	while (pr < &proc[NPROC])
    80002206:	0022f497          	auipc	s1,0x22f
    8000220a:	0ba48493          	addi	s1,s1,186 # 802312c0 <proc+0x8>
    8000220e:	00236a17          	auipc	s4,0x236
    80002212:	4b2a0a13          	addi	s4,s4,1202 # 802386c0 <tickslock+0x8>
		if (pr->state == RUNNING)
    80002216:	4991                	li	s3,4
    80002218:	a811                	j	8000222c <upd_time+0x36>
		release(&pr->lock);
    8000221a:	854a                	mv	a0,s2
    8000221c:	fffff097          	auipc	ra,0xfffff
    80002220:	c40080e7          	jalr	-960(ra) # 80000e5c <release>
	while (pr < &proc[NPROC])
    80002224:	1d048493          	addi	s1,s1,464
    80002228:	03448663          	beq	s1,s4,80002254 <upd_time+0x5e>
		acquire(&pr->lock);
    8000222c:	8926                	mv	s2,s1
    8000222e:	8526                	mv	a0,s1
    80002230:	fffff097          	auipc	ra,0xfffff
    80002234:	b78080e7          	jalr	-1160(ra) # 80000da8 <acquire>
		if (pr->state == RUNNING)
    80002238:	4c9c                	lw	a5,24(s1)
    8000223a:	ff3790e3          	bne	a5,s3,8000221a <upd_time+0x24>
			pr->runTime++;
    8000223e:	1784a783          	lw	a5,376(s1)
    80002242:	2785                	addiw	a5,a5,1
    80002244:	16f4ac23          	sw	a5,376(s1)
			pr->runTimePrev++;
    80002248:	18c4a783          	lw	a5,396(s1)
    8000224c:	2785                	addiw	a5,a5,1
    8000224e:	18f4a623          	sw	a5,396(s1)
    80002252:	b7e1                	j	8000221a <upd_time+0x24>
}
    80002254:	70a2                	ld	ra,40(sp)
    80002256:	7402                	ld	s0,32(sp)
    80002258:	64e2                	ld	s1,24(sp)
    8000225a:	6942                	ld	s2,16(sp)
    8000225c:	69a2                	ld	s3,8(sp)
    8000225e:	6a02                	ld	s4,0(sp)
    80002260:	6145                	addi	sp,sp,48
    80002262:	8082                	ret

0000000080002264 <scheduler>:
{
    80002264:	715d                	addi	sp,sp,-80
    80002266:	e486                	sd	ra,72(sp)
    80002268:	e0a2                	sd	s0,64(sp)
    8000226a:	fc26                	sd	s1,56(sp)
    8000226c:	f84a                	sd	s2,48(sp)
    8000226e:	f44e                	sd	s3,40(sp)
    80002270:	f052                	sd	s4,32(sp)
    80002272:	ec56                	sd	s5,24(sp)
    80002274:	e85a                	sd	s6,16(sp)
    80002276:	e45e                	sd	s7,8(sp)
    80002278:	0880                	addi	s0,sp,80
    8000227a:	8792                	mv	a5,tp
	int id = r_tp();
    8000227c:	2781                	sext.w	a5,a5
	c->proc = 0;
    8000227e:	00779b13          	slli	s6,a5,0x7
    80002282:	0022f717          	auipc	a4,0x22f
    80002286:	c0670713          	addi	a4,a4,-1018 # 80230e88 <pid_lock>
    8000228a:	975a                	add	a4,a4,s6
    8000228c:	02073823          	sd	zero,48(a4)
				swtch(&c->context, &p->context);
    80002290:	0022f717          	auipc	a4,0x22f
    80002294:	c3070713          	addi	a4,a4,-976 # 80230ec0 <cpus+0x8>
    80002298:	9b3a                	add	s6,s6,a4
			if (p->state == RUNNABLE)
    8000229a:	4a0d                	li	s4,3
				p->state = RUNNING;
    8000229c:	4b91                	li	s7,4
				c->proc = p;
    8000229e:	079e                	slli	a5,a5,0x7
    800022a0:	0022fa97          	auipc	s5,0x22f
    800022a4:	be8a8a93          	addi	s5,s5,-1048 # 80230e88 <pid_lock>
    800022a8:	9abe                	add	s5,s5,a5
		for (p = proc; p < &proc[NPROC]; p++)
    800022aa:	00236997          	auipc	s3,0x236
    800022ae:	40e98993          	addi	s3,s3,1038 # 802386b8 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800022b2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800022b6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800022ba:	10079073          	csrw	sstatus,a5
    800022be:	0022f497          	auipc	s1,0x22f
    800022c2:	ffa48493          	addi	s1,s1,-6 # 802312b8 <proc>
    800022c6:	a03d                	j	800022f4 <scheduler+0x90>
				p->state = RUNNING;
    800022c8:	0374a023          	sw	s7,32(s1)
				c->proc = p;
    800022cc:	029ab823          	sd	s1,48(s5)
				swtch(&c->context, &p->context);
    800022d0:	06848593          	addi	a1,s1,104
    800022d4:	855a                	mv	a0,s6
    800022d6:	00001097          	auipc	ra,0x1
    800022da:	88a080e7          	jalr	-1910(ra) # 80002b60 <swtch>
				c->proc = 0;
    800022de:	020ab823          	sd	zero,48(s5)
			release(&p->lock);
    800022e2:	854a                	mv	a0,s2
    800022e4:	fffff097          	auipc	ra,0xfffff
    800022e8:	b78080e7          	jalr	-1160(ra) # 80000e5c <release>
		for (p = proc; p < &proc[NPROC]; p++)
    800022ec:	1d048493          	addi	s1,s1,464
    800022f0:	fd3481e3          	beq	s1,s3,800022b2 <scheduler+0x4e>
			acquire(&p->lock);
    800022f4:	00848913          	addi	s2,s1,8
    800022f8:	854a                	mv	a0,s2
    800022fa:	fffff097          	auipc	ra,0xfffff
    800022fe:	aae080e7          	jalr	-1362(ra) # 80000da8 <acquire>
			if (p->state == RUNNABLE)
    80002302:	509c                	lw	a5,32(s1)
    80002304:	fd479fe3          	bne	a5,s4,800022e2 <scheduler+0x7e>
    80002308:	b7c1                	j	800022c8 <scheduler+0x64>

000000008000230a <sched>:
{
    8000230a:	7179                	addi	sp,sp,-48
    8000230c:	f406                	sd	ra,40(sp)
    8000230e:	f022                	sd	s0,32(sp)
    80002310:	ec26                	sd	s1,24(sp)
    80002312:	e84a                	sd	s2,16(sp)
    80002314:	e44e                	sd	s3,8(sp)
    80002316:	1800                	addi	s0,sp,48
	struct proc *p = myproc();
    80002318:	00000097          	auipc	ra,0x0
    8000231c:	9a0080e7          	jalr	-1632(ra) # 80001cb8 <myproc>
    80002320:	84aa                	mv	s1,a0
	if (!holding(&p->lock))
    80002322:	0521                	addi	a0,a0,8
    80002324:	fffff097          	auipc	ra,0xfffff
    80002328:	a0a080e7          	jalr	-1526(ra) # 80000d2e <holding>
    8000232c:	c93d                	beqz	a0,800023a2 <sched+0x98>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000232e:	8792                	mv	a5,tp
	if (mycpu()->noff != 1)
    80002330:	2781                	sext.w	a5,a5
    80002332:	079e                	slli	a5,a5,0x7
    80002334:	0022f717          	auipc	a4,0x22f
    80002338:	b5470713          	addi	a4,a4,-1196 # 80230e88 <pid_lock>
    8000233c:	97ba                	add	a5,a5,a4
    8000233e:	0a87a703          	lw	a4,168(a5)
    80002342:	4785                	li	a5,1
    80002344:	06f71763          	bne	a4,a5,800023b2 <sched+0xa8>
	if (p->state == RUNNING)
    80002348:	5098                	lw	a4,32(s1)
    8000234a:	4791                	li	a5,4
    8000234c:	06f70b63          	beq	a4,a5,800023c2 <sched+0xb8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002350:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002354:	8b89                	andi	a5,a5,2
	if (intr_get())
    80002356:	efb5                	bnez	a5,800023d2 <sched+0xc8>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002358:	8792                	mv	a5,tp
	intena = mycpu()->intena;
    8000235a:	0022f917          	auipc	s2,0x22f
    8000235e:	b2e90913          	addi	s2,s2,-1234 # 80230e88 <pid_lock>
    80002362:	2781                	sext.w	a5,a5
    80002364:	079e                	slli	a5,a5,0x7
    80002366:	97ca                	add	a5,a5,s2
    80002368:	0ac7a983          	lw	s3,172(a5)
    8000236c:	8792                	mv	a5,tp
	swtch(&p->context, &mycpu()->context);
    8000236e:	2781                	sext.w	a5,a5
    80002370:	079e                	slli	a5,a5,0x7
    80002372:	0022f597          	auipc	a1,0x22f
    80002376:	b4e58593          	addi	a1,a1,-1202 # 80230ec0 <cpus+0x8>
    8000237a:	95be                	add	a1,a1,a5
    8000237c:	06848513          	addi	a0,s1,104
    80002380:	00000097          	auipc	ra,0x0
    80002384:	7e0080e7          	jalr	2016(ra) # 80002b60 <swtch>
    80002388:	8792                	mv	a5,tp
	mycpu()->intena = intena;
    8000238a:	2781                	sext.w	a5,a5
    8000238c:	079e                	slli	a5,a5,0x7
    8000238e:	97ca                	add	a5,a5,s2
    80002390:	0b37a623          	sw	s3,172(a5)
}
    80002394:	70a2                	ld	ra,40(sp)
    80002396:	7402                	ld	s0,32(sp)
    80002398:	64e2                	ld	s1,24(sp)
    8000239a:	6942                	ld	s2,16(sp)
    8000239c:	69a2                	ld	s3,8(sp)
    8000239e:	6145                	addi	sp,sp,48
    800023a0:	8082                	ret
		panic("sched p->lock");
    800023a2:	00006517          	auipc	a0,0x6
    800023a6:	ebe50513          	addi	a0,a0,-322 # 80008260 <digits+0x220>
    800023aa:	ffffe097          	auipc	ra,0xffffe
    800023ae:	19a080e7          	jalr	410(ra) # 80000544 <panic>
		panic("sched locks");
    800023b2:	00006517          	auipc	a0,0x6
    800023b6:	ebe50513          	addi	a0,a0,-322 # 80008270 <digits+0x230>
    800023ba:	ffffe097          	auipc	ra,0xffffe
    800023be:	18a080e7          	jalr	394(ra) # 80000544 <panic>
		panic("sched running");
    800023c2:	00006517          	auipc	a0,0x6
    800023c6:	ebe50513          	addi	a0,a0,-322 # 80008280 <digits+0x240>
    800023ca:	ffffe097          	auipc	ra,0xffffe
    800023ce:	17a080e7          	jalr	378(ra) # 80000544 <panic>
		panic("sched interruptible");
    800023d2:	00006517          	auipc	a0,0x6
    800023d6:	ebe50513          	addi	a0,a0,-322 # 80008290 <digits+0x250>
    800023da:	ffffe097          	auipc	ra,0xffffe
    800023de:	16a080e7          	jalr	362(ra) # 80000544 <panic>

00000000800023e2 <yield>:
{
    800023e2:	1101                	addi	sp,sp,-32
    800023e4:	ec06                	sd	ra,24(sp)
    800023e6:	e822                	sd	s0,16(sp)
    800023e8:	e426                	sd	s1,8(sp)
    800023ea:	e04a                	sd	s2,0(sp)
    800023ec:	1000                	addi	s0,sp,32
	struct proc *p = myproc();
    800023ee:	00000097          	auipc	ra,0x0
    800023f2:	8ca080e7          	jalr	-1846(ra) # 80001cb8 <myproc>
    800023f6:	84aa                	mv	s1,a0
	acquire(&p->lock);
    800023f8:	00850913          	addi	s2,a0,8
    800023fc:	854a                	mv	a0,s2
    800023fe:	fffff097          	auipc	ra,0xfffff
    80002402:	9aa080e7          	jalr	-1622(ra) # 80000da8 <acquire>
	p->state = RUNNABLE;
    80002406:	478d                	li	a5,3
    80002408:	d09c                	sw	a5,32(s1)
	sched();
    8000240a:	00000097          	auipc	ra,0x0
    8000240e:	f00080e7          	jalr	-256(ra) # 8000230a <sched>
	release(&p->lock);
    80002412:	854a                	mv	a0,s2
    80002414:	fffff097          	auipc	ra,0xfffff
    80002418:	a48080e7          	jalr	-1464(ra) # 80000e5c <release>
}
    8000241c:	60e2                	ld	ra,24(sp)
    8000241e:	6442                	ld	s0,16(sp)
    80002420:	64a2                	ld	s1,8(sp)
    80002422:	6902                	ld	s2,0(sp)
    80002424:	6105                	addi	sp,sp,32
    80002426:	8082                	ret

0000000080002428 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    80002428:	7179                	addi	sp,sp,-48
    8000242a:	f406                	sd	ra,40(sp)
    8000242c:	f022                	sd	s0,32(sp)
    8000242e:	ec26                	sd	s1,24(sp)
    80002430:	e84a                	sd	s2,16(sp)
    80002432:	e44e                	sd	s3,8(sp)
    80002434:	e052                	sd	s4,0(sp)
    80002436:	1800                	addi	s0,sp,48
    80002438:	89aa                	mv	s3,a0
    8000243a:	892e                	mv	s2,a1
	struct proc *p = myproc();
    8000243c:	00000097          	auipc	ra,0x0
    80002440:	87c080e7          	jalr	-1924(ra) # 80001cb8 <myproc>
    80002444:	84aa                	mv	s1,a0
	// Once we hold p->lock, we can be
	// guaranteed that we won't miss any wakeup
	// (wakeup locks p->lock),
	// so it's okay to release lk.

	acquire(&p->lock); // DOC: sleeplock1
    80002446:	00850a13          	addi	s4,a0,8
    8000244a:	8552                	mv	a0,s4
    8000244c:	fffff097          	auipc	ra,0xfffff
    80002450:	95c080e7          	jalr	-1700(ra) # 80000da8 <acquire>
	release(lk);
    80002454:	854a                	mv	a0,s2
    80002456:	fffff097          	auipc	ra,0xfffff
    8000245a:	a06080e7          	jalr	-1530(ra) # 80000e5c <release>

	// Go to sleep.
	p->chan = chan;
    8000245e:	0334b423          	sd	s3,40(s1)
	p->state = SLEEPING;
    80002462:	4789                	li	a5,2
    80002464:	d09c                	sw	a5,32(s1)

	sched();
    80002466:	00000097          	auipc	ra,0x0
    8000246a:	ea4080e7          	jalr	-348(ra) # 8000230a <sched>

	// Tidy up.
	p->chan = 0;
    8000246e:	0204b423          	sd	zero,40(s1)

	// Reacquire original lock.
	release(&p->lock);
    80002472:	8552                	mv	a0,s4
    80002474:	fffff097          	auipc	ra,0xfffff
    80002478:	9e8080e7          	jalr	-1560(ra) # 80000e5c <release>
	acquire(lk);
    8000247c:	854a                	mv	a0,s2
    8000247e:	fffff097          	auipc	ra,0xfffff
    80002482:	92a080e7          	jalr	-1750(ra) # 80000da8 <acquire>
}
    80002486:	70a2                	ld	ra,40(sp)
    80002488:	7402                	ld	s0,32(sp)
    8000248a:	64e2                	ld	s1,24(sp)
    8000248c:	6942                	ld	s2,16(sp)
    8000248e:	69a2                	ld	s3,8(sp)
    80002490:	6a02                	ld	s4,0(sp)
    80002492:	6145                	addi	sp,sp,48
    80002494:	8082                	ret

0000000080002496 <waitx>:
{
    80002496:	7159                	addi	sp,sp,-112
    80002498:	f486                	sd	ra,104(sp)
    8000249a:	f0a2                	sd	s0,96(sp)
    8000249c:	eca6                	sd	s1,88(sp)
    8000249e:	e8ca                	sd	s2,80(sp)
    800024a0:	e4ce                	sd	s3,72(sp)
    800024a2:	e0d2                	sd	s4,64(sp)
    800024a4:	fc56                	sd	s5,56(sp)
    800024a6:	f85a                	sd	s6,48(sp)
    800024a8:	f45e                	sd	s7,40(sp)
    800024aa:	f062                	sd	s8,32(sp)
    800024ac:	ec66                	sd	s9,24(sp)
    800024ae:	e86a                	sd	s10,16(sp)
    800024b0:	e46e                	sd	s11,8(sp)
    800024b2:	1880                	addi	s0,sp,112
    800024b4:	8b2a                	mv	s6,a0
    800024b6:	8bae                	mv	s7,a1
    800024b8:	8c32                	mv	s8,a2
	struct proc *p = myproc();
    800024ba:	fffff097          	auipc	ra,0xfffff
    800024be:	7fe080e7          	jalr	2046(ra) # 80001cb8 <myproc>
    800024c2:	892a                	mv	s2,a0
	acquire(&wait_lock);
    800024c4:	0022f517          	auipc	a0,0x22f
    800024c8:	9dc50513          	addi	a0,a0,-1572 # 80230ea0 <wait_lock>
    800024cc:	fffff097          	auipc	ra,0xfffff
    800024d0:	8dc080e7          	jalr	-1828(ra) # 80000da8 <acquire>
		havekids = 0;
    800024d4:	4c81                	li	s9,0
				if (np->state == ZOMBIE)
    800024d6:	4a15                	li	s4,5
		for (np = proc; np < &proc[NPROC]; np++)
    800024d8:	00236997          	auipc	s3,0x236
    800024dc:	1e098993          	addi	s3,s3,480 # 802386b8 <tickslock>
				havekids = 1;
    800024e0:	4a85                	li	s5,1
		sleep(p, &wait_lock); // DOC: wait-sleep
    800024e2:	0022fd17          	auipc	s10,0x22f
    800024e6:	9bed0d13          	addi	s10,s10,-1602 # 80230ea0 <wait_lock>
		havekids = 0;
    800024ea:	8766                	mv	a4,s9
		for (np = proc; np < &proc[NPROC]; np++)
    800024ec:	0022f497          	auipc	s1,0x22f
    800024f0:	dcc48493          	addi	s1,s1,-564 # 802312b8 <proc>
    800024f4:	a059                	j	8000257a <waitx+0xe4>
					pid = np->pid;
    800024f6:	0384a983          	lw	s3,56(s1)
					*rtime = np->runTime;
    800024fa:	1804a703          	lw	a4,384(s1)
    800024fe:	00ec2023          	sw	a4,0(s8) # 4000000 <_entry-0x7c000000>
					*wtime = np->endTime - np->creationTime - np->runTime;
    80002502:	17c4a783          	lw	a5,380(s1)
    80002506:	9f3d                	addw	a4,a4,a5
    80002508:	1844a783          	lw	a5,388(s1)
    8000250c:	9f99                	subw	a5,a5,a4
    8000250e:	00fba023          	sw	a5,0(s7) # fffffffffffff000 <end+0xffffffff7fdbb568>
					if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002512:	000b0e63          	beqz	s6,8000252e <waitx+0x98>
    80002516:	4691                	li	a3,4
    80002518:	03448613          	addi	a2,s1,52
    8000251c:	85da                	mv	a1,s6
    8000251e:	05893503          	ld	a0,88(s2)
    80002522:	fffff097          	auipc	ra,0xfffff
    80002526:	316080e7          	jalr	790(ra) # 80001838 <copyout>
    8000252a:	02054563          	bltz	a0,80002554 <waitx+0xbe>
					freeproc(np);
    8000252e:	8526                	mv	a0,s1
    80002530:	00000097          	auipc	ra,0x0
    80002534:	93c080e7          	jalr	-1732(ra) # 80001e6c <freeproc>
					release(&np->lock);
    80002538:	856e                	mv	a0,s11
    8000253a:	fffff097          	auipc	ra,0xfffff
    8000253e:	922080e7          	jalr	-1758(ra) # 80000e5c <release>
					release(&wait_lock);
    80002542:	0022f517          	auipc	a0,0x22f
    80002546:	95e50513          	addi	a0,a0,-1698 # 80230ea0 <wait_lock>
    8000254a:	fffff097          	auipc	ra,0xfffff
    8000254e:	912080e7          	jalr	-1774(ra) # 80000e5c <release>
					return pid;
    80002552:	a0ad                	j	800025bc <waitx+0x126>
						release(&np->lock);
    80002554:	856e                	mv	a0,s11
    80002556:	fffff097          	auipc	ra,0xfffff
    8000255a:	906080e7          	jalr	-1786(ra) # 80000e5c <release>
						release(&wait_lock);
    8000255e:	0022f517          	auipc	a0,0x22f
    80002562:	94250513          	addi	a0,a0,-1726 # 80230ea0 <wait_lock>
    80002566:	fffff097          	auipc	ra,0xfffff
    8000256a:	8f6080e7          	jalr	-1802(ra) # 80000e5c <release>
						return -1;
    8000256e:	59fd                	li	s3,-1
    80002570:	a0b1                	j	800025bc <waitx+0x126>
		for (np = proc; np < &proc[NPROC]; np++)
    80002572:	1d048493          	addi	s1,s1,464
    80002576:	03348663          	beq	s1,s3,800025a2 <waitx+0x10c>
			if (np->parent == p)
    8000257a:	60bc                	ld	a5,64(s1)
    8000257c:	ff279be3          	bne	a5,s2,80002572 <waitx+0xdc>
				acquire(&np->lock);
    80002580:	00848d93          	addi	s11,s1,8
    80002584:	856e                	mv	a0,s11
    80002586:	fffff097          	auipc	ra,0xfffff
    8000258a:	822080e7          	jalr	-2014(ra) # 80000da8 <acquire>
				if (np->state == ZOMBIE)
    8000258e:	509c                	lw	a5,32(s1)
    80002590:	f74783e3          	beq	a5,s4,800024f6 <waitx+0x60>
				release(&np->lock);
    80002594:	856e                	mv	a0,s11
    80002596:	fffff097          	auipc	ra,0xfffff
    8000259a:	8c6080e7          	jalr	-1850(ra) # 80000e5c <release>
				havekids = 1;
    8000259e:	8756                	mv	a4,s5
    800025a0:	bfc9                	j	80002572 <waitx+0xdc>
		if (!havekids || p->killed)
    800025a2:	c701                	beqz	a4,800025aa <waitx+0x114>
    800025a4:	03092783          	lw	a5,48(s2)
    800025a8:	cb95                	beqz	a5,800025dc <waitx+0x146>
			release(&wait_lock);
    800025aa:	0022f517          	auipc	a0,0x22f
    800025ae:	8f650513          	addi	a0,a0,-1802 # 80230ea0 <wait_lock>
    800025b2:	fffff097          	auipc	ra,0xfffff
    800025b6:	8aa080e7          	jalr	-1878(ra) # 80000e5c <release>
			return -1;
    800025ba:	59fd                	li	s3,-1
}
    800025bc:	854e                	mv	a0,s3
    800025be:	70a6                	ld	ra,104(sp)
    800025c0:	7406                	ld	s0,96(sp)
    800025c2:	64e6                	ld	s1,88(sp)
    800025c4:	6946                	ld	s2,80(sp)
    800025c6:	69a6                	ld	s3,72(sp)
    800025c8:	6a06                	ld	s4,64(sp)
    800025ca:	7ae2                	ld	s5,56(sp)
    800025cc:	7b42                	ld	s6,48(sp)
    800025ce:	7ba2                	ld	s7,40(sp)
    800025d0:	7c02                	ld	s8,32(sp)
    800025d2:	6ce2                	ld	s9,24(sp)
    800025d4:	6d42                	ld	s10,16(sp)
    800025d6:	6da2                	ld	s11,8(sp)
    800025d8:	6165                	addi	sp,sp,112
    800025da:	8082                	ret
		sleep(p, &wait_lock); // DOC: wait-sleep
    800025dc:	85ea                	mv	a1,s10
    800025de:	854a                	mv	a0,s2
    800025e0:	00000097          	auipc	ra,0x0
    800025e4:	e48080e7          	jalr	-440(ra) # 80002428 <sleep>
		havekids = 0;
    800025e8:	b709                	j	800024ea <waitx+0x54>

00000000800025ea <wait>:
{
    800025ea:	711d                	addi	sp,sp,-96
    800025ec:	ec86                	sd	ra,88(sp)
    800025ee:	e8a2                	sd	s0,80(sp)
    800025f0:	e4a6                	sd	s1,72(sp)
    800025f2:	e0ca                	sd	s2,64(sp)
    800025f4:	fc4e                	sd	s3,56(sp)
    800025f6:	f852                	sd	s4,48(sp)
    800025f8:	f456                	sd	s5,40(sp)
    800025fa:	f05a                	sd	s6,32(sp)
    800025fc:	ec5e                	sd	s7,24(sp)
    800025fe:	e862                	sd	s8,16(sp)
    80002600:	e466                	sd	s9,8(sp)
    80002602:	1080                	addi	s0,sp,96
    80002604:	8baa                	mv	s7,a0
	struct proc *p = myproc();
    80002606:	fffff097          	auipc	ra,0xfffff
    8000260a:	6b2080e7          	jalr	1714(ra) # 80001cb8 <myproc>
    8000260e:	892a                	mv	s2,a0
	acquire(&wait_lock);
    80002610:	0022f517          	auipc	a0,0x22f
    80002614:	89050513          	addi	a0,a0,-1904 # 80230ea0 <wait_lock>
    80002618:	ffffe097          	auipc	ra,0xffffe
    8000261c:	790080e7          	jalr	1936(ra) # 80000da8 <acquire>
		havekids = 0;
    80002620:	4c01                	li	s8,0
				if (pp->state == ZOMBIE)
    80002622:	4a95                	li	s5,5
		for (pp = proc; pp < &proc[NPROC]; pp++)
    80002624:	00236997          	auipc	s3,0x236
    80002628:	09498993          	addi	s3,s3,148 # 802386b8 <tickslock>
				havekids = 1;
    8000262c:	4b05                	li	s6,1
		sleep(p, &wait_lock); // DOC: wait-sleep
    8000262e:	0022fc97          	auipc	s9,0x22f
    80002632:	872c8c93          	addi	s9,s9,-1934 # 80230ea0 <wait_lock>
		havekids = 0;
    80002636:	8762                	mv	a4,s8
		for (pp = proc; pp < &proc[NPROC]; pp++)
    80002638:	0022f497          	auipc	s1,0x22f
    8000263c:	c8048493          	addi	s1,s1,-896 # 802312b8 <proc>
    80002640:	a8ad                	j	800026ba <wait+0xd0>
					pid = pp->pid;
    80002642:	0384a983          	lw	s3,56(s1)
					if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002646:	000b8e63          	beqz	s7,80002662 <wait+0x78>
    8000264a:	4691                	li	a3,4
    8000264c:	03448613          	addi	a2,s1,52
    80002650:	85de                	mv	a1,s7
    80002652:	05893503          	ld	a0,88(s2)
    80002656:	fffff097          	auipc	ra,0xfffff
    8000265a:	1e2080e7          	jalr	482(ra) # 80001838 <copyout>
    8000265e:	02054b63          	bltz	a0,80002694 <wait+0xaa>
					freeproc(pp);
    80002662:	8526                	mv	a0,s1
    80002664:	00000097          	auipc	ra,0x0
    80002668:	808080e7          	jalr	-2040(ra) # 80001e6c <freeproc>
					release(&pp->lock);
    8000266c:	8552                	mv	a0,s4
    8000266e:	ffffe097          	auipc	ra,0xffffe
    80002672:	7ee080e7          	jalr	2030(ra) # 80000e5c <release>
					release(&wait_lock);
    80002676:	0022f517          	auipc	a0,0x22f
    8000267a:	82a50513          	addi	a0,a0,-2006 # 80230ea0 <wait_lock>
    8000267e:	ffffe097          	auipc	ra,0xffffe
    80002682:	7de080e7          	jalr	2014(ra) # 80000e5c <release>
					pp->endTime = ticks;
    80002686:	00006797          	auipc	a5,0x6
    8000268a:	57a7a783          	lw	a5,1402(a5) # 80008c00 <ticks>
    8000268e:	18f4a223          	sw	a5,388(s1)
					return pid;
    80002692:	a0ad                	j	800026fc <wait+0x112>
						release(&pp->lock);
    80002694:	8552                	mv	a0,s4
    80002696:	ffffe097          	auipc	ra,0xffffe
    8000269a:	7c6080e7          	jalr	1990(ra) # 80000e5c <release>
						release(&wait_lock);
    8000269e:	0022f517          	auipc	a0,0x22f
    800026a2:	80250513          	addi	a0,a0,-2046 # 80230ea0 <wait_lock>
    800026a6:	ffffe097          	auipc	ra,0xffffe
    800026aa:	7b6080e7          	jalr	1974(ra) # 80000e5c <release>
						return -1;
    800026ae:	59fd                	li	s3,-1
    800026b0:	a0b1                	j	800026fc <wait+0x112>
		for (pp = proc; pp < &proc[NPROC]; pp++)
    800026b2:	1d048493          	addi	s1,s1,464
    800026b6:	03348663          	beq	s1,s3,800026e2 <wait+0xf8>
			if (pp->parent == p)
    800026ba:	60bc                	ld	a5,64(s1)
    800026bc:	ff279be3          	bne	a5,s2,800026b2 <wait+0xc8>
				acquire(&pp->lock);
    800026c0:	00848a13          	addi	s4,s1,8
    800026c4:	8552                	mv	a0,s4
    800026c6:	ffffe097          	auipc	ra,0xffffe
    800026ca:	6e2080e7          	jalr	1762(ra) # 80000da8 <acquire>
				if (pp->state == ZOMBIE)
    800026ce:	509c                	lw	a5,32(s1)
    800026d0:	f75789e3          	beq	a5,s5,80002642 <wait+0x58>
				release(&pp->lock);
    800026d4:	8552                	mv	a0,s4
    800026d6:	ffffe097          	auipc	ra,0xffffe
    800026da:	786080e7          	jalr	1926(ra) # 80000e5c <release>
				havekids = 1;
    800026de:	875a                	mv	a4,s6
    800026e0:	bfc9                	j	800026b2 <wait+0xc8>
		if (!havekids || p->killed)
    800026e2:	c701                	beqz	a4,800026ea <wait+0x100>
    800026e4:	03092783          	lw	a5,48(s2)
    800026e8:	cb85                	beqz	a5,80002718 <wait+0x12e>
			release(&wait_lock);
    800026ea:	0022e517          	auipc	a0,0x22e
    800026ee:	7b650513          	addi	a0,a0,1974 # 80230ea0 <wait_lock>
    800026f2:	ffffe097          	auipc	ra,0xffffe
    800026f6:	76a080e7          	jalr	1898(ra) # 80000e5c <release>
			return -1;
    800026fa:	59fd                	li	s3,-1
}
    800026fc:	854e                	mv	a0,s3
    800026fe:	60e6                	ld	ra,88(sp)
    80002700:	6446                	ld	s0,80(sp)
    80002702:	64a6                	ld	s1,72(sp)
    80002704:	6906                	ld	s2,64(sp)
    80002706:	79e2                	ld	s3,56(sp)
    80002708:	7a42                	ld	s4,48(sp)
    8000270a:	7aa2                	ld	s5,40(sp)
    8000270c:	7b02                	ld	s6,32(sp)
    8000270e:	6be2                	ld	s7,24(sp)
    80002710:	6c42                	ld	s8,16(sp)
    80002712:	6ca2                	ld	s9,8(sp)
    80002714:	6125                	addi	sp,sp,96
    80002716:	8082                	ret
		sleep(p, &wait_lock); // DOC: wait-sleep
    80002718:	85e6                	mv	a1,s9
    8000271a:	854a                	mv	a0,s2
    8000271c:	00000097          	auipc	ra,0x0
    80002720:	d0c080e7          	jalr	-756(ra) # 80002428 <sleep>
		havekids = 0;
    80002724:	bf09                	j	80002636 <wait+0x4c>

0000000080002726 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    80002726:	715d                	addi	sp,sp,-80
    80002728:	e486                	sd	ra,72(sp)
    8000272a:	e0a2                	sd	s0,64(sp)
    8000272c:	fc26                	sd	s1,56(sp)
    8000272e:	f84a                	sd	s2,48(sp)
    80002730:	f44e                	sd	s3,40(sp)
    80002732:	f052                	sd	s4,32(sp)
    80002734:	ec56                	sd	s5,24(sp)
    80002736:	e85a                	sd	s6,16(sp)
    80002738:	e45e                	sd	s7,8(sp)
    8000273a:	0880                	addi	s0,sp,80
    8000273c:	8aaa                	mv	s5,a0
	struct proc *p;

	for (p = proc; p < &proc[NPROC]; p++)
    8000273e:	0022f497          	auipc	s1,0x22f
    80002742:	b7a48493          	addi	s1,s1,-1158 # 802312b8 <proc>
	{
		if (p != myproc())
		{
			acquire(&p->lock);
			if (p->state == SLEEPING && p->chan == chan)
    80002746:	4a09                	li	s4,2
			{
				p->state = RUNNABLE;
    80002748:	4b0d                	li	s6,3
				p->time_spent = 0;
#endif
				// #ifdef PBS
				if (p->sleepStartTime != 0)
				{
					p->sleepTimePrev = ticks - p->sleepStartTime;
    8000274a:	00006b97          	auipc	s7,0x6
    8000274e:	4b6b8b93          	addi	s7,s7,1206 # 80008c00 <ticks>
	for (p = proc; p < &proc[NPROC]; p++)
    80002752:	00236997          	auipc	s3,0x236
    80002756:	f6698993          	addi	s3,s3,-154 # 802386b8 <tickslock>
    8000275a:	a811                	j	8000276e <wakeup+0x48>
				int slices[5] = {1, 2, 4, 8, 16};
				p->time_slice = slices[p->curr_queue];
				push(&mlfq[p->curr_queue], p);
#endif
			}
			release(&p->lock);
    8000275c:	854a                	mv	a0,s2
    8000275e:	ffffe097          	auipc	ra,0xffffe
    80002762:	6fe080e7          	jalr	1790(ra) # 80000e5c <release>
	for (p = proc; p < &proc[NPROC]; p++)
    80002766:	1d048493          	addi	s1,s1,464
    8000276a:	05348663          	beq	s1,s3,800027b6 <wakeup+0x90>
		if (p != myproc())
    8000276e:	fffff097          	auipc	ra,0xfffff
    80002772:	54a080e7          	jalr	1354(ra) # 80001cb8 <myproc>
    80002776:	fea488e3          	beq	s1,a0,80002766 <wakeup+0x40>
			acquire(&p->lock);
    8000277a:	00848913          	addi	s2,s1,8
    8000277e:	854a                	mv	a0,s2
    80002780:	ffffe097          	auipc	ra,0xffffe
    80002784:	628080e7          	jalr	1576(ra) # 80000da8 <acquire>
			if (p->state == SLEEPING && p->chan == chan)
    80002788:	509c                	lw	a5,32(s1)
    8000278a:	fd4799e3          	bne	a5,s4,8000275c <wakeup+0x36>
    8000278e:	749c                	ld	a5,40(s1)
    80002790:	fd5796e3          	bne	a5,s5,8000275c <wakeup+0x36>
				p->state = RUNNABLE;
    80002794:	0364a023          	sw	s6,32(s1)
				if (p->sleepStartTime != 0)
    80002798:	1904a783          	lw	a5,400(s1)
    8000279c:	d3e1                	beqz	a5,8000275c <wakeup+0x36>
					p->sleepTimePrev = ticks - p->sleepStartTime;
    8000279e:	000ba703          	lw	a4,0(s7)
    800027a2:	40f707bb          	subw	a5,a4,a5
    800027a6:	18f4a623          	sw	a5,396(s1)
					p->totalSleep += p->sleepTimePrev;
    800027aa:	1884a703          	lw	a4,392(s1)
    800027ae:	9fb9                	addw	a5,a5,a4
    800027b0:	18f4a423          	sw	a5,392(s1)
    800027b4:	b765                	j	8000275c <wakeup+0x36>
		}
	}
}
    800027b6:	60a6                	ld	ra,72(sp)
    800027b8:	6406                	ld	s0,64(sp)
    800027ba:	74e2                	ld	s1,56(sp)
    800027bc:	7942                	ld	s2,48(sp)
    800027be:	79a2                	ld	s3,40(sp)
    800027c0:	7a02                	ld	s4,32(sp)
    800027c2:	6ae2                	ld	s5,24(sp)
    800027c4:	6b42                	ld	s6,16(sp)
    800027c6:	6ba2                	ld	s7,8(sp)
    800027c8:	6161                	addi	sp,sp,80
    800027ca:	8082                	ret

00000000800027cc <reparent>:
{
    800027cc:	7179                	addi	sp,sp,-48
    800027ce:	f406                	sd	ra,40(sp)
    800027d0:	f022                	sd	s0,32(sp)
    800027d2:	ec26                	sd	s1,24(sp)
    800027d4:	e84a                	sd	s2,16(sp)
    800027d6:	e44e                	sd	s3,8(sp)
    800027d8:	e052                	sd	s4,0(sp)
    800027da:	1800                	addi	s0,sp,48
    800027dc:	892a                	mv	s2,a0
	for (pp = proc; pp < &proc[NPROC]; pp++)
    800027de:	0022f497          	auipc	s1,0x22f
    800027e2:	ada48493          	addi	s1,s1,-1318 # 802312b8 <proc>
			pp->parent = initproc;
    800027e6:	00006a17          	auipc	s4,0x6
    800027ea:	412a0a13          	addi	s4,s4,1042 # 80008bf8 <initproc>
	for (pp = proc; pp < &proc[NPROC]; pp++)
    800027ee:	00236997          	auipc	s3,0x236
    800027f2:	eca98993          	addi	s3,s3,-310 # 802386b8 <tickslock>
    800027f6:	a029                	j	80002800 <reparent+0x34>
    800027f8:	1d048493          	addi	s1,s1,464
    800027fc:	01348d63          	beq	s1,s3,80002816 <reparent+0x4a>
		if (pp->parent == p)
    80002800:	60bc                	ld	a5,64(s1)
    80002802:	ff279be3          	bne	a5,s2,800027f8 <reparent+0x2c>
			pp->parent = initproc;
    80002806:	000a3503          	ld	a0,0(s4)
    8000280a:	e0a8                	sd	a0,64(s1)
			wakeup(initproc);
    8000280c:	00000097          	auipc	ra,0x0
    80002810:	f1a080e7          	jalr	-230(ra) # 80002726 <wakeup>
    80002814:	b7d5                	j	800027f8 <reparent+0x2c>
}
    80002816:	70a2                	ld	ra,40(sp)
    80002818:	7402                	ld	s0,32(sp)
    8000281a:	64e2                	ld	s1,24(sp)
    8000281c:	6942                	ld	s2,16(sp)
    8000281e:	69a2                	ld	s3,8(sp)
    80002820:	6a02                	ld	s4,0(sp)
    80002822:	6145                	addi	sp,sp,48
    80002824:	8082                	ret

0000000080002826 <exit>:
{
    80002826:	7179                	addi	sp,sp,-48
    80002828:	f406                	sd	ra,40(sp)
    8000282a:	f022                	sd	s0,32(sp)
    8000282c:	ec26                	sd	s1,24(sp)
    8000282e:	e84a                	sd	s2,16(sp)
    80002830:	e44e                	sd	s3,8(sp)
    80002832:	e052                	sd	s4,0(sp)
    80002834:	1800                	addi	s0,sp,48
    80002836:	8a2a                	mv	s4,a0
	struct proc *p = myproc();
    80002838:	fffff097          	auipc	ra,0xfffff
    8000283c:	480080e7          	jalr	1152(ra) # 80001cb8 <myproc>
    80002840:	89aa                	mv	s3,a0
	if (p == initproc)
    80002842:	00006797          	auipc	a5,0x6
    80002846:	3b67b783          	ld	a5,950(a5) # 80008bf8 <initproc>
    8000284a:	0d850493          	addi	s1,a0,216
    8000284e:	15850913          	addi	s2,a0,344
    80002852:	02a79363          	bne	a5,a0,80002878 <exit+0x52>
		panic("init exiting");
    80002856:	00006517          	auipc	a0,0x6
    8000285a:	a5250513          	addi	a0,a0,-1454 # 800082a8 <digits+0x268>
    8000285e:	ffffe097          	auipc	ra,0xffffe
    80002862:	ce6080e7          	jalr	-794(ra) # 80000544 <panic>
			fileclose(f);
    80002866:	00002097          	auipc	ra,0x2
    8000286a:	57c080e7          	jalr	1404(ra) # 80004de2 <fileclose>
			p->ofile[fd] = 0;
    8000286e:	0004b023          	sd	zero,0(s1)
	for (int fd = 0; fd < NOFILE; fd++)
    80002872:	04a1                	addi	s1,s1,8
    80002874:	01248563          	beq	s1,s2,8000287e <exit+0x58>
		if (p->ofile[fd])
    80002878:	6088                	ld	a0,0(s1)
    8000287a:	f575                	bnez	a0,80002866 <exit+0x40>
    8000287c:	bfdd                	j	80002872 <exit+0x4c>
	begin_op();
    8000287e:	00002097          	auipc	ra,0x2
    80002882:	098080e7          	jalr	152(ra) # 80004916 <begin_op>
	iput(p->cwd);
    80002886:	1589b503          	ld	a0,344(s3)
    8000288a:	00002097          	auipc	ra,0x2
    8000288e:	884080e7          	jalr	-1916(ra) # 8000410e <iput>
	end_op();
    80002892:	00002097          	auipc	ra,0x2
    80002896:	104080e7          	jalr	260(ra) # 80004996 <end_op>
	p->cwd = 0;
    8000289a:	1409bc23          	sd	zero,344(s3)
	acquire(&wait_lock);
    8000289e:	0022e497          	auipc	s1,0x22e
    800028a2:	60248493          	addi	s1,s1,1538 # 80230ea0 <wait_lock>
    800028a6:	8526                	mv	a0,s1
    800028a8:	ffffe097          	auipc	ra,0xffffe
    800028ac:	500080e7          	jalr	1280(ra) # 80000da8 <acquire>
	reparent(p);
    800028b0:	854e                	mv	a0,s3
    800028b2:	00000097          	auipc	ra,0x0
    800028b6:	f1a080e7          	jalr	-230(ra) # 800027cc <reparent>
	wakeup(p->parent);
    800028ba:	0409b503          	ld	a0,64(s3)
    800028be:	00000097          	auipc	ra,0x0
    800028c2:	e68080e7          	jalr	-408(ra) # 80002726 <wakeup>
	acquire(&p->lock);
    800028c6:	00898513          	addi	a0,s3,8
    800028ca:	ffffe097          	auipc	ra,0xffffe
    800028ce:	4de080e7          	jalr	1246(ra) # 80000da8 <acquire>
	p->xstate = status;
    800028d2:	0349aa23          	sw	s4,52(s3)
	p->state = ZOMBIE;
    800028d6:	4795                	li	a5,5
    800028d8:	02f9a023          	sw	a5,32(s3)
	p->endTime = ticks;
    800028dc:	00006797          	auipc	a5,0x6
    800028e0:	3247a783          	lw	a5,804(a5) # 80008c00 <ticks>
    800028e4:	18f9a223          	sw	a5,388(s3)
	release(&wait_lock);
    800028e8:	8526                	mv	a0,s1
    800028ea:	ffffe097          	auipc	ra,0xffffe
    800028ee:	572080e7          	jalr	1394(ra) # 80000e5c <release>
	sched();
    800028f2:	00000097          	auipc	ra,0x0
    800028f6:	a18080e7          	jalr	-1512(ra) # 8000230a <sched>
	panic("zombie exit");
    800028fa:	00006517          	auipc	a0,0x6
    800028fe:	9be50513          	addi	a0,a0,-1602 # 800082b8 <digits+0x278>
    80002902:	ffffe097          	auipc	ra,0xffffe
    80002906:	c42080e7          	jalr	-958(ra) # 80000544 <panic>

000000008000290a <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    8000290a:	7179                	addi	sp,sp,-48
    8000290c:	f406                	sd	ra,40(sp)
    8000290e:	f022                	sd	s0,32(sp)
    80002910:	ec26                	sd	s1,24(sp)
    80002912:	e84a                	sd	s2,16(sp)
    80002914:	e44e                	sd	s3,8(sp)
    80002916:	e052                	sd	s4,0(sp)
    80002918:	1800                	addi	s0,sp,48
    8000291a:	89aa                	mv	s3,a0
	struct proc *p;

	for (p = proc; p < &proc[NPROC]; p++)
    8000291c:	0022f497          	auipc	s1,0x22f
    80002920:	99c48493          	addi	s1,s1,-1636 # 802312b8 <proc>
    80002924:	00236a17          	auipc	s4,0x236
    80002928:	d94a0a13          	addi	s4,s4,-620 # 802386b8 <tickslock>
	{
		acquire(&p->lock);
    8000292c:	00848913          	addi	s2,s1,8
    80002930:	854a                	mv	a0,s2
    80002932:	ffffe097          	auipc	ra,0xffffe
    80002936:	476080e7          	jalr	1142(ra) # 80000da8 <acquire>
		if (p->pid == pid)
    8000293a:	5c9c                	lw	a5,56(s1)
    8000293c:	01378d63          	beq	a5,s3,80002956 <kill+0x4c>
#endif
			}
			release(&p->lock);
			return 0;
		}
		release(&p->lock);
    80002940:	854a                	mv	a0,s2
    80002942:	ffffe097          	auipc	ra,0xffffe
    80002946:	51a080e7          	jalr	1306(ra) # 80000e5c <release>
	for (p = proc; p < &proc[NPROC]; p++)
    8000294a:	1d048493          	addi	s1,s1,464
    8000294e:	fd449fe3          	bne	s1,s4,8000292c <kill+0x22>
	}
	return -1;
    80002952:	557d                	li	a0,-1
    80002954:	a829                	j	8000296e <kill+0x64>
			p->killed = 1;
    80002956:	4785                	li	a5,1
    80002958:	d89c                	sw	a5,48(s1)
			if (p->state == SLEEPING)
    8000295a:	5098                	lw	a4,32(s1)
    8000295c:	4789                	li	a5,2
    8000295e:	02f70063          	beq	a4,a5,8000297e <kill+0x74>
			release(&p->lock);
    80002962:	854a                	mv	a0,s2
    80002964:	ffffe097          	auipc	ra,0xffffe
    80002968:	4f8080e7          	jalr	1272(ra) # 80000e5c <release>
			return 0;
    8000296c:	4501                	li	a0,0
}
    8000296e:	70a2                	ld	ra,40(sp)
    80002970:	7402                	ld	s0,32(sp)
    80002972:	64e2                	ld	s1,24(sp)
    80002974:	6942                	ld	s2,16(sp)
    80002976:	69a2                	ld	s3,8(sp)
    80002978:	6a02                	ld	s4,0(sp)
    8000297a:	6145                	addi	sp,sp,48
    8000297c:	8082                	ret
				p->sleepTimePrev = ticks - p->sleepStartTime;
    8000297e:	1904a703          	lw	a4,400(s1)
    80002982:	00006797          	auipc	a5,0x6
    80002986:	27e7a783          	lw	a5,638(a5) # 80008c00 <ticks>
    8000298a:	9f99                	subw	a5,a5,a4
    8000298c:	18f4a623          	sw	a5,396(s1)
				p->state = RUNNABLE;
    80002990:	478d                	li	a5,3
    80002992:	d09c                	sw	a5,32(s1)
    80002994:	b7f9                	j	80002962 <kill+0x58>

0000000080002996 <setkilled>:

void setkilled(struct proc *p)
{
    80002996:	1101                	addi	sp,sp,-32
    80002998:	ec06                	sd	ra,24(sp)
    8000299a:	e822                	sd	s0,16(sp)
    8000299c:	e426                	sd	s1,8(sp)
    8000299e:	e04a                	sd	s2,0(sp)
    800029a0:	1000                	addi	s0,sp,32
    800029a2:	84aa                	mv	s1,a0
	acquire(&p->lock);
    800029a4:	00850913          	addi	s2,a0,8
    800029a8:	854a                	mv	a0,s2
    800029aa:	ffffe097          	auipc	ra,0xffffe
    800029ae:	3fe080e7          	jalr	1022(ra) # 80000da8 <acquire>
	p->killed = 1;
    800029b2:	4785                	li	a5,1
    800029b4:	d89c                	sw	a5,48(s1)
	release(&p->lock);
    800029b6:	854a                	mv	a0,s2
    800029b8:	ffffe097          	auipc	ra,0xffffe
    800029bc:	4a4080e7          	jalr	1188(ra) # 80000e5c <release>
}
    800029c0:	60e2                	ld	ra,24(sp)
    800029c2:	6442                	ld	s0,16(sp)
    800029c4:	64a2                	ld	s1,8(sp)
    800029c6:	6902                	ld	s2,0(sp)
    800029c8:	6105                	addi	sp,sp,32
    800029ca:	8082                	ret

00000000800029cc <killed>:

int killed(struct proc *p)
{
    800029cc:	1101                	addi	sp,sp,-32
    800029ce:	ec06                	sd	ra,24(sp)
    800029d0:	e822                	sd	s0,16(sp)
    800029d2:	e426                	sd	s1,8(sp)
    800029d4:	e04a                	sd	s2,0(sp)
    800029d6:	1000                	addi	s0,sp,32
    800029d8:	84aa                	mv	s1,a0
	int k;

	acquire(&p->lock);
    800029da:	00850913          	addi	s2,a0,8
    800029de:	854a                	mv	a0,s2
    800029e0:	ffffe097          	auipc	ra,0xffffe
    800029e4:	3c8080e7          	jalr	968(ra) # 80000da8 <acquire>
	k = p->killed;
    800029e8:	5884                	lw	s1,48(s1)
	release(&p->lock);
    800029ea:	854a                	mv	a0,s2
    800029ec:	ffffe097          	auipc	ra,0xffffe
    800029f0:	470080e7          	jalr	1136(ra) # 80000e5c <release>
	return k;
}
    800029f4:	8526                	mv	a0,s1
    800029f6:	60e2                	ld	ra,24(sp)
    800029f8:	6442                	ld	s0,16(sp)
    800029fa:	64a2                	ld	s1,8(sp)
    800029fc:	6902                	ld	s2,0(sp)
    800029fe:	6105                	addi	sp,sp,32
    80002a00:	8082                	ret

0000000080002a02 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002a02:	7179                	addi	sp,sp,-48
    80002a04:	f406                	sd	ra,40(sp)
    80002a06:	f022                	sd	s0,32(sp)
    80002a08:	ec26                	sd	s1,24(sp)
    80002a0a:	e84a                	sd	s2,16(sp)
    80002a0c:	e44e                	sd	s3,8(sp)
    80002a0e:	e052                	sd	s4,0(sp)
    80002a10:	1800                	addi	s0,sp,48
    80002a12:	84aa                	mv	s1,a0
    80002a14:	892e                	mv	s2,a1
    80002a16:	89b2                	mv	s3,a2
    80002a18:	8a36                	mv	s4,a3
	struct proc *p = myproc();
    80002a1a:	fffff097          	auipc	ra,0xfffff
    80002a1e:	29e080e7          	jalr	670(ra) # 80001cb8 <myproc>
	if (user_dst)
    80002a22:	c08d                	beqz	s1,80002a44 <either_copyout+0x42>
	{
		return copyout(p->pagetable, dst, src, len);
    80002a24:	86d2                	mv	a3,s4
    80002a26:	864e                	mv	a2,s3
    80002a28:	85ca                	mv	a1,s2
    80002a2a:	6d28                	ld	a0,88(a0)
    80002a2c:	fffff097          	auipc	ra,0xfffff
    80002a30:	e0c080e7          	jalr	-500(ra) # 80001838 <copyout>
	else
	{
		memmove((char *)dst, src, len);
		return 0;
	}
}
    80002a34:	70a2                	ld	ra,40(sp)
    80002a36:	7402                	ld	s0,32(sp)
    80002a38:	64e2                	ld	s1,24(sp)
    80002a3a:	6942                	ld	s2,16(sp)
    80002a3c:	69a2                	ld	s3,8(sp)
    80002a3e:	6a02                	ld	s4,0(sp)
    80002a40:	6145                	addi	sp,sp,48
    80002a42:	8082                	ret
		memmove((char *)dst, src, len);
    80002a44:	000a061b          	sext.w	a2,s4
    80002a48:	85ce                	mv	a1,s3
    80002a4a:	854a                	mv	a0,s2
    80002a4c:	ffffe097          	auipc	ra,0xffffe
    80002a50:	4b8080e7          	jalr	1208(ra) # 80000f04 <memmove>
		return 0;
    80002a54:	8526                	mv	a0,s1
    80002a56:	bff9                	j	80002a34 <either_copyout+0x32>

0000000080002a58 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002a58:	7179                	addi	sp,sp,-48
    80002a5a:	f406                	sd	ra,40(sp)
    80002a5c:	f022                	sd	s0,32(sp)
    80002a5e:	ec26                	sd	s1,24(sp)
    80002a60:	e84a                	sd	s2,16(sp)
    80002a62:	e44e                	sd	s3,8(sp)
    80002a64:	e052                	sd	s4,0(sp)
    80002a66:	1800                	addi	s0,sp,48
    80002a68:	892a                	mv	s2,a0
    80002a6a:	84ae                	mv	s1,a1
    80002a6c:	89b2                	mv	s3,a2
    80002a6e:	8a36                	mv	s4,a3
	struct proc *p = myproc();
    80002a70:	fffff097          	auipc	ra,0xfffff
    80002a74:	248080e7          	jalr	584(ra) # 80001cb8 <myproc>
	if (user_src)
    80002a78:	c08d                	beqz	s1,80002a9a <either_copyin+0x42>
	{
		return copyin(p->pagetable, dst, src, len);
    80002a7a:	86d2                	mv	a3,s4
    80002a7c:	864e                	mv	a2,s3
    80002a7e:	85ca                	mv	a1,s2
    80002a80:	6d28                	ld	a0,88(a0)
    80002a82:	fffff097          	auipc	ra,0xfffff
    80002a86:	e76080e7          	jalr	-394(ra) # 800018f8 <copyin>
	else
	{
		memmove(dst, (char *)src, len);
		return 0;
	}
}
    80002a8a:	70a2                	ld	ra,40(sp)
    80002a8c:	7402                	ld	s0,32(sp)
    80002a8e:	64e2                	ld	s1,24(sp)
    80002a90:	6942                	ld	s2,16(sp)
    80002a92:	69a2                	ld	s3,8(sp)
    80002a94:	6a02                	ld	s4,0(sp)
    80002a96:	6145                	addi	sp,sp,48
    80002a98:	8082                	ret
		memmove(dst, (char *)src, len);
    80002a9a:	000a061b          	sext.w	a2,s4
    80002a9e:	85ce                	mv	a1,s3
    80002aa0:	854a                	mv	a0,s2
    80002aa2:	ffffe097          	auipc	ra,0xffffe
    80002aa6:	462080e7          	jalr	1122(ra) # 80000f04 <memmove>
		return 0;
    80002aaa:	8526                	mv	a0,s1
    80002aac:	bff9                	j	80002a8a <either_copyin+0x32>

0000000080002aae <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck mastatechine further.
void procdump(void)
{
    80002aae:	715d                	addi	sp,sp,-80
    80002ab0:	e486                	sd	ra,72(sp)
    80002ab2:	e0a2                	sd	s0,64(sp)
    80002ab4:	fc26                	sd	s1,56(sp)
    80002ab6:	f84a                	sd	s2,48(sp)
    80002ab8:	f44e                	sd	s3,40(sp)
    80002aba:	f052                	sd	s4,32(sp)
    80002abc:	ec56                	sd	s5,24(sp)
    80002abe:	e85a                	sd	s6,16(sp)
    80002ac0:	e45e                	sd	s7,8(sp)
    80002ac2:	0880                	addi	s0,sp,80
		[RUNNING] "run   ",
		[ZOMBIE] "zombie"};
	struct proc *p;
	char *state;

	printf("\n");
    80002ac4:	00005517          	auipc	a0,0x5
    80002ac8:	63450513          	addi	a0,a0,1588 # 800080f8 <digits+0xb8>
    80002acc:	ffffe097          	auipc	ra,0xffffe
    80002ad0:	ac2080e7          	jalr	-1342(ra) # 8000058e <printf>
	for (p = proc; p < &proc[NPROC]; p++)
    80002ad4:	0022f497          	auipc	s1,0x22f
    80002ad8:	94448493          	addi	s1,s1,-1724 # 80231418 <proc+0x160>
    80002adc:	00236917          	auipc	s2,0x236
    80002ae0:	d3c90913          	addi	s2,s2,-708 # 80238818 <bcache+0x148>
	{
		if (p->state == UNUSED)
			continue;
		if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002ae4:	4b15                	li	s6,5
			state = states[p->state];
		else
			state = "???";
    80002ae6:	00005997          	auipc	s3,0x5
    80002aea:	7e298993          	addi	s3,s3,2018 # 800082c8 <digits+0x288>
		printf("%d %s %s %d %d", p->pid, state, p->name, p->runTime, p->countTimeCalled);
    80002aee:	00005a97          	auipc	s5,0x5
    80002af2:	7e2a8a93          	addi	s5,s5,2018 # 800082d0 <digits+0x290>
		printf("\n");
    80002af6:	00005a17          	auipc	s4,0x5
    80002afa:	602a0a13          	addi	s4,s4,1538 # 800080f8 <digits+0xb8>
		if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002afe:	00006b97          	auipc	s7,0x6
    80002b02:	812b8b93          	addi	s7,s7,-2030 # 80008310 <states.2502>
    80002b06:	a01d                	j	80002b2c <procdump+0x7e>
		printf("%d %s %s %d %d", p->pid, state, p->name, p->runTime, p->countTimeCalled);
    80002b08:	5e9c                	lw	a5,56(a3)
    80002b0a:	5298                	lw	a4,32(a3)
    80002b0c:	ed86a583          	lw	a1,-296(a3)
    80002b10:	8556                	mv	a0,s5
    80002b12:	ffffe097          	auipc	ra,0xffffe
    80002b16:	a7c080e7          	jalr	-1412(ra) # 8000058e <printf>
		printf("\n");
    80002b1a:	8552                	mv	a0,s4
    80002b1c:	ffffe097          	auipc	ra,0xffffe
    80002b20:	a72080e7          	jalr	-1422(ra) # 8000058e <printf>
	for (p = proc; p < &proc[NPROC]; p++)
    80002b24:	1d048493          	addi	s1,s1,464
    80002b28:	03248163          	beq	s1,s2,80002b4a <procdump+0x9c>
		if (p->state == UNUSED)
    80002b2c:	86a6                	mv	a3,s1
    80002b2e:	ec04a783          	lw	a5,-320(s1)
    80002b32:	dbed                	beqz	a5,80002b24 <procdump+0x76>
			state = "???";
    80002b34:	864e                	mv	a2,s3
		if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b36:	fcfb69e3          	bltu	s6,a5,80002b08 <procdump+0x5a>
    80002b3a:	1782                	slli	a5,a5,0x20
    80002b3c:	9381                	srli	a5,a5,0x20
    80002b3e:	078e                	slli	a5,a5,0x3
    80002b40:	97de                	add	a5,a5,s7
    80002b42:	6390                	ld	a2,0(a5)
    80002b44:	f271                	bnez	a2,80002b08 <procdump+0x5a>
			state = "???";
    80002b46:	864e                	mv	a2,s3
    80002b48:	b7c1                	j	80002b08 <procdump+0x5a>
	}
}
    80002b4a:	60a6                	ld	ra,72(sp)
    80002b4c:	6406                	ld	s0,64(sp)
    80002b4e:	74e2                	ld	s1,56(sp)
    80002b50:	7942                	ld	s2,48(sp)
    80002b52:	79a2                	ld	s3,40(sp)
    80002b54:	7a02                	ld	s4,32(sp)
    80002b56:	6ae2                	ld	s5,24(sp)
    80002b58:	6b42                	ld	s6,16(sp)
    80002b5a:	6ba2                	ld	s7,8(sp)
    80002b5c:	6161                	addi	sp,sp,80
    80002b5e:	8082                	ret

0000000080002b60 <swtch>:
    80002b60:	00153023          	sd	ra,0(a0)
    80002b64:	00253423          	sd	sp,8(a0)
    80002b68:	e900                	sd	s0,16(a0)
    80002b6a:	ed04                	sd	s1,24(a0)
    80002b6c:	03253023          	sd	s2,32(a0)
    80002b70:	03353423          	sd	s3,40(a0)
    80002b74:	03453823          	sd	s4,48(a0)
    80002b78:	03553c23          	sd	s5,56(a0)
    80002b7c:	05653023          	sd	s6,64(a0)
    80002b80:	05753423          	sd	s7,72(a0)
    80002b84:	05853823          	sd	s8,80(a0)
    80002b88:	05953c23          	sd	s9,88(a0)
    80002b8c:	07a53023          	sd	s10,96(a0)
    80002b90:	07b53423          	sd	s11,104(a0)
    80002b94:	0005b083          	ld	ra,0(a1)
    80002b98:	0085b103          	ld	sp,8(a1)
    80002b9c:	6980                	ld	s0,16(a1)
    80002b9e:	6d84                	ld	s1,24(a1)
    80002ba0:	0205b903          	ld	s2,32(a1)
    80002ba4:	0285b983          	ld	s3,40(a1)
    80002ba8:	0305ba03          	ld	s4,48(a1)
    80002bac:	0385ba83          	ld	s5,56(a1)
    80002bb0:	0405bb03          	ld	s6,64(a1)
    80002bb4:	0485bb83          	ld	s7,72(a1)
    80002bb8:	0505bc03          	ld	s8,80(a1)
    80002bbc:	0585bc83          	ld	s9,88(a1)
    80002bc0:	0605bd03          	ld	s10,96(a1)
    80002bc4:	0685bd83          	ld	s11,104(a1)
    80002bc8:	8082                	ret

0000000080002bca <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002bca:	1141                	addi	sp,sp,-16
    80002bcc:	e406                	sd	ra,8(sp)
    80002bce:	e022                	sd	s0,0(sp)
    80002bd0:	0800                	addi	s0,sp,16
	initlock(&tickslock, "time");
    80002bd2:	00005597          	auipc	a1,0x5
    80002bd6:	76e58593          	addi	a1,a1,1902 # 80008340 <states.2502+0x30>
    80002bda:	00236517          	auipc	a0,0x236
    80002bde:	ade50513          	addi	a0,a0,-1314 # 802386b8 <tickslock>
    80002be2:	ffffe097          	auipc	ra,0xffffe
    80002be6:	136080e7          	jalr	310(ra) # 80000d18 <initlock>
}
    80002bea:	60a2                	ld	ra,8(sp)
    80002bec:	6402                	ld	s0,0(sp)
    80002bee:	0141                	addi	sp,sp,16
    80002bf0:	8082                	ret

0000000080002bf2 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002bf2:	1141                	addi	sp,sp,-16
    80002bf4:	e422                	sd	s0,8(sp)
    80002bf6:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002bf8:	00004797          	auipc	a5,0x4
    80002bfc:	82878793          	addi	a5,a5,-2008 # 80006420 <kernelvec>
    80002c00:	10579073          	csrw	stvec,a5
	w_stvec((uint64)kernelvec);
}
    80002c04:	6422                	ld	s0,8(sp)
    80002c06:	0141                	addi	sp,sp,16
    80002c08:	8082                	ret

0000000080002c0a <cowalloc>:
{
	// ** va must be PGSIZE aligned
	// if ((va % PGSIZE) != 0)
	// 	return -1;

	if (va == 0)
    80002c0a:	fff58713          	addi	a4,a1,-1
    80002c0e:	f80007b7          	lui	a5,0xf8000
    80002c12:	83e9                	srli	a5,a5,0x1a
    80002c14:	06e7ef63          	bltu	a5,a4,80002c92 <cowalloc+0x88>
{
    80002c18:	7179                	addi	sp,sp,-48
    80002c1a:	f406                	sd	ra,40(sp)
    80002c1c:	f022                	sd	s0,32(sp)
    80002c1e:	ec26                	sd	s1,24(sp)
    80002c20:	e84a                	sd	s2,16(sp)
    80002c22:	e44e                	sd	s3,8(sp)
    80002c24:	1800                	addi	s0,sp,48

	// ** safety check
	if (va >= MAXVA)
		return -1;

	pte_t *pte = walk(pagetable, va, 0);
    80002c26:	4601                	li	a2,0
    80002c28:	ffffe097          	auipc	ra,0xffffe
    80002c2c:	568080e7          	jalr	1384(ra) # 80001190 <walk>
    80002c30:	84aa                	mv	s1,a0
	if (pte == 0)
    80002c32:	c135                	beqz	a0,80002c96 <cowalloc+0x8c>
		return -1;
	if ((*pte & PTE_U) == 0 || (*pte & PTE_V) == 0)
    80002c34:	00053903          	ld	s2,0(a0)
    80002c38:	01197713          	andi	a4,s2,17
    80002c3c:	47c5                	li	a5,17
    80002c3e:	04f71e63          	bne	a4,a5,80002c9a <cowalloc+0x90>

	// printf("here\n");

	// ** If page fault is raised with a COW page,
	// ** alloc a physical page, mapped to user pagetable and set PTE_W
	if (*pte & PTE_C)
    80002c42:	10097793          	andi	a5,s2,256
		krefdecr(pa);
		// kfree((void *)pa);
		return 0;
	}

	return 0;
    80002c46:	4501                	li	a0,0
	if (*pte & PTE_C)
    80002c48:	eb81                	bnez	a5,80002c58 <cowalloc+0x4e>
}
    80002c4a:	70a2                	ld	ra,40(sp)
    80002c4c:	7402                	ld	s0,32(sp)
    80002c4e:	64e2                	ld	s1,24(sp)
    80002c50:	6942                	ld	s2,16(sp)
    80002c52:	69a2                	ld	s3,8(sp)
    80002c54:	6145                	addi	sp,sp,48
    80002c56:	8082                	ret
		uint64 ka = (uint64)kalloc();
    80002c58:	ffffe097          	auipc	ra,0xffffe
    80002c5c:	01c080e7          	jalr	28(ra) # 80000c74 <kalloc>
    80002c60:	89aa                	mv	s3,a0
		if (ka == 0)
    80002c62:	cd15                	beqz	a0,80002c9e <cowalloc+0x94>
	uint64 pa = PTE2PA(*pte);
    80002c64:	00a95913          	srli	s2,s2,0xa
    80002c68:	0932                	slli	s2,s2,0xc
		memmove((void *)ka, (void *)pa, PGSIZE);
    80002c6a:	6605                	lui	a2,0x1
    80002c6c:	85ca                	mv	a1,s2
    80002c6e:	ffffe097          	auipc	ra,0xffffe
    80002c72:	296080e7          	jalr	662(ra) # 80000f04 <memmove>
		*pte = PA2PTE(ka) | PTE_U | PTE_V | PTE_W | PTE_X | PTE_R;
    80002c76:	00c9d993          	srli	s3,s3,0xc
    80002c7a:	09aa                	slli	s3,s3,0xa
    80002c7c:	01f9e993          	ori	s3,s3,31
    80002c80:	0134b023          	sd	s3,0(s1)
		krefdecr(pa);
    80002c84:	854a                	mv	a0,s2
    80002c86:	ffffe097          	auipc	ra,0xffffe
    80002c8a:	de0080e7          	jalr	-544(ra) # 80000a66 <krefdecr>
		return 0;
    80002c8e:	4501                	li	a0,0
    80002c90:	bf6d                	j	80002c4a <cowalloc+0x40>
		return -1;
    80002c92:	557d                	li	a0,-1
}
    80002c94:	8082                	ret
		return -1;
    80002c96:	557d                	li	a0,-1
    80002c98:	bf4d                	j	80002c4a <cowalloc+0x40>
		return -1;
    80002c9a:	557d                	li	a0,-1
    80002c9c:	b77d                	j	80002c4a <cowalloc+0x40>
			return -1;
    80002c9e:	557d                	li	a0,-1
    80002ca0:	b76d                	j	80002c4a <cowalloc+0x40>

0000000080002ca2 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80002ca2:	1141                	addi	sp,sp,-16
    80002ca4:	e406                	sd	ra,8(sp)
    80002ca6:	e022                	sd	s0,0(sp)
    80002ca8:	0800                	addi	s0,sp,16
	struct proc *p = myproc();
    80002caa:	fffff097          	auipc	ra,0xfffff
    80002cae:	00e080e7          	jalr	14(ra) # 80001cb8 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cb2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002cb6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002cb8:	10079073          	csrw	sstatus,a5
	// kerneltrap() to usertrap(), so turn off interrupts until
	// we're back in user space, where usertrap() is correct.
	intr_off();

	// send syscalls, interrupts, and exceptions to uservec in trampoline.S
	uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002cbc:	00004617          	auipc	a2,0x4
    80002cc0:	34460613          	addi	a2,a2,836 # 80007000 <_trampoline>
    80002cc4:	00004697          	auipc	a3,0x4
    80002cc8:	33c68693          	addi	a3,a3,828 # 80007000 <_trampoline>
    80002ccc:	8e91                	sub	a3,a3,a2
    80002cce:	040007b7          	lui	a5,0x4000
    80002cd2:	17fd                	addi	a5,a5,-1
    80002cd4:	07b2                	slli	a5,a5,0xc
    80002cd6:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002cd8:	10569073          	csrw	stvec,a3
	w_stvec(trampoline_uservec);

	// set up trapframe values that uservec will need when
	// the process next traps into the kernel.
	p->trapframe->kernel_satp = r_satp();		  // kernel page table
    80002cdc:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002cde:	180026f3          	csrr	a3,satp
    80002ce2:	e314                	sd	a3,0(a4)
	p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002ce4:	7138                	ld	a4,96(a0)
    80002ce6:	6534                	ld	a3,72(a0)
    80002ce8:	6585                	lui	a1,0x1
    80002cea:	96ae                	add	a3,a3,a1
    80002cec:	e714                	sd	a3,8(a4)
	p->trapframe->kernel_trap = (uint64)usertrap;
    80002cee:	7138                	ld	a4,96(a0)
    80002cf0:	00000697          	auipc	a3,0x0
    80002cf4:	13e68693          	addi	a3,a3,318 # 80002e2e <usertrap>
    80002cf8:	eb14                	sd	a3,16(a4)
	p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002cfa:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002cfc:	8692                	mv	a3,tp
    80002cfe:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d00:	100026f3          	csrr	a3,sstatus
	// set up the registers that trampoline.S's sret will use
	// to get to user space.

	// set S Previous Privilege mode to User.
	unsigned long x = r_sstatus();
	x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002d04:	eff6f693          	andi	a3,a3,-257
	x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002d08:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d0c:	10069073          	csrw	sstatus,a3
	w_sstatus(x);

	// set S Exception Program Counter to the saved user pc.
	w_sepc(p->trapframe->epc);
    80002d10:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002d12:	6f18                	ld	a4,24(a4)
    80002d14:	14171073          	csrw	sepc,a4

	// tell trampoline.S the user page table to switch to.
	uint64 satp = MAKE_SATP(p->pagetable);
    80002d18:	6d28                	ld	a0,88(a0)
    80002d1a:	8131                	srli	a0,a0,0xc

	// jump to userret in trampoline.S at the top of memory, which
	// switches to the user page table, restores user registers,
	// and switches to user mode with sret.
	uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002d1c:	00004717          	auipc	a4,0x4
    80002d20:	38070713          	addi	a4,a4,896 # 8000709c <userret>
    80002d24:	8f11                	sub	a4,a4,a2
    80002d26:	97ba                	add	a5,a5,a4
	((void (*)(uint64))trampoline_userret)(satp);
    80002d28:	577d                	li	a4,-1
    80002d2a:	177e                	slli	a4,a4,0x3f
    80002d2c:	8d59                	or	a0,a0,a4
    80002d2e:	9782                	jalr	a5
}
    80002d30:	60a2                	ld	ra,8(sp)
    80002d32:	6402                	ld	s0,0(sp)
    80002d34:	0141                	addi	sp,sp,16
    80002d36:	8082                	ret

0000000080002d38 <clockintr>:
	w_sepc(sepc);
	w_sstatus(sstatus);
}

void clockintr()
{
    80002d38:	1101                	addi	sp,sp,-32
    80002d3a:	ec06                	sd	ra,24(sp)
    80002d3c:	e822                	sd	s0,16(sp)
    80002d3e:	e426                	sd	s1,8(sp)
    80002d40:	e04a                	sd	s2,0(sp)
    80002d42:	1000                	addi	s0,sp,32
	acquire(&tickslock);
    80002d44:	00236917          	auipc	s2,0x236
    80002d48:	97490913          	addi	s2,s2,-1676 # 802386b8 <tickslock>
    80002d4c:	854a                	mv	a0,s2
    80002d4e:	ffffe097          	auipc	ra,0xffffe
    80002d52:	05a080e7          	jalr	90(ra) # 80000da8 <acquire>
	ticks++;
    80002d56:	00006497          	auipc	s1,0x6
    80002d5a:	eaa48493          	addi	s1,s1,-342 # 80008c00 <ticks>
    80002d5e:	409c                	lw	a5,0(s1)
    80002d60:	2785                	addiw	a5,a5,1
    80002d62:	c09c                	sw	a5,0(s1)
	upd_time();
    80002d64:	fffff097          	auipc	ra,0xfffff
    80002d68:	492080e7          	jalr	1170(ra) # 800021f6 <upd_time>
	wakeup(&ticks);
    80002d6c:	8526                	mv	a0,s1
    80002d6e:	00000097          	auipc	ra,0x0
    80002d72:	9b8080e7          	jalr	-1608(ra) # 80002726 <wakeup>
	release(&tickslock);
    80002d76:	854a                	mv	a0,s2
    80002d78:	ffffe097          	auipc	ra,0xffffe
    80002d7c:	0e4080e7          	jalr	228(ra) # 80000e5c <release>
}
    80002d80:	60e2                	ld	ra,24(sp)
    80002d82:	6442                	ld	s0,16(sp)
    80002d84:	64a2                	ld	s1,8(sp)
    80002d86:	6902                	ld	s2,0(sp)
    80002d88:	6105                	addi	sp,sp,32
    80002d8a:	8082                	ret

0000000080002d8c <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    80002d8c:	1101                	addi	sp,sp,-32
    80002d8e:	ec06                	sd	ra,24(sp)
    80002d90:	e822                	sd	s0,16(sp)
    80002d92:	e426                	sd	s1,8(sp)
    80002d94:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d96:	14202773          	csrr	a4,scause
	uint64 scause = r_scause();

	if ((scause & 0x8000000000000000L) &&
    80002d9a:	00074d63          	bltz	a4,80002db4 <devintr+0x28>
		if (irq)
			plic_complete(irq);

		return 1;
	}
	else if (scause == 0x8000000000000001L)
    80002d9e:	57fd                	li	a5,-1
    80002da0:	17fe                	slli	a5,a5,0x3f
    80002da2:	0785                	addi	a5,a5,1

		return 2;
	}
	else
	{
		return 0;
    80002da4:	4501                	li	a0,0
	else if (scause == 0x8000000000000001L)
    80002da6:	06f70363          	beq	a4,a5,80002e0c <devintr+0x80>
	}
}
    80002daa:	60e2                	ld	ra,24(sp)
    80002dac:	6442                	ld	s0,16(sp)
    80002dae:	64a2                	ld	s1,8(sp)
    80002db0:	6105                	addi	sp,sp,32
    80002db2:	8082                	ret
		(scause & 0xff) == 9)
    80002db4:	0ff77793          	andi	a5,a4,255
	if ((scause & 0x8000000000000000L) &&
    80002db8:	46a5                	li	a3,9
    80002dba:	fed792e3          	bne	a5,a3,80002d9e <devintr+0x12>
		int irq = plic_claim();
    80002dbe:	00003097          	auipc	ra,0x3
    80002dc2:	76a080e7          	jalr	1898(ra) # 80006528 <plic_claim>
    80002dc6:	84aa                	mv	s1,a0
		if (irq == UART0_IRQ)
    80002dc8:	47a9                	li	a5,10
    80002dca:	02f50763          	beq	a0,a5,80002df8 <devintr+0x6c>
		else if (irq == VIRTIO0_IRQ)
    80002dce:	4785                	li	a5,1
    80002dd0:	02f50963          	beq	a0,a5,80002e02 <devintr+0x76>
		return 1;
    80002dd4:	4505                	li	a0,1
		else if (irq)
    80002dd6:	d8f1                	beqz	s1,80002daa <devintr+0x1e>
			printf("unexpected interrupt irq=%d\n", irq);
    80002dd8:	85a6                	mv	a1,s1
    80002dda:	00005517          	auipc	a0,0x5
    80002dde:	56e50513          	addi	a0,a0,1390 # 80008348 <states.2502+0x38>
    80002de2:	ffffd097          	auipc	ra,0xffffd
    80002de6:	7ac080e7          	jalr	1964(ra) # 8000058e <printf>
			plic_complete(irq);
    80002dea:	8526                	mv	a0,s1
    80002dec:	00003097          	auipc	ra,0x3
    80002df0:	760080e7          	jalr	1888(ra) # 8000654c <plic_complete>
		return 1;
    80002df4:	4505                	li	a0,1
    80002df6:	bf55                	j	80002daa <devintr+0x1e>
			uartintr();
    80002df8:	ffffe097          	auipc	ra,0xffffe
    80002dfc:	bb6080e7          	jalr	-1098(ra) # 800009ae <uartintr>
    80002e00:	b7ed                	j	80002dea <devintr+0x5e>
			virtio_disk_intr();
    80002e02:	00004097          	auipc	ra,0x4
    80002e06:	c74080e7          	jalr	-908(ra) # 80006a76 <virtio_disk_intr>
    80002e0a:	b7c5                	j	80002dea <devintr+0x5e>
		if (cpuid() == 0)
    80002e0c:	fffff097          	auipc	ra,0xfffff
    80002e10:	e80080e7          	jalr	-384(ra) # 80001c8c <cpuid>
    80002e14:	c901                	beqz	a0,80002e24 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002e16:	144027f3          	csrr	a5,sip
		w_sip(r_sip() & ~2);
    80002e1a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002e1c:	14479073          	csrw	sip,a5
		return 2;
    80002e20:	4509                	li	a0,2
    80002e22:	b761                	j	80002daa <devintr+0x1e>
			clockintr();
    80002e24:	00000097          	auipc	ra,0x0
    80002e28:	f14080e7          	jalr	-236(ra) # 80002d38 <clockintr>
    80002e2c:	b7ed                	j	80002e16 <devintr+0x8a>

0000000080002e2e <usertrap>:
{
    80002e2e:	1101                	addi	sp,sp,-32
    80002e30:	ec06                	sd	ra,24(sp)
    80002e32:	e822                	sd	s0,16(sp)
    80002e34:	e426                	sd	s1,8(sp)
    80002e36:	e04a                	sd	s2,0(sp)
    80002e38:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e3a:	100027f3          	csrr	a5,sstatus
	if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002e3e:	1007f793          	andi	a5,a5,256
    80002e42:	e7b9                	bnez	a5,80002e90 <usertrap+0x62>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002e44:	00003797          	auipc	a5,0x3
    80002e48:	5dc78793          	addi	a5,a5,1500 # 80006420 <kernelvec>
    80002e4c:	10579073          	csrw	stvec,a5
	struct proc *p = myproc();
    80002e50:	fffff097          	auipc	ra,0xfffff
    80002e54:	e68080e7          	jalr	-408(ra) # 80001cb8 <myproc>
    80002e58:	84aa                	mv	s1,a0
	p->trapframe->epc = r_sepc();
    80002e5a:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e5c:	14102773          	csrr	a4,sepc
    80002e60:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e62:	14202773          	csrr	a4,scause
	if (r_scause() == 8)
    80002e66:	47a1                	li	a5,8
    80002e68:	02f70c63          	beq	a4,a5,80002ea0 <usertrap+0x72>
    80002e6c:	14202773          	csrr	a4,scause
	else if (r_scause() == 15)
    80002e70:	47bd                	li	a5,15
    80002e72:	06f70d63          	beq	a4,a5,80002eec <usertrap+0xbe>
	else if ((which_dev = devintr()) != 0)
    80002e76:	00000097          	auipc	ra,0x0
    80002e7a:	f16080e7          	jalr	-234(ra) # 80002d8c <devintr>
    80002e7e:	892a                	mv	s2,a0
    80002e80:	c549                	beqz	a0,80002f0a <usertrap+0xdc>
	if (killed(p))
    80002e82:	8526                	mv	a0,s1
    80002e84:	00000097          	auipc	ra,0x0
    80002e88:	b48080e7          	jalr	-1208(ra) # 800029cc <killed>
    80002e8c:	c171                	beqz	a0,80002f50 <usertrap+0x122>
    80002e8e:	a865                	j	80002f46 <usertrap+0x118>
		panic("usertrap: not from user mode");
    80002e90:	00005517          	auipc	a0,0x5
    80002e94:	4d850513          	addi	a0,a0,1240 # 80008368 <states.2502+0x58>
    80002e98:	ffffd097          	auipc	ra,0xffffd
    80002e9c:	6ac080e7          	jalr	1708(ra) # 80000544 <panic>
		if (p->killed)
    80002ea0:	591c                	lw	a5,48(a0)
    80002ea2:	ef9d                	bnez	a5,80002ee0 <usertrap+0xb2>
		p->trapframe->epc += 4;
    80002ea4:	70b8                	ld	a4,96(s1)
    80002ea6:	6f1c                	ld	a5,24(a4)
    80002ea8:	0791                	addi	a5,a5,4
    80002eaa:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002eac:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002eb0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002eb4:	10079073          	csrw	sstatus,a5
		syscall();
    80002eb8:	00000097          	auipc	ra,0x0
    80002ebc:	2f2080e7          	jalr	754(ra) # 800031aa <syscall>
	if (killed(p))
    80002ec0:	8526                	mv	a0,s1
    80002ec2:	00000097          	auipc	ra,0x0
    80002ec6:	b0a080e7          	jalr	-1270(ra) # 800029cc <killed>
    80002eca:	ed2d                	bnez	a0,80002f44 <usertrap+0x116>
	usertrapret();
    80002ecc:	00000097          	auipc	ra,0x0
    80002ed0:	dd6080e7          	jalr	-554(ra) # 80002ca2 <usertrapret>
}
    80002ed4:	60e2                	ld	ra,24(sp)
    80002ed6:	6442                	ld	s0,16(sp)
    80002ed8:	64a2                	ld	s1,8(sp)
    80002eda:	6902                	ld	s2,0(sp)
    80002edc:	6105                	addi	sp,sp,32
    80002ede:	8082                	ret
			exit(-1);
    80002ee0:	557d                	li	a0,-1
    80002ee2:	00000097          	auipc	ra,0x0
    80002ee6:	944080e7          	jalr	-1724(ra) # 80002826 <exit>
    80002eea:	bf6d                	j	80002ea4 <usertrap+0x76>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002eec:	143025f3          	csrr	a1,stval
		if (cowalloc(p->pagetable, r_stval()) < 0)
    80002ef0:	6d28                	ld	a0,88(a0)
    80002ef2:	00000097          	auipc	ra,0x0
    80002ef6:	d18080e7          	jalr	-744(ra) # 80002c0a <cowalloc>
    80002efa:	fc0553e3          	bgez	a0,80002ec0 <usertrap+0x92>
			setkilled(p);
    80002efe:	8526                	mv	a0,s1
    80002f00:	00000097          	auipc	ra,0x0
    80002f04:	a96080e7          	jalr	-1386(ra) # 80002996 <setkilled>
    80002f08:	bf65                	j	80002ec0 <usertrap+0x92>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f0a:	142025f3          	csrr	a1,scause
		printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002f0e:	5c90                	lw	a2,56(s1)
    80002f10:	00005517          	auipc	a0,0x5
    80002f14:	47850513          	addi	a0,a0,1144 # 80008388 <states.2502+0x78>
    80002f18:	ffffd097          	auipc	ra,0xffffd
    80002f1c:	676080e7          	jalr	1654(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002f20:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002f24:	14302673          	csrr	a2,stval
		printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002f28:	00005517          	auipc	a0,0x5
    80002f2c:	49050513          	addi	a0,a0,1168 # 800083b8 <states.2502+0xa8>
    80002f30:	ffffd097          	auipc	ra,0xffffd
    80002f34:	65e080e7          	jalr	1630(ra) # 8000058e <printf>
		setkilled(p);
    80002f38:	8526                	mv	a0,s1
    80002f3a:	00000097          	auipc	ra,0x0
    80002f3e:	a5c080e7          	jalr	-1444(ra) # 80002996 <setkilled>
    80002f42:	bfbd                	j	80002ec0 <usertrap+0x92>
	if (killed(p))
    80002f44:	4901                	li	s2,0
		exit(-1);
    80002f46:	557d                	li	a0,-1
    80002f48:	00000097          	auipc	ra,0x0
    80002f4c:	8de080e7          	jalr	-1826(ra) # 80002826 <exit>
	if (which_dev == 2)
    80002f50:	4789                	li	a5,2
    80002f52:	f6f91de3          	bne	s2,a5,80002ecc <usertrap+0x9e>
		yield();
    80002f56:	fffff097          	auipc	ra,0xfffff
    80002f5a:	48c080e7          	jalr	1164(ra) # 800023e2 <yield>
    80002f5e:	b7bd                	j	80002ecc <usertrap+0x9e>

0000000080002f60 <kerneltrap>:
{
    80002f60:	7179                	addi	sp,sp,-48
    80002f62:	f406                	sd	ra,40(sp)
    80002f64:	f022                	sd	s0,32(sp)
    80002f66:	ec26                	sd	s1,24(sp)
    80002f68:	e84a                	sd	s2,16(sp)
    80002f6a:	e44e                	sd	s3,8(sp)
    80002f6c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002f6e:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f72:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f76:	142029f3          	csrr	s3,scause
	if ((sstatus & SSTATUS_SPP) == 0)
    80002f7a:	1004f793          	andi	a5,s1,256
    80002f7e:	cb85                	beqz	a5,80002fae <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f80:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002f84:	8b89                	andi	a5,a5,2
	if (intr_get() != 0)
    80002f86:	ef85                	bnez	a5,80002fbe <kerneltrap+0x5e>
	if ((which_dev = devintr()) == 0)
    80002f88:	00000097          	auipc	ra,0x0
    80002f8c:	e04080e7          	jalr	-508(ra) # 80002d8c <devintr>
    80002f90:	cd1d                	beqz	a0,80002fce <kerneltrap+0x6e>
	if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002f92:	4789                	li	a5,2
    80002f94:	06f50a63          	beq	a0,a5,80003008 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002f98:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002f9c:	10049073          	csrw	sstatus,s1
}
    80002fa0:	70a2                	ld	ra,40(sp)
    80002fa2:	7402                	ld	s0,32(sp)
    80002fa4:	64e2                	ld	s1,24(sp)
    80002fa6:	6942                	ld	s2,16(sp)
    80002fa8:	69a2                	ld	s3,8(sp)
    80002faa:	6145                	addi	sp,sp,48
    80002fac:	8082                	ret
		panic("kerneltrap: not from supervisor mode");
    80002fae:	00005517          	auipc	a0,0x5
    80002fb2:	42a50513          	addi	a0,a0,1066 # 800083d8 <states.2502+0xc8>
    80002fb6:	ffffd097          	auipc	ra,0xffffd
    80002fba:	58e080e7          	jalr	1422(ra) # 80000544 <panic>
		panic("kerneltrap: interrupts enabled");
    80002fbe:	00005517          	auipc	a0,0x5
    80002fc2:	44250513          	addi	a0,a0,1090 # 80008400 <states.2502+0xf0>
    80002fc6:	ffffd097          	auipc	ra,0xffffd
    80002fca:	57e080e7          	jalr	1406(ra) # 80000544 <panic>
		printf("scause %p\n", scause);
    80002fce:	85ce                	mv	a1,s3
    80002fd0:	00005517          	auipc	a0,0x5
    80002fd4:	45050513          	addi	a0,a0,1104 # 80008420 <states.2502+0x110>
    80002fd8:	ffffd097          	auipc	ra,0xffffd
    80002fdc:	5b6080e7          	jalr	1462(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002fe0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002fe4:	14302673          	csrr	a2,stval
		printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002fe8:	00005517          	auipc	a0,0x5
    80002fec:	44850513          	addi	a0,a0,1096 # 80008430 <states.2502+0x120>
    80002ff0:	ffffd097          	auipc	ra,0xffffd
    80002ff4:	59e080e7          	jalr	1438(ra) # 8000058e <printf>
		panic("kerneltrap");
    80002ff8:	00005517          	auipc	a0,0x5
    80002ffc:	45050513          	addi	a0,a0,1104 # 80008448 <states.2502+0x138>
    80003000:	ffffd097          	auipc	ra,0xffffd
    80003004:	544080e7          	jalr	1348(ra) # 80000544 <panic>
	if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003008:	fffff097          	auipc	ra,0xfffff
    8000300c:	cb0080e7          	jalr	-848(ra) # 80001cb8 <myproc>
    80003010:	d541                	beqz	a0,80002f98 <kerneltrap+0x38>
    80003012:	fffff097          	auipc	ra,0xfffff
    80003016:	ca6080e7          	jalr	-858(ra) # 80001cb8 <myproc>
    8000301a:	5118                	lw	a4,32(a0)
    8000301c:	4791                	li	a5,4
    8000301e:	f6f71de3          	bne	a4,a5,80002f98 <kerneltrap+0x38>
		yield();
    80003022:	fffff097          	auipc	ra,0xfffff
    80003026:	3c0080e7          	jalr	960(ra) # 800023e2 <yield>
    8000302a:	b7bd                	j	80002f98 <kerneltrap+0x38>

000000008000302c <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000302c:	1101                	addi	sp,sp,-32
    8000302e:	ec06                	sd	ra,24(sp)
    80003030:	e822                	sd	s0,16(sp)
    80003032:	e426                	sd	s1,8(sp)
    80003034:	1000                	addi	s0,sp,32
    80003036:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80003038:	fffff097          	auipc	ra,0xfffff
    8000303c:	c80080e7          	jalr	-896(ra) # 80001cb8 <myproc>
  switch (n)
    80003040:	4795                	li	a5,5
    80003042:	0497e163          	bltu	a5,s1,80003084 <argraw+0x58>
    80003046:	048a                	slli	s1,s1,0x2
    80003048:	00005717          	auipc	a4,0x5
    8000304c:	54870713          	addi	a4,a4,1352 # 80008590 <states.2502+0x280>
    80003050:	94ba                	add	s1,s1,a4
    80003052:	409c                	lw	a5,0(s1)
    80003054:	97ba                	add	a5,a5,a4
    80003056:	8782                	jr	a5
  {
  case 0:
    return p->trapframe->a0;
    80003058:	713c                	ld	a5,96(a0)
    8000305a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000305c:	60e2                	ld	ra,24(sp)
    8000305e:	6442                	ld	s0,16(sp)
    80003060:	64a2                	ld	s1,8(sp)
    80003062:	6105                	addi	sp,sp,32
    80003064:	8082                	ret
    return p->trapframe->a1;
    80003066:	713c                	ld	a5,96(a0)
    80003068:	7fa8                	ld	a0,120(a5)
    8000306a:	bfcd                	j	8000305c <argraw+0x30>
    return p->trapframe->a2;
    8000306c:	713c                	ld	a5,96(a0)
    8000306e:	63c8                	ld	a0,128(a5)
    80003070:	b7f5                	j	8000305c <argraw+0x30>
    return p->trapframe->a3;
    80003072:	713c                	ld	a5,96(a0)
    80003074:	67c8                	ld	a0,136(a5)
    80003076:	b7dd                	j	8000305c <argraw+0x30>
    return p->trapframe->a4;
    80003078:	713c                	ld	a5,96(a0)
    8000307a:	6bc8                	ld	a0,144(a5)
    8000307c:	b7c5                	j	8000305c <argraw+0x30>
    return p->trapframe->a5;
    8000307e:	713c                	ld	a5,96(a0)
    80003080:	6fc8                	ld	a0,152(a5)
    80003082:	bfe9                	j	8000305c <argraw+0x30>
  panic("argraw");
    80003084:	00005517          	auipc	a0,0x5
    80003088:	3d450513          	addi	a0,a0,980 # 80008458 <states.2502+0x148>
    8000308c:	ffffd097          	auipc	ra,0xffffd
    80003090:	4b8080e7          	jalr	1208(ra) # 80000544 <panic>

0000000080003094 <fetchaddr>:
{
    80003094:	1101                	addi	sp,sp,-32
    80003096:	ec06                	sd	ra,24(sp)
    80003098:	e822                	sd	s0,16(sp)
    8000309a:	e426                	sd	s1,8(sp)
    8000309c:	e04a                	sd	s2,0(sp)
    8000309e:	1000                	addi	s0,sp,32
    800030a0:	84aa                	mv	s1,a0
    800030a2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800030a4:	fffff097          	auipc	ra,0xfffff
    800030a8:	c14080e7          	jalr	-1004(ra) # 80001cb8 <myproc>
  if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800030ac:	693c                	ld	a5,80(a0)
    800030ae:	02f4f863          	bgeu	s1,a5,800030de <fetchaddr+0x4a>
    800030b2:	00848713          	addi	a4,s1,8
    800030b6:	02e7e663          	bltu	a5,a4,800030e2 <fetchaddr+0x4e>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800030ba:	46a1                	li	a3,8
    800030bc:	8626                	mv	a2,s1
    800030be:	85ca                	mv	a1,s2
    800030c0:	6d28                	ld	a0,88(a0)
    800030c2:	fffff097          	auipc	ra,0xfffff
    800030c6:	836080e7          	jalr	-1994(ra) # 800018f8 <copyin>
    800030ca:	00a03533          	snez	a0,a0
    800030ce:	40a00533          	neg	a0,a0
}
    800030d2:	60e2                	ld	ra,24(sp)
    800030d4:	6442                	ld	s0,16(sp)
    800030d6:	64a2                	ld	s1,8(sp)
    800030d8:	6902                	ld	s2,0(sp)
    800030da:	6105                	addi	sp,sp,32
    800030dc:	8082                	ret
    return -1;
    800030de:	557d                	li	a0,-1
    800030e0:	bfcd                	j	800030d2 <fetchaddr+0x3e>
    800030e2:	557d                	li	a0,-1
    800030e4:	b7fd                	j	800030d2 <fetchaddr+0x3e>

00000000800030e6 <fetchstr>:
{
    800030e6:	7179                	addi	sp,sp,-48
    800030e8:	f406                	sd	ra,40(sp)
    800030ea:	f022                	sd	s0,32(sp)
    800030ec:	ec26                	sd	s1,24(sp)
    800030ee:	e84a                	sd	s2,16(sp)
    800030f0:	e44e                	sd	s3,8(sp)
    800030f2:	1800                	addi	s0,sp,48
    800030f4:	892a                	mv	s2,a0
    800030f6:	84ae                	mv	s1,a1
    800030f8:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800030fa:	fffff097          	auipc	ra,0xfffff
    800030fe:	bbe080e7          	jalr	-1090(ra) # 80001cb8 <myproc>
  if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80003102:	86ce                	mv	a3,s3
    80003104:	864a                	mv	a2,s2
    80003106:	85a6                	mv	a1,s1
    80003108:	6d28                	ld	a0,88(a0)
    8000310a:	fffff097          	auipc	ra,0xfffff
    8000310e:	87a080e7          	jalr	-1926(ra) # 80001984 <copyinstr>
    80003112:	00054e63          	bltz	a0,8000312e <fetchstr+0x48>
  return strlen(buf);
    80003116:	8526                	mv	a0,s1
    80003118:	ffffe097          	auipc	ra,0xffffe
    8000311c:	f10080e7          	jalr	-240(ra) # 80001028 <strlen>
}
    80003120:	70a2                	ld	ra,40(sp)
    80003122:	7402                	ld	s0,32(sp)
    80003124:	64e2                	ld	s1,24(sp)
    80003126:	6942                	ld	s2,16(sp)
    80003128:	69a2                	ld	s3,8(sp)
    8000312a:	6145                	addi	sp,sp,48
    8000312c:	8082                	ret
    return -1;
    8000312e:	557d                	li	a0,-1
    80003130:	bfc5                	j	80003120 <fetchstr+0x3a>

0000000080003132 <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80003132:	1101                	addi	sp,sp,-32
    80003134:	ec06                	sd	ra,24(sp)
    80003136:	e822                	sd	s0,16(sp)
    80003138:	e426                	sd	s1,8(sp)
    8000313a:	1000                	addi	s0,sp,32
    8000313c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000313e:	00000097          	auipc	ra,0x0
    80003142:	eee080e7          	jalr	-274(ra) # 8000302c <argraw>
    80003146:	c088                	sw	a0,0(s1)
}
    80003148:	60e2                	ld	ra,24(sp)
    8000314a:	6442                	ld	s0,16(sp)
    8000314c:	64a2                	ld	s1,8(sp)
    8000314e:	6105                	addi	sp,sp,32
    80003150:	8082                	ret

0000000080003152 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80003152:	1101                	addi	sp,sp,-32
    80003154:	ec06                	sd	ra,24(sp)
    80003156:	e822                	sd	s0,16(sp)
    80003158:	e426                	sd	s1,8(sp)
    8000315a:	1000                	addi	s0,sp,32
    8000315c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000315e:	00000097          	auipc	ra,0x0
    80003162:	ece080e7          	jalr	-306(ra) # 8000302c <argraw>
    80003166:	e088                	sd	a0,0(s1)
}
    80003168:	60e2                	ld	ra,24(sp)
    8000316a:	6442                	ld	s0,16(sp)
    8000316c:	64a2                	ld	s1,8(sp)
    8000316e:	6105                	addi	sp,sp,32
    80003170:	8082                	ret

0000000080003172 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80003172:	7179                	addi	sp,sp,-48
    80003174:	f406                	sd	ra,40(sp)
    80003176:	f022                	sd	s0,32(sp)
    80003178:	ec26                	sd	s1,24(sp)
    8000317a:	e84a                	sd	s2,16(sp)
    8000317c:	1800                	addi	s0,sp,48
    8000317e:	84ae                	mv	s1,a1
    80003180:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80003182:	fd840593          	addi	a1,s0,-40
    80003186:	00000097          	auipc	ra,0x0
    8000318a:	fcc080e7          	jalr	-52(ra) # 80003152 <argaddr>
  return fetchstr(addr, buf, max);
    8000318e:	864a                	mv	a2,s2
    80003190:	85a6                	mv	a1,s1
    80003192:	fd843503          	ld	a0,-40(s0)
    80003196:	00000097          	auipc	ra,0x0
    8000319a:	f50080e7          	jalr	-176(ra) # 800030e6 <fetchstr>
}
    8000319e:	70a2                	ld	ra,40(sp)
    800031a0:	7402                	ld	s0,32(sp)
    800031a2:	64e2                	ld	s1,24(sp)
    800031a4:	6942                	ld	s2,16(sp)
    800031a6:	6145                	addi	sp,sp,48
    800031a8:	8082                	ret

00000000800031aa <syscall>:
    {"settickets", 1},
    {"waitx",3}
};

void syscall(void)
{
    800031aa:	711d                	addi	sp,sp,-96
    800031ac:	ec86                	sd	ra,88(sp)
    800031ae:	e8a2                	sd	s0,80(sp)
    800031b0:	e4a6                	sd	s1,72(sp)
    800031b2:	e0ca                	sd	s2,64(sp)
    800031b4:	fc4e                	sd	s3,56(sp)
    800031b6:	f852                	sd	s4,48(sp)
    800031b8:	f456                	sd	s5,40(sp)
    800031ba:	f05a                	sd	s6,32(sp)
    800031bc:	ec5e                	sd	s7,24(sp)
    800031be:	e862                	sd	s8,16(sp)
    800031c0:	e466                	sd	s9,8(sp)
    800031c2:	e06a                	sd	s10,0(sp)
    800031c4:	1080                	addi	s0,sp,96
  int num;
  struct proc *p = myproc();
    800031c6:	fffff097          	auipc	ra,0xfffff
    800031ca:	af2080e7          	jalr	-1294(ra) # 80001cb8 <myproc>
    800031ce:	8a2a                	mv	s4,a0

  num = p->trapframe->a7; // return reg
    800031d0:	7124                	ld	s1,96(a0)
    800031d2:	74dc                	ld	a5,168(s1)
    800031d4:	00078b1b          	sext.w	s6,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    800031d8:	37fd                	addiw	a5,a5,-1
    800031da:	4765                	li	a4,25
    800031dc:	06f76f63          	bltu	a4,a5,8000325a <syscall+0xb0>
    800031e0:	003b1713          	slli	a4,s6,0x3
    800031e4:	00005797          	auipc	a5,0x5
    800031e8:	3c478793          	addi	a5,a5,964 # 800085a8 <syscalls>
    800031ec:	97ba                	add	a5,a5,a4
    800031ee:	0007bd03          	ld	s10,0(a5)
    800031f2:	060d0463          	beqz	s10,8000325a <syscall+0xb0>
  {
    800031f6:	8c8a                	mv	s9,sp
    int numargs = syscall_info[num - 1].num;
    800031f8:	fffb0c1b          	addiw	s8,s6,-1
    800031fc:	004c1713          	slli	a4,s8,0x4
    80003200:	00006797          	auipc	a5,0x6
    80003204:	80878793          	addi	a5,a5,-2040 # 80008a08 <syscall_info>
    80003208:	97ba                	add	a5,a5,a4
    8000320a:	0087a983          	lw	s3,8(a5)
    int Args[numargs]; // to store value of registers acc to the number of args of the syscall
    8000320e:	00299793          	slli	a5,s3,0x2
    80003212:	07bd                	addi	a5,a5,15
    80003214:	9bc1                	andi	a5,a5,-16
    80003216:	40f10133          	sub	sp,sp,a5
    8000321a:	8b8a                	mv	s7,sp
    int j = 0;
    while (j < numargs)
    8000321c:	11305363          	blez	s3,80003322 <syscall+0x178>
    80003220:	8ade                	mv	s5,s7
    80003222:	895e                	mv	s2,s7
    int j = 0;
    80003224:	4481                	li	s1,0
    {
      Args[j] = argraw(j);
    80003226:	8526                	mv	a0,s1
    80003228:	00000097          	auipc	ra,0x0
    8000322c:	e04080e7          	jalr	-508(ra) # 8000302c <argraw>
    80003230:	00a92023          	sw	a0,0(s2)
      j++;
    80003234:	2485                	addiw	s1,s1,1
    while (j < numargs)
    80003236:	0911                	addi	s2,s2,4
    80003238:	fe9997e3          	bne	s3,s1,80003226 <syscall+0x7c>
    }

    int shift = 1 << num; // mask for num
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    8000323c:	060a3483          	ld	s1,96(s4)
    80003240:	9d02                	jalr	s10
    80003242:	f8a8                	sd	a0,112(s1)
    int shift = 1 << num; // mask for num
    80003244:	4785                	li	a5,1
    80003246:	016797bb          	sllw	a5,a5,s6

    if (p->mask & shift)
    8000324a:	000a2b03          	lw	s6,0(s4)
    8000324e:	0167f7b3          	and	a5,a5,s6
    80003252:	2781                	sext.w	a5,a5
    80003254:	e7a1                	bnez	a5,8000329c <syscall+0xf2>
    80003256:	8166                	mv	sp,s9
  {
    80003258:	a015                	j	8000327c <syscall+0xd2>
      printf(" -> %d\n", p->trapframe->a0);
    }
  }
  else
  {
    printf("%d %s: unknown sys call %d\n",
    8000325a:	86da                	mv	a3,s6
    8000325c:	160a0613          	addi	a2,s4,352
    80003260:	038a2583          	lw	a1,56(s4)
    80003264:	00005517          	auipc	a0,0x5
    80003268:	21450513          	addi	a0,a0,532 # 80008478 <states.2502+0x168>
    8000326c:	ffffd097          	auipc	ra,0xffffd
    80003270:	322080e7          	jalr	802(ra) # 8000058e <printf>
           p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003274:	060a3783          	ld	a5,96(s4)
    80003278:	577d                	li	a4,-1
    8000327a:	fbb8                	sd	a4,112(a5)
  }
}
    8000327c:	fa040113          	addi	sp,s0,-96
    80003280:	60e6                	ld	ra,88(sp)
    80003282:	6446                	ld	s0,80(sp)
    80003284:	64a6                	ld	s1,72(sp)
    80003286:	6906                	ld	s2,64(sp)
    80003288:	79e2                	ld	s3,56(sp)
    8000328a:	7a42                	ld	s4,48(sp)
    8000328c:	7aa2                	ld	s5,40(sp)
    8000328e:	7b02                	ld	s6,32(sp)
    80003290:	6be2                	ld	s7,24(sp)
    80003292:	6c42                	ld	s8,16(sp)
    80003294:	6ca2                	ld	s9,8(sp)
    80003296:	6d02                	ld	s10,0(sp)
    80003298:	6125                	addi	sp,sp,96
    8000329a:	8082                	ret
      printf("%d: syscall %s ", p->pid, syscall_info[num - 1].name);
    8000329c:	0c12                	slli	s8,s8,0x4
    8000329e:	00005797          	auipc	a5,0x5
    800032a2:	76a78793          	addi	a5,a5,1898 # 80008a08 <syscall_info>
    800032a6:	9c3e                	add	s8,s8,a5
    800032a8:	000c3603          	ld	a2,0(s8)
    800032ac:	038a2583          	lw	a1,56(s4)
    800032b0:	00005517          	auipc	a0,0x5
    800032b4:	1e850513          	addi	a0,a0,488 # 80008498 <states.2502+0x188>
    800032b8:	ffffd097          	auipc	ra,0xffffd
    800032bc:	2d6080e7          	jalr	726(ra) # 8000058e <printf>
      printf("(");
    800032c0:	00005517          	auipc	a0,0x5
    800032c4:	1e850513          	addi	a0,a0,488 # 800084a8 <states.2502+0x198>
    800032c8:	ffffd097          	auipc	ra,0xffffd
    800032cc:	2c6080e7          	jalr	710(ra) # 8000058e <printf>
      while (i < numargs)
    800032d0:	fff9879b          	addiw	a5,s3,-1
    800032d4:	1782                	slli	a5,a5,0x20
    800032d6:	9381                	srli	a5,a5,0x20
    800032d8:	0785                	addi	a5,a5,1
    800032da:	078a                	slli	a5,a5,0x2
    800032dc:	9bbe                	add	s7,s7,a5
        printf("%d ", Args[i]);
    800032de:	00005497          	auipc	s1,0x5
    800032e2:	18248493          	addi	s1,s1,386 # 80008460 <states.2502+0x150>
    800032e6:	000aa583          	lw	a1,0(s5)
    800032ea:	8526                	mv	a0,s1
    800032ec:	ffffd097          	auipc	ra,0xffffd
    800032f0:	2a2080e7          	jalr	674(ra) # 8000058e <printf>
      while (i < numargs)
    800032f4:	0a91                	addi	s5,s5,4
    800032f6:	ff7a98e3          	bne	s5,s7,800032e6 <syscall+0x13c>
      printf(")");
    800032fa:	00005517          	auipc	a0,0x5
    800032fe:	16e50513          	addi	a0,a0,366 # 80008468 <states.2502+0x158>
    80003302:	ffffd097          	auipc	ra,0xffffd
    80003306:	28c080e7          	jalr	652(ra) # 8000058e <printf>
      printf(" -> %d\n", p->trapframe->a0);
    8000330a:	060a3783          	ld	a5,96(s4)
    8000330e:	7bac                	ld	a1,112(a5)
    80003310:	00005517          	auipc	a0,0x5
    80003314:	16050513          	addi	a0,a0,352 # 80008470 <states.2502+0x160>
    80003318:	ffffd097          	auipc	ra,0xffffd
    8000331c:	276080e7          	jalr	630(ra) # 8000058e <printf>
    80003320:	bf1d                	j	80003256 <syscall+0xac>
    p->trapframe->a0 = syscalls[num]();
    80003322:	9d02                	jalr	s10
    80003324:	f8a8                	sd	a0,112(s1)
    int shift = 1 << num; // mask for num
    80003326:	4785                	li	a5,1
    80003328:	016797bb          	sllw	a5,a5,s6
    if (p->mask & shift)
    8000332c:	000a2703          	lw	a4,0(s4)
    80003330:	8ff9                	and	a5,a5,a4
    80003332:	2781                	sext.w	a5,a5
    80003334:	d38d                	beqz	a5,80003256 <syscall+0xac>
      printf("%d: syscall %s ", p->pid, syscall_info[num - 1].name);
    80003336:	0c12                	slli	s8,s8,0x4
    80003338:	00005797          	auipc	a5,0x5
    8000333c:	6d078793          	addi	a5,a5,1744 # 80008a08 <syscall_info>
    80003340:	97e2                	add	a5,a5,s8
    80003342:	6390                	ld	a2,0(a5)
    80003344:	038a2583          	lw	a1,56(s4)
    80003348:	00005517          	auipc	a0,0x5
    8000334c:	15050513          	addi	a0,a0,336 # 80008498 <states.2502+0x188>
    80003350:	ffffd097          	auipc	ra,0xffffd
    80003354:	23e080e7          	jalr	574(ra) # 8000058e <printf>
      printf("(");
    80003358:	00005517          	auipc	a0,0x5
    8000335c:	15050513          	addi	a0,a0,336 # 800084a8 <states.2502+0x198>
    80003360:	ffffd097          	auipc	ra,0xffffd
    80003364:	22e080e7          	jalr	558(ra) # 8000058e <printf>
      while (i < numargs)
    80003368:	bf49                	j	800032fa <syscall+0x150>

000000008000336a <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    8000336a:	1101                	addi	sp,sp,-32
    8000336c:	ec06                	sd	ra,24(sp)
    8000336e:	e822                	sd	s0,16(sp)
    80003370:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80003372:	fec40593          	addi	a1,s0,-20
    80003376:	4501                	li	a0,0
    80003378:	00000097          	auipc	ra,0x0
    8000337c:	dba080e7          	jalr	-582(ra) # 80003132 <argint>
  exit(n);
    80003380:	fec42503          	lw	a0,-20(s0)
    80003384:	fffff097          	auipc	ra,0xfffff
    80003388:	4a2080e7          	jalr	1186(ra) # 80002826 <exit>
  return 0; // not reached
}
    8000338c:	4501                	li	a0,0
    8000338e:	60e2                	ld	ra,24(sp)
    80003390:	6442                	ld	s0,16(sp)
    80003392:	6105                	addi	sp,sp,32
    80003394:	8082                	ret

0000000080003396 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003396:	1141                	addi	sp,sp,-16
    80003398:	e406                	sd	ra,8(sp)
    8000339a:	e022                	sd	s0,0(sp)
    8000339c:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000339e:	fffff097          	auipc	ra,0xfffff
    800033a2:	91a080e7          	jalr	-1766(ra) # 80001cb8 <myproc>
}
    800033a6:	5d08                	lw	a0,56(a0)
    800033a8:	60a2                	ld	ra,8(sp)
    800033aa:	6402                	ld	s0,0(sp)
    800033ac:	0141                	addi	sp,sp,16
    800033ae:	8082                	ret

00000000800033b0 <sys_fork>:

uint64
sys_fork(void)
{
    800033b0:	1141                	addi	sp,sp,-16
    800033b2:	e406                	sd	ra,8(sp)
    800033b4:	e022                	sd	s0,0(sp)
    800033b6:	0800                	addi	s0,sp,16
  return fork();
    800033b8:	fffff097          	auipc	ra,0xfffff
    800033bc:	cf0080e7          	jalr	-784(ra) # 800020a8 <fork>
}
    800033c0:	60a2                	ld	ra,8(sp)
    800033c2:	6402                	ld	s0,0(sp)
    800033c4:	0141                	addi	sp,sp,16
    800033c6:	8082                	ret

00000000800033c8 <sys_wait>:

uint64
sys_wait(void)
{
    800033c8:	1101                	addi	sp,sp,-32
    800033ca:	ec06                	sd	ra,24(sp)
    800033cc:	e822                	sd	s0,16(sp)
    800033ce:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800033d0:	fe840593          	addi	a1,s0,-24
    800033d4:	4501                	li	a0,0
    800033d6:	00000097          	auipc	ra,0x0
    800033da:	d7c080e7          	jalr	-644(ra) # 80003152 <argaddr>
  return wait(p);
    800033de:	fe843503          	ld	a0,-24(s0)
    800033e2:	fffff097          	auipc	ra,0xfffff
    800033e6:	208080e7          	jalr	520(ra) # 800025ea <wait>
}
    800033ea:	60e2                	ld	ra,24(sp)
    800033ec:	6442                	ld	s0,16(sp)
    800033ee:	6105                	addi	sp,sp,32
    800033f0:	8082                	ret

00000000800033f2 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800033f2:	7179                	addi	sp,sp,-48
    800033f4:	f406                	sd	ra,40(sp)
    800033f6:	f022                	sd	s0,32(sp)
    800033f8:	ec26                	sd	s1,24(sp)
    800033fa:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    800033fc:	fdc40593          	addi	a1,s0,-36
    80003400:	4501                	li	a0,0
    80003402:	00000097          	auipc	ra,0x0
    80003406:	d30080e7          	jalr	-720(ra) # 80003132 <argint>
  addr = myproc()->sz;
    8000340a:	fffff097          	auipc	ra,0xfffff
    8000340e:	8ae080e7          	jalr	-1874(ra) # 80001cb8 <myproc>
    80003412:	6924                	ld	s1,80(a0)
  if (growproc(n) < 0)
    80003414:	fdc42503          	lw	a0,-36(s0)
    80003418:	fffff097          	auipc	ra,0xfffff
    8000341c:	c34080e7          	jalr	-972(ra) # 8000204c <growproc>
    80003420:	00054863          	bltz	a0,80003430 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80003424:	8526                	mv	a0,s1
    80003426:	70a2                	ld	ra,40(sp)
    80003428:	7402                	ld	s0,32(sp)
    8000342a:	64e2                	ld	s1,24(sp)
    8000342c:	6145                	addi	sp,sp,48
    8000342e:	8082                	ret
    return -1;
    80003430:	54fd                	li	s1,-1
    80003432:	bfcd                	j	80003424 <sys_sbrk+0x32>

0000000080003434 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003434:	7139                	addi	sp,sp,-64
    80003436:	fc06                	sd	ra,56(sp)
    80003438:	f822                	sd	s0,48(sp)
    8000343a:	f426                	sd	s1,40(sp)
    8000343c:	f04a                	sd	s2,32(sp)
    8000343e:	ec4e                	sd	s3,24(sp)
    80003440:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80003442:	fcc40593          	addi	a1,s0,-52
    80003446:	4501                	li	a0,0
    80003448:	00000097          	auipc	ra,0x0
    8000344c:	cea080e7          	jalr	-790(ra) # 80003132 <argint>
  acquire(&tickslock);
    80003450:	00235517          	auipc	a0,0x235
    80003454:	26850513          	addi	a0,a0,616 # 802386b8 <tickslock>
    80003458:	ffffe097          	auipc	ra,0xffffe
    8000345c:	950080e7          	jalr	-1712(ra) # 80000da8 <acquire>
  ticks0 = ticks;
    80003460:	00005917          	auipc	s2,0x5
    80003464:	7a092903          	lw	s2,1952(s2) # 80008c00 <ticks>
  while (ticks - ticks0 < n)
    80003468:	fcc42783          	lw	a5,-52(s0)
    8000346c:	cf9d                	beqz	a5,800034aa <sys_sleep+0x76>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000346e:	00235997          	auipc	s3,0x235
    80003472:	24a98993          	addi	s3,s3,586 # 802386b8 <tickslock>
    80003476:	00005497          	auipc	s1,0x5
    8000347a:	78a48493          	addi	s1,s1,1930 # 80008c00 <ticks>
    if (killed(myproc()))
    8000347e:	fffff097          	auipc	ra,0xfffff
    80003482:	83a080e7          	jalr	-1990(ra) # 80001cb8 <myproc>
    80003486:	fffff097          	auipc	ra,0xfffff
    8000348a:	546080e7          	jalr	1350(ra) # 800029cc <killed>
    8000348e:	ed15                	bnez	a0,800034ca <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80003490:	85ce                	mv	a1,s3
    80003492:	8526                	mv	a0,s1
    80003494:	fffff097          	auipc	ra,0xfffff
    80003498:	f94080e7          	jalr	-108(ra) # 80002428 <sleep>
  while (ticks - ticks0 < n)
    8000349c:	409c                	lw	a5,0(s1)
    8000349e:	412787bb          	subw	a5,a5,s2
    800034a2:	fcc42703          	lw	a4,-52(s0)
    800034a6:	fce7ece3          	bltu	a5,a4,8000347e <sys_sleep+0x4a>
  }
  release(&tickslock);
    800034aa:	00235517          	auipc	a0,0x235
    800034ae:	20e50513          	addi	a0,a0,526 # 802386b8 <tickslock>
    800034b2:	ffffe097          	auipc	ra,0xffffe
    800034b6:	9aa080e7          	jalr	-1622(ra) # 80000e5c <release>
  return 0;
    800034ba:	4501                	li	a0,0
}
    800034bc:	70e2                	ld	ra,56(sp)
    800034be:	7442                	ld	s0,48(sp)
    800034c0:	74a2                	ld	s1,40(sp)
    800034c2:	7902                	ld	s2,32(sp)
    800034c4:	69e2                	ld	s3,24(sp)
    800034c6:	6121                	addi	sp,sp,64
    800034c8:	8082                	ret
      release(&tickslock);
    800034ca:	00235517          	auipc	a0,0x235
    800034ce:	1ee50513          	addi	a0,a0,494 # 802386b8 <tickslock>
    800034d2:	ffffe097          	auipc	ra,0xffffe
    800034d6:	98a080e7          	jalr	-1654(ra) # 80000e5c <release>
      return -1;
    800034da:	557d                	li	a0,-1
    800034dc:	b7c5                	j	800034bc <sys_sleep+0x88>

00000000800034de <sys_kill>:

uint64
sys_kill(void)
{
    800034de:	1101                	addi	sp,sp,-32
    800034e0:	ec06                	sd	ra,24(sp)
    800034e2:	e822                	sd	s0,16(sp)
    800034e4:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800034e6:	fec40593          	addi	a1,s0,-20
    800034ea:	4501                	li	a0,0
    800034ec:	00000097          	auipc	ra,0x0
    800034f0:	c46080e7          	jalr	-954(ra) # 80003132 <argint>
  return kill(pid);
    800034f4:	fec42503          	lw	a0,-20(s0)
    800034f8:	fffff097          	auipc	ra,0xfffff
    800034fc:	412080e7          	jalr	1042(ra) # 8000290a <kill>
}
    80003500:	60e2                	ld	ra,24(sp)
    80003502:	6442                	ld	s0,16(sp)
    80003504:	6105                	addi	sp,sp,32
    80003506:	8082                	ret

0000000080003508 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003508:	1101                	addi	sp,sp,-32
    8000350a:	ec06                	sd	ra,24(sp)
    8000350c:	e822                	sd	s0,16(sp)
    8000350e:	e426                	sd	s1,8(sp)
    80003510:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003512:	00235517          	auipc	a0,0x235
    80003516:	1a650513          	addi	a0,a0,422 # 802386b8 <tickslock>
    8000351a:	ffffe097          	auipc	ra,0xffffe
    8000351e:	88e080e7          	jalr	-1906(ra) # 80000da8 <acquire>
  xticks = ticks;
    80003522:	00005497          	auipc	s1,0x5
    80003526:	6de4a483          	lw	s1,1758(s1) # 80008c00 <ticks>
  release(&tickslock);
    8000352a:	00235517          	auipc	a0,0x235
    8000352e:	18e50513          	addi	a0,a0,398 # 802386b8 <tickslock>
    80003532:	ffffe097          	auipc	ra,0xffffe
    80003536:	92a080e7          	jalr	-1750(ra) # 80000e5c <release>
  return xticks;
}
    8000353a:	02049513          	slli	a0,s1,0x20
    8000353e:	9101                	srli	a0,a0,0x20
    80003540:	60e2                	ld	ra,24(sp)
    80003542:	6442                	ld	s0,16(sp)
    80003544:	64a2                	ld	s1,8(sp)
    80003546:	6105                	addi	sp,sp,32
    80003548:	8082                	ret

000000008000354a <sys_trace>:

uint64
sys_trace(void)
{
    8000354a:	1101                	addi	sp,sp,-32
    8000354c:	ec06                	sd	ra,24(sp)
    8000354e:	e822                	sd	s0,16(sp)
    80003550:	1000                	addi	s0,sp,32
  int n; // mask
  argint(0, &n);
    80003552:	fec40593          	addi	a1,s0,-20
    80003556:	4501                	li	a0,0
    80003558:	00000097          	auipc	ra,0x0
    8000355c:	bda080e7          	jalr	-1062(ra) # 80003132 <argint>
  myproc()->mask = n;
    80003560:	ffffe097          	auipc	ra,0xffffe
    80003564:	758080e7          	jalr	1880(ra) # 80001cb8 <myproc>
    80003568:	fec42783          	lw	a5,-20(s0)
    8000356c:	c11c                	sw	a5,0(a0)
  return 0;
}
    8000356e:	4501                	li	a0,0
    80003570:	60e2                	ld	ra,24(sp)
    80003572:	6442                	ld	s0,16(sp)
    80003574:	6105                	addi	sp,sp,32
    80003576:	8082                	ret

0000000080003578 <sys_sigalarm>:

uint64
sys_sigalarm(void)
{
    80003578:	1101                	addi	sp,sp,-32
    8000357a:	ec06                	sd	ra,24(sp)
    8000357c:	e822                	sd	s0,16(sp)
    8000357e:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80003580:	fec40593          	addi	a1,s0,-20
    80003584:	4501                	li	a0,0
    80003586:	00000097          	auipc	ra,0x0
    8000358a:	bac080e7          	jalr	-1108(ra) # 80003132 <argint>
  myproc()->ticks0 = 0;
    8000358e:	ffffe097          	auipc	ra,0xffffe
    80003592:	72a080e7          	jalr	1834(ra) # 80001cb8 <myproc>
    80003596:	00052223          	sw	zero,4(a0)
  return 0;
}
    8000359a:	4501                	li	a0,0
    8000359c:	60e2                	ld	ra,24(sp)
    8000359e:	6442                	ld	s0,16(sp)
    800035a0:	6105                	addi	sp,sp,32
    800035a2:	8082                	ret

00000000800035a4 <sys_setpriority>:

uint64
sys_setpriority(void)
{
    800035a4:	1101                	addi	sp,sp,-32
    800035a6:	ec06                	sd	ra,24(sp)
    800035a8:	e822                	sd	s0,16(sp)
    800035aa:	1000                	addi	s0,sp,32
  int priority;
  int pid;
  argint(0, &priority);
    800035ac:	fec40593          	addi	a1,s0,-20
    800035b0:	4501                	li	a0,0
    800035b2:	00000097          	auipc	ra,0x0
    800035b6:	b80080e7          	jalr	-1152(ra) # 80003132 <argint>
  argint(1, &pid);
    800035ba:	fe840593          	addi	a1,s0,-24
    800035be:	4505                	li	a0,1
    800035c0:	00000097          	auipc	ra,0x0
    800035c4:	b72080e7          	jalr	-1166(ra) # 80003132 <argint>
  return set_priority(priority, pid);
    800035c8:	fe842583          	lw	a1,-24(s0)
    800035cc:	fec42503          	lw	a0,-20(s0)
    800035d0:	ffffe097          	auipc	ra,0xffffe
    800035d4:	4b6080e7          	jalr	1206(ra) # 80001a86 <set_priority>
}
    800035d8:	60e2                	ld	ra,24(sp)
    800035da:	6442                	ld	s0,16(sp)
    800035dc:	6105                	addi	sp,sp,32
    800035de:	8082                	ret

00000000800035e0 <sys_settickets>:

uint64
sys_settickets(void){
    800035e0:	1101                	addi	sp,sp,-32
    800035e2:	ec06                	sd	ra,24(sp)
    800035e4:	e822                	sd	s0,16(sp)
    800035e6:	1000                	addi	s0,sp,32
  int n; // tickets
  argint(0, &n);
    800035e8:	fec40593          	addi	a1,s0,-20
    800035ec:	4501                	li	a0,0
    800035ee:	00000097          	auipc	ra,0x0
    800035f2:	b44080e7          	jalr	-1212(ra) # 80003132 <argint>
  myproc()->tickets = n;
    800035f6:	ffffe097          	auipc	ra,0xffffe
    800035fa:	6c2080e7          	jalr	1730(ra) # 80001cb8 <myproc>
    800035fe:	fec42783          	lw	a5,-20(s0)
    80003602:	16f52823          	sw	a5,368(a0)
  return 0;
}
    80003606:	4501                	li	a0,0
    80003608:	60e2                	ld	ra,24(sp)
    8000360a:	6442                	ld	s0,16(sp)
    8000360c:	6105                	addi	sp,sp,32
    8000360e:	8082                	ret

0000000080003610 <sys_waitx>:

uint64
sys_waitx(void)
{
    80003610:	7139                	addi	sp,sp,-64
    80003612:	fc06                	sd	ra,56(sp)
    80003614:	f822                	sd	s0,48(sp)
    80003616:	f426                	sd	s1,40(sp)
    80003618:	f04a                	sd	s2,32(sp)
    8000361a:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    8000361c:	fd840593          	addi	a1,s0,-40
    80003620:	4501                	li	a0,0
    80003622:	00000097          	auipc	ra,0x0
    80003626:	b30080e7          	jalr	-1232(ra) # 80003152 <argaddr>
  argaddr(1, &addr1); // user virtual memory
    8000362a:	fd040593          	addi	a1,s0,-48
    8000362e:	4505                	li	a0,1
    80003630:	00000097          	auipc	ra,0x0
    80003634:	b22080e7          	jalr	-1246(ra) # 80003152 <argaddr>
  argaddr(2, &addr2);
    80003638:	fc840593          	addi	a1,s0,-56
    8000363c:	4509                	li	a0,2
    8000363e:	00000097          	auipc	ra,0x0
    80003642:	b14080e7          	jalr	-1260(ra) # 80003152 <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    80003646:	fc040613          	addi	a2,s0,-64
    8000364a:	fc440593          	addi	a1,s0,-60
    8000364e:	fd843503          	ld	a0,-40(s0)
    80003652:	fffff097          	auipc	ra,0xfffff
    80003656:	e44080e7          	jalr	-444(ra) # 80002496 <waitx>
    8000365a:	892a                	mv	s2,a0
  struct proc* p = myproc();
    8000365c:	ffffe097          	auipc	ra,0xffffe
    80003660:	65c080e7          	jalr	1628(ra) # 80001cb8 <myproc>
    80003664:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    80003666:	4691                	li	a3,4
    80003668:	fc440613          	addi	a2,s0,-60
    8000366c:	fd043583          	ld	a1,-48(s0)
    80003670:	6d28                	ld	a0,88(a0)
    80003672:	ffffe097          	auipc	ra,0xffffe
    80003676:	1c6080e7          	jalr	454(ra) # 80001838 <copyout>
    return -1;
    8000367a:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    8000367c:	00054f63          	bltz	a0,8000369a <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2,(char*)&rtime, sizeof(int)) < 0)
    80003680:	4691                	li	a3,4
    80003682:	fc040613          	addi	a2,s0,-64
    80003686:	fc843583          	ld	a1,-56(s0)
    8000368a:	6ca8                	ld	a0,88(s1)
    8000368c:	ffffe097          	auipc	ra,0xffffe
    80003690:	1ac080e7          	jalr	428(ra) # 80001838 <copyout>
    80003694:	00054a63          	bltz	a0,800036a8 <sys_waitx+0x98>
    return -1;
  return ret;
    80003698:	87ca                	mv	a5,s2
    8000369a:	853e                	mv	a0,a5
    8000369c:	70e2                	ld	ra,56(sp)
    8000369e:	7442                	ld	s0,48(sp)
    800036a0:	74a2                	ld	s1,40(sp)
    800036a2:	7902                	ld	s2,32(sp)
    800036a4:	6121                	addi	sp,sp,64
    800036a6:	8082                	ret
    return -1;
    800036a8:	57fd                	li	a5,-1
    800036aa:	bfc5                	j	8000369a <sys_waitx+0x8a>

00000000800036ac <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800036ac:	7179                	addi	sp,sp,-48
    800036ae:	f406                	sd	ra,40(sp)
    800036b0:	f022                	sd	s0,32(sp)
    800036b2:	ec26                	sd	s1,24(sp)
    800036b4:	e84a                	sd	s2,16(sp)
    800036b6:	e44e                	sd	s3,8(sp)
    800036b8:	e052                	sd	s4,0(sp)
    800036ba:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800036bc:	00005597          	auipc	a1,0x5
    800036c0:	fc458593          	addi	a1,a1,-60 # 80008680 <syscalls+0xd8>
    800036c4:	00235517          	auipc	a0,0x235
    800036c8:	00c50513          	addi	a0,a0,12 # 802386d0 <bcache>
    800036cc:	ffffd097          	auipc	ra,0xffffd
    800036d0:	64c080e7          	jalr	1612(ra) # 80000d18 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800036d4:	0023d797          	auipc	a5,0x23d
    800036d8:	ffc78793          	addi	a5,a5,-4 # 802406d0 <bcache+0x8000>
    800036dc:	0023d717          	auipc	a4,0x23d
    800036e0:	25c70713          	addi	a4,a4,604 # 80240938 <bcache+0x8268>
    800036e4:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800036e8:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800036ec:	00235497          	auipc	s1,0x235
    800036f0:	ffc48493          	addi	s1,s1,-4 # 802386e8 <bcache+0x18>
    b->next = bcache.head.next;
    800036f4:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800036f6:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800036f8:	00005a17          	auipc	s4,0x5
    800036fc:	f90a0a13          	addi	s4,s4,-112 # 80008688 <syscalls+0xe0>
    b->next = bcache.head.next;
    80003700:	2b893783          	ld	a5,696(s2)
    80003704:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003706:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000370a:	85d2                	mv	a1,s4
    8000370c:	01048513          	addi	a0,s1,16
    80003710:	00001097          	auipc	ra,0x1
    80003714:	4c4080e7          	jalr	1220(ra) # 80004bd4 <initsleeplock>
    bcache.head.next->prev = b;
    80003718:	2b893783          	ld	a5,696(s2)
    8000371c:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000371e:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003722:	45848493          	addi	s1,s1,1112
    80003726:	fd349de3          	bne	s1,s3,80003700 <binit+0x54>
  }
}
    8000372a:	70a2                	ld	ra,40(sp)
    8000372c:	7402                	ld	s0,32(sp)
    8000372e:	64e2                	ld	s1,24(sp)
    80003730:	6942                	ld	s2,16(sp)
    80003732:	69a2                	ld	s3,8(sp)
    80003734:	6a02                	ld	s4,0(sp)
    80003736:	6145                	addi	sp,sp,48
    80003738:	8082                	ret

000000008000373a <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000373a:	7179                	addi	sp,sp,-48
    8000373c:	f406                	sd	ra,40(sp)
    8000373e:	f022                	sd	s0,32(sp)
    80003740:	ec26                	sd	s1,24(sp)
    80003742:	e84a                	sd	s2,16(sp)
    80003744:	e44e                	sd	s3,8(sp)
    80003746:	1800                	addi	s0,sp,48
    80003748:	89aa                	mv	s3,a0
    8000374a:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    8000374c:	00235517          	auipc	a0,0x235
    80003750:	f8450513          	addi	a0,a0,-124 # 802386d0 <bcache>
    80003754:	ffffd097          	auipc	ra,0xffffd
    80003758:	654080e7          	jalr	1620(ra) # 80000da8 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000375c:	0023d497          	auipc	s1,0x23d
    80003760:	22c4b483          	ld	s1,556(s1) # 80240988 <bcache+0x82b8>
    80003764:	0023d797          	auipc	a5,0x23d
    80003768:	1d478793          	addi	a5,a5,468 # 80240938 <bcache+0x8268>
    8000376c:	02f48f63          	beq	s1,a5,800037aa <bread+0x70>
    80003770:	873e                	mv	a4,a5
    80003772:	a021                	j	8000377a <bread+0x40>
    80003774:	68a4                	ld	s1,80(s1)
    80003776:	02e48a63          	beq	s1,a4,800037aa <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000377a:	449c                	lw	a5,8(s1)
    8000377c:	ff379ce3          	bne	a5,s3,80003774 <bread+0x3a>
    80003780:	44dc                	lw	a5,12(s1)
    80003782:	ff2799e3          	bne	a5,s2,80003774 <bread+0x3a>
      b->refcnt++;
    80003786:	40bc                	lw	a5,64(s1)
    80003788:	2785                	addiw	a5,a5,1
    8000378a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000378c:	00235517          	auipc	a0,0x235
    80003790:	f4450513          	addi	a0,a0,-188 # 802386d0 <bcache>
    80003794:	ffffd097          	auipc	ra,0xffffd
    80003798:	6c8080e7          	jalr	1736(ra) # 80000e5c <release>
      acquiresleep(&b->lock);
    8000379c:	01048513          	addi	a0,s1,16
    800037a0:	00001097          	auipc	ra,0x1
    800037a4:	46e080e7          	jalr	1134(ra) # 80004c0e <acquiresleep>
      return b;
    800037a8:	a8b9                	j	80003806 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800037aa:	0023d497          	auipc	s1,0x23d
    800037ae:	1d64b483          	ld	s1,470(s1) # 80240980 <bcache+0x82b0>
    800037b2:	0023d797          	auipc	a5,0x23d
    800037b6:	18678793          	addi	a5,a5,390 # 80240938 <bcache+0x8268>
    800037ba:	00f48863          	beq	s1,a5,800037ca <bread+0x90>
    800037be:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800037c0:	40bc                	lw	a5,64(s1)
    800037c2:	cf81                	beqz	a5,800037da <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800037c4:	64a4                	ld	s1,72(s1)
    800037c6:	fee49de3          	bne	s1,a4,800037c0 <bread+0x86>
  panic("bget: no buffers");
    800037ca:	00005517          	auipc	a0,0x5
    800037ce:	ec650513          	addi	a0,a0,-314 # 80008690 <syscalls+0xe8>
    800037d2:	ffffd097          	auipc	ra,0xffffd
    800037d6:	d72080e7          	jalr	-654(ra) # 80000544 <panic>
      b->dev = dev;
    800037da:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    800037de:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    800037e2:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800037e6:	4785                	li	a5,1
    800037e8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800037ea:	00235517          	auipc	a0,0x235
    800037ee:	ee650513          	addi	a0,a0,-282 # 802386d0 <bcache>
    800037f2:	ffffd097          	auipc	ra,0xffffd
    800037f6:	66a080e7          	jalr	1642(ra) # 80000e5c <release>
      acquiresleep(&b->lock);
    800037fa:	01048513          	addi	a0,s1,16
    800037fe:	00001097          	auipc	ra,0x1
    80003802:	410080e7          	jalr	1040(ra) # 80004c0e <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003806:	409c                	lw	a5,0(s1)
    80003808:	cb89                	beqz	a5,8000381a <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000380a:	8526                	mv	a0,s1
    8000380c:	70a2                	ld	ra,40(sp)
    8000380e:	7402                	ld	s0,32(sp)
    80003810:	64e2                	ld	s1,24(sp)
    80003812:	6942                	ld	s2,16(sp)
    80003814:	69a2                	ld	s3,8(sp)
    80003816:	6145                	addi	sp,sp,48
    80003818:	8082                	ret
    virtio_disk_rw(b, 0);
    8000381a:	4581                	li	a1,0
    8000381c:	8526                	mv	a0,s1
    8000381e:	00003097          	auipc	ra,0x3
    80003822:	fca080e7          	jalr	-54(ra) # 800067e8 <virtio_disk_rw>
    b->valid = 1;
    80003826:	4785                	li	a5,1
    80003828:	c09c                	sw	a5,0(s1)
  return b;
    8000382a:	b7c5                	j	8000380a <bread+0xd0>

000000008000382c <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000382c:	1101                	addi	sp,sp,-32
    8000382e:	ec06                	sd	ra,24(sp)
    80003830:	e822                	sd	s0,16(sp)
    80003832:	e426                	sd	s1,8(sp)
    80003834:	1000                	addi	s0,sp,32
    80003836:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003838:	0541                	addi	a0,a0,16
    8000383a:	00001097          	auipc	ra,0x1
    8000383e:	46e080e7          	jalr	1134(ra) # 80004ca8 <holdingsleep>
    80003842:	cd01                	beqz	a0,8000385a <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003844:	4585                	li	a1,1
    80003846:	8526                	mv	a0,s1
    80003848:	00003097          	auipc	ra,0x3
    8000384c:	fa0080e7          	jalr	-96(ra) # 800067e8 <virtio_disk_rw>
}
    80003850:	60e2                	ld	ra,24(sp)
    80003852:	6442                	ld	s0,16(sp)
    80003854:	64a2                	ld	s1,8(sp)
    80003856:	6105                	addi	sp,sp,32
    80003858:	8082                	ret
    panic("bwrite");
    8000385a:	00005517          	auipc	a0,0x5
    8000385e:	e4e50513          	addi	a0,a0,-434 # 800086a8 <syscalls+0x100>
    80003862:	ffffd097          	auipc	ra,0xffffd
    80003866:	ce2080e7          	jalr	-798(ra) # 80000544 <panic>

000000008000386a <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000386a:	1101                	addi	sp,sp,-32
    8000386c:	ec06                	sd	ra,24(sp)
    8000386e:	e822                	sd	s0,16(sp)
    80003870:	e426                	sd	s1,8(sp)
    80003872:	e04a                	sd	s2,0(sp)
    80003874:	1000                	addi	s0,sp,32
    80003876:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003878:	01050913          	addi	s2,a0,16
    8000387c:	854a                	mv	a0,s2
    8000387e:	00001097          	auipc	ra,0x1
    80003882:	42a080e7          	jalr	1066(ra) # 80004ca8 <holdingsleep>
    80003886:	c92d                	beqz	a0,800038f8 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003888:	854a                	mv	a0,s2
    8000388a:	00001097          	auipc	ra,0x1
    8000388e:	3da080e7          	jalr	986(ra) # 80004c64 <releasesleep>

  acquire(&bcache.lock);
    80003892:	00235517          	auipc	a0,0x235
    80003896:	e3e50513          	addi	a0,a0,-450 # 802386d0 <bcache>
    8000389a:	ffffd097          	auipc	ra,0xffffd
    8000389e:	50e080e7          	jalr	1294(ra) # 80000da8 <acquire>
  b->refcnt--;
    800038a2:	40bc                	lw	a5,64(s1)
    800038a4:	37fd                	addiw	a5,a5,-1
    800038a6:	0007871b          	sext.w	a4,a5
    800038aa:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800038ac:	eb05                	bnez	a4,800038dc <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800038ae:	68bc                	ld	a5,80(s1)
    800038b0:	64b8                	ld	a4,72(s1)
    800038b2:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800038b4:	64bc                	ld	a5,72(s1)
    800038b6:	68b8                	ld	a4,80(s1)
    800038b8:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800038ba:	0023d797          	auipc	a5,0x23d
    800038be:	e1678793          	addi	a5,a5,-490 # 802406d0 <bcache+0x8000>
    800038c2:	2b87b703          	ld	a4,696(a5)
    800038c6:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800038c8:	0023d717          	auipc	a4,0x23d
    800038cc:	07070713          	addi	a4,a4,112 # 80240938 <bcache+0x8268>
    800038d0:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800038d2:	2b87b703          	ld	a4,696(a5)
    800038d6:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800038d8:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800038dc:	00235517          	auipc	a0,0x235
    800038e0:	df450513          	addi	a0,a0,-524 # 802386d0 <bcache>
    800038e4:	ffffd097          	auipc	ra,0xffffd
    800038e8:	578080e7          	jalr	1400(ra) # 80000e5c <release>
}
    800038ec:	60e2                	ld	ra,24(sp)
    800038ee:	6442                	ld	s0,16(sp)
    800038f0:	64a2                	ld	s1,8(sp)
    800038f2:	6902                	ld	s2,0(sp)
    800038f4:	6105                	addi	sp,sp,32
    800038f6:	8082                	ret
    panic("brelse");
    800038f8:	00005517          	auipc	a0,0x5
    800038fc:	db850513          	addi	a0,a0,-584 # 800086b0 <syscalls+0x108>
    80003900:	ffffd097          	auipc	ra,0xffffd
    80003904:	c44080e7          	jalr	-956(ra) # 80000544 <panic>

0000000080003908 <bpin>:

void
bpin(struct buf *b) {
    80003908:	1101                	addi	sp,sp,-32
    8000390a:	ec06                	sd	ra,24(sp)
    8000390c:	e822                	sd	s0,16(sp)
    8000390e:	e426                	sd	s1,8(sp)
    80003910:	1000                	addi	s0,sp,32
    80003912:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003914:	00235517          	auipc	a0,0x235
    80003918:	dbc50513          	addi	a0,a0,-580 # 802386d0 <bcache>
    8000391c:	ffffd097          	auipc	ra,0xffffd
    80003920:	48c080e7          	jalr	1164(ra) # 80000da8 <acquire>
  b->refcnt++;
    80003924:	40bc                	lw	a5,64(s1)
    80003926:	2785                	addiw	a5,a5,1
    80003928:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000392a:	00235517          	auipc	a0,0x235
    8000392e:	da650513          	addi	a0,a0,-602 # 802386d0 <bcache>
    80003932:	ffffd097          	auipc	ra,0xffffd
    80003936:	52a080e7          	jalr	1322(ra) # 80000e5c <release>
}
    8000393a:	60e2                	ld	ra,24(sp)
    8000393c:	6442                	ld	s0,16(sp)
    8000393e:	64a2                	ld	s1,8(sp)
    80003940:	6105                	addi	sp,sp,32
    80003942:	8082                	ret

0000000080003944 <bunpin>:

void
bunpin(struct buf *b) {
    80003944:	1101                	addi	sp,sp,-32
    80003946:	ec06                	sd	ra,24(sp)
    80003948:	e822                	sd	s0,16(sp)
    8000394a:	e426                	sd	s1,8(sp)
    8000394c:	1000                	addi	s0,sp,32
    8000394e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003950:	00235517          	auipc	a0,0x235
    80003954:	d8050513          	addi	a0,a0,-640 # 802386d0 <bcache>
    80003958:	ffffd097          	auipc	ra,0xffffd
    8000395c:	450080e7          	jalr	1104(ra) # 80000da8 <acquire>
  b->refcnt--;
    80003960:	40bc                	lw	a5,64(s1)
    80003962:	37fd                	addiw	a5,a5,-1
    80003964:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003966:	00235517          	auipc	a0,0x235
    8000396a:	d6a50513          	addi	a0,a0,-662 # 802386d0 <bcache>
    8000396e:	ffffd097          	auipc	ra,0xffffd
    80003972:	4ee080e7          	jalr	1262(ra) # 80000e5c <release>
}
    80003976:	60e2                	ld	ra,24(sp)
    80003978:	6442                	ld	s0,16(sp)
    8000397a:	64a2                	ld	s1,8(sp)
    8000397c:	6105                	addi	sp,sp,32
    8000397e:	8082                	ret

0000000080003980 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003980:	1101                	addi	sp,sp,-32
    80003982:	ec06                	sd	ra,24(sp)
    80003984:	e822                	sd	s0,16(sp)
    80003986:	e426                	sd	s1,8(sp)
    80003988:	e04a                	sd	s2,0(sp)
    8000398a:	1000                	addi	s0,sp,32
    8000398c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000398e:	00d5d59b          	srliw	a1,a1,0xd
    80003992:	0023d797          	auipc	a5,0x23d
    80003996:	41a7a783          	lw	a5,1050(a5) # 80240dac <sb+0x1c>
    8000399a:	9dbd                	addw	a1,a1,a5
    8000399c:	00000097          	auipc	ra,0x0
    800039a0:	d9e080e7          	jalr	-610(ra) # 8000373a <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800039a4:	0074f713          	andi	a4,s1,7
    800039a8:	4785                	li	a5,1
    800039aa:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800039ae:	14ce                	slli	s1,s1,0x33
    800039b0:	90d9                	srli	s1,s1,0x36
    800039b2:	00950733          	add	a4,a0,s1
    800039b6:	05874703          	lbu	a4,88(a4)
    800039ba:	00e7f6b3          	and	a3,a5,a4
    800039be:	c69d                	beqz	a3,800039ec <bfree+0x6c>
    800039c0:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800039c2:	94aa                	add	s1,s1,a0
    800039c4:	fff7c793          	not	a5,a5
    800039c8:	8ff9                	and	a5,a5,a4
    800039ca:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800039ce:	00001097          	auipc	ra,0x1
    800039d2:	120080e7          	jalr	288(ra) # 80004aee <log_write>
  brelse(bp);
    800039d6:	854a                	mv	a0,s2
    800039d8:	00000097          	auipc	ra,0x0
    800039dc:	e92080e7          	jalr	-366(ra) # 8000386a <brelse>
}
    800039e0:	60e2                	ld	ra,24(sp)
    800039e2:	6442                	ld	s0,16(sp)
    800039e4:	64a2                	ld	s1,8(sp)
    800039e6:	6902                	ld	s2,0(sp)
    800039e8:	6105                	addi	sp,sp,32
    800039ea:	8082                	ret
    panic("freeing free block");
    800039ec:	00005517          	auipc	a0,0x5
    800039f0:	ccc50513          	addi	a0,a0,-820 # 800086b8 <syscalls+0x110>
    800039f4:	ffffd097          	auipc	ra,0xffffd
    800039f8:	b50080e7          	jalr	-1200(ra) # 80000544 <panic>

00000000800039fc <balloc>:
{
    800039fc:	711d                	addi	sp,sp,-96
    800039fe:	ec86                	sd	ra,88(sp)
    80003a00:	e8a2                	sd	s0,80(sp)
    80003a02:	e4a6                	sd	s1,72(sp)
    80003a04:	e0ca                	sd	s2,64(sp)
    80003a06:	fc4e                	sd	s3,56(sp)
    80003a08:	f852                	sd	s4,48(sp)
    80003a0a:	f456                	sd	s5,40(sp)
    80003a0c:	f05a                	sd	s6,32(sp)
    80003a0e:	ec5e                	sd	s7,24(sp)
    80003a10:	e862                	sd	s8,16(sp)
    80003a12:	e466                	sd	s9,8(sp)
    80003a14:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003a16:	0023d797          	auipc	a5,0x23d
    80003a1a:	37e7a783          	lw	a5,894(a5) # 80240d94 <sb+0x4>
    80003a1e:	10078163          	beqz	a5,80003b20 <balloc+0x124>
    80003a22:	8baa                	mv	s7,a0
    80003a24:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003a26:	0023db17          	auipc	s6,0x23d
    80003a2a:	36ab0b13          	addi	s6,s6,874 # 80240d90 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a2e:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003a30:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a32:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003a34:	6c89                	lui	s9,0x2
    80003a36:	a061                	j	80003abe <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003a38:	974a                	add	a4,a4,s2
    80003a3a:	8fd5                	or	a5,a5,a3
    80003a3c:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003a40:	854a                	mv	a0,s2
    80003a42:	00001097          	auipc	ra,0x1
    80003a46:	0ac080e7          	jalr	172(ra) # 80004aee <log_write>
        brelse(bp);
    80003a4a:	854a                	mv	a0,s2
    80003a4c:	00000097          	auipc	ra,0x0
    80003a50:	e1e080e7          	jalr	-482(ra) # 8000386a <brelse>
  bp = bread(dev, bno);
    80003a54:	85a6                	mv	a1,s1
    80003a56:	855e                	mv	a0,s7
    80003a58:	00000097          	auipc	ra,0x0
    80003a5c:	ce2080e7          	jalr	-798(ra) # 8000373a <bread>
    80003a60:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003a62:	40000613          	li	a2,1024
    80003a66:	4581                	li	a1,0
    80003a68:	05850513          	addi	a0,a0,88
    80003a6c:	ffffd097          	auipc	ra,0xffffd
    80003a70:	438080e7          	jalr	1080(ra) # 80000ea4 <memset>
  log_write(bp);
    80003a74:	854a                	mv	a0,s2
    80003a76:	00001097          	auipc	ra,0x1
    80003a7a:	078080e7          	jalr	120(ra) # 80004aee <log_write>
  brelse(bp);
    80003a7e:	854a                	mv	a0,s2
    80003a80:	00000097          	auipc	ra,0x0
    80003a84:	dea080e7          	jalr	-534(ra) # 8000386a <brelse>
}
    80003a88:	8526                	mv	a0,s1
    80003a8a:	60e6                	ld	ra,88(sp)
    80003a8c:	6446                	ld	s0,80(sp)
    80003a8e:	64a6                	ld	s1,72(sp)
    80003a90:	6906                	ld	s2,64(sp)
    80003a92:	79e2                	ld	s3,56(sp)
    80003a94:	7a42                	ld	s4,48(sp)
    80003a96:	7aa2                	ld	s5,40(sp)
    80003a98:	7b02                	ld	s6,32(sp)
    80003a9a:	6be2                	ld	s7,24(sp)
    80003a9c:	6c42                	ld	s8,16(sp)
    80003a9e:	6ca2                	ld	s9,8(sp)
    80003aa0:	6125                	addi	sp,sp,96
    80003aa2:	8082                	ret
    brelse(bp);
    80003aa4:	854a                	mv	a0,s2
    80003aa6:	00000097          	auipc	ra,0x0
    80003aaa:	dc4080e7          	jalr	-572(ra) # 8000386a <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003aae:	015c87bb          	addw	a5,s9,s5
    80003ab2:	00078a9b          	sext.w	s5,a5
    80003ab6:	004b2703          	lw	a4,4(s6)
    80003aba:	06eaf363          	bgeu	s5,a4,80003b20 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80003abe:	41fad79b          	sraiw	a5,s5,0x1f
    80003ac2:	0137d79b          	srliw	a5,a5,0x13
    80003ac6:	015787bb          	addw	a5,a5,s5
    80003aca:	40d7d79b          	sraiw	a5,a5,0xd
    80003ace:	01cb2583          	lw	a1,28(s6)
    80003ad2:	9dbd                	addw	a1,a1,a5
    80003ad4:	855e                	mv	a0,s7
    80003ad6:	00000097          	auipc	ra,0x0
    80003ada:	c64080e7          	jalr	-924(ra) # 8000373a <bread>
    80003ade:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003ae0:	004b2503          	lw	a0,4(s6)
    80003ae4:	000a849b          	sext.w	s1,s5
    80003ae8:	8662                	mv	a2,s8
    80003aea:	faa4fde3          	bgeu	s1,a0,80003aa4 <balloc+0xa8>
      m = 1 << (bi % 8);
    80003aee:	41f6579b          	sraiw	a5,a2,0x1f
    80003af2:	01d7d69b          	srliw	a3,a5,0x1d
    80003af6:	00c6873b          	addw	a4,a3,a2
    80003afa:	00777793          	andi	a5,a4,7
    80003afe:	9f95                	subw	a5,a5,a3
    80003b00:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003b04:	4037571b          	sraiw	a4,a4,0x3
    80003b08:	00e906b3          	add	a3,s2,a4
    80003b0c:	0586c683          	lbu	a3,88(a3)
    80003b10:	00d7f5b3          	and	a1,a5,a3
    80003b14:	d195                	beqz	a1,80003a38 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b16:	2605                	addiw	a2,a2,1
    80003b18:	2485                	addiw	s1,s1,1
    80003b1a:	fd4618e3          	bne	a2,s4,80003aea <balloc+0xee>
    80003b1e:	b759                	j	80003aa4 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003b20:	00005517          	auipc	a0,0x5
    80003b24:	bb050513          	addi	a0,a0,-1104 # 800086d0 <syscalls+0x128>
    80003b28:	ffffd097          	auipc	ra,0xffffd
    80003b2c:	a66080e7          	jalr	-1434(ra) # 8000058e <printf>
  return 0;
    80003b30:	4481                	li	s1,0
    80003b32:	bf99                	j	80003a88 <balloc+0x8c>

0000000080003b34 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003b34:	7179                	addi	sp,sp,-48
    80003b36:	f406                	sd	ra,40(sp)
    80003b38:	f022                	sd	s0,32(sp)
    80003b3a:	ec26                	sd	s1,24(sp)
    80003b3c:	e84a                	sd	s2,16(sp)
    80003b3e:	e44e                	sd	s3,8(sp)
    80003b40:	e052                	sd	s4,0(sp)
    80003b42:	1800                	addi	s0,sp,48
    80003b44:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003b46:	47ad                	li	a5,11
    80003b48:	02b7e763          	bltu	a5,a1,80003b76 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003b4c:	02059493          	slli	s1,a1,0x20
    80003b50:	9081                	srli	s1,s1,0x20
    80003b52:	048a                	slli	s1,s1,0x2
    80003b54:	94aa                	add	s1,s1,a0
    80003b56:	0504a903          	lw	s2,80(s1)
    80003b5a:	06091e63          	bnez	s2,80003bd6 <bmap+0xa2>
      addr = balloc(ip->dev);
    80003b5e:	4108                	lw	a0,0(a0)
    80003b60:	00000097          	auipc	ra,0x0
    80003b64:	e9c080e7          	jalr	-356(ra) # 800039fc <balloc>
    80003b68:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003b6c:	06090563          	beqz	s2,80003bd6 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80003b70:	0524a823          	sw	s2,80(s1)
    80003b74:	a08d                	j	80003bd6 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003b76:	ff45849b          	addiw	s1,a1,-12
    80003b7a:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003b7e:	0ff00793          	li	a5,255
    80003b82:	08e7e563          	bltu	a5,a4,80003c0c <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003b86:	08052903          	lw	s2,128(a0)
    80003b8a:	00091d63          	bnez	s2,80003ba4 <bmap+0x70>
      addr = balloc(ip->dev);
    80003b8e:	4108                	lw	a0,0(a0)
    80003b90:	00000097          	auipc	ra,0x0
    80003b94:	e6c080e7          	jalr	-404(ra) # 800039fc <balloc>
    80003b98:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003b9c:	02090d63          	beqz	s2,80003bd6 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003ba0:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003ba4:	85ca                	mv	a1,s2
    80003ba6:	0009a503          	lw	a0,0(s3)
    80003baa:	00000097          	auipc	ra,0x0
    80003bae:	b90080e7          	jalr	-1136(ra) # 8000373a <bread>
    80003bb2:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003bb4:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003bb8:	02049593          	slli	a1,s1,0x20
    80003bbc:	9181                	srli	a1,a1,0x20
    80003bbe:	058a                	slli	a1,a1,0x2
    80003bc0:	00b784b3          	add	s1,a5,a1
    80003bc4:	0004a903          	lw	s2,0(s1)
    80003bc8:	02090063          	beqz	s2,80003be8 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003bcc:	8552                	mv	a0,s4
    80003bce:	00000097          	auipc	ra,0x0
    80003bd2:	c9c080e7          	jalr	-868(ra) # 8000386a <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003bd6:	854a                	mv	a0,s2
    80003bd8:	70a2                	ld	ra,40(sp)
    80003bda:	7402                	ld	s0,32(sp)
    80003bdc:	64e2                	ld	s1,24(sp)
    80003bde:	6942                	ld	s2,16(sp)
    80003be0:	69a2                	ld	s3,8(sp)
    80003be2:	6a02                	ld	s4,0(sp)
    80003be4:	6145                	addi	sp,sp,48
    80003be6:	8082                	ret
      addr = balloc(ip->dev);
    80003be8:	0009a503          	lw	a0,0(s3)
    80003bec:	00000097          	auipc	ra,0x0
    80003bf0:	e10080e7          	jalr	-496(ra) # 800039fc <balloc>
    80003bf4:	0005091b          	sext.w	s2,a0
      if(addr){
    80003bf8:	fc090ae3          	beqz	s2,80003bcc <bmap+0x98>
        a[bn] = addr;
    80003bfc:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003c00:	8552                	mv	a0,s4
    80003c02:	00001097          	auipc	ra,0x1
    80003c06:	eec080e7          	jalr	-276(ra) # 80004aee <log_write>
    80003c0a:	b7c9                	j	80003bcc <bmap+0x98>
  panic("bmap: out of range");
    80003c0c:	00005517          	auipc	a0,0x5
    80003c10:	adc50513          	addi	a0,a0,-1316 # 800086e8 <syscalls+0x140>
    80003c14:	ffffd097          	auipc	ra,0xffffd
    80003c18:	930080e7          	jalr	-1744(ra) # 80000544 <panic>

0000000080003c1c <iget>:
{
    80003c1c:	7179                	addi	sp,sp,-48
    80003c1e:	f406                	sd	ra,40(sp)
    80003c20:	f022                	sd	s0,32(sp)
    80003c22:	ec26                	sd	s1,24(sp)
    80003c24:	e84a                	sd	s2,16(sp)
    80003c26:	e44e                	sd	s3,8(sp)
    80003c28:	e052                	sd	s4,0(sp)
    80003c2a:	1800                	addi	s0,sp,48
    80003c2c:	89aa                	mv	s3,a0
    80003c2e:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003c30:	0023d517          	auipc	a0,0x23d
    80003c34:	18050513          	addi	a0,a0,384 # 80240db0 <itable>
    80003c38:	ffffd097          	auipc	ra,0xffffd
    80003c3c:	170080e7          	jalr	368(ra) # 80000da8 <acquire>
  empty = 0;
    80003c40:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003c42:	0023d497          	auipc	s1,0x23d
    80003c46:	18648493          	addi	s1,s1,390 # 80240dc8 <itable+0x18>
    80003c4a:	0023f697          	auipc	a3,0x23f
    80003c4e:	c0e68693          	addi	a3,a3,-1010 # 80242858 <log>
    80003c52:	a039                	j	80003c60 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003c54:	02090b63          	beqz	s2,80003c8a <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003c58:	08848493          	addi	s1,s1,136
    80003c5c:	02d48a63          	beq	s1,a3,80003c90 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003c60:	449c                	lw	a5,8(s1)
    80003c62:	fef059e3          	blez	a5,80003c54 <iget+0x38>
    80003c66:	4098                	lw	a4,0(s1)
    80003c68:	ff3716e3          	bne	a4,s3,80003c54 <iget+0x38>
    80003c6c:	40d8                	lw	a4,4(s1)
    80003c6e:	ff4713e3          	bne	a4,s4,80003c54 <iget+0x38>
      ip->ref++;
    80003c72:	2785                	addiw	a5,a5,1
    80003c74:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003c76:	0023d517          	auipc	a0,0x23d
    80003c7a:	13a50513          	addi	a0,a0,314 # 80240db0 <itable>
    80003c7e:	ffffd097          	auipc	ra,0xffffd
    80003c82:	1de080e7          	jalr	478(ra) # 80000e5c <release>
      return ip;
    80003c86:	8926                	mv	s2,s1
    80003c88:	a03d                	j	80003cb6 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003c8a:	f7f9                	bnez	a5,80003c58 <iget+0x3c>
    80003c8c:	8926                	mv	s2,s1
    80003c8e:	b7e9                	j	80003c58 <iget+0x3c>
  if(empty == 0)
    80003c90:	02090c63          	beqz	s2,80003cc8 <iget+0xac>
  ip->dev = dev;
    80003c94:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003c98:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003c9c:	4785                	li	a5,1
    80003c9e:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003ca2:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003ca6:	0023d517          	auipc	a0,0x23d
    80003caa:	10a50513          	addi	a0,a0,266 # 80240db0 <itable>
    80003cae:	ffffd097          	auipc	ra,0xffffd
    80003cb2:	1ae080e7          	jalr	430(ra) # 80000e5c <release>
}
    80003cb6:	854a                	mv	a0,s2
    80003cb8:	70a2                	ld	ra,40(sp)
    80003cba:	7402                	ld	s0,32(sp)
    80003cbc:	64e2                	ld	s1,24(sp)
    80003cbe:	6942                	ld	s2,16(sp)
    80003cc0:	69a2                	ld	s3,8(sp)
    80003cc2:	6a02                	ld	s4,0(sp)
    80003cc4:	6145                	addi	sp,sp,48
    80003cc6:	8082                	ret
    panic("iget: no inodes");
    80003cc8:	00005517          	auipc	a0,0x5
    80003ccc:	a3850513          	addi	a0,a0,-1480 # 80008700 <syscalls+0x158>
    80003cd0:	ffffd097          	auipc	ra,0xffffd
    80003cd4:	874080e7          	jalr	-1932(ra) # 80000544 <panic>

0000000080003cd8 <fsinit>:
fsinit(int dev) {
    80003cd8:	7179                	addi	sp,sp,-48
    80003cda:	f406                	sd	ra,40(sp)
    80003cdc:	f022                	sd	s0,32(sp)
    80003cde:	ec26                	sd	s1,24(sp)
    80003ce0:	e84a                	sd	s2,16(sp)
    80003ce2:	e44e                	sd	s3,8(sp)
    80003ce4:	1800                	addi	s0,sp,48
    80003ce6:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003ce8:	4585                	li	a1,1
    80003cea:	00000097          	auipc	ra,0x0
    80003cee:	a50080e7          	jalr	-1456(ra) # 8000373a <bread>
    80003cf2:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003cf4:	0023d997          	auipc	s3,0x23d
    80003cf8:	09c98993          	addi	s3,s3,156 # 80240d90 <sb>
    80003cfc:	02000613          	li	a2,32
    80003d00:	05850593          	addi	a1,a0,88
    80003d04:	854e                	mv	a0,s3
    80003d06:	ffffd097          	auipc	ra,0xffffd
    80003d0a:	1fe080e7          	jalr	510(ra) # 80000f04 <memmove>
  brelse(bp);
    80003d0e:	8526                	mv	a0,s1
    80003d10:	00000097          	auipc	ra,0x0
    80003d14:	b5a080e7          	jalr	-1190(ra) # 8000386a <brelse>
  if(sb.magic != FSMAGIC)
    80003d18:	0009a703          	lw	a4,0(s3)
    80003d1c:	102037b7          	lui	a5,0x10203
    80003d20:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003d24:	02f71263          	bne	a4,a5,80003d48 <fsinit+0x70>
  initlog(dev, &sb);
    80003d28:	0023d597          	auipc	a1,0x23d
    80003d2c:	06858593          	addi	a1,a1,104 # 80240d90 <sb>
    80003d30:	854a                	mv	a0,s2
    80003d32:	00001097          	auipc	ra,0x1
    80003d36:	b40080e7          	jalr	-1216(ra) # 80004872 <initlog>
}
    80003d3a:	70a2                	ld	ra,40(sp)
    80003d3c:	7402                	ld	s0,32(sp)
    80003d3e:	64e2                	ld	s1,24(sp)
    80003d40:	6942                	ld	s2,16(sp)
    80003d42:	69a2                	ld	s3,8(sp)
    80003d44:	6145                	addi	sp,sp,48
    80003d46:	8082                	ret
    panic("invalid file system");
    80003d48:	00005517          	auipc	a0,0x5
    80003d4c:	9c850513          	addi	a0,a0,-1592 # 80008710 <syscalls+0x168>
    80003d50:	ffffc097          	auipc	ra,0xffffc
    80003d54:	7f4080e7          	jalr	2036(ra) # 80000544 <panic>

0000000080003d58 <iinit>:
{
    80003d58:	7179                	addi	sp,sp,-48
    80003d5a:	f406                	sd	ra,40(sp)
    80003d5c:	f022                	sd	s0,32(sp)
    80003d5e:	ec26                	sd	s1,24(sp)
    80003d60:	e84a                	sd	s2,16(sp)
    80003d62:	e44e                	sd	s3,8(sp)
    80003d64:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003d66:	00005597          	auipc	a1,0x5
    80003d6a:	9c258593          	addi	a1,a1,-1598 # 80008728 <syscalls+0x180>
    80003d6e:	0023d517          	auipc	a0,0x23d
    80003d72:	04250513          	addi	a0,a0,66 # 80240db0 <itable>
    80003d76:	ffffd097          	auipc	ra,0xffffd
    80003d7a:	fa2080e7          	jalr	-94(ra) # 80000d18 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003d7e:	0023d497          	auipc	s1,0x23d
    80003d82:	05a48493          	addi	s1,s1,90 # 80240dd8 <itable+0x28>
    80003d86:	0023f997          	auipc	s3,0x23f
    80003d8a:	ae298993          	addi	s3,s3,-1310 # 80242868 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003d8e:	00005917          	auipc	s2,0x5
    80003d92:	9a290913          	addi	s2,s2,-1630 # 80008730 <syscalls+0x188>
    80003d96:	85ca                	mv	a1,s2
    80003d98:	8526                	mv	a0,s1
    80003d9a:	00001097          	auipc	ra,0x1
    80003d9e:	e3a080e7          	jalr	-454(ra) # 80004bd4 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003da2:	08848493          	addi	s1,s1,136
    80003da6:	ff3498e3          	bne	s1,s3,80003d96 <iinit+0x3e>
}
    80003daa:	70a2                	ld	ra,40(sp)
    80003dac:	7402                	ld	s0,32(sp)
    80003dae:	64e2                	ld	s1,24(sp)
    80003db0:	6942                	ld	s2,16(sp)
    80003db2:	69a2                	ld	s3,8(sp)
    80003db4:	6145                	addi	sp,sp,48
    80003db6:	8082                	ret

0000000080003db8 <ialloc>:
{
    80003db8:	715d                	addi	sp,sp,-80
    80003dba:	e486                	sd	ra,72(sp)
    80003dbc:	e0a2                	sd	s0,64(sp)
    80003dbe:	fc26                	sd	s1,56(sp)
    80003dc0:	f84a                	sd	s2,48(sp)
    80003dc2:	f44e                	sd	s3,40(sp)
    80003dc4:	f052                	sd	s4,32(sp)
    80003dc6:	ec56                	sd	s5,24(sp)
    80003dc8:	e85a                	sd	s6,16(sp)
    80003dca:	e45e                	sd	s7,8(sp)
    80003dcc:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003dce:	0023d717          	auipc	a4,0x23d
    80003dd2:	fce72703          	lw	a4,-50(a4) # 80240d9c <sb+0xc>
    80003dd6:	4785                	li	a5,1
    80003dd8:	04e7fa63          	bgeu	a5,a4,80003e2c <ialloc+0x74>
    80003ddc:	8aaa                	mv	s5,a0
    80003dde:	8bae                	mv	s7,a1
    80003de0:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003de2:	0023da17          	auipc	s4,0x23d
    80003de6:	faea0a13          	addi	s4,s4,-82 # 80240d90 <sb>
    80003dea:	00048b1b          	sext.w	s6,s1
    80003dee:	0044d593          	srli	a1,s1,0x4
    80003df2:	018a2783          	lw	a5,24(s4)
    80003df6:	9dbd                	addw	a1,a1,a5
    80003df8:	8556                	mv	a0,s5
    80003dfa:	00000097          	auipc	ra,0x0
    80003dfe:	940080e7          	jalr	-1728(ra) # 8000373a <bread>
    80003e02:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003e04:	05850993          	addi	s3,a0,88
    80003e08:	00f4f793          	andi	a5,s1,15
    80003e0c:	079a                	slli	a5,a5,0x6
    80003e0e:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003e10:	00099783          	lh	a5,0(s3)
    80003e14:	c3a1                	beqz	a5,80003e54 <ialloc+0x9c>
    brelse(bp);
    80003e16:	00000097          	auipc	ra,0x0
    80003e1a:	a54080e7          	jalr	-1452(ra) # 8000386a <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003e1e:	0485                	addi	s1,s1,1
    80003e20:	00ca2703          	lw	a4,12(s4)
    80003e24:	0004879b          	sext.w	a5,s1
    80003e28:	fce7e1e3          	bltu	a5,a4,80003dea <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003e2c:	00005517          	auipc	a0,0x5
    80003e30:	90c50513          	addi	a0,a0,-1780 # 80008738 <syscalls+0x190>
    80003e34:	ffffc097          	auipc	ra,0xffffc
    80003e38:	75a080e7          	jalr	1882(ra) # 8000058e <printf>
  return 0;
    80003e3c:	4501                	li	a0,0
}
    80003e3e:	60a6                	ld	ra,72(sp)
    80003e40:	6406                	ld	s0,64(sp)
    80003e42:	74e2                	ld	s1,56(sp)
    80003e44:	7942                	ld	s2,48(sp)
    80003e46:	79a2                	ld	s3,40(sp)
    80003e48:	7a02                	ld	s4,32(sp)
    80003e4a:	6ae2                	ld	s5,24(sp)
    80003e4c:	6b42                	ld	s6,16(sp)
    80003e4e:	6ba2                	ld	s7,8(sp)
    80003e50:	6161                	addi	sp,sp,80
    80003e52:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003e54:	04000613          	li	a2,64
    80003e58:	4581                	li	a1,0
    80003e5a:	854e                	mv	a0,s3
    80003e5c:	ffffd097          	auipc	ra,0xffffd
    80003e60:	048080e7          	jalr	72(ra) # 80000ea4 <memset>
      dip->type = type;
    80003e64:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003e68:	854a                	mv	a0,s2
    80003e6a:	00001097          	auipc	ra,0x1
    80003e6e:	c84080e7          	jalr	-892(ra) # 80004aee <log_write>
      brelse(bp);
    80003e72:	854a                	mv	a0,s2
    80003e74:	00000097          	auipc	ra,0x0
    80003e78:	9f6080e7          	jalr	-1546(ra) # 8000386a <brelse>
      return iget(dev, inum);
    80003e7c:	85da                	mv	a1,s6
    80003e7e:	8556                	mv	a0,s5
    80003e80:	00000097          	auipc	ra,0x0
    80003e84:	d9c080e7          	jalr	-612(ra) # 80003c1c <iget>
    80003e88:	bf5d                	j	80003e3e <ialloc+0x86>

0000000080003e8a <iupdate>:
{
    80003e8a:	1101                	addi	sp,sp,-32
    80003e8c:	ec06                	sd	ra,24(sp)
    80003e8e:	e822                	sd	s0,16(sp)
    80003e90:	e426                	sd	s1,8(sp)
    80003e92:	e04a                	sd	s2,0(sp)
    80003e94:	1000                	addi	s0,sp,32
    80003e96:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003e98:	415c                	lw	a5,4(a0)
    80003e9a:	0047d79b          	srliw	a5,a5,0x4
    80003e9e:	0023d597          	auipc	a1,0x23d
    80003ea2:	f0a5a583          	lw	a1,-246(a1) # 80240da8 <sb+0x18>
    80003ea6:	9dbd                	addw	a1,a1,a5
    80003ea8:	4108                	lw	a0,0(a0)
    80003eaa:	00000097          	auipc	ra,0x0
    80003eae:	890080e7          	jalr	-1904(ra) # 8000373a <bread>
    80003eb2:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003eb4:	05850793          	addi	a5,a0,88
    80003eb8:	40c8                	lw	a0,4(s1)
    80003eba:	893d                	andi	a0,a0,15
    80003ebc:	051a                	slli	a0,a0,0x6
    80003ebe:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003ec0:	04449703          	lh	a4,68(s1)
    80003ec4:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003ec8:	04649703          	lh	a4,70(s1)
    80003ecc:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003ed0:	04849703          	lh	a4,72(s1)
    80003ed4:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003ed8:	04a49703          	lh	a4,74(s1)
    80003edc:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003ee0:	44f8                	lw	a4,76(s1)
    80003ee2:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003ee4:	03400613          	li	a2,52
    80003ee8:	05048593          	addi	a1,s1,80
    80003eec:	0531                	addi	a0,a0,12
    80003eee:	ffffd097          	auipc	ra,0xffffd
    80003ef2:	016080e7          	jalr	22(ra) # 80000f04 <memmove>
  log_write(bp);
    80003ef6:	854a                	mv	a0,s2
    80003ef8:	00001097          	auipc	ra,0x1
    80003efc:	bf6080e7          	jalr	-1034(ra) # 80004aee <log_write>
  brelse(bp);
    80003f00:	854a                	mv	a0,s2
    80003f02:	00000097          	auipc	ra,0x0
    80003f06:	968080e7          	jalr	-1688(ra) # 8000386a <brelse>
}
    80003f0a:	60e2                	ld	ra,24(sp)
    80003f0c:	6442                	ld	s0,16(sp)
    80003f0e:	64a2                	ld	s1,8(sp)
    80003f10:	6902                	ld	s2,0(sp)
    80003f12:	6105                	addi	sp,sp,32
    80003f14:	8082                	ret

0000000080003f16 <idup>:
{
    80003f16:	1101                	addi	sp,sp,-32
    80003f18:	ec06                	sd	ra,24(sp)
    80003f1a:	e822                	sd	s0,16(sp)
    80003f1c:	e426                	sd	s1,8(sp)
    80003f1e:	1000                	addi	s0,sp,32
    80003f20:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003f22:	0023d517          	auipc	a0,0x23d
    80003f26:	e8e50513          	addi	a0,a0,-370 # 80240db0 <itable>
    80003f2a:	ffffd097          	auipc	ra,0xffffd
    80003f2e:	e7e080e7          	jalr	-386(ra) # 80000da8 <acquire>
  ip->ref++;
    80003f32:	449c                	lw	a5,8(s1)
    80003f34:	2785                	addiw	a5,a5,1
    80003f36:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003f38:	0023d517          	auipc	a0,0x23d
    80003f3c:	e7850513          	addi	a0,a0,-392 # 80240db0 <itable>
    80003f40:	ffffd097          	auipc	ra,0xffffd
    80003f44:	f1c080e7          	jalr	-228(ra) # 80000e5c <release>
}
    80003f48:	8526                	mv	a0,s1
    80003f4a:	60e2                	ld	ra,24(sp)
    80003f4c:	6442                	ld	s0,16(sp)
    80003f4e:	64a2                	ld	s1,8(sp)
    80003f50:	6105                	addi	sp,sp,32
    80003f52:	8082                	ret

0000000080003f54 <ilock>:
{
    80003f54:	1101                	addi	sp,sp,-32
    80003f56:	ec06                	sd	ra,24(sp)
    80003f58:	e822                	sd	s0,16(sp)
    80003f5a:	e426                	sd	s1,8(sp)
    80003f5c:	e04a                	sd	s2,0(sp)
    80003f5e:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003f60:	c115                	beqz	a0,80003f84 <ilock+0x30>
    80003f62:	84aa                	mv	s1,a0
    80003f64:	451c                	lw	a5,8(a0)
    80003f66:	00f05f63          	blez	a5,80003f84 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003f6a:	0541                	addi	a0,a0,16
    80003f6c:	00001097          	auipc	ra,0x1
    80003f70:	ca2080e7          	jalr	-862(ra) # 80004c0e <acquiresleep>
  if(ip->valid == 0){
    80003f74:	40bc                	lw	a5,64(s1)
    80003f76:	cf99                	beqz	a5,80003f94 <ilock+0x40>
}
    80003f78:	60e2                	ld	ra,24(sp)
    80003f7a:	6442                	ld	s0,16(sp)
    80003f7c:	64a2                	ld	s1,8(sp)
    80003f7e:	6902                	ld	s2,0(sp)
    80003f80:	6105                	addi	sp,sp,32
    80003f82:	8082                	ret
    panic("ilock");
    80003f84:	00004517          	auipc	a0,0x4
    80003f88:	7cc50513          	addi	a0,a0,1996 # 80008750 <syscalls+0x1a8>
    80003f8c:	ffffc097          	auipc	ra,0xffffc
    80003f90:	5b8080e7          	jalr	1464(ra) # 80000544 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003f94:	40dc                	lw	a5,4(s1)
    80003f96:	0047d79b          	srliw	a5,a5,0x4
    80003f9a:	0023d597          	auipc	a1,0x23d
    80003f9e:	e0e5a583          	lw	a1,-498(a1) # 80240da8 <sb+0x18>
    80003fa2:	9dbd                	addw	a1,a1,a5
    80003fa4:	4088                	lw	a0,0(s1)
    80003fa6:	fffff097          	auipc	ra,0xfffff
    80003faa:	794080e7          	jalr	1940(ra) # 8000373a <bread>
    80003fae:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003fb0:	05850593          	addi	a1,a0,88
    80003fb4:	40dc                	lw	a5,4(s1)
    80003fb6:	8bbd                	andi	a5,a5,15
    80003fb8:	079a                	slli	a5,a5,0x6
    80003fba:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003fbc:	00059783          	lh	a5,0(a1)
    80003fc0:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003fc4:	00259783          	lh	a5,2(a1)
    80003fc8:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003fcc:	00459783          	lh	a5,4(a1)
    80003fd0:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003fd4:	00659783          	lh	a5,6(a1)
    80003fd8:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003fdc:	459c                	lw	a5,8(a1)
    80003fde:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003fe0:	03400613          	li	a2,52
    80003fe4:	05b1                	addi	a1,a1,12
    80003fe6:	05048513          	addi	a0,s1,80
    80003fea:	ffffd097          	auipc	ra,0xffffd
    80003fee:	f1a080e7          	jalr	-230(ra) # 80000f04 <memmove>
    brelse(bp);
    80003ff2:	854a                	mv	a0,s2
    80003ff4:	00000097          	auipc	ra,0x0
    80003ff8:	876080e7          	jalr	-1930(ra) # 8000386a <brelse>
    ip->valid = 1;
    80003ffc:	4785                	li	a5,1
    80003ffe:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80004000:	04449783          	lh	a5,68(s1)
    80004004:	fbb5                	bnez	a5,80003f78 <ilock+0x24>
      panic("ilock: no type");
    80004006:	00004517          	auipc	a0,0x4
    8000400a:	75250513          	addi	a0,a0,1874 # 80008758 <syscalls+0x1b0>
    8000400e:	ffffc097          	auipc	ra,0xffffc
    80004012:	536080e7          	jalr	1334(ra) # 80000544 <panic>

0000000080004016 <iunlock>:
{
    80004016:	1101                	addi	sp,sp,-32
    80004018:	ec06                	sd	ra,24(sp)
    8000401a:	e822                	sd	s0,16(sp)
    8000401c:	e426                	sd	s1,8(sp)
    8000401e:	e04a                	sd	s2,0(sp)
    80004020:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80004022:	c905                	beqz	a0,80004052 <iunlock+0x3c>
    80004024:	84aa                	mv	s1,a0
    80004026:	01050913          	addi	s2,a0,16
    8000402a:	854a                	mv	a0,s2
    8000402c:	00001097          	auipc	ra,0x1
    80004030:	c7c080e7          	jalr	-900(ra) # 80004ca8 <holdingsleep>
    80004034:	cd19                	beqz	a0,80004052 <iunlock+0x3c>
    80004036:	449c                	lw	a5,8(s1)
    80004038:	00f05d63          	blez	a5,80004052 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000403c:	854a                	mv	a0,s2
    8000403e:	00001097          	auipc	ra,0x1
    80004042:	c26080e7          	jalr	-986(ra) # 80004c64 <releasesleep>
}
    80004046:	60e2                	ld	ra,24(sp)
    80004048:	6442                	ld	s0,16(sp)
    8000404a:	64a2                	ld	s1,8(sp)
    8000404c:	6902                	ld	s2,0(sp)
    8000404e:	6105                	addi	sp,sp,32
    80004050:	8082                	ret
    panic("iunlock");
    80004052:	00004517          	auipc	a0,0x4
    80004056:	71650513          	addi	a0,a0,1814 # 80008768 <syscalls+0x1c0>
    8000405a:	ffffc097          	auipc	ra,0xffffc
    8000405e:	4ea080e7          	jalr	1258(ra) # 80000544 <panic>

0000000080004062 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80004062:	7179                	addi	sp,sp,-48
    80004064:	f406                	sd	ra,40(sp)
    80004066:	f022                	sd	s0,32(sp)
    80004068:	ec26                	sd	s1,24(sp)
    8000406a:	e84a                	sd	s2,16(sp)
    8000406c:	e44e                	sd	s3,8(sp)
    8000406e:	e052                	sd	s4,0(sp)
    80004070:	1800                	addi	s0,sp,48
    80004072:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80004074:	05050493          	addi	s1,a0,80
    80004078:	08050913          	addi	s2,a0,128
    8000407c:	a021                	j	80004084 <itrunc+0x22>
    8000407e:	0491                	addi	s1,s1,4
    80004080:	01248d63          	beq	s1,s2,8000409a <itrunc+0x38>
    if(ip->addrs[i]){
    80004084:	408c                	lw	a1,0(s1)
    80004086:	dde5                	beqz	a1,8000407e <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80004088:	0009a503          	lw	a0,0(s3)
    8000408c:	00000097          	auipc	ra,0x0
    80004090:	8f4080e7          	jalr	-1804(ra) # 80003980 <bfree>
      ip->addrs[i] = 0;
    80004094:	0004a023          	sw	zero,0(s1)
    80004098:	b7dd                	j	8000407e <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000409a:	0809a583          	lw	a1,128(s3)
    8000409e:	e185                	bnez	a1,800040be <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800040a0:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800040a4:	854e                	mv	a0,s3
    800040a6:	00000097          	auipc	ra,0x0
    800040aa:	de4080e7          	jalr	-540(ra) # 80003e8a <iupdate>
}
    800040ae:	70a2                	ld	ra,40(sp)
    800040b0:	7402                	ld	s0,32(sp)
    800040b2:	64e2                	ld	s1,24(sp)
    800040b4:	6942                	ld	s2,16(sp)
    800040b6:	69a2                	ld	s3,8(sp)
    800040b8:	6a02                	ld	s4,0(sp)
    800040ba:	6145                	addi	sp,sp,48
    800040bc:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800040be:	0009a503          	lw	a0,0(s3)
    800040c2:	fffff097          	auipc	ra,0xfffff
    800040c6:	678080e7          	jalr	1656(ra) # 8000373a <bread>
    800040ca:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800040cc:	05850493          	addi	s1,a0,88
    800040d0:	45850913          	addi	s2,a0,1112
    800040d4:	a811                	j	800040e8 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    800040d6:	0009a503          	lw	a0,0(s3)
    800040da:	00000097          	auipc	ra,0x0
    800040de:	8a6080e7          	jalr	-1882(ra) # 80003980 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    800040e2:	0491                	addi	s1,s1,4
    800040e4:	01248563          	beq	s1,s2,800040ee <itrunc+0x8c>
      if(a[j])
    800040e8:	408c                	lw	a1,0(s1)
    800040ea:	dde5                	beqz	a1,800040e2 <itrunc+0x80>
    800040ec:	b7ed                	j	800040d6 <itrunc+0x74>
    brelse(bp);
    800040ee:	8552                	mv	a0,s4
    800040f0:	fffff097          	auipc	ra,0xfffff
    800040f4:	77a080e7          	jalr	1914(ra) # 8000386a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800040f8:	0809a583          	lw	a1,128(s3)
    800040fc:	0009a503          	lw	a0,0(s3)
    80004100:	00000097          	auipc	ra,0x0
    80004104:	880080e7          	jalr	-1920(ra) # 80003980 <bfree>
    ip->addrs[NDIRECT] = 0;
    80004108:	0809a023          	sw	zero,128(s3)
    8000410c:	bf51                	j	800040a0 <itrunc+0x3e>

000000008000410e <iput>:
{
    8000410e:	1101                	addi	sp,sp,-32
    80004110:	ec06                	sd	ra,24(sp)
    80004112:	e822                	sd	s0,16(sp)
    80004114:	e426                	sd	s1,8(sp)
    80004116:	e04a                	sd	s2,0(sp)
    80004118:	1000                	addi	s0,sp,32
    8000411a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000411c:	0023d517          	auipc	a0,0x23d
    80004120:	c9450513          	addi	a0,a0,-876 # 80240db0 <itable>
    80004124:	ffffd097          	auipc	ra,0xffffd
    80004128:	c84080e7          	jalr	-892(ra) # 80000da8 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000412c:	4498                	lw	a4,8(s1)
    8000412e:	4785                	li	a5,1
    80004130:	02f70363          	beq	a4,a5,80004156 <iput+0x48>
  ip->ref--;
    80004134:	449c                	lw	a5,8(s1)
    80004136:	37fd                	addiw	a5,a5,-1
    80004138:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000413a:	0023d517          	auipc	a0,0x23d
    8000413e:	c7650513          	addi	a0,a0,-906 # 80240db0 <itable>
    80004142:	ffffd097          	auipc	ra,0xffffd
    80004146:	d1a080e7          	jalr	-742(ra) # 80000e5c <release>
}
    8000414a:	60e2                	ld	ra,24(sp)
    8000414c:	6442                	ld	s0,16(sp)
    8000414e:	64a2                	ld	s1,8(sp)
    80004150:	6902                	ld	s2,0(sp)
    80004152:	6105                	addi	sp,sp,32
    80004154:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004156:	40bc                	lw	a5,64(s1)
    80004158:	dff1                	beqz	a5,80004134 <iput+0x26>
    8000415a:	04a49783          	lh	a5,74(s1)
    8000415e:	fbf9                	bnez	a5,80004134 <iput+0x26>
    acquiresleep(&ip->lock);
    80004160:	01048913          	addi	s2,s1,16
    80004164:	854a                	mv	a0,s2
    80004166:	00001097          	auipc	ra,0x1
    8000416a:	aa8080e7          	jalr	-1368(ra) # 80004c0e <acquiresleep>
    release(&itable.lock);
    8000416e:	0023d517          	auipc	a0,0x23d
    80004172:	c4250513          	addi	a0,a0,-958 # 80240db0 <itable>
    80004176:	ffffd097          	auipc	ra,0xffffd
    8000417a:	ce6080e7          	jalr	-794(ra) # 80000e5c <release>
    itrunc(ip);
    8000417e:	8526                	mv	a0,s1
    80004180:	00000097          	auipc	ra,0x0
    80004184:	ee2080e7          	jalr	-286(ra) # 80004062 <itrunc>
    ip->type = 0;
    80004188:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000418c:	8526                	mv	a0,s1
    8000418e:	00000097          	auipc	ra,0x0
    80004192:	cfc080e7          	jalr	-772(ra) # 80003e8a <iupdate>
    ip->valid = 0;
    80004196:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000419a:	854a                	mv	a0,s2
    8000419c:	00001097          	auipc	ra,0x1
    800041a0:	ac8080e7          	jalr	-1336(ra) # 80004c64 <releasesleep>
    acquire(&itable.lock);
    800041a4:	0023d517          	auipc	a0,0x23d
    800041a8:	c0c50513          	addi	a0,a0,-1012 # 80240db0 <itable>
    800041ac:	ffffd097          	auipc	ra,0xffffd
    800041b0:	bfc080e7          	jalr	-1028(ra) # 80000da8 <acquire>
    800041b4:	b741                	j	80004134 <iput+0x26>

00000000800041b6 <iunlockput>:
{
    800041b6:	1101                	addi	sp,sp,-32
    800041b8:	ec06                	sd	ra,24(sp)
    800041ba:	e822                	sd	s0,16(sp)
    800041bc:	e426                	sd	s1,8(sp)
    800041be:	1000                	addi	s0,sp,32
    800041c0:	84aa                	mv	s1,a0
  iunlock(ip);
    800041c2:	00000097          	auipc	ra,0x0
    800041c6:	e54080e7          	jalr	-428(ra) # 80004016 <iunlock>
  iput(ip);
    800041ca:	8526                	mv	a0,s1
    800041cc:	00000097          	auipc	ra,0x0
    800041d0:	f42080e7          	jalr	-190(ra) # 8000410e <iput>
}
    800041d4:	60e2                	ld	ra,24(sp)
    800041d6:	6442                	ld	s0,16(sp)
    800041d8:	64a2                	ld	s1,8(sp)
    800041da:	6105                	addi	sp,sp,32
    800041dc:	8082                	ret

00000000800041de <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800041de:	1141                	addi	sp,sp,-16
    800041e0:	e422                	sd	s0,8(sp)
    800041e2:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800041e4:	411c                	lw	a5,0(a0)
    800041e6:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800041e8:	415c                	lw	a5,4(a0)
    800041ea:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800041ec:	04451783          	lh	a5,68(a0)
    800041f0:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800041f4:	04a51783          	lh	a5,74(a0)
    800041f8:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800041fc:	04c56783          	lwu	a5,76(a0)
    80004200:	e99c                	sd	a5,16(a1)
}
    80004202:	6422                	ld	s0,8(sp)
    80004204:	0141                	addi	sp,sp,16
    80004206:	8082                	ret

0000000080004208 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004208:	457c                	lw	a5,76(a0)
    8000420a:	0ed7e963          	bltu	a5,a3,800042fc <readi+0xf4>
{
    8000420e:	7159                	addi	sp,sp,-112
    80004210:	f486                	sd	ra,104(sp)
    80004212:	f0a2                	sd	s0,96(sp)
    80004214:	eca6                	sd	s1,88(sp)
    80004216:	e8ca                	sd	s2,80(sp)
    80004218:	e4ce                	sd	s3,72(sp)
    8000421a:	e0d2                	sd	s4,64(sp)
    8000421c:	fc56                	sd	s5,56(sp)
    8000421e:	f85a                	sd	s6,48(sp)
    80004220:	f45e                	sd	s7,40(sp)
    80004222:	f062                	sd	s8,32(sp)
    80004224:	ec66                	sd	s9,24(sp)
    80004226:	e86a                	sd	s10,16(sp)
    80004228:	e46e                	sd	s11,8(sp)
    8000422a:	1880                	addi	s0,sp,112
    8000422c:	8b2a                	mv	s6,a0
    8000422e:	8bae                	mv	s7,a1
    80004230:	8a32                	mv	s4,a2
    80004232:	84b6                	mv	s1,a3
    80004234:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80004236:	9f35                	addw	a4,a4,a3
    return 0;
    80004238:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000423a:	0ad76063          	bltu	a4,a3,800042da <readi+0xd2>
  if(off + n > ip->size)
    8000423e:	00e7f463          	bgeu	a5,a4,80004246 <readi+0x3e>
    n = ip->size - off;
    80004242:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004246:	0a0a8963          	beqz	s5,800042f8 <readi+0xf0>
    8000424a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000424c:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004250:	5c7d                	li	s8,-1
    80004252:	a82d                	j	8000428c <readi+0x84>
    80004254:	020d1d93          	slli	s11,s10,0x20
    80004258:	020ddd93          	srli	s11,s11,0x20
    8000425c:	05890613          	addi	a2,s2,88
    80004260:	86ee                	mv	a3,s11
    80004262:	963a                	add	a2,a2,a4
    80004264:	85d2                	mv	a1,s4
    80004266:	855e                	mv	a0,s7
    80004268:	ffffe097          	auipc	ra,0xffffe
    8000426c:	79a080e7          	jalr	1946(ra) # 80002a02 <either_copyout>
    80004270:	05850d63          	beq	a0,s8,800042ca <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004274:	854a                	mv	a0,s2
    80004276:	fffff097          	auipc	ra,0xfffff
    8000427a:	5f4080e7          	jalr	1524(ra) # 8000386a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000427e:	013d09bb          	addw	s3,s10,s3
    80004282:	009d04bb          	addw	s1,s10,s1
    80004286:	9a6e                	add	s4,s4,s11
    80004288:	0559f763          	bgeu	s3,s5,800042d6 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    8000428c:	00a4d59b          	srliw	a1,s1,0xa
    80004290:	855a                	mv	a0,s6
    80004292:	00000097          	auipc	ra,0x0
    80004296:	8a2080e7          	jalr	-1886(ra) # 80003b34 <bmap>
    8000429a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000429e:	cd85                	beqz	a1,800042d6 <readi+0xce>
    bp = bread(ip->dev, addr);
    800042a0:	000b2503          	lw	a0,0(s6)
    800042a4:	fffff097          	auipc	ra,0xfffff
    800042a8:	496080e7          	jalr	1174(ra) # 8000373a <bread>
    800042ac:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800042ae:	3ff4f713          	andi	a4,s1,1023
    800042b2:	40ec87bb          	subw	a5,s9,a4
    800042b6:	413a86bb          	subw	a3,s5,s3
    800042ba:	8d3e                	mv	s10,a5
    800042bc:	2781                	sext.w	a5,a5
    800042be:	0006861b          	sext.w	a2,a3
    800042c2:	f8f679e3          	bgeu	a2,a5,80004254 <readi+0x4c>
    800042c6:	8d36                	mv	s10,a3
    800042c8:	b771                	j	80004254 <readi+0x4c>
      brelse(bp);
    800042ca:	854a                	mv	a0,s2
    800042cc:	fffff097          	auipc	ra,0xfffff
    800042d0:	59e080e7          	jalr	1438(ra) # 8000386a <brelse>
      tot = -1;
    800042d4:	59fd                	li	s3,-1
  }
  return tot;
    800042d6:	0009851b          	sext.w	a0,s3
}
    800042da:	70a6                	ld	ra,104(sp)
    800042dc:	7406                	ld	s0,96(sp)
    800042de:	64e6                	ld	s1,88(sp)
    800042e0:	6946                	ld	s2,80(sp)
    800042e2:	69a6                	ld	s3,72(sp)
    800042e4:	6a06                	ld	s4,64(sp)
    800042e6:	7ae2                	ld	s5,56(sp)
    800042e8:	7b42                	ld	s6,48(sp)
    800042ea:	7ba2                	ld	s7,40(sp)
    800042ec:	7c02                	ld	s8,32(sp)
    800042ee:	6ce2                	ld	s9,24(sp)
    800042f0:	6d42                	ld	s10,16(sp)
    800042f2:	6da2                	ld	s11,8(sp)
    800042f4:	6165                	addi	sp,sp,112
    800042f6:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800042f8:	89d6                	mv	s3,s5
    800042fa:	bff1                	j	800042d6 <readi+0xce>
    return 0;
    800042fc:	4501                	li	a0,0
}
    800042fe:	8082                	ret

0000000080004300 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004300:	457c                	lw	a5,76(a0)
    80004302:	10d7e863          	bltu	a5,a3,80004412 <writei+0x112>
{
    80004306:	7159                	addi	sp,sp,-112
    80004308:	f486                	sd	ra,104(sp)
    8000430a:	f0a2                	sd	s0,96(sp)
    8000430c:	eca6                	sd	s1,88(sp)
    8000430e:	e8ca                	sd	s2,80(sp)
    80004310:	e4ce                	sd	s3,72(sp)
    80004312:	e0d2                	sd	s4,64(sp)
    80004314:	fc56                	sd	s5,56(sp)
    80004316:	f85a                	sd	s6,48(sp)
    80004318:	f45e                	sd	s7,40(sp)
    8000431a:	f062                	sd	s8,32(sp)
    8000431c:	ec66                	sd	s9,24(sp)
    8000431e:	e86a                	sd	s10,16(sp)
    80004320:	e46e                	sd	s11,8(sp)
    80004322:	1880                	addi	s0,sp,112
    80004324:	8aaa                	mv	s5,a0
    80004326:	8bae                	mv	s7,a1
    80004328:	8a32                	mv	s4,a2
    8000432a:	8936                	mv	s2,a3
    8000432c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000432e:	00e687bb          	addw	a5,a3,a4
    80004332:	0ed7e263          	bltu	a5,a3,80004416 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004336:	00043737          	lui	a4,0x43
    8000433a:	0ef76063          	bltu	a4,a5,8000441a <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000433e:	0c0b0863          	beqz	s6,8000440e <writei+0x10e>
    80004342:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004344:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004348:	5c7d                	li	s8,-1
    8000434a:	a091                	j	8000438e <writei+0x8e>
    8000434c:	020d1d93          	slli	s11,s10,0x20
    80004350:	020ddd93          	srli	s11,s11,0x20
    80004354:	05848513          	addi	a0,s1,88
    80004358:	86ee                	mv	a3,s11
    8000435a:	8652                	mv	a2,s4
    8000435c:	85de                	mv	a1,s7
    8000435e:	953a                	add	a0,a0,a4
    80004360:	ffffe097          	auipc	ra,0xffffe
    80004364:	6f8080e7          	jalr	1784(ra) # 80002a58 <either_copyin>
    80004368:	07850263          	beq	a0,s8,800043cc <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000436c:	8526                	mv	a0,s1
    8000436e:	00000097          	auipc	ra,0x0
    80004372:	780080e7          	jalr	1920(ra) # 80004aee <log_write>
    brelse(bp);
    80004376:	8526                	mv	a0,s1
    80004378:	fffff097          	auipc	ra,0xfffff
    8000437c:	4f2080e7          	jalr	1266(ra) # 8000386a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004380:	013d09bb          	addw	s3,s10,s3
    80004384:	012d093b          	addw	s2,s10,s2
    80004388:	9a6e                	add	s4,s4,s11
    8000438a:	0569f663          	bgeu	s3,s6,800043d6 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    8000438e:	00a9559b          	srliw	a1,s2,0xa
    80004392:	8556                	mv	a0,s5
    80004394:	fffff097          	auipc	ra,0xfffff
    80004398:	7a0080e7          	jalr	1952(ra) # 80003b34 <bmap>
    8000439c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800043a0:	c99d                	beqz	a1,800043d6 <writei+0xd6>
    bp = bread(ip->dev, addr);
    800043a2:	000aa503          	lw	a0,0(s5)
    800043a6:	fffff097          	auipc	ra,0xfffff
    800043aa:	394080e7          	jalr	916(ra) # 8000373a <bread>
    800043ae:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800043b0:	3ff97713          	andi	a4,s2,1023
    800043b4:	40ec87bb          	subw	a5,s9,a4
    800043b8:	413b06bb          	subw	a3,s6,s3
    800043bc:	8d3e                	mv	s10,a5
    800043be:	2781                	sext.w	a5,a5
    800043c0:	0006861b          	sext.w	a2,a3
    800043c4:	f8f674e3          	bgeu	a2,a5,8000434c <writei+0x4c>
    800043c8:	8d36                	mv	s10,a3
    800043ca:	b749                	j	8000434c <writei+0x4c>
      brelse(bp);
    800043cc:	8526                	mv	a0,s1
    800043ce:	fffff097          	auipc	ra,0xfffff
    800043d2:	49c080e7          	jalr	1180(ra) # 8000386a <brelse>
  }

  if(off > ip->size)
    800043d6:	04caa783          	lw	a5,76(s5)
    800043da:	0127f463          	bgeu	a5,s2,800043e2 <writei+0xe2>
    ip->size = off;
    800043de:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800043e2:	8556                	mv	a0,s5
    800043e4:	00000097          	auipc	ra,0x0
    800043e8:	aa6080e7          	jalr	-1370(ra) # 80003e8a <iupdate>

  return tot;
    800043ec:	0009851b          	sext.w	a0,s3
}
    800043f0:	70a6                	ld	ra,104(sp)
    800043f2:	7406                	ld	s0,96(sp)
    800043f4:	64e6                	ld	s1,88(sp)
    800043f6:	6946                	ld	s2,80(sp)
    800043f8:	69a6                	ld	s3,72(sp)
    800043fa:	6a06                	ld	s4,64(sp)
    800043fc:	7ae2                	ld	s5,56(sp)
    800043fe:	7b42                	ld	s6,48(sp)
    80004400:	7ba2                	ld	s7,40(sp)
    80004402:	7c02                	ld	s8,32(sp)
    80004404:	6ce2                	ld	s9,24(sp)
    80004406:	6d42                	ld	s10,16(sp)
    80004408:	6da2                	ld	s11,8(sp)
    8000440a:	6165                	addi	sp,sp,112
    8000440c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000440e:	89da                	mv	s3,s6
    80004410:	bfc9                	j	800043e2 <writei+0xe2>
    return -1;
    80004412:	557d                	li	a0,-1
}
    80004414:	8082                	ret
    return -1;
    80004416:	557d                	li	a0,-1
    80004418:	bfe1                	j	800043f0 <writei+0xf0>
    return -1;
    8000441a:	557d                	li	a0,-1
    8000441c:	bfd1                	j	800043f0 <writei+0xf0>

000000008000441e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000441e:	1141                	addi	sp,sp,-16
    80004420:	e406                	sd	ra,8(sp)
    80004422:	e022                	sd	s0,0(sp)
    80004424:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004426:	4639                	li	a2,14
    80004428:	ffffd097          	auipc	ra,0xffffd
    8000442c:	b54080e7          	jalr	-1196(ra) # 80000f7c <strncmp>
}
    80004430:	60a2                	ld	ra,8(sp)
    80004432:	6402                	ld	s0,0(sp)
    80004434:	0141                	addi	sp,sp,16
    80004436:	8082                	ret

0000000080004438 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004438:	7139                	addi	sp,sp,-64
    8000443a:	fc06                	sd	ra,56(sp)
    8000443c:	f822                	sd	s0,48(sp)
    8000443e:	f426                	sd	s1,40(sp)
    80004440:	f04a                	sd	s2,32(sp)
    80004442:	ec4e                	sd	s3,24(sp)
    80004444:	e852                	sd	s4,16(sp)
    80004446:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004448:	04451703          	lh	a4,68(a0)
    8000444c:	4785                	li	a5,1
    8000444e:	00f71a63          	bne	a4,a5,80004462 <dirlookup+0x2a>
    80004452:	892a                	mv	s2,a0
    80004454:	89ae                	mv	s3,a1
    80004456:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004458:	457c                	lw	a5,76(a0)
    8000445a:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000445c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000445e:	e79d                	bnez	a5,8000448c <dirlookup+0x54>
    80004460:	a8a5                	j	800044d8 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004462:	00004517          	auipc	a0,0x4
    80004466:	30e50513          	addi	a0,a0,782 # 80008770 <syscalls+0x1c8>
    8000446a:	ffffc097          	auipc	ra,0xffffc
    8000446e:	0da080e7          	jalr	218(ra) # 80000544 <panic>
      panic("dirlookup read");
    80004472:	00004517          	auipc	a0,0x4
    80004476:	31650513          	addi	a0,a0,790 # 80008788 <syscalls+0x1e0>
    8000447a:	ffffc097          	auipc	ra,0xffffc
    8000447e:	0ca080e7          	jalr	202(ra) # 80000544 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004482:	24c1                	addiw	s1,s1,16
    80004484:	04c92783          	lw	a5,76(s2)
    80004488:	04f4f763          	bgeu	s1,a5,800044d6 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000448c:	4741                	li	a4,16
    8000448e:	86a6                	mv	a3,s1
    80004490:	fc040613          	addi	a2,s0,-64
    80004494:	4581                	li	a1,0
    80004496:	854a                	mv	a0,s2
    80004498:	00000097          	auipc	ra,0x0
    8000449c:	d70080e7          	jalr	-656(ra) # 80004208 <readi>
    800044a0:	47c1                	li	a5,16
    800044a2:	fcf518e3          	bne	a0,a5,80004472 <dirlookup+0x3a>
    if(de.inum == 0)
    800044a6:	fc045783          	lhu	a5,-64(s0)
    800044aa:	dfe1                	beqz	a5,80004482 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800044ac:	fc240593          	addi	a1,s0,-62
    800044b0:	854e                	mv	a0,s3
    800044b2:	00000097          	auipc	ra,0x0
    800044b6:	f6c080e7          	jalr	-148(ra) # 8000441e <namecmp>
    800044ba:	f561                	bnez	a0,80004482 <dirlookup+0x4a>
      if(poff)
    800044bc:	000a0463          	beqz	s4,800044c4 <dirlookup+0x8c>
        *poff = off;
    800044c0:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800044c4:	fc045583          	lhu	a1,-64(s0)
    800044c8:	00092503          	lw	a0,0(s2)
    800044cc:	fffff097          	auipc	ra,0xfffff
    800044d0:	750080e7          	jalr	1872(ra) # 80003c1c <iget>
    800044d4:	a011                	j	800044d8 <dirlookup+0xa0>
  return 0;
    800044d6:	4501                	li	a0,0
}
    800044d8:	70e2                	ld	ra,56(sp)
    800044da:	7442                	ld	s0,48(sp)
    800044dc:	74a2                	ld	s1,40(sp)
    800044de:	7902                	ld	s2,32(sp)
    800044e0:	69e2                	ld	s3,24(sp)
    800044e2:	6a42                	ld	s4,16(sp)
    800044e4:	6121                	addi	sp,sp,64
    800044e6:	8082                	ret

00000000800044e8 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800044e8:	711d                	addi	sp,sp,-96
    800044ea:	ec86                	sd	ra,88(sp)
    800044ec:	e8a2                	sd	s0,80(sp)
    800044ee:	e4a6                	sd	s1,72(sp)
    800044f0:	e0ca                	sd	s2,64(sp)
    800044f2:	fc4e                	sd	s3,56(sp)
    800044f4:	f852                	sd	s4,48(sp)
    800044f6:	f456                	sd	s5,40(sp)
    800044f8:	f05a                	sd	s6,32(sp)
    800044fa:	ec5e                	sd	s7,24(sp)
    800044fc:	e862                	sd	s8,16(sp)
    800044fe:	e466                	sd	s9,8(sp)
    80004500:	1080                	addi	s0,sp,96
    80004502:	84aa                	mv	s1,a0
    80004504:	8b2e                	mv	s6,a1
    80004506:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004508:	00054703          	lbu	a4,0(a0)
    8000450c:	02f00793          	li	a5,47
    80004510:	02f70363          	beq	a4,a5,80004536 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004514:	ffffd097          	auipc	ra,0xffffd
    80004518:	7a4080e7          	jalr	1956(ra) # 80001cb8 <myproc>
    8000451c:	15853503          	ld	a0,344(a0)
    80004520:	00000097          	auipc	ra,0x0
    80004524:	9f6080e7          	jalr	-1546(ra) # 80003f16 <idup>
    80004528:	89aa                	mv	s3,a0
  while(*path == '/')
    8000452a:	02f00913          	li	s2,47
  len = path - s;
    8000452e:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80004530:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004532:	4c05                	li	s8,1
    80004534:	a865                	j	800045ec <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80004536:	4585                	li	a1,1
    80004538:	4505                	li	a0,1
    8000453a:	fffff097          	auipc	ra,0xfffff
    8000453e:	6e2080e7          	jalr	1762(ra) # 80003c1c <iget>
    80004542:	89aa                	mv	s3,a0
    80004544:	b7dd                	j	8000452a <namex+0x42>
      iunlockput(ip);
    80004546:	854e                	mv	a0,s3
    80004548:	00000097          	auipc	ra,0x0
    8000454c:	c6e080e7          	jalr	-914(ra) # 800041b6 <iunlockput>
      return 0;
    80004550:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004552:	854e                	mv	a0,s3
    80004554:	60e6                	ld	ra,88(sp)
    80004556:	6446                	ld	s0,80(sp)
    80004558:	64a6                	ld	s1,72(sp)
    8000455a:	6906                	ld	s2,64(sp)
    8000455c:	79e2                	ld	s3,56(sp)
    8000455e:	7a42                	ld	s4,48(sp)
    80004560:	7aa2                	ld	s5,40(sp)
    80004562:	7b02                	ld	s6,32(sp)
    80004564:	6be2                	ld	s7,24(sp)
    80004566:	6c42                	ld	s8,16(sp)
    80004568:	6ca2                	ld	s9,8(sp)
    8000456a:	6125                	addi	sp,sp,96
    8000456c:	8082                	ret
      iunlock(ip);
    8000456e:	854e                	mv	a0,s3
    80004570:	00000097          	auipc	ra,0x0
    80004574:	aa6080e7          	jalr	-1370(ra) # 80004016 <iunlock>
      return ip;
    80004578:	bfe9                	j	80004552 <namex+0x6a>
      iunlockput(ip);
    8000457a:	854e                	mv	a0,s3
    8000457c:	00000097          	auipc	ra,0x0
    80004580:	c3a080e7          	jalr	-966(ra) # 800041b6 <iunlockput>
      return 0;
    80004584:	89d2                	mv	s3,s4
    80004586:	b7f1                	j	80004552 <namex+0x6a>
  len = path - s;
    80004588:	40b48633          	sub	a2,s1,a1
    8000458c:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80004590:	094cd463          	bge	s9,s4,80004618 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004594:	4639                	li	a2,14
    80004596:	8556                	mv	a0,s5
    80004598:	ffffd097          	auipc	ra,0xffffd
    8000459c:	96c080e7          	jalr	-1684(ra) # 80000f04 <memmove>
  while(*path == '/')
    800045a0:	0004c783          	lbu	a5,0(s1)
    800045a4:	01279763          	bne	a5,s2,800045b2 <namex+0xca>
    path++;
    800045a8:	0485                	addi	s1,s1,1
  while(*path == '/')
    800045aa:	0004c783          	lbu	a5,0(s1)
    800045ae:	ff278de3          	beq	a5,s2,800045a8 <namex+0xc0>
    ilock(ip);
    800045b2:	854e                	mv	a0,s3
    800045b4:	00000097          	auipc	ra,0x0
    800045b8:	9a0080e7          	jalr	-1632(ra) # 80003f54 <ilock>
    if(ip->type != T_DIR){
    800045bc:	04499783          	lh	a5,68(s3)
    800045c0:	f98793e3          	bne	a5,s8,80004546 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800045c4:	000b0563          	beqz	s6,800045ce <namex+0xe6>
    800045c8:	0004c783          	lbu	a5,0(s1)
    800045cc:	d3cd                	beqz	a5,8000456e <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800045ce:	865e                	mv	a2,s7
    800045d0:	85d6                	mv	a1,s5
    800045d2:	854e                	mv	a0,s3
    800045d4:	00000097          	auipc	ra,0x0
    800045d8:	e64080e7          	jalr	-412(ra) # 80004438 <dirlookup>
    800045dc:	8a2a                	mv	s4,a0
    800045de:	dd51                	beqz	a0,8000457a <namex+0x92>
    iunlockput(ip);
    800045e0:	854e                	mv	a0,s3
    800045e2:	00000097          	auipc	ra,0x0
    800045e6:	bd4080e7          	jalr	-1068(ra) # 800041b6 <iunlockput>
    ip = next;
    800045ea:	89d2                	mv	s3,s4
  while(*path == '/')
    800045ec:	0004c783          	lbu	a5,0(s1)
    800045f0:	05279763          	bne	a5,s2,8000463e <namex+0x156>
    path++;
    800045f4:	0485                	addi	s1,s1,1
  while(*path == '/')
    800045f6:	0004c783          	lbu	a5,0(s1)
    800045fa:	ff278de3          	beq	a5,s2,800045f4 <namex+0x10c>
  if(*path == 0)
    800045fe:	c79d                	beqz	a5,8000462c <namex+0x144>
    path++;
    80004600:	85a6                	mv	a1,s1
  len = path - s;
    80004602:	8a5e                	mv	s4,s7
    80004604:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80004606:	01278963          	beq	a5,s2,80004618 <namex+0x130>
    8000460a:	dfbd                	beqz	a5,80004588 <namex+0xa0>
    path++;
    8000460c:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000460e:	0004c783          	lbu	a5,0(s1)
    80004612:	ff279ce3          	bne	a5,s2,8000460a <namex+0x122>
    80004616:	bf8d                	j	80004588 <namex+0xa0>
    memmove(name, s, len);
    80004618:	2601                	sext.w	a2,a2
    8000461a:	8556                	mv	a0,s5
    8000461c:	ffffd097          	auipc	ra,0xffffd
    80004620:	8e8080e7          	jalr	-1816(ra) # 80000f04 <memmove>
    name[len] = 0;
    80004624:	9a56                	add	s4,s4,s5
    80004626:	000a0023          	sb	zero,0(s4)
    8000462a:	bf9d                	j	800045a0 <namex+0xb8>
  if(nameiparent){
    8000462c:	f20b03e3          	beqz	s6,80004552 <namex+0x6a>
    iput(ip);
    80004630:	854e                	mv	a0,s3
    80004632:	00000097          	auipc	ra,0x0
    80004636:	adc080e7          	jalr	-1316(ra) # 8000410e <iput>
    return 0;
    8000463a:	4981                	li	s3,0
    8000463c:	bf19                	j	80004552 <namex+0x6a>
  if(*path == 0)
    8000463e:	d7fd                	beqz	a5,8000462c <namex+0x144>
  while(*path != '/' && *path != 0)
    80004640:	0004c783          	lbu	a5,0(s1)
    80004644:	85a6                	mv	a1,s1
    80004646:	b7d1                	j	8000460a <namex+0x122>

0000000080004648 <dirlink>:
{
    80004648:	7139                	addi	sp,sp,-64
    8000464a:	fc06                	sd	ra,56(sp)
    8000464c:	f822                	sd	s0,48(sp)
    8000464e:	f426                	sd	s1,40(sp)
    80004650:	f04a                	sd	s2,32(sp)
    80004652:	ec4e                	sd	s3,24(sp)
    80004654:	e852                	sd	s4,16(sp)
    80004656:	0080                	addi	s0,sp,64
    80004658:	892a                	mv	s2,a0
    8000465a:	8a2e                	mv	s4,a1
    8000465c:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000465e:	4601                	li	a2,0
    80004660:	00000097          	auipc	ra,0x0
    80004664:	dd8080e7          	jalr	-552(ra) # 80004438 <dirlookup>
    80004668:	e93d                	bnez	a0,800046de <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000466a:	04c92483          	lw	s1,76(s2)
    8000466e:	c49d                	beqz	s1,8000469c <dirlink+0x54>
    80004670:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004672:	4741                	li	a4,16
    80004674:	86a6                	mv	a3,s1
    80004676:	fc040613          	addi	a2,s0,-64
    8000467a:	4581                	li	a1,0
    8000467c:	854a                	mv	a0,s2
    8000467e:	00000097          	auipc	ra,0x0
    80004682:	b8a080e7          	jalr	-1142(ra) # 80004208 <readi>
    80004686:	47c1                	li	a5,16
    80004688:	06f51163          	bne	a0,a5,800046ea <dirlink+0xa2>
    if(de.inum == 0)
    8000468c:	fc045783          	lhu	a5,-64(s0)
    80004690:	c791                	beqz	a5,8000469c <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004692:	24c1                	addiw	s1,s1,16
    80004694:	04c92783          	lw	a5,76(s2)
    80004698:	fcf4ede3          	bltu	s1,a5,80004672 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000469c:	4639                	li	a2,14
    8000469e:	85d2                	mv	a1,s4
    800046a0:	fc240513          	addi	a0,s0,-62
    800046a4:	ffffd097          	auipc	ra,0xffffd
    800046a8:	914080e7          	jalr	-1772(ra) # 80000fb8 <strncpy>
  de.inum = inum;
    800046ac:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800046b0:	4741                	li	a4,16
    800046b2:	86a6                	mv	a3,s1
    800046b4:	fc040613          	addi	a2,s0,-64
    800046b8:	4581                	li	a1,0
    800046ba:	854a                	mv	a0,s2
    800046bc:	00000097          	auipc	ra,0x0
    800046c0:	c44080e7          	jalr	-956(ra) # 80004300 <writei>
    800046c4:	1541                	addi	a0,a0,-16
    800046c6:	00a03533          	snez	a0,a0
    800046ca:	40a00533          	neg	a0,a0
}
    800046ce:	70e2                	ld	ra,56(sp)
    800046d0:	7442                	ld	s0,48(sp)
    800046d2:	74a2                	ld	s1,40(sp)
    800046d4:	7902                	ld	s2,32(sp)
    800046d6:	69e2                	ld	s3,24(sp)
    800046d8:	6a42                	ld	s4,16(sp)
    800046da:	6121                	addi	sp,sp,64
    800046dc:	8082                	ret
    iput(ip);
    800046de:	00000097          	auipc	ra,0x0
    800046e2:	a30080e7          	jalr	-1488(ra) # 8000410e <iput>
    return -1;
    800046e6:	557d                	li	a0,-1
    800046e8:	b7dd                	j	800046ce <dirlink+0x86>
      panic("dirlink read");
    800046ea:	00004517          	auipc	a0,0x4
    800046ee:	0ae50513          	addi	a0,a0,174 # 80008798 <syscalls+0x1f0>
    800046f2:	ffffc097          	auipc	ra,0xffffc
    800046f6:	e52080e7          	jalr	-430(ra) # 80000544 <panic>

00000000800046fa <namei>:

struct inode*
namei(char *path)
{
    800046fa:	1101                	addi	sp,sp,-32
    800046fc:	ec06                	sd	ra,24(sp)
    800046fe:	e822                	sd	s0,16(sp)
    80004700:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004702:	fe040613          	addi	a2,s0,-32
    80004706:	4581                	li	a1,0
    80004708:	00000097          	auipc	ra,0x0
    8000470c:	de0080e7          	jalr	-544(ra) # 800044e8 <namex>
}
    80004710:	60e2                	ld	ra,24(sp)
    80004712:	6442                	ld	s0,16(sp)
    80004714:	6105                	addi	sp,sp,32
    80004716:	8082                	ret

0000000080004718 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004718:	1141                	addi	sp,sp,-16
    8000471a:	e406                	sd	ra,8(sp)
    8000471c:	e022                	sd	s0,0(sp)
    8000471e:	0800                	addi	s0,sp,16
    80004720:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004722:	4585                	li	a1,1
    80004724:	00000097          	auipc	ra,0x0
    80004728:	dc4080e7          	jalr	-572(ra) # 800044e8 <namex>
}
    8000472c:	60a2                	ld	ra,8(sp)
    8000472e:	6402                	ld	s0,0(sp)
    80004730:	0141                	addi	sp,sp,16
    80004732:	8082                	ret

0000000080004734 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004734:	1101                	addi	sp,sp,-32
    80004736:	ec06                	sd	ra,24(sp)
    80004738:	e822                	sd	s0,16(sp)
    8000473a:	e426                	sd	s1,8(sp)
    8000473c:	e04a                	sd	s2,0(sp)
    8000473e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004740:	0023e917          	auipc	s2,0x23e
    80004744:	11890913          	addi	s2,s2,280 # 80242858 <log>
    80004748:	01892583          	lw	a1,24(s2)
    8000474c:	02892503          	lw	a0,40(s2)
    80004750:	fffff097          	auipc	ra,0xfffff
    80004754:	fea080e7          	jalr	-22(ra) # 8000373a <bread>
    80004758:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000475a:	02c92683          	lw	a3,44(s2)
    8000475e:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004760:	02d05763          	blez	a3,8000478e <write_head+0x5a>
    80004764:	0023e797          	auipc	a5,0x23e
    80004768:	12478793          	addi	a5,a5,292 # 80242888 <log+0x30>
    8000476c:	05c50713          	addi	a4,a0,92
    80004770:	36fd                	addiw	a3,a3,-1
    80004772:	1682                	slli	a3,a3,0x20
    80004774:	9281                	srli	a3,a3,0x20
    80004776:	068a                	slli	a3,a3,0x2
    80004778:	0023e617          	auipc	a2,0x23e
    8000477c:	11460613          	addi	a2,a2,276 # 8024288c <log+0x34>
    80004780:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004782:	4390                	lw	a2,0(a5)
    80004784:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004786:	0791                	addi	a5,a5,4
    80004788:	0711                	addi	a4,a4,4
    8000478a:	fed79ce3          	bne	a5,a3,80004782 <write_head+0x4e>
  }
  bwrite(buf);
    8000478e:	8526                	mv	a0,s1
    80004790:	fffff097          	auipc	ra,0xfffff
    80004794:	09c080e7          	jalr	156(ra) # 8000382c <bwrite>
  brelse(buf);
    80004798:	8526                	mv	a0,s1
    8000479a:	fffff097          	auipc	ra,0xfffff
    8000479e:	0d0080e7          	jalr	208(ra) # 8000386a <brelse>
}
    800047a2:	60e2                	ld	ra,24(sp)
    800047a4:	6442                	ld	s0,16(sp)
    800047a6:	64a2                	ld	s1,8(sp)
    800047a8:	6902                	ld	s2,0(sp)
    800047aa:	6105                	addi	sp,sp,32
    800047ac:	8082                	ret

00000000800047ae <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800047ae:	0023e797          	auipc	a5,0x23e
    800047b2:	0d67a783          	lw	a5,214(a5) # 80242884 <log+0x2c>
    800047b6:	0af05d63          	blez	a5,80004870 <install_trans+0xc2>
{
    800047ba:	7139                	addi	sp,sp,-64
    800047bc:	fc06                	sd	ra,56(sp)
    800047be:	f822                	sd	s0,48(sp)
    800047c0:	f426                	sd	s1,40(sp)
    800047c2:	f04a                	sd	s2,32(sp)
    800047c4:	ec4e                	sd	s3,24(sp)
    800047c6:	e852                	sd	s4,16(sp)
    800047c8:	e456                	sd	s5,8(sp)
    800047ca:	e05a                	sd	s6,0(sp)
    800047cc:	0080                	addi	s0,sp,64
    800047ce:	8b2a                	mv	s6,a0
    800047d0:	0023ea97          	auipc	s5,0x23e
    800047d4:	0b8a8a93          	addi	s5,s5,184 # 80242888 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800047d8:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800047da:	0023e997          	auipc	s3,0x23e
    800047de:	07e98993          	addi	s3,s3,126 # 80242858 <log>
    800047e2:	a035                	j	8000480e <install_trans+0x60>
      bunpin(dbuf);
    800047e4:	8526                	mv	a0,s1
    800047e6:	fffff097          	auipc	ra,0xfffff
    800047ea:	15e080e7          	jalr	350(ra) # 80003944 <bunpin>
    brelse(lbuf);
    800047ee:	854a                	mv	a0,s2
    800047f0:	fffff097          	auipc	ra,0xfffff
    800047f4:	07a080e7          	jalr	122(ra) # 8000386a <brelse>
    brelse(dbuf);
    800047f8:	8526                	mv	a0,s1
    800047fa:	fffff097          	auipc	ra,0xfffff
    800047fe:	070080e7          	jalr	112(ra) # 8000386a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004802:	2a05                	addiw	s4,s4,1
    80004804:	0a91                	addi	s5,s5,4
    80004806:	02c9a783          	lw	a5,44(s3)
    8000480a:	04fa5963          	bge	s4,a5,8000485c <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000480e:	0189a583          	lw	a1,24(s3)
    80004812:	014585bb          	addw	a1,a1,s4
    80004816:	2585                	addiw	a1,a1,1
    80004818:	0289a503          	lw	a0,40(s3)
    8000481c:	fffff097          	auipc	ra,0xfffff
    80004820:	f1e080e7          	jalr	-226(ra) # 8000373a <bread>
    80004824:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004826:	000aa583          	lw	a1,0(s5)
    8000482a:	0289a503          	lw	a0,40(s3)
    8000482e:	fffff097          	auipc	ra,0xfffff
    80004832:	f0c080e7          	jalr	-244(ra) # 8000373a <bread>
    80004836:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004838:	40000613          	li	a2,1024
    8000483c:	05890593          	addi	a1,s2,88
    80004840:	05850513          	addi	a0,a0,88
    80004844:	ffffc097          	auipc	ra,0xffffc
    80004848:	6c0080e7          	jalr	1728(ra) # 80000f04 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000484c:	8526                	mv	a0,s1
    8000484e:	fffff097          	auipc	ra,0xfffff
    80004852:	fde080e7          	jalr	-34(ra) # 8000382c <bwrite>
    if(recovering == 0)
    80004856:	f80b1ce3          	bnez	s6,800047ee <install_trans+0x40>
    8000485a:	b769                	j	800047e4 <install_trans+0x36>
}
    8000485c:	70e2                	ld	ra,56(sp)
    8000485e:	7442                	ld	s0,48(sp)
    80004860:	74a2                	ld	s1,40(sp)
    80004862:	7902                	ld	s2,32(sp)
    80004864:	69e2                	ld	s3,24(sp)
    80004866:	6a42                	ld	s4,16(sp)
    80004868:	6aa2                	ld	s5,8(sp)
    8000486a:	6b02                	ld	s6,0(sp)
    8000486c:	6121                	addi	sp,sp,64
    8000486e:	8082                	ret
    80004870:	8082                	ret

0000000080004872 <initlog>:
{
    80004872:	7179                	addi	sp,sp,-48
    80004874:	f406                	sd	ra,40(sp)
    80004876:	f022                	sd	s0,32(sp)
    80004878:	ec26                	sd	s1,24(sp)
    8000487a:	e84a                	sd	s2,16(sp)
    8000487c:	e44e                	sd	s3,8(sp)
    8000487e:	1800                	addi	s0,sp,48
    80004880:	892a                	mv	s2,a0
    80004882:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004884:	0023e497          	auipc	s1,0x23e
    80004888:	fd448493          	addi	s1,s1,-44 # 80242858 <log>
    8000488c:	00004597          	auipc	a1,0x4
    80004890:	f1c58593          	addi	a1,a1,-228 # 800087a8 <syscalls+0x200>
    80004894:	8526                	mv	a0,s1
    80004896:	ffffc097          	auipc	ra,0xffffc
    8000489a:	482080e7          	jalr	1154(ra) # 80000d18 <initlock>
  log.start = sb->logstart;
    8000489e:	0149a583          	lw	a1,20(s3)
    800048a2:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800048a4:	0109a783          	lw	a5,16(s3)
    800048a8:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800048aa:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800048ae:	854a                	mv	a0,s2
    800048b0:	fffff097          	auipc	ra,0xfffff
    800048b4:	e8a080e7          	jalr	-374(ra) # 8000373a <bread>
  log.lh.n = lh->n;
    800048b8:	4d3c                	lw	a5,88(a0)
    800048ba:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800048bc:	02f05563          	blez	a5,800048e6 <initlog+0x74>
    800048c0:	05c50713          	addi	a4,a0,92
    800048c4:	0023e697          	auipc	a3,0x23e
    800048c8:	fc468693          	addi	a3,a3,-60 # 80242888 <log+0x30>
    800048cc:	37fd                	addiw	a5,a5,-1
    800048ce:	1782                	slli	a5,a5,0x20
    800048d0:	9381                	srli	a5,a5,0x20
    800048d2:	078a                	slli	a5,a5,0x2
    800048d4:	06050613          	addi	a2,a0,96
    800048d8:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    800048da:	4310                	lw	a2,0(a4)
    800048dc:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    800048de:	0711                	addi	a4,a4,4
    800048e0:	0691                	addi	a3,a3,4
    800048e2:	fef71ce3          	bne	a4,a5,800048da <initlog+0x68>
  brelse(buf);
    800048e6:	fffff097          	auipc	ra,0xfffff
    800048ea:	f84080e7          	jalr	-124(ra) # 8000386a <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800048ee:	4505                	li	a0,1
    800048f0:	00000097          	auipc	ra,0x0
    800048f4:	ebe080e7          	jalr	-322(ra) # 800047ae <install_trans>
  log.lh.n = 0;
    800048f8:	0023e797          	auipc	a5,0x23e
    800048fc:	f807a623          	sw	zero,-116(a5) # 80242884 <log+0x2c>
  write_head(); // clear the log
    80004900:	00000097          	auipc	ra,0x0
    80004904:	e34080e7          	jalr	-460(ra) # 80004734 <write_head>
}
    80004908:	70a2                	ld	ra,40(sp)
    8000490a:	7402                	ld	s0,32(sp)
    8000490c:	64e2                	ld	s1,24(sp)
    8000490e:	6942                	ld	s2,16(sp)
    80004910:	69a2                	ld	s3,8(sp)
    80004912:	6145                	addi	sp,sp,48
    80004914:	8082                	ret

0000000080004916 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004916:	1101                	addi	sp,sp,-32
    80004918:	ec06                	sd	ra,24(sp)
    8000491a:	e822                	sd	s0,16(sp)
    8000491c:	e426                	sd	s1,8(sp)
    8000491e:	e04a                	sd	s2,0(sp)
    80004920:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004922:	0023e517          	auipc	a0,0x23e
    80004926:	f3650513          	addi	a0,a0,-202 # 80242858 <log>
    8000492a:	ffffc097          	auipc	ra,0xffffc
    8000492e:	47e080e7          	jalr	1150(ra) # 80000da8 <acquire>
  while(1){
    if(log.committing){
    80004932:	0023e497          	auipc	s1,0x23e
    80004936:	f2648493          	addi	s1,s1,-218 # 80242858 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000493a:	4979                	li	s2,30
    8000493c:	a039                	j	8000494a <begin_op+0x34>
      sleep(&log, &log.lock);
    8000493e:	85a6                	mv	a1,s1
    80004940:	8526                	mv	a0,s1
    80004942:	ffffe097          	auipc	ra,0xffffe
    80004946:	ae6080e7          	jalr	-1306(ra) # 80002428 <sleep>
    if(log.committing){
    8000494a:	50dc                	lw	a5,36(s1)
    8000494c:	fbed                	bnez	a5,8000493e <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000494e:	509c                	lw	a5,32(s1)
    80004950:	0017871b          	addiw	a4,a5,1
    80004954:	0007069b          	sext.w	a3,a4
    80004958:	0027179b          	slliw	a5,a4,0x2
    8000495c:	9fb9                	addw	a5,a5,a4
    8000495e:	0017979b          	slliw	a5,a5,0x1
    80004962:	54d8                	lw	a4,44(s1)
    80004964:	9fb9                	addw	a5,a5,a4
    80004966:	00f95963          	bge	s2,a5,80004978 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000496a:	85a6                	mv	a1,s1
    8000496c:	8526                	mv	a0,s1
    8000496e:	ffffe097          	auipc	ra,0xffffe
    80004972:	aba080e7          	jalr	-1350(ra) # 80002428 <sleep>
    80004976:	bfd1                	j	8000494a <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004978:	0023e517          	auipc	a0,0x23e
    8000497c:	ee050513          	addi	a0,a0,-288 # 80242858 <log>
    80004980:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004982:	ffffc097          	auipc	ra,0xffffc
    80004986:	4da080e7          	jalr	1242(ra) # 80000e5c <release>
      break;
    }
  }
}
    8000498a:	60e2                	ld	ra,24(sp)
    8000498c:	6442                	ld	s0,16(sp)
    8000498e:	64a2                	ld	s1,8(sp)
    80004990:	6902                	ld	s2,0(sp)
    80004992:	6105                	addi	sp,sp,32
    80004994:	8082                	ret

0000000080004996 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004996:	7139                	addi	sp,sp,-64
    80004998:	fc06                	sd	ra,56(sp)
    8000499a:	f822                	sd	s0,48(sp)
    8000499c:	f426                	sd	s1,40(sp)
    8000499e:	f04a                	sd	s2,32(sp)
    800049a0:	ec4e                	sd	s3,24(sp)
    800049a2:	e852                	sd	s4,16(sp)
    800049a4:	e456                	sd	s5,8(sp)
    800049a6:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800049a8:	0023e497          	auipc	s1,0x23e
    800049ac:	eb048493          	addi	s1,s1,-336 # 80242858 <log>
    800049b0:	8526                	mv	a0,s1
    800049b2:	ffffc097          	auipc	ra,0xffffc
    800049b6:	3f6080e7          	jalr	1014(ra) # 80000da8 <acquire>
  log.outstanding -= 1;
    800049ba:	509c                	lw	a5,32(s1)
    800049bc:	37fd                	addiw	a5,a5,-1
    800049be:	0007891b          	sext.w	s2,a5
    800049c2:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800049c4:	50dc                	lw	a5,36(s1)
    800049c6:	efb9                	bnez	a5,80004a24 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    800049c8:	06091663          	bnez	s2,80004a34 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    800049cc:	0023e497          	auipc	s1,0x23e
    800049d0:	e8c48493          	addi	s1,s1,-372 # 80242858 <log>
    800049d4:	4785                	li	a5,1
    800049d6:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800049d8:	8526                	mv	a0,s1
    800049da:	ffffc097          	auipc	ra,0xffffc
    800049de:	482080e7          	jalr	1154(ra) # 80000e5c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800049e2:	54dc                	lw	a5,44(s1)
    800049e4:	06f04763          	bgtz	a5,80004a52 <end_op+0xbc>
    acquire(&log.lock);
    800049e8:	0023e497          	auipc	s1,0x23e
    800049ec:	e7048493          	addi	s1,s1,-400 # 80242858 <log>
    800049f0:	8526                	mv	a0,s1
    800049f2:	ffffc097          	auipc	ra,0xffffc
    800049f6:	3b6080e7          	jalr	950(ra) # 80000da8 <acquire>
    log.committing = 0;
    800049fa:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800049fe:	8526                	mv	a0,s1
    80004a00:	ffffe097          	auipc	ra,0xffffe
    80004a04:	d26080e7          	jalr	-730(ra) # 80002726 <wakeup>
    release(&log.lock);
    80004a08:	8526                	mv	a0,s1
    80004a0a:	ffffc097          	auipc	ra,0xffffc
    80004a0e:	452080e7          	jalr	1106(ra) # 80000e5c <release>
}
    80004a12:	70e2                	ld	ra,56(sp)
    80004a14:	7442                	ld	s0,48(sp)
    80004a16:	74a2                	ld	s1,40(sp)
    80004a18:	7902                	ld	s2,32(sp)
    80004a1a:	69e2                	ld	s3,24(sp)
    80004a1c:	6a42                	ld	s4,16(sp)
    80004a1e:	6aa2                	ld	s5,8(sp)
    80004a20:	6121                	addi	sp,sp,64
    80004a22:	8082                	ret
    panic("log.committing");
    80004a24:	00004517          	auipc	a0,0x4
    80004a28:	d8c50513          	addi	a0,a0,-628 # 800087b0 <syscalls+0x208>
    80004a2c:	ffffc097          	auipc	ra,0xffffc
    80004a30:	b18080e7          	jalr	-1256(ra) # 80000544 <panic>
    wakeup(&log);
    80004a34:	0023e497          	auipc	s1,0x23e
    80004a38:	e2448493          	addi	s1,s1,-476 # 80242858 <log>
    80004a3c:	8526                	mv	a0,s1
    80004a3e:	ffffe097          	auipc	ra,0xffffe
    80004a42:	ce8080e7          	jalr	-792(ra) # 80002726 <wakeup>
  release(&log.lock);
    80004a46:	8526                	mv	a0,s1
    80004a48:	ffffc097          	auipc	ra,0xffffc
    80004a4c:	414080e7          	jalr	1044(ra) # 80000e5c <release>
  if(do_commit){
    80004a50:	b7c9                	j	80004a12 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004a52:	0023ea97          	auipc	s5,0x23e
    80004a56:	e36a8a93          	addi	s5,s5,-458 # 80242888 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004a5a:	0023ea17          	auipc	s4,0x23e
    80004a5e:	dfea0a13          	addi	s4,s4,-514 # 80242858 <log>
    80004a62:	018a2583          	lw	a1,24(s4)
    80004a66:	012585bb          	addw	a1,a1,s2
    80004a6a:	2585                	addiw	a1,a1,1
    80004a6c:	028a2503          	lw	a0,40(s4)
    80004a70:	fffff097          	auipc	ra,0xfffff
    80004a74:	cca080e7          	jalr	-822(ra) # 8000373a <bread>
    80004a78:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004a7a:	000aa583          	lw	a1,0(s5)
    80004a7e:	028a2503          	lw	a0,40(s4)
    80004a82:	fffff097          	auipc	ra,0xfffff
    80004a86:	cb8080e7          	jalr	-840(ra) # 8000373a <bread>
    80004a8a:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004a8c:	40000613          	li	a2,1024
    80004a90:	05850593          	addi	a1,a0,88
    80004a94:	05848513          	addi	a0,s1,88
    80004a98:	ffffc097          	auipc	ra,0xffffc
    80004a9c:	46c080e7          	jalr	1132(ra) # 80000f04 <memmove>
    bwrite(to);  // write the log
    80004aa0:	8526                	mv	a0,s1
    80004aa2:	fffff097          	auipc	ra,0xfffff
    80004aa6:	d8a080e7          	jalr	-630(ra) # 8000382c <bwrite>
    brelse(from);
    80004aaa:	854e                	mv	a0,s3
    80004aac:	fffff097          	auipc	ra,0xfffff
    80004ab0:	dbe080e7          	jalr	-578(ra) # 8000386a <brelse>
    brelse(to);
    80004ab4:	8526                	mv	a0,s1
    80004ab6:	fffff097          	auipc	ra,0xfffff
    80004aba:	db4080e7          	jalr	-588(ra) # 8000386a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004abe:	2905                	addiw	s2,s2,1
    80004ac0:	0a91                	addi	s5,s5,4
    80004ac2:	02ca2783          	lw	a5,44(s4)
    80004ac6:	f8f94ee3          	blt	s2,a5,80004a62 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004aca:	00000097          	auipc	ra,0x0
    80004ace:	c6a080e7          	jalr	-918(ra) # 80004734 <write_head>
    install_trans(0); // Now install writes to home locations
    80004ad2:	4501                	li	a0,0
    80004ad4:	00000097          	auipc	ra,0x0
    80004ad8:	cda080e7          	jalr	-806(ra) # 800047ae <install_trans>
    log.lh.n = 0;
    80004adc:	0023e797          	auipc	a5,0x23e
    80004ae0:	da07a423          	sw	zero,-600(a5) # 80242884 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004ae4:	00000097          	auipc	ra,0x0
    80004ae8:	c50080e7          	jalr	-944(ra) # 80004734 <write_head>
    80004aec:	bdf5                	j	800049e8 <end_op+0x52>

0000000080004aee <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004aee:	1101                	addi	sp,sp,-32
    80004af0:	ec06                	sd	ra,24(sp)
    80004af2:	e822                	sd	s0,16(sp)
    80004af4:	e426                	sd	s1,8(sp)
    80004af6:	e04a                	sd	s2,0(sp)
    80004af8:	1000                	addi	s0,sp,32
    80004afa:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004afc:	0023e917          	auipc	s2,0x23e
    80004b00:	d5c90913          	addi	s2,s2,-676 # 80242858 <log>
    80004b04:	854a                	mv	a0,s2
    80004b06:	ffffc097          	auipc	ra,0xffffc
    80004b0a:	2a2080e7          	jalr	674(ra) # 80000da8 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004b0e:	02c92603          	lw	a2,44(s2)
    80004b12:	47f5                	li	a5,29
    80004b14:	06c7c563          	blt	a5,a2,80004b7e <log_write+0x90>
    80004b18:	0023e797          	auipc	a5,0x23e
    80004b1c:	d5c7a783          	lw	a5,-676(a5) # 80242874 <log+0x1c>
    80004b20:	37fd                	addiw	a5,a5,-1
    80004b22:	04f65e63          	bge	a2,a5,80004b7e <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004b26:	0023e797          	auipc	a5,0x23e
    80004b2a:	d527a783          	lw	a5,-686(a5) # 80242878 <log+0x20>
    80004b2e:	06f05063          	blez	a5,80004b8e <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004b32:	4781                	li	a5,0
    80004b34:	06c05563          	blez	a2,80004b9e <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004b38:	44cc                	lw	a1,12(s1)
    80004b3a:	0023e717          	auipc	a4,0x23e
    80004b3e:	d4e70713          	addi	a4,a4,-690 # 80242888 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004b42:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004b44:	4314                	lw	a3,0(a4)
    80004b46:	04b68c63          	beq	a3,a1,80004b9e <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004b4a:	2785                	addiw	a5,a5,1
    80004b4c:	0711                	addi	a4,a4,4
    80004b4e:	fef61be3          	bne	a2,a5,80004b44 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004b52:	0621                	addi	a2,a2,8
    80004b54:	060a                	slli	a2,a2,0x2
    80004b56:	0023e797          	auipc	a5,0x23e
    80004b5a:	d0278793          	addi	a5,a5,-766 # 80242858 <log>
    80004b5e:	963e                	add	a2,a2,a5
    80004b60:	44dc                	lw	a5,12(s1)
    80004b62:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004b64:	8526                	mv	a0,s1
    80004b66:	fffff097          	auipc	ra,0xfffff
    80004b6a:	da2080e7          	jalr	-606(ra) # 80003908 <bpin>
    log.lh.n++;
    80004b6e:	0023e717          	auipc	a4,0x23e
    80004b72:	cea70713          	addi	a4,a4,-790 # 80242858 <log>
    80004b76:	575c                	lw	a5,44(a4)
    80004b78:	2785                	addiw	a5,a5,1
    80004b7a:	d75c                	sw	a5,44(a4)
    80004b7c:	a835                	j	80004bb8 <log_write+0xca>
    panic("too big a transaction");
    80004b7e:	00004517          	auipc	a0,0x4
    80004b82:	c4250513          	addi	a0,a0,-958 # 800087c0 <syscalls+0x218>
    80004b86:	ffffc097          	auipc	ra,0xffffc
    80004b8a:	9be080e7          	jalr	-1602(ra) # 80000544 <panic>
    panic("log_write outside of trans");
    80004b8e:	00004517          	auipc	a0,0x4
    80004b92:	c4a50513          	addi	a0,a0,-950 # 800087d8 <syscalls+0x230>
    80004b96:	ffffc097          	auipc	ra,0xffffc
    80004b9a:	9ae080e7          	jalr	-1618(ra) # 80000544 <panic>
  log.lh.block[i] = b->blockno;
    80004b9e:	00878713          	addi	a4,a5,8
    80004ba2:	00271693          	slli	a3,a4,0x2
    80004ba6:	0023e717          	auipc	a4,0x23e
    80004baa:	cb270713          	addi	a4,a4,-846 # 80242858 <log>
    80004bae:	9736                	add	a4,a4,a3
    80004bb0:	44d4                	lw	a3,12(s1)
    80004bb2:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004bb4:	faf608e3          	beq	a2,a5,80004b64 <log_write+0x76>
  }
  release(&log.lock);
    80004bb8:	0023e517          	auipc	a0,0x23e
    80004bbc:	ca050513          	addi	a0,a0,-864 # 80242858 <log>
    80004bc0:	ffffc097          	auipc	ra,0xffffc
    80004bc4:	29c080e7          	jalr	668(ra) # 80000e5c <release>
}
    80004bc8:	60e2                	ld	ra,24(sp)
    80004bca:	6442                	ld	s0,16(sp)
    80004bcc:	64a2                	ld	s1,8(sp)
    80004bce:	6902                	ld	s2,0(sp)
    80004bd0:	6105                	addi	sp,sp,32
    80004bd2:	8082                	ret

0000000080004bd4 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004bd4:	1101                	addi	sp,sp,-32
    80004bd6:	ec06                	sd	ra,24(sp)
    80004bd8:	e822                	sd	s0,16(sp)
    80004bda:	e426                	sd	s1,8(sp)
    80004bdc:	e04a                	sd	s2,0(sp)
    80004bde:	1000                	addi	s0,sp,32
    80004be0:	84aa                	mv	s1,a0
    80004be2:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004be4:	00004597          	auipc	a1,0x4
    80004be8:	c1458593          	addi	a1,a1,-1004 # 800087f8 <syscalls+0x250>
    80004bec:	0521                	addi	a0,a0,8
    80004bee:	ffffc097          	auipc	ra,0xffffc
    80004bf2:	12a080e7          	jalr	298(ra) # 80000d18 <initlock>
  lk->name = name;
    80004bf6:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004bfa:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004bfe:	0204a423          	sw	zero,40(s1)
}
    80004c02:	60e2                	ld	ra,24(sp)
    80004c04:	6442                	ld	s0,16(sp)
    80004c06:	64a2                	ld	s1,8(sp)
    80004c08:	6902                	ld	s2,0(sp)
    80004c0a:	6105                	addi	sp,sp,32
    80004c0c:	8082                	ret

0000000080004c0e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004c0e:	1101                	addi	sp,sp,-32
    80004c10:	ec06                	sd	ra,24(sp)
    80004c12:	e822                	sd	s0,16(sp)
    80004c14:	e426                	sd	s1,8(sp)
    80004c16:	e04a                	sd	s2,0(sp)
    80004c18:	1000                	addi	s0,sp,32
    80004c1a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004c1c:	00850913          	addi	s2,a0,8
    80004c20:	854a                	mv	a0,s2
    80004c22:	ffffc097          	auipc	ra,0xffffc
    80004c26:	186080e7          	jalr	390(ra) # 80000da8 <acquire>
  while (lk->locked) {
    80004c2a:	409c                	lw	a5,0(s1)
    80004c2c:	cb89                	beqz	a5,80004c3e <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004c2e:	85ca                	mv	a1,s2
    80004c30:	8526                	mv	a0,s1
    80004c32:	ffffd097          	auipc	ra,0xffffd
    80004c36:	7f6080e7          	jalr	2038(ra) # 80002428 <sleep>
  while (lk->locked) {
    80004c3a:	409c                	lw	a5,0(s1)
    80004c3c:	fbed                	bnez	a5,80004c2e <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004c3e:	4785                	li	a5,1
    80004c40:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004c42:	ffffd097          	auipc	ra,0xffffd
    80004c46:	076080e7          	jalr	118(ra) # 80001cb8 <myproc>
    80004c4a:	5d1c                	lw	a5,56(a0)
    80004c4c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004c4e:	854a                	mv	a0,s2
    80004c50:	ffffc097          	auipc	ra,0xffffc
    80004c54:	20c080e7          	jalr	524(ra) # 80000e5c <release>
}
    80004c58:	60e2                	ld	ra,24(sp)
    80004c5a:	6442                	ld	s0,16(sp)
    80004c5c:	64a2                	ld	s1,8(sp)
    80004c5e:	6902                	ld	s2,0(sp)
    80004c60:	6105                	addi	sp,sp,32
    80004c62:	8082                	ret

0000000080004c64 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004c64:	1101                	addi	sp,sp,-32
    80004c66:	ec06                	sd	ra,24(sp)
    80004c68:	e822                	sd	s0,16(sp)
    80004c6a:	e426                	sd	s1,8(sp)
    80004c6c:	e04a                	sd	s2,0(sp)
    80004c6e:	1000                	addi	s0,sp,32
    80004c70:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004c72:	00850913          	addi	s2,a0,8
    80004c76:	854a                	mv	a0,s2
    80004c78:	ffffc097          	auipc	ra,0xffffc
    80004c7c:	130080e7          	jalr	304(ra) # 80000da8 <acquire>
  lk->locked = 0;
    80004c80:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004c84:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004c88:	8526                	mv	a0,s1
    80004c8a:	ffffe097          	auipc	ra,0xffffe
    80004c8e:	a9c080e7          	jalr	-1380(ra) # 80002726 <wakeup>
  release(&lk->lk);
    80004c92:	854a                	mv	a0,s2
    80004c94:	ffffc097          	auipc	ra,0xffffc
    80004c98:	1c8080e7          	jalr	456(ra) # 80000e5c <release>
}
    80004c9c:	60e2                	ld	ra,24(sp)
    80004c9e:	6442                	ld	s0,16(sp)
    80004ca0:	64a2                	ld	s1,8(sp)
    80004ca2:	6902                	ld	s2,0(sp)
    80004ca4:	6105                	addi	sp,sp,32
    80004ca6:	8082                	ret

0000000080004ca8 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004ca8:	7179                	addi	sp,sp,-48
    80004caa:	f406                	sd	ra,40(sp)
    80004cac:	f022                	sd	s0,32(sp)
    80004cae:	ec26                	sd	s1,24(sp)
    80004cb0:	e84a                	sd	s2,16(sp)
    80004cb2:	e44e                	sd	s3,8(sp)
    80004cb4:	1800                	addi	s0,sp,48
    80004cb6:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004cb8:	00850913          	addi	s2,a0,8
    80004cbc:	854a                	mv	a0,s2
    80004cbe:	ffffc097          	auipc	ra,0xffffc
    80004cc2:	0ea080e7          	jalr	234(ra) # 80000da8 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004cc6:	409c                	lw	a5,0(s1)
    80004cc8:	ef99                	bnez	a5,80004ce6 <holdingsleep+0x3e>
    80004cca:	4481                	li	s1,0
  release(&lk->lk);
    80004ccc:	854a                	mv	a0,s2
    80004cce:	ffffc097          	auipc	ra,0xffffc
    80004cd2:	18e080e7          	jalr	398(ra) # 80000e5c <release>
  return r;
}
    80004cd6:	8526                	mv	a0,s1
    80004cd8:	70a2                	ld	ra,40(sp)
    80004cda:	7402                	ld	s0,32(sp)
    80004cdc:	64e2                	ld	s1,24(sp)
    80004cde:	6942                	ld	s2,16(sp)
    80004ce0:	69a2                	ld	s3,8(sp)
    80004ce2:	6145                	addi	sp,sp,48
    80004ce4:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004ce6:	0284a983          	lw	s3,40(s1)
    80004cea:	ffffd097          	auipc	ra,0xffffd
    80004cee:	fce080e7          	jalr	-50(ra) # 80001cb8 <myproc>
    80004cf2:	5d04                	lw	s1,56(a0)
    80004cf4:	413484b3          	sub	s1,s1,s3
    80004cf8:	0014b493          	seqz	s1,s1
    80004cfc:	bfc1                	j	80004ccc <holdingsleep+0x24>

0000000080004cfe <fileinit>:
	struct spinlock lock;
	struct file file[NFILE];
} ftable;

void fileinit(void)
{
    80004cfe:	1141                	addi	sp,sp,-16
    80004d00:	e406                	sd	ra,8(sp)
    80004d02:	e022                	sd	s0,0(sp)
    80004d04:	0800                	addi	s0,sp,16
	initlock(&ftable.lock, "ftable");
    80004d06:	00004597          	auipc	a1,0x4
    80004d0a:	b0258593          	addi	a1,a1,-1278 # 80008808 <syscalls+0x260>
    80004d0e:	0023e517          	auipc	a0,0x23e
    80004d12:	c9250513          	addi	a0,a0,-878 # 802429a0 <ftable>
    80004d16:	ffffc097          	auipc	ra,0xffffc
    80004d1a:	002080e7          	jalr	2(ra) # 80000d18 <initlock>
}
    80004d1e:	60a2                	ld	ra,8(sp)
    80004d20:	6402                	ld	s0,0(sp)
    80004d22:	0141                	addi	sp,sp,16
    80004d24:	8082                	ret

0000000080004d26 <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    80004d26:	1101                	addi	sp,sp,-32
    80004d28:	ec06                	sd	ra,24(sp)
    80004d2a:	e822                	sd	s0,16(sp)
    80004d2c:	e426                	sd	s1,8(sp)
    80004d2e:	1000                	addi	s0,sp,32
	struct file *f;

	acquire(&ftable.lock);
    80004d30:	0023e517          	auipc	a0,0x23e
    80004d34:	c7050513          	addi	a0,a0,-912 # 802429a0 <ftable>
    80004d38:	ffffc097          	auipc	ra,0xffffc
    80004d3c:	070080e7          	jalr	112(ra) # 80000da8 <acquire>
	for (f = ftable.file; f < ftable.file + NFILE; f++)
    80004d40:	0023e497          	auipc	s1,0x23e
    80004d44:	c7848493          	addi	s1,s1,-904 # 802429b8 <ftable+0x18>
    80004d48:	0023f717          	auipc	a4,0x23f
    80004d4c:	c1070713          	addi	a4,a4,-1008 # 80243958 <disk>
	{
		if (f->ref == 0)
    80004d50:	40dc                	lw	a5,4(s1)
    80004d52:	cf99                	beqz	a5,80004d70 <filealloc+0x4a>
	for (f = ftable.file; f < ftable.file + NFILE; f++)
    80004d54:	02848493          	addi	s1,s1,40
    80004d58:	fee49ce3          	bne	s1,a4,80004d50 <filealloc+0x2a>
			f->ref = 1;
			release(&ftable.lock);
			return f;
		}
	}
	release(&ftable.lock);
    80004d5c:	0023e517          	auipc	a0,0x23e
    80004d60:	c4450513          	addi	a0,a0,-956 # 802429a0 <ftable>
    80004d64:	ffffc097          	auipc	ra,0xffffc
    80004d68:	0f8080e7          	jalr	248(ra) # 80000e5c <release>
	return 0;
    80004d6c:	4481                	li	s1,0
    80004d6e:	a819                	j	80004d84 <filealloc+0x5e>
			f->ref = 1;
    80004d70:	4785                	li	a5,1
    80004d72:	c0dc                	sw	a5,4(s1)
			release(&ftable.lock);
    80004d74:	0023e517          	auipc	a0,0x23e
    80004d78:	c2c50513          	addi	a0,a0,-980 # 802429a0 <ftable>
    80004d7c:	ffffc097          	auipc	ra,0xffffc
    80004d80:	0e0080e7          	jalr	224(ra) # 80000e5c <release>
}
    80004d84:	8526                	mv	a0,s1
    80004d86:	60e2                	ld	ra,24(sp)
    80004d88:	6442                	ld	s0,16(sp)
    80004d8a:	64a2                	ld	s1,8(sp)
    80004d8c:	6105                	addi	sp,sp,32
    80004d8e:	8082                	ret

0000000080004d90 <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    80004d90:	1101                	addi	sp,sp,-32
    80004d92:	ec06                	sd	ra,24(sp)
    80004d94:	e822                	sd	s0,16(sp)
    80004d96:	e426                	sd	s1,8(sp)
    80004d98:	1000                	addi	s0,sp,32
    80004d9a:	84aa                	mv	s1,a0
	acquire(&ftable.lock);
    80004d9c:	0023e517          	auipc	a0,0x23e
    80004da0:	c0450513          	addi	a0,a0,-1020 # 802429a0 <ftable>
    80004da4:	ffffc097          	auipc	ra,0xffffc
    80004da8:	004080e7          	jalr	4(ra) # 80000da8 <acquire>
	if (f->ref < 1)
    80004dac:	40dc                	lw	a5,4(s1)
    80004dae:	02f05263          	blez	a5,80004dd2 <filedup+0x42>
		panic("filedup");
	f->ref++;
    80004db2:	2785                	addiw	a5,a5,1
    80004db4:	c0dc                	sw	a5,4(s1)
	release(&ftable.lock);
    80004db6:	0023e517          	auipc	a0,0x23e
    80004dba:	bea50513          	addi	a0,a0,-1046 # 802429a0 <ftable>
    80004dbe:	ffffc097          	auipc	ra,0xffffc
    80004dc2:	09e080e7          	jalr	158(ra) # 80000e5c <release>
	return f;
}
    80004dc6:	8526                	mv	a0,s1
    80004dc8:	60e2                	ld	ra,24(sp)
    80004dca:	6442                	ld	s0,16(sp)
    80004dcc:	64a2                	ld	s1,8(sp)
    80004dce:	6105                	addi	sp,sp,32
    80004dd0:	8082                	ret
		panic("filedup");
    80004dd2:	00004517          	auipc	a0,0x4
    80004dd6:	a3e50513          	addi	a0,a0,-1474 # 80008810 <syscalls+0x268>
    80004dda:	ffffb097          	auipc	ra,0xffffb
    80004dde:	76a080e7          	jalr	1898(ra) # 80000544 <panic>

0000000080004de2 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void fileclose(struct file *f)
{
    80004de2:	7139                	addi	sp,sp,-64
    80004de4:	fc06                	sd	ra,56(sp)
    80004de6:	f822                	sd	s0,48(sp)
    80004de8:	f426                	sd	s1,40(sp)
    80004dea:	f04a                	sd	s2,32(sp)
    80004dec:	ec4e                	sd	s3,24(sp)
    80004dee:	e852                	sd	s4,16(sp)
    80004df0:	e456                	sd	s5,8(sp)
    80004df2:	0080                	addi	s0,sp,64
    80004df4:	84aa                	mv	s1,a0
	struct file ff;

	acquire(&ftable.lock);
    80004df6:	0023e517          	auipc	a0,0x23e
    80004dfa:	baa50513          	addi	a0,a0,-1110 # 802429a0 <ftable>
    80004dfe:	ffffc097          	auipc	ra,0xffffc
    80004e02:	faa080e7          	jalr	-86(ra) # 80000da8 <acquire>
	if (f->ref < 1)
    80004e06:	40dc                	lw	a5,4(s1)
    80004e08:	06f05163          	blez	a5,80004e6a <fileclose+0x88>
		panic("fileclose");
	if (--f->ref > 0)
    80004e0c:	37fd                	addiw	a5,a5,-1
    80004e0e:	0007871b          	sext.w	a4,a5
    80004e12:	c0dc                	sw	a5,4(s1)
    80004e14:	06e04363          	bgtz	a4,80004e7a <fileclose+0x98>
	{
		release(&ftable.lock);
		return;
	}
	ff = *f;
    80004e18:	0004a903          	lw	s2,0(s1)
    80004e1c:	0094ca83          	lbu	s5,9(s1)
    80004e20:	0104ba03          	ld	s4,16(s1)
    80004e24:	0184b983          	ld	s3,24(s1)
	f->ref = 0;
    80004e28:	0004a223          	sw	zero,4(s1)
	f->type = FD_NONE;
    80004e2c:	0004a023          	sw	zero,0(s1)
	release(&ftable.lock);
    80004e30:	0023e517          	auipc	a0,0x23e
    80004e34:	b7050513          	addi	a0,a0,-1168 # 802429a0 <ftable>
    80004e38:	ffffc097          	auipc	ra,0xffffc
    80004e3c:	024080e7          	jalr	36(ra) # 80000e5c <release>

	if (ff.type == FD_PIPE)
    80004e40:	4785                	li	a5,1
    80004e42:	04f90d63          	beq	s2,a5,80004e9c <fileclose+0xba>
	{
		pipeclose(ff.pipe, ff.writable);
	}
	else if (ff.type == FD_INODE || ff.type == FD_DEVICE)
    80004e46:	3979                	addiw	s2,s2,-2
    80004e48:	4785                	li	a5,1
    80004e4a:	0527e063          	bltu	a5,s2,80004e8a <fileclose+0xa8>
	{
		begin_op();
    80004e4e:	00000097          	auipc	ra,0x0
    80004e52:	ac8080e7          	jalr	-1336(ra) # 80004916 <begin_op>
		iput(ff.ip);
    80004e56:	854e                	mv	a0,s3
    80004e58:	fffff097          	auipc	ra,0xfffff
    80004e5c:	2b6080e7          	jalr	694(ra) # 8000410e <iput>
		end_op();
    80004e60:	00000097          	auipc	ra,0x0
    80004e64:	b36080e7          	jalr	-1226(ra) # 80004996 <end_op>
    80004e68:	a00d                	j	80004e8a <fileclose+0xa8>
		panic("fileclose");
    80004e6a:	00004517          	auipc	a0,0x4
    80004e6e:	9ae50513          	addi	a0,a0,-1618 # 80008818 <syscalls+0x270>
    80004e72:	ffffb097          	auipc	ra,0xffffb
    80004e76:	6d2080e7          	jalr	1746(ra) # 80000544 <panic>
		release(&ftable.lock);
    80004e7a:	0023e517          	auipc	a0,0x23e
    80004e7e:	b2650513          	addi	a0,a0,-1242 # 802429a0 <ftable>
    80004e82:	ffffc097          	auipc	ra,0xffffc
    80004e86:	fda080e7          	jalr	-38(ra) # 80000e5c <release>
	}
}
    80004e8a:	70e2                	ld	ra,56(sp)
    80004e8c:	7442                	ld	s0,48(sp)
    80004e8e:	74a2                	ld	s1,40(sp)
    80004e90:	7902                	ld	s2,32(sp)
    80004e92:	69e2                	ld	s3,24(sp)
    80004e94:	6a42                	ld	s4,16(sp)
    80004e96:	6aa2                	ld	s5,8(sp)
    80004e98:	6121                	addi	sp,sp,64
    80004e9a:	8082                	ret
		pipeclose(ff.pipe, ff.writable);
    80004e9c:	85d6                	mv	a1,s5
    80004e9e:	8552                	mv	a0,s4
    80004ea0:	00000097          	auipc	ra,0x0
    80004ea4:	34c080e7          	jalr	844(ra) # 800051ec <pipeclose>
    80004ea8:	b7cd                	j	80004e8a <fileclose+0xa8>

0000000080004eaa <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int filestat(struct file *f, uint64 addr)
{
    80004eaa:	715d                	addi	sp,sp,-80
    80004eac:	e486                	sd	ra,72(sp)
    80004eae:	e0a2                	sd	s0,64(sp)
    80004eb0:	fc26                	sd	s1,56(sp)
    80004eb2:	f84a                	sd	s2,48(sp)
    80004eb4:	f44e                	sd	s3,40(sp)
    80004eb6:	0880                	addi	s0,sp,80
    80004eb8:	84aa                	mv	s1,a0
    80004eba:	89ae                	mv	s3,a1
	struct proc *p = myproc();
    80004ebc:	ffffd097          	auipc	ra,0xffffd
    80004ec0:	dfc080e7          	jalr	-516(ra) # 80001cb8 <myproc>
	struct stat st;

	if (f->type == FD_INODE || f->type == FD_DEVICE)
    80004ec4:	409c                	lw	a5,0(s1)
    80004ec6:	37f9                	addiw	a5,a5,-2
    80004ec8:	4705                	li	a4,1
    80004eca:	04f76763          	bltu	a4,a5,80004f18 <filestat+0x6e>
    80004ece:	892a                	mv	s2,a0
	{
		ilock(f->ip);
    80004ed0:	6c88                	ld	a0,24(s1)
    80004ed2:	fffff097          	auipc	ra,0xfffff
    80004ed6:	082080e7          	jalr	130(ra) # 80003f54 <ilock>
		stati(f->ip, &st);
    80004eda:	fb840593          	addi	a1,s0,-72
    80004ede:	6c88                	ld	a0,24(s1)
    80004ee0:	fffff097          	auipc	ra,0xfffff
    80004ee4:	2fe080e7          	jalr	766(ra) # 800041de <stati>
		iunlock(f->ip);
    80004ee8:	6c88                	ld	a0,24(s1)
    80004eea:	fffff097          	auipc	ra,0xfffff
    80004eee:	12c080e7          	jalr	300(ra) # 80004016 <iunlock>
		if (copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004ef2:	46e1                	li	a3,24
    80004ef4:	fb840613          	addi	a2,s0,-72
    80004ef8:	85ce                	mv	a1,s3
    80004efa:	05893503          	ld	a0,88(s2)
    80004efe:	ffffd097          	auipc	ra,0xffffd
    80004f02:	93a080e7          	jalr	-1734(ra) # 80001838 <copyout>
    80004f06:	41f5551b          	sraiw	a0,a0,0x1f
			return -1;
		return 0;
	}
	return -1;
}
    80004f0a:	60a6                	ld	ra,72(sp)
    80004f0c:	6406                	ld	s0,64(sp)
    80004f0e:	74e2                	ld	s1,56(sp)
    80004f10:	7942                	ld	s2,48(sp)
    80004f12:	79a2                	ld	s3,40(sp)
    80004f14:	6161                	addi	sp,sp,80
    80004f16:	8082                	ret
	return -1;
    80004f18:	557d                	li	a0,-1
    80004f1a:	bfc5                	j	80004f0a <filestat+0x60>

0000000080004f1c <fileread>:

// Read from file f.
// addr is a user virtual address.
int fileread(struct file *f, uint64 addr, int n)
{
    80004f1c:	7179                	addi	sp,sp,-48
    80004f1e:	f406                	sd	ra,40(sp)
    80004f20:	f022                	sd	s0,32(sp)
    80004f22:	ec26                	sd	s1,24(sp)
    80004f24:	e84a                	sd	s2,16(sp)
    80004f26:	e44e                	sd	s3,8(sp)
    80004f28:	1800                	addi	s0,sp,48
	int r = 0;

	if (f->readable == 0)
    80004f2a:	00854783          	lbu	a5,8(a0)
    80004f2e:	c3d5                	beqz	a5,80004fd2 <fileread+0xb6>
    80004f30:	84aa                	mv	s1,a0
    80004f32:	89ae                	mv	s3,a1
    80004f34:	8932                	mv	s2,a2
		return -1;

	if (f->type == FD_PIPE)
    80004f36:	411c                	lw	a5,0(a0)
    80004f38:	4705                	li	a4,1
    80004f3a:	04e78963          	beq	a5,a4,80004f8c <fileread+0x70>
	{
		r = piperead(f->pipe, addr, n);
		// printf("here\n");
	}
	else if (f->type == FD_DEVICE)
    80004f3e:	470d                	li	a4,3
    80004f40:	04e78d63          	beq	a5,a4,80004f9a <fileread+0x7e>
	{
		if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
			return -1;
		r = devsw[f->major].read(1, addr, n);
	}
	else if (f->type == FD_INODE)
    80004f44:	4709                	li	a4,2
    80004f46:	06e79e63          	bne	a5,a4,80004fc2 <fileread+0xa6>
	{
		ilock(f->ip);
    80004f4a:	6d08                	ld	a0,24(a0)
    80004f4c:	fffff097          	auipc	ra,0xfffff
    80004f50:	008080e7          	jalr	8(ra) # 80003f54 <ilock>
		if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004f54:	874a                	mv	a4,s2
    80004f56:	5094                	lw	a3,32(s1)
    80004f58:	864e                	mv	a2,s3
    80004f5a:	4585                	li	a1,1
    80004f5c:	6c88                	ld	a0,24(s1)
    80004f5e:	fffff097          	auipc	ra,0xfffff
    80004f62:	2aa080e7          	jalr	682(ra) # 80004208 <readi>
    80004f66:	892a                	mv	s2,a0
    80004f68:	00a05563          	blez	a0,80004f72 <fileread+0x56>
			f->off += r;
    80004f6c:	509c                	lw	a5,32(s1)
    80004f6e:	9fa9                	addw	a5,a5,a0
    80004f70:	d09c                	sw	a5,32(s1)
		iunlock(f->ip);
    80004f72:	6c88                	ld	a0,24(s1)
    80004f74:	fffff097          	auipc	ra,0xfffff
    80004f78:	0a2080e7          	jalr	162(ra) # 80004016 <iunlock>
	{
		panic("fileread");
	}

	return r;
}
    80004f7c:	854a                	mv	a0,s2
    80004f7e:	70a2                	ld	ra,40(sp)
    80004f80:	7402                	ld	s0,32(sp)
    80004f82:	64e2                	ld	s1,24(sp)
    80004f84:	6942                	ld	s2,16(sp)
    80004f86:	69a2                	ld	s3,8(sp)
    80004f88:	6145                	addi	sp,sp,48
    80004f8a:	8082                	ret
		r = piperead(f->pipe, addr, n);
    80004f8c:	6908                	ld	a0,16(a0)
    80004f8e:	00000097          	auipc	ra,0x0
    80004f92:	3ce080e7          	jalr	974(ra) # 8000535c <piperead>
    80004f96:	892a                	mv	s2,a0
    80004f98:	b7d5                	j	80004f7c <fileread+0x60>
		if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004f9a:	02451783          	lh	a5,36(a0)
    80004f9e:	03079693          	slli	a3,a5,0x30
    80004fa2:	92c1                	srli	a3,a3,0x30
    80004fa4:	4725                	li	a4,9
    80004fa6:	02d76863          	bltu	a4,a3,80004fd6 <fileread+0xba>
    80004faa:	0792                	slli	a5,a5,0x4
    80004fac:	0023e717          	auipc	a4,0x23e
    80004fb0:	95470713          	addi	a4,a4,-1708 # 80242900 <devsw>
    80004fb4:	97ba                	add	a5,a5,a4
    80004fb6:	639c                	ld	a5,0(a5)
    80004fb8:	c38d                	beqz	a5,80004fda <fileread+0xbe>
		r = devsw[f->major].read(1, addr, n);
    80004fba:	4505                	li	a0,1
    80004fbc:	9782                	jalr	a5
    80004fbe:	892a                	mv	s2,a0
    80004fc0:	bf75                	j	80004f7c <fileread+0x60>
		panic("fileread");
    80004fc2:	00004517          	auipc	a0,0x4
    80004fc6:	86650513          	addi	a0,a0,-1946 # 80008828 <syscalls+0x280>
    80004fca:	ffffb097          	auipc	ra,0xffffb
    80004fce:	57a080e7          	jalr	1402(ra) # 80000544 <panic>
		return -1;
    80004fd2:	597d                	li	s2,-1
    80004fd4:	b765                	j	80004f7c <fileread+0x60>
			return -1;
    80004fd6:	597d                	li	s2,-1
    80004fd8:	b755                	j	80004f7c <fileread+0x60>
    80004fda:	597d                	li	s2,-1
    80004fdc:	b745                	j	80004f7c <fileread+0x60>

0000000080004fde <filewrite>:

// Write to file f.
// addr is a user virtual address.
int filewrite(struct file *f, uint64 addr, int n)
{
    80004fde:	715d                	addi	sp,sp,-80
    80004fe0:	e486                	sd	ra,72(sp)
    80004fe2:	e0a2                	sd	s0,64(sp)
    80004fe4:	fc26                	sd	s1,56(sp)
    80004fe6:	f84a                	sd	s2,48(sp)
    80004fe8:	f44e                	sd	s3,40(sp)
    80004fea:	f052                	sd	s4,32(sp)
    80004fec:	ec56                	sd	s5,24(sp)
    80004fee:	e85a                	sd	s6,16(sp)
    80004ff0:	e45e                	sd	s7,8(sp)
    80004ff2:	e062                	sd	s8,0(sp)
    80004ff4:	0880                	addi	s0,sp,80
	int r, ret = 0;

	if (f->writable == 0)
    80004ff6:	00954783          	lbu	a5,9(a0)
    80004ffa:	10078663          	beqz	a5,80005106 <filewrite+0x128>
    80004ffe:	892a                	mv	s2,a0
    80005000:	8aae                	mv	s5,a1
    80005002:	8a32                	mv	s4,a2
		return -1;

	if (f->type == FD_PIPE)
    80005004:	411c                	lw	a5,0(a0)
    80005006:	4705                	li	a4,1
    80005008:	02e78263          	beq	a5,a4,8000502c <filewrite+0x4e>
	{
		ret = pipewrite(f->pipe, addr, n);
	}
	else if (f->type == FD_DEVICE)
    8000500c:	470d                	li	a4,3
    8000500e:	02e78663          	beq	a5,a4,8000503a <filewrite+0x5c>
	{
		if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
			return -1;
		ret = devsw[f->major].write(1, addr, n);
	}
	else if (f->type == FD_INODE)
    80005012:	4709                	li	a4,2
    80005014:	0ee79163          	bne	a5,a4,800050f6 <filewrite+0x118>
		// and 2 blocks of slop for non-aligned writes.
		// this really belongs lower down, since writei()
		// might be writing a device like the console.
		int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
		int i = 0;
		while (i < n)
    80005018:	0ac05d63          	blez	a2,800050d2 <filewrite+0xf4>
		int i = 0;
    8000501c:	4981                	li	s3,0
    8000501e:	6b05                	lui	s6,0x1
    80005020:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80005024:	6b85                	lui	s7,0x1
    80005026:	c00b8b9b          	addiw	s7,s7,-1024
    8000502a:	a861                	j	800050c2 <filewrite+0xe4>
		ret = pipewrite(f->pipe, addr, n);
    8000502c:	6908                	ld	a0,16(a0)
    8000502e:	00000097          	auipc	ra,0x0
    80005032:	22e080e7          	jalr	558(ra) # 8000525c <pipewrite>
    80005036:	8a2a                	mv	s4,a0
    80005038:	a045                	j	800050d8 <filewrite+0xfa>
		if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000503a:	02451783          	lh	a5,36(a0)
    8000503e:	03079693          	slli	a3,a5,0x30
    80005042:	92c1                	srli	a3,a3,0x30
    80005044:	4725                	li	a4,9
    80005046:	0cd76263          	bltu	a4,a3,8000510a <filewrite+0x12c>
    8000504a:	0792                	slli	a5,a5,0x4
    8000504c:	0023e717          	auipc	a4,0x23e
    80005050:	8b470713          	addi	a4,a4,-1868 # 80242900 <devsw>
    80005054:	97ba                	add	a5,a5,a4
    80005056:	679c                	ld	a5,8(a5)
    80005058:	cbdd                	beqz	a5,8000510e <filewrite+0x130>
		ret = devsw[f->major].write(1, addr, n);
    8000505a:	4505                	li	a0,1
    8000505c:	9782                	jalr	a5
    8000505e:	8a2a                	mv	s4,a0
    80005060:	a8a5                	j	800050d8 <filewrite+0xfa>
    80005062:	00048c1b          	sext.w	s8,s1
		{
			int n1 = n - i;
			if (n1 > max)
				n1 = max;

			begin_op();
    80005066:	00000097          	auipc	ra,0x0
    8000506a:	8b0080e7          	jalr	-1872(ra) # 80004916 <begin_op>
			ilock(f->ip);
    8000506e:	01893503          	ld	a0,24(s2)
    80005072:	fffff097          	auipc	ra,0xfffff
    80005076:	ee2080e7          	jalr	-286(ra) # 80003f54 <ilock>
			if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000507a:	8762                	mv	a4,s8
    8000507c:	02092683          	lw	a3,32(s2)
    80005080:	01598633          	add	a2,s3,s5
    80005084:	4585                	li	a1,1
    80005086:	01893503          	ld	a0,24(s2)
    8000508a:	fffff097          	auipc	ra,0xfffff
    8000508e:	276080e7          	jalr	630(ra) # 80004300 <writei>
    80005092:	84aa                	mv	s1,a0
    80005094:	00a05763          	blez	a0,800050a2 <filewrite+0xc4>
				f->off += r;
    80005098:	02092783          	lw	a5,32(s2)
    8000509c:	9fa9                	addw	a5,a5,a0
    8000509e:	02f92023          	sw	a5,32(s2)
			iunlock(f->ip);
    800050a2:	01893503          	ld	a0,24(s2)
    800050a6:	fffff097          	auipc	ra,0xfffff
    800050aa:	f70080e7          	jalr	-144(ra) # 80004016 <iunlock>
			end_op();
    800050ae:	00000097          	auipc	ra,0x0
    800050b2:	8e8080e7          	jalr	-1816(ra) # 80004996 <end_op>

			if (r != n1)
    800050b6:	009c1f63          	bne	s8,s1,800050d4 <filewrite+0xf6>
			{
				// error from writei
				break;
			}
			i += r;
    800050ba:	013489bb          	addw	s3,s1,s3
		while (i < n)
    800050be:	0149db63          	bge	s3,s4,800050d4 <filewrite+0xf6>
			int n1 = n - i;
    800050c2:	413a07bb          	subw	a5,s4,s3
			if (n1 > max)
    800050c6:	84be                	mv	s1,a5
    800050c8:	2781                	sext.w	a5,a5
    800050ca:	f8fb5ce3          	bge	s6,a5,80005062 <filewrite+0x84>
    800050ce:	84de                	mv	s1,s7
    800050d0:	bf49                	j	80005062 <filewrite+0x84>
		int i = 0;
    800050d2:	4981                	li	s3,0
		}
		ret = (i == n ? n : -1);
    800050d4:	013a1f63          	bne	s4,s3,800050f2 <filewrite+0x114>
	{
		panic("filewrite");
	}

	return ret;
}
    800050d8:	8552                	mv	a0,s4
    800050da:	60a6                	ld	ra,72(sp)
    800050dc:	6406                	ld	s0,64(sp)
    800050de:	74e2                	ld	s1,56(sp)
    800050e0:	7942                	ld	s2,48(sp)
    800050e2:	79a2                	ld	s3,40(sp)
    800050e4:	7a02                	ld	s4,32(sp)
    800050e6:	6ae2                	ld	s5,24(sp)
    800050e8:	6b42                	ld	s6,16(sp)
    800050ea:	6ba2                	ld	s7,8(sp)
    800050ec:	6c02                	ld	s8,0(sp)
    800050ee:	6161                	addi	sp,sp,80
    800050f0:	8082                	ret
		ret = (i == n ? n : -1);
    800050f2:	5a7d                	li	s4,-1
    800050f4:	b7d5                	j	800050d8 <filewrite+0xfa>
		panic("filewrite");
    800050f6:	00003517          	auipc	a0,0x3
    800050fa:	74250513          	addi	a0,a0,1858 # 80008838 <syscalls+0x290>
    800050fe:	ffffb097          	auipc	ra,0xffffb
    80005102:	446080e7          	jalr	1094(ra) # 80000544 <panic>
		return -1;
    80005106:	5a7d                	li	s4,-1
    80005108:	bfc1                	j	800050d8 <filewrite+0xfa>
			return -1;
    8000510a:	5a7d                	li	s4,-1
    8000510c:	b7f1                	j	800050d8 <filewrite+0xfa>
    8000510e:	5a7d                	li	s4,-1
    80005110:	b7e1                	j	800050d8 <filewrite+0xfa>

0000000080005112 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80005112:	7179                	addi	sp,sp,-48
    80005114:	f406                	sd	ra,40(sp)
    80005116:	f022                	sd	s0,32(sp)
    80005118:	ec26                	sd	s1,24(sp)
    8000511a:	e84a                	sd	s2,16(sp)
    8000511c:	e44e                	sd	s3,8(sp)
    8000511e:	e052                	sd	s4,0(sp)
    80005120:	1800                	addi	s0,sp,48
    80005122:	84aa                	mv	s1,a0
    80005124:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005126:	0005b023          	sd	zero,0(a1)
    8000512a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000512e:	00000097          	auipc	ra,0x0
    80005132:	bf8080e7          	jalr	-1032(ra) # 80004d26 <filealloc>
    80005136:	e088                	sd	a0,0(s1)
    80005138:	c551                	beqz	a0,800051c4 <pipealloc+0xb2>
    8000513a:	00000097          	auipc	ra,0x0
    8000513e:	bec080e7          	jalr	-1044(ra) # 80004d26 <filealloc>
    80005142:	00aa3023          	sd	a0,0(s4)
    80005146:	c92d                	beqz	a0,800051b8 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80005148:	ffffc097          	auipc	ra,0xffffc
    8000514c:	b2c080e7          	jalr	-1236(ra) # 80000c74 <kalloc>
    80005150:	892a                	mv	s2,a0
    80005152:	c125                	beqz	a0,800051b2 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80005154:	4985                	li	s3,1
    80005156:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000515a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000515e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005162:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80005166:	00003597          	auipc	a1,0x3
    8000516a:	36258593          	addi	a1,a1,866 # 800084c8 <states.2502+0x1b8>
    8000516e:	ffffc097          	auipc	ra,0xffffc
    80005172:	baa080e7          	jalr	-1110(ra) # 80000d18 <initlock>
  (*f0)->type = FD_PIPE;
    80005176:	609c                	ld	a5,0(s1)
    80005178:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000517c:	609c                	ld	a5,0(s1)
    8000517e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005182:	609c                	ld	a5,0(s1)
    80005184:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80005188:	609c                	ld	a5,0(s1)
    8000518a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000518e:	000a3783          	ld	a5,0(s4)
    80005192:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005196:	000a3783          	ld	a5,0(s4)
    8000519a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000519e:	000a3783          	ld	a5,0(s4)
    800051a2:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800051a6:	000a3783          	ld	a5,0(s4)
    800051aa:	0127b823          	sd	s2,16(a5)
  return 0;
    800051ae:	4501                	li	a0,0
    800051b0:	a025                	j	800051d8 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800051b2:	6088                	ld	a0,0(s1)
    800051b4:	e501                	bnez	a0,800051bc <pipealloc+0xaa>
    800051b6:	a039                	j	800051c4 <pipealloc+0xb2>
    800051b8:	6088                	ld	a0,0(s1)
    800051ba:	c51d                	beqz	a0,800051e8 <pipealloc+0xd6>
    fileclose(*f0);
    800051bc:	00000097          	auipc	ra,0x0
    800051c0:	c26080e7          	jalr	-986(ra) # 80004de2 <fileclose>
  if(*f1)
    800051c4:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800051c8:	557d                	li	a0,-1
  if(*f1)
    800051ca:	c799                	beqz	a5,800051d8 <pipealloc+0xc6>
    fileclose(*f1);
    800051cc:	853e                	mv	a0,a5
    800051ce:	00000097          	auipc	ra,0x0
    800051d2:	c14080e7          	jalr	-1004(ra) # 80004de2 <fileclose>
  return -1;
    800051d6:	557d                	li	a0,-1
}
    800051d8:	70a2                	ld	ra,40(sp)
    800051da:	7402                	ld	s0,32(sp)
    800051dc:	64e2                	ld	s1,24(sp)
    800051de:	6942                	ld	s2,16(sp)
    800051e0:	69a2                	ld	s3,8(sp)
    800051e2:	6a02                	ld	s4,0(sp)
    800051e4:	6145                	addi	sp,sp,48
    800051e6:	8082                	ret
  return -1;
    800051e8:	557d                	li	a0,-1
    800051ea:	b7fd                	j	800051d8 <pipealloc+0xc6>

00000000800051ec <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800051ec:	1101                	addi	sp,sp,-32
    800051ee:	ec06                	sd	ra,24(sp)
    800051f0:	e822                	sd	s0,16(sp)
    800051f2:	e426                	sd	s1,8(sp)
    800051f4:	e04a                	sd	s2,0(sp)
    800051f6:	1000                	addi	s0,sp,32
    800051f8:	84aa                	mv	s1,a0
    800051fa:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800051fc:	ffffc097          	auipc	ra,0xffffc
    80005200:	bac080e7          	jalr	-1108(ra) # 80000da8 <acquire>
  if(writable){
    80005204:	02090d63          	beqz	s2,8000523e <pipeclose+0x52>
    pi->writeopen = 0;
    80005208:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000520c:	21848513          	addi	a0,s1,536
    80005210:	ffffd097          	auipc	ra,0xffffd
    80005214:	516080e7          	jalr	1302(ra) # 80002726 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005218:	2204b783          	ld	a5,544(s1)
    8000521c:	eb95                	bnez	a5,80005250 <pipeclose+0x64>
    release(&pi->lock);
    8000521e:	8526                	mv	a0,s1
    80005220:	ffffc097          	auipc	ra,0xffffc
    80005224:	c3c080e7          	jalr	-964(ra) # 80000e5c <release>
    kfree((char*)pi);
    80005228:	8526                	mv	a0,s1
    8000522a:	ffffc097          	auipc	ra,0xffffc
    8000522e:	8a4080e7          	jalr	-1884(ra) # 80000ace <kfree>
  } else
    release(&pi->lock);
}
    80005232:	60e2                	ld	ra,24(sp)
    80005234:	6442                	ld	s0,16(sp)
    80005236:	64a2                	ld	s1,8(sp)
    80005238:	6902                	ld	s2,0(sp)
    8000523a:	6105                	addi	sp,sp,32
    8000523c:	8082                	ret
    pi->readopen = 0;
    8000523e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005242:	21c48513          	addi	a0,s1,540
    80005246:	ffffd097          	auipc	ra,0xffffd
    8000524a:	4e0080e7          	jalr	1248(ra) # 80002726 <wakeup>
    8000524e:	b7e9                	j	80005218 <pipeclose+0x2c>
    release(&pi->lock);
    80005250:	8526                	mv	a0,s1
    80005252:	ffffc097          	auipc	ra,0xffffc
    80005256:	c0a080e7          	jalr	-1014(ra) # 80000e5c <release>
}
    8000525a:	bfe1                	j	80005232 <pipeclose+0x46>

000000008000525c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000525c:	7159                	addi	sp,sp,-112
    8000525e:	f486                	sd	ra,104(sp)
    80005260:	f0a2                	sd	s0,96(sp)
    80005262:	eca6                	sd	s1,88(sp)
    80005264:	e8ca                	sd	s2,80(sp)
    80005266:	e4ce                	sd	s3,72(sp)
    80005268:	e0d2                	sd	s4,64(sp)
    8000526a:	fc56                	sd	s5,56(sp)
    8000526c:	f85a                	sd	s6,48(sp)
    8000526e:	f45e                	sd	s7,40(sp)
    80005270:	f062                	sd	s8,32(sp)
    80005272:	ec66                	sd	s9,24(sp)
    80005274:	1880                	addi	s0,sp,112
    80005276:	84aa                	mv	s1,a0
    80005278:	8aae                	mv	s5,a1
    8000527a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000527c:	ffffd097          	auipc	ra,0xffffd
    80005280:	a3c080e7          	jalr	-1476(ra) # 80001cb8 <myproc>
    80005284:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005286:	8526                	mv	a0,s1
    80005288:	ffffc097          	auipc	ra,0xffffc
    8000528c:	b20080e7          	jalr	-1248(ra) # 80000da8 <acquire>
  while(i < n){
    80005290:	0d405463          	blez	s4,80005358 <pipewrite+0xfc>
    80005294:	8ba6                	mv	s7,s1
  int i = 0;
    80005296:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005298:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000529a:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000529e:	21c48c13          	addi	s8,s1,540
    800052a2:	a08d                	j	80005304 <pipewrite+0xa8>
      release(&pi->lock);
    800052a4:	8526                	mv	a0,s1
    800052a6:	ffffc097          	auipc	ra,0xffffc
    800052aa:	bb6080e7          	jalr	-1098(ra) # 80000e5c <release>
      return -1;
    800052ae:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800052b0:	854a                	mv	a0,s2
    800052b2:	70a6                	ld	ra,104(sp)
    800052b4:	7406                	ld	s0,96(sp)
    800052b6:	64e6                	ld	s1,88(sp)
    800052b8:	6946                	ld	s2,80(sp)
    800052ba:	69a6                	ld	s3,72(sp)
    800052bc:	6a06                	ld	s4,64(sp)
    800052be:	7ae2                	ld	s5,56(sp)
    800052c0:	7b42                	ld	s6,48(sp)
    800052c2:	7ba2                	ld	s7,40(sp)
    800052c4:	7c02                	ld	s8,32(sp)
    800052c6:	6ce2                	ld	s9,24(sp)
    800052c8:	6165                	addi	sp,sp,112
    800052ca:	8082                	ret
      wakeup(&pi->nread);
    800052cc:	8566                	mv	a0,s9
    800052ce:	ffffd097          	auipc	ra,0xffffd
    800052d2:	458080e7          	jalr	1112(ra) # 80002726 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800052d6:	85de                	mv	a1,s7
    800052d8:	8562                	mv	a0,s8
    800052da:	ffffd097          	auipc	ra,0xffffd
    800052de:	14e080e7          	jalr	334(ra) # 80002428 <sleep>
    800052e2:	a839                	j	80005300 <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800052e4:	21c4a783          	lw	a5,540(s1)
    800052e8:	0017871b          	addiw	a4,a5,1
    800052ec:	20e4ae23          	sw	a4,540(s1)
    800052f0:	1ff7f793          	andi	a5,a5,511
    800052f4:	97a6                	add	a5,a5,s1
    800052f6:	f9f44703          	lbu	a4,-97(s0)
    800052fa:	00e78c23          	sb	a4,24(a5)
      i++;
    800052fe:	2905                	addiw	s2,s2,1
  while(i < n){
    80005300:	05495063          	bge	s2,s4,80005340 <pipewrite+0xe4>
    if(pi->readopen == 0 || killed(pr)){
    80005304:	2204a783          	lw	a5,544(s1)
    80005308:	dfd1                	beqz	a5,800052a4 <pipewrite+0x48>
    8000530a:	854e                	mv	a0,s3
    8000530c:	ffffd097          	auipc	ra,0xffffd
    80005310:	6c0080e7          	jalr	1728(ra) # 800029cc <killed>
    80005314:	f941                	bnez	a0,800052a4 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005316:	2184a783          	lw	a5,536(s1)
    8000531a:	21c4a703          	lw	a4,540(s1)
    8000531e:	2007879b          	addiw	a5,a5,512
    80005322:	faf705e3          	beq	a4,a5,800052cc <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005326:	4685                	li	a3,1
    80005328:	01590633          	add	a2,s2,s5
    8000532c:	f9f40593          	addi	a1,s0,-97
    80005330:	0589b503          	ld	a0,88(s3)
    80005334:	ffffc097          	auipc	ra,0xffffc
    80005338:	5c4080e7          	jalr	1476(ra) # 800018f8 <copyin>
    8000533c:	fb6514e3          	bne	a0,s6,800052e4 <pipewrite+0x88>
  wakeup(&pi->nread);
    80005340:	21848513          	addi	a0,s1,536
    80005344:	ffffd097          	auipc	ra,0xffffd
    80005348:	3e2080e7          	jalr	994(ra) # 80002726 <wakeup>
  release(&pi->lock);
    8000534c:	8526                	mv	a0,s1
    8000534e:	ffffc097          	auipc	ra,0xffffc
    80005352:	b0e080e7          	jalr	-1266(ra) # 80000e5c <release>
  return i;
    80005356:	bfa9                	j	800052b0 <pipewrite+0x54>
  int i = 0;
    80005358:	4901                	li	s2,0
    8000535a:	b7dd                	j	80005340 <pipewrite+0xe4>

000000008000535c <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000535c:	715d                	addi	sp,sp,-80
    8000535e:	e486                	sd	ra,72(sp)
    80005360:	e0a2                	sd	s0,64(sp)
    80005362:	fc26                	sd	s1,56(sp)
    80005364:	f84a                	sd	s2,48(sp)
    80005366:	f44e                	sd	s3,40(sp)
    80005368:	f052                	sd	s4,32(sp)
    8000536a:	ec56                	sd	s5,24(sp)
    8000536c:	e85a                	sd	s6,16(sp)
    8000536e:	0880                	addi	s0,sp,80
    80005370:	84aa                	mv	s1,a0
    80005372:	892e                	mv	s2,a1
    80005374:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005376:	ffffd097          	auipc	ra,0xffffd
    8000537a:	942080e7          	jalr	-1726(ra) # 80001cb8 <myproc>
    8000537e:	8a2a                	mv	s4,a0
  char ch;
  // printf("here1\n");

  acquire(&pi->lock);
    80005380:	8b26                	mv	s6,s1
    80005382:	8526                	mv	a0,s1
    80005384:	ffffc097          	auipc	ra,0xffffc
    80005388:	a24080e7          	jalr	-1500(ra) # 80000da8 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000538c:	2184a703          	lw	a4,536(s1)
    80005390:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005394:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005398:	02f71763          	bne	a4,a5,800053c6 <piperead+0x6a>
    8000539c:	2244a783          	lw	a5,548(s1)
    800053a0:	c39d                	beqz	a5,800053c6 <piperead+0x6a>
    if(killed(pr)){
    800053a2:	8552                	mv	a0,s4
    800053a4:	ffffd097          	auipc	ra,0xffffd
    800053a8:	628080e7          	jalr	1576(ra) # 800029cc <killed>
    800053ac:	e941                	bnez	a0,8000543c <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800053ae:	85da                	mv	a1,s6
    800053b0:	854e                	mv	a0,s3
    800053b2:	ffffd097          	auipc	ra,0xffffd
    800053b6:	076080e7          	jalr	118(ra) # 80002428 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800053ba:	2184a703          	lw	a4,536(s1)
    800053be:	21c4a783          	lw	a5,540(s1)
    800053c2:	fcf70de3          	beq	a4,a5,8000539c <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800053c6:	09505263          	blez	s5,8000544a <piperead+0xee>
    800053ca:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800053cc:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    800053ce:	2184a783          	lw	a5,536(s1)
    800053d2:	21c4a703          	lw	a4,540(s1)
    800053d6:	02f70d63          	beq	a4,a5,80005410 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800053da:	0017871b          	addiw	a4,a5,1
    800053de:	20e4ac23          	sw	a4,536(s1)
    800053e2:	1ff7f793          	andi	a5,a5,511
    800053e6:	97a6                	add	a5,a5,s1
    800053e8:	0187c783          	lbu	a5,24(a5)
    800053ec:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800053f0:	4685                	li	a3,1
    800053f2:	fbf40613          	addi	a2,s0,-65
    800053f6:	85ca                	mv	a1,s2
    800053f8:	058a3503          	ld	a0,88(s4)
    800053fc:	ffffc097          	auipc	ra,0xffffc
    80005400:	43c080e7          	jalr	1084(ra) # 80001838 <copyout>
    80005404:	01650663          	beq	a0,s6,80005410 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005408:	2985                	addiw	s3,s3,1
    8000540a:	0905                	addi	s2,s2,1
    8000540c:	fd3a91e3          	bne	s5,s3,800053ce <piperead+0x72>
      break;
  }
  // printf("here2\n");
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005410:	21c48513          	addi	a0,s1,540
    80005414:	ffffd097          	auipc	ra,0xffffd
    80005418:	312080e7          	jalr	786(ra) # 80002726 <wakeup>
  release(&pi->lock);
    8000541c:	8526                	mv	a0,s1
    8000541e:	ffffc097          	auipc	ra,0xffffc
    80005422:	a3e080e7          	jalr	-1474(ra) # 80000e5c <release>
  return i;
}
    80005426:	854e                	mv	a0,s3
    80005428:	60a6                	ld	ra,72(sp)
    8000542a:	6406                	ld	s0,64(sp)
    8000542c:	74e2                	ld	s1,56(sp)
    8000542e:	7942                	ld	s2,48(sp)
    80005430:	79a2                	ld	s3,40(sp)
    80005432:	7a02                	ld	s4,32(sp)
    80005434:	6ae2                	ld	s5,24(sp)
    80005436:	6b42                	ld	s6,16(sp)
    80005438:	6161                	addi	sp,sp,80
    8000543a:	8082                	ret
      release(&pi->lock);
    8000543c:	8526                	mv	a0,s1
    8000543e:	ffffc097          	auipc	ra,0xffffc
    80005442:	a1e080e7          	jalr	-1506(ra) # 80000e5c <release>
      return -1;
    80005446:	59fd                	li	s3,-1
    80005448:	bff9                	j	80005426 <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000544a:	4981                	li	s3,0
    8000544c:	b7d1                	j	80005410 <piperead+0xb4>

000000008000544e <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    8000544e:	1141                	addi	sp,sp,-16
    80005450:	e422                	sd	s0,8(sp)
    80005452:	0800                	addi	s0,sp,16
    80005454:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80005456:	8905                	andi	a0,a0,1
    80005458:	c111                	beqz	a0,8000545c <flags2perm+0xe>
      perm = PTE_X;
    8000545a:	4521                	li	a0,8
    if(flags & 0x2)
    8000545c:	8b89                	andi	a5,a5,2
    8000545e:	c399                	beqz	a5,80005464 <flags2perm+0x16>
      perm |= PTE_W;
    80005460:	00456513          	ori	a0,a0,4
    return perm;
}
    80005464:	6422                	ld	s0,8(sp)
    80005466:	0141                	addi	sp,sp,16
    80005468:	8082                	ret

000000008000546a <exec>:

int
exec(char *path, char **argv)
{
    8000546a:	df010113          	addi	sp,sp,-528
    8000546e:	20113423          	sd	ra,520(sp)
    80005472:	20813023          	sd	s0,512(sp)
    80005476:	ffa6                	sd	s1,504(sp)
    80005478:	fbca                	sd	s2,496(sp)
    8000547a:	f7ce                	sd	s3,488(sp)
    8000547c:	f3d2                	sd	s4,480(sp)
    8000547e:	efd6                	sd	s5,472(sp)
    80005480:	ebda                	sd	s6,464(sp)
    80005482:	e7de                	sd	s7,456(sp)
    80005484:	e3e2                	sd	s8,448(sp)
    80005486:	ff66                	sd	s9,440(sp)
    80005488:	fb6a                	sd	s10,432(sp)
    8000548a:	f76e                	sd	s11,424(sp)
    8000548c:	0c00                	addi	s0,sp,528
    8000548e:	84aa                	mv	s1,a0
    80005490:	dea43c23          	sd	a0,-520(s0)
    80005494:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005498:	ffffd097          	auipc	ra,0xffffd
    8000549c:	820080e7          	jalr	-2016(ra) # 80001cb8 <myproc>
    800054a0:	892a                	mv	s2,a0

  begin_op();
    800054a2:	fffff097          	auipc	ra,0xfffff
    800054a6:	474080e7          	jalr	1140(ra) # 80004916 <begin_op>

  if((ip = namei(path)) == 0){
    800054aa:	8526                	mv	a0,s1
    800054ac:	fffff097          	auipc	ra,0xfffff
    800054b0:	24e080e7          	jalr	590(ra) # 800046fa <namei>
    800054b4:	c92d                	beqz	a0,80005526 <exec+0xbc>
    800054b6:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800054b8:	fffff097          	auipc	ra,0xfffff
    800054bc:	a9c080e7          	jalr	-1380(ra) # 80003f54 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800054c0:	04000713          	li	a4,64
    800054c4:	4681                	li	a3,0
    800054c6:	e5040613          	addi	a2,s0,-432
    800054ca:	4581                	li	a1,0
    800054cc:	8526                	mv	a0,s1
    800054ce:	fffff097          	auipc	ra,0xfffff
    800054d2:	d3a080e7          	jalr	-710(ra) # 80004208 <readi>
    800054d6:	04000793          	li	a5,64
    800054da:	00f51a63          	bne	a0,a5,800054ee <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800054de:	e5042703          	lw	a4,-432(s0)
    800054e2:	464c47b7          	lui	a5,0x464c4
    800054e6:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800054ea:	04f70463          	beq	a4,a5,80005532 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800054ee:	8526                	mv	a0,s1
    800054f0:	fffff097          	auipc	ra,0xfffff
    800054f4:	cc6080e7          	jalr	-826(ra) # 800041b6 <iunlockput>
    end_op();
    800054f8:	fffff097          	auipc	ra,0xfffff
    800054fc:	49e080e7          	jalr	1182(ra) # 80004996 <end_op>
  }
  return -1;
    80005500:	557d                	li	a0,-1
}
    80005502:	20813083          	ld	ra,520(sp)
    80005506:	20013403          	ld	s0,512(sp)
    8000550a:	74fe                	ld	s1,504(sp)
    8000550c:	795e                	ld	s2,496(sp)
    8000550e:	79be                	ld	s3,488(sp)
    80005510:	7a1e                	ld	s4,480(sp)
    80005512:	6afe                	ld	s5,472(sp)
    80005514:	6b5e                	ld	s6,464(sp)
    80005516:	6bbe                	ld	s7,456(sp)
    80005518:	6c1e                	ld	s8,448(sp)
    8000551a:	7cfa                	ld	s9,440(sp)
    8000551c:	7d5a                	ld	s10,432(sp)
    8000551e:	7dba                	ld	s11,424(sp)
    80005520:	21010113          	addi	sp,sp,528
    80005524:	8082                	ret
    end_op();
    80005526:	fffff097          	auipc	ra,0xfffff
    8000552a:	470080e7          	jalr	1136(ra) # 80004996 <end_op>
    return -1;
    8000552e:	557d                	li	a0,-1
    80005530:	bfc9                	j	80005502 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80005532:	854a                	mv	a0,s2
    80005534:	ffffd097          	auipc	ra,0xffffd
    80005538:	84a080e7          	jalr	-1974(ra) # 80001d7e <proc_pagetable>
    8000553c:	8baa                	mv	s7,a0
    8000553e:	d945                	beqz	a0,800054ee <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005540:	e7042983          	lw	s3,-400(s0)
    80005544:	e8845783          	lhu	a5,-376(s0)
    80005548:	c7ad                	beqz	a5,800055b2 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000554a:	4a01                	li	s4,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000554c:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    8000554e:	6c85                	lui	s9,0x1
    80005550:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80005554:	def43823          	sd	a5,-528(s0)
    80005558:	ac0d                	j	8000578a <exec+0x320>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    8000555a:	00003517          	auipc	a0,0x3
    8000555e:	2ee50513          	addi	a0,a0,750 # 80008848 <syscalls+0x2a0>
    80005562:	ffffb097          	auipc	ra,0xffffb
    80005566:	fe2080e7          	jalr	-30(ra) # 80000544 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000556a:	8756                	mv	a4,s5
    8000556c:	012d86bb          	addw	a3,s11,s2
    80005570:	4581                	li	a1,0
    80005572:	8526                	mv	a0,s1
    80005574:	fffff097          	auipc	ra,0xfffff
    80005578:	c94080e7          	jalr	-876(ra) # 80004208 <readi>
    8000557c:	2501                	sext.w	a0,a0
    8000557e:	1aaa9a63          	bne	s5,a0,80005732 <exec+0x2c8>
  for(i = 0; i < sz; i += PGSIZE){
    80005582:	6785                	lui	a5,0x1
    80005584:	0127893b          	addw	s2,a5,s2
    80005588:	77fd                	lui	a5,0xfffff
    8000558a:	01478a3b          	addw	s4,a5,s4
    8000558e:	1f897563          	bgeu	s2,s8,80005778 <exec+0x30e>
    pa = walkaddr(pagetable, va + i);
    80005592:	02091593          	slli	a1,s2,0x20
    80005596:	9181                	srli	a1,a1,0x20
    80005598:	95ea                	add	a1,a1,s10
    8000559a:	855e                	mv	a0,s7
    8000559c:	ffffc097          	auipc	ra,0xffffc
    800055a0:	c9a080e7          	jalr	-870(ra) # 80001236 <walkaddr>
    800055a4:	862a                	mv	a2,a0
    if(pa == 0)
    800055a6:	d955                	beqz	a0,8000555a <exec+0xf0>
      n = PGSIZE;
    800055a8:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    800055aa:	fd9a70e3          	bgeu	s4,s9,8000556a <exec+0x100>
      n = sz - i;
    800055ae:	8ad2                	mv	s5,s4
    800055b0:	bf6d                	j	8000556a <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800055b2:	4a01                	li	s4,0
  iunlockput(ip);
    800055b4:	8526                	mv	a0,s1
    800055b6:	fffff097          	auipc	ra,0xfffff
    800055ba:	c00080e7          	jalr	-1024(ra) # 800041b6 <iunlockput>
  end_op();
    800055be:	fffff097          	auipc	ra,0xfffff
    800055c2:	3d8080e7          	jalr	984(ra) # 80004996 <end_op>
  p = myproc();
    800055c6:	ffffc097          	auipc	ra,0xffffc
    800055ca:	6f2080e7          	jalr	1778(ra) # 80001cb8 <myproc>
    800055ce:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800055d0:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    800055d4:	6785                	lui	a5,0x1
    800055d6:	17fd                	addi	a5,a5,-1
    800055d8:	9a3e                	add	s4,s4,a5
    800055da:	757d                	lui	a0,0xfffff
    800055dc:	00aa77b3          	and	a5,s4,a0
    800055e0:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800055e4:	4691                	li	a3,4
    800055e6:	6609                	lui	a2,0x2
    800055e8:	963e                	add	a2,a2,a5
    800055ea:	85be                	mv	a1,a5
    800055ec:	855e                	mv	a0,s7
    800055ee:	ffffc097          	auipc	ra,0xffffc
    800055f2:	ffc080e7          	jalr	-4(ra) # 800015ea <uvmalloc>
    800055f6:	8b2a                	mv	s6,a0
  ip = 0;
    800055f8:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800055fa:	12050c63          	beqz	a0,80005732 <exec+0x2c8>
  uvmclear(pagetable, sz-2*PGSIZE);
    800055fe:	75f9                	lui	a1,0xffffe
    80005600:	95aa                	add	a1,a1,a0
    80005602:	855e                	mv	a0,s7
    80005604:	ffffc097          	auipc	ra,0xffffc
    80005608:	202080e7          	jalr	514(ra) # 80001806 <uvmclear>
  stackbase = sp - PGSIZE;
    8000560c:	7c7d                	lui	s8,0xfffff
    8000560e:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80005610:	e0043783          	ld	a5,-512(s0)
    80005614:	6388                	ld	a0,0(a5)
    80005616:	c535                	beqz	a0,80005682 <exec+0x218>
    80005618:	e9040993          	addi	s3,s0,-368
    8000561c:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80005620:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80005622:	ffffc097          	auipc	ra,0xffffc
    80005626:	a06080e7          	jalr	-1530(ra) # 80001028 <strlen>
    8000562a:	2505                	addiw	a0,a0,1
    8000562c:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005630:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005634:	13896663          	bltu	s2,s8,80005760 <exec+0x2f6>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005638:	e0043d83          	ld	s11,-512(s0)
    8000563c:	000dba03          	ld	s4,0(s11)
    80005640:	8552                	mv	a0,s4
    80005642:	ffffc097          	auipc	ra,0xffffc
    80005646:	9e6080e7          	jalr	-1562(ra) # 80001028 <strlen>
    8000564a:	0015069b          	addiw	a3,a0,1
    8000564e:	8652                	mv	a2,s4
    80005650:	85ca                	mv	a1,s2
    80005652:	855e                	mv	a0,s7
    80005654:	ffffc097          	auipc	ra,0xffffc
    80005658:	1e4080e7          	jalr	484(ra) # 80001838 <copyout>
    8000565c:	10054663          	bltz	a0,80005768 <exec+0x2fe>
    ustack[argc] = sp;
    80005660:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005664:	0485                	addi	s1,s1,1
    80005666:	008d8793          	addi	a5,s11,8
    8000566a:	e0f43023          	sd	a5,-512(s0)
    8000566e:	008db503          	ld	a0,8(s11)
    80005672:	c911                	beqz	a0,80005686 <exec+0x21c>
    if(argc >= MAXARG)
    80005674:	09a1                	addi	s3,s3,8
    80005676:	fb3c96e3          	bne	s9,s3,80005622 <exec+0x1b8>
  sz = sz1;
    8000567a:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000567e:	4481                	li	s1,0
    80005680:	a84d                	j	80005732 <exec+0x2c8>
  sp = sz;
    80005682:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005684:	4481                	li	s1,0
  ustack[argc] = 0;
    80005686:	00349793          	slli	a5,s1,0x3
    8000568a:	f9040713          	addi	a4,s0,-112
    8000568e:	97ba                	add	a5,a5,a4
    80005690:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    80005694:	00148693          	addi	a3,s1,1
    80005698:	068e                	slli	a3,a3,0x3
    8000569a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000569e:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800056a2:	01897663          	bgeu	s2,s8,800056ae <exec+0x244>
  sz = sz1;
    800056a6:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800056aa:	4481                	li	s1,0
    800056ac:	a059                	j	80005732 <exec+0x2c8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800056ae:	e9040613          	addi	a2,s0,-368
    800056b2:	85ca                	mv	a1,s2
    800056b4:	855e                	mv	a0,s7
    800056b6:	ffffc097          	auipc	ra,0xffffc
    800056ba:	182080e7          	jalr	386(ra) # 80001838 <copyout>
    800056be:	0a054963          	bltz	a0,80005770 <exec+0x306>
  p->trapframe->a1 = sp;
    800056c2:	060ab783          	ld	a5,96(s5)
    800056c6:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800056ca:	df843783          	ld	a5,-520(s0)
    800056ce:	0007c703          	lbu	a4,0(a5)
    800056d2:	cf11                	beqz	a4,800056ee <exec+0x284>
    800056d4:	0785                	addi	a5,a5,1
    if(*s == '/')
    800056d6:	02f00693          	li	a3,47
    800056da:	a039                	j	800056e8 <exec+0x27e>
      last = s+1;
    800056dc:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800056e0:	0785                	addi	a5,a5,1
    800056e2:	fff7c703          	lbu	a4,-1(a5)
    800056e6:	c701                	beqz	a4,800056ee <exec+0x284>
    if(*s == '/')
    800056e8:	fed71ce3          	bne	a4,a3,800056e0 <exec+0x276>
    800056ec:	bfc5                	j	800056dc <exec+0x272>
  safestrcpy(p->name, last, sizeof(p->name));
    800056ee:	4641                	li	a2,16
    800056f0:	df843583          	ld	a1,-520(s0)
    800056f4:	160a8513          	addi	a0,s5,352
    800056f8:	ffffc097          	auipc	ra,0xffffc
    800056fc:	8fe080e7          	jalr	-1794(ra) # 80000ff6 <safestrcpy>
  oldpagetable = p->pagetable;
    80005700:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    80005704:	057abc23          	sd	s7,88(s5)
  p->sz = sz;
    80005708:	056ab823          	sd	s6,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000570c:	060ab783          	ld	a5,96(s5)
    80005710:	e6843703          	ld	a4,-408(s0)
    80005714:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005716:	060ab783          	ld	a5,96(s5)
    8000571a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000571e:	85ea                	mv	a1,s10
    80005720:	ffffc097          	auipc	ra,0xffffc
    80005724:	6fa080e7          	jalr	1786(ra) # 80001e1a <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005728:	0004851b          	sext.w	a0,s1
    8000572c:	bbd9                	j	80005502 <exec+0x98>
    8000572e:	e1443423          	sd	s4,-504(s0)
    proc_freepagetable(pagetable, sz);
    80005732:	e0843583          	ld	a1,-504(s0)
    80005736:	855e                	mv	a0,s7
    80005738:	ffffc097          	auipc	ra,0xffffc
    8000573c:	6e2080e7          	jalr	1762(ra) # 80001e1a <proc_freepagetable>
  if(ip){
    80005740:	da0497e3          	bnez	s1,800054ee <exec+0x84>
  return -1;
    80005744:	557d                	li	a0,-1
    80005746:	bb75                	j	80005502 <exec+0x98>
    80005748:	e1443423          	sd	s4,-504(s0)
    8000574c:	b7dd                	j	80005732 <exec+0x2c8>
    8000574e:	e1443423          	sd	s4,-504(s0)
    80005752:	b7c5                	j	80005732 <exec+0x2c8>
    80005754:	e1443423          	sd	s4,-504(s0)
    80005758:	bfe9                	j	80005732 <exec+0x2c8>
    8000575a:	e1443423          	sd	s4,-504(s0)
    8000575e:	bfd1                	j	80005732 <exec+0x2c8>
  sz = sz1;
    80005760:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005764:	4481                	li	s1,0
    80005766:	b7f1                	j	80005732 <exec+0x2c8>
  sz = sz1;
    80005768:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000576c:	4481                	li	s1,0
    8000576e:	b7d1                	j	80005732 <exec+0x2c8>
  sz = sz1;
    80005770:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005774:	4481                	li	s1,0
    80005776:	bf75                	j	80005732 <exec+0x2c8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005778:	e0843a03          	ld	s4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000577c:	2b05                	addiw	s6,s6,1
    8000577e:	0389899b          	addiw	s3,s3,56
    80005782:	e8845783          	lhu	a5,-376(s0)
    80005786:	e2fb57e3          	bge	s6,a5,800055b4 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000578a:	2981                	sext.w	s3,s3
    8000578c:	03800713          	li	a4,56
    80005790:	86ce                	mv	a3,s3
    80005792:	e1840613          	addi	a2,s0,-488
    80005796:	4581                	li	a1,0
    80005798:	8526                	mv	a0,s1
    8000579a:	fffff097          	auipc	ra,0xfffff
    8000579e:	a6e080e7          	jalr	-1426(ra) # 80004208 <readi>
    800057a2:	03800793          	li	a5,56
    800057a6:	f8f514e3          	bne	a0,a5,8000572e <exec+0x2c4>
    if(ph.type != ELF_PROG_LOAD)
    800057aa:	e1842783          	lw	a5,-488(s0)
    800057ae:	4705                	li	a4,1
    800057b0:	fce796e3          	bne	a5,a4,8000577c <exec+0x312>
    if(ph.memsz < ph.filesz)
    800057b4:	e4043903          	ld	s2,-448(s0)
    800057b8:	e3843783          	ld	a5,-456(s0)
    800057bc:	f8f966e3          	bltu	s2,a5,80005748 <exec+0x2de>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800057c0:	e2843783          	ld	a5,-472(s0)
    800057c4:	993e                	add	s2,s2,a5
    800057c6:	f8f964e3          	bltu	s2,a5,8000574e <exec+0x2e4>
    if(ph.vaddr % PGSIZE != 0)
    800057ca:	df043703          	ld	a4,-528(s0)
    800057ce:	8ff9                	and	a5,a5,a4
    800057d0:	f3d1                	bnez	a5,80005754 <exec+0x2ea>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800057d2:	e1c42503          	lw	a0,-484(s0)
    800057d6:	00000097          	auipc	ra,0x0
    800057da:	c78080e7          	jalr	-904(ra) # 8000544e <flags2perm>
    800057de:	86aa                	mv	a3,a0
    800057e0:	864a                	mv	a2,s2
    800057e2:	85d2                	mv	a1,s4
    800057e4:	855e                	mv	a0,s7
    800057e6:	ffffc097          	auipc	ra,0xffffc
    800057ea:	e04080e7          	jalr	-508(ra) # 800015ea <uvmalloc>
    800057ee:	e0a43423          	sd	a0,-504(s0)
    800057f2:	d525                	beqz	a0,8000575a <exec+0x2f0>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800057f4:	e2843d03          	ld	s10,-472(s0)
    800057f8:	e2042d83          	lw	s11,-480(s0)
    800057fc:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005800:	f60c0ce3          	beqz	s8,80005778 <exec+0x30e>
    80005804:	8a62                	mv	s4,s8
    80005806:	4901                	li	s2,0
    80005808:	b369                	j	80005592 <exec+0x128>

000000008000580a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000580a:	7179                	addi	sp,sp,-48
    8000580c:	f406                	sd	ra,40(sp)
    8000580e:	f022                	sd	s0,32(sp)
    80005810:	ec26                	sd	s1,24(sp)
    80005812:	e84a                	sd	s2,16(sp)
    80005814:	1800                	addi	s0,sp,48
    80005816:	892e                	mv	s2,a1
    80005818:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000581a:	fdc40593          	addi	a1,s0,-36
    8000581e:	ffffe097          	auipc	ra,0xffffe
    80005822:	914080e7          	jalr	-1772(ra) # 80003132 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005826:	fdc42703          	lw	a4,-36(s0)
    8000582a:	47bd                	li	a5,15
    8000582c:	02e7eb63          	bltu	a5,a4,80005862 <argfd+0x58>
    80005830:	ffffc097          	auipc	ra,0xffffc
    80005834:	488080e7          	jalr	1160(ra) # 80001cb8 <myproc>
    80005838:	fdc42703          	lw	a4,-36(s0)
    8000583c:	01a70793          	addi	a5,a4,26
    80005840:	078e                	slli	a5,a5,0x3
    80005842:	953e                	add	a0,a0,a5
    80005844:	651c                	ld	a5,8(a0)
    80005846:	c385                	beqz	a5,80005866 <argfd+0x5c>
    return -1;
  if(pfd)
    80005848:	00090463          	beqz	s2,80005850 <argfd+0x46>
    *pfd = fd;
    8000584c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005850:	4501                	li	a0,0
  if(pf)
    80005852:	c091                	beqz	s1,80005856 <argfd+0x4c>
    *pf = f;
    80005854:	e09c                	sd	a5,0(s1)
}
    80005856:	70a2                	ld	ra,40(sp)
    80005858:	7402                	ld	s0,32(sp)
    8000585a:	64e2                	ld	s1,24(sp)
    8000585c:	6942                	ld	s2,16(sp)
    8000585e:	6145                	addi	sp,sp,48
    80005860:	8082                	ret
    return -1;
    80005862:	557d                	li	a0,-1
    80005864:	bfcd                	j	80005856 <argfd+0x4c>
    80005866:	557d                	li	a0,-1
    80005868:	b7fd                	j	80005856 <argfd+0x4c>

000000008000586a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000586a:	1101                	addi	sp,sp,-32
    8000586c:	ec06                	sd	ra,24(sp)
    8000586e:	e822                	sd	s0,16(sp)
    80005870:	e426                	sd	s1,8(sp)
    80005872:	1000                	addi	s0,sp,32
    80005874:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005876:	ffffc097          	auipc	ra,0xffffc
    8000587a:	442080e7          	jalr	1090(ra) # 80001cb8 <myproc>
    8000587e:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005880:	0d850793          	addi	a5,a0,216 # fffffffffffff0d8 <end+0xffffffff7fdbb640>
    80005884:	4501                	li	a0,0
    80005886:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005888:	6398                	ld	a4,0(a5)
    8000588a:	cb19                	beqz	a4,800058a0 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000588c:	2505                	addiw	a0,a0,1
    8000588e:	07a1                	addi	a5,a5,8
    80005890:	fed51ce3          	bne	a0,a3,80005888 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005894:	557d                	li	a0,-1
}
    80005896:	60e2                	ld	ra,24(sp)
    80005898:	6442                	ld	s0,16(sp)
    8000589a:	64a2                	ld	s1,8(sp)
    8000589c:	6105                	addi	sp,sp,32
    8000589e:	8082                	ret
      p->ofile[fd] = f;
    800058a0:	01a50793          	addi	a5,a0,26
    800058a4:	078e                	slli	a5,a5,0x3
    800058a6:	963e                	add	a2,a2,a5
    800058a8:	e604                	sd	s1,8(a2)
      return fd;
    800058aa:	b7f5                	j	80005896 <fdalloc+0x2c>

00000000800058ac <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800058ac:	715d                	addi	sp,sp,-80
    800058ae:	e486                	sd	ra,72(sp)
    800058b0:	e0a2                	sd	s0,64(sp)
    800058b2:	fc26                	sd	s1,56(sp)
    800058b4:	f84a                	sd	s2,48(sp)
    800058b6:	f44e                	sd	s3,40(sp)
    800058b8:	f052                	sd	s4,32(sp)
    800058ba:	ec56                	sd	s5,24(sp)
    800058bc:	e85a                	sd	s6,16(sp)
    800058be:	0880                	addi	s0,sp,80
    800058c0:	8b2e                	mv	s6,a1
    800058c2:	89b2                	mv	s3,a2
    800058c4:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800058c6:	fb040593          	addi	a1,s0,-80
    800058ca:	fffff097          	auipc	ra,0xfffff
    800058ce:	e4e080e7          	jalr	-434(ra) # 80004718 <nameiparent>
    800058d2:	84aa                	mv	s1,a0
    800058d4:	16050063          	beqz	a0,80005a34 <create+0x188>
    return 0;

  ilock(dp);
    800058d8:	ffffe097          	auipc	ra,0xffffe
    800058dc:	67c080e7          	jalr	1660(ra) # 80003f54 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800058e0:	4601                	li	a2,0
    800058e2:	fb040593          	addi	a1,s0,-80
    800058e6:	8526                	mv	a0,s1
    800058e8:	fffff097          	auipc	ra,0xfffff
    800058ec:	b50080e7          	jalr	-1200(ra) # 80004438 <dirlookup>
    800058f0:	8aaa                	mv	s5,a0
    800058f2:	c931                	beqz	a0,80005946 <create+0x9a>
    iunlockput(dp);
    800058f4:	8526                	mv	a0,s1
    800058f6:	fffff097          	auipc	ra,0xfffff
    800058fa:	8c0080e7          	jalr	-1856(ra) # 800041b6 <iunlockput>
    ilock(ip);
    800058fe:	8556                	mv	a0,s5
    80005900:	ffffe097          	auipc	ra,0xffffe
    80005904:	654080e7          	jalr	1620(ra) # 80003f54 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005908:	000b059b          	sext.w	a1,s6
    8000590c:	4789                	li	a5,2
    8000590e:	02f59563          	bne	a1,a5,80005938 <create+0x8c>
    80005912:	044ad783          	lhu	a5,68(s5)
    80005916:	37f9                	addiw	a5,a5,-2
    80005918:	17c2                	slli	a5,a5,0x30
    8000591a:	93c1                	srli	a5,a5,0x30
    8000591c:	4705                	li	a4,1
    8000591e:	00f76d63          	bltu	a4,a5,80005938 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005922:	8556                	mv	a0,s5
    80005924:	60a6                	ld	ra,72(sp)
    80005926:	6406                	ld	s0,64(sp)
    80005928:	74e2                	ld	s1,56(sp)
    8000592a:	7942                	ld	s2,48(sp)
    8000592c:	79a2                	ld	s3,40(sp)
    8000592e:	7a02                	ld	s4,32(sp)
    80005930:	6ae2                	ld	s5,24(sp)
    80005932:	6b42                	ld	s6,16(sp)
    80005934:	6161                	addi	sp,sp,80
    80005936:	8082                	ret
    iunlockput(ip);
    80005938:	8556                	mv	a0,s5
    8000593a:	fffff097          	auipc	ra,0xfffff
    8000593e:	87c080e7          	jalr	-1924(ra) # 800041b6 <iunlockput>
    return 0;
    80005942:	4a81                	li	s5,0
    80005944:	bff9                	j	80005922 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005946:	85da                	mv	a1,s6
    80005948:	4088                	lw	a0,0(s1)
    8000594a:	ffffe097          	auipc	ra,0xffffe
    8000594e:	46e080e7          	jalr	1134(ra) # 80003db8 <ialloc>
    80005952:	8a2a                	mv	s4,a0
    80005954:	c921                	beqz	a0,800059a4 <create+0xf8>
  ilock(ip);
    80005956:	ffffe097          	auipc	ra,0xffffe
    8000595a:	5fe080e7          	jalr	1534(ra) # 80003f54 <ilock>
  ip->major = major;
    8000595e:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005962:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005966:	4785                	li	a5,1
    80005968:	04fa1523          	sh	a5,74(s4)
  iupdate(ip);
    8000596c:	8552                	mv	a0,s4
    8000596e:	ffffe097          	auipc	ra,0xffffe
    80005972:	51c080e7          	jalr	1308(ra) # 80003e8a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005976:	000b059b          	sext.w	a1,s6
    8000597a:	4785                	li	a5,1
    8000597c:	02f58b63          	beq	a1,a5,800059b2 <create+0x106>
  if(dirlink(dp, name, ip->inum) < 0)
    80005980:	004a2603          	lw	a2,4(s4)
    80005984:	fb040593          	addi	a1,s0,-80
    80005988:	8526                	mv	a0,s1
    8000598a:	fffff097          	auipc	ra,0xfffff
    8000598e:	cbe080e7          	jalr	-834(ra) # 80004648 <dirlink>
    80005992:	06054f63          	bltz	a0,80005a10 <create+0x164>
  iunlockput(dp);
    80005996:	8526                	mv	a0,s1
    80005998:	fffff097          	auipc	ra,0xfffff
    8000599c:	81e080e7          	jalr	-2018(ra) # 800041b6 <iunlockput>
  return ip;
    800059a0:	8ad2                	mv	s5,s4
    800059a2:	b741                	j	80005922 <create+0x76>
    iunlockput(dp);
    800059a4:	8526                	mv	a0,s1
    800059a6:	fffff097          	auipc	ra,0xfffff
    800059aa:	810080e7          	jalr	-2032(ra) # 800041b6 <iunlockput>
    return 0;
    800059ae:	8ad2                	mv	s5,s4
    800059b0:	bf8d                	j	80005922 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800059b2:	004a2603          	lw	a2,4(s4)
    800059b6:	00003597          	auipc	a1,0x3
    800059ba:	eb258593          	addi	a1,a1,-334 # 80008868 <syscalls+0x2c0>
    800059be:	8552                	mv	a0,s4
    800059c0:	fffff097          	auipc	ra,0xfffff
    800059c4:	c88080e7          	jalr	-888(ra) # 80004648 <dirlink>
    800059c8:	04054463          	bltz	a0,80005a10 <create+0x164>
    800059cc:	40d0                	lw	a2,4(s1)
    800059ce:	00003597          	auipc	a1,0x3
    800059d2:	ea258593          	addi	a1,a1,-350 # 80008870 <syscalls+0x2c8>
    800059d6:	8552                	mv	a0,s4
    800059d8:	fffff097          	auipc	ra,0xfffff
    800059dc:	c70080e7          	jalr	-912(ra) # 80004648 <dirlink>
    800059e0:	02054863          	bltz	a0,80005a10 <create+0x164>
  if(dirlink(dp, name, ip->inum) < 0)
    800059e4:	004a2603          	lw	a2,4(s4)
    800059e8:	fb040593          	addi	a1,s0,-80
    800059ec:	8526                	mv	a0,s1
    800059ee:	fffff097          	auipc	ra,0xfffff
    800059f2:	c5a080e7          	jalr	-934(ra) # 80004648 <dirlink>
    800059f6:	00054d63          	bltz	a0,80005a10 <create+0x164>
    dp->nlink++;  // for ".."
    800059fa:	04a4d783          	lhu	a5,74(s1)
    800059fe:	2785                	addiw	a5,a5,1
    80005a00:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005a04:	8526                	mv	a0,s1
    80005a06:	ffffe097          	auipc	ra,0xffffe
    80005a0a:	484080e7          	jalr	1156(ra) # 80003e8a <iupdate>
    80005a0e:	b761                	j	80005996 <create+0xea>
  ip->nlink = 0;
    80005a10:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005a14:	8552                	mv	a0,s4
    80005a16:	ffffe097          	auipc	ra,0xffffe
    80005a1a:	474080e7          	jalr	1140(ra) # 80003e8a <iupdate>
  iunlockput(ip);
    80005a1e:	8552                	mv	a0,s4
    80005a20:	ffffe097          	auipc	ra,0xffffe
    80005a24:	796080e7          	jalr	1942(ra) # 800041b6 <iunlockput>
  iunlockput(dp);
    80005a28:	8526                	mv	a0,s1
    80005a2a:	ffffe097          	auipc	ra,0xffffe
    80005a2e:	78c080e7          	jalr	1932(ra) # 800041b6 <iunlockput>
  return 0;
    80005a32:	bdc5                	j	80005922 <create+0x76>
    return 0;
    80005a34:	8aaa                	mv	s5,a0
    80005a36:	b5f5                	j	80005922 <create+0x76>

0000000080005a38 <sys_dup>:
{
    80005a38:	7179                	addi	sp,sp,-48
    80005a3a:	f406                	sd	ra,40(sp)
    80005a3c:	f022                	sd	s0,32(sp)
    80005a3e:	ec26                	sd	s1,24(sp)
    80005a40:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005a42:	fd840613          	addi	a2,s0,-40
    80005a46:	4581                	li	a1,0
    80005a48:	4501                	li	a0,0
    80005a4a:	00000097          	auipc	ra,0x0
    80005a4e:	dc0080e7          	jalr	-576(ra) # 8000580a <argfd>
    return -1;
    80005a52:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005a54:	02054363          	bltz	a0,80005a7a <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005a58:	fd843503          	ld	a0,-40(s0)
    80005a5c:	00000097          	auipc	ra,0x0
    80005a60:	e0e080e7          	jalr	-498(ra) # 8000586a <fdalloc>
    80005a64:	84aa                	mv	s1,a0
    return -1;
    80005a66:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005a68:	00054963          	bltz	a0,80005a7a <sys_dup+0x42>
  filedup(f);
    80005a6c:	fd843503          	ld	a0,-40(s0)
    80005a70:	fffff097          	auipc	ra,0xfffff
    80005a74:	320080e7          	jalr	800(ra) # 80004d90 <filedup>
  return fd;
    80005a78:	87a6                	mv	a5,s1
}
    80005a7a:	853e                	mv	a0,a5
    80005a7c:	70a2                	ld	ra,40(sp)
    80005a7e:	7402                	ld	s0,32(sp)
    80005a80:	64e2                	ld	s1,24(sp)
    80005a82:	6145                	addi	sp,sp,48
    80005a84:	8082                	ret

0000000080005a86 <sys_read>:
{
    80005a86:	7179                	addi	sp,sp,-48
    80005a88:	f406                	sd	ra,40(sp)
    80005a8a:	f022                	sd	s0,32(sp)
    80005a8c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005a8e:	fd840593          	addi	a1,s0,-40
    80005a92:	4505                	li	a0,1
    80005a94:	ffffd097          	auipc	ra,0xffffd
    80005a98:	6be080e7          	jalr	1726(ra) # 80003152 <argaddr>
  argint(2, &n);
    80005a9c:	fe440593          	addi	a1,s0,-28
    80005aa0:	4509                	li	a0,2
    80005aa2:	ffffd097          	auipc	ra,0xffffd
    80005aa6:	690080e7          	jalr	1680(ra) # 80003132 <argint>
  if(argfd(0, 0, &f) < 0)
    80005aaa:	fe840613          	addi	a2,s0,-24
    80005aae:	4581                	li	a1,0
    80005ab0:	4501                	li	a0,0
    80005ab2:	00000097          	auipc	ra,0x0
    80005ab6:	d58080e7          	jalr	-680(ra) # 8000580a <argfd>
    80005aba:	87aa                	mv	a5,a0
    return -1;
    80005abc:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005abe:	0007cc63          	bltz	a5,80005ad6 <sys_read+0x50>
  return fileread(f, p, n);
    80005ac2:	fe442603          	lw	a2,-28(s0)
    80005ac6:	fd843583          	ld	a1,-40(s0)
    80005aca:	fe843503          	ld	a0,-24(s0)
    80005ace:	fffff097          	auipc	ra,0xfffff
    80005ad2:	44e080e7          	jalr	1102(ra) # 80004f1c <fileread>
}
    80005ad6:	70a2                	ld	ra,40(sp)
    80005ad8:	7402                	ld	s0,32(sp)
    80005ada:	6145                	addi	sp,sp,48
    80005adc:	8082                	ret

0000000080005ade <sys_write>:
{
    80005ade:	7179                	addi	sp,sp,-48
    80005ae0:	f406                	sd	ra,40(sp)
    80005ae2:	f022                	sd	s0,32(sp)
    80005ae4:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005ae6:	fd840593          	addi	a1,s0,-40
    80005aea:	4505                	li	a0,1
    80005aec:	ffffd097          	auipc	ra,0xffffd
    80005af0:	666080e7          	jalr	1638(ra) # 80003152 <argaddr>
  argint(2, &n);
    80005af4:	fe440593          	addi	a1,s0,-28
    80005af8:	4509                	li	a0,2
    80005afa:	ffffd097          	auipc	ra,0xffffd
    80005afe:	638080e7          	jalr	1592(ra) # 80003132 <argint>
  if(argfd(0, 0, &f) < 0)
    80005b02:	fe840613          	addi	a2,s0,-24
    80005b06:	4581                	li	a1,0
    80005b08:	4501                	li	a0,0
    80005b0a:	00000097          	auipc	ra,0x0
    80005b0e:	d00080e7          	jalr	-768(ra) # 8000580a <argfd>
    80005b12:	87aa                	mv	a5,a0
    return -1;
    80005b14:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005b16:	0007cc63          	bltz	a5,80005b2e <sys_write+0x50>
  return filewrite(f, p, n);
    80005b1a:	fe442603          	lw	a2,-28(s0)
    80005b1e:	fd843583          	ld	a1,-40(s0)
    80005b22:	fe843503          	ld	a0,-24(s0)
    80005b26:	fffff097          	auipc	ra,0xfffff
    80005b2a:	4b8080e7          	jalr	1208(ra) # 80004fde <filewrite>
}
    80005b2e:	70a2                	ld	ra,40(sp)
    80005b30:	7402                	ld	s0,32(sp)
    80005b32:	6145                	addi	sp,sp,48
    80005b34:	8082                	ret

0000000080005b36 <sys_close>:
{
    80005b36:	1101                	addi	sp,sp,-32
    80005b38:	ec06                	sd	ra,24(sp)
    80005b3a:	e822                	sd	s0,16(sp)
    80005b3c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005b3e:	fe040613          	addi	a2,s0,-32
    80005b42:	fec40593          	addi	a1,s0,-20
    80005b46:	4501                	li	a0,0
    80005b48:	00000097          	auipc	ra,0x0
    80005b4c:	cc2080e7          	jalr	-830(ra) # 8000580a <argfd>
    return -1;
    80005b50:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005b52:	02054463          	bltz	a0,80005b7a <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005b56:	ffffc097          	auipc	ra,0xffffc
    80005b5a:	162080e7          	jalr	354(ra) # 80001cb8 <myproc>
    80005b5e:	fec42783          	lw	a5,-20(s0)
    80005b62:	07e9                	addi	a5,a5,26
    80005b64:	078e                	slli	a5,a5,0x3
    80005b66:	97aa                	add	a5,a5,a0
    80005b68:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    80005b6c:	fe043503          	ld	a0,-32(s0)
    80005b70:	fffff097          	auipc	ra,0xfffff
    80005b74:	272080e7          	jalr	626(ra) # 80004de2 <fileclose>
  return 0;
    80005b78:	4781                	li	a5,0
}
    80005b7a:	853e                	mv	a0,a5
    80005b7c:	60e2                	ld	ra,24(sp)
    80005b7e:	6442                	ld	s0,16(sp)
    80005b80:	6105                	addi	sp,sp,32
    80005b82:	8082                	ret

0000000080005b84 <sys_fstat>:
{
    80005b84:	1101                	addi	sp,sp,-32
    80005b86:	ec06                	sd	ra,24(sp)
    80005b88:	e822                	sd	s0,16(sp)
    80005b8a:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005b8c:	fe040593          	addi	a1,s0,-32
    80005b90:	4505                	li	a0,1
    80005b92:	ffffd097          	auipc	ra,0xffffd
    80005b96:	5c0080e7          	jalr	1472(ra) # 80003152 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005b9a:	fe840613          	addi	a2,s0,-24
    80005b9e:	4581                	li	a1,0
    80005ba0:	4501                	li	a0,0
    80005ba2:	00000097          	auipc	ra,0x0
    80005ba6:	c68080e7          	jalr	-920(ra) # 8000580a <argfd>
    80005baa:	87aa                	mv	a5,a0
    return -1;
    80005bac:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005bae:	0007ca63          	bltz	a5,80005bc2 <sys_fstat+0x3e>
  return filestat(f, st);
    80005bb2:	fe043583          	ld	a1,-32(s0)
    80005bb6:	fe843503          	ld	a0,-24(s0)
    80005bba:	fffff097          	auipc	ra,0xfffff
    80005bbe:	2f0080e7          	jalr	752(ra) # 80004eaa <filestat>
}
    80005bc2:	60e2                	ld	ra,24(sp)
    80005bc4:	6442                	ld	s0,16(sp)
    80005bc6:	6105                	addi	sp,sp,32
    80005bc8:	8082                	ret

0000000080005bca <sys_link>:
{
    80005bca:	7169                	addi	sp,sp,-304
    80005bcc:	f606                	sd	ra,296(sp)
    80005bce:	f222                	sd	s0,288(sp)
    80005bd0:	ee26                	sd	s1,280(sp)
    80005bd2:	ea4a                	sd	s2,272(sp)
    80005bd4:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005bd6:	08000613          	li	a2,128
    80005bda:	ed040593          	addi	a1,s0,-304
    80005bde:	4501                	li	a0,0
    80005be0:	ffffd097          	auipc	ra,0xffffd
    80005be4:	592080e7          	jalr	1426(ra) # 80003172 <argstr>
    return -1;
    80005be8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005bea:	10054e63          	bltz	a0,80005d06 <sys_link+0x13c>
    80005bee:	08000613          	li	a2,128
    80005bf2:	f5040593          	addi	a1,s0,-176
    80005bf6:	4505                	li	a0,1
    80005bf8:	ffffd097          	auipc	ra,0xffffd
    80005bfc:	57a080e7          	jalr	1402(ra) # 80003172 <argstr>
    return -1;
    80005c00:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005c02:	10054263          	bltz	a0,80005d06 <sys_link+0x13c>
  begin_op();
    80005c06:	fffff097          	auipc	ra,0xfffff
    80005c0a:	d10080e7          	jalr	-752(ra) # 80004916 <begin_op>
  if((ip = namei(old)) == 0){
    80005c0e:	ed040513          	addi	a0,s0,-304
    80005c12:	fffff097          	auipc	ra,0xfffff
    80005c16:	ae8080e7          	jalr	-1304(ra) # 800046fa <namei>
    80005c1a:	84aa                	mv	s1,a0
    80005c1c:	c551                	beqz	a0,80005ca8 <sys_link+0xde>
  ilock(ip);
    80005c1e:	ffffe097          	auipc	ra,0xffffe
    80005c22:	336080e7          	jalr	822(ra) # 80003f54 <ilock>
  if(ip->type == T_DIR){
    80005c26:	04449703          	lh	a4,68(s1)
    80005c2a:	4785                	li	a5,1
    80005c2c:	08f70463          	beq	a4,a5,80005cb4 <sys_link+0xea>
  ip->nlink++;
    80005c30:	04a4d783          	lhu	a5,74(s1)
    80005c34:	2785                	addiw	a5,a5,1
    80005c36:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005c3a:	8526                	mv	a0,s1
    80005c3c:	ffffe097          	auipc	ra,0xffffe
    80005c40:	24e080e7          	jalr	590(ra) # 80003e8a <iupdate>
  iunlock(ip);
    80005c44:	8526                	mv	a0,s1
    80005c46:	ffffe097          	auipc	ra,0xffffe
    80005c4a:	3d0080e7          	jalr	976(ra) # 80004016 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005c4e:	fd040593          	addi	a1,s0,-48
    80005c52:	f5040513          	addi	a0,s0,-176
    80005c56:	fffff097          	auipc	ra,0xfffff
    80005c5a:	ac2080e7          	jalr	-1342(ra) # 80004718 <nameiparent>
    80005c5e:	892a                	mv	s2,a0
    80005c60:	c935                	beqz	a0,80005cd4 <sys_link+0x10a>
  ilock(dp);
    80005c62:	ffffe097          	auipc	ra,0xffffe
    80005c66:	2f2080e7          	jalr	754(ra) # 80003f54 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005c6a:	00092703          	lw	a4,0(s2)
    80005c6e:	409c                	lw	a5,0(s1)
    80005c70:	04f71d63          	bne	a4,a5,80005cca <sys_link+0x100>
    80005c74:	40d0                	lw	a2,4(s1)
    80005c76:	fd040593          	addi	a1,s0,-48
    80005c7a:	854a                	mv	a0,s2
    80005c7c:	fffff097          	auipc	ra,0xfffff
    80005c80:	9cc080e7          	jalr	-1588(ra) # 80004648 <dirlink>
    80005c84:	04054363          	bltz	a0,80005cca <sys_link+0x100>
  iunlockput(dp);
    80005c88:	854a                	mv	a0,s2
    80005c8a:	ffffe097          	auipc	ra,0xffffe
    80005c8e:	52c080e7          	jalr	1324(ra) # 800041b6 <iunlockput>
  iput(ip);
    80005c92:	8526                	mv	a0,s1
    80005c94:	ffffe097          	auipc	ra,0xffffe
    80005c98:	47a080e7          	jalr	1146(ra) # 8000410e <iput>
  end_op();
    80005c9c:	fffff097          	auipc	ra,0xfffff
    80005ca0:	cfa080e7          	jalr	-774(ra) # 80004996 <end_op>
  return 0;
    80005ca4:	4781                	li	a5,0
    80005ca6:	a085                	j	80005d06 <sys_link+0x13c>
    end_op();
    80005ca8:	fffff097          	auipc	ra,0xfffff
    80005cac:	cee080e7          	jalr	-786(ra) # 80004996 <end_op>
    return -1;
    80005cb0:	57fd                	li	a5,-1
    80005cb2:	a891                	j	80005d06 <sys_link+0x13c>
    iunlockput(ip);
    80005cb4:	8526                	mv	a0,s1
    80005cb6:	ffffe097          	auipc	ra,0xffffe
    80005cba:	500080e7          	jalr	1280(ra) # 800041b6 <iunlockput>
    end_op();
    80005cbe:	fffff097          	auipc	ra,0xfffff
    80005cc2:	cd8080e7          	jalr	-808(ra) # 80004996 <end_op>
    return -1;
    80005cc6:	57fd                	li	a5,-1
    80005cc8:	a83d                	j	80005d06 <sys_link+0x13c>
    iunlockput(dp);
    80005cca:	854a                	mv	a0,s2
    80005ccc:	ffffe097          	auipc	ra,0xffffe
    80005cd0:	4ea080e7          	jalr	1258(ra) # 800041b6 <iunlockput>
  ilock(ip);
    80005cd4:	8526                	mv	a0,s1
    80005cd6:	ffffe097          	auipc	ra,0xffffe
    80005cda:	27e080e7          	jalr	638(ra) # 80003f54 <ilock>
  ip->nlink--;
    80005cde:	04a4d783          	lhu	a5,74(s1)
    80005ce2:	37fd                	addiw	a5,a5,-1
    80005ce4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005ce8:	8526                	mv	a0,s1
    80005cea:	ffffe097          	auipc	ra,0xffffe
    80005cee:	1a0080e7          	jalr	416(ra) # 80003e8a <iupdate>
  iunlockput(ip);
    80005cf2:	8526                	mv	a0,s1
    80005cf4:	ffffe097          	auipc	ra,0xffffe
    80005cf8:	4c2080e7          	jalr	1218(ra) # 800041b6 <iunlockput>
  end_op();
    80005cfc:	fffff097          	auipc	ra,0xfffff
    80005d00:	c9a080e7          	jalr	-870(ra) # 80004996 <end_op>
  return -1;
    80005d04:	57fd                	li	a5,-1
}
    80005d06:	853e                	mv	a0,a5
    80005d08:	70b2                	ld	ra,296(sp)
    80005d0a:	7412                	ld	s0,288(sp)
    80005d0c:	64f2                	ld	s1,280(sp)
    80005d0e:	6952                	ld	s2,272(sp)
    80005d10:	6155                	addi	sp,sp,304
    80005d12:	8082                	ret

0000000080005d14 <sys_unlink>:
{
    80005d14:	7151                	addi	sp,sp,-240
    80005d16:	f586                	sd	ra,232(sp)
    80005d18:	f1a2                	sd	s0,224(sp)
    80005d1a:	eda6                	sd	s1,216(sp)
    80005d1c:	e9ca                	sd	s2,208(sp)
    80005d1e:	e5ce                	sd	s3,200(sp)
    80005d20:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005d22:	08000613          	li	a2,128
    80005d26:	f3040593          	addi	a1,s0,-208
    80005d2a:	4501                	li	a0,0
    80005d2c:	ffffd097          	auipc	ra,0xffffd
    80005d30:	446080e7          	jalr	1094(ra) # 80003172 <argstr>
    80005d34:	18054163          	bltz	a0,80005eb6 <sys_unlink+0x1a2>
  begin_op();
    80005d38:	fffff097          	auipc	ra,0xfffff
    80005d3c:	bde080e7          	jalr	-1058(ra) # 80004916 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005d40:	fb040593          	addi	a1,s0,-80
    80005d44:	f3040513          	addi	a0,s0,-208
    80005d48:	fffff097          	auipc	ra,0xfffff
    80005d4c:	9d0080e7          	jalr	-1584(ra) # 80004718 <nameiparent>
    80005d50:	84aa                	mv	s1,a0
    80005d52:	c979                	beqz	a0,80005e28 <sys_unlink+0x114>
  ilock(dp);
    80005d54:	ffffe097          	auipc	ra,0xffffe
    80005d58:	200080e7          	jalr	512(ra) # 80003f54 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005d5c:	00003597          	auipc	a1,0x3
    80005d60:	b0c58593          	addi	a1,a1,-1268 # 80008868 <syscalls+0x2c0>
    80005d64:	fb040513          	addi	a0,s0,-80
    80005d68:	ffffe097          	auipc	ra,0xffffe
    80005d6c:	6b6080e7          	jalr	1718(ra) # 8000441e <namecmp>
    80005d70:	14050a63          	beqz	a0,80005ec4 <sys_unlink+0x1b0>
    80005d74:	00003597          	auipc	a1,0x3
    80005d78:	afc58593          	addi	a1,a1,-1284 # 80008870 <syscalls+0x2c8>
    80005d7c:	fb040513          	addi	a0,s0,-80
    80005d80:	ffffe097          	auipc	ra,0xffffe
    80005d84:	69e080e7          	jalr	1694(ra) # 8000441e <namecmp>
    80005d88:	12050e63          	beqz	a0,80005ec4 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005d8c:	f2c40613          	addi	a2,s0,-212
    80005d90:	fb040593          	addi	a1,s0,-80
    80005d94:	8526                	mv	a0,s1
    80005d96:	ffffe097          	auipc	ra,0xffffe
    80005d9a:	6a2080e7          	jalr	1698(ra) # 80004438 <dirlookup>
    80005d9e:	892a                	mv	s2,a0
    80005da0:	12050263          	beqz	a0,80005ec4 <sys_unlink+0x1b0>
  ilock(ip);
    80005da4:	ffffe097          	auipc	ra,0xffffe
    80005da8:	1b0080e7          	jalr	432(ra) # 80003f54 <ilock>
  if(ip->nlink < 1)
    80005dac:	04a91783          	lh	a5,74(s2)
    80005db0:	08f05263          	blez	a5,80005e34 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005db4:	04491703          	lh	a4,68(s2)
    80005db8:	4785                	li	a5,1
    80005dba:	08f70563          	beq	a4,a5,80005e44 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005dbe:	4641                	li	a2,16
    80005dc0:	4581                	li	a1,0
    80005dc2:	fc040513          	addi	a0,s0,-64
    80005dc6:	ffffb097          	auipc	ra,0xffffb
    80005dca:	0de080e7          	jalr	222(ra) # 80000ea4 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005dce:	4741                	li	a4,16
    80005dd0:	f2c42683          	lw	a3,-212(s0)
    80005dd4:	fc040613          	addi	a2,s0,-64
    80005dd8:	4581                	li	a1,0
    80005dda:	8526                	mv	a0,s1
    80005ddc:	ffffe097          	auipc	ra,0xffffe
    80005de0:	524080e7          	jalr	1316(ra) # 80004300 <writei>
    80005de4:	47c1                	li	a5,16
    80005de6:	0af51563          	bne	a0,a5,80005e90 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005dea:	04491703          	lh	a4,68(s2)
    80005dee:	4785                	li	a5,1
    80005df0:	0af70863          	beq	a4,a5,80005ea0 <sys_unlink+0x18c>
  iunlockput(dp);
    80005df4:	8526                	mv	a0,s1
    80005df6:	ffffe097          	auipc	ra,0xffffe
    80005dfa:	3c0080e7          	jalr	960(ra) # 800041b6 <iunlockput>
  ip->nlink--;
    80005dfe:	04a95783          	lhu	a5,74(s2)
    80005e02:	37fd                	addiw	a5,a5,-1
    80005e04:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005e08:	854a                	mv	a0,s2
    80005e0a:	ffffe097          	auipc	ra,0xffffe
    80005e0e:	080080e7          	jalr	128(ra) # 80003e8a <iupdate>
  iunlockput(ip);
    80005e12:	854a                	mv	a0,s2
    80005e14:	ffffe097          	auipc	ra,0xffffe
    80005e18:	3a2080e7          	jalr	930(ra) # 800041b6 <iunlockput>
  end_op();
    80005e1c:	fffff097          	auipc	ra,0xfffff
    80005e20:	b7a080e7          	jalr	-1158(ra) # 80004996 <end_op>
  return 0;
    80005e24:	4501                	li	a0,0
    80005e26:	a84d                	j	80005ed8 <sys_unlink+0x1c4>
    end_op();
    80005e28:	fffff097          	auipc	ra,0xfffff
    80005e2c:	b6e080e7          	jalr	-1170(ra) # 80004996 <end_op>
    return -1;
    80005e30:	557d                	li	a0,-1
    80005e32:	a05d                	j	80005ed8 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005e34:	00003517          	auipc	a0,0x3
    80005e38:	a4450513          	addi	a0,a0,-1468 # 80008878 <syscalls+0x2d0>
    80005e3c:	ffffa097          	auipc	ra,0xffffa
    80005e40:	708080e7          	jalr	1800(ra) # 80000544 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005e44:	04c92703          	lw	a4,76(s2)
    80005e48:	02000793          	li	a5,32
    80005e4c:	f6e7f9e3          	bgeu	a5,a4,80005dbe <sys_unlink+0xaa>
    80005e50:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005e54:	4741                	li	a4,16
    80005e56:	86ce                	mv	a3,s3
    80005e58:	f1840613          	addi	a2,s0,-232
    80005e5c:	4581                	li	a1,0
    80005e5e:	854a                	mv	a0,s2
    80005e60:	ffffe097          	auipc	ra,0xffffe
    80005e64:	3a8080e7          	jalr	936(ra) # 80004208 <readi>
    80005e68:	47c1                	li	a5,16
    80005e6a:	00f51b63          	bne	a0,a5,80005e80 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005e6e:	f1845783          	lhu	a5,-232(s0)
    80005e72:	e7a1                	bnez	a5,80005eba <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005e74:	29c1                	addiw	s3,s3,16
    80005e76:	04c92783          	lw	a5,76(s2)
    80005e7a:	fcf9ede3          	bltu	s3,a5,80005e54 <sys_unlink+0x140>
    80005e7e:	b781                	j	80005dbe <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005e80:	00003517          	auipc	a0,0x3
    80005e84:	a1050513          	addi	a0,a0,-1520 # 80008890 <syscalls+0x2e8>
    80005e88:	ffffa097          	auipc	ra,0xffffa
    80005e8c:	6bc080e7          	jalr	1724(ra) # 80000544 <panic>
    panic("unlink: writei");
    80005e90:	00003517          	auipc	a0,0x3
    80005e94:	a1850513          	addi	a0,a0,-1512 # 800088a8 <syscalls+0x300>
    80005e98:	ffffa097          	auipc	ra,0xffffa
    80005e9c:	6ac080e7          	jalr	1708(ra) # 80000544 <panic>
    dp->nlink--;
    80005ea0:	04a4d783          	lhu	a5,74(s1)
    80005ea4:	37fd                	addiw	a5,a5,-1
    80005ea6:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005eaa:	8526                	mv	a0,s1
    80005eac:	ffffe097          	auipc	ra,0xffffe
    80005eb0:	fde080e7          	jalr	-34(ra) # 80003e8a <iupdate>
    80005eb4:	b781                	j	80005df4 <sys_unlink+0xe0>
    return -1;
    80005eb6:	557d                	li	a0,-1
    80005eb8:	a005                	j	80005ed8 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005eba:	854a                	mv	a0,s2
    80005ebc:	ffffe097          	auipc	ra,0xffffe
    80005ec0:	2fa080e7          	jalr	762(ra) # 800041b6 <iunlockput>
  iunlockput(dp);
    80005ec4:	8526                	mv	a0,s1
    80005ec6:	ffffe097          	auipc	ra,0xffffe
    80005eca:	2f0080e7          	jalr	752(ra) # 800041b6 <iunlockput>
  end_op();
    80005ece:	fffff097          	auipc	ra,0xfffff
    80005ed2:	ac8080e7          	jalr	-1336(ra) # 80004996 <end_op>
  return -1;
    80005ed6:	557d                	li	a0,-1
}
    80005ed8:	70ae                	ld	ra,232(sp)
    80005eda:	740e                	ld	s0,224(sp)
    80005edc:	64ee                	ld	s1,216(sp)
    80005ede:	694e                	ld	s2,208(sp)
    80005ee0:	69ae                	ld	s3,200(sp)
    80005ee2:	616d                	addi	sp,sp,240
    80005ee4:	8082                	ret

0000000080005ee6 <sys_open>:

uint64
sys_open(void)
{
    80005ee6:	7131                	addi	sp,sp,-192
    80005ee8:	fd06                	sd	ra,184(sp)
    80005eea:	f922                	sd	s0,176(sp)
    80005eec:	f526                	sd	s1,168(sp)
    80005eee:	f14a                	sd	s2,160(sp)
    80005ef0:	ed4e                	sd	s3,152(sp)
    80005ef2:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005ef4:	f4c40593          	addi	a1,s0,-180
    80005ef8:	4505                	li	a0,1
    80005efa:	ffffd097          	auipc	ra,0xffffd
    80005efe:	238080e7          	jalr	568(ra) # 80003132 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005f02:	08000613          	li	a2,128
    80005f06:	f5040593          	addi	a1,s0,-176
    80005f0a:	4501                	li	a0,0
    80005f0c:	ffffd097          	auipc	ra,0xffffd
    80005f10:	266080e7          	jalr	614(ra) # 80003172 <argstr>
    80005f14:	87aa                	mv	a5,a0
    return -1;
    80005f16:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005f18:	0a07c963          	bltz	a5,80005fca <sys_open+0xe4>

  begin_op();
    80005f1c:	fffff097          	auipc	ra,0xfffff
    80005f20:	9fa080e7          	jalr	-1542(ra) # 80004916 <begin_op>

  if(omode & O_CREATE){
    80005f24:	f4c42783          	lw	a5,-180(s0)
    80005f28:	2007f793          	andi	a5,a5,512
    80005f2c:	cfc5                	beqz	a5,80005fe4 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005f2e:	4681                	li	a3,0
    80005f30:	4601                	li	a2,0
    80005f32:	4589                	li	a1,2
    80005f34:	f5040513          	addi	a0,s0,-176
    80005f38:	00000097          	auipc	ra,0x0
    80005f3c:	974080e7          	jalr	-1676(ra) # 800058ac <create>
    80005f40:	84aa                	mv	s1,a0
    if(ip == 0){
    80005f42:	c959                	beqz	a0,80005fd8 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005f44:	04449703          	lh	a4,68(s1)
    80005f48:	478d                	li	a5,3
    80005f4a:	00f71763          	bne	a4,a5,80005f58 <sys_open+0x72>
    80005f4e:	0464d703          	lhu	a4,70(s1)
    80005f52:	47a5                	li	a5,9
    80005f54:	0ce7ed63          	bltu	a5,a4,8000602e <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005f58:	fffff097          	auipc	ra,0xfffff
    80005f5c:	dce080e7          	jalr	-562(ra) # 80004d26 <filealloc>
    80005f60:	89aa                	mv	s3,a0
    80005f62:	10050363          	beqz	a0,80006068 <sys_open+0x182>
    80005f66:	00000097          	auipc	ra,0x0
    80005f6a:	904080e7          	jalr	-1788(ra) # 8000586a <fdalloc>
    80005f6e:	892a                	mv	s2,a0
    80005f70:	0e054763          	bltz	a0,8000605e <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005f74:	04449703          	lh	a4,68(s1)
    80005f78:	478d                	li	a5,3
    80005f7a:	0cf70563          	beq	a4,a5,80006044 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005f7e:	4789                	li	a5,2
    80005f80:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005f84:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005f88:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005f8c:	f4c42783          	lw	a5,-180(s0)
    80005f90:	0017c713          	xori	a4,a5,1
    80005f94:	8b05                	andi	a4,a4,1
    80005f96:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005f9a:	0037f713          	andi	a4,a5,3
    80005f9e:	00e03733          	snez	a4,a4
    80005fa2:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005fa6:	4007f793          	andi	a5,a5,1024
    80005faa:	c791                	beqz	a5,80005fb6 <sys_open+0xd0>
    80005fac:	04449703          	lh	a4,68(s1)
    80005fb0:	4789                	li	a5,2
    80005fb2:	0af70063          	beq	a4,a5,80006052 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005fb6:	8526                	mv	a0,s1
    80005fb8:	ffffe097          	auipc	ra,0xffffe
    80005fbc:	05e080e7          	jalr	94(ra) # 80004016 <iunlock>
  end_op();
    80005fc0:	fffff097          	auipc	ra,0xfffff
    80005fc4:	9d6080e7          	jalr	-1578(ra) # 80004996 <end_op>

  return fd;
    80005fc8:	854a                	mv	a0,s2
}
    80005fca:	70ea                	ld	ra,184(sp)
    80005fcc:	744a                	ld	s0,176(sp)
    80005fce:	74aa                	ld	s1,168(sp)
    80005fd0:	790a                	ld	s2,160(sp)
    80005fd2:	69ea                	ld	s3,152(sp)
    80005fd4:	6129                	addi	sp,sp,192
    80005fd6:	8082                	ret
      end_op();
    80005fd8:	fffff097          	auipc	ra,0xfffff
    80005fdc:	9be080e7          	jalr	-1602(ra) # 80004996 <end_op>
      return -1;
    80005fe0:	557d                	li	a0,-1
    80005fe2:	b7e5                	j	80005fca <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005fe4:	f5040513          	addi	a0,s0,-176
    80005fe8:	ffffe097          	auipc	ra,0xffffe
    80005fec:	712080e7          	jalr	1810(ra) # 800046fa <namei>
    80005ff0:	84aa                	mv	s1,a0
    80005ff2:	c905                	beqz	a0,80006022 <sys_open+0x13c>
    ilock(ip);
    80005ff4:	ffffe097          	auipc	ra,0xffffe
    80005ff8:	f60080e7          	jalr	-160(ra) # 80003f54 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005ffc:	04449703          	lh	a4,68(s1)
    80006000:	4785                	li	a5,1
    80006002:	f4f711e3          	bne	a4,a5,80005f44 <sys_open+0x5e>
    80006006:	f4c42783          	lw	a5,-180(s0)
    8000600a:	d7b9                	beqz	a5,80005f58 <sys_open+0x72>
      iunlockput(ip);
    8000600c:	8526                	mv	a0,s1
    8000600e:	ffffe097          	auipc	ra,0xffffe
    80006012:	1a8080e7          	jalr	424(ra) # 800041b6 <iunlockput>
      end_op();
    80006016:	fffff097          	auipc	ra,0xfffff
    8000601a:	980080e7          	jalr	-1664(ra) # 80004996 <end_op>
      return -1;
    8000601e:	557d                	li	a0,-1
    80006020:	b76d                	j	80005fca <sys_open+0xe4>
      end_op();
    80006022:	fffff097          	auipc	ra,0xfffff
    80006026:	974080e7          	jalr	-1676(ra) # 80004996 <end_op>
      return -1;
    8000602a:	557d                	li	a0,-1
    8000602c:	bf79                	j	80005fca <sys_open+0xe4>
    iunlockput(ip);
    8000602e:	8526                	mv	a0,s1
    80006030:	ffffe097          	auipc	ra,0xffffe
    80006034:	186080e7          	jalr	390(ra) # 800041b6 <iunlockput>
    end_op();
    80006038:	fffff097          	auipc	ra,0xfffff
    8000603c:	95e080e7          	jalr	-1698(ra) # 80004996 <end_op>
    return -1;
    80006040:	557d                	li	a0,-1
    80006042:	b761                	j	80005fca <sys_open+0xe4>
    f->type = FD_DEVICE;
    80006044:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80006048:	04649783          	lh	a5,70(s1)
    8000604c:	02f99223          	sh	a5,36(s3)
    80006050:	bf25                	j	80005f88 <sys_open+0xa2>
    itrunc(ip);
    80006052:	8526                	mv	a0,s1
    80006054:	ffffe097          	auipc	ra,0xffffe
    80006058:	00e080e7          	jalr	14(ra) # 80004062 <itrunc>
    8000605c:	bfa9                	j	80005fb6 <sys_open+0xd0>
      fileclose(f);
    8000605e:	854e                	mv	a0,s3
    80006060:	fffff097          	auipc	ra,0xfffff
    80006064:	d82080e7          	jalr	-638(ra) # 80004de2 <fileclose>
    iunlockput(ip);
    80006068:	8526                	mv	a0,s1
    8000606a:	ffffe097          	auipc	ra,0xffffe
    8000606e:	14c080e7          	jalr	332(ra) # 800041b6 <iunlockput>
    end_op();
    80006072:	fffff097          	auipc	ra,0xfffff
    80006076:	924080e7          	jalr	-1756(ra) # 80004996 <end_op>
    return -1;
    8000607a:	557d                	li	a0,-1
    8000607c:	b7b9                	j	80005fca <sys_open+0xe4>

000000008000607e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000607e:	7175                	addi	sp,sp,-144
    80006080:	e506                	sd	ra,136(sp)
    80006082:	e122                	sd	s0,128(sp)
    80006084:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80006086:	fffff097          	auipc	ra,0xfffff
    8000608a:	890080e7          	jalr	-1904(ra) # 80004916 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000608e:	08000613          	li	a2,128
    80006092:	f7040593          	addi	a1,s0,-144
    80006096:	4501                	li	a0,0
    80006098:	ffffd097          	auipc	ra,0xffffd
    8000609c:	0da080e7          	jalr	218(ra) # 80003172 <argstr>
    800060a0:	02054963          	bltz	a0,800060d2 <sys_mkdir+0x54>
    800060a4:	4681                	li	a3,0
    800060a6:	4601                	li	a2,0
    800060a8:	4585                	li	a1,1
    800060aa:	f7040513          	addi	a0,s0,-144
    800060ae:	fffff097          	auipc	ra,0xfffff
    800060b2:	7fe080e7          	jalr	2046(ra) # 800058ac <create>
    800060b6:	cd11                	beqz	a0,800060d2 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800060b8:	ffffe097          	auipc	ra,0xffffe
    800060bc:	0fe080e7          	jalr	254(ra) # 800041b6 <iunlockput>
  end_op();
    800060c0:	fffff097          	auipc	ra,0xfffff
    800060c4:	8d6080e7          	jalr	-1834(ra) # 80004996 <end_op>
  return 0;
    800060c8:	4501                	li	a0,0
}
    800060ca:	60aa                	ld	ra,136(sp)
    800060cc:	640a                	ld	s0,128(sp)
    800060ce:	6149                	addi	sp,sp,144
    800060d0:	8082                	ret
    end_op();
    800060d2:	fffff097          	auipc	ra,0xfffff
    800060d6:	8c4080e7          	jalr	-1852(ra) # 80004996 <end_op>
    return -1;
    800060da:	557d                	li	a0,-1
    800060dc:	b7fd                	j	800060ca <sys_mkdir+0x4c>

00000000800060de <sys_mknod>:

uint64
sys_mknod(void)
{
    800060de:	7135                	addi	sp,sp,-160
    800060e0:	ed06                	sd	ra,152(sp)
    800060e2:	e922                	sd	s0,144(sp)
    800060e4:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800060e6:	fffff097          	auipc	ra,0xfffff
    800060ea:	830080e7          	jalr	-2000(ra) # 80004916 <begin_op>
  argint(1, &major);
    800060ee:	f6c40593          	addi	a1,s0,-148
    800060f2:	4505                	li	a0,1
    800060f4:	ffffd097          	auipc	ra,0xffffd
    800060f8:	03e080e7          	jalr	62(ra) # 80003132 <argint>
  argint(2, &minor);
    800060fc:	f6840593          	addi	a1,s0,-152
    80006100:	4509                	li	a0,2
    80006102:	ffffd097          	auipc	ra,0xffffd
    80006106:	030080e7          	jalr	48(ra) # 80003132 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000610a:	08000613          	li	a2,128
    8000610e:	f7040593          	addi	a1,s0,-144
    80006112:	4501                	li	a0,0
    80006114:	ffffd097          	auipc	ra,0xffffd
    80006118:	05e080e7          	jalr	94(ra) # 80003172 <argstr>
    8000611c:	02054b63          	bltz	a0,80006152 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80006120:	f6841683          	lh	a3,-152(s0)
    80006124:	f6c41603          	lh	a2,-148(s0)
    80006128:	458d                	li	a1,3
    8000612a:	f7040513          	addi	a0,s0,-144
    8000612e:	fffff097          	auipc	ra,0xfffff
    80006132:	77e080e7          	jalr	1918(ra) # 800058ac <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006136:	cd11                	beqz	a0,80006152 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006138:	ffffe097          	auipc	ra,0xffffe
    8000613c:	07e080e7          	jalr	126(ra) # 800041b6 <iunlockput>
  end_op();
    80006140:	fffff097          	auipc	ra,0xfffff
    80006144:	856080e7          	jalr	-1962(ra) # 80004996 <end_op>
  return 0;
    80006148:	4501                	li	a0,0
}
    8000614a:	60ea                	ld	ra,152(sp)
    8000614c:	644a                	ld	s0,144(sp)
    8000614e:	610d                	addi	sp,sp,160
    80006150:	8082                	ret
    end_op();
    80006152:	fffff097          	auipc	ra,0xfffff
    80006156:	844080e7          	jalr	-1980(ra) # 80004996 <end_op>
    return -1;
    8000615a:	557d                	li	a0,-1
    8000615c:	b7fd                	j	8000614a <sys_mknod+0x6c>

000000008000615e <sys_chdir>:

uint64
sys_chdir(void)
{
    8000615e:	7135                	addi	sp,sp,-160
    80006160:	ed06                	sd	ra,152(sp)
    80006162:	e922                	sd	s0,144(sp)
    80006164:	e526                	sd	s1,136(sp)
    80006166:	e14a                	sd	s2,128(sp)
    80006168:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000616a:	ffffc097          	auipc	ra,0xffffc
    8000616e:	b4e080e7          	jalr	-1202(ra) # 80001cb8 <myproc>
    80006172:	892a                	mv	s2,a0
  
  begin_op();
    80006174:	ffffe097          	auipc	ra,0xffffe
    80006178:	7a2080e7          	jalr	1954(ra) # 80004916 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000617c:	08000613          	li	a2,128
    80006180:	f6040593          	addi	a1,s0,-160
    80006184:	4501                	li	a0,0
    80006186:	ffffd097          	auipc	ra,0xffffd
    8000618a:	fec080e7          	jalr	-20(ra) # 80003172 <argstr>
    8000618e:	04054b63          	bltz	a0,800061e4 <sys_chdir+0x86>
    80006192:	f6040513          	addi	a0,s0,-160
    80006196:	ffffe097          	auipc	ra,0xffffe
    8000619a:	564080e7          	jalr	1380(ra) # 800046fa <namei>
    8000619e:	84aa                	mv	s1,a0
    800061a0:	c131                	beqz	a0,800061e4 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800061a2:	ffffe097          	auipc	ra,0xffffe
    800061a6:	db2080e7          	jalr	-590(ra) # 80003f54 <ilock>
  if(ip->type != T_DIR){
    800061aa:	04449703          	lh	a4,68(s1)
    800061ae:	4785                	li	a5,1
    800061b0:	04f71063          	bne	a4,a5,800061f0 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800061b4:	8526                	mv	a0,s1
    800061b6:	ffffe097          	auipc	ra,0xffffe
    800061ba:	e60080e7          	jalr	-416(ra) # 80004016 <iunlock>
  iput(p->cwd);
    800061be:	15893503          	ld	a0,344(s2)
    800061c2:	ffffe097          	auipc	ra,0xffffe
    800061c6:	f4c080e7          	jalr	-180(ra) # 8000410e <iput>
  end_op();
    800061ca:	ffffe097          	auipc	ra,0xffffe
    800061ce:	7cc080e7          	jalr	1996(ra) # 80004996 <end_op>
  p->cwd = ip;
    800061d2:	14993c23          	sd	s1,344(s2)
  return 0;
    800061d6:	4501                	li	a0,0
}
    800061d8:	60ea                	ld	ra,152(sp)
    800061da:	644a                	ld	s0,144(sp)
    800061dc:	64aa                	ld	s1,136(sp)
    800061de:	690a                	ld	s2,128(sp)
    800061e0:	610d                	addi	sp,sp,160
    800061e2:	8082                	ret
    end_op();
    800061e4:	ffffe097          	auipc	ra,0xffffe
    800061e8:	7b2080e7          	jalr	1970(ra) # 80004996 <end_op>
    return -1;
    800061ec:	557d                	li	a0,-1
    800061ee:	b7ed                	j	800061d8 <sys_chdir+0x7a>
    iunlockput(ip);
    800061f0:	8526                	mv	a0,s1
    800061f2:	ffffe097          	auipc	ra,0xffffe
    800061f6:	fc4080e7          	jalr	-60(ra) # 800041b6 <iunlockput>
    end_op();
    800061fa:	ffffe097          	auipc	ra,0xffffe
    800061fe:	79c080e7          	jalr	1948(ra) # 80004996 <end_op>
    return -1;
    80006202:	557d                	li	a0,-1
    80006204:	bfd1                	j	800061d8 <sys_chdir+0x7a>

0000000080006206 <sys_exec>:

uint64
sys_exec(void)
{
    80006206:	7145                	addi	sp,sp,-464
    80006208:	e786                	sd	ra,456(sp)
    8000620a:	e3a2                	sd	s0,448(sp)
    8000620c:	ff26                	sd	s1,440(sp)
    8000620e:	fb4a                	sd	s2,432(sp)
    80006210:	f74e                	sd	s3,424(sp)
    80006212:	f352                	sd	s4,416(sp)
    80006214:	ef56                	sd	s5,408(sp)
    80006216:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80006218:	e3840593          	addi	a1,s0,-456
    8000621c:	4505                	li	a0,1
    8000621e:	ffffd097          	auipc	ra,0xffffd
    80006222:	f34080e7          	jalr	-204(ra) # 80003152 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80006226:	08000613          	li	a2,128
    8000622a:	f4040593          	addi	a1,s0,-192
    8000622e:	4501                	li	a0,0
    80006230:	ffffd097          	auipc	ra,0xffffd
    80006234:	f42080e7          	jalr	-190(ra) # 80003172 <argstr>
    80006238:	87aa                	mv	a5,a0
    return -1;
    8000623a:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000623c:	0c07c263          	bltz	a5,80006300 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80006240:	10000613          	li	a2,256
    80006244:	4581                	li	a1,0
    80006246:	e4040513          	addi	a0,s0,-448
    8000624a:	ffffb097          	auipc	ra,0xffffb
    8000624e:	c5a080e7          	jalr	-934(ra) # 80000ea4 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006252:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80006256:	89a6                	mv	s3,s1
    80006258:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000625a:	02000a13          	li	s4,32
    8000625e:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006262:	00391513          	slli	a0,s2,0x3
    80006266:	e3040593          	addi	a1,s0,-464
    8000626a:	e3843783          	ld	a5,-456(s0)
    8000626e:	953e                	add	a0,a0,a5
    80006270:	ffffd097          	auipc	ra,0xffffd
    80006274:	e24080e7          	jalr	-476(ra) # 80003094 <fetchaddr>
    80006278:	02054a63          	bltz	a0,800062ac <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    8000627c:	e3043783          	ld	a5,-464(s0)
    80006280:	c3b9                	beqz	a5,800062c6 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006282:	ffffb097          	auipc	ra,0xffffb
    80006286:	9f2080e7          	jalr	-1550(ra) # 80000c74 <kalloc>
    8000628a:	85aa                	mv	a1,a0
    8000628c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006290:	cd11                	beqz	a0,800062ac <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006292:	6605                	lui	a2,0x1
    80006294:	e3043503          	ld	a0,-464(s0)
    80006298:	ffffd097          	auipc	ra,0xffffd
    8000629c:	e4e080e7          	jalr	-434(ra) # 800030e6 <fetchstr>
    800062a0:	00054663          	bltz	a0,800062ac <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    800062a4:	0905                	addi	s2,s2,1
    800062a6:	09a1                	addi	s3,s3,8
    800062a8:	fb491be3          	bne	s2,s4,8000625e <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800062ac:	10048913          	addi	s2,s1,256
    800062b0:	6088                	ld	a0,0(s1)
    800062b2:	c531                	beqz	a0,800062fe <sys_exec+0xf8>
    kfree(argv[i]);
    800062b4:	ffffb097          	auipc	ra,0xffffb
    800062b8:	81a080e7          	jalr	-2022(ra) # 80000ace <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800062bc:	04a1                	addi	s1,s1,8
    800062be:	ff2499e3          	bne	s1,s2,800062b0 <sys_exec+0xaa>
  return -1;
    800062c2:	557d                	li	a0,-1
    800062c4:	a835                	j	80006300 <sys_exec+0xfa>
      argv[i] = 0;
    800062c6:	0a8e                	slli	s5,s5,0x3
    800062c8:	fc040793          	addi	a5,s0,-64
    800062cc:	9abe                	add	s5,s5,a5
    800062ce:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    800062d2:	e4040593          	addi	a1,s0,-448
    800062d6:	f4040513          	addi	a0,s0,-192
    800062da:	fffff097          	auipc	ra,0xfffff
    800062de:	190080e7          	jalr	400(ra) # 8000546a <exec>
    800062e2:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800062e4:	10048993          	addi	s3,s1,256
    800062e8:	6088                	ld	a0,0(s1)
    800062ea:	c901                	beqz	a0,800062fa <sys_exec+0xf4>
    kfree(argv[i]);
    800062ec:	ffffa097          	auipc	ra,0xffffa
    800062f0:	7e2080e7          	jalr	2018(ra) # 80000ace <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800062f4:	04a1                	addi	s1,s1,8
    800062f6:	ff3499e3          	bne	s1,s3,800062e8 <sys_exec+0xe2>
  return ret;
    800062fa:	854a                	mv	a0,s2
    800062fc:	a011                	j	80006300 <sys_exec+0xfa>
  return -1;
    800062fe:	557d                	li	a0,-1
}
    80006300:	60be                	ld	ra,456(sp)
    80006302:	641e                	ld	s0,448(sp)
    80006304:	74fa                	ld	s1,440(sp)
    80006306:	795a                	ld	s2,432(sp)
    80006308:	79ba                	ld	s3,424(sp)
    8000630a:	7a1a                	ld	s4,416(sp)
    8000630c:	6afa                	ld	s5,408(sp)
    8000630e:	6179                	addi	sp,sp,464
    80006310:	8082                	ret

0000000080006312 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006312:	7139                	addi	sp,sp,-64
    80006314:	fc06                	sd	ra,56(sp)
    80006316:	f822                	sd	s0,48(sp)
    80006318:	f426                	sd	s1,40(sp)
    8000631a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000631c:	ffffc097          	auipc	ra,0xffffc
    80006320:	99c080e7          	jalr	-1636(ra) # 80001cb8 <myproc>
    80006324:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80006326:	fd840593          	addi	a1,s0,-40
    8000632a:	4501                	li	a0,0
    8000632c:	ffffd097          	auipc	ra,0xffffd
    80006330:	e26080e7          	jalr	-474(ra) # 80003152 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80006334:	fc840593          	addi	a1,s0,-56
    80006338:	fd040513          	addi	a0,s0,-48
    8000633c:	fffff097          	auipc	ra,0xfffff
    80006340:	dd6080e7          	jalr	-554(ra) # 80005112 <pipealloc>
    return -1;
    80006344:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006346:	0c054463          	bltz	a0,8000640e <sys_pipe+0xfc>
  fd0 = -1;
    8000634a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000634e:	fd043503          	ld	a0,-48(s0)
    80006352:	fffff097          	auipc	ra,0xfffff
    80006356:	518080e7          	jalr	1304(ra) # 8000586a <fdalloc>
    8000635a:	fca42223          	sw	a0,-60(s0)
    8000635e:	08054b63          	bltz	a0,800063f4 <sys_pipe+0xe2>
    80006362:	fc843503          	ld	a0,-56(s0)
    80006366:	fffff097          	auipc	ra,0xfffff
    8000636a:	504080e7          	jalr	1284(ra) # 8000586a <fdalloc>
    8000636e:	fca42023          	sw	a0,-64(s0)
    80006372:	06054863          	bltz	a0,800063e2 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006376:	4691                	li	a3,4
    80006378:	fc440613          	addi	a2,s0,-60
    8000637c:	fd843583          	ld	a1,-40(s0)
    80006380:	6ca8                	ld	a0,88(s1)
    80006382:	ffffb097          	auipc	ra,0xffffb
    80006386:	4b6080e7          	jalr	1206(ra) # 80001838 <copyout>
    8000638a:	02054063          	bltz	a0,800063aa <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000638e:	4691                	li	a3,4
    80006390:	fc040613          	addi	a2,s0,-64
    80006394:	fd843583          	ld	a1,-40(s0)
    80006398:	0591                	addi	a1,a1,4
    8000639a:	6ca8                	ld	a0,88(s1)
    8000639c:	ffffb097          	auipc	ra,0xffffb
    800063a0:	49c080e7          	jalr	1180(ra) # 80001838 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800063a4:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800063a6:	06055463          	bgez	a0,8000640e <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    800063aa:	fc442783          	lw	a5,-60(s0)
    800063ae:	07e9                	addi	a5,a5,26
    800063b0:	078e                	slli	a5,a5,0x3
    800063b2:	97a6                	add	a5,a5,s1
    800063b4:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    800063b8:	fc042503          	lw	a0,-64(s0)
    800063bc:	0569                	addi	a0,a0,26
    800063be:	050e                	slli	a0,a0,0x3
    800063c0:	94aa                	add	s1,s1,a0
    800063c2:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    800063c6:	fd043503          	ld	a0,-48(s0)
    800063ca:	fffff097          	auipc	ra,0xfffff
    800063ce:	a18080e7          	jalr	-1512(ra) # 80004de2 <fileclose>
    fileclose(wf);
    800063d2:	fc843503          	ld	a0,-56(s0)
    800063d6:	fffff097          	auipc	ra,0xfffff
    800063da:	a0c080e7          	jalr	-1524(ra) # 80004de2 <fileclose>
    return -1;
    800063de:	57fd                	li	a5,-1
    800063e0:	a03d                	j	8000640e <sys_pipe+0xfc>
    if(fd0 >= 0)
    800063e2:	fc442783          	lw	a5,-60(s0)
    800063e6:	0007c763          	bltz	a5,800063f4 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    800063ea:	07e9                	addi	a5,a5,26
    800063ec:	078e                	slli	a5,a5,0x3
    800063ee:	94be                	add	s1,s1,a5
    800063f0:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    800063f4:	fd043503          	ld	a0,-48(s0)
    800063f8:	fffff097          	auipc	ra,0xfffff
    800063fc:	9ea080e7          	jalr	-1558(ra) # 80004de2 <fileclose>
    fileclose(wf);
    80006400:	fc843503          	ld	a0,-56(s0)
    80006404:	fffff097          	auipc	ra,0xfffff
    80006408:	9de080e7          	jalr	-1570(ra) # 80004de2 <fileclose>
    return -1;
    8000640c:	57fd                	li	a5,-1
}
    8000640e:	853e                	mv	a0,a5
    80006410:	70e2                	ld	ra,56(sp)
    80006412:	7442                	ld	s0,48(sp)
    80006414:	74a2                	ld	s1,40(sp)
    80006416:	6121                	addi	sp,sp,64
    80006418:	8082                	ret
    8000641a:	0000                	unimp
    8000641c:	0000                	unimp
	...

0000000080006420 <kernelvec>:
    80006420:	7111                	addi	sp,sp,-256
    80006422:	e006                	sd	ra,0(sp)
    80006424:	e40a                	sd	sp,8(sp)
    80006426:	e80e                	sd	gp,16(sp)
    80006428:	ec12                	sd	tp,24(sp)
    8000642a:	f016                	sd	t0,32(sp)
    8000642c:	f41a                	sd	t1,40(sp)
    8000642e:	f81e                	sd	t2,48(sp)
    80006430:	fc22                	sd	s0,56(sp)
    80006432:	e0a6                	sd	s1,64(sp)
    80006434:	e4aa                	sd	a0,72(sp)
    80006436:	e8ae                	sd	a1,80(sp)
    80006438:	ecb2                	sd	a2,88(sp)
    8000643a:	f0b6                	sd	a3,96(sp)
    8000643c:	f4ba                	sd	a4,104(sp)
    8000643e:	f8be                	sd	a5,112(sp)
    80006440:	fcc2                	sd	a6,120(sp)
    80006442:	e146                	sd	a7,128(sp)
    80006444:	e54a                	sd	s2,136(sp)
    80006446:	e94e                	sd	s3,144(sp)
    80006448:	ed52                	sd	s4,152(sp)
    8000644a:	f156                	sd	s5,160(sp)
    8000644c:	f55a                	sd	s6,168(sp)
    8000644e:	f95e                	sd	s7,176(sp)
    80006450:	fd62                	sd	s8,184(sp)
    80006452:	e1e6                	sd	s9,192(sp)
    80006454:	e5ea                	sd	s10,200(sp)
    80006456:	e9ee                	sd	s11,208(sp)
    80006458:	edf2                	sd	t3,216(sp)
    8000645a:	f1f6                	sd	t4,224(sp)
    8000645c:	f5fa                	sd	t5,232(sp)
    8000645e:	f9fe                	sd	t6,240(sp)
    80006460:	b01fc0ef          	jal	ra,80002f60 <kerneltrap>
    80006464:	6082                	ld	ra,0(sp)
    80006466:	6122                	ld	sp,8(sp)
    80006468:	61c2                	ld	gp,16(sp)
    8000646a:	7282                	ld	t0,32(sp)
    8000646c:	7322                	ld	t1,40(sp)
    8000646e:	73c2                	ld	t2,48(sp)
    80006470:	7462                	ld	s0,56(sp)
    80006472:	6486                	ld	s1,64(sp)
    80006474:	6526                	ld	a0,72(sp)
    80006476:	65c6                	ld	a1,80(sp)
    80006478:	6666                	ld	a2,88(sp)
    8000647a:	7686                	ld	a3,96(sp)
    8000647c:	7726                	ld	a4,104(sp)
    8000647e:	77c6                	ld	a5,112(sp)
    80006480:	7866                	ld	a6,120(sp)
    80006482:	688a                	ld	a7,128(sp)
    80006484:	692a                	ld	s2,136(sp)
    80006486:	69ca                	ld	s3,144(sp)
    80006488:	6a6a                	ld	s4,152(sp)
    8000648a:	7a8a                	ld	s5,160(sp)
    8000648c:	7b2a                	ld	s6,168(sp)
    8000648e:	7bca                	ld	s7,176(sp)
    80006490:	7c6a                	ld	s8,184(sp)
    80006492:	6c8e                	ld	s9,192(sp)
    80006494:	6d2e                	ld	s10,200(sp)
    80006496:	6dce                	ld	s11,208(sp)
    80006498:	6e6e                	ld	t3,216(sp)
    8000649a:	7e8e                	ld	t4,224(sp)
    8000649c:	7f2e                	ld	t5,232(sp)
    8000649e:	7fce                	ld	t6,240(sp)
    800064a0:	6111                	addi	sp,sp,256
    800064a2:	10200073          	sret
    800064a6:	00000013          	nop
    800064aa:	00000013          	nop
    800064ae:	0001                	nop

00000000800064b0 <timervec>:
    800064b0:	34051573          	csrrw	a0,mscratch,a0
    800064b4:	e10c                	sd	a1,0(a0)
    800064b6:	e510                	sd	a2,8(a0)
    800064b8:	e914                	sd	a3,16(a0)
    800064ba:	6d0c                	ld	a1,24(a0)
    800064bc:	7110                	ld	a2,32(a0)
    800064be:	6194                	ld	a3,0(a1)
    800064c0:	96b2                	add	a3,a3,a2
    800064c2:	e194                	sd	a3,0(a1)
    800064c4:	4589                	li	a1,2
    800064c6:	14459073          	csrw	sip,a1
    800064ca:	6914                	ld	a3,16(a0)
    800064cc:	6510                	ld	a2,8(a0)
    800064ce:	610c                	ld	a1,0(a0)
    800064d0:	34051573          	csrrw	a0,mscratch,a0
    800064d4:	30200073          	mret
	...

00000000800064da <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800064da:	1141                	addi	sp,sp,-16
    800064dc:	e422                	sd	s0,8(sp)
    800064de:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800064e0:	0c0007b7          	lui	a5,0xc000
    800064e4:	4705                	li	a4,1
    800064e6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800064e8:	c3d8                	sw	a4,4(a5)
}
    800064ea:	6422                	ld	s0,8(sp)
    800064ec:	0141                	addi	sp,sp,16
    800064ee:	8082                	ret

00000000800064f0 <plicinithart>:

void
plicinithart(void)
{
    800064f0:	1141                	addi	sp,sp,-16
    800064f2:	e406                	sd	ra,8(sp)
    800064f4:	e022                	sd	s0,0(sp)
    800064f6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800064f8:	ffffb097          	auipc	ra,0xffffb
    800064fc:	794080e7          	jalr	1940(ra) # 80001c8c <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006500:	0085171b          	slliw	a4,a0,0x8
    80006504:	0c0027b7          	lui	a5,0xc002
    80006508:	97ba                	add	a5,a5,a4
    8000650a:	40200713          	li	a4,1026
    8000650e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006512:	00d5151b          	slliw	a0,a0,0xd
    80006516:	0c2017b7          	lui	a5,0xc201
    8000651a:	953e                	add	a0,a0,a5
    8000651c:	00052023          	sw	zero,0(a0)
}
    80006520:	60a2                	ld	ra,8(sp)
    80006522:	6402                	ld	s0,0(sp)
    80006524:	0141                	addi	sp,sp,16
    80006526:	8082                	ret

0000000080006528 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006528:	1141                	addi	sp,sp,-16
    8000652a:	e406                	sd	ra,8(sp)
    8000652c:	e022                	sd	s0,0(sp)
    8000652e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006530:	ffffb097          	auipc	ra,0xffffb
    80006534:	75c080e7          	jalr	1884(ra) # 80001c8c <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006538:	00d5179b          	slliw	a5,a0,0xd
    8000653c:	0c201537          	lui	a0,0xc201
    80006540:	953e                	add	a0,a0,a5
  return irq;
}
    80006542:	4148                	lw	a0,4(a0)
    80006544:	60a2                	ld	ra,8(sp)
    80006546:	6402                	ld	s0,0(sp)
    80006548:	0141                	addi	sp,sp,16
    8000654a:	8082                	ret

000000008000654c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000654c:	1101                	addi	sp,sp,-32
    8000654e:	ec06                	sd	ra,24(sp)
    80006550:	e822                	sd	s0,16(sp)
    80006552:	e426                	sd	s1,8(sp)
    80006554:	1000                	addi	s0,sp,32
    80006556:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006558:	ffffb097          	auipc	ra,0xffffb
    8000655c:	734080e7          	jalr	1844(ra) # 80001c8c <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006560:	00d5151b          	slliw	a0,a0,0xd
    80006564:	0c2017b7          	lui	a5,0xc201
    80006568:	97aa                	add	a5,a5,a0
    8000656a:	c3c4                	sw	s1,4(a5)
}
    8000656c:	60e2                	ld	ra,24(sp)
    8000656e:	6442                	ld	s0,16(sp)
    80006570:	64a2                	ld	s1,8(sp)
    80006572:	6105                	addi	sp,sp,32
    80006574:	8082                	ret

0000000080006576 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006576:	1141                	addi	sp,sp,-16
    80006578:	e406                	sd	ra,8(sp)
    8000657a:	e022                	sd	s0,0(sp)
    8000657c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000657e:	479d                	li	a5,7
    80006580:	04a7cc63          	blt	a5,a0,800065d8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006584:	0023d797          	auipc	a5,0x23d
    80006588:	3d478793          	addi	a5,a5,980 # 80243958 <disk>
    8000658c:	97aa                	add	a5,a5,a0
    8000658e:	0187c783          	lbu	a5,24(a5)
    80006592:	ebb9                	bnez	a5,800065e8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006594:	00451613          	slli	a2,a0,0x4
    80006598:	0023d797          	auipc	a5,0x23d
    8000659c:	3c078793          	addi	a5,a5,960 # 80243958 <disk>
    800065a0:	6394                	ld	a3,0(a5)
    800065a2:	96b2                	add	a3,a3,a2
    800065a4:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800065a8:	6398                	ld	a4,0(a5)
    800065aa:	9732                	add	a4,a4,a2
    800065ac:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800065b0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800065b4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800065b8:	953e                	add	a0,a0,a5
    800065ba:	4785                	li	a5,1
    800065bc:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    800065c0:	0023d517          	auipc	a0,0x23d
    800065c4:	3b050513          	addi	a0,a0,944 # 80243970 <disk+0x18>
    800065c8:	ffffc097          	auipc	ra,0xffffc
    800065cc:	15e080e7          	jalr	350(ra) # 80002726 <wakeup>
}
    800065d0:	60a2                	ld	ra,8(sp)
    800065d2:	6402                	ld	s0,0(sp)
    800065d4:	0141                	addi	sp,sp,16
    800065d6:	8082                	ret
    panic("free_desc 1");
    800065d8:	00002517          	auipc	a0,0x2
    800065dc:	2e050513          	addi	a0,a0,736 # 800088b8 <syscalls+0x310>
    800065e0:	ffffa097          	auipc	ra,0xffffa
    800065e4:	f64080e7          	jalr	-156(ra) # 80000544 <panic>
    panic("free_desc 2");
    800065e8:	00002517          	auipc	a0,0x2
    800065ec:	2e050513          	addi	a0,a0,736 # 800088c8 <syscalls+0x320>
    800065f0:	ffffa097          	auipc	ra,0xffffa
    800065f4:	f54080e7          	jalr	-172(ra) # 80000544 <panic>

00000000800065f8 <virtio_disk_init>:
{
    800065f8:	1101                	addi	sp,sp,-32
    800065fa:	ec06                	sd	ra,24(sp)
    800065fc:	e822                	sd	s0,16(sp)
    800065fe:	e426                	sd	s1,8(sp)
    80006600:	e04a                	sd	s2,0(sp)
    80006602:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006604:	00002597          	auipc	a1,0x2
    80006608:	2d458593          	addi	a1,a1,724 # 800088d8 <syscalls+0x330>
    8000660c:	0023d517          	auipc	a0,0x23d
    80006610:	47450513          	addi	a0,a0,1140 # 80243a80 <disk+0x128>
    80006614:	ffffa097          	auipc	ra,0xffffa
    80006618:	704080e7          	jalr	1796(ra) # 80000d18 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000661c:	100017b7          	lui	a5,0x10001
    80006620:	4398                	lw	a4,0(a5)
    80006622:	2701                	sext.w	a4,a4
    80006624:	747277b7          	lui	a5,0x74727
    80006628:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000662c:	14f71e63          	bne	a4,a5,80006788 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006630:	100017b7          	lui	a5,0x10001
    80006634:	43dc                	lw	a5,4(a5)
    80006636:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006638:	4709                	li	a4,2
    8000663a:	14e79763          	bne	a5,a4,80006788 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000663e:	100017b7          	lui	a5,0x10001
    80006642:	479c                	lw	a5,8(a5)
    80006644:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006646:	14e79163          	bne	a5,a4,80006788 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000664a:	100017b7          	lui	a5,0x10001
    8000664e:	47d8                	lw	a4,12(a5)
    80006650:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006652:	554d47b7          	lui	a5,0x554d4
    80006656:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000665a:	12f71763          	bne	a4,a5,80006788 <virtio_disk_init+0x190>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000665e:	100017b7          	lui	a5,0x10001
    80006662:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006666:	4705                	li	a4,1
    80006668:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000666a:	470d                	li	a4,3
    8000666c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000666e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006670:	c7ffe737          	lui	a4,0xc7ffe
    80006674:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47dbacc7>
    80006678:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000667a:	2701                	sext.w	a4,a4
    8000667c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000667e:	472d                	li	a4,11
    80006680:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006682:	0707a903          	lw	s2,112(a5)
    80006686:	2901                	sext.w	s2,s2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006688:	00897793          	andi	a5,s2,8
    8000668c:	10078663          	beqz	a5,80006798 <virtio_disk_init+0x1a0>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006690:	100017b7          	lui	a5,0x10001
    80006694:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006698:	43fc                	lw	a5,68(a5)
    8000669a:	2781                	sext.w	a5,a5
    8000669c:	10079663          	bnez	a5,800067a8 <virtio_disk_init+0x1b0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800066a0:	100017b7          	lui	a5,0x10001
    800066a4:	5bdc                	lw	a5,52(a5)
    800066a6:	2781                	sext.w	a5,a5
  if(max == 0)
    800066a8:	10078863          	beqz	a5,800067b8 <virtio_disk_init+0x1c0>
  if(max < NUM)
    800066ac:	471d                	li	a4,7
    800066ae:	10f77d63          	bgeu	a4,a5,800067c8 <virtio_disk_init+0x1d0>
  disk.desc = kalloc();
    800066b2:	ffffa097          	auipc	ra,0xffffa
    800066b6:	5c2080e7          	jalr	1474(ra) # 80000c74 <kalloc>
    800066ba:	0023d497          	auipc	s1,0x23d
    800066be:	29e48493          	addi	s1,s1,670 # 80243958 <disk>
    800066c2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800066c4:	ffffa097          	auipc	ra,0xffffa
    800066c8:	5b0080e7          	jalr	1456(ra) # 80000c74 <kalloc>
    800066cc:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800066ce:	ffffa097          	auipc	ra,0xffffa
    800066d2:	5a6080e7          	jalr	1446(ra) # 80000c74 <kalloc>
    800066d6:	87aa                	mv	a5,a0
    800066d8:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800066da:	6088                	ld	a0,0(s1)
    800066dc:	cd75                	beqz	a0,800067d8 <virtio_disk_init+0x1e0>
    800066de:	0023d717          	auipc	a4,0x23d
    800066e2:	28273703          	ld	a4,642(a4) # 80243960 <disk+0x8>
    800066e6:	cb6d                	beqz	a4,800067d8 <virtio_disk_init+0x1e0>
    800066e8:	cbe5                	beqz	a5,800067d8 <virtio_disk_init+0x1e0>
  memset(disk.desc, 0, PGSIZE);
    800066ea:	6605                	lui	a2,0x1
    800066ec:	4581                	li	a1,0
    800066ee:	ffffa097          	auipc	ra,0xffffa
    800066f2:	7b6080e7          	jalr	1974(ra) # 80000ea4 <memset>
  memset(disk.avail, 0, PGSIZE);
    800066f6:	0023d497          	auipc	s1,0x23d
    800066fa:	26248493          	addi	s1,s1,610 # 80243958 <disk>
    800066fe:	6605                	lui	a2,0x1
    80006700:	4581                	li	a1,0
    80006702:	6488                	ld	a0,8(s1)
    80006704:	ffffa097          	auipc	ra,0xffffa
    80006708:	7a0080e7          	jalr	1952(ra) # 80000ea4 <memset>
  memset(disk.used, 0, PGSIZE);
    8000670c:	6605                	lui	a2,0x1
    8000670e:	4581                	li	a1,0
    80006710:	6888                	ld	a0,16(s1)
    80006712:	ffffa097          	auipc	ra,0xffffa
    80006716:	792080e7          	jalr	1938(ra) # 80000ea4 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000671a:	100017b7          	lui	a5,0x10001
    8000671e:	4721                	li	a4,8
    80006720:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006722:	4098                	lw	a4,0(s1)
    80006724:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006728:	40d8                	lw	a4,4(s1)
    8000672a:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000672e:	6498                	ld	a4,8(s1)
    80006730:	0007069b          	sext.w	a3,a4
    80006734:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006738:	9701                	srai	a4,a4,0x20
    8000673a:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000673e:	6898                	ld	a4,16(s1)
    80006740:	0007069b          	sext.w	a3,a4
    80006744:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006748:	9701                	srai	a4,a4,0x20
    8000674a:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000674e:	4685                	li	a3,1
    80006750:	c3f4                	sw	a3,68(a5)
    disk.free[i] = 1;
    80006752:	4705                	li	a4,1
    80006754:	00d48c23          	sb	a3,24(s1)
    80006758:	00e48ca3          	sb	a4,25(s1)
    8000675c:	00e48d23          	sb	a4,26(s1)
    80006760:	00e48da3          	sb	a4,27(s1)
    80006764:	00e48e23          	sb	a4,28(s1)
    80006768:	00e48ea3          	sb	a4,29(s1)
    8000676c:	00e48f23          	sb	a4,30(s1)
    80006770:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006774:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006778:	0727a823          	sw	s2,112(a5)
}
    8000677c:	60e2                	ld	ra,24(sp)
    8000677e:	6442                	ld	s0,16(sp)
    80006780:	64a2                	ld	s1,8(sp)
    80006782:	6902                	ld	s2,0(sp)
    80006784:	6105                	addi	sp,sp,32
    80006786:	8082                	ret
    panic("could not find virtio disk");
    80006788:	00002517          	auipc	a0,0x2
    8000678c:	16050513          	addi	a0,a0,352 # 800088e8 <syscalls+0x340>
    80006790:	ffffa097          	auipc	ra,0xffffa
    80006794:	db4080e7          	jalr	-588(ra) # 80000544 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006798:	00002517          	auipc	a0,0x2
    8000679c:	17050513          	addi	a0,a0,368 # 80008908 <syscalls+0x360>
    800067a0:	ffffa097          	auipc	ra,0xffffa
    800067a4:	da4080e7          	jalr	-604(ra) # 80000544 <panic>
    panic("virtio disk should not be ready");
    800067a8:	00002517          	auipc	a0,0x2
    800067ac:	18050513          	addi	a0,a0,384 # 80008928 <syscalls+0x380>
    800067b0:	ffffa097          	auipc	ra,0xffffa
    800067b4:	d94080e7          	jalr	-620(ra) # 80000544 <panic>
    panic("virtio disk has no queue 0");
    800067b8:	00002517          	auipc	a0,0x2
    800067bc:	19050513          	addi	a0,a0,400 # 80008948 <syscalls+0x3a0>
    800067c0:	ffffa097          	auipc	ra,0xffffa
    800067c4:	d84080e7          	jalr	-636(ra) # 80000544 <panic>
    panic("virtio disk max queue too short");
    800067c8:	00002517          	auipc	a0,0x2
    800067cc:	1a050513          	addi	a0,a0,416 # 80008968 <syscalls+0x3c0>
    800067d0:	ffffa097          	auipc	ra,0xffffa
    800067d4:	d74080e7          	jalr	-652(ra) # 80000544 <panic>
    panic("virtio disk kalloc");
    800067d8:	00002517          	auipc	a0,0x2
    800067dc:	1b050513          	addi	a0,a0,432 # 80008988 <syscalls+0x3e0>
    800067e0:	ffffa097          	auipc	ra,0xffffa
    800067e4:	d64080e7          	jalr	-668(ra) # 80000544 <panic>

00000000800067e8 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800067e8:	7159                	addi	sp,sp,-112
    800067ea:	f486                	sd	ra,104(sp)
    800067ec:	f0a2                	sd	s0,96(sp)
    800067ee:	eca6                	sd	s1,88(sp)
    800067f0:	e8ca                	sd	s2,80(sp)
    800067f2:	e4ce                	sd	s3,72(sp)
    800067f4:	e0d2                	sd	s4,64(sp)
    800067f6:	fc56                	sd	s5,56(sp)
    800067f8:	f85a                	sd	s6,48(sp)
    800067fa:	f45e                	sd	s7,40(sp)
    800067fc:	f062                	sd	s8,32(sp)
    800067fe:	ec66                	sd	s9,24(sp)
    80006800:	e86a                	sd	s10,16(sp)
    80006802:	1880                	addi	s0,sp,112
    80006804:	892a                	mv	s2,a0
    80006806:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006808:	00c52c83          	lw	s9,12(a0)
    8000680c:	001c9c9b          	slliw	s9,s9,0x1
    80006810:	1c82                	slli	s9,s9,0x20
    80006812:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006816:	0023d517          	auipc	a0,0x23d
    8000681a:	26a50513          	addi	a0,a0,618 # 80243a80 <disk+0x128>
    8000681e:	ffffa097          	auipc	ra,0xffffa
    80006822:	58a080e7          	jalr	1418(ra) # 80000da8 <acquire>
  for(int i = 0; i < 3; i++){
    80006826:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006828:	4ba1                	li	s7,8
      disk.free[i] = 0;
    8000682a:	0023db17          	auipc	s6,0x23d
    8000682e:	12eb0b13          	addi	s6,s6,302 # 80243958 <disk>
  for(int i = 0; i < 3; i++){
    80006832:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80006834:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006836:	0023dc17          	auipc	s8,0x23d
    8000683a:	24ac0c13          	addi	s8,s8,586 # 80243a80 <disk+0x128>
    8000683e:	a8b5                	j	800068ba <virtio_disk_rw+0xd2>
      disk.free[i] = 0;
    80006840:	00fb06b3          	add	a3,s6,a5
    80006844:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006848:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    8000684a:	0207c563          	bltz	a5,80006874 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000684e:	2485                	addiw	s1,s1,1
    80006850:	0711                	addi	a4,a4,4
    80006852:	1f548a63          	beq	s1,s5,80006a46 <virtio_disk_rw+0x25e>
    idx[i] = alloc_desc();
    80006856:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80006858:	0023d697          	auipc	a3,0x23d
    8000685c:	10068693          	addi	a3,a3,256 # 80243958 <disk>
    80006860:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80006862:	0186c583          	lbu	a1,24(a3)
    80006866:	fde9                	bnez	a1,80006840 <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006868:	2785                	addiw	a5,a5,1
    8000686a:	0685                	addi	a3,a3,1
    8000686c:	ff779be3          	bne	a5,s7,80006862 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    80006870:	57fd                	li	a5,-1
    80006872:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80006874:	02905a63          	blez	s1,800068a8 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    80006878:	f9042503          	lw	a0,-112(s0)
    8000687c:	00000097          	auipc	ra,0x0
    80006880:	cfa080e7          	jalr	-774(ra) # 80006576 <free_desc>
      for(int j = 0; j < i; j++)
    80006884:	4785                	li	a5,1
    80006886:	0297d163          	bge	a5,s1,800068a8 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000688a:	f9442503          	lw	a0,-108(s0)
    8000688e:	00000097          	auipc	ra,0x0
    80006892:	ce8080e7          	jalr	-792(ra) # 80006576 <free_desc>
      for(int j = 0; j < i; j++)
    80006896:	4789                	li	a5,2
    80006898:	0097d863          	bge	a5,s1,800068a8 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000689c:	f9842503          	lw	a0,-104(s0)
    800068a0:	00000097          	auipc	ra,0x0
    800068a4:	cd6080e7          	jalr	-810(ra) # 80006576 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800068a8:	85e2                	mv	a1,s8
    800068aa:	0023d517          	auipc	a0,0x23d
    800068ae:	0c650513          	addi	a0,a0,198 # 80243970 <disk+0x18>
    800068b2:	ffffc097          	auipc	ra,0xffffc
    800068b6:	b76080e7          	jalr	-1162(ra) # 80002428 <sleep>
  for(int i = 0; i < 3; i++){
    800068ba:	f9040713          	addi	a4,s0,-112
    800068be:	84ce                	mv	s1,s3
    800068c0:	bf59                	j	80006856 <virtio_disk_rw+0x6e>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    800068c2:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    800068c6:	00479693          	slli	a3,a5,0x4
    800068ca:	0023d797          	auipc	a5,0x23d
    800068ce:	08e78793          	addi	a5,a5,142 # 80243958 <disk>
    800068d2:	97b6                	add	a5,a5,a3
    800068d4:	4685                	li	a3,1
    800068d6:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800068d8:	0023d597          	auipc	a1,0x23d
    800068dc:	08058593          	addi	a1,a1,128 # 80243958 <disk>
    800068e0:	00a60793          	addi	a5,a2,10
    800068e4:	0792                	slli	a5,a5,0x4
    800068e6:	97ae                	add	a5,a5,a1
    800068e8:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    800068ec:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800068f0:	f6070693          	addi	a3,a4,-160
    800068f4:	619c                	ld	a5,0(a1)
    800068f6:	97b6                	add	a5,a5,a3
    800068f8:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800068fa:	6188                	ld	a0,0(a1)
    800068fc:	96aa                	add	a3,a3,a0
    800068fe:	47c1                	li	a5,16
    80006900:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006902:	4785                	li	a5,1
    80006904:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006908:	f9442783          	lw	a5,-108(s0)
    8000690c:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006910:	0792                	slli	a5,a5,0x4
    80006912:	953e                	add	a0,a0,a5
    80006914:	05890693          	addi	a3,s2,88
    80006918:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000691a:	6188                	ld	a0,0(a1)
    8000691c:	97aa                	add	a5,a5,a0
    8000691e:	40000693          	li	a3,1024
    80006922:	c794                	sw	a3,8(a5)
  if(write)
    80006924:	100d0d63          	beqz	s10,80006a3e <virtio_disk_rw+0x256>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006928:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000692c:	00c7d683          	lhu	a3,12(a5)
    80006930:	0016e693          	ori	a3,a3,1
    80006934:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    80006938:	f9842583          	lw	a1,-104(s0)
    8000693c:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006940:	0023d697          	auipc	a3,0x23d
    80006944:	01868693          	addi	a3,a3,24 # 80243958 <disk>
    80006948:	00260793          	addi	a5,a2,2
    8000694c:	0792                	slli	a5,a5,0x4
    8000694e:	97b6                	add	a5,a5,a3
    80006950:	587d                	li	a6,-1
    80006952:	01078823          	sb	a6,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006956:	0592                	slli	a1,a1,0x4
    80006958:	952e                	add	a0,a0,a1
    8000695a:	f9070713          	addi	a4,a4,-112
    8000695e:	9736                	add	a4,a4,a3
    80006960:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    80006962:	6298                	ld	a4,0(a3)
    80006964:	972e                	add	a4,a4,a1
    80006966:	4585                	li	a1,1
    80006968:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000696a:	4509                	li	a0,2
    8000696c:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    80006970:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006974:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    80006978:	0127b423          	sd	s2,8(a5)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000697c:	6698                	ld	a4,8(a3)
    8000697e:	00275783          	lhu	a5,2(a4)
    80006982:	8b9d                	andi	a5,a5,7
    80006984:	0786                	slli	a5,a5,0x1
    80006986:	97ba                	add	a5,a5,a4
    80006988:	00c79223          	sh	a2,4(a5)

  __sync_synchronize();
    8000698c:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006990:	6698                	ld	a4,8(a3)
    80006992:	00275783          	lhu	a5,2(a4)
    80006996:	2785                	addiw	a5,a5,1
    80006998:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000699c:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800069a0:	100017b7          	lui	a5,0x10001
    800069a4:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800069a8:	00492703          	lw	a4,4(s2)
    800069ac:	4785                	li	a5,1
    800069ae:	02f71163          	bne	a4,a5,800069d0 <virtio_disk_rw+0x1e8>
    sleep(b, &disk.vdisk_lock);
    800069b2:	0023d997          	auipc	s3,0x23d
    800069b6:	0ce98993          	addi	s3,s3,206 # 80243a80 <disk+0x128>
  while(b->disk == 1) {
    800069ba:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800069bc:	85ce                	mv	a1,s3
    800069be:	854a                	mv	a0,s2
    800069c0:	ffffc097          	auipc	ra,0xffffc
    800069c4:	a68080e7          	jalr	-1432(ra) # 80002428 <sleep>
  while(b->disk == 1) {
    800069c8:	00492783          	lw	a5,4(s2)
    800069cc:	fe9788e3          	beq	a5,s1,800069bc <virtio_disk_rw+0x1d4>
  }

  disk.info[idx[0]].b = 0;
    800069d0:	f9042903          	lw	s2,-112(s0)
    800069d4:	00290793          	addi	a5,s2,2
    800069d8:	00479713          	slli	a4,a5,0x4
    800069dc:	0023d797          	auipc	a5,0x23d
    800069e0:	f7c78793          	addi	a5,a5,-132 # 80243958 <disk>
    800069e4:	97ba                	add	a5,a5,a4
    800069e6:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800069ea:	0023d997          	auipc	s3,0x23d
    800069ee:	f6e98993          	addi	s3,s3,-146 # 80243958 <disk>
    800069f2:	00491713          	slli	a4,s2,0x4
    800069f6:	0009b783          	ld	a5,0(s3)
    800069fa:	97ba                	add	a5,a5,a4
    800069fc:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006a00:	854a                	mv	a0,s2
    80006a02:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006a06:	00000097          	auipc	ra,0x0
    80006a0a:	b70080e7          	jalr	-1168(ra) # 80006576 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006a0e:	8885                	andi	s1,s1,1
    80006a10:	f0ed                	bnez	s1,800069f2 <virtio_disk_rw+0x20a>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006a12:	0023d517          	auipc	a0,0x23d
    80006a16:	06e50513          	addi	a0,a0,110 # 80243a80 <disk+0x128>
    80006a1a:	ffffa097          	auipc	ra,0xffffa
    80006a1e:	442080e7          	jalr	1090(ra) # 80000e5c <release>
}
    80006a22:	70a6                	ld	ra,104(sp)
    80006a24:	7406                	ld	s0,96(sp)
    80006a26:	64e6                	ld	s1,88(sp)
    80006a28:	6946                	ld	s2,80(sp)
    80006a2a:	69a6                	ld	s3,72(sp)
    80006a2c:	6a06                	ld	s4,64(sp)
    80006a2e:	7ae2                	ld	s5,56(sp)
    80006a30:	7b42                	ld	s6,48(sp)
    80006a32:	7ba2                	ld	s7,40(sp)
    80006a34:	7c02                	ld	s8,32(sp)
    80006a36:	6ce2                	ld	s9,24(sp)
    80006a38:	6d42                	ld	s10,16(sp)
    80006a3a:	6165                	addi	sp,sp,112
    80006a3c:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006a3e:	4689                	li	a3,2
    80006a40:	00d79623          	sh	a3,12(a5)
    80006a44:	b5e5                	j	8000692c <virtio_disk_rw+0x144>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006a46:	f9042603          	lw	a2,-112(s0)
    80006a4a:	00a60713          	addi	a4,a2,10
    80006a4e:	0712                	slli	a4,a4,0x4
    80006a50:	0023d517          	auipc	a0,0x23d
    80006a54:	f1050513          	addi	a0,a0,-240 # 80243960 <disk+0x8>
    80006a58:	953a                	add	a0,a0,a4
  if(write)
    80006a5a:	e60d14e3          	bnez	s10,800068c2 <virtio_disk_rw+0xda>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    80006a5e:	00a60793          	addi	a5,a2,10
    80006a62:	00479693          	slli	a3,a5,0x4
    80006a66:	0023d797          	auipc	a5,0x23d
    80006a6a:	ef278793          	addi	a5,a5,-270 # 80243958 <disk>
    80006a6e:	97b6                	add	a5,a5,a3
    80006a70:	0007a423          	sw	zero,8(a5)
    80006a74:	b595                	j	800068d8 <virtio_disk_rw+0xf0>

0000000080006a76 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006a76:	1101                	addi	sp,sp,-32
    80006a78:	ec06                	sd	ra,24(sp)
    80006a7a:	e822                	sd	s0,16(sp)
    80006a7c:	e426                	sd	s1,8(sp)
    80006a7e:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006a80:	0023d497          	auipc	s1,0x23d
    80006a84:	ed848493          	addi	s1,s1,-296 # 80243958 <disk>
    80006a88:	0023d517          	auipc	a0,0x23d
    80006a8c:	ff850513          	addi	a0,a0,-8 # 80243a80 <disk+0x128>
    80006a90:	ffffa097          	auipc	ra,0xffffa
    80006a94:	318080e7          	jalr	792(ra) # 80000da8 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006a98:	10001737          	lui	a4,0x10001
    80006a9c:	533c                	lw	a5,96(a4)
    80006a9e:	8b8d                	andi	a5,a5,3
    80006aa0:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006aa2:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006aa6:	689c                	ld	a5,16(s1)
    80006aa8:	0204d703          	lhu	a4,32(s1)
    80006aac:	0027d783          	lhu	a5,2(a5)
    80006ab0:	04f70863          	beq	a4,a5,80006b00 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006ab4:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006ab8:	6898                	ld	a4,16(s1)
    80006aba:	0204d783          	lhu	a5,32(s1)
    80006abe:	8b9d                	andi	a5,a5,7
    80006ac0:	078e                	slli	a5,a5,0x3
    80006ac2:	97ba                	add	a5,a5,a4
    80006ac4:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006ac6:	00278713          	addi	a4,a5,2
    80006aca:	0712                	slli	a4,a4,0x4
    80006acc:	9726                	add	a4,a4,s1
    80006ace:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006ad2:	e721                	bnez	a4,80006b1a <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006ad4:	0789                	addi	a5,a5,2
    80006ad6:	0792                	slli	a5,a5,0x4
    80006ad8:	97a6                	add	a5,a5,s1
    80006ada:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006adc:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006ae0:	ffffc097          	auipc	ra,0xffffc
    80006ae4:	c46080e7          	jalr	-954(ra) # 80002726 <wakeup>

    disk.used_idx += 1;
    80006ae8:	0204d783          	lhu	a5,32(s1)
    80006aec:	2785                	addiw	a5,a5,1
    80006aee:	17c2                	slli	a5,a5,0x30
    80006af0:	93c1                	srli	a5,a5,0x30
    80006af2:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006af6:	6898                	ld	a4,16(s1)
    80006af8:	00275703          	lhu	a4,2(a4)
    80006afc:	faf71ce3          	bne	a4,a5,80006ab4 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006b00:	0023d517          	auipc	a0,0x23d
    80006b04:	f8050513          	addi	a0,a0,-128 # 80243a80 <disk+0x128>
    80006b08:	ffffa097          	auipc	ra,0xffffa
    80006b0c:	354080e7          	jalr	852(ra) # 80000e5c <release>
}
    80006b10:	60e2                	ld	ra,24(sp)
    80006b12:	6442                	ld	s0,16(sp)
    80006b14:	64a2                	ld	s1,8(sp)
    80006b16:	6105                	addi	sp,sp,32
    80006b18:	8082                	ret
      panic("virtio_disk_intr status");
    80006b1a:	00002517          	auipc	a0,0x2
    80006b1e:	e8650513          	addi	a0,a0,-378 # 800089a0 <syscalls+0x3f8>
    80006b22:	ffffa097          	auipc	ra,0xffffa
    80006b26:	a22080e7          	jalr	-1502(ra) # 80000544 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
