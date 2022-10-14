
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	be013103          	ld	sp,-1056(sp) # 80008be0 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000056:	bee70713          	addi	a4,a4,-1042 # 80008c40 <timer_scratch>
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
    80000068:	7ec78793          	addi	a5,a5,2028 # 80006850 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fdba537>
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
    80000130:	b70080e7          	jalr	-1168(ra) # 80002c9c <either_copyin>
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
    80000190:	bf450513          	addi	a0,a0,-1036 # 80010d80 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	c14080e7          	jalr	-1004(ra) # 80000da8 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019c:	00011497          	auipc	s1,0x11
    800001a0:	be448493          	addi	s1,s1,-1052 # 80010d80 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a4:	89a6                	mv	s3,s1
    800001a6:	00011917          	auipc	s2,0x11
    800001aa:	c7290913          	addi	s2,s2,-910 # 80010e18 <cons+0x98>
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
    800001c8:	ba4080e7          	jalr	-1116(ra) # 80001d68 <myproc>
    800001cc:	00003097          	auipc	ra,0x3
    800001d0:	a44080e7          	jalr	-1468(ra) # 80002c10 <killed>
    800001d4:	e535                	bnez	a0,80000240 <consoleread+0xdc>
      sleep(&cons.r, &cons.lock);
    800001d6:	85ce                	mv	a1,s3
    800001d8:	854a                	mv	a0,s2
    800001da:	00002097          	auipc	ra,0x2
    800001de:	48a080e7          	jalr	1162(ra) # 80002664 <sleep>
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
    80000216:	00003097          	auipc	ra,0x3
    8000021a:	a30080e7          	jalr	-1488(ra) # 80002c46 <either_copyout>
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
    8000022e:	b5650513          	addi	a0,a0,-1194 # 80010d80 <cons>
    80000232:	00001097          	auipc	ra,0x1
    80000236:	c2a080e7          	jalr	-982(ra) # 80000e5c <release>

  return target - n;
    8000023a:	414b853b          	subw	a0,s7,s4
    8000023e:	a811                	j	80000252 <consoleread+0xee>
        release(&cons.lock);
    80000240:	00011517          	auipc	a0,0x11
    80000244:	b4050513          	addi	a0,a0,-1216 # 80010d80 <cons>
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
    8000027c:	baf72023          	sw	a5,-1120(a4) # 80010e18 <cons+0x98>
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
    800002d6:	aae50513          	addi	a0,a0,-1362 # 80010d80 <cons>
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
    800002f8:	00003097          	auipc	ra,0x3
    800002fc:	9fa080e7          	jalr	-1542(ra) # 80002cf2 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000300:	00011517          	auipc	a0,0x11
    80000304:	a8050513          	addi	a0,a0,-1408 # 80010d80 <cons>
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
    80000328:	a5c70713          	addi	a4,a4,-1444 # 80010d80 <cons>
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
    80000352:	a3278793          	addi	a5,a5,-1486 # 80010d80 <cons>
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
    80000380:	a9c7a783          	lw	a5,-1380(a5) # 80010e18 <cons+0x98>
    80000384:	9f1d                	subw	a4,a4,a5
    80000386:	08000793          	li	a5,128
    8000038a:	f6f71be3          	bne	a4,a5,80000300 <consoleintr+0x3c>
    8000038e:	a07d                	j	8000043c <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000390:	00011717          	auipc	a4,0x11
    80000394:	9f070713          	addi	a4,a4,-1552 # 80010d80 <cons>
    80000398:	0a072783          	lw	a5,160(a4)
    8000039c:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a0:	00011497          	auipc	s1,0x11
    800003a4:	9e048493          	addi	s1,s1,-1568 # 80010d80 <cons>
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
    800003e0:	9a470713          	addi	a4,a4,-1628 # 80010d80 <cons>
    800003e4:	0a072783          	lw	a5,160(a4)
    800003e8:	09c72703          	lw	a4,156(a4)
    800003ec:	f0f70ae3          	beq	a4,a5,80000300 <consoleintr+0x3c>
      cons.e--;
    800003f0:	37fd                	addiw	a5,a5,-1
    800003f2:	00011717          	auipc	a4,0x11
    800003f6:	a2f72723          	sw	a5,-1490(a4) # 80010e20 <cons+0xa0>
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
    8000041c:	96878793          	addi	a5,a5,-1688 # 80010d80 <cons>
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
    80000440:	9ec7a023          	sw	a2,-1568(a5) # 80010e1c <cons+0x9c>
        wakeup(&cons.r);
    80000444:	00011517          	auipc	a0,0x11
    80000448:	9d450513          	addi	a0,a0,-1580 # 80010e18 <cons+0x98>
    8000044c:	00002097          	auipc	ra,0x2
    80000450:	516080e7          	jalr	1302(ra) # 80002962 <wakeup>
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
    8000046a:	91a50513          	addi	a0,a0,-1766 # 80010d80 <cons>
    8000046e:	00001097          	auipc	ra,0x1
    80000472:	8aa080e7          	jalr	-1878(ra) # 80000d18 <initlock>

  uartinit();
    80000476:	00000097          	auipc	ra,0x0
    8000047a:	330080e7          	jalr	816(ra) # 800007a6 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000047e:	00243797          	auipc	a5,0x243
    80000482:	cb278793          	addi	a5,a5,-846 # 80243130 <devsw>
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
    80000554:	8e07a823          	sw	zero,-1808(a5) # 80010e40 <pr+0x18>
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
    80000588:	66f72e23          	sw	a5,1660(a4) # 80008c00 <panicked>
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
    800005c4:	880dad83          	lw	s11,-1920(s11) # 80010e40 <pr+0x18>
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
    800005fe:	00011517          	auipc	a0,0x11
    80000602:	82a50513          	addi	a0,a0,-2006 # 80010e28 <pr>
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
    80000766:	6c650513          	addi	a0,a0,1734 # 80010e28 <pr>
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
    80000782:	6aa48493          	addi	s1,s1,1706 # 80010e28 <pr>
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
    800007e2:	66a50513          	addi	a0,a0,1642 # 80010e48 <uart_tx_lock>
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
    8000080e:	3f67a783          	lw	a5,1014(a5) # 80008c00 <panicked>
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
    8000084a:	3c273703          	ld	a4,962(a4) # 80008c08 <uart_tx_r>
    8000084e:	00008797          	auipc	a5,0x8
    80000852:	3c27b783          	ld	a5,962(a5) # 80008c10 <uart_tx_w>
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
    80000874:	5d8a0a13          	addi	s4,s4,1496 # 80010e48 <uart_tx_lock>
    uart_tx_r += 1;
    80000878:	00008497          	auipc	s1,0x8
    8000087c:	39048493          	addi	s1,s1,912 # 80008c08 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000880:	00008997          	auipc	s3,0x8
    80000884:	39098993          	addi	s3,s3,912 # 80008c10 <uart_tx_w>
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
    800008aa:	0bc080e7          	jalr	188(ra) # 80002962 <wakeup>
    
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
    800008e6:	56650513          	addi	a0,a0,1382 # 80010e48 <uart_tx_lock>
    800008ea:	00000097          	auipc	ra,0x0
    800008ee:	4be080e7          	jalr	1214(ra) # 80000da8 <acquire>
  if(panicked){
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	30e7a783          	lw	a5,782(a5) # 80008c00 <panicked>
    800008fa:	e7c9                	bnez	a5,80000984 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008fc:	00008797          	auipc	a5,0x8
    80000900:	3147b783          	ld	a5,788(a5) # 80008c10 <uart_tx_w>
    80000904:	00008717          	auipc	a4,0x8
    80000908:	30473703          	ld	a4,772(a4) # 80008c08 <uart_tx_r>
    8000090c:	02070713          	addi	a4,a4,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000910:	00010a17          	auipc	s4,0x10
    80000914:	538a0a13          	addi	s4,s4,1336 # 80010e48 <uart_tx_lock>
    80000918:	00008497          	auipc	s1,0x8
    8000091c:	2f048493          	addi	s1,s1,752 # 80008c08 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000920:	00008917          	auipc	s2,0x8
    80000924:	2f090913          	addi	s2,s2,752 # 80008c10 <uart_tx_w>
    80000928:	00f71f63          	bne	a4,a5,80000946 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000092c:	85d2                	mv	a1,s4
    8000092e:	8526                	mv	a0,s1
    80000930:	00002097          	auipc	ra,0x2
    80000934:	d34080e7          	jalr	-716(ra) # 80002664 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000938:	00093783          	ld	a5,0(s2)
    8000093c:	6098                	ld	a4,0(s1)
    8000093e:	02070713          	addi	a4,a4,32
    80000942:	fef705e3          	beq	a4,a5,8000092c <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000946:	00010497          	auipc	s1,0x10
    8000094a:	50248493          	addi	s1,s1,1282 # 80010e48 <uart_tx_lock>
    8000094e:	01f7f713          	andi	a4,a5,31
    80000952:	9726                	add	a4,a4,s1
    80000954:	01370c23          	sb	s3,24(a4)
  uart_tx_w += 1;
    80000958:	0785                	addi	a5,a5,1
    8000095a:	00008717          	auipc	a4,0x8
    8000095e:	2af73b23          	sd	a5,694(a4) # 80008c10 <uart_tx_w>
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
    800009d4:	47848493          	addi	s1,s1,1144 # 80010e48 <uart_tx_lock>
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
    80000a0e:	47650513          	addi	a0,a0,1142 # 80010e80 <kmem>
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
    80000a30:	47470713          	addi	a4,a4,1140 # 80010ea0 <refcnt>
    80000a34:	97ba                	add	a5,a5,a4
    80000a36:	4798                	lw	a4,8(a5)
    80000a38:	2705                	addiw	a4,a4,1
    80000a3a:	c798                	sw	a4,8(a5)
	release(&kmem.lock);
    80000a3c:	00010517          	auipc	a0,0x10
    80000a40:	44450513          	addi	a0,a0,1092 # 80010e80 <kmem>
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
    80000a76:	40e50513          	addi	a0,a0,1038 # 80010e80 <kmem>
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
    80000a98:	40c70713          	addi	a4,a4,1036 # 80010ea0 <refcnt>
    80000a9c:	97ba                	add	a5,a5,a4
    80000a9e:	4798                	lw	a4,8(a5)
    80000aa0:	377d                	addiw	a4,a4,-1
    80000aa2:	c798                	sw	a4,8(a5)
	release(&kmem.lock);
    80000aa4:	00010517          	auipc	a0,0x10
    80000aa8:	3dc50513          	addi	a0,a0,988 # 80010e80 <kmem>
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
    80000ae6:	7e678793          	addi	a5,a5,2022 # 802442c8 <end>
    80000aea:	08f56f63          	bltu	a0,a5,80000b88 <kfree+0xba>
    80000aee:	47c5                	li	a5,17
    80000af0:	07ee                	slli	a5,a5,0x1b
    80000af2:	08f57b63          	bgeu	a0,a5,80000b88 <kfree+0xba>
		panic("kfree");

	r = (struct run *)pa;

	acquire(&kmem.lock);
    80000af6:	00010517          	auipc	a0,0x10
    80000afa:	38a50513          	addi	a0,a0,906 # 80010e80 <kmem>
    80000afe:	00000097          	auipc	ra,0x0
    80000b02:	2aa080e7          	jalr	682(ra) # 80000da8 <acquire>
	int pn = (uint64)r / PGSIZE;
    80000b06:	00c4d793          	srli	a5,s1,0xc
    80000b0a:	2781                	sext.w	a5,a5
	if (refcnt.count[pn] < 1)
    80000b0c:	00478713          	addi	a4,a5,4
    80000b10:	00271693          	slli	a3,a4,0x2
    80000b14:	00010717          	auipc	a4,0x10
    80000b18:	38c70713          	addi	a4,a4,908 # 80010ea0 <refcnt>
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
    80000b32:	37268693          	addi	a3,a3,882 # 80010ea0 <refcnt>
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
    80000b42:	34290913          	addi	s2,s2,834 # 80010e80 <kmem>
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
    80000b9c:	2e850513          	addi	a0,a0,744 # 80010e80 <kmem>
    80000ba0:	00000097          	auipc	ra,0x0
    80000ba4:	2bc080e7          	jalr	700(ra) # 80000e5c <release>
		panic("kfree_decr");
    80000ba8:	00007517          	auipc	a0,0x7
    80000bac:	4e050513          	addi	a0,a0,1248 # 80008088 <digits+0x48>
    80000bb0:	00000097          	auipc	ra,0x0
    80000bb4:	994080e7          	jalr	-1644(ra) # 80000544 <panic>
		release(&kmem.lock);
    80000bb8:	00010517          	auipc	a0,0x10
    80000bbc:	2c850513          	addi	a0,a0,712 # 80010e80 <kmem>
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
    80000bf6:	2aeb0b13          	addi	s6,s6,686 # 80010ea0 <refcnt>
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
    80000c4c:	23850513          	addi	a0,a0,568 # 80010e80 <kmem>
    80000c50:	00000097          	auipc	ra,0x0
    80000c54:	0c8080e7          	jalr	200(ra) # 80000d18 <initlock>
	freerange(end, (void *)PHYSTOP);
    80000c58:	45c5                	li	a1,17
    80000c5a:	05ee                	slli	a1,a1,0x1b
    80000c5c:	00243517          	auipc	a0,0x243
    80000c60:	66c50513          	addi	a0,a0,1644 # 802442c8 <end>
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
    80000c82:	20248493          	addi	s1,s1,514 # 80010e80 <kmem>
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
    80000ca6:	1fe70713          	addi	a4,a4,510 # 80010ea0 <refcnt>
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
    80000cba:	1ea70713          	addi	a4,a4,490 # 80010ea0 <refcnt>
    80000cbe:	97ba                	add	a5,a5,a4
    80000cc0:	4705                	li	a4,1
    80000cc2:	c798                	sw	a4,8(a5)
		kmem.freelist = r->next;
    80000cc4:	609c                	ld	a5,0(s1)
    80000cc6:	00010517          	auipc	a0,0x10
    80000cca:	1ba50513          	addi	a0,a0,442 # 80010e80 <kmem>
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
    80000cf6:	18e50513          	addi	a0,a0,398 # 80010e80 <kmem>
    80000cfa:	00000097          	auipc	ra,0x0
    80000cfe:	162080e7          	jalr	354(ra) # 80000e5c <release>
			return 0;
    80000d02:	4481                	li	s1,0
    80000d04:	b7cd                	j	80000ce6 <kalloc+0x72>
	release(&kmem.lock);
    80000d06:	00010517          	auipc	a0,0x10
    80000d0a:	17a50513          	addi	a0,a0,378 # 80010e80 <kmem>
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
    80000d46:	00a080e7          	jalr	10(ra) # 80001d4c <mycpu>
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
    80000d78:	fd8080e7          	jalr	-40(ra) # 80001d4c <mycpu>
    80000d7c:	5d3c                	lw	a5,120(a0)
    80000d7e:	cf89                	beqz	a5,80000d98 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000d80:	00001097          	auipc	ra,0x1
    80000d84:	fcc080e7          	jalr	-52(ra) # 80001d4c <mycpu>
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
    80000d9c:	fb4080e7          	jalr	-76(ra) # 80001d4c <mycpu>
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
    80000ddc:	f74080e7          	jalr	-140(ra) # 80001d4c <mycpu>
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
    80000e08:	f48080e7          	jalr	-184(ra) # 80001d4c <mycpu>
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
    8000105e:	ce2080e7          	jalr	-798(ra) # 80001d3c <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80001062:	00008717          	auipc	a4,0x8
    80001066:	bb670713          	addi	a4,a4,-1098 # 80008c18 <started>
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
    8000107a:	cc6080e7          	jalr	-826(ra) # 80001d3c <cpuid>
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
    8000109c:	df2080e7          	jalr	-526(ra) # 80002e8a <trapinithart>
    // printf("trapinit done\n");
    plicinithart();   // ask PLIC for device interrupts
    800010a0:	00005097          	auipc	ra,0x5
    800010a4:	7f0080e7          	jalr	2032(ra) # 80006890 <plicinithart>
    // printf("plicinit done\n");
  }

  // printf("about to call sceduler\n");
  // srand(time(NULL));
  scheduler();        
    800010a8:	00001097          	auipc	ra,0x1
    800010ac:	1c8080e7          	jalr	456(ra) # 80002270 <scheduler>
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
    8000110c:	b7e080e7          	jalr	-1154(ra) # 80001c86 <procinit>
    trapinit();      // trap vectors
    80001110:	00002097          	auipc	ra,0x2
    80001114:	d52080e7          	jalr	-686(ra) # 80002e62 <trapinit>
    trapinithart();  // install kernel trap vector
    80001118:	00002097          	auipc	ra,0x2
    8000111c:	d72080e7          	jalr	-654(ra) # 80002e8a <trapinithart>
    plicinit();      // set up interrupt controller
    80001120:	00005097          	auipc	ra,0x5
    80001124:	75a080e7          	jalr	1882(ra) # 8000687a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001128:	00005097          	auipc	ra,0x5
    8000112c:	768080e7          	jalr	1896(ra) # 80006890 <plicinithart>
    binit();         // buffer cache
    80001130:	00003097          	auipc	ra,0x3
    80001134:	91a080e7          	jalr	-1766(ra) # 80003a4a <binit>
    iinit();         // inode table
    80001138:	00003097          	auipc	ra,0x3
    8000113c:	fbe080e7          	jalr	-66(ra) # 800040f6 <iinit>
    fileinit();      // file table
    80001140:	00004097          	auipc	ra,0x4
    80001144:	f5c080e7          	jalr	-164(ra) # 8000509c <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001148:	00006097          	auipc	ra,0x6
    8000114c:	850080e7          	jalr	-1968(ra) # 80006998 <virtio_disk_init>
    userinit();      // first user process
    80001150:	00001097          	auipc	ra,0x1
    80001154:	f54080e7          	jalr	-172(ra) # 800020a4 <userinit>
    __sync_synchronize();
    80001158:	0ff0000f          	fence
    started = 1;
    8000115c:	4785                	li	a5,1
    8000115e:	00008717          	auipc	a4,0x8
    80001162:	aaf72d23          	sw	a5,-1350(a4) # 80008c18 <started>
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
    80001176:	aae7b783          	ld	a5,-1362(a5) # 80008c20 <kernel_pagetable>
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
    8000140c:	7e8080e7          	jalr	2024(ra) # 80001bf0 <proc_mapstacks>
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
    80001432:	7ea7b923          	sd	a0,2034(a5) # 80008c20 <kernel_pagetable>
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
    800018a2:	604080e7          	jalr	1540(ra) # 80002ea2 <cowalloc>
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

0000000080001a38 <random_lbs>:
// Queue mlfq[5];
// #endif

/* This method is used to generate a random number, between 0 and max*/
int random_lbs(int max)
{
    80001a38:	1141                	addi	sp,sp,-16
    80001a3a:	e422                	sd	s0,8(sp)
    80001a3c:	0800                	addi	s0,sp,16

	if (max <= 0)
    80001a3e:	0aa05363          	blez	a0,80001ae4 <random_lbs+0xac>
	static int z2 = 12345; // 12345 for rest of zx
	static int z3 = 12345; // 12345 for rest of zx
	static int z4 = 12345; // 12345 for rest of zx

	int b;
	b = (((z1 << 6) ^ z1) >> 13);
    80001a42:	00007697          	auipc	a3,0x7
    80001a46:	f9e68693          	addi	a3,a3,-98 # 800089e0 <z1.2317>
    80001a4a:	429c                	lw	a5,0(a3)
    80001a4c:	0067961b          	slliw	a2,a5,0x6
    80001a50:	8e3d                	xor	a2,a2,a5
    80001a52:	40d6571b          	sraiw	a4,a2,0xd
	z1 = (((z1 & 4294967294) << 18) ^ b);
    80001a56:	01279613          	slli	a2,a5,0x12
    80001a5a:	fff807b7          	lui	a5,0xfff80
    80001a5e:	8e7d                	and	a2,a2,a5
    80001a60:	8e39                	xor	a2,a2,a4
    80001a62:	2601                	sext.w	a2,a2
    80001a64:	c290                	sw	a2,0(a3)
	b = (((z2 << 2) ^ z2) >> 27);
    80001a66:	00007797          	auipc	a5,0x7
    80001a6a:	f7678793          	addi	a5,a5,-138 # 800089dc <z2.2318>
    80001a6e:	4394                	lw	a3,0(a5)
    80001a70:	0026971b          	slliw	a4,a3,0x2
    80001a74:	8f35                	xor	a4,a4,a3
    80001a76:	41b7571b          	sraiw	a4,a4,0x1b
	z2 = (((z2 & 4294967288) << 2) ^ b);
    80001a7a:	068a                	slli	a3,a3,0x2
    80001a7c:	9a81                	andi	a3,a3,-32
    80001a7e:	8eb9                	xor	a3,a3,a4
    80001a80:	2681                	sext.w	a3,a3
    80001a82:	c394                	sw	a3,0(a5)
	b = (((z3 << 13) ^ z3) >> 21);
    80001a84:	00007597          	auipc	a1,0x7
    80001a88:	f5458593          	addi	a1,a1,-172 # 800089d8 <z3.2319>
    80001a8c:	4198                	lw	a4,0(a1)
    80001a8e:	00d7179b          	slliw	a5,a4,0xd
    80001a92:	8fb9                	xor	a5,a5,a4
    80001a94:	4157d79b          	sraiw	a5,a5,0x15
	z3 = (((z3 & 4294967280) << 7) ^ b);
    80001a98:	071e                	slli	a4,a4,0x7
    80001a9a:	80077713          	andi	a4,a4,-2048
    80001a9e:	8f3d                	xor	a4,a4,a5
    80001aa0:	2701                	sext.w	a4,a4
    80001aa2:	c198                	sw	a4,0(a1)
	b = (((z4 << 3) ^ z4) >> 12);
    80001aa4:	00007817          	auipc	a6,0x7
    80001aa8:	f3080813          	addi	a6,a6,-208 # 800089d4 <z4.2320>
    80001aac:	00082783          	lw	a5,0(a6)
    80001ab0:	0037959b          	slliw	a1,a5,0x3
    80001ab4:	8dbd                	xor	a1,a1,a5
    80001ab6:	40c5d59b          	sraiw	a1,a1,0xc
	z4 = (((z4 & 4294967168) << 13) ^ b);
    80001aba:	07b6                	slli	a5,a5,0xd
    80001abc:	fff008b7          	lui	a7,0xfff00
    80001ac0:	0117f7b3          	and	a5,a5,a7
    80001ac4:	8fad                	xor	a5,a5,a1
    80001ac6:	2781                	sext.w	a5,a5
    80001ac8:	00f82023          	sw	a5,0(a6)

	// if we have an argument, then we can use it
	int rand = ((z1 ^ z2 ^ z3 ^ z4)) % max;
    80001acc:	8eb1                	xor	a3,a3,a2
    80001ace:	8f35                	xor	a4,a4,a3
    80001ad0:	8fb9                	xor	a5,a5,a4
    80001ad2:	02a7e53b          	remw	a0,a5,a0
    80001ad6:	41f5579b          	sraiw	a5,a0,0x1f
    80001ada:	8d3d                	xor	a0,a0,a5
    80001adc:	9d1d                	subw	a0,a0,a5
	{
		rand = rand * -1;
	}

	return rand;
}
    80001ade:	6422                	ld	s0,8(sp)
    80001ae0:	0141                	addi	sp,sp,16
    80001ae2:	8082                	ret
		return 1;
    80001ae4:	4505                	li	a0,1
    80001ae6:	bfe5                	j	80001ade <random_lbs+0xa6>

0000000080001ae8 <calculateDynamicPriority>:

// #ifdef PBS
int calculateDynamicPriority(struct proc *process)
{
    80001ae8:	1141                	addi	sp,sp,-16
    80001aea:	e422                	sd	s0,8(sp)
    80001aec:	0800                	addi	s0,sp,16
	process->niceness = 5;
    80001aee:	4795                	li	a5,5
    80001af0:	1cf52223          	sw	a5,452(a0)
	if (process->runTimePrev == 0)
    80001af4:	1b452783          	lw	a5,436(a0)
    80001af8:	e791                	bnez	a5,80001b04 <calculateDynamicPriority+0x1c>
	{
		if (process->sleepTimePrev == 0)
    80001afa:	1ac52783          	lw	a5,428(a0)
    80001afe:	e399                	bnez	a5,80001b04 <calculateDynamicPriority+0x1c>
		{
			process->niceness = process->sleepTimePrev * 10;
			process->niceness /= (process->runTimePrev + process->sleepTimePrev);
    80001b00:	1c052223          	sw	zero,452(a0)
		}
	}
	int retval = 0, checker = process->sprior - process->niceness + 5;
    80001b04:	1bc52783          	lw	a5,444(a0)
    80001b08:	2795                	addiw	a5,a5,5
    80001b0a:	1c452503          	lw	a0,452(a0)
    80001b0e:	40a7853b          	subw	a0,a5,a0
	}
	else
	{
		retval = checker;
	}
	return retval;
    80001b12:	0005079b          	sext.w	a5,a0
    80001b16:	fff7c793          	not	a5,a5
    80001b1a:	97fd                	srai	a5,a5,0x3f
    80001b1c:	8d7d                	and	a0,a0,a5
    80001b1e:	0005071b          	sext.w	a4,a0
    80001b22:	06400793          	li	a5,100
    80001b26:	00e7d463          	bge	a5,a4,80001b2e <calculateDynamicPriority+0x46>
    80001b2a:	06400513          	li	a0,100
}
    80001b2e:	2501                	sext.w	a0,a0
    80001b30:	6422                	ld	s0,8(sp)
    80001b32:	0141                	addi	sp,sp,16
    80001b34:	8082                	ret

0000000080001b36 <set_priority>:
// #endif

int set_priority(int static_prior, int pid)
{
    80001b36:	7139                	addi	sp,sp,-64
    80001b38:	fc06                	sd	ra,56(sp)
    80001b3a:	f822                	sd	s0,48(sp)
    80001b3c:	f426                	sd	s1,40(sp)
    80001b3e:	f04a                	sd	s2,32(sp)
    80001b40:	ec4e                	sd	s3,24(sp)
    80001b42:	e852                	sd	s4,16(sp)
    80001b44:	e456                	sd	s5,8(sp)
    80001b46:	0080                	addi	s0,sp,64
    80001b48:	89ae                	mv	s3,a1
	int old_prior = -1, checkIfAvailable = 0;
	if (static_prior < 0 || static_prior > 100)
    80001b4a:	8aaa                	mv	s5,a0
    80001b4c:	06400793          	li	a5,100
	{
		printf("Priority is not right\n");
		return -1;
	}
	struct proc *i;
	for (i = proc; i < &proc[NPROC]; i++)
    80001b50:	0022f497          	auipc	s1,0x22f
    80001b54:	79848493          	addi	s1,s1,1944 # 802312e8 <proc>
    80001b58:	00237a17          	auipc	s4,0x237
    80001b5c:	390a0a13          	addi	s4,s4,912 # 80238ee8 <tickslock>
	if (static_prior < 0 || static_prior > 100)
    80001b60:	02a7e763          	bltu	a5,a0,80001b8e <set_priority+0x58>
	{
		acquire(&i->lock);
    80001b64:	00848913          	addi	s2,s1,8
    80001b68:	854a                	mv	a0,s2
    80001b6a:	fffff097          	auipc	ra,0xfffff
    80001b6e:	23e080e7          	jalr	574(ra) # 80000da8 <acquire>
		if (i->pid == pid)
    80001b72:	5c9c                	lw	a5,56(s1)
    80001b74:	03378763          	beq	a5,s3,80001ba2 <set_priority+0x6c>
		{
			checkIfAvailable = 1;
			release(&i->lock);
			break;
		}
		release(&i->lock);
    80001b78:	854a                	mv	a0,s2
    80001b7a:	fffff097          	auipc	ra,0xfffff
    80001b7e:	2e2080e7          	jalr	738(ra) # 80000e5c <release>
	for (i = proc; i < &proc[NPROC]; i++)
    80001b82:	1f048493          	addi	s1,s1,496
    80001b86:	fd449fe3          	bne	s1,s4,80001b64 <set_priority+0x2e>
		i->dprior = calculateDynamicPriority(i);
		release(&i->lock);
	}
	else
	{
		return -1;
    80001b8a:	59fd                	li	s3,-1
    80001b8c:	a881                	j	80001bdc <set_priority+0xa6>
		printf("Priority is not right\n");
    80001b8e:	00006517          	auipc	a0,0x6
    80001b92:	67a50513          	addi	a0,a0,1658 # 80008208 <digits+0x1c8>
    80001b96:	fffff097          	auipc	ra,0xfffff
    80001b9a:	9f8080e7          	jalr	-1544(ra) # 8000058e <printf>
		return -1;
    80001b9e:	59fd                	li	s3,-1
    80001ba0:	a835                	j	80001bdc <set_priority+0xa6>
			release(&i->lock);
    80001ba2:	854a                	mv	a0,s2
    80001ba4:	fffff097          	auipc	ra,0xfffff
    80001ba8:	2b8080e7          	jalr	696(ra) # 80000e5c <release>
		acquire(&i->lock);
    80001bac:	854a                	mv	a0,s2
    80001bae:	fffff097          	auipc	ra,0xfffff
    80001bb2:	1fa080e7          	jalr	506(ra) # 80000da8 <acquire>
		old_prior = i->sprior;
    80001bb6:	1bc4a983          	lw	s3,444(s1)
		i->sprior = static_prior;
    80001bba:	1b54ae23          	sw	s5,444(s1)
		i->niceness = 5;
    80001bbe:	4795                	li	a5,5
    80001bc0:	1cf4a223          	sw	a5,452(s1)
		i->dprior = calculateDynamicPriority(i);
    80001bc4:	8526                	mv	a0,s1
    80001bc6:	00000097          	auipc	ra,0x0
    80001bca:	f22080e7          	jalr	-222(ra) # 80001ae8 <calculateDynamicPriority>
    80001bce:	1ca4a023          	sw	a0,448(s1)
		release(&i->lock);
    80001bd2:	854a                	mv	a0,s2
    80001bd4:	fffff097          	auipc	ra,0xfffff
    80001bd8:	288080e7          	jalr	648(ra) # 80000e5c <release>
	}
	return old_prior;
}
    80001bdc:	854e                	mv	a0,s3
    80001bde:	70e2                	ld	ra,56(sp)
    80001be0:	7442                	ld	s0,48(sp)
    80001be2:	74a2                	ld	s1,40(sp)
    80001be4:	7902                	ld	s2,32(sp)
    80001be6:	69e2                	ld	s3,24(sp)
    80001be8:	6a42                	ld	s4,16(sp)
    80001bea:	6aa2                	ld	s5,8(sp)
    80001bec:	6121                	addi	sp,sp,64
    80001bee:	8082                	ret

0000000080001bf0 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    80001bf0:	7139                	addi	sp,sp,-64
    80001bf2:	fc06                	sd	ra,56(sp)
    80001bf4:	f822                	sd	s0,48(sp)
    80001bf6:	f426                	sd	s1,40(sp)
    80001bf8:	f04a                	sd	s2,32(sp)
    80001bfa:	ec4e                	sd	s3,24(sp)
    80001bfc:	e852                	sd	s4,16(sp)
    80001bfe:	e456                	sd	s5,8(sp)
    80001c00:	e05a                	sd	s6,0(sp)
    80001c02:	0080                	addi	s0,sp,64
    80001c04:	89aa                	mv	s3,a0
	struct proc *p;

	for (p = proc; p < &proc[NPROC]; p++)
    80001c06:	0022f497          	auipc	s1,0x22f
    80001c0a:	6e248493          	addi	s1,s1,1762 # 802312e8 <proc>
	{
		char *pa = kalloc();
		if (pa == 0)
			panic("kalloc");
		uint64 va = KSTACK((int)(p - proc));
    80001c0e:	8b26                	mv	s6,s1
    80001c10:	00006a97          	auipc	s5,0x6
    80001c14:	3f0a8a93          	addi	s5,s5,1008 # 80008000 <etext>
    80001c18:	04000937          	lui	s2,0x4000
    80001c1c:	197d                	addi	s2,s2,-1
    80001c1e:	0932                	slli	s2,s2,0xc
	for (p = proc; p < &proc[NPROC]; p++)
    80001c20:	00237a17          	auipc	s4,0x237
    80001c24:	2c8a0a13          	addi	s4,s4,712 # 80238ee8 <tickslock>
		char *pa = kalloc();
    80001c28:	fffff097          	auipc	ra,0xfffff
    80001c2c:	04c080e7          	jalr	76(ra) # 80000c74 <kalloc>
    80001c30:	862a                	mv	a2,a0
		if (pa == 0)
    80001c32:	c131                	beqz	a0,80001c76 <proc_mapstacks+0x86>
		uint64 va = KSTACK((int)(p - proc));
    80001c34:	416485b3          	sub	a1,s1,s6
    80001c38:	8591                	srai	a1,a1,0x4
    80001c3a:	000ab783          	ld	a5,0(s5)
    80001c3e:	02f585b3          	mul	a1,a1,a5
    80001c42:	2585                	addiw	a1,a1,1
    80001c44:	00d5959b          	slliw	a1,a1,0xd
		kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001c48:	4719                	li	a4,6
    80001c4a:	6685                	lui	a3,0x1
    80001c4c:	40b905b3          	sub	a1,s2,a1
    80001c50:	854e                	mv	a0,s3
    80001c52:	fffff097          	auipc	ra,0xfffff
    80001c56:	6c6080e7          	jalr	1734(ra) # 80001318 <kvmmap>
	for (p = proc; p < &proc[NPROC]; p++)
    80001c5a:	1f048493          	addi	s1,s1,496
    80001c5e:	fd4495e3          	bne	s1,s4,80001c28 <proc_mapstacks+0x38>
	}
}
    80001c62:	70e2                	ld	ra,56(sp)
    80001c64:	7442                	ld	s0,48(sp)
    80001c66:	74a2                	ld	s1,40(sp)
    80001c68:	7902                	ld	s2,32(sp)
    80001c6a:	69e2                	ld	s3,24(sp)
    80001c6c:	6a42                	ld	s4,16(sp)
    80001c6e:	6aa2                	ld	s5,8(sp)
    80001c70:	6b02                	ld	s6,0(sp)
    80001c72:	6121                	addi	sp,sp,64
    80001c74:	8082                	ret
			panic("kalloc");
    80001c76:	00006517          	auipc	a0,0x6
    80001c7a:	5aa50513          	addi	a0,a0,1450 # 80008220 <digits+0x1e0>
    80001c7e:	fffff097          	auipc	ra,0xfffff
    80001c82:	8c6080e7          	jalr	-1850(ra) # 80000544 <panic>

0000000080001c86 <procinit>:

// initialize the proc table.
void procinit(void)
{
    80001c86:	7139                	addi	sp,sp,-64
    80001c88:	fc06                	sd	ra,56(sp)
    80001c8a:	f822                	sd	s0,48(sp)
    80001c8c:	f426                	sd	s1,40(sp)
    80001c8e:	f04a                	sd	s2,32(sp)
    80001c90:	ec4e                	sd	s3,24(sp)
    80001c92:	e852                	sd	s4,16(sp)
    80001c94:	e456                	sd	s5,8(sp)
    80001c96:	e05a                	sd	s6,0(sp)
    80001c98:	0080                	addi	s0,sp,64
	struct proc *p;

	initlock(&pid_lock, "nextpid");
    80001c9a:	00006597          	auipc	a1,0x6
    80001c9e:	58e58593          	addi	a1,a1,1422 # 80008228 <digits+0x1e8>
    80001ca2:	0022f517          	auipc	a0,0x22f
    80001ca6:	21650513          	addi	a0,a0,534 # 80230eb8 <pid_lock>
    80001caa:	fffff097          	auipc	ra,0xfffff
    80001cae:	06e080e7          	jalr	110(ra) # 80000d18 <initlock>
	initlock(&wait_lock, "wait_lock");
    80001cb2:	00006597          	auipc	a1,0x6
    80001cb6:	57e58593          	addi	a1,a1,1406 # 80008230 <digits+0x1f0>
    80001cba:	0022f517          	auipc	a0,0x22f
    80001cbe:	21650513          	addi	a0,a0,534 # 80230ed0 <wait_lock>
    80001cc2:	fffff097          	auipc	ra,0xfffff
    80001cc6:	056080e7          	jalr	86(ra) # 80000d18 <initlock>
	for (p = proc; p < &proc[NPROC]; p++)
    80001cca:	0022f497          	auipc	s1,0x22f
    80001cce:	61e48493          	addi	s1,s1,1566 # 802312e8 <proc>
	{
		initlock(&p->lock, "proc");
    80001cd2:	00006b17          	auipc	s6,0x6
    80001cd6:	56eb0b13          	addi	s6,s6,1390 # 80008240 <digits+0x200>
		p->state = UNUSED;
		p->kstack = KSTACK((int)(p - proc));
    80001cda:	8aa6                	mv	s5,s1
    80001cdc:	00006a17          	auipc	s4,0x6
    80001ce0:	324a0a13          	addi	s4,s4,804 # 80008000 <etext>
    80001ce4:	04000937          	lui	s2,0x4000
    80001ce8:	197d                	addi	s2,s2,-1
    80001cea:	0932                	slli	s2,s2,0xc
	for (p = proc; p < &proc[NPROC]; p++)
    80001cec:	00237997          	auipc	s3,0x237
    80001cf0:	1fc98993          	addi	s3,s3,508 # 80238ee8 <tickslock>
		initlock(&p->lock, "proc");
    80001cf4:	85da                	mv	a1,s6
    80001cf6:	00848513          	addi	a0,s1,8
    80001cfa:	fffff097          	auipc	ra,0xfffff
    80001cfe:	01e080e7          	jalr	30(ra) # 80000d18 <initlock>
		p->state = UNUSED;
    80001d02:	0204a023          	sw	zero,32(s1)
		p->kstack = KSTACK((int)(p - proc));
    80001d06:	415487b3          	sub	a5,s1,s5
    80001d0a:	8791                	srai	a5,a5,0x4
    80001d0c:	000a3703          	ld	a4,0(s4)
    80001d10:	02e787b3          	mul	a5,a5,a4
    80001d14:	2785                	addiw	a5,a5,1
    80001d16:	00d7979b          	slliw	a5,a5,0xd
    80001d1a:	40f907b3          	sub	a5,s2,a5
    80001d1e:	e4bc                	sd	a5,72(s1)
	for (p = proc; p < &proc[NPROC]; p++)
    80001d20:	1f048493          	addi	s1,s1,496
    80001d24:	fd3498e3          	bne	s1,s3,80001cf4 <procinit+0x6e>
	}
}
    80001d28:	70e2                	ld	ra,56(sp)
    80001d2a:	7442                	ld	s0,48(sp)
    80001d2c:	74a2                	ld	s1,40(sp)
    80001d2e:	7902                	ld	s2,32(sp)
    80001d30:	69e2                	ld	s3,24(sp)
    80001d32:	6a42                	ld	s4,16(sp)
    80001d34:	6aa2                	ld	s5,8(sp)
    80001d36:	6b02                	ld	s6,0(sp)
    80001d38:	6121                	addi	sp,sp,64
    80001d3a:	8082                	ret

0000000080001d3c <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    80001d3c:	1141                	addi	sp,sp,-16
    80001d3e:	e422                	sd	s0,8(sp)
    80001d40:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001d42:	8512                	mv	a0,tp
	int id = r_tp();
	return id;
}
    80001d44:	2501                	sext.w	a0,a0
    80001d46:	6422                	ld	s0,8(sp)
    80001d48:	0141                	addi	sp,sp,16
    80001d4a:	8082                	ret

0000000080001d4c <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001d4c:	1141                	addi	sp,sp,-16
    80001d4e:	e422                	sd	s0,8(sp)
    80001d50:	0800                	addi	s0,sp,16
    80001d52:	8792                	mv	a5,tp
	int id = cpuid();
	struct cpu *c = &cpus[id];
    80001d54:	2781                	sext.w	a5,a5
    80001d56:	079e                	slli	a5,a5,0x7
	return c;
}
    80001d58:	0022f517          	auipc	a0,0x22f
    80001d5c:	19050513          	addi	a0,a0,400 # 80230ee8 <cpus>
    80001d60:	953e                	add	a0,a0,a5
    80001d62:	6422                	ld	s0,8(sp)
    80001d64:	0141                	addi	sp,sp,16
    80001d66:	8082                	ret

0000000080001d68 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001d68:	1101                	addi	sp,sp,-32
    80001d6a:	ec06                	sd	ra,24(sp)
    80001d6c:	e822                	sd	s0,16(sp)
    80001d6e:	e426                	sd	s1,8(sp)
    80001d70:	1000                	addi	s0,sp,32
	push_off();
    80001d72:	fffff097          	auipc	ra,0xfffff
    80001d76:	fea080e7          	jalr	-22(ra) # 80000d5c <push_off>
    80001d7a:	8792                	mv	a5,tp
	struct cpu *c = mycpu();
	struct proc *p = c->proc;
    80001d7c:	2781                	sext.w	a5,a5
    80001d7e:	079e                	slli	a5,a5,0x7
    80001d80:	0022f717          	auipc	a4,0x22f
    80001d84:	13870713          	addi	a4,a4,312 # 80230eb8 <pid_lock>
    80001d88:	97ba                	add	a5,a5,a4
    80001d8a:	7b84                	ld	s1,48(a5)
	pop_off();
    80001d8c:	fffff097          	auipc	ra,0xfffff
    80001d90:	070080e7          	jalr	112(ra) # 80000dfc <pop_off>
	return p;
}
    80001d94:	8526                	mv	a0,s1
    80001d96:	60e2                	ld	ra,24(sp)
    80001d98:	6442                	ld	s0,16(sp)
    80001d9a:	64a2                	ld	s1,8(sp)
    80001d9c:	6105                	addi	sp,sp,32
    80001d9e:	8082                	ret

0000000080001da0 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001da0:	1141                	addi	sp,sp,-16
    80001da2:	e406                	sd	ra,8(sp)
    80001da4:	e022                	sd	s0,0(sp)
    80001da6:	0800                	addi	s0,sp,16
	static int first = 1;

	// Still holding p->lock from scheduler.
	release(&myproc()->lock);
    80001da8:	00000097          	auipc	ra,0x0
    80001dac:	fc0080e7          	jalr	-64(ra) # 80001d68 <myproc>
    80001db0:	0521                	addi	a0,a0,8
    80001db2:	fffff097          	auipc	ra,0xfffff
    80001db6:	0aa080e7          	jalr	170(ra) # 80000e5c <release>

	if (first)
    80001dba:	00007797          	auipc	a5,0x7
    80001dbe:	c167a783          	lw	a5,-1002(a5) # 800089d0 <first.2500>
    80001dc2:	eb89                	bnez	a5,80001dd4 <forkret+0x34>
		// be run from main().
		first = 0;
		fsinit(ROOTDEV);
	}

	usertrapret();
    80001dc4:	00001097          	auipc	ra,0x1
    80001dc8:	17c080e7          	jalr	380(ra) # 80002f40 <usertrapret>
}
    80001dcc:	60a2                	ld	ra,8(sp)
    80001dce:	6402                	ld	s0,0(sp)
    80001dd0:	0141                	addi	sp,sp,16
    80001dd2:	8082                	ret
		first = 0;
    80001dd4:	00007797          	auipc	a5,0x7
    80001dd8:	be07ae23          	sw	zero,-1028(a5) # 800089d0 <first.2500>
		fsinit(ROOTDEV);
    80001ddc:	4505                	li	a0,1
    80001dde:	00002097          	auipc	ra,0x2
    80001de2:	298080e7          	jalr	664(ra) # 80004076 <fsinit>
    80001de6:	bff9                	j	80001dc4 <forkret+0x24>

0000000080001de8 <allocpid>:
{
    80001de8:	1101                	addi	sp,sp,-32
    80001dea:	ec06                	sd	ra,24(sp)
    80001dec:	e822                	sd	s0,16(sp)
    80001dee:	e426                	sd	s1,8(sp)
    80001df0:	e04a                	sd	s2,0(sp)
    80001df2:	1000                	addi	s0,sp,32
	acquire(&pid_lock);
    80001df4:	0022f917          	auipc	s2,0x22f
    80001df8:	0c490913          	addi	s2,s2,196 # 80230eb8 <pid_lock>
    80001dfc:	854a                	mv	a0,s2
    80001dfe:	fffff097          	auipc	ra,0xfffff
    80001e02:	faa080e7          	jalr	-86(ra) # 80000da8 <acquire>
	pid = nextpid;
    80001e06:	00007797          	auipc	a5,0x7
    80001e0a:	bde78793          	addi	a5,a5,-1058 # 800089e4 <nextpid>
    80001e0e:	4384                	lw	s1,0(a5)
	nextpid = nextpid + 1;
    80001e10:	0014871b          	addiw	a4,s1,1
    80001e14:	c398                	sw	a4,0(a5)
	release(&pid_lock);
    80001e16:	854a                	mv	a0,s2
    80001e18:	fffff097          	auipc	ra,0xfffff
    80001e1c:	044080e7          	jalr	68(ra) # 80000e5c <release>
}
    80001e20:	8526                	mv	a0,s1
    80001e22:	60e2                	ld	ra,24(sp)
    80001e24:	6442                	ld	s0,16(sp)
    80001e26:	64a2                	ld	s1,8(sp)
    80001e28:	6902                	ld	s2,0(sp)
    80001e2a:	6105                	addi	sp,sp,32
    80001e2c:	8082                	ret

0000000080001e2e <proc_pagetable>:
{
    80001e2e:	1101                	addi	sp,sp,-32
    80001e30:	ec06                	sd	ra,24(sp)
    80001e32:	e822                	sd	s0,16(sp)
    80001e34:	e426                	sd	s1,8(sp)
    80001e36:	e04a                	sd	s2,0(sp)
    80001e38:	1000                	addi	s0,sp,32
    80001e3a:	892a                	mv	s2,a0
	pagetable = uvmcreate();
    80001e3c:	fffff097          	auipc	ra,0xfffff
    80001e40:	6c6080e7          	jalr	1734(ra) # 80001502 <uvmcreate>
    80001e44:	84aa                	mv	s1,a0
	if (pagetable == 0)
    80001e46:	c121                	beqz	a0,80001e86 <proc_pagetable+0x58>
	if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001e48:	4729                	li	a4,10
    80001e4a:	00005697          	auipc	a3,0x5
    80001e4e:	1b668693          	addi	a3,a3,438 # 80007000 <_trampoline>
    80001e52:	6605                	lui	a2,0x1
    80001e54:	040005b7          	lui	a1,0x4000
    80001e58:	15fd                	addi	a1,a1,-1
    80001e5a:	05b2                	slli	a1,a1,0xc
    80001e5c:	fffff097          	auipc	ra,0xfffff
    80001e60:	41c080e7          	jalr	1052(ra) # 80001278 <mappages>
    80001e64:	02054863          	bltz	a0,80001e94 <proc_pagetable+0x66>
	if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001e68:	4719                	li	a4,6
    80001e6a:	06093683          	ld	a3,96(s2)
    80001e6e:	6605                	lui	a2,0x1
    80001e70:	020005b7          	lui	a1,0x2000
    80001e74:	15fd                	addi	a1,a1,-1
    80001e76:	05b6                	slli	a1,a1,0xd
    80001e78:	8526                	mv	a0,s1
    80001e7a:	fffff097          	auipc	ra,0xfffff
    80001e7e:	3fe080e7          	jalr	1022(ra) # 80001278 <mappages>
    80001e82:	02054163          	bltz	a0,80001ea4 <proc_pagetable+0x76>
}
    80001e86:	8526                	mv	a0,s1
    80001e88:	60e2                	ld	ra,24(sp)
    80001e8a:	6442                	ld	s0,16(sp)
    80001e8c:	64a2                	ld	s1,8(sp)
    80001e8e:	6902                	ld	s2,0(sp)
    80001e90:	6105                	addi	sp,sp,32
    80001e92:	8082                	ret
		uvmfree(pagetable, 0);
    80001e94:	4581                	li	a1,0
    80001e96:	8526                	mv	a0,s1
    80001e98:	00000097          	auipc	ra,0x0
    80001e9c:	86e080e7          	jalr	-1938(ra) # 80001706 <uvmfree>
		return 0;
    80001ea0:	4481                	li	s1,0
    80001ea2:	b7d5                	j	80001e86 <proc_pagetable+0x58>
		uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ea4:	4681                	li	a3,0
    80001ea6:	4605                	li	a2,1
    80001ea8:	040005b7          	lui	a1,0x4000
    80001eac:	15fd                	addi	a1,a1,-1
    80001eae:	05b2                	slli	a1,a1,0xc
    80001eb0:	8526                	mv	a0,s1
    80001eb2:	fffff097          	auipc	ra,0xfffff
    80001eb6:	58c080e7          	jalr	1420(ra) # 8000143e <uvmunmap>
		uvmfree(pagetable, 0);
    80001eba:	4581                	li	a1,0
    80001ebc:	8526                	mv	a0,s1
    80001ebe:	00000097          	auipc	ra,0x0
    80001ec2:	848080e7          	jalr	-1976(ra) # 80001706 <uvmfree>
		return 0;
    80001ec6:	4481                	li	s1,0
    80001ec8:	bf7d                	j	80001e86 <proc_pagetable+0x58>

0000000080001eca <proc_freepagetable>:
{
    80001eca:	1101                	addi	sp,sp,-32
    80001ecc:	ec06                	sd	ra,24(sp)
    80001ece:	e822                	sd	s0,16(sp)
    80001ed0:	e426                	sd	s1,8(sp)
    80001ed2:	e04a                	sd	s2,0(sp)
    80001ed4:	1000                	addi	s0,sp,32
    80001ed6:	84aa                	mv	s1,a0
    80001ed8:	892e                	mv	s2,a1
	uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001eda:	4681                	li	a3,0
    80001edc:	4605                	li	a2,1
    80001ede:	040005b7          	lui	a1,0x4000
    80001ee2:	15fd                	addi	a1,a1,-1
    80001ee4:	05b2                	slli	a1,a1,0xc
    80001ee6:	fffff097          	auipc	ra,0xfffff
    80001eea:	558080e7          	jalr	1368(ra) # 8000143e <uvmunmap>
	uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001eee:	4681                	li	a3,0
    80001ef0:	4605                	li	a2,1
    80001ef2:	020005b7          	lui	a1,0x2000
    80001ef6:	15fd                	addi	a1,a1,-1
    80001ef8:	05b6                	slli	a1,a1,0xd
    80001efa:	8526                	mv	a0,s1
    80001efc:	fffff097          	auipc	ra,0xfffff
    80001f00:	542080e7          	jalr	1346(ra) # 8000143e <uvmunmap>
	uvmfree(pagetable, sz);
    80001f04:	85ca                	mv	a1,s2
    80001f06:	8526                	mv	a0,s1
    80001f08:	fffff097          	auipc	ra,0xfffff
    80001f0c:	7fe080e7          	jalr	2046(ra) # 80001706 <uvmfree>
}
    80001f10:	60e2                	ld	ra,24(sp)
    80001f12:	6442                	ld	s0,16(sp)
    80001f14:	64a2                	ld	s1,8(sp)
    80001f16:	6902                	ld	s2,0(sp)
    80001f18:	6105                	addi	sp,sp,32
    80001f1a:	8082                	ret

0000000080001f1c <freeproc>:
{
    80001f1c:	1101                	addi	sp,sp,-32
    80001f1e:	ec06                	sd	ra,24(sp)
    80001f20:	e822                	sd	s0,16(sp)
    80001f22:	e426                	sd	s1,8(sp)
    80001f24:	1000                	addi	s0,sp,32
    80001f26:	84aa                	mv	s1,a0
	if (p->trapframe)
    80001f28:	7128                	ld	a0,96(a0)
    80001f2a:	c509                	beqz	a0,80001f34 <freeproc+0x18>
		kfree((void *)p->trapframe);
    80001f2c:	fffff097          	auipc	ra,0xfffff
    80001f30:	ba2080e7          	jalr	-1118(ra) # 80000ace <kfree>
	p->trapframe = 0;
    80001f34:	0604b023          	sd	zero,96(s1)
	if (p->pagetable)
    80001f38:	6ca8                	ld	a0,88(s1)
    80001f3a:	c511                	beqz	a0,80001f46 <freeproc+0x2a>
		proc_freepagetable(p->pagetable, p->sz);
    80001f3c:	68ac                	ld	a1,80(s1)
    80001f3e:	00000097          	auipc	ra,0x0
    80001f42:	f8c080e7          	jalr	-116(ra) # 80001eca <proc_freepagetable>
	p->pagetable = 0;
    80001f46:	0404bc23          	sd	zero,88(s1)
	p->sz = 0;
    80001f4a:	0404b823          	sd	zero,80(s1)
	p->pid = 0;
    80001f4e:	0204ac23          	sw	zero,56(s1)
	p->parent = 0;
    80001f52:	0404b023          	sd	zero,64(s1)
	p->name[0] = 0;
    80001f56:	16048023          	sb	zero,352(s1)
	p->chan = 0;
    80001f5a:	0204b423          	sd	zero,40(s1)
	p->killed = 0;
    80001f5e:	0204a823          	sw	zero,48(s1)
	p->xstate = 0;
    80001f62:	0204aa23          	sw	zero,52(s1)
	p->state = UNUSED;
    80001f66:	0204a023          	sw	zero,32(s1)
}
    80001f6a:	60e2                	ld	ra,24(sp)
    80001f6c:	6442                	ld	s0,16(sp)
    80001f6e:	64a2                	ld	s1,8(sp)
    80001f70:	6105                	addi	sp,sp,32
    80001f72:	8082                	ret

0000000080001f74 <allocproc>:
{
    80001f74:	7179                	addi	sp,sp,-48
    80001f76:	f406                	sd	ra,40(sp)
    80001f78:	f022                	sd	s0,32(sp)
    80001f7a:	ec26                	sd	s1,24(sp)
    80001f7c:	e84a                	sd	s2,16(sp)
    80001f7e:	e44e                	sd	s3,8(sp)
    80001f80:	1800                	addi	s0,sp,48
	for (p = proc; p < &proc[NPROC]; p++)
    80001f82:	0022f497          	auipc	s1,0x22f
    80001f86:	36648493          	addi	s1,s1,870 # 802312e8 <proc>
    80001f8a:	00237997          	auipc	s3,0x237
    80001f8e:	f5e98993          	addi	s3,s3,-162 # 80238ee8 <tickslock>
		acquire(&p->lock);
    80001f92:	00848913          	addi	s2,s1,8
    80001f96:	854a                	mv	a0,s2
    80001f98:	fffff097          	auipc	ra,0xfffff
    80001f9c:	e10080e7          	jalr	-496(ra) # 80000da8 <acquire>
		if (p->state == UNUSED)
    80001fa0:	509c                	lw	a5,32(s1)
    80001fa2:	cf81                	beqz	a5,80001fba <allocproc+0x46>
			release(&p->lock);
    80001fa4:	854a                	mv	a0,s2
    80001fa6:	fffff097          	auipc	ra,0xfffff
    80001faa:	eb6080e7          	jalr	-330(ra) # 80000e5c <release>
	for (p = proc; p < &proc[NPROC]; p++)
    80001fae:	1f048493          	addi	s1,s1,496
    80001fb2:	ff3490e3          	bne	s1,s3,80001f92 <allocproc+0x1e>
	return 0;
    80001fb6:	4481                	li	s1,0
    80001fb8:	a075                	j	80002064 <allocproc+0xf0>
	p->pid = allocpid();
    80001fba:	00000097          	auipc	ra,0x0
    80001fbe:	e2e080e7          	jalr	-466(ra) # 80001de8 <allocpid>
    80001fc2:	dc88                	sw	a0,56(s1)
	p->state = USED;
    80001fc4:	4785                	li	a5,1
    80001fc6:	d09c                	sw	a5,32(s1)
	p->tickets = 1;
    80001fc8:	18f4a623          	sw	a5,396(s1)
	p->time_spent = 0;
    80001fcc:	1804a823          	sw	zero,400(s1)
	p->time_avail = 1;
    80001fd0:	18f4aa23          	sw	a5,404(s1)
	p->priority_level = 0;
    80001fd4:	1c04a423          	sw	zero,456(s1)
	p->ass_ticks = 1;
    80001fd8:	1cf4a623          	sw	a5,460(s1)
	p->ticks_elapsed = 0;
    80001fdc:	1c04aa23          	sw	zero,468(s1)
		p->queue_ticks[i] = 0;
    80001fe0:	1c04ac23          	sw	zero,472(s1)
    80001fe4:	1c04ae23          	sw	zero,476(s1)
    80001fe8:	1e04a023          	sw	zero,480(s1)
    80001fec:	1e04a223          	sw	zero,484(s1)
    80001ff0:	1e04a423          	sw	zero,488(s1)
	p->creationTime = ticks;
    80001ff4:	00007797          	auipc	a5,0x7
    80001ff8:	c3c7a783          	lw	a5,-964(a5) # 80008c30 <ticks>
    80001ffc:	18f4ae23          	sw	a5,412(s1)
	p->sprior = 60;
    80002000:	03c00793          	li	a5,60
    80002004:	1af4ae23          	sw	a5,444(s1)
	p->niceness = 5;
    80002008:	4795                	li	a5,5
    8000200a:	1cf4a223          	sw	a5,452(s1)
	p->runTime = 0;
    8000200e:	1a04a023          	sw	zero,416(s1)
	p->endTime = 0;
    80002012:	1a04a223          	sw	zero,420(s1)
	p->runTimePrev = 0;
    80002016:	1a04aa23          	sw	zero,436(s1)
	p->sleepTimePrev = 0;
    8000201a:	1a04a623          	sw	zero,428(s1)
	p->sleepStartTime = 0;
    8000201e:	1a04a823          	sw	zero,432(s1)
	if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80002022:	fffff097          	auipc	ra,0xfffff
    80002026:	c52080e7          	jalr	-942(ra) # 80000c74 <kalloc>
    8000202a:	89aa                	mv	s3,a0
    8000202c:	f0a8                	sd	a0,96(s1)
    8000202e:	c139                	beqz	a0,80002074 <allocproc+0x100>
	p->pagetable = proc_pagetable(p);
    80002030:	8526                	mv	a0,s1
    80002032:	00000097          	auipc	ra,0x0
    80002036:	dfc080e7          	jalr	-516(ra) # 80001e2e <proc_pagetable>
    8000203a:	89aa                	mv	s3,a0
    8000203c:	eca8                	sd	a0,88(s1)
	if (p->pagetable == 0)
    8000203e:	c539                	beqz	a0,8000208c <allocproc+0x118>
	memset(&p->context, 0, sizeof(p->context));
    80002040:	07000613          	li	a2,112
    80002044:	4581                	li	a1,0
    80002046:	06848513          	addi	a0,s1,104
    8000204a:	fffff097          	auipc	ra,0xfffff
    8000204e:	e5a080e7          	jalr	-422(ra) # 80000ea4 <memset>
	p->context.ra = (uint64)forkret;
    80002052:	00000797          	auipc	a5,0x0
    80002056:	d4e78793          	addi	a5,a5,-690 # 80001da0 <forkret>
    8000205a:	f4bc                	sd	a5,104(s1)
	p->context.sp = p->kstack + PGSIZE;
    8000205c:	64bc                	ld	a5,72(s1)
    8000205e:	6705                	lui	a4,0x1
    80002060:	97ba                	add	a5,a5,a4
    80002062:	f8bc                	sd	a5,112(s1)
}
    80002064:	8526                	mv	a0,s1
    80002066:	70a2                	ld	ra,40(sp)
    80002068:	7402                	ld	s0,32(sp)
    8000206a:	64e2                	ld	s1,24(sp)
    8000206c:	6942                	ld	s2,16(sp)
    8000206e:	69a2                	ld	s3,8(sp)
    80002070:	6145                	addi	sp,sp,48
    80002072:	8082                	ret
		freeproc(p);
    80002074:	8526                	mv	a0,s1
    80002076:	00000097          	auipc	ra,0x0
    8000207a:	ea6080e7          	jalr	-346(ra) # 80001f1c <freeproc>
		release(&p->lock);
    8000207e:	854a                	mv	a0,s2
    80002080:	fffff097          	auipc	ra,0xfffff
    80002084:	ddc080e7          	jalr	-548(ra) # 80000e5c <release>
		return 0;
    80002088:	84ce                	mv	s1,s3
    8000208a:	bfe9                	j	80002064 <allocproc+0xf0>
		freeproc(p);
    8000208c:	8526                	mv	a0,s1
    8000208e:	00000097          	auipc	ra,0x0
    80002092:	e8e080e7          	jalr	-370(ra) # 80001f1c <freeproc>
		release(&p->lock);
    80002096:	854a                	mv	a0,s2
    80002098:	fffff097          	auipc	ra,0xfffff
    8000209c:	dc4080e7          	jalr	-572(ra) # 80000e5c <release>
		return 0;
    800020a0:	84ce                	mv	s1,s3
    800020a2:	b7c9                	j	80002064 <allocproc+0xf0>

00000000800020a4 <userinit>:
{
    800020a4:	1101                	addi	sp,sp,-32
    800020a6:	ec06                	sd	ra,24(sp)
    800020a8:	e822                	sd	s0,16(sp)
    800020aa:	e426                	sd	s1,8(sp)
    800020ac:	1000                	addi	s0,sp,32
	p = allocproc();
    800020ae:	00000097          	auipc	ra,0x0
    800020b2:	ec6080e7          	jalr	-314(ra) # 80001f74 <allocproc>
    800020b6:	84aa                	mv	s1,a0
	initproc = p;
    800020b8:	00007797          	auipc	a5,0x7
    800020bc:	b6a7b823          	sd	a0,-1168(a5) # 80008c28 <initproc>
	uvmfirst(p->pagetable, initcode, sizeof(initcode));
    800020c0:	03400613          	li	a2,52
    800020c4:	00007597          	auipc	a1,0x7
    800020c8:	92c58593          	addi	a1,a1,-1748 # 800089f0 <initcode>
    800020cc:	6d28                	ld	a0,88(a0)
    800020ce:	fffff097          	auipc	ra,0xfffff
    800020d2:	462080e7          	jalr	1122(ra) # 80001530 <uvmfirst>
	p->sz = PGSIZE;
    800020d6:	6785                	lui	a5,0x1
    800020d8:	e8bc                	sd	a5,80(s1)
	p->trapframe->epc = 0;	   // user program counter
    800020da:	70b8                	ld	a4,96(s1)
    800020dc:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
	p->trapframe->sp = PGSIZE; // user stack pointer
    800020e0:	70b8                	ld	a4,96(s1)
    800020e2:	fb1c                	sd	a5,48(a4)
	safestrcpy(p->name, "initcode", sizeof(p->name));
    800020e4:	4641                	li	a2,16
    800020e6:	00006597          	auipc	a1,0x6
    800020ea:	16258593          	addi	a1,a1,354 # 80008248 <digits+0x208>
    800020ee:	16048513          	addi	a0,s1,352
    800020f2:	fffff097          	auipc	ra,0xfffff
    800020f6:	f04080e7          	jalr	-252(ra) # 80000ff6 <safestrcpy>
	p->cwd = namei("/");
    800020fa:	00006517          	auipc	a0,0x6
    800020fe:	15e50513          	addi	a0,a0,350 # 80008258 <digits+0x218>
    80002102:	00003097          	auipc	ra,0x3
    80002106:	996080e7          	jalr	-1642(ra) # 80004a98 <namei>
    8000210a:	14a4bc23          	sd	a0,344(s1)
	p->state = RUNNABLE;
    8000210e:	478d                	li	a5,3
    80002110:	d09c                	sw	a5,32(s1)
	release(&p->lock);
    80002112:	00848513          	addi	a0,s1,8
    80002116:	fffff097          	auipc	ra,0xfffff
    8000211a:	d46080e7          	jalr	-698(ra) # 80000e5c <release>
}
    8000211e:	60e2                	ld	ra,24(sp)
    80002120:	6442                	ld	s0,16(sp)
    80002122:	64a2                	ld	s1,8(sp)
    80002124:	6105                	addi	sp,sp,32
    80002126:	8082                	ret

0000000080002128 <growproc>:
{
    80002128:	1101                	addi	sp,sp,-32
    8000212a:	ec06                	sd	ra,24(sp)
    8000212c:	e822                	sd	s0,16(sp)
    8000212e:	e426                	sd	s1,8(sp)
    80002130:	e04a                	sd	s2,0(sp)
    80002132:	1000                	addi	s0,sp,32
    80002134:	892a                	mv	s2,a0
	struct proc *p = myproc();
    80002136:	00000097          	auipc	ra,0x0
    8000213a:	c32080e7          	jalr	-974(ra) # 80001d68 <myproc>
    8000213e:	84aa                	mv	s1,a0
	sz = p->sz;
    80002140:	692c                	ld	a1,80(a0)
	if (n > 0)
    80002142:	01204c63          	bgtz	s2,8000215a <growproc+0x32>
	else if (n < 0)
    80002146:	02094663          	bltz	s2,80002172 <growproc+0x4a>
	p->sz = sz;
    8000214a:	e8ac                	sd	a1,80(s1)
	return 0;
    8000214c:	4501                	li	a0,0
}
    8000214e:	60e2                	ld	ra,24(sp)
    80002150:	6442                	ld	s0,16(sp)
    80002152:	64a2                	ld	s1,8(sp)
    80002154:	6902                	ld	s2,0(sp)
    80002156:	6105                	addi	sp,sp,32
    80002158:	8082                	ret
		if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    8000215a:	4691                	li	a3,4
    8000215c:	00b90633          	add	a2,s2,a1
    80002160:	6d28                	ld	a0,88(a0)
    80002162:	fffff097          	auipc	ra,0xfffff
    80002166:	488080e7          	jalr	1160(ra) # 800015ea <uvmalloc>
    8000216a:	85aa                	mv	a1,a0
    8000216c:	fd79                	bnez	a0,8000214a <growproc+0x22>
			return -1;
    8000216e:	557d                	li	a0,-1
    80002170:	bff9                	j	8000214e <growproc+0x26>
		sz = uvmdealloc(p->pagetable, sz, sz + n);
    80002172:	00b90633          	add	a2,s2,a1
    80002176:	6d28                	ld	a0,88(a0)
    80002178:	fffff097          	auipc	ra,0xfffff
    8000217c:	42a080e7          	jalr	1066(ra) # 800015a2 <uvmdealloc>
    80002180:	85aa                	mv	a1,a0
    80002182:	b7e1                	j	8000214a <growproc+0x22>

0000000080002184 <upd_time>:
{
    80002184:	7179                	addi	sp,sp,-48
    80002186:	f406                	sd	ra,40(sp)
    80002188:	f022                	sd	s0,32(sp)
    8000218a:	ec26                	sd	s1,24(sp)
    8000218c:	e84a                	sd	s2,16(sp)
    8000218e:	e44e                	sd	s3,8(sp)
    80002190:	e052                	sd	s4,0(sp)
    80002192:	1800                	addi	s0,sp,48
	struct proc *pr = proc;
    80002194:	0022f497          	auipc	s1,0x22f
    80002198:	15448493          	addi	s1,s1,340 # 802312e8 <proc>
		if (pr->state == RUNNING)
    8000219c:	4a11                	li	s4,4
	while (pr < &proc[NPROC])
    8000219e:	00237997          	auipc	s3,0x237
    800021a2:	d4a98993          	addi	s3,s3,-694 # 80238ee8 <tickslock>
    800021a6:	a811                	j	800021ba <upd_time+0x36>
		release(&pr->lock);
    800021a8:	854a                	mv	a0,s2
    800021aa:	fffff097          	auipc	ra,0xfffff
    800021ae:	cb2080e7          	jalr	-846(ra) # 80000e5c <release>
		pr++;
    800021b2:	1f048493          	addi	s1,s1,496
	while (pr < &proc[NPROC])
    800021b6:	05348563          	beq	s1,s3,80002200 <upd_time+0x7c>
		acquire(&pr->lock);
    800021ba:	00848913          	addi	s2,s1,8
    800021be:	854a                	mv	a0,s2
    800021c0:	fffff097          	auipc	ra,0xfffff
    800021c4:	be8080e7          	jalr	-1048(ra) # 80000da8 <acquire>
		if (pr->state == RUNNING)
    800021c8:	509c                	lw	a5,32(s1)
    800021ca:	fd479fe3          	bne	a5,s4,800021a8 <upd_time+0x24>
			pr->runTime++;
    800021ce:	1a04a783          	lw	a5,416(s1)
    800021d2:	2785                	addiw	a5,a5,1
    800021d4:	1af4a023          	sw	a5,416(s1)
			pr->runTimePrev++;
    800021d8:	1b44a783          	lw	a5,436(s1)
    800021dc:	2785                	addiw	a5,a5,1
    800021de:	1af4aa23          	sw	a5,436(s1)
			pr->queue_ticks[pr->priority_level]++;
    800021e2:	1c84a783          	lw	a5,456(s1)
    800021e6:	078a                	slli	a5,a5,0x2
    800021e8:	97a6                	add	a5,a5,s1
    800021ea:	1d87a703          	lw	a4,472(a5) # 11d8 <_entry-0x7fffee28>
    800021ee:	2705                	addiw	a4,a4,1
    800021f0:	1ce7ac23          	sw	a4,472(a5)
			pr->wait_time++;
    800021f4:	1d04a783          	lw	a5,464(s1)
    800021f8:	2785                	addiw	a5,a5,1
    800021fa:	1cf4a823          	sw	a5,464(s1)
    800021fe:	b76d                	j	800021a8 <upd_time+0x24>
}
    80002200:	70a2                	ld	ra,40(sp)
    80002202:	7402                	ld	s0,32(sp)
    80002204:	64e2                	ld	s1,24(sp)
    80002206:	6942                	ld	s2,16(sp)
    80002208:	69a2                	ld	s3,8(sp)
    8000220a:	6a02                	ld	s4,0(sp)
    8000220c:	6145                	addi	sp,sp,48
    8000220e:	8082                	ret

0000000080002210 <aging_check>:
{
    80002210:	1141                	addi	sp,sp,-16
    80002212:	e422                	sd	s0,8(sp)
    80002214:	0800                	addi	s0,sp,16
	for (p = proc; p < &proc[NPROC]; p++)
    80002216:	0022f797          	auipc	a5,0x22f
    8000221a:	0d278793          	addi	a5,a5,210 # 802312e8 <proc>
		if ((p->state == SLEEPING || p->state == RUNNABLE) && p->wait_time > AGE && p->priority_level != 0)
    8000221e:	4605                	li	a2,1
    80002220:	02400593          	li	a1,36
	for (p = proc; p < &proc[NPROC]; p++)
    80002224:	00237697          	auipc	a3,0x237
    80002228:	cc468693          	addi	a3,a3,-828 # 80238ee8 <tickslock>
    8000222c:	a029                	j	80002236 <aging_check+0x26>
    8000222e:	1f078793          	addi	a5,a5,496
    80002232:	02d78c63          	beq	a5,a3,8000226a <aging_check+0x5a>
		if ((p->state == SLEEPING || p->state == RUNNABLE) && p->wait_time > AGE && p->priority_level != 0)
    80002236:	5398                	lw	a4,32(a5)
    80002238:	3779                	addiw	a4,a4,-2
    8000223a:	fee66ae3          	bltu	a2,a4,8000222e <aging_check+0x1e>
    8000223e:	1d07a703          	lw	a4,464(a5)
    80002242:	fee5d6e3          	bge	a1,a4,8000222e <aging_check+0x1e>
    80002246:	1c87a703          	lw	a4,456(a5)
    8000224a:	d375                	beqz	a4,8000222e <aging_check+0x1e>
			p->wait_time = 0;
    8000224c:	1c07a823          	sw	zero,464(a5)
			p->priority_level--;
    80002250:	377d                	addiw	a4,a4,-1
    80002252:	1ce7a423          	sw	a4,456(a5)
			p->ass_ticks /= 2;
    80002256:	1cc7a503          	lw	a0,460(a5)
    8000225a:	01f5571b          	srliw	a4,a0,0x1f
    8000225e:	9f29                	addw	a4,a4,a0
    80002260:	4017571b          	sraiw	a4,a4,0x1
    80002264:	1ce7a623          	sw	a4,460(a5)
    80002268:	b7d9                	j	8000222e <aging_check+0x1e>
}
    8000226a:	6422                	ld	s0,8(sp)
    8000226c:	0141                	addi	sp,sp,16
    8000226e:	8082                	ret

0000000080002270 <scheduler>:
{
    80002270:	7159                	addi	sp,sp,-112
    80002272:	f486                	sd	ra,104(sp)
    80002274:	f0a2                	sd	s0,96(sp)
    80002276:	eca6                	sd	s1,88(sp)
    80002278:	e8ca                	sd	s2,80(sp)
    8000227a:	e4ce                	sd	s3,72(sp)
    8000227c:	e0d2                	sd	s4,64(sp)
    8000227e:	fc56                	sd	s5,56(sp)
    80002280:	f85a                	sd	s6,48(sp)
    80002282:	f45e                	sd	s7,40(sp)
    80002284:	f062                	sd	s8,32(sp)
    80002286:	ec66                	sd	s9,24(sp)
    80002288:	e86a                	sd	s10,16(sp)
    8000228a:	e46e                	sd	s11,8(sp)
    8000228c:	1880                	addi	s0,sp,112
    8000228e:	8792                	mv	a5,tp
	int id = r_tp();
    80002290:	2781                	sext.w	a5,a5
	c->proc = 0;
    80002292:	00779c93          	slli	s9,a5,0x7
    80002296:	0022f717          	auipc	a4,0x22f
    8000229a:	c2270713          	addi	a4,a4,-990 # 80230eb8 <pid_lock>
    8000229e:	9766                	add	a4,a4,s9
    800022a0:	02073823          	sd	zero,48(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800022a4:	10002773          	csrr	a4,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800022a8:	00276713          	ori	a4,a4,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800022ac:	10071073          	csrw	sstatus,a4
					swtch(&c->context, &check->context);
    800022b0:	0022f717          	auipc	a4,0x22f
    800022b4:	c4070713          	addi	a4,a4,-960 # 80230ef0 <cpus+0x8>
    800022b8:	9cba                	add	s9,s9,a4
			min_time = -1;
    800022ba:	5bfd                	li	s7,-1
				for (p = proc; p < &proc[NPROC]; p++)
    800022bc:	00237997          	auipc	s3,0x237
    800022c0:	c2c98993          	addi	s3,s3,-980 # 80238ee8 <tickslock>
					c->proc = check;
    800022c4:	079e                	slli	a5,a5,0x7
    800022c6:	0022fc17          	auipc	s8,0x22f
    800022ca:	bf2c0c13          	addi	s8,s8,-1038 # 80230eb8 <pid_lock>
    800022ce:	9c3e                	add	s8,s8,a5
    800022d0:	a071                	j	8000235c <scheduler+0xec>
							min_time = p->ctime;
    800022d2:	1984ad03          	lw	s10,408(s1)
							continue;
    800022d6:	8b26                	mv	s6,s1
    800022d8:	a031                	j	800022e4 <scheduler+0x74>
					release(&p->lock);
    800022da:	854a                	mv	a0,s2
    800022dc:	fffff097          	auipc	ra,0xfffff
    800022e0:	b80080e7          	jalr	-1152(ra) # 80000e5c <release>
				for (p = proc; p < &proc[NPROC]; p++)
    800022e4:	1f048493          	addi	s1,s1,496
    800022e8:	05348263          	beq	s1,s3,8000232c <scheduler+0xbc>
					acquire(&p->lock);
    800022ec:	00848913          	addi	s2,s1,8
    800022f0:	854a                	mv	a0,s2
    800022f2:	fffff097          	auipc	ra,0xfffff
    800022f6:	ab6080e7          	jalr	-1354(ra) # 80000da8 <acquire>
					if (p->state == RUNNABLE && p->priority_level == i)
    800022fa:	509c                	lw	a5,32(s1)
    800022fc:	fd479fe3          	bne	a5,s4,800022da <scheduler+0x6a>
    80002300:	1c84a783          	lw	a5,456(s1)
    80002304:	fd579be3          	bne	a5,s5,800022da <scheduler+0x6a>
						if (min_time == -1)
    80002308:	fd7d05e3          	beq	s10,s7,800022d2 <scheduler+0x62>
						else if (p->ctime < check->ctime)
    8000230c:	1984a703          	lw	a4,408(s1)
    80002310:	198b2783          	lw	a5,408(s6)
    80002314:	fcf773e3          	bgeu	a4,a5,800022da <scheduler+0x6a>
							release(&check->lock);
    80002318:	008b0513          	addi	a0,s6,8
    8000231c:	fffff097          	auipc	ra,0xfffff
    80002320:	b40080e7          	jalr	-1216(ra) # 80000e5c <release>
							min_time = p->ctime;
    80002324:	1984ad03          	lw	s10,408(s1)
							continue;
    80002328:	8b26                	mv	s6,s1
    8000232a:	bf6d                	j	800022e4 <scheduler+0x74>
				if (min_time == -1)
    8000232c:	057d0b63          	beq	s10,s7,80002382 <scheduler+0x112>
					check->state = RUNNING;
    80002330:	4791                	li	a5,4
    80002332:	02fb2023          	sw	a5,32(s6)
					check->wait_time = 0;
    80002336:	1c0b2823          	sw	zero,464(s6)
					c->proc = check;
    8000233a:	036c3823          	sd	s6,48(s8)
					swtch(&c->context, &check->context);
    8000233e:	068b0593          	addi	a1,s6,104
    80002342:	8566                	mv	a0,s9
    80002344:	00001097          	auipc	ra,0x1
    80002348:	ab4080e7          	jalr	-1356(ra) # 80002df8 <swtch>
					c->proc = 0;
    8000234c:	020c3823          	sd	zero,48(s8)
					release(&check->lock);
    80002350:	008b0513          	addi	a0,s6,8
    80002354:	fffff097          	auipc	ra,0xfffff
    80002358:	b08080e7          	jalr	-1272(ra) # 80000e5c <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000235c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002360:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002364:	10079073          	csrw	sstatus,a5
			aging_check();
    80002368:	00000097          	auipc	ra,0x0
    8000236c:	ea8080e7          	jalr	-344(ra) # 80002210 <aging_check>
			for (int i = 0; i < 4; i++) // FCFS for first 4 levels
    80002370:	4a81                	li	s5,0
			min_time = -1;
    80002372:	8d5e                	mv	s10,s7
					if (p->state == RUNNABLE && p->priority_level == i)
    80002374:	4a0d                	li	s4,3
			for (int i = 0; i < 4; i++) // FCFS for first 4 levels
    80002376:	4d91                	li	s11,4
				for (p = proc; p < &proc[NPROC]; p++)
    80002378:	0022f497          	auipc	s1,0x22f
    8000237c:	f7048493          	addi	s1,s1,-144 # 802312e8 <proc>
    80002380:	b7b5                	j	800022ec <scheduler+0x7c>
			for (int i = 0; i < 4; i++) // FCFS for first 4 levels
    80002382:	2a85                	addiw	s5,s5,1
    80002384:	ffba9ae3          	bne	s5,s11,80002378 <scheduler+0x108>
				for (p = proc; p < &proc[NPROC]; p++)
    80002388:	0022f497          	auipc	s1,0x22f
    8000238c:	f6048493          	addi	s1,s1,-160 # 802312e8 <proc>
					if (p->state == RUNNABLE && p->priority_level == 4)
    80002390:	4a8d                	li	s5,3
    80002392:	4d11                	li	s10,4
						p->state = RUNNING;
    80002394:	4d91                	li	s11,4
    80002396:	a811                	j	800023aa <scheduler+0x13a>
					release(&p->lock);
    80002398:	854a                	mv	a0,s2
    8000239a:	fffff097          	auipc	ra,0xfffff
    8000239e:	ac2080e7          	jalr	-1342(ra) # 80000e5c <release>
				for (p = proc; p < &proc[NPROC]; p++)
    800023a2:	1f048493          	addi	s1,s1,496
    800023a6:	fb348be3          	beq	s1,s3,8000235c <scheduler+0xec>
					acquire(&p->lock);
    800023aa:	00848913          	addi	s2,s1,8
    800023ae:	854a                	mv	a0,s2
    800023b0:	fffff097          	auipc	ra,0xfffff
    800023b4:	9f8080e7          	jalr	-1544(ra) # 80000da8 <acquire>
					if (p->state == RUNNABLE && p->priority_level == 4)
    800023b8:	509c                	lw	a5,32(s1)
    800023ba:	fd579fe3          	bne	a5,s5,80002398 <scheduler+0x128>
    800023be:	1c84a783          	lw	a5,456(s1)
    800023c2:	fda79be3          	bne	a5,s10,80002398 <scheduler+0x128>
						p->state = RUNNING;
    800023c6:	03b4a023          	sw	s11,32(s1)
						c->proc = p;
    800023ca:	029c3823          	sd	s1,48(s8)
						swtch(&c->context, &p->context);
    800023ce:	06848593          	addi	a1,s1,104
    800023d2:	8566                	mv	a0,s9
    800023d4:	00001097          	auipc	ra,0x1
    800023d8:	a24080e7          	jalr	-1500(ra) # 80002df8 <swtch>
						c->proc = 0;
    800023dc:	020c3823          	sd	zero,48(s8)
    800023e0:	bf65                	j	80002398 <scheduler+0x128>

00000000800023e2 <sched>:
{
    800023e2:	7179                	addi	sp,sp,-48
    800023e4:	f406                	sd	ra,40(sp)
    800023e6:	f022                	sd	s0,32(sp)
    800023e8:	ec26                	sd	s1,24(sp)
    800023ea:	e84a                	sd	s2,16(sp)
    800023ec:	e44e                	sd	s3,8(sp)
    800023ee:	1800                	addi	s0,sp,48
	struct proc *p = myproc();
    800023f0:	00000097          	auipc	ra,0x0
    800023f4:	978080e7          	jalr	-1672(ra) # 80001d68 <myproc>
    800023f8:	84aa                	mv	s1,a0
	if (!holding(&p->lock))
    800023fa:	0521                	addi	a0,a0,8
    800023fc:	fffff097          	auipc	ra,0xfffff
    80002400:	932080e7          	jalr	-1742(ra) # 80000d2e <holding>
    80002404:	c93d                	beqz	a0,8000247a <sched+0x98>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002406:	8792                	mv	a5,tp
	if (mycpu()->noff != 1)
    80002408:	2781                	sext.w	a5,a5
    8000240a:	079e                	slli	a5,a5,0x7
    8000240c:	0022f717          	auipc	a4,0x22f
    80002410:	aac70713          	addi	a4,a4,-1364 # 80230eb8 <pid_lock>
    80002414:	97ba                	add	a5,a5,a4
    80002416:	0a87a703          	lw	a4,168(a5)
    8000241a:	4785                	li	a5,1
    8000241c:	06f71763          	bne	a4,a5,8000248a <sched+0xa8>
	if (p->state == RUNNING)
    80002420:	5098                	lw	a4,32(s1)
    80002422:	4791                	li	a5,4
    80002424:	06f70b63          	beq	a4,a5,8000249a <sched+0xb8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002428:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000242c:	8b89                	andi	a5,a5,2
	if (intr_get())
    8000242e:	efb5                	bnez	a5,800024aa <sched+0xc8>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002430:	8792                	mv	a5,tp
	intena = mycpu()->intena;
    80002432:	0022f917          	auipc	s2,0x22f
    80002436:	a8690913          	addi	s2,s2,-1402 # 80230eb8 <pid_lock>
    8000243a:	2781                	sext.w	a5,a5
    8000243c:	079e                	slli	a5,a5,0x7
    8000243e:	97ca                	add	a5,a5,s2
    80002440:	0ac7a983          	lw	s3,172(a5)
    80002444:	8792                	mv	a5,tp
	swtch(&p->context, &mycpu()->context);
    80002446:	2781                	sext.w	a5,a5
    80002448:	079e                	slli	a5,a5,0x7
    8000244a:	0022f597          	auipc	a1,0x22f
    8000244e:	aa658593          	addi	a1,a1,-1370 # 80230ef0 <cpus+0x8>
    80002452:	95be                	add	a1,a1,a5
    80002454:	06848513          	addi	a0,s1,104
    80002458:	00001097          	auipc	ra,0x1
    8000245c:	9a0080e7          	jalr	-1632(ra) # 80002df8 <swtch>
    80002460:	8792                	mv	a5,tp
	mycpu()->intena = intena;
    80002462:	2781                	sext.w	a5,a5
    80002464:	079e                	slli	a5,a5,0x7
    80002466:	97ca                	add	a5,a5,s2
    80002468:	0b37a623          	sw	s3,172(a5)
}
    8000246c:	70a2                	ld	ra,40(sp)
    8000246e:	7402                	ld	s0,32(sp)
    80002470:	64e2                	ld	s1,24(sp)
    80002472:	6942                	ld	s2,16(sp)
    80002474:	69a2                	ld	s3,8(sp)
    80002476:	6145                	addi	sp,sp,48
    80002478:	8082                	ret
		panic("sched p->lock");
    8000247a:	00006517          	auipc	a0,0x6
    8000247e:	de650513          	addi	a0,a0,-538 # 80008260 <digits+0x220>
    80002482:	ffffe097          	auipc	ra,0xffffe
    80002486:	0c2080e7          	jalr	194(ra) # 80000544 <panic>
		panic("sched locks");
    8000248a:	00006517          	auipc	a0,0x6
    8000248e:	de650513          	addi	a0,a0,-538 # 80008270 <digits+0x230>
    80002492:	ffffe097          	auipc	ra,0xffffe
    80002496:	0b2080e7          	jalr	178(ra) # 80000544 <panic>
		panic("sched running");
    8000249a:	00006517          	auipc	a0,0x6
    8000249e:	de650513          	addi	a0,a0,-538 # 80008280 <digits+0x240>
    800024a2:	ffffe097          	auipc	ra,0xffffe
    800024a6:	0a2080e7          	jalr	162(ra) # 80000544 <panic>
		panic("sched interruptible");
    800024aa:	00006517          	auipc	a0,0x6
    800024ae:	de650513          	addi	a0,a0,-538 # 80008290 <digits+0x250>
    800024b2:	ffffe097          	auipc	ra,0xffffe
    800024b6:	092080e7          	jalr	146(ra) # 80000544 <panic>

00000000800024ba <yield>:
{
    800024ba:	1101                	addi	sp,sp,-32
    800024bc:	ec06                	sd	ra,24(sp)
    800024be:	e822                	sd	s0,16(sp)
    800024c0:	e426                	sd	s1,8(sp)
    800024c2:	e04a                	sd	s2,0(sp)
    800024c4:	1000                	addi	s0,sp,32
	struct proc *p = myproc();
    800024c6:	00000097          	auipc	ra,0x0
    800024ca:	8a2080e7          	jalr	-1886(ra) # 80001d68 <myproc>
    800024ce:	84aa                	mv	s1,a0
	acquire(&p->lock);
    800024d0:	00850913          	addi	s2,a0,8
    800024d4:	854a                	mv	a0,s2
    800024d6:	fffff097          	auipc	ra,0xfffff
    800024da:	8d2080e7          	jalr	-1838(ra) # 80000da8 <acquire>
	p->state = RUNNABLE;
    800024de:	478d                	li	a5,3
    800024e0:	d09c                	sw	a5,32(s1)
	sched();
    800024e2:	00000097          	auipc	ra,0x0
    800024e6:	f00080e7          	jalr	-256(ra) # 800023e2 <sched>
	release(&p->lock);
    800024ea:	854a                	mv	a0,s2
    800024ec:	fffff097          	auipc	ra,0xfffff
    800024f0:	970080e7          	jalr	-1680(ra) # 80000e5c <release>
}
    800024f4:	60e2                	ld	ra,24(sp)
    800024f6:	6442                	ld	s0,16(sp)
    800024f8:	64a2                	ld	s1,8(sp)
    800024fa:	6902                	ld	s2,0(sp)
    800024fc:	6105                	addi	sp,sp,32
    800024fe:	8082                	ret

0000000080002500 <fork>:
{
    80002500:	7139                	addi	sp,sp,-64
    80002502:	fc06                	sd	ra,56(sp)
    80002504:	f822                	sd	s0,48(sp)
    80002506:	f426                	sd	s1,40(sp)
    80002508:	f04a                	sd	s2,32(sp)
    8000250a:	ec4e                	sd	s3,24(sp)
    8000250c:	e852                	sd	s4,16(sp)
    8000250e:	e456                	sd	s5,8(sp)
    80002510:	0080                	addi	s0,sp,64
	struct proc *p = myproc();
    80002512:	00000097          	auipc	ra,0x0
    80002516:	856080e7          	jalr	-1962(ra) # 80001d68 <myproc>
    8000251a:	892a                	mv	s2,a0
	if ((np = allocproc()) == 0)
    8000251c:	00000097          	auipc	ra,0x0
    80002520:	a58080e7          	jalr	-1448(ra) # 80001f74 <allocproc>
    80002524:	12050e63          	beqz	a0,80002660 <fork+0x160>
    80002528:	89aa                	mv	s3,a0
	if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    8000252a:	05093603          	ld	a2,80(s2)
    8000252e:	6d2c                	ld	a1,88(a0)
    80002530:	05893503          	ld	a0,88(s2)
    80002534:	fffff097          	auipc	ra,0xfffff
    80002538:	20a080e7          	jalr	522(ra) # 8000173e <uvmcopy>
    8000253c:	04054a63          	bltz	a0,80002590 <fork+0x90>
	np->mask = p->mask; // copying mask so that we can also trace child processes
    80002540:	00092783          	lw	a5,0(s2)
    80002544:	00f9a023          	sw	a5,0(s3)
	np->sz = p->sz;
    80002548:	05093783          	ld	a5,80(s2)
    8000254c:	04f9b823          	sd	a5,80(s3)
	*(np->trapframe) = *(p->trapframe);
    80002550:	06093683          	ld	a3,96(s2)
    80002554:	87b6                	mv	a5,a3
    80002556:	0609b703          	ld	a4,96(s3)
    8000255a:	12068693          	addi	a3,a3,288
    8000255e:	0007b803          	ld	a6,0(a5)
    80002562:	6788                	ld	a0,8(a5)
    80002564:	6b8c                	ld	a1,16(a5)
    80002566:	6f90                	ld	a2,24(a5)
    80002568:	01073023          	sd	a6,0(a4)
    8000256c:	e708                	sd	a0,8(a4)
    8000256e:	eb0c                	sd	a1,16(a4)
    80002570:	ef10                	sd	a2,24(a4)
    80002572:	02078793          	addi	a5,a5,32
    80002576:	02070713          	addi	a4,a4,32
    8000257a:	fed792e3          	bne	a5,a3,8000255e <fork+0x5e>
	np->trapframe->a0 = 0;
    8000257e:	0609b783          	ld	a5,96(s3)
    80002582:	0607b823          	sd	zero,112(a5)
    80002586:	0d800493          	li	s1,216
	for (i = 0; i < NOFILE; i++)
    8000258a:	15800a13          	li	s4,344
    8000258e:	a805                	j	800025be <fork+0xbe>
		freeproc(np);
    80002590:	854e                	mv	a0,s3
    80002592:	00000097          	auipc	ra,0x0
    80002596:	98a080e7          	jalr	-1654(ra) # 80001f1c <freeproc>
		release(&np->lock);
    8000259a:	00898513          	addi	a0,s3,8
    8000259e:	fffff097          	auipc	ra,0xfffff
    800025a2:	8be080e7          	jalr	-1858(ra) # 80000e5c <release>
		return -1;
    800025a6:	5afd                	li	s5,-1
    800025a8:	a859                	j	8000263e <fork+0x13e>
			np->ofile[i] = filedup(p->ofile[i]);
    800025aa:	00003097          	auipc	ra,0x3
    800025ae:	b84080e7          	jalr	-1148(ra) # 8000512e <filedup>
    800025b2:	009987b3          	add	a5,s3,s1
    800025b6:	e388                	sd	a0,0(a5)
	for (i = 0; i < NOFILE; i++)
    800025b8:	04a1                	addi	s1,s1,8
    800025ba:	01448763          	beq	s1,s4,800025c8 <fork+0xc8>
		if (p->ofile[i])
    800025be:	009907b3          	add	a5,s2,s1
    800025c2:	6388                	ld	a0,0(a5)
    800025c4:	f17d                	bnez	a0,800025aa <fork+0xaa>
    800025c6:	bfcd                	j	800025b8 <fork+0xb8>
	np->cwd = idup(p->cwd);
    800025c8:	15893503          	ld	a0,344(s2)
    800025cc:	00002097          	auipc	ra,0x2
    800025d0:	ce8080e7          	jalr	-792(ra) # 800042b4 <idup>
    800025d4:	14a9bc23          	sd	a0,344(s3)
	safestrcpy(np->name, p->name, sizeof(p->name));
    800025d8:	4641                	li	a2,16
    800025da:	16090593          	addi	a1,s2,352
    800025de:	16098513          	addi	a0,s3,352
    800025e2:	fffff097          	auipc	ra,0xfffff
    800025e6:	a14080e7          	jalr	-1516(ra) # 80000ff6 <safestrcpy>
	pid = np->pid;
    800025ea:	0389aa83          	lw	s5,56(s3)
	release(&np->lock);
    800025ee:	00898493          	addi	s1,s3,8
    800025f2:	8526                	mv	a0,s1
    800025f4:	fffff097          	auipc	ra,0xfffff
    800025f8:	868080e7          	jalr	-1944(ra) # 80000e5c <release>
	acquire(&wait_lock);
    800025fc:	0022fa17          	auipc	s4,0x22f
    80002600:	8d4a0a13          	addi	s4,s4,-1836 # 80230ed0 <wait_lock>
    80002604:	8552                	mv	a0,s4
    80002606:	ffffe097          	auipc	ra,0xffffe
    8000260a:	7a2080e7          	jalr	1954(ra) # 80000da8 <acquire>
	np->parent = p;
    8000260e:	0529b023          	sd	s2,64(s3)
	release(&wait_lock);
    80002612:	8552                	mv	a0,s4
    80002614:	fffff097          	auipc	ra,0xfffff
    80002618:	848080e7          	jalr	-1976(ra) # 80000e5c <release>
	acquire(&np->lock);
    8000261c:	8526                	mv	a0,s1
    8000261e:	ffffe097          	auipc	ra,0xffffe
    80002622:	78a080e7          	jalr	1930(ra) # 80000da8 <acquire>
	np->state = RUNNABLE;
    80002626:	478d                	li	a5,3
    80002628:	02f9a023          	sw	a5,32(s3)
	release(&np->lock);
    8000262c:	8526                	mv	a0,s1
    8000262e:	fffff097          	auipc	ra,0xfffff
    80002632:	82e080e7          	jalr	-2002(ra) # 80000e5c <release>
	if (p->priority_level > 0) // pre-empt when a new process enters higher level queue
    80002636:	1c892783          	lw	a5,456(s2)
    8000263a:	00f04c63          	bgtz	a5,80002652 <fork+0x152>
}
    8000263e:	8556                	mv	a0,s5
    80002640:	70e2                	ld	ra,56(sp)
    80002642:	7442                	ld	s0,48(sp)
    80002644:	74a2                	ld	s1,40(sp)
    80002646:	7902                	ld	s2,32(sp)
    80002648:	69e2                	ld	s3,24(sp)
    8000264a:	6a42                	ld	s4,16(sp)
    8000264c:	6aa2                	ld	s5,8(sp)
    8000264e:	6121                	addi	sp,sp,64
    80002650:	8082                	ret
		p->ticks_elapsed = 0;
    80002652:	1c092a23          	sw	zero,468(s2)
		yield();
    80002656:	00000097          	auipc	ra,0x0
    8000265a:	e64080e7          	jalr	-412(ra) # 800024ba <yield>
    8000265e:	b7c5                	j	8000263e <fork+0x13e>
		return -1;
    80002660:	5afd                	li	s5,-1
    80002662:	bff1                	j	8000263e <fork+0x13e>

0000000080002664 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    80002664:	7179                	addi	sp,sp,-48
    80002666:	f406                	sd	ra,40(sp)
    80002668:	f022                	sd	s0,32(sp)
    8000266a:	ec26                	sd	s1,24(sp)
    8000266c:	e84a                	sd	s2,16(sp)
    8000266e:	e44e                	sd	s3,8(sp)
    80002670:	e052                	sd	s4,0(sp)
    80002672:	1800                	addi	s0,sp,48
    80002674:	89aa                	mv	s3,a0
    80002676:	892e                	mv	s2,a1
	struct proc *p = myproc();
    80002678:	fffff097          	auipc	ra,0xfffff
    8000267c:	6f0080e7          	jalr	1776(ra) # 80001d68 <myproc>
    80002680:	84aa                	mv	s1,a0
	// Once we hold p->lock, we can be
	// guaranteed that we won't miss any wakeup
	// (wakeup locks p->lock),
	// so it's okay to release lk.

	acquire(&p->lock); // DOC: sleeplock1
    80002682:	00850a13          	addi	s4,a0,8
    80002686:	8552                	mv	a0,s4
    80002688:	ffffe097          	auipc	ra,0xffffe
    8000268c:	720080e7          	jalr	1824(ra) # 80000da8 <acquire>
	release(lk);
    80002690:	854a                	mv	a0,s2
    80002692:	ffffe097          	auipc	ra,0xffffe
    80002696:	7ca080e7          	jalr	1994(ra) # 80000e5c <release>

	// Go to sleep.
	p->chan = chan;
    8000269a:	0334b423          	sd	s3,40(s1)
	p->state = SLEEPING;
    8000269e:	4789                	li	a5,2
    800026a0:	d09c                	sw	a5,32(s1)

	sched();
    800026a2:	00000097          	auipc	ra,0x0
    800026a6:	d40080e7          	jalr	-704(ra) # 800023e2 <sched>

	// Tidy up.
	p->chan = 0;
    800026aa:	0204b423          	sd	zero,40(s1)

	// Reacquire original lock.
	release(&p->lock);
    800026ae:	8552                	mv	a0,s4
    800026b0:	ffffe097          	auipc	ra,0xffffe
    800026b4:	7ac080e7          	jalr	1964(ra) # 80000e5c <release>
	acquire(lk);
    800026b8:	854a                	mv	a0,s2
    800026ba:	ffffe097          	auipc	ra,0xffffe
    800026be:	6ee080e7          	jalr	1774(ra) # 80000da8 <acquire>
}
    800026c2:	70a2                	ld	ra,40(sp)
    800026c4:	7402                	ld	s0,32(sp)
    800026c6:	64e2                	ld	s1,24(sp)
    800026c8:	6942                	ld	s2,16(sp)
    800026ca:	69a2                	ld	s3,8(sp)
    800026cc:	6a02                	ld	s4,0(sp)
    800026ce:	6145                	addi	sp,sp,48
    800026d0:	8082                	ret

00000000800026d2 <waitx>:
{
    800026d2:	7159                	addi	sp,sp,-112
    800026d4:	f486                	sd	ra,104(sp)
    800026d6:	f0a2                	sd	s0,96(sp)
    800026d8:	eca6                	sd	s1,88(sp)
    800026da:	e8ca                	sd	s2,80(sp)
    800026dc:	e4ce                	sd	s3,72(sp)
    800026de:	e0d2                	sd	s4,64(sp)
    800026e0:	fc56                	sd	s5,56(sp)
    800026e2:	f85a                	sd	s6,48(sp)
    800026e4:	f45e                	sd	s7,40(sp)
    800026e6:	f062                	sd	s8,32(sp)
    800026e8:	ec66                	sd	s9,24(sp)
    800026ea:	e86a                	sd	s10,16(sp)
    800026ec:	e46e                	sd	s11,8(sp)
    800026ee:	1880                	addi	s0,sp,112
    800026f0:	8b2a                	mv	s6,a0
    800026f2:	8bae                	mv	s7,a1
    800026f4:	8c32                	mv	s8,a2
	struct proc *p = myproc();
    800026f6:	fffff097          	auipc	ra,0xfffff
    800026fa:	672080e7          	jalr	1650(ra) # 80001d68 <myproc>
    800026fe:	892a                	mv	s2,a0
	acquire(&wait_lock);
    80002700:	0022e517          	auipc	a0,0x22e
    80002704:	7d050513          	addi	a0,a0,2000 # 80230ed0 <wait_lock>
    80002708:	ffffe097          	auipc	ra,0xffffe
    8000270c:	6a0080e7          	jalr	1696(ra) # 80000da8 <acquire>
		havekids = 0;
    80002710:	4c81                	li	s9,0
				if (np->state == ZOMBIE)
    80002712:	4a15                	li	s4,5
		for (np = proc; np < &proc[NPROC]; np++)
    80002714:	00236997          	auipc	s3,0x236
    80002718:	7d498993          	addi	s3,s3,2004 # 80238ee8 <tickslock>
				havekids = 1;
    8000271c:	4a85                	li	s5,1
		sleep(p, &wait_lock); // DOC: wait-sleep
    8000271e:	0022ed17          	auipc	s10,0x22e
    80002722:	7b2d0d13          	addi	s10,s10,1970 # 80230ed0 <wait_lock>
		havekids = 0;
    80002726:	8766                	mv	a4,s9
		for (np = proc; np < &proc[NPROC]; np++)
    80002728:	0022f497          	auipc	s1,0x22f
    8000272c:	bc048493          	addi	s1,s1,-1088 # 802312e8 <proc>
    80002730:	a059                	j	800027b6 <waitx+0xe4>
					pid = np->pid;
    80002732:	0384a983          	lw	s3,56(s1)
					*rtime = np->runTime;
    80002736:	1a04a703          	lw	a4,416(s1)
    8000273a:	00ec2023          	sw	a4,0(s8)
					*wtime = np->endTime - np->creationTime - np->runTime;
    8000273e:	19c4a783          	lw	a5,412(s1)
    80002742:	9f3d                	addw	a4,a4,a5
    80002744:	1a44a783          	lw	a5,420(s1)
    80002748:	9f99                	subw	a5,a5,a4
    8000274a:	00fba023          	sw	a5,0(s7) # fffffffffffff000 <end+0xffffffff7fdbad38>
					if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000274e:	000b0e63          	beqz	s6,8000276a <waitx+0x98>
    80002752:	4691                	li	a3,4
    80002754:	03448613          	addi	a2,s1,52
    80002758:	85da                	mv	a1,s6
    8000275a:	05893503          	ld	a0,88(s2)
    8000275e:	fffff097          	auipc	ra,0xfffff
    80002762:	0da080e7          	jalr	218(ra) # 80001838 <copyout>
    80002766:	02054563          	bltz	a0,80002790 <waitx+0xbe>
					freeproc(np);
    8000276a:	8526                	mv	a0,s1
    8000276c:	fffff097          	auipc	ra,0xfffff
    80002770:	7b0080e7          	jalr	1968(ra) # 80001f1c <freeproc>
					release(&np->lock);
    80002774:	856e                	mv	a0,s11
    80002776:	ffffe097          	auipc	ra,0xffffe
    8000277a:	6e6080e7          	jalr	1766(ra) # 80000e5c <release>
					release(&wait_lock);
    8000277e:	0022e517          	auipc	a0,0x22e
    80002782:	75250513          	addi	a0,a0,1874 # 80230ed0 <wait_lock>
    80002786:	ffffe097          	auipc	ra,0xffffe
    8000278a:	6d6080e7          	jalr	1750(ra) # 80000e5c <release>
					return pid;
    8000278e:	a0ad                	j	800027f8 <waitx+0x126>
						release(&np->lock);
    80002790:	856e                	mv	a0,s11
    80002792:	ffffe097          	auipc	ra,0xffffe
    80002796:	6ca080e7          	jalr	1738(ra) # 80000e5c <release>
						release(&wait_lock);
    8000279a:	0022e517          	auipc	a0,0x22e
    8000279e:	73650513          	addi	a0,a0,1846 # 80230ed0 <wait_lock>
    800027a2:	ffffe097          	auipc	ra,0xffffe
    800027a6:	6ba080e7          	jalr	1722(ra) # 80000e5c <release>
						return -1;
    800027aa:	59fd                	li	s3,-1
    800027ac:	a0b1                	j	800027f8 <waitx+0x126>
		for (np = proc; np < &proc[NPROC]; np++)
    800027ae:	1f048493          	addi	s1,s1,496
    800027b2:	03348663          	beq	s1,s3,800027de <waitx+0x10c>
			if (np->parent == p)
    800027b6:	60bc                	ld	a5,64(s1)
    800027b8:	ff279be3          	bne	a5,s2,800027ae <waitx+0xdc>
				acquire(&np->lock);
    800027bc:	00848d93          	addi	s11,s1,8
    800027c0:	856e                	mv	a0,s11
    800027c2:	ffffe097          	auipc	ra,0xffffe
    800027c6:	5e6080e7          	jalr	1510(ra) # 80000da8 <acquire>
				if (np->state == ZOMBIE)
    800027ca:	509c                	lw	a5,32(s1)
    800027cc:	f74783e3          	beq	a5,s4,80002732 <waitx+0x60>
				release(&np->lock);
    800027d0:	856e                	mv	a0,s11
    800027d2:	ffffe097          	auipc	ra,0xffffe
    800027d6:	68a080e7          	jalr	1674(ra) # 80000e5c <release>
				havekids = 1;
    800027da:	8756                	mv	a4,s5
    800027dc:	bfc9                	j	800027ae <waitx+0xdc>
		if (!havekids || p->killed)
    800027de:	c701                	beqz	a4,800027e6 <waitx+0x114>
    800027e0:	03092783          	lw	a5,48(s2)
    800027e4:	cb95                	beqz	a5,80002818 <waitx+0x146>
			release(&wait_lock);
    800027e6:	0022e517          	auipc	a0,0x22e
    800027ea:	6ea50513          	addi	a0,a0,1770 # 80230ed0 <wait_lock>
    800027ee:	ffffe097          	auipc	ra,0xffffe
    800027f2:	66e080e7          	jalr	1646(ra) # 80000e5c <release>
			return -1;
    800027f6:	59fd                	li	s3,-1
}
    800027f8:	854e                	mv	a0,s3
    800027fa:	70a6                	ld	ra,104(sp)
    800027fc:	7406                	ld	s0,96(sp)
    800027fe:	64e6                	ld	s1,88(sp)
    80002800:	6946                	ld	s2,80(sp)
    80002802:	69a6                	ld	s3,72(sp)
    80002804:	6a06                	ld	s4,64(sp)
    80002806:	7ae2                	ld	s5,56(sp)
    80002808:	7b42                	ld	s6,48(sp)
    8000280a:	7ba2                	ld	s7,40(sp)
    8000280c:	7c02                	ld	s8,32(sp)
    8000280e:	6ce2                	ld	s9,24(sp)
    80002810:	6d42                	ld	s10,16(sp)
    80002812:	6da2                	ld	s11,8(sp)
    80002814:	6165                	addi	sp,sp,112
    80002816:	8082                	ret
		sleep(p, &wait_lock); // DOC: wait-sleep
    80002818:	85ea                	mv	a1,s10
    8000281a:	854a                	mv	a0,s2
    8000281c:	00000097          	auipc	ra,0x0
    80002820:	e48080e7          	jalr	-440(ra) # 80002664 <sleep>
		havekids = 0;
    80002824:	b709                	j	80002726 <waitx+0x54>

0000000080002826 <wait>:
{
    80002826:	711d                	addi	sp,sp,-96
    80002828:	ec86                	sd	ra,88(sp)
    8000282a:	e8a2                	sd	s0,80(sp)
    8000282c:	e4a6                	sd	s1,72(sp)
    8000282e:	e0ca                	sd	s2,64(sp)
    80002830:	fc4e                	sd	s3,56(sp)
    80002832:	f852                	sd	s4,48(sp)
    80002834:	f456                	sd	s5,40(sp)
    80002836:	f05a                	sd	s6,32(sp)
    80002838:	ec5e                	sd	s7,24(sp)
    8000283a:	e862                	sd	s8,16(sp)
    8000283c:	e466                	sd	s9,8(sp)
    8000283e:	1080                	addi	s0,sp,96
    80002840:	8baa                	mv	s7,a0
	struct proc *p = myproc();
    80002842:	fffff097          	auipc	ra,0xfffff
    80002846:	526080e7          	jalr	1318(ra) # 80001d68 <myproc>
    8000284a:	892a                	mv	s2,a0
	acquire(&wait_lock);
    8000284c:	0022e517          	auipc	a0,0x22e
    80002850:	68450513          	addi	a0,a0,1668 # 80230ed0 <wait_lock>
    80002854:	ffffe097          	auipc	ra,0xffffe
    80002858:	554080e7          	jalr	1364(ra) # 80000da8 <acquire>
		havekids = 0;
    8000285c:	4c01                	li	s8,0
				if (pp->state == ZOMBIE)
    8000285e:	4a95                	li	s5,5
		for (pp = proc; pp < &proc[NPROC]; pp++)
    80002860:	00236997          	auipc	s3,0x236
    80002864:	68898993          	addi	s3,s3,1672 # 80238ee8 <tickslock>
				havekids = 1;
    80002868:	4b05                	li	s6,1
		sleep(p, &wait_lock); // DOC: wait-sleep
    8000286a:	0022ec97          	auipc	s9,0x22e
    8000286e:	666c8c93          	addi	s9,s9,1638 # 80230ed0 <wait_lock>
		havekids = 0;
    80002872:	8762                	mv	a4,s8
		for (pp = proc; pp < &proc[NPROC]; pp++)
    80002874:	0022f497          	auipc	s1,0x22f
    80002878:	a7448493          	addi	s1,s1,-1420 # 802312e8 <proc>
    8000287c:	a8ad                	j	800028f6 <wait+0xd0>
					pid = pp->pid;
    8000287e:	0384a983          	lw	s3,56(s1)
					if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002882:	000b8e63          	beqz	s7,8000289e <wait+0x78>
    80002886:	4691                	li	a3,4
    80002888:	03448613          	addi	a2,s1,52
    8000288c:	85de                	mv	a1,s7
    8000288e:	05893503          	ld	a0,88(s2)
    80002892:	fffff097          	auipc	ra,0xfffff
    80002896:	fa6080e7          	jalr	-90(ra) # 80001838 <copyout>
    8000289a:	02054b63          	bltz	a0,800028d0 <wait+0xaa>
					freeproc(pp);
    8000289e:	8526                	mv	a0,s1
    800028a0:	fffff097          	auipc	ra,0xfffff
    800028a4:	67c080e7          	jalr	1660(ra) # 80001f1c <freeproc>
					release(&pp->lock);
    800028a8:	8552                	mv	a0,s4
    800028aa:	ffffe097          	auipc	ra,0xffffe
    800028ae:	5b2080e7          	jalr	1458(ra) # 80000e5c <release>
					release(&wait_lock);
    800028b2:	0022e517          	auipc	a0,0x22e
    800028b6:	61e50513          	addi	a0,a0,1566 # 80230ed0 <wait_lock>
    800028ba:	ffffe097          	auipc	ra,0xffffe
    800028be:	5a2080e7          	jalr	1442(ra) # 80000e5c <release>
					pp->endTime = ticks;
    800028c2:	00006797          	auipc	a5,0x6
    800028c6:	36e7a783          	lw	a5,878(a5) # 80008c30 <ticks>
    800028ca:	1af4a223          	sw	a5,420(s1)
					return pid;
    800028ce:	a0ad                	j	80002938 <wait+0x112>
						release(&pp->lock);
    800028d0:	8552                	mv	a0,s4
    800028d2:	ffffe097          	auipc	ra,0xffffe
    800028d6:	58a080e7          	jalr	1418(ra) # 80000e5c <release>
						release(&wait_lock);
    800028da:	0022e517          	auipc	a0,0x22e
    800028de:	5f650513          	addi	a0,a0,1526 # 80230ed0 <wait_lock>
    800028e2:	ffffe097          	auipc	ra,0xffffe
    800028e6:	57a080e7          	jalr	1402(ra) # 80000e5c <release>
						return -1;
    800028ea:	59fd                	li	s3,-1
    800028ec:	a0b1                	j	80002938 <wait+0x112>
		for (pp = proc; pp < &proc[NPROC]; pp++)
    800028ee:	1f048493          	addi	s1,s1,496
    800028f2:	03348663          	beq	s1,s3,8000291e <wait+0xf8>
			if (pp->parent == p)
    800028f6:	60bc                	ld	a5,64(s1)
    800028f8:	ff279be3          	bne	a5,s2,800028ee <wait+0xc8>
				acquire(&pp->lock);
    800028fc:	00848a13          	addi	s4,s1,8
    80002900:	8552                	mv	a0,s4
    80002902:	ffffe097          	auipc	ra,0xffffe
    80002906:	4a6080e7          	jalr	1190(ra) # 80000da8 <acquire>
				if (pp->state == ZOMBIE)
    8000290a:	509c                	lw	a5,32(s1)
    8000290c:	f75789e3          	beq	a5,s5,8000287e <wait+0x58>
				release(&pp->lock);
    80002910:	8552                	mv	a0,s4
    80002912:	ffffe097          	auipc	ra,0xffffe
    80002916:	54a080e7          	jalr	1354(ra) # 80000e5c <release>
				havekids = 1;
    8000291a:	875a                	mv	a4,s6
    8000291c:	bfc9                	j	800028ee <wait+0xc8>
		if (!havekids || p->killed)
    8000291e:	c701                	beqz	a4,80002926 <wait+0x100>
    80002920:	03092783          	lw	a5,48(s2)
    80002924:	cb85                	beqz	a5,80002954 <wait+0x12e>
			release(&wait_lock);
    80002926:	0022e517          	auipc	a0,0x22e
    8000292a:	5aa50513          	addi	a0,a0,1450 # 80230ed0 <wait_lock>
    8000292e:	ffffe097          	auipc	ra,0xffffe
    80002932:	52e080e7          	jalr	1326(ra) # 80000e5c <release>
			return -1;
    80002936:	59fd                	li	s3,-1
}
    80002938:	854e                	mv	a0,s3
    8000293a:	60e6                	ld	ra,88(sp)
    8000293c:	6446                	ld	s0,80(sp)
    8000293e:	64a6                	ld	s1,72(sp)
    80002940:	6906                	ld	s2,64(sp)
    80002942:	79e2                	ld	s3,56(sp)
    80002944:	7a42                	ld	s4,48(sp)
    80002946:	7aa2                	ld	s5,40(sp)
    80002948:	7b02                	ld	s6,32(sp)
    8000294a:	6be2                	ld	s7,24(sp)
    8000294c:	6c42                	ld	s8,16(sp)
    8000294e:	6ca2                	ld	s9,8(sp)
    80002950:	6125                	addi	sp,sp,96
    80002952:	8082                	ret
		sleep(p, &wait_lock); // DOC: wait-sleep
    80002954:	85e6                	mv	a1,s9
    80002956:	854a                	mv	a0,s2
    80002958:	00000097          	auipc	ra,0x0
    8000295c:	d0c080e7          	jalr	-756(ra) # 80002664 <sleep>
		havekids = 0;
    80002960:	bf09                	j	80002872 <wait+0x4c>

0000000080002962 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    80002962:	715d                	addi	sp,sp,-80
    80002964:	e486                	sd	ra,72(sp)
    80002966:	e0a2                	sd	s0,64(sp)
    80002968:	fc26                	sd	s1,56(sp)
    8000296a:	f84a                	sd	s2,48(sp)
    8000296c:	f44e                	sd	s3,40(sp)
    8000296e:	f052                	sd	s4,32(sp)
    80002970:	ec56                	sd	s5,24(sp)
    80002972:	e85a                	sd	s6,16(sp)
    80002974:	e45e                	sd	s7,8(sp)
    80002976:	0880                	addi	s0,sp,80
    80002978:	8aaa                	mv	s5,a0
	struct proc *p;

	for (p = proc; p < &proc[NPROC]; p++)
    8000297a:	0022f497          	auipc	s1,0x22f
    8000297e:	96e48493          	addi	s1,s1,-1682 # 802312e8 <proc>
	{
		if (p != myproc())
		{
			acquire(&p->lock);
			if (p->state == SLEEPING && p->chan == chan)
    80002982:	4a09                	li	s4,2
			{
				p->state = RUNNABLE;
    80002984:	4b0d                	li	s6,3
				p->time_spent = 0;
#endif
				// #ifdef PBS
				if (p->sleepStartTime != 0)
				{
					p->sleepTimePrev = ticks - p->sleepStartTime;
    80002986:	00006b97          	auipc	s7,0x6
    8000298a:	2aab8b93          	addi	s7,s7,682 # 80008c30 <ticks>
	for (p = proc; p < &proc[NPROC]; p++)
    8000298e:	00236997          	auipc	s3,0x236
    80002992:	55a98993          	addi	s3,s3,1370 # 80238ee8 <tickslock>
    80002996:	a821                	j	800029ae <wakeup+0x4c>
					p->totalSleep += p->sleepTimePrev;
				}
// #endif
#ifdef MLFQ
				p->ticks_elapsed = 0;
    80002998:	1c04aa23          	sw	zero,468(s1)
#endif
			}
			release(&p->lock);
    8000299c:	854a                	mv	a0,s2
    8000299e:	ffffe097          	auipc	ra,0xffffe
    800029a2:	4be080e7          	jalr	1214(ra) # 80000e5c <release>
	for (p = proc; p < &proc[NPROC]; p++)
    800029a6:	1f048493          	addi	s1,s1,496
    800029aa:	05348663          	beq	s1,s3,800029f6 <wakeup+0x94>
		if (p != myproc())
    800029ae:	fffff097          	auipc	ra,0xfffff
    800029b2:	3ba080e7          	jalr	954(ra) # 80001d68 <myproc>
    800029b6:	fea488e3          	beq	s1,a0,800029a6 <wakeup+0x44>
			acquire(&p->lock);
    800029ba:	00848913          	addi	s2,s1,8
    800029be:	854a                	mv	a0,s2
    800029c0:	ffffe097          	auipc	ra,0xffffe
    800029c4:	3e8080e7          	jalr	1000(ra) # 80000da8 <acquire>
			if (p->state == SLEEPING && p->chan == chan)
    800029c8:	509c                	lw	a5,32(s1)
    800029ca:	fd4799e3          	bne	a5,s4,8000299c <wakeup+0x3a>
    800029ce:	749c                	ld	a5,40(s1)
    800029d0:	fd5796e3          	bne	a5,s5,8000299c <wakeup+0x3a>
				p->state = RUNNABLE;
    800029d4:	0364a023          	sw	s6,32(s1)
				if (p->sleepStartTime != 0)
    800029d8:	1b04a783          	lw	a5,432(s1)
    800029dc:	dfd5                	beqz	a5,80002998 <wakeup+0x36>
					p->sleepTimePrev = ticks - p->sleepStartTime;
    800029de:	000ba703          	lw	a4,0(s7)
    800029e2:	40f707bb          	subw	a5,a4,a5
    800029e6:	1af4a623          	sw	a5,428(s1)
					p->totalSleep += p->sleepTimePrev;
    800029ea:	1a84a703          	lw	a4,424(s1)
    800029ee:	9fb9                	addw	a5,a5,a4
    800029f0:	1af4a423          	sw	a5,424(s1)
    800029f4:	b755                	j	80002998 <wakeup+0x36>
		}
	}
}
    800029f6:	60a6                	ld	ra,72(sp)
    800029f8:	6406                	ld	s0,64(sp)
    800029fa:	74e2                	ld	s1,56(sp)
    800029fc:	7942                	ld	s2,48(sp)
    800029fe:	79a2                	ld	s3,40(sp)
    80002a00:	7a02                	ld	s4,32(sp)
    80002a02:	6ae2                	ld	s5,24(sp)
    80002a04:	6b42                	ld	s6,16(sp)
    80002a06:	6ba2                	ld	s7,8(sp)
    80002a08:	6161                	addi	sp,sp,80
    80002a0a:	8082                	ret

0000000080002a0c <reparent>:
{
    80002a0c:	7179                	addi	sp,sp,-48
    80002a0e:	f406                	sd	ra,40(sp)
    80002a10:	f022                	sd	s0,32(sp)
    80002a12:	ec26                	sd	s1,24(sp)
    80002a14:	e84a                	sd	s2,16(sp)
    80002a16:	e44e                	sd	s3,8(sp)
    80002a18:	e052                	sd	s4,0(sp)
    80002a1a:	1800                	addi	s0,sp,48
    80002a1c:	892a                	mv	s2,a0
	for (pp = proc; pp < &proc[NPROC]; pp++)
    80002a1e:	0022f497          	auipc	s1,0x22f
    80002a22:	8ca48493          	addi	s1,s1,-1846 # 802312e8 <proc>
			pp->parent = initproc;
    80002a26:	00006a17          	auipc	s4,0x6
    80002a2a:	202a0a13          	addi	s4,s4,514 # 80008c28 <initproc>
	for (pp = proc; pp < &proc[NPROC]; pp++)
    80002a2e:	00236997          	auipc	s3,0x236
    80002a32:	4ba98993          	addi	s3,s3,1210 # 80238ee8 <tickslock>
    80002a36:	a029                	j	80002a40 <reparent+0x34>
    80002a38:	1f048493          	addi	s1,s1,496
    80002a3c:	01348d63          	beq	s1,s3,80002a56 <reparent+0x4a>
		if (pp->parent == p)
    80002a40:	60bc                	ld	a5,64(s1)
    80002a42:	ff279be3          	bne	a5,s2,80002a38 <reparent+0x2c>
			pp->parent = initproc;
    80002a46:	000a3503          	ld	a0,0(s4)
    80002a4a:	e0a8                	sd	a0,64(s1)
			wakeup(initproc);
    80002a4c:	00000097          	auipc	ra,0x0
    80002a50:	f16080e7          	jalr	-234(ra) # 80002962 <wakeup>
    80002a54:	b7d5                	j	80002a38 <reparent+0x2c>
}
    80002a56:	70a2                	ld	ra,40(sp)
    80002a58:	7402                	ld	s0,32(sp)
    80002a5a:	64e2                	ld	s1,24(sp)
    80002a5c:	6942                	ld	s2,16(sp)
    80002a5e:	69a2                	ld	s3,8(sp)
    80002a60:	6a02                	ld	s4,0(sp)
    80002a62:	6145                	addi	sp,sp,48
    80002a64:	8082                	ret

0000000080002a66 <exit>:
{
    80002a66:	7179                	addi	sp,sp,-48
    80002a68:	f406                	sd	ra,40(sp)
    80002a6a:	f022                	sd	s0,32(sp)
    80002a6c:	ec26                	sd	s1,24(sp)
    80002a6e:	e84a                	sd	s2,16(sp)
    80002a70:	e44e                	sd	s3,8(sp)
    80002a72:	e052                	sd	s4,0(sp)
    80002a74:	1800                	addi	s0,sp,48
    80002a76:	8a2a                	mv	s4,a0
	struct proc *p = myproc();
    80002a78:	fffff097          	auipc	ra,0xfffff
    80002a7c:	2f0080e7          	jalr	752(ra) # 80001d68 <myproc>
    80002a80:	89aa                	mv	s3,a0
	if (p == initproc)
    80002a82:	00006797          	auipc	a5,0x6
    80002a86:	1a67b783          	ld	a5,422(a5) # 80008c28 <initproc>
    80002a8a:	0d850493          	addi	s1,a0,216
    80002a8e:	15850913          	addi	s2,a0,344
    80002a92:	02a79363          	bne	a5,a0,80002ab8 <exit+0x52>
		panic("init exiting");
    80002a96:	00006517          	auipc	a0,0x6
    80002a9a:	81250513          	addi	a0,a0,-2030 # 800082a8 <digits+0x268>
    80002a9e:	ffffe097          	auipc	ra,0xffffe
    80002aa2:	aa6080e7          	jalr	-1370(ra) # 80000544 <panic>
			fileclose(f);
    80002aa6:	00002097          	auipc	ra,0x2
    80002aaa:	6da080e7          	jalr	1754(ra) # 80005180 <fileclose>
			p->ofile[fd] = 0;
    80002aae:	0004b023          	sd	zero,0(s1)
	for (int fd = 0; fd < NOFILE; fd++)
    80002ab2:	04a1                	addi	s1,s1,8
    80002ab4:	01248563          	beq	s1,s2,80002abe <exit+0x58>
		if (p->ofile[fd])
    80002ab8:	6088                	ld	a0,0(s1)
    80002aba:	f575                	bnez	a0,80002aa6 <exit+0x40>
    80002abc:	bfdd                	j	80002ab2 <exit+0x4c>
	begin_op();
    80002abe:	00002097          	auipc	ra,0x2
    80002ac2:	1f6080e7          	jalr	502(ra) # 80004cb4 <begin_op>
	iput(p->cwd);
    80002ac6:	1589b503          	ld	a0,344(s3)
    80002aca:	00002097          	auipc	ra,0x2
    80002ace:	9e2080e7          	jalr	-1566(ra) # 800044ac <iput>
	end_op();
    80002ad2:	00002097          	auipc	ra,0x2
    80002ad6:	262080e7          	jalr	610(ra) # 80004d34 <end_op>
	p->cwd = 0;
    80002ada:	1409bc23          	sd	zero,344(s3)
	acquire(&wait_lock);
    80002ade:	0022e497          	auipc	s1,0x22e
    80002ae2:	3f248493          	addi	s1,s1,1010 # 80230ed0 <wait_lock>
    80002ae6:	8526                	mv	a0,s1
    80002ae8:	ffffe097          	auipc	ra,0xffffe
    80002aec:	2c0080e7          	jalr	704(ra) # 80000da8 <acquire>
	reparent(p);
    80002af0:	854e                	mv	a0,s3
    80002af2:	00000097          	auipc	ra,0x0
    80002af6:	f1a080e7          	jalr	-230(ra) # 80002a0c <reparent>
	wakeup(p->parent);
    80002afa:	0409b503          	ld	a0,64(s3)
    80002afe:	00000097          	auipc	ra,0x0
    80002b02:	e64080e7          	jalr	-412(ra) # 80002962 <wakeup>
	acquire(&p->lock);
    80002b06:	00898513          	addi	a0,s3,8
    80002b0a:	ffffe097          	auipc	ra,0xffffe
    80002b0e:	29e080e7          	jalr	670(ra) # 80000da8 <acquire>
	p->xstate = status;
    80002b12:	0349aa23          	sw	s4,52(s3)
	p->state = ZOMBIE;
    80002b16:	4795                	li	a5,5
    80002b18:	02f9a023          	sw	a5,32(s3)
	p->endTime = ticks;
    80002b1c:	00006797          	auipc	a5,0x6
    80002b20:	1147a783          	lw	a5,276(a5) # 80008c30 <ticks>
    80002b24:	1af9a223          	sw	a5,420(s3)
	release(&wait_lock);
    80002b28:	8526                	mv	a0,s1
    80002b2a:	ffffe097          	auipc	ra,0xffffe
    80002b2e:	332080e7          	jalr	818(ra) # 80000e5c <release>
	sched();
    80002b32:	00000097          	auipc	ra,0x0
    80002b36:	8b0080e7          	jalr	-1872(ra) # 800023e2 <sched>
	panic("zombie exit");
    80002b3a:	00005517          	auipc	a0,0x5
    80002b3e:	77e50513          	addi	a0,a0,1918 # 800082b8 <digits+0x278>
    80002b42:	ffffe097          	auipc	ra,0xffffe
    80002b46:	a02080e7          	jalr	-1534(ra) # 80000544 <panic>

0000000080002b4a <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    80002b4a:	7179                	addi	sp,sp,-48
    80002b4c:	f406                	sd	ra,40(sp)
    80002b4e:	f022                	sd	s0,32(sp)
    80002b50:	ec26                	sd	s1,24(sp)
    80002b52:	e84a                	sd	s2,16(sp)
    80002b54:	e44e                	sd	s3,8(sp)
    80002b56:	e052                	sd	s4,0(sp)
    80002b58:	1800                	addi	s0,sp,48
    80002b5a:	89aa                	mv	s3,a0
	struct proc *p;

	for (p = proc; p < &proc[NPROC]; p++)
    80002b5c:	0022e497          	auipc	s1,0x22e
    80002b60:	78c48493          	addi	s1,s1,1932 # 802312e8 <proc>
    80002b64:	00236a17          	auipc	s4,0x236
    80002b68:	384a0a13          	addi	s4,s4,900 # 80238ee8 <tickslock>
	{
		acquire(&p->lock);
    80002b6c:	00848913          	addi	s2,s1,8
    80002b70:	854a                	mv	a0,s2
    80002b72:	ffffe097          	auipc	ra,0xffffe
    80002b76:	236080e7          	jalr	566(ra) # 80000da8 <acquire>
		if (p->pid == pid)
    80002b7a:	5c9c                	lw	a5,56(s1)
    80002b7c:	01378d63          	beq	a5,s3,80002b96 <kill+0x4c>
#endif
			}
			release(&p->lock);
			return 0;
		}
		release(&p->lock);
    80002b80:	854a                	mv	a0,s2
    80002b82:	ffffe097          	auipc	ra,0xffffe
    80002b86:	2da080e7          	jalr	730(ra) # 80000e5c <release>
	for (p = proc; p < &proc[NPROC]; p++)
    80002b8a:	1f048493          	addi	s1,s1,496
    80002b8e:	fd449fe3          	bne	s1,s4,80002b6c <kill+0x22>
	}
	return -1;
    80002b92:	557d                	li	a0,-1
    80002b94:	a829                	j	80002bae <kill+0x64>
			p->killed = 1;
    80002b96:	4785                	li	a5,1
    80002b98:	d89c                	sw	a5,48(s1)
			if (p->state == SLEEPING)
    80002b9a:	5098                	lw	a4,32(s1)
    80002b9c:	4789                	li	a5,2
    80002b9e:	02f70063          	beq	a4,a5,80002bbe <kill+0x74>
			release(&p->lock);
    80002ba2:	854a                	mv	a0,s2
    80002ba4:	ffffe097          	auipc	ra,0xffffe
    80002ba8:	2b8080e7          	jalr	696(ra) # 80000e5c <release>
			return 0;
    80002bac:	4501                	li	a0,0
}
    80002bae:	70a2                	ld	ra,40(sp)
    80002bb0:	7402                	ld	s0,32(sp)
    80002bb2:	64e2                	ld	s1,24(sp)
    80002bb4:	6942                	ld	s2,16(sp)
    80002bb6:	69a2                	ld	s3,8(sp)
    80002bb8:	6a02                	ld	s4,0(sp)
    80002bba:	6145                	addi	sp,sp,48
    80002bbc:	8082                	ret
				p->sleepTimePrev = ticks - p->sleepStartTime;
    80002bbe:	1b04a703          	lw	a4,432(s1)
    80002bc2:	00006797          	auipc	a5,0x6
    80002bc6:	06e7a783          	lw	a5,110(a5) # 80008c30 <ticks>
    80002bca:	9f99                	subw	a5,a5,a4
    80002bcc:	1af4a623          	sw	a5,428(s1)
				p->state = RUNNABLE;
    80002bd0:	478d                	li	a5,3
    80002bd2:	d09c                	sw	a5,32(s1)
				p->ticks_elapsed = 0;
    80002bd4:	1c04aa23          	sw	zero,468(s1)
    80002bd8:	b7e9                	j	80002ba2 <kill+0x58>

0000000080002bda <setkilled>:

void setkilled(struct proc *p)
{
    80002bda:	1101                	addi	sp,sp,-32
    80002bdc:	ec06                	sd	ra,24(sp)
    80002bde:	e822                	sd	s0,16(sp)
    80002be0:	e426                	sd	s1,8(sp)
    80002be2:	e04a                	sd	s2,0(sp)
    80002be4:	1000                	addi	s0,sp,32
    80002be6:	84aa                	mv	s1,a0
	acquire(&p->lock);
    80002be8:	00850913          	addi	s2,a0,8
    80002bec:	854a                	mv	a0,s2
    80002bee:	ffffe097          	auipc	ra,0xffffe
    80002bf2:	1ba080e7          	jalr	442(ra) # 80000da8 <acquire>
	p->killed = 1;
    80002bf6:	4785                	li	a5,1
    80002bf8:	d89c                	sw	a5,48(s1)
	release(&p->lock);
    80002bfa:	854a                	mv	a0,s2
    80002bfc:	ffffe097          	auipc	ra,0xffffe
    80002c00:	260080e7          	jalr	608(ra) # 80000e5c <release>
}
    80002c04:	60e2                	ld	ra,24(sp)
    80002c06:	6442                	ld	s0,16(sp)
    80002c08:	64a2                	ld	s1,8(sp)
    80002c0a:	6902                	ld	s2,0(sp)
    80002c0c:	6105                	addi	sp,sp,32
    80002c0e:	8082                	ret

0000000080002c10 <killed>:

int killed(struct proc *p)
{
    80002c10:	1101                	addi	sp,sp,-32
    80002c12:	ec06                	sd	ra,24(sp)
    80002c14:	e822                	sd	s0,16(sp)
    80002c16:	e426                	sd	s1,8(sp)
    80002c18:	e04a                	sd	s2,0(sp)
    80002c1a:	1000                	addi	s0,sp,32
    80002c1c:	84aa                	mv	s1,a0
	int k;

	acquire(&p->lock);
    80002c1e:	00850913          	addi	s2,a0,8
    80002c22:	854a                	mv	a0,s2
    80002c24:	ffffe097          	auipc	ra,0xffffe
    80002c28:	184080e7          	jalr	388(ra) # 80000da8 <acquire>
	k = p->killed;
    80002c2c:	5884                	lw	s1,48(s1)
	release(&p->lock);
    80002c2e:	854a                	mv	a0,s2
    80002c30:	ffffe097          	auipc	ra,0xffffe
    80002c34:	22c080e7          	jalr	556(ra) # 80000e5c <release>
	return k;
}
    80002c38:	8526                	mv	a0,s1
    80002c3a:	60e2                	ld	ra,24(sp)
    80002c3c:	6442                	ld	s0,16(sp)
    80002c3e:	64a2                	ld	s1,8(sp)
    80002c40:	6902                	ld	s2,0(sp)
    80002c42:	6105                	addi	sp,sp,32
    80002c44:	8082                	ret

0000000080002c46 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002c46:	7179                	addi	sp,sp,-48
    80002c48:	f406                	sd	ra,40(sp)
    80002c4a:	f022                	sd	s0,32(sp)
    80002c4c:	ec26                	sd	s1,24(sp)
    80002c4e:	e84a                	sd	s2,16(sp)
    80002c50:	e44e                	sd	s3,8(sp)
    80002c52:	e052                	sd	s4,0(sp)
    80002c54:	1800                	addi	s0,sp,48
    80002c56:	84aa                	mv	s1,a0
    80002c58:	892e                	mv	s2,a1
    80002c5a:	89b2                	mv	s3,a2
    80002c5c:	8a36                	mv	s4,a3
	struct proc *p = myproc();
    80002c5e:	fffff097          	auipc	ra,0xfffff
    80002c62:	10a080e7          	jalr	266(ra) # 80001d68 <myproc>
	if (user_dst)
    80002c66:	c08d                	beqz	s1,80002c88 <either_copyout+0x42>
	{
		return copyout(p->pagetable, dst, src, len);
    80002c68:	86d2                	mv	a3,s4
    80002c6a:	864e                	mv	a2,s3
    80002c6c:	85ca                	mv	a1,s2
    80002c6e:	6d28                	ld	a0,88(a0)
    80002c70:	fffff097          	auipc	ra,0xfffff
    80002c74:	bc8080e7          	jalr	-1080(ra) # 80001838 <copyout>
	else
	{
		memmove((char *)dst, src, len);
		return 0;
	}
}
    80002c78:	70a2                	ld	ra,40(sp)
    80002c7a:	7402                	ld	s0,32(sp)
    80002c7c:	64e2                	ld	s1,24(sp)
    80002c7e:	6942                	ld	s2,16(sp)
    80002c80:	69a2                	ld	s3,8(sp)
    80002c82:	6a02                	ld	s4,0(sp)
    80002c84:	6145                	addi	sp,sp,48
    80002c86:	8082                	ret
		memmove((char *)dst, src, len);
    80002c88:	000a061b          	sext.w	a2,s4
    80002c8c:	85ce                	mv	a1,s3
    80002c8e:	854a                	mv	a0,s2
    80002c90:	ffffe097          	auipc	ra,0xffffe
    80002c94:	274080e7          	jalr	628(ra) # 80000f04 <memmove>
		return 0;
    80002c98:	8526                	mv	a0,s1
    80002c9a:	bff9                	j	80002c78 <either_copyout+0x32>

0000000080002c9c <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002c9c:	7179                	addi	sp,sp,-48
    80002c9e:	f406                	sd	ra,40(sp)
    80002ca0:	f022                	sd	s0,32(sp)
    80002ca2:	ec26                	sd	s1,24(sp)
    80002ca4:	e84a                	sd	s2,16(sp)
    80002ca6:	e44e                	sd	s3,8(sp)
    80002ca8:	e052                	sd	s4,0(sp)
    80002caa:	1800                	addi	s0,sp,48
    80002cac:	892a                	mv	s2,a0
    80002cae:	84ae                	mv	s1,a1
    80002cb0:	89b2                	mv	s3,a2
    80002cb2:	8a36                	mv	s4,a3
	struct proc *p = myproc();
    80002cb4:	fffff097          	auipc	ra,0xfffff
    80002cb8:	0b4080e7          	jalr	180(ra) # 80001d68 <myproc>
	if (user_src)
    80002cbc:	c08d                	beqz	s1,80002cde <either_copyin+0x42>
	{
		return copyin(p->pagetable, dst, src, len);
    80002cbe:	86d2                	mv	a3,s4
    80002cc0:	864e                	mv	a2,s3
    80002cc2:	85ca                	mv	a1,s2
    80002cc4:	6d28                	ld	a0,88(a0)
    80002cc6:	fffff097          	auipc	ra,0xfffff
    80002cca:	c32080e7          	jalr	-974(ra) # 800018f8 <copyin>
	else
	{
		memmove(dst, (char *)src, len);
		return 0;
	}
}
    80002cce:	70a2                	ld	ra,40(sp)
    80002cd0:	7402                	ld	s0,32(sp)
    80002cd2:	64e2                	ld	s1,24(sp)
    80002cd4:	6942                	ld	s2,16(sp)
    80002cd6:	69a2                	ld	s3,8(sp)
    80002cd8:	6a02                	ld	s4,0(sp)
    80002cda:	6145                	addi	sp,sp,48
    80002cdc:	8082                	ret
		memmove(dst, (char *)src, len);
    80002cde:	000a061b          	sext.w	a2,s4
    80002ce2:	85ce                	mv	a1,s3
    80002ce4:	854a                	mv	a0,s2
    80002ce6:	ffffe097          	auipc	ra,0xffffe
    80002cea:	21e080e7          	jalr	542(ra) # 80000f04 <memmove>
		return 0;
    80002cee:	8526                	mv	a0,s1
    80002cf0:	bff9                	j	80002cce <either_copyin+0x32>

0000000080002cf2 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck mastatechine further.
void procdump(void)
{
    80002cf2:	7159                	addi	sp,sp,-112
    80002cf4:	f486                	sd	ra,104(sp)
    80002cf6:	f0a2                	sd	s0,96(sp)
    80002cf8:	eca6                	sd	s1,88(sp)
    80002cfa:	e8ca                	sd	s2,80(sp)
    80002cfc:	e4ce                	sd	s3,72(sp)
    80002cfe:	e0d2                	sd	s4,64(sp)
    80002d00:	fc56                	sd	s5,56(sp)
    80002d02:	f85a                	sd	s6,48(sp)
    80002d04:	f45e                	sd	s7,40(sp)
    80002d06:	f062                	sd	s8,32(sp)
    80002d08:	ec66                	sd	s9,24(sp)
    80002d0a:	e86a                	sd	s10,16(sp)
    80002d0c:	e46e                	sd	s11,8(sp)
    80002d0e:	1880                	addi	s0,sp,112
		[RUNNING] "run   ",
		[ZOMBIE] "zombie"};
	struct proc *p;
	char *state;

	printf("\n");
    80002d10:	00005517          	auipc	a0,0x5
    80002d14:	3e850513          	addi	a0,a0,1000 # 800080f8 <digits+0xb8>
    80002d18:	ffffe097          	auipc	ra,0xffffe
    80002d1c:	876080e7          	jalr	-1930(ra) # 8000058e <printf>
	for (p = proc; p < &proc[NPROC]; p++)
    80002d20:	0022e917          	auipc	s2,0x22e
    80002d24:	7b490913          	addi	s2,s2,1972 # 802314d4 <proc+0x1ec>
    80002d28:	00236b17          	auipc	s6,0x236
    80002d2c:	3acb0b13          	addi	s6,s6,940 # 802390d4 <bcache+0x1d4>
	{
		if (p->state == UNUSED)
			continue;
		if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002d30:	4d15                	li	s10,5
			state = states[p->state];
		else
			state = "???";
    80002d32:	00005c17          	auipc	s8,0x5
    80002d36:	596c0c13          	addi	s8,s8,1430 # 800082c8 <digits+0x288>
#ifdef PBS
		printf("Run time: %d\n", p->runTime);
#endif
#ifdef MLFQ
		for (int j = 0; j < 5; j++)
			printf("%d ", p->queue_ticks[j]);
    80002d3a:	00005a17          	auipc	s4,0x5
    80002d3e:	596a0a13          	addi	s4,s4,1430 # 800082d0 <digits+0x290>
		printf("\n");
    80002d42:	00005b97          	auipc	s7,0x5
    80002d46:	3b6b8b93          	addi	s7,s7,950 # 800080f8 <digits+0xb8>
#endif
		printf("%d %s %s %d %d", p->pid, state, p->name, p->runTime, p->countTimeCalled);
    80002d4a:	00005c97          	auipc	s9,0x5
    80002d4e:	58ec8c93          	addi	s9,s9,1422 # 800082d8 <digits+0x298>
		if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002d52:	00005d97          	auipc	s11,0x5
    80002d56:	5c6d8d93          	addi	s11,s11,1478 # 80008318 <states.2544>
    80002d5a:	a881                	j	80002daa <procdump+0xb8>
		for (int j = 0; j < 5; j++)
    80002d5c:	fec90493          	addi	s1,s2,-20
			printf("%d ", p->queue_ticks[j]);
    80002d60:	408c                	lw	a1,0(s1)
    80002d62:	8552                	mv	a0,s4
    80002d64:	ffffe097          	auipc	ra,0xffffe
    80002d68:	82a080e7          	jalr	-2006(ra) # 8000058e <printf>
		for (int j = 0; j < 5; j++)
    80002d6c:	0491                	addi	s1,s1,4
    80002d6e:	ff2499e3          	bne	s1,s2,80002d60 <procdump+0x6e>
		printf("\n");
    80002d72:	855e                	mv	a0,s7
    80002d74:	ffffe097          	auipc	ra,0xffffe
    80002d78:	81a080e7          	jalr	-2022(ra) # 8000058e <printf>
		printf("%d %s %s %d %d", p->pid, state, p->name, p->runTime, p->countTimeCalled);
    80002d7c:	fcc9a783          	lw	a5,-52(s3)
    80002d80:	fb49a703          	lw	a4,-76(s3)
    80002d84:	f7490693          	addi	a3,s2,-140
    80002d88:	8656                	mv	a2,s5
    80002d8a:	e4c9a583          	lw	a1,-436(s3)
    80002d8e:	8566                	mv	a0,s9
    80002d90:	ffffd097          	auipc	ra,0xffffd
    80002d94:	7fe080e7          	jalr	2046(ra) # 8000058e <printf>
		printf("\n");
    80002d98:	855e                	mv	a0,s7
    80002d9a:	ffffd097          	auipc	ra,0xffffd
    80002d9e:	7f4080e7          	jalr	2036(ra) # 8000058e <printf>
	for (p = proc; p < &proc[NPROC]; p++)
    80002da2:	1f090913          	addi	s2,s2,496
    80002da6:	03690363          	beq	s2,s6,80002dcc <procdump+0xda>
		if (p->state == UNUSED)
    80002daa:	89ca                	mv	s3,s2
    80002dac:	e3492783          	lw	a5,-460(s2)
    80002db0:	dbed                	beqz	a5,80002da2 <procdump+0xb0>
			state = "???";
    80002db2:	8ae2                	mv	s5,s8
		if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002db4:	fafd64e3          	bltu	s10,a5,80002d5c <procdump+0x6a>
    80002db8:	1782                	slli	a5,a5,0x20
    80002dba:	9381                	srli	a5,a5,0x20
    80002dbc:	078e                	slli	a5,a5,0x3
    80002dbe:	97ee                	add	a5,a5,s11
    80002dc0:	0007ba83          	ld	s5,0(a5)
    80002dc4:	f80a9ce3          	bnez	s5,80002d5c <procdump+0x6a>
			state = "???";
    80002dc8:	8ae2                	mv	s5,s8
    80002dca:	bf49                	j	80002d5c <procdump+0x6a>
	}
}
    80002dcc:	70a6                	ld	ra,104(sp)
    80002dce:	7406                	ld	s0,96(sp)
    80002dd0:	64e6                	ld	s1,88(sp)
    80002dd2:	6946                	ld	s2,80(sp)
    80002dd4:	69a6                	ld	s3,72(sp)
    80002dd6:	6a06                	ld	s4,64(sp)
    80002dd8:	7ae2                	ld	s5,56(sp)
    80002dda:	7b42                	ld	s6,48(sp)
    80002ddc:	7ba2                	ld	s7,40(sp)
    80002dde:	7c02                	ld	s8,32(sp)
    80002de0:	6ce2                	ld	s9,24(sp)
    80002de2:	6d42                	ld	s10,16(sp)
    80002de4:	6da2                	ld	s11,8(sp)
    80002de6:	6165                	addi	sp,sp,112
    80002de8:	8082                	ret

0000000080002dea <set_tickets>:

int set_tickets(int no_of_tickets)
{
    80002dea:	1141                	addi	sp,sp,-16
    80002dec:	e422                	sd	s0,8(sp)
    80002dee:	0800                	addi	s0,sp,16

	p->tickets = no_of_tickets;

#endif
	return 1;
}
    80002df0:	4505                	li	a0,1
    80002df2:	6422                	ld	s0,8(sp)
    80002df4:	0141                	addi	sp,sp,16
    80002df6:	8082                	ret

0000000080002df8 <swtch>:
    80002df8:	00153023          	sd	ra,0(a0)
    80002dfc:	00253423          	sd	sp,8(a0)
    80002e00:	e900                	sd	s0,16(a0)
    80002e02:	ed04                	sd	s1,24(a0)
    80002e04:	03253023          	sd	s2,32(a0)
    80002e08:	03353423          	sd	s3,40(a0)
    80002e0c:	03453823          	sd	s4,48(a0)
    80002e10:	03553c23          	sd	s5,56(a0)
    80002e14:	05653023          	sd	s6,64(a0)
    80002e18:	05753423          	sd	s7,72(a0)
    80002e1c:	05853823          	sd	s8,80(a0)
    80002e20:	05953c23          	sd	s9,88(a0)
    80002e24:	07a53023          	sd	s10,96(a0)
    80002e28:	07b53423          	sd	s11,104(a0)
    80002e2c:	0005b083          	ld	ra,0(a1)
    80002e30:	0085b103          	ld	sp,8(a1)
    80002e34:	6980                	ld	s0,16(a1)
    80002e36:	6d84                	ld	s1,24(a1)
    80002e38:	0205b903          	ld	s2,32(a1)
    80002e3c:	0285b983          	ld	s3,40(a1)
    80002e40:	0305ba03          	ld	s4,48(a1)
    80002e44:	0385ba83          	ld	s5,56(a1)
    80002e48:	0405bb03          	ld	s6,64(a1)
    80002e4c:	0485bb83          	ld	s7,72(a1)
    80002e50:	0505bc03          	ld	s8,80(a1)
    80002e54:	0585bc83          	ld	s9,88(a1)
    80002e58:	0605bd03          	ld	s10,96(a1)
    80002e5c:	0685bd83          	ld	s11,104(a1)
    80002e60:	8082                	ret

0000000080002e62 <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002e62:	1141                	addi	sp,sp,-16
    80002e64:	e406                	sd	ra,8(sp)
    80002e66:	e022                	sd	s0,0(sp)
    80002e68:	0800                	addi	s0,sp,16
	initlock(&tickslock, "time");
    80002e6a:	00005597          	auipc	a1,0x5
    80002e6e:	4de58593          	addi	a1,a1,1246 # 80008348 <states.2544+0x30>
    80002e72:	00236517          	auipc	a0,0x236
    80002e76:	07650513          	addi	a0,a0,118 # 80238ee8 <tickslock>
    80002e7a:	ffffe097          	auipc	ra,0xffffe
    80002e7e:	e9e080e7          	jalr	-354(ra) # 80000d18 <initlock>
}
    80002e82:	60a2                	ld	ra,8(sp)
    80002e84:	6402                	ld	s0,0(sp)
    80002e86:	0141                	addi	sp,sp,16
    80002e88:	8082                	ret

0000000080002e8a <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002e8a:	1141                	addi	sp,sp,-16
    80002e8c:	e422                	sd	s0,8(sp)
    80002e8e:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002e90:	00004797          	auipc	a5,0x4
    80002e94:	93078793          	addi	a5,a5,-1744 # 800067c0 <kernelvec>
    80002e98:	10579073          	csrw	stvec,a5
	w_stvec((uint64)kernelvec);
}
    80002e9c:	6422                	ld	s0,8(sp)
    80002e9e:	0141                	addi	sp,sp,16
    80002ea0:	8082                	ret

0000000080002ea2 <cowalloc>:
{
	// ** va must be PGSIZE aligned
	// if ((va % PGSIZE) != 0)
	// 	return -1;

	if (va == 0)
    80002ea2:	fff58713          	addi	a4,a1,-1
    80002ea6:	f80007b7          	lui	a5,0xf8000
    80002eaa:	83e9                	srli	a5,a5,0x1a
    80002eac:	08e7e063          	bltu	a5,a4,80002f2c <cowalloc+0x8a>
{
    80002eb0:	7179                	addi	sp,sp,-48
    80002eb2:	f406                	sd	ra,40(sp)
    80002eb4:	f022                	sd	s0,32(sp)
    80002eb6:	ec26                	sd	s1,24(sp)
    80002eb8:	e84a                	sd	s2,16(sp)
    80002eba:	e44e                	sd	s3,8(sp)
    80002ebc:	1800                	addi	s0,sp,48

	// ** safety check
	if (va >= MAXVA)
		return -1;

	pte_t *pte = walk(pagetable, va, 0);
    80002ebe:	4601                	li	a2,0
    80002ec0:	ffffe097          	auipc	ra,0xffffe
    80002ec4:	2d0080e7          	jalr	720(ra) # 80001190 <walk>
    80002ec8:	84aa                	mv	s1,a0
	if (pte == 0)
    80002eca:	c13d                	beqz	a0,80002f30 <cowalloc+0x8e>
		return -1;
	if ((*pte & PTE_U) == 0 || (*pte & PTE_V) == 0)
    80002ecc:	611c                	ld	a5,0(a0)
    80002ece:	0117f693          	andi	a3,a5,17
    80002ed2:	4745                	li	a4,17
    80002ed4:	06e69063          	bne	a3,a4,80002f34 <cowalloc+0x92>
		return -1;

	uint64 pa = PTE2PA(*pte);
    80002ed8:	00a7d913          	srli	s2,a5,0xa
    80002edc:	0932                	slli	s2,s2,0xc
	if (pa == 0)
    80002ede:	04090d63          	beqz	s2,80002f38 <cowalloc+0x96>

	// printf("here\n");

	// ** If page fault is raised with a COW page,
	// ** alloc a physical page, mapped to user pagetable and set PTE_W
	if (*pte & PTE_C)
    80002ee2:	1007f793          	andi	a5,a5,256
		// mappages(pagetable, va, PGSIZE, (uint64)ka, flags);
		krefdecr((void *)pa);
		// kfree((void *)pa);
	}

	return 0;
    80002ee6:	4501                	li	a0,0
	if (*pte & PTE_C)
    80002ee8:	eb81                	bnez	a5,80002ef8 <cowalloc+0x56>
}
    80002eea:	70a2                	ld	ra,40(sp)
    80002eec:	7402                	ld	s0,32(sp)
    80002eee:	64e2                	ld	s1,24(sp)
    80002ef0:	6942                	ld	s2,16(sp)
    80002ef2:	69a2                	ld	s3,8(sp)
    80002ef4:	6145                	addi	sp,sp,48
    80002ef6:	8082                	ret
		uint64 ka = (uint64)kalloc();
    80002ef8:	ffffe097          	auipc	ra,0xffffe
    80002efc:	d7c080e7          	jalr	-644(ra) # 80000c74 <kalloc>
    80002f00:	89aa                	mv	s3,a0
		if (ka == 0)
    80002f02:	cd0d                	beqz	a0,80002f3c <cowalloc+0x9a>
		memmove((void *)ka, (void *)pa, PGSIZE);
    80002f04:	6605                	lui	a2,0x1
    80002f06:	85ca                	mv	a1,s2
    80002f08:	ffffe097          	auipc	ra,0xffffe
    80002f0c:	ffc080e7          	jalr	-4(ra) # 80000f04 <memmove>
		*pte = PA2PTE(ka) | PTE_U | PTE_V | PTE_W | PTE_X | PTE_R;
    80002f10:	00c9d993          	srli	s3,s3,0xc
    80002f14:	09aa                	slli	s3,s3,0xa
    80002f16:	01f9e993          	ori	s3,s3,31
    80002f1a:	0134b023          	sd	s3,0(s1)
		krefdecr((void *)pa);
    80002f1e:	854a                	mv	a0,s2
    80002f20:	ffffe097          	auipc	ra,0xffffe
    80002f24:	b46080e7          	jalr	-1210(ra) # 80000a66 <krefdecr>
	return 0;
    80002f28:	4501                	li	a0,0
    80002f2a:	b7c1                	j	80002eea <cowalloc+0x48>
		return -1;
    80002f2c:	557d                	li	a0,-1
}
    80002f2e:	8082                	ret
		return -1;
    80002f30:	557d                	li	a0,-1
    80002f32:	bf65                	j	80002eea <cowalloc+0x48>
		return -1;
    80002f34:	557d                	li	a0,-1
    80002f36:	bf55                	j	80002eea <cowalloc+0x48>
		return -1;
    80002f38:	557d                	li	a0,-1
    80002f3a:	bf45                	j	80002eea <cowalloc+0x48>
			return -1;
    80002f3c:	557d                	li	a0,-1
    80002f3e:	b775                	j	80002eea <cowalloc+0x48>

0000000080002f40 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80002f40:	1141                	addi	sp,sp,-16
    80002f42:	e406                	sd	ra,8(sp)
    80002f44:	e022                	sd	s0,0(sp)
    80002f46:	0800                	addi	s0,sp,16
	struct proc *p = myproc();
    80002f48:	fffff097          	auipc	ra,0xfffff
    80002f4c:	e20080e7          	jalr	-480(ra) # 80001d68 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f50:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002f54:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002f56:	10079073          	csrw	sstatus,a5
	// kerneltrap() to usertrap(), so turn off interrupts until
	// we're back in user space, where usertrap() is correct.
	intr_off();

	// send syscalls, interrupts, and exceptions to uservec in trampoline.S
	uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002f5a:	00004617          	auipc	a2,0x4
    80002f5e:	0a660613          	addi	a2,a2,166 # 80007000 <_trampoline>
    80002f62:	00004697          	auipc	a3,0x4
    80002f66:	09e68693          	addi	a3,a3,158 # 80007000 <_trampoline>
    80002f6a:	8e91                	sub	a3,a3,a2
    80002f6c:	040007b7          	lui	a5,0x4000
    80002f70:	17fd                	addi	a5,a5,-1
    80002f72:	07b2                	slli	a5,a5,0xc
    80002f74:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002f76:	10569073          	csrw	stvec,a3
	w_stvec(trampoline_uservec);

	// set up trapframe values that uservec will need when
	// the process next traps into the kernel.
	p->trapframe->kernel_satp = r_satp();		  // kernel page table
    80002f7a:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002f7c:	180026f3          	csrr	a3,satp
    80002f80:	e314                	sd	a3,0(a4)
	p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002f82:	7138                	ld	a4,96(a0)
    80002f84:	6534                	ld	a3,72(a0)
    80002f86:	6585                	lui	a1,0x1
    80002f88:	96ae                	add	a3,a3,a1
    80002f8a:	e714                	sd	a3,8(a4)
	p->trapframe->kernel_trap = (uint64)usertrap;
    80002f8c:	7138                	ld	a4,96(a0)
    80002f8e:	00000697          	auipc	a3,0x0
    80002f92:	13e68693          	addi	a3,a3,318 # 800030cc <usertrap>
    80002f96:	eb14                	sd	a3,16(a4)
	p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002f98:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002f9a:	8692                	mv	a3,tp
    80002f9c:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002f9e:	100026f3          	csrr	a3,sstatus
	// set up the registers that trampoline.S's sret will use
	// to get to user space.

	// set S Previous Privilege mode to User.
	unsigned long x = r_sstatus();
	x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002fa2:	eff6f693          	andi	a3,a3,-257
	x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002fa6:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002faa:	10069073          	csrw	sstatus,a3
	w_sstatus(x);

	// set S Exception Program Counter to the saved user pc.
	w_sepc(p->trapframe->epc);
    80002fae:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002fb0:	6f18                	ld	a4,24(a4)
    80002fb2:	14171073          	csrw	sepc,a4

	// tell trampoline.S the user page table to switch to.
	uint64 satp = MAKE_SATP(p->pagetable);
    80002fb6:	6d28                	ld	a0,88(a0)
    80002fb8:	8131                	srli	a0,a0,0xc

	// jump to userret in trampoline.S at the top of memory, which
	// switches to the user page table, restores user registers,
	// and switches to user mode with sret.
	uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002fba:	00004717          	auipc	a4,0x4
    80002fbe:	0e270713          	addi	a4,a4,226 # 8000709c <userret>
    80002fc2:	8f11                	sub	a4,a4,a2
    80002fc4:	97ba                	add	a5,a5,a4
	((void (*)(uint64))trampoline_userret)(satp);
    80002fc6:	577d                	li	a4,-1
    80002fc8:	177e                	slli	a4,a4,0x3f
    80002fca:	8d59                	or	a0,a0,a4
    80002fcc:	9782                	jalr	a5
}
    80002fce:	60a2                	ld	ra,8(sp)
    80002fd0:	6402                	ld	s0,0(sp)
    80002fd2:	0141                	addi	sp,sp,16
    80002fd4:	8082                	ret

0000000080002fd6 <clockintr>:
	w_sepc(sepc);
	w_sstatus(sstatus);
}

void clockintr()
{
    80002fd6:	1101                	addi	sp,sp,-32
    80002fd8:	ec06                	sd	ra,24(sp)
    80002fda:	e822                	sd	s0,16(sp)
    80002fdc:	e426                	sd	s1,8(sp)
    80002fde:	e04a                	sd	s2,0(sp)
    80002fe0:	1000                	addi	s0,sp,32
	acquire(&tickslock);
    80002fe2:	00236917          	auipc	s2,0x236
    80002fe6:	f0690913          	addi	s2,s2,-250 # 80238ee8 <tickslock>
    80002fea:	854a                	mv	a0,s2
    80002fec:	ffffe097          	auipc	ra,0xffffe
    80002ff0:	dbc080e7          	jalr	-580(ra) # 80000da8 <acquire>
	ticks++;
    80002ff4:	00006497          	auipc	s1,0x6
    80002ff8:	c3c48493          	addi	s1,s1,-964 # 80008c30 <ticks>
    80002ffc:	409c                	lw	a5,0(s1)
    80002ffe:	2785                	addiw	a5,a5,1
    80003000:	c09c                	sw	a5,0(s1)
	upd_time();
    80003002:	fffff097          	auipc	ra,0xfffff
    80003006:	182080e7          	jalr	386(ra) # 80002184 <upd_time>
	wakeup(&ticks);
    8000300a:	8526                	mv	a0,s1
    8000300c:	00000097          	auipc	ra,0x0
    80003010:	956080e7          	jalr	-1706(ra) # 80002962 <wakeup>
	release(&tickslock);
    80003014:	854a                	mv	a0,s2
    80003016:	ffffe097          	auipc	ra,0xffffe
    8000301a:	e46080e7          	jalr	-442(ra) # 80000e5c <release>
}
    8000301e:	60e2                	ld	ra,24(sp)
    80003020:	6442                	ld	s0,16(sp)
    80003022:	64a2                	ld	s1,8(sp)
    80003024:	6902                	ld	s2,0(sp)
    80003026:	6105                	addi	sp,sp,32
    80003028:	8082                	ret

000000008000302a <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    8000302a:	1101                	addi	sp,sp,-32
    8000302c:	ec06                	sd	ra,24(sp)
    8000302e:	e822                	sd	s0,16(sp)
    80003030:	e426                	sd	s1,8(sp)
    80003032:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003034:	14202773          	csrr	a4,scause
	uint64 scause = r_scause();

	if ((scause & 0x8000000000000000L) &&
    80003038:	00074d63          	bltz	a4,80003052 <devintr+0x28>
		if (irq)
			plic_complete(irq);

		return 1;
	}
	else if (scause == 0x8000000000000001L)
    8000303c:	57fd                	li	a5,-1
    8000303e:	17fe                	slli	a5,a5,0x3f
    80003040:	0785                	addi	a5,a5,1

		return 2;
	}
	else
	{
		return 0;
    80003042:	4501                	li	a0,0
	else if (scause == 0x8000000000000001L)
    80003044:	06f70363          	beq	a4,a5,800030aa <devintr+0x80>
	}
}
    80003048:	60e2                	ld	ra,24(sp)
    8000304a:	6442                	ld	s0,16(sp)
    8000304c:	64a2                	ld	s1,8(sp)
    8000304e:	6105                	addi	sp,sp,32
    80003050:	8082                	ret
		(scause & 0xff) == 9)
    80003052:	0ff77793          	andi	a5,a4,255
	if ((scause & 0x8000000000000000L) &&
    80003056:	46a5                	li	a3,9
    80003058:	fed792e3          	bne	a5,a3,8000303c <devintr+0x12>
		int irq = plic_claim();
    8000305c:	00004097          	auipc	ra,0x4
    80003060:	86c080e7          	jalr	-1940(ra) # 800068c8 <plic_claim>
    80003064:	84aa                	mv	s1,a0
		if (irq == UART0_IRQ)
    80003066:	47a9                	li	a5,10
    80003068:	02f50763          	beq	a0,a5,80003096 <devintr+0x6c>
		else if (irq == VIRTIO0_IRQ)
    8000306c:	4785                	li	a5,1
    8000306e:	02f50963          	beq	a0,a5,800030a0 <devintr+0x76>
		return 1;
    80003072:	4505                	li	a0,1
		else if (irq)
    80003074:	d8f1                	beqz	s1,80003048 <devintr+0x1e>
			printf("unexpected interrupt irq=%d\n", irq);
    80003076:	85a6                	mv	a1,s1
    80003078:	00005517          	auipc	a0,0x5
    8000307c:	2d850513          	addi	a0,a0,728 # 80008350 <states.2544+0x38>
    80003080:	ffffd097          	auipc	ra,0xffffd
    80003084:	50e080e7          	jalr	1294(ra) # 8000058e <printf>
			plic_complete(irq);
    80003088:	8526                	mv	a0,s1
    8000308a:	00004097          	auipc	ra,0x4
    8000308e:	862080e7          	jalr	-1950(ra) # 800068ec <plic_complete>
		return 1;
    80003092:	4505                	li	a0,1
    80003094:	bf55                	j	80003048 <devintr+0x1e>
			uartintr();
    80003096:	ffffe097          	auipc	ra,0xffffe
    8000309a:	918080e7          	jalr	-1768(ra) # 800009ae <uartintr>
    8000309e:	b7ed                	j	80003088 <devintr+0x5e>
			virtio_disk_intr();
    800030a0:	00004097          	auipc	ra,0x4
    800030a4:	d76080e7          	jalr	-650(ra) # 80006e16 <virtio_disk_intr>
    800030a8:	b7c5                	j	80003088 <devintr+0x5e>
		if (cpuid() == 0)
    800030aa:	fffff097          	auipc	ra,0xfffff
    800030ae:	c92080e7          	jalr	-878(ra) # 80001d3c <cpuid>
    800030b2:	c901                	beqz	a0,800030c2 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800030b4:	144027f3          	csrr	a5,sip
		w_sip(r_sip() & ~2);
    800030b8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800030ba:	14479073          	csrw	sip,a5
		return 2;
    800030be:	4509                	li	a0,2
    800030c0:	b761                	j	80003048 <devintr+0x1e>
			clockintr();
    800030c2:	00000097          	auipc	ra,0x0
    800030c6:	f14080e7          	jalr	-236(ra) # 80002fd6 <clockintr>
    800030ca:	b7ed                	j	800030b4 <devintr+0x8a>

00000000800030cc <usertrap>:
{
    800030cc:	1101                	addi	sp,sp,-32
    800030ce:	ec06                	sd	ra,24(sp)
    800030d0:	e822                	sd	s0,16(sp)
    800030d2:	e426                	sd	s1,8(sp)
    800030d4:	e04a                	sd	s2,0(sp)
    800030d6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800030d8:	100027f3          	csrr	a5,sstatus
	if ((r_sstatus() & SSTATUS_SPP) != 0)
    800030dc:	1007f793          	andi	a5,a5,256
    800030e0:	efad                	bnez	a5,8000315a <usertrap+0x8e>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800030e2:	00003797          	auipc	a5,0x3
    800030e6:	6de78793          	addi	a5,a5,1758 # 800067c0 <kernelvec>
    800030ea:	10579073          	csrw	stvec,a5
	struct proc *p = myproc();
    800030ee:	fffff097          	auipc	ra,0xfffff
    800030f2:	c7a080e7          	jalr	-902(ra) # 80001d68 <myproc>
    800030f6:	84aa                	mv	s1,a0
	p->trapframe->epc = r_sepc();
    800030f8:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800030fa:	14102773          	csrr	a4,sepc
    800030fe:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003100:	14202773          	csrr	a4,scause
	if (r_scause() == 8)
    80003104:	47a1                	li	a5,8
    80003106:	06f70263          	beq	a4,a5,8000316a <usertrap+0x9e>
    8000310a:	14202773          	csrr	a4,scause
	else if (r_scause() == 15)
    8000310e:	47bd                	li	a5,15
    80003110:	0af71363          	bne	a4,a5,800031b6 <usertrap+0xea>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003114:	14302973          	csrr	s2,stval
		if (addr >= MAXVA || (addr < p->trapframe->sp && addr >= (p->trapframe->sp - PGSIZE)))
    80003118:	57fd                	li	a5,-1
    8000311a:	83e9                	srli	a5,a5,0x1a
    8000311c:	0127ea63          	bltu	a5,s2,80003130 <usertrap+0x64>
    80003120:	713c                	ld	a5,96(a0)
    80003122:	7b9c                	ld	a5,48(a5)
    80003124:	00f97b63          	bgeu	s2,a5,8000313a <usertrap+0x6e>
    80003128:	777d                	lui	a4,0xfffff
    8000312a:	97ba                	add	a5,a5,a4
    8000312c:	00f96763          	bltu	s2,a5,8000313a <usertrap+0x6e>
			setkilled(p);
    80003130:	8526                	mv	a0,s1
    80003132:	00000097          	auipc	ra,0x0
    80003136:	aa8080e7          	jalr	-1368(ra) # 80002bda <setkilled>
		if (cowalloc(p->pagetable, PGROUNDDOWN(addr)) < 0)
    8000313a:	75fd                	lui	a1,0xfffff
    8000313c:	00b975b3          	and	a1,s2,a1
    80003140:	6ca8                	ld	a0,88(s1)
    80003142:	00000097          	auipc	ra,0x0
    80003146:	d60080e7          	jalr	-672(ra) # 80002ea2 <cowalloc>
    8000314a:	04055063          	bgez	a0,8000318a <usertrap+0xbe>
			setkilled(p);
    8000314e:	8526                	mv	a0,s1
    80003150:	00000097          	auipc	ra,0x0
    80003154:	a8a080e7          	jalr	-1398(ra) # 80002bda <setkilled>
    80003158:	a80d                	j	8000318a <usertrap+0xbe>
		panic("usertrap: not from user mode");
    8000315a:	00005517          	auipc	a0,0x5
    8000315e:	21650513          	addi	a0,a0,534 # 80008370 <states.2544+0x58>
    80003162:	ffffd097          	auipc	ra,0xffffd
    80003166:	3e2080e7          	jalr	994(ra) # 80000544 <panic>
		if (p->killed)
    8000316a:	591c                	lw	a5,48(a0)
    8000316c:	ef9d                	bnez	a5,800031aa <usertrap+0xde>
		p->trapframe->epc += 4;
    8000316e:	70b8                	ld	a4,96(s1)
    80003170:	6f1c                	ld	a5,24(a4)
    80003172:	0791                	addi	a5,a5,4
    80003174:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003176:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000317a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000317e:	10079073          	csrw	sstatus,a5
		syscall();
    80003182:	00000097          	auipc	ra,0x0
    80003186:	35a080e7          	jalr	858(ra) # 800034dc <syscall>
	if (killed(p))
    8000318a:	8526                	mv	a0,s1
    8000318c:	00000097          	auipc	ra,0x0
    80003190:	a84080e7          	jalr	-1404(ra) # 80002c10 <killed>
    80003194:	e93d                	bnez	a0,8000320a <usertrap+0x13e>
	usertrapret();
    80003196:	00000097          	auipc	ra,0x0
    8000319a:	daa080e7          	jalr	-598(ra) # 80002f40 <usertrapret>
}
    8000319e:	60e2                	ld	ra,24(sp)
    800031a0:	6442                	ld	s0,16(sp)
    800031a2:	64a2                	ld	s1,8(sp)
    800031a4:	6902                	ld	s2,0(sp)
    800031a6:	6105                	addi	sp,sp,32
    800031a8:	8082                	ret
			exit(-1);
    800031aa:	557d                	li	a0,-1
    800031ac:	00000097          	auipc	ra,0x0
    800031b0:	8ba080e7          	jalr	-1862(ra) # 80002a66 <exit>
    800031b4:	bf6d                	j	8000316e <usertrap+0xa2>
	else if ((which_dev = devintr()) != 0)
    800031b6:	00000097          	auipc	ra,0x0
    800031ba:	e74080e7          	jalr	-396(ra) # 8000302a <devintr>
    800031be:	892a                	mv	s2,a0
    800031c0:	c901                	beqz	a0,800031d0 <usertrap+0x104>
	if (killed(p))
    800031c2:	8526                	mv	a0,s1
    800031c4:	00000097          	auipc	ra,0x0
    800031c8:	a4c080e7          	jalr	-1460(ra) # 80002c10 <killed>
    800031cc:	c529                	beqz	a0,80003216 <usertrap+0x14a>
    800031ce:	a83d                	j	8000320c <usertrap+0x140>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800031d0:	142025f3          	csrr	a1,scause
		printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800031d4:	5c90                	lw	a2,56(s1)
    800031d6:	00005517          	auipc	a0,0x5
    800031da:	1ba50513          	addi	a0,a0,442 # 80008390 <states.2544+0x78>
    800031de:	ffffd097          	auipc	ra,0xffffd
    800031e2:	3b0080e7          	jalr	944(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800031e6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800031ea:	14302673          	csrr	a2,stval
		printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800031ee:	00005517          	auipc	a0,0x5
    800031f2:	1d250513          	addi	a0,a0,466 # 800083c0 <states.2544+0xa8>
    800031f6:	ffffd097          	auipc	ra,0xffffd
    800031fa:	398080e7          	jalr	920(ra) # 8000058e <printf>
		setkilled(p);
    800031fe:	8526                	mv	a0,s1
    80003200:	00000097          	auipc	ra,0x0
    80003204:	9da080e7          	jalr	-1574(ra) # 80002bda <setkilled>
    80003208:	b749                	j	8000318a <usertrap+0xbe>
	if (killed(p))
    8000320a:	4901                	li	s2,0
		exit(-1);
    8000320c:	557d                	li	a0,-1
    8000320e:	00000097          	auipc	ra,0x0
    80003212:	858080e7          	jalr	-1960(ra) # 80002a66 <exit>
	if (which_dev == 2)
    80003216:	4789                	li	a5,2
    80003218:	f6f91fe3          	bne	s2,a5,80003196 <usertrap+0xca>
		p->ticks_elapsed++;
    8000321c:	1d44a783          	lw	a5,468(s1)
    80003220:	2785                	addiw	a5,a5,1
    80003222:	0007871b          	sext.w	a4,a5
    80003226:	1cf4aa23          	sw	a5,468(s1)
		if (p->ticks_elapsed >= p->ass_ticks)
    8000322a:	1cc4a783          	lw	a5,460(s1)
    8000322e:	f6f744e3          	blt	a4,a5,80003196 <usertrap+0xca>
			p->ticks_elapsed = 0;
    80003232:	1c04aa23          	sw	zero,468(s1)
			if (p->priority_level < 4)
    80003236:	1c84a703          	lw	a4,456(s1)
    8000323a:	468d                	li	a3,3
    8000323c:	00e6c963          	blt	a3,a4,8000324e <usertrap+0x182>
				p->priority_level++;
    80003240:	2705                	addiw	a4,a4,1
    80003242:	1ce4a423          	sw	a4,456(s1)
				p->ass_ticks *= 2;
    80003246:	0017979b          	slliw	a5,a5,0x1
    8000324a:	1cf4a623          	sw	a5,460(s1)
			yield();
    8000324e:	fffff097          	auipc	ra,0xfffff
    80003252:	26c080e7          	jalr	620(ra) # 800024ba <yield>
    80003256:	b781                	j	80003196 <usertrap+0xca>

0000000080003258 <kerneltrap>:
{
    80003258:	7179                	addi	sp,sp,-48
    8000325a:	f406                	sd	ra,40(sp)
    8000325c:	f022                	sd	s0,32(sp)
    8000325e:	ec26                	sd	s1,24(sp)
    80003260:	e84a                	sd	s2,16(sp)
    80003262:	e44e                	sd	s3,8(sp)
    80003264:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003266:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000326a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000326e:	142029f3          	csrr	s3,scause
	if ((sstatus & SSTATUS_SPP) == 0)
    80003272:	1004f793          	andi	a5,s1,256
    80003276:	cb85                	beqz	a5,800032a6 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003278:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000327c:	8b89                	andi	a5,a5,2
	if (intr_get() != 0)
    8000327e:	ef85                	bnez	a5,800032b6 <kerneltrap+0x5e>
	if ((which_dev = devintr()) == 0)
    80003280:	00000097          	auipc	ra,0x0
    80003284:	daa080e7          	jalr	-598(ra) # 8000302a <devintr>
    80003288:	cd1d                	beqz	a0,800032c6 <kerneltrap+0x6e>
	if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000328a:	4789                	li	a5,2
    8000328c:	06f50a63          	beq	a0,a5,80003300 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003290:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003294:	10049073          	csrw	sstatus,s1
}
    80003298:	70a2                	ld	ra,40(sp)
    8000329a:	7402                	ld	s0,32(sp)
    8000329c:	64e2                	ld	s1,24(sp)
    8000329e:	6942                	ld	s2,16(sp)
    800032a0:	69a2                	ld	s3,8(sp)
    800032a2:	6145                	addi	sp,sp,48
    800032a4:	8082                	ret
		panic("kerneltrap: not from supervisor mode");
    800032a6:	00005517          	auipc	a0,0x5
    800032aa:	13a50513          	addi	a0,a0,314 # 800083e0 <states.2544+0xc8>
    800032ae:	ffffd097          	auipc	ra,0xffffd
    800032b2:	296080e7          	jalr	662(ra) # 80000544 <panic>
		panic("kerneltrap: interrupts enabled");
    800032b6:	00005517          	auipc	a0,0x5
    800032ba:	15250513          	addi	a0,a0,338 # 80008408 <states.2544+0xf0>
    800032be:	ffffd097          	auipc	ra,0xffffd
    800032c2:	286080e7          	jalr	646(ra) # 80000544 <panic>
		printf("scause %p\n", scause);
    800032c6:	85ce                	mv	a1,s3
    800032c8:	00005517          	auipc	a0,0x5
    800032cc:	16050513          	addi	a0,a0,352 # 80008428 <states.2544+0x110>
    800032d0:	ffffd097          	auipc	ra,0xffffd
    800032d4:	2be080e7          	jalr	702(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800032d8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800032dc:	14302673          	csrr	a2,stval
		printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800032e0:	00005517          	auipc	a0,0x5
    800032e4:	15850513          	addi	a0,a0,344 # 80008438 <states.2544+0x120>
    800032e8:	ffffd097          	auipc	ra,0xffffd
    800032ec:	2a6080e7          	jalr	678(ra) # 8000058e <printf>
		panic("kerneltrap");
    800032f0:	00005517          	auipc	a0,0x5
    800032f4:	16050513          	addi	a0,a0,352 # 80008450 <states.2544+0x138>
    800032f8:	ffffd097          	auipc	ra,0xffffd
    800032fc:	24c080e7          	jalr	588(ra) # 80000544 <panic>
	if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003300:	fffff097          	auipc	ra,0xfffff
    80003304:	a68080e7          	jalr	-1432(ra) # 80001d68 <myproc>
    80003308:	d541                	beqz	a0,80003290 <kerneltrap+0x38>
    8000330a:	fffff097          	auipc	ra,0xfffff
    8000330e:	a5e080e7          	jalr	-1442(ra) # 80001d68 <myproc>
    80003312:	5118                	lw	a4,32(a0)
    80003314:	4791                	li	a5,4
    80003316:	f6f71de3          	bne	a4,a5,80003290 <kerneltrap+0x38>
		struct proc *p = myproc();
    8000331a:	fffff097          	auipc	ra,0xfffff
    8000331e:	a4e080e7          	jalr	-1458(ra) # 80001d68 <myproc>
		p->ticks_elapsed++;
    80003322:	1d452783          	lw	a5,468(a0)
    80003326:	2785                	addiw	a5,a5,1
    80003328:	0007871b          	sext.w	a4,a5
    8000332c:	1cf52a23          	sw	a5,468(a0)
		if (p->ticks_elapsed >= p->ass_ticks)
    80003330:	1cc52783          	lw	a5,460(a0)
    80003334:	f4f74ee3          	blt	a4,a5,80003290 <kerneltrap+0x38>
			p->ticks_elapsed = 0;
    80003338:	1c052a23          	sw	zero,468(a0)
			if (p->priority_level < 4)
    8000333c:	1c852703          	lw	a4,456(a0)
    80003340:	468d                	li	a3,3
    80003342:	00e6c963          	blt	a3,a4,80003354 <kerneltrap+0xfc>
				p->priority_level++;
    80003346:	2705                	addiw	a4,a4,1
    80003348:	1ce52423          	sw	a4,456(a0)
				p->ass_ticks *= 2;
    8000334c:	0017979b          	slliw	a5,a5,0x1
    80003350:	1cf52623          	sw	a5,460(a0)
			yield();
    80003354:	fffff097          	auipc	ra,0xfffff
    80003358:	166080e7          	jalr	358(ra) # 800024ba <yield>
    8000335c:	bf15                	j	80003290 <kerneltrap+0x38>

000000008000335e <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000335e:	1101                	addi	sp,sp,-32
    80003360:	ec06                	sd	ra,24(sp)
    80003362:	e822                	sd	s0,16(sp)
    80003364:	e426                	sd	s1,8(sp)
    80003366:	1000                	addi	s0,sp,32
    80003368:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000336a:	fffff097          	auipc	ra,0xfffff
    8000336e:	9fe080e7          	jalr	-1538(ra) # 80001d68 <myproc>
  switch (n)
    80003372:	4795                	li	a5,5
    80003374:	0497e163          	bltu	a5,s1,800033b6 <argraw+0x58>
    80003378:	048a                	slli	s1,s1,0x2
    8000337a:	00005717          	auipc	a4,0x5
    8000337e:	22670713          	addi	a4,a4,550 # 800085a0 <states.2544+0x288>
    80003382:	94ba                	add	s1,s1,a4
    80003384:	409c                	lw	a5,0(s1)
    80003386:	97ba                	add	a5,a5,a4
    80003388:	8782                	jr	a5
  {
  case 0:
    return p->trapframe->a0;
    8000338a:	713c                	ld	a5,96(a0)
    8000338c:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000338e:	60e2                	ld	ra,24(sp)
    80003390:	6442                	ld	s0,16(sp)
    80003392:	64a2                	ld	s1,8(sp)
    80003394:	6105                	addi	sp,sp,32
    80003396:	8082                	ret
    return p->trapframe->a1;
    80003398:	713c                	ld	a5,96(a0)
    8000339a:	7fa8                	ld	a0,120(a5)
    8000339c:	bfcd                	j	8000338e <argraw+0x30>
    return p->trapframe->a2;
    8000339e:	713c                	ld	a5,96(a0)
    800033a0:	63c8                	ld	a0,128(a5)
    800033a2:	b7f5                	j	8000338e <argraw+0x30>
    return p->trapframe->a3;
    800033a4:	713c                	ld	a5,96(a0)
    800033a6:	67c8                	ld	a0,136(a5)
    800033a8:	b7dd                	j	8000338e <argraw+0x30>
    return p->trapframe->a4;
    800033aa:	713c                	ld	a5,96(a0)
    800033ac:	6bc8                	ld	a0,144(a5)
    800033ae:	b7c5                	j	8000338e <argraw+0x30>
    return p->trapframe->a5;
    800033b0:	713c                	ld	a5,96(a0)
    800033b2:	6fc8                	ld	a0,152(a5)
    800033b4:	bfe9                	j	8000338e <argraw+0x30>
  panic("argraw");
    800033b6:	00005517          	auipc	a0,0x5
    800033ba:	0aa50513          	addi	a0,a0,170 # 80008460 <states.2544+0x148>
    800033be:	ffffd097          	auipc	ra,0xffffd
    800033c2:	186080e7          	jalr	390(ra) # 80000544 <panic>

00000000800033c6 <fetchaddr>:
{
    800033c6:	1101                	addi	sp,sp,-32
    800033c8:	ec06                	sd	ra,24(sp)
    800033ca:	e822                	sd	s0,16(sp)
    800033cc:	e426                	sd	s1,8(sp)
    800033ce:	e04a                	sd	s2,0(sp)
    800033d0:	1000                	addi	s0,sp,32
    800033d2:	84aa                	mv	s1,a0
    800033d4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800033d6:	fffff097          	auipc	ra,0xfffff
    800033da:	992080e7          	jalr	-1646(ra) # 80001d68 <myproc>
  if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800033de:	693c                	ld	a5,80(a0)
    800033e0:	02f4f863          	bgeu	s1,a5,80003410 <fetchaddr+0x4a>
    800033e4:	00848713          	addi	a4,s1,8
    800033e8:	02e7e663          	bltu	a5,a4,80003414 <fetchaddr+0x4e>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800033ec:	46a1                	li	a3,8
    800033ee:	8626                	mv	a2,s1
    800033f0:	85ca                	mv	a1,s2
    800033f2:	6d28                	ld	a0,88(a0)
    800033f4:	ffffe097          	auipc	ra,0xffffe
    800033f8:	504080e7          	jalr	1284(ra) # 800018f8 <copyin>
    800033fc:	00a03533          	snez	a0,a0
    80003400:	40a00533          	neg	a0,a0
}
    80003404:	60e2                	ld	ra,24(sp)
    80003406:	6442                	ld	s0,16(sp)
    80003408:	64a2                	ld	s1,8(sp)
    8000340a:	6902                	ld	s2,0(sp)
    8000340c:	6105                	addi	sp,sp,32
    8000340e:	8082                	ret
    return -1;
    80003410:	557d                	li	a0,-1
    80003412:	bfcd                	j	80003404 <fetchaddr+0x3e>
    80003414:	557d                	li	a0,-1
    80003416:	b7fd                	j	80003404 <fetchaddr+0x3e>

0000000080003418 <fetchstr>:
{
    80003418:	7179                	addi	sp,sp,-48
    8000341a:	f406                	sd	ra,40(sp)
    8000341c:	f022                	sd	s0,32(sp)
    8000341e:	ec26                	sd	s1,24(sp)
    80003420:	e84a                	sd	s2,16(sp)
    80003422:	e44e                	sd	s3,8(sp)
    80003424:	1800                	addi	s0,sp,48
    80003426:	892a                	mv	s2,a0
    80003428:	84ae                	mv	s1,a1
    8000342a:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000342c:	fffff097          	auipc	ra,0xfffff
    80003430:	93c080e7          	jalr	-1732(ra) # 80001d68 <myproc>
  if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80003434:	86ce                	mv	a3,s3
    80003436:	864a                	mv	a2,s2
    80003438:	85a6                	mv	a1,s1
    8000343a:	6d28                	ld	a0,88(a0)
    8000343c:	ffffe097          	auipc	ra,0xffffe
    80003440:	548080e7          	jalr	1352(ra) # 80001984 <copyinstr>
    80003444:	00054e63          	bltz	a0,80003460 <fetchstr+0x48>
  return strlen(buf);
    80003448:	8526                	mv	a0,s1
    8000344a:	ffffe097          	auipc	ra,0xffffe
    8000344e:	bde080e7          	jalr	-1058(ra) # 80001028 <strlen>
}
    80003452:	70a2                	ld	ra,40(sp)
    80003454:	7402                	ld	s0,32(sp)
    80003456:	64e2                	ld	s1,24(sp)
    80003458:	6942                	ld	s2,16(sp)
    8000345a:	69a2                	ld	s3,8(sp)
    8000345c:	6145                	addi	sp,sp,48
    8000345e:	8082                	ret
    return -1;
    80003460:	557d                	li	a0,-1
    80003462:	bfc5                	j	80003452 <fetchstr+0x3a>

0000000080003464 <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80003464:	1101                	addi	sp,sp,-32
    80003466:	ec06                	sd	ra,24(sp)
    80003468:	e822                	sd	s0,16(sp)
    8000346a:	e426                	sd	s1,8(sp)
    8000346c:	1000                	addi	s0,sp,32
    8000346e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003470:	00000097          	auipc	ra,0x0
    80003474:	eee080e7          	jalr	-274(ra) # 8000335e <argraw>
    80003478:	c088                	sw	a0,0(s1)
}
    8000347a:	60e2                	ld	ra,24(sp)
    8000347c:	6442                	ld	s0,16(sp)
    8000347e:	64a2                	ld	s1,8(sp)
    80003480:	6105                	addi	sp,sp,32
    80003482:	8082                	ret

0000000080003484 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80003484:	1101                	addi	sp,sp,-32
    80003486:	ec06                	sd	ra,24(sp)
    80003488:	e822                	sd	s0,16(sp)
    8000348a:	e426                	sd	s1,8(sp)
    8000348c:	1000                	addi	s0,sp,32
    8000348e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003490:	00000097          	auipc	ra,0x0
    80003494:	ece080e7          	jalr	-306(ra) # 8000335e <argraw>
    80003498:	e088                	sd	a0,0(s1)
}
    8000349a:	60e2                	ld	ra,24(sp)
    8000349c:	6442                	ld	s0,16(sp)
    8000349e:	64a2                	ld	s1,8(sp)
    800034a0:	6105                	addi	sp,sp,32
    800034a2:	8082                	ret

00000000800034a4 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    800034a4:	7179                	addi	sp,sp,-48
    800034a6:	f406                	sd	ra,40(sp)
    800034a8:	f022                	sd	s0,32(sp)
    800034aa:	ec26                	sd	s1,24(sp)
    800034ac:	e84a                	sd	s2,16(sp)
    800034ae:	1800                	addi	s0,sp,48
    800034b0:	84ae                	mv	s1,a1
    800034b2:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    800034b4:	fd840593          	addi	a1,s0,-40
    800034b8:	00000097          	auipc	ra,0x0
    800034bc:	fcc080e7          	jalr	-52(ra) # 80003484 <argaddr>
  return fetchstr(addr, buf, max);
    800034c0:	864a                	mv	a2,s2
    800034c2:	85a6                	mv	a1,s1
    800034c4:	fd843503          	ld	a0,-40(s0)
    800034c8:	00000097          	auipc	ra,0x0
    800034cc:	f50080e7          	jalr	-176(ra) # 80003418 <fetchstr>
}
    800034d0:	70a2                	ld	ra,40(sp)
    800034d2:	7402                	ld	s0,32(sp)
    800034d4:	64e2                	ld	s1,24(sp)
    800034d6:	6942                	ld	s2,16(sp)
    800034d8:	6145                	addi	sp,sp,48
    800034da:	8082                	ret

00000000800034dc <syscall>:
        {"sigreturn", 0},

};

void syscall(void)
{
    800034dc:	711d                	addi	sp,sp,-96
    800034de:	ec86                	sd	ra,88(sp)
    800034e0:	e8a2                	sd	s0,80(sp)
    800034e2:	e4a6                	sd	s1,72(sp)
    800034e4:	e0ca                	sd	s2,64(sp)
    800034e6:	fc4e                	sd	s3,56(sp)
    800034e8:	f852                	sd	s4,48(sp)
    800034ea:	f456                	sd	s5,40(sp)
    800034ec:	f05a                	sd	s6,32(sp)
    800034ee:	ec5e                	sd	s7,24(sp)
    800034f0:	e862                	sd	s8,16(sp)
    800034f2:	e466                	sd	s9,8(sp)
    800034f4:	e06a                	sd	s10,0(sp)
    800034f6:	1080                	addi	s0,sp,96
  int num;
  struct proc *p = myproc();
    800034f8:	fffff097          	auipc	ra,0xfffff
    800034fc:	870080e7          	jalr	-1936(ra) # 80001d68 <myproc>
    80003500:	8a2a                	mv	s4,a0

  num = p->trapframe->a7; // return reg
    80003502:	7124                	ld	s1,96(a0)
    80003504:	74dc                	ld	a5,168(s1)
    80003506:	00078b1b          	sext.w	s6,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    8000350a:	37fd                	addiw	a5,a5,-1
    8000350c:	4769                	li	a4,26
    8000350e:	06f76f63          	bltu	a4,a5,8000358c <syscall+0xb0>
    80003512:	003b1713          	slli	a4,s6,0x3
    80003516:	00005797          	auipc	a5,0x5
    8000351a:	0a278793          	addi	a5,a5,162 # 800085b8 <syscalls>
    8000351e:	97ba                	add	a5,a5,a4
    80003520:	0007bd03          	ld	s10,0(a5)
    80003524:	060d0463          	beqz	s10,8000358c <syscall+0xb0>
  {
    80003528:	8c8a                	mv	s9,sp
    int numargs = syscall_info[num - 1].num;
    8000352a:	fffb0c1b          	addiw	s8,s6,-1
    8000352e:	004c1713          	slli	a4,s8,0x4
    80003532:	00005797          	auipc	a5,0x5
    80003536:	4f678793          	addi	a5,a5,1270 # 80008a28 <syscall_info>
    8000353a:	97ba                	add	a5,a5,a4
    8000353c:	0087a983          	lw	s3,8(a5)
    int Args[numargs]; // to store value of registers acc to the number of args of the syscall
    80003540:	00299793          	slli	a5,s3,0x2
    80003544:	07bd                	addi	a5,a5,15
    80003546:	9bc1                	andi	a5,a5,-16
    80003548:	40f10133          	sub	sp,sp,a5
    8000354c:	8b8a                	mv	s7,sp
    int j = 0;
    while (j < numargs)
    8000354e:	11305363          	blez	s3,80003654 <syscall+0x178>
    80003552:	8ade                	mv	s5,s7
    80003554:	895e                	mv	s2,s7
    int j = 0;
    80003556:	4481                	li	s1,0
    {
      Args[j] = argraw(j);
    80003558:	8526                	mv	a0,s1
    8000355a:	00000097          	auipc	ra,0x0
    8000355e:	e04080e7          	jalr	-508(ra) # 8000335e <argraw>
    80003562:	00a92023          	sw	a0,0(s2)
      j++;
    80003566:	2485                	addiw	s1,s1,1
    while (j < numargs)
    80003568:	0911                	addi	s2,s2,4
    8000356a:	fe9997e3          	bne	s3,s1,80003558 <syscall+0x7c>
    }

    int shift = 1 << num; // mask for num
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    8000356e:	060a3483          	ld	s1,96(s4)
    80003572:	9d02                	jalr	s10
    80003574:	f8a8                	sd	a0,112(s1)
    int shift = 1 << num; // mask for num
    80003576:	4785                	li	a5,1
    80003578:	016797bb          	sllw	a5,a5,s6

    if (p->mask & shift)
    8000357c:	000a2b03          	lw	s6,0(s4)
    80003580:	0167f7b3          	and	a5,a5,s6
    80003584:	2781                	sext.w	a5,a5
    80003586:	e7a1                	bnez	a5,800035ce <syscall+0xf2>
    80003588:	8166                	mv	sp,s9
  {
    8000358a:	a015                	j	800035ae <syscall+0xd2>
      printf(" -> %d\n", p->trapframe->a0);
    }
  }
  else
  {
    printf("%d %s: unknown sys call %d\n",
    8000358c:	86da                	mv	a3,s6
    8000358e:	160a0613          	addi	a2,s4,352
    80003592:	038a2583          	lw	a1,56(s4)
    80003596:	00005517          	auipc	a0,0x5
    8000359a:	ee250513          	addi	a0,a0,-286 # 80008478 <states.2544+0x160>
    8000359e:	ffffd097          	auipc	ra,0xffffd
    800035a2:	ff0080e7          	jalr	-16(ra) # 8000058e <printf>
           p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800035a6:	060a3783          	ld	a5,96(s4)
    800035aa:	577d                	li	a4,-1
    800035ac:	fbb8                	sd	a4,112(a5)
  }
}
    800035ae:	fa040113          	addi	sp,s0,-96
    800035b2:	60e6                	ld	ra,88(sp)
    800035b4:	6446                	ld	s0,80(sp)
    800035b6:	64a6                	ld	s1,72(sp)
    800035b8:	6906                	ld	s2,64(sp)
    800035ba:	79e2                	ld	s3,56(sp)
    800035bc:	7a42                	ld	s4,48(sp)
    800035be:	7aa2                	ld	s5,40(sp)
    800035c0:	7b02                	ld	s6,32(sp)
    800035c2:	6be2                	ld	s7,24(sp)
    800035c4:	6c42                	ld	s8,16(sp)
    800035c6:	6ca2                	ld	s9,8(sp)
    800035c8:	6d02                	ld	s10,0(sp)
    800035ca:	6125                	addi	sp,sp,96
    800035cc:	8082                	ret
      printf("%d: syscall %s ", p->pid, syscall_info[num - 1].name);
    800035ce:	0c12                	slli	s8,s8,0x4
    800035d0:	00005797          	auipc	a5,0x5
    800035d4:	45878793          	addi	a5,a5,1112 # 80008a28 <syscall_info>
    800035d8:	9c3e                	add	s8,s8,a5
    800035da:	000c3603          	ld	a2,0(s8)
    800035de:	038a2583          	lw	a1,56(s4)
    800035e2:	00005517          	auipc	a0,0x5
    800035e6:	eb650513          	addi	a0,a0,-330 # 80008498 <states.2544+0x180>
    800035ea:	ffffd097          	auipc	ra,0xffffd
    800035ee:	fa4080e7          	jalr	-92(ra) # 8000058e <printf>
      printf("(");
    800035f2:	00005517          	auipc	a0,0x5
    800035f6:	eb650513          	addi	a0,a0,-330 # 800084a8 <states.2544+0x190>
    800035fa:	ffffd097          	auipc	ra,0xffffd
    800035fe:	f94080e7          	jalr	-108(ra) # 8000058e <printf>
      while (i < numargs)
    80003602:	fff9879b          	addiw	a5,s3,-1
    80003606:	1782                	slli	a5,a5,0x20
    80003608:	9381                	srli	a5,a5,0x20
    8000360a:	0785                	addi	a5,a5,1
    8000360c:	078a                	slli	a5,a5,0x2
    8000360e:	9bbe                	add	s7,s7,a5
        printf("%d ", Args[i]);
    80003610:	00005497          	auipc	s1,0x5
    80003614:	cc048493          	addi	s1,s1,-832 # 800082d0 <digits+0x290>
    80003618:	000aa583          	lw	a1,0(s5)
    8000361c:	8526                	mv	a0,s1
    8000361e:	ffffd097          	auipc	ra,0xffffd
    80003622:	f70080e7          	jalr	-144(ra) # 8000058e <printf>
      while (i < numargs)
    80003626:	0a91                	addi	s5,s5,4
    80003628:	ff7a98e3          	bne	s5,s7,80003618 <syscall+0x13c>
      printf(")");
    8000362c:	00005517          	auipc	a0,0x5
    80003630:	e3c50513          	addi	a0,a0,-452 # 80008468 <states.2544+0x150>
    80003634:	ffffd097          	auipc	ra,0xffffd
    80003638:	f5a080e7          	jalr	-166(ra) # 8000058e <printf>
      printf(" -> %d\n", p->trapframe->a0);
    8000363c:	060a3783          	ld	a5,96(s4)
    80003640:	7bac                	ld	a1,112(a5)
    80003642:	00005517          	auipc	a0,0x5
    80003646:	e2e50513          	addi	a0,a0,-466 # 80008470 <states.2544+0x158>
    8000364a:	ffffd097          	auipc	ra,0xffffd
    8000364e:	f44080e7          	jalr	-188(ra) # 8000058e <printf>
    80003652:	bf1d                	j	80003588 <syscall+0xac>
    p->trapframe->a0 = syscalls[num]();
    80003654:	9d02                	jalr	s10
    80003656:	f8a8                	sd	a0,112(s1)
    int shift = 1 << num; // mask for num
    80003658:	4785                	li	a5,1
    8000365a:	016797bb          	sllw	a5,a5,s6
    if (p->mask & shift)
    8000365e:	000a2703          	lw	a4,0(s4)
    80003662:	8ff9                	and	a5,a5,a4
    80003664:	2781                	sext.w	a5,a5
    80003666:	d38d                	beqz	a5,80003588 <syscall+0xac>
      printf("%d: syscall %s ", p->pid, syscall_info[num - 1].name);
    80003668:	0c12                	slli	s8,s8,0x4
    8000366a:	00005797          	auipc	a5,0x5
    8000366e:	3be78793          	addi	a5,a5,958 # 80008a28 <syscall_info>
    80003672:	97e2                	add	a5,a5,s8
    80003674:	6390                	ld	a2,0(a5)
    80003676:	038a2583          	lw	a1,56(s4)
    8000367a:	00005517          	auipc	a0,0x5
    8000367e:	e1e50513          	addi	a0,a0,-482 # 80008498 <states.2544+0x180>
    80003682:	ffffd097          	auipc	ra,0xffffd
    80003686:	f0c080e7          	jalr	-244(ra) # 8000058e <printf>
      printf("(");
    8000368a:	00005517          	auipc	a0,0x5
    8000368e:	e1e50513          	addi	a0,a0,-482 # 800084a8 <states.2544+0x190>
    80003692:	ffffd097          	auipc	ra,0xffffd
    80003696:	efc080e7          	jalr	-260(ra) # 8000058e <printf>
      while (i < numargs)
    8000369a:	bf49                	j	8000362c <syscall+0x150>

000000008000369c <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    8000369c:	1101                	addi	sp,sp,-32
    8000369e:	ec06                	sd	ra,24(sp)
    800036a0:	e822                	sd	s0,16(sp)
    800036a2:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800036a4:	fec40593          	addi	a1,s0,-20
    800036a8:	4501                	li	a0,0
    800036aa:	00000097          	auipc	ra,0x0
    800036ae:	dba080e7          	jalr	-582(ra) # 80003464 <argint>
  exit(n);
    800036b2:	fec42503          	lw	a0,-20(s0)
    800036b6:	fffff097          	auipc	ra,0xfffff
    800036ba:	3b0080e7          	jalr	944(ra) # 80002a66 <exit>
  return 0; // not reached
}
    800036be:	4501                	li	a0,0
    800036c0:	60e2                	ld	ra,24(sp)
    800036c2:	6442                	ld	s0,16(sp)
    800036c4:	6105                	addi	sp,sp,32
    800036c6:	8082                	ret

00000000800036c8 <sys_getpid>:

uint64
sys_getpid(void)
{
    800036c8:	1141                	addi	sp,sp,-16
    800036ca:	e406                	sd	ra,8(sp)
    800036cc:	e022                	sd	s0,0(sp)
    800036ce:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800036d0:	ffffe097          	auipc	ra,0xffffe
    800036d4:	698080e7          	jalr	1688(ra) # 80001d68 <myproc>
}
    800036d8:	5d08                	lw	a0,56(a0)
    800036da:	60a2                	ld	ra,8(sp)
    800036dc:	6402                	ld	s0,0(sp)
    800036de:	0141                	addi	sp,sp,16
    800036e0:	8082                	ret

00000000800036e2 <sys_fork>:

uint64
sys_fork(void)
{
    800036e2:	1141                	addi	sp,sp,-16
    800036e4:	e406                	sd	ra,8(sp)
    800036e6:	e022                	sd	s0,0(sp)
    800036e8:	0800                	addi	s0,sp,16
  return fork();
    800036ea:	fffff097          	auipc	ra,0xfffff
    800036ee:	e16080e7          	jalr	-490(ra) # 80002500 <fork>
}
    800036f2:	60a2                	ld	ra,8(sp)
    800036f4:	6402                	ld	s0,0(sp)
    800036f6:	0141                	addi	sp,sp,16
    800036f8:	8082                	ret

00000000800036fa <sys_wait>:

uint64
sys_wait(void)
{
    800036fa:	1101                	addi	sp,sp,-32
    800036fc:	ec06                	sd	ra,24(sp)
    800036fe:	e822                	sd	s0,16(sp)
    80003700:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80003702:	fe840593          	addi	a1,s0,-24
    80003706:	4501                	li	a0,0
    80003708:	00000097          	auipc	ra,0x0
    8000370c:	d7c080e7          	jalr	-644(ra) # 80003484 <argaddr>
  return wait(p);
    80003710:	fe843503          	ld	a0,-24(s0)
    80003714:	fffff097          	auipc	ra,0xfffff
    80003718:	112080e7          	jalr	274(ra) # 80002826 <wait>
}
    8000371c:	60e2                	ld	ra,24(sp)
    8000371e:	6442                	ld	s0,16(sp)
    80003720:	6105                	addi	sp,sp,32
    80003722:	8082                	ret

0000000080003724 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003724:	7179                	addi	sp,sp,-48
    80003726:	f406                	sd	ra,40(sp)
    80003728:	f022                	sd	s0,32(sp)
    8000372a:	ec26                	sd	s1,24(sp)
    8000372c:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    8000372e:	fdc40593          	addi	a1,s0,-36
    80003732:	4501                	li	a0,0
    80003734:	00000097          	auipc	ra,0x0
    80003738:	d30080e7          	jalr	-720(ra) # 80003464 <argint>
  addr = myproc()->sz;
    8000373c:	ffffe097          	auipc	ra,0xffffe
    80003740:	62c080e7          	jalr	1580(ra) # 80001d68 <myproc>
    80003744:	6924                	ld	s1,80(a0)
  if (growproc(n) < 0)
    80003746:	fdc42503          	lw	a0,-36(s0)
    8000374a:	fffff097          	auipc	ra,0xfffff
    8000374e:	9de080e7          	jalr	-1570(ra) # 80002128 <growproc>
    80003752:	00054863          	bltz	a0,80003762 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80003756:	8526                	mv	a0,s1
    80003758:	70a2                	ld	ra,40(sp)
    8000375a:	7402                	ld	s0,32(sp)
    8000375c:	64e2                	ld	s1,24(sp)
    8000375e:	6145                	addi	sp,sp,48
    80003760:	8082                	ret
    return -1;
    80003762:	54fd                	li	s1,-1
    80003764:	bfcd                	j	80003756 <sys_sbrk+0x32>

0000000080003766 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003766:	7139                	addi	sp,sp,-64
    80003768:	fc06                	sd	ra,56(sp)
    8000376a:	f822                	sd	s0,48(sp)
    8000376c:	f426                	sd	s1,40(sp)
    8000376e:	f04a                	sd	s2,32(sp)
    80003770:	ec4e                	sd	s3,24(sp)
    80003772:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80003774:	fcc40593          	addi	a1,s0,-52
    80003778:	4501                	li	a0,0
    8000377a:	00000097          	auipc	ra,0x0
    8000377e:	cea080e7          	jalr	-790(ra) # 80003464 <argint>
  acquire(&tickslock);
    80003782:	00235517          	auipc	a0,0x235
    80003786:	76650513          	addi	a0,a0,1894 # 80238ee8 <tickslock>
    8000378a:	ffffd097          	auipc	ra,0xffffd
    8000378e:	61e080e7          	jalr	1566(ra) # 80000da8 <acquire>
  ticks0 = ticks;
    80003792:	00005917          	auipc	s2,0x5
    80003796:	49e92903          	lw	s2,1182(s2) # 80008c30 <ticks>
  while (ticks - ticks0 < n)
    8000379a:	fcc42783          	lw	a5,-52(s0)
    8000379e:	cf9d                	beqz	a5,800037dc <sys_sleep+0x76>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800037a0:	00235997          	auipc	s3,0x235
    800037a4:	74898993          	addi	s3,s3,1864 # 80238ee8 <tickslock>
    800037a8:	00005497          	auipc	s1,0x5
    800037ac:	48848493          	addi	s1,s1,1160 # 80008c30 <ticks>
    if (killed(myproc()))
    800037b0:	ffffe097          	auipc	ra,0xffffe
    800037b4:	5b8080e7          	jalr	1464(ra) # 80001d68 <myproc>
    800037b8:	fffff097          	auipc	ra,0xfffff
    800037bc:	458080e7          	jalr	1112(ra) # 80002c10 <killed>
    800037c0:	ed15                	bnez	a0,800037fc <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    800037c2:	85ce                	mv	a1,s3
    800037c4:	8526                	mv	a0,s1
    800037c6:	fffff097          	auipc	ra,0xfffff
    800037ca:	e9e080e7          	jalr	-354(ra) # 80002664 <sleep>
  while (ticks - ticks0 < n)
    800037ce:	409c                	lw	a5,0(s1)
    800037d0:	412787bb          	subw	a5,a5,s2
    800037d4:	fcc42703          	lw	a4,-52(s0)
    800037d8:	fce7ece3          	bltu	a5,a4,800037b0 <sys_sleep+0x4a>
  }
  release(&tickslock);
    800037dc:	00235517          	auipc	a0,0x235
    800037e0:	70c50513          	addi	a0,a0,1804 # 80238ee8 <tickslock>
    800037e4:	ffffd097          	auipc	ra,0xffffd
    800037e8:	678080e7          	jalr	1656(ra) # 80000e5c <release>
  return 0;
    800037ec:	4501                	li	a0,0
}
    800037ee:	70e2                	ld	ra,56(sp)
    800037f0:	7442                	ld	s0,48(sp)
    800037f2:	74a2                	ld	s1,40(sp)
    800037f4:	7902                	ld	s2,32(sp)
    800037f6:	69e2                	ld	s3,24(sp)
    800037f8:	6121                	addi	sp,sp,64
    800037fa:	8082                	ret
      release(&tickslock);
    800037fc:	00235517          	auipc	a0,0x235
    80003800:	6ec50513          	addi	a0,a0,1772 # 80238ee8 <tickslock>
    80003804:	ffffd097          	auipc	ra,0xffffd
    80003808:	658080e7          	jalr	1624(ra) # 80000e5c <release>
      return -1;
    8000380c:	557d                	li	a0,-1
    8000380e:	b7c5                	j	800037ee <sys_sleep+0x88>

0000000080003810 <sys_kill>:

uint64
sys_kill(void)
{
    80003810:	1101                	addi	sp,sp,-32
    80003812:	ec06                	sd	ra,24(sp)
    80003814:	e822                	sd	s0,16(sp)
    80003816:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80003818:	fec40593          	addi	a1,s0,-20
    8000381c:	4501                	li	a0,0
    8000381e:	00000097          	auipc	ra,0x0
    80003822:	c46080e7          	jalr	-954(ra) # 80003464 <argint>
  return kill(pid);
    80003826:	fec42503          	lw	a0,-20(s0)
    8000382a:	fffff097          	auipc	ra,0xfffff
    8000382e:	320080e7          	jalr	800(ra) # 80002b4a <kill>
}
    80003832:	60e2                	ld	ra,24(sp)
    80003834:	6442                	ld	s0,16(sp)
    80003836:	6105                	addi	sp,sp,32
    80003838:	8082                	ret

000000008000383a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000383a:	1101                	addi	sp,sp,-32
    8000383c:	ec06                	sd	ra,24(sp)
    8000383e:	e822                	sd	s0,16(sp)
    80003840:	e426                	sd	s1,8(sp)
    80003842:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003844:	00235517          	auipc	a0,0x235
    80003848:	6a450513          	addi	a0,a0,1700 # 80238ee8 <tickslock>
    8000384c:	ffffd097          	auipc	ra,0xffffd
    80003850:	55c080e7          	jalr	1372(ra) # 80000da8 <acquire>
  xticks = ticks;
    80003854:	00005497          	auipc	s1,0x5
    80003858:	3dc4a483          	lw	s1,988(s1) # 80008c30 <ticks>
  release(&tickslock);
    8000385c:	00235517          	auipc	a0,0x235
    80003860:	68c50513          	addi	a0,a0,1676 # 80238ee8 <tickslock>
    80003864:	ffffd097          	auipc	ra,0xffffd
    80003868:	5f8080e7          	jalr	1528(ra) # 80000e5c <release>
  return xticks;
}
    8000386c:	02049513          	slli	a0,s1,0x20
    80003870:	9101                	srli	a0,a0,0x20
    80003872:	60e2                	ld	ra,24(sp)
    80003874:	6442                	ld	s0,16(sp)
    80003876:	64a2                	ld	s1,8(sp)
    80003878:	6105                	addi	sp,sp,32
    8000387a:	8082                	ret

000000008000387c <sys_trace>:

uint64
sys_trace(void)
{
    8000387c:	1101                	addi	sp,sp,-32
    8000387e:	ec06                	sd	ra,24(sp)
    80003880:	e822                	sd	s0,16(sp)
    80003882:	1000                	addi	s0,sp,32
  int n; // mask
  argint(0, &n);
    80003884:	fec40593          	addi	a1,s0,-20
    80003888:	4501                	li	a0,0
    8000388a:	00000097          	auipc	ra,0x0
    8000388e:	bda080e7          	jalr	-1062(ra) # 80003464 <argint>
  myproc()->mask = n;
    80003892:	ffffe097          	auipc	ra,0xffffe
    80003896:	4d6080e7          	jalr	1238(ra) # 80001d68 <myproc>
    8000389a:	fec42783          	lw	a5,-20(s0)
    8000389e:	c11c                	sw	a5,0(a0)
  return 0;
}
    800038a0:	4501                	li	a0,0
    800038a2:	60e2                	ld	ra,24(sp)
    800038a4:	6442                	ld	s0,16(sp)
    800038a6:	6105                	addi	sp,sp,32
    800038a8:	8082                	ret

00000000800038aa <sys_setpriority>:

uint64
sys_setpriority(void)
{
    800038aa:	1101                	addi	sp,sp,-32
    800038ac:	ec06                	sd	ra,24(sp)
    800038ae:	e822                	sd	s0,16(sp)
    800038b0:	1000                	addi	s0,sp,32
  int priority;
  int pid;
  argint(0, &priority);
    800038b2:	fec40593          	addi	a1,s0,-20
    800038b6:	4501                	li	a0,0
    800038b8:	00000097          	auipc	ra,0x0
    800038bc:	bac080e7          	jalr	-1108(ra) # 80003464 <argint>
  argint(1, &pid);
    800038c0:	fe840593          	addi	a1,s0,-24
    800038c4:	4505                	li	a0,1
    800038c6:	00000097          	auipc	ra,0x0
    800038ca:	b9e080e7          	jalr	-1122(ra) # 80003464 <argint>
  return set_priority(priority, pid);
    800038ce:	fe842583          	lw	a1,-24(s0)
    800038d2:	fec42503          	lw	a0,-20(s0)
    800038d6:	ffffe097          	auipc	ra,0xffffe
    800038da:	260080e7          	jalr	608(ra) # 80001b36 <set_priority>
}
    800038de:	60e2                	ld	ra,24(sp)
    800038e0:	6442                	ld	s0,16(sp)
    800038e2:	6105                	addi	sp,sp,32
    800038e4:	8082                	ret

00000000800038e6 <sys_settickets>:

uint64
sys_settickets(void){
    800038e6:	1101                	addi	sp,sp,-32
    800038e8:	ec06                	sd	ra,24(sp)
    800038ea:	e822                	sd	s0,16(sp)
    800038ec:	1000                	addi	s0,sp,32
  int n; // tickets
  argint(0, &n);
    800038ee:	fec40593          	addi	a1,s0,-20
    800038f2:	4501                	li	a0,0
    800038f4:	00000097          	auipc	ra,0x0
    800038f8:	b70080e7          	jalr	-1168(ra) # 80003464 <argint>
  myproc()->tickets = n;
    800038fc:	ffffe097          	auipc	ra,0xffffe
    80003900:	46c080e7          	jalr	1132(ra) # 80001d68 <myproc>
    80003904:	fec42783          	lw	a5,-20(s0)
    80003908:	18f52623          	sw	a5,396(a0)
  return 0;
}
    8000390c:	4501                	li	a0,0
    8000390e:	60e2                	ld	ra,24(sp)
    80003910:	6442                	ld	s0,16(sp)
    80003912:	6105                	addi	sp,sp,32
    80003914:	8082                	ret

0000000080003916 <sys_waitx>:

uint64
sys_waitx(void)
{
    80003916:	7139                	addi	sp,sp,-64
    80003918:	fc06                	sd	ra,56(sp)
    8000391a:	f822                	sd	s0,48(sp)
    8000391c:	f426                	sd	s1,40(sp)
    8000391e:	f04a                	sd	s2,32(sp)
    80003920:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    80003922:	fd840593          	addi	a1,s0,-40
    80003926:	4501                	li	a0,0
    80003928:	00000097          	auipc	ra,0x0
    8000392c:	b5c080e7          	jalr	-1188(ra) # 80003484 <argaddr>
  argaddr(1, &addr1); // user virtual memory
    80003930:	fd040593          	addi	a1,s0,-48
    80003934:	4505                	li	a0,1
    80003936:	00000097          	auipc	ra,0x0
    8000393a:	b4e080e7          	jalr	-1202(ra) # 80003484 <argaddr>
  argaddr(2, &addr2);
    8000393e:	fc840593          	addi	a1,s0,-56
    80003942:	4509                	li	a0,2
    80003944:	00000097          	auipc	ra,0x0
    80003948:	b40080e7          	jalr	-1216(ra) # 80003484 <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    8000394c:	fc040613          	addi	a2,s0,-64
    80003950:	fc440593          	addi	a1,s0,-60
    80003954:	fd843503          	ld	a0,-40(s0)
    80003958:	fffff097          	auipc	ra,0xfffff
    8000395c:	d7a080e7          	jalr	-646(ra) # 800026d2 <waitx>
    80003960:	892a                	mv	s2,a0
  struct proc* p = myproc();
    80003962:	ffffe097          	auipc	ra,0xffffe
    80003966:	406080e7          	jalr	1030(ra) # 80001d68 <myproc>
    8000396a:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    8000396c:	4691                	li	a3,4
    8000396e:	fc440613          	addi	a2,s0,-60
    80003972:	fd043583          	ld	a1,-48(s0)
    80003976:	6d28                	ld	a0,88(a0)
    80003978:	ffffe097          	auipc	ra,0xffffe
    8000397c:	ec0080e7          	jalr	-320(ra) # 80001838 <copyout>
    return -1;
    80003980:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    80003982:	00054f63          	bltz	a0,800039a0 <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2,(char*)&rtime, sizeof(int)) < 0)
    80003986:	4691                	li	a3,4
    80003988:	fc040613          	addi	a2,s0,-64
    8000398c:	fc843583          	ld	a1,-56(s0)
    80003990:	6ca8                	ld	a0,88(s1)
    80003992:	ffffe097          	auipc	ra,0xffffe
    80003996:	ea6080e7          	jalr	-346(ra) # 80001838 <copyout>
    8000399a:	00054a63          	bltz	a0,800039ae <sys_waitx+0x98>
    return -1;
  return ret;
    8000399e:	87ca                	mv	a5,s2
}
    800039a0:	853e                	mv	a0,a5
    800039a2:	70e2                	ld	ra,56(sp)
    800039a4:	7442                	ld	s0,48(sp)
    800039a6:	74a2                	ld	s1,40(sp)
    800039a8:	7902                	ld	s2,32(sp)
    800039aa:	6121                	addi	sp,sp,64
    800039ac:	8082                	ret
    return -1;
    800039ae:	57fd                	li	a5,-1
    800039b0:	bfc5                	j	800039a0 <sys_waitx+0x8a>

00000000800039b2 <sys_sigalarm>:
uint64 sys_sigalarm(void)
{
    800039b2:	1101                	addi	sp,sp,-32
    800039b4:	ec06                	sd	ra,24(sp)
    800039b6:	e822                	sd	s0,16(sp)
    800039b8:	1000                	addi	s0,sp,32
  uint64 addr;
  int ticks;
  argint(0, &ticks);
    800039ba:	fe440593          	addi	a1,s0,-28
    800039be:	4501                	li	a0,0
    800039c0:	00000097          	auipc	ra,0x0
    800039c4:	aa4080e7          	jalr	-1372(ra) # 80003464 <argint>
  argaddr(1, &addr);
    800039c8:	fe840593          	addi	a1,s0,-24
    800039cc:	4505                	li	a0,1
    800039ce:	00000097          	auipc	ra,0x0
    800039d2:	ab6080e7          	jalr	-1354(ra) # 80003484 <argaddr>
  // if(argaddr(1, &addr) < 0)
  //   return -1;

  myproc()->maxticks = ticks;
    800039d6:	ffffe097          	auipc	ra,0xffffe
    800039da:	392080e7          	jalr	914(ra) # 80001d68 <myproc>
    800039de:	fe442783          	lw	a5,-28(s0)
    800039e2:	18f52423          	sw	a5,392(a0)
  myproc()->handler = addr;
    800039e6:	ffffe097          	auipc	ra,0xffffe
    800039ea:	382080e7          	jalr	898(ra) # 80001d68 <myproc>
    800039ee:	fe843783          	ld	a5,-24(s0)
    800039f2:	16f53c23          	sd	a5,376(a0)

  return 0;
}
    800039f6:	4501                	li	a0,0
    800039f8:	60e2                	ld	ra,24(sp)
    800039fa:	6442                	ld	s0,16(sp)
    800039fc:	6105                	addi	sp,sp,32
    800039fe:	8082                	ret

0000000080003a00 <sys_sigreturn>:
uint64 sys_sigreturn(void)
{
    80003a00:	1101                	addi	sp,sp,-32
    80003a02:	ec06                	sd	ra,24(sp)
    80003a04:	e822                	sd	s0,16(sp)
    80003a06:	e426                	sd	s1,8(sp)
    80003a08:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80003a0a:	ffffe097          	auipc	ra,0xffffe
    80003a0e:	35e080e7          	jalr	862(ra) # 80001d68 <myproc>
    80003a12:	84aa                	mv	s1,a0
  memmove(p->trapframe, p->alarm_handler, PGSIZE);
    80003a14:	6605                	lui	a2,0x1
    80003a16:	17053583          	ld	a1,368(a0)
    80003a1a:	7128                	ld	a0,96(a0)
    80003a1c:	ffffd097          	auipc	ra,0xffffd
    80003a20:	4e8080e7          	jalr	1256(ra) # 80000f04 <memmove>

  kfree(p->alarm_handler);
    80003a24:	1704b503          	ld	a0,368(s1)
    80003a28:	ffffd097          	auipc	ra,0xffffd
    80003a2c:	0a6080e7          	jalr	166(ra) # 80000ace <kfree>
  p->alarm_handler = 0;
    80003a30:	1604b823          	sd	zero,368(s1)
  p->checkifAlarmOn = 0;
    80003a34:	1804a023          	sw	zero,384(s1)
  p->sigticks = 0;
    80003a38:	1804a223          	sw	zero,388(s1)
  return p->trapframe->a0;
    80003a3c:	70bc                	ld	a5,96(s1)
    80003a3e:	7ba8                	ld	a0,112(a5)
    80003a40:	60e2                	ld	ra,24(sp)
    80003a42:	6442                	ld	s0,16(sp)
    80003a44:	64a2                	ld	s1,8(sp)
    80003a46:	6105                	addi	sp,sp,32
    80003a48:	8082                	ret

0000000080003a4a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003a4a:	7179                	addi	sp,sp,-48
    80003a4c:	f406                	sd	ra,40(sp)
    80003a4e:	f022                	sd	s0,32(sp)
    80003a50:	ec26                	sd	s1,24(sp)
    80003a52:	e84a                	sd	s2,16(sp)
    80003a54:	e44e                	sd	s3,8(sp)
    80003a56:	e052                	sd	s4,0(sp)
    80003a58:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003a5a:	00005597          	auipc	a1,0x5
    80003a5e:	c3e58593          	addi	a1,a1,-962 # 80008698 <syscalls+0xe0>
    80003a62:	00235517          	auipc	a0,0x235
    80003a66:	49e50513          	addi	a0,a0,1182 # 80238f00 <bcache>
    80003a6a:	ffffd097          	auipc	ra,0xffffd
    80003a6e:	2ae080e7          	jalr	686(ra) # 80000d18 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003a72:	0023d797          	auipc	a5,0x23d
    80003a76:	48e78793          	addi	a5,a5,1166 # 80240f00 <bcache+0x8000>
    80003a7a:	0023d717          	auipc	a4,0x23d
    80003a7e:	6ee70713          	addi	a4,a4,1774 # 80241168 <bcache+0x8268>
    80003a82:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003a86:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003a8a:	00235497          	auipc	s1,0x235
    80003a8e:	48e48493          	addi	s1,s1,1166 # 80238f18 <bcache+0x18>
    b->next = bcache.head.next;
    80003a92:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003a94:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003a96:	00005a17          	auipc	s4,0x5
    80003a9a:	c0aa0a13          	addi	s4,s4,-1014 # 800086a0 <syscalls+0xe8>
    b->next = bcache.head.next;
    80003a9e:	2b893783          	ld	a5,696(s2)
    80003aa2:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003aa4:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003aa8:	85d2                	mv	a1,s4
    80003aaa:	01048513          	addi	a0,s1,16
    80003aae:	00001097          	auipc	ra,0x1
    80003ab2:	4c4080e7          	jalr	1220(ra) # 80004f72 <initsleeplock>
    bcache.head.next->prev = b;
    80003ab6:	2b893783          	ld	a5,696(s2)
    80003aba:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003abc:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003ac0:	45848493          	addi	s1,s1,1112
    80003ac4:	fd349de3          	bne	s1,s3,80003a9e <binit+0x54>
  }
}
    80003ac8:	70a2                	ld	ra,40(sp)
    80003aca:	7402                	ld	s0,32(sp)
    80003acc:	64e2                	ld	s1,24(sp)
    80003ace:	6942                	ld	s2,16(sp)
    80003ad0:	69a2                	ld	s3,8(sp)
    80003ad2:	6a02                	ld	s4,0(sp)
    80003ad4:	6145                	addi	sp,sp,48
    80003ad6:	8082                	ret

0000000080003ad8 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003ad8:	7179                	addi	sp,sp,-48
    80003ada:	f406                	sd	ra,40(sp)
    80003adc:	f022                	sd	s0,32(sp)
    80003ade:	ec26                	sd	s1,24(sp)
    80003ae0:	e84a                	sd	s2,16(sp)
    80003ae2:	e44e                	sd	s3,8(sp)
    80003ae4:	1800                	addi	s0,sp,48
    80003ae6:	89aa                	mv	s3,a0
    80003ae8:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80003aea:	00235517          	auipc	a0,0x235
    80003aee:	41650513          	addi	a0,a0,1046 # 80238f00 <bcache>
    80003af2:	ffffd097          	auipc	ra,0xffffd
    80003af6:	2b6080e7          	jalr	694(ra) # 80000da8 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003afa:	0023d497          	auipc	s1,0x23d
    80003afe:	6be4b483          	ld	s1,1726(s1) # 802411b8 <bcache+0x82b8>
    80003b02:	0023d797          	auipc	a5,0x23d
    80003b06:	66678793          	addi	a5,a5,1638 # 80241168 <bcache+0x8268>
    80003b0a:	02f48f63          	beq	s1,a5,80003b48 <bread+0x70>
    80003b0e:	873e                	mv	a4,a5
    80003b10:	a021                	j	80003b18 <bread+0x40>
    80003b12:	68a4                	ld	s1,80(s1)
    80003b14:	02e48a63          	beq	s1,a4,80003b48 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003b18:	449c                	lw	a5,8(s1)
    80003b1a:	ff379ce3          	bne	a5,s3,80003b12 <bread+0x3a>
    80003b1e:	44dc                	lw	a5,12(s1)
    80003b20:	ff2799e3          	bne	a5,s2,80003b12 <bread+0x3a>
      b->refcnt++;
    80003b24:	40bc                	lw	a5,64(s1)
    80003b26:	2785                	addiw	a5,a5,1
    80003b28:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003b2a:	00235517          	auipc	a0,0x235
    80003b2e:	3d650513          	addi	a0,a0,982 # 80238f00 <bcache>
    80003b32:	ffffd097          	auipc	ra,0xffffd
    80003b36:	32a080e7          	jalr	810(ra) # 80000e5c <release>
      acquiresleep(&b->lock);
    80003b3a:	01048513          	addi	a0,s1,16
    80003b3e:	00001097          	auipc	ra,0x1
    80003b42:	46e080e7          	jalr	1134(ra) # 80004fac <acquiresleep>
      return b;
    80003b46:	a8b9                	j	80003ba4 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003b48:	0023d497          	auipc	s1,0x23d
    80003b4c:	6684b483          	ld	s1,1640(s1) # 802411b0 <bcache+0x82b0>
    80003b50:	0023d797          	auipc	a5,0x23d
    80003b54:	61878793          	addi	a5,a5,1560 # 80241168 <bcache+0x8268>
    80003b58:	00f48863          	beq	s1,a5,80003b68 <bread+0x90>
    80003b5c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003b5e:	40bc                	lw	a5,64(s1)
    80003b60:	cf81                	beqz	a5,80003b78 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003b62:	64a4                	ld	s1,72(s1)
    80003b64:	fee49de3          	bne	s1,a4,80003b5e <bread+0x86>
  panic("bget: no buffers");
    80003b68:	00005517          	auipc	a0,0x5
    80003b6c:	b4050513          	addi	a0,a0,-1216 # 800086a8 <syscalls+0xf0>
    80003b70:	ffffd097          	auipc	ra,0xffffd
    80003b74:	9d4080e7          	jalr	-1580(ra) # 80000544 <panic>
      b->dev = dev;
    80003b78:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80003b7c:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80003b80:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003b84:	4785                	li	a5,1
    80003b86:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003b88:	00235517          	auipc	a0,0x235
    80003b8c:	37850513          	addi	a0,a0,888 # 80238f00 <bcache>
    80003b90:	ffffd097          	auipc	ra,0xffffd
    80003b94:	2cc080e7          	jalr	716(ra) # 80000e5c <release>
      acquiresleep(&b->lock);
    80003b98:	01048513          	addi	a0,s1,16
    80003b9c:	00001097          	auipc	ra,0x1
    80003ba0:	410080e7          	jalr	1040(ra) # 80004fac <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003ba4:	409c                	lw	a5,0(s1)
    80003ba6:	cb89                	beqz	a5,80003bb8 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003ba8:	8526                	mv	a0,s1
    80003baa:	70a2                	ld	ra,40(sp)
    80003bac:	7402                	ld	s0,32(sp)
    80003bae:	64e2                	ld	s1,24(sp)
    80003bb0:	6942                	ld	s2,16(sp)
    80003bb2:	69a2                	ld	s3,8(sp)
    80003bb4:	6145                	addi	sp,sp,48
    80003bb6:	8082                	ret
    virtio_disk_rw(b, 0);
    80003bb8:	4581                	li	a1,0
    80003bba:	8526                	mv	a0,s1
    80003bbc:	00003097          	auipc	ra,0x3
    80003bc0:	fcc080e7          	jalr	-52(ra) # 80006b88 <virtio_disk_rw>
    b->valid = 1;
    80003bc4:	4785                	li	a5,1
    80003bc6:	c09c                	sw	a5,0(s1)
  return b;
    80003bc8:	b7c5                	j	80003ba8 <bread+0xd0>

0000000080003bca <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003bca:	1101                	addi	sp,sp,-32
    80003bcc:	ec06                	sd	ra,24(sp)
    80003bce:	e822                	sd	s0,16(sp)
    80003bd0:	e426                	sd	s1,8(sp)
    80003bd2:	1000                	addi	s0,sp,32
    80003bd4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003bd6:	0541                	addi	a0,a0,16
    80003bd8:	00001097          	auipc	ra,0x1
    80003bdc:	46e080e7          	jalr	1134(ra) # 80005046 <holdingsleep>
    80003be0:	cd01                	beqz	a0,80003bf8 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003be2:	4585                	li	a1,1
    80003be4:	8526                	mv	a0,s1
    80003be6:	00003097          	auipc	ra,0x3
    80003bea:	fa2080e7          	jalr	-94(ra) # 80006b88 <virtio_disk_rw>
}
    80003bee:	60e2                	ld	ra,24(sp)
    80003bf0:	6442                	ld	s0,16(sp)
    80003bf2:	64a2                	ld	s1,8(sp)
    80003bf4:	6105                	addi	sp,sp,32
    80003bf6:	8082                	ret
    panic("bwrite");
    80003bf8:	00005517          	auipc	a0,0x5
    80003bfc:	ac850513          	addi	a0,a0,-1336 # 800086c0 <syscalls+0x108>
    80003c00:	ffffd097          	auipc	ra,0xffffd
    80003c04:	944080e7          	jalr	-1724(ra) # 80000544 <panic>

0000000080003c08 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003c08:	1101                	addi	sp,sp,-32
    80003c0a:	ec06                	sd	ra,24(sp)
    80003c0c:	e822                	sd	s0,16(sp)
    80003c0e:	e426                	sd	s1,8(sp)
    80003c10:	e04a                	sd	s2,0(sp)
    80003c12:	1000                	addi	s0,sp,32
    80003c14:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003c16:	01050913          	addi	s2,a0,16
    80003c1a:	854a                	mv	a0,s2
    80003c1c:	00001097          	auipc	ra,0x1
    80003c20:	42a080e7          	jalr	1066(ra) # 80005046 <holdingsleep>
    80003c24:	c92d                	beqz	a0,80003c96 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003c26:	854a                	mv	a0,s2
    80003c28:	00001097          	auipc	ra,0x1
    80003c2c:	3da080e7          	jalr	986(ra) # 80005002 <releasesleep>

  acquire(&bcache.lock);
    80003c30:	00235517          	auipc	a0,0x235
    80003c34:	2d050513          	addi	a0,a0,720 # 80238f00 <bcache>
    80003c38:	ffffd097          	auipc	ra,0xffffd
    80003c3c:	170080e7          	jalr	368(ra) # 80000da8 <acquire>
  b->refcnt--;
    80003c40:	40bc                	lw	a5,64(s1)
    80003c42:	37fd                	addiw	a5,a5,-1
    80003c44:	0007871b          	sext.w	a4,a5
    80003c48:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003c4a:	eb05                	bnez	a4,80003c7a <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003c4c:	68bc                	ld	a5,80(s1)
    80003c4e:	64b8                	ld	a4,72(s1)
    80003c50:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003c52:	64bc                	ld	a5,72(s1)
    80003c54:	68b8                	ld	a4,80(s1)
    80003c56:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003c58:	0023d797          	auipc	a5,0x23d
    80003c5c:	2a878793          	addi	a5,a5,680 # 80240f00 <bcache+0x8000>
    80003c60:	2b87b703          	ld	a4,696(a5)
    80003c64:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003c66:	0023d717          	auipc	a4,0x23d
    80003c6a:	50270713          	addi	a4,a4,1282 # 80241168 <bcache+0x8268>
    80003c6e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003c70:	2b87b703          	ld	a4,696(a5)
    80003c74:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003c76:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003c7a:	00235517          	auipc	a0,0x235
    80003c7e:	28650513          	addi	a0,a0,646 # 80238f00 <bcache>
    80003c82:	ffffd097          	auipc	ra,0xffffd
    80003c86:	1da080e7          	jalr	474(ra) # 80000e5c <release>
}
    80003c8a:	60e2                	ld	ra,24(sp)
    80003c8c:	6442                	ld	s0,16(sp)
    80003c8e:	64a2                	ld	s1,8(sp)
    80003c90:	6902                	ld	s2,0(sp)
    80003c92:	6105                	addi	sp,sp,32
    80003c94:	8082                	ret
    panic("brelse");
    80003c96:	00005517          	auipc	a0,0x5
    80003c9a:	a3250513          	addi	a0,a0,-1486 # 800086c8 <syscalls+0x110>
    80003c9e:	ffffd097          	auipc	ra,0xffffd
    80003ca2:	8a6080e7          	jalr	-1882(ra) # 80000544 <panic>

0000000080003ca6 <bpin>:

void
bpin(struct buf *b) {
    80003ca6:	1101                	addi	sp,sp,-32
    80003ca8:	ec06                	sd	ra,24(sp)
    80003caa:	e822                	sd	s0,16(sp)
    80003cac:	e426                	sd	s1,8(sp)
    80003cae:	1000                	addi	s0,sp,32
    80003cb0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003cb2:	00235517          	auipc	a0,0x235
    80003cb6:	24e50513          	addi	a0,a0,590 # 80238f00 <bcache>
    80003cba:	ffffd097          	auipc	ra,0xffffd
    80003cbe:	0ee080e7          	jalr	238(ra) # 80000da8 <acquire>
  b->refcnt++;
    80003cc2:	40bc                	lw	a5,64(s1)
    80003cc4:	2785                	addiw	a5,a5,1
    80003cc6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003cc8:	00235517          	auipc	a0,0x235
    80003ccc:	23850513          	addi	a0,a0,568 # 80238f00 <bcache>
    80003cd0:	ffffd097          	auipc	ra,0xffffd
    80003cd4:	18c080e7          	jalr	396(ra) # 80000e5c <release>
}
    80003cd8:	60e2                	ld	ra,24(sp)
    80003cda:	6442                	ld	s0,16(sp)
    80003cdc:	64a2                	ld	s1,8(sp)
    80003cde:	6105                	addi	sp,sp,32
    80003ce0:	8082                	ret

0000000080003ce2 <bunpin>:

void
bunpin(struct buf *b) {
    80003ce2:	1101                	addi	sp,sp,-32
    80003ce4:	ec06                	sd	ra,24(sp)
    80003ce6:	e822                	sd	s0,16(sp)
    80003ce8:	e426                	sd	s1,8(sp)
    80003cea:	1000                	addi	s0,sp,32
    80003cec:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003cee:	00235517          	auipc	a0,0x235
    80003cf2:	21250513          	addi	a0,a0,530 # 80238f00 <bcache>
    80003cf6:	ffffd097          	auipc	ra,0xffffd
    80003cfa:	0b2080e7          	jalr	178(ra) # 80000da8 <acquire>
  b->refcnt--;
    80003cfe:	40bc                	lw	a5,64(s1)
    80003d00:	37fd                	addiw	a5,a5,-1
    80003d02:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003d04:	00235517          	auipc	a0,0x235
    80003d08:	1fc50513          	addi	a0,a0,508 # 80238f00 <bcache>
    80003d0c:	ffffd097          	auipc	ra,0xffffd
    80003d10:	150080e7          	jalr	336(ra) # 80000e5c <release>
}
    80003d14:	60e2                	ld	ra,24(sp)
    80003d16:	6442                	ld	s0,16(sp)
    80003d18:	64a2                	ld	s1,8(sp)
    80003d1a:	6105                	addi	sp,sp,32
    80003d1c:	8082                	ret

0000000080003d1e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003d1e:	1101                	addi	sp,sp,-32
    80003d20:	ec06                	sd	ra,24(sp)
    80003d22:	e822                	sd	s0,16(sp)
    80003d24:	e426                	sd	s1,8(sp)
    80003d26:	e04a                	sd	s2,0(sp)
    80003d28:	1000                	addi	s0,sp,32
    80003d2a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003d2c:	00d5d59b          	srliw	a1,a1,0xd
    80003d30:	0023e797          	auipc	a5,0x23e
    80003d34:	8ac7a783          	lw	a5,-1876(a5) # 802415dc <sb+0x1c>
    80003d38:	9dbd                	addw	a1,a1,a5
    80003d3a:	00000097          	auipc	ra,0x0
    80003d3e:	d9e080e7          	jalr	-610(ra) # 80003ad8 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003d42:	0074f713          	andi	a4,s1,7
    80003d46:	4785                	li	a5,1
    80003d48:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003d4c:	14ce                	slli	s1,s1,0x33
    80003d4e:	90d9                	srli	s1,s1,0x36
    80003d50:	00950733          	add	a4,a0,s1
    80003d54:	05874703          	lbu	a4,88(a4)
    80003d58:	00e7f6b3          	and	a3,a5,a4
    80003d5c:	c69d                	beqz	a3,80003d8a <bfree+0x6c>
    80003d5e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003d60:	94aa                	add	s1,s1,a0
    80003d62:	fff7c793          	not	a5,a5
    80003d66:	8ff9                	and	a5,a5,a4
    80003d68:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003d6c:	00001097          	auipc	ra,0x1
    80003d70:	120080e7          	jalr	288(ra) # 80004e8c <log_write>
  brelse(bp);
    80003d74:	854a                	mv	a0,s2
    80003d76:	00000097          	auipc	ra,0x0
    80003d7a:	e92080e7          	jalr	-366(ra) # 80003c08 <brelse>
}
    80003d7e:	60e2                	ld	ra,24(sp)
    80003d80:	6442                	ld	s0,16(sp)
    80003d82:	64a2                	ld	s1,8(sp)
    80003d84:	6902                	ld	s2,0(sp)
    80003d86:	6105                	addi	sp,sp,32
    80003d88:	8082                	ret
    panic("freeing free block");
    80003d8a:	00005517          	auipc	a0,0x5
    80003d8e:	94650513          	addi	a0,a0,-1722 # 800086d0 <syscalls+0x118>
    80003d92:	ffffc097          	auipc	ra,0xffffc
    80003d96:	7b2080e7          	jalr	1970(ra) # 80000544 <panic>

0000000080003d9a <balloc>:
{
    80003d9a:	711d                	addi	sp,sp,-96
    80003d9c:	ec86                	sd	ra,88(sp)
    80003d9e:	e8a2                	sd	s0,80(sp)
    80003da0:	e4a6                	sd	s1,72(sp)
    80003da2:	e0ca                	sd	s2,64(sp)
    80003da4:	fc4e                	sd	s3,56(sp)
    80003da6:	f852                	sd	s4,48(sp)
    80003da8:	f456                	sd	s5,40(sp)
    80003daa:	f05a                	sd	s6,32(sp)
    80003dac:	ec5e                	sd	s7,24(sp)
    80003dae:	e862                	sd	s8,16(sp)
    80003db0:	e466                	sd	s9,8(sp)
    80003db2:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003db4:	0023e797          	auipc	a5,0x23e
    80003db8:	8107a783          	lw	a5,-2032(a5) # 802415c4 <sb+0x4>
    80003dbc:	10078163          	beqz	a5,80003ebe <balloc+0x124>
    80003dc0:	8baa                	mv	s7,a0
    80003dc2:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003dc4:	0023db17          	auipc	s6,0x23d
    80003dc8:	7fcb0b13          	addi	s6,s6,2044 # 802415c0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003dcc:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003dce:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003dd0:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003dd2:	6c89                	lui	s9,0x2
    80003dd4:	a061                	j	80003e5c <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003dd6:	974a                	add	a4,a4,s2
    80003dd8:	8fd5                	or	a5,a5,a3
    80003dda:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003dde:	854a                	mv	a0,s2
    80003de0:	00001097          	auipc	ra,0x1
    80003de4:	0ac080e7          	jalr	172(ra) # 80004e8c <log_write>
        brelse(bp);
    80003de8:	854a                	mv	a0,s2
    80003dea:	00000097          	auipc	ra,0x0
    80003dee:	e1e080e7          	jalr	-482(ra) # 80003c08 <brelse>
  bp = bread(dev, bno);
    80003df2:	85a6                	mv	a1,s1
    80003df4:	855e                	mv	a0,s7
    80003df6:	00000097          	auipc	ra,0x0
    80003dfa:	ce2080e7          	jalr	-798(ra) # 80003ad8 <bread>
    80003dfe:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003e00:	40000613          	li	a2,1024
    80003e04:	4581                	li	a1,0
    80003e06:	05850513          	addi	a0,a0,88
    80003e0a:	ffffd097          	auipc	ra,0xffffd
    80003e0e:	09a080e7          	jalr	154(ra) # 80000ea4 <memset>
  log_write(bp);
    80003e12:	854a                	mv	a0,s2
    80003e14:	00001097          	auipc	ra,0x1
    80003e18:	078080e7          	jalr	120(ra) # 80004e8c <log_write>
  brelse(bp);
    80003e1c:	854a                	mv	a0,s2
    80003e1e:	00000097          	auipc	ra,0x0
    80003e22:	dea080e7          	jalr	-534(ra) # 80003c08 <brelse>
}
    80003e26:	8526                	mv	a0,s1
    80003e28:	60e6                	ld	ra,88(sp)
    80003e2a:	6446                	ld	s0,80(sp)
    80003e2c:	64a6                	ld	s1,72(sp)
    80003e2e:	6906                	ld	s2,64(sp)
    80003e30:	79e2                	ld	s3,56(sp)
    80003e32:	7a42                	ld	s4,48(sp)
    80003e34:	7aa2                	ld	s5,40(sp)
    80003e36:	7b02                	ld	s6,32(sp)
    80003e38:	6be2                	ld	s7,24(sp)
    80003e3a:	6c42                	ld	s8,16(sp)
    80003e3c:	6ca2                	ld	s9,8(sp)
    80003e3e:	6125                	addi	sp,sp,96
    80003e40:	8082                	ret
    brelse(bp);
    80003e42:	854a                	mv	a0,s2
    80003e44:	00000097          	auipc	ra,0x0
    80003e48:	dc4080e7          	jalr	-572(ra) # 80003c08 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003e4c:	015c87bb          	addw	a5,s9,s5
    80003e50:	00078a9b          	sext.w	s5,a5
    80003e54:	004b2703          	lw	a4,4(s6)
    80003e58:	06eaf363          	bgeu	s5,a4,80003ebe <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80003e5c:	41fad79b          	sraiw	a5,s5,0x1f
    80003e60:	0137d79b          	srliw	a5,a5,0x13
    80003e64:	015787bb          	addw	a5,a5,s5
    80003e68:	40d7d79b          	sraiw	a5,a5,0xd
    80003e6c:	01cb2583          	lw	a1,28(s6)
    80003e70:	9dbd                	addw	a1,a1,a5
    80003e72:	855e                	mv	a0,s7
    80003e74:	00000097          	auipc	ra,0x0
    80003e78:	c64080e7          	jalr	-924(ra) # 80003ad8 <bread>
    80003e7c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003e7e:	004b2503          	lw	a0,4(s6)
    80003e82:	000a849b          	sext.w	s1,s5
    80003e86:	8662                	mv	a2,s8
    80003e88:	faa4fde3          	bgeu	s1,a0,80003e42 <balloc+0xa8>
      m = 1 << (bi % 8);
    80003e8c:	41f6579b          	sraiw	a5,a2,0x1f
    80003e90:	01d7d69b          	srliw	a3,a5,0x1d
    80003e94:	00c6873b          	addw	a4,a3,a2
    80003e98:	00777793          	andi	a5,a4,7
    80003e9c:	9f95                	subw	a5,a5,a3
    80003e9e:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003ea2:	4037571b          	sraiw	a4,a4,0x3
    80003ea6:	00e906b3          	add	a3,s2,a4
    80003eaa:	0586c683          	lbu	a3,88(a3)
    80003eae:	00d7f5b3          	and	a1,a5,a3
    80003eb2:	d195                	beqz	a1,80003dd6 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003eb4:	2605                	addiw	a2,a2,1
    80003eb6:	2485                	addiw	s1,s1,1
    80003eb8:	fd4618e3          	bne	a2,s4,80003e88 <balloc+0xee>
    80003ebc:	b759                	j	80003e42 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003ebe:	00005517          	auipc	a0,0x5
    80003ec2:	82a50513          	addi	a0,a0,-2006 # 800086e8 <syscalls+0x130>
    80003ec6:	ffffc097          	auipc	ra,0xffffc
    80003eca:	6c8080e7          	jalr	1736(ra) # 8000058e <printf>
  return 0;
    80003ece:	4481                	li	s1,0
    80003ed0:	bf99                	j	80003e26 <balloc+0x8c>

0000000080003ed2 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003ed2:	7179                	addi	sp,sp,-48
    80003ed4:	f406                	sd	ra,40(sp)
    80003ed6:	f022                	sd	s0,32(sp)
    80003ed8:	ec26                	sd	s1,24(sp)
    80003eda:	e84a                	sd	s2,16(sp)
    80003edc:	e44e                	sd	s3,8(sp)
    80003ede:	e052                	sd	s4,0(sp)
    80003ee0:	1800                	addi	s0,sp,48
    80003ee2:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003ee4:	47ad                	li	a5,11
    80003ee6:	02b7e763          	bltu	a5,a1,80003f14 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003eea:	02059493          	slli	s1,a1,0x20
    80003eee:	9081                	srli	s1,s1,0x20
    80003ef0:	048a                	slli	s1,s1,0x2
    80003ef2:	94aa                	add	s1,s1,a0
    80003ef4:	0504a903          	lw	s2,80(s1)
    80003ef8:	06091e63          	bnez	s2,80003f74 <bmap+0xa2>
      addr = balloc(ip->dev);
    80003efc:	4108                	lw	a0,0(a0)
    80003efe:	00000097          	auipc	ra,0x0
    80003f02:	e9c080e7          	jalr	-356(ra) # 80003d9a <balloc>
    80003f06:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003f0a:	06090563          	beqz	s2,80003f74 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80003f0e:	0524a823          	sw	s2,80(s1)
    80003f12:	a08d                	j	80003f74 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003f14:	ff45849b          	addiw	s1,a1,-12
    80003f18:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003f1c:	0ff00793          	li	a5,255
    80003f20:	08e7e563          	bltu	a5,a4,80003faa <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003f24:	08052903          	lw	s2,128(a0)
    80003f28:	00091d63          	bnez	s2,80003f42 <bmap+0x70>
      addr = balloc(ip->dev);
    80003f2c:	4108                	lw	a0,0(a0)
    80003f2e:	00000097          	auipc	ra,0x0
    80003f32:	e6c080e7          	jalr	-404(ra) # 80003d9a <balloc>
    80003f36:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003f3a:	02090d63          	beqz	s2,80003f74 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003f3e:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003f42:	85ca                	mv	a1,s2
    80003f44:	0009a503          	lw	a0,0(s3)
    80003f48:	00000097          	auipc	ra,0x0
    80003f4c:	b90080e7          	jalr	-1136(ra) # 80003ad8 <bread>
    80003f50:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003f52:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003f56:	02049593          	slli	a1,s1,0x20
    80003f5a:	9181                	srli	a1,a1,0x20
    80003f5c:	058a                	slli	a1,a1,0x2
    80003f5e:	00b784b3          	add	s1,a5,a1
    80003f62:	0004a903          	lw	s2,0(s1)
    80003f66:	02090063          	beqz	s2,80003f86 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003f6a:	8552                	mv	a0,s4
    80003f6c:	00000097          	auipc	ra,0x0
    80003f70:	c9c080e7          	jalr	-868(ra) # 80003c08 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003f74:	854a                	mv	a0,s2
    80003f76:	70a2                	ld	ra,40(sp)
    80003f78:	7402                	ld	s0,32(sp)
    80003f7a:	64e2                	ld	s1,24(sp)
    80003f7c:	6942                	ld	s2,16(sp)
    80003f7e:	69a2                	ld	s3,8(sp)
    80003f80:	6a02                	ld	s4,0(sp)
    80003f82:	6145                	addi	sp,sp,48
    80003f84:	8082                	ret
      addr = balloc(ip->dev);
    80003f86:	0009a503          	lw	a0,0(s3)
    80003f8a:	00000097          	auipc	ra,0x0
    80003f8e:	e10080e7          	jalr	-496(ra) # 80003d9a <balloc>
    80003f92:	0005091b          	sext.w	s2,a0
      if(addr){
    80003f96:	fc090ae3          	beqz	s2,80003f6a <bmap+0x98>
        a[bn] = addr;
    80003f9a:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003f9e:	8552                	mv	a0,s4
    80003fa0:	00001097          	auipc	ra,0x1
    80003fa4:	eec080e7          	jalr	-276(ra) # 80004e8c <log_write>
    80003fa8:	b7c9                	j	80003f6a <bmap+0x98>
  panic("bmap: out of range");
    80003faa:	00004517          	auipc	a0,0x4
    80003fae:	75650513          	addi	a0,a0,1878 # 80008700 <syscalls+0x148>
    80003fb2:	ffffc097          	auipc	ra,0xffffc
    80003fb6:	592080e7          	jalr	1426(ra) # 80000544 <panic>

0000000080003fba <iget>:
{
    80003fba:	7179                	addi	sp,sp,-48
    80003fbc:	f406                	sd	ra,40(sp)
    80003fbe:	f022                	sd	s0,32(sp)
    80003fc0:	ec26                	sd	s1,24(sp)
    80003fc2:	e84a                	sd	s2,16(sp)
    80003fc4:	e44e                	sd	s3,8(sp)
    80003fc6:	e052                	sd	s4,0(sp)
    80003fc8:	1800                	addi	s0,sp,48
    80003fca:	89aa                	mv	s3,a0
    80003fcc:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003fce:	0023d517          	auipc	a0,0x23d
    80003fd2:	61250513          	addi	a0,a0,1554 # 802415e0 <itable>
    80003fd6:	ffffd097          	auipc	ra,0xffffd
    80003fda:	dd2080e7          	jalr	-558(ra) # 80000da8 <acquire>
  empty = 0;
    80003fde:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003fe0:	0023d497          	auipc	s1,0x23d
    80003fe4:	61848493          	addi	s1,s1,1560 # 802415f8 <itable+0x18>
    80003fe8:	0023f697          	auipc	a3,0x23f
    80003fec:	0a068693          	addi	a3,a3,160 # 80243088 <log>
    80003ff0:	a039                	j	80003ffe <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003ff2:	02090b63          	beqz	s2,80004028 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003ff6:	08848493          	addi	s1,s1,136
    80003ffa:	02d48a63          	beq	s1,a3,8000402e <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003ffe:	449c                	lw	a5,8(s1)
    80004000:	fef059e3          	blez	a5,80003ff2 <iget+0x38>
    80004004:	4098                	lw	a4,0(s1)
    80004006:	ff3716e3          	bne	a4,s3,80003ff2 <iget+0x38>
    8000400a:	40d8                	lw	a4,4(s1)
    8000400c:	ff4713e3          	bne	a4,s4,80003ff2 <iget+0x38>
      ip->ref++;
    80004010:	2785                	addiw	a5,a5,1
    80004012:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80004014:	0023d517          	auipc	a0,0x23d
    80004018:	5cc50513          	addi	a0,a0,1484 # 802415e0 <itable>
    8000401c:	ffffd097          	auipc	ra,0xffffd
    80004020:	e40080e7          	jalr	-448(ra) # 80000e5c <release>
      return ip;
    80004024:	8926                	mv	s2,s1
    80004026:	a03d                	j	80004054 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80004028:	f7f9                	bnez	a5,80003ff6 <iget+0x3c>
    8000402a:	8926                	mv	s2,s1
    8000402c:	b7e9                	j	80003ff6 <iget+0x3c>
  if(empty == 0)
    8000402e:	02090c63          	beqz	s2,80004066 <iget+0xac>
  ip->dev = dev;
    80004032:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80004036:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000403a:	4785                	li	a5,1
    8000403c:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80004040:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80004044:	0023d517          	auipc	a0,0x23d
    80004048:	59c50513          	addi	a0,a0,1436 # 802415e0 <itable>
    8000404c:	ffffd097          	auipc	ra,0xffffd
    80004050:	e10080e7          	jalr	-496(ra) # 80000e5c <release>
}
    80004054:	854a                	mv	a0,s2
    80004056:	70a2                	ld	ra,40(sp)
    80004058:	7402                	ld	s0,32(sp)
    8000405a:	64e2                	ld	s1,24(sp)
    8000405c:	6942                	ld	s2,16(sp)
    8000405e:	69a2                	ld	s3,8(sp)
    80004060:	6a02                	ld	s4,0(sp)
    80004062:	6145                	addi	sp,sp,48
    80004064:	8082                	ret
    panic("iget: no inodes");
    80004066:	00004517          	auipc	a0,0x4
    8000406a:	6b250513          	addi	a0,a0,1714 # 80008718 <syscalls+0x160>
    8000406e:	ffffc097          	auipc	ra,0xffffc
    80004072:	4d6080e7          	jalr	1238(ra) # 80000544 <panic>

0000000080004076 <fsinit>:
fsinit(int dev) {
    80004076:	7179                	addi	sp,sp,-48
    80004078:	f406                	sd	ra,40(sp)
    8000407a:	f022                	sd	s0,32(sp)
    8000407c:	ec26                	sd	s1,24(sp)
    8000407e:	e84a                	sd	s2,16(sp)
    80004080:	e44e                	sd	s3,8(sp)
    80004082:	1800                	addi	s0,sp,48
    80004084:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80004086:	4585                	li	a1,1
    80004088:	00000097          	auipc	ra,0x0
    8000408c:	a50080e7          	jalr	-1456(ra) # 80003ad8 <bread>
    80004090:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80004092:	0023d997          	auipc	s3,0x23d
    80004096:	52e98993          	addi	s3,s3,1326 # 802415c0 <sb>
    8000409a:	02000613          	li	a2,32
    8000409e:	05850593          	addi	a1,a0,88
    800040a2:	854e                	mv	a0,s3
    800040a4:	ffffd097          	auipc	ra,0xffffd
    800040a8:	e60080e7          	jalr	-416(ra) # 80000f04 <memmove>
  brelse(bp);
    800040ac:	8526                	mv	a0,s1
    800040ae:	00000097          	auipc	ra,0x0
    800040b2:	b5a080e7          	jalr	-1190(ra) # 80003c08 <brelse>
  if(sb.magic != FSMAGIC)
    800040b6:	0009a703          	lw	a4,0(s3)
    800040ba:	102037b7          	lui	a5,0x10203
    800040be:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800040c2:	02f71263          	bne	a4,a5,800040e6 <fsinit+0x70>
  initlog(dev, &sb);
    800040c6:	0023d597          	auipc	a1,0x23d
    800040ca:	4fa58593          	addi	a1,a1,1274 # 802415c0 <sb>
    800040ce:	854a                	mv	a0,s2
    800040d0:	00001097          	auipc	ra,0x1
    800040d4:	b40080e7          	jalr	-1216(ra) # 80004c10 <initlog>
}
    800040d8:	70a2                	ld	ra,40(sp)
    800040da:	7402                	ld	s0,32(sp)
    800040dc:	64e2                	ld	s1,24(sp)
    800040de:	6942                	ld	s2,16(sp)
    800040e0:	69a2                	ld	s3,8(sp)
    800040e2:	6145                	addi	sp,sp,48
    800040e4:	8082                	ret
    panic("invalid file system");
    800040e6:	00004517          	auipc	a0,0x4
    800040ea:	64250513          	addi	a0,a0,1602 # 80008728 <syscalls+0x170>
    800040ee:	ffffc097          	auipc	ra,0xffffc
    800040f2:	456080e7          	jalr	1110(ra) # 80000544 <panic>

00000000800040f6 <iinit>:
{
    800040f6:	7179                	addi	sp,sp,-48
    800040f8:	f406                	sd	ra,40(sp)
    800040fa:	f022                	sd	s0,32(sp)
    800040fc:	ec26                	sd	s1,24(sp)
    800040fe:	e84a                	sd	s2,16(sp)
    80004100:	e44e                	sd	s3,8(sp)
    80004102:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80004104:	00004597          	auipc	a1,0x4
    80004108:	63c58593          	addi	a1,a1,1596 # 80008740 <syscalls+0x188>
    8000410c:	0023d517          	auipc	a0,0x23d
    80004110:	4d450513          	addi	a0,a0,1236 # 802415e0 <itable>
    80004114:	ffffd097          	auipc	ra,0xffffd
    80004118:	c04080e7          	jalr	-1020(ra) # 80000d18 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000411c:	0023d497          	auipc	s1,0x23d
    80004120:	4ec48493          	addi	s1,s1,1260 # 80241608 <itable+0x28>
    80004124:	0023f997          	auipc	s3,0x23f
    80004128:	f7498993          	addi	s3,s3,-140 # 80243098 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000412c:	00004917          	auipc	s2,0x4
    80004130:	61c90913          	addi	s2,s2,1564 # 80008748 <syscalls+0x190>
    80004134:	85ca                	mv	a1,s2
    80004136:	8526                	mv	a0,s1
    80004138:	00001097          	auipc	ra,0x1
    8000413c:	e3a080e7          	jalr	-454(ra) # 80004f72 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80004140:	08848493          	addi	s1,s1,136
    80004144:	ff3498e3          	bne	s1,s3,80004134 <iinit+0x3e>
}
    80004148:	70a2                	ld	ra,40(sp)
    8000414a:	7402                	ld	s0,32(sp)
    8000414c:	64e2                	ld	s1,24(sp)
    8000414e:	6942                	ld	s2,16(sp)
    80004150:	69a2                	ld	s3,8(sp)
    80004152:	6145                	addi	sp,sp,48
    80004154:	8082                	ret

0000000080004156 <ialloc>:
{
    80004156:	715d                	addi	sp,sp,-80
    80004158:	e486                	sd	ra,72(sp)
    8000415a:	e0a2                	sd	s0,64(sp)
    8000415c:	fc26                	sd	s1,56(sp)
    8000415e:	f84a                	sd	s2,48(sp)
    80004160:	f44e                	sd	s3,40(sp)
    80004162:	f052                	sd	s4,32(sp)
    80004164:	ec56                	sd	s5,24(sp)
    80004166:	e85a                	sd	s6,16(sp)
    80004168:	e45e                	sd	s7,8(sp)
    8000416a:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000416c:	0023d717          	auipc	a4,0x23d
    80004170:	46072703          	lw	a4,1120(a4) # 802415cc <sb+0xc>
    80004174:	4785                	li	a5,1
    80004176:	04e7fa63          	bgeu	a5,a4,800041ca <ialloc+0x74>
    8000417a:	8aaa                	mv	s5,a0
    8000417c:	8bae                	mv	s7,a1
    8000417e:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80004180:	0023da17          	auipc	s4,0x23d
    80004184:	440a0a13          	addi	s4,s4,1088 # 802415c0 <sb>
    80004188:	00048b1b          	sext.w	s6,s1
    8000418c:	0044d593          	srli	a1,s1,0x4
    80004190:	018a2783          	lw	a5,24(s4)
    80004194:	9dbd                	addw	a1,a1,a5
    80004196:	8556                	mv	a0,s5
    80004198:	00000097          	auipc	ra,0x0
    8000419c:	940080e7          	jalr	-1728(ra) # 80003ad8 <bread>
    800041a0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800041a2:	05850993          	addi	s3,a0,88
    800041a6:	00f4f793          	andi	a5,s1,15
    800041aa:	079a                	slli	a5,a5,0x6
    800041ac:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800041ae:	00099783          	lh	a5,0(s3)
    800041b2:	c3a1                	beqz	a5,800041f2 <ialloc+0x9c>
    brelse(bp);
    800041b4:	00000097          	auipc	ra,0x0
    800041b8:	a54080e7          	jalr	-1452(ra) # 80003c08 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800041bc:	0485                	addi	s1,s1,1
    800041be:	00ca2703          	lw	a4,12(s4)
    800041c2:	0004879b          	sext.w	a5,s1
    800041c6:	fce7e1e3          	bltu	a5,a4,80004188 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    800041ca:	00004517          	auipc	a0,0x4
    800041ce:	58650513          	addi	a0,a0,1414 # 80008750 <syscalls+0x198>
    800041d2:	ffffc097          	auipc	ra,0xffffc
    800041d6:	3bc080e7          	jalr	956(ra) # 8000058e <printf>
  return 0;
    800041da:	4501                	li	a0,0
}
    800041dc:	60a6                	ld	ra,72(sp)
    800041de:	6406                	ld	s0,64(sp)
    800041e0:	74e2                	ld	s1,56(sp)
    800041e2:	7942                	ld	s2,48(sp)
    800041e4:	79a2                	ld	s3,40(sp)
    800041e6:	7a02                	ld	s4,32(sp)
    800041e8:	6ae2                	ld	s5,24(sp)
    800041ea:	6b42                	ld	s6,16(sp)
    800041ec:	6ba2                	ld	s7,8(sp)
    800041ee:	6161                	addi	sp,sp,80
    800041f0:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800041f2:	04000613          	li	a2,64
    800041f6:	4581                	li	a1,0
    800041f8:	854e                	mv	a0,s3
    800041fa:	ffffd097          	auipc	ra,0xffffd
    800041fe:	caa080e7          	jalr	-854(ra) # 80000ea4 <memset>
      dip->type = type;
    80004202:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80004206:	854a                	mv	a0,s2
    80004208:	00001097          	auipc	ra,0x1
    8000420c:	c84080e7          	jalr	-892(ra) # 80004e8c <log_write>
      brelse(bp);
    80004210:	854a                	mv	a0,s2
    80004212:	00000097          	auipc	ra,0x0
    80004216:	9f6080e7          	jalr	-1546(ra) # 80003c08 <brelse>
      return iget(dev, inum);
    8000421a:	85da                	mv	a1,s6
    8000421c:	8556                	mv	a0,s5
    8000421e:	00000097          	auipc	ra,0x0
    80004222:	d9c080e7          	jalr	-612(ra) # 80003fba <iget>
    80004226:	bf5d                	j	800041dc <ialloc+0x86>

0000000080004228 <iupdate>:
{
    80004228:	1101                	addi	sp,sp,-32
    8000422a:	ec06                	sd	ra,24(sp)
    8000422c:	e822                	sd	s0,16(sp)
    8000422e:	e426                	sd	s1,8(sp)
    80004230:	e04a                	sd	s2,0(sp)
    80004232:	1000                	addi	s0,sp,32
    80004234:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004236:	415c                	lw	a5,4(a0)
    80004238:	0047d79b          	srliw	a5,a5,0x4
    8000423c:	0023d597          	auipc	a1,0x23d
    80004240:	39c5a583          	lw	a1,924(a1) # 802415d8 <sb+0x18>
    80004244:	9dbd                	addw	a1,a1,a5
    80004246:	4108                	lw	a0,0(a0)
    80004248:	00000097          	auipc	ra,0x0
    8000424c:	890080e7          	jalr	-1904(ra) # 80003ad8 <bread>
    80004250:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004252:	05850793          	addi	a5,a0,88
    80004256:	40c8                	lw	a0,4(s1)
    80004258:	893d                	andi	a0,a0,15
    8000425a:	051a                	slli	a0,a0,0x6
    8000425c:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    8000425e:	04449703          	lh	a4,68(s1)
    80004262:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80004266:	04649703          	lh	a4,70(s1)
    8000426a:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    8000426e:	04849703          	lh	a4,72(s1)
    80004272:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80004276:	04a49703          	lh	a4,74(s1)
    8000427a:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    8000427e:	44f8                	lw	a4,76(s1)
    80004280:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80004282:	03400613          	li	a2,52
    80004286:	05048593          	addi	a1,s1,80
    8000428a:	0531                	addi	a0,a0,12
    8000428c:	ffffd097          	auipc	ra,0xffffd
    80004290:	c78080e7          	jalr	-904(ra) # 80000f04 <memmove>
  log_write(bp);
    80004294:	854a                	mv	a0,s2
    80004296:	00001097          	auipc	ra,0x1
    8000429a:	bf6080e7          	jalr	-1034(ra) # 80004e8c <log_write>
  brelse(bp);
    8000429e:	854a                	mv	a0,s2
    800042a0:	00000097          	auipc	ra,0x0
    800042a4:	968080e7          	jalr	-1688(ra) # 80003c08 <brelse>
}
    800042a8:	60e2                	ld	ra,24(sp)
    800042aa:	6442                	ld	s0,16(sp)
    800042ac:	64a2                	ld	s1,8(sp)
    800042ae:	6902                	ld	s2,0(sp)
    800042b0:	6105                	addi	sp,sp,32
    800042b2:	8082                	ret

00000000800042b4 <idup>:
{
    800042b4:	1101                	addi	sp,sp,-32
    800042b6:	ec06                	sd	ra,24(sp)
    800042b8:	e822                	sd	s0,16(sp)
    800042ba:	e426                	sd	s1,8(sp)
    800042bc:	1000                	addi	s0,sp,32
    800042be:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800042c0:	0023d517          	auipc	a0,0x23d
    800042c4:	32050513          	addi	a0,a0,800 # 802415e0 <itable>
    800042c8:	ffffd097          	auipc	ra,0xffffd
    800042cc:	ae0080e7          	jalr	-1312(ra) # 80000da8 <acquire>
  ip->ref++;
    800042d0:	449c                	lw	a5,8(s1)
    800042d2:	2785                	addiw	a5,a5,1
    800042d4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800042d6:	0023d517          	auipc	a0,0x23d
    800042da:	30a50513          	addi	a0,a0,778 # 802415e0 <itable>
    800042de:	ffffd097          	auipc	ra,0xffffd
    800042e2:	b7e080e7          	jalr	-1154(ra) # 80000e5c <release>
}
    800042e6:	8526                	mv	a0,s1
    800042e8:	60e2                	ld	ra,24(sp)
    800042ea:	6442                	ld	s0,16(sp)
    800042ec:	64a2                	ld	s1,8(sp)
    800042ee:	6105                	addi	sp,sp,32
    800042f0:	8082                	ret

00000000800042f2 <ilock>:
{
    800042f2:	1101                	addi	sp,sp,-32
    800042f4:	ec06                	sd	ra,24(sp)
    800042f6:	e822                	sd	s0,16(sp)
    800042f8:	e426                	sd	s1,8(sp)
    800042fa:	e04a                	sd	s2,0(sp)
    800042fc:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800042fe:	c115                	beqz	a0,80004322 <ilock+0x30>
    80004300:	84aa                	mv	s1,a0
    80004302:	451c                	lw	a5,8(a0)
    80004304:	00f05f63          	blez	a5,80004322 <ilock+0x30>
  acquiresleep(&ip->lock);
    80004308:	0541                	addi	a0,a0,16
    8000430a:	00001097          	auipc	ra,0x1
    8000430e:	ca2080e7          	jalr	-862(ra) # 80004fac <acquiresleep>
  if(ip->valid == 0){
    80004312:	40bc                	lw	a5,64(s1)
    80004314:	cf99                	beqz	a5,80004332 <ilock+0x40>
}
    80004316:	60e2                	ld	ra,24(sp)
    80004318:	6442                	ld	s0,16(sp)
    8000431a:	64a2                	ld	s1,8(sp)
    8000431c:	6902                	ld	s2,0(sp)
    8000431e:	6105                	addi	sp,sp,32
    80004320:	8082                	ret
    panic("ilock");
    80004322:	00004517          	auipc	a0,0x4
    80004326:	44650513          	addi	a0,a0,1094 # 80008768 <syscalls+0x1b0>
    8000432a:	ffffc097          	auipc	ra,0xffffc
    8000432e:	21a080e7          	jalr	538(ra) # 80000544 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004332:	40dc                	lw	a5,4(s1)
    80004334:	0047d79b          	srliw	a5,a5,0x4
    80004338:	0023d597          	auipc	a1,0x23d
    8000433c:	2a05a583          	lw	a1,672(a1) # 802415d8 <sb+0x18>
    80004340:	9dbd                	addw	a1,a1,a5
    80004342:	4088                	lw	a0,0(s1)
    80004344:	fffff097          	auipc	ra,0xfffff
    80004348:	794080e7          	jalr	1940(ra) # 80003ad8 <bread>
    8000434c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000434e:	05850593          	addi	a1,a0,88
    80004352:	40dc                	lw	a5,4(s1)
    80004354:	8bbd                	andi	a5,a5,15
    80004356:	079a                	slli	a5,a5,0x6
    80004358:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000435a:	00059783          	lh	a5,0(a1)
    8000435e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80004362:	00259783          	lh	a5,2(a1)
    80004366:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000436a:	00459783          	lh	a5,4(a1)
    8000436e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80004372:	00659783          	lh	a5,6(a1)
    80004376:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000437a:	459c                	lw	a5,8(a1)
    8000437c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000437e:	03400613          	li	a2,52
    80004382:	05b1                	addi	a1,a1,12
    80004384:	05048513          	addi	a0,s1,80
    80004388:	ffffd097          	auipc	ra,0xffffd
    8000438c:	b7c080e7          	jalr	-1156(ra) # 80000f04 <memmove>
    brelse(bp);
    80004390:	854a                	mv	a0,s2
    80004392:	00000097          	auipc	ra,0x0
    80004396:	876080e7          	jalr	-1930(ra) # 80003c08 <brelse>
    ip->valid = 1;
    8000439a:	4785                	li	a5,1
    8000439c:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000439e:	04449783          	lh	a5,68(s1)
    800043a2:	fbb5                	bnez	a5,80004316 <ilock+0x24>
      panic("ilock: no type");
    800043a4:	00004517          	auipc	a0,0x4
    800043a8:	3cc50513          	addi	a0,a0,972 # 80008770 <syscalls+0x1b8>
    800043ac:	ffffc097          	auipc	ra,0xffffc
    800043b0:	198080e7          	jalr	408(ra) # 80000544 <panic>

00000000800043b4 <iunlock>:
{
    800043b4:	1101                	addi	sp,sp,-32
    800043b6:	ec06                	sd	ra,24(sp)
    800043b8:	e822                	sd	s0,16(sp)
    800043ba:	e426                	sd	s1,8(sp)
    800043bc:	e04a                	sd	s2,0(sp)
    800043be:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800043c0:	c905                	beqz	a0,800043f0 <iunlock+0x3c>
    800043c2:	84aa                	mv	s1,a0
    800043c4:	01050913          	addi	s2,a0,16
    800043c8:	854a                	mv	a0,s2
    800043ca:	00001097          	auipc	ra,0x1
    800043ce:	c7c080e7          	jalr	-900(ra) # 80005046 <holdingsleep>
    800043d2:	cd19                	beqz	a0,800043f0 <iunlock+0x3c>
    800043d4:	449c                	lw	a5,8(s1)
    800043d6:	00f05d63          	blez	a5,800043f0 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800043da:	854a                	mv	a0,s2
    800043dc:	00001097          	auipc	ra,0x1
    800043e0:	c26080e7          	jalr	-986(ra) # 80005002 <releasesleep>
}
    800043e4:	60e2                	ld	ra,24(sp)
    800043e6:	6442                	ld	s0,16(sp)
    800043e8:	64a2                	ld	s1,8(sp)
    800043ea:	6902                	ld	s2,0(sp)
    800043ec:	6105                	addi	sp,sp,32
    800043ee:	8082                	ret
    panic("iunlock");
    800043f0:	00004517          	auipc	a0,0x4
    800043f4:	39050513          	addi	a0,a0,912 # 80008780 <syscalls+0x1c8>
    800043f8:	ffffc097          	auipc	ra,0xffffc
    800043fc:	14c080e7          	jalr	332(ra) # 80000544 <panic>

0000000080004400 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80004400:	7179                	addi	sp,sp,-48
    80004402:	f406                	sd	ra,40(sp)
    80004404:	f022                	sd	s0,32(sp)
    80004406:	ec26                	sd	s1,24(sp)
    80004408:	e84a                	sd	s2,16(sp)
    8000440a:	e44e                	sd	s3,8(sp)
    8000440c:	e052                	sd	s4,0(sp)
    8000440e:	1800                	addi	s0,sp,48
    80004410:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80004412:	05050493          	addi	s1,a0,80
    80004416:	08050913          	addi	s2,a0,128
    8000441a:	a021                	j	80004422 <itrunc+0x22>
    8000441c:	0491                	addi	s1,s1,4
    8000441e:	01248d63          	beq	s1,s2,80004438 <itrunc+0x38>
    if(ip->addrs[i]){
    80004422:	408c                	lw	a1,0(s1)
    80004424:	dde5                	beqz	a1,8000441c <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80004426:	0009a503          	lw	a0,0(s3)
    8000442a:	00000097          	auipc	ra,0x0
    8000442e:	8f4080e7          	jalr	-1804(ra) # 80003d1e <bfree>
      ip->addrs[i] = 0;
    80004432:	0004a023          	sw	zero,0(s1)
    80004436:	b7dd                	j	8000441c <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80004438:	0809a583          	lw	a1,128(s3)
    8000443c:	e185                	bnez	a1,8000445c <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000443e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80004442:	854e                	mv	a0,s3
    80004444:	00000097          	auipc	ra,0x0
    80004448:	de4080e7          	jalr	-540(ra) # 80004228 <iupdate>
}
    8000444c:	70a2                	ld	ra,40(sp)
    8000444e:	7402                	ld	s0,32(sp)
    80004450:	64e2                	ld	s1,24(sp)
    80004452:	6942                	ld	s2,16(sp)
    80004454:	69a2                	ld	s3,8(sp)
    80004456:	6a02                	ld	s4,0(sp)
    80004458:	6145                	addi	sp,sp,48
    8000445a:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000445c:	0009a503          	lw	a0,0(s3)
    80004460:	fffff097          	auipc	ra,0xfffff
    80004464:	678080e7          	jalr	1656(ra) # 80003ad8 <bread>
    80004468:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000446a:	05850493          	addi	s1,a0,88
    8000446e:	45850913          	addi	s2,a0,1112
    80004472:	a811                	j	80004486 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80004474:	0009a503          	lw	a0,0(s3)
    80004478:	00000097          	auipc	ra,0x0
    8000447c:	8a6080e7          	jalr	-1882(ra) # 80003d1e <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80004480:	0491                	addi	s1,s1,4
    80004482:	01248563          	beq	s1,s2,8000448c <itrunc+0x8c>
      if(a[j])
    80004486:	408c                	lw	a1,0(s1)
    80004488:	dde5                	beqz	a1,80004480 <itrunc+0x80>
    8000448a:	b7ed                	j	80004474 <itrunc+0x74>
    brelse(bp);
    8000448c:	8552                	mv	a0,s4
    8000448e:	fffff097          	auipc	ra,0xfffff
    80004492:	77a080e7          	jalr	1914(ra) # 80003c08 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80004496:	0809a583          	lw	a1,128(s3)
    8000449a:	0009a503          	lw	a0,0(s3)
    8000449e:	00000097          	auipc	ra,0x0
    800044a2:	880080e7          	jalr	-1920(ra) # 80003d1e <bfree>
    ip->addrs[NDIRECT] = 0;
    800044a6:	0809a023          	sw	zero,128(s3)
    800044aa:	bf51                	j	8000443e <itrunc+0x3e>

00000000800044ac <iput>:
{
    800044ac:	1101                	addi	sp,sp,-32
    800044ae:	ec06                	sd	ra,24(sp)
    800044b0:	e822                	sd	s0,16(sp)
    800044b2:	e426                	sd	s1,8(sp)
    800044b4:	e04a                	sd	s2,0(sp)
    800044b6:	1000                	addi	s0,sp,32
    800044b8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800044ba:	0023d517          	auipc	a0,0x23d
    800044be:	12650513          	addi	a0,a0,294 # 802415e0 <itable>
    800044c2:	ffffd097          	auipc	ra,0xffffd
    800044c6:	8e6080e7          	jalr	-1818(ra) # 80000da8 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800044ca:	4498                	lw	a4,8(s1)
    800044cc:	4785                	li	a5,1
    800044ce:	02f70363          	beq	a4,a5,800044f4 <iput+0x48>
  ip->ref--;
    800044d2:	449c                	lw	a5,8(s1)
    800044d4:	37fd                	addiw	a5,a5,-1
    800044d6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800044d8:	0023d517          	auipc	a0,0x23d
    800044dc:	10850513          	addi	a0,a0,264 # 802415e0 <itable>
    800044e0:	ffffd097          	auipc	ra,0xffffd
    800044e4:	97c080e7          	jalr	-1668(ra) # 80000e5c <release>
}
    800044e8:	60e2                	ld	ra,24(sp)
    800044ea:	6442                	ld	s0,16(sp)
    800044ec:	64a2                	ld	s1,8(sp)
    800044ee:	6902                	ld	s2,0(sp)
    800044f0:	6105                	addi	sp,sp,32
    800044f2:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800044f4:	40bc                	lw	a5,64(s1)
    800044f6:	dff1                	beqz	a5,800044d2 <iput+0x26>
    800044f8:	04a49783          	lh	a5,74(s1)
    800044fc:	fbf9                	bnez	a5,800044d2 <iput+0x26>
    acquiresleep(&ip->lock);
    800044fe:	01048913          	addi	s2,s1,16
    80004502:	854a                	mv	a0,s2
    80004504:	00001097          	auipc	ra,0x1
    80004508:	aa8080e7          	jalr	-1368(ra) # 80004fac <acquiresleep>
    release(&itable.lock);
    8000450c:	0023d517          	auipc	a0,0x23d
    80004510:	0d450513          	addi	a0,a0,212 # 802415e0 <itable>
    80004514:	ffffd097          	auipc	ra,0xffffd
    80004518:	948080e7          	jalr	-1720(ra) # 80000e5c <release>
    itrunc(ip);
    8000451c:	8526                	mv	a0,s1
    8000451e:	00000097          	auipc	ra,0x0
    80004522:	ee2080e7          	jalr	-286(ra) # 80004400 <itrunc>
    ip->type = 0;
    80004526:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000452a:	8526                	mv	a0,s1
    8000452c:	00000097          	auipc	ra,0x0
    80004530:	cfc080e7          	jalr	-772(ra) # 80004228 <iupdate>
    ip->valid = 0;
    80004534:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80004538:	854a                	mv	a0,s2
    8000453a:	00001097          	auipc	ra,0x1
    8000453e:	ac8080e7          	jalr	-1336(ra) # 80005002 <releasesleep>
    acquire(&itable.lock);
    80004542:	0023d517          	auipc	a0,0x23d
    80004546:	09e50513          	addi	a0,a0,158 # 802415e0 <itable>
    8000454a:	ffffd097          	auipc	ra,0xffffd
    8000454e:	85e080e7          	jalr	-1954(ra) # 80000da8 <acquire>
    80004552:	b741                	j	800044d2 <iput+0x26>

0000000080004554 <iunlockput>:
{
    80004554:	1101                	addi	sp,sp,-32
    80004556:	ec06                	sd	ra,24(sp)
    80004558:	e822                	sd	s0,16(sp)
    8000455a:	e426                	sd	s1,8(sp)
    8000455c:	1000                	addi	s0,sp,32
    8000455e:	84aa                	mv	s1,a0
  iunlock(ip);
    80004560:	00000097          	auipc	ra,0x0
    80004564:	e54080e7          	jalr	-428(ra) # 800043b4 <iunlock>
  iput(ip);
    80004568:	8526                	mv	a0,s1
    8000456a:	00000097          	auipc	ra,0x0
    8000456e:	f42080e7          	jalr	-190(ra) # 800044ac <iput>
}
    80004572:	60e2                	ld	ra,24(sp)
    80004574:	6442                	ld	s0,16(sp)
    80004576:	64a2                	ld	s1,8(sp)
    80004578:	6105                	addi	sp,sp,32
    8000457a:	8082                	ret

000000008000457c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000457c:	1141                	addi	sp,sp,-16
    8000457e:	e422                	sd	s0,8(sp)
    80004580:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004582:	411c                	lw	a5,0(a0)
    80004584:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004586:	415c                	lw	a5,4(a0)
    80004588:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000458a:	04451783          	lh	a5,68(a0)
    8000458e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004592:	04a51783          	lh	a5,74(a0)
    80004596:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000459a:	04c56783          	lwu	a5,76(a0)
    8000459e:	e99c                	sd	a5,16(a1)
}
    800045a0:	6422                	ld	s0,8(sp)
    800045a2:	0141                	addi	sp,sp,16
    800045a4:	8082                	ret

00000000800045a6 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800045a6:	457c                	lw	a5,76(a0)
    800045a8:	0ed7e963          	bltu	a5,a3,8000469a <readi+0xf4>
{
    800045ac:	7159                	addi	sp,sp,-112
    800045ae:	f486                	sd	ra,104(sp)
    800045b0:	f0a2                	sd	s0,96(sp)
    800045b2:	eca6                	sd	s1,88(sp)
    800045b4:	e8ca                	sd	s2,80(sp)
    800045b6:	e4ce                	sd	s3,72(sp)
    800045b8:	e0d2                	sd	s4,64(sp)
    800045ba:	fc56                	sd	s5,56(sp)
    800045bc:	f85a                	sd	s6,48(sp)
    800045be:	f45e                	sd	s7,40(sp)
    800045c0:	f062                	sd	s8,32(sp)
    800045c2:	ec66                	sd	s9,24(sp)
    800045c4:	e86a                	sd	s10,16(sp)
    800045c6:	e46e                	sd	s11,8(sp)
    800045c8:	1880                	addi	s0,sp,112
    800045ca:	8b2a                	mv	s6,a0
    800045cc:	8bae                	mv	s7,a1
    800045ce:	8a32                	mv	s4,a2
    800045d0:	84b6                	mv	s1,a3
    800045d2:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800045d4:	9f35                	addw	a4,a4,a3
    return 0;
    800045d6:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800045d8:	0ad76063          	bltu	a4,a3,80004678 <readi+0xd2>
  if(off + n > ip->size)
    800045dc:	00e7f463          	bgeu	a5,a4,800045e4 <readi+0x3e>
    n = ip->size - off;
    800045e0:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800045e4:	0a0a8963          	beqz	s5,80004696 <readi+0xf0>
    800045e8:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800045ea:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800045ee:	5c7d                	li	s8,-1
    800045f0:	a82d                	j	8000462a <readi+0x84>
    800045f2:	020d1d93          	slli	s11,s10,0x20
    800045f6:	020ddd93          	srli	s11,s11,0x20
    800045fa:	05890613          	addi	a2,s2,88
    800045fe:	86ee                	mv	a3,s11
    80004600:	963a                	add	a2,a2,a4
    80004602:	85d2                	mv	a1,s4
    80004604:	855e                	mv	a0,s7
    80004606:	ffffe097          	auipc	ra,0xffffe
    8000460a:	640080e7          	jalr	1600(ra) # 80002c46 <either_copyout>
    8000460e:	05850d63          	beq	a0,s8,80004668 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004612:	854a                	mv	a0,s2
    80004614:	fffff097          	auipc	ra,0xfffff
    80004618:	5f4080e7          	jalr	1524(ra) # 80003c08 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000461c:	013d09bb          	addw	s3,s10,s3
    80004620:	009d04bb          	addw	s1,s10,s1
    80004624:	9a6e                	add	s4,s4,s11
    80004626:	0559f763          	bgeu	s3,s5,80004674 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    8000462a:	00a4d59b          	srliw	a1,s1,0xa
    8000462e:	855a                	mv	a0,s6
    80004630:	00000097          	auipc	ra,0x0
    80004634:	8a2080e7          	jalr	-1886(ra) # 80003ed2 <bmap>
    80004638:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000463c:	cd85                	beqz	a1,80004674 <readi+0xce>
    bp = bread(ip->dev, addr);
    8000463e:	000b2503          	lw	a0,0(s6)
    80004642:	fffff097          	auipc	ra,0xfffff
    80004646:	496080e7          	jalr	1174(ra) # 80003ad8 <bread>
    8000464a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000464c:	3ff4f713          	andi	a4,s1,1023
    80004650:	40ec87bb          	subw	a5,s9,a4
    80004654:	413a86bb          	subw	a3,s5,s3
    80004658:	8d3e                	mv	s10,a5
    8000465a:	2781                	sext.w	a5,a5
    8000465c:	0006861b          	sext.w	a2,a3
    80004660:	f8f679e3          	bgeu	a2,a5,800045f2 <readi+0x4c>
    80004664:	8d36                	mv	s10,a3
    80004666:	b771                	j	800045f2 <readi+0x4c>
      brelse(bp);
    80004668:	854a                	mv	a0,s2
    8000466a:	fffff097          	auipc	ra,0xfffff
    8000466e:	59e080e7          	jalr	1438(ra) # 80003c08 <brelse>
      tot = -1;
    80004672:	59fd                	li	s3,-1
  }
  return tot;
    80004674:	0009851b          	sext.w	a0,s3
}
    80004678:	70a6                	ld	ra,104(sp)
    8000467a:	7406                	ld	s0,96(sp)
    8000467c:	64e6                	ld	s1,88(sp)
    8000467e:	6946                	ld	s2,80(sp)
    80004680:	69a6                	ld	s3,72(sp)
    80004682:	6a06                	ld	s4,64(sp)
    80004684:	7ae2                	ld	s5,56(sp)
    80004686:	7b42                	ld	s6,48(sp)
    80004688:	7ba2                	ld	s7,40(sp)
    8000468a:	7c02                	ld	s8,32(sp)
    8000468c:	6ce2                	ld	s9,24(sp)
    8000468e:	6d42                	ld	s10,16(sp)
    80004690:	6da2                	ld	s11,8(sp)
    80004692:	6165                	addi	sp,sp,112
    80004694:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004696:	89d6                	mv	s3,s5
    80004698:	bff1                	j	80004674 <readi+0xce>
    return 0;
    8000469a:	4501                	li	a0,0
}
    8000469c:	8082                	ret

000000008000469e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000469e:	457c                	lw	a5,76(a0)
    800046a0:	10d7e863          	bltu	a5,a3,800047b0 <writei+0x112>
{
    800046a4:	7159                	addi	sp,sp,-112
    800046a6:	f486                	sd	ra,104(sp)
    800046a8:	f0a2                	sd	s0,96(sp)
    800046aa:	eca6                	sd	s1,88(sp)
    800046ac:	e8ca                	sd	s2,80(sp)
    800046ae:	e4ce                	sd	s3,72(sp)
    800046b0:	e0d2                	sd	s4,64(sp)
    800046b2:	fc56                	sd	s5,56(sp)
    800046b4:	f85a                	sd	s6,48(sp)
    800046b6:	f45e                	sd	s7,40(sp)
    800046b8:	f062                	sd	s8,32(sp)
    800046ba:	ec66                	sd	s9,24(sp)
    800046bc:	e86a                	sd	s10,16(sp)
    800046be:	e46e                	sd	s11,8(sp)
    800046c0:	1880                	addi	s0,sp,112
    800046c2:	8aaa                	mv	s5,a0
    800046c4:	8bae                	mv	s7,a1
    800046c6:	8a32                	mv	s4,a2
    800046c8:	8936                	mv	s2,a3
    800046ca:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800046cc:	00e687bb          	addw	a5,a3,a4
    800046d0:	0ed7e263          	bltu	a5,a3,800047b4 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800046d4:	00043737          	lui	a4,0x43
    800046d8:	0ef76063          	bltu	a4,a5,800047b8 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800046dc:	0c0b0863          	beqz	s6,800047ac <writei+0x10e>
    800046e0:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800046e2:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800046e6:	5c7d                	li	s8,-1
    800046e8:	a091                	j	8000472c <writei+0x8e>
    800046ea:	020d1d93          	slli	s11,s10,0x20
    800046ee:	020ddd93          	srli	s11,s11,0x20
    800046f2:	05848513          	addi	a0,s1,88
    800046f6:	86ee                	mv	a3,s11
    800046f8:	8652                	mv	a2,s4
    800046fa:	85de                	mv	a1,s7
    800046fc:	953a                	add	a0,a0,a4
    800046fe:	ffffe097          	auipc	ra,0xffffe
    80004702:	59e080e7          	jalr	1438(ra) # 80002c9c <either_copyin>
    80004706:	07850263          	beq	a0,s8,8000476a <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000470a:	8526                	mv	a0,s1
    8000470c:	00000097          	auipc	ra,0x0
    80004710:	780080e7          	jalr	1920(ra) # 80004e8c <log_write>
    brelse(bp);
    80004714:	8526                	mv	a0,s1
    80004716:	fffff097          	auipc	ra,0xfffff
    8000471a:	4f2080e7          	jalr	1266(ra) # 80003c08 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000471e:	013d09bb          	addw	s3,s10,s3
    80004722:	012d093b          	addw	s2,s10,s2
    80004726:	9a6e                	add	s4,s4,s11
    80004728:	0569f663          	bgeu	s3,s6,80004774 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    8000472c:	00a9559b          	srliw	a1,s2,0xa
    80004730:	8556                	mv	a0,s5
    80004732:	fffff097          	auipc	ra,0xfffff
    80004736:	7a0080e7          	jalr	1952(ra) # 80003ed2 <bmap>
    8000473a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000473e:	c99d                	beqz	a1,80004774 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80004740:	000aa503          	lw	a0,0(s5)
    80004744:	fffff097          	auipc	ra,0xfffff
    80004748:	394080e7          	jalr	916(ra) # 80003ad8 <bread>
    8000474c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000474e:	3ff97713          	andi	a4,s2,1023
    80004752:	40ec87bb          	subw	a5,s9,a4
    80004756:	413b06bb          	subw	a3,s6,s3
    8000475a:	8d3e                	mv	s10,a5
    8000475c:	2781                	sext.w	a5,a5
    8000475e:	0006861b          	sext.w	a2,a3
    80004762:	f8f674e3          	bgeu	a2,a5,800046ea <writei+0x4c>
    80004766:	8d36                	mv	s10,a3
    80004768:	b749                	j	800046ea <writei+0x4c>
      brelse(bp);
    8000476a:	8526                	mv	a0,s1
    8000476c:	fffff097          	auipc	ra,0xfffff
    80004770:	49c080e7          	jalr	1180(ra) # 80003c08 <brelse>
  }

  if(off > ip->size)
    80004774:	04caa783          	lw	a5,76(s5)
    80004778:	0127f463          	bgeu	a5,s2,80004780 <writei+0xe2>
    ip->size = off;
    8000477c:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004780:	8556                	mv	a0,s5
    80004782:	00000097          	auipc	ra,0x0
    80004786:	aa6080e7          	jalr	-1370(ra) # 80004228 <iupdate>

  return tot;
    8000478a:	0009851b          	sext.w	a0,s3
}
    8000478e:	70a6                	ld	ra,104(sp)
    80004790:	7406                	ld	s0,96(sp)
    80004792:	64e6                	ld	s1,88(sp)
    80004794:	6946                	ld	s2,80(sp)
    80004796:	69a6                	ld	s3,72(sp)
    80004798:	6a06                	ld	s4,64(sp)
    8000479a:	7ae2                	ld	s5,56(sp)
    8000479c:	7b42                	ld	s6,48(sp)
    8000479e:	7ba2                	ld	s7,40(sp)
    800047a0:	7c02                	ld	s8,32(sp)
    800047a2:	6ce2                	ld	s9,24(sp)
    800047a4:	6d42                	ld	s10,16(sp)
    800047a6:	6da2                	ld	s11,8(sp)
    800047a8:	6165                	addi	sp,sp,112
    800047aa:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800047ac:	89da                	mv	s3,s6
    800047ae:	bfc9                	j	80004780 <writei+0xe2>
    return -1;
    800047b0:	557d                	li	a0,-1
}
    800047b2:	8082                	ret
    return -1;
    800047b4:	557d                	li	a0,-1
    800047b6:	bfe1                	j	8000478e <writei+0xf0>
    return -1;
    800047b8:	557d                	li	a0,-1
    800047ba:	bfd1                	j	8000478e <writei+0xf0>

00000000800047bc <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800047bc:	1141                	addi	sp,sp,-16
    800047be:	e406                	sd	ra,8(sp)
    800047c0:	e022                	sd	s0,0(sp)
    800047c2:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800047c4:	4639                	li	a2,14
    800047c6:	ffffc097          	auipc	ra,0xffffc
    800047ca:	7b6080e7          	jalr	1974(ra) # 80000f7c <strncmp>
}
    800047ce:	60a2                	ld	ra,8(sp)
    800047d0:	6402                	ld	s0,0(sp)
    800047d2:	0141                	addi	sp,sp,16
    800047d4:	8082                	ret

00000000800047d6 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800047d6:	7139                	addi	sp,sp,-64
    800047d8:	fc06                	sd	ra,56(sp)
    800047da:	f822                	sd	s0,48(sp)
    800047dc:	f426                	sd	s1,40(sp)
    800047de:	f04a                	sd	s2,32(sp)
    800047e0:	ec4e                	sd	s3,24(sp)
    800047e2:	e852                	sd	s4,16(sp)
    800047e4:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800047e6:	04451703          	lh	a4,68(a0)
    800047ea:	4785                	li	a5,1
    800047ec:	00f71a63          	bne	a4,a5,80004800 <dirlookup+0x2a>
    800047f0:	892a                	mv	s2,a0
    800047f2:	89ae                	mv	s3,a1
    800047f4:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800047f6:	457c                	lw	a5,76(a0)
    800047f8:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800047fa:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800047fc:	e79d                	bnez	a5,8000482a <dirlookup+0x54>
    800047fe:	a8a5                	j	80004876 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004800:	00004517          	auipc	a0,0x4
    80004804:	f8850513          	addi	a0,a0,-120 # 80008788 <syscalls+0x1d0>
    80004808:	ffffc097          	auipc	ra,0xffffc
    8000480c:	d3c080e7          	jalr	-708(ra) # 80000544 <panic>
      panic("dirlookup read");
    80004810:	00004517          	auipc	a0,0x4
    80004814:	f9050513          	addi	a0,a0,-112 # 800087a0 <syscalls+0x1e8>
    80004818:	ffffc097          	auipc	ra,0xffffc
    8000481c:	d2c080e7          	jalr	-724(ra) # 80000544 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004820:	24c1                	addiw	s1,s1,16
    80004822:	04c92783          	lw	a5,76(s2)
    80004826:	04f4f763          	bgeu	s1,a5,80004874 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000482a:	4741                	li	a4,16
    8000482c:	86a6                	mv	a3,s1
    8000482e:	fc040613          	addi	a2,s0,-64
    80004832:	4581                	li	a1,0
    80004834:	854a                	mv	a0,s2
    80004836:	00000097          	auipc	ra,0x0
    8000483a:	d70080e7          	jalr	-656(ra) # 800045a6 <readi>
    8000483e:	47c1                	li	a5,16
    80004840:	fcf518e3          	bne	a0,a5,80004810 <dirlookup+0x3a>
    if(de.inum == 0)
    80004844:	fc045783          	lhu	a5,-64(s0)
    80004848:	dfe1                	beqz	a5,80004820 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000484a:	fc240593          	addi	a1,s0,-62
    8000484e:	854e                	mv	a0,s3
    80004850:	00000097          	auipc	ra,0x0
    80004854:	f6c080e7          	jalr	-148(ra) # 800047bc <namecmp>
    80004858:	f561                	bnez	a0,80004820 <dirlookup+0x4a>
      if(poff)
    8000485a:	000a0463          	beqz	s4,80004862 <dirlookup+0x8c>
        *poff = off;
    8000485e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004862:	fc045583          	lhu	a1,-64(s0)
    80004866:	00092503          	lw	a0,0(s2)
    8000486a:	fffff097          	auipc	ra,0xfffff
    8000486e:	750080e7          	jalr	1872(ra) # 80003fba <iget>
    80004872:	a011                	j	80004876 <dirlookup+0xa0>
  return 0;
    80004874:	4501                	li	a0,0
}
    80004876:	70e2                	ld	ra,56(sp)
    80004878:	7442                	ld	s0,48(sp)
    8000487a:	74a2                	ld	s1,40(sp)
    8000487c:	7902                	ld	s2,32(sp)
    8000487e:	69e2                	ld	s3,24(sp)
    80004880:	6a42                	ld	s4,16(sp)
    80004882:	6121                	addi	sp,sp,64
    80004884:	8082                	ret

0000000080004886 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004886:	711d                	addi	sp,sp,-96
    80004888:	ec86                	sd	ra,88(sp)
    8000488a:	e8a2                	sd	s0,80(sp)
    8000488c:	e4a6                	sd	s1,72(sp)
    8000488e:	e0ca                	sd	s2,64(sp)
    80004890:	fc4e                	sd	s3,56(sp)
    80004892:	f852                	sd	s4,48(sp)
    80004894:	f456                	sd	s5,40(sp)
    80004896:	f05a                	sd	s6,32(sp)
    80004898:	ec5e                	sd	s7,24(sp)
    8000489a:	e862                	sd	s8,16(sp)
    8000489c:	e466                	sd	s9,8(sp)
    8000489e:	1080                	addi	s0,sp,96
    800048a0:	84aa                	mv	s1,a0
    800048a2:	8b2e                	mv	s6,a1
    800048a4:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800048a6:	00054703          	lbu	a4,0(a0)
    800048aa:	02f00793          	li	a5,47
    800048ae:	02f70363          	beq	a4,a5,800048d4 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800048b2:	ffffd097          	auipc	ra,0xffffd
    800048b6:	4b6080e7          	jalr	1206(ra) # 80001d68 <myproc>
    800048ba:	15853503          	ld	a0,344(a0)
    800048be:	00000097          	auipc	ra,0x0
    800048c2:	9f6080e7          	jalr	-1546(ra) # 800042b4 <idup>
    800048c6:	89aa                	mv	s3,a0
  while(*path == '/')
    800048c8:	02f00913          	li	s2,47
  len = path - s;
    800048cc:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    800048ce:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800048d0:	4c05                	li	s8,1
    800048d2:	a865                	j	8000498a <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    800048d4:	4585                	li	a1,1
    800048d6:	4505                	li	a0,1
    800048d8:	fffff097          	auipc	ra,0xfffff
    800048dc:	6e2080e7          	jalr	1762(ra) # 80003fba <iget>
    800048e0:	89aa                	mv	s3,a0
    800048e2:	b7dd                	j	800048c8 <namex+0x42>
      iunlockput(ip);
    800048e4:	854e                	mv	a0,s3
    800048e6:	00000097          	auipc	ra,0x0
    800048ea:	c6e080e7          	jalr	-914(ra) # 80004554 <iunlockput>
      return 0;
    800048ee:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800048f0:	854e                	mv	a0,s3
    800048f2:	60e6                	ld	ra,88(sp)
    800048f4:	6446                	ld	s0,80(sp)
    800048f6:	64a6                	ld	s1,72(sp)
    800048f8:	6906                	ld	s2,64(sp)
    800048fa:	79e2                	ld	s3,56(sp)
    800048fc:	7a42                	ld	s4,48(sp)
    800048fe:	7aa2                	ld	s5,40(sp)
    80004900:	7b02                	ld	s6,32(sp)
    80004902:	6be2                	ld	s7,24(sp)
    80004904:	6c42                	ld	s8,16(sp)
    80004906:	6ca2                	ld	s9,8(sp)
    80004908:	6125                	addi	sp,sp,96
    8000490a:	8082                	ret
      iunlock(ip);
    8000490c:	854e                	mv	a0,s3
    8000490e:	00000097          	auipc	ra,0x0
    80004912:	aa6080e7          	jalr	-1370(ra) # 800043b4 <iunlock>
      return ip;
    80004916:	bfe9                	j	800048f0 <namex+0x6a>
      iunlockput(ip);
    80004918:	854e                	mv	a0,s3
    8000491a:	00000097          	auipc	ra,0x0
    8000491e:	c3a080e7          	jalr	-966(ra) # 80004554 <iunlockput>
      return 0;
    80004922:	89d2                	mv	s3,s4
    80004924:	b7f1                	j	800048f0 <namex+0x6a>
  len = path - s;
    80004926:	40b48633          	sub	a2,s1,a1
    8000492a:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    8000492e:	094cd463          	bge	s9,s4,800049b6 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004932:	4639                	li	a2,14
    80004934:	8556                	mv	a0,s5
    80004936:	ffffc097          	auipc	ra,0xffffc
    8000493a:	5ce080e7          	jalr	1486(ra) # 80000f04 <memmove>
  while(*path == '/')
    8000493e:	0004c783          	lbu	a5,0(s1)
    80004942:	01279763          	bne	a5,s2,80004950 <namex+0xca>
    path++;
    80004946:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004948:	0004c783          	lbu	a5,0(s1)
    8000494c:	ff278de3          	beq	a5,s2,80004946 <namex+0xc0>
    ilock(ip);
    80004950:	854e                	mv	a0,s3
    80004952:	00000097          	auipc	ra,0x0
    80004956:	9a0080e7          	jalr	-1632(ra) # 800042f2 <ilock>
    if(ip->type != T_DIR){
    8000495a:	04499783          	lh	a5,68(s3)
    8000495e:	f98793e3          	bne	a5,s8,800048e4 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004962:	000b0563          	beqz	s6,8000496c <namex+0xe6>
    80004966:	0004c783          	lbu	a5,0(s1)
    8000496a:	d3cd                	beqz	a5,8000490c <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000496c:	865e                	mv	a2,s7
    8000496e:	85d6                	mv	a1,s5
    80004970:	854e                	mv	a0,s3
    80004972:	00000097          	auipc	ra,0x0
    80004976:	e64080e7          	jalr	-412(ra) # 800047d6 <dirlookup>
    8000497a:	8a2a                	mv	s4,a0
    8000497c:	dd51                	beqz	a0,80004918 <namex+0x92>
    iunlockput(ip);
    8000497e:	854e                	mv	a0,s3
    80004980:	00000097          	auipc	ra,0x0
    80004984:	bd4080e7          	jalr	-1068(ra) # 80004554 <iunlockput>
    ip = next;
    80004988:	89d2                	mv	s3,s4
  while(*path == '/')
    8000498a:	0004c783          	lbu	a5,0(s1)
    8000498e:	05279763          	bne	a5,s2,800049dc <namex+0x156>
    path++;
    80004992:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004994:	0004c783          	lbu	a5,0(s1)
    80004998:	ff278de3          	beq	a5,s2,80004992 <namex+0x10c>
  if(*path == 0)
    8000499c:	c79d                	beqz	a5,800049ca <namex+0x144>
    path++;
    8000499e:	85a6                	mv	a1,s1
  len = path - s;
    800049a0:	8a5e                	mv	s4,s7
    800049a2:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    800049a4:	01278963          	beq	a5,s2,800049b6 <namex+0x130>
    800049a8:	dfbd                	beqz	a5,80004926 <namex+0xa0>
    path++;
    800049aa:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800049ac:	0004c783          	lbu	a5,0(s1)
    800049b0:	ff279ce3          	bne	a5,s2,800049a8 <namex+0x122>
    800049b4:	bf8d                	j	80004926 <namex+0xa0>
    memmove(name, s, len);
    800049b6:	2601                	sext.w	a2,a2
    800049b8:	8556                	mv	a0,s5
    800049ba:	ffffc097          	auipc	ra,0xffffc
    800049be:	54a080e7          	jalr	1354(ra) # 80000f04 <memmove>
    name[len] = 0;
    800049c2:	9a56                	add	s4,s4,s5
    800049c4:	000a0023          	sb	zero,0(s4)
    800049c8:	bf9d                	j	8000493e <namex+0xb8>
  if(nameiparent){
    800049ca:	f20b03e3          	beqz	s6,800048f0 <namex+0x6a>
    iput(ip);
    800049ce:	854e                	mv	a0,s3
    800049d0:	00000097          	auipc	ra,0x0
    800049d4:	adc080e7          	jalr	-1316(ra) # 800044ac <iput>
    return 0;
    800049d8:	4981                	li	s3,0
    800049da:	bf19                	j	800048f0 <namex+0x6a>
  if(*path == 0)
    800049dc:	d7fd                	beqz	a5,800049ca <namex+0x144>
  while(*path != '/' && *path != 0)
    800049de:	0004c783          	lbu	a5,0(s1)
    800049e2:	85a6                	mv	a1,s1
    800049e4:	b7d1                	j	800049a8 <namex+0x122>

00000000800049e6 <dirlink>:
{
    800049e6:	7139                	addi	sp,sp,-64
    800049e8:	fc06                	sd	ra,56(sp)
    800049ea:	f822                	sd	s0,48(sp)
    800049ec:	f426                	sd	s1,40(sp)
    800049ee:	f04a                	sd	s2,32(sp)
    800049f0:	ec4e                	sd	s3,24(sp)
    800049f2:	e852                	sd	s4,16(sp)
    800049f4:	0080                	addi	s0,sp,64
    800049f6:	892a                	mv	s2,a0
    800049f8:	8a2e                	mv	s4,a1
    800049fa:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800049fc:	4601                	li	a2,0
    800049fe:	00000097          	auipc	ra,0x0
    80004a02:	dd8080e7          	jalr	-552(ra) # 800047d6 <dirlookup>
    80004a06:	e93d                	bnez	a0,80004a7c <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004a08:	04c92483          	lw	s1,76(s2)
    80004a0c:	c49d                	beqz	s1,80004a3a <dirlink+0x54>
    80004a0e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004a10:	4741                	li	a4,16
    80004a12:	86a6                	mv	a3,s1
    80004a14:	fc040613          	addi	a2,s0,-64
    80004a18:	4581                	li	a1,0
    80004a1a:	854a                	mv	a0,s2
    80004a1c:	00000097          	auipc	ra,0x0
    80004a20:	b8a080e7          	jalr	-1142(ra) # 800045a6 <readi>
    80004a24:	47c1                	li	a5,16
    80004a26:	06f51163          	bne	a0,a5,80004a88 <dirlink+0xa2>
    if(de.inum == 0)
    80004a2a:	fc045783          	lhu	a5,-64(s0)
    80004a2e:	c791                	beqz	a5,80004a3a <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004a30:	24c1                	addiw	s1,s1,16
    80004a32:	04c92783          	lw	a5,76(s2)
    80004a36:	fcf4ede3          	bltu	s1,a5,80004a10 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004a3a:	4639                	li	a2,14
    80004a3c:	85d2                	mv	a1,s4
    80004a3e:	fc240513          	addi	a0,s0,-62
    80004a42:	ffffc097          	auipc	ra,0xffffc
    80004a46:	576080e7          	jalr	1398(ra) # 80000fb8 <strncpy>
  de.inum = inum;
    80004a4a:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004a4e:	4741                	li	a4,16
    80004a50:	86a6                	mv	a3,s1
    80004a52:	fc040613          	addi	a2,s0,-64
    80004a56:	4581                	li	a1,0
    80004a58:	854a                	mv	a0,s2
    80004a5a:	00000097          	auipc	ra,0x0
    80004a5e:	c44080e7          	jalr	-956(ra) # 8000469e <writei>
    80004a62:	1541                	addi	a0,a0,-16
    80004a64:	00a03533          	snez	a0,a0
    80004a68:	40a00533          	neg	a0,a0
}
    80004a6c:	70e2                	ld	ra,56(sp)
    80004a6e:	7442                	ld	s0,48(sp)
    80004a70:	74a2                	ld	s1,40(sp)
    80004a72:	7902                	ld	s2,32(sp)
    80004a74:	69e2                	ld	s3,24(sp)
    80004a76:	6a42                	ld	s4,16(sp)
    80004a78:	6121                	addi	sp,sp,64
    80004a7a:	8082                	ret
    iput(ip);
    80004a7c:	00000097          	auipc	ra,0x0
    80004a80:	a30080e7          	jalr	-1488(ra) # 800044ac <iput>
    return -1;
    80004a84:	557d                	li	a0,-1
    80004a86:	b7dd                	j	80004a6c <dirlink+0x86>
      panic("dirlink read");
    80004a88:	00004517          	auipc	a0,0x4
    80004a8c:	d2850513          	addi	a0,a0,-728 # 800087b0 <syscalls+0x1f8>
    80004a90:	ffffc097          	auipc	ra,0xffffc
    80004a94:	ab4080e7          	jalr	-1356(ra) # 80000544 <panic>

0000000080004a98 <namei>:

struct inode*
namei(char *path)
{
    80004a98:	1101                	addi	sp,sp,-32
    80004a9a:	ec06                	sd	ra,24(sp)
    80004a9c:	e822                	sd	s0,16(sp)
    80004a9e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004aa0:	fe040613          	addi	a2,s0,-32
    80004aa4:	4581                	li	a1,0
    80004aa6:	00000097          	auipc	ra,0x0
    80004aaa:	de0080e7          	jalr	-544(ra) # 80004886 <namex>
}
    80004aae:	60e2                	ld	ra,24(sp)
    80004ab0:	6442                	ld	s0,16(sp)
    80004ab2:	6105                	addi	sp,sp,32
    80004ab4:	8082                	ret

0000000080004ab6 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004ab6:	1141                	addi	sp,sp,-16
    80004ab8:	e406                	sd	ra,8(sp)
    80004aba:	e022                	sd	s0,0(sp)
    80004abc:	0800                	addi	s0,sp,16
    80004abe:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004ac0:	4585                	li	a1,1
    80004ac2:	00000097          	auipc	ra,0x0
    80004ac6:	dc4080e7          	jalr	-572(ra) # 80004886 <namex>
}
    80004aca:	60a2                	ld	ra,8(sp)
    80004acc:	6402                	ld	s0,0(sp)
    80004ace:	0141                	addi	sp,sp,16
    80004ad0:	8082                	ret

0000000080004ad2 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004ad2:	1101                	addi	sp,sp,-32
    80004ad4:	ec06                	sd	ra,24(sp)
    80004ad6:	e822                	sd	s0,16(sp)
    80004ad8:	e426                	sd	s1,8(sp)
    80004ada:	e04a                	sd	s2,0(sp)
    80004adc:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004ade:	0023e917          	auipc	s2,0x23e
    80004ae2:	5aa90913          	addi	s2,s2,1450 # 80243088 <log>
    80004ae6:	01892583          	lw	a1,24(s2)
    80004aea:	02892503          	lw	a0,40(s2)
    80004aee:	fffff097          	auipc	ra,0xfffff
    80004af2:	fea080e7          	jalr	-22(ra) # 80003ad8 <bread>
    80004af6:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004af8:	02c92683          	lw	a3,44(s2)
    80004afc:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004afe:	02d05763          	blez	a3,80004b2c <write_head+0x5a>
    80004b02:	0023e797          	auipc	a5,0x23e
    80004b06:	5b678793          	addi	a5,a5,1462 # 802430b8 <log+0x30>
    80004b0a:	05c50713          	addi	a4,a0,92
    80004b0e:	36fd                	addiw	a3,a3,-1
    80004b10:	1682                	slli	a3,a3,0x20
    80004b12:	9281                	srli	a3,a3,0x20
    80004b14:	068a                	slli	a3,a3,0x2
    80004b16:	0023e617          	auipc	a2,0x23e
    80004b1a:	5a660613          	addi	a2,a2,1446 # 802430bc <log+0x34>
    80004b1e:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004b20:	4390                	lw	a2,0(a5)
    80004b22:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004b24:	0791                	addi	a5,a5,4
    80004b26:	0711                	addi	a4,a4,4
    80004b28:	fed79ce3          	bne	a5,a3,80004b20 <write_head+0x4e>
  }
  bwrite(buf);
    80004b2c:	8526                	mv	a0,s1
    80004b2e:	fffff097          	auipc	ra,0xfffff
    80004b32:	09c080e7          	jalr	156(ra) # 80003bca <bwrite>
  brelse(buf);
    80004b36:	8526                	mv	a0,s1
    80004b38:	fffff097          	auipc	ra,0xfffff
    80004b3c:	0d0080e7          	jalr	208(ra) # 80003c08 <brelse>
}
    80004b40:	60e2                	ld	ra,24(sp)
    80004b42:	6442                	ld	s0,16(sp)
    80004b44:	64a2                	ld	s1,8(sp)
    80004b46:	6902                	ld	s2,0(sp)
    80004b48:	6105                	addi	sp,sp,32
    80004b4a:	8082                	ret

0000000080004b4c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004b4c:	0023e797          	auipc	a5,0x23e
    80004b50:	5687a783          	lw	a5,1384(a5) # 802430b4 <log+0x2c>
    80004b54:	0af05d63          	blez	a5,80004c0e <install_trans+0xc2>
{
    80004b58:	7139                	addi	sp,sp,-64
    80004b5a:	fc06                	sd	ra,56(sp)
    80004b5c:	f822                	sd	s0,48(sp)
    80004b5e:	f426                	sd	s1,40(sp)
    80004b60:	f04a                	sd	s2,32(sp)
    80004b62:	ec4e                	sd	s3,24(sp)
    80004b64:	e852                	sd	s4,16(sp)
    80004b66:	e456                	sd	s5,8(sp)
    80004b68:	e05a                	sd	s6,0(sp)
    80004b6a:	0080                	addi	s0,sp,64
    80004b6c:	8b2a                	mv	s6,a0
    80004b6e:	0023ea97          	auipc	s5,0x23e
    80004b72:	54aa8a93          	addi	s5,s5,1354 # 802430b8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004b76:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004b78:	0023e997          	auipc	s3,0x23e
    80004b7c:	51098993          	addi	s3,s3,1296 # 80243088 <log>
    80004b80:	a035                	j	80004bac <install_trans+0x60>
      bunpin(dbuf);
    80004b82:	8526                	mv	a0,s1
    80004b84:	fffff097          	auipc	ra,0xfffff
    80004b88:	15e080e7          	jalr	350(ra) # 80003ce2 <bunpin>
    brelse(lbuf);
    80004b8c:	854a                	mv	a0,s2
    80004b8e:	fffff097          	auipc	ra,0xfffff
    80004b92:	07a080e7          	jalr	122(ra) # 80003c08 <brelse>
    brelse(dbuf);
    80004b96:	8526                	mv	a0,s1
    80004b98:	fffff097          	auipc	ra,0xfffff
    80004b9c:	070080e7          	jalr	112(ra) # 80003c08 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004ba0:	2a05                	addiw	s4,s4,1
    80004ba2:	0a91                	addi	s5,s5,4
    80004ba4:	02c9a783          	lw	a5,44(s3)
    80004ba8:	04fa5963          	bge	s4,a5,80004bfa <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004bac:	0189a583          	lw	a1,24(s3)
    80004bb0:	014585bb          	addw	a1,a1,s4
    80004bb4:	2585                	addiw	a1,a1,1
    80004bb6:	0289a503          	lw	a0,40(s3)
    80004bba:	fffff097          	auipc	ra,0xfffff
    80004bbe:	f1e080e7          	jalr	-226(ra) # 80003ad8 <bread>
    80004bc2:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004bc4:	000aa583          	lw	a1,0(s5)
    80004bc8:	0289a503          	lw	a0,40(s3)
    80004bcc:	fffff097          	auipc	ra,0xfffff
    80004bd0:	f0c080e7          	jalr	-244(ra) # 80003ad8 <bread>
    80004bd4:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004bd6:	40000613          	li	a2,1024
    80004bda:	05890593          	addi	a1,s2,88
    80004bde:	05850513          	addi	a0,a0,88
    80004be2:	ffffc097          	auipc	ra,0xffffc
    80004be6:	322080e7          	jalr	802(ra) # 80000f04 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004bea:	8526                	mv	a0,s1
    80004bec:	fffff097          	auipc	ra,0xfffff
    80004bf0:	fde080e7          	jalr	-34(ra) # 80003bca <bwrite>
    if(recovering == 0)
    80004bf4:	f80b1ce3          	bnez	s6,80004b8c <install_trans+0x40>
    80004bf8:	b769                	j	80004b82 <install_trans+0x36>
}
    80004bfa:	70e2                	ld	ra,56(sp)
    80004bfc:	7442                	ld	s0,48(sp)
    80004bfe:	74a2                	ld	s1,40(sp)
    80004c00:	7902                	ld	s2,32(sp)
    80004c02:	69e2                	ld	s3,24(sp)
    80004c04:	6a42                	ld	s4,16(sp)
    80004c06:	6aa2                	ld	s5,8(sp)
    80004c08:	6b02                	ld	s6,0(sp)
    80004c0a:	6121                	addi	sp,sp,64
    80004c0c:	8082                	ret
    80004c0e:	8082                	ret

0000000080004c10 <initlog>:
{
    80004c10:	7179                	addi	sp,sp,-48
    80004c12:	f406                	sd	ra,40(sp)
    80004c14:	f022                	sd	s0,32(sp)
    80004c16:	ec26                	sd	s1,24(sp)
    80004c18:	e84a                	sd	s2,16(sp)
    80004c1a:	e44e                	sd	s3,8(sp)
    80004c1c:	1800                	addi	s0,sp,48
    80004c1e:	892a                	mv	s2,a0
    80004c20:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004c22:	0023e497          	auipc	s1,0x23e
    80004c26:	46648493          	addi	s1,s1,1126 # 80243088 <log>
    80004c2a:	00004597          	auipc	a1,0x4
    80004c2e:	b9658593          	addi	a1,a1,-1130 # 800087c0 <syscalls+0x208>
    80004c32:	8526                	mv	a0,s1
    80004c34:	ffffc097          	auipc	ra,0xffffc
    80004c38:	0e4080e7          	jalr	228(ra) # 80000d18 <initlock>
  log.start = sb->logstart;
    80004c3c:	0149a583          	lw	a1,20(s3)
    80004c40:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004c42:	0109a783          	lw	a5,16(s3)
    80004c46:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004c48:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004c4c:	854a                	mv	a0,s2
    80004c4e:	fffff097          	auipc	ra,0xfffff
    80004c52:	e8a080e7          	jalr	-374(ra) # 80003ad8 <bread>
  log.lh.n = lh->n;
    80004c56:	4d3c                	lw	a5,88(a0)
    80004c58:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004c5a:	02f05563          	blez	a5,80004c84 <initlog+0x74>
    80004c5e:	05c50713          	addi	a4,a0,92
    80004c62:	0023e697          	auipc	a3,0x23e
    80004c66:	45668693          	addi	a3,a3,1110 # 802430b8 <log+0x30>
    80004c6a:	37fd                	addiw	a5,a5,-1
    80004c6c:	1782                	slli	a5,a5,0x20
    80004c6e:	9381                	srli	a5,a5,0x20
    80004c70:	078a                	slli	a5,a5,0x2
    80004c72:	06050613          	addi	a2,a0,96
    80004c76:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80004c78:	4310                	lw	a2,0(a4)
    80004c7a:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80004c7c:	0711                	addi	a4,a4,4
    80004c7e:	0691                	addi	a3,a3,4
    80004c80:	fef71ce3          	bne	a4,a5,80004c78 <initlog+0x68>
  brelse(buf);
    80004c84:	fffff097          	auipc	ra,0xfffff
    80004c88:	f84080e7          	jalr	-124(ra) # 80003c08 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004c8c:	4505                	li	a0,1
    80004c8e:	00000097          	auipc	ra,0x0
    80004c92:	ebe080e7          	jalr	-322(ra) # 80004b4c <install_trans>
  log.lh.n = 0;
    80004c96:	0023e797          	auipc	a5,0x23e
    80004c9a:	4007af23          	sw	zero,1054(a5) # 802430b4 <log+0x2c>
  write_head(); // clear the log
    80004c9e:	00000097          	auipc	ra,0x0
    80004ca2:	e34080e7          	jalr	-460(ra) # 80004ad2 <write_head>
}
    80004ca6:	70a2                	ld	ra,40(sp)
    80004ca8:	7402                	ld	s0,32(sp)
    80004caa:	64e2                	ld	s1,24(sp)
    80004cac:	6942                	ld	s2,16(sp)
    80004cae:	69a2                	ld	s3,8(sp)
    80004cb0:	6145                	addi	sp,sp,48
    80004cb2:	8082                	ret

0000000080004cb4 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004cb4:	1101                	addi	sp,sp,-32
    80004cb6:	ec06                	sd	ra,24(sp)
    80004cb8:	e822                	sd	s0,16(sp)
    80004cba:	e426                	sd	s1,8(sp)
    80004cbc:	e04a                	sd	s2,0(sp)
    80004cbe:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004cc0:	0023e517          	auipc	a0,0x23e
    80004cc4:	3c850513          	addi	a0,a0,968 # 80243088 <log>
    80004cc8:	ffffc097          	auipc	ra,0xffffc
    80004ccc:	0e0080e7          	jalr	224(ra) # 80000da8 <acquire>
  while(1){
    if(log.committing){
    80004cd0:	0023e497          	auipc	s1,0x23e
    80004cd4:	3b848493          	addi	s1,s1,952 # 80243088 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004cd8:	4979                	li	s2,30
    80004cda:	a039                	j	80004ce8 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004cdc:	85a6                	mv	a1,s1
    80004cde:	8526                	mv	a0,s1
    80004ce0:	ffffe097          	auipc	ra,0xffffe
    80004ce4:	984080e7          	jalr	-1660(ra) # 80002664 <sleep>
    if(log.committing){
    80004ce8:	50dc                	lw	a5,36(s1)
    80004cea:	fbed                	bnez	a5,80004cdc <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004cec:	509c                	lw	a5,32(s1)
    80004cee:	0017871b          	addiw	a4,a5,1
    80004cf2:	0007069b          	sext.w	a3,a4
    80004cf6:	0027179b          	slliw	a5,a4,0x2
    80004cfa:	9fb9                	addw	a5,a5,a4
    80004cfc:	0017979b          	slliw	a5,a5,0x1
    80004d00:	54d8                	lw	a4,44(s1)
    80004d02:	9fb9                	addw	a5,a5,a4
    80004d04:	00f95963          	bge	s2,a5,80004d16 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004d08:	85a6                	mv	a1,s1
    80004d0a:	8526                	mv	a0,s1
    80004d0c:	ffffe097          	auipc	ra,0xffffe
    80004d10:	958080e7          	jalr	-1704(ra) # 80002664 <sleep>
    80004d14:	bfd1                	j	80004ce8 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004d16:	0023e517          	auipc	a0,0x23e
    80004d1a:	37250513          	addi	a0,a0,882 # 80243088 <log>
    80004d1e:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004d20:	ffffc097          	auipc	ra,0xffffc
    80004d24:	13c080e7          	jalr	316(ra) # 80000e5c <release>
      break;
    }
  }
}
    80004d28:	60e2                	ld	ra,24(sp)
    80004d2a:	6442                	ld	s0,16(sp)
    80004d2c:	64a2                	ld	s1,8(sp)
    80004d2e:	6902                	ld	s2,0(sp)
    80004d30:	6105                	addi	sp,sp,32
    80004d32:	8082                	ret

0000000080004d34 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004d34:	7139                	addi	sp,sp,-64
    80004d36:	fc06                	sd	ra,56(sp)
    80004d38:	f822                	sd	s0,48(sp)
    80004d3a:	f426                	sd	s1,40(sp)
    80004d3c:	f04a                	sd	s2,32(sp)
    80004d3e:	ec4e                	sd	s3,24(sp)
    80004d40:	e852                	sd	s4,16(sp)
    80004d42:	e456                	sd	s5,8(sp)
    80004d44:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004d46:	0023e497          	auipc	s1,0x23e
    80004d4a:	34248493          	addi	s1,s1,834 # 80243088 <log>
    80004d4e:	8526                	mv	a0,s1
    80004d50:	ffffc097          	auipc	ra,0xffffc
    80004d54:	058080e7          	jalr	88(ra) # 80000da8 <acquire>
  log.outstanding -= 1;
    80004d58:	509c                	lw	a5,32(s1)
    80004d5a:	37fd                	addiw	a5,a5,-1
    80004d5c:	0007891b          	sext.w	s2,a5
    80004d60:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004d62:	50dc                	lw	a5,36(s1)
    80004d64:	efb9                	bnez	a5,80004dc2 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004d66:	06091663          	bnez	s2,80004dd2 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    80004d6a:	0023e497          	auipc	s1,0x23e
    80004d6e:	31e48493          	addi	s1,s1,798 # 80243088 <log>
    80004d72:	4785                	li	a5,1
    80004d74:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004d76:	8526                	mv	a0,s1
    80004d78:	ffffc097          	auipc	ra,0xffffc
    80004d7c:	0e4080e7          	jalr	228(ra) # 80000e5c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004d80:	54dc                	lw	a5,44(s1)
    80004d82:	06f04763          	bgtz	a5,80004df0 <end_op+0xbc>
    acquire(&log.lock);
    80004d86:	0023e497          	auipc	s1,0x23e
    80004d8a:	30248493          	addi	s1,s1,770 # 80243088 <log>
    80004d8e:	8526                	mv	a0,s1
    80004d90:	ffffc097          	auipc	ra,0xffffc
    80004d94:	018080e7          	jalr	24(ra) # 80000da8 <acquire>
    log.committing = 0;
    80004d98:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004d9c:	8526                	mv	a0,s1
    80004d9e:	ffffe097          	auipc	ra,0xffffe
    80004da2:	bc4080e7          	jalr	-1084(ra) # 80002962 <wakeup>
    release(&log.lock);
    80004da6:	8526                	mv	a0,s1
    80004da8:	ffffc097          	auipc	ra,0xffffc
    80004dac:	0b4080e7          	jalr	180(ra) # 80000e5c <release>
}
    80004db0:	70e2                	ld	ra,56(sp)
    80004db2:	7442                	ld	s0,48(sp)
    80004db4:	74a2                	ld	s1,40(sp)
    80004db6:	7902                	ld	s2,32(sp)
    80004db8:	69e2                	ld	s3,24(sp)
    80004dba:	6a42                	ld	s4,16(sp)
    80004dbc:	6aa2                	ld	s5,8(sp)
    80004dbe:	6121                	addi	sp,sp,64
    80004dc0:	8082                	ret
    panic("log.committing");
    80004dc2:	00004517          	auipc	a0,0x4
    80004dc6:	a0650513          	addi	a0,a0,-1530 # 800087c8 <syscalls+0x210>
    80004dca:	ffffb097          	auipc	ra,0xffffb
    80004dce:	77a080e7          	jalr	1914(ra) # 80000544 <panic>
    wakeup(&log);
    80004dd2:	0023e497          	auipc	s1,0x23e
    80004dd6:	2b648493          	addi	s1,s1,694 # 80243088 <log>
    80004dda:	8526                	mv	a0,s1
    80004ddc:	ffffe097          	auipc	ra,0xffffe
    80004de0:	b86080e7          	jalr	-1146(ra) # 80002962 <wakeup>
  release(&log.lock);
    80004de4:	8526                	mv	a0,s1
    80004de6:	ffffc097          	auipc	ra,0xffffc
    80004dea:	076080e7          	jalr	118(ra) # 80000e5c <release>
  if(do_commit){
    80004dee:	b7c9                	j	80004db0 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004df0:	0023ea97          	auipc	s5,0x23e
    80004df4:	2c8a8a93          	addi	s5,s5,712 # 802430b8 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004df8:	0023ea17          	auipc	s4,0x23e
    80004dfc:	290a0a13          	addi	s4,s4,656 # 80243088 <log>
    80004e00:	018a2583          	lw	a1,24(s4)
    80004e04:	012585bb          	addw	a1,a1,s2
    80004e08:	2585                	addiw	a1,a1,1
    80004e0a:	028a2503          	lw	a0,40(s4)
    80004e0e:	fffff097          	auipc	ra,0xfffff
    80004e12:	cca080e7          	jalr	-822(ra) # 80003ad8 <bread>
    80004e16:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004e18:	000aa583          	lw	a1,0(s5)
    80004e1c:	028a2503          	lw	a0,40(s4)
    80004e20:	fffff097          	auipc	ra,0xfffff
    80004e24:	cb8080e7          	jalr	-840(ra) # 80003ad8 <bread>
    80004e28:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004e2a:	40000613          	li	a2,1024
    80004e2e:	05850593          	addi	a1,a0,88
    80004e32:	05848513          	addi	a0,s1,88
    80004e36:	ffffc097          	auipc	ra,0xffffc
    80004e3a:	0ce080e7          	jalr	206(ra) # 80000f04 <memmove>
    bwrite(to);  // write the log
    80004e3e:	8526                	mv	a0,s1
    80004e40:	fffff097          	auipc	ra,0xfffff
    80004e44:	d8a080e7          	jalr	-630(ra) # 80003bca <bwrite>
    brelse(from);
    80004e48:	854e                	mv	a0,s3
    80004e4a:	fffff097          	auipc	ra,0xfffff
    80004e4e:	dbe080e7          	jalr	-578(ra) # 80003c08 <brelse>
    brelse(to);
    80004e52:	8526                	mv	a0,s1
    80004e54:	fffff097          	auipc	ra,0xfffff
    80004e58:	db4080e7          	jalr	-588(ra) # 80003c08 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004e5c:	2905                	addiw	s2,s2,1
    80004e5e:	0a91                	addi	s5,s5,4
    80004e60:	02ca2783          	lw	a5,44(s4)
    80004e64:	f8f94ee3          	blt	s2,a5,80004e00 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004e68:	00000097          	auipc	ra,0x0
    80004e6c:	c6a080e7          	jalr	-918(ra) # 80004ad2 <write_head>
    install_trans(0); // Now install writes to home locations
    80004e70:	4501                	li	a0,0
    80004e72:	00000097          	auipc	ra,0x0
    80004e76:	cda080e7          	jalr	-806(ra) # 80004b4c <install_trans>
    log.lh.n = 0;
    80004e7a:	0023e797          	auipc	a5,0x23e
    80004e7e:	2207ad23          	sw	zero,570(a5) # 802430b4 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004e82:	00000097          	auipc	ra,0x0
    80004e86:	c50080e7          	jalr	-944(ra) # 80004ad2 <write_head>
    80004e8a:	bdf5                	j	80004d86 <end_op+0x52>

0000000080004e8c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004e8c:	1101                	addi	sp,sp,-32
    80004e8e:	ec06                	sd	ra,24(sp)
    80004e90:	e822                	sd	s0,16(sp)
    80004e92:	e426                	sd	s1,8(sp)
    80004e94:	e04a                	sd	s2,0(sp)
    80004e96:	1000                	addi	s0,sp,32
    80004e98:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004e9a:	0023e917          	auipc	s2,0x23e
    80004e9e:	1ee90913          	addi	s2,s2,494 # 80243088 <log>
    80004ea2:	854a                	mv	a0,s2
    80004ea4:	ffffc097          	auipc	ra,0xffffc
    80004ea8:	f04080e7          	jalr	-252(ra) # 80000da8 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004eac:	02c92603          	lw	a2,44(s2)
    80004eb0:	47f5                	li	a5,29
    80004eb2:	06c7c563          	blt	a5,a2,80004f1c <log_write+0x90>
    80004eb6:	0023e797          	auipc	a5,0x23e
    80004eba:	1ee7a783          	lw	a5,494(a5) # 802430a4 <log+0x1c>
    80004ebe:	37fd                	addiw	a5,a5,-1
    80004ec0:	04f65e63          	bge	a2,a5,80004f1c <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004ec4:	0023e797          	auipc	a5,0x23e
    80004ec8:	1e47a783          	lw	a5,484(a5) # 802430a8 <log+0x20>
    80004ecc:	06f05063          	blez	a5,80004f2c <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004ed0:	4781                	li	a5,0
    80004ed2:	06c05563          	blez	a2,80004f3c <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004ed6:	44cc                	lw	a1,12(s1)
    80004ed8:	0023e717          	auipc	a4,0x23e
    80004edc:	1e070713          	addi	a4,a4,480 # 802430b8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004ee0:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004ee2:	4314                	lw	a3,0(a4)
    80004ee4:	04b68c63          	beq	a3,a1,80004f3c <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004ee8:	2785                	addiw	a5,a5,1
    80004eea:	0711                	addi	a4,a4,4
    80004eec:	fef61be3          	bne	a2,a5,80004ee2 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004ef0:	0621                	addi	a2,a2,8
    80004ef2:	060a                	slli	a2,a2,0x2
    80004ef4:	0023e797          	auipc	a5,0x23e
    80004ef8:	19478793          	addi	a5,a5,404 # 80243088 <log>
    80004efc:	963e                	add	a2,a2,a5
    80004efe:	44dc                	lw	a5,12(s1)
    80004f00:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004f02:	8526                	mv	a0,s1
    80004f04:	fffff097          	auipc	ra,0xfffff
    80004f08:	da2080e7          	jalr	-606(ra) # 80003ca6 <bpin>
    log.lh.n++;
    80004f0c:	0023e717          	auipc	a4,0x23e
    80004f10:	17c70713          	addi	a4,a4,380 # 80243088 <log>
    80004f14:	575c                	lw	a5,44(a4)
    80004f16:	2785                	addiw	a5,a5,1
    80004f18:	d75c                	sw	a5,44(a4)
    80004f1a:	a835                	j	80004f56 <log_write+0xca>
    panic("too big a transaction");
    80004f1c:	00004517          	auipc	a0,0x4
    80004f20:	8bc50513          	addi	a0,a0,-1860 # 800087d8 <syscalls+0x220>
    80004f24:	ffffb097          	auipc	ra,0xffffb
    80004f28:	620080e7          	jalr	1568(ra) # 80000544 <panic>
    panic("log_write outside of trans");
    80004f2c:	00004517          	auipc	a0,0x4
    80004f30:	8c450513          	addi	a0,a0,-1852 # 800087f0 <syscalls+0x238>
    80004f34:	ffffb097          	auipc	ra,0xffffb
    80004f38:	610080e7          	jalr	1552(ra) # 80000544 <panic>
  log.lh.block[i] = b->blockno;
    80004f3c:	00878713          	addi	a4,a5,8
    80004f40:	00271693          	slli	a3,a4,0x2
    80004f44:	0023e717          	auipc	a4,0x23e
    80004f48:	14470713          	addi	a4,a4,324 # 80243088 <log>
    80004f4c:	9736                	add	a4,a4,a3
    80004f4e:	44d4                	lw	a3,12(s1)
    80004f50:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004f52:	faf608e3          	beq	a2,a5,80004f02 <log_write+0x76>
  }
  release(&log.lock);
    80004f56:	0023e517          	auipc	a0,0x23e
    80004f5a:	13250513          	addi	a0,a0,306 # 80243088 <log>
    80004f5e:	ffffc097          	auipc	ra,0xffffc
    80004f62:	efe080e7          	jalr	-258(ra) # 80000e5c <release>
}
    80004f66:	60e2                	ld	ra,24(sp)
    80004f68:	6442                	ld	s0,16(sp)
    80004f6a:	64a2                	ld	s1,8(sp)
    80004f6c:	6902                	ld	s2,0(sp)
    80004f6e:	6105                	addi	sp,sp,32
    80004f70:	8082                	ret

0000000080004f72 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004f72:	1101                	addi	sp,sp,-32
    80004f74:	ec06                	sd	ra,24(sp)
    80004f76:	e822                	sd	s0,16(sp)
    80004f78:	e426                	sd	s1,8(sp)
    80004f7a:	e04a                	sd	s2,0(sp)
    80004f7c:	1000                	addi	s0,sp,32
    80004f7e:	84aa                	mv	s1,a0
    80004f80:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004f82:	00004597          	auipc	a1,0x4
    80004f86:	88e58593          	addi	a1,a1,-1906 # 80008810 <syscalls+0x258>
    80004f8a:	0521                	addi	a0,a0,8
    80004f8c:	ffffc097          	auipc	ra,0xffffc
    80004f90:	d8c080e7          	jalr	-628(ra) # 80000d18 <initlock>
  lk->name = name;
    80004f94:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004f98:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004f9c:	0204a423          	sw	zero,40(s1)
}
    80004fa0:	60e2                	ld	ra,24(sp)
    80004fa2:	6442                	ld	s0,16(sp)
    80004fa4:	64a2                	ld	s1,8(sp)
    80004fa6:	6902                	ld	s2,0(sp)
    80004fa8:	6105                	addi	sp,sp,32
    80004faa:	8082                	ret

0000000080004fac <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004fac:	1101                	addi	sp,sp,-32
    80004fae:	ec06                	sd	ra,24(sp)
    80004fb0:	e822                	sd	s0,16(sp)
    80004fb2:	e426                	sd	s1,8(sp)
    80004fb4:	e04a                	sd	s2,0(sp)
    80004fb6:	1000                	addi	s0,sp,32
    80004fb8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004fba:	00850913          	addi	s2,a0,8
    80004fbe:	854a                	mv	a0,s2
    80004fc0:	ffffc097          	auipc	ra,0xffffc
    80004fc4:	de8080e7          	jalr	-536(ra) # 80000da8 <acquire>
  while (lk->locked) {
    80004fc8:	409c                	lw	a5,0(s1)
    80004fca:	cb89                	beqz	a5,80004fdc <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004fcc:	85ca                	mv	a1,s2
    80004fce:	8526                	mv	a0,s1
    80004fd0:	ffffd097          	auipc	ra,0xffffd
    80004fd4:	694080e7          	jalr	1684(ra) # 80002664 <sleep>
  while (lk->locked) {
    80004fd8:	409c                	lw	a5,0(s1)
    80004fda:	fbed                	bnez	a5,80004fcc <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004fdc:	4785                	li	a5,1
    80004fde:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004fe0:	ffffd097          	auipc	ra,0xffffd
    80004fe4:	d88080e7          	jalr	-632(ra) # 80001d68 <myproc>
    80004fe8:	5d1c                	lw	a5,56(a0)
    80004fea:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004fec:	854a                	mv	a0,s2
    80004fee:	ffffc097          	auipc	ra,0xffffc
    80004ff2:	e6e080e7          	jalr	-402(ra) # 80000e5c <release>
}
    80004ff6:	60e2                	ld	ra,24(sp)
    80004ff8:	6442                	ld	s0,16(sp)
    80004ffa:	64a2                	ld	s1,8(sp)
    80004ffc:	6902                	ld	s2,0(sp)
    80004ffe:	6105                	addi	sp,sp,32
    80005000:	8082                	ret

0000000080005002 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80005002:	1101                	addi	sp,sp,-32
    80005004:	ec06                	sd	ra,24(sp)
    80005006:	e822                	sd	s0,16(sp)
    80005008:	e426                	sd	s1,8(sp)
    8000500a:	e04a                	sd	s2,0(sp)
    8000500c:	1000                	addi	s0,sp,32
    8000500e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80005010:	00850913          	addi	s2,a0,8
    80005014:	854a                	mv	a0,s2
    80005016:	ffffc097          	auipc	ra,0xffffc
    8000501a:	d92080e7          	jalr	-622(ra) # 80000da8 <acquire>
  lk->locked = 0;
    8000501e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80005022:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80005026:	8526                	mv	a0,s1
    80005028:	ffffe097          	auipc	ra,0xffffe
    8000502c:	93a080e7          	jalr	-1734(ra) # 80002962 <wakeup>
  release(&lk->lk);
    80005030:	854a                	mv	a0,s2
    80005032:	ffffc097          	auipc	ra,0xffffc
    80005036:	e2a080e7          	jalr	-470(ra) # 80000e5c <release>
}
    8000503a:	60e2                	ld	ra,24(sp)
    8000503c:	6442                	ld	s0,16(sp)
    8000503e:	64a2                	ld	s1,8(sp)
    80005040:	6902                	ld	s2,0(sp)
    80005042:	6105                	addi	sp,sp,32
    80005044:	8082                	ret

0000000080005046 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80005046:	7179                	addi	sp,sp,-48
    80005048:	f406                	sd	ra,40(sp)
    8000504a:	f022                	sd	s0,32(sp)
    8000504c:	ec26                	sd	s1,24(sp)
    8000504e:	e84a                	sd	s2,16(sp)
    80005050:	e44e                	sd	s3,8(sp)
    80005052:	1800                	addi	s0,sp,48
    80005054:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80005056:	00850913          	addi	s2,a0,8
    8000505a:	854a                	mv	a0,s2
    8000505c:	ffffc097          	auipc	ra,0xffffc
    80005060:	d4c080e7          	jalr	-692(ra) # 80000da8 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80005064:	409c                	lw	a5,0(s1)
    80005066:	ef99                	bnez	a5,80005084 <holdingsleep+0x3e>
    80005068:	4481                	li	s1,0
  release(&lk->lk);
    8000506a:	854a                	mv	a0,s2
    8000506c:	ffffc097          	auipc	ra,0xffffc
    80005070:	df0080e7          	jalr	-528(ra) # 80000e5c <release>
  return r;
}
    80005074:	8526                	mv	a0,s1
    80005076:	70a2                	ld	ra,40(sp)
    80005078:	7402                	ld	s0,32(sp)
    8000507a:	64e2                	ld	s1,24(sp)
    8000507c:	6942                	ld	s2,16(sp)
    8000507e:	69a2                	ld	s3,8(sp)
    80005080:	6145                	addi	sp,sp,48
    80005082:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80005084:	0284a983          	lw	s3,40(s1)
    80005088:	ffffd097          	auipc	ra,0xffffd
    8000508c:	ce0080e7          	jalr	-800(ra) # 80001d68 <myproc>
    80005090:	5d04                	lw	s1,56(a0)
    80005092:	413484b3          	sub	s1,s1,s3
    80005096:	0014b493          	seqz	s1,s1
    8000509a:	bfc1                	j	8000506a <holdingsleep+0x24>

000000008000509c <fileinit>:
	struct spinlock lock;
	struct file file[NFILE];
} ftable;

void fileinit(void)
{
    8000509c:	1141                	addi	sp,sp,-16
    8000509e:	e406                	sd	ra,8(sp)
    800050a0:	e022                	sd	s0,0(sp)
    800050a2:	0800                	addi	s0,sp,16
	initlock(&ftable.lock, "ftable");
    800050a4:	00003597          	auipc	a1,0x3
    800050a8:	77c58593          	addi	a1,a1,1916 # 80008820 <syscalls+0x268>
    800050ac:	0023e517          	auipc	a0,0x23e
    800050b0:	12450513          	addi	a0,a0,292 # 802431d0 <ftable>
    800050b4:	ffffc097          	auipc	ra,0xffffc
    800050b8:	c64080e7          	jalr	-924(ra) # 80000d18 <initlock>
}
    800050bc:	60a2                	ld	ra,8(sp)
    800050be:	6402                	ld	s0,0(sp)
    800050c0:	0141                	addi	sp,sp,16
    800050c2:	8082                	ret

00000000800050c4 <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    800050c4:	1101                	addi	sp,sp,-32
    800050c6:	ec06                	sd	ra,24(sp)
    800050c8:	e822                	sd	s0,16(sp)
    800050ca:	e426                	sd	s1,8(sp)
    800050cc:	1000                	addi	s0,sp,32
	struct file *f;

	acquire(&ftable.lock);
    800050ce:	0023e517          	auipc	a0,0x23e
    800050d2:	10250513          	addi	a0,a0,258 # 802431d0 <ftable>
    800050d6:	ffffc097          	auipc	ra,0xffffc
    800050da:	cd2080e7          	jalr	-814(ra) # 80000da8 <acquire>
	for (f = ftable.file; f < ftable.file + NFILE; f++)
    800050de:	0023e497          	auipc	s1,0x23e
    800050e2:	10a48493          	addi	s1,s1,266 # 802431e8 <ftable+0x18>
    800050e6:	0023f717          	auipc	a4,0x23f
    800050ea:	0a270713          	addi	a4,a4,162 # 80244188 <disk>
	{
		if (f->ref == 0)
    800050ee:	40dc                	lw	a5,4(s1)
    800050f0:	cf99                	beqz	a5,8000510e <filealloc+0x4a>
	for (f = ftable.file; f < ftable.file + NFILE; f++)
    800050f2:	02848493          	addi	s1,s1,40
    800050f6:	fee49ce3          	bne	s1,a4,800050ee <filealloc+0x2a>
			f->ref = 1;
			release(&ftable.lock);
			return f;
		}
	}
	release(&ftable.lock);
    800050fa:	0023e517          	auipc	a0,0x23e
    800050fe:	0d650513          	addi	a0,a0,214 # 802431d0 <ftable>
    80005102:	ffffc097          	auipc	ra,0xffffc
    80005106:	d5a080e7          	jalr	-678(ra) # 80000e5c <release>
	return 0;
    8000510a:	4481                	li	s1,0
    8000510c:	a819                	j	80005122 <filealloc+0x5e>
			f->ref = 1;
    8000510e:	4785                	li	a5,1
    80005110:	c0dc                	sw	a5,4(s1)
			release(&ftable.lock);
    80005112:	0023e517          	auipc	a0,0x23e
    80005116:	0be50513          	addi	a0,a0,190 # 802431d0 <ftable>
    8000511a:	ffffc097          	auipc	ra,0xffffc
    8000511e:	d42080e7          	jalr	-702(ra) # 80000e5c <release>
}
    80005122:	8526                	mv	a0,s1
    80005124:	60e2                	ld	ra,24(sp)
    80005126:	6442                	ld	s0,16(sp)
    80005128:	64a2                	ld	s1,8(sp)
    8000512a:	6105                	addi	sp,sp,32
    8000512c:	8082                	ret

000000008000512e <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    8000512e:	1101                	addi	sp,sp,-32
    80005130:	ec06                	sd	ra,24(sp)
    80005132:	e822                	sd	s0,16(sp)
    80005134:	e426                	sd	s1,8(sp)
    80005136:	1000                	addi	s0,sp,32
    80005138:	84aa                	mv	s1,a0
	acquire(&ftable.lock);
    8000513a:	0023e517          	auipc	a0,0x23e
    8000513e:	09650513          	addi	a0,a0,150 # 802431d0 <ftable>
    80005142:	ffffc097          	auipc	ra,0xffffc
    80005146:	c66080e7          	jalr	-922(ra) # 80000da8 <acquire>
	if (f->ref < 1)
    8000514a:	40dc                	lw	a5,4(s1)
    8000514c:	02f05263          	blez	a5,80005170 <filedup+0x42>
		panic("filedup");
	f->ref++;
    80005150:	2785                	addiw	a5,a5,1
    80005152:	c0dc                	sw	a5,4(s1)
	release(&ftable.lock);
    80005154:	0023e517          	auipc	a0,0x23e
    80005158:	07c50513          	addi	a0,a0,124 # 802431d0 <ftable>
    8000515c:	ffffc097          	auipc	ra,0xffffc
    80005160:	d00080e7          	jalr	-768(ra) # 80000e5c <release>
	return f;
}
    80005164:	8526                	mv	a0,s1
    80005166:	60e2                	ld	ra,24(sp)
    80005168:	6442                	ld	s0,16(sp)
    8000516a:	64a2                	ld	s1,8(sp)
    8000516c:	6105                	addi	sp,sp,32
    8000516e:	8082                	ret
		panic("filedup");
    80005170:	00003517          	auipc	a0,0x3
    80005174:	6b850513          	addi	a0,a0,1720 # 80008828 <syscalls+0x270>
    80005178:	ffffb097          	auipc	ra,0xffffb
    8000517c:	3cc080e7          	jalr	972(ra) # 80000544 <panic>

0000000080005180 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void fileclose(struct file *f)
{
    80005180:	7139                	addi	sp,sp,-64
    80005182:	fc06                	sd	ra,56(sp)
    80005184:	f822                	sd	s0,48(sp)
    80005186:	f426                	sd	s1,40(sp)
    80005188:	f04a                	sd	s2,32(sp)
    8000518a:	ec4e                	sd	s3,24(sp)
    8000518c:	e852                	sd	s4,16(sp)
    8000518e:	e456                	sd	s5,8(sp)
    80005190:	0080                	addi	s0,sp,64
    80005192:	84aa                	mv	s1,a0
	struct file ff;

	acquire(&ftable.lock);
    80005194:	0023e517          	auipc	a0,0x23e
    80005198:	03c50513          	addi	a0,a0,60 # 802431d0 <ftable>
    8000519c:	ffffc097          	auipc	ra,0xffffc
    800051a0:	c0c080e7          	jalr	-1012(ra) # 80000da8 <acquire>
	if (f->ref < 1)
    800051a4:	40dc                	lw	a5,4(s1)
    800051a6:	06f05163          	blez	a5,80005208 <fileclose+0x88>
		panic("fileclose");
	if (--f->ref > 0)
    800051aa:	37fd                	addiw	a5,a5,-1
    800051ac:	0007871b          	sext.w	a4,a5
    800051b0:	c0dc                	sw	a5,4(s1)
    800051b2:	06e04363          	bgtz	a4,80005218 <fileclose+0x98>
	{
		release(&ftable.lock);
		return;
	}
	ff = *f;
    800051b6:	0004a903          	lw	s2,0(s1)
    800051ba:	0094ca83          	lbu	s5,9(s1)
    800051be:	0104ba03          	ld	s4,16(s1)
    800051c2:	0184b983          	ld	s3,24(s1)
	f->ref = 0;
    800051c6:	0004a223          	sw	zero,4(s1)
	f->type = FD_NONE;
    800051ca:	0004a023          	sw	zero,0(s1)
	release(&ftable.lock);
    800051ce:	0023e517          	auipc	a0,0x23e
    800051d2:	00250513          	addi	a0,a0,2 # 802431d0 <ftable>
    800051d6:	ffffc097          	auipc	ra,0xffffc
    800051da:	c86080e7          	jalr	-890(ra) # 80000e5c <release>

	if (ff.type == FD_PIPE)
    800051de:	4785                	li	a5,1
    800051e0:	04f90d63          	beq	s2,a5,8000523a <fileclose+0xba>
	{
		pipeclose(ff.pipe, ff.writable);
	}
	else if (ff.type == FD_INODE || ff.type == FD_DEVICE)
    800051e4:	3979                	addiw	s2,s2,-2
    800051e6:	4785                	li	a5,1
    800051e8:	0527e063          	bltu	a5,s2,80005228 <fileclose+0xa8>
	{
		begin_op();
    800051ec:	00000097          	auipc	ra,0x0
    800051f0:	ac8080e7          	jalr	-1336(ra) # 80004cb4 <begin_op>
		iput(ff.ip);
    800051f4:	854e                	mv	a0,s3
    800051f6:	fffff097          	auipc	ra,0xfffff
    800051fa:	2b6080e7          	jalr	694(ra) # 800044ac <iput>
		end_op();
    800051fe:	00000097          	auipc	ra,0x0
    80005202:	b36080e7          	jalr	-1226(ra) # 80004d34 <end_op>
    80005206:	a00d                	j	80005228 <fileclose+0xa8>
		panic("fileclose");
    80005208:	00003517          	auipc	a0,0x3
    8000520c:	62850513          	addi	a0,a0,1576 # 80008830 <syscalls+0x278>
    80005210:	ffffb097          	auipc	ra,0xffffb
    80005214:	334080e7          	jalr	820(ra) # 80000544 <panic>
		release(&ftable.lock);
    80005218:	0023e517          	auipc	a0,0x23e
    8000521c:	fb850513          	addi	a0,a0,-72 # 802431d0 <ftable>
    80005220:	ffffc097          	auipc	ra,0xffffc
    80005224:	c3c080e7          	jalr	-964(ra) # 80000e5c <release>
	}
}
    80005228:	70e2                	ld	ra,56(sp)
    8000522a:	7442                	ld	s0,48(sp)
    8000522c:	74a2                	ld	s1,40(sp)
    8000522e:	7902                	ld	s2,32(sp)
    80005230:	69e2                	ld	s3,24(sp)
    80005232:	6a42                	ld	s4,16(sp)
    80005234:	6aa2                	ld	s5,8(sp)
    80005236:	6121                	addi	sp,sp,64
    80005238:	8082                	ret
		pipeclose(ff.pipe, ff.writable);
    8000523a:	85d6                	mv	a1,s5
    8000523c:	8552                	mv	a0,s4
    8000523e:	00000097          	auipc	ra,0x0
    80005242:	34c080e7          	jalr	844(ra) # 8000558a <pipeclose>
    80005246:	b7cd                	j	80005228 <fileclose+0xa8>

0000000080005248 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int filestat(struct file *f, uint64 addr)
{
    80005248:	715d                	addi	sp,sp,-80
    8000524a:	e486                	sd	ra,72(sp)
    8000524c:	e0a2                	sd	s0,64(sp)
    8000524e:	fc26                	sd	s1,56(sp)
    80005250:	f84a                	sd	s2,48(sp)
    80005252:	f44e                	sd	s3,40(sp)
    80005254:	0880                	addi	s0,sp,80
    80005256:	84aa                	mv	s1,a0
    80005258:	89ae                	mv	s3,a1
	struct proc *p = myproc();
    8000525a:	ffffd097          	auipc	ra,0xffffd
    8000525e:	b0e080e7          	jalr	-1266(ra) # 80001d68 <myproc>
	struct stat st;

	if (f->type == FD_INODE || f->type == FD_DEVICE)
    80005262:	409c                	lw	a5,0(s1)
    80005264:	37f9                	addiw	a5,a5,-2
    80005266:	4705                	li	a4,1
    80005268:	04f76763          	bltu	a4,a5,800052b6 <filestat+0x6e>
    8000526c:	892a                	mv	s2,a0
	{
		ilock(f->ip);
    8000526e:	6c88                	ld	a0,24(s1)
    80005270:	fffff097          	auipc	ra,0xfffff
    80005274:	082080e7          	jalr	130(ra) # 800042f2 <ilock>
		stati(f->ip, &st);
    80005278:	fb840593          	addi	a1,s0,-72
    8000527c:	6c88                	ld	a0,24(s1)
    8000527e:	fffff097          	auipc	ra,0xfffff
    80005282:	2fe080e7          	jalr	766(ra) # 8000457c <stati>
		iunlock(f->ip);
    80005286:	6c88                	ld	a0,24(s1)
    80005288:	fffff097          	auipc	ra,0xfffff
    8000528c:	12c080e7          	jalr	300(ra) # 800043b4 <iunlock>
		if (copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80005290:	46e1                	li	a3,24
    80005292:	fb840613          	addi	a2,s0,-72
    80005296:	85ce                	mv	a1,s3
    80005298:	05893503          	ld	a0,88(s2)
    8000529c:	ffffc097          	auipc	ra,0xffffc
    800052a0:	59c080e7          	jalr	1436(ra) # 80001838 <copyout>
    800052a4:	41f5551b          	sraiw	a0,a0,0x1f
			return -1;
		return 0;
	}
	return -1;
}
    800052a8:	60a6                	ld	ra,72(sp)
    800052aa:	6406                	ld	s0,64(sp)
    800052ac:	74e2                	ld	s1,56(sp)
    800052ae:	7942                	ld	s2,48(sp)
    800052b0:	79a2                	ld	s3,40(sp)
    800052b2:	6161                	addi	sp,sp,80
    800052b4:	8082                	ret
	return -1;
    800052b6:	557d                	li	a0,-1
    800052b8:	bfc5                	j	800052a8 <filestat+0x60>

00000000800052ba <fileread>:

// Read from file f.
// addr is a user virtual address.
int fileread(struct file *f, uint64 addr, int n)
{
    800052ba:	7179                	addi	sp,sp,-48
    800052bc:	f406                	sd	ra,40(sp)
    800052be:	f022                	sd	s0,32(sp)
    800052c0:	ec26                	sd	s1,24(sp)
    800052c2:	e84a                	sd	s2,16(sp)
    800052c4:	e44e                	sd	s3,8(sp)
    800052c6:	1800                	addi	s0,sp,48
	int r = 0;

	if (f->readable == 0)
    800052c8:	00854783          	lbu	a5,8(a0)
    800052cc:	c3d5                	beqz	a5,80005370 <fileread+0xb6>
    800052ce:	84aa                	mv	s1,a0
    800052d0:	89ae                	mv	s3,a1
    800052d2:	8932                	mv	s2,a2
		return -1;

	if (f->type == FD_PIPE)
    800052d4:	411c                	lw	a5,0(a0)
    800052d6:	4705                	li	a4,1
    800052d8:	04e78963          	beq	a5,a4,8000532a <fileread+0x70>
	{
		r = piperead(f->pipe, addr, n);
		// printf("here\n");
	}
	else if (f->type == FD_DEVICE)
    800052dc:	470d                	li	a4,3
    800052de:	04e78d63          	beq	a5,a4,80005338 <fileread+0x7e>
	{
		if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
			return -1;
		r = devsw[f->major].read(1, addr, n);
	}
	else if (f->type == FD_INODE)
    800052e2:	4709                	li	a4,2
    800052e4:	06e79e63          	bne	a5,a4,80005360 <fileread+0xa6>
	{
		ilock(f->ip);
    800052e8:	6d08                	ld	a0,24(a0)
    800052ea:	fffff097          	auipc	ra,0xfffff
    800052ee:	008080e7          	jalr	8(ra) # 800042f2 <ilock>
		if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800052f2:	874a                	mv	a4,s2
    800052f4:	5094                	lw	a3,32(s1)
    800052f6:	864e                	mv	a2,s3
    800052f8:	4585                	li	a1,1
    800052fa:	6c88                	ld	a0,24(s1)
    800052fc:	fffff097          	auipc	ra,0xfffff
    80005300:	2aa080e7          	jalr	682(ra) # 800045a6 <readi>
    80005304:	892a                	mv	s2,a0
    80005306:	00a05563          	blez	a0,80005310 <fileread+0x56>
			f->off += r;
    8000530a:	509c                	lw	a5,32(s1)
    8000530c:	9fa9                	addw	a5,a5,a0
    8000530e:	d09c                	sw	a5,32(s1)
		iunlock(f->ip);
    80005310:	6c88                	ld	a0,24(s1)
    80005312:	fffff097          	auipc	ra,0xfffff
    80005316:	0a2080e7          	jalr	162(ra) # 800043b4 <iunlock>
	{
		panic("fileread");
	}

	return r;
}
    8000531a:	854a                	mv	a0,s2
    8000531c:	70a2                	ld	ra,40(sp)
    8000531e:	7402                	ld	s0,32(sp)
    80005320:	64e2                	ld	s1,24(sp)
    80005322:	6942                	ld	s2,16(sp)
    80005324:	69a2                	ld	s3,8(sp)
    80005326:	6145                	addi	sp,sp,48
    80005328:	8082                	ret
		r = piperead(f->pipe, addr, n);
    8000532a:	6908                	ld	a0,16(a0)
    8000532c:	00000097          	auipc	ra,0x0
    80005330:	3ce080e7          	jalr	974(ra) # 800056fa <piperead>
    80005334:	892a                	mv	s2,a0
    80005336:	b7d5                	j	8000531a <fileread+0x60>
		if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80005338:	02451783          	lh	a5,36(a0)
    8000533c:	03079693          	slli	a3,a5,0x30
    80005340:	92c1                	srli	a3,a3,0x30
    80005342:	4725                	li	a4,9
    80005344:	02d76863          	bltu	a4,a3,80005374 <fileread+0xba>
    80005348:	0792                	slli	a5,a5,0x4
    8000534a:	0023e717          	auipc	a4,0x23e
    8000534e:	de670713          	addi	a4,a4,-538 # 80243130 <devsw>
    80005352:	97ba                	add	a5,a5,a4
    80005354:	639c                	ld	a5,0(a5)
    80005356:	c38d                	beqz	a5,80005378 <fileread+0xbe>
		r = devsw[f->major].read(1, addr, n);
    80005358:	4505                	li	a0,1
    8000535a:	9782                	jalr	a5
    8000535c:	892a                	mv	s2,a0
    8000535e:	bf75                	j	8000531a <fileread+0x60>
		panic("fileread");
    80005360:	00003517          	auipc	a0,0x3
    80005364:	4e050513          	addi	a0,a0,1248 # 80008840 <syscalls+0x288>
    80005368:	ffffb097          	auipc	ra,0xffffb
    8000536c:	1dc080e7          	jalr	476(ra) # 80000544 <panic>
		return -1;
    80005370:	597d                	li	s2,-1
    80005372:	b765                	j	8000531a <fileread+0x60>
			return -1;
    80005374:	597d                	li	s2,-1
    80005376:	b755                	j	8000531a <fileread+0x60>
    80005378:	597d                	li	s2,-1
    8000537a:	b745                	j	8000531a <fileread+0x60>

000000008000537c <filewrite>:

// Write to file f.
// addr is a user virtual address.
int filewrite(struct file *f, uint64 addr, int n)
{
    8000537c:	715d                	addi	sp,sp,-80
    8000537e:	e486                	sd	ra,72(sp)
    80005380:	e0a2                	sd	s0,64(sp)
    80005382:	fc26                	sd	s1,56(sp)
    80005384:	f84a                	sd	s2,48(sp)
    80005386:	f44e                	sd	s3,40(sp)
    80005388:	f052                	sd	s4,32(sp)
    8000538a:	ec56                	sd	s5,24(sp)
    8000538c:	e85a                	sd	s6,16(sp)
    8000538e:	e45e                	sd	s7,8(sp)
    80005390:	e062                	sd	s8,0(sp)
    80005392:	0880                	addi	s0,sp,80
	int r, ret = 0;

	if (f->writable == 0)
    80005394:	00954783          	lbu	a5,9(a0)
    80005398:	10078663          	beqz	a5,800054a4 <filewrite+0x128>
    8000539c:	892a                	mv	s2,a0
    8000539e:	8aae                	mv	s5,a1
    800053a0:	8a32                	mv	s4,a2
		return -1;

	if (f->type == FD_PIPE)
    800053a2:	411c                	lw	a5,0(a0)
    800053a4:	4705                	li	a4,1
    800053a6:	02e78263          	beq	a5,a4,800053ca <filewrite+0x4e>
	{
		ret = pipewrite(f->pipe, addr, n);
	}
	else if (f->type == FD_DEVICE)
    800053aa:	470d                	li	a4,3
    800053ac:	02e78663          	beq	a5,a4,800053d8 <filewrite+0x5c>
	{
		if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
			return -1;
		ret = devsw[f->major].write(1, addr, n);
	}
	else if (f->type == FD_INODE)
    800053b0:	4709                	li	a4,2
    800053b2:	0ee79163          	bne	a5,a4,80005494 <filewrite+0x118>
		// and 2 blocks of slop for non-aligned writes.
		// this really belongs lower down, since writei()
		// might be writing a device like the console.
		int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
		int i = 0;
		while (i < n)
    800053b6:	0ac05d63          	blez	a2,80005470 <filewrite+0xf4>
		int i = 0;
    800053ba:	4981                	li	s3,0
    800053bc:	6b05                	lui	s6,0x1
    800053be:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800053c2:	6b85                	lui	s7,0x1
    800053c4:	c00b8b9b          	addiw	s7,s7,-1024
    800053c8:	a861                	j	80005460 <filewrite+0xe4>
		ret = pipewrite(f->pipe, addr, n);
    800053ca:	6908                	ld	a0,16(a0)
    800053cc:	00000097          	auipc	ra,0x0
    800053d0:	22e080e7          	jalr	558(ra) # 800055fa <pipewrite>
    800053d4:	8a2a                	mv	s4,a0
    800053d6:	a045                	j	80005476 <filewrite+0xfa>
		if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800053d8:	02451783          	lh	a5,36(a0)
    800053dc:	03079693          	slli	a3,a5,0x30
    800053e0:	92c1                	srli	a3,a3,0x30
    800053e2:	4725                	li	a4,9
    800053e4:	0cd76263          	bltu	a4,a3,800054a8 <filewrite+0x12c>
    800053e8:	0792                	slli	a5,a5,0x4
    800053ea:	0023e717          	auipc	a4,0x23e
    800053ee:	d4670713          	addi	a4,a4,-698 # 80243130 <devsw>
    800053f2:	97ba                	add	a5,a5,a4
    800053f4:	679c                	ld	a5,8(a5)
    800053f6:	cbdd                	beqz	a5,800054ac <filewrite+0x130>
		ret = devsw[f->major].write(1, addr, n);
    800053f8:	4505                	li	a0,1
    800053fa:	9782                	jalr	a5
    800053fc:	8a2a                	mv	s4,a0
    800053fe:	a8a5                	j	80005476 <filewrite+0xfa>
    80005400:	00048c1b          	sext.w	s8,s1
		{
			int n1 = n - i;
			if (n1 > max)
				n1 = max;

			begin_op();
    80005404:	00000097          	auipc	ra,0x0
    80005408:	8b0080e7          	jalr	-1872(ra) # 80004cb4 <begin_op>
			ilock(f->ip);
    8000540c:	01893503          	ld	a0,24(s2)
    80005410:	fffff097          	auipc	ra,0xfffff
    80005414:	ee2080e7          	jalr	-286(ra) # 800042f2 <ilock>
			if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80005418:	8762                	mv	a4,s8
    8000541a:	02092683          	lw	a3,32(s2)
    8000541e:	01598633          	add	a2,s3,s5
    80005422:	4585                	li	a1,1
    80005424:	01893503          	ld	a0,24(s2)
    80005428:	fffff097          	auipc	ra,0xfffff
    8000542c:	276080e7          	jalr	630(ra) # 8000469e <writei>
    80005430:	84aa                	mv	s1,a0
    80005432:	00a05763          	blez	a0,80005440 <filewrite+0xc4>
				f->off += r;
    80005436:	02092783          	lw	a5,32(s2)
    8000543a:	9fa9                	addw	a5,a5,a0
    8000543c:	02f92023          	sw	a5,32(s2)
			iunlock(f->ip);
    80005440:	01893503          	ld	a0,24(s2)
    80005444:	fffff097          	auipc	ra,0xfffff
    80005448:	f70080e7          	jalr	-144(ra) # 800043b4 <iunlock>
			end_op();
    8000544c:	00000097          	auipc	ra,0x0
    80005450:	8e8080e7          	jalr	-1816(ra) # 80004d34 <end_op>

			if (r != n1)
    80005454:	009c1f63          	bne	s8,s1,80005472 <filewrite+0xf6>
			{
				// error from writei
				break;
			}
			i += r;
    80005458:	013489bb          	addw	s3,s1,s3
		while (i < n)
    8000545c:	0149db63          	bge	s3,s4,80005472 <filewrite+0xf6>
			int n1 = n - i;
    80005460:	413a07bb          	subw	a5,s4,s3
			if (n1 > max)
    80005464:	84be                	mv	s1,a5
    80005466:	2781                	sext.w	a5,a5
    80005468:	f8fb5ce3          	bge	s6,a5,80005400 <filewrite+0x84>
    8000546c:	84de                	mv	s1,s7
    8000546e:	bf49                	j	80005400 <filewrite+0x84>
		int i = 0;
    80005470:	4981                	li	s3,0
		}
		ret = (i == n ? n : -1);
    80005472:	013a1f63          	bne	s4,s3,80005490 <filewrite+0x114>
	{
		panic("filewrite");
	}

	return ret;
}
    80005476:	8552                	mv	a0,s4
    80005478:	60a6                	ld	ra,72(sp)
    8000547a:	6406                	ld	s0,64(sp)
    8000547c:	74e2                	ld	s1,56(sp)
    8000547e:	7942                	ld	s2,48(sp)
    80005480:	79a2                	ld	s3,40(sp)
    80005482:	7a02                	ld	s4,32(sp)
    80005484:	6ae2                	ld	s5,24(sp)
    80005486:	6b42                	ld	s6,16(sp)
    80005488:	6ba2                	ld	s7,8(sp)
    8000548a:	6c02                	ld	s8,0(sp)
    8000548c:	6161                	addi	sp,sp,80
    8000548e:	8082                	ret
		ret = (i == n ? n : -1);
    80005490:	5a7d                	li	s4,-1
    80005492:	b7d5                	j	80005476 <filewrite+0xfa>
		panic("filewrite");
    80005494:	00003517          	auipc	a0,0x3
    80005498:	3bc50513          	addi	a0,a0,956 # 80008850 <syscalls+0x298>
    8000549c:	ffffb097          	auipc	ra,0xffffb
    800054a0:	0a8080e7          	jalr	168(ra) # 80000544 <panic>
		return -1;
    800054a4:	5a7d                	li	s4,-1
    800054a6:	bfc1                	j	80005476 <filewrite+0xfa>
			return -1;
    800054a8:	5a7d                	li	s4,-1
    800054aa:	b7f1                	j	80005476 <filewrite+0xfa>
    800054ac:	5a7d                	li	s4,-1
    800054ae:	b7e1                	j	80005476 <filewrite+0xfa>

00000000800054b0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800054b0:	7179                	addi	sp,sp,-48
    800054b2:	f406                	sd	ra,40(sp)
    800054b4:	f022                	sd	s0,32(sp)
    800054b6:	ec26                	sd	s1,24(sp)
    800054b8:	e84a                	sd	s2,16(sp)
    800054ba:	e44e                	sd	s3,8(sp)
    800054bc:	e052                	sd	s4,0(sp)
    800054be:	1800                	addi	s0,sp,48
    800054c0:	84aa                	mv	s1,a0
    800054c2:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800054c4:	0005b023          	sd	zero,0(a1)
    800054c8:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800054cc:	00000097          	auipc	ra,0x0
    800054d0:	bf8080e7          	jalr	-1032(ra) # 800050c4 <filealloc>
    800054d4:	e088                	sd	a0,0(s1)
    800054d6:	c551                	beqz	a0,80005562 <pipealloc+0xb2>
    800054d8:	00000097          	auipc	ra,0x0
    800054dc:	bec080e7          	jalr	-1044(ra) # 800050c4 <filealloc>
    800054e0:	00aa3023          	sd	a0,0(s4)
    800054e4:	c92d                	beqz	a0,80005556 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800054e6:	ffffb097          	auipc	ra,0xffffb
    800054ea:	78e080e7          	jalr	1934(ra) # 80000c74 <kalloc>
    800054ee:	892a                	mv	s2,a0
    800054f0:	c125                	beqz	a0,80005550 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800054f2:	4985                	li	s3,1
    800054f4:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800054f8:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800054fc:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005500:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80005504:	00003597          	auipc	a1,0x3
    80005508:	fc458593          	addi	a1,a1,-60 # 800084c8 <states.2544+0x1b0>
    8000550c:	ffffc097          	auipc	ra,0xffffc
    80005510:	80c080e7          	jalr	-2036(ra) # 80000d18 <initlock>
  (*f0)->type = FD_PIPE;
    80005514:	609c                	ld	a5,0(s1)
    80005516:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000551a:	609c                	ld	a5,0(s1)
    8000551c:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005520:	609c                	ld	a5,0(s1)
    80005522:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80005526:	609c                	ld	a5,0(s1)
    80005528:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000552c:	000a3783          	ld	a5,0(s4)
    80005530:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005534:	000a3783          	ld	a5,0(s4)
    80005538:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000553c:	000a3783          	ld	a5,0(s4)
    80005540:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005544:	000a3783          	ld	a5,0(s4)
    80005548:	0127b823          	sd	s2,16(a5)
  return 0;
    8000554c:	4501                	li	a0,0
    8000554e:	a025                	j	80005576 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005550:	6088                	ld	a0,0(s1)
    80005552:	e501                	bnez	a0,8000555a <pipealloc+0xaa>
    80005554:	a039                	j	80005562 <pipealloc+0xb2>
    80005556:	6088                	ld	a0,0(s1)
    80005558:	c51d                	beqz	a0,80005586 <pipealloc+0xd6>
    fileclose(*f0);
    8000555a:	00000097          	auipc	ra,0x0
    8000555e:	c26080e7          	jalr	-986(ra) # 80005180 <fileclose>
  if(*f1)
    80005562:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005566:	557d                	li	a0,-1
  if(*f1)
    80005568:	c799                	beqz	a5,80005576 <pipealloc+0xc6>
    fileclose(*f1);
    8000556a:	853e                	mv	a0,a5
    8000556c:	00000097          	auipc	ra,0x0
    80005570:	c14080e7          	jalr	-1004(ra) # 80005180 <fileclose>
  return -1;
    80005574:	557d                	li	a0,-1
}
    80005576:	70a2                	ld	ra,40(sp)
    80005578:	7402                	ld	s0,32(sp)
    8000557a:	64e2                	ld	s1,24(sp)
    8000557c:	6942                	ld	s2,16(sp)
    8000557e:	69a2                	ld	s3,8(sp)
    80005580:	6a02                	ld	s4,0(sp)
    80005582:	6145                	addi	sp,sp,48
    80005584:	8082                	ret
  return -1;
    80005586:	557d                	li	a0,-1
    80005588:	b7fd                	j	80005576 <pipealloc+0xc6>

000000008000558a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000558a:	1101                	addi	sp,sp,-32
    8000558c:	ec06                	sd	ra,24(sp)
    8000558e:	e822                	sd	s0,16(sp)
    80005590:	e426                	sd	s1,8(sp)
    80005592:	e04a                	sd	s2,0(sp)
    80005594:	1000                	addi	s0,sp,32
    80005596:	84aa                	mv	s1,a0
    80005598:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000559a:	ffffc097          	auipc	ra,0xffffc
    8000559e:	80e080e7          	jalr	-2034(ra) # 80000da8 <acquire>
  if(writable){
    800055a2:	02090d63          	beqz	s2,800055dc <pipeclose+0x52>
    pi->writeopen = 0;
    800055a6:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800055aa:	21848513          	addi	a0,s1,536
    800055ae:	ffffd097          	auipc	ra,0xffffd
    800055b2:	3b4080e7          	jalr	948(ra) # 80002962 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800055b6:	2204b783          	ld	a5,544(s1)
    800055ba:	eb95                	bnez	a5,800055ee <pipeclose+0x64>
    release(&pi->lock);
    800055bc:	8526                	mv	a0,s1
    800055be:	ffffc097          	auipc	ra,0xffffc
    800055c2:	89e080e7          	jalr	-1890(ra) # 80000e5c <release>
    kfree((char*)pi);
    800055c6:	8526                	mv	a0,s1
    800055c8:	ffffb097          	auipc	ra,0xffffb
    800055cc:	506080e7          	jalr	1286(ra) # 80000ace <kfree>
  } else
    release(&pi->lock);
}
    800055d0:	60e2                	ld	ra,24(sp)
    800055d2:	6442                	ld	s0,16(sp)
    800055d4:	64a2                	ld	s1,8(sp)
    800055d6:	6902                	ld	s2,0(sp)
    800055d8:	6105                	addi	sp,sp,32
    800055da:	8082                	ret
    pi->readopen = 0;
    800055dc:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800055e0:	21c48513          	addi	a0,s1,540
    800055e4:	ffffd097          	auipc	ra,0xffffd
    800055e8:	37e080e7          	jalr	894(ra) # 80002962 <wakeup>
    800055ec:	b7e9                	j	800055b6 <pipeclose+0x2c>
    release(&pi->lock);
    800055ee:	8526                	mv	a0,s1
    800055f0:	ffffc097          	auipc	ra,0xffffc
    800055f4:	86c080e7          	jalr	-1940(ra) # 80000e5c <release>
}
    800055f8:	bfe1                	j	800055d0 <pipeclose+0x46>

00000000800055fa <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800055fa:	7159                	addi	sp,sp,-112
    800055fc:	f486                	sd	ra,104(sp)
    800055fe:	f0a2                	sd	s0,96(sp)
    80005600:	eca6                	sd	s1,88(sp)
    80005602:	e8ca                	sd	s2,80(sp)
    80005604:	e4ce                	sd	s3,72(sp)
    80005606:	e0d2                	sd	s4,64(sp)
    80005608:	fc56                	sd	s5,56(sp)
    8000560a:	f85a                	sd	s6,48(sp)
    8000560c:	f45e                	sd	s7,40(sp)
    8000560e:	f062                	sd	s8,32(sp)
    80005610:	ec66                	sd	s9,24(sp)
    80005612:	1880                	addi	s0,sp,112
    80005614:	84aa                	mv	s1,a0
    80005616:	8aae                	mv	s5,a1
    80005618:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000561a:	ffffc097          	auipc	ra,0xffffc
    8000561e:	74e080e7          	jalr	1870(ra) # 80001d68 <myproc>
    80005622:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005624:	8526                	mv	a0,s1
    80005626:	ffffb097          	auipc	ra,0xffffb
    8000562a:	782080e7          	jalr	1922(ra) # 80000da8 <acquire>
  while(i < n){
    8000562e:	0d405463          	blez	s4,800056f6 <pipewrite+0xfc>
    80005632:	8ba6                	mv	s7,s1
  int i = 0;
    80005634:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005636:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005638:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000563c:	21c48c13          	addi	s8,s1,540
    80005640:	a08d                	j	800056a2 <pipewrite+0xa8>
      release(&pi->lock);
    80005642:	8526                	mv	a0,s1
    80005644:	ffffc097          	auipc	ra,0xffffc
    80005648:	818080e7          	jalr	-2024(ra) # 80000e5c <release>
      return -1;
    8000564c:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000564e:	854a                	mv	a0,s2
    80005650:	70a6                	ld	ra,104(sp)
    80005652:	7406                	ld	s0,96(sp)
    80005654:	64e6                	ld	s1,88(sp)
    80005656:	6946                	ld	s2,80(sp)
    80005658:	69a6                	ld	s3,72(sp)
    8000565a:	6a06                	ld	s4,64(sp)
    8000565c:	7ae2                	ld	s5,56(sp)
    8000565e:	7b42                	ld	s6,48(sp)
    80005660:	7ba2                	ld	s7,40(sp)
    80005662:	7c02                	ld	s8,32(sp)
    80005664:	6ce2                	ld	s9,24(sp)
    80005666:	6165                	addi	sp,sp,112
    80005668:	8082                	ret
      wakeup(&pi->nread);
    8000566a:	8566                	mv	a0,s9
    8000566c:	ffffd097          	auipc	ra,0xffffd
    80005670:	2f6080e7          	jalr	758(ra) # 80002962 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005674:	85de                	mv	a1,s7
    80005676:	8562                	mv	a0,s8
    80005678:	ffffd097          	auipc	ra,0xffffd
    8000567c:	fec080e7          	jalr	-20(ra) # 80002664 <sleep>
    80005680:	a839                	j	8000569e <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005682:	21c4a783          	lw	a5,540(s1)
    80005686:	0017871b          	addiw	a4,a5,1
    8000568a:	20e4ae23          	sw	a4,540(s1)
    8000568e:	1ff7f793          	andi	a5,a5,511
    80005692:	97a6                	add	a5,a5,s1
    80005694:	f9f44703          	lbu	a4,-97(s0)
    80005698:	00e78c23          	sb	a4,24(a5)
      i++;
    8000569c:	2905                	addiw	s2,s2,1
  while(i < n){
    8000569e:	05495063          	bge	s2,s4,800056de <pipewrite+0xe4>
    if(pi->readopen == 0 || killed(pr)){
    800056a2:	2204a783          	lw	a5,544(s1)
    800056a6:	dfd1                	beqz	a5,80005642 <pipewrite+0x48>
    800056a8:	854e                	mv	a0,s3
    800056aa:	ffffd097          	auipc	ra,0xffffd
    800056ae:	566080e7          	jalr	1382(ra) # 80002c10 <killed>
    800056b2:	f941                	bnez	a0,80005642 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800056b4:	2184a783          	lw	a5,536(s1)
    800056b8:	21c4a703          	lw	a4,540(s1)
    800056bc:	2007879b          	addiw	a5,a5,512
    800056c0:	faf705e3          	beq	a4,a5,8000566a <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800056c4:	4685                	li	a3,1
    800056c6:	01590633          	add	a2,s2,s5
    800056ca:	f9f40593          	addi	a1,s0,-97
    800056ce:	0589b503          	ld	a0,88(s3)
    800056d2:	ffffc097          	auipc	ra,0xffffc
    800056d6:	226080e7          	jalr	550(ra) # 800018f8 <copyin>
    800056da:	fb6514e3          	bne	a0,s6,80005682 <pipewrite+0x88>
  wakeup(&pi->nread);
    800056de:	21848513          	addi	a0,s1,536
    800056e2:	ffffd097          	auipc	ra,0xffffd
    800056e6:	280080e7          	jalr	640(ra) # 80002962 <wakeup>
  release(&pi->lock);
    800056ea:	8526                	mv	a0,s1
    800056ec:	ffffb097          	auipc	ra,0xffffb
    800056f0:	770080e7          	jalr	1904(ra) # 80000e5c <release>
  return i;
    800056f4:	bfa9                	j	8000564e <pipewrite+0x54>
  int i = 0;
    800056f6:	4901                	li	s2,0
    800056f8:	b7dd                	j	800056de <pipewrite+0xe4>

00000000800056fa <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800056fa:	715d                	addi	sp,sp,-80
    800056fc:	e486                	sd	ra,72(sp)
    800056fe:	e0a2                	sd	s0,64(sp)
    80005700:	fc26                	sd	s1,56(sp)
    80005702:	f84a                	sd	s2,48(sp)
    80005704:	f44e                	sd	s3,40(sp)
    80005706:	f052                	sd	s4,32(sp)
    80005708:	ec56                	sd	s5,24(sp)
    8000570a:	e85a                	sd	s6,16(sp)
    8000570c:	0880                	addi	s0,sp,80
    8000570e:	84aa                	mv	s1,a0
    80005710:	892e                	mv	s2,a1
    80005712:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005714:	ffffc097          	auipc	ra,0xffffc
    80005718:	654080e7          	jalr	1620(ra) # 80001d68 <myproc>
    8000571c:	8a2a                	mv	s4,a0
  char ch;
  // printf("here1\n");

  acquire(&pi->lock);
    8000571e:	8b26                	mv	s6,s1
    80005720:	8526                	mv	a0,s1
    80005722:	ffffb097          	auipc	ra,0xffffb
    80005726:	686080e7          	jalr	1670(ra) # 80000da8 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000572a:	2184a703          	lw	a4,536(s1)
    8000572e:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005732:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005736:	02f71763          	bne	a4,a5,80005764 <piperead+0x6a>
    8000573a:	2244a783          	lw	a5,548(s1)
    8000573e:	c39d                	beqz	a5,80005764 <piperead+0x6a>
    if(killed(pr)){
    80005740:	8552                	mv	a0,s4
    80005742:	ffffd097          	auipc	ra,0xffffd
    80005746:	4ce080e7          	jalr	1230(ra) # 80002c10 <killed>
    8000574a:	e941                	bnez	a0,800057da <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000574c:	85da                	mv	a1,s6
    8000574e:	854e                	mv	a0,s3
    80005750:	ffffd097          	auipc	ra,0xffffd
    80005754:	f14080e7          	jalr	-236(ra) # 80002664 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005758:	2184a703          	lw	a4,536(s1)
    8000575c:	21c4a783          	lw	a5,540(s1)
    80005760:	fcf70de3          	beq	a4,a5,8000573a <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005764:	09505263          	blez	s5,800057e8 <piperead+0xee>
    80005768:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000576a:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    8000576c:	2184a783          	lw	a5,536(s1)
    80005770:	21c4a703          	lw	a4,540(s1)
    80005774:	02f70d63          	beq	a4,a5,800057ae <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005778:	0017871b          	addiw	a4,a5,1
    8000577c:	20e4ac23          	sw	a4,536(s1)
    80005780:	1ff7f793          	andi	a5,a5,511
    80005784:	97a6                	add	a5,a5,s1
    80005786:	0187c783          	lbu	a5,24(a5)
    8000578a:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000578e:	4685                	li	a3,1
    80005790:	fbf40613          	addi	a2,s0,-65
    80005794:	85ca                	mv	a1,s2
    80005796:	058a3503          	ld	a0,88(s4)
    8000579a:	ffffc097          	auipc	ra,0xffffc
    8000579e:	09e080e7          	jalr	158(ra) # 80001838 <copyout>
    800057a2:	01650663          	beq	a0,s6,800057ae <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800057a6:	2985                	addiw	s3,s3,1
    800057a8:	0905                	addi	s2,s2,1
    800057aa:	fd3a91e3          	bne	s5,s3,8000576c <piperead+0x72>
      break;
  }
  // printf("here2\n");
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800057ae:	21c48513          	addi	a0,s1,540
    800057b2:	ffffd097          	auipc	ra,0xffffd
    800057b6:	1b0080e7          	jalr	432(ra) # 80002962 <wakeup>
  release(&pi->lock);
    800057ba:	8526                	mv	a0,s1
    800057bc:	ffffb097          	auipc	ra,0xffffb
    800057c0:	6a0080e7          	jalr	1696(ra) # 80000e5c <release>
  return i;
}
    800057c4:	854e                	mv	a0,s3
    800057c6:	60a6                	ld	ra,72(sp)
    800057c8:	6406                	ld	s0,64(sp)
    800057ca:	74e2                	ld	s1,56(sp)
    800057cc:	7942                	ld	s2,48(sp)
    800057ce:	79a2                	ld	s3,40(sp)
    800057d0:	7a02                	ld	s4,32(sp)
    800057d2:	6ae2                	ld	s5,24(sp)
    800057d4:	6b42                	ld	s6,16(sp)
    800057d6:	6161                	addi	sp,sp,80
    800057d8:	8082                	ret
      release(&pi->lock);
    800057da:	8526                	mv	a0,s1
    800057dc:	ffffb097          	auipc	ra,0xffffb
    800057e0:	680080e7          	jalr	1664(ra) # 80000e5c <release>
      return -1;
    800057e4:	59fd                	li	s3,-1
    800057e6:	bff9                	j	800057c4 <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800057e8:	4981                	li	s3,0
    800057ea:	b7d1                	j	800057ae <piperead+0xb4>

00000000800057ec <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800057ec:	1141                	addi	sp,sp,-16
    800057ee:	e422                	sd	s0,8(sp)
    800057f0:	0800                	addi	s0,sp,16
    800057f2:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800057f4:	8905                	andi	a0,a0,1
    800057f6:	c111                	beqz	a0,800057fa <flags2perm+0xe>
      perm = PTE_X;
    800057f8:	4521                	li	a0,8
    if(flags & 0x2)
    800057fa:	8b89                	andi	a5,a5,2
    800057fc:	c399                	beqz	a5,80005802 <flags2perm+0x16>
      perm |= PTE_W;
    800057fe:	00456513          	ori	a0,a0,4
    return perm;
}
    80005802:	6422                	ld	s0,8(sp)
    80005804:	0141                	addi	sp,sp,16
    80005806:	8082                	ret

0000000080005808 <exec>:

int
exec(char *path, char **argv)
{
    80005808:	df010113          	addi	sp,sp,-528
    8000580c:	20113423          	sd	ra,520(sp)
    80005810:	20813023          	sd	s0,512(sp)
    80005814:	ffa6                	sd	s1,504(sp)
    80005816:	fbca                	sd	s2,496(sp)
    80005818:	f7ce                	sd	s3,488(sp)
    8000581a:	f3d2                	sd	s4,480(sp)
    8000581c:	efd6                	sd	s5,472(sp)
    8000581e:	ebda                	sd	s6,464(sp)
    80005820:	e7de                	sd	s7,456(sp)
    80005822:	e3e2                	sd	s8,448(sp)
    80005824:	ff66                	sd	s9,440(sp)
    80005826:	fb6a                	sd	s10,432(sp)
    80005828:	f76e                	sd	s11,424(sp)
    8000582a:	0c00                	addi	s0,sp,528
    8000582c:	84aa                	mv	s1,a0
    8000582e:	dea43c23          	sd	a0,-520(s0)
    80005832:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005836:	ffffc097          	auipc	ra,0xffffc
    8000583a:	532080e7          	jalr	1330(ra) # 80001d68 <myproc>
    8000583e:	892a                	mv	s2,a0

  begin_op();
    80005840:	fffff097          	auipc	ra,0xfffff
    80005844:	474080e7          	jalr	1140(ra) # 80004cb4 <begin_op>

  if((ip = namei(path)) == 0){
    80005848:	8526                	mv	a0,s1
    8000584a:	fffff097          	auipc	ra,0xfffff
    8000584e:	24e080e7          	jalr	590(ra) # 80004a98 <namei>
    80005852:	c92d                	beqz	a0,800058c4 <exec+0xbc>
    80005854:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005856:	fffff097          	auipc	ra,0xfffff
    8000585a:	a9c080e7          	jalr	-1380(ra) # 800042f2 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000585e:	04000713          	li	a4,64
    80005862:	4681                	li	a3,0
    80005864:	e5040613          	addi	a2,s0,-432
    80005868:	4581                	li	a1,0
    8000586a:	8526                	mv	a0,s1
    8000586c:	fffff097          	auipc	ra,0xfffff
    80005870:	d3a080e7          	jalr	-710(ra) # 800045a6 <readi>
    80005874:	04000793          	li	a5,64
    80005878:	00f51a63          	bne	a0,a5,8000588c <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    8000587c:	e5042703          	lw	a4,-432(s0)
    80005880:	464c47b7          	lui	a5,0x464c4
    80005884:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005888:	04f70463          	beq	a4,a5,800058d0 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000588c:	8526                	mv	a0,s1
    8000588e:	fffff097          	auipc	ra,0xfffff
    80005892:	cc6080e7          	jalr	-826(ra) # 80004554 <iunlockput>
    end_op();
    80005896:	fffff097          	auipc	ra,0xfffff
    8000589a:	49e080e7          	jalr	1182(ra) # 80004d34 <end_op>
  }
  return -1;
    8000589e:	557d                	li	a0,-1
}
    800058a0:	20813083          	ld	ra,520(sp)
    800058a4:	20013403          	ld	s0,512(sp)
    800058a8:	74fe                	ld	s1,504(sp)
    800058aa:	795e                	ld	s2,496(sp)
    800058ac:	79be                	ld	s3,488(sp)
    800058ae:	7a1e                	ld	s4,480(sp)
    800058b0:	6afe                	ld	s5,472(sp)
    800058b2:	6b5e                	ld	s6,464(sp)
    800058b4:	6bbe                	ld	s7,456(sp)
    800058b6:	6c1e                	ld	s8,448(sp)
    800058b8:	7cfa                	ld	s9,440(sp)
    800058ba:	7d5a                	ld	s10,432(sp)
    800058bc:	7dba                	ld	s11,424(sp)
    800058be:	21010113          	addi	sp,sp,528
    800058c2:	8082                	ret
    end_op();
    800058c4:	fffff097          	auipc	ra,0xfffff
    800058c8:	470080e7          	jalr	1136(ra) # 80004d34 <end_op>
    return -1;
    800058cc:	557d                	li	a0,-1
    800058ce:	bfc9                	j	800058a0 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    800058d0:	854a                	mv	a0,s2
    800058d2:	ffffc097          	auipc	ra,0xffffc
    800058d6:	55c080e7          	jalr	1372(ra) # 80001e2e <proc_pagetable>
    800058da:	8baa                	mv	s7,a0
    800058dc:	d945                	beqz	a0,8000588c <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800058de:	e7042983          	lw	s3,-400(s0)
    800058e2:	e8845783          	lhu	a5,-376(s0)
    800058e6:	c7ad                	beqz	a5,80005950 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800058e8:	4a01                	li	s4,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800058ea:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    800058ec:	6c85                	lui	s9,0x1
    800058ee:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800058f2:	def43823          	sd	a5,-528(s0)
    800058f6:	ac0d                	j	80005b28 <exec+0x320>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800058f8:	00003517          	auipc	a0,0x3
    800058fc:	f6850513          	addi	a0,a0,-152 # 80008860 <syscalls+0x2a8>
    80005900:	ffffb097          	auipc	ra,0xffffb
    80005904:	c44080e7          	jalr	-956(ra) # 80000544 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005908:	8756                	mv	a4,s5
    8000590a:	012d86bb          	addw	a3,s11,s2
    8000590e:	4581                	li	a1,0
    80005910:	8526                	mv	a0,s1
    80005912:	fffff097          	auipc	ra,0xfffff
    80005916:	c94080e7          	jalr	-876(ra) # 800045a6 <readi>
    8000591a:	2501                	sext.w	a0,a0
    8000591c:	1aaa9a63          	bne	s5,a0,80005ad0 <exec+0x2c8>
  for(i = 0; i < sz; i += PGSIZE){
    80005920:	6785                	lui	a5,0x1
    80005922:	0127893b          	addw	s2,a5,s2
    80005926:	77fd                	lui	a5,0xfffff
    80005928:	01478a3b          	addw	s4,a5,s4
    8000592c:	1f897563          	bgeu	s2,s8,80005b16 <exec+0x30e>
    pa = walkaddr(pagetable, va + i);
    80005930:	02091593          	slli	a1,s2,0x20
    80005934:	9181                	srli	a1,a1,0x20
    80005936:	95ea                	add	a1,a1,s10
    80005938:	855e                	mv	a0,s7
    8000593a:	ffffc097          	auipc	ra,0xffffc
    8000593e:	8fc080e7          	jalr	-1796(ra) # 80001236 <walkaddr>
    80005942:	862a                	mv	a2,a0
    if(pa == 0)
    80005944:	d955                	beqz	a0,800058f8 <exec+0xf0>
      n = PGSIZE;
    80005946:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80005948:	fd9a70e3          	bgeu	s4,s9,80005908 <exec+0x100>
      n = sz - i;
    8000594c:	8ad2                	mv	s5,s4
    8000594e:	bf6d                	j	80005908 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005950:	4a01                	li	s4,0
  iunlockput(ip);
    80005952:	8526                	mv	a0,s1
    80005954:	fffff097          	auipc	ra,0xfffff
    80005958:	c00080e7          	jalr	-1024(ra) # 80004554 <iunlockput>
  end_op();
    8000595c:	fffff097          	auipc	ra,0xfffff
    80005960:	3d8080e7          	jalr	984(ra) # 80004d34 <end_op>
  p = myproc();
    80005964:	ffffc097          	auipc	ra,0xffffc
    80005968:	404080e7          	jalr	1028(ra) # 80001d68 <myproc>
    8000596c:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    8000596e:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    80005972:	6785                	lui	a5,0x1
    80005974:	17fd                	addi	a5,a5,-1
    80005976:	9a3e                	add	s4,s4,a5
    80005978:	757d                	lui	a0,0xfffff
    8000597a:	00aa77b3          	and	a5,s4,a0
    8000597e:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005982:	4691                	li	a3,4
    80005984:	6609                	lui	a2,0x2
    80005986:	963e                	add	a2,a2,a5
    80005988:	85be                	mv	a1,a5
    8000598a:	855e                	mv	a0,s7
    8000598c:	ffffc097          	auipc	ra,0xffffc
    80005990:	c5e080e7          	jalr	-930(ra) # 800015ea <uvmalloc>
    80005994:	8b2a                	mv	s6,a0
  ip = 0;
    80005996:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005998:	12050c63          	beqz	a0,80005ad0 <exec+0x2c8>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000599c:	75f9                	lui	a1,0xffffe
    8000599e:	95aa                	add	a1,a1,a0
    800059a0:	855e                	mv	a0,s7
    800059a2:	ffffc097          	auipc	ra,0xffffc
    800059a6:	e64080e7          	jalr	-412(ra) # 80001806 <uvmclear>
  stackbase = sp - PGSIZE;
    800059aa:	7c7d                	lui	s8,0xfffff
    800059ac:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    800059ae:	e0043783          	ld	a5,-512(s0)
    800059b2:	6388                	ld	a0,0(a5)
    800059b4:	c535                	beqz	a0,80005a20 <exec+0x218>
    800059b6:	e9040993          	addi	s3,s0,-368
    800059ba:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800059be:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    800059c0:	ffffb097          	auipc	ra,0xffffb
    800059c4:	668080e7          	jalr	1640(ra) # 80001028 <strlen>
    800059c8:	2505                	addiw	a0,a0,1
    800059ca:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800059ce:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800059d2:	13896663          	bltu	s2,s8,80005afe <exec+0x2f6>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800059d6:	e0043d83          	ld	s11,-512(s0)
    800059da:	000dba03          	ld	s4,0(s11)
    800059de:	8552                	mv	a0,s4
    800059e0:	ffffb097          	auipc	ra,0xffffb
    800059e4:	648080e7          	jalr	1608(ra) # 80001028 <strlen>
    800059e8:	0015069b          	addiw	a3,a0,1
    800059ec:	8652                	mv	a2,s4
    800059ee:	85ca                	mv	a1,s2
    800059f0:	855e                	mv	a0,s7
    800059f2:	ffffc097          	auipc	ra,0xffffc
    800059f6:	e46080e7          	jalr	-442(ra) # 80001838 <copyout>
    800059fa:	10054663          	bltz	a0,80005b06 <exec+0x2fe>
    ustack[argc] = sp;
    800059fe:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005a02:	0485                	addi	s1,s1,1
    80005a04:	008d8793          	addi	a5,s11,8
    80005a08:	e0f43023          	sd	a5,-512(s0)
    80005a0c:	008db503          	ld	a0,8(s11)
    80005a10:	c911                	beqz	a0,80005a24 <exec+0x21c>
    if(argc >= MAXARG)
    80005a12:	09a1                	addi	s3,s3,8
    80005a14:	fb3c96e3          	bne	s9,s3,800059c0 <exec+0x1b8>
  sz = sz1;
    80005a18:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005a1c:	4481                	li	s1,0
    80005a1e:	a84d                	j	80005ad0 <exec+0x2c8>
  sp = sz;
    80005a20:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005a22:	4481                	li	s1,0
  ustack[argc] = 0;
    80005a24:	00349793          	slli	a5,s1,0x3
    80005a28:	f9040713          	addi	a4,s0,-112
    80005a2c:	97ba                	add	a5,a5,a4
    80005a2e:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    80005a32:	00148693          	addi	a3,s1,1
    80005a36:	068e                	slli	a3,a3,0x3
    80005a38:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005a3c:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005a40:	01897663          	bgeu	s2,s8,80005a4c <exec+0x244>
  sz = sz1;
    80005a44:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005a48:	4481                	li	s1,0
    80005a4a:	a059                	j	80005ad0 <exec+0x2c8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005a4c:	e9040613          	addi	a2,s0,-368
    80005a50:	85ca                	mv	a1,s2
    80005a52:	855e                	mv	a0,s7
    80005a54:	ffffc097          	auipc	ra,0xffffc
    80005a58:	de4080e7          	jalr	-540(ra) # 80001838 <copyout>
    80005a5c:	0a054963          	bltz	a0,80005b0e <exec+0x306>
  p->trapframe->a1 = sp;
    80005a60:	060ab783          	ld	a5,96(s5)
    80005a64:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005a68:	df843783          	ld	a5,-520(s0)
    80005a6c:	0007c703          	lbu	a4,0(a5)
    80005a70:	cf11                	beqz	a4,80005a8c <exec+0x284>
    80005a72:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005a74:	02f00693          	li	a3,47
    80005a78:	a039                	j	80005a86 <exec+0x27e>
      last = s+1;
    80005a7a:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80005a7e:	0785                	addi	a5,a5,1
    80005a80:	fff7c703          	lbu	a4,-1(a5)
    80005a84:	c701                	beqz	a4,80005a8c <exec+0x284>
    if(*s == '/')
    80005a86:	fed71ce3          	bne	a4,a3,80005a7e <exec+0x276>
    80005a8a:	bfc5                	j	80005a7a <exec+0x272>
  safestrcpy(p->name, last, sizeof(p->name));
    80005a8c:	4641                	li	a2,16
    80005a8e:	df843583          	ld	a1,-520(s0)
    80005a92:	160a8513          	addi	a0,s5,352
    80005a96:	ffffb097          	auipc	ra,0xffffb
    80005a9a:	560080e7          	jalr	1376(ra) # 80000ff6 <safestrcpy>
  oldpagetable = p->pagetable;
    80005a9e:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    80005aa2:	057abc23          	sd	s7,88(s5)
  p->sz = sz;
    80005aa6:	056ab823          	sd	s6,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005aaa:	060ab783          	ld	a5,96(s5)
    80005aae:	e6843703          	ld	a4,-408(s0)
    80005ab2:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005ab4:	060ab783          	ld	a5,96(s5)
    80005ab8:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005abc:	85ea                	mv	a1,s10
    80005abe:	ffffc097          	auipc	ra,0xffffc
    80005ac2:	40c080e7          	jalr	1036(ra) # 80001eca <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005ac6:	0004851b          	sext.w	a0,s1
    80005aca:	bbd9                	j	800058a0 <exec+0x98>
    80005acc:	e1443423          	sd	s4,-504(s0)
    proc_freepagetable(pagetable, sz);
    80005ad0:	e0843583          	ld	a1,-504(s0)
    80005ad4:	855e                	mv	a0,s7
    80005ad6:	ffffc097          	auipc	ra,0xffffc
    80005ada:	3f4080e7          	jalr	1012(ra) # 80001eca <proc_freepagetable>
  if(ip){
    80005ade:	da0497e3          	bnez	s1,8000588c <exec+0x84>
  return -1;
    80005ae2:	557d                	li	a0,-1
    80005ae4:	bb75                	j	800058a0 <exec+0x98>
    80005ae6:	e1443423          	sd	s4,-504(s0)
    80005aea:	b7dd                	j	80005ad0 <exec+0x2c8>
    80005aec:	e1443423          	sd	s4,-504(s0)
    80005af0:	b7c5                	j	80005ad0 <exec+0x2c8>
    80005af2:	e1443423          	sd	s4,-504(s0)
    80005af6:	bfe9                	j	80005ad0 <exec+0x2c8>
    80005af8:	e1443423          	sd	s4,-504(s0)
    80005afc:	bfd1                	j	80005ad0 <exec+0x2c8>
  sz = sz1;
    80005afe:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005b02:	4481                	li	s1,0
    80005b04:	b7f1                	j	80005ad0 <exec+0x2c8>
  sz = sz1;
    80005b06:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005b0a:	4481                	li	s1,0
    80005b0c:	b7d1                	j	80005ad0 <exec+0x2c8>
  sz = sz1;
    80005b0e:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005b12:	4481                	li	s1,0
    80005b14:	bf75                	j	80005ad0 <exec+0x2c8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005b16:	e0843a03          	ld	s4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005b1a:	2b05                	addiw	s6,s6,1
    80005b1c:	0389899b          	addiw	s3,s3,56
    80005b20:	e8845783          	lhu	a5,-376(s0)
    80005b24:	e2fb57e3          	bge	s6,a5,80005952 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005b28:	2981                	sext.w	s3,s3
    80005b2a:	03800713          	li	a4,56
    80005b2e:	86ce                	mv	a3,s3
    80005b30:	e1840613          	addi	a2,s0,-488
    80005b34:	4581                	li	a1,0
    80005b36:	8526                	mv	a0,s1
    80005b38:	fffff097          	auipc	ra,0xfffff
    80005b3c:	a6e080e7          	jalr	-1426(ra) # 800045a6 <readi>
    80005b40:	03800793          	li	a5,56
    80005b44:	f8f514e3          	bne	a0,a5,80005acc <exec+0x2c4>
    if(ph.type != ELF_PROG_LOAD)
    80005b48:	e1842783          	lw	a5,-488(s0)
    80005b4c:	4705                	li	a4,1
    80005b4e:	fce796e3          	bne	a5,a4,80005b1a <exec+0x312>
    if(ph.memsz < ph.filesz)
    80005b52:	e4043903          	ld	s2,-448(s0)
    80005b56:	e3843783          	ld	a5,-456(s0)
    80005b5a:	f8f966e3          	bltu	s2,a5,80005ae6 <exec+0x2de>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005b5e:	e2843783          	ld	a5,-472(s0)
    80005b62:	993e                	add	s2,s2,a5
    80005b64:	f8f964e3          	bltu	s2,a5,80005aec <exec+0x2e4>
    if(ph.vaddr % PGSIZE != 0)
    80005b68:	df043703          	ld	a4,-528(s0)
    80005b6c:	8ff9                	and	a5,a5,a4
    80005b6e:	f3d1                	bnez	a5,80005af2 <exec+0x2ea>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005b70:	e1c42503          	lw	a0,-484(s0)
    80005b74:	00000097          	auipc	ra,0x0
    80005b78:	c78080e7          	jalr	-904(ra) # 800057ec <flags2perm>
    80005b7c:	86aa                	mv	a3,a0
    80005b7e:	864a                	mv	a2,s2
    80005b80:	85d2                	mv	a1,s4
    80005b82:	855e                	mv	a0,s7
    80005b84:	ffffc097          	auipc	ra,0xffffc
    80005b88:	a66080e7          	jalr	-1434(ra) # 800015ea <uvmalloc>
    80005b8c:	e0a43423          	sd	a0,-504(s0)
    80005b90:	d525                	beqz	a0,80005af8 <exec+0x2f0>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005b92:	e2843d03          	ld	s10,-472(s0)
    80005b96:	e2042d83          	lw	s11,-480(s0)
    80005b9a:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005b9e:	f60c0ce3          	beqz	s8,80005b16 <exec+0x30e>
    80005ba2:	8a62                	mv	s4,s8
    80005ba4:	4901                	li	s2,0
    80005ba6:	b369                	j	80005930 <exec+0x128>

0000000080005ba8 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005ba8:	7179                	addi	sp,sp,-48
    80005baa:	f406                	sd	ra,40(sp)
    80005bac:	f022                	sd	s0,32(sp)
    80005bae:	ec26                	sd	s1,24(sp)
    80005bb0:	e84a                	sd	s2,16(sp)
    80005bb2:	1800                	addi	s0,sp,48
    80005bb4:	892e                	mv	s2,a1
    80005bb6:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005bb8:	fdc40593          	addi	a1,s0,-36
    80005bbc:	ffffe097          	auipc	ra,0xffffe
    80005bc0:	8a8080e7          	jalr	-1880(ra) # 80003464 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005bc4:	fdc42703          	lw	a4,-36(s0)
    80005bc8:	47bd                	li	a5,15
    80005bca:	02e7eb63          	bltu	a5,a4,80005c00 <argfd+0x58>
    80005bce:	ffffc097          	auipc	ra,0xffffc
    80005bd2:	19a080e7          	jalr	410(ra) # 80001d68 <myproc>
    80005bd6:	fdc42703          	lw	a4,-36(s0)
    80005bda:	01a70793          	addi	a5,a4,26
    80005bde:	078e                	slli	a5,a5,0x3
    80005be0:	953e                	add	a0,a0,a5
    80005be2:	651c                	ld	a5,8(a0)
    80005be4:	c385                	beqz	a5,80005c04 <argfd+0x5c>
    return -1;
  if(pfd)
    80005be6:	00090463          	beqz	s2,80005bee <argfd+0x46>
    *pfd = fd;
    80005bea:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005bee:	4501                	li	a0,0
  if(pf)
    80005bf0:	c091                	beqz	s1,80005bf4 <argfd+0x4c>
    *pf = f;
    80005bf2:	e09c                	sd	a5,0(s1)
}
    80005bf4:	70a2                	ld	ra,40(sp)
    80005bf6:	7402                	ld	s0,32(sp)
    80005bf8:	64e2                	ld	s1,24(sp)
    80005bfa:	6942                	ld	s2,16(sp)
    80005bfc:	6145                	addi	sp,sp,48
    80005bfe:	8082                	ret
    return -1;
    80005c00:	557d                	li	a0,-1
    80005c02:	bfcd                	j	80005bf4 <argfd+0x4c>
    80005c04:	557d                	li	a0,-1
    80005c06:	b7fd                	j	80005bf4 <argfd+0x4c>

0000000080005c08 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005c08:	1101                	addi	sp,sp,-32
    80005c0a:	ec06                	sd	ra,24(sp)
    80005c0c:	e822                	sd	s0,16(sp)
    80005c0e:	e426                	sd	s1,8(sp)
    80005c10:	1000                	addi	s0,sp,32
    80005c12:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005c14:	ffffc097          	auipc	ra,0xffffc
    80005c18:	154080e7          	jalr	340(ra) # 80001d68 <myproc>
    80005c1c:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005c1e:	0d850793          	addi	a5,a0,216 # fffffffffffff0d8 <end+0xffffffff7fdbae10>
    80005c22:	4501                	li	a0,0
    80005c24:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005c26:	6398                	ld	a4,0(a5)
    80005c28:	cb19                	beqz	a4,80005c3e <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005c2a:	2505                	addiw	a0,a0,1
    80005c2c:	07a1                	addi	a5,a5,8
    80005c2e:	fed51ce3          	bne	a0,a3,80005c26 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005c32:	557d                	li	a0,-1
}
    80005c34:	60e2                	ld	ra,24(sp)
    80005c36:	6442                	ld	s0,16(sp)
    80005c38:	64a2                	ld	s1,8(sp)
    80005c3a:	6105                	addi	sp,sp,32
    80005c3c:	8082                	ret
      p->ofile[fd] = f;
    80005c3e:	01a50793          	addi	a5,a0,26
    80005c42:	078e                	slli	a5,a5,0x3
    80005c44:	963e                	add	a2,a2,a5
    80005c46:	e604                	sd	s1,8(a2)
      return fd;
    80005c48:	b7f5                	j	80005c34 <fdalloc+0x2c>

0000000080005c4a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005c4a:	715d                	addi	sp,sp,-80
    80005c4c:	e486                	sd	ra,72(sp)
    80005c4e:	e0a2                	sd	s0,64(sp)
    80005c50:	fc26                	sd	s1,56(sp)
    80005c52:	f84a                	sd	s2,48(sp)
    80005c54:	f44e                	sd	s3,40(sp)
    80005c56:	f052                	sd	s4,32(sp)
    80005c58:	ec56                	sd	s5,24(sp)
    80005c5a:	e85a                	sd	s6,16(sp)
    80005c5c:	0880                	addi	s0,sp,80
    80005c5e:	8b2e                	mv	s6,a1
    80005c60:	89b2                	mv	s3,a2
    80005c62:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005c64:	fb040593          	addi	a1,s0,-80
    80005c68:	fffff097          	auipc	ra,0xfffff
    80005c6c:	e4e080e7          	jalr	-434(ra) # 80004ab6 <nameiparent>
    80005c70:	84aa                	mv	s1,a0
    80005c72:	16050063          	beqz	a0,80005dd2 <create+0x188>
    return 0;

  ilock(dp);
    80005c76:	ffffe097          	auipc	ra,0xffffe
    80005c7a:	67c080e7          	jalr	1660(ra) # 800042f2 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005c7e:	4601                	li	a2,0
    80005c80:	fb040593          	addi	a1,s0,-80
    80005c84:	8526                	mv	a0,s1
    80005c86:	fffff097          	auipc	ra,0xfffff
    80005c8a:	b50080e7          	jalr	-1200(ra) # 800047d6 <dirlookup>
    80005c8e:	8aaa                	mv	s5,a0
    80005c90:	c931                	beqz	a0,80005ce4 <create+0x9a>
    iunlockput(dp);
    80005c92:	8526                	mv	a0,s1
    80005c94:	fffff097          	auipc	ra,0xfffff
    80005c98:	8c0080e7          	jalr	-1856(ra) # 80004554 <iunlockput>
    ilock(ip);
    80005c9c:	8556                	mv	a0,s5
    80005c9e:	ffffe097          	auipc	ra,0xffffe
    80005ca2:	654080e7          	jalr	1620(ra) # 800042f2 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005ca6:	000b059b          	sext.w	a1,s6
    80005caa:	4789                	li	a5,2
    80005cac:	02f59563          	bne	a1,a5,80005cd6 <create+0x8c>
    80005cb0:	044ad783          	lhu	a5,68(s5)
    80005cb4:	37f9                	addiw	a5,a5,-2
    80005cb6:	17c2                	slli	a5,a5,0x30
    80005cb8:	93c1                	srli	a5,a5,0x30
    80005cba:	4705                	li	a4,1
    80005cbc:	00f76d63          	bltu	a4,a5,80005cd6 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005cc0:	8556                	mv	a0,s5
    80005cc2:	60a6                	ld	ra,72(sp)
    80005cc4:	6406                	ld	s0,64(sp)
    80005cc6:	74e2                	ld	s1,56(sp)
    80005cc8:	7942                	ld	s2,48(sp)
    80005cca:	79a2                	ld	s3,40(sp)
    80005ccc:	7a02                	ld	s4,32(sp)
    80005cce:	6ae2                	ld	s5,24(sp)
    80005cd0:	6b42                	ld	s6,16(sp)
    80005cd2:	6161                	addi	sp,sp,80
    80005cd4:	8082                	ret
    iunlockput(ip);
    80005cd6:	8556                	mv	a0,s5
    80005cd8:	fffff097          	auipc	ra,0xfffff
    80005cdc:	87c080e7          	jalr	-1924(ra) # 80004554 <iunlockput>
    return 0;
    80005ce0:	4a81                	li	s5,0
    80005ce2:	bff9                	j	80005cc0 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005ce4:	85da                	mv	a1,s6
    80005ce6:	4088                	lw	a0,0(s1)
    80005ce8:	ffffe097          	auipc	ra,0xffffe
    80005cec:	46e080e7          	jalr	1134(ra) # 80004156 <ialloc>
    80005cf0:	8a2a                	mv	s4,a0
    80005cf2:	c921                	beqz	a0,80005d42 <create+0xf8>
  ilock(ip);
    80005cf4:	ffffe097          	auipc	ra,0xffffe
    80005cf8:	5fe080e7          	jalr	1534(ra) # 800042f2 <ilock>
  ip->major = major;
    80005cfc:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005d00:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005d04:	4785                	li	a5,1
    80005d06:	04fa1523          	sh	a5,74(s4)
  iupdate(ip);
    80005d0a:	8552                	mv	a0,s4
    80005d0c:	ffffe097          	auipc	ra,0xffffe
    80005d10:	51c080e7          	jalr	1308(ra) # 80004228 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005d14:	000b059b          	sext.w	a1,s6
    80005d18:	4785                	li	a5,1
    80005d1a:	02f58b63          	beq	a1,a5,80005d50 <create+0x106>
  if(dirlink(dp, name, ip->inum) < 0)
    80005d1e:	004a2603          	lw	a2,4(s4)
    80005d22:	fb040593          	addi	a1,s0,-80
    80005d26:	8526                	mv	a0,s1
    80005d28:	fffff097          	auipc	ra,0xfffff
    80005d2c:	cbe080e7          	jalr	-834(ra) # 800049e6 <dirlink>
    80005d30:	06054f63          	bltz	a0,80005dae <create+0x164>
  iunlockput(dp);
    80005d34:	8526                	mv	a0,s1
    80005d36:	fffff097          	auipc	ra,0xfffff
    80005d3a:	81e080e7          	jalr	-2018(ra) # 80004554 <iunlockput>
  return ip;
    80005d3e:	8ad2                	mv	s5,s4
    80005d40:	b741                	j	80005cc0 <create+0x76>
    iunlockput(dp);
    80005d42:	8526                	mv	a0,s1
    80005d44:	fffff097          	auipc	ra,0xfffff
    80005d48:	810080e7          	jalr	-2032(ra) # 80004554 <iunlockput>
    return 0;
    80005d4c:	8ad2                	mv	s5,s4
    80005d4e:	bf8d                	j	80005cc0 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005d50:	004a2603          	lw	a2,4(s4)
    80005d54:	00003597          	auipc	a1,0x3
    80005d58:	b2c58593          	addi	a1,a1,-1236 # 80008880 <syscalls+0x2c8>
    80005d5c:	8552                	mv	a0,s4
    80005d5e:	fffff097          	auipc	ra,0xfffff
    80005d62:	c88080e7          	jalr	-888(ra) # 800049e6 <dirlink>
    80005d66:	04054463          	bltz	a0,80005dae <create+0x164>
    80005d6a:	40d0                	lw	a2,4(s1)
    80005d6c:	00003597          	auipc	a1,0x3
    80005d70:	b1c58593          	addi	a1,a1,-1252 # 80008888 <syscalls+0x2d0>
    80005d74:	8552                	mv	a0,s4
    80005d76:	fffff097          	auipc	ra,0xfffff
    80005d7a:	c70080e7          	jalr	-912(ra) # 800049e6 <dirlink>
    80005d7e:	02054863          	bltz	a0,80005dae <create+0x164>
  if(dirlink(dp, name, ip->inum) < 0)
    80005d82:	004a2603          	lw	a2,4(s4)
    80005d86:	fb040593          	addi	a1,s0,-80
    80005d8a:	8526                	mv	a0,s1
    80005d8c:	fffff097          	auipc	ra,0xfffff
    80005d90:	c5a080e7          	jalr	-934(ra) # 800049e6 <dirlink>
    80005d94:	00054d63          	bltz	a0,80005dae <create+0x164>
    dp->nlink++;  // for ".."
    80005d98:	04a4d783          	lhu	a5,74(s1)
    80005d9c:	2785                	addiw	a5,a5,1
    80005d9e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005da2:	8526                	mv	a0,s1
    80005da4:	ffffe097          	auipc	ra,0xffffe
    80005da8:	484080e7          	jalr	1156(ra) # 80004228 <iupdate>
    80005dac:	b761                	j	80005d34 <create+0xea>
  ip->nlink = 0;
    80005dae:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005db2:	8552                	mv	a0,s4
    80005db4:	ffffe097          	auipc	ra,0xffffe
    80005db8:	474080e7          	jalr	1140(ra) # 80004228 <iupdate>
  iunlockput(ip);
    80005dbc:	8552                	mv	a0,s4
    80005dbe:	ffffe097          	auipc	ra,0xffffe
    80005dc2:	796080e7          	jalr	1942(ra) # 80004554 <iunlockput>
  iunlockput(dp);
    80005dc6:	8526                	mv	a0,s1
    80005dc8:	ffffe097          	auipc	ra,0xffffe
    80005dcc:	78c080e7          	jalr	1932(ra) # 80004554 <iunlockput>
  return 0;
    80005dd0:	bdc5                	j	80005cc0 <create+0x76>
    return 0;
    80005dd2:	8aaa                	mv	s5,a0
    80005dd4:	b5f5                	j	80005cc0 <create+0x76>

0000000080005dd6 <sys_dup>:
{
    80005dd6:	7179                	addi	sp,sp,-48
    80005dd8:	f406                	sd	ra,40(sp)
    80005dda:	f022                	sd	s0,32(sp)
    80005ddc:	ec26                	sd	s1,24(sp)
    80005dde:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005de0:	fd840613          	addi	a2,s0,-40
    80005de4:	4581                	li	a1,0
    80005de6:	4501                	li	a0,0
    80005de8:	00000097          	auipc	ra,0x0
    80005dec:	dc0080e7          	jalr	-576(ra) # 80005ba8 <argfd>
    return -1;
    80005df0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005df2:	02054363          	bltz	a0,80005e18 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005df6:	fd843503          	ld	a0,-40(s0)
    80005dfa:	00000097          	auipc	ra,0x0
    80005dfe:	e0e080e7          	jalr	-498(ra) # 80005c08 <fdalloc>
    80005e02:	84aa                	mv	s1,a0
    return -1;
    80005e04:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005e06:	00054963          	bltz	a0,80005e18 <sys_dup+0x42>
  filedup(f);
    80005e0a:	fd843503          	ld	a0,-40(s0)
    80005e0e:	fffff097          	auipc	ra,0xfffff
    80005e12:	320080e7          	jalr	800(ra) # 8000512e <filedup>
  return fd;
    80005e16:	87a6                	mv	a5,s1
}
    80005e18:	853e                	mv	a0,a5
    80005e1a:	70a2                	ld	ra,40(sp)
    80005e1c:	7402                	ld	s0,32(sp)
    80005e1e:	64e2                	ld	s1,24(sp)
    80005e20:	6145                	addi	sp,sp,48
    80005e22:	8082                	ret

0000000080005e24 <sys_read>:
{
    80005e24:	7179                	addi	sp,sp,-48
    80005e26:	f406                	sd	ra,40(sp)
    80005e28:	f022                	sd	s0,32(sp)
    80005e2a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005e2c:	fd840593          	addi	a1,s0,-40
    80005e30:	4505                	li	a0,1
    80005e32:	ffffd097          	auipc	ra,0xffffd
    80005e36:	652080e7          	jalr	1618(ra) # 80003484 <argaddr>
  argint(2, &n);
    80005e3a:	fe440593          	addi	a1,s0,-28
    80005e3e:	4509                	li	a0,2
    80005e40:	ffffd097          	auipc	ra,0xffffd
    80005e44:	624080e7          	jalr	1572(ra) # 80003464 <argint>
  if(argfd(0, 0, &f) < 0)
    80005e48:	fe840613          	addi	a2,s0,-24
    80005e4c:	4581                	li	a1,0
    80005e4e:	4501                	li	a0,0
    80005e50:	00000097          	auipc	ra,0x0
    80005e54:	d58080e7          	jalr	-680(ra) # 80005ba8 <argfd>
    80005e58:	87aa                	mv	a5,a0
    return -1;
    80005e5a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005e5c:	0007cc63          	bltz	a5,80005e74 <sys_read+0x50>
  return fileread(f, p, n);
    80005e60:	fe442603          	lw	a2,-28(s0)
    80005e64:	fd843583          	ld	a1,-40(s0)
    80005e68:	fe843503          	ld	a0,-24(s0)
    80005e6c:	fffff097          	auipc	ra,0xfffff
    80005e70:	44e080e7          	jalr	1102(ra) # 800052ba <fileread>
}
    80005e74:	70a2                	ld	ra,40(sp)
    80005e76:	7402                	ld	s0,32(sp)
    80005e78:	6145                	addi	sp,sp,48
    80005e7a:	8082                	ret

0000000080005e7c <sys_write>:
{
    80005e7c:	7179                	addi	sp,sp,-48
    80005e7e:	f406                	sd	ra,40(sp)
    80005e80:	f022                	sd	s0,32(sp)
    80005e82:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005e84:	fd840593          	addi	a1,s0,-40
    80005e88:	4505                	li	a0,1
    80005e8a:	ffffd097          	auipc	ra,0xffffd
    80005e8e:	5fa080e7          	jalr	1530(ra) # 80003484 <argaddr>
  argint(2, &n);
    80005e92:	fe440593          	addi	a1,s0,-28
    80005e96:	4509                	li	a0,2
    80005e98:	ffffd097          	auipc	ra,0xffffd
    80005e9c:	5cc080e7          	jalr	1484(ra) # 80003464 <argint>
  if(argfd(0, 0, &f) < 0)
    80005ea0:	fe840613          	addi	a2,s0,-24
    80005ea4:	4581                	li	a1,0
    80005ea6:	4501                	li	a0,0
    80005ea8:	00000097          	auipc	ra,0x0
    80005eac:	d00080e7          	jalr	-768(ra) # 80005ba8 <argfd>
    80005eb0:	87aa                	mv	a5,a0
    return -1;
    80005eb2:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005eb4:	0007cc63          	bltz	a5,80005ecc <sys_write+0x50>
  return filewrite(f, p, n);
    80005eb8:	fe442603          	lw	a2,-28(s0)
    80005ebc:	fd843583          	ld	a1,-40(s0)
    80005ec0:	fe843503          	ld	a0,-24(s0)
    80005ec4:	fffff097          	auipc	ra,0xfffff
    80005ec8:	4b8080e7          	jalr	1208(ra) # 8000537c <filewrite>
}
    80005ecc:	70a2                	ld	ra,40(sp)
    80005ece:	7402                	ld	s0,32(sp)
    80005ed0:	6145                	addi	sp,sp,48
    80005ed2:	8082                	ret

0000000080005ed4 <sys_close>:
{
    80005ed4:	1101                	addi	sp,sp,-32
    80005ed6:	ec06                	sd	ra,24(sp)
    80005ed8:	e822                	sd	s0,16(sp)
    80005eda:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005edc:	fe040613          	addi	a2,s0,-32
    80005ee0:	fec40593          	addi	a1,s0,-20
    80005ee4:	4501                	li	a0,0
    80005ee6:	00000097          	auipc	ra,0x0
    80005eea:	cc2080e7          	jalr	-830(ra) # 80005ba8 <argfd>
    return -1;
    80005eee:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005ef0:	02054463          	bltz	a0,80005f18 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005ef4:	ffffc097          	auipc	ra,0xffffc
    80005ef8:	e74080e7          	jalr	-396(ra) # 80001d68 <myproc>
    80005efc:	fec42783          	lw	a5,-20(s0)
    80005f00:	07e9                	addi	a5,a5,26
    80005f02:	078e                	slli	a5,a5,0x3
    80005f04:	97aa                	add	a5,a5,a0
    80005f06:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    80005f0a:	fe043503          	ld	a0,-32(s0)
    80005f0e:	fffff097          	auipc	ra,0xfffff
    80005f12:	272080e7          	jalr	626(ra) # 80005180 <fileclose>
  return 0;
    80005f16:	4781                	li	a5,0
}
    80005f18:	853e                	mv	a0,a5
    80005f1a:	60e2                	ld	ra,24(sp)
    80005f1c:	6442                	ld	s0,16(sp)
    80005f1e:	6105                	addi	sp,sp,32
    80005f20:	8082                	ret

0000000080005f22 <sys_fstat>:
{
    80005f22:	1101                	addi	sp,sp,-32
    80005f24:	ec06                	sd	ra,24(sp)
    80005f26:	e822                	sd	s0,16(sp)
    80005f28:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005f2a:	fe040593          	addi	a1,s0,-32
    80005f2e:	4505                	li	a0,1
    80005f30:	ffffd097          	auipc	ra,0xffffd
    80005f34:	554080e7          	jalr	1364(ra) # 80003484 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005f38:	fe840613          	addi	a2,s0,-24
    80005f3c:	4581                	li	a1,0
    80005f3e:	4501                	li	a0,0
    80005f40:	00000097          	auipc	ra,0x0
    80005f44:	c68080e7          	jalr	-920(ra) # 80005ba8 <argfd>
    80005f48:	87aa                	mv	a5,a0
    return -1;
    80005f4a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005f4c:	0007ca63          	bltz	a5,80005f60 <sys_fstat+0x3e>
  return filestat(f, st);
    80005f50:	fe043583          	ld	a1,-32(s0)
    80005f54:	fe843503          	ld	a0,-24(s0)
    80005f58:	fffff097          	auipc	ra,0xfffff
    80005f5c:	2f0080e7          	jalr	752(ra) # 80005248 <filestat>
}
    80005f60:	60e2                	ld	ra,24(sp)
    80005f62:	6442                	ld	s0,16(sp)
    80005f64:	6105                	addi	sp,sp,32
    80005f66:	8082                	ret

0000000080005f68 <sys_link>:
{
    80005f68:	7169                	addi	sp,sp,-304
    80005f6a:	f606                	sd	ra,296(sp)
    80005f6c:	f222                	sd	s0,288(sp)
    80005f6e:	ee26                	sd	s1,280(sp)
    80005f70:	ea4a                	sd	s2,272(sp)
    80005f72:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005f74:	08000613          	li	a2,128
    80005f78:	ed040593          	addi	a1,s0,-304
    80005f7c:	4501                	li	a0,0
    80005f7e:	ffffd097          	auipc	ra,0xffffd
    80005f82:	526080e7          	jalr	1318(ra) # 800034a4 <argstr>
    return -1;
    80005f86:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005f88:	10054e63          	bltz	a0,800060a4 <sys_link+0x13c>
    80005f8c:	08000613          	li	a2,128
    80005f90:	f5040593          	addi	a1,s0,-176
    80005f94:	4505                	li	a0,1
    80005f96:	ffffd097          	auipc	ra,0xffffd
    80005f9a:	50e080e7          	jalr	1294(ra) # 800034a4 <argstr>
    return -1;
    80005f9e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005fa0:	10054263          	bltz	a0,800060a4 <sys_link+0x13c>
  begin_op();
    80005fa4:	fffff097          	auipc	ra,0xfffff
    80005fa8:	d10080e7          	jalr	-752(ra) # 80004cb4 <begin_op>
  if((ip = namei(old)) == 0){
    80005fac:	ed040513          	addi	a0,s0,-304
    80005fb0:	fffff097          	auipc	ra,0xfffff
    80005fb4:	ae8080e7          	jalr	-1304(ra) # 80004a98 <namei>
    80005fb8:	84aa                	mv	s1,a0
    80005fba:	c551                	beqz	a0,80006046 <sys_link+0xde>
  ilock(ip);
    80005fbc:	ffffe097          	auipc	ra,0xffffe
    80005fc0:	336080e7          	jalr	822(ra) # 800042f2 <ilock>
  if(ip->type == T_DIR){
    80005fc4:	04449703          	lh	a4,68(s1)
    80005fc8:	4785                	li	a5,1
    80005fca:	08f70463          	beq	a4,a5,80006052 <sys_link+0xea>
  ip->nlink++;
    80005fce:	04a4d783          	lhu	a5,74(s1)
    80005fd2:	2785                	addiw	a5,a5,1
    80005fd4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005fd8:	8526                	mv	a0,s1
    80005fda:	ffffe097          	auipc	ra,0xffffe
    80005fde:	24e080e7          	jalr	590(ra) # 80004228 <iupdate>
  iunlock(ip);
    80005fe2:	8526                	mv	a0,s1
    80005fe4:	ffffe097          	auipc	ra,0xffffe
    80005fe8:	3d0080e7          	jalr	976(ra) # 800043b4 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005fec:	fd040593          	addi	a1,s0,-48
    80005ff0:	f5040513          	addi	a0,s0,-176
    80005ff4:	fffff097          	auipc	ra,0xfffff
    80005ff8:	ac2080e7          	jalr	-1342(ra) # 80004ab6 <nameiparent>
    80005ffc:	892a                	mv	s2,a0
    80005ffe:	c935                	beqz	a0,80006072 <sys_link+0x10a>
  ilock(dp);
    80006000:	ffffe097          	auipc	ra,0xffffe
    80006004:	2f2080e7          	jalr	754(ra) # 800042f2 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80006008:	00092703          	lw	a4,0(s2)
    8000600c:	409c                	lw	a5,0(s1)
    8000600e:	04f71d63          	bne	a4,a5,80006068 <sys_link+0x100>
    80006012:	40d0                	lw	a2,4(s1)
    80006014:	fd040593          	addi	a1,s0,-48
    80006018:	854a                	mv	a0,s2
    8000601a:	fffff097          	auipc	ra,0xfffff
    8000601e:	9cc080e7          	jalr	-1588(ra) # 800049e6 <dirlink>
    80006022:	04054363          	bltz	a0,80006068 <sys_link+0x100>
  iunlockput(dp);
    80006026:	854a                	mv	a0,s2
    80006028:	ffffe097          	auipc	ra,0xffffe
    8000602c:	52c080e7          	jalr	1324(ra) # 80004554 <iunlockput>
  iput(ip);
    80006030:	8526                	mv	a0,s1
    80006032:	ffffe097          	auipc	ra,0xffffe
    80006036:	47a080e7          	jalr	1146(ra) # 800044ac <iput>
  end_op();
    8000603a:	fffff097          	auipc	ra,0xfffff
    8000603e:	cfa080e7          	jalr	-774(ra) # 80004d34 <end_op>
  return 0;
    80006042:	4781                	li	a5,0
    80006044:	a085                	j	800060a4 <sys_link+0x13c>
    end_op();
    80006046:	fffff097          	auipc	ra,0xfffff
    8000604a:	cee080e7          	jalr	-786(ra) # 80004d34 <end_op>
    return -1;
    8000604e:	57fd                	li	a5,-1
    80006050:	a891                	j	800060a4 <sys_link+0x13c>
    iunlockput(ip);
    80006052:	8526                	mv	a0,s1
    80006054:	ffffe097          	auipc	ra,0xffffe
    80006058:	500080e7          	jalr	1280(ra) # 80004554 <iunlockput>
    end_op();
    8000605c:	fffff097          	auipc	ra,0xfffff
    80006060:	cd8080e7          	jalr	-808(ra) # 80004d34 <end_op>
    return -1;
    80006064:	57fd                	li	a5,-1
    80006066:	a83d                	j	800060a4 <sys_link+0x13c>
    iunlockput(dp);
    80006068:	854a                	mv	a0,s2
    8000606a:	ffffe097          	auipc	ra,0xffffe
    8000606e:	4ea080e7          	jalr	1258(ra) # 80004554 <iunlockput>
  ilock(ip);
    80006072:	8526                	mv	a0,s1
    80006074:	ffffe097          	auipc	ra,0xffffe
    80006078:	27e080e7          	jalr	638(ra) # 800042f2 <ilock>
  ip->nlink--;
    8000607c:	04a4d783          	lhu	a5,74(s1)
    80006080:	37fd                	addiw	a5,a5,-1
    80006082:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80006086:	8526                	mv	a0,s1
    80006088:	ffffe097          	auipc	ra,0xffffe
    8000608c:	1a0080e7          	jalr	416(ra) # 80004228 <iupdate>
  iunlockput(ip);
    80006090:	8526                	mv	a0,s1
    80006092:	ffffe097          	auipc	ra,0xffffe
    80006096:	4c2080e7          	jalr	1218(ra) # 80004554 <iunlockput>
  end_op();
    8000609a:	fffff097          	auipc	ra,0xfffff
    8000609e:	c9a080e7          	jalr	-870(ra) # 80004d34 <end_op>
  return -1;
    800060a2:	57fd                	li	a5,-1
}
    800060a4:	853e                	mv	a0,a5
    800060a6:	70b2                	ld	ra,296(sp)
    800060a8:	7412                	ld	s0,288(sp)
    800060aa:	64f2                	ld	s1,280(sp)
    800060ac:	6952                	ld	s2,272(sp)
    800060ae:	6155                	addi	sp,sp,304
    800060b0:	8082                	ret

00000000800060b2 <sys_unlink>:
{
    800060b2:	7151                	addi	sp,sp,-240
    800060b4:	f586                	sd	ra,232(sp)
    800060b6:	f1a2                	sd	s0,224(sp)
    800060b8:	eda6                	sd	s1,216(sp)
    800060ba:	e9ca                	sd	s2,208(sp)
    800060bc:	e5ce                	sd	s3,200(sp)
    800060be:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800060c0:	08000613          	li	a2,128
    800060c4:	f3040593          	addi	a1,s0,-208
    800060c8:	4501                	li	a0,0
    800060ca:	ffffd097          	auipc	ra,0xffffd
    800060ce:	3da080e7          	jalr	986(ra) # 800034a4 <argstr>
    800060d2:	18054163          	bltz	a0,80006254 <sys_unlink+0x1a2>
  begin_op();
    800060d6:	fffff097          	auipc	ra,0xfffff
    800060da:	bde080e7          	jalr	-1058(ra) # 80004cb4 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800060de:	fb040593          	addi	a1,s0,-80
    800060e2:	f3040513          	addi	a0,s0,-208
    800060e6:	fffff097          	auipc	ra,0xfffff
    800060ea:	9d0080e7          	jalr	-1584(ra) # 80004ab6 <nameiparent>
    800060ee:	84aa                	mv	s1,a0
    800060f0:	c979                	beqz	a0,800061c6 <sys_unlink+0x114>
  ilock(dp);
    800060f2:	ffffe097          	auipc	ra,0xffffe
    800060f6:	200080e7          	jalr	512(ra) # 800042f2 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800060fa:	00002597          	auipc	a1,0x2
    800060fe:	78658593          	addi	a1,a1,1926 # 80008880 <syscalls+0x2c8>
    80006102:	fb040513          	addi	a0,s0,-80
    80006106:	ffffe097          	auipc	ra,0xffffe
    8000610a:	6b6080e7          	jalr	1718(ra) # 800047bc <namecmp>
    8000610e:	14050a63          	beqz	a0,80006262 <sys_unlink+0x1b0>
    80006112:	00002597          	auipc	a1,0x2
    80006116:	77658593          	addi	a1,a1,1910 # 80008888 <syscalls+0x2d0>
    8000611a:	fb040513          	addi	a0,s0,-80
    8000611e:	ffffe097          	auipc	ra,0xffffe
    80006122:	69e080e7          	jalr	1694(ra) # 800047bc <namecmp>
    80006126:	12050e63          	beqz	a0,80006262 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000612a:	f2c40613          	addi	a2,s0,-212
    8000612e:	fb040593          	addi	a1,s0,-80
    80006132:	8526                	mv	a0,s1
    80006134:	ffffe097          	auipc	ra,0xffffe
    80006138:	6a2080e7          	jalr	1698(ra) # 800047d6 <dirlookup>
    8000613c:	892a                	mv	s2,a0
    8000613e:	12050263          	beqz	a0,80006262 <sys_unlink+0x1b0>
  ilock(ip);
    80006142:	ffffe097          	auipc	ra,0xffffe
    80006146:	1b0080e7          	jalr	432(ra) # 800042f2 <ilock>
  if(ip->nlink < 1)
    8000614a:	04a91783          	lh	a5,74(s2)
    8000614e:	08f05263          	blez	a5,800061d2 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80006152:	04491703          	lh	a4,68(s2)
    80006156:	4785                	li	a5,1
    80006158:	08f70563          	beq	a4,a5,800061e2 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000615c:	4641                	li	a2,16
    8000615e:	4581                	li	a1,0
    80006160:	fc040513          	addi	a0,s0,-64
    80006164:	ffffb097          	auipc	ra,0xffffb
    80006168:	d40080e7          	jalr	-704(ra) # 80000ea4 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000616c:	4741                	li	a4,16
    8000616e:	f2c42683          	lw	a3,-212(s0)
    80006172:	fc040613          	addi	a2,s0,-64
    80006176:	4581                	li	a1,0
    80006178:	8526                	mv	a0,s1
    8000617a:	ffffe097          	auipc	ra,0xffffe
    8000617e:	524080e7          	jalr	1316(ra) # 8000469e <writei>
    80006182:	47c1                	li	a5,16
    80006184:	0af51563          	bne	a0,a5,8000622e <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80006188:	04491703          	lh	a4,68(s2)
    8000618c:	4785                	li	a5,1
    8000618e:	0af70863          	beq	a4,a5,8000623e <sys_unlink+0x18c>
  iunlockput(dp);
    80006192:	8526                	mv	a0,s1
    80006194:	ffffe097          	auipc	ra,0xffffe
    80006198:	3c0080e7          	jalr	960(ra) # 80004554 <iunlockput>
  ip->nlink--;
    8000619c:	04a95783          	lhu	a5,74(s2)
    800061a0:	37fd                	addiw	a5,a5,-1
    800061a2:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800061a6:	854a                	mv	a0,s2
    800061a8:	ffffe097          	auipc	ra,0xffffe
    800061ac:	080080e7          	jalr	128(ra) # 80004228 <iupdate>
  iunlockput(ip);
    800061b0:	854a                	mv	a0,s2
    800061b2:	ffffe097          	auipc	ra,0xffffe
    800061b6:	3a2080e7          	jalr	930(ra) # 80004554 <iunlockput>
  end_op();
    800061ba:	fffff097          	auipc	ra,0xfffff
    800061be:	b7a080e7          	jalr	-1158(ra) # 80004d34 <end_op>
  return 0;
    800061c2:	4501                	li	a0,0
    800061c4:	a84d                	j	80006276 <sys_unlink+0x1c4>
    end_op();
    800061c6:	fffff097          	auipc	ra,0xfffff
    800061ca:	b6e080e7          	jalr	-1170(ra) # 80004d34 <end_op>
    return -1;
    800061ce:	557d                	li	a0,-1
    800061d0:	a05d                	j	80006276 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800061d2:	00002517          	auipc	a0,0x2
    800061d6:	6be50513          	addi	a0,a0,1726 # 80008890 <syscalls+0x2d8>
    800061da:	ffffa097          	auipc	ra,0xffffa
    800061de:	36a080e7          	jalr	874(ra) # 80000544 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800061e2:	04c92703          	lw	a4,76(s2)
    800061e6:	02000793          	li	a5,32
    800061ea:	f6e7f9e3          	bgeu	a5,a4,8000615c <sys_unlink+0xaa>
    800061ee:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800061f2:	4741                	li	a4,16
    800061f4:	86ce                	mv	a3,s3
    800061f6:	f1840613          	addi	a2,s0,-232
    800061fa:	4581                	li	a1,0
    800061fc:	854a                	mv	a0,s2
    800061fe:	ffffe097          	auipc	ra,0xffffe
    80006202:	3a8080e7          	jalr	936(ra) # 800045a6 <readi>
    80006206:	47c1                	li	a5,16
    80006208:	00f51b63          	bne	a0,a5,8000621e <sys_unlink+0x16c>
    if(de.inum != 0)
    8000620c:	f1845783          	lhu	a5,-232(s0)
    80006210:	e7a1                	bnez	a5,80006258 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006212:	29c1                	addiw	s3,s3,16
    80006214:	04c92783          	lw	a5,76(s2)
    80006218:	fcf9ede3          	bltu	s3,a5,800061f2 <sys_unlink+0x140>
    8000621c:	b781                	j	8000615c <sys_unlink+0xaa>
      panic("isdirempty: readi");
    8000621e:	00002517          	auipc	a0,0x2
    80006222:	68a50513          	addi	a0,a0,1674 # 800088a8 <syscalls+0x2f0>
    80006226:	ffffa097          	auipc	ra,0xffffa
    8000622a:	31e080e7          	jalr	798(ra) # 80000544 <panic>
    panic("unlink: writei");
    8000622e:	00002517          	auipc	a0,0x2
    80006232:	69250513          	addi	a0,a0,1682 # 800088c0 <syscalls+0x308>
    80006236:	ffffa097          	auipc	ra,0xffffa
    8000623a:	30e080e7          	jalr	782(ra) # 80000544 <panic>
    dp->nlink--;
    8000623e:	04a4d783          	lhu	a5,74(s1)
    80006242:	37fd                	addiw	a5,a5,-1
    80006244:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80006248:	8526                	mv	a0,s1
    8000624a:	ffffe097          	auipc	ra,0xffffe
    8000624e:	fde080e7          	jalr	-34(ra) # 80004228 <iupdate>
    80006252:	b781                	j	80006192 <sys_unlink+0xe0>
    return -1;
    80006254:	557d                	li	a0,-1
    80006256:	a005                	j	80006276 <sys_unlink+0x1c4>
    iunlockput(ip);
    80006258:	854a                	mv	a0,s2
    8000625a:	ffffe097          	auipc	ra,0xffffe
    8000625e:	2fa080e7          	jalr	762(ra) # 80004554 <iunlockput>
  iunlockput(dp);
    80006262:	8526                	mv	a0,s1
    80006264:	ffffe097          	auipc	ra,0xffffe
    80006268:	2f0080e7          	jalr	752(ra) # 80004554 <iunlockput>
  end_op();
    8000626c:	fffff097          	auipc	ra,0xfffff
    80006270:	ac8080e7          	jalr	-1336(ra) # 80004d34 <end_op>
  return -1;
    80006274:	557d                	li	a0,-1
}
    80006276:	70ae                	ld	ra,232(sp)
    80006278:	740e                	ld	s0,224(sp)
    8000627a:	64ee                	ld	s1,216(sp)
    8000627c:	694e                	ld	s2,208(sp)
    8000627e:	69ae                	ld	s3,200(sp)
    80006280:	616d                	addi	sp,sp,240
    80006282:	8082                	ret

0000000080006284 <sys_open>:

uint64
sys_open(void)
{
    80006284:	7131                	addi	sp,sp,-192
    80006286:	fd06                	sd	ra,184(sp)
    80006288:	f922                	sd	s0,176(sp)
    8000628a:	f526                	sd	s1,168(sp)
    8000628c:	f14a                	sd	s2,160(sp)
    8000628e:	ed4e                	sd	s3,152(sp)
    80006290:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80006292:	f4c40593          	addi	a1,s0,-180
    80006296:	4505                	li	a0,1
    80006298:	ffffd097          	auipc	ra,0xffffd
    8000629c:	1cc080e7          	jalr	460(ra) # 80003464 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800062a0:	08000613          	li	a2,128
    800062a4:	f5040593          	addi	a1,s0,-176
    800062a8:	4501                	li	a0,0
    800062aa:	ffffd097          	auipc	ra,0xffffd
    800062ae:	1fa080e7          	jalr	506(ra) # 800034a4 <argstr>
    800062b2:	87aa                	mv	a5,a0
    return -1;
    800062b4:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800062b6:	0a07c963          	bltz	a5,80006368 <sys_open+0xe4>

  begin_op();
    800062ba:	fffff097          	auipc	ra,0xfffff
    800062be:	9fa080e7          	jalr	-1542(ra) # 80004cb4 <begin_op>

  if(omode & O_CREATE){
    800062c2:	f4c42783          	lw	a5,-180(s0)
    800062c6:	2007f793          	andi	a5,a5,512
    800062ca:	cfc5                	beqz	a5,80006382 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800062cc:	4681                	li	a3,0
    800062ce:	4601                	li	a2,0
    800062d0:	4589                	li	a1,2
    800062d2:	f5040513          	addi	a0,s0,-176
    800062d6:	00000097          	auipc	ra,0x0
    800062da:	974080e7          	jalr	-1676(ra) # 80005c4a <create>
    800062de:	84aa                	mv	s1,a0
    if(ip == 0){
    800062e0:	c959                	beqz	a0,80006376 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800062e2:	04449703          	lh	a4,68(s1)
    800062e6:	478d                	li	a5,3
    800062e8:	00f71763          	bne	a4,a5,800062f6 <sys_open+0x72>
    800062ec:	0464d703          	lhu	a4,70(s1)
    800062f0:	47a5                	li	a5,9
    800062f2:	0ce7ed63          	bltu	a5,a4,800063cc <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800062f6:	fffff097          	auipc	ra,0xfffff
    800062fa:	dce080e7          	jalr	-562(ra) # 800050c4 <filealloc>
    800062fe:	89aa                	mv	s3,a0
    80006300:	10050363          	beqz	a0,80006406 <sys_open+0x182>
    80006304:	00000097          	auipc	ra,0x0
    80006308:	904080e7          	jalr	-1788(ra) # 80005c08 <fdalloc>
    8000630c:	892a                	mv	s2,a0
    8000630e:	0e054763          	bltz	a0,800063fc <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80006312:	04449703          	lh	a4,68(s1)
    80006316:	478d                	li	a5,3
    80006318:	0cf70563          	beq	a4,a5,800063e2 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000631c:	4789                	li	a5,2
    8000631e:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80006322:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80006326:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000632a:	f4c42783          	lw	a5,-180(s0)
    8000632e:	0017c713          	xori	a4,a5,1
    80006332:	8b05                	andi	a4,a4,1
    80006334:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80006338:	0037f713          	andi	a4,a5,3
    8000633c:	00e03733          	snez	a4,a4
    80006340:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80006344:	4007f793          	andi	a5,a5,1024
    80006348:	c791                	beqz	a5,80006354 <sys_open+0xd0>
    8000634a:	04449703          	lh	a4,68(s1)
    8000634e:	4789                	li	a5,2
    80006350:	0af70063          	beq	a4,a5,800063f0 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80006354:	8526                	mv	a0,s1
    80006356:	ffffe097          	auipc	ra,0xffffe
    8000635a:	05e080e7          	jalr	94(ra) # 800043b4 <iunlock>
  end_op();
    8000635e:	fffff097          	auipc	ra,0xfffff
    80006362:	9d6080e7          	jalr	-1578(ra) # 80004d34 <end_op>

  return fd;
    80006366:	854a                	mv	a0,s2
}
    80006368:	70ea                	ld	ra,184(sp)
    8000636a:	744a                	ld	s0,176(sp)
    8000636c:	74aa                	ld	s1,168(sp)
    8000636e:	790a                	ld	s2,160(sp)
    80006370:	69ea                	ld	s3,152(sp)
    80006372:	6129                	addi	sp,sp,192
    80006374:	8082                	ret
      end_op();
    80006376:	fffff097          	auipc	ra,0xfffff
    8000637a:	9be080e7          	jalr	-1602(ra) # 80004d34 <end_op>
      return -1;
    8000637e:	557d                	li	a0,-1
    80006380:	b7e5                	j	80006368 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80006382:	f5040513          	addi	a0,s0,-176
    80006386:	ffffe097          	auipc	ra,0xffffe
    8000638a:	712080e7          	jalr	1810(ra) # 80004a98 <namei>
    8000638e:	84aa                	mv	s1,a0
    80006390:	c905                	beqz	a0,800063c0 <sys_open+0x13c>
    ilock(ip);
    80006392:	ffffe097          	auipc	ra,0xffffe
    80006396:	f60080e7          	jalr	-160(ra) # 800042f2 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000639a:	04449703          	lh	a4,68(s1)
    8000639e:	4785                	li	a5,1
    800063a0:	f4f711e3          	bne	a4,a5,800062e2 <sys_open+0x5e>
    800063a4:	f4c42783          	lw	a5,-180(s0)
    800063a8:	d7b9                	beqz	a5,800062f6 <sys_open+0x72>
      iunlockput(ip);
    800063aa:	8526                	mv	a0,s1
    800063ac:	ffffe097          	auipc	ra,0xffffe
    800063b0:	1a8080e7          	jalr	424(ra) # 80004554 <iunlockput>
      end_op();
    800063b4:	fffff097          	auipc	ra,0xfffff
    800063b8:	980080e7          	jalr	-1664(ra) # 80004d34 <end_op>
      return -1;
    800063bc:	557d                	li	a0,-1
    800063be:	b76d                	j	80006368 <sys_open+0xe4>
      end_op();
    800063c0:	fffff097          	auipc	ra,0xfffff
    800063c4:	974080e7          	jalr	-1676(ra) # 80004d34 <end_op>
      return -1;
    800063c8:	557d                	li	a0,-1
    800063ca:	bf79                	j	80006368 <sys_open+0xe4>
    iunlockput(ip);
    800063cc:	8526                	mv	a0,s1
    800063ce:	ffffe097          	auipc	ra,0xffffe
    800063d2:	186080e7          	jalr	390(ra) # 80004554 <iunlockput>
    end_op();
    800063d6:	fffff097          	auipc	ra,0xfffff
    800063da:	95e080e7          	jalr	-1698(ra) # 80004d34 <end_op>
    return -1;
    800063de:	557d                	li	a0,-1
    800063e0:	b761                	j	80006368 <sys_open+0xe4>
    f->type = FD_DEVICE;
    800063e2:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800063e6:	04649783          	lh	a5,70(s1)
    800063ea:	02f99223          	sh	a5,36(s3)
    800063ee:	bf25                	j	80006326 <sys_open+0xa2>
    itrunc(ip);
    800063f0:	8526                	mv	a0,s1
    800063f2:	ffffe097          	auipc	ra,0xffffe
    800063f6:	00e080e7          	jalr	14(ra) # 80004400 <itrunc>
    800063fa:	bfa9                	j	80006354 <sys_open+0xd0>
      fileclose(f);
    800063fc:	854e                	mv	a0,s3
    800063fe:	fffff097          	auipc	ra,0xfffff
    80006402:	d82080e7          	jalr	-638(ra) # 80005180 <fileclose>
    iunlockput(ip);
    80006406:	8526                	mv	a0,s1
    80006408:	ffffe097          	auipc	ra,0xffffe
    8000640c:	14c080e7          	jalr	332(ra) # 80004554 <iunlockput>
    end_op();
    80006410:	fffff097          	auipc	ra,0xfffff
    80006414:	924080e7          	jalr	-1756(ra) # 80004d34 <end_op>
    return -1;
    80006418:	557d                	li	a0,-1
    8000641a:	b7b9                	j	80006368 <sys_open+0xe4>

000000008000641c <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000641c:	7175                	addi	sp,sp,-144
    8000641e:	e506                	sd	ra,136(sp)
    80006420:	e122                	sd	s0,128(sp)
    80006422:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80006424:	fffff097          	auipc	ra,0xfffff
    80006428:	890080e7          	jalr	-1904(ra) # 80004cb4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000642c:	08000613          	li	a2,128
    80006430:	f7040593          	addi	a1,s0,-144
    80006434:	4501                	li	a0,0
    80006436:	ffffd097          	auipc	ra,0xffffd
    8000643a:	06e080e7          	jalr	110(ra) # 800034a4 <argstr>
    8000643e:	02054963          	bltz	a0,80006470 <sys_mkdir+0x54>
    80006442:	4681                	li	a3,0
    80006444:	4601                	li	a2,0
    80006446:	4585                	li	a1,1
    80006448:	f7040513          	addi	a0,s0,-144
    8000644c:	fffff097          	auipc	ra,0xfffff
    80006450:	7fe080e7          	jalr	2046(ra) # 80005c4a <create>
    80006454:	cd11                	beqz	a0,80006470 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006456:	ffffe097          	auipc	ra,0xffffe
    8000645a:	0fe080e7          	jalr	254(ra) # 80004554 <iunlockput>
  end_op();
    8000645e:	fffff097          	auipc	ra,0xfffff
    80006462:	8d6080e7          	jalr	-1834(ra) # 80004d34 <end_op>
  return 0;
    80006466:	4501                	li	a0,0
}
    80006468:	60aa                	ld	ra,136(sp)
    8000646a:	640a                	ld	s0,128(sp)
    8000646c:	6149                	addi	sp,sp,144
    8000646e:	8082                	ret
    end_op();
    80006470:	fffff097          	auipc	ra,0xfffff
    80006474:	8c4080e7          	jalr	-1852(ra) # 80004d34 <end_op>
    return -1;
    80006478:	557d                	li	a0,-1
    8000647a:	b7fd                	j	80006468 <sys_mkdir+0x4c>

000000008000647c <sys_mknod>:

uint64
sys_mknod(void)
{
    8000647c:	7135                	addi	sp,sp,-160
    8000647e:	ed06                	sd	ra,152(sp)
    80006480:	e922                	sd	s0,144(sp)
    80006482:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80006484:	fffff097          	auipc	ra,0xfffff
    80006488:	830080e7          	jalr	-2000(ra) # 80004cb4 <begin_op>
  argint(1, &major);
    8000648c:	f6c40593          	addi	a1,s0,-148
    80006490:	4505                	li	a0,1
    80006492:	ffffd097          	auipc	ra,0xffffd
    80006496:	fd2080e7          	jalr	-46(ra) # 80003464 <argint>
  argint(2, &minor);
    8000649a:	f6840593          	addi	a1,s0,-152
    8000649e:	4509                	li	a0,2
    800064a0:	ffffd097          	auipc	ra,0xffffd
    800064a4:	fc4080e7          	jalr	-60(ra) # 80003464 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800064a8:	08000613          	li	a2,128
    800064ac:	f7040593          	addi	a1,s0,-144
    800064b0:	4501                	li	a0,0
    800064b2:	ffffd097          	auipc	ra,0xffffd
    800064b6:	ff2080e7          	jalr	-14(ra) # 800034a4 <argstr>
    800064ba:	02054b63          	bltz	a0,800064f0 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800064be:	f6841683          	lh	a3,-152(s0)
    800064c2:	f6c41603          	lh	a2,-148(s0)
    800064c6:	458d                	li	a1,3
    800064c8:	f7040513          	addi	a0,s0,-144
    800064cc:	fffff097          	auipc	ra,0xfffff
    800064d0:	77e080e7          	jalr	1918(ra) # 80005c4a <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800064d4:	cd11                	beqz	a0,800064f0 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800064d6:	ffffe097          	auipc	ra,0xffffe
    800064da:	07e080e7          	jalr	126(ra) # 80004554 <iunlockput>
  end_op();
    800064de:	fffff097          	auipc	ra,0xfffff
    800064e2:	856080e7          	jalr	-1962(ra) # 80004d34 <end_op>
  return 0;
    800064e6:	4501                	li	a0,0
}
    800064e8:	60ea                	ld	ra,152(sp)
    800064ea:	644a                	ld	s0,144(sp)
    800064ec:	610d                	addi	sp,sp,160
    800064ee:	8082                	ret
    end_op();
    800064f0:	fffff097          	auipc	ra,0xfffff
    800064f4:	844080e7          	jalr	-1980(ra) # 80004d34 <end_op>
    return -1;
    800064f8:	557d                	li	a0,-1
    800064fa:	b7fd                	j	800064e8 <sys_mknod+0x6c>

00000000800064fc <sys_chdir>:

uint64
sys_chdir(void)
{
    800064fc:	7135                	addi	sp,sp,-160
    800064fe:	ed06                	sd	ra,152(sp)
    80006500:	e922                	sd	s0,144(sp)
    80006502:	e526                	sd	s1,136(sp)
    80006504:	e14a                	sd	s2,128(sp)
    80006506:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80006508:	ffffc097          	auipc	ra,0xffffc
    8000650c:	860080e7          	jalr	-1952(ra) # 80001d68 <myproc>
    80006510:	892a                	mv	s2,a0
  
  begin_op();
    80006512:	ffffe097          	auipc	ra,0xffffe
    80006516:	7a2080e7          	jalr	1954(ra) # 80004cb4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000651a:	08000613          	li	a2,128
    8000651e:	f6040593          	addi	a1,s0,-160
    80006522:	4501                	li	a0,0
    80006524:	ffffd097          	auipc	ra,0xffffd
    80006528:	f80080e7          	jalr	-128(ra) # 800034a4 <argstr>
    8000652c:	04054b63          	bltz	a0,80006582 <sys_chdir+0x86>
    80006530:	f6040513          	addi	a0,s0,-160
    80006534:	ffffe097          	auipc	ra,0xffffe
    80006538:	564080e7          	jalr	1380(ra) # 80004a98 <namei>
    8000653c:	84aa                	mv	s1,a0
    8000653e:	c131                	beqz	a0,80006582 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006540:	ffffe097          	auipc	ra,0xffffe
    80006544:	db2080e7          	jalr	-590(ra) # 800042f2 <ilock>
  if(ip->type != T_DIR){
    80006548:	04449703          	lh	a4,68(s1)
    8000654c:	4785                	li	a5,1
    8000654e:	04f71063          	bne	a4,a5,8000658e <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006552:	8526                	mv	a0,s1
    80006554:	ffffe097          	auipc	ra,0xffffe
    80006558:	e60080e7          	jalr	-416(ra) # 800043b4 <iunlock>
  iput(p->cwd);
    8000655c:	15893503          	ld	a0,344(s2)
    80006560:	ffffe097          	auipc	ra,0xffffe
    80006564:	f4c080e7          	jalr	-180(ra) # 800044ac <iput>
  end_op();
    80006568:	ffffe097          	auipc	ra,0xffffe
    8000656c:	7cc080e7          	jalr	1996(ra) # 80004d34 <end_op>
  p->cwd = ip;
    80006570:	14993c23          	sd	s1,344(s2)
  return 0;
    80006574:	4501                	li	a0,0
}
    80006576:	60ea                	ld	ra,152(sp)
    80006578:	644a                	ld	s0,144(sp)
    8000657a:	64aa                	ld	s1,136(sp)
    8000657c:	690a                	ld	s2,128(sp)
    8000657e:	610d                	addi	sp,sp,160
    80006580:	8082                	ret
    end_op();
    80006582:	ffffe097          	auipc	ra,0xffffe
    80006586:	7b2080e7          	jalr	1970(ra) # 80004d34 <end_op>
    return -1;
    8000658a:	557d                	li	a0,-1
    8000658c:	b7ed                	j	80006576 <sys_chdir+0x7a>
    iunlockput(ip);
    8000658e:	8526                	mv	a0,s1
    80006590:	ffffe097          	auipc	ra,0xffffe
    80006594:	fc4080e7          	jalr	-60(ra) # 80004554 <iunlockput>
    end_op();
    80006598:	ffffe097          	auipc	ra,0xffffe
    8000659c:	79c080e7          	jalr	1948(ra) # 80004d34 <end_op>
    return -1;
    800065a0:	557d                	li	a0,-1
    800065a2:	bfd1                	j	80006576 <sys_chdir+0x7a>

00000000800065a4 <sys_exec>:

uint64
sys_exec(void)
{
    800065a4:	7145                	addi	sp,sp,-464
    800065a6:	e786                	sd	ra,456(sp)
    800065a8:	e3a2                	sd	s0,448(sp)
    800065aa:	ff26                	sd	s1,440(sp)
    800065ac:	fb4a                	sd	s2,432(sp)
    800065ae:	f74e                	sd	s3,424(sp)
    800065b0:	f352                	sd	s4,416(sp)
    800065b2:	ef56                	sd	s5,408(sp)
    800065b4:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800065b6:	e3840593          	addi	a1,s0,-456
    800065ba:	4505                	li	a0,1
    800065bc:	ffffd097          	auipc	ra,0xffffd
    800065c0:	ec8080e7          	jalr	-312(ra) # 80003484 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800065c4:	08000613          	li	a2,128
    800065c8:	f4040593          	addi	a1,s0,-192
    800065cc:	4501                	li	a0,0
    800065ce:	ffffd097          	auipc	ra,0xffffd
    800065d2:	ed6080e7          	jalr	-298(ra) # 800034a4 <argstr>
    800065d6:	87aa                	mv	a5,a0
    return -1;
    800065d8:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800065da:	0c07c263          	bltz	a5,8000669e <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    800065de:	10000613          	li	a2,256
    800065e2:	4581                	li	a1,0
    800065e4:	e4040513          	addi	a0,s0,-448
    800065e8:	ffffb097          	auipc	ra,0xffffb
    800065ec:	8bc080e7          	jalr	-1860(ra) # 80000ea4 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800065f0:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800065f4:	89a6                	mv	s3,s1
    800065f6:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800065f8:	02000a13          	li	s4,32
    800065fc:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006600:	00391513          	slli	a0,s2,0x3
    80006604:	e3040593          	addi	a1,s0,-464
    80006608:	e3843783          	ld	a5,-456(s0)
    8000660c:	953e                	add	a0,a0,a5
    8000660e:	ffffd097          	auipc	ra,0xffffd
    80006612:	db8080e7          	jalr	-584(ra) # 800033c6 <fetchaddr>
    80006616:	02054a63          	bltz	a0,8000664a <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    8000661a:	e3043783          	ld	a5,-464(s0)
    8000661e:	c3b9                	beqz	a5,80006664 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006620:	ffffa097          	auipc	ra,0xffffa
    80006624:	654080e7          	jalr	1620(ra) # 80000c74 <kalloc>
    80006628:	85aa                	mv	a1,a0
    8000662a:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000662e:	cd11                	beqz	a0,8000664a <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006630:	6605                	lui	a2,0x1
    80006632:	e3043503          	ld	a0,-464(s0)
    80006636:	ffffd097          	auipc	ra,0xffffd
    8000663a:	de2080e7          	jalr	-542(ra) # 80003418 <fetchstr>
    8000663e:	00054663          	bltz	a0,8000664a <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80006642:	0905                	addi	s2,s2,1
    80006644:	09a1                	addi	s3,s3,8
    80006646:	fb491be3          	bne	s2,s4,800065fc <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000664a:	10048913          	addi	s2,s1,256
    8000664e:	6088                	ld	a0,0(s1)
    80006650:	c531                	beqz	a0,8000669c <sys_exec+0xf8>
    kfree(argv[i]);
    80006652:	ffffa097          	auipc	ra,0xffffa
    80006656:	47c080e7          	jalr	1148(ra) # 80000ace <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000665a:	04a1                	addi	s1,s1,8
    8000665c:	ff2499e3          	bne	s1,s2,8000664e <sys_exec+0xaa>
  return -1;
    80006660:	557d                	li	a0,-1
    80006662:	a835                	j	8000669e <sys_exec+0xfa>
      argv[i] = 0;
    80006664:	0a8e                	slli	s5,s5,0x3
    80006666:	fc040793          	addi	a5,s0,-64
    8000666a:	9abe                	add	s5,s5,a5
    8000666c:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80006670:	e4040593          	addi	a1,s0,-448
    80006674:	f4040513          	addi	a0,s0,-192
    80006678:	fffff097          	auipc	ra,0xfffff
    8000667c:	190080e7          	jalr	400(ra) # 80005808 <exec>
    80006680:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006682:	10048993          	addi	s3,s1,256
    80006686:	6088                	ld	a0,0(s1)
    80006688:	c901                	beqz	a0,80006698 <sys_exec+0xf4>
    kfree(argv[i]);
    8000668a:	ffffa097          	auipc	ra,0xffffa
    8000668e:	444080e7          	jalr	1092(ra) # 80000ace <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006692:	04a1                	addi	s1,s1,8
    80006694:	ff3499e3          	bne	s1,s3,80006686 <sys_exec+0xe2>
  return ret;
    80006698:	854a                	mv	a0,s2
    8000669a:	a011                	j	8000669e <sys_exec+0xfa>
  return -1;
    8000669c:	557d                	li	a0,-1
}
    8000669e:	60be                	ld	ra,456(sp)
    800066a0:	641e                	ld	s0,448(sp)
    800066a2:	74fa                	ld	s1,440(sp)
    800066a4:	795a                	ld	s2,432(sp)
    800066a6:	79ba                	ld	s3,424(sp)
    800066a8:	7a1a                	ld	s4,416(sp)
    800066aa:	6afa                	ld	s5,408(sp)
    800066ac:	6179                	addi	sp,sp,464
    800066ae:	8082                	ret

00000000800066b0 <sys_pipe>:

uint64
sys_pipe(void)
{
    800066b0:	7139                	addi	sp,sp,-64
    800066b2:	fc06                	sd	ra,56(sp)
    800066b4:	f822                	sd	s0,48(sp)
    800066b6:	f426                	sd	s1,40(sp)
    800066b8:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800066ba:	ffffb097          	auipc	ra,0xffffb
    800066be:	6ae080e7          	jalr	1710(ra) # 80001d68 <myproc>
    800066c2:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800066c4:	fd840593          	addi	a1,s0,-40
    800066c8:	4501                	li	a0,0
    800066ca:	ffffd097          	auipc	ra,0xffffd
    800066ce:	dba080e7          	jalr	-582(ra) # 80003484 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800066d2:	fc840593          	addi	a1,s0,-56
    800066d6:	fd040513          	addi	a0,s0,-48
    800066da:	fffff097          	auipc	ra,0xfffff
    800066de:	dd6080e7          	jalr	-554(ra) # 800054b0 <pipealloc>
    return -1;
    800066e2:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800066e4:	0c054463          	bltz	a0,800067ac <sys_pipe+0xfc>
  fd0 = -1;
    800066e8:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800066ec:	fd043503          	ld	a0,-48(s0)
    800066f0:	fffff097          	auipc	ra,0xfffff
    800066f4:	518080e7          	jalr	1304(ra) # 80005c08 <fdalloc>
    800066f8:	fca42223          	sw	a0,-60(s0)
    800066fc:	08054b63          	bltz	a0,80006792 <sys_pipe+0xe2>
    80006700:	fc843503          	ld	a0,-56(s0)
    80006704:	fffff097          	auipc	ra,0xfffff
    80006708:	504080e7          	jalr	1284(ra) # 80005c08 <fdalloc>
    8000670c:	fca42023          	sw	a0,-64(s0)
    80006710:	06054863          	bltz	a0,80006780 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006714:	4691                	li	a3,4
    80006716:	fc440613          	addi	a2,s0,-60
    8000671a:	fd843583          	ld	a1,-40(s0)
    8000671e:	6ca8                	ld	a0,88(s1)
    80006720:	ffffb097          	auipc	ra,0xffffb
    80006724:	118080e7          	jalr	280(ra) # 80001838 <copyout>
    80006728:	02054063          	bltz	a0,80006748 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000672c:	4691                	li	a3,4
    8000672e:	fc040613          	addi	a2,s0,-64
    80006732:	fd843583          	ld	a1,-40(s0)
    80006736:	0591                	addi	a1,a1,4
    80006738:	6ca8                	ld	a0,88(s1)
    8000673a:	ffffb097          	auipc	ra,0xffffb
    8000673e:	0fe080e7          	jalr	254(ra) # 80001838 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006742:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006744:	06055463          	bgez	a0,800067ac <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80006748:	fc442783          	lw	a5,-60(s0)
    8000674c:	07e9                	addi	a5,a5,26
    8000674e:	078e                	slli	a5,a5,0x3
    80006750:	97a6                	add	a5,a5,s1
    80006752:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80006756:	fc042503          	lw	a0,-64(s0)
    8000675a:	0569                	addi	a0,a0,26
    8000675c:	050e                	slli	a0,a0,0x3
    8000675e:	94aa                	add	s1,s1,a0
    80006760:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80006764:	fd043503          	ld	a0,-48(s0)
    80006768:	fffff097          	auipc	ra,0xfffff
    8000676c:	a18080e7          	jalr	-1512(ra) # 80005180 <fileclose>
    fileclose(wf);
    80006770:	fc843503          	ld	a0,-56(s0)
    80006774:	fffff097          	auipc	ra,0xfffff
    80006778:	a0c080e7          	jalr	-1524(ra) # 80005180 <fileclose>
    return -1;
    8000677c:	57fd                	li	a5,-1
    8000677e:	a03d                	j	800067ac <sys_pipe+0xfc>
    if(fd0 >= 0)
    80006780:	fc442783          	lw	a5,-60(s0)
    80006784:	0007c763          	bltz	a5,80006792 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80006788:	07e9                	addi	a5,a5,26
    8000678a:	078e                	slli	a5,a5,0x3
    8000678c:	94be                	add	s1,s1,a5
    8000678e:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80006792:	fd043503          	ld	a0,-48(s0)
    80006796:	fffff097          	auipc	ra,0xfffff
    8000679a:	9ea080e7          	jalr	-1558(ra) # 80005180 <fileclose>
    fileclose(wf);
    8000679e:	fc843503          	ld	a0,-56(s0)
    800067a2:	fffff097          	auipc	ra,0xfffff
    800067a6:	9de080e7          	jalr	-1570(ra) # 80005180 <fileclose>
    return -1;
    800067aa:	57fd                	li	a5,-1
}
    800067ac:	853e                	mv	a0,a5
    800067ae:	70e2                	ld	ra,56(sp)
    800067b0:	7442                	ld	s0,48(sp)
    800067b2:	74a2                	ld	s1,40(sp)
    800067b4:	6121                	addi	sp,sp,64
    800067b6:	8082                	ret
	...

00000000800067c0 <kernelvec>:
    800067c0:	7111                	addi	sp,sp,-256
    800067c2:	e006                	sd	ra,0(sp)
    800067c4:	e40a                	sd	sp,8(sp)
    800067c6:	e80e                	sd	gp,16(sp)
    800067c8:	ec12                	sd	tp,24(sp)
    800067ca:	f016                	sd	t0,32(sp)
    800067cc:	f41a                	sd	t1,40(sp)
    800067ce:	f81e                	sd	t2,48(sp)
    800067d0:	fc22                	sd	s0,56(sp)
    800067d2:	e0a6                	sd	s1,64(sp)
    800067d4:	e4aa                	sd	a0,72(sp)
    800067d6:	e8ae                	sd	a1,80(sp)
    800067d8:	ecb2                	sd	a2,88(sp)
    800067da:	f0b6                	sd	a3,96(sp)
    800067dc:	f4ba                	sd	a4,104(sp)
    800067de:	f8be                	sd	a5,112(sp)
    800067e0:	fcc2                	sd	a6,120(sp)
    800067e2:	e146                	sd	a7,128(sp)
    800067e4:	e54a                	sd	s2,136(sp)
    800067e6:	e94e                	sd	s3,144(sp)
    800067e8:	ed52                	sd	s4,152(sp)
    800067ea:	f156                	sd	s5,160(sp)
    800067ec:	f55a                	sd	s6,168(sp)
    800067ee:	f95e                	sd	s7,176(sp)
    800067f0:	fd62                	sd	s8,184(sp)
    800067f2:	e1e6                	sd	s9,192(sp)
    800067f4:	e5ea                	sd	s10,200(sp)
    800067f6:	e9ee                	sd	s11,208(sp)
    800067f8:	edf2                	sd	t3,216(sp)
    800067fa:	f1f6                	sd	t4,224(sp)
    800067fc:	f5fa                	sd	t5,232(sp)
    800067fe:	f9fe                	sd	t6,240(sp)
    80006800:	a59fc0ef          	jal	ra,80003258 <kerneltrap>
    80006804:	6082                	ld	ra,0(sp)
    80006806:	6122                	ld	sp,8(sp)
    80006808:	61c2                	ld	gp,16(sp)
    8000680a:	7282                	ld	t0,32(sp)
    8000680c:	7322                	ld	t1,40(sp)
    8000680e:	73c2                	ld	t2,48(sp)
    80006810:	7462                	ld	s0,56(sp)
    80006812:	6486                	ld	s1,64(sp)
    80006814:	6526                	ld	a0,72(sp)
    80006816:	65c6                	ld	a1,80(sp)
    80006818:	6666                	ld	a2,88(sp)
    8000681a:	7686                	ld	a3,96(sp)
    8000681c:	7726                	ld	a4,104(sp)
    8000681e:	77c6                	ld	a5,112(sp)
    80006820:	7866                	ld	a6,120(sp)
    80006822:	688a                	ld	a7,128(sp)
    80006824:	692a                	ld	s2,136(sp)
    80006826:	69ca                	ld	s3,144(sp)
    80006828:	6a6a                	ld	s4,152(sp)
    8000682a:	7a8a                	ld	s5,160(sp)
    8000682c:	7b2a                	ld	s6,168(sp)
    8000682e:	7bca                	ld	s7,176(sp)
    80006830:	7c6a                	ld	s8,184(sp)
    80006832:	6c8e                	ld	s9,192(sp)
    80006834:	6d2e                	ld	s10,200(sp)
    80006836:	6dce                	ld	s11,208(sp)
    80006838:	6e6e                	ld	t3,216(sp)
    8000683a:	7e8e                	ld	t4,224(sp)
    8000683c:	7f2e                	ld	t5,232(sp)
    8000683e:	7fce                	ld	t6,240(sp)
    80006840:	6111                	addi	sp,sp,256
    80006842:	10200073          	sret
    80006846:	00000013          	nop
    8000684a:	00000013          	nop
    8000684e:	0001                	nop

0000000080006850 <timervec>:
    80006850:	34051573          	csrrw	a0,mscratch,a0
    80006854:	e10c                	sd	a1,0(a0)
    80006856:	e510                	sd	a2,8(a0)
    80006858:	e914                	sd	a3,16(a0)
    8000685a:	6d0c                	ld	a1,24(a0)
    8000685c:	7110                	ld	a2,32(a0)
    8000685e:	6194                	ld	a3,0(a1)
    80006860:	96b2                	add	a3,a3,a2
    80006862:	e194                	sd	a3,0(a1)
    80006864:	4589                	li	a1,2
    80006866:	14459073          	csrw	sip,a1
    8000686a:	6914                	ld	a3,16(a0)
    8000686c:	6510                	ld	a2,8(a0)
    8000686e:	610c                	ld	a1,0(a0)
    80006870:	34051573          	csrrw	a0,mscratch,a0
    80006874:	30200073          	mret
	...

000000008000687a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000687a:	1141                	addi	sp,sp,-16
    8000687c:	e422                	sd	s0,8(sp)
    8000687e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006880:	0c0007b7          	lui	a5,0xc000
    80006884:	4705                	li	a4,1
    80006886:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006888:	c3d8                	sw	a4,4(a5)
}
    8000688a:	6422                	ld	s0,8(sp)
    8000688c:	0141                	addi	sp,sp,16
    8000688e:	8082                	ret

0000000080006890 <plicinithart>:

void
plicinithart(void)
{
    80006890:	1141                	addi	sp,sp,-16
    80006892:	e406                	sd	ra,8(sp)
    80006894:	e022                	sd	s0,0(sp)
    80006896:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006898:	ffffb097          	auipc	ra,0xffffb
    8000689c:	4a4080e7          	jalr	1188(ra) # 80001d3c <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800068a0:	0085171b          	slliw	a4,a0,0x8
    800068a4:	0c0027b7          	lui	a5,0xc002
    800068a8:	97ba                	add	a5,a5,a4
    800068aa:	40200713          	li	a4,1026
    800068ae:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800068b2:	00d5151b          	slliw	a0,a0,0xd
    800068b6:	0c2017b7          	lui	a5,0xc201
    800068ba:	953e                	add	a0,a0,a5
    800068bc:	00052023          	sw	zero,0(a0)
}
    800068c0:	60a2                	ld	ra,8(sp)
    800068c2:	6402                	ld	s0,0(sp)
    800068c4:	0141                	addi	sp,sp,16
    800068c6:	8082                	ret

00000000800068c8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800068c8:	1141                	addi	sp,sp,-16
    800068ca:	e406                	sd	ra,8(sp)
    800068cc:	e022                	sd	s0,0(sp)
    800068ce:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800068d0:	ffffb097          	auipc	ra,0xffffb
    800068d4:	46c080e7          	jalr	1132(ra) # 80001d3c <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800068d8:	00d5179b          	slliw	a5,a0,0xd
    800068dc:	0c201537          	lui	a0,0xc201
    800068e0:	953e                	add	a0,a0,a5
  return irq;
}
    800068e2:	4148                	lw	a0,4(a0)
    800068e4:	60a2                	ld	ra,8(sp)
    800068e6:	6402                	ld	s0,0(sp)
    800068e8:	0141                	addi	sp,sp,16
    800068ea:	8082                	ret

00000000800068ec <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800068ec:	1101                	addi	sp,sp,-32
    800068ee:	ec06                	sd	ra,24(sp)
    800068f0:	e822                	sd	s0,16(sp)
    800068f2:	e426                	sd	s1,8(sp)
    800068f4:	1000                	addi	s0,sp,32
    800068f6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800068f8:	ffffb097          	auipc	ra,0xffffb
    800068fc:	444080e7          	jalr	1092(ra) # 80001d3c <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006900:	00d5151b          	slliw	a0,a0,0xd
    80006904:	0c2017b7          	lui	a5,0xc201
    80006908:	97aa                	add	a5,a5,a0
    8000690a:	c3c4                	sw	s1,4(a5)
}
    8000690c:	60e2                	ld	ra,24(sp)
    8000690e:	6442                	ld	s0,16(sp)
    80006910:	64a2                	ld	s1,8(sp)
    80006912:	6105                	addi	sp,sp,32
    80006914:	8082                	ret

0000000080006916 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006916:	1141                	addi	sp,sp,-16
    80006918:	e406                	sd	ra,8(sp)
    8000691a:	e022                	sd	s0,0(sp)
    8000691c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000691e:	479d                	li	a5,7
    80006920:	04a7cc63          	blt	a5,a0,80006978 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006924:	0023e797          	auipc	a5,0x23e
    80006928:	86478793          	addi	a5,a5,-1948 # 80244188 <disk>
    8000692c:	97aa                	add	a5,a5,a0
    8000692e:	0187c783          	lbu	a5,24(a5)
    80006932:	ebb9                	bnez	a5,80006988 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006934:	00451613          	slli	a2,a0,0x4
    80006938:	0023e797          	auipc	a5,0x23e
    8000693c:	85078793          	addi	a5,a5,-1968 # 80244188 <disk>
    80006940:	6394                	ld	a3,0(a5)
    80006942:	96b2                	add	a3,a3,a2
    80006944:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006948:	6398                	ld	a4,0(a5)
    8000694a:	9732                	add	a4,a4,a2
    8000694c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006950:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006954:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006958:	953e                	add	a0,a0,a5
    8000695a:	4785                	li	a5,1
    8000695c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80006960:	0023e517          	auipc	a0,0x23e
    80006964:	84050513          	addi	a0,a0,-1984 # 802441a0 <disk+0x18>
    80006968:	ffffc097          	auipc	ra,0xffffc
    8000696c:	ffa080e7          	jalr	-6(ra) # 80002962 <wakeup>
}
    80006970:	60a2                	ld	ra,8(sp)
    80006972:	6402                	ld	s0,0(sp)
    80006974:	0141                	addi	sp,sp,16
    80006976:	8082                	ret
    panic("free_desc 1");
    80006978:	00002517          	auipc	a0,0x2
    8000697c:	f5850513          	addi	a0,a0,-168 # 800088d0 <syscalls+0x318>
    80006980:	ffffa097          	auipc	ra,0xffffa
    80006984:	bc4080e7          	jalr	-1084(ra) # 80000544 <panic>
    panic("free_desc 2");
    80006988:	00002517          	auipc	a0,0x2
    8000698c:	f5850513          	addi	a0,a0,-168 # 800088e0 <syscalls+0x328>
    80006990:	ffffa097          	auipc	ra,0xffffa
    80006994:	bb4080e7          	jalr	-1100(ra) # 80000544 <panic>

0000000080006998 <virtio_disk_init>:
{
    80006998:	1101                	addi	sp,sp,-32
    8000699a:	ec06                	sd	ra,24(sp)
    8000699c:	e822                	sd	s0,16(sp)
    8000699e:	e426                	sd	s1,8(sp)
    800069a0:	e04a                	sd	s2,0(sp)
    800069a2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800069a4:	00002597          	auipc	a1,0x2
    800069a8:	f4c58593          	addi	a1,a1,-180 # 800088f0 <syscalls+0x338>
    800069ac:	0023e517          	auipc	a0,0x23e
    800069b0:	90450513          	addi	a0,a0,-1788 # 802442b0 <disk+0x128>
    800069b4:	ffffa097          	auipc	ra,0xffffa
    800069b8:	364080e7          	jalr	868(ra) # 80000d18 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800069bc:	100017b7          	lui	a5,0x10001
    800069c0:	4398                	lw	a4,0(a5)
    800069c2:	2701                	sext.w	a4,a4
    800069c4:	747277b7          	lui	a5,0x74727
    800069c8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800069cc:	14f71e63          	bne	a4,a5,80006b28 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800069d0:	100017b7          	lui	a5,0x10001
    800069d4:	43dc                	lw	a5,4(a5)
    800069d6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800069d8:	4709                	li	a4,2
    800069da:	14e79763          	bne	a5,a4,80006b28 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800069de:	100017b7          	lui	a5,0x10001
    800069e2:	479c                	lw	a5,8(a5)
    800069e4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800069e6:	14e79163          	bne	a5,a4,80006b28 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800069ea:	100017b7          	lui	a5,0x10001
    800069ee:	47d8                	lw	a4,12(a5)
    800069f0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800069f2:	554d47b7          	lui	a5,0x554d4
    800069f6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800069fa:	12f71763          	bne	a4,a5,80006b28 <virtio_disk_init+0x190>
  *R(VIRTIO_MMIO_STATUS) = status;
    800069fe:	100017b7          	lui	a5,0x10001
    80006a02:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006a06:	4705                	li	a4,1
    80006a08:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006a0a:	470d                	li	a4,3
    80006a0c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006a0e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006a10:	c7ffe737          	lui	a4,0xc7ffe
    80006a14:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47dba497>
    80006a18:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006a1a:	2701                	sext.w	a4,a4
    80006a1c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006a1e:	472d                	li	a4,11
    80006a20:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006a22:	0707a903          	lw	s2,112(a5)
    80006a26:	2901                	sext.w	s2,s2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006a28:	00897793          	andi	a5,s2,8
    80006a2c:	10078663          	beqz	a5,80006b38 <virtio_disk_init+0x1a0>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006a30:	100017b7          	lui	a5,0x10001
    80006a34:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006a38:	43fc                	lw	a5,68(a5)
    80006a3a:	2781                	sext.w	a5,a5
    80006a3c:	10079663          	bnez	a5,80006b48 <virtio_disk_init+0x1b0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006a40:	100017b7          	lui	a5,0x10001
    80006a44:	5bdc                	lw	a5,52(a5)
    80006a46:	2781                	sext.w	a5,a5
  if(max == 0)
    80006a48:	10078863          	beqz	a5,80006b58 <virtio_disk_init+0x1c0>
  if(max < NUM)
    80006a4c:	471d                	li	a4,7
    80006a4e:	10f77d63          	bgeu	a4,a5,80006b68 <virtio_disk_init+0x1d0>
  disk.desc = kalloc();
    80006a52:	ffffa097          	auipc	ra,0xffffa
    80006a56:	222080e7          	jalr	546(ra) # 80000c74 <kalloc>
    80006a5a:	0023d497          	auipc	s1,0x23d
    80006a5e:	72e48493          	addi	s1,s1,1838 # 80244188 <disk>
    80006a62:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006a64:	ffffa097          	auipc	ra,0xffffa
    80006a68:	210080e7          	jalr	528(ra) # 80000c74 <kalloc>
    80006a6c:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80006a6e:	ffffa097          	auipc	ra,0xffffa
    80006a72:	206080e7          	jalr	518(ra) # 80000c74 <kalloc>
    80006a76:	87aa                	mv	a5,a0
    80006a78:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006a7a:	6088                	ld	a0,0(s1)
    80006a7c:	cd75                	beqz	a0,80006b78 <virtio_disk_init+0x1e0>
    80006a7e:	0023d717          	auipc	a4,0x23d
    80006a82:	71273703          	ld	a4,1810(a4) # 80244190 <disk+0x8>
    80006a86:	cb6d                	beqz	a4,80006b78 <virtio_disk_init+0x1e0>
    80006a88:	cbe5                	beqz	a5,80006b78 <virtio_disk_init+0x1e0>
  memset(disk.desc, 0, PGSIZE);
    80006a8a:	6605                	lui	a2,0x1
    80006a8c:	4581                	li	a1,0
    80006a8e:	ffffa097          	auipc	ra,0xffffa
    80006a92:	416080e7          	jalr	1046(ra) # 80000ea4 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006a96:	0023d497          	auipc	s1,0x23d
    80006a9a:	6f248493          	addi	s1,s1,1778 # 80244188 <disk>
    80006a9e:	6605                	lui	a2,0x1
    80006aa0:	4581                	li	a1,0
    80006aa2:	6488                	ld	a0,8(s1)
    80006aa4:	ffffa097          	auipc	ra,0xffffa
    80006aa8:	400080e7          	jalr	1024(ra) # 80000ea4 <memset>
  memset(disk.used, 0, PGSIZE);
    80006aac:	6605                	lui	a2,0x1
    80006aae:	4581                	li	a1,0
    80006ab0:	6888                	ld	a0,16(s1)
    80006ab2:	ffffa097          	auipc	ra,0xffffa
    80006ab6:	3f2080e7          	jalr	1010(ra) # 80000ea4 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006aba:	100017b7          	lui	a5,0x10001
    80006abe:	4721                	li	a4,8
    80006ac0:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006ac2:	4098                	lw	a4,0(s1)
    80006ac4:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006ac8:	40d8                	lw	a4,4(s1)
    80006aca:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80006ace:	6498                	ld	a4,8(s1)
    80006ad0:	0007069b          	sext.w	a3,a4
    80006ad4:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006ad8:	9701                	srai	a4,a4,0x20
    80006ada:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80006ade:	6898                	ld	a4,16(s1)
    80006ae0:	0007069b          	sext.w	a3,a4
    80006ae4:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006ae8:	9701                	srai	a4,a4,0x20
    80006aea:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80006aee:	4685                	li	a3,1
    80006af0:	c3f4                	sw	a3,68(a5)
    disk.free[i] = 1;
    80006af2:	4705                	li	a4,1
    80006af4:	00d48c23          	sb	a3,24(s1)
    80006af8:	00e48ca3          	sb	a4,25(s1)
    80006afc:	00e48d23          	sb	a4,26(s1)
    80006b00:	00e48da3          	sb	a4,27(s1)
    80006b04:	00e48e23          	sb	a4,28(s1)
    80006b08:	00e48ea3          	sb	a4,29(s1)
    80006b0c:	00e48f23          	sb	a4,30(s1)
    80006b10:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006b14:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006b18:	0727a823          	sw	s2,112(a5)
}
    80006b1c:	60e2                	ld	ra,24(sp)
    80006b1e:	6442                	ld	s0,16(sp)
    80006b20:	64a2                	ld	s1,8(sp)
    80006b22:	6902                	ld	s2,0(sp)
    80006b24:	6105                	addi	sp,sp,32
    80006b26:	8082                	ret
    panic("could not find virtio disk");
    80006b28:	00002517          	auipc	a0,0x2
    80006b2c:	dd850513          	addi	a0,a0,-552 # 80008900 <syscalls+0x348>
    80006b30:	ffffa097          	auipc	ra,0xffffa
    80006b34:	a14080e7          	jalr	-1516(ra) # 80000544 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006b38:	00002517          	auipc	a0,0x2
    80006b3c:	de850513          	addi	a0,a0,-536 # 80008920 <syscalls+0x368>
    80006b40:	ffffa097          	auipc	ra,0xffffa
    80006b44:	a04080e7          	jalr	-1532(ra) # 80000544 <panic>
    panic("virtio disk should not be ready");
    80006b48:	00002517          	auipc	a0,0x2
    80006b4c:	df850513          	addi	a0,a0,-520 # 80008940 <syscalls+0x388>
    80006b50:	ffffa097          	auipc	ra,0xffffa
    80006b54:	9f4080e7          	jalr	-1548(ra) # 80000544 <panic>
    panic("virtio disk has no queue 0");
    80006b58:	00002517          	auipc	a0,0x2
    80006b5c:	e0850513          	addi	a0,a0,-504 # 80008960 <syscalls+0x3a8>
    80006b60:	ffffa097          	auipc	ra,0xffffa
    80006b64:	9e4080e7          	jalr	-1564(ra) # 80000544 <panic>
    panic("virtio disk max queue too short");
    80006b68:	00002517          	auipc	a0,0x2
    80006b6c:	e1850513          	addi	a0,a0,-488 # 80008980 <syscalls+0x3c8>
    80006b70:	ffffa097          	auipc	ra,0xffffa
    80006b74:	9d4080e7          	jalr	-1580(ra) # 80000544 <panic>
    panic("virtio disk kalloc");
    80006b78:	00002517          	auipc	a0,0x2
    80006b7c:	e2850513          	addi	a0,a0,-472 # 800089a0 <syscalls+0x3e8>
    80006b80:	ffffa097          	auipc	ra,0xffffa
    80006b84:	9c4080e7          	jalr	-1596(ra) # 80000544 <panic>

0000000080006b88 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006b88:	7159                	addi	sp,sp,-112
    80006b8a:	f486                	sd	ra,104(sp)
    80006b8c:	f0a2                	sd	s0,96(sp)
    80006b8e:	eca6                	sd	s1,88(sp)
    80006b90:	e8ca                	sd	s2,80(sp)
    80006b92:	e4ce                	sd	s3,72(sp)
    80006b94:	e0d2                	sd	s4,64(sp)
    80006b96:	fc56                	sd	s5,56(sp)
    80006b98:	f85a                	sd	s6,48(sp)
    80006b9a:	f45e                	sd	s7,40(sp)
    80006b9c:	f062                	sd	s8,32(sp)
    80006b9e:	ec66                	sd	s9,24(sp)
    80006ba0:	e86a                	sd	s10,16(sp)
    80006ba2:	1880                	addi	s0,sp,112
    80006ba4:	892a                	mv	s2,a0
    80006ba6:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006ba8:	00c52c83          	lw	s9,12(a0)
    80006bac:	001c9c9b          	slliw	s9,s9,0x1
    80006bb0:	1c82                	slli	s9,s9,0x20
    80006bb2:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006bb6:	0023d517          	auipc	a0,0x23d
    80006bba:	6fa50513          	addi	a0,a0,1786 # 802442b0 <disk+0x128>
    80006bbe:	ffffa097          	auipc	ra,0xffffa
    80006bc2:	1ea080e7          	jalr	490(ra) # 80000da8 <acquire>
  for(int i = 0; i < 3; i++){
    80006bc6:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006bc8:	4ba1                	li	s7,8
      disk.free[i] = 0;
    80006bca:	0023db17          	auipc	s6,0x23d
    80006bce:	5beb0b13          	addi	s6,s6,1470 # 80244188 <disk>
  for(int i = 0; i < 3; i++){
    80006bd2:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80006bd4:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006bd6:	0023dc17          	auipc	s8,0x23d
    80006bda:	6dac0c13          	addi	s8,s8,1754 # 802442b0 <disk+0x128>
    80006bde:	a8b5                	j	80006c5a <virtio_disk_rw+0xd2>
      disk.free[i] = 0;
    80006be0:	00fb06b3          	add	a3,s6,a5
    80006be4:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006be8:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80006bea:	0207c563          	bltz	a5,80006c14 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    80006bee:	2485                	addiw	s1,s1,1
    80006bf0:	0711                	addi	a4,a4,4
    80006bf2:	1f548a63          	beq	s1,s5,80006de6 <virtio_disk_rw+0x25e>
    idx[i] = alloc_desc();
    80006bf6:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80006bf8:	0023d697          	auipc	a3,0x23d
    80006bfc:	59068693          	addi	a3,a3,1424 # 80244188 <disk>
    80006c00:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80006c02:	0186c583          	lbu	a1,24(a3)
    80006c06:	fde9                	bnez	a1,80006be0 <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006c08:	2785                	addiw	a5,a5,1
    80006c0a:	0685                	addi	a3,a3,1
    80006c0c:	ff779be3          	bne	a5,s7,80006c02 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    80006c10:	57fd                	li	a5,-1
    80006c12:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80006c14:	02905a63          	blez	s1,80006c48 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    80006c18:	f9042503          	lw	a0,-112(s0)
    80006c1c:	00000097          	auipc	ra,0x0
    80006c20:	cfa080e7          	jalr	-774(ra) # 80006916 <free_desc>
      for(int j = 0; j < i; j++)
    80006c24:	4785                	li	a5,1
    80006c26:	0297d163          	bge	a5,s1,80006c48 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    80006c2a:	f9442503          	lw	a0,-108(s0)
    80006c2e:	00000097          	auipc	ra,0x0
    80006c32:	ce8080e7          	jalr	-792(ra) # 80006916 <free_desc>
      for(int j = 0; j < i; j++)
    80006c36:	4789                	li	a5,2
    80006c38:	0097d863          	bge	a5,s1,80006c48 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    80006c3c:	f9842503          	lw	a0,-104(s0)
    80006c40:	00000097          	auipc	ra,0x0
    80006c44:	cd6080e7          	jalr	-810(ra) # 80006916 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006c48:	85e2                	mv	a1,s8
    80006c4a:	0023d517          	auipc	a0,0x23d
    80006c4e:	55650513          	addi	a0,a0,1366 # 802441a0 <disk+0x18>
    80006c52:	ffffc097          	auipc	ra,0xffffc
    80006c56:	a12080e7          	jalr	-1518(ra) # 80002664 <sleep>
  for(int i = 0; i < 3; i++){
    80006c5a:	f9040713          	addi	a4,s0,-112
    80006c5e:	84ce                	mv	s1,s3
    80006c60:	bf59                	j	80006bf6 <virtio_disk_rw+0x6e>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80006c62:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    80006c66:	00479693          	slli	a3,a5,0x4
    80006c6a:	0023d797          	auipc	a5,0x23d
    80006c6e:	51e78793          	addi	a5,a5,1310 # 80244188 <disk>
    80006c72:	97b6                	add	a5,a5,a3
    80006c74:	4685                	li	a3,1
    80006c76:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006c78:	0023d597          	auipc	a1,0x23d
    80006c7c:	51058593          	addi	a1,a1,1296 # 80244188 <disk>
    80006c80:	00a60793          	addi	a5,a2,10
    80006c84:	0792                	slli	a5,a5,0x4
    80006c86:	97ae                	add	a5,a5,a1
    80006c88:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    80006c8c:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006c90:	f6070693          	addi	a3,a4,-160
    80006c94:	619c                	ld	a5,0(a1)
    80006c96:	97b6                	add	a5,a5,a3
    80006c98:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006c9a:	6188                	ld	a0,0(a1)
    80006c9c:	96aa                	add	a3,a3,a0
    80006c9e:	47c1                	li	a5,16
    80006ca0:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006ca2:	4785                	li	a5,1
    80006ca4:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006ca8:	f9442783          	lw	a5,-108(s0)
    80006cac:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006cb0:	0792                	slli	a5,a5,0x4
    80006cb2:	953e                	add	a0,a0,a5
    80006cb4:	05890693          	addi	a3,s2,88
    80006cb8:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    80006cba:	6188                	ld	a0,0(a1)
    80006cbc:	97aa                	add	a5,a5,a0
    80006cbe:	40000693          	li	a3,1024
    80006cc2:	c794                	sw	a3,8(a5)
  if(write)
    80006cc4:	100d0d63          	beqz	s10,80006dde <virtio_disk_rw+0x256>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006cc8:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006ccc:	00c7d683          	lhu	a3,12(a5)
    80006cd0:	0016e693          	ori	a3,a3,1
    80006cd4:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    80006cd8:	f9842583          	lw	a1,-104(s0)
    80006cdc:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006ce0:	0023d697          	auipc	a3,0x23d
    80006ce4:	4a868693          	addi	a3,a3,1192 # 80244188 <disk>
    80006ce8:	00260793          	addi	a5,a2,2
    80006cec:	0792                	slli	a5,a5,0x4
    80006cee:	97b6                	add	a5,a5,a3
    80006cf0:	587d                	li	a6,-1
    80006cf2:	01078823          	sb	a6,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006cf6:	0592                	slli	a1,a1,0x4
    80006cf8:	952e                	add	a0,a0,a1
    80006cfa:	f9070713          	addi	a4,a4,-112
    80006cfe:	9736                	add	a4,a4,a3
    80006d00:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    80006d02:	6298                	ld	a4,0(a3)
    80006d04:	972e                	add	a4,a4,a1
    80006d06:	4585                	li	a1,1
    80006d08:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006d0a:	4509                	li	a0,2
    80006d0c:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    80006d10:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006d14:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    80006d18:	0127b423          	sd	s2,8(a5)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006d1c:	6698                	ld	a4,8(a3)
    80006d1e:	00275783          	lhu	a5,2(a4)
    80006d22:	8b9d                	andi	a5,a5,7
    80006d24:	0786                	slli	a5,a5,0x1
    80006d26:	97ba                	add	a5,a5,a4
    80006d28:	00c79223          	sh	a2,4(a5)

  __sync_synchronize();
    80006d2c:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006d30:	6698                	ld	a4,8(a3)
    80006d32:	00275783          	lhu	a5,2(a4)
    80006d36:	2785                	addiw	a5,a5,1
    80006d38:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006d3c:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006d40:	100017b7          	lui	a5,0x10001
    80006d44:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006d48:	00492703          	lw	a4,4(s2)
    80006d4c:	4785                	li	a5,1
    80006d4e:	02f71163          	bne	a4,a5,80006d70 <virtio_disk_rw+0x1e8>
    sleep(b, &disk.vdisk_lock);
    80006d52:	0023d997          	auipc	s3,0x23d
    80006d56:	55e98993          	addi	s3,s3,1374 # 802442b0 <disk+0x128>
  while(b->disk == 1) {
    80006d5a:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006d5c:	85ce                	mv	a1,s3
    80006d5e:	854a                	mv	a0,s2
    80006d60:	ffffc097          	auipc	ra,0xffffc
    80006d64:	904080e7          	jalr	-1788(ra) # 80002664 <sleep>
  while(b->disk == 1) {
    80006d68:	00492783          	lw	a5,4(s2)
    80006d6c:	fe9788e3          	beq	a5,s1,80006d5c <virtio_disk_rw+0x1d4>
  }

  disk.info[idx[0]].b = 0;
    80006d70:	f9042903          	lw	s2,-112(s0)
    80006d74:	00290793          	addi	a5,s2,2
    80006d78:	00479713          	slli	a4,a5,0x4
    80006d7c:	0023d797          	auipc	a5,0x23d
    80006d80:	40c78793          	addi	a5,a5,1036 # 80244188 <disk>
    80006d84:	97ba                	add	a5,a5,a4
    80006d86:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006d8a:	0023d997          	auipc	s3,0x23d
    80006d8e:	3fe98993          	addi	s3,s3,1022 # 80244188 <disk>
    80006d92:	00491713          	slli	a4,s2,0x4
    80006d96:	0009b783          	ld	a5,0(s3)
    80006d9a:	97ba                	add	a5,a5,a4
    80006d9c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006da0:	854a                	mv	a0,s2
    80006da2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006da6:	00000097          	auipc	ra,0x0
    80006daa:	b70080e7          	jalr	-1168(ra) # 80006916 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006dae:	8885                	andi	s1,s1,1
    80006db0:	f0ed                	bnez	s1,80006d92 <virtio_disk_rw+0x20a>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006db2:	0023d517          	auipc	a0,0x23d
    80006db6:	4fe50513          	addi	a0,a0,1278 # 802442b0 <disk+0x128>
    80006dba:	ffffa097          	auipc	ra,0xffffa
    80006dbe:	0a2080e7          	jalr	162(ra) # 80000e5c <release>
}
    80006dc2:	70a6                	ld	ra,104(sp)
    80006dc4:	7406                	ld	s0,96(sp)
    80006dc6:	64e6                	ld	s1,88(sp)
    80006dc8:	6946                	ld	s2,80(sp)
    80006dca:	69a6                	ld	s3,72(sp)
    80006dcc:	6a06                	ld	s4,64(sp)
    80006dce:	7ae2                	ld	s5,56(sp)
    80006dd0:	7b42                	ld	s6,48(sp)
    80006dd2:	7ba2                	ld	s7,40(sp)
    80006dd4:	7c02                	ld	s8,32(sp)
    80006dd6:	6ce2                	ld	s9,24(sp)
    80006dd8:	6d42                	ld	s10,16(sp)
    80006dda:	6165                	addi	sp,sp,112
    80006ddc:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006dde:	4689                	li	a3,2
    80006de0:	00d79623          	sh	a3,12(a5)
    80006de4:	b5e5                	j	80006ccc <virtio_disk_rw+0x144>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006de6:	f9042603          	lw	a2,-112(s0)
    80006dea:	00a60713          	addi	a4,a2,10
    80006dee:	0712                	slli	a4,a4,0x4
    80006df0:	0023d517          	auipc	a0,0x23d
    80006df4:	3a050513          	addi	a0,a0,928 # 80244190 <disk+0x8>
    80006df8:	953a                	add	a0,a0,a4
  if(write)
    80006dfa:	e60d14e3          	bnez	s10,80006c62 <virtio_disk_rw+0xda>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    80006dfe:	00a60793          	addi	a5,a2,10
    80006e02:	00479693          	slli	a3,a5,0x4
    80006e06:	0023d797          	auipc	a5,0x23d
    80006e0a:	38278793          	addi	a5,a5,898 # 80244188 <disk>
    80006e0e:	97b6                	add	a5,a5,a3
    80006e10:	0007a423          	sw	zero,8(a5)
    80006e14:	b595                	j	80006c78 <virtio_disk_rw+0xf0>

0000000080006e16 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006e16:	1101                	addi	sp,sp,-32
    80006e18:	ec06                	sd	ra,24(sp)
    80006e1a:	e822                	sd	s0,16(sp)
    80006e1c:	e426                	sd	s1,8(sp)
    80006e1e:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006e20:	0023d497          	auipc	s1,0x23d
    80006e24:	36848493          	addi	s1,s1,872 # 80244188 <disk>
    80006e28:	0023d517          	auipc	a0,0x23d
    80006e2c:	48850513          	addi	a0,a0,1160 # 802442b0 <disk+0x128>
    80006e30:	ffffa097          	auipc	ra,0xffffa
    80006e34:	f78080e7          	jalr	-136(ra) # 80000da8 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006e38:	10001737          	lui	a4,0x10001
    80006e3c:	533c                	lw	a5,96(a4)
    80006e3e:	8b8d                	andi	a5,a5,3
    80006e40:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006e42:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006e46:	689c                	ld	a5,16(s1)
    80006e48:	0204d703          	lhu	a4,32(s1)
    80006e4c:	0027d783          	lhu	a5,2(a5)
    80006e50:	04f70863          	beq	a4,a5,80006ea0 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006e54:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006e58:	6898                	ld	a4,16(s1)
    80006e5a:	0204d783          	lhu	a5,32(s1)
    80006e5e:	8b9d                	andi	a5,a5,7
    80006e60:	078e                	slli	a5,a5,0x3
    80006e62:	97ba                	add	a5,a5,a4
    80006e64:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006e66:	00278713          	addi	a4,a5,2
    80006e6a:	0712                	slli	a4,a4,0x4
    80006e6c:	9726                	add	a4,a4,s1
    80006e6e:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006e72:	e721                	bnez	a4,80006eba <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006e74:	0789                	addi	a5,a5,2
    80006e76:	0792                	slli	a5,a5,0x4
    80006e78:	97a6                	add	a5,a5,s1
    80006e7a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006e7c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006e80:	ffffc097          	auipc	ra,0xffffc
    80006e84:	ae2080e7          	jalr	-1310(ra) # 80002962 <wakeup>

    disk.used_idx += 1;
    80006e88:	0204d783          	lhu	a5,32(s1)
    80006e8c:	2785                	addiw	a5,a5,1
    80006e8e:	17c2                	slli	a5,a5,0x30
    80006e90:	93c1                	srli	a5,a5,0x30
    80006e92:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006e96:	6898                	ld	a4,16(s1)
    80006e98:	00275703          	lhu	a4,2(a4)
    80006e9c:	faf71ce3          	bne	a4,a5,80006e54 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006ea0:	0023d517          	auipc	a0,0x23d
    80006ea4:	41050513          	addi	a0,a0,1040 # 802442b0 <disk+0x128>
    80006ea8:	ffffa097          	auipc	ra,0xffffa
    80006eac:	fb4080e7          	jalr	-76(ra) # 80000e5c <release>
}
    80006eb0:	60e2                	ld	ra,24(sp)
    80006eb2:	6442                	ld	s0,16(sp)
    80006eb4:	64a2                	ld	s1,8(sp)
    80006eb6:	6105                	addi	sp,sp,32
    80006eb8:	8082                	ret
      panic("virtio_disk_intr status");
    80006eba:	00002517          	auipc	a0,0x2
    80006ebe:	afe50513          	addi	a0,a0,-1282 # 800089b8 <syscalls+0x400>
    80006ec2:	ffff9097          	auipc	ra,0xffff9
    80006ec6:	682080e7          	jalr	1666(ra) # 80000544 <panic>
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
