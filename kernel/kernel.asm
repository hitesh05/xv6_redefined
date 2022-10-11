
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
    80000068:	5ac78793          	addi	a5,a5,1452 # 80006610 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffda327>
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
    8000012c:	00003097          	auipc	ra,0x3
    80000130:	b44080e7          	jalr	-1212(ra) # 80002c70 <either_copyin>
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
    800001c8:	a26080e7          	jalr	-1498(ra) # 80001bea <myproc>
    800001cc:	00003097          	auipc	ra,0x3
    800001d0:	8d6080e7          	jalr	-1834(ra) # 80002aa2 <killed>
    800001d4:	e535                	bnez	a0,80000240 <consoleread+0xdc>
      sleep(&cons.r, &cons.lock);
    800001d6:	85ce                	mv	a1,s3
    800001d8:	854a                	mv	a0,s2
    800001da:	00002097          	auipc	ra,0x2
    800001de:	366080e7          	jalr	870(ra) # 80002540 <sleep>
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
    8000021a:	a04080e7          	jalr	-1532(ra) # 80002c1a <either_copyout>
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
    800002f8:	00003097          	auipc	ra,0x3
    800002fc:	9ce080e7          	jalr	-1586(ra) # 80002cc6 <procdump>
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
    80000450:	2d2080e7          	jalr	722(ra) # 8000271e <wakeup>
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
    80000462:	bb258593          	addi	a1,a1,-1102 # 80008010 <num_levels+0x8>
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
    8000047e:	00023797          	auipc	a5,0x23
    80000482:	ec278793          	addi	a5,a5,-318 # 80023340 <devsw>
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
    8000055c:	ac050513          	addi	a0,a0,-1344 # 80008018 <num_levels+0x10>
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
    80000614:	a1850513          	addi	a0,a0,-1512 # 80008028 <num_levels+0x20>
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
    80000714:	91090913          	addi	s2,s2,-1776 # 80008020 <num_levels+0x18>
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
    8000078a:	8b258593          	addi	a1,a1,-1870 # 80008038 <num_levels+0x30>
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
    800008aa:	e78080e7          	jalr	-392(ra) # 8000271e <wakeup>
    
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
    80000934:	c10080e7          	jalr	-1008(ra) # 80002540 <sleep>
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
    80000a12:	00024797          	auipc	a5,0x24
    80000a16:	ac678793          	addi	a5,a5,-1338 # 800244d8 <end>
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
    80000ae2:	00024517          	auipc	a0,0x24
    80000ae6:	9f650513          	addi	a0,a0,-1546 # 800244d8 <end>
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
    80000b88:	04a080e7          	jalr	74(ra) # 80001bce <mycpu>
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
    80000bba:	018080e7          	jalr	24(ra) # 80001bce <mycpu>
    80000bbe:	5d3c                	lw	a5,120(a0)
    80000bc0:	cf89                	beqz	a5,80000bda <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bc2:	00001097          	auipc	ra,0x1
    80000bc6:	00c080e7          	jalr	12(ra) # 80001bce <mycpu>
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
    80000bde:	ff4080e7          	jalr	-12(ra) # 80001bce <mycpu>
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
    80000c1e:	fb4080e7          	jalr	-76(ra) # 80001bce <mycpu>
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
    80000c4a:	f88080e7          	jalr	-120(ra) # 80001bce <mycpu>
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
    80000ea0:	d22080e7          	jalr	-734(ra) # 80001bbe <cpuid>
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
    80000ebc:	d06080e7          	jalr	-762(ra) # 80001bbe <cpuid>
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
    80000ede:	f30080e7          	jalr	-208(ra) # 80002e0a <trapinithart>
    // printf("trapinit done\n");
    plicinithart();   // ask PLIC for device interrupts
    80000ee2:	00005097          	auipc	ra,0x5
    80000ee6:	76e080e7          	jalr	1902(ra) # 80006650 <plicinithart>
    // printf("plicinit done\n");
  }

  // printf("about to call sceduler\n");
  scheduler();        
    80000eea:	00001097          	auipc	ra,0x1
    80000eee:	460080e7          	jalr	1120(ra) # 8000234a <scheduler>
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
    80000f4e:	bbe080e7          	jalr	-1090(ra) # 80001b08 <procinit>
    trapinit();      // trap vectors
    80000f52:	00002097          	auipc	ra,0x2
    80000f56:	e90080e7          	jalr	-368(ra) # 80002de2 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f5a:	00002097          	auipc	ra,0x2
    80000f5e:	eb0080e7          	jalr	-336(ra) # 80002e0a <trapinithart>
    plicinit();      // set up interrupt controller
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	6d8080e7          	jalr	1752(ra) # 8000663a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f6a:	00005097          	auipc	ra,0x5
    80000f6e:	6e6080e7          	jalr	1766(ra) # 80006650 <plicinithart>
    binit();         // buffer cache
    80000f72:	00003097          	auipc	ra,0x3
    80000f76:	898080e7          	jalr	-1896(ra) # 8000380a <binit>
    iinit();         // inode table
    80000f7a:	00003097          	auipc	ra,0x3
    80000f7e:	f3c080e7          	jalr	-196(ra) # 80003eb6 <iinit>
    fileinit();      // file table
    80000f82:	00004097          	auipc	ra,0x4
    80000f86:	eda080e7          	jalr	-294(ra) # 80004e5c <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f8a:	00005097          	auipc	ra,0x5
    80000f8e:	7ce080e7          	jalr	1998(ra) # 80006758 <virtio_disk_init>
    userinit();      // first user process
    80000f92:	00001097          	auipc	ra,0x1
    80000f96:	f98080e7          	jalr	-104(ra) # 80001f2a <userinit>
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
    8000124a:	00001097          	auipc	ra,0x1
    8000124e:	828080e7          	jalr	-2008(ra) # 80001a72 <proc_mapstacks>
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
    800018bc:	44048493          	addi	s1,s1,1088 # 80011cf8 <proc>
    800018c0:	00018a17          	auipc	s4,0x18
    800018c4:	838a0a13          	addi	s4,s4,-1992 # 800190f8 <tickslock>
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

0000000080001958 <pinit>:

#ifdef MLFQ
void pinit(void)
{
    80001958:	1141                	addi	sp,sp,-16
    8000195a:	e422                	sd	s0,8(sp)
    8000195c:	0800                	addi	s0,sp,16
	int i = 0;
	while (i < num_levels)
    8000195e:	00010797          	auipc	a5,0x10
    80001962:	92278793          	addi	a5,a5,-1758 # 80011280 <mlfq>
    80001966:	00010717          	auipc	a4,0x10
    8000196a:	39270713          	addi	a4,a4,914 # 80011cf8 <proc>
	{
		mlfq[i].head = 0;
    8000196e:	0007a023          	sw	zero,0(a5)
		mlfq[i].tail = 0;
    80001972:	0007a223          	sw	zero,4(a5)
		mlfq[i].size = 0;
    80001976:	2007a823          	sw	zero,528(a5)
	while (i < num_levels)
    8000197a:	21878793          	addi	a5,a5,536
    8000197e:	fee798e3          	bne	a5,a4,8000196e <pinit+0x16>
		i++;
	}
}
    80001982:	6422                	ld	s0,8(sp)
    80001984:	0141                	addi	sp,sp,16
    80001986:	8082                	ret

0000000080001988 <push>:

void push(Queue *q, struct proc *pr)
{
    80001988:	1141                	addi	sp,sp,-16
    8000198a:	e422                	sd	s0,8(sp)
    8000198c:	0800                	addi	s0,sp,16
	int tail = q->tail;
    8000198e:	415c                	lw	a5,4(a0)
	q->p[tail] = pr;
    80001990:	00379713          	slli	a4,a5,0x3
    80001994:	972a                	add	a4,a4,a0
    80001996:	e70c                	sd	a1,8(a4)
	q->tail++;
    80001998:	2785                	addiw	a5,a5,1
    8000199a:	0007869b          	sext.w	a3,a5

	int x = NPROC + 1;
	if (q->tail == x)
    8000199e:	04100713          	li	a4,65
    800019a2:	00e68b63          	beq	a3,a4,800019b8 <push+0x30>
	q->tail++;
    800019a6:	c15c                	sw	a5,4(a0)
	{
		q->tail = 0;
	}
	q->size++;
    800019a8:	21052783          	lw	a5,528(a0)
    800019ac:	2785                	addiw	a5,a5,1
    800019ae:	20f52823          	sw	a5,528(a0)
}
    800019b2:	6422                	ld	s0,8(sp)
    800019b4:	0141                	addi	sp,sp,16
    800019b6:	8082                	ret
		q->tail = 0;
    800019b8:	00052223          	sw	zero,4(a0)
    800019bc:	b7f5                	j	800019a8 <push+0x20>

00000000800019be <pop>:

void pop(Queue *q)
{
    800019be:	1141                	addi	sp,sp,-16
    800019c0:	e422                	sd	s0,8(sp)
    800019c2:	0800                	addi	s0,sp,16
	q->head++;
    800019c4:	411c                	lw	a5,0(a0)
    800019c6:	2785                	addiw	a5,a5,1
    800019c8:	0007869b          	sext.w	a3,a5
	int x = NPROC + 1;
	if (q->head == x)
    800019cc:	04100713          	li	a4,65
    800019d0:	00e68b63          	beq	a3,a4,800019e6 <pop+0x28>
	q->head++;
    800019d4:	c11c                	sw	a5,0(a0)
	{
		q->head = 0;
	}

	q->size--;
    800019d6:	21052783          	lw	a5,528(a0)
    800019da:	37fd                	addiw	a5,a5,-1
    800019dc:	20f52823          	sw	a5,528(a0)
}
    800019e0:	6422                	ld	s0,8(sp)
    800019e2:	0141                	addi	sp,sp,16
    800019e4:	8082                	ret
		q->head = 0;
    800019e6:	00052023          	sw	zero,0(a0)
    800019ea:	b7f5                	j	800019d6 <pop+0x18>

00000000800019ec <front>:

struct proc *front(Queue *q)
{
    800019ec:	1141                	addi	sp,sp,-16
    800019ee:	e422                	sd	s0,8(sp)
    800019f0:	0800                	addi	s0,sp,16
	if (q->head != q->tail)
    800019f2:	411c                	lw	a5,0(a0)
    800019f4:	4158                	lw	a4,4(a0)
    800019f6:	00f70863          	beq	a4,a5,80001a06 <front+0x1a>
	{
		return q->p[q->head];
    800019fa:	078e                	slli	a5,a5,0x3
    800019fc:	953e                	add	a0,a0,a5
    800019fe:	6508                	ld	a0,8(a0)
	}
	else
	{
		return 0;
	}
}
    80001a00:	6422                	ld	s0,8(sp)
    80001a02:	0141                	addi	sp,sp,16
    80001a04:	8082                	ret
		return 0;
    80001a06:	4501                	li	a0,0
    80001a08:	bfe5                	j	80001a00 <front+0x14>

0000000080001a0a <qerase>:

void qerase(Queue *q, int pid)
{
    80001a0a:	1141                	addi	sp,sp,-16
    80001a0c:	e422                	sd	s0,8(sp)
    80001a0e:	0800                	addi	s0,sp,16
	int head = q->head;
    80001a10:	411c                	lw	a5,0(a0)
	int tail = q->tail;
    80001a12:	00452883          	lw	a7,4(a0)
	int x = NPROC + 1;

	for (int curr = head; curr != tail; curr = (curr + 1) % x)
    80001a16:	03178d63          	beq	a5,a7,80001a50 <qerase+0x46>
		if (q->p[curr]->pid != pid)
		{
			continue;
		}
		struct proc *pr = q->p[curr];
		int z = (curr + 1) % x;
    80001a1a:	04100813          	li	a6,65
    80001a1e:	a031                	j	80001a2a <qerase+0x20>
	for (int curr = head; curr != tail; curr = (curr + 1) % x)
    80001a20:	2785                	addiw	a5,a5,1
    80001a22:	0307e7bb          	remw	a5,a5,a6
    80001a26:	02f88563          	beq	a7,a5,80001a50 <qerase+0x46>
		if (q->p[curr]->pid != pid)
    80001a2a:	00379693          	slli	a3,a5,0x3
    80001a2e:	96aa                	add	a3,a3,a0
    80001a30:	6690                	ld	a2,8(a3)
    80001a32:	5e18                	lw	a4,56(a2)
    80001a34:	feb716e3          	bne	a4,a1,80001a20 <qerase+0x16>
		int z = (curr + 1) % x;
    80001a38:	0017871b          	addiw	a4,a5,1
    80001a3c:	0307673b          	remw	a4,a4,a6
    80001a40:	070e                	slli	a4,a4,0x3
    80001a42:	972a                	add	a4,a4,a0
		q->p[curr] = q->p[z];
    80001a44:	00873303          	ld	t1,8(a4)
    80001a48:	0066b423          	sd	t1,8(a3) # 1008 <_entry-0x7fffeff8>
		q->p[z] = pr;
    80001a4c:	e710                	sd	a2,8(a4)
    80001a4e:	bfc9                	j	80001a20 <qerase+0x16>
	}
	if (q->tail == 0)
    80001a50:	00089d63          	bnez	a7,80001a6a <qerase+0x60>
	{
		q->tail = NPROC;
    80001a54:	04000793          	li	a5,64
    80001a58:	c15c                	sw	a5,4(a0)
	}
	else
	{
		q->tail--;
	}
	q->size--;
    80001a5a:	21052783          	lw	a5,528(a0)
    80001a5e:	37fd                	addiw	a5,a5,-1
    80001a60:	20f52823          	sw	a5,528(a0)
}
    80001a64:	6422                	ld	s0,8(sp)
    80001a66:	0141                	addi	sp,sp,16
    80001a68:	8082                	ret
		q->tail--;
    80001a6a:	38fd                	addiw	a7,a7,-1
    80001a6c:	01152223          	sw	a7,4(a0)
    80001a70:	b7ed                	j	80001a5a <qerase+0x50>

0000000080001a72 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    80001a72:	7139                	addi	sp,sp,-64
    80001a74:	fc06                	sd	ra,56(sp)
    80001a76:	f822                	sd	s0,48(sp)
    80001a78:	f426                	sd	s1,40(sp)
    80001a7a:	f04a                	sd	s2,32(sp)
    80001a7c:	ec4e                	sd	s3,24(sp)
    80001a7e:	e852                	sd	s4,16(sp)
    80001a80:	e456                	sd	s5,8(sp)
    80001a82:	e05a                	sd	s6,0(sp)
    80001a84:	0080                	addi	s0,sp,64
    80001a86:	89aa                	mv	s3,a0
	struct proc *p;

	for (p = proc; p < &proc[NPROC]; p++)
    80001a88:	00010497          	auipc	s1,0x10
    80001a8c:	27048493          	addi	s1,s1,624 # 80011cf8 <proc>
	{
		char *pa = kalloc();
		if (pa == 0)
			panic("kalloc");
		uint64 va = KSTACK((int)(p - proc));
    80001a90:	8b26                	mv	s6,s1
    80001a92:	00006a97          	auipc	s5,0x6
    80001a96:	56ea8a93          	addi	s5,s5,1390 # 80008000 <etext>
    80001a9a:	04000937          	lui	s2,0x4000
    80001a9e:	197d                	addi	s2,s2,-1
    80001aa0:	0932                	slli	s2,s2,0xc
	for (p = proc; p < &proc[NPROC]; p++)
    80001aa2:	00017a17          	auipc	s4,0x17
    80001aa6:	656a0a13          	addi	s4,s4,1622 # 800190f8 <tickslock>
		char *pa = kalloc();
    80001aaa:	fffff097          	auipc	ra,0xfffff
    80001aae:	050080e7          	jalr	80(ra) # 80000afa <kalloc>
    80001ab2:	862a                	mv	a2,a0
		if (pa == 0)
    80001ab4:	c131                	beqz	a0,80001af8 <proc_mapstacks+0x86>
		uint64 va = KSTACK((int)(p - proc));
    80001ab6:	416485b3          	sub	a1,s1,s6
    80001aba:	8591                	srai	a1,a1,0x4
    80001abc:	000ab783          	ld	a5,0(s5)
    80001ac0:	02f585b3          	mul	a1,a1,a5
    80001ac4:	2585                	addiw	a1,a1,1
    80001ac6:	00d5959b          	slliw	a1,a1,0xd
		kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001aca:	4719                	li	a4,6
    80001acc:	6685                	lui	a3,0x1
    80001ace:	40b905b3          	sub	a1,s2,a1
    80001ad2:	854e                	mv	a0,s3
    80001ad4:	fffff097          	auipc	ra,0xfffff
    80001ad8:	686080e7          	jalr	1670(ra) # 8000115a <kvmmap>
	for (p = proc; p < &proc[NPROC]; p++)
    80001adc:	1d048493          	addi	s1,s1,464
    80001ae0:	fd4495e3          	bne	s1,s4,80001aaa <proc_mapstacks+0x38>
	}
}
    80001ae4:	70e2                	ld	ra,56(sp)
    80001ae6:	7442                	ld	s0,48(sp)
    80001ae8:	74a2                	ld	s1,40(sp)
    80001aea:	7902                	ld	s2,32(sp)
    80001aec:	69e2                	ld	s3,24(sp)
    80001aee:	6a42                	ld	s4,16(sp)
    80001af0:	6aa2                	ld	s5,8(sp)
    80001af2:	6b02                	ld	s6,0(sp)
    80001af4:	6121                	addi	sp,sp,64
    80001af6:	8082                	ret
			panic("kalloc");
    80001af8:	00006517          	auipc	a0,0x6
    80001afc:	6f850513          	addi	a0,a0,1784 # 800081f0 <digits+0x1b0>
    80001b00:	fffff097          	auipc	ra,0xfffff
    80001b04:	a44080e7          	jalr	-1468(ra) # 80000544 <panic>

0000000080001b08 <procinit>:

// initialize the proc table.
void procinit(void)
{
    80001b08:	7139                	addi	sp,sp,-64
    80001b0a:	fc06                	sd	ra,56(sp)
    80001b0c:	f822                	sd	s0,48(sp)
    80001b0e:	f426                	sd	s1,40(sp)
    80001b10:	f04a                	sd	s2,32(sp)
    80001b12:	ec4e                	sd	s3,24(sp)
    80001b14:	e852                	sd	s4,16(sp)
    80001b16:	e456                	sd	s5,8(sp)
    80001b18:	e05a                	sd	s6,0(sp)
    80001b1a:	0080                	addi	s0,sp,64
	struct proc *p;

	initlock(&pid_lock, "nextpid");
    80001b1c:	00006597          	auipc	a1,0x6
    80001b20:	6dc58593          	addi	a1,a1,1756 # 800081f8 <digits+0x1b8>
    80001b24:	0000f517          	auipc	a0,0xf
    80001b28:	32c50513          	addi	a0,a0,812 # 80010e50 <pid_lock>
    80001b2c:	fffff097          	auipc	ra,0xfffff
    80001b30:	02e080e7          	jalr	46(ra) # 80000b5a <initlock>
	initlock(&wait_lock, "wait_lock");
    80001b34:	00006597          	auipc	a1,0x6
    80001b38:	6cc58593          	addi	a1,a1,1740 # 80008200 <digits+0x1c0>
    80001b3c:	0000f517          	auipc	a0,0xf
    80001b40:	32c50513          	addi	a0,a0,812 # 80010e68 <wait_lock>
    80001b44:	fffff097          	auipc	ra,0xfffff
    80001b48:	016080e7          	jalr	22(ra) # 80000b5a <initlock>
	for (p = proc; p < &proc[NPROC]; p++)
    80001b4c:	00010497          	auipc	s1,0x10
    80001b50:	1ac48493          	addi	s1,s1,428 # 80011cf8 <proc>
	{
		initlock(&p->lock, "proc");
    80001b54:	00006b17          	auipc	s6,0x6
    80001b58:	6bcb0b13          	addi	s6,s6,1724 # 80008210 <digits+0x1d0>
		p->state = UNUSED;
		p->kstack = KSTACK((int)(p - proc));
    80001b5c:	8aa6                	mv	s5,s1
    80001b5e:	00006a17          	auipc	s4,0x6
    80001b62:	4a2a0a13          	addi	s4,s4,1186 # 80008000 <etext>
    80001b66:	04000937          	lui	s2,0x4000
    80001b6a:	197d                	addi	s2,s2,-1
    80001b6c:	0932                	slli	s2,s2,0xc
	for (p = proc; p < &proc[NPROC]; p++)
    80001b6e:	00017997          	auipc	s3,0x17
    80001b72:	58a98993          	addi	s3,s3,1418 # 800190f8 <tickslock>
		initlock(&p->lock, "proc");
    80001b76:	85da                	mv	a1,s6
    80001b78:	00848513          	addi	a0,s1,8
    80001b7c:	fffff097          	auipc	ra,0xfffff
    80001b80:	fde080e7          	jalr	-34(ra) # 80000b5a <initlock>
		p->state = UNUSED;
    80001b84:	0204a023          	sw	zero,32(s1)
		p->kstack = KSTACK((int)(p - proc));
    80001b88:	415487b3          	sub	a5,s1,s5
    80001b8c:	8791                	srai	a5,a5,0x4
    80001b8e:	000a3703          	ld	a4,0(s4)
    80001b92:	02e787b3          	mul	a5,a5,a4
    80001b96:	2785                	addiw	a5,a5,1
    80001b98:	00d7979b          	slliw	a5,a5,0xd
    80001b9c:	40f907b3          	sub	a5,s2,a5
    80001ba0:	e4bc                	sd	a5,72(s1)
	for (p = proc; p < &proc[NPROC]; p++)
    80001ba2:	1d048493          	addi	s1,s1,464
    80001ba6:	fd3498e3          	bne	s1,s3,80001b76 <procinit+0x6e>
	}
}
    80001baa:	70e2                	ld	ra,56(sp)
    80001bac:	7442                	ld	s0,48(sp)
    80001bae:	74a2                	ld	s1,40(sp)
    80001bb0:	7902                	ld	s2,32(sp)
    80001bb2:	69e2                	ld	s3,24(sp)
    80001bb4:	6a42                	ld	s4,16(sp)
    80001bb6:	6aa2                	ld	s5,8(sp)
    80001bb8:	6b02                	ld	s6,0(sp)
    80001bba:	6121                	addi	sp,sp,64
    80001bbc:	8082                	ret

0000000080001bbe <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    80001bbe:	1141                	addi	sp,sp,-16
    80001bc0:	e422                	sd	s0,8(sp)
    80001bc2:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001bc4:	8512                	mv	a0,tp
	int id = r_tp();
	return id;
}
    80001bc6:	2501                	sext.w	a0,a0
    80001bc8:	6422                	ld	s0,8(sp)
    80001bca:	0141                	addi	sp,sp,16
    80001bcc:	8082                	ret

0000000080001bce <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001bce:	1141                	addi	sp,sp,-16
    80001bd0:	e422                	sd	s0,8(sp)
    80001bd2:	0800                	addi	s0,sp,16
    80001bd4:	8792                	mv	a5,tp
	int id = cpuid();
	struct cpu *c = &cpus[id];
    80001bd6:	2781                	sext.w	a5,a5
    80001bd8:	079e                	slli	a5,a5,0x7
	return c;
}
    80001bda:	0000f517          	auipc	a0,0xf
    80001bde:	2a650513          	addi	a0,a0,678 # 80010e80 <cpus>
    80001be2:	953e                	add	a0,a0,a5
    80001be4:	6422                	ld	s0,8(sp)
    80001be6:	0141                	addi	sp,sp,16
    80001be8:	8082                	ret

0000000080001bea <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001bea:	1101                	addi	sp,sp,-32
    80001bec:	ec06                	sd	ra,24(sp)
    80001bee:	e822                	sd	s0,16(sp)
    80001bf0:	e426                	sd	s1,8(sp)
    80001bf2:	1000                	addi	s0,sp,32
	push_off();
    80001bf4:	fffff097          	auipc	ra,0xfffff
    80001bf8:	faa080e7          	jalr	-86(ra) # 80000b9e <push_off>
    80001bfc:	8792                	mv	a5,tp
	struct cpu *c = mycpu();
	struct proc *p = c->proc;
    80001bfe:	2781                	sext.w	a5,a5
    80001c00:	079e                	slli	a5,a5,0x7
    80001c02:	0000f717          	auipc	a4,0xf
    80001c06:	24e70713          	addi	a4,a4,590 # 80010e50 <pid_lock>
    80001c0a:	97ba                	add	a5,a5,a4
    80001c0c:	7b84                	ld	s1,48(a5)
	pop_off();
    80001c0e:	fffff097          	auipc	ra,0xfffff
    80001c12:	030080e7          	jalr	48(ra) # 80000c3e <pop_off>
	return p;
}
    80001c16:	8526                	mv	a0,s1
    80001c18:	60e2                	ld	ra,24(sp)
    80001c1a:	6442                	ld	s0,16(sp)
    80001c1c:	64a2                	ld	s1,8(sp)
    80001c1e:	6105                	addi	sp,sp,32
    80001c20:	8082                	ret

0000000080001c22 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001c22:	1141                	addi	sp,sp,-16
    80001c24:	e406                	sd	ra,8(sp)
    80001c26:	e022                	sd	s0,0(sp)
    80001c28:	0800                	addi	s0,sp,16
	static int first = 1;

	// Still holding p->lock from scheduler.
	release(&myproc()->lock);
    80001c2a:	00000097          	auipc	ra,0x0
    80001c2e:	fc0080e7          	jalr	-64(ra) # 80001bea <myproc>
    80001c32:	0521                	addi	a0,a0,8
    80001c34:	fffff097          	auipc	ra,0xfffff
    80001c38:	06a080e7          	jalr	106(ra) # 80000c9e <release>

	if (first)
    80001c3c:	00007797          	auipc	a5,0x7
    80001c40:	d647a783          	lw	a5,-668(a5) # 800089a0 <first.2513>
    80001c44:	eb89                	bnez	a5,80001c56 <forkret+0x34>
		// be run from main().
		first = 0;
		fsinit(ROOTDEV);
	}

	usertrapret();
    80001c46:	00001097          	auipc	ra,0x1
    80001c4a:	1dc080e7          	jalr	476(ra) # 80002e22 <usertrapret>
}
    80001c4e:	60a2                	ld	ra,8(sp)
    80001c50:	6402                	ld	s0,0(sp)
    80001c52:	0141                	addi	sp,sp,16
    80001c54:	8082                	ret
		first = 0;
    80001c56:	00007797          	auipc	a5,0x7
    80001c5a:	d407a523          	sw	zero,-694(a5) # 800089a0 <first.2513>
		fsinit(ROOTDEV);
    80001c5e:	4505                	li	a0,1
    80001c60:	00002097          	auipc	ra,0x2
    80001c64:	1d6080e7          	jalr	470(ra) # 80003e36 <fsinit>
    80001c68:	bff9                	j	80001c46 <forkret+0x24>

0000000080001c6a <allocpid>:
{
    80001c6a:	1101                	addi	sp,sp,-32
    80001c6c:	ec06                	sd	ra,24(sp)
    80001c6e:	e822                	sd	s0,16(sp)
    80001c70:	e426                	sd	s1,8(sp)
    80001c72:	e04a                	sd	s2,0(sp)
    80001c74:	1000                	addi	s0,sp,32
	acquire(&pid_lock);
    80001c76:	0000f917          	auipc	s2,0xf
    80001c7a:	1da90913          	addi	s2,s2,474 # 80010e50 <pid_lock>
    80001c7e:	854a                	mv	a0,s2
    80001c80:	fffff097          	auipc	ra,0xfffff
    80001c84:	f6a080e7          	jalr	-150(ra) # 80000bea <acquire>
	pid = nextpid;
    80001c88:	00007797          	auipc	a5,0x7
    80001c8c:	d1c78793          	addi	a5,a5,-740 # 800089a4 <nextpid>
    80001c90:	4384                	lw	s1,0(a5)
	nextpid = nextpid + 1;
    80001c92:	0014871b          	addiw	a4,s1,1
    80001c96:	c398                	sw	a4,0(a5)
	release(&pid_lock);
    80001c98:	854a                	mv	a0,s2
    80001c9a:	fffff097          	auipc	ra,0xfffff
    80001c9e:	004080e7          	jalr	4(ra) # 80000c9e <release>
}
    80001ca2:	8526                	mv	a0,s1
    80001ca4:	60e2                	ld	ra,24(sp)
    80001ca6:	6442                	ld	s0,16(sp)
    80001ca8:	64a2                	ld	s1,8(sp)
    80001caa:	6902                	ld	s2,0(sp)
    80001cac:	6105                	addi	sp,sp,32
    80001cae:	8082                	ret

0000000080001cb0 <proc_pagetable>:
{
    80001cb0:	1101                	addi	sp,sp,-32
    80001cb2:	ec06                	sd	ra,24(sp)
    80001cb4:	e822                	sd	s0,16(sp)
    80001cb6:	e426                	sd	s1,8(sp)
    80001cb8:	e04a                	sd	s2,0(sp)
    80001cba:	1000                	addi	s0,sp,32
    80001cbc:	892a                	mv	s2,a0
	pagetable = uvmcreate();
    80001cbe:	fffff097          	auipc	ra,0xfffff
    80001cc2:	686080e7          	jalr	1670(ra) # 80001344 <uvmcreate>
    80001cc6:	84aa                	mv	s1,a0
	if (pagetable == 0)
    80001cc8:	c121                	beqz	a0,80001d08 <proc_pagetable+0x58>
	if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001cca:	4729                	li	a4,10
    80001ccc:	00005697          	auipc	a3,0x5
    80001cd0:	33468693          	addi	a3,a3,820 # 80007000 <_trampoline>
    80001cd4:	6605                	lui	a2,0x1
    80001cd6:	040005b7          	lui	a1,0x4000
    80001cda:	15fd                	addi	a1,a1,-1
    80001cdc:	05b2                	slli	a1,a1,0xc
    80001cde:	fffff097          	auipc	ra,0xfffff
    80001ce2:	3dc080e7          	jalr	988(ra) # 800010ba <mappages>
    80001ce6:	02054863          	bltz	a0,80001d16 <proc_pagetable+0x66>
	if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001cea:	4719                	li	a4,6
    80001cec:	06093683          	ld	a3,96(s2)
    80001cf0:	6605                	lui	a2,0x1
    80001cf2:	020005b7          	lui	a1,0x2000
    80001cf6:	15fd                	addi	a1,a1,-1
    80001cf8:	05b6                	slli	a1,a1,0xd
    80001cfa:	8526                	mv	a0,s1
    80001cfc:	fffff097          	auipc	ra,0xfffff
    80001d00:	3be080e7          	jalr	958(ra) # 800010ba <mappages>
    80001d04:	02054163          	bltz	a0,80001d26 <proc_pagetable+0x76>
}
    80001d08:	8526                	mv	a0,s1
    80001d0a:	60e2                	ld	ra,24(sp)
    80001d0c:	6442                	ld	s0,16(sp)
    80001d0e:	64a2                	ld	s1,8(sp)
    80001d10:	6902                	ld	s2,0(sp)
    80001d12:	6105                	addi	sp,sp,32
    80001d14:	8082                	ret
		uvmfree(pagetable, 0);
    80001d16:	4581                	li	a1,0
    80001d18:	8526                	mv	a0,s1
    80001d1a:	00000097          	auipc	ra,0x0
    80001d1e:	82e080e7          	jalr	-2002(ra) # 80001548 <uvmfree>
		return 0;
    80001d22:	4481                	li	s1,0
    80001d24:	b7d5                	j	80001d08 <proc_pagetable+0x58>
		uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d26:	4681                	li	a3,0
    80001d28:	4605                	li	a2,1
    80001d2a:	040005b7          	lui	a1,0x4000
    80001d2e:	15fd                	addi	a1,a1,-1
    80001d30:	05b2                	slli	a1,a1,0xc
    80001d32:	8526                	mv	a0,s1
    80001d34:	fffff097          	auipc	ra,0xfffff
    80001d38:	54c080e7          	jalr	1356(ra) # 80001280 <uvmunmap>
		uvmfree(pagetable, 0);
    80001d3c:	4581                	li	a1,0
    80001d3e:	8526                	mv	a0,s1
    80001d40:	00000097          	auipc	ra,0x0
    80001d44:	808080e7          	jalr	-2040(ra) # 80001548 <uvmfree>
		return 0;
    80001d48:	4481                	li	s1,0
    80001d4a:	bf7d                	j	80001d08 <proc_pagetable+0x58>

0000000080001d4c <proc_freepagetable>:
{
    80001d4c:	1101                	addi	sp,sp,-32
    80001d4e:	ec06                	sd	ra,24(sp)
    80001d50:	e822                	sd	s0,16(sp)
    80001d52:	e426                	sd	s1,8(sp)
    80001d54:	e04a                	sd	s2,0(sp)
    80001d56:	1000                	addi	s0,sp,32
    80001d58:	84aa                	mv	s1,a0
    80001d5a:	892e                	mv	s2,a1
	uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d5c:	4681                	li	a3,0
    80001d5e:	4605                	li	a2,1
    80001d60:	040005b7          	lui	a1,0x4000
    80001d64:	15fd                	addi	a1,a1,-1
    80001d66:	05b2                	slli	a1,a1,0xc
    80001d68:	fffff097          	auipc	ra,0xfffff
    80001d6c:	518080e7          	jalr	1304(ra) # 80001280 <uvmunmap>
	uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001d70:	4681                	li	a3,0
    80001d72:	4605                	li	a2,1
    80001d74:	020005b7          	lui	a1,0x2000
    80001d78:	15fd                	addi	a1,a1,-1
    80001d7a:	05b6                	slli	a1,a1,0xd
    80001d7c:	8526                	mv	a0,s1
    80001d7e:	fffff097          	auipc	ra,0xfffff
    80001d82:	502080e7          	jalr	1282(ra) # 80001280 <uvmunmap>
	uvmfree(pagetable, sz);
    80001d86:	85ca                	mv	a1,s2
    80001d88:	8526                	mv	a0,s1
    80001d8a:	fffff097          	auipc	ra,0xfffff
    80001d8e:	7be080e7          	jalr	1982(ra) # 80001548 <uvmfree>
}
    80001d92:	60e2                	ld	ra,24(sp)
    80001d94:	6442                	ld	s0,16(sp)
    80001d96:	64a2                	ld	s1,8(sp)
    80001d98:	6902                	ld	s2,0(sp)
    80001d9a:	6105                	addi	sp,sp,32
    80001d9c:	8082                	ret

0000000080001d9e <freeproc>:
{
    80001d9e:	1101                	addi	sp,sp,-32
    80001da0:	ec06                	sd	ra,24(sp)
    80001da2:	e822                	sd	s0,16(sp)
    80001da4:	e426                	sd	s1,8(sp)
    80001da6:	1000                	addi	s0,sp,32
    80001da8:	84aa                	mv	s1,a0
	if (p->trapframe)
    80001daa:	7128                	ld	a0,96(a0)
    80001dac:	c509                	beqz	a0,80001db6 <freeproc+0x18>
		kfree((void *)p->trapframe);
    80001dae:	fffff097          	auipc	ra,0xfffff
    80001db2:	c50080e7          	jalr	-944(ra) # 800009fe <kfree>
	p->trapframe = 0;
    80001db6:	0604b023          	sd	zero,96(s1)
	if (p->pagetable)
    80001dba:	6ca8                	ld	a0,88(s1)
    80001dbc:	c511                	beqz	a0,80001dc8 <freeproc+0x2a>
		proc_freepagetable(p->pagetable, p->sz);
    80001dbe:	68ac                	ld	a1,80(s1)
    80001dc0:	00000097          	auipc	ra,0x0
    80001dc4:	f8c080e7          	jalr	-116(ra) # 80001d4c <proc_freepagetable>
	p->pagetable = 0;
    80001dc8:	0404bc23          	sd	zero,88(s1)
	p->sz = 0;
    80001dcc:	0404b823          	sd	zero,80(s1)
	p->pid = 0;
    80001dd0:	0204ac23          	sw	zero,56(s1)
	p->parent = 0;
    80001dd4:	0404b023          	sd	zero,64(s1)
	p->name[0] = 0;
    80001dd8:	16048023          	sb	zero,352(s1)
	p->chan = 0;
    80001ddc:	0204b423          	sd	zero,40(s1)
	p->killed = 0;
    80001de0:	0204a823          	sw	zero,48(s1)
	p->xstate = 0;
    80001de4:	0204aa23          	sw	zero,52(s1)
	p->state = UNUSED;
    80001de8:	0204a023          	sw	zero,32(s1)
}
    80001dec:	60e2                	ld	ra,24(sp)
    80001dee:	6442                	ld	s0,16(sp)
    80001df0:	64a2                	ld	s1,8(sp)
    80001df2:	6105                	addi	sp,sp,32
    80001df4:	8082                	ret

0000000080001df6 <allocproc>:
{
    80001df6:	7179                	addi	sp,sp,-48
    80001df8:	f406                	sd	ra,40(sp)
    80001dfa:	f022                	sd	s0,32(sp)
    80001dfc:	ec26                	sd	s1,24(sp)
    80001dfe:	e84a                	sd	s2,16(sp)
    80001e00:	e44e                	sd	s3,8(sp)
    80001e02:	1800                	addi	s0,sp,48
	for (p = proc; p < &proc[NPROC]; p++)
    80001e04:	00010497          	auipc	s1,0x10
    80001e08:	ef448493          	addi	s1,s1,-268 # 80011cf8 <proc>
    80001e0c:	00017997          	auipc	s3,0x17
    80001e10:	2ec98993          	addi	s3,s3,748 # 800190f8 <tickslock>
		acquire(&p->lock);
    80001e14:	00848913          	addi	s2,s1,8
    80001e18:	854a                	mv	a0,s2
    80001e1a:	fffff097          	auipc	ra,0xfffff
    80001e1e:	dd0080e7          	jalr	-560(ra) # 80000bea <acquire>
		if (p->state == UNUSED)
    80001e22:	509c                	lw	a5,32(s1)
    80001e24:	cf81                	beqz	a5,80001e3c <allocproc+0x46>
			release(&p->lock);
    80001e26:	854a                	mv	a0,s2
    80001e28:	fffff097          	auipc	ra,0xfffff
    80001e2c:	e76080e7          	jalr	-394(ra) # 80000c9e <release>
	for (p = proc; p < &proc[NPROC]; p++)
    80001e30:	1d048493          	addi	s1,s1,464
    80001e34:	ff3490e3          	bne	s1,s3,80001e14 <allocproc+0x1e>
	return 0;
    80001e38:	4481                	li	s1,0
    80001e3a:	a845                	j	80001eea <allocproc+0xf4>
	p->pid = allocpid();
    80001e3c:	00000097          	auipc	ra,0x0
    80001e40:	e2e080e7          	jalr	-466(ra) # 80001c6a <allocpid>
    80001e44:	dc88                	sw	a0,56(s1)
	p->state = USED;
    80001e46:	4785                	li	a5,1
    80001e48:	d09c                	sw	a5,32(s1)
	p->curr_queue = 0;
    80001e4a:	1a04a423          	sw	zero,424(s1)
	p->ticks_spent = 0;
    80001e4e:	1a04a623          	sw	zero,428(s1)
	p->enter_time = ticks;
    80001e52:	00007717          	auipc	a4,0x7
    80001e56:	d8e72703          	lw	a4,-626(a4) # 80008be0 <ticks>
    80001e5a:	1ae4a823          	sw	a4,432(s1)
	p->time_slice = slices[p->curr_queue];
    80001e5e:	1af4ac23          	sw	a5,440(s1)
	p->in_queue = 0;
    80001e62:	1a04aa23          	sw	zero,436(s1)
		p->queue[i] = 0;
    80001e66:	1a04ae23          	sw	zero,444(s1)
    80001e6a:	1c04a023          	sw	zero,448(s1)
    80001e6e:	1c04a223          	sw	zero,452(s1)
    80001e72:	1c04a423          	sw	zero,456(s1)
    80001e76:	1c04a623          	sw	zero,460(s1)
	if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001e7a:	fffff097          	auipc	ra,0xfffff
    80001e7e:	c80080e7          	jalr	-896(ra) # 80000afa <kalloc>
    80001e82:	89aa                	mv	s3,a0
    80001e84:	f0a8                	sd	a0,96(s1)
    80001e86:	c935                	beqz	a0,80001efa <allocproc+0x104>
	p->pagetable = proc_pagetable(p);
    80001e88:	8526                	mv	a0,s1
    80001e8a:	00000097          	auipc	ra,0x0
    80001e8e:	e26080e7          	jalr	-474(ra) # 80001cb0 <proc_pagetable>
    80001e92:	89aa                	mv	s3,a0
    80001e94:	eca8                	sd	a0,88(s1)
	if (p->pagetable == 0)
    80001e96:	cd35                	beqz	a0,80001f12 <allocproc+0x11c>
	memset(&p->context, 0, sizeof(p->context));
    80001e98:	07000613          	li	a2,112
    80001e9c:	4581                	li	a1,0
    80001e9e:	06848513          	addi	a0,s1,104
    80001ea2:	fffff097          	auipc	ra,0xfffff
    80001ea6:	e44080e7          	jalr	-444(ra) # 80000ce6 <memset>
	p->context.ra = (uint64)forkret;
    80001eaa:	00000797          	auipc	a5,0x0
    80001eae:	d7878793          	addi	a5,a5,-648 # 80001c22 <forkret>
    80001eb2:	f4bc                	sd	a5,104(s1)
	p->context.sp = p->kstack + PGSIZE;
    80001eb4:	64bc                	ld	a5,72(s1)
    80001eb6:	6705                	lui	a4,0x1
    80001eb8:	97ba                	add	a5,a5,a4
    80001eba:	f8bc                	sd	a5,112(s1)
	p->creationTime = ticks;
    80001ebc:	00007797          	auipc	a5,0x7
    80001ec0:	d247a783          	lw	a5,-732(a5) # 80008be0 <ticks>
    80001ec4:	16f4ae23          	sw	a5,380(s1)
	p->sprior = 60;
    80001ec8:	03c00793          	li	a5,60
    80001ecc:	18f4ae23          	sw	a5,412(s1)
	p->niceness = 5;
    80001ed0:	4795                	li	a5,5
    80001ed2:	1af4a223          	sw	a5,420(s1)
	p->runTime = 0;
    80001ed6:	1804a023          	sw	zero,384(s1)
	p->endTime = 0;
    80001eda:	1804a223          	sw	zero,388(s1)
	p->runTimePrev = 0;
    80001ede:	1804aa23          	sw	zero,404(s1)
	p->sleepTimePrev = 0;
    80001ee2:	1804a623          	sw	zero,396(s1)
	p->sleepStartTime = 0;
    80001ee6:	1804a823          	sw	zero,400(s1)
}
    80001eea:	8526                	mv	a0,s1
    80001eec:	70a2                	ld	ra,40(sp)
    80001eee:	7402                	ld	s0,32(sp)
    80001ef0:	64e2                	ld	s1,24(sp)
    80001ef2:	6942                	ld	s2,16(sp)
    80001ef4:	69a2                	ld	s3,8(sp)
    80001ef6:	6145                	addi	sp,sp,48
    80001ef8:	8082                	ret
		freeproc(p);
    80001efa:	8526                	mv	a0,s1
    80001efc:	00000097          	auipc	ra,0x0
    80001f00:	ea2080e7          	jalr	-350(ra) # 80001d9e <freeproc>
		release(&p->lock);
    80001f04:	854a                	mv	a0,s2
    80001f06:	fffff097          	auipc	ra,0xfffff
    80001f0a:	d98080e7          	jalr	-616(ra) # 80000c9e <release>
		return 0;
    80001f0e:	84ce                	mv	s1,s3
    80001f10:	bfe9                	j	80001eea <allocproc+0xf4>
		freeproc(p);
    80001f12:	8526                	mv	a0,s1
    80001f14:	00000097          	auipc	ra,0x0
    80001f18:	e8a080e7          	jalr	-374(ra) # 80001d9e <freeproc>
		release(&p->lock);
    80001f1c:	854a                	mv	a0,s2
    80001f1e:	fffff097          	auipc	ra,0xfffff
    80001f22:	d80080e7          	jalr	-640(ra) # 80000c9e <release>
		return 0;
    80001f26:	84ce                	mv	s1,s3
    80001f28:	b7c9                	j	80001eea <allocproc+0xf4>

0000000080001f2a <userinit>:
{
    80001f2a:	1101                	addi	sp,sp,-32
    80001f2c:	ec06                	sd	ra,24(sp)
    80001f2e:	e822                	sd	s0,16(sp)
    80001f30:	e426                	sd	s1,8(sp)
    80001f32:	1000                	addi	s0,sp,32
	p = allocproc();
    80001f34:	00000097          	auipc	ra,0x0
    80001f38:	ec2080e7          	jalr	-318(ra) # 80001df6 <allocproc>
    80001f3c:	84aa                	mv	s1,a0
	initproc = p;
    80001f3e:	00007797          	auipc	a5,0x7
    80001f42:	c8a7bd23          	sd	a0,-870(a5) # 80008bd8 <initproc>
	uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001f46:	03400613          	li	a2,52
    80001f4a:	00007597          	auipc	a1,0x7
    80001f4e:	a6658593          	addi	a1,a1,-1434 # 800089b0 <initcode>
    80001f52:	6d28                	ld	a0,88(a0)
    80001f54:	fffff097          	auipc	ra,0xfffff
    80001f58:	41e080e7          	jalr	1054(ra) # 80001372 <uvmfirst>
	p->sz = PGSIZE;
    80001f5c:	6785                	lui	a5,0x1
    80001f5e:	e8bc                	sd	a5,80(s1)
	p->trapframe->epc = 0;	   // user program counter
    80001f60:	70b8                	ld	a4,96(s1)
    80001f62:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
	p->trapframe->sp = PGSIZE; // user stack pointer
    80001f66:	70b8                	ld	a4,96(s1)
    80001f68:	fb1c                	sd	a5,48(a4)
	safestrcpy(p->name, "initcode", sizeof(p->name));
    80001f6a:	4641                	li	a2,16
    80001f6c:	00006597          	auipc	a1,0x6
    80001f70:	2ac58593          	addi	a1,a1,684 # 80008218 <digits+0x1d8>
    80001f74:	16048513          	addi	a0,s1,352
    80001f78:	fffff097          	auipc	ra,0xfffff
    80001f7c:	ec0080e7          	jalr	-320(ra) # 80000e38 <safestrcpy>
	p->cwd = namei("/");
    80001f80:	00006517          	auipc	a0,0x6
    80001f84:	2a850513          	addi	a0,a0,680 # 80008228 <digits+0x1e8>
    80001f88:	00003097          	auipc	ra,0x3
    80001f8c:	8d0080e7          	jalr	-1840(ra) # 80004858 <namei>
    80001f90:	14a4bc23          	sd	a0,344(s1)
	p->state = RUNNABLE;
    80001f94:	478d                	li	a5,3
    80001f96:	d09c                	sw	a5,32(s1)
	release(&p->lock);
    80001f98:	00848513          	addi	a0,s1,8
    80001f9c:	fffff097          	auipc	ra,0xfffff
    80001fa0:	d02080e7          	jalr	-766(ra) # 80000c9e <release>
}
    80001fa4:	60e2                	ld	ra,24(sp)
    80001fa6:	6442                	ld	s0,16(sp)
    80001fa8:	64a2                	ld	s1,8(sp)
    80001faa:	6105                	addi	sp,sp,32
    80001fac:	8082                	ret

0000000080001fae <growproc>:
{
    80001fae:	1101                	addi	sp,sp,-32
    80001fb0:	ec06                	sd	ra,24(sp)
    80001fb2:	e822                	sd	s0,16(sp)
    80001fb4:	e426                	sd	s1,8(sp)
    80001fb6:	e04a                	sd	s2,0(sp)
    80001fb8:	1000                	addi	s0,sp,32
    80001fba:	892a                	mv	s2,a0
	struct proc *p = myproc();
    80001fbc:	00000097          	auipc	ra,0x0
    80001fc0:	c2e080e7          	jalr	-978(ra) # 80001bea <myproc>
    80001fc4:	84aa                	mv	s1,a0
	sz = p->sz;
    80001fc6:	692c                	ld	a1,80(a0)
	if (n > 0)
    80001fc8:	01204c63          	bgtz	s2,80001fe0 <growproc+0x32>
	else if (n < 0)
    80001fcc:	02094663          	bltz	s2,80001ff8 <growproc+0x4a>
	p->sz = sz;
    80001fd0:	e8ac                	sd	a1,80(s1)
	return 0;
    80001fd2:	4501                	li	a0,0
}
    80001fd4:	60e2                	ld	ra,24(sp)
    80001fd6:	6442                	ld	s0,16(sp)
    80001fd8:	64a2                	ld	s1,8(sp)
    80001fda:	6902                	ld	s2,0(sp)
    80001fdc:	6105                	addi	sp,sp,32
    80001fde:	8082                	ret
		if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001fe0:	4691                	li	a3,4
    80001fe2:	00b90633          	add	a2,s2,a1
    80001fe6:	6d28                	ld	a0,88(a0)
    80001fe8:	fffff097          	auipc	ra,0xfffff
    80001fec:	444080e7          	jalr	1092(ra) # 8000142c <uvmalloc>
    80001ff0:	85aa                	mv	a1,a0
    80001ff2:	fd79                	bnez	a0,80001fd0 <growproc+0x22>
			return -1;
    80001ff4:	557d                	li	a0,-1
    80001ff6:	bff9                	j	80001fd4 <growproc+0x26>
		sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001ff8:	00b90633          	add	a2,s2,a1
    80001ffc:	6d28                	ld	a0,88(a0)
    80001ffe:	fffff097          	auipc	ra,0xfffff
    80002002:	3e6080e7          	jalr	998(ra) # 800013e4 <uvmdealloc>
    80002006:	85aa                	mv	a1,a0
    80002008:	b7e1                	j	80001fd0 <growproc+0x22>

000000008000200a <fork>:
{
    8000200a:	7139                	addi	sp,sp,-64
    8000200c:	fc06                	sd	ra,56(sp)
    8000200e:	f822                	sd	s0,48(sp)
    80002010:	f426                	sd	s1,40(sp)
    80002012:	f04a                	sd	s2,32(sp)
    80002014:	ec4e                	sd	s3,24(sp)
    80002016:	e852                	sd	s4,16(sp)
    80002018:	e456                	sd	s5,8(sp)
    8000201a:	0080                	addi	s0,sp,64
	struct proc *p = myproc();
    8000201c:	00000097          	auipc	ra,0x0
    80002020:	bce080e7          	jalr	-1074(ra) # 80001bea <myproc>
    80002024:	892a                	mv	s2,a0
	if ((np = allocproc()) == 0)
    80002026:	00000097          	auipc	ra,0x0
    8000202a:	dd0080e7          	jalr	-560(ra) # 80001df6 <allocproc>
    8000202e:	12050f63          	beqz	a0,8000216c <fork+0x162>
    80002032:	89aa                	mv	s3,a0
	if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80002034:	05093603          	ld	a2,80(s2)
    80002038:	6d2c                	ld	a1,88(a0)
    8000203a:	05893503          	ld	a0,88(s2)
    8000203e:	fffff097          	auipc	ra,0xfffff
    80002042:	542080e7          	jalr	1346(ra) # 80001580 <uvmcopy>
    80002046:	04054a63          	bltz	a0,8000209a <fork+0x90>
	np->mask = p->mask; // copying mask so that we can also trace child processes
    8000204a:	00092783          	lw	a5,0(s2)
    8000204e:	00f9a023          	sw	a5,0(s3)
	np->sz = p->sz;
    80002052:	05093783          	ld	a5,80(s2)
    80002056:	04f9b823          	sd	a5,80(s3)
	*(np->trapframe) = *(p->trapframe);
    8000205a:	06093683          	ld	a3,96(s2)
    8000205e:	87b6                	mv	a5,a3
    80002060:	0609b703          	ld	a4,96(s3)
    80002064:	12068693          	addi	a3,a3,288
    80002068:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    8000206c:	6788                	ld	a0,8(a5)
    8000206e:	6b8c                	ld	a1,16(a5)
    80002070:	6f90                	ld	a2,24(a5)
    80002072:	01073023          	sd	a6,0(a4)
    80002076:	e708                	sd	a0,8(a4)
    80002078:	eb0c                	sd	a1,16(a4)
    8000207a:	ef10                	sd	a2,24(a4)
    8000207c:	02078793          	addi	a5,a5,32
    80002080:	02070713          	addi	a4,a4,32
    80002084:	fed792e3          	bne	a5,a3,80002068 <fork+0x5e>
	np->trapframe->a0 = 0;
    80002088:	0609b783          	ld	a5,96(s3)
    8000208c:	0607b823          	sd	zero,112(a5)
    80002090:	0d800493          	li	s1,216
	for (i = 0; i < NOFILE; i++)
    80002094:	15800a13          	li	s4,344
    80002098:	a805                	j	800020c8 <fork+0xbe>
		freeproc(np);
    8000209a:	854e                	mv	a0,s3
    8000209c:	00000097          	auipc	ra,0x0
    800020a0:	d02080e7          	jalr	-766(ra) # 80001d9e <freeproc>
		release(&np->lock);
    800020a4:	00898513          	addi	a0,s3,8
    800020a8:	fffff097          	auipc	ra,0xfffff
    800020ac:	bf6080e7          	jalr	-1034(ra) # 80000c9e <release>
		return -1;
    800020b0:	5afd                	li	s5,-1
    800020b2:	a05d                	j	80002158 <fork+0x14e>
			np->ofile[i] = filedup(p->ofile[i]);
    800020b4:	00003097          	auipc	ra,0x3
    800020b8:	e3a080e7          	jalr	-454(ra) # 80004eee <filedup>
    800020bc:	009987b3          	add	a5,s3,s1
    800020c0:	e388                	sd	a0,0(a5)
	for (i = 0; i < NOFILE; i++)
    800020c2:	04a1                	addi	s1,s1,8
    800020c4:	01448763          	beq	s1,s4,800020d2 <fork+0xc8>
		if (p->ofile[i])
    800020c8:	009907b3          	add	a5,s2,s1
    800020cc:	6388                	ld	a0,0(a5)
    800020ce:	f17d                	bnez	a0,800020b4 <fork+0xaa>
    800020d0:	bfcd                	j	800020c2 <fork+0xb8>
	np->cwd = idup(p->cwd);
    800020d2:	15893503          	ld	a0,344(s2)
    800020d6:	00002097          	auipc	ra,0x2
    800020da:	f9e080e7          	jalr	-98(ra) # 80004074 <idup>
    800020de:	14a9bc23          	sd	a0,344(s3)
	safestrcpy(np->name, p->name, sizeof(p->name));
    800020e2:	4641                	li	a2,16
    800020e4:	16090593          	addi	a1,s2,352
    800020e8:	16098513          	addi	a0,s3,352
    800020ec:	fffff097          	auipc	ra,0xfffff
    800020f0:	d4c080e7          	jalr	-692(ra) # 80000e38 <safestrcpy>
	pid = np->pid;
    800020f4:	0389aa83          	lw	s5,56(s3)
	release(&np->lock);
    800020f8:	00898493          	addi	s1,s3,8
    800020fc:	8526                	mv	a0,s1
    800020fe:	fffff097          	auipc	ra,0xfffff
    80002102:	ba0080e7          	jalr	-1120(ra) # 80000c9e <release>
	acquire(&wait_lock);
    80002106:	0000fa17          	auipc	s4,0xf
    8000210a:	d62a0a13          	addi	s4,s4,-670 # 80010e68 <wait_lock>
    8000210e:	8552                	mv	a0,s4
    80002110:	fffff097          	auipc	ra,0xfffff
    80002114:	ada080e7          	jalr	-1318(ra) # 80000bea <acquire>
	np->parent = p;
    80002118:	0529b023          	sd	s2,64(s3)
	release(&wait_lock);
    8000211c:	8552                	mv	a0,s4
    8000211e:	fffff097          	auipc	ra,0xfffff
    80002122:	b80080e7          	jalr	-1152(ra) # 80000c9e <release>
	acquire(&np->lock);
    80002126:	8526                	mv	a0,s1
    80002128:	fffff097          	auipc	ra,0xfffff
    8000212c:	ac2080e7          	jalr	-1342(ra) # 80000bea <acquire>
	np->state = RUNNABLE;
    80002130:	478d                	li	a5,3
    80002132:	02f9a023          	sw	a5,32(s3)
	release(&np->lock);
    80002136:	8526                	mv	a0,s1
    80002138:	fffff097          	auipc	ra,0xfffff
    8000213c:	b66080e7          	jalr	-1178(ra) # 80000c9e <release>
	push(&mlfq[0], np);
    80002140:	85ce                	mv	a1,s3
    80002142:	0000f517          	auipc	a0,0xf
    80002146:	13e50513          	addi	a0,a0,318 # 80011280 <mlfq>
    8000214a:	00000097          	auipc	ra,0x0
    8000214e:	83e080e7          	jalr	-1986(ra) # 80001988 <push>
	np->in_queue = 1;
    80002152:	4785                	li	a5,1
    80002154:	1af9aa23          	sw	a5,436(s3)
}
    80002158:	8556                	mv	a0,s5
    8000215a:	70e2                	ld	ra,56(sp)
    8000215c:	7442                	ld	s0,48(sp)
    8000215e:	74a2                	ld	s1,40(sp)
    80002160:	7902                	ld	s2,32(sp)
    80002162:	69e2                	ld	s3,24(sp)
    80002164:	6a42                	ld	s4,16(sp)
    80002166:	6aa2                	ld	s5,8(sp)
    80002168:	6121                	addi	sp,sp,64
    8000216a:	8082                	ret
		return -1;
    8000216c:	5afd                	li	s5,-1
    8000216e:	b7ed                	j	80002158 <fork+0x14e>

0000000080002170 <upd_time>:
{
    80002170:	7179                	addi	sp,sp,-48
    80002172:	f406                	sd	ra,40(sp)
    80002174:	f022                	sd	s0,32(sp)
    80002176:	ec26                	sd	s1,24(sp)
    80002178:	e84a                	sd	s2,16(sp)
    8000217a:	e44e                	sd	s3,8(sp)
    8000217c:	e052                	sd	s4,0(sp)
    8000217e:	1800                	addi	s0,sp,48
	struct proc *pr = proc;
    80002180:	00010497          	auipc	s1,0x10
    80002184:	b7848493          	addi	s1,s1,-1160 # 80011cf8 <proc>
		if (pr->state == RUNNING)
    80002188:	4a11                	li	s4,4
	while (pr < &proc[NPROC])
    8000218a:	00017997          	auipc	s3,0x17
    8000218e:	f6e98993          	addi	s3,s3,-146 # 800190f8 <tickslock>
    80002192:	a811                	j	800021a6 <upd_time+0x36>
		release(&pr->lock);
    80002194:	854a                	mv	a0,s2
    80002196:	fffff097          	auipc	ra,0xfffff
    8000219a:	b08080e7          	jalr	-1272(ra) # 80000c9e <release>
		pr++;
    8000219e:	1d048493          	addi	s1,s1,464
	while (pr < &proc[NPROC])
    800021a2:	05348563          	beq	s1,s3,800021ec <upd_time+0x7c>
		acquire(&pr->lock);
    800021a6:	00848913          	addi	s2,s1,8
    800021aa:	854a                	mv	a0,s2
    800021ac:	fffff097          	auipc	ra,0xfffff
    800021b0:	a3e080e7          	jalr	-1474(ra) # 80000bea <acquire>
		if (pr->state == RUNNING)
    800021b4:	509c                	lw	a5,32(s1)
    800021b6:	fd479fe3          	bne	a5,s4,80002194 <upd_time+0x24>
			pr->runTime++;
    800021ba:	1804a783          	lw	a5,384(s1)
    800021be:	2785                	addiw	a5,a5,1
    800021c0:	18f4a023          	sw	a5,384(s1)
			pr->runTimePrev++;
    800021c4:	1944a783          	lw	a5,404(s1)
    800021c8:	2785                	addiw	a5,a5,1
    800021ca:	18f4aa23          	sw	a5,404(s1)
			pr->queue[pr->curr_queue]++;
    800021ce:	1a84a783          	lw	a5,424(s1)
    800021d2:	078a                	slli	a5,a5,0x2
    800021d4:	97a6                	add	a5,a5,s1
    800021d6:	1bc7a703          	lw	a4,444(a5)
    800021da:	2705                	addiw	a4,a4,1
    800021dc:	1ae7ae23          	sw	a4,444(a5)
			pr->time_slice--;
    800021e0:	1b84a783          	lw	a5,440(s1)
    800021e4:	37fd                	addiw	a5,a5,-1
    800021e6:	1af4ac23          	sw	a5,440(s1)
    800021ea:	b76d                	j	80002194 <upd_time+0x24>
}
    800021ec:	70a2                	ld	ra,40(sp)
    800021ee:	7402                	ld	s0,32(sp)
    800021f0:	64e2                	ld	s1,24(sp)
    800021f2:	6942                	ld	s2,16(sp)
    800021f4:	69a2                	ld	s3,8(sp)
    800021f6:	6a02                	ld	s4,0(sp)
    800021f8:	6145                	addi	sp,sp,48
    800021fa:	8082                	ret

00000000800021fc <mlfq_sched>:
{
    800021fc:	715d                	addi	sp,sp,-80
    800021fe:	e486                	sd	ra,72(sp)
    80002200:	e0a2                	sd	s0,64(sp)
    80002202:	fc26                	sd	s1,56(sp)
    80002204:	f84a                	sd	s2,48(sp)
    80002206:	f44e                	sd	s3,40(sp)
    80002208:	f052                	sd	s4,32(sp)
    8000220a:	ec56                	sd	s5,24(sp)
    8000220c:	e85a                	sd	s6,16(sp)
    8000220e:	e45e                	sd	s7,8(sp)
    80002210:	0880                	addi	s0,sp,80
	struct proc *pr = proc;
    80002212:	00010497          	auipc	s1,0x10
    80002216:	ae648493          	addi	s1,s1,-1306 # 80011cf8 <proc>
		if (pr->state == RUNNABLE)
    8000221a:	498d                	li	s3,3
			if (ticks - pr->enter_time >= 256)
    8000221c:	00007a17          	auipc	s4,0x7
    80002220:	9c4a0a13          	addi	s4,s4,-1596 # 80008be0 <ticks>
    80002224:	0ff00a93          	li	s5,255
					qerase(&mlfq[level], pr->pid);
    80002228:	21800b93          	li	s7,536
    8000222c:	0000fb17          	auipc	s6,0xf
    80002230:	054b0b13          	addi	s6,s6,84 # 80011280 <mlfq>
	while (pr < &proc[x])
    80002234:	00017917          	auipc	s2,0x17
    80002238:	ec490913          	addi	s2,s2,-316 # 800190f8 <tickslock>
    8000223c:	a035                	j	80002268 <mlfq_sched+0x6c>
					qerase(&mlfq[level], pr->pid);
    8000223e:	1a84a503          	lw	a0,424(s1)
    80002242:	03750533          	mul	a0,a0,s7
    80002246:	5c8c                	lw	a1,56(s1)
    80002248:	955a                	add	a0,a0,s6
    8000224a:	fffff097          	auipc	ra,0xfffff
    8000224e:	7c0080e7          	jalr	1984(ra) # 80001a0a <qerase>
					pr->in_queue = 0;
    80002252:	1a04aa23          	sw	zero,436(s1)
    80002256:	a035                	j	80002282 <mlfq_sched+0x86>
				pr->enter_time = ticks;
    80002258:	000a2783          	lw	a5,0(s4)
    8000225c:	1af4a823          	sw	a5,432(s1)
		pr++;
    80002260:	1d048493          	addi	s1,s1,464
	while (pr < &proc[x])
    80002264:	03248663          	beq	s1,s2,80002290 <mlfq_sched+0x94>
		if (pr->state == RUNNABLE)
    80002268:	509c                	lw	a5,32(s1)
    8000226a:	ff379be3          	bne	a5,s3,80002260 <mlfq_sched+0x64>
			if (ticks - pr->enter_time >= 256)
    8000226e:	000a2783          	lw	a5,0(s4)
    80002272:	1b04a703          	lw	a4,432(s1)
    80002276:	9f99                	subw	a5,a5,a4
    80002278:	fefaf4e3          	bgeu	s5,a5,80002260 <mlfq_sched+0x64>
				if (test)
    8000227c:	1b44a783          	lw	a5,436(s1)
    80002280:	ffdd                	bnez	a5,8000223e <mlfq_sched+0x42>
				if (pr->curr_queue != 0)
    80002282:	1a84a783          	lw	a5,424(s1)
    80002286:	dbe9                	beqz	a5,80002258 <mlfq_sched+0x5c>
					pr->curr_queue--;
    80002288:	37fd                	addiw	a5,a5,-1
    8000228a:	1af4a423          	sw	a5,424(s1)
    8000228e:	b7e9                	j	80002258 <mlfq_sched+0x5c>
	pr = proc;
    80002290:	00010497          	auipc	s1,0x10
    80002294:	a6848493          	addi	s1,s1,-1432 # 80011cf8 <proc>
		if (pr->state == RUNNABLE)
    80002298:	498d                	li	s3,3
				push(&mlfq[level], pr);
    8000229a:	21800b13          	li	s6,536
    8000229e:	0000fa97          	auipc	s5,0xf
    800022a2:	fe2a8a93          	addi	s5,s5,-30 # 80011280 <mlfq>
				pr->in_queue = 1;
    800022a6:	4a05                	li	s4,1
	while (pr < &proc[x])
    800022a8:	00017917          	auipc	s2,0x17
    800022ac:	e5090913          	addi	s2,s2,-432 # 800190f8 <tickslock>
    800022b0:	a00d                	j	800022d2 <mlfq_sched+0xd6>
				push(&mlfq[level], pr);
    800022b2:	1a84a503          	lw	a0,424(s1)
    800022b6:	03650533          	mul	a0,a0,s6
    800022ba:	85a6                	mv	a1,s1
    800022bc:	9556                	add	a0,a0,s5
    800022be:	fffff097          	auipc	ra,0xfffff
    800022c2:	6ca080e7          	jalr	1738(ra) # 80001988 <push>
				pr->in_queue = 1;
    800022c6:	1b44aa23          	sw	s4,436(s1)
		pr++;
    800022ca:	1d048493          	addi	s1,s1,464
	while (pr < &proc[x])
    800022ce:	01248963          	beq	s1,s2,800022e0 <mlfq_sched+0xe4>
		if (pr->state == RUNNABLE)
    800022d2:	509c                	lw	a5,32(s1)
    800022d4:	ff379be3          	bne	a5,s3,800022ca <mlfq_sched+0xce>
			if (!test)
    800022d8:	1b44a783          	lw	a5,436(s1)
    800022dc:	f7fd                	bnez	a5,800022ca <mlfq_sched+0xce>
    800022de:	bfd1                	j	800022b2 <mlfq_sched+0xb6>
    800022e0:	0000fa17          	auipc	s4,0xf
    800022e4:	fa0a0a13          	addi	s4,s4,-96 # 80011280 <mlfq>
    800022e8:	00010a97          	auipc	s5,0x10
    800022ec:	a10a8a93          	addi	s5,s5,-1520 # 80011cf8 <proc>
			if (pr->state != RUNNABLE)
    800022f0:	498d                	li	s3,3
			struct proc *pr = front(&mlfq[lev]);
    800022f2:	8952                	mv	s2,s4
		while (mlfq[lev].size)
    800022f4:	21092783          	lw	a5,528(s2)
    800022f8:	c3b9                	beqz	a5,8000233e <mlfq_sched+0x142>
			struct proc *pr = front(&mlfq[lev]);
    800022fa:	854a                	mv	a0,s2
    800022fc:	fffff097          	auipc	ra,0xfffff
    80002300:	6f0080e7          	jalr	1776(ra) # 800019ec <front>
    80002304:	84aa                	mv	s1,a0
			pop(&mlfq[lev]);
    80002306:	854a                	mv	a0,s2
    80002308:	fffff097          	auipc	ra,0xfffff
    8000230c:	6b6080e7          	jalr	1718(ra) # 800019be <pop>
			pr->in_queue = 0;
    80002310:	1a04aa23          	sw	zero,436(s1)
			if (pr->state != RUNNABLE)
    80002314:	509c                	lw	a5,32(s1)
    80002316:	fd379fe3          	bne	a5,s3,800022f4 <mlfq_sched+0xf8>
				pr->enter_time = ticks;
    8000231a:	00007797          	auipc	a5,0x7
    8000231e:	8c67a783          	lw	a5,-1850(a5) # 80008be0 <ticks>
    80002322:	1af4a823          	sw	a5,432(s1)
}
    80002326:	8526                	mv	a0,s1
    80002328:	60a6                	ld	ra,72(sp)
    8000232a:	6406                	ld	s0,64(sp)
    8000232c:	74e2                	ld	s1,56(sp)
    8000232e:	7942                	ld	s2,48(sp)
    80002330:	79a2                	ld	s3,40(sp)
    80002332:	7a02                	ld	s4,32(sp)
    80002334:	6ae2                	ld	s5,24(sp)
    80002336:	6b42                	ld	s6,16(sp)
    80002338:	6ba2                	ld	s7,8(sp)
    8000233a:	6161                	addi	sp,sp,80
    8000233c:	8082                	ret
	while (lev < num_levels)
    8000233e:	218a0a13          	addi	s4,s4,536
    80002342:	fb5a18e3          	bne	s4,s5,800022f2 <mlfq_sched+0xf6>
	return 0;
    80002346:	4481                	li	s1,0
    80002348:	bff9                	j	80002326 <mlfq_sched+0x12a>

000000008000234a <scheduler>:
{
    8000234a:	7119                	addi	sp,sp,-128
    8000234c:	fc86                	sd	ra,120(sp)
    8000234e:	f8a2                	sd	s0,112(sp)
    80002350:	f4a6                	sd	s1,104(sp)
    80002352:	f0ca                	sd	s2,96(sp)
    80002354:	ecce                	sd	s3,88(sp)
    80002356:	e8d2                	sd	s4,80(sp)
    80002358:	e4d6                	sd	s5,72(sp)
    8000235a:	e0da                	sd	s6,64(sp)
    8000235c:	fc5e                	sd	s7,56(sp)
    8000235e:	f862                	sd	s8,48(sp)
    80002360:	f466                	sd	s9,40(sp)
    80002362:	f06a                	sd	s10,32(sp)
    80002364:	0100                	addi	s0,sp,128
    80002366:	8792                	mv	a5,tp
	int id = r_tp();
    80002368:	2781                	sext.w	a5,a5
	c->proc = 0;
    8000236a:	00779a13          	slli	s4,a5,0x7
    8000236e:	0000f717          	auipc	a4,0xf
    80002372:	ae270713          	addi	a4,a4,-1310 # 80010e50 <pid_lock>
    80002376:	9752                	add	a4,a4,s4
    80002378:	02073823          	sd	zero,48(a4)
			swtch(&c->context, &p->context);
    8000237c:	0000f717          	auipc	a4,0xf
    80002380:	b0c70713          	addi	a4,a4,-1268 # 80010e88 <cpus+0x8>
    80002384:	9a3a                	add	s4,s4,a4
			int slices[5] = {1, 2, 4, 8, 16};
    80002386:	4c85                	li	s9,1
    80002388:	4c09                	li	s8,2
    8000238a:	4991                	li	s3,4
    8000238c:	4ba1                	li	s7,8
    8000238e:	4b41                	li	s6,16
			c->proc = p;
    80002390:	079e                	slli	a5,a5,0x7
    80002392:	0000f917          	auipc	s2,0xf
    80002396:	abe90913          	addi	s2,s2,-1346 # 80010e50 <pid_lock>
    8000239a:	993e                	add	s2,s2,a5
			p->enter_time = ticks;
    8000239c:	00007a97          	auipc	s5,0x7
    800023a0:	844a8a93          	addi	s5,s5,-1980 # 80008be0 <ticks>
    800023a4:	a095                	j	80002408 <scheduler+0xbe>
			acquire(&p->lock);
    800023a6:	00850d13          	addi	s10,a0,8
    800023aa:	856a                	mv	a0,s10
    800023ac:	fffff097          	auipc	ra,0xfffff
    800023b0:	83e080e7          	jalr	-1986(ra) # 80000bea <acquire>
			int slices[5] = {1, 2, 4, 8, 16};
    800023b4:	f9942423          	sw	s9,-120(s0)
    800023b8:	f9842623          	sw	s8,-116(s0)
    800023bc:	f9342823          	sw	s3,-112(s0)
    800023c0:	f9742a23          	sw	s7,-108(s0)
    800023c4:	f9642c23          	sw	s6,-104(s0)
			p->time_slice = slices[level];
    800023c8:	1a84a783          	lw	a5,424(s1)
    800023cc:	078a                	slli	a5,a5,0x2
    800023ce:	fa040713          	addi	a4,s0,-96
    800023d2:	97ba                	add	a5,a5,a4
    800023d4:	fe87a783          	lw	a5,-24(a5)
    800023d8:	1af4ac23          	sw	a5,440(s1)
			c->proc = p;
    800023dc:	02993823          	sd	s1,48(s2)
			p->state = RUNNING;
    800023e0:	0334a023          	sw	s3,32(s1)
			swtch(&c->context, &p->context);
    800023e4:	06848593          	addi	a1,s1,104
    800023e8:	8552                	mv	a0,s4
    800023ea:	00001097          	auipc	ra,0x1
    800023ee:	98e080e7          	jalr	-1650(ra) # 80002d78 <swtch>
			c->proc = 0;
    800023f2:	02093823          	sd	zero,48(s2)
			p->enter_time = ticks;
    800023f6:	000aa783          	lw	a5,0(s5)
    800023fa:	1af4a823          	sw	a5,432(s1)
			release(&p->lock);
    800023fe:	856a                	mv	a0,s10
    80002400:	fffff097          	auipc	ra,0xfffff
    80002404:	89e080e7          	jalr	-1890(ra) # 80000c9e <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002408:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000240c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002410:	10079073          	csrw	sstatus,a5
		p = mlfq_sched();
    80002414:	00000097          	auipc	ra,0x0
    80002418:	de8080e7          	jalr	-536(ra) # 800021fc <mlfq_sched>
    8000241c:	84aa                	mv	s1,a0
		if (!p)
    8000241e:	f541                	bnez	a0,800023a6 <scheduler+0x5c>
    80002420:	b7e5                	j	80002408 <scheduler+0xbe>

0000000080002422 <sched>:
{
    80002422:	7179                	addi	sp,sp,-48
    80002424:	f406                	sd	ra,40(sp)
    80002426:	f022                	sd	s0,32(sp)
    80002428:	ec26                	sd	s1,24(sp)
    8000242a:	e84a                	sd	s2,16(sp)
    8000242c:	e44e                	sd	s3,8(sp)
    8000242e:	1800                	addi	s0,sp,48
	struct proc *p = myproc();
    80002430:	fffff097          	auipc	ra,0xfffff
    80002434:	7ba080e7          	jalr	1978(ra) # 80001bea <myproc>
    80002438:	84aa                	mv	s1,a0
	if (!holding(&p->lock))
    8000243a:	0521                	addi	a0,a0,8
    8000243c:	ffffe097          	auipc	ra,0xffffe
    80002440:	734080e7          	jalr	1844(ra) # 80000b70 <holding>
    80002444:	c93d                	beqz	a0,800024ba <sched+0x98>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002446:	8792                	mv	a5,tp
	if (mycpu()->noff != 1)
    80002448:	2781                	sext.w	a5,a5
    8000244a:	079e                	slli	a5,a5,0x7
    8000244c:	0000f717          	auipc	a4,0xf
    80002450:	a0470713          	addi	a4,a4,-1532 # 80010e50 <pid_lock>
    80002454:	97ba                	add	a5,a5,a4
    80002456:	0a87a703          	lw	a4,168(a5)
    8000245a:	4785                	li	a5,1
    8000245c:	06f71763          	bne	a4,a5,800024ca <sched+0xa8>
	if (p->state == RUNNING)
    80002460:	5098                	lw	a4,32(s1)
    80002462:	4791                	li	a5,4
    80002464:	06f70b63          	beq	a4,a5,800024da <sched+0xb8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002468:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000246c:	8b89                	andi	a5,a5,2
	if (intr_get())
    8000246e:	efb5                	bnez	a5,800024ea <sched+0xc8>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002470:	8792                	mv	a5,tp
	intena = mycpu()->intena;
    80002472:	0000f917          	auipc	s2,0xf
    80002476:	9de90913          	addi	s2,s2,-1570 # 80010e50 <pid_lock>
    8000247a:	2781                	sext.w	a5,a5
    8000247c:	079e                	slli	a5,a5,0x7
    8000247e:	97ca                	add	a5,a5,s2
    80002480:	0ac7a983          	lw	s3,172(a5)
    80002484:	8792                	mv	a5,tp
	swtch(&p->context, &mycpu()->context);
    80002486:	2781                	sext.w	a5,a5
    80002488:	079e                	slli	a5,a5,0x7
    8000248a:	0000f597          	auipc	a1,0xf
    8000248e:	9fe58593          	addi	a1,a1,-1538 # 80010e88 <cpus+0x8>
    80002492:	95be                	add	a1,a1,a5
    80002494:	06848513          	addi	a0,s1,104
    80002498:	00001097          	auipc	ra,0x1
    8000249c:	8e0080e7          	jalr	-1824(ra) # 80002d78 <swtch>
    800024a0:	8792                	mv	a5,tp
	mycpu()->intena = intena;
    800024a2:	2781                	sext.w	a5,a5
    800024a4:	079e                	slli	a5,a5,0x7
    800024a6:	97ca                	add	a5,a5,s2
    800024a8:	0b37a623          	sw	s3,172(a5)
}
    800024ac:	70a2                	ld	ra,40(sp)
    800024ae:	7402                	ld	s0,32(sp)
    800024b0:	64e2                	ld	s1,24(sp)
    800024b2:	6942                	ld	s2,16(sp)
    800024b4:	69a2                	ld	s3,8(sp)
    800024b6:	6145                	addi	sp,sp,48
    800024b8:	8082                	ret
		panic("sched p->lock");
    800024ba:	00006517          	auipc	a0,0x6
    800024be:	d7650513          	addi	a0,a0,-650 # 80008230 <digits+0x1f0>
    800024c2:	ffffe097          	auipc	ra,0xffffe
    800024c6:	082080e7          	jalr	130(ra) # 80000544 <panic>
		panic("sched locks");
    800024ca:	00006517          	auipc	a0,0x6
    800024ce:	d7650513          	addi	a0,a0,-650 # 80008240 <digits+0x200>
    800024d2:	ffffe097          	auipc	ra,0xffffe
    800024d6:	072080e7          	jalr	114(ra) # 80000544 <panic>
		panic("sched running");
    800024da:	00006517          	auipc	a0,0x6
    800024de:	d7650513          	addi	a0,a0,-650 # 80008250 <digits+0x210>
    800024e2:	ffffe097          	auipc	ra,0xffffe
    800024e6:	062080e7          	jalr	98(ra) # 80000544 <panic>
		panic("sched interruptible");
    800024ea:	00006517          	auipc	a0,0x6
    800024ee:	d7650513          	addi	a0,a0,-650 # 80008260 <digits+0x220>
    800024f2:	ffffe097          	auipc	ra,0xffffe
    800024f6:	052080e7          	jalr	82(ra) # 80000544 <panic>

00000000800024fa <yield>:
{
    800024fa:	1101                	addi	sp,sp,-32
    800024fc:	ec06                	sd	ra,24(sp)
    800024fe:	e822                	sd	s0,16(sp)
    80002500:	e426                	sd	s1,8(sp)
    80002502:	e04a                	sd	s2,0(sp)
    80002504:	1000                	addi	s0,sp,32
	struct proc *p = myproc();
    80002506:	fffff097          	auipc	ra,0xfffff
    8000250a:	6e4080e7          	jalr	1764(ra) # 80001bea <myproc>
    8000250e:	84aa                	mv	s1,a0
	acquire(&p->lock);
    80002510:	00850913          	addi	s2,a0,8
    80002514:	854a                	mv	a0,s2
    80002516:	ffffe097          	auipc	ra,0xffffe
    8000251a:	6d4080e7          	jalr	1748(ra) # 80000bea <acquire>
	p->state = RUNNABLE;
    8000251e:	478d                	li	a5,3
    80002520:	d09c                	sw	a5,32(s1)
	sched();
    80002522:	00000097          	auipc	ra,0x0
    80002526:	f00080e7          	jalr	-256(ra) # 80002422 <sched>
	release(&p->lock);
    8000252a:	854a                	mv	a0,s2
    8000252c:	ffffe097          	auipc	ra,0xffffe
    80002530:	772080e7          	jalr	1906(ra) # 80000c9e <release>
}
    80002534:	60e2                	ld	ra,24(sp)
    80002536:	6442                	ld	s0,16(sp)
    80002538:	64a2                	ld	s1,8(sp)
    8000253a:	6902                	ld	s2,0(sp)
    8000253c:	6105                	addi	sp,sp,32
    8000253e:	8082                	ret

0000000080002540 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    80002540:	7179                	addi	sp,sp,-48
    80002542:	f406                	sd	ra,40(sp)
    80002544:	f022                	sd	s0,32(sp)
    80002546:	ec26                	sd	s1,24(sp)
    80002548:	e84a                	sd	s2,16(sp)
    8000254a:	e44e                	sd	s3,8(sp)
    8000254c:	e052                	sd	s4,0(sp)
    8000254e:	1800                	addi	s0,sp,48
    80002550:	89aa                	mv	s3,a0
    80002552:	892e                	mv	s2,a1
	struct proc *p = myproc();
    80002554:	fffff097          	auipc	ra,0xfffff
    80002558:	696080e7          	jalr	1686(ra) # 80001bea <myproc>
    8000255c:	84aa                	mv	s1,a0
	// Once we hold p->lock, we can be
	// guaranteed that we won't miss any wakeup
	// (wakeup locks p->lock),
	// so it's okay to release lk.

	acquire(&p->lock); // DOC: sleeplock1
    8000255e:	00850a13          	addi	s4,a0,8
    80002562:	8552                	mv	a0,s4
    80002564:	ffffe097          	auipc	ra,0xffffe
    80002568:	686080e7          	jalr	1670(ra) # 80000bea <acquire>
	release(lk);
    8000256c:	854a                	mv	a0,s2
    8000256e:	ffffe097          	auipc	ra,0xffffe
    80002572:	730080e7          	jalr	1840(ra) # 80000c9e <release>

	// Go to sleep.
	p->chan = chan;
    80002576:	0334b423          	sd	s3,40(s1)
	p->state = SLEEPING;
    8000257a:	4789                	li	a5,2
    8000257c:	d09c                	sw	a5,32(s1)

	sched();
    8000257e:	00000097          	auipc	ra,0x0
    80002582:	ea4080e7          	jalr	-348(ra) # 80002422 <sched>

	// Tidy up.
	p->chan = 0;
    80002586:	0204b423          	sd	zero,40(s1)

	// Reacquire original lock.
	release(&p->lock);
    8000258a:	8552                	mv	a0,s4
    8000258c:	ffffe097          	auipc	ra,0xffffe
    80002590:	712080e7          	jalr	1810(ra) # 80000c9e <release>
	acquire(lk);
    80002594:	854a                	mv	a0,s2
    80002596:	ffffe097          	auipc	ra,0xffffe
    8000259a:	654080e7          	jalr	1620(ra) # 80000bea <acquire>
}
    8000259e:	70a2                	ld	ra,40(sp)
    800025a0:	7402                	ld	s0,32(sp)
    800025a2:	64e2                	ld	s1,24(sp)
    800025a4:	6942                	ld	s2,16(sp)
    800025a6:	69a2                	ld	s3,8(sp)
    800025a8:	6a02                	ld	s4,0(sp)
    800025aa:	6145                	addi	sp,sp,48
    800025ac:	8082                	ret

00000000800025ae <waitx>:
{
    800025ae:	7159                	addi	sp,sp,-112
    800025b0:	f486                	sd	ra,104(sp)
    800025b2:	f0a2                	sd	s0,96(sp)
    800025b4:	eca6                	sd	s1,88(sp)
    800025b6:	e8ca                	sd	s2,80(sp)
    800025b8:	e4ce                	sd	s3,72(sp)
    800025ba:	e0d2                	sd	s4,64(sp)
    800025bc:	fc56                	sd	s5,56(sp)
    800025be:	f85a                	sd	s6,48(sp)
    800025c0:	f45e                	sd	s7,40(sp)
    800025c2:	f062                	sd	s8,32(sp)
    800025c4:	ec66                	sd	s9,24(sp)
    800025c6:	e86a                	sd	s10,16(sp)
    800025c8:	e46e                	sd	s11,8(sp)
    800025ca:	1880                	addi	s0,sp,112
    800025cc:	8b2a                	mv	s6,a0
    800025ce:	8bae                	mv	s7,a1
    800025d0:	8c32                	mv	s8,a2
	struct proc *p = myproc();
    800025d2:	fffff097          	auipc	ra,0xfffff
    800025d6:	618080e7          	jalr	1560(ra) # 80001bea <myproc>
    800025da:	892a                	mv	s2,a0
	acquire(&wait_lock);
    800025dc:	0000f517          	auipc	a0,0xf
    800025e0:	88c50513          	addi	a0,a0,-1908 # 80010e68 <wait_lock>
    800025e4:	ffffe097          	auipc	ra,0xffffe
    800025e8:	606080e7          	jalr	1542(ra) # 80000bea <acquire>
		havekids = 0;
    800025ec:	4c81                	li	s9,0
				if (np->state == ZOMBIE)
    800025ee:	4a15                	li	s4,5
		for (np = proc; np < &proc[NPROC]; np++)
    800025f0:	00017997          	auipc	s3,0x17
    800025f4:	b0898993          	addi	s3,s3,-1272 # 800190f8 <tickslock>
				havekids = 1;
    800025f8:	4a85                	li	s5,1
		sleep(p, &wait_lock); // DOC: wait-sleep
    800025fa:	0000fd17          	auipc	s10,0xf
    800025fe:	86ed0d13          	addi	s10,s10,-1938 # 80010e68 <wait_lock>
		havekids = 0;
    80002602:	8766                	mv	a4,s9
		for (np = proc; np < &proc[NPROC]; np++)
    80002604:	0000f497          	auipc	s1,0xf
    80002608:	6f448493          	addi	s1,s1,1780 # 80011cf8 <proc>
    8000260c:	a04d                	j	800026ae <waitx+0x100>
					pid = np->pid;
    8000260e:	0384a983          	lw	s3,56(s1)
					*rtime = np->runTime;
    80002612:	1804a683          	lw	a3,384(s1)
    80002616:	00dc2023          	sw	a3,0(s8)
					printf("%d %d %d\n", np->endTime, np->creationTime, np->runTime);
    8000261a:	17c4a603          	lw	a2,380(s1)
    8000261e:	1844a583          	lw	a1,388(s1)
    80002622:	00006517          	auipc	a0,0x6
    80002626:	c5650513          	addi	a0,a0,-938 # 80008278 <digits+0x238>
    8000262a:	ffffe097          	auipc	ra,0xffffe
    8000262e:	f64080e7          	jalr	-156(ra) # 8000058e <printf>
					*wtime = np->endTime - np->creationTime - np->runTime;
    80002632:	17c4a783          	lw	a5,380(s1)
    80002636:	1804a703          	lw	a4,384(s1)
    8000263a:	9f3d                	addw	a4,a4,a5
    8000263c:	1844a783          	lw	a5,388(s1)
    80002640:	9f99                	subw	a5,a5,a4
    80002642:	00fba023          	sw	a5,0(s7) # fffffffffffff000 <end+0xffffffff7ffdab28>
					if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002646:	000b0e63          	beqz	s6,80002662 <waitx+0xb4>
    8000264a:	4691                	li	a3,4
    8000264c:	03448613          	addi	a2,s1,52
    80002650:	85da                	mv	a1,s6
    80002652:	05893503          	ld	a0,88(s2)
    80002656:	fffff097          	auipc	ra,0xfffff
    8000265a:	02e080e7          	jalr	46(ra) # 80001684 <copyout>
    8000265e:	02054563          	bltz	a0,80002688 <waitx+0xda>
					freeproc(np);
    80002662:	8526                	mv	a0,s1
    80002664:	fffff097          	auipc	ra,0xfffff
    80002668:	73a080e7          	jalr	1850(ra) # 80001d9e <freeproc>
					release(&np->lock);
    8000266c:	856e                	mv	a0,s11
    8000266e:	ffffe097          	auipc	ra,0xffffe
    80002672:	630080e7          	jalr	1584(ra) # 80000c9e <release>
					release(&wait_lock);
    80002676:	0000e517          	auipc	a0,0xe
    8000267a:	7f250513          	addi	a0,a0,2034 # 80010e68 <wait_lock>
    8000267e:	ffffe097          	auipc	ra,0xffffe
    80002682:	620080e7          	jalr	1568(ra) # 80000c9e <release>
					return pid;
    80002686:	a0ad                	j	800026f0 <waitx+0x142>
						release(&np->lock);
    80002688:	856e                	mv	a0,s11
    8000268a:	ffffe097          	auipc	ra,0xffffe
    8000268e:	614080e7          	jalr	1556(ra) # 80000c9e <release>
						release(&wait_lock);
    80002692:	0000e517          	auipc	a0,0xe
    80002696:	7d650513          	addi	a0,a0,2006 # 80010e68 <wait_lock>
    8000269a:	ffffe097          	auipc	ra,0xffffe
    8000269e:	604080e7          	jalr	1540(ra) # 80000c9e <release>
						return -1;
    800026a2:	59fd                	li	s3,-1
    800026a4:	a0b1                	j	800026f0 <waitx+0x142>
		for (np = proc; np < &proc[NPROC]; np++)
    800026a6:	1d048493          	addi	s1,s1,464
    800026aa:	03348663          	beq	s1,s3,800026d6 <waitx+0x128>
			if (np->parent == p)
    800026ae:	60bc                	ld	a5,64(s1)
    800026b0:	ff279be3          	bne	a5,s2,800026a6 <waitx+0xf8>
				acquire(&np->lock);
    800026b4:	00848d93          	addi	s11,s1,8
    800026b8:	856e                	mv	a0,s11
    800026ba:	ffffe097          	auipc	ra,0xffffe
    800026be:	530080e7          	jalr	1328(ra) # 80000bea <acquire>
				if (np->state == ZOMBIE)
    800026c2:	509c                	lw	a5,32(s1)
    800026c4:	f54785e3          	beq	a5,s4,8000260e <waitx+0x60>
				release(&np->lock);
    800026c8:	856e                	mv	a0,s11
    800026ca:	ffffe097          	auipc	ra,0xffffe
    800026ce:	5d4080e7          	jalr	1492(ra) # 80000c9e <release>
				havekids = 1;
    800026d2:	8756                	mv	a4,s5
    800026d4:	bfc9                	j	800026a6 <waitx+0xf8>
		if (!havekids || p->killed)
    800026d6:	c701                	beqz	a4,800026de <waitx+0x130>
    800026d8:	03092783          	lw	a5,48(s2)
    800026dc:	cb95                	beqz	a5,80002710 <waitx+0x162>
			release(&wait_lock);
    800026de:	0000e517          	auipc	a0,0xe
    800026e2:	78a50513          	addi	a0,a0,1930 # 80010e68 <wait_lock>
    800026e6:	ffffe097          	auipc	ra,0xffffe
    800026ea:	5b8080e7          	jalr	1464(ra) # 80000c9e <release>
			return -1;
    800026ee:	59fd                	li	s3,-1
}
    800026f0:	854e                	mv	a0,s3
    800026f2:	70a6                	ld	ra,104(sp)
    800026f4:	7406                	ld	s0,96(sp)
    800026f6:	64e6                	ld	s1,88(sp)
    800026f8:	6946                	ld	s2,80(sp)
    800026fa:	69a6                	ld	s3,72(sp)
    800026fc:	6a06                	ld	s4,64(sp)
    800026fe:	7ae2                	ld	s5,56(sp)
    80002700:	7b42                	ld	s6,48(sp)
    80002702:	7ba2                	ld	s7,40(sp)
    80002704:	7c02                	ld	s8,32(sp)
    80002706:	6ce2                	ld	s9,24(sp)
    80002708:	6d42                	ld	s10,16(sp)
    8000270a:	6da2                	ld	s11,8(sp)
    8000270c:	6165                	addi	sp,sp,112
    8000270e:	8082                	ret
		sleep(p, &wait_lock); // DOC: wait-sleep
    80002710:	85ea                	mv	a1,s10
    80002712:	854a                	mv	a0,s2
    80002714:	00000097          	auipc	ra,0x0
    80002718:	e2c080e7          	jalr	-468(ra) # 80002540 <sleep>
		havekids = 0;
    8000271c:	b5dd                	j	80002602 <waitx+0x54>

000000008000271e <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    8000271e:	7175                	addi	sp,sp,-144
    80002720:	e506                	sd	ra,136(sp)
    80002722:	e122                	sd	s0,128(sp)
    80002724:	fca6                	sd	s1,120(sp)
    80002726:	f8ca                	sd	s2,112(sp)
    80002728:	f4ce                	sd	s3,104(sp)
    8000272a:	f0d2                	sd	s4,96(sp)
    8000272c:	ecd6                	sd	s5,88(sp)
    8000272e:	e8da                	sd	s6,80(sp)
    80002730:	e4de                	sd	s7,72(sp)
    80002732:	e0e2                	sd	s8,64(sp)
    80002734:	fc66                	sd	s9,56(sp)
    80002736:	f86a                	sd	s10,48(sp)
    80002738:	f46e                	sd	s11,40(sp)
    8000273a:	0900                	addi	s0,sp,144
    8000273c:	8a2a                	mv	s4,a0
	struct proc *p;

	for (p = proc; p < &proc[NPROC]; p++)
    8000273e:	0000f497          	auipc	s1,0xf
    80002742:	5ba48493          	addi	s1,s1,1466 # 80011cf8 <proc>
	{
		if (p != myproc())
		{
			acquire(&p->lock);
			if (p->state == SLEEPING && p->chan == chan)
    80002746:	4989                	li	s3,2
			{
				p->state = RUNNABLE;
    80002748:	4d0d                	li	s10,3
					p->sleepTimePrev = ticks - p->sleepStartTime;
					p->totalSleep += p->sleepTimePrev;
				}
// #endif
#ifdef MLFQ
				p->enter_time = ticks;
    8000274a:	00006b17          	auipc	s6,0x6
    8000274e:	496b0b13          	addi	s6,s6,1174 # 80008be0 <ticks>
				p->queue[p->curr_queue] = 0;
				p->in_queue = 1;
    80002752:	4a85                	li	s5,1
				int slices[5] = {1, 2, 4, 8, 16};
    80002754:	4c89                	li	s9,2
    80002756:	4c11                	li	s8,4
				p->time_slice = slices[p->curr_queue];
				push(&mlfq[p->curr_queue], p);
    80002758:	0000fb97          	auipc	s7,0xf
    8000275c:	b28b8b93          	addi	s7,s7,-1240 # 80011280 <mlfq>
	for (p = proc; p < &proc[NPROC]; p++)
    80002760:	00017917          	auipc	s2,0x17
    80002764:	99890913          	addi	s2,s2,-1640 # 800190f8 <tickslock>
    80002768:	a0bd                	j	800027d6 <wakeup+0xb8>
				p->enter_time = ticks;
    8000276a:	000b2783          	lw	a5,0(s6)
    8000276e:	1af4a823          	sw	a5,432(s1)
				p->queue[p->curr_queue] = 0;
    80002772:	1a84a503          	lw	a0,424(s1)
    80002776:	06c50793          	addi	a5,a0,108
    8000277a:	078a                	slli	a5,a5,0x2
    8000277c:	97a6                	add	a5,a5,s1
    8000277e:	0007a623          	sw	zero,12(a5)
				p->in_queue = 1;
    80002782:	1b54aa23          	sw	s5,436(s1)
				int slices[5] = {1, 2, 4, 8, 16};
    80002786:	f7542c23          	sw	s5,-136(s0)
    8000278a:	f7942e23          	sw	s9,-132(s0)
    8000278e:	f9842023          	sw	s8,-128(s0)
    80002792:	47a1                	li	a5,8
    80002794:	f8f42223          	sw	a5,-124(s0)
    80002798:	47c1                	li	a5,16
    8000279a:	f8f42423          	sw	a5,-120(s0)
				p->time_slice = slices[p->curr_queue];
    8000279e:	00251793          	slli	a5,a0,0x2
    800027a2:	f9040713          	addi	a4,s0,-112
    800027a6:	97ba                	add	a5,a5,a4
    800027a8:	fe87a783          	lw	a5,-24(a5)
    800027ac:	1af4ac23          	sw	a5,440(s1)
				push(&mlfq[p->curr_queue], p);
    800027b0:	21800793          	li	a5,536
    800027b4:	02f50533          	mul	a0,a0,a5
    800027b8:	85a6                	mv	a1,s1
    800027ba:	955e                	add	a0,a0,s7
    800027bc:	fffff097          	auipc	ra,0xfffff
    800027c0:	1cc080e7          	jalr	460(ra) # 80001988 <push>
#endif
			}
			release(&p->lock);
    800027c4:	856e                	mv	a0,s11
    800027c6:	ffffe097          	auipc	ra,0xffffe
    800027ca:	4d8080e7          	jalr	1240(ra) # 80000c9e <release>
	for (p = proc; p < &proc[NPROC]; p++)
    800027ce:	1d048493          	addi	s1,s1,464
    800027d2:	05248663          	beq	s1,s2,8000281e <wakeup+0x100>
		if (p != myproc())
    800027d6:	fffff097          	auipc	ra,0xfffff
    800027da:	414080e7          	jalr	1044(ra) # 80001bea <myproc>
    800027de:	fea488e3          	beq	s1,a0,800027ce <wakeup+0xb0>
			acquire(&p->lock);
    800027e2:	00848d93          	addi	s11,s1,8
    800027e6:	856e                	mv	a0,s11
    800027e8:	ffffe097          	auipc	ra,0xffffe
    800027ec:	402080e7          	jalr	1026(ra) # 80000bea <acquire>
			if (p->state == SLEEPING && p->chan == chan)
    800027f0:	509c                	lw	a5,32(s1)
    800027f2:	fd3799e3          	bne	a5,s3,800027c4 <wakeup+0xa6>
    800027f6:	749c                	ld	a5,40(s1)
    800027f8:	fd4796e3          	bne	a5,s4,800027c4 <wakeup+0xa6>
				p->state = RUNNABLE;
    800027fc:	03a4a023          	sw	s10,32(s1)
				if (p->sleepStartTime != 0)
    80002800:	1904a783          	lw	a5,400(s1)
    80002804:	d3bd                	beqz	a5,8000276a <wakeup+0x4c>
					p->sleepTimePrev = ticks - p->sleepStartTime;
    80002806:	000b2703          	lw	a4,0(s6)
    8000280a:	40f707bb          	subw	a5,a4,a5
    8000280e:	18f4a623          	sw	a5,396(s1)
					p->totalSleep += p->sleepTimePrev;
    80002812:	1884a703          	lw	a4,392(s1)
    80002816:	9fb9                	addw	a5,a5,a4
    80002818:	18f4a423          	sw	a5,392(s1)
    8000281c:	b7b9                	j	8000276a <wakeup+0x4c>
		}
	}
}
    8000281e:	60aa                	ld	ra,136(sp)
    80002820:	640a                	ld	s0,128(sp)
    80002822:	74e6                	ld	s1,120(sp)
    80002824:	7946                	ld	s2,112(sp)
    80002826:	79a6                	ld	s3,104(sp)
    80002828:	7a06                	ld	s4,96(sp)
    8000282a:	6ae6                	ld	s5,88(sp)
    8000282c:	6b46                	ld	s6,80(sp)
    8000282e:	6ba6                	ld	s7,72(sp)
    80002830:	6c06                	ld	s8,64(sp)
    80002832:	7ce2                	ld	s9,56(sp)
    80002834:	7d42                	ld	s10,48(sp)
    80002836:	7da2                	ld	s11,40(sp)
    80002838:	6149                	addi	sp,sp,144
    8000283a:	8082                	ret

000000008000283c <reparent>:
{
    8000283c:	7179                	addi	sp,sp,-48
    8000283e:	f406                	sd	ra,40(sp)
    80002840:	f022                	sd	s0,32(sp)
    80002842:	ec26                	sd	s1,24(sp)
    80002844:	e84a                	sd	s2,16(sp)
    80002846:	e44e                	sd	s3,8(sp)
    80002848:	e052                	sd	s4,0(sp)
    8000284a:	1800                	addi	s0,sp,48
    8000284c:	892a                	mv	s2,a0
	for (pp = proc; pp < &proc[NPROC]; pp++)
    8000284e:	0000f497          	auipc	s1,0xf
    80002852:	4aa48493          	addi	s1,s1,1194 # 80011cf8 <proc>
			pp->parent = initproc;
    80002856:	00006a17          	auipc	s4,0x6
    8000285a:	382a0a13          	addi	s4,s4,898 # 80008bd8 <initproc>
	for (pp = proc; pp < &proc[NPROC]; pp++)
    8000285e:	00017997          	auipc	s3,0x17
    80002862:	89a98993          	addi	s3,s3,-1894 # 800190f8 <tickslock>
    80002866:	a029                	j	80002870 <reparent+0x34>
    80002868:	1d048493          	addi	s1,s1,464
    8000286c:	01348d63          	beq	s1,s3,80002886 <reparent+0x4a>
		if (pp->parent == p)
    80002870:	60bc                	ld	a5,64(s1)
    80002872:	ff279be3          	bne	a5,s2,80002868 <reparent+0x2c>
			pp->parent = initproc;
    80002876:	000a3503          	ld	a0,0(s4)
    8000287a:	e0a8                	sd	a0,64(s1)
			wakeup(initproc);
    8000287c:	00000097          	auipc	ra,0x0
    80002880:	ea2080e7          	jalr	-350(ra) # 8000271e <wakeup>
    80002884:	b7d5                	j	80002868 <reparent+0x2c>
}
    80002886:	70a2                	ld	ra,40(sp)
    80002888:	7402                	ld	s0,32(sp)
    8000288a:	64e2                	ld	s1,24(sp)
    8000288c:	6942                	ld	s2,16(sp)
    8000288e:	69a2                	ld	s3,8(sp)
    80002890:	6a02                	ld	s4,0(sp)
    80002892:	6145                	addi	sp,sp,48
    80002894:	8082                	ret

0000000080002896 <exit>:
{
    80002896:	7179                	addi	sp,sp,-48
    80002898:	f406                	sd	ra,40(sp)
    8000289a:	f022                	sd	s0,32(sp)
    8000289c:	ec26                	sd	s1,24(sp)
    8000289e:	e84a                	sd	s2,16(sp)
    800028a0:	e44e                	sd	s3,8(sp)
    800028a2:	e052                	sd	s4,0(sp)
    800028a4:	1800                	addi	s0,sp,48
    800028a6:	8a2a                	mv	s4,a0
	struct proc *p = myproc();
    800028a8:	fffff097          	auipc	ra,0xfffff
    800028ac:	342080e7          	jalr	834(ra) # 80001bea <myproc>
    800028b0:	89aa                	mv	s3,a0
	if (p == initproc)
    800028b2:	00006797          	auipc	a5,0x6
    800028b6:	3267b783          	ld	a5,806(a5) # 80008bd8 <initproc>
    800028ba:	0d850493          	addi	s1,a0,216
    800028be:	15850913          	addi	s2,a0,344
    800028c2:	02a79363          	bne	a5,a0,800028e8 <exit+0x52>
		panic("init exiting");
    800028c6:	00006517          	auipc	a0,0x6
    800028ca:	9c250513          	addi	a0,a0,-1598 # 80008288 <digits+0x248>
    800028ce:	ffffe097          	auipc	ra,0xffffe
    800028d2:	c76080e7          	jalr	-906(ra) # 80000544 <panic>
			fileclose(f);
    800028d6:	00002097          	auipc	ra,0x2
    800028da:	66a080e7          	jalr	1642(ra) # 80004f40 <fileclose>
			p->ofile[fd] = 0;
    800028de:	0004b023          	sd	zero,0(s1)
	for (int fd = 0; fd < NOFILE; fd++)
    800028e2:	04a1                	addi	s1,s1,8
    800028e4:	01248563          	beq	s1,s2,800028ee <exit+0x58>
		if (p->ofile[fd])
    800028e8:	6088                	ld	a0,0(s1)
    800028ea:	f575                	bnez	a0,800028d6 <exit+0x40>
    800028ec:	bfdd                	j	800028e2 <exit+0x4c>
	begin_op();
    800028ee:	00002097          	auipc	ra,0x2
    800028f2:	186080e7          	jalr	390(ra) # 80004a74 <begin_op>
	iput(p->cwd);
    800028f6:	1589b503          	ld	a0,344(s3)
    800028fa:	00002097          	auipc	ra,0x2
    800028fe:	972080e7          	jalr	-1678(ra) # 8000426c <iput>
	end_op();
    80002902:	00002097          	auipc	ra,0x2
    80002906:	1f2080e7          	jalr	498(ra) # 80004af4 <end_op>
	p->cwd = 0;
    8000290a:	1409bc23          	sd	zero,344(s3)
	acquire(&wait_lock);
    8000290e:	0000e497          	auipc	s1,0xe
    80002912:	55a48493          	addi	s1,s1,1370 # 80010e68 <wait_lock>
    80002916:	8526                	mv	a0,s1
    80002918:	ffffe097          	auipc	ra,0xffffe
    8000291c:	2d2080e7          	jalr	722(ra) # 80000bea <acquire>
	reparent(p);
    80002920:	854e                	mv	a0,s3
    80002922:	00000097          	auipc	ra,0x0
    80002926:	f1a080e7          	jalr	-230(ra) # 8000283c <reparent>
	wakeup(p->parent);
    8000292a:	0409b503          	ld	a0,64(s3)
    8000292e:	00000097          	auipc	ra,0x0
    80002932:	df0080e7          	jalr	-528(ra) # 8000271e <wakeup>
	acquire(&p->lock);
    80002936:	00898513          	addi	a0,s3,8
    8000293a:	ffffe097          	auipc	ra,0xffffe
    8000293e:	2b0080e7          	jalr	688(ra) # 80000bea <acquire>
	p->xstate = status;
    80002942:	0349aa23          	sw	s4,52(s3)
	p->state = ZOMBIE;
    80002946:	4795                	li	a5,5
    80002948:	02f9a023          	sw	a5,32(s3)
	p->endTime = ticks;
    8000294c:	00006797          	auipc	a5,0x6
    80002950:	2947a783          	lw	a5,660(a5) # 80008be0 <ticks>
    80002954:	18f9a223          	sw	a5,388(s3)
	release(&wait_lock);
    80002958:	8526                	mv	a0,s1
    8000295a:	ffffe097          	auipc	ra,0xffffe
    8000295e:	344080e7          	jalr	836(ra) # 80000c9e <release>
	sched();
    80002962:	00000097          	auipc	ra,0x0
    80002966:	ac0080e7          	jalr	-1344(ra) # 80002422 <sched>
	panic("zombie exit");
    8000296a:	00006517          	auipc	a0,0x6
    8000296e:	92e50513          	addi	a0,a0,-1746 # 80008298 <digits+0x258>
    80002972:	ffffe097          	auipc	ra,0xffffe
    80002976:	bd2080e7          	jalr	-1070(ra) # 80000544 <panic>

000000008000297a <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    8000297a:	715d                	addi	sp,sp,-80
    8000297c:	e486                	sd	ra,72(sp)
    8000297e:	e0a2                	sd	s0,64(sp)
    80002980:	fc26                	sd	s1,56(sp)
    80002982:	f84a                	sd	s2,48(sp)
    80002984:	f44e                	sd	s3,40(sp)
    80002986:	f052                	sd	s4,32(sp)
    80002988:	0880                	addi	s0,sp,80
    8000298a:	89aa                	mv	s3,a0
	struct proc *p;

	for (p = proc; p < &proc[NPROC]; p++)
    8000298c:	0000f497          	auipc	s1,0xf
    80002990:	36c48493          	addi	s1,s1,876 # 80011cf8 <proc>
    80002994:	00016a17          	auipc	s4,0x16
    80002998:	764a0a13          	addi	s4,s4,1892 # 800190f8 <tickslock>
	{
		acquire(&p->lock);
    8000299c:	00848913          	addi	s2,s1,8
    800029a0:	854a                	mv	a0,s2
    800029a2:	ffffe097          	auipc	ra,0xffffe
    800029a6:	248080e7          	jalr	584(ra) # 80000bea <acquire>
		if (p->pid == pid)
    800029aa:	5c9c                	lw	a5,56(s1)
    800029ac:	01378d63          	beq	a5,s3,800029c6 <kill+0x4c>
#endif
			}
			release(&p->lock);
			return 0;
		}
		release(&p->lock);
    800029b0:	854a                	mv	a0,s2
    800029b2:	ffffe097          	auipc	ra,0xffffe
    800029b6:	2ec080e7          	jalr	748(ra) # 80000c9e <release>
	for (p = proc; p < &proc[NPROC]; p++)
    800029ba:	1d048493          	addi	s1,s1,464
    800029be:	fd449fe3          	bne	s1,s4,8000299c <kill+0x22>
	}
	return -1;
    800029c2:	557d                	li	a0,-1
    800029c4:	a829                	j	800029de <kill+0x64>
			p->killed = 1;
    800029c6:	4785                	li	a5,1
    800029c8:	d89c                	sw	a5,48(s1)
			if (p->state == SLEEPING)
    800029ca:	5098                	lw	a4,32(s1)
    800029cc:	4789                	li	a5,2
    800029ce:	02f70063          	beq	a4,a5,800029ee <kill+0x74>
			release(&p->lock);
    800029d2:	854a                	mv	a0,s2
    800029d4:	ffffe097          	auipc	ra,0xffffe
    800029d8:	2ca080e7          	jalr	714(ra) # 80000c9e <release>
			return 0;
    800029dc:	4501                	li	a0,0
}
    800029de:	60a6                	ld	ra,72(sp)
    800029e0:	6406                	ld	s0,64(sp)
    800029e2:	74e2                	ld	s1,56(sp)
    800029e4:	7942                	ld	s2,48(sp)
    800029e6:	79a2                	ld	s3,40(sp)
    800029e8:	7a02                	ld	s4,32(sp)
    800029ea:	6161                	addi	sp,sp,80
    800029ec:	8082                	ret
				p->sleepTimePrev = ticks - p->sleepStartTime;
    800029ee:	00006717          	auipc	a4,0x6
    800029f2:	1f272703          	lw	a4,498(a4) # 80008be0 <ticks>
    800029f6:	1904a783          	lw	a5,400(s1)
    800029fa:	40f707bb          	subw	a5,a4,a5
    800029fe:	18f4a623          	sw	a5,396(s1)
				p->state = RUNNABLE;
    80002a02:	478d                	li	a5,3
    80002a04:	d09c                	sw	a5,32(s1)
				p->enter_time = ticks;
    80002a06:	1ae4a823          	sw	a4,432(s1)
				p->queue[p->curr_queue] = 0;
    80002a0a:	1a84a783          	lw	a5,424(s1)
    80002a0e:	06c78713          	addi	a4,a5,108
    80002a12:	070a                	slli	a4,a4,0x2
    80002a14:	9726                	add	a4,a4,s1
    80002a16:	00072623          	sw	zero,12(a4)
				p->in_queue = 1;
    80002a1a:	4705                	li	a4,1
    80002a1c:	1ae4aa23          	sw	a4,436(s1)
				int slices[5] = {1, 2, 4, 8, 16};
    80002a20:	fae42c23          	sw	a4,-72(s0)
    80002a24:	4709                	li	a4,2
    80002a26:	fae42e23          	sw	a4,-68(s0)
    80002a2a:	4711                	li	a4,4
    80002a2c:	fce42023          	sw	a4,-64(s0)
    80002a30:	4721                	li	a4,8
    80002a32:	fce42223          	sw	a4,-60(s0)
    80002a36:	4741                	li	a4,16
    80002a38:	fce42423          	sw	a4,-56(s0)
				p->time_slice = slices[p->curr_queue];
    80002a3c:	00279713          	slli	a4,a5,0x2
    80002a40:	fd040693          	addi	a3,s0,-48
    80002a44:	9736                	add	a4,a4,a3
    80002a46:	fe872703          	lw	a4,-24(a4)
    80002a4a:	1ae4ac23          	sw	a4,440(s1)
				push(&mlfq[p->curr_queue], p);
    80002a4e:	21800713          	li	a4,536
    80002a52:	02e787b3          	mul	a5,a5,a4
    80002a56:	85a6                	mv	a1,s1
    80002a58:	0000f517          	auipc	a0,0xf
    80002a5c:	82850513          	addi	a0,a0,-2008 # 80011280 <mlfq>
    80002a60:	953e                	add	a0,a0,a5
    80002a62:	fffff097          	auipc	ra,0xfffff
    80002a66:	f26080e7          	jalr	-218(ra) # 80001988 <push>
    80002a6a:	b7a5                	j	800029d2 <kill+0x58>

0000000080002a6c <setkilled>:

void setkilled(struct proc *p)
{
    80002a6c:	1101                	addi	sp,sp,-32
    80002a6e:	ec06                	sd	ra,24(sp)
    80002a70:	e822                	sd	s0,16(sp)
    80002a72:	e426                	sd	s1,8(sp)
    80002a74:	e04a                	sd	s2,0(sp)
    80002a76:	1000                	addi	s0,sp,32
    80002a78:	84aa                	mv	s1,a0
	acquire(&p->lock);
    80002a7a:	00850913          	addi	s2,a0,8
    80002a7e:	854a                	mv	a0,s2
    80002a80:	ffffe097          	auipc	ra,0xffffe
    80002a84:	16a080e7          	jalr	362(ra) # 80000bea <acquire>
	p->killed = 1;
    80002a88:	4785                	li	a5,1
    80002a8a:	d89c                	sw	a5,48(s1)
	release(&p->lock);
    80002a8c:	854a                	mv	a0,s2
    80002a8e:	ffffe097          	auipc	ra,0xffffe
    80002a92:	210080e7          	jalr	528(ra) # 80000c9e <release>
}
    80002a96:	60e2                	ld	ra,24(sp)
    80002a98:	6442                	ld	s0,16(sp)
    80002a9a:	64a2                	ld	s1,8(sp)
    80002a9c:	6902                	ld	s2,0(sp)
    80002a9e:	6105                	addi	sp,sp,32
    80002aa0:	8082                	ret

0000000080002aa2 <killed>:

int killed(struct proc *p)
{
    80002aa2:	1101                	addi	sp,sp,-32
    80002aa4:	ec06                	sd	ra,24(sp)
    80002aa6:	e822                	sd	s0,16(sp)
    80002aa8:	e426                	sd	s1,8(sp)
    80002aaa:	e04a                	sd	s2,0(sp)
    80002aac:	1000                	addi	s0,sp,32
    80002aae:	84aa                	mv	s1,a0
	int k;

	acquire(&p->lock);
    80002ab0:	00850913          	addi	s2,a0,8
    80002ab4:	854a                	mv	a0,s2
    80002ab6:	ffffe097          	auipc	ra,0xffffe
    80002aba:	134080e7          	jalr	308(ra) # 80000bea <acquire>
	k = p->killed;
    80002abe:	5884                	lw	s1,48(s1)
	release(&p->lock);
    80002ac0:	854a                	mv	a0,s2
    80002ac2:	ffffe097          	auipc	ra,0xffffe
    80002ac6:	1dc080e7          	jalr	476(ra) # 80000c9e <release>
	return k;
}
    80002aca:	8526                	mv	a0,s1
    80002acc:	60e2                	ld	ra,24(sp)
    80002ace:	6442                	ld	s0,16(sp)
    80002ad0:	64a2                	ld	s1,8(sp)
    80002ad2:	6902                	ld	s2,0(sp)
    80002ad4:	6105                	addi	sp,sp,32
    80002ad6:	8082                	ret

0000000080002ad8 <wait>:
{
    80002ad8:	711d                	addi	sp,sp,-96
    80002ada:	ec86                	sd	ra,88(sp)
    80002adc:	e8a2                	sd	s0,80(sp)
    80002ade:	e4a6                	sd	s1,72(sp)
    80002ae0:	e0ca                	sd	s2,64(sp)
    80002ae2:	fc4e                	sd	s3,56(sp)
    80002ae4:	f852                	sd	s4,48(sp)
    80002ae6:	f456                	sd	s5,40(sp)
    80002ae8:	f05a                	sd	s6,32(sp)
    80002aea:	ec5e                	sd	s7,24(sp)
    80002aec:	e862                	sd	s8,16(sp)
    80002aee:	e466                	sd	s9,8(sp)
    80002af0:	1080                	addi	s0,sp,96
    80002af2:	8baa                	mv	s7,a0
	struct proc *p = myproc();
    80002af4:	fffff097          	auipc	ra,0xfffff
    80002af8:	0f6080e7          	jalr	246(ra) # 80001bea <myproc>
    80002afc:	892a                	mv	s2,a0
	acquire(&wait_lock);
    80002afe:	0000e517          	auipc	a0,0xe
    80002b02:	36a50513          	addi	a0,a0,874 # 80010e68 <wait_lock>
    80002b06:	ffffe097          	auipc	ra,0xffffe
    80002b0a:	0e4080e7          	jalr	228(ra) # 80000bea <acquire>
		havekids = 0;
    80002b0e:	4c01                	li	s8,0
				if (pp->state == ZOMBIE)
    80002b10:	4a95                	li	s5,5
		for (pp = proc; pp < &proc[NPROC]; pp++)
    80002b12:	00016997          	auipc	s3,0x16
    80002b16:	5e698993          	addi	s3,s3,1510 # 800190f8 <tickslock>
				havekids = 1;
    80002b1a:	4b05                	li	s6,1
		sleep(p, &wait_lock); // DOC: wait-sleep
    80002b1c:	0000ec97          	auipc	s9,0xe
    80002b20:	34cc8c93          	addi	s9,s9,844 # 80010e68 <wait_lock>
		havekids = 0;
    80002b24:	8762                	mv	a4,s8
		for (pp = proc; pp < &proc[NPROC]; pp++)
    80002b26:	0000f497          	auipc	s1,0xf
    80002b2a:	1d248493          	addi	s1,s1,466 # 80011cf8 <proc>
    80002b2e:	a8ad                	j	80002ba8 <wait+0xd0>
					pid = pp->pid;
    80002b30:	0384a983          	lw	s3,56(s1)
					if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002b34:	000b8e63          	beqz	s7,80002b50 <wait+0x78>
    80002b38:	4691                	li	a3,4
    80002b3a:	03448613          	addi	a2,s1,52
    80002b3e:	85de                	mv	a1,s7
    80002b40:	05893503          	ld	a0,88(s2)
    80002b44:	fffff097          	auipc	ra,0xfffff
    80002b48:	b40080e7          	jalr	-1216(ra) # 80001684 <copyout>
    80002b4c:	02054b63          	bltz	a0,80002b82 <wait+0xaa>
					freeproc(pp);
    80002b50:	8526                	mv	a0,s1
    80002b52:	fffff097          	auipc	ra,0xfffff
    80002b56:	24c080e7          	jalr	588(ra) # 80001d9e <freeproc>
					release(&pp->lock);
    80002b5a:	8552                	mv	a0,s4
    80002b5c:	ffffe097          	auipc	ra,0xffffe
    80002b60:	142080e7          	jalr	322(ra) # 80000c9e <release>
					release(&wait_lock);
    80002b64:	0000e517          	auipc	a0,0xe
    80002b68:	30450513          	addi	a0,a0,772 # 80010e68 <wait_lock>
    80002b6c:	ffffe097          	auipc	ra,0xffffe
    80002b70:	132080e7          	jalr	306(ra) # 80000c9e <release>
					pp->endTime = ticks;
    80002b74:	00006797          	auipc	a5,0x6
    80002b78:	06c7a783          	lw	a5,108(a5) # 80008be0 <ticks>
    80002b7c:	18f4a223          	sw	a5,388(s1)
					return pid;
    80002b80:	a885                	j	80002bf0 <wait+0x118>
						release(&pp->lock);
    80002b82:	8552                	mv	a0,s4
    80002b84:	ffffe097          	auipc	ra,0xffffe
    80002b88:	11a080e7          	jalr	282(ra) # 80000c9e <release>
						release(&wait_lock);
    80002b8c:	0000e517          	auipc	a0,0xe
    80002b90:	2dc50513          	addi	a0,a0,732 # 80010e68 <wait_lock>
    80002b94:	ffffe097          	auipc	ra,0xffffe
    80002b98:	10a080e7          	jalr	266(ra) # 80000c9e <release>
						return -1;
    80002b9c:	59fd                	li	s3,-1
    80002b9e:	a889                	j	80002bf0 <wait+0x118>
		for (pp = proc; pp < &proc[NPROC]; pp++)
    80002ba0:	1d048493          	addi	s1,s1,464
    80002ba4:	03348663          	beq	s1,s3,80002bd0 <wait+0xf8>
			if (pp->parent == p)
    80002ba8:	60bc                	ld	a5,64(s1)
    80002baa:	ff279be3          	bne	a5,s2,80002ba0 <wait+0xc8>
				acquire(&pp->lock);
    80002bae:	00848a13          	addi	s4,s1,8
    80002bb2:	8552                	mv	a0,s4
    80002bb4:	ffffe097          	auipc	ra,0xffffe
    80002bb8:	036080e7          	jalr	54(ra) # 80000bea <acquire>
				if (pp->state == ZOMBIE)
    80002bbc:	509c                	lw	a5,32(s1)
    80002bbe:	f75789e3          	beq	a5,s5,80002b30 <wait+0x58>
				release(&pp->lock);
    80002bc2:	8552                	mv	a0,s4
    80002bc4:	ffffe097          	auipc	ra,0xffffe
    80002bc8:	0da080e7          	jalr	218(ra) # 80000c9e <release>
				havekids = 1;
    80002bcc:	875a                	mv	a4,s6
    80002bce:	bfc9                	j	80002ba0 <wait+0xc8>
		if (!havekids || killed(p))
    80002bd0:	c719                	beqz	a4,80002bde <wait+0x106>
    80002bd2:	854a                	mv	a0,s2
    80002bd4:	00000097          	auipc	ra,0x0
    80002bd8:	ece080e7          	jalr	-306(ra) # 80002aa2 <killed>
    80002bdc:	c905                	beqz	a0,80002c0c <wait+0x134>
			release(&wait_lock);
    80002bde:	0000e517          	auipc	a0,0xe
    80002be2:	28a50513          	addi	a0,a0,650 # 80010e68 <wait_lock>
    80002be6:	ffffe097          	auipc	ra,0xffffe
    80002bea:	0b8080e7          	jalr	184(ra) # 80000c9e <release>
			return -1;
    80002bee:	59fd                	li	s3,-1
}
    80002bf0:	854e                	mv	a0,s3
    80002bf2:	60e6                	ld	ra,88(sp)
    80002bf4:	6446                	ld	s0,80(sp)
    80002bf6:	64a6                	ld	s1,72(sp)
    80002bf8:	6906                	ld	s2,64(sp)
    80002bfa:	79e2                	ld	s3,56(sp)
    80002bfc:	7a42                	ld	s4,48(sp)
    80002bfe:	7aa2                	ld	s5,40(sp)
    80002c00:	7b02                	ld	s6,32(sp)
    80002c02:	6be2                	ld	s7,24(sp)
    80002c04:	6c42                	ld	s8,16(sp)
    80002c06:	6ca2                	ld	s9,8(sp)
    80002c08:	6125                	addi	sp,sp,96
    80002c0a:	8082                	ret
		sleep(p, &wait_lock); // DOC: wait-sleep
    80002c0c:	85e6                	mv	a1,s9
    80002c0e:	854a                	mv	a0,s2
    80002c10:	00000097          	auipc	ra,0x0
    80002c14:	930080e7          	jalr	-1744(ra) # 80002540 <sleep>
		havekids = 0;
    80002c18:	b731                	j	80002b24 <wait+0x4c>

0000000080002c1a <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002c1a:	7179                	addi	sp,sp,-48
    80002c1c:	f406                	sd	ra,40(sp)
    80002c1e:	f022                	sd	s0,32(sp)
    80002c20:	ec26                	sd	s1,24(sp)
    80002c22:	e84a                	sd	s2,16(sp)
    80002c24:	e44e                	sd	s3,8(sp)
    80002c26:	e052                	sd	s4,0(sp)
    80002c28:	1800                	addi	s0,sp,48
    80002c2a:	84aa                	mv	s1,a0
    80002c2c:	892e                	mv	s2,a1
    80002c2e:	89b2                	mv	s3,a2
    80002c30:	8a36                	mv	s4,a3
	struct proc *p = myproc();
    80002c32:	fffff097          	auipc	ra,0xfffff
    80002c36:	fb8080e7          	jalr	-72(ra) # 80001bea <myproc>
	if (user_dst)
    80002c3a:	c08d                	beqz	s1,80002c5c <either_copyout+0x42>
	{
		return copyout(p->pagetable, dst, src, len);
    80002c3c:	86d2                	mv	a3,s4
    80002c3e:	864e                	mv	a2,s3
    80002c40:	85ca                	mv	a1,s2
    80002c42:	6d28                	ld	a0,88(a0)
    80002c44:	fffff097          	auipc	ra,0xfffff
    80002c48:	a40080e7          	jalr	-1472(ra) # 80001684 <copyout>
	else
	{
		memmove((char *)dst, src, len);
		return 0;
	}
}
    80002c4c:	70a2                	ld	ra,40(sp)
    80002c4e:	7402                	ld	s0,32(sp)
    80002c50:	64e2                	ld	s1,24(sp)
    80002c52:	6942                	ld	s2,16(sp)
    80002c54:	69a2                	ld	s3,8(sp)
    80002c56:	6a02                	ld	s4,0(sp)
    80002c58:	6145                	addi	sp,sp,48
    80002c5a:	8082                	ret
		memmove((char *)dst, src, len);
    80002c5c:	000a061b          	sext.w	a2,s4
    80002c60:	85ce                	mv	a1,s3
    80002c62:	854a                	mv	a0,s2
    80002c64:	ffffe097          	auipc	ra,0xffffe
    80002c68:	0e2080e7          	jalr	226(ra) # 80000d46 <memmove>
		return 0;
    80002c6c:	8526                	mv	a0,s1
    80002c6e:	bff9                	j	80002c4c <either_copyout+0x32>

0000000080002c70 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002c70:	7179                	addi	sp,sp,-48
    80002c72:	f406                	sd	ra,40(sp)
    80002c74:	f022                	sd	s0,32(sp)
    80002c76:	ec26                	sd	s1,24(sp)
    80002c78:	e84a                	sd	s2,16(sp)
    80002c7a:	e44e                	sd	s3,8(sp)
    80002c7c:	e052                	sd	s4,0(sp)
    80002c7e:	1800                	addi	s0,sp,48
    80002c80:	892a                	mv	s2,a0
    80002c82:	84ae                	mv	s1,a1
    80002c84:	89b2                	mv	s3,a2
    80002c86:	8a36                	mv	s4,a3
	struct proc *p = myproc();
    80002c88:	fffff097          	auipc	ra,0xfffff
    80002c8c:	f62080e7          	jalr	-158(ra) # 80001bea <myproc>
	if (user_src)
    80002c90:	c08d                	beqz	s1,80002cb2 <either_copyin+0x42>
	{
		return copyin(p->pagetable, dst, src, len);
    80002c92:	86d2                	mv	a3,s4
    80002c94:	864e                	mv	a2,s3
    80002c96:	85ca                	mv	a1,s2
    80002c98:	6d28                	ld	a0,88(a0)
    80002c9a:	fffff097          	auipc	ra,0xfffff
    80002c9e:	a76080e7          	jalr	-1418(ra) # 80001710 <copyin>
	else
	{
		memmove(dst, (char *)src, len);
		return 0;
	}
}
    80002ca2:	70a2                	ld	ra,40(sp)
    80002ca4:	7402                	ld	s0,32(sp)
    80002ca6:	64e2                	ld	s1,24(sp)
    80002ca8:	6942                	ld	s2,16(sp)
    80002caa:	69a2                	ld	s3,8(sp)
    80002cac:	6a02                	ld	s4,0(sp)
    80002cae:	6145                	addi	sp,sp,48
    80002cb0:	8082                	ret
		memmove(dst, (char *)src, len);
    80002cb2:	000a061b          	sext.w	a2,s4
    80002cb6:	85ce                	mv	a1,s3
    80002cb8:	854a                	mv	a0,s2
    80002cba:	ffffe097          	auipc	ra,0xffffe
    80002cbe:	08c080e7          	jalr	140(ra) # 80000d46 <memmove>
		return 0;
    80002cc2:	8526                	mv	a0,s1
    80002cc4:	bff9                	j	80002ca2 <either_copyin+0x32>

0000000080002cc6 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002cc6:	715d                	addi	sp,sp,-80
    80002cc8:	e486                	sd	ra,72(sp)
    80002cca:	e0a2                	sd	s0,64(sp)
    80002ccc:	fc26                	sd	s1,56(sp)
    80002cce:	f84a                	sd	s2,48(sp)
    80002cd0:	f44e                	sd	s3,40(sp)
    80002cd2:	f052                	sd	s4,32(sp)
    80002cd4:	ec56                	sd	s5,24(sp)
    80002cd6:	e85a                	sd	s6,16(sp)
    80002cd8:	e45e                	sd	s7,8(sp)
    80002cda:	0880                	addi	s0,sp,80
		[RUNNING] "run   ",
		[ZOMBIE] "zombie"};
	struct proc *p;
	char *state;

	printf("\n");
    80002cdc:	00005517          	auipc	a0,0x5
    80002ce0:	5a450513          	addi	a0,a0,1444 # 80008280 <digits+0x240>
    80002ce4:	ffffe097          	auipc	ra,0xffffe
    80002ce8:	8aa080e7          	jalr	-1878(ra) # 8000058e <printf>
	for (p = proc; p < &proc[NPROC]; p++)
    80002cec:	0000f497          	auipc	s1,0xf
    80002cf0:	16c48493          	addi	s1,s1,364 # 80011e58 <proc+0x160>
    80002cf4:	00016917          	auipc	s2,0x16
    80002cf8:	56490913          	addi	s2,s2,1380 # 80019258 <bcache+0x148>
	{
		if (p->state == UNUSED)
			continue;
		if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002cfc:	4b15                	li	s6,5
			state = states[p->state];
		else
			state = "???";
    80002cfe:	00005997          	auipc	s3,0x5
    80002d02:	5aa98993          	addi	s3,s3,1450 # 800082a8 <digits+0x268>
		printf("%d %s %s %d %d", p->pid, state, p->name, p->runTime, p->countTimeCalled);
    80002d06:	00005a97          	auipc	s5,0x5
    80002d0a:	5aaa8a93          	addi	s5,s5,1450 # 800082b0 <digits+0x270>
		printf("\n");
    80002d0e:	00005a17          	auipc	s4,0x5
    80002d12:	572a0a13          	addi	s4,s4,1394 # 80008280 <digits+0x240>
		if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002d16:	00005b97          	auipc	s7,0x5
    80002d1a:	5dab8b93          	addi	s7,s7,1498 # 800082f0 <states.2559>
    80002d1e:	a01d                	j	80002d44 <procdump+0x7e>
		printf("%d %s %s %d %d", p->pid, state, p->name, p->runTime, p->countTimeCalled);
    80002d20:	5e9c                	lw	a5,56(a3)
    80002d22:	5298                	lw	a4,32(a3)
    80002d24:	ed86a583          	lw	a1,-296(a3)
    80002d28:	8556                	mv	a0,s5
    80002d2a:	ffffe097          	auipc	ra,0xffffe
    80002d2e:	864080e7          	jalr	-1948(ra) # 8000058e <printf>
		printf("\n");
    80002d32:	8552                	mv	a0,s4
    80002d34:	ffffe097          	auipc	ra,0xffffe
    80002d38:	85a080e7          	jalr	-1958(ra) # 8000058e <printf>
	for (p = proc; p < &proc[NPROC]; p++)
    80002d3c:	1d048493          	addi	s1,s1,464
    80002d40:	03248163          	beq	s1,s2,80002d62 <procdump+0x9c>
		if (p->state == UNUSED)
    80002d44:	86a6                	mv	a3,s1
    80002d46:	ec04a783          	lw	a5,-320(s1)
    80002d4a:	dbed                	beqz	a5,80002d3c <procdump+0x76>
			state = "???";
    80002d4c:	864e                	mv	a2,s3
		if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002d4e:	fcfb69e3          	bltu	s6,a5,80002d20 <procdump+0x5a>
    80002d52:	1782                	slli	a5,a5,0x20
    80002d54:	9381                	srli	a5,a5,0x20
    80002d56:	078e                	slli	a5,a5,0x3
    80002d58:	97de                	add	a5,a5,s7
    80002d5a:	6390                	ld	a2,0(a5)
    80002d5c:	f271                	bnez	a2,80002d20 <procdump+0x5a>
			state = "???";
    80002d5e:	864e                	mv	a2,s3
    80002d60:	b7c1                	j	80002d20 <procdump+0x5a>
	}
}
    80002d62:	60a6                	ld	ra,72(sp)
    80002d64:	6406                	ld	s0,64(sp)
    80002d66:	74e2                	ld	s1,56(sp)
    80002d68:	7942                	ld	s2,48(sp)
    80002d6a:	79a2                	ld	s3,40(sp)
    80002d6c:	7a02                	ld	s4,32(sp)
    80002d6e:	6ae2                	ld	s5,24(sp)
    80002d70:	6b42                	ld	s6,16(sp)
    80002d72:	6ba2                	ld	s7,8(sp)
    80002d74:	6161                	addi	sp,sp,80
    80002d76:	8082                	ret

0000000080002d78 <swtch>:
    80002d78:	00153023          	sd	ra,0(a0)
    80002d7c:	00253423          	sd	sp,8(a0)
    80002d80:	e900                	sd	s0,16(a0)
    80002d82:	ed04                	sd	s1,24(a0)
    80002d84:	03253023          	sd	s2,32(a0)
    80002d88:	03353423          	sd	s3,40(a0)
    80002d8c:	03453823          	sd	s4,48(a0)
    80002d90:	03553c23          	sd	s5,56(a0)
    80002d94:	05653023          	sd	s6,64(a0)
    80002d98:	05753423          	sd	s7,72(a0)
    80002d9c:	05853823          	sd	s8,80(a0)
    80002da0:	05953c23          	sd	s9,88(a0)
    80002da4:	07a53023          	sd	s10,96(a0)
    80002da8:	07b53423          	sd	s11,104(a0)
    80002dac:	0005b083          	ld	ra,0(a1)
    80002db0:	0085b103          	ld	sp,8(a1)
    80002db4:	6980                	ld	s0,16(a1)
    80002db6:	6d84                	ld	s1,24(a1)
    80002db8:	0205b903          	ld	s2,32(a1)
    80002dbc:	0285b983          	ld	s3,40(a1)
    80002dc0:	0305ba03          	ld	s4,48(a1)
    80002dc4:	0385ba83          	ld	s5,56(a1)
    80002dc8:	0405bb03          	ld	s6,64(a1)
    80002dcc:	0485bb83          	ld	s7,72(a1)
    80002dd0:	0505bc03          	ld	s8,80(a1)
    80002dd4:	0585bc83          	ld	s9,88(a1)
    80002dd8:	0605bd03          	ld	s10,96(a1)
    80002ddc:	0685bd83          	ld	s11,104(a1)
    80002de0:	8082                	ret

0000000080002de2 <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002de2:	1141                	addi	sp,sp,-16
    80002de4:	e406                	sd	ra,8(sp)
    80002de6:	e022                	sd	s0,0(sp)
    80002de8:	0800                	addi	s0,sp,16
	initlock(&tickslock, "time");
    80002dea:	00005597          	auipc	a1,0x5
    80002dee:	53658593          	addi	a1,a1,1334 # 80008320 <states.2559+0x30>
    80002df2:	00016517          	auipc	a0,0x16
    80002df6:	30650513          	addi	a0,a0,774 # 800190f8 <tickslock>
    80002dfa:	ffffe097          	auipc	ra,0xffffe
    80002dfe:	d60080e7          	jalr	-672(ra) # 80000b5a <initlock>
}
    80002e02:	60a2                	ld	ra,8(sp)
    80002e04:	6402                	ld	s0,0(sp)
    80002e06:	0141                	addi	sp,sp,16
    80002e08:	8082                	ret

0000000080002e0a <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002e0a:	1141                	addi	sp,sp,-16
    80002e0c:	e422                	sd	s0,8(sp)
    80002e0e:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002e10:	00003797          	auipc	a5,0x3
    80002e14:	77078793          	addi	a5,a5,1904 # 80006580 <kernelvec>
    80002e18:	10579073          	csrw	stvec,a5
	w_stvec((uint64)kernelvec);
}
    80002e1c:	6422                	ld	s0,8(sp)
    80002e1e:	0141                	addi	sp,sp,16
    80002e20:	8082                	ret

0000000080002e22 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80002e22:	1141                	addi	sp,sp,-16
    80002e24:	e406                	sd	ra,8(sp)
    80002e26:	e022                	sd	s0,0(sp)
    80002e28:	0800                	addi	s0,sp,16
	struct proc *p = myproc();
    80002e2a:	fffff097          	auipc	ra,0xfffff
    80002e2e:	dc0080e7          	jalr	-576(ra) # 80001bea <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e32:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002e36:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002e38:	10079073          	csrw	sstatus,a5
	// kerneltrap() to usertrap(), so turn off interrupts until
	// we're back in user space, where usertrap() is correct.
	intr_off();

	// send syscalls, interrupts, and exceptions to uservec in trampoline.S
	uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002e3c:	00004617          	auipc	a2,0x4
    80002e40:	1c460613          	addi	a2,a2,452 # 80007000 <_trampoline>
    80002e44:	00004697          	auipc	a3,0x4
    80002e48:	1bc68693          	addi	a3,a3,444 # 80007000 <_trampoline>
    80002e4c:	8e91                	sub	a3,a3,a2
    80002e4e:	040007b7          	lui	a5,0x4000
    80002e52:	17fd                	addi	a5,a5,-1
    80002e54:	07b2                	slli	a5,a5,0xc
    80002e56:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002e58:	10569073          	csrw	stvec,a3
	w_stvec(trampoline_uservec);

	// set up trapframe values that uservec will need when
	// the process next traps into the kernel.
	p->trapframe->kernel_satp = r_satp();		  // kernel page table
    80002e5c:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002e5e:	180026f3          	csrr	a3,satp
    80002e62:	e314                	sd	a3,0(a4)
	p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002e64:	7138                	ld	a4,96(a0)
    80002e66:	6534                	ld	a3,72(a0)
    80002e68:	6585                	lui	a1,0x1
    80002e6a:	96ae                	add	a3,a3,a1
    80002e6c:	e714                	sd	a3,8(a4)
	p->trapframe->kernel_trap = (uint64)usertrap;
    80002e6e:	7138                	ld	a4,96(a0)
    80002e70:	00000697          	auipc	a3,0x0
    80002e74:	13e68693          	addi	a3,a3,318 # 80002fae <usertrap>
    80002e78:	eb14                	sd	a3,16(a4)
	p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002e7a:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002e7c:	8692                	mv	a3,tp
    80002e7e:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e80:	100026f3          	csrr	a3,sstatus
	// set up the registers that trampoline.S's sret will use
	// to get to user space.

	// set S Previous Privilege mode to User.
	unsigned long x = r_sstatus();
	x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002e84:	eff6f693          	andi	a3,a3,-257
	x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002e88:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002e8c:	10069073          	csrw	sstatus,a3
	w_sstatus(x);

	// set S Exception Program Counter to the saved user pc.
	w_sepc(p->trapframe->epc);
    80002e90:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002e92:	6f18                	ld	a4,24(a4)
    80002e94:	14171073          	csrw	sepc,a4

	// tell trampoline.S the user page table to switch to.
	uint64 satp = MAKE_SATP(p->pagetable);
    80002e98:	6d28                	ld	a0,88(a0)
    80002e9a:	8131                	srli	a0,a0,0xc

	// jump to userret in trampoline.S at the top of memory, which
	// switches to the user page table, restores user registers,
	// and switches to user mode with sret.
	uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002e9c:	00004717          	auipc	a4,0x4
    80002ea0:	20070713          	addi	a4,a4,512 # 8000709c <userret>
    80002ea4:	8f11                	sub	a4,a4,a2
    80002ea6:	97ba                	add	a5,a5,a4
	((void (*)(uint64))trampoline_userret)(satp);
    80002ea8:	577d                	li	a4,-1
    80002eaa:	177e                	slli	a4,a4,0x3f
    80002eac:	8d59                	or	a0,a0,a4
    80002eae:	9782                	jalr	a5
}
    80002eb0:	60a2                	ld	ra,8(sp)
    80002eb2:	6402                	ld	s0,0(sp)
    80002eb4:	0141                	addi	sp,sp,16
    80002eb6:	8082                	ret

0000000080002eb8 <clockintr>:
	w_sepc(sepc);
	w_sstatus(sstatus);
}

void clockintr()
{
    80002eb8:	1101                	addi	sp,sp,-32
    80002eba:	ec06                	sd	ra,24(sp)
    80002ebc:	e822                	sd	s0,16(sp)
    80002ebe:	e426                	sd	s1,8(sp)
    80002ec0:	e04a                	sd	s2,0(sp)
    80002ec2:	1000                	addi	s0,sp,32
	acquire(&tickslock);
    80002ec4:	00016917          	auipc	s2,0x16
    80002ec8:	23490913          	addi	s2,s2,564 # 800190f8 <tickslock>
    80002ecc:	854a                	mv	a0,s2
    80002ece:	ffffe097          	auipc	ra,0xffffe
    80002ed2:	d1c080e7          	jalr	-740(ra) # 80000bea <acquire>
	ticks++;
    80002ed6:	00006497          	auipc	s1,0x6
    80002eda:	d0a48493          	addi	s1,s1,-758 # 80008be0 <ticks>
    80002ede:	409c                	lw	a5,0(s1)
    80002ee0:	2785                	addiw	a5,a5,1
    80002ee2:	c09c                	sw	a5,0(s1)
	upd_time();
    80002ee4:	fffff097          	auipc	ra,0xfffff
    80002ee8:	28c080e7          	jalr	652(ra) # 80002170 <upd_time>
	wakeup(&ticks);
    80002eec:	8526                	mv	a0,s1
    80002eee:	00000097          	auipc	ra,0x0
    80002ef2:	830080e7          	jalr	-2000(ra) # 8000271e <wakeup>
	release(&tickslock);
    80002ef6:	854a                	mv	a0,s2
    80002ef8:	ffffe097          	auipc	ra,0xffffe
    80002efc:	da6080e7          	jalr	-602(ra) # 80000c9e <release>
}
    80002f00:	60e2                	ld	ra,24(sp)
    80002f02:	6442                	ld	s0,16(sp)
    80002f04:	64a2                	ld	s1,8(sp)
    80002f06:	6902                	ld	s2,0(sp)
    80002f08:	6105                	addi	sp,sp,32
    80002f0a:	8082                	ret

0000000080002f0c <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    80002f0c:	1101                	addi	sp,sp,-32
    80002f0e:	ec06                	sd	ra,24(sp)
    80002f10:	e822                	sd	s0,16(sp)
    80002f12:	e426                	sd	s1,8(sp)
    80002f14:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f16:	14202773          	csrr	a4,scause
	uint64 scause = r_scause();

	if ((scause & 0x8000000000000000L) &&
    80002f1a:	00074d63          	bltz	a4,80002f34 <devintr+0x28>
		if (irq)
			plic_complete(irq);

		return 1;
	}
	else if (scause == 0x8000000000000001L)
    80002f1e:	57fd                	li	a5,-1
    80002f20:	17fe                	slli	a5,a5,0x3f
    80002f22:	0785                	addi	a5,a5,1

		return 2;
	}
	else
	{
		return 0;
    80002f24:	4501                	li	a0,0
	else if (scause == 0x8000000000000001L)
    80002f26:	06f70363          	beq	a4,a5,80002f8c <devintr+0x80>
	}
}
    80002f2a:	60e2                	ld	ra,24(sp)
    80002f2c:	6442                	ld	s0,16(sp)
    80002f2e:	64a2                	ld	s1,8(sp)
    80002f30:	6105                	addi	sp,sp,32
    80002f32:	8082                	ret
		(scause & 0xff) == 9)
    80002f34:	0ff77793          	andi	a5,a4,255
	if ((scause & 0x8000000000000000L) &&
    80002f38:	46a5                	li	a3,9
    80002f3a:	fed792e3          	bne	a5,a3,80002f1e <devintr+0x12>
		int irq = plic_claim();
    80002f3e:	00003097          	auipc	ra,0x3
    80002f42:	74a080e7          	jalr	1866(ra) # 80006688 <plic_claim>
    80002f46:	84aa                	mv	s1,a0
		if (irq == UART0_IRQ)
    80002f48:	47a9                	li	a5,10
    80002f4a:	02f50763          	beq	a0,a5,80002f78 <devintr+0x6c>
		else if (irq == VIRTIO0_IRQ)
    80002f4e:	4785                	li	a5,1
    80002f50:	02f50963          	beq	a0,a5,80002f82 <devintr+0x76>
		return 1;
    80002f54:	4505                	li	a0,1
		else if (irq)
    80002f56:	d8f1                	beqz	s1,80002f2a <devintr+0x1e>
			printf("unexpected interrupt irq=%d\n", irq);
    80002f58:	85a6                	mv	a1,s1
    80002f5a:	00005517          	auipc	a0,0x5
    80002f5e:	3ce50513          	addi	a0,a0,974 # 80008328 <states.2559+0x38>
    80002f62:	ffffd097          	auipc	ra,0xffffd
    80002f66:	62c080e7          	jalr	1580(ra) # 8000058e <printf>
			plic_complete(irq);
    80002f6a:	8526                	mv	a0,s1
    80002f6c:	00003097          	auipc	ra,0x3
    80002f70:	740080e7          	jalr	1856(ra) # 800066ac <plic_complete>
		return 1;
    80002f74:	4505                	li	a0,1
    80002f76:	bf55                	j	80002f2a <devintr+0x1e>
			uartintr();
    80002f78:	ffffe097          	auipc	ra,0xffffe
    80002f7c:	a36080e7          	jalr	-1482(ra) # 800009ae <uartintr>
    80002f80:	b7ed                	j	80002f6a <devintr+0x5e>
			virtio_disk_intr();
    80002f82:	00004097          	auipc	ra,0x4
    80002f86:	c54080e7          	jalr	-940(ra) # 80006bd6 <virtio_disk_intr>
    80002f8a:	b7c5                	j	80002f6a <devintr+0x5e>
		if (cpuid() == 0)
    80002f8c:	fffff097          	auipc	ra,0xfffff
    80002f90:	c32080e7          	jalr	-974(ra) # 80001bbe <cpuid>
    80002f94:	c901                	beqz	a0,80002fa4 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002f96:	144027f3          	csrr	a5,sip
		w_sip(r_sip() & ~2);
    80002f9a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002f9c:	14479073          	csrw	sip,a5
		return 2;
    80002fa0:	4509                	li	a0,2
    80002fa2:	b761                	j	80002f2a <devintr+0x1e>
			clockintr();
    80002fa4:	00000097          	auipc	ra,0x0
    80002fa8:	f14080e7          	jalr	-236(ra) # 80002eb8 <clockintr>
    80002fac:	b7ed                	j	80002f96 <devintr+0x8a>

0000000080002fae <usertrap>:
{
    80002fae:	1101                	addi	sp,sp,-32
    80002fb0:	ec06                	sd	ra,24(sp)
    80002fb2:	e822                	sd	s0,16(sp)
    80002fb4:	e426                	sd	s1,8(sp)
    80002fb6:	e04a                	sd	s2,0(sp)
    80002fb8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002fba:	100027f3          	csrr	a5,sstatus
	if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002fbe:	1007f793          	andi	a5,a5,256
    80002fc2:	e3b1                	bnez	a5,80003006 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002fc4:	00003797          	auipc	a5,0x3
    80002fc8:	5bc78793          	addi	a5,a5,1468 # 80006580 <kernelvec>
    80002fcc:	10579073          	csrw	stvec,a5
	struct proc *p = myproc();
    80002fd0:	fffff097          	auipc	ra,0xfffff
    80002fd4:	c1a080e7          	jalr	-998(ra) # 80001bea <myproc>
    80002fd8:	84aa                	mv	s1,a0
	p->trapframe->epc = r_sepc();
    80002fda:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002fdc:	14102773          	csrr	a4,sepc
    80002fe0:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002fe2:	14202773          	csrr	a4,scause
	if (r_scause() == 8)
    80002fe6:	47a1                	li	a5,8
    80002fe8:	02f70763          	beq	a4,a5,80003016 <usertrap+0x68>
	else if ((which_dev = devintr()) != 0)
    80002fec:	00000097          	auipc	ra,0x0
    80002ff0:	f20080e7          	jalr	-224(ra) # 80002f0c <devintr>
    80002ff4:	892a                	mv	s2,a0
    80002ff6:	c151                	beqz	a0,8000307a <usertrap+0xcc>
	if (killed(p))
    80002ff8:	8526                	mv	a0,s1
    80002ffa:	00000097          	auipc	ra,0x0
    80002ffe:	aa8080e7          	jalr	-1368(ra) # 80002aa2 <killed>
    80003002:	c929                	beqz	a0,80003054 <usertrap+0xa6>
    80003004:	a099                	j	8000304a <usertrap+0x9c>
		panic("usertrap: not from user mode");
    80003006:	00005517          	auipc	a0,0x5
    8000300a:	34250513          	addi	a0,a0,834 # 80008348 <states.2559+0x58>
    8000300e:	ffffd097          	auipc	ra,0xffffd
    80003012:	536080e7          	jalr	1334(ra) # 80000544 <panic>
		if (killed(p))
    80003016:	00000097          	auipc	ra,0x0
    8000301a:	a8c080e7          	jalr	-1396(ra) # 80002aa2 <killed>
    8000301e:	e921                	bnez	a0,8000306e <usertrap+0xc0>
		p->trapframe->epc += 4;
    80003020:	70b8                	ld	a4,96(s1)
    80003022:	6f1c                	ld	a5,24(a4)
    80003024:	0791                	addi	a5,a5,4
    80003026:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003028:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000302c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003030:	10079073          	csrw	sstatus,a5
		syscall();
    80003034:	00000097          	auipc	ra,0x0
    80003038:	2d4080e7          	jalr	724(ra) # 80003308 <syscall>
	if (killed(p))
    8000303c:	8526                	mv	a0,s1
    8000303e:	00000097          	auipc	ra,0x0
    80003042:	a64080e7          	jalr	-1436(ra) # 80002aa2 <killed>
    80003046:	c911                	beqz	a0,8000305a <usertrap+0xac>
    80003048:	4901                	li	s2,0
		exit(-1);
    8000304a:	557d                	li	a0,-1
    8000304c:	00000097          	auipc	ra,0x0
    80003050:	84a080e7          	jalr	-1974(ra) # 80002896 <exit>
	if (which_dev == 2)
    80003054:	4789                	li	a5,2
    80003056:	04f90f63          	beq	s2,a5,800030b4 <usertrap+0x106>
	usertrapret();
    8000305a:	00000097          	auipc	ra,0x0
    8000305e:	dc8080e7          	jalr	-568(ra) # 80002e22 <usertrapret>
}
    80003062:	60e2                	ld	ra,24(sp)
    80003064:	6442                	ld	s0,16(sp)
    80003066:	64a2                	ld	s1,8(sp)
    80003068:	6902                	ld	s2,0(sp)
    8000306a:	6105                	addi	sp,sp,32
    8000306c:	8082                	ret
			exit(-1);
    8000306e:	557d                	li	a0,-1
    80003070:	00000097          	auipc	ra,0x0
    80003074:	826080e7          	jalr	-2010(ra) # 80002896 <exit>
    80003078:	b765                	j	80003020 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000307a:	142025f3          	csrr	a1,scause
		printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    8000307e:	5c90                	lw	a2,56(s1)
    80003080:	00005517          	auipc	a0,0x5
    80003084:	2e850513          	addi	a0,a0,744 # 80008368 <states.2559+0x78>
    80003088:	ffffd097          	auipc	ra,0xffffd
    8000308c:	506080e7          	jalr	1286(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003090:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003094:	14302673          	csrr	a2,stval
		printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003098:	00005517          	auipc	a0,0x5
    8000309c:	30050513          	addi	a0,a0,768 # 80008398 <states.2559+0xa8>
    800030a0:	ffffd097          	auipc	ra,0xffffd
    800030a4:	4ee080e7          	jalr	1262(ra) # 8000058e <printf>
		setkilled(p);
    800030a8:	8526                	mv	a0,s1
    800030aa:	00000097          	auipc	ra,0x0
    800030ae:	9c2080e7          	jalr	-1598(ra) # 80002a6c <setkilled>
    800030b2:	b769                	j	8000303c <usertrap+0x8e>
		yield();
    800030b4:	fffff097          	auipc	ra,0xfffff
    800030b8:	446080e7          	jalr	1094(ra) # 800024fa <yield>
    800030bc:	bf79                	j	8000305a <usertrap+0xac>

00000000800030be <kerneltrap>:
{
    800030be:	7179                	addi	sp,sp,-48
    800030c0:	f406                	sd	ra,40(sp)
    800030c2:	f022                	sd	s0,32(sp)
    800030c4:	ec26                	sd	s1,24(sp)
    800030c6:	e84a                	sd	s2,16(sp)
    800030c8:	e44e                	sd	s3,8(sp)
    800030ca:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800030cc:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800030d0:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800030d4:	142029f3          	csrr	s3,scause
	if ((sstatus & SSTATUS_SPP) == 0)
    800030d8:	1004f793          	andi	a5,s1,256
    800030dc:	cb85                	beqz	a5,8000310c <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800030de:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800030e2:	8b89                	andi	a5,a5,2
	if (intr_get() != 0)
    800030e4:	ef85                	bnez	a5,8000311c <kerneltrap+0x5e>
	if ((which_dev = devintr()) == 0)
    800030e6:	00000097          	auipc	ra,0x0
    800030ea:	e26080e7          	jalr	-474(ra) # 80002f0c <devintr>
    800030ee:	cd1d                	beqz	a0,8000312c <kerneltrap+0x6e>
	if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800030f0:	4789                	li	a5,2
    800030f2:	06f50a63          	beq	a0,a5,80003166 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800030f6:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800030fa:	10049073          	csrw	sstatus,s1
}
    800030fe:	70a2                	ld	ra,40(sp)
    80003100:	7402                	ld	s0,32(sp)
    80003102:	64e2                	ld	s1,24(sp)
    80003104:	6942                	ld	s2,16(sp)
    80003106:	69a2                	ld	s3,8(sp)
    80003108:	6145                	addi	sp,sp,48
    8000310a:	8082                	ret
		panic("kerneltrap: not from supervisor mode");
    8000310c:	00005517          	auipc	a0,0x5
    80003110:	2ac50513          	addi	a0,a0,684 # 800083b8 <states.2559+0xc8>
    80003114:	ffffd097          	auipc	ra,0xffffd
    80003118:	430080e7          	jalr	1072(ra) # 80000544 <panic>
		panic("kerneltrap: interrupts enabled");
    8000311c:	00005517          	auipc	a0,0x5
    80003120:	2c450513          	addi	a0,a0,708 # 800083e0 <states.2559+0xf0>
    80003124:	ffffd097          	auipc	ra,0xffffd
    80003128:	420080e7          	jalr	1056(ra) # 80000544 <panic>
		printf("scause %p\n", scause);
    8000312c:	85ce                	mv	a1,s3
    8000312e:	00005517          	auipc	a0,0x5
    80003132:	2d250513          	addi	a0,a0,722 # 80008400 <states.2559+0x110>
    80003136:	ffffd097          	auipc	ra,0xffffd
    8000313a:	458080e7          	jalr	1112(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000313e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003142:	14302673          	csrr	a2,stval
		printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003146:	00005517          	auipc	a0,0x5
    8000314a:	2ca50513          	addi	a0,a0,714 # 80008410 <states.2559+0x120>
    8000314e:	ffffd097          	auipc	ra,0xffffd
    80003152:	440080e7          	jalr	1088(ra) # 8000058e <printf>
		panic("kerneltrap");
    80003156:	00005517          	auipc	a0,0x5
    8000315a:	2d250513          	addi	a0,a0,722 # 80008428 <states.2559+0x138>
    8000315e:	ffffd097          	auipc	ra,0xffffd
    80003162:	3e6080e7          	jalr	998(ra) # 80000544 <panic>
	if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003166:	fffff097          	auipc	ra,0xfffff
    8000316a:	a84080e7          	jalr	-1404(ra) # 80001bea <myproc>
    8000316e:	d541                	beqz	a0,800030f6 <kerneltrap+0x38>
    80003170:	fffff097          	auipc	ra,0xfffff
    80003174:	a7a080e7          	jalr	-1414(ra) # 80001bea <myproc>
    80003178:	5118                	lw	a4,32(a0)
    8000317a:	4791                	li	a5,4
    8000317c:	f6f71de3          	bne	a4,a5,800030f6 <kerneltrap+0x38>
		yield();
    80003180:	fffff097          	auipc	ra,0xfffff
    80003184:	37a080e7          	jalr	890(ra) # 800024fa <yield>
    80003188:	b7bd                	j	800030f6 <kerneltrap+0x38>

000000008000318a <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000318a:	1101                	addi	sp,sp,-32
    8000318c:	ec06                	sd	ra,24(sp)
    8000318e:	e822                	sd	s0,16(sp)
    80003190:	e426                	sd	s1,8(sp)
    80003192:	1000                	addi	s0,sp,32
    80003194:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80003196:	fffff097          	auipc	ra,0xfffff
    8000319a:	a54080e7          	jalr	-1452(ra) # 80001bea <myproc>
  switch (n)
    8000319e:	4795                	li	a5,5
    800031a0:	0497e163          	bltu	a5,s1,800031e2 <argraw+0x58>
    800031a4:	048a                	slli	s1,s1,0x2
    800031a6:	00005717          	auipc	a4,0x5
    800031aa:	3ca70713          	addi	a4,a4,970 # 80008570 <states.2559+0x280>
    800031ae:	94ba                	add	s1,s1,a4
    800031b0:	409c                	lw	a5,0(s1)
    800031b2:	97ba                	add	a5,a5,a4
    800031b4:	8782                	jr	a5
  {
  case 0:
    return p->trapframe->a0;
    800031b6:	713c                	ld	a5,96(a0)
    800031b8:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800031ba:	60e2                	ld	ra,24(sp)
    800031bc:	6442                	ld	s0,16(sp)
    800031be:	64a2                	ld	s1,8(sp)
    800031c0:	6105                	addi	sp,sp,32
    800031c2:	8082                	ret
    return p->trapframe->a1;
    800031c4:	713c                	ld	a5,96(a0)
    800031c6:	7fa8                	ld	a0,120(a5)
    800031c8:	bfcd                	j	800031ba <argraw+0x30>
    return p->trapframe->a2;
    800031ca:	713c                	ld	a5,96(a0)
    800031cc:	63c8                	ld	a0,128(a5)
    800031ce:	b7f5                	j	800031ba <argraw+0x30>
    return p->trapframe->a3;
    800031d0:	713c                	ld	a5,96(a0)
    800031d2:	67c8                	ld	a0,136(a5)
    800031d4:	b7dd                	j	800031ba <argraw+0x30>
    return p->trapframe->a4;
    800031d6:	713c                	ld	a5,96(a0)
    800031d8:	6bc8                	ld	a0,144(a5)
    800031da:	b7c5                	j	800031ba <argraw+0x30>
    return p->trapframe->a5;
    800031dc:	713c                	ld	a5,96(a0)
    800031de:	6fc8                	ld	a0,152(a5)
    800031e0:	bfe9                	j	800031ba <argraw+0x30>
  panic("argraw");
    800031e2:	00005517          	auipc	a0,0x5
    800031e6:	25650513          	addi	a0,a0,598 # 80008438 <states.2559+0x148>
    800031ea:	ffffd097          	auipc	ra,0xffffd
    800031ee:	35a080e7          	jalr	858(ra) # 80000544 <panic>

00000000800031f2 <fetchaddr>:
{
    800031f2:	1101                	addi	sp,sp,-32
    800031f4:	ec06                	sd	ra,24(sp)
    800031f6:	e822                	sd	s0,16(sp)
    800031f8:	e426                	sd	s1,8(sp)
    800031fa:	e04a                	sd	s2,0(sp)
    800031fc:	1000                	addi	s0,sp,32
    800031fe:	84aa                	mv	s1,a0
    80003200:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003202:	fffff097          	auipc	ra,0xfffff
    80003206:	9e8080e7          	jalr	-1560(ra) # 80001bea <myproc>
  if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    8000320a:	693c                	ld	a5,80(a0)
    8000320c:	02f4f863          	bgeu	s1,a5,8000323c <fetchaddr+0x4a>
    80003210:	00848713          	addi	a4,s1,8
    80003214:	02e7e663          	bltu	a5,a4,80003240 <fetchaddr+0x4e>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003218:	46a1                	li	a3,8
    8000321a:	8626                	mv	a2,s1
    8000321c:	85ca                	mv	a1,s2
    8000321e:	6d28                	ld	a0,88(a0)
    80003220:	ffffe097          	auipc	ra,0xffffe
    80003224:	4f0080e7          	jalr	1264(ra) # 80001710 <copyin>
    80003228:	00a03533          	snez	a0,a0
    8000322c:	40a00533          	neg	a0,a0
}
    80003230:	60e2                	ld	ra,24(sp)
    80003232:	6442                	ld	s0,16(sp)
    80003234:	64a2                	ld	s1,8(sp)
    80003236:	6902                	ld	s2,0(sp)
    80003238:	6105                	addi	sp,sp,32
    8000323a:	8082                	ret
    return -1;
    8000323c:	557d                	li	a0,-1
    8000323e:	bfcd                	j	80003230 <fetchaddr+0x3e>
    80003240:	557d                	li	a0,-1
    80003242:	b7fd                	j	80003230 <fetchaddr+0x3e>

0000000080003244 <fetchstr>:
{
    80003244:	7179                	addi	sp,sp,-48
    80003246:	f406                	sd	ra,40(sp)
    80003248:	f022                	sd	s0,32(sp)
    8000324a:	ec26                	sd	s1,24(sp)
    8000324c:	e84a                	sd	s2,16(sp)
    8000324e:	e44e                	sd	s3,8(sp)
    80003250:	1800                	addi	s0,sp,48
    80003252:	892a                	mv	s2,a0
    80003254:	84ae                	mv	s1,a1
    80003256:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80003258:	fffff097          	auipc	ra,0xfffff
    8000325c:	992080e7          	jalr	-1646(ra) # 80001bea <myproc>
  if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80003260:	86ce                	mv	a3,s3
    80003262:	864a                	mv	a2,s2
    80003264:	85a6                	mv	a1,s1
    80003266:	6d28                	ld	a0,88(a0)
    80003268:	ffffe097          	auipc	ra,0xffffe
    8000326c:	534080e7          	jalr	1332(ra) # 8000179c <copyinstr>
    80003270:	00054e63          	bltz	a0,8000328c <fetchstr+0x48>
  return strlen(buf);
    80003274:	8526                	mv	a0,s1
    80003276:	ffffe097          	auipc	ra,0xffffe
    8000327a:	bf4080e7          	jalr	-1036(ra) # 80000e6a <strlen>
}
    8000327e:	70a2                	ld	ra,40(sp)
    80003280:	7402                	ld	s0,32(sp)
    80003282:	64e2                	ld	s1,24(sp)
    80003284:	6942                	ld	s2,16(sp)
    80003286:	69a2                	ld	s3,8(sp)
    80003288:	6145                	addi	sp,sp,48
    8000328a:	8082                	ret
    return -1;
    8000328c:	557d                	li	a0,-1
    8000328e:	bfc5                	j	8000327e <fetchstr+0x3a>

0000000080003290 <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80003290:	1101                	addi	sp,sp,-32
    80003292:	ec06                	sd	ra,24(sp)
    80003294:	e822                	sd	s0,16(sp)
    80003296:	e426                	sd	s1,8(sp)
    80003298:	1000                	addi	s0,sp,32
    8000329a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000329c:	00000097          	auipc	ra,0x0
    800032a0:	eee080e7          	jalr	-274(ra) # 8000318a <argraw>
    800032a4:	c088                	sw	a0,0(s1)
}
    800032a6:	60e2                	ld	ra,24(sp)
    800032a8:	6442                	ld	s0,16(sp)
    800032aa:	64a2                	ld	s1,8(sp)
    800032ac:	6105                	addi	sp,sp,32
    800032ae:	8082                	ret

00000000800032b0 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    800032b0:	1101                	addi	sp,sp,-32
    800032b2:	ec06                	sd	ra,24(sp)
    800032b4:	e822                	sd	s0,16(sp)
    800032b6:	e426                	sd	s1,8(sp)
    800032b8:	1000                	addi	s0,sp,32
    800032ba:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800032bc:	00000097          	auipc	ra,0x0
    800032c0:	ece080e7          	jalr	-306(ra) # 8000318a <argraw>
    800032c4:	e088                	sd	a0,0(s1)
}
    800032c6:	60e2                	ld	ra,24(sp)
    800032c8:	6442                	ld	s0,16(sp)
    800032ca:	64a2                	ld	s1,8(sp)
    800032cc:	6105                	addi	sp,sp,32
    800032ce:	8082                	ret

00000000800032d0 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    800032d0:	7179                	addi	sp,sp,-48
    800032d2:	f406                	sd	ra,40(sp)
    800032d4:	f022                	sd	s0,32(sp)
    800032d6:	ec26                	sd	s1,24(sp)
    800032d8:	e84a                	sd	s2,16(sp)
    800032da:	1800                	addi	s0,sp,48
    800032dc:	84ae                	mv	s1,a1
    800032de:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    800032e0:	fd840593          	addi	a1,s0,-40
    800032e4:	00000097          	auipc	ra,0x0
    800032e8:	fcc080e7          	jalr	-52(ra) # 800032b0 <argaddr>
  return fetchstr(addr, buf, max);
    800032ec:	864a                	mv	a2,s2
    800032ee:	85a6                	mv	a1,s1
    800032f0:	fd843503          	ld	a0,-40(s0)
    800032f4:	00000097          	auipc	ra,0x0
    800032f8:	f50080e7          	jalr	-176(ra) # 80003244 <fetchstr>
}
    800032fc:	70a2                	ld	ra,40(sp)
    800032fe:	7402                	ld	s0,32(sp)
    80003300:	64e2                	ld	s1,24(sp)
    80003302:	6942                	ld	s2,16(sp)
    80003304:	6145                	addi	sp,sp,48
    80003306:	8082                	ret

0000000080003308 <syscall>:
    {"settickets", 1},
    {"waitx",3}
};

void syscall(void)
{
    80003308:	711d                	addi	sp,sp,-96
    8000330a:	ec86                	sd	ra,88(sp)
    8000330c:	e8a2                	sd	s0,80(sp)
    8000330e:	e4a6                	sd	s1,72(sp)
    80003310:	e0ca                	sd	s2,64(sp)
    80003312:	fc4e                	sd	s3,56(sp)
    80003314:	f852                	sd	s4,48(sp)
    80003316:	f456                	sd	s5,40(sp)
    80003318:	f05a                	sd	s6,32(sp)
    8000331a:	ec5e                	sd	s7,24(sp)
    8000331c:	e862                	sd	s8,16(sp)
    8000331e:	e466                	sd	s9,8(sp)
    80003320:	e06a                	sd	s10,0(sp)
    80003322:	1080                	addi	s0,sp,96
  int num;
  struct proc *p = myproc();
    80003324:	fffff097          	auipc	ra,0xfffff
    80003328:	8c6080e7          	jalr	-1850(ra) # 80001bea <myproc>
    8000332c:	8a2a                	mv	s4,a0

  num = p->trapframe->a7; // return reg
    8000332e:	7124                	ld	s1,96(a0)
    80003330:	74dc                	ld	a5,168(s1)
    80003332:	00078b1b          	sext.w	s6,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    80003336:	37fd                	addiw	a5,a5,-1
    80003338:	4765                	li	a4,25
    8000333a:	06f76f63          	bltu	a4,a5,800033b8 <syscall+0xb0>
    8000333e:	003b1713          	slli	a4,s6,0x3
    80003342:	00005797          	auipc	a5,0x5
    80003346:	24678793          	addi	a5,a5,582 # 80008588 <syscalls>
    8000334a:	97ba                	add	a5,a5,a4
    8000334c:	0007bd03          	ld	s10,0(a5)
    80003350:	060d0463          	beqz	s10,800033b8 <syscall+0xb0>
  {
    80003354:	8c8a                	mv	s9,sp
    int numargs = syscall_info[num - 1].num;
    80003356:	fffb0c1b          	addiw	s8,s6,-1
    8000335a:	004c1713          	slli	a4,s8,0x4
    8000335e:	00005797          	auipc	a5,0x5
    80003362:	68a78793          	addi	a5,a5,1674 # 800089e8 <syscall_info>
    80003366:	97ba                	add	a5,a5,a4
    80003368:	0087a983          	lw	s3,8(a5)
    int Args[numargs]; // to store value of registers acc to the number of args of the syscall
    8000336c:	00299793          	slli	a5,s3,0x2
    80003370:	07bd                	addi	a5,a5,15
    80003372:	9bc1                	andi	a5,a5,-16
    80003374:	40f10133          	sub	sp,sp,a5
    80003378:	8b8a                	mv	s7,sp
    int j = 0;
    while (j < numargs)
    8000337a:	11305363          	blez	s3,80003480 <syscall+0x178>
    8000337e:	8ade                	mv	s5,s7
    80003380:	895e                	mv	s2,s7
    int j = 0;
    80003382:	4481                	li	s1,0
    {
      Args[j] = argraw(j);
    80003384:	8526                	mv	a0,s1
    80003386:	00000097          	auipc	ra,0x0
    8000338a:	e04080e7          	jalr	-508(ra) # 8000318a <argraw>
    8000338e:	00a92023          	sw	a0,0(s2)
      j++;
    80003392:	2485                	addiw	s1,s1,1
    while (j < numargs)
    80003394:	0911                	addi	s2,s2,4
    80003396:	fe9997e3          	bne	s3,s1,80003384 <syscall+0x7c>
    }

    int shift = 1 << num; // mask for num
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    8000339a:	060a3483          	ld	s1,96(s4)
    8000339e:	9d02                	jalr	s10
    800033a0:	f8a8                	sd	a0,112(s1)
    int shift = 1 << num; // mask for num
    800033a2:	4785                	li	a5,1
    800033a4:	016797bb          	sllw	a5,a5,s6

    if (p->mask & shift)
    800033a8:	000a2b03          	lw	s6,0(s4)
    800033ac:	0167f7b3          	and	a5,a5,s6
    800033b0:	2781                	sext.w	a5,a5
    800033b2:	e7a1                	bnez	a5,800033fa <syscall+0xf2>
    800033b4:	8166                	mv	sp,s9
  {
    800033b6:	a015                	j	800033da <syscall+0xd2>
      printf(" -> %d\n", p->trapframe->a0);
    }
  }
  else
  {
    printf("%d %s: unknown sys call %d\n",
    800033b8:	86da                	mv	a3,s6
    800033ba:	160a0613          	addi	a2,s4,352
    800033be:	038a2583          	lw	a1,56(s4)
    800033c2:	00005517          	auipc	a0,0x5
    800033c6:	09650513          	addi	a0,a0,150 # 80008458 <states.2559+0x168>
    800033ca:	ffffd097          	auipc	ra,0xffffd
    800033ce:	1c4080e7          	jalr	452(ra) # 8000058e <printf>
           p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800033d2:	060a3783          	ld	a5,96(s4)
    800033d6:	577d                	li	a4,-1
    800033d8:	fbb8                	sd	a4,112(a5)
  }
}
    800033da:	fa040113          	addi	sp,s0,-96
    800033de:	60e6                	ld	ra,88(sp)
    800033e0:	6446                	ld	s0,80(sp)
    800033e2:	64a6                	ld	s1,72(sp)
    800033e4:	6906                	ld	s2,64(sp)
    800033e6:	79e2                	ld	s3,56(sp)
    800033e8:	7a42                	ld	s4,48(sp)
    800033ea:	7aa2                	ld	s5,40(sp)
    800033ec:	7b02                	ld	s6,32(sp)
    800033ee:	6be2                	ld	s7,24(sp)
    800033f0:	6c42                	ld	s8,16(sp)
    800033f2:	6ca2                	ld	s9,8(sp)
    800033f4:	6d02                	ld	s10,0(sp)
    800033f6:	6125                	addi	sp,sp,96
    800033f8:	8082                	ret
      printf("%d: syscall %s ", p->pid, syscall_info[num - 1].name);
    800033fa:	0c12                	slli	s8,s8,0x4
    800033fc:	00005797          	auipc	a5,0x5
    80003400:	5ec78793          	addi	a5,a5,1516 # 800089e8 <syscall_info>
    80003404:	9c3e                	add	s8,s8,a5
    80003406:	000c3603          	ld	a2,0(s8)
    8000340a:	038a2583          	lw	a1,56(s4)
    8000340e:	00005517          	auipc	a0,0x5
    80003412:	06a50513          	addi	a0,a0,106 # 80008478 <states.2559+0x188>
    80003416:	ffffd097          	auipc	ra,0xffffd
    8000341a:	178080e7          	jalr	376(ra) # 8000058e <printf>
      printf("(");
    8000341e:	00005517          	auipc	a0,0x5
    80003422:	06a50513          	addi	a0,a0,106 # 80008488 <states.2559+0x198>
    80003426:	ffffd097          	auipc	ra,0xffffd
    8000342a:	168080e7          	jalr	360(ra) # 8000058e <printf>
      while (i < numargs)
    8000342e:	fff9879b          	addiw	a5,s3,-1
    80003432:	1782                	slli	a5,a5,0x20
    80003434:	9381                	srli	a5,a5,0x20
    80003436:	0785                	addi	a5,a5,1
    80003438:	078a                	slli	a5,a5,0x2
    8000343a:	9bbe                	add	s7,s7,a5
        printf("%d ", Args[i]);
    8000343c:	00005497          	auipc	s1,0x5
    80003440:	00448493          	addi	s1,s1,4 # 80008440 <states.2559+0x150>
    80003444:	000aa583          	lw	a1,0(s5)
    80003448:	8526                	mv	a0,s1
    8000344a:	ffffd097          	auipc	ra,0xffffd
    8000344e:	144080e7          	jalr	324(ra) # 8000058e <printf>
      while (i < numargs)
    80003452:	0a91                	addi	s5,s5,4
    80003454:	ff7a98e3          	bne	s5,s7,80003444 <syscall+0x13c>
      printf(")");
    80003458:	00005517          	auipc	a0,0x5
    8000345c:	ff050513          	addi	a0,a0,-16 # 80008448 <states.2559+0x158>
    80003460:	ffffd097          	auipc	ra,0xffffd
    80003464:	12e080e7          	jalr	302(ra) # 8000058e <printf>
      printf(" -> %d\n", p->trapframe->a0);
    80003468:	060a3783          	ld	a5,96(s4)
    8000346c:	7bac                	ld	a1,112(a5)
    8000346e:	00005517          	auipc	a0,0x5
    80003472:	fe250513          	addi	a0,a0,-30 # 80008450 <states.2559+0x160>
    80003476:	ffffd097          	auipc	ra,0xffffd
    8000347a:	118080e7          	jalr	280(ra) # 8000058e <printf>
    8000347e:	bf1d                	j	800033b4 <syscall+0xac>
    p->trapframe->a0 = syscalls[num]();
    80003480:	9d02                	jalr	s10
    80003482:	f8a8                	sd	a0,112(s1)
    int shift = 1 << num; // mask for num
    80003484:	4785                	li	a5,1
    80003486:	016797bb          	sllw	a5,a5,s6
    if (p->mask & shift)
    8000348a:	000a2703          	lw	a4,0(s4)
    8000348e:	8ff9                	and	a5,a5,a4
    80003490:	2781                	sext.w	a5,a5
    80003492:	d38d                	beqz	a5,800033b4 <syscall+0xac>
      printf("%d: syscall %s ", p->pid, syscall_info[num - 1].name);
    80003494:	0c12                	slli	s8,s8,0x4
    80003496:	00005797          	auipc	a5,0x5
    8000349a:	55278793          	addi	a5,a5,1362 # 800089e8 <syscall_info>
    8000349e:	97e2                	add	a5,a5,s8
    800034a0:	6390                	ld	a2,0(a5)
    800034a2:	038a2583          	lw	a1,56(s4)
    800034a6:	00005517          	auipc	a0,0x5
    800034aa:	fd250513          	addi	a0,a0,-46 # 80008478 <states.2559+0x188>
    800034ae:	ffffd097          	auipc	ra,0xffffd
    800034b2:	0e0080e7          	jalr	224(ra) # 8000058e <printf>
      printf("(");
    800034b6:	00005517          	auipc	a0,0x5
    800034ba:	fd250513          	addi	a0,a0,-46 # 80008488 <states.2559+0x198>
    800034be:	ffffd097          	auipc	ra,0xffffd
    800034c2:	0d0080e7          	jalr	208(ra) # 8000058e <printf>
      while (i < numargs)
    800034c6:	bf49                	j	80003458 <syscall+0x150>

00000000800034c8 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800034c8:	1101                	addi	sp,sp,-32
    800034ca:	ec06                	sd	ra,24(sp)
    800034cc:	e822                	sd	s0,16(sp)
    800034ce:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800034d0:	fec40593          	addi	a1,s0,-20
    800034d4:	4501                	li	a0,0
    800034d6:	00000097          	auipc	ra,0x0
    800034da:	dba080e7          	jalr	-582(ra) # 80003290 <argint>
  exit(n);
    800034de:	fec42503          	lw	a0,-20(s0)
    800034e2:	fffff097          	auipc	ra,0xfffff
    800034e6:	3b4080e7          	jalr	948(ra) # 80002896 <exit>
  return 0; // not reached
}
    800034ea:	4501                	li	a0,0
    800034ec:	60e2                	ld	ra,24(sp)
    800034ee:	6442                	ld	s0,16(sp)
    800034f0:	6105                	addi	sp,sp,32
    800034f2:	8082                	ret

00000000800034f4 <sys_getpid>:

uint64
sys_getpid(void)
{
    800034f4:	1141                	addi	sp,sp,-16
    800034f6:	e406                	sd	ra,8(sp)
    800034f8:	e022                	sd	s0,0(sp)
    800034fa:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800034fc:	ffffe097          	auipc	ra,0xffffe
    80003500:	6ee080e7          	jalr	1774(ra) # 80001bea <myproc>
}
    80003504:	5d08                	lw	a0,56(a0)
    80003506:	60a2                	ld	ra,8(sp)
    80003508:	6402                	ld	s0,0(sp)
    8000350a:	0141                	addi	sp,sp,16
    8000350c:	8082                	ret

000000008000350e <sys_fork>:

uint64
sys_fork(void)
{
    8000350e:	1141                	addi	sp,sp,-16
    80003510:	e406                	sd	ra,8(sp)
    80003512:	e022                	sd	s0,0(sp)
    80003514:	0800                	addi	s0,sp,16
  return fork();
    80003516:	fffff097          	auipc	ra,0xfffff
    8000351a:	af4080e7          	jalr	-1292(ra) # 8000200a <fork>
}
    8000351e:	60a2                	ld	ra,8(sp)
    80003520:	6402                	ld	s0,0(sp)
    80003522:	0141                	addi	sp,sp,16
    80003524:	8082                	ret

0000000080003526 <sys_wait>:

uint64
sys_wait(void)
{
    80003526:	1101                	addi	sp,sp,-32
    80003528:	ec06                	sd	ra,24(sp)
    8000352a:	e822                	sd	s0,16(sp)
    8000352c:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    8000352e:	fe840593          	addi	a1,s0,-24
    80003532:	4501                	li	a0,0
    80003534:	00000097          	auipc	ra,0x0
    80003538:	d7c080e7          	jalr	-644(ra) # 800032b0 <argaddr>
  return wait(p);
    8000353c:	fe843503          	ld	a0,-24(s0)
    80003540:	fffff097          	auipc	ra,0xfffff
    80003544:	598080e7          	jalr	1432(ra) # 80002ad8 <wait>
}
    80003548:	60e2                	ld	ra,24(sp)
    8000354a:	6442                	ld	s0,16(sp)
    8000354c:	6105                	addi	sp,sp,32
    8000354e:	8082                	ret

0000000080003550 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003550:	7179                	addi	sp,sp,-48
    80003552:	f406                	sd	ra,40(sp)
    80003554:	f022                	sd	s0,32(sp)
    80003556:	ec26                	sd	s1,24(sp)
    80003558:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    8000355a:	fdc40593          	addi	a1,s0,-36
    8000355e:	4501                	li	a0,0
    80003560:	00000097          	auipc	ra,0x0
    80003564:	d30080e7          	jalr	-720(ra) # 80003290 <argint>
  addr = myproc()->sz;
    80003568:	ffffe097          	auipc	ra,0xffffe
    8000356c:	682080e7          	jalr	1666(ra) # 80001bea <myproc>
    80003570:	6924                	ld	s1,80(a0)
  if (growproc(n) < 0)
    80003572:	fdc42503          	lw	a0,-36(s0)
    80003576:	fffff097          	auipc	ra,0xfffff
    8000357a:	a38080e7          	jalr	-1480(ra) # 80001fae <growproc>
    8000357e:	00054863          	bltz	a0,8000358e <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80003582:	8526                	mv	a0,s1
    80003584:	70a2                	ld	ra,40(sp)
    80003586:	7402                	ld	s0,32(sp)
    80003588:	64e2                	ld	s1,24(sp)
    8000358a:	6145                	addi	sp,sp,48
    8000358c:	8082                	ret
    return -1;
    8000358e:	54fd                	li	s1,-1
    80003590:	bfcd                	j	80003582 <sys_sbrk+0x32>

0000000080003592 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003592:	7139                	addi	sp,sp,-64
    80003594:	fc06                	sd	ra,56(sp)
    80003596:	f822                	sd	s0,48(sp)
    80003598:	f426                	sd	s1,40(sp)
    8000359a:	f04a                	sd	s2,32(sp)
    8000359c:	ec4e                	sd	s3,24(sp)
    8000359e:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800035a0:	fcc40593          	addi	a1,s0,-52
    800035a4:	4501                	li	a0,0
    800035a6:	00000097          	auipc	ra,0x0
    800035aa:	cea080e7          	jalr	-790(ra) # 80003290 <argint>
  acquire(&tickslock);
    800035ae:	00016517          	auipc	a0,0x16
    800035b2:	b4a50513          	addi	a0,a0,-1206 # 800190f8 <tickslock>
    800035b6:	ffffd097          	auipc	ra,0xffffd
    800035ba:	634080e7          	jalr	1588(ra) # 80000bea <acquire>
  ticks0 = ticks;
    800035be:	00005917          	auipc	s2,0x5
    800035c2:	62292903          	lw	s2,1570(s2) # 80008be0 <ticks>
  while (ticks - ticks0 < n)
    800035c6:	fcc42783          	lw	a5,-52(s0)
    800035ca:	cf9d                	beqz	a5,80003608 <sys_sleep+0x76>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800035cc:	00016997          	auipc	s3,0x16
    800035d0:	b2c98993          	addi	s3,s3,-1236 # 800190f8 <tickslock>
    800035d4:	00005497          	auipc	s1,0x5
    800035d8:	60c48493          	addi	s1,s1,1548 # 80008be0 <ticks>
    if (killed(myproc()))
    800035dc:	ffffe097          	auipc	ra,0xffffe
    800035e0:	60e080e7          	jalr	1550(ra) # 80001bea <myproc>
    800035e4:	fffff097          	auipc	ra,0xfffff
    800035e8:	4be080e7          	jalr	1214(ra) # 80002aa2 <killed>
    800035ec:	ed15                	bnez	a0,80003628 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    800035ee:	85ce                	mv	a1,s3
    800035f0:	8526                	mv	a0,s1
    800035f2:	fffff097          	auipc	ra,0xfffff
    800035f6:	f4e080e7          	jalr	-178(ra) # 80002540 <sleep>
  while (ticks - ticks0 < n)
    800035fa:	409c                	lw	a5,0(s1)
    800035fc:	412787bb          	subw	a5,a5,s2
    80003600:	fcc42703          	lw	a4,-52(s0)
    80003604:	fce7ece3          	bltu	a5,a4,800035dc <sys_sleep+0x4a>
  }
  release(&tickslock);
    80003608:	00016517          	auipc	a0,0x16
    8000360c:	af050513          	addi	a0,a0,-1296 # 800190f8 <tickslock>
    80003610:	ffffd097          	auipc	ra,0xffffd
    80003614:	68e080e7          	jalr	1678(ra) # 80000c9e <release>
  return 0;
    80003618:	4501                	li	a0,0
}
    8000361a:	70e2                	ld	ra,56(sp)
    8000361c:	7442                	ld	s0,48(sp)
    8000361e:	74a2                	ld	s1,40(sp)
    80003620:	7902                	ld	s2,32(sp)
    80003622:	69e2                	ld	s3,24(sp)
    80003624:	6121                	addi	sp,sp,64
    80003626:	8082                	ret
      release(&tickslock);
    80003628:	00016517          	auipc	a0,0x16
    8000362c:	ad050513          	addi	a0,a0,-1328 # 800190f8 <tickslock>
    80003630:	ffffd097          	auipc	ra,0xffffd
    80003634:	66e080e7          	jalr	1646(ra) # 80000c9e <release>
      return -1;
    80003638:	557d                	li	a0,-1
    8000363a:	b7c5                	j	8000361a <sys_sleep+0x88>

000000008000363c <sys_kill>:

uint64
sys_kill(void)
{
    8000363c:	1101                	addi	sp,sp,-32
    8000363e:	ec06                	sd	ra,24(sp)
    80003640:	e822                	sd	s0,16(sp)
    80003642:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80003644:	fec40593          	addi	a1,s0,-20
    80003648:	4501                	li	a0,0
    8000364a:	00000097          	auipc	ra,0x0
    8000364e:	c46080e7          	jalr	-954(ra) # 80003290 <argint>
  return kill(pid);
    80003652:	fec42503          	lw	a0,-20(s0)
    80003656:	fffff097          	auipc	ra,0xfffff
    8000365a:	324080e7          	jalr	804(ra) # 8000297a <kill>
}
    8000365e:	60e2                	ld	ra,24(sp)
    80003660:	6442                	ld	s0,16(sp)
    80003662:	6105                	addi	sp,sp,32
    80003664:	8082                	ret

0000000080003666 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003666:	1101                	addi	sp,sp,-32
    80003668:	ec06                	sd	ra,24(sp)
    8000366a:	e822                	sd	s0,16(sp)
    8000366c:	e426                	sd	s1,8(sp)
    8000366e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003670:	00016517          	auipc	a0,0x16
    80003674:	a8850513          	addi	a0,a0,-1400 # 800190f8 <tickslock>
    80003678:	ffffd097          	auipc	ra,0xffffd
    8000367c:	572080e7          	jalr	1394(ra) # 80000bea <acquire>
  xticks = ticks;
    80003680:	00005497          	auipc	s1,0x5
    80003684:	5604a483          	lw	s1,1376(s1) # 80008be0 <ticks>
  release(&tickslock);
    80003688:	00016517          	auipc	a0,0x16
    8000368c:	a7050513          	addi	a0,a0,-1424 # 800190f8 <tickslock>
    80003690:	ffffd097          	auipc	ra,0xffffd
    80003694:	60e080e7          	jalr	1550(ra) # 80000c9e <release>
  return xticks;
}
    80003698:	02049513          	slli	a0,s1,0x20
    8000369c:	9101                	srli	a0,a0,0x20
    8000369e:	60e2                	ld	ra,24(sp)
    800036a0:	6442                	ld	s0,16(sp)
    800036a2:	64a2                	ld	s1,8(sp)
    800036a4:	6105                	addi	sp,sp,32
    800036a6:	8082                	ret

00000000800036a8 <sys_trace>:

uint64
sys_trace(void)
{
    800036a8:	1101                	addi	sp,sp,-32
    800036aa:	ec06                	sd	ra,24(sp)
    800036ac:	e822                	sd	s0,16(sp)
    800036ae:	1000                	addi	s0,sp,32
  int n; // mask
  argint(0, &n);
    800036b0:	fec40593          	addi	a1,s0,-20
    800036b4:	4501                	li	a0,0
    800036b6:	00000097          	auipc	ra,0x0
    800036ba:	bda080e7          	jalr	-1062(ra) # 80003290 <argint>
  myproc()->mask = n;
    800036be:	ffffe097          	auipc	ra,0xffffe
    800036c2:	52c080e7          	jalr	1324(ra) # 80001bea <myproc>
    800036c6:	fec42783          	lw	a5,-20(s0)
    800036ca:	c11c                	sw	a5,0(a0)
  return 0;
}
    800036cc:	4501                	li	a0,0
    800036ce:	60e2                	ld	ra,24(sp)
    800036d0:	6442                	ld	s0,16(sp)
    800036d2:	6105                	addi	sp,sp,32
    800036d4:	8082                	ret

00000000800036d6 <sys_sigalarm>:

uint64
sys_sigalarm(void)
{
    800036d6:	1101                	addi	sp,sp,-32
    800036d8:	ec06                	sd	ra,24(sp)
    800036da:	e822                	sd	s0,16(sp)
    800036dc:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800036de:	fec40593          	addi	a1,s0,-20
    800036e2:	4501                	li	a0,0
    800036e4:	00000097          	auipc	ra,0x0
    800036e8:	bac080e7          	jalr	-1108(ra) # 80003290 <argint>
  myproc()->ticks0 = 0;
    800036ec:	ffffe097          	auipc	ra,0xffffe
    800036f0:	4fe080e7          	jalr	1278(ra) # 80001bea <myproc>
    800036f4:	00052223          	sw	zero,4(a0)
  return 0;
}
    800036f8:	4501                	li	a0,0
    800036fa:	60e2                	ld	ra,24(sp)
    800036fc:	6442                	ld	s0,16(sp)
    800036fe:	6105                	addi	sp,sp,32
    80003700:	8082                	ret

0000000080003702 <sys_setpriority>:

uint64
sys_setpriority(void)
{
    80003702:	1101                	addi	sp,sp,-32
    80003704:	ec06                	sd	ra,24(sp)
    80003706:	e822                	sd	s0,16(sp)
    80003708:	1000                	addi	s0,sp,32
  int priority;
  int pid;
  argint(0, &priority);
    8000370a:	fec40593          	addi	a1,s0,-20
    8000370e:	4501                	li	a0,0
    80003710:	00000097          	auipc	ra,0x0
    80003714:	b80080e7          	jalr	-1152(ra) # 80003290 <argint>
  argint(1, &pid);
    80003718:	fe840593          	addi	a1,s0,-24
    8000371c:	4505                	li	a0,1
    8000371e:	00000097          	auipc	ra,0x0
    80003722:	b72080e7          	jalr	-1166(ra) # 80003290 <argint>
  return set_priority(priority, pid);
    80003726:	fe842583          	lw	a1,-24(s0)
    8000372a:	fec42503          	lw	a0,-20(s0)
    8000372e:	ffffe097          	auipc	ra,0xffffe
    80003732:	170080e7          	jalr	368(ra) # 8000189e <set_priority>
}
    80003736:	60e2                	ld	ra,24(sp)
    80003738:	6442                	ld	s0,16(sp)
    8000373a:	6105                	addi	sp,sp,32
    8000373c:	8082                	ret

000000008000373e <sys_settickets>:

uint64
sys_settickets(void){
    8000373e:	1101                	addi	sp,sp,-32
    80003740:	ec06                	sd	ra,24(sp)
    80003742:	e822                	sd	s0,16(sp)
    80003744:	1000                	addi	s0,sp,32
  int n; // tickets
  argint(0, &n);
    80003746:	fec40593          	addi	a1,s0,-20
    8000374a:	4501                	li	a0,0
    8000374c:	00000097          	auipc	ra,0x0
    80003750:	b44080e7          	jalr	-1212(ra) # 80003290 <argint>
  myproc()->tickets = n;
    80003754:	ffffe097          	auipc	ra,0xffffe
    80003758:	496080e7          	jalr	1174(ra) # 80001bea <myproc>
    8000375c:	fec42783          	lw	a5,-20(s0)
    80003760:	16f52823          	sw	a5,368(a0)
  return 0;
}
    80003764:	4501                	li	a0,0
    80003766:	60e2                	ld	ra,24(sp)
    80003768:	6442                	ld	s0,16(sp)
    8000376a:	6105                	addi	sp,sp,32
    8000376c:	8082                	ret

000000008000376e <sys_waitx>:

uint64
sys_waitx(void)
{
    8000376e:	7139                	addi	sp,sp,-64
    80003770:	fc06                	sd	ra,56(sp)
    80003772:	f822                	sd	s0,48(sp)
    80003774:	f426                	sd	s1,40(sp)
    80003776:	f04a                	sd	s2,32(sp)
    80003778:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    8000377a:	fd840593          	addi	a1,s0,-40
    8000377e:	4501                	li	a0,0
    80003780:	00000097          	auipc	ra,0x0
    80003784:	b30080e7          	jalr	-1232(ra) # 800032b0 <argaddr>
  argaddr(1, &addr1); // user virtual memory
    80003788:	fd040593          	addi	a1,s0,-48
    8000378c:	4505                	li	a0,1
    8000378e:	00000097          	auipc	ra,0x0
    80003792:	b22080e7          	jalr	-1246(ra) # 800032b0 <argaddr>
  argaddr(2, &addr2);
    80003796:	fc840593          	addi	a1,s0,-56
    8000379a:	4509                	li	a0,2
    8000379c:	00000097          	auipc	ra,0x0
    800037a0:	b14080e7          	jalr	-1260(ra) # 800032b0 <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    800037a4:	fc040613          	addi	a2,s0,-64
    800037a8:	fc440593          	addi	a1,s0,-60
    800037ac:	fd843503          	ld	a0,-40(s0)
    800037b0:	fffff097          	auipc	ra,0xfffff
    800037b4:	dfe080e7          	jalr	-514(ra) # 800025ae <waitx>
    800037b8:	892a                	mv	s2,a0
  struct proc* p = myproc();
    800037ba:	ffffe097          	auipc	ra,0xffffe
    800037be:	430080e7          	jalr	1072(ra) # 80001bea <myproc>
    800037c2:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    800037c4:	4691                	li	a3,4
    800037c6:	fc440613          	addi	a2,s0,-60
    800037ca:	fd043583          	ld	a1,-48(s0)
    800037ce:	6d28                	ld	a0,88(a0)
    800037d0:	ffffe097          	auipc	ra,0xffffe
    800037d4:	eb4080e7          	jalr	-332(ra) # 80001684 <copyout>
    return -1;
    800037d8:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    800037da:	00054f63          	bltz	a0,800037f8 <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2,(char*)&rtime, sizeof(int)) < 0)
    800037de:	4691                	li	a3,4
    800037e0:	fc040613          	addi	a2,s0,-64
    800037e4:	fc843583          	ld	a1,-56(s0)
    800037e8:	6ca8                	ld	a0,88(s1)
    800037ea:	ffffe097          	auipc	ra,0xffffe
    800037ee:	e9a080e7          	jalr	-358(ra) # 80001684 <copyout>
    800037f2:	00054a63          	bltz	a0,80003806 <sys_waitx+0x98>
    return -1;
  return ret;
    800037f6:	87ca                	mv	a5,s2
    800037f8:	853e                	mv	a0,a5
    800037fa:	70e2                	ld	ra,56(sp)
    800037fc:	7442                	ld	s0,48(sp)
    800037fe:	74a2                	ld	s1,40(sp)
    80003800:	7902                	ld	s2,32(sp)
    80003802:	6121                	addi	sp,sp,64
    80003804:	8082                	ret
    return -1;
    80003806:	57fd                	li	a5,-1
    80003808:	bfc5                	j	800037f8 <sys_waitx+0x8a>

000000008000380a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000380a:	7179                	addi	sp,sp,-48
    8000380c:	f406                	sd	ra,40(sp)
    8000380e:	f022                	sd	s0,32(sp)
    80003810:	ec26                	sd	s1,24(sp)
    80003812:	e84a                	sd	s2,16(sp)
    80003814:	e44e                	sd	s3,8(sp)
    80003816:	e052                	sd	s4,0(sp)
    80003818:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000381a:	00005597          	auipc	a1,0x5
    8000381e:	e4658593          	addi	a1,a1,-442 # 80008660 <syscalls+0xd8>
    80003822:	00016517          	auipc	a0,0x16
    80003826:	8ee50513          	addi	a0,a0,-1810 # 80019110 <bcache>
    8000382a:	ffffd097          	auipc	ra,0xffffd
    8000382e:	330080e7          	jalr	816(ra) # 80000b5a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003832:	0001e797          	auipc	a5,0x1e
    80003836:	8de78793          	addi	a5,a5,-1826 # 80021110 <bcache+0x8000>
    8000383a:	0001e717          	auipc	a4,0x1e
    8000383e:	b3e70713          	addi	a4,a4,-1218 # 80021378 <bcache+0x8268>
    80003842:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003846:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000384a:	00016497          	auipc	s1,0x16
    8000384e:	8de48493          	addi	s1,s1,-1826 # 80019128 <bcache+0x18>
    b->next = bcache.head.next;
    80003852:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003854:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003856:	00005a17          	auipc	s4,0x5
    8000385a:	e12a0a13          	addi	s4,s4,-494 # 80008668 <syscalls+0xe0>
    b->next = bcache.head.next;
    8000385e:	2b893783          	ld	a5,696(s2)
    80003862:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003864:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003868:	85d2                	mv	a1,s4
    8000386a:	01048513          	addi	a0,s1,16
    8000386e:	00001097          	auipc	ra,0x1
    80003872:	4c4080e7          	jalr	1220(ra) # 80004d32 <initsleeplock>
    bcache.head.next->prev = b;
    80003876:	2b893783          	ld	a5,696(s2)
    8000387a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000387c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003880:	45848493          	addi	s1,s1,1112
    80003884:	fd349de3          	bne	s1,s3,8000385e <binit+0x54>
  }
}
    80003888:	70a2                	ld	ra,40(sp)
    8000388a:	7402                	ld	s0,32(sp)
    8000388c:	64e2                	ld	s1,24(sp)
    8000388e:	6942                	ld	s2,16(sp)
    80003890:	69a2                	ld	s3,8(sp)
    80003892:	6a02                	ld	s4,0(sp)
    80003894:	6145                	addi	sp,sp,48
    80003896:	8082                	ret

0000000080003898 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003898:	7179                	addi	sp,sp,-48
    8000389a:	f406                	sd	ra,40(sp)
    8000389c:	f022                	sd	s0,32(sp)
    8000389e:	ec26                	sd	s1,24(sp)
    800038a0:	e84a                	sd	s2,16(sp)
    800038a2:	e44e                	sd	s3,8(sp)
    800038a4:	1800                	addi	s0,sp,48
    800038a6:	89aa                	mv	s3,a0
    800038a8:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    800038aa:	00016517          	auipc	a0,0x16
    800038ae:	86650513          	addi	a0,a0,-1946 # 80019110 <bcache>
    800038b2:	ffffd097          	auipc	ra,0xffffd
    800038b6:	338080e7          	jalr	824(ra) # 80000bea <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800038ba:	0001e497          	auipc	s1,0x1e
    800038be:	b0e4b483          	ld	s1,-1266(s1) # 800213c8 <bcache+0x82b8>
    800038c2:	0001e797          	auipc	a5,0x1e
    800038c6:	ab678793          	addi	a5,a5,-1354 # 80021378 <bcache+0x8268>
    800038ca:	02f48f63          	beq	s1,a5,80003908 <bread+0x70>
    800038ce:	873e                	mv	a4,a5
    800038d0:	a021                	j	800038d8 <bread+0x40>
    800038d2:	68a4                	ld	s1,80(s1)
    800038d4:	02e48a63          	beq	s1,a4,80003908 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800038d8:	449c                	lw	a5,8(s1)
    800038da:	ff379ce3          	bne	a5,s3,800038d2 <bread+0x3a>
    800038de:	44dc                	lw	a5,12(s1)
    800038e0:	ff2799e3          	bne	a5,s2,800038d2 <bread+0x3a>
      b->refcnt++;
    800038e4:	40bc                	lw	a5,64(s1)
    800038e6:	2785                	addiw	a5,a5,1
    800038e8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800038ea:	00016517          	auipc	a0,0x16
    800038ee:	82650513          	addi	a0,a0,-2010 # 80019110 <bcache>
    800038f2:	ffffd097          	auipc	ra,0xffffd
    800038f6:	3ac080e7          	jalr	940(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    800038fa:	01048513          	addi	a0,s1,16
    800038fe:	00001097          	auipc	ra,0x1
    80003902:	46e080e7          	jalr	1134(ra) # 80004d6c <acquiresleep>
      return b;
    80003906:	a8b9                	j	80003964 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003908:	0001e497          	auipc	s1,0x1e
    8000390c:	ab84b483          	ld	s1,-1352(s1) # 800213c0 <bcache+0x82b0>
    80003910:	0001e797          	auipc	a5,0x1e
    80003914:	a6878793          	addi	a5,a5,-1432 # 80021378 <bcache+0x8268>
    80003918:	00f48863          	beq	s1,a5,80003928 <bread+0x90>
    8000391c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000391e:	40bc                	lw	a5,64(s1)
    80003920:	cf81                	beqz	a5,80003938 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003922:	64a4                	ld	s1,72(s1)
    80003924:	fee49de3          	bne	s1,a4,8000391e <bread+0x86>
  panic("bget: no buffers");
    80003928:	00005517          	auipc	a0,0x5
    8000392c:	d4850513          	addi	a0,a0,-696 # 80008670 <syscalls+0xe8>
    80003930:	ffffd097          	auipc	ra,0xffffd
    80003934:	c14080e7          	jalr	-1004(ra) # 80000544 <panic>
      b->dev = dev;
    80003938:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    8000393c:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80003940:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003944:	4785                	li	a5,1
    80003946:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003948:	00015517          	auipc	a0,0x15
    8000394c:	7c850513          	addi	a0,a0,1992 # 80019110 <bcache>
    80003950:	ffffd097          	auipc	ra,0xffffd
    80003954:	34e080e7          	jalr	846(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    80003958:	01048513          	addi	a0,s1,16
    8000395c:	00001097          	auipc	ra,0x1
    80003960:	410080e7          	jalr	1040(ra) # 80004d6c <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003964:	409c                	lw	a5,0(s1)
    80003966:	cb89                	beqz	a5,80003978 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003968:	8526                	mv	a0,s1
    8000396a:	70a2                	ld	ra,40(sp)
    8000396c:	7402                	ld	s0,32(sp)
    8000396e:	64e2                	ld	s1,24(sp)
    80003970:	6942                	ld	s2,16(sp)
    80003972:	69a2                	ld	s3,8(sp)
    80003974:	6145                	addi	sp,sp,48
    80003976:	8082                	ret
    virtio_disk_rw(b, 0);
    80003978:	4581                	li	a1,0
    8000397a:	8526                	mv	a0,s1
    8000397c:	00003097          	auipc	ra,0x3
    80003980:	fcc080e7          	jalr	-52(ra) # 80006948 <virtio_disk_rw>
    b->valid = 1;
    80003984:	4785                	li	a5,1
    80003986:	c09c                	sw	a5,0(s1)
  return b;
    80003988:	b7c5                	j	80003968 <bread+0xd0>

000000008000398a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000398a:	1101                	addi	sp,sp,-32
    8000398c:	ec06                	sd	ra,24(sp)
    8000398e:	e822                	sd	s0,16(sp)
    80003990:	e426                	sd	s1,8(sp)
    80003992:	1000                	addi	s0,sp,32
    80003994:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003996:	0541                	addi	a0,a0,16
    80003998:	00001097          	auipc	ra,0x1
    8000399c:	46e080e7          	jalr	1134(ra) # 80004e06 <holdingsleep>
    800039a0:	cd01                	beqz	a0,800039b8 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800039a2:	4585                	li	a1,1
    800039a4:	8526                	mv	a0,s1
    800039a6:	00003097          	auipc	ra,0x3
    800039aa:	fa2080e7          	jalr	-94(ra) # 80006948 <virtio_disk_rw>
}
    800039ae:	60e2                	ld	ra,24(sp)
    800039b0:	6442                	ld	s0,16(sp)
    800039b2:	64a2                	ld	s1,8(sp)
    800039b4:	6105                	addi	sp,sp,32
    800039b6:	8082                	ret
    panic("bwrite");
    800039b8:	00005517          	auipc	a0,0x5
    800039bc:	cd050513          	addi	a0,a0,-816 # 80008688 <syscalls+0x100>
    800039c0:	ffffd097          	auipc	ra,0xffffd
    800039c4:	b84080e7          	jalr	-1148(ra) # 80000544 <panic>

00000000800039c8 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800039c8:	1101                	addi	sp,sp,-32
    800039ca:	ec06                	sd	ra,24(sp)
    800039cc:	e822                	sd	s0,16(sp)
    800039ce:	e426                	sd	s1,8(sp)
    800039d0:	e04a                	sd	s2,0(sp)
    800039d2:	1000                	addi	s0,sp,32
    800039d4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800039d6:	01050913          	addi	s2,a0,16
    800039da:	854a                	mv	a0,s2
    800039dc:	00001097          	auipc	ra,0x1
    800039e0:	42a080e7          	jalr	1066(ra) # 80004e06 <holdingsleep>
    800039e4:	c92d                	beqz	a0,80003a56 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800039e6:	854a                	mv	a0,s2
    800039e8:	00001097          	auipc	ra,0x1
    800039ec:	3da080e7          	jalr	986(ra) # 80004dc2 <releasesleep>

  acquire(&bcache.lock);
    800039f0:	00015517          	auipc	a0,0x15
    800039f4:	72050513          	addi	a0,a0,1824 # 80019110 <bcache>
    800039f8:	ffffd097          	auipc	ra,0xffffd
    800039fc:	1f2080e7          	jalr	498(ra) # 80000bea <acquire>
  b->refcnt--;
    80003a00:	40bc                	lw	a5,64(s1)
    80003a02:	37fd                	addiw	a5,a5,-1
    80003a04:	0007871b          	sext.w	a4,a5
    80003a08:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003a0a:	eb05                	bnez	a4,80003a3a <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003a0c:	68bc                	ld	a5,80(s1)
    80003a0e:	64b8                	ld	a4,72(s1)
    80003a10:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003a12:	64bc                	ld	a5,72(s1)
    80003a14:	68b8                	ld	a4,80(s1)
    80003a16:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003a18:	0001d797          	auipc	a5,0x1d
    80003a1c:	6f878793          	addi	a5,a5,1784 # 80021110 <bcache+0x8000>
    80003a20:	2b87b703          	ld	a4,696(a5)
    80003a24:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003a26:	0001e717          	auipc	a4,0x1e
    80003a2a:	95270713          	addi	a4,a4,-1710 # 80021378 <bcache+0x8268>
    80003a2e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003a30:	2b87b703          	ld	a4,696(a5)
    80003a34:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003a36:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003a3a:	00015517          	auipc	a0,0x15
    80003a3e:	6d650513          	addi	a0,a0,1750 # 80019110 <bcache>
    80003a42:	ffffd097          	auipc	ra,0xffffd
    80003a46:	25c080e7          	jalr	604(ra) # 80000c9e <release>
}
    80003a4a:	60e2                	ld	ra,24(sp)
    80003a4c:	6442                	ld	s0,16(sp)
    80003a4e:	64a2                	ld	s1,8(sp)
    80003a50:	6902                	ld	s2,0(sp)
    80003a52:	6105                	addi	sp,sp,32
    80003a54:	8082                	ret
    panic("brelse");
    80003a56:	00005517          	auipc	a0,0x5
    80003a5a:	c3a50513          	addi	a0,a0,-966 # 80008690 <syscalls+0x108>
    80003a5e:	ffffd097          	auipc	ra,0xffffd
    80003a62:	ae6080e7          	jalr	-1306(ra) # 80000544 <panic>

0000000080003a66 <bpin>:

void
bpin(struct buf *b) {
    80003a66:	1101                	addi	sp,sp,-32
    80003a68:	ec06                	sd	ra,24(sp)
    80003a6a:	e822                	sd	s0,16(sp)
    80003a6c:	e426                	sd	s1,8(sp)
    80003a6e:	1000                	addi	s0,sp,32
    80003a70:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003a72:	00015517          	auipc	a0,0x15
    80003a76:	69e50513          	addi	a0,a0,1694 # 80019110 <bcache>
    80003a7a:	ffffd097          	auipc	ra,0xffffd
    80003a7e:	170080e7          	jalr	368(ra) # 80000bea <acquire>
  b->refcnt++;
    80003a82:	40bc                	lw	a5,64(s1)
    80003a84:	2785                	addiw	a5,a5,1
    80003a86:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003a88:	00015517          	auipc	a0,0x15
    80003a8c:	68850513          	addi	a0,a0,1672 # 80019110 <bcache>
    80003a90:	ffffd097          	auipc	ra,0xffffd
    80003a94:	20e080e7          	jalr	526(ra) # 80000c9e <release>
}
    80003a98:	60e2                	ld	ra,24(sp)
    80003a9a:	6442                	ld	s0,16(sp)
    80003a9c:	64a2                	ld	s1,8(sp)
    80003a9e:	6105                	addi	sp,sp,32
    80003aa0:	8082                	ret

0000000080003aa2 <bunpin>:

void
bunpin(struct buf *b) {
    80003aa2:	1101                	addi	sp,sp,-32
    80003aa4:	ec06                	sd	ra,24(sp)
    80003aa6:	e822                	sd	s0,16(sp)
    80003aa8:	e426                	sd	s1,8(sp)
    80003aaa:	1000                	addi	s0,sp,32
    80003aac:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003aae:	00015517          	auipc	a0,0x15
    80003ab2:	66250513          	addi	a0,a0,1634 # 80019110 <bcache>
    80003ab6:	ffffd097          	auipc	ra,0xffffd
    80003aba:	134080e7          	jalr	308(ra) # 80000bea <acquire>
  b->refcnt--;
    80003abe:	40bc                	lw	a5,64(s1)
    80003ac0:	37fd                	addiw	a5,a5,-1
    80003ac2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003ac4:	00015517          	auipc	a0,0x15
    80003ac8:	64c50513          	addi	a0,a0,1612 # 80019110 <bcache>
    80003acc:	ffffd097          	auipc	ra,0xffffd
    80003ad0:	1d2080e7          	jalr	466(ra) # 80000c9e <release>
}
    80003ad4:	60e2                	ld	ra,24(sp)
    80003ad6:	6442                	ld	s0,16(sp)
    80003ad8:	64a2                	ld	s1,8(sp)
    80003ada:	6105                	addi	sp,sp,32
    80003adc:	8082                	ret

0000000080003ade <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003ade:	1101                	addi	sp,sp,-32
    80003ae0:	ec06                	sd	ra,24(sp)
    80003ae2:	e822                	sd	s0,16(sp)
    80003ae4:	e426                	sd	s1,8(sp)
    80003ae6:	e04a                	sd	s2,0(sp)
    80003ae8:	1000                	addi	s0,sp,32
    80003aea:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003aec:	00d5d59b          	srliw	a1,a1,0xd
    80003af0:	0001e797          	auipc	a5,0x1e
    80003af4:	cfc7a783          	lw	a5,-772(a5) # 800217ec <sb+0x1c>
    80003af8:	9dbd                	addw	a1,a1,a5
    80003afa:	00000097          	auipc	ra,0x0
    80003afe:	d9e080e7          	jalr	-610(ra) # 80003898 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003b02:	0074f713          	andi	a4,s1,7
    80003b06:	4785                	li	a5,1
    80003b08:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003b0c:	14ce                	slli	s1,s1,0x33
    80003b0e:	90d9                	srli	s1,s1,0x36
    80003b10:	00950733          	add	a4,a0,s1
    80003b14:	05874703          	lbu	a4,88(a4)
    80003b18:	00e7f6b3          	and	a3,a5,a4
    80003b1c:	c69d                	beqz	a3,80003b4a <bfree+0x6c>
    80003b1e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003b20:	94aa                	add	s1,s1,a0
    80003b22:	fff7c793          	not	a5,a5
    80003b26:	8ff9                	and	a5,a5,a4
    80003b28:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003b2c:	00001097          	auipc	ra,0x1
    80003b30:	120080e7          	jalr	288(ra) # 80004c4c <log_write>
  brelse(bp);
    80003b34:	854a                	mv	a0,s2
    80003b36:	00000097          	auipc	ra,0x0
    80003b3a:	e92080e7          	jalr	-366(ra) # 800039c8 <brelse>
}
    80003b3e:	60e2                	ld	ra,24(sp)
    80003b40:	6442                	ld	s0,16(sp)
    80003b42:	64a2                	ld	s1,8(sp)
    80003b44:	6902                	ld	s2,0(sp)
    80003b46:	6105                	addi	sp,sp,32
    80003b48:	8082                	ret
    panic("freeing free block");
    80003b4a:	00005517          	auipc	a0,0x5
    80003b4e:	b4e50513          	addi	a0,a0,-1202 # 80008698 <syscalls+0x110>
    80003b52:	ffffd097          	auipc	ra,0xffffd
    80003b56:	9f2080e7          	jalr	-1550(ra) # 80000544 <panic>

0000000080003b5a <balloc>:
{
    80003b5a:	711d                	addi	sp,sp,-96
    80003b5c:	ec86                	sd	ra,88(sp)
    80003b5e:	e8a2                	sd	s0,80(sp)
    80003b60:	e4a6                	sd	s1,72(sp)
    80003b62:	e0ca                	sd	s2,64(sp)
    80003b64:	fc4e                	sd	s3,56(sp)
    80003b66:	f852                	sd	s4,48(sp)
    80003b68:	f456                	sd	s5,40(sp)
    80003b6a:	f05a                	sd	s6,32(sp)
    80003b6c:	ec5e                	sd	s7,24(sp)
    80003b6e:	e862                	sd	s8,16(sp)
    80003b70:	e466                	sd	s9,8(sp)
    80003b72:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003b74:	0001e797          	auipc	a5,0x1e
    80003b78:	c607a783          	lw	a5,-928(a5) # 800217d4 <sb+0x4>
    80003b7c:	10078163          	beqz	a5,80003c7e <balloc+0x124>
    80003b80:	8baa                	mv	s7,a0
    80003b82:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003b84:	0001eb17          	auipc	s6,0x1e
    80003b88:	c4cb0b13          	addi	s6,s6,-948 # 800217d0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b8c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003b8e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b90:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003b92:	6c89                	lui	s9,0x2
    80003b94:	a061                	j	80003c1c <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003b96:	974a                	add	a4,a4,s2
    80003b98:	8fd5                	or	a5,a5,a3
    80003b9a:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003b9e:	854a                	mv	a0,s2
    80003ba0:	00001097          	auipc	ra,0x1
    80003ba4:	0ac080e7          	jalr	172(ra) # 80004c4c <log_write>
        brelse(bp);
    80003ba8:	854a                	mv	a0,s2
    80003baa:	00000097          	auipc	ra,0x0
    80003bae:	e1e080e7          	jalr	-482(ra) # 800039c8 <brelse>
  bp = bread(dev, bno);
    80003bb2:	85a6                	mv	a1,s1
    80003bb4:	855e                	mv	a0,s7
    80003bb6:	00000097          	auipc	ra,0x0
    80003bba:	ce2080e7          	jalr	-798(ra) # 80003898 <bread>
    80003bbe:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003bc0:	40000613          	li	a2,1024
    80003bc4:	4581                	li	a1,0
    80003bc6:	05850513          	addi	a0,a0,88
    80003bca:	ffffd097          	auipc	ra,0xffffd
    80003bce:	11c080e7          	jalr	284(ra) # 80000ce6 <memset>
  log_write(bp);
    80003bd2:	854a                	mv	a0,s2
    80003bd4:	00001097          	auipc	ra,0x1
    80003bd8:	078080e7          	jalr	120(ra) # 80004c4c <log_write>
  brelse(bp);
    80003bdc:	854a                	mv	a0,s2
    80003bde:	00000097          	auipc	ra,0x0
    80003be2:	dea080e7          	jalr	-534(ra) # 800039c8 <brelse>
}
    80003be6:	8526                	mv	a0,s1
    80003be8:	60e6                	ld	ra,88(sp)
    80003bea:	6446                	ld	s0,80(sp)
    80003bec:	64a6                	ld	s1,72(sp)
    80003bee:	6906                	ld	s2,64(sp)
    80003bf0:	79e2                	ld	s3,56(sp)
    80003bf2:	7a42                	ld	s4,48(sp)
    80003bf4:	7aa2                	ld	s5,40(sp)
    80003bf6:	7b02                	ld	s6,32(sp)
    80003bf8:	6be2                	ld	s7,24(sp)
    80003bfa:	6c42                	ld	s8,16(sp)
    80003bfc:	6ca2                	ld	s9,8(sp)
    80003bfe:	6125                	addi	sp,sp,96
    80003c00:	8082                	ret
    brelse(bp);
    80003c02:	854a                	mv	a0,s2
    80003c04:	00000097          	auipc	ra,0x0
    80003c08:	dc4080e7          	jalr	-572(ra) # 800039c8 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003c0c:	015c87bb          	addw	a5,s9,s5
    80003c10:	00078a9b          	sext.w	s5,a5
    80003c14:	004b2703          	lw	a4,4(s6)
    80003c18:	06eaf363          	bgeu	s5,a4,80003c7e <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80003c1c:	41fad79b          	sraiw	a5,s5,0x1f
    80003c20:	0137d79b          	srliw	a5,a5,0x13
    80003c24:	015787bb          	addw	a5,a5,s5
    80003c28:	40d7d79b          	sraiw	a5,a5,0xd
    80003c2c:	01cb2583          	lw	a1,28(s6)
    80003c30:	9dbd                	addw	a1,a1,a5
    80003c32:	855e                	mv	a0,s7
    80003c34:	00000097          	auipc	ra,0x0
    80003c38:	c64080e7          	jalr	-924(ra) # 80003898 <bread>
    80003c3c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003c3e:	004b2503          	lw	a0,4(s6)
    80003c42:	000a849b          	sext.w	s1,s5
    80003c46:	8662                	mv	a2,s8
    80003c48:	faa4fde3          	bgeu	s1,a0,80003c02 <balloc+0xa8>
      m = 1 << (bi % 8);
    80003c4c:	41f6579b          	sraiw	a5,a2,0x1f
    80003c50:	01d7d69b          	srliw	a3,a5,0x1d
    80003c54:	00c6873b          	addw	a4,a3,a2
    80003c58:	00777793          	andi	a5,a4,7
    80003c5c:	9f95                	subw	a5,a5,a3
    80003c5e:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003c62:	4037571b          	sraiw	a4,a4,0x3
    80003c66:	00e906b3          	add	a3,s2,a4
    80003c6a:	0586c683          	lbu	a3,88(a3)
    80003c6e:	00d7f5b3          	and	a1,a5,a3
    80003c72:	d195                	beqz	a1,80003b96 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003c74:	2605                	addiw	a2,a2,1
    80003c76:	2485                	addiw	s1,s1,1
    80003c78:	fd4618e3          	bne	a2,s4,80003c48 <balloc+0xee>
    80003c7c:	b759                	j	80003c02 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003c7e:	00005517          	auipc	a0,0x5
    80003c82:	a3250513          	addi	a0,a0,-1486 # 800086b0 <syscalls+0x128>
    80003c86:	ffffd097          	auipc	ra,0xffffd
    80003c8a:	908080e7          	jalr	-1784(ra) # 8000058e <printf>
  return 0;
    80003c8e:	4481                	li	s1,0
    80003c90:	bf99                	j	80003be6 <balloc+0x8c>

0000000080003c92 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003c92:	7179                	addi	sp,sp,-48
    80003c94:	f406                	sd	ra,40(sp)
    80003c96:	f022                	sd	s0,32(sp)
    80003c98:	ec26                	sd	s1,24(sp)
    80003c9a:	e84a                	sd	s2,16(sp)
    80003c9c:	e44e                	sd	s3,8(sp)
    80003c9e:	e052                	sd	s4,0(sp)
    80003ca0:	1800                	addi	s0,sp,48
    80003ca2:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003ca4:	47ad                	li	a5,11
    80003ca6:	02b7e763          	bltu	a5,a1,80003cd4 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003caa:	02059493          	slli	s1,a1,0x20
    80003cae:	9081                	srli	s1,s1,0x20
    80003cb0:	048a                	slli	s1,s1,0x2
    80003cb2:	94aa                	add	s1,s1,a0
    80003cb4:	0504a903          	lw	s2,80(s1)
    80003cb8:	06091e63          	bnez	s2,80003d34 <bmap+0xa2>
      addr = balloc(ip->dev);
    80003cbc:	4108                	lw	a0,0(a0)
    80003cbe:	00000097          	auipc	ra,0x0
    80003cc2:	e9c080e7          	jalr	-356(ra) # 80003b5a <balloc>
    80003cc6:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003cca:	06090563          	beqz	s2,80003d34 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80003cce:	0524a823          	sw	s2,80(s1)
    80003cd2:	a08d                	j	80003d34 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003cd4:	ff45849b          	addiw	s1,a1,-12
    80003cd8:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003cdc:	0ff00793          	li	a5,255
    80003ce0:	08e7e563          	bltu	a5,a4,80003d6a <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003ce4:	08052903          	lw	s2,128(a0)
    80003ce8:	00091d63          	bnez	s2,80003d02 <bmap+0x70>
      addr = balloc(ip->dev);
    80003cec:	4108                	lw	a0,0(a0)
    80003cee:	00000097          	auipc	ra,0x0
    80003cf2:	e6c080e7          	jalr	-404(ra) # 80003b5a <balloc>
    80003cf6:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003cfa:	02090d63          	beqz	s2,80003d34 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003cfe:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003d02:	85ca                	mv	a1,s2
    80003d04:	0009a503          	lw	a0,0(s3)
    80003d08:	00000097          	auipc	ra,0x0
    80003d0c:	b90080e7          	jalr	-1136(ra) # 80003898 <bread>
    80003d10:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003d12:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003d16:	02049593          	slli	a1,s1,0x20
    80003d1a:	9181                	srli	a1,a1,0x20
    80003d1c:	058a                	slli	a1,a1,0x2
    80003d1e:	00b784b3          	add	s1,a5,a1
    80003d22:	0004a903          	lw	s2,0(s1)
    80003d26:	02090063          	beqz	s2,80003d46 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003d2a:	8552                	mv	a0,s4
    80003d2c:	00000097          	auipc	ra,0x0
    80003d30:	c9c080e7          	jalr	-868(ra) # 800039c8 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003d34:	854a                	mv	a0,s2
    80003d36:	70a2                	ld	ra,40(sp)
    80003d38:	7402                	ld	s0,32(sp)
    80003d3a:	64e2                	ld	s1,24(sp)
    80003d3c:	6942                	ld	s2,16(sp)
    80003d3e:	69a2                	ld	s3,8(sp)
    80003d40:	6a02                	ld	s4,0(sp)
    80003d42:	6145                	addi	sp,sp,48
    80003d44:	8082                	ret
      addr = balloc(ip->dev);
    80003d46:	0009a503          	lw	a0,0(s3)
    80003d4a:	00000097          	auipc	ra,0x0
    80003d4e:	e10080e7          	jalr	-496(ra) # 80003b5a <balloc>
    80003d52:	0005091b          	sext.w	s2,a0
      if(addr){
    80003d56:	fc090ae3          	beqz	s2,80003d2a <bmap+0x98>
        a[bn] = addr;
    80003d5a:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003d5e:	8552                	mv	a0,s4
    80003d60:	00001097          	auipc	ra,0x1
    80003d64:	eec080e7          	jalr	-276(ra) # 80004c4c <log_write>
    80003d68:	b7c9                	j	80003d2a <bmap+0x98>
  panic("bmap: out of range");
    80003d6a:	00005517          	auipc	a0,0x5
    80003d6e:	95e50513          	addi	a0,a0,-1698 # 800086c8 <syscalls+0x140>
    80003d72:	ffffc097          	auipc	ra,0xffffc
    80003d76:	7d2080e7          	jalr	2002(ra) # 80000544 <panic>

0000000080003d7a <iget>:
{
    80003d7a:	7179                	addi	sp,sp,-48
    80003d7c:	f406                	sd	ra,40(sp)
    80003d7e:	f022                	sd	s0,32(sp)
    80003d80:	ec26                	sd	s1,24(sp)
    80003d82:	e84a                	sd	s2,16(sp)
    80003d84:	e44e                	sd	s3,8(sp)
    80003d86:	e052                	sd	s4,0(sp)
    80003d88:	1800                	addi	s0,sp,48
    80003d8a:	89aa                	mv	s3,a0
    80003d8c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003d8e:	0001e517          	auipc	a0,0x1e
    80003d92:	a6250513          	addi	a0,a0,-1438 # 800217f0 <itable>
    80003d96:	ffffd097          	auipc	ra,0xffffd
    80003d9a:	e54080e7          	jalr	-428(ra) # 80000bea <acquire>
  empty = 0;
    80003d9e:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003da0:	0001e497          	auipc	s1,0x1e
    80003da4:	a6848493          	addi	s1,s1,-1432 # 80021808 <itable+0x18>
    80003da8:	0001f697          	auipc	a3,0x1f
    80003dac:	4f068693          	addi	a3,a3,1264 # 80023298 <log>
    80003db0:	a039                	j	80003dbe <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003db2:	02090b63          	beqz	s2,80003de8 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003db6:	08848493          	addi	s1,s1,136
    80003dba:	02d48a63          	beq	s1,a3,80003dee <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003dbe:	449c                	lw	a5,8(s1)
    80003dc0:	fef059e3          	blez	a5,80003db2 <iget+0x38>
    80003dc4:	4098                	lw	a4,0(s1)
    80003dc6:	ff3716e3          	bne	a4,s3,80003db2 <iget+0x38>
    80003dca:	40d8                	lw	a4,4(s1)
    80003dcc:	ff4713e3          	bne	a4,s4,80003db2 <iget+0x38>
      ip->ref++;
    80003dd0:	2785                	addiw	a5,a5,1
    80003dd2:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003dd4:	0001e517          	auipc	a0,0x1e
    80003dd8:	a1c50513          	addi	a0,a0,-1508 # 800217f0 <itable>
    80003ddc:	ffffd097          	auipc	ra,0xffffd
    80003de0:	ec2080e7          	jalr	-318(ra) # 80000c9e <release>
      return ip;
    80003de4:	8926                	mv	s2,s1
    80003de6:	a03d                	j	80003e14 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003de8:	f7f9                	bnez	a5,80003db6 <iget+0x3c>
    80003dea:	8926                	mv	s2,s1
    80003dec:	b7e9                	j	80003db6 <iget+0x3c>
  if(empty == 0)
    80003dee:	02090c63          	beqz	s2,80003e26 <iget+0xac>
  ip->dev = dev;
    80003df2:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003df6:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003dfa:	4785                	li	a5,1
    80003dfc:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003e00:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003e04:	0001e517          	auipc	a0,0x1e
    80003e08:	9ec50513          	addi	a0,a0,-1556 # 800217f0 <itable>
    80003e0c:	ffffd097          	auipc	ra,0xffffd
    80003e10:	e92080e7          	jalr	-366(ra) # 80000c9e <release>
}
    80003e14:	854a                	mv	a0,s2
    80003e16:	70a2                	ld	ra,40(sp)
    80003e18:	7402                	ld	s0,32(sp)
    80003e1a:	64e2                	ld	s1,24(sp)
    80003e1c:	6942                	ld	s2,16(sp)
    80003e1e:	69a2                	ld	s3,8(sp)
    80003e20:	6a02                	ld	s4,0(sp)
    80003e22:	6145                	addi	sp,sp,48
    80003e24:	8082                	ret
    panic("iget: no inodes");
    80003e26:	00005517          	auipc	a0,0x5
    80003e2a:	8ba50513          	addi	a0,a0,-1862 # 800086e0 <syscalls+0x158>
    80003e2e:	ffffc097          	auipc	ra,0xffffc
    80003e32:	716080e7          	jalr	1814(ra) # 80000544 <panic>

0000000080003e36 <fsinit>:
fsinit(int dev) {
    80003e36:	7179                	addi	sp,sp,-48
    80003e38:	f406                	sd	ra,40(sp)
    80003e3a:	f022                	sd	s0,32(sp)
    80003e3c:	ec26                	sd	s1,24(sp)
    80003e3e:	e84a                	sd	s2,16(sp)
    80003e40:	e44e                	sd	s3,8(sp)
    80003e42:	1800                	addi	s0,sp,48
    80003e44:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003e46:	4585                	li	a1,1
    80003e48:	00000097          	auipc	ra,0x0
    80003e4c:	a50080e7          	jalr	-1456(ra) # 80003898 <bread>
    80003e50:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003e52:	0001e997          	auipc	s3,0x1e
    80003e56:	97e98993          	addi	s3,s3,-1666 # 800217d0 <sb>
    80003e5a:	02000613          	li	a2,32
    80003e5e:	05850593          	addi	a1,a0,88
    80003e62:	854e                	mv	a0,s3
    80003e64:	ffffd097          	auipc	ra,0xffffd
    80003e68:	ee2080e7          	jalr	-286(ra) # 80000d46 <memmove>
  brelse(bp);
    80003e6c:	8526                	mv	a0,s1
    80003e6e:	00000097          	auipc	ra,0x0
    80003e72:	b5a080e7          	jalr	-1190(ra) # 800039c8 <brelse>
  if(sb.magic != FSMAGIC)
    80003e76:	0009a703          	lw	a4,0(s3)
    80003e7a:	102037b7          	lui	a5,0x10203
    80003e7e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003e82:	02f71263          	bne	a4,a5,80003ea6 <fsinit+0x70>
  initlog(dev, &sb);
    80003e86:	0001e597          	auipc	a1,0x1e
    80003e8a:	94a58593          	addi	a1,a1,-1718 # 800217d0 <sb>
    80003e8e:	854a                	mv	a0,s2
    80003e90:	00001097          	auipc	ra,0x1
    80003e94:	b40080e7          	jalr	-1216(ra) # 800049d0 <initlog>
}
    80003e98:	70a2                	ld	ra,40(sp)
    80003e9a:	7402                	ld	s0,32(sp)
    80003e9c:	64e2                	ld	s1,24(sp)
    80003e9e:	6942                	ld	s2,16(sp)
    80003ea0:	69a2                	ld	s3,8(sp)
    80003ea2:	6145                	addi	sp,sp,48
    80003ea4:	8082                	ret
    panic("invalid file system");
    80003ea6:	00005517          	auipc	a0,0x5
    80003eaa:	84a50513          	addi	a0,a0,-1974 # 800086f0 <syscalls+0x168>
    80003eae:	ffffc097          	auipc	ra,0xffffc
    80003eb2:	696080e7          	jalr	1686(ra) # 80000544 <panic>

0000000080003eb6 <iinit>:
{
    80003eb6:	7179                	addi	sp,sp,-48
    80003eb8:	f406                	sd	ra,40(sp)
    80003eba:	f022                	sd	s0,32(sp)
    80003ebc:	ec26                	sd	s1,24(sp)
    80003ebe:	e84a                	sd	s2,16(sp)
    80003ec0:	e44e                	sd	s3,8(sp)
    80003ec2:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003ec4:	00005597          	auipc	a1,0x5
    80003ec8:	84458593          	addi	a1,a1,-1980 # 80008708 <syscalls+0x180>
    80003ecc:	0001e517          	auipc	a0,0x1e
    80003ed0:	92450513          	addi	a0,a0,-1756 # 800217f0 <itable>
    80003ed4:	ffffd097          	auipc	ra,0xffffd
    80003ed8:	c86080e7          	jalr	-890(ra) # 80000b5a <initlock>
  for(i = 0; i < NINODE; i++) {
    80003edc:	0001e497          	auipc	s1,0x1e
    80003ee0:	93c48493          	addi	s1,s1,-1732 # 80021818 <itable+0x28>
    80003ee4:	0001f997          	auipc	s3,0x1f
    80003ee8:	3c498993          	addi	s3,s3,964 # 800232a8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003eec:	00005917          	auipc	s2,0x5
    80003ef0:	82490913          	addi	s2,s2,-2012 # 80008710 <syscalls+0x188>
    80003ef4:	85ca                	mv	a1,s2
    80003ef6:	8526                	mv	a0,s1
    80003ef8:	00001097          	auipc	ra,0x1
    80003efc:	e3a080e7          	jalr	-454(ra) # 80004d32 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003f00:	08848493          	addi	s1,s1,136
    80003f04:	ff3498e3          	bne	s1,s3,80003ef4 <iinit+0x3e>
}
    80003f08:	70a2                	ld	ra,40(sp)
    80003f0a:	7402                	ld	s0,32(sp)
    80003f0c:	64e2                	ld	s1,24(sp)
    80003f0e:	6942                	ld	s2,16(sp)
    80003f10:	69a2                	ld	s3,8(sp)
    80003f12:	6145                	addi	sp,sp,48
    80003f14:	8082                	ret

0000000080003f16 <ialloc>:
{
    80003f16:	715d                	addi	sp,sp,-80
    80003f18:	e486                	sd	ra,72(sp)
    80003f1a:	e0a2                	sd	s0,64(sp)
    80003f1c:	fc26                	sd	s1,56(sp)
    80003f1e:	f84a                	sd	s2,48(sp)
    80003f20:	f44e                	sd	s3,40(sp)
    80003f22:	f052                	sd	s4,32(sp)
    80003f24:	ec56                	sd	s5,24(sp)
    80003f26:	e85a                	sd	s6,16(sp)
    80003f28:	e45e                	sd	s7,8(sp)
    80003f2a:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003f2c:	0001e717          	auipc	a4,0x1e
    80003f30:	8b072703          	lw	a4,-1872(a4) # 800217dc <sb+0xc>
    80003f34:	4785                	li	a5,1
    80003f36:	04e7fa63          	bgeu	a5,a4,80003f8a <ialloc+0x74>
    80003f3a:	8aaa                	mv	s5,a0
    80003f3c:	8bae                	mv	s7,a1
    80003f3e:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003f40:	0001ea17          	auipc	s4,0x1e
    80003f44:	890a0a13          	addi	s4,s4,-1904 # 800217d0 <sb>
    80003f48:	00048b1b          	sext.w	s6,s1
    80003f4c:	0044d593          	srli	a1,s1,0x4
    80003f50:	018a2783          	lw	a5,24(s4)
    80003f54:	9dbd                	addw	a1,a1,a5
    80003f56:	8556                	mv	a0,s5
    80003f58:	00000097          	auipc	ra,0x0
    80003f5c:	940080e7          	jalr	-1728(ra) # 80003898 <bread>
    80003f60:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003f62:	05850993          	addi	s3,a0,88
    80003f66:	00f4f793          	andi	a5,s1,15
    80003f6a:	079a                	slli	a5,a5,0x6
    80003f6c:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003f6e:	00099783          	lh	a5,0(s3)
    80003f72:	c3a1                	beqz	a5,80003fb2 <ialloc+0x9c>
    brelse(bp);
    80003f74:	00000097          	auipc	ra,0x0
    80003f78:	a54080e7          	jalr	-1452(ra) # 800039c8 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003f7c:	0485                	addi	s1,s1,1
    80003f7e:	00ca2703          	lw	a4,12(s4)
    80003f82:	0004879b          	sext.w	a5,s1
    80003f86:	fce7e1e3          	bltu	a5,a4,80003f48 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003f8a:	00004517          	auipc	a0,0x4
    80003f8e:	78e50513          	addi	a0,a0,1934 # 80008718 <syscalls+0x190>
    80003f92:	ffffc097          	auipc	ra,0xffffc
    80003f96:	5fc080e7          	jalr	1532(ra) # 8000058e <printf>
  return 0;
    80003f9a:	4501                	li	a0,0
}
    80003f9c:	60a6                	ld	ra,72(sp)
    80003f9e:	6406                	ld	s0,64(sp)
    80003fa0:	74e2                	ld	s1,56(sp)
    80003fa2:	7942                	ld	s2,48(sp)
    80003fa4:	79a2                	ld	s3,40(sp)
    80003fa6:	7a02                	ld	s4,32(sp)
    80003fa8:	6ae2                	ld	s5,24(sp)
    80003faa:	6b42                	ld	s6,16(sp)
    80003fac:	6ba2                	ld	s7,8(sp)
    80003fae:	6161                	addi	sp,sp,80
    80003fb0:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003fb2:	04000613          	li	a2,64
    80003fb6:	4581                	li	a1,0
    80003fb8:	854e                	mv	a0,s3
    80003fba:	ffffd097          	auipc	ra,0xffffd
    80003fbe:	d2c080e7          	jalr	-724(ra) # 80000ce6 <memset>
      dip->type = type;
    80003fc2:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003fc6:	854a                	mv	a0,s2
    80003fc8:	00001097          	auipc	ra,0x1
    80003fcc:	c84080e7          	jalr	-892(ra) # 80004c4c <log_write>
      brelse(bp);
    80003fd0:	854a                	mv	a0,s2
    80003fd2:	00000097          	auipc	ra,0x0
    80003fd6:	9f6080e7          	jalr	-1546(ra) # 800039c8 <brelse>
      return iget(dev, inum);
    80003fda:	85da                	mv	a1,s6
    80003fdc:	8556                	mv	a0,s5
    80003fde:	00000097          	auipc	ra,0x0
    80003fe2:	d9c080e7          	jalr	-612(ra) # 80003d7a <iget>
    80003fe6:	bf5d                	j	80003f9c <ialloc+0x86>

0000000080003fe8 <iupdate>:
{
    80003fe8:	1101                	addi	sp,sp,-32
    80003fea:	ec06                	sd	ra,24(sp)
    80003fec:	e822                	sd	s0,16(sp)
    80003fee:	e426                	sd	s1,8(sp)
    80003ff0:	e04a                	sd	s2,0(sp)
    80003ff2:	1000                	addi	s0,sp,32
    80003ff4:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003ff6:	415c                	lw	a5,4(a0)
    80003ff8:	0047d79b          	srliw	a5,a5,0x4
    80003ffc:	0001d597          	auipc	a1,0x1d
    80004000:	7ec5a583          	lw	a1,2028(a1) # 800217e8 <sb+0x18>
    80004004:	9dbd                	addw	a1,a1,a5
    80004006:	4108                	lw	a0,0(a0)
    80004008:	00000097          	auipc	ra,0x0
    8000400c:	890080e7          	jalr	-1904(ra) # 80003898 <bread>
    80004010:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004012:	05850793          	addi	a5,a0,88
    80004016:	40c8                	lw	a0,4(s1)
    80004018:	893d                	andi	a0,a0,15
    8000401a:	051a                	slli	a0,a0,0x6
    8000401c:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    8000401e:	04449703          	lh	a4,68(s1)
    80004022:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80004026:	04649703          	lh	a4,70(s1)
    8000402a:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    8000402e:	04849703          	lh	a4,72(s1)
    80004032:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80004036:	04a49703          	lh	a4,74(s1)
    8000403a:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    8000403e:	44f8                	lw	a4,76(s1)
    80004040:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80004042:	03400613          	li	a2,52
    80004046:	05048593          	addi	a1,s1,80
    8000404a:	0531                	addi	a0,a0,12
    8000404c:	ffffd097          	auipc	ra,0xffffd
    80004050:	cfa080e7          	jalr	-774(ra) # 80000d46 <memmove>
  log_write(bp);
    80004054:	854a                	mv	a0,s2
    80004056:	00001097          	auipc	ra,0x1
    8000405a:	bf6080e7          	jalr	-1034(ra) # 80004c4c <log_write>
  brelse(bp);
    8000405e:	854a                	mv	a0,s2
    80004060:	00000097          	auipc	ra,0x0
    80004064:	968080e7          	jalr	-1688(ra) # 800039c8 <brelse>
}
    80004068:	60e2                	ld	ra,24(sp)
    8000406a:	6442                	ld	s0,16(sp)
    8000406c:	64a2                	ld	s1,8(sp)
    8000406e:	6902                	ld	s2,0(sp)
    80004070:	6105                	addi	sp,sp,32
    80004072:	8082                	ret

0000000080004074 <idup>:
{
    80004074:	1101                	addi	sp,sp,-32
    80004076:	ec06                	sd	ra,24(sp)
    80004078:	e822                	sd	s0,16(sp)
    8000407a:	e426                	sd	s1,8(sp)
    8000407c:	1000                	addi	s0,sp,32
    8000407e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004080:	0001d517          	auipc	a0,0x1d
    80004084:	77050513          	addi	a0,a0,1904 # 800217f0 <itable>
    80004088:	ffffd097          	auipc	ra,0xffffd
    8000408c:	b62080e7          	jalr	-1182(ra) # 80000bea <acquire>
  ip->ref++;
    80004090:	449c                	lw	a5,8(s1)
    80004092:	2785                	addiw	a5,a5,1
    80004094:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004096:	0001d517          	auipc	a0,0x1d
    8000409a:	75a50513          	addi	a0,a0,1882 # 800217f0 <itable>
    8000409e:	ffffd097          	auipc	ra,0xffffd
    800040a2:	c00080e7          	jalr	-1024(ra) # 80000c9e <release>
}
    800040a6:	8526                	mv	a0,s1
    800040a8:	60e2                	ld	ra,24(sp)
    800040aa:	6442                	ld	s0,16(sp)
    800040ac:	64a2                	ld	s1,8(sp)
    800040ae:	6105                	addi	sp,sp,32
    800040b0:	8082                	ret

00000000800040b2 <ilock>:
{
    800040b2:	1101                	addi	sp,sp,-32
    800040b4:	ec06                	sd	ra,24(sp)
    800040b6:	e822                	sd	s0,16(sp)
    800040b8:	e426                	sd	s1,8(sp)
    800040ba:	e04a                	sd	s2,0(sp)
    800040bc:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800040be:	c115                	beqz	a0,800040e2 <ilock+0x30>
    800040c0:	84aa                	mv	s1,a0
    800040c2:	451c                	lw	a5,8(a0)
    800040c4:	00f05f63          	blez	a5,800040e2 <ilock+0x30>
  acquiresleep(&ip->lock);
    800040c8:	0541                	addi	a0,a0,16
    800040ca:	00001097          	auipc	ra,0x1
    800040ce:	ca2080e7          	jalr	-862(ra) # 80004d6c <acquiresleep>
  if(ip->valid == 0){
    800040d2:	40bc                	lw	a5,64(s1)
    800040d4:	cf99                	beqz	a5,800040f2 <ilock+0x40>
}
    800040d6:	60e2                	ld	ra,24(sp)
    800040d8:	6442                	ld	s0,16(sp)
    800040da:	64a2                	ld	s1,8(sp)
    800040dc:	6902                	ld	s2,0(sp)
    800040de:	6105                	addi	sp,sp,32
    800040e0:	8082                	ret
    panic("ilock");
    800040e2:	00004517          	auipc	a0,0x4
    800040e6:	64e50513          	addi	a0,a0,1614 # 80008730 <syscalls+0x1a8>
    800040ea:	ffffc097          	auipc	ra,0xffffc
    800040ee:	45a080e7          	jalr	1114(ra) # 80000544 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800040f2:	40dc                	lw	a5,4(s1)
    800040f4:	0047d79b          	srliw	a5,a5,0x4
    800040f8:	0001d597          	auipc	a1,0x1d
    800040fc:	6f05a583          	lw	a1,1776(a1) # 800217e8 <sb+0x18>
    80004100:	9dbd                	addw	a1,a1,a5
    80004102:	4088                	lw	a0,0(s1)
    80004104:	fffff097          	auipc	ra,0xfffff
    80004108:	794080e7          	jalr	1940(ra) # 80003898 <bread>
    8000410c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000410e:	05850593          	addi	a1,a0,88
    80004112:	40dc                	lw	a5,4(s1)
    80004114:	8bbd                	andi	a5,a5,15
    80004116:	079a                	slli	a5,a5,0x6
    80004118:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000411a:	00059783          	lh	a5,0(a1)
    8000411e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80004122:	00259783          	lh	a5,2(a1)
    80004126:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000412a:	00459783          	lh	a5,4(a1)
    8000412e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80004132:	00659783          	lh	a5,6(a1)
    80004136:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000413a:	459c                	lw	a5,8(a1)
    8000413c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000413e:	03400613          	li	a2,52
    80004142:	05b1                	addi	a1,a1,12
    80004144:	05048513          	addi	a0,s1,80
    80004148:	ffffd097          	auipc	ra,0xffffd
    8000414c:	bfe080e7          	jalr	-1026(ra) # 80000d46 <memmove>
    brelse(bp);
    80004150:	854a                	mv	a0,s2
    80004152:	00000097          	auipc	ra,0x0
    80004156:	876080e7          	jalr	-1930(ra) # 800039c8 <brelse>
    ip->valid = 1;
    8000415a:	4785                	li	a5,1
    8000415c:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000415e:	04449783          	lh	a5,68(s1)
    80004162:	fbb5                	bnez	a5,800040d6 <ilock+0x24>
      panic("ilock: no type");
    80004164:	00004517          	auipc	a0,0x4
    80004168:	5d450513          	addi	a0,a0,1492 # 80008738 <syscalls+0x1b0>
    8000416c:	ffffc097          	auipc	ra,0xffffc
    80004170:	3d8080e7          	jalr	984(ra) # 80000544 <panic>

0000000080004174 <iunlock>:
{
    80004174:	1101                	addi	sp,sp,-32
    80004176:	ec06                	sd	ra,24(sp)
    80004178:	e822                	sd	s0,16(sp)
    8000417a:	e426                	sd	s1,8(sp)
    8000417c:	e04a                	sd	s2,0(sp)
    8000417e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80004180:	c905                	beqz	a0,800041b0 <iunlock+0x3c>
    80004182:	84aa                	mv	s1,a0
    80004184:	01050913          	addi	s2,a0,16
    80004188:	854a                	mv	a0,s2
    8000418a:	00001097          	auipc	ra,0x1
    8000418e:	c7c080e7          	jalr	-900(ra) # 80004e06 <holdingsleep>
    80004192:	cd19                	beqz	a0,800041b0 <iunlock+0x3c>
    80004194:	449c                	lw	a5,8(s1)
    80004196:	00f05d63          	blez	a5,800041b0 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000419a:	854a                	mv	a0,s2
    8000419c:	00001097          	auipc	ra,0x1
    800041a0:	c26080e7          	jalr	-986(ra) # 80004dc2 <releasesleep>
}
    800041a4:	60e2                	ld	ra,24(sp)
    800041a6:	6442                	ld	s0,16(sp)
    800041a8:	64a2                	ld	s1,8(sp)
    800041aa:	6902                	ld	s2,0(sp)
    800041ac:	6105                	addi	sp,sp,32
    800041ae:	8082                	ret
    panic("iunlock");
    800041b0:	00004517          	auipc	a0,0x4
    800041b4:	59850513          	addi	a0,a0,1432 # 80008748 <syscalls+0x1c0>
    800041b8:	ffffc097          	auipc	ra,0xffffc
    800041bc:	38c080e7          	jalr	908(ra) # 80000544 <panic>

00000000800041c0 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800041c0:	7179                	addi	sp,sp,-48
    800041c2:	f406                	sd	ra,40(sp)
    800041c4:	f022                	sd	s0,32(sp)
    800041c6:	ec26                	sd	s1,24(sp)
    800041c8:	e84a                	sd	s2,16(sp)
    800041ca:	e44e                	sd	s3,8(sp)
    800041cc:	e052                	sd	s4,0(sp)
    800041ce:	1800                	addi	s0,sp,48
    800041d0:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800041d2:	05050493          	addi	s1,a0,80
    800041d6:	08050913          	addi	s2,a0,128
    800041da:	a021                	j	800041e2 <itrunc+0x22>
    800041dc:	0491                	addi	s1,s1,4
    800041de:	01248d63          	beq	s1,s2,800041f8 <itrunc+0x38>
    if(ip->addrs[i]){
    800041e2:	408c                	lw	a1,0(s1)
    800041e4:	dde5                	beqz	a1,800041dc <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800041e6:	0009a503          	lw	a0,0(s3)
    800041ea:	00000097          	auipc	ra,0x0
    800041ee:	8f4080e7          	jalr	-1804(ra) # 80003ade <bfree>
      ip->addrs[i] = 0;
    800041f2:	0004a023          	sw	zero,0(s1)
    800041f6:	b7dd                	j	800041dc <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800041f8:	0809a583          	lw	a1,128(s3)
    800041fc:	e185                	bnez	a1,8000421c <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800041fe:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80004202:	854e                	mv	a0,s3
    80004204:	00000097          	auipc	ra,0x0
    80004208:	de4080e7          	jalr	-540(ra) # 80003fe8 <iupdate>
}
    8000420c:	70a2                	ld	ra,40(sp)
    8000420e:	7402                	ld	s0,32(sp)
    80004210:	64e2                	ld	s1,24(sp)
    80004212:	6942                	ld	s2,16(sp)
    80004214:	69a2                	ld	s3,8(sp)
    80004216:	6a02                	ld	s4,0(sp)
    80004218:	6145                	addi	sp,sp,48
    8000421a:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000421c:	0009a503          	lw	a0,0(s3)
    80004220:	fffff097          	auipc	ra,0xfffff
    80004224:	678080e7          	jalr	1656(ra) # 80003898 <bread>
    80004228:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000422a:	05850493          	addi	s1,a0,88
    8000422e:	45850913          	addi	s2,a0,1112
    80004232:	a811                	j	80004246 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80004234:	0009a503          	lw	a0,0(s3)
    80004238:	00000097          	auipc	ra,0x0
    8000423c:	8a6080e7          	jalr	-1882(ra) # 80003ade <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80004240:	0491                	addi	s1,s1,4
    80004242:	01248563          	beq	s1,s2,8000424c <itrunc+0x8c>
      if(a[j])
    80004246:	408c                	lw	a1,0(s1)
    80004248:	dde5                	beqz	a1,80004240 <itrunc+0x80>
    8000424a:	b7ed                	j	80004234 <itrunc+0x74>
    brelse(bp);
    8000424c:	8552                	mv	a0,s4
    8000424e:	fffff097          	auipc	ra,0xfffff
    80004252:	77a080e7          	jalr	1914(ra) # 800039c8 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80004256:	0809a583          	lw	a1,128(s3)
    8000425a:	0009a503          	lw	a0,0(s3)
    8000425e:	00000097          	auipc	ra,0x0
    80004262:	880080e7          	jalr	-1920(ra) # 80003ade <bfree>
    ip->addrs[NDIRECT] = 0;
    80004266:	0809a023          	sw	zero,128(s3)
    8000426a:	bf51                	j	800041fe <itrunc+0x3e>

000000008000426c <iput>:
{
    8000426c:	1101                	addi	sp,sp,-32
    8000426e:	ec06                	sd	ra,24(sp)
    80004270:	e822                	sd	s0,16(sp)
    80004272:	e426                	sd	s1,8(sp)
    80004274:	e04a                	sd	s2,0(sp)
    80004276:	1000                	addi	s0,sp,32
    80004278:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000427a:	0001d517          	auipc	a0,0x1d
    8000427e:	57650513          	addi	a0,a0,1398 # 800217f0 <itable>
    80004282:	ffffd097          	auipc	ra,0xffffd
    80004286:	968080e7          	jalr	-1688(ra) # 80000bea <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000428a:	4498                	lw	a4,8(s1)
    8000428c:	4785                	li	a5,1
    8000428e:	02f70363          	beq	a4,a5,800042b4 <iput+0x48>
  ip->ref--;
    80004292:	449c                	lw	a5,8(s1)
    80004294:	37fd                	addiw	a5,a5,-1
    80004296:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004298:	0001d517          	auipc	a0,0x1d
    8000429c:	55850513          	addi	a0,a0,1368 # 800217f0 <itable>
    800042a0:	ffffd097          	auipc	ra,0xffffd
    800042a4:	9fe080e7          	jalr	-1538(ra) # 80000c9e <release>
}
    800042a8:	60e2                	ld	ra,24(sp)
    800042aa:	6442                	ld	s0,16(sp)
    800042ac:	64a2                	ld	s1,8(sp)
    800042ae:	6902                	ld	s2,0(sp)
    800042b0:	6105                	addi	sp,sp,32
    800042b2:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800042b4:	40bc                	lw	a5,64(s1)
    800042b6:	dff1                	beqz	a5,80004292 <iput+0x26>
    800042b8:	04a49783          	lh	a5,74(s1)
    800042bc:	fbf9                	bnez	a5,80004292 <iput+0x26>
    acquiresleep(&ip->lock);
    800042be:	01048913          	addi	s2,s1,16
    800042c2:	854a                	mv	a0,s2
    800042c4:	00001097          	auipc	ra,0x1
    800042c8:	aa8080e7          	jalr	-1368(ra) # 80004d6c <acquiresleep>
    release(&itable.lock);
    800042cc:	0001d517          	auipc	a0,0x1d
    800042d0:	52450513          	addi	a0,a0,1316 # 800217f0 <itable>
    800042d4:	ffffd097          	auipc	ra,0xffffd
    800042d8:	9ca080e7          	jalr	-1590(ra) # 80000c9e <release>
    itrunc(ip);
    800042dc:	8526                	mv	a0,s1
    800042de:	00000097          	auipc	ra,0x0
    800042e2:	ee2080e7          	jalr	-286(ra) # 800041c0 <itrunc>
    ip->type = 0;
    800042e6:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800042ea:	8526                	mv	a0,s1
    800042ec:	00000097          	auipc	ra,0x0
    800042f0:	cfc080e7          	jalr	-772(ra) # 80003fe8 <iupdate>
    ip->valid = 0;
    800042f4:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800042f8:	854a                	mv	a0,s2
    800042fa:	00001097          	auipc	ra,0x1
    800042fe:	ac8080e7          	jalr	-1336(ra) # 80004dc2 <releasesleep>
    acquire(&itable.lock);
    80004302:	0001d517          	auipc	a0,0x1d
    80004306:	4ee50513          	addi	a0,a0,1262 # 800217f0 <itable>
    8000430a:	ffffd097          	auipc	ra,0xffffd
    8000430e:	8e0080e7          	jalr	-1824(ra) # 80000bea <acquire>
    80004312:	b741                	j	80004292 <iput+0x26>

0000000080004314 <iunlockput>:
{
    80004314:	1101                	addi	sp,sp,-32
    80004316:	ec06                	sd	ra,24(sp)
    80004318:	e822                	sd	s0,16(sp)
    8000431a:	e426                	sd	s1,8(sp)
    8000431c:	1000                	addi	s0,sp,32
    8000431e:	84aa                	mv	s1,a0
  iunlock(ip);
    80004320:	00000097          	auipc	ra,0x0
    80004324:	e54080e7          	jalr	-428(ra) # 80004174 <iunlock>
  iput(ip);
    80004328:	8526                	mv	a0,s1
    8000432a:	00000097          	auipc	ra,0x0
    8000432e:	f42080e7          	jalr	-190(ra) # 8000426c <iput>
}
    80004332:	60e2                	ld	ra,24(sp)
    80004334:	6442                	ld	s0,16(sp)
    80004336:	64a2                	ld	s1,8(sp)
    80004338:	6105                	addi	sp,sp,32
    8000433a:	8082                	ret

000000008000433c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000433c:	1141                	addi	sp,sp,-16
    8000433e:	e422                	sd	s0,8(sp)
    80004340:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004342:	411c                	lw	a5,0(a0)
    80004344:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004346:	415c                	lw	a5,4(a0)
    80004348:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000434a:	04451783          	lh	a5,68(a0)
    8000434e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004352:	04a51783          	lh	a5,74(a0)
    80004356:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000435a:	04c56783          	lwu	a5,76(a0)
    8000435e:	e99c                	sd	a5,16(a1)
}
    80004360:	6422                	ld	s0,8(sp)
    80004362:	0141                	addi	sp,sp,16
    80004364:	8082                	ret

0000000080004366 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004366:	457c                	lw	a5,76(a0)
    80004368:	0ed7e963          	bltu	a5,a3,8000445a <readi+0xf4>
{
    8000436c:	7159                	addi	sp,sp,-112
    8000436e:	f486                	sd	ra,104(sp)
    80004370:	f0a2                	sd	s0,96(sp)
    80004372:	eca6                	sd	s1,88(sp)
    80004374:	e8ca                	sd	s2,80(sp)
    80004376:	e4ce                	sd	s3,72(sp)
    80004378:	e0d2                	sd	s4,64(sp)
    8000437a:	fc56                	sd	s5,56(sp)
    8000437c:	f85a                	sd	s6,48(sp)
    8000437e:	f45e                	sd	s7,40(sp)
    80004380:	f062                	sd	s8,32(sp)
    80004382:	ec66                	sd	s9,24(sp)
    80004384:	e86a                	sd	s10,16(sp)
    80004386:	e46e                	sd	s11,8(sp)
    80004388:	1880                	addi	s0,sp,112
    8000438a:	8b2a                	mv	s6,a0
    8000438c:	8bae                	mv	s7,a1
    8000438e:	8a32                	mv	s4,a2
    80004390:	84b6                	mv	s1,a3
    80004392:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80004394:	9f35                	addw	a4,a4,a3
    return 0;
    80004396:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004398:	0ad76063          	bltu	a4,a3,80004438 <readi+0xd2>
  if(off + n > ip->size)
    8000439c:	00e7f463          	bgeu	a5,a4,800043a4 <readi+0x3e>
    n = ip->size - off;
    800043a0:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800043a4:	0a0a8963          	beqz	s5,80004456 <readi+0xf0>
    800043a8:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800043aa:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800043ae:	5c7d                	li	s8,-1
    800043b0:	a82d                	j	800043ea <readi+0x84>
    800043b2:	020d1d93          	slli	s11,s10,0x20
    800043b6:	020ddd93          	srli	s11,s11,0x20
    800043ba:	05890613          	addi	a2,s2,88
    800043be:	86ee                	mv	a3,s11
    800043c0:	963a                	add	a2,a2,a4
    800043c2:	85d2                	mv	a1,s4
    800043c4:	855e                	mv	a0,s7
    800043c6:	fffff097          	auipc	ra,0xfffff
    800043ca:	854080e7          	jalr	-1964(ra) # 80002c1a <either_copyout>
    800043ce:	05850d63          	beq	a0,s8,80004428 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800043d2:	854a                	mv	a0,s2
    800043d4:	fffff097          	auipc	ra,0xfffff
    800043d8:	5f4080e7          	jalr	1524(ra) # 800039c8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800043dc:	013d09bb          	addw	s3,s10,s3
    800043e0:	009d04bb          	addw	s1,s10,s1
    800043e4:	9a6e                	add	s4,s4,s11
    800043e6:	0559f763          	bgeu	s3,s5,80004434 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    800043ea:	00a4d59b          	srliw	a1,s1,0xa
    800043ee:	855a                	mv	a0,s6
    800043f0:	00000097          	auipc	ra,0x0
    800043f4:	8a2080e7          	jalr	-1886(ra) # 80003c92 <bmap>
    800043f8:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800043fc:	cd85                	beqz	a1,80004434 <readi+0xce>
    bp = bread(ip->dev, addr);
    800043fe:	000b2503          	lw	a0,0(s6)
    80004402:	fffff097          	auipc	ra,0xfffff
    80004406:	496080e7          	jalr	1174(ra) # 80003898 <bread>
    8000440a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000440c:	3ff4f713          	andi	a4,s1,1023
    80004410:	40ec87bb          	subw	a5,s9,a4
    80004414:	413a86bb          	subw	a3,s5,s3
    80004418:	8d3e                	mv	s10,a5
    8000441a:	2781                	sext.w	a5,a5
    8000441c:	0006861b          	sext.w	a2,a3
    80004420:	f8f679e3          	bgeu	a2,a5,800043b2 <readi+0x4c>
    80004424:	8d36                	mv	s10,a3
    80004426:	b771                	j	800043b2 <readi+0x4c>
      brelse(bp);
    80004428:	854a                	mv	a0,s2
    8000442a:	fffff097          	auipc	ra,0xfffff
    8000442e:	59e080e7          	jalr	1438(ra) # 800039c8 <brelse>
      tot = -1;
    80004432:	59fd                	li	s3,-1
  }
  return tot;
    80004434:	0009851b          	sext.w	a0,s3
}
    80004438:	70a6                	ld	ra,104(sp)
    8000443a:	7406                	ld	s0,96(sp)
    8000443c:	64e6                	ld	s1,88(sp)
    8000443e:	6946                	ld	s2,80(sp)
    80004440:	69a6                	ld	s3,72(sp)
    80004442:	6a06                	ld	s4,64(sp)
    80004444:	7ae2                	ld	s5,56(sp)
    80004446:	7b42                	ld	s6,48(sp)
    80004448:	7ba2                	ld	s7,40(sp)
    8000444a:	7c02                	ld	s8,32(sp)
    8000444c:	6ce2                	ld	s9,24(sp)
    8000444e:	6d42                	ld	s10,16(sp)
    80004450:	6da2                	ld	s11,8(sp)
    80004452:	6165                	addi	sp,sp,112
    80004454:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004456:	89d6                	mv	s3,s5
    80004458:	bff1                	j	80004434 <readi+0xce>
    return 0;
    8000445a:	4501                	li	a0,0
}
    8000445c:	8082                	ret

000000008000445e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000445e:	457c                	lw	a5,76(a0)
    80004460:	10d7e863          	bltu	a5,a3,80004570 <writei+0x112>
{
    80004464:	7159                	addi	sp,sp,-112
    80004466:	f486                	sd	ra,104(sp)
    80004468:	f0a2                	sd	s0,96(sp)
    8000446a:	eca6                	sd	s1,88(sp)
    8000446c:	e8ca                	sd	s2,80(sp)
    8000446e:	e4ce                	sd	s3,72(sp)
    80004470:	e0d2                	sd	s4,64(sp)
    80004472:	fc56                	sd	s5,56(sp)
    80004474:	f85a                	sd	s6,48(sp)
    80004476:	f45e                	sd	s7,40(sp)
    80004478:	f062                	sd	s8,32(sp)
    8000447a:	ec66                	sd	s9,24(sp)
    8000447c:	e86a                	sd	s10,16(sp)
    8000447e:	e46e                	sd	s11,8(sp)
    80004480:	1880                	addi	s0,sp,112
    80004482:	8aaa                	mv	s5,a0
    80004484:	8bae                	mv	s7,a1
    80004486:	8a32                	mv	s4,a2
    80004488:	8936                	mv	s2,a3
    8000448a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000448c:	00e687bb          	addw	a5,a3,a4
    80004490:	0ed7e263          	bltu	a5,a3,80004574 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004494:	00043737          	lui	a4,0x43
    80004498:	0ef76063          	bltu	a4,a5,80004578 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000449c:	0c0b0863          	beqz	s6,8000456c <writei+0x10e>
    800044a0:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800044a2:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800044a6:	5c7d                	li	s8,-1
    800044a8:	a091                	j	800044ec <writei+0x8e>
    800044aa:	020d1d93          	slli	s11,s10,0x20
    800044ae:	020ddd93          	srli	s11,s11,0x20
    800044b2:	05848513          	addi	a0,s1,88
    800044b6:	86ee                	mv	a3,s11
    800044b8:	8652                	mv	a2,s4
    800044ba:	85de                	mv	a1,s7
    800044bc:	953a                	add	a0,a0,a4
    800044be:	ffffe097          	auipc	ra,0xffffe
    800044c2:	7b2080e7          	jalr	1970(ra) # 80002c70 <either_copyin>
    800044c6:	07850263          	beq	a0,s8,8000452a <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800044ca:	8526                	mv	a0,s1
    800044cc:	00000097          	auipc	ra,0x0
    800044d0:	780080e7          	jalr	1920(ra) # 80004c4c <log_write>
    brelse(bp);
    800044d4:	8526                	mv	a0,s1
    800044d6:	fffff097          	auipc	ra,0xfffff
    800044da:	4f2080e7          	jalr	1266(ra) # 800039c8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800044de:	013d09bb          	addw	s3,s10,s3
    800044e2:	012d093b          	addw	s2,s10,s2
    800044e6:	9a6e                	add	s4,s4,s11
    800044e8:	0569f663          	bgeu	s3,s6,80004534 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    800044ec:	00a9559b          	srliw	a1,s2,0xa
    800044f0:	8556                	mv	a0,s5
    800044f2:	fffff097          	auipc	ra,0xfffff
    800044f6:	7a0080e7          	jalr	1952(ra) # 80003c92 <bmap>
    800044fa:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800044fe:	c99d                	beqz	a1,80004534 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80004500:	000aa503          	lw	a0,0(s5)
    80004504:	fffff097          	auipc	ra,0xfffff
    80004508:	394080e7          	jalr	916(ra) # 80003898 <bread>
    8000450c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000450e:	3ff97713          	andi	a4,s2,1023
    80004512:	40ec87bb          	subw	a5,s9,a4
    80004516:	413b06bb          	subw	a3,s6,s3
    8000451a:	8d3e                	mv	s10,a5
    8000451c:	2781                	sext.w	a5,a5
    8000451e:	0006861b          	sext.w	a2,a3
    80004522:	f8f674e3          	bgeu	a2,a5,800044aa <writei+0x4c>
    80004526:	8d36                	mv	s10,a3
    80004528:	b749                	j	800044aa <writei+0x4c>
      brelse(bp);
    8000452a:	8526                	mv	a0,s1
    8000452c:	fffff097          	auipc	ra,0xfffff
    80004530:	49c080e7          	jalr	1180(ra) # 800039c8 <brelse>
  }

  if(off > ip->size)
    80004534:	04caa783          	lw	a5,76(s5)
    80004538:	0127f463          	bgeu	a5,s2,80004540 <writei+0xe2>
    ip->size = off;
    8000453c:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004540:	8556                	mv	a0,s5
    80004542:	00000097          	auipc	ra,0x0
    80004546:	aa6080e7          	jalr	-1370(ra) # 80003fe8 <iupdate>

  return tot;
    8000454a:	0009851b          	sext.w	a0,s3
}
    8000454e:	70a6                	ld	ra,104(sp)
    80004550:	7406                	ld	s0,96(sp)
    80004552:	64e6                	ld	s1,88(sp)
    80004554:	6946                	ld	s2,80(sp)
    80004556:	69a6                	ld	s3,72(sp)
    80004558:	6a06                	ld	s4,64(sp)
    8000455a:	7ae2                	ld	s5,56(sp)
    8000455c:	7b42                	ld	s6,48(sp)
    8000455e:	7ba2                	ld	s7,40(sp)
    80004560:	7c02                	ld	s8,32(sp)
    80004562:	6ce2                	ld	s9,24(sp)
    80004564:	6d42                	ld	s10,16(sp)
    80004566:	6da2                	ld	s11,8(sp)
    80004568:	6165                	addi	sp,sp,112
    8000456a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000456c:	89da                	mv	s3,s6
    8000456e:	bfc9                	j	80004540 <writei+0xe2>
    return -1;
    80004570:	557d                	li	a0,-1
}
    80004572:	8082                	ret
    return -1;
    80004574:	557d                	li	a0,-1
    80004576:	bfe1                	j	8000454e <writei+0xf0>
    return -1;
    80004578:	557d                	li	a0,-1
    8000457a:	bfd1                	j	8000454e <writei+0xf0>

000000008000457c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000457c:	1141                	addi	sp,sp,-16
    8000457e:	e406                	sd	ra,8(sp)
    80004580:	e022                	sd	s0,0(sp)
    80004582:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004584:	4639                	li	a2,14
    80004586:	ffffd097          	auipc	ra,0xffffd
    8000458a:	838080e7          	jalr	-1992(ra) # 80000dbe <strncmp>
}
    8000458e:	60a2                	ld	ra,8(sp)
    80004590:	6402                	ld	s0,0(sp)
    80004592:	0141                	addi	sp,sp,16
    80004594:	8082                	ret

0000000080004596 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004596:	7139                	addi	sp,sp,-64
    80004598:	fc06                	sd	ra,56(sp)
    8000459a:	f822                	sd	s0,48(sp)
    8000459c:	f426                	sd	s1,40(sp)
    8000459e:	f04a                	sd	s2,32(sp)
    800045a0:	ec4e                	sd	s3,24(sp)
    800045a2:	e852                	sd	s4,16(sp)
    800045a4:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800045a6:	04451703          	lh	a4,68(a0)
    800045aa:	4785                	li	a5,1
    800045ac:	00f71a63          	bne	a4,a5,800045c0 <dirlookup+0x2a>
    800045b0:	892a                	mv	s2,a0
    800045b2:	89ae                	mv	s3,a1
    800045b4:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800045b6:	457c                	lw	a5,76(a0)
    800045b8:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800045ba:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800045bc:	e79d                	bnez	a5,800045ea <dirlookup+0x54>
    800045be:	a8a5                	j	80004636 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800045c0:	00004517          	auipc	a0,0x4
    800045c4:	19050513          	addi	a0,a0,400 # 80008750 <syscalls+0x1c8>
    800045c8:	ffffc097          	auipc	ra,0xffffc
    800045cc:	f7c080e7          	jalr	-132(ra) # 80000544 <panic>
      panic("dirlookup read");
    800045d0:	00004517          	auipc	a0,0x4
    800045d4:	19850513          	addi	a0,a0,408 # 80008768 <syscalls+0x1e0>
    800045d8:	ffffc097          	auipc	ra,0xffffc
    800045dc:	f6c080e7          	jalr	-148(ra) # 80000544 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800045e0:	24c1                	addiw	s1,s1,16
    800045e2:	04c92783          	lw	a5,76(s2)
    800045e6:	04f4f763          	bgeu	s1,a5,80004634 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800045ea:	4741                	li	a4,16
    800045ec:	86a6                	mv	a3,s1
    800045ee:	fc040613          	addi	a2,s0,-64
    800045f2:	4581                	li	a1,0
    800045f4:	854a                	mv	a0,s2
    800045f6:	00000097          	auipc	ra,0x0
    800045fa:	d70080e7          	jalr	-656(ra) # 80004366 <readi>
    800045fe:	47c1                	li	a5,16
    80004600:	fcf518e3          	bne	a0,a5,800045d0 <dirlookup+0x3a>
    if(de.inum == 0)
    80004604:	fc045783          	lhu	a5,-64(s0)
    80004608:	dfe1                	beqz	a5,800045e0 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000460a:	fc240593          	addi	a1,s0,-62
    8000460e:	854e                	mv	a0,s3
    80004610:	00000097          	auipc	ra,0x0
    80004614:	f6c080e7          	jalr	-148(ra) # 8000457c <namecmp>
    80004618:	f561                	bnez	a0,800045e0 <dirlookup+0x4a>
      if(poff)
    8000461a:	000a0463          	beqz	s4,80004622 <dirlookup+0x8c>
        *poff = off;
    8000461e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004622:	fc045583          	lhu	a1,-64(s0)
    80004626:	00092503          	lw	a0,0(s2)
    8000462a:	fffff097          	auipc	ra,0xfffff
    8000462e:	750080e7          	jalr	1872(ra) # 80003d7a <iget>
    80004632:	a011                	j	80004636 <dirlookup+0xa0>
  return 0;
    80004634:	4501                	li	a0,0
}
    80004636:	70e2                	ld	ra,56(sp)
    80004638:	7442                	ld	s0,48(sp)
    8000463a:	74a2                	ld	s1,40(sp)
    8000463c:	7902                	ld	s2,32(sp)
    8000463e:	69e2                	ld	s3,24(sp)
    80004640:	6a42                	ld	s4,16(sp)
    80004642:	6121                	addi	sp,sp,64
    80004644:	8082                	ret

0000000080004646 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004646:	711d                	addi	sp,sp,-96
    80004648:	ec86                	sd	ra,88(sp)
    8000464a:	e8a2                	sd	s0,80(sp)
    8000464c:	e4a6                	sd	s1,72(sp)
    8000464e:	e0ca                	sd	s2,64(sp)
    80004650:	fc4e                	sd	s3,56(sp)
    80004652:	f852                	sd	s4,48(sp)
    80004654:	f456                	sd	s5,40(sp)
    80004656:	f05a                	sd	s6,32(sp)
    80004658:	ec5e                	sd	s7,24(sp)
    8000465a:	e862                	sd	s8,16(sp)
    8000465c:	e466                	sd	s9,8(sp)
    8000465e:	1080                	addi	s0,sp,96
    80004660:	84aa                	mv	s1,a0
    80004662:	8b2e                	mv	s6,a1
    80004664:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004666:	00054703          	lbu	a4,0(a0)
    8000466a:	02f00793          	li	a5,47
    8000466e:	02f70363          	beq	a4,a5,80004694 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004672:	ffffd097          	auipc	ra,0xffffd
    80004676:	578080e7          	jalr	1400(ra) # 80001bea <myproc>
    8000467a:	15853503          	ld	a0,344(a0)
    8000467e:	00000097          	auipc	ra,0x0
    80004682:	9f6080e7          	jalr	-1546(ra) # 80004074 <idup>
    80004686:	89aa                	mv	s3,a0
  while(*path == '/')
    80004688:	02f00913          	li	s2,47
  len = path - s;
    8000468c:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    8000468e:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004690:	4c05                	li	s8,1
    80004692:	a865                	j	8000474a <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80004694:	4585                	li	a1,1
    80004696:	4505                	li	a0,1
    80004698:	fffff097          	auipc	ra,0xfffff
    8000469c:	6e2080e7          	jalr	1762(ra) # 80003d7a <iget>
    800046a0:	89aa                	mv	s3,a0
    800046a2:	b7dd                	j	80004688 <namex+0x42>
      iunlockput(ip);
    800046a4:	854e                	mv	a0,s3
    800046a6:	00000097          	auipc	ra,0x0
    800046aa:	c6e080e7          	jalr	-914(ra) # 80004314 <iunlockput>
      return 0;
    800046ae:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800046b0:	854e                	mv	a0,s3
    800046b2:	60e6                	ld	ra,88(sp)
    800046b4:	6446                	ld	s0,80(sp)
    800046b6:	64a6                	ld	s1,72(sp)
    800046b8:	6906                	ld	s2,64(sp)
    800046ba:	79e2                	ld	s3,56(sp)
    800046bc:	7a42                	ld	s4,48(sp)
    800046be:	7aa2                	ld	s5,40(sp)
    800046c0:	7b02                	ld	s6,32(sp)
    800046c2:	6be2                	ld	s7,24(sp)
    800046c4:	6c42                	ld	s8,16(sp)
    800046c6:	6ca2                	ld	s9,8(sp)
    800046c8:	6125                	addi	sp,sp,96
    800046ca:	8082                	ret
      iunlock(ip);
    800046cc:	854e                	mv	a0,s3
    800046ce:	00000097          	auipc	ra,0x0
    800046d2:	aa6080e7          	jalr	-1370(ra) # 80004174 <iunlock>
      return ip;
    800046d6:	bfe9                	j	800046b0 <namex+0x6a>
      iunlockput(ip);
    800046d8:	854e                	mv	a0,s3
    800046da:	00000097          	auipc	ra,0x0
    800046de:	c3a080e7          	jalr	-966(ra) # 80004314 <iunlockput>
      return 0;
    800046e2:	89d2                	mv	s3,s4
    800046e4:	b7f1                	j	800046b0 <namex+0x6a>
  len = path - s;
    800046e6:	40b48633          	sub	a2,s1,a1
    800046ea:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    800046ee:	094cd463          	bge	s9,s4,80004776 <namex+0x130>
    memmove(name, s, DIRSIZ);
    800046f2:	4639                	li	a2,14
    800046f4:	8556                	mv	a0,s5
    800046f6:	ffffc097          	auipc	ra,0xffffc
    800046fa:	650080e7          	jalr	1616(ra) # 80000d46 <memmove>
  while(*path == '/')
    800046fe:	0004c783          	lbu	a5,0(s1)
    80004702:	01279763          	bne	a5,s2,80004710 <namex+0xca>
    path++;
    80004706:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004708:	0004c783          	lbu	a5,0(s1)
    8000470c:	ff278de3          	beq	a5,s2,80004706 <namex+0xc0>
    ilock(ip);
    80004710:	854e                	mv	a0,s3
    80004712:	00000097          	auipc	ra,0x0
    80004716:	9a0080e7          	jalr	-1632(ra) # 800040b2 <ilock>
    if(ip->type != T_DIR){
    8000471a:	04499783          	lh	a5,68(s3)
    8000471e:	f98793e3          	bne	a5,s8,800046a4 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004722:	000b0563          	beqz	s6,8000472c <namex+0xe6>
    80004726:	0004c783          	lbu	a5,0(s1)
    8000472a:	d3cd                	beqz	a5,800046cc <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000472c:	865e                	mv	a2,s7
    8000472e:	85d6                	mv	a1,s5
    80004730:	854e                	mv	a0,s3
    80004732:	00000097          	auipc	ra,0x0
    80004736:	e64080e7          	jalr	-412(ra) # 80004596 <dirlookup>
    8000473a:	8a2a                	mv	s4,a0
    8000473c:	dd51                	beqz	a0,800046d8 <namex+0x92>
    iunlockput(ip);
    8000473e:	854e                	mv	a0,s3
    80004740:	00000097          	auipc	ra,0x0
    80004744:	bd4080e7          	jalr	-1068(ra) # 80004314 <iunlockput>
    ip = next;
    80004748:	89d2                	mv	s3,s4
  while(*path == '/')
    8000474a:	0004c783          	lbu	a5,0(s1)
    8000474e:	05279763          	bne	a5,s2,8000479c <namex+0x156>
    path++;
    80004752:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004754:	0004c783          	lbu	a5,0(s1)
    80004758:	ff278de3          	beq	a5,s2,80004752 <namex+0x10c>
  if(*path == 0)
    8000475c:	c79d                	beqz	a5,8000478a <namex+0x144>
    path++;
    8000475e:	85a6                	mv	a1,s1
  len = path - s;
    80004760:	8a5e                	mv	s4,s7
    80004762:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80004764:	01278963          	beq	a5,s2,80004776 <namex+0x130>
    80004768:	dfbd                	beqz	a5,800046e6 <namex+0xa0>
    path++;
    8000476a:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000476c:	0004c783          	lbu	a5,0(s1)
    80004770:	ff279ce3          	bne	a5,s2,80004768 <namex+0x122>
    80004774:	bf8d                	j	800046e6 <namex+0xa0>
    memmove(name, s, len);
    80004776:	2601                	sext.w	a2,a2
    80004778:	8556                	mv	a0,s5
    8000477a:	ffffc097          	auipc	ra,0xffffc
    8000477e:	5cc080e7          	jalr	1484(ra) # 80000d46 <memmove>
    name[len] = 0;
    80004782:	9a56                	add	s4,s4,s5
    80004784:	000a0023          	sb	zero,0(s4)
    80004788:	bf9d                	j	800046fe <namex+0xb8>
  if(nameiparent){
    8000478a:	f20b03e3          	beqz	s6,800046b0 <namex+0x6a>
    iput(ip);
    8000478e:	854e                	mv	a0,s3
    80004790:	00000097          	auipc	ra,0x0
    80004794:	adc080e7          	jalr	-1316(ra) # 8000426c <iput>
    return 0;
    80004798:	4981                	li	s3,0
    8000479a:	bf19                	j	800046b0 <namex+0x6a>
  if(*path == 0)
    8000479c:	d7fd                	beqz	a5,8000478a <namex+0x144>
  while(*path != '/' && *path != 0)
    8000479e:	0004c783          	lbu	a5,0(s1)
    800047a2:	85a6                	mv	a1,s1
    800047a4:	b7d1                	j	80004768 <namex+0x122>

00000000800047a6 <dirlink>:
{
    800047a6:	7139                	addi	sp,sp,-64
    800047a8:	fc06                	sd	ra,56(sp)
    800047aa:	f822                	sd	s0,48(sp)
    800047ac:	f426                	sd	s1,40(sp)
    800047ae:	f04a                	sd	s2,32(sp)
    800047b0:	ec4e                	sd	s3,24(sp)
    800047b2:	e852                	sd	s4,16(sp)
    800047b4:	0080                	addi	s0,sp,64
    800047b6:	892a                	mv	s2,a0
    800047b8:	8a2e                	mv	s4,a1
    800047ba:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800047bc:	4601                	li	a2,0
    800047be:	00000097          	auipc	ra,0x0
    800047c2:	dd8080e7          	jalr	-552(ra) # 80004596 <dirlookup>
    800047c6:	e93d                	bnez	a0,8000483c <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800047c8:	04c92483          	lw	s1,76(s2)
    800047cc:	c49d                	beqz	s1,800047fa <dirlink+0x54>
    800047ce:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800047d0:	4741                	li	a4,16
    800047d2:	86a6                	mv	a3,s1
    800047d4:	fc040613          	addi	a2,s0,-64
    800047d8:	4581                	li	a1,0
    800047da:	854a                	mv	a0,s2
    800047dc:	00000097          	auipc	ra,0x0
    800047e0:	b8a080e7          	jalr	-1142(ra) # 80004366 <readi>
    800047e4:	47c1                	li	a5,16
    800047e6:	06f51163          	bne	a0,a5,80004848 <dirlink+0xa2>
    if(de.inum == 0)
    800047ea:	fc045783          	lhu	a5,-64(s0)
    800047ee:	c791                	beqz	a5,800047fa <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800047f0:	24c1                	addiw	s1,s1,16
    800047f2:	04c92783          	lw	a5,76(s2)
    800047f6:	fcf4ede3          	bltu	s1,a5,800047d0 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800047fa:	4639                	li	a2,14
    800047fc:	85d2                	mv	a1,s4
    800047fe:	fc240513          	addi	a0,s0,-62
    80004802:	ffffc097          	auipc	ra,0xffffc
    80004806:	5f8080e7          	jalr	1528(ra) # 80000dfa <strncpy>
  de.inum = inum;
    8000480a:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000480e:	4741                	li	a4,16
    80004810:	86a6                	mv	a3,s1
    80004812:	fc040613          	addi	a2,s0,-64
    80004816:	4581                	li	a1,0
    80004818:	854a                	mv	a0,s2
    8000481a:	00000097          	auipc	ra,0x0
    8000481e:	c44080e7          	jalr	-956(ra) # 8000445e <writei>
    80004822:	1541                	addi	a0,a0,-16
    80004824:	00a03533          	snez	a0,a0
    80004828:	40a00533          	neg	a0,a0
}
    8000482c:	70e2                	ld	ra,56(sp)
    8000482e:	7442                	ld	s0,48(sp)
    80004830:	74a2                	ld	s1,40(sp)
    80004832:	7902                	ld	s2,32(sp)
    80004834:	69e2                	ld	s3,24(sp)
    80004836:	6a42                	ld	s4,16(sp)
    80004838:	6121                	addi	sp,sp,64
    8000483a:	8082                	ret
    iput(ip);
    8000483c:	00000097          	auipc	ra,0x0
    80004840:	a30080e7          	jalr	-1488(ra) # 8000426c <iput>
    return -1;
    80004844:	557d                	li	a0,-1
    80004846:	b7dd                	j	8000482c <dirlink+0x86>
      panic("dirlink read");
    80004848:	00004517          	auipc	a0,0x4
    8000484c:	f3050513          	addi	a0,a0,-208 # 80008778 <syscalls+0x1f0>
    80004850:	ffffc097          	auipc	ra,0xffffc
    80004854:	cf4080e7          	jalr	-780(ra) # 80000544 <panic>

0000000080004858 <namei>:

struct inode*
namei(char *path)
{
    80004858:	1101                	addi	sp,sp,-32
    8000485a:	ec06                	sd	ra,24(sp)
    8000485c:	e822                	sd	s0,16(sp)
    8000485e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004860:	fe040613          	addi	a2,s0,-32
    80004864:	4581                	li	a1,0
    80004866:	00000097          	auipc	ra,0x0
    8000486a:	de0080e7          	jalr	-544(ra) # 80004646 <namex>
}
    8000486e:	60e2                	ld	ra,24(sp)
    80004870:	6442                	ld	s0,16(sp)
    80004872:	6105                	addi	sp,sp,32
    80004874:	8082                	ret

0000000080004876 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004876:	1141                	addi	sp,sp,-16
    80004878:	e406                	sd	ra,8(sp)
    8000487a:	e022                	sd	s0,0(sp)
    8000487c:	0800                	addi	s0,sp,16
    8000487e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004880:	4585                	li	a1,1
    80004882:	00000097          	auipc	ra,0x0
    80004886:	dc4080e7          	jalr	-572(ra) # 80004646 <namex>
}
    8000488a:	60a2                	ld	ra,8(sp)
    8000488c:	6402                	ld	s0,0(sp)
    8000488e:	0141                	addi	sp,sp,16
    80004890:	8082                	ret

0000000080004892 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004892:	1101                	addi	sp,sp,-32
    80004894:	ec06                	sd	ra,24(sp)
    80004896:	e822                	sd	s0,16(sp)
    80004898:	e426                	sd	s1,8(sp)
    8000489a:	e04a                	sd	s2,0(sp)
    8000489c:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000489e:	0001f917          	auipc	s2,0x1f
    800048a2:	9fa90913          	addi	s2,s2,-1542 # 80023298 <log>
    800048a6:	01892583          	lw	a1,24(s2)
    800048aa:	02892503          	lw	a0,40(s2)
    800048ae:	fffff097          	auipc	ra,0xfffff
    800048b2:	fea080e7          	jalr	-22(ra) # 80003898 <bread>
    800048b6:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800048b8:	02c92683          	lw	a3,44(s2)
    800048bc:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800048be:	02d05763          	blez	a3,800048ec <write_head+0x5a>
    800048c2:	0001f797          	auipc	a5,0x1f
    800048c6:	a0678793          	addi	a5,a5,-1530 # 800232c8 <log+0x30>
    800048ca:	05c50713          	addi	a4,a0,92
    800048ce:	36fd                	addiw	a3,a3,-1
    800048d0:	1682                	slli	a3,a3,0x20
    800048d2:	9281                	srli	a3,a3,0x20
    800048d4:	068a                	slli	a3,a3,0x2
    800048d6:	0001f617          	auipc	a2,0x1f
    800048da:	9f660613          	addi	a2,a2,-1546 # 800232cc <log+0x34>
    800048de:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800048e0:	4390                	lw	a2,0(a5)
    800048e2:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800048e4:	0791                	addi	a5,a5,4
    800048e6:	0711                	addi	a4,a4,4
    800048e8:	fed79ce3          	bne	a5,a3,800048e0 <write_head+0x4e>
  }
  bwrite(buf);
    800048ec:	8526                	mv	a0,s1
    800048ee:	fffff097          	auipc	ra,0xfffff
    800048f2:	09c080e7          	jalr	156(ra) # 8000398a <bwrite>
  brelse(buf);
    800048f6:	8526                	mv	a0,s1
    800048f8:	fffff097          	auipc	ra,0xfffff
    800048fc:	0d0080e7          	jalr	208(ra) # 800039c8 <brelse>
}
    80004900:	60e2                	ld	ra,24(sp)
    80004902:	6442                	ld	s0,16(sp)
    80004904:	64a2                	ld	s1,8(sp)
    80004906:	6902                	ld	s2,0(sp)
    80004908:	6105                	addi	sp,sp,32
    8000490a:	8082                	ret

000000008000490c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000490c:	0001f797          	auipc	a5,0x1f
    80004910:	9b87a783          	lw	a5,-1608(a5) # 800232c4 <log+0x2c>
    80004914:	0af05d63          	blez	a5,800049ce <install_trans+0xc2>
{
    80004918:	7139                	addi	sp,sp,-64
    8000491a:	fc06                	sd	ra,56(sp)
    8000491c:	f822                	sd	s0,48(sp)
    8000491e:	f426                	sd	s1,40(sp)
    80004920:	f04a                	sd	s2,32(sp)
    80004922:	ec4e                	sd	s3,24(sp)
    80004924:	e852                	sd	s4,16(sp)
    80004926:	e456                	sd	s5,8(sp)
    80004928:	e05a                	sd	s6,0(sp)
    8000492a:	0080                	addi	s0,sp,64
    8000492c:	8b2a                	mv	s6,a0
    8000492e:	0001fa97          	auipc	s5,0x1f
    80004932:	99aa8a93          	addi	s5,s5,-1638 # 800232c8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004936:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004938:	0001f997          	auipc	s3,0x1f
    8000493c:	96098993          	addi	s3,s3,-1696 # 80023298 <log>
    80004940:	a035                	j	8000496c <install_trans+0x60>
      bunpin(dbuf);
    80004942:	8526                	mv	a0,s1
    80004944:	fffff097          	auipc	ra,0xfffff
    80004948:	15e080e7          	jalr	350(ra) # 80003aa2 <bunpin>
    brelse(lbuf);
    8000494c:	854a                	mv	a0,s2
    8000494e:	fffff097          	auipc	ra,0xfffff
    80004952:	07a080e7          	jalr	122(ra) # 800039c8 <brelse>
    brelse(dbuf);
    80004956:	8526                	mv	a0,s1
    80004958:	fffff097          	auipc	ra,0xfffff
    8000495c:	070080e7          	jalr	112(ra) # 800039c8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004960:	2a05                	addiw	s4,s4,1
    80004962:	0a91                	addi	s5,s5,4
    80004964:	02c9a783          	lw	a5,44(s3)
    80004968:	04fa5963          	bge	s4,a5,800049ba <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000496c:	0189a583          	lw	a1,24(s3)
    80004970:	014585bb          	addw	a1,a1,s4
    80004974:	2585                	addiw	a1,a1,1
    80004976:	0289a503          	lw	a0,40(s3)
    8000497a:	fffff097          	auipc	ra,0xfffff
    8000497e:	f1e080e7          	jalr	-226(ra) # 80003898 <bread>
    80004982:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004984:	000aa583          	lw	a1,0(s5)
    80004988:	0289a503          	lw	a0,40(s3)
    8000498c:	fffff097          	auipc	ra,0xfffff
    80004990:	f0c080e7          	jalr	-244(ra) # 80003898 <bread>
    80004994:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004996:	40000613          	li	a2,1024
    8000499a:	05890593          	addi	a1,s2,88
    8000499e:	05850513          	addi	a0,a0,88
    800049a2:	ffffc097          	auipc	ra,0xffffc
    800049a6:	3a4080e7          	jalr	932(ra) # 80000d46 <memmove>
    bwrite(dbuf);  // write dst to disk
    800049aa:	8526                	mv	a0,s1
    800049ac:	fffff097          	auipc	ra,0xfffff
    800049b0:	fde080e7          	jalr	-34(ra) # 8000398a <bwrite>
    if(recovering == 0)
    800049b4:	f80b1ce3          	bnez	s6,8000494c <install_trans+0x40>
    800049b8:	b769                	j	80004942 <install_trans+0x36>
}
    800049ba:	70e2                	ld	ra,56(sp)
    800049bc:	7442                	ld	s0,48(sp)
    800049be:	74a2                	ld	s1,40(sp)
    800049c0:	7902                	ld	s2,32(sp)
    800049c2:	69e2                	ld	s3,24(sp)
    800049c4:	6a42                	ld	s4,16(sp)
    800049c6:	6aa2                	ld	s5,8(sp)
    800049c8:	6b02                	ld	s6,0(sp)
    800049ca:	6121                	addi	sp,sp,64
    800049cc:	8082                	ret
    800049ce:	8082                	ret

00000000800049d0 <initlog>:
{
    800049d0:	7179                	addi	sp,sp,-48
    800049d2:	f406                	sd	ra,40(sp)
    800049d4:	f022                	sd	s0,32(sp)
    800049d6:	ec26                	sd	s1,24(sp)
    800049d8:	e84a                	sd	s2,16(sp)
    800049da:	e44e                	sd	s3,8(sp)
    800049dc:	1800                	addi	s0,sp,48
    800049de:	892a                	mv	s2,a0
    800049e0:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800049e2:	0001f497          	auipc	s1,0x1f
    800049e6:	8b648493          	addi	s1,s1,-1866 # 80023298 <log>
    800049ea:	00004597          	auipc	a1,0x4
    800049ee:	d9e58593          	addi	a1,a1,-610 # 80008788 <syscalls+0x200>
    800049f2:	8526                	mv	a0,s1
    800049f4:	ffffc097          	auipc	ra,0xffffc
    800049f8:	166080e7          	jalr	358(ra) # 80000b5a <initlock>
  log.start = sb->logstart;
    800049fc:	0149a583          	lw	a1,20(s3)
    80004a00:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004a02:	0109a783          	lw	a5,16(s3)
    80004a06:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004a08:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004a0c:	854a                	mv	a0,s2
    80004a0e:	fffff097          	auipc	ra,0xfffff
    80004a12:	e8a080e7          	jalr	-374(ra) # 80003898 <bread>
  log.lh.n = lh->n;
    80004a16:	4d3c                	lw	a5,88(a0)
    80004a18:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004a1a:	02f05563          	blez	a5,80004a44 <initlog+0x74>
    80004a1e:	05c50713          	addi	a4,a0,92
    80004a22:	0001f697          	auipc	a3,0x1f
    80004a26:	8a668693          	addi	a3,a3,-1882 # 800232c8 <log+0x30>
    80004a2a:	37fd                	addiw	a5,a5,-1
    80004a2c:	1782                	slli	a5,a5,0x20
    80004a2e:	9381                	srli	a5,a5,0x20
    80004a30:	078a                	slli	a5,a5,0x2
    80004a32:	06050613          	addi	a2,a0,96
    80004a36:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80004a38:	4310                	lw	a2,0(a4)
    80004a3a:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80004a3c:	0711                	addi	a4,a4,4
    80004a3e:	0691                	addi	a3,a3,4
    80004a40:	fef71ce3          	bne	a4,a5,80004a38 <initlog+0x68>
  brelse(buf);
    80004a44:	fffff097          	auipc	ra,0xfffff
    80004a48:	f84080e7          	jalr	-124(ra) # 800039c8 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004a4c:	4505                	li	a0,1
    80004a4e:	00000097          	auipc	ra,0x0
    80004a52:	ebe080e7          	jalr	-322(ra) # 8000490c <install_trans>
  log.lh.n = 0;
    80004a56:	0001f797          	auipc	a5,0x1f
    80004a5a:	8607a723          	sw	zero,-1938(a5) # 800232c4 <log+0x2c>
  write_head(); // clear the log
    80004a5e:	00000097          	auipc	ra,0x0
    80004a62:	e34080e7          	jalr	-460(ra) # 80004892 <write_head>
}
    80004a66:	70a2                	ld	ra,40(sp)
    80004a68:	7402                	ld	s0,32(sp)
    80004a6a:	64e2                	ld	s1,24(sp)
    80004a6c:	6942                	ld	s2,16(sp)
    80004a6e:	69a2                	ld	s3,8(sp)
    80004a70:	6145                	addi	sp,sp,48
    80004a72:	8082                	ret

0000000080004a74 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004a74:	1101                	addi	sp,sp,-32
    80004a76:	ec06                	sd	ra,24(sp)
    80004a78:	e822                	sd	s0,16(sp)
    80004a7a:	e426                	sd	s1,8(sp)
    80004a7c:	e04a                	sd	s2,0(sp)
    80004a7e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004a80:	0001f517          	auipc	a0,0x1f
    80004a84:	81850513          	addi	a0,a0,-2024 # 80023298 <log>
    80004a88:	ffffc097          	auipc	ra,0xffffc
    80004a8c:	162080e7          	jalr	354(ra) # 80000bea <acquire>
  while(1){
    if(log.committing){
    80004a90:	0001f497          	auipc	s1,0x1f
    80004a94:	80848493          	addi	s1,s1,-2040 # 80023298 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004a98:	4979                	li	s2,30
    80004a9a:	a039                	j	80004aa8 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004a9c:	85a6                	mv	a1,s1
    80004a9e:	8526                	mv	a0,s1
    80004aa0:	ffffe097          	auipc	ra,0xffffe
    80004aa4:	aa0080e7          	jalr	-1376(ra) # 80002540 <sleep>
    if(log.committing){
    80004aa8:	50dc                	lw	a5,36(s1)
    80004aaa:	fbed                	bnez	a5,80004a9c <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004aac:	509c                	lw	a5,32(s1)
    80004aae:	0017871b          	addiw	a4,a5,1
    80004ab2:	0007069b          	sext.w	a3,a4
    80004ab6:	0027179b          	slliw	a5,a4,0x2
    80004aba:	9fb9                	addw	a5,a5,a4
    80004abc:	0017979b          	slliw	a5,a5,0x1
    80004ac0:	54d8                	lw	a4,44(s1)
    80004ac2:	9fb9                	addw	a5,a5,a4
    80004ac4:	00f95963          	bge	s2,a5,80004ad6 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004ac8:	85a6                	mv	a1,s1
    80004aca:	8526                	mv	a0,s1
    80004acc:	ffffe097          	auipc	ra,0xffffe
    80004ad0:	a74080e7          	jalr	-1420(ra) # 80002540 <sleep>
    80004ad4:	bfd1                	j	80004aa8 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004ad6:	0001e517          	auipc	a0,0x1e
    80004ada:	7c250513          	addi	a0,a0,1986 # 80023298 <log>
    80004ade:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004ae0:	ffffc097          	auipc	ra,0xffffc
    80004ae4:	1be080e7          	jalr	446(ra) # 80000c9e <release>
      break;
    }
  }
}
    80004ae8:	60e2                	ld	ra,24(sp)
    80004aea:	6442                	ld	s0,16(sp)
    80004aec:	64a2                	ld	s1,8(sp)
    80004aee:	6902                	ld	s2,0(sp)
    80004af0:	6105                	addi	sp,sp,32
    80004af2:	8082                	ret

0000000080004af4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004af4:	7139                	addi	sp,sp,-64
    80004af6:	fc06                	sd	ra,56(sp)
    80004af8:	f822                	sd	s0,48(sp)
    80004afa:	f426                	sd	s1,40(sp)
    80004afc:	f04a                	sd	s2,32(sp)
    80004afe:	ec4e                	sd	s3,24(sp)
    80004b00:	e852                	sd	s4,16(sp)
    80004b02:	e456                	sd	s5,8(sp)
    80004b04:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004b06:	0001e497          	auipc	s1,0x1e
    80004b0a:	79248493          	addi	s1,s1,1938 # 80023298 <log>
    80004b0e:	8526                	mv	a0,s1
    80004b10:	ffffc097          	auipc	ra,0xffffc
    80004b14:	0da080e7          	jalr	218(ra) # 80000bea <acquire>
  log.outstanding -= 1;
    80004b18:	509c                	lw	a5,32(s1)
    80004b1a:	37fd                	addiw	a5,a5,-1
    80004b1c:	0007891b          	sext.w	s2,a5
    80004b20:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004b22:	50dc                	lw	a5,36(s1)
    80004b24:	efb9                	bnez	a5,80004b82 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004b26:	06091663          	bnez	s2,80004b92 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    80004b2a:	0001e497          	auipc	s1,0x1e
    80004b2e:	76e48493          	addi	s1,s1,1902 # 80023298 <log>
    80004b32:	4785                	li	a5,1
    80004b34:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004b36:	8526                	mv	a0,s1
    80004b38:	ffffc097          	auipc	ra,0xffffc
    80004b3c:	166080e7          	jalr	358(ra) # 80000c9e <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004b40:	54dc                	lw	a5,44(s1)
    80004b42:	06f04763          	bgtz	a5,80004bb0 <end_op+0xbc>
    acquire(&log.lock);
    80004b46:	0001e497          	auipc	s1,0x1e
    80004b4a:	75248493          	addi	s1,s1,1874 # 80023298 <log>
    80004b4e:	8526                	mv	a0,s1
    80004b50:	ffffc097          	auipc	ra,0xffffc
    80004b54:	09a080e7          	jalr	154(ra) # 80000bea <acquire>
    log.committing = 0;
    80004b58:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004b5c:	8526                	mv	a0,s1
    80004b5e:	ffffe097          	auipc	ra,0xffffe
    80004b62:	bc0080e7          	jalr	-1088(ra) # 8000271e <wakeup>
    release(&log.lock);
    80004b66:	8526                	mv	a0,s1
    80004b68:	ffffc097          	auipc	ra,0xffffc
    80004b6c:	136080e7          	jalr	310(ra) # 80000c9e <release>
}
    80004b70:	70e2                	ld	ra,56(sp)
    80004b72:	7442                	ld	s0,48(sp)
    80004b74:	74a2                	ld	s1,40(sp)
    80004b76:	7902                	ld	s2,32(sp)
    80004b78:	69e2                	ld	s3,24(sp)
    80004b7a:	6a42                	ld	s4,16(sp)
    80004b7c:	6aa2                	ld	s5,8(sp)
    80004b7e:	6121                	addi	sp,sp,64
    80004b80:	8082                	ret
    panic("log.committing");
    80004b82:	00004517          	auipc	a0,0x4
    80004b86:	c0e50513          	addi	a0,a0,-1010 # 80008790 <syscalls+0x208>
    80004b8a:	ffffc097          	auipc	ra,0xffffc
    80004b8e:	9ba080e7          	jalr	-1606(ra) # 80000544 <panic>
    wakeup(&log);
    80004b92:	0001e497          	auipc	s1,0x1e
    80004b96:	70648493          	addi	s1,s1,1798 # 80023298 <log>
    80004b9a:	8526                	mv	a0,s1
    80004b9c:	ffffe097          	auipc	ra,0xffffe
    80004ba0:	b82080e7          	jalr	-1150(ra) # 8000271e <wakeup>
  release(&log.lock);
    80004ba4:	8526                	mv	a0,s1
    80004ba6:	ffffc097          	auipc	ra,0xffffc
    80004baa:	0f8080e7          	jalr	248(ra) # 80000c9e <release>
  if(do_commit){
    80004bae:	b7c9                	j	80004b70 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004bb0:	0001ea97          	auipc	s5,0x1e
    80004bb4:	718a8a93          	addi	s5,s5,1816 # 800232c8 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004bb8:	0001ea17          	auipc	s4,0x1e
    80004bbc:	6e0a0a13          	addi	s4,s4,1760 # 80023298 <log>
    80004bc0:	018a2583          	lw	a1,24(s4)
    80004bc4:	012585bb          	addw	a1,a1,s2
    80004bc8:	2585                	addiw	a1,a1,1
    80004bca:	028a2503          	lw	a0,40(s4)
    80004bce:	fffff097          	auipc	ra,0xfffff
    80004bd2:	cca080e7          	jalr	-822(ra) # 80003898 <bread>
    80004bd6:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004bd8:	000aa583          	lw	a1,0(s5)
    80004bdc:	028a2503          	lw	a0,40(s4)
    80004be0:	fffff097          	auipc	ra,0xfffff
    80004be4:	cb8080e7          	jalr	-840(ra) # 80003898 <bread>
    80004be8:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004bea:	40000613          	li	a2,1024
    80004bee:	05850593          	addi	a1,a0,88
    80004bf2:	05848513          	addi	a0,s1,88
    80004bf6:	ffffc097          	auipc	ra,0xffffc
    80004bfa:	150080e7          	jalr	336(ra) # 80000d46 <memmove>
    bwrite(to);  // write the log
    80004bfe:	8526                	mv	a0,s1
    80004c00:	fffff097          	auipc	ra,0xfffff
    80004c04:	d8a080e7          	jalr	-630(ra) # 8000398a <bwrite>
    brelse(from);
    80004c08:	854e                	mv	a0,s3
    80004c0a:	fffff097          	auipc	ra,0xfffff
    80004c0e:	dbe080e7          	jalr	-578(ra) # 800039c8 <brelse>
    brelse(to);
    80004c12:	8526                	mv	a0,s1
    80004c14:	fffff097          	auipc	ra,0xfffff
    80004c18:	db4080e7          	jalr	-588(ra) # 800039c8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004c1c:	2905                	addiw	s2,s2,1
    80004c1e:	0a91                	addi	s5,s5,4
    80004c20:	02ca2783          	lw	a5,44(s4)
    80004c24:	f8f94ee3          	blt	s2,a5,80004bc0 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004c28:	00000097          	auipc	ra,0x0
    80004c2c:	c6a080e7          	jalr	-918(ra) # 80004892 <write_head>
    install_trans(0); // Now install writes to home locations
    80004c30:	4501                	li	a0,0
    80004c32:	00000097          	auipc	ra,0x0
    80004c36:	cda080e7          	jalr	-806(ra) # 8000490c <install_trans>
    log.lh.n = 0;
    80004c3a:	0001e797          	auipc	a5,0x1e
    80004c3e:	6807a523          	sw	zero,1674(a5) # 800232c4 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004c42:	00000097          	auipc	ra,0x0
    80004c46:	c50080e7          	jalr	-944(ra) # 80004892 <write_head>
    80004c4a:	bdf5                	j	80004b46 <end_op+0x52>

0000000080004c4c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004c4c:	1101                	addi	sp,sp,-32
    80004c4e:	ec06                	sd	ra,24(sp)
    80004c50:	e822                	sd	s0,16(sp)
    80004c52:	e426                	sd	s1,8(sp)
    80004c54:	e04a                	sd	s2,0(sp)
    80004c56:	1000                	addi	s0,sp,32
    80004c58:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004c5a:	0001e917          	auipc	s2,0x1e
    80004c5e:	63e90913          	addi	s2,s2,1598 # 80023298 <log>
    80004c62:	854a                	mv	a0,s2
    80004c64:	ffffc097          	auipc	ra,0xffffc
    80004c68:	f86080e7          	jalr	-122(ra) # 80000bea <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004c6c:	02c92603          	lw	a2,44(s2)
    80004c70:	47f5                	li	a5,29
    80004c72:	06c7c563          	blt	a5,a2,80004cdc <log_write+0x90>
    80004c76:	0001e797          	auipc	a5,0x1e
    80004c7a:	63e7a783          	lw	a5,1598(a5) # 800232b4 <log+0x1c>
    80004c7e:	37fd                	addiw	a5,a5,-1
    80004c80:	04f65e63          	bge	a2,a5,80004cdc <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004c84:	0001e797          	auipc	a5,0x1e
    80004c88:	6347a783          	lw	a5,1588(a5) # 800232b8 <log+0x20>
    80004c8c:	06f05063          	blez	a5,80004cec <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004c90:	4781                	li	a5,0
    80004c92:	06c05563          	blez	a2,80004cfc <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004c96:	44cc                	lw	a1,12(s1)
    80004c98:	0001e717          	auipc	a4,0x1e
    80004c9c:	63070713          	addi	a4,a4,1584 # 800232c8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004ca0:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004ca2:	4314                	lw	a3,0(a4)
    80004ca4:	04b68c63          	beq	a3,a1,80004cfc <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004ca8:	2785                	addiw	a5,a5,1
    80004caa:	0711                	addi	a4,a4,4
    80004cac:	fef61be3          	bne	a2,a5,80004ca2 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004cb0:	0621                	addi	a2,a2,8
    80004cb2:	060a                	slli	a2,a2,0x2
    80004cb4:	0001e797          	auipc	a5,0x1e
    80004cb8:	5e478793          	addi	a5,a5,1508 # 80023298 <log>
    80004cbc:	963e                	add	a2,a2,a5
    80004cbe:	44dc                	lw	a5,12(s1)
    80004cc0:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004cc2:	8526                	mv	a0,s1
    80004cc4:	fffff097          	auipc	ra,0xfffff
    80004cc8:	da2080e7          	jalr	-606(ra) # 80003a66 <bpin>
    log.lh.n++;
    80004ccc:	0001e717          	auipc	a4,0x1e
    80004cd0:	5cc70713          	addi	a4,a4,1484 # 80023298 <log>
    80004cd4:	575c                	lw	a5,44(a4)
    80004cd6:	2785                	addiw	a5,a5,1
    80004cd8:	d75c                	sw	a5,44(a4)
    80004cda:	a835                	j	80004d16 <log_write+0xca>
    panic("too big a transaction");
    80004cdc:	00004517          	auipc	a0,0x4
    80004ce0:	ac450513          	addi	a0,a0,-1340 # 800087a0 <syscalls+0x218>
    80004ce4:	ffffc097          	auipc	ra,0xffffc
    80004ce8:	860080e7          	jalr	-1952(ra) # 80000544 <panic>
    panic("log_write outside of trans");
    80004cec:	00004517          	auipc	a0,0x4
    80004cf0:	acc50513          	addi	a0,a0,-1332 # 800087b8 <syscalls+0x230>
    80004cf4:	ffffc097          	auipc	ra,0xffffc
    80004cf8:	850080e7          	jalr	-1968(ra) # 80000544 <panic>
  log.lh.block[i] = b->blockno;
    80004cfc:	00878713          	addi	a4,a5,8
    80004d00:	00271693          	slli	a3,a4,0x2
    80004d04:	0001e717          	auipc	a4,0x1e
    80004d08:	59470713          	addi	a4,a4,1428 # 80023298 <log>
    80004d0c:	9736                	add	a4,a4,a3
    80004d0e:	44d4                	lw	a3,12(s1)
    80004d10:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004d12:	faf608e3          	beq	a2,a5,80004cc2 <log_write+0x76>
  }
  release(&log.lock);
    80004d16:	0001e517          	auipc	a0,0x1e
    80004d1a:	58250513          	addi	a0,a0,1410 # 80023298 <log>
    80004d1e:	ffffc097          	auipc	ra,0xffffc
    80004d22:	f80080e7          	jalr	-128(ra) # 80000c9e <release>
}
    80004d26:	60e2                	ld	ra,24(sp)
    80004d28:	6442                	ld	s0,16(sp)
    80004d2a:	64a2                	ld	s1,8(sp)
    80004d2c:	6902                	ld	s2,0(sp)
    80004d2e:	6105                	addi	sp,sp,32
    80004d30:	8082                	ret

0000000080004d32 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004d32:	1101                	addi	sp,sp,-32
    80004d34:	ec06                	sd	ra,24(sp)
    80004d36:	e822                	sd	s0,16(sp)
    80004d38:	e426                	sd	s1,8(sp)
    80004d3a:	e04a                	sd	s2,0(sp)
    80004d3c:	1000                	addi	s0,sp,32
    80004d3e:	84aa                	mv	s1,a0
    80004d40:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004d42:	00004597          	auipc	a1,0x4
    80004d46:	a9658593          	addi	a1,a1,-1386 # 800087d8 <syscalls+0x250>
    80004d4a:	0521                	addi	a0,a0,8
    80004d4c:	ffffc097          	auipc	ra,0xffffc
    80004d50:	e0e080e7          	jalr	-498(ra) # 80000b5a <initlock>
  lk->name = name;
    80004d54:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004d58:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004d5c:	0204a423          	sw	zero,40(s1)
}
    80004d60:	60e2                	ld	ra,24(sp)
    80004d62:	6442                	ld	s0,16(sp)
    80004d64:	64a2                	ld	s1,8(sp)
    80004d66:	6902                	ld	s2,0(sp)
    80004d68:	6105                	addi	sp,sp,32
    80004d6a:	8082                	ret

0000000080004d6c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004d6c:	1101                	addi	sp,sp,-32
    80004d6e:	ec06                	sd	ra,24(sp)
    80004d70:	e822                	sd	s0,16(sp)
    80004d72:	e426                	sd	s1,8(sp)
    80004d74:	e04a                	sd	s2,0(sp)
    80004d76:	1000                	addi	s0,sp,32
    80004d78:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004d7a:	00850913          	addi	s2,a0,8
    80004d7e:	854a                	mv	a0,s2
    80004d80:	ffffc097          	auipc	ra,0xffffc
    80004d84:	e6a080e7          	jalr	-406(ra) # 80000bea <acquire>
  while (lk->locked) {
    80004d88:	409c                	lw	a5,0(s1)
    80004d8a:	cb89                	beqz	a5,80004d9c <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004d8c:	85ca                	mv	a1,s2
    80004d8e:	8526                	mv	a0,s1
    80004d90:	ffffd097          	auipc	ra,0xffffd
    80004d94:	7b0080e7          	jalr	1968(ra) # 80002540 <sleep>
  while (lk->locked) {
    80004d98:	409c                	lw	a5,0(s1)
    80004d9a:	fbed                	bnez	a5,80004d8c <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004d9c:	4785                	li	a5,1
    80004d9e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004da0:	ffffd097          	auipc	ra,0xffffd
    80004da4:	e4a080e7          	jalr	-438(ra) # 80001bea <myproc>
    80004da8:	5d1c                	lw	a5,56(a0)
    80004daa:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004dac:	854a                	mv	a0,s2
    80004dae:	ffffc097          	auipc	ra,0xffffc
    80004db2:	ef0080e7          	jalr	-272(ra) # 80000c9e <release>
}
    80004db6:	60e2                	ld	ra,24(sp)
    80004db8:	6442                	ld	s0,16(sp)
    80004dba:	64a2                	ld	s1,8(sp)
    80004dbc:	6902                	ld	s2,0(sp)
    80004dbe:	6105                	addi	sp,sp,32
    80004dc0:	8082                	ret

0000000080004dc2 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004dc2:	1101                	addi	sp,sp,-32
    80004dc4:	ec06                	sd	ra,24(sp)
    80004dc6:	e822                	sd	s0,16(sp)
    80004dc8:	e426                	sd	s1,8(sp)
    80004dca:	e04a                	sd	s2,0(sp)
    80004dcc:	1000                	addi	s0,sp,32
    80004dce:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004dd0:	00850913          	addi	s2,a0,8
    80004dd4:	854a                	mv	a0,s2
    80004dd6:	ffffc097          	auipc	ra,0xffffc
    80004dda:	e14080e7          	jalr	-492(ra) # 80000bea <acquire>
  lk->locked = 0;
    80004dde:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004de2:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004de6:	8526                	mv	a0,s1
    80004de8:	ffffe097          	auipc	ra,0xffffe
    80004dec:	936080e7          	jalr	-1738(ra) # 8000271e <wakeup>
  release(&lk->lk);
    80004df0:	854a                	mv	a0,s2
    80004df2:	ffffc097          	auipc	ra,0xffffc
    80004df6:	eac080e7          	jalr	-340(ra) # 80000c9e <release>
}
    80004dfa:	60e2                	ld	ra,24(sp)
    80004dfc:	6442                	ld	s0,16(sp)
    80004dfe:	64a2                	ld	s1,8(sp)
    80004e00:	6902                	ld	s2,0(sp)
    80004e02:	6105                	addi	sp,sp,32
    80004e04:	8082                	ret

0000000080004e06 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004e06:	7179                	addi	sp,sp,-48
    80004e08:	f406                	sd	ra,40(sp)
    80004e0a:	f022                	sd	s0,32(sp)
    80004e0c:	ec26                	sd	s1,24(sp)
    80004e0e:	e84a                	sd	s2,16(sp)
    80004e10:	e44e                	sd	s3,8(sp)
    80004e12:	1800                	addi	s0,sp,48
    80004e14:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004e16:	00850913          	addi	s2,a0,8
    80004e1a:	854a                	mv	a0,s2
    80004e1c:	ffffc097          	auipc	ra,0xffffc
    80004e20:	dce080e7          	jalr	-562(ra) # 80000bea <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004e24:	409c                	lw	a5,0(s1)
    80004e26:	ef99                	bnez	a5,80004e44 <holdingsleep+0x3e>
    80004e28:	4481                	li	s1,0
  release(&lk->lk);
    80004e2a:	854a                	mv	a0,s2
    80004e2c:	ffffc097          	auipc	ra,0xffffc
    80004e30:	e72080e7          	jalr	-398(ra) # 80000c9e <release>
  return r;
}
    80004e34:	8526                	mv	a0,s1
    80004e36:	70a2                	ld	ra,40(sp)
    80004e38:	7402                	ld	s0,32(sp)
    80004e3a:	64e2                	ld	s1,24(sp)
    80004e3c:	6942                	ld	s2,16(sp)
    80004e3e:	69a2                	ld	s3,8(sp)
    80004e40:	6145                	addi	sp,sp,48
    80004e42:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004e44:	0284a983          	lw	s3,40(s1)
    80004e48:	ffffd097          	auipc	ra,0xffffd
    80004e4c:	da2080e7          	jalr	-606(ra) # 80001bea <myproc>
    80004e50:	5d04                	lw	s1,56(a0)
    80004e52:	413484b3          	sub	s1,s1,s3
    80004e56:	0014b493          	seqz	s1,s1
    80004e5a:	bfc1                	j	80004e2a <holdingsleep+0x24>

0000000080004e5c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004e5c:	1141                	addi	sp,sp,-16
    80004e5e:	e406                	sd	ra,8(sp)
    80004e60:	e022                	sd	s0,0(sp)
    80004e62:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004e64:	00004597          	auipc	a1,0x4
    80004e68:	98458593          	addi	a1,a1,-1660 # 800087e8 <syscalls+0x260>
    80004e6c:	0001e517          	auipc	a0,0x1e
    80004e70:	57450513          	addi	a0,a0,1396 # 800233e0 <ftable>
    80004e74:	ffffc097          	auipc	ra,0xffffc
    80004e78:	ce6080e7          	jalr	-794(ra) # 80000b5a <initlock>
}
    80004e7c:	60a2                	ld	ra,8(sp)
    80004e7e:	6402                	ld	s0,0(sp)
    80004e80:	0141                	addi	sp,sp,16
    80004e82:	8082                	ret

0000000080004e84 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004e84:	1101                	addi	sp,sp,-32
    80004e86:	ec06                	sd	ra,24(sp)
    80004e88:	e822                	sd	s0,16(sp)
    80004e8a:	e426                	sd	s1,8(sp)
    80004e8c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004e8e:	0001e517          	auipc	a0,0x1e
    80004e92:	55250513          	addi	a0,a0,1362 # 800233e0 <ftable>
    80004e96:	ffffc097          	auipc	ra,0xffffc
    80004e9a:	d54080e7          	jalr	-684(ra) # 80000bea <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004e9e:	0001e497          	auipc	s1,0x1e
    80004ea2:	55a48493          	addi	s1,s1,1370 # 800233f8 <ftable+0x18>
    80004ea6:	0001f717          	auipc	a4,0x1f
    80004eaa:	4f270713          	addi	a4,a4,1266 # 80024398 <disk>
    if(f->ref == 0){
    80004eae:	40dc                	lw	a5,4(s1)
    80004eb0:	cf99                	beqz	a5,80004ece <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004eb2:	02848493          	addi	s1,s1,40
    80004eb6:	fee49ce3          	bne	s1,a4,80004eae <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004eba:	0001e517          	auipc	a0,0x1e
    80004ebe:	52650513          	addi	a0,a0,1318 # 800233e0 <ftable>
    80004ec2:	ffffc097          	auipc	ra,0xffffc
    80004ec6:	ddc080e7          	jalr	-548(ra) # 80000c9e <release>
  return 0;
    80004eca:	4481                	li	s1,0
    80004ecc:	a819                	j	80004ee2 <filealloc+0x5e>
      f->ref = 1;
    80004ece:	4785                	li	a5,1
    80004ed0:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004ed2:	0001e517          	auipc	a0,0x1e
    80004ed6:	50e50513          	addi	a0,a0,1294 # 800233e0 <ftable>
    80004eda:	ffffc097          	auipc	ra,0xffffc
    80004ede:	dc4080e7          	jalr	-572(ra) # 80000c9e <release>
}
    80004ee2:	8526                	mv	a0,s1
    80004ee4:	60e2                	ld	ra,24(sp)
    80004ee6:	6442                	ld	s0,16(sp)
    80004ee8:	64a2                	ld	s1,8(sp)
    80004eea:	6105                	addi	sp,sp,32
    80004eec:	8082                	ret

0000000080004eee <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004eee:	1101                	addi	sp,sp,-32
    80004ef0:	ec06                	sd	ra,24(sp)
    80004ef2:	e822                	sd	s0,16(sp)
    80004ef4:	e426                	sd	s1,8(sp)
    80004ef6:	1000                	addi	s0,sp,32
    80004ef8:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004efa:	0001e517          	auipc	a0,0x1e
    80004efe:	4e650513          	addi	a0,a0,1254 # 800233e0 <ftable>
    80004f02:	ffffc097          	auipc	ra,0xffffc
    80004f06:	ce8080e7          	jalr	-792(ra) # 80000bea <acquire>
  if(f->ref < 1)
    80004f0a:	40dc                	lw	a5,4(s1)
    80004f0c:	02f05263          	blez	a5,80004f30 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004f10:	2785                	addiw	a5,a5,1
    80004f12:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004f14:	0001e517          	auipc	a0,0x1e
    80004f18:	4cc50513          	addi	a0,a0,1228 # 800233e0 <ftable>
    80004f1c:	ffffc097          	auipc	ra,0xffffc
    80004f20:	d82080e7          	jalr	-638(ra) # 80000c9e <release>
  return f;
}
    80004f24:	8526                	mv	a0,s1
    80004f26:	60e2                	ld	ra,24(sp)
    80004f28:	6442                	ld	s0,16(sp)
    80004f2a:	64a2                	ld	s1,8(sp)
    80004f2c:	6105                	addi	sp,sp,32
    80004f2e:	8082                	ret
    panic("filedup");
    80004f30:	00004517          	auipc	a0,0x4
    80004f34:	8c050513          	addi	a0,a0,-1856 # 800087f0 <syscalls+0x268>
    80004f38:	ffffb097          	auipc	ra,0xffffb
    80004f3c:	60c080e7          	jalr	1548(ra) # 80000544 <panic>

0000000080004f40 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004f40:	7139                	addi	sp,sp,-64
    80004f42:	fc06                	sd	ra,56(sp)
    80004f44:	f822                	sd	s0,48(sp)
    80004f46:	f426                	sd	s1,40(sp)
    80004f48:	f04a                	sd	s2,32(sp)
    80004f4a:	ec4e                	sd	s3,24(sp)
    80004f4c:	e852                	sd	s4,16(sp)
    80004f4e:	e456                	sd	s5,8(sp)
    80004f50:	0080                	addi	s0,sp,64
    80004f52:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004f54:	0001e517          	auipc	a0,0x1e
    80004f58:	48c50513          	addi	a0,a0,1164 # 800233e0 <ftable>
    80004f5c:	ffffc097          	auipc	ra,0xffffc
    80004f60:	c8e080e7          	jalr	-882(ra) # 80000bea <acquire>
  if(f->ref < 1)
    80004f64:	40dc                	lw	a5,4(s1)
    80004f66:	06f05163          	blez	a5,80004fc8 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004f6a:	37fd                	addiw	a5,a5,-1
    80004f6c:	0007871b          	sext.w	a4,a5
    80004f70:	c0dc                	sw	a5,4(s1)
    80004f72:	06e04363          	bgtz	a4,80004fd8 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004f76:	0004a903          	lw	s2,0(s1)
    80004f7a:	0094ca83          	lbu	s5,9(s1)
    80004f7e:	0104ba03          	ld	s4,16(s1)
    80004f82:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004f86:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004f8a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004f8e:	0001e517          	auipc	a0,0x1e
    80004f92:	45250513          	addi	a0,a0,1106 # 800233e0 <ftable>
    80004f96:	ffffc097          	auipc	ra,0xffffc
    80004f9a:	d08080e7          	jalr	-760(ra) # 80000c9e <release>

  if(ff.type == FD_PIPE){
    80004f9e:	4785                	li	a5,1
    80004fa0:	04f90d63          	beq	s2,a5,80004ffa <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004fa4:	3979                	addiw	s2,s2,-2
    80004fa6:	4785                	li	a5,1
    80004fa8:	0527e063          	bltu	a5,s2,80004fe8 <fileclose+0xa8>
    begin_op();
    80004fac:	00000097          	auipc	ra,0x0
    80004fb0:	ac8080e7          	jalr	-1336(ra) # 80004a74 <begin_op>
    iput(ff.ip);
    80004fb4:	854e                	mv	a0,s3
    80004fb6:	fffff097          	auipc	ra,0xfffff
    80004fba:	2b6080e7          	jalr	694(ra) # 8000426c <iput>
    end_op();
    80004fbe:	00000097          	auipc	ra,0x0
    80004fc2:	b36080e7          	jalr	-1226(ra) # 80004af4 <end_op>
    80004fc6:	a00d                	j	80004fe8 <fileclose+0xa8>
    panic("fileclose");
    80004fc8:	00004517          	auipc	a0,0x4
    80004fcc:	83050513          	addi	a0,a0,-2000 # 800087f8 <syscalls+0x270>
    80004fd0:	ffffb097          	auipc	ra,0xffffb
    80004fd4:	574080e7          	jalr	1396(ra) # 80000544 <panic>
    release(&ftable.lock);
    80004fd8:	0001e517          	auipc	a0,0x1e
    80004fdc:	40850513          	addi	a0,a0,1032 # 800233e0 <ftable>
    80004fe0:	ffffc097          	auipc	ra,0xffffc
    80004fe4:	cbe080e7          	jalr	-834(ra) # 80000c9e <release>
  }
}
    80004fe8:	70e2                	ld	ra,56(sp)
    80004fea:	7442                	ld	s0,48(sp)
    80004fec:	74a2                	ld	s1,40(sp)
    80004fee:	7902                	ld	s2,32(sp)
    80004ff0:	69e2                	ld	s3,24(sp)
    80004ff2:	6a42                	ld	s4,16(sp)
    80004ff4:	6aa2                	ld	s5,8(sp)
    80004ff6:	6121                	addi	sp,sp,64
    80004ff8:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004ffa:	85d6                	mv	a1,s5
    80004ffc:	8552                	mv	a0,s4
    80004ffe:	00000097          	auipc	ra,0x0
    80005002:	34c080e7          	jalr	844(ra) # 8000534a <pipeclose>
    80005006:	b7cd                	j	80004fe8 <fileclose+0xa8>

0000000080005008 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80005008:	715d                	addi	sp,sp,-80
    8000500a:	e486                	sd	ra,72(sp)
    8000500c:	e0a2                	sd	s0,64(sp)
    8000500e:	fc26                	sd	s1,56(sp)
    80005010:	f84a                	sd	s2,48(sp)
    80005012:	f44e                	sd	s3,40(sp)
    80005014:	0880                	addi	s0,sp,80
    80005016:	84aa                	mv	s1,a0
    80005018:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000501a:	ffffd097          	auipc	ra,0xffffd
    8000501e:	bd0080e7          	jalr	-1072(ra) # 80001bea <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80005022:	409c                	lw	a5,0(s1)
    80005024:	37f9                	addiw	a5,a5,-2
    80005026:	4705                	li	a4,1
    80005028:	04f76763          	bltu	a4,a5,80005076 <filestat+0x6e>
    8000502c:	892a                	mv	s2,a0
    ilock(f->ip);
    8000502e:	6c88                	ld	a0,24(s1)
    80005030:	fffff097          	auipc	ra,0xfffff
    80005034:	082080e7          	jalr	130(ra) # 800040b2 <ilock>
    stati(f->ip, &st);
    80005038:	fb840593          	addi	a1,s0,-72
    8000503c:	6c88                	ld	a0,24(s1)
    8000503e:	fffff097          	auipc	ra,0xfffff
    80005042:	2fe080e7          	jalr	766(ra) # 8000433c <stati>
    iunlock(f->ip);
    80005046:	6c88                	ld	a0,24(s1)
    80005048:	fffff097          	auipc	ra,0xfffff
    8000504c:	12c080e7          	jalr	300(ra) # 80004174 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80005050:	46e1                	li	a3,24
    80005052:	fb840613          	addi	a2,s0,-72
    80005056:	85ce                	mv	a1,s3
    80005058:	05893503          	ld	a0,88(s2)
    8000505c:	ffffc097          	auipc	ra,0xffffc
    80005060:	628080e7          	jalr	1576(ra) # 80001684 <copyout>
    80005064:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80005068:	60a6                	ld	ra,72(sp)
    8000506a:	6406                	ld	s0,64(sp)
    8000506c:	74e2                	ld	s1,56(sp)
    8000506e:	7942                	ld	s2,48(sp)
    80005070:	79a2                	ld	s3,40(sp)
    80005072:	6161                	addi	sp,sp,80
    80005074:	8082                	ret
  return -1;
    80005076:	557d                	li	a0,-1
    80005078:	bfc5                	j	80005068 <filestat+0x60>

000000008000507a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000507a:	7179                	addi	sp,sp,-48
    8000507c:	f406                	sd	ra,40(sp)
    8000507e:	f022                	sd	s0,32(sp)
    80005080:	ec26                	sd	s1,24(sp)
    80005082:	e84a                	sd	s2,16(sp)
    80005084:	e44e                	sd	s3,8(sp)
    80005086:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80005088:	00854783          	lbu	a5,8(a0)
    8000508c:	c3d5                	beqz	a5,80005130 <fileread+0xb6>
    8000508e:	84aa                	mv	s1,a0
    80005090:	89ae                	mv	s3,a1
    80005092:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80005094:	411c                	lw	a5,0(a0)
    80005096:	4705                	li	a4,1
    80005098:	04e78963          	beq	a5,a4,800050ea <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000509c:	470d                	li	a4,3
    8000509e:	04e78d63          	beq	a5,a4,800050f8 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800050a2:	4709                	li	a4,2
    800050a4:	06e79e63          	bne	a5,a4,80005120 <fileread+0xa6>
    ilock(f->ip);
    800050a8:	6d08                	ld	a0,24(a0)
    800050aa:	fffff097          	auipc	ra,0xfffff
    800050ae:	008080e7          	jalr	8(ra) # 800040b2 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800050b2:	874a                	mv	a4,s2
    800050b4:	5094                	lw	a3,32(s1)
    800050b6:	864e                	mv	a2,s3
    800050b8:	4585                	li	a1,1
    800050ba:	6c88                	ld	a0,24(s1)
    800050bc:	fffff097          	auipc	ra,0xfffff
    800050c0:	2aa080e7          	jalr	682(ra) # 80004366 <readi>
    800050c4:	892a                	mv	s2,a0
    800050c6:	00a05563          	blez	a0,800050d0 <fileread+0x56>
      f->off += r;
    800050ca:	509c                	lw	a5,32(s1)
    800050cc:	9fa9                	addw	a5,a5,a0
    800050ce:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800050d0:	6c88                	ld	a0,24(s1)
    800050d2:	fffff097          	auipc	ra,0xfffff
    800050d6:	0a2080e7          	jalr	162(ra) # 80004174 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800050da:	854a                	mv	a0,s2
    800050dc:	70a2                	ld	ra,40(sp)
    800050de:	7402                	ld	s0,32(sp)
    800050e0:	64e2                	ld	s1,24(sp)
    800050e2:	6942                	ld	s2,16(sp)
    800050e4:	69a2                	ld	s3,8(sp)
    800050e6:	6145                	addi	sp,sp,48
    800050e8:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800050ea:	6908                	ld	a0,16(a0)
    800050ec:	00000097          	auipc	ra,0x0
    800050f0:	3ce080e7          	jalr	974(ra) # 800054ba <piperead>
    800050f4:	892a                	mv	s2,a0
    800050f6:	b7d5                	j	800050da <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800050f8:	02451783          	lh	a5,36(a0)
    800050fc:	03079693          	slli	a3,a5,0x30
    80005100:	92c1                	srli	a3,a3,0x30
    80005102:	4725                	li	a4,9
    80005104:	02d76863          	bltu	a4,a3,80005134 <fileread+0xba>
    80005108:	0792                	slli	a5,a5,0x4
    8000510a:	0001e717          	auipc	a4,0x1e
    8000510e:	23670713          	addi	a4,a4,566 # 80023340 <devsw>
    80005112:	97ba                	add	a5,a5,a4
    80005114:	639c                	ld	a5,0(a5)
    80005116:	c38d                	beqz	a5,80005138 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80005118:	4505                	li	a0,1
    8000511a:	9782                	jalr	a5
    8000511c:	892a                	mv	s2,a0
    8000511e:	bf75                	j	800050da <fileread+0x60>
    panic("fileread");
    80005120:	00003517          	auipc	a0,0x3
    80005124:	6e850513          	addi	a0,a0,1768 # 80008808 <syscalls+0x280>
    80005128:	ffffb097          	auipc	ra,0xffffb
    8000512c:	41c080e7          	jalr	1052(ra) # 80000544 <panic>
    return -1;
    80005130:	597d                	li	s2,-1
    80005132:	b765                	j	800050da <fileread+0x60>
      return -1;
    80005134:	597d                	li	s2,-1
    80005136:	b755                	j	800050da <fileread+0x60>
    80005138:	597d                	li	s2,-1
    8000513a:	b745                	j	800050da <fileread+0x60>

000000008000513c <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    8000513c:	715d                	addi	sp,sp,-80
    8000513e:	e486                	sd	ra,72(sp)
    80005140:	e0a2                	sd	s0,64(sp)
    80005142:	fc26                	sd	s1,56(sp)
    80005144:	f84a                	sd	s2,48(sp)
    80005146:	f44e                	sd	s3,40(sp)
    80005148:	f052                	sd	s4,32(sp)
    8000514a:	ec56                	sd	s5,24(sp)
    8000514c:	e85a                	sd	s6,16(sp)
    8000514e:	e45e                	sd	s7,8(sp)
    80005150:	e062                	sd	s8,0(sp)
    80005152:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80005154:	00954783          	lbu	a5,9(a0)
    80005158:	10078663          	beqz	a5,80005264 <filewrite+0x128>
    8000515c:	892a                	mv	s2,a0
    8000515e:	8aae                	mv	s5,a1
    80005160:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80005162:	411c                	lw	a5,0(a0)
    80005164:	4705                	li	a4,1
    80005166:	02e78263          	beq	a5,a4,8000518a <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000516a:	470d                	li	a4,3
    8000516c:	02e78663          	beq	a5,a4,80005198 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80005170:	4709                	li	a4,2
    80005172:	0ee79163          	bne	a5,a4,80005254 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80005176:	0ac05d63          	blez	a2,80005230 <filewrite+0xf4>
    int i = 0;
    8000517a:	4981                	li	s3,0
    8000517c:	6b05                	lui	s6,0x1
    8000517e:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80005182:	6b85                	lui	s7,0x1
    80005184:	c00b8b9b          	addiw	s7,s7,-1024
    80005188:	a861                	j	80005220 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    8000518a:	6908                	ld	a0,16(a0)
    8000518c:	00000097          	auipc	ra,0x0
    80005190:	22e080e7          	jalr	558(ra) # 800053ba <pipewrite>
    80005194:	8a2a                	mv	s4,a0
    80005196:	a045                	j	80005236 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005198:	02451783          	lh	a5,36(a0)
    8000519c:	03079693          	slli	a3,a5,0x30
    800051a0:	92c1                	srli	a3,a3,0x30
    800051a2:	4725                	li	a4,9
    800051a4:	0cd76263          	bltu	a4,a3,80005268 <filewrite+0x12c>
    800051a8:	0792                	slli	a5,a5,0x4
    800051aa:	0001e717          	auipc	a4,0x1e
    800051ae:	19670713          	addi	a4,a4,406 # 80023340 <devsw>
    800051b2:	97ba                	add	a5,a5,a4
    800051b4:	679c                	ld	a5,8(a5)
    800051b6:	cbdd                	beqz	a5,8000526c <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800051b8:	4505                	li	a0,1
    800051ba:	9782                	jalr	a5
    800051bc:	8a2a                	mv	s4,a0
    800051be:	a8a5                	j	80005236 <filewrite+0xfa>
    800051c0:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800051c4:	00000097          	auipc	ra,0x0
    800051c8:	8b0080e7          	jalr	-1872(ra) # 80004a74 <begin_op>
      ilock(f->ip);
    800051cc:	01893503          	ld	a0,24(s2)
    800051d0:	fffff097          	auipc	ra,0xfffff
    800051d4:	ee2080e7          	jalr	-286(ra) # 800040b2 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800051d8:	8762                	mv	a4,s8
    800051da:	02092683          	lw	a3,32(s2)
    800051de:	01598633          	add	a2,s3,s5
    800051e2:	4585                	li	a1,1
    800051e4:	01893503          	ld	a0,24(s2)
    800051e8:	fffff097          	auipc	ra,0xfffff
    800051ec:	276080e7          	jalr	630(ra) # 8000445e <writei>
    800051f0:	84aa                	mv	s1,a0
    800051f2:	00a05763          	blez	a0,80005200 <filewrite+0xc4>
        f->off += r;
    800051f6:	02092783          	lw	a5,32(s2)
    800051fa:	9fa9                	addw	a5,a5,a0
    800051fc:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80005200:	01893503          	ld	a0,24(s2)
    80005204:	fffff097          	auipc	ra,0xfffff
    80005208:	f70080e7          	jalr	-144(ra) # 80004174 <iunlock>
      end_op();
    8000520c:	00000097          	auipc	ra,0x0
    80005210:	8e8080e7          	jalr	-1816(ra) # 80004af4 <end_op>

      if(r != n1){
    80005214:	009c1f63          	bne	s8,s1,80005232 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80005218:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000521c:	0149db63          	bge	s3,s4,80005232 <filewrite+0xf6>
      int n1 = n - i;
    80005220:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80005224:	84be                	mv	s1,a5
    80005226:	2781                	sext.w	a5,a5
    80005228:	f8fb5ce3          	bge	s6,a5,800051c0 <filewrite+0x84>
    8000522c:	84de                	mv	s1,s7
    8000522e:	bf49                	j	800051c0 <filewrite+0x84>
    int i = 0;
    80005230:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80005232:	013a1f63          	bne	s4,s3,80005250 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80005236:	8552                	mv	a0,s4
    80005238:	60a6                	ld	ra,72(sp)
    8000523a:	6406                	ld	s0,64(sp)
    8000523c:	74e2                	ld	s1,56(sp)
    8000523e:	7942                	ld	s2,48(sp)
    80005240:	79a2                	ld	s3,40(sp)
    80005242:	7a02                	ld	s4,32(sp)
    80005244:	6ae2                	ld	s5,24(sp)
    80005246:	6b42                	ld	s6,16(sp)
    80005248:	6ba2                	ld	s7,8(sp)
    8000524a:	6c02                	ld	s8,0(sp)
    8000524c:	6161                	addi	sp,sp,80
    8000524e:	8082                	ret
    ret = (i == n ? n : -1);
    80005250:	5a7d                	li	s4,-1
    80005252:	b7d5                	j	80005236 <filewrite+0xfa>
    panic("filewrite");
    80005254:	00003517          	auipc	a0,0x3
    80005258:	5c450513          	addi	a0,a0,1476 # 80008818 <syscalls+0x290>
    8000525c:	ffffb097          	auipc	ra,0xffffb
    80005260:	2e8080e7          	jalr	744(ra) # 80000544 <panic>
    return -1;
    80005264:	5a7d                	li	s4,-1
    80005266:	bfc1                	j	80005236 <filewrite+0xfa>
      return -1;
    80005268:	5a7d                	li	s4,-1
    8000526a:	b7f1                	j	80005236 <filewrite+0xfa>
    8000526c:	5a7d                	li	s4,-1
    8000526e:	b7e1                	j	80005236 <filewrite+0xfa>

0000000080005270 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80005270:	7179                	addi	sp,sp,-48
    80005272:	f406                	sd	ra,40(sp)
    80005274:	f022                	sd	s0,32(sp)
    80005276:	ec26                	sd	s1,24(sp)
    80005278:	e84a                	sd	s2,16(sp)
    8000527a:	e44e                	sd	s3,8(sp)
    8000527c:	e052                	sd	s4,0(sp)
    8000527e:	1800                	addi	s0,sp,48
    80005280:	84aa                	mv	s1,a0
    80005282:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005284:	0005b023          	sd	zero,0(a1)
    80005288:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000528c:	00000097          	auipc	ra,0x0
    80005290:	bf8080e7          	jalr	-1032(ra) # 80004e84 <filealloc>
    80005294:	e088                	sd	a0,0(s1)
    80005296:	c551                	beqz	a0,80005322 <pipealloc+0xb2>
    80005298:	00000097          	auipc	ra,0x0
    8000529c:	bec080e7          	jalr	-1044(ra) # 80004e84 <filealloc>
    800052a0:	00aa3023          	sd	a0,0(s4)
    800052a4:	c92d                	beqz	a0,80005316 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800052a6:	ffffc097          	auipc	ra,0xffffc
    800052aa:	854080e7          	jalr	-1964(ra) # 80000afa <kalloc>
    800052ae:	892a                	mv	s2,a0
    800052b0:	c125                	beqz	a0,80005310 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800052b2:	4985                	li	s3,1
    800052b4:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800052b8:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800052bc:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800052c0:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800052c4:	00003597          	auipc	a1,0x3
    800052c8:	1e458593          	addi	a1,a1,484 # 800084a8 <states.2559+0x1b8>
    800052cc:	ffffc097          	auipc	ra,0xffffc
    800052d0:	88e080e7          	jalr	-1906(ra) # 80000b5a <initlock>
  (*f0)->type = FD_PIPE;
    800052d4:	609c                	ld	a5,0(s1)
    800052d6:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800052da:	609c                	ld	a5,0(s1)
    800052dc:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800052e0:	609c                	ld	a5,0(s1)
    800052e2:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800052e6:	609c                	ld	a5,0(s1)
    800052e8:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800052ec:	000a3783          	ld	a5,0(s4)
    800052f0:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800052f4:	000a3783          	ld	a5,0(s4)
    800052f8:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800052fc:	000a3783          	ld	a5,0(s4)
    80005300:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005304:	000a3783          	ld	a5,0(s4)
    80005308:	0127b823          	sd	s2,16(a5)
  return 0;
    8000530c:	4501                	li	a0,0
    8000530e:	a025                	j	80005336 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005310:	6088                	ld	a0,0(s1)
    80005312:	e501                	bnez	a0,8000531a <pipealloc+0xaa>
    80005314:	a039                	j	80005322 <pipealloc+0xb2>
    80005316:	6088                	ld	a0,0(s1)
    80005318:	c51d                	beqz	a0,80005346 <pipealloc+0xd6>
    fileclose(*f0);
    8000531a:	00000097          	auipc	ra,0x0
    8000531e:	c26080e7          	jalr	-986(ra) # 80004f40 <fileclose>
  if(*f1)
    80005322:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005326:	557d                	li	a0,-1
  if(*f1)
    80005328:	c799                	beqz	a5,80005336 <pipealloc+0xc6>
    fileclose(*f1);
    8000532a:	853e                	mv	a0,a5
    8000532c:	00000097          	auipc	ra,0x0
    80005330:	c14080e7          	jalr	-1004(ra) # 80004f40 <fileclose>
  return -1;
    80005334:	557d                	li	a0,-1
}
    80005336:	70a2                	ld	ra,40(sp)
    80005338:	7402                	ld	s0,32(sp)
    8000533a:	64e2                	ld	s1,24(sp)
    8000533c:	6942                	ld	s2,16(sp)
    8000533e:	69a2                	ld	s3,8(sp)
    80005340:	6a02                	ld	s4,0(sp)
    80005342:	6145                	addi	sp,sp,48
    80005344:	8082                	ret
  return -1;
    80005346:	557d                	li	a0,-1
    80005348:	b7fd                	j	80005336 <pipealloc+0xc6>

000000008000534a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000534a:	1101                	addi	sp,sp,-32
    8000534c:	ec06                	sd	ra,24(sp)
    8000534e:	e822                	sd	s0,16(sp)
    80005350:	e426                	sd	s1,8(sp)
    80005352:	e04a                	sd	s2,0(sp)
    80005354:	1000                	addi	s0,sp,32
    80005356:	84aa                	mv	s1,a0
    80005358:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000535a:	ffffc097          	auipc	ra,0xffffc
    8000535e:	890080e7          	jalr	-1904(ra) # 80000bea <acquire>
  if(writable){
    80005362:	02090d63          	beqz	s2,8000539c <pipeclose+0x52>
    pi->writeopen = 0;
    80005366:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000536a:	21848513          	addi	a0,s1,536
    8000536e:	ffffd097          	auipc	ra,0xffffd
    80005372:	3b0080e7          	jalr	944(ra) # 8000271e <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005376:	2204b783          	ld	a5,544(s1)
    8000537a:	eb95                	bnez	a5,800053ae <pipeclose+0x64>
    release(&pi->lock);
    8000537c:	8526                	mv	a0,s1
    8000537e:	ffffc097          	auipc	ra,0xffffc
    80005382:	920080e7          	jalr	-1760(ra) # 80000c9e <release>
    kfree((char*)pi);
    80005386:	8526                	mv	a0,s1
    80005388:	ffffb097          	auipc	ra,0xffffb
    8000538c:	676080e7          	jalr	1654(ra) # 800009fe <kfree>
  } else
    release(&pi->lock);
}
    80005390:	60e2                	ld	ra,24(sp)
    80005392:	6442                	ld	s0,16(sp)
    80005394:	64a2                	ld	s1,8(sp)
    80005396:	6902                	ld	s2,0(sp)
    80005398:	6105                	addi	sp,sp,32
    8000539a:	8082                	ret
    pi->readopen = 0;
    8000539c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800053a0:	21c48513          	addi	a0,s1,540
    800053a4:	ffffd097          	auipc	ra,0xffffd
    800053a8:	37a080e7          	jalr	890(ra) # 8000271e <wakeup>
    800053ac:	b7e9                	j	80005376 <pipeclose+0x2c>
    release(&pi->lock);
    800053ae:	8526                	mv	a0,s1
    800053b0:	ffffc097          	auipc	ra,0xffffc
    800053b4:	8ee080e7          	jalr	-1810(ra) # 80000c9e <release>
}
    800053b8:	bfe1                	j	80005390 <pipeclose+0x46>

00000000800053ba <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800053ba:	7159                	addi	sp,sp,-112
    800053bc:	f486                	sd	ra,104(sp)
    800053be:	f0a2                	sd	s0,96(sp)
    800053c0:	eca6                	sd	s1,88(sp)
    800053c2:	e8ca                	sd	s2,80(sp)
    800053c4:	e4ce                	sd	s3,72(sp)
    800053c6:	e0d2                	sd	s4,64(sp)
    800053c8:	fc56                	sd	s5,56(sp)
    800053ca:	f85a                	sd	s6,48(sp)
    800053cc:	f45e                	sd	s7,40(sp)
    800053ce:	f062                	sd	s8,32(sp)
    800053d0:	ec66                	sd	s9,24(sp)
    800053d2:	1880                	addi	s0,sp,112
    800053d4:	84aa                	mv	s1,a0
    800053d6:	8aae                	mv	s5,a1
    800053d8:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800053da:	ffffd097          	auipc	ra,0xffffd
    800053de:	810080e7          	jalr	-2032(ra) # 80001bea <myproc>
    800053e2:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800053e4:	8526                	mv	a0,s1
    800053e6:	ffffc097          	auipc	ra,0xffffc
    800053ea:	804080e7          	jalr	-2044(ra) # 80000bea <acquire>
  while(i < n){
    800053ee:	0d405463          	blez	s4,800054b6 <pipewrite+0xfc>
    800053f2:	8ba6                	mv	s7,s1
  int i = 0;
    800053f4:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800053f6:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800053f8:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800053fc:	21c48c13          	addi	s8,s1,540
    80005400:	a08d                	j	80005462 <pipewrite+0xa8>
      release(&pi->lock);
    80005402:	8526                	mv	a0,s1
    80005404:	ffffc097          	auipc	ra,0xffffc
    80005408:	89a080e7          	jalr	-1894(ra) # 80000c9e <release>
      return -1;
    8000540c:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000540e:	854a                	mv	a0,s2
    80005410:	70a6                	ld	ra,104(sp)
    80005412:	7406                	ld	s0,96(sp)
    80005414:	64e6                	ld	s1,88(sp)
    80005416:	6946                	ld	s2,80(sp)
    80005418:	69a6                	ld	s3,72(sp)
    8000541a:	6a06                	ld	s4,64(sp)
    8000541c:	7ae2                	ld	s5,56(sp)
    8000541e:	7b42                	ld	s6,48(sp)
    80005420:	7ba2                	ld	s7,40(sp)
    80005422:	7c02                	ld	s8,32(sp)
    80005424:	6ce2                	ld	s9,24(sp)
    80005426:	6165                	addi	sp,sp,112
    80005428:	8082                	ret
      wakeup(&pi->nread);
    8000542a:	8566                	mv	a0,s9
    8000542c:	ffffd097          	auipc	ra,0xffffd
    80005430:	2f2080e7          	jalr	754(ra) # 8000271e <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005434:	85de                	mv	a1,s7
    80005436:	8562                	mv	a0,s8
    80005438:	ffffd097          	auipc	ra,0xffffd
    8000543c:	108080e7          	jalr	264(ra) # 80002540 <sleep>
    80005440:	a839                	j	8000545e <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005442:	21c4a783          	lw	a5,540(s1)
    80005446:	0017871b          	addiw	a4,a5,1
    8000544a:	20e4ae23          	sw	a4,540(s1)
    8000544e:	1ff7f793          	andi	a5,a5,511
    80005452:	97a6                	add	a5,a5,s1
    80005454:	f9f44703          	lbu	a4,-97(s0)
    80005458:	00e78c23          	sb	a4,24(a5)
      i++;
    8000545c:	2905                	addiw	s2,s2,1
  while(i < n){
    8000545e:	05495063          	bge	s2,s4,8000549e <pipewrite+0xe4>
    if(pi->readopen == 0 || killed(pr)){
    80005462:	2204a783          	lw	a5,544(s1)
    80005466:	dfd1                	beqz	a5,80005402 <pipewrite+0x48>
    80005468:	854e                	mv	a0,s3
    8000546a:	ffffd097          	auipc	ra,0xffffd
    8000546e:	638080e7          	jalr	1592(ra) # 80002aa2 <killed>
    80005472:	f941                	bnez	a0,80005402 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005474:	2184a783          	lw	a5,536(s1)
    80005478:	21c4a703          	lw	a4,540(s1)
    8000547c:	2007879b          	addiw	a5,a5,512
    80005480:	faf705e3          	beq	a4,a5,8000542a <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005484:	4685                	li	a3,1
    80005486:	01590633          	add	a2,s2,s5
    8000548a:	f9f40593          	addi	a1,s0,-97
    8000548e:	0589b503          	ld	a0,88(s3)
    80005492:	ffffc097          	auipc	ra,0xffffc
    80005496:	27e080e7          	jalr	638(ra) # 80001710 <copyin>
    8000549a:	fb6514e3          	bne	a0,s6,80005442 <pipewrite+0x88>
  wakeup(&pi->nread);
    8000549e:	21848513          	addi	a0,s1,536
    800054a2:	ffffd097          	auipc	ra,0xffffd
    800054a6:	27c080e7          	jalr	636(ra) # 8000271e <wakeup>
  release(&pi->lock);
    800054aa:	8526                	mv	a0,s1
    800054ac:	ffffb097          	auipc	ra,0xffffb
    800054b0:	7f2080e7          	jalr	2034(ra) # 80000c9e <release>
  return i;
    800054b4:	bfa9                	j	8000540e <pipewrite+0x54>
  int i = 0;
    800054b6:	4901                	li	s2,0
    800054b8:	b7dd                	j	8000549e <pipewrite+0xe4>

00000000800054ba <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800054ba:	715d                	addi	sp,sp,-80
    800054bc:	e486                	sd	ra,72(sp)
    800054be:	e0a2                	sd	s0,64(sp)
    800054c0:	fc26                	sd	s1,56(sp)
    800054c2:	f84a                	sd	s2,48(sp)
    800054c4:	f44e                	sd	s3,40(sp)
    800054c6:	f052                	sd	s4,32(sp)
    800054c8:	ec56                	sd	s5,24(sp)
    800054ca:	e85a                	sd	s6,16(sp)
    800054cc:	0880                	addi	s0,sp,80
    800054ce:	84aa                	mv	s1,a0
    800054d0:	892e                	mv	s2,a1
    800054d2:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800054d4:	ffffc097          	auipc	ra,0xffffc
    800054d8:	716080e7          	jalr	1814(ra) # 80001bea <myproc>
    800054dc:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800054de:	8b26                	mv	s6,s1
    800054e0:	8526                	mv	a0,s1
    800054e2:	ffffb097          	auipc	ra,0xffffb
    800054e6:	708080e7          	jalr	1800(ra) # 80000bea <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800054ea:	2184a703          	lw	a4,536(s1)
    800054ee:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800054f2:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800054f6:	02f71763          	bne	a4,a5,80005524 <piperead+0x6a>
    800054fa:	2244a783          	lw	a5,548(s1)
    800054fe:	c39d                	beqz	a5,80005524 <piperead+0x6a>
    if(killed(pr)){
    80005500:	8552                	mv	a0,s4
    80005502:	ffffd097          	auipc	ra,0xffffd
    80005506:	5a0080e7          	jalr	1440(ra) # 80002aa2 <killed>
    8000550a:	e941                	bnez	a0,8000559a <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000550c:	85da                	mv	a1,s6
    8000550e:	854e                	mv	a0,s3
    80005510:	ffffd097          	auipc	ra,0xffffd
    80005514:	030080e7          	jalr	48(ra) # 80002540 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005518:	2184a703          	lw	a4,536(s1)
    8000551c:	21c4a783          	lw	a5,540(s1)
    80005520:	fcf70de3          	beq	a4,a5,800054fa <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005524:	09505263          	blez	s5,800055a8 <piperead+0xee>
    80005528:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000552a:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    8000552c:	2184a783          	lw	a5,536(s1)
    80005530:	21c4a703          	lw	a4,540(s1)
    80005534:	02f70d63          	beq	a4,a5,8000556e <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005538:	0017871b          	addiw	a4,a5,1
    8000553c:	20e4ac23          	sw	a4,536(s1)
    80005540:	1ff7f793          	andi	a5,a5,511
    80005544:	97a6                	add	a5,a5,s1
    80005546:	0187c783          	lbu	a5,24(a5)
    8000554a:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000554e:	4685                	li	a3,1
    80005550:	fbf40613          	addi	a2,s0,-65
    80005554:	85ca                	mv	a1,s2
    80005556:	058a3503          	ld	a0,88(s4)
    8000555a:	ffffc097          	auipc	ra,0xffffc
    8000555e:	12a080e7          	jalr	298(ra) # 80001684 <copyout>
    80005562:	01650663          	beq	a0,s6,8000556e <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005566:	2985                	addiw	s3,s3,1
    80005568:	0905                	addi	s2,s2,1
    8000556a:	fd3a91e3          	bne	s5,s3,8000552c <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000556e:	21c48513          	addi	a0,s1,540
    80005572:	ffffd097          	auipc	ra,0xffffd
    80005576:	1ac080e7          	jalr	428(ra) # 8000271e <wakeup>
  release(&pi->lock);
    8000557a:	8526                	mv	a0,s1
    8000557c:	ffffb097          	auipc	ra,0xffffb
    80005580:	722080e7          	jalr	1826(ra) # 80000c9e <release>
  return i;
}
    80005584:	854e                	mv	a0,s3
    80005586:	60a6                	ld	ra,72(sp)
    80005588:	6406                	ld	s0,64(sp)
    8000558a:	74e2                	ld	s1,56(sp)
    8000558c:	7942                	ld	s2,48(sp)
    8000558e:	79a2                	ld	s3,40(sp)
    80005590:	7a02                	ld	s4,32(sp)
    80005592:	6ae2                	ld	s5,24(sp)
    80005594:	6b42                	ld	s6,16(sp)
    80005596:	6161                	addi	sp,sp,80
    80005598:	8082                	ret
      release(&pi->lock);
    8000559a:	8526                	mv	a0,s1
    8000559c:	ffffb097          	auipc	ra,0xffffb
    800055a0:	702080e7          	jalr	1794(ra) # 80000c9e <release>
      return -1;
    800055a4:	59fd                	li	s3,-1
    800055a6:	bff9                	j	80005584 <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800055a8:	4981                	li	s3,0
    800055aa:	b7d1                	j	8000556e <piperead+0xb4>

00000000800055ac <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800055ac:	1141                	addi	sp,sp,-16
    800055ae:	e422                	sd	s0,8(sp)
    800055b0:	0800                	addi	s0,sp,16
    800055b2:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800055b4:	8905                	andi	a0,a0,1
    800055b6:	c111                	beqz	a0,800055ba <flags2perm+0xe>
      perm = PTE_X;
    800055b8:	4521                	li	a0,8
    if(flags & 0x2)
    800055ba:	8b89                	andi	a5,a5,2
    800055bc:	c399                	beqz	a5,800055c2 <flags2perm+0x16>
      perm |= PTE_W;
    800055be:	00456513          	ori	a0,a0,4
    return perm;
}
    800055c2:	6422                	ld	s0,8(sp)
    800055c4:	0141                	addi	sp,sp,16
    800055c6:	8082                	ret

00000000800055c8 <exec>:

int
exec(char *path, char **argv)
{
    800055c8:	df010113          	addi	sp,sp,-528
    800055cc:	20113423          	sd	ra,520(sp)
    800055d0:	20813023          	sd	s0,512(sp)
    800055d4:	ffa6                	sd	s1,504(sp)
    800055d6:	fbca                	sd	s2,496(sp)
    800055d8:	f7ce                	sd	s3,488(sp)
    800055da:	f3d2                	sd	s4,480(sp)
    800055dc:	efd6                	sd	s5,472(sp)
    800055de:	ebda                	sd	s6,464(sp)
    800055e0:	e7de                	sd	s7,456(sp)
    800055e2:	e3e2                	sd	s8,448(sp)
    800055e4:	ff66                	sd	s9,440(sp)
    800055e6:	fb6a                	sd	s10,432(sp)
    800055e8:	f76e                	sd	s11,424(sp)
    800055ea:	0c00                	addi	s0,sp,528
    800055ec:	84aa                	mv	s1,a0
    800055ee:	dea43c23          	sd	a0,-520(s0)
    800055f2:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800055f6:	ffffc097          	auipc	ra,0xffffc
    800055fa:	5f4080e7          	jalr	1524(ra) # 80001bea <myproc>
    800055fe:	892a                	mv	s2,a0

  begin_op();
    80005600:	fffff097          	auipc	ra,0xfffff
    80005604:	474080e7          	jalr	1140(ra) # 80004a74 <begin_op>

  if((ip = namei(path)) == 0){
    80005608:	8526                	mv	a0,s1
    8000560a:	fffff097          	auipc	ra,0xfffff
    8000560e:	24e080e7          	jalr	590(ra) # 80004858 <namei>
    80005612:	c92d                	beqz	a0,80005684 <exec+0xbc>
    80005614:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005616:	fffff097          	auipc	ra,0xfffff
    8000561a:	a9c080e7          	jalr	-1380(ra) # 800040b2 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000561e:	04000713          	li	a4,64
    80005622:	4681                	li	a3,0
    80005624:	e5040613          	addi	a2,s0,-432
    80005628:	4581                	li	a1,0
    8000562a:	8526                	mv	a0,s1
    8000562c:	fffff097          	auipc	ra,0xfffff
    80005630:	d3a080e7          	jalr	-710(ra) # 80004366 <readi>
    80005634:	04000793          	li	a5,64
    80005638:	00f51a63          	bne	a0,a5,8000564c <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    8000563c:	e5042703          	lw	a4,-432(s0)
    80005640:	464c47b7          	lui	a5,0x464c4
    80005644:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005648:	04f70463          	beq	a4,a5,80005690 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000564c:	8526                	mv	a0,s1
    8000564e:	fffff097          	auipc	ra,0xfffff
    80005652:	cc6080e7          	jalr	-826(ra) # 80004314 <iunlockput>
    end_op();
    80005656:	fffff097          	auipc	ra,0xfffff
    8000565a:	49e080e7          	jalr	1182(ra) # 80004af4 <end_op>
  }
  return -1;
    8000565e:	557d                	li	a0,-1
}
    80005660:	20813083          	ld	ra,520(sp)
    80005664:	20013403          	ld	s0,512(sp)
    80005668:	74fe                	ld	s1,504(sp)
    8000566a:	795e                	ld	s2,496(sp)
    8000566c:	79be                	ld	s3,488(sp)
    8000566e:	7a1e                	ld	s4,480(sp)
    80005670:	6afe                	ld	s5,472(sp)
    80005672:	6b5e                	ld	s6,464(sp)
    80005674:	6bbe                	ld	s7,456(sp)
    80005676:	6c1e                	ld	s8,448(sp)
    80005678:	7cfa                	ld	s9,440(sp)
    8000567a:	7d5a                	ld	s10,432(sp)
    8000567c:	7dba                	ld	s11,424(sp)
    8000567e:	21010113          	addi	sp,sp,528
    80005682:	8082                	ret
    end_op();
    80005684:	fffff097          	auipc	ra,0xfffff
    80005688:	470080e7          	jalr	1136(ra) # 80004af4 <end_op>
    return -1;
    8000568c:	557d                	li	a0,-1
    8000568e:	bfc9                	j	80005660 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80005690:	854a                	mv	a0,s2
    80005692:	ffffc097          	auipc	ra,0xffffc
    80005696:	61e080e7          	jalr	1566(ra) # 80001cb0 <proc_pagetable>
    8000569a:	8baa                	mv	s7,a0
    8000569c:	d945                	beqz	a0,8000564c <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000569e:	e7042983          	lw	s3,-400(s0)
    800056a2:	e8845783          	lhu	a5,-376(s0)
    800056a6:	c7ad                	beqz	a5,80005710 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800056a8:	4a01                	li	s4,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800056aa:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    800056ac:	6c85                	lui	s9,0x1
    800056ae:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800056b2:	def43823          	sd	a5,-528(s0)
    800056b6:	ac0d                	j	800058e8 <exec+0x320>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800056b8:	00003517          	auipc	a0,0x3
    800056bc:	17050513          	addi	a0,a0,368 # 80008828 <syscalls+0x2a0>
    800056c0:	ffffb097          	auipc	ra,0xffffb
    800056c4:	e84080e7          	jalr	-380(ra) # 80000544 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800056c8:	8756                	mv	a4,s5
    800056ca:	012d86bb          	addw	a3,s11,s2
    800056ce:	4581                	li	a1,0
    800056d0:	8526                	mv	a0,s1
    800056d2:	fffff097          	auipc	ra,0xfffff
    800056d6:	c94080e7          	jalr	-876(ra) # 80004366 <readi>
    800056da:	2501                	sext.w	a0,a0
    800056dc:	1aaa9a63          	bne	s5,a0,80005890 <exec+0x2c8>
  for(i = 0; i < sz; i += PGSIZE){
    800056e0:	6785                	lui	a5,0x1
    800056e2:	0127893b          	addw	s2,a5,s2
    800056e6:	77fd                	lui	a5,0xfffff
    800056e8:	01478a3b          	addw	s4,a5,s4
    800056ec:	1f897563          	bgeu	s2,s8,800058d6 <exec+0x30e>
    pa = walkaddr(pagetable, va + i);
    800056f0:	02091593          	slli	a1,s2,0x20
    800056f4:	9181                	srli	a1,a1,0x20
    800056f6:	95ea                	add	a1,a1,s10
    800056f8:	855e                	mv	a0,s7
    800056fa:	ffffc097          	auipc	ra,0xffffc
    800056fe:	97e080e7          	jalr	-1666(ra) # 80001078 <walkaddr>
    80005702:	862a                	mv	a2,a0
    if(pa == 0)
    80005704:	d955                	beqz	a0,800056b8 <exec+0xf0>
      n = PGSIZE;
    80005706:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80005708:	fd9a70e3          	bgeu	s4,s9,800056c8 <exec+0x100>
      n = sz - i;
    8000570c:	8ad2                	mv	s5,s4
    8000570e:	bf6d                	j	800056c8 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005710:	4a01                	li	s4,0
  iunlockput(ip);
    80005712:	8526                	mv	a0,s1
    80005714:	fffff097          	auipc	ra,0xfffff
    80005718:	c00080e7          	jalr	-1024(ra) # 80004314 <iunlockput>
  end_op();
    8000571c:	fffff097          	auipc	ra,0xfffff
    80005720:	3d8080e7          	jalr	984(ra) # 80004af4 <end_op>
  p = myproc();
    80005724:	ffffc097          	auipc	ra,0xffffc
    80005728:	4c6080e7          	jalr	1222(ra) # 80001bea <myproc>
    8000572c:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    8000572e:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    80005732:	6785                	lui	a5,0x1
    80005734:	17fd                	addi	a5,a5,-1
    80005736:	9a3e                	add	s4,s4,a5
    80005738:	757d                	lui	a0,0xfffff
    8000573a:	00aa77b3          	and	a5,s4,a0
    8000573e:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005742:	4691                	li	a3,4
    80005744:	6609                	lui	a2,0x2
    80005746:	963e                	add	a2,a2,a5
    80005748:	85be                	mv	a1,a5
    8000574a:	855e                	mv	a0,s7
    8000574c:	ffffc097          	auipc	ra,0xffffc
    80005750:	ce0080e7          	jalr	-800(ra) # 8000142c <uvmalloc>
    80005754:	8b2a                	mv	s6,a0
  ip = 0;
    80005756:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005758:	12050c63          	beqz	a0,80005890 <exec+0x2c8>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000575c:	75f9                	lui	a1,0xffffe
    8000575e:	95aa                	add	a1,a1,a0
    80005760:	855e                	mv	a0,s7
    80005762:	ffffc097          	auipc	ra,0xffffc
    80005766:	ef0080e7          	jalr	-272(ra) # 80001652 <uvmclear>
  stackbase = sp - PGSIZE;
    8000576a:	7c7d                	lui	s8,0xfffff
    8000576c:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    8000576e:	e0043783          	ld	a5,-512(s0)
    80005772:	6388                	ld	a0,0(a5)
    80005774:	c535                	beqz	a0,800057e0 <exec+0x218>
    80005776:	e9040993          	addi	s3,s0,-368
    8000577a:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    8000577e:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80005780:	ffffb097          	auipc	ra,0xffffb
    80005784:	6ea080e7          	jalr	1770(ra) # 80000e6a <strlen>
    80005788:	2505                	addiw	a0,a0,1
    8000578a:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000578e:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005792:	13896663          	bltu	s2,s8,800058be <exec+0x2f6>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005796:	e0043d83          	ld	s11,-512(s0)
    8000579a:	000dba03          	ld	s4,0(s11)
    8000579e:	8552                	mv	a0,s4
    800057a0:	ffffb097          	auipc	ra,0xffffb
    800057a4:	6ca080e7          	jalr	1738(ra) # 80000e6a <strlen>
    800057a8:	0015069b          	addiw	a3,a0,1
    800057ac:	8652                	mv	a2,s4
    800057ae:	85ca                	mv	a1,s2
    800057b0:	855e                	mv	a0,s7
    800057b2:	ffffc097          	auipc	ra,0xffffc
    800057b6:	ed2080e7          	jalr	-302(ra) # 80001684 <copyout>
    800057ba:	10054663          	bltz	a0,800058c6 <exec+0x2fe>
    ustack[argc] = sp;
    800057be:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800057c2:	0485                	addi	s1,s1,1
    800057c4:	008d8793          	addi	a5,s11,8
    800057c8:	e0f43023          	sd	a5,-512(s0)
    800057cc:	008db503          	ld	a0,8(s11)
    800057d0:	c911                	beqz	a0,800057e4 <exec+0x21c>
    if(argc >= MAXARG)
    800057d2:	09a1                	addi	s3,s3,8
    800057d4:	fb3c96e3          	bne	s9,s3,80005780 <exec+0x1b8>
  sz = sz1;
    800057d8:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800057dc:	4481                	li	s1,0
    800057de:	a84d                	j	80005890 <exec+0x2c8>
  sp = sz;
    800057e0:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    800057e2:	4481                	li	s1,0
  ustack[argc] = 0;
    800057e4:	00349793          	slli	a5,s1,0x3
    800057e8:	f9040713          	addi	a4,s0,-112
    800057ec:	97ba                	add	a5,a5,a4
    800057ee:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    800057f2:	00148693          	addi	a3,s1,1
    800057f6:	068e                	slli	a3,a3,0x3
    800057f8:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800057fc:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005800:	01897663          	bgeu	s2,s8,8000580c <exec+0x244>
  sz = sz1;
    80005804:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005808:	4481                	li	s1,0
    8000580a:	a059                	j	80005890 <exec+0x2c8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000580c:	e9040613          	addi	a2,s0,-368
    80005810:	85ca                	mv	a1,s2
    80005812:	855e                	mv	a0,s7
    80005814:	ffffc097          	auipc	ra,0xffffc
    80005818:	e70080e7          	jalr	-400(ra) # 80001684 <copyout>
    8000581c:	0a054963          	bltz	a0,800058ce <exec+0x306>
  p->trapframe->a1 = sp;
    80005820:	060ab783          	ld	a5,96(s5)
    80005824:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005828:	df843783          	ld	a5,-520(s0)
    8000582c:	0007c703          	lbu	a4,0(a5)
    80005830:	cf11                	beqz	a4,8000584c <exec+0x284>
    80005832:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005834:	02f00693          	li	a3,47
    80005838:	a039                	j	80005846 <exec+0x27e>
      last = s+1;
    8000583a:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    8000583e:	0785                	addi	a5,a5,1
    80005840:	fff7c703          	lbu	a4,-1(a5)
    80005844:	c701                	beqz	a4,8000584c <exec+0x284>
    if(*s == '/')
    80005846:	fed71ce3          	bne	a4,a3,8000583e <exec+0x276>
    8000584a:	bfc5                	j	8000583a <exec+0x272>
  safestrcpy(p->name, last, sizeof(p->name));
    8000584c:	4641                	li	a2,16
    8000584e:	df843583          	ld	a1,-520(s0)
    80005852:	160a8513          	addi	a0,s5,352
    80005856:	ffffb097          	auipc	ra,0xffffb
    8000585a:	5e2080e7          	jalr	1506(ra) # 80000e38 <safestrcpy>
  oldpagetable = p->pagetable;
    8000585e:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    80005862:	057abc23          	sd	s7,88(s5)
  p->sz = sz;
    80005866:	056ab823          	sd	s6,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000586a:	060ab783          	ld	a5,96(s5)
    8000586e:	e6843703          	ld	a4,-408(s0)
    80005872:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005874:	060ab783          	ld	a5,96(s5)
    80005878:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000587c:	85ea                	mv	a1,s10
    8000587e:	ffffc097          	auipc	ra,0xffffc
    80005882:	4ce080e7          	jalr	1230(ra) # 80001d4c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005886:	0004851b          	sext.w	a0,s1
    8000588a:	bbd9                	j	80005660 <exec+0x98>
    8000588c:	e1443423          	sd	s4,-504(s0)
    proc_freepagetable(pagetable, sz);
    80005890:	e0843583          	ld	a1,-504(s0)
    80005894:	855e                	mv	a0,s7
    80005896:	ffffc097          	auipc	ra,0xffffc
    8000589a:	4b6080e7          	jalr	1206(ra) # 80001d4c <proc_freepagetable>
  if(ip){
    8000589e:	da0497e3          	bnez	s1,8000564c <exec+0x84>
  return -1;
    800058a2:	557d                	li	a0,-1
    800058a4:	bb75                	j	80005660 <exec+0x98>
    800058a6:	e1443423          	sd	s4,-504(s0)
    800058aa:	b7dd                	j	80005890 <exec+0x2c8>
    800058ac:	e1443423          	sd	s4,-504(s0)
    800058b0:	b7c5                	j	80005890 <exec+0x2c8>
    800058b2:	e1443423          	sd	s4,-504(s0)
    800058b6:	bfe9                	j	80005890 <exec+0x2c8>
    800058b8:	e1443423          	sd	s4,-504(s0)
    800058bc:	bfd1                	j	80005890 <exec+0x2c8>
  sz = sz1;
    800058be:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800058c2:	4481                	li	s1,0
    800058c4:	b7f1                	j	80005890 <exec+0x2c8>
  sz = sz1;
    800058c6:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800058ca:	4481                	li	s1,0
    800058cc:	b7d1                	j	80005890 <exec+0x2c8>
  sz = sz1;
    800058ce:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800058d2:	4481                	li	s1,0
    800058d4:	bf75                	j	80005890 <exec+0x2c8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800058d6:	e0843a03          	ld	s4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800058da:	2b05                	addiw	s6,s6,1
    800058dc:	0389899b          	addiw	s3,s3,56
    800058e0:	e8845783          	lhu	a5,-376(s0)
    800058e4:	e2fb57e3          	bge	s6,a5,80005712 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800058e8:	2981                	sext.w	s3,s3
    800058ea:	03800713          	li	a4,56
    800058ee:	86ce                	mv	a3,s3
    800058f0:	e1840613          	addi	a2,s0,-488
    800058f4:	4581                	li	a1,0
    800058f6:	8526                	mv	a0,s1
    800058f8:	fffff097          	auipc	ra,0xfffff
    800058fc:	a6e080e7          	jalr	-1426(ra) # 80004366 <readi>
    80005900:	03800793          	li	a5,56
    80005904:	f8f514e3          	bne	a0,a5,8000588c <exec+0x2c4>
    if(ph.type != ELF_PROG_LOAD)
    80005908:	e1842783          	lw	a5,-488(s0)
    8000590c:	4705                	li	a4,1
    8000590e:	fce796e3          	bne	a5,a4,800058da <exec+0x312>
    if(ph.memsz < ph.filesz)
    80005912:	e4043903          	ld	s2,-448(s0)
    80005916:	e3843783          	ld	a5,-456(s0)
    8000591a:	f8f966e3          	bltu	s2,a5,800058a6 <exec+0x2de>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000591e:	e2843783          	ld	a5,-472(s0)
    80005922:	993e                	add	s2,s2,a5
    80005924:	f8f964e3          	bltu	s2,a5,800058ac <exec+0x2e4>
    if(ph.vaddr % PGSIZE != 0)
    80005928:	df043703          	ld	a4,-528(s0)
    8000592c:	8ff9                	and	a5,a5,a4
    8000592e:	f3d1                	bnez	a5,800058b2 <exec+0x2ea>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005930:	e1c42503          	lw	a0,-484(s0)
    80005934:	00000097          	auipc	ra,0x0
    80005938:	c78080e7          	jalr	-904(ra) # 800055ac <flags2perm>
    8000593c:	86aa                	mv	a3,a0
    8000593e:	864a                	mv	a2,s2
    80005940:	85d2                	mv	a1,s4
    80005942:	855e                	mv	a0,s7
    80005944:	ffffc097          	auipc	ra,0xffffc
    80005948:	ae8080e7          	jalr	-1304(ra) # 8000142c <uvmalloc>
    8000594c:	e0a43423          	sd	a0,-504(s0)
    80005950:	d525                	beqz	a0,800058b8 <exec+0x2f0>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005952:	e2843d03          	ld	s10,-472(s0)
    80005956:	e2042d83          	lw	s11,-480(s0)
    8000595a:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000595e:	f60c0ce3          	beqz	s8,800058d6 <exec+0x30e>
    80005962:	8a62                	mv	s4,s8
    80005964:	4901                	li	s2,0
    80005966:	b369                	j	800056f0 <exec+0x128>

0000000080005968 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005968:	7179                	addi	sp,sp,-48
    8000596a:	f406                	sd	ra,40(sp)
    8000596c:	f022                	sd	s0,32(sp)
    8000596e:	ec26                	sd	s1,24(sp)
    80005970:	e84a                	sd	s2,16(sp)
    80005972:	1800                	addi	s0,sp,48
    80005974:	892e                	mv	s2,a1
    80005976:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005978:	fdc40593          	addi	a1,s0,-36
    8000597c:	ffffe097          	auipc	ra,0xffffe
    80005980:	914080e7          	jalr	-1772(ra) # 80003290 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005984:	fdc42703          	lw	a4,-36(s0)
    80005988:	47bd                	li	a5,15
    8000598a:	02e7eb63          	bltu	a5,a4,800059c0 <argfd+0x58>
    8000598e:	ffffc097          	auipc	ra,0xffffc
    80005992:	25c080e7          	jalr	604(ra) # 80001bea <myproc>
    80005996:	fdc42703          	lw	a4,-36(s0)
    8000599a:	01a70793          	addi	a5,a4,26
    8000599e:	078e                	slli	a5,a5,0x3
    800059a0:	953e                	add	a0,a0,a5
    800059a2:	651c                	ld	a5,8(a0)
    800059a4:	c385                	beqz	a5,800059c4 <argfd+0x5c>
    return -1;
  if(pfd)
    800059a6:	00090463          	beqz	s2,800059ae <argfd+0x46>
    *pfd = fd;
    800059aa:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800059ae:	4501                	li	a0,0
  if(pf)
    800059b0:	c091                	beqz	s1,800059b4 <argfd+0x4c>
    *pf = f;
    800059b2:	e09c                	sd	a5,0(s1)
}
    800059b4:	70a2                	ld	ra,40(sp)
    800059b6:	7402                	ld	s0,32(sp)
    800059b8:	64e2                	ld	s1,24(sp)
    800059ba:	6942                	ld	s2,16(sp)
    800059bc:	6145                	addi	sp,sp,48
    800059be:	8082                	ret
    return -1;
    800059c0:	557d                	li	a0,-1
    800059c2:	bfcd                	j	800059b4 <argfd+0x4c>
    800059c4:	557d                	li	a0,-1
    800059c6:	b7fd                	j	800059b4 <argfd+0x4c>

00000000800059c8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800059c8:	1101                	addi	sp,sp,-32
    800059ca:	ec06                	sd	ra,24(sp)
    800059cc:	e822                	sd	s0,16(sp)
    800059ce:	e426                	sd	s1,8(sp)
    800059d0:	1000                	addi	s0,sp,32
    800059d2:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800059d4:	ffffc097          	auipc	ra,0xffffc
    800059d8:	216080e7          	jalr	534(ra) # 80001bea <myproc>
    800059dc:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800059de:	0d850793          	addi	a5,a0,216 # fffffffffffff0d8 <end+0xffffffff7ffdac00>
    800059e2:	4501                	li	a0,0
    800059e4:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800059e6:	6398                	ld	a4,0(a5)
    800059e8:	cb19                	beqz	a4,800059fe <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800059ea:	2505                	addiw	a0,a0,1
    800059ec:	07a1                	addi	a5,a5,8
    800059ee:	fed51ce3          	bne	a0,a3,800059e6 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800059f2:	557d                	li	a0,-1
}
    800059f4:	60e2                	ld	ra,24(sp)
    800059f6:	6442                	ld	s0,16(sp)
    800059f8:	64a2                	ld	s1,8(sp)
    800059fa:	6105                	addi	sp,sp,32
    800059fc:	8082                	ret
      p->ofile[fd] = f;
    800059fe:	01a50793          	addi	a5,a0,26
    80005a02:	078e                	slli	a5,a5,0x3
    80005a04:	963e                	add	a2,a2,a5
    80005a06:	e604                	sd	s1,8(a2)
      return fd;
    80005a08:	b7f5                	j	800059f4 <fdalloc+0x2c>

0000000080005a0a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005a0a:	715d                	addi	sp,sp,-80
    80005a0c:	e486                	sd	ra,72(sp)
    80005a0e:	e0a2                	sd	s0,64(sp)
    80005a10:	fc26                	sd	s1,56(sp)
    80005a12:	f84a                	sd	s2,48(sp)
    80005a14:	f44e                	sd	s3,40(sp)
    80005a16:	f052                	sd	s4,32(sp)
    80005a18:	ec56                	sd	s5,24(sp)
    80005a1a:	e85a                	sd	s6,16(sp)
    80005a1c:	0880                	addi	s0,sp,80
    80005a1e:	8b2e                	mv	s6,a1
    80005a20:	89b2                	mv	s3,a2
    80005a22:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005a24:	fb040593          	addi	a1,s0,-80
    80005a28:	fffff097          	auipc	ra,0xfffff
    80005a2c:	e4e080e7          	jalr	-434(ra) # 80004876 <nameiparent>
    80005a30:	84aa                	mv	s1,a0
    80005a32:	16050063          	beqz	a0,80005b92 <create+0x188>
    return 0;

  ilock(dp);
    80005a36:	ffffe097          	auipc	ra,0xffffe
    80005a3a:	67c080e7          	jalr	1660(ra) # 800040b2 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005a3e:	4601                	li	a2,0
    80005a40:	fb040593          	addi	a1,s0,-80
    80005a44:	8526                	mv	a0,s1
    80005a46:	fffff097          	auipc	ra,0xfffff
    80005a4a:	b50080e7          	jalr	-1200(ra) # 80004596 <dirlookup>
    80005a4e:	8aaa                	mv	s5,a0
    80005a50:	c931                	beqz	a0,80005aa4 <create+0x9a>
    iunlockput(dp);
    80005a52:	8526                	mv	a0,s1
    80005a54:	fffff097          	auipc	ra,0xfffff
    80005a58:	8c0080e7          	jalr	-1856(ra) # 80004314 <iunlockput>
    ilock(ip);
    80005a5c:	8556                	mv	a0,s5
    80005a5e:	ffffe097          	auipc	ra,0xffffe
    80005a62:	654080e7          	jalr	1620(ra) # 800040b2 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005a66:	000b059b          	sext.w	a1,s6
    80005a6a:	4789                	li	a5,2
    80005a6c:	02f59563          	bne	a1,a5,80005a96 <create+0x8c>
    80005a70:	044ad783          	lhu	a5,68(s5)
    80005a74:	37f9                	addiw	a5,a5,-2
    80005a76:	17c2                	slli	a5,a5,0x30
    80005a78:	93c1                	srli	a5,a5,0x30
    80005a7a:	4705                	li	a4,1
    80005a7c:	00f76d63          	bltu	a4,a5,80005a96 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005a80:	8556                	mv	a0,s5
    80005a82:	60a6                	ld	ra,72(sp)
    80005a84:	6406                	ld	s0,64(sp)
    80005a86:	74e2                	ld	s1,56(sp)
    80005a88:	7942                	ld	s2,48(sp)
    80005a8a:	79a2                	ld	s3,40(sp)
    80005a8c:	7a02                	ld	s4,32(sp)
    80005a8e:	6ae2                	ld	s5,24(sp)
    80005a90:	6b42                	ld	s6,16(sp)
    80005a92:	6161                	addi	sp,sp,80
    80005a94:	8082                	ret
    iunlockput(ip);
    80005a96:	8556                	mv	a0,s5
    80005a98:	fffff097          	auipc	ra,0xfffff
    80005a9c:	87c080e7          	jalr	-1924(ra) # 80004314 <iunlockput>
    return 0;
    80005aa0:	4a81                	li	s5,0
    80005aa2:	bff9                	j	80005a80 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005aa4:	85da                	mv	a1,s6
    80005aa6:	4088                	lw	a0,0(s1)
    80005aa8:	ffffe097          	auipc	ra,0xffffe
    80005aac:	46e080e7          	jalr	1134(ra) # 80003f16 <ialloc>
    80005ab0:	8a2a                	mv	s4,a0
    80005ab2:	c921                	beqz	a0,80005b02 <create+0xf8>
  ilock(ip);
    80005ab4:	ffffe097          	auipc	ra,0xffffe
    80005ab8:	5fe080e7          	jalr	1534(ra) # 800040b2 <ilock>
  ip->major = major;
    80005abc:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005ac0:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005ac4:	4785                	li	a5,1
    80005ac6:	04fa1523          	sh	a5,74(s4)
  iupdate(ip);
    80005aca:	8552                	mv	a0,s4
    80005acc:	ffffe097          	auipc	ra,0xffffe
    80005ad0:	51c080e7          	jalr	1308(ra) # 80003fe8 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005ad4:	000b059b          	sext.w	a1,s6
    80005ad8:	4785                	li	a5,1
    80005ada:	02f58b63          	beq	a1,a5,80005b10 <create+0x106>
  if(dirlink(dp, name, ip->inum) < 0)
    80005ade:	004a2603          	lw	a2,4(s4)
    80005ae2:	fb040593          	addi	a1,s0,-80
    80005ae6:	8526                	mv	a0,s1
    80005ae8:	fffff097          	auipc	ra,0xfffff
    80005aec:	cbe080e7          	jalr	-834(ra) # 800047a6 <dirlink>
    80005af0:	06054f63          	bltz	a0,80005b6e <create+0x164>
  iunlockput(dp);
    80005af4:	8526                	mv	a0,s1
    80005af6:	fffff097          	auipc	ra,0xfffff
    80005afa:	81e080e7          	jalr	-2018(ra) # 80004314 <iunlockput>
  return ip;
    80005afe:	8ad2                	mv	s5,s4
    80005b00:	b741                	j	80005a80 <create+0x76>
    iunlockput(dp);
    80005b02:	8526                	mv	a0,s1
    80005b04:	fffff097          	auipc	ra,0xfffff
    80005b08:	810080e7          	jalr	-2032(ra) # 80004314 <iunlockput>
    return 0;
    80005b0c:	8ad2                	mv	s5,s4
    80005b0e:	bf8d                	j	80005a80 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005b10:	004a2603          	lw	a2,4(s4)
    80005b14:	00003597          	auipc	a1,0x3
    80005b18:	d3458593          	addi	a1,a1,-716 # 80008848 <syscalls+0x2c0>
    80005b1c:	8552                	mv	a0,s4
    80005b1e:	fffff097          	auipc	ra,0xfffff
    80005b22:	c88080e7          	jalr	-888(ra) # 800047a6 <dirlink>
    80005b26:	04054463          	bltz	a0,80005b6e <create+0x164>
    80005b2a:	40d0                	lw	a2,4(s1)
    80005b2c:	00003597          	auipc	a1,0x3
    80005b30:	d2458593          	addi	a1,a1,-732 # 80008850 <syscalls+0x2c8>
    80005b34:	8552                	mv	a0,s4
    80005b36:	fffff097          	auipc	ra,0xfffff
    80005b3a:	c70080e7          	jalr	-912(ra) # 800047a6 <dirlink>
    80005b3e:	02054863          	bltz	a0,80005b6e <create+0x164>
  if(dirlink(dp, name, ip->inum) < 0)
    80005b42:	004a2603          	lw	a2,4(s4)
    80005b46:	fb040593          	addi	a1,s0,-80
    80005b4a:	8526                	mv	a0,s1
    80005b4c:	fffff097          	auipc	ra,0xfffff
    80005b50:	c5a080e7          	jalr	-934(ra) # 800047a6 <dirlink>
    80005b54:	00054d63          	bltz	a0,80005b6e <create+0x164>
    dp->nlink++;  // for ".."
    80005b58:	04a4d783          	lhu	a5,74(s1)
    80005b5c:	2785                	addiw	a5,a5,1
    80005b5e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005b62:	8526                	mv	a0,s1
    80005b64:	ffffe097          	auipc	ra,0xffffe
    80005b68:	484080e7          	jalr	1156(ra) # 80003fe8 <iupdate>
    80005b6c:	b761                	j	80005af4 <create+0xea>
  ip->nlink = 0;
    80005b6e:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005b72:	8552                	mv	a0,s4
    80005b74:	ffffe097          	auipc	ra,0xffffe
    80005b78:	474080e7          	jalr	1140(ra) # 80003fe8 <iupdate>
  iunlockput(ip);
    80005b7c:	8552                	mv	a0,s4
    80005b7e:	ffffe097          	auipc	ra,0xffffe
    80005b82:	796080e7          	jalr	1942(ra) # 80004314 <iunlockput>
  iunlockput(dp);
    80005b86:	8526                	mv	a0,s1
    80005b88:	ffffe097          	auipc	ra,0xffffe
    80005b8c:	78c080e7          	jalr	1932(ra) # 80004314 <iunlockput>
  return 0;
    80005b90:	bdc5                	j	80005a80 <create+0x76>
    return 0;
    80005b92:	8aaa                	mv	s5,a0
    80005b94:	b5f5                	j	80005a80 <create+0x76>

0000000080005b96 <sys_dup>:
{
    80005b96:	7179                	addi	sp,sp,-48
    80005b98:	f406                	sd	ra,40(sp)
    80005b9a:	f022                	sd	s0,32(sp)
    80005b9c:	ec26                	sd	s1,24(sp)
    80005b9e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005ba0:	fd840613          	addi	a2,s0,-40
    80005ba4:	4581                	li	a1,0
    80005ba6:	4501                	li	a0,0
    80005ba8:	00000097          	auipc	ra,0x0
    80005bac:	dc0080e7          	jalr	-576(ra) # 80005968 <argfd>
    return -1;
    80005bb0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005bb2:	02054363          	bltz	a0,80005bd8 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005bb6:	fd843503          	ld	a0,-40(s0)
    80005bba:	00000097          	auipc	ra,0x0
    80005bbe:	e0e080e7          	jalr	-498(ra) # 800059c8 <fdalloc>
    80005bc2:	84aa                	mv	s1,a0
    return -1;
    80005bc4:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005bc6:	00054963          	bltz	a0,80005bd8 <sys_dup+0x42>
  filedup(f);
    80005bca:	fd843503          	ld	a0,-40(s0)
    80005bce:	fffff097          	auipc	ra,0xfffff
    80005bd2:	320080e7          	jalr	800(ra) # 80004eee <filedup>
  return fd;
    80005bd6:	87a6                	mv	a5,s1
}
    80005bd8:	853e                	mv	a0,a5
    80005bda:	70a2                	ld	ra,40(sp)
    80005bdc:	7402                	ld	s0,32(sp)
    80005bde:	64e2                	ld	s1,24(sp)
    80005be0:	6145                	addi	sp,sp,48
    80005be2:	8082                	ret

0000000080005be4 <sys_read>:
{
    80005be4:	7179                	addi	sp,sp,-48
    80005be6:	f406                	sd	ra,40(sp)
    80005be8:	f022                	sd	s0,32(sp)
    80005bea:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005bec:	fd840593          	addi	a1,s0,-40
    80005bf0:	4505                	li	a0,1
    80005bf2:	ffffd097          	auipc	ra,0xffffd
    80005bf6:	6be080e7          	jalr	1726(ra) # 800032b0 <argaddr>
  argint(2, &n);
    80005bfa:	fe440593          	addi	a1,s0,-28
    80005bfe:	4509                	li	a0,2
    80005c00:	ffffd097          	auipc	ra,0xffffd
    80005c04:	690080e7          	jalr	1680(ra) # 80003290 <argint>
  if(argfd(0, 0, &f) < 0)
    80005c08:	fe840613          	addi	a2,s0,-24
    80005c0c:	4581                	li	a1,0
    80005c0e:	4501                	li	a0,0
    80005c10:	00000097          	auipc	ra,0x0
    80005c14:	d58080e7          	jalr	-680(ra) # 80005968 <argfd>
    80005c18:	87aa                	mv	a5,a0
    return -1;
    80005c1a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005c1c:	0007cc63          	bltz	a5,80005c34 <sys_read+0x50>
  return fileread(f, p, n);
    80005c20:	fe442603          	lw	a2,-28(s0)
    80005c24:	fd843583          	ld	a1,-40(s0)
    80005c28:	fe843503          	ld	a0,-24(s0)
    80005c2c:	fffff097          	auipc	ra,0xfffff
    80005c30:	44e080e7          	jalr	1102(ra) # 8000507a <fileread>
}
    80005c34:	70a2                	ld	ra,40(sp)
    80005c36:	7402                	ld	s0,32(sp)
    80005c38:	6145                	addi	sp,sp,48
    80005c3a:	8082                	ret

0000000080005c3c <sys_write>:
{
    80005c3c:	7179                	addi	sp,sp,-48
    80005c3e:	f406                	sd	ra,40(sp)
    80005c40:	f022                	sd	s0,32(sp)
    80005c42:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005c44:	fd840593          	addi	a1,s0,-40
    80005c48:	4505                	li	a0,1
    80005c4a:	ffffd097          	auipc	ra,0xffffd
    80005c4e:	666080e7          	jalr	1638(ra) # 800032b0 <argaddr>
  argint(2, &n);
    80005c52:	fe440593          	addi	a1,s0,-28
    80005c56:	4509                	li	a0,2
    80005c58:	ffffd097          	auipc	ra,0xffffd
    80005c5c:	638080e7          	jalr	1592(ra) # 80003290 <argint>
  if(argfd(0, 0, &f) < 0)
    80005c60:	fe840613          	addi	a2,s0,-24
    80005c64:	4581                	li	a1,0
    80005c66:	4501                	li	a0,0
    80005c68:	00000097          	auipc	ra,0x0
    80005c6c:	d00080e7          	jalr	-768(ra) # 80005968 <argfd>
    80005c70:	87aa                	mv	a5,a0
    return -1;
    80005c72:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005c74:	0007cc63          	bltz	a5,80005c8c <sys_write+0x50>
  return filewrite(f, p, n);
    80005c78:	fe442603          	lw	a2,-28(s0)
    80005c7c:	fd843583          	ld	a1,-40(s0)
    80005c80:	fe843503          	ld	a0,-24(s0)
    80005c84:	fffff097          	auipc	ra,0xfffff
    80005c88:	4b8080e7          	jalr	1208(ra) # 8000513c <filewrite>
}
    80005c8c:	70a2                	ld	ra,40(sp)
    80005c8e:	7402                	ld	s0,32(sp)
    80005c90:	6145                	addi	sp,sp,48
    80005c92:	8082                	ret

0000000080005c94 <sys_close>:
{
    80005c94:	1101                	addi	sp,sp,-32
    80005c96:	ec06                	sd	ra,24(sp)
    80005c98:	e822                	sd	s0,16(sp)
    80005c9a:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005c9c:	fe040613          	addi	a2,s0,-32
    80005ca0:	fec40593          	addi	a1,s0,-20
    80005ca4:	4501                	li	a0,0
    80005ca6:	00000097          	auipc	ra,0x0
    80005caa:	cc2080e7          	jalr	-830(ra) # 80005968 <argfd>
    return -1;
    80005cae:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005cb0:	02054463          	bltz	a0,80005cd8 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005cb4:	ffffc097          	auipc	ra,0xffffc
    80005cb8:	f36080e7          	jalr	-202(ra) # 80001bea <myproc>
    80005cbc:	fec42783          	lw	a5,-20(s0)
    80005cc0:	07e9                	addi	a5,a5,26
    80005cc2:	078e                	slli	a5,a5,0x3
    80005cc4:	97aa                	add	a5,a5,a0
    80005cc6:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    80005cca:	fe043503          	ld	a0,-32(s0)
    80005cce:	fffff097          	auipc	ra,0xfffff
    80005cd2:	272080e7          	jalr	626(ra) # 80004f40 <fileclose>
  return 0;
    80005cd6:	4781                	li	a5,0
}
    80005cd8:	853e                	mv	a0,a5
    80005cda:	60e2                	ld	ra,24(sp)
    80005cdc:	6442                	ld	s0,16(sp)
    80005cde:	6105                	addi	sp,sp,32
    80005ce0:	8082                	ret

0000000080005ce2 <sys_fstat>:
{
    80005ce2:	1101                	addi	sp,sp,-32
    80005ce4:	ec06                	sd	ra,24(sp)
    80005ce6:	e822                	sd	s0,16(sp)
    80005ce8:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005cea:	fe040593          	addi	a1,s0,-32
    80005cee:	4505                	li	a0,1
    80005cf0:	ffffd097          	auipc	ra,0xffffd
    80005cf4:	5c0080e7          	jalr	1472(ra) # 800032b0 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005cf8:	fe840613          	addi	a2,s0,-24
    80005cfc:	4581                	li	a1,0
    80005cfe:	4501                	li	a0,0
    80005d00:	00000097          	auipc	ra,0x0
    80005d04:	c68080e7          	jalr	-920(ra) # 80005968 <argfd>
    80005d08:	87aa                	mv	a5,a0
    return -1;
    80005d0a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005d0c:	0007ca63          	bltz	a5,80005d20 <sys_fstat+0x3e>
  return filestat(f, st);
    80005d10:	fe043583          	ld	a1,-32(s0)
    80005d14:	fe843503          	ld	a0,-24(s0)
    80005d18:	fffff097          	auipc	ra,0xfffff
    80005d1c:	2f0080e7          	jalr	752(ra) # 80005008 <filestat>
}
    80005d20:	60e2                	ld	ra,24(sp)
    80005d22:	6442                	ld	s0,16(sp)
    80005d24:	6105                	addi	sp,sp,32
    80005d26:	8082                	ret

0000000080005d28 <sys_link>:
{
    80005d28:	7169                	addi	sp,sp,-304
    80005d2a:	f606                	sd	ra,296(sp)
    80005d2c:	f222                	sd	s0,288(sp)
    80005d2e:	ee26                	sd	s1,280(sp)
    80005d30:	ea4a                	sd	s2,272(sp)
    80005d32:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005d34:	08000613          	li	a2,128
    80005d38:	ed040593          	addi	a1,s0,-304
    80005d3c:	4501                	li	a0,0
    80005d3e:	ffffd097          	auipc	ra,0xffffd
    80005d42:	592080e7          	jalr	1426(ra) # 800032d0 <argstr>
    return -1;
    80005d46:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005d48:	10054e63          	bltz	a0,80005e64 <sys_link+0x13c>
    80005d4c:	08000613          	li	a2,128
    80005d50:	f5040593          	addi	a1,s0,-176
    80005d54:	4505                	li	a0,1
    80005d56:	ffffd097          	auipc	ra,0xffffd
    80005d5a:	57a080e7          	jalr	1402(ra) # 800032d0 <argstr>
    return -1;
    80005d5e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005d60:	10054263          	bltz	a0,80005e64 <sys_link+0x13c>
  begin_op();
    80005d64:	fffff097          	auipc	ra,0xfffff
    80005d68:	d10080e7          	jalr	-752(ra) # 80004a74 <begin_op>
  if((ip = namei(old)) == 0){
    80005d6c:	ed040513          	addi	a0,s0,-304
    80005d70:	fffff097          	auipc	ra,0xfffff
    80005d74:	ae8080e7          	jalr	-1304(ra) # 80004858 <namei>
    80005d78:	84aa                	mv	s1,a0
    80005d7a:	c551                	beqz	a0,80005e06 <sys_link+0xde>
  ilock(ip);
    80005d7c:	ffffe097          	auipc	ra,0xffffe
    80005d80:	336080e7          	jalr	822(ra) # 800040b2 <ilock>
  if(ip->type == T_DIR){
    80005d84:	04449703          	lh	a4,68(s1)
    80005d88:	4785                	li	a5,1
    80005d8a:	08f70463          	beq	a4,a5,80005e12 <sys_link+0xea>
  ip->nlink++;
    80005d8e:	04a4d783          	lhu	a5,74(s1)
    80005d92:	2785                	addiw	a5,a5,1
    80005d94:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005d98:	8526                	mv	a0,s1
    80005d9a:	ffffe097          	auipc	ra,0xffffe
    80005d9e:	24e080e7          	jalr	590(ra) # 80003fe8 <iupdate>
  iunlock(ip);
    80005da2:	8526                	mv	a0,s1
    80005da4:	ffffe097          	auipc	ra,0xffffe
    80005da8:	3d0080e7          	jalr	976(ra) # 80004174 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005dac:	fd040593          	addi	a1,s0,-48
    80005db0:	f5040513          	addi	a0,s0,-176
    80005db4:	fffff097          	auipc	ra,0xfffff
    80005db8:	ac2080e7          	jalr	-1342(ra) # 80004876 <nameiparent>
    80005dbc:	892a                	mv	s2,a0
    80005dbe:	c935                	beqz	a0,80005e32 <sys_link+0x10a>
  ilock(dp);
    80005dc0:	ffffe097          	auipc	ra,0xffffe
    80005dc4:	2f2080e7          	jalr	754(ra) # 800040b2 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005dc8:	00092703          	lw	a4,0(s2)
    80005dcc:	409c                	lw	a5,0(s1)
    80005dce:	04f71d63          	bne	a4,a5,80005e28 <sys_link+0x100>
    80005dd2:	40d0                	lw	a2,4(s1)
    80005dd4:	fd040593          	addi	a1,s0,-48
    80005dd8:	854a                	mv	a0,s2
    80005dda:	fffff097          	auipc	ra,0xfffff
    80005dde:	9cc080e7          	jalr	-1588(ra) # 800047a6 <dirlink>
    80005de2:	04054363          	bltz	a0,80005e28 <sys_link+0x100>
  iunlockput(dp);
    80005de6:	854a                	mv	a0,s2
    80005de8:	ffffe097          	auipc	ra,0xffffe
    80005dec:	52c080e7          	jalr	1324(ra) # 80004314 <iunlockput>
  iput(ip);
    80005df0:	8526                	mv	a0,s1
    80005df2:	ffffe097          	auipc	ra,0xffffe
    80005df6:	47a080e7          	jalr	1146(ra) # 8000426c <iput>
  end_op();
    80005dfa:	fffff097          	auipc	ra,0xfffff
    80005dfe:	cfa080e7          	jalr	-774(ra) # 80004af4 <end_op>
  return 0;
    80005e02:	4781                	li	a5,0
    80005e04:	a085                	j	80005e64 <sys_link+0x13c>
    end_op();
    80005e06:	fffff097          	auipc	ra,0xfffff
    80005e0a:	cee080e7          	jalr	-786(ra) # 80004af4 <end_op>
    return -1;
    80005e0e:	57fd                	li	a5,-1
    80005e10:	a891                	j	80005e64 <sys_link+0x13c>
    iunlockput(ip);
    80005e12:	8526                	mv	a0,s1
    80005e14:	ffffe097          	auipc	ra,0xffffe
    80005e18:	500080e7          	jalr	1280(ra) # 80004314 <iunlockput>
    end_op();
    80005e1c:	fffff097          	auipc	ra,0xfffff
    80005e20:	cd8080e7          	jalr	-808(ra) # 80004af4 <end_op>
    return -1;
    80005e24:	57fd                	li	a5,-1
    80005e26:	a83d                	j	80005e64 <sys_link+0x13c>
    iunlockput(dp);
    80005e28:	854a                	mv	a0,s2
    80005e2a:	ffffe097          	auipc	ra,0xffffe
    80005e2e:	4ea080e7          	jalr	1258(ra) # 80004314 <iunlockput>
  ilock(ip);
    80005e32:	8526                	mv	a0,s1
    80005e34:	ffffe097          	auipc	ra,0xffffe
    80005e38:	27e080e7          	jalr	638(ra) # 800040b2 <ilock>
  ip->nlink--;
    80005e3c:	04a4d783          	lhu	a5,74(s1)
    80005e40:	37fd                	addiw	a5,a5,-1
    80005e42:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005e46:	8526                	mv	a0,s1
    80005e48:	ffffe097          	auipc	ra,0xffffe
    80005e4c:	1a0080e7          	jalr	416(ra) # 80003fe8 <iupdate>
  iunlockput(ip);
    80005e50:	8526                	mv	a0,s1
    80005e52:	ffffe097          	auipc	ra,0xffffe
    80005e56:	4c2080e7          	jalr	1218(ra) # 80004314 <iunlockput>
  end_op();
    80005e5a:	fffff097          	auipc	ra,0xfffff
    80005e5e:	c9a080e7          	jalr	-870(ra) # 80004af4 <end_op>
  return -1;
    80005e62:	57fd                	li	a5,-1
}
    80005e64:	853e                	mv	a0,a5
    80005e66:	70b2                	ld	ra,296(sp)
    80005e68:	7412                	ld	s0,288(sp)
    80005e6a:	64f2                	ld	s1,280(sp)
    80005e6c:	6952                	ld	s2,272(sp)
    80005e6e:	6155                	addi	sp,sp,304
    80005e70:	8082                	ret

0000000080005e72 <sys_unlink>:
{
    80005e72:	7151                	addi	sp,sp,-240
    80005e74:	f586                	sd	ra,232(sp)
    80005e76:	f1a2                	sd	s0,224(sp)
    80005e78:	eda6                	sd	s1,216(sp)
    80005e7a:	e9ca                	sd	s2,208(sp)
    80005e7c:	e5ce                	sd	s3,200(sp)
    80005e7e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005e80:	08000613          	li	a2,128
    80005e84:	f3040593          	addi	a1,s0,-208
    80005e88:	4501                	li	a0,0
    80005e8a:	ffffd097          	auipc	ra,0xffffd
    80005e8e:	446080e7          	jalr	1094(ra) # 800032d0 <argstr>
    80005e92:	18054163          	bltz	a0,80006014 <sys_unlink+0x1a2>
  begin_op();
    80005e96:	fffff097          	auipc	ra,0xfffff
    80005e9a:	bde080e7          	jalr	-1058(ra) # 80004a74 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005e9e:	fb040593          	addi	a1,s0,-80
    80005ea2:	f3040513          	addi	a0,s0,-208
    80005ea6:	fffff097          	auipc	ra,0xfffff
    80005eaa:	9d0080e7          	jalr	-1584(ra) # 80004876 <nameiparent>
    80005eae:	84aa                	mv	s1,a0
    80005eb0:	c979                	beqz	a0,80005f86 <sys_unlink+0x114>
  ilock(dp);
    80005eb2:	ffffe097          	auipc	ra,0xffffe
    80005eb6:	200080e7          	jalr	512(ra) # 800040b2 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005eba:	00003597          	auipc	a1,0x3
    80005ebe:	98e58593          	addi	a1,a1,-1650 # 80008848 <syscalls+0x2c0>
    80005ec2:	fb040513          	addi	a0,s0,-80
    80005ec6:	ffffe097          	auipc	ra,0xffffe
    80005eca:	6b6080e7          	jalr	1718(ra) # 8000457c <namecmp>
    80005ece:	14050a63          	beqz	a0,80006022 <sys_unlink+0x1b0>
    80005ed2:	00003597          	auipc	a1,0x3
    80005ed6:	97e58593          	addi	a1,a1,-1666 # 80008850 <syscalls+0x2c8>
    80005eda:	fb040513          	addi	a0,s0,-80
    80005ede:	ffffe097          	auipc	ra,0xffffe
    80005ee2:	69e080e7          	jalr	1694(ra) # 8000457c <namecmp>
    80005ee6:	12050e63          	beqz	a0,80006022 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005eea:	f2c40613          	addi	a2,s0,-212
    80005eee:	fb040593          	addi	a1,s0,-80
    80005ef2:	8526                	mv	a0,s1
    80005ef4:	ffffe097          	auipc	ra,0xffffe
    80005ef8:	6a2080e7          	jalr	1698(ra) # 80004596 <dirlookup>
    80005efc:	892a                	mv	s2,a0
    80005efe:	12050263          	beqz	a0,80006022 <sys_unlink+0x1b0>
  ilock(ip);
    80005f02:	ffffe097          	auipc	ra,0xffffe
    80005f06:	1b0080e7          	jalr	432(ra) # 800040b2 <ilock>
  if(ip->nlink < 1)
    80005f0a:	04a91783          	lh	a5,74(s2)
    80005f0e:	08f05263          	blez	a5,80005f92 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005f12:	04491703          	lh	a4,68(s2)
    80005f16:	4785                	li	a5,1
    80005f18:	08f70563          	beq	a4,a5,80005fa2 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005f1c:	4641                	li	a2,16
    80005f1e:	4581                	li	a1,0
    80005f20:	fc040513          	addi	a0,s0,-64
    80005f24:	ffffb097          	auipc	ra,0xffffb
    80005f28:	dc2080e7          	jalr	-574(ra) # 80000ce6 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005f2c:	4741                	li	a4,16
    80005f2e:	f2c42683          	lw	a3,-212(s0)
    80005f32:	fc040613          	addi	a2,s0,-64
    80005f36:	4581                	li	a1,0
    80005f38:	8526                	mv	a0,s1
    80005f3a:	ffffe097          	auipc	ra,0xffffe
    80005f3e:	524080e7          	jalr	1316(ra) # 8000445e <writei>
    80005f42:	47c1                	li	a5,16
    80005f44:	0af51563          	bne	a0,a5,80005fee <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005f48:	04491703          	lh	a4,68(s2)
    80005f4c:	4785                	li	a5,1
    80005f4e:	0af70863          	beq	a4,a5,80005ffe <sys_unlink+0x18c>
  iunlockput(dp);
    80005f52:	8526                	mv	a0,s1
    80005f54:	ffffe097          	auipc	ra,0xffffe
    80005f58:	3c0080e7          	jalr	960(ra) # 80004314 <iunlockput>
  ip->nlink--;
    80005f5c:	04a95783          	lhu	a5,74(s2)
    80005f60:	37fd                	addiw	a5,a5,-1
    80005f62:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005f66:	854a                	mv	a0,s2
    80005f68:	ffffe097          	auipc	ra,0xffffe
    80005f6c:	080080e7          	jalr	128(ra) # 80003fe8 <iupdate>
  iunlockput(ip);
    80005f70:	854a                	mv	a0,s2
    80005f72:	ffffe097          	auipc	ra,0xffffe
    80005f76:	3a2080e7          	jalr	930(ra) # 80004314 <iunlockput>
  end_op();
    80005f7a:	fffff097          	auipc	ra,0xfffff
    80005f7e:	b7a080e7          	jalr	-1158(ra) # 80004af4 <end_op>
  return 0;
    80005f82:	4501                	li	a0,0
    80005f84:	a84d                	j	80006036 <sys_unlink+0x1c4>
    end_op();
    80005f86:	fffff097          	auipc	ra,0xfffff
    80005f8a:	b6e080e7          	jalr	-1170(ra) # 80004af4 <end_op>
    return -1;
    80005f8e:	557d                	li	a0,-1
    80005f90:	a05d                	j	80006036 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005f92:	00003517          	auipc	a0,0x3
    80005f96:	8c650513          	addi	a0,a0,-1850 # 80008858 <syscalls+0x2d0>
    80005f9a:	ffffa097          	auipc	ra,0xffffa
    80005f9e:	5aa080e7          	jalr	1450(ra) # 80000544 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005fa2:	04c92703          	lw	a4,76(s2)
    80005fa6:	02000793          	li	a5,32
    80005faa:	f6e7f9e3          	bgeu	a5,a4,80005f1c <sys_unlink+0xaa>
    80005fae:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005fb2:	4741                	li	a4,16
    80005fb4:	86ce                	mv	a3,s3
    80005fb6:	f1840613          	addi	a2,s0,-232
    80005fba:	4581                	li	a1,0
    80005fbc:	854a                	mv	a0,s2
    80005fbe:	ffffe097          	auipc	ra,0xffffe
    80005fc2:	3a8080e7          	jalr	936(ra) # 80004366 <readi>
    80005fc6:	47c1                	li	a5,16
    80005fc8:	00f51b63          	bne	a0,a5,80005fde <sys_unlink+0x16c>
    if(de.inum != 0)
    80005fcc:	f1845783          	lhu	a5,-232(s0)
    80005fd0:	e7a1                	bnez	a5,80006018 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005fd2:	29c1                	addiw	s3,s3,16
    80005fd4:	04c92783          	lw	a5,76(s2)
    80005fd8:	fcf9ede3          	bltu	s3,a5,80005fb2 <sys_unlink+0x140>
    80005fdc:	b781                	j	80005f1c <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005fde:	00003517          	auipc	a0,0x3
    80005fe2:	89250513          	addi	a0,a0,-1902 # 80008870 <syscalls+0x2e8>
    80005fe6:	ffffa097          	auipc	ra,0xffffa
    80005fea:	55e080e7          	jalr	1374(ra) # 80000544 <panic>
    panic("unlink: writei");
    80005fee:	00003517          	auipc	a0,0x3
    80005ff2:	89a50513          	addi	a0,a0,-1894 # 80008888 <syscalls+0x300>
    80005ff6:	ffffa097          	auipc	ra,0xffffa
    80005ffa:	54e080e7          	jalr	1358(ra) # 80000544 <panic>
    dp->nlink--;
    80005ffe:	04a4d783          	lhu	a5,74(s1)
    80006002:	37fd                	addiw	a5,a5,-1
    80006004:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80006008:	8526                	mv	a0,s1
    8000600a:	ffffe097          	auipc	ra,0xffffe
    8000600e:	fde080e7          	jalr	-34(ra) # 80003fe8 <iupdate>
    80006012:	b781                	j	80005f52 <sys_unlink+0xe0>
    return -1;
    80006014:	557d                	li	a0,-1
    80006016:	a005                	j	80006036 <sys_unlink+0x1c4>
    iunlockput(ip);
    80006018:	854a                	mv	a0,s2
    8000601a:	ffffe097          	auipc	ra,0xffffe
    8000601e:	2fa080e7          	jalr	762(ra) # 80004314 <iunlockput>
  iunlockput(dp);
    80006022:	8526                	mv	a0,s1
    80006024:	ffffe097          	auipc	ra,0xffffe
    80006028:	2f0080e7          	jalr	752(ra) # 80004314 <iunlockput>
  end_op();
    8000602c:	fffff097          	auipc	ra,0xfffff
    80006030:	ac8080e7          	jalr	-1336(ra) # 80004af4 <end_op>
  return -1;
    80006034:	557d                	li	a0,-1
}
    80006036:	70ae                	ld	ra,232(sp)
    80006038:	740e                	ld	s0,224(sp)
    8000603a:	64ee                	ld	s1,216(sp)
    8000603c:	694e                	ld	s2,208(sp)
    8000603e:	69ae                	ld	s3,200(sp)
    80006040:	616d                	addi	sp,sp,240
    80006042:	8082                	ret

0000000080006044 <sys_open>:

uint64
sys_open(void)
{
    80006044:	7131                	addi	sp,sp,-192
    80006046:	fd06                	sd	ra,184(sp)
    80006048:	f922                	sd	s0,176(sp)
    8000604a:	f526                	sd	s1,168(sp)
    8000604c:	f14a                	sd	s2,160(sp)
    8000604e:	ed4e                	sd	s3,152(sp)
    80006050:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80006052:	f4c40593          	addi	a1,s0,-180
    80006056:	4505                	li	a0,1
    80006058:	ffffd097          	auipc	ra,0xffffd
    8000605c:	238080e7          	jalr	568(ra) # 80003290 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80006060:	08000613          	li	a2,128
    80006064:	f5040593          	addi	a1,s0,-176
    80006068:	4501                	li	a0,0
    8000606a:	ffffd097          	auipc	ra,0xffffd
    8000606e:	266080e7          	jalr	614(ra) # 800032d0 <argstr>
    80006072:	87aa                	mv	a5,a0
    return -1;
    80006074:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80006076:	0a07c963          	bltz	a5,80006128 <sys_open+0xe4>

  begin_op();
    8000607a:	fffff097          	auipc	ra,0xfffff
    8000607e:	9fa080e7          	jalr	-1542(ra) # 80004a74 <begin_op>

  if(omode & O_CREATE){
    80006082:	f4c42783          	lw	a5,-180(s0)
    80006086:	2007f793          	andi	a5,a5,512
    8000608a:	cfc5                	beqz	a5,80006142 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    8000608c:	4681                	li	a3,0
    8000608e:	4601                	li	a2,0
    80006090:	4589                	li	a1,2
    80006092:	f5040513          	addi	a0,s0,-176
    80006096:	00000097          	auipc	ra,0x0
    8000609a:	974080e7          	jalr	-1676(ra) # 80005a0a <create>
    8000609e:	84aa                	mv	s1,a0
    if(ip == 0){
    800060a0:	c959                	beqz	a0,80006136 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800060a2:	04449703          	lh	a4,68(s1)
    800060a6:	478d                	li	a5,3
    800060a8:	00f71763          	bne	a4,a5,800060b6 <sys_open+0x72>
    800060ac:	0464d703          	lhu	a4,70(s1)
    800060b0:	47a5                	li	a5,9
    800060b2:	0ce7ed63          	bltu	a5,a4,8000618c <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800060b6:	fffff097          	auipc	ra,0xfffff
    800060ba:	dce080e7          	jalr	-562(ra) # 80004e84 <filealloc>
    800060be:	89aa                	mv	s3,a0
    800060c0:	10050363          	beqz	a0,800061c6 <sys_open+0x182>
    800060c4:	00000097          	auipc	ra,0x0
    800060c8:	904080e7          	jalr	-1788(ra) # 800059c8 <fdalloc>
    800060cc:	892a                	mv	s2,a0
    800060ce:	0e054763          	bltz	a0,800061bc <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800060d2:	04449703          	lh	a4,68(s1)
    800060d6:	478d                	li	a5,3
    800060d8:	0cf70563          	beq	a4,a5,800061a2 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800060dc:	4789                	li	a5,2
    800060de:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800060e2:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800060e6:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    800060ea:	f4c42783          	lw	a5,-180(s0)
    800060ee:	0017c713          	xori	a4,a5,1
    800060f2:	8b05                	andi	a4,a4,1
    800060f4:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800060f8:	0037f713          	andi	a4,a5,3
    800060fc:	00e03733          	snez	a4,a4
    80006100:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80006104:	4007f793          	andi	a5,a5,1024
    80006108:	c791                	beqz	a5,80006114 <sys_open+0xd0>
    8000610a:	04449703          	lh	a4,68(s1)
    8000610e:	4789                	li	a5,2
    80006110:	0af70063          	beq	a4,a5,800061b0 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80006114:	8526                	mv	a0,s1
    80006116:	ffffe097          	auipc	ra,0xffffe
    8000611a:	05e080e7          	jalr	94(ra) # 80004174 <iunlock>
  end_op();
    8000611e:	fffff097          	auipc	ra,0xfffff
    80006122:	9d6080e7          	jalr	-1578(ra) # 80004af4 <end_op>

  return fd;
    80006126:	854a                	mv	a0,s2
}
    80006128:	70ea                	ld	ra,184(sp)
    8000612a:	744a                	ld	s0,176(sp)
    8000612c:	74aa                	ld	s1,168(sp)
    8000612e:	790a                	ld	s2,160(sp)
    80006130:	69ea                	ld	s3,152(sp)
    80006132:	6129                	addi	sp,sp,192
    80006134:	8082                	ret
      end_op();
    80006136:	fffff097          	auipc	ra,0xfffff
    8000613a:	9be080e7          	jalr	-1602(ra) # 80004af4 <end_op>
      return -1;
    8000613e:	557d                	li	a0,-1
    80006140:	b7e5                	j	80006128 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80006142:	f5040513          	addi	a0,s0,-176
    80006146:	ffffe097          	auipc	ra,0xffffe
    8000614a:	712080e7          	jalr	1810(ra) # 80004858 <namei>
    8000614e:	84aa                	mv	s1,a0
    80006150:	c905                	beqz	a0,80006180 <sys_open+0x13c>
    ilock(ip);
    80006152:	ffffe097          	auipc	ra,0xffffe
    80006156:	f60080e7          	jalr	-160(ra) # 800040b2 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000615a:	04449703          	lh	a4,68(s1)
    8000615e:	4785                	li	a5,1
    80006160:	f4f711e3          	bne	a4,a5,800060a2 <sys_open+0x5e>
    80006164:	f4c42783          	lw	a5,-180(s0)
    80006168:	d7b9                	beqz	a5,800060b6 <sys_open+0x72>
      iunlockput(ip);
    8000616a:	8526                	mv	a0,s1
    8000616c:	ffffe097          	auipc	ra,0xffffe
    80006170:	1a8080e7          	jalr	424(ra) # 80004314 <iunlockput>
      end_op();
    80006174:	fffff097          	auipc	ra,0xfffff
    80006178:	980080e7          	jalr	-1664(ra) # 80004af4 <end_op>
      return -1;
    8000617c:	557d                	li	a0,-1
    8000617e:	b76d                	j	80006128 <sys_open+0xe4>
      end_op();
    80006180:	fffff097          	auipc	ra,0xfffff
    80006184:	974080e7          	jalr	-1676(ra) # 80004af4 <end_op>
      return -1;
    80006188:	557d                	li	a0,-1
    8000618a:	bf79                	j	80006128 <sys_open+0xe4>
    iunlockput(ip);
    8000618c:	8526                	mv	a0,s1
    8000618e:	ffffe097          	auipc	ra,0xffffe
    80006192:	186080e7          	jalr	390(ra) # 80004314 <iunlockput>
    end_op();
    80006196:	fffff097          	auipc	ra,0xfffff
    8000619a:	95e080e7          	jalr	-1698(ra) # 80004af4 <end_op>
    return -1;
    8000619e:	557d                	li	a0,-1
    800061a0:	b761                	j	80006128 <sys_open+0xe4>
    f->type = FD_DEVICE;
    800061a2:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800061a6:	04649783          	lh	a5,70(s1)
    800061aa:	02f99223          	sh	a5,36(s3)
    800061ae:	bf25                	j	800060e6 <sys_open+0xa2>
    itrunc(ip);
    800061b0:	8526                	mv	a0,s1
    800061b2:	ffffe097          	auipc	ra,0xffffe
    800061b6:	00e080e7          	jalr	14(ra) # 800041c0 <itrunc>
    800061ba:	bfa9                	j	80006114 <sys_open+0xd0>
      fileclose(f);
    800061bc:	854e                	mv	a0,s3
    800061be:	fffff097          	auipc	ra,0xfffff
    800061c2:	d82080e7          	jalr	-638(ra) # 80004f40 <fileclose>
    iunlockput(ip);
    800061c6:	8526                	mv	a0,s1
    800061c8:	ffffe097          	auipc	ra,0xffffe
    800061cc:	14c080e7          	jalr	332(ra) # 80004314 <iunlockput>
    end_op();
    800061d0:	fffff097          	auipc	ra,0xfffff
    800061d4:	924080e7          	jalr	-1756(ra) # 80004af4 <end_op>
    return -1;
    800061d8:	557d                	li	a0,-1
    800061da:	b7b9                	j	80006128 <sys_open+0xe4>

00000000800061dc <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800061dc:	7175                	addi	sp,sp,-144
    800061de:	e506                	sd	ra,136(sp)
    800061e0:	e122                	sd	s0,128(sp)
    800061e2:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800061e4:	fffff097          	auipc	ra,0xfffff
    800061e8:	890080e7          	jalr	-1904(ra) # 80004a74 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800061ec:	08000613          	li	a2,128
    800061f0:	f7040593          	addi	a1,s0,-144
    800061f4:	4501                	li	a0,0
    800061f6:	ffffd097          	auipc	ra,0xffffd
    800061fa:	0da080e7          	jalr	218(ra) # 800032d0 <argstr>
    800061fe:	02054963          	bltz	a0,80006230 <sys_mkdir+0x54>
    80006202:	4681                	li	a3,0
    80006204:	4601                	li	a2,0
    80006206:	4585                	li	a1,1
    80006208:	f7040513          	addi	a0,s0,-144
    8000620c:	fffff097          	auipc	ra,0xfffff
    80006210:	7fe080e7          	jalr	2046(ra) # 80005a0a <create>
    80006214:	cd11                	beqz	a0,80006230 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006216:	ffffe097          	auipc	ra,0xffffe
    8000621a:	0fe080e7          	jalr	254(ra) # 80004314 <iunlockput>
  end_op();
    8000621e:	fffff097          	auipc	ra,0xfffff
    80006222:	8d6080e7          	jalr	-1834(ra) # 80004af4 <end_op>
  return 0;
    80006226:	4501                	li	a0,0
}
    80006228:	60aa                	ld	ra,136(sp)
    8000622a:	640a                	ld	s0,128(sp)
    8000622c:	6149                	addi	sp,sp,144
    8000622e:	8082                	ret
    end_op();
    80006230:	fffff097          	auipc	ra,0xfffff
    80006234:	8c4080e7          	jalr	-1852(ra) # 80004af4 <end_op>
    return -1;
    80006238:	557d                	li	a0,-1
    8000623a:	b7fd                	j	80006228 <sys_mkdir+0x4c>

000000008000623c <sys_mknod>:

uint64
sys_mknod(void)
{
    8000623c:	7135                	addi	sp,sp,-160
    8000623e:	ed06                	sd	ra,152(sp)
    80006240:	e922                	sd	s0,144(sp)
    80006242:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80006244:	fffff097          	auipc	ra,0xfffff
    80006248:	830080e7          	jalr	-2000(ra) # 80004a74 <begin_op>
  argint(1, &major);
    8000624c:	f6c40593          	addi	a1,s0,-148
    80006250:	4505                	li	a0,1
    80006252:	ffffd097          	auipc	ra,0xffffd
    80006256:	03e080e7          	jalr	62(ra) # 80003290 <argint>
  argint(2, &minor);
    8000625a:	f6840593          	addi	a1,s0,-152
    8000625e:	4509                	li	a0,2
    80006260:	ffffd097          	auipc	ra,0xffffd
    80006264:	030080e7          	jalr	48(ra) # 80003290 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006268:	08000613          	li	a2,128
    8000626c:	f7040593          	addi	a1,s0,-144
    80006270:	4501                	li	a0,0
    80006272:	ffffd097          	auipc	ra,0xffffd
    80006276:	05e080e7          	jalr	94(ra) # 800032d0 <argstr>
    8000627a:	02054b63          	bltz	a0,800062b0 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000627e:	f6841683          	lh	a3,-152(s0)
    80006282:	f6c41603          	lh	a2,-148(s0)
    80006286:	458d                	li	a1,3
    80006288:	f7040513          	addi	a0,s0,-144
    8000628c:	fffff097          	auipc	ra,0xfffff
    80006290:	77e080e7          	jalr	1918(ra) # 80005a0a <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006294:	cd11                	beqz	a0,800062b0 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006296:	ffffe097          	auipc	ra,0xffffe
    8000629a:	07e080e7          	jalr	126(ra) # 80004314 <iunlockput>
  end_op();
    8000629e:	fffff097          	auipc	ra,0xfffff
    800062a2:	856080e7          	jalr	-1962(ra) # 80004af4 <end_op>
  return 0;
    800062a6:	4501                	li	a0,0
}
    800062a8:	60ea                	ld	ra,152(sp)
    800062aa:	644a                	ld	s0,144(sp)
    800062ac:	610d                	addi	sp,sp,160
    800062ae:	8082                	ret
    end_op();
    800062b0:	fffff097          	auipc	ra,0xfffff
    800062b4:	844080e7          	jalr	-1980(ra) # 80004af4 <end_op>
    return -1;
    800062b8:	557d                	li	a0,-1
    800062ba:	b7fd                	j	800062a8 <sys_mknod+0x6c>

00000000800062bc <sys_chdir>:

uint64
sys_chdir(void)
{
    800062bc:	7135                	addi	sp,sp,-160
    800062be:	ed06                	sd	ra,152(sp)
    800062c0:	e922                	sd	s0,144(sp)
    800062c2:	e526                	sd	s1,136(sp)
    800062c4:	e14a                	sd	s2,128(sp)
    800062c6:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800062c8:	ffffc097          	auipc	ra,0xffffc
    800062cc:	922080e7          	jalr	-1758(ra) # 80001bea <myproc>
    800062d0:	892a                	mv	s2,a0
  
  begin_op();
    800062d2:	ffffe097          	auipc	ra,0xffffe
    800062d6:	7a2080e7          	jalr	1954(ra) # 80004a74 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800062da:	08000613          	li	a2,128
    800062de:	f6040593          	addi	a1,s0,-160
    800062e2:	4501                	li	a0,0
    800062e4:	ffffd097          	auipc	ra,0xffffd
    800062e8:	fec080e7          	jalr	-20(ra) # 800032d0 <argstr>
    800062ec:	04054b63          	bltz	a0,80006342 <sys_chdir+0x86>
    800062f0:	f6040513          	addi	a0,s0,-160
    800062f4:	ffffe097          	auipc	ra,0xffffe
    800062f8:	564080e7          	jalr	1380(ra) # 80004858 <namei>
    800062fc:	84aa                	mv	s1,a0
    800062fe:	c131                	beqz	a0,80006342 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006300:	ffffe097          	auipc	ra,0xffffe
    80006304:	db2080e7          	jalr	-590(ra) # 800040b2 <ilock>
  if(ip->type != T_DIR){
    80006308:	04449703          	lh	a4,68(s1)
    8000630c:	4785                	li	a5,1
    8000630e:	04f71063          	bne	a4,a5,8000634e <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006312:	8526                	mv	a0,s1
    80006314:	ffffe097          	auipc	ra,0xffffe
    80006318:	e60080e7          	jalr	-416(ra) # 80004174 <iunlock>
  iput(p->cwd);
    8000631c:	15893503          	ld	a0,344(s2)
    80006320:	ffffe097          	auipc	ra,0xffffe
    80006324:	f4c080e7          	jalr	-180(ra) # 8000426c <iput>
  end_op();
    80006328:	ffffe097          	auipc	ra,0xffffe
    8000632c:	7cc080e7          	jalr	1996(ra) # 80004af4 <end_op>
  p->cwd = ip;
    80006330:	14993c23          	sd	s1,344(s2)
  return 0;
    80006334:	4501                	li	a0,0
}
    80006336:	60ea                	ld	ra,152(sp)
    80006338:	644a                	ld	s0,144(sp)
    8000633a:	64aa                	ld	s1,136(sp)
    8000633c:	690a                	ld	s2,128(sp)
    8000633e:	610d                	addi	sp,sp,160
    80006340:	8082                	ret
    end_op();
    80006342:	ffffe097          	auipc	ra,0xffffe
    80006346:	7b2080e7          	jalr	1970(ra) # 80004af4 <end_op>
    return -1;
    8000634a:	557d                	li	a0,-1
    8000634c:	b7ed                	j	80006336 <sys_chdir+0x7a>
    iunlockput(ip);
    8000634e:	8526                	mv	a0,s1
    80006350:	ffffe097          	auipc	ra,0xffffe
    80006354:	fc4080e7          	jalr	-60(ra) # 80004314 <iunlockput>
    end_op();
    80006358:	ffffe097          	auipc	ra,0xffffe
    8000635c:	79c080e7          	jalr	1948(ra) # 80004af4 <end_op>
    return -1;
    80006360:	557d                	li	a0,-1
    80006362:	bfd1                	j	80006336 <sys_chdir+0x7a>

0000000080006364 <sys_exec>:

uint64
sys_exec(void)
{
    80006364:	7145                	addi	sp,sp,-464
    80006366:	e786                	sd	ra,456(sp)
    80006368:	e3a2                	sd	s0,448(sp)
    8000636a:	ff26                	sd	s1,440(sp)
    8000636c:	fb4a                	sd	s2,432(sp)
    8000636e:	f74e                	sd	s3,424(sp)
    80006370:	f352                	sd	s4,416(sp)
    80006372:	ef56                	sd	s5,408(sp)
    80006374:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80006376:	e3840593          	addi	a1,s0,-456
    8000637a:	4505                	li	a0,1
    8000637c:	ffffd097          	auipc	ra,0xffffd
    80006380:	f34080e7          	jalr	-204(ra) # 800032b0 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80006384:	08000613          	li	a2,128
    80006388:	f4040593          	addi	a1,s0,-192
    8000638c:	4501                	li	a0,0
    8000638e:	ffffd097          	auipc	ra,0xffffd
    80006392:	f42080e7          	jalr	-190(ra) # 800032d0 <argstr>
    80006396:	87aa                	mv	a5,a0
    return -1;
    80006398:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000639a:	0c07c263          	bltz	a5,8000645e <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    8000639e:	10000613          	li	a2,256
    800063a2:	4581                	li	a1,0
    800063a4:	e4040513          	addi	a0,s0,-448
    800063a8:	ffffb097          	auipc	ra,0xffffb
    800063ac:	93e080e7          	jalr	-1730(ra) # 80000ce6 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800063b0:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800063b4:	89a6                	mv	s3,s1
    800063b6:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800063b8:	02000a13          	li	s4,32
    800063bc:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800063c0:	00391513          	slli	a0,s2,0x3
    800063c4:	e3040593          	addi	a1,s0,-464
    800063c8:	e3843783          	ld	a5,-456(s0)
    800063cc:	953e                	add	a0,a0,a5
    800063ce:	ffffd097          	auipc	ra,0xffffd
    800063d2:	e24080e7          	jalr	-476(ra) # 800031f2 <fetchaddr>
    800063d6:	02054a63          	bltz	a0,8000640a <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    800063da:	e3043783          	ld	a5,-464(s0)
    800063de:	c3b9                	beqz	a5,80006424 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800063e0:	ffffa097          	auipc	ra,0xffffa
    800063e4:	71a080e7          	jalr	1818(ra) # 80000afa <kalloc>
    800063e8:	85aa                	mv	a1,a0
    800063ea:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800063ee:	cd11                	beqz	a0,8000640a <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800063f0:	6605                	lui	a2,0x1
    800063f2:	e3043503          	ld	a0,-464(s0)
    800063f6:	ffffd097          	auipc	ra,0xffffd
    800063fa:	e4e080e7          	jalr	-434(ra) # 80003244 <fetchstr>
    800063fe:	00054663          	bltz	a0,8000640a <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80006402:	0905                	addi	s2,s2,1
    80006404:	09a1                	addi	s3,s3,8
    80006406:	fb491be3          	bne	s2,s4,800063bc <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000640a:	10048913          	addi	s2,s1,256
    8000640e:	6088                	ld	a0,0(s1)
    80006410:	c531                	beqz	a0,8000645c <sys_exec+0xf8>
    kfree(argv[i]);
    80006412:	ffffa097          	auipc	ra,0xffffa
    80006416:	5ec080e7          	jalr	1516(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000641a:	04a1                	addi	s1,s1,8
    8000641c:	ff2499e3          	bne	s1,s2,8000640e <sys_exec+0xaa>
  return -1;
    80006420:	557d                	li	a0,-1
    80006422:	a835                	j	8000645e <sys_exec+0xfa>
      argv[i] = 0;
    80006424:	0a8e                	slli	s5,s5,0x3
    80006426:	fc040793          	addi	a5,s0,-64
    8000642a:	9abe                	add	s5,s5,a5
    8000642c:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80006430:	e4040593          	addi	a1,s0,-448
    80006434:	f4040513          	addi	a0,s0,-192
    80006438:	fffff097          	auipc	ra,0xfffff
    8000643c:	190080e7          	jalr	400(ra) # 800055c8 <exec>
    80006440:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006442:	10048993          	addi	s3,s1,256
    80006446:	6088                	ld	a0,0(s1)
    80006448:	c901                	beqz	a0,80006458 <sys_exec+0xf4>
    kfree(argv[i]);
    8000644a:	ffffa097          	auipc	ra,0xffffa
    8000644e:	5b4080e7          	jalr	1460(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006452:	04a1                	addi	s1,s1,8
    80006454:	ff3499e3          	bne	s1,s3,80006446 <sys_exec+0xe2>
  return ret;
    80006458:	854a                	mv	a0,s2
    8000645a:	a011                	j	8000645e <sys_exec+0xfa>
  return -1;
    8000645c:	557d                	li	a0,-1
}
    8000645e:	60be                	ld	ra,456(sp)
    80006460:	641e                	ld	s0,448(sp)
    80006462:	74fa                	ld	s1,440(sp)
    80006464:	795a                	ld	s2,432(sp)
    80006466:	79ba                	ld	s3,424(sp)
    80006468:	7a1a                	ld	s4,416(sp)
    8000646a:	6afa                	ld	s5,408(sp)
    8000646c:	6179                	addi	sp,sp,464
    8000646e:	8082                	ret

0000000080006470 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006470:	7139                	addi	sp,sp,-64
    80006472:	fc06                	sd	ra,56(sp)
    80006474:	f822                	sd	s0,48(sp)
    80006476:	f426                	sd	s1,40(sp)
    80006478:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000647a:	ffffb097          	auipc	ra,0xffffb
    8000647e:	770080e7          	jalr	1904(ra) # 80001bea <myproc>
    80006482:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80006484:	fd840593          	addi	a1,s0,-40
    80006488:	4501                	li	a0,0
    8000648a:	ffffd097          	auipc	ra,0xffffd
    8000648e:	e26080e7          	jalr	-474(ra) # 800032b0 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80006492:	fc840593          	addi	a1,s0,-56
    80006496:	fd040513          	addi	a0,s0,-48
    8000649a:	fffff097          	auipc	ra,0xfffff
    8000649e:	dd6080e7          	jalr	-554(ra) # 80005270 <pipealloc>
    return -1;
    800064a2:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800064a4:	0c054463          	bltz	a0,8000656c <sys_pipe+0xfc>
  fd0 = -1;
    800064a8:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800064ac:	fd043503          	ld	a0,-48(s0)
    800064b0:	fffff097          	auipc	ra,0xfffff
    800064b4:	518080e7          	jalr	1304(ra) # 800059c8 <fdalloc>
    800064b8:	fca42223          	sw	a0,-60(s0)
    800064bc:	08054b63          	bltz	a0,80006552 <sys_pipe+0xe2>
    800064c0:	fc843503          	ld	a0,-56(s0)
    800064c4:	fffff097          	auipc	ra,0xfffff
    800064c8:	504080e7          	jalr	1284(ra) # 800059c8 <fdalloc>
    800064cc:	fca42023          	sw	a0,-64(s0)
    800064d0:	06054863          	bltz	a0,80006540 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800064d4:	4691                	li	a3,4
    800064d6:	fc440613          	addi	a2,s0,-60
    800064da:	fd843583          	ld	a1,-40(s0)
    800064de:	6ca8                	ld	a0,88(s1)
    800064e0:	ffffb097          	auipc	ra,0xffffb
    800064e4:	1a4080e7          	jalr	420(ra) # 80001684 <copyout>
    800064e8:	02054063          	bltz	a0,80006508 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800064ec:	4691                	li	a3,4
    800064ee:	fc040613          	addi	a2,s0,-64
    800064f2:	fd843583          	ld	a1,-40(s0)
    800064f6:	0591                	addi	a1,a1,4
    800064f8:	6ca8                	ld	a0,88(s1)
    800064fa:	ffffb097          	auipc	ra,0xffffb
    800064fe:	18a080e7          	jalr	394(ra) # 80001684 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006502:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006504:	06055463          	bgez	a0,8000656c <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80006508:	fc442783          	lw	a5,-60(s0)
    8000650c:	07e9                	addi	a5,a5,26
    8000650e:	078e                	slli	a5,a5,0x3
    80006510:	97a6                	add	a5,a5,s1
    80006512:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80006516:	fc042503          	lw	a0,-64(s0)
    8000651a:	0569                	addi	a0,a0,26
    8000651c:	050e                	slli	a0,a0,0x3
    8000651e:	94aa                	add	s1,s1,a0
    80006520:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80006524:	fd043503          	ld	a0,-48(s0)
    80006528:	fffff097          	auipc	ra,0xfffff
    8000652c:	a18080e7          	jalr	-1512(ra) # 80004f40 <fileclose>
    fileclose(wf);
    80006530:	fc843503          	ld	a0,-56(s0)
    80006534:	fffff097          	auipc	ra,0xfffff
    80006538:	a0c080e7          	jalr	-1524(ra) # 80004f40 <fileclose>
    return -1;
    8000653c:	57fd                	li	a5,-1
    8000653e:	a03d                	j	8000656c <sys_pipe+0xfc>
    if(fd0 >= 0)
    80006540:	fc442783          	lw	a5,-60(s0)
    80006544:	0007c763          	bltz	a5,80006552 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80006548:	07e9                	addi	a5,a5,26
    8000654a:	078e                	slli	a5,a5,0x3
    8000654c:	94be                	add	s1,s1,a5
    8000654e:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80006552:	fd043503          	ld	a0,-48(s0)
    80006556:	fffff097          	auipc	ra,0xfffff
    8000655a:	9ea080e7          	jalr	-1558(ra) # 80004f40 <fileclose>
    fileclose(wf);
    8000655e:	fc843503          	ld	a0,-56(s0)
    80006562:	fffff097          	auipc	ra,0xfffff
    80006566:	9de080e7          	jalr	-1570(ra) # 80004f40 <fileclose>
    return -1;
    8000656a:	57fd                	li	a5,-1
}
    8000656c:	853e                	mv	a0,a5
    8000656e:	70e2                	ld	ra,56(sp)
    80006570:	7442                	ld	s0,48(sp)
    80006572:	74a2                	ld	s1,40(sp)
    80006574:	6121                	addi	sp,sp,64
    80006576:	8082                	ret
	...

0000000080006580 <kernelvec>:
    80006580:	7111                	addi	sp,sp,-256
    80006582:	e006                	sd	ra,0(sp)
    80006584:	e40a                	sd	sp,8(sp)
    80006586:	e80e                	sd	gp,16(sp)
    80006588:	ec12                	sd	tp,24(sp)
    8000658a:	f016                	sd	t0,32(sp)
    8000658c:	f41a                	sd	t1,40(sp)
    8000658e:	f81e                	sd	t2,48(sp)
    80006590:	fc22                	sd	s0,56(sp)
    80006592:	e0a6                	sd	s1,64(sp)
    80006594:	e4aa                	sd	a0,72(sp)
    80006596:	e8ae                	sd	a1,80(sp)
    80006598:	ecb2                	sd	a2,88(sp)
    8000659a:	f0b6                	sd	a3,96(sp)
    8000659c:	f4ba                	sd	a4,104(sp)
    8000659e:	f8be                	sd	a5,112(sp)
    800065a0:	fcc2                	sd	a6,120(sp)
    800065a2:	e146                	sd	a7,128(sp)
    800065a4:	e54a                	sd	s2,136(sp)
    800065a6:	e94e                	sd	s3,144(sp)
    800065a8:	ed52                	sd	s4,152(sp)
    800065aa:	f156                	sd	s5,160(sp)
    800065ac:	f55a                	sd	s6,168(sp)
    800065ae:	f95e                	sd	s7,176(sp)
    800065b0:	fd62                	sd	s8,184(sp)
    800065b2:	e1e6                	sd	s9,192(sp)
    800065b4:	e5ea                	sd	s10,200(sp)
    800065b6:	e9ee                	sd	s11,208(sp)
    800065b8:	edf2                	sd	t3,216(sp)
    800065ba:	f1f6                	sd	t4,224(sp)
    800065bc:	f5fa                	sd	t5,232(sp)
    800065be:	f9fe                	sd	t6,240(sp)
    800065c0:	afffc0ef          	jal	ra,800030be <kerneltrap>
    800065c4:	6082                	ld	ra,0(sp)
    800065c6:	6122                	ld	sp,8(sp)
    800065c8:	61c2                	ld	gp,16(sp)
    800065ca:	7282                	ld	t0,32(sp)
    800065cc:	7322                	ld	t1,40(sp)
    800065ce:	73c2                	ld	t2,48(sp)
    800065d0:	7462                	ld	s0,56(sp)
    800065d2:	6486                	ld	s1,64(sp)
    800065d4:	6526                	ld	a0,72(sp)
    800065d6:	65c6                	ld	a1,80(sp)
    800065d8:	6666                	ld	a2,88(sp)
    800065da:	7686                	ld	a3,96(sp)
    800065dc:	7726                	ld	a4,104(sp)
    800065de:	77c6                	ld	a5,112(sp)
    800065e0:	7866                	ld	a6,120(sp)
    800065e2:	688a                	ld	a7,128(sp)
    800065e4:	692a                	ld	s2,136(sp)
    800065e6:	69ca                	ld	s3,144(sp)
    800065e8:	6a6a                	ld	s4,152(sp)
    800065ea:	7a8a                	ld	s5,160(sp)
    800065ec:	7b2a                	ld	s6,168(sp)
    800065ee:	7bca                	ld	s7,176(sp)
    800065f0:	7c6a                	ld	s8,184(sp)
    800065f2:	6c8e                	ld	s9,192(sp)
    800065f4:	6d2e                	ld	s10,200(sp)
    800065f6:	6dce                	ld	s11,208(sp)
    800065f8:	6e6e                	ld	t3,216(sp)
    800065fa:	7e8e                	ld	t4,224(sp)
    800065fc:	7f2e                	ld	t5,232(sp)
    800065fe:	7fce                	ld	t6,240(sp)
    80006600:	6111                	addi	sp,sp,256
    80006602:	10200073          	sret
    80006606:	00000013          	nop
    8000660a:	00000013          	nop
    8000660e:	0001                	nop

0000000080006610 <timervec>:
    80006610:	34051573          	csrrw	a0,mscratch,a0
    80006614:	e10c                	sd	a1,0(a0)
    80006616:	e510                	sd	a2,8(a0)
    80006618:	e914                	sd	a3,16(a0)
    8000661a:	6d0c                	ld	a1,24(a0)
    8000661c:	7110                	ld	a2,32(a0)
    8000661e:	6194                	ld	a3,0(a1)
    80006620:	96b2                	add	a3,a3,a2
    80006622:	e194                	sd	a3,0(a1)
    80006624:	4589                	li	a1,2
    80006626:	14459073          	csrw	sip,a1
    8000662a:	6914                	ld	a3,16(a0)
    8000662c:	6510                	ld	a2,8(a0)
    8000662e:	610c                	ld	a1,0(a0)
    80006630:	34051573          	csrrw	a0,mscratch,a0
    80006634:	30200073          	mret
	...

000000008000663a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000663a:	1141                	addi	sp,sp,-16
    8000663c:	e422                	sd	s0,8(sp)
    8000663e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006640:	0c0007b7          	lui	a5,0xc000
    80006644:	4705                	li	a4,1
    80006646:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006648:	c3d8                	sw	a4,4(a5)
}
    8000664a:	6422                	ld	s0,8(sp)
    8000664c:	0141                	addi	sp,sp,16
    8000664e:	8082                	ret

0000000080006650 <plicinithart>:

void
plicinithart(void)
{
    80006650:	1141                	addi	sp,sp,-16
    80006652:	e406                	sd	ra,8(sp)
    80006654:	e022                	sd	s0,0(sp)
    80006656:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006658:	ffffb097          	auipc	ra,0xffffb
    8000665c:	566080e7          	jalr	1382(ra) # 80001bbe <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006660:	0085171b          	slliw	a4,a0,0x8
    80006664:	0c0027b7          	lui	a5,0xc002
    80006668:	97ba                	add	a5,a5,a4
    8000666a:	40200713          	li	a4,1026
    8000666e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006672:	00d5151b          	slliw	a0,a0,0xd
    80006676:	0c2017b7          	lui	a5,0xc201
    8000667a:	953e                	add	a0,a0,a5
    8000667c:	00052023          	sw	zero,0(a0)
}
    80006680:	60a2                	ld	ra,8(sp)
    80006682:	6402                	ld	s0,0(sp)
    80006684:	0141                	addi	sp,sp,16
    80006686:	8082                	ret

0000000080006688 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006688:	1141                	addi	sp,sp,-16
    8000668a:	e406                	sd	ra,8(sp)
    8000668c:	e022                	sd	s0,0(sp)
    8000668e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006690:	ffffb097          	auipc	ra,0xffffb
    80006694:	52e080e7          	jalr	1326(ra) # 80001bbe <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006698:	00d5179b          	slliw	a5,a0,0xd
    8000669c:	0c201537          	lui	a0,0xc201
    800066a0:	953e                	add	a0,a0,a5
  return irq;
}
    800066a2:	4148                	lw	a0,4(a0)
    800066a4:	60a2                	ld	ra,8(sp)
    800066a6:	6402                	ld	s0,0(sp)
    800066a8:	0141                	addi	sp,sp,16
    800066aa:	8082                	ret

00000000800066ac <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800066ac:	1101                	addi	sp,sp,-32
    800066ae:	ec06                	sd	ra,24(sp)
    800066b0:	e822                	sd	s0,16(sp)
    800066b2:	e426                	sd	s1,8(sp)
    800066b4:	1000                	addi	s0,sp,32
    800066b6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800066b8:	ffffb097          	auipc	ra,0xffffb
    800066bc:	506080e7          	jalr	1286(ra) # 80001bbe <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800066c0:	00d5151b          	slliw	a0,a0,0xd
    800066c4:	0c2017b7          	lui	a5,0xc201
    800066c8:	97aa                	add	a5,a5,a0
    800066ca:	c3c4                	sw	s1,4(a5)
}
    800066cc:	60e2                	ld	ra,24(sp)
    800066ce:	6442                	ld	s0,16(sp)
    800066d0:	64a2                	ld	s1,8(sp)
    800066d2:	6105                	addi	sp,sp,32
    800066d4:	8082                	ret

00000000800066d6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800066d6:	1141                	addi	sp,sp,-16
    800066d8:	e406                	sd	ra,8(sp)
    800066da:	e022                	sd	s0,0(sp)
    800066dc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800066de:	479d                	li	a5,7
    800066e0:	04a7cc63          	blt	a5,a0,80006738 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800066e4:	0001e797          	auipc	a5,0x1e
    800066e8:	cb478793          	addi	a5,a5,-844 # 80024398 <disk>
    800066ec:	97aa                	add	a5,a5,a0
    800066ee:	0187c783          	lbu	a5,24(a5)
    800066f2:	ebb9                	bnez	a5,80006748 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800066f4:	00451613          	slli	a2,a0,0x4
    800066f8:	0001e797          	auipc	a5,0x1e
    800066fc:	ca078793          	addi	a5,a5,-864 # 80024398 <disk>
    80006700:	6394                	ld	a3,0(a5)
    80006702:	96b2                	add	a3,a3,a2
    80006704:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006708:	6398                	ld	a4,0(a5)
    8000670a:	9732                	add	a4,a4,a2
    8000670c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006710:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006714:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006718:	953e                	add	a0,a0,a5
    8000671a:	4785                	li	a5,1
    8000671c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80006720:	0001e517          	auipc	a0,0x1e
    80006724:	c9050513          	addi	a0,a0,-880 # 800243b0 <disk+0x18>
    80006728:	ffffc097          	auipc	ra,0xffffc
    8000672c:	ff6080e7          	jalr	-10(ra) # 8000271e <wakeup>
}
    80006730:	60a2                	ld	ra,8(sp)
    80006732:	6402                	ld	s0,0(sp)
    80006734:	0141                	addi	sp,sp,16
    80006736:	8082                	ret
    panic("free_desc 1");
    80006738:	00002517          	auipc	a0,0x2
    8000673c:	16050513          	addi	a0,a0,352 # 80008898 <syscalls+0x310>
    80006740:	ffffa097          	auipc	ra,0xffffa
    80006744:	e04080e7          	jalr	-508(ra) # 80000544 <panic>
    panic("free_desc 2");
    80006748:	00002517          	auipc	a0,0x2
    8000674c:	16050513          	addi	a0,a0,352 # 800088a8 <syscalls+0x320>
    80006750:	ffffa097          	auipc	ra,0xffffa
    80006754:	df4080e7          	jalr	-524(ra) # 80000544 <panic>

0000000080006758 <virtio_disk_init>:
{
    80006758:	1101                	addi	sp,sp,-32
    8000675a:	ec06                	sd	ra,24(sp)
    8000675c:	e822                	sd	s0,16(sp)
    8000675e:	e426                	sd	s1,8(sp)
    80006760:	e04a                	sd	s2,0(sp)
    80006762:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006764:	00002597          	auipc	a1,0x2
    80006768:	15458593          	addi	a1,a1,340 # 800088b8 <syscalls+0x330>
    8000676c:	0001e517          	auipc	a0,0x1e
    80006770:	d5450513          	addi	a0,a0,-684 # 800244c0 <disk+0x128>
    80006774:	ffffa097          	auipc	ra,0xffffa
    80006778:	3e6080e7          	jalr	998(ra) # 80000b5a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000677c:	100017b7          	lui	a5,0x10001
    80006780:	4398                	lw	a4,0(a5)
    80006782:	2701                	sext.w	a4,a4
    80006784:	747277b7          	lui	a5,0x74727
    80006788:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000678c:	14f71e63          	bne	a4,a5,800068e8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006790:	100017b7          	lui	a5,0x10001
    80006794:	43dc                	lw	a5,4(a5)
    80006796:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006798:	4709                	li	a4,2
    8000679a:	14e79763          	bne	a5,a4,800068e8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000679e:	100017b7          	lui	a5,0x10001
    800067a2:	479c                	lw	a5,8(a5)
    800067a4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800067a6:	14e79163          	bne	a5,a4,800068e8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800067aa:	100017b7          	lui	a5,0x10001
    800067ae:	47d8                	lw	a4,12(a5)
    800067b0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800067b2:	554d47b7          	lui	a5,0x554d4
    800067b6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800067ba:	12f71763          	bne	a4,a5,800068e8 <virtio_disk_init+0x190>
  *R(VIRTIO_MMIO_STATUS) = status;
    800067be:	100017b7          	lui	a5,0x10001
    800067c2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800067c6:	4705                	li	a4,1
    800067c8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800067ca:	470d                	li	a4,3
    800067cc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800067ce:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800067d0:	c7ffe737          	lui	a4,0xc7ffe
    800067d4:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fda287>
    800067d8:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800067da:	2701                	sext.w	a4,a4
    800067dc:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800067de:	472d                	li	a4,11
    800067e0:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800067e2:	0707a903          	lw	s2,112(a5)
    800067e6:	2901                	sext.w	s2,s2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800067e8:	00897793          	andi	a5,s2,8
    800067ec:	10078663          	beqz	a5,800068f8 <virtio_disk_init+0x1a0>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800067f0:	100017b7          	lui	a5,0x10001
    800067f4:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800067f8:	43fc                	lw	a5,68(a5)
    800067fa:	2781                	sext.w	a5,a5
    800067fc:	10079663          	bnez	a5,80006908 <virtio_disk_init+0x1b0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006800:	100017b7          	lui	a5,0x10001
    80006804:	5bdc                	lw	a5,52(a5)
    80006806:	2781                	sext.w	a5,a5
  if(max == 0)
    80006808:	10078863          	beqz	a5,80006918 <virtio_disk_init+0x1c0>
  if(max < NUM)
    8000680c:	471d                	li	a4,7
    8000680e:	10f77d63          	bgeu	a4,a5,80006928 <virtio_disk_init+0x1d0>
  disk.desc = kalloc();
    80006812:	ffffa097          	auipc	ra,0xffffa
    80006816:	2e8080e7          	jalr	744(ra) # 80000afa <kalloc>
    8000681a:	0001e497          	auipc	s1,0x1e
    8000681e:	b7e48493          	addi	s1,s1,-1154 # 80024398 <disk>
    80006822:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006824:	ffffa097          	auipc	ra,0xffffa
    80006828:	2d6080e7          	jalr	726(ra) # 80000afa <kalloc>
    8000682c:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000682e:	ffffa097          	auipc	ra,0xffffa
    80006832:	2cc080e7          	jalr	716(ra) # 80000afa <kalloc>
    80006836:	87aa                	mv	a5,a0
    80006838:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    8000683a:	6088                	ld	a0,0(s1)
    8000683c:	cd75                	beqz	a0,80006938 <virtio_disk_init+0x1e0>
    8000683e:	0001e717          	auipc	a4,0x1e
    80006842:	b6273703          	ld	a4,-1182(a4) # 800243a0 <disk+0x8>
    80006846:	cb6d                	beqz	a4,80006938 <virtio_disk_init+0x1e0>
    80006848:	cbe5                	beqz	a5,80006938 <virtio_disk_init+0x1e0>
  memset(disk.desc, 0, PGSIZE);
    8000684a:	6605                	lui	a2,0x1
    8000684c:	4581                	li	a1,0
    8000684e:	ffffa097          	auipc	ra,0xffffa
    80006852:	498080e7          	jalr	1176(ra) # 80000ce6 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006856:	0001e497          	auipc	s1,0x1e
    8000685a:	b4248493          	addi	s1,s1,-1214 # 80024398 <disk>
    8000685e:	6605                	lui	a2,0x1
    80006860:	4581                	li	a1,0
    80006862:	6488                	ld	a0,8(s1)
    80006864:	ffffa097          	auipc	ra,0xffffa
    80006868:	482080e7          	jalr	1154(ra) # 80000ce6 <memset>
  memset(disk.used, 0, PGSIZE);
    8000686c:	6605                	lui	a2,0x1
    8000686e:	4581                	li	a1,0
    80006870:	6888                	ld	a0,16(s1)
    80006872:	ffffa097          	auipc	ra,0xffffa
    80006876:	474080e7          	jalr	1140(ra) # 80000ce6 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000687a:	100017b7          	lui	a5,0x10001
    8000687e:	4721                	li	a4,8
    80006880:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006882:	4098                	lw	a4,0(s1)
    80006884:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006888:	40d8                	lw	a4,4(s1)
    8000688a:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000688e:	6498                	ld	a4,8(s1)
    80006890:	0007069b          	sext.w	a3,a4
    80006894:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006898:	9701                	srai	a4,a4,0x20
    8000689a:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000689e:	6898                	ld	a4,16(s1)
    800068a0:	0007069b          	sext.w	a3,a4
    800068a4:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800068a8:	9701                	srai	a4,a4,0x20
    800068aa:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800068ae:	4685                	li	a3,1
    800068b0:	c3f4                	sw	a3,68(a5)
    disk.free[i] = 1;
    800068b2:	4705                	li	a4,1
    800068b4:	00d48c23          	sb	a3,24(s1)
    800068b8:	00e48ca3          	sb	a4,25(s1)
    800068bc:	00e48d23          	sb	a4,26(s1)
    800068c0:	00e48da3          	sb	a4,27(s1)
    800068c4:	00e48e23          	sb	a4,28(s1)
    800068c8:	00e48ea3          	sb	a4,29(s1)
    800068cc:	00e48f23          	sb	a4,30(s1)
    800068d0:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800068d4:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800068d8:	0727a823          	sw	s2,112(a5)
}
    800068dc:	60e2                	ld	ra,24(sp)
    800068de:	6442                	ld	s0,16(sp)
    800068e0:	64a2                	ld	s1,8(sp)
    800068e2:	6902                	ld	s2,0(sp)
    800068e4:	6105                	addi	sp,sp,32
    800068e6:	8082                	ret
    panic("could not find virtio disk");
    800068e8:	00002517          	auipc	a0,0x2
    800068ec:	fe050513          	addi	a0,a0,-32 # 800088c8 <syscalls+0x340>
    800068f0:	ffffa097          	auipc	ra,0xffffa
    800068f4:	c54080e7          	jalr	-940(ra) # 80000544 <panic>
    panic("virtio disk FEATURES_OK unset");
    800068f8:	00002517          	auipc	a0,0x2
    800068fc:	ff050513          	addi	a0,a0,-16 # 800088e8 <syscalls+0x360>
    80006900:	ffffa097          	auipc	ra,0xffffa
    80006904:	c44080e7          	jalr	-956(ra) # 80000544 <panic>
    panic("virtio disk should not be ready");
    80006908:	00002517          	auipc	a0,0x2
    8000690c:	00050513          	mv	a0,a0
    80006910:	ffffa097          	auipc	ra,0xffffa
    80006914:	c34080e7          	jalr	-972(ra) # 80000544 <panic>
    panic("virtio disk has no queue 0");
    80006918:	00002517          	auipc	a0,0x2
    8000691c:	01050513          	addi	a0,a0,16 # 80008928 <syscalls+0x3a0>
    80006920:	ffffa097          	auipc	ra,0xffffa
    80006924:	c24080e7          	jalr	-988(ra) # 80000544 <panic>
    panic("virtio disk max queue too short");
    80006928:	00002517          	auipc	a0,0x2
    8000692c:	02050513          	addi	a0,a0,32 # 80008948 <syscalls+0x3c0>
    80006930:	ffffa097          	auipc	ra,0xffffa
    80006934:	c14080e7          	jalr	-1004(ra) # 80000544 <panic>
    panic("virtio disk kalloc");
    80006938:	00002517          	auipc	a0,0x2
    8000693c:	03050513          	addi	a0,a0,48 # 80008968 <syscalls+0x3e0>
    80006940:	ffffa097          	auipc	ra,0xffffa
    80006944:	c04080e7          	jalr	-1020(ra) # 80000544 <panic>

0000000080006948 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006948:	7159                	addi	sp,sp,-112
    8000694a:	f486                	sd	ra,104(sp)
    8000694c:	f0a2                	sd	s0,96(sp)
    8000694e:	eca6                	sd	s1,88(sp)
    80006950:	e8ca                	sd	s2,80(sp)
    80006952:	e4ce                	sd	s3,72(sp)
    80006954:	e0d2                	sd	s4,64(sp)
    80006956:	fc56                	sd	s5,56(sp)
    80006958:	f85a                	sd	s6,48(sp)
    8000695a:	f45e                	sd	s7,40(sp)
    8000695c:	f062                	sd	s8,32(sp)
    8000695e:	ec66                	sd	s9,24(sp)
    80006960:	e86a                	sd	s10,16(sp)
    80006962:	1880                	addi	s0,sp,112
    80006964:	892a                	mv	s2,a0
    80006966:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006968:	00c52c83          	lw	s9,12(a0)
    8000696c:	001c9c9b          	slliw	s9,s9,0x1
    80006970:	1c82                	slli	s9,s9,0x20
    80006972:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006976:	0001e517          	auipc	a0,0x1e
    8000697a:	b4a50513          	addi	a0,a0,-1206 # 800244c0 <disk+0x128>
    8000697e:	ffffa097          	auipc	ra,0xffffa
    80006982:	26c080e7          	jalr	620(ra) # 80000bea <acquire>
  for(int i = 0; i < 3; i++){
    80006986:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006988:	4ba1                	li	s7,8
      disk.free[i] = 0;
    8000698a:	0001eb17          	auipc	s6,0x1e
    8000698e:	a0eb0b13          	addi	s6,s6,-1522 # 80024398 <disk>
  for(int i = 0; i < 3; i++){
    80006992:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80006994:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006996:	0001ec17          	auipc	s8,0x1e
    8000699a:	b2ac0c13          	addi	s8,s8,-1238 # 800244c0 <disk+0x128>
    8000699e:	a8b5                	j	80006a1a <virtio_disk_rw+0xd2>
      disk.free[i] = 0;
    800069a0:	00fb06b3          	add	a3,s6,a5
    800069a4:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    800069a8:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    800069aa:	0207c563          	bltz	a5,800069d4 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800069ae:	2485                	addiw	s1,s1,1
    800069b0:	0711                	addi	a4,a4,4
    800069b2:	1f548a63          	beq	s1,s5,80006ba6 <virtio_disk_rw+0x25e>
    idx[i] = alloc_desc();
    800069b6:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    800069b8:	0001e697          	auipc	a3,0x1e
    800069bc:	9e068693          	addi	a3,a3,-1568 # 80024398 <disk>
    800069c0:	87d2                	mv	a5,s4
    if(disk.free[i]){
    800069c2:	0186c583          	lbu	a1,24(a3)
    800069c6:	fde9                	bnez	a1,800069a0 <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800069c8:	2785                	addiw	a5,a5,1
    800069ca:	0685                	addi	a3,a3,1
    800069cc:	ff779be3          	bne	a5,s7,800069c2 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800069d0:	57fd                	li	a5,-1
    800069d2:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    800069d4:	02905a63          	blez	s1,80006a08 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800069d8:	f9042503          	lw	a0,-112(s0)
    800069dc:	00000097          	auipc	ra,0x0
    800069e0:	cfa080e7          	jalr	-774(ra) # 800066d6 <free_desc>
      for(int j = 0; j < i; j++)
    800069e4:	4785                	li	a5,1
    800069e6:	0297d163          	bge	a5,s1,80006a08 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800069ea:	f9442503          	lw	a0,-108(s0)
    800069ee:	00000097          	auipc	ra,0x0
    800069f2:	ce8080e7          	jalr	-792(ra) # 800066d6 <free_desc>
      for(int j = 0; j < i; j++)
    800069f6:	4789                	li	a5,2
    800069f8:	0097d863          	bge	a5,s1,80006a08 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800069fc:	f9842503          	lw	a0,-104(s0)
    80006a00:	00000097          	auipc	ra,0x0
    80006a04:	cd6080e7          	jalr	-810(ra) # 800066d6 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006a08:	85e2                	mv	a1,s8
    80006a0a:	0001e517          	auipc	a0,0x1e
    80006a0e:	9a650513          	addi	a0,a0,-1626 # 800243b0 <disk+0x18>
    80006a12:	ffffc097          	auipc	ra,0xffffc
    80006a16:	b2e080e7          	jalr	-1234(ra) # 80002540 <sleep>
  for(int i = 0; i < 3; i++){
    80006a1a:	f9040713          	addi	a4,s0,-112
    80006a1e:	84ce                	mv	s1,s3
    80006a20:	bf59                	j	800069b6 <virtio_disk_rw+0x6e>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80006a22:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    80006a26:	00479693          	slli	a3,a5,0x4
    80006a2a:	0001e797          	auipc	a5,0x1e
    80006a2e:	96e78793          	addi	a5,a5,-1682 # 80024398 <disk>
    80006a32:	97b6                	add	a5,a5,a3
    80006a34:	4685                	li	a3,1
    80006a36:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006a38:	0001e597          	auipc	a1,0x1e
    80006a3c:	96058593          	addi	a1,a1,-1696 # 80024398 <disk>
    80006a40:	00a60793          	addi	a5,a2,10
    80006a44:	0792                	slli	a5,a5,0x4
    80006a46:	97ae                	add	a5,a5,a1
    80006a48:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    80006a4c:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006a50:	f6070693          	addi	a3,a4,-160
    80006a54:	619c                	ld	a5,0(a1)
    80006a56:	97b6                	add	a5,a5,a3
    80006a58:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006a5a:	6188                	ld	a0,0(a1)
    80006a5c:	96aa                	add	a3,a3,a0
    80006a5e:	47c1                	li	a5,16
    80006a60:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006a62:	4785                	li	a5,1
    80006a64:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006a68:	f9442783          	lw	a5,-108(s0)
    80006a6c:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006a70:	0792                	slli	a5,a5,0x4
    80006a72:	953e                	add	a0,a0,a5
    80006a74:	05890693          	addi	a3,s2,88
    80006a78:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    80006a7a:	6188                	ld	a0,0(a1)
    80006a7c:	97aa                	add	a5,a5,a0
    80006a7e:	40000693          	li	a3,1024
    80006a82:	c794                	sw	a3,8(a5)
  if(write)
    80006a84:	100d0d63          	beqz	s10,80006b9e <virtio_disk_rw+0x256>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006a88:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006a8c:	00c7d683          	lhu	a3,12(a5)
    80006a90:	0016e693          	ori	a3,a3,1
    80006a94:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    80006a98:	f9842583          	lw	a1,-104(s0)
    80006a9c:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006aa0:	0001e697          	auipc	a3,0x1e
    80006aa4:	8f868693          	addi	a3,a3,-1800 # 80024398 <disk>
    80006aa8:	00260793          	addi	a5,a2,2
    80006aac:	0792                	slli	a5,a5,0x4
    80006aae:	97b6                	add	a5,a5,a3
    80006ab0:	587d                	li	a6,-1
    80006ab2:	01078823          	sb	a6,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006ab6:	0592                	slli	a1,a1,0x4
    80006ab8:	952e                	add	a0,a0,a1
    80006aba:	f9070713          	addi	a4,a4,-112
    80006abe:	9736                	add	a4,a4,a3
    80006ac0:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    80006ac2:	6298                	ld	a4,0(a3)
    80006ac4:	972e                	add	a4,a4,a1
    80006ac6:	4585                	li	a1,1
    80006ac8:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006aca:	4509                	li	a0,2
    80006acc:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    80006ad0:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006ad4:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    80006ad8:	0127b423          	sd	s2,8(a5)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006adc:	6698                	ld	a4,8(a3)
    80006ade:	00275783          	lhu	a5,2(a4)
    80006ae2:	8b9d                	andi	a5,a5,7
    80006ae4:	0786                	slli	a5,a5,0x1
    80006ae6:	97ba                	add	a5,a5,a4
    80006ae8:	00c79223          	sh	a2,4(a5)

  __sync_synchronize();
    80006aec:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006af0:	6698                	ld	a4,8(a3)
    80006af2:	00275783          	lhu	a5,2(a4)
    80006af6:	2785                	addiw	a5,a5,1
    80006af8:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006afc:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006b00:	100017b7          	lui	a5,0x10001
    80006b04:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006b08:	00492703          	lw	a4,4(s2)
    80006b0c:	4785                	li	a5,1
    80006b0e:	02f71163          	bne	a4,a5,80006b30 <virtio_disk_rw+0x1e8>
    sleep(b, &disk.vdisk_lock);
    80006b12:	0001e997          	auipc	s3,0x1e
    80006b16:	9ae98993          	addi	s3,s3,-1618 # 800244c0 <disk+0x128>
  while(b->disk == 1) {
    80006b1a:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006b1c:	85ce                	mv	a1,s3
    80006b1e:	854a                	mv	a0,s2
    80006b20:	ffffc097          	auipc	ra,0xffffc
    80006b24:	a20080e7          	jalr	-1504(ra) # 80002540 <sleep>
  while(b->disk == 1) {
    80006b28:	00492783          	lw	a5,4(s2)
    80006b2c:	fe9788e3          	beq	a5,s1,80006b1c <virtio_disk_rw+0x1d4>
  }

  disk.info[idx[0]].b = 0;
    80006b30:	f9042903          	lw	s2,-112(s0)
    80006b34:	00290793          	addi	a5,s2,2
    80006b38:	00479713          	slli	a4,a5,0x4
    80006b3c:	0001e797          	auipc	a5,0x1e
    80006b40:	85c78793          	addi	a5,a5,-1956 # 80024398 <disk>
    80006b44:	97ba                	add	a5,a5,a4
    80006b46:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006b4a:	0001e997          	auipc	s3,0x1e
    80006b4e:	84e98993          	addi	s3,s3,-1970 # 80024398 <disk>
    80006b52:	00491713          	slli	a4,s2,0x4
    80006b56:	0009b783          	ld	a5,0(s3)
    80006b5a:	97ba                	add	a5,a5,a4
    80006b5c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006b60:	854a                	mv	a0,s2
    80006b62:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006b66:	00000097          	auipc	ra,0x0
    80006b6a:	b70080e7          	jalr	-1168(ra) # 800066d6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006b6e:	8885                	andi	s1,s1,1
    80006b70:	f0ed                	bnez	s1,80006b52 <virtio_disk_rw+0x20a>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006b72:	0001e517          	auipc	a0,0x1e
    80006b76:	94e50513          	addi	a0,a0,-1714 # 800244c0 <disk+0x128>
    80006b7a:	ffffa097          	auipc	ra,0xffffa
    80006b7e:	124080e7          	jalr	292(ra) # 80000c9e <release>
}
    80006b82:	70a6                	ld	ra,104(sp)
    80006b84:	7406                	ld	s0,96(sp)
    80006b86:	64e6                	ld	s1,88(sp)
    80006b88:	6946                	ld	s2,80(sp)
    80006b8a:	69a6                	ld	s3,72(sp)
    80006b8c:	6a06                	ld	s4,64(sp)
    80006b8e:	7ae2                	ld	s5,56(sp)
    80006b90:	7b42                	ld	s6,48(sp)
    80006b92:	7ba2                	ld	s7,40(sp)
    80006b94:	7c02                	ld	s8,32(sp)
    80006b96:	6ce2                	ld	s9,24(sp)
    80006b98:	6d42                	ld	s10,16(sp)
    80006b9a:	6165                	addi	sp,sp,112
    80006b9c:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006b9e:	4689                	li	a3,2
    80006ba0:	00d79623          	sh	a3,12(a5)
    80006ba4:	b5e5                	j	80006a8c <virtio_disk_rw+0x144>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006ba6:	f9042603          	lw	a2,-112(s0)
    80006baa:	00a60713          	addi	a4,a2,10
    80006bae:	0712                	slli	a4,a4,0x4
    80006bb0:	0001d517          	auipc	a0,0x1d
    80006bb4:	7f050513          	addi	a0,a0,2032 # 800243a0 <disk+0x8>
    80006bb8:	953a                	add	a0,a0,a4
  if(write)
    80006bba:	e60d14e3          	bnez	s10,80006a22 <virtio_disk_rw+0xda>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    80006bbe:	00a60793          	addi	a5,a2,10
    80006bc2:	00479693          	slli	a3,a5,0x4
    80006bc6:	0001d797          	auipc	a5,0x1d
    80006bca:	7d278793          	addi	a5,a5,2002 # 80024398 <disk>
    80006bce:	97b6                	add	a5,a5,a3
    80006bd0:	0007a423          	sw	zero,8(a5)
    80006bd4:	b595                	j	80006a38 <virtio_disk_rw+0xf0>

0000000080006bd6 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006bd6:	1101                	addi	sp,sp,-32
    80006bd8:	ec06                	sd	ra,24(sp)
    80006bda:	e822                	sd	s0,16(sp)
    80006bdc:	e426                	sd	s1,8(sp)
    80006bde:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006be0:	0001d497          	auipc	s1,0x1d
    80006be4:	7b848493          	addi	s1,s1,1976 # 80024398 <disk>
    80006be8:	0001e517          	auipc	a0,0x1e
    80006bec:	8d850513          	addi	a0,a0,-1832 # 800244c0 <disk+0x128>
    80006bf0:	ffffa097          	auipc	ra,0xffffa
    80006bf4:	ffa080e7          	jalr	-6(ra) # 80000bea <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006bf8:	10001737          	lui	a4,0x10001
    80006bfc:	533c                	lw	a5,96(a4)
    80006bfe:	8b8d                	andi	a5,a5,3
    80006c00:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006c02:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006c06:	689c                	ld	a5,16(s1)
    80006c08:	0204d703          	lhu	a4,32(s1)
    80006c0c:	0027d783          	lhu	a5,2(a5)
    80006c10:	04f70863          	beq	a4,a5,80006c60 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006c14:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006c18:	6898                	ld	a4,16(s1)
    80006c1a:	0204d783          	lhu	a5,32(s1)
    80006c1e:	8b9d                	andi	a5,a5,7
    80006c20:	078e                	slli	a5,a5,0x3
    80006c22:	97ba                	add	a5,a5,a4
    80006c24:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006c26:	00278713          	addi	a4,a5,2
    80006c2a:	0712                	slli	a4,a4,0x4
    80006c2c:	9726                	add	a4,a4,s1
    80006c2e:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006c32:	e721                	bnez	a4,80006c7a <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006c34:	0789                	addi	a5,a5,2
    80006c36:	0792                	slli	a5,a5,0x4
    80006c38:	97a6                	add	a5,a5,s1
    80006c3a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006c3c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006c40:	ffffc097          	auipc	ra,0xffffc
    80006c44:	ade080e7          	jalr	-1314(ra) # 8000271e <wakeup>

    disk.used_idx += 1;
    80006c48:	0204d783          	lhu	a5,32(s1)
    80006c4c:	2785                	addiw	a5,a5,1
    80006c4e:	17c2                	slli	a5,a5,0x30
    80006c50:	93c1                	srli	a5,a5,0x30
    80006c52:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006c56:	6898                	ld	a4,16(s1)
    80006c58:	00275703          	lhu	a4,2(a4)
    80006c5c:	faf71ce3          	bne	a4,a5,80006c14 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006c60:	0001e517          	auipc	a0,0x1e
    80006c64:	86050513          	addi	a0,a0,-1952 # 800244c0 <disk+0x128>
    80006c68:	ffffa097          	auipc	ra,0xffffa
    80006c6c:	036080e7          	jalr	54(ra) # 80000c9e <release>
}
    80006c70:	60e2                	ld	ra,24(sp)
    80006c72:	6442                	ld	s0,16(sp)
    80006c74:	64a2                	ld	s1,8(sp)
    80006c76:	6105                	addi	sp,sp,32
    80006c78:	8082                	ret
      panic("virtio_disk_intr status");
    80006c7a:	00002517          	auipc	a0,0x2
    80006c7e:	d0650513          	addi	a0,a0,-762 # 80008980 <syscalls+0x3f8>
    80006c82:	ffffa097          	auipc	ra,0xffffa
    80006c86:	8c2080e7          	jalr	-1854(ra) # 80000544 <panic>
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
