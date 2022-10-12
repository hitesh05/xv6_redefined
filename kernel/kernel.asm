
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	b9013103          	ld	sp,-1136(sp) # 80008b90 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000056:	b9e70713          	addi	a4,a4,-1122 # 80008bf0 <timer_scratch>
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
    80000068:	1cc78793          	addi	a5,a5,460 # 80006230 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdad9f>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	de678793          	addi	a5,a5,-538 # 80000e94 <main>
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
    8000012c:	00002097          	auipc	ra,0x2
    80000130:	766080e7          	jalr	1894(ra) # 80002892 <either_copyin>
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
    80000190:	ba450513          	addi	a0,a0,-1116 # 80010d30 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	a56080e7          	jalr	-1450(ra) # 80000bea <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019c:	00011497          	auipc	s1,0x11
    800001a0:	b9448493          	addi	s1,s1,-1132 # 80010d30 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a4:	89a6                	mv	s3,s1
    800001a6:	00011917          	auipc	s2,0x11
    800001aa:	c2290913          	addi	s2,s2,-990 # 80010dc8 <cons+0x98>
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
    800001c8:	90c080e7          	jalr	-1780(ra) # 80001ad0 <myproc>
    800001cc:	00002097          	auipc	ra,0x2
    800001d0:	4f8080e7          	jalr	1272(ra) # 800026c4 <killed>
    800001d4:	e535                	bnez	a0,80000240 <consoleread+0xdc>
      sleep(&cons.r, &cons.lock);
    800001d6:	85ce                	mv	a1,s3
    800001d8:	854a                	mv	a0,s2
    800001da:	00002097          	auipc	ra,0x2
    800001de:	066080e7          	jalr	102(ra) # 80002240 <sleep>
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
    8000021a:	626080e7          	jalr	1574(ra) # 8000283c <either_copyout>
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
    8000022e:	b0650513          	addi	a0,a0,-1274 # 80010d30 <cons>
    80000232:	00001097          	auipc	ra,0x1
    80000236:	a6c080e7          	jalr	-1428(ra) # 80000c9e <release>

  return target - n;
    8000023a:	414b853b          	subw	a0,s7,s4
    8000023e:	a811                	j	80000252 <consoleread+0xee>
        release(&cons.lock);
    80000240:	00011517          	auipc	a0,0x11
    80000244:	af050513          	addi	a0,a0,-1296 # 80010d30 <cons>
    80000248:	00001097          	auipc	ra,0x1
    8000024c:	a56080e7          	jalr	-1450(ra) # 80000c9e <release>
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
    8000027c:	b4f72823          	sw	a5,-1200(a4) # 80010dc8 <cons+0x98>
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
    800002d6:	a5e50513          	addi	a0,a0,-1442 # 80010d30 <cons>
    800002da:	00001097          	auipc	ra,0x1
    800002de:	910080e7          	jalr	-1776(ra) # 80000bea <acquire>

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
    800002fc:	5f0080e7          	jalr	1520(ra) # 800028e8 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000300:	00011517          	auipc	a0,0x11
    80000304:	a3050513          	addi	a0,a0,-1488 # 80010d30 <cons>
    80000308:	00001097          	auipc	ra,0x1
    8000030c:	996080e7          	jalr	-1642(ra) # 80000c9e <release>
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
    80000328:	a0c70713          	addi	a4,a4,-1524 # 80010d30 <cons>
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
    80000352:	9e278793          	addi	a5,a5,-1566 # 80010d30 <cons>
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
    80000380:	a4c7a783          	lw	a5,-1460(a5) # 80010dc8 <cons+0x98>
    80000384:	9f1d                	subw	a4,a4,a5
    80000386:	08000793          	li	a5,128
    8000038a:	f6f71be3          	bne	a4,a5,80000300 <consoleintr+0x3c>
    8000038e:	a07d                	j	8000043c <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000390:	00011717          	auipc	a4,0x11
    80000394:	9a070713          	addi	a4,a4,-1632 # 80010d30 <cons>
    80000398:	0a072783          	lw	a5,160(a4)
    8000039c:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a0:	00011497          	auipc	s1,0x11
    800003a4:	99048493          	addi	s1,s1,-1648 # 80010d30 <cons>
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
    800003e0:	95470713          	addi	a4,a4,-1708 # 80010d30 <cons>
    800003e4:	0a072783          	lw	a5,160(a4)
    800003e8:	09c72703          	lw	a4,156(a4)
    800003ec:	f0f70ae3          	beq	a4,a5,80000300 <consoleintr+0x3c>
      cons.e--;
    800003f0:	37fd                	addiw	a5,a5,-1
    800003f2:	00011717          	auipc	a4,0x11
    800003f6:	9cf72f23          	sw	a5,-1570(a4) # 80010dd0 <cons+0xa0>
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
    8000041c:	91878793          	addi	a5,a5,-1768 # 80010d30 <cons>
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
    80000440:	98c7a823          	sw	a2,-1648(a5) # 80010dcc <cons+0x9c>
        wakeup(&cons.r);
    80000444:	00011517          	auipc	a0,0x11
    80000448:	98450513          	addi	a0,a0,-1660 # 80010dc8 <cons+0x98>
    8000044c:	00002097          	auipc	ra,0x2
    80000450:	fd2080e7          	jalr	-46(ra) # 8000241e <wakeup>
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
    8000046a:	8ca50513          	addi	a0,a0,-1846 # 80010d30 <cons>
    8000046e:	00000097          	auipc	ra,0x0
    80000472:	6ec080e7          	jalr	1772(ra) # 80000b5a <initlock>

  uartinit();
    80000476:	00000097          	auipc	ra,0x0
    8000047a:	330080e7          	jalr	816(ra) # 800007a6 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000047e:	00022797          	auipc	a5,0x22
    80000482:	44a78793          	addi	a5,a5,1098 # 800228c8 <devsw>
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
    80000554:	8a07a023          	sw	zero,-1888(a5) # 80010df0 <pr+0x18>
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
    80000576:	d0e50513          	addi	a0,a0,-754 # 80008280 <digits+0x240>
    8000057a:	00000097          	auipc	ra,0x0
    8000057e:	014080e7          	jalr	20(ra) # 8000058e <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000582:	4785                	li	a5,1
    80000584:	00008717          	auipc	a4,0x8
    80000588:	62f72623          	sw	a5,1580(a4) # 80008bb0 <panicked>
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
    800005c4:	830dad83          	lw	s11,-2000(s11) # 80010df0 <pr+0x18>
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
    80000602:	7da50513          	addi	a0,a0,2010 # 80010dd8 <pr>
    80000606:	00000097          	auipc	ra,0x0
    8000060a:	5e4080e7          	jalr	1508(ra) # 80000bea <acquire>
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
    80000766:	67650513          	addi	a0,a0,1654 # 80010dd8 <pr>
    8000076a:	00000097          	auipc	ra,0x0
    8000076e:	534080e7          	jalr	1332(ra) # 80000c9e <release>
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
    80000782:	65a48493          	addi	s1,s1,1626 # 80010dd8 <pr>
    80000786:	00008597          	auipc	a1,0x8
    8000078a:	8b258593          	addi	a1,a1,-1870 # 80008038 <etext+0x38>
    8000078e:	8526                	mv	a0,s1
    80000790:	00000097          	auipc	ra,0x0
    80000794:	3ca080e7          	jalr	970(ra) # 80000b5a <initlock>
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
    800007e2:	61a50513          	addi	a0,a0,1562 # 80010df8 <uart_tx_lock>
    800007e6:	00000097          	auipc	ra,0x0
    800007ea:	374080e7          	jalr	884(ra) # 80000b5a <initlock>
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
    80000806:	39c080e7          	jalr	924(ra) # 80000b9e <push_off>

  if(panicked){
    8000080a:	00008797          	auipc	a5,0x8
    8000080e:	3a67a783          	lw	a5,934(a5) # 80008bb0 <panicked>
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
    80000838:	40a080e7          	jalr	1034(ra) # 80000c3e <pop_off>
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
    8000084a:	37273703          	ld	a4,882(a4) # 80008bb8 <uart_tx_r>
    8000084e:	00008797          	auipc	a5,0x8
    80000852:	3727b783          	ld	a5,882(a5) # 80008bc0 <uart_tx_w>
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
    80000874:	588a0a13          	addi	s4,s4,1416 # 80010df8 <uart_tx_lock>
    uart_tx_r += 1;
    80000878:	00008497          	auipc	s1,0x8
    8000087c:	34048493          	addi	s1,s1,832 # 80008bb8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000880:	00008997          	auipc	s3,0x8
    80000884:	34098993          	addi	s3,s3,832 # 80008bc0 <uart_tx_w>
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
    800008aa:	b78080e7          	jalr	-1160(ra) # 8000241e <wakeup>
    
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
    800008e6:	51650513          	addi	a0,a0,1302 # 80010df8 <uart_tx_lock>
    800008ea:	00000097          	auipc	ra,0x0
    800008ee:	300080e7          	jalr	768(ra) # 80000bea <acquire>
  if(panicked){
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	2be7a783          	lw	a5,702(a5) # 80008bb0 <panicked>
    800008fa:	e7c9                	bnez	a5,80000984 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008fc:	00008797          	auipc	a5,0x8
    80000900:	2c47b783          	ld	a5,708(a5) # 80008bc0 <uart_tx_w>
    80000904:	00008717          	auipc	a4,0x8
    80000908:	2b473703          	ld	a4,692(a4) # 80008bb8 <uart_tx_r>
    8000090c:	02070713          	addi	a4,a4,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000910:	00010a17          	auipc	s4,0x10
    80000914:	4e8a0a13          	addi	s4,s4,1256 # 80010df8 <uart_tx_lock>
    80000918:	00008497          	auipc	s1,0x8
    8000091c:	2a048493          	addi	s1,s1,672 # 80008bb8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000920:	00008917          	auipc	s2,0x8
    80000924:	2a090913          	addi	s2,s2,672 # 80008bc0 <uart_tx_w>
    80000928:	00f71f63          	bne	a4,a5,80000946 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000092c:	85d2                	mv	a1,s4
    8000092e:	8526                	mv	a0,s1
    80000930:	00002097          	auipc	ra,0x2
    80000934:	910080e7          	jalr	-1776(ra) # 80002240 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000938:	00093783          	ld	a5,0(s2)
    8000093c:	6098                	ld	a4,0(s1)
    8000093e:	02070713          	addi	a4,a4,32
    80000942:	fef705e3          	beq	a4,a5,8000092c <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000946:	00010497          	auipc	s1,0x10
    8000094a:	4b248493          	addi	s1,s1,1202 # 80010df8 <uart_tx_lock>
    8000094e:	01f7f713          	andi	a4,a5,31
    80000952:	9726                	add	a4,a4,s1
    80000954:	01370c23          	sb	s3,24(a4)
  uart_tx_w += 1;
    80000958:	0785                	addi	a5,a5,1
    8000095a:	00008717          	auipc	a4,0x8
    8000095e:	26f73323          	sd	a5,614(a4) # 80008bc0 <uart_tx_w>
  uartstart();
    80000962:	00000097          	auipc	ra,0x0
    80000966:	ee4080e7          	jalr	-284(ra) # 80000846 <uartstart>
  release(&uart_tx_lock);
    8000096a:	8526                	mv	a0,s1
    8000096c:	00000097          	auipc	ra,0x0
    80000970:	332080e7          	jalr	818(ra) # 80000c9e <release>
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
    800009d4:	42848493          	addi	s1,s1,1064 # 80010df8 <uart_tx_lock>
    800009d8:	8526                	mv	a0,s1
    800009da:	00000097          	auipc	ra,0x0
    800009de:	210080e7          	jalr	528(ra) # 80000bea <acquire>
  uartstart();
    800009e2:	00000097          	auipc	ra,0x0
    800009e6:	e64080e7          	jalr	-412(ra) # 80000846 <uartstart>
  release(&uart_tx_lock);
    800009ea:	8526                	mv	a0,s1
    800009ec:	00000097          	auipc	ra,0x0
    800009f0:	2b2080e7          	jalr	690(ra) # 80000c9e <release>
}
    800009f4:	60e2                	ld	ra,24(sp)
    800009f6:	6442                	ld	s0,16(sp)
    800009f8:	64a2                	ld	s1,8(sp)
    800009fa:	6105                	addi	sp,sp,32
    800009fc:	8082                	ret

00000000800009fe <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009fe:	1101                	addi	sp,sp,-32
    80000a00:	ec06                	sd	ra,24(sp)
    80000a02:	e822                	sd	s0,16(sp)
    80000a04:	e426                	sd	s1,8(sp)
    80000a06:	e04a                	sd	s2,0(sp)
    80000a08:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a0a:	03451793          	slli	a5,a0,0x34
    80000a0e:	ebb9                	bnez	a5,80000a64 <kfree+0x66>
    80000a10:	84aa                	mv	s1,a0
    80000a12:	00023797          	auipc	a5,0x23
    80000a16:	04e78793          	addi	a5,a5,78 # 80023a60 <end>
    80000a1a:	04f56563          	bltu	a0,a5,80000a64 <kfree+0x66>
    80000a1e:	47c5                	li	a5,17
    80000a20:	07ee                	slli	a5,a5,0x1b
    80000a22:	04f57163          	bgeu	a0,a5,80000a64 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a26:	6605                	lui	a2,0x1
    80000a28:	4585                	li	a1,1
    80000a2a:	00000097          	auipc	ra,0x0
    80000a2e:	2bc080e7          	jalr	700(ra) # 80000ce6 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a32:	00010917          	auipc	s2,0x10
    80000a36:	3fe90913          	addi	s2,s2,1022 # 80010e30 <kmem>
    80000a3a:	854a                	mv	a0,s2
    80000a3c:	00000097          	auipc	ra,0x0
    80000a40:	1ae080e7          	jalr	430(ra) # 80000bea <acquire>
  r->next = kmem.freelist;
    80000a44:	01893783          	ld	a5,24(s2)
    80000a48:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a4a:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a4e:	854a                	mv	a0,s2
    80000a50:	00000097          	auipc	ra,0x0
    80000a54:	24e080e7          	jalr	590(ra) # 80000c9e <release>
}
    80000a58:	60e2                	ld	ra,24(sp)
    80000a5a:	6442                	ld	s0,16(sp)
    80000a5c:	64a2                	ld	s1,8(sp)
    80000a5e:	6902                	ld	s2,0(sp)
    80000a60:	6105                	addi	sp,sp,32
    80000a62:	8082                	ret
    panic("kfree");
    80000a64:	00007517          	auipc	a0,0x7
    80000a68:	5fc50513          	addi	a0,a0,1532 # 80008060 <digits+0x20>
    80000a6c:	00000097          	auipc	ra,0x0
    80000a70:	ad8080e7          	jalr	-1320(ra) # 80000544 <panic>

0000000080000a74 <freerange>:
{
    80000a74:	7179                	addi	sp,sp,-48
    80000a76:	f406                	sd	ra,40(sp)
    80000a78:	f022                	sd	s0,32(sp)
    80000a7a:	ec26                	sd	s1,24(sp)
    80000a7c:	e84a                	sd	s2,16(sp)
    80000a7e:	e44e                	sd	s3,8(sp)
    80000a80:	e052                	sd	s4,0(sp)
    80000a82:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a84:	6785                	lui	a5,0x1
    80000a86:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a8a:	94aa                	add	s1,s1,a0
    80000a8c:	757d                	lui	a0,0xfffff
    80000a8e:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a90:	94be                	add	s1,s1,a5
    80000a92:	0095ee63          	bltu	a1,s1,80000aae <freerange+0x3a>
    80000a96:	892e                	mv	s2,a1
    kfree(p);
    80000a98:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a9a:	6985                	lui	s3,0x1
    kfree(p);
    80000a9c:	01448533          	add	a0,s1,s4
    80000aa0:	00000097          	auipc	ra,0x0
    80000aa4:	f5e080e7          	jalr	-162(ra) # 800009fe <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aa8:	94ce                	add	s1,s1,s3
    80000aaa:	fe9979e3          	bgeu	s2,s1,80000a9c <freerange+0x28>
}
    80000aae:	70a2                	ld	ra,40(sp)
    80000ab0:	7402                	ld	s0,32(sp)
    80000ab2:	64e2                	ld	s1,24(sp)
    80000ab4:	6942                	ld	s2,16(sp)
    80000ab6:	69a2                	ld	s3,8(sp)
    80000ab8:	6a02                	ld	s4,0(sp)
    80000aba:	6145                	addi	sp,sp,48
    80000abc:	8082                	ret

0000000080000abe <kinit>:
{
    80000abe:	1141                	addi	sp,sp,-16
    80000ac0:	e406                	sd	ra,8(sp)
    80000ac2:	e022                	sd	s0,0(sp)
    80000ac4:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ac6:	00007597          	auipc	a1,0x7
    80000aca:	5a258593          	addi	a1,a1,1442 # 80008068 <digits+0x28>
    80000ace:	00010517          	auipc	a0,0x10
    80000ad2:	36250513          	addi	a0,a0,866 # 80010e30 <kmem>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	084080e7          	jalr	132(ra) # 80000b5a <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ade:	45c5                	li	a1,17
    80000ae0:	05ee                	slli	a1,a1,0x1b
    80000ae2:	00023517          	auipc	a0,0x23
    80000ae6:	f7e50513          	addi	a0,a0,-130 # 80023a60 <end>
    80000aea:	00000097          	auipc	ra,0x0
    80000aee:	f8a080e7          	jalr	-118(ra) # 80000a74 <freerange>
}
    80000af2:	60a2                	ld	ra,8(sp)
    80000af4:	6402                	ld	s0,0(sp)
    80000af6:	0141                	addi	sp,sp,16
    80000af8:	8082                	ret

0000000080000afa <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000afa:	1101                	addi	sp,sp,-32
    80000afc:	ec06                	sd	ra,24(sp)
    80000afe:	e822                	sd	s0,16(sp)
    80000b00:	e426                	sd	s1,8(sp)
    80000b02:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b04:	00010497          	auipc	s1,0x10
    80000b08:	32c48493          	addi	s1,s1,812 # 80010e30 <kmem>
    80000b0c:	8526                	mv	a0,s1
    80000b0e:	00000097          	auipc	ra,0x0
    80000b12:	0dc080e7          	jalr	220(ra) # 80000bea <acquire>
  r = kmem.freelist;
    80000b16:	6c84                	ld	s1,24(s1)
  if(r)
    80000b18:	c885                	beqz	s1,80000b48 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b1a:	609c                	ld	a5,0(s1)
    80000b1c:	00010517          	auipc	a0,0x10
    80000b20:	31450513          	addi	a0,a0,788 # 80010e30 <kmem>
    80000b24:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b26:	00000097          	auipc	ra,0x0
    80000b2a:	178080e7          	jalr	376(ra) # 80000c9e <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b2e:	6605                	lui	a2,0x1
    80000b30:	4595                	li	a1,5
    80000b32:	8526                	mv	a0,s1
    80000b34:	00000097          	auipc	ra,0x0
    80000b38:	1b2080e7          	jalr	434(ra) # 80000ce6 <memset>
  return (void*)r;
}
    80000b3c:	8526                	mv	a0,s1
    80000b3e:	60e2                	ld	ra,24(sp)
    80000b40:	6442                	ld	s0,16(sp)
    80000b42:	64a2                	ld	s1,8(sp)
    80000b44:	6105                	addi	sp,sp,32
    80000b46:	8082                	ret
  release(&kmem.lock);
    80000b48:	00010517          	auipc	a0,0x10
    80000b4c:	2e850513          	addi	a0,a0,744 # 80010e30 <kmem>
    80000b50:	00000097          	auipc	ra,0x0
    80000b54:	14e080e7          	jalr	334(ra) # 80000c9e <release>
  if(r)
    80000b58:	b7d5                	j	80000b3c <kalloc+0x42>

0000000080000b5a <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b5a:	1141                	addi	sp,sp,-16
    80000b5c:	e422                	sd	s0,8(sp)
    80000b5e:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b60:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b62:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b66:	00053823          	sd	zero,16(a0)
}
    80000b6a:	6422                	ld	s0,8(sp)
    80000b6c:	0141                	addi	sp,sp,16
    80000b6e:	8082                	ret

0000000080000b70 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b70:	411c                	lw	a5,0(a0)
    80000b72:	e399                	bnez	a5,80000b78 <holding+0x8>
    80000b74:	4501                	li	a0,0
  return r;
}
    80000b76:	8082                	ret
{
    80000b78:	1101                	addi	sp,sp,-32
    80000b7a:	ec06                	sd	ra,24(sp)
    80000b7c:	e822                	sd	s0,16(sp)
    80000b7e:	e426                	sd	s1,8(sp)
    80000b80:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b82:	6904                	ld	s1,16(a0)
    80000b84:	00001097          	auipc	ra,0x1
    80000b88:	f30080e7          	jalr	-208(ra) # 80001ab4 <mycpu>
    80000b8c:	40a48533          	sub	a0,s1,a0
    80000b90:	00153513          	seqz	a0,a0
}
    80000b94:	60e2                	ld	ra,24(sp)
    80000b96:	6442                	ld	s0,16(sp)
    80000b98:	64a2                	ld	s1,8(sp)
    80000b9a:	6105                	addi	sp,sp,32
    80000b9c:	8082                	ret

0000000080000b9e <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b9e:	1101                	addi	sp,sp,-32
    80000ba0:	ec06                	sd	ra,24(sp)
    80000ba2:	e822                	sd	s0,16(sp)
    80000ba4:	e426                	sd	s1,8(sp)
    80000ba6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000ba8:	100024f3          	csrr	s1,sstatus
    80000bac:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bb0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bb2:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bb6:	00001097          	auipc	ra,0x1
    80000bba:	efe080e7          	jalr	-258(ra) # 80001ab4 <mycpu>
    80000bbe:	5d3c                	lw	a5,120(a0)
    80000bc0:	cf89                	beqz	a5,80000bda <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bc2:	00001097          	auipc	ra,0x1
    80000bc6:	ef2080e7          	jalr	-270(ra) # 80001ab4 <mycpu>
    80000bca:	5d3c                	lw	a5,120(a0)
    80000bcc:	2785                	addiw	a5,a5,1
    80000bce:	dd3c                	sw	a5,120(a0)
}
    80000bd0:	60e2                	ld	ra,24(sp)
    80000bd2:	6442                	ld	s0,16(sp)
    80000bd4:	64a2                	ld	s1,8(sp)
    80000bd6:	6105                	addi	sp,sp,32
    80000bd8:	8082                	ret
    mycpu()->intena = old;
    80000bda:	00001097          	auipc	ra,0x1
    80000bde:	eda080e7          	jalr	-294(ra) # 80001ab4 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000be2:	8085                	srli	s1,s1,0x1
    80000be4:	8885                	andi	s1,s1,1
    80000be6:	dd64                	sw	s1,124(a0)
    80000be8:	bfe9                	j	80000bc2 <push_off+0x24>

0000000080000bea <acquire>:
{
    80000bea:	1101                	addi	sp,sp,-32
    80000bec:	ec06                	sd	ra,24(sp)
    80000bee:	e822                	sd	s0,16(sp)
    80000bf0:	e426                	sd	s1,8(sp)
    80000bf2:	1000                	addi	s0,sp,32
    80000bf4:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bf6:	00000097          	auipc	ra,0x0
    80000bfa:	fa8080e7          	jalr	-88(ra) # 80000b9e <push_off>
  if(holding(lk))
    80000bfe:	8526                	mv	a0,s1
    80000c00:	00000097          	auipc	ra,0x0
    80000c04:	f70080e7          	jalr	-144(ra) # 80000b70 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c08:	4705                	li	a4,1
  if(holding(lk))
    80000c0a:	e115                	bnez	a0,80000c2e <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0c:	87ba                	mv	a5,a4
    80000c0e:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c12:	2781                	sext.w	a5,a5
    80000c14:	ffe5                	bnez	a5,80000c0c <acquire+0x22>
  __sync_synchronize();
    80000c16:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c1a:	00001097          	auipc	ra,0x1
    80000c1e:	e9a080e7          	jalr	-358(ra) # 80001ab4 <mycpu>
    80000c22:	e888                	sd	a0,16(s1)
}
    80000c24:	60e2                	ld	ra,24(sp)
    80000c26:	6442                	ld	s0,16(sp)
    80000c28:	64a2                	ld	s1,8(sp)
    80000c2a:	6105                	addi	sp,sp,32
    80000c2c:	8082                	ret
    panic("acquire");
    80000c2e:	00007517          	auipc	a0,0x7
    80000c32:	44250513          	addi	a0,a0,1090 # 80008070 <digits+0x30>
    80000c36:	00000097          	auipc	ra,0x0
    80000c3a:	90e080e7          	jalr	-1778(ra) # 80000544 <panic>

0000000080000c3e <pop_off>:

void
pop_off(void)
{
    80000c3e:	1141                	addi	sp,sp,-16
    80000c40:	e406                	sd	ra,8(sp)
    80000c42:	e022                	sd	s0,0(sp)
    80000c44:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c46:	00001097          	auipc	ra,0x1
    80000c4a:	e6e080e7          	jalr	-402(ra) # 80001ab4 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c4e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c52:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c54:	e78d                	bnez	a5,80000c7e <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c56:	5d3c                	lw	a5,120(a0)
    80000c58:	02f05b63          	blez	a5,80000c8e <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c5c:	37fd                	addiw	a5,a5,-1
    80000c5e:	0007871b          	sext.w	a4,a5
    80000c62:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c64:	eb09                	bnez	a4,80000c76 <pop_off+0x38>
    80000c66:	5d7c                	lw	a5,124(a0)
    80000c68:	c799                	beqz	a5,80000c76 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c6a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c6e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c72:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c76:	60a2                	ld	ra,8(sp)
    80000c78:	6402                	ld	s0,0(sp)
    80000c7a:	0141                	addi	sp,sp,16
    80000c7c:	8082                	ret
    panic("pop_off - interruptible");
    80000c7e:	00007517          	auipc	a0,0x7
    80000c82:	3fa50513          	addi	a0,a0,1018 # 80008078 <digits+0x38>
    80000c86:	00000097          	auipc	ra,0x0
    80000c8a:	8be080e7          	jalr	-1858(ra) # 80000544 <panic>
    panic("pop_off");
    80000c8e:	00007517          	auipc	a0,0x7
    80000c92:	40250513          	addi	a0,a0,1026 # 80008090 <digits+0x50>
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	8ae080e7          	jalr	-1874(ra) # 80000544 <panic>

0000000080000c9e <release>:
{
    80000c9e:	1101                	addi	sp,sp,-32
    80000ca0:	ec06                	sd	ra,24(sp)
    80000ca2:	e822                	sd	s0,16(sp)
    80000ca4:	e426                	sd	s1,8(sp)
    80000ca6:	1000                	addi	s0,sp,32
    80000ca8:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000caa:	00000097          	auipc	ra,0x0
    80000cae:	ec6080e7          	jalr	-314(ra) # 80000b70 <holding>
    80000cb2:	c115                	beqz	a0,80000cd6 <release+0x38>
  lk->cpu = 0;
    80000cb4:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cb8:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000cbc:	0f50000f          	fence	iorw,ow
    80000cc0:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cc4:	00000097          	auipc	ra,0x0
    80000cc8:	f7a080e7          	jalr	-134(ra) # 80000c3e <pop_off>
}
    80000ccc:	60e2                	ld	ra,24(sp)
    80000cce:	6442                	ld	s0,16(sp)
    80000cd0:	64a2                	ld	s1,8(sp)
    80000cd2:	6105                	addi	sp,sp,32
    80000cd4:	8082                	ret
    panic("release");
    80000cd6:	00007517          	auipc	a0,0x7
    80000cda:	3c250513          	addi	a0,a0,962 # 80008098 <digits+0x58>
    80000cde:	00000097          	auipc	ra,0x0
    80000ce2:	866080e7          	jalr	-1946(ra) # 80000544 <panic>

0000000080000ce6 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ce6:	1141                	addi	sp,sp,-16
    80000ce8:	e422                	sd	s0,8(sp)
    80000cea:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cec:	ce09                	beqz	a2,80000d06 <memset+0x20>
    80000cee:	87aa                	mv	a5,a0
    80000cf0:	fff6071b          	addiw	a4,a2,-1
    80000cf4:	1702                	slli	a4,a4,0x20
    80000cf6:	9301                	srli	a4,a4,0x20
    80000cf8:	0705                	addi	a4,a4,1
    80000cfa:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000cfc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d00:	0785                	addi	a5,a5,1
    80000d02:	fee79de3          	bne	a5,a4,80000cfc <memset+0x16>
  }
  return dst;
}
    80000d06:	6422                	ld	s0,8(sp)
    80000d08:	0141                	addi	sp,sp,16
    80000d0a:	8082                	ret

0000000080000d0c <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d0c:	1141                	addi	sp,sp,-16
    80000d0e:	e422                	sd	s0,8(sp)
    80000d10:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d12:	ca05                	beqz	a2,80000d42 <memcmp+0x36>
    80000d14:	fff6069b          	addiw	a3,a2,-1
    80000d18:	1682                	slli	a3,a3,0x20
    80000d1a:	9281                	srli	a3,a3,0x20
    80000d1c:	0685                	addi	a3,a3,1
    80000d1e:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d20:	00054783          	lbu	a5,0(a0)
    80000d24:	0005c703          	lbu	a4,0(a1)
    80000d28:	00e79863          	bne	a5,a4,80000d38 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d2c:	0505                	addi	a0,a0,1
    80000d2e:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d30:	fed518e3          	bne	a0,a3,80000d20 <memcmp+0x14>
  }

  return 0;
    80000d34:	4501                	li	a0,0
    80000d36:	a019                	j	80000d3c <memcmp+0x30>
      return *s1 - *s2;
    80000d38:	40e7853b          	subw	a0,a5,a4
}
    80000d3c:	6422                	ld	s0,8(sp)
    80000d3e:	0141                	addi	sp,sp,16
    80000d40:	8082                	ret
  return 0;
    80000d42:	4501                	li	a0,0
    80000d44:	bfe5                	j	80000d3c <memcmp+0x30>

0000000080000d46 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d46:	1141                	addi	sp,sp,-16
    80000d48:	e422                	sd	s0,8(sp)
    80000d4a:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d4c:	ca0d                	beqz	a2,80000d7e <memmove+0x38>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d4e:	00a5f963          	bgeu	a1,a0,80000d60 <memmove+0x1a>
    80000d52:	02061693          	slli	a3,a2,0x20
    80000d56:	9281                	srli	a3,a3,0x20
    80000d58:	00d58733          	add	a4,a1,a3
    80000d5c:	02e56463          	bltu	a0,a4,80000d84 <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d60:	fff6079b          	addiw	a5,a2,-1
    80000d64:	1782                	slli	a5,a5,0x20
    80000d66:	9381                	srli	a5,a5,0x20
    80000d68:	0785                	addi	a5,a5,1
    80000d6a:	97ae                	add	a5,a5,a1
    80000d6c:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d6e:	0585                	addi	a1,a1,1
    80000d70:	0705                	addi	a4,a4,1
    80000d72:	fff5c683          	lbu	a3,-1(a1)
    80000d76:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d7a:	fef59ae3          	bne	a1,a5,80000d6e <memmove+0x28>

  return dst;
}
    80000d7e:	6422                	ld	s0,8(sp)
    80000d80:	0141                	addi	sp,sp,16
    80000d82:	8082                	ret
    d += n;
    80000d84:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d86:	fff6079b          	addiw	a5,a2,-1
    80000d8a:	1782                	slli	a5,a5,0x20
    80000d8c:	9381                	srli	a5,a5,0x20
    80000d8e:	fff7c793          	not	a5,a5
    80000d92:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d94:	177d                	addi	a4,a4,-1
    80000d96:	16fd                	addi	a3,a3,-1
    80000d98:	00074603          	lbu	a2,0(a4)
    80000d9c:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000da0:	fef71ae3          	bne	a4,a5,80000d94 <memmove+0x4e>
    80000da4:	bfe9                	j	80000d7e <memmove+0x38>

0000000080000da6 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000da6:	1141                	addi	sp,sp,-16
    80000da8:	e406                	sd	ra,8(sp)
    80000daa:	e022                	sd	s0,0(sp)
    80000dac:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000dae:	00000097          	auipc	ra,0x0
    80000db2:	f98080e7          	jalr	-104(ra) # 80000d46 <memmove>
}
    80000db6:	60a2                	ld	ra,8(sp)
    80000db8:	6402                	ld	s0,0(sp)
    80000dba:	0141                	addi	sp,sp,16
    80000dbc:	8082                	ret

0000000080000dbe <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000dbe:	1141                	addi	sp,sp,-16
    80000dc0:	e422                	sd	s0,8(sp)
    80000dc2:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dc4:	ce11                	beqz	a2,80000de0 <strncmp+0x22>
    80000dc6:	00054783          	lbu	a5,0(a0)
    80000dca:	cf89                	beqz	a5,80000de4 <strncmp+0x26>
    80000dcc:	0005c703          	lbu	a4,0(a1)
    80000dd0:	00f71a63          	bne	a4,a5,80000de4 <strncmp+0x26>
    n--, p++, q++;
    80000dd4:	367d                	addiw	a2,a2,-1
    80000dd6:	0505                	addi	a0,a0,1
    80000dd8:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dda:	f675                	bnez	a2,80000dc6 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000ddc:	4501                	li	a0,0
    80000dde:	a809                	j	80000df0 <strncmp+0x32>
    80000de0:	4501                	li	a0,0
    80000de2:	a039                	j	80000df0 <strncmp+0x32>
  if(n == 0)
    80000de4:	ca09                	beqz	a2,80000df6 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000de6:	00054503          	lbu	a0,0(a0)
    80000dea:	0005c783          	lbu	a5,0(a1)
    80000dee:	9d1d                	subw	a0,a0,a5
}
    80000df0:	6422                	ld	s0,8(sp)
    80000df2:	0141                	addi	sp,sp,16
    80000df4:	8082                	ret
    return 0;
    80000df6:	4501                	li	a0,0
    80000df8:	bfe5                	j	80000df0 <strncmp+0x32>

0000000080000dfa <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dfa:	1141                	addi	sp,sp,-16
    80000dfc:	e422                	sd	s0,8(sp)
    80000dfe:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e00:	872a                	mv	a4,a0
    80000e02:	8832                	mv	a6,a2
    80000e04:	367d                	addiw	a2,a2,-1
    80000e06:	01005963          	blez	a6,80000e18 <strncpy+0x1e>
    80000e0a:	0705                	addi	a4,a4,1
    80000e0c:	0005c783          	lbu	a5,0(a1)
    80000e10:	fef70fa3          	sb	a5,-1(a4)
    80000e14:	0585                	addi	a1,a1,1
    80000e16:	f7f5                	bnez	a5,80000e02 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e18:	00c05d63          	blez	a2,80000e32 <strncpy+0x38>
    80000e1c:	86ba                	mv	a3,a4
    *s++ = 0;
    80000e1e:	0685                	addi	a3,a3,1
    80000e20:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e24:	fff6c793          	not	a5,a3
    80000e28:	9fb9                	addw	a5,a5,a4
    80000e2a:	010787bb          	addw	a5,a5,a6
    80000e2e:	fef048e3          	bgtz	a5,80000e1e <strncpy+0x24>
  return os;
}
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret

0000000080000e38 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e38:	1141                	addi	sp,sp,-16
    80000e3a:	e422                	sd	s0,8(sp)
    80000e3c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e3e:	02c05363          	blez	a2,80000e64 <safestrcpy+0x2c>
    80000e42:	fff6069b          	addiw	a3,a2,-1
    80000e46:	1682                	slli	a3,a3,0x20
    80000e48:	9281                	srli	a3,a3,0x20
    80000e4a:	96ae                	add	a3,a3,a1
    80000e4c:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e4e:	00d58963          	beq	a1,a3,80000e60 <safestrcpy+0x28>
    80000e52:	0585                	addi	a1,a1,1
    80000e54:	0785                	addi	a5,a5,1
    80000e56:	fff5c703          	lbu	a4,-1(a1)
    80000e5a:	fee78fa3          	sb	a4,-1(a5)
    80000e5e:	fb65                	bnez	a4,80000e4e <safestrcpy+0x16>
    ;
  *s = 0;
    80000e60:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e64:	6422                	ld	s0,8(sp)
    80000e66:	0141                	addi	sp,sp,16
    80000e68:	8082                	ret

0000000080000e6a <strlen>:

int
strlen(const char *s)
{
    80000e6a:	1141                	addi	sp,sp,-16
    80000e6c:	e422                	sd	s0,8(sp)
    80000e6e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e70:	00054783          	lbu	a5,0(a0)
    80000e74:	cf91                	beqz	a5,80000e90 <strlen+0x26>
    80000e76:	0505                	addi	a0,a0,1
    80000e78:	87aa                	mv	a5,a0
    80000e7a:	4685                	li	a3,1
    80000e7c:	9e89                	subw	a3,a3,a0
    80000e7e:	00f6853b          	addw	a0,a3,a5
    80000e82:	0785                	addi	a5,a5,1
    80000e84:	fff7c703          	lbu	a4,-1(a5)
    80000e88:	fb7d                	bnez	a4,80000e7e <strlen+0x14>
    ;
  return n;
}
    80000e8a:	6422                	ld	s0,8(sp)
    80000e8c:	0141                	addi	sp,sp,16
    80000e8e:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e90:	4501                	li	a0,0
    80000e92:	bfe5                	j	80000e8a <strlen+0x20>

0000000080000e94 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e94:	1141                	addi	sp,sp,-16
    80000e96:	e406                	sd	ra,8(sp)
    80000e98:	e022                	sd	s0,0(sp)
    80000e9a:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e9c:	00001097          	auipc	ra,0x1
    80000ea0:	c08080e7          	jalr	-1016(ra) # 80001aa4 <cpuid>
    pinit();
    #endif
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000ea4:	00008717          	auipc	a4,0x8
    80000ea8:	d2470713          	addi	a4,a4,-732 # 80008bc8 <started>
  if(cpuid() == 0){
    80000eac:	c139                	beqz	a0,80000ef2 <main+0x5e>
    while(started == 0)
    80000eae:	431c                	lw	a5,0(a4)
    80000eb0:	2781                	sext.w	a5,a5
    80000eb2:	dff5                	beqz	a5,80000eae <main+0x1a>
      ;
    __sync_synchronize();
    80000eb4:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000eb8:	00001097          	auipc	ra,0x1
    80000ebc:	bec080e7          	jalr	-1044(ra) # 80001aa4 <cpuid>
    80000ec0:	85aa                	mv	a1,a0
    80000ec2:	00007517          	auipc	a0,0x7
    80000ec6:	1f650513          	addi	a0,a0,502 # 800080b8 <digits+0x78>
    80000eca:	fffff097          	auipc	ra,0xfffff
    80000ece:	6c4080e7          	jalr	1732(ra) # 8000058e <printf>
    kvminithart();    // turn on paging
    80000ed2:	00000097          	auipc	ra,0x0
    80000ed6:	0d8080e7          	jalr	216(ra) # 80000faa <kvminithart>
    // printf("kvminit done\n");
    trapinithart();   // install kernel trap vector
    80000eda:	00002097          	auipc	ra,0x2
    80000ede:	b52080e7          	jalr	-1198(ra) # 80002a2c <trapinithart>
    // printf("trapinit done\n");
    plicinithart();   // ask PLIC for device interrupts
    80000ee2:	00005097          	auipc	ra,0x5
    80000ee6:	38e080e7          	jalr	910(ra) # 80006270 <plicinithart>
    // printf("plicinit done\n");
  }

  // printf("about to call sceduler\n");
  scheduler();        
    80000eea:	00001097          	auipc	ra,0x1
    80000eee:	192080e7          	jalr	402(ra) # 8000207c <scheduler>
    consoleinit();
    80000ef2:	fffff097          	auipc	ra,0xfffff
    80000ef6:	564080e7          	jalr	1380(ra) # 80000456 <consoleinit>
    printfinit();
    80000efa:	00000097          	auipc	ra,0x0
    80000efe:	87a080e7          	jalr	-1926(ra) # 80000774 <printfinit>
    printf("\n");
    80000f02:	00007517          	auipc	a0,0x7
    80000f06:	37e50513          	addi	a0,a0,894 # 80008280 <digits+0x240>
    80000f0a:	fffff097          	auipc	ra,0xfffff
    80000f0e:	684080e7          	jalr	1668(ra) # 8000058e <printf>
    printf("xv6 kernel is booting\n");
    80000f12:	00007517          	auipc	a0,0x7
    80000f16:	18e50513          	addi	a0,a0,398 # 800080a0 <digits+0x60>
    80000f1a:	fffff097          	auipc	ra,0xfffff
    80000f1e:	674080e7          	jalr	1652(ra) # 8000058e <printf>
    printf("\n");
    80000f22:	00007517          	auipc	a0,0x7
    80000f26:	35e50513          	addi	a0,a0,862 # 80008280 <digits+0x240>
    80000f2a:	fffff097          	auipc	ra,0xfffff
    80000f2e:	664080e7          	jalr	1636(ra) # 8000058e <printf>
    kinit();         // physical page allocator
    80000f32:	00000097          	auipc	ra,0x0
    80000f36:	b8c080e7          	jalr	-1140(ra) # 80000abe <kinit>
    kvminit();       // create kernel page table
    80000f3a:	00000097          	auipc	ra,0x0
    80000f3e:	326080e7          	jalr	806(ra) # 80001260 <kvminit>
    kvminithart();   // turn on paging
    80000f42:	00000097          	auipc	ra,0x0
    80000f46:	068080e7          	jalr	104(ra) # 80000faa <kvminithart>
    procinit();      // process table
    80000f4a:	00001097          	auipc	ra,0x1
    80000f4e:	aa4080e7          	jalr	-1372(ra) # 800019ee <procinit>
    trapinit();      // trap vectors
    80000f52:	00002097          	auipc	ra,0x2
    80000f56:	ab2080e7          	jalr	-1358(ra) # 80002a04 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f5a:	00002097          	auipc	ra,0x2
    80000f5e:	ad2080e7          	jalr	-1326(ra) # 80002a2c <trapinithart>
    plicinit();      // set up interrupt controller
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	2f8080e7          	jalr	760(ra) # 8000625a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f6a:	00005097          	auipc	ra,0x5
    80000f6e:	306080e7          	jalr	774(ra) # 80006270 <plicinithart>
    binit();         // buffer cache
    80000f72:	00002097          	auipc	ra,0x2
    80000f76:	4ba080e7          	jalr	1210(ra) # 8000342c <binit>
    iinit();         // inode table
    80000f7a:	00003097          	auipc	ra,0x3
    80000f7e:	b5e080e7          	jalr	-1186(ra) # 80003ad8 <iinit>
    fileinit();      // file table
    80000f82:	00004097          	auipc	ra,0x4
    80000f86:	afc080e7          	jalr	-1284(ra) # 80004a7e <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f8a:	00005097          	auipc	ra,0x5
    80000f8e:	3ee080e7          	jalr	1006(ra) # 80006378 <virtio_disk_init>
    userinit();      // first user process
    80000f92:	00001097          	auipc	ra,0x1
    80000f96:	e4e080e7          	jalr	-434(ra) # 80001de0 <userinit>
    __sync_synchronize();
    80000f9a:	0ff0000f          	fence
    started = 1;
    80000f9e:	4785                	li	a5,1
    80000fa0:	00008717          	auipc	a4,0x8
    80000fa4:	c2f72423          	sw	a5,-984(a4) # 80008bc8 <started>
    80000fa8:	b789                	j	80000eea <main+0x56>

0000000080000faa <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000faa:	1141                	addi	sp,sp,-16
    80000fac:	e422                	sd	s0,8(sp)
    80000fae:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fb0:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000fb4:	00008797          	auipc	a5,0x8
    80000fb8:	c1c7b783          	ld	a5,-996(a5) # 80008bd0 <kernel_pagetable>
    80000fbc:	83b1                	srli	a5,a5,0xc
    80000fbe:	577d                	li	a4,-1
    80000fc0:	177e                	slli	a4,a4,0x3f
    80000fc2:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fc4:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fc8:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fcc:	6422                	ld	s0,8(sp)
    80000fce:	0141                	addi	sp,sp,16
    80000fd0:	8082                	ret

0000000080000fd2 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fd2:	7139                	addi	sp,sp,-64
    80000fd4:	fc06                	sd	ra,56(sp)
    80000fd6:	f822                	sd	s0,48(sp)
    80000fd8:	f426                	sd	s1,40(sp)
    80000fda:	f04a                	sd	s2,32(sp)
    80000fdc:	ec4e                	sd	s3,24(sp)
    80000fde:	e852                	sd	s4,16(sp)
    80000fe0:	e456                	sd	s5,8(sp)
    80000fe2:	e05a                	sd	s6,0(sp)
    80000fe4:	0080                	addi	s0,sp,64
    80000fe6:	84aa                	mv	s1,a0
    80000fe8:	89ae                	mv	s3,a1
    80000fea:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fec:	57fd                	li	a5,-1
    80000fee:	83e9                	srli	a5,a5,0x1a
    80000ff0:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000ff2:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000ff4:	04b7f263          	bgeu	a5,a1,80001038 <walk+0x66>
    panic("walk");
    80000ff8:	00007517          	auipc	a0,0x7
    80000ffc:	0d850513          	addi	a0,a0,216 # 800080d0 <digits+0x90>
    80001000:	fffff097          	auipc	ra,0xfffff
    80001004:	544080e7          	jalr	1348(ra) # 80000544 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001008:	060a8663          	beqz	s5,80001074 <walk+0xa2>
    8000100c:	00000097          	auipc	ra,0x0
    80001010:	aee080e7          	jalr	-1298(ra) # 80000afa <kalloc>
    80001014:	84aa                	mv	s1,a0
    80001016:	c529                	beqz	a0,80001060 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001018:	6605                	lui	a2,0x1
    8000101a:	4581                	li	a1,0
    8000101c:	00000097          	auipc	ra,0x0
    80001020:	cca080e7          	jalr	-822(ra) # 80000ce6 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001024:	00c4d793          	srli	a5,s1,0xc
    80001028:	07aa                	slli	a5,a5,0xa
    8000102a:	0017e793          	ori	a5,a5,1
    8000102e:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001032:	3a5d                	addiw	s4,s4,-9
    80001034:	036a0063          	beq	s4,s6,80001054 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001038:	0149d933          	srl	s2,s3,s4
    8000103c:	1ff97913          	andi	s2,s2,511
    80001040:	090e                	slli	s2,s2,0x3
    80001042:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001044:	00093483          	ld	s1,0(s2)
    80001048:	0014f793          	andi	a5,s1,1
    8000104c:	dfd5                	beqz	a5,80001008 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000104e:	80a9                	srli	s1,s1,0xa
    80001050:	04b2                	slli	s1,s1,0xc
    80001052:	b7c5                	j	80001032 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001054:	00c9d513          	srli	a0,s3,0xc
    80001058:	1ff57513          	andi	a0,a0,511
    8000105c:	050e                	slli	a0,a0,0x3
    8000105e:	9526                	add	a0,a0,s1
}
    80001060:	70e2                	ld	ra,56(sp)
    80001062:	7442                	ld	s0,48(sp)
    80001064:	74a2                	ld	s1,40(sp)
    80001066:	7902                	ld	s2,32(sp)
    80001068:	69e2                	ld	s3,24(sp)
    8000106a:	6a42                	ld	s4,16(sp)
    8000106c:	6aa2                	ld	s5,8(sp)
    8000106e:	6b02                	ld	s6,0(sp)
    80001070:	6121                	addi	sp,sp,64
    80001072:	8082                	ret
        return 0;
    80001074:	4501                	li	a0,0
    80001076:	b7ed                	j	80001060 <walk+0x8e>

0000000080001078 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001078:	57fd                	li	a5,-1
    8000107a:	83e9                	srli	a5,a5,0x1a
    8000107c:	00b7f463          	bgeu	a5,a1,80001084 <walkaddr+0xc>
    return 0;
    80001080:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001082:	8082                	ret
{
    80001084:	1141                	addi	sp,sp,-16
    80001086:	e406                	sd	ra,8(sp)
    80001088:	e022                	sd	s0,0(sp)
    8000108a:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000108c:	4601                	li	a2,0
    8000108e:	00000097          	auipc	ra,0x0
    80001092:	f44080e7          	jalr	-188(ra) # 80000fd2 <walk>
  if(pte == 0)
    80001096:	c105                	beqz	a0,800010b6 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001098:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000109a:	0117f693          	andi	a3,a5,17
    8000109e:	4745                	li	a4,17
    return 0;
    800010a0:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010a2:	00e68663          	beq	a3,a4,800010ae <walkaddr+0x36>
}
    800010a6:	60a2                	ld	ra,8(sp)
    800010a8:	6402                	ld	s0,0(sp)
    800010aa:	0141                	addi	sp,sp,16
    800010ac:	8082                	ret
  pa = PTE2PA(*pte);
    800010ae:	00a7d513          	srli	a0,a5,0xa
    800010b2:	0532                	slli	a0,a0,0xc
  return pa;
    800010b4:	bfcd                	j	800010a6 <walkaddr+0x2e>
    return 0;
    800010b6:	4501                	li	a0,0
    800010b8:	b7fd                	j	800010a6 <walkaddr+0x2e>

00000000800010ba <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010ba:	715d                	addi	sp,sp,-80
    800010bc:	e486                	sd	ra,72(sp)
    800010be:	e0a2                	sd	s0,64(sp)
    800010c0:	fc26                	sd	s1,56(sp)
    800010c2:	f84a                	sd	s2,48(sp)
    800010c4:	f44e                	sd	s3,40(sp)
    800010c6:	f052                	sd	s4,32(sp)
    800010c8:	ec56                	sd	s5,24(sp)
    800010ca:	e85a                	sd	s6,16(sp)
    800010cc:	e45e                	sd	s7,8(sp)
    800010ce:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010d0:	c205                	beqz	a2,800010f0 <mappages+0x36>
    800010d2:	8aaa                	mv	s5,a0
    800010d4:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010d6:	77fd                	lui	a5,0xfffff
    800010d8:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800010dc:	15fd                	addi	a1,a1,-1
    800010de:	00c589b3          	add	s3,a1,a2
    800010e2:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    800010e6:	8952                	mv	s2,s4
    800010e8:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010ec:	6b85                	lui	s7,0x1
    800010ee:	a015                	j	80001112 <mappages+0x58>
    panic("mappages: size");
    800010f0:	00007517          	auipc	a0,0x7
    800010f4:	fe850513          	addi	a0,a0,-24 # 800080d8 <digits+0x98>
    800010f8:	fffff097          	auipc	ra,0xfffff
    800010fc:	44c080e7          	jalr	1100(ra) # 80000544 <panic>
      panic("mappages: remap");
    80001100:	00007517          	auipc	a0,0x7
    80001104:	fe850513          	addi	a0,a0,-24 # 800080e8 <digits+0xa8>
    80001108:	fffff097          	auipc	ra,0xfffff
    8000110c:	43c080e7          	jalr	1084(ra) # 80000544 <panic>
    a += PGSIZE;
    80001110:	995e                	add	s2,s2,s7
  for(;;){
    80001112:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001116:	4605                	li	a2,1
    80001118:	85ca                	mv	a1,s2
    8000111a:	8556                	mv	a0,s5
    8000111c:	00000097          	auipc	ra,0x0
    80001120:	eb6080e7          	jalr	-330(ra) # 80000fd2 <walk>
    80001124:	cd19                	beqz	a0,80001142 <mappages+0x88>
    if(*pte & PTE_V)
    80001126:	611c                	ld	a5,0(a0)
    80001128:	8b85                	andi	a5,a5,1
    8000112a:	fbf9                	bnez	a5,80001100 <mappages+0x46>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000112c:	80b1                	srli	s1,s1,0xc
    8000112e:	04aa                	slli	s1,s1,0xa
    80001130:	0164e4b3          	or	s1,s1,s6
    80001134:	0014e493          	ori	s1,s1,1
    80001138:	e104                	sd	s1,0(a0)
    if(a == last)
    8000113a:	fd391be3          	bne	s2,s3,80001110 <mappages+0x56>
    pa += PGSIZE;
  }
  return 0;
    8000113e:	4501                	li	a0,0
    80001140:	a011                	j	80001144 <mappages+0x8a>
      return -1;
    80001142:	557d                	li	a0,-1
}
    80001144:	60a6                	ld	ra,72(sp)
    80001146:	6406                	ld	s0,64(sp)
    80001148:	74e2                	ld	s1,56(sp)
    8000114a:	7942                	ld	s2,48(sp)
    8000114c:	79a2                	ld	s3,40(sp)
    8000114e:	7a02                	ld	s4,32(sp)
    80001150:	6ae2                	ld	s5,24(sp)
    80001152:	6b42                	ld	s6,16(sp)
    80001154:	6ba2                	ld	s7,8(sp)
    80001156:	6161                	addi	sp,sp,80
    80001158:	8082                	ret

000000008000115a <kvmmap>:
{
    8000115a:	1141                	addi	sp,sp,-16
    8000115c:	e406                	sd	ra,8(sp)
    8000115e:	e022                	sd	s0,0(sp)
    80001160:	0800                	addi	s0,sp,16
    80001162:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001164:	86b2                	mv	a3,a2
    80001166:	863e                	mv	a2,a5
    80001168:	00000097          	auipc	ra,0x0
    8000116c:	f52080e7          	jalr	-174(ra) # 800010ba <mappages>
    80001170:	e509                	bnez	a0,8000117a <kvmmap+0x20>
}
    80001172:	60a2                	ld	ra,8(sp)
    80001174:	6402                	ld	s0,0(sp)
    80001176:	0141                	addi	sp,sp,16
    80001178:	8082                	ret
    panic("kvmmap");
    8000117a:	00007517          	auipc	a0,0x7
    8000117e:	f7e50513          	addi	a0,a0,-130 # 800080f8 <digits+0xb8>
    80001182:	fffff097          	auipc	ra,0xfffff
    80001186:	3c2080e7          	jalr	962(ra) # 80000544 <panic>

000000008000118a <kvmmake>:
{
    8000118a:	1101                	addi	sp,sp,-32
    8000118c:	ec06                	sd	ra,24(sp)
    8000118e:	e822                	sd	s0,16(sp)
    80001190:	e426                	sd	s1,8(sp)
    80001192:	e04a                	sd	s2,0(sp)
    80001194:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001196:	00000097          	auipc	ra,0x0
    8000119a:	964080e7          	jalr	-1692(ra) # 80000afa <kalloc>
    8000119e:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800011a0:	6605                	lui	a2,0x1
    800011a2:	4581                	li	a1,0
    800011a4:	00000097          	auipc	ra,0x0
    800011a8:	b42080e7          	jalr	-1214(ra) # 80000ce6 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011ac:	4719                	li	a4,6
    800011ae:	6685                	lui	a3,0x1
    800011b0:	10000637          	lui	a2,0x10000
    800011b4:	100005b7          	lui	a1,0x10000
    800011b8:	8526                	mv	a0,s1
    800011ba:	00000097          	auipc	ra,0x0
    800011be:	fa0080e7          	jalr	-96(ra) # 8000115a <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011c2:	4719                	li	a4,6
    800011c4:	6685                	lui	a3,0x1
    800011c6:	10001637          	lui	a2,0x10001
    800011ca:	100015b7          	lui	a1,0x10001
    800011ce:	8526                	mv	a0,s1
    800011d0:	00000097          	auipc	ra,0x0
    800011d4:	f8a080e7          	jalr	-118(ra) # 8000115a <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011d8:	4719                	li	a4,6
    800011da:	004006b7          	lui	a3,0x400
    800011de:	0c000637          	lui	a2,0xc000
    800011e2:	0c0005b7          	lui	a1,0xc000
    800011e6:	8526                	mv	a0,s1
    800011e8:	00000097          	auipc	ra,0x0
    800011ec:	f72080e7          	jalr	-142(ra) # 8000115a <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011f0:	00007917          	auipc	s2,0x7
    800011f4:	e1090913          	addi	s2,s2,-496 # 80008000 <etext>
    800011f8:	4729                	li	a4,10
    800011fa:	80007697          	auipc	a3,0x80007
    800011fe:	e0668693          	addi	a3,a3,-506 # 8000 <_entry-0x7fff8000>
    80001202:	4605                	li	a2,1
    80001204:	067e                	slli	a2,a2,0x1f
    80001206:	85b2                	mv	a1,a2
    80001208:	8526                	mv	a0,s1
    8000120a:	00000097          	auipc	ra,0x0
    8000120e:	f50080e7          	jalr	-176(ra) # 8000115a <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001212:	4719                	li	a4,6
    80001214:	46c5                	li	a3,17
    80001216:	06ee                	slli	a3,a3,0x1b
    80001218:	412686b3          	sub	a3,a3,s2
    8000121c:	864a                	mv	a2,s2
    8000121e:	85ca                	mv	a1,s2
    80001220:	8526                	mv	a0,s1
    80001222:	00000097          	auipc	ra,0x0
    80001226:	f38080e7          	jalr	-200(ra) # 8000115a <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000122a:	4729                	li	a4,10
    8000122c:	6685                	lui	a3,0x1
    8000122e:	00006617          	auipc	a2,0x6
    80001232:	dd260613          	addi	a2,a2,-558 # 80007000 <_trampoline>
    80001236:	040005b7          	lui	a1,0x4000
    8000123a:	15fd                	addi	a1,a1,-1
    8000123c:	05b2                	slli	a1,a1,0xc
    8000123e:	8526                	mv	a0,s1
    80001240:	00000097          	auipc	ra,0x0
    80001244:	f1a080e7          	jalr	-230(ra) # 8000115a <kvmmap>
  proc_mapstacks(kpgtbl);
    80001248:	8526                	mv	a0,s1
    8000124a:	00000097          	auipc	ra,0x0
    8000124e:	70e080e7          	jalr	1806(ra) # 80001958 <proc_mapstacks>
}
    80001252:	8526                	mv	a0,s1
    80001254:	60e2                	ld	ra,24(sp)
    80001256:	6442                	ld	s0,16(sp)
    80001258:	64a2                	ld	s1,8(sp)
    8000125a:	6902                	ld	s2,0(sp)
    8000125c:	6105                	addi	sp,sp,32
    8000125e:	8082                	ret

0000000080001260 <kvminit>:
{
    80001260:	1141                	addi	sp,sp,-16
    80001262:	e406                	sd	ra,8(sp)
    80001264:	e022                	sd	s0,0(sp)
    80001266:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001268:	00000097          	auipc	ra,0x0
    8000126c:	f22080e7          	jalr	-222(ra) # 8000118a <kvmmake>
    80001270:	00008797          	auipc	a5,0x8
    80001274:	96a7b023          	sd	a0,-1696(a5) # 80008bd0 <kernel_pagetable>
}
    80001278:	60a2                	ld	ra,8(sp)
    8000127a:	6402                	ld	s0,0(sp)
    8000127c:	0141                	addi	sp,sp,16
    8000127e:	8082                	ret

0000000080001280 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001280:	715d                	addi	sp,sp,-80
    80001282:	e486                	sd	ra,72(sp)
    80001284:	e0a2                	sd	s0,64(sp)
    80001286:	fc26                	sd	s1,56(sp)
    80001288:	f84a                	sd	s2,48(sp)
    8000128a:	f44e                	sd	s3,40(sp)
    8000128c:	f052                	sd	s4,32(sp)
    8000128e:	ec56                	sd	s5,24(sp)
    80001290:	e85a                	sd	s6,16(sp)
    80001292:	e45e                	sd	s7,8(sp)
    80001294:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001296:	03459793          	slli	a5,a1,0x34
    8000129a:	e795                	bnez	a5,800012c6 <uvmunmap+0x46>
    8000129c:	8a2a                	mv	s4,a0
    8000129e:	892e                	mv	s2,a1
    800012a0:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012a2:	0632                	slli	a2,a2,0xc
    800012a4:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800012a8:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012aa:	6b05                	lui	s6,0x1
    800012ac:	0735e863          	bltu	a1,s3,8000131c <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012b0:	60a6                	ld	ra,72(sp)
    800012b2:	6406                	ld	s0,64(sp)
    800012b4:	74e2                	ld	s1,56(sp)
    800012b6:	7942                	ld	s2,48(sp)
    800012b8:	79a2                	ld	s3,40(sp)
    800012ba:	7a02                	ld	s4,32(sp)
    800012bc:	6ae2                	ld	s5,24(sp)
    800012be:	6b42                	ld	s6,16(sp)
    800012c0:	6ba2                	ld	s7,8(sp)
    800012c2:	6161                	addi	sp,sp,80
    800012c4:	8082                	ret
    panic("uvmunmap: not aligned");
    800012c6:	00007517          	auipc	a0,0x7
    800012ca:	e3a50513          	addi	a0,a0,-454 # 80008100 <digits+0xc0>
    800012ce:	fffff097          	auipc	ra,0xfffff
    800012d2:	276080e7          	jalr	630(ra) # 80000544 <panic>
      panic("uvmunmap: walk");
    800012d6:	00007517          	auipc	a0,0x7
    800012da:	e4250513          	addi	a0,a0,-446 # 80008118 <digits+0xd8>
    800012de:	fffff097          	auipc	ra,0xfffff
    800012e2:	266080e7          	jalr	614(ra) # 80000544 <panic>
      panic("uvmunmap: not mapped");
    800012e6:	00007517          	auipc	a0,0x7
    800012ea:	e4250513          	addi	a0,a0,-446 # 80008128 <digits+0xe8>
    800012ee:	fffff097          	auipc	ra,0xfffff
    800012f2:	256080e7          	jalr	598(ra) # 80000544 <panic>
      panic("uvmunmap: not a leaf");
    800012f6:	00007517          	auipc	a0,0x7
    800012fa:	e4a50513          	addi	a0,a0,-438 # 80008140 <digits+0x100>
    800012fe:	fffff097          	auipc	ra,0xfffff
    80001302:	246080e7          	jalr	582(ra) # 80000544 <panic>
      uint64 pa = PTE2PA(*pte);
    80001306:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001308:	0532                	slli	a0,a0,0xc
    8000130a:	fffff097          	auipc	ra,0xfffff
    8000130e:	6f4080e7          	jalr	1780(ra) # 800009fe <kfree>
    *pte = 0;
    80001312:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001316:	995a                	add	s2,s2,s6
    80001318:	f9397ce3          	bgeu	s2,s3,800012b0 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    8000131c:	4601                	li	a2,0
    8000131e:	85ca                	mv	a1,s2
    80001320:	8552                	mv	a0,s4
    80001322:	00000097          	auipc	ra,0x0
    80001326:	cb0080e7          	jalr	-848(ra) # 80000fd2 <walk>
    8000132a:	84aa                	mv	s1,a0
    8000132c:	d54d                	beqz	a0,800012d6 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    8000132e:	6108                	ld	a0,0(a0)
    80001330:	00157793          	andi	a5,a0,1
    80001334:	dbcd                	beqz	a5,800012e6 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001336:	3ff57793          	andi	a5,a0,1023
    8000133a:	fb778ee3          	beq	a5,s7,800012f6 <uvmunmap+0x76>
    if(do_free){
    8000133e:	fc0a8ae3          	beqz	s5,80001312 <uvmunmap+0x92>
    80001342:	b7d1                	j	80001306 <uvmunmap+0x86>

0000000080001344 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001344:	1101                	addi	sp,sp,-32
    80001346:	ec06                	sd	ra,24(sp)
    80001348:	e822                	sd	s0,16(sp)
    8000134a:	e426                	sd	s1,8(sp)
    8000134c:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000134e:	fffff097          	auipc	ra,0xfffff
    80001352:	7ac080e7          	jalr	1964(ra) # 80000afa <kalloc>
    80001356:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001358:	c519                	beqz	a0,80001366 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000135a:	6605                	lui	a2,0x1
    8000135c:	4581                	li	a1,0
    8000135e:	00000097          	auipc	ra,0x0
    80001362:	988080e7          	jalr	-1656(ra) # 80000ce6 <memset>
  return pagetable;
}
    80001366:	8526                	mv	a0,s1
    80001368:	60e2                	ld	ra,24(sp)
    8000136a:	6442                	ld	s0,16(sp)
    8000136c:	64a2                	ld	s1,8(sp)
    8000136e:	6105                	addi	sp,sp,32
    80001370:	8082                	ret

0000000080001372 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001372:	7179                	addi	sp,sp,-48
    80001374:	f406                	sd	ra,40(sp)
    80001376:	f022                	sd	s0,32(sp)
    80001378:	ec26                	sd	s1,24(sp)
    8000137a:	e84a                	sd	s2,16(sp)
    8000137c:	e44e                	sd	s3,8(sp)
    8000137e:	e052                	sd	s4,0(sp)
    80001380:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001382:	6785                	lui	a5,0x1
    80001384:	04f67863          	bgeu	a2,a5,800013d4 <uvmfirst+0x62>
    80001388:	8a2a                	mv	s4,a0
    8000138a:	89ae                	mv	s3,a1
    8000138c:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000138e:	fffff097          	auipc	ra,0xfffff
    80001392:	76c080e7          	jalr	1900(ra) # 80000afa <kalloc>
    80001396:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001398:	6605                	lui	a2,0x1
    8000139a:	4581                	li	a1,0
    8000139c:	00000097          	auipc	ra,0x0
    800013a0:	94a080e7          	jalr	-1718(ra) # 80000ce6 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800013a4:	4779                	li	a4,30
    800013a6:	86ca                	mv	a3,s2
    800013a8:	6605                	lui	a2,0x1
    800013aa:	4581                	li	a1,0
    800013ac:	8552                	mv	a0,s4
    800013ae:	00000097          	auipc	ra,0x0
    800013b2:	d0c080e7          	jalr	-756(ra) # 800010ba <mappages>
  memmove(mem, src, sz);
    800013b6:	8626                	mv	a2,s1
    800013b8:	85ce                	mv	a1,s3
    800013ba:	854a                	mv	a0,s2
    800013bc:	00000097          	auipc	ra,0x0
    800013c0:	98a080e7          	jalr	-1654(ra) # 80000d46 <memmove>
}
    800013c4:	70a2                	ld	ra,40(sp)
    800013c6:	7402                	ld	s0,32(sp)
    800013c8:	64e2                	ld	s1,24(sp)
    800013ca:	6942                	ld	s2,16(sp)
    800013cc:	69a2                	ld	s3,8(sp)
    800013ce:	6a02                	ld	s4,0(sp)
    800013d0:	6145                	addi	sp,sp,48
    800013d2:	8082                	ret
    panic("uvmfirst: more than a page");
    800013d4:	00007517          	auipc	a0,0x7
    800013d8:	d8450513          	addi	a0,a0,-636 # 80008158 <digits+0x118>
    800013dc:	fffff097          	auipc	ra,0xfffff
    800013e0:	168080e7          	jalr	360(ra) # 80000544 <panic>

00000000800013e4 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013e4:	1101                	addi	sp,sp,-32
    800013e6:	ec06                	sd	ra,24(sp)
    800013e8:	e822                	sd	s0,16(sp)
    800013ea:	e426                	sd	s1,8(sp)
    800013ec:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013ee:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013f0:	00b67d63          	bgeu	a2,a1,8000140a <uvmdealloc+0x26>
    800013f4:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013f6:	6785                	lui	a5,0x1
    800013f8:	17fd                	addi	a5,a5,-1
    800013fa:	00f60733          	add	a4,a2,a5
    800013fe:	767d                	lui	a2,0xfffff
    80001400:	8f71                	and	a4,a4,a2
    80001402:	97ae                	add	a5,a5,a1
    80001404:	8ff1                	and	a5,a5,a2
    80001406:	00f76863          	bltu	a4,a5,80001416 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000140a:	8526                	mv	a0,s1
    8000140c:	60e2                	ld	ra,24(sp)
    8000140e:	6442                	ld	s0,16(sp)
    80001410:	64a2                	ld	s1,8(sp)
    80001412:	6105                	addi	sp,sp,32
    80001414:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001416:	8f99                	sub	a5,a5,a4
    80001418:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000141a:	4685                	li	a3,1
    8000141c:	0007861b          	sext.w	a2,a5
    80001420:	85ba                	mv	a1,a4
    80001422:	00000097          	auipc	ra,0x0
    80001426:	e5e080e7          	jalr	-418(ra) # 80001280 <uvmunmap>
    8000142a:	b7c5                	j	8000140a <uvmdealloc+0x26>

000000008000142c <uvmalloc>:
  if(newsz < oldsz)
    8000142c:	0ab66563          	bltu	a2,a1,800014d6 <uvmalloc+0xaa>
{
    80001430:	7139                	addi	sp,sp,-64
    80001432:	fc06                	sd	ra,56(sp)
    80001434:	f822                	sd	s0,48(sp)
    80001436:	f426                	sd	s1,40(sp)
    80001438:	f04a                	sd	s2,32(sp)
    8000143a:	ec4e                	sd	s3,24(sp)
    8000143c:	e852                	sd	s4,16(sp)
    8000143e:	e456                	sd	s5,8(sp)
    80001440:	e05a                	sd	s6,0(sp)
    80001442:	0080                	addi	s0,sp,64
    80001444:	8aaa                	mv	s5,a0
    80001446:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001448:	6985                	lui	s3,0x1
    8000144a:	19fd                	addi	s3,s3,-1
    8000144c:	95ce                	add	a1,a1,s3
    8000144e:	79fd                	lui	s3,0xfffff
    80001450:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001454:	08c9f363          	bgeu	s3,a2,800014da <uvmalloc+0xae>
    80001458:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000145a:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    8000145e:	fffff097          	auipc	ra,0xfffff
    80001462:	69c080e7          	jalr	1692(ra) # 80000afa <kalloc>
    80001466:	84aa                	mv	s1,a0
    if(mem == 0){
    80001468:	c51d                	beqz	a0,80001496 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000146a:	6605                	lui	a2,0x1
    8000146c:	4581                	li	a1,0
    8000146e:	00000097          	auipc	ra,0x0
    80001472:	878080e7          	jalr	-1928(ra) # 80000ce6 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001476:	875a                	mv	a4,s6
    80001478:	86a6                	mv	a3,s1
    8000147a:	6605                	lui	a2,0x1
    8000147c:	85ca                	mv	a1,s2
    8000147e:	8556                	mv	a0,s5
    80001480:	00000097          	auipc	ra,0x0
    80001484:	c3a080e7          	jalr	-966(ra) # 800010ba <mappages>
    80001488:	e90d                	bnez	a0,800014ba <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000148a:	6785                	lui	a5,0x1
    8000148c:	993e                	add	s2,s2,a5
    8000148e:	fd4968e3          	bltu	s2,s4,8000145e <uvmalloc+0x32>
  return newsz;
    80001492:	8552                	mv	a0,s4
    80001494:	a809                	j	800014a6 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    80001496:	864e                	mv	a2,s3
    80001498:	85ca                	mv	a1,s2
    8000149a:	8556                	mv	a0,s5
    8000149c:	00000097          	auipc	ra,0x0
    800014a0:	f48080e7          	jalr	-184(ra) # 800013e4 <uvmdealloc>
      return 0;
    800014a4:	4501                	li	a0,0
}
    800014a6:	70e2                	ld	ra,56(sp)
    800014a8:	7442                	ld	s0,48(sp)
    800014aa:	74a2                	ld	s1,40(sp)
    800014ac:	7902                	ld	s2,32(sp)
    800014ae:	69e2                	ld	s3,24(sp)
    800014b0:	6a42                	ld	s4,16(sp)
    800014b2:	6aa2                	ld	s5,8(sp)
    800014b4:	6b02                	ld	s6,0(sp)
    800014b6:	6121                	addi	sp,sp,64
    800014b8:	8082                	ret
      kfree(mem);
    800014ba:	8526                	mv	a0,s1
    800014bc:	fffff097          	auipc	ra,0xfffff
    800014c0:	542080e7          	jalr	1346(ra) # 800009fe <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014c4:	864e                	mv	a2,s3
    800014c6:	85ca                	mv	a1,s2
    800014c8:	8556                	mv	a0,s5
    800014ca:	00000097          	auipc	ra,0x0
    800014ce:	f1a080e7          	jalr	-230(ra) # 800013e4 <uvmdealloc>
      return 0;
    800014d2:	4501                	li	a0,0
    800014d4:	bfc9                	j	800014a6 <uvmalloc+0x7a>
    return oldsz;
    800014d6:	852e                	mv	a0,a1
}
    800014d8:	8082                	ret
  return newsz;
    800014da:	8532                	mv	a0,a2
    800014dc:	b7e9                	j	800014a6 <uvmalloc+0x7a>

00000000800014de <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014de:	7179                	addi	sp,sp,-48
    800014e0:	f406                	sd	ra,40(sp)
    800014e2:	f022                	sd	s0,32(sp)
    800014e4:	ec26                	sd	s1,24(sp)
    800014e6:	e84a                	sd	s2,16(sp)
    800014e8:	e44e                	sd	s3,8(sp)
    800014ea:	e052                	sd	s4,0(sp)
    800014ec:	1800                	addi	s0,sp,48
    800014ee:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014f0:	84aa                	mv	s1,a0
    800014f2:	6905                	lui	s2,0x1
    800014f4:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f6:	4985                	li	s3,1
    800014f8:	a821                	j	80001510 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014fa:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014fc:	0532                	slli	a0,a0,0xc
    800014fe:	00000097          	auipc	ra,0x0
    80001502:	fe0080e7          	jalr	-32(ra) # 800014de <freewalk>
      pagetable[i] = 0;
    80001506:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000150a:	04a1                	addi	s1,s1,8
    8000150c:	03248163          	beq	s1,s2,8000152e <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001510:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001512:	00f57793          	andi	a5,a0,15
    80001516:	ff3782e3          	beq	a5,s3,800014fa <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000151a:	8905                	andi	a0,a0,1
    8000151c:	d57d                	beqz	a0,8000150a <freewalk+0x2c>
      panic("freewalk: leaf");
    8000151e:	00007517          	auipc	a0,0x7
    80001522:	c5a50513          	addi	a0,a0,-934 # 80008178 <digits+0x138>
    80001526:	fffff097          	auipc	ra,0xfffff
    8000152a:	01e080e7          	jalr	30(ra) # 80000544 <panic>
    }
  }
  kfree((void*)pagetable);
    8000152e:	8552                	mv	a0,s4
    80001530:	fffff097          	auipc	ra,0xfffff
    80001534:	4ce080e7          	jalr	1230(ra) # 800009fe <kfree>
}
    80001538:	70a2                	ld	ra,40(sp)
    8000153a:	7402                	ld	s0,32(sp)
    8000153c:	64e2                	ld	s1,24(sp)
    8000153e:	6942                	ld	s2,16(sp)
    80001540:	69a2                	ld	s3,8(sp)
    80001542:	6a02                	ld	s4,0(sp)
    80001544:	6145                	addi	sp,sp,48
    80001546:	8082                	ret

0000000080001548 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001548:	1101                	addi	sp,sp,-32
    8000154a:	ec06                	sd	ra,24(sp)
    8000154c:	e822                	sd	s0,16(sp)
    8000154e:	e426                	sd	s1,8(sp)
    80001550:	1000                	addi	s0,sp,32
    80001552:	84aa                	mv	s1,a0
  if(sz > 0)
    80001554:	e999                	bnez	a1,8000156a <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001556:	8526                	mv	a0,s1
    80001558:	00000097          	auipc	ra,0x0
    8000155c:	f86080e7          	jalr	-122(ra) # 800014de <freewalk>
}
    80001560:	60e2                	ld	ra,24(sp)
    80001562:	6442                	ld	s0,16(sp)
    80001564:	64a2                	ld	s1,8(sp)
    80001566:	6105                	addi	sp,sp,32
    80001568:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000156a:	6605                	lui	a2,0x1
    8000156c:	167d                	addi	a2,a2,-1
    8000156e:	962e                	add	a2,a2,a1
    80001570:	4685                	li	a3,1
    80001572:	8231                	srli	a2,a2,0xc
    80001574:	4581                	li	a1,0
    80001576:	00000097          	auipc	ra,0x0
    8000157a:	d0a080e7          	jalr	-758(ra) # 80001280 <uvmunmap>
    8000157e:	bfe1                	j	80001556 <uvmfree+0xe>

0000000080001580 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001580:	c679                	beqz	a2,8000164e <uvmcopy+0xce>
{
    80001582:	715d                	addi	sp,sp,-80
    80001584:	e486                	sd	ra,72(sp)
    80001586:	e0a2                	sd	s0,64(sp)
    80001588:	fc26                	sd	s1,56(sp)
    8000158a:	f84a                	sd	s2,48(sp)
    8000158c:	f44e                	sd	s3,40(sp)
    8000158e:	f052                	sd	s4,32(sp)
    80001590:	ec56                	sd	s5,24(sp)
    80001592:	e85a                	sd	s6,16(sp)
    80001594:	e45e                	sd	s7,8(sp)
    80001596:	0880                	addi	s0,sp,80
    80001598:	8b2a                	mv	s6,a0
    8000159a:	8aae                	mv	s5,a1
    8000159c:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000159e:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800015a0:	4601                	li	a2,0
    800015a2:	85ce                	mv	a1,s3
    800015a4:	855a                	mv	a0,s6
    800015a6:	00000097          	auipc	ra,0x0
    800015aa:	a2c080e7          	jalr	-1492(ra) # 80000fd2 <walk>
    800015ae:	c531                	beqz	a0,800015fa <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800015b0:	6118                	ld	a4,0(a0)
    800015b2:	00177793          	andi	a5,a4,1
    800015b6:	cbb1                	beqz	a5,8000160a <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015b8:	00a75593          	srli	a1,a4,0xa
    800015bc:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015c0:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015c4:	fffff097          	auipc	ra,0xfffff
    800015c8:	536080e7          	jalr	1334(ra) # 80000afa <kalloc>
    800015cc:	892a                	mv	s2,a0
    800015ce:	c939                	beqz	a0,80001624 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015d0:	6605                	lui	a2,0x1
    800015d2:	85de                	mv	a1,s7
    800015d4:	fffff097          	auipc	ra,0xfffff
    800015d8:	772080e7          	jalr	1906(ra) # 80000d46 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015dc:	8726                	mv	a4,s1
    800015de:	86ca                	mv	a3,s2
    800015e0:	6605                	lui	a2,0x1
    800015e2:	85ce                	mv	a1,s3
    800015e4:	8556                	mv	a0,s5
    800015e6:	00000097          	auipc	ra,0x0
    800015ea:	ad4080e7          	jalr	-1324(ra) # 800010ba <mappages>
    800015ee:	e515                	bnez	a0,8000161a <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015f0:	6785                	lui	a5,0x1
    800015f2:	99be                	add	s3,s3,a5
    800015f4:	fb49e6e3          	bltu	s3,s4,800015a0 <uvmcopy+0x20>
    800015f8:	a081                	j	80001638 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015fa:	00007517          	auipc	a0,0x7
    800015fe:	b8e50513          	addi	a0,a0,-1138 # 80008188 <digits+0x148>
    80001602:	fffff097          	auipc	ra,0xfffff
    80001606:	f42080e7          	jalr	-190(ra) # 80000544 <panic>
      panic("uvmcopy: page not present");
    8000160a:	00007517          	auipc	a0,0x7
    8000160e:	b9e50513          	addi	a0,a0,-1122 # 800081a8 <digits+0x168>
    80001612:	fffff097          	auipc	ra,0xfffff
    80001616:	f32080e7          	jalr	-206(ra) # 80000544 <panic>
      kfree(mem);
    8000161a:	854a                	mv	a0,s2
    8000161c:	fffff097          	auipc	ra,0xfffff
    80001620:	3e2080e7          	jalr	994(ra) # 800009fe <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001624:	4685                	li	a3,1
    80001626:	00c9d613          	srli	a2,s3,0xc
    8000162a:	4581                	li	a1,0
    8000162c:	8556                	mv	a0,s5
    8000162e:	00000097          	auipc	ra,0x0
    80001632:	c52080e7          	jalr	-942(ra) # 80001280 <uvmunmap>
  return -1;
    80001636:	557d                	li	a0,-1
}
    80001638:	60a6                	ld	ra,72(sp)
    8000163a:	6406                	ld	s0,64(sp)
    8000163c:	74e2                	ld	s1,56(sp)
    8000163e:	7942                	ld	s2,48(sp)
    80001640:	79a2                	ld	s3,40(sp)
    80001642:	7a02                	ld	s4,32(sp)
    80001644:	6ae2                	ld	s5,24(sp)
    80001646:	6b42                	ld	s6,16(sp)
    80001648:	6ba2                	ld	s7,8(sp)
    8000164a:	6161                	addi	sp,sp,80
    8000164c:	8082                	ret
  return 0;
    8000164e:	4501                	li	a0,0
}
    80001650:	8082                	ret

0000000080001652 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001652:	1141                	addi	sp,sp,-16
    80001654:	e406                	sd	ra,8(sp)
    80001656:	e022                	sd	s0,0(sp)
    80001658:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000165a:	4601                	li	a2,0
    8000165c:	00000097          	auipc	ra,0x0
    80001660:	976080e7          	jalr	-1674(ra) # 80000fd2 <walk>
  if(pte == 0)
    80001664:	c901                	beqz	a0,80001674 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001666:	611c                	ld	a5,0(a0)
    80001668:	9bbd                	andi	a5,a5,-17
    8000166a:	e11c                	sd	a5,0(a0)
}
    8000166c:	60a2                	ld	ra,8(sp)
    8000166e:	6402                	ld	s0,0(sp)
    80001670:	0141                	addi	sp,sp,16
    80001672:	8082                	ret
    panic("uvmclear");
    80001674:	00007517          	auipc	a0,0x7
    80001678:	b5450513          	addi	a0,a0,-1196 # 800081c8 <digits+0x188>
    8000167c:	fffff097          	auipc	ra,0xfffff
    80001680:	ec8080e7          	jalr	-312(ra) # 80000544 <panic>

0000000080001684 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001684:	c6bd                	beqz	a3,800016f2 <copyout+0x6e>
{
    80001686:	715d                	addi	sp,sp,-80
    80001688:	e486                	sd	ra,72(sp)
    8000168a:	e0a2                	sd	s0,64(sp)
    8000168c:	fc26                	sd	s1,56(sp)
    8000168e:	f84a                	sd	s2,48(sp)
    80001690:	f44e                	sd	s3,40(sp)
    80001692:	f052                	sd	s4,32(sp)
    80001694:	ec56                	sd	s5,24(sp)
    80001696:	e85a                	sd	s6,16(sp)
    80001698:	e45e                	sd	s7,8(sp)
    8000169a:	e062                	sd	s8,0(sp)
    8000169c:	0880                	addi	s0,sp,80
    8000169e:	8b2a                	mv	s6,a0
    800016a0:	8c2e                	mv	s8,a1
    800016a2:	8a32                	mv	s4,a2
    800016a4:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800016a6:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800016a8:	6a85                	lui	s5,0x1
    800016aa:	a015                	j	800016ce <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800016ac:	9562                	add	a0,a0,s8
    800016ae:	0004861b          	sext.w	a2,s1
    800016b2:	85d2                	mv	a1,s4
    800016b4:	41250533          	sub	a0,a0,s2
    800016b8:	fffff097          	auipc	ra,0xfffff
    800016bc:	68e080e7          	jalr	1678(ra) # 80000d46 <memmove>

    len -= n;
    800016c0:	409989b3          	sub	s3,s3,s1
    src += n;
    800016c4:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016c6:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016ca:	02098263          	beqz	s3,800016ee <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016ce:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016d2:	85ca                	mv	a1,s2
    800016d4:	855a                	mv	a0,s6
    800016d6:	00000097          	auipc	ra,0x0
    800016da:	9a2080e7          	jalr	-1630(ra) # 80001078 <walkaddr>
    if(pa0 == 0)
    800016de:	cd01                	beqz	a0,800016f6 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016e0:	418904b3          	sub	s1,s2,s8
    800016e4:	94d6                	add	s1,s1,s5
    if(n > len)
    800016e6:	fc99f3e3          	bgeu	s3,s1,800016ac <copyout+0x28>
    800016ea:	84ce                	mv	s1,s3
    800016ec:	b7c1                	j	800016ac <copyout+0x28>
  }
  return 0;
    800016ee:	4501                	li	a0,0
    800016f0:	a021                	j	800016f8 <copyout+0x74>
    800016f2:	4501                	li	a0,0
}
    800016f4:	8082                	ret
      return -1;
    800016f6:	557d                	li	a0,-1
}
    800016f8:	60a6                	ld	ra,72(sp)
    800016fa:	6406                	ld	s0,64(sp)
    800016fc:	74e2                	ld	s1,56(sp)
    800016fe:	7942                	ld	s2,48(sp)
    80001700:	79a2                	ld	s3,40(sp)
    80001702:	7a02                	ld	s4,32(sp)
    80001704:	6ae2                	ld	s5,24(sp)
    80001706:	6b42                	ld	s6,16(sp)
    80001708:	6ba2                	ld	s7,8(sp)
    8000170a:	6c02                	ld	s8,0(sp)
    8000170c:	6161                	addi	sp,sp,80
    8000170e:	8082                	ret

0000000080001710 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001710:	c6bd                	beqz	a3,8000177e <copyin+0x6e>
{
    80001712:	715d                	addi	sp,sp,-80
    80001714:	e486                	sd	ra,72(sp)
    80001716:	e0a2                	sd	s0,64(sp)
    80001718:	fc26                	sd	s1,56(sp)
    8000171a:	f84a                	sd	s2,48(sp)
    8000171c:	f44e                	sd	s3,40(sp)
    8000171e:	f052                	sd	s4,32(sp)
    80001720:	ec56                	sd	s5,24(sp)
    80001722:	e85a                	sd	s6,16(sp)
    80001724:	e45e                	sd	s7,8(sp)
    80001726:	e062                	sd	s8,0(sp)
    80001728:	0880                	addi	s0,sp,80
    8000172a:	8b2a                	mv	s6,a0
    8000172c:	8a2e                	mv	s4,a1
    8000172e:	8c32                	mv	s8,a2
    80001730:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001732:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001734:	6a85                	lui	s5,0x1
    80001736:	a015                	j	8000175a <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001738:	9562                	add	a0,a0,s8
    8000173a:	0004861b          	sext.w	a2,s1
    8000173e:	412505b3          	sub	a1,a0,s2
    80001742:	8552                	mv	a0,s4
    80001744:	fffff097          	auipc	ra,0xfffff
    80001748:	602080e7          	jalr	1538(ra) # 80000d46 <memmove>

    len -= n;
    8000174c:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001750:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001752:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001756:	02098263          	beqz	s3,8000177a <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    8000175a:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000175e:	85ca                	mv	a1,s2
    80001760:	855a                	mv	a0,s6
    80001762:	00000097          	auipc	ra,0x0
    80001766:	916080e7          	jalr	-1770(ra) # 80001078 <walkaddr>
    if(pa0 == 0)
    8000176a:	cd01                	beqz	a0,80001782 <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    8000176c:	418904b3          	sub	s1,s2,s8
    80001770:	94d6                	add	s1,s1,s5
    if(n > len)
    80001772:	fc99f3e3          	bgeu	s3,s1,80001738 <copyin+0x28>
    80001776:	84ce                	mv	s1,s3
    80001778:	b7c1                	j	80001738 <copyin+0x28>
  }
  return 0;
    8000177a:	4501                	li	a0,0
    8000177c:	a021                	j	80001784 <copyin+0x74>
    8000177e:	4501                	li	a0,0
}
    80001780:	8082                	ret
      return -1;
    80001782:	557d                	li	a0,-1
}
    80001784:	60a6                	ld	ra,72(sp)
    80001786:	6406                	ld	s0,64(sp)
    80001788:	74e2                	ld	s1,56(sp)
    8000178a:	7942                	ld	s2,48(sp)
    8000178c:	79a2                	ld	s3,40(sp)
    8000178e:	7a02                	ld	s4,32(sp)
    80001790:	6ae2                	ld	s5,24(sp)
    80001792:	6b42                	ld	s6,16(sp)
    80001794:	6ba2                	ld	s7,8(sp)
    80001796:	6c02                	ld	s8,0(sp)
    80001798:	6161                	addi	sp,sp,80
    8000179a:	8082                	ret

000000008000179c <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000179c:	c6c5                	beqz	a3,80001844 <copyinstr+0xa8>
{
    8000179e:	715d                	addi	sp,sp,-80
    800017a0:	e486                	sd	ra,72(sp)
    800017a2:	e0a2                	sd	s0,64(sp)
    800017a4:	fc26                	sd	s1,56(sp)
    800017a6:	f84a                	sd	s2,48(sp)
    800017a8:	f44e                	sd	s3,40(sp)
    800017aa:	f052                	sd	s4,32(sp)
    800017ac:	ec56                	sd	s5,24(sp)
    800017ae:	e85a                	sd	s6,16(sp)
    800017b0:	e45e                	sd	s7,8(sp)
    800017b2:	0880                	addi	s0,sp,80
    800017b4:	8a2a                	mv	s4,a0
    800017b6:	8b2e                	mv	s6,a1
    800017b8:	8bb2                	mv	s7,a2
    800017ba:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017bc:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017be:	6985                	lui	s3,0x1
    800017c0:	a035                	j	800017ec <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017c2:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017c6:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017c8:	0017b793          	seqz	a5,a5
    800017cc:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017d0:	60a6                	ld	ra,72(sp)
    800017d2:	6406                	ld	s0,64(sp)
    800017d4:	74e2                	ld	s1,56(sp)
    800017d6:	7942                	ld	s2,48(sp)
    800017d8:	79a2                	ld	s3,40(sp)
    800017da:	7a02                	ld	s4,32(sp)
    800017dc:	6ae2                	ld	s5,24(sp)
    800017de:	6b42                	ld	s6,16(sp)
    800017e0:	6ba2                	ld	s7,8(sp)
    800017e2:	6161                	addi	sp,sp,80
    800017e4:	8082                	ret
    srcva = va0 + PGSIZE;
    800017e6:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017ea:	c8a9                	beqz	s1,8000183c <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017ec:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017f0:	85ca                	mv	a1,s2
    800017f2:	8552                	mv	a0,s4
    800017f4:	00000097          	auipc	ra,0x0
    800017f8:	884080e7          	jalr	-1916(ra) # 80001078 <walkaddr>
    if(pa0 == 0)
    800017fc:	c131                	beqz	a0,80001840 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017fe:	41790833          	sub	a6,s2,s7
    80001802:	984e                	add	a6,a6,s3
    if(n > max)
    80001804:	0104f363          	bgeu	s1,a6,8000180a <copyinstr+0x6e>
    80001808:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    8000180a:	955e                	add	a0,a0,s7
    8000180c:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001810:	fc080be3          	beqz	a6,800017e6 <copyinstr+0x4a>
    80001814:	985a                	add	a6,a6,s6
    80001816:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001818:	41650633          	sub	a2,a0,s6
    8000181c:	14fd                	addi	s1,s1,-1
    8000181e:	9b26                	add	s6,s6,s1
    80001820:	00f60733          	add	a4,a2,a5
    80001824:	00074703          	lbu	a4,0(a4)
    80001828:	df49                	beqz	a4,800017c2 <copyinstr+0x26>
        *dst = *p;
    8000182a:	00e78023          	sb	a4,0(a5)
      --max;
    8000182e:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001832:	0785                	addi	a5,a5,1
    while(n > 0){
    80001834:	ff0796e3          	bne	a5,a6,80001820 <copyinstr+0x84>
      dst++;
    80001838:	8b42                	mv	s6,a6
    8000183a:	b775                	j	800017e6 <copyinstr+0x4a>
    8000183c:	4781                	li	a5,0
    8000183e:	b769                	j	800017c8 <copyinstr+0x2c>
      return -1;
    80001840:	557d                	li	a0,-1
    80001842:	b779                	j	800017d0 <copyinstr+0x34>
  int got_null = 0;
    80001844:	4781                	li	a5,0
  if(got_null){
    80001846:	0017b793          	seqz	a5,a5
    8000184a:	40f00533          	neg	a0,a5
}
    8000184e:	8082                	ret

0000000080001850 <calculateDynamicPriority>:
Queue mlfq[5];
#endif

// #ifdef PBS
int calculateDynamicPriority(struct proc *process)
{
    80001850:	1141                	addi	sp,sp,-16
    80001852:	e422                	sd	s0,8(sp)
    80001854:	0800                	addi	s0,sp,16
	process->niceness = 5;
    80001856:	4795                	li	a5,5
    80001858:	1af52223          	sw	a5,420(a0)
	if (process->runTimePrev == 0)
    8000185c:	19452783          	lw	a5,404(a0)
    80001860:	e791                	bnez	a5,8000186c <calculateDynamicPriority+0x1c>
	{
		if (process->sleepTimePrev == 0)
    80001862:	18c52783          	lw	a5,396(a0)
    80001866:	e399                	bnez	a5,8000186c <calculateDynamicPriority+0x1c>
		{
			process->niceness = process->sleepTimePrev * 10;
			process->niceness /= (process->runTimePrev + process->sleepTimePrev);
    80001868:	1a052223          	sw	zero,420(a0)
		}
	}
	int retval = 0, checker = process->sprior - process->niceness + 5;
    8000186c:	19c52783          	lw	a5,412(a0)
    80001870:	2795                	addiw	a5,a5,5
    80001872:	1a452503          	lw	a0,420(a0)
    80001876:	40a7853b          	subw	a0,a5,a0
	}
	else
	{
		retval = checker;
	}
	return retval;
    8000187a:	0005079b          	sext.w	a5,a0
    8000187e:	fff7c793          	not	a5,a5
    80001882:	97fd                	srai	a5,a5,0x3f
    80001884:	8d7d                	and	a0,a0,a5
    80001886:	0005071b          	sext.w	a4,a0
    8000188a:	06400793          	li	a5,100
    8000188e:	00e7d463          	bge	a5,a4,80001896 <calculateDynamicPriority+0x46>
    80001892:	06400513          	li	a0,100
}
    80001896:	2501                	sext.w	a0,a0
    80001898:	6422                	ld	s0,8(sp)
    8000189a:	0141                	addi	sp,sp,16
    8000189c:	8082                	ret

000000008000189e <set_priority>:
// #endif

int set_priority(int static_prior, int pid)
{
    8000189e:	7139                	addi	sp,sp,-64
    800018a0:	fc06                	sd	ra,56(sp)
    800018a2:	f822                	sd	s0,48(sp)
    800018a4:	f426                	sd	s1,40(sp)
    800018a6:	f04a                	sd	s2,32(sp)
    800018a8:	ec4e                	sd	s3,24(sp)
    800018aa:	e852                	sd	s4,16(sp)
    800018ac:	e456                	sd	s5,8(sp)
    800018ae:	0080                	addi	s0,sp,64
    800018b0:	89ae                	mv	s3,a1
	int old_prior = -1, checkIfAvailable = 0;
	if (static_prior < 0 || static_prior > 100)
    800018b2:	8aaa                	mv	s5,a0
    800018b4:	06400793          	li	a5,100
	{
		printf("Priority is not right\n");
		return -1;
	}
	struct proc *i;
	for (i = proc; i < &proc[NPROC]; i++)
    800018b8:	00010497          	auipc	s1,0x10
    800018bc:	9c848493          	addi	s1,s1,-1592 # 80011280 <proc>
    800018c0:	00017a17          	auipc	s4,0x17
    800018c4:	dc0a0a13          	addi	s4,s4,-576 # 80018680 <tickslock>
	if (static_prior < 0 || static_prior > 100)
    800018c8:	02a7e763          	bltu	a5,a0,800018f6 <set_priority+0x58>
	{
		acquire(&i->lock);
    800018cc:	00848913          	addi	s2,s1,8
    800018d0:	854a                	mv	a0,s2
    800018d2:	fffff097          	auipc	ra,0xfffff
    800018d6:	318080e7          	jalr	792(ra) # 80000bea <acquire>
		if (i->pid == pid)
    800018da:	5c9c                	lw	a5,56(s1)
    800018dc:	03378763          	beq	a5,s3,8000190a <set_priority+0x6c>
		{
			checkIfAvailable = 1;
			release(&i->lock);
			break;
		}
		release(&i->lock);
    800018e0:	854a                	mv	a0,s2
    800018e2:	fffff097          	auipc	ra,0xfffff
    800018e6:	3bc080e7          	jalr	956(ra) # 80000c9e <release>
	for (i = proc; i < &proc[NPROC]; i++)
    800018ea:	1d048493          	addi	s1,s1,464
    800018ee:	fd449fe3          	bne	s1,s4,800018cc <set_priority+0x2e>
		i->dprior = calculateDynamicPriority(i);
		release(&i->lock);
	}
	else
	{
		return -1;
    800018f2:	59fd                	li	s3,-1
    800018f4:	a881                	j	80001944 <set_priority+0xa6>
		printf("Priority is not right\n");
    800018f6:	00007517          	auipc	a0,0x7
    800018fa:	8e250513          	addi	a0,a0,-1822 # 800081d8 <digits+0x198>
    800018fe:	fffff097          	auipc	ra,0xfffff
    80001902:	c90080e7          	jalr	-880(ra) # 8000058e <printf>
		return -1;
    80001906:	59fd                	li	s3,-1
    80001908:	a835                	j	80001944 <set_priority+0xa6>
			release(&i->lock);
    8000190a:	854a                	mv	a0,s2
    8000190c:	fffff097          	auipc	ra,0xfffff
    80001910:	392080e7          	jalr	914(ra) # 80000c9e <release>
		acquire(&i->lock);
    80001914:	854a                	mv	a0,s2
    80001916:	fffff097          	auipc	ra,0xfffff
    8000191a:	2d4080e7          	jalr	724(ra) # 80000bea <acquire>
		old_prior = i->sprior;
    8000191e:	19c4a983          	lw	s3,412(s1)
		i->sprior = static_prior;
    80001922:	1954ae23          	sw	s5,412(s1)
		i->niceness = 5;
    80001926:	4795                	li	a5,5
    80001928:	1af4a223          	sw	a5,420(s1)
		i->dprior = calculateDynamicPriority(i);
    8000192c:	8526                	mv	a0,s1
    8000192e:	00000097          	auipc	ra,0x0
    80001932:	f22080e7          	jalr	-222(ra) # 80001850 <calculateDynamicPriority>
    80001936:	1aa4a023          	sw	a0,416(s1)
		release(&i->lock);
    8000193a:	854a                	mv	a0,s2
    8000193c:	fffff097          	auipc	ra,0xfffff
    80001940:	362080e7          	jalr	866(ra) # 80000c9e <release>
	}
	return old_prior;
}
    80001944:	854e                	mv	a0,s3
    80001946:	70e2                	ld	ra,56(sp)
    80001948:	7442                	ld	s0,48(sp)
    8000194a:	74a2                	ld	s1,40(sp)
    8000194c:	7902                	ld	s2,32(sp)
    8000194e:	69e2                	ld	s3,24(sp)
    80001950:	6a42                	ld	s4,16(sp)
    80001952:	6aa2                	ld	s5,8(sp)
    80001954:	6121                	addi	sp,sp,64
    80001956:	8082                	ret

0000000080001958 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    80001958:	7139                	addi	sp,sp,-64
    8000195a:	fc06                	sd	ra,56(sp)
    8000195c:	f822                	sd	s0,48(sp)
    8000195e:	f426                	sd	s1,40(sp)
    80001960:	f04a                	sd	s2,32(sp)
    80001962:	ec4e                	sd	s3,24(sp)
    80001964:	e852                	sd	s4,16(sp)
    80001966:	e456                	sd	s5,8(sp)
    80001968:	e05a                	sd	s6,0(sp)
    8000196a:	0080                	addi	s0,sp,64
    8000196c:	89aa                	mv	s3,a0
	struct proc *p;

	for (p = proc; p < &proc[NPROC]; p++)
    8000196e:	00010497          	auipc	s1,0x10
    80001972:	91248493          	addi	s1,s1,-1774 # 80011280 <proc>
	{
		char *pa = kalloc();
		if (pa == 0)
			panic("kalloc");
		uint64 va = KSTACK((int)(p - proc));
    80001976:	8b26                	mv	s6,s1
    80001978:	00006a97          	auipc	s5,0x6
    8000197c:	688a8a93          	addi	s5,s5,1672 # 80008000 <etext>
    80001980:	04000937          	lui	s2,0x4000
    80001984:	197d                	addi	s2,s2,-1
    80001986:	0932                	slli	s2,s2,0xc
	for (p = proc; p < &proc[NPROC]; p++)
    80001988:	00017a17          	auipc	s4,0x17
    8000198c:	cf8a0a13          	addi	s4,s4,-776 # 80018680 <tickslock>
		char *pa = kalloc();
    80001990:	fffff097          	auipc	ra,0xfffff
    80001994:	16a080e7          	jalr	362(ra) # 80000afa <kalloc>
    80001998:	862a                	mv	a2,a0
		if (pa == 0)
    8000199a:	c131                	beqz	a0,800019de <proc_mapstacks+0x86>
		uint64 va = KSTACK((int)(p - proc));
    8000199c:	416485b3          	sub	a1,s1,s6
    800019a0:	8591                	srai	a1,a1,0x4
    800019a2:	000ab783          	ld	a5,0(s5)
    800019a6:	02f585b3          	mul	a1,a1,a5
    800019aa:	2585                	addiw	a1,a1,1
    800019ac:	00d5959b          	slliw	a1,a1,0xd
		kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800019b0:	4719                	li	a4,6
    800019b2:	6685                	lui	a3,0x1
    800019b4:	40b905b3          	sub	a1,s2,a1
    800019b8:	854e                	mv	a0,s3
    800019ba:	fffff097          	auipc	ra,0xfffff
    800019be:	7a0080e7          	jalr	1952(ra) # 8000115a <kvmmap>
	for (p = proc; p < &proc[NPROC]; p++)
    800019c2:	1d048493          	addi	s1,s1,464
    800019c6:	fd4495e3          	bne	s1,s4,80001990 <proc_mapstacks+0x38>
	}
}
    800019ca:	70e2                	ld	ra,56(sp)
    800019cc:	7442                	ld	s0,48(sp)
    800019ce:	74a2                	ld	s1,40(sp)
    800019d0:	7902                	ld	s2,32(sp)
    800019d2:	69e2                	ld	s3,24(sp)
    800019d4:	6a42                	ld	s4,16(sp)
    800019d6:	6aa2                	ld	s5,8(sp)
    800019d8:	6b02                	ld	s6,0(sp)
    800019da:	6121                	addi	sp,sp,64
    800019dc:	8082                	ret
			panic("kalloc");
    800019de:	00007517          	auipc	a0,0x7
    800019e2:	81250513          	addi	a0,a0,-2030 # 800081f0 <digits+0x1b0>
    800019e6:	fffff097          	auipc	ra,0xfffff
    800019ea:	b5e080e7          	jalr	-1186(ra) # 80000544 <panic>

00000000800019ee <procinit>:

// initialize the proc table.
void procinit(void)
{
    800019ee:	7139                	addi	sp,sp,-64
    800019f0:	fc06                	sd	ra,56(sp)
    800019f2:	f822                	sd	s0,48(sp)
    800019f4:	f426                	sd	s1,40(sp)
    800019f6:	f04a                	sd	s2,32(sp)
    800019f8:	ec4e                	sd	s3,24(sp)
    800019fa:	e852                	sd	s4,16(sp)
    800019fc:	e456                	sd	s5,8(sp)
    800019fe:	e05a                	sd	s6,0(sp)
    80001a00:	0080                	addi	s0,sp,64
	struct proc *p;

	initlock(&pid_lock, "nextpid");
    80001a02:	00006597          	auipc	a1,0x6
    80001a06:	7f658593          	addi	a1,a1,2038 # 800081f8 <digits+0x1b8>
    80001a0a:	0000f517          	auipc	a0,0xf
    80001a0e:	44650513          	addi	a0,a0,1094 # 80010e50 <pid_lock>
    80001a12:	fffff097          	auipc	ra,0xfffff
    80001a16:	148080e7          	jalr	328(ra) # 80000b5a <initlock>
	initlock(&wait_lock, "wait_lock");
    80001a1a:	00006597          	auipc	a1,0x6
    80001a1e:	7e658593          	addi	a1,a1,2022 # 80008200 <digits+0x1c0>
    80001a22:	0000f517          	auipc	a0,0xf
    80001a26:	44650513          	addi	a0,a0,1094 # 80010e68 <wait_lock>
    80001a2a:	fffff097          	auipc	ra,0xfffff
    80001a2e:	130080e7          	jalr	304(ra) # 80000b5a <initlock>
	for (p = proc; p < &proc[NPROC]; p++)
    80001a32:	00010497          	auipc	s1,0x10
    80001a36:	84e48493          	addi	s1,s1,-1970 # 80011280 <proc>
	{
		initlock(&p->lock, "proc");
    80001a3a:	00006b17          	auipc	s6,0x6
    80001a3e:	7d6b0b13          	addi	s6,s6,2006 # 80008210 <digits+0x1d0>
		p->state = UNUSED;
		p->kstack = KSTACK((int)(p - proc));
    80001a42:	8aa6                	mv	s5,s1
    80001a44:	00006a17          	auipc	s4,0x6
    80001a48:	5bca0a13          	addi	s4,s4,1468 # 80008000 <etext>
    80001a4c:	04000937          	lui	s2,0x4000
    80001a50:	197d                	addi	s2,s2,-1
    80001a52:	0932                	slli	s2,s2,0xc
	for (p = proc; p < &proc[NPROC]; p++)
    80001a54:	00017997          	auipc	s3,0x17
    80001a58:	c2c98993          	addi	s3,s3,-980 # 80018680 <tickslock>
		initlock(&p->lock, "proc");
    80001a5c:	85da                	mv	a1,s6
    80001a5e:	00848513          	addi	a0,s1,8
    80001a62:	fffff097          	auipc	ra,0xfffff
    80001a66:	0f8080e7          	jalr	248(ra) # 80000b5a <initlock>
		p->state = UNUSED;
    80001a6a:	0204a023          	sw	zero,32(s1)
		p->kstack = KSTACK((int)(p - proc));
    80001a6e:	415487b3          	sub	a5,s1,s5
    80001a72:	8791                	srai	a5,a5,0x4
    80001a74:	000a3703          	ld	a4,0(s4)
    80001a78:	02e787b3          	mul	a5,a5,a4
    80001a7c:	2785                	addiw	a5,a5,1
    80001a7e:	00d7979b          	slliw	a5,a5,0xd
    80001a82:	40f907b3          	sub	a5,s2,a5
    80001a86:	e4bc                	sd	a5,72(s1)
	for (p = proc; p < &proc[NPROC]; p++)
    80001a88:	1d048493          	addi	s1,s1,464
    80001a8c:	fd3498e3          	bne	s1,s3,80001a5c <procinit+0x6e>
	}
}
    80001a90:	70e2                	ld	ra,56(sp)
    80001a92:	7442                	ld	s0,48(sp)
    80001a94:	74a2                	ld	s1,40(sp)
    80001a96:	7902                	ld	s2,32(sp)
    80001a98:	69e2                	ld	s3,24(sp)
    80001a9a:	6a42                	ld	s4,16(sp)
    80001a9c:	6aa2                	ld	s5,8(sp)
    80001a9e:	6b02                	ld	s6,0(sp)
    80001aa0:	6121                	addi	sp,sp,64
    80001aa2:	8082                	ret

0000000080001aa4 <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    80001aa4:	1141                	addi	sp,sp,-16
    80001aa6:	e422                	sd	s0,8(sp)
    80001aa8:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001aaa:	8512                	mv	a0,tp
	int id = r_tp();
	return id;
}
    80001aac:	2501                	sext.w	a0,a0
    80001aae:	6422                	ld	s0,8(sp)
    80001ab0:	0141                	addi	sp,sp,16
    80001ab2:	8082                	ret

0000000080001ab4 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001ab4:	1141                	addi	sp,sp,-16
    80001ab6:	e422                	sd	s0,8(sp)
    80001ab8:	0800                	addi	s0,sp,16
    80001aba:	8792                	mv	a5,tp
	int id = cpuid();
	struct cpu *c = &cpus[id];
    80001abc:	2781                	sext.w	a5,a5
    80001abe:	079e                	slli	a5,a5,0x7
	return c;
}
    80001ac0:	0000f517          	auipc	a0,0xf
    80001ac4:	3c050513          	addi	a0,a0,960 # 80010e80 <cpus>
    80001ac8:	953e                	add	a0,a0,a5
    80001aca:	6422                	ld	s0,8(sp)
    80001acc:	0141                	addi	sp,sp,16
    80001ace:	8082                	ret

0000000080001ad0 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001ad0:	1101                	addi	sp,sp,-32
    80001ad2:	ec06                	sd	ra,24(sp)
    80001ad4:	e822                	sd	s0,16(sp)
    80001ad6:	e426                	sd	s1,8(sp)
    80001ad8:	1000                	addi	s0,sp,32
	push_off();
    80001ada:	fffff097          	auipc	ra,0xfffff
    80001ade:	0c4080e7          	jalr	196(ra) # 80000b9e <push_off>
    80001ae2:	8792                	mv	a5,tp
	struct cpu *c = mycpu();
	struct proc *p = c->proc;
    80001ae4:	2781                	sext.w	a5,a5
    80001ae6:	079e                	slli	a5,a5,0x7
    80001ae8:	0000f717          	auipc	a4,0xf
    80001aec:	36870713          	addi	a4,a4,872 # 80010e50 <pid_lock>
    80001af0:	97ba                	add	a5,a5,a4
    80001af2:	7b84                	ld	s1,48(a5)
	pop_off();
    80001af4:	fffff097          	auipc	ra,0xfffff
    80001af8:	14a080e7          	jalr	330(ra) # 80000c3e <pop_off>
	return p;
}
    80001afc:	8526                	mv	a0,s1
    80001afe:	60e2                	ld	ra,24(sp)
    80001b00:	6442                	ld	s0,16(sp)
    80001b02:	64a2                	ld	s1,8(sp)
    80001b04:	6105                	addi	sp,sp,32
    80001b06:	8082                	ret

0000000080001b08 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001b08:	1141                	addi	sp,sp,-16
    80001b0a:	e406                	sd	ra,8(sp)
    80001b0c:	e022                	sd	s0,0(sp)
    80001b0e:	0800                	addi	s0,sp,16
	static int first = 1;

	// Still holding p->lock from scheduler.
	release(&myproc()->lock);
    80001b10:	00000097          	auipc	ra,0x0
    80001b14:	fc0080e7          	jalr	-64(ra) # 80001ad0 <myproc>
    80001b18:	0521                	addi	a0,a0,8
    80001b1a:	fffff097          	auipc	ra,0xfffff
    80001b1e:	184080e7          	jalr	388(ra) # 80000c9e <release>

	if (first)
    80001b22:	00007797          	auipc	a5,0x7
    80001b26:	e7e7a783          	lw	a5,-386(a5) # 800089a0 <first.2449>
    80001b2a:	eb89                	bnez	a5,80001b3c <forkret+0x34>
		// be run from main().
		first = 0;
		fsinit(ROOTDEV);
	}

	usertrapret();
    80001b2c:	00001097          	auipc	ra,0x1
    80001b30:	f18080e7          	jalr	-232(ra) # 80002a44 <usertrapret>
}
    80001b34:	60a2                	ld	ra,8(sp)
    80001b36:	6402                	ld	s0,0(sp)
    80001b38:	0141                	addi	sp,sp,16
    80001b3a:	8082                	ret
		first = 0;
    80001b3c:	00007797          	auipc	a5,0x7
    80001b40:	e607a223          	sw	zero,-412(a5) # 800089a0 <first.2449>
		fsinit(ROOTDEV);
    80001b44:	4505                	li	a0,1
    80001b46:	00002097          	auipc	ra,0x2
    80001b4a:	f12080e7          	jalr	-238(ra) # 80003a58 <fsinit>
    80001b4e:	bff9                	j	80001b2c <forkret+0x24>

0000000080001b50 <allocpid>:
{
    80001b50:	1101                	addi	sp,sp,-32
    80001b52:	ec06                	sd	ra,24(sp)
    80001b54:	e822                	sd	s0,16(sp)
    80001b56:	e426                	sd	s1,8(sp)
    80001b58:	e04a                	sd	s2,0(sp)
    80001b5a:	1000                	addi	s0,sp,32
	acquire(&pid_lock);
    80001b5c:	0000f917          	auipc	s2,0xf
    80001b60:	2f490913          	addi	s2,s2,756 # 80010e50 <pid_lock>
    80001b64:	854a                	mv	a0,s2
    80001b66:	fffff097          	auipc	ra,0xfffff
    80001b6a:	084080e7          	jalr	132(ra) # 80000bea <acquire>
	pid = nextpid;
    80001b6e:	00007797          	auipc	a5,0x7
    80001b72:	e3678793          	addi	a5,a5,-458 # 800089a4 <nextpid>
    80001b76:	4384                	lw	s1,0(a5)
	nextpid = nextpid + 1;
    80001b78:	0014871b          	addiw	a4,s1,1
    80001b7c:	c398                	sw	a4,0(a5)
	release(&pid_lock);
    80001b7e:	854a                	mv	a0,s2
    80001b80:	fffff097          	auipc	ra,0xfffff
    80001b84:	11e080e7          	jalr	286(ra) # 80000c9e <release>
}
    80001b88:	8526                	mv	a0,s1
    80001b8a:	60e2                	ld	ra,24(sp)
    80001b8c:	6442                	ld	s0,16(sp)
    80001b8e:	64a2                	ld	s1,8(sp)
    80001b90:	6902                	ld	s2,0(sp)
    80001b92:	6105                	addi	sp,sp,32
    80001b94:	8082                	ret

0000000080001b96 <proc_pagetable>:
{
    80001b96:	1101                	addi	sp,sp,-32
    80001b98:	ec06                	sd	ra,24(sp)
    80001b9a:	e822                	sd	s0,16(sp)
    80001b9c:	e426                	sd	s1,8(sp)
    80001b9e:	e04a                	sd	s2,0(sp)
    80001ba0:	1000                	addi	s0,sp,32
    80001ba2:	892a                	mv	s2,a0
	pagetable = uvmcreate();
    80001ba4:	fffff097          	auipc	ra,0xfffff
    80001ba8:	7a0080e7          	jalr	1952(ra) # 80001344 <uvmcreate>
    80001bac:	84aa                	mv	s1,a0
	if (pagetable == 0)
    80001bae:	c121                	beqz	a0,80001bee <proc_pagetable+0x58>
	if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001bb0:	4729                	li	a4,10
    80001bb2:	00005697          	auipc	a3,0x5
    80001bb6:	44e68693          	addi	a3,a3,1102 # 80007000 <_trampoline>
    80001bba:	6605                	lui	a2,0x1
    80001bbc:	040005b7          	lui	a1,0x4000
    80001bc0:	15fd                	addi	a1,a1,-1
    80001bc2:	05b2                	slli	a1,a1,0xc
    80001bc4:	fffff097          	auipc	ra,0xfffff
    80001bc8:	4f6080e7          	jalr	1270(ra) # 800010ba <mappages>
    80001bcc:	02054863          	bltz	a0,80001bfc <proc_pagetable+0x66>
	if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001bd0:	4719                	li	a4,6
    80001bd2:	06093683          	ld	a3,96(s2)
    80001bd6:	6605                	lui	a2,0x1
    80001bd8:	020005b7          	lui	a1,0x2000
    80001bdc:	15fd                	addi	a1,a1,-1
    80001bde:	05b6                	slli	a1,a1,0xd
    80001be0:	8526                	mv	a0,s1
    80001be2:	fffff097          	auipc	ra,0xfffff
    80001be6:	4d8080e7          	jalr	1240(ra) # 800010ba <mappages>
    80001bea:	02054163          	bltz	a0,80001c0c <proc_pagetable+0x76>
}
    80001bee:	8526                	mv	a0,s1
    80001bf0:	60e2                	ld	ra,24(sp)
    80001bf2:	6442                	ld	s0,16(sp)
    80001bf4:	64a2                	ld	s1,8(sp)
    80001bf6:	6902                	ld	s2,0(sp)
    80001bf8:	6105                	addi	sp,sp,32
    80001bfa:	8082                	ret
		uvmfree(pagetable, 0);
    80001bfc:	4581                	li	a1,0
    80001bfe:	8526                	mv	a0,s1
    80001c00:	00000097          	auipc	ra,0x0
    80001c04:	948080e7          	jalr	-1720(ra) # 80001548 <uvmfree>
		return 0;
    80001c08:	4481                	li	s1,0
    80001c0a:	b7d5                	j	80001bee <proc_pagetable+0x58>
		uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c0c:	4681                	li	a3,0
    80001c0e:	4605                	li	a2,1
    80001c10:	040005b7          	lui	a1,0x4000
    80001c14:	15fd                	addi	a1,a1,-1
    80001c16:	05b2                	slli	a1,a1,0xc
    80001c18:	8526                	mv	a0,s1
    80001c1a:	fffff097          	auipc	ra,0xfffff
    80001c1e:	666080e7          	jalr	1638(ra) # 80001280 <uvmunmap>
		uvmfree(pagetable, 0);
    80001c22:	4581                	li	a1,0
    80001c24:	8526                	mv	a0,s1
    80001c26:	00000097          	auipc	ra,0x0
    80001c2a:	922080e7          	jalr	-1758(ra) # 80001548 <uvmfree>
		return 0;
    80001c2e:	4481                	li	s1,0
    80001c30:	bf7d                	j	80001bee <proc_pagetable+0x58>

0000000080001c32 <proc_freepagetable>:
{
    80001c32:	1101                	addi	sp,sp,-32
    80001c34:	ec06                	sd	ra,24(sp)
    80001c36:	e822                	sd	s0,16(sp)
    80001c38:	e426                	sd	s1,8(sp)
    80001c3a:	e04a                	sd	s2,0(sp)
    80001c3c:	1000                	addi	s0,sp,32
    80001c3e:	84aa                	mv	s1,a0
    80001c40:	892e                	mv	s2,a1
	uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c42:	4681                	li	a3,0
    80001c44:	4605                	li	a2,1
    80001c46:	040005b7          	lui	a1,0x4000
    80001c4a:	15fd                	addi	a1,a1,-1
    80001c4c:	05b2                	slli	a1,a1,0xc
    80001c4e:	fffff097          	auipc	ra,0xfffff
    80001c52:	632080e7          	jalr	1586(ra) # 80001280 <uvmunmap>
	uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001c56:	4681                	li	a3,0
    80001c58:	4605                	li	a2,1
    80001c5a:	020005b7          	lui	a1,0x2000
    80001c5e:	15fd                	addi	a1,a1,-1
    80001c60:	05b6                	slli	a1,a1,0xd
    80001c62:	8526                	mv	a0,s1
    80001c64:	fffff097          	auipc	ra,0xfffff
    80001c68:	61c080e7          	jalr	1564(ra) # 80001280 <uvmunmap>
	uvmfree(pagetable, sz);
    80001c6c:	85ca                	mv	a1,s2
    80001c6e:	8526                	mv	a0,s1
    80001c70:	00000097          	auipc	ra,0x0
    80001c74:	8d8080e7          	jalr	-1832(ra) # 80001548 <uvmfree>
}
    80001c78:	60e2                	ld	ra,24(sp)
    80001c7a:	6442                	ld	s0,16(sp)
    80001c7c:	64a2                	ld	s1,8(sp)
    80001c7e:	6902                	ld	s2,0(sp)
    80001c80:	6105                	addi	sp,sp,32
    80001c82:	8082                	ret

0000000080001c84 <freeproc>:
{
    80001c84:	1101                	addi	sp,sp,-32
    80001c86:	ec06                	sd	ra,24(sp)
    80001c88:	e822                	sd	s0,16(sp)
    80001c8a:	e426                	sd	s1,8(sp)
    80001c8c:	1000                	addi	s0,sp,32
    80001c8e:	84aa                	mv	s1,a0
	if (p->trapframe)
    80001c90:	7128                	ld	a0,96(a0)
    80001c92:	c509                	beqz	a0,80001c9c <freeproc+0x18>
		kfree((void *)p->trapframe);
    80001c94:	fffff097          	auipc	ra,0xfffff
    80001c98:	d6a080e7          	jalr	-662(ra) # 800009fe <kfree>
	p->trapframe = 0;
    80001c9c:	0604b023          	sd	zero,96(s1)
	if (p->pagetable)
    80001ca0:	6ca8                	ld	a0,88(s1)
    80001ca2:	c511                	beqz	a0,80001cae <freeproc+0x2a>
		proc_freepagetable(p->pagetable, p->sz);
    80001ca4:	68ac                	ld	a1,80(s1)
    80001ca6:	00000097          	auipc	ra,0x0
    80001caa:	f8c080e7          	jalr	-116(ra) # 80001c32 <proc_freepagetable>
	p->pagetable = 0;
    80001cae:	0404bc23          	sd	zero,88(s1)
	p->sz = 0;
    80001cb2:	0404b823          	sd	zero,80(s1)
	p->pid = 0;
    80001cb6:	0204ac23          	sw	zero,56(s1)
	p->parent = 0;
    80001cba:	0404b023          	sd	zero,64(s1)
	p->name[0] = 0;
    80001cbe:	16048023          	sb	zero,352(s1)
	p->chan = 0;
    80001cc2:	0204b423          	sd	zero,40(s1)
	p->killed = 0;
    80001cc6:	0204a823          	sw	zero,48(s1)
	p->xstate = 0;
    80001cca:	0204aa23          	sw	zero,52(s1)
	p->state = UNUSED;
    80001cce:	0204a023          	sw	zero,32(s1)
}
    80001cd2:	60e2                	ld	ra,24(sp)
    80001cd4:	6442                	ld	s0,16(sp)
    80001cd6:	64a2                	ld	s1,8(sp)
    80001cd8:	6105                	addi	sp,sp,32
    80001cda:	8082                	ret

0000000080001cdc <allocproc>:
{
    80001cdc:	7179                	addi	sp,sp,-48
    80001cde:	f406                	sd	ra,40(sp)
    80001ce0:	f022                	sd	s0,32(sp)
    80001ce2:	ec26                	sd	s1,24(sp)
    80001ce4:	e84a                	sd	s2,16(sp)
    80001ce6:	e44e                	sd	s3,8(sp)
    80001ce8:	1800                	addi	s0,sp,48
	for (p = proc; p < &proc[NPROC]; p++)
    80001cea:	0000f497          	auipc	s1,0xf
    80001cee:	59648493          	addi	s1,s1,1430 # 80011280 <proc>
    80001cf2:	00017997          	auipc	s3,0x17
    80001cf6:	98e98993          	addi	s3,s3,-1650 # 80018680 <tickslock>
		acquire(&p->lock);
    80001cfa:	00848913          	addi	s2,s1,8
    80001cfe:	854a                	mv	a0,s2
    80001d00:	fffff097          	auipc	ra,0xfffff
    80001d04:	eea080e7          	jalr	-278(ra) # 80000bea <acquire>
		if (p->state == UNUSED)
    80001d08:	509c                	lw	a5,32(s1)
    80001d0a:	cf81                	beqz	a5,80001d22 <allocproc+0x46>
			release(&p->lock);
    80001d0c:	854a                	mv	a0,s2
    80001d0e:	fffff097          	auipc	ra,0xfffff
    80001d12:	f90080e7          	jalr	-112(ra) # 80000c9e <release>
	for (p = proc; p < &proc[NPROC]; p++)
    80001d16:	1d048493          	addi	s1,s1,464
    80001d1a:	ff3490e3          	bne	s1,s3,80001cfa <allocproc+0x1e>
	return 0;
    80001d1e:	4481                	li	s1,0
    80001d20:	a041                	j	80001da0 <allocproc+0xc4>
	p->pid = allocpid();
    80001d22:	00000097          	auipc	ra,0x0
    80001d26:	e2e080e7          	jalr	-466(ra) # 80001b50 <allocpid>
    80001d2a:	dc88                	sw	a0,56(s1)
	p->state = USED;
    80001d2c:	4785                	li	a5,1
    80001d2e:	d09c                	sw	a5,32(s1)
	if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001d30:	fffff097          	auipc	ra,0xfffff
    80001d34:	dca080e7          	jalr	-566(ra) # 80000afa <kalloc>
    80001d38:	89aa                	mv	s3,a0
    80001d3a:	f0a8                	sd	a0,96(s1)
    80001d3c:	c935                	beqz	a0,80001db0 <allocproc+0xd4>
	p->pagetable = proc_pagetable(p);
    80001d3e:	8526                	mv	a0,s1
    80001d40:	00000097          	auipc	ra,0x0
    80001d44:	e56080e7          	jalr	-426(ra) # 80001b96 <proc_pagetable>
    80001d48:	89aa                	mv	s3,a0
    80001d4a:	eca8                	sd	a0,88(s1)
	if (p->pagetable == 0)
    80001d4c:	cd35                	beqz	a0,80001dc8 <allocproc+0xec>
	memset(&p->context, 0, sizeof(p->context));
    80001d4e:	07000613          	li	a2,112
    80001d52:	4581                	li	a1,0
    80001d54:	06848513          	addi	a0,s1,104
    80001d58:	fffff097          	auipc	ra,0xfffff
    80001d5c:	f8e080e7          	jalr	-114(ra) # 80000ce6 <memset>
	p->context.ra = (uint64)forkret;
    80001d60:	00000797          	auipc	a5,0x0
    80001d64:	da878793          	addi	a5,a5,-600 # 80001b08 <forkret>
    80001d68:	f4bc                	sd	a5,104(s1)
	p->context.sp = p->kstack + PGSIZE;
    80001d6a:	64bc                	ld	a5,72(s1)
    80001d6c:	6705                	lui	a4,0x1
    80001d6e:	97ba                	add	a5,a5,a4
    80001d70:	f8bc                	sd	a5,112(s1)
	p->creationTime = ticks;
    80001d72:	00007797          	auipc	a5,0x7
    80001d76:	e6e7a783          	lw	a5,-402(a5) # 80008be0 <ticks>
    80001d7a:	16f4ae23          	sw	a5,380(s1)
	p->sprior = 60;
    80001d7e:	03c00793          	li	a5,60
    80001d82:	18f4ae23          	sw	a5,412(s1)
	p->niceness = 5;
    80001d86:	4795                	li	a5,5
    80001d88:	1af4a223          	sw	a5,420(s1)
	p->runTime = 0;
    80001d8c:	1804a023          	sw	zero,384(s1)
	p->endTime = 0;
    80001d90:	1804a223          	sw	zero,388(s1)
	p->runTimePrev = 0;
    80001d94:	1804aa23          	sw	zero,404(s1)
	p->sleepTimePrev = 0;
    80001d98:	1804a623          	sw	zero,396(s1)
	p->sleepStartTime = 0;
    80001d9c:	1804a823          	sw	zero,400(s1)
}
    80001da0:	8526                	mv	a0,s1
    80001da2:	70a2                	ld	ra,40(sp)
    80001da4:	7402                	ld	s0,32(sp)
    80001da6:	64e2                	ld	s1,24(sp)
    80001da8:	6942                	ld	s2,16(sp)
    80001daa:	69a2                	ld	s3,8(sp)
    80001dac:	6145                	addi	sp,sp,48
    80001dae:	8082                	ret
		freeproc(p);
    80001db0:	8526                	mv	a0,s1
    80001db2:	00000097          	auipc	ra,0x0
    80001db6:	ed2080e7          	jalr	-302(ra) # 80001c84 <freeproc>
		release(&p->lock);
    80001dba:	854a                	mv	a0,s2
    80001dbc:	fffff097          	auipc	ra,0xfffff
    80001dc0:	ee2080e7          	jalr	-286(ra) # 80000c9e <release>
		return 0;
    80001dc4:	84ce                	mv	s1,s3
    80001dc6:	bfe9                	j	80001da0 <allocproc+0xc4>
		freeproc(p);
    80001dc8:	8526                	mv	a0,s1
    80001dca:	00000097          	auipc	ra,0x0
    80001dce:	eba080e7          	jalr	-326(ra) # 80001c84 <freeproc>
		release(&p->lock);
    80001dd2:	854a                	mv	a0,s2
    80001dd4:	fffff097          	auipc	ra,0xfffff
    80001dd8:	eca080e7          	jalr	-310(ra) # 80000c9e <release>
		return 0;
    80001ddc:	84ce                	mv	s1,s3
    80001dde:	b7c9                	j	80001da0 <allocproc+0xc4>

0000000080001de0 <userinit>:
{
    80001de0:	1101                	addi	sp,sp,-32
    80001de2:	ec06                	sd	ra,24(sp)
    80001de4:	e822                	sd	s0,16(sp)
    80001de6:	e426                	sd	s1,8(sp)
    80001de8:	1000                	addi	s0,sp,32
	p = allocproc();
    80001dea:	00000097          	auipc	ra,0x0
    80001dee:	ef2080e7          	jalr	-270(ra) # 80001cdc <allocproc>
    80001df2:	84aa                	mv	s1,a0
	initproc = p;
    80001df4:	00007797          	auipc	a5,0x7
    80001df8:	dea7b223          	sd	a0,-540(a5) # 80008bd8 <initproc>
	uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001dfc:	03400613          	li	a2,52
    80001e00:	00007597          	auipc	a1,0x7
    80001e04:	bb058593          	addi	a1,a1,-1104 # 800089b0 <initcode>
    80001e08:	6d28                	ld	a0,88(a0)
    80001e0a:	fffff097          	auipc	ra,0xfffff
    80001e0e:	568080e7          	jalr	1384(ra) # 80001372 <uvmfirst>
	p->sz = PGSIZE;
    80001e12:	6785                	lui	a5,0x1
    80001e14:	e8bc                	sd	a5,80(s1)
	p->trapframe->epc = 0;	   // user program counter
    80001e16:	70b8                	ld	a4,96(s1)
    80001e18:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
	p->trapframe->sp = PGSIZE; // user stack pointer
    80001e1c:	70b8                	ld	a4,96(s1)
    80001e1e:	fb1c                	sd	a5,48(a4)
	safestrcpy(p->name, "initcode", sizeof(p->name));
    80001e20:	4641                	li	a2,16
    80001e22:	00006597          	auipc	a1,0x6
    80001e26:	3f658593          	addi	a1,a1,1014 # 80008218 <digits+0x1d8>
    80001e2a:	16048513          	addi	a0,s1,352
    80001e2e:	fffff097          	auipc	ra,0xfffff
    80001e32:	00a080e7          	jalr	10(ra) # 80000e38 <safestrcpy>
	p->cwd = namei("/");
    80001e36:	00006517          	auipc	a0,0x6
    80001e3a:	3f250513          	addi	a0,a0,1010 # 80008228 <digits+0x1e8>
    80001e3e:	00002097          	auipc	ra,0x2
    80001e42:	63c080e7          	jalr	1596(ra) # 8000447a <namei>
    80001e46:	14a4bc23          	sd	a0,344(s1)
	p->state = RUNNABLE;
    80001e4a:	478d                	li	a5,3
    80001e4c:	d09c                	sw	a5,32(s1)
	release(&p->lock);
    80001e4e:	00848513          	addi	a0,s1,8
    80001e52:	fffff097          	auipc	ra,0xfffff
    80001e56:	e4c080e7          	jalr	-436(ra) # 80000c9e <release>
}
    80001e5a:	60e2                	ld	ra,24(sp)
    80001e5c:	6442                	ld	s0,16(sp)
    80001e5e:	64a2                	ld	s1,8(sp)
    80001e60:	6105                	addi	sp,sp,32
    80001e62:	8082                	ret

0000000080001e64 <growproc>:
{
    80001e64:	1101                	addi	sp,sp,-32
    80001e66:	ec06                	sd	ra,24(sp)
    80001e68:	e822                	sd	s0,16(sp)
    80001e6a:	e426                	sd	s1,8(sp)
    80001e6c:	e04a                	sd	s2,0(sp)
    80001e6e:	1000                	addi	s0,sp,32
    80001e70:	892a                	mv	s2,a0
	struct proc *p = myproc();
    80001e72:	00000097          	auipc	ra,0x0
    80001e76:	c5e080e7          	jalr	-930(ra) # 80001ad0 <myproc>
    80001e7a:	84aa                	mv	s1,a0
	sz = p->sz;
    80001e7c:	692c                	ld	a1,80(a0)
	if (n > 0)
    80001e7e:	01204c63          	bgtz	s2,80001e96 <growproc+0x32>
	else if (n < 0)
    80001e82:	02094663          	bltz	s2,80001eae <growproc+0x4a>
	p->sz = sz;
    80001e86:	e8ac                	sd	a1,80(s1)
	return 0;
    80001e88:	4501                	li	a0,0
}
    80001e8a:	60e2                	ld	ra,24(sp)
    80001e8c:	6442                	ld	s0,16(sp)
    80001e8e:	64a2                	ld	s1,8(sp)
    80001e90:	6902                	ld	s2,0(sp)
    80001e92:	6105                	addi	sp,sp,32
    80001e94:	8082                	ret
		if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001e96:	4691                	li	a3,4
    80001e98:	00b90633          	add	a2,s2,a1
    80001e9c:	6d28                	ld	a0,88(a0)
    80001e9e:	fffff097          	auipc	ra,0xfffff
    80001ea2:	58e080e7          	jalr	1422(ra) # 8000142c <uvmalloc>
    80001ea6:	85aa                	mv	a1,a0
    80001ea8:	fd79                	bnez	a0,80001e86 <growproc+0x22>
			return -1;
    80001eaa:	557d                	li	a0,-1
    80001eac:	bff9                	j	80001e8a <growproc+0x26>
		sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001eae:	00b90633          	add	a2,s2,a1
    80001eb2:	6d28                	ld	a0,88(a0)
    80001eb4:	fffff097          	auipc	ra,0xfffff
    80001eb8:	530080e7          	jalr	1328(ra) # 800013e4 <uvmdealloc>
    80001ebc:	85aa                	mv	a1,a0
    80001ebe:	b7e1                	j	80001e86 <growproc+0x22>

0000000080001ec0 <fork>:
{
    80001ec0:	7139                	addi	sp,sp,-64
    80001ec2:	fc06                	sd	ra,56(sp)
    80001ec4:	f822                	sd	s0,48(sp)
    80001ec6:	f426                	sd	s1,40(sp)
    80001ec8:	f04a                	sd	s2,32(sp)
    80001eca:	ec4e                	sd	s3,24(sp)
    80001ecc:	e852                	sd	s4,16(sp)
    80001ece:	e456                	sd	s5,8(sp)
    80001ed0:	0080                	addi	s0,sp,64
	struct proc *p = myproc();
    80001ed2:	00000097          	auipc	ra,0x0
    80001ed6:	bfe080e7          	jalr	-1026(ra) # 80001ad0 <myproc>
    80001eda:	892a                	mv	s2,a0
	if ((np = allocproc()) == 0)
    80001edc:	00000097          	auipc	ra,0x0
    80001ee0:	e00080e7          	jalr	-512(ra) # 80001cdc <allocproc>
    80001ee4:	12050363          	beqz	a0,8000200a <fork+0x14a>
    80001ee8:	89aa                	mv	s3,a0
	if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001eea:	05093603          	ld	a2,80(s2)
    80001eee:	6d2c                	ld	a1,88(a0)
    80001ef0:	05893503          	ld	a0,88(s2)
    80001ef4:	fffff097          	auipc	ra,0xfffff
    80001ef8:	68c080e7          	jalr	1676(ra) # 80001580 <uvmcopy>
    80001efc:	04054a63          	bltz	a0,80001f50 <fork+0x90>
	np->mask = p->mask; // copying mask so that we can also trace child processes
    80001f00:	00092783          	lw	a5,0(s2)
    80001f04:	00f9a023          	sw	a5,0(s3)
	np->sz = p->sz;
    80001f08:	05093783          	ld	a5,80(s2)
    80001f0c:	04f9b823          	sd	a5,80(s3)
	*(np->trapframe) = *(p->trapframe);
    80001f10:	06093683          	ld	a3,96(s2)
    80001f14:	87b6                	mv	a5,a3
    80001f16:	0609b703          	ld	a4,96(s3)
    80001f1a:	12068693          	addi	a3,a3,288
    80001f1e:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001f22:	6788                	ld	a0,8(a5)
    80001f24:	6b8c                	ld	a1,16(a5)
    80001f26:	6f90                	ld	a2,24(a5)
    80001f28:	01073023          	sd	a6,0(a4)
    80001f2c:	e708                	sd	a0,8(a4)
    80001f2e:	eb0c                	sd	a1,16(a4)
    80001f30:	ef10                	sd	a2,24(a4)
    80001f32:	02078793          	addi	a5,a5,32
    80001f36:	02070713          	addi	a4,a4,32
    80001f3a:	fed792e3          	bne	a5,a3,80001f1e <fork+0x5e>
	np->trapframe->a0 = 0;
    80001f3e:	0609b783          	ld	a5,96(s3)
    80001f42:	0607b823          	sd	zero,112(a5)
    80001f46:	0d800493          	li	s1,216
	for (i = 0; i < NOFILE; i++)
    80001f4a:	15800a13          	li	s4,344
    80001f4e:	a805                	j	80001f7e <fork+0xbe>
		freeproc(np);
    80001f50:	854e                	mv	a0,s3
    80001f52:	00000097          	auipc	ra,0x0
    80001f56:	d32080e7          	jalr	-718(ra) # 80001c84 <freeproc>
		release(&np->lock);
    80001f5a:	00898513          	addi	a0,s3,8
    80001f5e:	fffff097          	auipc	ra,0xfffff
    80001f62:	d40080e7          	jalr	-704(ra) # 80000c9e <release>
		return -1;
    80001f66:	5afd                	li	s5,-1
    80001f68:	a079                	j	80001ff6 <fork+0x136>
			np->ofile[i] = filedup(p->ofile[i]);
    80001f6a:	00003097          	auipc	ra,0x3
    80001f6e:	ba6080e7          	jalr	-1114(ra) # 80004b10 <filedup>
    80001f72:	009987b3          	add	a5,s3,s1
    80001f76:	e388                	sd	a0,0(a5)
	for (i = 0; i < NOFILE; i++)
    80001f78:	04a1                	addi	s1,s1,8
    80001f7a:	01448763          	beq	s1,s4,80001f88 <fork+0xc8>
		if (p->ofile[i])
    80001f7e:	009907b3          	add	a5,s2,s1
    80001f82:	6388                	ld	a0,0(a5)
    80001f84:	f17d                	bnez	a0,80001f6a <fork+0xaa>
    80001f86:	bfcd                	j	80001f78 <fork+0xb8>
	np->cwd = idup(p->cwd);
    80001f88:	15893503          	ld	a0,344(s2)
    80001f8c:	00002097          	auipc	ra,0x2
    80001f90:	d0a080e7          	jalr	-758(ra) # 80003c96 <idup>
    80001f94:	14a9bc23          	sd	a0,344(s3)
	safestrcpy(np->name, p->name, sizeof(p->name));
    80001f98:	4641                	li	a2,16
    80001f9a:	16090593          	addi	a1,s2,352
    80001f9e:	16098513          	addi	a0,s3,352
    80001fa2:	fffff097          	auipc	ra,0xfffff
    80001fa6:	e96080e7          	jalr	-362(ra) # 80000e38 <safestrcpy>
	pid = np->pid;
    80001faa:	0389aa83          	lw	s5,56(s3)
	release(&np->lock);
    80001fae:	00898493          	addi	s1,s3,8
    80001fb2:	8526                	mv	a0,s1
    80001fb4:	fffff097          	auipc	ra,0xfffff
    80001fb8:	cea080e7          	jalr	-790(ra) # 80000c9e <release>
	acquire(&wait_lock);
    80001fbc:	0000fa17          	auipc	s4,0xf
    80001fc0:	eaca0a13          	addi	s4,s4,-340 # 80010e68 <wait_lock>
    80001fc4:	8552                	mv	a0,s4
    80001fc6:	fffff097          	auipc	ra,0xfffff
    80001fca:	c24080e7          	jalr	-988(ra) # 80000bea <acquire>
	np->parent = p;
    80001fce:	0529b023          	sd	s2,64(s3)
	release(&wait_lock);
    80001fd2:	8552                	mv	a0,s4
    80001fd4:	fffff097          	auipc	ra,0xfffff
    80001fd8:	cca080e7          	jalr	-822(ra) # 80000c9e <release>
	acquire(&np->lock);
    80001fdc:	8526                	mv	a0,s1
    80001fde:	fffff097          	auipc	ra,0xfffff
    80001fe2:	c0c080e7          	jalr	-1012(ra) # 80000bea <acquire>
	np->state = RUNNABLE;
    80001fe6:	478d                	li	a5,3
    80001fe8:	02f9a023          	sw	a5,32(s3)
	release(&np->lock);
    80001fec:	8526                	mv	a0,s1
    80001fee:	fffff097          	auipc	ra,0xfffff
    80001ff2:	cb0080e7          	jalr	-848(ra) # 80000c9e <release>
}
    80001ff6:	8556                	mv	a0,s5
    80001ff8:	70e2                	ld	ra,56(sp)
    80001ffa:	7442                	ld	s0,48(sp)
    80001ffc:	74a2                	ld	s1,40(sp)
    80001ffe:	7902                	ld	s2,32(sp)
    80002000:	69e2                	ld	s3,24(sp)
    80002002:	6a42                	ld	s4,16(sp)
    80002004:	6aa2                	ld	s5,8(sp)
    80002006:	6121                	addi	sp,sp,64
    80002008:	8082                	ret
		return -1;
    8000200a:	5afd                	li	s5,-1
    8000200c:	b7ed                	j	80001ff6 <fork+0x136>

000000008000200e <upd_time>:
{
    8000200e:	7179                	addi	sp,sp,-48
    80002010:	f406                	sd	ra,40(sp)
    80002012:	f022                	sd	s0,32(sp)
    80002014:	ec26                	sd	s1,24(sp)
    80002016:	e84a                	sd	s2,16(sp)
    80002018:	e44e                	sd	s3,8(sp)
    8000201a:	e052                	sd	s4,0(sp)
    8000201c:	1800                	addi	s0,sp,48
	while (pr < &proc[NPROC])
    8000201e:	0000f497          	auipc	s1,0xf
    80002022:	26a48493          	addi	s1,s1,618 # 80011288 <proc+0x8>
    80002026:	00016a17          	auipc	s4,0x16
    8000202a:	662a0a13          	addi	s4,s4,1634 # 80018688 <tickslock+0x8>
		if (pr->state == RUNNING)
    8000202e:	4991                	li	s3,4
    80002030:	a811                	j	80002044 <upd_time+0x36>
		release(&pr->lock);
    80002032:	854a                	mv	a0,s2
    80002034:	fffff097          	auipc	ra,0xfffff
    80002038:	c6a080e7          	jalr	-918(ra) # 80000c9e <release>
	while (pr < &proc[NPROC])
    8000203c:	1d048493          	addi	s1,s1,464
    80002040:	03448663          	beq	s1,s4,8000206c <upd_time+0x5e>
		acquire(&pr->lock);
    80002044:	8926                	mv	s2,s1
    80002046:	8526                	mv	a0,s1
    80002048:	fffff097          	auipc	ra,0xfffff
    8000204c:	ba2080e7          	jalr	-1118(ra) # 80000bea <acquire>
		if (pr->state == RUNNING)
    80002050:	4c9c                	lw	a5,24(s1)
    80002052:	ff3790e3          	bne	a5,s3,80002032 <upd_time+0x24>
			pr->runTime++;
    80002056:	1784a783          	lw	a5,376(s1)
    8000205a:	2785                	addiw	a5,a5,1
    8000205c:	16f4ac23          	sw	a5,376(s1)
			pr->runTimePrev++;
    80002060:	18c4a783          	lw	a5,396(s1)
    80002064:	2785                	addiw	a5,a5,1
    80002066:	18f4a623          	sw	a5,396(s1)
    8000206a:	b7e1                	j	80002032 <upd_time+0x24>
}
    8000206c:	70a2                	ld	ra,40(sp)
    8000206e:	7402                	ld	s0,32(sp)
    80002070:	64e2                	ld	s1,24(sp)
    80002072:	6942                	ld	s2,16(sp)
    80002074:	69a2                	ld	s3,8(sp)
    80002076:	6a02                	ld	s4,0(sp)
    80002078:	6145                	addi	sp,sp,48
    8000207a:	8082                	ret

000000008000207c <scheduler>:
{
    8000207c:	715d                	addi	sp,sp,-80
    8000207e:	e486                	sd	ra,72(sp)
    80002080:	e0a2                	sd	s0,64(sp)
    80002082:	fc26                	sd	s1,56(sp)
    80002084:	f84a                	sd	s2,48(sp)
    80002086:	f44e                	sd	s3,40(sp)
    80002088:	f052                	sd	s4,32(sp)
    8000208a:	ec56                	sd	s5,24(sp)
    8000208c:	e85a                	sd	s6,16(sp)
    8000208e:	e45e                	sd	s7,8(sp)
    80002090:	0880                	addi	s0,sp,80
    80002092:	8792                	mv	a5,tp
	int id = r_tp();
    80002094:	2781                	sext.w	a5,a5
	c->proc = 0;
    80002096:	00779b13          	slli	s6,a5,0x7
    8000209a:	0000f717          	auipc	a4,0xf
    8000209e:	db670713          	addi	a4,a4,-586 # 80010e50 <pid_lock>
    800020a2:	975a                	add	a4,a4,s6
    800020a4:	02073823          	sd	zero,48(a4)
				swtch(&c->context, &p->context);
    800020a8:	0000f717          	auipc	a4,0xf
    800020ac:	de070713          	addi	a4,a4,-544 # 80010e88 <cpus+0x8>
    800020b0:	9b3a                	add	s6,s6,a4
			if (p->state == RUNNABLE)
    800020b2:	4a0d                	li	s4,3
				p->state = RUNNING;
    800020b4:	4b91                	li	s7,4
				c->proc = p;
    800020b6:	079e                	slli	a5,a5,0x7
    800020b8:	0000fa97          	auipc	s5,0xf
    800020bc:	d98a8a93          	addi	s5,s5,-616 # 80010e50 <pid_lock>
    800020c0:	9abe                	add	s5,s5,a5
		for (p = proc; p < &proc[NPROC]; p++)
    800020c2:	00016997          	auipc	s3,0x16
    800020c6:	5be98993          	addi	s3,s3,1470 # 80018680 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020ca:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800020ce:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800020d2:	10079073          	csrw	sstatus,a5
    800020d6:	0000f497          	auipc	s1,0xf
    800020da:	1aa48493          	addi	s1,s1,426 # 80011280 <proc>
    800020de:	a03d                	j	8000210c <scheduler+0x90>
				p->state = RUNNING;
    800020e0:	0374a023          	sw	s7,32(s1)
				c->proc = p;
    800020e4:	029ab823          	sd	s1,48(s5)
				swtch(&c->context, &p->context);
    800020e8:	06848593          	addi	a1,s1,104
    800020ec:	855a                	mv	a0,s6
    800020ee:	00001097          	auipc	ra,0x1
    800020f2:	8ac080e7          	jalr	-1876(ra) # 8000299a <swtch>
				c->proc = 0;
    800020f6:	020ab823          	sd	zero,48(s5)
			release(&p->lock);
    800020fa:	854a                	mv	a0,s2
    800020fc:	fffff097          	auipc	ra,0xfffff
    80002100:	ba2080e7          	jalr	-1118(ra) # 80000c9e <release>
		for (p = proc; p < &proc[NPROC]; p++)
    80002104:	1d048493          	addi	s1,s1,464
    80002108:	fd3481e3          	beq	s1,s3,800020ca <scheduler+0x4e>
			acquire(&p->lock);
    8000210c:	00848913          	addi	s2,s1,8
    80002110:	854a                	mv	a0,s2
    80002112:	fffff097          	auipc	ra,0xfffff
    80002116:	ad8080e7          	jalr	-1320(ra) # 80000bea <acquire>
			if (p->state == RUNNABLE)
    8000211a:	509c                	lw	a5,32(s1)
    8000211c:	fd479fe3          	bne	a5,s4,800020fa <scheduler+0x7e>
    80002120:	b7c1                	j	800020e0 <scheduler+0x64>

0000000080002122 <sched>:
{
    80002122:	7179                	addi	sp,sp,-48
    80002124:	f406                	sd	ra,40(sp)
    80002126:	f022                	sd	s0,32(sp)
    80002128:	ec26                	sd	s1,24(sp)
    8000212a:	e84a                	sd	s2,16(sp)
    8000212c:	e44e                	sd	s3,8(sp)
    8000212e:	1800                	addi	s0,sp,48
	struct proc *p = myproc();
    80002130:	00000097          	auipc	ra,0x0
    80002134:	9a0080e7          	jalr	-1632(ra) # 80001ad0 <myproc>
    80002138:	84aa                	mv	s1,a0
	if (!holding(&p->lock))
    8000213a:	0521                	addi	a0,a0,8
    8000213c:	fffff097          	auipc	ra,0xfffff
    80002140:	a34080e7          	jalr	-1484(ra) # 80000b70 <holding>
    80002144:	c93d                	beqz	a0,800021ba <sched+0x98>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002146:	8792                	mv	a5,tp
	if (mycpu()->noff != 1)
    80002148:	2781                	sext.w	a5,a5
    8000214a:	079e                	slli	a5,a5,0x7
    8000214c:	0000f717          	auipc	a4,0xf
    80002150:	d0470713          	addi	a4,a4,-764 # 80010e50 <pid_lock>
    80002154:	97ba                	add	a5,a5,a4
    80002156:	0a87a703          	lw	a4,168(a5)
    8000215a:	4785                	li	a5,1
    8000215c:	06f71763          	bne	a4,a5,800021ca <sched+0xa8>
	if (p->state == RUNNING)
    80002160:	5098                	lw	a4,32(s1)
    80002162:	4791                	li	a5,4
    80002164:	06f70b63          	beq	a4,a5,800021da <sched+0xb8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002168:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000216c:	8b89                	andi	a5,a5,2
	if (intr_get())
    8000216e:	efb5                	bnez	a5,800021ea <sched+0xc8>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002170:	8792                	mv	a5,tp
	intena = mycpu()->intena;
    80002172:	0000f917          	auipc	s2,0xf
    80002176:	cde90913          	addi	s2,s2,-802 # 80010e50 <pid_lock>
    8000217a:	2781                	sext.w	a5,a5
    8000217c:	079e                	slli	a5,a5,0x7
    8000217e:	97ca                	add	a5,a5,s2
    80002180:	0ac7a983          	lw	s3,172(a5)
    80002184:	8792                	mv	a5,tp
	swtch(&p->context, &mycpu()->context);
    80002186:	2781                	sext.w	a5,a5
    80002188:	079e                	slli	a5,a5,0x7
    8000218a:	0000f597          	auipc	a1,0xf
    8000218e:	cfe58593          	addi	a1,a1,-770 # 80010e88 <cpus+0x8>
    80002192:	95be                	add	a1,a1,a5
    80002194:	06848513          	addi	a0,s1,104
    80002198:	00001097          	auipc	ra,0x1
    8000219c:	802080e7          	jalr	-2046(ra) # 8000299a <swtch>
    800021a0:	8792                	mv	a5,tp
	mycpu()->intena = intena;
    800021a2:	2781                	sext.w	a5,a5
    800021a4:	079e                	slli	a5,a5,0x7
    800021a6:	97ca                	add	a5,a5,s2
    800021a8:	0b37a623          	sw	s3,172(a5)
}
    800021ac:	70a2                	ld	ra,40(sp)
    800021ae:	7402                	ld	s0,32(sp)
    800021b0:	64e2                	ld	s1,24(sp)
    800021b2:	6942                	ld	s2,16(sp)
    800021b4:	69a2                	ld	s3,8(sp)
    800021b6:	6145                	addi	sp,sp,48
    800021b8:	8082                	ret
		panic("sched p->lock");
    800021ba:	00006517          	auipc	a0,0x6
    800021be:	07650513          	addi	a0,a0,118 # 80008230 <digits+0x1f0>
    800021c2:	ffffe097          	auipc	ra,0xffffe
    800021c6:	382080e7          	jalr	898(ra) # 80000544 <panic>
		panic("sched locks");
    800021ca:	00006517          	auipc	a0,0x6
    800021ce:	07650513          	addi	a0,a0,118 # 80008240 <digits+0x200>
    800021d2:	ffffe097          	auipc	ra,0xffffe
    800021d6:	372080e7          	jalr	882(ra) # 80000544 <panic>
		panic("sched running");
    800021da:	00006517          	auipc	a0,0x6
    800021de:	07650513          	addi	a0,a0,118 # 80008250 <digits+0x210>
    800021e2:	ffffe097          	auipc	ra,0xffffe
    800021e6:	362080e7          	jalr	866(ra) # 80000544 <panic>
		panic("sched interruptible");
    800021ea:	00006517          	auipc	a0,0x6
    800021ee:	07650513          	addi	a0,a0,118 # 80008260 <digits+0x220>
    800021f2:	ffffe097          	auipc	ra,0xffffe
    800021f6:	352080e7          	jalr	850(ra) # 80000544 <panic>

00000000800021fa <yield>:
{
    800021fa:	1101                	addi	sp,sp,-32
    800021fc:	ec06                	sd	ra,24(sp)
    800021fe:	e822                	sd	s0,16(sp)
    80002200:	e426                	sd	s1,8(sp)
    80002202:	e04a                	sd	s2,0(sp)
    80002204:	1000                	addi	s0,sp,32
	struct proc *p = myproc();
    80002206:	00000097          	auipc	ra,0x0
    8000220a:	8ca080e7          	jalr	-1846(ra) # 80001ad0 <myproc>
    8000220e:	84aa                	mv	s1,a0
	acquire(&p->lock);
    80002210:	00850913          	addi	s2,a0,8
    80002214:	854a                	mv	a0,s2
    80002216:	fffff097          	auipc	ra,0xfffff
    8000221a:	9d4080e7          	jalr	-1580(ra) # 80000bea <acquire>
	p->state = RUNNABLE;
    8000221e:	478d                	li	a5,3
    80002220:	d09c                	sw	a5,32(s1)
	sched();
    80002222:	00000097          	auipc	ra,0x0
    80002226:	f00080e7          	jalr	-256(ra) # 80002122 <sched>
	release(&p->lock);
    8000222a:	854a                	mv	a0,s2
    8000222c:	fffff097          	auipc	ra,0xfffff
    80002230:	a72080e7          	jalr	-1422(ra) # 80000c9e <release>
}
    80002234:	60e2                	ld	ra,24(sp)
    80002236:	6442                	ld	s0,16(sp)
    80002238:	64a2                	ld	s1,8(sp)
    8000223a:	6902                	ld	s2,0(sp)
    8000223c:	6105                	addi	sp,sp,32
    8000223e:	8082                	ret

0000000080002240 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    80002240:	7179                	addi	sp,sp,-48
    80002242:	f406                	sd	ra,40(sp)
    80002244:	f022                	sd	s0,32(sp)
    80002246:	ec26                	sd	s1,24(sp)
    80002248:	e84a                	sd	s2,16(sp)
    8000224a:	e44e                	sd	s3,8(sp)
    8000224c:	e052                	sd	s4,0(sp)
    8000224e:	1800                	addi	s0,sp,48
    80002250:	89aa                	mv	s3,a0
    80002252:	892e                	mv	s2,a1
	struct proc *p = myproc();
    80002254:	00000097          	auipc	ra,0x0
    80002258:	87c080e7          	jalr	-1924(ra) # 80001ad0 <myproc>
    8000225c:	84aa                	mv	s1,a0
	// Once we hold p->lock, we can be
	// guaranteed that we won't miss any wakeup
	// (wakeup locks p->lock),
	// so it's okay to release lk.

	acquire(&p->lock); // DOC: sleeplock1
    8000225e:	00850a13          	addi	s4,a0,8
    80002262:	8552                	mv	a0,s4
    80002264:	fffff097          	auipc	ra,0xfffff
    80002268:	986080e7          	jalr	-1658(ra) # 80000bea <acquire>
	release(lk);
    8000226c:	854a                	mv	a0,s2
    8000226e:	fffff097          	auipc	ra,0xfffff
    80002272:	a30080e7          	jalr	-1488(ra) # 80000c9e <release>

	// Go to sleep.
	p->chan = chan;
    80002276:	0334b423          	sd	s3,40(s1)
	p->state = SLEEPING;
    8000227a:	4789                	li	a5,2
    8000227c:	d09c                	sw	a5,32(s1)

	sched();
    8000227e:	00000097          	auipc	ra,0x0
    80002282:	ea4080e7          	jalr	-348(ra) # 80002122 <sched>

	// Tidy up.
	p->chan = 0;
    80002286:	0204b423          	sd	zero,40(s1)

	// Reacquire original lock.
	release(&p->lock);
    8000228a:	8552                	mv	a0,s4
    8000228c:	fffff097          	auipc	ra,0xfffff
    80002290:	a12080e7          	jalr	-1518(ra) # 80000c9e <release>
	acquire(lk);
    80002294:	854a                	mv	a0,s2
    80002296:	fffff097          	auipc	ra,0xfffff
    8000229a:	954080e7          	jalr	-1708(ra) # 80000bea <acquire>
}
    8000229e:	70a2                	ld	ra,40(sp)
    800022a0:	7402                	ld	s0,32(sp)
    800022a2:	64e2                	ld	s1,24(sp)
    800022a4:	6942                	ld	s2,16(sp)
    800022a6:	69a2                	ld	s3,8(sp)
    800022a8:	6a02                	ld	s4,0(sp)
    800022aa:	6145                	addi	sp,sp,48
    800022ac:	8082                	ret

00000000800022ae <waitx>:
{
    800022ae:	7159                	addi	sp,sp,-112
    800022b0:	f486                	sd	ra,104(sp)
    800022b2:	f0a2                	sd	s0,96(sp)
    800022b4:	eca6                	sd	s1,88(sp)
    800022b6:	e8ca                	sd	s2,80(sp)
    800022b8:	e4ce                	sd	s3,72(sp)
    800022ba:	e0d2                	sd	s4,64(sp)
    800022bc:	fc56                	sd	s5,56(sp)
    800022be:	f85a                	sd	s6,48(sp)
    800022c0:	f45e                	sd	s7,40(sp)
    800022c2:	f062                	sd	s8,32(sp)
    800022c4:	ec66                	sd	s9,24(sp)
    800022c6:	e86a                	sd	s10,16(sp)
    800022c8:	e46e                	sd	s11,8(sp)
    800022ca:	1880                	addi	s0,sp,112
    800022cc:	8b2a                	mv	s6,a0
    800022ce:	8bae                	mv	s7,a1
    800022d0:	8c32                	mv	s8,a2
	struct proc *p = myproc();
    800022d2:	fffff097          	auipc	ra,0xfffff
    800022d6:	7fe080e7          	jalr	2046(ra) # 80001ad0 <myproc>
    800022da:	892a                	mv	s2,a0
	acquire(&wait_lock);
    800022dc:	0000f517          	auipc	a0,0xf
    800022e0:	b8c50513          	addi	a0,a0,-1140 # 80010e68 <wait_lock>
    800022e4:	fffff097          	auipc	ra,0xfffff
    800022e8:	906080e7          	jalr	-1786(ra) # 80000bea <acquire>
		havekids = 0;
    800022ec:	4c81                	li	s9,0
				if (np->state == ZOMBIE)
    800022ee:	4a15                	li	s4,5
		for (np = proc; np < &proc[NPROC]; np++)
    800022f0:	00016997          	auipc	s3,0x16
    800022f4:	39098993          	addi	s3,s3,912 # 80018680 <tickslock>
				havekids = 1;
    800022f8:	4a85                	li	s5,1
		sleep(p, &wait_lock); // DOC: wait-sleep
    800022fa:	0000fd17          	auipc	s10,0xf
    800022fe:	b6ed0d13          	addi	s10,s10,-1170 # 80010e68 <wait_lock>
		havekids = 0;
    80002302:	8766                	mv	a4,s9
		for (np = proc; np < &proc[NPROC]; np++)
    80002304:	0000f497          	auipc	s1,0xf
    80002308:	f7c48493          	addi	s1,s1,-132 # 80011280 <proc>
    8000230c:	a04d                	j	800023ae <waitx+0x100>
					pid = np->pid;
    8000230e:	0384a983          	lw	s3,56(s1)
					*rtime = np->runTime;
    80002312:	1804a683          	lw	a3,384(s1)
    80002316:	00dc2023          	sw	a3,0(s8)
					printf("%d %d %d\n", np->endTime, np->creationTime, np->runTime);
    8000231a:	17c4a603          	lw	a2,380(s1)
    8000231e:	1844a583          	lw	a1,388(s1)
    80002322:	00006517          	auipc	a0,0x6
    80002326:	f5650513          	addi	a0,a0,-170 # 80008278 <digits+0x238>
    8000232a:	ffffe097          	auipc	ra,0xffffe
    8000232e:	264080e7          	jalr	612(ra) # 8000058e <printf>
					*wtime = np->endTime - np->creationTime - np->runTime;
    80002332:	17c4a783          	lw	a5,380(s1)
    80002336:	1804a703          	lw	a4,384(s1)
    8000233a:	9f3d                	addw	a4,a4,a5
    8000233c:	1844a783          	lw	a5,388(s1)
    80002340:	9f99                	subw	a5,a5,a4
    80002342:	00fba023          	sw	a5,0(s7) # fffffffffffff000 <end+0xffffffff7ffdb5a0>
					if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002346:	000b0e63          	beqz	s6,80002362 <waitx+0xb4>
    8000234a:	4691                	li	a3,4
    8000234c:	03448613          	addi	a2,s1,52
    80002350:	85da                	mv	a1,s6
    80002352:	05893503          	ld	a0,88(s2)
    80002356:	fffff097          	auipc	ra,0xfffff
    8000235a:	32e080e7          	jalr	814(ra) # 80001684 <copyout>
    8000235e:	02054563          	bltz	a0,80002388 <waitx+0xda>
					freeproc(np);
    80002362:	8526                	mv	a0,s1
    80002364:	00000097          	auipc	ra,0x0
    80002368:	920080e7          	jalr	-1760(ra) # 80001c84 <freeproc>
					release(&np->lock);
    8000236c:	856e                	mv	a0,s11
    8000236e:	fffff097          	auipc	ra,0xfffff
    80002372:	930080e7          	jalr	-1744(ra) # 80000c9e <release>
					release(&wait_lock);
    80002376:	0000f517          	auipc	a0,0xf
    8000237a:	af250513          	addi	a0,a0,-1294 # 80010e68 <wait_lock>
    8000237e:	fffff097          	auipc	ra,0xfffff
    80002382:	920080e7          	jalr	-1760(ra) # 80000c9e <release>
					return pid;
    80002386:	a0ad                	j	800023f0 <waitx+0x142>
						release(&np->lock);
    80002388:	856e                	mv	a0,s11
    8000238a:	fffff097          	auipc	ra,0xfffff
    8000238e:	914080e7          	jalr	-1772(ra) # 80000c9e <release>
						release(&wait_lock);
    80002392:	0000f517          	auipc	a0,0xf
    80002396:	ad650513          	addi	a0,a0,-1322 # 80010e68 <wait_lock>
    8000239a:	fffff097          	auipc	ra,0xfffff
    8000239e:	904080e7          	jalr	-1788(ra) # 80000c9e <release>
						return -1;
    800023a2:	59fd                	li	s3,-1
    800023a4:	a0b1                	j	800023f0 <waitx+0x142>
		for (np = proc; np < &proc[NPROC]; np++)
    800023a6:	1d048493          	addi	s1,s1,464
    800023aa:	03348663          	beq	s1,s3,800023d6 <waitx+0x128>
			if (np->parent == p)
    800023ae:	60bc                	ld	a5,64(s1)
    800023b0:	ff279be3          	bne	a5,s2,800023a6 <waitx+0xf8>
				acquire(&np->lock);
    800023b4:	00848d93          	addi	s11,s1,8
    800023b8:	856e                	mv	a0,s11
    800023ba:	fffff097          	auipc	ra,0xfffff
    800023be:	830080e7          	jalr	-2000(ra) # 80000bea <acquire>
				if (np->state == ZOMBIE)
    800023c2:	509c                	lw	a5,32(s1)
    800023c4:	f54785e3          	beq	a5,s4,8000230e <waitx+0x60>
				release(&np->lock);
    800023c8:	856e                	mv	a0,s11
    800023ca:	fffff097          	auipc	ra,0xfffff
    800023ce:	8d4080e7          	jalr	-1836(ra) # 80000c9e <release>
				havekids = 1;
    800023d2:	8756                	mv	a4,s5
    800023d4:	bfc9                	j	800023a6 <waitx+0xf8>
		if (!havekids || p->killed)
    800023d6:	c701                	beqz	a4,800023de <waitx+0x130>
    800023d8:	03092783          	lw	a5,48(s2)
    800023dc:	cb95                	beqz	a5,80002410 <waitx+0x162>
			release(&wait_lock);
    800023de:	0000f517          	auipc	a0,0xf
    800023e2:	a8a50513          	addi	a0,a0,-1398 # 80010e68 <wait_lock>
    800023e6:	fffff097          	auipc	ra,0xfffff
    800023ea:	8b8080e7          	jalr	-1864(ra) # 80000c9e <release>
			return -1;
    800023ee:	59fd                	li	s3,-1
}
    800023f0:	854e                	mv	a0,s3
    800023f2:	70a6                	ld	ra,104(sp)
    800023f4:	7406                	ld	s0,96(sp)
    800023f6:	64e6                	ld	s1,88(sp)
    800023f8:	6946                	ld	s2,80(sp)
    800023fa:	69a6                	ld	s3,72(sp)
    800023fc:	6a06                	ld	s4,64(sp)
    800023fe:	7ae2                	ld	s5,56(sp)
    80002400:	7b42                	ld	s6,48(sp)
    80002402:	7ba2                	ld	s7,40(sp)
    80002404:	7c02                	ld	s8,32(sp)
    80002406:	6ce2                	ld	s9,24(sp)
    80002408:	6d42                	ld	s10,16(sp)
    8000240a:	6da2                	ld	s11,8(sp)
    8000240c:	6165                	addi	sp,sp,112
    8000240e:	8082                	ret
		sleep(p, &wait_lock); // DOC: wait-sleep
    80002410:	85ea                	mv	a1,s10
    80002412:	854a                	mv	a0,s2
    80002414:	00000097          	auipc	ra,0x0
    80002418:	e2c080e7          	jalr	-468(ra) # 80002240 <sleep>
		havekids = 0;
    8000241c:	b5dd                	j	80002302 <waitx+0x54>

000000008000241e <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    8000241e:	715d                	addi	sp,sp,-80
    80002420:	e486                	sd	ra,72(sp)
    80002422:	e0a2                	sd	s0,64(sp)
    80002424:	fc26                	sd	s1,56(sp)
    80002426:	f84a                	sd	s2,48(sp)
    80002428:	f44e                	sd	s3,40(sp)
    8000242a:	f052                	sd	s4,32(sp)
    8000242c:	ec56                	sd	s5,24(sp)
    8000242e:	e85a                	sd	s6,16(sp)
    80002430:	e45e                	sd	s7,8(sp)
    80002432:	0880                	addi	s0,sp,80
    80002434:	8aaa                	mv	s5,a0
	struct proc *p;

	for (p = proc; p < &proc[NPROC]; p++)
    80002436:	0000f497          	auipc	s1,0xf
    8000243a:	e4a48493          	addi	s1,s1,-438 # 80011280 <proc>
	{
		if (p != myproc())
		{
			acquire(&p->lock);
			if (p->state == SLEEPING && p->chan == chan)
    8000243e:	4a09                	li	s4,2
			{
				p->state = RUNNABLE;
    80002440:	4b0d                	li	s6,3
				p->time_spent = 0;
#endif
				// #ifdef PBS
				if (p->sleepStartTime != 0)
				{
					p->sleepTimePrev = ticks - p->sleepStartTime;
    80002442:	00006b97          	auipc	s7,0x6
    80002446:	79eb8b93          	addi	s7,s7,1950 # 80008be0 <ticks>
	for (p = proc; p < &proc[NPROC]; p++)
    8000244a:	00016997          	auipc	s3,0x16
    8000244e:	23698993          	addi	s3,s3,566 # 80018680 <tickslock>
    80002452:	a811                	j	80002466 <wakeup+0x48>
				int slices[5] = {1, 2, 4, 8, 16};
				p->time_slice = slices[p->curr_queue];
				push(&mlfq[p->curr_queue], p);
#endif
			}
			release(&p->lock);
    80002454:	854a                	mv	a0,s2
    80002456:	fffff097          	auipc	ra,0xfffff
    8000245a:	848080e7          	jalr	-1976(ra) # 80000c9e <release>
	for (p = proc; p < &proc[NPROC]; p++)
    8000245e:	1d048493          	addi	s1,s1,464
    80002462:	05348663          	beq	s1,s3,800024ae <wakeup+0x90>
		if (p != myproc())
    80002466:	fffff097          	auipc	ra,0xfffff
    8000246a:	66a080e7          	jalr	1642(ra) # 80001ad0 <myproc>
    8000246e:	fea488e3          	beq	s1,a0,8000245e <wakeup+0x40>
			acquire(&p->lock);
    80002472:	00848913          	addi	s2,s1,8
    80002476:	854a                	mv	a0,s2
    80002478:	ffffe097          	auipc	ra,0xffffe
    8000247c:	772080e7          	jalr	1906(ra) # 80000bea <acquire>
			if (p->state == SLEEPING && p->chan == chan)
    80002480:	509c                	lw	a5,32(s1)
    80002482:	fd4799e3          	bne	a5,s4,80002454 <wakeup+0x36>
    80002486:	749c                	ld	a5,40(s1)
    80002488:	fd5796e3          	bne	a5,s5,80002454 <wakeup+0x36>
				p->state = RUNNABLE;
    8000248c:	0364a023          	sw	s6,32(s1)
				if (p->sleepStartTime != 0)
    80002490:	1904a783          	lw	a5,400(s1)
    80002494:	d3e1                	beqz	a5,80002454 <wakeup+0x36>
					p->sleepTimePrev = ticks - p->sleepStartTime;
    80002496:	000ba703          	lw	a4,0(s7)
    8000249a:	40f707bb          	subw	a5,a4,a5
    8000249e:	18f4a623          	sw	a5,396(s1)
					p->totalSleep += p->sleepTimePrev;
    800024a2:	1884a703          	lw	a4,392(s1)
    800024a6:	9fb9                	addw	a5,a5,a4
    800024a8:	18f4a423          	sw	a5,392(s1)
    800024ac:	b765                	j	80002454 <wakeup+0x36>
		}
	}
}
    800024ae:	60a6                	ld	ra,72(sp)
    800024b0:	6406                	ld	s0,64(sp)
    800024b2:	74e2                	ld	s1,56(sp)
    800024b4:	7942                	ld	s2,48(sp)
    800024b6:	79a2                	ld	s3,40(sp)
    800024b8:	7a02                	ld	s4,32(sp)
    800024ba:	6ae2                	ld	s5,24(sp)
    800024bc:	6b42                	ld	s6,16(sp)
    800024be:	6ba2                	ld	s7,8(sp)
    800024c0:	6161                	addi	sp,sp,80
    800024c2:	8082                	ret

00000000800024c4 <reparent>:
{
    800024c4:	7179                	addi	sp,sp,-48
    800024c6:	f406                	sd	ra,40(sp)
    800024c8:	f022                	sd	s0,32(sp)
    800024ca:	ec26                	sd	s1,24(sp)
    800024cc:	e84a                	sd	s2,16(sp)
    800024ce:	e44e                	sd	s3,8(sp)
    800024d0:	e052                	sd	s4,0(sp)
    800024d2:	1800                	addi	s0,sp,48
    800024d4:	892a                	mv	s2,a0
	for (pp = proc; pp < &proc[NPROC]; pp++)
    800024d6:	0000f497          	auipc	s1,0xf
    800024da:	daa48493          	addi	s1,s1,-598 # 80011280 <proc>
			pp->parent = initproc;
    800024de:	00006a17          	auipc	s4,0x6
    800024e2:	6faa0a13          	addi	s4,s4,1786 # 80008bd8 <initproc>
	for (pp = proc; pp < &proc[NPROC]; pp++)
    800024e6:	00016997          	auipc	s3,0x16
    800024ea:	19a98993          	addi	s3,s3,410 # 80018680 <tickslock>
    800024ee:	a029                	j	800024f8 <reparent+0x34>
    800024f0:	1d048493          	addi	s1,s1,464
    800024f4:	01348d63          	beq	s1,s3,8000250e <reparent+0x4a>
		if (pp->parent == p)
    800024f8:	60bc                	ld	a5,64(s1)
    800024fa:	ff279be3          	bne	a5,s2,800024f0 <reparent+0x2c>
			pp->parent = initproc;
    800024fe:	000a3503          	ld	a0,0(s4)
    80002502:	e0a8                	sd	a0,64(s1)
			wakeup(initproc);
    80002504:	00000097          	auipc	ra,0x0
    80002508:	f1a080e7          	jalr	-230(ra) # 8000241e <wakeup>
    8000250c:	b7d5                	j	800024f0 <reparent+0x2c>
}
    8000250e:	70a2                	ld	ra,40(sp)
    80002510:	7402                	ld	s0,32(sp)
    80002512:	64e2                	ld	s1,24(sp)
    80002514:	6942                	ld	s2,16(sp)
    80002516:	69a2                	ld	s3,8(sp)
    80002518:	6a02                	ld	s4,0(sp)
    8000251a:	6145                	addi	sp,sp,48
    8000251c:	8082                	ret

000000008000251e <exit>:
{
    8000251e:	7179                	addi	sp,sp,-48
    80002520:	f406                	sd	ra,40(sp)
    80002522:	f022                	sd	s0,32(sp)
    80002524:	ec26                	sd	s1,24(sp)
    80002526:	e84a                	sd	s2,16(sp)
    80002528:	e44e                	sd	s3,8(sp)
    8000252a:	e052                	sd	s4,0(sp)
    8000252c:	1800                	addi	s0,sp,48
    8000252e:	8a2a                	mv	s4,a0
	struct proc *p = myproc();
    80002530:	fffff097          	auipc	ra,0xfffff
    80002534:	5a0080e7          	jalr	1440(ra) # 80001ad0 <myproc>
    80002538:	89aa                	mv	s3,a0
	if (p == initproc)
    8000253a:	00006797          	auipc	a5,0x6
    8000253e:	69e7b783          	ld	a5,1694(a5) # 80008bd8 <initproc>
    80002542:	0d850493          	addi	s1,a0,216
    80002546:	15850913          	addi	s2,a0,344
    8000254a:	02a79363          	bne	a5,a0,80002570 <exit+0x52>
		panic("init exiting");
    8000254e:	00006517          	auipc	a0,0x6
    80002552:	d3a50513          	addi	a0,a0,-710 # 80008288 <digits+0x248>
    80002556:	ffffe097          	auipc	ra,0xffffe
    8000255a:	fee080e7          	jalr	-18(ra) # 80000544 <panic>
			fileclose(f);
    8000255e:	00002097          	auipc	ra,0x2
    80002562:	604080e7          	jalr	1540(ra) # 80004b62 <fileclose>
			p->ofile[fd] = 0;
    80002566:	0004b023          	sd	zero,0(s1)
	for (int fd = 0; fd < NOFILE; fd++)
    8000256a:	04a1                	addi	s1,s1,8
    8000256c:	01248563          	beq	s1,s2,80002576 <exit+0x58>
		if (p->ofile[fd])
    80002570:	6088                	ld	a0,0(s1)
    80002572:	f575                	bnez	a0,8000255e <exit+0x40>
    80002574:	bfdd                	j	8000256a <exit+0x4c>
	begin_op();
    80002576:	00002097          	auipc	ra,0x2
    8000257a:	120080e7          	jalr	288(ra) # 80004696 <begin_op>
	iput(p->cwd);
    8000257e:	1589b503          	ld	a0,344(s3)
    80002582:	00002097          	auipc	ra,0x2
    80002586:	90c080e7          	jalr	-1780(ra) # 80003e8e <iput>
	end_op();
    8000258a:	00002097          	auipc	ra,0x2
    8000258e:	18c080e7          	jalr	396(ra) # 80004716 <end_op>
	p->cwd = 0;
    80002592:	1409bc23          	sd	zero,344(s3)
	acquire(&wait_lock);
    80002596:	0000f497          	auipc	s1,0xf
    8000259a:	8d248493          	addi	s1,s1,-1838 # 80010e68 <wait_lock>
    8000259e:	8526                	mv	a0,s1
    800025a0:	ffffe097          	auipc	ra,0xffffe
    800025a4:	64a080e7          	jalr	1610(ra) # 80000bea <acquire>
	reparent(p);
    800025a8:	854e                	mv	a0,s3
    800025aa:	00000097          	auipc	ra,0x0
    800025ae:	f1a080e7          	jalr	-230(ra) # 800024c4 <reparent>
	wakeup(p->parent);
    800025b2:	0409b503          	ld	a0,64(s3)
    800025b6:	00000097          	auipc	ra,0x0
    800025ba:	e68080e7          	jalr	-408(ra) # 8000241e <wakeup>
	acquire(&p->lock);
    800025be:	00898513          	addi	a0,s3,8
    800025c2:	ffffe097          	auipc	ra,0xffffe
    800025c6:	628080e7          	jalr	1576(ra) # 80000bea <acquire>
	p->xstate = status;
    800025ca:	0349aa23          	sw	s4,52(s3)
	p->state = ZOMBIE;
    800025ce:	4795                	li	a5,5
    800025d0:	02f9a023          	sw	a5,32(s3)
	p->endTime = ticks;
    800025d4:	00006797          	auipc	a5,0x6
    800025d8:	60c7a783          	lw	a5,1548(a5) # 80008be0 <ticks>
    800025dc:	18f9a223          	sw	a5,388(s3)
	release(&wait_lock);
    800025e0:	8526                	mv	a0,s1
    800025e2:	ffffe097          	auipc	ra,0xffffe
    800025e6:	6bc080e7          	jalr	1724(ra) # 80000c9e <release>
	sched();
    800025ea:	00000097          	auipc	ra,0x0
    800025ee:	b38080e7          	jalr	-1224(ra) # 80002122 <sched>
	panic("zombie exit");
    800025f2:	00006517          	auipc	a0,0x6
    800025f6:	ca650513          	addi	a0,a0,-858 # 80008298 <digits+0x258>
    800025fa:	ffffe097          	auipc	ra,0xffffe
    800025fe:	f4a080e7          	jalr	-182(ra) # 80000544 <panic>

0000000080002602 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    80002602:	7179                	addi	sp,sp,-48
    80002604:	f406                	sd	ra,40(sp)
    80002606:	f022                	sd	s0,32(sp)
    80002608:	ec26                	sd	s1,24(sp)
    8000260a:	e84a                	sd	s2,16(sp)
    8000260c:	e44e                	sd	s3,8(sp)
    8000260e:	e052                	sd	s4,0(sp)
    80002610:	1800                	addi	s0,sp,48
    80002612:	89aa                	mv	s3,a0
	struct proc *p;

	for (p = proc; p < &proc[NPROC]; p++)
    80002614:	0000f497          	auipc	s1,0xf
    80002618:	c6c48493          	addi	s1,s1,-916 # 80011280 <proc>
    8000261c:	00016a17          	auipc	s4,0x16
    80002620:	064a0a13          	addi	s4,s4,100 # 80018680 <tickslock>
	{
		acquire(&p->lock);
    80002624:	00848913          	addi	s2,s1,8
    80002628:	854a                	mv	a0,s2
    8000262a:	ffffe097          	auipc	ra,0xffffe
    8000262e:	5c0080e7          	jalr	1472(ra) # 80000bea <acquire>
		if (p->pid == pid)
    80002632:	5c9c                	lw	a5,56(s1)
    80002634:	01378d63          	beq	a5,s3,8000264e <kill+0x4c>
#endif
			}
			release(&p->lock);
			return 0;
		}
		release(&p->lock);
    80002638:	854a                	mv	a0,s2
    8000263a:	ffffe097          	auipc	ra,0xffffe
    8000263e:	664080e7          	jalr	1636(ra) # 80000c9e <release>
	for (p = proc; p < &proc[NPROC]; p++)
    80002642:	1d048493          	addi	s1,s1,464
    80002646:	fd449fe3          	bne	s1,s4,80002624 <kill+0x22>
	}
	return -1;
    8000264a:	557d                	li	a0,-1
    8000264c:	a829                	j	80002666 <kill+0x64>
			p->killed = 1;
    8000264e:	4785                	li	a5,1
    80002650:	d89c                	sw	a5,48(s1)
			if (p->state == SLEEPING)
    80002652:	5098                	lw	a4,32(s1)
    80002654:	4789                	li	a5,2
    80002656:	02f70063          	beq	a4,a5,80002676 <kill+0x74>
			release(&p->lock);
    8000265a:	854a                	mv	a0,s2
    8000265c:	ffffe097          	auipc	ra,0xffffe
    80002660:	642080e7          	jalr	1602(ra) # 80000c9e <release>
			return 0;
    80002664:	4501                	li	a0,0
}
    80002666:	70a2                	ld	ra,40(sp)
    80002668:	7402                	ld	s0,32(sp)
    8000266a:	64e2                	ld	s1,24(sp)
    8000266c:	6942                	ld	s2,16(sp)
    8000266e:	69a2                	ld	s3,8(sp)
    80002670:	6a02                	ld	s4,0(sp)
    80002672:	6145                	addi	sp,sp,48
    80002674:	8082                	ret
				p->sleepTimePrev = ticks - p->sleepStartTime;
    80002676:	1904a703          	lw	a4,400(s1)
    8000267a:	00006797          	auipc	a5,0x6
    8000267e:	5667a783          	lw	a5,1382(a5) # 80008be0 <ticks>
    80002682:	9f99                	subw	a5,a5,a4
    80002684:	18f4a623          	sw	a5,396(s1)
				p->state = RUNNABLE;
    80002688:	478d                	li	a5,3
    8000268a:	d09c                	sw	a5,32(s1)
    8000268c:	b7f9                	j	8000265a <kill+0x58>

000000008000268e <setkilled>:

void setkilled(struct proc *p)
{
    8000268e:	1101                	addi	sp,sp,-32
    80002690:	ec06                	sd	ra,24(sp)
    80002692:	e822                	sd	s0,16(sp)
    80002694:	e426                	sd	s1,8(sp)
    80002696:	e04a                	sd	s2,0(sp)
    80002698:	1000                	addi	s0,sp,32
    8000269a:	84aa                	mv	s1,a0
	acquire(&p->lock);
    8000269c:	00850913          	addi	s2,a0,8
    800026a0:	854a                	mv	a0,s2
    800026a2:	ffffe097          	auipc	ra,0xffffe
    800026a6:	548080e7          	jalr	1352(ra) # 80000bea <acquire>
	p->killed = 1;
    800026aa:	4785                	li	a5,1
    800026ac:	d89c                	sw	a5,48(s1)
	release(&p->lock);
    800026ae:	854a                	mv	a0,s2
    800026b0:	ffffe097          	auipc	ra,0xffffe
    800026b4:	5ee080e7          	jalr	1518(ra) # 80000c9e <release>
}
    800026b8:	60e2                	ld	ra,24(sp)
    800026ba:	6442                	ld	s0,16(sp)
    800026bc:	64a2                	ld	s1,8(sp)
    800026be:	6902                	ld	s2,0(sp)
    800026c0:	6105                	addi	sp,sp,32
    800026c2:	8082                	ret

00000000800026c4 <killed>:

int killed(struct proc *p)
{
    800026c4:	1101                	addi	sp,sp,-32
    800026c6:	ec06                	sd	ra,24(sp)
    800026c8:	e822                	sd	s0,16(sp)
    800026ca:	e426                	sd	s1,8(sp)
    800026cc:	e04a                	sd	s2,0(sp)
    800026ce:	1000                	addi	s0,sp,32
    800026d0:	84aa                	mv	s1,a0
	int k;

	acquire(&p->lock);
    800026d2:	00850913          	addi	s2,a0,8
    800026d6:	854a                	mv	a0,s2
    800026d8:	ffffe097          	auipc	ra,0xffffe
    800026dc:	512080e7          	jalr	1298(ra) # 80000bea <acquire>
	k = p->killed;
    800026e0:	5884                	lw	s1,48(s1)
	release(&p->lock);
    800026e2:	854a                	mv	a0,s2
    800026e4:	ffffe097          	auipc	ra,0xffffe
    800026e8:	5ba080e7          	jalr	1466(ra) # 80000c9e <release>
	return k;
}
    800026ec:	8526                	mv	a0,s1
    800026ee:	60e2                	ld	ra,24(sp)
    800026f0:	6442                	ld	s0,16(sp)
    800026f2:	64a2                	ld	s1,8(sp)
    800026f4:	6902                	ld	s2,0(sp)
    800026f6:	6105                	addi	sp,sp,32
    800026f8:	8082                	ret

00000000800026fa <wait>:
{
    800026fa:	711d                	addi	sp,sp,-96
    800026fc:	ec86                	sd	ra,88(sp)
    800026fe:	e8a2                	sd	s0,80(sp)
    80002700:	e4a6                	sd	s1,72(sp)
    80002702:	e0ca                	sd	s2,64(sp)
    80002704:	fc4e                	sd	s3,56(sp)
    80002706:	f852                	sd	s4,48(sp)
    80002708:	f456                	sd	s5,40(sp)
    8000270a:	f05a                	sd	s6,32(sp)
    8000270c:	ec5e                	sd	s7,24(sp)
    8000270e:	e862                	sd	s8,16(sp)
    80002710:	e466                	sd	s9,8(sp)
    80002712:	1080                	addi	s0,sp,96
    80002714:	8baa                	mv	s7,a0
	struct proc *p = myproc();
    80002716:	fffff097          	auipc	ra,0xfffff
    8000271a:	3ba080e7          	jalr	954(ra) # 80001ad0 <myproc>
    8000271e:	892a                	mv	s2,a0
	acquire(&wait_lock);
    80002720:	0000e517          	auipc	a0,0xe
    80002724:	74850513          	addi	a0,a0,1864 # 80010e68 <wait_lock>
    80002728:	ffffe097          	auipc	ra,0xffffe
    8000272c:	4c2080e7          	jalr	1218(ra) # 80000bea <acquire>
		havekids = 0;
    80002730:	4c01                	li	s8,0
				if (pp->state == ZOMBIE)
    80002732:	4a95                	li	s5,5
		for (pp = proc; pp < &proc[NPROC]; pp++)
    80002734:	00016997          	auipc	s3,0x16
    80002738:	f4c98993          	addi	s3,s3,-180 # 80018680 <tickslock>
				havekids = 1;
    8000273c:	4b05                	li	s6,1
		sleep(p, &wait_lock); // DOC: wait-sleep
    8000273e:	0000ec97          	auipc	s9,0xe
    80002742:	72ac8c93          	addi	s9,s9,1834 # 80010e68 <wait_lock>
		havekids = 0;
    80002746:	8762                	mv	a4,s8
		for (pp = proc; pp < &proc[NPROC]; pp++)
    80002748:	0000f497          	auipc	s1,0xf
    8000274c:	b3848493          	addi	s1,s1,-1224 # 80011280 <proc>
    80002750:	a8ad                	j	800027ca <wait+0xd0>
					pid = pp->pid;
    80002752:	0384a983          	lw	s3,56(s1)
					if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002756:	000b8e63          	beqz	s7,80002772 <wait+0x78>
    8000275a:	4691                	li	a3,4
    8000275c:	03448613          	addi	a2,s1,52
    80002760:	85de                	mv	a1,s7
    80002762:	05893503          	ld	a0,88(s2)
    80002766:	fffff097          	auipc	ra,0xfffff
    8000276a:	f1e080e7          	jalr	-226(ra) # 80001684 <copyout>
    8000276e:	02054b63          	bltz	a0,800027a4 <wait+0xaa>
					freeproc(pp);
    80002772:	8526                	mv	a0,s1
    80002774:	fffff097          	auipc	ra,0xfffff
    80002778:	510080e7          	jalr	1296(ra) # 80001c84 <freeproc>
					release(&pp->lock);
    8000277c:	8552                	mv	a0,s4
    8000277e:	ffffe097          	auipc	ra,0xffffe
    80002782:	520080e7          	jalr	1312(ra) # 80000c9e <release>
					release(&wait_lock);
    80002786:	0000e517          	auipc	a0,0xe
    8000278a:	6e250513          	addi	a0,a0,1762 # 80010e68 <wait_lock>
    8000278e:	ffffe097          	auipc	ra,0xffffe
    80002792:	510080e7          	jalr	1296(ra) # 80000c9e <release>
					pp->endTime = ticks;
    80002796:	00006797          	auipc	a5,0x6
    8000279a:	44a7a783          	lw	a5,1098(a5) # 80008be0 <ticks>
    8000279e:	18f4a223          	sw	a5,388(s1)
					return pid;
    800027a2:	a885                	j	80002812 <wait+0x118>
						release(&pp->lock);
    800027a4:	8552                	mv	a0,s4
    800027a6:	ffffe097          	auipc	ra,0xffffe
    800027aa:	4f8080e7          	jalr	1272(ra) # 80000c9e <release>
						release(&wait_lock);
    800027ae:	0000e517          	auipc	a0,0xe
    800027b2:	6ba50513          	addi	a0,a0,1722 # 80010e68 <wait_lock>
    800027b6:	ffffe097          	auipc	ra,0xffffe
    800027ba:	4e8080e7          	jalr	1256(ra) # 80000c9e <release>
						return -1;
    800027be:	59fd                	li	s3,-1
    800027c0:	a889                	j	80002812 <wait+0x118>
		for (pp = proc; pp < &proc[NPROC]; pp++)
    800027c2:	1d048493          	addi	s1,s1,464
    800027c6:	03348663          	beq	s1,s3,800027f2 <wait+0xf8>
			if (pp->parent == p)
    800027ca:	60bc                	ld	a5,64(s1)
    800027cc:	ff279be3          	bne	a5,s2,800027c2 <wait+0xc8>
				acquire(&pp->lock);
    800027d0:	00848a13          	addi	s4,s1,8
    800027d4:	8552                	mv	a0,s4
    800027d6:	ffffe097          	auipc	ra,0xffffe
    800027da:	414080e7          	jalr	1044(ra) # 80000bea <acquire>
				if (pp->state == ZOMBIE)
    800027de:	509c                	lw	a5,32(s1)
    800027e0:	f75789e3          	beq	a5,s5,80002752 <wait+0x58>
				release(&pp->lock);
    800027e4:	8552                	mv	a0,s4
    800027e6:	ffffe097          	auipc	ra,0xffffe
    800027ea:	4b8080e7          	jalr	1208(ra) # 80000c9e <release>
				havekids = 1;
    800027ee:	875a                	mv	a4,s6
    800027f0:	bfc9                	j	800027c2 <wait+0xc8>
		if (!havekids || killed(p))
    800027f2:	c719                	beqz	a4,80002800 <wait+0x106>
    800027f4:	854a                	mv	a0,s2
    800027f6:	00000097          	auipc	ra,0x0
    800027fa:	ece080e7          	jalr	-306(ra) # 800026c4 <killed>
    800027fe:	c905                	beqz	a0,8000282e <wait+0x134>
			release(&wait_lock);
    80002800:	0000e517          	auipc	a0,0xe
    80002804:	66850513          	addi	a0,a0,1640 # 80010e68 <wait_lock>
    80002808:	ffffe097          	auipc	ra,0xffffe
    8000280c:	496080e7          	jalr	1174(ra) # 80000c9e <release>
			return -1;
    80002810:	59fd                	li	s3,-1
}
    80002812:	854e                	mv	a0,s3
    80002814:	60e6                	ld	ra,88(sp)
    80002816:	6446                	ld	s0,80(sp)
    80002818:	64a6                	ld	s1,72(sp)
    8000281a:	6906                	ld	s2,64(sp)
    8000281c:	79e2                	ld	s3,56(sp)
    8000281e:	7a42                	ld	s4,48(sp)
    80002820:	7aa2                	ld	s5,40(sp)
    80002822:	7b02                	ld	s6,32(sp)
    80002824:	6be2                	ld	s7,24(sp)
    80002826:	6c42                	ld	s8,16(sp)
    80002828:	6ca2                	ld	s9,8(sp)
    8000282a:	6125                	addi	sp,sp,96
    8000282c:	8082                	ret
		sleep(p, &wait_lock); // DOC: wait-sleep
    8000282e:	85e6                	mv	a1,s9
    80002830:	854a                	mv	a0,s2
    80002832:	00000097          	auipc	ra,0x0
    80002836:	a0e080e7          	jalr	-1522(ra) # 80002240 <sleep>
		havekids = 0;
    8000283a:	b731                	j	80002746 <wait+0x4c>

000000008000283c <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000283c:	7179                	addi	sp,sp,-48
    8000283e:	f406                	sd	ra,40(sp)
    80002840:	f022                	sd	s0,32(sp)
    80002842:	ec26                	sd	s1,24(sp)
    80002844:	e84a                	sd	s2,16(sp)
    80002846:	e44e                	sd	s3,8(sp)
    80002848:	e052                	sd	s4,0(sp)
    8000284a:	1800                	addi	s0,sp,48
    8000284c:	84aa                	mv	s1,a0
    8000284e:	892e                	mv	s2,a1
    80002850:	89b2                	mv	s3,a2
    80002852:	8a36                	mv	s4,a3
	struct proc *p = myproc();
    80002854:	fffff097          	auipc	ra,0xfffff
    80002858:	27c080e7          	jalr	636(ra) # 80001ad0 <myproc>
	if (user_dst)
    8000285c:	c08d                	beqz	s1,8000287e <either_copyout+0x42>
	{
		return copyout(p->pagetable, dst, src, len);
    8000285e:	86d2                	mv	a3,s4
    80002860:	864e                	mv	a2,s3
    80002862:	85ca                	mv	a1,s2
    80002864:	6d28                	ld	a0,88(a0)
    80002866:	fffff097          	auipc	ra,0xfffff
    8000286a:	e1e080e7          	jalr	-482(ra) # 80001684 <copyout>
	else
	{
		memmove((char *)dst, src, len);
		return 0;
	}
}
    8000286e:	70a2                	ld	ra,40(sp)
    80002870:	7402                	ld	s0,32(sp)
    80002872:	64e2                	ld	s1,24(sp)
    80002874:	6942                	ld	s2,16(sp)
    80002876:	69a2                	ld	s3,8(sp)
    80002878:	6a02                	ld	s4,0(sp)
    8000287a:	6145                	addi	sp,sp,48
    8000287c:	8082                	ret
		memmove((char *)dst, src, len);
    8000287e:	000a061b          	sext.w	a2,s4
    80002882:	85ce                	mv	a1,s3
    80002884:	854a                	mv	a0,s2
    80002886:	ffffe097          	auipc	ra,0xffffe
    8000288a:	4c0080e7          	jalr	1216(ra) # 80000d46 <memmove>
		return 0;
    8000288e:	8526                	mv	a0,s1
    80002890:	bff9                	j	8000286e <either_copyout+0x32>

0000000080002892 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002892:	7179                	addi	sp,sp,-48
    80002894:	f406                	sd	ra,40(sp)
    80002896:	f022                	sd	s0,32(sp)
    80002898:	ec26                	sd	s1,24(sp)
    8000289a:	e84a                	sd	s2,16(sp)
    8000289c:	e44e                	sd	s3,8(sp)
    8000289e:	e052                	sd	s4,0(sp)
    800028a0:	1800                	addi	s0,sp,48
    800028a2:	892a                	mv	s2,a0
    800028a4:	84ae                	mv	s1,a1
    800028a6:	89b2                	mv	s3,a2
    800028a8:	8a36                	mv	s4,a3
	struct proc *p = myproc();
    800028aa:	fffff097          	auipc	ra,0xfffff
    800028ae:	226080e7          	jalr	550(ra) # 80001ad0 <myproc>
	if (user_src)
    800028b2:	c08d                	beqz	s1,800028d4 <either_copyin+0x42>
	{
		return copyin(p->pagetable, dst, src, len);
    800028b4:	86d2                	mv	a3,s4
    800028b6:	864e                	mv	a2,s3
    800028b8:	85ca                	mv	a1,s2
    800028ba:	6d28                	ld	a0,88(a0)
    800028bc:	fffff097          	auipc	ra,0xfffff
    800028c0:	e54080e7          	jalr	-428(ra) # 80001710 <copyin>
	else
	{
		memmove(dst, (char *)src, len);
		return 0;
	}
}
    800028c4:	70a2                	ld	ra,40(sp)
    800028c6:	7402                	ld	s0,32(sp)
    800028c8:	64e2                	ld	s1,24(sp)
    800028ca:	6942                	ld	s2,16(sp)
    800028cc:	69a2                	ld	s3,8(sp)
    800028ce:	6a02                	ld	s4,0(sp)
    800028d0:	6145                	addi	sp,sp,48
    800028d2:	8082                	ret
		memmove(dst, (char *)src, len);
    800028d4:	000a061b          	sext.w	a2,s4
    800028d8:	85ce                	mv	a1,s3
    800028da:	854a                	mv	a0,s2
    800028dc:	ffffe097          	auipc	ra,0xffffe
    800028e0:	46a080e7          	jalr	1130(ra) # 80000d46 <memmove>
		return 0;
    800028e4:	8526                	mv	a0,s1
    800028e6:	bff9                	j	800028c4 <either_copyin+0x32>

00000000800028e8 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck mastatechine further.
void procdump(void)
{
    800028e8:	715d                	addi	sp,sp,-80
    800028ea:	e486                	sd	ra,72(sp)
    800028ec:	e0a2                	sd	s0,64(sp)
    800028ee:	fc26                	sd	s1,56(sp)
    800028f0:	f84a                	sd	s2,48(sp)
    800028f2:	f44e                	sd	s3,40(sp)
    800028f4:	f052                	sd	s4,32(sp)
    800028f6:	ec56                	sd	s5,24(sp)
    800028f8:	e85a                	sd	s6,16(sp)
    800028fa:	e45e                	sd	s7,8(sp)
    800028fc:	0880                	addi	s0,sp,80
		[RUNNING] "run   ",
		[ZOMBIE] "zombie"};
	struct proc *p;
	char *state;

	printf("\n");
    800028fe:	00006517          	auipc	a0,0x6
    80002902:	98250513          	addi	a0,a0,-1662 # 80008280 <digits+0x240>
    80002906:	ffffe097          	auipc	ra,0xffffe
    8000290a:	c88080e7          	jalr	-888(ra) # 8000058e <printf>
	for (p = proc; p < &proc[NPROC]; p++)
    8000290e:	0000f497          	auipc	s1,0xf
    80002912:	ad248493          	addi	s1,s1,-1326 # 800113e0 <proc+0x160>
    80002916:	00016917          	auipc	s2,0x16
    8000291a:	eca90913          	addi	s2,s2,-310 # 800187e0 <bcache+0x148>
	{
		if (p->state == UNUSED)
			continue;
		if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000291e:	4b15                	li	s6,5
			state = states[p->state];
		else
			state = "???";
    80002920:	00006997          	auipc	s3,0x6
    80002924:	98898993          	addi	s3,s3,-1656 # 800082a8 <digits+0x268>
		printf("%d %s %s %d %d", p->pid, state, p->name, p->runTime, p->countTimeCalled);
    80002928:	00006a97          	auipc	s5,0x6
    8000292c:	988a8a93          	addi	s5,s5,-1656 # 800082b0 <digits+0x270>
		printf("\n");
    80002930:	00006a17          	auipc	s4,0x6
    80002934:	950a0a13          	addi	s4,s4,-1712 # 80008280 <digits+0x240>
		if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002938:	00006b97          	auipc	s7,0x6
    8000293c:	9b8b8b93          	addi	s7,s7,-1608 # 800082f0 <states.2493>
    80002940:	a01d                	j	80002966 <procdump+0x7e>
		printf("%d %s %s %d %d", p->pid, state, p->name, p->runTime, p->countTimeCalled);
    80002942:	5e9c                	lw	a5,56(a3)
    80002944:	5298                	lw	a4,32(a3)
    80002946:	ed86a583          	lw	a1,-296(a3)
    8000294a:	8556                	mv	a0,s5
    8000294c:	ffffe097          	auipc	ra,0xffffe
    80002950:	c42080e7          	jalr	-958(ra) # 8000058e <printf>
		printf("\n");
    80002954:	8552                	mv	a0,s4
    80002956:	ffffe097          	auipc	ra,0xffffe
    8000295a:	c38080e7          	jalr	-968(ra) # 8000058e <printf>
	for (p = proc; p < &proc[NPROC]; p++)
    8000295e:	1d048493          	addi	s1,s1,464
    80002962:	03248163          	beq	s1,s2,80002984 <procdump+0x9c>
		if (p->state == UNUSED)
    80002966:	86a6                	mv	a3,s1
    80002968:	ec04a783          	lw	a5,-320(s1)
    8000296c:	dbed                	beqz	a5,8000295e <procdump+0x76>
			state = "???";
    8000296e:	864e                	mv	a2,s3
		if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002970:	fcfb69e3          	bltu	s6,a5,80002942 <procdump+0x5a>
    80002974:	1782                	slli	a5,a5,0x20
    80002976:	9381                	srli	a5,a5,0x20
    80002978:	078e                	slli	a5,a5,0x3
    8000297a:	97de                	add	a5,a5,s7
    8000297c:	6390                	ld	a2,0(a5)
    8000297e:	f271                	bnez	a2,80002942 <procdump+0x5a>
			state = "???";
    80002980:	864e                	mv	a2,s3
    80002982:	b7c1                	j	80002942 <procdump+0x5a>
	}
}
    80002984:	60a6                	ld	ra,72(sp)
    80002986:	6406                	ld	s0,64(sp)
    80002988:	74e2                	ld	s1,56(sp)
    8000298a:	7942                	ld	s2,48(sp)
    8000298c:	79a2                	ld	s3,40(sp)
    8000298e:	7a02                	ld	s4,32(sp)
    80002990:	6ae2                	ld	s5,24(sp)
    80002992:	6b42                	ld	s6,16(sp)
    80002994:	6ba2                	ld	s7,8(sp)
    80002996:	6161                	addi	sp,sp,80
    80002998:	8082                	ret

000000008000299a <swtch>:
    8000299a:	00153023          	sd	ra,0(a0)
    8000299e:	00253423          	sd	sp,8(a0)
    800029a2:	e900                	sd	s0,16(a0)
    800029a4:	ed04                	sd	s1,24(a0)
    800029a6:	03253023          	sd	s2,32(a0)
    800029aa:	03353423          	sd	s3,40(a0)
    800029ae:	03453823          	sd	s4,48(a0)
    800029b2:	03553c23          	sd	s5,56(a0)
    800029b6:	05653023          	sd	s6,64(a0)
    800029ba:	05753423          	sd	s7,72(a0)
    800029be:	05853823          	sd	s8,80(a0)
    800029c2:	05953c23          	sd	s9,88(a0)
    800029c6:	07a53023          	sd	s10,96(a0)
    800029ca:	07b53423          	sd	s11,104(a0)
    800029ce:	0005b083          	ld	ra,0(a1)
    800029d2:	0085b103          	ld	sp,8(a1)
    800029d6:	6980                	ld	s0,16(a1)
    800029d8:	6d84                	ld	s1,24(a1)
    800029da:	0205b903          	ld	s2,32(a1)
    800029de:	0285b983          	ld	s3,40(a1)
    800029e2:	0305ba03          	ld	s4,48(a1)
    800029e6:	0385ba83          	ld	s5,56(a1)
    800029ea:	0405bb03          	ld	s6,64(a1)
    800029ee:	0485bb83          	ld	s7,72(a1)
    800029f2:	0505bc03          	ld	s8,80(a1)
    800029f6:	0585bc83          	ld	s9,88(a1)
    800029fa:	0605bd03          	ld	s10,96(a1)
    800029fe:	0685bd83          	ld	s11,104(a1)
    80002a02:	8082                	ret

0000000080002a04 <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002a04:	1141                	addi	sp,sp,-16
    80002a06:	e406                	sd	ra,8(sp)
    80002a08:	e022                	sd	s0,0(sp)
    80002a0a:	0800                	addi	s0,sp,16
	initlock(&tickslock, "time");
    80002a0c:	00006597          	auipc	a1,0x6
    80002a10:	91458593          	addi	a1,a1,-1772 # 80008320 <states.2493+0x30>
    80002a14:	00016517          	auipc	a0,0x16
    80002a18:	c6c50513          	addi	a0,a0,-916 # 80018680 <tickslock>
    80002a1c:	ffffe097          	auipc	ra,0xffffe
    80002a20:	13e080e7          	jalr	318(ra) # 80000b5a <initlock>
}
    80002a24:	60a2                	ld	ra,8(sp)
    80002a26:	6402                	ld	s0,0(sp)
    80002a28:	0141                	addi	sp,sp,16
    80002a2a:	8082                	ret

0000000080002a2c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002a2c:	1141                	addi	sp,sp,-16
    80002a2e:	e422                	sd	s0,8(sp)
    80002a30:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a32:	00003797          	auipc	a5,0x3
    80002a36:	76e78793          	addi	a5,a5,1902 # 800061a0 <kernelvec>
    80002a3a:	10579073          	csrw	stvec,a5
	w_stvec((uint64)kernelvec);
}
    80002a3e:	6422                	ld	s0,8(sp)
    80002a40:	0141                	addi	sp,sp,16
    80002a42:	8082                	ret

0000000080002a44 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80002a44:	1141                	addi	sp,sp,-16
    80002a46:	e406                	sd	ra,8(sp)
    80002a48:	e022                	sd	s0,0(sp)
    80002a4a:	0800                	addi	s0,sp,16
	struct proc *p = myproc();
    80002a4c:	fffff097          	auipc	ra,0xfffff
    80002a50:	084080e7          	jalr	132(ra) # 80001ad0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a54:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002a58:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a5a:	10079073          	csrw	sstatus,a5
	// kerneltrap() to usertrap(), so turn off interrupts until
	// we're back in user space, where usertrap() is correct.
	intr_off();

	// send syscalls, interrupts, and exceptions to uservec in trampoline.S
	uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002a5e:	00004617          	auipc	a2,0x4
    80002a62:	5a260613          	addi	a2,a2,1442 # 80007000 <_trampoline>
    80002a66:	00004697          	auipc	a3,0x4
    80002a6a:	59a68693          	addi	a3,a3,1434 # 80007000 <_trampoline>
    80002a6e:	8e91                	sub	a3,a3,a2
    80002a70:	040007b7          	lui	a5,0x4000
    80002a74:	17fd                	addi	a5,a5,-1
    80002a76:	07b2                	slli	a5,a5,0xc
    80002a78:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a7a:	10569073          	csrw	stvec,a3
	w_stvec(trampoline_uservec);

	// set up trapframe values that uservec will need when
	// the process next traps into the kernel.
	p->trapframe->kernel_satp = r_satp();		  // kernel page table
    80002a7e:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002a80:	180026f3          	csrr	a3,satp
    80002a84:	e314                	sd	a3,0(a4)
	p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002a86:	7138                	ld	a4,96(a0)
    80002a88:	6534                	ld	a3,72(a0)
    80002a8a:	6585                	lui	a1,0x1
    80002a8c:	96ae                	add	a3,a3,a1
    80002a8e:	e714                	sd	a3,8(a4)
	p->trapframe->kernel_trap = (uint64)usertrap;
    80002a90:	7138                	ld	a4,96(a0)
    80002a92:	00000697          	auipc	a3,0x0
    80002a96:	13e68693          	addi	a3,a3,318 # 80002bd0 <usertrap>
    80002a9a:	eb14                	sd	a3,16(a4)
	p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002a9c:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002a9e:	8692                	mv	a3,tp
    80002aa0:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002aa2:	100026f3          	csrr	a3,sstatus
	// set up the registers that trampoline.S's sret will use
	// to get to user space.

	// set S Previous Privilege mode to User.
	unsigned long x = r_sstatus();
	x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002aa6:	eff6f693          	andi	a3,a3,-257
	x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002aaa:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002aae:	10069073          	csrw	sstatus,a3
	w_sstatus(x);

	// set S Exception Program Counter to the saved user pc.
	w_sepc(p->trapframe->epc);
    80002ab2:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002ab4:	6f18                	ld	a4,24(a4)
    80002ab6:	14171073          	csrw	sepc,a4

	// tell trampoline.S the user page table to switch to.
	uint64 satp = MAKE_SATP(p->pagetable);
    80002aba:	6d28                	ld	a0,88(a0)
    80002abc:	8131                	srli	a0,a0,0xc

	// jump to userret in trampoline.S at the top of memory, which
	// switches to the user page table, restores user registers,
	// and switches to user mode with sret.
	uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002abe:	00004717          	auipc	a4,0x4
    80002ac2:	5de70713          	addi	a4,a4,1502 # 8000709c <userret>
    80002ac6:	8f11                	sub	a4,a4,a2
    80002ac8:	97ba                	add	a5,a5,a4
	((void (*)(uint64))trampoline_userret)(satp);
    80002aca:	577d                	li	a4,-1
    80002acc:	177e                	slli	a4,a4,0x3f
    80002ace:	8d59                	or	a0,a0,a4
    80002ad0:	9782                	jalr	a5
}
    80002ad2:	60a2                	ld	ra,8(sp)
    80002ad4:	6402                	ld	s0,0(sp)
    80002ad6:	0141                	addi	sp,sp,16
    80002ad8:	8082                	ret

0000000080002ada <clockintr>:
	w_sepc(sepc);
	w_sstatus(sstatus);
}

void clockintr()
{
    80002ada:	1101                	addi	sp,sp,-32
    80002adc:	ec06                	sd	ra,24(sp)
    80002ade:	e822                	sd	s0,16(sp)
    80002ae0:	e426                	sd	s1,8(sp)
    80002ae2:	e04a                	sd	s2,0(sp)
    80002ae4:	1000                	addi	s0,sp,32
	acquire(&tickslock);
    80002ae6:	00016917          	auipc	s2,0x16
    80002aea:	b9a90913          	addi	s2,s2,-1126 # 80018680 <tickslock>
    80002aee:	854a                	mv	a0,s2
    80002af0:	ffffe097          	auipc	ra,0xffffe
    80002af4:	0fa080e7          	jalr	250(ra) # 80000bea <acquire>
	ticks++;
    80002af8:	00006497          	auipc	s1,0x6
    80002afc:	0e848493          	addi	s1,s1,232 # 80008be0 <ticks>
    80002b00:	409c                	lw	a5,0(s1)
    80002b02:	2785                	addiw	a5,a5,1
    80002b04:	c09c                	sw	a5,0(s1)
	upd_time();
    80002b06:	fffff097          	auipc	ra,0xfffff
    80002b0a:	508080e7          	jalr	1288(ra) # 8000200e <upd_time>
	wakeup(&ticks);
    80002b0e:	8526                	mv	a0,s1
    80002b10:	00000097          	auipc	ra,0x0
    80002b14:	90e080e7          	jalr	-1778(ra) # 8000241e <wakeup>
	release(&tickslock);
    80002b18:	854a                	mv	a0,s2
    80002b1a:	ffffe097          	auipc	ra,0xffffe
    80002b1e:	184080e7          	jalr	388(ra) # 80000c9e <release>
}
    80002b22:	60e2                	ld	ra,24(sp)
    80002b24:	6442                	ld	s0,16(sp)
    80002b26:	64a2                	ld	s1,8(sp)
    80002b28:	6902                	ld	s2,0(sp)
    80002b2a:	6105                	addi	sp,sp,32
    80002b2c:	8082                	ret

0000000080002b2e <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    80002b2e:	1101                	addi	sp,sp,-32
    80002b30:	ec06                	sd	ra,24(sp)
    80002b32:	e822                	sd	s0,16(sp)
    80002b34:	e426                	sd	s1,8(sp)
    80002b36:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b38:	14202773          	csrr	a4,scause
	uint64 scause = r_scause();

	if ((scause & 0x8000000000000000L) &&
    80002b3c:	00074d63          	bltz	a4,80002b56 <devintr+0x28>
		if (irq)
			plic_complete(irq);

		return 1;
	}
	else if (scause == 0x8000000000000001L)
    80002b40:	57fd                	li	a5,-1
    80002b42:	17fe                	slli	a5,a5,0x3f
    80002b44:	0785                	addi	a5,a5,1

		return 2;
	}
	else
	{
		return 0;
    80002b46:	4501                	li	a0,0
	else if (scause == 0x8000000000000001L)
    80002b48:	06f70363          	beq	a4,a5,80002bae <devintr+0x80>
	}
}
    80002b4c:	60e2                	ld	ra,24(sp)
    80002b4e:	6442                	ld	s0,16(sp)
    80002b50:	64a2                	ld	s1,8(sp)
    80002b52:	6105                	addi	sp,sp,32
    80002b54:	8082                	ret
		(scause & 0xff) == 9)
    80002b56:	0ff77793          	andi	a5,a4,255
	if ((scause & 0x8000000000000000L) &&
    80002b5a:	46a5                	li	a3,9
    80002b5c:	fed792e3          	bne	a5,a3,80002b40 <devintr+0x12>
		int irq = plic_claim();
    80002b60:	00003097          	auipc	ra,0x3
    80002b64:	748080e7          	jalr	1864(ra) # 800062a8 <plic_claim>
    80002b68:	84aa                	mv	s1,a0
		if (irq == UART0_IRQ)
    80002b6a:	47a9                	li	a5,10
    80002b6c:	02f50763          	beq	a0,a5,80002b9a <devintr+0x6c>
		else if (irq == VIRTIO0_IRQ)
    80002b70:	4785                	li	a5,1
    80002b72:	02f50963          	beq	a0,a5,80002ba4 <devintr+0x76>
		return 1;
    80002b76:	4505                	li	a0,1
		else if (irq)
    80002b78:	d8f1                	beqz	s1,80002b4c <devintr+0x1e>
			printf("unexpected interrupt irq=%d\n", irq);
    80002b7a:	85a6                	mv	a1,s1
    80002b7c:	00005517          	auipc	a0,0x5
    80002b80:	7ac50513          	addi	a0,a0,1964 # 80008328 <states.2493+0x38>
    80002b84:	ffffe097          	auipc	ra,0xffffe
    80002b88:	a0a080e7          	jalr	-1526(ra) # 8000058e <printf>
			plic_complete(irq);
    80002b8c:	8526                	mv	a0,s1
    80002b8e:	00003097          	auipc	ra,0x3
    80002b92:	73e080e7          	jalr	1854(ra) # 800062cc <plic_complete>
		return 1;
    80002b96:	4505                	li	a0,1
    80002b98:	bf55                	j	80002b4c <devintr+0x1e>
			uartintr();
    80002b9a:	ffffe097          	auipc	ra,0xffffe
    80002b9e:	e14080e7          	jalr	-492(ra) # 800009ae <uartintr>
    80002ba2:	b7ed                	j	80002b8c <devintr+0x5e>
			virtio_disk_intr();
    80002ba4:	00004097          	auipc	ra,0x4
    80002ba8:	c52080e7          	jalr	-942(ra) # 800067f6 <virtio_disk_intr>
    80002bac:	b7c5                	j	80002b8c <devintr+0x5e>
		if (cpuid() == 0)
    80002bae:	fffff097          	auipc	ra,0xfffff
    80002bb2:	ef6080e7          	jalr	-266(ra) # 80001aa4 <cpuid>
    80002bb6:	c901                	beqz	a0,80002bc6 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002bb8:	144027f3          	csrr	a5,sip
		w_sip(r_sip() & ~2);
    80002bbc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002bbe:	14479073          	csrw	sip,a5
		return 2;
    80002bc2:	4509                	li	a0,2
    80002bc4:	b761                	j	80002b4c <devintr+0x1e>
			clockintr();
    80002bc6:	00000097          	auipc	ra,0x0
    80002bca:	f14080e7          	jalr	-236(ra) # 80002ada <clockintr>
    80002bce:	b7ed                	j	80002bb8 <devintr+0x8a>

0000000080002bd0 <usertrap>:
{
    80002bd0:	1101                	addi	sp,sp,-32
    80002bd2:	ec06                	sd	ra,24(sp)
    80002bd4:	e822                	sd	s0,16(sp)
    80002bd6:	e426                	sd	s1,8(sp)
    80002bd8:	e04a                	sd	s2,0(sp)
    80002bda:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bdc:	100027f3          	csrr	a5,sstatus
	if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002be0:	1007f793          	andi	a5,a5,256
    80002be4:	e3b1                	bnez	a5,80002c28 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002be6:	00003797          	auipc	a5,0x3
    80002bea:	5ba78793          	addi	a5,a5,1466 # 800061a0 <kernelvec>
    80002bee:	10579073          	csrw	stvec,a5
	struct proc *p = myproc();
    80002bf2:	fffff097          	auipc	ra,0xfffff
    80002bf6:	ede080e7          	jalr	-290(ra) # 80001ad0 <myproc>
    80002bfa:	84aa                	mv	s1,a0
	p->trapframe->epc = r_sepc();
    80002bfc:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bfe:	14102773          	csrr	a4,sepc
    80002c02:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c04:	14202773          	csrr	a4,scause
	if (r_scause() == 8)
    80002c08:	47a1                	li	a5,8
    80002c0a:	02f70763          	beq	a4,a5,80002c38 <usertrap+0x68>
	else if ((which_dev = devintr()) != 0)
    80002c0e:	00000097          	auipc	ra,0x0
    80002c12:	f20080e7          	jalr	-224(ra) # 80002b2e <devintr>
    80002c16:	892a                	mv	s2,a0
    80002c18:	c151                	beqz	a0,80002c9c <usertrap+0xcc>
	if (killed(p))
    80002c1a:	8526                	mv	a0,s1
    80002c1c:	00000097          	auipc	ra,0x0
    80002c20:	aa8080e7          	jalr	-1368(ra) # 800026c4 <killed>
    80002c24:	c929                	beqz	a0,80002c76 <usertrap+0xa6>
    80002c26:	a099                	j	80002c6c <usertrap+0x9c>
		panic("usertrap: not from user mode");
    80002c28:	00005517          	auipc	a0,0x5
    80002c2c:	72050513          	addi	a0,a0,1824 # 80008348 <states.2493+0x58>
    80002c30:	ffffe097          	auipc	ra,0xffffe
    80002c34:	914080e7          	jalr	-1772(ra) # 80000544 <panic>
		if (killed(p))
    80002c38:	00000097          	auipc	ra,0x0
    80002c3c:	a8c080e7          	jalr	-1396(ra) # 800026c4 <killed>
    80002c40:	e921                	bnez	a0,80002c90 <usertrap+0xc0>
		p->trapframe->epc += 4;
    80002c42:	70b8                	ld	a4,96(s1)
    80002c44:	6f1c                	ld	a5,24(a4)
    80002c46:	0791                	addi	a5,a5,4
    80002c48:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c4a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002c4e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c52:	10079073          	csrw	sstatus,a5
		syscall();
    80002c56:	00000097          	auipc	ra,0x0
    80002c5a:	2d4080e7          	jalr	724(ra) # 80002f2a <syscall>
	if (killed(p))
    80002c5e:	8526                	mv	a0,s1
    80002c60:	00000097          	auipc	ra,0x0
    80002c64:	a64080e7          	jalr	-1436(ra) # 800026c4 <killed>
    80002c68:	c911                	beqz	a0,80002c7c <usertrap+0xac>
    80002c6a:	4901                	li	s2,0
		exit(-1);
    80002c6c:	557d                	li	a0,-1
    80002c6e:	00000097          	auipc	ra,0x0
    80002c72:	8b0080e7          	jalr	-1872(ra) # 8000251e <exit>
	if (which_dev == 2)
    80002c76:	4789                	li	a5,2
    80002c78:	04f90f63          	beq	s2,a5,80002cd6 <usertrap+0x106>
	usertrapret();
    80002c7c:	00000097          	auipc	ra,0x0
    80002c80:	dc8080e7          	jalr	-568(ra) # 80002a44 <usertrapret>
}
    80002c84:	60e2                	ld	ra,24(sp)
    80002c86:	6442                	ld	s0,16(sp)
    80002c88:	64a2                	ld	s1,8(sp)
    80002c8a:	6902                	ld	s2,0(sp)
    80002c8c:	6105                	addi	sp,sp,32
    80002c8e:	8082                	ret
			exit(-1);
    80002c90:	557d                	li	a0,-1
    80002c92:	00000097          	auipc	ra,0x0
    80002c96:	88c080e7          	jalr	-1908(ra) # 8000251e <exit>
    80002c9a:	b765                	j	80002c42 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c9c:	142025f3          	csrr	a1,scause
		printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002ca0:	5c90                	lw	a2,56(s1)
    80002ca2:	00005517          	auipc	a0,0x5
    80002ca6:	6c650513          	addi	a0,a0,1734 # 80008368 <states.2493+0x78>
    80002caa:	ffffe097          	auipc	ra,0xffffe
    80002cae:	8e4080e7          	jalr	-1820(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cb2:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002cb6:	14302673          	csrr	a2,stval
		printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002cba:	00005517          	auipc	a0,0x5
    80002cbe:	6de50513          	addi	a0,a0,1758 # 80008398 <states.2493+0xa8>
    80002cc2:	ffffe097          	auipc	ra,0xffffe
    80002cc6:	8cc080e7          	jalr	-1844(ra) # 8000058e <printf>
		setkilled(p);
    80002cca:	8526                	mv	a0,s1
    80002ccc:	00000097          	auipc	ra,0x0
    80002cd0:	9c2080e7          	jalr	-1598(ra) # 8000268e <setkilled>
    80002cd4:	b769                	j	80002c5e <usertrap+0x8e>
		yield();
    80002cd6:	fffff097          	auipc	ra,0xfffff
    80002cda:	524080e7          	jalr	1316(ra) # 800021fa <yield>
    80002cde:	bf79                	j	80002c7c <usertrap+0xac>

0000000080002ce0 <kerneltrap>:
{
    80002ce0:	7179                	addi	sp,sp,-48
    80002ce2:	f406                	sd	ra,40(sp)
    80002ce4:	f022                	sd	s0,32(sp)
    80002ce6:	ec26                	sd	s1,24(sp)
    80002ce8:	e84a                	sd	s2,16(sp)
    80002cea:	e44e                	sd	s3,8(sp)
    80002cec:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cee:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cf2:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cf6:	142029f3          	csrr	s3,scause
	if ((sstatus & SSTATUS_SPP) == 0)
    80002cfa:	1004f793          	andi	a5,s1,256
    80002cfe:	cb85                	beqz	a5,80002d2e <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d00:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002d04:	8b89                	andi	a5,a5,2
	if (intr_get() != 0)
    80002d06:	ef85                	bnez	a5,80002d3e <kerneltrap+0x5e>
	if ((which_dev = devintr()) == 0)
    80002d08:	00000097          	auipc	ra,0x0
    80002d0c:	e26080e7          	jalr	-474(ra) # 80002b2e <devintr>
    80002d10:	cd1d                	beqz	a0,80002d4e <kerneltrap+0x6e>
	if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d12:	4789                	li	a5,2
    80002d14:	06f50a63          	beq	a0,a5,80002d88 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002d18:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d1c:	10049073          	csrw	sstatus,s1
}
    80002d20:	70a2                	ld	ra,40(sp)
    80002d22:	7402                	ld	s0,32(sp)
    80002d24:	64e2                	ld	s1,24(sp)
    80002d26:	6942                	ld	s2,16(sp)
    80002d28:	69a2                	ld	s3,8(sp)
    80002d2a:	6145                	addi	sp,sp,48
    80002d2c:	8082                	ret
		panic("kerneltrap: not from supervisor mode");
    80002d2e:	00005517          	auipc	a0,0x5
    80002d32:	68a50513          	addi	a0,a0,1674 # 800083b8 <states.2493+0xc8>
    80002d36:	ffffe097          	auipc	ra,0xffffe
    80002d3a:	80e080e7          	jalr	-2034(ra) # 80000544 <panic>
		panic("kerneltrap: interrupts enabled");
    80002d3e:	00005517          	auipc	a0,0x5
    80002d42:	6a250513          	addi	a0,a0,1698 # 800083e0 <states.2493+0xf0>
    80002d46:	ffffd097          	auipc	ra,0xffffd
    80002d4a:	7fe080e7          	jalr	2046(ra) # 80000544 <panic>
		printf("scause %p\n", scause);
    80002d4e:	85ce                	mv	a1,s3
    80002d50:	00005517          	auipc	a0,0x5
    80002d54:	6b050513          	addi	a0,a0,1712 # 80008400 <states.2493+0x110>
    80002d58:	ffffe097          	auipc	ra,0xffffe
    80002d5c:	836080e7          	jalr	-1994(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d60:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d64:	14302673          	csrr	a2,stval
		printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d68:	00005517          	auipc	a0,0x5
    80002d6c:	6a850513          	addi	a0,a0,1704 # 80008410 <states.2493+0x120>
    80002d70:	ffffe097          	auipc	ra,0xffffe
    80002d74:	81e080e7          	jalr	-2018(ra) # 8000058e <printf>
		panic("kerneltrap");
    80002d78:	00005517          	auipc	a0,0x5
    80002d7c:	6b050513          	addi	a0,a0,1712 # 80008428 <states.2493+0x138>
    80002d80:	ffffd097          	auipc	ra,0xffffd
    80002d84:	7c4080e7          	jalr	1988(ra) # 80000544 <panic>
	if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d88:	fffff097          	auipc	ra,0xfffff
    80002d8c:	d48080e7          	jalr	-696(ra) # 80001ad0 <myproc>
    80002d90:	d541                	beqz	a0,80002d18 <kerneltrap+0x38>
    80002d92:	fffff097          	auipc	ra,0xfffff
    80002d96:	d3e080e7          	jalr	-706(ra) # 80001ad0 <myproc>
    80002d9a:	5118                	lw	a4,32(a0)
    80002d9c:	4791                	li	a5,4
    80002d9e:	f6f71de3          	bne	a4,a5,80002d18 <kerneltrap+0x38>
		yield();
    80002da2:	fffff097          	auipc	ra,0xfffff
    80002da6:	458080e7          	jalr	1112(ra) # 800021fa <yield>
    80002daa:	b7bd                	j	80002d18 <kerneltrap+0x38>

0000000080002dac <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002dac:	1101                	addi	sp,sp,-32
    80002dae:	ec06                	sd	ra,24(sp)
    80002db0:	e822                	sd	s0,16(sp)
    80002db2:	e426                	sd	s1,8(sp)
    80002db4:	1000                	addi	s0,sp,32
    80002db6:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002db8:	fffff097          	auipc	ra,0xfffff
    80002dbc:	d18080e7          	jalr	-744(ra) # 80001ad0 <myproc>
  switch (n)
    80002dc0:	4795                	li	a5,5
    80002dc2:	0497e163          	bltu	a5,s1,80002e04 <argraw+0x58>
    80002dc6:	048a                	slli	s1,s1,0x2
    80002dc8:	00005717          	auipc	a4,0x5
    80002dcc:	7a870713          	addi	a4,a4,1960 # 80008570 <states.2493+0x280>
    80002dd0:	94ba                	add	s1,s1,a4
    80002dd2:	409c                	lw	a5,0(s1)
    80002dd4:	97ba                	add	a5,a5,a4
    80002dd6:	8782                	jr	a5
  {
  case 0:
    return p->trapframe->a0;
    80002dd8:	713c                	ld	a5,96(a0)
    80002dda:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002ddc:	60e2                	ld	ra,24(sp)
    80002dde:	6442                	ld	s0,16(sp)
    80002de0:	64a2                	ld	s1,8(sp)
    80002de2:	6105                	addi	sp,sp,32
    80002de4:	8082                	ret
    return p->trapframe->a1;
    80002de6:	713c                	ld	a5,96(a0)
    80002de8:	7fa8                	ld	a0,120(a5)
    80002dea:	bfcd                	j	80002ddc <argraw+0x30>
    return p->trapframe->a2;
    80002dec:	713c                	ld	a5,96(a0)
    80002dee:	63c8                	ld	a0,128(a5)
    80002df0:	b7f5                	j	80002ddc <argraw+0x30>
    return p->trapframe->a3;
    80002df2:	713c                	ld	a5,96(a0)
    80002df4:	67c8                	ld	a0,136(a5)
    80002df6:	b7dd                	j	80002ddc <argraw+0x30>
    return p->trapframe->a4;
    80002df8:	713c                	ld	a5,96(a0)
    80002dfa:	6bc8                	ld	a0,144(a5)
    80002dfc:	b7c5                	j	80002ddc <argraw+0x30>
    return p->trapframe->a5;
    80002dfe:	713c                	ld	a5,96(a0)
    80002e00:	6fc8                	ld	a0,152(a5)
    80002e02:	bfe9                	j	80002ddc <argraw+0x30>
  panic("argraw");
    80002e04:	00005517          	auipc	a0,0x5
    80002e08:	63450513          	addi	a0,a0,1588 # 80008438 <states.2493+0x148>
    80002e0c:	ffffd097          	auipc	ra,0xffffd
    80002e10:	738080e7          	jalr	1848(ra) # 80000544 <panic>

0000000080002e14 <fetchaddr>:
{
    80002e14:	1101                	addi	sp,sp,-32
    80002e16:	ec06                	sd	ra,24(sp)
    80002e18:	e822                	sd	s0,16(sp)
    80002e1a:	e426                	sd	s1,8(sp)
    80002e1c:	e04a                	sd	s2,0(sp)
    80002e1e:	1000                	addi	s0,sp,32
    80002e20:	84aa                	mv	s1,a0
    80002e22:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002e24:	fffff097          	auipc	ra,0xfffff
    80002e28:	cac080e7          	jalr	-852(ra) # 80001ad0 <myproc>
  if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002e2c:	693c                	ld	a5,80(a0)
    80002e2e:	02f4f863          	bgeu	s1,a5,80002e5e <fetchaddr+0x4a>
    80002e32:	00848713          	addi	a4,s1,8
    80002e36:	02e7e663          	bltu	a5,a4,80002e62 <fetchaddr+0x4e>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002e3a:	46a1                	li	a3,8
    80002e3c:	8626                	mv	a2,s1
    80002e3e:	85ca                	mv	a1,s2
    80002e40:	6d28                	ld	a0,88(a0)
    80002e42:	fffff097          	auipc	ra,0xfffff
    80002e46:	8ce080e7          	jalr	-1842(ra) # 80001710 <copyin>
    80002e4a:	00a03533          	snez	a0,a0
    80002e4e:	40a00533          	neg	a0,a0
}
    80002e52:	60e2                	ld	ra,24(sp)
    80002e54:	6442                	ld	s0,16(sp)
    80002e56:	64a2                	ld	s1,8(sp)
    80002e58:	6902                	ld	s2,0(sp)
    80002e5a:	6105                	addi	sp,sp,32
    80002e5c:	8082                	ret
    return -1;
    80002e5e:	557d                	li	a0,-1
    80002e60:	bfcd                	j	80002e52 <fetchaddr+0x3e>
    80002e62:	557d                	li	a0,-1
    80002e64:	b7fd                	j	80002e52 <fetchaddr+0x3e>

0000000080002e66 <fetchstr>:
{
    80002e66:	7179                	addi	sp,sp,-48
    80002e68:	f406                	sd	ra,40(sp)
    80002e6a:	f022                	sd	s0,32(sp)
    80002e6c:	ec26                	sd	s1,24(sp)
    80002e6e:	e84a                	sd	s2,16(sp)
    80002e70:	e44e                	sd	s3,8(sp)
    80002e72:	1800                	addi	s0,sp,48
    80002e74:	892a                	mv	s2,a0
    80002e76:	84ae                	mv	s1,a1
    80002e78:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002e7a:	fffff097          	auipc	ra,0xfffff
    80002e7e:	c56080e7          	jalr	-938(ra) # 80001ad0 <myproc>
  if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80002e82:	86ce                	mv	a3,s3
    80002e84:	864a                	mv	a2,s2
    80002e86:	85a6                	mv	a1,s1
    80002e88:	6d28                	ld	a0,88(a0)
    80002e8a:	fffff097          	auipc	ra,0xfffff
    80002e8e:	912080e7          	jalr	-1774(ra) # 8000179c <copyinstr>
    80002e92:	00054e63          	bltz	a0,80002eae <fetchstr+0x48>
  return strlen(buf);
    80002e96:	8526                	mv	a0,s1
    80002e98:	ffffe097          	auipc	ra,0xffffe
    80002e9c:	fd2080e7          	jalr	-46(ra) # 80000e6a <strlen>
}
    80002ea0:	70a2                	ld	ra,40(sp)
    80002ea2:	7402                	ld	s0,32(sp)
    80002ea4:	64e2                	ld	s1,24(sp)
    80002ea6:	6942                	ld	s2,16(sp)
    80002ea8:	69a2                	ld	s3,8(sp)
    80002eaa:	6145                	addi	sp,sp,48
    80002eac:	8082                	ret
    return -1;
    80002eae:	557d                	li	a0,-1
    80002eb0:	bfc5                	j	80002ea0 <fetchstr+0x3a>

0000000080002eb2 <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80002eb2:	1101                	addi	sp,sp,-32
    80002eb4:	ec06                	sd	ra,24(sp)
    80002eb6:	e822                	sd	s0,16(sp)
    80002eb8:	e426                	sd	s1,8(sp)
    80002eba:	1000                	addi	s0,sp,32
    80002ebc:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ebe:	00000097          	auipc	ra,0x0
    80002ec2:	eee080e7          	jalr	-274(ra) # 80002dac <argraw>
    80002ec6:	c088                	sw	a0,0(s1)
}
    80002ec8:	60e2                	ld	ra,24(sp)
    80002eca:	6442                	ld	s0,16(sp)
    80002ecc:	64a2                	ld	s1,8(sp)
    80002ece:	6105                	addi	sp,sp,32
    80002ed0:	8082                	ret

0000000080002ed2 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80002ed2:	1101                	addi	sp,sp,-32
    80002ed4:	ec06                	sd	ra,24(sp)
    80002ed6:	e822                	sd	s0,16(sp)
    80002ed8:	e426                	sd	s1,8(sp)
    80002eda:	1000                	addi	s0,sp,32
    80002edc:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ede:	00000097          	auipc	ra,0x0
    80002ee2:	ece080e7          	jalr	-306(ra) # 80002dac <argraw>
    80002ee6:	e088                	sd	a0,0(s1)
}
    80002ee8:	60e2                	ld	ra,24(sp)
    80002eea:	6442                	ld	s0,16(sp)
    80002eec:	64a2                	ld	s1,8(sp)
    80002eee:	6105                	addi	sp,sp,32
    80002ef0:	8082                	ret

0000000080002ef2 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80002ef2:	7179                	addi	sp,sp,-48
    80002ef4:	f406                	sd	ra,40(sp)
    80002ef6:	f022                	sd	s0,32(sp)
    80002ef8:	ec26                	sd	s1,24(sp)
    80002efa:	e84a                	sd	s2,16(sp)
    80002efc:	1800                	addi	s0,sp,48
    80002efe:	84ae                	mv	s1,a1
    80002f00:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002f02:	fd840593          	addi	a1,s0,-40
    80002f06:	00000097          	auipc	ra,0x0
    80002f0a:	fcc080e7          	jalr	-52(ra) # 80002ed2 <argaddr>
  return fetchstr(addr, buf, max);
    80002f0e:	864a                	mv	a2,s2
    80002f10:	85a6                	mv	a1,s1
    80002f12:	fd843503          	ld	a0,-40(s0)
    80002f16:	00000097          	auipc	ra,0x0
    80002f1a:	f50080e7          	jalr	-176(ra) # 80002e66 <fetchstr>
}
    80002f1e:	70a2                	ld	ra,40(sp)
    80002f20:	7402                	ld	s0,32(sp)
    80002f22:	64e2                	ld	s1,24(sp)
    80002f24:	6942                	ld	s2,16(sp)
    80002f26:	6145                	addi	sp,sp,48
    80002f28:	8082                	ret

0000000080002f2a <syscall>:
    {"settickets", 1},
    {"waitx",3}
};

void syscall(void)
{
    80002f2a:	711d                	addi	sp,sp,-96
    80002f2c:	ec86                	sd	ra,88(sp)
    80002f2e:	e8a2                	sd	s0,80(sp)
    80002f30:	e4a6                	sd	s1,72(sp)
    80002f32:	e0ca                	sd	s2,64(sp)
    80002f34:	fc4e                	sd	s3,56(sp)
    80002f36:	f852                	sd	s4,48(sp)
    80002f38:	f456                	sd	s5,40(sp)
    80002f3a:	f05a                	sd	s6,32(sp)
    80002f3c:	ec5e                	sd	s7,24(sp)
    80002f3e:	e862                	sd	s8,16(sp)
    80002f40:	e466                	sd	s9,8(sp)
    80002f42:	e06a                	sd	s10,0(sp)
    80002f44:	1080                	addi	s0,sp,96
  int num;
  struct proc *p = myproc();
    80002f46:	fffff097          	auipc	ra,0xfffff
    80002f4a:	b8a080e7          	jalr	-1142(ra) # 80001ad0 <myproc>
    80002f4e:	8a2a                	mv	s4,a0

  num = p->trapframe->a7; // return reg
    80002f50:	7124                	ld	s1,96(a0)
    80002f52:	74dc                	ld	a5,168(s1)
    80002f54:	00078b1b          	sext.w	s6,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    80002f58:	37fd                	addiw	a5,a5,-1
    80002f5a:	4765                	li	a4,25
    80002f5c:	06f76f63          	bltu	a4,a5,80002fda <syscall+0xb0>
    80002f60:	003b1713          	slli	a4,s6,0x3
    80002f64:	00005797          	auipc	a5,0x5
    80002f68:	62478793          	addi	a5,a5,1572 # 80008588 <syscalls>
    80002f6c:	97ba                	add	a5,a5,a4
    80002f6e:	0007bd03          	ld	s10,0(a5)
    80002f72:	060d0463          	beqz	s10,80002fda <syscall+0xb0>
  {
    80002f76:	8c8a                	mv	s9,sp
    int numargs = syscall_info[num - 1].num;
    80002f78:	fffb0c1b          	addiw	s8,s6,-1
    80002f7c:	004c1713          	slli	a4,s8,0x4
    80002f80:	00006797          	auipc	a5,0x6
    80002f84:	a6878793          	addi	a5,a5,-1432 # 800089e8 <syscall_info>
    80002f88:	97ba                	add	a5,a5,a4
    80002f8a:	0087a983          	lw	s3,8(a5)
    int Args[numargs]; // to store value of registers acc to the number of args of the syscall
    80002f8e:	00299793          	slli	a5,s3,0x2
    80002f92:	07bd                	addi	a5,a5,15
    80002f94:	9bc1                	andi	a5,a5,-16
    80002f96:	40f10133          	sub	sp,sp,a5
    80002f9a:	8b8a                	mv	s7,sp
    int j = 0;
    while (j < numargs)
    80002f9c:	11305363          	blez	s3,800030a2 <syscall+0x178>
    80002fa0:	8ade                	mv	s5,s7
    80002fa2:	895e                	mv	s2,s7
    int j = 0;
    80002fa4:	4481                	li	s1,0
    {
      Args[j] = argraw(j);
    80002fa6:	8526                	mv	a0,s1
    80002fa8:	00000097          	auipc	ra,0x0
    80002fac:	e04080e7          	jalr	-508(ra) # 80002dac <argraw>
    80002fb0:	00a92023          	sw	a0,0(s2)
      j++;
    80002fb4:	2485                	addiw	s1,s1,1
    while (j < numargs)
    80002fb6:	0911                	addi	s2,s2,4
    80002fb8:	fe9997e3          	bne	s3,s1,80002fa6 <syscall+0x7c>
    }

    int shift = 1 << num; // mask for num
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002fbc:	060a3483          	ld	s1,96(s4)
    80002fc0:	9d02                	jalr	s10
    80002fc2:	f8a8                	sd	a0,112(s1)
    int shift = 1 << num; // mask for num
    80002fc4:	4785                	li	a5,1
    80002fc6:	016797bb          	sllw	a5,a5,s6

    if (p->mask & shift)
    80002fca:	000a2b03          	lw	s6,0(s4)
    80002fce:	0167f7b3          	and	a5,a5,s6
    80002fd2:	2781                	sext.w	a5,a5
    80002fd4:	e7a1                	bnez	a5,8000301c <syscall+0xf2>
    80002fd6:	8166                	mv	sp,s9
  {
    80002fd8:	a015                	j	80002ffc <syscall+0xd2>
      printf(" -> %d\n", p->trapframe->a0);
    }
  }
  else
  {
    printf("%d %s: unknown sys call %d\n",
    80002fda:	86da                	mv	a3,s6
    80002fdc:	160a0613          	addi	a2,s4,352
    80002fe0:	038a2583          	lw	a1,56(s4)
    80002fe4:	00005517          	auipc	a0,0x5
    80002fe8:	47450513          	addi	a0,a0,1140 # 80008458 <states.2493+0x168>
    80002fec:	ffffd097          	auipc	ra,0xffffd
    80002ff0:	5a2080e7          	jalr	1442(ra) # 8000058e <printf>
           p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002ff4:	060a3783          	ld	a5,96(s4)
    80002ff8:	577d                	li	a4,-1
    80002ffa:	fbb8                	sd	a4,112(a5)
  }
}
    80002ffc:	fa040113          	addi	sp,s0,-96
    80003000:	60e6                	ld	ra,88(sp)
    80003002:	6446                	ld	s0,80(sp)
    80003004:	64a6                	ld	s1,72(sp)
    80003006:	6906                	ld	s2,64(sp)
    80003008:	79e2                	ld	s3,56(sp)
    8000300a:	7a42                	ld	s4,48(sp)
    8000300c:	7aa2                	ld	s5,40(sp)
    8000300e:	7b02                	ld	s6,32(sp)
    80003010:	6be2                	ld	s7,24(sp)
    80003012:	6c42                	ld	s8,16(sp)
    80003014:	6ca2                	ld	s9,8(sp)
    80003016:	6d02                	ld	s10,0(sp)
    80003018:	6125                	addi	sp,sp,96
    8000301a:	8082                	ret
      printf("%d: syscall %s ", p->pid, syscall_info[num - 1].name);
    8000301c:	0c12                	slli	s8,s8,0x4
    8000301e:	00006797          	auipc	a5,0x6
    80003022:	9ca78793          	addi	a5,a5,-1590 # 800089e8 <syscall_info>
    80003026:	9c3e                	add	s8,s8,a5
    80003028:	000c3603          	ld	a2,0(s8)
    8000302c:	038a2583          	lw	a1,56(s4)
    80003030:	00005517          	auipc	a0,0x5
    80003034:	44850513          	addi	a0,a0,1096 # 80008478 <states.2493+0x188>
    80003038:	ffffd097          	auipc	ra,0xffffd
    8000303c:	556080e7          	jalr	1366(ra) # 8000058e <printf>
      printf("(");
    80003040:	00005517          	auipc	a0,0x5
    80003044:	44850513          	addi	a0,a0,1096 # 80008488 <states.2493+0x198>
    80003048:	ffffd097          	auipc	ra,0xffffd
    8000304c:	546080e7          	jalr	1350(ra) # 8000058e <printf>
      while (i < numargs)
    80003050:	fff9879b          	addiw	a5,s3,-1
    80003054:	1782                	slli	a5,a5,0x20
    80003056:	9381                	srli	a5,a5,0x20
    80003058:	0785                	addi	a5,a5,1
    8000305a:	078a                	slli	a5,a5,0x2
    8000305c:	9bbe                	add	s7,s7,a5
        printf("%d ", Args[i]);
    8000305e:	00005497          	auipc	s1,0x5
    80003062:	3e248493          	addi	s1,s1,994 # 80008440 <states.2493+0x150>
    80003066:	000aa583          	lw	a1,0(s5)
    8000306a:	8526                	mv	a0,s1
    8000306c:	ffffd097          	auipc	ra,0xffffd
    80003070:	522080e7          	jalr	1314(ra) # 8000058e <printf>
      while (i < numargs)
    80003074:	0a91                	addi	s5,s5,4
    80003076:	ff7a98e3          	bne	s5,s7,80003066 <syscall+0x13c>
      printf(")");
    8000307a:	00005517          	auipc	a0,0x5
    8000307e:	3ce50513          	addi	a0,a0,974 # 80008448 <states.2493+0x158>
    80003082:	ffffd097          	auipc	ra,0xffffd
    80003086:	50c080e7          	jalr	1292(ra) # 8000058e <printf>
      printf(" -> %d\n", p->trapframe->a0);
    8000308a:	060a3783          	ld	a5,96(s4)
    8000308e:	7bac                	ld	a1,112(a5)
    80003090:	00005517          	auipc	a0,0x5
    80003094:	3c050513          	addi	a0,a0,960 # 80008450 <states.2493+0x160>
    80003098:	ffffd097          	auipc	ra,0xffffd
    8000309c:	4f6080e7          	jalr	1270(ra) # 8000058e <printf>
    800030a0:	bf1d                	j	80002fd6 <syscall+0xac>
    p->trapframe->a0 = syscalls[num]();
    800030a2:	9d02                	jalr	s10
    800030a4:	f8a8                	sd	a0,112(s1)
    int shift = 1 << num; // mask for num
    800030a6:	4785                	li	a5,1
    800030a8:	016797bb          	sllw	a5,a5,s6
    if (p->mask & shift)
    800030ac:	000a2703          	lw	a4,0(s4)
    800030b0:	8ff9                	and	a5,a5,a4
    800030b2:	2781                	sext.w	a5,a5
    800030b4:	d38d                	beqz	a5,80002fd6 <syscall+0xac>
      printf("%d: syscall %s ", p->pid, syscall_info[num - 1].name);
    800030b6:	0c12                	slli	s8,s8,0x4
    800030b8:	00006797          	auipc	a5,0x6
    800030bc:	93078793          	addi	a5,a5,-1744 # 800089e8 <syscall_info>
    800030c0:	97e2                	add	a5,a5,s8
    800030c2:	6390                	ld	a2,0(a5)
    800030c4:	038a2583          	lw	a1,56(s4)
    800030c8:	00005517          	auipc	a0,0x5
    800030cc:	3b050513          	addi	a0,a0,944 # 80008478 <states.2493+0x188>
    800030d0:	ffffd097          	auipc	ra,0xffffd
    800030d4:	4be080e7          	jalr	1214(ra) # 8000058e <printf>
      printf("(");
    800030d8:	00005517          	auipc	a0,0x5
    800030dc:	3b050513          	addi	a0,a0,944 # 80008488 <states.2493+0x198>
    800030e0:	ffffd097          	auipc	ra,0xffffd
    800030e4:	4ae080e7          	jalr	1198(ra) # 8000058e <printf>
      while (i < numargs)
    800030e8:	bf49                	j	8000307a <syscall+0x150>

00000000800030ea <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800030ea:	1101                	addi	sp,sp,-32
    800030ec:	ec06                	sd	ra,24(sp)
    800030ee:	e822                	sd	s0,16(sp)
    800030f0:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800030f2:	fec40593          	addi	a1,s0,-20
    800030f6:	4501                	li	a0,0
    800030f8:	00000097          	auipc	ra,0x0
    800030fc:	dba080e7          	jalr	-582(ra) # 80002eb2 <argint>
  exit(n);
    80003100:	fec42503          	lw	a0,-20(s0)
    80003104:	fffff097          	auipc	ra,0xfffff
    80003108:	41a080e7          	jalr	1050(ra) # 8000251e <exit>
  return 0; // not reached
}
    8000310c:	4501                	li	a0,0
    8000310e:	60e2                	ld	ra,24(sp)
    80003110:	6442                	ld	s0,16(sp)
    80003112:	6105                	addi	sp,sp,32
    80003114:	8082                	ret

0000000080003116 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003116:	1141                	addi	sp,sp,-16
    80003118:	e406                	sd	ra,8(sp)
    8000311a:	e022                	sd	s0,0(sp)
    8000311c:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000311e:	fffff097          	auipc	ra,0xfffff
    80003122:	9b2080e7          	jalr	-1614(ra) # 80001ad0 <myproc>
}
    80003126:	5d08                	lw	a0,56(a0)
    80003128:	60a2                	ld	ra,8(sp)
    8000312a:	6402                	ld	s0,0(sp)
    8000312c:	0141                	addi	sp,sp,16
    8000312e:	8082                	ret

0000000080003130 <sys_fork>:

uint64
sys_fork(void)
{
    80003130:	1141                	addi	sp,sp,-16
    80003132:	e406                	sd	ra,8(sp)
    80003134:	e022                	sd	s0,0(sp)
    80003136:	0800                	addi	s0,sp,16
  return fork();
    80003138:	fffff097          	auipc	ra,0xfffff
    8000313c:	d88080e7          	jalr	-632(ra) # 80001ec0 <fork>
}
    80003140:	60a2                	ld	ra,8(sp)
    80003142:	6402                	ld	s0,0(sp)
    80003144:	0141                	addi	sp,sp,16
    80003146:	8082                	ret

0000000080003148 <sys_wait>:

uint64
sys_wait(void)
{
    80003148:	1101                	addi	sp,sp,-32
    8000314a:	ec06                	sd	ra,24(sp)
    8000314c:	e822                	sd	s0,16(sp)
    8000314e:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80003150:	fe840593          	addi	a1,s0,-24
    80003154:	4501                	li	a0,0
    80003156:	00000097          	auipc	ra,0x0
    8000315a:	d7c080e7          	jalr	-644(ra) # 80002ed2 <argaddr>
  return wait(p);
    8000315e:	fe843503          	ld	a0,-24(s0)
    80003162:	fffff097          	auipc	ra,0xfffff
    80003166:	598080e7          	jalr	1432(ra) # 800026fa <wait>
}
    8000316a:	60e2                	ld	ra,24(sp)
    8000316c:	6442                	ld	s0,16(sp)
    8000316e:	6105                	addi	sp,sp,32
    80003170:	8082                	ret

0000000080003172 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003172:	7179                	addi	sp,sp,-48
    80003174:	f406                	sd	ra,40(sp)
    80003176:	f022                	sd	s0,32(sp)
    80003178:	ec26                	sd	s1,24(sp)
    8000317a:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    8000317c:	fdc40593          	addi	a1,s0,-36
    80003180:	4501                	li	a0,0
    80003182:	00000097          	auipc	ra,0x0
    80003186:	d30080e7          	jalr	-720(ra) # 80002eb2 <argint>
  addr = myproc()->sz;
    8000318a:	fffff097          	auipc	ra,0xfffff
    8000318e:	946080e7          	jalr	-1722(ra) # 80001ad0 <myproc>
    80003192:	6924                	ld	s1,80(a0)
  if (growproc(n) < 0)
    80003194:	fdc42503          	lw	a0,-36(s0)
    80003198:	fffff097          	auipc	ra,0xfffff
    8000319c:	ccc080e7          	jalr	-820(ra) # 80001e64 <growproc>
    800031a0:	00054863          	bltz	a0,800031b0 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    800031a4:	8526                	mv	a0,s1
    800031a6:	70a2                	ld	ra,40(sp)
    800031a8:	7402                	ld	s0,32(sp)
    800031aa:	64e2                	ld	s1,24(sp)
    800031ac:	6145                	addi	sp,sp,48
    800031ae:	8082                	ret
    return -1;
    800031b0:	54fd                	li	s1,-1
    800031b2:	bfcd                	j	800031a4 <sys_sbrk+0x32>

00000000800031b4 <sys_sleep>:

uint64
sys_sleep(void)
{
    800031b4:	7139                	addi	sp,sp,-64
    800031b6:	fc06                	sd	ra,56(sp)
    800031b8:	f822                	sd	s0,48(sp)
    800031ba:	f426                	sd	s1,40(sp)
    800031bc:	f04a                	sd	s2,32(sp)
    800031be:	ec4e                	sd	s3,24(sp)
    800031c0:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800031c2:	fcc40593          	addi	a1,s0,-52
    800031c6:	4501                	li	a0,0
    800031c8:	00000097          	auipc	ra,0x0
    800031cc:	cea080e7          	jalr	-790(ra) # 80002eb2 <argint>
  acquire(&tickslock);
    800031d0:	00015517          	auipc	a0,0x15
    800031d4:	4b050513          	addi	a0,a0,1200 # 80018680 <tickslock>
    800031d8:	ffffe097          	auipc	ra,0xffffe
    800031dc:	a12080e7          	jalr	-1518(ra) # 80000bea <acquire>
  ticks0 = ticks;
    800031e0:	00006917          	auipc	s2,0x6
    800031e4:	a0092903          	lw	s2,-1536(s2) # 80008be0 <ticks>
  while (ticks - ticks0 < n)
    800031e8:	fcc42783          	lw	a5,-52(s0)
    800031ec:	cf9d                	beqz	a5,8000322a <sys_sleep+0x76>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800031ee:	00015997          	auipc	s3,0x15
    800031f2:	49298993          	addi	s3,s3,1170 # 80018680 <tickslock>
    800031f6:	00006497          	auipc	s1,0x6
    800031fa:	9ea48493          	addi	s1,s1,-1558 # 80008be0 <ticks>
    if (killed(myproc()))
    800031fe:	fffff097          	auipc	ra,0xfffff
    80003202:	8d2080e7          	jalr	-1838(ra) # 80001ad0 <myproc>
    80003206:	fffff097          	auipc	ra,0xfffff
    8000320a:	4be080e7          	jalr	1214(ra) # 800026c4 <killed>
    8000320e:	ed15                	bnez	a0,8000324a <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80003210:	85ce                	mv	a1,s3
    80003212:	8526                	mv	a0,s1
    80003214:	fffff097          	auipc	ra,0xfffff
    80003218:	02c080e7          	jalr	44(ra) # 80002240 <sleep>
  while (ticks - ticks0 < n)
    8000321c:	409c                	lw	a5,0(s1)
    8000321e:	412787bb          	subw	a5,a5,s2
    80003222:	fcc42703          	lw	a4,-52(s0)
    80003226:	fce7ece3          	bltu	a5,a4,800031fe <sys_sleep+0x4a>
  }
  release(&tickslock);
    8000322a:	00015517          	auipc	a0,0x15
    8000322e:	45650513          	addi	a0,a0,1110 # 80018680 <tickslock>
    80003232:	ffffe097          	auipc	ra,0xffffe
    80003236:	a6c080e7          	jalr	-1428(ra) # 80000c9e <release>
  return 0;
    8000323a:	4501                	li	a0,0
}
    8000323c:	70e2                	ld	ra,56(sp)
    8000323e:	7442                	ld	s0,48(sp)
    80003240:	74a2                	ld	s1,40(sp)
    80003242:	7902                	ld	s2,32(sp)
    80003244:	69e2                	ld	s3,24(sp)
    80003246:	6121                	addi	sp,sp,64
    80003248:	8082                	ret
      release(&tickslock);
    8000324a:	00015517          	auipc	a0,0x15
    8000324e:	43650513          	addi	a0,a0,1078 # 80018680 <tickslock>
    80003252:	ffffe097          	auipc	ra,0xffffe
    80003256:	a4c080e7          	jalr	-1460(ra) # 80000c9e <release>
      return -1;
    8000325a:	557d                	li	a0,-1
    8000325c:	b7c5                	j	8000323c <sys_sleep+0x88>

000000008000325e <sys_kill>:

uint64
sys_kill(void)
{
    8000325e:	1101                	addi	sp,sp,-32
    80003260:	ec06                	sd	ra,24(sp)
    80003262:	e822                	sd	s0,16(sp)
    80003264:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80003266:	fec40593          	addi	a1,s0,-20
    8000326a:	4501                	li	a0,0
    8000326c:	00000097          	auipc	ra,0x0
    80003270:	c46080e7          	jalr	-954(ra) # 80002eb2 <argint>
  return kill(pid);
    80003274:	fec42503          	lw	a0,-20(s0)
    80003278:	fffff097          	auipc	ra,0xfffff
    8000327c:	38a080e7          	jalr	906(ra) # 80002602 <kill>
}
    80003280:	60e2                	ld	ra,24(sp)
    80003282:	6442                	ld	s0,16(sp)
    80003284:	6105                	addi	sp,sp,32
    80003286:	8082                	ret

0000000080003288 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003288:	1101                	addi	sp,sp,-32
    8000328a:	ec06                	sd	ra,24(sp)
    8000328c:	e822                	sd	s0,16(sp)
    8000328e:	e426                	sd	s1,8(sp)
    80003290:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003292:	00015517          	auipc	a0,0x15
    80003296:	3ee50513          	addi	a0,a0,1006 # 80018680 <tickslock>
    8000329a:	ffffe097          	auipc	ra,0xffffe
    8000329e:	950080e7          	jalr	-1712(ra) # 80000bea <acquire>
  xticks = ticks;
    800032a2:	00006497          	auipc	s1,0x6
    800032a6:	93e4a483          	lw	s1,-1730(s1) # 80008be0 <ticks>
  release(&tickslock);
    800032aa:	00015517          	auipc	a0,0x15
    800032ae:	3d650513          	addi	a0,a0,982 # 80018680 <tickslock>
    800032b2:	ffffe097          	auipc	ra,0xffffe
    800032b6:	9ec080e7          	jalr	-1556(ra) # 80000c9e <release>
  return xticks;
}
    800032ba:	02049513          	slli	a0,s1,0x20
    800032be:	9101                	srli	a0,a0,0x20
    800032c0:	60e2                	ld	ra,24(sp)
    800032c2:	6442                	ld	s0,16(sp)
    800032c4:	64a2                	ld	s1,8(sp)
    800032c6:	6105                	addi	sp,sp,32
    800032c8:	8082                	ret

00000000800032ca <sys_trace>:

uint64
sys_trace(void)
{
    800032ca:	1101                	addi	sp,sp,-32
    800032cc:	ec06                	sd	ra,24(sp)
    800032ce:	e822                	sd	s0,16(sp)
    800032d0:	1000                	addi	s0,sp,32
  int n; // mask
  argint(0, &n);
    800032d2:	fec40593          	addi	a1,s0,-20
    800032d6:	4501                	li	a0,0
    800032d8:	00000097          	auipc	ra,0x0
    800032dc:	bda080e7          	jalr	-1062(ra) # 80002eb2 <argint>
  myproc()->mask = n;
    800032e0:	ffffe097          	auipc	ra,0xffffe
    800032e4:	7f0080e7          	jalr	2032(ra) # 80001ad0 <myproc>
    800032e8:	fec42783          	lw	a5,-20(s0)
    800032ec:	c11c                	sw	a5,0(a0)
  return 0;
}
    800032ee:	4501                	li	a0,0
    800032f0:	60e2                	ld	ra,24(sp)
    800032f2:	6442                	ld	s0,16(sp)
    800032f4:	6105                	addi	sp,sp,32
    800032f6:	8082                	ret

00000000800032f8 <sys_sigalarm>:

uint64
sys_sigalarm(void)
{
    800032f8:	1101                	addi	sp,sp,-32
    800032fa:	ec06                	sd	ra,24(sp)
    800032fc:	e822                	sd	s0,16(sp)
    800032fe:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80003300:	fec40593          	addi	a1,s0,-20
    80003304:	4501                	li	a0,0
    80003306:	00000097          	auipc	ra,0x0
    8000330a:	bac080e7          	jalr	-1108(ra) # 80002eb2 <argint>
  myproc()->ticks0 = 0;
    8000330e:	ffffe097          	auipc	ra,0xffffe
    80003312:	7c2080e7          	jalr	1986(ra) # 80001ad0 <myproc>
    80003316:	00052223          	sw	zero,4(a0)
  return 0;
}
    8000331a:	4501                	li	a0,0
    8000331c:	60e2                	ld	ra,24(sp)
    8000331e:	6442                	ld	s0,16(sp)
    80003320:	6105                	addi	sp,sp,32
    80003322:	8082                	ret

0000000080003324 <sys_setpriority>:

uint64
sys_setpriority(void)
{
    80003324:	1101                	addi	sp,sp,-32
    80003326:	ec06                	sd	ra,24(sp)
    80003328:	e822                	sd	s0,16(sp)
    8000332a:	1000                	addi	s0,sp,32
  int priority;
  int pid;
  argint(0, &priority);
    8000332c:	fec40593          	addi	a1,s0,-20
    80003330:	4501                	li	a0,0
    80003332:	00000097          	auipc	ra,0x0
    80003336:	b80080e7          	jalr	-1152(ra) # 80002eb2 <argint>
  argint(1, &pid);
    8000333a:	fe840593          	addi	a1,s0,-24
    8000333e:	4505                	li	a0,1
    80003340:	00000097          	auipc	ra,0x0
    80003344:	b72080e7          	jalr	-1166(ra) # 80002eb2 <argint>
  return set_priority(priority, pid);
    80003348:	fe842583          	lw	a1,-24(s0)
    8000334c:	fec42503          	lw	a0,-20(s0)
    80003350:	ffffe097          	auipc	ra,0xffffe
    80003354:	54e080e7          	jalr	1358(ra) # 8000189e <set_priority>
}
    80003358:	60e2                	ld	ra,24(sp)
    8000335a:	6442                	ld	s0,16(sp)
    8000335c:	6105                	addi	sp,sp,32
    8000335e:	8082                	ret

0000000080003360 <sys_settickets>:

uint64
sys_settickets(void){
    80003360:	1101                	addi	sp,sp,-32
    80003362:	ec06                	sd	ra,24(sp)
    80003364:	e822                	sd	s0,16(sp)
    80003366:	1000                	addi	s0,sp,32
  int n; // tickets
  argint(0, &n);
    80003368:	fec40593          	addi	a1,s0,-20
    8000336c:	4501                	li	a0,0
    8000336e:	00000097          	auipc	ra,0x0
    80003372:	b44080e7          	jalr	-1212(ra) # 80002eb2 <argint>
  myproc()->tickets = n;
    80003376:	ffffe097          	auipc	ra,0xffffe
    8000337a:	75a080e7          	jalr	1882(ra) # 80001ad0 <myproc>
    8000337e:	fec42783          	lw	a5,-20(s0)
    80003382:	16f52823          	sw	a5,368(a0)
  return 0;
}
    80003386:	4501                	li	a0,0
    80003388:	60e2                	ld	ra,24(sp)
    8000338a:	6442                	ld	s0,16(sp)
    8000338c:	6105                	addi	sp,sp,32
    8000338e:	8082                	ret

0000000080003390 <sys_waitx>:

uint64
sys_waitx(void)
{
    80003390:	7139                	addi	sp,sp,-64
    80003392:	fc06                	sd	ra,56(sp)
    80003394:	f822                	sd	s0,48(sp)
    80003396:	f426                	sd	s1,40(sp)
    80003398:	f04a                	sd	s2,32(sp)
    8000339a:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    8000339c:	fd840593          	addi	a1,s0,-40
    800033a0:	4501                	li	a0,0
    800033a2:	00000097          	auipc	ra,0x0
    800033a6:	b30080e7          	jalr	-1232(ra) # 80002ed2 <argaddr>
  argaddr(1, &addr1); // user virtual memory
    800033aa:	fd040593          	addi	a1,s0,-48
    800033ae:	4505                	li	a0,1
    800033b0:	00000097          	auipc	ra,0x0
    800033b4:	b22080e7          	jalr	-1246(ra) # 80002ed2 <argaddr>
  argaddr(2, &addr2);
    800033b8:	fc840593          	addi	a1,s0,-56
    800033bc:	4509                	li	a0,2
    800033be:	00000097          	auipc	ra,0x0
    800033c2:	b14080e7          	jalr	-1260(ra) # 80002ed2 <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    800033c6:	fc040613          	addi	a2,s0,-64
    800033ca:	fc440593          	addi	a1,s0,-60
    800033ce:	fd843503          	ld	a0,-40(s0)
    800033d2:	fffff097          	auipc	ra,0xfffff
    800033d6:	edc080e7          	jalr	-292(ra) # 800022ae <waitx>
    800033da:	892a                	mv	s2,a0
  struct proc* p = myproc();
    800033dc:	ffffe097          	auipc	ra,0xffffe
    800033e0:	6f4080e7          	jalr	1780(ra) # 80001ad0 <myproc>
    800033e4:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    800033e6:	4691                	li	a3,4
    800033e8:	fc440613          	addi	a2,s0,-60
    800033ec:	fd043583          	ld	a1,-48(s0)
    800033f0:	6d28                	ld	a0,88(a0)
    800033f2:	ffffe097          	auipc	ra,0xffffe
    800033f6:	292080e7          	jalr	658(ra) # 80001684 <copyout>
    return -1;
    800033fa:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    800033fc:	00054f63          	bltz	a0,8000341a <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2,(char*)&rtime, sizeof(int)) < 0)
    80003400:	4691                	li	a3,4
    80003402:	fc040613          	addi	a2,s0,-64
    80003406:	fc843583          	ld	a1,-56(s0)
    8000340a:	6ca8                	ld	a0,88(s1)
    8000340c:	ffffe097          	auipc	ra,0xffffe
    80003410:	278080e7          	jalr	632(ra) # 80001684 <copyout>
    80003414:	00054a63          	bltz	a0,80003428 <sys_waitx+0x98>
    return -1;
  return ret;
    80003418:	87ca                	mv	a5,s2
    8000341a:	853e                	mv	a0,a5
    8000341c:	70e2                	ld	ra,56(sp)
    8000341e:	7442                	ld	s0,48(sp)
    80003420:	74a2                	ld	s1,40(sp)
    80003422:	7902                	ld	s2,32(sp)
    80003424:	6121                	addi	sp,sp,64
    80003426:	8082                	ret
    return -1;
    80003428:	57fd                	li	a5,-1
    8000342a:	bfc5                	j	8000341a <sys_waitx+0x8a>

000000008000342c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000342c:	7179                	addi	sp,sp,-48
    8000342e:	f406                	sd	ra,40(sp)
    80003430:	f022                	sd	s0,32(sp)
    80003432:	ec26                	sd	s1,24(sp)
    80003434:	e84a                	sd	s2,16(sp)
    80003436:	e44e                	sd	s3,8(sp)
    80003438:	e052                	sd	s4,0(sp)
    8000343a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000343c:	00005597          	auipc	a1,0x5
    80003440:	22458593          	addi	a1,a1,548 # 80008660 <syscalls+0xd8>
    80003444:	00015517          	auipc	a0,0x15
    80003448:	25450513          	addi	a0,a0,596 # 80018698 <bcache>
    8000344c:	ffffd097          	auipc	ra,0xffffd
    80003450:	70e080e7          	jalr	1806(ra) # 80000b5a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003454:	0001d797          	auipc	a5,0x1d
    80003458:	24478793          	addi	a5,a5,580 # 80020698 <bcache+0x8000>
    8000345c:	0001d717          	auipc	a4,0x1d
    80003460:	4a470713          	addi	a4,a4,1188 # 80020900 <bcache+0x8268>
    80003464:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003468:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000346c:	00015497          	auipc	s1,0x15
    80003470:	24448493          	addi	s1,s1,580 # 800186b0 <bcache+0x18>
    b->next = bcache.head.next;
    80003474:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003476:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003478:	00005a17          	auipc	s4,0x5
    8000347c:	1f0a0a13          	addi	s4,s4,496 # 80008668 <syscalls+0xe0>
    b->next = bcache.head.next;
    80003480:	2b893783          	ld	a5,696(s2)
    80003484:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003486:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000348a:	85d2                	mv	a1,s4
    8000348c:	01048513          	addi	a0,s1,16
    80003490:	00001097          	auipc	ra,0x1
    80003494:	4c4080e7          	jalr	1220(ra) # 80004954 <initsleeplock>
    bcache.head.next->prev = b;
    80003498:	2b893783          	ld	a5,696(s2)
    8000349c:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000349e:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800034a2:	45848493          	addi	s1,s1,1112
    800034a6:	fd349de3          	bne	s1,s3,80003480 <binit+0x54>
  }
}
    800034aa:	70a2                	ld	ra,40(sp)
    800034ac:	7402                	ld	s0,32(sp)
    800034ae:	64e2                	ld	s1,24(sp)
    800034b0:	6942                	ld	s2,16(sp)
    800034b2:	69a2                	ld	s3,8(sp)
    800034b4:	6a02                	ld	s4,0(sp)
    800034b6:	6145                	addi	sp,sp,48
    800034b8:	8082                	ret

00000000800034ba <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800034ba:	7179                	addi	sp,sp,-48
    800034bc:	f406                	sd	ra,40(sp)
    800034be:	f022                	sd	s0,32(sp)
    800034c0:	ec26                	sd	s1,24(sp)
    800034c2:	e84a                	sd	s2,16(sp)
    800034c4:	e44e                	sd	s3,8(sp)
    800034c6:	1800                	addi	s0,sp,48
    800034c8:	89aa                	mv	s3,a0
    800034ca:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    800034cc:	00015517          	auipc	a0,0x15
    800034d0:	1cc50513          	addi	a0,a0,460 # 80018698 <bcache>
    800034d4:	ffffd097          	auipc	ra,0xffffd
    800034d8:	716080e7          	jalr	1814(ra) # 80000bea <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800034dc:	0001d497          	auipc	s1,0x1d
    800034e0:	4744b483          	ld	s1,1140(s1) # 80020950 <bcache+0x82b8>
    800034e4:	0001d797          	auipc	a5,0x1d
    800034e8:	41c78793          	addi	a5,a5,1052 # 80020900 <bcache+0x8268>
    800034ec:	02f48f63          	beq	s1,a5,8000352a <bread+0x70>
    800034f0:	873e                	mv	a4,a5
    800034f2:	a021                	j	800034fa <bread+0x40>
    800034f4:	68a4                	ld	s1,80(s1)
    800034f6:	02e48a63          	beq	s1,a4,8000352a <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800034fa:	449c                	lw	a5,8(s1)
    800034fc:	ff379ce3          	bne	a5,s3,800034f4 <bread+0x3a>
    80003500:	44dc                	lw	a5,12(s1)
    80003502:	ff2799e3          	bne	a5,s2,800034f4 <bread+0x3a>
      b->refcnt++;
    80003506:	40bc                	lw	a5,64(s1)
    80003508:	2785                	addiw	a5,a5,1
    8000350a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000350c:	00015517          	auipc	a0,0x15
    80003510:	18c50513          	addi	a0,a0,396 # 80018698 <bcache>
    80003514:	ffffd097          	auipc	ra,0xffffd
    80003518:	78a080e7          	jalr	1930(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    8000351c:	01048513          	addi	a0,s1,16
    80003520:	00001097          	auipc	ra,0x1
    80003524:	46e080e7          	jalr	1134(ra) # 8000498e <acquiresleep>
      return b;
    80003528:	a8b9                	j	80003586 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000352a:	0001d497          	auipc	s1,0x1d
    8000352e:	41e4b483          	ld	s1,1054(s1) # 80020948 <bcache+0x82b0>
    80003532:	0001d797          	auipc	a5,0x1d
    80003536:	3ce78793          	addi	a5,a5,974 # 80020900 <bcache+0x8268>
    8000353a:	00f48863          	beq	s1,a5,8000354a <bread+0x90>
    8000353e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003540:	40bc                	lw	a5,64(s1)
    80003542:	cf81                	beqz	a5,8000355a <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003544:	64a4                	ld	s1,72(s1)
    80003546:	fee49de3          	bne	s1,a4,80003540 <bread+0x86>
  panic("bget: no buffers");
    8000354a:	00005517          	auipc	a0,0x5
    8000354e:	12650513          	addi	a0,a0,294 # 80008670 <syscalls+0xe8>
    80003552:	ffffd097          	auipc	ra,0xffffd
    80003556:	ff2080e7          	jalr	-14(ra) # 80000544 <panic>
      b->dev = dev;
    8000355a:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    8000355e:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80003562:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003566:	4785                	li	a5,1
    80003568:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000356a:	00015517          	auipc	a0,0x15
    8000356e:	12e50513          	addi	a0,a0,302 # 80018698 <bcache>
    80003572:	ffffd097          	auipc	ra,0xffffd
    80003576:	72c080e7          	jalr	1836(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    8000357a:	01048513          	addi	a0,s1,16
    8000357e:	00001097          	auipc	ra,0x1
    80003582:	410080e7          	jalr	1040(ra) # 8000498e <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003586:	409c                	lw	a5,0(s1)
    80003588:	cb89                	beqz	a5,8000359a <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000358a:	8526                	mv	a0,s1
    8000358c:	70a2                	ld	ra,40(sp)
    8000358e:	7402                	ld	s0,32(sp)
    80003590:	64e2                	ld	s1,24(sp)
    80003592:	6942                	ld	s2,16(sp)
    80003594:	69a2                	ld	s3,8(sp)
    80003596:	6145                	addi	sp,sp,48
    80003598:	8082                	ret
    virtio_disk_rw(b, 0);
    8000359a:	4581                	li	a1,0
    8000359c:	8526                	mv	a0,s1
    8000359e:	00003097          	auipc	ra,0x3
    800035a2:	fca080e7          	jalr	-54(ra) # 80006568 <virtio_disk_rw>
    b->valid = 1;
    800035a6:	4785                	li	a5,1
    800035a8:	c09c                	sw	a5,0(s1)
  return b;
    800035aa:	b7c5                	j	8000358a <bread+0xd0>

00000000800035ac <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800035ac:	1101                	addi	sp,sp,-32
    800035ae:	ec06                	sd	ra,24(sp)
    800035b0:	e822                	sd	s0,16(sp)
    800035b2:	e426                	sd	s1,8(sp)
    800035b4:	1000                	addi	s0,sp,32
    800035b6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800035b8:	0541                	addi	a0,a0,16
    800035ba:	00001097          	auipc	ra,0x1
    800035be:	46e080e7          	jalr	1134(ra) # 80004a28 <holdingsleep>
    800035c2:	cd01                	beqz	a0,800035da <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800035c4:	4585                	li	a1,1
    800035c6:	8526                	mv	a0,s1
    800035c8:	00003097          	auipc	ra,0x3
    800035cc:	fa0080e7          	jalr	-96(ra) # 80006568 <virtio_disk_rw>
}
    800035d0:	60e2                	ld	ra,24(sp)
    800035d2:	6442                	ld	s0,16(sp)
    800035d4:	64a2                	ld	s1,8(sp)
    800035d6:	6105                	addi	sp,sp,32
    800035d8:	8082                	ret
    panic("bwrite");
    800035da:	00005517          	auipc	a0,0x5
    800035de:	0ae50513          	addi	a0,a0,174 # 80008688 <syscalls+0x100>
    800035e2:	ffffd097          	auipc	ra,0xffffd
    800035e6:	f62080e7          	jalr	-158(ra) # 80000544 <panic>

00000000800035ea <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800035ea:	1101                	addi	sp,sp,-32
    800035ec:	ec06                	sd	ra,24(sp)
    800035ee:	e822                	sd	s0,16(sp)
    800035f0:	e426                	sd	s1,8(sp)
    800035f2:	e04a                	sd	s2,0(sp)
    800035f4:	1000                	addi	s0,sp,32
    800035f6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800035f8:	01050913          	addi	s2,a0,16
    800035fc:	854a                	mv	a0,s2
    800035fe:	00001097          	auipc	ra,0x1
    80003602:	42a080e7          	jalr	1066(ra) # 80004a28 <holdingsleep>
    80003606:	c92d                	beqz	a0,80003678 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003608:	854a                	mv	a0,s2
    8000360a:	00001097          	auipc	ra,0x1
    8000360e:	3da080e7          	jalr	986(ra) # 800049e4 <releasesleep>

  acquire(&bcache.lock);
    80003612:	00015517          	auipc	a0,0x15
    80003616:	08650513          	addi	a0,a0,134 # 80018698 <bcache>
    8000361a:	ffffd097          	auipc	ra,0xffffd
    8000361e:	5d0080e7          	jalr	1488(ra) # 80000bea <acquire>
  b->refcnt--;
    80003622:	40bc                	lw	a5,64(s1)
    80003624:	37fd                	addiw	a5,a5,-1
    80003626:	0007871b          	sext.w	a4,a5
    8000362a:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000362c:	eb05                	bnez	a4,8000365c <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000362e:	68bc                	ld	a5,80(s1)
    80003630:	64b8                	ld	a4,72(s1)
    80003632:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003634:	64bc                	ld	a5,72(s1)
    80003636:	68b8                	ld	a4,80(s1)
    80003638:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000363a:	0001d797          	auipc	a5,0x1d
    8000363e:	05e78793          	addi	a5,a5,94 # 80020698 <bcache+0x8000>
    80003642:	2b87b703          	ld	a4,696(a5)
    80003646:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003648:	0001d717          	auipc	a4,0x1d
    8000364c:	2b870713          	addi	a4,a4,696 # 80020900 <bcache+0x8268>
    80003650:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003652:	2b87b703          	ld	a4,696(a5)
    80003656:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003658:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000365c:	00015517          	auipc	a0,0x15
    80003660:	03c50513          	addi	a0,a0,60 # 80018698 <bcache>
    80003664:	ffffd097          	auipc	ra,0xffffd
    80003668:	63a080e7          	jalr	1594(ra) # 80000c9e <release>
}
    8000366c:	60e2                	ld	ra,24(sp)
    8000366e:	6442                	ld	s0,16(sp)
    80003670:	64a2                	ld	s1,8(sp)
    80003672:	6902                	ld	s2,0(sp)
    80003674:	6105                	addi	sp,sp,32
    80003676:	8082                	ret
    panic("brelse");
    80003678:	00005517          	auipc	a0,0x5
    8000367c:	01850513          	addi	a0,a0,24 # 80008690 <syscalls+0x108>
    80003680:	ffffd097          	auipc	ra,0xffffd
    80003684:	ec4080e7          	jalr	-316(ra) # 80000544 <panic>

0000000080003688 <bpin>:

void
bpin(struct buf *b) {
    80003688:	1101                	addi	sp,sp,-32
    8000368a:	ec06                	sd	ra,24(sp)
    8000368c:	e822                	sd	s0,16(sp)
    8000368e:	e426                	sd	s1,8(sp)
    80003690:	1000                	addi	s0,sp,32
    80003692:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003694:	00015517          	auipc	a0,0x15
    80003698:	00450513          	addi	a0,a0,4 # 80018698 <bcache>
    8000369c:	ffffd097          	auipc	ra,0xffffd
    800036a0:	54e080e7          	jalr	1358(ra) # 80000bea <acquire>
  b->refcnt++;
    800036a4:	40bc                	lw	a5,64(s1)
    800036a6:	2785                	addiw	a5,a5,1
    800036a8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800036aa:	00015517          	auipc	a0,0x15
    800036ae:	fee50513          	addi	a0,a0,-18 # 80018698 <bcache>
    800036b2:	ffffd097          	auipc	ra,0xffffd
    800036b6:	5ec080e7          	jalr	1516(ra) # 80000c9e <release>
}
    800036ba:	60e2                	ld	ra,24(sp)
    800036bc:	6442                	ld	s0,16(sp)
    800036be:	64a2                	ld	s1,8(sp)
    800036c0:	6105                	addi	sp,sp,32
    800036c2:	8082                	ret

00000000800036c4 <bunpin>:

void
bunpin(struct buf *b) {
    800036c4:	1101                	addi	sp,sp,-32
    800036c6:	ec06                	sd	ra,24(sp)
    800036c8:	e822                	sd	s0,16(sp)
    800036ca:	e426                	sd	s1,8(sp)
    800036cc:	1000                	addi	s0,sp,32
    800036ce:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800036d0:	00015517          	auipc	a0,0x15
    800036d4:	fc850513          	addi	a0,a0,-56 # 80018698 <bcache>
    800036d8:	ffffd097          	auipc	ra,0xffffd
    800036dc:	512080e7          	jalr	1298(ra) # 80000bea <acquire>
  b->refcnt--;
    800036e0:	40bc                	lw	a5,64(s1)
    800036e2:	37fd                	addiw	a5,a5,-1
    800036e4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800036e6:	00015517          	auipc	a0,0x15
    800036ea:	fb250513          	addi	a0,a0,-78 # 80018698 <bcache>
    800036ee:	ffffd097          	auipc	ra,0xffffd
    800036f2:	5b0080e7          	jalr	1456(ra) # 80000c9e <release>
}
    800036f6:	60e2                	ld	ra,24(sp)
    800036f8:	6442                	ld	s0,16(sp)
    800036fa:	64a2                	ld	s1,8(sp)
    800036fc:	6105                	addi	sp,sp,32
    800036fe:	8082                	ret

0000000080003700 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003700:	1101                	addi	sp,sp,-32
    80003702:	ec06                	sd	ra,24(sp)
    80003704:	e822                	sd	s0,16(sp)
    80003706:	e426                	sd	s1,8(sp)
    80003708:	e04a                	sd	s2,0(sp)
    8000370a:	1000                	addi	s0,sp,32
    8000370c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000370e:	00d5d59b          	srliw	a1,a1,0xd
    80003712:	0001d797          	auipc	a5,0x1d
    80003716:	6627a783          	lw	a5,1634(a5) # 80020d74 <sb+0x1c>
    8000371a:	9dbd                	addw	a1,a1,a5
    8000371c:	00000097          	auipc	ra,0x0
    80003720:	d9e080e7          	jalr	-610(ra) # 800034ba <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003724:	0074f713          	andi	a4,s1,7
    80003728:	4785                	li	a5,1
    8000372a:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000372e:	14ce                	slli	s1,s1,0x33
    80003730:	90d9                	srli	s1,s1,0x36
    80003732:	00950733          	add	a4,a0,s1
    80003736:	05874703          	lbu	a4,88(a4)
    8000373a:	00e7f6b3          	and	a3,a5,a4
    8000373e:	c69d                	beqz	a3,8000376c <bfree+0x6c>
    80003740:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003742:	94aa                	add	s1,s1,a0
    80003744:	fff7c793          	not	a5,a5
    80003748:	8ff9                	and	a5,a5,a4
    8000374a:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    8000374e:	00001097          	auipc	ra,0x1
    80003752:	120080e7          	jalr	288(ra) # 8000486e <log_write>
  brelse(bp);
    80003756:	854a                	mv	a0,s2
    80003758:	00000097          	auipc	ra,0x0
    8000375c:	e92080e7          	jalr	-366(ra) # 800035ea <brelse>
}
    80003760:	60e2                	ld	ra,24(sp)
    80003762:	6442                	ld	s0,16(sp)
    80003764:	64a2                	ld	s1,8(sp)
    80003766:	6902                	ld	s2,0(sp)
    80003768:	6105                	addi	sp,sp,32
    8000376a:	8082                	ret
    panic("freeing free block");
    8000376c:	00005517          	auipc	a0,0x5
    80003770:	f2c50513          	addi	a0,a0,-212 # 80008698 <syscalls+0x110>
    80003774:	ffffd097          	auipc	ra,0xffffd
    80003778:	dd0080e7          	jalr	-560(ra) # 80000544 <panic>

000000008000377c <balloc>:
{
    8000377c:	711d                	addi	sp,sp,-96
    8000377e:	ec86                	sd	ra,88(sp)
    80003780:	e8a2                	sd	s0,80(sp)
    80003782:	e4a6                	sd	s1,72(sp)
    80003784:	e0ca                	sd	s2,64(sp)
    80003786:	fc4e                	sd	s3,56(sp)
    80003788:	f852                	sd	s4,48(sp)
    8000378a:	f456                	sd	s5,40(sp)
    8000378c:	f05a                	sd	s6,32(sp)
    8000378e:	ec5e                	sd	s7,24(sp)
    80003790:	e862                	sd	s8,16(sp)
    80003792:	e466                	sd	s9,8(sp)
    80003794:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003796:	0001d797          	auipc	a5,0x1d
    8000379a:	5c67a783          	lw	a5,1478(a5) # 80020d5c <sb+0x4>
    8000379e:	10078163          	beqz	a5,800038a0 <balloc+0x124>
    800037a2:	8baa                	mv	s7,a0
    800037a4:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800037a6:	0001db17          	auipc	s6,0x1d
    800037aa:	5b2b0b13          	addi	s6,s6,1458 # 80020d58 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037ae:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800037b0:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037b2:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800037b4:	6c89                	lui	s9,0x2
    800037b6:	a061                	j	8000383e <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    800037b8:	974a                	add	a4,a4,s2
    800037ba:	8fd5                	or	a5,a5,a3
    800037bc:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800037c0:	854a                	mv	a0,s2
    800037c2:	00001097          	auipc	ra,0x1
    800037c6:	0ac080e7          	jalr	172(ra) # 8000486e <log_write>
        brelse(bp);
    800037ca:	854a                	mv	a0,s2
    800037cc:	00000097          	auipc	ra,0x0
    800037d0:	e1e080e7          	jalr	-482(ra) # 800035ea <brelse>
  bp = bread(dev, bno);
    800037d4:	85a6                	mv	a1,s1
    800037d6:	855e                	mv	a0,s7
    800037d8:	00000097          	auipc	ra,0x0
    800037dc:	ce2080e7          	jalr	-798(ra) # 800034ba <bread>
    800037e0:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800037e2:	40000613          	li	a2,1024
    800037e6:	4581                	li	a1,0
    800037e8:	05850513          	addi	a0,a0,88
    800037ec:	ffffd097          	auipc	ra,0xffffd
    800037f0:	4fa080e7          	jalr	1274(ra) # 80000ce6 <memset>
  log_write(bp);
    800037f4:	854a                	mv	a0,s2
    800037f6:	00001097          	auipc	ra,0x1
    800037fa:	078080e7          	jalr	120(ra) # 8000486e <log_write>
  brelse(bp);
    800037fe:	854a                	mv	a0,s2
    80003800:	00000097          	auipc	ra,0x0
    80003804:	dea080e7          	jalr	-534(ra) # 800035ea <brelse>
}
    80003808:	8526                	mv	a0,s1
    8000380a:	60e6                	ld	ra,88(sp)
    8000380c:	6446                	ld	s0,80(sp)
    8000380e:	64a6                	ld	s1,72(sp)
    80003810:	6906                	ld	s2,64(sp)
    80003812:	79e2                	ld	s3,56(sp)
    80003814:	7a42                	ld	s4,48(sp)
    80003816:	7aa2                	ld	s5,40(sp)
    80003818:	7b02                	ld	s6,32(sp)
    8000381a:	6be2                	ld	s7,24(sp)
    8000381c:	6c42                	ld	s8,16(sp)
    8000381e:	6ca2                	ld	s9,8(sp)
    80003820:	6125                	addi	sp,sp,96
    80003822:	8082                	ret
    brelse(bp);
    80003824:	854a                	mv	a0,s2
    80003826:	00000097          	auipc	ra,0x0
    8000382a:	dc4080e7          	jalr	-572(ra) # 800035ea <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000382e:	015c87bb          	addw	a5,s9,s5
    80003832:	00078a9b          	sext.w	s5,a5
    80003836:	004b2703          	lw	a4,4(s6)
    8000383a:	06eaf363          	bgeu	s5,a4,800038a0 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    8000383e:	41fad79b          	sraiw	a5,s5,0x1f
    80003842:	0137d79b          	srliw	a5,a5,0x13
    80003846:	015787bb          	addw	a5,a5,s5
    8000384a:	40d7d79b          	sraiw	a5,a5,0xd
    8000384e:	01cb2583          	lw	a1,28(s6)
    80003852:	9dbd                	addw	a1,a1,a5
    80003854:	855e                	mv	a0,s7
    80003856:	00000097          	auipc	ra,0x0
    8000385a:	c64080e7          	jalr	-924(ra) # 800034ba <bread>
    8000385e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003860:	004b2503          	lw	a0,4(s6)
    80003864:	000a849b          	sext.w	s1,s5
    80003868:	8662                	mv	a2,s8
    8000386a:	faa4fde3          	bgeu	s1,a0,80003824 <balloc+0xa8>
      m = 1 << (bi % 8);
    8000386e:	41f6579b          	sraiw	a5,a2,0x1f
    80003872:	01d7d69b          	srliw	a3,a5,0x1d
    80003876:	00c6873b          	addw	a4,a3,a2
    8000387a:	00777793          	andi	a5,a4,7
    8000387e:	9f95                	subw	a5,a5,a3
    80003880:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003884:	4037571b          	sraiw	a4,a4,0x3
    80003888:	00e906b3          	add	a3,s2,a4
    8000388c:	0586c683          	lbu	a3,88(a3)
    80003890:	00d7f5b3          	and	a1,a5,a3
    80003894:	d195                	beqz	a1,800037b8 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003896:	2605                	addiw	a2,a2,1
    80003898:	2485                	addiw	s1,s1,1
    8000389a:	fd4618e3          	bne	a2,s4,8000386a <balloc+0xee>
    8000389e:	b759                	j	80003824 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    800038a0:	00005517          	auipc	a0,0x5
    800038a4:	e1050513          	addi	a0,a0,-496 # 800086b0 <syscalls+0x128>
    800038a8:	ffffd097          	auipc	ra,0xffffd
    800038ac:	ce6080e7          	jalr	-794(ra) # 8000058e <printf>
  return 0;
    800038b0:	4481                	li	s1,0
    800038b2:	bf99                	j	80003808 <balloc+0x8c>

00000000800038b4 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800038b4:	7179                	addi	sp,sp,-48
    800038b6:	f406                	sd	ra,40(sp)
    800038b8:	f022                	sd	s0,32(sp)
    800038ba:	ec26                	sd	s1,24(sp)
    800038bc:	e84a                	sd	s2,16(sp)
    800038be:	e44e                	sd	s3,8(sp)
    800038c0:	e052                	sd	s4,0(sp)
    800038c2:	1800                	addi	s0,sp,48
    800038c4:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800038c6:	47ad                	li	a5,11
    800038c8:	02b7e763          	bltu	a5,a1,800038f6 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    800038cc:	02059493          	slli	s1,a1,0x20
    800038d0:	9081                	srli	s1,s1,0x20
    800038d2:	048a                	slli	s1,s1,0x2
    800038d4:	94aa                	add	s1,s1,a0
    800038d6:	0504a903          	lw	s2,80(s1)
    800038da:	06091e63          	bnez	s2,80003956 <bmap+0xa2>
      addr = balloc(ip->dev);
    800038de:	4108                	lw	a0,0(a0)
    800038e0:	00000097          	auipc	ra,0x0
    800038e4:	e9c080e7          	jalr	-356(ra) # 8000377c <balloc>
    800038e8:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800038ec:	06090563          	beqz	s2,80003956 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    800038f0:	0524a823          	sw	s2,80(s1)
    800038f4:	a08d                	j	80003956 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    800038f6:	ff45849b          	addiw	s1,a1,-12
    800038fa:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800038fe:	0ff00793          	li	a5,255
    80003902:	08e7e563          	bltu	a5,a4,8000398c <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003906:	08052903          	lw	s2,128(a0)
    8000390a:	00091d63          	bnez	s2,80003924 <bmap+0x70>
      addr = balloc(ip->dev);
    8000390e:	4108                	lw	a0,0(a0)
    80003910:	00000097          	auipc	ra,0x0
    80003914:	e6c080e7          	jalr	-404(ra) # 8000377c <balloc>
    80003918:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000391c:	02090d63          	beqz	s2,80003956 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003920:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003924:	85ca                	mv	a1,s2
    80003926:	0009a503          	lw	a0,0(s3)
    8000392a:	00000097          	auipc	ra,0x0
    8000392e:	b90080e7          	jalr	-1136(ra) # 800034ba <bread>
    80003932:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003934:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003938:	02049593          	slli	a1,s1,0x20
    8000393c:	9181                	srli	a1,a1,0x20
    8000393e:	058a                	slli	a1,a1,0x2
    80003940:	00b784b3          	add	s1,a5,a1
    80003944:	0004a903          	lw	s2,0(s1)
    80003948:	02090063          	beqz	s2,80003968 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000394c:	8552                	mv	a0,s4
    8000394e:	00000097          	auipc	ra,0x0
    80003952:	c9c080e7          	jalr	-868(ra) # 800035ea <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003956:	854a                	mv	a0,s2
    80003958:	70a2                	ld	ra,40(sp)
    8000395a:	7402                	ld	s0,32(sp)
    8000395c:	64e2                	ld	s1,24(sp)
    8000395e:	6942                	ld	s2,16(sp)
    80003960:	69a2                	ld	s3,8(sp)
    80003962:	6a02                	ld	s4,0(sp)
    80003964:	6145                	addi	sp,sp,48
    80003966:	8082                	ret
      addr = balloc(ip->dev);
    80003968:	0009a503          	lw	a0,0(s3)
    8000396c:	00000097          	auipc	ra,0x0
    80003970:	e10080e7          	jalr	-496(ra) # 8000377c <balloc>
    80003974:	0005091b          	sext.w	s2,a0
      if(addr){
    80003978:	fc090ae3          	beqz	s2,8000394c <bmap+0x98>
        a[bn] = addr;
    8000397c:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003980:	8552                	mv	a0,s4
    80003982:	00001097          	auipc	ra,0x1
    80003986:	eec080e7          	jalr	-276(ra) # 8000486e <log_write>
    8000398a:	b7c9                	j	8000394c <bmap+0x98>
  panic("bmap: out of range");
    8000398c:	00005517          	auipc	a0,0x5
    80003990:	d3c50513          	addi	a0,a0,-708 # 800086c8 <syscalls+0x140>
    80003994:	ffffd097          	auipc	ra,0xffffd
    80003998:	bb0080e7          	jalr	-1104(ra) # 80000544 <panic>

000000008000399c <iget>:
{
    8000399c:	7179                	addi	sp,sp,-48
    8000399e:	f406                	sd	ra,40(sp)
    800039a0:	f022                	sd	s0,32(sp)
    800039a2:	ec26                	sd	s1,24(sp)
    800039a4:	e84a                	sd	s2,16(sp)
    800039a6:	e44e                	sd	s3,8(sp)
    800039a8:	e052                	sd	s4,0(sp)
    800039aa:	1800                	addi	s0,sp,48
    800039ac:	89aa                	mv	s3,a0
    800039ae:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800039b0:	0001d517          	auipc	a0,0x1d
    800039b4:	3c850513          	addi	a0,a0,968 # 80020d78 <itable>
    800039b8:	ffffd097          	auipc	ra,0xffffd
    800039bc:	232080e7          	jalr	562(ra) # 80000bea <acquire>
  empty = 0;
    800039c0:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800039c2:	0001d497          	auipc	s1,0x1d
    800039c6:	3ce48493          	addi	s1,s1,974 # 80020d90 <itable+0x18>
    800039ca:	0001f697          	auipc	a3,0x1f
    800039ce:	e5668693          	addi	a3,a3,-426 # 80022820 <log>
    800039d2:	a039                	j	800039e0 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800039d4:	02090b63          	beqz	s2,80003a0a <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800039d8:	08848493          	addi	s1,s1,136
    800039dc:	02d48a63          	beq	s1,a3,80003a10 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800039e0:	449c                	lw	a5,8(s1)
    800039e2:	fef059e3          	blez	a5,800039d4 <iget+0x38>
    800039e6:	4098                	lw	a4,0(s1)
    800039e8:	ff3716e3          	bne	a4,s3,800039d4 <iget+0x38>
    800039ec:	40d8                	lw	a4,4(s1)
    800039ee:	ff4713e3          	bne	a4,s4,800039d4 <iget+0x38>
      ip->ref++;
    800039f2:	2785                	addiw	a5,a5,1
    800039f4:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800039f6:	0001d517          	auipc	a0,0x1d
    800039fa:	38250513          	addi	a0,a0,898 # 80020d78 <itable>
    800039fe:	ffffd097          	auipc	ra,0xffffd
    80003a02:	2a0080e7          	jalr	672(ra) # 80000c9e <release>
      return ip;
    80003a06:	8926                	mv	s2,s1
    80003a08:	a03d                	j	80003a36 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003a0a:	f7f9                	bnez	a5,800039d8 <iget+0x3c>
    80003a0c:	8926                	mv	s2,s1
    80003a0e:	b7e9                	j	800039d8 <iget+0x3c>
  if(empty == 0)
    80003a10:	02090c63          	beqz	s2,80003a48 <iget+0xac>
  ip->dev = dev;
    80003a14:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003a18:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003a1c:	4785                	li	a5,1
    80003a1e:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003a22:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003a26:	0001d517          	auipc	a0,0x1d
    80003a2a:	35250513          	addi	a0,a0,850 # 80020d78 <itable>
    80003a2e:	ffffd097          	auipc	ra,0xffffd
    80003a32:	270080e7          	jalr	624(ra) # 80000c9e <release>
}
    80003a36:	854a                	mv	a0,s2
    80003a38:	70a2                	ld	ra,40(sp)
    80003a3a:	7402                	ld	s0,32(sp)
    80003a3c:	64e2                	ld	s1,24(sp)
    80003a3e:	6942                	ld	s2,16(sp)
    80003a40:	69a2                	ld	s3,8(sp)
    80003a42:	6a02                	ld	s4,0(sp)
    80003a44:	6145                	addi	sp,sp,48
    80003a46:	8082                	ret
    panic("iget: no inodes");
    80003a48:	00005517          	auipc	a0,0x5
    80003a4c:	c9850513          	addi	a0,a0,-872 # 800086e0 <syscalls+0x158>
    80003a50:	ffffd097          	auipc	ra,0xffffd
    80003a54:	af4080e7          	jalr	-1292(ra) # 80000544 <panic>

0000000080003a58 <fsinit>:
fsinit(int dev) {
    80003a58:	7179                	addi	sp,sp,-48
    80003a5a:	f406                	sd	ra,40(sp)
    80003a5c:	f022                	sd	s0,32(sp)
    80003a5e:	ec26                	sd	s1,24(sp)
    80003a60:	e84a                	sd	s2,16(sp)
    80003a62:	e44e                	sd	s3,8(sp)
    80003a64:	1800                	addi	s0,sp,48
    80003a66:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003a68:	4585                	li	a1,1
    80003a6a:	00000097          	auipc	ra,0x0
    80003a6e:	a50080e7          	jalr	-1456(ra) # 800034ba <bread>
    80003a72:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003a74:	0001d997          	auipc	s3,0x1d
    80003a78:	2e498993          	addi	s3,s3,740 # 80020d58 <sb>
    80003a7c:	02000613          	li	a2,32
    80003a80:	05850593          	addi	a1,a0,88
    80003a84:	854e                	mv	a0,s3
    80003a86:	ffffd097          	auipc	ra,0xffffd
    80003a8a:	2c0080e7          	jalr	704(ra) # 80000d46 <memmove>
  brelse(bp);
    80003a8e:	8526                	mv	a0,s1
    80003a90:	00000097          	auipc	ra,0x0
    80003a94:	b5a080e7          	jalr	-1190(ra) # 800035ea <brelse>
  if(sb.magic != FSMAGIC)
    80003a98:	0009a703          	lw	a4,0(s3)
    80003a9c:	102037b7          	lui	a5,0x10203
    80003aa0:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003aa4:	02f71263          	bne	a4,a5,80003ac8 <fsinit+0x70>
  initlog(dev, &sb);
    80003aa8:	0001d597          	auipc	a1,0x1d
    80003aac:	2b058593          	addi	a1,a1,688 # 80020d58 <sb>
    80003ab0:	854a                	mv	a0,s2
    80003ab2:	00001097          	auipc	ra,0x1
    80003ab6:	b40080e7          	jalr	-1216(ra) # 800045f2 <initlog>
}
    80003aba:	70a2                	ld	ra,40(sp)
    80003abc:	7402                	ld	s0,32(sp)
    80003abe:	64e2                	ld	s1,24(sp)
    80003ac0:	6942                	ld	s2,16(sp)
    80003ac2:	69a2                	ld	s3,8(sp)
    80003ac4:	6145                	addi	sp,sp,48
    80003ac6:	8082                	ret
    panic("invalid file system");
    80003ac8:	00005517          	auipc	a0,0x5
    80003acc:	c2850513          	addi	a0,a0,-984 # 800086f0 <syscalls+0x168>
    80003ad0:	ffffd097          	auipc	ra,0xffffd
    80003ad4:	a74080e7          	jalr	-1420(ra) # 80000544 <panic>

0000000080003ad8 <iinit>:
{
    80003ad8:	7179                	addi	sp,sp,-48
    80003ada:	f406                	sd	ra,40(sp)
    80003adc:	f022                	sd	s0,32(sp)
    80003ade:	ec26                	sd	s1,24(sp)
    80003ae0:	e84a                	sd	s2,16(sp)
    80003ae2:	e44e                	sd	s3,8(sp)
    80003ae4:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003ae6:	00005597          	auipc	a1,0x5
    80003aea:	c2258593          	addi	a1,a1,-990 # 80008708 <syscalls+0x180>
    80003aee:	0001d517          	auipc	a0,0x1d
    80003af2:	28a50513          	addi	a0,a0,650 # 80020d78 <itable>
    80003af6:	ffffd097          	auipc	ra,0xffffd
    80003afa:	064080e7          	jalr	100(ra) # 80000b5a <initlock>
  for(i = 0; i < NINODE; i++) {
    80003afe:	0001d497          	auipc	s1,0x1d
    80003b02:	2a248493          	addi	s1,s1,674 # 80020da0 <itable+0x28>
    80003b06:	0001f997          	auipc	s3,0x1f
    80003b0a:	d2a98993          	addi	s3,s3,-726 # 80022830 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003b0e:	00005917          	auipc	s2,0x5
    80003b12:	c0290913          	addi	s2,s2,-1022 # 80008710 <syscalls+0x188>
    80003b16:	85ca                	mv	a1,s2
    80003b18:	8526                	mv	a0,s1
    80003b1a:	00001097          	auipc	ra,0x1
    80003b1e:	e3a080e7          	jalr	-454(ra) # 80004954 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003b22:	08848493          	addi	s1,s1,136
    80003b26:	ff3498e3          	bne	s1,s3,80003b16 <iinit+0x3e>
}
    80003b2a:	70a2                	ld	ra,40(sp)
    80003b2c:	7402                	ld	s0,32(sp)
    80003b2e:	64e2                	ld	s1,24(sp)
    80003b30:	6942                	ld	s2,16(sp)
    80003b32:	69a2                	ld	s3,8(sp)
    80003b34:	6145                	addi	sp,sp,48
    80003b36:	8082                	ret

0000000080003b38 <ialloc>:
{
    80003b38:	715d                	addi	sp,sp,-80
    80003b3a:	e486                	sd	ra,72(sp)
    80003b3c:	e0a2                	sd	s0,64(sp)
    80003b3e:	fc26                	sd	s1,56(sp)
    80003b40:	f84a                	sd	s2,48(sp)
    80003b42:	f44e                	sd	s3,40(sp)
    80003b44:	f052                	sd	s4,32(sp)
    80003b46:	ec56                	sd	s5,24(sp)
    80003b48:	e85a                	sd	s6,16(sp)
    80003b4a:	e45e                	sd	s7,8(sp)
    80003b4c:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b4e:	0001d717          	auipc	a4,0x1d
    80003b52:	21672703          	lw	a4,534(a4) # 80020d64 <sb+0xc>
    80003b56:	4785                	li	a5,1
    80003b58:	04e7fa63          	bgeu	a5,a4,80003bac <ialloc+0x74>
    80003b5c:	8aaa                	mv	s5,a0
    80003b5e:	8bae                	mv	s7,a1
    80003b60:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003b62:	0001da17          	auipc	s4,0x1d
    80003b66:	1f6a0a13          	addi	s4,s4,502 # 80020d58 <sb>
    80003b6a:	00048b1b          	sext.w	s6,s1
    80003b6e:	0044d593          	srli	a1,s1,0x4
    80003b72:	018a2783          	lw	a5,24(s4)
    80003b76:	9dbd                	addw	a1,a1,a5
    80003b78:	8556                	mv	a0,s5
    80003b7a:	00000097          	auipc	ra,0x0
    80003b7e:	940080e7          	jalr	-1728(ra) # 800034ba <bread>
    80003b82:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003b84:	05850993          	addi	s3,a0,88
    80003b88:	00f4f793          	andi	a5,s1,15
    80003b8c:	079a                	slli	a5,a5,0x6
    80003b8e:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003b90:	00099783          	lh	a5,0(s3)
    80003b94:	c3a1                	beqz	a5,80003bd4 <ialloc+0x9c>
    brelse(bp);
    80003b96:	00000097          	auipc	ra,0x0
    80003b9a:	a54080e7          	jalr	-1452(ra) # 800035ea <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b9e:	0485                	addi	s1,s1,1
    80003ba0:	00ca2703          	lw	a4,12(s4)
    80003ba4:	0004879b          	sext.w	a5,s1
    80003ba8:	fce7e1e3          	bltu	a5,a4,80003b6a <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003bac:	00005517          	auipc	a0,0x5
    80003bb0:	b6c50513          	addi	a0,a0,-1172 # 80008718 <syscalls+0x190>
    80003bb4:	ffffd097          	auipc	ra,0xffffd
    80003bb8:	9da080e7          	jalr	-1574(ra) # 8000058e <printf>
  return 0;
    80003bbc:	4501                	li	a0,0
}
    80003bbe:	60a6                	ld	ra,72(sp)
    80003bc0:	6406                	ld	s0,64(sp)
    80003bc2:	74e2                	ld	s1,56(sp)
    80003bc4:	7942                	ld	s2,48(sp)
    80003bc6:	79a2                	ld	s3,40(sp)
    80003bc8:	7a02                	ld	s4,32(sp)
    80003bca:	6ae2                	ld	s5,24(sp)
    80003bcc:	6b42                	ld	s6,16(sp)
    80003bce:	6ba2                	ld	s7,8(sp)
    80003bd0:	6161                	addi	sp,sp,80
    80003bd2:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003bd4:	04000613          	li	a2,64
    80003bd8:	4581                	li	a1,0
    80003bda:	854e                	mv	a0,s3
    80003bdc:	ffffd097          	auipc	ra,0xffffd
    80003be0:	10a080e7          	jalr	266(ra) # 80000ce6 <memset>
      dip->type = type;
    80003be4:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003be8:	854a                	mv	a0,s2
    80003bea:	00001097          	auipc	ra,0x1
    80003bee:	c84080e7          	jalr	-892(ra) # 8000486e <log_write>
      brelse(bp);
    80003bf2:	854a                	mv	a0,s2
    80003bf4:	00000097          	auipc	ra,0x0
    80003bf8:	9f6080e7          	jalr	-1546(ra) # 800035ea <brelse>
      return iget(dev, inum);
    80003bfc:	85da                	mv	a1,s6
    80003bfe:	8556                	mv	a0,s5
    80003c00:	00000097          	auipc	ra,0x0
    80003c04:	d9c080e7          	jalr	-612(ra) # 8000399c <iget>
    80003c08:	bf5d                	j	80003bbe <ialloc+0x86>

0000000080003c0a <iupdate>:
{
    80003c0a:	1101                	addi	sp,sp,-32
    80003c0c:	ec06                	sd	ra,24(sp)
    80003c0e:	e822                	sd	s0,16(sp)
    80003c10:	e426                	sd	s1,8(sp)
    80003c12:	e04a                	sd	s2,0(sp)
    80003c14:	1000                	addi	s0,sp,32
    80003c16:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003c18:	415c                	lw	a5,4(a0)
    80003c1a:	0047d79b          	srliw	a5,a5,0x4
    80003c1e:	0001d597          	auipc	a1,0x1d
    80003c22:	1525a583          	lw	a1,338(a1) # 80020d70 <sb+0x18>
    80003c26:	9dbd                	addw	a1,a1,a5
    80003c28:	4108                	lw	a0,0(a0)
    80003c2a:	00000097          	auipc	ra,0x0
    80003c2e:	890080e7          	jalr	-1904(ra) # 800034ba <bread>
    80003c32:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c34:	05850793          	addi	a5,a0,88
    80003c38:	40c8                	lw	a0,4(s1)
    80003c3a:	893d                	andi	a0,a0,15
    80003c3c:	051a                	slli	a0,a0,0x6
    80003c3e:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003c40:	04449703          	lh	a4,68(s1)
    80003c44:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003c48:	04649703          	lh	a4,70(s1)
    80003c4c:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003c50:	04849703          	lh	a4,72(s1)
    80003c54:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003c58:	04a49703          	lh	a4,74(s1)
    80003c5c:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003c60:	44f8                	lw	a4,76(s1)
    80003c62:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003c64:	03400613          	li	a2,52
    80003c68:	05048593          	addi	a1,s1,80
    80003c6c:	0531                	addi	a0,a0,12
    80003c6e:	ffffd097          	auipc	ra,0xffffd
    80003c72:	0d8080e7          	jalr	216(ra) # 80000d46 <memmove>
  log_write(bp);
    80003c76:	854a                	mv	a0,s2
    80003c78:	00001097          	auipc	ra,0x1
    80003c7c:	bf6080e7          	jalr	-1034(ra) # 8000486e <log_write>
  brelse(bp);
    80003c80:	854a                	mv	a0,s2
    80003c82:	00000097          	auipc	ra,0x0
    80003c86:	968080e7          	jalr	-1688(ra) # 800035ea <brelse>
}
    80003c8a:	60e2                	ld	ra,24(sp)
    80003c8c:	6442                	ld	s0,16(sp)
    80003c8e:	64a2                	ld	s1,8(sp)
    80003c90:	6902                	ld	s2,0(sp)
    80003c92:	6105                	addi	sp,sp,32
    80003c94:	8082                	ret

0000000080003c96 <idup>:
{
    80003c96:	1101                	addi	sp,sp,-32
    80003c98:	ec06                	sd	ra,24(sp)
    80003c9a:	e822                	sd	s0,16(sp)
    80003c9c:	e426                	sd	s1,8(sp)
    80003c9e:	1000                	addi	s0,sp,32
    80003ca0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003ca2:	0001d517          	auipc	a0,0x1d
    80003ca6:	0d650513          	addi	a0,a0,214 # 80020d78 <itable>
    80003caa:	ffffd097          	auipc	ra,0xffffd
    80003cae:	f40080e7          	jalr	-192(ra) # 80000bea <acquire>
  ip->ref++;
    80003cb2:	449c                	lw	a5,8(s1)
    80003cb4:	2785                	addiw	a5,a5,1
    80003cb6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003cb8:	0001d517          	auipc	a0,0x1d
    80003cbc:	0c050513          	addi	a0,a0,192 # 80020d78 <itable>
    80003cc0:	ffffd097          	auipc	ra,0xffffd
    80003cc4:	fde080e7          	jalr	-34(ra) # 80000c9e <release>
}
    80003cc8:	8526                	mv	a0,s1
    80003cca:	60e2                	ld	ra,24(sp)
    80003ccc:	6442                	ld	s0,16(sp)
    80003cce:	64a2                	ld	s1,8(sp)
    80003cd0:	6105                	addi	sp,sp,32
    80003cd2:	8082                	ret

0000000080003cd4 <ilock>:
{
    80003cd4:	1101                	addi	sp,sp,-32
    80003cd6:	ec06                	sd	ra,24(sp)
    80003cd8:	e822                	sd	s0,16(sp)
    80003cda:	e426                	sd	s1,8(sp)
    80003cdc:	e04a                	sd	s2,0(sp)
    80003cde:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003ce0:	c115                	beqz	a0,80003d04 <ilock+0x30>
    80003ce2:	84aa                	mv	s1,a0
    80003ce4:	451c                	lw	a5,8(a0)
    80003ce6:	00f05f63          	blez	a5,80003d04 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003cea:	0541                	addi	a0,a0,16
    80003cec:	00001097          	auipc	ra,0x1
    80003cf0:	ca2080e7          	jalr	-862(ra) # 8000498e <acquiresleep>
  if(ip->valid == 0){
    80003cf4:	40bc                	lw	a5,64(s1)
    80003cf6:	cf99                	beqz	a5,80003d14 <ilock+0x40>
}
    80003cf8:	60e2                	ld	ra,24(sp)
    80003cfa:	6442                	ld	s0,16(sp)
    80003cfc:	64a2                	ld	s1,8(sp)
    80003cfe:	6902                	ld	s2,0(sp)
    80003d00:	6105                	addi	sp,sp,32
    80003d02:	8082                	ret
    panic("ilock");
    80003d04:	00005517          	auipc	a0,0x5
    80003d08:	a2c50513          	addi	a0,a0,-1492 # 80008730 <syscalls+0x1a8>
    80003d0c:	ffffd097          	auipc	ra,0xffffd
    80003d10:	838080e7          	jalr	-1992(ra) # 80000544 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003d14:	40dc                	lw	a5,4(s1)
    80003d16:	0047d79b          	srliw	a5,a5,0x4
    80003d1a:	0001d597          	auipc	a1,0x1d
    80003d1e:	0565a583          	lw	a1,86(a1) # 80020d70 <sb+0x18>
    80003d22:	9dbd                	addw	a1,a1,a5
    80003d24:	4088                	lw	a0,0(s1)
    80003d26:	fffff097          	auipc	ra,0xfffff
    80003d2a:	794080e7          	jalr	1940(ra) # 800034ba <bread>
    80003d2e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003d30:	05850593          	addi	a1,a0,88
    80003d34:	40dc                	lw	a5,4(s1)
    80003d36:	8bbd                	andi	a5,a5,15
    80003d38:	079a                	slli	a5,a5,0x6
    80003d3a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003d3c:	00059783          	lh	a5,0(a1)
    80003d40:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003d44:	00259783          	lh	a5,2(a1)
    80003d48:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003d4c:	00459783          	lh	a5,4(a1)
    80003d50:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003d54:	00659783          	lh	a5,6(a1)
    80003d58:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003d5c:	459c                	lw	a5,8(a1)
    80003d5e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003d60:	03400613          	li	a2,52
    80003d64:	05b1                	addi	a1,a1,12
    80003d66:	05048513          	addi	a0,s1,80
    80003d6a:	ffffd097          	auipc	ra,0xffffd
    80003d6e:	fdc080e7          	jalr	-36(ra) # 80000d46 <memmove>
    brelse(bp);
    80003d72:	854a                	mv	a0,s2
    80003d74:	00000097          	auipc	ra,0x0
    80003d78:	876080e7          	jalr	-1930(ra) # 800035ea <brelse>
    ip->valid = 1;
    80003d7c:	4785                	li	a5,1
    80003d7e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003d80:	04449783          	lh	a5,68(s1)
    80003d84:	fbb5                	bnez	a5,80003cf8 <ilock+0x24>
      panic("ilock: no type");
    80003d86:	00005517          	auipc	a0,0x5
    80003d8a:	9b250513          	addi	a0,a0,-1614 # 80008738 <syscalls+0x1b0>
    80003d8e:	ffffc097          	auipc	ra,0xffffc
    80003d92:	7b6080e7          	jalr	1974(ra) # 80000544 <panic>

0000000080003d96 <iunlock>:
{
    80003d96:	1101                	addi	sp,sp,-32
    80003d98:	ec06                	sd	ra,24(sp)
    80003d9a:	e822                	sd	s0,16(sp)
    80003d9c:	e426                	sd	s1,8(sp)
    80003d9e:	e04a                	sd	s2,0(sp)
    80003da0:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003da2:	c905                	beqz	a0,80003dd2 <iunlock+0x3c>
    80003da4:	84aa                	mv	s1,a0
    80003da6:	01050913          	addi	s2,a0,16
    80003daa:	854a                	mv	a0,s2
    80003dac:	00001097          	auipc	ra,0x1
    80003db0:	c7c080e7          	jalr	-900(ra) # 80004a28 <holdingsleep>
    80003db4:	cd19                	beqz	a0,80003dd2 <iunlock+0x3c>
    80003db6:	449c                	lw	a5,8(s1)
    80003db8:	00f05d63          	blez	a5,80003dd2 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003dbc:	854a                	mv	a0,s2
    80003dbe:	00001097          	auipc	ra,0x1
    80003dc2:	c26080e7          	jalr	-986(ra) # 800049e4 <releasesleep>
}
    80003dc6:	60e2                	ld	ra,24(sp)
    80003dc8:	6442                	ld	s0,16(sp)
    80003dca:	64a2                	ld	s1,8(sp)
    80003dcc:	6902                	ld	s2,0(sp)
    80003dce:	6105                	addi	sp,sp,32
    80003dd0:	8082                	ret
    panic("iunlock");
    80003dd2:	00005517          	auipc	a0,0x5
    80003dd6:	97650513          	addi	a0,a0,-1674 # 80008748 <syscalls+0x1c0>
    80003dda:	ffffc097          	auipc	ra,0xffffc
    80003dde:	76a080e7          	jalr	1898(ra) # 80000544 <panic>

0000000080003de2 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003de2:	7179                	addi	sp,sp,-48
    80003de4:	f406                	sd	ra,40(sp)
    80003de6:	f022                	sd	s0,32(sp)
    80003de8:	ec26                	sd	s1,24(sp)
    80003dea:	e84a                	sd	s2,16(sp)
    80003dec:	e44e                	sd	s3,8(sp)
    80003dee:	e052                	sd	s4,0(sp)
    80003df0:	1800                	addi	s0,sp,48
    80003df2:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003df4:	05050493          	addi	s1,a0,80
    80003df8:	08050913          	addi	s2,a0,128
    80003dfc:	a021                	j	80003e04 <itrunc+0x22>
    80003dfe:	0491                	addi	s1,s1,4
    80003e00:	01248d63          	beq	s1,s2,80003e1a <itrunc+0x38>
    if(ip->addrs[i]){
    80003e04:	408c                	lw	a1,0(s1)
    80003e06:	dde5                	beqz	a1,80003dfe <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003e08:	0009a503          	lw	a0,0(s3)
    80003e0c:	00000097          	auipc	ra,0x0
    80003e10:	8f4080e7          	jalr	-1804(ra) # 80003700 <bfree>
      ip->addrs[i] = 0;
    80003e14:	0004a023          	sw	zero,0(s1)
    80003e18:	b7dd                	j	80003dfe <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003e1a:	0809a583          	lw	a1,128(s3)
    80003e1e:	e185                	bnez	a1,80003e3e <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003e20:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003e24:	854e                	mv	a0,s3
    80003e26:	00000097          	auipc	ra,0x0
    80003e2a:	de4080e7          	jalr	-540(ra) # 80003c0a <iupdate>
}
    80003e2e:	70a2                	ld	ra,40(sp)
    80003e30:	7402                	ld	s0,32(sp)
    80003e32:	64e2                	ld	s1,24(sp)
    80003e34:	6942                	ld	s2,16(sp)
    80003e36:	69a2                	ld	s3,8(sp)
    80003e38:	6a02                	ld	s4,0(sp)
    80003e3a:	6145                	addi	sp,sp,48
    80003e3c:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003e3e:	0009a503          	lw	a0,0(s3)
    80003e42:	fffff097          	auipc	ra,0xfffff
    80003e46:	678080e7          	jalr	1656(ra) # 800034ba <bread>
    80003e4a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003e4c:	05850493          	addi	s1,a0,88
    80003e50:	45850913          	addi	s2,a0,1112
    80003e54:	a811                	j	80003e68 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003e56:	0009a503          	lw	a0,0(s3)
    80003e5a:	00000097          	auipc	ra,0x0
    80003e5e:	8a6080e7          	jalr	-1882(ra) # 80003700 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003e62:	0491                	addi	s1,s1,4
    80003e64:	01248563          	beq	s1,s2,80003e6e <itrunc+0x8c>
      if(a[j])
    80003e68:	408c                	lw	a1,0(s1)
    80003e6a:	dde5                	beqz	a1,80003e62 <itrunc+0x80>
    80003e6c:	b7ed                	j	80003e56 <itrunc+0x74>
    brelse(bp);
    80003e6e:	8552                	mv	a0,s4
    80003e70:	fffff097          	auipc	ra,0xfffff
    80003e74:	77a080e7          	jalr	1914(ra) # 800035ea <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003e78:	0809a583          	lw	a1,128(s3)
    80003e7c:	0009a503          	lw	a0,0(s3)
    80003e80:	00000097          	auipc	ra,0x0
    80003e84:	880080e7          	jalr	-1920(ra) # 80003700 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003e88:	0809a023          	sw	zero,128(s3)
    80003e8c:	bf51                	j	80003e20 <itrunc+0x3e>

0000000080003e8e <iput>:
{
    80003e8e:	1101                	addi	sp,sp,-32
    80003e90:	ec06                	sd	ra,24(sp)
    80003e92:	e822                	sd	s0,16(sp)
    80003e94:	e426                	sd	s1,8(sp)
    80003e96:	e04a                	sd	s2,0(sp)
    80003e98:	1000                	addi	s0,sp,32
    80003e9a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003e9c:	0001d517          	auipc	a0,0x1d
    80003ea0:	edc50513          	addi	a0,a0,-292 # 80020d78 <itable>
    80003ea4:	ffffd097          	auipc	ra,0xffffd
    80003ea8:	d46080e7          	jalr	-698(ra) # 80000bea <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003eac:	4498                	lw	a4,8(s1)
    80003eae:	4785                	li	a5,1
    80003eb0:	02f70363          	beq	a4,a5,80003ed6 <iput+0x48>
  ip->ref--;
    80003eb4:	449c                	lw	a5,8(s1)
    80003eb6:	37fd                	addiw	a5,a5,-1
    80003eb8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003eba:	0001d517          	auipc	a0,0x1d
    80003ebe:	ebe50513          	addi	a0,a0,-322 # 80020d78 <itable>
    80003ec2:	ffffd097          	auipc	ra,0xffffd
    80003ec6:	ddc080e7          	jalr	-548(ra) # 80000c9e <release>
}
    80003eca:	60e2                	ld	ra,24(sp)
    80003ecc:	6442                	ld	s0,16(sp)
    80003ece:	64a2                	ld	s1,8(sp)
    80003ed0:	6902                	ld	s2,0(sp)
    80003ed2:	6105                	addi	sp,sp,32
    80003ed4:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003ed6:	40bc                	lw	a5,64(s1)
    80003ed8:	dff1                	beqz	a5,80003eb4 <iput+0x26>
    80003eda:	04a49783          	lh	a5,74(s1)
    80003ede:	fbf9                	bnez	a5,80003eb4 <iput+0x26>
    acquiresleep(&ip->lock);
    80003ee0:	01048913          	addi	s2,s1,16
    80003ee4:	854a                	mv	a0,s2
    80003ee6:	00001097          	auipc	ra,0x1
    80003eea:	aa8080e7          	jalr	-1368(ra) # 8000498e <acquiresleep>
    release(&itable.lock);
    80003eee:	0001d517          	auipc	a0,0x1d
    80003ef2:	e8a50513          	addi	a0,a0,-374 # 80020d78 <itable>
    80003ef6:	ffffd097          	auipc	ra,0xffffd
    80003efa:	da8080e7          	jalr	-600(ra) # 80000c9e <release>
    itrunc(ip);
    80003efe:	8526                	mv	a0,s1
    80003f00:	00000097          	auipc	ra,0x0
    80003f04:	ee2080e7          	jalr	-286(ra) # 80003de2 <itrunc>
    ip->type = 0;
    80003f08:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003f0c:	8526                	mv	a0,s1
    80003f0e:	00000097          	auipc	ra,0x0
    80003f12:	cfc080e7          	jalr	-772(ra) # 80003c0a <iupdate>
    ip->valid = 0;
    80003f16:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003f1a:	854a                	mv	a0,s2
    80003f1c:	00001097          	auipc	ra,0x1
    80003f20:	ac8080e7          	jalr	-1336(ra) # 800049e4 <releasesleep>
    acquire(&itable.lock);
    80003f24:	0001d517          	auipc	a0,0x1d
    80003f28:	e5450513          	addi	a0,a0,-428 # 80020d78 <itable>
    80003f2c:	ffffd097          	auipc	ra,0xffffd
    80003f30:	cbe080e7          	jalr	-834(ra) # 80000bea <acquire>
    80003f34:	b741                	j	80003eb4 <iput+0x26>

0000000080003f36 <iunlockput>:
{
    80003f36:	1101                	addi	sp,sp,-32
    80003f38:	ec06                	sd	ra,24(sp)
    80003f3a:	e822                	sd	s0,16(sp)
    80003f3c:	e426                	sd	s1,8(sp)
    80003f3e:	1000                	addi	s0,sp,32
    80003f40:	84aa                	mv	s1,a0
  iunlock(ip);
    80003f42:	00000097          	auipc	ra,0x0
    80003f46:	e54080e7          	jalr	-428(ra) # 80003d96 <iunlock>
  iput(ip);
    80003f4a:	8526                	mv	a0,s1
    80003f4c:	00000097          	auipc	ra,0x0
    80003f50:	f42080e7          	jalr	-190(ra) # 80003e8e <iput>
}
    80003f54:	60e2                	ld	ra,24(sp)
    80003f56:	6442                	ld	s0,16(sp)
    80003f58:	64a2                	ld	s1,8(sp)
    80003f5a:	6105                	addi	sp,sp,32
    80003f5c:	8082                	ret

0000000080003f5e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003f5e:	1141                	addi	sp,sp,-16
    80003f60:	e422                	sd	s0,8(sp)
    80003f62:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003f64:	411c                	lw	a5,0(a0)
    80003f66:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003f68:	415c                	lw	a5,4(a0)
    80003f6a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003f6c:	04451783          	lh	a5,68(a0)
    80003f70:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003f74:	04a51783          	lh	a5,74(a0)
    80003f78:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003f7c:	04c56783          	lwu	a5,76(a0)
    80003f80:	e99c                	sd	a5,16(a1)
}
    80003f82:	6422                	ld	s0,8(sp)
    80003f84:	0141                	addi	sp,sp,16
    80003f86:	8082                	ret

0000000080003f88 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003f88:	457c                	lw	a5,76(a0)
    80003f8a:	0ed7e963          	bltu	a5,a3,8000407c <readi+0xf4>
{
    80003f8e:	7159                	addi	sp,sp,-112
    80003f90:	f486                	sd	ra,104(sp)
    80003f92:	f0a2                	sd	s0,96(sp)
    80003f94:	eca6                	sd	s1,88(sp)
    80003f96:	e8ca                	sd	s2,80(sp)
    80003f98:	e4ce                	sd	s3,72(sp)
    80003f9a:	e0d2                	sd	s4,64(sp)
    80003f9c:	fc56                	sd	s5,56(sp)
    80003f9e:	f85a                	sd	s6,48(sp)
    80003fa0:	f45e                	sd	s7,40(sp)
    80003fa2:	f062                	sd	s8,32(sp)
    80003fa4:	ec66                	sd	s9,24(sp)
    80003fa6:	e86a                	sd	s10,16(sp)
    80003fa8:	e46e                	sd	s11,8(sp)
    80003faa:	1880                	addi	s0,sp,112
    80003fac:	8b2a                	mv	s6,a0
    80003fae:	8bae                	mv	s7,a1
    80003fb0:	8a32                	mv	s4,a2
    80003fb2:	84b6                	mv	s1,a3
    80003fb4:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003fb6:	9f35                	addw	a4,a4,a3
    return 0;
    80003fb8:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003fba:	0ad76063          	bltu	a4,a3,8000405a <readi+0xd2>
  if(off + n > ip->size)
    80003fbe:	00e7f463          	bgeu	a5,a4,80003fc6 <readi+0x3e>
    n = ip->size - off;
    80003fc2:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003fc6:	0a0a8963          	beqz	s5,80004078 <readi+0xf0>
    80003fca:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fcc:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003fd0:	5c7d                	li	s8,-1
    80003fd2:	a82d                	j	8000400c <readi+0x84>
    80003fd4:	020d1d93          	slli	s11,s10,0x20
    80003fd8:	020ddd93          	srli	s11,s11,0x20
    80003fdc:	05890613          	addi	a2,s2,88
    80003fe0:	86ee                	mv	a3,s11
    80003fe2:	963a                	add	a2,a2,a4
    80003fe4:	85d2                	mv	a1,s4
    80003fe6:	855e                	mv	a0,s7
    80003fe8:	fffff097          	auipc	ra,0xfffff
    80003fec:	854080e7          	jalr	-1964(ra) # 8000283c <either_copyout>
    80003ff0:	05850d63          	beq	a0,s8,8000404a <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003ff4:	854a                	mv	a0,s2
    80003ff6:	fffff097          	auipc	ra,0xfffff
    80003ffa:	5f4080e7          	jalr	1524(ra) # 800035ea <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ffe:	013d09bb          	addw	s3,s10,s3
    80004002:	009d04bb          	addw	s1,s10,s1
    80004006:	9a6e                	add	s4,s4,s11
    80004008:	0559f763          	bgeu	s3,s5,80004056 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    8000400c:	00a4d59b          	srliw	a1,s1,0xa
    80004010:	855a                	mv	a0,s6
    80004012:	00000097          	auipc	ra,0x0
    80004016:	8a2080e7          	jalr	-1886(ra) # 800038b4 <bmap>
    8000401a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000401e:	cd85                	beqz	a1,80004056 <readi+0xce>
    bp = bread(ip->dev, addr);
    80004020:	000b2503          	lw	a0,0(s6)
    80004024:	fffff097          	auipc	ra,0xfffff
    80004028:	496080e7          	jalr	1174(ra) # 800034ba <bread>
    8000402c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000402e:	3ff4f713          	andi	a4,s1,1023
    80004032:	40ec87bb          	subw	a5,s9,a4
    80004036:	413a86bb          	subw	a3,s5,s3
    8000403a:	8d3e                	mv	s10,a5
    8000403c:	2781                	sext.w	a5,a5
    8000403e:	0006861b          	sext.w	a2,a3
    80004042:	f8f679e3          	bgeu	a2,a5,80003fd4 <readi+0x4c>
    80004046:	8d36                	mv	s10,a3
    80004048:	b771                	j	80003fd4 <readi+0x4c>
      brelse(bp);
    8000404a:	854a                	mv	a0,s2
    8000404c:	fffff097          	auipc	ra,0xfffff
    80004050:	59e080e7          	jalr	1438(ra) # 800035ea <brelse>
      tot = -1;
    80004054:	59fd                	li	s3,-1
  }
  return tot;
    80004056:	0009851b          	sext.w	a0,s3
}
    8000405a:	70a6                	ld	ra,104(sp)
    8000405c:	7406                	ld	s0,96(sp)
    8000405e:	64e6                	ld	s1,88(sp)
    80004060:	6946                	ld	s2,80(sp)
    80004062:	69a6                	ld	s3,72(sp)
    80004064:	6a06                	ld	s4,64(sp)
    80004066:	7ae2                	ld	s5,56(sp)
    80004068:	7b42                	ld	s6,48(sp)
    8000406a:	7ba2                	ld	s7,40(sp)
    8000406c:	7c02                	ld	s8,32(sp)
    8000406e:	6ce2                	ld	s9,24(sp)
    80004070:	6d42                	ld	s10,16(sp)
    80004072:	6da2                	ld	s11,8(sp)
    80004074:	6165                	addi	sp,sp,112
    80004076:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004078:	89d6                	mv	s3,s5
    8000407a:	bff1                	j	80004056 <readi+0xce>
    return 0;
    8000407c:	4501                	li	a0,0
}
    8000407e:	8082                	ret

0000000080004080 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004080:	457c                	lw	a5,76(a0)
    80004082:	10d7e863          	bltu	a5,a3,80004192 <writei+0x112>
{
    80004086:	7159                	addi	sp,sp,-112
    80004088:	f486                	sd	ra,104(sp)
    8000408a:	f0a2                	sd	s0,96(sp)
    8000408c:	eca6                	sd	s1,88(sp)
    8000408e:	e8ca                	sd	s2,80(sp)
    80004090:	e4ce                	sd	s3,72(sp)
    80004092:	e0d2                	sd	s4,64(sp)
    80004094:	fc56                	sd	s5,56(sp)
    80004096:	f85a                	sd	s6,48(sp)
    80004098:	f45e                	sd	s7,40(sp)
    8000409a:	f062                	sd	s8,32(sp)
    8000409c:	ec66                	sd	s9,24(sp)
    8000409e:	e86a                	sd	s10,16(sp)
    800040a0:	e46e                	sd	s11,8(sp)
    800040a2:	1880                	addi	s0,sp,112
    800040a4:	8aaa                	mv	s5,a0
    800040a6:	8bae                	mv	s7,a1
    800040a8:	8a32                	mv	s4,a2
    800040aa:	8936                	mv	s2,a3
    800040ac:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800040ae:	00e687bb          	addw	a5,a3,a4
    800040b2:	0ed7e263          	bltu	a5,a3,80004196 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800040b6:	00043737          	lui	a4,0x43
    800040ba:	0ef76063          	bltu	a4,a5,8000419a <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800040be:	0c0b0863          	beqz	s6,8000418e <writei+0x10e>
    800040c2:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800040c4:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800040c8:	5c7d                	li	s8,-1
    800040ca:	a091                	j	8000410e <writei+0x8e>
    800040cc:	020d1d93          	slli	s11,s10,0x20
    800040d0:	020ddd93          	srli	s11,s11,0x20
    800040d4:	05848513          	addi	a0,s1,88
    800040d8:	86ee                	mv	a3,s11
    800040da:	8652                	mv	a2,s4
    800040dc:	85de                	mv	a1,s7
    800040de:	953a                	add	a0,a0,a4
    800040e0:	ffffe097          	auipc	ra,0xffffe
    800040e4:	7b2080e7          	jalr	1970(ra) # 80002892 <either_copyin>
    800040e8:	07850263          	beq	a0,s8,8000414c <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800040ec:	8526                	mv	a0,s1
    800040ee:	00000097          	auipc	ra,0x0
    800040f2:	780080e7          	jalr	1920(ra) # 8000486e <log_write>
    brelse(bp);
    800040f6:	8526                	mv	a0,s1
    800040f8:	fffff097          	auipc	ra,0xfffff
    800040fc:	4f2080e7          	jalr	1266(ra) # 800035ea <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004100:	013d09bb          	addw	s3,s10,s3
    80004104:	012d093b          	addw	s2,s10,s2
    80004108:	9a6e                	add	s4,s4,s11
    8000410a:	0569f663          	bgeu	s3,s6,80004156 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    8000410e:	00a9559b          	srliw	a1,s2,0xa
    80004112:	8556                	mv	a0,s5
    80004114:	fffff097          	auipc	ra,0xfffff
    80004118:	7a0080e7          	jalr	1952(ra) # 800038b4 <bmap>
    8000411c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004120:	c99d                	beqz	a1,80004156 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80004122:	000aa503          	lw	a0,0(s5)
    80004126:	fffff097          	auipc	ra,0xfffff
    8000412a:	394080e7          	jalr	916(ra) # 800034ba <bread>
    8000412e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004130:	3ff97713          	andi	a4,s2,1023
    80004134:	40ec87bb          	subw	a5,s9,a4
    80004138:	413b06bb          	subw	a3,s6,s3
    8000413c:	8d3e                	mv	s10,a5
    8000413e:	2781                	sext.w	a5,a5
    80004140:	0006861b          	sext.w	a2,a3
    80004144:	f8f674e3          	bgeu	a2,a5,800040cc <writei+0x4c>
    80004148:	8d36                	mv	s10,a3
    8000414a:	b749                	j	800040cc <writei+0x4c>
      brelse(bp);
    8000414c:	8526                	mv	a0,s1
    8000414e:	fffff097          	auipc	ra,0xfffff
    80004152:	49c080e7          	jalr	1180(ra) # 800035ea <brelse>
  }

  if(off > ip->size)
    80004156:	04caa783          	lw	a5,76(s5)
    8000415a:	0127f463          	bgeu	a5,s2,80004162 <writei+0xe2>
    ip->size = off;
    8000415e:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004162:	8556                	mv	a0,s5
    80004164:	00000097          	auipc	ra,0x0
    80004168:	aa6080e7          	jalr	-1370(ra) # 80003c0a <iupdate>

  return tot;
    8000416c:	0009851b          	sext.w	a0,s3
}
    80004170:	70a6                	ld	ra,104(sp)
    80004172:	7406                	ld	s0,96(sp)
    80004174:	64e6                	ld	s1,88(sp)
    80004176:	6946                	ld	s2,80(sp)
    80004178:	69a6                	ld	s3,72(sp)
    8000417a:	6a06                	ld	s4,64(sp)
    8000417c:	7ae2                	ld	s5,56(sp)
    8000417e:	7b42                	ld	s6,48(sp)
    80004180:	7ba2                	ld	s7,40(sp)
    80004182:	7c02                	ld	s8,32(sp)
    80004184:	6ce2                	ld	s9,24(sp)
    80004186:	6d42                	ld	s10,16(sp)
    80004188:	6da2                	ld	s11,8(sp)
    8000418a:	6165                	addi	sp,sp,112
    8000418c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000418e:	89da                	mv	s3,s6
    80004190:	bfc9                	j	80004162 <writei+0xe2>
    return -1;
    80004192:	557d                	li	a0,-1
}
    80004194:	8082                	ret
    return -1;
    80004196:	557d                	li	a0,-1
    80004198:	bfe1                	j	80004170 <writei+0xf0>
    return -1;
    8000419a:	557d                	li	a0,-1
    8000419c:	bfd1                	j	80004170 <writei+0xf0>

000000008000419e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000419e:	1141                	addi	sp,sp,-16
    800041a0:	e406                	sd	ra,8(sp)
    800041a2:	e022                	sd	s0,0(sp)
    800041a4:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800041a6:	4639                	li	a2,14
    800041a8:	ffffd097          	auipc	ra,0xffffd
    800041ac:	c16080e7          	jalr	-1002(ra) # 80000dbe <strncmp>
}
    800041b0:	60a2                	ld	ra,8(sp)
    800041b2:	6402                	ld	s0,0(sp)
    800041b4:	0141                	addi	sp,sp,16
    800041b6:	8082                	ret

00000000800041b8 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800041b8:	7139                	addi	sp,sp,-64
    800041ba:	fc06                	sd	ra,56(sp)
    800041bc:	f822                	sd	s0,48(sp)
    800041be:	f426                	sd	s1,40(sp)
    800041c0:	f04a                	sd	s2,32(sp)
    800041c2:	ec4e                	sd	s3,24(sp)
    800041c4:	e852                	sd	s4,16(sp)
    800041c6:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800041c8:	04451703          	lh	a4,68(a0)
    800041cc:	4785                	li	a5,1
    800041ce:	00f71a63          	bne	a4,a5,800041e2 <dirlookup+0x2a>
    800041d2:	892a                	mv	s2,a0
    800041d4:	89ae                	mv	s3,a1
    800041d6:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800041d8:	457c                	lw	a5,76(a0)
    800041da:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800041dc:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041de:	e79d                	bnez	a5,8000420c <dirlookup+0x54>
    800041e0:	a8a5                	j	80004258 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800041e2:	00004517          	auipc	a0,0x4
    800041e6:	56e50513          	addi	a0,a0,1390 # 80008750 <syscalls+0x1c8>
    800041ea:	ffffc097          	auipc	ra,0xffffc
    800041ee:	35a080e7          	jalr	858(ra) # 80000544 <panic>
      panic("dirlookup read");
    800041f2:	00004517          	auipc	a0,0x4
    800041f6:	57650513          	addi	a0,a0,1398 # 80008768 <syscalls+0x1e0>
    800041fa:	ffffc097          	auipc	ra,0xffffc
    800041fe:	34a080e7          	jalr	842(ra) # 80000544 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004202:	24c1                	addiw	s1,s1,16
    80004204:	04c92783          	lw	a5,76(s2)
    80004208:	04f4f763          	bgeu	s1,a5,80004256 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000420c:	4741                	li	a4,16
    8000420e:	86a6                	mv	a3,s1
    80004210:	fc040613          	addi	a2,s0,-64
    80004214:	4581                	li	a1,0
    80004216:	854a                	mv	a0,s2
    80004218:	00000097          	auipc	ra,0x0
    8000421c:	d70080e7          	jalr	-656(ra) # 80003f88 <readi>
    80004220:	47c1                	li	a5,16
    80004222:	fcf518e3          	bne	a0,a5,800041f2 <dirlookup+0x3a>
    if(de.inum == 0)
    80004226:	fc045783          	lhu	a5,-64(s0)
    8000422a:	dfe1                	beqz	a5,80004202 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000422c:	fc240593          	addi	a1,s0,-62
    80004230:	854e                	mv	a0,s3
    80004232:	00000097          	auipc	ra,0x0
    80004236:	f6c080e7          	jalr	-148(ra) # 8000419e <namecmp>
    8000423a:	f561                	bnez	a0,80004202 <dirlookup+0x4a>
      if(poff)
    8000423c:	000a0463          	beqz	s4,80004244 <dirlookup+0x8c>
        *poff = off;
    80004240:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004244:	fc045583          	lhu	a1,-64(s0)
    80004248:	00092503          	lw	a0,0(s2)
    8000424c:	fffff097          	auipc	ra,0xfffff
    80004250:	750080e7          	jalr	1872(ra) # 8000399c <iget>
    80004254:	a011                	j	80004258 <dirlookup+0xa0>
  return 0;
    80004256:	4501                	li	a0,0
}
    80004258:	70e2                	ld	ra,56(sp)
    8000425a:	7442                	ld	s0,48(sp)
    8000425c:	74a2                	ld	s1,40(sp)
    8000425e:	7902                	ld	s2,32(sp)
    80004260:	69e2                	ld	s3,24(sp)
    80004262:	6a42                	ld	s4,16(sp)
    80004264:	6121                	addi	sp,sp,64
    80004266:	8082                	ret

0000000080004268 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004268:	711d                	addi	sp,sp,-96
    8000426a:	ec86                	sd	ra,88(sp)
    8000426c:	e8a2                	sd	s0,80(sp)
    8000426e:	e4a6                	sd	s1,72(sp)
    80004270:	e0ca                	sd	s2,64(sp)
    80004272:	fc4e                	sd	s3,56(sp)
    80004274:	f852                	sd	s4,48(sp)
    80004276:	f456                	sd	s5,40(sp)
    80004278:	f05a                	sd	s6,32(sp)
    8000427a:	ec5e                	sd	s7,24(sp)
    8000427c:	e862                	sd	s8,16(sp)
    8000427e:	e466                	sd	s9,8(sp)
    80004280:	1080                	addi	s0,sp,96
    80004282:	84aa                	mv	s1,a0
    80004284:	8b2e                	mv	s6,a1
    80004286:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004288:	00054703          	lbu	a4,0(a0)
    8000428c:	02f00793          	li	a5,47
    80004290:	02f70363          	beq	a4,a5,800042b6 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004294:	ffffe097          	auipc	ra,0xffffe
    80004298:	83c080e7          	jalr	-1988(ra) # 80001ad0 <myproc>
    8000429c:	15853503          	ld	a0,344(a0)
    800042a0:	00000097          	auipc	ra,0x0
    800042a4:	9f6080e7          	jalr	-1546(ra) # 80003c96 <idup>
    800042a8:	89aa                	mv	s3,a0
  while(*path == '/')
    800042aa:	02f00913          	li	s2,47
  len = path - s;
    800042ae:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    800042b0:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800042b2:	4c05                	li	s8,1
    800042b4:	a865                	j	8000436c <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    800042b6:	4585                	li	a1,1
    800042b8:	4505                	li	a0,1
    800042ba:	fffff097          	auipc	ra,0xfffff
    800042be:	6e2080e7          	jalr	1762(ra) # 8000399c <iget>
    800042c2:	89aa                	mv	s3,a0
    800042c4:	b7dd                	j	800042aa <namex+0x42>
      iunlockput(ip);
    800042c6:	854e                	mv	a0,s3
    800042c8:	00000097          	auipc	ra,0x0
    800042cc:	c6e080e7          	jalr	-914(ra) # 80003f36 <iunlockput>
      return 0;
    800042d0:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800042d2:	854e                	mv	a0,s3
    800042d4:	60e6                	ld	ra,88(sp)
    800042d6:	6446                	ld	s0,80(sp)
    800042d8:	64a6                	ld	s1,72(sp)
    800042da:	6906                	ld	s2,64(sp)
    800042dc:	79e2                	ld	s3,56(sp)
    800042de:	7a42                	ld	s4,48(sp)
    800042e0:	7aa2                	ld	s5,40(sp)
    800042e2:	7b02                	ld	s6,32(sp)
    800042e4:	6be2                	ld	s7,24(sp)
    800042e6:	6c42                	ld	s8,16(sp)
    800042e8:	6ca2                	ld	s9,8(sp)
    800042ea:	6125                	addi	sp,sp,96
    800042ec:	8082                	ret
      iunlock(ip);
    800042ee:	854e                	mv	a0,s3
    800042f0:	00000097          	auipc	ra,0x0
    800042f4:	aa6080e7          	jalr	-1370(ra) # 80003d96 <iunlock>
      return ip;
    800042f8:	bfe9                	j	800042d2 <namex+0x6a>
      iunlockput(ip);
    800042fa:	854e                	mv	a0,s3
    800042fc:	00000097          	auipc	ra,0x0
    80004300:	c3a080e7          	jalr	-966(ra) # 80003f36 <iunlockput>
      return 0;
    80004304:	89d2                	mv	s3,s4
    80004306:	b7f1                	j	800042d2 <namex+0x6a>
  len = path - s;
    80004308:	40b48633          	sub	a2,s1,a1
    8000430c:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80004310:	094cd463          	bge	s9,s4,80004398 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004314:	4639                	li	a2,14
    80004316:	8556                	mv	a0,s5
    80004318:	ffffd097          	auipc	ra,0xffffd
    8000431c:	a2e080e7          	jalr	-1490(ra) # 80000d46 <memmove>
  while(*path == '/')
    80004320:	0004c783          	lbu	a5,0(s1)
    80004324:	01279763          	bne	a5,s2,80004332 <namex+0xca>
    path++;
    80004328:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000432a:	0004c783          	lbu	a5,0(s1)
    8000432e:	ff278de3          	beq	a5,s2,80004328 <namex+0xc0>
    ilock(ip);
    80004332:	854e                	mv	a0,s3
    80004334:	00000097          	auipc	ra,0x0
    80004338:	9a0080e7          	jalr	-1632(ra) # 80003cd4 <ilock>
    if(ip->type != T_DIR){
    8000433c:	04499783          	lh	a5,68(s3)
    80004340:	f98793e3          	bne	a5,s8,800042c6 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004344:	000b0563          	beqz	s6,8000434e <namex+0xe6>
    80004348:	0004c783          	lbu	a5,0(s1)
    8000434c:	d3cd                	beqz	a5,800042ee <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000434e:	865e                	mv	a2,s7
    80004350:	85d6                	mv	a1,s5
    80004352:	854e                	mv	a0,s3
    80004354:	00000097          	auipc	ra,0x0
    80004358:	e64080e7          	jalr	-412(ra) # 800041b8 <dirlookup>
    8000435c:	8a2a                	mv	s4,a0
    8000435e:	dd51                	beqz	a0,800042fa <namex+0x92>
    iunlockput(ip);
    80004360:	854e                	mv	a0,s3
    80004362:	00000097          	auipc	ra,0x0
    80004366:	bd4080e7          	jalr	-1068(ra) # 80003f36 <iunlockput>
    ip = next;
    8000436a:	89d2                	mv	s3,s4
  while(*path == '/')
    8000436c:	0004c783          	lbu	a5,0(s1)
    80004370:	05279763          	bne	a5,s2,800043be <namex+0x156>
    path++;
    80004374:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004376:	0004c783          	lbu	a5,0(s1)
    8000437a:	ff278de3          	beq	a5,s2,80004374 <namex+0x10c>
  if(*path == 0)
    8000437e:	c79d                	beqz	a5,800043ac <namex+0x144>
    path++;
    80004380:	85a6                	mv	a1,s1
  len = path - s;
    80004382:	8a5e                	mv	s4,s7
    80004384:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80004386:	01278963          	beq	a5,s2,80004398 <namex+0x130>
    8000438a:	dfbd                	beqz	a5,80004308 <namex+0xa0>
    path++;
    8000438c:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000438e:	0004c783          	lbu	a5,0(s1)
    80004392:	ff279ce3          	bne	a5,s2,8000438a <namex+0x122>
    80004396:	bf8d                	j	80004308 <namex+0xa0>
    memmove(name, s, len);
    80004398:	2601                	sext.w	a2,a2
    8000439a:	8556                	mv	a0,s5
    8000439c:	ffffd097          	auipc	ra,0xffffd
    800043a0:	9aa080e7          	jalr	-1622(ra) # 80000d46 <memmove>
    name[len] = 0;
    800043a4:	9a56                	add	s4,s4,s5
    800043a6:	000a0023          	sb	zero,0(s4)
    800043aa:	bf9d                	j	80004320 <namex+0xb8>
  if(nameiparent){
    800043ac:	f20b03e3          	beqz	s6,800042d2 <namex+0x6a>
    iput(ip);
    800043b0:	854e                	mv	a0,s3
    800043b2:	00000097          	auipc	ra,0x0
    800043b6:	adc080e7          	jalr	-1316(ra) # 80003e8e <iput>
    return 0;
    800043ba:	4981                	li	s3,0
    800043bc:	bf19                	j	800042d2 <namex+0x6a>
  if(*path == 0)
    800043be:	d7fd                	beqz	a5,800043ac <namex+0x144>
  while(*path != '/' && *path != 0)
    800043c0:	0004c783          	lbu	a5,0(s1)
    800043c4:	85a6                	mv	a1,s1
    800043c6:	b7d1                	j	8000438a <namex+0x122>

00000000800043c8 <dirlink>:
{
    800043c8:	7139                	addi	sp,sp,-64
    800043ca:	fc06                	sd	ra,56(sp)
    800043cc:	f822                	sd	s0,48(sp)
    800043ce:	f426                	sd	s1,40(sp)
    800043d0:	f04a                	sd	s2,32(sp)
    800043d2:	ec4e                	sd	s3,24(sp)
    800043d4:	e852                	sd	s4,16(sp)
    800043d6:	0080                	addi	s0,sp,64
    800043d8:	892a                	mv	s2,a0
    800043da:	8a2e                	mv	s4,a1
    800043dc:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800043de:	4601                	li	a2,0
    800043e0:	00000097          	auipc	ra,0x0
    800043e4:	dd8080e7          	jalr	-552(ra) # 800041b8 <dirlookup>
    800043e8:	e93d                	bnez	a0,8000445e <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043ea:	04c92483          	lw	s1,76(s2)
    800043ee:	c49d                	beqz	s1,8000441c <dirlink+0x54>
    800043f0:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043f2:	4741                	li	a4,16
    800043f4:	86a6                	mv	a3,s1
    800043f6:	fc040613          	addi	a2,s0,-64
    800043fa:	4581                	li	a1,0
    800043fc:	854a                	mv	a0,s2
    800043fe:	00000097          	auipc	ra,0x0
    80004402:	b8a080e7          	jalr	-1142(ra) # 80003f88 <readi>
    80004406:	47c1                	li	a5,16
    80004408:	06f51163          	bne	a0,a5,8000446a <dirlink+0xa2>
    if(de.inum == 0)
    8000440c:	fc045783          	lhu	a5,-64(s0)
    80004410:	c791                	beqz	a5,8000441c <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004412:	24c1                	addiw	s1,s1,16
    80004414:	04c92783          	lw	a5,76(s2)
    80004418:	fcf4ede3          	bltu	s1,a5,800043f2 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000441c:	4639                	li	a2,14
    8000441e:	85d2                	mv	a1,s4
    80004420:	fc240513          	addi	a0,s0,-62
    80004424:	ffffd097          	auipc	ra,0xffffd
    80004428:	9d6080e7          	jalr	-1578(ra) # 80000dfa <strncpy>
  de.inum = inum;
    8000442c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004430:	4741                	li	a4,16
    80004432:	86a6                	mv	a3,s1
    80004434:	fc040613          	addi	a2,s0,-64
    80004438:	4581                	li	a1,0
    8000443a:	854a                	mv	a0,s2
    8000443c:	00000097          	auipc	ra,0x0
    80004440:	c44080e7          	jalr	-956(ra) # 80004080 <writei>
    80004444:	1541                	addi	a0,a0,-16
    80004446:	00a03533          	snez	a0,a0
    8000444a:	40a00533          	neg	a0,a0
}
    8000444e:	70e2                	ld	ra,56(sp)
    80004450:	7442                	ld	s0,48(sp)
    80004452:	74a2                	ld	s1,40(sp)
    80004454:	7902                	ld	s2,32(sp)
    80004456:	69e2                	ld	s3,24(sp)
    80004458:	6a42                	ld	s4,16(sp)
    8000445a:	6121                	addi	sp,sp,64
    8000445c:	8082                	ret
    iput(ip);
    8000445e:	00000097          	auipc	ra,0x0
    80004462:	a30080e7          	jalr	-1488(ra) # 80003e8e <iput>
    return -1;
    80004466:	557d                	li	a0,-1
    80004468:	b7dd                	j	8000444e <dirlink+0x86>
      panic("dirlink read");
    8000446a:	00004517          	auipc	a0,0x4
    8000446e:	30e50513          	addi	a0,a0,782 # 80008778 <syscalls+0x1f0>
    80004472:	ffffc097          	auipc	ra,0xffffc
    80004476:	0d2080e7          	jalr	210(ra) # 80000544 <panic>

000000008000447a <namei>:

struct inode*
namei(char *path)
{
    8000447a:	1101                	addi	sp,sp,-32
    8000447c:	ec06                	sd	ra,24(sp)
    8000447e:	e822                	sd	s0,16(sp)
    80004480:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004482:	fe040613          	addi	a2,s0,-32
    80004486:	4581                	li	a1,0
    80004488:	00000097          	auipc	ra,0x0
    8000448c:	de0080e7          	jalr	-544(ra) # 80004268 <namex>
}
    80004490:	60e2                	ld	ra,24(sp)
    80004492:	6442                	ld	s0,16(sp)
    80004494:	6105                	addi	sp,sp,32
    80004496:	8082                	ret

0000000080004498 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004498:	1141                	addi	sp,sp,-16
    8000449a:	e406                	sd	ra,8(sp)
    8000449c:	e022                	sd	s0,0(sp)
    8000449e:	0800                	addi	s0,sp,16
    800044a0:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800044a2:	4585                	li	a1,1
    800044a4:	00000097          	auipc	ra,0x0
    800044a8:	dc4080e7          	jalr	-572(ra) # 80004268 <namex>
}
    800044ac:	60a2                	ld	ra,8(sp)
    800044ae:	6402                	ld	s0,0(sp)
    800044b0:	0141                	addi	sp,sp,16
    800044b2:	8082                	ret

00000000800044b4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800044b4:	1101                	addi	sp,sp,-32
    800044b6:	ec06                	sd	ra,24(sp)
    800044b8:	e822                	sd	s0,16(sp)
    800044ba:	e426                	sd	s1,8(sp)
    800044bc:	e04a                	sd	s2,0(sp)
    800044be:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800044c0:	0001e917          	auipc	s2,0x1e
    800044c4:	36090913          	addi	s2,s2,864 # 80022820 <log>
    800044c8:	01892583          	lw	a1,24(s2)
    800044cc:	02892503          	lw	a0,40(s2)
    800044d0:	fffff097          	auipc	ra,0xfffff
    800044d4:	fea080e7          	jalr	-22(ra) # 800034ba <bread>
    800044d8:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800044da:	02c92683          	lw	a3,44(s2)
    800044de:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800044e0:	02d05763          	blez	a3,8000450e <write_head+0x5a>
    800044e4:	0001e797          	auipc	a5,0x1e
    800044e8:	36c78793          	addi	a5,a5,876 # 80022850 <log+0x30>
    800044ec:	05c50713          	addi	a4,a0,92
    800044f0:	36fd                	addiw	a3,a3,-1
    800044f2:	1682                	slli	a3,a3,0x20
    800044f4:	9281                	srli	a3,a3,0x20
    800044f6:	068a                	slli	a3,a3,0x2
    800044f8:	0001e617          	auipc	a2,0x1e
    800044fc:	35c60613          	addi	a2,a2,860 # 80022854 <log+0x34>
    80004500:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004502:	4390                	lw	a2,0(a5)
    80004504:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004506:	0791                	addi	a5,a5,4
    80004508:	0711                	addi	a4,a4,4
    8000450a:	fed79ce3          	bne	a5,a3,80004502 <write_head+0x4e>
  }
  bwrite(buf);
    8000450e:	8526                	mv	a0,s1
    80004510:	fffff097          	auipc	ra,0xfffff
    80004514:	09c080e7          	jalr	156(ra) # 800035ac <bwrite>
  brelse(buf);
    80004518:	8526                	mv	a0,s1
    8000451a:	fffff097          	auipc	ra,0xfffff
    8000451e:	0d0080e7          	jalr	208(ra) # 800035ea <brelse>
}
    80004522:	60e2                	ld	ra,24(sp)
    80004524:	6442                	ld	s0,16(sp)
    80004526:	64a2                	ld	s1,8(sp)
    80004528:	6902                	ld	s2,0(sp)
    8000452a:	6105                	addi	sp,sp,32
    8000452c:	8082                	ret

000000008000452e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000452e:	0001e797          	auipc	a5,0x1e
    80004532:	31e7a783          	lw	a5,798(a5) # 8002284c <log+0x2c>
    80004536:	0af05d63          	blez	a5,800045f0 <install_trans+0xc2>
{
    8000453a:	7139                	addi	sp,sp,-64
    8000453c:	fc06                	sd	ra,56(sp)
    8000453e:	f822                	sd	s0,48(sp)
    80004540:	f426                	sd	s1,40(sp)
    80004542:	f04a                	sd	s2,32(sp)
    80004544:	ec4e                	sd	s3,24(sp)
    80004546:	e852                	sd	s4,16(sp)
    80004548:	e456                	sd	s5,8(sp)
    8000454a:	e05a                	sd	s6,0(sp)
    8000454c:	0080                	addi	s0,sp,64
    8000454e:	8b2a                	mv	s6,a0
    80004550:	0001ea97          	auipc	s5,0x1e
    80004554:	300a8a93          	addi	s5,s5,768 # 80022850 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004558:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000455a:	0001e997          	auipc	s3,0x1e
    8000455e:	2c698993          	addi	s3,s3,710 # 80022820 <log>
    80004562:	a035                	j	8000458e <install_trans+0x60>
      bunpin(dbuf);
    80004564:	8526                	mv	a0,s1
    80004566:	fffff097          	auipc	ra,0xfffff
    8000456a:	15e080e7          	jalr	350(ra) # 800036c4 <bunpin>
    brelse(lbuf);
    8000456e:	854a                	mv	a0,s2
    80004570:	fffff097          	auipc	ra,0xfffff
    80004574:	07a080e7          	jalr	122(ra) # 800035ea <brelse>
    brelse(dbuf);
    80004578:	8526                	mv	a0,s1
    8000457a:	fffff097          	auipc	ra,0xfffff
    8000457e:	070080e7          	jalr	112(ra) # 800035ea <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004582:	2a05                	addiw	s4,s4,1
    80004584:	0a91                	addi	s5,s5,4
    80004586:	02c9a783          	lw	a5,44(s3)
    8000458a:	04fa5963          	bge	s4,a5,800045dc <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000458e:	0189a583          	lw	a1,24(s3)
    80004592:	014585bb          	addw	a1,a1,s4
    80004596:	2585                	addiw	a1,a1,1
    80004598:	0289a503          	lw	a0,40(s3)
    8000459c:	fffff097          	auipc	ra,0xfffff
    800045a0:	f1e080e7          	jalr	-226(ra) # 800034ba <bread>
    800045a4:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800045a6:	000aa583          	lw	a1,0(s5)
    800045aa:	0289a503          	lw	a0,40(s3)
    800045ae:	fffff097          	auipc	ra,0xfffff
    800045b2:	f0c080e7          	jalr	-244(ra) # 800034ba <bread>
    800045b6:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800045b8:	40000613          	li	a2,1024
    800045bc:	05890593          	addi	a1,s2,88
    800045c0:	05850513          	addi	a0,a0,88
    800045c4:	ffffc097          	auipc	ra,0xffffc
    800045c8:	782080e7          	jalr	1922(ra) # 80000d46 <memmove>
    bwrite(dbuf);  // write dst to disk
    800045cc:	8526                	mv	a0,s1
    800045ce:	fffff097          	auipc	ra,0xfffff
    800045d2:	fde080e7          	jalr	-34(ra) # 800035ac <bwrite>
    if(recovering == 0)
    800045d6:	f80b1ce3          	bnez	s6,8000456e <install_trans+0x40>
    800045da:	b769                	j	80004564 <install_trans+0x36>
}
    800045dc:	70e2                	ld	ra,56(sp)
    800045de:	7442                	ld	s0,48(sp)
    800045e0:	74a2                	ld	s1,40(sp)
    800045e2:	7902                	ld	s2,32(sp)
    800045e4:	69e2                	ld	s3,24(sp)
    800045e6:	6a42                	ld	s4,16(sp)
    800045e8:	6aa2                	ld	s5,8(sp)
    800045ea:	6b02                	ld	s6,0(sp)
    800045ec:	6121                	addi	sp,sp,64
    800045ee:	8082                	ret
    800045f0:	8082                	ret

00000000800045f2 <initlog>:
{
    800045f2:	7179                	addi	sp,sp,-48
    800045f4:	f406                	sd	ra,40(sp)
    800045f6:	f022                	sd	s0,32(sp)
    800045f8:	ec26                	sd	s1,24(sp)
    800045fa:	e84a                	sd	s2,16(sp)
    800045fc:	e44e                	sd	s3,8(sp)
    800045fe:	1800                	addi	s0,sp,48
    80004600:	892a                	mv	s2,a0
    80004602:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004604:	0001e497          	auipc	s1,0x1e
    80004608:	21c48493          	addi	s1,s1,540 # 80022820 <log>
    8000460c:	00004597          	auipc	a1,0x4
    80004610:	17c58593          	addi	a1,a1,380 # 80008788 <syscalls+0x200>
    80004614:	8526                	mv	a0,s1
    80004616:	ffffc097          	auipc	ra,0xffffc
    8000461a:	544080e7          	jalr	1348(ra) # 80000b5a <initlock>
  log.start = sb->logstart;
    8000461e:	0149a583          	lw	a1,20(s3)
    80004622:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004624:	0109a783          	lw	a5,16(s3)
    80004628:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000462a:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000462e:	854a                	mv	a0,s2
    80004630:	fffff097          	auipc	ra,0xfffff
    80004634:	e8a080e7          	jalr	-374(ra) # 800034ba <bread>
  log.lh.n = lh->n;
    80004638:	4d3c                	lw	a5,88(a0)
    8000463a:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000463c:	02f05563          	blez	a5,80004666 <initlog+0x74>
    80004640:	05c50713          	addi	a4,a0,92
    80004644:	0001e697          	auipc	a3,0x1e
    80004648:	20c68693          	addi	a3,a3,524 # 80022850 <log+0x30>
    8000464c:	37fd                	addiw	a5,a5,-1
    8000464e:	1782                	slli	a5,a5,0x20
    80004650:	9381                	srli	a5,a5,0x20
    80004652:	078a                	slli	a5,a5,0x2
    80004654:	06050613          	addi	a2,a0,96
    80004658:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    8000465a:	4310                	lw	a2,0(a4)
    8000465c:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    8000465e:	0711                	addi	a4,a4,4
    80004660:	0691                	addi	a3,a3,4
    80004662:	fef71ce3          	bne	a4,a5,8000465a <initlog+0x68>
  brelse(buf);
    80004666:	fffff097          	auipc	ra,0xfffff
    8000466a:	f84080e7          	jalr	-124(ra) # 800035ea <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000466e:	4505                	li	a0,1
    80004670:	00000097          	auipc	ra,0x0
    80004674:	ebe080e7          	jalr	-322(ra) # 8000452e <install_trans>
  log.lh.n = 0;
    80004678:	0001e797          	auipc	a5,0x1e
    8000467c:	1c07aa23          	sw	zero,468(a5) # 8002284c <log+0x2c>
  write_head(); // clear the log
    80004680:	00000097          	auipc	ra,0x0
    80004684:	e34080e7          	jalr	-460(ra) # 800044b4 <write_head>
}
    80004688:	70a2                	ld	ra,40(sp)
    8000468a:	7402                	ld	s0,32(sp)
    8000468c:	64e2                	ld	s1,24(sp)
    8000468e:	6942                	ld	s2,16(sp)
    80004690:	69a2                	ld	s3,8(sp)
    80004692:	6145                	addi	sp,sp,48
    80004694:	8082                	ret

0000000080004696 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004696:	1101                	addi	sp,sp,-32
    80004698:	ec06                	sd	ra,24(sp)
    8000469a:	e822                	sd	s0,16(sp)
    8000469c:	e426                	sd	s1,8(sp)
    8000469e:	e04a                	sd	s2,0(sp)
    800046a0:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800046a2:	0001e517          	auipc	a0,0x1e
    800046a6:	17e50513          	addi	a0,a0,382 # 80022820 <log>
    800046aa:	ffffc097          	auipc	ra,0xffffc
    800046ae:	540080e7          	jalr	1344(ra) # 80000bea <acquire>
  while(1){
    if(log.committing){
    800046b2:	0001e497          	auipc	s1,0x1e
    800046b6:	16e48493          	addi	s1,s1,366 # 80022820 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800046ba:	4979                	li	s2,30
    800046bc:	a039                	j	800046ca <begin_op+0x34>
      sleep(&log, &log.lock);
    800046be:	85a6                	mv	a1,s1
    800046c0:	8526                	mv	a0,s1
    800046c2:	ffffe097          	auipc	ra,0xffffe
    800046c6:	b7e080e7          	jalr	-1154(ra) # 80002240 <sleep>
    if(log.committing){
    800046ca:	50dc                	lw	a5,36(s1)
    800046cc:	fbed                	bnez	a5,800046be <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800046ce:	509c                	lw	a5,32(s1)
    800046d0:	0017871b          	addiw	a4,a5,1
    800046d4:	0007069b          	sext.w	a3,a4
    800046d8:	0027179b          	slliw	a5,a4,0x2
    800046dc:	9fb9                	addw	a5,a5,a4
    800046de:	0017979b          	slliw	a5,a5,0x1
    800046e2:	54d8                	lw	a4,44(s1)
    800046e4:	9fb9                	addw	a5,a5,a4
    800046e6:	00f95963          	bge	s2,a5,800046f8 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800046ea:	85a6                	mv	a1,s1
    800046ec:	8526                	mv	a0,s1
    800046ee:	ffffe097          	auipc	ra,0xffffe
    800046f2:	b52080e7          	jalr	-1198(ra) # 80002240 <sleep>
    800046f6:	bfd1                	j	800046ca <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800046f8:	0001e517          	auipc	a0,0x1e
    800046fc:	12850513          	addi	a0,a0,296 # 80022820 <log>
    80004700:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004702:	ffffc097          	auipc	ra,0xffffc
    80004706:	59c080e7          	jalr	1436(ra) # 80000c9e <release>
      break;
    }
  }
}
    8000470a:	60e2                	ld	ra,24(sp)
    8000470c:	6442                	ld	s0,16(sp)
    8000470e:	64a2                	ld	s1,8(sp)
    80004710:	6902                	ld	s2,0(sp)
    80004712:	6105                	addi	sp,sp,32
    80004714:	8082                	ret

0000000080004716 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004716:	7139                	addi	sp,sp,-64
    80004718:	fc06                	sd	ra,56(sp)
    8000471a:	f822                	sd	s0,48(sp)
    8000471c:	f426                	sd	s1,40(sp)
    8000471e:	f04a                	sd	s2,32(sp)
    80004720:	ec4e                	sd	s3,24(sp)
    80004722:	e852                	sd	s4,16(sp)
    80004724:	e456                	sd	s5,8(sp)
    80004726:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004728:	0001e497          	auipc	s1,0x1e
    8000472c:	0f848493          	addi	s1,s1,248 # 80022820 <log>
    80004730:	8526                	mv	a0,s1
    80004732:	ffffc097          	auipc	ra,0xffffc
    80004736:	4b8080e7          	jalr	1208(ra) # 80000bea <acquire>
  log.outstanding -= 1;
    8000473a:	509c                	lw	a5,32(s1)
    8000473c:	37fd                	addiw	a5,a5,-1
    8000473e:	0007891b          	sext.w	s2,a5
    80004742:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004744:	50dc                	lw	a5,36(s1)
    80004746:	efb9                	bnez	a5,800047a4 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004748:	06091663          	bnez	s2,800047b4 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    8000474c:	0001e497          	auipc	s1,0x1e
    80004750:	0d448493          	addi	s1,s1,212 # 80022820 <log>
    80004754:	4785                	li	a5,1
    80004756:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004758:	8526                	mv	a0,s1
    8000475a:	ffffc097          	auipc	ra,0xffffc
    8000475e:	544080e7          	jalr	1348(ra) # 80000c9e <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004762:	54dc                	lw	a5,44(s1)
    80004764:	06f04763          	bgtz	a5,800047d2 <end_op+0xbc>
    acquire(&log.lock);
    80004768:	0001e497          	auipc	s1,0x1e
    8000476c:	0b848493          	addi	s1,s1,184 # 80022820 <log>
    80004770:	8526                	mv	a0,s1
    80004772:	ffffc097          	auipc	ra,0xffffc
    80004776:	478080e7          	jalr	1144(ra) # 80000bea <acquire>
    log.committing = 0;
    8000477a:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000477e:	8526                	mv	a0,s1
    80004780:	ffffe097          	auipc	ra,0xffffe
    80004784:	c9e080e7          	jalr	-866(ra) # 8000241e <wakeup>
    release(&log.lock);
    80004788:	8526                	mv	a0,s1
    8000478a:	ffffc097          	auipc	ra,0xffffc
    8000478e:	514080e7          	jalr	1300(ra) # 80000c9e <release>
}
    80004792:	70e2                	ld	ra,56(sp)
    80004794:	7442                	ld	s0,48(sp)
    80004796:	74a2                	ld	s1,40(sp)
    80004798:	7902                	ld	s2,32(sp)
    8000479a:	69e2                	ld	s3,24(sp)
    8000479c:	6a42                	ld	s4,16(sp)
    8000479e:	6aa2                	ld	s5,8(sp)
    800047a0:	6121                	addi	sp,sp,64
    800047a2:	8082                	ret
    panic("log.committing");
    800047a4:	00004517          	auipc	a0,0x4
    800047a8:	fec50513          	addi	a0,a0,-20 # 80008790 <syscalls+0x208>
    800047ac:	ffffc097          	auipc	ra,0xffffc
    800047b0:	d98080e7          	jalr	-616(ra) # 80000544 <panic>
    wakeup(&log);
    800047b4:	0001e497          	auipc	s1,0x1e
    800047b8:	06c48493          	addi	s1,s1,108 # 80022820 <log>
    800047bc:	8526                	mv	a0,s1
    800047be:	ffffe097          	auipc	ra,0xffffe
    800047c2:	c60080e7          	jalr	-928(ra) # 8000241e <wakeup>
  release(&log.lock);
    800047c6:	8526                	mv	a0,s1
    800047c8:	ffffc097          	auipc	ra,0xffffc
    800047cc:	4d6080e7          	jalr	1238(ra) # 80000c9e <release>
  if(do_commit){
    800047d0:	b7c9                	j	80004792 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800047d2:	0001ea97          	auipc	s5,0x1e
    800047d6:	07ea8a93          	addi	s5,s5,126 # 80022850 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800047da:	0001ea17          	auipc	s4,0x1e
    800047de:	046a0a13          	addi	s4,s4,70 # 80022820 <log>
    800047e2:	018a2583          	lw	a1,24(s4)
    800047e6:	012585bb          	addw	a1,a1,s2
    800047ea:	2585                	addiw	a1,a1,1
    800047ec:	028a2503          	lw	a0,40(s4)
    800047f0:	fffff097          	auipc	ra,0xfffff
    800047f4:	cca080e7          	jalr	-822(ra) # 800034ba <bread>
    800047f8:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800047fa:	000aa583          	lw	a1,0(s5)
    800047fe:	028a2503          	lw	a0,40(s4)
    80004802:	fffff097          	auipc	ra,0xfffff
    80004806:	cb8080e7          	jalr	-840(ra) # 800034ba <bread>
    8000480a:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000480c:	40000613          	li	a2,1024
    80004810:	05850593          	addi	a1,a0,88
    80004814:	05848513          	addi	a0,s1,88
    80004818:	ffffc097          	auipc	ra,0xffffc
    8000481c:	52e080e7          	jalr	1326(ra) # 80000d46 <memmove>
    bwrite(to);  // write the log
    80004820:	8526                	mv	a0,s1
    80004822:	fffff097          	auipc	ra,0xfffff
    80004826:	d8a080e7          	jalr	-630(ra) # 800035ac <bwrite>
    brelse(from);
    8000482a:	854e                	mv	a0,s3
    8000482c:	fffff097          	auipc	ra,0xfffff
    80004830:	dbe080e7          	jalr	-578(ra) # 800035ea <brelse>
    brelse(to);
    80004834:	8526                	mv	a0,s1
    80004836:	fffff097          	auipc	ra,0xfffff
    8000483a:	db4080e7          	jalr	-588(ra) # 800035ea <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000483e:	2905                	addiw	s2,s2,1
    80004840:	0a91                	addi	s5,s5,4
    80004842:	02ca2783          	lw	a5,44(s4)
    80004846:	f8f94ee3          	blt	s2,a5,800047e2 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000484a:	00000097          	auipc	ra,0x0
    8000484e:	c6a080e7          	jalr	-918(ra) # 800044b4 <write_head>
    install_trans(0); // Now install writes to home locations
    80004852:	4501                	li	a0,0
    80004854:	00000097          	auipc	ra,0x0
    80004858:	cda080e7          	jalr	-806(ra) # 8000452e <install_trans>
    log.lh.n = 0;
    8000485c:	0001e797          	auipc	a5,0x1e
    80004860:	fe07a823          	sw	zero,-16(a5) # 8002284c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004864:	00000097          	auipc	ra,0x0
    80004868:	c50080e7          	jalr	-944(ra) # 800044b4 <write_head>
    8000486c:	bdf5                	j	80004768 <end_op+0x52>

000000008000486e <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000486e:	1101                	addi	sp,sp,-32
    80004870:	ec06                	sd	ra,24(sp)
    80004872:	e822                	sd	s0,16(sp)
    80004874:	e426                	sd	s1,8(sp)
    80004876:	e04a                	sd	s2,0(sp)
    80004878:	1000                	addi	s0,sp,32
    8000487a:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000487c:	0001e917          	auipc	s2,0x1e
    80004880:	fa490913          	addi	s2,s2,-92 # 80022820 <log>
    80004884:	854a                	mv	a0,s2
    80004886:	ffffc097          	auipc	ra,0xffffc
    8000488a:	364080e7          	jalr	868(ra) # 80000bea <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000488e:	02c92603          	lw	a2,44(s2)
    80004892:	47f5                	li	a5,29
    80004894:	06c7c563          	blt	a5,a2,800048fe <log_write+0x90>
    80004898:	0001e797          	auipc	a5,0x1e
    8000489c:	fa47a783          	lw	a5,-92(a5) # 8002283c <log+0x1c>
    800048a0:	37fd                	addiw	a5,a5,-1
    800048a2:	04f65e63          	bge	a2,a5,800048fe <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800048a6:	0001e797          	auipc	a5,0x1e
    800048aa:	f9a7a783          	lw	a5,-102(a5) # 80022840 <log+0x20>
    800048ae:	06f05063          	blez	a5,8000490e <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800048b2:	4781                	li	a5,0
    800048b4:	06c05563          	blez	a2,8000491e <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800048b8:	44cc                	lw	a1,12(s1)
    800048ba:	0001e717          	auipc	a4,0x1e
    800048be:	f9670713          	addi	a4,a4,-106 # 80022850 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800048c2:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800048c4:	4314                	lw	a3,0(a4)
    800048c6:	04b68c63          	beq	a3,a1,8000491e <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800048ca:	2785                	addiw	a5,a5,1
    800048cc:	0711                	addi	a4,a4,4
    800048ce:	fef61be3          	bne	a2,a5,800048c4 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800048d2:	0621                	addi	a2,a2,8
    800048d4:	060a                	slli	a2,a2,0x2
    800048d6:	0001e797          	auipc	a5,0x1e
    800048da:	f4a78793          	addi	a5,a5,-182 # 80022820 <log>
    800048de:	963e                	add	a2,a2,a5
    800048e0:	44dc                	lw	a5,12(s1)
    800048e2:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800048e4:	8526                	mv	a0,s1
    800048e6:	fffff097          	auipc	ra,0xfffff
    800048ea:	da2080e7          	jalr	-606(ra) # 80003688 <bpin>
    log.lh.n++;
    800048ee:	0001e717          	auipc	a4,0x1e
    800048f2:	f3270713          	addi	a4,a4,-206 # 80022820 <log>
    800048f6:	575c                	lw	a5,44(a4)
    800048f8:	2785                	addiw	a5,a5,1
    800048fa:	d75c                	sw	a5,44(a4)
    800048fc:	a835                	j	80004938 <log_write+0xca>
    panic("too big a transaction");
    800048fe:	00004517          	auipc	a0,0x4
    80004902:	ea250513          	addi	a0,a0,-350 # 800087a0 <syscalls+0x218>
    80004906:	ffffc097          	auipc	ra,0xffffc
    8000490a:	c3e080e7          	jalr	-962(ra) # 80000544 <panic>
    panic("log_write outside of trans");
    8000490e:	00004517          	auipc	a0,0x4
    80004912:	eaa50513          	addi	a0,a0,-342 # 800087b8 <syscalls+0x230>
    80004916:	ffffc097          	auipc	ra,0xffffc
    8000491a:	c2e080e7          	jalr	-978(ra) # 80000544 <panic>
  log.lh.block[i] = b->blockno;
    8000491e:	00878713          	addi	a4,a5,8
    80004922:	00271693          	slli	a3,a4,0x2
    80004926:	0001e717          	auipc	a4,0x1e
    8000492a:	efa70713          	addi	a4,a4,-262 # 80022820 <log>
    8000492e:	9736                	add	a4,a4,a3
    80004930:	44d4                	lw	a3,12(s1)
    80004932:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004934:	faf608e3          	beq	a2,a5,800048e4 <log_write+0x76>
  }
  release(&log.lock);
    80004938:	0001e517          	auipc	a0,0x1e
    8000493c:	ee850513          	addi	a0,a0,-280 # 80022820 <log>
    80004940:	ffffc097          	auipc	ra,0xffffc
    80004944:	35e080e7          	jalr	862(ra) # 80000c9e <release>
}
    80004948:	60e2                	ld	ra,24(sp)
    8000494a:	6442                	ld	s0,16(sp)
    8000494c:	64a2                	ld	s1,8(sp)
    8000494e:	6902                	ld	s2,0(sp)
    80004950:	6105                	addi	sp,sp,32
    80004952:	8082                	ret

0000000080004954 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004954:	1101                	addi	sp,sp,-32
    80004956:	ec06                	sd	ra,24(sp)
    80004958:	e822                	sd	s0,16(sp)
    8000495a:	e426                	sd	s1,8(sp)
    8000495c:	e04a                	sd	s2,0(sp)
    8000495e:	1000                	addi	s0,sp,32
    80004960:	84aa                	mv	s1,a0
    80004962:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004964:	00004597          	auipc	a1,0x4
    80004968:	e7458593          	addi	a1,a1,-396 # 800087d8 <syscalls+0x250>
    8000496c:	0521                	addi	a0,a0,8
    8000496e:	ffffc097          	auipc	ra,0xffffc
    80004972:	1ec080e7          	jalr	492(ra) # 80000b5a <initlock>
  lk->name = name;
    80004976:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000497a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000497e:	0204a423          	sw	zero,40(s1)
}
    80004982:	60e2                	ld	ra,24(sp)
    80004984:	6442                	ld	s0,16(sp)
    80004986:	64a2                	ld	s1,8(sp)
    80004988:	6902                	ld	s2,0(sp)
    8000498a:	6105                	addi	sp,sp,32
    8000498c:	8082                	ret

000000008000498e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000498e:	1101                	addi	sp,sp,-32
    80004990:	ec06                	sd	ra,24(sp)
    80004992:	e822                	sd	s0,16(sp)
    80004994:	e426                	sd	s1,8(sp)
    80004996:	e04a                	sd	s2,0(sp)
    80004998:	1000                	addi	s0,sp,32
    8000499a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000499c:	00850913          	addi	s2,a0,8
    800049a0:	854a                	mv	a0,s2
    800049a2:	ffffc097          	auipc	ra,0xffffc
    800049a6:	248080e7          	jalr	584(ra) # 80000bea <acquire>
  while (lk->locked) {
    800049aa:	409c                	lw	a5,0(s1)
    800049ac:	cb89                	beqz	a5,800049be <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800049ae:	85ca                	mv	a1,s2
    800049b0:	8526                	mv	a0,s1
    800049b2:	ffffe097          	auipc	ra,0xffffe
    800049b6:	88e080e7          	jalr	-1906(ra) # 80002240 <sleep>
  while (lk->locked) {
    800049ba:	409c                	lw	a5,0(s1)
    800049bc:	fbed                	bnez	a5,800049ae <acquiresleep+0x20>
  }
  lk->locked = 1;
    800049be:	4785                	li	a5,1
    800049c0:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800049c2:	ffffd097          	auipc	ra,0xffffd
    800049c6:	10e080e7          	jalr	270(ra) # 80001ad0 <myproc>
    800049ca:	5d1c                	lw	a5,56(a0)
    800049cc:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800049ce:	854a                	mv	a0,s2
    800049d0:	ffffc097          	auipc	ra,0xffffc
    800049d4:	2ce080e7          	jalr	718(ra) # 80000c9e <release>
}
    800049d8:	60e2                	ld	ra,24(sp)
    800049da:	6442                	ld	s0,16(sp)
    800049dc:	64a2                	ld	s1,8(sp)
    800049de:	6902                	ld	s2,0(sp)
    800049e0:	6105                	addi	sp,sp,32
    800049e2:	8082                	ret

00000000800049e4 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800049e4:	1101                	addi	sp,sp,-32
    800049e6:	ec06                	sd	ra,24(sp)
    800049e8:	e822                	sd	s0,16(sp)
    800049ea:	e426                	sd	s1,8(sp)
    800049ec:	e04a                	sd	s2,0(sp)
    800049ee:	1000                	addi	s0,sp,32
    800049f0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800049f2:	00850913          	addi	s2,a0,8
    800049f6:	854a                	mv	a0,s2
    800049f8:	ffffc097          	auipc	ra,0xffffc
    800049fc:	1f2080e7          	jalr	498(ra) # 80000bea <acquire>
  lk->locked = 0;
    80004a00:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004a04:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004a08:	8526                	mv	a0,s1
    80004a0a:	ffffe097          	auipc	ra,0xffffe
    80004a0e:	a14080e7          	jalr	-1516(ra) # 8000241e <wakeup>
  release(&lk->lk);
    80004a12:	854a                	mv	a0,s2
    80004a14:	ffffc097          	auipc	ra,0xffffc
    80004a18:	28a080e7          	jalr	650(ra) # 80000c9e <release>
}
    80004a1c:	60e2                	ld	ra,24(sp)
    80004a1e:	6442                	ld	s0,16(sp)
    80004a20:	64a2                	ld	s1,8(sp)
    80004a22:	6902                	ld	s2,0(sp)
    80004a24:	6105                	addi	sp,sp,32
    80004a26:	8082                	ret

0000000080004a28 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004a28:	7179                	addi	sp,sp,-48
    80004a2a:	f406                	sd	ra,40(sp)
    80004a2c:	f022                	sd	s0,32(sp)
    80004a2e:	ec26                	sd	s1,24(sp)
    80004a30:	e84a                	sd	s2,16(sp)
    80004a32:	e44e                	sd	s3,8(sp)
    80004a34:	1800                	addi	s0,sp,48
    80004a36:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004a38:	00850913          	addi	s2,a0,8
    80004a3c:	854a                	mv	a0,s2
    80004a3e:	ffffc097          	auipc	ra,0xffffc
    80004a42:	1ac080e7          	jalr	428(ra) # 80000bea <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004a46:	409c                	lw	a5,0(s1)
    80004a48:	ef99                	bnez	a5,80004a66 <holdingsleep+0x3e>
    80004a4a:	4481                	li	s1,0
  release(&lk->lk);
    80004a4c:	854a                	mv	a0,s2
    80004a4e:	ffffc097          	auipc	ra,0xffffc
    80004a52:	250080e7          	jalr	592(ra) # 80000c9e <release>
  return r;
}
    80004a56:	8526                	mv	a0,s1
    80004a58:	70a2                	ld	ra,40(sp)
    80004a5a:	7402                	ld	s0,32(sp)
    80004a5c:	64e2                	ld	s1,24(sp)
    80004a5e:	6942                	ld	s2,16(sp)
    80004a60:	69a2                	ld	s3,8(sp)
    80004a62:	6145                	addi	sp,sp,48
    80004a64:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004a66:	0284a983          	lw	s3,40(s1)
    80004a6a:	ffffd097          	auipc	ra,0xffffd
    80004a6e:	066080e7          	jalr	102(ra) # 80001ad0 <myproc>
    80004a72:	5d04                	lw	s1,56(a0)
    80004a74:	413484b3          	sub	s1,s1,s3
    80004a78:	0014b493          	seqz	s1,s1
    80004a7c:	bfc1                	j	80004a4c <holdingsleep+0x24>

0000000080004a7e <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004a7e:	1141                	addi	sp,sp,-16
    80004a80:	e406                	sd	ra,8(sp)
    80004a82:	e022                	sd	s0,0(sp)
    80004a84:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004a86:	00004597          	auipc	a1,0x4
    80004a8a:	d6258593          	addi	a1,a1,-670 # 800087e8 <syscalls+0x260>
    80004a8e:	0001e517          	auipc	a0,0x1e
    80004a92:	eda50513          	addi	a0,a0,-294 # 80022968 <ftable>
    80004a96:	ffffc097          	auipc	ra,0xffffc
    80004a9a:	0c4080e7          	jalr	196(ra) # 80000b5a <initlock>
}
    80004a9e:	60a2                	ld	ra,8(sp)
    80004aa0:	6402                	ld	s0,0(sp)
    80004aa2:	0141                	addi	sp,sp,16
    80004aa4:	8082                	ret

0000000080004aa6 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004aa6:	1101                	addi	sp,sp,-32
    80004aa8:	ec06                	sd	ra,24(sp)
    80004aaa:	e822                	sd	s0,16(sp)
    80004aac:	e426                	sd	s1,8(sp)
    80004aae:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004ab0:	0001e517          	auipc	a0,0x1e
    80004ab4:	eb850513          	addi	a0,a0,-328 # 80022968 <ftable>
    80004ab8:	ffffc097          	auipc	ra,0xffffc
    80004abc:	132080e7          	jalr	306(ra) # 80000bea <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004ac0:	0001e497          	auipc	s1,0x1e
    80004ac4:	ec048493          	addi	s1,s1,-320 # 80022980 <ftable+0x18>
    80004ac8:	0001f717          	auipc	a4,0x1f
    80004acc:	e5870713          	addi	a4,a4,-424 # 80023920 <disk>
    if(f->ref == 0){
    80004ad0:	40dc                	lw	a5,4(s1)
    80004ad2:	cf99                	beqz	a5,80004af0 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004ad4:	02848493          	addi	s1,s1,40
    80004ad8:	fee49ce3          	bne	s1,a4,80004ad0 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004adc:	0001e517          	auipc	a0,0x1e
    80004ae0:	e8c50513          	addi	a0,a0,-372 # 80022968 <ftable>
    80004ae4:	ffffc097          	auipc	ra,0xffffc
    80004ae8:	1ba080e7          	jalr	442(ra) # 80000c9e <release>
  return 0;
    80004aec:	4481                	li	s1,0
    80004aee:	a819                	j	80004b04 <filealloc+0x5e>
      f->ref = 1;
    80004af0:	4785                	li	a5,1
    80004af2:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004af4:	0001e517          	auipc	a0,0x1e
    80004af8:	e7450513          	addi	a0,a0,-396 # 80022968 <ftable>
    80004afc:	ffffc097          	auipc	ra,0xffffc
    80004b00:	1a2080e7          	jalr	418(ra) # 80000c9e <release>
}
    80004b04:	8526                	mv	a0,s1
    80004b06:	60e2                	ld	ra,24(sp)
    80004b08:	6442                	ld	s0,16(sp)
    80004b0a:	64a2                	ld	s1,8(sp)
    80004b0c:	6105                	addi	sp,sp,32
    80004b0e:	8082                	ret

0000000080004b10 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004b10:	1101                	addi	sp,sp,-32
    80004b12:	ec06                	sd	ra,24(sp)
    80004b14:	e822                	sd	s0,16(sp)
    80004b16:	e426                	sd	s1,8(sp)
    80004b18:	1000                	addi	s0,sp,32
    80004b1a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004b1c:	0001e517          	auipc	a0,0x1e
    80004b20:	e4c50513          	addi	a0,a0,-436 # 80022968 <ftable>
    80004b24:	ffffc097          	auipc	ra,0xffffc
    80004b28:	0c6080e7          	jalr	198(ra) # 80000bea <acquire>
  if(f->ref < 1)
    80004b2c:	40dc                	lw	a5,4(s1)
    80004b2e:	02f05263          	blez	a5,80004b52 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004b32:	2785                	addiw	a5,a5,1
    80004b34:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004b36:	0001e517          	auipc	a0,0x1e
    80004b3a:	e3250513          	addi	a0,a0,-462 # 80022968 <ftable>
    80004b3e:	ffffc097          	auipc	ra,0xffffc
    80004b42:	160080e7          	jalr	352(ra) # 80000c9e <release>
  return f;
}
    80004b46:	8526                	mv	a0,s1
    80004b48:	60e2                	ld	ra,24(sp)
    80004b4a:	6442                	ld	s0,16(sp)
    80004b4c:	64a2                	ld	s1,8(sp)
    80004b4e:	6105                	addi	sp,sp,32
    80004b50:	8082                	ret
    panic("filedup");
    80004b52:	00004517          	auipc	a0,0x4
    80004b56:	c9e50513          	addi	a0,a0,-866 # 800087f0 <syscalls+0x268>
    80004b5a:	ffffc097          	auipc	ra,0xffffc
    80004b5e:	9ea080e7          	jalr	-1558(ra) # 80000544 <panic>

0000000080004b62 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004b62:	7139                	addi	sp,sp,-64
    80004b64:	fc06                	sd	ra,56(sp)
    80004b66:	f822                	sd	s0,48(sp)
    80004b68:	f426                	sd	s1,40(sp)
    80004b6a:	f04a                	sd	s2,32(sp)
    80004b6c:	ec4e                	sd	s3,24(sp)
    80004b6e:	e852                	sd	s4,16(sp)
    80004b70:	e456                	sd	s5,8(sp)
    80004b72:	0080                	addi	s0,sp,64
    80004b74:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004b76:	0001e517          	auipc	a0,0x1e
    80004b7a:	df250513          	addi	a0,a0,-526 # 80022968 <ftable>
    80004b7e:	ffffc097          	auipc	ra,0xffffc
    80004b82:	06c080e7          	jalr	108(ra) # 80000bea <acquire>
  if(f->ref < 1)
    80004b86:	40dc                	lw	a5,4(s1)
    80004b88:	06f05163          	blez	a5,80004bea <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004b8c:	37fd                	addiw	a5,a5,-1
    80004b8e:	0007871b          	sext.w	a4,a5
    80004b92:	c0dc                	sw	a5,4(s1)
    80004b94:	06e04363          	bgtz	a4,80004bfa <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004b98:	0004a903          	lw	s2,0(s1)
    80004b9c:	0094ca83          	lbu	s5,9(s1)
    80004ba0:	0104ba03          	ld	s4,16(s1)
    80004ba4:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004ba8:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004bac:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004bb0:	0001e517          	auipc	a0,0x1e
    80004bb4:	db850513          	addi	a0,a0,-584 # 80022968 <ftable>
    80004bb8:	ffffc097          	auipc	ra,0xffffc
    80004bbc:	0e6080e7          	jalr	230(ra) # 80000c9e <release>

  if(ff.type == FD_PIPE){
    80004bc0:	4785                	li	a5,1
    80004bc2:	04f90d63          	beq	s2,a5,80004c1c <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004bc6:	3979                	addiw	s2,s2,-2
    80004bc8:	4785                	li	a5,1
    80004bca:	0527e063          	bltu	a5,s2,80004c0a <fileclose+0xa8>
    begin_op();
    80004bce:	00000097          	auipc	ra,0x0
    80004bd2:	ac8080e7          	jalr	-1336(ra) # 80004696 <begin_op>
    iput(ff.ip);
    80004bd6:	854e                	mv	a0,s3
    80004bd8:	fffff097          	auipc	ra,0xfffff
    80004bdc:	2b6080e7          	jalr	694(ra) # 80003e8e <iput>
    end_op();
    80004be0:	00000097          	auipc	ra,0x0
    80004be4:	b36080e7          	jalr	-1226(ra) # 80004716 <end_op>
    80004be8:	a00d                	j	80004c0a <fileclose+0xa8>
    panic("fileclose");
    80004bea:	00004517          	auipc	a0,0x4
    80004bee:	c0e50513          	addi	a0,a0,-1010 # 800087f8 <syscalls+0x270>
    80004bf2:	ffffc097          	auipc	ra,0xffffc
    80004bf6:	952080e7          	jalr	-1710(ra) # 80000544 <panic>
    release(&ftable.lock);
    80004bfa:	0001e517          	auipc	a0,0x1e
    80004bfe:	d6e50513          	addi	a0,a0,-658 # 80022968 <ftable>
    80004c02:	ffffc097          	auipc	ra,0xffffc
    80004c06:	09c080e7          	jalr	156(ra) # 80000c9e <release>
  }
}
    80004c0a:	70e2                	ld	ra,56(sp)
    80004c0c:	7442                	ld	s0,48(sp)
    80004c0e:	74a2                	ld	s1,40(sp)
    80004c10:	7902                	ld	s2,32(sp)
    80004c12:	69e2                	ld	s3,24(sp)
    80004c14:	6a42                	ld	s4,16(sp)
    80004c16:	6aa2                	ld	s5,8(sp)
    80004c18:	6121                	addi	sp,sp,64
    80004c1a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004c1c:	85d6                	mv	a1,s5
    80004c1e:	8552                	mv	a0,s4
    80004c20:	00000097          	auipc	ra,0x0
    80004c24:	34c080e7          	jalr	844(ra) # 80004f6c <pipeclose>
    80004c28:	b7cd                	j	80004c0a <fileclose+0xa8>

0000000080004c2a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004c2a:	715d                	addi	sp,sp,-80
    80004c2c:	e486                	sd	ra,72(sp)
    80004c2e:	e0a2                	sd	s0,64(sp)
    80004c30:	fc26                	sd	s1,56(sp)
    80004c32:	f84a                	sd	s2,48(sp)
    80004c34:	f44e                	sd	s3,40(sp)
    80004c36:	0880                	addi	s0,sp,80
    80004c38:	84aa                	mv	s1,a0
    80004c3a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004c3c:	ffffd097          	auipc	ra,0xffffd
    80004c40:	e94080e7          	jalr	-364(ra) # 80001ad0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004c44:	409c                	lw	a5,0(s1)
    80004c46:	37f9                	addiw	a5,a5,-2
    80004c48:	4705                	li	a4,1
    80004c4a:	04f76763          	bltu	a4,a5,80004c98 <filestat+0x6e>
    80004c4e:	892a                	mv	s2,a0
    ilock(f->ip);
    80004c50:	6c88                	ld	a0,24(s1)
    80004c52:	fffff097          	auipc	ra,0xfffff
    80004c56:	082080e7          	jalr	130(ra) # 80003cd4 <ilock>
    stati(f->ip, &st);
    80004c5a:	fb840593          	addi	a1,s0,-72
    80004c5e:	6c88                	ld	a0,24(s1)
    80004c60:	fffff097          	auipc	ra,0xfffff
    80004c64:	2fe080e7          	jalr	766(ra) # 80003f5e <stati>
    iunlock(f->ip);
    80004c68:	6c88                	ld	a0,24(s1)
    80004c6a:	fffff097          	auipc	ra,0xfffff
    80004c6e:	12c080e7          	jalr	300(ra) # 80003d96 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004c72:	46e1                	li	a3,24
    80004c74:	fb840613          	addi	a2,s0,-72
    80004c78:	85ce                	mv	a1,s3
    80004c7a:	05893503          	ld	a0,88(s2)
    80004c7e:	ffffd097          	auipc	ra,0xffffd
    80004c82:	a06080e7          	jalr	-1530(ra) # 80001684 <copyout>
    80004c86:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004c8a:	60a6                	ld	ra,72(sp)
    80004c8c:	6406                	ld	s0,64(sp)
    80004c8e:	74e2                	ld	s1,56(sp)
    80004c90:	7942                	ld	s2,48(sp)
    80004c92:	79a2                	ld	s3,40(sp)
    80004c94:	6161                	addi	sp,sp,80
    80004c96:	8082                	ret
  return -1;
    80004c98:	557d                	li	a0,-1
    80004c9a:	bfc5                	j	80004c8a <filestat+0x60>

0000000080004c9c <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004c9c:	7179                	addi	sp,sp,-48
    80004c9e:	f406                	sd	ra,40(sp)
    80004ca0:	f022                	sd	s0,32(sp)
    80004ca2:	ec26                	sd	s1,24(sp)
    80004ca4:	e84a                	sd	s2,16(sp)
    80004ca6:	e44e                	sd	s3,8(sp)
    80004ca8:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004caa:	00854783          	lbu	a5,8(a0)
    80004cae:	c3d5                	beqz	a5,80004d52 <fileread+0xb6>
    80004cb0:	84aa                	mv	s1,a0
    80004cb2:	89ae                	mv	s3,a1
    80004cb4:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004cb6:	411c                	lw	a5,0(a0)
    80004cb8:	4705                	li	a4,1
    80004cba:	04e78963          	beq	a5,a4,80004d0c <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004cbe:	470d                	li	a4,3
    80004cc0:	04e78d63          	beq	a5,a4,80004d1a <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004cc4:	4709                	li	a4,2
    80004cc6:	06e79e63          	bne	a5,a4,80004d42 <fileread+0xa6>
    ilock(f->ip);
    80004cca:	6d08                	ld	a0,24(a0)
    80004ccc:	fffff097          	auipc	ra,0xfffff
    80004cd0:	008080e7          	jalr	8(ra) # 80003cd4 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004cd4:	874a                	mv	a4,s2
    80004cd6:	5094                	lw	a3,32(s1)
    80004cd8:	864e                	mv	a2,s3
    80004cda:	4585                	li	a1,1
    80004cdc:	6c88                	ld	a0,24(s1)
    80004cde:	fffff097          	auipc	ra,0xfffff
    80004ce2:	2aa080e7          	jalr	682(ra) # 80003f88 <readi>
    80004ce6:	892a                	mv	s2,a0
    80004ce8:	00a05563          	blez	a0,80004cf2 <fileread+0x56>
      f->off += r;
    80004cec:	509c                	lw	a5,32(s1)
    80004cee:	9fa9                	addw	a5,a5,a0
    80004cf0:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004cf2:	6c88                	ld	a0,24(s1)
    80004cf4:	fffff097          	auipc	ra,0xfffff
    80004cf8:	0a2080e7          	jalr	162(ra) # 80003d96 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004cfc:	854a                	mv	a0,s2
    80004cfe:	70a2                	ld	ra,40(sp)
    80004d00:	7402                	ld	s0,32(sp)
    80004d02:	64e2                	ld	s1,24(sp)
    80004d04:	6942                	ld	s2,16(sp)
    80004d06:	69a2                	ld	s3,8(sp)
    80004d08:	6145                	addi	sp,sp,48
    80004d0a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004d0c:	6908                	ld	a0,16(a0)
    80004d0e:	00000097          	auipc	ra,0x0
    80004d12:	3ce080e7          	jalr	974(ra) # 800050dc <piperead>
    80004d16:	892a                	mv	s2,a0
    80004d18:	b7d5                	j	80004cfc <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004d1a:	02451783          	lh	a5,36(a0)
    80004d1e:	03079693          	slli	a3,a5,0x30
    80004d22:	92c1                	srli	a3,a3,0x30
    80004d24:	4725                	li	a4,9
    80004d26:	02d76863          	bltu	a4,a3,80004d56 <fileread+0xba>
    80004d2a:	0792                	slli	a5,a5,0x4
    80004d2c:	0001e717          	auipc	a4,0x1e
    80004d30:	b9c70713          	addi	a4,a4,-1124 # 800228c8 <devsw>
    80004d34:	97ba                	add	a5,a5,a4
    80004d36:	639c                	ld	a5,0(a5)
    80004d38:	c38d                	beqz	a5,80004d5a <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004d3a:	4505                	li	a0,1
    80004d3c:	9782                	jalr	a5
    80004d3e:	892a                	mv	s2,a0
    80004d40:	bf75                	j	80004cfc <fileread+0x60>
    panic("fileread");
    80004d42:	00004517          	auipc	a0,0x4
    80004d46:	ac650513          	addi	a0,a0,-1338 # 80008808 <syscalls+0x280>
    80004d4a:	ffffb097          	auipc	ra,0xffffb
    80004d4e:	7fa080e7          	jalr	2042(ra) # 80000544 <panic>
    return -1;
    80004d52:	597d                	li	s2,-1
    80004d54:	b765                	j	80004cfc <fileread+0x60>
      return -1;
    80004d56:	597d                	li	s2,-1
    80004d58:	b755                	j	80004cfc <fileread+0x60>
    80004d5a:	597d                	li	s2,-1
    80004d5c:	b745                	j	80004cfc <fileread+0x60>

0000000080004d5e <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004d5e:	715d                	addi	sp,sp,-80
    80004d60:	e486                	sd	ra,72(sp)
    80004d62:	e0a2                	sd	s0,64(sp)
    80004d64:	fc26                	sd	s1,56(sp)
    80004d66:	f84a                	sd	s2,48(sp)
    80004d68:	f44e                	sd	s3,40(sp)
    80004d6a:	f052                	sd	s4,32(sp)
    80004d6c:	ec56                	sd	s5,24(sp)
    80004d6e:	e85a                	sd	s6,16(sp)
    80004d70:	e45e                	sd	s7,8(sp)
    80004d72:	e062                	sd	s8,0(sp)
    80004d74:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004d76:	00954783          	lbu	a5,9(a0)
    80004d7a:	10078663          	beqz	a5,80004e86 <filewrite+0x128>
    80004d7e:	892a                	mv	s2,a0
    80004d80:	8aae                	mv	s5,a1
    80004d82:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004d84:	411c                	lw	a5,0(a0)
    80004d86:	4705                	li	a4,1
    80004d88:	02e78263          	beq	a5,a4,80004dac <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004d8c:	470d                	li	a4,3
    80004d8e:	02e78663          	beq	a5,a4,80004dba <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004d92:	4709                	li	a4,2
    80004d94:	0ee79163          	bne	a5,a4,80004e76 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004d98:	0ac05d63          	blez	a2,80004e52 <filewrite+0xf4>
    int i = 0;
    80004d9c:	4981                	li	s3,0
    80004d9e:	6b05                	lui	s6,0x1
    80004da0:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004da4:	6b85                	lui	s7,0x1
    80004da6:	c00b8b9b          	addiw	s7,s7,-1024
    80004daa:	a861                	j	80004e42 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004dac:	6908                	ld	a0,16(a0)
    80004dae:	00000097          	auipc	ra,0x0
    80004db2:	22e080e7          	jalr	558(ra) # 80004fdc <pipewrite>
    80004db6:	8a2a                	mv	s4,a0
    80004db8:	a045                	j	80004e58 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004dba:	02451783          	lh	a5,36(a0)
    80004dbe:	03079693          	slli	a3,a5,0x30
    80004dc2:	92c1                	srli	a3,a3,0x30
    80004dc4:	4725                	li	a4,9
    80004dc6:	0cd76263          	bltu	a4,a3,80004e8a <filewrite+0x12c>
    80004dca:	0792                	slli	a5,a5,0x4
    80004dcc:	0001e717          	auipc	a4,0x1e
    80004dd0:	afc70713          	addi	a4,a4,-1284 # 800228c8 <devsw>
    80004dd4:	97ba                	add	a5,a5,a4
    80004dd6:	679c                	ld	a5,8(a5)
    80004dd8:	cbdd                	beqz	a5,80004e8e <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004dda:	4505                	li	a0,1
    80004ddc:	9782                	jalr	a5
    80004dde:	8a2a                	mv	s4,a0
    80004de0:	a8a5                	j	80004e58 <filewrite+0xfa>
    80004de2:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004de6:	00000097          	auipc	ra,0x0
    80004dea:	8b0080e7          	jalr	-1872(ra) # 80004696 <begin_op>
      ilock(f->ip);
    80004dee:	01893503          	ld	a0,24(s2)
    80004df2:	fffff097          	auipc	ra,0xfffff
    80004df6:	ee2080e7          	jalr	-286(ra) # 80003cd4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004dfa:	8762                	mv	a4,s8
    80004dfc:	02092683          	lw	a3,32(s2)
    80004e00:	01598633          	add	a2,s3,s5
    80004e04:	4585                	li	a1,1
    80004e06:	01893503          	ld	a0,24(s2)
    80004e0a:	fffff097          	auipc	ra,0xfffff
    80004e0e:	276080e7          	jalr	630(ra) # 80004080 <writei>
    80004e12:	84aa                	mv	s1,a0
    80004e14:	00a05763          	blez	a0,80004e22 <filewrite+0xc4>
        f->off += r;
    80004e18:	02092783          	lw	a5,32(s2)
    80004e1c:	9fa9                	addw	a5,a5,a0
    80004e1e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004e22:	01893503          	ld	a0,24(s2)
    80004e26:	fffff097          	auipc	ra,0xfffff
    80004e2a:	f70080e7          	jalr	-144(ra) # 80003d96 <iunlock>
      end_op();
    80004e2e:	00000097          	auipc	ra,0x0
    80004e32:	8e8080e7          	jalr	-1816(ra) # 80004716 <end_op>

      if(r != n1){
    80004e36:	009c1f63          	bne	s8,s1,80004e54 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004e3a:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004e3e:	0149db63          	bge	s3,s4,80004e54 <filewrite+0xf6>
      int n1 = n - i;
    80004e42:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004e46:	84be                	mv	s1,a5
    80004e48:	2781                	sext.w	a5,a5
    80004e4a:	f8fb5ce3          	bge	s6,a5,80004de2 <filewrite+0x84>
    80004e4e:	84de                	mv	s1,s7
    80004e50:	bf49                	j	80004de2 <filewrite+0x84>
    int i = 0;
    80004e52:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004e54:	013a1f63          	bne	s4,s3,80004e72 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004e58:	8552                	mv	a0,s4
    80004e5a:	60a6                	ld	ra,72(sp)
    80004e5c:	6406                	ld	s0,64(sp)
    80004e5e:	74e2                	ld	s1,56(sp)
    80004e60:	7942                	ld	s2,48(sp)
    80004e62:	79a2                	ld	s3,40(sp)
    80004e64:	7a02                	ld	s4,32(sp)
    80004e66:	6ae2                	ld	s5,24(sp)
    80004e68:	6b42                	ld	s6,16(sp)
    80004e6a:	6ba2                	ld	s7,8(sp)
    80004e6c:	6c02                	ld	s8,0(sp)
    80004e6e:	6161                	addi	sp,sp,80
    80004e70:	8082                	ret
    ret = (i == n ? n : -1);
    80004e72:	5a7d                	li	s4,-1
    80004e74:	b7d5                	j	80004e58 <filewrite+0xfa>
    panic("filewrite");
    80004e76:	00004517          	auipc	a0,0x4
    80004e7a:	9a250513          	addi	a0,a0,-1630 # 80008818 <syscalls+0x290>
    80004e7e:	ffffb097          	auipc	ra,0xffffb
    80004e82:	6c6080e7          	jalr	1734(ra) # 80000544 <panic>
    return -1;
    80004e86:	5a7d                	li	s4,-1
    80004e88:	bfc1                	j	80004e58 <filewrite+0xfa>
      return -1;
    80004e8a:	5a7d                	li	s4,-1
    80004e8c:	b7f1                	j	80004e58 <filewrite+0xfa>
    80004e8e:	5a7d                	li	s4,-1
    80004e90:	b7e1                	j	80004e58 <filewrite+0xfa>

0000000080004e92 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004e92:	7179                	addi	sp,sp,-48
    80004e94:	f406                	sd	ra,40(sp)
    80004e96:	f022                	sd	s0,32(sp)
    80004e98:	ec26                	sd	s1,24(sp)
    80004e9a:	e84a                	sd	s2,16(sp)
    80004e9c:	e44e                	sd	s3,8(sp)
    80004e9e:	e052                	sd	s4,0(sp)
    80004ea0:	1800                	addi	s0,sp,48
    80004ea2:	84aa                	mv	s1,a0
    80004ea4:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004ea6:	0005b023          	sd	zero,0(a1)
    80004eaa:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004eae:	00000097          	auipc	ra,0x0
    80004eb2:	bf8080e7          	jalr	-1032(ra) # 80004aa6 <filealloc>
    80004eb6:	e088                	sd	a0,0(s1)
    80004eb8:	c551                	beqz	a0,80004f44 <pipealloc+0xb2>
    80004eba:	00000097          	auipc	ra,0x0
    80004ebe:	bec080e7          	jalr	-1044(ra) # 80004aa6 <filealloc>
    80004ec2:	00aa3023          	sd	a0,0(s4)
    80004ec6:	c92d                	beqz	a0,80004f38 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004ec8:	ffffc097          	auipc	ra,0xffffc
    80004ecc:	c32080e7          	jalr	-974(ra) # 80000afa <kalloc>
    80004ed0:	892a                	mv	s2,a0
    80004ed2:	c125                	beqz	a0,80004f32 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004ed4:	4985                	li	s3,1
    80004ed6:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004eda:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004ede:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004ee2:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004ee6:	00003597          	auipc	a1,0x3
    80004eea:	5c258593          	addi	a1,a1,1474 # 800084a8 <states.2493+0x1b8>
    80004eee:	ffffc097          	auipc	ra,0xffffc
    80004ef2:	c6c080e7          	jalr	-916(ra) # 80000b5a <initlock>
  (*f0)->type = FD_PIPE;
    80004ef6:	609c                	ld	a5,0(s1)
    80004ef8:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004efc:	609c                	ld	a5,0(s1)
    80004efe:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004f02:	609c                	ld	a5,0(s1)
    80004f04:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004f08:	609c                	ld	a5,0(s1)
    80004f0a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004f0e:	000a3783          	ld	a5,0(s4)
    80004f12:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004f16:	000a3783          	ld	a5,0(s4)
    80004f1a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004f1e:	000a3783          	ld	a5,0(s4)
    80004f22:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004f26:	000a3783          	ld	a5,0(s4)
    80004f2a:	0127b823          	sd	s2,16(a5)
  return 0;
    80004f2e:	4501                	li	a0,0
    80004f30:	a025                	j	80004f58 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004f32:	6088                	ld	a0,0(s1)
    80004f34:	e501                	bnez	a0,80004f3c <pipealloc+0xaa>
    80004f36:	a039                	j	80004f44 <pipealloc+0xb2>
    80004f38:	6088                	ld	a0,0(s1)
    80004f3a:	c51d                	beqz	a0,80004f68 <pipealloc+0xd6>
    fileclose(*f0);
    80004f3c:	00000097          	auipc	ra,0x0
    80004f40:	c26080e7          	jalr	-986(ra) # 80004b62 <fileclose>
  if(*f1)
    80004f44:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004f48:	557d                	li	a0,-1
  if(*f1)
    80004f4a:	c799                	beqz	a5,80004f58 <pipealloc+0xc6>
    fileclose(*f1);
    80004f4c:	853e                	mv	a0,a5
    80004f4e:	00000097          	auipc	ra,0x0
    80004f52:	c14080e7          	jalr	-1004(ra) # 80004b62 <fileclose>
  return -1;
    80004f56:	557d                	li	a0,-1
}
    80004f58:	70a2                	ld	ra,40(sp)
    80004f5a:	7402                	ld	s0,32(sp)
    80004f5c:	64e2                	ld	s1,24(sp)
    80004f5e:	6942                	ld	s2,16(sp)
    80004f60:	69a2                	ld	s3,8(sp)
    80004f62:	6a02                	ld	s4,0(sp)
    80004f64:	6145                	addi	sp,sp,48
    80004f66:	8082                	ret
  return -1;
    80004f68:	557d                	li	a0,-1
    80004f6a:	b7fd                	j	80004f58 <pipealloc+0xc6>

0000000080004f6c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004f6c:	1101                	addi	sp,sp,-32
    80004f6e:	ec06                	sd	ra,24(sp)
    80004f70:	e822                	sd	s0,16(sp)
    80004f72:	e426                	sd	s1,8(sp)
    80004f74:	e04a                	sd	s2,0(sp)
    80004f76:	1000                	addi	s0,sp,32
    80004f78:	84aa                	mv	s1,a0
    80004f7a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004f7c:	ffffc097          	auipc	ra,0xffffc
    80004f80:	c6e080e7          	jalr	-914(ra) # 80000bea <acquire>
  if(writable){
    80004f84:	02090d63          	beqz	s2,80004fbe <pipeclose+0x52>
    pi->writeopen = 0;
    80004f88:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004f8c:	21848513          	addi	a0,s1,536
    80004f90:	ffffd097          	auipc	ra,0xffffd
    80004f94:	48e080e7          	jalr	1166(ra) # 8000241e <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004f98:	2204b783          	ld	a5,544(s1)
    80004f9c:	eb95                	bnez	a5,80004fd0 <pipeclose+0x64>
    release(&pi->lock);
    80004f9e:	8526                	mv	a0,s1
    80004fa0:	ffffc097          	auipc	ra,0xffffc
    80004fa4:	cfe080e7          	jalr	-770(ra) # 80000c9e <release>
    kfree((char*)pi);
    80004fa8:	8526                	mv	a0,s1
    80004faa:	ffffc097          	auipc	ra,0xffffc
    80004fae:	a54080e7          	jalr	-1452(ra) # 800009fe <kfree>
  } else
    release(&pi->lock);
}
    80004fb2:	60e2                	ld	ra,24(sp)
    80004fb4:	6442                	ld	s0,16(sp)
    80004fb6:	64a2                	ld	s1,8(sp)
    80004fb8:	6902                	ld	s2,0(sp)
    80004fba:	6105                	addi	sp,sp,32
    80004fbc:	8082                	ret
    pi->readopen = 0;
    80004fbe:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004fc2:	21c48513          	addi	a0,s1,540
    80004fc6:	ffffd097          	auipc	ra,0xffffd
    80004fca:	458080e7          	jalr	1112(ra) # 8000241e <wakeup>
    80004fce:	b7e9                	j	80004f98 <pipeclose+0x2c>
    release(&pi->lock);
    80004fd0:	8526                	mv	a0,s1
    80004fd2:	ffffc097          	auipc	ra,0xffffc
    80004fd6:	ccc080e7          	jalr	-820(ra) # 80000c9e <release>
}
    80004fda:	bfe1                	j	80004fb2 <pipeclose+0x46>

0000000080004fdc <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004fdc:	7159                	addi	sp,sp,-112
    80004fde:	f486                	sd	ra,104(sp)
    80004fe0:	f0a2                	sd	s0,96(sp)
    80004fe2:	eca6                	sd	s1,88(sp)
    80004fe4:	e8ca                	sd	s2,80(sp)
    80004fe6:	e4ce                	sd	s3,72(sp)
    80004fe8:	e0d2                	sd	s4,64(sp)
    80004fea:	fc56                	sd	s5,56(sp)
    80004fec:	f85a                	sd	s6,48(sp)
    80004fee:	f45e                	sd	s7,40(sp)
    80004ff0:	f062                	sd	s8,32(sp)
    80004ff2:	ec66                	sd	s9,24(sp)
    80004ff4:	1880                	addi	s0,sp,112
    80004ff6:	84aa                	mv	s1,a0
    80004ff8:	8aae                	mv	s5,a1
    80004ffa:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004ffc:	ffffd097          	auipc	ra,0xffffd
    80005000:	ad4080e7          	jalr	-1324(ra) # 80001ad0 <myproc>
    80005004:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005006:	8526                	mv	a0,s1
    80005008:	ffffc097          	auipc	ra,0xffffc
    8000500c:	be2080e7          	jalr	-1054(ra) # 80000bea <acquire>
  while(i < n){
    80005010:	0d405463          	blez	s4,800050d8 <pipewrite+0xfc>
    80005014:	8ba6                	mv	s7,s1
  int i = 0;
    80005016:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005018:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000501a:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000501e:	21c48c13          	addi	s8,s1,540
    80005022:	a08d                	j	80005084 <pipewrite+0xa8>
      release(&pi->lock);
    80005024:	8526                	mv	a0,s1
    80005026:	ffffc097          	auipc	ra,0xffffc
    8000502a:	c78080e7          	jalr	-904(ra) # 80000c9e <release>
      return -1;
    8000502e:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005030:	854a                	mv	a0,s2
    80005032:	70a6                	ld	ra,104(sp)
    80005034:	7406                	ld	s0,96(sp)
    80005036:	64e6                	ld	s1,88(sp)
    80005038:	6946                	ld	s2,80(sp)
    8000503a:	69a6                	ld	s3,72(sp)
    8000503c:	6a06                	ld	s4,64(sp)
    8000503e:	7ae2                	ld	s5,56(sp)
    80005040:	7b42                	ld	s6,48(sp)
    80005042:	7ba2                	ld	s7,40(sp)
    80005044:	7c02                	ld	s8,32(sp)
    80005046:	6ce2                	ld	s9,24(sp)
    80005048:	6165                	addi	sp,sp,112
    8000504a:	8082                	ret
      wakeup(&pi->nread);
    8000504c:	8566                	mv	a0,s9
    8000504e:	ffffd097          	auipc	ra,0xffffd
    80005052:	3d0080e7          	jalr	976(ra) # 8000241e <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005056:	85de                	mv	a1,s7
    80005058:	8562                	mv	a0,s8
    8000505a:	ffffd097          	auipc	ra,0xffffd
    8000505e:	1e6080e7          	jalr	486(ra) # 80002240 <sleep>
    80005062:	a839                	j	80005080 <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005064:	21c4a783          	lw	a5,540(s1)
    80005068:	0017871b          	addiw	a4,a5,1
    8000506c:	20e4ae23          	sw	a4,540(s1)
    80005070:	1ff7f793          	andi	a5,a5,511
    80005074:	97a6                	add	a5,a5,s1
    80005076:	f9f44703          	lbu	a4,-97(s0)
    8000507a:	00e78c23          	sb	a4,24(a5)
      i++;
    8000507e:	2905                	addiw	s2,s2,1
  while(i < n){
    80005080:	05495063          	bge	s2,s4,800050c0 <pipewrite+0xe4>
    if(pi->readopen == 0 || killed(pr)){
    80005084:	2204a783          	lw	a5,544(s1)
    80005088:	dfd1                	beqz	a5,80005024 <pipewrite+0x48>
    8000508a:	854e                	mv	a0,s3
    8000508c:	ffffd097          	auipc	ra,0xffffd
    80005090:	638080e7          	jalr	1592(ra) # 800026c4 <killed>
    80005094:	f941                	bnez	a0,80005024 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005096:	2184a783          	lw	a5,536(s1)
    8000509a:	21c4a703          	lw	a4,540(s1)
    8000509e:	2007879b          	addiw	a5,a5,512
    800050a2:	faf705e3          	beq	a4,a5,8000504c <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800050a6:	4685                	li	a3,1
    800050a8:	01590633          	add	a2,s2,s5
    800050ac:	f9f40593          	addi	a1,s0,-97
    800050b0:	0589b503          	ld	a0,88(s3)
    800050b4:	ffffc097          	auipc	ra,0xffffc
    800050b8:	65c080e7          	jalr	1628(ra) # 80001710 <copyin>
    800050bc:	fb6514e3          	bne	a0,s6,80005064 <pipewrite+0x88>
  wakeup(&pi->nread);
    800050c0:	21848513          	addi	a0,s1,536
    800050c4:	ffffd097          	auipc	ra,0xffffd
    800050c8:	35a080e7          	jalr	858(ra) # 8000241e <wakeup>
  release(&pi->lock);
    800050cc:	8526                	mv	a0,s1
    800050ce:	ffffc097          	auipc	ra,0xffffc
    800050d2:	bd0080e7          	jalr	-1072(ra) # 80000c9e <release>
  return i;
    800050d6:	bfa9                	j	80005030 <pipewrite+0x54>
  int i = 0;
    800050d8:	4901                	li	s2,0
    800050da:	b7dd                	j	800050c0 <pipewrite+0xe4>

00000000800050dc <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800050dc:	715d                	addi	sp,sp,-80
    800050de:	e486                	sd	ra,72(sp)
    800050e0:	e0a2                	sd	s0,64(sp)
    800050e2:	fc26                	sd	s1,56(sp)
    800050e4:	f84a                	sd	s2,48(sp)
    800050e6:	f44e                	sd	s3,40(sp)
    800050e8:	f052                	sd	s4,32(sp)
    800050ea:	ec56                	sd	s5,24(sp)
    800050ec:	e85a                	sd	s6,16(sp)
    800050ee:	0880                	addi	s0,sp,80
    800050f0:	84aa                	mv	s1,a0
    800050f2:	892e                	mv	s2,a1
    800050f4:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800050f6:	ffffd097          	auipc	ra,0xffffd
    800050fa:	9da080e7          	jalr	-1574(ra) # 80001ad0 <myproc>
    800050fe:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005100:	8b26                	mv	s6,s1
    80005102:	8526                	mv	a0,s1
    80005104:	ffffc097          	auipc	ra,0xffffc
    80005108:	ae6080e7          	jalr	-1306(ra) # 80000bea <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000510c:	2184a703          	lw	a4,536(s1)
    80005110:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005114:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005118:	02f71763          	bne	a4,a5,80005146 <piperead+0x6a>
    8000511c:	2244a783          	lw	a5,548(s1)
    80005120:	c39d                	beqz	a5,80005146 <piperead+0x6a>
    if(killed(pr)){
    80005122:	8552                	mv	a0,s4
    80005124:	ffffd097          	auipc	ra,0xffffd
    80005128:	5a0080e7          	jalr	1440(ra) # 800026c4 <killed>
    8000512c:	e941                	bnez	a0,800051bc <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000512e:	85da                	mv	a1,s6
    80005130:	854e                	mv	a0,s3
    80005132:	ffffd097          	auipc	ra,0xffffd
    80005136:	10e080e7          	jalr	270(ra) # 80002240 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000513a:	2184a703          	lw	a4,536(s1)
    8000513e:	21c4a783          	lw	a5,540(s1)
    80005142:	fcf70de3          	beq	a4,a5,8000511c <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005146:	09505263          	blez	s5,800051ca <piperead+0xee>
    8000514a:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000514c:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    8000514e:	2184a783          	lw	a5,536(s1)
    80005152:	21c4a703          	lw	a4,540(s1)
    80005156:	02f70d63          	beq	a4,a5,80005190 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000515a:	0017871b          	addiw	a4,a5,1
    8000515e:	20e4ac23          	sw	a4,536(s1)
    80005162:	1ff7f793          	andi	a5,a5,511
    80005166:	97a6                	add	a5,a5,s1
    80005168:	0187c783          	lbu	a5,24(a5)
    8000516c:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005170:	4685                	li	a3,1
    80005172:	fbf40613          	addi	a2,s0,-65
    80005176:	85ca                	mv	a1,s2
    80005178:	058a3503          	ld	a0,88(s4)
    8000517c:	ffffc097          	auipc	ra,0xffffc
    80005180:	508080e7          	jalr	1288(ra) # 80001684 <copyout>
    80005184:	01650663          	beq	a0,s6,80005190 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005188:	2985                	addiw	s3,s3,1
    8000518a:	0905                	addi	s2,s2,1
    8000518c:	fd3a91e3          	bne	s5,s3,8000514e <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005190:	21c48513          	addi	a0,s1,540
    80005194:	ffffd097          	auipc	ra,0xffffd
    80005198:	28a080e7          	jalr	650(ra) # 8000241e <wakeup>
  release(&pi->lock);
    8000519c:	8526                	mv	a0,s1
    8000519e:	ffffc097          	auipc	ra,0xffffc
    800051a2:	b00080e7          	jalr	-1280(ra) # 80000c9e <release>
  return i;
}
    800051a6:	854e                	mv	a0,s3
    800051a8:	60a6                	ld	ra,72(sp)
    800051aa:	6406                	ld	s0,64(sp)
    800051ac:	74e2                	ld	s1,56(sp)
    800051ae:	7942                	ld	s2,48(sp)
    800051b0:	79a2                	ld	s3,40(sp)
    800051b2:	7a02                	ld	s4,32(sp)
    800051b4:	6ae2                	ld	s5,24(sp)
    800051b6:	6b42                	ld	s6,16(sp)
    800051b8:	6161                	addi	sp,sp,80
    800051ba:	8082                	ret
      release(&pi->lock);
    800051bc:	8526                	mv	a0,s1
    800051be:	ffffc097          	auipc	ra,0xffffc
    800051c2:	ae0080e7          	jalr	-1312(ra) # 80000c9e <release>
      return -1;
    800051c6:	59fd                	li	s3,-1
    800051c8:	bff9                	j	800051a6 <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800051ca:	4981                	li	s3,0
    800051cc:	b7d1                	j	80005190 <piperead+0xb4>

00000000800051ce <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800051ce:	1141                	addi	sp,sp,-16
    800051d0:	e422                	sd	s0,8(sp)
    800051d2:	0800                	addi	s0,sp,16
    800051d4:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800051d6:	8905                	andi	a0,a0,1
    800051d8:	c111                	beqz	a0,800051dc <flags2perm+0xe>
      perm = PTE_X;
    800051da:	4521                	li	a0,8
    if(flags & 0x2)
    800051dc:	8b89                	andi	a5,a5,2
    800051de:	c399                	beqz	a5,800051e4 <flags2perm+0x16>
      perm |= PTE_W;
    800051e0:	00456513          	ori	a0,a0,4
    return perm;
}
    800051e4:	6422                	ld	s0,8(sp)
    800051e6:	0141                	addi	sp,sp,16
    800051e8:	8082                	ret

00000000800051ea <exec>:

int
exec(char *path, char **argv)
{
    800051ea:	df010113          	addi	sp,sp,-528
    800051ee:	20113423          	sd	ra,520(sp)
    800051f2:	20813023          	sd	s0,512(sp)
    800051f6:	ffa6                	sd	s1,504(sp)
    800051f8:	fbca                	sd	s2,496(sp)
    800051fa:	f7ce                	sd	s3,488(sp)
    800051fc:	f3d2                	sd	s4,480(sp)
    800051fe:	efd6                	sd	s5,472(sp)
    80005200:	ebda                	sd	s6,464(sp)
    80005202:	e7de                	sd	s7,456(sp)
    80005204:	e3e2                	sd	s8,448(sp)
    80005206:	ff66                	sd	s9,440(sp)
    80005208:	fb6a                	sd	s10,432(sp)
    8000520a:	f76e                	sd	s11,424(sp)
    8000520c:	0c00                	addi	s0,sp,528
    8000520e:	84aa                	mv	s1,a0
    80005210:	dea43c23          	sd	a0,-520(s0)
    80005214:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005218:	ffffd097          	auipc	ra,0xffffd
    8000521c:	8b8080e7          	jalr	-1864(ra) # 80001ad0 <myproc>
    80005220:	892a                	mv	s2,a0

  begin_op();
    80005222:	fffff097          	auipc	ra,0xfffff
    80005226:	474080e7          	jalr	1140(ra) # 80004696 <begin_op>

  if((ip = namei(path)) == 0){
    8000522a:	8526                	mv	a0,s1
    8000522c:	fffff097          	auipc	ra,0xfffff
    80005230:	24e080e7          	jalr	590(ra) # 8000447a <namei>
    80005234:	c92d                	beqz	a0,800052a6 <exec+0xbc>
    80005236:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005238:	fffff097          	auipc	ra,0xfffff
    8000523c:	a9c080e7          	jalr	-1380(ra) # 80003cd4 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005240:	04000713          	li	a4,64
    80005244:	4681                	li	a3,0
    80005246:	e5040613          	addi	a2,s0,-432
    8000524a:	4581                	li	a1,0
    8000524c:	8526                	mv	a0,s1
    8000524e:	fffff097          	auipc	ra,0xfffff
    80005252:	d3a080e7          	jalr	-710(ra) # 80003f88 <readi>
    80005256:	04000793          	li	a5,64
    8000525a:	00f51a63          	bne	a0,a5,8000526e <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    8000525e:	e5042703          	lw	a4,-432(s0)
    80005262:	464c47b7          	lui	a5,0x464c4
    80005266:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000526a:	04f70463          	beq	a4,a5,800052b2 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000526e:	8526                	mv	a0,s1
    80005270:	fffff097          	auipc	ra,0xfffff
    80005274:	cc6080e7          	jalr	-826(ra) # 80003f36 <iunlockput>
    end_op();
    80005278:	fffff097          	auipc	ra,0xfffff
    8000527c:	49e080e7          	jalr	1182(ra) # 80004716 <end_op>
  }
  return -1;
    80005280:	557d                	li	a0,-1
}
    80005282:	20813083          	ld	ra,520(sp)
    80005286:	20013403          	ld	s0,512(sp)
    8000528a:	74fe                	ld	s1,504(sp)
    8000528c:	795e                	ld	s2,496(sp)
    8000528e:	79be                	ld	s3,488(sp)
    80005290:	7a1e                	ld	s4,480(sp)
    80005292:	6afe                	ld	s5,472(sp)
    80005294:	6b5e                	ld	s6,464(sp)
    80005296:	6bbe                	ld	s7,456(sp)
    80005298:	6c1e                	ld	s8,448(sp)
    8000529a:	7cfa                	ld	s9,440(sp)
    8000529c:	7d5a                	ld	s10,432(sp)
    8000529e:	7dba                	ld	s11,424(sp)
    800052a0:	21010113          	addi	sp,sp,528
    800052a4:	8082                	ret
    end_op();
    800052a6:	fffff097          	auipc	ra,0xfffff
    800052aa:	470080e7          	jalr	1136(ra) # 80004716 <end_op>
    return -1;
    800052ae:	557d                	li	a0,-1
    800052b0:	bfc9                	j	80005282 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    800052b2:	854a                	mv	a0,s2
    800052b4:	ffffd097          	auipc	ra,0xffffd
    800052b8:	8e2080e7          	jalr	-1822(ra) # 80001b96 <proc_pagetable>
    800052bc:	8baa                	mv	s7,a0
    800052be:	d945                	beqz	a0,8000526e <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800052c0:	e7042983          	lw	s3,-400(s0)
    800052c4:	e8845783          	lhu	a5,-376(s0)
    800052c8:	c7ad                	beqz	a5,80005332 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800052ca:	4a01                	li	s4,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800052cc:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    800052ce:	6c85                	lui	s9,0x1
    800052d0:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800052d4:	def43823          	sd	a5,-528(s0)
    800052d8:	ac0d                	j	8000550a <exec+0x320>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800052da:	00003517          	auipc	a0,0x3
    800052de:	54e50513          	addi	a0,a0,1358 # 80008828 <syscalls+0x2a0>
    800052e2:	ffffb097          	auipc	ra,0xffffb
    800052e6:	262080e7          	jalr	610(ra) # 80000544 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800052ea:	8756                	mv	a4,s5
    800052ec:	012d86bb          	addw	a3,s11,s2
    800052f0:	4581                	li	a1,0
    800052f2:	8526                	mv	a0,s1
    800052f4:	fffff097          	auipc	ra,0xfffff
    800052f8:	c94080e7          	jalr	-876(ra) # 80003f88 <readi>
    800052fc:	2501                	sext.w	a0,a0
    800052fe:	1aaa9a63          	bne	s5,a0,800054b2 <exec+0x2c8>
  for(i = 0; i < sz; i += PGSIZE){
    80005302:	6785                	lui	a5,0x1
    80005304:	0127893b          	addw	s2,a5,s2
    80005308:	77fd                	lui	a5,0xfffff
    8000530a:	01478a3b          	addw	s4,a5,s4
    8000530e:	1f897563          	bgeu	s2,s8,800054f8 <exec+0x30e>
    pa = walkaddr(pagetable, va + i);
    80005312:	02091593          	slli	a1,s2,0x20
    80005316:	9181                	srli	a1,a1,0x20
    80005318:	95ea                	add	a1,a1,s10
    8000531a:	855e                	mv	a0,s7
    8000531c:	ffffc097          	auipc	ra,0xffffc
    80005320:	d5c080e7          	jalr	-676(ra) # 80001078 <walkaddr>
    80005324:	862a                	mv	a2,a0
    if(pa == 0)
    80005326:	d955                	beqz	a0,800052da <exec+0xf0>
      n = PGSIZE;
    80005328:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    8000532a:	fd9a70e3          	bgeu	s4,s9,800052ea <exec+0x100>
      n = sz - i;
    8000532e:	8ad2                	mv	s5,s4
    80005330:	bf6d                	j	800052ea <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005332:	4a01                	li	s4,0
  iunlockput(ip);
    80005334:	8526                	mv	a0,s1
    80005336:	fffff097          	auipc	ra,0xfffff
    8000533a:	c00080e7          	jalr	-1024(ra) # 80003f36 <iunlockput>
  end_op();
    8000533e:	fffff097          	auipc	ra,0xfffff
    80005342:	3d8080e7          	jalr	984(ra) # 80004716 <end_op>
  p = myproc();
    80005346:	ffffc097          	auipc	ra,0xffffc
    8000534a:	78a080e7          	jalr	1930(ra) # 80001ad0 <myproc>
    8000534e:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005350:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    80005354:	6785                	lui	a5,0x1
    80005356:	17fd                	addi	a5,a5,-1
    80005358:	9a3e                	add	s4,s4,a5
    8000535a:	757d                	lui	a0,0xfffff
    8000535c:	00aa77b3          	and	a5,s4,a0
    80005360:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005364:	4691                	li	a3,4
    80005366:	6609                	lui	a2,0x2
    80005368:	963e                	add	a2,a2,a5
    8000536a:	85be                	mv	a1,a5
    8000536c:	855e                	mv	a0,s7
    8000536e:	ffffc097          	auipc	ra,0xffffc
    80005372:	0be080e7          	jalr	190(ra) # 8000142c <uvmalloc>
    80005376:	8b2a                	mv	s6,a0
  ip = 0;
    80005378:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    8000537a:	12050c63          	beqz	a0,800054b2 <exec+0x2c8>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000537e:	75f9                	lui	a1,0xffffe
    80005380:	95aa                	add	a1,a1,a0
    80005382:	855e                	mv	a0,s7
    80005384:	ffffc097          	auipc	ra,0xffffc
    80005388:	2ce080e7          	jalr	718(ra) # 80001652 <uvmclear>
  stackbase = sp - PGSIZE;
    8000538c:	7c7d                	lui	s8,0xfffff
    8000538e:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80005390:	e0043783          	ld	a5,-512(s0)
    80005394:	6388                	ld	a0,0(a5)
    80005396:	c535                	beqz	a0,80005402 <exec+0x218>
    80005398:	e9040993          	addi	s3,s0,-368
    8000539c:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800053a0:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    800053a2:	ffffc097          	auipc	ra,0xffffc
    800053a6:	ac8080e7          	jalr	-1336(ra) # 80000e6a <strlen>
    800053aa:	2505                	addiw	a0,a0,1
    800053ac:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800053b0:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800053b4:	13896663          	bltu	s2,s8,800054e0 <exec+0x2f6>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800053b8:	e0043d83          	ld	s11,-512(s0)
    800053bc:	000dba03          	ld	s4,0(s11)
    800053c0:	8552                	mv	a0,s4
    800053c2:	ffffc097          	auipc	ra,0xffffc
    800053c6:	aa8080e7          	jalr	-1368(ra) # 80000e6a <strlen>
    800053ca:	0015069b          	addiw	a3,a0,1
    800053ce:	8652                	mv	a2,s4
    800053d0:	85ca                	mv	a1,s2
    800053d2:	855e                	mv	a0,s7
    800053d4:	ffffc097          	auipc	ra,0xffffc
    800053d8:	2b0080e7          	jalr	688(ra) # 80001684 <copyout>
    800053dc:	10054663          	bltz	a0,800054e8 <exec+0x2fe>
    ustack[argc] = sp;
    800053e0:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800053e4:	0485                	addi	s1,s1,1
    800053e6:	008d8793          	addi	a5,s11,8
    800053ea:	e0f43023          	sd	a5,-512(s0)
    800053ee:	008db503          	ld	a0,8(s11)
    800053f2:	c911                	beqz	a0,80005406 <exec+0x21c>
    if(argc >= MAXARG)
    800053f4:	09a1                	addi	s3,s3,8
    800053f6:	fb3c96e3          	bne	s9,s3,800053a2 <exec+0x1b8>
  sz = sz1;
    800053fa:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800053fe:	4481                	li	s1,0
    80005400:	a84d                	j	800054b2 <exec+0x2c8>
  sp = sz;
    80005402:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005404:	4481                	li	s1,0
  ustack[argc] = 0;
    80005406:	00349793          	slli	a5,s1,0x3
    8000540a:	f9040713          	addi	a4,s0,-112
    8000540e:	97ba                	add	a5,a5,a4
    80005410:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    80005414:	00148693          	addi	a3,s1,1
    80005418:	068e                	slli	a3,a3,0x3
    8000541a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000541e:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005422:	01897663          	bgeu	s2,s8,8000542e <exec+0x244>
  sz = sz1;
    80005426:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000542a:	4481                	li	s1,0
    8000542c:	a059                	j	800054b2 <exec+0x2c8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000542e:	e9040613          	addi	a2,s0,-368
    80005432:	85ca                	mv	a1,s2
    80005434:	855e                	mv	a0,s7
    80005436:	ffffc097          	auipc	ra,0xffffc
    8000543a:	24e080e7          	jalr	590(ra) # 80001684 <copyout>
    8000543e:	0a054963          	bltz	a0,800054f0 <exec+0x306>
  p->trapframe->a1 = sp;
    80005442:	060ab783          	ld	a5,96(s5)
    80005446:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000544a:	df843783          	ld	a5,-520(s0)
    8000544e:	0007c703          	lbu	a4,0(a5)
    80005452:	cf11                	beqz	a4,8000546e <exec+0x284>
    80005454:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005456:	02f00693          	li	a3,47
    8000545a:	a039                	j	80005468 <exec+0x27e>
      last = s+1;
    8000545c:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80005460:	0785                	addi	a5,a5,1
    80005462:	fff7c703          	lbu	a4,-1(a5)
    80005466:	c701                	beqz	a4,8000546e <exec+0x284>
    if(*s == '/')
    80005468:	fed71ce3          	bne	a4,a3,80005460 <exec+0x276>
    8000546c:	bfc5                	j	8000545c <exec+0x272>
  safestrcpy(p->name, last, sizeof(p->name));
    8000546e:	4641                	li	a2,16
    80005470:	df843583          	ld	a1,-520(s0)
    80005474:	160a8513          	addi	a0,s5,352
    80005478:	ffffc097          	auipc	ra,0xffffc
    8000547c:	9c0080e7          	jalr	-1600(ra) # 80000e38 <safestrcpy>
  oldpagetable = p->pagetable;
    80005480:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    80005484:	057abc23          	sd	s7,88(s5)
  p->sz = sz;
    80005488:	056ab823          	sd	s6,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000548c:	060ab783          	ld	a5,96(s5)
    80005490:	e6843703          	ld	a4,-408(s0)
    80005494:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005496:	060ab783          	ld	a5,96(s5)
    8000549a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000549e:	85ea                	mv	a1,s10
    800054a0:	ffffc097          	auipc	ra,0xffffc
    800054a4:	792080e7          	jalr	1938(ra) # 80001c32 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800054a8:	0004851b          	sext.w	a0,s1
    800054ac:	bbd9                	j	80005282 <exec+0x98>
    800054ae:	e1443423          	sd	s4,-504(s0)
    proc_freepagetable(pagetable, sz);
    800054b2:	e0843583          	ld	a1,-504(s0)
    800054b6:	855e                	mv	a0,s7
    800054b8:	ffffc097          	auipc	ra,0xffffc
    800054bc:	77a080e7          	jalr	1914(ra) # 80001c32 <proc_freepagetable>
  if(ip){
    800054c0:	da0497e3          	bnez	s1,8000526e <exec+0x84>
  return -1;
    800054c4:	557d                	li	a0,-1
    800054c6:	bb75                	j	80005282 <exec+0x98>
    800054c8:	e1443423          	sd	s4,-504(s0)
    800054cc:	b7dd                	j	800054b2 <exec+0x2c8>
    800054ce:	e1443423          	sd	s4,-504(s0)
    800054d2:	b7c5                	j	800054b2 <exec+0x2c8>
    800054d4:	e1443423          	sd	s4,-504(s0)
    800054d8:	bfe9                	j	800054b2 <exec+0x2c8>
    800054da:	e1443423          	sd	s4,-504(s0)
    800054de:	bfd1                	j	800054b2 <exec+0x2c8>
  sz = sz1;
    800054e0:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800054e4:	4481                	li	s1,0
    800054e6:	b7f1                	j	800054b2 <exec+0x2c8>
  sz = sz1;
    800054e8:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800054ec:	4481                	li	s1,0
    800054ee:	b7d1                	j	800054b2 <exec+0x2c8>
  sz = sz1;
    800054f0:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800054f4:	4481                	li	s1,0
    800054f6:	bf75                	j	800054b2 <exec+0x2c8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800054f8:	e0843a03          	ld	s4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800054fc:	2b05                	addiw	s6,s6,1
    800054fe:	0389899b          	addiw	s3,s3,56
    80005502:	e8845783          	lhu	a5,-376(s0)
    80005506:	e2fb57e3          	bge	s6,a5,80005334 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000550a:	2981                	sext.w	s3,s3
    8000550c:	03800713          	li	a4,56
    80005510:	86ce                	mv	a3,s3
    80005512:	e1840613          	addi	a2,s0,-488
    80005516:	4581                	li	a1,0
    80005518:	8526                	mv	a0,s1
    8000551a:	fffff097          	auipc	ra,0xfffff
    8000551e:	a6e080e7          	jalr	-1426(ra) # 80003f88 <readi>
    80005522:	03800793          	li	a5,56
    80005526:	f8f514e3          	bne	a0,a5,800054ae <exec+0x2c4>
    if(ph.type != ELF_PROG_LOAD)
    8000552a:	e1842783          	lw	a5,-488(s0)
    8000552e:	4705                	li	a4,1
    80005530:	fce796e3          	bne	a5,a4,800054fc <exec+0x312>
    if(ph.memsz < ph.filesz)
    80005534:	e4043903          	ld	s2,-448(s0)
    80005538:	e3843783          	ld	a5,-456(s0)
    8000553c:	f8f966e3          	bltu	s2,a5,800054c8 <exec+0x2de>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005540:	e2843783          	ld	a5,-472(s0)
    80005544:	993e                	add	s2,s2,a5
    80005546:	f8f964e3          	bltu	s2,a5,800054ce <exec+0x2e4>
    if(ph.vaddr % PGSIZE != 0)
    8000554a:	df043703          	ld	a4,-528(s0)
    8000554e:	8ff9                	and	a5,a5,a4
    80005550:	f3d1                	bnez	a5,800054d4 <exec+0x2ea>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005552:	e1c42503          	lw	a0,-484(s0)
    80005556:	00000097          	auipc	ra,0x0
    8000555a:	c78080e7          	jalr	-904(ra) # 800051ce <flags2perm>
    8000555e:	86aa                	mv	a3,a0
    80005560:	864a                	mv	a2,s2
    80005562:	85d2                	mv	a1,s4
    80005564:	855e                	mv	a0,s7
    80005566:	ffffc097          	auipc	ra,0xffffc
    8000556a:	ec6080e7          	jalr	-314(ra) # 8000142c <uvmalloc>
    8000556e:	e0a43423          	sd	a0,-504(s0)
    80005572:	d525                	beqz	a0,800054da <exec+0x2f0>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005574:	e2843d03          	ld	s10,-472(s0)
    80005578:	e2042d83          	lw	s11,-480(s0)
    8000557c:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005580:	f60c0ce3          	beqz	s8,800054f8 <exec+0x30e>
    80005584:	8a62                	mv	s4,s8
    80005586:	4901                	li	s2,0
    80005588:	b369                	j	80005312 <exec+0x128>

000000008000558a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000558a:	7179                	addi	sp,sp,-48
    8000558c:	f406                	sd	ra,40(sp)
    8000558e:	f022                	sd	s0,32(sp)
    80005590:	ec26                	sd	s1,24(sp)
    80005592:	e84a                	sd	s2,16(sp)
    80005594:	1800                	addi	s0,sp,48
    80005596:	892e                	mv	s2,a1
    80005598:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000559a:	fdc40593          	addi	a1,s0,-36
    8000559e:	ffffe097          	auipc	ra,0xffffe
    800055a2:	914080e7          	jalr	-1772(ra) # 80002eb2 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800055a6:	fdc42703          	lw	a4,-36(s0)
    800055aa:	47bd                	li	a5,15
    800055ac:	02e7eb63          	bltu	a5,a4,800055e2 <argfd+0x58>
    800055b0:	ffffc097          	auipc	ra,0xffffc
    800055b4:	520080e7          	jalr	1312(ra) # 80001ad0 <myproc>
    800055b8:	fdc42703          	lw	a4,-36(s0)
    800055bc:	01a70793          	addi	a5,a4,26
    800055c0:	078e                	slli	a5,a5,0x3
    800055c2:	953e                	add	a0,a0,a5
    800055c4:	651c                	ld	a5,8(a0)
    800055c6:	c385                	beqz	a5,800055e6 <argfd+0x5c>
    return -1;
  if(pfd)
    800055c8:	00090463          	beqz	s2,800055d0 <argfd+0x46>
    *pfd = fd;
    800055cc:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800055d0:	4501                	li	a0,0
  if(pf)
    800055d2:	c091                	beqz	s1,800055d6 <argfd+0x4c>
    *pf = f;
    800055d4:	e09c                	sd	a5,0(s1)
}
    800055d6:	70a2                	ld	ra,40(sp)
    800055d8:	7402                	ld	s0,32(sp)
    800055da:	64e2                	ld	s1,24(sp)
    800055dc:	6942                	ld	s2,16(sp)
    800055de:	6145                	addi	sp,sp,48
    800055e0:	8082                	ret
    return -1;
    800055e2:	557d                	li	a0,-1
    800055e4:	bfcd                	j	800055d6 <argfd+0x4c>
    800055e6:	557d                	li	a0,-1
    800055e8:	b7fd                	j	800055d6 <argfd+0x4c>

00000000800055ea <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800055ea:	1101                	addi	sp,sp,-32
    800055ec:	ec06                	sd	ra,24(sp)
    800055ee:	e822                	sd	s0,16(sp)
    800055f0:	e426                	sd	s1,8(sp)
    800055f2:	1000                	addi	s0,sp,32
    800055f4:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800055f6:	ffffc097          	auipc	ra,0xffffc
    800055fa:	4da080e7          	jalr	1242(ra) # 80001ad0 <myproc>
    800055fe:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005600:	0d850793          	addi	a5,a0,216 # fffffffffffff0d8 <end+0xffffffff7ffdb678>
    80005604:	4501                	li	a0,0
    80005606:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005608:	6398                	ld	a4,0(a5)
    8000560a:	cb19                	beqz	a4,80005620 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000560c:	2505                	addiw	a0,a0,1
    8000560e:	07a1                	addi	a5,a5,8
    80005610:	fed51ce3          	bne	a0,a3,80005608 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005614:	557d                	li	a0,-1
}
    80005616:	60e2                	ld	ra,24(sp)
    80005618:	6442                	ld	s0,16(sp)
    8000561a:	64a2                	ld	s1,8(sp)
    8000561c:	6105                	addi	sp,sp,32
    8000561e:	8082                	ret
      p->ofile[fd] = f;
    80005620:	01a50793          	addi	a5,a0,26
    80005624:	078e                	slli	a5,a5,0x3
    80005626:	963e                	add	a2,a2,a5
    80005628:	e604                	sd	s1,8(a2)
      return fd;
    8000562a:	b7f5                	j	80005616 <fdalloc+0x2c>

000000008000562c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000562c:	715d                	addi	sp,sp,-80
    8000562e:	e486                	sd	ra,72(sp)
    80005630:	e0a2                	sd	s0,64(sp)
    80005632:	fc26                	sd	s1,56(sp)
    80005634:	f84a                	sd	s2,48(sp)
    80005636:	f44e                	sd	s3,40(sp)
    80005638:	f052                	sd	s4,32(sp)
    8000563a:	ec56                	sd	s5,24(sp)
    8000563c:	e85a                	sd	s6,16(sp)
    8000563e:	0880                	addi	s0,sp,80
    80005640:	8b2e                	mv	s6,a1
    80005642:	89b2                	mv	s3,a2
    80005644:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005646:	fb040593          	addi	a1,s0,-80
    8000564a:	fffff097          	auipc	ra,0xfffff
    8000564e:	e4e080e7          	jalr	-434(ra) # 80004498 <nameiparent>
    80005652:	84aa                	mv	s1,a0
    80005654:	16050063          	beqz	a0,800057b4 <create+0x188>
    return 0;

  ilock(dp);
    80005658:	ffffe097          	auipc	ra,0xffffe
    8000565c:	67c080e7          	jalr	1660(ra) # 80003cd4 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005660:	4601                	li	a2,0
    80005662:	fb040593          	addi	a1,s0,-80
    80005666:	8526                	mv	a0,s1
    80005668:	fffff097          	auipc	ra,0xfffff
    8000566c:	b50080e7          	jalr	-1200(ra) # 800041b8 <dirlookup>
    80005670:	8aaa                	mv	s5,a0
    80005672:	c931                	beqz	a0,800056c6 <create+0x9a>
    iunlockput(dp);
    80005674:	8526                	mv	a0,s1
    80005676:	fffff097          	auipc	ra,0xfffff
    8000567a:	8c0080e7          	jalr	-1856(ra) # 80003f36 <iunlockput>
    ilock(ip);
    8000567e:	8556                	mv	a0,s5
    80005680:	ffffe097          	auipc	ra,0xffffe
    80005684:	654080e7          	jalr	1620(ra) # 80003cd4 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005688:	000b059b          	sext.w	a1,s6
    8000568c:	4789                	li	a5,2
    8000568e:	02f59563          	bne	a1,a5,800056b8 <create+0x8c>
    80005692:	044ad783          	lhu	a5,68(s5)
    80005696:	37f9                	addiw	a5,a5,-2
    80005698:	17c2                	slli	a5,a5,0x30
    8000569a:	93c1                	srli	a5,a5,0x30
    8000569c:	4705                	li	a4,1
    8000569e:	00f76d63          	bltu	a4,a5,800056b8 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800056a2:	8556                	mv	a0,s5
    800056a4:	60a6                	ld	ra,72(sp)
    800056a6:	6406                	ld	s0,64(sp)
    800056a8:	74e2                	ld	s1,56(sp)
    800056aa:	7942                	ld	s2,48(sp)
    800056ac:	79a2                	ld	s3,40(sp)
    800056ae:	7a02                	ld	s4,32(sp)
    800056b0:	6ae2                	ld	s5,24(sp)
    800056b2:	6b42                	ld	s6,16(sp)
    800056b4:	6161                	addi	sp,sp,80
    800056b6:	8082                	ret
    iunlockput(ip);
    800056b8:	8556                	mv	a0,s5
    800056ba:	fffff097          	auipc	ra,0xfffff
    800056be:	87c080e7          	jalr	-1924(ra) # 80003f36 <iunlockput>
    return 0;
    800056c2:	4a81                	li	s5,0
    800056c4:	bff9                	j	800056a2 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800056c6:	85da                	mv	a1,s6
    800056c8:	4088                	lw	a0,0(s1)
    800056ca:	ffffe097          	auipc	ra,0xffffe
    800056ce:	46e080e7          	jalr	1134(ra) # 80003b38 <ialloc>
    800056d2:	8a2a                	mv	s4,a0
    800056d4:	c921                	beqz	a0,80005724 <create+0xf8>
  ilock(ip);
    800056d6:	ffffe097          	auipc	ra,0xffffe
    800056da:	5fe080e7          	jalr	1534(ra) # 80003cd4 <ilock>
  ip->major = major;
    800056de:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800056e2:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800056e6:	4785                	li	a5,1
    800056e8:	04fa1523          	sh	a5,74(s4)
  iupdate(ip);
    800056ec:	8552                	mv	a0,s4
    800056ee:	ffffe097          	auipc	ra,0xffffe
    800056f2:	51c080e7          	jalr	1308(ra) # 80003c0a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800056f6:	000b059b          	sext.w	a1,s6
    800056fa:	4785                	li	a5,1
    800056fc:	02f58b63          	beq	a1,a5,80005732 <create+0x106>
  if(dirlink(dp, name, ip->inum) < 0)
    80005700:	004a2603          	lw	a2,4(s4)
    80005704:	fb040593          	addi	a1,s0,-80
    80005708:	8526                	mv	a0,s1
    8000570a:	fffff097          	auipc	ra,0xfffff
    8000570e:	cbe080e7          	jalr	-834(ra) # 800043c8 <dirlink>
    80005712:	06054f63          	bltz	a0,80005790 <create+0x164>
  iunlockput(dp);
    80005716:	8526                	mv	a0,s1
    80005718:	fffff097          	auipc	ra,0xfffff
    8000571c:	81e080e7          	jalr	-2018(ra) # 80003f36 <iunlockput>
  return ip;
    80005720:	8ad2                	mv	s5,s4
    80005722:	b741                	j	800056a2 <create+0x76>
    iunlockput(dp);
    80005724:	8526                	mv	a0,s1
    80005726:	fffff097          	auipc	ra,0xfffff
    8000572a:	810080e7          	jalr	-2032(ra) # 80003f36 <iunlockput>
    return 0;
    8000572e:	8ad2                	mv	s5,s4
    80005730:	bf8d                	j	800056a2 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005732:	004a2603          	lw	a2,4(s4)
    80005736:	00003597          	auipc	a1,0x3
    8000573a:	11258593          	addi	a1,a1,274 # 80008848 <syscalls+0x2c0>
    8000573e:	8552                	mv	a0,s4
    80005740:	fffff097          	auipc	ra,0xfffff
    80005744:	c88080e7          	jalr	-888(ra) # 800043c8 <dirlink>
    80005748:	04054463          	bltz	a0,80005790 <create+0x164>
    8000574c:	40d0                	lw	a2,4(s1)
    8000574e:	00003597          	auipc	a1,0x3
    80005752:	10258593          	addi	a1,a1,258 # 80008850 <syscalls+0x2c8>
    80005756:	8552                	mv	a0,s4
    80005758:	fffff097          	auipc	ra,0xfffff
    8000575c:	c70080e7          	jalr	-912(ra) # 800043c8 <dirlink>
    80005760:	02054863          	bltz	a0,80005790 <create+0x164>
  if(dirlink(dp, name, ip->inum) < 0)
    80005764:	004a2603          	lw	a2,4(s4)
    80005768:	fb040593          	addi	a1,s0,-80
    8000576c:	8526                	mv	a0,s1
    8000576e:	fffff097          	auipc	ra,0xfffff
    80005772:	c5a080e7          	jalr	-934(ra) # 800043c8 <dirlink>
    80005776:	00054d63          	bltz	a0,80005790 <create+0x164>
    dp->nlink++;  // for ".."
    8000577a:	04a4d783          	lhu	a5,74(s1)
    8000577e:	2785                	addiw	a5,a5,1
    80005780:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005784:	8526                	mv	a0,s1
    80005786:	ffffe097          	auipc	ra,0xffffe
    8000578a:	484080e7          	jalr	1156(ra) # 80003c0a <iupdate>
    8000578e:	b761                	j	80005716 <create+0xea>
  ip->nlink = 0;
    80005790:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005794:	8552                	mv	a0,s4
    80005796:	ffffe097          	auipc	ra,0xffffe
    8000579a:	474080e7          	jalr	1140(ra) # 80003c0a <iupdate>
  iunlockput(ip);
    8000579e:	8552                	mv	a0,s4
    800057a0:	ffffe097          	auipc	ra,0xffffe
    800057a4:	796080e7          	jalr	1942(ra) # 80003f36 <iunlockput>
  iunlockput(dp);
    800057a8:	8526                	mv	a0,s1
    800057aa:	ffffe097          	auipc	ra,0xffffe
    800057ae:	78c080e7          	jalr	1932(ra) # 80003f36 <iunlockput>
  return 0;
    800057b2:	bdc5                	j	800056a2 <create+0x76>
    return 0;
    800057b4:	8aaa                	mv	s5,a0
    800057b6:	b5f5                	j	800056a2 <create+0x76>

00000000800057b8 <sys_dup>:
{
    800057b8:	7179                	addi	sp,sp,-48
    800057ba:	f406                	sd	ra,40(sp)
    800057bc:	f022                	sd	s0,32(sp)
    800057be:	ec26                	sd	s1,24(sp)
    800057c0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800057c2:	fd840613          	addi	a2,s0,-40
    800057c6:	4581                	li	a1,0
    800057c8:	4501                	li	a0,0
    800057ca:	00000097          	auipc	ra,0x0
    800057ce:	dc0080e7          	jalr	-576(ra) # 8000558a <argfd>
    return -1;
    800057d2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800057d4:	02054363          	bltz	a0,800057fa <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800057d8:	fd843503          	ld	a0,-40(s0)
    800057dc:	00000097          	auipc	ra,0x0
    800057e0:	e0e080e7          	jalr	-498(ra) # 800055ea <fdalloc>
    800057e4:	84aa                	mv	s1,a0
    return -1;
    800057e6:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800057e8:	00054963          	bltz	a0,800057fa <sys_dup+0x42>
  filedup(f);
    800057ec:	fd843503          	ld	a0,-40(s0)
    800057f0:	fffff097          	auipc	ra,0xfffff
    800057f4:	320080e7          	jalr	800(ra) # 80004b10 <filedup>
  return fd;
    800057f8:	87a6                	mv	a5,s1
}
    800057fa:	853e                	mv	a0,a5
    800057fc:	70a2                	ld	ra,40(sp)
    800057fe:	7402                	ld	s0,32(sp)
    80005800:	64e2                	ld	s1,24(sp)
    80005802:	6145                	addi	sp,sp,48
    80005804:	8082                	ret

0000000080005806 <sys_read>:
{
    80005806:	7179                	addi	sp,sp,-48
    80005808:	f406                	sd	ra,40(sp)
    8000580a:	f022                	sd	s0,32(sp)
    8000580c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000580e:	fd840593          	addi	a1,s0,-40
    80005812:	4505                	li	a0,1
    80005814:	ffffd097          	auipc	ra,0xffffd
    80005818:	6be080e7          	jalr	1726(ra) # 80002ed2 <argaddr>
  argint(2, &n);
    8000581c:	fe440593          	addi	a1,s0,-28
    80005820:	4509                	li	a0,2
    80005822:	ffffd097          	auipc	ra,0xffffd
    80005826:	690080e7          	jalr	1680(ra) # 80002eb2 <argint>
  if(argfd(0, 0, &f) < 0)
    8000582a:	fe840613          	addi	a2,s0,-24
    8000582e:	4581                	li	a1,0
    80005830:	4501                	li	a0,0
    80005832:	00000097          	auipc	ra,0x0
    80005836:	d58080e7          	jalr	-680(ra) # 8000558a <argfd>
    8000583a:	87aa                	mv	a5,a0
    return -1;
    8000583c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000583e:	0007cc63          	bltz	a5,80005856 <sys_read+0x50>
  return fileread(f, p, n);
    80005842:	fe442603          	lw	a2,-28(s0)
    80005846:	fd843583          	ld	a1,-40(s0)
    8000584a:	fe843503          	ld	a0,-24(s0)
    8000584e:	fffff097          	auipc	ra,0xfffff
    80005852:	44e080e7          	jalr	1102(ra) # 80004c9c <fileread>
}
    80005856:	70a2                	ld	ra,40(sp)
    80005858:	7402                	ld	s0,32(sp)
    8000585a:	6145                	addi	sp,sp,48
    8000585c:	8082                	ret

000000008000585e <sys_write>:
{
    8000585e:	7179                	addi	sp,sp,-48
    80005860:	f406                	sd	ra,40(sp)
    80005862:	f022                	sd	s0,32(sp)
    80005864:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005866:	fd840593          	addi	a1,s0,-40
    8000586a:	4505                	li	a0,1
    8000586c:	ffffd097          	auipc	ra,0xffffd
    80005870:	666080e7          	jalr	1638(ra) # 80002ed2 <argaddr>
  argint(2, &n);
    80005874:	fe440593          	addi	a1,s0,-28
    80005878:	4509                	li	a0,2
    8000587a:	ffffd097          	auipc	ra,0xffffd
    8000587e:	638080e7          	jalr	1592(ra) # 80002eb2 <argint>
  if(argfd(0, 0, &f) < 0)
    80005882:	fe840613          	addi	a2,s0,-24
    80005886:	4581                	li	a1,0
    80005888:	4501                	li	a0,0
    8000588a:	00000097          	auipc	ra,0x0
    8000588e:	d00080e7          	jalr	-768(ra) # 8000558a <argfd>
    80005892:	87aa                	mv	a5,a0
    return -1;
    80005894:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005896:	0007cc63          	bltz	a5,800058ae <sys_write+0x50>
  return filewrite(f, p, n);
    8000589a:	fe442603          	lw	a2,-28(s0)
    8000589e:	fd843583          	ld	a1,-40(s0)
    800058a2:	fe843503          	ld	a0,-24(s0)
    800058a6:	fffff097          	auipc	ra,0xfffff
    800058aa:	4b8080e7          	jalr	1208(ra) # 80004d5e <filewrite>
}
    800058ae:	70a2                	ld	ra,40(sp)
    800058b0:	7402                	ld	s0,32(sp)
    800058b2:	6145                	addi	sp,sp,48
    800058b4:	8082                	ret

00000000800058b6 <sys_close>:
{
    800058b6:	1101                	addi	sp,sp,-32
    800058b8:	ec06                	sd	ra,24(sp)
    800058ba:	e822                	sd	s0,16(sp)
    800058bc:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800058be:	fe040613          	addi	a2,s0,-32
    800058c2:	fec40593          	addi	a1,s0,-20
    800058c6:	4501                	li	a0,0
    800058c8:	00000097          	auipc	ra,0x0
    800058cc:	cc2080e7          	jalr	-830(ra) # 8000558a <argfd>
    return -1;
    800058d0:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800058d2:	02054463          	bltz	a0,800058fa <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800058d6:	ffffc097          	auipc	ra,0xffffc
    800058da:	1fa080e7          	jalr	506(ra) # 80001ad0 <myproc>
    800058de:	fec42783          	lw	a5,-20(s0)
    800058e2:	07e9                	addi	a5,a5,26
    800058e4:	078e                	slli	a5,a5,0x3
    800058e6:	97aa                	add	a5,a5,a0
    800058e8:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    800058ec:	fe043503          	ld	a0,-32(s0)
    800058f0:	fffff097          	auipc	ra,0xfffff
    800058f4:	272080e7          	jalr	626(ra) # 80004b62 <fileclose>
  return 0;
    800058f8:	4781                	li	a5,0
}
    800058fa:	853e                	mv	a0,a5
    800058fc:	60e2                	ld	ra,24(sp)
    800058fe:	6442                	ld	s0,16(sp)
    80005900:	6105                	addi	sp,sp,32
    80005902:	8082                	ret

0000000080005904 <sys_fstat>:
{
    80005904:	1101                	addi	sp,sp,-32
    80005906:	ec06                	sd	ra,24(sp)
    80005908:	e822                	sd	s0,16(sp)
    8000590a:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000590c:	fe040593          	addi	a1,s0,-32
    80005910:	4505                	li	a0,1
    80005912:	ffffd097          	auipc	ra,0xffffd
    80005916:	5c0080e7          	jalr	1472(ra) # 80002ed2 <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000591a:	fe840613          	addi	a2,s0,-24
    8000591e:	4581                	li	a1,0
    80005920:	4501                	li	a0,0
    80005922:	00000097          	auipc	ra,0x0
    80005926:	c68080e7          	jalr	-920(ra) # 8000558a <argfd>
    8000592a:	87aa                	mv	a5,a0
    return -1;
    8000592c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000592e:	0007ca63          	bltz	a5,80005942 <sys_fstat+0x3e>
  return filestat(f, st);
    80005932:	fe043583          	ld	a1,-32(s0)
    80005936:	fe843503          	ld	a0,-24(s0)
    8000593a:	fffff097          	auipc	ra,0xfffff
    8000593e:	2f0080e7          	jalr	752(ra) # 80004c2a <filestat>
}
    80005942:	60e2                	ld	ra,24(sp)
    80005944:	6442                	ld	s0,16(sp)
    80005946:	6105                	addi	sp,sp,32
    80005948:	8082                	ret

000000008000594a <sys_link>:
{
    8000594a:	7169                	addi	sp,sp,-304
    8000594c:	f606                	sd	ra,296(sp)
    8000594e:	f222                	sd	s0,288(sp)
    80005950:	ee26                	sd	s1,280(sp)
    80005952:	ea4a                	sd	s2,272(sp)
    80005954:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005956:	08000613          	li	a2,128
    8000595a:	ed040593          	addi	a1,s0,-304
    8000595e:	4501                	li	a0,0
    80005960:	ffffd097          	auipc	ra,0xffffd
    80005964:	592080e7          	jalr	1426(ra) # 80002ef2 <argstr>
    return -1;
    80005968:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000596a:	10054e63          	bltz	a0,80005a86 <sys_link+0x13c>
    8000596e:	08000613          	li	a2,128
    80005972:	f5040593          	addi	a1,s0,-176
    80005976:	4505                	li	a0,1
    80005978:	ffffd097          	auipc	ra,0xffffd
    8000597c:	57a080e7          	jalr	1402(ra) # 80002ef2 <argstr>
    return -1;
    80005980:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005982:	10054263          	bltz	a0,80005a86 <sys_link+0x13c>
  begin_op();
    80005986:	fffff097          	auipc	ra,0xfffff
    8000598a:	d10080e7          	jalr	-752(ra) # 80004696 <begin_op>
  if((ip = namei(old)) == 0){
    8000598e:	ed040513          	addi	a0,s0,-304
    80005992:	fffff097          	auipc	ra,0xfffff
    80005996:	ae8080e7          	jalr	-1304(ra) # 8000447a <namei>
    8000599a:	84aa                	mv	s1,a0
    8000599c:	c551                	beqz	a0,80005a28 <sys_link+0xde>
  ilock(ip);
    8000599e:	ffffe097          	auipc	ra,0xffffe
    800059a2:	336080e7          	jalr	822(ra) # 80003cd4 <ilock>
  if(ip->type == T_DIR){
    800059a6:	04449703          	lh	a4,68(s1)
    800059aa:	4785                	li	a5,1
    800059ac:	08f70463          	beq	a4,a5,80005a34 <sys_link+0xea>
  ip->nlink++;
    800059b0:	04a4d783          	lhu	a5,74(s1)
    800059b4:	2785                	addiw	a5,a5,1
    800059b6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800059ba:	8526                	mv	a0,s1
    800059bc:	ffffe097          	auipc	ra,0xffffe
    800059c0:	24e080e7          	jalr	590(ra) # 80003c0a <iupdate>
  iunlock(ip);
    800059c4:	8526                	mv	a0,s1
    800059c6:	ffffe097          	auipc	ra,0xffffe
    800059ca:	3d0080e7          	jalr	976(ra) # 80003d96 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800059ce:	fd040593          	addi	a1,s0,-48
    800059d2:	f5040513          	addi	a0,s0,-176
    800059d6:	fffff097          	auipc	ra,0xfffff
    800059da:	ac2080e7          	jalr	-1342(ra) # 80004498 <nameiparent>
    800059de:	892a                	mv	s2,a0
    800059e0:	c935                	beqz	a0,80005a54 <sys_link+0x10a>
  ilock(dp);
    800059e2:	ffffe097          	auipc	ra,0xffffe
    800059e6:	2f2080e7          	jalr	754(ra) # 80003cd4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800059ea:	00092703          	lw	a4,0(s2)
    800059ee:	409c                	lw	a5,0(s1)
    800059f0:	04f71d63          	bne	a4,a5,80005a4a <sys_link+0x100>
    800059f4:	40d0                	lw	a2,4(s1)
    800059f6:	fd040593          	addi	a1,s0,-48
    800059fa:	854a                	mv	a0,s2
    800059fc:	fffff097          	auipc	ra,0xfffff
    80005a00:	9cc080e7          	jalr	-1588(ra) # 800043c8 <dirlink>
    80005a04:	04054363          	bltz	a0,80005a4a <sys_link+0x100>
  iunlockput(dp);
    80005a08:	854a                	mv	a0,s2
    80005a0a:	ffffe097          	auipc	ra,0xffffe
    80005a0e:	52c080e7          	jalr	1324(ra) # 80003f36 <iunlockput>
  iput(ip);
    80005a12:	8526                	mv	a0,s1
    80005a14:	ffffe097          	auipc	ra,0xffffe
    80005a18:	47a080e7          	jalr	1146(ra) # 80003e8e <iput>
  end_op();
    80005a1c:	fffff097          	auipc	ra,0xfffff
    80005a20:	cfa080e7          	jalr	-774(ra) # 80004716 <end_op>
  return 0;
    80005a24:	4781                	li	a5,0
    80005a26:	a085                	j	80005a86 <sys_link+0x13c>
    end_op();
    80005a28:	fffff097          	auipc	ra,0xfffff
    80005a2c:	cee080e7          	jalr	-786(ra) # 80004716 <end_op>
    return -1;
    80005a30:	57fd                	li	a5,-1
    80005a32:	a891                	j	80005a86 <sys_link+0x13c>
    iunlockput(ip);
    80005a34:	8526                	mv	a0,s1
    80005a36:	ffffe097          	auipc	ra,0xffffe
    80005a3a:	500080e7          	jalr	1280(ra) # 80003f36 <iunlockput>
    end_op();
    80005a3e:	fffff097          	auipc	ra,0xfffff
    80005a42:	cd8080e7          	jalr	-808(ra) # 80004716 <end_op>
    return -1;
    80005a46:	57fd                	li	a5,-1
    80005a48:	a83d                	j	80005a86 <sys_link+0x13c>
    iunlockput(dp);
    80005a4a:	854a                	mv	a0,s2
    80005a4c:	ffffe097          	auipc	ra,0xffffe
    80005a50:	4ea080e7          	jalr	1258(ra) # 80003f36 <iunlockput>
  ilock(ip);
    80005a54:	8526                	mv	a0,s1
    80005a56:	ffffe097          	auipc	ra,0xffffe
    80005a5a:	27e080e7          	jalr	638(ra) # 80003cd4 <ilock>
  ip->nlink--;
    80005a5e:	04a4d783          	lhu	a5,74(s1)
    80005a62:	37fd                	addiw	a5,a5,-1
    80005a64:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005a68:	8526                	mv	a0,s1
    80005a6a:	ffffe097          	auipc	ra,0xffffe
    80005a6e:	1a0080e7          	jalr	416(ra) # 80003c0a <iupdate>
  iunlockput(ip);
    80005a72:	8526                	mv	a0,s1
    80005a74:	ffffe097          	auipc	ra,0xffffe
    80005a78:	4c2080e7          	jalr	1218(ra) # 80003f36 <iunlockput>
  end_op();
    80005a7c:	fffff097          	auipc	ra,0xfffff
    80005a80:	c9a080e7          	jalr	-870(ra) # 80004716 <end_op>
  return -1;
    80005a84:	57fd                	li	a5,-1
}
    80005a86:	853e                	mv	a0,a5
    80005a88:	70b2                	ld	ra,296(sp)
    80005a8a:	7412                	ld	s0,288(sp)
    80005a8c:	64f2                	ld	s1,280(sp)
    80005a8e:	6952                	ld	s2,272(sp)
    80005a90:	6155                	addi	sp,sp,304
    80005a92:	8082                	ret

0000000080005a94 <sys_unlink>:
{
    80005a94:	7151                	addi	sp,sp,-240
    80005a96:	f586                	sd	ra,232(sp)
    80005a98:	f1a2                	sd	s0,224(sp)
    80005a9a:	eda6                	sd	s1,216(sp)
    80005a9c:	e9ca                	sd	s2,208(sp)
    80005a9e:	e5ce                	sd	s3,200(sp)
    80005aa0:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005aa2:	08000613          	li	a2,128
    80005aa6:	f3040593          	addi	a1,s0,-208
    80005aaa:	4501                	li	a0,0
    80005aac:	ffffd097          	auipc	ra,0xffffd
    80005ab0:	446080e7          	jalr	1094(ra) # 80002ef2 <argstr>
    80005ab4:	18054163          	bltz	a0,80005c36 <sys_unlink+0x1a2>
  begin_op();
    80005ab8:	fffff097          	auipc	ra,0xfffff
    80005abc:	bde080e7          	jalr	-1058(ra) # 80004696 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005ac0:	fb040593          	addi	a1,s0,-80
    80005ac4:	f3040513          	addi	a0,s0,-208
    80005ac8:	fffff097          	auipc	ra,0xfffff
    80005acc:	9d0080e7          	jalr	-1584(ra) # 80004498 <nameiparent>
    80005ad0:	84aa                	mv	s1,a0
    80005ad2:	c979                	beqz	a0,80005ba8 <sys_unlink+0x114>
  ilock(dp);
    80005ad4:	ffffe097          	auipc	ra,0xffffe
    80005ad8:	200080e7          	jalr	512(ra) # 80003cd4 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005adc:	00003597          	auipc	a1,0x3
    80005ae0:	d6c58593          	addi	a1,a1,-660 # 80008848 <syscalls+0x2c0>
    80005ae4:	fb040513          	addi	a0,s0,-80
    80005ae8:	ffffe097          	auipc	ra,0xffffe
    80005aec:	6b6080e7          	jalr	1718(ra) # 8000419e <namecmp>
    80005af0:	14050a63          	beqz	a0,80005c44 <sys_unlink+0x1b0>
    80005af4:	00003597          	auipc	a1,0x3
    80005af8:	d5c58593          	addi	a1,a1,-676 # 80008850 <syscalls+0x2c8>
    80005afc:	fb040513          	addi	a0,s0,-80
    80005b00:	ffffe097          	auipc	ra,0xffffe
    80005b04:	69e080e7          	jalr	1694(ra) # 8000419e <namecmp>
    80005b08:	12050e63          	beqz	a0,80005c44 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005b0c:	f2c40613          	addi	a2,s0,-212
    80005b10:	fb040593          	addi	a1,s0,-80
    80005b14:	8526                	mv	a0,s1
    80005b16:	ffffe097          	auipc	ra,0xffffe
    80005b1a:	6a2080e7          	jalr	1698(ra) # 800041b8 <dirlookup>
    80005b1e:	892a                	mv	s2,a0
    80005b20:	12050263          	beqz	a0,80005c44 <sys_unlink+0x1b0>
  ilock(ip);
    80005b24:	ffffe097          	auipc	ra,0xffffe
    80005b28:	1b0080e7          	jalr	432(ra) # 80003cd4 <ilock>
  if(ip->nlink < 1)
    80005b2c:	04a91783          	lh	a5,74(s2)
    80005b30:	08f05263          	blez	a5,80005bb4 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005b34:	04491703          	lh	a4,68(s2)
    80005b38:	4785                	li	a5,1
    80005b3a:	08f70563          	beq	a4,a5,80005bc4 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005b3e:	4641                	li	a2,16
    80005b40:	4581                	li	a1,0
    80005b42:	fc040513          	addi	a0,s0,-64
    80005b46:	ffffb097          	auipc	ra,0xffffb
    80005b4a:	1a0080e7          	jalr	416(ra) # 80000ce6 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b4e:	4741                	li	a4,16
    80005b50:	f2c42683          	lw	a3,-212(s0)
    80005b54:	fc040613          	addi	a2,s0,-64
    80005b58:	4581                	li	a1,0
    80005b5a:	8526                	mv	a0,s1
    80005b5c:	ffffe097          	auipc	ra,0xffffe
    80005b60:	524080e7          	jalr	1316(ra) # 80004080 <writei>
    80005b64:	47c1                	li	a5,16
    80005b66:	0af51563          	bne	a0,a5,80005c10 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005b6a:	04491703          	lh	a4,68(s2)
    80005b6e:	4785                	li	a5,1
    80005b70:	0af70863          	beq	a4,a5,80005c20 <sys_unlink+0x18c>
  iunlockput(dp);
    80005b74:	8526                	mv	a0,s1
    80005b76:	ffffe097          	auipc	ra,0xffffe
    80005b7a:	3c0080e7          	jalr	960(ra) # 80003f36 <iunlockput>
  ip->nlink--;
    80005b7e:	04a95783          	lhu	a5,74(s2)
    80005b82:	37fd                	addiw	a5,a5,-1
    80005b84:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005b88:	854a                	mv	a0,s2
    80005b8a:	ffffe097          	auipc	ra,0xffffe
    80005b8e:	080080e7          	jalr	128(ra) # 80003c0a <iupdate>
  iunlockput(ip);
    80005b92:	854a                	mv	a0,s2
    80005b94:	ffffe097          	auipc	ra,0xffffe
    80005b98:	3a2080e7          	jalr	930(ra) # 80003f36 <iunlockput>
  end_op();
    80005b9c:	fffff097          	auipc	ra,0xfffff
    80005ba0:	b7a080e7          	jalr	-1158(ra) # 80004716 <end_op>
  return 0;
    80005ba4:	4501                	li	a0,0
    80005ba6:	a84d                	j	80005c58 <sys_unlink+0x1c4>
    end_op();
    80005ba8:	fffff097          	auipc	ra,0xfffff
    80005bac:	b6e080e7          	jalr	-1170(ra) # 80004716 <end_op>
    return -1;
    80005bb0:	557d                	li	a0,-1
    80005bb2:	a05d                	j	80005c58 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005bb4:	00003517          	auipc	a0,0x3
    80005bb8:	ca450513          	addi	a0,a0,-860 # 80008858 <syscalls+0x2d0>
    80005bbc:	ffffb097          	auipc	ra,0xffffb
    80005bc0:	988080e7          	jalr	-1656(ra) # 80000544 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005bc4:	04c92703          	lw	a4,76(s2)
    80005bc8:	02000793          	li	a5,32
    80005bcc:	f6e7f9e3          	bgeu	a5,a4,80005b3e <sys_unlink+0xaa>
    80005bd0:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005bd4:	4741                	li	a4,16
    80005bd6:	86ce                	mv	a3,s3
    80005bd8:	f1840613          	addi	a2,s0,-232
    80005bdc:	4581                	li	a1,0
    80005bde:	854a                	mv	a0,s2
    80005be0:	ffffe097          	auipc	ra,0xffffe
    80005be4:	3a8080e7          	jalr	936(ra) # 80003f88 <readi>
    80005be8:	47c1                	li	a5,16
    80005bea:	00f51b63          	bne	a0,a5,80005c00 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005bee:	f1845783          	lhu	a5,-232(s0)
    80005bf2:	e7a1                	bnez	a5,80005c3a <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005bf4:	29c1                	addiw	s3,s3,16
    80005bf6:	04c92783          	lw	a5,76(s2)
    80005bfa:	fcf9ede3          	bltu	s3,a5,80005bd4 <sys_unlink+0x140>
    80005bfe:	b781                	j	80005b3e <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005c00:	00003517          	auipc	a0,0x3
    80005c04:	c7050513          	addi	a0,a0,-912 # 80008870 <syscalls+0x2e8>
    80005c08:	ffffb097          	auipc	ra,0xffffb
    80005c0c:	93c080e7          	jalr	-1732(ra) # 80000544 <panic>
    panic("unlink: writei");
    80005c10:	00003517          	auipc	a0,0x3
    80005c14:	c7850513          	addi	a0,a0,-904 # 80008888 <syscalls+0x300>
    80005c18:	ffffb097          	auipc	ra,0xffffb
    80005c1c:	92c080e7          	jalr	-1748(ra) # 80000544 <panic>
    dp->nlink--;
    80005c20:	04a4d783          	lhu	a5,74(s1)
    80005c24:	37fd                	addiw	a5,a5,-1
    80005c26:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005c2a:	8526                	mv	a0,s1
    80005c2c:	ffffe097          	auipc	ra,0xffffe
    80005c30:	fde080e7          	jalr	-34(ra) # 80003c0a <iupdate>
    80005c34:	b781                	j	80005b74 <sys_unlink+0xe0>
    return -1;
    80005c36:	557d                	li	a0,-1
    80005c38:	a005                	j	80005c58 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005c3a:	854a                	mv	a0,s2
    80005c3c:	ffffe097          	auipc	ra,0xffffe
    80005c40:	2fa080e7          	jalr	762(ra) # 80003f36 <iunlockput>
  iunlockput(dp);
    80005c44:	8526                	mv	a0,s1
    80005c46:	ffffe097          	auipc	ra,0xffffe
    80005c4a:	2f0080e7          	jalr	752(ra) # 80003f36 <iunlockput>
  end_op();
    80005c4e:	fffff097          	auipc	ra,0xfffff
    80005c52:	ac8080e7          	jalr	-1336(ra) # 80004716 <end_op>
  return -1;
    80005c56:	557d                	li	a0,-1
}
    80005c58:	70ae                	ld	ra,232(sp)
    80005c5a:	740e                	ld	s0,224(sp)
    80005c5c:	64ee                	ld	s1,216(sp)
    80005c5e:	694e                	ld	s2,208(sp)
    80005c60:	69ae                	ld	s3,200(sp)
    80005c62:	616d                	addi	sp,sp,240
    80005c64:	8082                	ret

0000000080005c66 <sys_open>:

uint64
sys_open(void)
{
    80005c66:	7131                	addi	sp,sp,-192
    80005c68:	fd06                	sd	ra,184(sp)
    80005c6a:	f922                	sd	s0,176(sp)
    80005c6c:	f526                	sd	s1,168(sp)
    80005c6e:	f14a                	sd	s2,160(sp)
    80005c70:	ed4e                	sd	s3,152(sp)
    80005c72:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005c74:	f4c40593          	addi	a1,s0,-180
    80005c78:	4505                	li	a0,1
    80005c7a:	ffffd097          	auipc	ra,0xffffd
    80005c7e:	238080e7          	jalr	568(ra) # 80002eb2 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005c82:	08000613          	li	a2,128
    80005c86:	f5040593          	addi	a1,s0,-176
    80005c8a:	4501                	li	a0,0
    80005c8c:	ffffd097          	auipc	ra,0xffffd
    80005c90:	266080e7          	jalr	614(ra) # 80002ef2 <argstr>
    80005c94:	87aa                	mv	a5,a0
    return -1;
    80005c96:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005c98:	0a07c963          	bltz	a5,80005d4a <sys_open+0xe4>

  begin_op();
    80005c9c:	fffff097          	auipc	ra,0xfffff
    80005ca0:	9fa080e7          	jalr	-1542(ra) # 80004696 <begin_op>

  if(omode & O_CREATE){
    80005ca4:	f4c42783          	lw	a5,-180(s0)
    80005ca8:	2007f793          	andi	a5,a5,512
    80005cac:	cfc5                	beqz	a5,80005d64 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005cae:	4681                	li	a3,0
    80005cb0:	4601                	li	a2,0
    80005cb2:	4589                	li	a1,2
    80005cb4:	f5040513          	addi	a0,s0,-176
    80005cb8:	00000097          	auipc	ra,0x0
    80005cbc:	974080e7          	jalr	-1676(ra) # 8000562c <create>
    80005cc0:	84aa                	mv	s1,a0
    if(ip == 0){
    80005cc2:	c959                	beqz	a0,80005d58 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005cc4:	04449703          	lh	a4,68(s1)
    80005cc8:	478d                	li	a5,3
    80005cca:	00f71763          	bne	a4,a5,80005cd8 <sys_open+0x72>
    80005cce:	0464d703          	lhu	a4,70(s1)
    80005cd2:	47a5                	li	a5,9
    80005cd4:	0ce7ed63          	bltu	a5,a4,80005dae <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005cd8:	fffff097          	auipc	ra,0xfffff
    80005cdc:	dce080e7          	jalr	-562(ra) # 80004aa6 <filealloc>
    80005ce0:	89aa                	mv	s3,a0
    80005ce2:	10050363          	beqz	a0,80005de8 <sys_open+0x182>
    80005ce6:	00000097          	auipc	ra,0x0
    80005cea:	904080e7          	jalr	-1788(ra) # 800055ea <fdalloc>
    80005cee:	892a                	mv	s2,a0
    80005cf0:	0e054763          	bltz	a0,80005dde <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005cf4:	04449703          	lh	a4,68(s1)
    80005cf8:	478d                	li	a5,3
    80005cfa:	0cf70563          	beq	a4,a5,80005dc4 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005cfe:	4789                	li	a5,2
    80005d00:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005d04:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005d08:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005d0c:	f4c42783          	lw	a5,-180(s0)
    80005d10:	0017c713          	xori	a4,a5,1
    80005d14:	8b05                	andi	a4,a4,1
    80005d16:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005d1a:	0037f713          	andi	a4,a5,3
    80005d1e:	00e03733          	snez	a4,a4
    80005d22:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005d26:	4007f793          	andi	a5,a5,1024
    80005d2a:	c791                	beqz	a5,80005d36 <sys_open+0xd0>
    80005d2c:	04449703          	lh	a4,68(s1)
    80005d30:	4789                	li	a5,2
    80005d32:	0af70063          	beq	a4,a5,80005dd2 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005d36:	8526                	mv	a0,s1
    80005d38:	ffffe097          	auipc	ra,0xffffe
    80005d3c:	05e080e7          	jalr	94(ra) # 80003d96 <iunlock>
  end_op();
    80005d40:	fffff097          	auipc	ra,0xfffff
    80005d44:	9d6080e7          	jalr	-1578(ra) # 80004716 <end_op>

  return fd;
    80005d48:	854a                	mv	a0,s2
}
    80005d4a:	70ea                	ld	ra,184(sp)
    80005d4c:	744a                	ld	s0,176(sp)
    80005d4e:	74aa                	ld	s1,168(sp)
    80005d50:	790a                	ld	s2,160(sp)
    80005d52:	69ea                	ld	s3,152(sp)
    80005d54:	6129                	addi	sp,sp,192
    80005d56:	8082                	ret
      end_op();
    80005d58:	fffff097          	auipc	ra,0xfffff
    80005d5c:	9be080e7          	jalr	-1602(ra) # 80004716 <end_op>
      return -1;
    80005d60:	557d                	li	a0,-1
    80005d62:	b7e5                	j	80005d4a <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005d64:	f5040513          	addi	a0,s0,-176
    80005d68:	ffffe097          	auipc	ra,0xffffe
    80005d6c:	712080e7          	jalr	1810(ra) # 8000447a <namei>
    80005d70:	84aa                	mv	s1,a0
    80005d72:	c905                	beqz	a0,80005da2 <sys_open+0x13c>
    ilock(ip);
    80005d74:	ffffe097          	auipc	ra,0xffffe
    80005d78:	f60080e7          	jalr	-160(ra) # 80003cd4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005d7c:	04449703          	lh	a4,68(s1)
    80005d80:	4785                	li	a5,1
    80005d82:	f4f711e3          	bne	a4,a5,80005cc4 <sys_open+0x5e>
    80005d86:	f4c42783          	lw	a5,-180(s0)
    80005d8a:	d7b9                	beqz	a5,80005cd8 <sys_open+0x72>
      iunlockput(ip);
    80005d8c:	8526                	mv	a0,s1
    80005d8e:	ffffe097          	auipc	ra,0xffffe
    80005d92:	1a8080e7          	jalr	424(ra) # 80003f36 <iunlockput>
      end_op();
    80005d96:	fffff097          	auipc	ra,0xfffff
    80005d9a:	980080e7          	jalr	-1664(ra) # 80004716 <end_op>
      return -1;
    80005d9e:	557d                	li	a0,-1
    80005da0:	b76d                	j	80005d4a <sys_open+0xe4>
      end_op();
    80005da2:	fffff097          	auipc	ra,0xfffff
    80005da6:	974080e7          	jalr	-1676(ra) # 80004716 <end_op>
      return -1;
    80005daa:	557d                	li	a0,-1
    80005dac:	bf79                	j	80005d4a <sys_open+0xe4>
    iunlockput(ip);
    80005dae:	8526                	mv	a0,s1
    80005db0:	ffffe097          	auipc	ra,0xffffe
    80005db4:	186080e7          	jalr	390(ra) # 80003f36 <iunlockput>
    end_op();
    80005db8:	fffff097          	auipc	ra,0xfffff
    80005dbc:	95e080e7          	jalr	-1698(ra) # 80004716 <end_op>
    return -1;
    80005dc0:	557d                	li	a0,-1
    80005dc2:	b761                	j	80005d4a <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005dc4:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005dc8:	04649783          	lh	a5,70(s1)
    80005dcc:	02f99223          	sh	a5,36(s3)
    80005dd0:	bf25                	j	80005d08 <sys_open+0xa2>
    itrunc(ip);
    80005dd2:	8526                	mv	a0,s1
    80005dd4:	ffffe097          	auipc	ra,0xffffe
    80005dd8:	00e080e7          	jalr	14(ra) # 80003de2 <itrunc>
    80005ddc:	bfa9                	j	80005d36 <sys_open+0xd0>
      fileclose(f);
    80005dde:	854e                	mv	a0,s3
    80005de0:	fffff097          	auipc	ra,0xfffff
    80005de4:	d82080e7          	jalr	-638(ra) # 80004b62 <fileclose>
    iunlockput(ip);
    80005de8:	8526                	mv	a0,s1
    80005dea:	ffffe097          	auipc	ra,0xffffe
    80005dee:	14c080e7          	jalr	332(ra) # 80003f36 <iunlockput>
    end_op();
    80005df2:	fffff097          	auipc	ra,0xfffff
    80005df6:	924080e7          	jalr	-1756(ra) # 80004716 <end_op>
    return -1;
    80005dfa:	557d                	li	a0,-1
    80005dfc:	b7b9                	j	80005d4a <sys_open+0xe4>

0000000080005dfe <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005dfe:	7175                	addi	sp,sp,-144
    80005e00:	e506                	sd	ra,136(sp)
    80005e02:	e122                	sd	s0,128(sp)
    80005e04:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005e06:	fffff097          	auipc	ra,0xfffff
    80005e0a:	890080e7          	jalr	-1904(ra) # 80004696 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005e0e:	08000613          	li	a2,128
    80005e12:	f7040593          	addi	a1,s0,-144
    80005e16:	4501                	li	a0,0
    80005e18:	ffffd097          	auipc	ra,0xffffd
    80005e1c:	0da080e7          	jalr	218(ra) # 80002ef2 <argstr>
    80005e20:	02054963          	bltz	a0,80005e52 <sys_mkdir+0x54>
    80005e24:	4681                	li	a3,0
    80005e26:	4601                	li	a2,0
    80005e28:	4585                	li	a1,1
    80005e2a:	f7040513          	addi	a0,s0,-144
    80005e2e:	fffff097          	auipc	ra,0xfffff
    80005e32:	7fe080e7          	jalr	2046(ra) # 8000562c <create>
    80005e36:	cd11                	beqz	a0,80005e52 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005e38:	ffffe097          	auipc	ra,0xffffe
    80005e3c:	0fe080e7          	jalr	254(ra) # 80003f36 <iunlockput>
  end_op();
    80005e40:	fffff097          	auipc	ra,0xfffff
    80005e44:	8d6080e7          	jalr	-1834(ra) # 80004716 <end_op>
  return 0;
    80005e48:	4501                	li	a0,0
}
    80005e4a:	60aa                	ld	ra,136(sp)
    80005e4c:	640a                	ld	s0,128(sp)
    80005e4e:	6149                	addi	sp,sp,144
    80005e50:	8082                	ret
    end_op();
    80005e52:	fffff097          	auipc	ra,0xfffff
    80005e56:	8c4080e7          	jalr	-1852(ra) # 80004716 <end_op>
    return -1;
    80005e5a:	557d                	li	a0,-1
    80005e5c:	b7fd                	j	80005e4a <sys_mkdir+0x4c>

0000000080005e5e <sys_mknod>:

uint64
sys_mknod(void)
{
    80005e5e:	7135                	addi	sp,sp,-160
    80005e60:	ed06                	sd	ra,152(sp)
    80005e62:	e922                	sd	s0,144(sp)
    80005e64:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005e66:	fffff097          	auipc	ra,0xfffff
    80005e6a:	830080e7          	jalr	-2000(ra) # 80004696 <begin_op>
  argint(1, &major);
    80005e6e:	f6c40593          	addi	a1,s0,-148
    80005e72:	4505                	li	a0,1
    80005e74:	ffffd097          	auipc	ra,0xffffd
    80005e78:	03e080e7          	jalr	62(ra) # 80002eb2 <argint>
  argint(2, &minor);
    80005e7c:	f6840593          	addi	a1,s0,-152
    80005e80:	4509                	li	a0,2
    80005e82:	ffffd097          	auipc	ra,0xffffd
    80005e86:	030080e7          	jalr	48(ra) # 80002eb2 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005e8a:	08000613          	li	a2,128
    80005e8e:	f7040593          	addi	a1,s0,-144
    80005e92:	4501                	li	a0,0
    80005e94:	ffffd097          	auipc	ra,0xffffd
    80005e98:	05e080e7          	jalr	94(ra) # 80002ef2 <argstr>
    80005e9c:	02054b63          	bltz	a0,80005ed2 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005ea0:	f6841683          	lh	a3,-152(s0)
    80005ea4:	f6c41603          	lh	a2,-148(s0)
    80005ea8:	458d                	li	a1,3
    80005eaa:	f7040513          	addi	a0,s0,-144
    80005eae:	fffff097          	auipc	ra,0xfffff
    80005eb2:	77e080e7          	jalr	1918(ra) # 8000562c <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005eb6:	cd11                	beqz	a0,80005ed2 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005eb8:	ffffe097          	auipc	ra,0xffffe
    80005ebc:	07e080e7          	jalr	126(ra) # 80003f36 <iunlockput>
  end_op();
    80005ec0:	fffff097          	auipc	ra,0xfffff
    80005ec4:	856080e7          	jalr	-1962(ra) # 80004716 <end_op>
  return 0;
    80005ec8:	4501                	li	a0,0
}
    80005eca:	60ea                	ld	ra,152(sp)
    80005ecc:	644a                	ld	s0,144(sp)
    80005ece:	610d                	addi	sp,sp,160
    80005ed0:	8082                	ret
    end_op();
    80005ed2:	fffff097          	auipc	ra,0xfffff
    80005ed6:	844080e7          	jalr	-1980(ra) # 80004716 <end_op>
    return -1;
    80005eda:	557d                	li	a0,-1
    80005edc:	b7fd                	j	80005eca <sys_mknod+0x6c>

0000000080005ede <sys_chdir>:

uint64
sys_chdir(void)
{
    80005ede:	7135                	addi	sp,sp,-160
    80005ee0:	ed06                	sd	ra,152(sp)
    80005ee2:	e922                	sd	s0,144(sp)
    80005ee4:	e526                	sd	s1,136(sp)
    80005ee6:	e14a                	sd	s2,128(sp)
    80005ee8:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005eea:	ffffc097          	auipc	ra,0xffffc
    80005eee:	be6080e7          	jalr	-1050(ra) # 80001ad0 <myproc>
    80005ef2:	892a                	mv	s2,a0
  
  begin_op();
    80005ef4:	ffffe097          	auipc	ra,0xffffe
    80005ef8:	7a2080e7          	jalr	1954(ra) # 80004696 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005efc:	08000613          	li	a2,128
    80005f00:	f6040593          	addi	a1,s0,-160
    80005f04:	4501                	li	a0,0
    80005f06:	ffffd097          	auipc	ra,0xffffd
    80005f0a:	fec080e7          	jalr	-20(ra) # 80002ef2 <argstr>
    80005f0e:	04054b63          	bltz	a0,80005f64 <sys_chdir+0x86>
    80005f12:	f6040513          	addi	a0,s0,-160
    80005f16:	ffffe097          	auipc	ra,0xffffe
    80005f1a:	564080e7          	jalr	1380(ra) # 8000447a <namei>
    80005f1e:	84aa                	mv	s1,a0
    80005f20:	c131                	beqz	a0,80005f64 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005f22:	ffffe097          	auipc	ra,0xffffe
    80005f26:	db2080e7          	jalr	-590(ra) # 80003cd4 <ilock>
  if(ip->type != T_DIR){
    80005f2a:	04449703          	lh	a4,68(s1)
    80005f2e:	4785                	li	a5,1
    80005f30:	04f71063          	bne	a4,a5,80005f70 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005f34:	8526                	mv	a0,s1
    80005f36:	ffffe097          	auipc	ra,0xffffe
    80005f3a:	e60080e7          	jalr	-416(ra) # 80003d96 <iunlock>
  iput(p->cwd);
    80005f3e:	15893503          	ld	a0,344(s2)
    80005f42:	ffffe097          	auipc	ra,0xffffe
    80005f46:	f4c080e7          	jalr	-180(ra) # 80003e8e <iput>
  end_op();
    80005f4a:	ffffe097          	auipc	ra,0xffffe
    80005f4e:	7cc080e7          	jalr	1996(ra) # 80004716 <end_op>
  p->cwd = ip;
    80005f52:	14993c23          	sd	s1,344(s2)
  return 0;
    80005f56:	4501                	li	a0,0
}
    80005f58:	60ea                	ld	ra,152(sp)
    80005f5a:	644a                	ld	s0,144(sp)
    80005f5c:	64aa                	ld	s1,136(sp)
    80005f5e:	690a                	ld	s2,128(sp)
    80005f60:	610d                	addi	sp,sp,160
    80005f62:	8082                	ret
    end_op();
    80005f64:	ffffe097          	auipc	ra,0xffffe
    80005f68:	7b2080e7          	jalr	1970(ra) # 80004716 <end_op>
    return -1;
    80005f6c:	557d                	li	a0,-1
    80005f6e:	b7ed                	j	80005f58 <sys_chdir+0x7a>
    iunlockput(ip);
    80005f70:	8526                	mv	a0,s1
    80005f72:	ffffe097          	auipc	ra,0xffffe
    80005f76:	fc4080e7          	jalr	-60(ra) # 80003f36 <iunlockput>
    end_op();
    80005f7a:	ffffe097          	auipc	ra,0xffffe
    80005f7e:	79c080e7          	jalr	1948(ra) # 80004716 <end_op>
    return -1;
    80005f82:	557d                	li	a0,-1
    80005f84:	bfd1                	j	80005f58 <sys_chdir+0x7a>

0000000080005f86 <sys_exec>:

uint64
sys_exec(void)
{
    80005f86:	7145                	addi	sp,sp,-464
    80005f88:	e786                	sd	ra,456(sp)
    80005f8a:	e3a2                	sd	s0,448(sp)
    80005f8c:	ff26                	sd	s1,440(sp)
    80005f8e:	fb4a                	sd	s2,432(sp)
    80005f90:	f74e                	sd	s3,424(sp)
    80005f92:	f352                	sd	s4,416(sp)
    80005f94:	ef56                	sd	s5,408(sp)
    80005f96:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005f98:	e3840593          	addi	a1,s0,-456
    80005f9c:	4505                	li	a0,1
    80005f9e:	ffffd097          	auipc	ra,0xffffd
    80005fa2:	f34080e7          	jalr	-204(ra) # 80002ed2 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005fa6:	08000613          	li	a2,128
    80005faa:	f4040593          	addi	a1,s0,-192
    80005fae:	4501                	li	a0,0
    80005fb0:	ffffd097          	auipc	ra,0xffffd
    80005fb4:	f42080e7          	jalr	-190(ra) # 80002ef2 <argstr>
    80005fb8:	87aa                	mv	a5,a0
    return -1;
    80005fba:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005fbc:	0c07c263          	bltz	a5,80006080 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005fc0:	10000613          	li	a2,256
    80005fc4:	4581                	li	a1,0
    80005fc6:	e4040513          	addi	a0,s0,-448
    80005fca:	ffffb097          	auipc	ra,0xffffb
    80005fce:	d1c080e7          	jalr	-740(ra) # 80000ce6 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005fd2:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005fd6:	89a6                	mv	s3,s1
    80005fd8:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005fda:	02000a13          	li	s4,32
    80005fde:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005fe2:	00391513          	slli	a0,s2,0x3
    80005fe6:	e3040593          	addi	a1,s0,-464
    80005fea:	e3843783          	ld	a5,-456(s0)
    80005fee:	953e                	add	a0,a0,a5
    80005ff0:	ffffd097          	auipc	ra,0xffffd
    80005ff4:	e24080e7          	jalr	-476(ra) # 80002e14 <fetchaddr>
    80005ff8:	02054a63          	bltz	a0,8000602c <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005ffc:	e3043783          	ld	a5,-464(s0)
    80006000:	c3b9                	beqz	a5,80006046 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006002:	ffffb097          	auipc	ra,0xffffb
    80006006:	af8080e7          	jalr	-1288(ra) # 80000afa <kalloc>
    8000600a:	85aa                	mv	a1,a0
    8000600c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006010:	cd11                	beqz	a0,8000602c <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006012:	6605                	lui	a2,0x1
    80006014:	e3043503          	ld	a0,-464(s0)
    80006018:	ffffd097          	auipc	ra,0xffffd
    8000601c:	e4e080e7          	jalr	-434(ra) # 80002e66 <fetchstr>
    80006020:	00054663          	bltz	a0,8000602c <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80006024:	0905                	addi	s2,s2,1
    80006026:	09a1                	addi	s3,s3,8
    80006028:	fb491be3          	bne	s2,s4,80005fde <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000602c:	10048913          	addi	s2,s1,256
    80006030:	6088                	ld	a0,0(s1)
    80006032:	c531                	beqz	a0,8000607e <sys_exec+0xf8>
    kfree(argv[i]);
    80006034:	ffffb097          	auipc	ra,0xffffb
    80006038:	9ca080e7          	jalr	-1590(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000603c:	04a1                	addi	s1,s1,8
    8000603e:	ff2499e3          	bne	s1,s2,80006030 <sys_exec+0xaa>
  return -1;
    80006042:	557d                	li	a0,-1
    80006044:	a835                	j	80006080 <sys_exec+0xfa>
      argv[i] = 0;
    80006046:	0a8e                	slli	s5,s5,0x3
    80006048:	fc040793          	addi	a5,s0,-64
    8000604c:	9abe                	add	s5,s5,a5
    8000604e:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80006052:	e4040593          	addi	a1,s0,-448
    80006056:	f4040513          	addi	a0,s0,-192
    8000605a:	fffff097          	auipc	ra,0xfffff
    8000605e:	190080e7          	jalr	400(ra) # 800051ea <exec>
    80006062:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006064:	10048993          	addi	s3,s1,256
    80006068:	6088                	ld	a0,0(s1)
    8000606a:	c901                	beqz	a0,8000607a <sys_exec+0xf4>
    kfree(argv[i]);
    8000606c:	ffffb097          	auipc	ra,0xffffb
    80006070:	992080e7          	jalr	-1646(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006074:	04a1                	addi	s1,s1,8
    80006076:	ff3499e3          	bne	s1,s3,80006068 <sys_exec+0xe2>
  return ret;
    8000607a:	854a                	mv	a0,s2
    8000607c:	a011                	j	80006080 <sys_exec+0xfa>
  return -1;
    8000607e:	557d                	li	a0,-1
}
    80006080:	60be                	ld	ra,456(sp)
    80006082:	641e                	ld	s0,448(sp)
    80006084:	74fa                	ld	s1,440(sp)
    80006086:	795a                	ld	s2,432(sp)
    80006088:	79ba                	ld	s3,424(sp)
    8000608a:	7a1a                	ld	s4,416(sp)
    8000608c:	6afa                	ld	s5,408(sp)
    8000608e:	6179                	addi	sp,sp,464
    80006090:	8082                	ret

0000000080006092 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006092:	7139                	addi	sp,sp,-64
    80006094:	fc06                	sd	ra,56(sp)
    80006096:	f822                	sd	s0,48(sp)
    80006098:	f426                	sd	s1,40(sp)
    8000609a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000609c:	ffffc097          	auipc	ra,0xffffc
    800060a0:	a34080e7          	jalr	-1484(ra) # 80001ad0 <myproc>
    800060a4:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800060a6:	fd840593          	addi	a1,s0,-40
    800060aa:	4501                	li	a0,0
    800060ac:	ffffd097          	auipc	ra,0xffffd
    800060b0:	e26080e7          	jalr	-474(ra) # 80002ed2 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800060b4:	fc840593          	addi	a1,s0,-56
    800060b8:	fd040513          	addi	a0,s0,-48
    800060bc:	fffff097          	auipc	ra,0xfffff
    800060c0:	dd6080e7          	jalr	-554(ra) # 80004e92 <pipealloc>
    return -1;
    800060c4:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800060c6:	0c054463          	bltz	a0,8000618e <sys_pipe+0xfc>
  fd0 = -1;
    800060ca:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800060ce:	fd043503          	ld	a0,-48(s0)
    800060d2:	fffff097          	auipc	ra,0xfffff
    800060d6:	518080e7          	jalr	1304(ra) # 800055ea <fdalloc>
    800060da:	fca42223          	sw	a0,-60(s0)
    800060de:	08054b63          	bltz	a0,80006174 <sys_pipe+0xe2>
    800060e2:	fc843503          	ld	a0,-56(s0)
    800060e6:	fffff097          	auipc	ra,0xfffff
    800060ea:	504080e7          	jalr	1284(ra) # 800055ea <fdalloc>
    800060ee:	fca42023          	sw	a0,-64(s0)
    800060f2:	06054863          	bltz	a0,80006162 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800060f6:	4691                	li	a3,4
    800060f8:	fc440613          	addi	a2,s0,-60
    800060fc:	fd843583          	ld	a1,-40(s0)
    80006100:	6ca8                	ld	a0,88(s1)
    80006102:	ffffb097          	auipc	ra,0xffffb
    80006106:	582080e7          	jalr	1410(ra) # 80001684 <copyout>
    8000610a:	02054063          	bltz	a0,8000612a <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000610e:	4691                	li	a3,4
    80006110:	fc040613          	addi	a2,s0,-64
    80006114:	fd843583          	ld	a1,-40(s0)
    80006118:	0591                	addi	a1,a1,4
    8000611a:	6ca8                	ld	a0,88(s1)
    8000611c:	ffffb097          	auipc	ra,0xffffb
    80006120:	568080e7          	jalr	1384(ra) # 80001684 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006124:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006126:	06055463          	bgez	a0,8000618e <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    8000612a:	fc442783          	lw	a5,-60(s0)
    8000612e:	07e9                	addi	a5,a5,26
    80006130:	078e                	slli	a5,a5,0x3
    80006132:	97a6                	add	a5,a5,s1
    80006134:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80006138:	fc042503          	lw	a0,-64(s0)
    8000613c:	0569                	addi	a0,a0,26
    8000613e:	050e                	slli	a0,a0,0x3
    80006140:	94aa                	add	s1,s1,a0
    80006142:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80006146:	fd043503          	ld	a0,-48(s0)
    8000614a:	fffff097          	auipc	ra,0xfffff
    8000614e:	a18080e7          	jalr	-1512(ra) # 80004b62 <fileclose>
    fileclose(wf);
    80006152:	fc843503          	ld	a0,-56(s0)
    80006156:	fffff097          	auipc	ra,0xfffff
    8000615a:	a0c080e7          	jalr	-1524(ra) # 80004b62 <fileclose>
    return -1;
    8000615e:	57fd                	li	a5,-1
    80006160:	a03d                	j	8000618e <sys_pipe+0xfc>
    if(fd0 >= 0)
    80006162:	fc442783          	lw	a5,-60(s0)
    80006166:	0007c763          	bltz	a5,80006174 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    8000616a:	07e9                	addi	a5,a5,26
    8000616c:	078e                	slli	a5,a5,0x3
    8000616e:	94be                	add	s1,s1,a5
    80006170:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80006174:	fd043503          	ld	a0,-48(s0)
    80006178:	fffff097          	auipc	ra,0xfffff
    8000617c:	9ea080e7          	jalr	-1558(ra) # 80004b62 <fileclose>
    fileclose(wf);
    80006180:	fc843503          	ld	a0,-56(s0)
    80006184:	fffff097          	auipc	ra,0xfffff
    80006188:	9de080e7          	jalr	-1570(ra) # 80004b62 <fileclose>
    return -1;
    8000618c:	57fd                	li	a5,-1
}
    8000618e:	853e                	mv	a0,a5
    80006190:	70e2                	ld	ra,56(sp)
    80006192:	7442                	ld	s0,48(sp)
    80006194:	74a2                	ld	s1,40(sp)
    80006196:	6121                	addi	sp,sp,64
    80006198:	8082                	ret
    8000619a:	0000                	unimp
    8000619c:	0000                	unimp
	...

00000000800061a0 <kernelvec>:
    800061a0:	7111                	addi	sp,sp,-256
    800061a2:	e006                	sd	ra,0(sp)
    800061a4:	e40a                	sd	sp,8(sp)
    800061a6:	e80e                	sd	gp,16(sp)
    800061a8:	ec12                	sd	tp,24(sp)
    800061aa:	f016                	sd	t0,32(sp)
    800061ac:	f41a                	sd	t1,40(sp)
    800061ae:	f81e                	sd	t2,48(sp)
    800061b0:	fc22                	sd	s0,56(sp)
    800061b2:	e0a6                	sd	s1,64(sp)
    800061b4:	e4aa                	sd	a0,72(sp)
    800061b6:	e8ae                	sd	a1,80(sp)
    800061b8:	ecb2                	sd	a2,88(sp)
    800061ba:	f0b6                	sd	a3,96(sp)
    800061bc:	f4ba                	sd	a4,104(sp)
    800061be:	f8be                	sd	a5,112(sp)
    800061c0:	fcc2                	sd	a6,120(sp)
    800061c2:	e146                	sd	a7,128(sp)
    800061c4:	e54a                	sd	s2,136(sp)
    800061c6:	e94e                	sd	s3,144(sp)
    800061c8:	ed52                	sd	s4,152(sp)
    800061ca:	f156                	sd	s5,160(sp)
    800061cc:	f55a                	sd	s6,168(sp)
    800061ce:	f95e                	sd	s7,176(sp)
    800061d0:	fd62                	sd	s8,184(sp)
    800061d2:	e1e6                	sd	s9,192(sp)
    800061d4:	e5ea                	sd	s10,200(sp)
    800061d6:	e9ee                	sd	s11,208(sp)
    800061d8:	edf2                	sd	t3,216(sp)
    800061da:	f1f6                	sd	t4,224(sp)
    800061dc:	f5fa                	sd	t5,232(sp)
    800061de:	f9fe                	sd	t6,240(sp)
    800061e0:	b01fc0ef          	jal	ra,80002ce0 <kerneltrap>
    800061e4:	6082                	ld	ra,0(sp)
    800061e6:	6122                	ld	sp,8(sp)
    800061e8:	61c2                	ld	gp,16(sp)
    800061ea:	7282                	ld	t0,32(sp)
    800061ec:	7322                	ld	t1,40(sp)
    800061ee:	73c2                	ld	t2,48(sp)
    800061f0:	7462                	ld	s0,56(sp)
    800061f2:	6486                	ld	s1,64(sp)
    800061f4:	6526                	ld	a0,72(sp)
    800061f6:	65c6                	ld	a1,80(sp)
    800061f8:	6666                	ld	a2,88(sp)
    800061fa:	7686                	ld	a3,96(sp)
    800061fc:	7726                	ld	a4,104(sp)
    800061fe:	77c6                	ld	a5,112(sp)
    80006200:	7866                	ld	a6,120(sp)
    80006202:	688a                	ld	a7,128(sp)
    80006204:	692a                	ld	s2,136(sp)
    80006206:	69ca                	ld	s3,144(sp)
    80006208:	6a6a                	ld	s4,152(sp)
    8000620a:	7a8a                	ld	s5,160(sp)
    8000620c:	7b2a                	ld	s6,168(sp)
    8000620e:	7bca                	ld	s7,176(sp)
    80006210:	7c6a                	ld	s8,184(sp)
    80006212:	6c8e                	ld	s9,192(sp)
    80006214:	6d2e                	ld	s10,200(sp)
    80006216:	6dce                	ld	s11,208(sp)
    80006218:	6e6e                	ld	t3,216(sp)
    8000621a:	7e8e                	ld	t4,224(sp)
    8000621c:	7f2e                	ld	t5,232(sp)
    8000621e:	7fce                	ld	t6,240(sp)
    80006220:	6111                	addi	sp,sp,256
    80006222:	10200073          	sret
    80006226:	00000013          	nop
    8000622a:	00000013          	nop
    8000622e:	0001                	nop

0000000080006230 <timervec>:
    80006230:	34051573          	csrrw	a0,mscratch,a0
    80006234:	e10c                	sd	a1,0(a0)
    80006236:	e510                	sd	a2,8(a0)
    80006238:	e914                	sd	a3,16(a0)
    8000623a:	6d0c                	ld	a1,24(a0)
    8000623c:	7110                	ld	a2,32(a0)
    8000623e:	6194                	ld	a3,0(a1)
    80006240:	96b2                	add	a3,a3,a2
    80006242:	e194                	sd	a3,0(a1)
    80006244:	4589                	li	a1,2
    80006246:	14459073          	csrw	sip,a1
    8000624a:	6914                	ld	a3,16(a0)
    8000624c:	6510                	ld	a2,8(a0)
    8000624e:	610c                	ld	a1,0(a0)
    80006250:	34051573          	csrrw	a0,mscratch,a0
    80006254:	30200073          	mret
	...

000000008000625a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000625a:	1141                	addi	sp,sp,-16
    8000625c:	e422                	sd	s0,8(sp)
    8000625e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006260:	0c0007b7          	lui	a5,0xc000
    80006264:	4705                	li	a4,1
    80006266:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006268:	c3d8                	sw	a4,4(a5)
}
    8000626a:	6422                	ld	s0,8(sp)
    8000626c:	0141                	addi	sp,sp,16
    8000626e:	8082                	ret

0000000080006270 <plicinithart>:

void
plicinithart(void)
{
    80006270:	1141                	addi	sp,sp,-16
    80006272:	e406                	sd	ra,8(sp)
    80006274:	e022                	sd	s0,0(sp)
    80006276:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006278:	ffffc097          	auipc	ra,0xffffc
    8000627c:	82c080e7          	jalr	-2004(ra) # 80001aa4 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006280:	0085171b          	slliw	a4,a0,0x8
    80006284:	0c0027b7          	lui	a5,0xc002
    80006288:	97ba                	add	a5,a5,a4
    8000628a:	40200713          	li	a4,1026
    8000628e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006292:	00d5151b          	slliw	a0,a0,0xd
    80006296:	0c2017b7          	lui	a5,0xc201
    8000629a:	953e                	add	a0,a0,a5
    8000629c:	00052023          	sw	zero,0(a0)
}
    800062a0:	60a2                	ld	ra,8(sp)
    800062a2:	6402                	ld	s0,0(sp)
    800062a4:	0141                	addi	sp,sp,16
    800062a6:	8082                	ret

00000000800062a8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800062a8:	1141                	addi	sp,sp,-16
    800062aa:	e406                	sd	ra,8(sp)
    800062ac:	e022                	sd	s0,0(sp)
    800062ae:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800062b0:	ffffb097          	auipc	ra,0xffffb
    800062b4:	7f4080e7          	jalr	2036(ra) # 80001aa4 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800062b8:	00d5179b          	slliw	a5,a0,0xd
    800062bc:	0c201537          	lui	a0,0xc201
    800062c0:	953e                	add	a0,a0,a5
  return irq;
}
    800062c2:	4148                	lw	a0,4(a0)
    800062c4:	60a2                	ld	ra,8(sp)
    800062c6:	6402                	ld	s0,0(sp)
    800062c8:	0141                	addi	sp,sp,16
    800062ca:	8082                	ret

00000000800062cc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800062cc:	1101                	addi	sp,sp,-32
    800062ce:	ec06                	sd	ra,24(sp)
    800062d0:	e822                	sd	s0,16(sp)
    800062d2:	e426                	sd	s1,8(sp)
    800062d4:	1000                	addi	s0,sp,32
    800062d6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800062d8:	ffffb097          	auipc	ra,0xffffb
    800062dc:	7cc080e7          	jalr	1996(ra) # 80001aa4 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800062e0:	00d5151b          	slliw	a0,a0,0xd
    800062e4:	0c2017b7          	lui	a5,0xc201
    800062e8:	97aa                	add	a5,a5,a0
    800062ea:	c3c4                	sw	s1,4(a5)
}
    800062ec:	60e2                	ld	ra,24(sp)
    800062ee:	6442                	ld	s0,16(sp)
    800062f0:	64a2                	ld	s1,8(sp)
    800062f2:	6105                	addi	sp,sp,32
    800062f4:	8082                	ret

00000000800062f6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800062f6:	1141                	addi	sp,sp,-16
    800062f8:	e406                	sd	ra,8(sp)
    800062fa:	e022                	sd	s0,0(sp)
    800062fc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800062fe:	479d                	li	a5,7
    80006300:	04a7cc63          	blt	a5,a0,80006358 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006304:	0001d797          	auipc	a5,0x1d
    80006308:	61c78793          	addi	a5,a5,1564 # 80023920 <disk>
    8000630c:	97aa                	add	a5,a5,a0
    8000630e:	0187c783          	lbu	a5,24(a5)
    80006312:	ebb9                	bnez	a5,80006368 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006314:	00451613          	slli	a2,a0,0x4
    80006318:	0001d797          	auipc	a5,0x1d
    8000631c:	60878793          	addi	a5,a5,1544 # 80023920 <disk>
    80006320:	6394                	ld	a3,0(a5)
    80006322:	96b2                	add	a3,a3,a2
    80006324:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006328:	6398                	ld	a4,0(a5)
    8000632a:	9732                	add	a4,a4,a2
    8000632c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006330:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006334:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006338:	953e                	add	a0,a0,a5
    8000633a:	4785                	li	a5,1
    8000633c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80006340:	0001d517          	auipc	a0,0x1d
    80006344:	5f850513          	addi	a0,a0,1528 # 80023938 <disk+0x18>
    80006348:	ffffc097          	auipc	ra,0xffffc
    8000634c:	0d6080e7          	jalr	214(ra) # 8000241e <wakeup>
}
    80006350:	60a2                	ld	ra,8(sp)
    80006352:	6402                	ld	s0,0(sp)
    80006354:	0141                	addi	sp,sp,16
    80006356:	8082                	ret
    panic("free_desc 1");
    80006358:	00002517          	auipc	a0,0x2
    8000635c:	54050513          	addi	a0,a0,1344 # 80008898 <syscalls+0x310>
    80006360:	ffffa097          	auipc	ra,0xffffa
    80006364:	1e4080e7          	jalr	484(ra) # 80000544 <panic>
    panic("free_desc 2");
    80006368:	00002517          	auipc	a0,0x2
    8000636c:	54050513          	addi	a0,a0,1344 # 800088a8 <syscalls+0x320>
    80006370:	ffffa097          	auipc	ra,0xffffa
    80006374:	1d4080e7          	jalr	468(ra) # 80000544 <panic>

0000000080006378 <virtio_disk_init>:
{
    80006378:	1101                	addi	sp,sp,-32
    8000637a:	ec06                	sd	ra,24(sp)
    8000637c:	e822                	sd	s0,16(sp)
    8000637e:	e426                	sd	s1,8(sp)
    80006380:	e04a                	sd	s2,0(sp)
    80006382:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006384:	00002597          	auipc	a1,0x2
    80006388:	53458593          	addi	a1,a1,1332 # 800088b8 <syscalls+0x330>
    8000638c:	0001d517          	auipc	a0,0x1d
    80006390:	6bc50513          	addi	a0,a0,1724 # 80023a48 <disk+0x128>
    80006394:	ffffa097          	auipc	ra,0xffffa
    80006398:	7c6080e7          	jalr	1990(ra) # 80000b5a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000639c:	100017b7          	lui	a5,0x10001
    800063a0:	4398                	lw	a4,0(a5)
    800063a2:	2701                	sext.w	a4,a4
    800063a4:	747277b7          	lui	a5,0x74727
    800063a8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800063ac:	14f71e63          	bne	a4,a5,80006508 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800063b0:	100017b7          	lui	a5,0x10001
    800063b4:	43dc                	lw	a5,4(a5)
    800063b6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800063b8:	4709                	li	a4,2
    800063ba:	14e79763          	bne	a5,a4,80006508 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800063be:	100017b7          	lui	a5,0x10001
    800063c2:	479c                	lw	a5,8(a5)
    800063c4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800063c6:	14e79163          	bne	a5,a4,80006508 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800063ca:	100017b7          	lui	a5,0x10001
    800063ce:	47d8                	lw	a4,12(a5)
    800063d0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800063d2:	554d47b7          	lui	a5,0x554d4
    800063d6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800063da:	12f71763          	bne	a4,a5,80006508 <virtio_disk_init+0x190>
  *R(VIRTIO_MMIO_STATUS) = status;
    800063de:	100017b7          	lui	a5,0x10001
    800063e2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800063e6:	4705                	li	a4,1
    800063e8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800063ea:	470d                	li	a4,3
    800063ec:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800063ee:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800063f0:	c7ffe737          	lui	a4,0xc7ffe
    800063f4:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdacff>
    800063f8:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800063fa:	2701                	sext.w	a4,a4
    800063fc:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800063fe:	472d                	li	a4,11
    80006400:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006402:	0707a903          	lw	s2,112(a5)
    80006406:	2901                	sext.w	s2,s2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006408:	00897793          	andi	a5,s2,8
    8000640c:	10078663          	beqz	a5,80006518 <virtio_disk_init+0x1a0>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006410:	100017b7          	lui	a5,0x10001
    80006414:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006418:	43fc                	lw	a5,68(a5)
    8000641a:	2781                	sext.w	a5,a5
    8000641c:	10079663          	bnez	a5,80006528 <virtio_disk_init+0x1b0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006420:	100017b7          	lui	a5,0x10001
    80006424:	5bdc                	lw	a5,52(a5)
    80006426:	2781                	sext.w	a5,a5
  if(max == 0)
    80006428:	10078863          	beqz	a5,80006538 <virtio_disk_init+0x1c0>
  if(max < NUM)
    8000642c:	471d                	li	a4,7
    8000642e:	10f77d63          	bgeu	a4,a5,80006548 <virtio_disk_init+0x1d0>
  disk.desc = kalloc();
    80006432:	ffffa097          	auipc	ra,0xffffa
    80006436:	6c8080e7          	jalr	1736(ra) # 80000afa <kalloc>
    8000643a:	0001d497          	auipc	s1,0x1d
    8000643e:	4e648493          	addi	s1,s1,1254 # 80023920 <disk>
    80006442:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006444:	ffffa097          	auipc	ra,0xffffa
    80006448:	6b6080e7          	jalr	1718(ra) # 80000afa <kalloc>
    8000644c:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000644e:	ffffa097          	auipc	ra,0xffffa
    80006452:	6ac080e7          	jalr	1708(ra) # 80000afa <kalloc>
    80006456:	87aa                	mv	a5,a0
    80006458:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    8000645a:	6088                	ld	a0,0(s1)
    8000645c:	cd75                	beqz	a0,80006558 <virtio_disk_init+0x1e0>
    8000645e:	0001d717          	auipc	a4,0x1d
    80006462:	4ca73703          	ld	a4,1226(a4) # 80023928 <disk+0x8>
    80006466:	cb6d                	beqz	a4,80006558 <virtio_disk_init+0x1e0>
    80006468:	cbe5                	beqz	a5,80006558 <virtio_disk_init+0x1e0>
  memset(disk.desc, 0, PGSIZE);
    8000646a:	6605                	lui	a2,0x1
    8000646c:	4581                	li	a1,0
    8000646e:	ffffb097          	auipc	ra,0xffffb
    80006472:	878080e7          	jalr	-1928(ra) # 80000ce6 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006476:	0001d497          	auipc	s1,0x1d
    8000647a:	4aa48493          	addi	s1,s1,1194 # 80023920 <disk>
    8000647e:	6605                	lui	a2,0x1
    80006480:	4581                	li	a1,0
    80006482:	6488                	ld	a0,8(s1)
    80006484:	ffffb097          	auipc	ra,0xffffb
    80006488:	862080e7          	jalr	-1950(ra) # 80000ce6 <memset>
  memset(disk.used, 0, PGSIZE);
    8000648c:	6605                	lui	a2,0x1
    8000648e:	4581                	li	a1,0
    80006490:	6888                	ld	a0,16(s1)
    80006492:	ffffb097          	auipc	ra,0xffffb
    80006496:	854080e7          	jalr	-1964(ra) # 80000ce6 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000649a:	100017b7          	lui	a5,0x10001
    8000649e:	4721                	li	a4,8
    800064a0:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800064a2:	4098                	lw	a4,0(s1)
    800064a4:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800064a8:	40d8                	lw	a4,4(s1)
    800064aa:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800064ae:	6498                	ld	a4,8(s1)
    800064b0:	0007069b          	sext.w	a3,a4
    800064b4:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800064b8:	9701                	srai	a4,a4,0x20
    800064ba:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800064be:	6898                	ld	a4,16(s1)
    800064c0:	0007069b          	sext.w	a3,a4
    800064c4:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800064c8:	9701                	srai	a4,a4,0x20
    800064ca:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800064ce:	4685                	li	a3,1
    800064d0:	c3f4                	sw	a3,68(a5)
    disk.free[i] = 1;
    800064d2:	4705                	li	a4,1
    800064d4:	00d48c23          	sb	a3,24(s1)
    800064d8:	00e48ca3          	sb	a4,25(s1)
    800064dc:	00e48d23          	sb	a4,26(s1)
    800064e0:	00e48da3          	sb	a4,27(s1)
    800064e4:	00e48e23          	sb	a4,28(s1)
    800064e8:	00e48ea3          	sb	a4,29(s1)
    800064ec:	00e48f23          	sb	a4,30(s1)
    800064f0:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800064f4:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800064f8:	0727a823          	sw	s2,112(a5)
}
    800064fc:	60e2                	ld	ra,24(sp)
    800064fe:	6442                	ld	s0,16(sp)
    80006500:	64a2                	ld	s1,8(sp)
    80006502:	6902                	ld	s2,0(sp)
    80006504:	6105                	addi	sp,sp,32
    80006506:	8082                	ret
    panic("could not find virtio disk");
    80006508:	00002517          	auipc	a0,0x2
    8000650c:	3c050513          	addi	a0,a0,960 # 800088c8 <syscalls+0x340>
    80006510:	ffffa097          	auipc	ra,0xffffa
    80006514:	034080e7          	jalr	52(ra) # 80000544 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006518:	00002517          	auipc	a0,0x2
    8000651c:	3d050513          	addi	a0,a0,976 # 800088e8 <syscalls+0x360>
    80006520:	ffffa097          	auipc	ra,0xffffa
    80006524:	024080e7          	jalr	36(ra) # 80000544 <panic>
    panic("virtio disk should not be ready");
    80006528:	00002517          	auipc	a0,0x2
    8000652c:	3e050513          	addi	a0,a0,992 # 80008908 <syscalls+0x380>
    80006530:	ffffa097          	auipc	ra,0xffffa
    80006534:	014080e7          	jalr	20(ra) # 80000544 <panic>
    panic("virtio disk has no queue 0");
    80006538:	00002517          	auipc	a0,0x2
    8000653c:	3f050513          	addi	a0,a0,1008 # 80008928 <syscalls+0x3a0>
    80006540:	ffffa097          	auipc	ra,0xffffa
    80006544:	004080e7          	jalr	4(ra) # 80000544 <panic>
    panic("virtio disk max queue too short");
    80006548:	00002517          	auipc	a0,0x2
    8000654c:	40050513          	addi	a0,a0,1024 # 80008948 <syscalls+0x3c0>
    80006550:	ffffa097          	auipc	ra,0xffffa
    80006554:	ff4080e7          	jalr	-12(ra) # 80000544 <panic>
    panic("virtio disk kalloc");
    80006558:	00002517          	auipc	a0,0x2
    8000655c:	41050513          	addi	a0,a0,1040 # 80008968 <syscalls+0x3e0>
    80006560:	ffffa097          	auipc	ra,0xffffa
    80006564:	fe4080e7          	jalr	-28(ra) # 80000544 <panic>

0000000080006568 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006568:	7159                	addi	sp,sp,-112
    8000656a:	f486                	sd	ra,104(sp)
    8000656c:	f0a2                	sd	s0,96(sp)
    8000656e:	eca6                	sd	s1,88(sp)
    80006570:	e8ca                	sd	s2,80(sp)
    80006572:	e4ce                	sd	s3,72(sp)
    80006574:	e0d2                	sd	s4,64(sp)
    80006576:	fc56                	sd	s5,56(sp)
    80006578:	f85a                	sd	s6,48(sp)
    8000657a:	f45e                	sd	s7,40(sp)
    8000657c:	f062                	sd	s8,32(sp)
    8000657e:	ec66                	sd	s9,24(sp)
    80006580:	e86a                	sd	s10,16(sp)
    80006582:	1880                	addi	s0,sp,112
    80006584:	892a                	mv	s2,a0
    80006586:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006588:	00c52c83          	lw	s9,12(a0)
    8000658c:	001c9c9b          	slliw	s9,s9,0x1
    80006590:	1c82                	slli	s9,s9,0x20
    80006592:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006596:	0001d517          	auipc	a0,0x1d
    8000659a:	4b250513          	addi	a0,a0,1202 # 80023a48 <disk+0x128>
    8000659e:	ffffa097          	auipc	ra,0xffffa
    800065a2:	64c080e7          	jalr	1612(ra) # 80000bea <acquire>
  for(int i = 0; i < 3; i++){
    800065a6:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800065a8:	4ba1                	li	s7,8
      disk.free[i] = 0;
    800065aa:	0001db17          	auipc	s6,0x1d
    800065ae:	376b0b13          	addi	s6,s6,886 # 80023920 <disk>
  for(int i = 0; i < 3; i++){
    800065b2:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    800065b4:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800065b6:	0001dc17          	auipc	s8,0x1d
    800065ba:	492c0c13          	addi	s8,s8,1170 # 80023a48 <disk+0x128>
    800065be:	a8b5                	j	8000663a <virtio_disk_rw+0xd2>
      disk.free[i] = 0;
    800065c0:	00fb06b3          	add	a3,s6,a5
    800065c4:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    800065c8:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    800065ca:	0207c563          	bltz	a5,800065f4 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800065ce:	2485                	addiw	s1,s1,1
    800065d0:	0711                	addi	a4,a4,4
    800065d2:	1f548a63          	beq	s1,s5,800067c6 <virtio_disk_rw+0x25e>
    idx[i] = alloc_desc();
    800065d6:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    800065d8:	0001d697          	auipc	a3,0x1d
    800065dc:	34868693          	addi	a3,a3,840 # 80023920 <disk>
    800065e0:	87d2                	mv	a5,s4
    if(disk.free[i]){
    800065e2:	0186c583          	lbu	a1,24(a3)
    800065e6:	fde9                	bnez	a1,800065c0 <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800065e8:	2785                	addiw	a5,a5,1
    800065ea:	0685                	addi	a3,a3,1
    800065ec:	ff779be3          	bne	a5,s7,800065e2 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800065f0:	57fd                	li	a5,-1
    800065f2:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    800065f4:	02905a63          	blez	s1,80006628 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800065f8:	f9042503          	lw	a0,-112(s0)
    800065fc:	00000097          	auipc	ra,0x0
    80006600:	cfa080e7          	jalr	-774(ra) # 800062f6 <free_desc>
      for(int j = 0; j < i; j++)
    80006604:	4785                	li	a5,1
    80006606:	0297d163          	bge	a5,s1,80006628 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000660a:	f9442503          	lw	a0,-108(s0)
    8000660e:	00000097          	auipc	ra,0x0
    80006612:	ce8080e7          	jalr	-792(ra) # 800062f6 <free_desc>
      for(int j = 0; j < i; j++)
    80006616:	4789                	li	a5,2
    80006618:	0097d863          	bge	a5,s1,80006628 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000661c:	f9842503          	lw	a0,-104(s0)
    80006620:	00000097          	auipc	ra,0x0
    80006624:	cd6080e7          	jalr	-810(ra) # 800062f6 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006628:	85e2                	mv	a1,s8
    8000662a:	0001d517          	auipc	a0,0x1d
    8000662e:	30e50513          	addi	a0,a0,782 # 80023938 <disk+0x18>
    80006632:	ffffc097          	auipc	ra,0xffffc
    80006636:	c0e080e7          	jalr	-1010(ra) # 80002240 <sleep>
  for(int i = 0; i < 3; i++){
    8000663a:	f9040713          	addi	a4,s0,-112
    8000663e:	84ce                	mv	s1,s3
    80006640:	bf59                	j	800065d6 <virtio_disk_rw+0x6e>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80006642:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    80006646:	00479693          	slli	a3,a5,0x4
    8000664a:	0001d797          	auipc	a5,0x1d
    8000664e:	2d678793          	addi	a5,a5,726 # 80023920 <disk>
    80006652:	97b6                	add	a5,a5,a3
    80006654:	4685                	li	a3,1
    80006656:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006658:	0001d597          	auipc	a1,0x1d
    8000665c:	2c858593          	addi	a1,a1,712 # 80023920 <disk>
    80006660:	00a60793          	addi	a5,a2,10
    80006664:	0792                	slli	a5,a5,0x4
    80006666:	97ae                	add	a5,a5,a1
    80006668:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    8000666c:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006670:	f6070693          	addi	a3,a4,-160
    80006674:	619c                	ld	a5,0(a1)
    80006676:	97b6                	add	a5,a5,a3
    80006678:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000667a:	6188                	ld	a0,0(a1)
    8000667c:	96aa                	add	a3,a3,a0
    8000667e:	47c1                	li	a5,16
    80006680:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006682:	4785                	li	a5,1
    80006684:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006688:	f9442783          	lw	a5,-108(s0)
    8000668c:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006690:	0792                	slli	a5,a5,0x4
    80006692:	953e                	add	a0,a0,a5
    80006694:	05890693          	addi	a3,s2,88
    80006698:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000669a:	6188                	ld	a0,0(a1)
    8000669c:	97aa                	add	a5,a5,a0
    8000669e:	40000693          	li	a3,1024
    800066a2:	c794                	sw	a3,8(a5)
  if(write)
    800066a4:	100d0d63          	beqz	s10,800067be <virtio_disk_rw+0x256>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800066a8:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800066ac:	00c7d683          	lhu	a3,12(a5)
    800066b0:	0016e693          	ori	a3,a3,1
    800066b4:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    800066b8:	f9842583          	lw	a1,-104(s0)
    800066bc:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800066c0:	0001d697          	auipc	a3,0x1d
    800066c4:	26068693          	addi	a3,a3,608 # 80023920 <disk>
    800066c8:	00260793          	addi	a5,a2,2
    800066cc:	0792                	slli	a5,a5,0x4
    800066ce:	97b6                	add	a5,a5,a3
    800066d0:	587d                	li	a6,-1
    800066d2:	01078823          	sb	a6,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800066d6:	0592                	slli	a1,a1,0x4
    800066d8:	952e                	add	a0,a0,a1
    800066da:	f9070713          	addi	a4,a4,-112
    800066de:	9736                	add	a4,a4,a3
    800066e0:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    800066e2:	6298                	ld	a4,0(a3)
    800066e4:	972e                	add	a4,a4,a1
    800066e6:	4585                	li	a1,1
    800066e8:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800066ea:	4509                	li	a0,2
    800066ec:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    800066f0:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800066f4:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    800066f8:	0127b423          	sd	s2,8(a5)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800066fc:	6698                	ld	a4,8(a3)
    800066fe:	00275783          	lhu	a5,2(a4)
    80006702:	8b9d                	andi	a5,a5,7
    80006704:	0786                	slli	a5,a5,0x1
    80006706:	97ba                	add	a5,a5,a4
    80006708:	00c79223          	sh	a2,4(a5)

  __sync_synchronize();
    8000670c:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006710:	6698                	ld	a4,8(a3)
    80006712:	00275783          	lhu	a5,2(a4)
    80006716:	2785                	addiw	a5,a5,1
    80006718:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000671c:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006720:	100017b7          	lui	a5,0x10001
    80006724:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006728:	00492703          	lw	a4,4(s2)
    8000672c:	4785                	li	a5,1
    8000672e:	02f71163          	bne	a4,a5,80006750 <virtio_disk_rw+0x1e8>
    sleep(b, &disk.vdisk_lock);
    80006732:	0001d997          	auipc	s3,0x1d
    80006736:	31698993          	addi	s3,s3,790 # 80023a48 <disk+0x128>
  while(b->disk == 1) {
    8000673a:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000673c:	85ce                	mv	a1,s3
    8000673e:	854a                	mv	a0,s2
    80006740:	ffffc097          	auipc	ra,0xffffc
    80006744:	b00080e7          	jalr	-1280(ra) # 80002240 <sleep>
  while(b->disk == 1) {
    80006748:	00492783          	lw	a5,4(s2)
    8000674c:	fe9788e3          	beq	a5,s1,8000673c <virtio_disk_rw+0x1d4>
  }

  disk.info[idx[0]].b = 0;
    80006750:	f9042903          	lw	s2,-112(s0)
    80006754:	00290793          	addi	a5,s2,2
    80006758:	00479713          	slli	a4,a5,0x4
    8000675c:	0001d797          	auipc	a5,0x1d
    80006760:	1c478793          	addi	a5,a5,452 # 80023920 <disk>
    80006764:	97ba                	add	a5,a5,a4
    80006766:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000676a:	0001d997          	auipc	s3,0x1d
    8000676e:	1b698993          	addi	s3,s3,438 # 80023920 <disk>
    80006772:	00491713          	slli	a4,s2,0x4
    80006776:	0009b783          	ld	a5,0(s3)
    8000677a:	97ba                	add	a5,a5,a4
    8000677c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006780:	854a                	mv	a0,s2
    80006782:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006786:	00000097          	auipc	ra,0x0
    8000678a:	b70080e7          	jalr	-1168(ra) # 800062f6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000678e:	8885                	andi	s1,s1,1
    80006790:	f0ed                	bnez	s1,80006772 <virtio_disk_rw+0x20a>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006792:	0001d517          	auipc	a0,0x1d
    80006796:	2b650513          	addi	a0,a0,694 # 80023a48 <disk+0x128>
    8000679a:	ffffa097          	auipc	ra,0xffffa
    8000679e:	504080e7          	jalr	1284(ra) # 80000c9e <release>
}
    800067a2:	70a6                	ld	ra,104(sp)
    800067a4:	7406                	ld	s0,96(sp)
    800067a6:	64e6                	ld	s1,88(sp)
    800067a8:	6946                	ld	s2,80(sp)
    800067aa:	69a6                	ld	s3,72(sp)
    800067ac:	6a06                	ld	s4,64(sp)
    800067ae:	7ae2                	ld	s5,56(sp)
    800067b0:	7b42                	ld	s6,48(sp)
    800067b2:	7ba2                	ld	s7,40(sp)
    800067b4:	7c02                	ld	s8,32(sp)
    800067b6:	6ce2                	ld	s9,24(sp)
    800067b8:	6d42                	ld	s10,16(sp)
    800067ba:	6165                	addi	sp,sp,112
    800067bc:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800067be:	4689                	li	a3,2
    800067c0:	00d79623          	sh	a3,12(a5)
    800067c4:	b5e5                	j	800066ac <virtio_disk_rw+0x144>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800067c6:	f9042603          	lw	a2,-112(s0)
    800067ca:	00a60713          	addi	a4,a2,10
    800067ce:	0712                	slli	a4,a4,0x4
    800067d0:	0001d517          	auipc	a0,0x1d
    800067d4:	15850513          	addi	a0,a0,344 # 80023928 <disk+0x8>
    800067d8:	953a                	add	a0,a0,a4
  if(write)
    800067da:	e60d14e3          	bnez	s10,80006642 <virtio_disk_rw+0xda>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    800067de:	00a60793          	addi	a5,a2,10
    800067e2:	00479693          	slli	a3,a5,0x4
    800067e6:	0001d797          	auipc	a5,0x1d
    800067ea:	13a78793          	addi	a5,a5,314 # 80023920 <disk>
    800067ee:	97b6                	add	a5,a5,a3
    800067f0:	0007a423          	sw	zero,8(a5)
    800067f4:	b595                	j	80006658 <virtio_disk_rw+0xf0>

00000000800067f6 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800067f6:	1101                	addi	sp,sp,-32
    800067f8:	ec06                	sd	ra,24(sp)
    800067fa:	e822                	sd	s0,16(sp)
    800067fc:	e426                	sd	s1,8(sp)
    800067fe:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006800:	0001d497          	auipc	s1,0x1d
    80006804:	12048493          	addi	s1,s1,288 # 80023920 <disk>
    80006808:	0001d517          	auipc	a0,0x1d
    8000680c:	24050513          	addi	a0,a0,576 # 80023a48 <disk+0x128>
    80006810:	ffffa097          	auipc	ra,0xffffa
    80006814:	3da080e7          	jalr	986(ra) # 80000bea <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006818:	10001737          	lui	a4,0x10001
    8000681c:	533c                	lw	a5,96(a4)
    8000681e:	8b8d                	andi	a5,a5,3
    80006820:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006822:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006826:	689c                	ld	a5,16(s1)
    80006828:	0204d703          	lhu	a4,32(s1)
    8000682c:	0027d783          	lhu	a5,2(a5)
    80006830:	04f70863          	beq	a4,a5,80006880 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006834:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006838:	6898                	ld	a4,16(s1)
    8000683a:	0204d783          	lhu	a5,32(s1)
    8000683e:	8b9d                	andi	a5,a5,7
    80006840:	078e                	slli	a5,a5,0x3
    80006842:	97ba                	add	a5,a5,a4
    80006844:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006846:	00278713          	addi	a4,a5,2
    8000684a:	0712                	slli	a4,a4,0x4
    8000684c:	9726                	add	a4,a4,s1
    8000684e:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006852:	e721                	bnez	a4,8000689a <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006854:	0789                	addi	a5,a5,2
    80006856:	0792                	slli	a5,a5,0x4
    80006858:	97a6                	add	a5,a5,s1
    8000685a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000685c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006860:	ffffc097          	auipc	ra,0xffffc
    80006864:	bbe080e7          	jalr	-1090(ra) # 8000241e <wakeup>

    disk.used_idx += 1;
    80006868:	0204d783          	lhu	a5,32(s1)
    8000686c:	2785                	addiw	a5,a5,1
    8000686e:	17c2                	slli	a5,a5,0x30
    80006870:	93c1                	srli	a5,a5,0x30
    80006872:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006876:	6898                	ld	a4,16(s1)
    80006878:	00275703          	lhu	a4,2(a4)
    8000687c:	faf71ce3          	bne	a4,a5,80006834 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006880:	0001d517          	auipc	a0,0x1d
    80006884:	1c850513          	addi	a0,a0,456 # 80023a48 <disk+0x128>
    80006888:	ffffa097          	auipc	ra,0xffffa
    8000688c:	416080e7          	jalr	1046(ra) # 80000c9e <release>
}
    80006890:	60e2                	ld	ra,24(sp)
    80006892:	6442                	ld	s0,16(sp)
    80006894:	64a2                	ld	s1,8(sp)
    80006896:	6105                	addi	sp,sp,32
    80006898:	8082                	ret
      panic("virtio_disk_intr status");
    8000689a:	00002517          	auipc	a0,0x2
    8000689e:	0e650513          	addi	a0,a0,230 # 80008980 <syscalls+0x3f8>
    800068a2:	ffffa097          	auipc	ra,0xffffa
    800068a6:	ca2080e7          	jalr	-862(ra) # 80000544 <panic>
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
