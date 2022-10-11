
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	b6013103          	ld	sp,-1184(sp) # 80008b60 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000056:	b6e70713          	addi	a4,a4,-1170 # 80008bc0 <timer_scratch>
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
    80000068:	f0c78793          	addi	a5,a5,-244 # 80005f70 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdadcf>
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
    80000130:	54c080e7          	jalr	1356(ra) # 80002678 <either_copyin>
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
    80000190:	b7450513          	addi	a0,a0,-1164 # 80010d00 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	a56080e7          	jalr	-1450(ra) # 80000bea <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019c:	00011497          	auipc	s1,0x11
    800001a0:	b6448493          	addi	s1,s1,-1180 # 80010d00 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a4:	89a6                	mv	s3,s1
    800001a6:	00011917          	auipc	s2,0x11
    800001aa:	bf290913          	addi	s2,s2,-1038 # 80010d98 <cons+0x98>
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
    800001d0:	2ea080e7          	jalr	746(ra) # 800024b6 <killed>
    800001d4:	e535                	bnez	a0,80000240 <consoleread+0xdc>
      sleep(&cons.r, &cons.lock);
    800001d6:	85ce                	mv	a1,s3
    800001d8:	854a                	mv	a0,s2
    800001da:	00002097          	auipc	ra,0x2
    800001de:	00e080e7          	jalr	14(ra) # 800021e8 <sleep>
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
    8000021a:	40c080e7          	jalr	1036(ra) # 80002622 <either_copyout>
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
    8000022e:	ad650513          	addi	a0,a0,-1322 # 80010d00 <cons>
    80000232:	00001097          	auipc	ra,0x1
    80000236:	a6c080e7          	jalr	-1428(ra) # 80000c9e <release>

  return target - n;
    8000023a:	414b853b          	subw	a0,s7,s4
    8000023e:	a811                	j	80000252 <consoleread+0xee>
        release(&cons.lock);
    80000240:	00011517          	auipc	a0,0x11
    80000244:	ac050513          	addi	a0,a0,-1344 # 80010d00 <cons>
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
    8000027c:	b2f72023          	sw	a5,-1248(a4) # 80010d98 <cons+0x98>
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
    800002d6:	a2e50513          	addi	a0,a0,-1490 # 80010d00 <cons>
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
    800002fc:	3d6080e7          	jalr	982(ra) # 800026ce <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000300:	00011517          	auipc	a0,0x11
    80000304:	a0050513          	addi	a0,a0,-1536 # 80010d00 <cons>
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
    80000328:	9dc70713          	addi	a4,a4,-1572 # 80010d00 <cons>
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
    80000352:	9b278793          	addi	a5,a5,-1614 # 80010d00 <cons>
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
    80000380:	a1c7a783          	lw	a5,-1508(a5) # 80010d98 <cons+0x98>
    80000384:	9f1d                	subw	a4,a4,a5
    80000386:	08000793          	li	a5,128
    8000038a:	f6f71be3          	bne	a4,a5,80000300 <consoleintr+0x3c>
    8000038e:	a07d                	j	8000043c <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000390:	00011717          	auipc	a4,0x11
    80000394:	97070713          	addi	a4,a4,-1680 # 80010d00 <cons>
    80000398:	0a072783          	lw	a5,160(a4)
    8000039c:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a0:	00011497          	auipc	s1,0x11
    800003a4:	96048493          	addi	s1,s1,-1696 # 80010d00 <cons>
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
    800003e0:	92470713          	addi	a4,a4,-1756 # 80010d00 <cons>
    800003e4:	0a072783          	lw	a5,160(a4)
    800003e8:	09c72703          	lw	a4,156(a4)
    800003ec:	f0f70ae3          	beq	a4,a5,80000300 <consoleintr+0x3c>
      cons.e--;
    800003f0:	37fd                	addiw	a5,a5,-1
    800003f2:	00011717          	auipc	a4,0x11
    800003f6:	9af72723          	sw	a5,-1618(a4) # 80010da0 <cons+0xa0>
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
    8000041c:	8e878793          	addi	a5,a5,-1816 # 80010d00 <cons>
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
    80000440:	96c7a023          	sw	a2,-1696(a5) # 80010d9c <cons+0x9c>
        wakeup(&cons.r);
    80000444:	00011517          	auipc	a0,0x11
    80000448:	95450513          	addi	a0,a0,-1708 # 80010d98 <cons+0x98>
    8000044c:	00002097          	auipc	ra,0x2
    80000450:	e0a080e7          	jalr	-502(ra) # 80002256 <wakeup>
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
    8000046a:	89a50513          	addi	a0,a0,-1894 # 80010d00 <cons>
    8000046e:	00000097          	auipc	ra,0x0
    80000472:	6ec080e7          	jalr	1772(ra) # 80000b5a <initlock>

  uartinit();
    80000476:	00000097          	auipc	ra,0x0
    8000047a:	330080e7          	jalr	816(ra) # 800007a6 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000047e:	00022797          	auipc	a5,0x22
    80000482:	41a78793          	addi	a5,a5,1050 # 80022898 <devsw>
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
    80000554:	8607a823          	sw	zero,-1936(a5) # 80010dc0 <pr+0x18>
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
    80000576:	b5650513          	addi	a0,a0,-1194 # 800080c8 <digits+0x88>
    8000057a:	00000097          	auipc	ra,0x0
    8000057e:	014080e7          	jalr	20(ra) # 8000058e <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000582:	4785                	li	a5,1
    80000584:	00008717          	auipc	a4,0x8
    80000588:	5ef72e23          	sw	a5,1532(a4) # 80008b80 <panicked>
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
    800005c4:	800dad83          	lw	s11,-2048(s11) # 80010dc0 <pr+0x18>
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
    80000602:	7aa50513          	addi	a0,a0,1962 # 80010da8 <pr>
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
    80000766:	64650513          	addi	a0,a0,1606 # 80010da8 <pr>
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
    80000782:	62a48493          	addi	s1,s1,1578 # 80010da8 <pr>
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
    800007e2:	5ea50513          	addi	a0,a0,1514 # 80010dc8 <uart_tx_lock>
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
    8000080e:	3767a783          	lw	a5,886(a5) # 80008b80 <panicked>
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
    8000084a:	34273703          	ld	a4,834(a4) # 80008b88 <uart_tx_r>
    8000084e:	00008797          	auipc	a5,0x8
    80000852:	3427b783          	ld	a5,834(a5) # 80008b90 <uart_tx_w>
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
    80000874:	558a0a13          	addi	s4,s4,1368 # 80010dc8 <uart_tx_lock>
    uart_tx_r += 1;
    80000878:	00008497          	auipc	s1,0x8
    8000087c:	31048493          	addi	s1,s1,784 # 80008b88 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000880:	00008997          	auipc	s3,0x8
    80000884:	31098993          	addi	s3,s3,784 # 80008b90 <uart_tx_w>
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
    800008aa:	9b0080e7          	jalr	-1616(ra) # 80002256 <wakeup>
    
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
    800008e6:	4e650513          	addi	a0,a0,1254 # 80010dc8 <uart_tx_lock>
    800008ea:	00000097          	auipc	ra,0x0
    800008ee:	300080e7          	jalr	768(ra) # 80000bea <acquire>
  if(panicked){
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	28e7a783          	lw	a5,654(a5) # 80008b80 <panicked>
    800008fa:	e7c9                	bnez	a5,80000984 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008fc:	00008797          	auipc	a5,0x8
    80000900:	2947b783          	ld	a5,660(a5) # 80008b90 <uart_tx_w>
    80000904:	00008717          	auipc	a4,0x8
    80000908:	28473703          	ld	a4,644(a4) # 80008b88 <uart_tx_r>
    8000090c:	02070713          	addi	a4,a4,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000910:	00010a17          	auipc	s4,0x10
    80000914:	4b8a0a13          	addi	s4,s4,1208 # 80010dc8 <uart_tx_lock>
    80000918:	00008497          	auipc	s1,0x8
    8000091c:	27048493          	addi	s1,s1,624 # 80008b88 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000920:	00008917          	auipc	s2,0x8
    80000924:	27090913          	addi	s2,s2,624 # 80008b90 <uart_tx_w>
    80000928:	00f71f63          	bne	a4,a5,80000946 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000092c:	85d2                	mv	a1,s4
    8000092e:	8526                	mv	a0,s1
    80000930:	00002097          	auipc	ra,0x2
    80000934:	8b8080e7          	jalr	-1864(ra) # 800021e8 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000938:	00093783          	ld	a5,0(s2)
    8000093c:	6098                	ld	a4,0(s1)
    8000093e:	02070713          	addi	a4,a4,32
    80000942:	fef705e3          	beq	a4,a5,8000092c <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000946:	00010497          	auipc	s1,0x10
    8000094a:	48248493          	addi	s1,s1,1154 # 80010dc8 <uart_tx_lock>
    8000094e:	01f7f713          	andi	a4,a5,31
    80000952:	9726                	add	a4,a4,s1
    80000954:	01370c23          	sb	s3,24(a4)
  uart_tx_w += 1;
    80000958:	0785                	addi	a5,a5,1
    8000095a:	00008717          	auipc	a4,0x8
    8000095e:	22f73b23          	sd	a5,566(a4) # 80008b90 <uart_tx_w>
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
    800009d4:	3f848493          	addi	s1,s1,1016 # 80010dc8 <uart_tx_lock>
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
    80000a16:	01e78793          	addi	a5,a5,30 # 80023a30 <end>
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
    80000a36:	3ce90913          	addi	s2,s2,974 # 80010e00 <kmem>
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
    80000ad2:	33250513          	addi	a0,a0,818 # 80010e00 <kmem>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	084080e7          	jalr	132(ra) # 80000b5a <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ade:	45c5                	li	a1,17
    80000ae0:	05ee                	slli	a1,a1,0x1b
    80000ae2:	00023517          	auipc	a0,0x23
    80000ae6:	f4e50513          	addi	a0,a0,-178 # 80023a30 <end>
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
    80000b08:	2fc48493          	addi	s1,s1,764 # 80010e00 <kmem>
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
    80000b20:	2e450513          	addi	a0,a0,740 # 80010e00 <kmem>
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
    80000b4c:	2b850513          	addi	a0,a0,696 # 80010e00 <kmem>
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
    80000ea8:	cf470713          	addi	a4,a4,-780 # 80008b98 <started>
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
    80000ede:	934080e7          	jalr	-1740(ra) # 8000280e <trapinithart>
    // printf("trapinit done\n");
    plicinithart();   // ask PLIC for device interrupts
    80000ee2:	00005097          	auipc	ra,0x5
    80000ee6:	0ce080e7          	jalr	206(ra) # 80005fb0 <plicinithart>
    // printf("plicinit done\n");
  }

  // printf("about to call sceduler\n");
  scheduler();        
    80000eea:	00001097          	auipc	ra,0x1
    80000eee:	13a080e7          	jalr	314(ra) # 80002024 <scheduler>
    consoleinit();
    80000ef2:	fffff097          	auipc	ra,0xfffff
    80000ef6:	564080e7          	jalr	1380(ra) # 80000456 <consoleinit>
    printfinit();
    80000efa:	00000097          	auipc	ra,0x0
    80000efe:	87a080e7          	jalr	-1926(ra) # 80000774 <printfinit>
    printf("\n");
    80000f02:	00007517          	auipc	a0,0x7
    80000f06:	1c650513          	addi	a0,a0,454 # 800080c8 <digits+0x88>
    80000f0a:	fffff097          	auipc	ra,0xfffff
    80000f0e:	684080e7          	jalr	1668(ra) # 8000058e <printf>
    printf("xv6 kernel is booting\n");
    80000f12:	00007517          	auipc	a0,0x7
    80000f16:	18e50513          	addi	a0,a0,398 # 800080a0 <digits+0x60>
    80000f1a:	fffff097          	auipc	ra,0xfffff
    80000f1e:	674080e7          	jalr	1652(ra) # 8000058e <printf>
    printf("\n");
    80000f22:	00007517          	auipc	a0,0x7
    80000f26:	1a650513          	addi	a0,a0,422 # 800080c8 <digits+0x88>
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
    80000f56:	894080e7          	jalr	-1900(ra) # 800027e6 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f5a:	00002097          	auipc	ra,0x2
    80000f5e:	8b4080e7          	jalr	-1868(ra) # 8000280e <trapinithart>
    plicinit();      // set up interrupt controller
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	038080e7          	jalr	56(ra) # 80005f9a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f6a:	00005097          	auipc	ra,0x5
    80000f6e:	046080e7          	jalr	70(ra) # 80005fb0 <plicinithart>
    binit();         // buffer cache
    80000f72:	00002097          	auipc	ra,0x2
    80000f76:	200080e7          	jalr	512(ra) # 80003172 <binit>
    iinit();         // inode table
    80000f7a:	00003097          	auipc	ra,0x3
    80000f7e:	8a4080e7          	jalr	-1884(ra) # 8000381e <iinit>
    fileinit();      // file table
    80000f82:	00004097          	auipc	ra,0x4
    80000f86:	842080e7          	jalr	-1982(ra) # 800047c4 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f8a:	00005097          	auipc	ra,0x5
    80000f8e:	12e080e7          	jalr	302(ra) # 800060b8 <virtio_disk_init>
    userinit();      // first user process
    80000f92:	00001097          	auipc	ra,0x1
    80000f96:	e20080e7          	jalr	-480(ra) # 80001db2 <userinit>
    __sync_synchronize();
    80000f9a:	0ff0000f          	fence
    started = 1;
    80000f9e:	4785                	li	a5,1
    80000fa0:	00008717          	auipc	a4,0x8
    80000fa4:	bef72c23          	sw	a5,-1032(a4) # 80008b98 <started>
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
    80000fb8:	bec7b783          	ld	a5,-1044(a5) # 80008ba0 <kernel_pagetable>
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
    80001274:	92a7b823          	sd	a0,-1744(a5) # 80008ba0 <kernel_pagetable>
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
    800018bc:	99848493          	addi	s1,s1,-1640 # 80011250 <proc>
    800018c0:	00017a17          	auipc	s4,0x17
    800018c4:	d90a0a13          	addi	s4,s4,-624 # 80018650 <tickslock>
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
    80001972:	8e248493          	addi	s1,s1,-1822 # 80011250 <proc>
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
    8000198c:	cc8a0a13          	addi	s4,s4,-824 # 80018650 <tickslock>
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
    80001a0e:	41650513          	addi	a0,a0,1046 # 80010e20 <pid_lock>
    80001a12:	fffff097          	auipc	ra,0xfffff
    80001a16:	148080e7          	jalr	328(ra) # 80000b5a <initlock>
	initlock(&wait_lock, "wait_lock");
    80001a1a:	00006597          	auipc	a1,0x6
    80001a1e:	7e658593          	addi	a1,a1,2022 # 80008200 <digits+0x1c0>
    80001a22:	0000f517          	auipc	a0,0xf
    80001a26:	41650513          	addi	a0,a0,1046 # 80010e38 <wait_lock>
    80001a2a:	fffff097          	auipc	ra,0xfffff
    80001a2e:	130080e7          	jalr	304(ra) # 80000b5a <initlock>
	for (p = proc; p < &proc[NPROC]; p++)
    80001a32:	00010497          	auipc	s1,0x10
    80001a36:	81e48493          	addi	s1,s1,-2018 # 80011250 <proc>
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
    80001a58:	bfc98993          	addi	s3,s3,-1028 # 80018650 <tickslock>
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
    80001ac4:	39050513          	addi	a0,a0,912 # 80010e50 <cpus>
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
    80001aec:	33870713          	addi	a4,a4,824 # 80010e20 <pid_lock>
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
    80001b26:	e5e7a783          	lw	a5,-418(a5) # 80008980 <first.2432>
    80001b2a:	eb89                	bnez	a5,80001b3c <forkret+0x34>
		// be run from main().
		first = 0;
		fsinit(ROOTDEV);
	}

	usertrapret();
    80001b2c:	00001097          	auipc	ra,0x1
    80001b30:	cfa080e7          	jalr	-774(ra) # 80002826 <usertrapret>
}
    80001b34:	60a2                	ld	ra,8(sp)
    80001b36:	6402                	ld	s0,0(sp)
    80001b38:	0141                	addi	sp,sp,16
    80001b3a:	8082                	ret
		first = 0;
    80001b3c:	00007797          	auipc	a5,0x7
    80001b40:	e407a223          	sw	zero,-444(a5) # 80008980 <first.2432>
		fsinit(ROOTDEV);
    80001b44:	4505                	li	a0,1
    80001b46:	00002097          	auipc	ra,0x2
    80001b4a:	c58080e7          	jalr	-936(ra) # 8000379e <fsinit>
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
    80001b60:	2c490913          	addi	s2,s2,708 # 80010e20 <pid_lock>
    80001b64:	854a                	mv	a0,s2
    80001b66:	fffff097          	auipc	ra,0xfffff
    80001b6a:	084080e7          	jalr	132(ra) # 80000bea <acquire>
	pid = nextpid;
    80001b6e:	00007797          	auipc	a5,0x7
    80001b72:	e1678793          	addi	a5,a5,-490 # 80008984 <nextpid>
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
    80001cee:	56648493          	addi	s1,s1,1382 # 80011250 <proc>
    80001cf2:	00017997          	auipc	s3,0x17
    80001cf6:	95e98993          	addi	s3,s3,-1698 # 80018650 <tickslock>
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
    80001d20:	a889                	j	80001d72 <allocproc+0x96>
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
    80001d3c:	c139                	beqz	a0,80001d82 <allocproc+0xa6>
	p->pagetable = proc_pagetable(p);
    80001d3e:	8526                	mv	a0,s1
    80001d40:	00000097          	auipc	ra,0x0
    80001d44:	e56080e7          	jalr	-426(ra) # 80001b96 <proc_pagetable>
    80001d48:	89aa                	mv	s3,a0
    80001d4a:	eca8                	sd	a0,88(s1)
	if (p->pagetable == 0)
    80001d4c:	c539                	beqz	a0,80001d9a <allocproc+0xbe>
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
}
    80001d72:	8526                	mv	a0,s1
    80001d74:	70a2                	ld	ra,40(sp)
    80001d76:	7402                	ld	s0,32(sp)
    80001d78:	64e2                	ld	s1,24(sp)
    80001d7a:	6942                	ld	s2,16(sp)
    80001d7c:	69a2                	ld	s3,8(sp)
    80001d7e:	6145                	addi	sp,sp,48
    80001d80:	8082                	ret
		freeproc(p);
    80001d82:	8526                	mv	a0,s1
    80001d84:	00000097          	auipc	ra,0x0
    80001d88:	f00080e7          	jalr	-256(ra) # 80001c84 <freeproc>
		release(&p->lock);
    80001d8c:	854a                	mv	a0,s2
    80001d8e:	fffff097          	auipc	ra,0xfffff
    80001d92:	f10080e7          	jalr	-240(ra) # 80000c9e <release>
		return 0;
    80001d96:	84ce                	mv	s1,s3
    80001d98:	bfe9                	j	80001d72 <allocproc+0x96>
		freeproc(p);
    80001d9a:	8526                	mv	a0,s1
    80001d9c:	00000097          	auipc	ra,0x0
    80001da0:	ee8080e7          	jalr	-280(ra) # 80001c84 <freeproc>
		release(&p->lock);
    80001da4:	854a                	mv	a0,s2
    80001da6:	fffff097          	auipc	ra,0xfffff
    80001daa:	ef8080e7          	jalr	-264(ra) # 80000c9e <release>
		return 0;
    80001dae:	84ce                	mv	s1,s3
    80001db0:	b7c9                	j	80001d72 <allocproc+0x96>

0000000080001db2 <userinit>:
{
    80001db2:	1101                	addi	sp,sp,-32
    80001db4:	ec06                	sd	ra,24(sp)
    80001db6:	e822                	sd	s0,16(sp)
    80001db8:	e426                	sd	s1,8(sp)
    80001dba:	1000                	addi	s0,sp,32
	p = allocproc();
    80001dbc:	00000097          	auipc	ra,0x0
    80001dc0:	f20080e7          	jalr	-224(ra) # 80001cdc <allocproc>
    80001dc4:	84aa                	mv	s1,a0
	initproc = p;
    80001dc6:	00007797          	auipc	a5,0x7
    80001dca:	dea7b123          	sd	a0,-542(a5) # 80008ba8 <initproc>
	uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001dce:	03400613          	li	a2,52
    80001dd2:	00007597          	auipc	a1,0x7
    80001dd6:	bbe58593          	addi	a1,a1,-1090 # 80008990 <initcode>
    80001dda:	6d28                	ld	a0,88(a0)
    80001ddc:	fffff097          	auipc	ra,0xfffff
    80001de0:	596080e7          	jalr	1430(ra) # 80001372 <uvmfirst>
	p->sz = PGSIZE;
    80001de4:	6785                	lui	a5,0x1
    80001de6:	e8bc                	sd	a5,80(s1)
	p->trapframe->epc = 0;	   // user program counter
    80001de8:	70b8                	ld	a4,96(s1)
    80001dea:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
	p->trapframe->sp = PGSIZE; // user stack pointer
    80001dee:	70b8                	ld	a4,96(s1)
    80001df0:	fb1c                	sd	a5,48(a4)
	safestrcpy(p->name, "initcode", sizeof(p->name));
    80001df2:	4641                	li	a2,16
    80001df4:	00006597          	auipc	a1,0x6
    80001df8:	42458593          	addi	a1,a1,1060 # 80008218 <digits+0x1d8>
    80001dfc:	16048513          	addi	a0,s1,352
    80001e00:	fffff097          	auipc	ra,0xfffff
    80001e04:	038080e7          	jalr	56(ra) # 80000e38 <safestrcpy>
	p->cwd = namei("/");
    80001e08:	00006517          	auipc	a0,0x6
    80001e0c:	42050513          	addi	a0,a0,1056 # 80008228 <digits+0x1e8>
    80001e10:	00002097          	auipc	ra,0x2
    80001e14:	3b0080e7          	jalr	944(ra) # 800041c0 <namei>
    80001e18:	14a4bc23          	sd	a0,344(s1)
	p->state = RUNNABLE;
    80001e1c:	478d                	li	a5,3
    80001e1e:	d09c                	sw	a5,32(s1)
	release(&p->lock);
    80001e20:	00848513          	addi	a0,s1,8
    80001e24:	fffff097          	auipc	ra,0xfffff
    80001e28:	e7a080e7          	jalr	-390(ra) # 80000c9e <release>
}
    80001e2c:	60e2                	ld	ra,24(sp)
    80001e2e:	6442                	ld	s0,16(sp)
    80001e30:	64a2                	ld	s1,8(sp)
    80001e32:	6105                	addi	sp,sp,32
    80001e34:	8082                	ret

0000000080001e36 <growproc>:
{
    80001e36:	1101                	addi	sp,sp,-32
    80001e38:	ec06                	sd	ra,24(sp)
    80001e3a:	e822                	sd	s0,16(sp)
    80001e3c:	e426                	sd	s1,8(sp)
    80001e3e:	e04a                	sd	s2,0(sp)
    80001e40:	1000                	addi	s0,sp,32
    80001e42:	892a                	mv	s2,a0
	struct proc *p = myproc();
    80001e44:	00000097          	auipc	ra,0x0
    80001e48:	c8c080e7          	jalr	-884(ra) # 80001ad0 <myproc>
    80001e4c:	84aa                	mv	s1,a0
	sz = p->sz;
    80001e4e:	692c                	ld	a1,80(a0)
	if (n > 0)
    80001e50:	01204c63          	bgtz	s2,80001e68 <growproc+0x32>
	else if (n < 0)
    80001e54:	02094663          	bltz	s2,80001e80 <growproc+0x4a>
	p->sz = sz;
    80001e58:	e8ac                	sd	a1,80(s1)
	return 0;
    80001e5a:	4501                	li	a0,0
}
    80001e5c:	60e2                	ld	ra,24(sp)
    80001e5e:	6442                	ld	s0,16(sp)
    80001e60:	64a2                	ld	s1,8(sp)
    80001e62:	6902                	ld	s2,0(sp)
    80001e64:	6105                	addi	sp,sp,32
    80001e66:	8082                	ret
		if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001e68:	4691                	li	a3,4
    80001e6a:	00b90633          	add	a2,s2,a1
    80001e6e:	6d28                	ld	a0,88(a0)
    80001e70:	fffff097          	auipc	ra,0xfffff
    80001e74:	5bc080e7          	jalr	1468(ra) # 8000142c <uvmalloc>
    80001e78:	85aa                	mv	a1,a0
    80001e7a:	fd79                	bnez	a0,80001e58 <growproc+0x22>
			return -1;
    80001e7c:	557d                	li	a0,-1
    80001e7e:	bff9                	j	80001e5c <growproc+0x26>
		sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e80:	00b90633          	add	a2,s2,a1
    80001e84:	6d28                	ld	a0,88(a0)
    80001e86:	fffff097          	auipc	ra,0xfffff
    80001e8a:	55e080e7          	jalr	1374(ra) # 800013e4 <uvmdealloc>
    80001e8e:	85aa                	mv	a1,a0
    80001e90:	b7e1                	j	80001e58 <growproc+0x22>

0000000080001e92 <fork>:
{
    80001e92:	7139                	addi	sp,sp,-64
    80001e94:	fc06                	sd	ra,56(sp)
    80001e96:	f822                	sd	s0,48(sp)
    80001e98:	f426                	sd	s1,40(sp)
    80001e9a:	f04a                	sd	s2,32(sp)
    80001e9c:	ec4e                	sd	s3,24(sp)
    80001e9e:	e852                	sd	s4,16(sp)
    80001ea0:	e456                	sd	s5,8(sp)
    80001ea2:	0080                	addi	s0,sp,64
	struct proc *p = myproc();
    80001ea4:	00000097          	auipc	ra,0x0
    80001ea8:	c2c080e7          	jalr	-980(ra) # 80001ad0 <myproc>
    80001eac:	892a                	mv	s2,a0
	if ((np = allocproc()) == 0)
    80001eae:	00000097          	auipc	ra,0x0
    80001eb2:	e2e080e7          	jalr	-466(ra) # 80001cdc <allocproc>
    80001eb6:	12050363          	beqz	a0,80001fdc <fork+0x14a>
    80001eba:	89aa                	mv	s3,a0
	if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001ebc:	05093603          	ld	a2,80(s2)
    80001ec0:	6d2c                	ld	a1,88(a0)
    80001ec2:	05893503          	ld	a0,88(s2)
    80001ec6:	fffff097          	auipc	ra,0xfffff
    80001eca:	6ba080e7          	jalr	1722(ra) # 80001580 <uvmcopy>
    80001ece:	04054a63          	bltz	a0,80001f22 <fork+0x90>
	np->mask = p->mask; // copying mask so that we can also trace child processes
    80001ed2:	00092783          	lw	a5,0(s2)
    80001ed6:	00f9a023          	sw	a5,0(s3)
	np->sz = p->sz;
    80001eda:	05093783          	ld	a5,80(s2)
    80001ede:	04f9b823          	sd	a5,80(s3)
	*(np->trapframe) = *(p->trapframe);
    80001ee2:	06093683          	ld	a3,96(s2)
    80001ee6:	87b6                	mv	a5,a3
    80001ee8:	0609b703          	ld	a4,96(s3)
    80001eec:	12068693          	addi	a3,a3,288
    80001ef0:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001ef4:	6788                	ld	a0,8(a5)
    80001ef6:	6b8c                	ld	a1,16(a5)
    80001ef8:	6f90                	ld	a2,24(a5)
    80001efa:	01073023          	sd	a6,0(a4)
    80001efe:	e708                	sd	a0,8(a4)
    80001f00:	eb0c                	sd	a1,16(a4)
    80001f02:	ef10                	sd	a2,24(a4)
    80001f04:	02078793          	addi	a5,a5,32
    80001f08:	02070713          	addi	a4,a4,32
    80001f0c:	fed792e3          	bne	a5,a3,80001ef0 <fork+0x5e>
	np->trapframe->a0 = 0;
    80001f10:	0609b783          	ld	a5,96(s3)
    80001f14:	0607b823          	sd	zero,112(a5)
    80001f18:	0d800493          	li	s1,216
	for (i = 0; i < NOFILE; i++)
    80001f1c:	15800a13          	li	s4,344
    80001f20:	a805                	j	80001f50 <fork+0xbe>
		freeproc(np);
    80001f22:	854e                	mv	a0,s3
    80001f24:	00000097          	auipc	ra,0x0
    80001f28:	d60080e7          	jalr	-672(ra) # 80001c84 <freeproc>
		release(&np->lock);
    80001f2c:	00898513          	addi	a0,s3,8
    80001f30:	fffff097          	auipc	ra,0xfffff
    80001f34:	d6e080e7          	jalr	-658(ra) # 80000c9e <release>
		return -1;
    80001f38:	5afd                	li	s5,-1
    80001f3a:	a079                	j	80001fc8 <fork+0x136>
			np->ofile[i] = filedup(p->ofile[i]);
    80001f3c:	00003097          	auipc	ra,0x3
    80001f40:	91a080e7          	jalr	-1766(ra) # 80004856 <filedup>
    80001f44:	009987b3          	add	a5,s3,s1
    80001f48:	e388                	sd	a0,0(a5)
	for (i = 0; i < NOFILE; i++)
    80001f4a:	04a1                	addi	s1,s1,8
    80001f4c:	01448763          	beq	s1,s4,80001f5a <fork+0xc8>
		if (p->ofile[i])
    80001f50:	009907b3          	add	a5,s2,s1
    80001f54:	6388                	ld	a0,0(a5)
    80001f56:	f17d                	bnez	a0,80001f3c <fork+0xaa>
    80001f58:	bfcd                	j	80001f4a <fork+0xb8>
	np->cwd = idup(p->cwd);
    80001f5a:	15893503          	ld	a0,344(s2)
    80001f5e:	00002097          	auipc	ra,0x2
    80001f62:	a7e080e7          	jalr	-1410(ra) # 800039dc <idup>
    80001f66:	14a9bc23          	sd	a0,344(s3)
	safestrcpy(np->name, p->name, sizeof(p->name));
    80001f6a:	4641                	li	a2,16
    80001f6c:	16090593          	addi	a1,s2,352
    80001f70:	16098513          	addi	a0,s3,352
    80001f74:	fffff097          	auipc	ra,0xfffff
    80001f78:	ec4080e7          	jalr	-316(ra) # 80000e38 <safestrcpy>
	pid = np->pid;
    80001f7c:	0389aa83          	lw	s5,56(s3)
	release(&np->lock);
    80001f80:	00898493          	addi	s1,s3,8
    80001f84:	8526                	mv	a0,s1
    80001f86:	fffff097          	auipc	ra,0xfffff
    80001f8a:	d18080e7          	jalr	-744(ra) # 80000c9e <release>
	acquire(&wait_lock);
    80001f8e:	0000fa17          	auipc	s4,0xf
    80001f92:	eaaa0a13          	addi	s4,s4,-342 # 80010e38 <wait_lock>
    80001f96:	8552                	mv	a0,s4
    80001f98:	fffff097          	auipc	ra,0xfffff
    80001f9c:	c52080e7          	jalr	-942(ra) # 80000bea <acquire>
	np->parent = p;
    80001fa0:	0529b023          	sd	s2,64(s3)
	release(&wait_lock);
    80001fa4:	8552                	mv	a0,s4
    80001fa6:	fffff097          	auipc	ra,0xfffff
    80001faa:	cf8080e7          	jalr	-776(ra) # 80000c9e <release>
	acquire(&np->lock);
    80001fae:	8526                	mv	a0,s1
    80001fb0:	fffff097          	auipc	ra,0xfffff
    80001fb4:	c3a080e7          	jalr	-966(ra) # 80000bea <acquire>
	np->state = RUNNABLE;
    80001fb8:	478d                	li	a5,3
    80001fba:	02f9a023          	sw	a5,32(s3)
	release(&np->lock);
    80001fbe:	8526                	mv	a0,s1
    80001fc0:	fffff097          	auipc	ra,0xfffff
    80001fc4:	cde080e7          	jalr	-802(ra) # 80000c9e <release>
}
    80001fc8:	8556                	mv	a0,s5
    80001fca:	70e2                	ld	ra,56(sp)
    80001fcc:	7442                	ld	s0,48(sp)
    80001fce:	74a2                	ld	s1,40(sp)
    80001fd0:	7902                	ld	s2,32(sp)
    80001fd2:	69e2                	ld	s3,24(sp)
    80001fd4:	6a42                	ld	s4,16(sp)
    80001fd6:	6aa2                	ld	s5,8(sp)
    80001fd8:	6121                	addi	sp,sp,64
    80001fda:	8082                	ret
		return -1;
    80001fdc:	5afd                	li	s5,-1
    80001fde:	b7ed                	j	80001fc8 <fork+0x136>

0000000080001fe0 <upd_time>:
{
    80001fe0:	1101                	addi	sp,sp,-32
    80001fe2:	ec06                	sd	ra,24(sp)
    80001fe4:	e822                	sd	s0,16(sp)
    80001fe6:	e426                	sd	s1,8(sp)
    80001fe8:	e04a                	sd	s2,0(sp)
    80001fea:	1000                	addi	s0,sp,32
	while (pr < &proc[NPROC])
    80001fec:	0000f497          	auipc	s1,0xf
    80001ff0:	26c48493          	addi	s1,s1,620 # 80011258 <proc+0x8>
    80001ff4:	00016917          	auipc	s2,0x16
    80001ff8:	66490913          	addi	s2,s2,1636 # 80018658 <tickslock+0x8>
		acquire(&pr->lock);
    80001ffc:	8526                	mv	a0,s1
    80001ffe:	fffff097          	auipc	ra,0xfffff
    80002002:	bec080e7          	jalr	-1044(ra) # 80000bea <acquire>
		release(&pr->lock);
    80002006:	8526                	mv	a0,s1
    80002008:	fffff097          	auipc	ra,0xfffff
    8000200c:	c96080e7          	jalr	-874(ra) # 80000c9e <release>
	while (pr < &proc[NPROC])
    80002010:	1d048493          	addi	s1,s1,464
    80002014:	ff2494e3          	bne	s1,s2,80001ffc <upd_time+0x1c>
}
    80002018:	60e2                	ld	ra,24(sp)
    8000201a:	6442                	ld	s0,16(sp)
    8000201c:	64a2                	ld	s1,8(sp)
    8000201e:	6902                	ld	s2,0(sp)
    80002020:	6105                	addi	sp,sp,32
    80002022:	8082                	ret

0000000080002024 <scheduler>:
{
    80002024:	715d                	addi	sp,sp,-80
    80002026:	e486                	sd	ra,72(sp)
    80002028:	e0a2                	sd	s0,64(sp)
    8000202a:	fc26                	sd	s1,56(sp)
    8000202c:	f84a                	sd	s2,48(sp)
    8000202e:	f44e                	sd	s3,40(sp)
    80002030:	f052                	sd	s4,32(sp)
    80002032:	ec56                	sd	s5,24(sp)
    80002034:	e85a                	sd	s6,16(sp)
    80002036:	e45e                	sd	s7,8(sp)
    80002038:	0880                	addi	s0,sp,80
    8000203a:	8792                	mv	a5,tp
	int id = r_tp();
    8000203c:	2781                	sext.w	a5,a5
	c->proc = 0;
    8000203e:	00779b13          	slli	s6,a5,0x7
    80002042:	0000f717          	auipc	a4,0xf
    80002046:	dde70713          	addi	a4,a4,-546 # 80010e20 <pid_lock>
    8000204a:	975a                	add	a4,a4,s6
    8000204c:	02073823          	sd	zero,48(a4)
				swtch(&c->context, &p->context);
    80002050:	0000f717          	auipc	a4,0xf
    80002054:	e0870713          	addi	a4,a4,-504 # 80010e58 <cpus+0x8>
    80002058:	9b3a                	add	s6,s6,a4
			if (p->state == RUNNABLE)
    8000205a:	4a0d                	li	s4,3
				p->state = RUNNING;
    8000205c:	4b91                	li	s7,4
				c->proc = p;
    8000205e:	079e                	slli	a5,a5,0x7
    80002060:	0000fa97          	auipc	s5,0xf
    80002064:	dc0a8a93          	addi	s5,s5,-576 # 80010e20 <pid_lock>
    80002068:	9abe                	add	s5,s5,a5
		for (p = proc; p < &proc[NPROC]; p++)
    8000206a:	00016997          	auipc	s3,0x16
    8000206e:	5e698993          	addi	s3,s3,1510 # 80018650 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002072:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002076:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000207a:	10079073          	csrw	sstatus,a5
    8000207e:	0000f497          	auipc	s1,0xf
    80002082:	1d248493          	addi	s1,s1,466 # 80011250 <proc>
    80002086:	a03d                	j	800020b4 <scheduler+0x90>
				p->state = RUNNING;
    80002088:	0374a023          	sw	s7,32(s1)
				c->proc = p;
    8000208c:	029ab823          	sd	s1,48(s5)
				swtch(&c->context, &p->context);
    80002090:	06848593          	addi	a1,s1,104
    80002094:	855a                	mv	a0,s6
    80002096:	00000097          	auipc	ra,0x0
    8000209a:	6e6080e7          	jalr	1766(ra) # 8000277c <swtch>
				c->proc = 0;
    8000209e:	020ab823          	sd	zero,48(s5)
			release(&p->lock);
    800020a2:	854a                	mv	a0,s2
    800020a4:	fffff097          	auipc	ra,0xfffff
    800020a8:	bfa080e7          	jalr	-1030(ra) # 80000c9e <release>
		for (p = proc; p < &proc[NPROC]; p++)
    800020ac:	1d048493          	addi	s1,s1,464
    800020b0:	fd3481e3          	beq	s1,s3,80002072 <scheduler+0x4e>
			acquire(&p->lock);
    800020b4:	00848913          	addi	s2,s1,8
    800020b8:	854a                	mv	a0,s2
    800020ba:	fffff097          	auipc	ra,0xfffff
    800020be:	b30080e7          	jalr	-1232(ra) # 80000bea <acquire>
			if (p->state == RUNNABLE)
    800020c2:	509c                	lw	a5,32(s1)
    800020c4:	fd479fe3          	bne	a5,s4,800020a2 <scheduler+0x7e>
    800020c8:	b7c1                	j	80002088 <scheduler+0x64>

00000000800020ca <sched>:
{
    800020ca:	7179                	addi	sp,sp,-48
    800020cc:	f406                	sd	ra,40(sp)
    800020ce:	f022                	sd	s0,32(sp)
    800020d0:	ec26                	sd	s1,24(sp)
    800020d2:	e84a                	sd	s2,16(sp)
    800020d4:	e44e                	sd	s3,8(sp)
    800020d6:	1800                	addi	s0,sp,48
	struct proc *p = myproc();
    800020d8:	00000097          	auipc	ra,0x0
    800020dc:	9f8080e7          	jalr	-1544(ra) # 80001ad0 <myproc>
    800020e0:	84aa                	mv	s1,a0
	if (!holding(&p->lock))
    800020e2:	0521                	addi	a0,a0,8
    800020e4:	fffff097          	auipc	ra,0xfffff
    800020e8:	a8c080e7          	jalr	-1396(ra) # 80000b70 <holding>
    800020ec:	c93d                	beqz	a0,80002162 <sched+0x98>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020ee:	8792                	mv	a5,tp
	if (mycpu()->noff != 1)
    800020f0:	2781                	sext.w	a5,a5
    800020f2:	079e                	slli	a5,a5,0x7
    800020f4:	0000f717          	auipc	a4,0xf
    800020f8:	d2c70713          	addi	a4,a4,-724 # 80010e20 <pid_lock>
    800020fc:	97ba                	add	a5,a5,a4
    800020fe:	0a87a703          	lw	a4,168(a5)
    80002102:	4785                	li	a5,1
    80002104:	06f71763          	bne	a4,a5,80002172 <sched+0xa8>
	if (p->state == RUNNING)
    80002108:	5098                	lw	a4,32(s1)
    8000210a:	4791                	li	a5,4
    8000210c:	06f70b63          	beq	a4,a5,80002182 <sched+0xb8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002110:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002114:	8b89                	andi	a5,a5,2
	if (intr_get())
    80002116:	efb5                	bnez	a5,80002192 <sched+0xc8>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002118:	8792                	mv	a5,tp
	intena = mycpu()->intena;
    8000211a:	0000f917          	auipc	s2,0xf
    8000211e:	d0690913          	addi	s2,s2,-762 # 80010e20 <pid_lock>
    80002122:	2781                	sext.w	a5,a5
    80002124:	079e                	slli	a5,a5,0x7
    80002126:	97ca                	add	a5,a5,s2
    80002128:	0ac7a983          	lw	s3,172(a5)
    8000212c:	8792                	mv	a5,tp
	swtch(&p->context, &mycpu()->context);
    8000212e:	2781                	sext.w	a5,a5
    80002130:	079e                	slli	a5,a5,0x7
    80002132:	0000f597          	auipc	a1,0xf
    80002136:	d2658593          	addi	a1,a1,-730 # 80010e58 <cpus+0x8>
    8000213a:	95be                	add	a1,a1,a5
    8000213c:	06848513          	addi	a0,s1,104
    80002140:	00000097          	auipc	ra,0x0
    80002144:	63c080e7          	jalr	1596(ra) # 8000277c <swtch>
    80002148:	8792                	mv	a5,tp
	mycpu()->intena = intena;
    8000214a:	2781                	sext.w	a5,a5
    8000214c:	079e                	slli	a5,a5,0x7
    8000214e:	97ca                	add	a5,a5,s2
    80002150:	0b37a623          	sw	s3,172(a5)
}
    80002154:	70a2                	ld	ra,40(sp)
    80002156:	7402                	ld	s0,32(sp)
    80002158:	64e2                	ld	s1,24(sp)
    8000215a:	6942                	ld	s2,16(sp)
    8000215c:	69a2                	ld	s3,8(sp)
    8000215e:	6145                	addi	sp,sp,48
    80002160:	8082                	ret
		panic("sched p->lock");
    80002162:	00006517          	auipc	a0,0x6
    80002166:	0ce50513          	addi	a0,a0,206 # 80008230 <digits+0x1f0>
    8000216a:	ffffe097          	auipc	ra,0xffffe
    8000216e:	3da080e7          	jalr	986(ra) # 80000544 <panic>
		panic("sched locks");
    80002172:	00006517          	auipc	a0,0x6
    80002176:	0ce50513          	addi	a0,a0,206 # 80008240 <digits+0x200>
    8000217a:	ffffe097          	auipc	ra,0xffffe
    8000217e:	3ca080e7          	jalr	970(ra) # 80000544 <panic>
		panic("sched running");
    80002182:	00006517          	auipc	a0,0x6
    80002186:	0ce50513          	addi	a0,a0,206 # 80008250 <digits+0x210>
    8000218a:	ffffe097          	auipc	ra,0xffffe
    8000218e:	3ba080e7          	jalr	954(ra) # 80000544 <panic>
		panic("sched interruptible");
    80002192:	00006517          	auipc	a0,0x6
    80002196:	0ce50513          	addi	a0,a0,206 # 80008260 <digits+0x220>
    8000219a:	ffffe097          	auipc	ra,0xffffe
    8000219e:	3aa080e7          	jalr	938(ra) # 80000544 <panic>

00000000800021a2 <yield>:
{
    800021a2:	1101                	addi	sp,sp,-32
    800021a4:	ec06                	sd	ra,24(sp)
    800021a6:	e822                	sd	s0,16(sp)
    800021a8:	e426                	sd	s1,8(sp)
    800021aa:	e04a                	sd	s2,0(sp)
    800021ac:	1000                	addi	s0,sp,32
	struct proc *p = myproc();
    800021ae:	00000097          	auipc	ra,0x0
    800021b2:	922080e7          	jalr	-1758(ra) # 80001ad0 <myproc>
    800021b6:	84aa                	mv	s1,a0
	acquire(&p->lock);
    800021b8:	00850913          	addi	s2,a0,8
    800021bc:	854a                	mv	a0,s2
    800021be:	fffff097          	auipc	ra,0xfffff
    800021c2:	a2c080e7          	jalr	-1492(ra) # 80000bea <acquire>
	p->state = RUNNABLE;
    800021c6:	478d                	li	a5,3
    800021c8:	d09c                	sw	a5,32(s1)
	sched();
    800021ca:	00000097          	auipc	ra,0x0
    800021ce:	f00080e7          	jalr	-256(ra) # 800020ca <sched>
	release(&p->lock);
    800021d2:	854a                	mv	a0,s2
    800021d4:	fffff097          	auipc	ra,0xfffff
    800021d8:	aca080e7          	jalr	-1334(ra) # 80000c9e <release>
}
    800021dc:	60e2                	ld	ra,24(sp)
    800021de:	6442                	ld	s0,16(sp)
    800021e0:	64a2                	ld	s1,8(sp)
    800021e2:	6902                	ld	s2,0(sp)
    800021e4:	6105                	addi	sp,sp,32
    800021e6:	8082                	ret

00000000800021e8 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    800021e8:	7179                	addi	sp,sp,-48
    800021ea:	f406                	sd	ra,40(sp)
    800021ec:	f022                	sd	s0,32(sp)
    800021ee:	ec26                	sd	s1,24(sp)
    800021f0:	e84a                	sd	s2,16(sp)
    800021f2:	e44e                	sd	s3,8(sp)
    800021f4:	e052                	sd	s4,0(sp)
    800021f6:	1800                	addi	s0,sp,48
    800021f8:	89aa                	mv	s3,a0
    800021fa:	892e                	mv	s2,a1
	struct proc *p = myproc();
    800021fc:	00000097          	auipc	ra,0x0
    80002200:	8d4080e7          	jalr	-1836(ra) # 80001ad0 <myproc>
    80002204:	84aa                	mv	s1,a0
	// Once we hold p->lock, we can be
	// guaranteed that we won't miss any wakeup
	// (wakeup locks p->lock),
	// so it's okay to release lk.

	acquire(&p->lock); // DOC: sleeplock1
    80002206:	00850a13          	addi	s4,a0,8
    8000220a:	8552                	mv	a0,s4
    8000220c:	fffff097          	auipc	ra,0xfffff
    80002210:	9de080e7          	jalr	-1570(ra) # 80000bea <acquire>
	release(lk);
    80002214:	854a                	mv	a0,s2
    80002216:	fffff097          	auipc	ra,0xfffff
    8000221a:	a88080e7          	jalr	-1400(ra) # 80000c9e <release>

	// Go to sleep.
	p->chan = chan;
    8000221e:	0334b423          	sd	s3,40(s1)
	p->state = SLEEPING;
    80002222:	4789                	li	a5,2
    80002224:	d09c                	sw	a5,32(s1)

	sched();
    80002226:	00000097          	auipc	ra,0x0
    8000222a:	ea4080e7          	jalr	-348(ra) # 800020ca <sched>

	// Tidy up.
	p->chan = 0;
    8000222e:	0204b423          	sd	zero,40(s1)

	// Reacquire original lock.
	release(&p->lock);
    80002232:	8552                	mv	a0,s4
    80002234:	fffff097          	auipc	ra,0xfffff
    80002238:	a6a080e7          	jalr	-1430(ra) # 80000c9e <release>
	acquire(lk);
    8000223c:	854a                	mv	a0,s2
    8000223e:	fffff097          	auipc	ra,0xfffff
    80002242:	9ac080e7          	jalr	-1620(ra) # 80000bea <acquire>
}
    80002246:	70a2                	ld	ra,40(sp)
    80002248:	7402                	ld	s0,32(sp)
    8000224a:	64e2                	ld	s1,24(sp)
    8000224c:	6942                	ld	s2,16(sp)
    8000224e:	69a2                	ld	s3,8(sp)
    80002250:	6a02                	ld	s4,0(sp)
    80002252:	6145                	addi	sp,sp,48
    80002254:	8082                	ret

0000000080002256 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    80002256:	7139                	addi	sp,sp,-64
    80002258:	fc06                	sd	ra,56(sp)
    8000225a:	f822                	sd	s0,48(sp)
    8000225c:	f426                	sd	s1,40(sp)
    8000225e:	f04a                	sd	s2,32(sp)
    80002260:	ec4e                	sd	s3,24(sp)
    80002262:	e852                	sd	s4,16(sp)
    80002264:	e456                	sd	s5,8(sp)
    80002266:	e05a                	sd	s6,0(sp)
    80002268:	0080                	addi	s0,sp,64
    8000226a:	8aaa                	mv	s5,a0
	struct proc *p;

	for (p = proc; p < &proc[NPROC]; p++)
    8000226c:	0000f497          	auipc	s1,0xf
    80002270:	fe448493          	addi	s1,s1,-28 # 80011250 <proc>
	{
		if (p != myproc())
		{
			acquire(&p->lock);
			if (p->state == SLEEPING && p->chan == chan)
    80002274:	4a09                	li	s4,2
			{
				p->state = RUNNABLE;
    80002276:	4b0d                	li	s6,3
	for (p = proc; p < &proc[NPROC]; p++)
    80002278:	00016997          	auipc	s3,0x16
    8000227c:	3d898993          	addi	s3,s3,984 # 80018650 <tickslock>
    80002280:	a821                	j	80002298 <wakeup+0x42>
				p->state = RUNNABLE;
    80002282:	0364a023          	sw	s6,32(s1)
				int slices[5] = {1, 2, 4, 8, 16};
				p->time_slice = slices[p->curr_queue];
				push(&mlfq[p->curr_queue], p);
#endif
			}
			release(&p->lock);
    80002286:	854a                	mv	a0,s2
    80002288:	fffff097          	auipc	ra,0xfffff
    8000228c:	a16080e7          	jalr	-1514(ra) # 80000c9e <release>
	for (p = proc; p < &proc[NPROC]; p++)
    80002290:	1d048493          	addi	s1,s1,464
    80002294:	03348663          	beq	s1,s3,800022c0 <wakeup+0x6a>
		if (p != myproc())
    80002298:	00000097          	auipc	ra,0x0
    8000229c:	838080e7          	jalr	-1992(ra) # 80001ad0 <myproc>
    800022a0:	fea488e3          	beq	s1,a0,80002290 <wakeup+0x3a>
			acquire(&p->lock);
    800022a4:	00848913          	addi	s2,s1,8
    800022a8:	854a                	mv	a0,s2
    800022aa:	fffff097          	auipc	ra,0xfffff
    800022ae:	940080e7          	jalr	-1728(ra) # 80000bea <acquire>
			if (p->state == SLEEPING && p->chan == chan)
    800022b2:	509c                	lw	a5,32(s1)
    800022b4:	fd4799e3          	bne	a5,s4,80002286 <wakeup+0x30>
    800022b8:	749c                	ld	a5,40(s1)
    800022ba:	fd5796e3          	bne	a5,s5,80002286 <wakeup+0x30>
    800022be:	b7d1                	j	80002282 <wakeup+0x2c>
		}
	}
}
    800022c0:	70e2                	ld	ra,56(sp)
    800022c2:	7442                	ld	s0,48(sp)
    800022c4:	74a2                	ld	s1,40(sp)
    800022c6:	7902                	ld	s2,32(sp)
    800022c8:	69e2                	ld	s3,24(sp)
    800022ca:	6a42                	ld	s4,16(sp)
    800022cc:	6aa2                	ld	s5,8(sp)
    800022ce:	6b02                	ld	s6,0(sp)
    800022d0:	6121                	addi	sp,sp,64
    800022d2:	8082                	ret

00000000800022d4 <reparent>:
{
    800022d4:	7179                	addi	sp,sp,-48
    800022d6:	f406                	sd	ra,40(sp)
    800022d8:	f022                	sd	s0,32(sp)
    800022da:	ec26                	sd	s1,24(sp)
    800022dc:	e84a                	sd	s2,16(sp)
    800022de:	e44e                	sd	s3,8(sp)
    800022e0:	e052                	sd	s4,0(sp)
    800022e2:	1800                	addi	s0,sp,48
    800022e4:	892a                	mv	s2,a0
	for (pp = proc; pp < &proc[NPROC]; pp++)
    800022e6:	0000f497          	auipc	s1,0xf
    800022ea:	f6a48493          	addi	s1,s1,-150 # 80011250 <proc>
			pp->parent = initproc;
    800022ee:	00007a17          	auipc	s4,0x7
    800022f2:	8baa0a13          	addi	s4,s4,-1862 # 80008ba8 <initproc>
	for (pp = proc; pp < &proc[NPROC]; pp++)
    800022f6:	00016997          	auipc	s3,0x16
    800022fa:	35a98993          	addi	s3,s3,858 # 80018650 <tickslock>
    800022fe:	a029                	j	80002308 <reparent+0x34>
    80002300:	1d048493          	addi	s1,s1,464
    80002304:	01348d63          	beq	s1,s3,8000231e <reparent+0x4a>
		if (pp->parent == p)
    80002308:	60bc                	ld	a5,64(s1)
    8000230a:	ff279be3          	bne	a5,s2,80002300 <reparent+0x2c>
			pp->parent = initproc;
    8000230e:	000a3503          	ld	a0,0(s4)
    80002312:	e0a8                	sd	a0,64(s1)
			wakeup(initproc);
    80002314:	00000097          	auipc	ra,0x0
    80002318:	f42080e7          	jalr	-190(ra) # 80002256 <wakeup>
    8000231c:	b7d5                	j	80002300 <reparent+0x2c>
}
    8000231e:	70a2                	ld	ra,40(sp)
    80002320:	7402                	ld	s0,32(sp)
    80002322:	64e2                	ld	s1,24(sp)
    80002324:	6942                	ld	s2,16(sp)
    80002326:	69a2                	ld	s3,8(sp)
    80002328:	6a02                	ld	s4,0(sp)
    8000232a:	6145                	addi	sp,sp,48
    8000232c:	8082                	ret

000000008000232e <exit>:
{
    8000232e:	7179                	addi	sp,sp,-48
    80002330:	f406                	sd	ra,40(sp)
    80002332:	f022                	sd	s0,32(sp)
    80002334:	ec26                	sd	s1,24(sp)
    80002336:	e84a                	sd	s2,16(sp)
    80002338:	e44e                	sd	s3,8(sp)
    8000233a:	e052                	sd	s4,0(sp)
    8000233c:	1800                	addi	s0,sp,48
    8000233e:	8a2a                	mv	s4,a0
	struct proc *p = myproc();
    80002340:	fffff097          	auipc	ra,0xfffff
    80002344:	790080e7          	jalr	1936(ra) # 80001ad0 <myproc>
    80002348:	89aa                	mv	s3,a0
	if (p == initproc)
    8000234a:	00007797          	auipc	a5,0x7
    8000234e:	85e7b783          	ld	a5,-1954(a5) # 80008ba8 <initproc>
    80002352:	0d850493          	addi	s1,a0,216
    80002356:	15850913          	addi	s2,a0,344
    8000235a:	02a79363          	bne	a5,a0,80002380 <exit+0x52>
		panic("init exiting");
    8000235e:	00006517          	auipc	a0,0x6
    80002362:	f1a50513          	addi	a0,a0,-230 # 80008278 <digits+0x238>
    80002366:	ffffe097          	auipc	ra,0xffffe
    8000236a:	1de080e7          	jalr	478(ra) # 80000544 <panic>
			fileclose(f);
    8000236e:	00002097          	auipc	ra,0x2
    80002372:	53a080e7          	jalr	1338(ra) # 800048a8 <fileclose>
			p->ofile[fd] = 0;
    80002376:	0004b023          	sd	zero,0(s1)
	for (int fd = 0; fd < NOFILE; fd++)
    8000237a:	04a1                	addi	s1,s1,8
    8000237c:	01248563          	beq	s1,s2,80002386 <exit+0x58>
		if (p->ofile[fd])
    80002380:	6088                	ld	a0,0(s1)
    80002382:	f575                	bnez	a0,8000236e <exit+0x40>
    80002384:	bfdd                	j	8000237a <exit+0x4c>
	begin_op();
    80002386:	00002097          	auipc	ra,0x2
    8000238a:	056080e7          	jalr	86(ra) # 800043dc <begin_op>
	iput(p->cwd);
    8000238e:	1589b503          	ld	a0,344(s3)
    80002392:	00002097          	auipc	ra,0x2
    80002396:	842080e7          	jalr	-1982(ra) # 80003bd4 <iput>
	end_op();
    8000239a:	00002097          	auipc	ra,0x2
    8000239e:	0c2080e7          	jalr	194(ra) # 8000445c <end_op>
	p->cwd = 0;
    800023a2:	1409bc23          	sd	zero,344(s3)
	acquire(&wait_lock);
    800023a6:	0000f497          	auipc	s1,0xf
    800023aa:	a9248493          	addi	s1,s1,-1390 # 80010e38 <wait_lock>
    800023ae:	8526                	mv	a0,s1
    800023b0:	fffff097          	auipc	ra,0xfffff
    800023b4:	83a080e7          	jalr	-1990(ra) # 80000bea <acquire>
	reparent(p);
    800023b8:	854e                	mv	a0,s3
    800023ba:	00000097          	auipc	ra,0x0
    800023be:	f1a080e7          	jalr	-230(ra) # 800022d4 <reparent>
	wakeup(p->parent);
    800023c2:	0409b503          	ld	a0,64(s3)
    800023c6:	00000097          	auipc	ra,0x0
    800023ca:	e90080e7          	jalr	-368(ra) # 80002256 <wakeup>
	acquire(&p->lock);
    800023ce:	00898513          	addi	a0,s3,8
    800023d2:	fffff097          	auipc	ra,0xfffff
    800023d6:	818080e7          	jalr	-2024(ra) # 80000bea <acquire>
	p->xstate = status;
    800023da:	0349aa23          	sw	s4,52(s3)
	p->state = ZOMBIE;
    800023de:	4795                	li	a5,5
    800023e0:	02f9a023          	sw	a5,32(s3)
	release(&wait_lock);
    800023e4:	8526                	mv	a0,s1
    800023e6:	fffff097          	auipc	ra,0xfffff
    800023ea:	8b8080e7          	jalr	-1864(ra) # 80000c9e <release>
	sched();
    800023ee:	00000097          	auipc	ra,0x0
    800023f2:	cdc080e7          	jalr	-804(ra) # 800020ca <sched>
	panic("zombie exit");
    800023f6:	00006517          	auipc	a0,0x6
    800023fa:	e9250513          	addi	a0,a0,-366 # 80008288 <digits+0x248>
    800023fe:	ffffe097          	auipc	ra,0xffffe
    80002402:	146080e7          	jalr	326(ra) # 80000544 <panic>

0000000080002406 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    80002406:	7179                	addi	sp,sp,-48
    80002408:	f406                	sd	ra,40(sp)
    8000240a:	f022                	sd	s0,32(sp)
    8000240c:	ec26                	sd	s1,24(sp)
    8000240e:	e84a                	sd	s2,16(sp)
    80002410:	e44e                	sd	s3,8(sp)
    80002412:	e052                	sd	s4,0(sp)
    80002414:	1800                	addi	s0,sp,48
    80002416:	89aa                	mv	s3,a0
	struct proc *p;

	for (p = proc; p < &proc[NPROC]; p++)
    80002418:	0000f497          	auipc	s1,0xf
    8000241c:	e3848493          	addi	s1,s1,-456 # 80011250 <proc>
    80002420:	00016a17          	auipc	s4,0x16
    80002424:	230a0a13          	addi	s4,s4,560 # 80018650 <tickslock>
	{
		acquire(&p->lock);
    80002428:	00848913          	addi	s2,s1,8
    8000242c:	854a                	mv	a0,s2
    8000242e:	ffffe097          	auipc	ra,0xffffe
    80002432:	7bc080e7          	jalr	1980(ra) # 80000bea <acquire>
		if (p->pid == pid)
    80002436:	5c9c                	lw	a5,56(s1)
    80002438:	01378d63          	beq	a5,s3,80002452 <kill+0x4c>
#endif
			}
			release(&p->lock);
			return 0;
		}
		release(&p->lock);
    8000243c:	854a                	mv	a0,s2
    8000243e:	fffff097          	auipc	ra,0xfffff
    80002442:	860080e7          	jalr	-1952(ra) # 80000c9e <release>
	for (p = proc; p < &proc[NPROC]; p++)
    80002446:	1d048493          	addi	s1,s1,464
    8000244a:	fd449fe3          	bne	s1,s4,80002428 <kill+0x22>
	}
	return -1;
    8000244e:	557d                	li	a0,-1
    80002450:	a829                	j	8000246a <kill+0x64>
			p->killed = 1;
    80002452:	4785                	li	a5,1
    80002454:	d89c                	sw	a5,48(s1)
			if (p->state == SLEEPING)
    80002456:	5098                	lw	a4,32(s1)
    80002458:	4789                	li	a5,2
    8000245a:	02f70063          	beq	a4,a5,8000247a <kill+0x74>
			release(&p->lock);
    8000245e:	854a                	mv	a0,s2
    80002460:	fffff097          	auipc	ra,0xfffff
    80002464:	83e080e7          	jalr	-1986(ra) # 80000c9e <release>
			return 0;
    80002468:	4501                	li	a0,0
}
    8000246a:	70a2                	ld	ra,40(sp)
    8000246c:	7402                	ld	s0,32(sp)
    8000246e:	64e2                	ld	s1,24(sp)
    80002470:	6942                	ld	s2,16(sp)
    80002472:	69a2                	ld	s3,8(sp)
    80002474:	6a02                	ld	s4,0(sp)
    80002476:	6145                	addi	sp,sp,48
    80002478:	8082                	ret
				p->state = RUNNABLE;
    8000247a:	478d                	li	a5,3
    8000247c:	d09c                	sw	a5,32(s1)
    8000247e:	b7c5                	j	8000245e <kill+0x58>

0000000080002480 <setkilled>:

void setkilled(struct proc *p)
{
    80002480:	1101                	addi	sp,sp,-32
    80002482:	ec06                	sd	ra,24(sp)
    80002484:	e822                	sd	s0,16(sp)
    80002486:	e426                	sd	s1,8(sp)
    80002488:	e04a                	sd	s2,0(sp)
    8000248a:	1000                	addi	s0,sp,32
    8000248c:	84aa                	mv	s1,a0
	acquire(&p->lock);
    8000248e:	00850913          	addi	s2,a0,8
    80002492:	854a                	mv	a0,s2
    80002494:	ffffe097          	auipc	ra,0xffffe
    80002498:	756080e7          	jalr	1878(ra) # 80000bea <acquire>
	p->killed = 1;
    8000249c:	4785                	li	a5,1
    8000249e:	d89c                	sw	a5,48(s1)
	release(&p->lock);
    800024a0:	854a                	mv	a0,s2
    800024a2:	ffffe097          	auipc	ra,0xffffe
    800024a6:	7fc080e7          	jalr	2044(ra) # 80000c9e <release>
}
    800024aa:	60e2                	ld	ra,24(sp)
    800024ac:	6442                	ld	s0,16(sp)
    800024ae:	64a2                	ld	s1,8(sp)
    800024b0:	6902                	ld	s2,0(sp)
    800024b2:	6105                	addi	sp,sp,32
    800024b4:	8082                	ret

00000000800024b6 <killed>:

int killed(struct proc *p)
{
    800024b6:	1101                	addi	sp,sp,-32
    800024b8:	ec06                	sd	ra,24(sp)
    800024ba:	e822                	sd	s0,16(sp)
    800024bc:	e426                	sd	s1,8(sp)
    800024be:	e04a                	sd	s2,0(sp)
    800024c0:	1000                	addi	s0,sp,32
    800024c2:	84aa                	mv	s1,a0
	int k;

	acquire(&p->lock);
    800024c4:	00850913          	addi	s2,a0,8
    800024c8:	854a                	mv	a0,s2
    800024ca:	ffffe097          	auipc	ra,0xffffe
    800024ce:	720080e7          	jalr	1824(ra) # 80000bea <acquire>
	k = p->killed;
    800024d2:	5884                	lw	s1,48(s1)
	release(&p->lock);
    800024d4:	854a                	mv	a0,s2
    800024d6:	ffffe097          	auipc	ra,0xffffe
    800024da:	7c8080e7          	jalr	1992(ra) # 80000c9e <release>
	return k;
}
    800024de:	8526                	mv	a0,s1
    800024e0:	60e2                	ld	ra,24(sp)
    800024e2:	6442                	ld	s0,16(sp)
    800024e4:	64a2                	ld	s1,8(sp)
    800024e6:	6902                	ld	s2,0(sp)
    800024e8:	6105                	addi	sp,sp,32
    800024ea:	8082                	ret

00000000800024ec <wait>:
{
    800024ec:	711d                	addi	sp,sp,-96
    800024ee:	ec86                	sd	ra,88(sp)
    800024f0:	e8a2                	sd	s0,80(sp)
    800024f2:	e4a6                	sd	s1,72(sp)
    800024f4:	e0ca                	sd	s2,64(sp)
    800024f6:	fc4e                	sd	s3,56(sp)
    800024f8:	f852                	sd	s4,48(sp)
    800024fa:	f456                	sd	s5,40(sp)
    800024fc:	f05a                	sd	s6,32(sp)
    800024fe:	ec5e                	sd	s7,24(sp)
    80002500:	e862                	sd	s8,16(sp)
    80002502:	e466                	sd	s9,8(sp)
    80002504:	1080                	addi	s0,sp,96
    80002506:	8baa                	mv	s7,a0
	struct proc *p = myproc();
    80002508:	fffff097          	auipc	ra,0xfffff
    8000250c:	5c8080e7          	jalr	1480(ra) # 80001ad0 <myproc>
    80002510:	892a                	mv	s2,a0
	acquire(&wait_lock);
    80002512:	0000f517          	auipc	a0,0xf
    80002516:	92650513          	addi	a0,a0,-1754 # 80010e38 <wait_lock>
    8000251a:	ffffe097          	auipc	ra,0xffffe
    8000251e:	6d0080e7          	jalr	1744(ra) # 80000bea <acquire>
		havekids = 0;
    80002522:	4c01                	li	s8,0
				if (pp->state == ZOMBIE)
    80002524:	4a95                	li	s5,5
		for (pp = proc; pp < &proc[NPROC]; pp++)
    80002526:	00016997          	auipc	s3,0x16
    8000252a:	12a98993          	addi	s3,s3,298 # 80018650 <tickslock>
				havekids = 1;
    8000252e:	4b05                	li	s6,1
		sleep(p, &wait_lock); // DOC: wait-sleep
    80002530:	0000fc97          	auipc	s9,0xf
    80002534:	908c8c93          	addi	s9,s9,-1784 # 80010e38 <wait_lock>
		havekids = 0;
    80002538:	8762                	mv	a4,s8
		for (pp = proc; pp < &proc[NPROC]; pp++)
    8000253a:	0000f497          	auipc	s1,0xf
    8000253e:	d1648493          	addi	s1,s1,-746 # 80011250 <proc>
    80002542:	a0bd                	j	800025b0 <wait+0xc4>
					pid = pp->pid;
    80002544:	0384a983          	lw	s3,56(s1)
					if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002548:	000b8e63          	beqz	s7,80002564 <wait+0x78>
    8000254c:	4691                	li	a3,4
    8000254e:	03448613          	addi	a2,s1,52
    80002552:	85de                	mv	a1,s7
    80002554:	05893503          	ld	a0,88(s2)
    80002558:	fffff097          	auipc	ra,0xfffff
    8000255c:	12c080e7          	jalr	300(ra) # 80001684 <copyout>
    80002560:	02054563          	bltz	a0,8000258a <wait+0x9e>
					freeproc(pp);
    80002564:	8526                	mv	a0,s1
    80002566:	fffff097          	auipc	ra,0xfffff
    8000256a:	71e080e7          	jalr	1822(ra) # 80001c84 <freeproc>
					release(&pp->lock);
    8000256e:	8552                	mv	a0,s4
    80002570:	ffffe097          	auipc	ra,0xffffe
    80002574:	72e080e7          	jalr	1838(ra) # 80000c9e <release>
					release(&wait_lock);
    80002578:	0000f517          	auipc	a0,0xf
    8000257c:	8c050513          	addi	a0,a0,-1856 # 80010e38 <wait_lock>
    80002580:	ffffe097          	auipc	ra,0xffffe
    80002584:	71e080e7          	jalr	1822(ra) # 80000c9e <release>
					return pid;
    80002588:	a885                	j	800025f8 <wait+0x10c>
						release(&pp->lock);
    8000258a:	8552                	mv	a0,s4
    8000258c:	ffffe097          	auipc	ra,0xffffe
    80002590:	712080e7          	jalr	1810(ra) # 80000c9e <release>
						release(&wait_lock);
    80002594:	0000f517          	auipc	a0,0xf
    80002598:	8a450513          	addi	a0,a0,-1884 # 80010e38 <wait_lock>
    8000259c:	ffffe097          	auipc	ra,0xffffe
    800025a0:	702080e7          	jalr	1794(ra) # 80000c9e <release>
						return -1;
    800025a4:	59fd                	li	s3,-1
    800025a6:	a889                	j	800025f8 <wait+0x10c>
		for (pp = proc; pp < &proc[NPROC]; pp++)
    800025a8:	1d048493          	addi	s1,s1,464
    800025ac:	03348663          	beq	s1,s3,800025d8 <wait+0xec>
			if (pp->parent == p)
    800025b0:	60bc                	ld	a5,64(s1)
    800025b2:	ff279be3          	bne	a5,s2,800025a8 <wait+0xbc>
				acquire(&pp->lock);
    800025b6:	00848a13          	addi	s4,s1,8
    800025ba:	8552                	mv	a0,s4
    800025bc:	ffffe097          	auipc	ra,0xffffe
    800025c0:	62e080e7          	jalr	1582(ra) # 80000bea <acquire>
				if (pp->state == ZOMBIE)
    800025c4:	509c                	lw	a5,32(s1)
    800025c6:	f7578fe3          	beq	a5,s5,80002544 <wait+0x58>
				release(&pp->lock);
    800025ca:	8552                	mv	a0,s4
    800025cc:	ffffe097          	auipc	ra,0xffffe
    800025d0:	6d2080e7          	jalr	1746(ra) # 80000c9e <release>
				havekids = 1;
    800025d4:	875a                	mv	a4,s6
    800025d6:	bfc9                	j	800025a8 <wait+0xbc>
		if (!havekids || killed(p))
    800025d8:	c719                	beqz	a4,800025e6 <wait+0xfa>
    800025da:	854a                	mv	a0,s2
    800025dc:	00000097          	auipc	ra,0x0
    800025e0:	eda080e7          	jalr	-294(ra) # 800024b6 <killed>
    800025e4:	c905                	beqz	a0,80002614 <wait+0x128>
			release(&wait_lock);
    800025e6:	0000f517          	auipc	a0,0xf
    800025ea:	85250513          	addi	a0,a0,-1966 # 80010e38 <wait_lock>
    800025ee:	ffffe097          	auipc	ra,0xffffe
    800025f2:	6b0080e7          	jalr	1712(ra) # 80000c9e <release>
			return -1;
    800025f6:	59fd                	li	s3,-1
}
    800025f8:	854e                	mv	a0,s3
    800025fa:	60e6                	ld	ra,88(sp)
    800025fc:	6446                	ld	s0,80(sp)
    800025fe:	64a6                	ld	s1,72(sp)
    80002600:	6906                	ld	s2,64(sp)
    80002602:	79e2                	ld	s3,56(sp)
    80002604:	7a42                	ld	s4,48(sp)
    80002606:	7aa2                	ld	s5,40(sp)
    80002608:	7b02                	ld	s6,32(sp)
    8000260a:	6be2                	ld	s7,24(sp)
    8000260c:	6c42                	ld	s8,16(sp)
    8000260e:	6ca2                	ld	s9,8(sp)
    80002610:	6125                	addi	sp,sp,96
    80002612:	8082                	ret
		sleep(p, &wait_lock); // DOC: wait-sleep
    80002614:	85e6                	mv	a1,s9
    80002616:	854a                	mv	a0,s2
    80002618:	00000097          	auipc	ra,0x0
    8000261c:	bd0080e7          	jalr	-1072(ra) # 800021e8 <sleep>
		havekids = 0;
    80002620:	bf21                	j	80002538 <wait+0x4c>

0000000080002622 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002622:	7179                	addi	sp,sp,-48
    80002624:	f406                	sd	ra,40(sp)
    80002626:	f022                	sd	s0,32(sp)
    80002628:	ec26                	sd	s1,24(sp)
    8000262a:	e84a                	sd	s2,16(sp)
    8000262c:	e44e                	sd	s3,8(sp)
    8000262e:	e052                	sd	s4,0(sp)
    80002630:	1800                	addi	s0,sp,48
    80002632:	84aa                	mv	s1,a0
    80002634:	892e                	mv	s2,a1
    80002636:	89b2                	mv	s3,a2
    80002638:	8a36                	mv	s4,a3
	struct proc *p = myproc();
    8000263a:	fffff097          	auipc	ra,0xfffff
    8000263e:	496080e7          	jalr	1174(ra) # 80001ad0 <myproc>
	if (user_dst)
    80002642:	c08d                	beqz	s1,80002664 <either_copyout+0x42>
	{
		return copyout(p->pagetable, dst, src, len);
    80002644:	86d2                	mv	a3,s4
    80002646:	864e                	mv	a2,s3
    80002648:	85ca                	mv	a1,s2
    8000264a:	6d28                	ld	a0,88(a0)
    8000264c:	fffff097          	auipc	ra,0xfffff
    80002650:	038080e7          	jalr	56(ra) # 80001684 <copyout>
	else
	{
		memmove((char *)dst, src, len);
		return 0;
	}
}
    80002654:	70a2                	ld	ra,40(sp)
    80002656:	7402                	ld	s0,32(sp)
    80002658:	64e2                	ld	s1,24(sp)
    8000265a:	6942                	ld	s2,16(sp)
    8000265c:	69a2                	ld	s3,8(sp)
    8000265e:	6a02                	ld	s4,0(sp)
    80002660:	6145                	addi	sp,sp,48
    80002662:	8082                	ret
		memmove((char *)dst, src, len);
    80002664:	000a061b          	sext.w	a2,s4
    80002668:	85ce                	mv	a1,s3
    8000266a:	854a                	mv	a0,s2
    8000266c:	ffffe097          	auipc	ra,0xffffe
    80002670:	6da080e7          	jalr	1754(ra) # 80000d46 <memmove>
		return 0;
    80002674:	8526                	mv	a0,s1
    80002676:	bff9                	j	80002654 <either_copyout+0x32>

0000000080002678 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002678:	7179                	addi	sp,sp,-48
    8000267a:	f406                	sd	ra,40(sp)
    8000267c:	f022                	sd	s0,32(sp)
    8000267e:	ec26                	sd	s1,24(sp)
    80002680:	e84a                	sd	s2,16(sp)
    80002682:	e44e                	sd	s3,8(sp)
    80002684:	e052                	sd	s4,0(sp)
    80002686:	1800                	addi	s0,sp,48
    80002688:	892a                	mv	s2,a0
    8000268a:	84ae                	mv	s1,a1
    8000268c:	89b2                	mv	s3,a2
    8000268e:	8a36                	mv	s4,a3
	struct proc *p = myproc();
    80002690:	fffff097          	auipc	ra,0xfffff
    80002694:	440080e7          	jalr	1088(ra) # 80001ad0 <myproc>
	if (user_src)
    80002698:	c08d                	beqz	s1,800026ba <either_copyin+0x42>
	{
		return copyin(p->pagetable, dst, src, len);
    8000269a:	86d2                	mv	a3,s4
    8000269c:	864e                	mv	a2,s3
    8000269e:	85ca                	mv	a1,s2
    800026a0:	6d28                	ld	a0,88(a0)
    800026a2:	fffff097          	auipc	ra,0xfffff
    800026a6:	06e080e7          	jalr	110(ra) # 80001710 <copyin>
	else
	{
		memmove(dst, (char *)src, len);
		return 0;
	}
}
    800026aa:	70a2                	ld	ra,40(sp)
    800026ac:	7402                	ld	s0,32(sp)
    800026ae:	64e2                	ld	s1,24(sp)
    800026b0:	6942                	ld	s2,16(sp)
    800026b2:	69a2                	ld	s3,8(sp)
    800026b4:	6a02                	ld	s4,0(sp)
    800026b6:	6145                	addi	sp,sp,48
    800026b8:	8082                	ret
		memmove(dst, (char *)src, len);
    800026ba:	000a061b          	sext.w	a2,s4
    800026be:	85ce                	mv	a1,s3
    800026c0:	854a                	mv	a0,s2
    800026c2:	ffffe097          	auipc	ra,0xffffe
    800026c6:	684080e7          	jalr	1668(ra) # 80000d46 <memmove>
		return 0;
    800026ca:	8526                	mv	a0,s1
    800026cc:	bff9                	j	800026aa <either_copyin+0x32>

00000000800026ce <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    800026ce:	715d                	addi	sp,sp,-80
    800026d0:	e486                	sd	ra,72(sp)
    800026d2:	e0a2                	sd	s0,64(sp)
    800026d4:	fc26                	sd	s1,56(sp)
    800026d6:	f84a                	sd	s2,48(sp)
    800026d8:	f44e                	sd	s3,40(sp)
    800026da:	f052                	sd	s4,32(sp)
    800026dc:	ec56                	sd	s5,24(sp)
    800026de:	e85a                	sd	s6,16(sp)
    800026e0:	e45e                	sd	s7,8(sp)
    800026e2:	0880                	addi	s0,sp,80
		[RUNNING] "run   ",
		[ZOMBIE] "zombie"};
	struct proc *p;
	char *state;

	printf("\n");
    800026e4:	00006517          	auipc	a0,0x6
    800026e8:	9e450513          	addi	a0,a0,-1564 # 800080c8 <digits+0x88>
    800026ec:	ffffe097          	auipc	ra,0xffffe
    800026f0:	ea2080e7          	jalr	-350(ra) # 8000058e <printf>
	for (p = proc; p < &proc[NPROC]; p++)
    800026f4:	0000f497          	auipc	s1,0xf
    800026f8:	cbc48493          	addi	s1,s1,-836 # 800113b0 <proc+0x160>
    800026fc:	00016917          	auipc	s2,0x16
    80002700:	0b490913          	addi	s2,s2,180 # 800187b0 <bcache+0x148>
	{
		if (p->state == UNUSED)
			continue;
		if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002704:	4b15                	li	s6,5
			state = states[p->state];
		else
			state = "???";
    80002706:	00006997          	auipc	s3,0x6
    8000270a:	b9298993          	addi	s3,s3,-1134 # 80008298 <digits+0x258>
		printf("%d %s %s", p->pid, state, p->name);
    8000270e:	00006a97          	auipc	s5,0x6
    80002712:	b92a8a93          	addi	s5,s5,-1134 # 800082a0 <digits+0x260>
		printf("\n");
    80002716:	00006a17          	auipc	s4,0x6
    8000271a:	9b2a0a13          	addi	s4,s4,-1614 # 800080c8 <digits+0x88>
		if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000271e:	00006b97          	auipc	s7,0x6
    80002722:	bc2b8b93          	addi	s7,s7,-1086 # 800082e0 <states.2476>
    80002726:	a00d                	j	80002748 <procdump+0x7a>
		printf("%d %s %s", p->pid, state, p->name);
    80002728:	ed86a583          	lw	a1,-296(a3)
    8000272c:	8556                	mv	a0,s5
    8000272e:	ffffe097          	auipc	ra,0xffffe
    80002732:	e60080e7          	jalr	-416(ra) # 8000058e <printf>
		printf("\n");
    80002736:	8552                	mv	a0,s4
    80002738:	ffffe097          	auipc	ra,0xffffe
    8000273c:	e56080e7          	jalr	-426(ra) # 8000058e <printf>
	for (p = proc; p < &proc[NPROC]; p++)
    80002740:	1d048493          	addi	s1,s1,464
    80002744:	03248163          	beq	s1,s2,80002766 <procdump+0x98>
		if (p->state == UNUSED)
    80002748:	86a6                	mv	a3,s1
    8000274a:	ec04a783          	lw	a5,-320(s1)
    8000274e:	dbed                	beqz	a5,80002740 <procdump+0x72>
			state = "???";
    80002750:	864e                	mv	a2,s3
		if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002752:	fcfb6be3          	bltu	s6,a5,80002728 <procdump+0x5a>
    80002756:	1782                	slli	a5,a5,0x20
    80002758:	9381                	srli	a5,a5,0x20
    8000275a:	078e                	slli	a5,a5,0x3
    8000275c:	97de                	add	a5,a5,s7
    8000275e:	6390                	ld	a2,0(a5)
    80002760:	f661                	bnez	a2,80002728 <procdump+0x5a>
			state = "???";
    80002762:	864e                	mv	a2,s3
    80002764:	b7d1                	j	80002728 <procdump+0x5a>
	}
}
    80002766:	60a6                	ld	ra,72(sp)
    80002768:	6406                	ld	s0,64(sp)
    8000276a:	74e2                	ld	s1,56(sp)
    8000276c:	7942                	ld	s2,48(sp)
    8000276e:	79a2                	ld	s3,40(sp)
    80002770:	7a02                	ld	s4,32(sp)
    80002772:	6ae2                	ld	s5,24(sp)
    80002774:	6b42                	ld	s6,16(sp)
    80002776:	6ba2                	ld	s7,8(sp)
    80002778:	6161                	addi	sp,sp,80
    8000277a:	8082                	ret

000000008000277c <swtch>:
    8000277c:	00153023          	sd	ra,0(a0)
    80002780:	00253423          	sd	sp,8(a0)
    80002784:	e900                	sd	s0,16(a0)
    80002786:	ed04                	sd	s1,24(a0)
    80002788:	03253023          	sd	s2,32(a0)
    8000278c:	03353423          	sd	s3,40(a0)
    80002790:	03453823          	sd	s4,48(a0)
    80002794:	03553c23          	sd	s5,56(a0)
    80002798:	05653023          	sd	s6,64(a0)
    8000279c:	05753423          	sd	s7,72(a0)
    800027a0:	05853823          	sd	s8,80(a0)
    800027a4:	05953c23          	sd	s9,88(a0)
    800027a8:	07a53023          	sd	s10,96(a0)
    800027ac:	07b53423          	sd	s11,104(a0)
    800027b0:	0005b083          	ld	ra,0(a1)
    800027b4:	0085b103          	ld	sp,8(a1)
    800027b8:	6980                	ld	s0,16(a1)
    800027ba:	6d84                	ld	s1,24(a1)
    800027bc:	0205b903          	ld	s2,32(a1)
    800027c0:	0285b983          	ld	s3,40(a1)
    800027c4:	0305ba03          	ld	s4,48(a1)
    800027c8:	0385ba83          	ld	s5,56(a1)
    800027cc:	0405bb03          	ld	s6,64(a1)
    800027d0:	0485bb83          	ld	s7,72(a1)
    800027d4:	0505bc03          	ld	s8,80(a1)
    800027d8:	0585bc83          	ld	s9,88(a1)
    800027dc:	0605bd03          	ld	s10,96(a1)
    800027e0:	0685bd83          	ld	s11,104(a1)
    800027e4:	8082                	ret

00000000800027e6 <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    800027e6:	1141                	addi	sp,sp,-16
    800027e8:	e406                	sd	ra,8(sp)
    800027ea:	e022                	sd	s0,0(sp)
    800027ec:	0800                	addi	s0,sp,16
	initlock(&tickslock, "time");
    800027ee:	00006597          	auipc	a1,0x6
    800027f2:	b2258593          	addi	a1,a1,-1246 # 80008310 <states.2476+0x30>
    800027f6:	00016517          	auipc	a0,0x16
    800027fa:	e5a50513          	addi	a0,a0,-422 # 80018650 <tickslock>
    800027fe:	ffffe097          	auipc	ra,0xffffe
    80002802:	35c080e7          	jalr	860(ra) # 80000b5a <initlock>
}
    80002806:	60a2                	ld	ra,8(sp)
    80002808:	6402                	ld	s0,0(sp)
    8000280a:	0141                	addi	sp,sp,16
    8000280c:	8082                	ret

000000008000280e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    8000280e:	1141                	addi	sp,sp,-16
    80002810:	e422                	sd	s0,8(sp)
    80002812:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002814:	00003797          	auipc	a5,0x3
    80002818:	6cc78793          	addi	a5,a5,1740 # 80005ee0 <kernelvec>
    8000281c:	10579073          	csrw	stvec,a5
	w_stvec((uint64)kernelvec);
}
    80002820:	6422                	ld	s0,8(sp)
    80002822:	0141                	addi	sp,sp,16
    80002824:	8082                	ret

0000000080002826 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80002826:	1141                	addi	sp,sp,-16
    80002828:	e406                	sd	ra,8(sp)
    8000282a:	e022                	sd	s0,0(sp)
    8000282c:	0800                	addi	s0,sp,16
	struct proc *p = myproc();
    8000282e:	fffff097          	auipc	ra,0xfffff
    80002832:	2a2080e7          	jalr	674(ra) # 80001ad0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002836:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000283a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000283c:	10079073          	csrw	sstatus,a5
	// kerneltrap() to usertrap(), so turn off interrupts until
	// we're back in user space, where usertrap() is correct.
	intr_off();

	// send syscalls, interrupts, and exceptions to uservec in trampoline.S
	uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002840:	00004617          	auipc	a2,0x4
    80002844:	7c060613          	addi	a2,a2,1984 # 80007000 <_trampoline>
    80002848:	00004697          	auipc	a3,0x4
    8000284c:	7b868693          	addi	a3,a3,1976 # 80007000 <_trampoline>
    80002850:	8e91                	sub	a3,a3,a2
    80002852:	040007b7          	lui	a5,0x4000
    80002856:	17fd                	addi	a5,a5,-1
    80002858:	07b2                	slli	a5,a5,0xc
    8000285a:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000285c:	10569073          	csrw	stvec,a3
	w_stvec(trampoline_uservec);

	// set up trapframe values that uservec will need when
	// the process next traps into the kernel.
	p->trapframe->kernel_satp = r_satp();		  // kernel page table
    80002860:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002862:	180026f3          	csrr	a3,satp
    80002866:	e314                	sd	a3,0(a4)
	p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002868:	7138                	ld	a4,96(a0)
    8000286a:	6534                	ld	a3,72(a0)
    8000286c:	6585                	lui	a1,0x1
    8000286e:	96ae                	add	a3,a3,a1
    80002870:	e714                	sd	a3,8(a4)
	p->trapframe->kernel_trap = (uint64)usertrap;
    80002872:	7138                	ld	a4,96(a0)
    80002874:	00000697          	auipc	a3,0x0
    80002878:	13e68693          	addi	a3,a3,318 # 800029b2 <usertrap>
    8000287c:	eb14                	sd	a3,16(a4)
	p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    8000287e:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002880:	8692                	mv	a3,tp
    80002882:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002884:	100026f3          	csrr	a3,sstatus
	// set up the registers that trampoline.S's sret will use
	// to get to user space.

	// set S Previous Privilege mode to User.
	unsigned long x = r_sstatus();
	x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002888:	eff6f693          	andi	a3,a3,-257
	x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000288c:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002890:	10069073          	csrw	sstatus,a3
	w_sstatus(x);

	// set S Exception Program Counter to the saved user pc.
	w_sepc(p->trapframe->epc);
    80002894:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002896:	6f18                	ld	a4,24(a4)
    80002898:	14171073          	csrw	sepc,a4

	// tell trampoline.S the user page table to switch to.
	uint64 satp = MAKE_SATP(p->pagetable);
    8000289c:	6d28                	ld	a0,88(a0)
    8000289e:	8131                	srli	a0,a0,0xc

	// jump to userret in trampoline.S at the top of memory, which
	// switches to the user page table, restores user registers,
	// and switches to user mode with sret.
	uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800028a0:	00004717          	auipc	a4,0x4
    800028a4:	7fc70713          	addi	a4,a4,2044 # 8000709c <userret>
    800028a8:	8f11                	sub	a4,a4,a2
    800028aa:	97ba                	add	a5,a5,a4
	((void (*)(uint64))trampoline_userret)(satp);
    800028ac:	577d                	li	a4,-1
    800028ae:	177e                	slli	a4,a4,0x3f
    800028b0:	8d59                	or	a0,a0,a4
    800028b2:	9782                	jalr	a5
}
    800028b4:	60a2                	ld	ra,8(sp)
    800028b6:	6402                	ld	s0,0(sp)
    800028b8:	0141                	addi	sp,sp,16
    800028ba:	8082                	ret

00000000800028bc <clockintr>:
	w_sepc(sepc);
	w_sstatus(sstatus);
}

void clockintr()
{
    800028bc:	1101                	addi	sp,sp,-32
    800028be:	ec06                	sd	ra,24(sp)
    800028c0:	e822                	sd	s0,16(sp)
    800028c2:	e426                	sd	s1,8(sp)
    800028c4:	e04a                	sd	s2,0(sp)
    800028c6:	1000                	addi	s0,sp,32
	acquire(&tickslock);
    800028c8:	00016917          	auipc	s2,0x16
    800028cc:	d8890913          	addi	s2,s2,-632 # 80018650 <tickslock>
    800028d0:	854a                	mv	a0,s2
    800028d2:	ffffe097          	auipc	ra,0xffffe
    800028d6:	318080e7          	jalr	792(ra) # 80000bea <acquire>
	ticks++;
    800028da:	00006497          	auipc	s1,0x6
    800028de:	2d648493          	addi	s1,s1,726 # 80008bb0 <ticks>
    800028e2:	409c                	lw	a5,0(s1)
    800028e4:	2785                	addiw	a5,a5,1
    800028e6:	c09c                	sw	a5,0(s1)
	upd_time();
    800028e8:	fffff097          	auipc	ra,0xfffff
    800028ec:	6f8080e7          	jalr	1784(ra) # 80001fe0 <upd_time>
	wakeup(&ticks);
    800028f0:	8526                	mv	a0,s1
    800028f2:	00000097          	auipc	ra,0x0
    800028f6:	964080e7          	jalr	-1692(ra) # 80002256 <wakeup>
	release(&tickslock);
    800028fa:	854a                	mv	a0,s2
    800028fc:	ffffe097          	auipc	ra,0xffffe
    80002900:	3a2080e7          	jalr	930(ra) # 80000c9e <release>
}
    80002904:	60e2                	ld	ra,24(sp)
    80002906:	6442                	ld	s0,16(sp)
    80002908:	64a2                	ld	s1,8(sp)
    8000290a:	6902                	ld	s2,0(sp)
    8000290c:	6105                	addi	sp,sp,32
    8000290e:	8082                	ret

0000000080002910 <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    80002910:	1101                	addi	sp,sp,-32
    80002912:	ec06                	sd	ra,24(sp)
    80002914:	e822                	sd	s0,16(sp)
    80002916:	e426                	sd	s1,8(sp)
    80002918:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000291a:	14202773          	csrr	a4,scause
	uint64 scause = r_scause();

	if ((scause & 0x8000000000000000L) &&
    8000291e:	00074d63          	bltz	a4,80002938 <devintr+0x28>
		if (irq)
			plic_complete(irq);

		return 1;
	}
	else if (scause == 0x8000000000000001L)
    80002922:	57fd                	li	a5,-1
    80002924:	17fe                	slli	a5,a5,0x3f
    80002926:	0785                	addi	a5,a5,1

		return 2;
	}
	else
	{
		return 0;
    80002928:	4501                	li	a0,0
	else if (scause == 0x8000000000000001L)
    8000292a:	06f70363          	beq	a4,a5,80002990 <devintr+0x80>
	}
}
    8000292e:	60e2                	ld	ra,24(sp)
    80002930:	6442                	ld	s0,16(sp)
    80002932:	64a2                	ld	s1,8(sp)
    80002934:	6105                	addi	sp,sp,32
    80002936:	8082                	ret
		(scause & 0xff) == 9)
    80002938:	0ff77793          	andi	a5,a4,255
	if ((scause & 0x8000000000000000L) &&
    8000293c:	46a5                	li	a3,9
    8000293e:	fed792e3          	bne	a5,a3,80002922 <devintr+0x12>
		int irq = plic_claim();
    80002942:	00003097          	auipc	ra,0x3
    80002946:	6a6080e7          	jalr	1702(ra) # 80005fe8 <plic_claim>
    8000294a:	84aa                	mv	s1,a0
		if (irq == UART0_IRQ)
    8000294c:	47a9                	li	a5,10
    8000294e:	02f50763          	beq	a0,a5,8000297c <devintr+0x6c>
		else if (irq == VIRTIO0_IRQ)
    80002952:	4785                	li	a5,1
    80002954:	02f50963          	beq	a0,a5,80002986 <devintr+0x76>
		return 1;
    80002958:	4505                	li	a0,1
		else if (irq)
    8000295a:	d8f1                	beqz	s1,8000292e <devintr+0x1e>
			printf("unexpected interrupt irq=%d\n", irq);
    8000295c:	85a6                	mv	a1,s1
    8000295e:	00006517          	auipc	a0,0x6
    80002962:	9ba50513          	addi	a0,a0,-1606 # 80008318 <states.2476+0x38>
    80002966:	ffffe097          	auipc	ra,0xffffe
    8000296a:	c28080e7          	jalr	-984(ra) # 8000058e <printf>
			plic_complete(irq);
    8000296e:	8526                	mv	a0,s1
    80002970:	00003097          	auipc	ra,0x3
    80002974:	69c080e7          	jalr	1692(ra) # 8000600c <plic_complete>
		return 1;
    80002978:	4505                	li	a0,1
    8000297a:	bf55                	j	8000292e <devintr+0x1e>
			uartintr();
    8000297c:	ffffe097          	auipc	ra,0xffffe
    80002980:	032080e7          	jalr	50(ra) # 800009ae <uartintr>
    80002984:	b7ed                	j	8000296e <devintr+0x5e>
			virtio_disk_intr();
    80002986:	00004097          	auipc	ra,0x4
    8000298a:	bb0080e7          	jalr	-1104(ra) # 80006536 <virtio_disk_intr>
    8000298e:	b7c5                	j	8000296e <devintr+0x5e>
		if (cpuid() == 0)
    80002990:	fffff097          	auipc	ra,0xfffff
    80002994:	114080e7          	jalr	276(ra) # 80001aa4 <cpuid>
    80002998:	c901                	beqz	a0,800029a8 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    8000299a:	144027f3          	csrr	a5,sip
		w_sip(r_sip() & ~2);
    8000299e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800029a0:	14479073          	csrw	sip,a5
		return 2;
    800029a4:	4509                	li	a0,2
    800029a6:	b761                	j	8000292e <devintr+0x1e>
			clockintr();
    800029a8:	00000097          	auipc	ra,0x0
    800029ac:	f14080e7          	jalr	-236(ra) # 800028bc <clockintr>
    800029b0:	b7ed                	j	8000299a <devintr+0x8a>

00000000800029b2 <usertrap>:
{
    800029b2:	1101                	addi	sp,sp,-32
    800029b4:	ec06                	sd	ra,24(sp)
    800029b6:	e822                	sd	s0,16(sp)
    800029b8:	e426                	sd	s1,8(sp)
    800029ba:	e04a                	sd	s2,0(sp)
    800029bc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029be:	100027f3          	csrr	a5,sstatus
	if ((r_sstatus() & SSTATUS_SPP) != 0)
    800029c2:	1007f793          	andi	a5,a5,256
    800029c6:	e3b1                	bnez	a5,80002a0a <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029c8:	00003797          	auipc	a5,0x3
    800029cc:	51878793          	addi	a5,a5,1304 # 80005ee0 <kernelvec>
    800029d0:	10579073          	csrw	stvec,a5
	struct proc *p = myproc();
    800029d4:	fffff097          	auipc	ra,0xfffff
    800029d8:	0fc080e7          	jalr	252(ra) # 80001ad0 <myproc>
    800029dc:	84aa                	mv	s1,a0
	p->trapframe->epc = r_sepc();
    800029de:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029e0:	14102773          	csrr	a4,sepc
    800029e4:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029e6:	14202773          	csrr	a4,scause
	if (r_scause() == 8)
    800029ea:	47a1                	li	a5,8
    800029ec:	02f70763          	beq	a4,a5,80002a1a <usertrap+0x68>
	else if ((which_dev = devintr()) != 0)
    800029f0:	00000097          	auipc	ra,0x0
    800029f4:	f20080e7          	jalr	-224(ra) # 80002910 <devintr>
    800029f8:	892a                	mv	s2,a0
    800029fa:	c151                	beqz	a0,80002a7e <usertrap+0xcc>
	if (killed(p))
    800029fc:	8526                	mv	a0,s1
    800029fe:	00000097          	auipc	ra,0x0
    80002a02:	ab8080e7          	jalr	-1352(ra) # 800024b6 <killed>
    80002a06:	c929                	beqz	a0,80002a58 <usertrap+0xa6>
    80002a08:	a099                	j	80002a4e <usertrap+0x9c>
		panic("usertrap: not from user mode");
    80002a0a:	00006517          	auipc	a0,0x6
    80002a0e:	92e50513          	addi	a0,a0,-1746 # 80008338 <states.2476+0x58>
    80002a12:	ffffe097          	auipc	ra,0xffffe
    80002a16:	b32080e7          	jalr	-1230(ra) # 80000544 <panic>
		if (killed(p))
    80002a1a:	00000097          	auipc	ra,0x0
    80002a1e:	a9c080e7          	jalr	-1380(ra) # 800024b6 <killed>
    80002a22:	e921                	bnez	a0,80002a72 <usertrap+0xc0>
		p->trapframe->epc += 4;
    80002a24:	70b8                	ld	a4,96(s1)
    80002a26:	6f1c                	ld	a5,24(a4)
    80002a28:	0791                	addi	a5,a5,4
    80002a2a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a2c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002a30:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a34:	10079073          	csrw	sstatus,a5
		syscall();
    80002a38:	00000097          	auipc	ra,0x0
    80002a3c:	2d4080e7          	jalr	724(ra) # 80002d0c <syscall>
	if (killed(p))
    80002a40:	8526                	mv	a0,s1
    80002a42:	00000097          	auipc	ra,0x0
    80002a46:	a74080e7          	jalr	-1420(ra) # 800024b6 <killed>
    80002a4a:	c911                	beqz	a0,80002a5e <usertrap+0xac>
    80002a4c:	4901                	li	s2,0
		exit(-1);
    80002a4e:	557d                	li	a0,-1
    80002a50:	00000097          	auipc	ra,0x0
    80002a54:	8de080e7          	jalr	-1826(ra) # 8000232e <exit>
	if (which_dev == 2)
    80002a58:	4789                	li	a5,2
    80002a5a:	04f90f63          	beq	s2,a5,80002ab8 <usertrap+0x106>
	usertrapret();
    80002a5e:	00000097          	auipc	ra,0x0
    80002a62:	dc8080e7          	jalr	-568(ra) # 80002826 <usertrapret>
}
    80002a66:	60e2                	ld	ra,24(sp)
    80002a68:	6442                	ld	s0,16(sp)
    80002a6a:	64a2                	ld	s1,8(sp)
    80002a6c:	6902                	ld	s2,0(sp)
    80002a6e:	6105                	addi	sp,sp,32
    80002a70:	8082                	ret
			exit(-1);
    80002a72:	557d                	li	a0,-1
    80002a74:	00000097          	auipc	ra,0x0
    80002a78:	8ba080e7          	jalr	-1862(ra) # 8000232e <exit>
    80002a7c:	b765                	j	80002a24 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a7e:	142025f3          	csrr	a1,scause
		printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002a82:	5c90                	lw	a2,56(s1)
    80002a84:	00006517          	auipc	a0,0x6
    80002a88:	8d450513          	addi	a0,a0,-1836 # 80008358 <states.2476+0x78>
    80002a8c:	ffffe097          	auipc	ra,0xffffe
    80002a90:	b02080e7          	jalr	-1278(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a94:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a98:	14302673          	csrr	a2,stval
		printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a9c:	00006517          	auipc	a0,0x6
    80002aa0:	8ec50513          	addi	a0,a0,-1812 # 80008388 <states.2476+0xa8>
    80002aa4:	ffffe097          	auipc	ra,0xffffe
    80002aa8:	aea080e7          	jalr	-1302(ra) # 8000058e <printf>
		setkilled(p);
    80002aac:	8526                	mv	a0,s1
    80002aae:	00000097          	auipc	ra,0x0
    80002ab2:	9d2080e7          	jalr	-1582(ra) # 80002480 <setkilled>
    80002ab6:	b769                	j	80002a40 <usertrap+0x8e>
		yield();
    80002ab8:	fffff097          	auipc	ra,0xfffff
    80002abc:	6ea080e7          	jalr	1770(ra) # 800021a2 <yield>
    80002ac0:	bf79                	j	80002a5e <usertrap+0xac>

0000000080002ac2 <kerneltrap>:
{
    80002ac2:	7179                	addi	sp,sp,-48
    80002ac4:	f406                	sd	ra,40(sp)
    80002ac6:	f022                	sd	s0,32(sp)
    80002ac8:	ec26                	sd	s1,24(sp)
    80002aca:	e84a                	sd	s2,16(sp)
    80002acc:	e44e                	sd	s3,8(sp)
    80002ace:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ad0:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ad4:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ad8:	142029f3          	csrr	s3,scause
	if ((sstatus & SSTATUS_SPP) == 0)
    80002adc:	1004f793          	andi	a5,s1,256
    80002ae0:	cb85                	beqz	a5,80002b10 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ae2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002ae6:	8b89                	andi	a5,a5,2
	if (intr_get() != 0)
    80002ae8:	ef85                	bnez	a5,80002b20 <kerneltrap+0x5e>
	if ((which_dev = devintr()) == 0)
    80002aea:	00000097          	auipc	ra,0x0
    80002aee:	e26080e7          	jalr	-474(ra) # 80002910 <devintr>
    80002af2:	cd1d                	beqz	a0,80002b30 <kerneltrap+0x6e>
	if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002af4:	4789                	li	a5,2
    80002af6:	06f50a63          	beq	a0,a5,80002b6a <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002afa:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002afe:	10049073          	csrw	sstatus,s1
}
    80002b02:	70a2                	ld	ra,40(sp)
    80002b04:	7402                	ld	s0,32(sp)
    80002b06:	64e2                	ld	s1,24(sp)
    80002b08:	6942                	ld	s2,16(sp)
    80002b0a:	69a2                	ld	s3,8(sp)
    80002b0c:	6145                	addi	sp,sp,48
    80002b0e:	8082                	ret
		panic("kerneltrap: not from supervisor mode");
    80002b10:	00006517          	auipc	a0,0x6
    80002b14:	89850513          	addi	a0,a0,-1896 # 800083a8 <states.2476+0xc8>
    80002b18:	ffffe097          	auipc	ra,0xffffe
    80002b1c:	a2c080e7          	jalr	-1492(ra) # 80000544 <panic>
		panic("kerneltrap: interrupts enabled");
    80002b20:	00006517          	auipc	a0,0x6
    80002b24:	8b050513          	addi	a0,a0,-1872 # 800083d0 <states.2476+0xf0>
    80002b28:	ffffe097          	auipc	ra,0xffffe
    80002b2c:	a1c080e7          	jalr	-1508(ra) # 80000544 <panic>
		printf("scause %p\n", scause);
    80002b30:	85ce                	mv	a1,s3
    80002b32:	00006517          	auipc	a0,0x6
    80002b36:	8be50513          	addi	a0,a0,-1858 # 800083f0 <states.2476+0x110>
    80002b3a:	ffffe097          	auipc	ra,0xffffe
    80002b3e:	a54080e7          	jalr	-1452(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b42:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b46:	14302673          	csrr	a2,stval
		printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b4a:	00006517          	auipc	a0,0x6
    80002b4e:	8b650513          	addi	a0,a0,-1866 # 80008400 <states.2476+0x120>
    80002b52:	ffffe097          	auipc	ra,0xffffe
    80002b56:	a3c080e7          	jalr	-1476(ra) # 8000058e <printf>
		panic("kerneltrap");
    80002b5a:	00006517          	auipc	a0,0x6
    80002b5e:	8be50513          	addi	a0,a0,-1858 # 80008418 <states.2476+0x138>
    80002b62:	ffffe097          	auipc	ra,0xffffe
    80002b66:	9e2080e7          	jalr	-1566(ra) # 80000544 <panic>
	if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002b6a:	fffff097          	auipc	ra,0xfffff
    80002b6e:	f66080e7          	jalr	-154(ra) # 80001ad0 <myproc>
    80002b72:	d541                	beqz	a0,80002afa <kerneltrap+0x38>
    80002b74:	fffff097          	auipc	ra,0xfffff
    80002b78:	f5c080e7          	jalr	-164(ra) # 80001ad0 <myproc>
    80002b7c:	5118                	lw	a4,32(a0)
    80002b7e:	4791                	li	a5,4
    80002b80:	f6f71de3          	bne	a4,a5,80002afa <kerneltrap+0x38>
		yield();
    80002b84:	fffff097          	auipc	ra,0xfffff
    80002b88:	61e080e7          	jalr	1566(ra) # 800021a2 <yield>
    80002b8c:	b7bd                	j	80002afa <kerneltrap+0x38>

0000000080002b8e <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002b8e:	1101                	addi	sp,sp,-32
    80002b90:	ec06                	sd	ra,24(sp)
    80002b92:	e822                	sd	s0,16(sp)
    80002b94:	e426                	sd	s1,8(sp)
    80002b96:	1000                	addi	s0,sp,32
    80002b98:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002b9a:	fffff097          	auipc	ra,0xfffff
    80002b9e:	f36080e7          	jalr	-202(ra) # 80001ad0 <myproc>
  switch (n)
    80002ba2:	4795                	li	a5,5
    80002ba4:	0497e163          	bltu	a5,s1,80002be6 <argraw+0x58>
    80002ba8:	048a                	slli	s1,s1,0x2
    80002baa:	00006717          	auipc	a4,0x6
    80002bae:	9ae70713          	addi	a4,a4,-1618 # 80008558 <states.2476+0x278>
    80002bb2:	94ba                	add	s1,s1,a4
    80002bb4:	409c                	lw	a5,0(s1)
    80002bb6:	97ba                	add	a5,a5,a4
    80002bb8:	8782                	jr	a5
  {
  case 0:
    return p->trapframe->a0;
    80002bba:	713c                	ld	a5,96(a0)
    80002bbc:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002bbe:	60e2                	ld	ra,24(sp)
    80002bc0:	6442                	ld	s0,16(sp)
    80002bc2:	64a2                	ld	s1,8(sp)
    80002bc4:	6105                	addi	sp,sp,32
    80002bc6:	8082                	ret
    return p->trapframe->a1;
    80002bc8:	713c                	ld	a5,96(a0)
    80002bca:	7fa8                	ld	a0,120(a5)
    80002bcc:	bfcd                	j	80002bbe <argraw+0x30>
    return p->trapframe->a2;
    80002bce:	713c                	ld	a5,96(a0)
    80002bd0:	63c8                	ld	a0,128(a5)
    80002bd2:	b7f5                	j	80002bbe <argraw+0x30>
    return p->trapframe->a3;
    80002bd4:	713c                	ld	a5,96(a0)
    80002bd6:	67c8                	ld	a0,136(a5)
    80002bd8:	b7dd                	j	80002bbe <argraw+0x30>
    return p->trapframe->a4;
    80002bda:	713c                	ld	a5,96(a0)
    80002bdc:	6bc8                	ld	a0,144(a5)
    80002bde:	b7c5                	j	80002bbe <argraw+0x30>
    return p->trapframe->a5;
    80002be0:	713c                	ld	a5,96(a0)
    80002be2:	6fc8                	ld	a0,152(a5)
    80002be4:	bfe9                	j	80002bbe <argraw+0x30>
  panic("argraw");
    80002be6:	00006517          	auipc	a0,0x6
    80002bea:	84250513          	addi	a0,a0,-1982 # 80008428 <states.2476+0x148>
    80002bee:	ffffe097          	auipc	ra,0xffffe
    80002bf2:	956080e7          	jalr	-1706(ra) # 80000544 <panic>

0000000080002bf6 <fetchaddr>:
{
    80002bf6:	1101                	addi	sp,sp,-32
    80002bf8:	ec06                	sd	ra,24(sp)
    80002bfa:	e822                	sd	s0,16(sp)
    80002bfc:	e426                	sd	s1,8(sp)
    80002bfe:	e04a                	sd	s2,0(sp)
    80002c00:	1000                	addi	s0,sp,32
    80002c02:	84aa                	mv	s1,a0
    80002c04:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002c06:	fffff097          	auipc	ra,0xfffff
    80002c0a:	eca080e7          	jalr	-310(ra) # 80001ad0 <myproc>
  if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002c0e:	693c                	ld	a5,80(a0)
    80002c10:	02f4f863          	bgeu	s1,a5,80002c40 <fetchaddr+0x4a>
    80002c14:	00848713          	addi	a4,s1,8
    80002c18:	02e7e663          	bltu	a5,a4,80002c44 <fetchaddr+0x4e>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002c1c:	46a1                	li	a3,8
    80002c1e:	8626                	mv	a2,s1
    80002c20:	85ca                	mv	a1,s2
    80002c22:	6d28                	ld	a0,88(a0)
    80002c24:	fffff097          	auipc	ra,0xfffff
    80002c28:	aec080e7          	jalr	-1300(ra) # 80001710 <copyin>
    80002c2c:	00a03533          	snez	a0,a0
    80002c30:	40a00533          	neg	a0,a0
}
    80002c34:	60e2                	ld	ra,24(sp)
    80002c36:	6442                	ld	s0,16(sp)
    80002c38:	64a2                	ld	s1,8(sp)
    80002c3a:	6902                	ld	s2,0(sp)
    80002c3c:	6105                	addi	sp,sp,32
    80002c3e:	8082                	ret
    return -1;
    80002c40:	557d                	li	a0,-1
    80002c42:	bfcd                	j	80002c34 <fetchaddr+0x3e>
    80002c44:	557d                	li	a0,-1
    80002c46:	b7fd                	j	80002c34 <fetchaddr+0x3e>

0000000080002c48 <fetchstr>:
{
    80002c48:	7179                	addi	sp,sp,-48
    80002c4a:	f406                	sd	ra,40(sp)
    80002c4c:	f022                	sd	s0,32(sp)
    80002c4e:	ec26                	sd	s1,24(sp)
    80002c50:	e84a                	sd	s2,16(sp)
    80002c52:	e44e                	sd	s3,8(sp)
    80002c54:	1800                	addi	s0,sp,48
    80002c56:	892a                	mv	s2,a0
    80002c58:	84ae                	mv	s1,a1
    80002c5a:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002c5c:	fffff097          	auipc	ra,0xfffff
    80002c60:	e74080e7          	jalr	-396(ra) # 80001ad0 <myproc>
  if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80002c64:	86ce                	mv	a3,s3
    80002c66:	864a                	mv	a2,s2
    80002c68:	85a6                	mv	a1,s1
    80002c6a:	6d28                	ld	a0,88(a0)
    80002c6c:	fffff097          	auipc	ra,0xfffff
    80002c70:	b30080e7          	jalr	-1232(ra) # 8000179c <copyinstr>
    80002c74:	00054e63          	bltz	a0,80002c90 <fetchstr+0x48>
  return strlen(buf);
    80002c78:	8526                	mv	a0,s1
    80002c7a:	ffffe097          	auipc	ra,0xffffe
    80002c7e:	1f0080e7          	jalr	496(ra) # 80000e6a <strlen>
}
    80002c82:	70a2                	ld	ra,40(sp)
    80002c84:	7402                	ld	s0,32(sp)
    80002c86:	64e2                	ld	s1,24(sp)
    80002c88:	6942                	ld	s2,16(sp)
    80002c8a:	69a2                	ld	s3,8(sp)
    80002c8c:	6145                	addi	sp,sp,48
    80002c8e:	8082                	ret
    return -1;
    80002c90:	557d                	li	a0,-1
    80002c92:	bfc5                	j	80002c82 <fetchstr+0x3a>

0000000080002c94 <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80002c94:	1101                	addi	sp,sp,-32
    80002c96:	ec06                	sd	ra,24(sp)
    80002c98:	e822                	sd	s0,16(sp)
    80002c9a:	e426                	sd	s1,8(sp)
    80002c9c:	1000                	addi	s0,sp,32
    80002c9e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ca0:	00000097          	auipc	ra,0x0
    80002ca4:	eee080e7          	jalr	-274(ra) # 80002b8e <argraw>
    80002ca8:	c088                	sw	a0,0(s1)
}
    80002caa:	60e2                	ld	ra,24(sp)
    80002cac:	6442                	ld	s0,16(sp)
    80002cae:	64a2                	ld	s1,8(sp)
    80002cb0:	6105                	addi	sp,sp,32
    80002cb2:	8082                	ret

0000000080002cb4 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80002cb4:	1101                	addi	sp,sp,-32
    80002cb6:	ec06                	sd	ra,24(sp)
    80002cb8:	e822                	sd	s0,16(sp)
    80002cba:	e426                	sd	s1,8(sp)
    80002cbc:	1000                	addi	s0,sp,32
    80002cbe:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002cc0:	00000097          	auipc	ra,0x0
    80002cc4:	ece080e7          	jalr	-306(ra) # 80002b8e <argraw>
    80002cc8:	e088                	sd	a0,0(s1)
}
    80002cca:	60e2                	ld	ra,24(sp)
    80002ccc:	6442                	ld	s0,16(sp)
    80002cce:	64a2                	ld	s1,8(sp)
    80002cd0:	6105                	addi	sp,sp,32
    80002cd2:	8082                	ret

0000000080002cd4 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80002cd4:	7179                	addi	sp,sp,-48
    80002cd6:	f406                	sd	ra,40(sp)
    80002cd8:	f022                	sd	s0,32(sp)
    80002cda:	ec26                	sd	s1,24(sp)
    80002cdc:	e84a                	sd	s2,16(sp)
    80002cde:	1800                	addi	s0,sp,48
    80002ce0:	84ae                	mv	s1,a1
    80002ce2:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002ce4:	fd840593          	addi	a1,s0,-40
    80002ce8:	00000097          	auipc	ra,0x0
    80002cec:	fcc080e7          	jalr	-52(ra) # 80002cb4 <argaddr>
  return fetchstr(addr, buf, max);
    80002cf0:	864a                	mv	a2,s2
    80002cf2:	85a6                	mv	a1,s1
    80002cf4:	fd843503          	ld	a0,-40(s0)
    80002cf8:	00000097          	auipc	ra,0x0
    80002cfc:	f50080e7          	jalr	-176(ra) # 80002c48 <fetchstr>
}
    80002d00:	70a2                	ld	ra,40(sp)
    80002d02:	7402                	ld	s0,32(sp)
    80002d04:	64e2                	ld	s1,24(sp)
    80002d06:	6942                	ld	s2,16(sp)
    80002d08:	6145                	addi	sp,sp,48
    80002d0a:	8082                	ret

0000000080002d0c <syscall>:
    {"setpriority", 2}, // CHECK
    {"settickets", 1},
};

void syscall(void)
{
    80002d0c:	711d                	addi	sp,sp,-96
    80002d0e:	ec86                	sd	ra,88(sp)
    80002d10:	e8a2                	sd	s0,80(sp)
    80002d12:	e4a6                	sd	s1,72(sp)
    80002d14:	e0ca                	sd	s2,64(sp)
    80002d16:	fc4e                	sd	s3,56(sp)
    80002d18:	f852                	sd	s4,48(sp)
    80002d1a:	f456                	sd	s5,40(sp)
    80002d1c:	f05a                	sd	s6,32(sp)
    80002d1e:	ec5e                	sd	s7,24(sp)
    80002d20:	e862                	sd	s8,16(sp)
    80002d22:	e466                	sd	s9,8(sp)
    80002d24:	e06a                	sd	s10,0(sp)
    80002d26:	1080                	addi	s0,sp,96
  int num;
  struct proc *p = myproc();
    80002d28:	fffff097          	auipc	ra,0xfffff
    80002d2c:	da8080e7          	jalr	-600(ra) # 80001ad0 <myproc>
    80002d30:	8a2a                	mv	s4,a0

  num = p->trapframe->a7; // return reg
    80002d32:	7124                	ld	s1,96(a0)
    80002d34:	74dc                	ld	a5,168(s1)
    80002d36:	00078b1b          	sext.w	s6,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    80002d3a:	37fd                	addiw	a5,a5,-1
    80002d3c:	4761                	li	a4,24
    80002d3e:	06f76f63          	bltu	a4,a5,80002dbc <syscall+0xb0>
    80002d42:	003b1713          	slli	a4,s6,0x3
    80002d46:	00006797          	auipc	a5,0x6
    80002d4a:	82a78793          	addi	a5,a5,-2006 # 80008570 <syscalls>
    80002d4e:	97ba                	add	a5,a5,a4
    80002d50:	0007bd03          	ld	s10,0(a5)
    80002d54:	060d0463          	beqz	s10,80002dbc <syscall+0xb0>
  {
    80002d58:	8c8a                	mv	s9,sp
    int numargs = syscall_info[num - 1].num;
    80002d5a:	fffb0c1b          	addiw	s8,s6,-1
    80002d5e:	004c1713          	slli	a4,s8,0x4
    80002d62:	00006797          	auipc	a5,0x6
    80002d66:	c6678793          	addi	a5,a5,-922 # 800089c8 <syscall_info>
    80002d6a:	97ba                	add	a5,a5,a4
    80002d6c:	0087a983          	lw	s3,8(a5)
    int Args[numargs]; // to store value of registers acc to the number of args of the syscall
    80002d70:	00299793          	slli	a5,s3,0x2
    80002d74:	07bd                	addi	a5,a5,15
    80002d76:	9bc1                	andi	a5,a5,-16
    80002d78:	40f10133          	sub	sp,sp,a5
    80002d7c:	8b8a                	mv	s7,sp
    int j = 0;
    while (j < numargs)
    80002d7e:	11305363          	blez	s3,80002e84 <syscall+0x178>
    80002d82:	8ade                	mv	s5,s7
    80002d84:	895e                	mv	s2,s7
    int j = 0;
    80002d86:	4481                	li	s1,0
    {
      Args[j] = argraw(j);
    80002d88:	8526                	mv	a0,s1
    80002d8a:	00000097          	auipc	ra,0x0
    80002d8e:	e04080e7          	jalr	-508(ra) # 80002b8e <argraw>
    80002d92:	00a92023          	sw	a0,0(s2)
      j++;
    80002d96:	2485                	addiw	s1,s1,1
    while (j < numargs)
    80002d98:	0911                	addi	s2,s2,4
    80002d9a:	fe9997e3          	bne	s3,s1,80002d88 <syscall+0x7c>
    }

    int shift = 1 << num; // mask for num
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002d9e:	060a3483          	ld	s1,96(s4)
    80002da2:	9d02                	jalr	s10
    80002da4:	f8a8                	sd	a0,112(s1)
    int shift = 1 << num; // mask for num
    80002da6:	4785                	li	a5,1
    80002da8:	016797bb          	sllw	a5,a5,s6

    if (p->mask & shift)
    80002dac:	000a2b03          	lw	s6,0(s4)
    80002db0:	0167f7b3          	and	a5,a5,s6
    80002db4:	2781                	sext.w	a5,a5
    80002db6:	e7a1                	bnez	a5,80002dfe <syscall+0xf2>
    80002db8:	8166                	mv	sp,s9
  {
    80002dba:	a015                	j	80002dde <syscall+0xd2>
      printf(" -> %d\n", p->trapframe->a0);
    }
  }
  else
  {
    printf("%d %s: unknown sys call %d\n",
    80002dbc:	86da                	mv	a3,s6
    80002dbe:	160a0613          	addi	a2,s4,352
    80002dc2:	038a2583          	lw	a1,56(s4)
    80002dc6:	00005517          	auipc	a0,0x5
    80002dca:	68250513          	addi	a0,a0,1666 # 80008448 <states.2476+0x168>
    80002dce:	ffffd097          	auipc	ra,0xffffd
    80002dd2:	7c0080e7          	jalr	1984(ra) # 8000058e <printf>
           p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002dd6:	060a3783          	ld	a5,96(s4)
    80002dda:	577d                	li	a4,-1
    80002ddc:	fbb8                	sd	a4,112(a5)
  }
}
    80002dde:	fa040113          	addi	sp,s0,-96
    80002de2:	60e6                	ld	ra,88(sp)
    80002de4:	6446                	ld	s0,80(sp)
    80002de6:	64a6                	ld	s1,72(sp)
    80002de8:	6906                	ld	s2,64(sp)
    80002dea:	79e2                	ld	s3,56(sp)
    80002dec:	7a42                	ld	s4,48(sp)
    80002dee:	7aa2                	ld	s5,40(sp)
    80002df0:	7b02                	ld	s6,32(sp)
    80002df2:	6be2                	ld	s7,24(sp)
    80002df4:	6c42                	ld	s8,16(sp)
    80002df6:	6ca2                	ld	s9,8(sp)
    80002df8:	6d02                	ld	s10,0(sp)
    80002dfa:	6125                	addi	sp,sp,96
    80002dfc:	8082                	ret
      printf("%d: syscall %s ", p->pid, syscall_info[num - 1].name);
    80002dfe:	0c12                	slli	s8,s8,0x4
    80002e00:	00006797          	auipc	a5,0x6
    80002e04:	bc878793          	addi	a5,a5,-1080 # 800089c8 <syscall_info>
    80002e08:	9c3e                	add	s8,s8,a5
    80002e0a:	000c3603          	ld	a2,0(s8)
    80002e0e:	038a2583          	lw	a1,56(s4)
    80002e12:	00005517          	auipc	a0,0x5
    80002e16:	65650513          	addi	a0,a0,1622 # 80008468 <states.2476+0x188>
    80002e1a:	ffffd097          	auipc	ra,0xffffd
    80002e1e:	774080e7          	jalr	1908(ra) # 8000058e <printf>
      printf("(");
    80002e22:	00005517          	auipc	a0,0x5
    80002e26:	65650513          	addi	a0,a0,1622 # 80008478 <states.2476+0x198>
    80002e2a:	ffffd097          	auipc	ra,0xffffd
    80002e2e:	764080e7          	jalr	1892(ra) # 8000058e <printf>
      while (i < numargs)
    80002e32:	fff9879b          	addiw	a5,s3,-1
    80002e36:	1782                	slli	a5,a5,0x20
    80002e38:	9381                	srli	a5,a5,0x20
    80002e3a:	0785                	addi	a5,a5,1
    80002e3c:	078a                	slli	a5,a5,0x2
    80002e3e:	9bbe                	add	s7,s7,a5
        printf("%d ", Args[i]);
    80002e40:	00005497          	auipc	s1,0x5
    80002e44:	5f048493          	addi	s1,s1,1520 # 80008430 <states.2476+0x150>
    80002e48:	000aa583          	lw	a1,0(s5)
    80002e4c:	8526                	mv	a0,s1
    80002e4e:	ffffd097          	auipc	ra,0xffffd
    80002e52:	740080e7          	jalr	1856(ra) # 8000058e <printf>
      while (i < numargs)
    80002e56:	0a91                	addi	s5,s5,4
    80002e58:	ff7a98e3          	bne	s5,s7,80002e48 <syscall+0x13c>
      printf(")");
    80002e5c:	00005517          	auipc	a0,0x5
    80002e60:	5dc50513          	addi	a0,a0,1500 # 80008438 <states.2476+0x158>
    80002e64:	ffffd097          	auipc	ra,0xffffd
    80002e68:	72a080e7          	jalr	1834(ra) # 8000058e <printf>
      printf(" -> %d\n", p->trapframe->a0);
    80002e6c:	060a3783          	ld	a5,96(s4)
    80002e70:	7bac                	ld	a1,112(a5)
    80002e72:	00005517          	auipc	a0,0x5
    80002e76:	5ce50513          	addi	a0,a0,1486 # 80008440 <states.2476+0x160>
    80002e7a:	ffffd097          	auipc	ra,0xffffd
    80002e7e:	714080e7          	jalr	1812(ra) # 8000058e <printf>
    80002e82:	bf1d                	j	80002db8 <syscall+0xac>
    p->trapframe->a0 = syscalls[num]();
    80002e84:	9d02                	jalr	s10
    80002e86:	f8a8                	sd	a0,112(s1)
    int shift = 1 << num; // mask for num
    80002e88:	4785                	li	a5,1
    80002e8a:	016797bb          	sllw	a5,a5,s6
    if (p->mask & shift)
    80002e8e:	000a2703          	lw	a4,0(s4)
    80002e92:	8ff9                	and	a5,a5,a4
    80002e94:	2781                	sext.w	a5,a5
    80002e96:	d38d                	beqz	a5,80002db8 <syscall+0xac>
      printf("%d: syscall %s ", p->pid, syscall_info[num - 1].name);
    80002e98:	0c12                	slli	s8,s8,0x4
    80002e9a:	00006797          	auipc	a5,0x6
    80002e9e:	b2e78793          	addi	a5,a5,-1234 # 800089c8 <syscall_info>
    80002ea2:	97e2                	add	a5,a5,s8
    80002ea4:	6390                	ld	a2,0(a5)
    80002ea6:	038a2583          	lw	a1,56(s4)
    80002eaa:	00005517          	auipc	a0,0x5
    80002eae:	5be50513          	addi	a0,a0,1470 # 80008468 <states.2476+0x188>
    80002eb2:	ffffd097          	auipc	ra,0xffffd
    80002eb6:	6dc080e7          	jalr	1756(ra) # 8000058e <printf>
      printf("(");
    80002eba:	00005517          	auipc	a0,0x5
    80002ebe:	5be50513          	addi	a0,a0,1470 # 80008478 <states.2476+0x198>
    80002ec2:	ffffd097          	auipc	ra,0xffffd
    80002ec6:	6cc080e7          	jalr	1740(ra) # 8000058e <printf>
      while (i < numargs)
    80002eca:	bf49                	j	80002e5c <syscall+0x150>

0000000080002ecc <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002ecc:	1101                	addi	sp,sp,-32
    80002ece:	ec06                	sd	ra,24(sp)
    80002ed0:	e822                	sd	s0,16(sp)
    80002ed2:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002ed4:	fec40593          	addi	a1,s0,-20
    80002ed8:	4501                	li	a0,0
    80002eda:	00000097          	auipc	ra,0x0
    80002ede:	dba080e7          	jalr	-582(ra) # 80002c94 <argint>
  exit(n);
    80002ee2:	fec42503          	lw	a0,-20(s0)
    80002ee6:	fffff097          	auipc	ra,0xfffff
    80002eea:	448080e7          	jalr	1096(ra) # 8000232e <exit>
  return 0; // not reached
}
    80002eee:	4501                	li	a0,0
    80002ef0:	60e2                	ld	ra,24(sp)
    80002ef2:	6442                	ld	s0,16(sp)
    80002ef4:	6105                	addi	sp,sp,32
    80002ef6:	8082                	ret

0000000080002ef8 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002ef8:	1141                	addi	sp,sp,-16
    80002efa:	e406                	sd	ra,8(sp)
    80002efc:	e022                	sd	s0,0(sp)
    80002efe:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002f00:	fffff097          	auipc	ra,0xfffff
    80002f04:	bd0080e7          	jalr	-1072(ra) # 80001ad0 <myproc>
}
    80002f08:	5d08                	lw	a0,56(a0)
    80002f0a:	60a2                	ld	ra,8(sp)
    80002f0c:	6402                	ld	s0,0(sp)
    80002f0e:	0141                	addi	sp,sp,16
    80002f10:	8082                	ret

0000000080002f12 <sys_fork>:

uint64
sys_fork(void)
{
    80002f12:	1141                	addi	sp,sp,-16
    80002f14:	e406                	sd	ra,8(sp)
    80002f16:	e022                	sd	s0,0(sp)
    80002f18:	0800                	addi	s0,sp,16
  return fork();
    80002f1a:	fffff097          	auipc	ra,0xfffff
    80002f1e:	f78080e7          	jalr	-136(ra) # 80001e92 <fork>
}
    80002f22:	60a2                	ld	ra,8(sp)
    80002f24:	6402                	ld	s0,0(sp)
    80002f26:	0141                	addi	sp,sp,16
    80002f28:	8082                	ret

0000000080002f2a <sys_wait>:

uint64
sys_wait(void)
{
    80002f2a:	1101                	addi	sp,sp,-32
    80002f2c:	ec06                	sd	ra,24(sp)
    80002f2e:	e822                	sd	s0,16(sp)
    80002f30:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002f32:	fe840593          	addi	a1,s0,-24
    80002f36:	4501                	li	a0,0
    80002f38:	00000097          	auipc	ra,0x0
    80002f3c:	d7c080e7          	jalr	-644(ra) # 80002cb4 <argaddr>
  return wait(p);
    80002f40:	fe843503          	ld	a0,-24(s0)
    80002f44:	fffff097          	auipc	ra,0xfffff
    80002f48:	5a8080e7          	jalr	1448(ra) # 800024ec <wait>
}
    80002f4c:	60e2                	ld	ra,24(sp)
    80002f4e:	6442                	ld	s0,16(sp)
    80002f50:	6105                	addi	sp,sp,32
    80002f52:	8082                	ret

0000000080002f54 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002f54:	7179                	addi	sp,sp,-48
    80002f56:	f406                	sd	ra,40(sp)
    80002f58:	f022                	sd	s0,32(sp)
    80002f5a:	ec26                	sd	s1,24(sp)
    80002f5c:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002f5e:	fdc40593          	addi	a1,s0,-36
    80002f62:	4501                	li	a0,0
    80002f64:	00000097          	auipc	ra,0x0
    80002f68:	d30080e7          	jalr	-720(ra) # 80002c94 <argint>
  addr = myproc()->sz;
    80002f6c:	fffff097          	auipc	ra,0xfffff
    80002f70:	b64080e7          	jalr	-1180(ra) # 80001ad0 <myproc>
    80002f74:	6924                	ld	s1,80(a0)
  if (growproc(n) < 0)
    80002f76:	fdc42503          	lw	a0,-36(s0)
    80002f7a:	fffff097          	auipc	ra,0xfffff
    80002f7e:	ebc080e7          	jalr	-324(ra) # 80001e36 <growproc>
    80002f82:	00054863          	bltz	a0,80002f92 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002f86:	8526                	mv	a0,s1
    80002f88:	70a2                	ld	ra,40(sp)
    80002f8a:	7402                	ld	s0,32(sp)
    80002f8c:	64e2                	ld	s1,24(sp)
    80002f8e:	6145                	addi	sp,sp,48
    80002f90:	8082                	ret
    return -1;
    80002f92:	54fd                	li	s1,-1
    80002f94:	bfcd                	j	80002f86 <sys_sbrk+0x32>

0000000080002f96 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002f96:	7139                	addi	sp,sp,-64
    80002f98:	fc06                	sd	ra,56(sp)
    80002f9a:	f822                	sd	s0,48(sp)
    80002f9c:	f426                	sd	s1,40(sp)
    80002f9e:	f04a                	sd	s2,32(sp)
    80002fa0:	ec4e                	sd	s3,24(sp)
    80002fa2:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002fa4:	fcc40593          	addi	a1,s0,-52
    80002fa8:	4501                	li	a0,0
    80002faa:	00000097          	auipc	ra,0x0
    80002fae:	cea080e7          	jalr	-790(ra) # 80002c94 <argint>
  acquire(&tickslock);
    80002fb2:	00015517          	auipc	a0,0x15
    80002fb6:	69e50513          	addi	a0,a0,1694 # 80018650 <tickslock>
    80002fba:	ffffe097          	auipc	ra,0xffffe
    80002fbe:	c30080e7          	jalr	-976(ra) # 80000bea <acquire>
  ticks0 = ticks;
    80002fc2:	00006917          	auipc	s2,0x6
    80002fc6:	bee92903          	lw	s2,-1042(s2) # 80008bb0 <ticks>
  while (ticks - ticks0 < n)
    80002fca:	fcc42783          	lw	a5,-52(s0)
    80002fce:	cf9d                	beqz	a5,8000300c <sys_sleep+0x76>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002fd0:	00015997          	auipc	s3,0x15
    80002fd4:	68098993          	addi	s3,s3,1664 # 80018650 <tickslock>
    80002fd8:	00006497          	auipc	s1,0x6
    80002fdc:	bd848493          	addi	s1,s1,-1064 # 80008bb0 <ticks>
    if (killed(myproc()))
    80002fe0:	fffff097          	auipc	ra,0xfffff
    80002fe4:	af0080e7          	jalr	-1296(ra) # 80001ad0 <myproc>
    80002fe8:	fffff097          	auipc	ra,0xfffff
    80002fec:	4ce080e7          	jalr	1230(ra) # 800024b6 <killed>
    80002ff0:	ed15                	bnez	a0,8000302c <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002ff2:	85ce                	mv	a1,s3
    80002ff4:	8526                	mv	a0,s1
    80002ff6:	fffff097          	auipc	ra,0xfffff
    80002ffa:	1f2080e7          	jalr	498(ra) # 800021e8 <sleep>
  while (ticks - ticks0 < n)
    80002ffe:	409c                	lw	a5,0(s1)
    80003000:	412787bb          	subw	a5,a5,s2
    80003004:	fcc42703          	lw	a4,-52(s0)
    80003008:	fce7ece3          	bltu	a5,a4,80002fe0 <sys_sleep+0x4a>
  }
  release(&tickslock);
    8000300c:	00015517          	auipc	a0,0x15
    80003010:	64450513          	addi	a0,a0,1604 # 80018650 <tickslock>
    80003014:	ffffe097          	auipc	ra,0xffffe
    80003018:	c8a080e7          	jalr	-886(ra) # 80000c9e <release>
  return 0;
    8000301c:	4501                	li	a0,0
}
    8000301e:	70e2                	ld	ra,56(sp)
    80003020:	7442                	ld	s0,48(sp)
    80003022:	74a2                	ld	s1,40(sp)
    80003024:	7902                	ld	s2,32(sp)
    80003026:	69e2                	ld	s3,24(sp)
    80003028:	6121                	addi	sp,sp,64
    8000302a:	8082                	ret
      release(&tickslock);
    8000302c:	00015517          	auipc	a0,0x15
    80003030:	62450513          	addi	a0,a0,1572 # 80018650 <tickslock>
    80003034:	ffffe097          	auipc	ra,0xffffe
    80003038:	c6a080e7          	jalr	-918(ra) # 80000c9e <release>
      return -1;
    8000303c:	557d                	li	a0,-1
    8000303e:	b7c5                	j	8000301e <sys_sleep+0x88>

0000000080003040 <sys_kill>:

uint64
sys_kill(void)
{
    80003040:	1101                	addi	sp,sp,-32
    80003042:	ec06                	sd	ra,24(sp)
    80003044:	e822                	sd	s0,16(sp)
    80003046:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80003048:	fec40593          	addi	a1,s0,-20
    8000304c:	4501                	li	a0,0
    8000304e:	00000097          	auipc	ra,0x0
    80003052:	c46080e7          	jalr	-954(ra) # 80002c94 <argint>
  return kill(pid);
    80003056:	fec42503          	lw	a0,-20(s0)
    8000305a:	fffff097          	auipc	ra,0xfffff
    8000305e:	3ac080e7          	jalr	940(ra) # 80002406 <kill>
}
    80003062:	60e2                	ld	ra,24(sp)
    80003064:	6442                	ld	s0,16(sp)
    80003066:	6105                	addi	sp,sp,32
    80003068:	8082                	ret

000000008000306a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000306a:	1101                	addi	sp,sp,-32
    8000306c:	ec06                	sd	ra,24(sp)
    8000306e:	e822                	sd	s0,16(sp)
    80003070:	e426                	sd	s1,8(sp)
    80003072:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003074:	00015517          	auipc	a0,0x15
    80003078:	5dc50513          	addi	a0,a0,1500 # 80018650 <tickslock>
    8000307c:	ffffe097          	auipc	ra,0xffffe
    80003080:	b6e080e7          	jalr	-1170(ra) # 80000bea <acquire>
  xticks = ticks;
    80003084:	00006497          	auipc	s1,0x6
    80003088:	b2c4a483          	lw	s1,-1236(s1) # 80008bb0 <ticks>
  release(&tickslock);
    8000308c:	00015517          	auipc	a0,0x15
    80003090:	5c450513          	addi	a0,a0,1476 # 80018650 <tickslock>
    80003094:	ffffe097          	auipc	ra,0xffffe
    80003098:	c0a080e7          	jalr	-1014(ra) # 80000c9e <release>
  return xticks;
}
    8000309c:	02049513          	slli	a0,s1,0x20
    800030a0:	9101                	srli	a0,a0,0x20
    800030a2:	60e2                	ld	ra,24(sp)
    800030a4:	6442                	ld	s0,16(sp)
    800030a6:	64a2                	ld	s1,8(sp)
    800030a8:	6105                	addi	sp,sp,32
    800030aa:	8082                	ret

00000000800030ac <sys_trace>:

uint64
sys_trace(void)
{
    800030ac:	1101                	addi	sp,sp,-32
    800030ae:	ec06                	sd	ra,24(sp)
    800030b0:	e822                	sd	s0,16(sp)
    800030b2:	1000                	addi	s0,sp,32
  int n; // mask
  argint(0, &n);
    800030b4:	fec40593          	addi	a1,s0,-20
    800030b8:	4501                	li	a0,0
    800030ba:	00000097          	auipc	ra,0x0
    800030be:	bda080e7          	jalr	-1062(ra) # 80002c94 <argint>
  myproc()->mask = n;
    800030c2:	fffff097          	auipc	ra,0xfffff
    800030c6:	a0e080e7          	jalr	-1522(ra) # 80001ad0 <myproc>
    800030ca:	fec42783          	lw	a5,-20(s0)
    800030ce:	c11c                	sw	a5,0(a0)
  return 0;
}
    800030d0:	4501                	li	a0,0
    800030d2:	60e2                	ld	ra,24(sp)
    800030d4:	6442                	ld	s0,16(sp)
    800030d6:	6105                	addi	sp,sp,32
    800030d8:	8082                	ret

00000000800030da <sys_sigalarm>:

uint64
sys_sigalarm(void)
{
    800030da:	1101                	addi	sp,sp,-32
    800030dc:	ec06                	sd	ra,24(sp)
    800030de:	e822                	sd	s0,16(sp)
    800030e0:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800030e2:	fec40593          	addi	a1,s0,-20
    800030e6:	4501                	li	a0,0
    800030e8:	00000097          	auipc	ra,0x0
    800030ec:	bac080e7          	jalr	-1108(ra) # 80002c94 <argint>
  myproc()->ticks0 = 0;
    800030f0:	fffff097          	auipc	ra,0xfffff
    800030f4:	9e0080e7          	jalr	-1568(ra) # 80001ad0 <myproc>
    800030f8:	00052223          	sw	zero,4(a0)
  return 0;
}
    800030fc:	4501                	li	a0,0
    800030fe:	60e2                	ld	ra,24(sp)
    80003100:	6442                	ld	s0,16(sp)
    80003102:	6105                	addi	sp,sp,32
    80003104:	8082                	ret

0000000080003106 <sys_setpriority>:

uint64
sys_setpriority(void)
{
    80003106:	1101                	addi	sp,sp,-32
    80003108:	ec06                	sd	ra,24(sp)
    8000310a:	e822                	sd	s0,16(sp)
    8000310c:	1000                	addi	s0,sp,32
  int priority;
  int pid;
  argint(0, &priority);
    8000310e:	fec40593          	addi	a1,s0,-20
    80003112:	4501                	li	a0,0
    80003114:	00000097          	auipc	ra,0x0
    80003118:	b80080e7          	jalr	-1152(ra) # 80002c94 <argint>
  argint(1, &pid);
    8000311c:	fe840593          	addi	a1,s0,-24
    80003120:	4505                	li	a0,1
    80003122:	00000097          	auipc	ra,0x0
    80003126:	b72080e7          	jalr	-1166(ra) # 80002c94 <argint>
  return set_priority(priority, pid);
    8000312a:	fe842583          	lw	a1,-24(s0)
    8000312e:	fec42503          	lw	a0,-20(s0)
    80003132:	ffffe097          	auipc	ra,0xffffe
    80003136:	76c080e7          	jalr	1900(ra) # 8000189e <set_priority>
}
    8000313a:	60e2                	ld	ra,24(sp)
    8000313c:	6442                	ld	s0,16(sp)
    8000313e:	6105                	addi	sp,sp,32
    80003140:	8082                	ret

0000000080003142 <sys_settickets>:

uint64
sys_settickets(void){
    80003142:	1101                	addi	sp,sp,-32
    80003144:	ec06                	sd	ra,24(sp)
    80003146:	e822                	sd	s0,16(sp)
    80003148:	1000                	addi	s0,sp,32
  int n; // tickets
  argint(0, &n);
    8000314a:	fec40593          	addi	a1,s0,-20
    8000314e:	4501                	li	a0,0
    80003150:	00000097          	auipc	ra,0x0
    80003154:	b44080e7          	jalr	-1212(ra) # 80002c94 <argint>
  myproc()->tickets = n;
    80003158:	fffff097          	auipc	ra,0xfffff
    8000315c:	978080e7          	jalr	-1672(ra) # 80001ad0 <myproc>
    80003160:	fec42783          	lw	a5,-20(s0)
    80003164:	16f52823          	sw	a5,368(a0)
  return 0;
}
    80003168:	4501                	li	a0,0
    8000316a:	60e2                	ld	ra,24(sp)
    8000316c:	6442                	ld	s0,16(sp)
    8000316e:	6105                	addi	sp,sp,32
    80003170:	8082                	ret

0000000080003172 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003172:	7179                	addi	sp,sp,-48
    80003174:	f406                	sd	ra,40(sp)
    80003176:	f022                	sd	s0,32(sp)
    80003178:	ec26                	sd	s1,24(sp)
    8000317a:	e84a                	sd	s2,16(sp)
    8000317c:	e44e                	sd	s3,8(sp)
    8000317e:	e052                	sd	s4,0(sp)
    80003180:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003182:	00005597          	auipc	a1,0x5
    80003186:	4be58593          	addi	a1,a1,1214 # 80008640 <syscalls+0xd0>
    8000318a:	00015517          	auipc	a0,0x15
    8000318e:	4de50513          	addi	a0,a0,1246 # 80018668 <bcache>
    80003192:	ffffe097          	auipc	ra,0xffffe
    80003196:	9c8080e7          	jalr	-1592(ra) # 80000b5a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000319a:	0001d797          	auipc	a5,0x1d
    8000319e:	4ce78793          	addi	a5,a5,1230 # 80020668 <bcache+0x8000>
    800031a2:	0001d717          	auipc	a4,0x1d
    800031a6:	72e70713          	addi	a4,a4,1838 # 800208d0 <bcache+0x8268>
    800031aa:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800031ae:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800031b2:	00015497          	auipc	s1,0x15
    800031b6:	4ce48493          	addi	s1,s1,1230 # 80018680 <bcache+0x18>
    b->next = bcache.head.next;
    800031ba:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800031bc:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800031be:	00005a17          	auipc	s4,0x5
    800031c2:	48aa0a13          	addi	s4,s4,1162 # 80008648 <syscalls+0xd8>
    b->next = bcache.head.next;
    800031c6:	2b893783          	ld	a5,696(s2)
    800031ca:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800031cc:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800031d0:	85d2                	mv	a1,s4
    800031d2:	01048513          	addi	a0,s1,16
    800031d6:	00001097          	auipc	ra,0x1
    800031da:	4c4080e7          	jalr	1220(ra) # 8000469a <initsleeplock>
    bcache.head.next->prev = b;
    800031de:	2b893783          	ld	a5,696(s2)
    800031e2:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800031e4:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800031e8:	45848493          	addi	s1,s1,1112
    800031ec:	fd349de3          	bne	s1,s3,800031c6 <binit+0x54>
  }
}
    800031f0:	70a2                	ld	ra,40(sp)
    800031f2:	7402                	ld	s0,32(sp)
    800031f4:	64e2                	ld	s1,24(sp)
    800031f6:	6942                	ld	s2,16(sp)
    800031f8:	69a2                	ld	s3,8(sp)
    800031fa:	6a02                	ld	s4,0(sp)
    800031fc:	6145                	addi	sp,sp,48
    800031fe:	8082                	ret

0000000080003200 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003200:	7179                	addi	sp,sp,-48
    80003202:	f406                	sd	ra,40(sp)
    80003204:	f022                	sd	s0,32(sp)
    80003206:	ec26                	sd	s1,24(sp)
    80003208:	e84a                	sd	s2,16(sp)
    8000320a:	e44e                	sd	s3,8(sp)
    8000320c:	1800                	addi	s0,sp,48
    8000320e:	89aa                	mv	s3,a0
    80003210:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80003212:	00015517          	auipc	a0,0x15
    80003216:	45650513          	addi	a0,a0,1110 # 80018668 <bcache>
    8000321a:	ffffe097          	auipc	ra,0xffffe
    8000321e:	9d0080e7          	jalr	-1584(ra) # 80000bea <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003222:	0001d497          	auipc	s1,0x1d
    80003226:	6fe4b483          	ld	s1,1790(s1) # 80020920 <bcache+0x82b8>
    8000322a:	0001d797          	auipc	a5,0x1d
    8000322e:	6a678793          	addi	a5,a5,1702 # 800208d0 <bcache+0x8268>
    80003232:	02f48f63          	beq	s1,a5,80003270 <bread+0x70>
    80003236:	873e                	mv	a4,a5
    80003238:	a021                	j	80003240 <bread+0x40>
    8000323a:	68a4                	ld	s1,80(s1)
    8000323c:	02e48a63          	beq	s1,a4,80003270 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003240:	449c                	lw	a5,8(s1)
    80003242:	ff379ce3          	bne	a5,s3,8000323a <bread+0x3a>
    80003246:	44dc                	lw	a5,12(s1)
    80003248:	ff2799e3          	bne	a5,s2,8000323a <bread+0x3a>
      b->refcnt++;
    8000324c:	40bc                	lw	a5,64(s1)
    8000324e:	2785                	addiw	a5,a5,1
    80003250:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003252:	00015517          	auipc	a0,0x15
    80003256:	41650513          	addi	a0,a0,1046 # 80018668 <bcache>
    8000325a:	ffffe097          	auipc	ra,0xffffe
    8000325e:	a44080e7          	jalr	-1468(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    80003262:	01048513          	addi	a0,s1,16
    80003266:	00001097          	auipc	ra,0x1
    8000326a:	46e080e7          	jalr	1134(ra) # 800046d4 <acquiresleep>
      return b;
    8000326e:	a8b9                	j	800032cc <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003270:	0001d497          	auipc	s1,0x1d
    80003274:	6a84b483          	ld	s1,1704(s1) # 80020918 <bcache+0x82b0>
    80003278:	0001d797          	auipc	a5,0x1d
    8000327c:	65878793          	addi	a5,a5,1624 # 800208d0 <bcache+0x8268>
    80003280:	00f48863          	beq	s1,a5,80003290 <bread+0x90>
    80003284:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003286:	40bc                	lw	a5,64(s1)
    80003288:	cf81                	beqz	a5,800032a0 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000328a:	64a4                	ld	s1,72(s1)
    8000328c:	fee49de3          	bne	s1,a4,80003286 <bread+0x86>
  panic("bget: no buffers");
    80003290:	00005517          	auipc	a0,0x5
    80003294:	3c050513          	addi	a0,a0,960 # 80008650 <syscalls+0xe0>
    80003298:	ffffd097          	auipc	ra,0xffffd
    8000329c:	2ac080e7          	jalr	684(ra) # 80000544 <panic>
      b->dev = dev;
    800032a0:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    800032a4:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    800032a8:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800032ac:	4785                	li	a5,1
    800032ae:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800032b0:	00015517          	auipc	a0,0x15
    800032b4:	3b850513          	addi	a0,a0,952 # 80018668 <bcache>
    800032b8:	ffffe097          	auipc	ra,0xffffe
    800032bc:	9e6080e7          	jalr	-1562(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    800032c0:	01048513          	addi	a0,s1,16
    800032c4:	00001097          	auipc	ra,0x1
    800032c8:	410080e7          	jalr	1040(ra) # 800046d4 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800032cc:	409c                	lw	a5,0(s1)
    800032ce:	cb89                	beqz	a5,800032e0 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800032d0:	8526                	mv	a0,s1
    800032d2:	70a2                	ld	ra,40(sp)
    800032d4:	7402                	ld	s0,32(sp)
    800032d6:	64e2                	ld	s1,24(sp)
    800032d8:	6942                	ld	s2,16(sp)
    800032da:	69a2                	ld	s3,8(sp)
    800032dc:	6145                	addi	sp,sp,48
    800032de:	8082                	ret
    virtio_disk_rw(b, 0);
    800032e0:	4581                	li	a1,0
    800032e2:	8526                	mv	a0,s1
    800032e4:	00003097          	auipc	ra,0x3
    800032e8:	fc4080e7          	jalr	-60(ra) # 800062a8 <virtio_disk_rw>
    b->valid = 1;
    800032ec:	4785                	li	a5,1
    800032ee:	c09c                	sw	a5,0(s1)
  return b;
    800032f0:	b7c5                	j	800032d0 <bread+0xd0>

00000000800032f2 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800032f2:	1101                	addi	sp,sp,-32
    800032f4:	ec06                	sd	ra,24(sp)
    800032f6:	e822                	sd	s0,16(sp)
    800032f8:	e426                	sd	s1,8(sp)
    800032fa:	1000                	addi	s0,sp,32
    800032fc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800032fe:	0541                	addi	a0,a0,16
    80003300:	00001097          	auipc	ra,0x1
    80003304:	46e080e7          	jalr	1134(ra) # 8000476e <holdingsleep>
    80003308:	cd01                	beqz	a0,80003320 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000330a:	4585                	li	a1,1
    8000330c:	8526                	mv	a0,s1
    8000330e:	00003097          	auipc	ra,0x3
    80003312:	f9a080e7          	jalr	-102(ra) # 800062a8 <virtio_disk_rw>
}
    80003316:	60e2                	ld	ra,24(sp)
    80003318:	6442                	ld	s0,16(sp)
    8000331a:	64a2                	ld	s1,8(sp)
    8000331c:	6105                	addi	sp,sp,32
    8000331e:	8082                	ret
    panic("bwrite");
    80003320:	00005517          	auipc	a0,0x5
    80003324:	34850513          	addi	a0,a0,840 # 80008668 <syscalls+0xf8>
    80003328:	ffffd097          	auipc	ra,0xffffd
    8000332c:	21c080e7          	jalr	540(ra) # 80000544 <panic>

0000000080003330 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003330:	1101                	addi	sp,sp,-32
    80003332:	ec06                	sd	ra,24(sp)
    80003334:	e822                	sd	s0,16(sp)
    80003336:	e426                	sd	s1,8(sp)
    80003338:	e04a                	sd	s2,0(sp)
    8000333a:	1000                	addi	s0,sp,32
    8000333c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000333e:	01050913          	addi	s2,a0,16
    80003342:	854a                	mv	a0,s2
    80003344:	00001097          	auipc	ra,0x1
    80003348:	42a080e7          	jalr	1066(ra) # 8000476e <holdingsleep>
    8000334c:	c92d                	beqz	a0,800033be <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000334e:	854a                	mv	a0,s2
    80003350:	00001097          	auipc	ra,0x1
    80003354:	3da080e7          	jalr	986(ra) # 8000472a <releasesleep>

  acquire(&bcache.lock);
    80003358:	00015517          	auipc	a0,0x15
    8000335c:	31050513          	addi	a0,a0,784 # 80018668 <bcache>
    80003360:	ffffe097          	auipc	ra,0xffffe
    80003364:	88a080e7          	jalr	-1910(ra) # 80000bea <acquire>
  b->refcnt--;
    80003368:	40bc                	lw	a5,64(s1)
    8000336a:	37fd                	addiw	a5,a5,-1
    8000336c:	0007871b          	sext.w	a4,a5
    80003370:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003372:	eb05                	bnez	a4,800033a2 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003374:	68bc                	ld	a5,80(s1)
    80003376:	64b8                	ld	a4,72(s1)
    80003378:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000337a:	64bc                	ld	a5,72(s1)
    8000337c:	68b8                	ld	a4,80(s1)
    8000337e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003380:	0001d797          	auipc	a5,0x1d
    80003384:	2e878793          	addi	a5,a5,744 # 80020668 <bcache+0x8000>
    80003388:	2b87b703          	ld	a4,696(a5)
    8000338c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000338e:	0001d717          	auipc	a4,0x1d
    80003392:	54270713          	addi	a4,a4,1346 # 800208d0 <bcache+0x8268>
    80003396:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003398:	2b87b703          	ld	a4,696(a5)
    8000339c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000339e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800033a2:	00015517          	auipc	a0,0x15
    800033a6:	2c650513          	addi	a0,a0,710 # 80018668 <bcache>
    800033aa:	ffffe097          	auipc	ra,0xffffe
    800033ae:	8f4080e7          	jalr	-1804(ra) # 80000c9e <release>
}
    800033b2:	60e2                	ld	ra,24(sp)
    800033b4:	6442                	ld	s0,16(sp)
    800033b6:	64a2                	ld	s1,8(sp)
    800033b8:	6902                	ld	s2,0(sp)
    800033ba:	6105                	addi	sp,sp,32
    800033bc:	8082                	ret
    panic("brelse");
    800033be:	00005517          	auipc	a0,0x5
    800033c2:	2b250513          	addi	a0,a0,690 # 80008670 <syscalls+0x100>
    800033c6:	ffffd097          	auipc	ra,0xffffd
    800033ca:	17e080e7          	jalr	382(ra) # 80000544 <panic>

00000000800033ce <bpin>:

void
bpin(struct buf *b) {
    800033ce:	1101                	addi	sp,sp,-32
    800033d0:	ec06                	sd	ra,24(sp)
    800033d2:	e822                	sd	s0,16(sp)
    800033d4:	e426                	sd	s1,8(sp)
    800033d6:	1000                	addi	s0,sp,32
    800033d8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800033da:	00015517          	auipc	a0,0x15
    800033de:	28e50513          	addi	a0,a0,654 # 80018668 <bcache>
    800033e2:	ffffe097          	auipc	ra,0xffffe
    800033e6:	808080e7          	jalr	-2040(ra) # 80000bea <acquire>
  b->refcnt++;
    800033ea:	40bc                	lw	a5,64(s1)
    800033ec:	2785                	addiw	a5,a5,1
    800033ee:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800033f0:	00015517          	auipc	a0,0x15
    800033f4:	27850513          	addi	a0,a0,632 # 80018668 <bcache>
    800033f8:	ffffe097          	auipc	ra,0xffffe
    800033fc:	8a6080e7          	jalr	-1882(ra) # 80000c9e <release>
}
    80003400:	60e2                	ld	ra,24(sp)
    80003402:	6442                	ld	s0,16(sp)
    80003404:	64a2                	ld	s1,8(sp)
    80003406:	6105                	addi	sp,sp,32
    80003408:	8082                	ret

000000008000340a <bunpin>:

void
bunpin(struct buf *b) {
    8000340a:	1101                	addi	sp,sp,-32
    8000340c:	ec06                	sd	ra,24(sp)
    8000340e:	e822                	sd	s0,16(sp)
    80003410:	e426                	sd	s1,8(sp)
    80003412:	1000                	addi	s0,sp,32
    80003414:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003416:	00015517          	auipc	a0,0x15
    8000341a:	25250513          	addi	a0,a0,594 # 80018668 <bcache>
    8000341e:	ffffd097          	auipc	ra,0xffffd
    80003422:	7cc080e7          	jalr	1996(ra) # 80000bea <acquire>
  b->refcnt--;
    80003426:	40bc                	lw	a5,64(s1)
    80003428:	37fd                	addiw	a5,a5,-1
    8000342a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000342c:	00015517          	auipc	a0,0x15
    80003430:	23c50513          	addi	a0,a0,572 # 80018668 <bcache>
    80003434:	ffffe097          	auipc	ra,0xffffe
    80003438:	86a080e7          	jalr	-1942(ra) # 80000c9e <release>
}
    8000343c:	60e2                	ld	ra,24(sp)
    8000343e:	6442                	ld	s0,16(sp)
    80003440:	64a2                	ld	s1,8(sp)
    80003442:	6105                	addi	sp,sp,32
    80003444:	8082                	ret

0000000080003446 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003446:	1101                	addi	sp,sp,-32
    80003448:	ec06                	sd	ra,24(sp)
    8000344a:	e822                	sd	s0,16(sp)
    8000344c:	e426                	sd	s1,8(sp)
    8000344e:	e04a                	sd	s2,0(sp)
    80003450:	1000                	addi	s0,sp,32
    80003452:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003454:	00d5d59b          	srliw	a1,a1,0xd
    80003458:	0001e797          	auipc	a5,0x1e
    8000345c:	8ec7a783          	lw	a5,-1812(a5) # 80020d44 <sb+0x1c>
    80003460:	9dbd                	addw	a1,a1,a5
    80003462:	00000097          	auipc	ra,0x0
    80003466:	d9e080e7          	jalr	-610(ra) # 80003200 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000346a:	0074f713          	andi	a4,s1,7
    8000346e:	4785                	li	a5,1
    80003470:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003474:	14ce                	slli	s1,s1,0x33
    80003476:	90d9                	srli	s1,s1,0x36
    80003478:	00950733          	add	a4,a0,s1
    8000347c:	05874703          	lbu	a4,88(a4)
    80003480:	00e7f6b3          	and	a3,a5,a4
    80003484:	c69d                	beqz	a3,800034b2 <bfree+0x6c>
    80003486:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003488:	94aa                	add	s1,s1,a0
    8000348a:	fff7c793          	not	a5,a5
    8000348e:	8ff9                	and	a5,a5,a4
    80003490:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003494:	00001097          	auipc	ra,0x1
    80003498:	120080e7          	jalr	288(ra) # 800045b4 <log_write>
  brelse(bp);
    8000349c:	854a                	mv	a0,s2
    8000349e:	00000097          	auipc	ra,0x0
    800034a2:	e92080e7          	jalr	-366(ra) # 80003330 <brelse>
}
    800034a6:	60e2                	ld	ra,24(sp)
    800034a8:	6442                	ld	s0,16(sp)
    800034aa:	64a2                	ld	s1,8(sp)
    800034ac:	6902                	ld	s2,0(sp)
    800034ae:	6105                	addi	sp,sp,32
    800034b0:	8082                	ret
    panic("freeing free block");
    800034b2:	00005517          	auipc	a0,0x5
    800034b6:	1c650513          	addi	a0,a0,454 # 80008678 <syscalls+0x108>
    800034ba:	ffffd097          	auipc	ra,0xffffd
    800034be:	08a080e7          	jalr	138(ra) # 80000544 <panic>

00000000800034c2 <balloc>:
{
    800034c2:	711d                	addi	sp,sp,-96
    800034c4:	ec86                	sd	ra,88(sp)
    800034c6:	e8a2                	sd	s0,80(sp)
    800034c8:	e4a6                	sd	s1,72(sp)
    800034ca:	e0ca                	sd	s2,64(sp)
    800034cc:	fc4e                	sd	s3,56(sp)
    800034ce:	f852                	sd	s4,48(sp)
    800034d0:	f456                	sd	s5,40(sp)
    800034d2:	f05a                	sd	s6,32(sp)
    800034d4:	ec5e                	sd	s7,24(sp)
    800034d6:	e862                	sd	s8,16(sp)
    800034d8:	e466                	sd	s9,8(sp)
    800034da:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800034dc:	0001e797          	auipc	a5,0x1e
    800034e0:	8507a783          	lw	a5,-1968(a5) # 80020d2c <sb+0x4>
    800034e4:	10078163          	beqz	a5,800035e6 <balloc+0x124>
    800034e8:	8baa                	mv	s7,a0
    800034ea:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800034ec:	0001eb17          	auipc	s6,0x1e
    800034f0:	83cb0b13          	addi	s6,s6,-1988 # 80020d28 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034f4:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800034f6:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034f8:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800034fa:	6c89                	lui	s9,0x2
    800034fc:	a061                	j	80003584 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    800034fe:	974a                	add	a4,a4,s2
    80003500:	8fd5                	or	a5,a5,a3
    80003502:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003506:	854a                	mv	a0,s2
    80003508:	00001097          	auipc	ra,0x1
    8000350c:	0ac080e7          	jalr	172(ra) # 800045b4 <log_write>
        brelse(bp);
    80003510:	854a                	mv	a0,s2
    80003512:	00000097          	auipc	ra,0x0
    80003516:	e1e080e7          	jalr	-482(ra) # 80003330 <brelse>
  bp = bread(dev, bno);
    8000351a:	85a6                	mv	a1,s1
    8000351c:	855e                	mv	a0,s7
    8000351e:	00000097          	auipc	ra,0x0
    80003522:	ce2080e7          	jalr	-798(ra) # 80003200 <bread>
    80003526:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003528:	40000613          	li	a2,1024
    8000352c:	4581                	li	a1,0
    8000352e:	05850513          	addi	a0,a0,88
    80003532:	ffffd097          	auipc	ra,0xffffd
    80003536:	7b4080e7          	jalr	1972(ra) # 80000ce6 <memset>
  log_write(bp);
    8000353a:	854a                	mv	a0,s2
    8000353c:	00001097          	auipc	ra,0x1
    80003540:	078080e7          	jalr	120(ra) # 800045b4 <log_write>
  brelse(bp);
    80003544:	854a                	mv	a0,s2
    80003546:	00000097          	auipc	ra,0x0
    8000354a:	dea080e7          	jalr	-534(ra) # 80003330 <brelse>
}
    8000354e:	8526                	mv	a0,s1
    80003550:	60e6                	ld	ra,88(sp)
    80003552:	6446                	ld	s0,80(sp)
    80003554:	64a6                	ld	s1,72(sp)
    80003556:	6906                	ld	s2,64(sp)
    80003558:	79e2                	ld	s3,56(sp)
    8000355a:	7a42                	ld	s4,48(sp)
    8000355c:	7aa2                	ld	s5,40(sp)
    8000355e:	7b02                	ld	s6,32(sp)
    80003560:	6be2                	ld	s7,24(sp)
    80003562:	6c42                	ld	s8,16(sp)
    80003564:	6ca2                	ld	s9,8(sp)
    80003566:	6125                	addi	sp,sp,96
    80003568:	8082                	ret
    brelse(bp);
    8000356a:	854a                	mv	a0,s2
    8000356c:	00000097          	auipc	ra,0x0
    80003570:	dc4080e7          	jalr	-572(ra) # 80003330 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003574:	015c87bb          	addw	a5,s9,s5
    80003578:	00078a9b          	sext.w	s5,a5
    8000357c:	004b2703          	lw	a4,4(s6)
    80003580:	06eaf363          	bgeu	s5,a4,800035e6 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80003584:	41fad79b          	sraiw	a5,s5,0x1f
    80003588:	0137d79b          	srliw	a5,a5,0x13
    8000358c:	015787bb          	addw	a5,a5,s5
    80003590:	40d7d79b          	sraiw	a5,a5,0xd
    80003594:	01cb2583          	lw	a1,28(s6)
    80003598:	9dbd                	addw	a1,a1,a5
    8000359a:	855e                	mv	a0,s7
    8000359c:	00000097          	auipc	ra,0x0
    800035a0:	c64080e7          	jalr	-924(ra) # 80003200 <bread>
    800035a4:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800035a6:	004b2503          	lw	a0,4(s6)
    800035aa:	000a849b          	sext.w	s1,s5
    800035ae:	8662                	mv	a2,s8
    800035b0:	faa4fde3          	bgeu	s1,a0,8000356a <balloc+0xa8>
      m = 1 << (bi % 8);
    800035b4:	41f6579b          	sraiw	a5,a2,0x1f
    800035b8:	01d7d69b          	srliw	a3,a5,0x1d
    800035bc:	00c6873b          	addw	a4,a3,a2
    800035c0:	00777793          	andi	a5,a4,7
    800035c4:	9f95                	subw	a5,a5,a3
    800035c6:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800035ca:	4037571b          	sraiw	a4,a4,0x3
    800035ce:	00e906b3          	add	a3,s2,a4
    800035d2:	0586c683          	lbu	a3,88(a3)
    800035d6:	00d7f5b3          	and	a1,a5,a3
    800035da:	d195                	beqz	a1,800034fe <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800035dc:	2605                	addiw	a2,a2,1
    800035de:	2485                	addiw	s1,s1,1
    800035e0:	fd4618e3          	bne	a2,s4,800035b0 <balloc+0xee>
    800035e4:	b759                	j	8000356a <balloc+0xa8>
  printf("balloc: out of blocks\n");
    800035e6:	00005517          	auipc	a0,0x5
    800035ea:	0aa50513          	addi	a0,a0,170 # 80008690 <syscalls+0x120>
    800035ee:	ffffd097          	auipc	ra,0xffffd
    800035f2:	fa0080e7          	jalr	-96(ra) # 8000058e <printf>
  return 0;
    800035f6:	4481                	li	s1,0
    800035f8:	bf99                	j	8000354e <balloc+0x8c>

00000000800035fa <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800035fa:	7179                	addi	sp,sp,-48
    800035fc:	f406                	sd	ra,40(sp)
    800035fe:	f022                	sd	s0,32(sp)
    80003600:	ec26                	sd	s1,24(sp)
    80003602:	e84a                	sd	s2,16(sp)
    80003604:	e44e                	sd	s3,8(sp)
    80003606:	e052                	sd	s4,0(sp)
    80003608:	1800                	addi	s0,sp,48
    8000360a:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000360c:	47ad                	li	a5,11
    8000360e:	02b7e763          	bltu	a5,a1,8000363c <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003612:	02059493          	slli	s1,a1,0x20
    80003616:	9081                	srli	s1,s1,0x20
    80003618:	048a                	slli	s1,s1,0x2
    8000361a:	94aa                	add	s1,s1,a0
    8000361c:	0504a903          	lw	s2,80(s1)
    80003620:	06091e63          	bnez	s2,8000369c <bmap+0xa2>
      addr = balloc(ip->dev);
    80003624:	4108                	lw	a0,0(a0)
    80003626:	00000097          	auipc	ra,0x0
    8000362a:	e9c080e7          	jalr	-356(ra) # 800034c2 <balloc>
    8000362e:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003632:	06090563          	beqz	s2,8000369c <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80003636:	0524a823          	sw	s2,80(s1)
    8000363a:	a08d                	j	8000369c <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000363c:	ff45849b          	addiw	s1,a1,-12
    80003640:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003644:	0ff00793          	li	a5,255
    80003648:	08e7e563          	bltu	a5,a4,800036d2 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000364c:	08052903          	lw	s2,128(a0)
    80003650:	00091d63          	bnez	s2,8000366a <bmap+0x70>
      addr = balloc(ip->dev);
    80003654:	4108                	lw	a0,0(a0)
    80003656:	00000097          	auipc	ra,0x0
    8000365a:	e6c080e7          	jalr	-404(ra) # 800034c2 <balloc>
    8000365e:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003662:	02090d63          	beqz	s2,8000369c <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003666:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000366a:	85ca                	mv	a1,s2
    8000366c:	0009a503          	lw	a0,0(s3)
    80003670:	00000097          	auipc	ra,0x0
    80003674:	b90080e7          	jalr	-1136(ra) # 80003200 <bread>
    80003678:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000367a:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000367e:	02049593          	slli	a1,s1,0x20
    80003682:	9181                	srli	a1,a1,0x20
    80003684:	058a                	slli	a1,a1,0x2
    80003686:	00b784b3          	add	s1,a5,a1
    8000368a:	0004a903          	lw	s2,0(s1)
    8000368e:	02090063          	beqz	s2,800036ae <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003692:	8552                	mv	a0,s4
    80003694:	00000097          	auipc	ra,0x0
    80003698:	c9c080e7          	jalr	-868(ra) # 80003330 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000369c:	854a                	mv	a0,s2
    8000369e:	70a2                	ld	ra,40(sp)
    800036a0:	7402                	ld	s0,32(sp)
    800036a2:	64e2                	ld	s1,24(sp)
    800036a4:	6942                	ld	s2,16(sp)
    800036a6:	69a2                	ld	s3,8(sp)
    800036a8:	6a02                	ld	s4,0(sp)
    800036aa:	6145                	addi	sp,sp,48
    800036ac:	8082                	ret
      addr = balloc(ip->dev);
    800036ae:	0009a503          	lw	a0,0(s3)
    800036b2:	00000097          	auipc	ra,0x0
    800036b6:	e10080e7          	jalr	-496(ra) # 800034c2 <balloc>
    800036ba:	0005091b          	sext.w	s2,a0
      if(addr){
    800036be:	fc090ae3          	beqz	s2,80003692 <bmap+0x98>
        a[bn] = addr;
    800036c2:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800036c6:	8552                	mv	a0,s4
    800036c8:	00001097          	auipc	ra,0x1
    800036cc:	eec080e7          	jalr	-276(ra) # 800045b4 <log_write>
    800036d0:	b7c9                	j	80003692 <bmap+0x98>
  panic("bmap: out of range");
    800036d2:	00005517          	auipc	a0,0x5
    800036d6:	fd650513          	addi	a0,a0,-42 # 800086a8 <syscalls+0x138>
    800036da:	ffffd097          	auipc	ra,0xffffd
    800036de:	e6a080e7          	jalr	-406(ra) # 80000544 <panic>

00000000800036e2 <iget>:
{
    800036e2:	7179                	addi	sp,sp,-48
    800036e4:	f406                	sd	ra,40(sp)
    800036e6:	f022                	sd	s0,32(sp)
    800036e8:	ec26                	sd	s1,24(sp)
    800036ea:	e84a                	sd	s2,16(sp)
    800036ec:	e44e                	sd	s3,8(sp)
    800036ee:	e052                	sd	s4,0(sp)
    800036f0:	1800                	addi	s0,sp,48
    800036f2:	89aa                	mv	s3,a0
    800036f4:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800036f6:	0001d517          	auipc	a0,0x1d
    800036fa:	65250513          	addi	a0,a0,1618 # 80020d48 <itable>
    800036fe:	ffffd097          	auipc	ra,0xffffd
    80003702:	4ec080e7          	jalr	1260(ra) # 80000bea <acquire>
  empty = 0;
    80003706:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003708:	0001d497          	auipc	s1,0x1d
    8000370c:	65848493          	addi	s1,s1,1624 # 80020d60 <itable+0x18>
    80003710:	0001f697          	auipc	a3,0x1f
    80003714:	0e068693          	addi	a3,a3,224 # 800227f0 <log>
    80003718:	a039                	j	80003726 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000371a:	02090b63          	beqz	s2,80003750 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000371e:	08848493          	addi	s1,s1,136
    80003722:	02d48a63          	beq	s1,a3,80003756 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003726:	449c                	lw	a5,8(s1)
    80003728:	fef059e3          	blez	a5,8000371a <iget+0x38>
    8000372c:	4098                	lw	a4,0(s1)
    8000372e:	ff3716e3          	bne	a4,s3,8000371a <iget+0x38>
    80003732:	40d8                	lw	a4,4(s1)
    80003734:	ff4713e3          	bne	a4,s4,8000371a <iget+0x38>
      ip->ref++;
    80003738:	2785                	addiw	a5,a5,1
    8000373a:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000373c:	0001d517          	auipc	a0,0x1d
    80003740:	60c50513          	addi	a0,a0,1548 # 80020d48 <itable>
    80003744:	ffffd097          	auipc	ra,0xffffd
    80003748:	55a080e7          	jalr	1370(ra) # 80000c9e <release>
      return ip;
    8000374c:	8926                	mv	s2,s1
    8000374e:	a03d                	j	8000377c <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003750:	f7f9                	bnez	a5,8000371e <iget+0x3c>
    80003752:	8926                	mv	s2,s1
    80003754:	b7e9                	j	8000371e <iget+0x3c>
  if(empty == 0)
    80003756:	02090c63          	beqz	s2,8000378e <iget+0xac>
  ip->dev = dev;
    8000375a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000375e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003762:	4785                	li	a5,1
    80003764:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003768:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000376c:	0001d517          	auipc	a0,0x1d
    80003770:	5dc50513          	addi	a0,a0,1500 # 80020d48 <itable>
    80003774:	ffffd097          	auipc	ra,0xffffd
    80003778:	52a080e7          	jalr	1322(ra) # 80000c9e <release>
}
    8000377c:	854a                	mv	a0,s2
    8000377e:	70a2                	ld	ra,40(sp)
    80003780:	7402                	ld	s0,32(sp)
    80003782:	64e2                	ld	s1,24(sp)
    80003784:	6942                	ld	s2,16(sp)
    80003786:	69a2                	ld	s3,8(sp)
    80003788:	6a02                	ld	s4,0(sp)
    8000378a:	6145                	addi	sp,sp,48
    8000378c:	8082                	ret
    panic("iget: no inodes");
    8000378e:	00005517          	auipc	a0,0x5
    80003792:	f3250513          	addi	a0,a0,-206 # 800086c0 <syscalls+0x150>
    80003796:	ffffd097          	auipc	ra,0xffffd
    8000379a:	dae080e7          	jalr	-594(ra) # 80000544 <panic>

000000008000379e <fsinit>:
fsinit(int dev) {
    8000379e:	7179                	addi	sp,sp,-48
    800037a0:	f406                	sd	ra,40(sp)
    800037a2:	f022                	sd	s0,32(sp)
    800037a4:	ec26                	sd	s1,24(sp)
    800037a6:	e84a                	sd	s2,16(sp)
    800037a8:	e44e                	sd	s3,8(sp)
    800037aa:	1800                	addi	s0,sp,48
    800037ac:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800037ae:	4585                	li	a1,1
    800037b0:	00000097          	auipc	ra,0x0
    800037b4:	a50080e7          	jalr	-1456(ra) # 80003200 <bread>
    800037b8:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800037ba:	0001d997          	auipc	s3,0x1d
    800037be:	56e98993          	addi	s3,s3,1390 # 80020d28 <sb>
    800037c2:	02000613          	li	a2,32
    800037c6:	05850593          	addi	a1,a0,88
    800037ca:	854e                	mv	a0,s3
    800037cc:	ffffd097          	auipc	ra,0xffffd
    800037d0:	57a080e7          	jalr	1402(ra) # 80000d46 <memmove>
  brelse(bp);
    800037d4:	8526                	mv	a0,s1
    800037d6:	00000097          	auipc	ra,0x0
    800037da:	b5a080e7          	jalr	-1190(ra) # 80003330 <brelse>
  if(sb.magic != FSMAGIC)
    800037de:	0009a703          	lw	a4,0(s3)
    800037e2:	102037b7          	lui	a5,0x10203
    800037e6:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800037ea:	02f71263          	bne	a4,a5,8000380e <fsinit+0x70>
  initlog(dev, &sb);
    800037ee:	0001d597          	auipc	a1,0x1d
    800037f2:	53a58593          	addi	a1,a1,1338 # 80020d28 <sb>
    800037f6:	854a                	mv	a0,s2
    800037f8:	00001097          	auipc	ra,0x1
    800037fc:	b40080e7          	jalr	-1216(ra) # 80004338 <initlog>
}
    80003800:	70a2                	ld	ra,40(sp)
    80003802:	7402                	ld	s0,32(sp)
    80003804:	64e2                	ld	s1,24(sp)
    80003806:	6942                	ld	s2,16(sp)
    80003808:	69a2                	ld	s3,8(sp)
    8000380a:	6145                	addi	sp,sp,48
    8000380c:	8082                	ret
    panic("invalid file system");
    8000380e:	00005517          	auipc	a0,0x5
    80003812:	ec250513          	addi	a0,a0,-318 # 800086d0 <syscalls+0x160>
    80003816:	ffffd097          	auipc	ra,0xffffd
    8000381a:	d2e080e7          	jalr	-722(ra) # 80000544 <panic>

000000008000381e <iinit>:
{
    8000381e:	7179                	addi	sp,sp,-48
    80003820:	f406                	sd	ra,40(sp)
    80003822:	f022                	sd	s0,32(sp)
    80003824:	ec26                	sd	s1,24(sp)
    80003826:	e84a                	sd	s2,16(sp)
    80003828:	e44e                	sd	s3,8(sp)
    8000382a:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000382c:	00005597          	auipc	a1,0x5
    80003830:	ebc58593          	addi	a1,a1,-324 # 800086e8 <syscalls+0x178>
    80003834:	0001d517          	auipc	a0,0x1d
    80003838:	51450513          	addi	a0,a0,1300 # 80020d48 <itable>
    8000383c:	ffffd097          	auipc	ra,0xffffd
    80003840:	31e080e7          	jalr	798(ra) # 80000b5a <initlock>
  for(i = 0; i < NINODE; i++) {
    80003844:	0001d497          	auipc	s1,0x1d
    80003848:	52c48493          	addi	s1,s1,1324 # 80020d70 <itable+0x28>
    8000384c:	0001f997          	auipc	s3,0x1f
    80003850:	fb498993          	addi	s3,s3,-76 # 80022800 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003854:	00005917          	auipc	s2,0x5
    80003858:	e9c90913          	addi	s2,s2,-356 # 800086f0 <syscalls+0x180>
    8000385c:	85ca                	mv	a1,s2
    8000385e:	8526                	mv	a0,s1
    80003860:	00001097          	auipc	ra,0x1
    80003864:	e3a080e7          	jalr	-454(ra) # 8000469a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003868:	08848493          	addi	s1,s1,136
    8000386c:	ff3498e3          	bne	s1,s3,8000385c <iinit+0x3e>
}
    80003870:	70a2                	ld	ra,40(sp)
    80003872:	7402                	ld	s0,32(sp)
    80003874:	64e2                	ld	s1,24(sp)
    80003876:	6942                	ld	s2,16(sp)
    80003878:	69a2                	ld	s3,8(sp)
    8000387a:	6145                	addi	sp,sp,48
    8000387c:	8082                	ret

000000008000387e <ialloc>:
{
    8000387e:	715d                	addi	sp,sp,-80
    80003880:	e486                	sd	ra,72(sp)
    80003882:	e0a2                	sd	s0,64(sp)
    80003884:	fc26                	sd	s1,56(sp)
    80003886:	f84a                	sd	s2,48(sp)
    80003888:	f44e                	sd	s3,40(sp)
    8000388a:	f052                	sd	s4,32(sp)
    8000388c:	ec56                	sd	s5,24(sp)
    8000388e:	e85a                	sd	s6,16(sp)
    80003890:	e45e                	sd	s7,8(sp)
    80003892:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003894:	0001d717          	auipc	a4,0x1d
    80003898:	4a072703          	lw	a4,1184(a4) # 80020d34 <sb+0xc>
    8000389c:	4785                	li	a5,1
    8000389e:	04e7fa63          	bgeu	a5,a4,800038f2 <ialloc+0x74>
    800038a2:	8aaa                	mv	s5,a0
    800038a4:	8bae                	mv	s7,a1
    800038a6:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800038a8:	0001da17          	auipc	s4,0x1d
    800038ac:	480a0a13          	addi	s4,s4,1152 # 80020d28 <sb>
    800038b0:	00048b1b          	sext.w	s6,s1
    800038b4:	0044d593          	srli	a1,s1,0x4
    800038b8:	018a2783          	lw	a5,24(s4)
    800038bc:	9dbd                	addw	a1,a1,a5
    800038be:	8556                	mv	a0,s5
    800038c0:	00000097          	auipc	ra,0x0
    800038c4:	940080e7          	jalr	-1728(ra) # 80003200 <bread>
    800038c8:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800038ca:	05850993          	addi	s3,a0,88
    800038ce:	00f4f793          	andi	a5,s1,15
    800038d2:	079a                	slli	a5,a5,0x6
    800038d4:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800038d6:	00099783          	lh	a5,0(s3)
    800038da:	c3a1                	beqz	a5,8000391a <ialloc+0x9c>
    brelse(bp);
    800038dc:	00000097          	auipc	ra,0x0
    800038e0:	a54080e7          	jalr	-1452(ra) # 80003330 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800038e4:	0485                	addi	s1,s1,1
    800038e6:	00ca2703          	lw	a4,12(s4)
    800038ea:	0004879b          	sext.w	a5,s1
    800038ee:	fce7e1e3          	bltu	a5,a4,800038b0 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    800038f2:	00005517          	auipc	a0,0x5
    800038f6:	e0650513          	addi	a0,a0,-506 # 800086f8 <syscalls+0x188>
    800038fa:	ffffd097          	auipc	ra,0xffffd
    800038fe:	c94080e7          	jalr	-876(ra) # 8000058e <printf>
  return 0;
    80003902:	4501                	li	a0,0
}
    80003904:	60a6                	ld	ra,72(sp)
    80003906:	6406                	ld	s0,64(sp)
    80003908:	74e2                	ld	s1,56(sp)
    8000390a:	7942                	ld	s2,48(sp)
    8000390c:	79a2                	ld	s3,40(sp)
    8000390e:	7a02                	ld	s4,32(sp)
    80003910:	6ae2                	ld	s5,24(sp)
    80003912:	6b42                	ld	s6,16(sp)
    80003914:	6ba2                	ld	s7,8(sp)
    80003916:	6161                	addi	sp,sp,80
    80003918:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000391a:	04000613          	li	a2,64
    8000391e:	4581                	li	a1,0
    80003920:	854e                	mv	a0,s3
    80003922:	ffffd097          	auipc	ra,0xffffd
    80003926:	3c4080e7          	jalr	964(ra) # 80000ce6 <memset>
      dip->type = type;
    8000392a:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000392e:	854a                	mv	a0,s2
    80003930:	00001097          	auipc	ra,0x1
    80003934:	c84080e7          	jalr	-892(ra) # 800045b4 <log_write>
      brelse(bp);
    80003938:	854a                	mv	a0,s2
    8000393a:	00000097          	auipc	ra,0x0
    8000393e:	9f6080e7          	jalr	-1546(ra) # 80003330 <brelse>
      return iget(dev, inum);
    80003942:	85da                	mv	a1,s6
    80003944:	8556                	mv	a0,s5
    80003946:	00000097          	auipc	ra,0x0
    8000394a:	d9c080e7          	jalr	-612(ra) # 800036e2 <iget>
    8000394e:	bf5d                	j	80003904 <ialloc+0x86>

0000000080003950 <iupdate>:
{
    80003950:	1101                	addi	sp,sp,-32
    80003952:	ec06                	sd	ra,24(sp)
    80003954:	e822                	sd	s0,16(sp)
    80003956:	e426                	sd	s1,8(sp)
    80003958:	e04a                	sd	s2,0(sp)
    8000395a:	1000                	addi	s0,sp,32
    8000395c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000395e:	415c                	lw	a5,4(a0)
    80003960:	0047d79b          	srliw	a5,a5,0x4
    80003964:	0001d597          	auipc	a1,0x1d
    80003968:	3dc5a583          	lw	a1,988(a1) # 80020d40 <sb+0x18>
    8000396c:	9dbd                	addw	a1,a1,a5
    8000396e:	4108                	lw	a0,0(a0)
    80003970:	00000097          	auipc	ra,0x0
    80003974:	890080e7          	jalr	-1904(ra) # 80003200 <bread>
    80003978:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000397a:	05850793          	addi	a5,a0,88
    8000397e:	40c8                	lw	a0,4(s1)
    80003980:	893d                	andi	a0,a0,15
    80003982:	051a                	slli	a0,a0,0x6
    80003984:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003986:	04449703          	lh	a4,68(s1)
    8000398a:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    8000398e:	04649703          	lh	a4,70(s1)
    80003992:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003996:	04849703          	lh	a4,72(s1)
    8000399a:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    8000399e:	04a49703          	lh	a4,74(s1)
    800039a2:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800039a6:	44f8                	lw	a4,76(s1)
    800039a8:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800039aa:	03400613          	li	a2,52
    800039ae:	05048593          	addi	a1,s1,80
    800039b2:	0531                	addi	a0,a0,12
    800039b4:	ffffd097          	auipc	ra,0xffffd
    800039b8:	392080e7          	jalr	914(ra) # 80000d46 <memmove>
  log_write(bp);
    800039bc:	854a                	mv	a0,s2
    800039be:	00001097          	auipc	ra,0x1
    800039c2:	bf6080e7          	jalr	-1034(ra) # 800045b4 <log_write>
  brelse(bp);
    800039c6:	854a                	mv	a0,s2
    800039c8:	00000097          	auipc	ra,0x0
    800039cc:	968080e7          	jalr	-1688(ra) # 80003330 <brelse>
}
    800039d0:	60e2                	ld	ra,24(sp)
    800039d2:	6442                	ld	s0,16(sp)
    800039d4:	64a2                	ld	s1,8(sp)
    800039d6:	6902                	ld	s2,0(sp)
    800039d8:	6105                	addi	sp,sp,32
    800039da:	8082                	ret

00000000800039dc <idup>:
{
    800039dc:	1101                	addi	sp,sp,-32
    800039de:	ec06                	sd	ra,24(sp)
    800039e0:	e822                	sd	s0,16(sp)
    800039e2:	e426                	sd	s1,8(sp)
    800039e4:	1000                	addi	s0,sp,32
    800039e6:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800039e8:	0001d517          	auipc	a0,0x1d
    800039ec:	36050513          	addi	a0,a0,864 # 80020d48 <itable>
    800039f0:	ffffd097          	auipc	ra,0xffffd
    800039f4:	1fa080e7          	jalr	506(ra) # 80000bea <acquire>
  ip->ref++;
    800039f8:	449c                	lw	a5,8(s1)
    800039fa:	2785                	addiw	a5,a5,1
    800039fc:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800039fe:	0001d517          	auipc	a0,0x1d
    80003a02:	34a50513          	addi	a0,a0,842 # 80020d48 <itable>
    80003a06:	ffffd097          	auipc	ra,0xffffd
    80003a0a:	298080e7          	jalr	664(ra) # 80000c9e <release>
}
    80003a0e:	8526                	mv	a0,s1
    80003a10:	60e2                	ld	ra,24(sp)
    80003a12:	6442                	ld	s0,16(sp)
    80003a14:	64a2                	ld	s1,8(sp)
    80003a16:	6105                	addi	sp,sp,32
    80003a18:	8082                	ret

0000000080003a1a <ilock>:
{
    80003a1a:	1101                	addi	sp,sp,-32
    80003a1c:	ec06                	sd	ra,24(sp)
    80003a1e:	e822                	sd	s0,16(sp)
    80003a20:	e426                	sd	s1,8(sp)
    80003a22:	e04a                	sd	s2,0(sp)
    80003a24:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003a26:	c115                	beqz	a0,80003a4a <ilock+0x30>
    80003a28:	84aa                	mv	s1,a0
    80003a2a:	451c                	lw	a5,8(a0)
    80003a2c:	00f05f63          	blez	a5,80003a4a <ilock+0x30>
  acquiresleep(&ip->lock);
    80003a30:	0541                	addi	a0,a0,16
    80003a32:	00001097          	auipc	ra,0x1
    80003a36:	ca2080e7          	jalr	-862(ra) # 800046d4 <acquiresleep>
  if(ip->valid == 0){
    80003a3a:	40bc                	lw	a5,64(s1)
    80003a3c:	cf99                	beqz	a5,80003a5a <ilock+0x40>
}
    80003a3e:	60e2                	ld	ra,24(sp)
    80003a40:	6442                	ld	s0,16(sp)
    80003a42:	64a2                	ld	s1,8(sp)
    80003a44:	6902                	ld	s2,0(sp)
    80003a46:	6105                	addi	sp,sp,32
    80003a48:	8082                	ret
    panic("ilock");
    80003a4a:	00005517          	auipc	a0,0x5
    80003a4e:	cc650513          	addi	a0,a0,-826 # 80008710 <syscalls+0x1a0>
    80003a52:	ffffd097          	auipc	ra,0xffffd
    80003a56:	af2080e7          	jalr	-1294(ra) # 80000544 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a5a:	40dc                	lw	a5,4(s1)
    80003a5c:	0047d79b          	srliw	a5,a5,0x4
    80003a60:	0001d597          	auipc	a1,0x1d
    80003a64:	2e05a583          	lw	a1,736(a1) # 80020d40 <sb+0x18>
    80003a68:	9dbd                	addw	a1,a1,a5
    80003a6a:	4088                	lw	a0,0(s1)
    80003a6c:	fffff097          	auipc	ra,0xfffff
    80003a70:	794080e7          	jalr	1940(ra) # 80003200 <bread>
    80003a74:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003a76:	05850593          	addi	a1,a0,88
    80003a7a:	40dc                	lw	a5,4(s1)
    80003a7c:	8bbd                	andi	a5,a5,15
    80003a7e:	079a                	slli	a5,a5,0x6
    80003a80:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003a82:	00059783          	lh	a5,0(a1)
    80003a86:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003a8a:	00259783          	lh	a5,2(a1)
    80003a8e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003a92:	00459783          	lh	a5,4(a1)
    80003a96:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003a9a:	00659783          	lh	a5,6(a1)
    80003a9e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003aa2:	459c                	lw	a5,8(a1)
    80003aa4:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003aa6:	03400613          	li	a2,52
    80003aaa:	05b1                	addi	a1,a1,12
    80003aac:	05048513          	addi	a0,s1,80
    80003ab0:	ffffd097          	auipc	ra,0xffffd
    80003ab4:	296080e7          	jalr	662(ra) # 80000d46 <memmove>
    brelse(bp);
    80003ab8:	854a                	mv	a0,s2
    80003aba:	00000097          	auipc	ra,0x0
    80003abe:	876080e7          	jalr	-1930(ra) # 80003330 <brelse>
    ip->valid = 1;
    80003ac2:	4785                	li	a5,1
    80003ac4:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003ac6:	04449783          	lh	a5,68(s1)
    80003aca:	fbb5                	bnez	a5,80003a3e <ilock+0x24>
      panic("ilock: no type");
    80003acc:	00005517          	auipc	a0,0x5
    80003ad0:	c4c50513          	addi	a0,a0,-948 # 80008718 <syscalls+0x1a8>
    80003ad4:	ffffd097          	auipc	ra,0xffffd
    80003ad8:	a70080e7          	jalr	-1424(ra) # 80000544 <panic>

0000000080003adc <iunlock>:
{
    80003adc:	1101                	addi	sp,sp,-32
    80003ade:	ec06                	sd	ra,24(sp)
    80003ae0:	e822                	sd	s0,16(sp)
    80003ae2:	e426                	sd	s1,8(sp)
    80003ae4:	e04a                	sd	s2,0(sp)
    80003ae6:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003ae8:	c905                	beqz	a0,80003b18 <iunlock+0x3c>
    80003aea:	84aa                	mv	s1,a0
    80003aec:	01050913          	addi	s2,a0,16
    80003af0:	854a                	mv	a0,s2
    80003af2:	00001097          	auipc	ra,0x1
    80003af6:	c7c080e7          	jalr	-900(ra) # 8000476e <holdingsleep>
    80003afa:	cd19                	beqz	a0,80003b18 <iunlock+0x3c>
    80003afc:	449c                	lw	a5,8(s1)
    80003afe:	00f05d63          	blez	a5,80003b18 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003b02:	854a                	mv	a0,s2
    80003b04:	00001097          	auipc	ra,0x1
    80003b08:	c26080e7          	jalr	-986(ra) # 8000472a <releasesleep>
}
    80003b0c:	60e2                	ld	ra,24(sp)
    80003b0e:	6442                	ld	s0,16(sp)
    80003b10:	64a2                	ld	s1,8(sp)
    80003b12:	6902                	ld	s2,0(sp)
    80003b14:	6105                	addi	sp,sp,32
    80003b16:	8082                	ret
    panic("iunlock");
    80003b18:	00005517          	auipc	a0,0x5
    80003b1c:	c1050513          	addi	a0,a0,-1008 # 80008728 <syscalls+0x1b8>
    80003b20:	ffffd097          	auipc	ra,0xffffd
    80003b24:	a24080e7          	jalr	-1500(ra) # 80000544 <panic>

0000000080003b28 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003b28:	7179                	addi	sp,sp,-48
    80003b2a:	f406                	sd	ra,40(sp)
    80003b2c:	f022                	sd	s0,32(sp)
    80003b2e:	ec26                	sd	s1,24(sp)
    80003b30:	e84a                	sd	s2,16(sp)
    80003b32:	e44e                	sd	s3,8(sp)
    80003b34:	e052                	sd	s4,0(sp)
    80003b36:	1800                	addi	s0,sp,48
    80003b38:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003b3a:	05050493          	addi	s1,a0,80
    80003b3e:	08050913          	addi	s2,a0,128
    80003b42:	a021                	j	80003b4a <itrunc+0x22>
    80003b44:	0491                	addi	s1,s1,4
    80003b46:	01248d63          	beq	s1,s2,80003b60 <itrunc+0x38>
    if(ip->addrs[i]){
    80003b4a:	408c                	lw	a1,0(s1)
    80003b4c:	dde5                	beqz	a1,80003b44 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003b4e:	0009a503          	lw	a0,0(s3)
    80003b52:	00000097          	auipc	ra,0x0
    80003b56:	8f4080e7          	jalr	-1804(ra) # 80003446 <bfree>
      ip->addrs[i] = 0;
    80003b5a:	0004a023          	sw	zero,0(s1)
    80003b5e:	b7dd                	j	80003b44 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003b60:	0809a583          	lw	a1,128(s3)
    80003b64:	e185                	bnez	a1,80003b84 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003b66:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003b6a:	854e                	mv	a0,s3
    80003b6c:	00000097          	auipc	ra,0x0
    80003b70:	de4080e7          	jalr	-540(ra) # 80003950 <iupdate>
}
    80003b74:	70a2                	ld	ra,40(sp)
    80003b76:	7402                	ld	s0,32(sp)
    80003b78:	64e2                	ld	s1,24(sp)
    80003b7a:	6942                	ld	s2,16(sp)
    80003b7c:	69a2                	ld	s3,8(sp)
    80003b7e:	6a02                	ld	s4,0(sp)
    80003b80:	6145                	addi	sp,sp,48
    80003b82:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003b84:	0009a503          	lw	a0,0(s3)
    80003b88:	fffff097          	auipc	ra,0xfffff
    80003b8c:	678080e7          	jalr	1656(ra) # 80003200 <bread>
    80003b90:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003b92:	05850493          	addi	s1,a0,88
    80003b96:	45850913          	addi	s2,a0,1112
    80003b9a:	a811                	j	80003bae <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003b9c:	0009a503          	lw	a0,0(s3)
    80003ba0:	00000097          	auipc	ra,0x0
    80003ba4:	8a6080e7          	jalr	-1882(ra) # 80003446 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003ba8:	0491                	addi	s1,s1,4
    80003baa:	01248563          	beq	s1,s2,80003bb4 <itrunc+0x8c>
      if(a[j])
    80003bae:	408c                	lw	a1,0(s1)
    80003bb0:	dde5                	beqz	a1,80003ba8 <itrunc+0x80>
    80003bb2:	b7ed                	j	80003b9c <itrunc+0x74>
    brelse(bp);
    80003bb4:	8552                	mv	a0,s4
    80003bb6:	fffff097          	auipc	ra,0xfffff
    80003bba:	77a080e7          	jalr	1914(ra) # 80003330 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003bbe:	0809a583          	lw	a1,128(s3)
    80003bc2:	0009a503          	lw	a0,0(s3)
    80003bc6:	00000097          	auipc	ra,0x0
    80003bca:	880080e7          	jalr	-1920(ra) # 80003446 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003bce:	0809a023          	sw	zero,128(s3)
    80003bd2:	bf51                	j	80003b66 <itrunc+0x3e>

0000000080003bd4 <iput>:
{
    80003bd4:	1101                	addi	sp,sp,-32
    80003bd6:	ec06                	sd	ra,24(sp)
    80003bd8:	e822                	sd	s0,16(sp)
    80003bda:	e426                	sd	s1,8(sp)
    80003bdc:	e04a                	sd	s2,0(sp)
    80003bde:	1000                	addi	s0,sp,32
    80003be0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003be2:	0001d517          	auipc	a0,0x1d
    80003be6:	16650513          	addi	a0,a0,358 # 80020d48 <itable>
    80003bea:	ffffd097          	auipc	ra,0xffffd
    80003bee:	000080e7          	jalr	ra # 80000bea <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003bf2:	4498                	lw	a4,8(s1)
    80003bf4:	4785                	li	a5,1
    80003bf6:	02f70363          	beq	a4,a5,80003c1c <iput+0x48>
  ip->ref--;
    80003bfa:	449c                	lw	a5,8(s1)
    80003bfc:	37fd                	addiw	a5,a5,-1
    80003bfe:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003c00:	0001d517          	auipc	a0,0x1d
    80003c04:	14850513          	addi	a0,a0,328 # 80020d48 <itable>
    80003c08:	ffffd097          	auipc	ra,0xffffd
    80003c0c:	096080e7          	jalr	150(ra) # 80000c9e <release>
}
    80003c10:	60e2                	ld	ra,24(sp)
    80003c12:	6442                	ld	s0,16(sp)
    80003c14:	64a2                	ld	s1,8(sp)
    80003c16:	6902                	ld	s2,0(sp)
    80003c18:	6105                	addi	sp,sp,32
    80003c1a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003c1c:	40bc                	lw	a5,64(s1)
    80003c1e:	dff1                	beqz	a5,80003bfa <iput+0x26>
    80003c20:	04a49783          	lh	a5,74(s1)
    80003c24:	fbf9                	bnez	a5,80003bfa <iput+0x26>
    acquiresleep(&ip->lock);
    80003c26:	01048913          	addi	s2,s1,16
    80003c2a:	854a                	mv	a0,s2
    80003c2c:	00001097          	auipc	ra,0x1
    80003c30:	aa8080e7          	jalr	-1368(ra) # 800046d4 <acquiresleep>
    release(&itable.lock);
    80003c34:	0001d517          	auipc	a0,0x1d
    80003c38:	11450513          	addi	a0,a0,276 # 80020d48 <itable>
    80003c3c:	ffffd097          	auipc	ra,0xffffd
    80003c40:	062080e7          	jalr	98(ra) # 80000c9e <release>
    itrunc(ip);
    80003c44:	8526                	mv	a0,s1
    80003c46:	00000097          	auipc	ra,0x0
    80003c4a:	ee2080e7          	jalr	-286(ra) # 80003b28 <itrunc>
    ip->type = 0;
    80003c4e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003c52:	8526                	mv	a0,s1
    80003c54:	00000097          	auipc	ra,0x0
    80003c58:	cfc080e7          	jalr	-772(ra) # 80003950 <iupdate>
    ip->valid = 0;
    80003c5c:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003c60:	854a                	mv	a0,s2
    80003c62:	00001097          	auipc	ra,0x1
    80003c66:	ac8080e7          	jalr	-1336(ra) # 8000472a <releasesleep>
    acquire(&itable.lock);
    80003c6a:	0001d517          	auipc	a0,0x1d
    80003c6e:	0de50513          	addi	a0,a0,222 # 80020d48 <itable>
    80003c72:	ffffd097          	auipc	ra,0xffffd
    80003c76:	f78080e7          	jalr	-136(ra) # 80000bea <acquire>
    80003c7a:	b741                	j	80003bfa <iput+0x26>

0000000080003c7c <iunlockput>:
{
    80003c7c:	1101                	addi	sp,sp,-32
    80003c7e:	ec06                	sd	ra,24(sp)
    80003c80:	e822                	sd	s0,16(sp)
    80003c82:	e426                	sd	s1,8(sp)
    80003c84:	1000                	addi	s0,sp,32
    80003c86:	84aa                	mv	s1,a0
  iunlock(ip);
    80003c88:	00000097          	auipc	ra,0x0
    80003c8c:	e54080e7          	jalr	-428(ra) # 80003adc <iunlock>
  iput(ip);
    80003c90:	8526                	mv	a0,s1
    80003c92:	00000097          	auipc	ra,0x0
    80003c96:	f42080e7          	jalr	-190(ra) # 80003bd4 <iput>
}
    80003c9a:	60e2                	ld	ra,24(sp)
    80003c9c:	6442                	ld	s0,16(sp)
    80003c9e:	64a2                	ld	s1,8(sp)
    80003ca0:	6105                	addi	sp,sp,32
    80003ca2:	8082                	ret

0000000080003ca4 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003ca4:	1141                	addi	sp,sp,-16
    80003ca6:	e422                	sd	s0,8(sp)
    80003ca8:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003caa:	411c                	lw	a5,0(a0)
    80003cac:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003cae:	415c                	lw	a5,4(a0)
    80003cb0:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003cb2:	04451783          	lh	a5,68(a0)
    80003cb6:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003cba:	04a51783          	lh	a5,74(a0)
    80003cbe:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003cc2:	04c56783          	lwu	a5,76(a0)
    80003cc6:	e99c                	sd	a5,16(a1)
}
    80003cc8:	6422                	ld	s0,8(sp)
    80003cca:	0141                	addi	sp,sp,16
    80003ccc:	8082                	ret

0000000080003cce <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003cce:	457c                	lw	a5,76(a0)
    80003cd0:	0ed7e963          	bltu	a5,a3,80003dc2 <readi+0xf4>
{
    80003cd4:	7159                	addi	sp,sp,-112
    80003cd6:	f486                	sd	ra,104(sp)
    80003cd8:	f0a2                	sd	s0,96(sp)
    80003cda:	eca6                	sd	s1,88(sp)
    80003cdc:	e8ca                	sd	s2,80(sp)
    80003cde:	e4ce                	sd	s3,72(sp)
    80003ce0:	e0d2                	sd	s4,64(sp)
    80003ce2:	fc56                	sd	s5,56(sp)
    80003ce4:	f85a                	sd	s6,48(sp)
    80003ce6:	f45e                	sd	s7,40(sp)
    80003ce8:	f062                	sd	s8,32(sp)
    80003cea:	ec66                	sd	s9,24(sp)
    80003cec:	e86a                	sd	s10,16(sp)
    80003cee:	e46e                	sd	s11,8(sp)
    80003cf0:	1880                	addi	s0,sp,112
    80003cf2:	8b2a                	mv	s6,a0
    80003cf4:	8bae                	mv	s7,a1
    80003cf6:	8a32                	mv	s4,a2
    80003cf8:	84b6                	mv	s1,a3
    80003cfa:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003cfc:	9f35                	addw	a4,a4,a3
    return 0;
    80003cfe:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003d00:	0ad76063          	bltu	a4,a3,80003da0 <readi+0xd2>
  if(off + n > ip->size)
    80003d04:	00e7f463          	bgeu	a5,a4,80003d0c <readi+0x3e>
    n = ip->size - off;
    80003d08:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d0c:	0a0a8963          	beqz	s5,80003dbe <readi+0xf0>
    80003d10:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d12:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003d16:	5c7d                	li	s8,-1
    80003d18:	a82d                	j	80003d52 <readi+0x84>
    80003d1a:	020d1d93          	slli	s11,s10,0x20
    80003d1e:	020ddd93          	srli	s11,s11,0x20
    80003d22:	05890613          	addi	a2,s2,88
    80003d26:	86ee                	mv	a3,s11
    80003d28:	963a                	add	a2,a2,a4
    80003d2a:	85d2                	mv	a1,s4
    80003d2c:	855e                	mv	a0,s7
    80003d2e:	fffff097          	auipc	ra,0xfffff
    80003d32:	8f4080e7          	jalr	-1804(ra) # 80002622 <either_copyout>
    80003d36:	05850d63          	beq	a0,s8,80003d90 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003d3a:	854a                	mv	a0,s2
    80003d3c:	fffff097          	auipc	ra,0xfffff
    80003d40:	5f4080e7          	jalr	1524(ra) # 80003330 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d44:	013d09bb          	addw	s3,s10,s3
    80003d48:	009d04bb          	addw	s1,s10,s1
    80003d4c:	9a6e                	add	s4,s4,s11
    80003d4e:	0559f763          	bgeu	s3,s5,80003d9c <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003d52:	00a4d59b          	srliw	a1,s1,0xa
    80003d56:	855a                	mv	a0,s6
    80003d58:	00000097          	auipc	ra,0x0
    80003d5c:	8a2080e7          	jalr	-1886(ra) # 800035fa <bmap>
    80003d60:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003d64:	cd85                	beqz	a1,80003d9c <readi+0xce>
    bp = bread(ip->dev, addr);
    80003d66:	000b2503          	lw	a0,0(s6)
    80003d6a:	fffff097          	auipc	ra,0xfffff
    80003d6e:	496080e7          	jalr	1174(ra) # 80003200 <bread>
    80003d72:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d74:	3ff4f713          	andi	a4,s1,1023
    80003d78:	40ec87bb          	subw	a5,s9,a4
    80003d7c:	413a86bb          	subw	a3,s5,s3
    80003d80:	8d3e                	mv	s10,a5
    80003d82:	2781                	sext.w	a5,a5
    80003d84:	0006861b          	sext.w	a2,a3
    80003d88:	f8f679e3          	bgeu	a2,a5,80003d1a <readi+0x4c>
    80003d8c:	8d36                	mv	s10,a3
    80003d8e:	b771                	j	80003d1a <readi+0x4c>
      brelse(bp);
    80003d90:	854a                	mv	a0,s2
    80003d92:	fffff097          	auipc	ra,0xfffff
    80003d96:	59e080e7          	jalr	1438(ra) # 80003330 <brelse>
      tot = -1;
    80003d9a:	59fd                	li	s3,-1
  }
  return tot;
    80003d9c:	0009851b          	sext.w	a0,s3
}
    80003da0:	70a6                	ld	ra,104(sp)
    80003da2:	7406                	ld	s0,96(sp)
    80003da4:	64e6                	ld	s1,88(sp)
    80003da6:	6946                	ld	s2,80(sp)
    80003da8:	69a6                	ld	s3,72(sp)
    80003daa:	6a06                	ld	s4,64(sp)
    80003dac:	7ae2                	ld	s5,56(sp)
    80003dae:	7b42                	ld	s6,48(sp)
    80003db0:	7ba2                	ld	s7,40(sp)
    80003db2:	7c02                	ld	s8,32(sp)
    80003db4:	6ce2                	ld	s9,24(sp)
    80003db6:	6d42                	ld	s10,16(sp)
    80003db8:	6da2                	ld	s11,8(sp)
    80003dba:	6165                	addi	sp,sp,112
    80003dbc:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003dbe:	89d6                	mv	s3,s5
    80003dc0:	bff1                	j	80003d9c <readi+0xce>
    return 0;
    80003dc2:	4501                	li	a0,0
}
    80003dc4:	8082                	ret

0000000080003dc6 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003dc6:	457c                	lw	a5,76(a0)
    80003dc8:	10d7e863          	bltu	a5,a3,80003ed8 <writei+0x112>
{
    80003dcc:	7159                	addi	sp,sp,-112
    80003dce:	f486                	sd	ra,104(sp)
    80003dd0:	f0a2                	sd	s0,96(sp)
    80003dd2:	eca6                	sd	s1,88(sp)
    80003dd4:	e8ca                	sd	s2,80(sp)
    80003dd6:	e4ce                	sd	s3,72(sp)
    80003dd8:	e0d2                	sd	s4,64(sp)
    80003dda:	fc56                	sd	s5,56(sp)
    80003ddc:	f85a                	sd	s6,48(sp)
    80003dde:	f45e                	sd	s7,40(sp)
    80003de0:	f062                	sd	s8,32(sp)
    80003de2:	ec66                	sd	s9,24(sp)
    80003de4:	e86a                	sd	s10,16(sp)
    80003de6:	e46e                	sd	s11,8(sp)
    80003de8:	1880                	addi	s0,sp,112
    80003dea:	8aaa                	mv	s5,a0
    80003dec:	8bae                	mv	s7,a1
    80003dee:	8a32                	mv	s4,a2
    80003df0:	8936                	mv	s2,a3
    80003df2:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003df4:	00e687bb          	addw	a5,a3,a4
    80003df8:	0ed7e263          	bltu	a5,a3,80003edc <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003dfc:	00043737          	lui	a4,0x43
    80003e00:	0ef76063          	bltu	a4,a5,80003ee0 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e04:	0c0b0863          	beqz	s6,80003ed4 <writei+0x10e>
    80003e08:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e0a:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003e0e:	5c7d                	li	s8,-1
    80003e10:	a091                	j	80003e54 <writei+0x8e>
    80003e12:	020d1d93          	slli	s11,s10,0x20
    80003e16:	020ddd93          	srli	s11,s11,0x20
    80003e1a:	05848513          	addi	a0,s1,88
    80003e1e:	86ee                	mv	a3,s11
    80003e20:	8652                	mv	a2,s4
    80003e22:	85de                	mv	a1,s7
    80003e24:	953a                	add	a0,a0,a4
    80003e26:	fffff097          	auipc	ra,0xfffff
    80003e2a:	852080e7          	jalr	-1966(ra) # 80002678 <either_copyin>
    80003e2e:	07850263          	beq	a0,s8,80003e92 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003e32:	8526                	mv	a0,s1
    80003e34:	00000097          	auipc	ra,0x0
    80003e38:	780080e7          	jalr	1920(ra) # 800045b4 <log_write>
    brelse(bp);
    80003e3c:	8526                	mv	a0,s1
    80003e3e:	fffff097          	auipc	ra,0xfffff
    80003e42:	4f2080e7          	jalr	1266(ra) # 80003330 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e46:	013d09bb          	addw	s3,s10,s3
    80003e4a:	012d093b          	addw	s2,s10,s2
    80003e4e:	9a6e                	add	s4,s4,s11
    80003e50:	0569f663          	bgeu	s3,s6,80003e9c <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003e54:	00a9559b          	srliw	a1,s2,0xa
    80003e58:	8556                	mv	a0,s5
    80003e5a:	fffff097          	auipc	ra,0xfffff
    80003e5e:	7a0080e7          	jalr	1952(ra) # 800035fa <bmap>
    80003e62:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003e66:	c99d                	beqz	a1,80003e9c <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003e68:	000aa503          	lw	a0,0(s5)
    80003e6c:	fffff097          	auipc	ra,0xfffff
    80003e70:	394080e7          	jalr	916(ra) # 80003200 <bread>
    80003e74:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e76:	3ff97713          	andi	a4,s2,1023
    80003e7a:	40ec87bb          	subw	a5,s9,a4
    80003e7e:	413b06bb          	subw	a3,s6,s3
    80003e82:	8d3e                	mv	s10,a5
    80003e84:	2781                	sext.w	a5,a5
    80003e86:	0006861b          	sext.w	a2,a3
    80003e8a:	f8f674e3          	bgeu	a2,a5,80003e12 <writei+0x4c>
    80003e8e:	8d36                	mv	s10,a3
    80003e90:	b749                	j	80003e12 <writei+0x4c>
      brelse(bp);
    80003e92:	8526                	mv	a0,s1
    80003e94:	fffff097          	auipc	ra,0xfffff
    80003e98:	49c080e7          	jalr	1180(ra) # 80003330 <brelse>
  }

  if(off > ip->size)
    80003e9c:	04caa783          	lw	a5,76(s5)
    80003ea0:	0127f463          	bgeu	a5,s2,80003ea8 <writei+0xe2>
    ip->size = off;
    80003ea4:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003ea8:	8556                	mv	a0,s5
    80003eaa:	00000097          	auipc	ra,0x0
    80003eae:	aa6080e7          	jalr	-1370(ra) # 80003950 <iupdate>

  return tot;
    80003eb2:	0009851b          	sext.w	a0,s3
}
    80003eb6:	70a6                	ld	ra,104(sp)
    80003eb8:	7406                	ld	s0,96(sp)
    80003eba:	64e6                	ld	s1,88(sp)
    80003ebc:	6946                	ld	s2,80(sp)
    80003ebe:	69a6                	ld	s3,72(sp)
    80003ec0:	6a06                	ld	s4,64(sp)
    80003ec2:	7ae2                	ld	s5,56(sp)
    80003ec4:	7b42                	ld	s6,48(sp)
    80003ec6:	7ba2                	ld	s7,40(sp)
    80003ec8:	7c02                	ld	s8,32(sp)
    80003eca:	6ce2                	ld	s9,24(sp)
    80003ecc:	6d42                	ld	s10,16(sp)
    80003ece:	6da2                	ld	s11,8(sp)
    80003ed0:	6165                	addi	sp,sp,112
    80003ed2:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ed4:	89da                	mv	s3,s6
    80003ed6:	bfc9                	j	80003ea8 <writei+0xe2>
    return -1;
    80003ed8:	557d                	li	a0,-1
}
    80003eda:	8082                	ret
    return -1;
    80003edc:	557d                	li	a0,-1
    80003ede:	bfe1                	j	80003eb6 <writei+0xf0>
    return -1;
    80003ee0:	557d                	li	a0,-1
    80003ee2:	bfd1                	j	80003eb6 <writei+0xf0>

0000000080003ee4 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003ee4:	1141                	addi	sp,sp,-16
    80003ee6:	e406                	sd	ra,8(sp)
    80003ee8:	e022                	sd	s0,0(sp)
    80003eea:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003eec:	4639                	li	a2,14
    80003eee:	ffffd097          	auipc	ra,0xffffd
    80003ef2:	ed0080e7          	jalr	-304(ra) # 80000dbe <strncmp>
}
    80003ef6:	60a2                	ld	ra,8(sp)
    80003ef8:	6402                	ld	s0,0(sp)
    80003efa:	0141                	addi	sp,sp,16
    80003efc:	8082                	ret

0000000080003efe <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003efe:	7139                	addi	sp,sp,-64
    80003f00:	fc06                	sd	ra,56(sp)
    80003f02:	f822                	sd	s0,48(sp)
    80003f04:	f426                	sd	s1,40(sp)
    80003f06:	f04a                	sd	s2,32(sp)
    80003f08:	ec4e                	sd	s3,24(sp)
    80003f0a:	e852                	sd	s4,16(sp)
    80003f0c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003f0e:	04451703          	lh	a4,68(a0)
    80003f12:	4785                	li	a5,1
    80003f14:	00f71a63          	bne	a4,a5,80003f28 <dirlookup+0x2a>
    80003f18:	892a                	mv	s2,a0
    80003f1a:	89ae                	mv	s3,a1
    80003f1c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f1e:	457c                	lw	a5,76(a0)
    80003f20:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003f22:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f24:	e79d                	bnez	a5,80003f52 <dirlookup+0x54>
    80003f26:	a8a5                	j	80003f9e <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003f28:	00005517          	auipc	a0,0x5
    80003f2c:	80850513          	addi	a0,a0,-2040 # 80008730 <syscalls+0x1c0>
    80003f30:	ffffc097          	auipc	ra,0xffffc
    80003f34:	614080e7          	jalr	1556(ra) # 80000544 <panic>
      panic("dirlookup read");
    80003f38:	00005517          	auipc	a0,0x5
    80003f3c:	81050513          	addi	a0,a0,-2032 # 80008748 <syscalls+0x1d8>
    80003f40:	ffffc097          	auipc	ra,0xffffc
    80003f44:	604080e7          	jalr	1540(ra) # 80000544 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f48:	24c1                	addiw	s1,s1,16
    80003f4a:	04c92783          	lw	a5,76(s2)
    80003f4e:	04f4f763          	bgeu	s1,a5,80003f9c <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f52:	4741                	li	a4,16
    80003f54:	86a6                	mv	a3,s1
    80003f56:	fc040613          	addi	a2,s0,-64
    80003f5a:	4581                	li	a1,0
    80003f5c:	854a                	mv	a0,s2
    80003f5e:	00000097          	auipc	ra,0x0
    80003f62:	d70080e7          	jalr	-656(ra) # 80003cce <readi>
    80003f66:	47c1                	li	a5,16
    80003f68:	fcf518e3          	bne	a0,a5,80003f38 <dirlookup+0x3a>
    if(de.inum == 0)
    80003f6c:	fc045783          	lhu	a5,-64(s0)
    80003f70:	dfe1                	beqz	a5,80003f48 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003f72:	fc240593          	addi	a1,s0,-62
    80003f76:	854e                	mv	a0,s3
    80003f78:	00000097          	auipc	ra,0x0
    80003f7c:	f6c080e7          	jalr	-148(ra) # 80003ee4 <namecmp>
    80003f80:	f561                	bnez	a0,80003f48 <dirlookup+0x4a>
      if(poff)
    80003f82:	000a0463          	beqz	s4,80003f8a <dirlookup+0x8c>
        *poff = off;
    80003f86:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003f8a:	fc045583          	lhu	a1,-64(s0)
    80003f8e:	00092503          	lw	a0,0(s2)
    80003f92:	fffff097          	auipc	ra,0xfffff
    80003f96:	750080e7          	jalr	1872(ra) # 800036e2 <iget>
    80003f9a:	a011                	j	80003f9e <dirlookup+0xa0>
  return 0;
    80003f9c:	4501                	li	a0,0
}
    80003f9e:	70e2                	ld	ra,56(sp)
    80003fa0:	7442                	ld	s0,48(sp)
    80003fa2:	74a2                	ld	s1,40(sp)
    80003fa4:	7902                	ld	s2,32(sp)
    80003fa6:	69e2                	ld	s3,24(sp)
    80003fa8:	6a42                	ld	s4,16(sp)
    80003faa:	6121                	addi	sp,sp,64
    80003fac:	8082                	ret

0000000080003fae <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003fae:	711d                	addi	sp,sp,-96
    80003fb0:	ec86                	sd	ra,88(sp)
    80003fb2:	e8a2                	sd	s0,80(sp)
    80003fb4:	e4a6                	sd	s1,72(sp)
    80003fb6:	e0ca                	sd	s2,64(sp)
    80003fb8:	fc4e                	sd	s3,56(sp)
    80003fba:	f852                	sd	s4,48(sp)
    80003fbc:	f456                	sd	s5,40(sp)
    80003fbe:	f05a                	sd	s6,32(sp)
    80003fc0:	ec5e                	sd	s7,24(sp)
    80003fc2:	e862                	sd	s8,16(sp)
    80003fc4:	e466                	sd	s9,8(sp)
    80003fc6:	1080                	addi	s0,sp,96
    80003fc8:	84aa                	mv	s1,a0
    80003fca:	8b2e                	mv	s6,a1
    80003fcc:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003fce:	00054703          	lbu	a4,0(a0)
    80003fd2:	02f00793          	li	a5,47
    80003fd6:	02f70363          	beq	a4,a5,80003ffc <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003fda:	ffffe097          	auipc	ra,0xffffe
    80003fde:	af6080e7          	jalr	-1290(ra) # 80001ad0 <myproc>
    80003fe2:	15853503          	ld	a0,344(a0)
    80003fe6:	00000097          	auipc	ra,0x0
    80003fea:	9f6080e7          	jalr	-1546(ra) # 800039dc <idup>
    80003fee:	89aa                	mv	s3,a0
  while(*path == '/')
    80003ff0:	02f00913          	li	s2,47
  len = path - s;
    80003ff4:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003ff6:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003ff8:	4c05                	li	s8,1
    80003ffa:	a865                	j	800040b2 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003ffc:	4585                	li	a1,1
    80003ffe:	4505                	li	a0,1
    80004000:	fffff097          	auipc	ra,0xfffff
    80004004:	6e2080e7          	jalr	1762(ra) # 800036e2 <iget>
    80004008:	89aa                	mv	s3,a0
    8000400a:	b7dd                	j	80003ff0 <namex+0x42>
      iunlockput(ip);
    8000400c:	854e                	mv	a0,s3
    8000400e:	00000097          	auipc	ra,0x0
    80004012:	c6e080e7          	jalr	-914(ra) # 80003c7c <iunlockput>
      return 0;
    80004016:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004018:	854e                	mv	a0,s3
    8000401a:	60e6                	ld	ra,88(sp)
    8000401c:	6446                	ld	s0,80(sp)
    8000401e:	64a6                	ld	s1,72(sp)
    80004020:	6906                	ld	s2,64(sp)
    80004022:	79e2                	ld	s3,56(sp)
    80004024:	7a42                	ld	s4,48(sp)
    80004026:	7aa2                	ld	s5,40(sp)
    80004028:	7b02                	ld	s6,32(sp)
    8000402a:	6be2                	ld	s7,24(sp)
    8000402c:	6c42                	ld	s8,16(sp)
    8000402e:	6ca2                	ld	s9,8(sp)
    80004030:	6125                	addi	sp,sp,96
    80004032:	8082                	ret
      iunlock(ip);
    80004034:	854e                	mv	a0,s3
    80004036:	00000097          	auipc	ra,0x0
    8000403a:	aa6080e7          	jalr	-1370(ra) # 80003adc <iunlock>
      return ip;
    8000403e:	bfe9                	j	80004018 <namex+0x6a>
      iunlockput(ip);
    80004040:	854e                	mv	a0,s3
    80004042:	00000097          	auipc	ra,0x0
    80004046:	c3a080e7          	jalr	-966(ra) # 80003c7c <iunlockput>
      return 0;
    8000404a:	89d2                	mv	s3,s4
    8000404c:	b7f1                	j	80004018 <namex+0x6a>
  len = path - s;
    8000404e:	40b48633          	sub	a2,s1,a1
    80004052:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80004056:	094cd463          	bge	s9,s4,800040de <namex+0x130>
    memmove(name, s, DIRSIZ);
    8000405a:	4639                	li	a2,14
    8000405c:	8556                	mv	a0,s5
    8000405e:	ffffd097          	auipc	ra,0xffffd
    80004062:	ce8080e7          	jalr	-792(ra) # 80000d46 <memmove>
  while(*path == '/')
    80004066:	0004c783          	lbu	a5,0(s1)
    8000406a:	01279763          	bne	a5,s2,80004078 <namex+0xca>
    path++;
    8000406e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004070:	0004c783          	lbu	a5,0(s1)
    80004074:	ff278de3          	beq	a5,s2,8000406e <namex+0xc0>
    ilock(ip);
    80004078:	854e                	mv	a0,s3
    8000407a:	00000097          	auipc	ra,0x0
    8000407e:	9a0080e7          	jalr	-1632(ra) # 80003a1a <ilock>
    if(ip->type != T_DIR){
    80004082:	04499783          	lh	a5,68(s3)
    80004086:	f98793e3          	bne	a5,s8,8000400c <namex+0x5e>
    if(nameiparent && *path == '\0'){
    8000408a:	000b0563          	beqz	s6,80004094 <namex+0xe6>
    8000408e:	0004c783          	lbu	a5,0(s1)
    80004092:	d3cd                	beqz	a5,80004034 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004094:	865e                	mv	a2,s7
    80004096:	85d6                	mv	a1,s5
    80004098:	854e                	mv	a0,s3
    8000409a:	00000097          	auipc	ra,0x0
    8000409e:	e64080e7          	jalr	-412(ra) # 80003efe <dirlookup>
    800040a2:	8a2a                	mv	s4,a0
    800040a4:	dd51                	beqz	a0,80004040 <namex+0x92>
    iunlockput(ip);
    800040a6:	854e                	mv	a0,s3
    800040a8:	00000097          	auipc	ra,0x0
    800040ac:	bd4080e7          	jalr	-1068(ra) # 80003c7c <iunlockput>
    ip = next;
    800040b0:	89d2                	mv	s3,s4
  while(*path == '/')
    800040b2:	0004c783          	lbu	a5,0(s1)
    800040b6:	05279763          	bne	a5,s2,80004104 <namex+0x156>
    path++;
    800040ba:	0485                	addi	s1,s1,1
  while(*path == '/')
    800040bc:	0004c783          	lbu	a5,0(s1)
    800040c0:	ff278de3          	beq	a5,s2,800040ba <namex+0x10c>
  if(*path == 0)
    800040c4:	c79d                	beqz	a5,800040f2 <namex+0x144>
    path++;
    800040c6:	85a6                	mv	a1,s1
  len = path - s;
    800040c8:	8a5e                	mv	s4,s7
    800040ca:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    800040cc:	01278963          	beq	a5,s2,800040de <namex+0x130>
    800040d0:	dfbd                	beqz	a5,8000404e <namex+0xa0>
    path++;
    800040d2:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800040d4:	0004c783          	lbu	a5,0(s1)
    800040d8:	ff279ce3          	bne	a5,s2,800040d0 <namex+0x122>
    800040dc:	bf8d                	j	8000404e <namex+0xa0>
    memmove(name, s, len);
    800040de:	2601                	sext.w	a2,a2
    800040e0:	8556                	mv	a0,s5
    800040e2:	ffffd097          	auipc	ra,0xffffd
    800040e6:	c64080e7          	jalr	-924(ra) # 80000d46 <memmove>
    name[len] = 0;
    800040ea:	9a56                	add	s4,s4,s5
    800040ec:	000a0023          	sb	zero,0(s4)
    800040f0:	bf9d                	j	80004066 <namex+0xb8>
  if(nameiparent){
    800040f2:	f20b03e3          	beqz	s6,80004018 <namex+0x6a>
    iput(ip);
    800040f6:	854e                	mv	a0,s3
    800040f8:	00000097          	auipc	ra,0x0
    800040fc:	adc080e7          	jalr	-1316(ra) # 80003bd4 <iput>
    return 0;
    80004100:	4981                	li	s3,0
    80004102:	bf19                	j	80004018 <namex+0x6a>
  if(*path == 0)
    80004104:	d7fd                	beqz	a5,800040f2 <namex+0x144>
  while(*path != '/' && *path != 0)
    80004106:	0004c783          	lbu	a5,0(s1)
    8000410a:	85a6                	mv	a1,s1
    8000410c:	b7d1                	j	800040d0 <namex+0x122>

000000008000410e <dirlink>:
{
    8000410e:	7139                	addi	sp,sp,-64
    80004110:	fc06                	sd	ra,56(sp)
    80004112:	f822                	sd	s0,48(sp)
    80004114:	f426                	sd	s1,40(sp)
    80004116:	f04a                	sd	s2,32(sp)
    80004118:	ec4e                	sd	s3,24(sp)
    8000411a:	e852                	sd	s4,16(sp)
    8000411c:	0080                	addi	s0,sp,64
    8000411e:	892a                	mv	s2,a0
    80004120:	8a2e                	mv	s4,a1
    80004122:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004124:	4601                	li	a2,0
    80004126:	00000097          	auipc	ra,0x0
    8000412a:	dd8080e7          	jalr	-552(ra) # 80003efe <dirlookup>
    8000412e:	e93d                	bnez	a0,800041a4 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004130:	04c92483          	lw	s1,76(s2)
    80004134:	c49d                	beqz	s1,80004162 <dirlink+0x54>
    80004136:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004138:	4741                	li	a4,16
    8000413a:	86a6                	mv	a3,s1
    8000413c:	fc040613          	addi	a2,s0,-64
    80004140:	4581                	li	a1,0
    80004142:	854a                	mv	a0,s2
    80004144:	00000097          	auipc	ra,0x0
    80004148:	b8a080e7          	jalr	-1142(ra) # 80003cce <readi>
    8000414c:	47c1                	li	a5,16
    8000414e:	06f51163          	bne	a0,a5,800041b0 <dirlink+0xa2>
    if(de.inum == 0)
    80004152:	fc045783          	lhu	a5,-64(s0)
    80004156:	c791                	beqz	a5,80004162 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004158:	24c1                	addiw	s1,s1,16
    8000415a:	04c92783          	lw	a5,76(s2)
    8000415e:	fcf4ede3          	bltu	s1,a5,80004138 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004162:	4639                	li	a2,14
    80004164:	85d2                	mv	a1,s4
    80004166:	fc240513          	addi	a0,s0,-62
    8000416a:	ffffd097          	auipc	ra,0xffffd
    8000416e:	c90080e7          	jalr	-880(ra) # 80000dfa <strncpy>
  de.inum = inum;
    80004172:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004176:	4741                	li	a4,16
    80004178:	86a6                	mv	a3,s1
    8000417a:	fc040613          	addi	a2,s0,-64
    8000417e:	4581                	li	a1,0
    80004180:	854a                	mv	a0,s2
    80004182:	00000097          	auipc	ra,0x0
    80004186:	c44080e7          	jalr	-956(ra) # 80003dc6 <writei>
    8000418a:	1541                	addi	a0,a0,-16
    8000418c:	00a03533          	snez	a0,a0
    80004190:	40a00533          	neg	a0,a0
}
    80004194:	70e2                	ld	ra,56(sp)
    80004196:	7442                	ld	s0,48(sp)
    80004198:	74a2                	ld	s1,40(sp)
    8000419a:	7902                	ld	s2,32(sp)
    8000419c:	69e2                	ld	s3,24(sp)
    8000419e:	6a42                	ld	s4,16(sp)
    800041a0:	6121                	addi	sp,sp,64
    800041a2:	8082                	ret
    iput(ip);
    800041a4:	00000097          	auipc	ra,0x0
    800041a8:	a30080e7          	jalr	-1488(ra) # 80003bd4 <iput>
    return -1;
    800041ac:	557d                	li	a0,-1
    800041ae:	b7dd                	j	80004194 <dirlink+0x86>
      panic("dirlink read");
    800041b0:	00004517          	auipc	a0,0x4
    800041b4:	5a850513          	addi	a0,a0,1448 # 80008758 <syscalls+0x1e8>
    800041b8:	ffffc097          	auipc	ra,0xffffc
    800041bc:	38c080e7          	jalr	908(ra) # 80000544 <panic>

00000000800041c0 <namei>:

struct inode*
namei(char *path)
{
    800041c0:	1101                	addi	sp,sp,-32
    800041c2:	ec06                	sd	ra,24(sp)
    800041c4:	e822                	sd	s0,16(sp)
    800041c6:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800041c8:	fe040613          	addi	a2,s0,-32
    800041cc:	4581                	li	a1,0
    800041ce:	00000097          	auipc	ra,0x0
    800041d2:	de0080e7          	jalr	-544(ra) # 80003fae <namex>
}
    800041d6:	60e2                	ld	ra,24(sp)
    800041d8:	6442                	ld	s0,16(sp)
    800041da:	6105                	addi	sp,sp,32
    800041dc:	8082                	ret

00000000800041de <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800041de:	1141                	addi	sp,sp,-16
    800041e0:	e406                	sd	ra,8(sp)
    800041e2:	e022                	sd	s0,0(sp)
    800041e4:	0800                	addi	s0,sp,16
    800041e6:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800041e8:	4585                	li	a1,1
    800041ea:	00000097          	auipc	ra,0x0
    800041ee:	dc4080e7          	jalr	-572(ra) # 80003fae <namex>
}
    800041f2:	60a2                	ld	ra,8(sp)
    800041f4:	6402                	ld	s0,0(sp)
    800041f6:	0141                	addi	sp,sp,16
    800041f8:	8082                	ret

00000000800041fa <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800041fa:	1101                	addi	sp,sp,-32
    800041fc:	ec06                	sd	ra,24(sp)
    800041fe:	e822                	sd	s0,16(sp)
    80004200:	e426                	sd	s1,8(sp)
    80004202:	e04a                	sd	s2,0(sp)
    80004204:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004206:	0001e917          	auipc	s2,0x1e
    8000420a:	5ea90913          	addi	s2,s2,1514 # 800227f0 <log>
    8000420e:	01892583          	lw	a1,24(s2)
    80004212:	02892503          	lw	a0,40(s2)
    80004216:	fffff097          	auipc	ra,0xfffff
    8000421a:	fea080e7          	jalr	-22(ra) # 80003200 <bread>
    8000421e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004220:	02c92683          	lw	a3,44(s2)
    80004224:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004226:	02d05763          	blez	a3,80004254 <write_head+0x5a>
    8000422a:	0001e797          	auipc	a5,0x1e
    8000422e:	5f678793          	addi	a5,a5,1526 # 80022820 <log+0x30>
    80004232:	05c50713          	addi	a4,a0,92
    80004236:	36fd                	addiw	a3,a3,-1
    80004238:	1682                	slli	a3,a3,0x20
    8000423a:	9281                	srli	a3,a3,0x20
    8000423c:	068a                	slli	a3,a3,0x2
    8000423e:	0001e617          	auipc	a2,0x1e
    80004242:	5e660613          	addi	a2,a2,1510 # 80022824 <log+0x34>
    80004246:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004248:	4390                	lw	a2,0(a5)
    8000424a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000424c:	0791                	addi	a5,a5,4
    8000424e:	0711                	addi	a4,a4,4
    80004250:	fed79ce3          	bne	a5,a3,80004248 <write_head+0x4e>
  }
  bwrite(buf);
    80004254:	8526                	mv	a0,s1
    80004256:	fffff097          	auipc	ra,0xfffff
    8000425a:	09c080e7          	jalr	156(ra) # 800032f2 <bwrite>
  brelse(buf);
    8000425e:	8526                	mv	a0,s1
    80004260:	fffff097          	auipc	ra,0xfffff
    80004264:	0d0080e7          	jalr	208(ra) # 80003330 <brelse>
}
    80004268:	60e2                	ld	ra,24(sp)
    8000426a:	6442                	ld	s0,16(sp)
    8000426c:	64a2                	ld	s1,8(sp)
    8000426e:	6902                	ld	s2,0(sp)
    80004270:	6105                	addi	sp,sp,32
    80004272:	8082                	ret

0000000080004274 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004274:	0001e797          	auipc	a5,0x1e
    80004278:	5a87a783          	lw	a5,1448(a5) # 8002281c <log+0x2c>
    8000427c:	0af05d63          	blez	a5,80004336 <install_trans+0xc2>
{
    80004280:	7139                	addi	sp,sp,-64
    80004282:	fc06                	sd	ra,56(sp)
    80004284:	f822                	sd	s0,48(sp)
    80004286:	f426                	sd	s1,40(sp)
    80004288:	f04a                	sd	s2,32(sp)
    8000428a:	ec4e                	sd	s3,24(sp)
    8000428c:	e852                	sd	s4,16(sp)
    8000428e:	e456                	sd	s5,8(sp)
    80004290:	e05a                	sd	s6,0(sp)
    80004292:	0080                	addi	s0,sp,64
    80004294:	8b2a                	mv	s6,a0
    80004296:	0001ea97          	auipc	s5,0x1e
    8000429a:	58aa8a93          	addi	s5,s5,1418 # 80022820 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000429e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800042a0:	0001e997          	auipc	s3,0x1e
    800042a4:	55098993          	addi	s3,s3,1360 # 800227f0 <log>
    800042a8:	a035                	j	800042d4 <install_trans+0x60>
      bunpin(dbuf);
    800042aa:	8526                	mv	a0,s1
    800042ac:	fffff097          	auipc	ra,0xfffff
    800042b0:	15e080e7          	jalr	350(ra) # 8000340a <bunpin>
    brelse(lbuf);
    800042b4:	854a                	mv	a0,s2
    800042b6:	fffff097          	auipc	ra,0xfffff
    800042ba:	07a080e7          	jalr	122(ra) # 80003330 <brelse>
    brelse(dbuf);
    800042be:	8526                	mv	a0,s1
    800042c0:	fffff097          	auipc	ra,0xfffff
    800042c4:	070080e7          	jalr	112(ra) # 80003330 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042c8:	2a05                	addiw	s4,s4,1
    800042ca:	0a91                	addi	s5,s5,4
    800042cc:	02c9a783          	lw	a5,44(s3)
    800042d0:	04fa5963          	bge	s4,a5,80004322 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800042d4:	0189a583          	lw	a1,24(s3)
    800042d8:	014585bb          	addw	a1,a1,s4
    800042dc:	2585                	addiw	a1,a1,1
    800042de:	0289a503          	lw	a0,40(s3)
    800042e2:	fffff097          	auipc	ra,0xfffff
    800042e6:	f1e080e7          	jalr	-226(ra) # 80003200 <bread>
    800042ea:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800042ec:	000aa583          	lw	a1,0(s5)
    800042f0:	0289a503          	lw	a0,40(s3)
    800042f4:	fffff097          	auipc	ra,0xfffff
    800042f8:	f0c080e7          	jalr	-244(ra) # 80003200 <bread>
    800042fc:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800042fe:	40000613          	li	a2,1024
    80004302:	05890593          	addi	a1,s2,88
    80004306:	05850513          	addi	a0,a0,88
    8000430a:	ffffd097          	auipc	ra,0xffffd
    8000430e:	a3c080e7          	jalr	-1476(ra) # 80000d46 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004312:	8526                	mv	a0,s1
    80004314:	fffff097          	auipc	ra,0xfffff
    80004318:	fde080e7          	jalr	-34(ra) # 800032f2 <bwrite>
    if(recovering == 0)
    8000431c:	f80b1ce3          	bnez	s6,800042b4 <install_trans+0x40>
    80004320:	b769                	j	800042aa <install_trans+0x36>
}
    80004322:	70e2                	ld	ra,56(sp)
    80004324:	7442                	ld	s0,48(sp)
    80004326:	74a2                	ld	s1,40(sp)
    80004328:	7902                	ld	s2,32(sp)
    8000432a:	69e2                	ld	s3,24(sp)
    8000432c:	6a42                	ld	s4,16(sp)
    8000432e:	6aa2                	ld	s5,8(sp)
    80004330:	6b02                	ld	s6,0(sp)
    80004332:	6121                	addi	sp,sp,64
    80004334:	8082                	ret
    80004336:	8082                	ret

0000000080004338 <initlog>:
{
    80004338:	7179                	addi	sp,sp,-48
    8000433a:	f406                	sd	ra,40(sp)
    8000433c:	f022                	sd	s0,32(sp)
    8000433e:	ec26                	sd	s1,24(sp)
    80004340:	e84a                	sd	s2,16(sp)
    80004342:	e44e                	sd	s3,8(sp)
    80004344:	1800                	addi	s0,sp,48
    80004346:	892a                	mv	s2,a0
    80004348:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000434a:	0001e497          	auipc	s1,0x1e
    8000434e:	4a648493          	addi	s1,s1,1190 # 800227f0 <log>
    80004352:	00004597          	auipc	a1,0x4
    80004356:	41658593          	addi	a1,a1,1046 # 80008768 <syscalls+0x1f8>
    8000435a:	8526                	mv	a0,s1
    8000435c:	ffffc097          	auipc	ra,0xffffc
    80004360:	7fe080e7          	jalr	2046(ra) # 80000b5a <initlock>
  log.start = sb->logstart;
    80004364:	0149a583          	lw	a1,20(s3)
    80004368:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000436a:	0109a783          	lw	a5,16(s3)
    8000436e:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004370:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004374:	854a                	mv	a0,s2
    80004376:	fffff097          	auipc	ra,0xfffff
    8000437a:	e8a080e7          	jalr	-374(ra) # 80003200 <bread>
  log.lh.n = lh->n;
    8000437e:	4d3c                	lw	a5,88(a0)
    80004380:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004382:	02f05563          	blez	a5,800043ac <initlog+0x74>
    80004386:	05c50713          	addi	a4,a0,92
    8000438a:	0001e697          	auipc	a3,0x1e
    8000438e:	49668693          	addi	a3,a3,1174 # 80022820 <log+0x30>
    80004392:	37fd                	addiw	a5,a5,-1
    80004394:	1782                	slli	a5,a5,0x20
    80004396:	9381                	srli	a5,a5,0x20
    80004398:	078a                	slli	a5,a5,0x2
    8000439a:	06050613          	addi	a2,a0,96
    8000439e:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    800043a0:	4310                	lw	a2,0(a4)
    800043a2:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    800043a4:	0711                	addi	a4,a4,4
    800043a6:	0691                	addi	a3,a3,4
    800043a8:	fef71ce3          	bne	a4,a5,800043a0 <initlog+0x68>
  brelse(buf);
    800043ac:	fffff097          	auipc	ra,0xfffff
    800043b0:	f84080e7          	jalr	-124(ra) # 80003330 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800043b4:	4505                	li	a0,1
    800043b6:	00000097          	auipc	ra,0x0
    800043ba:	ebe080e7          	jalr	-322(ra) # 80004274 <install_trans>
  log.lh.n = 0;
    800043be:	0001e797          	auipc	a5,0x1e
    800043c2:	4407af23          	sw	zero,1118(a5) # 8002281c <log+0x2c>
  write_head(); // clear the log
    800043c6:	00000097          	auipc	ra,0x0
    800043ca:	e34080e7          	jalr	-460(ra) # 800041fa <write_head>
}
    800043ce:	70a2                	ld	ra,40(sp)
    800043d0:	7402                	ld	s0,32(sp)
    800043d2:	64e2                	ld	s1,24(sp)
    800043d4:	6942                	ld	s2,16(sp)
    800043d6:	69a2                	ld	s3,8(sp)
    800043d8:	6145                	addi	sp,sp,48
    800043da:	8082                	ret

00000000800043dc <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800043dc:	1101                	addi	sp,sp,-32
    800043de:	ec06                	sd	ra,24(sp)
    800043e0:	e822                	sd	s0,16(sp)
    800043e2:	e426                	sd	s1,8(sp)
    800043e4:	e04a                	sd	s2,0(sp)
    800043e6:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800043e8:	0001e517          	auipc	a0,0x1e
    800043ec:	40850513          	addi	a0,a0,1032 # 800227f0 <log>
    800043f0:	ffffc097          	auipc	ra,0xffffc
    800043f4:	7fa080e7          	jalr	2042(ra) # 80000bea <acquire>
  while(1){
    if(log.committing){
    800043f8:	0001e497          	auipc	s1,0x1e
    800043fc:	3f848493          	addi	s1,s1,1016 # 800227f0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004400:	4979                	li	s2,30
    80004402:	a039                	j	80004410 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004404:	85a6                	mv	a1,s1
    80004406:	8526                	mv	a0,s1
    80004408:	ffffe097          	auipc	ra,0xffffe
    8000440c:	de0080e7          	jalr	-544(ra) # 800021e8 <sleep>
    if(log.committing){
    80004410:	50dc                	lw	a5,36(s1)
    80004412:	fbed                	bnez	a5,80004404 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004414:	509c                	lw	a5,32(s1)
    80004416:	0017871b          	addiw	a4,a5,1
    8000441a:	0007069b          	sext.w	a3,a4
    8000441e:	0027179b          	slliw	a5,a4,0x2
    80004422:	9fb9                	addw	a5,a5,a4
    80004424:	0017979b          	slliw	a5,a5,0x1
    80004428:	54d8                	lw	a4,44(s1)
    8000442a:	9fb9                	addw	a5,a5,a4
    8000442c:	00f95963          	bge	s2,a5,8000443e <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004430:	85a6                	mv	a1,s1
    80004432:	8526                	mv	a0,s1
    80004434:	ffffe097          	auipc	ra,0xffffe
    80004438:	db4080e7          	jalr	-588(ra) # 800021e8 <sleep>
    8000443c:	bfd1                	j	80004410 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000443e:	0001e517          	auipc	a0,0x1e
    80004442:	3b250513          	addi	a0,a0,946 # 800227f0 <log>
    80004446:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004448:	ffffd097          	auipc	ra,0xffffd
    8000444c:	856080e7          	jalr	-1962(ra) # 80000c9e <release>
      break;
    }
  }
}
    80004450:	60e2                	ld	ra,24(sp)
    80004452:	6442                	ld	s0,16(sp)
    80004454:	64a2                	ld	s1,8(sp)
    80004456:	6902                	ld	s2,0(sp)
    80004458:	6105                	addi	sp,sp,32
    8000445a:	8082                	ret

000000008000445c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000445c:	7139                	addi	sp,sp,-64
    8000445e:	fc06                	sd	ra,56(sp)
    80004460:	f822                	sd	s0,48(sp)
    80004462:	f426                	sd	s1,40(sp)
    80004464:	f04a                	sd	s2,32(sp)
    80004466:	ec4e                	sd	s3,24(sp)
    80004468:	e852                	sd	s4,16(sp)
    8000446a:	e456                	sd	s5,8(sp)
    8000446c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000446e:	0001e497          	auipc	s1,0x1e
    80004472:	38248493          	addi	s1,s1,898 # 800227f0 <log>
    80004476:	8526                	mv	a0,s1
    80004478:	ffffc097          	auipc	ra,0xffffc
    8000447c:	772080e7          	jalr	1906(ra) # 80000bea <acquire>
  log.outstanding -= 1;
    80004480:	509c                	lw	a5,32(s1)
    80004482:	37fd                	addiw	a5,a5,-1
    80004484:	0007891b          	sext.w	s2,a5
    80004488:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000448a:	50dc                	lw	a5,36(s1)
    8000448c:	efb9                	bnez	a5,800044ea <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000448e:	06091663          	bnez	s2,800044fa <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    80004492:	0001e497          	auipc	s1,0x1e
    80004496:	35e48493          	addi	s1,s1,862 # 800227f0 <log>
    8000449a:	4785                	li	a5,1
    8000449c:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000449e:	8526                	mv	a0,s1
    800044a0:	ffffc097          	auipc	ra,0xffffc
    800044a4:	7fe080e7          	jalr	2046(ra) # 80000c9e <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800044a8:	54dc                	lw	a5,44(s1)
    800044aa:	06f04763          	bgtz	a5,80004518 <end_op+0xbc>
    acquire(&log.lock);
    800044ae:	0001e497          	auipc	s1,0x1e
    800044b2:	34248493          	addi	s1,s1,834 # 800227f0 <log>
    800044b6:	8526                	mv	a0,s1
    800044b8:	ffffc097          	auipc	ra,0xffffc
    800044bc:	732080e7          	jalr	1842(ra) # 80000bea <acquire>
    log.committing = 0;
    800044c0:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800044c4:	8526                	mv	a0,s1
    800044c6:	ffffe097          	auipc	ra,0xffffe
    800044ca:	d90080e7          	jalr	-624(ra) # 80002256 <wakeup>
    release(&log.lock);
    800044ce:	8526                	mv	a0,s1
    800044d0:	ffffc097          	auipc	ra,0xffffc
    800044d4:	7ce080e7          	jalr	1998(ra) # 80000c9e <release>
}
    800044d8:	70e2                	ld	ra,56(sp)
    800044da:	7442                	ld	s0,48(sp)
    800044dc:	74a2                	ld	s1,40(sp)
    800044de:	7902                	ld	s2,32(sp)
    800044e0:	69e2                	ld	s3,24(sp)
    800044e2:	6a42                	ld	s4,16(sp)
    800044e4:	6aa2                	ld	s5,8(sp)
    800044e6:	6121                	addi	sp,sp,64
    800044e8:	8082                	ret
    panic("log.committing");
    800044ea:	00004517          	auipc	a0,0x4
    800044ee:	28650513          	addi	a0,a0,646 # 80008770 <syscalls+0x200>
    800044f2:	ffffc097          	auipc	ra,0xffffc
    800044f6:	052080e7          	jalr	82(ra) # 80000544 <panic>
    wakeup(&log);
    800044fa:	0001e497          	auipc	s1,0x1e
    800044fe:	2f648493          	addi	s1,s1,758 # 800227f0 <log>
    80004502:	8526                	mv	a0,s1
    80004504:	ffffe097          	auipc	ra,0xffffe
    80004508:	d52080e7          	jalr	-686(ra) # 80002256 <wakeup>
  release(&log.lock);
    8000450c:	8526                	mv	a0,s1
    8000450e:	ffffc097          	auipc	ra,0xffffc
    80004512:	790080e7          	jalr	1936(ra) # 80000c9e <release>
  if(do_commit){
    80004516:	b7c9                	j	800044d8 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004518:	0001ea97          	auipc	s5,0x1e
    8000451c:	308a8a93          	addi	s5,s5,776 # 80022820 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004520:	0001ea17          	auipc	s4,0x1e
    80004524:	2d0a0a13          	addi	s4,s4,720 # 800227f0 <log>
    80004528:	018a2583          	lw	a1,24(s4)
    8000452c:	012585bb          	addw	a1,a1,s2
    80004530:	2585                	addiw	a1,a1,1
    80004532:	028a2503          	lw	a0,40(s4)
    80004536:	fffff097          	auipc	ra,0xfffff
    8000453a:	cca080e7          	jalr	-822(ra) # 80003200 <bread>
    8000453e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004540:	000aa583          	lw	a1,0(s5)
    80004544:	028a2503          	lw	a0,40(s4)
    80004548:	fffff097          	auipc	ra,0xfffff
    8000454c:	cb8080e7          	jalr	-840(ra) # 80003200 <bread>
    80004550:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004552:	40000613          	li	a2,1024
    80004556:	05850593          	addi	a1,a0,88
    8000455a:	05848513          	addi	a0,s1,88
    8000455e:	ffffc097          	auipc	ra,0xffffc
    80004562:	7e8080e7          	jalr	2024(ra) # 80000d46 <memmove>
    bwrite(to);  // write the log
    80004566:	8526                	mv	a0,s1
    80004568:	fffff097          	auipc	ra,0xfffff
    8000456c:	d8a080e7          	jalr	-630(ra) # 800032f2 <bwrite>
    brelse(from);
    80004570:	854e                	mv	a0,s3
    80004572:	fffff097          	auipc	ra,0xfffff
    80004576:	dbe080e7          	jalr	-578(ra) # 80003330 <brelse>
    brelse(to);
    8000457a:	8526                	mv	a0,s1
    8000457c:	fffff097          	auipc	ra,0xfffff
    80004580:	db4080e7          	jalr	-588(ra) # 80003330 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004584:	2905                	addiw	s2,s2,1
    80004586:	0a91                	addi	s5,s5,4
    80004588:	02ca2783          	lw	a5,44(s4)
    8000458c:	f8f94ee3          	blt	s2,a5,80004528 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004590:	00000097          	auipc	ra,0x0
    80004594:	c6a080e7          	jalr	-918(ra) # 800041fa <write_head>
    install_trans(0); // Now install writes to home locations
    80004598:	4501                	li	a0,0
    8000459a:	00000097          	auipc	ra,0x0
    8000459e:	cda080e7          	jalr	-806(ra) # 80004274 <install_trans>
    log.lh.n = 0;
    800045a2:	0001e797          	auipc	a5,0x1e
    800045a6:	2607ad23          	sw	zero,634(a5) # 8002281c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800045aa:	00000097          	auipc	ra,0x0
    800045ae:	c50080e7          	jalr	-944(ra) # 800041fa <write_head>
    800045b2:	bdf5                	j	800044ae <end_op+0x52>

00000000800045b4 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800045b4:	1101                	addi	sp,sp,-32
    800045b6:	ec06                	sd	ra,24(sp)
    800045b8:	e822                	sd	s0,16(sp)
    800045ba:	e426                	sd	s1,8(sp)
    800045bc:	e04a                	sd	s2,0(sp)
    800045be:	1000                	addi	s0,sp,32
    800045c0:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800045c2:	0001e917          	auipc	s2,0x1e
    800045c6:	22e90913          	addi	s2,s2,558 # 800227f0 <log>
    800045ca:	854a                	mv	a0,s2
    800045cc:	ffffc097          	auipc	ra,0xffffc
    800045d0:	61e080e7          	jalr	1566(ra) # 80000bea <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800045d4:	02c92603          	lw	a2,44(s2)
    800045d8:	47f5                	li	a5,29
    800045da:	06c7c563          	blt	a5,a2,80004644 <log_write+0x90>
    800045de:	0001e797          	auipc	a5,0x1e
    800045e2:	22e7a783          	lw	a5,558(a5) # 8002280c <log+0x1c>
    800045e6:	37fd                	addiw	a5,a5,-1
    800045e8:	04f65e63          	bge	a2,a5,80004644 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800045ec:	0001e797          	auipc	a5,0x1e
    800045f0:	2247a783          	lw	a5,548(a5) # 80022810 <log+0x20>
    800045f4:	06f05063          	blez	a5,80004654 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800045f8:	4781                	li	a5,0
    800045fa:	06c05563          	blez	a2,80004664 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800045fe:	44cc                	lw	a1,12(s1)
    80004600:	0001e717          	auipc	a4,0x1e
    80004604:	22070713          	addi	a4,a4,544 # 80022820 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004608:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000460a:	4314                	lw	a3,0(a4)
    8000460c:	04b68c63          	beq	a3,a1,80004664 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004610:	2785                	addiw	a5,a5,1
    80004612:	0711                	addi	a4,a4,4
    80004614:	fef61be3          	bne	a2,a5,8000460a <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004618:	0621                	addi	a2,a2,8
    8000461a:	060a                	slli	a2,a2,0x2
    8000461c:	0001e797          	auipc	a5,0x1e
    80004620:	1d478793          	addi	a5,a5,468 # 800227f0 <log>
    80004624:	963e                	add	a2,a2,a5
    80004626:	44dc                	lw	a5,12(s1)
    80004628:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000462a:	8526                	mv	a0,s1
    8000462c:	fffff097          	auipc	ra,0xfffff
    80004630:	da2080e7          	jalr	-606(ra) # 800033ce <bpin>
    log.lh.n++;
    80004634:	0001e717          	auipc	a4,0x1e
    80004638:	1bc70713          	addi	a4,a4,444 # 800227f0 <log>
    8000463c:	575c                	lw	a5,44(a4)
    8000463e:	2785                	addiw	a5,a5,1
    80004640:	d75c                	sw	a5,44(a4)
    80004642:	a835                	j	8000467e <log_write+0xca>
    panic("too big a transaction");
    80004644:	00004517          	auipc	a0,0x4
    80004648:	13c50513          	addi	a0,a0,316 # 80008780 <syscalls+0x210>
    8000464c:	ffffc097          	auipc	ra,0xffffc
    80004650:	ef8080e7          	jalr	-264(ra) # 80000544 <panic>
    panic("log_write outside of trans");
    80004654:	00004517          	auipc	a0,0x4
    80004658:	14450513          	addi	a0,a0,324 # 80008798 <syscalls+0x228>
    8000465c:	ffffc097          	auipc	ra,0xffffc
    80004660:	ee8080e7          	jalr	-280(ra) # 80000544 <panic>
  log.lh.block[i] = b->blockno;
    80004664:	00878713          	addi	a4,a5,8
    80004668:	00271693          	slli	a3,a4,0x2
    8000466c:	0001e717          	auipc	a4,0x1e
    80004670:	18470713          	addi	a4,a4,388 # 800227f0 <log>
    80004674:	9736                	add	a4,a4,a3
    80004676:	44d4                	lw	a3,12(s1)
    80004678:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000467a:	faf608e3          	beq	a2,a5,8000462a <log_write+0x76>
  }
  release(&log.lock);
    8000467e:	0001e517          	auipc	a0,0x1e
    80004682:	17250513          	addi	a0,a0,370 # 800227f0 <log>
    80004686:	ffffc097          	auipc	ra,0xffffc
    8000468a:	618080e7          	jalr	1560(ra) # 80000c9e <release>
}
    8000468e:	60e2                	ld	ra,24(sp)
    80004690:	6442                	ld	s0,16(sp)
    80004692:	64a2                	ld	s1,8(sp)
    80004694:	6902                	ld	s2,0(sp)
    80004696:	6105                	addi	sp,sp,32
    80004698:	8082                	ret

000000008000469a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000469a:	1101                	addi	sp,sp,-32
    8000469c:	ec06                	sd	ra,24(sp)
    8000469e:	e822                	sd	s0,16(sp)
    800046a0:	e426                	sd	s1,8(sp)
    800046a2:	e04a                	sd	s2,0(sp)
    800046a4:	1000                	addi	s0,sp,32
    800046a6:	84aa                	mv	s1,a0
    800046a8:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800046aa:	00004597          	auipc	a1,0x4
    800046ae:	10e58593          	addi	a1,a1,270 # 800087b8 <syscalls+0x248>
    800046b2:	0521                	addi	a0,a0,8
    800046b4:	ffffc097          	auipc	ra,0xffffc
    800046b8:	4a6080e7          	jalr	1190(ra) # 80000b5a <initlock>
  lk->name = name;
    800046bc:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800046c0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800046c4:	0204a423          	sw	zero,40(s1)
}
    800046c8:	60e2                	ld	ra,24(sp)
    800046ca:	6442                	ld	s0,16(sp)
    800046cc:	64a2                	ld	s1,8(sp)
    800046ce:	6902                	ld	s2,0(sp)
    800046d0:	6105                	addi	sp,sp,32
    800046d2:	8082                	ret

00000000800046d4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800046d4:	1101                	addi	sp,sp,-32
    800046d6:	ec06                	sd	ra,24(sp)
    800046d8:	e822                	sd	s0,16(sp)
    800046da:	e426                	sd	s1,8(sp)
    800046dc:	e04a                	sd	s2,0(sp)
    800046de:	1000                	addi	s0,sp,32
    800046e0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800046e2:	00850913          	addi	s2,a0,8
    800046e6:	854a                	mv	a0,s2
    800046e8:	ffffc097          	auipc	ra,0xffffc
    800046ec:	502080e7          	jalr	1282(ra) # 80000bea <acquire>
  while (lk->locked) {
    800046f0:	409c                	lw	a5,0(s1)
    800046f2:	cb89                	beqz	a5,80004704 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800046f4:	85ca                	mv	a1,s2
    800046f6:	8526                	mv	a0,s1
    800046f8:	ffffe097          	auipc	ra,0xffffe
    800046fc:	af0080e7          	jalr	-1296(ra) # 800021e8 <sleep>
  while (lk->locked) {
    80004700:	409c                	lw	a5,0(s1)
    80004702:	fbed                	bnez	a5,800046f4 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004704:	4785                	li	a5,1
    80004706:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004708:	ffffd097          	auipc	ra,0xffffd
    8000470c:	3c8080e7          	jalr	968(ra) # 80001ad0 <myproc>
    80004710:	5d1c                	lw	a5,56(a0)
    80004712:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004714:	854a                	mv	a0,s2
    80004716:	ffffc097          	auipc	ra,0xffffc
    8000471a:	588080e7          	jalr	1416(ra) # 80000c9e <release>
}
    8000471e:	60e2                	ld	ra,24(sp)
    80004720:	6442                	ld	s0,16(sp)
    80004722:	64a2                	ld	s1,8(sp)
    80004724:	6902                	ld	s2,0(sp)
    80004726:	6105                	addi	sp,sp,32
    80004728:	8082                	ret

000000008000472a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000472a:	1101                	addi	sp,sp,-32
    8000472c:	ec06                	sd	ra,24(sp)
    8000472e:	e822                	sd	s0,16(sp)
    80004730:	e426                	sd	s1,8(sp)
    80004732:	e04a                	sd	s2,0(sp)
    80004734:	1000                	addi	s0,sp,32
    80004736:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004738:	00850913          	addi	s2,a0,8
    8000473c:	854a                	mv	a0,s2
    8000473e:	ffffc097          	auipc	ra,0xffffc
    80004742:	4ac080e7          	jalr	1196(ra) # 80000bea <acquire>
  lk->locked = 0;
    80004746:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000474a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000474e:	8526                	mv	a0,s1
    80004750:	ffffe097          	auipc	ra,0xffffe
    80004754:	b06080e7          	jalr	-1274(ra) # 80002256 <wakeup>
  release(&lk->lk);
    80004758:	854a                	mv	a0,s2
    8000475a:	ffffc097          	auipc	ra,0xffffc
    8000475e:	544080e7          	jalr	1348(ra) # 80000c9e <release>
}
    80004762:	60e2                	ld	ra,24(sp)
    80004764:	6442                	ld	s0,16(sp)
    80004766:	64a2                	ld	s1,8(sp)
    80004768:	6902                	ld	s2,0(sp)
    8000476a:	6105                	addi	sp,sp,32
    8000476c:	8082                	ret

000000008000476e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000476e:	7179                	addi	sp,sp,-48
    80004770:	f406                	sd	ra,40(sp)
    80004772:	f022                	sd	s0,32(sp)
    80004774:	ec26                	sd	s1,24(sp)
    80004776:	e84a                	sd	s2,16(sp)
    80004778:	e44e                	sd	s3,8(sp)
    8000477a:	1800                	addi	s0,sp,48
    8000477c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000477e:	00850913          	addi	s2,a0,8
    80004782:	854a                	mv	a0,s2
    80004784:	ffffc097          	auipc	ra,0xffffc
    80004788:	466080e7          	jalr	1126(ra) # 80000bea <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000478c:	409c                	lw	a5,0(s1)
    8000478e:	ef99                	bnez	a5,800047ac <holdingsleep+0x3e>
    80004790:	4481                	li	s1,0
  release(&lk->lk);
    80004792:	854a                	mv	a0,s2
    80004794:	ffffc097          	auipc	ra,0xffffc
    80004798:	50a080e7          	jalr	1290(ra) # 80000c9e <release>
  return r;
}
    8000479c:	8526                	mv	a0,s1
    8000479e:	70a2                	ld	ra,40(sp)
    800047a0:	7402                	ld	s0,32(sp)
    800047a2:	64e2                	ld	s1,24(sp)
    800047a4:	6942                	ld	s2,16(sp)
    800047a6:	69a2                	ld	s3,8(sp)
    800047a8:	6145                	addi	sp,sp,48
    800047aa:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800047ac:	0284a983          	lw	s3,40(s1)
    800047b0:	ffffd097          	auipc	ra,0xffffd
    800047b4:	320080e7          	jalr	800(ra) # 80001ad0 <myproc>
    800047b8:	5d04                	lw	s1,56(a0)
    800047ba:	413484b3          	sub	s1,s1,s3
    800047be:	0014b493          	seqz	s1,s1
    800047c2:	bfc1                	j	80004792 <holdingsleep+0x24>

00000000800047c4 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800047c4:	1141                	addi	sp,sp,-16
    800047c6:	e406                	sd	ra,8(sp)
    800047c8:	e022                	sd	s0,0(sp)
    800047ca:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800047cc:	00004597          	auipc	a1,0x4
    800047d0:	ffc58593          	addi	a1,a1,-4 # 800087c8 <syscalls+0x258>
    800047d4:	0001e517          	auipc	a0,0x1e
    800047d8:	16450513          	addi	a0,a0,356 # 80022938 <ftable>
    800047dc:	ffffc097          	auipc	ra,0xffffc
    800047e0:	37e080e7          	jalr	894(ra) # 80000b5a <initlock>
}
    800047e4:	60a2                	ld	ra,8(sp)
    800047e6:	6402                	ld	s0,0(sp)
    800047e8:	0141                	addi	sp,sp,16
    800047ea:	8082                	ret

00000000800047ec <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800047ec:	1101                	addi	sp,sp,-32
    800047ee:	ec06                	sd	ra,24(sp)
    800047f0:	e822                	sd	s0,16(sp)
    800047f2:	e426                	sd	s1,8(sp)
    800047f4:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800047f6:	0001e517          	auipc	a0,0x1e
    800047fa:	14250513          	addi	a0,a0,322 # 80022938 <ftable>
    800047fe:	ffffc097          	auipc	ra,0xffffc
    80004802:	3ec080e7          	jalr	1004(ra) # 80000bea <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004806:	0001e497          	auipc	s1,0x1e
    8000480a:	14a48493          	addi	s1,s1,330 # 80022950 <ftable+0x18>
    8000480e:	0001f717          	auipc	a4,0x1f
    80004812:	0e270713          	addi	a4,a4,226 # 800238f0 <disk>
    if(f->ref == 0){
    80004816:	40dc                	lw	a5,4(s1)
    80004818:	cf99                	beqz	a5,80004836 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000481a:	02848493          	addi	s1,s1,40
    8000481e:	fee49ce3          	bne	s1,a4,80004816 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004822:	0001e517          	auipc	a0,0x1e
    80004826:	11650513          	addi	a0,a0,278 # 80022938 <ftable>
    8000482a:	ffffc097          	auipc	ra,0xffffc
    8000482e:	474080e7          	jalr	1140(ra) # 80000c9e <release>
  return 0;
    80004832:	4481                	li	s1,0
    80004834:	a819                	j	8000484a <filealloc+0x5e>
      f->ref = 1;
    80004836:	4785                	li	a5,1
    80004838:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000483a:	0001e517          	auipc	a0,0x1e
    8000483e:	0fe50513          	addi	a0,a0,254 # 80022938 <ftable>
    80004842:	ffffc097          	auipc	ra,0xffffc
    80004846:	45c080e7          	jalr	1116(ra) # 80000c9e <release>
}
    8000484a:	8526                	mv	a0,s1
    8000484c:	60e2                	ld	ra,24(sp)
    8000484e:	6442                	ld	s0,16(sp)
    80004850:	64a2                	ld	s1,8(sp)
    80004852:	6105                	addi	sp,sp,32
    80004854:	8082                	ret

0000000080004856 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004856:	1101                	addi	sp,sp,-32
    80004858:	ec06                	sd	ra,24(sp)
    8000485a:	e822                	sd	s0,16(sp)
    8000485c:	e426                	sd	s1,8(sp)
    8000485e:	1000                	addi	s0,sp,32
    80004860:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004862:	0001e517          	auipc	a0,0x1e
    80004866:	0d650513          	addi	a0,a0,214 # 80022938 <ftable>
    8000486a:	ffffc097          	auipc	ra,0xffffc
    8000486e:	380080e7          	jalr	896(ra) # 80000bea <acquire>
  if(f->ref < 1)
    80004872:	40dc                	lw	a5,4(s1)
    80004874:	02f05263          	blez	a5,80004898 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004878:	2785                	addiw	a5,a5,1
    8000487a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000487c:	0001e517          	auipc	a0,0x1e
    80004880:	0bc50513          	addi	a0,a0,188 # 80022938 <ftable>
    80004884:	ffffc097          	auipc	ra,0xffffc
    80004888:	41a080e7          	jalr	1050(ra) # 80000c9e <release>
  return f;
}
    8000488c:	8526                	mv	a0,s1
    8000488e:	60e2                	ld	ra,24(sp)
    80004890:	6442                	ld	s0,16(sp)
    80004892:	64a2                	ld	s1,8(sp)
    80004894:	6105                	addi	sp,sp,32
    80004896:	8082                	ret
    panic("filedup");
    80004898:	00004517          	auipc	a0,0x4
    8000489c:	f3850513          	addi	a0,a0,-200 # 800087d0 <syscalls+0x260>
    800048a0:	ffffc097          	auipc	ra,0xffffc
    800048a4:	ca4080e7          	jalr	-860(ra) # 80000544 <panic>

00000000800048a8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800048a8:	7139                	addi	sp,sp,-64
    800048aa:	fc06                	sd	ra,56(sp)
    800048ac:	f822                	sd	s0,48(sp)
    800048ae:	f426                	sd	s1,40(sp)
    800048b0:	f04a                	sd	s2,32(sp)
    800048b2:	ec4e                	sd	s3,24(sp)
    800048b4:	e852                	sd	s4,16(sp)
    800048b6:	e456                	sd	s5,8(sp)
    800048b8:	0080                	addi	s0,sp,64
    800048ba:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800048bc:	0001e517          	auipc	a0,0x1e
    800048c0:	07c50513          	addi	a0,a0,124 # 80022938 <ftable>
    800048c4:	ffffc097          	auipc	ra,0xffffc
    800048c8:	326080e7          	jalr	806(ra) # 80000bea <acquire>
  if(f->ref < 1)
    800048cc:	40dc                	lw	a5,4(s1)
    800048ce:	06f05163          	blez	a5,80004930 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800048d2:	37fd                	addiw	a5,a5,-1
    800048d4:	0007871b          	sext.w	a4,a5
    800048d8:	c0dc                	sw	a5,4(s1)
    800048da:	06e04363          	bgtz	a4,80004940 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800048de:	0004a903          	lw	s2,0(s1)
    800048e2:	0094ca83          	lbu	s5,9(s1)
    800048e6:	0104ba03          	ld	s4,16(s1)
    800048ea:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800048ee:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800048f2:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800048f6:	0001e517          	auipc	a0,0x1e
    800048fa:	04250513          	addi	a0,a0,66 # 80022938 <ftable>
    800048fe:	ffffc097          	auipc	ra,0xffffc
    80004902:	3a0080e7          	jalr	928(ra) # 80000c9e <release>

  if(ff.type == FD_PIPE){
    80004906:	4785                	li	a5,1
    80004908:	04f90d63          	beq	s2,a5,80004962 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000490c:	3979                	addiw	s2,s2,-2
    8000490e:	4785                	li	a5,1
    80004910:	0527e063          	bltu	a5,s2,80004950 <fileclose+0xa8>
    begin_op();
    80004914:	00000097          	auipc	ra,0x0
    80004918:	ac8080e7          	jalr	-1336(ra) # 800043dc <begin_op>
    iput(ff.ip);
    8000491c:	854e                	mv	a0,s3
    8000491e:	fffff097          	auipc	ra,0xfffff
    80004922:	2b6080e7          	jalr	694(ra) # 80003bd4 <iput>
    end_op();
    80004926:	00000097          	auipc	ra,0x0
    8000492a:	b36080e7          	jalr	-1226(ra) # 8000445c <end_op>
    8000492e:	a00d                	j	80004950 <fileclose+0xa8>
    panic("fileclose");
    80004930:	00004517          	auipc	a0,0x4
    80004934:	ea850513          	addi	a0,a0,-344 # 800087d8 <syscalls+0x268>
    80004938:	ffffc097          	auipc	ra,0xffffc
    8000493c:	c0c080e7          	jalr	-1012(ra) # 80000544 <panic>
    release(&ftable.lock);
    80004940:	0001e517          	auipc	a0,0x1e
    80004944:	ff850513          	addi	a0,a0,-8 # 80022938 <ftable>
    80004948:	ffffc097          	auipc	ra,0xffffc
    8000494c:	356080e7          	jalr	854(ra) # 80000c9e <release>
  }
}
    80004950:	70e2                	ld	ra,56(sp)
    80004952:	7442                	ld	s0,48(sp)
    80004954:	74a2                	ld	s1,40(sp)
    80004956:	7902                	ld	s2,32(sp)
    80004958:	69e2                	ld	s3,24(sp)
    8000495a:	6a42                	ld	s4,16(sp)
    8000495c:	6aa2                	ld	s5,8(sp)
    8000495e:	6121                	addi	sp,sp,64
    80004960:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004962:	85d6                	mv	a1,s5
    80004964:	8552                	mv	a0,s4
    80004966:	00000097          	auipc	ra,0x0
    8000496a:	34c080e7          	jalr	844(ra) # 80004cb2 <pipeclose>
    8000496e:	b7cd                	j	80004950 <fileclose+0xa8>

0000000080004970 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004970:	715d                	addi	sp,sp,-80
    80004972:	e486                	sd	ra,72(sp)
    80004974:	e0a2                	sd	s0,64(sp)
    80004976:	fc26                	sd	s1,56(sp)
    80004978:	f84a                	sd	s2,48(sp)
    8000497a:	f44e                	sd	s3,40(sp)
    8000497c:	0880                	addi	s0,sp,80
    8000497e:	84aa                	mv	s1,a0
    80004980:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004982:	ffffd097          	auipc	ra,0xffffd
    80004986:	14e080e7          	jalr	334(ra) # 80001ad0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000498a:	409c                	lw	a5,0(s1)
    8000498c:	37f9                	addiw	a5,a5,-2
    8000498e:	4705                	li	a4,1
    80004990:	04f76763          	bltu	a4,a5,800049de <filestat+0x6e>
    80004994:	892a                	mv	s2,a0
    ilock(f->ip);
    80004996:	6c88                	ld	a0,24(s1)
    80004998:	fffff097          	auipc	ra,0xfffff
    8000499c:	082080e7          	jalr	130(ra) # 80003a1a <ilock>
    stati(f->ip, &st);
    800049a0:	fb840593          	addi	a1,s0,-72
    800049a4:	6c88                	ld	a0,24(s1)
    800049a6:	fffff097          	auipc	ra,0xfffff
    800049aa:	2fe080e7          	jalr	766(ra) # 80003ca4 <stati>
    iunlock(f->ip);
    800049ae:	6c88                	ld	a0,24(s1)
    800049b0:	fffff097          	auipc	ra,0xfffff
    800049b4:	12c080e7          	jalr	300(ra) # 80003adc <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800049b8:	46e1                	li	a3,24
    800049ba:	fb840613          	addi	a2,s0,-72
    800049be:	85ce                	mv	a1,s3
    800049c0:	05893503          	ld	a0,88(s2)
    800049c4:	ffffd097          	auipc	ra,0xffffd
    800049c8:	cc0080e7          	jalr	-832(ra) # 80001684 <copyout>
    800049cc:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800049d0:	60a6                	ld	ra,72(sp)
    800049d2:	6406                	ld	s0,64(sp)
    800049d4:	74e2                	ld	s1,56(sp)
    800049d6:	7942                	ld	s2,48(sp)
    800049d8:	79a2                	ld	s3,40(sp)
    800049da:	6161                	addi	sp,sp,80
    800049dc:	8082                	ret
  return -1;
    800049de:	557d                	li	a0,-1
    800049e0:	bfc5                	j	800049d0 <filestat+0x60>

00000000800049e2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800049e2:	7179                	addi	sp,sp,-48
    800049e4:	f406                	sd	ra,40(sp)
    800049e6:	f022                	sd	s0,32(sp)
    800049e8:	ec26                	sd	s1,24(sp)
    800049ea:	e84a                	sd	s2,16(sp)
    800049ec:	e44e                	sd	s3,8(sp)
    800049ee:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800049f0:	00854783          	lbu	a5,8(a0)
    800049f4:	c3d5                	beqz	a5,80004a98 <fileread+0xb6>
    800049f6:	84aa                	mv	s1,a0
    800049f8:	89ae                	mv	s3,a1
    800049fa:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800049fc:	411c                	lw	a5,0(a0)
    800049fe:	4705                	li	a4,1
    80004a00:	04e78963          	beq	a5,a4,80004a52 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a04:	470d                	li	a4,3
    80004a06:	04e78d63          	beq	a5,a4,80004a60 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004a0a:	4709                	li	a4,2
    80004a0c:	06e79e63          	bne	a5,a4,80004a88 <fileread+0xa6>
    ilock(f->ip);
    80004a10:	6d08                	ld	a0,24(a0)
    80004a12:	fffff097          	auipc	ra,0xfffff
    80004a16:	008080e7          	jalr	8(ra) # 80003a1a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004a1a:	874a                	mv	a4,s2
    80004a1c:	5094                	lw	a3,32(s1)
    80004a1e:	864e                	mv	a2,s3
    80004a20:	4585                	li	a1,1
    80004a22:	6c88                	ld	a0,24(s1)
    80004a24:	fffff097          	auipc	ra,0xfffff
    80004a28:	2aa080e7          	jalr	682(ra) # 80003cce <readi>
    80004a2c:	892a                	mv	s2,a0
    80004a2e:	00a05563          	blez	a0,80004a38 <fileread+0x56>
      f->off += r;
    80004a32:	509c                	lw	a5,32(s1)
    80004a34:	9fa9                	addw	a5,a5,a0
    80004a36:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004a38:	6c88                	ld	a0,24(s1)
    80004a3a:	fffff097          	auipc	ra,0xfffff
    80004a3e:	0a2080e7          	jalr	162(ra) # 80003adc <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004a42:	854a                	mv	a0,s2
    80004a44:	70a2                	ld	ra,40(sp)
    80004a46:	7402                	ld	s0,32(sp)
    80004a48:	64e2                	ld	s1,24(sp)
    80004a4a:	6942                	ld	s2,16(sp)
    80004a4c:	69a2                	ld	s3,8(sp)
    80004a4e:	6145                	addi	sp,sp,48
    80004a50:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004a52:	6908                	ld	a0,16(a0)
    80004a54:	00000097          	auipc	ra,0x0
    80004a58:	3ce080e7          	jalr	974(ra) # 80004e22 <piperead>
    80004a5c:	892a                	mv	s2,a0
    80004a5e:	b7d5                	j	80004a42 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004a60:	02451783          	lh	a5,36(a0)
    80004a64:	03079693          	slli	a3,a5,0x30
    80004a68:	92c1                	srli	a3,a3,0x30
    80004a6a:	4725                	li	a4,9
    80004a6c:	02d76863          	bltu	a4,a3,80004a9c <fileread+0xba>
    80004a70:	0792                	slli	a5,a5,0x4
    80004a72:	0001e717          	auipc	a4,0x1e
    80004a76:	e2670713          	addi	a4,a4,-474 # 80022898 <devsw>
    80004a7a:	97ba                	add	a5,a5,a4
    80004a7c:	639c                	ld	a5,0(a5)
    80004a7e:	c38d                	beqz	a5,80004aa0 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004a80:	4505                	li	a0,1
    80004a82:	9782                	jalr	a5
    80004a84:	892a                	mv	s2,a0
    80004a86:	bf75                	j	80004a42 <fileread+0x60>
    panic("fileread");
    80004a88:	00004517          	auipc	a0,0x4
    80004a8c:	d6050513          	addi	a0,a0,-672 # 800087e8 <syscalls+0x278>
    80004a90:	ffffc097          	auipc	ra,0xffffc
    80004a94:	ab4080e7          	jalr	-1356(ra) # 80000544 <panic>
    return -1;
    80004a98:	597d                	li	s2,-1
    80004a9a:	b765                	j	80004a42 <fileread+0x60>
      return -1;
    80004a9c:	597d                	li	s2,-1
    80004a9e:	b755                	j	80004a42 <fileread+0x60>
    80004aa0:	597d                	li	s2,-1
    80004aa2:	b745                	j	80004a42 <fileread+0x60>

0000000080004aa4 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004aa4:	715d                	addi	sp,sp,-80
    80004aa6:	e486                	sd	ra,72(sp)
    80004aa8:	e0a2                	sd	s0,64(sp)
    80004aaa:	fc26                	sd	s1,56(sp)
    80004aac:	f84a                	sd	s2,48(sp)
    80004aae:	f44e                	sd	s3,40(sp)
    80004ab0:	f052                	sd	s4,32(sp)
    80004ab2:	ec56                	sd	s5,24(sp)
    80004ab4:	e85a                	sd	s6,16(sp)
    80004ab6:	e45e                	sd	s7,8(sp)
    80004ab8:	e062                	sd	s8,0(sp)
    80004aba:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004abc:	00954783          	lbu	a5,9(a0)
    80004ac0:	10078663          	beqz	a5,80004bcc <filewrite+0x128>
    80004ac4:	892a                	mv	s2,a0
    80004ac6:	8aae                	mv	s5,a1
    80004ac8:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004aca:	411c                	lw	a5,0(a0)
    80004acc:	4705                	li	a4,1
    80004ace:	02e78263          	beq	a5,a4,80004af2 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004ad2:	470d                	li	a4,3
    80004ad4:	02e78663          	beq	a5,a4,80004b00 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004ad8:	4709                	li	a4,2
    80004ada:	0ee79163          	bne	a5,a4,80004bbc <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004ade:	0ac05d63          	blez	a2,80004b98 <filewrite+0xf4>
    int i = 0;
    80004ae2:	4981                	li	s3,0
    80004ae4:	6b05                	lui	s6,0x1
    80004ae6:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004aea:	6b85                	lui	s7,0x1
    80004aec:	c00b8b9b          	addiw	s7,s7,-1024
    80004af0:	a861                	j	80004b88 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004af2:	6908                	ld	a0,16(a0)
    80004af4:	00000097          	auipc	ra,0x0
    80004af8:	22e080e7          	jalr	558(ra) # 80004d22 <pipewrite>
    80004afc:	8a2a                	mv	s4,a0
    80004afe:	a045                	j	80004b9e <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004b00:	02451783          	lh	a5,36(a0)
    80004b04:	03079693          	slli	a3,a5,0x30
    80004b08:	92c1                	srli	a3,a3,0x30
    80004b0a:	4725                	li	a4,9
    80004b0c:	0cd76263          	bltu	a4,a3,80004bd0 <filewrite+0x12c>
    80004b10:	0792                	slli	a5,a5,0x4
    80004b12:	0001e717          	auipc	a4,0x1e
    80004b16:	d8670713          	addi	a4,a4,-634 # 80022898 <devsw>
    80004b1a:	97ba                	add	a5,a5,a4
    80004b1c:	679c                	ld	a5,8(a5)
    80004b1e:	cbdd                	beqz	a5,80004bd4 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004b20:	4505                	li	a0,1
    80004b22:	9782                	jalr	a5
    80004b24:	8a2a                	mv	s4,a0
    80004b26:	a8a5                	j	80004b9e <filewrite+0xfa>
    80004b28:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004b2c:	00000097          	auipc	ra,0x0
    80004b30:	8b0080e7          	jalr	-1872(ra) # 800043dc <begin_op>
      ilock(f->ip);
    80004b34:	01893503          	ld	a0,24(s2)
    80004b38:	fffff097          	auipc	ra,0xfffff
    80004b3c:	ee2080e7          	jalr	-286(ra) # 80003a1a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004b40:	8762                	mv	a4,s8
    80004b42:	02092683          	lw	a3,32(s2)
    80004b46:	01598633          	add	a2,s3,s5
    80004b4a:	4585                	li	a1,1
    80004b4c:	01893503          	ld	a0,24(s2)
    80004b50:	fffff097          	auipc	ra,0xfffff
    80004b54:	276080e7          	jalr	630(ra) # 80003dc6 <writei>
    80004b58:	84aa                	mv	s1,a0
    80004b5a:	00a05763          	blez	a0,80004b68 <filewrite+0xc4>
        f->off += r;
    80004b5e:	02092783          	lw	a5,32(s2)
    80004b62:	9fa9                	addw	a5,a5,a0
    80004b64:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004b68:	01893503          	ld	a0,24(s2)
    80004b6c:	fffff097          	auipc	ra,0xfffff
    80004b70:	f70080e7          	jalr	-144(ra) # 80003adc <iunlock>
      end_op();
    80004b74:	00000097          	auipc	ra,0x0
    80004b78:	8e8080e7          	jalr	-1816(ra) # 8000445c <end_op>

      if(r != n1){
    80004b7c:	009c1f63          	bne	s8,s1,80004b9a <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004b80:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004b84:	0149db63          	bge	s3,s4,80004b9a <filewrite+0xf6>
      int n1 = n - i;
    80004b88:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004b8c:	84be                	mv	s1,a5
    80004b8e:	2781                	sext.w	a5,a5
    80004b90:	f8fb5ce3          	bge	s6,a5,80004b28 <filewrite+0x84>
    80004b94:	84de                	mv	s1,s7
    80004b96:	bf49                	j	80004b28 <filewrite+0x84>
    int i = 0;
    80004b98:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004b9a:	013a1f63          	bne	s4,s3,80004bb8 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004b9e:	8552                	mv	a0,s4
    80004ba0:	60a6                	ld	ra,72(sp)
    80004ba2:	6406                	ld	s0,64(sp)
    80004ba4:	74e2                	ld	s1,56(sp)
    80004ba6:	7942                	ld	s2,48(sp)
    80004ba8:	79a2                	ld	s3,40(sp)
    80004baa:	7a02                	ld	s4,32(sp)
    80004bac:	6ae2                	ld	s5,24(sp)
    80004bae:	6b42                	ld	s6,16(sp)
    80004bb0:	6ba2                	ld	s7,8(sp)
    80004bb2:	6c02                	ld	s8,0(sp)
    80004bb4:	6161                	addi	sp,sp,80
    80004bb6:	8082                	ret
    ret = (i == n ? n : -1);
    80004bb8:	5a7d                	li	s4,-1
    80004bba:	b7d5                	j	80004b9e <filewrite+0xfa>
    panic("filewrite");
    80004bbc:	00004517          	auipc	a0,0x4
    80004bc0:	c3c50513          	addi	a0,a0,-964 # 800087f8 <syscalls+0x288>
    80004bc4:	ffffc097          	auipc	ra,0xffffc
    80004bc8:	980080e7          	jalr	-1664(ra) # 80000544 <panic>
    return -1;
    80004bcc:	5a7d                	li	s4,-1
    80004bce:	bfc1                	j	80004b9e <filewrite+0xfa>
      return -1;
    80004bd0:	5a7d                	li	s4,-1
    80004bd2:	b7f1                	j	80004b9e <filewrite+0xfa>
    80004bd4:	5a7d                	li	s4,-1
    80004bd6:	b7e1                	j	80004b9e <filewrite+0xfa>

0000000080004bd8 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004bd8:	7179                	addi	sp,sp,-48
    80004bda:	f406                	sd	ra,40(sp)
    80004bdc:	f022                	sd	s0,32(sp)
    80004bde:	ec26                	sd	s1,24(sp)
    80004be0:	e84a                	sd	s2,16(sp)
    80004be2:	e44e                	sd	s3,8(sp)
    80004be4:	e052                	sd	s4,0(sp)
    80004be6:	1800                	addi	s0,sp,48
    80004be8:	84aa                	mv	s1,a0
    80004bea:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004bec:	0005b023          	sd	zero,0(a1)
    80004bf0:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004bf4:	00000097          	auipc	ra,0x0
    80004bf8:	bf8080e7          	jalr	-1032(ra) # 800047ec <filealloc>
    80004bfc:	e088                	sd	a0,0(s1)
    80004bfe:	c551                	beqz	a0,80004c8a <pipealloc+0xb2>
    80004c00:	00000097          	auipc	ra,0x0
    80004c04:	bec080e7          	jalr	-1044(ra) # 800047ec <filealloc>
    80004c08:	00aa3023          	sd	a0,0(s4)
    80004c0c:	c92d                	beqz	a0,80004c7e <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004c0e:	ffffc097          	auipc	ra,0xffffc
    80004c12:	eec080e7          	jalr	-276(ra) # 80000afa <kalloc>
    80004c16:	892a                	mv	s2,a0
    80004c18:	c125                	beqz	a0,80004c78 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004c1a:	4985                	li	s3,1
    80004c1c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004c20:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004c24:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004c28:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004c2c:	00004597          	auipc	a1,0x4
    80004c30:	86c58593          	addi	a1,a1,-1940 # 80008498 <states.2476+0x1b8>
    80004c34:	ffffc097          	auipc	ra,0xffffc
    80004c38:	f26080e7          	jalr	-218(ra) # 80000b5a <initlock>
  (*f0)->type = FD_PIPE;
    80004c3c:	609c                	ld	a5,0(s1)
    80004c3e:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004c42:	609c                	ld	a5,0(s1)
    80004c44:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004c48:	609c                	ld	a5,0(s1)
    80004c4a:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004c4e:	609c                	ld	a5,0(s1)
    80004c50:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004c54:	000a3783          	ld	a5,0(s4)
    80004c58:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004c5c:	000a3783          	ld	a5,0(s4)
    80004c60:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004c64:	000a3783          	ld	a5,0(s4)
    80004c68:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004c6c:	000a3783          	ld	a5,0(s4)
    80004c70:	0127b823          	sd	s2,16(a5)
  return 0;
    80004c74:	4501                	li	a0,0
    80004c76:	a025                	j	80004c9e <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004c78:	6088                	ld	a0,0(s1)
    80004c7a:	e501                	bnez	a0,80004c82 <pipealloc+0xaa>
    80004c7c:	a039                	j	80004c8a <pipealloc+0xb2>
    80004c7e:	6088                	ld	a0,0(s1)
    80004c80:	c51d                	beqz	a0,80004cae <pipealloc+0xd6>
    fileclose(*f0);
    80004c82:	00000097          	auipc	ra,0x0
    80004c86:	c26080e7          	jalr	-986(ra) # 800048a8 <fileclose>
  if(*f1)
    80004c8a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004c8e:	557d                	li	a0,-1
  if(*f1)
    80004c90:	c799                	beqz	a5,80004c9e <pipealloc+0xc6>
    fileclose(*f1);
    80004c92:	853e                	mv	a0,a5
    80004c94:	00000097          	auipc	ra,0x0
    80004c98:	c14080e7          	jalr	-1004(ra) # 800048a8 <fileclose>
  return -1;
    80004c9c:	557d                	li	a0,-1
}
    80004c9e:	70a2                	ld	ra,40(sp)
    80004ca0:	7402                	ld	s0,32(sp)
    80004ca2:	64e2                	ld	s1,24(sp)
    80004ca4:	6942                	ld	s2,16(sp)
    80004ca6:	69a2                	ld	s3,8(sp)
    80004ca8:	6a02                	ld	s4,0(sp)
    80004caa:	6145                	addi	sp,sp,48
    80004cac:	8082                	ret
  return -1;
    80004cae:	557d                	li	a0,-1
    80004cb0:	b7fd                	j	80004c9e <pipealloc+0xc6>

0000000080004cb2 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004cb2:	1101                	addi	sp,sp,-32
    80004cb4:	ec06                	sd	ra,24(sp)
    80004cb6:	e822                	sd	s0,16(sp)
    80004cb8:	e426                	sd	s1,8(sp)
    80004cba:	e04a                	sd	s2,0(sp)
    80004cbc:	1000                	addi	s0,sp,32
    80004cbe:	84aa                	mv	s1,a0
    80004cc0:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004cc2:	ffffc097          	auipc	ra,0xffffc
    80004cc6:	f28080e7          	jalr	-216(ra) # 80000bea <acquire>
  if(writable){
    80004cca:	02090d63          	beqz	s2,80004d04 <pipeclose+0x52>
    pi->writeopen = 0;
    80004cce:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004cd2:	21848513          	addi	a0,s1,536
    80004cd6:	ffffd097          	auipc	ra,0xffffd
    80004cda:	580080e7          	jalr	1408(ra) # 80002256 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004cde:	2204b783          	ld	a5,544(s1)
    80004ce2:	eb95                	bnez	a5,80004d16 <pipeclose+0x64>
    release(&pi->lock);
    80004ce4:	8526                	mv	a0,s1
    80004ce6:	ffffc097          	auipc	ra,0xffffc
    80004cea:	fb8080e7          	jalr	-72(ra) # 80000c9e <release>
    kfree((char*)pi);
    80004cee:	8526                	mv	a0,s1
    80004cf0:	ffffc097          	auipc	ra,0xffffc
    80004cf4:	d0e080e7          	jalr	-754(ra) # 800009fe <kfree>
  } else
    release(&pi->lock);
}
    80004cf8:	60e2                	ld	ra,24(sp)
    80004cfa:	6442                	ld	s0,16(sp)
    80004cfc:	64a2                	ld	s1,8(sp)
    80004cfe:	6902                	ld	s2,0(sp)
    80004d00:	6105                	addi	sp,sp,32
    80004d02:	8082                	ret
    pi->readopen = 0;
    80004d04:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004d08:	21c48513          	addi	a0,s1,540
    80004d0c:	ffffd097          	auipc	ra,0xffffd
    80004d10:	54a080e7          	jalr	1354(ra) # 80002256 <wakeup>
    80004d14:	b7e9                	j	80004cde <pipeclose+0x2c>
    release(&pi->lock);
    80004d16:	8526                	mv	a0,s1
    80004d18:	ffffc097          	auipc	ra,0xffffc
    80004d1c:	f86080e7          	jalr	-122(ra) # 80000c9e <release>
}
    80004d20:	bfe1                	j	80004cf8 <pipeclose+0x46>

0000000080004d22 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004d22:	7159                	addi	sp,sp,-112
    80004d24:	f486                	sd	ra,104(sp)
    80004d26:	f0a2                	sd	s0,96(sp)
    80004d28:	eca6                	sd	s1,88(sp)
    80004d2a:	e8ca                	sd	s2,80(sp)
    80004d2c:	e4ce                	sd	s3,72(sp)
    80004d2e:	e0d2                	sd	s4,64(sp)
    80004d30:	fc56                	sd	s5,56(sp)
    80004d32:	f85a                	sd	s6,48(sp)
    80004d34:	f45e                	sd	s7,40(sp)
    80004d36:	f062                	sd	s8,32(sp)
    80004d38:	ec66                	sd	s9,24(sp)
    80004d3a:	1880                	addi	s0,sp,112
    80004d3c:	84aa                	mv	s1,a0
    80004d3e:	8aae                	mv	s5,a1
    80004d40:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004d42:	ffffd097          	auipc	ra,0xffffd
    80004d46:	d8e080e7          	jalr	-626(ra) # 80001ad0 <myproc>
    80004d4a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004d4c:	8526                	mv	a0,s1
    80004d4e:	ffffc097          	auipc	ra,0xffffc
    80004d52:	e9c080e7          	jalr	-356(ra) # 80000bea <acquire>
  while(i < n){
    80004d56:	0d405463          	blez	s4,80004e1e <pipewrite+0xfc>
    80004d5a:	8ba6                	mv	s7,s1
  int i = 0;
    80004d5c:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d5e:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004d60:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004d64:	21c48c13          	addi	s8,s1,540
    80004d68:	a08d                	j	80004dca <pipewrite+0xa8>
      release(&pi->lock);
    80004d6a:	8526                	mv	a0,s1
    80004d6c:	ffffc097          	auipc	ra,0xffffc
    80004d70:	f32080e7          	jalr	-206(ra) # 80000c9e <release>
      return -1;
    80004d74:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004d76:	854a                	mv	a0,s2
    80004d78:	70a6                	ld	ra,104(sp)
    80004d7a:	7406                	ld	s0,96(sp)
    80004d7c:	64e6                	ld	s1,88(sp)
    80004d7e:	6946                	ld	s2,80(sp)
    80004d80:	69a6                	ld	s3,72(sp)
    80004d82:	6a06                	ld	s4,64(sp)
    80004d84:	7ae2                	ld	s5,56(sp)
    80004d86:	7b42                	ld	s6,48(sp)
    80004d88:	7ba2                	ld	s7,40(sp)
    80004d8a:	7c02                	ld	s8,32(sp)
    80004d8c:	6ce2                	ld	s9,24(sp)
    80004d8e:	6165                	addi	sp,sp,112
    80004d90:	8082                	ret
      wakeup(&pi->nread);
    80004d92:	8566                	mv	a0,s9
    80004d94:	ffffd097          	auipc	ra,0xffffd
    80004d98:	4c2080e7          	jalr	1218(ra) # 80002256 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004d9c:	85de                	mv	a1,s7
    80004d9e:	8562                	mv	a0,s8
    80004da0:	ffffd097          	auipc	ra,0xffffd
    80004da4:	448080e7          	jalr	1096(ra) # 800021e8 <sleep>
    80004da8:	a839                	j	80004dc6 <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004daa:	21c4a783          	lw	a5,540(s1)
    80004dae:	0017871b          	addiw	a4,a5,1
    80004db2:	20e4ae23          	sw	a4,540(s1)
    80004db6:	1ff7f793          	andi	a5,a5,511
    80004dba:	97a6                	add	a5,a5,s1
    80004dbc:	f9f44703          	lbu	a4,-97(s0)
    80004dc0:	00e78c23          	sb	a4,24(a5)
      i++;
    80004dc4:	2905                	addiw	s2,s2,1
  while(i < n){
    80004dc6:	05495063          	bge	s2,s4,80004e06 <pipewrite+0xe4>
    if(pi->readopen == 0 || killed(pr)){
    80004dca:	2204a783          	lw	a5,544(s1)
    80004dce:	dfd1                	beqz	a5,80004d6a <pipewrite+0x48>
    80004dd0:	854e                	mv	a0,s3
    80004dd2:	ffffd097          	auipc	ra,0xffffd
    80004dd6:	6e4080e7          	jalr	1764(ra) # 800024b6 <killed>
    80004dda:	f941                	bnez	a0,80004d6a <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004ddc:	2184a783          	lw	a5,536(s1)
    80004de0:	21c4a703          	lw	a4,540(s1)
    80004de4:	2007879b          	addiw	a5,a5,512
    80004de8:	faf705e3          	beq	a4,a5,80004d92 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004dec:	4685                	li	a3,1
    80004dee:	01590633          	add	a2,s2,s5
    80004df2:	f9f40593          	addi	a1,s0,-97
    80004df6:	0589b503          	ld	a0,88(s3)
    80004dfa:	ffffd097          	auipc	ra,0xffffd
    80004dfe:	916080e7          	jalr	-1770(ra) # 80001710 <copyin>
    80004e02:	fb6514e3          	bne	a0,s6,80004daa <pipewrite+0x88>
  wakeup(&pi->nread);
    80004e06:	21848513          	addi	a0,s1,536
    80004e0a:	ffffd097          	auipc	ra,0xffffd
    80004e0e:	44c080e7          	jalr	1100(ra) # 80002256 <wakeup>
  release(&pi->lock);
    80004e12:	8526                	mv	a0,s1
    80004e14:	ffffc097          	auipc	ra,0xffffc
    80004e18:	e8a080e7          	jalr	-374(ra) # 80000c9e <release>
  return i;
    80004e1c:	bfa9                	j	80004d76 <pipewrite+0x54>
  int i = 0;
    80004e1e:	4901                	li	s2,0
    80004e20:	b7dd                	j	80004e06 <pipewrite+0xe4>

0000000080004e22 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004e22:	715d                	addi	sp,sp,-80
    80004e24:	e486                	sd	ra,72(sp)
    80004e26:	e0a2                	sd	s0,64(sp)
    80004e28:	fc26                	sd	s1,56(sp)
    80004e2a:	f84a                	sd	s2,48(sp)
    80004e2c:	f44e                	sd	s3,40(sp)
    80004e2e:	f052                	sd	s4,32(sp)
    80004e30:	ec56                	sd	s5,24(sp)
    80004e32:	e85a                	sd	s6,16(sp)
    80004e34:	0880                	addi	s0,sp,80
    80004e36:	84aa                	mv	s1,a0
    80004e38:	892e                	mv	s2,a1
    80004e3a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004e3c:	ffffd097          	auipc	ra,0xffffd
    80004e40:	c94080e7          	jalr	-876(ra) # 80001ad0 <myproc>
    80004e44:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004e46:	8b26                	mv	s6,s1
    80004e48:	8526                	mv	a0,s1
    80004e4a:	ffffc097          	auipc	ra,0xffffc
    80004e4e:	da0080e7          	jalr	-608(ra) # 80000bea <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e52:	2184a703          	lw	a4,536(s1)
    80004e56:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e5a:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e5e:	02f71763          	bne	a4,a5,80004e8c <piperead+0x6a>
    80004e62:	2244a783          	lw	a5,548(s1)
    80004e66:	c39d                	beqz	a5,80004e8c <piperead+0x6a>
    if(killed(pr)){
    80004e68:	8552                	mv	a0,s4
    80004e6a:	ffffd097          	auipc	ra,0xffffd
    80004e6e:	64c080e7          	jalr	1612(ra) # 800024b6 <killed>
    80004e72:	e941                	bnez	a0,80004f02 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e74:	85da                	mv	a1,s6
    80004e76:	854e                	mv	a0,s3
    80004e78:	ffffd097          	auipc	ra,0xffffd
    80004e7c:	370080e7          	jalr	880(ra) # 800021e8 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e80:	2184a703          	lw	a4,536(s1)
    80004e84:	21c4a783          	lw	a5,540(s1)
    80004e88:	fcf70de3          	beq	a4,a5,80004e62 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e8c:	09505263          	blez	s5,80004f10 <piperead+0xee>
    80004e90:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e92:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004e94:	2184a783          	lw	a5,536(s1)
    80004e98:	21c4a703          	lw	a4,540(s1)
    80004e9c:	02f70d63          	beq	a4,a5,80004ed6 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004ea0:	0017871b          	addiw	a4,a5,1
    80004ea4:	20e4ac23          	sw	a4,536(s1)
    80004ea8:	1ff7f793          	andi	a5,a5,511
    80004eac:	97a6                	add	a5,a5,s1
    80004eae:	0187c783          	lbu	a5,24(a5)
    80004eb2:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004eb6:	4685                	li	a3,1
    80004eb8:	fbf40613          	addi	a2,s0,-65
    80004ebc:	85ca                	mv	a1,s2
    80004ebe:	058a3503          	ld	a0,88(s4)
    80004ec2:	ffffc097          	auipc	ra,0xffffc
    80004ec6:	7c2080e7          	jalr	1986(ra) # 80001684 <copyout>
    80004eca:	01650663          	beq	a0,s6,80004ed6 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ece:	2985                	addiw	s3,s3,1
    80004ed0:	0905                	addi	s2,s2,1
    80004ed2:	fd3a91e3          	bne	s5,s3,80004e94 <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004ed6:	21c48513          	addi	a0,s1,540
    80004eda:	ffffd097          	auipc	ra,0xffffd
    80004ede:	37c080e7          	jalr	892(ra) # 80002256 <wakeup>
  release(&pi->lock);
    80004ee2:	8526                	mv	a0,s1
    80004ee4:	ffffc097          	auipc	ra,0xffffc
    80004ee8:	dba080e7          	jalr	-582(ra) # 80000c9e <release>
  return i;
}
    80004eec:	854e                	mv	a0,s3
    80004eee:	60a6                	ld	ra,72(sp)
    80004ef0:	6406                	ld	s0,64(sp)
    80004ef2:	74e2                	ld	s1,56(sp)
    80004ef4:	7942                	ld	s2,48(sp)
    80004ef6:	79a2                	ld	s3,40(sp)
    80004ef8:	7a02                	ld	s4,32(sp)
    80004efa:	6ae2                	ld	s5,24(sp)
    80004efc:	6b42                	ld	s6,16(sp)
    80004efe:	6161                	addi	sp,sp,80
    80004f00:	8082                	ret
      release(&pi->lock);
    80004f02:	8526                	mv	a0,s1
    80004f04:	ffffc097          	auipc	ra,0xffffc
    80004f08:	d9a080e7          	jalr	-614(ra) # 80000c9e <release>
      return -1;
    80004f0c:	59fd                	li	s3,-1
    80004f0e:	bff9                	j	80004eec <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f10:	4981                	li	s3,0
    80004f12:	b7d1                	j	80004ed6 <piperead+0xb4>

0000000080004f14 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004f14:	1141                	addi	sp,sp,-16
    80004f16:	e422                	sd	s0,8(sp)
    80004f18:	0800                	addi	s0,sp,16
    80004f1a:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004f1c:	8905                	andi	a0,a0,1
    80004f1e:	c111                	beqz	a0,80004f22 <flags2perm+0xe>
      perm = PTE_X;
    80004f20:	4521                	li	a0,8
    if(flags & 0x2)
    80004f22:	8b89                	andi	a5,a5,2
    80004f24:	c399                	beqz	a5,80004f2a <flags2perm+0x16>
      perm |= PTE_W;
    80004f26:	00456513          	ori	a0,a0,4
    return perm;
}
    80004f2a:	6422                	ld	s0,8(sp)
    80004f2c:	0141                	addi	sp,sp,16
    80004f2e:	8082                	ret

0000000080004f30 <exec>:

int
exec(char *path, char **argv)
{
    80004f30:	df010113          	addi	sp,sp,-528
    80004f34:	20113423          	sd	ra,520(sp)
    80004f38:	20813023          	sd	s0,512(sp)
    80004f3c:	ffa6                	sd	s1,504(sp)
    80004f3e:	fbca                	sd	s2,496(sp)
    80004f40:	f7ce                	sd	s3,488(sp)
    80004f42:	f3d2                	sd	s4,480(sp)
    80004f44:	efd6                	sd	s5,472(sp)
    80004f46:	ebda                	sd	s6,464(sp)
    80004f48:	e7de                	sd	s7,456(sp)
    80004f4a:	e3e2                	sd	s8,448(sp)
    80004f4c:	ff66                	sd	s9,440(sp)
    80004f4e:	fb6a                	sd	s10,432(sp)
    80004f50:	f76e                	sd	s11,424(sp)
    80004f52:	0c00                	addi	s0,sp,528
    80004f54:	84aa                	mv	s1,a0
    80004f56:	dea43c23          	sd	a0,-520(s0)
    80004f5a:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004f5e:	ffffd097          	auipc	ra,0xffffd
    80004f62:	b72080e7          	jalr	-1166(ra) # 80001ad0 <myproc>
    80004f66:	892a                	mv	s2,a0

  begin_op();
    80004f68:	fffff097          	auipc	ra,0xfffff
    80004f6c:	474080e7          	jalr	1140(ra) # 800043dc <begin_op>

  if((ip = namei(path)) == 0){
    80004f70:	8526                	mv	a0,s1
    80004f72:	fffff097          	auipc	ra,0xfffff
    80004f76:	24e080e7          	jalr	590(ra) # 800041c0 <namei>
    80004f7a:	c92d                	beqz	a0,80004fec <exec+0xbc>
    80004f7c:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004f7e:	fffff097          	auipc	ra,0xfffff
    80004f82:	a9c080e7          	jalr	-1380(ra) # 80003a1a <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004f86:	04000713          	li	a4,64
    80004f8a:	4681                	li	a3,0
    80004f8c:	e5040613          	addi	a2,s0,-432
    80004f90:	4581                	li	a1,0
    80004f92:	8526                	mv	a0,s1
    80004f94:	fffff097          	auipc	ra,0xfffff
    80004f98:	d3a080e7          	jalr	-710(ra) # 80003cce <readi>
    80004f9c:	04000793          	li	a5,64
    80004fa0:	00f51a63          	bne	a0,a5,80004fb4 <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004fa4:	e5042703          	lw	a4,-432(s0)
    80004fa8:	464c47b7          	lui	a5,0x464c4
    80004fac:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004fb0:	04f70463          	beq	a4,a5,80004ff8 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004fb4:	8526                	mv	a0,s1
    80004fb6:	fffff097          	auipc	ra,0xfffff
    80004fba:	cc6080e7          	jalr	-826(ra) # 80003c7c <iunlockput>
    end_op();
    80004fbe:	fffff097          	auipc	ra,0xfffff
    80004fc2:	49e080e7          	jalr	1182(ra) # 8000445c <end_op>
  }
  return -1;
    80004fc6:	557d                	li	a0,-1
}
    80004fc8:	20813083          	ld	ra,520(sp)
    80004fcc:	20013403          	ld	s0,512(sp)
    80004fd0:	74fe                	ld	s1,504(sp)
    80004fd2:	795e                	ld	s2,496(sp)
    80004fd4:	79be                	ld	s3,488(sp)
    80004fd6:	7a1e                	ld	s4,480(sp)
    80004fd8:	6afe                	ld	s5,472(sp)
    80004fda:	6b5e                	ld	s6,464(sp)
    80004fdc:	6bbe                	ld	s7,456(sp)
    80004fde:	6c1e                	ld	s8,448(sp)
    80004fe0:	7cfa                	ld	s9,440(sp)
    80004fe2:	7d5a                	ld	s10,432(sp)
    80004fe4:	7dba                	ld	s11,424(sp)
    80004fe6:	21010113          	addi	sp,sp,528
    80004fea:	8082                	ret
    end_op();
    80004fec:	fffff097          	auipc	ra,0xfffff
    80004ff0:	470080e7          	jalr	1136(ra) # 8000445c <end_op>
    return -1;
    80004ff4:	557d                	li	a0,-1
    80004ff6:	bfc9                	j	80004fc8 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004ff8:	854a                	mv	a0,s2
    80004ffa:	ffffd097          	auipc	ra,0xffffd
    80004ffe:	b9c080e7          	jalr	-1124(ra) # 80001b96 <proc_pagetable>
    80005002:	8baa                	mv	s7,a0
    80005004:	d945                	beqz	a0,80004fb4 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005006:	e7042983          	lw	s3,-400(s0)
    8000500a:	e8845783          	lhu	a5,-376(s0)
    8000500e:	c7ad                	beqz	a5,80005078 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005010:	4a01                	li	s4,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005012:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80005014:	6c85                	lui	s9,0x1
    80005016:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000501a:	def43823          	sd	a5,-528(s0)
    8000501e:	ac0d                	j	80005250 <exec+0x320>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005020:	00003517          	auipc	a0,0x3
    80005024:	7e850513          	addi	a0,a0,2024 # 80008808 <syscalls+0x298>
    80005028:	ffffb097          	auipc	ra,0xffffb
    8000502c:	51c080e7          	jalr	1308(ra) # 80000544 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005030:	8756                	mv	a4,s5
    80005032:	012d86bb          	addw	a3,s11,s2
    80005036:	4581                	li	a1,0
    80005038:	8526                	mv	a0,s1
    8000503a:	fffff097          	auipc	ra,0xfffff
    8000503e:	c94080e7          	jalr	-876(ra) # 80003cce <readi>
    80005042:	2501                	sext.w	a0,a0
    80005044:	1aaa9a63          	bne	s5,a0,800051f8 <exec+0x2c8>
  for(i = 0; i < sz; i += PGSIZE){
    80005048:	6785                	lui	a5,0x1
    8000504a:	0127893b          	addw	s2,a5,s2
    8000504e:	77fd                	lui	a5,0xfffff
    80005050:	01478a3b          	addw	s4,a5,s4
    80005054:	1f897563          	bgeu	s2,s8,8000523e <exec+0x30e>
    pa = walkaddr(pagetable, va + i);
    80005058:	02091593          	slli	a1,s2,0x20
    8000505c:	9181                	srli	a1,a1,0x20
    8000505e:	95ea                	add	a1,a1,s10
    80005060:	855e                	mv	a0,s7
    80005062:	ffffc097          	auipc	ra,0xffffc
    80005066:	016080e7          	jalr	22(ra) # 80001078 <walkaddr>
    8000506a:	862a                	mv	a2,a0
    if(pa == 0)
    8000506c:	d955                	beqz	a0,80005020 <exec+0xf0>
      n = PGSIZE;
    8000506e:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80005070:	fd9a70e3          	bgeu	s4,s9,80005030 <exec+0x100>
      n = sz - i;
    80005074:	8ad2                	mv	s5,s4
    80005076:	bf6d                	j	80005030 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005078:	4a01                	li	s4,0
  iunlockput(ip);
    8000507a:	8526                	mv	a0,s1
    8000507c:	fffff097          	auipc	ra,0xfffff
    80005080:	c00080e7          	jalr	-1024(ra) # 80003c7c <iunlockput>
  end_op();
    80005084:	fffff097          	auipc	ra,0xfffff
    80005088:	3d8080e7          	jalr	984(ra) # 8000445c <end_op>
  p = myproc();
    8000508c:	ffffd097          	auipc	ra,0xffffd
    80005090:	a44080e7          	jalr	-1468(ra) # 80001ad0 <myproc>
    80005094:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005096:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    8000509a:	6785                	lui	a5,0x1
    8000509c:	17fd                	addi	a5,a5,-1
    8000509e:	9a3e                	add	s4,s4,a5
    800050a0:	757d                	lui	a0,0xfffff
    800050a2:	00aa77b3          	and	a5,s4,a0
    800050a6:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800050aa:	4691                	li	a3,4
    800050ac:	6609                	lui	a2,0x2
    800050ae:	963e                	add	a2,a2,a5
    800050b0:	85be                	mv	a1,a5
    800050b2:	855e                	mv	a0,s7
    800050b4:	ffffc097          	auipc	ra,0xffffc
    800050b8:	378080e7          	jalr	888(ra) # 8000142c <uvmalloc>
    800050bc:	8b2a                	mv	s6,a0
  ip = 0;
    800050be:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800050c0:	12050c63          	beqz	a0,800051f8 <exec+0x2c8>
  uvmclear(pagetable, sz-2*PGSIZE);
    800050c4:	75f9                	lui	a1,0xffffe
    800050c6:	95aa                	add	a1,a1,a0
    800050c8:	855e                	mv	a0,s7
    800050ca:	ffffc097          	auipc	ra,0xffffc
    800050ce:	588080e7          	jalr	1416(ra) # 80001652 <uvmclear>
  stackbase = sp - PGSIZE;
    800050d2:	7c7d                	lui	s8,0xfffff
    800050d4:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    800050d6:	e0043783          	ld	a5,-512(s0)
    800050da:	6388                	ld	a0,0(a5)
    800050dc:	c535                	beqz	a0,80005148 <exec+0x218>
    800050de:	e9040993          	addi	s3,s0,-368
    800050e2:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800050e6:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    800050e8:	ffffc097          	auipc	ra,0xffffc
    800050ec:	d82080e7          	jalr	-638(ra) # 80000e6a <strlen>
    800050f0:	2505                	addiw	a0,a0,1
    800050f2:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800050f6:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800050fa:	13896663          	bltu	s2,s8,80005226 <exec+0x2f6>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800050fe:	e0043d83          	ld	s11,-512(s0)
    80005102:	000dba03          	ld	s4,0(s11)
    80005106:	8552                	mv	a0,s4
    80005108:	ffffc097          	auipc	ra,0xffffc
    8000510c:	d62080e7          	jalr	-670(ra) # 80000e6a <strlen>
    80005110:	0015069b          	addiw	a3,a0,1
    80005114:	8652                	mv	a2,s4
    80005116:	85ca                	mv	a1,s2
    80005118:	855e                	mv	a0,s7
    8000511a:	ffffc097          	auipc	ra,0xffffc
    8000511e:	56a080e7          	jalr	1386(ra) # 80001684 <copyout>
    80005122:	10054663          	bltz	a0,8000522e <exec+0x2fe>
    ustack[argc] = sp;
    80005126:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000512a:	0485                	addi	s1,s1,1
    8000512c:	008d8793          	addi	a5,s11,8
    80005130:	e0f43023          	sd	a5,-512(s0)
    80005134:	008db503          	ld	a0,8(s11)
    80005138:	c911                	beqz	a0,8000514c <exec+0x21c>
    if(argc >= MAXARG)
    8000513a:	09a1                	addi	s3,s3,8
    8000513c:	fb3c96e3          	bne	s9,s3,800050e8 <exec+0x1b8>
  sz = sz1;
    80005140:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005144:	4481                	li	s1,0
    80005146:	a84d                	j	800051f8 <exec+0x2c8>
  sp = sz;
    80005148:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    8000514a:	4481                	li	s1,0
  ustack[argc] = 0;
    8000514c:	00349793          	slli	a5,s1,0x3
    80005150:	f9040713          	addi	a4,s0,-112
    80005154:	97ba                	add	a5,a5,a4
    80005156:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    8000515a:	00148693          	addi	a3,s1,1
    8000515e:	068e                	slli	a3,a3,0x3
    80005160:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005164:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005168:	01897663          	bgeu	s2,s8,80005174 <exec+0x244>
  sz = sz1;
    8000516c:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005170:	4481                	li	s1,0
    80005172:	a059                	j	800051f8 <exec+0x2c8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005174:	e9040613          	addi	a2,s0,-368
    80005178:	85ca                	mv	a1,s2
    8000517a:	855e                	mv	a0,s7
    8000517c:	ffffc097          	auipc	ra,0xffffc
    80005180:	508080e7          	jalr	1288(ra) # 80001684 <copyout>
    80005184:	0a054963          	bltz	a0,80005236 <exec+0x306>
  p->trapframe->a1 = sp;
    80005188:	060ab783          	ld	a5,96(s5)
    8000518c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005190:	df843783          	ld	a5,-520(s0)
    80005194:	0007c703          	lbu	a4,0(a5)
    80005198:	cf11                	beqz	a4,800051b4 <exec+0x284>
    8000519a:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000519c:	02f00693          	li	a3,47
    800051a0:	a039                	j	800051ae <exec+0x27e>
      last = s+1;
    800051a2:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800051a6:	0785                	addi	a5,a5,1
    800051a8:	fff7c703          	lbu	a4,-1(a5)
    800051ac:	c701                	beqz	a4,800051b4 <exec+0x284>
    if(*s == '/')
    800051ae:	fed71ce3          	bne	a4,a3,800051a6 <exec+0x276>
    800051b2:	bfc5                	j	800051a2 <exec+0x272>
  safestrcpy(p->name, last, sizeof(p->name));
    800051b4:	4641                	li	a2,16
    800051b6:	df843583          	ld	a1,-520(s0)
    800051ba:	160a8513          	addi	a0,s5,352
    800051be:	ffffc097          	auipc	ra,0xffffc
    800051c2:	c7a080e7          	jalr	-902(ra) # 80000e38 <safestrcpy>
  oldpagetable = p->pagetable;
    800051c6:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    800051ca:	057abc23          	sd	s7,88(s5)
  p->sz = sz;
    800051ce:	056ab823          	sd	s6,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800051d2:	060ab783          	ld	a5,96(s5)
    800051d6:	e6843703          	ld	a4,-408(s0)
    800051da:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800051dc:	060ab783          	ld	a5,96(s5)
    800051e0:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800051e4:	85ea                	mv	a1,s10
    800051e6:	ffffd097          	auipc	ra,0xffffd
    800051ea:	a4c080e7          	jalr	-1460(ra) # 80001c32 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800051ee:	0004851b          	sext.w	a0,s1
    800051f2:	bbd9                	j	80004fc8 <exec+0x98>
    800051f4:	e1443423          	sd	s4,-504(s0)
    proc_freepagetable(pagetable, sz);
    800051f8:	e0843583          	ld	a1,-504(s0)
    800051fc:	855e                	mv	a0,s7
    800051fe:	ffffd097          	auipc	ra,0xffffd
    80005202:	a34080e7          	jalr	-1484(ra) # 80001c32 <proc_freepagetable>
  if(ip){
    80005206:	da0497e3          	bnez	s1,80004fb4 <exec+0x84>
  return -1;
    8000520a:	557d                	li	a0,-1
    8000520c:	bb75                	j	80004fc8 <exec+0x98>
    8000520e:	e1443423          	sd	s4,-504(s0)
    80005212:	b7dd                	j	800051f8 <exec+0x2c8>
    80005214:	e1443423          	sd	s4,-504(s0)
    80005218:	b7c5                	j	800051f8 <exec+0x2c8>
    8000521a:	e1443423          	sd	s4,-504(s0)
    8000521e:	bfe9                	j	800051f8 <exec+0x2c8>
    80005220:	e1443423          	sd	s4,-504(s0)
    80005224:	bfd1                	j	800051f8 <exec+0x2c8>
  sz = sz1;
    80005226:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000522a:	4481                	li	s1,0
    8000522c:	b7f1                	j	800051f8 <exec+0x2c8>
  sz = sz1;
    8000522e:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005232:	4481                	li	s1,0
    80005234:	b7d1                	j	800051f8 <exec+0x2c8>
  sz = sz1;
    80005236:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000523a:	4481                	li	s1,0
    8000523c:	bf75                	j	800051f8 <exec+0x2c8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000523e:	e0843a03          	ld	s4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005242:	2b05                	addiw	s6,s6,1
    80005244:	0389899b          	addiw	s3,s3,56
    80005248:	e8845783          	lhu	a5,-376(s0)
    8000524c:	e2fb57e3          	bge	s6,a5,8000507a <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005250:	2981                	sext.w	s3,s3
    80005252:	03800713          	li	a4,56
    80005256:	86ce                	mv	a3,s3
    80005258:	e1840613          	addi	a2,s0,-488
    8000525c:	4581                	li	a1,0
    8000525e:	8526                	mv	a0,s1
    80005260:	fffff097          	auipc	ra,0xfffff
    80005264:	a6e080e7          	jalr	-1426(ra) # 80003cce <readi>
    80005268:	03800793          	li	a5,56
    8000526c:	f8f514e3          	bne	a0,a5,800051f4 <exec+0x2c4>
    if(ph.type != ELF_PROG_LOAD)
    80005270:	e1842783          	lw	a5,-488(s0)
    80005274:	4705                	li	a4,1
    80005276:	fce796e3          	bne	a5,a4,80005242 <exec+0x312>
    if(ph.memsz < ph.filesz)
    8000527a:	e4043903          	ld	s2,-448(s0)
    8000527e:	e3843783          	ld	a5,-456(s0)
    80005282:	f8f966e3          	bltu	s2,a5,8000520e <exec+0x2de>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005286:	e2843783          	ld	a5,-472(s0)
    8000528a:	993e                	add	s2,s2,a5
    8000528c:	f8f964e3          	bltu	s2,a5,80005214 <exec+0x2e4>
    if(ph.vaddr % PGSIZE != 0)
    80005290:	df043703          	ld	a4,-528(s0)
    80005294:	8ff9                	and	a5,a5,a4
    80005296:	f3d1                	bnez	a5,8000521a <exec+0x2ea>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005298:	e1c42503          	lw	a0,-484(s0)
    8000529c:	00000097          	auipc	ra,0x0
    800052a0:	c78080e7          	jalr	-904(ra) # 80004f14 <flags2perm>
    800052a4:	86aa                	mv	a3,a0
    800052a6:	864a                	mv	a2,s2
    800052a8:	85d2                	mv	a1,s4
    800052aa:	855e                	mv	a0,s7
    800052ac:	ffffc097          	auipc	ra,0xffffc
    800052b0:	180080e7          	jalr	384(ra) # 8000142c <uvmalloc>
    800052b4:	e0a43423          	sd	a0,-504(s0)
    800052b8:	d525                	beqz	a0,80005220 <exec+0x2f0>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800052ba:	e2843d03          	ld	s10,-472(s0)
    800052be:	e2042d83          	lw	s11,-480(s0)
    800052c2:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800052c6:	f60c0ce3          	beqz	s8,8000523e <exec+0x30e>
    800052ca:	8a62                	mv	s4,s8
    800052cc:	4901                	li	s2,0
    800052ce:	b369                	j	80005058 <exec+0x128>

00000000800052d0 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800052d0:	7179                	addi	sp,sp,-48
    800052d2:	f406                	sd	ra,40(sp)
    800052d4:	f022                	sd	s0,32(sp)
    800052d6:	ec26                	sd	s1,24(sp)
    800052d8:	e84a                	sd	s2,16(sp)
    800052da:	1800                	addi	s0,sp,48
    800052dc:	892e                	mv	s2,a1
    800052de:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800052e0:	fdc40593          	addi	a1,s0,-36
    800052e4:	ffffe097          	auipc	ra,0xffffe
    800052e8:	9b0080e7          	jalr	-1616(ra) # 80002c94 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800052ec:	fdc42703          	lw	a4,-36(s0)
    800052f0:	47bd                	li	a5,15
    800052f2:	02e7eb63          	bltu	a5,a4,80005328 <argfd+0x58>
    800052f6:	ffffc097          	auipc	ra,0xffffc
    800052fa:	7da080e7          	jalr	2010(ra) # 80001ad0 <myproc>
    800052fe:	fdc42703          	lw	a4,-36(s0)
    80005302:	01a70793          	addi	a5,a4,26
    80005306:	078e                	slli	a5,a5,0x3
    80005308:	953e                	add	a0,a0,a5
    8000530a:	651c                	ld	a5,8(a0)
    8000530c:	c385                	beqz	a5,8000532c <argfd+0x5c>
    return -1;
  if(pfd)
    8000530e:	00090463          	beqz	s2,80005316 <argfd+0x46>
    *pfd = fd;
    80005312:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005316:	4501                	li	a0,0
  if(pf)
    80005318:	c091                	beqz	s1,8000531c <argfd+0x4c>
    *pf = f;
    8000531a:	e09c                	sd	a5,0(s1)
}
    8000531c:	70a2                	ld	ra,40(sp)
    8000531e:	7402                	ld	s0,32(sp)
    80005320:	64e2                	ld	s1,24(sp)
    80005322:	6942                	ld	s2,16(sp)
    80005324:	6145                	addi	sp,sp,48
    80005326:	8082                	ret
    return -1;
    80005328:	557d                	li	a0,-1
    8000532a:	bfcd                	j	8000531c <argfd+0x4c>
    8000532c:	557d                	li	a0,-1
    8000532e:	b7fd                	j	8000531c <argfd+0x4c>

0000000080005330 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005330:	1101                	addi	sp,sp,-32
    80005332:	ec06                	sd	ra,24(sp)
    80005334:	e822                	sd	s0,16(sp)
    80005336:	e426                	sd	s1,8(sp)
    80005338:	1000                	addi	s0,sp,32
    8000533a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000533c:	ffffc097          	auipc	ra,0xffffc
    80005340:	794080e7          	jalr	1940(ra) # 80001ad0 <myproc>
    80005344:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005346:	0d850793          	addi	a5,a0,216 # fffffffffffff0d8 <end+0xffffffff7ffdb6a8>
    8000534a:	4501                	li	a0,0
    8000534c:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000534e:	6398                	ld	a4,0(a5)
    80005350:	cb19                	beqz	a4,80005366 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005352:	2505                	addiw	a0,a0,1
    80005354:	07a1                	addi	a5,a5,8
    80005356:	fed51ce3          	bne	a0,a3,8000534e <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000535a:	557d                	li	a0,-1
}
    8000535c:	60e2                	ld	ra,24(sp)
    8000535e:	6442                	ld	s0,16(sp)
    80005360:	64a2                	ld	s1,8(sp)
    80005362:	6105                	addi	sp,sp,32
    80005364:	8082                	ret
      p->ofile[fd] = f;
    80005366:	01a50793          	addi	a5,a0,26
    8000536a:	078e                	slli	a5,a5,0x3
    8000536c:	963e                	add	a2,a2,a5
    8000536e:	e604                	sd	s1,8(a2)
      return fd;
    80005370:	b7f5                	j	8000535c <fdalloc+0x2c>

0000000080005372 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005372:	715d                	addi	sp,sp,-80
    80005374:	e486                	sd	ra,72(sp)
    80005376:	e0a2                	sd	s0,64(sp)
    80005378:	fc26                	sd	s1,56(sp)
    8000537a:	f84a                	sd	s2,48(sp)
    8000537c:	f44e                	sd	s3,40(sp)
    8000537e:	f052                	sd	s4,32(sp)
    80005380:	ec56                	sd	s5,24(sp)
    80005382:	e85a                	sd	s6,16(sp)
    80005384:	0880                	addi	s0,sp,80
    80005386:	8b2e                	mv	s6,a1
    80005388:	89b2                	mv	s3,a2
    8000538a:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000538c:	fb040593          	addi	a1,s0,-80
    80005390:	fffff097          	auipc	ra,0xfffff
    80005394:	e4e080e7          	jalr	-434(ra) # 800041de <nameiparent>
    80005398:	84aa                	mv	s1,a0
    8000539a:	16050063          	beqz	a0,800054fa <create+0x188>
    return 0;

  ilock(dp);
    8000539e:	ffffe097          	auipc	ra,0xffffe
    800053a2:	67c080e7          	jalr	1660(ra) # 80003a1a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800053a6:	4601                	li	a2,0
    800053a8:	fb040593          	addi	a1,s0,-80
    800053ac:	8526                	mv	a0,s1
    800053ae:	fffff097          	auipc	ra,0xfffff
    800053b2:	b50080e7          	jalr	-1200(ra) # 80003efe <dirlookup>
    800053b6:	8aaa                	mv	s5,a0
    800053b8:	c931                	beqz	a0,8000540c <create+0x9a>
    iunlockput(dp);
    800053ba:	8526                	mv	a0,s1
    800053bc:	fffff097          	auipc	ra,0xfffff
    800053c0:	8c0080e7          	jalr	-1856(ra) # 80003c7c <iunlockput>
    ilock(ip);
    800053c4:	8556                	mv	a0,s5
    800053c6:	ffffe097          	auipc	ra,0xffffe
    800053ca:	654080e7          	jalr	1620(ra) # 80003a1a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800053ce:	000b059b          	sext.w	a1,s6
    800053d2:	4789                	li	a5,2
    800053d4:	02f59563          	bne	a1,a5,800053fe <create+0x8c>
    800053d8:	044ad783          	lhu	a5,68(s5)
    800053dc:	37f9                	addiw	a5,a5,-2
    800053de:	17c2                	slli	a5,a5,0x30
    800053e0:	93c1                	srli	a5,a5,0x30
    800053e2:	4705                	li	a4,1
    800053e4:	00f76d63          	bltu	a4,a5,800053fe <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800053e8:	8556                	mv	a0,s5
    800053ea:	60a6                	ld	ra,72(sp)
    800053ec:	6406                	ld	s0,64(sp)
    800053ee:	74e2                	ld	s1,56(sp)
    800053f0:	7942                	ld	s2,48(sp)
    800053f2:	79a2                	ld	s3,40(sp)
    800053f4:	7a02                	ld	s4,32(sp)
    800053f6:	6ae2                	ld	s5,24(sp)
    800053f8:	6b42                	ld	s6,16(sp)
    800053fa:	6161                	addi	sp,sp,80
    800053fc:	8082                	ret
    iunlockput(ip);
    800053fe:	8556                	mv	a0,s5
    80005400:	fffff097          	auipc	ra,0xfffff
    80005404:	87c080e7          	jalr	-1924(ra) # 80003c7c <iunlockput>
    return 0;
    80005408:	4a81                	li	s5,0
    8000540a:	bff9                	j	800053e8 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000540c:	85da                	mv	a1,s6
    8000540e:	4088                	lw	a0,0(s1)
    80005410:	ffffe097          	auipc	ra,0xffffe
    80005414:	46e080e7          	jalr	1134(ra) # 8000387e <ialloc>
    80005418:	8a2a                	mv	s4,a0
    8000541a:	c921                	beqz	a0,8000546a <create+0xf8>
  ilock(ip);
    8000541c:	ffffe097          	auipc	ra,0xffffe
    80005420:	5fe080e7          	jalr	1534(ra) # 80003a1a <ilock>
  ip->major = major;
    80005424:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005428:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000542c:	4785                	li	a5,1
    8000542e:	04fa1523          	sh	a5,74(s4)
  iupdate(ip);
    80005432:	8552                	mv	a0,s4
    80005434:	ffffe097          	auipc	ra,0xffffe
    80005438:	51c080e7          	jalr	1308(ra) # 80003950 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000543c:	000b059b          	sext.w	a1,s6
    80005440:	4785                	li	a5,1
    80005442:	02f58b63          	beq	a1,a5,80005478 <create+0x106>
  if(dirlink(dp, name, ip->inum) < 0)
    80005446:	004a2603          	lw	a2,4(s4)
    8000544a:	fb040593          	addi	a1,s0,-80
    8000544e:	8526                	mv	a0,s1
    80005450:	fffff097          	auipc	ra,0xfffff
    80005454:	cbe080e7          	jalr	-834(ra) # 8000410e <dirlink>
    80005458:	06054f63          	bltz	a0,800054d6 <create+0x164>
  iunlockput(dp);
    8000545c:	8526                	mv	a0,s1
    8000545e:	fffff097          	auipc	ra,0xfffff
    80005462:	81e080e7          	jalr	-2018(ra) # 80003c7c <iunlockput>
  return ip;
    80005466:	8ad2                	mv	s5,s4
    80005468:	b741                	j	800053e8 <create+0x76>
    iunlockput(dp);
    8000546a:	8526                	mv	a0,s1
    8000546c:	fffff097          	auipc	ra,0xfffff
    80005470:	810080e7          	jalr	-2032(ra) # 80003c7c <iunlockput>
    return 0;
    80005474:	8ad2                	mv	s5,s4
    80005476:	bf8d                	j	800053e8 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005478:	004a2603          	lw	a2,4(s4)
    8000547c:	00003597          	auipc	a1,0x3
    80005480:	3ac58593          	addi	a1,a1,940 # 80008828 <syscalls+0x2b8>
    80005484:	8552                	mv	a0,s4
    80005486:	fffff097          	auipc	ra,0xfffff
    8000548a:	c88080e7          	jalr	-888(ra) # 8000410e <dirlink>
    8000548e:	04054463          	bltz	a0,800054d6 <create+0x164>
    80005492:	40d0                	lw	a2,4(s1)
    80005494:	00003597          	auipc	a1,0x3
    80005498:	39c58593          	addi	a1,a1,924 # 80008830 <syscalls+0x2c0>
    8000549c:	8552                	mv	a0,s4
    8000549e:	fffff097          	auipc	ra,0xfffff
    800054a2:	c70080e7          	jalr	-912(ra) # 8000410e <dirlink>
    800054a6:	02054863          	bltz	a0,800054d6 <create+0x164>
  if(dirlink(dp, name, ip->inum) < 0)
    800054aa:	004a2603          	lw	a2,4(s4)
    800054ae:	fb040593          	addi	a1,s0,-80
    800054b2:	8526                	mv	a0,s1
    800054b4:	fffff097          	auipc	ra,0xfffff
    800054b8:	c5a080e7          	jalr	-934(ra) # 8000410e <dirlink>
    800054bc:	00054d63          	bltz	a0,800054d6 <create+0x164>
    dp->nlink++;  // for ".."
    800054c0:	04a4d783          	lhu	a5,74(s1)
    800054c4:	2785                	addiw	a5,a5,1
    800054c6:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800054ca:	8526                	mv	a0,s1
    800054cc:	ffffe097          	auipc	ra,0xffffe
    800054d0:	484080e7          	jalr	1156(ra) # 80003950 <iupdate>
    800054d4:	b761                	j	8000545c <create+0xea>
  ip->nlink = 0;
    800054d6:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800054da:	8552                	mv	a0,s4
    800054dc:	ffffe097          	auipc	ra,0xffffe
    800054e0:	474080e7          	jalr	1140(ra) # 80003950 <iupdate>
  iunlockput(ip);
    800054e4:	8552                	mv	a0,s4
    800054e6:	ffffe097          	auipc	ra,0xffffe
    800054ea:	796080e7          	jalr	1942(ra) # 80003c7c <iunlockput>
  iunlockput(dp);
    800054ee:	8526                	mv	a0,s1
    800054f0:	ffffe097          	auipc	ra,0xffffe
    800054f4:	78c080e7          	jalr	1932(ra) # 80003c7c <iunlockput>
  return 0;
    800054f8:	bdc5                	j	800053e8 <create+0x76>
    return 0;
    800054fa:	8aaa                	mv	s5,a0
    800054fc:	b5f5                	j	800053e8 <create+0x76>

00000000800054fe <sys_dup>:
{
    800054fe:	7179                	addi	sp,sp,-48
    80005500:	f406                	sd	ra,40(sp)
    80005502:	f022                	sd	s0,32(sp)
    80005504:	ec26                	sd	s1,24(sp)
    80005506:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005508:	fd840613          	addi	a2,s0,-40
    8000550c:	4581                	li	a1,0
    8000550e:	4501                	li	a0,0
    80005510:	00000097          	auipc	ra,0x0
    80005514:	dc0080e7          	jalr	-576(ra) # 800052d0 <argfd>
    return -1;
    80005518:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000551a:	02054363          	bltz	a0,80005540 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000551e:	fd843503          	ld	a0,-40(s0)
    80005522:	00000097          	auipc	ra,0x0
    80005526:	e0e080e7          	jalr	-498(ra) # 80005330 <fdalloc>
    8000552a:	84aa                	mv	s1,a0
    return -1;
    8000552c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000552e:	00054963          	bltz	a0,80005540 <sys_dup+0x42>
  filedup(f);
    80005532:	fd843503          	ld	a0,-40(s0)
    80005536:	fffff097          	auipc	ra,0xfffff
    8000553a:	320080e7          	jalr	800(ra) # 80004856 <filedup>
  return fd;
    8000553e:	87a6                	mv	a5,s1
}
    80005540:	853e                	mv	a0,a5
    80005542:	70a2                	ld	ra,40(sp)
    80005544:	7402                	ld	s0,32(sp)
    80005546:	64e2                	ld	s1,24(sp)
    80005548:	6145                	addi	sp,sp,48
    8000554a:	8082                	ret

000000008000554c <sys_read>:
{
    8000554c:	7179                	addi	sp,sp,-48
    8000554e:	f406                	sd	ra,40(sp)
    80005550:	f022                	sd	s0,32(sp)
    80005552:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005554:	fd840593          	addi	a1,s0,-40
    80005558:	4505                	li	a0,1
    8000555a:	ffffd097          	auipc	ra,0xffffd
    8000555e:	75a080e7          	jalr	1882(ra) # 80002cb4 <argaddr>
  argint(2, &n);
    80005562:	fe440593          	addi	a1,s0,-28
    80005566:	4509                	li	a0,2
    80005568:	ffffd097          	auipc	ra,0xffffd
    8000556c:	72c080e7          	jalr	1836(ra) # 80002c94 <argint>
  if(argfd(0, 0, &f) < 0)
    80005570:	fe840613          	addi	a2,s0,-24
    80005574:	4581                	li	a1,0
    80005576:	4501                	li	a0,0
    80005578:	00000097          	auipc	ra,0x0
    8000557c:	d58080e7          	jalr	-680(ra) # 800052d0 <argfd>
    80005580:	87aa                	mv	a5,a0
    return -1;
    80005582:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005584:	0007cc63          	bltz	a5,8000559c <sys_read+0x50>
  return fileread(f, p, n);
    80005588:	fe442603          	lw	a2,-28(s0)
    8000558c:	fd843583          	ld	a1,-40(s0)
    80005590:	fe843503          	ld	a0,-24(s0)
    80005594:	fffff097          	auipc	ra,0xfffff
    80005598:	44e080e7          	jalr	1102(ra) # 800049e2 <fileread>
}
    8000559c:	70a2                	ld	ra,40(sp)
    8000559e:	7402                	ld	s0,32(sp)
    800055a0:	6145                	addi	sp,sp,48
    800055a2:	8082                	ret

00000000800055a4 <sys_write>:
{
    800055a4:	7179                	addi	sp,sp,-48
    800055a6:	f406                	sd	ra,40(sp)
    800055a8:	f022                	sd	s0,32(sp)
    800055aa:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800055ac:	fd840593          	addi	a1,s0,-40
    800055b0:	4505                	li	a0,1
    800055b2:	ffffd097          	auipc	ra,0xffffd
    800055b6:	702080e7          	jalr	1794(ra) # 80002cb4 <argaddr>
  argint(2, &n);
    800055ba:	fe440593          	addi	a1,s0,-28
    800055be:	4509                	li	a0,2
    800055c0:	ffffd097          	auipc	ra,0xffffd
    800055c4:	6d4080e7          	jalr	1748(ra) # 80002c94 <argint>
  if(argfd(0, 0, &f) < 0)
    800055c8:	fe840613          	addi	a2,s0,-24
    800055cc:	4581                	li	a1,0
    800055ce:	4501                	li	a0,0
    800055d0:	00000097          	auipc	ra,0x0
    800055d4:	d00080e7          	jalr	-768(ra) # 800052d0 <argfd>
    800055d8:	87aa                	mv	a5,a0
    return -1;
    800055da:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800055dc:	0007cc63          	bltz	a5,800055f4 <sys_write+0x50>
  return filewrite(f, p, n);
    800055e0:	fe442603          	lw	a2,-28(s0)
    800055e4:	fd843583          	ld	a1,-40(s0)
    800055e8:	fe843503          	ld	a0,-24(s0)
    800055ec:	fffff097          	auipc	ra,0xfffff
    800055f0:	4b8080e7          	jalr	1208(ra) # 80004aa4 <filewrite>
}
    800055f4:	70a2                	ld	ra,40(sp)
    800055f6:	7402                	ld	s0,32(sp)
    800055f8:	6145                	addi	sp,sp,48
    800055fa:	8082                	ret

00000000800055fc <sys_close>:
{
    800055fc:	1101                	addi	sp,sp,-32
    800055fe:	ec06                	sd	ra,24(sp)
    80005600:	e822                	sd	s0,16(sp)
    80005602:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005604:	fe040613          	addi	a2,s0,-32
    80005608:	fec40593          	addi	a1,s0,-20
    8000560c:	4501                	li	a0,0
    8000560e:	00000097          	auipc	ra,0x0
    80005612:	cc2080e7          	jalr	-830(ra) # 800052d0 <argfd>
    return -1;
    80005616:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005618:	02054463          	bltz	a0,80005640 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000561c:	ffffc097          	auipc	ra,0xffffc
    80005620:	4b4080e7          	jalr	1204(ra) # 80001ad0 <myproc>
    80005624:	fec42783          	lw	a5,-20(s0)
    80005628:	07e9                	addi	a5,a5,26
    8000562a:	078e                	slli	a5,a5,0x3
    8000562c:	97aa                	add	a5,a5,a0
    8000562e:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    80005632:	fe043503          	ld	a0,-32(s0)
    80005636:	fffff097          	auipc	ra,0xfffff
    8000563a:	272080e7          	jalr	626(ra) # 800048a8 <fileclose>
  return 0;
    8000563e:	4781                	li	a5,0
}
    80005640:	853e                	mv	a0,a5
    80005642:	60e2                	ld	ra,24(sp)
    80005644:	6442                	ld	s0,16(sp)
    80005646:	6105                	addi	sp,sp,32
    80005648:	8082                	ret

000000008000564a <sys_fstat>:
{
    8000564a:	1101                	addi	sp,sp,-32
    8000564c:	ec06                	sd	ra,24(sp)
    8000564e:	e822                	sd	s0,16(sp)
    80005650:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005652:	fe040593          	addi	a1,s0,-32
    80005656:	4505                	li	a0,1
    80005658:	ffffd097          	auipc	ra,0xffffd
    8000565c:	65c080e7          	jalr	1628(ra) # 80002cb4 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005660:	fe840613          	addi	a2,s0,-24
    80005664:	4581                	li	a1,0
    80005666:	4501                	li	a0,0
    80005668:	00000097          	auipc	ra,0x0
    8000566c:	c68080e7          	jalr	-920(ra) # 800052d0 <argfd>
    80005670:	87aa                	mv	a5,a0
    return -1;
    80005672:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005674:	0007ca63          	bltz	a5,80005688 <sys_fstat+0x3e>
  return filestat(f, st);
    80005678:	fe043583          	ld	a1,-32(s0)
    8000567c:	fe843503          	ld	a0,-24(s0)
    80005680:	fffff097          	auipc	ra,0xfffff
    80005684:	2f0080e7          	jalr	752(ra) # 80004970 <filestat>
}
    80005688:	60e2                	ld	ra,24(sp)
    8000568a:	6442                	ld	s0,16(sp)
    8000568c:	6105                	addi	sp,sp,32
    8000568e:	8082                	ret

0000000080005690 <sys_link>:
{
    80005690:	7169                	addi	sp,sp,-304
    80005692:	f606                	sd	ra,296(sp)
    80005694:	f222                	sd	s0,288(sp)
    80005696:	ee26                	sd	s1,280(sp)
    80005698:	ea4a                	sd	s2,272(sp)
    8000569a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000569c:	08000613          	li	a2,128
    800056a0:	ed040593          	addi	a1,s0,-304
    800056a4:	4501                	li	a0,0
    800056a6:	ffffd097          	auipc	ra,0xffffd
    800056aa:	62e080e7          	jalr	1582(ra) # 80002cd4 <argstr>
    return -1;
    800056ae:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800056b0:	10054e63          	bltz	a0,800057cc <sys_link+0x13c>
    800056b4:	08000613          	li	a2,128
    800056b8:	f5040593          	addi	a1,s0,-176
    800056bc:	4505                	li	a0,1
    800056be:	ffffd097          	auipc	ra,0xffffd
    800056c2:	616080e7          	jalr	1558(ra) # 80002cd4 <argstr>
    return -1;
    800056c6:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800056c8:	10054263          	bltz	a0,800057cc <sys_link+0x13c>
  begin_op();
    800056cc:	fffff097          	auipc	ra,0xfffff
    800056d0:	d10080e7          	jalr	-752(ra) # 800043dc <begin_op>
  if((ip = namei(old)) == 0){
    800056d4:	ed040513          	addi	a0,s0,-304
    800056d8:	fffff097          	auipc	ra,0xfffff
    800056dc:	ae8080e7          	jalr	-1304(ra) # 800041c0 <namei>
    800056e0:	84aa                	mv	s1,a0
    800056e2:	c551                	beqz	a0,8000576e <sys_link+0xde>
  ilock(ip);
    800056e4:	ffffe097          	auipc	ra,0xffffe
    800056e8:	336080e7          	jalr	822(ra) # 80003a1a <ilock>
  if(ip->type == T_DIR){
    800056ec:	04449703          	lh	a4,68(s1)
    800056f0:	4785                	li	a5,1
    800056f2:	08f70463          	beq	a4,a5,8000577a <sys_link+0xea>
  ip->nlink++;
    800056f6:	04a4d783          	lhu	a5,74(s1)
    800056fa:	2785                	addiw	a5,a5,1
    800056fc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005700:	8526                	mv	a0,s1
    80005702:	ffffe097          	auipc	ra,0xffffe
    80005706:	24e080e7          	jalr	590(ra) # 80003950 <iupdate>
  iunlock(ip);
    8000570a:	8526                	mv	a0,s1
    8000570c:	ffffe097          	auipc	ra,0xffffe
    80005710:	3d0080e7          	jalr	976(ra) # 80003adc <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005714:	fd040593          	addi	a1,s0,-48
    80005718:	f5040513          	addi	a0,s0,-176
    8000571c:	fffff097          	auipc	ra,0xfffff
    80005720:	ac2080e7          	jalr	-1342(ra) # 800041de <nameiparent>
    80005724:	892a                	mv	s2,a0
    80005726:	c935                	beqz	a0,8000579a <sys_link+0x10a>
  ilock(dp);
    80005728:	ffffe097          	auipc	ra,0xffffe
    8000572c:	2f2080e7          	jalr	754(ra) # 80003a1a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005730:	00092703          	lw	a4,0(s2)
    80005734:	409c                	lw	a5,0(s1)
    80005736:	04f71d63          	bne	a4,a5,80005790 <sys_link+0x100>
    8000573a:	40d0                	lw	a2,4(s1)
    8000573c:	fd040593          	addi	a1,s0,-48
    80005740:	854a                	mv	a0,s2
    80005742:	fffff097          	auipc	ra,0xfffff
    80005746:	9cc080e7          	jalr	-1588(ra) # 8000410e <dirlink>
    8000574a:	04054363          	bltz	a0,80005790 <sys_link+0x100>
  iunlockput(dp);
    8000574e:	854a                	mv	a0,s2
    80005750:	ffffe097          	auipc	ra,0xffffe
    80005754:	52c080e7          	jalr	1324(ra) # 80003c7c <iunlockput>
  iput(ip);
    80005758:	8526                	mv	a0,s1
    8000575a:	ffffe097          	auipc	ra,0xffffe
    8000575e:	47a080e7          	jalr	1146(ra) # 80003bd4 <iput>
  end_op();
    80005762:	fffff097          	auipc	ra,0xfffff
    80005766:	cfa080e7          	jalr	-774(ra) # 8000445c <end_op>
  return 0;
    8000576a:	4781                	li	a5,0
    8000576c:	a085                	j	800057cc <sys_link+0x13c>
    end_op();
    8000576e:	fffff097          	auipc	ra,0xfffff
    80005772:	cee080e7          	jalr	-786(ra) # 8000445c <end_op>
    return -1;
    80005776:	57fd                	li	a5,-1
    80005778:	a891                	j	800057cc <sys_link+0x13c>
    iunlockput(ip);
    8000577a:	8526                	mv	a0,s1
    8000577c:	ffffe097          	auipc	ra,0xffffe
    80005780:	500080e7          	jalr	1280(ra) # 80003c7c <iunlockput>
    end_op();
    80005784:	fffff097          	auipc	ra,0xfffff
    80005788:	cd8080e7          	jalr	-808(ra) # 8000445c <end_op>
    return -1;
    8000578c:	57fd                	li	a5,-1
    8000578e:	a83d                	j	800057cc <sys_link+0x13c>
    iunlockput(dp);
    80005790:	854a                	mv	a0,s2
    80005792:	ffffe097          	auipc	ra,0xffffe
    80005796:	4ea080e7          	jalr	1258(ra) # 80003c7c <iunlockput>
  ilock(ip);
    8000579a:	8526                	mv	a0,s1
    8000579c:	ffffe097          	auipc	ra,0xffffe
    800057a0:	27e080e7          	jalr	638(ra) # 80003a1a <ilock>
  ip->nlink--;
    800057a4:	04a4d783          	lhu	a5,74(s1)
    800057a8:	37fd                	addiw	a5,a5,-1
    800057aa:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800057ae:	8526                	mv	a0,s1
    800057b0:	ffffe097          	auipc	ra,0xffffe
    800057b4:	1a0080e7          	jalr	416(ra) # 80003950 <iupdate>
  iunlockput(ip);
    800057b8:	8526                	mv	a0,s1
    800057ba:	ffffe097          	auipc	ra,0xffffe
    800057be:	4c2080e7          	jalr	1218(ra) # 80003c7c <iunlockput>
  end_op();
    800057c2:	fffff097          	auipc	ra,0xfffff
    800057c6:	c9a080e7          	jalr	-870(ra) # 8000445c <end_op>
  return -1;
    800057ca:	57fd                	li	a5,-1
}
    800057cc:	853e                	mv	a0,a5
    800057ce:	70b2                	ld	ra,296(sp)
    800057d0:	7412                	ld	s0,288(sp)
    800057d2:	64f2                	ld	s1,280(sp)
    800057d4:	6952                	ld	s2,272(sp)
    800057d6:	6155                	addi	sp,sp,304
    800057d8:	8082                	ret

00000000800057da <sys_unlink>:
{
    800057da:	7151                	addi	sp,sp,-240
    800057dc:	f586                	sd	ra,232(sp)
    800057de:	f1a2                	sd	s0,224(sp)
    800057e0:	eda6                	sd	s1,216(sp)
    800057e2:	e9ca                	sd	s2,208(sp)
    800057e4:	e5ce                	sd	s3,200(sp)
    800057e6:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800057e8:	08000613          	li	a2,128
    800057ec:	f3040593          	addi	a1,s0,-208
    800057f0:	4501                	li	a0,0
    800057f2:	ffffd097          	auipc	ra,0xffffd
    800057f6:	4e2080e7          	jalr	1250(ra) # 80002cd4 <argstr>
    800057fa:	18054163          	bltz	a0,8000597c <sys_unlink+0x1a2>
  begin_op();
    800057fe:	fffff097          	auipc	ra,0xfffff
    80005802:	bde080e7          	jalr	-1058(ra) # 800043dc <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005806:	fb040593          	addi	a1,s0,-80
    8000580a:	f3040513          	addi	a0,s0,-208
    8000580e:	fffff097          	auipc	ra,0xfffff
    80005812:	9d0080e7          	jalr	-1584(ra) # 800041de <nameiparent>
    80005816:	84aa                	mv	s1,a0
    80005818:	c979                	beqz	a0,800058ee <sys_unlink+0x114>
  ilock(dp);
    8000581a:	ffffe097          	auipc	ra,0xffffe
    8000581e:	200080e7          	jalr	512(ra) # 80003a1a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005822:	00003597          	auipc	a1,0x3
    80005826:	00658593          	addi	a1,a1,6 # 80008828 <syscalls+0x2b8>
    8000582a:	fb040513          	addi	a0,s0,-80
    8000582e:	ffffe097          	auipc	ra,0xffffe
    80005832:	6b6080e7          	jalr	1718(ra) # 80003ee4 <namecmp>
    80005836:	14050a63          	beqz	a0,8000598a <sys_unlink+0x1b0>
    8000583a:	00003597          	auipc	a1,0x3
    8000583e:	ff658593          	addi	a1,a1,-10 # 80008830 <syscalls+0x2c0>
    80005842:	fb040513          	addi	a0,s0,-80
    80005846:	ffffe097          	auipc	ra,0xffffe
    8000584a:	69e080e7          	jalr	1694(ra) # 80003ee4 <namecmp>
    8000584e:	12050e63          	beqz	a0,8000598a <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005852:	f2c40613          	addi	a2,s0,-212
    80005856:	fb040593          	addi	a1,s0,-80
    8000585a:	8526                	mv	a0,s1
    8000585c:	ffffe097          	auipc	ra,0xffffe
    80005860:	6a2080e7          	jalr	1698(ra) # 80003efe <dirlookup>
    80005864:	892a                	mv	s2,a0
    80005866:	12050263          	beqz	a0,8000598a <sys_unlink+0x1b0>
  ilock(ip);
    8000586a:	ffffe097          	auipc	ra,0xffffe
    8000586e:	1b0080e7          	jalr	432(ra) # 80003a1a <ilock>
  if(ip->nlink < 1)
    80005872:	04a91783          	lh	a5,74(s2)
    80005876:	08f05263          	blez	a5,800058fa <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000587a:	04491703          	lh	a4,68(s2)
    8000587e:	4785                	li	a5,1
    80005880:	08f70563          	beq	a4,a5,8000590a <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005884:	4641                	li	a2,16
    80005886:	4581                	li	a1,0
    80005888:	fc040513          	addi	a0,s0,-64
    8000588c:	ffffb097          	auipc	ra,0xffffb
    80005890:	45a080e7          	jalr	1114(ra) # 80000ce6 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005894:	4741                	li	a4,16
    80005896:	f2c42683          	lw	a3,-212(s0)
    8000589a:	fc040613          	addi	a2,s0,-64
    8000589e:	4581                	li	a1,0
    800058a0:	8526                	mv	a0,s1
    800058a2:	ffffe097          	auipc	ra,0xffffe
    800058a6:	524080e7          	jalr	1316(ra) # 80003dc6 <writei>
    800058aa:	47c1                	li	a5,16
    800058ac:	0af51563          	bne	a0,a5,80005956 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800058b0:	04491703          	lh	a4,68(s2)
    800058b4:	4785                	li	a5,1
    800058b6:	0af70863          	beq	a4,a5,80005966 <sys_unlink+0x18c>
  iunlockput(dp);
    800058ba:	8526                	mv	a0,s1
    800058bc:	ffffe097          	auipc	ra,0xffffe
    800058c0:	3c0080e7          	jalr	960(ra) # 80003c7c <iunlockput>
  ip->nlink--;
    800058c4:	04a95783          	lhu	a5,74(s2)
    800058c8:	37fd                	addiw	a5,a5,-1
    800058ca:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800058ce:	854a                	mv	a0,s2
    800058d0:	ffffe097          	auipc	ra,0xffffe
    800058d4:	080080e7          	jalr	128(ra) # 80003950 <iupdate>
  iunlockput(ip);
    800058d8:	854a                	mv	a0,s2
    800058da:	ffffe097          	auipc	ra,0xffffe
    800058de:	3a2080e7          	jalr	930(ra) # 80003c7c <iunlockput>
  end_op();
    800058e2:	fffff097          	auipc	ra,0xfffff
    800058e6:	b7a080e7          	jalr	-1158(ra) # 8000445c <end_op>
  return 0;
    800058ea:	4501                	li	a0,0
    800058ec:	a84d                	j	8000599e <sys_unlink+0x1c4>
    end_op();
    800058ee:	fffff097          	auipc	ra,0xfffff
    800058f2:	b6e080e7          	jalr	-1170(ra) # 8000445c <end_op>
    return -1;
    800058f6:	557d                	li	a0,-1
    800058f8:	a05d                	j	8000599e <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800058fa:	00003517          	auipc	a0,0x3
    800058fe:	f3e50513          	addi	a0,a0,-194 # 80008838 <syscalls+0x2c8>
    80005902:	ffffb097          	auipc	ra,0xffffb
    80005906:	c42080e7          	jalr	-958(ra) # 80000544 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000590a:	04c92703          	lw	a4,76(s2)
    8000590e:	02000793          	li	a5,32
    80005912:	f6e7f9e3          	bgeu	a5,a4,80005884 <sys_unlink+0xaa>
    80005916:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000591a:	4741                	li	a4,16
    8000591c:	86ce                	mv	a3,s3
    8000591e:	f1840613          	addi	a2,s0,-232
    80005922:	4581                	li	a1,0
    80005924:	854a                	mv	a0,s2
    80005926:	ffffe097          	auipc	ra,0xffffe
    8000592a:	3a8080e7          	jalr	936(ra) # 80003cce <readi>
    8000592e:	47c1                	li	a5,16
    80005930:	00f51b63          	bne	a0,a5,80005946 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005934:	f1845783          	lhu	a5,-232(s0)
    80005938:	e7a1                	bnez	a5,80005980 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000593a:	29c1                	addiw	s3,s3,16
    8000593c:	04c92783          	lw	a5,76(s2)
    80005940:	fcf9ede3          	bltu	s3,a5,8000591a <sys_unlink+0x140>
    80005944:	b781                	j	80005884 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005946:	00003517          	auipc	a0,0x3
    8000594a:	f0a50513          	addi	a0,a0,-246 # 80008850 <syscalls+0x2e0>
    8000594e:	ffffb097          	auipc	ra,0xffffb
    80005952:	bf6080e7          	jalr	-1034(ra) # 80000544 <panic>
    panic("unlink: writei");
    80005956:	00003517          	auipc	a0,0x3
    8000595a:	f1250513          	addi	a0,a0,-238 # 80008868 <syscalls+0x2f8>
    8000595e:	ffffb097          	auipc	ra,0xffffb
    80005962:	be6080e7          	jalr	-1050(ra) # 80000544 <panic>
    dp->nlink--;
    80005966:	04a4d783          	lhu	a5,74(s1)
    8000596a:	37fd                	addiw	a5,a5,-1
    8000596c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005970:	8526                	mv	a0,s1
    80005972:	ffffe097          	auipc	ra,0xffffe
    80005976:	fde080e7          	jalr	-34(ra) # 80003950 <iupdate>
    8000597a:	b781                	j	800058ba <sys_unlink+0xe0>
    return -1;
    8000597c:	557d                	li	a0,-1
    8000597e:	a005                	j	8000599e <sys_unlink+0x1c4>
    iunlockput(ip);
    80005980:	854a                	mv	a0,s2
    80005982:	ffffe097          	auipc	ra,0xffffe
    80005986:	2fa080e7          	jalr	762(ra) # 80003c7c <iunlockput>
  iunlockput(dp);
    8000598a:	8526                	mv	a0,s1
    8000598c:	ffffe097          	auipc	ra,0xffffe
    80005990:	2f0080e7          	jalr	752(ra) # 80003c7c <iunlockput>
  end_op();
    80005994:	fffff097          	auipc	ra,0xfffff
    80005998:	ac8080e7          	jalr	-1336(ra) # 8000445c <end_op>
  return -1;
    8000599c:	557d                	li	a0,-1
}
    8000599e:	70ae                	ld	ra,232(sp)
    800059a0:	740e                	ld	s0,224(sp)
    800059a2:	64ee                	ld	s1,216(sp)
    800059a4:	694e                	ld	s2,208(sp)
    800059a6:	69ae                	ld	s3,200(sp)
    800059a8:	616d                	addi	sp,sp,240
    800059aa:	8082                	ret

00000000800059ac <sys_open>:

uint64
sys_open(void)
{
    800059ac:	7131                	addi	sp,sp,-192
    800059ae:	fd06                	sd	ra,184(sp)
    800059b0:	f922                	sd	s0,176(sp)
    800059b2:	f526                	sd	s1,168(sp)
    800059b4:	f14a                	sd	s2,160(sp)
    800059b6:	ed4e                	sd	s3,152(sp)
    800059b8:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800059ba:	f4c40593          	addi	a1,s0,-180
    800059be:	4505                	li	a0,1
    800059c0:	ffffd097          	auipc	ra,0xffffd
    800059c4:	2d4080e7          	jalr	724(ra) # 80002c94 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800059c8:	08000613          	li	a2,128
    800059cc:	f5040593          	addi	a1,s0,-176
    800059d0:	4501                	li	a0,0
    800059d2:	ffffd097          	auipc	ra,0xffffd
    800059d6:	302080e7          	jalr	770(ra) # 80002cd4 <argstr>
    800059da:	87aa                	mv	a5,a0
    return -1;
    800059dc:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800059de:	0a07c963          	bltz	a5,80005a90 <sys_open+0xe4>

  begin_op();
    800059e2:	fffff097          	auipc	ra,0xfffff
    800059e6:	9fa080e7          	jalr	-1542(ra) # 800043dc <begin_op>

  if(omode & O_CREATE){
    800059ea:	f4c42783          	lw	a5,-180(s0)
    800059ee:	2007f793          	andi	a5,a5,512
    800059f2:	cfc5                	beqz	a5,80005aaa <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800059f4:	4681                	li	a3,0
    800059f6:	4601                	li	a2,0
    800059f8:	4589                	li	a1,2
    800059fa:	f5040513          	addi	a0,s0,-176
    800059fe:	00000097          	auipc	ra,0x0
    80005a02:	974080e7          	jalr	-1676(ra) # 80005372 <create>
    80005a06:	84aa                	mv	s1,a0
    if(ip == 0){
    80005a08:	c959                	beqz	a0,80005a9e <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005a0a:	04449703          	lh	a4,68(s1)
    80005a0e:	478d                	li	a5,3
    80005a10:	00f71763          	bne	a4,a5,80005a1e <sys_open+0x72>
    80005a14:	0464d703          	lhu	a4,70(s1)
    80005a18:	47a5                	li	a5,9
    80005a1a:	0ce7ed63          	bltu	a5,a4,80005af4 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005a1e:	fffff097          	auipc	ra,0xfffff
    80005a22:	dce080e7          	jalr	-562(ra) # 800047ec <filealloc>
    80005a26:	89aa                	mv	s3,a0
    80005a28:	10050363          	beqz	a0,80005b2e <sys_open+0x182>
    80005a2c:	00000097          	auipc	ra,0x0
    80005a30:	904080e7          	jalr	-1788(ra) # 80005330 <fdalloc>
    80005a34:	892a                	mv	s2,a0
    80005a36:	0e054763          	bltz	a0,80005b24 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005a3a:	04449703          	lh	a4,68(s1)
    80005a3e:	478d                	li	a5,3
    80005a40:	0cf70563          	beq	a4,a5,80005b0a <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005a44:	4789                	li	a5,2
    80005a46:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005a4a:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005a4e:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005a52:	f4c42783          	lw	a5,-180(s0)
    80005a56:	0017c713          	xori	a4,a5,1
    80005a5a:	8b05                	andi	a4,a4,1
    80005a5c:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005a60:	0037f713          	andi	a4,a5,3
    80005a64:	00e03733          	snez	a4,a4
    80005a68:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005a6c:	4007f793          	andi	a5,a5,1024
    80005a70:	c791                	beqz	a5,80005a7c <sys_open+0xd0>
    80005a72:	04449703          	lh	a4,68(s1)
    80005a76:	4789                	li	a5,2
    80005a78:	0af70063          	beq	a4,a5,80005b18 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005a7c:	8526                	mv	a0,s1
    80005a7e:	ffffe097          	auipc	ra,0xffffe
    80005a82:	05e080e7          	jalr	94(ra) # 80003adc <iunlock>
  end_op();
    80005a86:	fffff097          	auipc	ra,0xfffff
    80005a8a:	9d6080e7          	jalr	-1578(ra) # 8000445c <end_op>

  return fd;
    80005a8e:	854a                	mv	a0,s2
}
    80005a90:	70ea                	ld	ra,184(sp)
    80005a92:	744a                	ld	s0,176(sp)
    80005a94:	74aa                	ld	s1,168(sp)
    80005a96:	790a                	ld	s2,160(sp)
    80005a98:	69ea                	ld	s3,152(sp)
    80005a9a:	6129                	addi	sp,sp,192
    80005a9c:	8082                	ret
      end_op();
    80005a9e:	fffff097          	auipc	ra,0xfffff
    80005aa2:	9be080e7          	jalr	-1602(ra) # 8000445c <end_op>
      return -1;
    80005aa6:	557d                	li	a0,-1
    80005aa8:	b7e5                	j	80005a90 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005aaa:	f5040513          	addi	a0,s0,-176
    80005aae:	ffffe097          	auipc	ra,0xffffe
    80005ab2:	712080e7          	jalr	1810(ra) # 800041c0 <namei>
    80005ab6:	84aa                	mv	s1,a0
    80005ab8:	c905                	beqz	a0,80005ae8 <sys_open+0x13c>
    ilock(ip);
    80005aba:	ffffe097          	auipc	ra,0xffffe
    80005abe:	f60080e7          	jalr	-160(ra) # 80003a1a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005ac2:	04449703          	lh	a4,68(s1)
    80005ac6:	4785                	li	a5,1
    80005ac8:	f4f711e3          	bne	a4,a5,80005a0a <sys_open+0x5e>
    80005acc:	f4c42783          	lw	a5,-180(s0)
    80005ad0:	d7b9                	beqz	a5,80005a1e <sys_open+0x72>
      iunlockput(ip);
    80005ad2:	8526                	mv	a0,s1
    80005ad4:	ffffe097          	auipc	ra,0xffffe
    80005ad8:	1a8080e7          	jalr	424(ra) # 80003c7c <iunlockput>
      end_op();
    80005adc:	fffff097          	auipc	ra,0xfffff
    80005ae0:	980080e7          	jalr	-1664(ra) # 8000445c <end_op>
      return -1;
    80005ae4:	557d                	li	a0,-1
    80005ae6:	b76d                	j	80005a90 <sys_open+0xe4>
      end_op();
    80005ae8:	fffff097          	auipc	ra,0xfffff
    80005aec:	974080e7          	jalr	-1676(ra) # 8000445c <end_op>
      return -1;
    80005af0:	557d                	li	a0,-1
    80005af2:	bf79                	j	80005a90 <sys_open+0xe4>
    iunlockput(ip);
    80005af4:	8526                	mv	a0,s1
    80005af6:	ffffe097          	auipc	ra,0xffffe
    80005afa:	186080e7          	jalr	390(ra) # 80003c7c <iunlockput>
    end_op();
    80005afe:	fffff097          	auipc	ra,0xfffff
    80005b02:	95e080e7          	jalr	-1698(ra) # 8000445c <end_op>
    return -1;
    80005b06:	557d                	li	a0,-1
    80005b08:	b761                	j	80005a90 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005b0a:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005b0e:	04649783          	lh	a5,70(s1)
    80005b12:	02f99223          	sh	a5,36(s3)
    80005b16:	bf25                	j	80005a4e <sys_open+0xa2>
    itrunc(ip);
    80005b18:	8526                	mv	a0,s1
    80005b1a:	ffffe097          	auipc	ra,0xffffe
    80005b1e:	00e080e7          	jalr	14(ra) # 80003b28 <itrunc>
    80005b22:	bfa9                	j	80005a7c <sys_open+0xd0>
      fileclose(f);
    80005b24:	854e                	mv	a0,s3
    80005b26:	fffff097          	auipc	ra,0xfffff
    80005b2a:	d82080e7          	jalr	-638(ra) # 800048a8 <fileclose>
    iunlockput(ip);
    80005b2e:	8526                	mv	a0,s1
    80005b30:	ffffe097          	auipc	ra,0xffffe
    80005b34:	14c080e7          	jalr	332(ra) # 80003c7c <iunlockput>
    end_op();
    80005b38:	fffff097          	auipc	ra,0xfffff
    80005b3c:	924080e7          	jalr	-1756(ra) # 8000445c <end_op>
    return -1;
    80005b40:	557d                	li	a0,-1
    80005b42:	b7b9                	j	80005a90 <sys_open+0xe4>

0000000080005b44 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005b44:	7175                	addi	sp,sp,-144
    80005b46:	e506                	sd	ra,136(sp)
    80005b48:	e122                	sd	s0,128(sp)
    80005b4a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005b4c:	fffff097          	auipc	ra,0xfffff
    80005b50:	890080e7          	jalr	-1904(ra) # 800043dc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005b54:	08000613          	li	a2,128
    80005b58:	f7040593          	addi	a1,s0,-144
    80005b5c:	4501                	li	a0,0
    80005b5e:	ffffd097          	auipc	ra,0xffffd
    80005b62:	176080e7          	jalr	374(ra) # 80002cd4 <argstr>
    80005b66:	02054963          	bltz	a0,80005b98 <sys_mkdir+0x54>
    80005b6a:	4681                	li	a3,0
    80005b6c:	4601                	li	a2,0
    80005b6e:	4585                	li	a1,1
    80005b70:	f7040513          	addi	a0,s0,-144
    80005b74:	fffff097          	auipc	ra,0xfffff
    80005b78:	7fe080e7          	jalr	2046(ra) # 80005372 <create>
    80005b7c:	cd11                	beqz	a0,80005b98 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b7e:	ffffe097          	auipc	ra,0xffffe
    80005b82:	0fe080e7          	jalr	254(ra) # 80003c7c <iunlockput>
  end_op();
    80005b86:	fffff097          	auipc	ra,0xfffff
    80005b8a:	8d6080e7          	jalr	-1834(ra) # 8000445c <end_op>
  return 0;
    80005b8e:	4501                	li	a0,0
}
    80005b90:	60aa                	ld	ra,136(sp)
    80005b92:	640a                	ld	s0,128(sp)
    80005b94:	6149                	addi	sp,sp,144
    80005b96:	8082                	ret
    end_op();
    80005b98:	fffff097          	auipc	ra,0xfffff
    80005b9c:	8c4080e7          	jalr	-1852(ra) # 8000445c <end_op>
    return -1;
    80005ba0:	557d                	li	a0,-1
    80005ba2:	b7fd                	j	80005b90 <sys_mkdir+0x4c>

0000000080005ba4 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005ba4:	7135                	addi	sp,sp,-160
    80005ba6:	ed06                	sd	ra,152(sp)
    80005ba8:	e922                	sd	s0,144(sp)
    80005baa:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005bac:	fffff097          	auipc	ra,0xfffff
    80005bb0:	830080e7          	jalr	-2000(ra) # 800043dc <begin_op>
  argint(1, &major);
    80005bb4:	f6c40593          	addi	a1,s0,-148
    80005bb8:	4505                	li	a0,1
    80005bba:	ffffd097          	auipc	ra,0xffffd
    80005bbe:	0da080e7          	jalr	218(ra) # 80002c94 <argint>
  argint(2, &minor);
    80005bc2:	f6840593          	addi	a1,s0,-152
    80005bc6:	4509                	li	a0,2
    80005bc8:	ffffd097          	auipc	ra,0xffffd
    80005bcc:	0cc080e7          	jalr	204(ra) # 80002c94 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005bd0:	08000613          	li	a2,128
    80005bd4:	f7040593          	addi	a1,s0,-144
    80005bd8:	4501                	li	a0,0
    80005bda:	ffffd097          	auipc	ra,0xffffd
    80005bde:	0fa080e7          	jalr	250(ra) # 80002cd4 <argstr>
    80005be2:	02054b63          	bltz	a0,80005c18 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005be6:	f6841683          	lh	a3,-152(s0)
    80005bea:	f6c41603          	lh	a2,-148(s0)
    80005bee:	458d                	li	a1,3
    80005bf0:	f7040513          	addi	a0,s0,-144
    80005bf4:	fffff097          	auipc	ra,0xfffff
    80005bf8:	77e080e7          	jalr	1918(ra) # 80005372 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005bfc:	cd11                	beqz	a0,80005c18 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005bfe:	ffffe097          	auipc	ra,0xffffe
    80005c02:	07e080e7          	jalr	126(ra) # 80003c7c <iunlockput>
  end_op();
    80005c06:	fffff097          	auipc	ra,0xfffff
    80005c0a:	856080e7          	jalr	-1962(ra) # 8000445c <end_op>
  return 0;
    80005c0e:	4501                	li	a0,0
}
    80005c10:	60ea                	ld	ra,152(sp)
    80005c12:	644a                	ld	s0,144(sp)
    80005c14:	610d                	addi	sp,sp,160
    80005c16:	8082                	ret
    end_op();
    80005c18:	fffff097          	auipc	ra,0xfffff
    80005c1c:	844080e7          	jalr	-1980(ra) # 8000445c <end_op>
    return -1;
    80005c20:	557d                	li	a0,-1
    80005c22:	b7fd                	j	80005c10 <sys_mknod+0x6c>

0000000080005c24 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005c24:	7135                	addi	sp,sp,-160
    80005c26:	ed06                	sd	ra,152(sp)
    80005c28:	e922                	sd	s0,144(sp)
    80005c2a:	e526                	sd	s1,136(sp)
    80005c2c:	e14a                	sd	s2,128(sp)
    80005c2e:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005c30:	ffffc097          	auipc	ra,0xffffc
    80005c34:	ea0080e7          	jalr	-352(ra) # 80001ad0 <myproc>
    80005c38:	892a                	mv	s2,a0
  
  begin_op();
    80005c3a:	ffffe097          	auipc	ra,0xffffe
    80005c3e:	7a2080e7          	jalr	1954(ra) # 800043dc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005c42:	08000613          	li	a2,128
    80005c46:	f6040593          	addi	a1,s0,-160
    80005c4a:	4501                	li	a0,0
    80005c4c:	ffffd097          	auipc	ra,0xffffd
    80005c50:	088080e7          	jalr	136(ra) # 80002cd4 <argstr>
    80005c54:	04054b63          	bltz	a0,80005caa <sys_chdir+0x86>
    80005c58:	f6040513          	addi	a0,s0,-160
    80005c5c:	ffffe097          	auipc	ra,0xffffe
    80005c60:	564080e7          	jalr	1380(ra) # 800041c0 <namei>
    80005c64:	84aa                	mv	s1,a0
    80005c66:	c131                	beqz	a0,80005caa <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005c68:	ffffe097          	auipc	ra,0xffffe
    80005c6c:	db2080e7          	jalr	-590(ra) # 80003a1a <ilock>
  if(ip->type != T_DIR){
    80005c70:	04449703          	lh	a4,68(s1)
    80005c74:	4785                	li	a5,1
    80005c76:	04f71063          	bne	a4,a5,80005cb6 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005c7a:	8526                	mv	a0,s1
    80005c7c:	ffffe097          	auipc	ra,0xffffe
    80005c80:	e60080e7          	jalr	-416(ra) # 80003adc <iunlock>
  iput(p->cwd);
    80005c84:	15893503          	ld	a0,344(s2)
    80005c88:	ffffe097          	auipc	ra,0xffffe
    80005c8c:	f4c080e7          	jalr	-180(ra) # 80003bd4 <iput>
  end_op();
    80005c90:	ffffe097          	auipc	ra,0xffffe
    80005c94:	7cc080e7          	jalr	1996(ra) # 8000445c <end_op>
  p->cwd = ip;
    80005c98:	14993c23          	sd	s1,344(s2)
  return 0;
    80005c9c:	4501                	li	a0,0
}
    80005c9e:	60ea                	ld	ra,152(sp)
    80005ca0:	644a                	ld	s0,144(sp)
    80005ca2:	64aa                	ld	s1,136(sp)
    80005ca4:	690a                	ld	s2,128(sp)
    80005ca6:	610d                	addi	sp,sp,160
    80005ca8:	8082                	ret
    end_op();
    80005caa:	ffffe097          	auipc	ra,0xffffe
    80005cae:	7b2080e7          	jalr	1970(ra) # 8000445c <end_op>
    return -1;
    80005cb2:	557d                	li	a0,-1
    80005cb4:	b7ed                	j	80005c9e <sys_chdir+0x7a>
    iunlockput(ip);
    80005cb6:	8526                	mv	a0,s1
    80005cb8:	ffffe097          	auipc	ra,0xffffe
    80005cbc:	fc4080e7          	jalr	-60(ra) # 80003c7c <iunlockput>
    end_op();
    80005cc0:	ffffe097          	auipc	ra,0xffffe
    80005cc4:	79c080e7          	jalr	1948(ra) # 8000445c <end_op>
    return -1;
    80005cc8:	557d                	li	a0,-1
    80005cca:	bfd1                	j	80005c9e <sys_chdir+0x7a>

0000000080005ccc <sys_exec>:

uint64
sys_exec(void)
{
    80005ccc:	7145                	addi	sp,sp,-464
    80005cce:	e786                	sd	ra,456(sp)
    80005cd0:	e3a2                	sd	s0,448(sp)
    80005cd2:	ff26                	sd	s1,440(sp)
    80005cd4:	fb4a                	sd	s2,432(sp)
    80005cd6:	f74e                	sd	s3,424(sp)
    80005cd8:	f352                	sd	s4,416(sp)
    80005cda:	ef56                	sd	s5,408(sp)
    80005cdc:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005cde:	e3840593          	addi	a1,s0,-456
    80005ce2:	4505                	li	a0,1
    80005ce4:	ffffd097          	auipc	ra,0xffffd
    80005ce8:	fd0080e7          	jalr	-48(ra) # 80002cb4 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005cec:	08000613          	li	a2,128
    80005cf0:	f4040593          	addi	a1,s0,-192
    80005cf4:	4501                	li	a0,0
    80005cf6:	ffffd097          	auipc	ra,0xffffd
    80005cfa:	fde080e7          	jalr	-34(ra) # 80002cd4 <argstr>
    80005cfe:	87aa                	mv	a5,a0
    return -1;
    80005d00:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005d02:	0c07c263          	bltz	a5,80005dc6 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005d06:	10000613          	li	a2,256
    80005d0a:	4581                	li	a1,0
    80005d0c:	e4040513          	addi	a0,s0,-448
    80005d10:	ffffb097          	auipc	ra,0xffffb
    80005d14:	fd6080e7          	jalr	-42(ra) # 80000ce6 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005d18:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005d1c:	89a6                	mv	s3,s1
    80005d1e:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005d20:	02000a13          	li	s4,32
    80005d24:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005d28:	00391513          	slli	a0,s2,0x3
    80005d2c:	e3040593          	addi	a1,s0,-464
    80005d30:	e3843783          	ld	a5,-456(s0)
    80005d34:	953e                	add	a0,a0,a5
    80005d36:	ffffd097          	auipc	ra,0xffffd
    80005d3a:	ec0080e7          	jalr	-320(ra) # 80002bf6 <fetchaddr>
    80005d3e:	02054a63          	bltz	a0,80005d72 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005d42:	e3043783          	ld	a5,-464(s0)
    80005d46:	c3b9                	beqz	a5,80005d8c <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005d48:	ffffb097          	auipc	ra,0xffffb
    80005d4c:	db2080e7          	jalr	-590(ra) # 80000afa <kalloc>
    80005d50:	85aa                	mv	a1,a0
    80005d52:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005d56:	cd11                	beqz	a0,80005d72 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005d58:	6605                	lui	a2,0x1
    80005d5a:	e3043503          	ld	a0,-464(s0)
    80005d5e:	ffffd097          	auipc	ra,0xffffd
    80005d62:	eea080e7          	jalr	-278(ra) # 80002c48 <fetchstr>
    80005d66:	00054663          	bltz	a0,80005d72 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005d6a:	0905                	addi	s2,s2,1
    80005d6c:	09a1                	addi	s3,s3,8
    80005d6e:	fb491be3          	bne	s2,s4,80005d24 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d72:	10048913          	addi	s2,s1,256
    80005d76:	6088                	ld	a0,0(s1)
    80005d78:	c531                	beqz	a0,80005dc4 <sys_exec+0xf8>
    kfree(argv[i]);
    80005d7a:	ffffb097          	auipc	ra,0xffffb
    80005d7e:	c84080e7          	jalr	-892(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d82:	04a1                	addi	s1,s1,8
    80005d84:	ff2499e3          	bne	s1,s2,80005d76 <sys_exec+0xaa>
  return -1;
    80005d88:	557d                	li	a0,-1
    80005d8a:	a835                	j	80005dc6 <sys_exec+0xfa>
      argv[i] = 0;
    80005d8c:	0a8e                	slli	s5,s5,0x3
    80005d8e:	fc040793          	addi	a5,s0,-64
    80005d92:	9abe                	add	s5,s5,a5
    80005d94:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005d98:	e4040593          	addi	a1,s0,-448
    80005d9c:	f4040513          	addi	a0,s0,-192
    80005da0:	fffff097          	auipc	ra,0xfffff
    80005da4:	190080e7          	jalr	400(ra) # 80004f30 <exec>
    80005da8:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005daa:	10048993          	addi	s3,s1,256
    80005dae:	6088                	ld	a0,0(s1)
    80005db0:	c901                	beqz	a0,80005dc0 <sys_exec+0xf4>
    kfree(argv[i]);
    80005db2:	ffffb097          	auipc	ra,0xffffb
    80005db6:	c4c080e7          	jalr	-948(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005dba:	04a1                	addi	s1,s1,8
    80005dbc:	ff3499e3          	bne	s1,s3,80005dae <sys_exec+0xe2>
  return ret;
    80005dc0:	854a                	mv	a0,s2
    80005dc2:	a011                	j	80005dc6 <sys_exec+0xfa>
  return -1;
    80005dc4:	557d                	li	a0,-1
}
    80005dc6:	60be                	ld	ra,456(sp)
    80005dc8:	641e                	ld	s0,448(sp)
    80005dca:	74fa                	ld	s1,440(sp)
    80005dcc:	795a                	ld	s2,432(sp)
    80005dce:	79ba                	ld	s3,424(sp)
    80005dd0:	7a1a                	ld	s4,416(sp)
    80005dd2:	6afa                	ld	s5,408(sp)
    80005dd4:	6179                	addi	sp,sp,464
    80005dd6:	8082                	ret

0000000080005dd8 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005dd8:	7139                	addi	sp,sp,-64
    80005dda:	fc06                	sd	ra,56(sp)
    80005ddc:	f822                	sd	s0,48(sp)
    80005dde:	f426                	sd	s1,40(sp)
    80005de0:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005de2:	ffffc097          	auipc	ra,0xffffc
    80005de6:	cee080e7          	jalr	-786(ra) # 80001ad0 <myproc>
    80005dea:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005dec:	fd840593          	addi	a1,s0,-40
    80005df0:	4501                	li	a0,0
    80005df2:	ffffd097          	auipc	ra,0xffffd
    80005df6:	ec2080e7          	jalr	-318(ra) # 80002cb4 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005dfa:	fc840593          	addi	a1,s0,-56
    80005dfe:	fd040513          	addi	a0,s0,-48
    80005e02:	fffff097          	auipc	ra,0xfffff
    80005e06:	dd6080e7          	jalr	-554(ra) # 80004bd8 <pipealloc>
    return -1;
    80005e0a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005e0c:	0c054463          	bltz	a0,80005ed4 <sys_pipe+0xfc>
  fd0 = -1;
    80005e10:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005e14:	fd043503          	ld	a0,-48(s0)
    80005e18:	fffff097          	auipc	ra,0xfffff
    80005e1c:	518080e7          	jalr	1304(ra) # 80005330 <fdalloc>
    80005e20:	fca42223          	sw	a0,-60(s0)
    80005e24:	08054b63          	bltz	a0,80005eba <sys_pipe+0xe2>
    80005e28:	fc843503          	ld	a0,-56(s0)
    80005e2c:	fffff097          	auipc	ra,0xfffff
    80005e30:	504080e7          	jalr	1284(ra) # 80005330 <fdalloc>
    80005e34:	fca42023          	sw	a0,-64(s0)
    80005e38:	06054863          	bltz	a0,80005ea8 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e3c:	4691                	li	a3,4
    80005e3e:	fc440613          	addi	a2,s0,-60
    80005e42:	fd843583          	ld	a1,-40(s0)
    80005e46:	6ca8                	ld	a0,88(s1)
    80005e48:	ffffc097          	auipc	ra,0xffffc
    80005e4c:	83c080e7          	jalr	-1988(ra) # 80001684 <copyout>
    80005e50:	02054063          	bltz	a0,80005e70 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005e54:	4691                	li	a3,4
    80005e56:	fc040613          	addi	a2,s0,-64
    80005e5a:	fd843583          	ld	a1,-40(s0)
    80005e5e:	0591                	addi	a1,a1,4
    80005e60:	6ca8                	ld	a0,88(s1)
    80005e62:	ffffc097          	auipc	ra,0xffffc
    80005e66:	822080e7          	jalr	-2014(ra) # 80001684 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005e6a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e6c:	06055463          	bgez	a0,80005ed4 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005e70:	fc442783          	lw	a5,-60(s0)
    80005e74:	07e9                	addi	a5,a5,26
    80005e76:	078e                	slli	a5,a5,0x3
    80005e78:	97a6                	add	a5,a5,s1
    80005e7a:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005e7e:	fc042503          	lw	a0,-64(s0)
    80005e82:	0569                	addi	a0,a0,26
    80005e84:	050e                	slli	a0,a0,0x3
    80005e86:	94aa                	add	s1,s1,a0
    80005e88:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80005e8c:	fd043503          	ld	a0,-48(s0)
    80005e90:	fffff097          	auipc	ra,0xfffff
    80005e94:	a18080e7          	jalr	-1512(ra) # 800048a8 <fileclose>
    fileclose(wf);
    80005e98:	fc843503          	ld	a0,-56(s0)
    80005e9c:	fffff097          	auipc	ra,0xfffff
    80005ea0:	a0c080e7          	jalr	-1524(ra) # 800048a8 <fileclose>
    return -1;
    80005ea4:	57fd                	li	a5,-1
    80005ea6:	a03d                	j	80005ed4 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005ea8:	fc442783          	lw	a5,-60(s0)
    80005eac:	0007c763          	bltz	a5,80005eba <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005eb0:	07e9                	addi	a5,a5,26
    80005eb2:	078e                	slli	a5,a5,0x3
    80005eb4:	94be                	add	s1,s1,a5
    80005eb6:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80005eba:	fd043503          	ld	a0,-48(s0)
    80005ebe:	fffff097          	auipc	ra,0xfffff
    80005ec2:	9ea080e7          	jalr	-1558(ra) # 800048a8 <fileclose>
    fileclose(wf);
    80005ec6:	fc843503          	ld	a0,-56(s0)
    80005eca:	fffff097          	auipc	ra,0xfffff
    80005ece:	9de080e7          	jalr	-1570(ra) # 800048a8 <fileclose>
    return -1;
    80005ed2:	57fd                	li	a5,-1
}
    80005ed4:	853e                	mv	a0,a5
    80005ed6:	70e2                	ld	ra,56(sp)
    80005ed8:	7442                	ld	s0,48(sp)
    80005eda:	74a2                	ld	s1,40(sp)
    80005edc:	6121                	addi	sp,sp,64
    80005ede:	8082                	ret

0000000080005ee0 <kernelvec>:
    80005ee0:	7111                	addi	sp,sp,-256
    80005ee2:	e006                	sd	ra,0(sp)
    80005ee4:	e40a                	sd	sp,8(sp)
    80005ee6:	e80e                	sd	gp,16(sp)
    80005ee8:	ec12                	sd	tp,24(sp)
    80005eea:	f016                	sd	t0,32(sp)
    80005eec:	f41a                	sd	t1,40(sp)
    80005eee:	f81e                	sd	t2,48(sp)
    80005ef0:	fc22                	sd	s0,56(sp)
    80005ef2:	e0a6                	sd	s1,64(sp)
    80005ef4:	e4aa                	sd	a0,72(sp)
    80005ef6:	e8ae                	sd	a1,80(sp)
    80005ef8:	ecb2                	sd	a2,88(sp)
    80005efa:	f0b6                	sd	a3,96(sp)
    80005efc:	f4ba                	sd	a4,104(sp)
    80005efe:	f8be                	sd	a5,112(sp)
    80005f00:	fcc2                	sd	a6,120(sp)
    80005f02:	e146                	sd	a7,128(sp)
    80005f04:	e54a                	sd	s2,136(sp)
    80005f06:	e94e                	sd	s3,144(sp)
    80005f08:	ed52                	sd	s4,152(sp)
    80005f0a:	f156                	sd	s5,160(sp)
    80005f0c:	f55a                	sd	s6,168(sp)
    80005f0e:	f95e                	sd	s7,176(sp)
    80005f10:	fd62                	sd	s8,184(sp)
    80005f12:	e1e6                	sd	s9,192(sp)
    80005f14:	e5ea                	sd	s10,200(sp)
    80005f16:	e9ee                	sd	s11,208(sp)
    80005f18:	edf2                	sd	t3,216(sp)
    80005f1a:	f1f6                	sd	t4,224(sp)
    80005f1c:	f5fa                	sd	t5,232(sp)
    80005f1e:	f9fe                	sd	t6,240(sp)
    80005f20:	ba3fc0ef          	jal	ra,80002ac2 <kerneltrap>
    80005f24:	6082                	ld	ra,0(sp)
    80005f26:	6122                	ld	sp,8(sp)
    80005f28:	61c2                	ld	gp,16(sp)
    80005f2a:	7282                	ld	t0,32(sp)
    80005f2c:	7322                	ld	t1,40(sp)
    80005f2e:	73c2                	ld	t2,48(sp)
    80005f30:	7462                	ld	s0,56(sp)
    80005f32:	6486                	ld	s1,64(sp)
    80005f34:	6526                	ld	a0,72(sp)
    80005f36:	65c6                	ld	a1,80(sp)
    80005f38:	6666                	ld	a2,88(sp)
    80005f3a:	7686                	ld	a3,96(sp)
    80005f3c:	7726                	ld	a4,104(sp)
    80005f3e:	77c6                	ld	a5,112(sp)
    80005f40:	7866                	ld	a6,120(sp)
    80005f42:	688a                	ld	a7,128(sp)
    80005f44:	692a                	ld	s2,136(sp)
    80005f46:	69ca                	ld	s3,144(sp)
    80005f48:	6a6a                	ld	s4,152(sp)
    80005f4a:	7a8a                	ld	s5,160(sp)
    80005f4c:	7b2a                	ld	s6,168(sp)
    80005f4e:	7bca                	ld	s7,176(sp)
    80005f50:	7c6a                	ld	s8,184(sp)
    80005f52:	6c8e                	ld	s9,192(sp)
    80005f54:	6d2e                	ld	s10,200(sp)
    80005f56:	6dce                	ld	s11,208(sp)
    80005f58:	6e6e                	ld	t3,216(sp)
    80005f5a:	7e8e                	ld	t4,224(sp)
    80005f5c:	7f2e                	ld	t5,232(sp)
    80005f5e:	7fce                	ld	t6,240(sp)
    80005f60:	6111                	addi	sp,sp,256
    80005f62:	10200073          	sret
    80005f66:	00000013          	nop
    80005f6a:	00000013          	nop
    80005f6e:	0001                	nop

0000000080005f70 <timervec>:
    80005f70:	34051573          	csrrw	a0,mscratch,a0
    80005f74:	e10c                	sd	a1,0(a0)
    80005f76:	e510                	sd	a2,8(a0)
    80005f78:	e914                	sd	a3,16(a0)
    80005f7a:	6d0c                	ld	a1,24(a0)
    80005f7c:	7110                	ld	a2,32(a0)
    80005f7e:	6194                	ld	a3,0(a1)
    80005f80:	96b2                	add	a3,a3,a2
    80005f82:	e194                	sd	a3,0(a1)
    80005f84:	4589                	li	a1,2
    80005f86:	14459073          	csrw	sip,a1
    80005f8a:	6914                	ld	a3,16(a0)
    80005f8c:	6510                	ld	a2,8(a0)
    80005f8e:	610c                	ld	a1,0(a0)
    80005f90:	34051573          	csrrw	a0,mscratch,a0
    80005f94:	30200073          	mret
	...

0000000080005f9a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005f9a:	1141                	addi	sp,sp,-16
    80005f9c:	e422                	sd	s0,8(sp)
    80005f9e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005fa0:	0c0007b7          	lui	a5,0xc000
    80005fa4:	4705                	li	a4,1
    80005fa6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005fa8:	c3d8                	sw	a4,4(a5)
}
    80005faa:	6422                	ld	s0,8(sp)
    80005fac:	0141                	addi	sp,sp,16
    80005fae:	8082                	ret

0000000080005fb0 <plicinithart>:

void
plicinithart(void)
{
    80005fb0:	1141                	addi	sp,sp,-16
    80005fb2:	e406                	sd	ra,8(sp)
    80005fb4:	e022                	sd	s0,0(sp)
    80005fb6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005fb8:	ffffc097          	auipc	ra,0xffffc
    80005fbc:	aec080e7          	jalr	-1300(ra) # 80001aa4 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005fc0:	0085171b          	slliw	a4,a0,0x8
    80005fc4:	0c0027b7          	lui	a5,0xc002
    80005fc8:	97ba                	add	a5,a5,a4
    80005fca:	40200713          	li	a4,1026
    80005fce:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005fd2:	00d5151b          	slliw	a0,a0,0xd
    80005fd6:	0c2017b7          	lui	a5,0xc201
    80005fda:	953e                	add	a0,a0,a5
    80005fdc:	00052023          	sw	zero,0(a0)
}
    80005fe0:	60a2                	ld	ra,8(sp)
    80005fe2:	6402                	ld	s0,0(sp)
    80005fe4:	0141                	addi	sp,sp,16
    80005fe6:	8082                	ret

0000000080005fe8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005fe8:	1141                	addi	sp,sp,-16
    80005fea:	e406                	sd	ra,8(sp)
    80005fec:	e022                	sd	s0,0(sp)
    80005fee:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ff0:	ffffc097          	auipc	ra,0xffffc
    80005ff4:	ab4080e7          	jalr	-1356(ra) # 80001aa4 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005ff8:	00d5179b          	slliw	a5,a0,0xd
    80005ffc:	0c201537          	lui	a0,0xc201
    80006000:	953e                	add	a0,a0,a5
  return irq;
}
    80006002:	4148                	lw	a0,4(a0)
    80006004:	60a2                	ld	ra,8(sp)
    80006006:	6402                	ld	s0,0(sp)
    80006008:	0141                	addi	sp,sp,16
    8000600a:	8082                	ret

000000008000600c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000600c:	1101                	addi	sp,sp,-32
    8000600e:	ec06                	sd	ra,24(sp)
    80006010:	e822                	sd	s0,16(sp)
    80006012:	e426                	sd	s1,8(sp)
    80006014:	1000                	addi	s0,sp,32
    80006016:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006018:	ffffc097          	auipc	ra,0xffffc
    8000601c:	a8c080e7          	jalr	-1396(ra) # 80001aa4 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006020:	00d5151b          	slliw	a0,a0,0xd
    80006024:	0c2017b7          	lui	a5,0xc201
    80006028:	97aa                	add	a5,a5,a0
    8000602a:	c3c4                	sw	s1,4(a5)
}
    8000602c:	60e2                	ld	ra,24(sp)
    8000602e:	6442                	ld	s0,16(sp)
    80006030:	64a2                	ld	s1,8(sp)
    80006032:	6105                	addi	sp,sp,32
    80006034:	8082                	ret

0000000080006036 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006036:	1141                	addi	sp,sp,-16
    80006038:	e406                	sd	ra,8(sp)
    8000603a:	e022                	sd	s0,0(sp)
    8000603c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000603e:	479d                	li	a5,7
    80006040:	04a7cc63          	blt	a5,a0,80006098 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006044:	0001e797          	auipc	a5,0x1e
    80006048:	8ac78793          	addi	a5,a5,-1876 # 800238f0 <disk>
    8000604c:	97aa                	add	a5,a5,a0
    8000604e:	0187c783          	lbu	a5,24(a5)
    80006052:	ebb9                	bnez	a5,800060a8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006054:	00451613          	slli	a2,a0,0x4
    80006058:	0001e797          	auipc	a5,0x1e
    8000605c:	89878793          	addi	a5,a5,-1896 # 800238f0 <disk>
    80006060:	6394                	ld	a3,0(a5)
    80006062:	96b2                	add	a3,a3,a2
    80006064:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006068:	6398                	ld	a4,0(a5)
    8000606a:	9732                	add	a4,a4,a2
    8000606c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006070:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006074:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006078:	953e                	add	a0,a0,a5
    8000607a:	4785                	li	a5,1
    8000607c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80006080:	0001e517          	auipc	a0,0x1e
    80006084:	88850513          	addi	a0,a0,-1912 # 80023908 <disk+0x18>
    80006088:	ffffc097          	auipc	ra,0xffffc
    8000608c:	1ce080e7          	jalr	462(ra) # 80002256 <wakeup>
}
    80006090:	60a2                	ld	ra,8(sp)
    80006092:	6402                	ld	s0,0(sp)
    80006094:	0141                	addi	sp,sp,16
    80006096:	8082                	ret
    panic("free_desc 1");
    80006098:	00002517          	auipc	a0,0x2
    8000609c:	7e050513          	addi	a0,a0,2016 # 80008878 <syscalls+0x308>
    800060a0:	ffffa097          	auipc	ra,0xffffa
    800060a4:	4a4080e7          	jalr	1188(ra) # 80000544 <panic>
    panic("free_desc 2");
    800060a8:	00002517          	auipc	a0,0x2
    800060ac:	7e050513          	addi	a0,a0,2016 # 80008888 <syscalls+0x318>
    800060b0:	ffffa097          	auipc	ra,0xffffa
    800060b4:	494080e7          	jalr	1172(ra) # 80000544 <panic>

00000000800060b8 <virtio_disk_init>:
{
    800060b8:	1101                	addi	sp,sp,-32
    800060ba:	ec06                	sd	ra,24(sp)
    800060bc:	e822                	sd	s0,16(sp)
    800060be:	e426                	sd	s1,8(sp)
    800060c0:	e04a                	sd	s2,0(sp)
    800060c2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800060c4:	00002597          	auipc	a1,0x2
    800060c8:	7d458593          	addi	a1,a1,2004 # 80008898 <syscalls+0x328>
    800060cc:	0001e517          	auipc	a0,0x1e
    800060d0:	94c50513          	addi	a0,a0,-1716 # 80023a18 <disk+0x128>
    800060d4:	ffffb097          	auipc	ra,0xffffb
    800060d8:	a86080e7          	jalr	-1402(ra) # 80000b5a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800060dc:	100017b7          	lui	a5,0x10001
    800060e0:	4398                	lw	a4,0(a5)
    800060e2:	2701                	sext.w	a4,a4
    800060e4:	747277b7          	lui	a5,0x74727
    800060e8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800060ec:	14f71e63          	bne	a4,a5,80006248 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800060f0:	100017b7          	lui	a5,0x10001
    800060f4:	43dc                	lw	a5,4(a5)
    800060f6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800060f8:	4709                	li	a4,2
    800060fa:	14e79763          	bne	a5,a4,80006248 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800060fe:	100017b7          	lui	a5,0x10001
    80006102:	479c                	lw	a5,8(a5)
    80006104:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006106:	14e79163          	bne	a5,a4,80006248 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000610a:	100017b7          	lui	a5,0x10001
    8000610e:	47d8                	lw	a4,12(a5)
    80006110:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006112:	554d47b7          	lui	a5,0x554d4
    80006116:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000611a:	12f71763          	bne	a4,a5,80006248 <virtio_disk_init+0x190>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000611e:	100017b7          	lui	a5,0x10001
    80006122:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006126:	4705                	li	a4,1
    80006128:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000612a:	470d                	li	a4,3
    8000612c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000612e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006130:	c7ffe737          	lui	a4,0xc7ffe
    80006134:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdad2f>
    80006138:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000613a:	2701                	sext.w	a4,a4
    8000613c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000613e:	472d                	li	a4,11
    80006140:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006142:	0707a903          	lw	s2,112(a5)
    80006146:	2901                	sext.w	s2,s2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006148:	00897793          	andi	a5,s2,8
    8000614c:	10078663          	beqz	a5,80006258 <virtio_disk_init+0x1a0>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006150:	100017b7          	lui	a5,0x10001
    80006154:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006158:	43fc                	lw	a5,68(a5)
    8000615a:	2781                	sext.w	a5,a5
    8000615c:	10079663          	bnez	a5,80006268 <virtio_disk_init+0x1b0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006160:	100017b7          	lui	a5,0x10001
    80006164:	5bdc                	lw	a5,52(a5)
    80006166:	2781                	sext.w	a5,a5
  if(max == 0)
    80006168:	10078863          	beqz	a5,80006278 <virtio_disk_init+0x1c0>
  if(max < NUM)
    8000616c:	471d                	li	a4,7
    8000616e:	10f77d63          	bgeu	a4,a5,80006288 <virtio_disk_init+0x1d0>
  disk.desc = kalloc();
    80006172:	ffffb097          	auipc	ra,0xffffb
    80006176:	988080e7          	jalr	-1656(ra) # 80000afa <kalloc>
    8000617a:	0001d497          	auipc	s1,0x1d
    8000617e:	77648493          	addi	s1,s1,1910 # 800238f0 <disk>
    80006182:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006184:	ffffb097          	auipc	ra,0xffffb
    80006188:	976080e7          	jalr	-1674(ra) # 80000afa <kalloc>
    8000618c:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000618e:	ffffb097          	auipc	ra,0xffffb
    80006192:	96c080e7          	jalr	-1684(ra) # 80000afa <kalloc>
    80006196:	87aa                	mv	a5,a0
    80006198:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    8000619a:	6088                	ld	a0,0(s1)
    8000619c:	cd75                	beqz	a0,80006298 <virtio_disk_init+0x1e0>
    8000619e:	0001d717          	auipc	a4,0x1d
    800061a2:	75a73703          	ld	a4,1882(a4) # 800238f8 <disk+0x8>
    800061a6:	cb6d                	beqz	a4,80006298 <virtio_disk_init+0x1e0>
    800061a8:	cbe5                	beqz	a5,80006298 <virtio_disk_init+0x1e0>
  memset(disk.desc, 0, PGSIZE);
    800061aa:	6605                	lui	a2,0x1
    800061ac:	4581                	li	a1,0
    800061ae:	ffffb097          	auipc	ra,0xffffb
    800061b2:	b38080e7          	jalr	-1224(ra) # 80000ce6 <memset>
  memset(disk.avail, 0, PGSIZE);
    800061b6:	0001d497          	auipc	s1,0x1d
    800061ba:	73a48493          	addi	s1,s1,1850 # 800238f0 <disk>
    800061be:	6605                	lui	a2,0x1
    800061c0:	4581                	li	a1,0
    800061c2:	6488                	ld	a0,8(s1)
    800061c4:	ffffb097          	auipc	ra,0xffffb
    800061c8:	b22080e7          	jalr	-1246(ra) # 80000ce6 <memset>
  memset(disk.used, 0, PGSIZE);
    800061cc:	6605                	lui	a2,0x1
    800061ce:	4581                	li	a1,0
    800061d0:	6888                	ld	a0,16(s1)
    800061d2:	ffffb097          	auipc	ra,0xffffb
    800061d6:	b14080e7          	jalr	-1260(ra) # 80000ce6 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800061da:	100017b7          	lui	a5,0x10001
    800061de:	4721                	li	a4,8
    800061e0:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800061e2:	4098                	lw	a4,0(s1)
    800061e4:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800061e8:	40d8                	lw	a4,4(s1)
    800061ea:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800061ee:	6498                	ld	a4,8(s1)
    800061f0:	0007069b          	sext.w	a3,a4
    800061f4:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800061f8:	9701                	srai	a4,a4,0x20
    800061fa:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800061fe:	6898                	ld	a4,16(s1)
    80006200:	0007069b          	sext.w	a3,a4
    80006204:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006208:	9701                	srai	a4,a4,0x20
    8000620a:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000620e:	4685                	li	a3,1
    80006210:	c3f4                	sw	a3,68(a5)
    disk.free[i] = 1;
    80006212:	4705                	li	a4,1
    80006214:	00d48c23          	sb	a3,24(s1)
    80006218:	00e48ca3          	sb	a4,25(s1)
    8000621c:	00e48d23          	sb	a4,26(s1)
    80006220:	00e48da3          	sb	a4,27(s1)
    80006224:	00e48e23          	sb	a4,28(s1)
    80006228:	00e48ea3          	sb	a4,29(s1)
    8000622c:	00e48f23          	sb	a4,30(s1)
    80006230:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006234:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006238:	0727a823          	sw	s2,112(a5)
}
    8000623c:	60e2                	ld	ra,24(sp)
    8000623e:	6442                	ld	s0,16(sp)
    80006240:	64a2                	ld	s1,8(sp)
    80006242:	6902                	ld	s2,0(sp)
    80006244:	6105                	addi	sp,sp,32
    80006246:	8082                	ret
    panic("could not find virtio disk");
    80006248:	00002517          	auipc	a0,0x2
    8000624c:	66050513          	addi	a0,a0,1632 # 800088a8 <syscalls+0x338>
    80006250:	ffffa097          	auipc	ra,0xffffa
    80006254:	2f4080e7          	jalr	756(ra) # 80000544 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006258:	00002517          	auipc	a0,0x2
    8000625c:	67050513          	addi	a0,a0,1648 # 800088c8 <syscalls+0x358>
    80006260:	ffffa097          	auipc	ra,0xffffa
    80006264:	2e4080e7          	jalr	740(ra) # 80000544 <panic>
    panic("virtio disk should not be ready");
    80006268:	00002517          	auipc	a0,0x2
    8000626c:	68050513          	addi	a0,a0,1664 # 800088e8 <syscalls+0x378>
    80006270:	ffffa097          	auipc	ra,0xffffa
    80006274:	2d4080e7          	jalr	724(ra) # 80000544 <panic>
    panic("virtio disk has no queue 0");
    80006278:	00002517          	auipc	a0,0x2
    8000627c:	69050513          	addi	a0,a0,1680 # 80008908 <syscalls+0x398>
    80006280:	ffffa097          	auipc	ra,0xffffa
    80006284:	2c4080e7          	jalr	708(ra) # 80000544 <panic>
    panic("virtio disk max queue too short");
    80006288:	00002517          	auipc	a0,0x2
    8000628c:	6a050513          	addi	a0,a0,1696 # 80008928 <syscalls+0x3b8>
    80006290:	ffffa097          	auipc	ra,0xffffa
    80006294:	2b4080e7          	jalr	692(ra) # 80000544 <panic>
    panic("virtio disk kalloc");
    80006298:	00002517          	auipc	a0,0x2
    8000629c:	6b050513          	addi	a0,a0,1712 # 80008948 <syscalls+0x3d8>
    800062a0:	ffffa097          	auipc	ra,0xffffa
    800062a4:	2a4080e7          	jalr	676(ra) # 80000544 <panic>

00000000800062a8 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800062a8:	7159                	addi	sp,sp,-112
    800062aa:	f486                	sd	ra,104(sp)
    800062ac:	f0a2                	sd	s0,96(sp)
    800062ae:	eca6                	sd	s1,88(sp)
    800062b0:	e8ca                	sd	s2,80(sp)
    800062b2:	e4ce                	sd	s3,72(sp)
    800062b4:	e0d2                	sd	s4,64(sp)
    800062b6:	fc56                	sd	s5,56(sp)
    800062b8:	f85a                	sd	s6,48(sp)
    800062ba:	f45e                	sd	s7,40(sp)
    800062bc:	f062                	sd	s8,32(sp)
    800062be:	ec66                	sd	s9,24(sp)
    800062c0:	e86a                	sd	s10,16(sp)
    800062c2:	1880                	addi	s0,sp,112
    800062c4:	892a                	mv	s2,a0
    800062c6:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800062c8:	00c52c83          	lw	s9,12(a0)
    800062cc:	001c9c9b          	slliw	s9,s9,0x1
    800062d0:	1c82                	slli	s9,s9,0x20
    800062d2:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800062d6:	0001d517          	auipc	a0,0x1d
    800062da:	74250513          	addi	a0,a0,1858 # 80023a18 <disk+0x128>
    800062de:	ffffb097          	auipc	ra,0xffffb
    800062e2:	90c080e7          	jalr	-1780(ra) # 80000bea <acquire>
  for(int i = 0; i < 3; i++){
    800062e6:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800062e8:	4ba1                	li	s7,8
      disk.free[i] = 0;
    800062ea:	0001db17          	auipc	s6,0x1d
    800062ee:	606b0b13          	addi	s6,s6,1542 # 800238f0 <disk>
  for(int i = 0; i < 3; i++){
    800062f2:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    800062f4:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800062f6:	0001dc17          	auipc	s8,0x1d
    800062fa:	722c0c13          	addi	s8,s8,1826 # 80023a18 <disk+0x128>
    800062fe:	a8b5                	j	8000637a <virtio_disk_rw+0xd2>
      disk.free[i] = 0;
    80006300:	00fb06b3          	add	a3,s6,a5
    80006304:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006308:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    8000630a:	0207c563          	bltz	a5,80006334 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000630e:	2485                	addiw	s1,s1,1
    80006310:	0711                	addi	a4,a4,4
    80006312:	1f548a63          	beq	s1,s5,80006506 <virtio_disk_rw+0x25e>
    idx[i] = alloc_desc();
    80006316:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80006318:	0001d697          	auipc	a3,0x1d
    8000631c:	5d868693          	addi	a3,a3,1496 # 800238f0 <disk>
    80006320:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80006322:	0186c583          	lbu	a1,24(a3)
    80006326:	fde9                	bnez	a1,80006300 <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006328:	2785                	addiw	a5,a5,1
    8000632a:	0685                	addi	a3,a3,1
    8000632c:	ff779be3          	bne	a5,s7,80006322 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    80006330:	57fd                	li	a5,-1
    80006332:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80006334:	02905a63          	blez	s1,80006368 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    80006338:	f9042503          	lw	a0,-112(s0)
    8000633c:	00000097          	auipc	ra,0x0
    80006340:	cfa080e7          	jalr	-774(ra) # 80006036 <free_desc>
      for(int j = 0; j < i; j++)
    80006344:	4785                	li	a5,1
    80006346:	0297d163          	bge	a5,s1,80006368 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000634a:	f9442503          	lw	a0,-108(s0)
    8000634e:	00000097          	auipc	ra,0x0
    80006352:	ce8080e7          	jalr	-792(ra) # 80006036 <free_desc>
      for(int j = 0; j < i; j++)
    80006356:	4789                	li	a5,2
    80006358:	0097d863          	bge	a5,s1,80006368 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000635c:	f9842503          	lw	a0,-104(s0)
    80006360:	00000097          	auipc	ra,0x0
    80006364:	cd6080e7          	jalr	-810(ra) # 80006036 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006368:	85e2                	mv	a1,s8
    8000636a:	0001d517          	auipc	a0,0x1d
    8000636e:	59e50513          	addi	a0,a0,1438 # 80023908 <disk+0x18>
    80006372:	ffffc097          	auipc	ra,0xffffc
    80006376:	e76080e7          	jalr	-394(ra) # 800021e8 <sleep>
  for(int i = 0; i < 3; i++){
    8000637a:	f9040713          	addi	a4,s0,-112
    8000637e:	84ce                	mv	s1,s3
    80006380:	bf59                	j	80006316 <virtio_disk_rw+0x6e>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80006382:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    80006386:	00479693          	slli	a3,a5,0x4
    8000638a:	0001d797          	auipc	a5,0x1d
    8000638e:	56678793          	addi	a5,a5,1382 # 800238f0 <disk>
    80006392:	97b6                	add	a5,a5,a3
    80006394:	4685                	li	a3,1
    80006396:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006398:	0001d597          	auipc	a1,0x1d
    8000639c:	55858593          	addi	a1,a1,1368 # 800238f0 <disk>
    800063a0:	00a60793          	addi	a5,a2,10
    800063a4:	0792                	slli	a5,a5,0x4
    800063a6:	97ae                	add	a5,a5,a1
    800063a8:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    800063ac:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800063b0:	f6070693          	addi	a3,a4,-160
    800063b4:	619c                	ld	a5,0(a1)
    800063b6:	97b6                	add	a5,a5,a3
    800063b8:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800063ba:	6188                	ld	a0,0(a1)
    800063bc:	96aa                	add	a3,a3,a0
    800063be:	47c1                	li	a5,16
    800063c0:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800063c2:	4785                	li	a5,1
    800063c4:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    800063c8:	f9442783          	lw	a5,-108(s0)
    800063cc:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800063d0:	0792                	slli	a5,a5,0x4
    800063d2:	953e                	add	a0,a0,a5
    800063d4:	05890693          	addi	a3,s2,88
    800063d8:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    800063da:	6188                	ld	a0,0(a1)
    800063dc:	97aa                	add	a5,a5,a0
    800063de:	40000693          	li	a3,1024
    800063e2:	c794                	sw	a3,8(a5)
  if(write)
    800063e4:	100d0d63          	beqz	s10,800064fe <virtio_disk_rw+0x256>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800063e8:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800063ec:	00c7d683          	lhu	a3,12(a5)
    800063f0:	0016e693          	ori	a3,a3,1
    800063f4:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    800063f8:	f9842583          	lw	a1,-104(s0)
    800063fc:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006400:	0001d697          	auipc	a3,0x1d
    80006404:	4f068693          	addi	a3,a3,1264 # 800238f0 <disk>
    80006408:	00260793          	addi	a5,a2,2
    8000640c:	0792                	slli	a5,a5,0x4
    8000640e:	97b6                	add	a5,a5,a3
    80006410:	587d                	li	a6,-1
    80006412:	01078823          	sb	a6,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006416:	0592                	slli	a1,a1,0x4
    80006418:	952e                	add	a0,a0,a1
    8000641a:	f9070713          	addi	a4,a4,-112
    8000641e:	9736                	add	a4,a4,a3
    80006420:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    80006422:	6298                	ld	a4,0(a3)
    80006424:	972e                	add	a4,a4,a1
    80006426:	4585                	li	a1,1
    80006428:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000642a:	4509                	li	a0,2
    8000642c:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    80006430:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006434:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    80006438:	0127b423          	sd	s2,8(a5)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000643c:	6698                	ld	a4,8(a3)
    8000643e:	00275783          	lhu	a5,2(a4)
    80006442:	8b9d                	andi	a5,a5,7
    80006444:	0786                	slli	a5,a5,0x1
    80006446:	97ba                	add	a5,a5,a4
    80006448:	00c79223          	sh	a2,4(a5)

  __sync_synchronize();
    8000644c:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006450:	6698                	ld	a4,8(a3)
    80006452:	00275783          	lhu	a5,2(a4)
    80006456:	2785                	addiw	a5,a5,1
    80006458:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000645c:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006460:	100017b7          	lui	a5,0x10001
    80006464:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006468:	00492703          	lw	a4,4(s2)
    8000646c:	4785                	li	a5,1
    8000646e:	02f71163          	bne	a4,a5,80006490 <virtio_disk_rw+0x1e8>
    sleep(b, &disk.vdisk_lock);
    80006472:	0001d997          	auipc	s3,0x1d
    80006476:	5a698993          	addi	s3,s3,1446 # 80023a18 <disk+0x128>
  while(b->disk == 1) {
    8000647a:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000647c:	85ce                	mv	a1,s3
    8000647e:	854a                	mv	a0,s2
    80006480:	ffffc097          	auipc	ra,0xffffc
    80006484:	d68080e7          	jalr	-664(ra) # 800021e8 <sleep>
  while(b->disk == 1) {
    80006488:	00492783          	lw	a5,4(s2)
    8000648c:	fe9788e3          	beq	a5,s1,8000647c <virtio_disk_rw+0x1d4>
  }

  disk.info[idx[0]].b = 0;
    80006490:	f9042903          	lw	s2,-112(s0)
    80006494:	00290793          	addi	a5,s2,2
    80006498:	00479713          	slli	a4,a5,0x4
    8000649c:	0001d797          	auipc	a5,0x1d
    800064a0:	45478793          	addi	a5,a5,1108 # 800238f0 <disk>
    800064a4:	97ba                	add	a5,a5,a4
    800064a6:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800064aa:	0001d997          	auipc	s3,0x1d
    800064ae:	44698993          	addi	s3,s3,1094 # 800238f0 <disk>
    800064b2:	00491713          	slli	a4,s2,0x4
    800064b6:	0009b783          	ld	a5,0(s3)
    800064ba:	97ba                	add	a5,a5,a4
    800064bc:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800064c0:	854a                	mv	a0,s2
    800064c2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800064c6:	00000097          	auipc	ra,0x0
    800064ca:	b70080e7          	jalr	-1168(ra) # 80006036 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800064ce:	8885                	andi	s1,s1,1
    800064d0:	f0ed                	bnez	s1,800064b2 <virtio_disk_rw+0x20a>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800064d2:	0001d517          	auipc	a0,0x1d
    800064d6:	54650513          	addi	a0,a0,1350 # 80023a18 <disk+0x128>
    800064da:	ffffa097          	auipc	ra,0xffffa
    800064de:	7c4080e7          	jalr	1988(ra) # 80000c9e <release>
}
    800064e2:	70a6                	ld	ra,104(sp)
    800064e4:	7406                	ld	s0,96(sp)
    800064e6:	64e6                	ld	s1,88(sp)
    800064e8:	6946                	ld	s2,80(sp)
    800064ea:	69a6                	ld	s3,72(sp)
    800064ec:	6a06                	ld	s4,64(sp)
    800064ee:	7ae2                	ld	s5,56(sp)
    800064f0:	7b42                	ld	s6,48(sp)
    800064f2:	7ba2                	ld	s7,40(sp)
    800064f4:	7c02                	ld	s8,32(sp)
    800064f6:	6ce2                	ld	s9,24(sp)
    800064f8:	6d42                	ld	s10,16(sp)
    800064fa:	6165                	addi	sp,sp,112
    800064fc:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800064fe:	4689                	li	a3,2
    80006500:	00d79623          	sh	a3,12(a5)
    80006504:	b5e5                	j	800063ec <virtio_disk_rw+0x144>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006506:	f9042603          	lw	a2,-112(s0)
    8000650a:	00a60713          	addi	a4,a2,10
    8000650e:	0712                	slli	a4,a4,0x4
    80006510:	0001d517          	auipc	a0,0x1d
    80006514:	3e850513          	addi	a0,a0,1000 # 800238f8 <disk+0x8>
    80006518:	953a                	add	a0,a0,a4
  if(write)
    8000651a:	e60d14e3          	bnez	s10,80006382 <virtio_disk_rw+0xda>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    8000651e:	00a60793          	addi	a5,a2,10
    80006522:	00479693          	slli	a3,a5,0x4
    80006526:	0001d797          	auipc	a5,0x1d
    8000652a:	3ca78793          	addi	a5,a5,970 # 800238f0 <disk>
    8000652e:	97b6                	add	a5,a5,a3
    80006530:	0007a423          	sw	zero,8(a5)
    80006534:	b595                	j	80006398 <virtio_disk_rw+0xf0>

0000000080006536 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006536:	1101                	addi	sp,sp,-32
    80006538:	ec06                	sd	ra,24(sp)
    8000653a:	e822                	sd	s0,16(sp)
    8000653c:	e426                	sd	s1,8(sp)
    8000653e:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006540:	0001d497          	auipc	s1,0x1d
    80006544:	3b048493          	addi	s1,s1,944 # 800238f0 <disk>
    80006548:	0001d517          	auipc	a0,0x1d
    8000654c:	4d050513          	addi	a0,a0,1232 # 80023a18 <disk+0x128>
    80006550:	ffffa097          	auipc	ra,0xffffa
    80006554:	69a080e7          	jalr	1690(ra) # 80000bea <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006558:	10001737          	lui	a4,0x10001
    8000655c:	533c                	lw	a5,96(a4)
    8000655e:	8b8d                	andi	a5,a5,3
    80006560:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006562:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006566:	689c                	ld	a5,16(s1)
    80006568:	0204d703          	lhu	a4,32(s1)
    8000656c:	0027d783          	lhu	a5,2(a5)
    80006570:	04f70863          	beq	a4,a5,800065c0 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006574:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006578:	6898                	ld	a4,16(s1)
    8000657a:	0204d783          	lhu	a5,32(s1)
    8000657e:	8b9d                	andi	a5,a5,7
    80006580:	078e                	slli	a5,a5,0x3
    80006582:	97ba                	add	a5,a5,a4
    80006584:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006586:	00278713          	addi	a4,a5,2
    8000658a:	0712                	slli	a4,a4,0x4
    8000658c:	9726                	add	a4,a4,s1
    8000658e:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006592:	e721                	bnez	a4,800065da <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006594:	0789                	addi	a5,a5,2
    80006596:	0792                	slli	a5,a5,0x4
    80006598:	97a6                	add	a5,a5,s1
    8000659a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000659c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800065a0:	ffffc097          	auipc	ra,0xffffc
    800065a4:	cb6080e7          	jalr	-842(ra) # 80002256 <wakeup>

    disk.used_idx += 1;
    800065a8:	0204d783          	lhu	a5,32(s1)
    800065ac:	2785                	addiw	a5,a5,1
    800065ae:	17c2                	slli	a5,a5,0x30
    800065b0:	93c1                	srli	a5,a5,0x30
    800065b2:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800065b6:	6898                	ld	a4,16(s1)
    800065b8:	00275703          	lhu	a4,2(a4)
    800065bc:	faf71ce3          	bne	a4,a5,80006574 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800065c0:	0001d517          	auipc	a0,0x1d
    800065c4:	45850513          	addi	a0,a0,1112 # 80023a18 <disk+0x128>
    800065c8:	ffffa097          	auipc	ra,0xffffa
    800065cc:	6d6080e7          	jalr	1750(ra) # 80000c9e <release>
}
    800065d0:	60e2                	ld	ra,24(sp)
    800065d2:	6442                	ld	s0,16(sp)
    800065d4:	64a2                	ld	s1,8(sp)
    800065d6:	6105                	addi	sp,sp,32
    800065d8:	8082                	ret
      panic("virtio_disk_intr status");
    800065da:	00002517          	auipc	a0,0x2
    800065de:	38650513          	addi	a0,a0,902 # 80008960 <syscalls+0x3f0>
    800065e2:	ffffa097          	auipc	ra,0xffffa
    800065e6:	f62080e7          	jalr	-158(ra) # 80000544 <panic>
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
