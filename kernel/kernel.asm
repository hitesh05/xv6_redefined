
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
    80000068:	47c78793          	addi	a5,a5,1148 # 800064e0 <timervec>
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

void krefincr(void *pa)
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
	int pn = (uint64)pa / PGSIZE;
	if ((uint64)pa > PHYSTOP)
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

void krefdecr(void *pa)
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
	int pn = (uint64)pa / PGSIZE;
	if ((uint64)pa > PHYSTOP)
    80000a82:	4745                	li	a4,17
    80000a84:	076e                	slli	a4,a4,0x1b
    80000a86:	02976c63          	bltu	a4,s1,80000abe <krefdecr+0x58>
    80000a8a:	00c4d793          	srli	a5,s1,0xc
    80000a8e:	2781                	sext.w	a5,a5
	{
		panic("Physical Address limit exceeded");
	}

	refcnt.count[pn]--;
    80000a90:	0791                	addi	a5,a5,4
    80000a92:	078a                	slli	a5,a5,0x2
    80000a94:	00010717          	auipc	a4,0x10
    80000a98:	3dc70713          	addi	a4,a4,988 # 80010e70 <refcnt>
    80000a9c:	97ba                	add	a5,a5,a4
    80000a9e:	4798                	lw	a4,8(a5)
    80000aa0:	377d                	addiw	a4,a4,-1
    80000aa2:	c798                	sw	a4,8(a5)
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

	// Fill with junk to catch dangling refs.
	memset(pa, 1, PGSIZE);
    80000b50:	6605                	lui	a2,0x1
    80000b52:	4585                	li	a1,1
    80000b54:	8526                	mv	a0,s1
    80000b56:	00000097          	auipc	ra,0x0
    80000b5a:	34e080e7          	jalr	846(ra) # 80000ea4 <memset>

	acquire(&kmem.lock);
    80000b5e:	854a                	mv	a0,s2
    80000b60:	00000097          	auipc	ra,0x0
    80000b64:	248080e7          	jalr	584(ra) # 80000da8 <acquire>
	r->next = kmem.freelist;
    80000b68:	01893783          	ld	a5,24(s2)
    80000b6c:	e09c                	sd	a5,0(s1)
	kmem.freelist = r;
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
    800010a4:	480080e7          	jalr	1152(ra) # 80006520 <plicinithart>
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
    80001124:	3ea080e7          	jalr	1002(ra) # 8000650a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001128:	00005097          	auipc	ra,0x5
    8000112c:	3f8080e7          	jalr	1016(ra) # 80006520 <plicinithart>
    binit();         // buffer cache
    80001130:	00002097          	auipc	ra,0x2
    80001134:	5aa080e7          	jalr	1450(ra) # 800036da <binit>
    iinit();         // inode table
    80001138:	00003097          	auipc	ra,0x3
    8000113c:	c4e080e7          	jalr	-946(ra) # 80003d86 <iinit>
    fileinit();      // file table
    80001140:	00004097          	auipc	ra,0x4
    80001144:	bec080e7          	jalr	-1044(ra) # 80004d2c <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001148:	00005097          	auipc	ra,0x5
    8000114c:	4e0080e7          	jalr	1248(ra) # 80006628 <virtio_disk_init>
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
    80001754:	8b2a                	mv	s6,a0
    80001756:	8aae                	mv	s5,a1
    80001758:	8a32                	mv	s4,a2
	for (i = 0; i < sz; i += PGSIZE)
    8000175a:	4901                	li	s2,0
    8000175c:	a0a9                	j	800017a6 <uvmcopy+0x68>
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
			// flags &= (~PTE_W);
			flags = (flags | PTE_C) & (~PTE_W);
			// *pte = (*pte & ~PTE_W) | PTE_C;
		}
		flags |= PTE_C;
		krefincr((void *)pa);
    8000177e:	854e                	mv	a0,s3
    80001780:	fffff097          	auipc	ra,0xfffff
    80001784:	27e080e7          	jalr	638(ra) # 800009fe <krefincr>

		// if ((mem = kalloc()) == 0)
		//   goto err;
		// memmove(mem, (char *)pa, PGSIZE);

		if (mappages(new, i, PGSIZE, (uint64)pa, flags) != 0)
    80001788:	1004e713          	ori	a4,s1,256
    8000178c:	86ce                	mv	a3,s3
    8000178e:	6605                	lui	a2,0x1
    80001790:	85ca                	mv	a1,s2
    80001792:	8556                	mv	a0,s5
    80001794:	00000097          	auipc	ra,0x0
    80001798:	ae4080e7          	jalr	-1308(ra) # 80001278 <mappages>
    8000179c:	ed1d                	bnez	a0,800017da <uvmcopy+0x9c>
	for (i = 0; i < sz; i += PGSIZE)
    8000179e:	6785                	lui	a5,0x1
    800017a0:	993e                	add	s2,s2,a5
    800017a2:	05497663          	bgeu	s2,s4,800017ee <uvmcopy+0xb0>
		if ((pte = walk(old, i, 0)) == 0)
    800017a6:	4601                	li	a2,0
    800017a8:	85ca                	mv	a1,s2
    800017aa:	855a                	mv	a0,s6
    800017ac:	00000097          	auipc	ra,0x0
    800017b0:	9e4080e7          	jalr	-1564(ra) # 80001190 <walk>
    800017b4:	d54d                	beqz	a0,8000175e <uvmcopy+0x20>
		if ((*pte & PTE_V) == 0)
    800017b6:	611c                	ld	a5,0(a0)
    800017b8:	0017f713          	andi	a4,a5,1
    800017bc:	db4d                	beqz	a4,8000176e <uvmcopy+0x30>
		pa = PTE2PA(*pte);
    800017be:	00a7d993          	srli	s3,a5,0xa
    800017c2:	09b2                	slli	s3,s3,0xc
		flags = PTE_FLAGS(*pte);
    800017c4:	2781                	sext.w	a5,a5
		if (flags & PTE_W)
    800017c6:	0047f713          	andi	a4,a5,4
		flags = PTE_FLAGS(*pte);
    800017ca:	3ff7f493          	andi	s1,a5,1023
		if (flags & PTE_W)
    800017ce:	db45                	beqz	a4,8000177e <uvmcopy+0x40>
			flags = (flags | PTE_C) & (~PTE_W);
    800017d0:	3fb7f793          	andi	a5,a5,1019
    800017d4:	1007e493          	ori	s1,a5,256
    800017d8:	b75d                	j	8000177e <uvmcopy+0x40>
		}
	}
	return 0;

err:
	uvmunmap(new, 0, i / PGSIZE, 1);
    800017da:	4685                	li	a3,1
    800017dc:	00c95613          	srli	a2,s2,0xc
    800017e0:	4581                	li	a1,0
    800017e2:	8556                	mv	a0,s5
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
    80001d18:	f94080e7          	jalr	-108(ra) # 80002ca8 <usertrapret>
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
    80001d32:	fd8080e7          	jalr	-40(ra) # 80003d06 <fsinit>
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
    8000202a:	702080e7          	jalr	1794(ra) # 80004728 <namei>
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
    80002156:	c6c080e7          	jalr	-916(ra) # 80004dbe <filedup>
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
    80002178:	dd0080e7          	jalr	-560(ra) # 80003f44 <idup>
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
    8000286a:	5aa080e7          	jalr	1450(ra) # 80004e10 <fileclose>
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
    80002882:	0c6080e7          	jalr	198(ra) # 80004944 <begin_op>
	iput(p->cwd);
    80002886:	1589b503          	ld	a0,344(s3)
    8000288a:	00002097          	auipc	ra,0x2
    8000288e:	8b2080e7          	jalr	-1870(ra) # 8000413c <iput>
	end_op();
    80002892:	00002097          	auipc	ra,0x2
    80002896:	132080e7          	jalr	306(ra) # 800049c4 <end_op>
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
    80002bfc:	85878793          	addi	a5,a5,-1960 # 80006450 <kernelvec>
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
    80002c14:	08e7e063          	bltu	a5,a4,80002c94 <cowalloc+0x8a>
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
    80002c32:	c13d                	beqz	a0,80002c98 <cowalloc+0x8e>
		return -1;
	if ((*pte & PTE_U) == 0 || (*pte & PTE_V) == 0)
    80002c34:	611c                	ld	a5,0(a0)
    80002c36:	0117f693          	andi	a3,a5,17
    80002c3a:	4745                	li	a4,17
    80002c3c:	06e69063          	bne	a3,a4,80002c9c <cowalloc+0x92>
		return -1;

	uint64 pa = PTE2PA(*pte);
    80002c40:	00a7d913          	srli	s2,a5,0xa
    80002c44:	0932                	slli	s2,s2,0xc
	if (pa == 0)
    80002c46:	04090d63          	beqz	s2,80002ca0 <cowalloc+0x96>

	// printf("here\n");

	// ** If page fault is raised with a COW page,
	// ** alloc a physical page, mapped to user pagetable and set PTE_W
	if (*pte & PTE_C)
    80002c4a:	1007f793          	andi	a5,a5,256
		// mappages(pagetable, va, PGSIZE, (uint64)ka, flags);
		krefdecr((void *)pa);
		// kfree((void *)pa);
	}

	return 0;
    80002c4e:	4501                	li	a0,0
	if (*pte & PTE_C)
    80002c50:	eb81                	bnez	a5,80002c60 <cowalloc+0x56>
}
    80002c52:	70a2                	ld	ra,40(sp)
    80002c54:	7402                	ld	s0,32(sp)
    80002c56:	64e2                	ld	s1,24(sp)
    80002c58:	6942                	ld	s2,16(sp)
    80002c5a:	69a2                	ld	s3,8(sp)
    80002c5c:	6145                	addi	sp,sp,48
    80002c5e:	8082                	ret
		uint64 ka = (uint64)kalloc();
    80002c60:	ffffe097          	auipc	ra,0xffffe
    80002c64:	014080e7          	jalr	20(ra) # 80000c74 <kalloc>
    80002c68:	89aa                	mv	s3,a0
		if (ka == 0)
    80002c6a:	cd0d                	beqz	a0,80002ca4 <cowalloc+0x9a>
		memmove((void *)ka, (void *)pa, PGSIZE);
    80002c6c:	6605                	lui	a2,0x1
    80002c6e:	85ca                	mv	a1,s2
    80002c70:	ffffe097          	auipc	ra,0xffffe
    80002c74:	294080e7          	jalr	660(ra) # 80000f04 <memmove>
		*pte = PA2PTE(ka) | PTE_U | PTE_V | PTE_W | PTE_X | PTE_R;
    80002c78:	00c9d993          	srli	s3,s3,0xc
    80002c7c:	09aa                	slli	s3,s3,0xa
    80002c7e:	01f9e993          	ori	s3,s3,31
    80002c82:	0134b023          	sd	s3,0(s1)
		krefdecr((void *)pa);
    80002c86:	854a                	mv	a0,s2
    80002c88:	ffffe097          	auipc	ra,0xffffe
    80002c8c:	dde080e7          	jalr	-546(ra) # 80000a66 <krefdecr>
	return 0;
    80002c90:	4501                	li	a0,0
    80002c92:	b7c1                	j	80002c52 <cowalloc+0x48>
		return -1;
    80002c94:	557d                	li	a0,-1
}
    80002c96:	8082                	ret
		return -1;
    80002c98:	557d                	li	a0,-1
    80002c9a:	bf65                	j	80002c52 <cowalloc+0x48>
		return -1;
    80002c9c:	557d                	li	a0,-1
    80002c9e:	bf55                	j	80002c52 <cowalloc+0x48>
		return -1;
    80002ca0:	557d                	li	a0,-1
    80002ca2:	bf45                	j	80002c52 <cowalloc+0x48>
			return -1;
    80002ca4:	557d                	li	a0,-1
    80002ca6:	b775                	j	80002c52 <cowalloc+0x48>

0000000080002ca8 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80002ca8:	1141                	addi	sp,sp,-16
    80002caa:	e406                	sd	ra,8(sp)
    80002cac:	e022                	sd	s0,0(sp)
    80002cae:	0800                	addi	s0,sp,16
	struct proc *p = myproc();
    80002cb0:	fffff097          	auipc	ra,0xfffff
    80002cb4:	008080e7          	jalr	8(ra) # 80001cb8 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cb8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002cbc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002cbe:	10079073          	csrw	sstatus,a5
	// kerneltrap() to usertrap(), so turn off interrupts until
	// we're back in user space, where usertrap() is correct.
	intr_off();

	// send syscalls, interrupts, and exceptions to uservec in trampoline.S
	uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002cc2:	00004617          	auipc	a2,0x4
    80002cc6:	33e60613          	addi	a2,a2,830 # 80007000 <_trampoline>
    80002cca:	00004697          	auipc	a3,0x4
    80002cce:	33668693          	addi	a3,a3,822 # 80007000 <_trampoline>
    80002cd2:	8e91                	sub	a3,a3,a2
    80002cd4:	040007b7          	lui	a5,0x4000
    80002cd8:	17fd                	addi	a5,a5,-1
    80002cda:	07b2                	slli	a5,a5,0xc
    80002cdc:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002cde:	10569073          	csrw	stvec,a3
	w_stvec(trampoline_uservec);

	// set up trapframe values that uservec will need when
	// the process next traps into the kernel.
	p->trapframe->kernel_satp = r_satp();		  // kernel page table
    80002ce2:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002ce4:	180026f3          	csrr	a3,satp
    80002ce8:	e314                	sd	a3,0(a4)
	p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002cea:	7138                	ld	a4,96(a0)
    80002cec:	6534                	ld	a3,72(a0)
    80002cee:	6585                	lui	a1,0x1
    80002cf0:	96ae                	add	a3,a3,a1
    80002cf2:	e714                	sd	a3,8(a4)
	p->trapframe->kernel_trap = (uint64)usertrap;
    80002cf4:	7138                	ld	a4,96(a0)
    80002cf6:	00000697          	auipc	a3,0x0
    80002cfa:	13e68693          	addi	a3,a3,318 # 80002e34 <usertrap>
    80002cfe:	eb14                	sd	a3,16(a4)
	p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002d00:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002d02:	8692                	mv	a3,tp
    80002d04:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d06:	100026f3          	csrr	a3,sstatus
	// set up the registers that trampoline.S's sret will use
	// to get to user space.

	// set S Previous Privilege mode to User.
	unsigned long x = r_sstatus();
	x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002d0a:	eff6f693          	andi	a3,a3,-257
	x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002d0e:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d12:	10069073          	csrw	sstatus,a3
	w_sstatus(x);

	// set S Exception Program Counter to the saved user pc.
	w_sepc(p->trapframe->epc);
    80002d16:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002d18:	6f18                	ld	a4,24(a4)
    80002d1a:	14171073          	csrw	sepc,a4

	// tell trampoline.S the user page table to switch to.
	uint64 satp = MAKE_SATP(p->pagetable);
    80002d1e:	6d28                	ld	a0,88(a0)
    80002d20:	8131                	srli	a0,a0,0xc

	// jump to userret in trampoline.S at the top of memory, which
	// switches to the user page table, restores user registers,
	// and switches to user mode with sret.
	uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002d22:	00004717          	auipc	a4,0x4
    80002d26:	37a70713          	addi	a4,a4,890 # 8000709c <userret>
    80002d2a:	8f11                	sub	a4,a4,a2
    80002d2c:	97ba                	add	a5,a5,a4
	((void (*)(uint64))trampoline_userret)(satp);
    80002d2e:	577d                	li	a4,-1
    80002d30:	177e                	slli	a4,a4,0x3f
    80002d32:	8d59                	or	a0,a0,a4
    80002d34:	9782                	jalr	a5
}
    80002d36:	60a2                	ld	ra,8(sp)
    80002d38:	6402                	ld	s0,0(sp)
    80002d3a:	0141                	addi	sp,sp,16
    80002d3c:	8082                	ret

0000000080002d3e <clockintr>:
	w_sepc(sepc);
	w_sstatus(sstatus);
}

void clockintr()
{
    80002d3e:	1101                	addi	sp,sp,-32
    80002d40:	ec06                	sd	ra,24(sp)
    80002d42:	e822                	sd	s0,16(sp)
    80002d44:	e426                	sd	s1,8(sp)
    80002d46:	e04a                	sd	s2,0(sp)
    80002d48:	1000                	addi	s0,sp,32
	acquire(&tickslock);
    80002d4a:	00236917          	auipc	s2,0x236
    80002d4e:	96e90913          	addi	s2,s2,-1682 # 802386b8 <tickslock>
    80002d52:	854a                	mv	a0,s2
    80002d54:	ffffe097          	auipc	ra,0xffffe
    80002d58:	054080e7          	jalr	84(ra) # 80000da8 <acquire>
	ticks++;
    80002d5c:	00006497          	auipc	s1,0x6
    80002d60:	ea448493          	addi	s1,s1,-348 # 80008c00 <ticks>
    80002d64:	409c                	lw	a5,0(s1)
    80002d66:	2785                	addiw	a5,a5,1
    80002d68:	c09c                	sw	a5,0(s1)
	upd_time();
    80002d6a:	fffff097          	auipc	ra,0xfffff
    80002d6e:	48c080e7          	jalr	1164(ra) # 800021f6 <upd_time>
	wakeup(&ticks);
    80002d72:	8526                	mv	a0,s1
    80002d74:	00000097          	auipc	ra,0x0
    80002d78:	9b2080e7          	jalr	-1614(ra) # 80002726 <wakeup>
	release(&tickslock);
    80002d7c:	854a                	mv	a0,s2
    80002d7e:	ffffe097          	auipc	ra,0xffffe
    80002d82:	0de080e7          	jalr	222(ra) # 80000e5c <release>
}
    80002d86:	60e2                	ld	ra,24(sp)
    80002d88:	6442                	ld	s0,16(sp)
    80002d8a:	64a2                	ld	s1,8(sp)
    80002d8c:	6902                	ld	s2,0(sp)
    80002d8e:	6105                	addi	sp,sp,32
    80002d90:	8082                	ret

0000000080002d92 <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    80002d92:	1101                	addi	sp,sp,-32
    80002d94:	ec06                	sd	ra,24(sp)
    80002d96:	e822                	sd	s0,16(sp)
    80002d98:	e426                	sd	s1,8(sp)
    80002d9a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d9c:	14202773          	csrr	a4,scause
	uint64 scause = r_scause();

	if ((scause & 0x8000000000000000L) &&
    80002da0:	00074d63          	bltz	a4,80002dba <devintr+0x28>
		if (irq)
			plic_complete(irq);

		return 1;
	}
	else if (scause == 0x8000000000000001L)
    80002da4:	57fd                	li	a5,-1
    80002da6:	17fe                	slli	a5,a5,0x3f
    80002da8:	0785                	addi	a5,a5,1

		return 2;
	}
	else
	{
		return 0;
    80002daa:	4501                	li	a0,0
	else if (scause == 0x8000000000000001L)
    80002dac:	06f70363          	beq	a4,a5,80002e12 <devintr+0x80>
	}
}
    80002db0:	60e2                	ld	ra,24(sp)
    80002db2:	6442                	ld	s0,16(sp)
    80002db4:	64a2                	ld	s1,8(sp)
    80002db6:	6105                	addi	sp,sp,32
    80002db8:	8082                	ret
		(scause & 0xff) == 9)
    80002dba:	0ff77793          	andi	a5,a4,255
	if ((scause & 0x8000000000000000L) &&
    80002dbe:	46a5                	li	a3,9
    80002dc0:	fed792e3          	bne	a5,a3,80002da4 <devintr+0x12>
		int irq = plic_claim();
    80002dc4:	00003097          	auipc	ra,0x3
    80002dc8:	794080e7          	jalr	1940(ra) # 80006558 <plic_claim>
    80002dcc:	84aa                	mv	s1,a0
		if (irq == UART0_IRQ)
    80002dce:	47a9                	li	a5,10
    80002dd0:	02f50763          	beq	a0,a5,80002dfe <devintr+0x6c>
		else if (irq == VIRTIO0_IRQ)
    80002dd4:	4785                	li	a5,1
    80002dd6:	02f50963          	beq	a0,a5,80002e08 <devintr+0x76>
		return 1;
    80002dda:	4505                	li	a0,1
		else if (irq)
    80002ddc:	d8f1                	beqz	s1,80002db0 <devintr+0x1e>
			printf("unexpected interrupt irq=%d\n", irq);
    80002dde:	85a6                	mv	a1,s1
    80002de0:	00005517          	auipc	a0,0x5
    80002de4:	56850513          	addi	a0,a0,1384 # 80008348 <states.2502+0x38>
    80002de8:	ffffd097          	auipc	ra,0xffffd
    80002dec:	7a6080e7          	jalr	1958(ra) # 8000058e <printf>
			plic_complete(irq);
    80002df0:	8526                	mv	a0,s1
    80002df2:	00003097          	auipc	ra,0x3
    80002df6:	78a080e7          	jalr	1930(ra) # 8000657c <plic_complete>
		return 1;
    80002dfa:	4505                	li	a0,1
    80002dfc:	bf55                	j	80002db0 <devintr+0x1e>
			uartintr();
    80002dfe:	ffffe097          	auipc	ra,0xffffe
    80002e02:	bb0080e7          	jalr	-1104(ra) # 800009ae <uartintr>
    80002e06:	b7ed                	j	80002df0 <devintr+0x5e>
			virtio_disk_intr();
    80002e08:	00004097          	auipc	ra,0x4
    80002e0c:	c9e080e7          	jalr	-866(ra) # 80006aa6 <virtio_disk_intr>
    80002e10:	b7c5                	j	80002df0 <devintr+0x5e>
		if (cpuid() == 0)
    80002e12:	fffff097          	auipc	ra,0xfffff
    80002e16:	e7a080e7          	jalr	-390(ra) # 80001c8c <cpuid>
    80002e1a:	c901                	beqz	a0,80002e2a <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002e1c:	144027f3          	csrr	a5,sip
		w_sip(r_sip() & ~2);
    80002e20:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002e22:	14479073          	csrw	sip,a5
		return 2;
    80002e26:	4509                	li	a0,2
    80002e28:	b761                	j	80002db0 <devintr+0x1e>
			clockintr();
    80002e2a:	00000097          	auipc	ra,0x0
    80002e2e:	f14080e7          	jalr	-236(ra) # 80002d3e <clockintr>
    80002e32:	b7ed                	j	80002e1c <devintr+0x8a>

0000000080002e34 <usertrap>:
{
    80002e34:	1101                	addi	sp,sp,-32
    80002e36:	ec06                	sd	ra,24(sp)
    80002e38:	e822                	sd	s0,16(sp)
    80002e3a:	e426                	sd	s1,8(sp)
    80002e3c:	e04a                	sd	s2,0(sp)
    80002e3e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e40:	100027f3          	csrr	a5,sstatus
	if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002e44:	1007f793          	andi	a5,a5,256
    80002e48:	efad                	bnez	a5,80002ec2 <usertrap+0x8e>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002e4a:	00003797          	auipc	a5,0x3
    80002e4e:	60678793          	addi	a5,a5,1542 # 80006450 <kernelvec>
    80002e52:	10579073          	csrw	stvec,a5
	struct proc *p = myproc();
    80002e56:	fffff097          	auipc	ra,0xfffff
    80002e5a:	e62080e7          	jalr	-414(ra) # 80001cb8 <myproc>
    80002e5e:	84aa                	mv	s1,a0
	p->trapframe->epc = r_sepc();
    80002e60:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e62:	14102773          	csrr	a4,sepc
    80002e66:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e68:	14202773          	csrr	a4,scause
	if (r_scause() == 8)
    80002e6c:	47a1                	li	a5,8
    80002e6e:	06f70263          	beq	a4,a5,80002ed2 <usertrap+0x9e>
    80002e72:	14202773          	csrr	a4,scause
	else if (r_scause() == 15)
    80002e76:	47bd                	li	a5,15
    80002e78:	0af71363          	bne	a4,a5,80002f1e <usertrap+0xea>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002e7c:	14302973          	csrr	s2,stval
		if (addr >= MAXVA || (addr < p->trapframe->sp && addr >= (p->trapframe->sp - PGSIZE)))
    80002e80:	57fd                	li	a5,-1
    80002e82:	83e9                	srli	a5,a5,0x1a
    80002e84:	0127ea63          	bltu	a5,s2,80002e98 <usertrap+0x64>
    80002e88:	713c                	ld	a5,96(a0)
    80002e8a:	7b9c                	ld	a5,48(a5)
    80002e8c:	00f97b63          	bgeu	s2,a5,80002ea2 <usertrap+0x6e>
    80002e90:	777d                	lui	a4,0xfffff
    80002e92:	97ba                	add	a5,a5,a4
    80002e94:	00f96763          	bltu	s2,a5,80002ea2 <usertrap+0x6e>
			setkilled(p);
    80002e98:	8526                	mv	a0,s1
    80002e9a:	00000097          	auipc	ra,0x0
    80002e9e:	afc080e7          	jalr	-1284(ra) # 80002996 <setkilled>
		if (cowalloc(p->pagetable, PGROUNDDOWN(addr)) < 0)
    80002ea2:	75fd                	lui	a1,0xfffff
    80002ea4:	00b975b3          	and	a1,s2,a1
    80002ea8:	6ca8                	ld	a0,88(s1)
    80002eaa:	00000097          	auipc	ra,0x0
    80002eae:	d60080e7          	jalr	-672(ra) # 80002c0a <cowalloc>
    80002eb2:	04055063          	bgez	a0,80002ef2 <usertrap+0xbe>
			setkilled(p);
    80002eb6:	8526                	mv	a0,s1
    80002eb8:	00000097          	auipc	ra,0x0
    80002ebc:	ade080e7          	jalr	-1314(ra) # 80002996 <setkilled>
    80002ec0:	a80d                	j	80002ef2 <usertrap+0xbe>
		panic("usertrap: not from user mode");
    80002ec2:	00005517          	auipc	a0,0x5
    80002ec6:	4a650513          	addi	a0,a0,1190 # 80008368 <states.2502+0x58>
    80002eca:	ffffd097          	auipc	ra,0xffffd
    80002ece:	67a080e7          	jalr	1658(ra) # 80000544 <panic>
		if (p->killed)
    80002ed2:	591c                	lw	a5,48(a0)
    80002ed4:	ef9d                	bnez	a5,80002f12 <usertrap+0xde>
		p->trapframe->epc += 4;
    80002ed6:	70b8                	ld	a4,96(s1)
    80002ed8:	6f1c                	ld	a5,24(a4)
    80002eda:	0791                	addi	a5,a5,4
    80002edc:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ede:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002ee2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ee6:	10079073          	csrw	sstatus,a5
		syscall();
    80002eea:	00000097          	auipc	ra,0x0
    80002eee:	2ee080e7          	jalr	750(ra) # 800031d8 <syscall>
	if (killed(p))
    80002ef2:	8526                	mv	a0,s1
    80002ef4:	00000097          	auipc	ra,0x0
    80002ef8:	ad8080e7          	jalr	-1320(ra) # 800029cc <killed>
    80002efc:	e93d                	bnez	a0,80002f72 <usertrap+0x13e>
	usertrapret();
    80002efe:	00000097          	auipc	ra,0x0
    80002f02:	daa080e7          	jalr	-598(ra) # 80002ca8 <usertrapret>
}
    80002f06:	60e2                	ld	ra,24(sp)
    80002f08:	6442                	ld	s0,16(sp)
    80002f0a:	64a2                	ld	s1,8(sp)
    80002f0c:	6902                	ld	s2,0(sp)
    80002f0e:	6105                	addi	sp,sp,32
    80002f10:	8082                	ret
			exit(-1);
    80002f12:	557d                	li	a0,-1
    80002f14:	00000097          	auipc	ra,0x0
    80002f18:	912080e7          	jalr	-1774(ra) # 80002826 <exit>
    80002f1c:	bf6d                	j	80002ed6 <usertrap+0xa2>
	else if ((which_dev = devintr()) != 0)
    80002f1e:	00000097          	auipc	ra,0x0
    80002f22:	e74080e7          	jalr	-396(ra) # 80002d92 <devintr>
    80002f26:	892a                	mv	s2,a0
    80002f28:	c901                	beqz	a0,80002f38 <usertrap+0x104>
	if (killed(p))
    80002f2a:	8526                	mv	a0,s1
    80002f2c:	00000097          	auipc	ra,0x0
    80002f30:	aa0080e7          	jalr	-1376(ra) # 800029cc <killed>
    80002f34:	c529                	beqz	a0,80002f7e <usertrap+0x14a>
    80002f36:	a83d                	j	80002f74 <usertrap+0x140>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f38:	142025f3          	csrr	a1,scause
		printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002f3c:	5c90                	lw	a2,56(s1)
    80002f3e:	00005517          	auipc	a0,0x5
    80002f42:	44a50513          	addi	a0,a0,1098 # 80008388 <states.2502+0x78>
    80002f46:	ffffd097          	auipc	ra,0xffffd
    80002f4a:	648080e7          	jalr	1608(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002f4e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002f52:	14302673          	csrr	a2,stval
		printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002f56:	00005517          	auipc	a0,0x5
    80002f5a:	46250513          	addi	a0,a0,1122 # 800083b8 <states.2502+0xa8>
    80002f5e:	ffffd097          	auipc	ra,0xffffd
    80002f62:	630080e7          	jalr	1584(ra) # 8000058e <printf>
		setkilled(p);
    80002f66:	8526                	mv	a0,s1
    80002f68:	00000097          	auipc	ra,0x0
    80002f6c:	a2e080e7          	jalr	-1490(ra) # 80002996 <setkilled>
    80002f70:	b749                	j	80002ef2 <usertrap+0xbe>
	if (killed(p))
    80002f72:	4901                	li	s2,0
		exit(-1);
    80002f74:	557d                	li	a0,-1
    80002f76:	00000097          	auipc	ra,0x0
    80002f7a:	8b0080e7          	jalr	-1872(ra) # 80002826 <exit>
	if (which_dev == 2)
    80002f7e:	4789                	li	a5,2
    80002f80:	f6f91fe3          	bne	s2,a5,80002efe <usertrap+0xca>
		yield();
    80002f84:	fffff097          	auipc	ra,0xfffff
    80002f88:	45e080e7          	jalr	1118(ra) # 800023e2 <yield>
    80002f8c:	bf8d                	j	80002efe <usertrap+0xca>

0000000080002f8e <kerneltrap>:
{
    80002f8e:	7179                	addi	sp,sp,-48
    80002f90:	f406                	sd	ra,40(sp)
    80002f92:	f022                	sd	s0,32(sp)
    80002f94:	ec26                	sd	s1,24(sp)
    80002f96:	e84a                	sd	s2,16(sp)
    80002f98:	e44e                	sd	s3,8(sp)
    80002f9a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002f9c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002fa0:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002fa4:	142029f3          	csrr	s3,scause
	if ((sstatus & SSTATUS_SPP) == 0)
    80002fa8:	1004f793          	andi	a5,s1,256
    80002fac:	cb85                	beqz	a5,80002fdc <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002fae:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002fb2:	8b89                	andi	a5,a5,2
	if (intr_get() != 0)
    80002fb4:	ef85                	bnez	a5,80002fec <kerneltrap+0x5e>
	if ((which_dev = devintr()) == 0)
    80002fb6:	00000097          	auipc	ra,0x0
    80002fba:	ddc080e7          	jalr	-548(ra) # 80002d92 <devintr>
    80002fbe:	cd1d                	beqz	a0,80002ffc <kerneltrap+0x6e>
	if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002fc0:	4789                	li	a5,2
    80002fc2:	06f50a63          	beq	a0,a5,80003036 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002fc6:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002fca:	10049073          	csrw	sstatus,s1
}
    80002fce:	70a2                	ld	ra,40(sp)
    80002fd0:	7402                	ld	s0,32(sp)
    80002fd2:	64e2                	ld	s1,24(sp)
    80002fd4:	6942                	ld	s2,16(sp)
    80002fd6:	69a2                	ld	s3,8(sp)
    80002fd8:	6145                	addi	sp,sp,48
    80002fda:	8082                	ret
		panic("kerneltrap: not from supervisor mode");
    80002fdc:	00005517          	auipc	a0,0x5
    80002fe0:	3fc50513          	addi	a0,a0,1020 # 800083d8 <states.2502+0xc8>
    80002fe4:	ffffd097          	auipc	ra,0xffffd
    80002fe8:	560080e7          	jalr	1376(ra) # 80000544 <panic>
		panic("kerneltrap: interrupts enabled");
    80002fec:	00005517          	auipc	a0,0x5
    80002ff0:	41450513          	addi	a0,a0,1044 # 80008400 <states.2502+0xf0>
    80002ff4:	ffffd097          	auipc	ra,0xffffd
    80002ff8:	550080e7          	jalr	1360(ra) # 80000544 <panic>
		printf("scause %p\n", scause);
    80002ffc:	85ce                	mv	a1,s3
    80002ffe:	00005517          	auipc	a0,0x5
    80003002:	42250513          	addi	a0,a0,1058 # 80008420 <states.2502+0x110>
    80003006:	ffffd097          	auipc	ra,0xffffd
    8000300a:	588080e7          	jalr	1416(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000300e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003012:	14302673          	csrr	a2,stval
		printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003016:	00005517          	auipc	a0,0x5
    8000301a:	41a50513          	addi	a0,a0,1050 # 80008430 <states.2502+0x120>
    8000301e:	ffffd097          	auipc	ra,0xffffd
    80003022:	570080e7          	jalr	1392(ra) # 8000058e <printf>
		panic("kerneltrap");
    80003026:	00005517          	auipc	a0,0x5
    8000302a:	42250513          	addi	a0,a0,1058 # 80008448 <states.2502+0x138>
    8000302e:	ffffd097          	auipc	ra,0xffffd
    80003032:	516080e7          	jalr	1302(ra) # 80000544 <panic>
	if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003036:	fffff097          	auipc	ra,0xfffff
    8000303a:	c82080e7          	jalr	-894(ra) # 80001cb8 <myproc>
    8000303e:	d541                	beqz	a0,80002fc6 <kerneltrap+0x38>
    80003040:	fffff097          	auipc	ra,0xfffff
    80003044:	c78080e7          	jalr	-904(ra) # 80001cb8 <myproc>
    80003048:	5118                	lw	a4,32(a0)
    8000304a:	4791                	li	a5,4
    8000304c:	f6f71de3          	bne	a4,a5,80002fc6 <kerneltrap+0x38>
		yield();
    80003050:	fffff097          	auipc	ra,0xfffff
    80003054:	392080e7          	jalr	914(ra) # 800023e2 <yield>
    80003058:	b7bd                	j	80002fc6 <kerneltrap+0x38>

000000008000305a <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000305a:	1101                	addi	sp,sp,-32
    8000305c:	ec06                	sd	ra,24(sp)
    8000305e:	e822                	sd	s0,16(sp)
    80003060:	e426                	sd	s1,8(sp)
    80003062:	1000                	addi	s0,sp,32
    80003064:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80003066:	fffff097          	auipc	ra,0xfffff
    8000306a:	c52080e7          	jalr	-942(ra) # 80001cb8 <myproc>
  switch (n)
    8000306e:	4795                	li	a5,5
    80003070:	0497e163          	bltu	a5,s1,800030b2 <argraw+0x58>
    80003074:	048a                	slli	s1,s1,0x2
    80003076:	00005717          	auipc	a4,0x5
    8000307a:	51a70713          	addi	a4,a4,1306 # 80008590 <states.2502+0x280>
    8000307e:	94ba                	add	s1,s1,a4
    80003080:	409c                	lw	a5,0(s1)
    80003082:	97ba                	add	a5,a5,a4
    80003084:	8782                	jr	a5
  {
  case 0:
    return p->trapframe->a0;
    80003086:	713c                	ld	a5,96(a0)
    80003088:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000308a:	60e2                	ld	ra,24(sp)
    8000308c:	6442                	ld	s0,16(sp)
    8000308e:	64a2                	ld	s1,8(sp)
    80003090:	6105                	addi	sp,sp,32
    80003092:	8082                	ret
    return p->trapframe->a1;
    80003094:	713c                	ld	a5,96(a0)
    80003096:	7fa8                	ld	a0,120(a5)
    80003098:	bfcd                	j	8000308a <argraw+0x30>
    return p->trapframe->a2;
    8000309a:	713c                	ld	a5,96(a0)
    8000309c:	63c8                	ld	a0,128(a5)
    8000309e:	b7f5                	j	8000308a <argraw+0x30>
    return p->trapframe->a3;
    800030a0:	713c                	ld	a5,96(a0)
    800030a2:	67c8                	ld	a0,136(a5)
    800030a4:	b7dd                	j	8000308a <argraw+0x30>
    return p->trapframe->a4;
    800030a6:	713c                	ld	a5,96(a0)
    800030a8:	6bc8                	ld	a0,144(a5)
    800030aa:	b7c5                	j	8000308a <argraw+0x30>
    return p->trapframe->a5;
    800030ac:	713c                	ld	a5,96(a0)
    800030ae:	6fc8                	ld	a0,152(a5)
    800030b0:	bfe9                	j	8000308a <argraw+0x30>
  panic("argraw");
    800030b2:	00005517          	auipc	a0,0x5
    800030b6:	3a650513          	addi	a0,a0,934 # 80008458 <states.2502+0x148>
    800030ba:	ffffd097          	auipc	ra,0xffffd
    800030be:	48a080e7          	jalr	1162(ra) # 80000544 <panic>

00000000800030c2 <fetchaddr>:
{
    800030c2:	1101                	addi	sp,sp,-32
    800030c4:	ec06                	sd	ra,24(sp)
    800030c6:	e822                	sd	s0,16(sp)
    800030c8:	e426                	sd	s1,8(sp)
    800030ca:	e04a                	sd	s2,0(sp)
    800030cc:	1000                	addi	s0,sp,32
    800030ce:	84aa                	mv	s1,a0
    800030d0:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800030d2:	fffff097          	auipc	ra,0xfffff
    800030d6:	be6080e7          	jalr	-1050(ra) # 80001cb8 <myproc>
  if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800030da:	693c                	ld	a5,80(a0)
    800030dc:	02f4f863          	bgeu	s1,a5,8000310c <fetchaddr+0x4a>
    800030e0:	00848713          	addi	a4,s1,8
    800030e4:	02e7e663          	bltu	a5,a4,80003110 <fetchaddr+0x4e>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800030e8:	46a1                	li	a3,8
    800030ea:	8626                	mv	a2,s1
    800030ec:	85ca                	mv	a1,s2
    800030ee:	6d28                	ld	a0,88(a0)
    800030f0:	fffff097          	auipc	ra,0xfffff
    800030f4:	808080e7          	jalr	-2040(ra) # 800018f8 <copyin>
    800030f8:	00a03533          	snez	a0,a0
    800030fc:	40a00533          	neg	a0,a0
}
    80003100:	60e2                	ld	ra,24(sp)
    80003102:	6442                	ld	s0,16(sp)
    80003104:	64a2                	ld	s1,8(sp)
    80003106:	6902                	ld	s2,0(sp)
    80003108:	6105                	addi	sp,sp,32
    8000310a:	8082                	ret
    return -1;
    8000310c:	557d                	li	a0,-1
    8000310e:	bfcd                	j	80003100 <fetchaddr+0x3e>
    80003110:	557d                	li	a0,-1
    80003112:	b7fd                	j	80003100 <fetchaddr+0x3e>

0000000080003114 <fetchstr>:
{
    80003114:	7179                	addi	sp,sp,-48
    80003116:	f406                	sd	ra,40(sp)
    80003118:	f022                	sd	s0,32(sp)
    8000311a:	ec26                	sd	s1,24(sp)
    8000311c:	e84a                	sd	s2,16(sp)
    8000311e:	e44e                	sd	s3,8(sp)
    80003120:	1800                	addi	s0,sp,48
    80003122:	892a                	mv	s2,a0
    80003124:	84ae                	mv	s1,a1
    80003126:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80003128:	fffff097          	auipc	ra,0xfffff
    8000312c:	b90080e7          	jalr	-1136(ra) # 80001cb8 <myproc>
  if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80003130:	86ce                	mv	a3,s3
    80003132:	864a                	mv	a2,s2
    80003134:	85a6                	mv	a1,s1
    80003136:	6d28                	ld	a0,88(a0)
    80003138:	fffff097          	auipc	ra,0xfffff
    8000313c:	84c080e7          	jalr	-1972(ra) # 80001984 <copyinstr>
    80003140:	00054e63          	bltz	a0,8000315c <fetchstr+0x48>
  return strlen(buf);
    80003144:	8526                	mv	a0,s1
    80003146:	ffffe097          	auipc	ra,0xffffe
    8000314a:	ee2080e7          	jalr	-286(ra) # 80001028 <strlen>
}
    8000314e:	70a2                	ld	ra,40(sp)
    80003150:	7402                	ld	s0,32(sp)
    80003152:	64e2                	ld	s1,24(sp)
    80003154:	6942                	ld	s2,16(sp)
    80003156:	69a2                	ld	s3,8(sp)
    80003158:	6145                	addi	sp,sp,48
    8000315a:	8082                	ret
    return -1;
    8000315c:	557d                	li	a0,-1
    8000315e:	bfc5                	j	8000314e <fetchstr+0x3a>

0000000080003160 <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80003160:	1101                	addi	sp,sp,-32
    80003162:	ec06                	sd	ra,24(sp)
    80003164:	e822                	sd	s0,16(sp)
    80003166:	e426                	sd	s1,8(sp)
    80003168:	1000                	addi	s0,sp,32
    8000316a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000316c:	00000097          	auipc	ra,0x0
    80003170:	eee080e7          	jalr	-274(ra) # 8000305a <argraw>
    80003174:	c088                	sw	a0,0(s1)
}
    80003176:	60e2                	ld	ra,24(sp)
    80003178:	6442                	ld	s0,16(sp)
    8000317a:	64a2                	ld	s1,8(sp)
    8000317c:	6105                	addi	sp,sp,32
    8000317e:	8082                	ret

0000000080003180 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80003180:	1101                	addi	sp,sp,-32
    80003182:	ec06                	sd	ra,24(sp)
    80003184:	e822                	sd	s0,16(sp)
    80003186:	e426                	sd	s1,8(sp)
    80003188:	1000                	addi	s0,sp,32
    8000318a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000318c:	00000097          	auipc	ra,0x0
    80003190:	ece080e7          	jalr	-306(ra) # 8000305a <argraw>
    80003194:	e088                	sd	a0,0(s1)
}
    80003196:	60e2                	ld	ra,24(sp)
    80003198:	6442                	ld	s0,16(sp)
    8000319a:	64a2                	ld	s1,8(sp)
    8000319c:	6105                	addi	sp,sp,32
    8000319e:	8082                	ret

00000000800031a0 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    800031a0:	7179                	addi	sp,sp,-48
    800031a2:	f406                	sd	ra,40(sp)
    800031a4:	f022                	sd	s0,32(sp)
    800031a6:	ec26                	sd	s1,24(sp)
    800031a8:	e84a                	sd	s2,16(sp)
    800031aa:	1800                	addi	s0,sp,48
    800031ac:	84ae                	mv	s1,a1
    800031ae:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    800031b0:	fd840593          	addi	a1,s0,-40
    800031b4:	00000097          	auipc	ra,0x0
    800031b8:	fcc080e7          	jalr	-52(ra) # 80003180 <argaddr>
  return fetchstr(addr, buf, max);
    800031bc:	864a                	mv	a2,s2
    800031be:	85a6                	mv	a1,s1
    800031c0:	fd843503          	ld	a0,-40(s0)
    800031c4:	00000097          	auipc	ra,0x0
    800031c8:	f50080e7          	jalr	-176(ra) # 80003114 <fetchstr>
}
    800031cc:	70a2                	ld	ra,40(sp)
    800031ce:	7402                	ld	s0,32(sp)
    800031d0:	64e2                	ld	s1,24(sp)
    800031d2:	6942                	ld	s2,16(sp)
    800031d4:	6145                	addi	sp,sp,48
    800031d6:	8082                	ret

00000000800031d8 <syscall>:
    {"settickets", 1},
    {"waitx",3}
};

void syscall(void)
{
    800031d8:	711d                	addi	sp,sp,-96
    800031da:	ec86                	sd	ra,88(sp)
    800031dc:	e8a2                	sd	s0,80(sp)
    800031de:	e4a6                	sd	s1,72(sp)
    800031e0:	e0ca                	sd	s2,64(sp)
    800031e2:	fc4e                	sd	s3,56(sp)
    800031e4:	f852                	sd	s4,48(sp)
    800031e6:	f456                	sd	s5,40(sp)
    800031e8:	f05a                	sd	s6,32(sp)
    800031ea:	ec5e                	sd	s7,24(sp)
    800031ec:	e862                	sd	s8,16(sp)
    800031ee:	e466                	sd	s9,8(sp)
    800031f0:	e06a                	sd	s10,0(sp)
    800031f2:	1080                	addi	s0,sp,96
  int num;
  struct proc *p = myproc();
    800031f4:	fffff097          	auipc	ra,0xfffff
    800031f8:	ac4080e7          	jalr	-1340(ra) # 80001cb8 <myproc>
    800031fc:	8a2a                	mv	s4,a0

  num = p->trapframe->a7; // return reg
    800031fe:	7124                	ld	s1,96(a0)
    80003200:	74dc                	ld	a5,168(s1)
    80003202:	00078b1b          	sext.w	s6,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    80003206:	37fd                	addiw	a5,a5,-1
    80003208:	4765                	li	a4,25
    8000320a:	06f76f63          	bltu	a4,a5,80003288 <syscall+0xb0>
    8000320e:	003b1713          	slli	a4,s6,0x3
    80003212:	00005797          	auipc	a5,0x5
    80003216:	39678793          	addi	a5,a5,918 # 800085a8 <syscalls>
    8000321a:	97ba                	add	a5,a5,a4
    8000321c:	0007bd03          	ld	s10,0(a5)
    80003220:	060d0463          	beqz	s10,80003288 <syscall+0xb0>
  {
    80003224:	8c8a                	mv	s9,sp
    int numargs = syscall_info[num - 1].num;
    80003226:	fffb0c1b          	addiw	s8,s6,-1
    8000322a:	004c1713          	slli	a4,s8,0x4
    8000322e:	00005797          	auipc	a5,0x5
    80003232:	7da78793          	addi	a5,a5,2010 # 80008a08 <syscall_info>
    80003236:	97ba                	add	a5,a5,a4
    80003238:	0087a983          	lw	s3,8(a5)
    int Args[numargs]; // to store value of registers acc to the number of args of the syscall
    8000323c:	00299793          	slli	a5,s3,0x2
    80003240:	07bd                	addi	a5,a5,15
    80003242:	9bc1                	andi	a5,a5,-16
    80003244:	40f10133          	sub	sp,sp,a5
    80003248:	8b8a                	mv	s7,sp
    int j = 0;
    while (j < numargs)
    8000324a:	11305363          	blez	s3,80003350 <syscall+0x178>
    8000324e:	8ade                	mv	s5,s7
    80003250:	895e                	mv	s2,s7
    int j = 0;
    80003252:	4481                	li	s1,0
    {
      Args[j] = argraw(j);
    80003254:	8526                	mv	a0,s1
    80003256:	00000097          	auipc	ra,0x0
    8000325a:	e04080e7          	jalr	-508(ra) # 8000305a <argraw>
    8000325e:	00a92023          	sw	a0,0(s2)
      j++;
    80003262:	2485                	addiw	s1,s1,1
    while (j < numargs)
    80003264:	0911                	addi	s2,s2,4
    80003266:	fe9997e3          	bne	s3,s1,80003254 <syscall+0x7c>
    }

    int shift = 1 << num; // mask for num
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    8000326a:	060a3483          	ld	s1,96(s4)
    8000326e:	9d02                	jalr	s10
    80003270:	f8a8                	sd	a0,112(s1)
    int shift = 1 << num; // mask for num
    80003272:	4785                	li	a5,1
    80003274:	016797bb          	sllw	a5,a5,s6

    if (p->mask & shift)
    80003278:	000a2b03          	lw	s6,0(s4)
    8000327c:	0167f7b3          	and	a5,a5,s6
    80003280:	2781                	sext.w	a5,a5
    80003282:	e7a1                	bnez	a5,800032ca <syscall+0xf2>
    80003284:	8166                	mv	sp,s9
  {
    80003286:	a015                	j	800032aa <syscall+0xd2>
      printf(" -> %d\n", p->trapframe->a0);
    }
  }
  else
  {
    printf("%d %s: unknown sys call %d\n",
    80003288:	86da                	mv	a3,s6
    8000328a:	160a0613          	addi	a2,s4,352
    8000328e:	038a2583          	lw	a1,56(s4)
    80003292:	00005517          	auipc	a0,0x5
    80003296:	1e650513          	addi	a0,a0,486 # 80008478 <states.2502+0x168>
    8000329a:	ffffd097          	auipc	ra,0xffffd
    8000329e:	2f4080e7          	jalr	756(ra) # 8000058e <printf>
           p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800032a2:	060a3783          	ld	a5,96(s4)
    800032a6:	577d                	li	a4,-1
    800032a8:	fbb8                	sd	a4,112(a5)
  }
}
    800032aa:	fa040113          	addi	sp,s0,-96
    800032ae:	60e6                	ld	ra,88(sp)
    800032b0:	6446                	ld	s0,80(sp)
    800032b2:	64a6                	ld	s1,72(sp)
    800032b4:	6906                	ld	s2,64(sp)
    800032b6:	79e2                	ld	s3,56(sp)
    800032b8:	7a42                	ld	s4,48(sp)
    800032ba:	7aa2                	ld	s5,40(sp)
    800032bc:	7b02                	ld	s6,32(sp)
    800032be:	6be2                	ld	s7,24(sp)
    800032c0:	6c42                	ld	s8,16(sp)
    800032c2:	6ca2                	ld	s9,8(sp)
    800032c4:	6d02                	ld	s10,0(sp)
    800032c6:	6125                	addi	sp,sp,96
    800032c8:	8082                	ret
      printf("%d: syscall %s ", p->pid, syscall_info[num - 1].name);
    800032ca:	0c12                	slli	s8,s8,0x4
    800032cc:	00005797          	auipc	a5,0x5
    800032d0:	73c78793          	addi	a5,a5,1852 # 80008a08 <syscall_info>
    800032d4:	9c3e                	add	s8,s8,a5
    800032d6:	000c3603          	ld	a2,0(s8)
    800032da:	038a2583          	lw	a1,56(s4)
    800032de:	00005517          	auipc	a0,0x5
    800032e2:	1ba50513          	addi	a0,a0,442 # 80008498 <states.2502+0x188>
    800032e6:	ffffd097          	auipc	ra,0xffffd
    800032ea:	2a8080e7          	jalr	680(ra) # 8000058e <printf>
      printf("(");
    800032ee:	00005517          	auipc	a0,0x5
    800032f2:	1ba50513          	addi	a0,a0,442 # 800084a8 <states.2502+0x198>
    800032f6:	ffffd097          	auipc	ra,0xffffd
    800032fa:	298080e7          	jalr	664(ra) # 8000058e <printf>
      while (i < numargs)
    800032fe:	fff9879b          	addiw	a5,s3,-1
    80003302:	1782                	slli	a5,a5,0x20
    80003304:	9381                	srli	a5,a5,0x20
    80003306:	0785                	addi	a5,a5,1
    80003308:	078a                	slli	a5,a5,0x2
    8000330a:	9bbe                	add	s7,s7,a5
        printf("%d ", Args[i]);
    8000330c:	00005497          	auipc	s1,0x5
    80003310:	15448493          	addi	s1,s1,340 # 80008460 <states.2502+0x150>
    80003314:	000aa583          	lw	a1,0(s5)
    80003318:	8526                	mv	a0,s1
    8000331a:	ffffd097          	auipc	ra,0xffffd
    8000331e:	274080e7          	jalr	628(ra) # 8000058e <printf>
      while (i < numargs)
    80003322:	0a91                	addi	s5,s5,4
    80003324:	ff7a98e3          	bne	s5,s7,80003314 <syscall+0x13c>
      printf(")");
    80003328:	00005517          	auipc	a0,0x5
    8000332c:	14050513          	addi	a0,a0,320 # 80008468 <states.2502+0x158>
    80003330:	ffffd097          	auipc	ra,0xffffd
    80003334:	25e080e7          	jalr	606(ra) # 8000058e <printf>
      printf(" -> %d\n", p->trapframe->a0);
    80003338:	060a3783          	ld	a5,96(s4)
    8000333c:	7bac                	ld	a1,112(a5)
    8000333e:	00005517          	auipc	a0,0x5
    80003342:	13250513          	addi	a0,a0,306 # 80008470 <states.2502+0x160>
    80003346:	ffffd097          	auipc	ra,0xffffd
    8000334a:	248080e7          	jalr	584(ra) # 8000058e <printf>
    8000334e:	bf1d                	j	80003284 <syscall+0xac>
    p->trapframe->a0 = syscalls[num]();
    80003350:	9d02                	jalr	s10
    80003352:	f8a8                	sd	a0,112(s1)
    int shift = 1 << num; // mask for num
    80003354:	4785                	li	a5,1
    80003356:	016797bb          	sllw	a5,a5,s6
    if (p->mask & shift)
    8000335a:	000a2703          	lw	a4,0(s4)
    8000335e:	8ff9                	and	a5,a5,a4
    80003360:	2781                	sext.w	a5,a5
    80003362:	d38d                	beqz	a5,80003284 <syscall+0xac>
      printf("%d: syscall %s ", p->pid, syscall_info[num - 1].name);
    80003364:	0c12                	slli	s8,s8,0x4
    80003366:	00005797          	auipc	a5,0x5
    8000336a:	6a278793          	addi	a5,a5,1698 # 80008a08 <syscall_info>
    8000336e:	97e2                	add	a5,a5,s8
    80003370:	6390                	ld	a2,0(a5)
    80003372:	038a2583          	lw	a1,56(s4)
    80003376:	00005517          	auipc	a0,0x5
    8000337a:	12250513          	addi	a0,a0,290 # 80008498 <states.2502+0x188>
    8000337e:	ffffd097          	auipc	ra,0xffffd
    80003382:	210080e7          	jalr	528(ra) # 8000058e <printf>
      printf("(");
    80003386:	00005517          	auipc	a0,0x5
    8000338a:	12250513          	addi	a0,a0,290 # 800084a8 <states.2502+0x198>
    8000338e:	ffffd097          	auipc	ra,0xffffd
    80003392:	200080e7          	jalr	512(ra) # 8000058e <printf>
      while (i < numargs)
    80003396:	bf49                	j	80003328 <syscall+0x150>

0000000080003398 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80003398:	1101                	addi	sp,sp,-32
    8000339a:	ec06                	sd	ra,24(sp)
    8000339c:	e822                	sd	s0,16(sp)
    8000339e:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800033a0:	fec40593          	addi	a1,s0,-20
    800033a4:	4501                	li	a0,0
    800033a6:	00000097          	auipc	ra,0x0
    800033aa:	dba080e7          	jalr	-582(ra) # 80003160 <argint>
  exit(n);
    800033ae:	fec42503          	lw	a0,-20(s0)
    800033b2:	fffff097          	auipc	ra,0xfffff
    800033b6:	474080e7          	jalr	1140(ra) # 80002826 <exit>
  return 0; // not reached
}
    800033ba:	4501                	li	a0,0
    800033bc:	60e2                	ld	ra,24(sp)
    800033be:	6442                	ld	s0,16(sp)
    800033c0:	6105                	addi	sp,sp,32
    800033c2:	8082                	ret

00000000800033c4 <sys_getpid>:

uint64
sys_getpid(void)
{
    800033c4:	1141                	addi	sp,sp,-16
    800033c6:	e406                	sd	ra,8(sp)
    800033c8:	e022                	sd	s0,0(sp)
    800033ca:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800033cc:	fffff097          	auipc	ra,0xfffff
    800033d0:	8ec080e7          	jalr	-1812(ra) # 80001cb8 <myproc>
}
    800033d4:	5d08                	lw	a0,56(a0)
    800033d6:	60a2                	ld	ra,8(sp)
    800033d8:	6402                	ld	s0,0(sp)
    800033da:	0141                	addi	sp,sp,16
    800033dc:	8082                	ret

00000000800033de <sys_fork>:

uint64
sys_fork(void)
{
    800033de:	1141                	addi	sp,sp,-16
    800033e0:	e406                	sd	ra,8(sp)
    800033e2:	e022                	sd	s0,0(sp)
    800033e4:	0800                	addi	s0,sp,16
  return fork();
    800033e6:	fffff097          	auipc	ra,0xfffff
    800033ea:	cc2080e7          	jalr	-830(ra) # 800020a8 <fork>
}
    800033ee:	60a2                	ld	ra,8(sp)
    800033f0:	6402                	ld	s0,0(sp)
    800033f2:	0141                	addi	sp,sp,16
    800033f4:	8082                	ret

00000000800033f6 <sys_wait>:

uint64
sys_wait(void)
{
    800033f6:	1101                	addi	sp,sp,-32
    800033f8:	ec06                	sd	ra,24(sp)
    800033fa:	e822                	sd	s0,16(sp)
    800033fc:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800033fe:	fe840593          	addi	a1,s0,-24
    80003402:	4501                	li	a0,0
    80003404:	00000097          	auipc	ra,0x0
    80003408:	d7c080e7          	jalr	-644(ra) # 80003180 <argaddr>
  return wait(p);
    8000340c:	fe843503          	ld	a0,-24(s0)
    80003410:	fffff097          	auipc	ra,0xfffff
    80003414:	1da080e7          	jalr	474(ra) # 800025ea <wait>
}
    80003418:	60e2                	ld	ra,24(sp)
    8000341a:	6442                	ld	s0,16(sp)
    8000341c:	6105                	addi	sp,sp,32
    8000341e:	8082                	ret

0000000080003420 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003420:	7179                	addi	sp,sp,-48
    80003422:	f406                	sd	ra,40(sp)
    80003424:	f022                	sd	s0,32(sp)
    80003426:	ec26                	sd	s1,24(sp)
    80003428:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    8000342a:	fdc40593          	addi	a1,s0,-36
    8000342e:	4501                	li	a0,0
    80003430:	00000097          	auipc	ra,0x0
    80003434:	d30080e7          	jalr	-720(ra) # 80003160 <argint>
  addr = myproc()->sz;
    80003438:	fffff097          	auipc	ra,0xfffff
    8000343c:	880080e7          	jalr	-1920(ra) # 80001cb8 <myproc>
    80003440:	6924                	ld	s1,80(a0)
  if (growproc(n) < 0)
    80003442:	fdc42503          	lw	a0,-36(s0)
    80003446:	fffff097          	auipc	ra,0xfffff
    8000344a:	c06080e7          	jalr	-1018(ra) # 8000204c <growproc>
    8000344e:	00054863          	bltz	a0,8000345e <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80003452:	8526                	mv	a0,s1
    80003454:	70a2                	ld	ra,40(sp)
    80003456:	7402                	ld	s0,32(sp)
    80003458:	64e2                	ld	s1,24(sp)
    8000345a:	6145                	addi	sp,sp,48
    8000345c:	8082                	ret
    return -1;
    8000345e:	54fd                	li	s1,-1
    80003460:	bfcd                	j	80003452 <sys_sbrk+0x32>

0000000080003462 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003462:	7139                	addi	sp,sp,-64
    80003464:	fc06                	sd	ra,56(sp)
    80003466:	f822                	sd	s0,48(sp)
    80003468:	f426                	sd	s1,40(sp)
    8000346a:	f04a                	sd	s2,32(sp)
    8000346c:	ec4e                	sd	s3,24(sp)
    8000346e:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80003470:	fcc40593          	addi	a1,s0,-52
    80003474:	4501                	li	a0,0
    80003476:	00000097          	auipc	ra,0x0
    8000347a:	cea080e7          	jalr	-790(ra) # 80003160 <argint>
  acquire(&tickslock);
    8000347e:	00235517          	auipc	a0,0x235
    80003482:	23a50513          	addi	a0,a0,570 # 802386b8 <tickslock>
    80003486:	ffffe097          	auipc	ra,0xffffe
    8000348a:	922080e7          	jalr	-1758(ra) # 80000da8 <acquire>
  ticks0 = ticks;
    8000348e:	00005917          	auipc	s2,0x5
    80003492:	77292903          	lw	s2,1906(s2) # 80008c00 <ticks>
  while (ticks - ticks0 < n)
    80003496:	fcc42783          	lw	a5,-52(s0)
    8000349a:	cf9d                	beqz	a5,800034d8 <sys_sleep+0x76>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000349c:	00235997          	auipc	s3,0x235
    800034a0:	21c98993          	addi	s3,s3,540 # 802386b8 <tickslock>
    800034a4:	00005497          	auipc	s1,0x5
    800034a8:	75c48493          	addi	s1,s1,1884 # 80008c00 <ticks>
    if (killed(myproc()))
    800034ac:	fffff097          	auipc	ra,0xfffff
    800034b0:	80c080e7          	jalr	-2036(ra) # 80001cb8 <myproc>
    800034b4:	fffff097          	auipc	ra,0xfffff
    800034b8:	518080e7          	jalr	1304(ra) # 800029cc <killed>
    800034bc:	ed15                	bnez	a0,800034f8 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    800034be:	85ce                	mv	a1,s3
    800034c0:	8526                	mv	a0,s1
    800034c2:	fffff097          	auipc	ra,0xfffff
    800034c6:	f66080e7          	jalr	-154(ra) # 80002428 <sleep>
  while (ticks - ticks0 < n)
    800034ca:	409c                	lw	a5,0(s1)
    800034cc:	412787bb          	subw	a5,a5,s2
    800034d0:	fcc42703          	lw	a4,-52(s0)
    800034d4:	fce7ece3          	bltu	a5,a4,800034ac <sys_sleep+0x4a>
  }
  release(&tickslock);
    800034d8:	00235517          	auipc	a0,0x235
    800034dc:	1e050513          	addi	a0,a0,480 # 802386b8 <tickslock>
    800034e0:	ffffe097          	auipc	ra,0xffffe
    800034e4:	97c080e7          	jalr	-1668(ra) # 80000e5c <release>
  return 0;
    800034e8:	4501                	li	a0,0
}
    800034ea:	70e2                	ld	ra,56(sp)
    800034ec:	7442                	ld	s0,48(sp)
    800034ee:	74a2                	ld	s1,40(sp)
    800034f0:	7902                	ld	s2,32(sp)
    800034f2:	69e2                	ld	s3,24(sp)
    800034f4:	6121                	addi	sp,sp,64
    800034f6:	8082                	ret
      release(&tickslock);
    800034f8:	00235517          	auipc	a0,0x235
    800034fc:	1c050513          	addi	a0,a0,448 # 802386b8 <tickslock>
    80003500:	ffffe097          	auipc	ra,0xffffe
    80003504:	95c080e7          	jalr	-1700(ra) # 80000e5c <release>
      return -1;
    80003508:	557d                	li	a0,-1
    8000350a:	b7c5                	j	800034ea <sys_sleep+0x88>

000000008000350c <sys_kill>:

uint64
sys_kill(void)
{
    8000350c:	1101                	addi	sp,sp,-32
    8000350e:	ec06                	sd	ra,24(sp)
    80003510:	e822                	sd	s0,16(sp)
    80003512:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80003514:	fec40593          	addi	a1,s0,-20
    80003518:	4501                	li	a0,0
    8000351a:	00000097          	auipc	ra,0x0
    8000351e:	c46080e7          	jalr	-954(ra) # 80003160 <argint>
  return kill(pid);
    80003522:	fec42503          	lw	a0,-20(s0)
    80003526:	fffff097          	auipc	ra,0xfffff
    8000352a:	3e4080e7          	jalr	996(ra) # 8000290a <kill>
}
    8000352e:	60e2                	ld	ra,24(sp)
    80003530:	6442                	ld	s0,16(sp)
    80003532:	6105                	addi	sp,sp,32
    80003534:	8082                	ret

0000000080003536 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003536:	1101                	addi	sp,sp,-32
    80003538:	ec06                	sd	ra,24(sp)
    8000353a:	e822                	sd	s0,16(sp)
    8000353c:	e426                	sd	s1,8(sp)
    8000353e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003540:	00235517          	auipc	a0,0x235
    80003544:	17850513          	addi	a0,a0,376 # 802386b8 <tickslock>
    80003548:	ffffe097          	auipc	ra,0xffffe
    8000354c:	860080e7          	jalr	-1952(ra) # 80000da8 <acquire>
  xticks = ticks;
    80003550:	00005497          	auipc	s1,0x5
    80003554:	6b04a483          	lw	s1,1712(s1) # 80008c00 <ticks>
  release(&tickslock);
    80003558:	00235517          	auipc	a0,0x235
    8000355c:	16050513          	addi	a0,a0,352 # 802386b8 <tickslock>
    80003560:	ffffe097          	auipc	ra,0xffffe
    80003564:	8fc080e7          	jalr	-1796(ra) # 80000e5c <release>
  return xticks;
}
    80003568:	02049513          	slli	a0,s1,0x20
    8000356c:	9101                	srli	a0,a0,0x20
    8000356e:	60e2                	ld	ra,24(sp)
    80003570:	6442                	ld	s0,16(sp)
    80003572:	64a2                	ld	s1,8(sp)
    80003574:	6105                	addi	sp,sp,32
    80003576:	8082                	ret

0000000080003578 <sys_trace>:

uint64
sys_trace(void)
{
    80003578:	1101                	addi	sp,sp,-32
    8000357a:	ec06                	sd	ra,24(sp)
    8000357c:	e822                	sd	s0,16(sp)
    8000357e:	1000                	addi	s0,sp,32
  int n; // mask
  argint(0, &n);
    80003580:	fec40593          	addi	a1,s0,-20
    80003584:	4501                	li	a0,0
    80003586:	00000097          	auipc	ra,0x0
    8000358a:	bda080e7          	jalr	-1062(ra) # 80003160 <argint>
  myproc()->mask = n;
    8000358e:	ffffe097          	auipc	ra,0xffffe
    80003592:	72a080e7          	jalr	1834(ra) # 80001cb8 <myproc>
    80003596:	fec42783          	lw	a5,-20(s0)
    8000359a:	c11c                	sw	a5,0(a0)
  return 0;
}
    8000359c:	4501                	li	a0,0
    8000359e:	60e2                	ld	ra,24(sp)
    800035a0:	6442                	ld	s0,16(sp)
    800035a2:	6105                	addi	sp,sp,32
    800035a4:	8082                	ret

00000000800035a6 <sys_sigalarm>:

uint64
sys_sigalarm(void)
{
    800035a6:	1101                	addi	sp,sp,-32
    800035a8:	ec06                	sd	ra,24(sp)
    800035aa:	e822                	sd	s0,16(sp)
    800035ac:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800035ae:	fec40593          	addi	a1,s0,-20
    800035b2:	4501                	li	a0,0
    800035b4:	00000097          	auipc	ra,0x0
    800035b8:	bac080e7          	jalr	-1108(ra) # 80003160 <argint>
  myproc()->ticks0 = 0;
    800035bc:	ffffe097          	auipc	ra,0xffffe
    800035c0:	6fc080e7          	jalr	1788(ra) # 80001cb8 <myproc>
    800035c4:	00052223          	sw	zero,4(a0)
  return 0;
}
    800035c8:	4501                	li	a0,0
    800035ca:	60e2                	ld	ra,24(sp)
    800035cc:	6442                	ld	s0,16(sp)
    800035ce:	6105                	addi	sp,sp,32
    800035d0:	8082                	ret

00000000800035d2 <sys_setpriority>:

uint64
sys_setpriority(void)
{
    800035d2:	1101                	addi	sp,sp,-32
    800035d4:	ec06                	sd	ra,24(sp)
    800035d6:	e822                	sd	s0,16(sp)
    800035d8:	1000                	addi	s0,sp,32
  int priority;
  int pid;
  argint(0, &priority);
    800035da:	fec40593          	addi	a1,s0,-20
    800035de:	4501                	li	a0,0
    800035e0:	00000097          	auipc	ra,0x0
    800035e4:	b80080e7          	jalr	-1152(ra) # 80003160 <argint>
  argint(1, &pid);
    800035e8:	fe840593          	addi	a1,s0,-24
    800035ec:	4505                	li	a0,1
    800035ee:	00000097          	auipc	ra,0x0
    800035f2:	b72080e7          	jalr	-1166(ra) # 80003160 <argint>
  return set_priority(priority, pid);
    800035f6:	fe842583          	lw	a1,-24(s0)
    800035fa:	fec42503          	lw	a0,-20(s0)
    800035fe:	ffffe097          	auipc	ra,0xffffe
    80003602:	488080e7          	jalr	1160(ra) # 80001a86 <set_priority>
}
    80003606:	60e2                	ld	ra,24(sp)
    80003608:	6442                	ld	s0,16(sp)
    8000360a:	6105                	addi	sp,sp,32
    8000360c:	8082                	ret

000000008000360e <sys_settickets>:

uint64
sys_settickets(void){
    8000360e:	1101                	addi	sp,sp,-32
    80003610:	ec06                	sd	ra,24(sp)
    80003612:	e822                	sd	s0,16(sp)
    80003614:	1000                	addi	s0,sp,32
  int n; // tickets
  argint(0, &n);
    80003616:	fec40593          	addi	a1,s0,-20
    8000361a:	4501                	li	a0,0
    8000361c:	00000097          	auipc	ra,0x0
    80003620:	b44080e7          	jalr	-1212(ra) # 80003160 <argint>
  myproc()->tickets = n;
    80003624:	ffffe097          	auipc	ra,0xffffe
    80003628:	694080e7          	jalr	1684(ra) # 80001cb8 <myproc>
    8000362c:	fec42783          	lw	a5,-20(s0)
    80003630:	16f52823          	sw	a5,368(a0)
  return 0;
}
    80003634:	4501                	li	a0,0
    80003636:	60e2                	ld	ra,24(sp)
    80003638:	6442                	ld	s0,16(sp)
    8000363a:	6105                	addi	sp,sp,32
    8000363c:	8082                	ret

000000008000363e <sys_waitx>:

uint64
sys_waitx(void)
{
    8000363e:	7139                	addi	sp,sp,-64
    80003640:	fc06                	sd	ra,56(sp)
    80003642:	f822                	sd	s0,48(sp)
    80003644:	f426                	sd	s1,40(sp)
    80003646:	f04a                	sd	s2,32(sp)
    80003648:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    8000364a:	fd840593          	addi	a1,s0,-40
    8000364e:	4501                	li	a0,0
    80003650:	00000097          	auipc	ra,0x0
    80003654:	b30080e7          	jalr	-1232(ra) # 80003180 <argaddr>
  argaddr(1, &addr1); // user virtual memory
    80003658:	fd040593          	addi	a1,s0,-48
    8000365c:	4505                	li	a0,1
    8000365e:	00000097          	auipc	ra,0x0
    80003662:	b22080e7          	jalr	-1246(ra) # 80003180 <argaddr>
  argaddr(2, &addr2);
    80003666:	fc840593          	addi	a1,s0,-56
    8000366a:	4509                	li	a0,2
    8000366c:	00000097          	auipc	ra,0x0
    80003670:	b14080e7          	jalr	-1260(ra) # 80003180 <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    80003674:	fc040613          	addi	a2,s0,-64
    80003678:	fc440593          	addi	a1,s0,-60
    8000367c:	fd843503          	ld	a0,-40(s0)
    80003680:	fffff097          	auipc	ra,0xfffff
    80003684:	e16080e7          	jalr	-490(ra) # 80002496 <waitx>
    80003688:	892a                	mv	s2,a0
  struct proc* p = myproc();
    8000368a:	ffffe097          	auipc	ra,0xffffe
    8000368e:	62e080e7          	jalr	1582(ra) # 80001cb8 <myproc>
    80003692:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    80003694:	4691                	li	a3,4
    80003696:	fc440613          	addi	a2,s0,-60
    8000369a:	fd043583          	ld	a1,-48(s0)
    8000369e:	6d28                	ld	a0,88(a0)
    800036a0:	ffffe097          	auipc	ra,0xffffe
    800036a4:	198080e7          	jalr	408(ra) # 80001838 <copyout>
    return -1;
    800036a8:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    800036aa:	00054f63          	bltz	a0,800036c8 <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2,(char*)&rtime, sizeof(int)) < 0)
    800036ae:	4691                	li	a3,4
    800036b0:	fc040613          	addi	a2,s0,-64
    800036b4:	fc843583          	ld	a1,-56(s0)
    800036b8:	6ca8                	ld	a0,88(s1)
    800036ba:	ffffe097          	auipc	ra,0xffffe
    800036be:	17e080e7          	jalr	382(ra) # 80001838 <copyout>
    800036c2:	00054a63          	bltz	a0,800036d6 <sys_waitx+0x98>
    return -1;
  return ret;
    800036c6:	87ca                	mv	a5,s2
    800036c8:	853e                	mv	a0,a5
    800036ca:	70e2                	ld	ra,56(sp)
    800036cc:	7442                	ld	s0,48(sp)
    800036ce:	74a2                	ld	s1,40(sp)
    800036d0:	7902                	ld	s2,32(sp)
    800036d2:	6121                	addi	sp,sp,64
    800036d4:	8082                	ret
    return -1;
    800036d6:	57fd                	li	a5,-1
    800036d8:	bfc5                	j	800036c8 <sys_waitx+0x8a>

00000000800036da <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800036da:	7179                	addi	sp,sp,-48
    800036dc:	f406                	sd	ra,40(sp)
    800036de:	f022                	sd	s0,32(sp)
    800036e0:	ec26                	sd	s1,24(sp)
    800036e2:	e84a                	sd	s2,16(sp)
    800036e4:	e44e                	sd	s3,8(sp)
    800036e6:	e052                	sd	s4,0(sp)
    800036e8:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800036ea:	00005597          	auipc	a1,0x5
    800036ee:	f9658593          	addi	a1,a1,-106 # 80008680 <syscalls+0xd8>
    800036f2:	00235517          	auipc	a0,0x235
    800036f6:	fde50513          	addi	a0,a0,-34 # 802386d0 <bcache>
    800036fa:	ffffd097          	auipc	ra,0xffffd
    800036fe:	61e080e7          	jalr	1566(ra) # 80000d18 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003702:	0023d797          	auipc	a5,0x23d
    80003706:	fce78793          	addi	a5,a5,-50 # 802406d0 <bcache+0x8000>
    8000370a:	0023d717          	auipc	a4,0x23d
    8000370e:	22e70713          	addi	a4,a4,558 # 80240938 <bcache+0x8268>
    80003712:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003716:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000371a:	00235497          	auipc	s1,0x235
    8000371e:	fce48493          	addi	s1,s1,-50 # 802386e8 <bcache+0x18>
    b->next = bcache.head.next;
    80003722:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003724:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003726:	00005a17          	auipc	s4,0x5
    8000372a:	f62a0a13          	addi	s4,s4,-158 # 80008688 <syscalls+0xe0>
    b->next = bcache.head.next;
    8000372e:	2b893783          	ld	a5,696(s2)
    80003732:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003734:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003738:	85d2                	mv	a1,s4
    8000373a:	01048513          	addi	a0,s1,16
    8000373e:	00001097          	auipc	ra,0x1
    80003742:	4c4080e7          	jalr	1220(ra) # 80004c02 <initsleeplock>
    bcache.head.next->prev = b;
    80003746:	2b893783          	ld	a5,696(s2)
    8000374a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000374c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003750:	45848493          	addi	s1,s1,1112
    80003754:	fd349de3          	bne	s1,s3,8000372e <binit+0x54>
  }
}
    80003758:	70a2                	ld	ra,40(sp)
    8000375a:	7402                	ld	s0,32(sp)
    8000375c:	64e2                	ld	s1,24(sp)
    8000375e:	6942                	ld	s2,16(sp)
    80003760:	69a2                	ld	s3,8(sp)
    80003762:	6a02                	ld	s4,0(sp)
    80003764:	6145                	addi	sp,sp,48
    80003766:	8082                	ret

0000000080003768 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003768:	7179                	addi	sp,sp,-48
    8000376a:	f406                	sd	ra,40(sp)
    8000376c:	f022                	sd	s0,32(sp)
    8000376e:	ec26                	sd	s1,24(sp)
    80003770:	e84a                	sd	s2,16(sp)
    80003772:	e44e                	sd	s3,8(sp)
    80003774:	1800                	addi	s0,sp,48
    80003776:	89aa                	mv	s3,a0
    80003778:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    8000377a:	00235517          	auipc	a0,0x235
    8000377e:	f5650513          	addi	a0,a0,-170 # 802386d0 <bcache>
    80003782:	ffffd097          	auipc	ra,0xffffd
    80003786:	626080e7          	jalr	1574(ra) # 80000da8 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000378a:	0023d497          	auipc	s1,0x23d
    8000378e:	1fe4b483          	ld	s1,510(s1) # 80240988 <bcache+0x82b8>
    80003792:	0023d797          	auipc	a5,0x23d
    80003796:	1a678793          	addi	a5,a5,422 # 80240938 <bcache+0x8268>
    8000379a:	02f48f63          	beq	s1,a5,800037d8 <bread+0x70>
    8000379e:	873e                	mv	a4,a5
    800037a0:	a021                	j	800037a8 <bread+0x40>
    800037a2:	68a4                	ld	s1,80(s1)
    800037a4:	02e48a63          	beq	s1,a4,800037d8 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800037a8:	449c                	lw	a5,8(s1)
    800037aa:	ff379ce3          	bne	a5,s3,800037a2 <bread+0x3a>
    800037ae:	44dc                	lw	a5,12(s1)
    800037b0:	ff2799e3          	bne	a5,s2,800037a2 <bread+0x3a>
      b->refcnt++;
    800037b4:	40bc                	lw	a5,64(s1)
    800037b6:	2785                	addiw	a5,a5,1
    800037b8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800037ba:	00235517          	auipc	a0,0x235
    800037be:	f1650513          	addi	a0,a0,-234 # 802386d0 <bcache>
    800037c2:	ffffd097          	auipc	ra,0xffffd
    800037c6:	69a080e7          	jalr	1690(ra) # 80000e5c <release>
      acquiresleep(&b->lock);
    800037ca:	01048513          	addi	a0,s1,16
    800037ce:	00001097          	auipc	ra,0x1
    800037d2:	46e080e7          	jalr	1134(ra) # 80004c3c <acquiresleep>
      return b;
    800037d6:	a8b9                	j	80003834 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800037d8:	0023d497          	auipc	s1,0x23d
    800037dc:	1a84b483          	ld	s1,424(s1) # 80240980 <bcache+0x82b0>
    800037e0:	0023d797          	auipc	a5,0x23d
    800037e4:	15878793          	addi	a5,a5,344 # 80240938 <bcache+0x8268>
    800037e8:	00f48863          	beq	s1,a5,800037f8 <bread+0x90>
    800037ec:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800037ee:	40bc                	lw	a5,64(s1)
    800037f0:	cf81                	beqz	a5,80003808 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800037f2:	64a4                	ld	s1,72(s1)
    800037f4:	fee49de3          	bne	s1,a4,800037ee <bread+0x86>
  panic("bget: no buffers");
    800037f8:	00005517          	auipc	a0,0x5
    800037fc:	e9850513          	addi	a0,a0,-360 # 80008690 <syscalls+0xe8>
    80003800:	ffffd097          	auipc	ra,0xffffd
    80003804:	d44080e7          	jalr	-700(ra) # 80000544 <panic>
      b->dev = dev;
    80003808:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    8000380c:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80003810:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003814:	4785                	li	a5,1
    80003816:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003818:	00235517          	auipc	a0,0x235
    8000381c:	eb850513          	addi	a0,a0,-328 # 802386d0 <bcache>
    80003820:	ffffd097          	auipc	ra,0xffffd
    80003824:	63c080e7          	jalr	1596(ra) # 80000e5c <release>
      acquiresleep(&b->lock);
    80003828:	01048513          	addi	a0,s1,16
    8000382c:	00001097          	auipc	ra,0x1
    80003830:	410080e7          	jalr	1040(ra) # 80004c3c <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003834:	409c                	lw	a5,0(s1)
    80003836:	cb89                	beqz	a5,80003848 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003838:	8526                	mv	a0,s1
    8000383a:	70a2                	ld	ra,40(sp)
    8000383c:	7402                	ld	s0,32(sp)
    8000383e:	64e2                	ld	s1,24(sp)
    80003840:	6942                	ld	s2,16(sp)
    80003842:	69a2                	ld	s3,8(sp)
    80003844:	6145                	addi	sp,sp,48
    80003846:	8082                	ret
    virtio_disk_rw(b, 0);
    80003848:	4581                	li	a1,0
    8000384a:	8526                	mv	a0,s1
    8000384c:	00003097          	auipc	ra,0x3
    80003850:	fcc080e7          	jalr	-52(ra) # 80006818 <virtio_disk_rw>
    b->valid = 1;
    80003854:	4785                	li	a5,1
    80003856:	c09c                	sw	a5,0(s1)
  return b;
    80003858:	b7c5                	j	80003838 <bread+0xd0>

000000008000385a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000385a:	1101                	addi	sp,sp,-32
    8000385c:	ec06                	sd	ra,24(sp)
    8000385e:	e822                	sd	s0,16(sp)
    80003860:	e426                	sd	s1,8(sp)
    80003862:	1000                	addi	s0,sp,32
    80003864:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003866:	0541                	addi	a0,a0,16
    80003868:	00001097          	auipc	ra,0x1
    8000386c:	46e080e7          	jalr	1134(ra) # 80004cd6 <holdingsleep>
    80003870:	cd01                	beqz	a0,80003888 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003872:	4585                	li	a1,1
    80003874:	8526                	mv	a0,s1
    80003876:	00003097          	auipc	ra,0x3
    8000387a:	fa2080e7          	jalr	-94(ra) # 80006818 <virtio_disk_rw>
}
    8000387e:	60e2                	ld	ra,24(sp)
    80003880:	6442                	ld	s0,16(sp)
    80003882:	64a2                	ld	s1,8(sp)
    80003884:	6105                	addi	sp,sp,32
    80003886:	8082                	ret
    panic("bwrite");
    80003888:	00005517          	auipc	a0,0x5
    8000388c:	e2050513          	addi	a0,a0,-480 # 800086a8 <syscalls+0x100>
    80003890:	ffffd097          	auipc	ra,0xffffd
    80003894:	cb4080e7          	jalr	-844(ra) # 80000544 <panic>

0000000080003898 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003898:	1101                	addi	sp,sp,-32
    8000389a:	ec06                	sd	ra,24(sp)
    8000389c:	e822                	sd	s0,16(sp)
    8000389e:	e426                	sd	s1,8(sp)
    800038a0:	e04a                	sd	s2,0(sp)
    800038a2:	1000                	addi	s0,sp,32
    800038a4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800038a6:	01050913          	addi	s2,a0,16
    800038aa:	854a                	mv	a0,s2
    800038ac:	00001097          	auipc	ra,0x1
    800038b0:	42a080e7          	jalr	1066(ra) # 80004cd6 <holdingsleep>
    800038b4:	c92d                	beqz	a0,80003926 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800038b6:	854a                	mv	a0,s2
    800038b8:	00001097          	auipc	ra,0x1
    800038bc:	3da080e7          	jalr	986(ra) # 80004c92 <releasesleep>

  acquire(&bcache.lock);
    800038c0:	00235517          	auipc	a0,0x235
    800038c4:	e1050513          	addi	a0,a0,-496 # 802386d0 <bcache>
    800038c8:	ffffd097          	auipc	ra,0xffffd
    800038cc:	4e0080e7          	jalr	1248(ra) # 80000da8 <acquire>
  b->refcnt--;
    800038d0:	40bc                	lw	a5,64(s1)
    800038d2:	37fd                	addiw	a5,a5,-1
    800038d4:	0007871b          	sext.w	a4,a5
    800038d8:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800038da:	eb05                	bnez	a4,8000390a <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800038dc:	68bc                	ld	a5,80(s1)
    800038de:	64b8                	ld	a4,72(s1)
    800038e0:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800038e2:	64bc                	ld	a5,72(s1)
    800038e4:	68b8                	ld	a4,80(s1)
    800038e6:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800038e8:	0023d797          	auipc	a5,0x23d
    800038ec:	de878793          	addi	a5,a5,-536 # 802406d0 <bcache+0x8000>
    800038f0:	2b87b703          	ld	a4,696(a5)
    800038f4:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800038f6:	0023d717          	auipc	a4,0x23d
    800038fa:	04270713          	addi	a4,a4,66 # 80240938 <bcache+0x8268>
    800038fe:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003900:	2b87b703          	ld	a4,696(a5)
    80003904:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003906:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000390a:	00235517          	auipc	a0,0x235
    8000390e:	dc650513          	addi	a0,a0,-570 # 802386d0 <bcache>
    80003912:	ffffd097          	auipc	ra,0xffffd
    80003916:	54a080e7          	jalr	1354(ra) # 80000e5c <release>
}
    8000391a:	60e2                	ld	ra,24(sp)
    8000391c:	6442                	ld	s0,16(sp)
    8000391e:	64a2                	ld	s1,8(sp)
    80003920:	6902                	ld	s2,0(sp)
    80003922:	6105                	addi	sp,sp,32
    80003924:	8082                	ret
    panic("brelse");
    80003926:	00005517          	auipc	a0,0x5
    8000392a:	d8a50513          	addi	a0,a0,-630 # 800086b0 <syscalls+0x108>
    8000392e:	ffffd097          	auipc	ra,0xffffd
    80003932:	c16080e7          	jalr	-1002(ra) # 80000544 <panic>

0000000080003936 <bpin>:

void
bpin(struct buf *b) {
    80003936:	1101                	addi	sp,sp,-32
    80003938:	ec06                	sd	ra,24(sp)
    8000393a:	e822                	sd	s0,16(sp)
    8000393c:	e426                	sd	s1,8(sp)
    8000393e:	1000                	addi	s0,sp,32
    80003940:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003942:	00235517          	auipc	a0,0x235
    80003946:	d8e50513          	addi	a0,a0,-626 # 802386d0 <bcache>
    8000394a:	ffffd097          	auipc	ra,0xffffd
    8000394e:	45e080e7          	jalr	1118(ra) # 80000da8 <acquire>
  b->refcnt++;
    80003952:	40bc                	lw	a5,64(s1)
    80003954:	2785                	addiw	a5,a5,1
    80003956:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003958:	00235517          	auipc	a0,0x235
    8000395c:	d7850513          	addi	a0,a0,-648 # 802386d0 <bcache>
    80003960:	ffffd097          	auipc	ra,0xffffd
    80003964:	4fc080e7          	jalr	1276(ra) # 80000e5c <release>
}
    80003968:	60e2                	ld	ra,24(sp)
    8000396a:	6442                	ld	s0,16(sp)
    8000396c:	64a2                	ld	s1,8(sp)
    8000396e:	6105                	addi	sp,sp,32
    80003970:	8082                	ret

0000000080003972 <bunpin>:

void
bunpin(struct buf *b) {
    80003972:	1101                	addi	sp,sp,-32
    80003974:	ec06                	sd	ra,24(sp)
    80003976:	e822                	sd	s0,16(sp)
    80003978:	e426                	sd	s1,8(sp)
    8000397a:	1000                	addi	s0,sp,32
    8000397c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000397e:	00235517          	auipc	a0,0x235
    80003982:	d5250513          	addi	a0,a0,-686 # 802386d0 <bcache>
    80003986:	ffffd097          	auipc	ra,0xffffd
    8000398a:	422080e7          	jalr	1058(ra) # 80000da8 <acquire>
  b->refcnt--;
    8000398e:	40bc                	lw	a5,64(s1)
    80003990:	37fd                	addiw	a5,a5,-1
    80003992:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003994:	00235517          	auipc	a0,0x235
    80003998:	d3c50513          	addi	a0,a0,-708 # 802386d0 <bcache>
    8000399c:	ffffd097          	auipc	ra,0xffffd
    800039a0:	4c0080e7          	jalr	1216(ra) # 80000e5c <release>
}
    800039a4:	60e2                	ld	ra,24(sp)
    800039a6:	6442                	ld	s0,16(sp)
    800039a8:	64a2                	ld	s1,8(sp)
    800039aa:	6105                	addi	sp,sp,32
    800039ac:	8082                	ret

00000000800039ae <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800039ae:	1101                	addi	sp,sp,-32
    800039b0:	ec06                	sd	ra,24(sp)
    800039b2:	e822                	sd	s0,16(sp)
    800039b4:	e426                	sd	s1,8(sp)
    800039b6:	e04a                	sd	s2,0(sp)
    800039b8:	1000                	addi	s0,sp,32
    800039ba:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800039bc:	00d5d59b          	srliw	a1,a1,0xd
    800039c0:	0023d797          	auipc	a5,0x23d
    800039c4:	3ec7a783          	lw	a5,1004(a5) # 80240dac <sb+0x1c>
    800039c8:	9dbd                	addw	a1,a1,a5
    800039ca:	00000097          	auipc	ra,0x0
    800039ce:	d9e080e7          	jalr	-610(ra) # 80003768 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800039d2:	0074f713          	andi	a4,s1,7
    800039d6:	4785                	li	a5,1
    800039d8:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800039dc:	14ce                	slli	s1,s1,0x33
    800039de:	90d9                	srli	s1,s1,0x36
    800039e0:	00950733          	add	a4,a0,s1
    800039e4:	05874703          	lbu	a4,88(a4)
    800039e8:	00e7f6b3          	and	a3,a5,a4
    800039ec:	c69d                	beqz	a3,80003a1a <bfree+0x6c>
    800039ee:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800039f0:	94aa                	add	s1,s1,a0
    800039f2:	fff7c793          	not	a5,a5
    800039f6:	8ff9                	and	a5,a5,a4
    800039f8:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800039fc:	00001097          	auipc	ra,0x1
    80003a00:	120080e7          	jalr	288(ra) # 80004b1c <log_write>
  brelse(bp);
    80003a04:	854a                	mv	a0,s2
    80003a06:	00000097          	auipc	ra,0x0
    80003a0a:	e92080e7          	jalr	-366(ra) # 80003898 <brelse>
}
    80003a0e:	60e2                	ld	ra,24(sp)
    80003a10:	6442                	ld	s0,16(sp)
    80003a12:	64a2                	ld	s1,8(sp)
    80003a14:	6902                	ld	s2,0(sp)
    80003a16:	6105                	addi	sp,sp,32
    80003a18:	8082                	ret
    panic("freeing free block");
    80003a1a:	00005517          	auipc	a0,0x5
    80003a1e:	c9e50513          	addi	a0,a0,-866 # 800086b8 <syscalls+0x110>
    80003a22:	ffffd097          	auipc	ra,0xffffd
    80003a26:	b22080e7          	jalr	-1246(ra) # 80000544 <panic>

0000000080003a2a <balloc>:
{
    80003a2a:	711d                	addi	sp,sp,-96
    80003a2c:	ec86                	sd	ra,88(sp)
    80003a2e:	e8a2                	sd	s0,80(sp)
    80003a30:	e4a6                	sd	s1,72(sp)
    80003a32:	e0ca                	sd	s2,64(sp)
    80003a34:	fc4e                	sd	s3,56(sp)
    80003a36:	f852                	sd	s4,48(sp)
    80003a38:	f456                	sd	s5,40(sp)
    80003a3a:	f05a                	sd	s6,32(sp)
    80003a3c:	ec5e                	sd	s7,24(sp)
    80003a3e:	e862                	sd	s8,16(sp)
    80003a40:	e466                	sd	s9,8(sp)
    80003a42:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003a44:	0023d797          	auipc	a5,0x23d
    80003a48:	3507a783          	lw	a5,848(a5) # 80240d94 <sb+0x4>
    80003a4c:	10078163          	beqz	a5,80003b4e <balloc+0x124>
    80003a50:	8baa                	mv	s7,a0
    80003a52:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003a54:	0023db17          	auipc	s6,0x23d
    80003a58:	33cb0b13          	addi	s6,s6,828 # 80240d90 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a5c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003a5e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a60:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003a62:	6c89                	lui	s9,0x2
    80003a64:	a061                	j	80003aec <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003a66:	974a                	add	a4,a4,s2
    80003a68:	8fd5                	or	a5,a5,a3
    80003a6a:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003a6e:	854a                	mv	a0,s2
    80003a70:	00001097          	auipc	ra,0x1
    80003a74:	0ac080e7          	jalr	172(ra) # 80004b1c <log_write>
        brelse(bp);
    80003a78:	854a                	mv	a0,s2
    80003a7a:	00000097          	auipc	ra,0x0
    80003a7e:	e1e080e7          	jalr	-482(ra) # 80003898 <brelse>
  bp = bread(dev, bno);
    80003a82:	85a6                	mv	a1,s1
    80003a84:	855e                	mv	a0,s7
    80003a86:	00000097          	auipc	ra,0x0
    80003a8a:	ce2080e7          	jalr	-798(ra) # 80003768 <bread>
    80003a8e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003a90:	40000613          	li	a2,1024
    80003a94:	4581                	li	a1,0
    80003a96:	05850513          	addi	a0,a0,88
    80003a9a:	ffffd097          	auipc	ra,0xffffd
    80003a9e:	40a080e7          	jalr	1034(ra) # 80000ea4 <memset>
  log_write(bp);
    80003aa2:	854a                	mv	a0,s2
    80003aa4:	00001097          	auipc	ra,0x1
    80003aa8:	078080e7          	jalr	120(ra) # 80004b1c <log_write>
  brelse(bp);
    80003aac:	854a                	mv	a0,s2
    80003aae:	00000097          	auipc	ra,0x0
    80003ab2:	dea080e7          	jalr	-534(ra) # 80003898 <brelse>
}
    80003ab6:	8526                	mv	a0,s1
    80003ab8:	60e6                	ld	ra,88(sp)
    80003aba:	6446                	ld	s0,80(sp)
    80003abc:	64a6                	ld	s1,72(sp)
    80003abe:	6906                	ld	s2,64(sp)
    80003ac0:	79e2                	ld	s3,56(sp)
    80003ac2:	7a42                	ld	s4,48(sp)
    80003ac4:	7aa2                	ld	s5,40(sp)
    80003ac6:	7b02                	ld	s6,32(sp)
    80003ac8:	6be2                	ld	s7,24(sp)
    80003aca:	6c42                	ld	s8,16(sp)
    80003acc:	6ca2                	ld	s9,8(sp)
    80003ace:	6125                	addi	sp,sp,96
    80003ad0:	8082                	ret
    brelse(bp);
    80003ad2:	854a                	mv	a0,s2
    80003ad4:	00000097          	auipc	ra,0x0
    80003ad8:	dc4080e7          	jalr	-572(ra) # 80003898 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003adc:	015c87bb          	addw	a5,s9,s5
    80003ae0:	00078a9b          	sext.w	s5,a5
    80003ae4:	004b2703          	lw	a4,4(s6)
    80003ae8:	06eaf363          	bgeu	s5,a4,80003b4e <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80003aec:	41fad79b          	sraiw	a5,s5,0x1f
    80003af0:	0137d79b          	srliw	a5,a5,0x13
    80003af4:	015787bb          	addw	a5,a5,s5
    80003af8:	40d7d79b          	sraiw	a5,a5,0xd
    80003afc:	01cb2583          	lw	a1,28(s6)
    80003b00:	9dbd                	addw	a1,a1,a5
    80003b02:	855e                	mv	a0,s7
    80003b04:	00000097          	auipc	ra,0x0
    80003b08:	c64080e7          	jalr	-924(ra) # 80003768 <bread>
    80003b0c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b0e:	004b2503          	lw	a0,4(s6)
    80003b12:	000a849b          	sext.w	s1,s5
    80003b16:	8662                	mv	a2,s8
    80003b18:	faa4fde3          	bgeu	s1,a0,80003ad2 <balloc+0xa8>
      m = 1 << (bi % 8);
    80003b1c:	41f6579b          	sraiw	a5,a2,0x1f
    80003b20:	01d7d69b          	srliw	a3,a5,0x1d
    80003b24:	00c6873b          	addw	a4,a3,a2
    80003b28:	00777793          	andi	a5,a4,7
    80003b2c:	9f95                	subw	a5,a5,a3
    80003b2e:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003b32:	4037571b          	sraiw	a4,a4,0x3
    80003b36:	00e906b3          	add	a3,s2,a4
    80003b3a:	0586c683          	lbu	a3,88(a3)
    80003b3e:	00d7f5b3          	and	a1,a5,a3
    80003b42:	d195                	beqz	a1,80003a66 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b44:	2605                	addiw	a2,a2,1
    80003b46:	2485                	addiw	s1,s1,1
    80003b48:	fd4618e3          	bne	a2,s4,80003b18 <balloc+0xee>
    80003b4c:	b759                	j	80003ad2 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003b4e:	00005517          	auipc	a0,0x5
    80003b52:	b8250513          	addi	a0,a0,-1150 # 800086d0 <syscalls+0x128>
    80003b56:	ffffd097          	auipc	ra,0xffffd
    80003b5a:	a38080e7          	jalr	-1480(ra) # 8000058e <printf>
  return 0;
    80003b5e:	4481                	li	s1,0
    80003b60:	bf99                	j	80003ab6 <balloc+0x8c>

0000000080003b62 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003b62:	7179                	addi	sp,sp,-48
    80003b64:	f406                	sd	ra,40(sp)
    80003b66:	f022                	sd	s0,32(sp)
    80003b68:	ec26                	sd	s1,24(sp)
    80003b6a:	e84a                	sd	s2,16(sp)
    80003b6c:	e44e                	sd	s3,8(sp)
    80003b6e:	e052                	sd	s4,0(sp)
    80003b70:	1800                	addi	s0,sp,48
    80003b72:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003b74:	47ad                	li	a5,11
    80003b76:	02b7e763          	bltu	a5,a1,80003ba4 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003b7a:	02059493          	slli	s1,a1,0x20
    80003b7e:	9081                	srli	s1,s1,0x20
    80003b80:	048a                	slli	s1,s1,0x2
    80003b82:	94aa                	add	s1,s1,a0
    80003b84:	0504a903          	lw	s2,80(s1)
    80003b88:	06091e63          	bnez	s2,80003c04 <bmap+0xa2>
      addr = balloc(ip->dev);
    80003b8c:	4108                	lw	a0,0(a0)
    80003b8e:	00000097          	auipc	ra,0x0
    80003b92:	e9c080e7          	jalr	-356(ra) # 80003a2a <balloc>
    80003b96:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003b9a:	06090563          	beqz	s2,80003c04 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80003b9e:	0524a823          	sw	s2,80(s1)
    80003ba2:	a08d                	j	80003c04 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003ba4:	ff45849b          	addiw	s1,a1,-12
    80003ba8:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003bac:	0ff00793          	li	a5,255
    80003bb0:	08e7e563          	bltu	a5,a4,80003c3a <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003bb4:	08052903          	lw	s2,128(a0)
    80003bb8:	00091d63          	bnez	s2,80003bd2 <bmap+0x70>
      addr = balloc(ip->dev);
    80003bbc:	4108                	lw	a0,0(a0)
    80003bbe:	00000097          	auipc	ra,0x0
    80003bc2:	e6c080e7          	jalr	-404(ra) # 80003a2a <balloc>
    80003bc6:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003bca:	02090d63          	beqz	s2,80003c04 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003bce:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003bd2:	85ca                	mv	a1,s2
    80003bd4:	0009a503          	lw	a0,0(s3)
    80003bd8:	00000097          	auipc	ra,0x0
    80003bdc:	b90080e7          	jalr	-1136(ra) # 80003768 <bread>
    80003be0:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003be2:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003be6:	02049593          	slli	a1,s1,0x20
    80003bea:	9181                	srli	a1,a1,0x20
    80003bec:	058a                	slli	a1,a1,0x2
    80003bee:	00b784b3          	add	s1,a5,a1
    80003bf2:	0004a903          	lw	s2,0(s1)
    80003bf6:	02090063          	beqz	s2,80003c16 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003bfa:	8552                	mv	a0,s4
    80003bfc:	00000097          	auipc	ra,0x0
    80003c00:	c9c080e7          	jalr	-868(ra) # 80003898 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003c04:	854a                	mv	a0,s2
    80003c06:	70a2                	ld	ra,40(sp)
    80003c08:	7402                	ld	s0,32(sp)
    80003c0a:	64e2                	ld	s1,24(sp)
    80003c0c:	6942                	ld	s2,16(sp)
    80003c0e:	69a2                	ld	s3,8(sp)
    80003c10:	6a02                	ld	s4,0(sp)
    80003c12:	6145                	addi	sp,sp,48
    80003c14:	8082                	ret
      addr = balloc(ip->dev);
    80003c16:	0009a503          	lw	a0,0(s3)
    80003c1a:	00000097          	auipc	ra,0x0
    80003c1e:	e10080e7          	jalr	-496(ra) # 80003a2a <balloc>
    80003c22:	0005091b          	sext.w	s2,a0
      if(addr){
    80003c26:	fc090ae3          	beqz	s2,80003bfa <bmap+0x98>
        a[bn] = addr;
    80003c2a:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003c2e:	8552                	mv	a0,s4
    80003c30:	00001097          	auipc	ra,0x1
    80003c34:	eec080e7          	jalr	-276(ra) # 80004b1c <log_write>
    80003c38:	b7c9                	j	80003bfa <bmap+0x98>
  panic("bmap: out of range");
    80003c3a:	00005517          	auipc	a0,0x5
    80003c3e:	aae50513          	addi	a0,a0,-1362 # 800086e8 <syscalls+0x140>
    80003c42:	ffffd097          	auipc	ra,0xffffd
    80003c46:	902080e7          	jalr	-1790(ra) # 80000544 <panic>

0000000080003c4a <iget>:
{
    80003c4a:	7179                	addi	sp,sp,-48
    80003c4c:	f406                	sd	ra,40(sp)
    80003c4e:	f022                	sd	s0,32(sp)
    80003c50:	ec26                	sd	s1,24(sp)
    80003c52:	e84a                	sd	s2,16(sp)
    80003c54:	e44e                	sd	s3,8(sp)
    80003c56:	e052                	sd	s4,0(sp)
    80003c58:	1800                	addi	s0,sp,48
    80003c5a:	89aa                	mv	s3,a0
    80003c5c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003c5e:	0023d517          	auipc	a0,0x23d
    80003c62:	15250513          	addi	a0,a0,338 # 80240db0 <itable>
    80003c66:	ffffd097          	auipc	ra,0xffffd
    80003c6a:	142080e7          	jalr	322(ra) # 80000da8 <acquire>
  empty = 0;
    80003c6e:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003c70:	0023d497          	auipc	s1,0x23d
    80003c74:	15848493          	addi	s1,s1,344 # 80240dc8 <itable+0x18>
    80003c78:	0023f697          	auipc	a3,0x23f
    80003c7c:	be068693          	addi	a3,a3,-1056 # 80242858 <log>
    80003c80:	a039                	j	80003c8e <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003c82:	02090b63          	beqz	s2,80003cb8 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003c86:	08848493          	addi	s1,s1,136
    80003c8a:	02d48a63          	beq	s1,a3,80003cbe <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003c8e:	449c                	lw	a5,8(s1)
    80003c90:	fef059e3          	blez	a5,80003c82 <iget+0x38>
    80003c94:	4098                	lw	a4,0(s1)
    80003c96:	ff3716e3          	bne	a4,s3,80003c82 <iget+0x38>
    80003c9a:	40d8                	lw	a4,4(s1)
    80003c9c:	ff4713e3          	bne	a4,s4,80003c82 <iget+0x38>
      ip->ref++;
    80003ca0:	2785                	addiw	a5,a5,1
    80003ca2:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003ca4:	0023d517          	auipc	a0,0x23d
    80003ca8:	10c50513          	addi	a0,a0,268 # 80240db0 <itable>
    80003cac:	ffffd097          	auipc	ra,0xffffd
    80003cb0:	1b0080e7          	jalr	432(ra) # 80000e5c <release>
      return ip;
    80003cb4:	8926                	mv	s2,s1
    80003cb6:	a03d                	j	80003ce4 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003cb8:	f7f9                	bnez	a5,80003c86 <iget+0x3c>
    80003cba:	8926                	mv	s2,s1
    80003cbc:	b7e9                	j	80003c86 <iget+0x3c>
  if(empty == 0)
    80003cbe:	02090c63          	beqz	s2,80003cf6 <iget+0xac>
  ip->dev = dev;
    80003cc2:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003cc6:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003cca:	4785                	li	a5,1
    80003ccc:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003cd0:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003cd4:	0023d517          	auipc	a0,0x23d
    80003cd8:	0dc50513          	addi	a0,a0,220 # 80240db0 <itable>
    80003cdc:	ffffd097          	auipc	ra,0xffffd
    80003ce0:	180080e7          	jalr	384(ra) # 80000e5c <release>
}
    80003ce4:	854a                	mv	a0,s2
    80003ce6:	70a2                	ld	ra,40(sp)
    80003ce8:	7402                	ld	s0,32(sp)
    80003cea:	64e2                	ld	s1,24(sp)
    80003cec:	6942                	ld	s2,16(sp)
    80003cee:	69a2                	ld	s3,8(sp)
    80003cf0:	6a02                	ld	s4,0(sp)
    80003cf2:	6145                	addi	sp,sp,48
    80003cf4:	8082                	ret
    panic("iget: no inodes");
    80003cf6:	00005517          	auipc	a0,0x5
    80003cfa:	a0a50513          	addi	a0,a0,-1526 # 80008700 <syscalls+0x158>
    80003cfe:	ffffd097          	auipc	ra,0xffffd
    80003d02:	846080e7          	jalr	-1978(ra) # 80000544 <panic>

0000000080003d06 <fsinit>:
fsinit(int dev) {
    80003d06:	7179                	addi	sp,sp,-48
    80003d08:	f406                	sd	ra,40(sp)
    80003d0a:	f022                	sd	s0,32(sp)
    80003d0c:	ec26                	sd	s1,24(sp)
    80003d0e:	e84a                	sd	s2,16(sp)
    80003d10:	e44e                	sd	s3,8(sp)
    80003d12:	1800                	addi	s0,sp,48
    80003d14:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003d16:	4585                	li	a1,1
    80003d18:	00000097          	auipc	ra,0x0
    80003d1c:	a50080e7          	jalr	-1456(ra) # 80003768 <bread>
    80003d20:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003d22:	0023d997          	auipc	s3,0x23d
    80003d26:	06e98993          	addi	s3,s3,110 # 80240d90 <sb>
    80003d2a:	02000613          	li	a2,32
    80003d2e:	05850593          	addi	a1,a0,88
    80003d32:	854e                	mv	a0,s3
    80003d34:	ffffd097          	auipc	ra,0xffffd
    80003d38:	1d0080e7          	jalr	464(ra) # 80000f04 <memmove>
  brelse(bp);
    80003d3c:	8526                	mv	a0,s1
    80003d3e:	00000097          	auipc	ra,0x0
    80003d42:	b5a080e7          	jalr	-1190(ra) # 80003898 <brelse>
  if(sb.magic != FSMAGIC)
    80003d46:	0009a703          	lw	a4,0(s3)
    80003d4a:	102037b7          	lui	a5,0x10203
    80003d4e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003d52:	02f71263          	bne	a4,a5,80003d76 <fsinit+0x70>
  initlog(dev, &sb);
    80003d56:	0023d597          	auipc	a1,0x23d
    80003d5a:	03a58593          	addi	a1,a1,58 # 80240d90 <sb>
    80003d5e:	854a                	mv	a0,s2
    80003d60:	00001097          	auipc	ra,0x1
    80003d64:	b40080e7          	jalr	-1216(ra) # 800048a0 <initlog>
}
    80003d68:	70a2                	ld	ra,40(sp)
    80003d6a:	7402                	ld	s0,32(sp)
    80003d6c:	64e2                	ld	s1,24(sp)
    80003d6e:	6942                	ld	s2,16(sp)
    80003d70:	69a2                	ld	s3,8(sp)
    80003d72:	6145                	addi	sp,sp,48
    80003d74:	8082                	ret
    panic("invalid file system");
    80003d76:	00005517          	auipc	a0,0x5
    80003d7a:	99a50513          	addi	a0,a0,-1638 # 80008710 <syscalls+0x168>
    80003d7e:	ffffc097          	auipc	ra,0xffffc
    80003d82:	7c6080e7          	jalr	1990(ra) # 80000544 <panic>

0000000080003d86 <iinit>:
{
    80003d86:	7179                	addi	sp,sp,-48
    80003d88:	f406                	sd	ra,40(sp)
    80003d8a:	f022                	sd	s0,32(sp)
    80003d8c:	ec26                	sd	s1,24(sp)
    80003d8e:	e84a                	sd	s2,16(sp)
    80003d90:	e44e                	sd	s3,8(sp)
    80003d92:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003d94:	00005597          	auipc	a1,0x5
    80003d98:	99458593          	addi	a1,a1,-1644 # 80008728 <syscalls+0x180>
    80003d9c:	0023d517          	auipc	a0,0x23d
    80003da0:	01450513          	addi	a0,a0,20 # 80240db0 <itable>
    80003da4:	ffffd097          	auipc	ra,0xffffd
    80003da8:	f74080e7          	jalr	-140(ra) # 80000d18 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003dac:	0023d497          	auipc	s1,0x23d
    80003db0:	02c48493          	addi	s1,s1,44 # 80240dd8 <itable+0x28>
    80003db4:	0023f997          	auipc	s3,0x23f
    80003db8:	ab498993          	addi	s3,s3,-1356 # 80242868 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003dbc:	00005917          	auipc	s2,0x5
    80003dc0:	97490913          	addi	s2,s2,-1676 # 80008730 <syscalls+0x188>
    80003dc4:	85ca                	mv	a1,s2
    80003dc6:	8526                	mv	a0,s1
    80003dc8:	00001097          	auipc	ra,0x1
    80003dcc:	e3a080e7          	jalr	-454(ra) # 80004c02 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003dd0:	08848493          	addi	s1,s1,136
    80003dd4:	ff3498e3          	bne	s1,s3,80003dc4 <iinit+0x3e>
}
    80003dd8:	70a2                	ld	ra,40(sp)
    80003dda:	7402                	ld	s0,32(sp)
    80003ddc:	64e2                	ld	s1,24(sp)
    80003dde:	6942                	ld	s2,16(sp)
    80003de0:	69a2                	ld	s3,8(sp)
    80003de2:	6145                	addi	sp,sp,48
    80003de4:	8082                	ret

0000000080003de6 <ialloc>:
{
    80003de6:	715d                	addi	sp,sp,-80
    80003de8:	e486                	sd	ra,72(sp)
    80003dea:	e0a2                	sd	s0,64(sp)
    80003dec:	fc26                	sd	s1,56(sp)
    80003dee:	f84a                	sd	s2,48(sp)
    80003df0:	f44e                	sd	s3,40(sp)
    80003df2:	f052                	sd	s4,32(sp)
    80003df4:	ec56                	sd	s5,24(sp)
    80003df6:	e85a                	sd	s6,16(sp)
    80003df8:	e45e                	sd	s7,8(sp)
    80003dfa:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003dfc:	0023d717          	auipc	a4,0x23d
    80003e00:	fa072703          	lw	a4,-96(a4) # 80240d9c <sb+0xc>
    80003e04:	4785                	li	a5,1
    80003e06:	04e7fa63          	bgeu	a5,a4,80003e5a <ialloc+0x74>
    80003e0a:	8aaa                	mv	s5,a0
    80003e0c:	8bae                	mv	s7,a1
    80003e0e:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003e10:	0023da17          	auipc	s4,0x23d
    80003e14:	f80a0a13          	addi	s4,s4,-128 # 80240d90 <sb>
    80003e18:	00048b1b          	sext.w	s6,s1
    80003e1c:	0044d593          	srli	a1,s1,0x4
    80003e20:	018a2783          	lw	a5,24(s4)
    80003e24:	9dbd                	addw	a1,a1,a5
    80003e26:	8556                	mv	a0,s5
    80003e28:	00000097          	auipc	ra,0x0
    80003e2c:	940080e7          	jalr	-1728(ra) # 80003768 <bread>
    80003e30:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003e32:	05850993          	addi	s3,a0,88
    80003e36:	00f4f793          	andi	a5,s1,15
    80003e3a:	079a                	slli	a5,a5,0x6
    80003e3c:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003e3e:	00099783          	lh	a5,0(s3)
    80003e42:	c3a1                	beqz	a5,80003e82 <ialloc+0x9c>
    brelse(bp);
    80003e44:	00000097          	auipc	ra,0x0
    80003e48:	a54080e7          	jalr	-1452(ra) # 80003898 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003e4c:	0485                	addi	s1,s1,1
    80003e4e:	00ca2703          	lw	a4,12(s4)
    80003e52:	0004879b          	sext.w	a5,s1
    80003e56:	fce7e1e3          	bltu	a5,a4,80003e18 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003e5a:	00005517          	auipc	a0,0x5
    80003e5e:	8de50513          	addi	a0,a0,-1826 # 80008738 <syscalls+0x190>
    80003e62:	ffffc097          	auipc	ra,0xffffc
    80003e66:	72c080e7          	jalr	1836(ra) # 8000058e <printf>
  return 0;
    80003e6a:	4501                	li	a0,0
}
    80003e6c:	60a6                	ld	ra,72(sp)
    80003e6e:	6406                	ld	s0,64(sp)
    80003e70:	74e2                	ld	s1,56(sp)
    80003e72:	7942                	ld	s2,48(sp)
    80003e74:	79a2                	ld	s3,40(sp)
    80003e76:	7a02                	ld	s4,32(sp)
    80003e78:	6ae2                	ld	s5,24(sp)
    80003e7a:	6b42                	ld	s6,16(sp)
    80003e7c:	6ba2                	ld	s7,8(sp)
    80003e7e:	6161                	addi	sp,sp,80
    80003e80:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003e82:	04000613          	li	a2,64
    80003e86:	4581                	li	a1,0
    80003e88:	854e                	mv	a0,s3
    80003e8a:	ffffd097          	auipc	ra,0xffffd
    80003e8e:	01a080e7          	jalr	26(ra) # 80000ea4 <memset>
      dip->type = type;
    80003e92:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003e96:	854a                	mv	a0,s2
    80003e98:	00001097          	auipc	ra,0x1
    80003e9c:	c84080e7          	jalr	-892(ra) # 80004b1c <log_write>
      brelse(bp);
    80003ea0:	854a                	mv	a0,s2
    80003ea2:	00000097          	auipc	ra,0x0
    80003ea6:	9f6080e7          	jalr	-1546(ra) # 80003898 <brelse>
      return iget(dev, inum);
    80003eaa:	85da                	mv	a1,s6
    80003eac:	8556                	mv	a0,s5
    80003eae:	00000097          	auipc	ra,0x0
    80003eb2:	d9c080e7          	jalr	-612(ra) # 80003c4a <iget>
    80003eb6:	bf5d                	j	80003e6c <ialloc+0x86>

0000000080003eb8 <iupdate>:
{
    80003eb8:	1101                	addi	sp,sp,-32
    80003eba:	ec06                	sd	ra,24(sp)
    80003ebc:	e822                	sd	s0,16(sp)
    80003ebe:	e426                	sd	s1,8(sp)
    80003ec0:	e04a                	sd	s2,0(sp)
    80003ec2:	1000                	addi	s0,sp,32
    80003ec4:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003ec6:	415c                	lw	a5,4(a0)
    80003ec8:	0047d79b          	srliw	a5,a5,0x4
    80003ecc:	0023d597          	auipc	a1,0x23d
    80003ed0:	edc5a583          	lw	a1,-292(a1) # 80240da8 <sb+0x18>
    80003ed4:	9dbd                	addw	a1,a1,a5
    80003ed6:	4108                	lw	a0,0(a0)
    80003ed8:	00000097          	auipc	ra,0x0
    80003edc:	890080e7          	jalr	-1904(ra) # 80003768 <bread>
    80003ee0:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003ee2:	05850793          	addi	a5,a0,88
    80003ee6:	40c8                	lw	a0,4(s1)
    80003ee8:	893d                	andi	a0,a0,15
    80003eea:	051a                	slli	a0,a0,0x6
    80003eec:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003eee:	04449703          	lh	a4,68(s1)
    80003ef2:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003ef6:	04649703          	lh	a4,70(s1)
    80003efa:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003efe:	04849703          	lh	a4,72(s1)
    80003f02:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003f06:	04a49703          	lh	a4,74(s1)
    80003f0a:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003f0e:	44f8                	lw	a4,76(s1)
    80003f10:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003f12:	03400613          	li	a2,52
    80003f16:	05048593          	addi	a1,s1,80
    80003f1a:	0531                	addi	a0,a0,12
    80003f1c:	ffffd097          	auipc	ra,0xffffd
    80003f20:	fe8080e7          	jalr	-24(ra) # 80000f04 <memmove>
  log_write(bp);
    80003f24:	854a                	mv	a0,s2
    80003f26:	00001097          	auipc	ra,0x1
    80003f2a:	bf6080e7          	jalr	-1034(ra) # 80004b1c <log_write>
  brelse(bp);
    80003f2e:	854a                	mv	a0,s2
    80003f30:	00000097          	auipc	ra,0x0
    80003f34:	968080e7          	jalr	-1688(ra) # 80003898 <brelse>
}
    80003f38:	60e2                	ld	ra,24(sp)
    80003f3a:	6442                	ld	s0,16(sp)
    80003f3c:	64a2                	ld	s1,8(sp)
    80003f3e:	6902                	ld	s2,0(sp)
    80003f40:	6105                	addi	sp,sp,32
    80003f42:	8082                	ret

0000000080003f44 <idup>:
{
    80003f44:	1101                	addi	sp,sp,-32
    80003f46:	ec06                	sd	ra,24(sp)
    80003f48:	e822                	sd	s0,16(sp)
    80003f4a:	e426                	sd	s1,8(sp)
    80003f4c:	1000                	addi	s0,sp,32
    80003f4e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003f50:	0023d517          	auipc	a0,0x23d
    80003f54:	e6050513          	addi	a0,a0,-416 # 80240db0 <itable>
    80003f58:	ffffd097          	auipc	ra,0xffffd
    80003f5c:	e50080e7          	jalr	-432(ra) # 80000da8 <acquire>
  ip->ref++;
    80003f60:	449c                	lw	a5,8(s1)
    80003f62:	2785                	addiw	a5,a5,1
    80003f64:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003f66:	0023d517          	auipc	a0,0x23d
    80003f6a:	e4a50513          	addi	a0,a0,-438 # 80240db0 <itable>
    80003f6e:	ffffd097          	auipc	ra,0xffffd
    80003f72:	eee080e7          	jalr	-274(ra) # 80000e5c <release>
}
    80003f76:	8526                	mv	a0,s1
    80003f78:	60e2                	ld	ra,24(sp)
    80003f7a:	6442                	ld	s0,16(sp)
    80003f7c:	64a2                	ld	s1,8(sp)
    80003f7e:	6105                	addi	sp,sp,32
    80003f80:	8082                	ret

0000000080003f82 <ilock>:
{
    80003f82:	1101                	addi	sp,sp,-32
    80003f84:	ec06                	sd	ra,24(sp)
    80003f86:	e822                	sd	s0,16(sp)
    80003f88:	e426                	sd	s1,8(sp)
    80003f8a:	e04a                	sd	s2,0(sp)
    80003f8c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003f8e:	c115                	beqz	a0,80003fb2 <ilock+0x30>
    80003f90:	84aa                	mv	s1,a0
    80003f92:	451c                	lw	a5,8(a0)
    80003f94:	00f05f63          	blez	a5,80003fb2 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003f98:	0541                	addi	a0,a0,16
    80003f9a:	00001097          	auipc	ra,0x1
    80003f9e:	ca2080e7          	jalr	-862(ra) # 80004c3c <acquiresleep>
  if(ip->valid == 0){
    80003fa2:	40bc                	lw	a5,64(s1)
    80003fa4:	cf99                	beqz	a5,80003fc2 <ilock+0x40>
}
    80003fa6:	60e2                	ld	ra,24(sp)
    80003fa8:	6442                	ld	s0,16(sp)
    80003faa:	64a2                	ld	s1,8(sp)
    80003fac:	6902                	ld	s2,0(sp)
    80003fae:	6105                	addi	sp,sp,32
    80003fb0:	8082                	ret
    panic("ilock");
    80003fb2:	00004517          	auipc	a0,0x4
    80003fb6:	79e50513          	addi	a0,a0,1950 # 80008750 <syscalls+0x1a8>
    80003fba:	ffffc097          	auipc	ra,0xffffc
    80003fbe:	58a080e7          	jalr	1418(ra) # 80000544 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003fc2:	40dc                	lw	a5,4(s1)
    80003fc4:	0047d79b          	srliw	a5,a5,0x4
    80003fc8:	0023d597          	auipc	a1,0x23d
    80003fcc:	de05a583          	lw	a1,-544(a1) # 80240da8 <sb+0x18>
    80003fd0:	9dbd                	addw	a1,a1,a5
    80003fd2:	4088                	lw	a0,0(s1)
    80003fd4:	fffff097          	auipc	ra,0xfffff
    80003fd8:	794080e7          	jalr	1940(ra) # 80003768 <bread>
    80003fdc:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003fde:	05850593          	addi	a1,a0,88
    80003fe2:	40dc                	lw	a5,4(s1)
    80003fe4:	8bbd                	andi	a5,a5,15
    80003fe6:	079a                	slli	a5,a5,0x6
    80003fe8:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003fea:	00059783          	lh	a5,0(a1)
    80003fee:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003ff2:	00259783          	lh	a5,2(a1)
    80003ff6:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003ffa:	00459783          	lh	a5,4(a1)
    80003ffe:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80004002:	00659783          	lh	a5,6(a1)
    80004006:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000400a:	459c                	lw	a5,8(a1)
    8000400c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000400e:	03400613          	li	a2,52
    80004012:	05b1                	addi	a1,a1,12
    80004014:	05048513          	addi	a0,s1,80
    80004018:	ffffd097          	auipc	ra,0xffffd
    8000401c:	eec080e7          	jalr	-276(ra) # 80000f04 <memmove>
    brelse(bp);
    80004020:	854a                	mv	a0,s2
    80004022:	00000097          	auipc	ra,0x0
    80004026:	876080e7          	jalr	-1930(ra) # 80003898 <brelse>
    ip->valid = 1;
    8000402a:	4785                	li	a5,1
    8000402c:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000402e:	04449783          	lh	a5,68(s1)
    80004032:	fbb5                	bnez	a5,80003fa6 <ilock+0x24>
      panic("ilock: no type");
    80004034:	00004517          	auipc	a0,0x4
    80004038:	72450513          	addi	a0,a0,1828 # 80008758 <syscalls+0x1b0>
    8000403c:	ffffc097          	auipc	ra,0xffffc
    80004040:	508080e7          	jalr	1288(ra) # 80000544 <panic>

0000000080004044 <iunlock>:
{
    80004044:	1101                	addi	sp,sp,-32
    80004046:	ec06                	sd	ra,24(sp)
    80004048:	e822                	sd	s0,16(sp)
    8000404a:	e426                	sd	s1,8(sp)
    8000404c:	e04a                	sd	s2,0(sp)
    8000404e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80004050:	c905                	beqz	a0,80004080 <iunlock+0x3c>
    80004052:	84aa                	mv	s1,a0
    80004054:	01050913          	addi	s2,a0,16
    80004058:	854a                	mv	a0,s2
    8000405a:	00001097          	auipc	ra,0x1
    8000405e:	c7c080e7          	jalr	-900(ra) # 80004cd6 <holdingsleep>
    80004062:	cd19                	beqz	a0,80004080 <iunlock+0x3c>
    80004064:	449c                	lw	a5,8(s1)
    80004066:	00f05d63          	blez	a5,80004080 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000406a:	854a                	mv	a0,s2
    8000406c:	00001097          	auipc	ra,0x1
    80004070:	c26080e7          	jalr	-986(ra) # 80004c92 <releasesleep>
}
    80004074:	60e2                	ld	ra,24(sp)
    80004076:	6442                	ld	s0,16(sp)
    80004078:	64a2                	ld	s1,8(sp)
    8000407a:	6902                	ld	s2,0(sp)
    8000407c:	6105                	addi	sp,sp,32
    8000407e:	8082                	ret
    panic("iunlock");
    80004080:	00004517          	auipc	a0,0x4
    80004084:	6e850513          	addi	a0,a0,1768 # 80008768 <syscalls+0x1c0>
    80004088:	ffffc097          	auipc	ra,0xffffc
    8000408c:	4bc080e7          	jalr	1212(ra) # 80000544 <panic>

0000000080004090 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80004090:	7179                	addi	sp,sp,-48
    80004092:	f406                	sd	ra,40(sp)
    80004094:	f022                	sd	s0,32(sp)
    80004096:	ec26                	sd	s1,24(sp)
    80004098:	e84a                	sd	s2,16(sp)
    8000409a:	e44e                	sd	s3,8(sp)
    8000409c:	e052                	sd	s4,0(sp)
    8000409e:	1800                	addi	s0,sp,48
    800040a0:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800040a2:	05050493          	addi	s1,a0,80
    800040a6:	08050913          	addi	s2,a0,128
    800040aa:	a021                	j	800040b2 <itrunc+0x22>
    800040ac:	0491                	addi	s1,s1,4
    800040ae:	01248d63          	beq	s1,s2,800040c8 <itrunc+0x38>
    if(ip->addrs[i]){
    800040b2:	408c                	lw	a1,0(s1)
    800040b4:	dde5                	beqz	a1,800040ac <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800040b6:	0009a503          	lw	a0,0(s3)
    800040ba:	00000097          	auipc	ra,0x0
    800040be:	8f4080e7          	jalr	-1804(ra) # 800039ae <bfree>
      ip->addrs[i] = 0;
    800040c2:	0004a023          	sw	zero,0(s1)
    800040c6:	b7dd                	j	800040ac <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800040c8:	0809a583          	lw	a1,128(s3)
    800040cc:	e185                	bnez	a1,800040ec <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800040ce:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800040d2:	854e                	mv	a0,s3
    800040d4:	00000097          	auipc	ra,0x0
    800040d8:	de4080e7          	jalr	-540(ra) # 80003eb8 <iupdate>
}
    800040dc:	70a2                	ld	ra,40(sp)
    800040de:	7402                	ld	s0,32(sp)
    800040e0:	64e2                	ld	s1,24(sp)
    800040e2:	6942                	ld	s2,16(sp)
    800040e4:	69a2                	ld	s3,8(sp)
    800040e6:	6a02                	ld	s4,0(sp)
    800040e8:	6145                	addi	sp,sp,48
    800040ea:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800040ec:	0009a503          	lw	a0,0(s3)
    800040f0:	fffff097          	auipc	ra,0xfffff
    800040f4:	678080e7          	jalr	1656(ra) # 80003768 <bread>
    800040f8:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800040fa:	05850493          	addi	s1,a0,88
    800040fe:	45850913          	addi	s2,a0,1112
    80004102:	a811                	j	80004116 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80004104:	0009a503          	lw	a0,0(s3)
    80004108:	00000097          	auipc	ra,0x0
    8000410c:	8a6080e7          	jalr	-1882(ra) # 800039ae <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80004110:	0491                	addi	s1,s1,4
    80004112:	01248563          	beq	s1,s2,8000411c <itrunc+0x8c>
      if(a[j])
    80004116:	408c                	lw	a1,0(s1)
    80004118:	dde5                	beqz	a1,80004110 <itrunc+0x80>
    8000411a:	b7ed                	j	80004104 <itrunc+0x74>
    brelse(bp);
    8000411c:	8552                	mv	a0,s4
    8000411e:	fffff097          	auipc	ra,0xfffff
    80004122:	77a080e7          	jalr	1914(ra) # 80003898 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80004126:	0809a583          	lw	a1,128(s3)
    8000412a:	0009a503          	lw	a0,0(s3)
    8000412e:	00000097          	auipc	ra,0x0
    80004132:	880080e7          	jalr	-1920(ra) # 800039ae <bfree>
    ip->addrs[NDIRECT] = 0;
    80004136:	0809a023          	sw	zero,128(s3)
    8000413a:	bf51                	j	800040ce <itrunc+0x3e>

000000008000413c <iput>:
{
    8000413c:	1101                	addi	sp,sp,-32
    8000413e:	ec06                	sd	ra,24(sp)
    80004140:	e822                	sd	s0,16(sp)
    80004142:	e426                	sd	s1,8(sp)
    80004144:	e04a                	sd	s2,0(sp)
    80004146:	1000                	addi	s0,sp,32
    80004148:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000414a:	0023d517          	auipc	a0,0x23d
    8000414e:	c6650513          	addi	a0,a0,-922 # 80240db0 <itable>
    80004152:	ffffd097          	auipc	ra,0xffffd
    80004156:	c56080e7          	jalr	-938(ra) # 80000da8 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000415a:	4498                	lw	a4,8(s1)
    8000415c:	4785                	li	a5,1
    8000415e:	02f70363          	beq	a4,a5,80004184 <iput+0x48>
  ip->ref--;
    80004162:	449c                	lw	a5,8(s1)
    80004164:	37fd                	addiw	a5,a5,-1
    80004166:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004168:	0023d517          	auipc	a0,0x23d
    8000416c:	c4850513          	addi	a0,a0,-952 # 80240db0 <itable>
    80004170:	ffffd097          	auipc	ra,0xffffd
    80004174:	cec080e7          	jalr	-788(ra) # 80000e5c <release>
}
    80004178:	60e2                	ld	ra,24(sp)
    8000417a:	6442                	ld	s0,16(sp)
    8000417c:	64a2                	ld	s1,8(sp)
    8000417e:	6902                	ld	s2,0(sp)
    80004180:	6105                	addi	sp,sp,32
    80004182:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004184:	40bc                	lw	a5,64(s1)
    80004186:	dff1                	beqz	a5,80004162 <iput+0x26>
    80004188:	04a49783          	lh	a5,74(s1)
    8000418c:	fbf9                	bnez	a5,80004162 <iput+0x26>
    acquiresleep(&ip->lock);
    8000418e:	01048913          	addi	s2,s1,16
    80004192:	854a                	mv	a0,s2
    80004194:	00001097          	auipc	ra,0x1
    80004198:	aa8080e7          	jalr	-1368(ra) # 80004c3c <acquiresleep>
    release(&itable.lock);
    8000419c:	0023d517          	auipc	a0,0x23d
    800041a0:	c1450513          	addi	a0,a0,-1004 # 80240db0 <itable>
    800041a4:	ffffd097          	auipc	ra,0xffffd
    800041a8:	cb8080e7          	jalr	-840(ra) # 80000e5c <release>
    itrunc(ip);
    800041ac:	8526                	mv	a0,s1
    800041ae:	00000097          	auipc	ra,0x0
    800041b2:	ee2080e7          	jalr	-286(ra) # 80004090 <itrunc>
    ip->type = 0;
    800041b6:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800041ba:	8526                	mv	a0,s1
    800041bc:	00000097          	auipc	ra,0x0
    800041c0:	cfc080e7          	jalr	-772(ra) # 80003eb8 <iupdate>
    ip->valid = 0;
    800041c4:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800041c8:	854a                	mv	a0,s2
    800041ca:	00001097          	auipc	ra,0x1
    800041ce:	ac8080e7          	jalr	-1336(ra) # 80004c92 <releasesleep>
    acquire(&itable.lock);
    800041d2:	0023d517          	auipc	a0,0x23d
    800041d6:	bde50513          	addi	a0,a0,-1058 # 80240db0 <itable>
    800041da:	ffffd097          	auipc	ra,0xffffd
    800041de:	bce080e7          	jalr	-1074(ra) # 80000da8 <acquire>
    800041e2:	b741                	j	80004162 <iput+0x26>

00000000800041e4 <iunlockput>:
{
    800041e4:	1101                	addi	sp,sp,-32
    800041e6:	ec06                	sd	ra,24(sp)
    800041e8:	e822                	sd	s0,16(sp)
    800041ea:	e426                	sd	s1,8(sp)
    800041ec:	1000                	addi	s0,sp,32
    800041ee:	84aa                	mv	s1,a0
  iunlock(ip);
    800041f0:	00000097          	auipc	ra,0x0
    800041f4:	e54080e7          	jalr	-428(ra) # 80004044 <iunlock>
  iput(ip);
    800041f8:	8526                	mv	a0,s1
    800041fa:	00000097          	auipc	ra,0x0
    800041fe:	f42080e7          	jalr	-190(ra) # 8000413c <iput>
}
    80004202:	60e2                	ld	ra,24(sp)
    80004204:	6442                	ld	s0,16(sp)
    80004206:	64a2                	ld	s1,8(sp)
    80004208:	6105                	addi	sp,sp,32
    8000420a:	8082                	ret

000000008000420c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000420c:	1141                	addi	sp,sp,-16
    8000420e:	e422                	sd	s0,8(sp)
    80004210:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004212:	411c                	lw	a5,0(a0)
    80004214:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004216:	415c                	lw	a5,4(a0)
    80004218:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000421a:	04451783          	lh	a5,68(a0)
    8000421e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004222:	04a51783          	lh	a5,74(a0)
    80004226:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000422a:	04c56783          	lwu	a5,76(a0)
    8000422e:	e99c                	sd	a5,16(a1)
}
    80004230:	6422                	ld	s0,8(sp)
    80004232:	0141                	addi	sp,sp,16
    80004234:	8082                	ret

0000000080004236 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004236:	457c                	lw	a5,76(a0)
    80004238:	0ed7e963          	bltu	a5,a3,8000432a <readi+0xf4>
{
    8000423c:	7159                	addi	sp,sp,-112
    8000423e:	f486                	sd	ra,104(sp)
    80004240:	f0a2                	sd	s0,96(sp)
    80004242:	eca6                	sd	s1,88(sp)
    80004244:	e8ca                	sd	s2,80(sp)
    80004246:	e4ce                	sd	s3,72(sp)
    80004248:	e0d2                	sd	s4,64(sp)
    8000424a:	fc56                	sd	s5,56(sp)
    8000424c:	f85a                	sd	s6,48(sp)
    8000424e:	f45e                	sd	s7,40(sp)
    80004250:	f062                	sd	s8,32(sp)
    80004252:	ec66                	sd	s9,24(sp)
    80004254:	e86a                	sd	s10,16(sp)
    80004256:	e46e                	sd	s11,8(sp)
    80004258:	1880                	addi	s0,sp,112
    8000425a:	8b2a                	mv	s6,a0
    8000425c:	8bae                	mv	s7,a1
    8000425e:	8a32                	mv	s4,a2
    80004260:	84b6                	mv	s1,a3
    80004262:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80004264:	9f35                	addw	a4,a4,a3
    return 0;
    80004266:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004268:	0ad76063          	bltu	a4,a3,80004308 <readi+0xd2>
  if(off + n > ip->size)
    8000426c:	00e7f463          	bgeu	a5,a4,80004274 <readi+0x3e>
    n = ip->size - off;
    80004270:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004274:	0a0a8963          	beqz	s5,80004326 <readi+0xf0>
    80004278:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000427a:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000427e:	5c7d                	li	s8,-1
    80004280:	a82d                	j	800042ba <readi+0x84>
    80004282:	020d1d93          	slli	s11,s10,0x20
    80004286:	020ddd93          	srli	s11,s11,0x20
    8000428a:	05890613          	addi	a2,s2,88
    8000428e:	86ee                	mv	a3,s11
    80004290:	963a                	add	a2,a2,a4
    80004292:	85d2                	mv	a1,s4
    80004294:	855e                	mv	a0,s7
    80004296:	ffffe097          	auipc	ra,0xffffe
    8000429a:	76c080e7          	jalr	1900(ra) # 80002a02 <either_copyout>
    8000429e:	05850d63          	beq	a0,s8,800042f8 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800042a2:	854a                	mv	a0,s2
    800042a4:	fffff097          	auipc	ra,0xfffff
    800042a8:	5f4080e7          	jalr	1524(ra) # 80003898 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800042ac:	013d09bb          	addw	s3,s10,s3
    800042b0:	009d04bb          	addw	s1,s10,s1
    800042b4:	9a6e                	add	s4,s4,s11
    800042b6:	0559f763          	bgeu	s3,s5,80004304 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    800042ba:	00a4d59b          	srliw	a1,s1,0xa
    800042be:	855a                	mv	a0,s6
    800042c0:	00000097          	auipc	ra,0x0
    800042c4:	8a2080e7          	jalr	-1886(ra) # 80003b62 <bmap>
    800042c8:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800042cc:	cd85                	beqz	a1,80004304 <readi+0xce>
    bp = bread(ip->dev, addr);
    800042ce:	000b2503          	lw	a0,0(s6)
    800042d2:	fffff097          	auipc	ra,0xfffff
    800042d6:	496080e7          	jalr	1174(ra) # 80003768 <bread>
    800042da:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800042dc:	3ff4f713          	andi	a4,s1,1023
    800042e0:	40ec87bb          	subw	a5,s9,a4
    800042e4:	413a86bb          	subw	a3,s5,s3
    800042e8:	8d3e                	mv	s10,a5
    800042ea:	2781                	sext.w	a5,a5
    800042ec:	0006861b          	sext.w	a2,a3
    800042f0:	f8f679e3          	bgeu	a2,a5,80004282 <readi+0x4c>
    800042f4:	8d36                	mv	s10,a3
    800042f6:	b771                	j	80004282 <readi+0x4c>
      brelse(bp);
    800042f8:	854a                	mv	a0,s2
    800042fa:	fffff097          	auipc	ra,0xfffff
    800042fe:	59e080e7          	jalr	1438(ra) # 80003898 <brelse>
      tot = -1;
    80004302:	59fd                	li	s3,-1
  }
  return tot;
    80004304:	0009851b          	sext.w	a0,s3
}
    80004308:	70a6                	ld	ra,104(sp)
    8000430a:	7406                	ld	s0,96(sp)
    8000430c:	64e6                	ld	s1,88(sp)
    8000430e:	6946                	ld	s2,80(sp)
    80004310:	69a6                	ld	s3,72(sp)
    80004312:	6a06                	ld	s4,64(sp)
    80004314:	7ae2                	ld	s5,56(sp)
    80004316:	7b42                	ld	s6,48(sp)
    80004318:	7ba2                	ld	s7,40(sp)
    8000431a:	7c02                	ld	s8,32(sp)
    8000431c:	6ce2                	ld	s9,24(sp)
    8000431e:	6d42                	ld	s10,16(sp)
    80004320:	6da2                	ld	s11,8(sp)
    80004322:	6165                	addi	sp,sp,112
    80004324:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004326:	89d6                	mv	s3,s5
    80004328:	bff1                	j	80004304 <readi+0xce>
    return 0;
    8000432a:	4501                	li	a0,0
}
    8000432c:	8082                	ret

000000008000432e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000432e:	457c                	lw	a5,76(a0)
    80004330:	10d7e863          	bltu	a5,a3,80004440 <writei+0x112>
{
    80004334:	7159                	addi	sp,sp,-112
    80004336:	f486                	sd	ra,104(sp)
    80004338:	f0a2                	sd	s0,96(sp)
    8000433a:	eca6                	sd	s1,88(sp)
    8000433c:	e8ca                	sd	s2,80(sp)
    8000433e:	e4ce                	sd	s3,72(sp)
    80004340:	e0d2                	sd	s4,64(sp)
    80004342:	fc56                	sd	s5,56(sp)
    80004344:	f85a                	sd	s6,48(sp)
    80004346:	f45e                	sd	s7,40(sp)
    80004348:	f062                	sd	s8,32(sp)
    8000434a:	ec66                	sd	s9,24(sp)
    8000434c:	e86a                	sd	s10,16(sp)
    8000434e:	e46e                	sd	s11,8(sp)
    80004350:	1880                	addi	s0,sp,112
    80004352:	8aaa                	mv	s5,a0
    80004354:	8bae                	mv	s7,a1
    80004356:	8a32                	mv	s4,a2
    80004358:	8936                	mv	s2,a3
    8000435a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000435c:	00e687bb          	addw	a5,a3,a4
    80004360:	0ed7e263          	bltu	a5,a3,80004444 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004364:	00043737          	lui	a4,0x43
    80004368:	0ef76063          	bltu	a4,a5,80004448 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000436c:	0c0b0863          	beqz	s6,8000443c <writei+0x10e>
    80004370:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004372:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004376:	5c7d                	li	s8,-1
    80004378:	a091                	j	800043bc <writei+0x8e>
    8000437a:	020d1d93          	slli	s11,s10,0x20
    8000437e:	020ddd93          	srli	s11,s11,0x20
    80004382:	05848513          	addi	a0,s1,88
    80004386:	86ee                	mv	a3,s11
    80004388:	8652                	mv	a2,s4
    8000438a:	85de                	mv	a1,s7
    8000438c:	953a                	add	a0,a0,a4
    8000438e:	ffffe097          	auipc	ra,0xffffe
    80004392:	6ca080e7          	jalr	1738(ra) # 80002a58 <either_copyin>
    80004396:	07850263          	beq	a0,s8,800043fa <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000439a:	8526                	mv	a0,s1
    8000439c:	00000097          	auipc	ra,0x0
    800043a0:	780080e7          	jalr	1920(ra) # 80004b1c <log_write>
    brelse(bp);
    800043a4:	8526                	mv	a0,s1
    800043a6:	fffff097          	auipc	ra,0xfffff
    800043aa:	4f2080e7          	jalr	1266(ra) # 80003898 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800043ae:	013d09bb          	addw	s3,s10,s3
    800043b2:	012d093b          	addw	s2,s10,s2
    800043b6:	9a6e                	add	s4,s4,s11
    800043b8:	0569f663          	bgeu	s3,s6,80004404 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    800043bc:	00a9559b          	srliw	a1,s2,0xa
    800043c0:	8556                	mv	a0,s5
    800043c2:	fffff097          	auipc	ra,0xfffff
    800043c6:	7a0080e7          	jalr	1952(ra) # 80003b62 <bmap>
    800043ca:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800043ce:	c99d                	beqz	a1,80004404 <writei+0xd6>
    bp = bread(ip->dev, addr);
    800043d0:	000aa503          	lw	a0,0(s5)
    800043d4:	fffff097          	auipc	ra,0xfffff
    800043d8:	394080e7          	jalr	916(ra) # 80003768 <bread>
    800043dc:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800043de:	3ff97713          	andi	a4,s2,1023
    800043e2:	40ec87bb          	subw	a5,s9,a4
    800043e6:	413b06bb          	subw	a3,s6,s3
    800043ea:	8d3e                	mv	s10,a5
    800043ec:	2781                	sext.w	a5,a5
    800043ee:	0006861b          	sext.w	a2,a3
    800043f2:	f8f674e3          	bgeu	a2,a5,8000437a <writei+0x4c>
    800043f6:	8d36                	mv	s10,a3
    800043f8:	b749                	j	8000437a <writei+0x4c>
      brelse(bp);
    800043fa:	8526                	mv	a0,s1
    800043fc:	fffff097          	auipc	ra,0xfffff
    80004400:	49c080e7          	jalr	1180(ra) # 80003898 <brelse>
  }

  if(off > ip->size)
    80004404:	04caa783          	lw	a5,76(s5)
    80004408:	0127f463          	bgeu	a5,s2,80004410 <writei+0xe2>
    ip->size = off;
    8000440c:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004410:	8556                	mv	a0,s5
    80004412:	00000097          	auipc	ra,0x0
    80004416:	aa6080e7          	jalr	-1370(ra) # 80003eb8 <iupdate>

  return tot;
    8000441a:	0009851b          	sext.w	a0,s3
}
    8000441e:	70a6                	ld	ra,104(sp)
    80004420:	7406                	ld	s0,96(sp)
    80004422:	64e6                	ld	s1,88(sp)
    80004424:	6946                	ld	s2,80(sp)
    80004426:	69a6                	ld	s3,72(sp)
    80004428:	6a06                	ld	s4,64(sp)
    8000442a:	7ae2                	ld	s5,56(sp)
    8000442c:	7b42                	ld	s6,48(sp)
    8000442e:	7ba2                	ld	s7,40(sp)
    80004430:	7c02                	ld	s8,32(sp)
    80004432:	6ce2                	ld	s9,24(sp)
    80004434:	6d42                	ld	s10,16(sp)
    80004436:	6da2                	ld	s11,8(sp)
    80004438:	6165                	addi	sp,sp,112
    8000443a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000443c:	89da                	mv	s3,s6
    8000443e:	bfc9                	j	80004410 <writei+0xe2>
    return -1;
    80004440:	557d                	li	a0,-1
}
    80004442:	8082                	ret
    return -1;
    80004444:	557d                	li	a0,-1
    80004446:	bfe1                	j	8000441e <writei+0xf0>
    return -1;
    80004448:	557d                	li	a0,-1
    8000444a:	bfd1                	j	8000441e <writei+0xf0>

000000008000444c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000444c:	1141                	addi	sp,sp,-16
    8000444e:	e406                	sd	ra,8(sp)
    80004450:	e022                	sd	s0,0(sp)
    80004452:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004454:	4639                	li	a2,14
    80004456:	ffffd097          	auipc	ra,0xffffd
    8000445a:	b26080e7          	jalr	-1242(ra) # 80000f7c <strncmp>
}
    8000445e:	60a2                	ld	ra,8(sp)
    80004460:	6402                	ld	s0,0(sp)
    80004462:	0141                	addi	sp,sp,16
    80004464:	8082                	ret

0000000080004466 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004466:	7139                	addi	sp,sp,-64
    80004468:	fc06                	sd	ra,56(sp)
    8000446a:	f822                	sd	s0,48(sp)
    8000446c:	f426                	sd	s1,40(sp)
    8000446e:	f04a                	sd	s2,32(sp)
    80004470:	ec4e                	sd	s3,24(sp)
    80004472:	e852                	sd	s4,16(sp)
    80004474:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004476:	04451703          	lh	a4,68(a0)
    8000447a:	4785                	li	a5,1
    8000447c:	00f71a63          	bne	a4,a5,80004490 <dirlookup+0x2a>
    80004480:	892a                	mv	s2,a0
    80004482:	89ae                	mv	s3,a1
    80004484:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004486:	457c                	lw	a5,76(a0)
    80004488:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000448a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000448c:	e79d                	bnez	a5,800044ba <dirlookup+0x54>
    8000448e:	a8a5                	j	80004506 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004490:	00004517          	auipc	a0,0x4
    80004494:	2e050513          	addi	a0,a0,736 # 80008770 <syscalls+0x1c8>
    80004498:	ffffc097          	auipc	ra,0xffffc
    8000449c:	0ac080e7          	jalr	172(ra) # 80000544 <panic>
      panic("dirlookup read");
    800044a0:	00004517          	auipc	a0,0x4
    800044a4:	2e850513          	addi	a0,a0,744 # 80008788 <syscalls+0x1e0>
    800044a8:	ffffc097          	auipc	ra,0xffffc
    800044ac:	09c080e7          	jalr	156(ra) # 80000544 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800044b0:	24c1                	addiw	s1,s1,16
    800044b2:	04c92783          	lw	a5,76(s2)
    800044b6:	04f4f763          	bgeu	s1,a5,80004504 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800044ba:	4741                	li	a4,16
    800044bc:	86a6                	mv	a3,s1
    800044be:	fc040613          	addi	a2,s0,-64
    800044c2:	4581                	li	a1,0
    800044c4:	854a                	mv	a0,s2
    800044c6:	00000097          	auipc	ra,0x0
    800044ca:	d70080e7          	jalr	-656(ra) # 80004236 <readi>
    800044ce:	47c1                	li	a5,16
    800044d0:	fcf518e3          	bne	a0,a5,800044a0 <dirlookup+0x3a>
    if(de.inum == 0)
    800044d4:	fc045783          	lhu	a5,-64(s0)
    800044d8:	dfe1                	beqz	a5,800044b0 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800044da:	fc240593          	addi	a1,s0,-62
    800044de:	854e                	mv	a0,s3
    800044e0:	00000097          	auipc	ra,0x0
    800044e4:	f6c080e7          	jalr	-148(ra) # 8000444c <namecmp>
    800044e8:	f561                	bnez	a0,800044b0 <dirlookup+0x4a>
      if(poff)
    800044ea:	000a0463          	beqz	s4,800044f2 <dirlookup+0x8c>
        *poff = off;
    800044ee:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800044f2:	fc045583          	lhu	a1,-64(s0)
    800044f6:	00092503          	lw	a0,0(s2)
    800044fa:	fffff097          	auipc	ra,0xfffff
    800044fe:	750080e7          	jalr	1872(ra) # 80003c4a <iget>
    80004502:	a011                	j	80004506 <dirlookup+0xa0>
  return 0;
    80004504:	4501                	li	a0,0
}
    80004506:	70e2                	ld	ra,56(sp)
    80004508:	7442                	ld	s0,48(sp)
    8000450a:	74a2                	ld	s1,40(sp)
    8000450c:	7902                	ld	s2,32(sp)
    8000450e:	69e2                	ld	s3,24(sp)
    80004510:	6a42                	ld	s4,16(sp)
    80004512:	6121                	addi	sp,sp,64
    80004514:	8082                	ret

0000000080004516 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004516:	711d                	addi	sp,sp,-96
    80004518:	ec86                	sd	ra,88(sp)
    8000451a:	e8a2                	sd	s0,80(sp)
    8000451c:	e4a6                	sd	s1,72(sp)
    8000451e:	e0ca                	sd	s2,64(sp)
    80004520:	fc4e                	sd	s3,56(sp)
    80004522:	f852                	sd	s4,48(sp)
    80004524:	f456                	sd	s5,40(sp)
    80004526:	f05a                	sd	s6,32(sp)
    80004528:	ec5e                	sd	s7,24(sp)
    8000452a:	e862                	sd	s8,16(sp)
    8000452c:	e466                	sd	s9,8(sp)
    8000452e:	1080                	addi	s0,sp,96
    80004530:	84aa                	mv	s1,a0
    80004532:	8b2e                	mv	s6,a1
    80004534:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004536:	00054703          	lbu	a4,0(a0)
    8000453a:	02f00793          	li	a5,47
    8000453e:	02f70363          	beq	a4,a5,80004564 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004542:	ffffd097          	auipc	ra,0xffffd
    80004546:	776080e7          	jalr	1910(ra) # 80001cb8 <myproc>
    8000454a:	15853503          	ld	a0,344(a0)
    8000454e:	00000097          	auipc	ra,0x0
    80004552:	9f6080e7          	jalr	-1546(ra) # 80003f44 <idup>
    80004556:	89aa                	mv	s3,a0
  while(*path == '/')
    80004558:	02f00913          	li	s2,47
  len = path - s;
    8000455c:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    8000455e:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004560:	4c05                	li	s8,1
    80004562:	a865                	j	8000461a <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80004564:	4585                	li	a1,1
    80004566:	4505                	li	a0,1
    80004568:	fffff097          	auipc	ra,0xfffff
    8000456c:	6e2080e7          	jalr	1762(ra) # 80003c4a <iget>
    80004570:	89aa                	mv	s3,a0
    80004572:	b7dd                	j	80004558 <namex+0x42>
      iunlockput(ip);
    80004574:	854e                	mv	a0,s3
    80004576:	00000097          	auipc	ra,0x0
    8000457a:	c6e080e7          	jalr	-914(ra) # 800041e4 <iunlockput>
      return 0;
    8000457e:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004580:	854e                	mv	a0,s3
    80004582:	60e6                	ld	ra,88(sp)
    80004584:	6446                	ld	s0,80(sp)
    80004586:	64a6                	ld	s1,72(sp)
    80004588:	6906                	ld	s2,64(sp)
    8000458a:	79e2                	ld	s3,56(sp)
    8000458c:	7a42                	ld	s4,48(sp)
    8000458e:	7aa2                	ld	s5,40(sp)
    80004590:	7b02                	ld	s6,32(sp)
    80004592:	6be2                	ld	s7,24(sp)
    80004594:	6c42                	ld	s8,16(sp)
    80004596:	6ca2                	ld	s9,8(sp)
    80004598:	6125                	addi	sp,sp,96
    8000459a:	8082                	ret
      iunlock(ip);
    8000459c:	854e                	mv	a0,s3
    8000459e:	00000097          	auipc	ra,0x0
    800045a2:	aa6080e7          	jalr	-1370(ra) # 80004044 <iunlock>
      return ip;
    800045a6:	bfe9                	j	80004580 <namex+0x6a>
      iunlockput(ip);
    800045a8:	854e                	mv	a0,s3
    800045aa:	00000097          	auipc	ra,0x0
    800045ae:	c3a080e7          	jalr	-966(ra) # 800041e4 <iunlockput>
      return 0;
    800045b2:	89d2                	mv	s3,s4
    800045b4:	b7f1                	j	80004580 <namex+0x6a>
  len = path - s;
    800045b6:	40b48633          	sub	a2,s1,a1
    800045ba:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    800045be:	094cd463          	bge	s9,s4,80004646 <namex+0x130>
    memmove(name, s, DIRSIZ);
    800045c2:	4639                	li	a2,14
    800045c4:	8556                	mv	a0,s5
    800045c6:	ffffd097          	auipc	ra,0xffffd
    800045ca:	93e080e7          	jalr	-1730(ra) # 80000f04 <memmove>
  while(*path == '/')
    800045ce:	0004c783          	lbu	a5,0(s1)
    800045d2:	01279763          	bne	a5,s2,800045e0 <namex+0xca>
    path++;
    800045d6:	0485                	addi	s1,s1,1
  while(*path == '/')
    800045d8:	0004c783          	lbu	a5,0(s1)
    800045dc:	ff278de3          	beq	a5,s2,800045d6 <namex+0xc0>
    ilock(ip);
    800045e0:	854e                	mv	a0,s3
    800045e2:	00000097          	auipc	ra,0x0
    800045e6:	9a0080e7          	jalr	-1632(ra) # 80003f82 <ilock>
    if(ip->type != T_DIR){
    800045ea:	04499783          	lh	a5,68(s3)
    800045ee:	f98793e3          	bne	a5,s8,80004574 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800045f2:	000b0563          	beqz	s6,800045fc <namex+0xe6>
    800045f6:	0004c783          	lbu	a5,0(s1)
    800045fa:	d3cd                	beqz	a5,8000459c <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800045fc:	865e                	mv	a2,s7
    800045fe:	85d6                	mv	a1,s5
    80004600:	854e                	mv	a0,s3
    80004602:	00000097          	auipc	ra,0x0
    80004606:	e64080e7          	jalr	-412(ra) # 80004466 <dirlookup>
    8000460a:	8a2a                	mv	s4,a0
    8000460c:	dd51                	beqz	a0,800045a8 <namex+0x92>
    iunlockput(ip);
    8000460e:	854e                	mv	a0,s3
    80004610:	00000097          	auipc	ra,0x0
    80004614:	bd4080e7          	jalr	-1068(ra) # 800041e4 <iunlockput>
    ip = next;
    80004618:	89d2                	mv	s3,s4
  while(*path == '/')
    8000461a:	0004c783          	lbu	a5,0(s1)
    8000461e:	05279763          	bne	a5,s2,8000466c <namex+0x156>
    path++;
    80004622:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004624:	0004c783          	lbu	a5,0(s1)
    80004628:	ff278de3          	beq	a5,s2,80004622 <namex+0x10c>
  if(*path == 0)
    8000462c:	c79d                	beqz	a5,8000465a <namex+0x144>
    path++;
    8000462e:	85a6                	mv	a1,s1
  len = path - s;
    80004630:	8a5e                	mv	s4,s7
    80004632:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80004634:	01278963          	beq	a5,s2,80004646 <namex+0x130>
    80004638:	dfbd                	beqz	a5,800045b6 <namex+0xa0>
    path++;
    8000463a:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000463c:	0004c783          	lbu	a5,0(s1)
    80004640:	ff279ce3          	bne	a5,s2,80004638 <namex+0x122>
    80004644:	bf8d                	j	800045b6 <namex+0xa0>
    memmove(name, s, len);
    80004646:	2601                	sext.w	a2,a2
    80004648:	8556                	mv	a0,s5
    8000464a:	ffffd097          	auipc	ra,0xffffd
    8000464e:	8ba080e7          	jalr	-1862(ra) # 80000f04 <memmove>
    name[len] = 0;
    80004652:	9a56                	add	s4,s4,s5
    80004654:	000a0023          	sb	zero,0(s4)
    80004658:	bf9d                	j	800045ce <namex+0xb8>
  if(nameiparent){
    8000465a:	f20b03e3          	beqz	s6,80004580 <namex+0x6a>
    iput(ip);
    8000465e:	854e                	mv	a0,s3
    80004660:	00000097          	auipc	ra,0x0
    80004664:	adc080e7          	jalr	-1316(ra) # 8000413c <iput>
    return 0;
    80004668:	4981                	li	s3,0
    8000466a:	bf19                	j	80004580 <namex+0x6a>
  if(*path == 0)
    8000466c:	d7fd                	beqz	a5,8000465a <namex+0x144>
  while(*path != '/' && *path != 0)
    8000466e:	0004c783          	lbu	a5,0(s1)
    80004672:	85a6                	mv	a1,s1
    80004674:	b7d1                	j	80004638 <namex+0x122>

0000000080004676 <dirlink>:
{
    80004676:	7139                	addi	sp,sp,-64
    80004678:	fc06                	sd	ra,56(sp)
    8000467a:	f822                	sd	s0,48(sp)
    8000467c:	f426                	sd	s1,40(sp)
    8000467e:	f04a                	sd	s2,32(sp)
    80004680:	ec4e                	sd	s3,24(sp)
    80004682:	e852                	sd	s4,16(sp)
    80004684:	0080                	addi	s0,sp,64
    80004686:	892a                	mv	s2,a0
    80004688:	8a2e                	mv	s4,a1
    8000468a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000468c:	4601                	li	a2,0
    8000468e:	00000097          	auipc	ra,0x0
    80004692:	dd8080e7          	jalr	-552(ra) # 80004466 <dirlookup>
    80004696:	e93d                	bnez	a0,8000470c <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004698:	04c92483          	lw	s1,76(s2)
    8000469c:	c49d                	beqz	s1,800046ca <dirlink+0x54>
    8000469e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800046a0:	4741                	li	a4,16
    800046a2:	86a6                	mv	a3,s1
    800046a4:	fc040613          	addi	a2,s0,-64
    800046a8:	4581                	li	a1,0
    800046aa:	854a                	mv	a0,s2
    800046ac:	00000097          	auipc	ra,0x0
    800046b0:	b8a080e7          	jalr	-1142(ra) # 80004236 <readi>
    800046b4:	47c1                	li	a5,16
    800046b6:	06f51163          	bne	a0,a5,80004718 <dirlink+0xa2>
    if(de.inum == 0)
    800046ba:	fc045783          	lhu	a5,-64(s0)
    800046be:	c791                	beqz	a5,800046ca <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800046c0:	24c1                	addiw	s1,s1,16
    800046c2:	04c92783          	lw	a5,76(s2)
    800046c6:	fcf4ede3          	bltu	s1,a5,800046a0 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800046ca:	4639                	li	a2,14
    800046cc:	85d2                	mv	a1,s4
    800046ce:	fc240513          	addi	a0,s0,-62
    800046d2:	ffffd097          	auipc	ra,0xffffd
    800046d6:	8e6080e7          	jalr	-1818(ra) # 80000fb8 <strncpy>
  de.inum = inum;
    800046da:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800046de:	4741                	li	a4,16
    800046e0:	86a6                	mv	a3,s1
    800046e2:	fc040613          	addi	a2,s0,-64
    800046e6:	4581                	li	a1,0
    800046e8:	854a                	mv	a0,s2
    800046ea:	00000097          	auipc	ra,0x0
    800046ee:	c44080e7          	jalr	-956(ra) # 8000432e <writei>
    800046f2:	1541                	addi	a0,a0,-16
    800046f4:	00a03533          	snez	a0,a0
    800046f8:	40a00533          	neg	a0,a0
}
    800046fc:	70e2                	ld	ra,56(sp)
    800046fe:	7442                	ld	s0,48(sp)
    80004700:	74a2                	ld	s1,40(sp)
    80004702:	7902                	ld	s2,32(sp)
    80004704:	69e2                	ld	s3,24(sp)
    80004706:	6a42                	ld	s4,16(sp)
    80004708:	6121                	addi	sp,sp,64
    8000470a:	8082                	ret
    iput(ip);
    8000470c:	00000097          	auipc	ra,0x0
    80004710:	a30080e7          	jalr	-1488(ra) # 8000413c <iput>
    return -1;
    80004714:	557d                	li	a0,-1
    80004716:	b7dd                	j	800046fc <dirlink+0x86>
      panic("dirlink read");
    80004718:	00004517          	auipc	a0,0x4
    8000471c:	08050513          	addi	a0,a0,128 # 80008798 <syscalls+0x1f0>
    80004720:	ffffc097          	auipc	ra,0xffffc
    80004724:	e24080e7          	jalr	-476(ra) # 80000544 <panic>

0000000080004728 <namei>:

struct inode*
namei(char *path)
{
    80004728:	1101                	addi	sp,sp,-32
    8000472a:	ec06                	sd	ra,24(sp)
    8000472c:	e822                	sd	s0,16(sp)
    8000472e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004730:	fe040613          	addi	a2,s0,-32
    80004734:	4581                	li	a1,0
    80004736:	00000097          	auipc	ra,0x0
    8000473a:	de0080e7          	jalr	-544(ra) # 80004516 <namex>
}
    8000473e:	60e2                	ld	ra,24(sp)
    80004740:	6442                	ld	s0,16(sp)
    80004742:	6105                	addi	sp,sp,32
    80004744:	8082                	ret

0000000080004746 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004746:	1141                	addi	sp,sp,-16
    80004748:	e406                	sd	ra,8(sp)
    8000474a:	e022                	sd	s0,0(sp)
    8000474c:	0800                	addi	s0,sp,16
    8000474e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004750:	4585                	li	a1,1
    80004752:	00000097          	auipc	ra,0x0
    80004756:	dc4080e7          	jalr	-572(ra) # 80004516 <namex>
}
    8000475a:	60a2                	ld	ra,8(sp)
    8000475c:	6402                	ld	s0,0(sp)
    8000475e:	0141                	addi	sp,sp,16
    80004760:	8082                	ret

0000000080004762 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004762:	1101                	addi	sp,sp,-32
    80004764:	ec06                	sd	ra,24(sp)
    80004766:	e822                	sd	s0,16(sp)
    80004768:	e426                	sd	s1,8(sp)
    8000476a:	e04a                	sd	s2,0(sp)
    8000476c:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000476e:	0023e917          	auipc	s2,0x23e
    80004772:	0ea90913          	addi	s2,s2,234 # 80242858 <log>
    80004776:	01892583          	lw	a1,24(s2)
    8000477a:	02892503          	lw	a0,40(s2)
    8000477e:	fffff097          	auipc	ra,0xfffff
    80004782:	fea080e7          	jalr	-22(ra) # 80003768 <bread>
    80004786:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004788:	02c92683          	lw	a3,44(s2)
    8000478c:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000478e:	02d05763          	blez	a3,800047bc <write_head+0x5a>
    80004792:	0023e797          	auipc	a5,0x23e
    80004796:	0f678793          	addi	a5,a5,246 # 80242888 <log+0x30>
    8000479a:	05c50713          	addi	a4,a0,92
    8000479e:	36fd                	addiw	a3,a3,-1
    800047a0:	1682                	slli	a3,a3,0x20
    800047a2:	9281                	srli	a3,a3,0x20
    800047a4:	068a                	slli	a3,a3,0x2
    800047a6:	0023e617          	auipc	a2,0x23e
    800047aa:	0e660613          	addi	a2,a2,230 # 8024288c <log+0x34>
    800047ae:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800047b0:	4390                	lw	a2,0(a5)
    800047b2:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800047b4:	0791                	addi	a5,a5,4
    800047b6:	0711                	addi	a4,a4,4
    800047b8:	fed79ce3          	bne	a5,a3,800047b0 <write_head+0x4e>
  }
  bwrite(buf);
    800047bc:	8526                	mv	a0,s1
    800047be:	fffff097          	auipc	ra,0xfffff
    800047c2:	09c080e7          	jalr	156(ra) # 8000385a <bwrite>
  brelse(buf);
    800047c6:	8526                	mv	a0,s1
    800047c8:	fffff097          	auipc	ra,0xfffff
    800047cc:	0d0080e7          	jalr	208(ra) # 80003898 <brelse>
}
    800047d0:	60e2                	ld	ra,24(sp)
    800047d2:	6442                	ld	s0,16(sp)
    800047d4:	64a2                	ld	s1,8(sp)
    800047d6:	6902                	ld	s2,0(sp)
    800047d8:	6105                	addi	sp,sp,32
    800047da:	8082                	ret

00000000800047dc <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800047dc:	0023e797          	auipc	a5,0x23e
    800047e0:	0a87a783          	lw	a5,168(a5) # 80242884 <log+0x2c>
    800047e4:	0af05d63          	blez	a5,8000489e <install_trans+0xc2>
{
    800047e8:	7139                	addi	sp,sp,-64
    800047ea:	fc06                	sd	ra,56(sp)
    800047ec:	f822                	sd	s0,48(sp)
    800047ee:	f426                	sd	s1,40(sp)
    800047f0:	f04a                	sd	s2,32(sp)
    800047f2:	ec4e                	sd	s3,24(sp)
    800047f4:	e852                	sd	s4,16(sp)
    800047f6:	e456                	sd	s5,8(sp)
    800047f8:	e05a                	sd	s6,0(sp)
    800047fa:	0080                	addi	s0,sp,64
    800047fc:	8b2a                	mv	s6,a0
    800047fe:	0023ea97          	auipc	s5,0x23e
    80004802:	08aa8a93          	addi	s5,s5,138 # 80242888 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004806:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004808:	0023e997          	auipc	s3,0x23e
    8000480c:	05098993          	addi	s3,s3,80 # 80242858 <log>
    80004810:	a035                	j	8000483c <install_trans+0x60>
      bunpin(dbuf);
    80004812:	8526                	mv	a0,s1
    80004814:	fffff097          	auipc	ra,0xfffff
    80004818:	15e080e7          	jalr	350(ra) # 80003972 <bunpin>
    brelse(lbuf);
    8000481c:	854a                	mv	a0,s2
    8000481e:	fffff097          	auipc	ra,0xfffff
    80004822:	07a080e7          	jalr	122(ra) # 80003898 <brelse>
    brelse(dbuf);
    80004826:	8526                	mv	a0,s1
    80004828:	fffff097          	auipc	ra,0xfffff
    8000482c:	070080e7          	jalr	112(ra) # 80003898 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004830:	2a05                	addiw	s4,s4,1
    80004832:	0a91                	addi	s5,s5,4
    80004834:	02c9a783          	lw	a5,44(s3)
    80004838:	04fa5963          	bge	s4,a5,8000488a <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000483c:	0189a583          	lw	a1,24(s3)
    80004840:	014585bb          	addw	a1,a1,s4
    80004844:	2585                	addiw	a1,a1,1
    80004846:	0289a503          	lw	a0,40(s3)
    8000484a:	fffff097          	auipc	ra,0xfffff
    8000484e:	f1e080e7          	jalr	-226(ra) # 80003768 <bread>
    80004852:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004854:	000aa583          	lw	a1,0(s5)
    80004858:	0289a503          	lw	a0,40(s3)
    8000485c:	fffff097          	auipc	ra,0xfffff
    80004860:	f0c080e7          	jalr	-244(ra) # 80003768 <bread>
    80004864:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004866:	40000613          	li	a2,1024
    8000486a:	05890593          	addi	a1,s2,88
    8000486e:	05850513          	addi	a0,a0,88
    80004872:	ffffc097          	auipc	ra,0xffffc
    80004876:	692080e7          	jalr	1682(ra) # 80000f04 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000487a:	8526                	mv	a0,s1
    8000487c:	fffff097          	auipc	ra,0xfffff
    80004880:	fde080e7          	jalr	-34(ra) # 8000385a <bwrite>
    if(recovering == 0)
    80004884:	f80b1ce3          	bnez	s6,8000481c <install_trans+0x40>
    80004888:	b769                	j	80004812 <install_trans+0x36>
}
    8000488a:	70e2                	ld	ra,56(sp)
    8000488c:	7442                	ld	s0,48(sp)
    8000488e:	74a2                	ld	s1,40(sp)
    80004890:	7902                	ld	s2,32(sp)
    80004892:	69e2                	ld	s3,24(sp)
    80004894:	6a42                	ld	s4,16(sp)
    80004896:	6aa2                	ld	s5,8(sp)
    80004898:	6b02                	ld	s6,0(sp)
    8000489a:	6121                	addi	sp,sp,64
    8000489c:	8082                	ret
    8000489e:	8082                	ret

00000000800048a0 <initlog>:
{
    800048a0:	7179                	addi	sp,sp,-48
    800048a2:	f406                	sd	ra,40(sp)
    800048a4:	f022                	sd	s0,32(sp)
    800048a6:	ec26                	sd	s1,24(sp)
    800048a8:	e84a                	sd	s2,16(sp)
    800048aa:	e44e                	sd	s3,8(sp)
    800048ac:	1800                	addi	s0,sp,48
    800048ae:	892a                	mv	s2,a0
    800048b0:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800048b2:	0023e497          	auipc	s1,0x23e
    800048b6:	fa648493          	addi	s1,s1,-90 # 80242858 <log>
    800048ba:	00004597          	auipc	a1,0x4
    800048be:	eee58593          	addi	a1,a1,-274 # 800087a8 <syscalls+0x200>
    800048c2:	8526                	mv	a0,s1
    800048c4:	ffffc097          	auipc	ra,0xffffc
    800048c8:	454080e7          	jalr	1108(ra) # 80000d18 <initlock>
  log.start = sb->logstart;
    800048cc:	0149a583          	lw	a1,20(s3)
    800048d0:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800048d2:	0109a783          	lw	a5,16(s3)
    800048d6:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800048d8:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800048dc:	854a                	mv	a0,s2
    800048de:	fffff097          	auipc	ra,0xfffff
    800048e2:	e8a080e7          	jalr	-374(ra) # 80003768 <bread>
  log.lh.n = lh->n;
    800048e6:	4d3c                	lw	a5,88(a0)
    800048e8:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800048ea:	02f05563          	blez	a5,80004914 <initlog+0x74>
    800048ee:	05c50713          	addi	a4,a0,92
    800048f2:	0023e697          	auipc	a3,0x23e
    800048f6:	f9668693          	addi	a3,a3,-106 # 80242888 <log+0x30>
    800048fa:	37fd                	addiw	a5,a5,-1
    800048fc:	1782                	slli	a5,a5,0x20
    800048fe:	9381                	srli	a5,a5,0x20
    80004900:	078a                	slli	a5,a5,0x2
    80004902:	06050613          	addi	a2,a0,96
    80004906:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80004908:	4310                	lw	a2,0(a4)
    8000490a:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    8000490c:	0711                	addi	a4,a4,4
    8000490e:	0691                	addi	a3,a3,4
    80004910:	fef71ce3          	bne	a4,a5,80004908 <initlog+0x68>
  brelse(buf);
    80004914:	fffff097          	auipc	ra,0xfffff
    80004918:	f84080e7          	jalr	-124(ra) # 80003898 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000491c:	4505                	li	a0,1
    8000491e:	00000097          	auipc	ra,0x0
    80004922:	ebe080e7          	jalr	-322(ra) # 800047dc <install_trans>
  log.lh.n = 0;
    80004926:	0023e797          	auipc	a5,0x23e
    8000492a:	f407af23          	sw	zero,-162(a5) # 80242884 <log+0x2c>
  write_head(); // clear the log
    8000492e:	00000097          	auipc	ra,0x0
    80004932:	e34080e7          	jalr	-460(ra) # 80004762 <write_head>
}
    80004936:	70a2                	ld	ra,40(sp)
    80004938:	7402                	ld	s0,32(sp)
    8000493a:	64e2                	ld	s1,24(sp)
    8000493c:	6942                	ld	s2,16(sp)
    8000493e:	69a2                	ld	s3,8(sp)
    80004940:	6145                	addi	sp,sp,48
    80004942:	8082                	ret

0000000080004944 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004944:	1101                	addi	sp,sp,-32
    80004946:	ec06                	sd	ra,24(sp)
    80004948:	e822                	sd	s0,16(sp)
    8000494a:	e426                	sd	s1,8(sp)
    8000494c:	e04a                	sd	s2,0(sp)
    8000494e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004950:	0023e517          	auipc	a0,0x23e
    80004954:	f0850513          	addi	a0,a0,-248 # 80242858 <log>
    80004958:	ffffc097          	auipc	ra,0xffffc
    8000495c:	450080e7          	jalr	1104(ra) # 80000da8 <acquire>
  while(1){
    if(log.committing){
    80004960:	0023e497          	auipc	s1,0x23e
    80004964:	ef848493          	addi	s1,s1,-264 # 80242858 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004968:	4979                	li	s2,30
    8000496a:	a039                	j	80004978 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000496c:	85a6                	mv	a1,s1
    8000496e:	8526                	mv	a0,s1
    80004970:	ffffe097          	auipc	ra,0xffffe
    80004974:	ab8080e7          	jalr	-1352(ra) # 80002428 <sleep>
    if(log.committing){
    80004978:	50dc                	lw	a5,36(s1)
    8000497a:	fbed                	bnez	a5,8000496c <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000497c:	509c                	lw	a5,32(s1)
    8000497e:	0017871b          	addiw	a4,a5,1
    80004982:	0007069b          	sext.w	a3,a4
    80004986:	0027179b          	slliw	a5,a4,0x2
    8000498a:	9fb9                	addw	a5,a5,a4
    8000498c:	0017979b          	slliw	a5,a5,0x1
    80004990:	54d8                	lw	a4,44(s1)
    80004992:	9fb9                	addw	a5,a5,a4
    80004994:	00f95963          	bge	s2,a5,800049a6 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004998:	85a6                	mv	a1,s1
    8000499a:	8526                	mv	a0,s1
    8000499c:	ffffe097          	auipc	ra,0xffffe
    800049a0:	a8c080e7          	jalr	-1396(ra) # 80002428 <sleep>
    800049a4:	bfd1                	j	80004978 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800049a6:	0023e517          	auipc	a0,0x23e
    800049aa:	eb250513          	addi	a0,a0,-334 # 80242858 <log>
    800049ae:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800049b0:	ffffc097          	auipc	ra,0xffffc
    800049b4:	4ac080e7          	jalr	1196(ra) # 80000e5c <release>
      break;
    }
  }
}
    800049b8:	60e2                	ld	ra,24(sp)
    800049ba:	6442                	ld	s0,16(sp)
    800049bc:	64a2                	ld	s1,8(sp)
    800049be:	6902                	ld	s2,0(sp)
    800049c0:	6105                	addi	sp,sp,32
    800049c2:	8082                	ret

00000000800049c4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800049c4:	7139                	addi	sp,sp,-64
    800049c6:	fc06                	sd	ra,56(sp)
    800049c8:	f822                	sd	s0,48(sp)
    800049ca:	f426                	sd	s1,40(sp)
    800049cc:	f04a                	sd	s2,32(sp)
    800049ce:	ec4e                	sd	s3,24(sp)
    800049d0:	e852                	sd	s4,16(sp)
    800049d2:	e456                	sd	s5,8(sp)
    800049d4:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800049d6:	0023e497          	auipc	s1,0x23e
    800049da:	e8248493          	addi	s1,s1,-382 # 80242858 <log>
    800049de:	8526                	mv	a0,s1
    800049e0:	ffffc097          	auipc	ra,0xffffc
    800049e4:	3c8080e7          	jalr	968(ra) # 80000da8 <acquire>
  log.outstanding -= 1;
    800049e8:	509c                	lw	a5,32(s1)
    800049ea:	37fd                	addiw	a5,a5,-1
    800049ec:	0007891b          	sext.w	s2,a5
    800049f0:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800049f2:	50dc                	lw	a5,36(s1)
    800049f4:	efb9                	bnez	a5,80004a52 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    800049f6:	06091663          	bnez	s2,80004a62 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    800049fa:	0023e497          	auipc	s1,0x23e
    800049fe:	e5e48493          	addi	s1,s1,-418 # 80242858 <log>
    80004a02:	4785                	li	a5,1
    80004a04:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004a06:	8526                	mv	a0,s1
    80004a08:	ffffc097          	auipc	ra,0xffffc
    80004a0c:	454080e7          	jalr	1108(ra) # 80000e5c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004a10:	54dc                	lw	a5,44(s1)
    80004a12:	06f04763          	bgtz	a5,80004a80 <end_op+0xbc>
    acquire(&log.lock);
    80004a16:	0023e497          	auipc	s1,0x23e
    80004a1a:	e4248493          	addi	s1,s1,-446 # 80242858 <log>
    80004a1e:	8526                	mv	a0,s1
    80004a20:	ffffc097          	auipc	ra,0xffffc
    80004a24:	388080e7          	jalr	904(ra) # 80000da8 <acquire>
    log.committing = 0;
    80004a28:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004a2c:	8526                	mv	a0,s1
    80004a2e:	ffffe097          	auipc	ra,0xffffe
    80004a32:	cf8080e7          	jalr	-776(ra) # 80002726 <wakeup>
    release(&log.lock);
    80004a36:	8526                	mv	a0,s1
    80004a38:	ffffc097          	auipc	ra,0xffffc
    80004a3c:	424080e7          	jalr	1060(ra) # 80000e5c <release>
}
    80004a40:	70e2                	ld	ra,56(sp)
    80004a42:	7442                	ld	s0,48(sp)
    80004a44:	74a2                	ld	s1,40(sp)
    80004a46:	7902                	ld	s2,32(sp)
    80004a48:	69e2                	ld	s3,24(sp)
    80004a4a:	6a42                	ld	s4,16(sp)
    80004a4c:	6aa2                	ld	s5,8(sp)
    80004a4e:	6121                	addi	sp,sp,64
    80004a50:	8082                	ret
    panic("log.committing");
    80004a52:	00004517          	auipc	a0,0x4
    80004a56:	d5e50513          	addi	a0,a0,-674 # 800087b0 <syscalls+0x208>
    80004a5a:	ffffc097          	auipc	ra,0xffffc
    80004a5e:	aea080e7          	jalr	-1302(ra) # 80000544 <panic>
    wakeup(&log);
    80004a62:	0023e497          	auipc	s1,0x23e
    80004a66:	df648493          	addi	s1,s1,-522 # 80242858 <log>
    80004a6a:	8526                	mv	a0,s1
    80004a6c:	ffffe097          	auipc	ra,0xffffe
    80004a70:	cba080e7          	jalr	-838(ra) # 80002726 <wakeup>
  release(&log.lock);
    80004a74:	8526                	mv	a0,s1
    80004a76:	ffffc097          	auipc	ra,0xffffc
    80004a7a:	3e6080e7          	jalr	998(ra) # 80000e5c <release>
  if(do_commit){
    80004a7e:	b7c9                	j	80004a40 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004a80:	0023ea97          	auipc	s5,0x23e
    80004a84:	e08a8a93          	addi	s5,s5,-504 # 80242888 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004a88:	0023ea17          	auipc	s4,0x23e
    80004a8c:	dd0a0a13          	addi	s4,s4,-560 # 80242858 <log>
    80004a90:	018a2583          	lw	a1,24(s4)
    80004a94:	012585bb          	addw	a1,a1,s2
    80004a98:	2585                	addiw	a1,a1,1
    80004a9a:	028a2503          	lw	a0,40(s4)
    80004a9e:	fffff097          	auipc	ra,0xfffff
    80004aa2:	cca080e7          	jalr	-822(ra) # 80003768 <bread>
    80004aa6:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004aa8:	000aa583          	lw	a1,0(s5)
    80004aac:	028a2503          	lw	a0,40(s4)
    80004ab0:	fffff097          	auipc	ra,0xfffff
    80004ab4:	cb8080e7          	jalr	-840(ra) # 80003768 <bread>
    80004ab8:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004aba:	40000613          	li	a2,1024
    80004abe:	05850593          	addi	a1,a0,88
    80004ac2:	05848513          	addi	a0,s1,88
    80004ac6:	ffffc097          	auipc	ra,0xffffc
    80004aca:	43e080e7          	jalr	1086(ra) # 80000f04 <memmove>
    bwrite(to);  // write the log
    80004ace:	8526                	mv	a0,s1
    80004ad0:	fffff097          	auipc	ra,0xfffff
    80004ad4:	d8a080e7          	jalr	-630(ra) # 8000385a <bwrite>
    brelse(from);
    80004ad8:	854e                	mv	a0,s3
    80004ada:	fffff097          	auipc	ra,0xfffff
    80004ade:	dbe080e7          	jalr	-578(ra) # 80003898 <brelse>
    brelse(to);
    80004ae2:	8526                	mv	a0,s1
    80004ae4:	fffff097          	auipc	ra,0xfffff
    80004ae8:	db4080e7          	jalr	-588(ra) # 80003898 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004aec:	2905                	addiw	s2,s2,1
    80004aee:	0a91                	addi	s5,s5,4
    80004af0:	02ca2783          	lw	a5,44(s4)
    80004af4:	f8f94ee3          	blt	s2,a5,80004a90 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004af8:	00000097          	auipc	ra,0x0
    80004afc:	c6a080e7          	jalr	-918(ra) # 80004762 <write_head>
    install_trans(0); // Now install writes to home locations
    80004b00:	4501                	li	a0,0
    80004b02:	00000097          	auipc	ra,0x0
    80004b06:	cda080e7          	jalr	-806(ra) # 800047dc <install_trans>
    log.lh.n = 0;
    80004b0a:	0023e797          	auipc	a5,0x23e
    80004b0e:	d607ad23          	sw	zero,-646(a5) # 80242884 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004b12:	00000097          	auipc	ra,0x0
    80004b16:	c50080e7          	jalr	-944(ra) # 80004762 <write_head>
    80004b1a:	bdf5                	j	80004a16 <end_op+0x52>

0000000080004b1c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004b1c:	1101                	addi	sp,sp,-32
    80004b1e:	ec06                	sd	ra,24(sp)
    80004b20:	e822                	sd	s0,16(sp)
    80004b22:	e426                	sd	s1,8(sp)
    80004b24:	e04a                	sd	s2,0(sp)
    80004b26:	1000                	addi	s0,sp,32
    80004b28:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004b2a:	0023e917          	auipc	s2,0x23e
    80004b2e:	d2e90913          	addi	s2,s2,-722 # 80242858 <log>
    80004b32:	854a                	mv	a0,s2
    80004b34:	ffffc097          	auipc	ra,0xffffc
    80004b38:	274080e7          	jalr	628(ra) # 80000da8 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004b3c:	02c92603          	lw	a2,44(s2)
    80004b40:	47f5                	li	a5,29
    80004b42:	06c7c563          	blt	a5,a2,80004bac <log_write+0x90>
    80004b46:	0023e797          	auipc	a5,0x23e
    80004b4a:	d2e7a783          	lw	a5,-722(a5) # 80242874 <log+0x1c>
    80004b4e:	37fd                	addiw	a5,a5,-1
    80004b50:	04f65e63          	bge	a2,a5,80004bac <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004b54:	0023e797          	auipc	a5,0x23e
    80004b58:	d247a783          	lw	a5,-732(a5) # 80242878 <log+0x20>
    80004b5c:	06f05063          	blez	a5,80004bbc <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004b60:	4781                	li	a5,0
    80004b62:	06c05563          	blez	a2,80004bcc <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004b66:	44cc                	lw	a1,12(s1)
    80004b68:	0023e717          	auipc	a4,0x23e
    80004b6c:	d2070713          	addi	a4,a4,-736 # 80242888 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004b70:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004b72:	4314                	lw	a3,0(a4)
    80004b74:	04b68c63          	beq	a3,a1,80004bcc <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004b78:	2785                	addiw	a5,a5,1
    80004b7a:	0711                	addi	a4,a4,4
    80004b7c:	fef61be3          	bne	a2,a5,80004b72 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004b80:	0621                	addi	a2,a2,8
    80004b82:	060a                	slli	a2,a2,0x2
    80004b84:	0023e797          	auipc	a5,0x23e
    80004b88:	cd478793          	addi	a5,a5,-812 # 80242858 <log>
    80004b8c:	963e                	add	a2,a2,a5
    80004b8e:	44dc                	lw	a5,12(s1)
    80004b90:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004b92:	8526                	mv	a0,s1
    80004b94:	fffff097          	auipc	ra,0xfffff
    80004b98:	da2080e7          	jalr	-606(ra) # 80003936 <bpin>
    log.lh.n++;
    80004b9c:	0023e717          	auipc	a4,0x23e
    80004ba0:	cbc70713          	addi	a4,a4,-836 # 80242858 <log>
    80004ba4:	575c                	lw	a5,44(a4)
    80004ba6:	2785                	addiw	a5,a5,1
    80004ba8:	d75c                	sw	a5,44(a4)
    80004baa:	a835                	j	80004be6 <log_write+0xca>
    panic("too big a transaction");
    80004bac:	00004517          	auipc	a0,0x4
    80004bb0:	c1450513          	addi	a0,a0,-1004 # 800087c0 <syscalls+0x218>
    80004bb4:	ffffc097          	auipc	ra,0xffffc
    80004bb8:	990080e7          	jalr	-1648(ra) # 80000544 <panic>
    panic("log_write outside of trans");
    80004bbc:	00004517          	auipc	a0,0x4
    80004bc0:	c1c50513          	addi	a0,a0,-996 # 800087d8 <syscalls+0x230>
    80004bc4:	ffffc097          	auipc	ra,0xffffc
    80004bc8:	980080e7          	jalr	-1664(ra) # 80000544 <panic>
  log.lh.block[i] = b->blockno;
    80004bcc:	00878713          	addi	a4,a5,8
    80004bd0:	00271693          	slli	a3,a4,0x2
    80004bd4:	0023e717          	auipc	a4,0x23e
    80004bd8:	c8470713          	addi	a4,a4,-892 # 80242858 <log>
    80004bdc:	9736                	add	a4,a4,a3
    80004bde:	44d4                	lw	a3,12(s1)
    80004be0:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004be2:	faf608e3          	beq	a2,a5,80004b92 <log_write+0x76>
  }
  release(&log.lock);
    80004be6:	0023e517          	auipc	a0,0x23e
    80004bea:	c7250513          	addi	a0,a0,-910 # 80242858 <log>
    80004bee:	ffffc097          	auipc	ra,0xffffc
    80004bf2:	26e080e7          	jalr	622(ra) # 80000e5c <release>
}
    80004bf6:	60e2                	ld	ra,24(sp)
    80004bf8:	6442                	ld	s0,16(sp)
    80004bfa:	64a2                	ld	s1,8(sp)
    80004bfc:	6902                	ld	s2,0(sp)
    80004bfe:	6105                	addi	sp,sp,32
    80004c00:	8082                	ret

0000000080004c02 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004c02:	1101                	addi	sp,sp,-32
    80004c04:	ec06                	sd	ra,24(sp)
    80004c06:	e822                	sd	s0,16(sp)
    80004c08:	e426                	sd	s1,8(sp)
    80004c0a:	e04a                	sd	s2,0(sp)
    80004c0c:	1000                	addi	s0,sp,32
    80004c0e:	84aa                	mv	s1,a0
    80004c10:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004c12:	00004597          	auipc	a1,0x4
    80004c16:	be658593          	addi	a1,a1,-1050 # 800087f8 <syscalls+0x250>
    80004c1a:	0521                	addi	a0,a0,8
    80004c1c:	ffffc097          	auipc	ra,0xffffc
    80004c20:	0fc080e7          	jalr	252(ra) # 80000d18 <initlock>
  lk->name = name;
    80004c24:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004c28:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004c2c:	0204a423          	sw	zero,40(s1)
}
    80004c30:	60e2                	ld	ra,24(sp)
    80004c32:	6442                	ld	s0,16(sp)
    80004c34:	64a2                	ld	s1,8(sp)
    80004c36:	6902                	ld	s2,0(sp)
    80004c38:	6105                	addi	sp,sp,32
    80004c3a:	8082                	ret

0000000080004c3c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004c3c:	1101                	addi	sp,sp,-32
    80004c3e:	ec06                	sd	ra,24(sp)
    80004c40:	e822                	sd	s0,16(sp)
    80004c42:	e426                	sd	s1,8(sp)
    80004c44:	e04a                	sd	s2,0(sp)
    80004c46:	1000                	addi	s0,sp,32
    80004c48:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004c4a:	00850913          	addi	s2,a0,8
    80004c4e:	854a                	mv	a0,s2
    80004c50:	ffffc097          	auipc	ra,0xffffc
    80004c54:	158080e7          	jalr	344(ra) # 80000da8 <acquire>
  while (lk->locked) {
    80004c58:	409c                	lw	a5,0(s1)
    80004c5a:	cb89                	beqz	a5,80004c6c <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004c5c:	85ca                	mv	a1,s2
    80004c5e:	8526                	mv	a0,s1
    80004c60:	ffffd097          	auipc	ra,0xffffd
    80004c64:	7c8080e7          	jalr	1992(ra) # 80002428 <sleep>
  while (lk->locked) {
    80004c68:	409c                	lw	a5,0(s1)
    80004c6a:	fbed                	bnez	a5,80004c5c <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004c6c:	4785                	li	a5,1
    80004c6e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004c70:	ffffd097          	auipc	ra,0xffffd
    80004c74:	048080e7          	jalr	72(ra) # 80001cb8 <myproc>
    80004c78:	5d1c                	lw	a5,56(a0)
    80004c7a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004c7c:	854a                	mv	a0,s2
    80004c7e:	ffffc097          	auipc	ra,0xffffc
    80004c82:	1de080e7          	jalr	478(ra) # 80000e5c <release>
}
    80004c86:	60e2                	ld	ra,24(sp)
    80004c88:	6442                	ld	s0,16(sp)
    80004c8a:	64a2                	ld	s1,8(sp)
    80004c8c:	6902                	ld	s2,0(sp)
    80004c8e:	6105                	addi	sp,sp,32
    80004c90:	8082                	ret

0000000080004c92 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004c92:	1101                	addi	sp,sp,-32
    80004c94:	ec06                	sd	ra,24(sp)
    80004c96:	e822                	sd	s0,16(sp)
    80004c98:	e426                	sd	s1,8(sp)
    80004c9a:	e04a                	sd	s2,0(sp)
    80004c9c:	1000                	addi	s0,sp,32
    80004c9e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004ca0:	00850913          	addi	s2,a0,8
    80004ca4:	854a                	mv	a0,s2
    80004ca6:	ffffc097          	auipc	ra,0xffffc
    80004caa:	102080e7          	jalr	258(ra) # 80000da8 <acquire>
  lk->locked = 0;
    80004cae:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004cb2:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004cb6:	8526                	mv	a0,s1
    80004cb8:	ffffe097          	auipc	ra,0xffffe
    80004cbc:	a6e080e7          	jalr	-1426(ra) # 80002726 <wakeup>
  release(&lk->lk);
    80004cc0:	854a                	mv	a0,s2
    80004cc2:	ffffc097          	auipc	ra,0xffffc
    80004cc6:	19a080e7          	jalr	410(ra) # 80000e5c <release>
}
    80004cca:	60e2                	ld	ra,24(sp)
    80004ccc:	6442                	ld	s0,16(sp)
    80004cce:	64a2                	ld	s1,8(sp)
    80004cd0:	6902                	ld	s2,0(sp)
    80004cd2:	6105                	addi	sp,sp,32
    80004cd4:	8082                	ret

0000000080004cd6 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004cd6:	7179                	addi	sp,sp,-48
    80004cd8:	f406                	sd	ra,40(sp)
    80004cda:	f022                	sd	s0,32(sp)
    80004cdc:	ec26                	sd	s1,24(sp)
    80004cde:	e84a                	sd	s2,16(sp)
    80004ce0:	e44e                	sd	s3,8(sp)
    80004ce2:	1800                	addi	s0,sp,48
    80004ce4:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004ce6:	00850913          	addi	s2,a0,8
    80004cea:	854a                	mv	a0,s2
    80004cec:	ffffc097          	auipc	ra,0xffffc
    80004cf0:	0bc080e7          	jalr	188(ra) # 80000da8 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004cf4:	409c                	lw	a5,0(s1)
    80004cf6:	ef99                	bnez	a5,80004d14 <holdingsleep+0x3e>
    80004cf8:	4481                	li	s1,0
  release(&lk->lk);
    80004cfa:	854a                	mv	a0,s2
    80004cfc:	ffffc097          	auipc	ra,0xffffc
    80004d00:	160080e7          	jalr	352(ra) # 80000e5c <release>
  return r;
}
    80004d04:	8526                	mv	a0,s1
    80004d06:	70a2                	ld	ra,40(sp)
    80004d08:	7402                	ld	s0,32(sp)
    80004d0a:	64e2                	ld	s1,24(sp)
    80004d0c:	6942                	ld	s2,16(sp)
    80004d0e:	69a2                	ld	s3,8(sp)
    80004d10:	6145                	addi	sp,sp,48
    80004d12:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004d14:	0284a983          	lw	s3,40(s1)
    80004d18:	ffffd097          	auipc	ra,0xffffd
    80004d1c:	fa0080e7          	jalr	-96(ra) # 80001cb8 <myproc>
    80004d20:	5d04                	lw	s1,56(a0)
    80004d22:	413484b3          	sub	s1,s1,s3
    80004d26:	0014b493          	seqz	s1,s1
    80004d2a:	bfc1                	j	80004cfa <holdingsleep+0x24>

0000000080004d2c <fileinit>:
	struct spinlock lock;
	struct file file[NFILE];
} ftable;

void fileinit(void)
{
    80004d2c:	1141                	addi	sp,sp,-16
    80004d2e:	e406                	sd	ra,8(sp)
    80004d30:	e022                	sd	s0,0(sp)
    80004d32:	0800                	addi	s0,sp,16
	initlock(&ftable.lock, "ftable");
    80004d34:	00004597          	auipc	a1,0x4
    80004d38:	ad458593          	addi	a1,a1,-1324 # 80008808 <syscalls+0x260>
    80004d3c:	0023e517          	auipc	a0,0x23e
    80004d40:	c6450513          	addi	a0,a0,-924 # 802429a0 <ftable>
    80004d44:	ffffc097          	auipc	ra,0xffffc
    80004d48:	fd4080e7          	jalr	-44(ra) # 80000d18 <initlock>
}
    80004d4c:	60a2                	ld	ra,8(sp)
    80004d4e:	6402                	ld	s0,0(sp)
    80004d50:	0141                	addi	sp,sp,16
    80004d52:	8082                	ret

0000000080004d54 <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    80004d54:	1101                	addi	sp,sp,-32
    80004d56:	ec06                	sd	ra,24(sp)
    80004d58:	e822                	sd	s0,16(sp)
    80004d5a:	e426                	sd	s1,8(sp)
    80004d5c:	1000                	addi	s0,sp,32
	struct file *f;

	acquire(&ftable.lock);
    80004d5e:	0023e517          	auipc	a0,0x23e
    80004d62:	c4250513          	addi	a0,a0,-958 # 802429a0 <ftable>
    80004d66:	ffffc097          	auipc	ra,0xffffc
    80004d6a:	042080e7          	jalr	66(ra) # 80000da8 <acquire>
	for (f = ftable.file; f < ftable.file + NFILE; f++)
    80004d6e:	0023e497          	auipc	s1,0x23e
    80004d72:	c4a48493          	addi	s1,s1,-950 # 802429b8 <ftable+0x18>
    80004d76:	0023f717          	auipc	a4,0x23f
    80004d7a:	be270713          	addi	a4,a4,-1054 # 80243958 <disk>
	{
		if (f->ref == 0)
    80004d7e:	40dc                	lw	a5,4(s1)
    80004d80:	cf99                	beqz	a5,80004d9e <filealloc+0x4a>
	for (f = ftable.file; f < ftable.file + NFILE; f++)
    80004d82:	02848493          	addi	s1,s1,40
    80004d86:	fee49ce3          	bne	s1,a4,80004d7e <filealloc+0x2a>
			f->ref = 1;
			release(&ftable.lock);
			return f;
		}
	}
	release(&ftable.lock);
    80004d8a:	0023e517          	auipc	a0,0x23e
    80004d8e:	c1650513          	addi	a0,a0,-1002 # 802429a0 <ftable>
    80004d92:	ffffc097          	auipc	ra,0xffffc
    80004d96:	0ca080e7          	jalr	202(ra) # 80000e5c <release>
	return 0;
    80004d9a:	4481                	li	s1,0
    80004d9c:	a819                	j	80004db2 <filealloc+0x5e>
			f->ref = 1;
    80004d9e:	4785                	li	a5,1
    80004da0:	c0dc                	sw	a5,4(s1)
			release(&ftable.lock);
    80004da2:	0023e517          	auipc	a0,0x23e
    80004da6:	bfe50513          	addi	a0,a0,-1026 # 802429a0 <ftable>
    80004daa:	ffffc097          	auipc	ra,0xffffc
    80004dae:	0b2080e7          	jalr	178(ra) # 80000e5c <release>
}
    80004db2:	8526                	mv	a0,s1
    80004db4:	60e2                	ld	ra,24(sp)
    80004db6:	6442                	ld	s0,16(sp)
    80004db8:	64a2                	ld	s1,8(sp)
    80004dba:	6105                	addi	sp,sp,32
    80004dbc:	8082                	ret

0000000080004dbe <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    80004dbe:	1101                	addi	sp,sp,-32
    80004dc0:	ec06                	sd	ra,24(sp)
    80004dc2:	e822                	sd	s0,16(sp)
    80004dc4:	e426                	sd	s1,8(sp)
    80004dc6:	1000                	addi	s0,sp,32
    80004dc8:	84aa                	mv	s1,a0
	acquire(&ftable.lock);
    80004dca:	0023e517          	auipc	a0,0x23e
    80004dce:	bd650513          	addi	a0,a0,-1066 # 802429a0 <ftable>
    80004dd2:	ffffc097          	auipc	ra,0xffffc
    80004dd6:	fd6080e7          	jalr	-42(ra) # 80000da8 <acquire>
	if (f->ref < 1)
    80004dda:	40dc                	lw	a5,4(s1)
    80004ddc:	02f05263          	blez	a5,80004e00 <filedup+0x42>
		panic("filedup");
	f->ref++;
    80004de0:	2785                	addiw	a5,a5,1
    80004de2:	c0dc                	sw	a5,4(s1)
	release(&ftable.lock);
    80004de4:	0023e517          	auipc	a0,0x23e
    80004de8:	bbc50513          	addi	a0,a0,-1092 # 802429a0 <ftable>
    80004dec:	ffffc097          	auipc	ra,0xffffc
    80004df0:	070080e7          	jalr	112(ra) # 80000e5c <release>
	return f;
}
    80004df4:	8526                	mv	a0,s1
    80004df6:	60e2                	ld	ra,24(sp)
    80004df8:	6442                	ld	s0,16(sp)
    80004dfa:	64a2                	ld	s1,8(sp)
    80004dfc:	6105                	addi	sp,sp,32
    80004dfe:	8082                	ret
		panic("filedup");
    80004e00:	00004517          	auipc	a0,0x4
    80004e04:	a1050513          	addi	a0,a0,-1520 # 80008810 <syscalls+0x268>
    80004e08:	ffffb097          	auipc	ra,0xffffb
    80004e0c:	73c080e7          	jalr	1852(ra) # 80000544 <panic>

0000000080004e10 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void fileclose(struct file *f)
{
    80004e10:	7139                	addi	sp,sp,-64
    80004e12:	fc06                	sd	ra,56(sp)
    80004e14:	f822                	sd	s0,48(sp)
    80004e16:	f426                	sd	s1,40(sp)
    80004e18:	f04a                	sd	s2,32(sp)
    80004e1a:	ec4e                	sd	s3,24(sp)
    80004e1c:	e852                	sd	s4,16(sp)
    80004e1e:	e456                	sd	s5,8(sp)
    80004e20:	0080                	addi	s0,sp,64
    80004e22:	84aa                	mv	s1,a0
	struct file ff;

	acquire(&ftable.lock);
    80004e24:	0023e517          	auipc	a0,0x23e
    80004e28:	b7c50513          	addi	a0,a0,-1156 # 802429a0 <ftable>
    80004e2c:	ffffc097          	auipc	ra,0xffffc
    80004e30:	f7c080e7          	jalr	-132(ra) # 80000da8 <acquire>
	if (f->ref < 1)
    80004e34:	40dc                	lw	a5,4(s1)
    80004e36:	06f05163          	blez	a5,80004e98 <fileclose+0x88>
		panic("fileclose");
	if (--f->ref > 0)
    80004e3a:	37fd                	addiw	a5,a5,-1
    80004e3c:	0007871b          	sext.w	a4,a5
    80004e40:	c0dc                	sw	a5,4(s1)
    80004e42:	06e04363          	bgtz	a4,80004ea8 <fileclose+0x98>
	{
		release(&ftable.lock);
		return;
	}
	ff = *f;
    80004e46:	0004a903          	lw	s2,0(s1)
    80004e4a:	0094ca83          	lbu	s5,9(s1)
    80004e4e:	0104ba03          	ld	s4,16(s1)
    80004e52:	0184b983          	ld	s3,24(s1)
	f->ref = 0;
    80004e56:	0004a223          	sw	zero,4(s1)
	f->type = FD_NONE;
    80004e5a:	0004a023          	sw	zero,0(s1)
	release(&ftable.lock);
    80004e5e:	0023e517          	auipc	a0,0x23e
    80004e62:	b4250513          	addi	a0,a0,-1214 # 802429a0 <ftable>
    80004e66:	ffffc097          	auipc	ra,0xffffc
    80004e6a:	ff6080e7          	jalr	-10(ra) # 80000e5c <release>

	if (ff.type == FD_PIPE)
    80004e6e:	4785                	li	a5,1
    80004e70:	04f90d63          	beq	s2,a5,80004eca <fileclose+0xba>
	{
		pipeclose(ff.pipe, ff.writable);
	}
	else if (ff.type == FD_INODE || ff.type == FD_DEVICE)
    80004e74:	3979                	addiw	s2,s2,-2
    80004e76:	4785                	li	a5,1
    80004e78:	0527e063          	bltu	a5,s2,80004eb8 <fileclose+0xa8>
	{
		begin_op();
    80004e7c:	00000097          	auipc	ra,0x0
    80004e80:	ac8080e7          	jalr	-1336(ra) # 80004944 <begin_op>
		iput(ff.ip);
    80004e84:	854e                	mv	a0,s3
    80004e86:	fffff097          	auipc	ra,0xfffff
    80004e8a:	2b6080e7          	jalr	694(ra) # 8000413c <iput>
		end_op();
    80004e8e:	00000097          	auipc	ra,0x0
    80004e92:	b36080e7          	jalr	-1226(ra) # 800049c4 <end_op>
    80004e96:	a00d                	j	80004eb8 <fileclose+0xa8>
		panic("fileclose");
    80004e98:	00004517          	auipc	a0,0x4
    80004e9c:	98050513          	addi	a0,a0,-1664 # 80008818 <syscalls+0x270>
    80004ea0:	ffffb097          	auipc	ra,0xffffb
    80004ea4:	6a4080e7          	jalr	1700(ra) # 80000544 <panic>
		release(&ftable.lock);
    80004ea8:	0023e517          	auipc	a0,0x23e
    80004eac:	af850513          	addi	a0,a0,-1288 # 802429a0 <ftable>
    80004eb0:	ffffc097          	auipc	ra,0xffffc
    80004eb4:	fac080e7          	jalr	-84(ra) # 80000e5c <release>
	}
}
    80004eb8:	70e2                	ld	ra,56(sp)
    80004eba:	7442                	ld	s0,48(sp)
    80004ebc:	74a2                	ld	s1,40(sp)
    80004ebe:	7902                	ld	s2,32(sp)
    80004ec0:	69e2                	ld	s3,24(sp)
    80004ec2:	6a42                	ld	s4,16(sp)
    80004ec4:	6aa2                	ld	s5,8(sp)
    80004ec6:	6121                	addi	sp,sp,64
    80004ec8:	8082                	ret
		pipeclose(ff.pipe, ff.writable);
    80004eca:	85d6                	mv	a1,s5
    80004ecc:	8552                	mv	a0,s4
    80004ece:	00000097          	auipc	ra,0x0
    80004ed2:	34c080e7          	jalr	844(ra) # 8000521a <pipeclose>
    80004ed6:	b7cd                	j	80004eb8 <fileclose+0xa8>

0000000080004ed8 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int filestat(struct file *f, uint64 addr)
{
    80004ed8:	715d                	addi	sp,sp,-80
    80004eda:	e486                	sd	ra,72(sp)
    80004edc:	e0a2                	sd	s0,64(sp)
    80004ede:	fc26                	sd	s1,56(sp)
    80004ee0:	f84a                	sd	s2,48(sp)
    80004ee2:	f44e                	sd	s3,40(sp)
    80004ee4:	0880                	addi	s0,sp,80
    80004ee6:	84aa                	mv	s1,a0
    80004ee8:	89ae                	mv	s3,a1
	struct proc *p = myproc();
    80004eea:	ffffd097          	auipc	ra,0xffffd
    80004eee:	dce080e7          	jalr	-562(ra) # 80001cb8 <myproc>
	struct stat st;

	if (f->type == FD_INODE || f->type == FD_DEVICE)
    80004ef2:	409c                	lw	a5,0(s1)
    80004ef4:	37f9                	addiw	a5,a5,-2
    80004ef6:	4705                	li	a4,1
    80004ef8:	04f76763          	bltu	a4,a5,80004f46 <filestat+0x6e>
    80004efc:	892a                	mv	s2,a0
	{
		ilock(f->ip);
    80004efe:	6c88                	ld	a0,24(s1)
    80004f00:	fffff097          	auipc	ra,0xfffff
    80004f04:	082080e7          	jalr	130(ra) # 80003f82 <ilock>
		stati(f->ip, &st);
    80004f08:	fb840593          	addi	a1,s0,-72
    80004f0c:	6c88                	ld	a0,24(s1)
    80004f0e:	fffff097          	auipc	ra,0xfffff
    80004f12:	2fe080e7          	jalr	766(ra) # 8000420c <stati>
		iunlock(f->ip);
    80004f16:	6c88                	ld	a0,24(s1)
    80004f18:	fffff097          	auipc	ra,0xfffff
    80004f1c:	12c080e7          	jalr	300(ra) # 80004044 <iunlock>
		if (copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004f20:	46e1                	li	a3,24
    80004f22:	fb840613          	addi	a2,s0,-72
    80004f26:	85ce                	mv	a1,s3
    80004f28:	05893503          	ld	a0,88(s2)
    80004f2c:	ffffd097          	auipc	ra,0xffffd
    80004f30:	90c080e7          	jalr	-1780(ra) # 80001838 <copyout>
    80004f34:	41f5551b          	sraiw	a0,a0,0x1f
			return -1;
		return 0;
	}
	return -1;
}
    80004f38:	60a6                	ld	ra,72(sp)
    80004f3a:	6406                	ld	s0,64(sp)
    80004f3c:	74e2                	ld	s1,56(sp)
    80004f3e:	7942                	ld	s2,48(sp)
    80004f40:	79a2                	ld	s3,40(sp)
    80004f42:	6161                	addi	sp,sp,80
    80004f44:	8082                	ret
	return -1;
    80004f46:	557d                	li	a0,-1
    80004f48:	bfc5                	j	80004f38 <filestat+0x60>

0000000080004f4a <fileread>:

// Read from file f.
// addr is a user virtual address.
int fileread(struct file *f, uint64 addr, int n)
{
    80004f4a:	7179                	addi	sp,sp,-48
    80004f4c:	f406                	sd	ra,40(sp)
    80004f4e:	f022                	sd	s0,32(sp)
    80004f50:	ec26                	sd	s1,24(sp)
    80004f52:	e84a                	sd	s2,16(sp)
    80004f54:	e44e                	sd	s3,8(sp)
    80004f56:	1800                	addi	s0,sp,48
	int r = 0;

	if (f->readable == 0)
    80004f58:	00854783          	lbu	a5,8(a0)
    80004f5c:	c3d5                	beqz	a5,80005000 <fileread+0xb6>
    80004f5e:	84aa                	mv	s1,a0
    80004f60:	89ae                	mv	s3,a1
    80004f62:	8932                	mv	s2,a2
		return -1;

	if (f->type == FD_PIPE)
    80004f64:	411c                	lw	a5,0(a0)
    80004f66:	4705                	li	a4,1
    80004f68:	04e78963          	beq	a5,a4,80004fba <fileread+0x70>
	{
		r = piperead(f->pipe, addr, n);
		// printf("here\n");
	}
	else if (f->type == FD_DEVICE)
    80004f6c:	470d                	li	a4,3
    80004f6e:	04e78d63          	beq	a5,a4,80004fc8 <fileread+0x7e>
	{
		if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
			return -1;
		r = devsw[f->major].read(1, addr, n);
	}
	else if (f->type == FD_INODE)
    80004f72:	4709                	li	a4,2
    80004f74:	06e79e63          	bne	a5,a4,80004ff0 <fileread+0xa6>
	{
		ilock(f->ip);
    80004f78:	6d08                	ld	a0,24(a0)
    80004f7a:	fffff097          	auipc	ra,0xfffff
    80004f7e:	008080e7          	jalr	8(ra) # 80003f82 <ilock>
		if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004f82:	874a                	mv	a4,s2
    80004f84:	5094                	lw	a3,32(s1)
    80004f86:	864e                	mv	a2,s3
    80004f88:	4585                	li	a1,1
    80004f8a:	6c88                	ld	a0,24(s1)
    80004f8c:	fffff097          	auipc	ra,0xfffff
    80004f90:	2aa080e7          	jalr	682(ra) # 80004236 <readi>
    80004f94:	892a                	mv	s2,a0
    80004f96:	00a05563          	blez	a0,80004fa0 <fileread+0x56>
			f->off += r;
    80004f9a:	509c                	lw	a5,32(s1)
    80004f9c:	9fa9                	addw	a5,a5,a0
    80004f9e:	d09c                	sw	a5,32(s1)
		iunlock(f->ip);
    80004fa0:	6c88                	ld	a0,24(s1)
    80004fa2:	fffff097          	auipc	ra,0xfffff
    80004fa6:	0a2080e7          	jalr	162(ra) # 80004044 <iunlock>
	{
		panic("fileread");
	}

	return r;
}
    80004faa:	854a                	mv	a0,s2
    80004fac:	70a2                	ld	ra,40(sp)
    80004fae:	7402                	ld	s0,32(sp)
    80004fb0:	64e2                	ld	s1,24(sp)
    80004fb2:	6942                	ld	s2,16(sp)
    80004fb4:	69a2                	ld	s3,8(sp)
    80004fb6:	6145                	addi	sp,sp,48
    80004fb8:	8082                	ret
		r = piperead(f->pipe, addr, n);
    80004fba:	6908                	ld	a0,16(a0)
    80004fbc:	00000097          	auipc	ra,0x0
    80004fc0:	3ce080e7          	jalr	974(ra) # 8000538a <piperead>
    80004fc4:	892a                	mv	s2,a0
    80004fc6:	b7d5                	j	80004faa <fileread+0x60>
		if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004fc8:	02451783          	lh	a5,36(a0)
    80004fcc:	03079693          	slli	a3,a5,0x30
    80004fd0:	92c1                	srli	a3,a3,0x30
    80004fd2:	4725                	li	a4,9
    80004fd4:	02d76863          	bltu	a4,a3,80005004 <fileread+0xba>
    80004fd8:	0792                	slli	a5,a5,0x4
    80004fda:	0023e717          	auipc	a4,0x23e
    80004fde:	92670713          	addi	a4,a4,-1754 # 80242900 <devsw>
    80004fe2:	97ba                	add	a5,a5,a4
    80004fe4:	639c                	ld	a5,0(a5)
    80004fe6:	c38d                	beqz	a5,80005008 <fileread+0xbe>
		r = devsw[f->major].read(1, addr, n);
    80004fe8:	4505                	li	a0,1
    80004fea:	9782                	jalr	a5
    80004fec:	892a                	mv	s2,a0
    80004fee:	bf75                	j	80004faa <fileread+0x60>
		panic("fileread");
    80004ff0:	00004517          	auipc	a0,0x4
    80004ff4:	83850513          	addi	a0,a0,-1992 # 80008828 <syscalls+0x280>
    80004ff8:	ffffb097          	auipc	ra,0xffffb
    80004ffc:	54c080e7          	jalr	1356(ra) # 80000544 <panic>
		return -1;
    80005000:	597d                	li	s2,-1
    80005002:	b765                	j	80004faa <fileread+0x60>
			return -1;
    80005004:	597d                	li	s2,-1
    80005006:	b755                	j	80004faa <fileread+0x60>
    80005008:	597d                	li	s2,-1
    8000500a:	b745                	j	80004faa <fileread+0x60>

000000008000500c <filewrite>:

// Write to file f.
// addr is a user virtual address.
int filewrite(struct file *f, uint64 addr, int n)
{
    8000500c:	715d                	addi	sp,sp,-80
    8000500e:	e486                	sd	ra,72(sp)
    80005010:	e0a2                	sd	s0,64(sp)
    80005012:	fc26                	sd	s1,56(sp)
    80005014:	f84a                	sd	s2,48(sp)
    80005016:	f44e                	sd	s3,40(sp)
    80005018:	f052                	sd	s4,32(sp)
    8000501a:	ec56                	sd	s5,24(sp)
    8000501c:	e85a                	sd	s6,16(sp)
    8000501e:	e45e                	sd	s7,8(sp)
    80005020:	e062                	sd	s8,0(sp)
    80005022:	0880                	addi	s0,sp,80
	int r, ret = 0;

	if (f->writable == 0)
    80005024:	00954783          	lbu	a5,9(a0)
    80005028:	10078663          	beqz	a5,80005134 <filewrite+0x128>
    8000502c:	892a                	mv	s2,a0
    8000502e:	8aae                	mv	s5,a1
    80005030:	8a32                	mv	s4,a2
		return -1;

	if (f->type == FD_PIPE)
    80005032:	411c                	lw	a5,0(a0)
    80005034:	4705                	li	a4,1
    80005036:	02e78263          	beq	a5,a4,8000505a <filewrite+0x4e>
	{
		ret = pipewrite(f->pipe, addr, n);
	}
	else if (f->type == FD_DEVICE)
    8000503a:	470d                	li	a4,3
    8000503c:	02e78663          	beq	a5,a4,80005068 <filewrite+0x5c>
	{
		if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
			return -1;
		ret = devsw[f->major].write(1, addr, n);
	}
	else if (f->type == FD_INODE)
    80005040:	4709                	li	a4,2
    80005042:	0ee79163          	bne	a5,a4,80005124 <filewrite+0x118>
		// and 2 blocks of slop for non-aligned writes.
		// this really belongs lower down, since writei()
		// might be writing a device like the console.
		int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
		int i = 0;
		while (i < n)
    80005046:	0ac05d63          	blez	a2,80005100 <filewrite+0xf4>
		int i = 0;
    8000504a:	4981                	li	s3,0
    8000504c:	6b05                	lui	s6,0x1
    8000504e:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80005052:	6b85                	lui	s7,0x1
    80005054:	c00b8b9b          	addiw	s7,s7,-1024
    80005058:	a861                	j	800050f0 <filewrite+0xe4>
		ret = pipewrite(f->pipe, addr, n);
    8000505a:	6908                	ld	a0,16(a0)
    8000505c:	00000097          	auipc	ra,0x0
    80005060:	22e080e7          	jalr	558(ra) # 8000528a <pipewrite>
    80005064:	8a2a                	mv	s4,a0
    80005066:	a045                	j	80005106 <filewrite+0xfa>
		if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005068:	02451783          	lh	a5,36(a0)
    8000506c:	03079693          	slli	a3,a5,0x30
    80005070:	92c1                	srli	a3,a3,0x30
    80005072:	4725                	li	a4,9
    80005074:	0cd76263          	bltu	a4,a3,80005138 <filewrite+0x12c>
    80005078:	0792                	slli	a5,a5,0x4
    8000507a:	0023e717          	auipc	a4,0x23e
    8000507e:	88670713          	addi	a4,a4,-1914 # 80242900 <devsw>
    80005082:	97ba                	add	a5,a5,a4
    80005084:	679c                	ld	a5,8(a5)
    80005086:	cbdd                	beqz	a5,8000513c <filewrite+0x130>
		ret = devsw[f->major].write(1, addr, n);
    80005088:	4505                	li	a0,1
    8000508a:	9782                	jalr	a5
    8000508c:	8a2a                	mv	s4,a0
    8000508e:	a8a5                	j	80005106 <filewrite+0xfa>
    80005090:	00048c1b          	sext.w	s8,s1
		{
			int n1 = n - i;
			if (n1 > max)
				n1 = max;

			begin_op();
    80005094:	00000097          	auipc	ra,0x0
    80005098:	8b0080e7          	jalr	-1872(ra) # 80004944 <begin_op>
			ilock(f->ip);
    8000509c:	01893503          	ld	a0,24(s2)
    800050a0:	fffff097          	auipc	ra,0xfffff
    800050a4:	ee2080e7          	jalr	-286(ra) # 80003f82 <ilock>
			if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800050a8:	8762                	mv	a4,s8
    800050aa:	02092683          	lw	a3,32(s2)
    800050ae:	01598633          	add	a2,s3,s5
    800050b2:	4585                	li	a1,1
    800050b4:	01893503          	ld	a0,24(s2)
    800050b8:	fffff097          	auipc	ra,0xfffff
    800050bc:	276080e7          	jalr	630(ra) # 8000432e <writei>
    800050c0:	84aa                	mv	s1,a0
    800050c2:	00a05763          	blez	a0,800050d0 <filewrite+0xc4>
				f->off += r;
    800050c6:	02092783          	lw	a5,32(s2)
    800050ca:	9fa9                	addw	a5,a5,a0
    800050cc:	02f92023          	sw	a5,32(s2)
			iunlock(f->ip);
    800050d0:	01893503          	ld	a0,24(s2)
    800050d4:	fffff097          	auipc	ra,0xfffff
    800050d8:	f70080e7          	jalr	-144(ra) # 80004044 <iunlock>
			end_op();
    800050dc:	00000097          	auipc	ra,0x0
    800050e0:	8e8080e7          	jalr	-1816(ra) # 800049c4 <end_op>

			if (r != n1)
    800050e4:	009c1f63          	bne	s8,s1,80005102 <filewrite+0xf6>
			{
				// error from writei
				break;
			}
			i += r;
    800050e8:	013489bb          	addw	s3,s1,s3
		while (i < n)
    800050ec:	0149db63          	bge	s3,s4,80005102 <filewrite+0xf6>
			int n1 = n - i;
    800050f0:	413a07bb          	subw	a5,s4,s3
			if (n1 > max)
    800050f4:	84be                	mv	s1,a5
    800050f6:	2781                	sext.w	a5,a5
    800050f8:	f8fb5ce3          	bge	s6,a5,80005090 <filewrite+0x84>
    800050fc:	84de                	mv	s1,s7
    800050fe:	bf49                	j	80005090 <filewrite+0x84>
		int i = 0;
    80005100:	4981                	li	s3,0
		}
		ret = (i == n ? n : -1);
    80005102:	013a1f63          	bne	s4,s3,80005120 <filewrite+0x114>
	{
		panic("filewrite");
	}

	return ret;
}
    80005106:	8552                	mv	a0,s4
    80005108:	60a6                	ld	ra,72(sp)
    8000510a:	6406                	ld	s0,64(sp)
    8000510c:	74e2                	ld	s1,56(sp)
    8000510e:	7942                	ld	s2,48(sp)
    80005110:	79a2                	ld	s3,40(sp)
    80005112:	7a02                	ld	s4,32(sp)
    80005114:	6ae2                	ld	s5,24(sp)
    80005116:	6b42                	ld	s6,16(sp)
    80005118:	6ba2                	ld	s7,8(sp)
    8000511a:	6c02                	ld	s8,0(sp)
    8000511c:	6161                	addi	sp,sp,80
    8000511e:	8082                	ret
		ret = (i == n ? n : -1);
    80005120:	5a7d                	li	s4,-1
    80005122:	b7d5                	j	80005106 <filewrite+0xfa>
		panic("filewrite");
    80005124:	00003517          	auipc	a0,0x3
    80005128:	71450513          	addi	a0,a0,1812 # 80008838 <syscalls+0x290>
    8000512c:	ffffb097          	auipc	ra,0xffffb
    80005130:	418080e7          	jalr	1048(ra) # 80000544 <panic>
		return -1;
    80005134:	5a7d                	li	s4,-1
    80005136:	bfc1                	j	80005106 <filewrite+0xfa>
			return -1;
    80005138:	5a7d                	li	s4,-1
    8000513a:	b7f1                	j	80005106 <filewrite+0xfa>
    8000513c:	5a7d                	li	s4,-1
    8000513e:	b7e1                	j	80005106 <filewrite+0xfa>

0000000080005140 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80005140:	7179                	addi	sp,sp,-48
    80005142:	f406                	sd	ra,40(sp)
    80005144:	f022                	sd	s0,32(sp)
    80005146:	ec26                	sd	s1,24(sp)
    80005148:	e84a                	sd	s2,16(sp)
    8000514a:	e44e                	sd	s3,8(sp)
    8000514c:	e052                	sd	s4,0(sp)
    8000514e:	1800                	addi	s0,sp,48
    80005150:	84aa                	mv	s1,a0
    80005152:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005154:	0005b023          	sd	zero,0(a1)
    80005158:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000515c:	00000097          	auipc	ra,0x0
    80005160:	bf8080e7          	jalr	-1032(ra) # 80004d54 <filealloc>
    80005164:	e088                	sd	a0,0(s1)
    80005166:	c551                	beqz	a0,800051f2 <pipealloc+0xb2>
    80005168:	00000097          	auipc	ra,0x0
    8000516c:	bec080e7          	jalr	-1044(ra) # 80004d54 <filealloc>
    80005170:	00aa3023          	sd	a0,0(s4)
    80005174:	c92d                	beqz	a0,800051e6 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80005176:	ffffc097          	auipc	ra,0xffffc
    8000517a:	afe080e7          	jalr	-1282(ra) # 80000c74 <kalloc>
    8000517e:	892a                	mv	s2,a0
    80005180:	c125                	beqz	a0,800051e0 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80005182:	4985                	li	s3,1
    80005184:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80005188:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000518c:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005190:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80005194:	00003597          	auipc	a1,0x3
    80005198:	33458593          	addi	a1,a1,820 # 800084c8 <states.2502+0x1b8>
    8000519c:	ffffc097          	auipc	ra,0xffffc
    800051a0:	b7c080e7          	jalr	-1156(ra) # 80000d18 <initlock>
  (*f0)->type = FD_PIPE;
    800051a4:	609c                	ld	a5,0(s1)
    800051a6:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800051aa:	609c                	ld	a5,0(s1)
    800051ac:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800051b0:	609c                	ld	a5,0(s1)
    800051b2:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800051b6:	609c                	ld	a5,0(s1)
    800051b8:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800051bc:	000a3783          	ld	a5,0(s4)
    800051c0:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800051c4:	000a3783          	ld	a5,0(s4)
    800051c8:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800051cc:	000a3783          	ld	a5,0(s4)
    800051d0:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800051d4:	000a3783          	ld	a5,0(s4)
    800051d8:	0127b823          	sd	s2,16(a5)
  return 0;
    800051dc:	4501                	li	a0,0
    800051de:	a025                	j	80005206 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800051e0:	6088                	ld	a0,0(s1)
    800051e2:	e501                	bnez	a0,800051ea <pipealloc+0xaa>
    800051e4:	a039                	j	800051f2 <pipealloc+0xb2>
    800051e6:	6088                	ld	a0,0(s1)
    800051e8:	c51d                	beqz	a0,80005216 <pipealloc+0xd6>
    fileclose(*f0);
    800051ea:	00000097          	auipc	ra,0x0
    800051ee:	c26080e7          	jalr	-986(ra) # 80004e10 <fileclose>
  if(*f1)
    800051f2:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800051f6:	557d                	li	a0,-1
  if(*f1)
    800051f8:	c799                	beqz	a5,80005206 <pipealloc+0xc6>
    fileclose(*f1);
    800051fa:	853e                	mv	a0,a5
    800051fc:	00000097          	auipc	ra,0x0
    80005200:	c14080e7          	jalr	-1004(ra) # 80004e10 <fileclose>
  return -1;
    80005204:	557d                	li	a0,-1
}
    80005206:	70a2                	ld	ra,40(sp)
    80005208:	7402                	ld	s0,32(sp)
    8000520a:	64e2                	ld	s1,24(sp)
    8000520c:	6942                	ld	s2,16(sp)
    8000520e:	69a2                	ld	s3,8(sp)
    80005210:	6a02                	ld	s4,0(sp)
    80005212:	6145                	addi	sp,sp,48
    80005214:	8082                	ret
  return -1;
    80005216:	557d                	li	a0,-1
    80005218:	b7fd                	j	80005206 <pipealloc+0xc6>

000000008000521a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000521a:	1101                	addi	sp,sp,-32
    8000521c:	ec06                	sd	ra,24(sp)
    8000521e:	e822                	sd	s0,16(sp)
    80005220:	e426                	sd	s1,8(sp)
    80005222:	e04a                	sd	s2,0(sp)
    80005224:	1000                	addi	s0,sp,32
    80005226:	84aa                	mv	s1,a0
    80005228:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000522a:	ffffc097          	auipc	ra,0xffffc
    8000522e:	b7e080e7          	jalr	-1154(ra) # 80000da8 <acquire>
  if(writable){
    80005232:	02090d63          	beqz	s2,8000526c <pipeclose+0x52>
    pi->writeopen = 0;
    80005236:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000523a:	21848513          	addi	a0,s1,536
    8000523e:	ffffd097          	auipc	ra,0xffffd
    80005242:	4e8080e7          	jalr	1256(ra) # 80002726 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005246:	2204b783          	ld	a5,544(s1)
    8000524a:	eb95                	bnez	a5,8000527e <pipeclose+0x64>
    release(&pi->lock);
    8000524c:	8526                	mv	a0,s1
    8000524e:	ffffc097          	auipc	ra,0xffffc
    80005252:	c0e080e7          	jalr	-1010(ra) # 80000e5c <release>
    kfree((char*)pi);
    80005256:	8526                	mv	a0,s1
    80005258:	ffffc097          	auipc	ra,0xffffc
    8000525c:	876080e7          	jalr	-1930(ra) # 80000ace <kfree>
  } else
    release(&pi->lock);
}
    80005260:	60e2                	ld	ra,24(sp)
    80005262:	6442                	ld	s0,16(sp)
    80005264:	64a2                	ld	s1,8(sp)
    80005266:	6902                	ld	s2,0(sp)
    80005268:	6105                	addi	sp,sp,32
    8000526a:	8082                	ret
    pi->readopen = 0;
    8000526c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005270:	21c48513          	addi	a0,s1,540
    80005274:	ffffd097          	auipc	ra,0xffffd
    80005278:	4b2080e7          	jalr	1202(ra) # 80002726 <wakeup>
    8000527c:	b7e9                	j	80005246 <pipeclose+0x2c>
    release(&pi->lock);
    8000527e:	8526                	mv	a0,s1
    80005280:	ffffc097          	auipc	ra,0xffffc
    80005284:	bdc080e7          	jalr	-1060(ra) # 80000e5c <release>
}
    80005288:	bfe1                	j	80005260 <pipeclose+0x46>

000000008000528a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000528a:	7159                	addi	sp,sp,-112
    8000528c:	f486                	sd	ra,104(sp)
    8000528e:	f0a2                	sd	s0,96(sp)
    80005290:	eca6                	sd	s1,88(sp)
    80005292:	e8ca                	sd	s2,80(sp)
    80005294:	e4ce                	sd	s3,72(sp)
    80005296:	e0d2                	sd	s4,64(sp)
    80005298:	fc56                	sd	s5,56(sp)
    8000529a:	f85a                	sd	s6,48(sp)
    8000529c:	f45e                	sd	s7,40(sp)
    8000529e:	f062                	sd	s8,32(sp)
    800052a0:	ec66                	sd	s9,24(sp)
    800052a2:	1880                	addi	s0,sp,112
    800052a4:	84aa                	mv	s1,a0
    800052a6:	8aae                	mv	s5,a1
    800052a8:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800052aa:	ffffd097          	auipc	ra,0xffffd
    800052ae:	a0e080e7          	jalr	-1522(ra) # 80001cb8 <myproc>
    800052b2:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800052b4:	8526                	mv	a0,s1
    800052b6:	ffffc097          	auipc	ra,0xffffc
    800052ba:	af2080e7          	jalr	-1294(ra) # 80000da8 <acquire>
  while(i < n){
    800052be:	0d405463          	blez	s4,80005386 <pipewrite+0xfc>
    800052c2:	8ba6                	mv	s7,s1
  int i = 0;
    800052c4:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800052c6:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800052c8:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800052cc:	21c48c13          	addi	s8,s1,540
    800052d0:	a08d                	j	80005332 <pipewrite+0xa8>
      release(&pi->lock);
    800052d2:	8526                	mv	a0,s1
    800052d4:	ffffc097          	auipc	ra,0xffffc
    800052d8:	b88080e7          	jalr	-1144(ra) # 80000e5c <release>
      return -1;
    800052dc:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800052de:	854a                	mv	a0,s2
    800052e0:	70a6                	ld	ra,104(sp)
    800052e2:	7406                	ld	s0,96(sp)
    800052e4:	64e6                	ld	s1,88(sp)
    800052e6:	6946                	ld	s2,80(sp)
    800052e8:	69a6                	ld	s3,72(sp)
    800052ea:	6a06                	ld	s4,64(sp)
    800052ec:	7ae2                	ld	s5,56(sp)
    800052ee:	7b42                	ld	s6,48(sp)
    800052f0:	7ba2                	ld	s7,40(sp)
    800052f2:	7c02                	ld	s8,32(sp)
    800052f4:	6ce2                	ld	s9,24(sp)
    800052f6:	6165                	addi	sp,sp,112
    800052f8:	8082                	ret
      wakeup(&pi->nread);
    800052fa:	8566                	mv	a0,s9
    800052fc:	ffffd097          	auipc	ra,0xffffd
    80005300:	42a080e7          	jalr	1066(ra) # 80002726 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005304:	85de                	mv	a1,s7
    80005306:	8562                	mv	a0,s8
    80005308:	ffffd097          	auipc	ra,0xffffd
    8000530c:	120080e7          	jalr	288(ra) # 80002428 <sleep>
    80005310:	a839                	j	8000532e <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005312:	21c4a783          	lw	a5,540(s1)
    80005316:	0017871b          	addiw	a4,a5,1
    8000531a:	20e4ae23          	sw	a4,540(s1)
    8000531e:	1ff7f793          	andi	a5,a5,511
    80005322:	97a6                	add	a5,a5,s1
    80005324:	f9f44703          	lbu	a4,-97(s0)
    80005328:	00e78c23          	sb	a4,24(a5)
      i++;
    8000532c:	2905                	addiw	s2,s2,1
  while(i < n){
    8000532e:	05495063          	bge	s2,s4,8000536e <pipewrite+0xe4>
    if(pi->readopen == 0 || killed(pr)){
    80005332:	2204a783          	lw	a5,544(s1)
    80005336:	dfd1                	beqz	a5,800052d2 <pipewrite+0x48>
    80005338:	854e                	mv	a0,s3
    8000533a:	ffffd097          	auipc	ra,0xffffd
    8000533e:	692080e7          	jalr	1682(ra) # 800029cc <killed>
    80005342:	f941                	bnez	a0,800052d2 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005344:	2184a783          	lw	a5,536(s1)
    80005348:	21c4a703          	lw	a4,540(s1)
    8000534c:	2007879b          	addiw	a5,a5,512
    80005350:	faf705e3          	beq	a4,a5,800052fa <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005354:	4685                	li	a3,1
    80005356:	01590633          	add	a2,s2,s5
    8000535a:	f9f40593          	addi	a1,s0,-97
    8000535e:	0589b503          	ld	a0,88(s3)
    80005362:	ffffc097          	auipc	ra,0xffffc
    80005366:	596080e7          	jalr	1430(ra) # 800018f8 <copyin>
    8000536a:	fb6514e3          	bne	a0,s6,80005312 <pipewrite+0x88>
  wakeup(&pi->nread);
    8000536e:	21848513          	addi	a0,s1,536
    80005372:	ffffd097          	auipc	ra,0xffffd
    80005376:	3b4080e7          	jalr	948(ra) # 80002726 <wakeup>
  release(&pi->lock);
    8000537a:	8526                	mv	a0,s1
    8000537c:	ffffc097          	auipc	ra,0xffffc
    80005380:	ae0080e7          	jalr	-1312(ra) # 80000e5c <release>
  return i;
    80005384:	bfa9                	j	800052de <pipewrite+0x54>
  int i = 0;
    80005386:	4901                	li	s2,0
    80005388:	b7dd                	j	8000536e <pipewrite+0xe4>

000000008000538a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000538a:	715d                	addi	sp,sp,-80
    8000538c:	e486                	sd	ra,72(sp)
    8000538e:	e0a2                	sd	s0,64(sp)
    80005390:	fc26                	sd	s1,56(sp)
    80005392:	f84a                	sd	s2,48(sp)
    80005394:	f44e                	sd	s3,40(sp)
    80005396:	f052                	sd	s4,32(sp)
    80005398:	ec56                	sd	s5,24(sp)
    8000539a:	e85a                	sd	s6,16(sp)
    8000539c:	0880                	addi	s0,sp,80
    8000539e:	84aa                	mv	s1,a0
    800053a0:	892e                	mv	s2,a1
    800053a2:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800053a4:	ffffd097          	auipc	ra,0xffffd
    800053a8:	914080e7          	jalr	-1772(ra) # 80001cb8 <myproc>
    800053ac:	8a2a                	mv	s4,a0
  char ch;
  // printf("here1\n");

  acquire(&pi->lock);
    800053ae:	8b26                	mv	s6,s1
    800053b0:	8526                	mv	a0,s1
    800053b2:	ffffc097          	auipc	ra,0xffffc
    800053b6:	9f6080e7          	jalr	-1546(ra) # 80000da8 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800053ba:	2184a703          	lw	a4,536(s1)
    800053be:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800053c2:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800053c6:	02f71763          	bne	a4,a5,800053f4 <piperead+0x6a>
    800053ca:	2244a783          	lw	a5,548(s1)
    800053ce:	c39d                	beqz	a5,800053f4 <piperead+0x6a>
    if(killed(pr)){
    800053d0:	8552                	mv	a0,s4
    800053d2:	ffffd097          	auipc	ra,0xffffd
    800053d6:	5fa080e7          	jalr	1530(ra) # 800029cc <killed>
    800053da:	e941                	bnez	a0,8000546a <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800053dc:	85da                	mv	a1,s6
    800053de:	854e                	mv	a0,s3
    800053e0:	ffffd097          	auipc	ra,0xffffd
    800053e4:	048080e7          	jalr	72(ra) # 80002428 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800053e8:	2184a703          	lw	a4,536(s1)
    800053ec:	21c4a783          	lw	a5,540(s1)
    800053f0:	fcf70de3          	beq	a4,a5,800053ca <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800053f4:	09505263          	blez	s5,80005478 <piperead+0xee>
    800053f8:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800053fa:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    800053fc:	2184a783          	lw	a5,536(s1)
    80005400:	21c4a703          	lw	a4,540(s1)
    80005404:	02f70d63          	beq	a4,a5,8000543e <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005408:	0017871b          	addiw	a4,a5,1
    8000540c:	20e4ac23          	sw	a4,536(s1)
    80005410:	1ff7f793          	andi	a5,a5,511
    80005414:	97a6                	add	a5,a5,s1
    80005416:	0187c783          	lbu	a5,24(a5)
    8000541a:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000541e:	4685                	li	a3,1
    80005420:	fbf40613          	addi	a2,s0,-65
    80005424:	85ca                	mv	a1,s2
    80005426:	058a3503          	ld	a0,88(s4)
    8000542a:	ffffc097          	auipc	ra,0xffffc
    8000542e:	40e080e7          	jalr	1038(ra) # 80001838 <copyout>
    80005432:	01650663          	beq	a0,s6,8000543e <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005436:	2985                	addiw	s3,s3,1
    80005438:	0905                	addi	s2,s2,1
    8000543a:	fd3a91e3          	bne	s5,s3,800053fc <piperead+0x72>
      break;
  }
  // printf("here2\n");
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000543e:	21c48513          	addi	a0,s1,540
    80005442:	ffffd097          	auipc	ra,0xffffd
    80005446:	2e4080e7          	jalr	740(ra) # 80002726 <wakeup>
  release(&pi->lock);
    8000544a:	8526                	mv	a0,s1
    8000544c:	ffffc097          	auipc	ra,0xffffc
    80005450:	a10080e7          	jalr	-1520(ra) # 80000e5c <release>
  return i;
}
    80005454:	854e                	mv	a0,s3
    80005456:	60a6                	ld	ra,72(sp)
    80005458:	6406                	ld	s0,64(sp)
    8000545a:	74e2                	ld	s1,56(sp)
    8000545c:	7942                	ld	s2,48(sp)
    8000545e:	79a2                	ld	s3,40(sp)
    80005460:	7a02                	ld	s4,32(sp)
    80005462:	6ae2                	ld	s5,24(sp)
    80005464:	6b42                	ld	s6,16(sp)
    80005466:	6161                	addi	sp,sp,80
    80005468:	8082                	ret
      release(&pi->lock);
    8000546a:	8526                	mv	a0,s1
    8000546c:	ffffc097          	auipc	ra,0xffffc
    80005470:	9f0080e7          	jalr	-1552(ra) # 80000e5c <release>
      return -1;
    80005474:	59fd                	li	s3,-1
    80005476:	bff9                	j	80005454 <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005478:	4981                	li	s3,0
    8000547a:	b7d1                	j	8000543e <piperead+0xb4>

000000008000547c <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    8000547c:	1141                	addi	sp,sp,-16
    8000547e:	e422                	sd	s0,8(sp)
    80005480:	0800                	addi	s0,sp,16
    80005482:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80005484:	8905                	andi	a0,a0,1
    80005486:	c111                	beqz	a0,8000548a <flags2perm+0xe>
      perm = PTE_X;
    80005488:	4521                	li	a0,8
    if(flags & 0x2)
    8000548a:	8b89                	andi	a5,a5,2
    8000548c:	c399                	beqz	a5,80005492 <flags2perm+0x16>
      perm |= PTE_W;
    8000548e:	00456513          	ori	a0,a0,4
    return perm;
}
    80005492:	6422                	ld	s0,8(sp)
    80005494:	0141                	addi	sp,sp,16
    80005496:	8082                	ret

0000000080005498 <exec>:

int
exec(char *path, char **argv)
{
    80005498:	df010113          	addi	sp,sp,-528
    8000549c:	20113423          	sd	ra,520(sp)
    800054a0:	20813023          	sd	s0,512(sp)
    800054a4:	ffa6                	sd	s1,504(sp)
    800054a6:	fbca                	sd	s2,496(sp)
    800054a8:	f7ce                	sd	s3,488(sp)
    800054aa:	f3d2                	sd	s4,480(sp)
    800054ac:	efd6                	sd	s5,472(sp)
    800054ae:	ebda                	sd	s6,464(sp)
    800054b0:	e7de                	sd	s7,456(sp)
    800054b2:	e3e2                	sd	s8,448(sp)
    800054b4:	ff66                	sd	s9,440(sp)
    800054b6:	fb6a                	sd	s10,432(sp)
    800054b8:	f76e                	sd	s11,424(sp)
    800054ba:	0c00                	addi	s0,sp,528
    800054bc:	84aa                	mv	s1,a0
    800054be:	dea43c23          	sd	a0,-520(s0)
    800054c2:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800054c6:	ffffc097          	auipc	ra,0xffffc
    800054ca:	7f2080e7          	jalr	2034(ra) # 80001cb8 <myproc>
    800054ce:	892a                	mv	s2,a0

  begin_op();
    800054d0:	fffff097          	auipc	ra,0xfffff
    800054d4:	474080e7          	jalr	1140(ra) # 80004944 <begin_op>

  if((ip = namei(path)) == 0){
    800054d8:	8526                	mv	a0,s1
    800054da:	fffff097          	auipc	ra,0xfffff
    800054de:	24e080e7          	jalr	590(ra) # 80004728 <namei>
    800054e2:	c92d                	beqz	a0,80005554 <exec+0xbc>
    800054e4:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800054e6:	fffff097          	auipc	ra,0xfffff
    800054ea:	a9c080e7          	jalr	-1380(ra) # 80003f82 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800054ee:	04000713          	li	a4,64
    800054f2:	4681                	li	a3,0
    800054f4:	e5040613          	addi	a2,s0,-432
    800054f8:	4581                	li	a1,0
    800054fa:	8526                	mv	a0,s1
    800054fc:	fffff097          	auipc	ra,0xfffff
    80005500:	d3a080e7          	jalr	-710(ra) # 80004236 <readi>
    80005504:	04000793          	li	a5,64
    80005508:	00f51a63          	bne	a0,a5,8000551c <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    8000550c:	e5042703          	lw	a4,-432(s0)
    80005510:	464c47b7          	lui	a5,0x464c4
    80005514:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005518:	04f70463          	beq	a4,a5,80005560 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000551c:	8526                	mv	a0,s1
    8000551e:	fffff097          	auipc	ra,0xfffff
    80005522:	cc6080e7          	jalr	-826(ra) # 800041e4 <iunlockput>
    end_op();
    80005526:	fffff097          	auipc	ra,0xfffff
    8000552a:	49e080e7          	jalr	1182(ra) # 800049c4 <end_op>
  }
  return -1;
    8000552e:	557d                	li	a0,-1
}
    80005530:	20813083          	ld	ra,520(sp)
    80005534:	20013403          	ld	s0,512(sp)
    80005538:	74fe                	ld	s1,504(sp)
    8000553a:	795e                	ld	s2,496(sp)
    8000553c:	79be                	ld	s3,488(sp)
    8000553e:	7a1e                	ld	s4,480(sp)
    80005540:	6afe                	ld	s5,472(sp)
    80005542:	6b5e                	ld	s6,464(sp)
    80005544:	6bbe                	ld	s7,456(sp)
    80005546:	6c1e                	ld	s8,448(sp)
    80005548:	7cfa                	ld	s9,440(sp)
    8000554a:	7d5a                	ld	s10,432(sp)
    8000554c:	7dba                	ld	s11,424(sp)
    8000554e:	21010113          	addi	sp,sp,528
    80005552:	8082                	ret
    end_op();
    80005554:	fffff097          	auipc	ra,0xfffff
    80005558:	470080e7          	jalr	1136(ra) # 800049c4 <end_op>
    return -1;
    8000555c:	557d                	li	a0,-1
    8000555e:	bfc9                	j	80005530 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80005560:	854a                	mv	a0,s2
    80005562:	ffffd097          	auipc	ra,0xffffd
    80005566:	81c080e7          	jalr	-2020(ra) # 80001d7e <proc_pagetable>
    8000556a:	8baa                	mv	s7,a0
    8000556c:	d945                	beqz	a0,8000551c <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000556e:	e7042983          	lw	s3,-400(s0)
    80005572:	e8845783          	lhu	a5,-376(s0)
    80005576:	c7ad                	beqz	a5,800055e0 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005578:	4a01                	li	s4,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000557a:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    8000557c:	6c85                	lui	s9,0x1
    8000557e:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80005582:	def43823          	sd	a5,-528(s0)
    80005586:	ac0d                	j	800057b8 <exec+0x320>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005588:	00003517          	auipc	a0,0x3
    8000558c:	2c050513          	addi	a0,a0,704 # 80008848 <syscalls+0x2a0>
    80005590:	ffffb097          	auipc	ra,0xffffb
    80005594:	fb4080e7          	jalr	-76(ra) # 80000544 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005598:	8756                	mv	a4,s5
    8000559a:	012d86bb          	addw	a3,s11,s2
    8000559e:	4581                	li	a1,0
    800055a0:	8526                	mv	a0,s1
    800055a2:	fffff097          	auipc	ra,0xfffff
    800055a6:	c94080e7          	jalr	-876(ra) # 80004236 <readi>
    800055aa:	2501                	sext.w	a0,a0
    800055ac:	1aaa9a63          	bne	s5,a0,80005760 <exec+0x2c8>
  for(i = 0; i < sz; i += PGSIZE){
    800055b0:	6785                	lui	a5,0x1
    800055b2:	0127893b          	addw	s2,a5,s2
    800055b6:	77fd                	lui	a5,0xfffff
    800055b8:	01478a3b          	addw	s4,a5,s4
    800055bc:	1f897563          	bgeu	s2,s8,800057a6 <exec+0x30e>
    pa = walkaddr(pagetable, va + i);
    800055c0:	02091593          	slli	a1,s2,0x20
    800055c4:	9181                	srli	a1,a1,0x20
    800055c6:	95ea                	add	a1,a1,s10
    800055c8:	855e                	mv	a0,s7
    800055ca:	ffffc097          	auipc	ra,0xffffc
    800055ce:	c6c080e7          	jalr	-916(ra) # 80001236 <walkaddr>
    800055d2:	862a                	mv	a2,a0
    if(pa == 0)
    800055d4:	d955                	beqz	a0,80005588 <exec+0xf0>
      n = PGSIZE;
    800055d6:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    800055d8:	fd9a70e3          	bgeu	s4,s9,80005598 <exec+0x100>
      n = sz - i;
    800055dc:	8ad2                	mv	s5,s4
    800055de:	bf6d                	j	80005598 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800055e0:	4a01                	li	s4,0
  iunlockput(ip);
    800055e2:	8526                	mv	a0,s1
    800055e4:	fffff097          	auipc	ra,0xfffff
    800055e8:	c00080e7          	jalr	-1024(ra) # 800041e4 <iunlockput>
  end_op();
    800055ec:	fffff097          	auipc	ra,0xfffff
    800055f0:	3d8080e7          	jalr	984(ra) # 800049c4 <end_op>
  p = myproc();
    800055f4:	ffffc097          	auipc	ra,0xffffc
    800055f8:	6c4080e7          	jalr	1732(ra) # 80001cb8 <myproc>
    800055fc:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800055fe:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    80005602:	6785                	lui	a5,0x1
    80005604:	17fd                	addi	a5,a5,-1
    80005606:	9a3e                	add	s4,s4,a5
    80005608:	757d                	lui	a0,0xfffff
    8000560a:	00aa77b3          	and	a5,s4,a0
    8000560e:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005612:	4691                	li	a3,4
    80005614:	6609                	lui	a2,0x2
    80005616:	963e                	add	a2,a2,a5
    80005618:	85be                	mv	a1,a5
    8000561a:	855e                	mv	a0,s7
    8000561c:	ffffc097          	auipc	ra,0xffffc
    80005620:	fce080e7          	jalr	-50(ra) # 800015ea <uvmalloc>
    80005624:	8b2a                	mv	s6,a0
  ip = 0;
    80005626:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005628:	12050c63          	beqz	a0,80005760 <exec+0x2c8>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000562c:	75f9                	lui	a1,0xffffe
    8000562e:	95aa                	add	a1,a1,a0
    80005630:	855e                	mv	a0,s7
    80005632:	ffffc097          	auipc	ra,0xffffc
    80005636:	1d4080e7          	jalr	468(ra) # 80001806 <uvmclear>
  stackbase = sp - PGSIZE;
    8000563a:	7c7d                	lui	s8,0xfffff
    8000563c:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    8000563e:	e0043783          	ld	a5,-512(s0)
    80005642:	6388                	ld	a0,0(a5)
    80005644:	c535                	beqz	a0,800056b0 <exec+0x218>
    80005646:	e9040993          	addi	s3,s0,-368
    8000564a:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    8000564e:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80005650:	ffffc097          	auipc	ra,0xffffc
    80005654:	9d8080e7          	jalr	-1576(ra) # 80001028 <strlen>
    80005658:	2505                	addiw	a0,a0,1
    8000565a:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000565e:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005662:	13896663          	bltu	s2,s8,8000578e <exec+0x2f6>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005666:	e0043d83          	ld	s11,-512(s0)
    8000566a:	000dba03          	ld	s4,0(s11)
    8000566e:	8552                	mv	a0,s4
    80005670:	ffffc097          	auipc	ra,0xffffc
    80005674:	9b8080e7          	jalr	-1608(ra) # 80001028 <strlen>
    80005678:	0015069b          	addiw	a3,a0,1
    8000567c:	8652                	mv	a2,s4
    8000567e:	85ca                	mv	a1,s2
    80005680:	855e                	mv	a0,s7
    80005682:	ffffc097          	auipc	ra,0xffffc
    80005686:	1b6080e7          	jalr	438(ra) # 80001838 <copyout>
    8000568a:	10054663          	bltz	a0,80005796 <exec+0x2fe>
    ustack[argc] = sp;
    8000568e:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005692:	0485                	addi	s1,s1,1
    80005694:	008d8793          	addi	a5,s11,8
    80005698:	e0f43023          	sd	a5,-512(s0)
    8000569c:	008db503          	ld	a0,8(s11)
    800056a0:	c911                	beqz	a0,800056b4 <exec+0x21c>
    if(argc >= MAXARG)
    800056a2:	09a1                	addi	s3,s3,8
    800056a4:	fb3c96e3          	bne	s9,s3,80005650 <exec+0x1b8>
  sz = sz1;
    800056a8:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800056ac:	4481                	li	s1,0
    800056ae:	a84d                	j	80005760 <exec+0x2c8>
  sp = sz;
    800056b0:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    800056b2:	4481                	li	s1,0
  ustack[argc] = 0;
    800056b4:	00349793          	slli	a5,s1,0x3
    800056b8:	f9040713          	addi	a4,s0,-112
    800056bc:	97ba                	add	a5,a5,a4
    800056be:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    800056c2:	00148693          	addi	a3,s1,1
    800056c6:	068e                	slli	a3,a3,0x3
    800056c8:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800056cc:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800056d0:	01897663          	bgeu	s2,s8,800056dc <exec+0x244>
  sz = sz1;
    800056d4:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800056d8:	4481                	li	s1,0
    800056da:	a059                	j	80005760 <exec+0x2c8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800056dc:	e9040613          	addi	a2,s0,-368
    800056e0:	85ca                	mv	a1,s2
    800056e2:	855e                	mv	a0,s7
    800056e4:	ffffc097          	auipc	ra,0xffffc
    800056e8:	154080e7          	jalr	340(ra) # 80001838 <copyout>
    800056ec:	0a054963          	bltz	a0,8000579e <exec+0x306>
  p->trapframe->a1 = sp;
    800056f0:	060ab783          	ld	a5,96(s5)
    800056f4:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800056f8:	df843783          	ld	a5,-520(s0)
    800056fc:	0007c703          	lbu	a4,0(a5)
    80005700:	cf11                	beqz	a4,8000571c <exec+0x284>
    80005702:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005704:	02f00693          	li	a3,47
    80005708:	a039                	j	80005716 <exec+0x27e>
      last = s+1;
    8000570a:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    8000570e:	0785                	addi	a5,a5,1
    80005710:	fff7c703          	lbu	a4,-1(a5)
    80005714:	c701                	beqz	a4,8000571c <exec+0x284>
    if(*s == '/')
    80005716:	fed71ce3          	bne	a4,a3,8000570e <exec+0x276>
    8000571a:	bfc5                	j	8000570a <exec+0x272>
  safestrcpy(p->name, last, sizeof(p->name));
    8000571c:	4641                	li	a2,16
    8000571e:	df843583          	ld	a1,-520(s0)
    80005722:	160a8513          	addi	a0,s5,352
    80005726:	ffffc097          	auipc	ra,0xffffc
    8000572a:	8d0080e7          	jalr	-1840(ra) # 80000ff6 <safestrcpy>
  oldpagetable = p->pagetable;
    8000572e:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    80005732:	057abc23          	sd	s7,88(s5)
  p->sz = sz;
    80005736:	056ab823          	sd	s6,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000573a:	060ab783          	ld	a5,96(s5)
    8000573e:	e6843703          	ld	a4,-408(s0)
    80005742:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005744:	060ab783          	ld	a5,96(s5)
    80005748:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000574c:	85ea                	mv	a1,s10
    8000574e:	ffffc097          	auipc	ra,0xffffc
    80005752:	6cc080e7          	jalr	1740(ra) # 80001e1a <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005756:	0004851b          	sext.w	a0,s1
    8000575a:	bbd9                	j	80005530 <exec+0x98>
    8000575c:	e1443423          	sd	s4,-504(s0)
    proc_freepagetable(pagetable, sz);
    80005760:	e0843583          	ld	a1,-504(s0)
    80005764:	855e                	mv	a0,s7
    80005766:	ffffc097          	auipc	ra,0xffffc
    8000576a:	6b4080e7          	jalr	1716(ra) # 80001e1a <proc_freepagetable>
  if(ip){
    8000576e:	da0497e3          	bnez	s1,8000551c <exec+0x84>
  return -1;
    80005772:	557d                	li	a0,-1
    80005774:	bb75                	j	80005530 <exec+0x98>
    80005776:	e1443423          	sd	s4,-504(s0)
    8000577a:	b7dd                	j	80005760 <exec+0x2c8>
    8000577c:	e1443423          	sd	s4,-504(s0)
    80005780:	b7c5                	j	80005760 <exec+0x2c8>
    80005782:	e1443423          	sd	s4,-504(s0)
    80005786:	bfe9                	j	80005760 <exec+0x2c8>
    80005788:	e1443423          	sd	s4,-504(s0)
    8000578c:	bfd1                	j	80005760 <exec+0x2c8>
  sz = sz1;
    8000578e:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005792:	4481                	li	s1,0
    80005794:	b7f1                	j	80005760 <exec+0x2c8>
  sz = sz1;
    80005796:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000579a:	4481                	li	s1,0
    8000579c:	b7d1                	j	80005760 <exec+0x2c8>
  sz = sz1;
    8000579e:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800057a2:	4481                	li	s1,0
    800057a4:	bf75                	j	80005760 <exec+0x2c8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800057a6:	e0843a03          	ld	s4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800057aa:	2b05                	addiw	s6,s6,1
    800057ac:	0389899b          	addiw	s3,s3,56
    800057b0:	e8845783          	lhu	a5,-376(s0)
    800057b4:	e2fb57e3          	bge	s6,a5,800055e2 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800057b8:	2981                	sext.w	s3,s3
    800057ba:	03800713          	li	a4,56
    800057be:	86ce                	mv	a3,s3
    800057c0:	e1840613          	addi	a2,s0,-488
    800057c4:	4581                	li	a1,0
    800057c6:	8526                	mv	a0,s1
    800057c8:	fffff097          	auipc	ra,0xfffff
    800057cc:	a6e080e7          	jalr	-1426(ra) # 80004236 <readi>
    800057d0:	03800793          	li	a5,56
    800057d4:	f8f514e3          	bne	a0,a5,8000575c <exec+0x2c4>
    if(ph.type != ELF_PROG_LOAD)
    800057d8:	e1842783          	lw	a5,-488(s0)
    800057dc:	4705                	li	a4,1
    800057de:	fce796e3          	bne	a5,a4,800057aa <exec+0x312>
    if(ph.memsz < ph.filesz)
    800057e2:	e4043903          	ld	s2,-448(s0)
    800057e6:	e3843783          	ld	a5,-456(s0)
    800057ea:	f8f966e3          	bltu	s2,a5,80005776 <exec+0x2de>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800057ee:	e2843783          	ld	a5,-472(s0)
    800057f2:	993e                	add	s2,s2,a5
    800057f4:	f8f964e3          	bltu	s2,a5,8000577c <exec+0x2e4>
    if(ph.vaddr % PGSIZE != 0)
    800057f8:	df043703          	ld	a4,-528(s0)
    800057fc:	8ff9                	and	a5,a5,a4
    800057fe:	f3d1                	bnez	a5,80005782 <exec+0x2ea>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005800:	e1c42503          	lw	a0,-484(s0)
    80005804:	00000097          	auipc	ra,0x0
    80005808:	c78080e7          	jalr	-904(ra) # 8000547c <flags2perm>
    8000580c:	86aa                	mv	a3,a0
    8000580e:	864a                	mv	a2,s2
    80005810:	85d2                	mv	a1,s4
    80005812:	855e                	mv	a0,s7
    80005814:	ffffc097          	auipc	ra,0xffffc
    80005818:	dd6080e7          	jalr	-554(ra) # 800015ea <uvmalloc>
    8000581c:	e0a43423          	sd	a0,-504(s0)
    80005820:	d525                	beqz	a0,80005788 <exec+0x2f0>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005822:	e2843d03          	ld	s10,-472(s0)
    80005826:	e2042d83          	lw	s11,-480(s0)
    8000582a:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000582e:	f60c0ce3          	beqz	s8,800057a6 <exec+0x30e>
    80005832:	8a62                	mv	s4,s8
    80005834:	4901                	li	s2,0
    80005836:	b369                	j	800055c0 <exec+0x128>

0000000080005838 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005838:	7179                	addi	sp,sp,-48
    8000583a:	f406                	sd	ra,40(sp)
    8000583c:	f022                	sd	s0,32(sp)
    8000583e:	ec26                	sd	s1,24(sp)
    80005840:	e84a                	sd	s2,16(sp)
    80005842:	1800                	addi	s0,sp,48
    80005844:	892e                	mv	s2,a1
    80005846:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005848:	fdc40593          	addi	a1,s0,-36
    8000584c:	ffffe097          	auipc	ra,0xffffe
    80005850:	914080e7          	jalr	-1772(ra) # 80003160 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005854:	fdc42703          	lw	a4,-36(s0)
    80005858:	47bd                	li	a5,15
    8000585a:	02e7eb63          	bltu	a5,a4,80005890 <argfd+0x58>
    8000585e:	ffffc097          	auipc	ra,0xffffc
    80005862:	45a080e7          	jalr	1114(ra) # 80001cb8 <myproc>
    80005866:	fdc42703          	lw	a4,-36(s0)
    8000586a:	01a70793          	addi	a5,a4,26
    8000586e:	078e                	slli	a5,a5,0x3
    80005870:	953e                	add	a0,a0,a5
    80005872:	651c                	ld	a5,8(a0)
    80005874:	c385                	beqz	a5,80005894 <argfd+0x5c>
    return -1;
  if(pfd)
    80005876:	00090463          	beqz	s2,8000587e <argfd+0x46>
    *pfd = fd;
    8000587a:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000587e:	4501                	li	a0,0
  if(pf)
    80005880:	c091                	beqz	s1,80005884 <argfd+0x4c>
    *pf = f;
    80005882:	e09c                	sd	a5,0(s1)
}
    80005884:	70a2                	ld	ra,40(sp)
    80005886:	7402                	ld	s0,32(sp)
    80005888:	64e2                	ld	s1,24(sp)
    8000588a:	6942                	ld	s2,16(sp)
    8000588c:	6145                	addi	sp,sp,48
    8000588e:	8082                	ret
    return -1;
    80005890:	557d                	li	a0,-1
    80005892:	bfcd                	j	80005884 <argfd+0x4c>
    80005894:	557d                	li	a0,-1
    80005896:	b7fd                	j	80005884 <argfd+0x4c>

0000000080005898 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005898:	1101                	addi	sp,sp,-32
    8000589a:	ec06                	sd	ra,24(sp)
    8000589c:	e822                	sd	s0,16(sp)
    8000589e:	e426                	sd	s1,8(sp)
    800058a0:	1000                	addi	s0,sp,32
    800058a2:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800058a4:	ffffc097          	auipc	ra,0xffffc
    800058a8:	414080e7          	jalr	1044(ra) # 80001cb8 <myproc>
    800058ac:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800058ae:	0d850793          	addi	a5,a0,216 # fffffffffffff0d8 <end+0xffffffff7fdbb640>
    800058b2:	4501                	li	a0,0
    800058b4:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800058b6:	6398                	ld	a4,0(a5)
    800058b8:	cb19                	beqz	a4,800058ce <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800058ba:	2505                	addiw	a0,a0,1
    800058bc:	07a1                	addi	a5,a5,8
    800058be:	fed51ce3          	bne	a0,a3,800058b6 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800058c2:	557d                	li	a0,-1
}
    800058c4:	60e2                	ld	ra,24(sp)
    800058c6:	6442                	ld	s0,16(sp)
    800058c8:	64a2                	ld	s1,8(sp)
    800058ca:	6105                	addi	sp,sp,32
    800058cc:	8082                	ret
      p->ofile[fd] = f;
    800058ce:	01a50793          	addi	a5,a0,26
    800058d2:	078e                	slli	a5,a5,0x3
    800058d4:	963e                	add	a2,a2,a5
    800058d6:	e604                	sd	s1,8(a2)
      return fd;
    800058d8:	b7f5                	j	800058c4 <fdalloc+0x2c>

00000000800058da <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800058da:	715d                	addi	sp,sp,-80
    800058dc:	e486                	sd	ra,72(sp)
    800058de:	e0a2                	sd	s0,64(sp)
    800058e0:	fc26                	sd	s1,56(sp)
    800058e2:	f84a                	sd	s2,48(sp)
    800058e4:	f44e                	sd	s3,40(sp)
    800058e6:	f052                	sd	s4,32(sp)
    800058e8:	ec56                	sd	s5,24(sp)
    800058ea:	e85a                	sd	s6,16(sp)
    800058ec:	0880                	addi	s0,sp,80
    800058ee:	8b2e                	mv	s6,a1
    800058f0:	89b2                	mv	s3,a2
    800058f2:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800058f4:	fb040593          	addi	a1,s0,-80
    800058f8:	fffff097          	auipc	ra,0xfffff
    800058fc:	e4e080e7          	jalr	-434(ra) # 80004746 <nameiparent>
    80005900:	84aa                	mv	s1,a0
    80005902:	16050063          	beqz	a0,80005a62 <create+0x188>
    return 0;

  ilock(dp);
    80005906:	ffffe097          	auipc	ra,0xffffe
    8000590a:	67c080e7          	jalr	1660(ra) # 80003f82 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000590e:	4601                	li	a2,0
    80005910:	fb040593          	addi	a1,s0,-80
    80005914:	8526                	mv	a0,s1
    80005916:	fffff097          	auipc	ra,0xfffff
    8000591a:	b50080e7          	jalr	-1200(ra) # 80004466 <dirlookup>
    8000591e:	8aaa                	mv	s5,a0
    80005920:	c931                	beqz	a0,80005974 <create+0x9a>
    iunlockput(dp);
    80005922:	8526                	mv	a0,s1
    80005924:	fffff097          	auipc	ra,0xfffff
    80005928:	8c0080e7          	jalr	-1856(ra) # 800041e4 <iunlockput>
    ilock(ip);
    8000592c:	8556                	mv	a0,s5
    8000592e:	ffffe097          	auipc	ra,0xffffe
    80005932:	654080e7          	jalr	1620(ra) # 80003f82 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005936:	000b059b          	sext.w	a1,s6
    8000593a:	4789                	li	a5,2
    8000593c:	02f59563          	bne	a1,a5,80005966 <create+0x8c>
    80005940:	044ad783          	lhu	a5,68(s5)
    80005944:	37f9                	addiw	a5,a5,-2
    80005946:	17c2                	slli	a5,a5,0x30
    80005948:	93c1                	srli	a5,a5,0x30
    8000594a:	4705                	li	a4,1
    8000594c:	00f76d63          	bltu	a4,a5,80005966 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005950:	8556                	mv	a0,s5
    80005952:	60a6                	ld	ra,72(sp)
    80005954:	6406                	ld	s0,64(sp)
    80005956:	74e2                	ld	s1,56(sp)
    80005958:	7942                	ld	s2,48(sp)
    8000595a:	79a2                	ld	s3,40(sp)
    8000595c:	7a02                	ld	s4,32(sp)
    8000595e:	6ae2                	ld	s5,24(sp)
    80005960:	6b42                	ld	s6,16(sp)
    80005962:	6161                	addi	sp,sp,80
    80005964:	8082                	ret
    iunlockput(ip);
    80005966:	8556                	mv	a0,s5
    80005968:	fffff097          	auipc	ra,0xfffff
    8000596c:	87c080e7          	jalr	-1924(ra) # 800041e4 <iunlockput>
    return 0;
    80005970:	4a81                	li	s5,0
    80005972:	bff9                	j	80005950 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005974:	85da                	mv	a1,s6
    80005976:	4088                	lw	a0,0(s1)
    80005978:	ffffe097          	auipc	ra,0xffffe
    8000597c:	46e080e7          	jalr	1134(ra) # 80003de6 <ialloc>
    80005980:	8a2a                	mv	s4,a0
    80005982:	c921                	beqz	a0,800059d2 <create+0xf8>
  ilock(ip);
    80005984:	ffffe097          	auipc	ra,0xffffe
    80005988:	5fe080e7          	jalr	1534(ra) # 80003f82 <ilock>
  ip->major = major;
    8000598c:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005990:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005994:	4785                	li	a5,1
    80005996:	04fa1523          	sh	a5,74(s4)
  iupdate(ip);
    8000599a:	8552                	mv	a0,s4
    8000599c:	ffffe097          	auipc	ra,0xffffe
    800059a0:	51c080e7          	jalr	1308(ra) # 80003eb8 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800059a4:	000b059b          	sext.w	a1,s6
    800059a8:	4785                	li	a5,1
    800059aa:	02f58b63          	beq	a1,a5,800059e0 <create+0x106>
  if(dirlink(dp, name, ip->inum) < 0)
    800059ae:	004a2603          	lw	a2,4(s4)
    800059b2:	fb040593          	addi	a1,s0,-80
    800059b6:	8526                	mv	a0,s1
    800059b8:	fffff097          	auipc	ra,0xfffff
    800059bc:	cbe080e7          	jalr	-834(ra) # 80004676 <dirlink>
    800059c0:	06054f63          	bltz	a0,80005a3e <create+0x164>
  iunlockput(dp);
    800059c4:	8526                	mv	a0,s1
    800059c6:	fffff097          	auipc	ra,0xfffff
    800059ca:	81e080e7          	jalr	-2018(ra) # 800041e4 <iunlockput>
  return ip;
    800059ce:	8ad2                	mv	s5,s4
    800059d0:	b741                	j	80005950 <create+0x76>
    iunlockput(dp);
    800059d2:	8526                	mv	a0,s1
    800059d4:	fffff097          	auipc	ra,0xfffff
    800059d8:	810080e7          	jalr	-2032(ra) # 800041e4 <iunlockput>
    return 0;
    800059dc:	8ad2                	mv	s5,s4
    800059de:	bf8d                	j	80005950 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800059e0:	004a2603          	lw	a2,4(s4)
    800059e4:	00003597          	auipc	a1,0x3
    800059e8:	e8458593          	addi	a1,a1,-380 # 80008868 <syscalls+0x2c0>
    800059ec:	8552                	mv	a0,s4
    800059ee:	fffff097          	auipc	ra,0xfffff
    800059f2:	c88080e7          	jalr	-888(ra) # 80004676 <dirlink>
    800059f6:	04054463          	bltz	a0,80005a3e <create+0x164>
    800059fa:	40d0                	lw	a2,4(s1)
    800059fc:	00003597          	auipc	a1,0x3
    80005a00:	e7458593          	addi	a1,a1,-396 # 80008870 <syscalls+0x2c8>
    80005a04:	8552                	mv	a0,s4
    80005a06:	fffff097          	auipc	ra,0xfffff
    80005a0a:	c70080e7          	jalr	-912(ra) # 80004676 <dirlink>
    80005a0e:	02054863          	bltz	a0,80005a3e <create+0x164>
  if(dirlink(dp, name, ip->inum) < 0)
    80005a12:	004a2603          	lw	a2,4(s4)
    80005a16:	fb040593          	addi	a1,s0,-80
    80005a1a:	8526                	mv	a0,s1
    80005a1c:	fffff097          	auipc	ra,0xfffff
    80005a20:	c5a080e7          	jalr	-934(ra) # 80004676 <dirlink>
    80005a24:	00054d63          	bltz	a0,80005a3e <create+0x164>
    dp->nlink++;  // for ".."
    80005a28:	04a4d783          	lhu	a5,74(s1)
    80005a2c:	2785                	addiw	a5,a5,1
    80005a2e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005a32:	8526                	mv	a0,s1
    80005a34:	ffffe097          	auipc	ra,0xffffe
    80005a38:	484080e7          	jalr	1156(ra) # 80003eb8 <iupdate>
    80005a3c:	b761                	j	800059c4 <create+0xea>
  ip->nlink = 0;
    80005a3e:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005a42:	8552                	mv	a0,s4
    80005a44:	ffffe097          	auipc	ra,0xffffe
    80005a48:	474080e7          	jalr	1140(ra) # 80003eb8 <iupdate>
  iunlockput(ip);
    80005a4c:	8552                	mv	a0,s4
    80005a4e:	ffffe097          	auipc	ra,0xffffe
    80005a52:	796080e7          	jalr	1942(ra) # 800041e4 <iunlockput>
  iunlockput(dp);
    80005a56:	8526                	mv	a0,s1
    80005a58:	ffffe097          	auipc	ra,0xffffe
    80005a5c:	78c080e7          	jalr	1932(ra) # 800041e4 <iunlockput>
  return 0;
    80005a60:	bdc5                	j	80005950 <create+0x76>
    return 0;
    80005a62:	8aaa                	mv	s5,a0
    80005a64:	b5f5                	j	80005950 <create+0x76>

0000000080005a66 <sys_dup>:
{
    80005a66:	7179                	addi	sp,sp,-48
    80005a68:	f406                	sd	ra,40(sp)
    80005a6a:	f022                	sd	s0,32(sp)
    80005a6c:	ec26                	sd	s1,24(sp)
    80005a6e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005a70:	fd840613          	addi	a2,s0,-40
    80005a74:	4581                	li	a1,0
    80005a76:	4501                	li	a0,0
    80005a78:	00000097          	auipc	ra,0x0
    80005a7c:	dc0080e7          	jalr	-576(ra) # 80005838 <argfd>
    return -1;
    80005a80:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005a82:	02054363          	bltz	a0,80005aa8 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005a86:	fd843503          	ld	a0,-40(s0)
    80005a8a:	00000097          	auipc	ra,0x0
    80005a8e:	e0e080e7          	jalr	-498(ra) # 80005898 <fdalloc>
    80005a92:	84aa                	mv	s1,a0
    return -1;
    80005a94:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005a96:	00054963          	bltz	a0,80005aa8 <sys_dup+0x42>
  filedup(f);
    80005a9a:	fd843503          	ld	a0,-40(s0)
    80005a9e:	fffff097          	auipc	ra,0xfffff
    80005aa2:	320080e7          	jalr	800(ra) # 80004dbe <filedup>
  return fd;
    80005aa6:	87a6                	mv	a5,s1
}
    80005aa8:	853e                	mv	a0,a5
    80005aaa:	70a2                	ld	ra,40(sp)
    80005aac:	7402                	ld	s0,32(sp)
    80005aae:	64e2                	ld	s1,24(sp)
    80005ab0:	6145                	addi	sp,sp,48
    80005ab2:	8082                	ret

0000000080005ab4 <sys_read>:
{
    80005ab4:	7179                	addi	sp,sp,-48
    80005ab6:	f406                	sd	ra,40(sp)
    80005ab8:	f022                	sd	s0,32(sp)
    80005aba:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005abc:	fd840593          	addi	a1,s0,-40
    80005ac0:	4505                	li	a0,1
    80005ac2:	ffffd097          	auipc	ra,0xffffd
    80005ac6:	6be080e7          	jalr	1726(ra) # 80003180 <argaddr>
  argint(2, &n);
    80005aca:	fe440593          	addi	a1,s0,-28
    80005ace:	4509                	li	a0,2
    80005ad0:	ffffd097          	auipc	ra,0xffffd
    80005ad4:	690080e7          	jalr	1680(ra) # 80003160 <argint>
  if(argfd(0, 0, &f) < 0)
    80005ad8:	fe840613          	addi	a2,s0,-24
    80005adc:	4581                	li	a1,0
    80005ade:	4501                	li	a0,0
    80005ae0:	00000097          	auipc	ra,0x0
    80005ae4:	d58080e7          	jalr	-680(ra) # 80005838 <argfd>
    80005ae8:	87aa                	mv	a5,a0
    return -1;
    80005aea:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005aec:	0007cc63          	bltz	a5,80005b04 <sys_read+0x50>
  return fileread(f, p, n);
    80005af0:	fe442603          	lw	a2,-28(s0)
    80005af4:	fd843583          	ld	a1,-40(s0)
    80005af8:	fe843503          	ld	a0,-24(s0)
    80005afc:	fffff097          	auipc	ra,0xfffff
    80005b00:	44e080e7          	jalr	1102(ra) # 80004f4a <fileread>
}
    80005b04:	70a2                	ld	ra,40(sp)
    80005b06:	7402                	ld	s0,32(sp)
    80005b08:	6145                	addi	sp,sp,48
    80005b0a:	8082                	ret

0000000080005b0c <sys_write>:
{
    80005b0c:	7179                	addi	sp,sp,-48
    80005b0e:	f406                	sd	ra,40(sp)
    80005b10:	f022                	sd	s0,32(sp)
    80005b12:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005b14:	fd840593          	addi	a1,s0,-40
    80005b18:	4505                	li	a0,1
    80005b1a:	ffffd097          	auipc	ra,0xffffd
    80005b1e:	666080e7          	jalr	1638(ra) # 80003180 <argaddr>
  argint(2, &n);
    80005b22:	fe440593          	addi	a1,s0,-28
    80005b26:	4509                	li	a0,2
    80005b28:	ffffd097          	auipc	ra,0xffffd
    80005b2c:	638080e7          	jalr	1592(ra) # 80003160 <argint>
  if(argfd(0, 0, &f) < 0)
    80005b30:	fe840613          	addi	a2,s0,-24
    80005b34:	4581                	li	a1,0
    80005b36:	4501                	li	a0,0
    80005b38:	00000097          	auipc	ra,0x0
    80005b3c:	d00080e7          	jalr	-768(ra) # 80005838 <argfd>
    80005b40:	87aa                	mv	a5,a0
    return -1;
    80005b42:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005b44:	0007cc63          	bltz	a5,80005b5c <sys_write+0x50>
  return filewrite(f, p, n);
    80005b48:	fe442603          	lw	a2,-28(s0)
    80005b4c:	fd843583          	ld	a1,-40(s0)
    80005b50:	fe843503          	ld	a0,-24(s0)
    80005b54:	fffff097          	auipc	ra,0xfffff
    80005b58:	4b8080e7          	jalr	1208(ra) # 8000500c <filewrite>
}
    80005b5c:	70a2                	ld	ra,40(sp)
    80005b5e:	7402                	ld	s0,32(sp)
    80005b60:	6145                	addi	sp,sp,48
    80005b62:	8082                	ret

0000000080005b64 <sys_close>:
{
    80005b64:	1101                	addi	sp,sp,-32
    80005b66:	ec06                	sd	ra,24(sp)
    80005b68:	e822                	sd	s0,16(sp)
    80005b6a:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005b6c:	fe040613          	addi	a2,s0,-32
    80005b70:	fec40593          	addi	a1,s0,-20
    80005b74:	4501                	li	a0,0
    80005b76:	00000097          	auipc	ra,0x0
    80005b7a:	cc2080e7          	jalr	-830(ra) # 80005838 <argfd>
    return -1;
    80005b7e:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005b80:	02054463          	bltz	a0,80005ba8 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005b84:	ffffc097          	auipc	ra,0xffffc
    80005b88:	134080e7          	jalr	308(ra) # 80001cb8 <myproc>
    80005b8c:	fec42783          	lw	a5,-20(s0)
    80005b90:	07e9                	addi	a5,a5,26
    80005b92:	078e                	slli	a5,a5,0x3
    80005b94:	97aa                	add	a5,a5,a0
    80005b96:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    80005b9a:	fe043503          	ld	a0,-32(s0)
    80005b9e:	fffff097          	auipc	ra,0xfffff
    80005ba2:	272080e7          	jalr	626(ra) # 80004e10 <fileclose>
  return 0;
    80005ba6:	4781                	li	a5,0
}
    80005ba8:	853e                	mv	a0,a5
    80005baa:	60e2                	ld	ra,24(sp)
    80005bac:	6442                	ld	s0,16(sp)
    80005bae:	6105                	addi	sp,sp,32
    80005bb0:	8082                	ret

0000000080005bb2 <sys_fstat>:
{
    80005bb2:	1101                	addi	sp,sp,-32
    80005bb4:	ec06                	sd	ra,24(sp)
    80005bb6:	e822                	sd	s0,16(sp)
    80005bb8:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005bba:	fe040593          	addi	a1,s0,-32
    80005bbe:	4505                	li	a0,1
    80005bc0:	ffffd097          	auipc	ra,0xffffd
    80005bc4:	5c0080e7          	jalr	1472(ra) # 80003180 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005bc8:	fe840613          	addi	a2,s0,-24
    80005bcc:	4581                	li	a1,0
    80005bce:	4501                	li	a0,0
    80005bd0:	00000097          	auipc	ra,0x0
    80005bd4:	c68080e7          	jalr	-920(ra) # 80005838 <argfd>
    80005bd8:	87aa                	mv	a5,a0
    return -1;
    80005bda:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005bdc:	0007ca63          	bltz	a5,80005bf0 <sys_fstat+0x3e>
  return filestat(f, st);
    80005be0:	fe043583          	ld	a1,-32(s0)
    80005be4:	fe843503          	ld	a0,-24(s0)
    80005be8:	fffff097          	auipc	ra,0xfffff
    80005bec:	2f0080e7          	jalr	752(ra) # 80004ed8 <filestat>
}
    80005bf0:	60e2                	ld	ra,24(sp)
    80005bf2:	6442                	ld	s0,16(sp)
    80005bf4:	6105                	addi	sp,sp,32
    80005bf6:	8082                	ret

0000000080005bf8 <sys_link>:
{
    80005bf8:	7169                	addi	sp,sp,-304
    80005bfa:	f606                	sd	ra,296(sp)
    80005bfc:	f222                	sd	s0,288(sp)
    80005bfe:	ee26                	sd	s1,280(sp)
    80005c00:	ea4a                	sd	s2,272(sp)
    80005c02:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005c04:	08000613          	li	a2,128
    80005c08:	ed040593          	addi	a1,s0,-304
    80005c0c:	4501                	li	a0,0
    80005c0e:	ffffd097          	auipc	ra,0xffffd
    80005c12:	592080e7          	jalr	1426(ra) # 800031a0 <argstr>
    return -1;
    80005c16:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005c18:	10054e63          	bltz	a0,80005d34 <sys_link+0x13c>
    80005c1c:	08000613          	li	a2,128
    80005c20:	f5040593          	addi	a1,s0,-176
    80005c24:	4505                	li	a0,1
    80005c26:	ffffd097          	auipc	ra,0xffffd
    80005c2a:	57a080e7          	jalr	1402(ra) # 800031a0 <argstr>
    return -1;
    80005c2e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005c30:	10054263          	bltz	a0,80005d34 <sys_link+0x13c>
  begin_op();
    80005c34:	fffff097          	auipc	ra,0xfffff
    80005c38:	d10080e7          	jalr	-752(ra) # 80004944 <begin_op>
  if((ip = namei(old)) == 0){
    80005c3c:	ed040513          	addi	a0,s0,-304
    80005c40:	fffff097          	auipc	ra,0xfffff
    80005c44:	ae8080e7          	jalr	-1304(ra) # 80004728 <namei>
    80005c48:	84aa                	mv	s1,a0
    80005c4a:	c551                	beqz	a0,80005cd6 <sys_link+0xde>
  ilock(ip);
    80005c4c:	ffffe097          	auipc	ra,0xffffe
    80005c50:	336080e7          	jalr	822(ra) # 80003f82 <ilock>
  if(ip->type == T_DIR){
    80005c54:	04449703          	lh	a4,68(s1)
    80005c58:	4785                	li	a5,1
    80005c5a:	08f70463          	beq	a4,a5,80005ce2 <sys_link+0xea>
  ip->nlink++;
    80005c5e:	04a4d783          	lhu	a5,74(s1)
    80005c62:	2785                	addiw	a5,a5,1
    80005c64:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005c68:	8526                	mv	a0,s1
    80005c6a:	ffffe097          	auipc	ra,0xffffe
    80005c6e:	24e080e7          	jalr	590(ra) # 80003eb8 <iupdate>
  iunlock(ip);
    80005c72:	8526                	mv	a0,s1
    80005c74:	ffffe097          	auipc	ra,0xffffe
    80005c78:	3d0080e7          	jalr	976(ra) # 80004044 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005c7c:	fd040593          	addi	a1,s0,-48
    80005c80:	f5040513          	addi	a0,s0,-176
    80005c84:	fffff097          	auipc	ra,0xfffff
    80005c88:	ac2080e7          	jalr	-1342(ra) # 80004746 <nameiparent>
    80005c8c:	892a                	mv	s2,a0
    80005c8e:	c935                	beqz	a0,80005d02 <sys_link+0x10a>
  ilock(dp);
    80005c90:	ffffe097          	auipc	ra,0xffffe
    80005c94:	2f2080e7          	jalr	754(ra) # 80003f82 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005c98:	00092703          	lw	a4,0(s2)
    80005c9c:	409c                	lw	a5,0(s1)
    80005c9e:	04f71d63          	bne	a4,a5,80005cf8 <sys_link+0x100>
    80005ca2:	40d0                	lw	a2,4(s1)
    80005ca4:	fd040593          	addi	a1,s0,-48
    80005ca8:	854a                	mv	a0,s2
    80005caa:	fffff097          	auipc	ra,0xfffff
    80005cae:	9cc080e7          	jalr	-1588(ra) # 80004676 <dirlink>
    80005cb2:	04054363          	bltz	a0,80005cf8 <sys_link+0x100>
  iunlockput(dp);
    80005cb6:	854a                	mv	a0,s2
    80005cb8:	ffffe097          	auipc	ra,0xffffe
    80005cbc:	52c080e7          	jalr	1324(ra) # 800041e4 <iunlockput>
  iput(ip);
    80005cc0:	8526                	mv	a0,s1
    80005cc2:	ffffe097          	auipc	ra,0xffffe
    80005cc6:	47a080e7          	jalr	1146(ra) # 8000413c <iput>
  end_op();
    80005cca:	fffff097          	auipc	ra,0xfffff
    80005cce:	cfa080e7          	jalr	-774(ra) # 800049c4 <end_op>
  return 0;
    80005cd2:	4781                	li	a5,0
    80005cd4:	a085                	j	80005d34 <sys_link+0x13c>
    end_op();
    80005cd6:	fffff097          	auipc	ra,0xfffff
    80005cda:	cee080e7          	jalr	-786(ra) # 800049c4 <end_op>
    return -1;
    80005cde:	57fd                	li	a5,-1
    80005ce0:	a891                	j	80005d34 <sys_link+0x13c>
    iunlockput(ip);
    80005ce2:	8526                	mv	a0,s1
    80005ce4:	ffffe097          	auipc	ra,0xffffe
    80005ce8:	500080e7          	jalr	1280(ra) # 800041e4 <iunlockput>
    end_op();
    80005cec:	fffff097          	auipc	ra,0xfffff
    80005cf0:	cd8080e7          	jalr	-808(ra) # 800049c4 <end_op>
    return -1;
    80005cf4:	57fd                	li	a5,-1
    80005cf6:	a83d                	j	80005d34 <sys_link+0x13c>
    iunlockput(dp);
    80005cf8:	854a                	mv	a0,s2
    80005cfa:	ffffe097          	auipc	ra,0xffffe
    80005cfe:	4ea080e7          	jalr	1258(ra) # 800041e4 <iunlockput>
  ilock(ip);
    80005d02:	8526                	mv	a0,s1
    80005d04:	ffffe097          	auipc	ra,0xffffe
    80005d08:	27e080e7          	jalr	638(ra) # 80003f82 <ilock>
  ip->nlink--;
    80005d0c:	04a4d783          	lhu	a5,74(s1)
    80005d10:	37fd                	addiw	a5,a5,-1
    80005d12:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005d16:	8526                	mv	a0,s1
    80005d18:	ffffe097          	auipc	ra,0xffffe
    80005d1c:	1a0080e7          	jalr	416(ra) # 80003eb8 <iupdate>
  iunlockput(ip);
    80005d20:	8526                	mv	a0,s1
    80005d22:	ffffe097          	auipc	ra,0xffffe
    80005d26:	4c2080e7          	jalr	1218(ra) # 800041e4 <iunlockput>
  end_op();
    80005d2a:	fffff097          	auipc	ra,0xfffff
    80005d2e:	c9a080e7          	jalr	-870(ra) # 800049c4 <end_op>
  return -1;
    80005d32:	57fd                	li	a5,-1
}
    80005d34:	853e                	mv	a0,a5
    80005d36:	70b2                	ld	ra,296(sp)
    80005d38:	7412                	ld	s0,288(sp)
    80005d3a:	64f2                	ld	s1,280(sp)
    80005d3c:	6952                	ld	s2,272(sp)
    80005d3e:	6155                	addi	sp,sp,304
    80005d40:	8082                	ret

0000000080005d42 <sys_unlink>:
{
    80005d42:	7151                	addi	sp,sp,-240
    80005d44:	f586                	sd	ra,232(sp)
    80005d46:	f1a2                	sd	s0,224(sp)
    80005d48:	eda6                	sd	s1,216(sp)
    80005d4a:	e9ca                	sd	s2,208(sp)
    80005d4c:	e5ce                	sd	s3,200(sp)
    80005d4e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005d50:	08000613          	li	a2,128
    80005d54:	f3040593          	addi	a1,s0,-208
    80005d58:	4501                	li	a0,0
    80005d5a:	ffffd097          	auipc	ra,0xffffd
    80005d5e:	446080e7          	jalr	1094(ra) # 800031a0 <argstr>
    80005d62:	18054163          	bltz	a0,80005ee4 <sys_unlink+0x1a2>
  begin_op();
    80005d66:	fffff097          	auipc	ra,0xfffff
    80005d6a:	bde080e7          	jalr	-1058(ra) # 80004944 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005d6e:	fb040593          	addi	a1,s0,-80
    80005d72:	f3040513          	addi	a0,s0,-208
    80005d76:	fffff097          	auipc	ra,0xfffff
    80005d7a:	9d0080e7          	jalr	-1584(ra) # 80004746 <nameiparent>
    80005d7e:	84aa                	mv	s1,a0
    80005d80:	c979                	beqz	a0,80005e56 <sys_unlink+0x114>
  ilock(dp);
    80005d82:	ffffe097          	auipc	ra,0xffffe
    80005d86:	200080e7          	jalr	512(ra) # 80003f82 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005d8a:	00003597          	auipc	a1,0x3
    80005d8e:	ade58593          	addi	a1,a1,-1314 # 80008868 <syscalls+0x2c0>
    80005d92:	fb040513          	addi	a0,s0,-80
    80005d96:	ffffe097          	auipc	ra,0xffffe
    80005d9a:	6b6080e7          	jalr	1718(ra) # 8000444c <namecmp>
    80005d9e:	14050a63          	beqz	a0,80005ef2 <sys_unlink+0x1b0>
    80005da2:	00003597          	auipc	a1,0x3
    80005da6:	ace58593          	addi	a1,a1,-1330 # 80008870 <syscalls+0x2c8>
    80005daa:	fb040513          	addi	a0,s0,-80
    80005dae:	ffffe097          	auipc	ra,0xffffe
    80005db2:	69e080e7          	jalr	1694(ra) # 8000444c <namecmp>
    80005db6:	12050e63          	beqz	a0,80005ef2 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005dba:	f2c40613          	addi	a2,s0,-212
    80005dbe:	fb040593          	addi	a1,s0,-80
    80005dc2:	8526                	mv	a0,s1
    80005dc4:	ffffe097          	auipc	ra,0xffffe
    80005dc8:	6a2080e7          	jalr	1698(ra) # 80004466 <dirlookup>
    80005dcc:	892a                	mv	s2,a0
    80005dce:	12050263          	beqz	a0,80005ef2 <sys_unlink+0x1b0>
  ilock(ip);
    80005dd2:	ffffe097          	auipc	ra,0xffffe
    80005dd6:	1b0080e7          	jalr	432(ra) # 80003f82 <ilock>
  if(ip->nlink < 1)
    80005dda:	04a91783          	lh	a5,74(s2)
    80005dde:	08f05263          	blez	a5,80005e62 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005de2:	04491703          	lh	a4,68(s2)
    80005de6:	4785                	li	a5,1
    80005de8:	08f70563          	beq	a4,a5,80005e72 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005dec:	4641                	li	a2,16
    80005dee:	4581                	li	a1,0
    80005df0:	fc040513          	addi	a0,s0,-64
    80005df4:	ffffb097          	auipc	ra,0xffffb
    80005df8:	0b0080e7          	jalr	176(ra) # 80000ea4 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005dfc:	4741                	li	a4,16
    80005dfe:	f2c42683          	lw	a3,-212(s0)
    80005e02:	fc040613          	addi	a2,s0,-64
    80005e06:	4581                	li	a1,0
    80005e08:	8526                	mv	a0,s1
    80005e0a:	ffffe097          	auipc	ra,0xffffe
    80005e0e:	524080e7          	jalr	1316(ra) # 8000432e <writei>
    80005e12:	47c1                	li	a5,16
    80005e14:	0af51563          	bne	a0,a5,80005ebe <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005e18:	04491703          	lh	a4,68(s2)
    80005e1c:	4785                	li	a5,1
    80005e1e:	0af70863          	beq	a4,a5,80005ece <sys_unlink+0x18c>
  iunlockput(dp);
    80005e22:	8526                	mv	a0,s1
    80005e24:	ffffe097          	auipc	ra,0xffffe
    80005e28:	3c0080e7          	jalr	960(ra) # 800041e4 <iunlockput>
  ip->nlink--;
    80005e2c:	04a95783          	lhu	a5,74(s2)
    80005e30:	37fd                	addiw	a5,a5,-1
    80005e32:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005e36:	854a                	mv	a0,s2
    80005e38:	ffffe097          	auipc	ra,0xffffe
    80005e3c:	080080e7          	jalr	128(ra) # 80003eb8 <iupdate>
  iunlockput(ip);
    80005e40:	854a                	mv	a0,s2
    80005e42:	ffffe097          	auipc	ra,0xffffe
    80005e46:	3a2080e7          	jalr	930(ra) # 800041e4 <iunlockput>
  end_op();
    80005e4a:	fffff097          	auipc	ra,0xfffff
    80005e4e:	b7a080e7          	jalr	-1158(ra) # 800049c4 <end_op>
  return 0;
    80005e52:	4501                	li	a0,0
    80005e54:	a84d                	j	80005f06 <sys_unlink+0x1c4>
    end_op();
    80005e56:	fffff097          	auipc	ra,0xfffff
    80005e5a:	b6e080e7          	jalr	-1170(ra) # 800049c4 <end_op>
    return -1;
    80005e5e:	557d                	li	a0,-1
    80005e60:	a05d                	j	80005f06 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005e62:	00003517          	auipc	a0,0x3
    80005e66:	a1650513          	addi	a0,a0,-1514 # 80008878 <syscalls+0x2d0>
    80005e6a:	ffffa097          	auipc	ra,0xffffa
    80005e6e:	6da080e7          	jalr	1754(ra) # 80000544 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005e72:	04c92703          	lw	a4,76(s2)
    80005e76:	02000793          	li	a5,32
    80005e7a:	f6e7f9e3          	bgeu	a5,a4,80005dec <sys_unlink+0xaa>
    80005e7e:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005e82:	4741                	li	a4,16
    80005e84:	86ce                	mv	a3,s3
    80005e86:	f1840613          	addi	a2,s0,-232
    80005e8a:	4581                	li	a1,0
    80005e8c:	854a                	mv	a0,s2
    80005e8e:	ffffe097          	auipc	ra,0xffffe
    80005e92:	3a8080e7          	jalr	936(ra) # 80004236 <readi>
    80005e96:	47c1                	li	a5,16
    80005e98:	00f51b63          	bne	a0,a5,80005eae <sys_unlink+0x16c>
    if(de.inum != 0)
    80005e9c:	f1845783          	lhu	a5,-232(s0)
    80005ea0:	e7a1                	bnez	a5,80005ee8 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005ea2:	29c1                	addiw	s3,s3,16
    80005ea4:	04c92783          	lw	a5,76(s2)
    80005ea8:	fcf9ede3          	bltu	s3,a5,80005e82 <sys_unlink+0x140>
    80005eac:	b781                	j	80005dec <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005eae:	00003517          	auipc	a0,0x3
    80005eb2:	9e250513          	addi	a0,a0,-1566 # 80008890 <syscalls+0x2e8>
    80005eb6:	ffffa097          	auipc	ra,0xffffa
    80005eba:	68e080e7          	jalr	1678(ra) # 80000544 <panic>
    panic("unlink: writei");
    80005ebe:	00003517          	auipc	a0,0x3
    80005ec2:	9ea50513          	addi	a0,a0,-1558 # 800088a8 <syscalls+0x300>
    80005ec6:	ffffa097          	auipc	ra,0xffffa
    80005eca:	67e080e7          	jalr	1662(ra) # 80000544 <panic>
    dp->nlink--;
    80005ece:	04a4d783          	lhu	a5,74(s1)
    80005ed2:	37fd                	addiw	a5,a5,-1
    80005ed4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005ed8:	8526                	mv	a0,s1
    80005eda:	ffffe097          	auipc	ra,0xffffe
    80005ede:	fde080e7          	jalr	-34(ra) # 80003eb8 <iupdate>
    80005ee2:	b781                	j	80005e22 <sys_unlink+0xe0>
    return -1;
    80005ee4:	557d                	li	a0,-1
    80005ee6:	a005                	j	80005f06 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005ee8:	854a                	mv	a0,s2
    80005eea:	ffffe097          	auipc	ra,0xffffe
    80005eee:	2fa080e7          	jalr	762(ra) # 800041e4 <iunlockput>
  iunlockput(dp);
    80005ef2:	8526                	mv	a0,s1
    80005ef4:	ffffe097          	auipc	ra,0xffffe
    80005ef8:	2f0080e7          	jalr	752(ra) # 800041e4 <iunlockput>
  end_op();
    80005efc:	fffff097          	auipc	ra,0xfffff
    80005f00:	ac8080e7          	jalr	-1336(ra) # 800049c4 <end_op>
  return -1;
    80005f04:	557d                	li	a0,-1
}
    80005f06:	70ae                	ld	ra,232(sp)
    80005f08:	740e                	ld	s0,224(sp)
    80005f0a:	64ee                	ld	s1,216(sp)
    80005f0c:	694e                	ld	s2,208(sp)
    80005f0e:	69ae                	ld	s3,200(sp)
    80005f10:	616d                	addi	sp,sp,240
    80005f12:	8082                	ret

0000000080005f14 <sys_open>:

uint64
sys_open(void)
{
    80005f14:	7131                	addi	sp,sp,-192
    80005f16:	fd06                	sd	ra,184(sp)
    80005f18:	f922                	sd	s0,176(sp)
    80005f1a:	f526                	sd	s1,168(sp)
    80005f1c:	f14a                	sd	s2,160(sp)
    80005f1e:	ed4e                	sd	s3,152(sp)
    80005f20:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005f22:	f4c40593          	addi	a1,s0,-180
    80005f26:	4505                	li	a0,1
    80005f28:	ffffd097          	auipc	ra,0xffffd
    80005f2c:	238080e7          	jalr	568(ra) # 80003160 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005f30:	08000613          	li	a2,128
    80005f34:	f5040593          	addi	a1,s0,-176
    80005f38:	4501                	li	a0,0
    80005f3a:	ffffd097          	auipc	ra,0xffffd
    80005f3e:	266080e7          	jalr	614(ra) # 800031a0 <argstr>
    80005f42:	87aa                	mv	a5,a0
    return -1;
    80005f44:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005f46:	0a07c963          	bltz	a5,80005ff8 <sys_open+0xe4>

  begin_op();
    80005f4a:	fffff097          	auipc	ra,0xfffff
    80005f4e:	9fa080e7          	jalr	-1542(ra) # 80004944 <begin_op>

  if(omode & O_CREATE){
    80005f52:	f4c42783          	lw	a5,-180(s0)
    80005f56:	2007f793          	andi	a5,a5,512
    80005f5a:	cfc5                	beqz	a5,80006012 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005f5c:	4681                	li	a3,0
    80005f5e:	4601                	li	a2,0
    80005f60:	4589                	li	a1,2
    80005f62:	f5040513          	addi	a0,s0,-176
    80005f66:	00000097          	auipc	ra,0x0
    80005f6a:	974080e7          	jalr	-1676(ra) # 800058da <create>
    80005f6e:	84aa                	mv	s1,a0
    if(ip == 0){
    80005f70:	c959                	beqz	a0,80006006 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005f72:	04449703          	lh	a4,68(s1)
    80005f76:	478d                	li	a5,3
    80005f78:	00f71763          	bne	a4,a5,80005f86 <sys_open+0x72>
    80005f7c:	0464d703          	lhu	a4,70(s1)
    80005f80:	47a5                	li	a5,9
    80005f82:	0ce7ed63          	bltu	a5,a4,8000605c <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005f86:	fffff097          	auipc	ra,0xfffff
    80005f8a:	dce080e7          	jalr	-562(ra) # 80004d54 <filealloc>
    80005f8e:	89aa                	mv	s3,a0
    80005f90:	10050363          	beqz	a0,80006096 <sys_open+0x182>
    80005f94:	00000097          	auipc	ra,0x0
    80005f98:	904080e7          	jalr	-1788(ra) # 80005898 <fdalloc>
    80005f9c:	892a                	mv	s2,a0
    80005f9e:	0e054763          	bltz	a0,8000608c <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005fa2:	04449703          	lh	a4,68(s1)
    80005fa6:	478d                	li	a5,3
    80005fa8:	0cf70563          	beq	a4,a5,80006072 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005fac:	4789                	li	a5,2
    80005fae:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005fb2:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005fb6:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005fba:	f4c42783          	lw	a5,-180(s0)
    80005fbe:	0017c713          	xori	a4,a5,1
    80005fc2:	8b05                	andi	a4,a4,1
    80005fc4:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005fc8:	0037f713          	andi	a4,a5,3
    80005fcc:	00e03733          	snez	a4,a4
    80005fd0:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005fd4:	4007f793          	andi	a5,a5,1024
    80005fd8:	c791                	beqz	a5,80005fe4 <sys_open+0xd0>
    80005fda:	04449703          	lh	a4,68(s1)
    80005fde:	4789                	li	a5,2
    80005fe0:	0af70063          	beq	a4,a5,80006080 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005fe4:	8526                	mv	a0,s1
    80005fe6:	ffffe097          	auipc	ra,0xffffe
    80005fea:	05e080e7          	jalr	94(ra) # 80004044 <iunlock>
  end_op();
    80005fee:	fffff097          	auipc	ra,0xfffff
    80005ff2:	9d6080e7          	jalr	-1578(ra) # 800049c4 <end_op>

  return fd;
    80005ff6:	854a                	mv	a0,s2
}
    80005ff8:	70ea                	ld	ra,184(sp)
    80005ffa:	744a                	ld	s0,176(sp)
    80005ffc:	74aa                	ld	s1,168(sp)
    80005ffe:	790a                	ld	s2,160(sp)
    80006000:	69ea                	ld	s3,152(sp)
    80006002:	6129                	addi	sp,sp,192
    80006004:	8082                	ret
      end_op();
    80006006:	fffff097          	auipc	ra,0xfffff
    8000600a:	9be080e7          	jalr	-1602(ra) # 800049c4 <end_op>
      return -1;
    8000600e:	557d                	li	a0,-1
    80006010:	b7e5                	j	80005ff8 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80006012:	f5040513          	addi	a0,s0,-176
    80006016:	ffffe097          	auipc	ra,0xffffe
    8000601a:	712080e7          	jalr	1810(ra) # 80004728 <namei>
    8000601e:	84aa                	mv	s1,a0
    80006020:	c905                	beqz	a0,80006050 <sys_open+0x13c>
    ilock(ip);
    80006022:	ffffe097          	auipc	ra,0xffffe
    80006026:	f60080e7          	jalr	-160(ra) # 80003f82 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000602a:	04449703          	lh	a4,68(s1)
    8000602e:	4785                	li	a5,1
    80006030:	f4f711e3          	bne	a4,a5,80005f72 <sys_open+0x5e>
    80006034:	f4c42783          	lw	a5,-180(s0)
    80006038:	d7b9                	beqz	a5,80005f86 <sys_open+0x72>
      iunlockput(ip);
    8000603a:	8526                	mv	a0,s1
    8000603c:	ffffe097          	auipc	ra,0xffffe
    80006040:	1a8080e7          	jalr	424(ra) # 800041e4 <iunlockput>
      end_op();
    80006044:	fffff097          	auipc	ra,0xfffff
    80006048:	980080e7          	jalr	-1664(ra) # 800049c4 <end_op>
      return -1;
    8000604c:	557d                	li	a0,-1
    8000604e:	b76d                	j	80005ff8 <sys_open+0xe4>
      end_op();
    80006050:	fffff097          	auipc	ra,0xfffff
    80006054:	974080e7          	jalr	-1676(ra) # 800049c4 <end_op>
      return -1;
    80006058:	557d                	li	a0,-1
    8000605a:	bf79                	j	80005ff8 <sys_open+0xe4>
    iunlockput(ip);
    8000605c:	8526                	mv	a0,s1
    8000605e:	ffffe097          	auipc	ra,0xffffe
    80006062:	186080e7          	jalr	390(ra) # 800041e4 <iunlockput>
    end_op();
    80006066:	fffff097          	auipc	ra,0xfffff
    8000606a:	95e080e7          	jalr	-1698(ra) # 800049c4 <end_op>
    return -1;
    8000606e:	557d                	li	a0,-1
    80006070:	b761                	j	80005ff8 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80006072:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80006076:	04649783          	lh	a5,70(s1)
    8000607a:	02f99223          	sh	a5,36(s3)
    8000607e:	bf25                	j	80005fb6 <sys_open+0xa2>
    itrunc(ip);
    80006080:	8526                	mv	a0,s1
    80006082:	ffffe097          	auipc	ra,0xffffe
    80006086:	00e080e7          	jalr	14(ra) # 80004090 <itrunc>
    8000608a:	bfa9                	j	80005fe4 <sys_open+0xd0>
      fileclose(f);
    8000608c:	854e                	mv	a0,s3
    8000608e:	fffff097          	auipc	ra,0xfffff
    80006092:	d82080e7          	jalr	-638(ra) # 80004e10 <fileclose>
    iunlockput(ip);
    80006096:	8526                	mv	a0,s1
    80006098:	ffffe097          	auipc	ra,0xffffe
    8000609c:	14c080e7          	jalr	332(ra) # 800041e4 <iunlockput>
    end_op();
    800060a0:	fffff097          	auipc	ra,0xfffff
    800060a4:	924080e7          	jalr	-1756(ra) # 800049c4 <end_op>
    return -1;
    800060a8:	557d                	li	a0,-1
    800060aa:	b7b9                	j	80005ff8 <sys_open+0xe4>

00000000800060ac <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800060ac:	7175                	addi	sp,sp,-144
    800060ae:	e506                	sd	ra,136(sp)
    800060b0:	e122                	sd	s0,128(sp)
    800060b2:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800060b4:	fffff097          	auipc	ra,0xfffff
    800060b8:	890080e7          	jalr	-1904(ra) # 80004944 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800060bc:	08000613          	li	a2,128
    800060c0:	f7040593          	addi	a1,s0,-144
    800060c4:	4501                	li	a0,0
    800060c6:	ffffd097          	auipc	ra,0xffffd
    800060ca:	0da080e7          	jalr	218(ra) # 800031a0 <argstr>
    800060ce:	02054963          	bltz	a0,80006100 <sys_mkdir+0x54>
    800060d2:	4681                	li	a3,0
    800060d4:	4601                	li	a2,0
    800060d6:	4585                	li	a1,1
    800060d8:	f7040513          	addi	a0,s0,-144
    800060dc:	fffff097          	auipc	ra,0xfffff
    800060e0:	7fe080e7          	jalr	2046(ra) # 800058da <create>
    800060e4:	cd11                	beqz	a0,80006100 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800060e6:	ffffe097          	auipc	ra,0xffffe
    800060ea:	0fe080e7          	jalr	254(ra) # 800041e4 <iunlockput>
  end_op();
    800060ee:	fffff097          	auipc	ra,0xfffff
    800060f2:	8d6080e7          	jalr	-1834(ra) # 800049c4 <end_op>
  return 0;
    800060f6:	4501                	li	a0,0
}
    800060f8:	60aa                	ld	ra,136(sp)
    800060fa:	640a                	ld	s0,128(sp)
    800060fc:	6149                	addi	sp,sp,144
    800060fe:	8082                	ret
    end_op();
    80006100:	fffff097          	auipc	ra,0xfffff
    80006104:	8c4080e7          	jalr	-1852(ra) # 800049c4 <end_op>
    return -1;
    80006108:	557d                	li	a0,-1
    8000610a:	b7fd                	j	800060f8 <sys_mkdir+0x4c>

000000008000610c <sys_mknod>:

uint64
sys_mknod(void)
{
    8000610c:	7135                	addi	sp,sp,-160
    8000610e:	ed06                	sd	ra,152(sp)
    80006110:	e922                	sd	s0,144(sp)
    80006112:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80006114:	fffff097          	auipc	ra,0xfffff
    80006118:	830080e7          	jalr	-2000(ra) # 80004944 <begin_op>
  argint(1, &major);
    8000611c:	f6c40593          	addi	a1,s0,-148
    80006120:	4505                	li	a0,1
    80006122:	ffffd097          	auipc	ra,0xffffd
    80006126:	03e080e7          	jalr	62(ra) # 80003160 <argint>
  argint(2, &minor);
    8000612a:	f6840593          	addi	a1,s0,-152
    8000612e:	4509                	li	a0,2
    80006130:	ffffd097          	auipc	ra,0xffffd
    80006134:	030080e7          	jalr	48(ra) # 80003160 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006138:	08000613          	li	a2,128
    8000613c:	f7040593          	addi	a1,s0,-144
    80006140:	4501                	li	a0,0
    80006142:	ffffd097          	auipc	ra,0xffffd
    80006146:	05e080e7          	jalr	94(ra) # 800031a0 <argstr>
    8000614a:	02054b63          	bltz	a0,80006180 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000614e:	f6841683          	lh	a3,-152(s0)
    80006152:	f6c41603          	lh	a2,-148(s0)
    80006156:	458d                	li	a1,3
    80006158:	f7040513          	addi	a0,s0,-144
    8000615c:	fffff097          	auipc	ra,0xfffff
    80006160:	77e080e7          	jalr	1918(ra) # 800058da <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006164:	cd11                	beqz	a0,80006180 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006166:	ffffe097          	auipc	ra,0xffffe
    8000616a:	07e080e7          	jalr	126(ra) # 800041e4 <iunlockput>
  end_op();
    8000616e:	fffff097          	auipc	ra,0xfffff
    80006172:	856080e7          	jalr	-1962(ra) # 800049c4 <end_op>
  return 0;
    80006176:	4501                	li	a0,0
}
    80006178:	60ea                	ld	ra,152(sp)
    8000617a:	644a                	ld	s0,144(sp)
    8000617c:	610d                	addi	sp,sp,160
    8000617e:	8082                	ret
    end_op();
    80006180:	fffff097          	auipc	ra,0xfffff
    80006184:	844080e7          	jalr	-1980(ra) # 800049c4 <end_op>
    return -1;
    80006188:	557d                	li	a0,-1
    8000618a:	b7fd                	j	80006178 <sys_mknod+0x6c>

000000008000618c <sys_chdir>:

uint64
sys_chdir(void)
{
    8000618c:	7135                	addi	sp,sp,-160
    8000618e:	ed06                	sd	ra,152(sp)
    80006190:	e922                	sd	s0,144(sp)
    80006192:	e526                	sd	s1,136(sp)
    80006194:	e14a                	sd	s2,128(sp)
    80006196:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80006198:	ffffc097          	auipc	ra,0xffffc
    8000619c:	b20080e7          	jalr	-1248(ra) # 80001cb8 <myproc>
    800061a0:	892a                	mv	s2,a0
  
  begin_op();
    800061a2:	ffffe097          	auipc	ra,0xffffe
    800061a6:	7a2080e7          	jalr	1954(ra) # 80004944 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800061aa:	08000613          	li	a2,128
    800061ae:	f6040593          	addi	a1,s0,-160
    800061b2:	4501                	li	a0,0
    800061b4:	ffffd097          	auipc	ra,0xffffd
    800061b8:	fec080e7          	jalr	-20(ra) # 800031a0 <argstr>
    800061bc:	04054b63          	bltz	a0,80006212 <sys_chdir+0x86>
    800061c0:	f6040513          	addi	a0,s0,-160
    800061c4:	ffffe097          	auipc	ra,0xffffe
    800061c8:	564080e7          	jalr	1380(ra) # 80004728 <namei>
    800061cc:	84aa                	mv	s1,a0
    800061ce:	c131                	beqz	a0,80006212 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800061d0:	ffffe097          	auipc	ra,0xffffe
    800061d4:	db2080e7          	jalr	-590(ra) # 80003f82 <ilock>
  if(ip->type != T_DIR){
    800061d8:	04449703          	lh	a4,68(s1)
    800061dc:	4785                	li	a5,1
    800061de:	04f71063          	bne	a4,a5,8000621e <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800061e2:	8526                	mv	a0,s1
    800061e4:	ffffe097          	auipc	ra,0xffffe
    800061e8:	e60080e7          	jalr	-416(ra) # 80004044 <iunlock>
  iput(p->cwd);
    800061ec:	15893503          	ld	a0,344(s2)
    800061f0:	ffffe097          	auipc	ra,0xffffe
    800061f4:	f4c080e7          	jalr	-180(ra) # 8000413c <iput>
  end_op();
    800061f8:	ffffe097          	auipc	ra,0xffffe
    800061fc:	7cc080e7          	jalr	1996(ra) # 800049c4 <end_op>
  p->cwd = ip;
    80006200:	14993c23          	sd	s1,344(s2)
  return 0;
    80006204:	4501                	li	a0,0
}
    80006206:	60ea                	ld	ra,152(sp)
    80006208:	644a                	ld	s0,144(sp)
    8000620a:	64aa                	ld	s1,136(sp)
    8000620c:	690a                	ld	s2,128(sp)
    8000620e:	610d                	addi	sp,sp,160
    80006210:	8082                	ret
    end_op();
    80006212:	ffffe097          	auipc	ra,0xffffe
    80006216:	7b2080e7          	jalr	1970(ra) # 800049c4 <end_op>
    return -1;
    8000621a:	557d                	li	a0,-1
    8000621c:	b7ed                	j	80006206 <sys_chdir+0x7a>
    iunlockput(ip);
    8000621e:	8526                	mv	a0,s1
    80006220:	ffffe097          	auipc	ra,0xffffe
    80006224:	fc4080e7          	jalr	-60(ra) # 800041e4 <iunlockput>
    end_op();
    80006228:	ffffe097          	auipc	ra,0xffffe
    8000622c:	79c080e7          	jalr	1948(ra) # 800049c4 <end_op>
    return -1;
    80006230:	557d                	li	a0,-1
    80006232:	bfd1                	j	80006206 <sys_chdir+0x7a>

0000000080006234 <sys_exec>:

uint64
sys_exec(void)
{
    80006234:	7145                	addi	sp,sp,-464
    80006236:	e786                	sd	ra,456(sp)
    80006238:	e3a2                	sd	s0,448(sp)
    8000623a:	ff26                	sd	s1,440(sp)
    8000623c:	fb4a                	sd	s2,432(sp)
    8000623e:	f74e                	sd	s3,424(sp)
    80006240:	f352                	sd	s4,416(sp)
    80006242:	ef56                	sd	s5,408(sp)
    80006244:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80006246:	e3840593          	addi	a1,s0,-456
    8000624a:	4505                	li	a0,1
    8000624c:	ffffd097          	auipc	ra,0xffffd
    80006250:	f34080e7          	jalr	-204(ra) # 80003180 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80006254:	08000613          	li	a2,128
    80006258:	f4040593          	addi	a1,s0,-192
    8000625c:	4501                	li	a0,0
    8000625e:	ffffd097          	auipc	ra,0xffffd
    80006262:	f42080e7          	jalr	-190(ra) # 800031a0 <argstr>
    80006266:	87aa                	mv	a5,a0
    return -1;
    80006268:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000626a:	0c07c263          	bltz	a5,8000632e <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    8000626e:	10000613          	li	a2,256
    80006272:	4581                	li	a1,0
    80006274:	e4040513          	addi	a0,s0,-448
    80006278:	ffffb097          	auipc	ra,0xffffb
    8000627c:	c2c080e7          	jalr	-980(ra) # 80000ea4 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006280:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80006284:	89a6                	mv	s3,s1
    80006286:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80006288:	02000a13          	li	s4,32
    8000628c:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006290:	00391513          	slli	a0,s2,0x3
    80006294:	e3040593          	addi	a1,s0,-464
    80006298:	e3843783          	ld	a5,-456(s0)
    8000629c:	953e                	add	a0,a0,a5
    8000629e:	ffffd097          	auipc	ra,0xffffd
    800062a2:	e24080e7          	jalr	-476(ra) # 800030c2 <fetchaddr>
    800062a6:	02054a63          	bltz	a0,800062da <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    800062aa:	e3043783          	ld	a5,-464(s0)
    800062ae:	c3b9                	beqz	a5,800062f4 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800062b0:	ffffb097          	auipc	ra,0xffffb
    800062b4:	9c4080e7          	jalr	-1596(ra) # 80000c74 <kalloc>
    800062b8:	85aa                	mv	a1,a0
    800062ba:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800062be:	cd11                	beqz	a0,800062da <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800062c0:	6605                	lui	a2,0x1
    800062c2:	e3043503          	ld	a0,-464(s0)
    800062c6:	ffffd097          	auipc	ra,0xffffd
    800062ca:	e4e080e7          	jalr	-434(ra) # 80003114 <fetchstr>
    800062ce:	00054663          	bltz	a0,800062da <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    800062d2:	0905                	addi	s2,s2,1
    800062d4:	09a1                	addi	s3,s3,8
    800062d6:	fb491be3          	bne	s2,s4,8000628c <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800062da:	10048913          	addi	s2,s1,256
    800062de:	6088                	ld	a0,0(s1)
    800062e0:	c531                	beqz	a0,8000632c <sys_exec+0xf8>
    kfree(argv[i]);
    800062e2:	ffffa097          	auipc	ra,0xffffa
    800062e6:	7ec080e7          	jalr	2028(ra) # 80000ace <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800062ea:	04a1                	addi	s1,s1,8
    800062ec:	ff2499e3          	bne	s1,s2,800062de <sys_exec+0xaa>
  return -1;
    800062f0:	557d                	li	a0,-1
    800062f2:	a835                	j	8000632e <sys_exec+0xfa>
      argv[i] = 0;
    800062f4:	0a8e                	slli	s5,s5,0x3
    800062f6:	fc040793          	addi	a5,s0,-64
    800062fa:	9abe                	add	s5,s5,a5
    800062fc:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80006300:	e4040593          	addi	a1,s0,-448
    80006304:	f4040513          	addi	a0,s0,-192
    80006308:	fffff097          	auipc	ra,0xfffff
    8000630c:	190080e7          	jalr	400(ra) # 80005498 <exec>
    80006310:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006312:	10048993          	addi	s3,s1,256
    80006316:	6088                	ld	a0,0(s1)
    80006318:	c901                	beqz	a0,80006328 <sys_exec+0xf4>
    kfree(argv[i]);
    8000631a:	ffffa097          	auipc	ra,0xffffa
    8000631e:	7b4080e7          	jalr	1972(ra) # 80000ace <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006322:	04a1                	addi	s1,s1,8
    80006324:	ff3499e3          	bne	s1,s3,80006316 <sys_exec+0xe2>
  return ret;
    80006328:	854a                	mv	a0,s2
    8000632a:	a011                	j	8000632e <sys_exec+0xfa>
  return -1;
    8000632c:	557d                	li	a0,-1
}
    8000632e:	60be                	ld	ra,456(sp)
    80006330:	641e                	ld	s0,448(sp)
    80006332:	74fa                	ld	s1,440(sp)
    80006334:	795a                	ld	s2,432(sp)
    80006336:	79ba                	ld	s3,424(sp)
    80006338:	7a1a                	ld	s4,416(sp)
    8000633a:	6afa                	ld	s5,408(sp)
    8000633c:	6179                	addi	sp,sp,464
    8000633e:	8082                	ret

0000000080006340 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006340:	7139                	addi	sp,sp,-64
    80006342:	fc06                	sd	ra,56(sp)
    80006344:	f822                	sd	s0,48(sp)
    80006346:	f426                	sd	s1,40(sp)
    80006348:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000634a:	ffffc097          	auipc	ra,0xffffc
    8000634e:	96e080e7          	jalr	-1682(ra) # 80001cb8 <myproc>
    80006352:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80006354:	fd840593          	addi	a1,s0,-40
    80006358:	4501                	li	a0,0
    8000635a:	ffffd097          	auipc	ra,0xffffd
    8000635e:	e26080e7          	jalr	-474(ra) # 80003180 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80006362:	fc840593          	addi	a1,s0,-56
    80006366:	fd040513          	addi	a0,s0,-48
    8000636a:	fffff097          	auipc	ra,0xfffff
    8000636e:	dd6080e7          	jalr	-554(ra) # 80005140 <pipealloc>
    return -1;
    80006372:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006374:	0c054463          	bltz	a0,8000643c <sys_pipe+0xfc>
  fd0 = -1;
    80006378:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000637c:	fd043503          	ld	a0,-48(s0)
    80006380:	fffff097          	auipc	ra,0xfffff
    80006384:	518080e7          	jalr	1304(ra) # 80005898 <fdalloc>
    80006388:	fca42223          	sw	a0,-60(s0)
    8000638c:	08054b63          	bltz	a0,80006422 <sys_pipe+0xe2>
    80006390:	fc843503          	ld	a0,-56(s0)
    80006394:	fffff097          	auipc	ra,0xfffff
    80006398:	504080e7          	jalr	1284(ra) # 80005898 <fdalloc>
    8000639c:	fca42023          	sw	a0,-64(s0)
    800063a0:	06054863          	bltz	a0,80006410 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800063a4:	4691                	li	a3,4
    800063a6:	fc440613          	addi	a2,s0,-60
    800063aa:	fd843583          	ld	a1,-40(s0)
    800063ae:	6ca8                	ld	a0,88(s1)
    800063b0:	ffffb097          	auipc	ra,0xffffb
    800063b4:	488080e7          	jalr	1160(ra) # 80001838 <copyout>
    800063b8:	02054063          	bltz	a0,800063d8 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800063bc:	4691                	li	a3,4
    800063be:	fc040613          	addi	a2,s0,-64
    800063c2:	fd843583          	ld	a1,-40(s0)
    800063c6:	0591                	addi	a1,a1,4
    800063c8:	6ca8                	ld	a0,88(s1)
    800063ca:	ffffb097          	auipc	ra,0xffffb
    800063ce:	46e080e7          	jalr	1134(ra) # 80001838 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800063d2:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800063d4:	06055463          	bgez	a0,8000643c <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    800063d8:	fc442783          	lw	a5,-60(s0)
    800063dc:	07e9                	addi	a5,a5,26
    800063de:	078e                	slli	a5,a5,0x3
    800063e0:	97a6                	add	a5,a5,s1
    800063e2:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    800063e6:	fc042503          	lw	a0,-64(s0)
    800063ea:	0569                	addi	a0,a0,26
    800063ec:	050e                	slli	a0,a0,0x3
    800063ee:	94aa                	add	s1,s1,a0
    800063f0:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    800063f4:	fd043503          	ld	a0,-48(s0)
    800063f8:	fffff097          	auipc	ra,0xfffff
    800063fc:	a18080e7          	jalr	-1512(ra) # 80004e10 <fileclose>
    fileclose(wf);
    80006400:	fc843503          	ld	a0,-56(s0)
    80006404:	fffff097          	auipc	ra,0xfffff
    80006408:	a0c080e7          	jalr	-1524(ra) # 80004e10 <fileclose>
    return -1;
    8000640c:	57fd                	li	a5,-1
    8000640e:	a03d                	j	8000643c <sys_pipe+0xfc>
    if(fd0 >= 0)
    80006410:	fc442783          	lw	a5,-60(s0)
    80006414:	0007c763          	bltz	a5,80006422 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80006418:	07e9                	addi	a5,a5,26
    8000641a:	078e                	slli	a5,a5,0x3
    8000641c:	94be                	add	s1,s1,a5
    8000641e:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80006422:	fd043503          	ld	a0,-48(s0)
    80006426:	fffff097          	auipc	ra,0xfffff
    8000642a:	9ea080e7          	jalr	-1558(ra) # 80004e10 <fileclose>
    fileclose(wf);
    8000642e:	fc843503          	ld	a0,-56(s0)
    80006432:	fffff097          	auipc	ra,0xfffff
    80006436:	9de080e7          	jalr	-1570(ra) # 80004e10 <fileclose>
    return -1;
    8000643a:	57fd                	li	a5,-1
}
    8000643c:	853e                	mv	a0,a5
    8000643e:	70e2                	ld	ra,56(sp)
    80006440:	7442                	ld	s0,48(sp)
    80006442:	74a2                	ld	s1,40(sp)
    80006444:	6121                	addi	sp,sp,64
    80006446:	8082                	ret
	...

0000000080006450 <kernelvec>:
    80006450:	7111                	addi	sp,sp,-256
    80006452:	e006                	sd	ra,0(sp)
    80006454:	e40a                	sd	sp,8(sp)
    80006456:	e80e                	sd	gp,16(sp)
    80006458:	ec12                	sd	tp,24(sp)
    8000645a:	f016                	sd	t0,32(sp)
    8000645c:	f41a                	sd	t1,40(sp)
    8000645e:	f81e                	sd	t2,48(sp)
    80006460:	fc22                	sd	s0,56(sp)
    80006462:	e0a6                	sd	s1,64(sp)
    80006464:	e4aa                	sd	a0,72(sp)
    80006466:	e8ae                	sd	a1,80(sp)
    80006468:	ecb2                	sd	a2,88(sp)
    8000646a:	f0b6                	sd	a3,96(sp)
    8000646c:	f4ba                	sd	a4,104(sp)
    8000646e:	f8be                	sd	a5,112(sp)
    80006470:	fcc2                	sd	a6,120(sp)
    80006472:	e146                	sd	a7,128(sp)
    80006474:	e54a                	sd	s2,136(sp)
    80006476:	e94e                	sd	s3,144(sp)
    80006478:	ed52                	sd	s4,152(sp)
    8000647a:	f156                	sd	s5,160(sp)
    8000647c:	f55a                	sd	s6,168(sp)
    8000647e:	f95e                	sd	s7,176(sp)
    80006480:	fd62                	sd	s8,184(sp)
    80006482:	e1e6                	sd	s9,192(sp)
    80006484:	e5ea                	sd	s10,200(sp)
    80006486:	e9ee                	sd	s11,208(sp)
    80006488:	edf2                	sd	t3,216(sp)
    8000648a:	f1f6                	sd	t4,224(sp)
    8000648c:	f5fa                	sd	t5,232(sp)
    8000648e:	f9fe                	sd	t6,240(sp)
    80006490:	afffc0ef          	jal	ra,80002f8e <kerneltrap>
    80006494:	6082                	ld	ra,0(sp)
    80006496:	6122                	ld	sp,8(sp)
    80006498:	61c2                	ld	gp,16(sp)
    8000649a:	7282                	ld	t0,32(sp)
    8000649c:	7322                	ld	t1,40(sp)
    8000649e:	73c2                	ld	t2,48(sp)
    800064a0:	7462                	ld	s0,56(sp)
    800064a2:	6486                	ld	s1,64(sp)
    800064a4:	6526                	ld	a0,72(sp)
    800064a6:	65c6                	ld	a1,80(sp)
    800064a8:	6666                	ld	a2,88(sp)
    800064aa:	7686                	ld	a3,96(sp)
    800064ac:	7726                	ld	a4,104(sp)
    800064ae:	77c6                	ld	a5,112(sp)
    800064b0:	7866                	ld	a6,120(sp)
    800064b2:	688a                	ld	a7,128(sp)
    800064b4:	692a                	ld	s2,136(sp)
    800064b6:	69ca                	ld	s3,144(sp)
    800064b8:	6a6a                	ld	s4,152(sp)
    800064ba:	7a8a                	ld	s5,160(sp)
    800064bc:	7b2a                	ld	s6,168(sp)
    800064be:	7bca                	ld	s7,176(sp)
    800064c0:	7c6a                	ld	s8,184(sp)
    800064c2:	6c8e                	ld	s9,192(sp)
    800064c4:	6d2e                	ld	s10,200(sp)
    800064c6:	6dce                	ld	s11,208(sp)
    800064c8:	6e6e                	ld	t3,216(sp)
    800064ca:	7e8e                	ld	t4,224(sp)
    800064cc:	7f2e                	ld	t5,232(sp)
    800064ce:	7fce                	ld	t6,240(sp)
    800064d0:	6111                	addi	sp,sp,256
    800064d2:	10200073          	sret
    800064d6:	00000013          	nop
    800064da:	00000013          	nop
    800064de:	0001                	nop

00000000800064e0 <timervec>:
    800064e0:	34051573          	csrrw	a0,mscratch,a0
    800064e4:	e10c                	sd	a1,0(a0)
    800064e6:	e510                	sd	a2,8(a0)
    800064e8:	e914                	sd	a3,16(a0)
    800064ea:	6d0c                	ld	a1,24(a0)
    800064ec:	7110                	ld	a2,32(a0)
    800064ee:	6194                	ld	a3,0(a1)
    800064f0:	96b2                	add	a3,a3,a2
    800064f2:	e194                	sd	a3,0(a1)
    800064f4:	4589                	li	a1,2
    800064f6:	14459073          	csrw	sip,a1
    800064fa:	6914                	ld	a3,16(a0)
    800064fc:	6510                	ld	a2,8(a0)
    800064fe:	610c                	ld	a1,0(a0)
    80006500:	34051573          	csrrw	a0,mscratch,a0
    80006504:	30200073          	mret
	...

000000008000650a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000650a:	1141                	addi	sp,sp,-16
    8000650c:	e422                	sd	s0,8(sp)
    8000650e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006510:	0c0007b7          	lui	a5,0xc000
    80006514:	4705                	li	a4,1
    80006516:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006518:	c3d8                	sw	a4,4(a5)
}
    8000651a:	6422                	ld	s0,8(sp)
    8000651c:	0141                	addi	sp,sp,16
    8000651e:	8082                	ret

0000000080006520 <plicinithart>:

void
plicinithart(void)
{
    80006520:	1141                	addi	sp,sp,-16
    80006522:	e406                	sd	ra,8(sp)
    80006524:	e022                	sd	s0,0(sp)
    80006526:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006528:	ffffb097          	auipc	ra,0xffffb
    8000652c:	764080e7          	jalr	1892(ra) # 80001c8c <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006530:	0085171b          	slliw	a4,a0,0x8
    80006534:	0c0027b7          	lui	a5,0xc002
    80006538:	97ba                	add	a5,a5,a4
    8000653a:	40200713          	li	a4,1026
    8000653e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006542:	00d5151b          	slliw	a0,a0,0xd
    80006546:	0c2017b7          	lui	a5,0xc201
    8000654a:	953e                	add	a0,a0,a5
    8000654c:	00052023          	sw	zero,0(a0)
}
    80006550:	60a2                	ld	ra,8(sp)
    80006552:	6402                	ld	s0,0(sp)
    80006554:	0141                	addi	sp,sp,16
    80006556:	8082                	ret

0000000080006558 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006558:	1141                	addi	sp,sp,-16
    8000655a:	e406                	sd	ra,8(sp)
    8000655c:	e022                	sd	s0,0(sp)
    8000655e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006560:	ffffb097          	auipc	ra,0xffffb
    80006564:	72c080e7          	jalr	1836(ra) # 80001c8c <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006568:	00d5179b          	slliw	a5,a0,0xd
    8000656c:	0c201537          	lui	a0,0xc201
    80006570:	953e                	add	a0,a0,a5
  return irq;
}
    80006572:	4148                	lw	a0,4(a0)
    80006574:	60a2                	ld	ra,8(sp)
    80006576:	6402                	ld	s0,0(sp)
    80006578:	0141                	addi	sp,sp,16
    8000657a:	8082                	ret

000000008000657c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000657c:	1101                	addi	sp,sp,-32
    8000657e:	ec06                	sd	ra,24(sp)
    80006580:	e822                	sd	s0,16(sp)
    80006582:	e426                	sd	s1,8(sp)
    80006584:	1000                	addi	s0,sp,32
    80006586:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006588:	ffffb097          	auipc	ra,0xffffb
    8000658c:	704080e7          	jalr	1796(ra) # 80001c8c <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006590:	00d5151b          	slliw	a0,a0,0xd
    80006594:	0c2017b7          	lui	a5,0xc201
    80006598:	97aa                	add	a5,a5,a0
    8000659a:	c3c4                	sw	s1,4(a5)
}
    8000659c:	60e2                	ld	ra,24(sp)
    8000659e:	6442                	ld	s0,16(sp)
    800065a0:	64a2                	ld	s1,8(sp)
    800065a2:	6105                	addi	sp,sp,32
    800065a4:	8082                	ret

00000000800065a6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800065a6:	1141                	addi	sp,sp,-16
    800065a8:	e406                	sd	ra,8(sp)
    800065aa:	e022                	sd	s0,0(sp)
    800065ac:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800065ae:	479d                	li	a5,7
    800065b0:	04a7cc63          	blt	a5,a0,80006608 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800065b4:	0023d797          	auipc	a5,0x23d
    800065b8:	3a478793          	addi	a5,a5,932 # 80243958 <disk>
    800065bc:	97aa                	add	a5,a5,a0
    800065be:	0187c783          	lbu	a5,24(a5)
    800065c2:	ebb9                	bnez	a5,80006618 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800065c4:	00451613          	slli	a2,a0,0x4
    800065c8:	0023d797          	auipc	a5,0x23d
    800065cc:	39078793          	addi	a5,a5,912 # 80243958 <disk>
    800065d0:	6394                	ld	a3,0(a5)
    800065d2:	96b2                	add	a3,a3,a2
    800065d4:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800065d8:	6398                	ld	a4,0(a5)
    800065da:	9732                	add	a4,a4,a2
    800065dc:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800065e0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800065e4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800065e8:	953e                	add	a0,a0,a5
    800065ea:	4785                	li	a5,1
    800065ec:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    800065f0:	0023d517          	auipc	a0,0x23d
    800065f4:	38050513          	addi	a0,a0,896 # 80243970 <disk+0x18>
    800065f8:	ffffc097          	auipc	ra,0xffffc
    800065fc:	12e080e7          	jalr	302(ra) # 80002726 <wakeup>
}
    80006600:	60a2                	ld	ra,8(sp)
    80006602:	6402                	ld	s0,0(sp)
    80006604:	0141                	addi	sp,sp,16
    80006606:	8082                	ret
    panic("free_desc 1");
    80006608:	00002517          	auipc	a0,0x2
    8000660c:	2b050513          	addi	a0,a0,688 # 800088b8 <syscalls+0x310>
    80006610:	ffffa097          	auipc	ra,0xffffa
    80006614:	f34080e7          	jalr	-204(ra) # 80000544 <panic>
    panic("free_desc 2");
    80006618:	00002517          	auipc	a0,0x2
    8000661c:	2b050513          	addi	a0,a0,688 # 800088c8 <syscalls+0x320>
    80006620:	ffffa097          	auipc	ra,0xffffa
    80006624:	f24080e7          	jalr	-220(ra) # 80000544 <panic>

0000000080006628 <virtio_disk_init>:
{
    80006628:	1101                	addi	sp,sp,-32
    8000662a:	ec06                	sd	ra,24(sp)
    8000662c:	e822                	sd	s0,16(sp)
    8000662e:	e426                	sd	s1,8(sp)
    80006630:	e04a                	sd	s2,0(sp)
    80006632:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006634:	00002597          	auipc	a1,0x2
    80006638:	2a458593          	addi	a1,a1,676 # 800088d8 <syscalls+0x330>
    8000663c:	0023d517          	auipc	a0,0x23d
    80006640:	44450513          	addi	a0,a0,1092 # 80243a80 <disk+0x128>
    80006644:	ffffa097          	auipc	ra,0xffffa
    80006648:	6d4080e7          	jalr	1748(ra) # 80000d18 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000664c:	100017b7          	lui	a5,0x10001
    80006650:	4398                	lw	a4,0(a5)
    80006652:	2701                	sext.w	a4,a4
    80006654:	747277b7          	lui	a5,0x74727
    80006658:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000665c:	14f71e63          	bne	a4,a5,800067b8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006660:	100017b7          	lui	a5,0x10001
    80006664:	43dc                	lw	a5,4(a5)
    80006666:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006668:	4709                	li	a4,2
    8000666a:	14e79763          	bne	a5,a4,800067b8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000666e:	100017b7          	lui	a5,0x10001
    80006672:	479c                	lw	a5,8(a5)
    80006674:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006676:	14e79163          	bne	a5,a4,800067b8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000667a:	100017b7          	lui	a5,0x10001
    8000667e:	47d8                	lw	a4,12(a5)
    80006680:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006682:	554d47b7          	lui	a5,0x554d4
    80006686:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000668a:	12f71763          	bne	a4,a5,800067b8 <virtio_disk_init+0x190>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000668e:	100017b7          	lui	a5,0x10001
    80006692:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006696:	4705                	li	a4,1
    80006698:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000669a:	470d                	li	a4,3
    8000669c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000669e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800066a0:	c7ffe737          	lui	a4,0xc7ffe
    800066a4:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47dbacc7>
    800066a8:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800066aa:	2701                	sext.w	a4,a4
    800066ac:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800066ae:	472d                	li	a4,11
    800066b0:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800066b2:	0707a903          	lw	s2,112(a5)
    800066b6:	2901                	sext.w	s2,s2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800066b8:	00897793          	andi	a5,s2,8
    800066bc:	10078663          	beqz	a5,800067c8 <virtio_disk_init+0x1a0>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800066c0:	100017b7          	lui	a5,0x10001
    800066c4:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800066c8:	43fc                	lw	a5,68(a5)
    800066ca:	2781                	sext.w	a5,a5
    800066cc:	10079663          	bnez	a5,800067d8 <virtio_disk_init+0x1b0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800066d0:	100017b7          	lui	a5,0x10001
    800066d4:	5bdc                	lw	a5,52(a5)
    800066d6:	2781                	sext.w	a5,a5
  if(max == 0)
    800066d8:	10078863          	beqz	a5,800067e8 <virtio_disk_init+0x1c0>
  if(max < NUM)
    800066dc:	471d                	li	a4,7
    800066de:	10f77d63          	bgeu	a4,a5,800067f8 <virtio_disk_init+0x1d0>
  disk.desc = kalloc();
    800066e2:	ffffa097          	auipc	ra,0xffffa
    800066e6:	592080e7          	jalr	1426(ra) # 80000c74 <kalloc>
    800066ea:	0023d497          	auipc	s1,0x23d
    800066ee:	26e48493          	addi	s1,s1,622 # 80243958 <disk>
    800066f2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800066f4:	ffffa097          	auipc	ra,0xffffa
    800066f8:	580080e7          	jalr	1408(ra) # 80000c74 <kalloc>
    800066fc:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800066fe:	ffffa097          	auipc	ra,0xffffa
    80006702:	576080e7          	jalr	1398(ra) # 80000c74 <kalloc>
    80006706:	87aa                	mv	a5,a0
    80006708:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    8000670a:	6088                	ld	a0,0(s1)
    8000670c:	cd75                	beqz	a0,80006808 <virtio_disk_init+0x1e0>
    8000670e:	0023d717          	auipc	a4,0x23d
    80006712:	25273703          	ld	a4,594(a4) # 80243960 <disk+0x8>
    80006716:	cb6d                	beqz	a4,80006808 <virtio_disk_init+0x1e0>
    80006718:	cbe5                	beqz	a5,80006808 <virtio_disk_init+0x1e0>
  memset(disk.desc, 0, PGSIZE);
    8000671a:	6605                	lui	a2,0x1
    8000671c:	4581                	li	a1,0
    8000671e:	ffffa097          	auipc	ra,0xffffa
    80006722:	786080e7          	jalr	1926(ra) # 80000ea4 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006726:	0023d497          	auipc	s1,0x23d
    8000672a:	23248493          	addi	s1,s1,562 # 80243958 <disk>
    8000672e:	6605                	lui	a2,0x1
    80006730:	4581                	li	a1,0
    80006732:	6488                	ld	a0,8(s1)
    80006734:	ffffa097          	auipc	ra,0xffffa
    80006738:	770080e7          	jalr	1904(ra) # 80000ea4 <memset>
  memset(disk.used, 0, PGSIZE);
    8000673c:	6605                	lui	a2,0x1
    8000673e:	4581                	li	a1,0
    80006740:	6888                	ld	a0,16(s1)
    80006742:	ffffa097          	auipc	ra,0xffffa
    80006746:	762080e7          	jalr	1890(ra) # 80000ea4 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000674a:	100017b7          	lui	a5,0x10001
    8000674e:	4721                	li	a4,8
    80006750:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006752:	4098                	lw	a4,0(s1)
    80006754:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006758:	40d8                	lw	a4,4(s1)
    8000675a:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000675e:	6498                	ld	a4,8(s1)
    80006760:	0007069b          	sext.w	a3,a4
    80006764:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006768:	9701                	srai	a4,a4,0x20
    8000676a:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000676e:	6898                	ld	a4,16(s1)
    80006770:	0007069b          	sext.w	a3,a4
    80006774:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006778:	9701                	srai	a4,a4,0x20
    8000677a:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000677e:	4685                	li	a3,1
    80006780:	c3f4                	sw	a3,68(a5)
    disk.free[i] = 1;
    80006782:	4705                	li	a4,1
    80006784:	00d48c23          	sb	a3,24(s1)
    80006788:	00e48ca3          	sb	a4,25(s1)
    8000678c:	00e48d23          	sb	a4,26(s1)
    80006790:	00e48da3          	sb	a4,27(s1)
    80006794:	00e48e23          	sb	a4,28(s1)
    80006798:	00e48ea3          	sb	a4,29(s1)
    8000679c:	00e48f23          	sb	a4,30(s1)
    800067a0:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800067a4:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800067a8:	0727a823          	sw	s2,112(a5)
}
    800067ac:	60e2                	ld	ra,24(sp)
    800067ae:	6442                	ld	s0,16(sp)
    800067b0:	64a2                	ld	s1,8(sp)
    800067b2:	6902                	ld	s2,0(sp)
    800067b4:	6105                	addi	sp,sp,32
    800067b6:	8082                	ret
    panic("could not find virtio disk");
    800067b8:	00002517          	auipc	a0,0x2
    800067bc:	13050513          	addi	a0,a0,304 # 800088e8 <syscalls+0x340>
    800067c0:	ffffa097          	auipc	ra,0xffffa
    800067c4:	d84080e7          	jalr	-636(ra) # 80000544 <panic>
    panic("virtio disk FEATURES_OK unset");
    800067c8:	00002517          	auipc	a0,0x2
    800067cc:	14050513          	addi	a0,a0,320 # 80008908 <syscalls+0x360>
    800067d0:	ffffa097          	auipc	ra,0xffffa
    800067d4:	d74080e7          	jalr	-652(ra) # 80000544 <panic>
    panic("virtio disk should not be ready");
    800067d8:	00002517          	auipc	a0,0x2
    800067dc:	15050513          	addi	a0,a0,336 # 80008928 <syscalls+0x380>
    800067e0:	ffffa097          	auipc	ra,0xffffa
    800067e4:	d64080e7          	jalr	-668(ra) # 80000544 <panic>
    panic("virtio disk has no queue 0");
    800067e8:	00002517          	auipc	a0,0x2
    800067ec:	16050513          	addi	a0,a0,352 # 80008948 <syscalls+0x3a0>
    800067f0:	ffffa097          	auipc	ra,0xffffa
    800067f4:	d54080e7          	jalr	-684(ra) # 80000544 <panic>
    panic("virtio disk max queue too short");
    800067f8:	00002517          	auipc	a0,0x2
    800067fc:	17050513          	addi	a0,a0,368 # 80008968 <syscalls+0x3c0>
    80006800:	ffffa097          	auipc	ra,0xffffa
    80006804:	d44080e7          	jalr	-700(ra) # 80000544 <panic>
    panic("virtio disk kalloc");
    80006808:	00002517          	auipc	a0,0x2
    8000680c:	18050513          	addi	a0,a0,384 # 80008988 <syscalls+0x3e0>
    80006810:	ffffa097          	auipc	ra,0xffffa
    80006814:	d34080e7          	jalr	-716(ra) # 80000544 <panic>

0000000080006818 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006818:	7159                	addi	sp,sp,-112
    8000681a:	f486                	sd	ra,104(sp)
    8000681c:	f0a2                	sd	s0,96(sp)
    8000681e:	eca6                	sd	s1,88(sp)
    80006820:	e8ca                	sd	s2,80(sp)
    80006822:	e4ce                	sd	s3,72(sp)
    80006824:	e0d2                	sd	s4,64(sp)
    80006826:	fc56                	sd	s5,56(sp)
    80006828:	f85a                	sd	s6,48(sp)
    8000682a:	f45e                	sd	s7,40(sp)
    8000682c:	f062                	sd	s8,32(sp)
    8000682e:	ec66                	sd	s9,24(sp)
    80006830:	e86a                	sd	s10,16(sp)
    80006832:	1880                	addi	s0,sp,112
    80006834:	892a                	mv	s2,a0
    80006836:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006838:	00c52c83          	lw	s9,12(a0)
    8000683c:	001c9c9b          	slliw	s9,s9,0x1
    80006840:	1c82                	slli	s9,s9,0x20
    80006842:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006846:	0023d517          	auipc	a0,0x23d
    8000684a:	23a50513          	addi	a0,a0,570 # 80243a80 <disk+0x128>
    8000684e:	ffffa097          	auipc	ra,0xffffa
    80006852:	55a080e7          	jalr	1370(ra) # 80000da8 <acquire>
  for(int i = 0; i < 3; i++){
    80006856:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006858:	4ba1                	li	s7,8
      disk.free[i] = 0;
    8000685a:	0023db17          	auipc	s6,0x23d
    8000685e:	0feb0b13          	addi	s6,s6,254 # 80243958 <disk>
  for(int i = 0; i < 3; i++){
    80006862:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80006864:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006866:	0023dc17          	auipc	s8,0x23d
    8000686a:	21ac0c13          	addi	s8,s8,538 # 80243a80 <disk+0x128>
    8000686e:	a8b5                	j	800068ea <virtio_disk_rw+0xd2>
      disk.free[i] = 0;
    80006870:	00fb06b3          	add	a3,s6,a5
    80006874:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006878:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    8000687a:	0207c563          	bltz	a5,800068a4 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000687e:	2485                	addiw	s1,s1,1
    80006880:	0711                	addi	a4,a4,4
    80006882:	1f548a63          	beq	s1,s5,80006a76 <virtio_disk_rw+0x25e>
    idx[i] = alloc_desc();
    80006886:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80006888:	0023d697          	auipc	a3,0x23d
    8000688c:	0d068693          	addi	a3,a3,208 # 80243958 <disk>
    80006890:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80006892:	0186c583          	lbu	a1,24(a3)
    80006896:	fde9                	bnez	a1,80006870 <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006898:	2785                	addiw	a5,a5,1
    8000689a:	0685                	addi	a3,a3,1
    8000689c:	ff779be3          	bne	a5,s7,80006892 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800068a0:	57fd                	li	a5,-1
    800068a2:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    800068a4:	02905a63          	blez	s1,800068d8 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800068a8:	f9042503          	lw	a0,-112(s0)
    800068ac:	00000097          	auipc	ra,0x0
    800068b0:	cfa080e7          	jalr	-774(ra) # 800065a6 <free_desc>
      for(int j = 0; j < i; j++)
    800068b4:	4785                	li	a5,1
    800068b6:	0297d163          	bge	a5,s1,800068d8 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800068ba:	f9442503          	lw	a0,-108(s0)
    800068be:	00000097          	auipc	ra,0x0
    800068c2:	ce8080e7          	jalr	-792(ra) # 800065a6 <free_desc>
      for(int j = 0; j < i; j++)
    800068c6:	4789                	li	a5,2
    800068c8:	0097d863          	bge	a5,s1,800068d8 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800068cc:	f9842503          	lw	a0,-104(s0)
    800068d0:	00000097          	auipc	ra,0x0
    800068d4:	cd6080e7          	jalr	-810(ra) # 800065a6 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800068d8:	85e2                	mv	a1,s8
    800068da:	0023d517          	auipc	a0,0x23d
    800068de:	09650513          	addi	a0,a0,150 # 80243970 <disk+0x18>
    800068e2:	ffffc097          	auipc	ra,0xffffc
    800068e6:	b46080e7          	jalr	-1210(ra) # 80002428 <sleep>
  for(int i = 0; i < 3; i++){
    800068ea:	f9040713          	addi	a4,s0,-112
    800068ee:	84ce                	mv	s1,s3
    800068f0:	bf59                	j	80006886 <virtio_disk_rw+0x6e>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    800068f2:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    800068f6:	00479693          	slli	a3,a5,0x4
    800068fa:	0023d797          	auipc	a5,0x23d
    800068fe:	05e78793          	addi	a5,a5,94 # 80243958 <disk>
    80006902:	97b6                	add	a5,a5,a3
    80006904:	4685                	li	a3,1
    80006906:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006908:	0023d597          	auipc	a1,0x23d
    8000690c:	05058593          	addi	a1,a1,80 # 80243958 <disk>
    80006910:	00a60793          	addi	a5,a2,10
    80006914:	0792                	slli	a5,a5,0x4
    80006916:	97ae                	add	a5,a5,a1
    80006918:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    8000691c:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006920:	f6070693          	addi	a3,a4,-160
    80006924:	619c                	ld	a5,0(a1)
    80006926:	97b6                	add	a5,a5,a3
    80006928:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000692a:	6188                	ld	a0,0(a1)
    8000692c:	96aa                	add	a3,a3,a0
    8000692e:	47c1                	li	a5,16
    80006930:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006932:	4785                	li	a5,1
    80006934:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006938:	f9442783          	lw	a5,-108(s0)
    8000693c:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006940:	0792                	slli	a5,a5,0x4
    80006942:	953e                	add	a0,a0,a5
    80006944:	05890693          	addi	a3,s2,88
    80006948:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000694a:	6188                	ld	a0,0(a1)
    8000694c:	97aa                	add	a5,a5,a0
    8000694e:	40000693          	li	a3,1024
    80006952:	c794                	sw	a3,8(a5)
  if(write)
    80006954:	100d0d63          	beqz	s10,80006a6e <virtio_disk_rw+0x256>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006958:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000695c:	00c7d683          	lhu	a3,12(a5)
    80006960:	0016e693          	ori	a3,a3,1
    80006964:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    80006968:	f9842583          	lw	a1,-104(s0)
    8000696c:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006970:	0023d697          	auipc	a3,0x23d
    80006974:	fe868693          	addi	a3,a3,-24 # 80243958 <disk>
    80006978:	00260793          	addi	a5,a2,2
    8000697c:	0792                	slli	a5,a5,0x4
    8000697e:	97b6                	add	a5,a5,a3
    80006980:	587d                	li	a6,-1
    80006982:	01078823          	sb	a6,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006986:	0592                	slli	a1,a1,0x4
    80006988:	952e                	add	a0,a0,a1
    8000698a:	f9070713          	addi	a4,a4,-112
    8000698e:	9736                	add	a4,a4,a3
    80006990:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    80006992:	6298                	ld	a4,0(a3)
    80006994:	972e                	add	a4,a4,a1
    80006996:	4585                	li	a1,1
    80006998:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000699a:	4509                	li	a0,2
    8000699c:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    800069a0:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800069a4:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    800069a8:	0127b423          	sd	s2,8(a5)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800069ac:	6698                	ld	a4,8(a3)
    800069ae:	00275783          	lhu	a5,2(a4)
    800069b2:	8b9d                	andi	a5,a5,7
    800069b4:	0786                	slli	a5,a5,0x1
    800069b6:	97ba                	add	a5,a5,a4
    800069b8:	00c79223          	sh	a2,4(a5)

  __sync_synchronize();
    800069bc:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800069c0:	6698                	ld	a4,8(a3)
    800069c2:	00275783          	lhu	a5,2(a4)
    800069c6:	2785                	addiw	a5,a5,1
    800069c8:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800069cc:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800069d0:	100017b7          	lui	a5,0x10001
    800069d4:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800069d8:	00492703          	lw	a4,4(s2)
    800069dc:	4785                	li	a5,1
    800069de:	02f71163          	bne	a4,a5,80006a00 <virtio_disk_rw+0x1e8>
    sleep(b, &disk.vdisk_lock);
    800069e2:	0023d997          	auipc	s3,0x23d
    800069e6:	09e98993          	addi	s3,s3,158 # 80243a80 <disk+0x128>
  while(b->disk == 1) {
    800069ea:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800069ec:	85ce                	mv	a1,s3
    800069ee:	854a                	mv	a0,s2
    800069f0:	ffffc097          	auipc	ra,0xffffc
    800069f4:	a38080e7          	jalr	-1480(ra) # 80002428 <sleep>
  while(b->disk == 1) {
    800069f8:	00492783          	lw	a5,4(s2)
    800069fc:	fe9788e3          	beq	a5,s1,800069ec <virtio_disk_rw+0x1d4>
  }

  disk.info[idx[0]].b = 0;
    80006a00:	f9042903          	lw	s2,-112(s0)
    80006a04:	00290793          	addi	a5,s2,2
    80006a08:	00479713          	slli	a4,a5,0x4
    80006a0c:	0023d797          	auipc	a5,0x23d
    80006a10:	f4c78793          	addi	a5,a5,-180 # 80243958 <disk>
    80006a14:	97ba                	add	a5,a5,a4
    80006a16:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006a1a:	0023d997          	auipc	s3,0x23d
    80006a1e:	f3e98993          	addi	s3,s3,-194 # 80243958 <disk>
    80006a22:	00491713          	slli	a4,s2,0x4
    80006a26:	0009b783          	ld	a5,0(s3)
    80006a2a:	97ba                	add	a5,a5,a4
    80006a2c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006a30:	854a                	mv	a0,s2
    80006a32:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006a36:	00000097          	auipc	ra,0x0
    80006a3a:	b70080e7          	jalr	-1168(ra) # 800065a6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006a3e:	8885                	andi	s1,s1,1
    80006a40:	f0ed                	bnez	s1,80006a22 <virtio_disk_rw+0x20a>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006a42:	0023d517          	auipc	a0,0x23d
    80006a46:	03e50513          	addi	a0,a0,62 # 80243a80 <disk+0x128>
    80006a4a:	ffffa097          	auipc	ra,0xffffa
    80006a4e:	412080e7          	jalr	1042(ra) # 80000e5c <release>
}
    80006a52:	70a6                	ld	ra,104(sp)
    80006a54:	7406                	ld	s0,96(sp)
    80006a56:	64e6                	ld	s1,88(sp)
    80006a58:	6946                	ld	s2,80(sp)
    80006a5a:	69a6                	ld	s3,72(sp)
    80006a5c:	6a06                	ld	s4,64(sp)
    80006a5e:	7ae2                	ld	s5,56(sp)
    80006a60:	7b42                	ld	s6,48(sp)
    80006a62:	7ba2                	ld	s7,40(sp)
    80006a64:	7c02                	ld	s8,32(sp)
    80006a66:	6ce2                	ld	s9,24(sp)
    80006a68:	6d42                	ld	s10,16(sp)
    80006a6a:	6165                	addi	sp,sp,112
    80006a6c:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006a6e:	4689                	li	a3,2
    80006a70:	00d79623          	sh	a3,12(a5)
    80006a74:	b5e5                	j	8000695c <virtio_disk_rw+0x144>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006a76:	f9042603          	lw	a2,-112(s0)
    80006a7a:	00a60713          	addi	a4,a2,10
    80006a7e:	0712                	slli	a4,a4,0x4
    80006a80:	0023d517          	auipc	a0,0x23d
    80006a84:	ee050513          	addi	a0,a0,-288 # 80243960 <disk+0x8>
    80006a88:	953a                	add	a0,a0,a4
  if(write)
    80006a8a:	e60d14e3          	bnez	s10,800068f2 <virtio_disk_rw+0xda>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    80006a8e:	00a60793          	addi	a5,a2,10
    80006a92:	00479693          	slli	a3,a5,0x4
    80006a96:	0023d797          	auipc	a5,0x23d
    80006a9a:	ec278793          	addi	a5,a5,-318 # 80243958 <disk>
    80006a9e:	97b6                	add	a5,a5,a3
    80006aa0:	0007a423          	sw	zero,8(a5)
    80006aa4:	b595                	j	80006908 <virtio_disk_rw+0xf0>

0000000080006aa6 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006aa6:	1101                	addi	sp,sp,-32
    80006aa8:	ec06                	sd	ra,24(sp)
    80006aaa:	e822                	sd	s0,16(sp)
    80006aac:	e426                	sd	s1,8(sp)
    80006aae:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006ab0:	0023d497          	auipc	s1,0x23d
    80006ab4:	ea848493          	addi	s1,s1,-344 # 80243958 <disk>
    80006ab8:	0023d517          	auipc	a0,0x23d
    80006abc:	fc850513          	addi	a0,a0,-56 # 80243a80 <disk+0x128>
    80006ac0:	ffffa097          	auipc	ra,0xffffa
    80006ac4:	2e8080e7          	jalr	744(ra) # 80000da8 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006ac8:	10001737          	lui	a4,0x10001
    80006acc:	533c                	lw	a5,96(a4)
    80006ace:	8b8d                	andi	a5,a5,3
    80006ad0:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006ad2:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006ad6:	689c                	ld	a5,16(s1)
    80006ad8:	0204d703          	lhu	a4,32(s1)
    80006adc:	0027d783          	lhu	a5,2(a5)
    80006ae0:	04f70863          	beq	a4,a5,80006b30 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006ae4:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006ae8:	6898                	ld	a4,16(s1)
    80006aea:	0204d783          	lhu	a5,32(s1)
    80006aee:	8b9d                	andi	a5,a5,7
    80006af0:	078e                	slli	a5,a5,0x3
    80006af2:	97ba                	add	a5,a5,a4
    80006af4:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006af6:	00278713          	addi	a4,a5,2
    80006afa:	0712                	slli	a4,a4,0x4
    80006afc:	9726                	add	a4,a4,s1
    80006afe:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006b02:	e721                	bnez	a4,80006b4a <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006b04:	0789                	addi	a5,a5,2
    80006b06:	0792                	slli	a5,a5,0x4
    80006b08:	97a6                	add	a5,a5,s1
    80006b0a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006b0c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006b10:	ffffc097          	auipc	ra,0xffffc
    80006b14:	c16080e7          	jalr	-1002(ra) # 80002726 <wakeup>

    disk.used_idx += 1;
    80006b18:	0204d783          	lhu	a5,32(s1)
    80006b1c:	2785                	addiw	a5,a5,1
    80006b1e:	17c2                	slli	a5,a5,0x30
    80006b20:	93c1                	srli	a5,a5,0x30
    80006b22:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006b26:	6898                	ld	a4,16(s1)
    80006b28:	00275703          	lhu	a4,2(a4)
    80006b2c:	faf71ce3          	bne	a4,a5,80006ae4 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006b30:	0023d517          	auipc	a0,0x23d
    80006b34:	f5050513          	addi	a0,a0,-176 # 80243a80 <disk+0x128>
    80006b38:	ffffa097          	auipc	ra,0xffffa
    80006b3c:	324080e7          	jalr	804(ra) # 80000e5c <release>
}
    80006b40:	60e2                	ld	ra,24(sp)
    80006b42:	6442                	ld	s0,16(sp)
    80006b44:	64a2                	ld	s1,8(sp)
    80006b46:	6105                	addi	sp,sp,32
    80006b48:	8082                	ret
      panic("virtio_disk_intr status");
    80006b4a:	00002517          	auipc	a0,0x2
    80006b4e:	e5650513          	addi	a0,a0,-426 # 800089a0 <syscalls+0x3f8>
    80006b52:	ffffa097          	auipc	ra,0xffffa
    80006b56:	9f2080e7          	jalr	-1550(ra) # 80000544 <panic>
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
