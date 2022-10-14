
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
    80000068:	2bc78793          	addi	a5,a5,700 # 80006320 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffda54f>
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
    80000130:	74a080e7          	jalr	1866(ra) # 80002876 <either_copyin>
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
    80000198:	a56080e7          	jalr	-1450(ra) # 80000bea <acquire>
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
    800001c8:	908080e7          	jalr	-1784(ra) # 80001acc <myproc>
    800001cc:	00002097          	auipc	ra,0x2
    800001d0:	4dc080e7          	jalr	1244(ra) # 800026a8 <killed>
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
    8000021a:	60a080e7          	jalr	1546(ra) # 80002820 <either_copyout>
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
    80000236:	a6c080e7          	jalr	-1428(ra) # 80000c9e <release>

  return target - n;
    8000023a:	414b853b          	subw	a0,s7,s4
    8000023e:	a811                	j	80000252 <consoleread+0xee>
        release(&cons.lock);
    80000240:	00011517          	auipc	a0,0x11
    80000244:	b4050513          	addi	a0,a0,-1216 # 80010d80 <cons>
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
    800002fc:	5d4080e7          	jalr	1492(ra) # 800028cc <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000300:	00011517          	auipc	a0,0x11
    80000304:	a8050513          	addi	a0,a0,-1408 # 80010d80 <cons>
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
    80000450:	fb6080e7          	jalr	-74(ra) # 80002402 <wakeup>
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
    8000046e:	00000097          	auipc	ra,0x0
    80000472:	6ec080e7          	jalr	1772(ra) # 80000b5a <initlock>

  uartinit();
    80000476:	00000097          	auipc	ra,0x0
    8000047a:	330080e7          	jalr	816(ra) # 800007a6 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000047e:	00023797          	auipc	a5,0x23
    80000482:	c9a78793          	addi	a5,a5,-870 # 80023118 <devsw>
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
    80000576:	b5650513          	addi	a0,a0,-1194 # 800080c8 <digits+0x88>
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
    80000766:	6c650513          	addi	a0,a0,1734 # 80010e28 <pr>
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
    80000782:	6aa48493          	addi	s1,s1,1706 # 80010e28 <pr>
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
    800007e2:	66a50513          	addi	a0,a0,1642 # 80010e48 <uart_tx_lock>
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
    800008aa:	b5c080e7          	jalr	-1188(ra) # 80002402 <wakeup>
    
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
    800008ee:	300080e7          	jalr	768(ra) # 80000bea <acquire>
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
    80000934:	910080e7          	jalr	-1776(ra) # 80002240 <sleep>
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
    800009d4:	47848493          	addi	s1,s1,1144 # 80010e48 <uart_tx_lock>
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
    80000a16:	89e78793          	addi	a5,a5,-1890 # 800242b0 <end>
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
    80000a36:	44e90913          	addi	s2,s2,1102 # 80010e80 <kmem>
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
    80000ad2:	3b250513          	addi	a0,a0,946 # 80010e80 <kmem>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	084080e7          	jalr	132(ra) # 80000b5a <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ade:	45c5                	li	a1,17
    80000ae0:	05ee                	slli	a1,a1,0x1b
    80000ae2:	00023517          	auipc	a0,0x23
    80000ae6:	7ce50513          	addi	a0,a0,1998 # 800242b0 <end>
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
    80000b08:	37c48493          	addi	s1,s1,892 # 80010e80 <kmem>
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
    80000b20:	36450513          	addi	a0,a0,868 # 80010e80 <kmem>
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
    80000b4c:	33850513          	addi	a0,a0,824 # 80010e80 <kmem>
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
    80000b88:	f2c080e7          	jalr	-212(ra) # 80001ab0 <mycpu>
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
    80000bba:	efa080e7          	jalr	-262(ra) # 80001ab0 <mycpu>
    80000bbe:	5d3c                	lw	a5,120(a0)
    80000bc0:	cf89                	beqz	a5,80000bda <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bc2:	00001097          	auipc	ra,0x1
    80000bc6:	eee080e7          	jalr	-274(ra) # 80001ab0 <mycpu>
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
    80000bde:	ed6080e7          	jalr	-298(ra) # 80001ab0 <mycpu>
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
    80000c1e:	e96080e7          	jalr	-362(ra) # 80001ab0 <mycpu>
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
    80000c4a:	e6a080e7          	jalr	-406(ra) # 80001ab0 <mycpu>
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
    80000ce6:	1141                	addi	sp,sp,-16
    80000ce8:	e422                	sd	s0,8(sp)
    80000cea:	0800                	addi	s0,sp,16
    80000cec:	ce09                	beqz	a2,80000d06 <memset+0x20>
    80000cee:	87aa                	mv	a5,a0
    80000cf0:	fff6071b          	addiw	a4,a2,-1
    80000cf4:	1702                	slli	a4,a4,0x20
    80000cf6:	9301                	srli	a4,a4,0x20
    80000cf8:	0705                	addi	a4,a4,1
    80000cfa:	972a                	add	a4,a4,a0
    80000cfc:	00b78023          	sb	a1,0(a5)
    80000d00:	0785                	addi	a5,a5,1
    80000d02:	fee79de3          	bne	a5,a4,80000cfc <memset+0x16>
    80000d06:	6422                	ld	s0,8(sp)
    80000d08:	0141                	addi	sp,sp,16
    80000d0a:	8082                	ret

0000000080000d0c <memcmp>:
    80000d0c:	1141                	addi	sp,sp,-16
    80000d0e:	e422                	sd	s0,8(sp)
    80000d10:	0800                	addi	s0,sp,16
    80000d12:	ca05                	beqz	a2,80000d42 <memcmp+0x36>
    80000d14:	fff6069b          	addiw	a3,a2,-1
    80000d18:	1682                	slli	a3,a3,0x20
    80000d1a:	9281                	srli	a3,a3,0x20
    80000d1c:	0685                	addi	a3,a3,1
    80000d1e:	96aa                	add	a3,a3,a0
    80000d20:	00054783          	lbu	a5,0(a0)
    80000d24:	0005c703          	lbu	a4,0(a1)
    80000d28:	00e79863          	bne	a5,a4,80000d38 <memcmp+0x2c>
    80000d2c:	0505                	addi	a0,a0,1
    80000d2e:	0585                	addi	a1,a1,1
    80000d30:	fed518e3          	bne	a0,a3,80000d20 <memcmp+0x14>
    80000d34:	4501                	li	a0,0
    80000d36:	a019                	j	80000d3c <memcmp+0x30>
    80000d38:	40e7853b          	subw	a0,a5,a4
    80000d3c:	6422                	ld	s0,8(sp)
    80000d3e:	0141                	addi	sp,sp,16
    80000d40:	8082                	ret
    80000d42:	4501                	li	a0,0
    80000d44:	bfe5                	j	80000d3c <memcmp+0x30>

0000000080000d46 <memmove>:
    80000d46:	1141                	addi	sp,sp,-16
    80000d48:	e422                	sd	s0,8(sp)
    80000d4a:	0800                	addi	s0,sp,16
    80000d4c:	ca0d                	beqz	a2,80000d7e <memmove+0x38>
    80000d4e:	00a5f963          	bgeu	a1,a0,80000d60 <memmove+0x1a>
    80000d52:	02061693          	slli	a3,a2,0x20
    80000d56:	9281                	srli	a3,a3,0x20
    80000d58:	00d58733          	add	a4,a1,a3
    80000d5c:	02e56463          	bltu	a0,a4,80000d84 <memmove+0x3e>
    80000d60:	fff6079b          	addiw	a5,a2,-1
    80000d64:	1782                	slli	a5,a5,0x20
    80000d66:	9381                	srli	a5,a5,0x20
    80000d68:	0785                	addi	a5,a5,1
    80000d6a:	97ae                	add	a5,a5,a1
    80000d6c:	872a                	mv	a4,a0
    80000d6e:	0585                	addi	a1,a1,1
    80000d70:	0705                	addi	a4,a4,1
    80000d72:	fff5c683          	lbu	a3,-1(a1)
    80000d76:	fed70fa3          	sb	a3,-1(a4)
    80000d7a:	fef59ae3          	bne	a1,a5,80000d6e <memmove+0x28>
    80000d7e:	6422                	ld	s0,8(sp)
    80000d80:	0141                	addi	sp,sp,16
    80000d82:	8082                	ret
    80000d84:	96aa                	add	a3,a3,a0
    80000d86:	fff6079b          	addiw	a5,a2,-1
    80000d8a:	1782                	slli	a5,a5,0x20
    80000d8c:	9381                	srli	a5,a5,0x20
    80000d8e:	fff7c793          	not	a5,a5
    80000d92:	97ba                	add	a5,a5,a4
    80000d94:	177d                	addi	a4,a4,-1
    80000d96:	16fd                	addi	a3,a3,-1
    80000d98:	00074603          	lbu	a2,0(a4)
    80000d9c:	00c68023          	sb	a2,0(a3)
    80000da0:	fef71ae3          	bne	a4,a5,80000d94 <memmove+0x4e>
    80000da4:	bfe9                	j	80000d7e <memmove+0x38>

0000000080000da6 <memcpy>:
    80000da6:	1141                	addi	sp,sp,-16
    80000da8:	e406                	sd	ra,8(sp)
    80000daa:	e022                	sd	s0,0(sp)
    80000dac:	0800                	addi	s0,sp,16
    80000dae:	00000097          	auipc	ra,0x0
    80000db2:	f98080e7          	jalr	-104(ra) # 80000d46 <memmove>
    80000db6:	60a2                	ld	ra,8(sp)
    80000db8:	6402                	ld	s0,0(sp)
    80000dba:	0141                	addi	sp,sp,16
    80000dbc:	8082                	ret

0000000080000dbe <strncmp>:
    80000dbe:	1141                	addi	sp,sp,-16
    80000dc0:	e422                	sd	s0,8(sp)
    80000dc2:	0800                	addi	s0,sp,16
    80000dc4:	ce11                	beqz	a2,80000de0 <strncmp+0x22>
    80000dc6:	00054783          	lbu	a5,0(a0)
    80000dca:	cf89                	beqz	a5,80000de4 <strncmp+0x26>
    80000dcc:	0005c703          	lbu	a4,0(a1)
    80000dd0:	00f71a63          	bne	a4,a5,80000de4 <strncmp+0x26>
    80000dd4:	367d                	addiw	a2,a2,-1
    80000dd6:	0505                	addi	a0,a0,1
    80000dd8:	0585                	addi	a1,a1,1
    80000dda:	f675                	bnez	a2,80000dc6 <strncmp+0x8>
    80000ddc:	4501                	li	a0,0
    80000dde:	a809                	j	80000df0 <strncmp+0x32>
    80000de0:	4501                	li	a0,0
    80000de2:	a039                	j	80000df0 <strncmp+0x32>
    80000de4:	ca09                	beqz	a2,80000df6 <strncmp+0x38>
    80000de6:	00054503          	lbu	a0,0(a0)
    80000dea:	0005c783          	lbu	a5,0(a1)
    80000dee:	9d1d                	subw	a0,a0,a5
    80000df0:	6422                	ld	s0,8(sp)
    80000df2:	0141                	addi	sp,sp,16
    80000df4:	8082                	ret
    80000df6:	4501                	li	a0,0
    80000df8:	bfe5                	j	80000df0 <strncmp+0x32>

0000000080000dfa <strncpy>:
    80000dfa:	1141                	addi	sp,sp,-16
    80000dfc:	e422                	sd	s0,8(sp)
    80000dfe:	0800                	addi	s0,sp,16
    80000e00:	872a                	mv	a4,a0
    80000e02:	8832                	mv	a6,a2
    80000e04:	367d                	addiw	a2,a2,-1
    80000e06:	01005963          	blez	a6,80000e18 <strncpy+0x1e>
    80000e0a:	0705                	addi	a4,a4,1
    80000e0c:	0005c783          	lbu	a5,0(a1)
    80000e10:	fef70fa3          	sb	a5,-1(a4)
    80000e14:	0585                	addi	a1,a1,1
    80000e16:	f7f5                	bnez	a5,80000e02 <strncpy+0x8>
    80000e18:	00c05d63          	blez	a2,80000e32 <strncpy+0x38>
    80000e1c:	86ba                	mv	a3,a4
    80000e1e:	0685                	addi	a3,a3,1
    80000e20:	fe068fa3          	sb	zero,-1(a3)
    80000e24:	fff6c793          	not	a5,a3
    80000e28:	9fb9                	addw	a5,a5,a4
    80000e2a:	010787bb          	addw	a5,a5,a6
    80000e2e:	fef048e3          	bgtz	a5,80000e1e <strncpy+0x24>
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret

0000000080000e38 <safestrcpy>:
    80000e38:	1141                	addi	sp,sp,-16
    80000e3a:	e422                	sd	s0,8(sp)
    80000e3c:	0800                	addi	s0,sp,16
    80000e3e:	02c05363          	blez	a2,80000e64 <safestrcpy+0x2c>
    80000e42:	fff6069b          	addiw	a3,a2,-1
    80000e46:	1682                	slli	a3,a3,0x20
    80000e48:	9281                	srli	a3,a3,0x20
    80000e4a:	96ae                	add	a3,a3,a1
    80000e4c:	87aa                	mv	a5,a0
    80000e4e:	00d58963          	beq	a1,a3,80000e60 <safestrcpy+0x28>
    80000e52:	0585                	addi	a1,a1,1
    80000e54:	0785                	addi	a5,a5,1
    80000e56:	fff5c703          	lbu	a4,-1(a1)
    80000e5a:	fee78fa3          	sb	a4,-1(a5)
    80000e5e:	fb65                	bnez	a4,80000e4e <safestrcpy+0x16>
    80000e60:	00078023          	sb	zero,0(a5)
    80000e64:	6422                	ld	s0,8(sp)
    80000e66:	0141                	addi	sp,sp,16
    80000e68:	8082                	ret

0000000080000e6a <strlen>:
    80000e6a:	1141                	addi	sp,sp,-16
    80000e6c:	e422                	sd	s0,8(sp)
    80000e6e:	0800                	addi	s0,sp,16
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
    80000e8a:	6422                	ld	s0,8(sp)
    80000e8c:	0141                	addi	sp,sp,16
    80000e8e:	8082                	ret
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
    80000ea0:	c04080e7          	jalr	-1020(ra) # 80001aa0 <cpuid>
    pinit();
    #endif
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000ea4:	00008717          	auipc	a4,0x8
    80000ea8:	d7470713          	addi	a4,a4,-652 # 80008c18 <started>
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
    80000ebc:	be8080e7          	jalr	-1048(ra) # 80001aa0 <cpuid>
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
    80000ede:	b42080e7          	jalr	-1214(ra) # 80002a1c <trapinithart>
    // printf("trapinit done\n");
    plicinithart();   // ask PLIC for device interrupts
    80000ee2:	00005097          	auipc	ra,0x5
    80000ee6:	47e080e7          	jalr	1150(ra) # 80006360 <plicinithart>
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
    80000f56:	aa2080e7          	jalr	-1374(ra) # 800029f4 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f5a:	00002097          	auipc	ra,0x2
    80000f5e:	ac2080e7          	jalr	-1342(ra) # 80002a1c <trapinithart>
    plicinit();      // set up interrupt controller
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	3e8080e7          	jalr	1000(ra) # 8000634a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f6a:	00005097          	auipc	ra,0x5
    80000f6e:	3f6080e7          	jalr	1014(ra) # 80006360 <plicinithart>
    binit();         // buffer cache
    80000f72:	00002097          	auipc	ra,0x2
    80000f76:	5ae080e7          	jalr	1454(ra) # 80003520 <binit>
    iinit();         // inode table
    80000f7a:	00003097          	auipc	ra,0x3
    80000f7e:	c52080e7          	jalr	-942(ra) # 80003bcc <iinit>
    fileinit();      // file table
    80000f82:	00004097          	auipc	ra,0x4
    80000f86:	bf0080e7          	jalr	-1040(ra) # 80004b72 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f8a:	00005097          	auipc	ra,0x5
    80000f8e:	4de080e7          	jalr	1246(ra) # 80006468 <virtio_disk_init>
    userinit();      // first user process
    80000f92:	00001097          	auipc	ra,0x1
    80000f96:	e4e080e7          	jalr	-434(ra) # 80001de0 <userinit>
    __sync_synchronize();
    80000f9a:	0ff0000f          	fence
    started = 1;
    80000f9e:	4785                	li	a5,1
    80000fa0:	00008717          	auipc	a4,0x8
    80000fa4:	c6f72c23          	sw	a5,-904(a4) # 80008c18 <started>
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
    80000fb8:	c6c7b783          	ld	a5,-916(a5) # 80008c20 <kernel_pagetable>
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
    80001274:	9aa7b823          	sd	a0,-1616(a5) # 80008c20 <kernel_pagetable>
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
    80001858:	1cf52023          	sw	a5,448(a0)
	if (process->runTimePrev == 0)
    8000185c:	1b052783          	lw	a5,432(a0)
    80001860:	e791                	bnez	a5,8000186c <calculateDynamicPriority+0x1c>
	{
		if (process->sleepTimePrev == 0)
    80001862:	1a852783          	lw	a5,424(a0)
    80001866:	e399                	bnez	a5,8000186c <calculateDynamicPriority+0x1c>
		{
			process->niceness = process->sleepTimePrev * 10;
			process->niceness /= (process->runTimePrev + process->sleepTimePrev);
    80001868:	1c052023          	sw	zero,448(a0)
		}
	}
	int retval = 0, checker = process->sprior - process->niceness + 5;
    8000186c:	1b852783          	lw	a5,440(a0)
    80001870:	2795                	addiw	a5,a5,5
    80001872:	1c052503          	lw	a0,448(a0)
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
    800018bc:	a1848493          	addi	s1,s1,-1512 # 800112d0 <proc>
    800018c0:	00017a17          	auipc	s4,0x17
    800018c4:	610a0a13          	addi	s4,s4,1552 # 80018ed0 <tickslock>
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
    800018ea:	1f048493          	addi	s1,s1,496
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
    8000191e:	1b84a983          	lw	s3,440(s1)
		i->sprior = static_prior;
    80001922:	1b54ac23          	sw	s5,440(s1)
		i->niceness = 5;
    80001926:	4795                	li	a5,5
    80001928:	1cf4a023          	sw	a5,448(s1)
		i->dprior = calculateDynamicPriority(i);
    8000192c:	8526                	mv	a0,s1
    8000192e:	00000097          	auipc	ra,0x0
    80001932:	f22080e7          	jalr	-222(ra) # 80001850 <calculateDynamicPriority>
    80001936:	1aa4ae23          	sw	a0,444(s1)
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
    80001972:	96248493          	addi	s1,s1,-1694 # 800112d0 <proc>
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
    8000198c:	548a0a13          	addi	s4,s4,1352 # 80018ed0 <tickslock>
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
    800019c2:	1f048493          	addi	s1,s1,496
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
    80001a0e:	49650513          	addi	a0,a0,1174 # 80010ea0 <pid_lock>
    80001a12:	fffff097          	auipc	ra,0xfffff
    80001a16:	148080e7          	jalr	328(ra) # 80000b5a <initlock>
	initlock(&wait_lock, "wait_lock");
    80001a1a:	00006597          	auipc	a1,0x6
    80001a1e:	7e658593          	addi	a1,a1,2022 # 80008200 <digits+0x1c0>
    80001a22:	0000f517          	auipc	a0,0xf
    80001a26:	49650513          	addi	a0,a0,1174 # 80010eb8 <wait_lock>
    80001a2a:	fffff097          	auipc	ra,0xfffff
    80001a2e:	130080e7          	jalr	304(ra) # 80000b5a <initlock>
	for (p = proc; p < &proc[NPROC]; p++)
    80001a32:	00010497          	auipc	s1,0x10
    80001a36:	89e48493          	addi	s1,s1,-1890 # 800112d0 <proc>
	{
		initlock(&p->lock, "proc");
    80001a3a:	00006b17          	auipc	s6,0x6
    80001a3e:	7d6b0b13          	addi	s6,s6,2006 # 80008210 <digits+0x1d0>
		// p->state = UNUSED;
		p->kstack = KSTACK((int)(p - proc));
    80001a42:	8aa6                	mv	s5,s1
    80001a44:	00006a17          	auipc	s4,0x6
    80001a48:	5bca0a13          	addi	s4,s4,1468 # 80008000 <etext>
    80001a4c:	04000937          	lui	s2,0x4000
    80001a50:	197d                	addi	s2,s2,-1
    80001a52:	0932                	slli	s2,s2,0xc
	for (p = proc; p < &proc[NPROC]; p++)
    80001a54:	00017997          	auipc	s3,0x17
    80001a58:	47c98993          	addi	s3,s3,1148 # 80018ed0 <tickslock>
		initlock(&p->lock, "proc");
    80001a5c:	85da                	mv	a1,s6
    80001a5e:	00848513          	addi	a0,s1,8
    80001a62:	fffff097          	auipc	ra,0xfffff
    80001a66:	0f8080e7          	jalr	248(ra) # 80000b5a <initlock>
		p->kstack = KSTACK((int)(p - proc));
    80001a6a:	415487b3          	sub	a5,s1,s5
    80001a6e:	8791                	srai	a5,a5,0x4
    80001a70:	000a3703          	ld	a4,0(s4)
    80001a74:	02e787b3          	mul	a5,a5,a4
    80001a78:	2785                	addiw	a5,a5,1
    80001a7a:	00d7979b          	slliw	a5,a5,0xd
    80001a7e:	40f907b3          	sub	a5,s2,a5
    80001a82:	e4bc                	sd	a5,72(s1)
	for (p = proc; p < &proc[NPROC]; p++)
    80001a84:	1f048493          	addi	s1,s1,496
    80001a88:	fd349ae3          	bne	s1,s3,80001a5c <procinit+0x6e>
	}
}
    80001a8c:	70e2                	ld	ra,56(sp)
    80001a8e:	7442                	ld	s0,48(sp)
    80001a90:	74a2                	ld	s1,40(sp)
    80001a92:	7902                	ld	s2,32(sp)
    80001a94:	69e2                	ld	s3,24(sp)
    80001a96:	6a42                	ld	s4,16(sp)
    80001a98:	6aa2                	ld	s5,8(sp)
    80001a9a:	6b02                	ld	s6,0(sp)
    80001a9c:	6121                	addi	sp,sp,64
    80001a9e:	8082                	ret

0000000080001aa0 <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    80001aa0:	1141                	addi	sp,sp,-16
    80001aa2:	e422                	sd	s0,8(sp)
    80001aa4:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001aa6:	8512                	mv	a0,tp
	int id = r_tp();
	return id;
}
    80001aa8:	2501                	sext.w	a0,a0
    80001aaa:	6422                	ld	s0,8(sp)
    80001aac:	0141                	addi	sp,sp,16
    80001aae:	8082                	ret

0000000080001ab0 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001ab0:	1141                	addi	sp,sp,-16
    80001ab2:	e422                	sd	s0,8(sp)
    80001ab4:	0800                	addi	s0,sp,16
    80001ab6:	8792                	mv	a5,tp
	int id = cpuid();
	struct cpu *c = &cpus[id];
    80001ab8:	2781                	sext.w	a5,a5
    80001aba:	079e                	slli	a5,a5,0x7
	return c;
}
    80001abc:	0000f517          	auipc	a0,0xf
    80001ac0:	41450513          	addi	a0,a0,1044 # 80010ed0 <cpus>
    80001ac4:	953e                	add	a0,a0,a5
    80001ac6:	6422                	ld	s0,8(sp)
    80001ac8:	0141                	addi	sp,sp,16
    80001aca:	8082                	ret

0000000080001acc <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001acc:	1101                	addi	sp,sp,-32
    80001ace:	ec06                	sd	ra,24(sp)
    80001ad0:	e822                	sd	s0,16(sp)
    80001ad2:	e426                	sd	s1,8(sp)
    80001ad4:	1000                	addi	s0,sp,32
	push_off();
    80001ad6:	fffff097          	auipc	ra,0xfffff
    80001ada:	0c8080e7          	jalr	200(ra) # 80000b9e <push_off>
    80001ade:	8792                	mv	a5,tp
	struct cpu *c = mycpu();
	struct proc *p = c->proc;
    80001ae0:	2781                	sext.w	a5,a5
    80001ae2:	079e                	slli	a5,a5,0x7
    80001ae4:	0000f717          	auipc	a4,0xf
    80001ae8:	3bc70713          	addi	a4,a4,956 # 80010ea0 <pid_lock>
    80001aec:	97ba                	add	a5,a5,a4
    80001aee:	7b84                	ld	s1,48(a5)
	pop_off();
    80001af0:	fffff097          	auipc	ra,0xfffff
    80001af4:	14e080e7          	jalr	334(ra) # 80000c3e <pop_off>
	return p;
}
    80001af8:	8526                	mv	a0,s1
    80001afa:	60e2                	ld	ra,24(sp)
    80001afc:	6442                	ld	s0,16(sp)
    80001afe:	64a2                	ld	s1,8(sp)
    80001b00:	6105                	addi	sp,sp,32
    80001b02:	8082                	ret

0000000080001b04 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001b04:	1141                	addi	sp,sp,-16
    80001b06:	e406                	sd	ra,8(sp)
    80001b08:	e022                	sd	s0,0(sp)
    80001b0a:	0800                	addi	s0,sp,16
	static int first = 1;

	// Still holding p->lock from scheduler.
	release(&myproc()->lock);
    80001b0c:	00000097          	auipc	ra,0x0
    80001b10:	fc0080e7          	jalr	-64(ra) # 80001acc <myproc>
    80001b14:	0521                	addi	a0,a0,8
    80001b16:	fffff097          	auipc	ra,0xfffff
    80001b1a:	188080e7          	jalr	392(ra) # 80000c9e <release>

	if (first)
    80001b1e:	00007797          	auipc	a5,0x7
    80001b22:	ea27a783          	lw	a5,-350(a5) # 800089c0 <first.2459>
    80001b26:	eb89                	bnez	a5,80001b38 <forkret+0x34>
		// be run from main().
		first = 0;
		fsinit(ROOTDEV);
	}

	usertrapret();
    80001b28:	00001097          	auipc	ra,0x1
    80001b2c:	f0c080e7          	jalr	-244(ra) # 80002a34 <usertrapret>
}
    80001b30:	60a2                	ld	ra,8(sp)
    80001b32:	6402                	ld	s0,0(sp)
    80001b34:	0141                	addi	sp,sp,16
    80001b36:	8082                	ret
		first = 0;
    80001b38:	00007797          	auipc	a5,0x7
    80001b3c:	e807a423          	sw	zero,-376(a5) # 800089c0 <first.2459>
		fsinit(ROOTDEV);
    80001b40:	4505                	li	a0,1
    80001b42:	00002097          	auipc	ra,0x2
    80001b46:	00a080e7          	jalr	10(ra) # 80003b4c <fsinit>
    80001b4a:	bff9                	j	80001b28 <forkret+0x24>

0000000080001b4c <allocpid>:
{
    80001b4c:	1101                	addi	sp,sp,-32
    80001b4e:	ec06                	sd	ra,24(sp)
    80001b50:	e822                	sd	s0,16(sp)
    80001b52:	e426                	sd	s1,8(sp)
    80001b54:	e04a                	sd	s2,0(sp)
    80001b56:	1000                	addi	s0,sp,32
	acquire(&pid_lock);
    80001b58:	0000f917          	auipc	s2,0xf
    80001b5c:	34890913          	addi	s2,s2,840 # 80010ea0 <pid_lock>
    80001b60:	854a                	mv	a0,s2
    80001b62:	fffff097          	auipc	ra,0xfffff
    80001b66:	088080e7          	jalr	136(ra) # 80000bea <acquire>
	pid = nextpid;
    80001b6a:	00007797          	auipc	a5,0x7
    80001b6e:	e5a78793          	addi	a5,a5,-422 # 800089c4 <nextpid>
    80001b72:	4384                	lw	s1,0(a5)
	nextpid = nextpid + 1;
    80001b74:	0014871b          	addiw	a4,s1,1
    80001b78:	c398                	sw	a4,0(a5)
	release(&pid_lock);
    80001b7a:	854a                	mv	a0,s2
    80001b7c:	fffff097          	auipc	ra,0xfffff
    80001b80:	122080e7          	jalr	290(ra) # 80000c9e <release>
}
    80001b84:	8526                	mv	a0,s1
    80001b86:	60e2                	ld	ra,24(sp)
    80001b88:	6442                	ld	s0,16(sp)
    80001b8a:	64a2                	ld	s1,8(sp)
    80001b8c:	6902                	ld	s2,0(sp)
    80001b8e:	6105                	addi	sp,sp,32
    80001b90:	8082                	ret

0000000080001b92 <proc_pagetable>:
{
    80001b92:	1101                	addi	sp,sp,-32
    80001b94:	ec06                	sd	ra,24(sp)
    80001b96:	e822                	sd	s0,16(sp)
    80001b98:	e426                	sd	s1,8(sp)
    80001b9a:	e04a                	sd	s2,0(sp)
    80001b9c:	1000                	addi	s0,sp,32
    80001b9e:	892a                	mv	s2,a0
	pagetable = uvmcreate();
    80001ba0:	fffff097          	auipc	ra,0xfffff
    80001ba4:	7a4080e7          	jalr	1956(ra) # 80001344 <uvmcreate>
    80001ba8:	84aa                	mv	s1,a0
	if (pagetable == 0)
    80001baa:	c121                	beqz	a0,80001bea <proc_pagetable+0x58>
	if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001bac:	4729                	li	a4,10
    80001bae:	00005697          	auipc	a3,0x5
    80001bb2:	45268693          	addi	a3,a3,1106 # 80007000 <_trampoline>
    80001bb6:	6605                	lui	a2,0x1
    80001bb8:	040005b7          	lui	a1,0x4000
    80001bbc:	15fd                	addi	a1,a1,-1
    80001bbe:	05b2                	slli	a1,a1,0xc
    80001bc0:	fffff097          	auipc	ra,0xfffff
    80001bc4:	4fa080e7          	jalr	1274(ra) # 800010ba <mappages>
    80001bc8:	02054863          	bltz	a0,80001bf8 <proc_pagetable+0x66>
	if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001bcc:	4719                	li	a4,6
    80001bce:	06093683          	ld	a3,96(s2)
    80001bd2:	6605                	lui	a2,0x1
    80001bd4:	020005b7          	lui	a1,0x2000
    80001bd8:	15fd                	addi	a1,a1,-1
    80001bda:	05b6                	slli	a1,a1,0xd
    80001bdc:	8526                	mv	a0,s1
    80001bde:	fffff097          	auipc	ra,0xfffff
    80001be2:	4dc080e7          	jalr	1244(ra) # 800010ba <mappages>
    80001be6:	02054163          	bltz	a0,80001c08 <proc_pagetable+0x76>
}
    80001bea:	8526                	mv	a0,s1
    80001bec:	60e2                	ld	ra,24(sp)
    80001bee:	6442                	ld	s0,16(sp)
    80001bf0:	64a2                	ld	s1,8(sp)
    80001bf2:	6902                	ld	s2,0(sp)
    80001bf4:	6105                	addi	sp,sp,32
    80001bf6:	8082                	ret
		uvmfree(pagetable, 0);
    80001bf8:	4581                	li	a1,0
    80001bfa:	8526                	mv	a0,s1
    80001bfc:	00000097          	auipc	ra,0x0
    80001c00:	94c080e7          	jalr	-1716(ra) # 80001548 <uvmfree>
		return 0;
    80001c04:	4481                	li	s1,0
    80001c06:	b7d5                	j	80001bea <proc_pagetable+0x58>
		uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c08:	4681                	li	a3,0
    80001c0a:	4605                	li	a2,1
    80001c0c:	040005b7          	lui	a1,0x4000
    80001c10:	15fd                	addi	a1,a1,-1
    80001c12:	05b2                	slli	a1,a1,0xc
    80001c14:	8526                	mv	a0,s1
    80001c16:	fffff097          	auipc	ra,0xfffff
    80001c1a:	66a080e7          	jalr	1642(ra) # 80001280 <uvmunmap>
		uvmfree(pagetable, 0);
    80001c1e:	4581                	li	a1,0
    80001c20:	8526                	mv	a0,s1
    80001c22:	00000097          	auipc	ra,0x0
    80001c26:	926080e7          	jalr	-1754(ra) # 80001548 <uvmfree>
		return 0;
    80001c2a:	4481                	li	s1,0
    80001c2c:	bf7d                	j	80001bea <proc_pagetable+0x58>

0000000080001c2e <proc_freepagetable>:
{
    80001c2e:	1101                	addi	sp,sp,-32
    80001c30:	ec06                	sd	ra,24(sp)
    80001c32:	e822                	sd	s0,16(sp)
    80001c34:	e426                	sd	s1,8(sp)
    80001c36:	e04a                	sd	s2,0(sp)
    80001c38:	1000                	addi	s0,sp,32
    80001c3a:	84aa                	mv	s1,a0
    80001c3c:	892e                	mv	s2,a1
	uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c3e:	4681                	li	a3,0
    80001c40:	4605                	li	a2,1
    80001c42:	040005b7          	lui	a1,0x4000
    80001c46:	15fd                	addi	a1,a1,-1
    80001c48:	05b2                	slli	a1,a1,0xc
    80001c4a:	fffff097          	auipc	ra,0xfffff
    80001c4e:	636080e7          	jalr	1590(ra) # 80001280 <uvmunmap>
	uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001c52:	4681                	li	a3,0
    80001c54:	4605                	li	a2,1
    80001c56:	020005b7          	lui	a1,0x2000
    80001c5a:	15fd                	addi	a1,a1,-1
    80001c5c:	05b6                	slli	a1,a1,0xd
    80001c5e:	8526                	mv	a0,s1
    80001c60:	fffff097          	auipc	ra,0xfffff
    80001c64:	620080e7          	jalr	1568(ra) # 80001280 <uvmunmap>
	uvmfree(pagetable, sz);
    80001c68:	85ca                	mv	a1,s2
    80001c6a:	8526                	mv	a0,s1
    80001c6c:	00000097          	auipc	ra,0x0
    80001c70:	8dc080e7          	jalr	-1828(ra) # 80001548 <uvmfree>
}
    80001c74:	60e2                	ld	ra,24(sp)
    80001c76:	6442                	ld	s0,16(sp)
    80001c78:	64a2                	ld	s1,8(sp)
    80001c7a:	6902                	ld	s2,0(sp)
    80001c7c:	6105                	addi	sp,sp,32
    80001c7e:	8082                	ret

0000000080001c80 <freeproc>:
{
    80001c80:	1101                	addi	sp,sp,-32
    80001c82:	ec06                	sd	ra,24(sp)
    80001c84:	e822                	sd	s0,16(sp)
    80001c86:	e426                	sd	s1,8(sp)
    80001c88:	1000                	addi	s0,sp,32
    80001c8a:	84aa                	mv	s1,a0
	if (p->trapframe)
    80001c8c:	7128                	ld	a0,96(a0)
    80001c8e:	c509                	beqz	a0,80001c98 <freeproc+0x18>
		kfree((void *)p->trapframe);
    80001c90:	fffff097          	auipc	ra,0xfffff
    80001c94:	d6e080e7          	jalr	-658(ra) # 800009fe <kfree>
	p->trapframe = 0;
    80001c98:	0604b023          	sd	zero,96(s1)
	if (p->pagetable)
    80001c9c:	6ca8                	ld	a0,88(s1)
    80001c9e:	c511                	beqz	a0,80001caa <freeproc+0x2a>
		proc_freepagetable(p->pagetable, p->sz);
    80001ca0:	68ac                	ld	a1,80(s1)
    80001ca2:	00000097          	auipc	ra,0x0
    80001ca6:	f8c080e7          	jalr	-116(ra) # 80001c2e <proc_freepagetable>
	p->pagetable = 0;
    80001caa:	0404bc23          	sd	zero,88(s1)
	p->sz = 0;
    80001cae:	0404b823          	sd	zero,80(s1)
	p->pid = 0;
    80001cb2:	0204ac23          	sw	zero,56(s1)
	p->parent = 0;
    80001cb6:	0404b023          	sd	zero,64(s1)
	p->name[0] = 0;
    80001cba:	16048023          	sb	zero,352(s1)
	p->chan = 0;
    80001cbe:	0204b423          	sd	zero,40(s1)
	p->killed = 0;
    80001cc2:	0204a823          	sw	zero,48(s1)
	p->xstate = 0;
    80001cc6:	0204aa23          	sw	zero,52(s1)
	p->state = UNUSED;
    80001cca:	0204a023          	sw	zero,32(s1)
}
    80001cce:	60e2                	ld	ra,24(sp)
    80001cd0:	6442                	ld	s0,16(sp)
    80001cd2:	64a2                	ld	s1,8(sp)
    80001cd4:	6105                	addi	sp,sp,32
    80001cd6:	8082                	ret

0000000080001cd8 <allocproc>:
{
    80001cd8:	7179                	addi	sp,sp,-48
    80001cda:	f406                	sd	ra,40(sp)
    80001cdc:	f022                	sd	s0,32(sp)
    80001cde:	ec26                	sd	s1,24(sp)
    80001ce0:	e84a                	sd	s2,16(sp)
    80001ce2:	e44e                	sd	s3,8(sp)
    80001ce4:	1800                	addi	s0,sp,48
	for (p = proc; p < &proc[NPROC]; p++)
    80001ce6:	0000f497          	auipc	s1,0xf
    80001cea:	5ea48493          	addi	s1,s1,1514 # 800112d0 <proc>
    80001cee:	00017997          	auipc	s3,0x17
    80001cf2:	1e298993          	addi	s3,s3,482 # 80018ed0 <tickslock>
		acquire(&p->lock);
    80001cf6:	00848913          	addi	s2,s1,8
    80001cfa:	854a                	mv	a0,s2
    80001cfc:	fffff097          	auipc	ra,0xfffff
    80001d00:	eee080e7          	jalr	-274(ra) # 80000bea <acquire>
		if (p->state == UNUSED)
    80001d04:	509c                	lw	a5,32(s1)
    80001d06:	cf81                	beqz	a5,80001d1e <allocproc+0x46>
			release(&p->lock);
    80001d08:	854a                	mv	a0,s2
    80001d0a:	fffff097          	auipc	ra,0xfffff
    80001d0e:	f94080e7          	jalr	-108(ra) # 80000c9e <release>
	for (p = proc; p < &proc[NPROC]; p++)
    80001d12:	1f048493          	addi	s1,s1,496
    80001d16:	ff3490e3          	bne	s1,s3,80001cf6 <allocproc+0x1e>
	return 0;
    80001d1a:	4481                	li	s1,0
    80001d1c:	a051                	j	80001da0 <allocproc+0xc8>
	p->pid = allocpid();
    80001d1e:	00000097          	auipc	ra,0x0
    80001d22:	e2e080e7          	jalr	-466(ra) # 80001b4c <allocpid>
    80001d26:	dc88                	sw	a0,56(s1)
	p->state = USED;
    80001d28:	4785                	li	a5,1
    80001d2a:	d09c                	sw	a5,32(s1)
	if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001d2c:	fffff097          	auipc	ra,0xfffff
    80001d30:	dce080e7          	jalr	-562(ra) # 80000afa <kalloc>
    80001d34:	89aa                	mv	s3,a0
    80001d36:	f0a8                	sd	a0,96(s1)
    80001d38:	cd25                	beqz	a0,80001db0 <allocproc+0xd8>
	p->pagetable = proc_pagetable(p);
    80001d3a:	8526                	mv	a0,s1
    80001d3c:	00000097          	auipc	ra,0x0
    80001d40:	e56080e7          	jalr	-426(ra) # 80001b92 <proc_pagetable>
    80001d44:	89aa                	mv	s3,a0
    80001d46:	eca8                	sd	a0,88(s1)
	if (p->pagetable == 0)
    80001d48:	c141                	beqz	a0,80001dc8 <allocproc+0xf0>
	memset(&p->context, 0, sizeof(p->context));
    80001d4a:	07000613          	li	a2,112
    80001d4e:	4581                	li	a1,0
    80001d50:	06848513          	addi	a0,s1,104
    80001d54:	fffff097          	auipc	ra,0xfffff
    80001d58:	f92080e7          	jalr	-110(ra) # 80000ce6 <memset>
	p->context.ra = (uint64)forkret;
    80001d5c:	00000797          	auipc	a5,0x0
    80001d60:	da878793          	addi	a5,a5,-600 # 80001b04 <forkret>
    80001d64:	f4bc                	sd	a5,104(s1)
	p->context.sp = p->kstack + PGSIZE;
    80001d66:	64bc                	ld	a5,72(s1)
    80001d68:	6705                	lui	a4,0x1
    80001d6a:	97ba                	add	a5,a5,a4
    80001d6c:	f8bc                	sd	a5,112(s1)
	p->creationTime = ticks;
    80001d6e:	00007797          	auipc	a5,0x7
    80001d72:	ec27a783          	lw	a5,-318(a5) # 80008c30 <ticks>
    80001d76:	18f4ac23          	sw	a5,408(s1)
	p->sprior = 60;
    80001d7a:	03c00793          	li	a5,60
    80001d7e:	1af4ac23          	sw	a5,440(s1)
	p->niceness = 5;
    80001d82:	4795                	li	a5,5
    80001d84:	1cf4a023          	sw	a5,448(s1)
	p->runTime = 0;
    80001d88:	1804ae23          	sw	zero,412(s1)
	p->endTime = 0;
    80001d8c:	1a04a023          	sw	zero,416(s1)
	p->runTimePrev = 0;
    80001d90:	1a04a823          	sw	zero,432(s1)
	p->sleepTimePrev = 0;
    80001d94:	1a04a423          	sw	zero,424(s1)
	p->sleepStartTime = 0;
    80001d98:	1a04a623          	sw	zero,428(s1)
	p->sigticks=0;
    80001d9c:	1804a223          	sw	zero,388(s1)
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
    80001db6:	ece080e7          	jalr	-306(ra) # 80001c80 <freeproc>
		release(&p->lock);
    80001dba:	854a                	mv	a0,s2
    80001dbc:	fffff097          	auipc	ra,0xfffff
    80001dc0:	ee2080e7          	jalr	-286(ra) # 80000c9e <release>
		return 0;
    80001dc4:	84ce                	mv	s1,s3
    80001dc6:	bfe9                	j	80001da0 <allocproc+0xc8>
		freeproc(p);
    80001dc8:	8526                	mv	a0,s1
    80001dca:	00000097          	auipc	ra,0x0
    80001dce:	eb6080e7          	jalr	-330(ra) # 80001c80 <freeproc>
		release(&p->lock);
    80001dd2:	854a                	mv	a0,s2
    80001dd4:	fffff097          	auipc	ra,0xfffff
    80001dd8:	eca080e7          	jalr	-310(ra) # 80000c9e <release>
		return 0;
    80001ddc:	84ce                	mv	s1,s3
    80001dde:	b7c9                	j	80001da0 <allocproc+0xc8>

0000000080001de0 <userinit>:
{
    80001de0:	1101                	addi	sp,sp,-32
    80001de2:	ec06                	sd	ra,24(sp)
    80001de4:	e822                	sd	s0,16(sp)
    80001de6:	e426                	sd	s1,8(sp)
    80001de8:	1000                	addi	s0,sp,32
	p = allocproc();
    80001dea:	00000097          	auipc	ra,0x0
    80001dee:	eee080e7          	jalr	-274(ra) # 80001cd8 <allocproc>
    80001df2:	84aa                	mv	s1,a0
	initproc = p;
    80001df4:	00007797          	auipc	a5,0x7
    80001df8:	e2a7ba23          	sd	a0,-460(a5) # 80008c28 <initproc>
	uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001dfc:	03400613          	li	a2,52
    80001e00:	00007597          	auipc	a1,0x7
    80001e04:	bd058593          	addi	a1,a1,-1072 # 800089d0 <initcode>
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
    80001e42:	730080e7          	jalr	1840(ra) # 8000456e <namei>
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
    80001e76:	c5a080e7          	jalr	-934(ra) # 80001acc <myproc>
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
    80001ed6:	bfa080e7          	jalr	-1030(ra) # 80001acc <myproc>
    80001eda:	892a                	mv	s2,a0
	if ((np = allocproc()) == 0)
    80001edc:	00000097          	auipc	ra,0x0
    80001ee0:	dfc080e7          	jalr	-516(ra) # 80001cd8 <allocproc>
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
    80001f56:	d2e080e7          	jalr	-722(ra) # 80001c80 <freeproc>
		release(&np->lock);
    80001f5a:	00898513          	addi	a0,s3,8
    80001f5e:	fffff097          	auipc	ra,0xfffff
    80001f62:	d40080e7          	jalr	-704(ra) # 80000c9e <release>
		return -1;
    80001f66:	5afd                	li	s5,-1
    80001f68:	a079                	j	80001ff6 <fork+0x136>
			np->ofile[i] = filedup(p->ofile[i]);
    80001f6a:	00003097          	auipc	ra,0x3
    80001f6e:	c9a080e7          	jalr	-870(ra) # 80004c04 <filedup>
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
    80001f90:	dfe080e7          	jalr	-514(ra) # 80003d8a <idup>
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
    80001fc0:	efca0a13          	addi	s4,s4,-260 # 80010eb8 <wait_lock>
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
    80002022:	2ba48493          	addi	s1,s1,698 # 800112d8 <proc+0x8>
    80002026:	00017a17          	auipc	s4,0x17
    8000202a:	eb2a0a13          	addi	s4,s4,-334 # 80018ed8 <tickslock+0x8>
		if(pr->state==4)
    8000202e:	4991                	li	s3,4
    80002030:	a811                	j	80002044 <upd_time+0x36>
		release(&pr->lock);
    80002032:	854a                	mv	a0,s2
    80002034:	fffff097          	auipc	ra,0xfffff
    80002038:	c6a080e7          	jalr	-918(ra) # 80000c9e <release>
	while (pr < &proc[NPROC])
    8000203c:	1f048493          	addi	s1,s1,496
    80002040:	03448663          	beq	s1,s4,8000206c <upd_time+0x5e>
		acquire(&pr->lock);
    80002044:	8926                	mv	s2,s1
    80002046:	8526                	mv	a0,s1
    80002048:	fffff097          	auipc	ra,0xfffff
    8000204c:	ba2080e7          	jalr	-1118(ra) # 80000bea <acquire>
		if(pr->state==4)
    80002050:	4c9c                	lw	a5,24(s1)
    80002052:	ff3790e3          	bne	a5,s3,80002032 <upd_time+0x24>
			pr->runTime++;
    80002056:	1944a783          	lw	a5,404(s1)
    8000205a:	2785                	addiw	a5,a5,1
    8000205c:	18f4aa23          	sw	a5,404(s1)
			pr->runTimePrev++;
    80002060:	1a84a783          	lw	a5,424(s1)
    80002064:	2785                	addiw	a5,a5,1
    80002066:	1af4a423          	sw	a5,424(s1)
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
    8000209e:	e0670713          	addi	a4,a4,-506 # 80010ea0 <pid_lock>
    800020a2:	975a                	add	a4,a4,s6
    800020a4:	02073823          	sd	zero,48(a4)
				swtch(&c->context, &p->context);
    800020a8:	0000f717          	auipc	a4,0xf
    800020ac:	e3070713          	addi	a4,a4,-464 # 80010ed8 <cpus+0x8>
    800020b0:	9b3a                	add	s6,s6,a4
			if (p->state == RUNNABLE)
    800020b2:	4a0d                	li	s4,3
				p->state = RUNNING;
    800020b4:	4b91                	li	s7,4
				c->proc = p;
    800020b6:	079e                	slli	a5,a5,0x7
    800020b8:	0000fa97          	auipc	s5,0xf
    800020bc:	de8a8a93          	addi	s5,s5,-536 # 80010ea0 <pid_lock>
    800020c0:	9abe                	add	s5,s5,a5
		for (p = proc; p < &proc[NPROC]; p++)
    800020c2:	00017997          	auipc	s3,0x17
    800020c6:	e0e98993          	addi	s3,s3,-498 # 80018ed0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020ca:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800020ce:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800020d2:	10079073          	csrw	sstatus,a5
    800020d6:	0000f497          	auipc	s1,0xf
    800020da:	1fa48493          	addi	s1,s1,506 # 800112d0 <proc>
    800020de:	a03d                	j	8000210c <scheduler+0x90>
				p->state = RUNNING;
    800020e0:	0374a023          	sw	s7,32(s1)
				c->proc = p;
    800020e4:	029ab823          	sd	s1,48(s5)
				swtch(&c->context, &p->context);
    800020e8:	06848593          	addi	a1,s1,104
    800020ec:	855a                	mv	a0,s6
    800020ee:	00001097          	auipc	ra,0x1
    800020f2:	89c080e7          	jalr	-1892(ra) # 8000298a <swtch>
				c->proc = 0;
    800020f6:	020ab823          	sd	zero,48(s5)
			release(&p->lock);
    800020fa:	854a                	mv	a0,s2
    800020fc:	fffff097          	auipc	ra,0xfffff
    80002100:	ba2080e7          	jalr	-1118(ra) # 80000c9e <release>
		for (p = proc; p < &proc[NPROC]; p++)
    80002104:	1f048493          	addi	s1,s1,496
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
    80002134:	99c080e7          	jalr	-1636(ra) # 80001acc <myproc>
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
    80002150:	d5470713          	addi	a4,a4,-684 # 80010ea0 <pid_lock>
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
    80002176:	d2e90913          	addi	s2,s2,-722 # 80010ea0 <pid_lock>
    8000217a:	2781                	sext.w	a5,a5
    8000217c:	079e                	slli	a5,a5,0x7
    8000217e:	97ca                	add	a5,a5,s2
    80002180:	0ac7a983          	lw	s3,172(a5)
    80002184:	8792                	mv	a5,tp
	swtch(&p->context, &mycpu()->context);
    80002186:	2781                	sext.w	a5,a5
    80002188:	079e                	slli	a5,a5,0x7
    8000218a:	0000f597          	auipc	a1,0xf
    8000218e:	d4e58593          	addi	a1,a1,-690 # 80010ed8 <cpus+0x8>
    80002192:	95be                	add	a1,a1,a5
    80002194:	06848513          	addi	a0,s1,104
    80002198:	00000097          	auipc	ra,0x0
    8000219c:	7f2080e7          	jalr	2034(ra) # 8000298a <swtch>
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
    8000220a:	8c6080e7          	jalr	-1850(ra) # 80001acc <myproc>
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
    80002258:	878080e7          	jalr	-1928(ra) # 80001acc <myproc>
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
    800022d6:	7fa080e7          	jalr	2042(ra) # 80001acc <myproc>
    800022da:	892a                	mv	s2,a0
	acquire(&wait_lock);
    800022dc:	0000f517          	auipc	a0,0xf
    800022e0:	bdc50513          	addi	a0,a0,-1060 # 80010eb8 <wait_lock>
    800022e4:	fffff097          	auipc	ra,0xfffff
    800022e8:	906080e7          	jalr	-1786(ra) # 80000bea <acquire>
		havekids = 0;
    800022ec:	4c81                	li	s9,0
				if (np->state == ZOMBIE)
    800022ee:	4a15                	li	s4,5
		for (np = proc; np < &proc[NPROC]; np++)
    800022f0:	00017997          	auipc	s3,0x17
    800022f4:	be098993          	addi	s3,s3,-1056 # 80018ed0 <tickslock>
				havekids = 1;
    800022f8:	4a85                	li	s5,1
		sleep(p, &wait_lock); // DOC: wait-sleep
    800022fa:	0000fd17          	auipc	s10,0xf
    800022fe:	bbed0d13          	addi	s10,s10,-1090 # 80010eb8 <wait_lock>
		havekids = 0;
    80002302:	8766                	mv	a4,s9
		for (np = proc; np < &proc[NPROC]; np++)
    80002304:	0000f497          	auipc	s1,0xf
    80002308:	fcc48493          	addi	s1,s1,-52 # 800112d0 <proc>
    8000230c:	a059                	j	80002392 <waitx+0xe4>
					pid = np->pid;
    8000230e:	0384a983          	lw	s3,56(s1)
					*rtime = np->runTime;
    80002312:	19c4a703          	lw	a4,412(s1)
    80002316:	00ec2023          	sw	a4,0(s8)
					*wtime = np->endTime - np->creationTime - np->runTime;
    8000231a:	1984a783          	lw	a5,408(s1)
    8000231e:	9f3d                	addw	a4,a4,a5
    80002320:	1a04a783          	lw	a5,416(s1)
    80002324:	9f99                	subw	a5,a5,a4
    80002326:	00fba023          	sw	a5,0(s7) # fffffffffffff000 <end+0xffffffff7ffdad50>
					if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000232a:	000b0e63          	beqz	s6,80002346 <waitx+0x98>
    8000232e:	4691                	li	a3,4
    80002330:	03448613          	addi	a2,s1,52
    80002334:	85da                	mv	a1,s6
    80002336:	05893503          	ld	a0,88(s2)
    8000233a:	fffff097          	auipc	ra,0xfffff
    8000233e:	34a080e7          	jalr	842(ra) # 80001684 <copyout>
    80002342:	02054563          	bltz	a0,8000236c <waitx+0xbe>
					freeproc(np);
    80002346:	8526                	mv	a0,s1
    80002348:	00000097          	auipc	ra,0x0
    8000234c:	938080e7          	jalr	-1736(ra) # 80001c80 <freeproc>
					release(&np->lock);
    80002350:	856e                	mv	a0,s11
    80002352:	fffff097          	auipc	ra,0xfffff
    80002356:	94c080e7          	jalr	-1716(ra) # 80000c9e <release>
					release(&wait_lock);
    8000235a:	0000f517          	auipc	a0,0xf
    8000235e:	b5e50513          	addi	a0,a0,-1186 # 80010eb8 <wait_lock>
    80002362:	fffff097          	auipc	ra,0xfffff
    80002366:	93c080e7          	jalr	-1732(ra) # 80000c9e <release>
					return pid;
    8000236a:	a0ad                	j	800023d4 <waitx+0x126>
						release(&np->lock);
    8000236c:	856e                	mv	a0,s11
    8000236e:	fffff097          	auipc	ra,0xfffff
    80002372:	930080e7          	jalr	-1744(ra) # 80000c9e <release>
						release(&wait_lock);
    80002376:	0000f517          	auipc	a0,0xf
    8000237a:	b4250513          	addi	a0,a0,-1214 # 80010eb8 <wait_lock>
    8000237e:	fffff097          	auipc	ra,0xfffff
    80002382:	920080e7          	jalr	-1760(ra) # 80000c9e <release>
						return -1;
    80002386:	59fd                	li	s3,-1
    80002388:	a0b1                	j	800023d4 <waitx+0x126>
		for (np = proc; np < &proc[NPROC]; np++)
    8000238a:	1f048493          	addi	s1,s1,496
    8000238e:	03348663          	beq	s1,s3,800023ba <waitx+0x10c>
			if (np->parent == p)
    80002392:	60bc                	ld	a5,64(s1)
    80002394:	ff279be3          	bne	a5,s2,8000238a <waitx+0xdc>
				acquire(&np->lock);
    80002398:	00848d93          	addi	s11,s1,8
    8000239c:	856e                	mv	a0,s11
    8000239e:	fffff097          	auipc	ra,0xfffff
    800023a2:	84c080e7          	jalr	-1972(ra) # 80000bea <acquire>
				if (np->state == ZOMBIE)
    800023a6:	509c                	lw	a5,32(s1)
    800023a8:	f74783e3          	beq	a5,s4,8000230e <waitx+0x60>
				release(&np->lock);
    800023ac:	856e                	mv	a0,s11
    800023ae:	fffff097          	auipc	ra,0xfffff
    800023b2:	8f0080e7          	jalr	-1808(ra) # 80000c9e <release>
				havekids = 1;
    800023b6:	8756                	mv	a4,s5
    800023b8:	bfc9                	j	8000238a <waitx+0xdc>
		if (!havekids || p->killed)
    800023ba:	c701                	beqz	a4,800023c2 <waitx+0x114>
    800023bc:	03092783          	lw	a5,48(s2)
    800023c0:	cb95                	beqz	a5,800023f4 <waitx+0x146>
			release(&wait_lock);
    800023c2:	0000f517          	auipc	a0,0xf
    800023c6:	af650513          	addi	a0,a0,-1290 # 80010eb8 <wait_lock>
    800023ca:	fffff097          	auipc	ra,0xfffff
    800023ce:	8d4080e7          	jalr	-1836(ra) # 80000c9e <release>
			return -1;
    800023d2:	59fd                	li	s3,-1
}
    800023d4:	854e                	mv	a0,s3
    800023d6:	70a6                	ld	ra,104(sp)
    800023d8:	7406                	ld	s0,96(sp)
    800023da:	64e6                	ld	s1,88(sp)
    800023dc:	6946                	ld	s2,80(sp)
    800023de:	69a6                	ld	s3,72(sp)
    800023e0:	6a06                	ld	s4,64(sp)
    800023e2:	7ae2                	ld	s5,56(sp)
    800023e4:	7b42                	ld	s6,48(sp)
    800023e6:	7ba2                	ld	s7,40(sp)
    800023e8:	7c02                	ld	s8,32(sp)
    800023ea:	6ce2                	ld	s9,24(sp)
    800023ec:	6d42                	ld	s10,16(sp)
    800023ee:	6da2                	ld	s11,8(sp)
    800023f0:	6165                	addi	sp,sp,112
    800023f2:	8082                	ret
		sleep(p, &wait_lock); // DOC: wait-sleep
    800023f4:	85ea                	mv	a1,s10
    800023f6:	854a                	mv	a0,s2
    800023f8:	00000097          	auipc	ra,0x0
    800023fc:	e48080e7          	jalr	-440(ra) # 80002240 <sleep>
		havekids = 0;
    80002400:	b709                	j	80002302 <waitx+0x54>

0000000080002402 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    80002402:	715d                	addi	sp,sp,-80
    80002404:	e486                	sd	ra,72(sp)
    80002406:	e0a2                	sd	s0,64(sp)
    80002408:	fc26                	sd	s1,56(sp)
    8000240a:	f84a                	sd	s2,48(sp)
    8000240c:	f44e                	sd	s3,40(sp)
    8000240e:	f052                	sd	s4,32(sp)
    80002410:	ec56                	sd	s5,24(sp)
    80002412:	e85a                	sd	s6,16(sp)
    80002414:	e45e                	sd	s7,8(sp)
    80002416:	0880                	addi	s0,sp,80
    80002418:	8aaa                	mv	s5,a0
	struct proc *p;

	for (p = proc; p < &proc[NPROC]; p++)
    8000241a:	0000f497          	auipc	s1,0xf
    8000241e:	eb648493          	addi	s1,s1,-330 # 800112d0 <proc>
	{
		if (p != myproc())
		{
			acquire(&p->lock);
			if (p->state == SLEEPING && p->chan == chan)
    80002422:	4a09                	li	s4,2
			{
				p->state = RUNNABLE;
    80002424:	4b0d                	li	s6,3
				p->time_spent = 0;
#endif
				// #ifdef PBS
				if (p->sleepStartTime != 0)
				{
					p->sleepTimePrev = ticks - p->sleepStartTime;
    80002426:	00007b97          	auipc	s7,0x7
    8000242a:	80ab8b93          	addi	s7,s7,-2038 # 80008c30 <ticks>
	for (p = proc; p < &proc[NPROC]; p++)
    8000242e:	00017997          	auipc	s3,0x17
    80002432:	aa298993          	addi	s3,s3,-1374 # 80018ed0 <tickslock>
    80002436:	a811                	j	8000244a <wakeup+0x48>
				int slices[5] = {1, 2, 4, 8, 16};
				p->time_slice = slices[p->curr_queue];
				push(&mlfq[p->curr_queue], p);
#endif
			}
			release(&p->lock);
    80002438:	854a                	mv	a0,s2
    8000243a:	fffff097          	auipc	ra,0xfffff
    8000243e:	864080e7          	jalr	-1948(ra) # 80000c9e <release>
	for (p = proc; p < &proc[NPROC]; p++)
    80002442:	1f048493          	addi	s1,s1,496
    80002446:	05348663          	beq	s1,s3,80002492 <wakeup+0x90>
		if (p != myproc())
    8000244a:	fffff097          	auipc	ra,0xfffff
    8000244e:	682080e7          	jalr	1666(ra) # 80001acc <myproc>
    80002452:	fea488e3          	beq	s1,a0,80002442 <wakeup+0x40>
			acquire(&p->lock);
    80002456:	00848913          	addi	s2,s1,8
    8000245a:	854a                	mv	a0,s2
    8000245c:	ffffe097          	auipc	ra,0xffffe
    80002460:	78e080e7          	jalr	1934(ra) # 80000bea <acquire>
			if (p->state == SLEEPING && p->chan == chan)
    80002464:	509c                	lw	a5,32(s1)
    80002466:	fd4799e3          	bne	a5,s4,80002438 <wakeup+0x36>
    8000246a:	749c                	ld	a5,40(s1)
    8000246c:	fd5796e3          	bne	a5,s5,80002438 <wakeup+0x36>
				p->state = RUNNABLE;
    80002470:	0364a023          	sw	s6,32(s1)
				if (p->sleepStartTime != 0)
    80002474:	1ac4a783          	lw	a5,428(s1)
    80002478:	d3e1                	beqz	a5,80002438 <wakeup+0x36>
					p->sleepTimePrev = ticks - p->sleepStartTime;
    8000247a:	000ba703          	lw	a4,0(s7)
    8000247e:	40f707bb          	subw	a5,a4,a5
    80002482:	1af4a423          	sw	a5,424(s1)
					p->totalSleep += p->sleepTimePrev;
    80002486:	1a44a703          	lw	a4,420(s1)
    8000248a:	9fb9                	addw	a5,a5,a4
    8000248c:	1af4a223          	sw	a5,420(s1)
    80002490:	b765                	j	80002438 <wakeup+0x36>
		}
	}
}
    80002492:	60a6                	ld	ra,72(sp)
    80002494:	6406                	ld	s0,64(sp)
    80002496:	74e2                	ld	s1,56(sp)
    80002498:	7942                	ld	s2,48(sp)
    8000249a:	79a2                	ld	s3,40(sp)
    8000249c:	7a02                	ld	s4,32(sp)
    8000249e:	6ae2                	ld	s5,24(sp)
    800024a0:	6b42                	ld	s6,16(sp)
    800024a2:	6ba2                	ld	s7,8(sp)
    800024a4:	6161                	addi	sp,sp,80
    800024a6:	8082                	ret

00000000800024a8 <reparent>:
{
    800024a8:	7179                	addi	sp,sp,-48
    800024aa:	f406                	sd	ra,40(sp)
    800024ac:	f022                	sd	s0,32(sp)
    800024ae:	ec26                	sd	s1,24(sp)
    800024b0:	e84a                	sd	s2,16(sp)
    800024b2:	e44e                	sd	s3,8(sp)
    800024b4:	e052                	sd	s4,0(sp)
    800024b6:	1800                	addi	s0,sp,48
    800024b8:	892a                	mv	s2,a0
	for (pp = proc; pp < &proc[NPROC]; pp++)
    800024ba:	0000f497          	auipc	s1,0xf
    800024be:	e1648493          	addi	s1,s1,-490 # 800112d0 <proc>
			pp->parent = initproc;
    800024c2:	00006a17          	auipc	s4,0x6
    800024c6:	766a0a13          	addi	s4,s4,1894 # 80008c28 <initproc>
	for (pp = proc; pp < &proc[NPROC]; pp++)
    800024ca:	00017997          	auipc	s3,0x17
    800024ce:	a0698993          	addi	s3,s3,-1530 # 80018ed0 <tickslock>
    800024d2:	a029                	j	800024dc <reparent+0x34>
    800024d4:	1f048493          	addi	s1,s1,496
    800024d8:	01348d63          	beq	s1,s3,800024f2 <reparent+0x4a>
		if (pp->parent == p)
    800024dc:	60bc                	ld	a5,64(s1)
    800024de:	ff279be3          	bne	a5,s2,800024d4 <reparent+0x2c>
			pp->parent = initproc;
    800024e2:	000a3503          	ld	a0,0(s4)
    800024e6:	e0a8                	sd	a0,64(s1)
			wakeup(initproc);
    800024e8:	00000097          	auipc	ra,0x0
    800024ec:	f1a080e7          	jalr	-230(ra) # 80002402 <wakeup>
    800024f0:	b7d5                	j	800024d4 <reparent+0x2c>
}
    800024f2:	70a2                	ld	ra,40(sp)
    800024f4:	7402                	ld	s0,32(sp)
    800024f6:	64e2                	ld	s1,24(sp)
    800024f8:	6942                	ld	s2,16(sp)
    800024fa:	69a2                	ld	s3,8(sp)
    800024fc:	6a02                	ld	s4,0(sp)
    800024fe:	6145                	addi	sp,sp,48
    80002500:	8082                	ret

0000000080002502 <exit>:
{
    80002502:	7179                	addi	sp,sp,-48
    80002504:	f406                	sd	ra,40(sp)
    80002506:	f022                	sd	s0,32(sp)
    80002508:	ec26                	sd	s1,24(sp)
    8000250a:	e84a                	sd	s2,16(sp)
    8000250c:	e44e                	sd	s3,8(sp)
    8000250e:	e052                	sd	s4,0(sp)
    80002510:	1800                	addi	s0,sp,48
    80002512:	8a2a                	mv	s4,a0
	struct proc *p = myproc();
    80002514:	fffff097          	auipc	ra,0xfffff
    80002518:	5b8080e7          	jalr	1464(ra) # 80001acc <myproc>
    8000251c:	89aa                	mv	s3,a0
	if (p == initproc)
    8000251e:	00006797          	auipc	a5,0x6
    80002522:	70a7b783          	ld	a5,1802(a5) # 80008c28 <initproc>
    80002526:	0d850493          	addi	s1,a0,216
    8000252a:	15850913          	addi	s2,a0,344
    8000252e:	02a79363          	bne	a5,a0,80002554 <exit+0x52>
		panic("init exiting");
    80002532:	00006517          	auipc	a0,0x6
    80002536:	d4650513          	addi	a0,a0,-698 # 80008278 <digits+0x238>
    8000253a:	ffffe097          	auipc	ra,0xffffe
    8000253e:	00a080e7          	jalr	10(ra) # 80000544 <panic>
			fileclose(f);
    80002542:	00002097          	auipc	ra,0x2
    80002546:	714080e7          	jalr	1812(ra) # 80004c56 <fileclose>
			p->ofile[fd] = 0;
    8000254a:	0004b023          	sd	zero,0(s1)
	for (int fd = 0; fd < NOFILE; fd++)
    8000254e:	04a1                	addi	s1,s1,8
    80002550:	01248563          	beq	s1,s2,8000255a <exit+0x58>
		if (p->ofile[fd])
    80002554:	6088                	ld	a0,0(s1)
    80002556:	f575                	bnez	a0,80002542 <exit+0x40>
    80002558:	bfdd                	j	8000254e <exit+0x4c>
	begin_op();
    8000255a:	00002097          	auipc	ra,0x2
    8000255e:	230080e7          	jalr	560(ra) # 8000478a <begin_op>
	iput(p->cwd);
    80002562:	1589b503          	ld	a0,344(s3)
    80002566:	00002097          	auipc	ra,0x2
    8000256a:	a1c080e7          	jalr	-1508(ra) # 80003f82 <iput>
	end_op();
    8000256e:	00002097          	auipc	ra,0x2
    80002572:	29c080e7          	jalr	668(ra) # 8000480a <end_op>
	p->cwd = 0;
    80002576:	1409bc23          	sd	zero,344(s3)
	acquire(&wait_lock);
    8000257a:	0000f497          	auipc	s1,0xf
    8000257e:	93e48493          	addi	s1,s1,-1730 # 80010eb8 <wait_lock>
    80002582:	8526                	mv	a0,s1
    80002584:	ffffe097          	auipc	ra,0xffffe
    80002588:	666080e7          	jalr	1638(ra) # 80000bea <acquire>
	reparent(p);
    8000258c:	854e                	mv	a0,s3
    8000258e:	00000097          	auipc	ra,0x0
    80002592:	f1a080e7          	jalr	-230(ra) # 800024a8 <reparent>
	wakeup(p->parent);
    80002596:	0409b503          	ld	a0,64(s3)
    8000259a:	00000097          	auipc	ra,0x0
    8000259e:	e68080e7          	jalr	-408(ra) # 80002402 <wakeup>
	acquire(&p->lock);
    800025a2:	00898513          	addi	a0,s3,8
    800025a6:	ffffe097          	auipc	ra,0xffffe
    800025aa:	644080e7          	jalr	1604(ra) # 80000bea <acquire>
	p->xstate = status;
    800025ae:	0349aa23          	sw	s4,52(s3)
	p->state = ZOMBIE;
    800025b2:	4795                	li	a5,5
    800025b4:	02f9a023          	sw	a5,32(s3)
	p->endTime = ticks;
    800025b8:	00006797          	auipc	a5,0x6
    800025bc:	6787a783          	lw	a5,1656(a5) # 80008c30 <ticks>
    800025c0:	1af9a023          	sw	a5,416(s3)
	release(&wait_lock);
    800025c4:	8526                	mv	a0,s1
    800025c6:	ffffe097          	auipc	ra,0xffffe
    800025ca:	6d8080e7          	jalr	1752(ra) # 80000c9e <release>
	sched();
    800025ce:	00000097          	auipc	ra,0x0
    800025d2:	b54080e7          	jalr	-1196(ra) # 80002122 <sched>
	panic("zombie exit");
    800025d6:	00006517          	auipc	a0,0x6
    800025da:	cb250513          	addi	a0,a0,-846 # 80008288 <digits+0x248>
    800025de:	ffffe097          	auipc	ra,0xffffe
    800025e2:	f66080e7          	jalr	-154(ra) # 80000544 <panic>

00000000800025e6 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    800025e6:	7179                	addi	sp,sp,-48
    800025e8:	f406                	sd	ra,40(sp)
    800025ea:	f022                	sd	s0,32(sp)
    800025ec:	ec26                	sd	s1,24(sp)
    800025ee:	e84a                	sd	s2,16(sp)
    800025f0:	e44e                	sd	s3,8(sp)
    800025f2:	e052                	sd	s4,0(sp)
    800025f4:	1800                	addi	s0,sp,48
    800025f6:	89aa                	mv	s3,a0
	struct proc *p;

	for (p = proc; p < &proc[NPROC]; p++)
    800025f8:	0000f497          	auipc	s1,0xf
    800025fc:	cd848493          	addi	s1,s1,-808 # 800112d0 <proc>
    80002600:	00017a17          	auipc	s4,0x17
    80002604:	8d0a0a13          	addi	s4,s4,-1840 # 80018ed0 <tickslock>
	{
		acquire(&p->lock);
    80002608:	00848913          	addi	s2,s1,8
    8000260c:	854a                	mv	a0,s2
    8000260e:	ffffe097          	auipc	ra,0xffffe
    80002612:	5dc080e7          	jalr	1500(ra) # 80000bea <acquire>
		if (p->pid == pid)
    80002616:	5c9c                	lw	a5,56(s1)
    80002618:	01378d63          	beq	a5,s3,80002632 <kill+0x4c>
#endif
			}
			release(&p->lock);
			return 0;
		}
		release(&p->lock);
    8000261c:	854a                	mv	a0,s2
    8000261e:	ffffe097          	auipc	ra,0xffffe
    80002622:	680080e7          	jalr	1664(ra) # 80000c9e <release>
	for (p = proc; p < &proc[NPROC]; p++)
    80002626:	1f048493          	addi	s1,s1,496
    8000262a:	fd449fe3          	bne	s1,s4,80002608 <kill+0x22>
	}
	return -1;
    8000262e:	557d                	li	a0,-1
    80002630:	a829                	j	8000264a <kill+0x64>
			p->killed = 1;
    80002632:	4785                	li	a5,1
    80002634:	d89c                	sw	a5,48(s1)
			if (p->state == SLEEPING)
    80002636:	5098                	lw	a4,32(s1)
    80002638:	4789                	li	a5,2
    8000263a:	02f70063          	beq	a4,a5,8000265a <kill+0x74>
			release(&p->lock);
    8000263e:	854a                	mv	a0,s2
    80002640:	ffffe097          	auipc	ra,0xffffe
    80002644:	65e080e7          	jalr	1630(ra) # 80000c9e <release>
			return 0;
    80002648:	4501                	li	a0,0
}
    8000264a:	70a2                	ld	ra,40(sp)
    8000264c:	7402                	ld	s0,32(sp)
    8000264e:	64e2                	ld	s1,24(sp)
    80002650:	6942                	ld	s2,16(sp)
    80002652:	69a2                	ld	s3,8(sp)
    80002654:	6a02                	ld	s4,0(sp)
    80002656:	6145                	addi	sp,sp,48
    80002658:	8082                	ret
				p->sleepTimePrev = ticks - p->sleepStartTime;
    8000265a:	1ac4a703          	lw	a4,428(s1)
    8000265e:	00006797          	auipc	a5,0x6
    80002662:	5d27a783          	lw	a5,1490(a5) # 80008c30 <ticks>
    80002666:	9f99                	subw	a5,a5,a4
    80002668:	1af4a423          	sw	a5,424(s1)
				p->state = RUNNABLE;
    8000266c:	478d                	li	a5,3
    8000266e:	d09c                	sw	a5,32(s1)
    80002670:	b7f9                	j	8000263e <kill+0x58>

0000000080002672 <setkilled>:

void setkilled(struct proc *p)
{
    80002672:	1101                	addi	sp,sp,-32
    80002674:	ec06                	sd	ra,24(sp)
    80002676:	e822                	sd	s0,16(sp)
    80002678:	e426                	sd	s1,8(sp)
    8000267a:	e04a                	sd	s2,0(sp)
    8000267c:	1000                	addi	s0,sp,32
    8000267e:	84aa                	mv	s1,a0
	acquire(&p->lock);
    80002680:	00850913          	addi	s2,a0,8
    80002684:	854a                	mv	a0,s2
    80002686:	ffffe097          	auipc	ra,0xffffe
    8000268a:	564080e7          	jalr	1380(ra) # 80000bea <acquire>
	p->killed = 1;
    8000268e:	4785                	li	a5,1
    80002690:	d89c                	sw	a5,48(s1)
	release(&p->lock);
    80002692:	854a                	mv	a0,s2
    80002694:	ffffe097          	auipc	ra,0xffffe
    80002698:	60a080e7          	jalr	1546(ra) # 80000c9e <release>
}
    8000269c:	60e2                	ld	ra,24(sp)
    8000269e:	6442                	ld	s0,16(sp)
    800026a0:	64a2                	ld	s1,8(sp)
    800026a2:	6902                	ld	s2,0(sp)
    800026a4:	6105                	addi	sp,sp,32
    800026a6:	8082                	ret

00000000800026a8 <killed>:

int killed(struct proc *p)
{
    800026a8:	1101                	addi	sp,sp,-32
    800026aa:	ec06                	sd	ra,24(sp)
    800026ac:	e822                	sd	s0,16(sp)
    800026ae:	e426                	sd	s1,8(sp)
    800026b0:	e04a                	sd	s2,0(sp)
    800026b2:	1000                	addi	s0,sp,32
    800026b4:	84aa                	mv	s1,a0
	int k;

	acquire(&p->lock);
    800026b6:	00850913          	addi	s2,a0,8
    800026ba:	854a                	mv	a0,s2
    800026bc:	ffffe097          	auipc	ra,0xffffe
    800026c0:	52e080e7          	jalr	1326(ra) # 80000bea <acquire>
	k = p->killed;
    800026c4:	5884                	lw	s1,48(s1)
	release(&p->lock);
    800026c6:	854a                	mv	a0,s2
    800026c8:	ffffe097          	auipc	ra,0xffffe
    800026cc:	5d6080e7          	jalr	1494(ra) # 80000c9e <release>
	return k;
}
    800026d0:	8526                	mv	a0,s1
    800026d2:	60e2                	ld	ra,24(sp)
    800026d4:	6442                	ld	s0,16(sp)
    800026d6:	64a2                	ld	s1,8(sp)
    800026d8:	6902                	ld	s2,0(sp)
    800026da:	6105                	addi	sp,sp,32
    800026dc:	8082                	ret

00000000800026de <wait>:
{
    800026de:	711d                	addi	sp,sp,-96
    800026e0:	ec86                	sd	ra,88(sp)
    800026e2:	e8a2                	sd	s0,80(sp)
    800026e4:	e4a6                	sd	s1,72(sp)
    800026e6:	e0ca                	sd	s2,64(sp)
    800026e8:	fc4e                	sd	s3,56(sp)
    800026ea:	f852                	sd	s4,48(sp)
    800026ec:	f456                	sd	s5,40(sp)
    800026ee:	f05a                	sd	s6,32(sp)
    800026f0:	ec5e                	sd	s7,24(sp)
    800026f2:	e862                	sd	s8,16(sp)
    800026f4:	e466                	sd	s9,8(sp)
    800026f6:	1080                	addi	s0,sp,96
    800026f8:	8baa                	mv	s7,a0
	struct proc *p = myproc();
    800026fa:	fffff097          	auipc	ra,0xfffff
    800026fe:	3d2080e7          	jalr	978(ra) # 80001acc <myproc>
    80002702:	892a                	mv	s2,a0
	acquire(&wait_lock);
    80002704:	0000e517          	auipc	a0,0xe
    80002708:	7b450513          	addi	a0,a0,1972 # 80010eb8 <wait_lock>
    8000270c:	ffffe097          	auipc	ra,0xffffe
    80002710:	4de080e7          	jalr	1246(ra) # 80000bea <acquire>
		havekids = 0;
    80002714:	4c01                	li	s8,0
				if (pp->state == ZOMBIE)
    80002716:	4a95                	li	s5,5
		for (pp = proc; pp < &proc[NPROC]; pp++)
    80002718:	00016997          	auipc	s3,0x16
    8000271c:	7b898993          	addi	s3,s3,1976 # 80018ed0 <tickslock>
				havekids = 1;
    80002720:	4b05                	li	s6,1
		sleep(p, &wait_lock); // DOC: wait-sleep
    80002722:	0000ec97          	auipc	s9,0xe
    80002726:	796c8c93          	addi	s9,s9,1942 # 80010eb8 <wait_lock>
		havekids = 0;
    8000272a:	8762                	mv	a4,s8
		for (pp = proc; pp < &proc[NPROC]; pp++)
    8000272c:	0000f497          	auipc	s1,0xf
    80002730:	ba448493          	addi	s1,s1,-1116 # 800112d0 <proc>
    80002734:	a8ad                	j	800027ae <wait+0xd0>
					pid = pp->pid;
    80002736:	0384a983          	lw	s3,56(s1)
					if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000273a:	000b8e63          	beqz	s7,80002756 <wait+0x78>
    8000273e:	4691                	li	a3,4
    80002740:	03448613          	addi	a2,s1,52
    80002744:	85de                	mv	a1,s7
    80002746:	05893503          	ld	a0,88(s2)
    8000274a:	fffff097          	auipc	ra,0xfffff
    8000274e:	f3a080e7          	jalr	-198(ra) # 80001684 <copyout>
    80002752:	02054b63          	bltz	a0,80002788 <wait+0xaa>
					freeproc(pp);
    80002756:	8526                	mv	a0,s1
    80002758:	fffff097          	auipc	ra,0xfffff
    8000275c:	528080e7          	jalr	1320(ra) # 80001c80 <freeproc>
					release(&pp->lock);
    80002760:	8552                	mv	a0,s4
    80002762:	ffffe097          	auipc	ra,0xffffe
    80002766:	53c080e7          	jalr	1340(ra) # 80000c9e <release>
					release(&wait_lock);
    8000276a:	0000e517          	auipc	a0,0xe
    8000276e:	74e50513          	addi	a0,a0,1870 # 80010eb8 <wait_lock>
    80002772:	ffffe097          	auipc	ra,0xffffe
    80002776:	52c080e7          	jalr	1324(ra) # 80000c9e <release>
					pp->endTime = ticks;
    8000277a:	00006797          	auipc	a5,0x6
    8000277e:	4b67a783          	lw	a5,1206(a5) # 80008c30 <ticks>
    80002782:	1af4a023          	sw	a5,416(s1)
					return pid;
    80002786:	a885                	j	800027f6 <wait+0x118>
						release(&pp->lock);
    80002788:	8552                	mv	a0,s4
    8000278a:	ffffe097          	auipc	ra,0xffffe
    8000278e:	514080e7          	jalr	1300(ra) # 80000c9e <release>
						release(&wait_lock);
    80002792:	0000e517          	auipc	a0,0xe
    80002796:	72650513          	addi	a0,a0,1830 # 80010eb8 <wait_lock>
    8000279a:	ffffe097          	auipc	ra,0xffffe
    8000279e:	504080e7          	jalr	1284(ra) # 80000c9e <release>
						return -1;
    800027a2:	59fd                	li	s3,-1
    800027a4:	a889                	j	800027f6 <wait+0x118>
		for (pp = proc; pp < &proc[NPROC]; pp++)
    800027a6:	1f048493          	addi	s1,s1,496
    800027aa:	03348663          	beq	s1,s3,800027d6 <wait+0xf8>
			if (pp->parent == p)
    800027ae:	60bc                	ld	a5,64(s1)
    800027b0:	ff279be3          	bne	a5,s2,800027a6 <wait+0xc8>
				acquire(&pp->lock);
    800027b4:	00848a13          	addi	s4,s1,8
    800027b8:	8552                	mv	a0,s4
    800027ba:	ffffe097          	auipc	ra,0xffffe
    800027be:	430080e7          	jalr	1072(ra) # 80000bea <acquire>
				if (pp->state == ZOMBIE)
    800027c2:	509c                	lw	a5,32(s1)
    800027c4:	f75789e3          	beq	a5,s5,80002736 <wait+0x58>
				release(&pp->lock);
    800027c8:	8552                	mv	a0,s4
    800027ca:	ffffe097          	auipc	ra,0xffffe
    800027ce:	4d4080e7          	jalr	1236(ra) # 80000c9e <release>
				havekids = 1;
    800027d2:	875a                	mv	a4,s6
    800027d4:	bfc9                	j	800027a6 <wait+0xc8>
		if (!havekids || killed(p))
    800027d6:	c719                	beqz	a4,800027e4 <wait+0x106>
    800027d8:	854a                	mv	a0,s2
    800027da:	00000097          	auipc	ra,0x0
    800027de:	ece080e7          	jalr	-306(ra) # 800026a8 <killed>
    800027e2:	c905                	beqz	a0,80002812 <wait+0x134>
			release(&wait_lock);
    800027e4:	0000e517          	auipc	a0,0xe
    800027e8:	6d450513          	addi	a0,a0,1748 # 80010eb8 <wait_lock>
    800027ec:	ffffe097          	auipc	ra,0xffffe
    800027f0:	4b2080e7          	jalr	1202(ra) # 80000c9e <release>
			return -1;
    800027f4:	59fd                	li	s3,-1
}
    800027f6:	854e                	mv	a0,s3
    800027f8:	60e6                	ld	ra,88(sp)
    800027fa:	6446                	ld	s0,80(sp)
    800027fc:	64a6                	ld	s1,72(sp)
    800027fe:	6906                	ld	s2,64(sp)
    80002800:	79e2                	ld	s3,56(sp)
    80002802:	7a42                	ld	s4,48(sp)
    80002804:	7aa2                	ld	s5,40(sp)
    80002806:	7b02                	ld	s6,32(sp)
    80002808:	6be2                	ld	s7,24(sp)
    8000280a:	6c42                	ld	s8,16(sp)
    8000280c:	6ca2                	ld	s9,8(sp)
    8000280e:	6125                	addi	sp,sp,96
    80002810:	8082                	ret
		sleep(p, &wait_lock); // DOC: wait-sleep
    80002812:	85e6                	mv	a1,s9
    80002814:	854a                	mv	a0,s2
    80002816:	00000097          	auipc	ra,0x0
    8000281a:	a2a080e7          	jalr	-1494(ra) # 80002240 <sleep>
		havekids = 0;
    8000281e:	b731                	j	8000272a <wait+0x4c>

0000000080002820 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002820:	7179                	addi	sp,sp,-48
    80002822:	f406                	sd	ra,40(sp)
    80002824:	f022                	sd	s0,32(sp)
    80002826:	ec26                	sd	s1,24(sp)
    80002828:	e84a                	sd	s2,16(sp)
    8000282a:	e44e                	sd	s3,8(sp)
    8000282c:	e052                	sd	s4,0(sp)
    8000282e:	1800                	addi	s0,sp,48
    80002830:	84aa                	mv	s1,a0
    80002832:	892e                	mv	s2,a1
    80002834:	89b2                	mv	s3,a2
    80002836:	8a36                	mv	s4,a3
	struct proc *p = myproc();
    80002838:	fffff097          	auipc	ra,0xfffff
    8000283c:	294080e7          	jalr	660(ra) # 80001acc <myproc>
	if (user_dst)
    80002840:	c08d                	beqz	s1,80002862 <either_copyout+0x42>
	{
		return copyout(p->pagetable, dst, src, len);
    80002842:	86d2                	mv	a3,s4
    80002844:	864e                	mv	a2,s3
    80002846:	85ca                	mv	a1,s2
    80002848:	6d28                	ld	a0,88(a0)
    8000284a:	fffff097          	auipc	ra,0xfffff
    8000284e:	e3a080e7          	jalr	-454(ra) # 80001684 <copyout>
	else
	{
		memmove((char *)dst, src, len);
		return 0;
	}
}
    80002852:	70a2                	ld	ra,40(sp)
    80002854:	7402                	ld	s0,32(sp)
    80002856:	64e2                	ld	s1,24(sp)
    80002858:	6942                	ld	s2,16(sp)
    8000285a:	69a2                	ld	s3,8(sp)
    8000285c:	6a02                	ld	s4,0(sp)
    8000285e:	6145                	addi	sp,sp,48
    80002860:	8082                	ret
		memmove((char *)dst, src, len);
    80002862:	000a061b          	sext.w	a2,s4
    80002866:	85ce                	mv	a1,s3
    80002868:	854a                	mv	a0,s2
    8000286a:	ffffe097          	auipc	ra,0xffffe
    8000286e:	4dc080e7          	jalr	1244(ra) # 80000d46 <memmove>
		return 0;
    80002872:	8526                	mv	a0,s1
    80002874:	bff9                	j	80002852 <either_copyout+0x32>

0000000080002876 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002876:	7179                	addi	sp,sp,-48
    80002878:	f406                	sd	ra,40(sp)
    8000287a:	f022                	sd	s0,32(sp)
    8000287c:	ec26                	sd	s1,24(sp)
    8000287e:	e84a                	sd	s2,16(sp)
    80002880:	e44e                	sd	s3,8(sp)
    80002882:	e052                	sd	s4,0(sp)
    80002884:	1800                	addi	s0,sp,48
    80002886:	892a                	mv	s2,a0
    80002888:	84ae                	mv	s1,a1
    8000288a:	89b2                	mv	s3,a2
    8000288c:	8a36                	mv	s4,a3
	struct proc *p = myproc();
    8000288e:	fffff097          	auipc	ra,0xfffff
    80002892:	23e080e7          	jalr	574(ra) # 80001acc <myproc>
	if (user_src)
    80002896:	c08d                	beqz	s1,800028b8 <either_copyin+0x42>
	{
		return copyin(p->pagetable, dst, src, len);
    80002898:	86d2                	mv	a3,s4
    8000289a:	864e                	mv	a2,s3
    8000289c:	85ca                	mv	a1,s2
    8000289e:	6d28                	ld	a0,88(a0)
    800028a0:	fffff097          	auipc	ra,0xfffff
    800028a4:	e70080e7          	jalr	-400(ra) # 80001710 <copyin>
	else
	{
		memmove(dst, (char *)src, len);
		return 0;
	}
}
    800028a8:	70a2                	ld	ra,40(sp)
    800028aa:	7402                	ld	s0,32(sp)
    800028ac:	64e2                	ld	s1,24(sp)
    800028ae:	6942                	ld	s2,16(sp)
    800028b0:	69a2                	ld	s3,8(sp)
    800028b2:	6a02                	ld	s4,0(sp)
    800028b4:	6145                	addi	sp,sp,48
    800028b6:	8082                	ret
		memmove(dst, (char *)src, len);
    800028b8:	000a061b          	sext.w	a2,s4
    800028bc:	85ce                	mv	a1,s3
    800028be:	854a                	mv	a0,s2
    800028c0:	ffffe097          	auipc	ra,0xffffe
    800028c4:	486080e7          	jalr	1158(ra) # 80000d46 <memmove>
		return 0;
    800028c8:	8526                	mv	a0,s1
    800028ca:	bff9                	j	800028a8 <either_copyin+0x32>

00000000800028cc <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck mastatechine further.
void procdump(void)
{
    800028cc:	715d                	addi	sp,sp,-80
    800028ce:	e486                	sd	ra,72(sp)
    800028d0:	e0a2                	sd	s0,64(sp)
    800028d2:	fc26                	sd	s1,56(sp)
    800028d4:	f84a                	sd	s2,48(sp)
    800028d6:	f44e                	sd	s3,40(sp)
    800028d8:	f052                	sd	s4,32(sp)
    800028da:	ec56                	sd	s5,24(sp)
    800028dc:	e85a                	sd	s6,16(sp)
    800028de:	e45e                	sd	s7,8(sp)
    800028e0:	0880                	addi	s0,sp,80
//     printf("%d     %d     %s   %d    %d    %d\n", p->pid, p->dynamicpriority, state, p->runtime, p->totalsleeptime, p->schedcount);
//     // release(&p->lock);
//   }
//   return;
// #endif
	printf("\n");
    800028e2:	00005517          	auipc	a0,0x5
    800028e6:	7e650513          	addi	a0,a0,2022 # 800080c8 <digits+0x88>
    800028ea:	ffffe097          	auipc	ra,0xffffe
    800028ee:	ca4080e7          	jalr	-860(ra) # 8000058e <printf>
	for (p = proc; p < &proc[NPROC]; p++)
    800028f2:	0000f497          	auipc	s1,0xf
    800028f6:	b3e48493          	addi	s1,s1,-1218 # 80011430 <proc+0x160>
    800028fa:	00016917          	auipc	s2,0x16
    800028fe:	73690913          	addi	s2,s2,1846 # 80019030 <bcache+0x148>
	{
		if (p->state == UNUSED)
			continue;
		if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002902:	4b15                	li	s6,5
			state = states[p->state];
		else
			state = "???";
    80002904:	00006997          	auipc	s3,0x6
    80002908:	99498993          	addi	s3,s3,-1644 # 80008298 <digits+0x258>
		printf("%d %s %s %d %d", p->pid, state, p->name, p->runTime, p->countTimeCalled);
    8000290c:	00006a97          	auipc	s5,0x6
    80002910:	994a8a93          	addi	s5,s5,-1644 # 800082a0 <digits+0x260>
		printf("\n");
    80002914:	00005a17          	auipc	s4,0x5
    80002918:	7b4a0a13          	addi	s4,s4,1972 # 800080c8 <digits+0x88>
		if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000291c:	00006b97          	auipc	s7,0x6
    80002920:	9c4b8b93          	addi	s7,s7,-1596 # 800082e0 <states.2503>
    80002924:	a01d                	j	8000294a <procdump+0x7e>
		printf("%d %s %s %d %d", p->pid, state, p->name, p->runTime, p->countTimeCalled);
    80002926:	4afc                	lw	a5,84(a3)
    80002928:	5ed8                	lw	a4,60(a3)
    8000292a:	ed86a583          	lw	a1,-296(a3)
    8000292e:	8556                	mv	a0,s5
    80002930:	ffffe097          	auipc	ra,0xffffe
    80002934:	c5e080e7          	jalr	-930(ra) # 8000058e <printf>
		printf("\n");
    80002938:	8552                	mv	a0,s4
    8000293a:	ffffe097          	auipc	ra,0xffffe
    8000293e:	c54080e7          	jalr	-940(ra) # 8000058e <printf>
	for (p = proc; p < &proc[NPROC]; p++)
    80002942:	1f048493          	addi	s1,s1,496
    80002946:	03248163          	beq	s1,s2,80002968 <procdump+0x9c>
		if (p->state == UNUSED)
    8000294a:	86a6                	mv	a3,s1
    8000294c:	ec04a783          	lw	a5,-320(s1)
    80002950:	dbed                	beqz	a5,80002942 <procdump+0x76>
			state = "???";
    80002952:	864e                	mv	a2,s3
		if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002954:	fcfb69e3          	bltu	s6,a5,80002926 <procdump+0x5a>
    80002958:	1782                	slli	a5,a5,0x20
    8000295a:	9381                	srli	a5,a5,0x20
    8000295c:	078e                	slli	a5,a5,0x3
    8000295e:	97de                	add	a5,a5,s7
    80002960:	6390                	ld	a2,0(a5)
    80002962:	f271                	bnez	a2,80002926 <procdump+0x5a>
			state = "???";
    80002964:	864e                	mv	a2,s3
    80002966:	b7c1                	j	80002926 <procdump+0x5a>
	}
}
    80002968:	60a6                	ld	ra,72(sp)
    8000296a:	6406                	ld	s0,64(sp)
    8000296c:	74e2                	ld	s1,56(sp)
    8000296e:	7942                	ld	s2,48(sp)
    80002970:	79a2                	ld	s3,40(sp)
    80002972:	7a02                	ld	s4,32(sp)
    80002974:	6ae2                	ld	s5,24(sp)
    80002976:	6b42                	ld	s6,16(sp)
    80002978:	6ba2                	ld	s7,8(sp)
    8000297a:	6161                	addi	sp,sp,80
    8000297c:	8082                	ret

000000008000297e <alarmtest>:

// int settickets(int num){

// }
int alarmtest(void)
{
    8000297e:	1141                	addi	sp,sp,-16
    80002980:	e422                	sd	s0,8(sp)
    80002982:	0800                	addi	s0,sp,16
	
    80002984:	6422                	ld	s0,8(sp)
    80002986:	0141                	addi	sp,sp,16
    80002988:	8082                	ret

000000008000298a <swtch>:
    8000298a:	00153023          	sd	ra,0(a0)
    8000298e:	00253423          	sd	sp,8(a0)
    80002992:	e900                	sd	s0,16(a0)
    80002994:	ed04                	sd	s1,24(a0)
    80002996:	03253023          	sd	s2,32(a0)
    8000299a:	03353423          	sd	s3,40(a0)
    8000299e:	03453823          	sd	s4,48(a0)
    800029a2:	03553c23          	sd	s5,56(a0)
    800029a6:	05653023          	sd	s6,64(a0)
    800029aa:	05753423          	sd	s7,72(a0)
    800029ae:	05853823          	sd	s8,80(a0)
    800029b2:	05953c23          	sd	s9,88(a0)
    800029b6:	07a53023          	sd	s10,96(a0)
    800029ba:	07b53423          	sd	s11,104(a0)
    800029be:	0005b083          	ld	ra,0(a1)
    800029c2:	0085b103          	ld	sp,8(a1)
    800029c6:	6980                	ld	s0,16(a1)
    800029c8:	6d84                	ld	s1,24(a1)
    800029ca:	0205b903          	ld	s2,32(a1)
    800029ce:	0285b983          	ld	s3,40(a1)
    800029d2:	0305ba03          	ld	s4,48(a1)
    800029d6:	0385ba83          	ld	s5,56(a1)
    800029da:	0405bb03          	ld	s6,64(a1)
    800029de:	0485bb83          	ld	s7,72(a1)
    800029e2:	0505bc03          	ld	s8,80(a1)
    800029e6:	0585bc83          	ld	s9,88(a1)
    800029ea:	0605bd03          	ld	s10,96(a1)
    800029ee:	0685bd83          	ld	s11,104(a1)
    800029f2:	8082                	ret

00000000800029f4 <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    800029f4:	1141                	addi	sp,sp,-16
    800029f6:	e406                	sd	ra,8(sp)
    800029f8:	e022                	sd	s0,0(sp)
    800029fa:	0800                	addi	s0,sp,16
	initlock(&tickslock, "time");
    800029fc:	00006597          	auipc	a1,0x6
    80002a00:	91458593          	addi	a1,a1,-1772 # 80008310 <states.2503+0x30>
    80002a04:	00016517          	auipc	a0,0x16
    80002a08:	4cc50513          	addi	a0,a0,1228 # 80018ed0 <tickslock>
    80002a0c:	ffffe097          	auipc	ra,0xffffe
    80002a10:	14e080e7          	jalr	334(ra) # 80000b5a <initlock>
}
    80002a14:	60a2                	ld	ra,8(sp)
    80002a16:	6402                	ld	s0,0(sp)
    80002a18:	0141                	addi	sp,sp,16
    80002a1a:	8082                	ret

0000000080002a1c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002a1c:	1141                	addi	sp,sp,-16
    80002a1e:	e422                	sd	s0,8(sp)
    80002a20:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a22:	00004797          	auipc	a5,0x4
    80002a26:	86e78793          	addi	a5,a5,-1938 # 80006290 <kernelvec>
    80002a2a:	10579073          	csrw	stvec,a5
	w_stvec((uint64)kernelvec);
}
    80002a2e:	6422                	ld	s0,8(sp)
    80002a30:	0141                	addi	sp,sp,16
    80002a32:	8082                	ret

0000000080002a34 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80002a34:	1141                	addi	sp,sp,-16
    80002a36:	e406                	sd	ra,8(sp)
    80002a38:	e022                	sd	s0,0(sp)
    80002a3a:	0800                	addi	s0,sp,16
	struct proc *p = myproc();
    80002a3c:	fffff097          	auipc	ra,0xfffff
    80002a40:	090080e7          	jalr	144(ra) # 80001acc <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a44:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002a48:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a4a:	10079073          	csrw	sstatus,a5
	// kerneltrap() to usertrap(), so turn off interrupts until
	// we're back in user space, where usertrap() is correct.
	intr_off();

	// send syscalls, interrupts, and exceptions to uservec in trampoline.S
	uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002a4e:	00004617          	auipc	a2,0x4
    80002a52:	5b260613          	addi	a2,a2,1458 # 80007000 <_trampoline>
    80002a56:	00004697          	auipc	a3,0x4
    80002a5a:	5aa68693          	addi	a3,a3,1450 # 80007000 <_trampoline>
    80002a5e:	8e91                	sub	a3,a3,a2
    80002a60:	040007b7          	lui	a5,0x4000
    80002a64:	17fd                	addi	a5,a5,-1
    80002a66:	07b2                	slli	a5,a5,0xc
    80002a68:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a6a:	10569073          	csrw	stvec,a3
	w_stvec(trampoline_uservec);

	// set up trapframe values that uservec will need when
	// the process next traps into the kernel.
	p->trapframe->kernel_satp = r_satp();		  // kernel page table
    80002a6e:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002a70:	180026f3          	csrr	a3,satp
    80002a74:	e314                	sd	a3,0(a4)
	p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002a76:	7138                	ld	a4,96(a0)
    80002a78:	6534                	ld	a3,72(a0)
    80002a7a:	6585                	lui	a1,0x1
    80002a7c:	96ae                	add	a3,a3,a1
    80002a7e:	e714                	sd	a3,8(a4)
	p->trapframe->kernel_trap = (uint64)usertrap;
    80002a80:	7138                	ld	a4,96(a0)
    80002a82:	00000697          	auipc	a3,0x0
    80002a86:	13e68693          	addi	a3,a3,318 # 80002bc0 <usertrap>
    80002a8a:	eb14                	sd	a3,16(a4)
	p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002a8c:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002a8e:	8692                	mv	a3,tp
    80002a90:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a92:	100026f3          	csrr	a3,sstatus
	// set up the registers that trampoline.S's sret will use
	// to get to user space.

	// set S Previous Privilege mode to User.
	unsigned long x = r_sstatus();
	x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002a96:	eff6f693          	andi	a3,a3,-257
	x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002a9a:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a9e:	10069073          	csrw	sstatus,a3
	w_sstatus(x);

	// set S Exception Program Counter to the saved user pc.
	w_sepc(p->trapframe->epc);
    80002aa2:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002aa4:	6f18                	ld	a4,24(a4)
    80002aa6:	14171073          	csrw	sepc,a4

	// tell trampoline.S the user page table to switch to.
	uint64 satp = MAKE_SATP(p->pagetable);
    80002aaa:	6d28                	ld	a0,88(a0)
    80002aac:	8131                	srli	a0,a0,0xc

	// jump to userret in trampoline.S at the top of memory, which
	// switches to the user page table, restores user registers,
	// and switches to user mode with sret.
	uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002aae:	00004717          	auipc	a4,0x4
    80002ab2:	5ee70713          	addi	a4,a4,1518 # 8000709c <userret>
    80002ab6:	8f11                	sub	a4,a4,a2
    80002ab8:	97ba                	add	a5,a5,a4
	((void (*)(uint64))trampoline_userret)(satp);
    80002aba:	577d                	li	a4,-1
    80002abc:	177e                	slli	a4,a4,0x3f
    80002abe:	8d59                	or	a0,a0,a4
    80002ac0:	9782                	jalr	a5
}
    80002ac2:	60a2                	ld	ra,8(sp)
    80002ac4:	6402                	ld	s0,0(sp)
    80002ac6:	0141                	addi	sp,sp,16
    80002ac8:	8082                	ret

0000000080002aca <clockintr>:
	w_sepc(sepc);
	w_sstatus(sstatus);
}

void clockintr()
{
    80002aca:	1101                	addi	sp,sp,-32
    80002acc:	ec06                	sd	ra,24(sp)
    80002ace:	e822                	sd	s0,16(sp)
    80002ad0:	e426                	sd	s1,8(sp)
    80002ad2:	e04a                	sd	s2,0(sp)
    80002ad4:	1000                	addi	s0,sp,32
	acquire(&tickslock);
    80002ad6:	00016917          	auipc	s2,0x16
    80002ada:	3fa90913          	addi	s2,s2,1018 # 80018ed0 <tickslock>
    80002ade:	854a                	mv	a0,s2
    80002ae0:	ffffe097          	auipc	ra,0xffffe
    80002ae4:	10a080e7          	jalr	266(ra) # 80000bea <acquire>
	ticks++;
    80002ae8:	00006497          	auipc	s1,0x6
    80002aec:	14848493          	addi	s1,s1,328 # 80008c30 <ticks>
    80002af0:	409c                	lw	a5,0(s1)
    80002af2:	2785                	addiw	a5,a5,1
    80002af4:	c09c                	sw	a5,0(s1)
	upd_time();
    80002af6:	fffff097          	auipc	ra,0xfffff
    80002afa:	518080e7          	jalr	1304(ra) # 8000200e <upd_time>
	wakeup(&ticks);
    80002afe:	8526                	mv	a0,s1
    80002b00:	00000097          	auipc	ra,0x0
    80002b04:	902080e7          	jalr	-1790(ra) # 80002402 <wakeup>
	release(&tickslock);
    80002b08:	854a                	mv	a0,s2
    80002b0a:	ffffe097          	auipc	ra,0xffffe
    80002b0e:	194080e7          	jalr	404(ra) # 80000c9e <release>
}
    80002b12:	60e2                	ld	ra,24(sp)
    80002b14:	6442                	ld	s0,16(sp)
    80002b16:	64a2                	ld	s1,8(sp)
    80002b18:	6902                	ld	s2,0(sp)
    80002b1a:	6105                	addi	sp,sp,32
    80002b1c:	8082                	ret

0000000080002b1e <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    80002b1e:	1101                	addi	sp,sp,-32
    80002b20:	ec06                	sd	ra,24(sp)
    80002b22:	e822                	sd	s0,16(sp)
    80002b24:	e426                	sd	s1,8(sp)
    80002b26:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b28:	14202773          	csrr	a4,scause
	uint64 scause = r_scause();

	if ((scause & 0x8000000000000000L) &&
    80002b2c:	00074d63          	bltz	a4,80002b46 <devintr+0x28>
		if (irq)
			plic_complete(irq);

		return 1;
	}
	else if (scause == 0x8000000000000001L)
    80002b30:	57fd                	li	a5,-1
    80002b32:	17fe                	slli	a5,a5,0x3f
    80002b34:	0785                	addi	a5,a5,1

		return 2;
	}
	else
	{
		return 0;
    80002b36:	4501                	li	a0,0
	else if (scause == 0x8000000000000001L)
    80002b38:	06f70363          	beq	a4,a5,80002b9e <devintr+0x80>
	}
}
    80002b3c:	60e2                	ld	ra,24(sp)
    80002b3e:	6442                	ld	s0,16(sp)
    80002b40:	64a2                	ld	s1,8(sp)
    80002b42:	6105                	addi	sp,sp,32
    80002b44:	8082                	ret
		(scause & 0xff) == 9)
    80002b46:	0ff77793          	andi	a5,a4,255
	if ((scause & 0x8000000000000000L) &&
    80002b4a:	46a5                	li	a3,9
    80002b4c:	fed792e3          	bne	a5,a3,80002b30 <devintr+0x12>
		int irq = plic_claim();
    80002b50:	00004097          	auipc	ra,0x4
    80002b54:	848080e7          	jalr	-1976(ra) # 80006398 <plic_claim>
    80002b58:	84aa                	mv	s1,a0
		if (irq == UART0_IRQ)
    80002b5a:	47a9                	li	a5,10
    80002b5c:	02f50763          	beq	a0,a5,80002b8a <devintr+0x6c>
		else if (irq == VIRTIO0_IRQ)
    80002b60:	4785                	li	a5,1
    80002b62:	02f50963          	beq	a0,a5,80002b94 <devintr+0x76>
		return 1;
    80002b66:	4505                	li	a0,1
		else if (irq)
    80002b68:	d8f1                	beqz	s1,80002b3c <devintr+0x1e>
			printf("unexpected interrupt irq=%d\n", irq);
    80002b6a:	85a6                	mv	a1,s1
    80002b6c:	00005517          	auipc	a0,0x5
    80002b70:	7ac50513          	addi	a0,a0,1964 # 80008318 <states.2503+0x38>
    80002b74:	ffffe097          	auipc	ra,0xffffe
    80002b78:	a1a080e7          	jalr	-1510(ra) # 8000058e <printf>
			plic_complete(irq);
    80002b7c:	8526                	mv	a0,s1
    80002b7e:	00004097          	auipc	ra,0x4
    80002b82:	83e080e7          	jalr	-1986(ra) # 800063bc <plic_complete>
		return 1;
    80002b86:	4505                	li	a0,1
    80002b88:	bf55                	j	80002b3c <devintr+0x1e>
			uartintr();
    80002b8a:	ffffe097          	auipc	ra,0xffffe
    80002b8e:	e24080e7          	jalr	-476(ra) # 800009ae <uartintr>
    80002b92:	b7ed                	j	80002b7c <devintr+0x5e>
			virtio_disk_intr();
    80002b94:	00004097          	auipc	ra,0x4
    80002b98:	d52080e7          	jalr	-686(ra) # 800068e6 <virtio_disk_intr>
    80002b9c:	b7c5                	j	80002b7c <devintr+0x5e>
		if (cpuid() == 0)
    80002b9e:	fffff097          	auipc	ra,0xfffff
    80002ba2:	f02080e7          	jalr	-254(ra) # 80001aa0 <cpuid>
    80002ba6:	c901                	beqz	a0,80002bb6 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002ba8:	144027f3          	csrr	a5,sip
		w_sip(r_sip() & ~2);
    80002bac:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002bae:	14479073          	csrw	sip,a5
		return 2;
    80002bb2:	4509                	li	a0,2
    80002bb4:	b761                	j	80002b3c <devintr+0x1e>
			clockintr();
    80002bb6:	00000097          	auipc	ra,0x0
    80002bba:	f14080e7          	jalr	-236(ra) # 80002aca <clockintr>
    80002bbe:	b7ed                	j	80002ba8 <devintr+0x8a>

0000000080002bc0 <usertrap>:
{
    80002bc0:	1101                	addi	sp,sp,-32
    80002bc2:	ec06                	sd	ra,24(sp)
    80002bc4:	e822                	sd	s0,16(sp)
    80002bc6:	e426                	sd	s1,8(sp)
    80002bc8:	e04a                	sd	s2,0(sp)
    80002bca:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bcc:	100027f3          	csrr	a5,sstatus
	if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002bd0:	1007f793          	andi	a5,a5,256
    80002bd4:	eba5                	bnez	a5,80002c44 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002bd6:	00003797          	auipc	a5,0x3
    80002bda:	6ba78793          	addi	a5,a5,1722 # 80006290 <kernelvec>
    80002bde:	10579073          	csrw	stvec,a5
	struct proc *p = myproc();
    80002be2:	fffff097          	auipc	ra,0xfffff
    80002be6:	eea080e7          	jalr	-278(ra) # 80001acc <myproc>
    80002bea:	84aa                	mv	s1,a0
	p->trapframe->epc = r_sepc();
    80002bec:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bee:	14102773          	csrr	a4,sepc
    80002bf2:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bf4:	14202773          	csrr	a4,scause
	if (r_scause() == 8)
    80002bf8:	47a1                	li	a5,8
    80002bfa:	04f70d63          	beq	a4,a5,80002c54 <usertrap+0x94>
	else if ((which_dev = devintr()) != 0)
    80002bfe:	00000097          	auipc	ra,0x0
    80002c02:	f20080e7          	jalr	-224(ra) # 80002b1e <devintr>
    80002c06:	892a                	mv	s2,a0
    80002c08:	c569                	beqz	a0,80002cd2 <usertrap+0x112>
		if (p != 0 && which_dev == 2 && p->checkifAlarmOn == 0)
    80002c0a:	4789                	li	a5,2
    80002c0c:	06f51863          	bne	a0,a5,80002c7c <usertrap+0xbc>
    80002c10:	1804a783          	lw	a5,384(s1)
    80002c14:	ef81                	bnez	a5,80002c2c <usertrap+0x6c>
			p->sigticks++;
    80002c16:	1844a783          	lw	a5,388(s1)
    80002c1a:	2785                	addiw	a5,a5,1
    80002c1c:	0007871b          	sext.w	a4,a5
    80002c20:	18f4a223          	sw	a5,388(s1)
			if (p->sigticks >= p->maxticks)
    80002c24:	1884a783          	lw	a5,392(s1)
    80002c28:	08f75063          	bge	a4,a5,80002ca8 <usertrap+0xe8>
	if (killed(p))
    80002c2c:	8526                	mv	a0,s1
    80002c2e:	00000097          	auipc	ra,0x0
    80002c32:	a7a080e7          	jalr	-1414(ra) # 800026a8 <killed>
    80002c36:	c17d                	beqz	a0,80002d1c <usertrap+0x15c>
		exit(-1);
    80002c38:	557d                	li	a0,-1
    80002c3a:	00000097          	auipc	ra,0x0
    80002c3e:	8c8080e7          	jalr	-1848(ra) # 80002502 <exit>
	if (which_dev == 2 && myproc()!=0 && myproc()->state==RUNNING)
    80002c42:	a8e9                	j	80002d1c <usertrap+0x15c>
		panic("usertrap: not from user mode");
    80002c44:	00005517          	auipc	a0,0x5
    80002c48:	6f450513          	addi	a0,a0,1780 # 80008338 <states.2503+0x58>
    80002c4c:	ffffe097          	auipc	ra,0xffffe
    80002c50:	8f8080e7          	jalr	-1800(ra) # 80000544 <panic>
		if (killed(p))
    80002c54:	00000097          	auipc	ra,0x0
    80002c58:	a54080e7          	jalr	-1452(ra) # 800026a8 <killed>
    80002c5c:	e121                	bnez	a0,80002c9c <usertrap+0xdc>
		p->trapframe->epc += 4;
    80002c5e:	70b8                	ld	a4,96(s1)
    80002c60:	6f1c                	ld	a5,24(a4)
    80002c62:	0791                	addi	a5,a5,4
    80002c64:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c66:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002c6a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c6e:	10079073          	csrw	sstatus,a5
		syscall();
    80002c72:	00000097          	auipc	ra,0x0
    80002c76:	332080e7          	jalr	818(ra) # 80002fa4 <syscall>
	int which_dev = 0;
    80002c7a:	4901                	li	s2,0
	if (killed(p))
    80002c7c:	8526                	mv	a0,s1
    80002c7e:	00000097          	auipc	ra,0x0
    80002c82:	a2a080e7          	jalr	-1494(ra) # 800026a8 <killed>
    80002c86:	e159                	bnez	a0,80002d0c <usertrap+0x14c>
	usertrapret();
    80002c88:	00000097          	auipc	ra,0x0
    80002c8c:	dac080e7          	jalr	-596(ra) # 80002a34 <usertrapret>
}
    80002c90:	60e2                	ld	ra,24(sp)
    80002c92:	6442                	ld	s0,16(sp)
    80002c94:	64a2                	ld	s1,8(sp)
    80002c96:	6902                	ld	s2,0(sp)
    80002c98:	6105                	addi	sp,sp,32
    80002c9a:	8082                	ret
			exit(-1);
    80002c9c:	557d                	li	a0,-1
    80002c9e:	00000097          	auipc	ra,0x0
    80002ca2:	864080e7          	jalr	-1948(ra) # 80002502 <exit>
    80002ca6:	bf65                	j	80002c5e <usertrap+0x9e>
				p->checkifAlarmOn = 1;
    80002ca8:	4785                	li	a5,1
    80002caa:	18f4a023          	sw	a5,384(s1)
				struct trapframe *tf = kalloc();
    80002cae:	ffffe097          	auipc	ra,0xffffe
    80002cb2:	e4c080e7          	jalr	-436(ra) # 80000afa <kalloc>
    80002cb6:	892a                	mv	s2,a0
				memmove(tf, p->trapframe, PGSIZE);
    80002cb8:	6605                	lui	a2,0x1
    80002cba:	70ac                	ld	a1,96(s1)
    80002cbc:	ffffe097          	auipc	ra,0xffffe
    80002cc0:	08a080e7          	jalr	138(ra) # 80000d46 <memmove>
				p->alarm_handler = tf;
    80002cc4:	1724b823          	sd	s2,368(s1)
				p->trapframe->epc = p->handler;
    80002cc8:	70bc                	ld	a5,96(s1)
    80002cca:	1784b703          	ld	a4,376(s1)
    80002cce:	ef98                	sd	a4,24(a5)
    80002cd0:	bfb1                	j	80002c2c <usertrap+0x6c>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cd2:	142025f3          	csrr	a1,scause
		printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002cd6:	5c90                	lw	a2,56(s1)
    80002cd8:	00005517          	auipc	a0,0x5
    80002cdc:	68050513          	addi	a0,a0,1664 # 80008358 <states.2503+0x78>
    80002ce0:	ffffe097          	auipc	ra,0xffffe
    80002ce4:	8ae080e7          	jalr	-1874(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ce8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002cec:	14302673          	csrr	a2,stval
		printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002cf0:	00005517          	auipc	a0,0x5
    80002cf4:	69850513          	addi	a0,a0,1688 # 80008388 <states.2503+0xa8>
    80002cf8:	ffffe097          	auipc	ra,0xffffe
    80002cfc:	896080e7          	jalr	-1898(ra) # 8000058e <printf>
		setkilled(p);
    80002d00:	8526                	mv	a0,s1
    80002d02:	00000097          	auipc	ra,0x0
    80002d06:	970080e7          	jalr	-1680(ra) # 80002672 <setkilled>
    80002d0a:	bf8d                	j	80002c7c <usertrap+0xbc>
		exit(-1);
    80002d0c:	557d                	li	a0,-1
    80002d0e:	fffff097          	auipc	ra,0xfffff
    80002d12:	7f4080e7          	jalr	2036(ra) # 80002502 <exit>
	if (which_dev == 2 && myproc()!=0 && myproc()->state==RUNNING)
    80002d16:	4789                	li	a5,2
    80002d18:	f6f918e3          	bne	s2,a5,80002c88 <usertrap+0xc8>
    80002d1c:	fffff097          	auipc	ra,0xfffff
    80002d20:	db0080e7          	jalr	-592(ra) # 80001acc <myproc>
    80002d24:	d135                	beqz	a0,80002c88 <usertrap+0xc8>
    80002d26:	fffff097          	auipc	ra,0xfffff
    80002d2a:	da6080e7          	jalr	-602(ra) # 80001acc <myproc>
    80002d2e:	5118                	lw	a4,32(a0)
    80002d30:	4791                	li	a5,4
    80002d32:	f4f71be3          	bne	a4,a5,80002c88 <usertrap+0xc8>
		yield();
    80002d36:	fffff097          	auipc	ra,0xfffff
    80002d3a:	4c4080e7          	jalr	1220(ra) # 800021fa <yield>
    80002d3e:	b7a9                	j	80002c88 <usertrap+0xc8>

0000000080002d40 <kerneltrap>:
{
    80002d40:	7179                	addi	sp,sp,-48
    80002d42:	f406                	sd	ra,40(sp)
    80002d44:	f022                	sd	s0,32(sp)
    80002d46:	ec26                	sd	s1,24(sp)
    80002d48:	e84a                	sd	s2,16(sp)
    80002d4a:	e44e                	sd	s3,8(sp)
    80002d4c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d4e:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d52:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d56:	142029f3          	csrr	s3,scause
	if ((sstatus & SSTATUS_SPP) == 0)
    80002d5a:	1004f793          	andi	a5,s1,256
    80002d5e:	cb85                	beqz	a5,80002d8e <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d60:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002d64:	8b89                	andi	a5,a5,2
	if (intr_get() != 0)
    80002d66:	ef85                	bnez	a5,80002d9e <kerneltrap+0x5e>
	if ((which_dev = devintr()) == 0)
    80002d68:	00000097          	auipc	ra,0x0
    80002d6c:	db6080e7          	jalr	-586(ra) # 80002b1e <devintr>
    80002d70:	cd1d                	beqz	a0,80002dae <kerneltrap+0x6e>
	if (which_dev == 2 && myproc() != 0)
    80002d72:	4789                	li	a5,2
    80002d74:	06f50a63          	beq	a0,a5,80002de8 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002d78:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d7c:	10049073          	csrw	sstatus,s1
}
    80002d80:	70a2                	ld	ra,40(sp)
    80002d82:	7402                	ld	s0,32(sp)
    80002d84:	64e2                	ld	s1,24(sp)
    80002d86:	6942                	ld	s2,16(sp)
    80002d88:	69a2                	ld	s3,8(sp)
    80002d8a:	6145                	addi	sp,sp,48
    80002d8c:	8082                	ret
		panic("kerneltrap: not from supervisor mode");
    80002d8e:	00005517          	auipc	a0,0x5
    80002d92:	61a50513          	addi	a0,a0,1562 # 800083a8 <states.2503+0xc8>
    80002d96:	ffffd097          	auipc	ra,0xffffd
    80002d9a:	7ae080e7          	jalr	1966(ra) # 80000544 <panic>
		panic("kerneltrap: interrupts enabled");
    80002d9e:	00005517          	auipc	a0,0x5
    80002da2:	63250513          	addi	a0,a0,1586 # 800083d0 <states.2503+0xf0>
    80002da6:	ffffd097          	auipc	ra,0xffffd
    80002daa:	79e080e7          	jalr	1950(ra) # 80000544 <panic>
		printf("scause %p\n", scause);
    80002dae:	85ce                	mv	a1,s3
    80002db0:	00005517          	auipc	a0,0x5
    80002db4:	64050513          	addi	a0,a0,1600 # 800083f0 <states.2503+0x110>
    80002db8:	ffffd097          	auipc	ra,0xffffd
    80002dbc:	7d6080e7          	jalr	2006(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002dc0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002dc4:	14302673          	csrr	a2,stval
		printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002dc8:	00005517          	auipc	a0,0x5
    80002dcc:	63850513          	addi	a0,a0,1592 # 80008400 <states.2503+0x120>
    80002dd0:	ffffd097          	auipc	ra,0xffffd
    80002dd4:	7be080e7          	jalr	1982(ra) # 8000058e <printf>
		panic("kerneltrap");
    80002dd8:	00005517          	auipc	a0,0x5
    80002ddc:	64050513          	addi	a0,a0,1600 # 80008418 <states.2503+0x138>
    80002de0:	ffffd097          	auipc	ra,0xffffd
    80002de4:	764080e7          	jalr	1892(ra) # 80000544 <panic>
	if (which_dev == 2 && myproc() != 0)
    80002de8:	fffff097          	auipc	ra,0xfffff
    80002dec:	ce4080e7          	jalr	-796(ra) # 80001acc <myproc>
    80002df0:	d541                	beqz	a0,80002d78 <kerneltrap+0x38>
		printf("%d\n", myproc()->state);
    80002df2:	fffff097          	auipc	ra,0xfffff
    80002df6:	cda080e7          	jalr	-806(ra) # 80001acc <myproc>
    80002dfa:	510c                	lw	a1,32(a0)
    80002dfc:	00005517          	auipc	a0,0x5
    80002e00:	66450513          	addi	a0,a0,1636 # 80008460 <states.2503+0x180>
    80002e04:	ffffd097          	auipc	ra,0xffffd
    80002e08:	78a080e7          	jalr	1930(ra) # 8000058e <printf>
		if (myproc()->state == RUNNING)
    80002e0c:	fffff097          	auipc	ra,0xfffff
    80002e10:	cc0080e7          	jalr	-832(ra) # 80001acc <myproc>
    80002e14:	5118                	lw	a4,32(a0)
    80002e16:	4791                	li	a5,4
    80002e18:	f6f710e3          	bne	a4,a5,80002d78 <kerneltrap+0x38>
			yield();
    80002e1c:	fffff097          	auipc	ra,0xfffff
    80002e20:	3de080e7          	jalr	990(ra) # 800021fa <yield>
    80002e24:	bf91                	j	80002d78 <kerneltrap+0x38>

0000000080002e26 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002e26:	1101                	addi	sp,sp,-32
    80002e28:	ec06                	sd	ra,24(sp)
    80002e2a:	e822                	sd	s0,16(sp)
    80002e2c:	e426                	sd	s1,8(sp)
    80002e2e:	1000                	addi	s0,sp,32
    80002e30:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002e32:	fffff097          	auipc	ra,0xfffff
    80002e36:	c9a080e7          	jalr	-870(ra) # 80001acc <myproc>
  switch (n)
    80002e3a:	4795                	li	a5,5
    80002e3c:	0497e163          	bltu	a5,s1,80002e7e <argraw+0x58>
    80002e40:	048a                	slli	s1,s1,0x2
    80002e42:	00005717          	auipc	a4,0x5
    80002e46:	73e70713          	addi	a4,a4,1854 # 80008580 <states.2503+0x2a0>
    80002e4a:	94ba                	add	s1,s1,a4
    80002e4c:	409c                	lw	a5,0(s1)
    80002e4e:	97ba                	add	a5,a5,a4
    80002e50:	8782                	jr	a5
  {
  case 0:
    return p->trapframe->a0;
    80002e52:	713c                	ld	a5,96(a0)
    80002e54:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002e56:	60e2                	ld	ra,24(sp)
    80002e58:	6442                	ld	s0,16(sp)
    80002e5a:	64a2                	ld	s1,8(sp)
    80002e5c:	6105                	addi	sp,sp,32
    80002e5e:	8082                	ret
    return p->trapframe->a1;
    80002e60:	713c                	ld	a5,96(a0)
    80002e62:	7fa8                	ld	a0,120(a5)
    80002e64:	bfcd                	j	80002e56 <argraw+0x30>
    return p->trapframe->a2;
    80002e66:	713c                	ld	a5,96(a0)
    80002e68:	63c8                	ld	a0,128(a5)
    80002e6a:	b7f5                	j	80002e56 <argraw+0x30>
    return p->trapframe->a3;
    80002e6c:	713c                	ld	a5,96(a0)
    80002e6e:	67c8                	ld	a0,136(a5)
    80002e70:	b7dd                	j	80002e56 <argraw+0x30>
    return p->trapframe->a4;
    80002e72:	713c                	ld	a5,96(a0)
    80002e74:	6bc8                	ld	a0,144(a5)
    80002e76:	b7c5                	j	80002e56 <argraw+0x30>
    return p->trapframe->a5;
    80002e78:	713c                	ld	a5,96(a0)
    80002e7a:	6fc8                	ld	a0,152(a5)
    80002e7c:	bfe9                	j	80002e56 <argraw+0x30>
  panic("argraw");
    80002e7e:	00005517          	auipc	a0,0x5
    80002e82:	5aa50513          	addi	a0,a0,1450 # 80008428 <states.2503+0x148>
    80002e86:	ffffd097          	auipc	ra,0xffffd
    80002e8a:	6be080e7          	jalr	1726(ra) # 80000544 <panic>

0000000080002e8e <fetchaddr>:
{
    80002e8e:	1101                	addi	sp,sp,-32
    80002e90:	ec06                	sd	ra,24(sp)
    80002e92:	e822                	sd	s0,16(sp)
    80002e94:	e426                	sd	s1,8(sp)
    80002e96:	e04a                	sd	s2,0(sp)
    80002e98:	1000                	addi	s0,sp,32
    80002e9a:	84aa                	mv	s1,a0
    80002e9c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002e9e:	fffff097          	auipc	ra,0xfffff
    80002ea2:	c2e080e7          	jalr	-978(ra) # 80001acc <myproc>
  if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002ea6:	693c                	ld	a5,80(a0)
    80002ea8:	02f4f863          	bgeu	s1,a5,80002ed8 <fetchaddr+0x4a>
    80002eac:	00848713          	addi	a4,s1,8
    80002eb0:	02e7e663          	bltu	a5,a4,80002edc <fetchaddr+0x4e>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002eb4:	46a1                	li	a3,8
    80002eb6:	8626                	mv	a2,s1
    80002eb8:	85ca                	mv	a1,s2
    80002eba:	6d28                	ld	a0,88(a0)
    80002ebc:	fffff097          	auipc	ra,0xfffff
    80002ec0:	854080e7          	jalr	-1964(ra) # 80001710 <copyin>
    80002ec4:	00a03533          	snez	a0,a0
    80002ec8:	40a00533          	neg	a0,a0
}
    80002ecc:	60e2                	ld	ra,24(sp)
    80002ece:	6442                	ld	s0,16(sp)
    80002ed0:	64a2                	ld	s1,8(sp)
    80002ed2:	6902                	ld	s2,0(sp)
    80002ed4:	6105                	addi	sp,sp,32
    80002ed6:	8082                	ret
    return -1;
    80002ed8:	557d                	li	a0,-1
    80002eda:	bfcd                	j	80002ecc <fetchaddr+0x3e>
    80002edc:	557d                	li	a0,-1
    80002ede:	b7fd                	j	80002ecc <fetchaddr+0x3e>

0000000080002ee0 <fetchstr>:
{
    80002ee0:	7179                	addi	sp,sp,-48
    80002ee2:	f406                	sd	ra,40(sp)
    80002ee4:	f022                	sd	s0,32(sp)
    80002ee6:	ec26                	sd	s1,24(sp)
    80002ee8:	e84a                	sd	s2,16(sp)
    80002eea:	e44e                	sd	s3,8(sp)
    80002eec:	1800                	addi	s0,sp,48
    80002eee:	892a                	mv	s2,a0
    80002ef0:	84ae                	mv	s1,a1
    80002ef2:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002ef4:	fffff097          	auipc	ra,0xfffff
    80002ef8:	bd8080e7          	jalr	-1064(ra) # 80001acc <myproc>
  if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80002efc:	86ce                	mv	a3,s3
    80002efe:	864a                	mv	a2,s2
    80002f00:	85a6                	mv	a1,s1
    80002f02:	6d28                	ld	a0,88(a0)
    80002f04:	fffff097          	auipc	ra,0xfffff
    80002f08:	898080e7          	jalr	-1896(ra) # 8000179c <copyinstr>
    80002f0c:	00054e63          	bltz	a0,80002f28 <fetchstr+0x48>
  return strlen(buf);
    80002f10:	8526                	mv	a0,s1
    80002f12:	ffffe097          	auipc	ra,0xffffe
    80002f16:	f58080e7          	jalr	-168(ra) # 80000e6a <strlen>
}
    80002f1a:	70a2                	ld	ra,40(sp)
    80002f1c:	7402                	ld	s0,32(sp)
    80002f1e:	64e2                	ld	s1,24(sp)
    80002f20:	6942                	ld	s2,16(sp)
    80002f22:	69a2                	ld	s3,8(sp)
    80002f24:	6145                	addi	sp,sp,48
    80002f26:	8082                	ret
    return -1;
    80002f28:	557d                	li	a0,-1
    80002f2a:	bfc5                	j	80002f1a <fetchstr+0x3a>

0000000080002f2c <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80002f2c:	1101                	addi	sp,sp,-32
    80002f2e:	ec06                	sd	ra,24(sp)
    80002f30:	e822                	sd	s0,16(sp)
    80002f32:	e426                	sd	s1,8(sp)
    80002f34:	1000                	addi	s0,sp,32
    80002f36:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002f38:	00000097          	auipc	ra,0x0
    80002f3c:	eee080e7          	jalr	-274(ra) # 80002e26 <argraw>
    80002f40:	c088                	sw	a0,0(s1)
}
    80002f42:	60e2                	ld	ra,24(sp)
    80002f44:	6442                	ld	s0,16(sp)
    80002f46:	64a2                	ld	s1,8(sp)
    80002f48:	6105                	addi	sp,sp,32
    80002f4a:	8082                	ret

0000000080002f4c <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80002f4c:	1101                	addi	sp,sp,-32
    80002f4e:	ec06                	sd	ra,24(sp)
    80002f50:	e822                	sd	s0,16(sp)
    80002f52:	e426                	sd	s1,8(sp)
    80002f54:	1000                	addi	s0,sp,32
    80002f56:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002f58:	00000097          	auipc	ra,0x0
    80002f5c:	ece080e7          	jalr	-306(ra) # 80002e26 <argraw>
    80002f60:	e088                	sd	a0,0(s1)
}
    80002f62:	60e2                	ld	ra,24(sp)
    80002f64:	6442                	ld	s0,16(sp)
    80002f66:	64a2                	ld	s1,8(sp)
    80002f68:	6105                	addi	sp,sp,32
    80002f6a:	8082                	ret

0000000080002f6c <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80002f6c:	7179                	addi	sp,sp,-48
    80002f6e:	f406                	sd	ra,40(sp)
    80002f70:	f022                	sd	s0,32(sp)
    80002f72:	ec26                	sd	s1,24(sp)
    80002f74:	e84a                	sd	s2,16(sp)
    80002f76:	1800                	addi	s0,sp,48
    80002f78:	84ae                	mv	s1,a1
    80002f7a:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002f7c:	fd840593          	addi	a1,s0,-40
    80002f80:	00000097          	auipc	ra,0x0
    80002f84:	fcc080e7          	jalr	-52(ra) # 80002f4c <argaddr>
  return fetchstr(addr, buf, max);
    80002f88:	864a                	mv	a2,s2
    80002f8a:	85a6                	mv	a1,s1
    80002f8c:	fd843503          	ld	a0,-40(s0)
    80002f90:	00000097          	auipc	ra,0x0
    80002f94:	f50080e7          	jalr	-176(ra) # 80002ee0 <fetchstr>
}
    80002f98:	70a2                	ld	ra,40(sp)
    80002f9a:	7402                	ld	s0,32(sp)
    80002f9c:	64e2                	ld	s1,24(sp)
    80002f9e:	6942                	ld	s2,16(sp)
    80002fa0:	6145                	addi	sp,sp,48
    80002fa2:	8082                	ret

0000000080002fa4 <syscall>:
    {"sigreturn", 0},
    {"alarmtest", 0},
};

void syscall(void)
{
    80002fa4:	711d                	addi	sp,sp,-96
    80002fa6:	ec86                	sd	ra,88(sp)
    80002fa8:	e8a2                	sd	s0,80(sp)
    80002faa:	e4a6                	sd	s1,72(sp)
    80002fac:	e0ca                	sd	s2,64(sp)
    80002fae:	fc4e                	sd	s3,56(sp)
    80002fb0:	f852                	sd	s4,48(sp)
    80002fb2:	f456                	sd	s5,40(sp)
    80002fb4:	f05a                	sd	s6,32(sp)
    80002fb6:	ec5e                	sd	s7,24(sp)
    80002fb8:	e862                	sd	s8,16(sp)
    80002fba:	e466                	sd	s9,8(sp)
    80002fbc:	e06a                	sd	s10,0(sp)
    80002fbe:	1080                	addi	s0,sp,96
  int num;
  struct proc *p = myproc();
    80002fc0:	fffff097          	auipc	ra,0xfffff
    80002fc4:	b0c080e7          	jalr	-1268(ra) # 80001acc <myproc>
    80002fc8:	8a2a                	mv	s4,a0

  num = p->trapframe->a7; // return reg
    80002fca:	7124                	ld	s1,96(a0)
    80002fcc:	74dc                	ld	a5,168(s1)
    80002fce:	00078b1b          	sext.w	s6,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    80002fd2:	37fd                	addiw	a5,a5,-1
    80002fd4:	476d                	li	a4,27
    80002fd6:	06f76f63          	bltu	a4,a5,80003054 <syscall+0xb0>
    80002fda:	003b1713          	slli	a4,s6,0x3
    80002fde:	00005797          	auipc	a5,0x5
    80002fe2:	5ba78793          	addi	a5,a5,1466 # 80008598 <syscalls>
    80002fe6:	97ba                	add	a5,a5,a4
    80002fe8:	0007bd03          	ld	s10,0(a5)
    80002fec:	060d0463          	beqz	s10,80003054 <syscall+0xb0>
  {
    80002ff0:	8c8a                	mv	s9,sp
    int numargs = syscall_info[num - 1].num;
    80002ff2:	fffb0c1b          	addiw	s8,s6,-1
    80002ff6:	004c1713          	slli	a4,s8,0x4
    80002ffa:	00006797          	auipc	a5,0x6
    80002ffe:	a0e78793          	addi	a5,a5,-1522 # 80008a08 <syscall_info>
    80003002:	97ba                	add	a5,a5,a4
    80003004:	0087a983          	lw	s3,8(a5)
    int Args[numargs]; // to store value of registers acc to the number of args of the syscall
    80003008:	00299793          	slli	a5,s3,0x2
    8000300c:	07bd                	addi	a5,a5,15
    8000300e:	9bc1                	andi	a5,a5,-16
    80003010:	40f10133          	sub	sp,sp,a5
    80003014:	8b8a                	mv	s7,sp
    int j = 0;
    while (j < numargs)
    80003016:	11305363          	blez	s3,8000311c <syscall+0x178>
    8000301a:	8ade                	mv	s5,s7
    8000301c:	895e                	mv	s2,s7
    int j = 0;
    8000301e:	4481                	li	s1,0
    {
      Args[j] = argraw(j);
    80003020:	8526                	mv	a0,s1
    80003022:	00000097          	auipc	ra,0x0
    80003026:	e04080e7          	jalr	-508(ra) # 80002e26 <argraw>
    8000302a:	00a92023          	sw	a0,0(s2)
      j++;
    8000302e:	2485                	addiw	s1,s1,1
    while (j < numargs)
    80003030:	0911                	addi	s2,s2,4
    80003032:	fe9997e3          	bne	s3,s1,80003020 <syscall+0x7c>
    }

    int shift = 1 << num; // mask for num
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80003036:	060a3483          	ld	s1,96(s4)
    8000303a:	9d02                	jalr	s10
    8000303c:	f8a8                	sd	a0,112(s1)
    int shift = 1 << num; // mask for num
    8000303e:	4785                	li	a5,1
    80003040:	016797bb          	sllw	a5,a5,s6

    if (p->mask & shift)
    80003044:	000a2b03          	lw	s6,0(s4)
    80003048:	0167f7b3          	and	a5,a5,s6
    8000304c:	2781                	sext.w	a5,a5
    8000304e:	e7a1                	bnez	a5,80003096 <syscall+0xf2>
    80003050:	8166                	mv	sp,s9
  {
    80003052:	a015                	j	80003076 <syscall+0xd2>
      printf(" -> %d\n", p->trapframe->a0);
    }
  }
  else
  {
    printf("%d %s: unknown sys call %d\n",
    80003054:	86da                	mv	a3,s6
    80003056:	160a0613          	addi	a2,s4,352
    8000305a:	038a2583          	lw	a1,56(s4)
    8000305e:	00005517          	auipc	a0,0x5
    80003062:	3ea50513          	addi	a0,a0,1002 # 80008448 <states.2503+0x168>
    80003066:	ffffd097          	auipc	ra,0xffffd
    8000306a:	528080e7          	jalr	1320(ra) # 8000058e <printf>
           p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000306e:	060a3783          	ld	a5,96(s4)
    80003072:	577d                	li	a4,-1
    80003074:	fbb8                	sd	a4,112(a5)
  }
}
    80003076:	fa040113          	addi	sp,s0,-96
    8000307a:	60e6                	ld	ra,88(sp)
    8000307c:	6446                	ld	s0,80(sp)
    8000307e:	64a6                	ld	s1,72(sp)
    80003080:	6906                	ld	s2,64(sp)
    80003082:	79e2                	ld	s3,56(sp)
    80003084:	7a42                	ld	s4,48(sp)
    80003086:	7aa2                	ld	s5,40(sp)
    80003088:	7b02                	ld	s6,32(sp)
    8000308a:	6be2                	ld	s7,24(sp)
    8000308c:	6c42                	ld	s8,16(sp)
    8000308e:	6ca2                	ld	s9,8(sp)
    80003090:	6d02                	ld	s10,0(sp)
    80003092:	6125                	addi	sp,sp,96
    80003094:	8082                	ret
      printf("%d: syscall %s ", p->pid, syscall_info[num - 1].name);
    80003096:	0c12                	slli	s8,s8,0x4
    80003098:	00006797          	auipc	a5,0x6
    8000309c:	97078793          	addi	a5,a5,-1680 # 80008a08 <syscall_info>
    800030a0:	9c3e                	add	s8,s8,a5
    800030a2:	000c3603          	ld	a2,0(s8)
    800030a6:	038a2583          	lw	a1,56(s4)
    800030aa:	00005517          	auipc	a0,0x5
    800030ae:	3be50513          	addi	a0,a0,958 # 80008468 <states.2503+0x188>
    800030b2:	ffffd097          	auipc	ra,0xffffd
    800030b6:	4dc080e7          	jalr	1244(ra) # 8000058e <printf>
      printf("(");
    800030ba:	00005517          	auipc	a0,0x5
    800030be:	3be50513          	addi	a0,a0,958 # 80008478 <states.2503+0x198>
    800030c2:	ffffd097          	auipc	ra,0xffffd
    800030c6:	4cc080e7          	jalr	1228(ra) # 8000058e <printf>
      while (i < numargs)
    800030ca:	fff9879b          	addiw	a5,s3,-1
    800030ce:	1782                	slli	a5,a5,0x20
    800030d0:	9381                	srli	a5,a5,0x20
    800030d2:	0785                	addi	a5,a5,1
    800030d4:	078a                	slli	a5,a5,0x2
    800030d6:	9bbe                	add	s7,s7,a5
        printf("%d ", Args[i]);
    800030d8:	00005497          	auipc	s1,0x5
    800030dc:	35848493          	addi	s1,s1,856 # 80008430 <states.2503+0x150>
    800030e0:	000aa583          	lw	a1,0(s5)
    800030e4:	8526                	mv	a0,s1
    800030e6:	ffffd097          	auipc	ra,0xffffd
    800030ea:	4a8080e7          	jalr	1192(ra) # 8000058e <printf>
      while (i < numargs)
    800030ee:	0a91                	addi	s5,s5,4
    800030f0:	ff7a98e3          	bne	s5,s7,800030e0 <syscall+0x13c>
      printf(")");
    800030f4:	00005517          	auipc	a0,0x5
    800030f8:	34450513          	addi	a0,a0,836 # 80008438 <states.2503+0x158>
    800030fc:	ffffd097          	auipc	ra,0xffffd
    80003100:	492080e7          	jalr	1170(ra) # 8000058e <printf>
      printf(" -> %d\n", p->trapframe->a0);
    80003104:	060a3783          	ld	a5,96(s4)
    80003108:	7bac                	ld	a1,112(a5)
    8000310a:	00005517          	auipc	a0,0x5
    8000310e:	33650513          	addi	a0,a0,822 # 80008440 <states.2503+0x160>
    80003112:	ffffd097          	auipc	ra,0xffffd
    80003116:	47c080e7          	jalr	1148(ra) # 8000058e <printf>
    8000311a:	bf1d                	j	80003050 <syscall+0xac>
    p->trapframe->a0 = syscalls[num]();
    8000311c:	9d02                	jalr	s10
    8000311e:	f8a8                	sd	a0,112(s1)
    int shift = 1 << num; // mask for num
    80003120:	4785                	li	a5,1
    80003122:	016797bb          	sllw	a5,a5,s6
    if (p->mask & shift)
    80003126:	000a2703          	lw	a4,0(s4)
    8000312a:	8ff9                	and	a5,a5,a4
    8000312c:	2781                	sext.w	a5,a5
    8000312e:	d38d                	beqz	a5,80003050 <syscall+0xac>
      printf("%d: syscall %s ", p->pid, syscall_info[num - 1].name);
    80003130:	0c12                	slli	s8,s8,0x4
    80003132:	00006797          	auipc	a5,0x6
    80003136:	8d678793          	addi	a5,a5,-1834 # 80008a08 <syscall_info>
    8000313a:	97e2                	add	a5,a5,s8
    8000313c:	6390                	ld	a2,0(a5)
    8000313e:	038a2583          	lw	a1,56(s4)
    80003142:	00005517          	auipc	a0,0x5
    80003146:	32650513          	addi	a0,a0,806 # 80008468 <states.2503+0x188>
    8000314a:	ffffd097          	auipc	ra,0xffffd
    8000314e:	444080e7          	jalr	1092(ra) # 8000058e <printf>
      printf("(");
    80003152:	00005517          	auipc	a0,0x5
    80003156:	32650513          	addi	a0,a0,806 # 80008478 <states.2503+0x198>
    8000315a:	ffffd097          	auipc	ra,0xffffd
    8000315e:	434080e7          	jalr	1076(ra) # 8000058e <printf>
      while (i < numargs)
    80003162:	bf49                	j	800030f4 <syscall+0x150>

0000000080003164 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80003164:	1101                	addi	sp,sp,-32
    80003166:	ec06                	sd	ra,24(sp)
    80003168:	e822                	sd	s0,16(sp)
    8000316a:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    8000316c:	fec40593          	addi	a1,s0,-20
    80003170:	4501                	li	a0,0
    80003172:	00000097          	auipc	ra,0x0
    80003176:	dba080e7          	jalr	-582(ra) # 80002f2c <argint>
  exit(n);
    8000317a:	fec42503          	lw	a0,-20(s0)
    8000317e:	fffff097          	auipc	ra,0xfffff
    80003182:	384080e7          	jalr	900(ra) # 80002502 <exit>
  return 0; // not reached
}
    80003186:	4501                	li	a0,0
    80003188:	60e2                	ld	ra,24(sp)
    8000318a:	6442                	ld	s0,16(sp)
    8000318c:	6105                	addi	sp,sp,32
    8000318e:	8082                	ret

0000000080003190 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003190:	1141                	addi	sp,sp,-16
    80003192:	e406                	sd	ra,8(sp)
    80003194:	e022                	sd	s0,0(sp)
    80003196:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003198:	fffff097          	auipc	ra,0xfffff
    8000319c:	934080e7          	jalr	-1740(ra) # 80001acc <myproc>
}
    800031a0:	5d08                	lw	a0,56(a0)
    800031a2:	60a2                	ld	ra,8(sp)
    800031a4:	6402                	ld	s0,0(sp)
    800031a6:	0141                	addi	sp,sp,16
    800031a8:	8082                	ret

00000000800031aa <sys_fork>:

uint64
sys_fork(void)
{
    800031aa:	1141                	addi	sp,sp,-16
    800031ac:	e406                	sd	ra,8(sp)
    800031ae:	e022                	sd	s0,0(sp)
    800031b0:	0800                	addi	s0,sp,16
  return fork();
    800031b2:	fffff097          	auipc	ra,0xfffff
    800031b6:	d0e080e7          	jalr	-754(ra) # 80001ec0 <fork>
}
    800031ba:	60a2                	ld	ra,8(sp)
    800031bc:	6402                	ld	s0,0(sp)
    800031be:	0141                	addi	sp,sp,16
    800031c0:	8082                	ret

00000000800031c2 <sys_wait>:

uint64
sys_wait(void)
{
    800031c2:	1101                	addi	sp,sp,-32
    800031c4:	ec06                	sd	ra,24(sp)
    800031c6:	e822                	sd	s0,16(sp)
    800031c8:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800031ca:	fe840593          	addi	a1,s0,-24
    800031ce:	4501                	li	a0,0
    800031d0:	00000097          	auipc	ra,0x0
    800031d4:	d7c080e7          	jalr	-644(ra) # 80002f4c <argaddr>
  return wait(p);
    800031d8:	fe843503          	ld	a0,-24(s0)
    800031dc:	fffff097          	auipc	ra,0xfffff
    800031e0:	502080e7          	jalr	1282(ra) # 800026de <wait>
}
    800031e4:	60e2                	ld	ra,24(sp)
    800031e6:	6442                	ld	s0,16(sp)
    800031e8:	6105                	addi	sp,sp,32
    800031ea:	8082                	ret

00000000800031ec <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800031ec:	7179                	addi	sp,sp,-48
    800031ee:	f406                	sd	ra,40(sp)
    800031f0:	f022                	sd	s0,32(sp)
    800031f2:	ec26                	sd	s1,24(sp)
    800031f4:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    800031f6:	fdc40593          	addi	a1,s0,-36
    800031fa:	4501                	li	a0,0
    800031fc:	00000097          	auipc	ra,0x0
    80003200:	d30080e7          	jalr	-720(ra) # 80002f2c <argint>
  addr = myproc()->sz;
    80003204:	fffff097          	auipc	ra,0xfffff
    80003208:	8c8080e7          	jalr	-1848(ra) # 80001acc <myproc>
    8000320c:	6924                	ld	s1,80(a0)
  if (growproc(n) < 0)
    8000320e:	fdc42503          	lw	a0,-36(s0)
    80003212:	fffff097          	auipc	ra,0xfffff
    80003216:	c52080e7          	jalr	-942(ra) # 80001e64 <growproc>
    8000321a:	00054863          	bltz	a0,8000322a <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    8000321e:	8526                	mv	a0,s1
    80003220:	70a2                	ld	ra,40(sp)
    80003222:	7402                	ld	s0,32(sp)
    80003224:	64e2                	ld	s1,24(sp)
    80003226:	6145                	addi	sp,sp,48
    80003228:	8082                	ret
    return -1;
    8000322a:	54fd                	li	s1,-1
    8000322c:	bfcd                	j	8000321e <sys_sbrk+0x32>

000000008000322e <sys_sleep>:

uint64
sys_sleep(void)
{
    8000322e:	7139                	addi	sp,sp,-64
    80003230:	fc06                	sd	ra,56(sp)
    80003232:	f822                	sd	s0,48(sp)
    80003234:	f426                	sd	s1,40(sp)
    80003236:	f04a                	sd	s2,32(sp)
    80003238:	ec4e                	sd	s3,24(sp)
    8000323a:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    8000323c:	fcc40593          	addi	a1,s0,-52
    80003240:	4501                	li	a0,0
    80003242:	00000097          	auipc	ra,0x0
    80003246:	cea080e7          	jalr	-790(ra) # 80002f2c <argint>
  acquire(&tickslock);
    8000324a:	00016517          	auipc	a0,0x16
    8000324e:	c8650513          	addi	a0,a0,-890 # 80018ed0 <tickslock>
    80003252:	ffffe097          	auipc	ra,0xffffe
    80003256:	998080e7          	jalr	-1640(ra) # 80000bea <acquire>
  ticks0 = ticks;
    8000325a:	00006917          	auipc	s2,0x6
    8000325e:	9d692903          	lw	s2,-1578(s2) # 80008c30 <ticks>
  while (ticks - ticks0 < n)
    80003262:	fcc42783          	lw	a5,-52(s0)
    80003266:	cf9d                	beqz	a5,800032a4 <sys_sleep+0x76>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003268:	00016997          	auipc	s3,0x16
    8000326c:	c6898993          	addi	s3,s3,-920 # 80018ed0 <tickslock>
    80003270:	00006497          	auipc	s1,0x6
    80003274:	9c048493          	addi	s1,s1,-1600 # 80008c30 <ticks>
    if (killed(myproc()))
    80003278:	fffff097          	auipc	ra,0xfffff
    8000327c:	854080e7          	jalr	-1964(ra) # 80001acc <myproc>
    80003280:	fffff097          	auipc	ra,0xfffff
    80003284:	428080e7          	jalr	1064(ra) # 800026a8 <killed>
    80003288:	ed15                	bnez	a0,800032c4 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    8000328a:	85ce                	mv	a1,s3
    8000328c:	8526                	mv	a0,s1
    8000328e:	fffff097          	auipc	ra,0xfffff
    80003292:	fb2080e7          	jalr	-78(ra) # 80002240 <sleep>
  while (ticks - ticks0 < n)
    80003296:	409c                	lw	a5,0(s1)
    80003298:	412787bb          	subw	a5,a5,s2
    8000329c:	fcc42703          	lw	a4,-52(s0)
    800032a0:	fce7ece3          	bltu	a5,a4,80003278 <sys_sleep+0x4a>
  }
  release(&tickslock);
    800032a4:	00016517          	auipc	a0,0x16
    800032a8:	c2c50513          	addi	a0,a0,-980 # 80018ed0 <tickslock>
    800032ac:	ffffe097          	auipc	ra,0xffffe
    800032b0:	9f2080e7          	jalr	-1550(ra) # 80000c9e <release>
  return 0;
    800032b4:	4501                	li	a0,0
}
    800032b6:	70e2                	ld	ra,56(sp)
    800032b8:	7442                	ld	s0,48(sp)
    800032ba:	74a2                	ld	s1,40(sp)
    800032bc:	7902                	ld	s2,32(sp)
    800032be:	69e2                	ld	s3,24(sp)
    800032c0:	6121                	addi	sp,sp,64
    800032c2:	8082                	ret
      release(&tickslock);
    800032c4:	00016517          	auipc	a0,0x16
    800032c8:	c0c50513          	addi	a0,a0,-1012 # 80018ed0 <tickslock>
    800032cc:	ffffe097          	auipc	ra,0xffffe
    800032d0:	9d2080e7          	jalr	-1582(ra) # 80000c9e <release>
      return -1;
    800032d4:	557d                	li	a0,-1
    800032d6:	b7c5                	j	800032b6 <sys_sleep+0x88>

00000000800032d8 <sys_kill>:

uint64
sys_kill(void)
{
    800032d8:	1101                	addi	sp,sp,-32
    800032da:	ec06                	sd	ra,24(sp)
    800032dc:	e822                	sd	s0,16(sp)
    800032de:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800032e0:	fec40593          	addi	a1,s0,-20
    800032e4:	4501                	li	a0,0
    800032e6:	00000097          	auipc	ra,0x0
    800032ea:	c46080e7          	jalr	-954(ra) # 80002f2c <argint>
  return kill(pid);
    800032ee:	fec42503          	lw	a0,-20(s0)
    800032f2:	fffff097          	auipc	ra,0xfffff
    800032f6:	2f4080e7          	jalr	756(ra) # 800025e6 <kill>
}
    800032fa:	60e2                	ld	ra,24(sp)
    800032fc:	6442                	ld	s0,16(sp)
    800032fe:	6105                	addi	sp,sp,32
    80003300:	8082                	ret

0000000080003302 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003302:	1101                	addi	sp,sp,-32
    80003304:	ec06                	sd	ra,24(sp)
    80003306:	e822                	sd	s0,16(sp)
    80003308:	e426                	sd	s1,8(sp)
    8000330a:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000330c:	00016517          	auipc	a0,0x16
    80003310:	bc450513          	addi	a0,a0,-1084 # 80018ed0 <tickslock>
    80003314:	ffffe097          	auipc	ra,0xffffe
    80003318:	8d6080e7          	jalr	-1834(ra) # 80000bea <acquire>
  xticks = ticks;
    8000331c:	00006497          	auipc	s1,0x6
    80003320:	9144a483          	lw	s1,-1772(s1) # 80008c30 <ticks>
  release(&tickslock);
    80003324:	00016517          	auipc	a0,0x16
    80003328:	bac50513          	addi	a0,a0,-1108 # 80018ed0 <tickslock>
    8000332c:	ffffe097          	auipc	ra,0xffffe
    80003330:	972080e7          	jalr	-1678(ra) # 80000c9e <release>
  return xticks;
}
    80003334:	02049513          	slli	a0,s1,0x20
    80003338:	9101                	srli	a0,a0,0x20
    8000333a:	60e2                	ld	ra,24(sp)
    8000333c:	6442                	ld	s0,16(sp)
    8000333e:	64a2                	ld	s1,8(sp)
    80003340:	6105                	addi	sp,sp,32
    80003342:	8082                	ret

0000000080003344 <sys_trace>:

uint64
sys_trace(void)
{
    80003344:	1101                	addi	sp,sp,-32
    80003346:	ec06                	sd	ra,24(sp)
    80003348:	e822                	sd	s0,16(sp)
    8000334a:	1000                	addi	s0,sp,32
  int n; // mask
  argint(0, &n);
    8000334c:	fec40593          	addi	a1,s0,-20
    80003350:	4501                	li	a0,0
    80003352:	00000097          	auipc	ra,0x0
    80003356:	bda080e7          	jalr	-1062(ra) # 80002f2c <argint>
  myproc()->mask = n;
    8000335a:	ffffe097          	auipc	ra,0xffffe
    8000335e:	772080e7          	jalr	1906(ra) # 80001acc <myproc>
    80003362:	fec42783          	lw	a5,-20(s0)
    80003366:	c11c                	sw	a5,0(a0)
  return 0;
}
    80003368:	4501                	li	a0,0
    8000336a:	60e2                	ld	ra,24(sp)
    8000336c:	6442                	ld	s0,16(sp)
    8000336e:	6105                	addi	sp,sp,32
    80003370:	8082                	ret

0000000080003372 <sys_setpriority>:
//   return 0;
// }

uint64
sys_setpriority(void)
{
    80003372:	1101                	addi	sp,sp,-32
    80003374:	ec06                	sd	ra,24(sp)
    80003376:	e822                	sd	s0,16(sp)
    80003378:	1000                	addi	s0,sp,32
  int priority;
  int pid;
  argint(0, &priority);
    8000337a:	fec40593          	addi	a1,s0,-20
    8000337e:	4501                	li	a0,0
    80003380:	00000097          	auipc	ra,0x0
    80003384:	bac080e7          	jalr	-1108(ra) # 80002f2c <argint>
  argint(1, &pid);
    80003388:	fe840593          	addi	a1,s0,-24
    8000338c:	4505                	li	a0,1
    8000338e:	00000097          	auipc	ra,0x0
    80003392:	b9e080e7          	jalr	-1122(ra) # 80002f2c <argint>
  return set_priority(priority, pid);
    80003396:	fe842583          	lw	a1,-24(s0)
    8000339a:	fec42503          	lw	a0,-20(s0)
    8000339e:	ffffe097          	auipc	ra,0xffffe
    800033a2:	500080e7          	jalr	1280(ra) # 8000189e <set_priority>
}
    800033a6:	60e2                	ld	ra,24(sp)
    800033a8:	6442                	ld	s0,16(sp)
    800033aa:	6105                	addi	sp,sp,32
    800033ac:	8082                	ret

00000000800033ae <sys_settickets>:

uint64
sys_settickets(void)
{
    800033ae:	1101                	addi	sp,sp,-32
    800033b0:	ec06                	sd	ra,24(sp)
    800033b2:	e822                	sd	s0,16(sp)
    800033b4:	1000                	addi	s0,sp,32
  int n; // tickets
  argint(0, &n);
    800033b6:	fec40593          	addi	a1,s0,-20
    800033ba:	4501                	li	a0,0
    800033bc:	00000097          	auipc	ra,0x0
    800033c0:	b70080e7          	jalr	-1168(ra) # 80002f2c <argint>
  myproc()->tickets = n;
    800033c4:	ffffe097          	auipc	ra,0xffffe
    800033c8:	708080e7          	jalr	1800(ra) # 80001acc <myproc>
    800033cc:	fec42783          	lw	a5,-20(s0)
    800033d0:	18f52623          	sw	a5,396(a0)
  return 0;
}
    800033d4:	4501                	li	a0,0
    800033d6:	60e2                	ld	ra,24(sp)
    800033d8:	6442                	ld	s0,16(sp)
    800033da:	6105                	addi	sp,sp,32
    800033dc:	8082                	ret

00000000800033de <sys_waitx>:

uint64
sys_waitx(void)
{
    800033de:	7139                	addi	sp,sp,-64
    800033e0:	fc06                	sd	ra,56(sp)
    800033e2:	f822                	sd	s0,48(sp)
    800033e4:	f426                	sd	s1,40(sp)
    800033e6:	f04a                	sd	s2,32(sp)
    800033e8:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    800033ea:	fd840593          	addi	a1,s0,-40
    800033ee:	4501                	li	a0,0
    800033f0:	00000097          	auipc	ra,0x0
    800033f4:	b5c080e7          	jalr	-1188(ra) # 80002f4c <argaddr>
  argaddr(1, &addr1); // user virtual memory
    800033f8:	fd040593          	addi	a1,s0,-48
    800033fc:	4505                	li	a0,1
    800033fe:	00000097          	auipc	ra,0x0
    80003402:	b4e080e7          	jalr	-1202(ra) # 80002f4c <argaddr>
  argaddr(2, &addr2);
    80003406:	fc840593          	addi	a1,s0,-56
    8000340a:	4509                	li	a0,2
    8000340c:	00000097          	auipc	ra,0x0
    80003410:	b40080e7          	jalr	-1216(ra) # 80002f4c <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    80003414:	fc040613          	addi	a2,s0,-64
    80003418:	fc440593          	addi	a1,s0,-60
    8000341c:	fd843503          	ld	a0,-40(s0)
    80003420:	fffff097          	auipc	ra,0xfffff
    80003424:	e8e080e7          	jalr	-370(ra) # 800022ae <waitx>
    80003428:	892a                	mv	s2,a0
  struct proc *p = myproc();
    8000342a:	ffffe097          	auipc	ra,0xffffe
    8000342e:	6a2080e7          	jalr	1698(ra) # 80001acc <myproc>
    80003432:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    80003434:	4691                	li	a3,4
    80003436:	fc440613          	addi	a2,s0,-60
    8000343a:	fd043583          	ld	a1,-48(s0)
    8000343e:	6d28                	ld	a0,88(a0)
    80003440:	ffffe097          	auipc	ra,0xffffe
    80003444:	244080e7          	jalr	580(ra) # 80001684 <copyout>
    return -1;
    80003448:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    8000344a:	00054f63          	bltz	a0,80003468 <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    8000344e:	4691                	li	a3,4
    80003450:	fc040613          	addi	a2,s0,-64
    80003454:	fc843583          	ld	a1,-56(s0)
    80003458:	6ca8                	ld	a0,88(s1)
    8000345a:	ffffe097          	auipc	ra,0xffffe
    8000345e:	22a080e7          	jalr	554(ra) # 80001684 <copyout>
    80003462:	00054a63          	bltz	a0,80003476 <sys_waitx+0x98>
    return -1;
  return ret;
    80003466:	87ca                	mv	a5,s2
}
    80003468:	853e                	mv	a0,a5
    8000346a:	70e2                	ld	ra,56(sp)
    8000346c:	7442                	ld	s0,48(sp)
    8000346e:	74a2                	ld	s1,40(sp)
    80003470:	7902                	ld	s2,32(sp)
    80003472:	6121                	addi	sp,sp,64
    80003474:	8082                	ret
    return -1;
    80003476:	57fd                	li	a5,-1
    80003478:	bfc5                	j	80003468 <sys_waitx+0x8a>

000000008000347a <sys_sigalarm>:
uint64 sys_sigalarm(void)
{
    8000347a:	1101                	addi	sp,sp,-32
    8000347c:	ec06                	sd	ra,24(sp)
    8000347e:	e822                	sd	s0,16(sp)
    80003480:	1000                	addi	s0,sp,32
  uint64 addr;
  int ticks;
  argint(0, &ticks);
    80003482:	fe440593          	addi	a1,s0,-28
    80003486:	4501                	li	a0,0
    80003488:	00000097          	auipc	ra,0x0
    8000348c:	aa4080e7          	jalr	-1372(ra) # 80002f2c <argint>
  argaddr(1, &addr);
    80003490:	fe840593          	addi	a1,s0,-24
    80003494:	4505                	li	a0,1
    80003496:	00000097          	auipc	ra,0x0
    8000349a:	ab6080e7          	jalr	-1354(ra) # 80002f4c <argaddr>
  // if(argaddr(1, &addr) < 0)
  //   return -1;

  myproc()->maxticks = ticks;
    8000349e:	ffffe097          	auipc	ra,0xffffe
    800034a2:	62e080e7          	jalr	1582(ra) # 80001acc <myproc>
    800034a6:	fe442783          	lw	a5,-28(s0)
    800034aa:	18f52423          	sw	a5,392(a0)
  myproc()->handler = addr;
    800034ae:	ffffe097          	auipc	ra,0xffffe
    800034b2:	61e080e7          	jalr	1566(ra) # 80001acc <myproc>
    800034b6:	fe843783          	ld	a5,-24(s0)
    800034ba:	16f53c23          	sd	a5,376(a0)

  return 0;
}
    800034be:	4501                	li	a0,0
    800034c0:	60e2                	ld	ra,24(sp)
    800034c2:	6442                	ld	s0,16(sp)
    800034c4:	6105                	addi	sp,sp,32
    800034c6:	8082                	ret

00000000800034c8 <sys_sigreturn>:
uint64 sys_sigreturn(void)
{
    800034c8:	1101                	addi	sp,sp,-32
    800034ca:	ec06                	sd	ra,24(sp)
    800034cc:	e822                	sd	s0,16(sp)
    800034ce:	e426                	sd	s1,8(sp)
    800034d0:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800034d2:	ffffe097          	auipc	ra,0xffffe
    800034d6:	5fa080e7          	jalr	1530(ra) # 80001acc <myproc>
    800034da:	84aa                	mv	s1,a0
  memmove(p->trapframe, p->alarm_handler, PGSIZE);
    800034dc:	6605                	lui	a2,0x1
    800034de:	17053583          	ld	a1,368(a0)
    800034e2:	7128                	ld	a0,96(a0)
    800034e4:	ffffe097          	auipc	ra,0xffffe
    800034e8:	862080e7          	jalr	-1950(ra) # 80000d46 <memmove>

  kfree(p->alarm_handler);
    800034ec:	1704b503          	ld	a0,368(s1)
    800034f0:	ffffd097          	auipc	ra,0xffffd
    800034f4:	50e080e7          	jalr	1294(ra) # 800009fe <kfree>
  p->alarm_handler = 0;
    800034f8:	1604b823          	sd	zero,368(s1)
  p->checkifAlarmOn = 0;
    800034fc:	1804a023          	sw	zero,384(s1)
  p->sigticks = 0;
    80003500:	1804a223          	sw	zero,388(s1)
  return p->trapframe->a0;
    80003504:	70bc                	ld	a5,96(s1)
}
    80003506:	7ba8                	ld	a0,112(a5)
    80003508:	60e2                	ld	ra,24(sp)
    8000350a:	6442                	ld	s0,16(sp)
    8000350c:	64a2                	ld	s1,8(sp)
    8000350e:	6105                	addi	sp,sp,32
    80003510:	8082                	ret

0000000080003512 <sys_alarmtest>:
uint64 sys_alarmtest(void)
{
    80003512:	1141                	addi	sp,sp,-16
    80003514:	e422                	sd	s0,8(sp)
    80003516:	0800                	addi	s0,sp,16
  // alarmtest();
  return 0;
    80003518:	4501                	li	a0,0
    8000351a:	6422                	ld	s0,8(sp)
    8000351c:	0141                	addi	sp,sp,16
    8000351e:	8082                	ret

0000000080003520 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003520:	7179                	addi	sp,sp,-48
    80003522:	f406                	sd	ra,40(sp)
    80003524:	f022                	sd	s0,32(sp)
    80003526:	ec26                	sd	s1,24(sp)
    80003528:	e84a                	sd	s2,16(sp)
    8000352a:	e44e                	sd	s3,8(sp)
    8000352c:	e052                	sd	s4,0(sp)
    8000352e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003530:	00005597          	auipc	a1,0x5
    80003534:	15058593          	addi	a1,a1,336 # 80008680 <syscalls+0xe8>
    80003538:	00016517          	auipc	a0,0x16
    8000353c:	9b050513          	addi	a0,a0,-1616 # 80018ee8 <bcache>
    80003540:	ffffd097          	auipc	ra,0xffffd
    80003544:	61a080e7          	jalr	1562(ra) # 80000b5a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003548:	0001e797          	auipc	a5,0x1e
    8000354c:	9a078793          	addi	a5,a5,-1632 # 80020ee8 <bcache+0x8000>
    80003550:	0001e717          	auipc	a4,0x1e
    80003554:	c0070713          	addi	a4,a4,-1024 # 80021150 <bcache+0x8268>
    80003558:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000355c:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003560:	00016497          	auipc	s1,0x16
    80003564:	9a048493          	addi	s1,s1,-1632 # 80018f00 <bcache+0x18>
    b->next = bcache.head.next;
    80003568:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000356a:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000356c:	00005a17          	auipc	s4,0x5
    80003570:	11ca0a13          	addi	s4,s4,284 # 80008688 <syscalls+0xf0>
    b->next = bcache.head.next;
    80003574:	2b893783          	ld	a5,696(s2)
    80003578:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000357a:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000357e:	85d2                	mv	a1,s4
    80003580:	01048513          	addi	a0,s1,16
    80003584:	00001097          	auipc	ra,0x1
    80003588:	4c4080e7          	jalr	1220(ra) # 80004a48 <initsleeplock>
    bcache.head.next->prev = b;
    8000358c:	2b893783          	ld	a5,696(s2)
    80003590:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003592:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003596:	45848493          	addi	s1,s1,1112
    8000359a:	fd349de3          	bne	s1,s3,80003574 <binit+0x54>
  }
}
    8000359e:	70a2                	ld	ra,40(sp)
    800035a0:	7402                	ld	s0,32(sp)
    800035a2:	64e2                	ld	s1,24(sp)
    800035a4:	6942                	ld	s2,16(sp)
    800035a6:	69a2                	ld	s3,8(sp)
    800035a8:	6a02                	ld	s4,0(sp)
    800035aa:	6145                	addi	sp,sp,48
    800035ac:	8082                	ret

00000000800035ae <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800035ae:	7179                	addi	sp,sp,-48
    800035b0:	f406                	sd	ra,40(sp)
    800035b2:	f022                	sd	s0,32(sp)
    800035b4:	ec26                	sd	s1,24(sp)
    800035b6:	e84a                	sd	s2,16(sp)
    800035b8:	e44e                	sd	s3,8(sp)
    800035ba:	1800                	addi	s0,sp,48
    800035bc:	89aa                	mv	s3,a0
    800035be:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    800035c0:	00016517          	auipc	a0,0x16
    800035c4:	92850513          	addi	a0,a0,-1752 # 80018ee8 <bcache>
    800035c8:	ffffd097          	auipc	ra,0xffffd
    800035cc:	622080e7          	jalr	1570(ra) # 80000bea <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800035d0:	0001e497          	auipc	s1,0x1e
    800035d4:	bd04b483          	ld	s1,-1072(s1) # 800211a0 <bcache+0x82b8>
    800035d8:	0001e797          	auipc	a5,0x1e
    800035dc:	b7878793          	addi	a5,a5,-1160 # 80021150 <bcache+0x8268>
    800035e0:	02f48f63          	beq	s1,a5,8000361e <bread+0x70>
    800035e4:	873e                	mv	a4,a5
    800035e6:	a021                	j	800035ee <bread+0x40>
    800035e8:	68a4                	ld	s1,80(s1)
    800035ea:	02e48a63          	beq	s1,a4,8000361e <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800035ee:	449c                	lw	a5,8(s1)
    800035f0:	ff379ce3          	bne	a5,s3,800035e8 <bread+0x3a>
    800035f4:	44dc                	lw	a5,12(s1)
    800035f6:	ff2799e3          	bne	a5,s2,800035e8 <bread+0x3a>
      b->refcnt++;
    800035fa:	40bc                	lw	a5,64(s1)
    800035fc:	2785                	addiw	a5,a5,1
    800035fe:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003600:	00016517          	auipc	a0,0x16
    80003604:	8e850513          	addi	a0,a0,-1816 # 80018ee8 <bcache>
    80003608:	ffffd097          	auipc	ra,0xffffd
    8000360c:	696080e7          	jalr	1686(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    80003610:	01048513          	addi	a0,s1,16
    80003614:	00001097          	auipc	ra,0x1
    80003618:	46e080e7          	jalr	1134(ra) # 80004a82 <acquiresleep>
      return b;
    8000361c:	a8b9                	j	8000367a <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000361e:	0001e497          	auipc	s1,0x1e
    80003622:	b7a4b483          	ld	s1,-1158(s1) # 80021198 <bcache+0x82b0>
    80003626:	0001e797          	auipc	a5,0x1e
    8000362a:	b2a78793          	addi	a5,a5,-1238 # 80021150 <bcache+0x8268>
    8000362e:	00f48863          	beq	s1,a5,8000363e <bread+0x90>
    80003632:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003634:	40bc                	lw	a5,64(s1)
    80003636:	cf81                	beqz	a5,8000364e <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003638:	64a4                	ld	s1,72(s1)
    8000363a:	fee49de3          	bne	s1,a4,80003634 <bread+0x86>
  panic("bget: no buffers");
    8000363e:	00005517          	auipc	a0,0x5
    80003642:	05250513          	addi	a0,a0,82 # 80008690 <syscalls+0xf8>
    80003646:	ffffd097          	auipc	ra,0xffffd
    8000364a:	efe080e7          	jalr	-258(ra) # 80000544 <panic>
      b->dev = dev;
    8000364e:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80003652:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80003656:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000365a:	4785                	li	a5,1
    8000365c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000365e:	00016517          	auipc	a0,0x16
    80003662:	88a50513          	addi	a0,a0,-1910 # 80018ee8 <bcache>
    80003666:	ffffd097          	auipc	ra,0xffffd
    8000366a:	638080e7          	jalr	1592(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    8000366e:	01048513          	addi	a0,s1,16
    80003672:	00001097          	auipc	ra,0x1
    80003676:	410080e7          	jalr	1040(ra) # 80004a82 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000367a:	409c                	lw	a5,0(s1)
    8000367c:	cb89                	beqz	a5,8000368e <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000367e:	8526                	mv	a0,s1
    80003680:	70a2                	ld	ra,40(sp)
    80003682:	7402                	ld	s0,32(sp)
    80003684:	64e2                	ld	s1,24(sp)
    80003686:	6942                	ld	s2,16(sp)
    80003688:	69a2                	ld	s3,8(sp)
    8000368a:	6145                	addi	sp,sp,48
    8000368c:	8082                	ret
    virtio_disk_rw(b, 0);
    8000368e:	4581                	li	a1,0
    80003690:	8526                	mv	a0,s1
    80003692:	00003097          	auipc	ra,0x3
    80003696:	fc6080e7          	jalr	-58(ra) # 80006658 <virtio_disk_rw>
    b->valid = 1;
    8000369a:	4785                	li	a5,1
    8000369c:	c09c                	sw	a5,0(s1)
  return b;
    8000369e:	b7c5                	j	8000367e <bread+0xd0>

00000000800036a0 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800036a0:	1101                	addi	sp,sp,-32
    800036a2:	ec06                	sd	ra,24(sp)
    800036a4:	e822                	sd	s0,16(sp)
    800036a6:	e426                	sd	s1,8(sp)
    800036a8:	1000                	addi	s0,sp,32
    800036aa:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800036ac:	0541                	addi	a0,a0,16
    800036ae:	00001097          	auipc	ra,0x1
    800036b2:	46e080e7          	jalr	1134(ra) # 80004b1c <holdingsleep>
    800036b6:	cd01                	beqz	a0,800036ce <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800036b8:	4585                	li	a1,1
    800036ba:	8526                	mv	a0,s1
    800036bc:	00003097          	auipc	ra,0x3
    800036c0:	f9c080e7          	jalr	-100(ra) # 80006658 <virtio_disk_rw>
}
    800036c4:	60e2                	ld	ra,24(sp)
    800036c6:	6442                	ld	s0,16(sp)
    800036c8:	64a2                	ld	s1,8(sp)
    800036ca:	6105                	addi	sp,sp,32
    800036cc:	8082                	ret
    panic("bwrite");
    800036ce:	00005517          	auipc	a0,0x5
    800036d2:	fda50513          	addi	a0,a0,-38 # 800086a8 <syscalls+0x110>
    800036d6:	ffffd097          	auipc	ra,0xffffd
    800036da:	e6e080e7          	jalr	-402(ra) # 80000544 <panic>

00000000800036de <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800036de:	1101                	addi	sp,sp,-32
    800036e0:	ec06                	sd	ra,24(sp)
    800036e2:	e822                	sd	s0,16(sp)
    800036e4:	e426                	sd	s1,8(sp)
    800036e6:	e04a                	sd	s2,0(sp)
    800036e8:	1000                	addi	s0,sp,32
    800036ea:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800036ec:	01050913          	addi	s2,a0,16
    800036f0:	854a                	mv	a0,s2
    800036f2:	00001097          	auipc	ra,0x1
    800036f6:	42a080e7          	jalr	1066(ra) # 80004b1c <holdingsleep>
    800036fa:	c92d                	beqz	a0,8000376c <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800036fc:	854a                	mv	a0,s2
    800036fe:	00001097          	auipc	ra,0x1
    80003702:	3da080e7          	jalr	986(ra) # 80004ad8 <releasesleep>

  acquire(&bcache.lock);
    80003706:	00015517          	auipc	a0,0x15
    8000370a:	7e250513          	addi	a0,a0,2018 # 80018ee8 <bcache>
    8000370e:	ffffd097          	auipc	ra,0xffffd
    80003712:	4dc080e7          	jalr	1244(ra) # 80000bea <acquire>
  b->refcnt--;
    80003716:	40bc                	lw	a5,64(s1)
    80003718:	37fd                	addiw	a5,a5,-1
    8000371a:	0007871b          	sext.w	a4,a5
    8000371e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003720:	eb05                	bnez	a4,80003750 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003722:	68bc                	ld	a5,80(s1)
    80003724:	64b8                	ld	a4,72(s1)
    80003726:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003728:	64bc                	ld	a5,72(s1)
    8000372a:	68b8                	ld	a4,80(s1)
    8000372c:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000372e:	0001d797          	auipc	a5,0x1d
    80003732:	7ba78793          	addi	a5,a5,1978 # 80020ee8 <bcache+0x8000>
    80003736:	2b87b703          	ld	a4,696(a5)
    8000373a:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000373c:	0001e717          	auipc	a4,0x1e
    80003740:	a1470713          	addi	a4,a4,-1516 # 80021150 <bcache+0x8268>
    80003744:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003746:	2b87b703          	ld	a4,696(a5)
    8000374a:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000374c:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003750:	00015517          	auipc	a0,0x15
    80003754:	79850513          	addi	a0,a0,1944 # 80018ee8 <bcache>
    80003758:	ffffd097          	auipc	ra,0xffffd
    8000375c:	546080e7          	jalr	1350(ra) # 80000c9e <release>
}
    80003760:	60e2                	ld	ra,24(sp)
    80003762:	6442                	ld	s0,16(sp)
    80003764:	64a2                	ld	s1,8(sp)
    80003766:	6902                	ld	s2,0(sp)
    80003768:	6105                	addi	sp,sp,32
    8000376a:	8082                	ret
    panic("brelse");
    8000376c:	00005517          	auipc	a0,0x5
    80003770:	f4450513          	addi	a0,a0,-188 # 800086b0 <syscalls+0x118>
    80003774:	ffffd097          	auipc	ra,0xffffd
    80003778:	dd0080e7          	jalr	-560(ra) # 80000544 <panic>

000000008000377c <bpin>:

void
bpin(struct buf *b) {
    8000377c:	1101                	addi	sp,sp,-32
    8000377e:	ec06                	sd	ra,24(sp)
    80003780:	e822                	sd	s0,16(sp)
    80003782:	e426                	sd	s1,8(sp)
    80003784:	1000                	addi	s0,sp,32
    80003786:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003788:	00015517          	auipc	a0,0x15
    8000378c:	76050513          	addi	a0,a0,1888 # 80018ee8 <bcache>
    80003790:	ffffd097          	auipc	ra,0xffffd
    80003794:	45a080e7          	jalr	1114(ra) # 80000bea <acquire>
  b->refcnt++;
    80003798:	40bc                	lw	a5,64(s1)
    8000379a:	2785                	addiw	a5,a5,1
    8000379c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000379e:	00015517          	auipc	a0,0x15
    800037a2:	74a50513          	addi	a0,a0,1866 # 80018ee8 <bcache>
    800037a6:	ffffd097          	auipc	ra,0xffffd
    800037aa:	4f8080e7          	jalr	1272(ra) # 80000c9e <release>
}
    800037ae:	60e2                	ld	ra,24(sp)
    800037b0:	6442                	ld	s0,16(sp)
    800037b2:	64a2                	ld	s1,8(sp)
    800037b4:	6105                	addi	sp,sp,32
    800037b6:	8082                	ret

00000000800037b8 <bunpin>:

void
bunpin(struct buf *b) {
    800037b8:	1101                	addi	sp,sp,-32
    800037ba:	ec06                	sd	ra,24(sp)
    800037bc:	e822                	sd	s0,16(sp)
    800037be:	e426                	sd	s1,8(sp)
    800037c0:	1000                	addi	s0,sp,32
    800037c2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800037c4:	00015517          	auipc	a0,0x15
    800037c8:	72450513          	addi	a0,a0,1828 # 80018ee8 <bcache>
    800037cc:	ffffd097          	auipc	ra,0xffffd
    800037d0:	41e080e7          	jalr	1054(ra) # 80000bea <acquire>
  b->refcnt--;
    800037d4:	40bc                	lw	a5,64(s1)
    800037d6:	37fd                	addiw	a5,a5,-1
    800037d8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800037da:	00015517          	auipc	a0,0x15
    800037de:	70e50513          	addi	a0,a0,1806 # 80018ee8 <bcache>
    800037e2:	ffffd097          	auipc	ra,0xffffd
    800037e6:	4bc080e7          	jalr	1212(ra) # 80000c9e <release>
}
    800037ea:	60e2                	ld	ra,24(sp)
    800037ec:	6442                	ld	s0,16(sp)
    800037ee:	64a2                	ld	s1,8(sp)
    800037f0:	6105                	addi	sp,sp,32
    800037f2:	8082                	ret

00000000800037f4 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800037f4:	1101                	addi	sp,sp,-32
    800037f6:	ec06                	sd	ra,24(sp)
    800037f8:	e822                	sd	s0,16(sp)
    800037fa:	e426                	sd	s1,8(sp)
    800037fc:	e04a                	sd	s2,0(sp)
    800037fe:	1000                	addi	s0,sp,32
    80003800:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003802:	00d5d59b          	srliw	a1,a1,0xd
    80003806:	0001e797          	auipc	a5,0x1e
    8000380a:	dbe7a783          	lw	a5,-578(a5) # 800215c4 <sb+0x1c>
    8000380e:	9dbd                	addw	a1,a1,a5
    80003810:	00000097          	auipc	ra,0x0
    80003814:	d9e080e7          	jalr	-610(ra) # 800035ae <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003818:	0074f713          	andi	a4,s1,7
    8000381c:	4785                	li	a5,1
    8000381e:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003822:	14ce                	slli	s1,s1,0x33
    80003824:	90d9                	srli	s1,s1,0x36
    80003826:	00950733          	add	a4,a0,s1
    8000382a:	05874703          	lbu	a4,88(a4)
    8000382e:	00e7f6b3          	and	a3,a5,a4
    80003832:	c69d                	beqz	a3,80003860 <bfree+0x6c>
    80003834:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003836:	94aa                	add	s1,s1,a0
    80003838:	fff7c793          	not	a5,a5
    8000383c:	8ff9                	and	a5,a5,a4
    8000383e:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003842:	00001097          	auipc	ra,0x1
    80003846:	120080e7          	jalr	288(ra) # 80004962 <log_write>
  brelse(bp);
    8000384a:	854a                	mv	a0,s2
    8000384c:	00000097          	auipc	ra,0x0
    80003850:	e92080e7          	jalr	-366(ra) # 800036de <brelse>
}
    80003854:	60e2                	ld	ra,24(sp)
    80003856:	6442                	ld	s0,16(sp)
    80003858:	64a2                	ld	s1,8(sp)
    8000385a:	6902                	ld	s2,0(sp)
    8000385c:	6105                	addi	sp,sp,32
    8000385e:	8082                	ret
    panic("freeing free block");
    80003860:	00005517          	auipc	a0,0x5
    80003864:	e5850513          	addi	a0,a0,-424 # 800086b8 <syscalls+0x120>
    80003868:	ffffd097          	auipc	ra,0xffffd
    8000386c:	cdc080e7          	jalr	-804(ra) # 80000544 <panic>

0000000080003870 <balloc>:
{
    80003870:	711d                	addi	sp,sp,-96
    80003872:	ec86                	sd	ra,88(sp)
    80003874:	e8a2                	sd	s0,80(sp)
    80003876:	e4a6                	sd	s1,72(sp)
    80003878:	e0ca                	sd	s2,64(sp)
    8000387a:	fc4e                	sd	s3,56(sp)
    8000387c:	f852                	sd	s4,48(sp)
    8000387e:	f456                	sd	s5,40(sp)
    80003880:	f05a                	sd	s6,32(sp)
    80003882:	ec5e                	sd	s7,24(sp)
    80003884:	e862                	sd	s8,16(sp)
    80003886:	e466                	sd	s9,8(sp)
    80003888:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000388a:	0001e797          	auipc	a5,0x1e
    8000388e:	d227a783          	lw	a5,-734(a5) # 800215ac <sb+0x4>
    80003892:	10078163          	beqz	a5,80003994 <balloc+0x124>
    80003896:	8baa                	mv	s7,a0
    80003898:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000389a:	0001eb17          	auipc	s6,0x1e
    8000389e:	d0eb0b13          	addi	s6,s6,-754 # 800215a8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800038a2:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800038a4:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800038a6:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800038a8:	6c89                	lui	s9,0x2
    800038aa:	a061                	j	80003932 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    800038ac:	974a                	add	a4,a4,s2
    800038ae:	8fd5                	or	a5,a5,a3
    800038b0:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800038b4:	854a                	mv	a0,s2
    800038b6:	00001097          	auipc	ra,0x1
    800038ba:	0ac080e7          	jalr	172(ra) # 80004962 <log_write>
        brelse(bp);
    800038be:	854a                	mv	a0,s2
    800038c0:	00000097          	auipc	ra,0x0
    800038c4:	e1e080e7          	jalr	-482(ra) # 800036de <brelse>
  bp = bread(dev, bno);
    800038c8:	85a6                	mv	a1,s1
    800038ca:	855e                	mv	a0,s7
    800038cc:	00000097          	auipc	ra,0x0
    800038d0:	ce2080e7          	jalr	-798(ra) # 800035ae <bread>
    800038d4:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800038d6:	40000613          	li	a2,1024
    800038da:	4581                	li	a1,0
    800038dc:	05850513          	addi	a0,a0,88
    800038e0:	ffffd097          	auipc	ra,0xffffd
    800038e4:	406080e7          	jalr	1030(ra) # 80000ce6 <memset>
  log_write(bp);
    800038e8:	854a                	mv	a0,s2
    800038ea:	00001097          	auipc	ra,0x1
    800038ee:	078080e7          	jalr	120(ra) # 80004962 <log_write>
  brelse(bp);
    800038f2:	854a                	mv	a0,s2
    800038f4:	00000097          	auipc	ra,0x0
    800038f8:	dea080e7          	jalr	-534(ra) # 800036de <brelse>
}
    800038fc:	8526                	mv	a0,s1
    800038fe:	60e6                	ld	ra,88(sp)
    80003900:	6446                	ld	s0,80(sp)
    80003902:	64a6                	ld	s1,72(sp)
    80003904:	6906                	ld	s2,64(sp)
    80003906:	79e2                	ld	s3,56(sp)
    80003908:	7a42                	ld	s4,48(sp)
    8000390a:	7aa2                	ld	s5,40(sp)
    8000390c:	7b02                	ld	s6,32(sp)
    8000390e:	6be2                	ld	s7,24(sp)
    80003910:	6c42                	ld	s8,16(sp)
    80003912:	6ca2                	ld	s9,8(sp)
    80003914:	6125                	addi	sp,sp,96
    80003916:	8082                	ret
    brelse(bp);
    80003918:	854a                	mv	a0,s2
    8000391a:	00000097          	auipc	ra,0x0
    8000391e:	dc4080e7          	jalr	-572(ra) # 800036de <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003922:	015c87bb          	addw	a5,s9,s5
    80003926:	00078a9b          	sext.w	s5,a5
    8000392a:	004b2703          	lw	a4,4(s6)
    8000392e:	06eaf363          	bgeu	s5,a4,80003994 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80003932:	41fad79b          	sraiw	a5,s5,0x1f
    80003936:	0137d79b          	srliw	a5,a5,0x13
    8000393a:	015787bb          	addw	a5,a5,s5
    8000393e:	40d7d79b          	sraiw	a5,a5,0xd
    80003942:	01cb2583          	lw	a1,28(s6)
    80003946:	9dbd                	addw	a1,a1,a5
    80003948:	855e                	mv	a0,s7
    8000394a:	00000097          	auipc	ra,0x0
    8000394e:	c64080e7          	jalr	-924(ra) # 800035ae <bread>
    80003952:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003954:	004b2503          	lw	a0,4(s6)
    80003958:	000a849b          	sext.w	s1,s5
    8000395c:	8662                	mv	a2,s8
    8000395e:	faa4fde3          	bgeu	s1,a0,80003918 <balloc+0xa8>
      m = 1 << (bi % 8);
    80003962:	41f6579b          	sraiw	a5,a2,0x1f
    80003966:	01d7d69b          	srliw	a3,a5,0x1d
    8000396a:	00c6873b          	addw	a4,a3,a2
    8000396e:	00777793          	andi	a5,a4,7
    80003972:	9f95                	subw	a5,a5,a3
    80003974:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003978:	4037571b          	sraiw	a4,a4,0x3
    8000397c:	00e906b3          	add	a3,s2,a4
    80003980:	0586c683          	lbu	a3,88(a3)
    80003984:	00d7f5b3          	and	a1,a5,a3
    80003988:	d195                	beqz	a1,800038ac <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000398a:	2605                	addiw	a2,a2,1
    8000398c:	2485                	addiw	s1,s1,1
    8000398e:	fd4618e3          	bne	a2,s4,8000395e <balloc+0xee>
    80003992:	b759                	j	80003918 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003994:	00005517          	auipc	a0,0x5
    80003998:	d3c50513          	addi	a0,a0,-708 # 800086d0 <syscalls+0x138>
    8000399c:	ffffd097          	auipc	ra,0xffffd
    800039a0:	bf2080e7          	jalr	-1038(ra) # 8000058e <printf>
  return 0;
    800039a4:	4481                	li	s1,0
    800039a6:	bf99                	j	800038fc <balloc+0x8c>

00000000800039a8 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800039a8:	7179                	addi	sp,sp,-48
    800039aa:	f406                	sd	ra,40(sp)
    800039ac:	f022                	sd	s0,32(sp)
    800039ae:	ec26                	sd	s1,24(sp)
    800039b0:	e84a                	sd	s2,16(sp)
    800039b2:	e44e                	sd	s3,8(sp)
    800039b4:	e052                	sd	s4,0(sp)
    800039b6:	1800                	addi	s0,sp,48
    800039b8:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800039ba:	47ad                	li	a5,11
    800039bc:	02b7e763          	bltu	a5,a1,800039ea <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    800039c0:	02059493          	slli	s1,a1,0x20
    800039c4:	9081                	srli	s1,s1,0x20
    800039c6:	048a                	slli	s1,s1,0x2
    800039c8:	94aa                	add	s1,s1,a0
    800039ca:	0504a903          	lw	s2,80(s1)
    800039ce:	06091e63          	bnez	s2,80003a4a <bmap+0xa2>
      addr = balloc(ip->dev);
    800039d2:	4108                	lw	a0,0(a0)
    800039d4:	00000097          	auipc	ra,0x0
    800039d8:	e9c080e7          	jalr	-356(ra) # 80003870 <balloc>
    800039dc:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800039e0:	06090563          	beqz	s2,80003a4a <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    800039e4:	0524a823          	sw	s2,80(s1)
    800039e8:	a08d                	j	80003a4a <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    800039ea:	ff45849b          	addiw	s1,a1,-12
    800039ee:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800039f2:	0ff00793          	li	a5,255
    800039f6:	08e7e563          	bltu	a5,a4,80003a80 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800039fa:	08052903          	lw	s2,128(a0)
    800039fe:	00091d63          	bnez	s2,80003a18 <bmap+0x70>
      addr = balloc(ip->dev);
    80003a02:	4108                	lw	a0,0(a0)
    80003a04:	00000097          	auipc	ra,0x0
    80003a08:	e6c080e7          	jalr	-404(ra) # 80003870 <balloc>
    80003a0c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003a10:	02090d63          	beqz	s2,80003a4a <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003a14:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003a18:	85ca                	mv	a1,s2
    80003a1a:	0009a503          	lw	a0,0(s3)
    80003a1e:	00000097          	auipc	ra,0x0
    80003a22:	b90080e7          	jalr	-1136(ra) # 800035ae <bread>
    80003a26:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003a28:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003a2c:	02049593          	slli	a1,s1,0x20
    80003a30:	9181                	srli	a1,a1,0x20
    80003a32:	058a                	slli	a1,a1,0x2
    80003a34:	00b784b3          	add	s1,a5,a1
    80003a38:	0004a903          	lw	s2,0(s1)
    80003a3c:	02090063          	beqz	s2,80003a5c <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003a40:	8552                	mv	a0,s4
    80003a42:	00000097          	auipc	ra,0x0
    80003a46:	c9c080e7          	jalr	-868(ra) # 800036de <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003a4a:	854a                	mv	a0,s2
    80003a4c:	70a2                	ld	ra,40(sp)
    80003a4e:	7402                	ld	s0,32(sp)
    80003a50:	64e2                	ld	s1,24(sp)
    80003a52:	6942                	ld	s2,16(sp)
    80003a54:	69a2                	ld	s3,8(sp)
    80003a56:	6a02                	ld	s4,0(sp)
    80003a58:	6145                	addi	sp,sp,48
    80003a5a:	8082                	ret
      addr = balloc(ip->dev);
    80003a5c:	0009a503          	lw	a0,0(s3)
    80003a60:	00000097          	auipc	ra,0x0
    80003a64:	e10080e7          	jalr	-496(ra) # 80003870 <balloc>
    80003a68:	0005091b          	sext.w	s2,a0
      if(addr){
    80003a6c:	fc090ae3          	beqz	s2,80003a40 <bmap+0x98>
        a[bn] = addr;
    80003a70:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003a74:	8552                	mv	a0,s4
    80003a76:	00001097          	auipc	ra,0x1
    80003a7a:	eec080e7          	jalr	-276(ra) # 80004962 <log_write>
    80003a7e:	b7c9                	j	80003a40 <bmap+0x98>
  panic("bmap: out of range");
    80003a80:	00005517          	auipc	a0,0x5
    80003a84:	c6850513          	addi	a0,a0,-920 # 800086e8 <syscalls+0x150>
    80003a88:	ffffd097          	auipc	ra,0xffffd
    80003a8c:	abc080e7          	jalr	-1348(ra) # 80000544 <panic>

0000000080003a90 <iget>:
{
    80003a90:	7179                	addi	sp,sp,-48
    80003a92:	f406                	sd	ra,40(sp)
    80003a94:	f022                	sd	s0,32(sp)
    80003a96:	ec26                	sd	s1,24(sp)
    80003a98:	e84a                	sd	s2,16(sp)
    80003a9a:	e44e                	sd	s3,8(sp)
    80003a9c:	e052                	sd	s4,0(sp)
    80003a9e:	1800                	addi	s0,sp,48
    80003aa0:	89aa                	mv	s3,a0
    80003aa2:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003aa4:	0001e517          	auipc	a0,0x1e
    80003aa8:	b2450513          	addi	a0,a0,-1244 # 800215c8 <itable>
    80003aac:	ffffd097          	auipc	ra,0xffffd
    80003ab0:	13e080e7          	jalr	318(ra) # 80000bea <acquire>
  empty = 0;
    80003ab4:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003ab6:	0001e497          	auipc	s1,0x1e
    80003aba:	b2a48493          	addi	s1,s1,-1238 # 800215e0 <itable+0x18>
    80003abe:	0001f697          	auipc	a3,0x1f
    80003ac2:	5b268693          	addi	a3,a3,1458 # 80023070 <log>
    80003ac6:	a039                	j	80003ad4 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003ac8:	02090b63          	beqz	s2,80003afe <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003acc:	08848493          	addi	s1,s1,136
    80003ad0:	02d48a63          	beq	s1,a3,80003b04 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003ad4:	449c                	lw	a5,8(s1)
    80003ad6:	fef059e3          	blez	a5,80003ac8 <iget+0x38>
    80003ada:	4098                	lw	a4,0(s1)
    80003adc:	ff3716e3          	bne	a4,s3,80003ac8 <iget+0x38>
    80003ae0:	40d8                	lw	a4,4(s1)
    80003ae2:	ff4713e3          	bne	a4,s4,80003ac8 <iget+0x38>
      ip->ref++;
    80003ae6:	2785                	addiw	a5,a5,1
    80003ae8:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003aea:	0001e517          	auipc	a0,0x1e
    80003aee:	ade50513          	addi	a0,a0,-1314 # 800215c8 <itable>
    80003af2:	ffffd097          	auipc	ra,0xffffd
    80003af6:	1ac080e7          	jalr	428(ra) # 80000c9e <release>
      return ip;
    80003afa:	8926                	mv	s2,s1
    80003afc:	a03d                	j	80003b2a <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003afe:	f7f9                	bnez	a5,80003acc <iget+0x3c>
    80003b00:	8926                	mv	s2,s1
    80003b02:	b7e9                	j	80003acc <iget+0x3c>
  if(empty == 0)
    80003b04:	02090c63          	beqz	s2,80003b3c <iget+0xac>
  ip->dev = dev;
    80003b08:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003b0c:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003b10:	4785                	li	a5,1
    80003b12:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003b16:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003b1a:	0001e517          	auipc	a0,0x1e
    80003b1e:	aae50513          	addi	a0,a0,-1362 # 800215c8 <itable>
    80003b22:	ffffd097          	auipc	ra,0xffffd
    80003b26:	17c080e7          	jalr	380(ra) # 80000c9e <release>
}
    80003b2a:	854a                	mv	a0,s2
    80003b2c:	70a2                	ld	ra,40(sp)
    80003b2e:	7402                	ld	s0,32(sp)
    80003b30:	64e2                	ld	s1,24(sp)
    80003b32:	6942                	ld	s2,16(sp)
    80003b34:	69a2                	ld	s3,8(sp)
    80003b36:	6a02                	ld	s4,0(sp)
    80003b38:	6145                	addi	sp,sp,48
    80003b3a:	8082                	ret
    panic("iget: no inodes");
    80003b3c:	00005517          	auipc	a0,0x5
    80003b40:	bc450513          	addi	a0,a0,-1084 # 80008700 <syscalls+0x168>
    80003b44:	ffffd097          	auipc	ra,0xffffd
    80003b48:	a00080e7          	jalr	-1536(ra) # 80000544 <panic>

0000000080003b4c <fsinit>:
fsinit(int dev) {
    80003b4c:	7179                	addi	sp,sp,-48
    80003b4e:	f406                	sd	ra,40(sp)
    80003b50:	f022                	sd	s0,32(sp)
    80003b52:	ec26                	sd	s1,24(sp)
    80003b54:	e84a                	sd	s2,16(sp)
    80003b56:	e44e                	sd	s3,8(sp)
    80003b58:	1800                	addi	s0,sp,48
    80003b5a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003b5c:	4585                	li	a1,1
    80003b5e:	00000097          	auipc	ra,0x0
    80003b62:	a50080e7          	jalr	-1456(ra) # 800035ae <bread>
    80003b66:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003b68:	0001e997          	auipc	s3,0x1e
    80003b6c:	a4098993          	addi	s3,s3,-1472 # 800215a8 <sb>
    80003b70:	02000613          	li	a2,32
    80003b74:	05850593          	addi	a1,a0,88
    80003b78:	854e                	mv	a0,s3
    80003b7a:	ffffd097          	auipc	ra,0xffffd
    80003b7e:	1cc080e7          	jalr	460(ra) # 80000d46 <memmove>
  brelse(bp);
    80003b82:	8526                	mv	a0,s1
    80003b84:	00000097          	auipc	ra,0x0
    80003b88:	b5a080e7          	jalr	-1190(ra) # 800036de <brelse>
  if(sb.magic != FSMAGIC)
    80003b8c:	0009a703          	lw	a4,0(s3)
    80003b90:	102037b7          	lui	a5,0x10203
    80003b94:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003b98:	02f71263          	bne	a4,a5,80003bbc <fsinit+0x70>
  initlog(dev, &sb);
    80003b9c:	0001e597          	auipc	a1,0x1e
    80003ba0:	a0c58593          	addi	a1,a1,-1524 # 800215a8 <sb>
    80003ba4:	854a                	mv	a0,s2
    80003ba6:	00001097          	auipc	ra,0x1
    80003baa:	b40080e7          	jalr	-1216(ra) # 800046e6 <initlog>
}
    80003bae:	70a2                	ld	ra,40(sp)
    80003bb0:	7402                	ld	s0,32(sp)
    80003bb2:	64e2                	ld	s1,24(sp)
    80003bb4:	6942                	ld	s2,16(sp)
    80003bb6:	69a2                	ld	s3,8(sp)
    80003bb8:	6145                	addi	sp,sp,48
    80003bba:	8082                	ret
    panic("invalid file system");
    80003bbc:	00005517          	auipc	a0,0x5
    80003bc0:	b5450513          	addi	a0,a0,-1196 # 80008710 <syscalls+0x178>
    80003bc4:	ffffd097          	auipc	ra,0xffffd
    80003bc8:	980080e7          	jalr	-1664(ra) # 80000544 <panic>

0000000080003bcc <iinit>:
{
    80003bcc:	7179                	addi	sp,sp,-48
    80003bce:	f406                	sd	ra,40(sp)
    80003bd0:	f022                	sd	s0,32(sp)
    80003bd2:	ec26                	sd	s1,24(sp)
    80003bd4:	e84a                	sd	s2,16(sp)
    80003bd6:	e44e                	sd	s3,8(sp)
    80003bd8:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003bda:	00005597          	auipc	a1,0x5
    80003bde:	b4e58593          	addi	a1,a1,-1202 # 80008728 <syscalls+0x190>
    80003be2:	0001e517          	auipc	a0,0x1e
    80003be6:	9e650513          	addi	a0,a0,-1562 # 800215c8 <itable>
    80003bea:	ffffd097          	auipc	ra,0xffffd
    80003bee:	f70080e7          	jalr	-144(ra) # 80000b5a <initlock>
  for(i = 0; i < NINODE; i++) {
    80003bf2:	0001e497          	auipc	s1,0x1e
    80003bf6:	9fe48493          	addi	s1,s1,-1538 # 800215f0 <itable+0x28>
    80003bfa:	0001f997          	auipc	s3,0x1f
    80003bfe:	48698993          	addi	s3,s3,1158 # 80023080 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003c02:	00005917          	auipc	s2,0x5
    80003c06:	b2e90913          	addi	s2,s2,-1234 # 80008730 <syscalls+0x198>
    80003c0a:	85ca                	mv	a1,s2
    80003c0c:	8526                	mv	a0,s1
    80003c0e:	00001097          	auipc	ra,0x1
    80003c12:	e3a080e7          	jalr	-454(ra) # 80004a48 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003c16:	08848493          	addi	s1,s1,136
    80003c1a:	ff3498e3          	bne	s1,s3,80003c0a <iinit+0x3e>
}
    80003c1e:	70a2                	ld	ra,40(sp)
    80003c20:	7402                	ld	s0,32(sp)
    80003c22:	64e2                	ld	s1,24(sp)
    80003c24:	6942                	ld	s2,16(sp)
    80003c26:	69a2                	ld	s3,8(sp)
    80003c28:	6145                	addi	sp,sp,48
    80003c2a:	8082                	ret

0000000080003c2c <ialloc>:
{
    80003c2c:	715d                	addi	sp,sp,-80
    80003c2e:	e486                	sd	ra,72(sp)
    80003c30:	e0a2                	sd	s0,64(sp)
    80003c32:	fc26                	sd	s1,56(sp)
    80003c34:	f84a                	sd	s2,48(sp)
    80003c36:	f44e                	sd	s3,40(sp)
    80003c38:	f052                	sd	s4,32(sp)
    80003c3a:	ec56                	sd	s5,24(sp)
    80003c3c:	e85a                	sd	s6,16(sp)
    80003c3e:	e45e                	sd	s7,8(sp)
    80003c40:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003c42:	0001e717          	auipc	a4,0x1e
    80003c46:	97272703          	lw	a4,-1678(a4) # 800215b4 <sb+0xc>
    80003c4a:	4785                	li	a5,1
    80003c4c:	04e7fa63          	bgeu	a5,a4,80003ca0 <ialloc+0x74>
    80003c50:	8aaa                	mv	s5,a0
    80003c52:	8bae                	mv	s7,a1
    80003c54:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003c56:	0001ea17          	auipc	s4,0x1e
    80003c5a:	952a0a13          	addi	s4,s4,-1710 # 800215a8 <sb>
    80003c5e:	00048b1b          	sext.w	s6,s1
    80003c62:	0044d593          	srli	a1,s1,0x4
    80003c66:	018a2783          	lw	a5,24(s4)
    80003c6a:	9dbd                	addw	a1,a1,a5
    80003c6c:	8556                	mv	a0,s5
    80003c6e:	00000097          	auipc	ra,0x0
    80003c72:	940080e7          	jalr	-1728(ra) # 800035ae <bread>
    80003c76:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003c78:	05850993          	addi	s3,a0,88
    80003c7c:	00f4f793          	andi	a5,s1,15
    80003c80:	079a                	slli	a5,a5,0x6
    80003c82:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003c84:	00099783          	lh	a5,0(s3)
    80003c88:	c3a1                	beqz	a5,80003cc8 <ialloc+0x9c>
    brelse(bp);
    80003c8a:	00000097          	auipc	ra,0x0
    80003c8e:	a54080e7          	jalr	-1452(ra) # 800036de <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003c92:	0485                	addi	s1,s1,1
    80003c94:	00ca2703          	lw	a4,12(s4)
    80003c98:	0004879b          	sext.w	a5,s1
    80003c9c:	fce7e1e3          	bltu	a5,a4,80003c5e <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003ca0:	00005517          	auipc	a0,0x5
    80003ca4:	a9850513          	addi	a0,a0,-1384 # 80008738 <syscalls+0x1a0>
    80003ca8:	ffffd097          	auipc	ra,0xffffd
    80003cac:	8e6080e7          	jalr	-1818(ra) # 8000058e <printf>
  return 0;
    80003cb0:	4501                	li	a0,0
}
    80003cb2:	60a6                	ld	ra,72(sp)
    80003cb4:	6406                	ld	s0,64(sp)
    80003cb6:	74e2                	ld	s1,56(sp)
    80003cb8:	7942                	ld	s2,48(sp)
    80003cba:	79a2                	ld	s3,40(sp)
    80003cbc:	7a02                	ld	s4,32(sp)
    80003cbe:	6ae2                	ld	s5,24(sp)
    80003cc0:	6b42                	ld	s6,16(sp)
    80003cc2:	6ba2                	ld	s7,8(sp)
    80003cc4:	6161                	addi	sp,sp,80
    80003cc6:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003cc8:	04000613          	li	a2,64
    80003ccc:	4581                	li	a1,0
    80003cce:	854e                	mv	a0,s3
    80003cd0:	ffffd097          	auipc	ra,0xffffd
    80003cd4:	016080e7          	jalr	22(ra) # 80000ce6 <memset>
      dip->type = type;
    80003cd8:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003cdc:	854a                	mv	a0,s2
    80003cde:	00001097          	auipc	ra,0x1
    80003ce2:	c84080e7          	jalr	-892(ra) # 80004962 <log_write>
      brelse(bp);
    80003ce6:	854a                	mv	a0,s2
    80003ce8:	00000097          	auipc	ra,0x0
    80003cec:	9f6080e7          	jalr	-1546(ra) # 800036de <brelse>
      return iget(dev, inum);
    80003cf0:	85da                	mv	a1,s6
    80003cf2:	8556                	mv	a0,s5
    80003cf4:	00000097          	auipc	ra,0x0
    80003cf8:	d9c080e7          	jalr	-612(ra) # 80003a90 <iget>
    80003cfc:	bf5d                	j	80003cb2 <ialloc+0x86>

0000000080003cfe <iupdate>:
{
    80003cfe:	1101                	addi	sp,sp,-32
    80003d00:	ec06                	sd	ra,24(sp)
    80003d02:	e822                	sd	s0,16(sp)
    80003d04:	e426                	sd	s1,8(sp)
    80003d06:	e04a                	sd	s2,0(sp)
    80003d08:	1000                	addi	s0,sp,32
    80003d0a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003d0c:	415c                	lw	a5,4(a0)
    80003d0e:	0047d79b          	srliw	a5,a5,0x4
    80003d12:	0001e597          	auipc	a1,0x1e
    80003d16:	8ae5a583          	lw	a1,-1874(a1) # 800215c0 <sb+0x18>
    80003d1a:	9dbd                	addw	a1,a1,a5
    80003d1c:	4108                	lw	a0,0(a0)
    80003d1e:	00000097          	auipc	ra,0x0
    80003d22:	890080e7          	jalr	-1904(ra) # 800035ae <bread>
    80003d26:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003d28:	05850793          	addi	a5,a0,88
    80003d2c:	40c8                	lw	a0,4(s1)
    80003d2e:	893d                	andi	a0,a0,15
    80003d30:	051a                	slli	a0,a0,0x6
    80003d32:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003d34:	04449703          	lh	a4,68(s1)
    80003d38:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003d3c:	04649703          	lh	a4,70(s1)
    80003d40:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003d44:	04849703          	lh	a4,72(s1)
    80003d48:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003d4c:	04a49703          	lh	a4,74(s1)
    80003d50:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003d54:	44f8                	lw	a4,76(s1)
    80003d56:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003d58:	03400613          	li	a2,52
    80003d5c:	05048593          	addi	a1,s1,80
    80003d60:	0531                	addi	a0,a0,12
    80003d62:	ffffd097          	auipc	ra,0xffffd
    80003d66:	fe4080e7          	jalr	-28(ra) # 80000d46 <memmove>
  log_write(bp);
    80003d6a:	854a                	mv	a0,s2
    80003d6c:	00001097          	auipc	ra,0x1
    80003d70:	bf6080e7          	jalr	-1034(ra) # 80004962 <log_write>
  brelse(bp);
    80003d74:	854a                	mv	a0,s2
    80003d76:	00000097          	auipc	ra,0x0
    80003d7a:	968080e7          	jalr	-1688(ra) # 800036de <brelse>
}
    80003d7e:	60e2                	ld	ra,24(sp)
    80003d80:	6442                	ld	s0,16(sp)
    80003d82:	64a2                	ld	s1,8(sp)
    80003d84:	6902                	ld	s2,0(sp)
    80003d86:	6105                	addi	sp,sp,32
    80003d88:	8082                	ret

0000000080003d8a <idup>:
{
    80003d8a:	1101                	addi	sp,sp,-32
    80003d8c:	ec06                	sd	ra,24(sp)
    80003d8e:	e822                	sd	s0,16(sp)
    80003d90:	e426                	sd	s1,8(sp)
    80003d92:	1000                	addi	s0,sp,32
    80003d94:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003d96:	0001e517          	auipc	a0,0x1e
    80003d9a:	83250513          	addi	a0,a0,-1998 # 800215c8 <itable>
    80003d9e:	ffffd097          	auipc	ra,0xffffd
    80003da2:	e4c080e7          	jalr	-436(ra) # 80000bea <acquire>
  ip->ref++;
    80003da6:	449c                	lw	a5,8(s1)
    80003da8:	2785                	addiw	a5,a5,1
    80003daa:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003dac:	0001e517          	auipc	a0,0x1e
    80003db0:	81c50513          	addi	a0,a0,-2020 # 800215c8 <itable>
    80003db4:	ffffd097          	auipc	ra,0xffffd
    80003db8:	eea080e7          	jalr	-278(ra) # 80000c9e <release>
}
    80003dbc:	8526                	mv	a0,s1
    80003dbe:	60e2                	ld	ra,24(sp)
    80003dc0:	6442                	ld	s0,16(sp)
    80003dc2:	64a2                	ld	s1,8(sp)
    80003dc4:	6105                	addi	sp,sp,32
    80003dc6:	8082                	ret

0000000080003dc8 <ilock>:
{
    80003dc8:	1101                	addi	sp,sp,-32
    80003dca:	ec06                	sd	ra,24(sp)
    80003dcc:	e822                	sd	s0,16(sp)
    80003dce:	e426                	sd	s1,8(sp)
    80003dd0:	e04a                	sd	s2,0(sp)
    80003dd2:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003dd4:	c115                	beqz	a0,80003df8 <ilock+0x30>
    80003dd6:	84aa                	mv	s1,a0
    80003dd8:	451c                	lw	a5,8(a0)
    80003dda:	00f05f63          	blez	a5,80003df8 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003dde:	0541                	addi	a0,a0,16
    80003de0:	00001097          	auipc	ra,0x1
    80003de4:	ca2080e7          	jalr	-862(ra) # 80004a82 <acquiresleep>
  if(ip->valid == 0){
    80003de8:	40bc                	lw	a5,64(s1)
    80003dea:	cf99                	beqz	a5,80003e08 <ilock+0x40>
}
    80003dec:	60e2                	ld	ra,24(sp)
    80003dee:	6442                	ld	s0,16(sp)
    80003df0:	64a2                	ld	s1,8(sp)
    80003df2:	6902                	ld	s2,0(sp)
    80003df4:	6105                	addi	sp,sp,32
    80003df6:	8082                	ret
    panic("ilock");
    80003df8:	00005517          	auipc	a0,0x5
    80003dfc:	95850513          	addi	a0,a0,-1704 # 80008750 <syscalls+0x1b8>
    80003e00:	ffffc097          	auipc	ra,0xffffc
    80003e04:	744080e7          	jalr	1860(ra) # 80000544 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003e08:	40dc                	lw	a5,4(s1)
    80003e0a:	0047d79b          	srliw	a5,a5,0x4
    80003e0e:	0001d597          	auipc	a1,0x1d
    80003e12:	7b25a583          	lw	a1,1970(a1) # 800215c0 <sb+0x18>
    80003e16:	9dbd                	addw	a1,a1,a5
    80003e18:	4088                	lw	a0,0(s1)
    80003e1a:	fffff097          	auipc	ra,0xfffff
    80003e1e:	794080e7          	jalr	1940(ra) # 800035ae <bread>
    80003e22:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003e24:	05850593          	addi	a1,a0,88
    80003e28:	40dc                	lw	a5,4(s1)
    80003e2a:	8bbd                	andi	a5,a5,15
    80003e2c:	079a                	slli	a5,a5,0x6
    80003e2e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003e30:	00059783          	lh	a5,0(a1)
    80003e34:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003e38:	00259783          	lh	a5,2(a1)
    80003e3c:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003e40:	00459783          	lh	a5,4(a1)
    80003e44:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003e48:	00659783          	lh	a5,6(a1)
    80003e4c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003e50:	459c                	lw	a5,8(a1)
    80003e52:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003e54:	03400613          	li	a2,52
    80003e58:	05b1                	addi	a1,a1,12
    80003e5a:	05048513          	addi	a0,s1,80
    80003e5e:	ffffd097          	auipc	ra,0xffffd
    80003e62:	ee8080e7          	jalr	-280(ra) # 80000d46 <memmove>
    brelse(bp);
    80003e66:	854a                	mv	a0,s2
    80003e68:	00000097          	auipc	ra,0x0
    80003e6c:	876080e7          	jalr	-1930(ra) # 800036de <brelse>
    ip->valid = 1;
    80003e70:	4785                	li	a5,1
    80003e72:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003e74:	04449783          	lh	a5,68(s1)
    80003e78:	fbb5                	bnez	a5,80003dec <ilock+0x24>
      panic("ilock: no type");
    80003e7a:	00005517          	auipc	a0,0x5
    80003e7e:	8de50513          	addi	a0,a0,-1826 # 80008758 <syscalls+0x1c0>
    80003e82:	ffffc097          	auipc	ra,0xffffc
    80003e86:	6c2080e7          	jalr	1730(ra) # 80000544 <panic>

0000000080003e8a <iunlock>:
{
    80003e8a:	1101                	addi	sp,sp,-32
    80003e8c:	ec06                	sd	ra,24(sp)
    80003e8e:	e822                	sd	s0,16(sp)
    80003e90:	e426                	sd	s1,8(sp)
    80003e92:	e04a                	sd	s2,0(sp)
    80003e94:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003e96:	c905                	beqz	a0,80003ec6 <iunlock+0x3c>
    80003e98:	84aa                	mv	s1,a0
    80003e9a:	01050913          	addi	s2,a0,16
    80003e9e:	854a                	mv	a0,s2
    80003ea0:	00001097          	auipc	ra,0x1
    80003ea4:	c7c080e7          	jalr	-900(ra) # 80004b1c <holdingsleep>
    80003ea8:	cd19                	beqz	a0,80003ec6 <iunlock+0x3c>
    80003eaa:	449c                	lw	a5,8(s1)
    80003eac:	00f05d63          	blez	a5,80003ec6 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003eb0:	854a                	mv	a0,s2
    80003eb2:	00001097          	auipc	ra,0x1
    80003eb6:	c26080e7          	jalr	-986(ra) # 80004ad8 <releasesleep>
}
    80003eba:	60e2                	ld	ra,24(sp)
    80003ebc:	6442                	ld	s0,16(sp)
    80003ebe:	64a2                	ld	s1,8(sp)
    80003ec0:	6902                	ld	s2,0(sp)
    80003ec2:	6105                	addi	sp,sp,32
    80003ec4:	8082                	ret
    panic("iunlock");
    80003ec6:	00005517          	auipc	a0,0x5
    80003eca:	8a250513          	addi	a0,a0,-1886 # 80008768 <syscalls+0x1d0>
    80003ece:	ffffc097          	auipc	ra,0xffffc
    80003ed2:	676080e7          	jalr	1654(ra) # 80000544 <panic>

0000000080003ed6 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003ed6:	7179                	addi	sp,sp,-48
    80003ed8:	f406                	sd	ra,40(sp)
    80003eda:	f022                	sd	s0,32(sp)
    80003edc:	ec26                	sd	s1,24(sp)
    80003ede:	e84a                	sd	s2,16(sp)
    80003ee0:	e44e                	sd	s3,8(sp)
    80003ee2:	e052                	sd	s4,0(sp)
    80003ee4:	1800                	addi	s0,sp,48
    80003ee6:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003ee8:	05050493          	addi	s1,a0,80
    80003eec:	08050913          	addi	s2,a0,128
    80003ef0:	a021                	j	80003ef8 <itrunc+0x22>
    80003ef2:	0491                	addi	s1,s1,4
    80003ef4:	01248d63          	beq	s1,s2,80003f0e <itrunc+0x38>
    if(ip->addrs[i]){
    80003ef8:	408c                	lw	a1,0(s1)
    80003efa:	dde5                	beqz	a1,80003ef2 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003efc:	0009a503          	lw	a0,0(s3)
    80003f00:	00000097          	auipc	ra,0x0
    80003f04:	8f4080e7          	jalr	-1804(ra) # 800037f4 <bfree>
      ip->addrs[i] = 0;
    80003f08:	0004a023          	sw	zero,0(s1)
    80003f0c:	b7dd                	j	80003ef2 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003f0e:	0809a583          	lw	a1,128(s3)
    80003f12:	e185                	bnez	a1,80003f32 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003f14:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003f18:	854e                	mv	a0,s3
    80003f1a:	00000097          	auipc	ra,0x0
    80003f1e:	de4080e7          	jalr	-540(ra) # 80003cfe <iupdate>
}
    80003f22:	70a2                	ld	ra,40(sp)
    80003f24:	7402                	ld	s0,32(sp)
    80003f26:	64e2                	ld	s1,24(sp)
    80003f28:	6942                	ld	s2,16(sp)
    80003f2a:	69a2                	ld	s3,8(sp)
    80003f2c:	6a02                	ld	s4,0(sp)
    80003f2e:	6145                	addi	sp,sp,48
    80003f30:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003f32:	0009a503          	lw	a0,0(s3)
    80003f36:	fffff097          	auipc	ra,0xfffff
    80003f3a:	678080e7          	jalr	1656(ra) # 800035ae <bread>
    80003f3e:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003f40:	05850493          	addi	s1,a0,88
    80003f44:	45850913          	addi	s2,a0,1112
    80003f48:	a811                	j	80003f5c <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003f4a:	0009a503          	lw	a0,0(s3)
    80003f4e:	00000097          	auipc	ra,0x0
    80003f52:	8a6080e7          	jalr	-1882(ra) # 800037f4 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003f56:	0491                	addi	s1,s1,4
    80003f58:	01248563          	beq	s1,s2,80003f62 <itrunc+0x8c>
      if(a[j])
    80003f5c:	408c                	lw	a1,0(s1)
    80003f5e:	dde5                	beqz	a1,80003f56 <itrunc+0x80>
    80003f60:	b7ed                	j	80003f4a <itrunc+0x74>
    brelse(bp);
    80003f62:	8552                	mv	a0,s4
    80003f64:	fffff097          	auipc	ra,0xfffff
    80003f68:	77a080e7          	jalr	1914(ra) # 800036de <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003f6c:	0809a583          	lw	a1,128(s3)
    80003f70:	0009a503          	lw	a0,0(s3)
    80003f74:	00000097          	auipc	ra,0x0
    80003f78:	880080e7          	jalr	-1920(ra) # 800037f4 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003f7c:	0809a023          	sw	zero,128(s3)
    80003f80:	bf51                	j	80003f14 <itrunc+0x3e>

0000000080003f82 <iput>:
{
    80003f82:	1101                	addi	sp,sp,-32
    80003f84:	ec06                	sd	ra,24(sp)
    80003f86:	e822                	sd	s0,16(sp)
    80003f88:	e426                	sd	s1,8(sp)
    80003f8a:	e04a                	sd	s2,0(sp)
    80003f8c:	1000                	addi	s0,sp,32
    80003f8e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003f90:	0001d517          	auipc	a0,0x1d
    80003f94:	63850513          	addi	a0,a0,1592 # 800215c8 <itable>
    80003f98:	ffffd097          	auipc	ra,0xffffd
    80003f9c:	c52080e7          	jalr	-942(ra) # 80000bea <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003fa0:	4498                	lw	a4,8(s1)
    80003fa2:	4785                	li	a5,1
    80003fa4:	02f70363          	beq	a4,a5,80003fca <iput+0x48>
  ip->ref--;
    80003fa8:	449c                	lw	a5,8(s1)
    80003faa:	37fd                	addiw	a5,a5,-1
    80003fac:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003fae:	0001d517          	auipc	a0,0x1d
    80003fb2:	61a50513          	addi	a0,a0,1562 # 800215c8 <itable>
    80003fb6:	ffffd097          	auipc	ra,0xffffd
    80003fba:	ce8080e7          	jalr	-792(ra) # 80000c9e <release>
}
    80003fbe:	60e2                	ld	ra,24(sp)
    80003fc0:	6442                	ld	s0,16(sp)
    80003fc2:	64a2                	ld	s1,8(sp)
    80003fc4:	6902                	ld	s2,0(sp)
    80003fc6:	6105                	addi	sp,sp,32
    80003fc8:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003fca:	40bc                	lw	a5,64(s1)
    80003fcc:	dff1                	beqz	a5,80003fa8 <iput+0x26>
    80003fce:	04a49783          	lh	a5,74(s1)
    80003fd2:	fbf9                	bnez	a5,80003fa8 <iput+0x26>
    acquiresleep(&ip->lock);
    80003fd4:	01048913          	addi	s2,s1,16
    80003fd8:	854a                	mv	a0,s2
    80003fda:	00001097          	auipc	ra,0x1
    80003fde:	aa8080e7          	jalr	-1368(ra) # 80004a82 <acquiresleep>
    release(&itable.lock);
    80003fe2:	0001d517          	auipc	a0,0x1d
    80003fe6:	5e650513          	addi	a0,a0,1510 # 800215c8 <itable>
    80003fea:	ffffd097          	auipc	ra,0xffffd
    80003fee:	cb4080e7          	jalr	-844(ra) # 80000c9e <release>
    itrunc(ip);
    80003ff2:	8526                	mv	a0,s1
    80003ff4:	00000097          	auipc	ra,0x0
    80003ff8:	ee2080e7          	jalr	-286(ra) # 80003ed6 <itrunc>
    ip->type = 0;
    80003ffc:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80004000:	8526                	mv	a0,s1
    80004002:	00000097          	auipc	ra,0x0
    80004006:	cfc080e7          	jalr	-772(ra) # 80003cfe <iupdate>
    ip->valid = 0;
    8000400a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000400e:	854a                	mv	a0,s2
    80004010:	00001097          	auipc	ra,0x1
    80004014:	ac8080e7          	jalr	-1336(ra) # 80004ad8 <releasesleep>
    acquire(&itable.lock);
    80004018:	0001d517          	auipc	a0,0x1d
    8000401c:	5b050513          	addi	a0,a0,1456 # 800215c8 <itable>
    80004020:	ffffd097          	auipc	ra,0xffffd
    80004024:	bca080e7          	jalr	-1078(ra) # 80000bea <acquire>
    80004028:	b741                	j	80003fa8 <iput+0x26>

000000008000402a <iunlockput>:
{
    8000402a:	1101                	addi	sp,sp,-32
    8000402c:	ec06                	sd	ra,24(sp)
    8000402e:	e822                	sd	s0,16(sp)
    80004030:	e426                	sd	s1,8(sp)
    80004032:	1000                	addi	s0,sp,32
    80004034:	84aa                	mv	s1,a0
  iunlock(ip);
    80004036:	00000097          	auipc	ra,0x0
    8000403a:	e54080e7          	jalr	-428(ra) # 80003e8a <iunlock>
  iput(ip);
    8000403e:	8526                	mv	a0,s1
    80004040:	00000097          	auipc	ra,0x0
    80004044:	f42080e7          	jalr	-190(ra) # 80003f82 <iput>
}
    80004048:	60e2                	ld	ra,24(sp)
    8000404a:	6442                	ld	s0,16(sp)
    8000404c:	64a2                	ld	s1,8(sp)
    8000404e:	6105                	addi	sp,sp,32
    80004050:	8082                	ret

0000000080004052 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80004052:	1141                	addi	sp,sp,-16
    80004054:	e422                	sd	s0,8(sp)
    80004056:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004058:	411c                	lw	a5,0(a0)
    8000405a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000405c:	415c                	lw	a5,4(a0)
    8000405e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004060:	04451783          	lh	a5,68(a0)
    80004064:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004068:	04a51783          	lh	a5,74(a0)
    8000406c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004070:	04c56783          	lwu	a5,76(a0)
    80004074:	e99c                	sd	a5,16(a1)
}
    80004076:	6422                	ld	s0,8(sp)
    80004078:	0141                	addi	sp,sp,16
    8000407a:	8082                	ret

000000008000407c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000407c:	457c                	lw	a5,76(a0)
    8000407e:	0ed7e963          	bltu	a5,a3,80004170 <readi+0xf4>
{
    80004082:	7159                	addi	sp,sp,-112
    80004084:	f486                	sd	ra,104(sp)
    80004086:	f0a2                	sd	s0,96(sp)
    80004088:	eca6                	sd	s1,88(sp)
    8000408a:	e8ca                	sd	s2,80(sp)
    8000408c:	e4ce                	sd	s3,72(sp)
    8000408e:	e0d2                	sd	s4,64(sp)
    80004090:	fc56                	sd	s5,56(sp)
    80004092:	f85a                	sd	s6,48(sp)
    80004094:	f45e                	sd	s7,40(sp)
    80004096:	f062                	sd	s8,32(sp)
    80004098:	ec66                	sd	s9,24(sp)
    8000409a:	e86a                	sd	s10,16(sp)
    8000409c:	e46e                	sd	s11,8(sp)
    8000409e:	1880                	addi	s0,sp,112
    800040a0:	8b2a                	mv	s6,a0
    800040a2:	8bae                	mv	s7,a1
    800040a4:	8a32                	mv	s4,a2
    800040a6:	84b6                	mv	s1,a3
    800040a8:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800040aa:	9f35                	addw	a4,a4,a3
    return 0;
    800040ac:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800040ae:	0ad76063          	bltu	a4,a3,8000414e <readi+0xd2>
  if(off + n > ip->size)
    800040b2:	00e7f463          	bgeu	a5,a4,800040ba <readi+0x3e>
    n = ip->size - off;
    800040b6:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800040ba:	0a0a8963          	beqz	s5,8000416c <readi+0xf0>
    800040be:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800040c0:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800040c4:	5c7d                	li	s8,-1
    800040c6:	a82d                	j	80004100 <readi+0x84>
    800040c8:	020d1d93          	slli	s11,s10,0x20
    800040cc:	020ddd93          	srli	s11,s11,0x20
    800040d0:	05890613          	addi	a2,s2,88
    800040d4:	86ee                	mv	a3,s11
    800040d6:	963a                	add	a2,a2,a4
    800040d8:	85d2                	mv	a1,s4
    800040da:	855e                	mv	a0,s7
    800040dc:	ffffe097          	auipc	ra,0xffffe
    800040e0:	744080e7          	jalr	1860(ra) # 80002820 <either_copyout>
    800040e4:	05850d63          	beq	a0,s8,8000413e <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800040e8:	854a                	mv	a0,s2
    800040ea:	fffff097          	auipc	ra,0xfffff
    800040ee:	5f4080e7          	jalr	1524(ra) # 800036de <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800040f2:	013d09bb          	addw	s3,s10,s3
    800040f6:	009d04bb          	addw	s1,s10,s1
    800040fa:	9a6e                	add	s4,s4,s11
    800040fc:	0559f763          	bgeu	s3,s5,8000414a <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80004100:	00a4d59b          	srliw	a1,s1,0xa
    80004104:	855a                	mv	a0,s6
    80004106:	00000097          	auipc	ra,0x0
    8000410a:	8a2080e7          	jalr	-1886(ra) # 800039a8 <bmap>
    8000410e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004112:	cd85                	beqz	a1,8000414a <readi+0xce>
    bp = bread(ip->dev, addr);
    80004114:	000b2503          	lw	a0,0(s6)
    80004118:	fffff097          	auipc	ra,0xfffff
    8000411c:	496080e7          	jalr	1174(ra) # 800035ae <bread>
    80004120:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004122:	3ff4f713          	andi	a4,s1,1023
    80004126:	40ec87bb          	subw	a5,s9,a4
    8000412a:	413a86bb          	subw	a3,s5,s3
    8000412e:	8d3e                	mv	s10,a5
    80004130:	2781                	sext.w	a5,a5
    80004132:	0006861b          	sext.w	a2,a3
    80004136:	f8f679e3          	bgeu	a2,a5,800040c8 <readi+0x4c>
    8000413a:	8d36                	mv	s10,a3
    8000413c:	b771                	j	800040c8 <readi+0x4c>
      brelse(bp);
    8000413e:	854a                	mv	a0,s2
    80004140:	fffff097          	auipc	ra,0xfffff
    80004144:	59e080e7          	jalr	1438(ra) # 800036de <brelse>
      tot = -1;
    80004148:	59fd                	li	s3,-1
  }
  return tot;
    8000414a:	0009851b          	sext.w	a0,s3
}
    8000414e:	70a6                	ld	ra,104(sp)
    80004150:	7406                	ld	s0,96(sp)
    80004152:	64e6                	ld	s1,88(sp)
    80004154:	6946                	ld	s2,80(sp)
    80004156:	69a6                	ld	s3,72(sp)
    80004158:	6a06                	ld	s4,64(sp)
    8000415a:	7ae2                	ld	s5,56(sp)
    8000415c:	7b42                	ld	s6,48(sp)
    8000415e:	7ba2                	ld	s7,40(sp)
    80004160:	7c02                	ld	s8,32(sp)
    80004162:	6ce2                	ld	s9,24(sp)
    80004164:	6d42                	ld	s10,16(sp)
    80004166:	6da2                	ld	s11,8(sp)
    80004168:	6165                	addi	sp,sp,112
    8000416a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000416c:	89d6                	mv	s3,s5
    8000416e:	bff1                	j	8000414a <readi+0xce>
    return 0;
    80004170:	4501                	li	a0,0
}
    80004172:	8082                	ret

0000000080004174 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004174:	457c                	lw	a5,76(a0)
    80004176:	10d7e863          	bltu	a5,a3,80004286 <writei+0x112>
{
    8000417a:	7159                	addi	sp,sp,-112
    8000417c:	f486                	sd	ra,104(sp)
    8000417e:	f0a2                	sd	s0,96(sp)
    80004180:	eca6                	sd	s1,88(sp)
    80004182:	e8ca                	sd	s2,80(sp)
    80004184:	e4ce                	sd	s3,72(sp)
    80004186:	e0d2                	sd	s4,64(sp)
    80004188:	fc56                	sd	s5,56(sp)
    8000418a:	f85a                	sd	s6,48(sp)
    8000418c:	f45e                	sd	s7,40(sp)
    8000418e:	f062                	sd	s8,32(sp)
    80004190:	ec66                	sd	s9,24(sp)
    80004192:	e86a                	sd	s10,16(sp)
    80004194:	e46e                	sd	s11,8(sp)
    80004196:	1880                	addi	s0,sp,112
    80004198:	8aaa                	mv	s5,a0
    8000419a:	8bae                	mv	s7,a1
    8000419c:	8a32                	mv	s4,a2
    8000419e:	8936                	mv	s2,a3
    800041a0:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800041a2:	00e687bb          	addw	a5,a3,a4
    800041a6:	0ed7e263          	bltu	a5,a3,8000428a <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800041aa:	00043737          	lui	a4,0x43
    800041ae:	0ef76063          	bltu	a4,a5,8000428e <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800041b2:	0c0b0863          	beqz	s6,80004282 <writei+0x10e>
    800041b6:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800041b8:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800041bc:	5c7d                	li	s8,-1
    800041be:	a091                	j	80004202 <writei+0x8e>
    800041c0:	020d1d93          	slli	s11,s10,0x20
    800041c4:	020ddd93          	srli	s11,s11,0x20
    800041c8:	05848513          	addi	a0,s1,88
    800041cc:	86ee                	mv	a3,s11
    800041ce:	8652                	mv	a2,s4
    800041d0:	85de                	mv	a1,s7
    800041d2:	953a                	add	a0,a0,a4
    800041d4:	ffffe097          	auipc	ra,0xffffe
    800041d8:	6a2080e7          	jalr	1698(ra) # 80002876 <either_copyin>
    800041dc:	07850263          	beq	a0,s8,80004240 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800041e0:	8526                	mv	a0,s1
    800041e2:	00000097          	auipc	ra,0x0
    800041e6:	780080e7          	jalr	1920(ra) # 80004962 <log_write>
    brelse(bp);
    800041ea:	8526                	mv	a0,s1
    800041ec:	fffff097          	auipc	ra,0xfffff
    800041f0:	4f2080e7          	jalr	1266(ra) # 800036de <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800041f4:	013d09bb          	addw	s3,s10,s3
    800041f8:	012d093b          	addw	s2,s10,s2
    800041fc:	9a6e                	add	s4,s4,s11
    800041fe:	0569f663          	bgeu	s3,s6,8000424a <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80004202:	00a9559b          	srliw	a1,s2,0xa
    80004206:	8556                	mv	a0,s5
    80004208:	fffff097          	auipc	ra,0xfffff
    8000420c:	7a0080e7          	jalr	1952(ra) # 800039a8 <bmap>
    80004210:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004214:	c99d                	beqz	a1,8000424a <writei+0xd6>
    bp = bread(ip->dev, addr);
    80004216:	000aa503          	lw	a0,0(s5)
    8000421a:	fffff097          	auipc	ra,0xfffff
    8000421e:	394080e7          	jalr	916(ra) # 800035ae <bread>
    80004222:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004224:	3ff97713          	andi	a4,s2,1023
    80004228:	40ec87bb          	subw	a5,s9,a4
    8000422c:	413b06bb          	subw	a3,s6,s3
    80004230:	8d3e                	mv	s10,a5
    80004232:	2781                	sext.w	a5,a5
    80004234:	0006861b          	sext.w	a2,a3
    80004238:	f8f674e3          	bgeu	a2,a5,800041c0 <writei+0x4c>
    8000423c:	8d36                	mv	s10,a3
    8000423e:	b749                	j	800041c0 <writei+0x4c>
      brelse(bp);
    80004240:	8526                	mv	a0,s1
    80004242:	fffff097          	auipc	ra,0xfffff
    80004246:	49c080e7          	jalr	1180(ra) # 800036de <brelse>
  }

  if(off > ip->size)
    8000424a:	04caa783          	lw	a5,76(s5)
    8000424e:	0127f463          	bgeu	a5,s2,80004256 <writei+0xe2>
    ip->size = off;
    80004252:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004256:	8556                	mv	a0,s5
    80004258:	00000097          	auipc	ra,0x0
    8000425c:	aa6080e7          	jalr	-1370(ra) # 80003cfe <iupdate>

  return tot;
    80004260:	0009851b          	sext.w	a0,s3
}
    80004264:	70a6                	ld	ra,104(sp)
    80004266:	7406                	ld	s0,96(sp)
    80004268:	64e6                	ld	s1,88(sp)
    8000426a:	6946                	ld	s2,80(sp)
    8000426c:	69a6                	ld	s3,72(sp)
    8000426e:	6a06                	ld	s4,64(sp)
    80004270:	7ae2                	ld	s5,56(sp)
    80004272:	7b42                	ld	s6,48(sp)
    80004274:	7ba2                	ld	s7,40(sp)
    80004276:	7c02                	ld	s8,32(sp)
    80004278:	6ce2                	ld	s9,24(sp)
    8000427a:	6d42                	ld	s10,16(sp)
    8000427c:	6da2                	ld	s11,8(sp)
    8000427e:	6165                	addi	sp,sp,112
    80004280:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004282:	89da                	mv	s3,s6
    80004284:	bfc9                	j	80004256 <writei+0xe2>
    return -1;
    80004286:	557d                	li	a0,-1
}
    80004288:	8082                	ret
    return -1;
    8000428a:	557d                	li	a0,-1
    8000428c:	bfe1                	j	80004264 <writei+0xf0>
    return -1;
    8000428e:	557d                	li	a0,-1
    80004290:	bfd1                	j	80004264 <writei+0xf0>

0000000080004292 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004292:	1141                	addi	sp,sp,-16
    80004294:	e406                	sd	ra,8(sp)
    80004296:	e022                	sd	s0,0(sp)
    80004298:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000429a:	4639                	li	a2,14
    8000429c:	ffffd097          	auipc	ra,0xffffd
    800042a0:	b22080e7          	jalr	-1246(ra) # 80000dbe <strncmp>
}
    800042a4:	60a2                	ld	ra,8(sp)
    800042a6:	6402                	ld	s0,0(sp)
    800042a8:	0141                	addi	sp,sp,16
    800042aa:	8082                	ret

00000000800042ac <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800042ac:	7139                	addi	sp,sp,-64
    800042ae:	fc06                	sd	ra,56(sp)
    800042b0:	f822                	sd	s0,48(sp)
    800042b2:	f426                	sd	s1,40(sp)
    800042b4:	f04a                	sd	s2,32(sp)
    800042b6:	ec4e                	sd	s3,24(sp)
    800042b8:	e852                	sd	s4,16(sp)
    800042ba:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800042bc:	04451703          	lh	a4,68(a0)
    800042c0:	4785                	li	a5,1
    800042c2:	00f71a63          	bne	a4,a5,800042d6 <dirlookup+0x2a>
    800042c6:	892a                	mv	s2,a0
    800042c8:	89ae                	mv	s3,a1
    800042ca:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800042cc:	457c                	lw	a5,76(a0)
    800042ce:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800042d0:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042d2:	e79d                	bnez	a5,80004300 <dirlookup+0x54>
    800042d4:	a8a5                	j	8000434c <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800042d6:	00004517          	auipc	a0,0x4
    800042da:	49a50513          	addi	a0,a0,1178 # 80008770 <syscalls+0x1d8>
    800042de:	ffffc097          	auipc	ra,0xffffc
    800042e2:	266080e7          	jalr	614(ra) # 80000544 <panic>
      panic("dirlookup read");
    800042e6:	00004517          	auipc	a0,0x4
    800042ea:	4a250513          	addi	a0,a0,1186 # 80008788 <syscalls+0x1f0>
    800042ee:	ffffc097          	auipc	ra,0xffffc
    800042f2:	256080e7          	jalr	598(ra) # 80000544 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042f6:	24c1                	addiw	s1,s1,16
    800042f8:	04c92783          	lw	a5,76(s2)
    800042fc:	04f4f763          	bgeu	s1,a5,8000434a <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004300:	4741                	li	a4,16
    80004302:	86a6                	mv	a3,s1
    80004304:	fc040613          	addi	a2,s0,-64
    80004308:	4581                	li	a1,0
    8000430a:	854a                	mv	a0,s2
    8000430c:	00000097          	auipc	ra,0x0
    80004310:	d70080e7          	jalr	-656(ra) # 8000407c <readi>
    80004314:	47c1                	li	a5,16
    80004316:	fcf518e3          	bne	a0,a5,800042e6 <dirlookup+0x3a>
    if(de.inum == 0)
    8000431a:	fc045783          	lhu	a5,-64(s0)
    8000431e:	dfe1                	beqz	a5,800042f6 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004320:	fc240593          	addi	a1,s0,-62
    80004324:	854e                	mv	a0,s3
    80004326:	00000097          	auipc	ra,0x0
    8000432a:	f6c080e7          	jalr	-148(ra) # 80004292 <namecmp>
    8000432e:	f561                	bnez	a0,800042f6 <dirlookup+0x4a>
      if(poff)
    80004330:	000a0463          	beqz	s4,80004338 <dirlookup+0x8c>
        *poff = off;
    80004334:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004338:	fc045583          	lhu	a1,-64(s0)
    8000433c:	00092503          	lw	a0,0(s2)
    80004340:	fffff097          	auipc	ra,0xfffff
    80004344:	750080e7          	jalr	1872(ra) # 80003a90 <iget>
    80004348:	a011                	j	8000434c <dirlookup+0xa0>
  return 0;
    8000434a:	4501                	li	a0,0
}
    8000434c:	70e2                	ld	ra,56(sp)
    8000434e:	7442                	ld	s0,48(sp)
    80004350:	74a2                	ld	s1,40(sp)
    80004352:	7902                	ld	s2,32(sp)
    80004354:	69e2                	ld	s3,24(sp)
    80004356:	6a42                	ld	s4,16(sp)
    80004358:	6121                	addi	sp,sp,64
    8000435a:	8082                	ret

000000008000435c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000435c:	711d                	addi	sp,sp,-96
    8000435e:	ec86                	sd	ra,88(sp)
    80004360:	e8a2                	sd	s0,80(sp)
    80004362:	e4a6                	sd	s1,72(sp)
    80004364:	e0ca                	sd	s2,64(sp)
    80004366:	fc4e                	sd	s3,56(sp)
    80004368:	f852                	sd	s4,48(sp)
    8000436a:	f456                	sd	s5,40(sp)
    8000436c:	f05a                	sd	s6,32(sp)
    8000436e:	ec5e                	sd	s7,24(sp)
    80004370:	e862                	sd	s8,16(sp)
    80004372:	e466                	sd	s9,8(sp)
    80004374:	1080                	addi	s0,sp,96
    80004376:	84aa                	mv	s1,a0
    80004378:	8b2e                	mv	s6,a1
    8000437a:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000437c:	00054703          	lbu	a4,0(a0)
    80004380:	02f00793          	li	a5,47
    80004384:	02f70363          	beq	a4,a5,800043aa <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004388:	ffffd097          	auipc	ra,0xffffd
    8000438c:	744080e7          	jalr	1860(ra) # 80001acc <myproc>
    80004390:	15853503          	ld	a0,344(a0)
    80004394:	00000097          	auipc	ra,0x0
    80004398:	9f6080e7          	jalr	-1546(ra) # 80003d8a <idup>
    8000439c:	89aa                	mv	s3,a0
  while(*path == '/')
    8000439e:	02f00913          	li	s2,47
  len = path - s;
    800043a2:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    800043a4:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800043a6:	4c05                	li	s8,1
    800043a8:	a865                	j	80004460 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    800043aa:	4585                	li	a1,1
    800043ac:	4505                	li	a0,1
    800043ae:	fffff097          	auipc	ra,0xfffff
    800043b2:	6e2080e7          	jalr	1762(ra) # 80003a90 <iget>
    800043b6:	89aa                	mv	s3,a0
    800043b8:	b7dd                	j	8000439e <namex+0x42>
      iunlockput(ip);
    800043ba:	854e                	mv	a0,s3
    800043bc:	00000097          	auipc	ra,0x0
    800043c0:	c6e080e7          	jalr	-914(ra) # 8000402a <iunlockput>
      return 0;
    800043c4:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800043c6:	854e                	mv	a0,s3
    800043c8:	60e6                	ld	ra,88(sp)
    800043ca:	6446                	ld	s0,80(sp)
    800043cc:	64a6                	ld	s1,72(sp)
    800043ce:	6906                	ld	s2,64(sp)
    800043d0:	79e2                	ld	s3,56(sp)
    800043d2:	7a42                	ld	s4,48(sp)
    800043d4:	7aa2                	ld	s5,40(sp)
    800043d6:	7b02                	ld	s6,32(sp)
    800043d8:	6be2                	ld	s7,24(sp)
    800043da:	6c42                	ld	s8,16(sp)
    800043dc:	6ca2                	ld	s9,8(sp)
    800043de:	6125                	addi	sp,sp,96
    800043e0:	8082                	ret
      iunlock(ip);
    800043e2:	854e                	mv	a0,s3
    800043e4:	00000097          	auipc	ra,0x0
    800043e8:	aa6080e7          	jalr	-1370(ra) # 80003e8a <iunlock>
      return ip;
    800043ec:	bfe9                	j	800043c6 <namex+0x6a>
      iunlockput(ip);
    800043ee:	854e                	mv	a0,s3
    800043f0:	00000097          	auipc	ra,0x0
    800043f4:	c3a080e7          	jalr	-966(ra) # 8000402a <iunlockput>
      return 0;
    800043f8:	89d2                	mv	s3,s4
    800043fa:	b7f1                	j	800043c6 <namex+0x6a>
  len = path - s;
    800043fc:	40b48633          	sub	a2,s1,a1
    80004400:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80004404:	094cd463          	bge	s9,s4,8000448c <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004408:	4639                	li	a2,14
    8000440a:	8556                	mv	a0,s5
    8000440c:	ffffd097          	auipc	ra,0xffffd
    80004410:	93a080e7          	jalr	-1734(ra) # 80000d46 <memmove>
  while(*path == '/')
    80004414:	0004c783          	lbu	a5,0(s1)
    80004418:	01279763          	bne	a5,s2,80004426 <namex+0xca>
    path++;
    8000441c:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000441e:	0004c783          	lbu	a5,0(s1)
    80004422:	ff278de3          	beq	a5,s2,8000441c <namex+0xc0>
    ilock(ip);
    80004426:	854e                	mv	a0,s3
    80004428:	00000097          	auipc	ra,0x0
    8000442c:	9a0080e7          	jalr	-1632(ra) # 80003dc8 <ilock>
    if(ip->type != T_DIR){
    80004430:	04499783          	lh	a5,68(s3)
    80004434:	f98793e3          	bne	a5,s8,800043ba <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004438:	000b0563          	beqz	s6,80004442 <namex+0xe6>
    8000443c:	0004c783          	lbu	a5,0(s1)
    80004440:	d3cd                	beqz	a5,800043e2 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004442:	865e                	mv	a2,s7
    80004444:	85d6                	mv	a1,s5
    80004446:	854e                	mv	a0,s3
    80004448:	00000097          	auipc	ra,0x0
    8000444c:	e64080e7          	jalr	-412(ra) # 800042ac <dirlookup>
    80004450:	8a2a                	mv	s4,a0
    80004452:	dd51                	beqz	a0,800043ee <namex+0x92>
    iunlockput(ip);
    80004454:	854e                	mv	a0,s3
    80004456:	00000097          	auipc	ra,0x0
    8000445a:	bd4080e7          	jalr	-1068(ra) # 8000402a <iunlockput>
    ip = next;
    8000445e:	89d2                	mv	s3,s4
  while(*path == '/')
    80004460:	0004c783          	lbu	a5,0(s1)
    80004464:	05279763          	bne	a5,s2,800044b2 <namex+0x156>
    path++;
    80004468:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000446a:	0004c783          	lbu	a5,0(s1)
    8000446e:	ff278de3          	beq	a5,s2,80004468 <namex+0x10c>
  if(*path == 0)
    80004472:	c79d                	beqz	a5,800044a0 <namex+0x144>
    path++;
    80004474:	85a6                	mv	a1,s1
  len = path - s;
    80004476:	8a5e                	mv	s4,s7
    80004478:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    8000447a:	01278963          	beq	a5,s2,8000448c <namex+0x130>
    8000447e:	dfbd                	beqz	a5,800043fc <namex+0xa0>
    path++;
    80004480:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004482:	0004c783          	lbu	a5,0(s1)
    80004486:	ff279ce3          	bne	a5,s2,8000447e <namex+0x122>
    8000448a:	bf8d                	j	800043fc <namex+0xa0>
    memmove(name, s, len);
    8000448c:	2601                	sext.w	a2,a2
    8000448e:	8556                	mv	a0,s5
    80004490:	ffffd097          	auipc	ra,0xffffd
    80004494:	8b6080e7          	jalr	-1866(ra) # 80000d46 <memmove>
    name[len] = 0;
    80004498:	9a56                	add	s4,s4,s5
    8000449a:	000a0023          	sb	zero,0(s4)
    8000449e:	bf9d                	j	80004414 <namex+0xb8>
  if(nameiparent){
    800044a0:	f20b03e3          	beqz	s6,800043c6 <namex+0x6a>
    iput(ip);
    800044a4:	854e                	mv	a0,s3
    800044a6:	00000097          	auipc	ra,0x0
    800044aa:	adc080e7          	jalr	-1316(ra) # 80003f82 <iput>
    return 0;
    800044ae:	4981                	li	s3,0
    800044b0:	bf19                	j	800043c6 <namex+0x6a>
  if(*path == 0)
    800044b2:	d7fd                	beqz	a5,800044a0 <namex+0x144>
  while(*path != '/' && *path != 0)
    800044b4:	0004c783          	lbu	a5,0(s1)
    800044b8:	85a6                	mv	a1,s1
    800044ba:	b7d1                	j	8000447e <namex+0x122>

00000000800044bc <dirlink>:
{
    800044bc:	7139                	addi	sp,sp,-64
    800044be:	fc06                	sd	ra,56(sp)
    800044c0:	f822                	sd	s0,48(sp)
    800044c2:	f426                	sd	s1,40(sp)
    800044c4:	f04a                	sd	s2,32(sp)
    800044c6:	ec4e                	sd	s3,24(sp)
    800044c8:	e852                	sd	s4,16(sp)
    800044ca:	0080                	addi	s0,sp,64
    800044cc:	892a                	mv	s2,a0
    800044ce:	8a2e                	mv	s4,a1
    800044d0:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800044d2:	4601                	li	a2,0
    800044d4:	00000097          	auipc	ra,0x0
    800044d8:	dd8080e7          	jalr	-552(ra) # 800042ac <dirlookup>
    800044dc:	e93d                	bnez	a0,80004552 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800044de:	04c92483          	lw	s1,76(s2)
    800044e2:	c49d                	beqz	s1,80004510 <dirlink+0x54>
    800044e4:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800044e6:	4741                	li	a4,16
    800044e8:	86a6                	mv	a3,s1
    800044ea:	fc040613          	addi	a2,s0,-64
    800044ee:	4581                	li	a1,0
    800044f0:	854a                	mv	a0,s2
    800044f2:	00000097          	auipc	ra,0x0
    800044f6:	b8a080e7          	jalr	-1142(ra) # 8000407c <readi>
    800044fa:	47c1                	li	a5,16
    800044fc:	06f51163          	bne	a0,a5,8000455e <dirlink+0xa2>
    if(de.inum == 0)
    80004500:	fc045783          	lhu	a5,-64(s0)
    80004504:	c791                	beqz	a5,80004510 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004506:	24c1                	addiw	s1,s1,16
    80004508:	04c92783          	lw	a5,76(s2)
    8000450c:	fcf4ede3          	bltu	s1,a5,800044e6 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004510:	4639                	li	a2,14
    80004512:	85d2                	mv	a1,s4
    80004514:	fc240513          	addi	a0,s0,-62
    80004518:	ffffd097          	auipc	ra,0xffffd
    8000451c:	8e2080e7          	jalr	-1822(ra) # 80000dfa <strncpy>
  de.inum = inum;
    80004520:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004524:	4741                	li	a4,16
    80004526:	86a6                	mv	a3,s1
    80004528:	fc040613          	addi	a2,s0,-64
    8000452c:	4581                	li	a1,0
    8000452e:	854a                	mv	a0,s2
    80004530:	00000097          	auipc	ra,0x0
    80004534:	c44080e7          	jalr	-956(ra) # 80004174 <writei>
    80004538:	1541                	addi	a0,a0,-16
    8000453a:	00a03533          	snez	a0,a0
    8000453e:	40a00533          	neg	a0,a0
}
    80004542:	70e2                	ld	ra,56(sp)
    80004544:	7442                	ld	s0,48(sp)
    80004546:	74a2                	ld	s1,40(sp)
    80004548:	7902                	ld	s2,32(sp)
    8000454a:	69e2                	ld	s3,24(sp)
    8000454c:	6a42                	ld	s4,16(sp)
    8000454e:	6121                	addi	sp,sp,64
    80004550:	8082                	ret
    iput(ip);
    80004552:	00000097          	auipc	ra,0x0
    80004556:	a30080e7          	jalr	-1488(ra) # 80003f82 <iput>
    return -1;
    8000455a:	557d                	li	a0,-1
    8000455c:	b7dd                	j	80004542 <dirlink+0x86>
      panic("dirlink read");
    8000455e:	00004517          	auipc	a0,0x4
    80004562:	23a50513          	addi	a0,a0,570 # 80008798 <syscalls+0x200>
    80004566:	ffffc097          	auipc	ra,0xffffc
    8000456a:	fde080e7          	jalr	-34(ra) # 80000544 <panic>

000000008000456e <namei>:

struct inode*
namei(char *path)
{
    8000456e:	1101                	addi	sp,sp,-32
    80004570:	ec06                	sd	ra,24(sp)
    80004572:	e822                	sd	s0,16(sp)
    80004574:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004576:	fe040613          	addi	a2,s0,-32
    8000457a:	4581                	li	a1,0
    8000457c:	00000097          	auipc	ra,0x0
    80004580:	de0080e7          	jalr	-544(ra) # 8000435c <namex>
}
    80004584:	60e2                	ld	ra,24(sp)
    80004586:	6442                	ld	s0,16(sp)
    80004588:	6105                	addi	sp,sp,32
    8000458a:	8082                	ret

000000008000458c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000458c:	1141                	addi	sp,sp,-16
    8000458e:	e406                	sd	ra,8(sp)
    80004590:	e022                	sd	s0,0(sp)
    80004592:	0800                	addi	s0,sp,16
    80004594:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004596:	4585                	li	a1,1
    80004598:	00000097          	auipc	ra,0x0
    8000459c:	dc4080e7          	jalr	-572(ra) # 8000435c <namex>
}
    800045a0:	60a2                	ld	ra,8(sp)
    800045a2:	6402                	ld	s0,0(sp)
    800045a4:	0141                	addi	sp,sp,16
    800045a6:	8082                	ret

00000000800045a8 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800045a8:	1101                	addi	sp,sp,-32
    800045aa:	ec06                	sd	ra,24(sp)
    800045ac:	e822                	sd	s0,16(sp)
    800045ae:	e426                	sd	s1,8(sp)
    800045b0:	e04a                	sd	s2,0(sp)
    800045b2:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800045b4:	0001f917          	auipc	s2,0x1f
    800045b8:	abc90913          	addi	s2,s2,-1348 # 80023070 <log>
    800045bc:	01892583          	lw	a1,24(s2)
    800045c0:	02892503          	lw	a0,40(s2)
    800045c4:	fffff097          	auipc	ra,0xfffff
    800045c8:	fea080e7          	jalr	-22(ra) # 800035ae <bread>
    800045cc:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800045ce:	02c92683          	lw	a3,44(s2)
    800045d2:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800045d4:	02d05763          	blez	a3,80004602 <write_head+0x5a>
    800045d8:	0001f797          	auipc	a5,0x1f
    800045dc:	ac878793          	addi	a5,a5,-1336 # 800230a0 <log+0x30>
    800045e0:	05c50713          	addi	a4,a0,92
    800045e4:	36fd                	addiw	a3,a3,-1
    800045e6:	1682                	slli	a3,a3,0x20
    800045e8:	9281                	srli	a3,a3,0x20
    800045ea:	068a                	slli	a3,a3,0x2
    800045ec:	0001f617          	auipc	a2,0x1f
    800045f0:	ab860613          	addi	a2,a2,-1352 # 800230a4 <log+0x34>
    800045f4:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800045f6:	4390                	lw	a2,0(a5)
    800045f8:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800045fa:	0791                	addi	a5,a5,4
    800045fc:	0711                	addi	a4,a4,4
    800045fe:	fed79ce3          	bne	a5,a3,800045f6 <write_head+0x4e>
  }
  bwrite(buf);
    80004602:	8526                	mv	a0,s1
    80004604:	fffff097          	auipc	ra,0xfffff
    80004608:	09c080e7          	jalr	156(ra) # 800036a0 <bwrite>
  brelse(buf);
    8000460c:	8526                	mv	a0,s1
    8000460e:	fffff097          	auipc	ra,0xfffff
    80004612:	0d0080e7          	jalr	208(ra) # 800036de <brelse>
}
    80004616:	60e2                	ld	ra,24(sp)
    80004618:	6442                	ld	s0,16(sp)
    8000461a:	64a2                	ld	s1,8(sp)
    8000461c:	6902                	ld	s2,0(sp)
    8000461e:	6105                	addi	sp,sp,32
    80004620:	8082                	ret

0000000080004622 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004622:	0001f797          	auipc	a5,0x1f
    80004626:	a7a7a783          	lw	a5,-1414(a5) # 8002309c <log+0x2c>
    8000462a:	0af05d63          	blez	a5,800046e4 <install_trans+0xc2>
{
    8000462e:	7139                	addi	sp,sp,-64
    80004630:	fc06                	sd	ra,56(sp)
    80004632:	f822                	sd	s0,48(sp)
    80004634:	f426                	sd	s1,40(sp)
    80004636:	f04a                	sd	s2,32(sp)
    80004638:	ec4e                	sd	s3,24(sp)
    8000463a:	e852                	sd	s4,16(sp)
    8000463c:	e456                	sd	s5,8(sp)
    8000463e:	e05a                	sd	s6,0(sp)
    80004640:	0080                	addi	s0,sp,64
    80004642:	8b2a                	mv	s6,a0
    80004644:	0001fa97          	auipc	s5,0x1f
    80004648:	a5ca8a93          	addi	s5,s5,-1444 # 800230a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000464c:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000464e:	0001f997          	auipc	s3,0x1f
    80004652:	a2298993          	addi	s3,s3,-1502 # 80023070 <log>
    80004656:	a035                	j	80004682 <install_trans+0x60>
      bunpin(dbuf);
    80004658:	8526                	mv	a0,s1
    8000465a:	fffff097          	auipc	ra,0xfffff
    8000465e:	15e080e7          	jalr	350(ra) # 800037b8 <bunpin>
    brelse(lbuf);
    80004662:	854a                	mv	a0,s2
    80004664:	fffff097          	auipc	ra,0xfffff
    80004668:	07a080e7          	jalr	122(ra) # 800036de <brelse>
    brelse(dbuf);
    8000466c:	8526                	mv	a0,s1
    8000466e:	fffff097          	auipc	ra,0xfffff
    80004672:	070080e7          	jalr	112(ra) # 800036de <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004676:	2a05                	addiw	s4,s4,1
    80004678:	0a91                	addi	s5,s5,4
    8000467a:	02c9a783          	lw	a5,44(s3)
    8000467e:	04fa5963          	bge	s4,a5,800046d0 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004682:	0189a583          	lw	a1,24(s3)
    80004686:	014585bb          	addw	a1,a1,s4
    8000468a:	2585                	addiw	a1,a1,1
    8000468c:	0289a503          	lw	a0,40(s3)
    80004690:	fffff097          	auipc	ra,0xfffff
    80004694:	f1e080e7          	jalr	-226(ra) # 800035ae <bread>
    80004698:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000469a:	000aa583          	lw	a1,0(s5)
    8000469e:	0289a503          	lw	a0,40(s3)
    800046a2:	fffff097          	auipc	ra,0xfffff
    800046a6:	f0c080e7          	jalr	-244(ra) # 800035ae <bread>
    800046aa:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800046ac:	40000613          	li	a2,1024
    800046b0:	05890593          	addi	a1,s2,88
    800046b4:	05850513          	addi	a0,a0,88
    800046b8:	ffffc097          	auipc	ra,0xffffc
    800046bc:	68e080e7          	jalr	1678(ra) # 80000d46 <memmove>
    bwrite(dbuf);  // write dst to disk
    800046c0:	8526                	mv	a0,s1
    800046c2:	fffff097          	auipc	ra,0xfffff
    800046c6:	fde080e7          	jalr	-34(ra) # 800036a0 <bwrite>
    if(recovering == 0)
    800046ca:	f80b1ce3          	bnez	s6,80004662 <install_trans+0x40>
    800046ce:	b769                	j	80004658 <install_trans+0x36>
}
    800046d0:	70e2                	ld	ra,56(sp)
    800046d2:	7442                	ld	s0,48(sp)
    800046d4:	74a2                	ld	s1,40(sp)
    800046d6:	7902                	ld	s2,32(sp)
    800046d8:	69e2                	ld	s3,24(sp)
    800046da:	6a42                	ld	s4,16(sp)
    800046dc:	6aa2                	ld	s5,8(sp)
    800046de:	6b02                	ld	s6,0(sp)
    800046e0:	6121                	addi	sp,sp,64
    800046e2:	8082                	ret
    800046e4:	8082                	ret

00000000800046e6 <initlog>:
{
    800046e6:	7179                	addi	sp,sp,-48
    800046e8:	f406                	sd	ra,40(sp)
    800046ea:	f022                	sd	s0,32(sp)
    800046ec:	ec26                	sd	s1,24(sp)
    800046ee:	e84a                	sd	s2,16(sp)
    800046f0:	e44e                	sd	s3,8(sp)
    800046f2:	1800                	addi	s0,sp,48
    800046f4:	892a                	mv	s2,a0
    800046f6:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800046f8:	0001f497          	auipc	s1,0x1f
    800046fc:	97848493          	addi	s1,s1,-1672 # 80023070 <log>
    80004700:	00004597          	auipc	a1,0x4
    80004704:	0a858593          	addi	a1,a1,168 # 800087a8 <syscalls+0x210>
    80004708:	8526                	mv	a0,s1
    8000470a:	ffffc097          	auipc	ra,0xffffc
    8000470e:	450080e7          	jalr	1104(ra) # 80000b5a <initlock>
  log.start = sb->logstart;
    80004712:	0149a583          	lw	a1,20(s3)
    80004716:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004718:	0109a783          	lw	a5,16(s3)
    8000471c:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000471e:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004722:	854a                	mv	a0,s2
    80004724:	fffff097          	auipc	ra,0xfffff
    80004728:	e8a080e7          	jalr	-374(ra) # 800035ae <bread>
  log.lh.n = lh->n;
    8000472c:	4d3c                	lw	a5,88(a0)
    8000472e:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004730:	02f05563          	blez	a5,8000475a <initlog+0x74>
    80004734:	05c50713          	addi	a4,a0,92
    80004738:	0001f697          	auipc	a3,0x1f
    8000473c:	96868693          	addi	a3,a3,-1688 # 800230a0 <log+0x30>
    80004740:	37fd                	addiw	a5,a5,-1
    80004742:	1782                	slli	a5,a5,0x20
    80004744:	9381                	srli	a5,a5,0x20
    80004746:	078a                	slli	a5,a5,0x2
    80004748:	06050613          	addi	a2,a0,96
    8000474c:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    8000474e:	4310                	lw	a2,0(a4)
    80004750:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80004752:	0711                	addi	a4,a4,4
    80004754:	0691                	addi	a3,a3,4
    80004756:	fef71ce3          	bne	a4,a5,8000474e <initlog+0x68>
  brelse(buf);
    8000475a:	fffff097          	auipc	ra,0xfffff
    8000475e:	f84080e7          	jalr	-124(ra) # 800036de <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004762:	4505                	li	a0,1
    80004764:	00000097          	auipc	ra,0x0
    80004768:	ebe080e7          	jalr	-322(ra) # 80004622 <install_trans>
  log.lh.n = 0;
    8000476c:	0001f797          	auipc	a5,0x1f
    80004770:	9207a823          	sw	zero,-1744(a5) # 8002309c <log+0x2c>
  write_head(); // clear the log
    80004774:	00000097          	auipc	ra,0x0
    80004778:	e34080e7          	jalr	-460(ra) # 800045a8 <write_head>
}
    8000477c:	70a2                	ld	ra,40(sp)
    8000477e:	7402                	ld	s0,32(sp)
    80004780:	64e2                	ld	s1,24(sp)
    80004782:	6942                	ld	s2,16(sp)
    80004784:	69a2                	ld	s3,8(sp)
    80004786:	6145                	addi	sp,sp,48
    80004788:	8082                	ret

000000008000478a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000478a:	1101                	addi	sp,sp,-32
    8000478c:	ec06                	sd	ra,24(sp)
    8000478e:	e822                	sd	s0,16(sp)
    80004790:	e426                	sd	s1,8(sp)
    80004792:	e04a                	sd	s2,0(sp)
    80004794:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004796:	0001f517          	auipc	a0,0x1f
    8000479a:	8da50513          	addi	a0,a0,-1830 # 80023070 <log>
    8000479e:	ffffc097          	auipc	ra,0xffffc
    800047a2:	44c080e7          	jalr	1100(ra) # 80000bea <acquire>
  while(1){
    if(log.committing){
    800047a6:	0001f497          	auipc	s1,0x1f
    800047aa:	8ca48493          	addi	s1,s1,-1846 # 80023070 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800047ae:	4979                	li	s2,30
    800047b0:	a039                	j	800047be <begin_op+0x34>
      sleep(&log, &log.lock);
    800047b2:	85a6                	mv	a1,s1
    800047b4:	8526                	mv	a0,s1
    800047b6:	ffffe097          	auipc	ra,0xffffe
    800047ba:	a8a080e7          	jalr	-1398(ra) # 80002240 <sleep>
    if(log.committing){
    800047be:	50dc                	lw	a5,36(s1)
    800047c0:	fbed                	bnez	a5,800047b2 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800047c2:	509c                	lw	a5,32(s1)
    800047c4:	0017871b          	addiw	a4,a5,1
    800047c8:	0007069b          	sext.w	a3,a4
    800047cc:	0027179b          	slliw	a5,a4,0x2
    800047d0:	9fb9                	addw	a5,a5,a4
    800047d2:	0017979b          	slliw	a5,a5,0x1
    800047d6:	54d8                	lw	a4,44(s1)
    800047d8:	9fb9                	addw	a5,a5,a4
    800047da:	00f95963          	bge	s2,a5,800047ec <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800047de:	85a6                	mv	a1,s1
    800047e0:	8526                	mv	a0,s1
    800047e2:	ffffe097          	auipc	ra,0xffffe
    800047e6:	a5e080e7          	jalr	-1442(ra) # 80002240 <sleep>
    800047ea:	bfd1                	j	800047be <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800047ec:	0001f517          	auipc	a0,0x1f
    800047f0:	88450513          	addi	a0,a0,-1916 # 80023070 <log>
    800047f4:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800047f6:	ffffc097          	auipc	ra,0xffffc
    800047fa:	4a8080e7          	jalr	1192(ra) # 80000c9e <release>
      break;
    }
  }
}
    800047fe:	60e2                	ld	ra,24(sp)
    80004800:	6442                	ld	s0,16(sp)
    80004802:	64a2                	ld	s1,8(sp)
    80004804:	6902                	ld	s2,0(sp)
    80004806:	6105                	addi	sp,sp,32
    80004808:	8082                	ret

000000008000480a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000480a:	7139                	addi	sp,sp,-64
    8000480c:	fc06                	sd	ra,56(sp)
    8000480e:	f822                	sd	s0,48(sp)
    80004810:	f426                	sd	s1,40(sp)
    80004812:	f04a                	sd	s2,32(sp)
    80004814:	ec4e                	sd	s3,24(sp)
    80004816:	e852                	sd	s4,16(sp)
    80004818:	e456                	sd	s5,8(sp)
    8000481a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000481c:	0001f497          	auipc	s1,0x1f
    80004820:	85448493          	addi	s1,s1,-1964 # 80023070 <log>
    80004824:	8526                	mv	a0,s1
    80004826:	ffffc097          	auipc	ra,0xffffc
    8000482a:	3c4080e7          	jalr	964(ra) # 80000bea <acquire>
  log.outstanding -= 1;
    8000482e:	509c                	lw	a5,32(s1)
    80004830:	37fd                	addiw	a5,a5,-1
    80004832:	0007891b          	sext.w	s2,a5
    80004836:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004838:	50dc                	lw	a5,36(s1)
    8000483a:	efb9                	bnez	a5,80004898 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000483c:	06091663          	bnez	s2,800048a8 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    80004840:	0001f497          	auipc	s1,0x1f
    80004844:	83048493          	addi	s1,s1,-2000 # 80023070 <log>
    80004848:	4785                	li	a5,1
    8000484a:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000484c:	8526                	mv	a0,s1
    8000484e:	ffffc097          	auipc	ra,0xffffc
    80004852:	450080e7          	jalr	1104(ra) # 80000c9e <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004856:	54dc                	lw	a5,44(s1)
    80004858:	06f04763          	bgtz	a5,800048c6 <end_op+0xbc>
    acquire(&log.lock);
    8000485c:	0001f497          	auipc	s1,0x1f
    80004860:	81448493          	addi	s1,s1,-2028 # 80023070 <log>
    80004864:	8526                	mv	a0,s1
    80004866:	ffffc097          	auipc	ra,0xffffc
    8000486a:	384080e7          	jalr	900(ra) # 80000bea <acquire>
    log.committing = 0;
    8000486e:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004872:	8526                	mv	a0,s1
    80004874:	ffffe097          	auipc	ra,0xffffe
    80004878:	b8e080e7          	jalr	-1138(ra) # 80002402 <wakeup>
    release(&log.lock);
    8000487c:	8526                	mv	a0,s1
    8000487e:	ffffc097          	auipc	ra,0xffffc
    80004882:	420080e7          	jalr	1056(ra) # 80000c9e <release>
}
    80004886:	70e2                	ld	ra,56(sp)
    80004888:	7442                	ld	s0,48(sp)
    8000488a:	74a2                	ld	s1,40(sp)
    8000488c:	7902                	ld	s2,32(sp)
    8000488e:	69e2                	ld	s3,24(sp)
    80004890:	6a42                	ld	s4,16(sp)
    80004892:	6aa2                	ld	s5,8(sp)
    80004894:	6121                	addi	sp,sp,64
    80004896:	8082                	ret
    panic("log.committing");
    80004898:	00004517          	auipc	a0,0x4
    8000489c:	f1850513          	addi	a0,a0,-232 # 800087b0 <syscalls+0x218>
    800048a0:	ffffc097          	auipc	ra,0xffffc
    800048a4:	ca4080e7          	jalr	-860(ra) # 80000544 <panic>
    wakeup(&log);
    800048a8:	0001e497          	auipc	s1,0x1e
    800048ac:	7c848493          	addi	s1,s1,1992 # 80023070 <log>
    800048b0:	8526                	mv	a0,s1
    800048b2:	ffffe097          	auipc	ra,0xffffe
    800048b6:	b50080e7          	jalr	-1200(ra) # 80002402 <wakeup>
  release(&log.lock);
    800048ba:	8526                	mv	a0,s1
    800048bc:	ffffc097          	auipc	ra,0xffffc
    800048c0:	3e2080e7          	jalr	994(ra) # 80000c9e <release>
  if(do_commit){
    800048c4:	b7c9                	j	80004886 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800048c6:	0001ea97          	auipc	s5,0x1e
    800048ca:	7daa8a93          	addi	s5,s5,2010 # 800230a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800048ce:	0001ea17          	auipc	s4,0x1e
    800048d2:	7a2a0a13          	addi	s4,s4,1954 # 80023070 <log>
    800048d6:	018a2583          	lw	a1,24(s4)
    800048da:	012585bb          	addw	a1,a1,s2
    800048de:	2585                	addiw	a1,a1,1
    800048e0:	028a2503          	lw	a0,40(s4)
    800048e4:	fffff097          	auipc	ra,0xfffff
    800048e8:	cca080e7          	jalr	-822(ra) # 800035ae <bread>
    800048ec:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800048ee:	000aa583          	lw	a1,0(s5)
    800048f2:	028a2503          	lw	a0,40(s4)
    800048f6:	fffff097          	auipc	ra,0xfffff
    800048fa:	cb8080e7          	jalr	-840(ra) # 800035ae <bread>
    800048fe:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004900:	40000613          	li	a2,1024
    80004904:	05850593          	addi	a1,a0,88
    80004908:	05848513          	addi	a0,s1,88
    8000490c:	ffffc097          	auipc	ra,0xffffc
    80004910:	43a080e7          	jalr	1082(ra) # 80000d46 <memmove>
    bwrite(to);  // write the log
    80004914:	8526                	mv	a0,s1
    80004916:	fffff097          	auipc	ra,0xfffff
    8000491a:	d8a080e7          	jalr	-630(ra) # 800036a0 <bwrite>
    brelse(from);
    8000491e:	854e                	mv	a0,s3
    80004920:	fffff097          	auipc	ra,0xfffff
    80004924:	dbe080e7          	jalr	-578(ra) # 800036de <brelse>
    brelse(to);
    80004928:	8526                	mv	a0,s1
    8000492a:	fffff097          	auipc	ra,0xfffff
    8000492e:	db4080e7          	jalr	-588(ra) # 800036de <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004932:	2905                	addiw	s2,s2,1
    80004934:	0a91                	addi	s5,s5,4
    80004936:	02ca2783          	lw	a5,44(s4)
    8000493a:	f8f94ee3          	blt	s2,a5,800048d6 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000493e:	00000097          	auipc	ra,0x0
    80004942:	c6a080e7          	jalr	-918(ra) # 800045a8 <write_head>
    install_trans(0); // Now install writes to home locations
    80004946:	4501                	li	a0,0
    80004948:	00000097          	auipc	ra,0x0
    8000494c:	cda080e7          	jalr	-806(ra) # 80004622 <install_trans>
    log.lh.n = 0;
    80004950:	0001e797          	auipc	a5,0x1e
    80004954:	7407a623          	sw	zero,1868(a5) # 8002309c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004958:	00000097          	auipc	ra,0x0
    8000495c:	c50080e7          	jalr	-944(ra) # 800045a8 <write_head>
    80004960:	bdf5                	j	8000485c <end_op+0x52>

0000000080004962 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004962:	1101                	addi	sp,sp,-32
    80004964:	ec06                	sd	ra,24(sp)
    80004966:	e822                	sd	s0,16(sp)
    80004968:	e426                	sd	s1,8(sp)
    8000496a:	e04a                	sd	s2,0(sp)
    8000496c:	1000                	addi	s0,sp,32
    8000496e:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004970:	0001e917          	auipc	s2,0x1e
    80004974:	70090913          	addi	s2,s2,1792 # 80023070 <log>
    80004978:	854a                	mv	a0,s2
    8000497a:	ffffc097          	auipc	ra,0xffffc
    8000497e:	270080e7          	jalr	624(ra) # 80000bea <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004982:	02c92603          	lw	a2,44(s2)
    80004986:	47f5                	li	a5,29
    80004988:	06c7c563          	blt	a5,a2,800049f2 <log_write+0x90>
    8000498c:	0001e797          	auipc	a5,0x1e
    80004990:	7007a783          	lw	a5,1792(a5) # 8002308c <log+0x1c>
    80004994:	37fd                	addiw	a5,a5,-1
    80004996:	04f65e63          	bge	a2,a5,800049f2 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000499a:	0001e797          	auipc	a5,0x1e
    8000499e:	6f67a783          	lw	a5,1782(a5) # 80023090 <log+0x20>
    800049a2:	06f05063          	blez	a5,80004a02 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800049a6:	4781                	li	a5,0
    800049a8:	06c05563          	blez	a2,80004a12 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800049ac:	44cc                	lw	a1,12(s1)
    800049ae:	0001e717          	auipc	a4,0x1e
    800049b2:	6f270713          	addi	a4,a4,1778 # 800230a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800049b6:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800049b8:	4314                	lw	a3,0(a4)
    800049ba:	04b68c63          	beq	a3,a1,80004a12 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800049be:	2785                	addiw	a5,a5,1
    800049c0:	0711                	addi	a4,a4,4
    800049c2:	fef61be3          	bne	a2,a5,800049b8 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800049c6:	0621                	addi	a2,a2,8
    800049c8:	060a                	slli	a2,a2,0x2
    800049ca:	0001e797          	auipc	a5,0x1e
    800049ce:	6a678793          	addi	a5,a5,1702 # 80023070 <log>
    800049d2:	963e                	add	a2,a2,a5
    800049d4:	44dc                	lw	a5,12(s1)
    800049d6:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800049d8:	8526                	mv	a0,s1
    800049da:	fffff097          	auipc	ra,0xfffff
    800049de:	da2080e7          	jalr	-606(ra) # 8000377c <bpin>
    log.lh.n++;
    800049e2:	0001e717          	auipc	a4,0x1e
    800049e6:	68e70713          	addi	a4,a4,1678 # 80023070 <log>
    800049ea:	575c                	lw	a5,44(a4)
    800049ec:	2785                	addiw	a5,a5,1
    800049ee:	d75c                	sw	a5,44(a4)
    800049f0:	a835                	j	80004a2c <log_write+0xca>
    panic("too big a transaction");
    800049f2:	00004517          	auipc	a0,0x4
    800049f6:	dce50513          	addi	a0,a0,-562 # 800087c0 <syscalls+0x228>
    800049fa:	ffffc097          	auipc	ra,0xffffc
    800049fe:	b4a080e7          	jalr	-1206(ra) # 80000544 <panic>
    panic("log_write outside of trans");
    80004a02:	00004517          	auipc	a0,0x4
    80004a06:	dd650513          	addi	a0,a0,-554 # 800087d8 <syscalls+0x240>
    80004a0a:	ffffc097          	auipc	ra,0xffffc
    80004a0e:	b3a080e7          	jalr	-1222(ra) # 80000544 <panic>
  log.lh.block[i] = b->blockno;
    80004a12:	00878713          	addi	a4,a5,8
    80004a16:	00271693          	slli	a3,a4,0x2
    80004a1a:	0001e717          	auipc	a4,0x1e
    80004a1e:	65670713          	addi	a4,a4,1622 # 80023070 <log>
    80004a22:	9736                	add	a4,a4,a3
    80004a24:	44d4                	lw	a3,12(s1)
    80004a26:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004a28:	faf608e3          	beq	a2,a5,800049d8 <log_write+0x76>
  }
  release(&log.lock);
    80004a2c:	0001e517          	auipc	a0,0x1e
    80004a30:	64450513          	addi	a0,a0,1604 # 80023070 <log>
    80004a34:	ffffc097          	auipc	ra,0xffffc
    80004a38:	26a080e7          	jalr	618(ra) # 80000c9e <release>
}
    80004a3c:	60e2                	ld	ra,24(sp)
    80004a3e:	6442                	ld	s0,16(sp)
    80004a40:	64a2                	ld	s1,8(sp)
    80004a42:	6902                	ld	s2,0(sp)
    80004a44:	6105                	addi	sp,sp,32
    80004a46:	8082                	ret

0000000080004a48 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004a48:	1101                	addi	sp,sp,-32
    80004a4a:	ec06                	sd	ra,24(sp)
    80004a4c:	e822                	sd	s0,16(sp)
    80004a4e:	e426                	sd	s1,8(sp)
    80004a50:	e04a                	sd	s2,0(sp)
    80004a52:	1000                	addi	s0,sp,32
    80004a54:	84aa                	mv	s1,a0
    80004a56:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004a58:	00004597          	auipc	a1,0x4
    80004a5c:	da058593          	addi	a1,a1,-608 # 800087f8 <syscalls+0x260>
    80004a60:	0521                	addi	a0,a0,8
    80004a62:	ffffc097          	auipc	ra,0xffffc
    80004a66:	0f8080e7          	jalr	248(ra) # 80000b5a <initlock>
  lk->name = name;
    80004a6a:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004a6e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004a72:	0204a423          	sw	zero,40(s1)
}
    80004a76:	60e2                	ld	ra,24(sp)
    80004a78:	6442                	ld	s0,16(sp)
    80004a7a:	64a2                	ld	s1,8(sp)
    80004a7c:	6902                	ld	s2,0(sp)
    80004a7e:	6105                	addi	sp,sp,32
    80004a80:	8082                	ret

0000000080004a82 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004a82:	1101                	addi	sp,sp,-32
    80004a84:	ec06                	sd	ra,24(sp)
    80004a86:	e822                	sd	s0,16(sp)
    80004a88:	e426                	sd	s1,8(sp)
    80004a8a:	e04a                	sd	s2,0(sp)
    80004a8c:	1000                	addi	s0,sp,32
    80004a8e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004a90:	00850913          	addi	s2,a0,8
    80004a94:	854a                	mv	a0,s2
    80004a96:	ffffc097          	auipc	ra,0xffffc
    80004a9a:	154080e7          	jalr	340(ra) # 80000bea <acquire>
  while (lk->locked) {
    80004a9e:	409c                	lw	a5,0(s1)
    80004aa0:	cb89                	beqz	a5,80004ab2 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004aa2:	85ca                	mv	a1,s2
    80004aa4:	8526                	mv	a0,s1
    80004aa6:	ffffd097          	auipc	ra,0xffffd
    80004aaa:	79a080e7          	jalr	1946(ra) # 80002240 <sleep>
  while (lk->locked) {
    80004aae:	409c                	lw	a5,0(s1)
    80004ab0:	fbed                	bnez	a5,80004aa2 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004ab2:	4785                	li	a5,1
    80004ab4:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004ab6:	ffffd097          	auipc	ra,0xffffd
    80004aba:	016080e7          	jalr	22(ra) # 80001acc <myproc>
    80004abe:	5d1c                	lw	a5,56(a0)
    80004ac0:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004ac2:	854a                	mv	a0,s2
    80004ac4:	ffffc097          	auipc	ra,0xffffc
    80004ac8:	1da080e7          	jalr	474(ra) # 80000c9e <release>
}
    80004acc:	60e2                	ld	ra,24(sp)
    80004ace:	6442                	ld	s0,16(sp)
    80004ad0:	64a2                	ld	s1,8(sp)
    80004ad2:	6902                	ld	s2,0(sp)
    80004ad4:	6105                	addi	sp,sp,32
    80004ad6:	8082                	ret

0000000080004ad8 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004ad8:	1101                	addi	sp,sp,-32
    80004ada:	ec06                	sd	ra,24(sp)
    80004adc:	e822                	sd	s0,16(sp)
    80004ade:	e426                	sd	s1,8(sp)
    80004ae0:	e04a                	sd	s2,0(sp)
    80004ae2:	1000                	addi	s0,sp,32
    80004ae4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004ae6:	00850913          	addi	s2,a0,8
    80004aea:	854a                	mv	a0,s2
    80004aec:	ffffc097          	auipc	ra,0xffffc
    80004af0:	0fe080e7          	jalr	254(ra) # 80000bea <acquire>
  lk->locked = 0;
    80004af4:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004af8:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004afc:	8526                	mv	a0,s1
    80004afe:	ffffe097          	auipc	ra,0xffffe
    80004b02:	904080e7          	jalr	-1788(ra) # 80002402 <wakeup>
  release(&lk->lk);
    80004b06:	854a                	mv	a0,s2
    80004b08:	ffffc097          	auipc	ra,0xffffc
    80004b0c:	196080e7          	jalr	406(ra) # 80000c9e <release>
}
    80004b10:	60e2                	ld	ra,24(sp)
    80004b12:	6442                	ld	s0,16(sp)
    80004b14:	64a2                	ld	s1,8(sp)
    80004b16:	6902                	ld	s2,0(sp)
    80004b18:	6105                	addi	sp,sp,32
    80004b1a:	8082                	ret

0000000080004b1c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004b1c:	7179                	addi	sp,sp,-48
    80004b1e:	f406                	sd	ra,40(sp)
    80004b20:	f022                	sd	s0,32(sp)
    80004b22:	ec26                	sd	s1,24(sp)
    80004b24:	e84a                	sd	s2,16(sp)
    80004b26:	e44e                	sd	s3,8(sp)
    80004b28:	1800                	addi	s0,sp,48
    80004b2a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004b2c:	00850913          	addi	s2,a0,8
    80004b30:	854a                	mv	a0,s2
    80004b32:	ffffc097          	auipc	ra,0xffffc
    80004b36:	0b8080e7          	jalr	184(ra) # 80000bea <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004b3a:	409c                	lw	a5,0(s1)
    80004b3c:	ef99                	bnez	a5,80004b5a <holdingsleep+0x3e>
    80004b3e:	4481                	li	s1,0
  release(&lk->lk);
    80004b40:	854a                	mv	a0,s2
    80004b42:	ffffc097          	auipc	ra,0xffffc
    80004b46:	15c080e7          	jalr	348(ra) # 80000c9e <release>
  return r;
}
    80004b4a:	8526                	mv	a0,s1
    80004b4c:	70a2                	ld	ra,40(sp)
    80004b4e:	7402                	ld	s0,32(sp)
    80004b50:	64e2                	ld	s1,24(sp)
    80004b52:	6942                	ld	s2,16(sp)
    80004b54:	69a2                	ld	s3,8(sp)
    80004b56:	6145                	addi	sp,sp,48
    80004b58:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004b5a:	0284a983          	lw	s3,40(s1)
    80004b5e:	ffffd097          	auipc	ra,0xffffd
    80004b62:	f6e080e7          	jalr	-146(ra) # 80001acc <myproc>
    80004b66:	5d04                	lw	s1,56(a0)
    80004b68:	413484b3          	sub	s1,s1,s3
    80004b6c:	0014b493          	seqz	s1,s1
    80004b70:	bfc1                	j	80004b40 <holdingsleep+0x24>

0000000080004b72 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004b72:	1141                	addi	sp,sp,-16
    80004b74:	e406                	sd	ra,8(sp)
    80004b76:	e022                	sd	s0,0(sp)
    80004b78:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004b7a:	00004597          	auipc	a1,0x4
    80004b7e:	c8e58593          	addi	a1,a1,-882 # 80008808 <syscalls+0x270>
    80004b82:	0001e517          	auipc	a0,0x1e
    80004b86:	63650513          	addi	a0,a0,1590 # 800231b8 <ftable>
    80004b8a:	ffffc097          	auipc	ra,0xffffc
    80004b8e:	fd0080e7          	jalr	-48(ra) # 80000b5a <initlock>
}
    80004b92:	60a2                	ld	ra,8(sp)
    80004b94:	6402                	ld	s0,0(sp)
    80004b96:	0141                	addi	sp,sp,16
    80004b98:	8082                	ret

0000000080004b9a <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004b9a:	1101                	addi	sp,sp,-32
    80004b9c:	ec06                	sd	ra,24(sp)
    80004b9e:	e822                	sd	s0,16(sp)
    80004ba0:	e426                	sd	s1,8(sp)
    80004ba2:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004ba4:	0001e517          	auipc	a0,0x1e
    80004ba8:	61450513          	addi	a0,a0,1556 # 800231b8 <ftable>
    80004bac:	ffffc097          	auipc	ra,0xffffc
    80004bb0:	03e080e7          	jalr	62(ra) # 80000bea <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004bb4:	0001e497          	auipc	s1,0x1e
    80004bb8:	61c48493          	addi	s1,s1,1564 # 800231d0 <ftable+0x18>
    80004bbc:	0001f717          	auipc	a4,0x1f
    80004bc0:	5b470713          	addi	a4,a4,1460 # 80024170 <disk>
    if(f->ref == 0){
    80004bc4:	40dc                	lw	a5,4(s1)
    80004bc6:	cf99                	beqz	a5,80004be4 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004bc8:	02848493          	addi	s1,s1,40
    80004bcc:	fee49ce3          	bne	s1,a4,80004bc4 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004bd0:	0001e517          	auipc	a0,0x1e
    80004bd4:	5e850513          	addi	a0,a0,1512 # 800231b8 <ftable>
    80004bd8:	ffffc097          	auipc	ra,0xffffc
    80004bdc:	0c6080e7          	jalr	198(ra) # 80000c9e <release>
  return 0;
    80004be0:	4481                	li	s1,0
    80004be2:	a819                	j	80004bf8 <filealloc+0x5e>
      f->ref = 1;
    80004be4:	4785                	li	a5,1
    80004be6:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004be8:	0001e517          	auipc	a0,0x1e
    80004bec:	5d050513          	addi	a0,a0,1488 # 800231b8 <ftable>
    80004bf0:	ffffc097          	auipc	ra,0xffffc
    80004bf4:	0ae080e7          	jalr	174(ra) # 80000c9e <release>
}
    80004bf8:	8526                	mv	a0,s1
    80004bfa:	60e2                	ld	ra,24(sp)
    80004bfc:	6442                	ld	s0,16(sp)
    80004bfe:	64a2                	ld	s1,8(sp)
    80004c00:	6105                	addi	sp,sp,32
    80004c02:	8082                	ret

0000000080004c04 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004c04:	1101                	addi	sp,sp,-32
    80004c06:	ec06                	sd	ra,24(sp)
    80004c08:	e822                	sd	s0,16(sp)
    80004c0a:	e426                	sd	s1,8(sp)
    80004c0c:	1000                	addi	s0,sp,32
    80004c0e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004c10:	0001e517          	auipc	a0,0x1e
    80004c14:	5a850513          	addi	a0,a0,1448 # 800231b8 <ftable>
    80004c18:	ffffc097          	auipc	ra,0xffffc
    80004c1c:	fd2080e7          	jalr	-46(ra) # 80000bea <acquire>
  if(f->ref < 1)
    80004c20:	40dc                	lw	a5,4(s1)
    80004c22:	02f05263          	blez	a5,80004c46 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004c26:	2785                	addiw	a5,a5,1
    80004c28:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004c2a:	0001e517          	auipc	a0,0x1e
    80004c2e:	58e50513          	addi	a0,a0,1422 # 800231b8 <ftable>
    80004c32:	ffffc097          	auipc	ra,0xffffc
    80004c36:	06c080e7          	jalr	108(ra) # 80000c9e <release>
  return f;
}
    80004c3a:	8526                	mv	a0,s1
    80004c3c:	60e2                	ld	ra,24(sp)
    80004c3e:	6442                	ld	s0,16(sp)
    80004c40:	64a2                	ld	s1,8(sp)
    80004c42:	6105                	addi	sp,sp,32
    80004c44:	8082                	ret
    panic("filedup");
    80004c46:	00004517          	auipc	a0,0x4
    80004c4a:	bca50513          	addi	a0,a0,-1078 # 80008810 <syscalls+0x278>
    80004c4e:	ffffc097          	auipc	ra,0xffffc
    80004c52:	8f6080e7          	jalr	-1802(ra) # 80000544 <panic>

0000000080004c56 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004c56:	7139                	addi	sp,sp,-64
    80004c58:	fc06                	sd	ra,56(sp)
    80004c5a:	f822                	sd	s0,48(sp)
    80004c5c:	f426                	sd	s1,40(sp)
    80004c5e:	f04a                	sd	s2,32(sp)
    80004c60:	ec4e                	sd	s3,24(sp)
    80004c62:	e852                	sd	s4,16(sp)
    80004c64:	e456                	sd	s5,8(sp)
    80004c66:	0080                	addi	s0,sp,64
    80004c68:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004c6a:	0001e517          	auipc	a0,0x1e
    80004c6e:	54e50513          	addi	a0,a0,1358 # 800231b8 <ftable>
    80004c72:	ffffc097          	auipc	ra,0xffffc
    80004c76:	f78080e7          	jalr	-136(ra) # 80000bea <acquire>
  if(f->ref < 1)
    80004c7a:	40dc                	lw	a5,4(s1)
    80004c7c:	06f05163          	blez	a5,80004cde <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004c80:	37fd                	addiw	a5,a5,-1
    80004c82:	0007871b          	sext.w	a4,a5
    80004c86:	c0dc                	sw	a5,4(s1)
    80004c88:	06e04363          	bgtz	a4,80004cee <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004c8c:	0004a903          	lw	s2,0(s1)
    80004c90:	0094ca83          	lbu	s5,9(s1)
    80004c94:	0104ba03          	ld	s4,16(s1)
    80004c98:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004c9c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004ca0:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004ca4:	0001e517          	auipc	a0,0x1e
    80004ca8:	51450513          	addi	a0,a0,1300 # 800231b8 <ftable>
    80004cac:	ffffc097          	auipc	ra,0xffffc
    80004cb0:	ff2080e7          	jalr	-14(ra) # 80000c9e <release>

  if(ff.type == FD_PIPE){
    80004cb4:	4785                	li	a5,1
    80004cb6:	04f90d63          	beq	s2,a5,80004d10 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004cba:	3979                	addiw	s2,s2,-2
    80004cbc:	4785                	li	a5,1
    80004cbe:	0527e063          	bltu	a5,s2,80004cfe <fileclose+0xa8>
    begin_op();
    80004cc2:	00000097          	auipc	ra,0x0
    80004cc6:	ac8080e7          	jalr	-1336(ra) # 8000478a <begin_op>
    iput(ff.ip);
    80004cca:	854e                	mv	a0,s3
    80004ccc:	fffff097          	auipc	ra,0xfffff
    80004cd0:	2b6080e7          	jalr	694(ra) # 80003f82 <iput>
    end_op();
    80004cd4:	00000097          	auipc	ra,0x0
    80004cd8:	b36080e7          	jalr	-1226(ra) # 8000480a <end_op>
    80004cdc:	a00d                	j	80004cfe <fileclose+0xa8>
    panic("fileclose");
    80004cde:	00004517          	auipc	a0,0x4
    80004ce2:	b3a50513          	addi	a0,a0,-1222 # 80008818 <syscalls+0x280>
    80004ce6:	ffffc097          	auipc	ra,0xffffc
    80004cea:	85e080e7          	jalr	-1954(ra) # 80000544 <panic>
    release(&ftable.lock);
    80004cee:	0001e517          	auipc	a0,0x1e
    80004cf2:	4ca50513          	addi	a0,a0,1226 # 800231b8 <ftable>
    80004cf6:	ffffc097          	auipc	ra,0xffffc
    80004cfa:	fa8080e7          	jalr	-88(ra) # 80000c9e <release>
  }
}
    80004cfe:	70e2                	ld	ra,56(sp)
    80004d00:	7442                	ld	s0,48(sp)
    80004d02:	74a2                	ld	s1,40(sp)
    80004d04:	7902                	ld	s2,32(sp)
    80004d06:	69e2                	ld	s3,24(sp)
    80004d08:	6a42                	ld	s4,16(sp)
    80004d0a:	6aa2                	ld	s5,8(sp)
    80004d0c:	6121                	addi	sp,sp,64
    80004d0e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004d10:	85d6                	mv	a1,s5
    80004d12:	8552                	mv	a0,s4
    80004d14:	00000097          	auipc	ra,0x0
    80004d18:	34c080e7          	jalr	844(ra) # 80005060 <pipeclose>
    80004d1c:	b7cd                	j	80004cfe <fileclose+0xa8>

0000000080004d1e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004d1e:	715d                	addi	sp,sp,-80
    80004d20:	e486                	sd	ra,72(sp)
    80004d22:	e0a2                	sd	s0,64(sp)
    80004d24:	fc26                	sd	s1,56(sp)
    80004d26:	f84a                	sd	s2,48(sp)
    80004d28:	f44e                	sd	s3,40(sp)
    80004d2a:	0880                	addi	s0,sp,80
    80004d2c:	84aa                	mv	s1,a0
    80004d2e:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004d30:	ffffd097          	auipc	ra,0xffffd
    80004d34:	d9c080e7          	jalr	-612(ra) # 80001acc <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004d38:	409c                	lw	a5,0(s1)
    80004d3a:	37f9                	addiw	a5,a5,-2
    80004d3c:	4705                	li	a4,1
    80004d3e:	04f76763          	bltu	a4,a5,80004d8c <filestat+0x6e>
    80004d42:	892a                	mv	s2,a0
    ilock(f->ip);
    80004d44:	6c88                	ld	a0,24(s1)
    80004d46:	fffff097          	auipc	ra,0xfffff
    80004d4a:	082080e7          	jalr	130(ra) # 80003dc8 <ilock>
    stati(f->ip, &st);
    80004d4e:	fb840593          	addi	a1,s0,-72
    80004d52:	6c88                	ld	a0,24(s1)
    80004d54:	fffff097          	auipc	ra,0xfffff
    80004d58:	2fe080e7          	jalr	766(ra) # 80004052 <stati>
    iunlock(f->ip);
    80004d5c:	6c88                	ld	a0,24(s1)
    80004d5e:	fffff097          	auipc	ra,0xfffff
    80004d62:	12c080e7          	jalr	300(ra) # 80003e8a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004d66:	46e1                	li	a3,24
    80004d68:	fb840613          	addi	a2,s0,-72
    80004d6c:	85ce                	mv	a1,s3
    80004d6e:	05893503          	ld	a0,88(s2)
    80004d72:	ffffd097          	auipc	ra,0xffffd
    80004d76:	912080e7          	jalr	-1774(ra) # 80001684 <copyout>
    80004d7a:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004d7e:	60a6                	ld	ra,72(sp)
    80004d80:	6406                	ld	s0,64(sp)
    80004d82:	74e2                	ld	s1,56(sp)
    80004d84:	7942                	ld	s2,48(sp)
    80004d86:	79a2                	ld	s3,40(sp)
    80004d88:	6161                	addi	sp,sp,80
    80004d8a:	8082                	ret
  return -1;
    80004d8c:	557d                	li	a0,-1
    80004d8e:	bfc5                	j	80004d7e <filestat+0x60>

0000000080004d90 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004d90:	7179                	addi	sp,sp,-48
    80004d92:	f406                	sd	ra,40(sp)
    80004d94:	f022                	sd	s0,32(sp)
    80004d96:	ec26                	sd	s1,24(sp)
    80004d98:	e84a                	sd	s2,16(sp)
    80004d9a:	e44e                	sd	s3,8(sp)
    80004d9c:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004d9e:	00854783          	lbu	a5,8(a0)
    80004da2:	c3d5                	beqz	a5,80004e46 <fileread+0xb6>
    80004da4:	84aa                	mv	s1,a0
    80004da6:	89ae                	mv	s3,a1
    80004da8:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004daa:	411c                	lw	a5,0(a0)
    80004dac:	4705                	li	a4,1
    80004dae:	04e78963          	beq	a5,a4,80004e00 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004db2:	470d                	li	a4,3
    80004db4:	04e78d63          	beq	a5,a4,80004e0e <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004db8:	4709                	li	a4,2
    80004dba:	06e79e63          	bne	a5,a4,80004e36 <fileread+0xa6>
    ilock(f->ip);
    80004dbe:	6d08                	ld	a0,24(a0)
    80004dc0:	fffff097          	auipc	ra,0xfffff
    80004dc4:	008080e7          	jalr	8(ra) # 80003dc8 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004dc8:	874a                	mv	a4,s2
    80004dca:	5094                	lw	a3,32(s1)
    80004dcc:	864e                	mv	a2,s3
    80004dce:	4585                	li	a1,1
    80004dd0:	6c88                	ld	a0,24(s1)
    80004dd2:	fffff097          	auipc	ra,0xfffff
    80004dd6:	2aa080e7          	jalr	682(ra) # 8000407c <readi>
    80004dda:	892a                	mv	s2,a0
    80004ddc:	00a05563          	blez	a0,80004de6 <fileread+0x56>
      f->off += r;
    80004de0:	509c                	lw	a5,32(s1)
    80004de2:	9fa9                	addw	a5,a5,a0
    80004de4:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004de6:	6c88                	ld	a0,24(s1)
    80004de8:	fffff097          	auipc	ra,0xfffff
    80004dec:	0a2080e7          	jalr	162(ra) # 80003e8a <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004df0:	854a                	mv	a0,s2
    80004df2:	70a2                	ld	ra,40(sp)
    80004df4:	7402                	ld	s0,32(sp)
    80004df6:	64e2                	ld	s1,24(sp)
    80004df8:	6942                	ld	s2,16(sp)
    80004dfa:	69a2                	ld	s3,8(sp)
    80004dfc:	6145                	addi	sp,sp,48
    80004dfe:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004e00:	6908                	ld	a0,16(a0)
    80004e02:	00000097          	auipc	ra,0x0
    80004e06:	3ce080e7          	jalr	974(ra) # 800051d0 <piperead>
    80004e0a:	892a                	mv	s2,a0
    80004e0c:	b7d5                	j	80004df0 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004e0e:	02451783          	lh	a5,36(a0)
    80004e12:	03079693          	slli	a3,a5,0x30
    80004e16:	92c1                	srli	a3,a3,0x30
    80004e18:	4725                	li	a4,9
    80004e1a:	02d76863          	bltu	a4,a3,80004e4a <fileread+0xba>
    80004e1e:	0792                	slli	a5,a5,0x4
    80004e20:	0001e717          	auipc	a4,0x1e
    80004e24:	2f870713          	addi	a4,a4,760 # 80023118 <devsw>
    80004e28:	97ba                	add	a5,a5,a4
    80004e2a:	639c                	ld	a5,0(a5)
    80004e2c:	c38d                	beqz	a5,80004e4e <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004e2e:	4505                	li	a0,1
    80004e30:	9782                	jalr	a5
    80004e32:	892a                	mv	s2,a0
    80004e34:	bf75                	j	80004df0 <fileread+0x60>
    panic("fileread");
    80004e36:	00004517          	auipc	a0,0x4
    80004e3a:	9f250513          	addi	a0,a0,-1550 # 80008828 <syscalls+0x290>
    80004e3e:	ffffb097          	auipc	ra,0xffffb
    80004e42:	706080e7          	jalr	1798(ra) # 80000544 <panic>
    return -1;
    80004e46:	597d                	li	s2,-1
    80004e48:	b765                	j	80004df0 <fileread+0x60>
      return -1;
    80004e4a:	597d                	li	s2,-1
    80004e4c:	b755                	j	80004df0 <fileread+0x60>
    80004e4e:	597d                	li	s2,-1
    80004e50:	b745                	j	80004df0 <fileread+0x60>

0000000080004e52 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004e52:	715d                	addi	sp,sp,-80
    80004e54:	e486                	sd	ra,72(sp)
    80004e56:	e0a2                	sd	s0,64(sp)
    80004e58:	fc26                	sd	s1,56(sp)
    80004e5a:	f84a                	sd	s2,48(sp)
    80004e5c:	f44e                	sd	s3,40(sp)
    80004e5e:	f052                	sd	s4,32(sp)
    80004e60:	ec56                	sd	s5,24(sp)
    80004e62:	e85a                	sd	s6,16(sp)
    80004e64:	e45e                	sd	s7,8(sp)
    80004e66:	e062                	sd	s8,0(sp)
    80004e68:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004e6a:	00954783          	lbu	a5,9(a0)
    80004e6e:	10078663          	beqz	a5,80004f7a <filewrite+0x128>
    80004e72:	892a                	mv	s2,a0
    80004e74:	8aae                	mv	s5,a1
    80004e76:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004e78:	411c                	lw	a5,0(a0)
    80004e7a:	4705                	li	a4,1
    80004e7c:	02e78263          	beq	a5,a4,80004ea0 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004e80:	470d                	li	a4,3
    80004e82:	02e78663          	beq	a5,a4,80004eae <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004e86:	4709                	li	a4,2
    80004e88:	0ee79163          	bne	a5,a4,80004f6a <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004e8c:	0ac05d63          	blez	a2,80004f46 <filewrite+0xf4>
    int i = 0;
    80004e90:	4981                	li	s3,0
    80004e92:	6b05                	lui	s6,0x1
    80004e94:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004e98:	6b85                	lui	s7,0x1
    80004e9a:	c00b8b9b          	addiw	s7,s7,-1024
    80004e9e:	a861                	j	80004f36 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004ea0:	6908                	ld	a0,16(a0)
    80004ea2:	00000097          	auipc	ra,0x0
    80004ea6:	22e080e7          	jalr	558(ra) # 800050d0 <pipewrite>
    80004eaa:	8a2a                	mv	s4,a0
    80004eac:	a045                	j	80004f4c <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004eae:	02451783          	lh	a5,36(a0)
    80004eb2:	03079693          	slli	a3,a5,0x30
    80004eb6:	92c1                	srli	a3,a3,0x30
    80004eb8:	4725                	li	a4,9
    80004eba:	0cd76263          	bltu	a4,a3,80004f7e <filewrite+0x12c>
    80004ebe:	0792                	slli	a5,a5,0x4
    80004ec0:	0001e717          	auipc	a4,0x1e
    80004ec4:	25870713          	addi	a4,a4,600 # 80023118 <devsw>
    80004ec8:	97ba                	add	a5,a5,a4
    80004eca:	679c                	ld	a5,8(a5)
    80004ecc:	cbdd                	beqz	a5,80004f82 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004ece:	4505                	li	a0,1
    80004ed0:	9782                	jalr	a5
    80004ed2:	8a2a                	mv	s4,a0
    80004ed4:	a8a5                	j	80004f4c <filewrite+0xfa>
    80004ed6:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004eda:	00000097          	auipc	ra,0x0
    80004ede:	8b0080e7          	jalr	-1872(ra) # 8000478a <begin_op>
      ilock(f->ip);
    80004ee2:	01893503          	ld	a0,24(s2)
    80004ee6:	fffff097          	auipc	ra,0xfffff
    80004eea:	ee2080e7          	jalr	-286(ra) # 80003dc8 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004eee:	8762                	mv	a4,s8
    80004ef0:	02092683          	lw	a3,32(s2)
    80004ef4:	01598633          	add	a2,s3,s5
    80004ef8:	4585                	li	a1,1
    80004efa:	01893503          	ld	a0,24(s2)
    80004efe:	fffff097          	auipc	ra,0xfffff
    80004f02:	276080e7          	jalr	630(ra) # 80004174 <writei>
    80004f06:	84aa                	mv	s1,a0
    80004f08:	00a05763          	blez	a0,80004f16 <filewrite+0xc4>
        f->off += r;
    80004f0c:	02092783          	lw	a5,32(s2)
    80004f10:	9fa9                	addw	a5,a5,a0
    80004f12:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004f16:	01893503          	ld	a0,24(s2)
    80004f1a:	fffff097          	auipc	ra,0xfffff
    80004f1e:	f70080e7          	jalr	-144(ra) # 80003e8a <iunlock>
      end_op();
    80004f22:	00000097          	auipc	ra,0x0
    80004f26:	8e8080e7          	jalr	-1816(ra) # 8000480a <end_op>

      if(r != n1){
    80004f2a:	009c1f63          	bne	s8,s1,80004f48 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004f2e:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004f32:	0149db63          	bge	s3,s4,80004f48 <filewrite+0xf6>
      int n1 = n - i;
    80004f36:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004f3a:	84be                	mv	s1,a5
    80004f3c:	2781                	sext.w	a5,a5
    80004f3e:	f8fb5ce3          	bge	s6,a5,80004ed6 <filewrite+0x84>
    80004f42:	84de                	mv	s1,s7
    80004f44:	bf49                	j	80004ed6 <filewrite+0x84>
    int i = 0;
    80004f46:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004f48:	013a1f63          	bne	s4,s3,80004f66 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004f4c:	8552                	mv	a0,s4
    80004f4e:	60a6                	ld	ra,72(sp)
    80004f50:	6406                	ld	s0,64(sp)
    80004f52:	74e2                	ld	s1,56(sp)
    80004f54:	7942                	ld	s2,48(sp)
    80004f56:	79a2                	ld	s3,40(sp)
    80004f58:	7a02                	ld	s4,32(sp)
    80004f5a:	6ae2                	ld	s5,24(sp)
    80004f5c:	6b42                	ld	s6,16(sp)
    80004f5e:	6ba2                	ld	s7,8(sp)
    80004f60:	6c02                	ld	s8,0(sp)
    80004f62:	6161                	addi	sp,sp,80
    80004f64:	8082                	ret
    ret = (i == n ? n : -1);
    80004f66:	5a7d                	li	s4,-1
    80004f68:	b7d5                	j	80004f4c <filewrite+0xfa>
    panic("filewrite");
    80004f6a:	00004517          	auipc	a0,0x4
    80004f6e:	8ce50513          	addi	a0,a0,-1842 # 80008838 <syscalls+0x2a0>
    80004f72:	ffffb097          	auipc	ra,0xffffb
    80004f76:	5d2080e7          	jalr	1490(ra) # 80000544 <panic>
    return -1;
    80004f7a:	5a7d                	li	s4,-1
    80004f7c:	bfc1                	j	80004f4c <filewrite+0xfa>
      return -1;
    80004f7e:	5a7d                	li	s4,-1
    80004f80:	b7f1                	j	80004f4c <filewrite+0xfa>
    80004f82:	5a7d                	li	s4,-1
    80004f84:	b7e1                	j	80004f4c <filewrite+0xfa>

0000000080004f86 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004f86:	7179                	addi	sp,sp,-48
    80004f88:	f406                	sd	ra,40(sp)
    80004f8a:	f022                	sd	s0,32(sp)
    80004f8c:	ec26                	sd	s1,24(sp)
    80004f8e:	e84a                	sd	s2,16(sp)
    80004f90:	e44e                	sd	s3,8(sp)
    80004f92:	e052                	sd	s4,0(sp)
    80004f94:	1800                	addi	s0,sp,48
    80004f96:	84aa                	mv	s1,a0
    80004f98:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004f9a:	0005b023          	sd	zero,0(a1)
    80004f9e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004fa2:	00000097          	auipc	ra,0x0
    80004fa6:	bf8080e7          	jalr	-1032(ra) # 80004b9a <filealloc>
    80004faa:	e088                	sd	a0,0(s1)
    80004fac:	c551                	beqz	a0,80005038 <pipealloc+0xb2>
    80004fae:	00000097          	auipc	ra,0x0
    80004fb2:	bec080e7          	jalr	-1044(ra) # 80004b9a <filealloc>
    80004fb6:	00aa3023          	sd	a0,0(s4)
    80004fba:	c92d                	beqz	a0,8000502c <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004fbc:	ffffc097          	auipc	ra,0xffffc
    80004fc0:	b3e080e7          	jalr	-1218(ra) # 80000afa <kalloc>
    80004fc4:	892a                	mv	s2,a0
    80004fc6:	c125                	beqz	a0,80005026 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004fc8:	4985                	li	s3,1
    80004fca:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004fce:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004fd2:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004fd6:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004fda:	00003597          	auipc	a1,0x3
    80004fde:	4be58593          	addi	a1,a1,1214 # 80008498 <states.2503+0x1b8>
    80004fe2:	ffffc097          	auipc	ra,0xffffc
    80004fe6:	b78080e7          	jalr	-1160(ra) # 80000b5a <initlock>
  (*f0)->type = FD_PIPE;
    80004fea:	609c                	ld	a5,0(s1)
    80004fec:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004ff0:	609c                	ld	a5,0(s1)
    80004ff2:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004ff6:	609c                	ld	a5,0(s1)
    80004ff8:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004ffc:	609c                	ld	a5,0(s1)
    80004ffe:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80005002:	000a3783          	ld	a5,0(s4)
    80005006:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000500a:	000a3783          	ld	a5,0(s4)
    8000500e:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005012:	000a3783          	ld	a5,0(s4)
    80005016:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000501a:	000a3783          	ld	a5,0(s4)
    8000501e:	0127b823          	sd	s2,16(a5)
  return 0;
    80005022:	4501                	li	a0,0
    80005024:	a025                	j	8000504c <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005026:	6088                	ld	a0,0(s1)
    80005028:	e501                	bnez	a0,80005030 <pipealloc+0xaa>
    8000502a:	a039                	j	80005038 <pipealloc+0xb2>
    8000502c:	6088                	ld	a0,0(s1)
    8000502e:	c51d                	beqz	a0,8000505c <pipealloc+0xd6>
    fileclose(*f0);
    80005030:	00000097          	auipc	ra,0x0
    80005034:	c26080e7          	jalr	-986(ra) # 80004c56 <fileclose>
  if(*f1)
    80005038:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000503c:	557d                	li	a0,-1
  if(*f1)
    8000503e:	c799                	beqz	a5,8000504c <pipealloc+0xc6>
    fileclose(*f1);
    80005040:	853e                	mv	a0,a5
    80005042:	00000097          	auipc	ra,0x0
    80005046:	c14080e7          	jalr	-1004(ra) # 80004c56 <fileclose>
  return -1;
    8000504a:	557d                	li	a0,-1
}
    8000504c:	70a2                	ld	ra,40(sp)
    8000504e:	7402                	ld	s0,32(sp)
    80005050:	64e2                	ld	s1,24(sp)
    80005052:	6942                	ld	s2,16(sp)
    80005054:	69a2                	ld	s3,8(sp)
    80005056:	6a02                	ld	s4,0(sp)
    80005058:	6145                	addi	sp,sp,48
    8000505a:	8082                	ret
  return -1;
    8000505c:	557d                	li	a0,-1
    8000505e:	b7fd                	j	8000504c <pipealloc+0xc6>

0000000080005060 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005060:	1101                	addi	sp,sp,-32
    80005062:	ec06                	sd	ra,24(sp)
    80005064:	e822                	sd	s0,16(sp)
    80005066:	e426                	sd	s1,8(sp)
    80005068:	e04a                	sd	s2,0(sp)
    8000506a:	1000                	addi	s0,sp,32
    8000506c:	84aa                	mv	s1,a0
    8000506e:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005070:	ffffc097          	auipc	ra,0xffffc
    80005074:	b7a080e7          	jalr	-1158(ra) # 80000bea <acquire>
  if(writable){
    80005078:	02090d63          	beqz	s2,800050b2 <pipeclose+0x52>
    pi->writeopen = 0;
    8000507c:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005080:	21848513          	addi	a0,s1,536
    80005084:	ffffd097          	auipc	ra,0xffffd
    80005088:	37e080e7          	jalr	894(ra) # 80002402 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000508c:	2204b783          	ld	a5,544(s1)
    80005090:	eb95                	bnez	a5,800050c4 <pipeclose+0x64>
    release(&pi->lock);
    80005092:	8526                	mv	a0,s1
    80005094:	ffffc097          	auipc	ra,0xffffc
    80005098:	c0a080e7          	jalr	-1014(ra) # 80000c9e <release>
    kfree((char*)pi);
    8000509c:	8526                	mv	a0,s1
    8000509e:	ffffc097          	auipc	ra,0xffffc
    800050a2:	960080e7          	jalr	-1696(ra) # 800009fe <kfree>
  } else
    release(&pi->lock);
}
    800050a6:	60e2                	ld	ra,24(sp)
    800050a8:	6442                	ld	s0,16(sp)
    800050aa:	64a2                	ld	s1,8(sp)
    800050ac:	6902                	ld	s2,0(sp)
    800050ae:	6105                	addi	sp,sp,32
    800050b0:	8082                	ret
    pi->readopen = 0;
    800050b2:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800050b6:	21c48513          	addi	a0,s1,540
    800050ba:	ffffd097          	auipc	ra,0xffffd
    800050be:	348080e7          	jalr	840(ra) # 80002402 <wakeup>
    800050c2:	b7e9                	j	8000508c <pipeclose+0x2c>
    release(&pi->lock);
    800050c4:	8526                	mv	a0,s1
    800050c6:	ffffc097          	auipc	ra,0xffffc
    800050ca:	bd8080e7          	jalr	-1064(ra) # 80000c9e <release>
}
    800050ce:	bfe1                	j	800050a6 <pipeclose+0x46>

00000000800050d0 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800050d0:	7159                	addi	sp,sp,-112
    800050d2:	f486                	sd	ra,104(sp)
    800050d4:	f0a2                	sd	s0,96(sp)
    800050d6:	eca6                	sd	s1,88(sp)
    800050d8:	e8ca                	sd	s2,80(sp)
    800050da:	e4ce                	sd	s3,72(sp)
    800050dc:	e0d2                	sd	s4,64(sp)
    800050de:	fc56                	sd	s5,56(sp)
    800050e0:	f85a                	sd	s6,48(sp)
    800050e2:	f45e                	sd	s7,40(sp)
    800050e4:	f062                	sd	s8,32(sp)
    800050e6:	ec66                	sd	s9,24(sp)
    800050e8:	1880                	addi	s0,sp,112
    800050ea:	84aa                	mv	s1,a0
    800050ec:	8aae                	mv	s5,a1
    800050ee:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800050f0:	ffffd097          	auipc	ra,0xffffd
    800050f4:	9dc080e7          	jalr	-1572(ra) # 80001acc <myproc>
    800050f8:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800050fa:	8526                	mv	a0,s1
    800050fc:	ffffc097          	auipc	ra,0xffffc
    80005100:	aee080e7          	jalr	-1298(ra) # 80000bea <acquire>
  while(i < n){
    80005104:	0d405463          	blez	s4,800051cc <pipewrite+0xfc>
    80005108:	8ba6                	mv	s7,s1
  int i = 0;
    8000510a:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000510c:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000510e:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005112:	21c48c13          	addi	s8,s1,540
    80005116:	a08d                	j	80005178 <pipewrite+0xa8>
      release(&pi->lock);
    80005118:	8526                	mv	a0,s1
    8000511a:	ffffc097          	auipc	ra,0xffffc
    8000511e:	b84080e7          	jalr	-1148(ra) # 80000c9e <release>
      return -1;
    80005122:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005124:	854a                	mv	a0,s2
    80005126:	70a6                	ld	ra,104(sp)
    80005128:	7406                	ld	s0,96(sp)
    8000512a:	64e6                	ld	s1,88(sp)
    8000512c:	6946                	ld	s2,80(sp)
    8000512e:	69a6                	ld	s3,72(sp)
    80005130:	6a06                	ld	s4,64(sp)
    80005132:	7ae2                	ld	s5,56(sp)
    80005134:	7b42                	ld	s6,48(sp)
    80005136:	7ba2                	ld	s7,40(sp)
    80005138:	7c02                	ld	s8,32(sp)
    8000513a:	6ce2                	ld	s9,24(sp)
    8000513c:	6165                	addi	sp,sp,112
    8000513e:	8082                	ret
      wakeup(&pi->nread);
    80005140:	8566                	mv	a0,s9
    80005142:	ffffd097          	auipc	ra,0xffffd
    80005146:	2c0080e7          	jalr	704(ra) # 80002402 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000514a:	85de                	mv	a1,s7
    8000514c:	8562                	mv	a0,s8
    8000514e:	ffffd097          	auipc	ra,0xffffd
    80005152:	0f2080e7          	jalr	242(ra) # 80002240 <sleep>
    80005156:	a839                	j	80005174 <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005158:	21c4a783          	lw	a5,540(s1)
    8000515c:	0017871b          	addiw	a4,a5,1
    80005160:	20e4ae23          	sw	a4,540(s1)
    80005164:	1ff7f793          	andi	a5,a5,511
    80005168:	97a6                	add	a5,a5,s1
    8000516a:	f9f44703          	lbu	a4,-97(s0)
    8000516e:	00e78c23          	sb	a4,24(a5)
      i++;
    80005172:	2905                	addiw	s2,s2,1
  while(i < n){
    80005174:	05495063          	bge	s2,s4,800051b4 <pipewrite+0xe4>
    if(pi->readopen == 0 || killed(pr)){
    80005178:	2204a783          	lw	a5,544(s1)
    8000517c:	dfd1                	beqz	a5,80005118 <pipewrite+0x48>
    8000517e:	854e                	mv	a0,s3
    80005180:	ffffd097          	auipc	ra,0xffffd
    80005184:	528080e7          	jalr	1320(ra) # 800026a8 <killed>
    80005188:	f941                	bnez	a0,80005118 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000518a:	2184a783          	lw	a5,536(s1)
    8000518e:	21c4a703          	lw	a4,540(s1)
    80005192:	2007879b          	addiw	a5,a5,512
    80005196:	faf705e3          	beq	a4,a5,80005140 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000519a:	4685                	li	a3,1
    8000519c:	01590633          	add	a2,s2,s5
    800051a0:	f9f40593          	addi	a1,s0,-97
    800051a4:	0589b503          	ld	a0,88(s3)
    800051a8:	ffffc097          	auipc	ra,0xffffc
    800051ac:	568080e7          	jalr	1384(ra) # 80001710 <copyin>
    800051b0:	fb6514e3          	bne	a0,s6,80005158 <pipewrite+0x88>
  wakeup(&pi->nread);
    800051b4:	21848513          	addi	a0,s1,536
    800051b8:	ffffd097          	auipc	ra,0xffffd
    800051bc:	24a080e7          	jalr	586(ra) # 80002402 <wakeup>
  release(&pi->lock);
    800051c0:	8526                	mv	a0,s1
    800051c2:	ffffc097          	auipc	ra,0xffffc
    800051c6:	adc080e7          	jalr	-1316(ra) # 80000c9e <release>
  return i;
    800051ca:	bfa9                	j	80005124 <pipewrite+0x54>
  int i = 0;
    800051cc:	4901                	li	s2,0
    800051ce:	b7dd                	j	800051b4 <pipewrite+0xe4>

00000000800051d0 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800051d0:	715d                	addi	sp,sp,-80
    800051d2:	e486                	sd	ra,72(sp)
    800051d4:	e0a2                	sd	s0,64(sp)
    800051d6:	fc26                	sd	s1,56(sp)
    800051d8:	f84a                	sd	s2,48(sp)
    800051da:	f44e                	sd	s3,40(sp)
    800051dc:	f052                	sd	s4,32(sp)
    800051de:	ec56                	sd	s5,24(sp)
    800051e0:	e85a                	sd	s6,16(sp)
    800051e2:	0880                	addi	s0,sp,80
    800051e4:	84aa                	mv	s1,a0
    800051e6:	892e                	mv	s2,a1
    800051e8:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800051ea:	ffffd097          	auipc	ra,0xffffd
    800051ee:	8e2080e7          	jalr	-1822(ra) # 80001acc <myproc>
    800051f2:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800051f4:	8b26                	mv	s6,s1
    800051f6:	8526                	mv	a0,s1
    800051f8:	ffffc097          	auipc	ra,0xffffc
    800051fc:	9f2080e7          	jalr	-1550(ra) # 80000bea <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005200:	2184a703          	lw	a4,536(s1)
    80005204:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005208:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000520c:	02f71763          	bne	a4,a5,8000523a <piperead+0x6a>
    80005210:	2244a783          	lw	a5,548(s1)
    80005214:	c39d                	beqz	a5,8000523a <piperead+0x6a>
    if(killed(pr)){
    80005216:	8552                	mv	a0,s4
    80005218:	ffffd097          	auipc	ra,0xffffd
    8000521c:	490080e7          	jalr	1168(ra) # 800026a8 <killed>
    80005220:	e941                	bnez	a0,800052b0 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005222:	85da                	mv	a1,s6
    80005224:	854e                	mv	a0,s3
    80005226:	ffffd097          	auipc	ra,0xffffd
    8000522a:	01a080e7          	jalr	26(ra) # 80002240 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000522e:	2184a703          	lw	a4,536(s1)
    80005232:	21c4a783          	lw	a5,540(s1)
    80005236:	fcf70de3          	beq	a4,a5,80005210 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000523a:	09505263          	blez	s5,800052be <piperead+0xee>
    8000523e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005240:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80005242:	2184a783          	lw	a5,536(s1)
    80005246:	21c4a703          	lw	a4,540(s1)
    8000524a:	02f70d63          	beq	a4,a5,80005284 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000524e:	0017871b          	addiw	a4,a5,1
    80005252:	20e4ac23          	sw	a4,536(s1)
    80005256:	1ff7f793          	andi	a5,a5,511
    8000525a:	97a6                	add	a5,a5,s1
    8000525c:	0187c783          	lbu	a5,24(a5)
    80005260:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005264:	4685                	li	a3,1
    80005266:	fbf40613          	addi	a2,s0,-65
    8000526a:	85ca                	mv	a1,s2
    8000526c:	058a3503          	ld	a0,88(s4)
    80005270:	ffffc097          	auipc	ra,0xffffc
    80005274:	414080e7          	jalr	1044(ra) # 80001684 <copyout>
    80005278:	01650663          	beq	a0,s6,80005284 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000527c:	2985                	addiw	s3,s3,1
    8000527e:	0905                	addi	s2,s2,1
    80005280:	fd3a91e3          	bne	s5,s3,80005242 <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005284:	21c48513          	addi	a0,s1,540
    80005288:	ffffd097          	auipc	ra,0xffffd
    8000528c:	17a080e7          	jalr	378(ra) # 80002402 <wakeup>
  release(&pi->lock);
    80005290:	8526                	mv	a0,s1
    80005292:	ffffc097          	auipc	ra,0xffffc
    80005296:	a0c080e7          	jalr	-1524(ra) # 80000c9e <release>
  return i;
}
    8000529a:	854e                	mv	a0,s3
    8000529c:	60a6                	ld	ra,72(sp)
    8000529e:	6406                	ld	s0,64(sp)
    800052a0:	74e2                	ld	s1,56(sp)
    800052a2:	7942                	ld	s2,48(sp)
    800052a4:	79a2                	ld	s3,40(sp)
    800052a6:	7a02                	ld	s4,32(sp)
    800052a8:	6ae2                	ld	s5,24(sp)
    800052aa:	6b42                	ld	s6,16(sp)
    800052ac:	6161                	addi	sp,sp,80
    800052ae:	8082                	ret
      release(&pi->lock);
    800052b0:	8526                	mv	a0,s1
    800052b2:	ffffc097          	auipc	ra,0xffffc
    800052b6:	9ec080e7          	jalr	-1556(ra) # 80000c9e <release>
      return -1;
    800052ba:	59fd                	li	s3,-1
    800052bc:	bff9                	j	8000529a <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800052be:	4981                	li	s3,0
    800052c0:	b7d1                	j	80005284 <piperead+0xb4>

00000000800052c2 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800052c2:	1141                	addi	sp,sp,-16
    800052c4:	e422                	sd	s0,8(sp)
    800052c6:	0800                	addi	s0,sp,16
    800052c8:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800052ca:	8905                	andi	a0,a0,1
    800052cc:	c111                	beqz	a0,800052d0 <flags2perm+0xe>
      perm = PTE_X;
    800052ce:	4521                	li	a0,8
    if(flags & 0x2)
    800052d0:	8b89                	andi	a5,a5,2
    800052d2:	c399                	beqz	a5,800052d8 <flags2perm+0x16>
      perm |= PTE_W;
    800052d4:	00456513          	ori	a0,a0,4
    return perm;
}
    800052d8:	6422                	ld	s0,8(sp)
    800052da:	0141                	addi	sp,sp,16
    800052dc:	8082                	ret

00000000800052de <exec>:

int
exec(char *path, char **argv)
{
    800052de:	df010113          	addi	sp,sp,-528
    800052e2:	20113423          	sd	ra,520(sp)
    800052e6:	20813023          	sd	s0,512(sp)
    800052ea:	ffa6                	sd	s1,504(sp)
    800052ec:	fbca                	sd	s2,496(sp)
    800052ee:	f7ce                	sd	s3,488(sp)
    800052f0:	f3d2                	sd	s4,480(sp)
    800052f2:	efd6                	sd	s5,472(sp)
    800052f4:	ebda                	sd	s6,464(sp)
    800052f6:	e7de                	sd	s7,456(sp)
    800052f8:	e3e2                	sd	s8,448(sp)
    800052fa:	ff66                	sd	s9,440(sp)
    800052fc:	fb6a                	sd	s10,432(sp)
    800052fe:	f76e                	sd	s11,424(sp)
    80005300:	0c00                	addi	s0,sp,528
    80005302:	84aa                	mv	s1,a0
    80005304:	dea43c23          	sd	a0,-520(s0)
    80005308:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000530c:	ffffc097          	auipc	ra,0xffffc
    80005310:	7c0080e7          	jalr	1984(ra) # 80001acc <myproc>
    80005314:	892a                	mv	s2,a0

  begin_op();
    80005316:	fffff097          	auipc	ra,0xfffff
    8000531a:	474080e7          	jalr	1140(ra) # 8000478a <begin_op>

  if((ip = namei(path)) == 0){
    8000531e:	8526                	mv	a0,s1
    80005320:	fffff097          	auipc	ra,0xfffff
    80005324:	24e080e7          	jalr	590(ra) # 8000456e <namei>
    80005328:	c92d                	beqz	a0,8000539a <exec+0xbc>
    8000532a:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000532c:	fffff097          	auipc	ra,0xfffff
    80005330:	a9c080e7          	jalr	-1380(ra) # 80003dc8 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005334:	04000713          	li	a4,64
    80005338:	4681                	li	a3,0
    8000533a:	e5040613          	addi	a2,s0,-432
    8000533e:	4581                	li	a1,0
    80005340:	8526                	mv	a0,s1
    80005342:	fffff097          	auipc	ra,0xfffff
    80005346:	d3a080e7          	jalr	-710(ra) # 8000407c <readi>
    8000534a:	04000793          	li	a5,64
    8000534e:	00f51a63          	bne	a0,a5,80005362 <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80005352:	e5042703          	lw	a4,-432(s0)
    80005356:	464c47b7          	lui	a5,0x464c4
    8000535a:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000535e:	04f70463          	beq	a4,a5,800053a6 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005362:	8526                	mv	a0,s1
    80005364:	fffff097          	auipc	ra,0xfffff
    80005368:	cc6080e7          	jalr	-826(ra) # 8000402a <iunlockput>
    end_op();
    8000536c:	fffff097          	auipc	ra,0xfffff
    80005370:	49e080e7          	jalr	1182(ra) # 8000480a <end_op>
  }
  return -1;
    80005374:	557d                	li	a0,-1
}
    80005376:	20813083          	ld	ra,520(sp)
    8000537a:	20013403          	ld	s0,512(sp)
    8000537e:	74fe                	ld	s1,504(sp)
    80005380:	795e                	ld	s2,496(sp)
    80005382:	79be                	ld	s3,488(sp)
    80005384:	7a1e                	ld	s4,480(sp)
    80005386:	6afe                	ld	s5,472(sp)
    80005388:	6b5e                	ld	s6,464(sp)
    8000538a:	6bbe                	ld	s7,456(sp)
    8000538c:	6c1e                	ld	s8,448(sp)
    8000538e:	7cfa                	ld	s9,440(sp)
    80005390:	7d5a                	ld	s10,432(sp)
    80005392:	7dba                	ld	s11,424(sp)
    80005394:	21010113          	addi	sp,sp,528
    80005398:	8082                	ret
    end_op();
    8000539a:	fffff097          	auipc	ra,0xfffff
    8000539e:	470080e7          	jalr	1136(ra) # 8000480a <end_op>
    return -1;
    800053a2:	557d                	li	a0,-1
    800053a4:	bfc9                	j	80005376 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    800053a6:	854a                	mv	a0,s2
    800053a8:	ffffc097          	auipc	ra,0xffffc
    800053ac:	7ea080e7          	jalr	2026(ra) # 80001b92 <proc_pagetable>
    800053b0:	8baa                	mv	s7,a0
    800053b2:	d945                	beqz	a0,80005362 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800053b4:	e7042983          	lw	s3,-400(s0)
    800053b8:	e8845783          	lhu	a5,-376(s0)
    800053bc:	c7ad                	beqz	a5,80005426 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800053be:	4a01                	li	s4,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800053c0:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    800053c2:	6c85                	lui	s9,0x1
    800053c4:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800053c8:	def43823          	sd	a5,-528(s0)
    800053cc:	ac0d                	j	800055fe <exec+0x320>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800053ce:	00003517          	auipc	a0,0x3
    800053d2:	47a50513          	addi	a0,a0,1146 # 80008848 <syscalls+0x2b0>
    800053d6:	ffffb097          	auipc	ra,0xffffb
    800053da:	16e080e7          	jalr	366(ra) # 80000544 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800053de:	8756                	mv	a4,s5
    800053e0:	012d86bb          	addw	a3,s11,s2
    800053e4:	4581                	li	a1,0
    800053e6:	8526                	mv	a0,s1
    800053e8:	fffff097          	auipc	ra,0xfffff
    800053ec:	c94080e7          	jalr	-876(ra) # 8000407c <readi>
    800053f0:	2501                	sext.w	a0,a0
    800053f2:	1aaa9a63          	bne	s5,a0,800055a6 <exec+0x2c8>
  for(i = 0; i < sz; i += PGSIZE){
    800053f6:	6785                	lui	a5,0x1
    800053f8:	0127893b          	addw	s2,a5,s2
    800053fc:	77fd                	lui	a5,0xfffff
    800053fe:	01478a3b          	addw	s4,a5,s4
    80005402:	1f897563          	bgeu	s2,s8,800055ec <exec+0x30e>
    pa = walkaddr(pagetable, va + i);
    80005406:	02091593          	slli	a1,s2,0x20
    8000540a:	9181                	srli	a1,a1,0x20
    8000540c:	95ea                	add	a1,a1,s10
    8000540e:	855e                	mv	a0,s7
    80005410:	ffffc097          	auipc	ra,0xffffc
    80005414:	c68080e7          	jalr	-920(ra) # 80001078 <walkaddr>
    80005418:	862a                	mv	a2,a0
    if(pa == 0)
    8000541a:	d955                	beqz	a0,800053ce <exec+0xf0>
      n = PGSIZE;
    8000541c:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    8000541e:	fd9a70e3          	bgeu	s4,s9,800053de <exec+0x100>
      n = sz - i;
    80005422:	8ad2                	mv	s5,s4
    80005424:	bf6d                	j	800053de <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005426:	4a01                	li	s4,0
  iunlockput(ip);
    80005428:	8526                	mv	a0,s1
    8000542a:	fffff097          	auipc	ra,0xfffff
    8000542e:	c00080e7          	jalr	-1024(ra) # 8000402a <iunlockput>
  end_op();
    80005432:	fffff097          	auipc	ra,0xfffff
    80005436:	3d8080e7          	jalr	984(ra) # 8000480a <end_op>
  p = myproc();
    8000543a:	ffffc097          	auipc	ra,0xffffc
    8000543e:	692080e7          	jalr	1682(ra) # 80001acc <myproc>
    80005442:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005444:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    80005448:	6785                	lui	a5,0x1
    8000544a:	17fd                	addi	a5,a5,-1
    8000544c:	9a3e                	add	s4,s4,a5
    8000544e:	757d                	lui	a0,0xfffff
    80005450:	00aa77b3          	and	a5,s4,a0
    80005454:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005458:	4691                	li	a3,4
    8000545a:	6609                	lui	a2,0x2
    8000545c:	963e                	add	a2,a2,a5
    8000545e:	85be                	mv	a1,a5
    80005460:	855e                	mv	a0,s7
    80005462:	ffffc097          	auipc	ra,0xffffc
    80005466:	fca080e7          	jalr	-54(ra) # 8000142c <uvmalloc>
    8000546a:	8b2a                	mv	s6,a0
  ip = 0;
    8000546c:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    8000546e:	12050c63          	beqz	a0,800055a6 <exec+0x2c8>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005472:	75f9                	lui	a1,0xffffe
    80005474:	95aa                	add	a1,a1,a0
    80005476:	855e                	mv	a0,s7
    80005478:	ffffc097          	auipc	ra,0xffffc
    8000547c:	1da080e7          	jalr	474(ra) # 80001652 <uvmclear>
  stackbase = sp - PGSIZE;
    80005480:	7c7d                	lui	s8,0xfffff
    80005482:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80005484:	e0043783          	ld	a5,-512(s0)
    80005488:	6388                	ld	a0,0(a5)
    8000548a:	c535                	beqz	a0,800054f6 <exec+0x218>
    8000548c:	e9040993          	addi	s3,s0,-368
    80005490:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80005494:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80005496:	ffffc097          	auipc	ra,0xffffc
    8000549a:	9d4080e7          	jalr	-1580(ra) # 80000e6a <strlen>
    8000549e:	2505                	addiw	a0,a0,1
    800054a0:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800054a4:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800054a8:	13896663          	bltu	s2,s8,800055d4 <exec+0x2f6>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800054ac:	e0043d83          	ld	s11,-512(s0)
    800054b0:	000dba03          	ld	s4,0(s11)
    800054b4:	8552                	mv	a0,s4
    800054b6:	ffffc097          	auipc	ra,0xffffc
    800054ba:	9b4080e7          	jalr	-1612(ra) # 80000e6a <strlen>
    800054be:	0015069b          	addiw	a3,a0,1
    800054c2:	8652                	mv	a2,s4
    800054c4:	85ca                	mv	a1,s2
    800054c6:	855e                	mv	a0,s7
    800054c8:	ffffc097          	auipc	ra,0xffffc
    800054cc:	1bc080e7          	jalr	444(ra) # 80001684 <copyout>
    800054d0:	10054663          	bltz	a0,800055dc <exec+0x2fe>
    ustack[argc] = sp;
    800054d4:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800054d8:	0485                	addi	s1,s1,1
    800054da:	008d8793          	addi	a5,s11,8
    800054de:	e0f43023          	sd	a5,-512(s0)
    800054e2:	008db503          	ld	a0,8(s11)
    800054e6:	c911                	beqz	a0,800054fa <exec+0x21c>
    if(argc >= MAXARG)
    800054e8:	09a1                	addi	s3,s3,8
    800054ea:	fb3c96e3          	bne	s9,s3,80005496 <exec+0x1b8>
  sz = sz1;
    800054ee:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800054f2:	4481                	li	s1,0
    800054f4:	a84d                	j	800055a6 <exec+0x2c8>
  sp = sz;
    800054f6:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    800054f8:	4481                	li	s1,0
  ustack[argc] = 0;
    800054fa:	00349793          	slli	a5,s1,0x3
    800054fe:	f9040713          	addi	a4,s0,-112
    80005502:	97ba                	add	a5,a5,a4
    80005504:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    80005508:	00148693          	addi	a3,s1,1
    8000550c:	068e                	slli	a3,a3,0x3
    8000550e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005512:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005516:	01897663          	bgeu	s2,s8,80005522 <exec+0x244>
  sz = sz1;
    8000551a:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000551e:	4481                	li	s1,0
    80005520:	a059                	j	800055a6 <exec+0x2c8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005522:	e9040613          	addi	a2,s0,-368
    80005526:	85ca                	mv	a1,s2
    80005528:	855e                	mv	a0,s7
    8000552a:	ffffc097          	auipc	ra,0xffffc
    8000552e:	15a080e7          	jalr	346(ra) # 80001684 <copyout>
    80005532:	0a054963          	bltz	a0,800055e4 <exec+0x306>
  p->trapframe->a1 = sp;
    80005536:	060ab783          	ld	a5,96(s5)
    8000553a:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000553e:	df843783          	ld	a5,-520(s0)
    80005542:	0007c703          	lbu	a4,0(a5)
    80005546:	cf11                	beqz	a4,80005562 <exec+0x284>
    80005548:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000554a:	02f00693          	li	a3,47
    8000554e:	a039                	j	8000555c <exec+0x27e>
      last = s+1;
    80005550:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80005554:	0785                	addi	a5,a5,1
    80005556:	fff7c703          	lbu	a4,-1(a5)
    8000555a:	c701                	beqz	a4,80005562 <exec+0x284>
    if(*s == '/')
    8000555c:	fed71ce3          	bne	a4,a3,80005554 <exec+0x276>
    80005560:	bfc5                	j	80005550 <exec+0x272>
  safestrcpy(p->name, last, sizeof(p->name));
    80005562:	4641                	li	a2,16
    80005564:	df843583          	ld	a1,-520(s0)
    80005568:	160a8513          	addi	a0,s5,352
    8000556c:	ffffc097          	auipc	ra,0xffffc
    80005570:	8cc080e7          	jalr	-1844(ra) # 80000e38 <safestrcpy>
  oldpagetable = p->pagetable;
    80005574:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    80005578:	057abc23          	sd	s7,88(s5)
  p->sz = sz;
    8000557c:	056ab823          	sd	s6,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005580:	060ab783          	ld	a5,96(s5)
    80005584:	e6843703          	ld	a4,-408(s0)
    80005588:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000558a:	060ab783          	ld	a5,96(s5)
    8000558e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005592:	85ea                	mv	a1,s10
    80005594:	ffffc097          	auipc	ra,0xffffc
    80005598:	69a080e7          	jalr	1690(ra) # 80001c2e <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000559c:	0004851b          	sext.w	a0,s1
    800055a0:	bbd9                	j	80005376 <exec+0x98>
    800055a2:	e1443423          	sd	s4,-504(s0)
    proc_freepagetable(pagetable, sz);
    800055a6:	e0843583          	ld	a1,-504(s0)
    800055aa:	855e                	mv	a0,s7
    800055ac:	ffffc097          	auipc	ra,0xffffc
    800055b0:	682080e7          	jalr	1666(ra) # 80001c2e <proc_freepagetable>
  if(ip){
    800055b4:	da0497e3          	bnez	s1,80005362 <exec+0x84>
  return -1;
    800055b8:	557d                	li	a0,-1
    800055ba:	bb75                	j	80005376 <exec+0x98>
    800055bc:	e1443423          	sd	s4,-504(s0)
    800055c0:	b7dd                	j	800055a6 <exec+0x2c8>
    800055c2:	e1443423          	sd	s4,-504(s0)
    800055c6:	b7c5                	j	800055a6 <exec+0x2c8>
    800055c8:	e1443423          	sd	s4,-504(s0)
    800055cc:	bfe9                	j	800055a6 <exec+0x2c8>
    800055ce:	e1443423          	sd	s4,-504(s0)
    800055d2:	bfd1                	j	800055a6 <exec+0x2c8>
  sz = sz1;
    800055d4:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800055d8:	4481                	li	s1,0
    800055da:	b7f1                	j	800055a6 <exec+0x2c8>
  sz = sz1;
    800055dc:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800055e0:	4481                	li	s1,0
    800055e2:	b7d1                	j	800055a6 <exec+0x2c8>
  sz = sz1;
    800055e4:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800055e8:	4481                	li	s1,0
    800055ea:	bf75                	j	800055a6 <exec+0x2c8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800055ec:	e0843a03          	ld	s4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800055f0:	2b05                	addiw	s6,s6,1
    800055f2:	0389899b          	addiw	s3,s3,56
    800055f6:	e8845783          	lhu	a5,-376(s0)
    800055fa:	e2fb57e3          	bge	s6,a5,80005428 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800055fe:	2981                	sext.w	s3,s3
    80005600:	03800713          	li	a4,56
    80005604:	86ce                	mv	a3,s3
    80005606:	e1840613          	addi	a2,s0,-488
    8000560a:	4581                	li	a1,0
    8000560c:	8526                	mv	a0,s1
    8000560e:	fffff097          	auipc	ra,0xfffff
    80005612:	a6e080e7          	jalr	-1426(ra) # 8000407c <readi>
    80005616:	03800793          	li	a5,56
    8000561a:	f8f514e3          	bne	a0,a5,800055a2 <exec+0x2c4>
    if(ph.type != ELF_PROG_LOAD)
    8000561e:	e1842783          	lw	a5,-488(s0)
    80005622:	4705                	li	a4,1
    80005624:	fce796e3          	bne	a5,a4,800055f0 <exec+0x312>
    if(ph.memsz < ph.filesz)
    80005628:	e4043903          	ld	s2,-448(s0)
    8000562c:	e3843783          	ld	a5,-456(s0)
    80005630:	f8f966e3          	bltu	s2,a5,800055bc <exec+0x2de>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005634:	e2843783          	ld	a5,-472(s0)
    80005638:	993e                	add	s2,s2,a5
    8000563a:	f8f964e3          	bltu	s2,a5,800055c2 <exec+0x2e4>
    if(ph.vaddr % PGSIZE != 0)
    8000563e:	df043703          	ld	a4,-528(s0)
    80005642:	8ff9                	and	a5,a5,a4
    80005644:	f3d1                	bnez	a5,800055c8 <exec+0x2ea>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005646:	e1c42503          	lw	a0,-484(s0)
    8000564a:	00000097          	auipc	ra,0x0
    8000564e:	c78080e7          	jalr	-904(ra) # 800052c2 <flags2perm>
    80005652:	86aa                	mv	a3,a0
    80005654:	864a                	mv	a2,s2
    80005656:	85d2                	mv	a1,s4
    80005658:	855e                	mv	a0,s7
    8000565a:	ffffc097          	auipc	ra,0xffffc
    8000565e:	dd2080e7          	jalr	-558(ra) # 8000142c <uvmalloc>
    80005662:	e0a43423          	sd	a0,-504(s0)
    80005666:	d525                	beqz	a0,800055ce <exec+0x2f0>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005668:	e2843d03          	ld	s10,-472(s0)
    8000566c:	e2042d83          	lw	s11,-480(s0)
    80005670:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005674:	f60c0ce3          	beqz	s8,800055ec <exec+0x30e>
    80005678:	8a62                	mv	s4,s8
    8000567a:	4901                	li	s2,0
    8000567c:	b369                	j	80005406 <exec+0x128>

000000008000567e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000567e:	7179                	addi	sp,sp,-48
    80005680:	f406                	sd	ra,40(sp)
    80005682:	f022                	sd	s0,32(sp)
    80005684:	ec26                	sd	s1,24(sp)
    80005686:	e84a                	sd	s2,16(sp)
    80005688:	1800                	addi	s0,sp,48
    8000568a:	892e                	mv	s2,a1
    8000568c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000568e:	fdc40593          	addi	a1,s0,-36
    80005692:	ffffe097          	auipc	ra,0xffffe
    80005696:	89a080e7          	jalr	-1894(ra) # 80002f2c <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000569a:	fdc42703          	lw	a4,-36(s0)
    8000569e:	47bd                	li	a5,15
    800056a0:	02e7eb63          	bltu	a5,a4,800056d6 <argfd+0x58>
    800056a4:	ffffc097          	auipc	ra,0xffffc
    800056a8:	428080e7          	jalr	1064(ra) # 80001acc <myproc>
    800056ac:	fdc42703          	lw	a4,-36(s0)
    800056b0:	01a70793          	addi	a5,a4,26
    800056b4:	078e                	slli	a5,a5,0x3
    800056b6:	953e                	add	a0,a0,a5
    800056b8:	651c                	ld	a5,8(a0)
    800056ba:	c385                	beqz	a5,800056da <argfd+0x5c>
    return -1;
  if(pfd)
    800056bc:	00090463          	beqz	s2,800056c4 <argfd+0x46>
    *pfd = fd;
    800056c0:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800056c4:	4501                	li	a0,0
  if(pf)
    800056c6:	c091                	beqz	s1,800056ca <argfd+0x4c>
    *pf = f;
    800056c8:	e09c                	sd	a5,0(s1)
}
    800056ca:	70a2                	ld	ra,40(sp)
    800056cc:	7402                	ld	s0,32(sp)
    800056ce:	64e2                	ld	s1,24(sp)
    800056d0:	6942                	ld	s2,16(sp)
    800056d2:	6145                	addi	sp,sp,48
    800056d4:	8082                	ret
    return -1;
    800056d6:	557d                	li	a0,-1
    800056d8:	bfcd                	j	800056ca <argfd+0x4c>
    800056da:	557d                	li	a0,-1
    800056dc:	b7fd                	j	800056ca <argfd+0x4c>

00000000800056de <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800056de:	1101                	addi	sp,sp,-32
    800056e0:	ec06                	sd	ra,24(sp)
    800056e2:	e822                	sd	s0,16(sp)
    800056e4:	e426                	sd	s1,8(sp)
    800056e6:	1000                	addi	s0,sp,32
    800056e8:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800056ea:	ffffc097          	auipc	ra,0xffffc
    800056ee:	3e2080e7          	jalr	994(ra) # 80001acc <myproc>
    800056f2:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800056f4:	0d850793          	addi	a5,a0,216 # fffffffffffff0d8 <end+0xffffffff7ffdae28>
    800056f8:	4501                	li	a0,0
    800056fa:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800056fc:	6398                	ld	a4,0(a5)
    800056fe:	cb19                	beqz	a4,80005714 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005700:	2505                	addiw	a0,a0,1
    80005702:	07a1                	addi	a5,a5,8
    80005704:	fed51ce3          	bne	a0,a3,800056fc <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005708:	557d                	li	a0,-1
}
    8000570a:	60e2                	ld	ra,24(sp)
    8000570c:	6442                	ld	s0,16(sp)
    8000570e:	64a2                	ld	s1,8(sp)
    80005710:	6105                	addi	sp,sp,32
    80005712:	8082                	ret
      p->ofile[fd] = f;
    80005714:	01a50793          	addi	a5,a0,26
    80005718:	078e                	slli	a5,a5,0x3
    8000571a:	963e                	add	a2,a2,a5
    8000571c:	e604                	sd	s1,8(a2)
      return fd;
    8000571e:	b7f5                	j	8000570a <fdalloc+0x2c>

0000000080005720 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005720:	715d                	addi	sp,sp,-80
    80005722:	e486                	sd	ra,72(sp)
    80005724:	e0a2                	sd	s0,64(sp)
    80005726:	fc26                	sd	s1,56(sp)
    80005728:	f84a                	sd	s2,48(sp)
    8000572a:	f44e                	sd	s3,40(sp)
    8000572c:	f052                	sd	s4,32(sp)
    8000572e:	ec56                	sd	s5,24(sp)
    80005730:	e85a                	sd	s6,16(sp)
    80005732:	0880                	addi	s0,sp,80
    80005734:	8b2e                	mv	s6,a1
    80005736:	89b2                	mv	s3,a2
    80005738:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000573a:	fb040593          	addi	a1,s0,-80
    8000573e:	fffff097          	auipc	ra,0xfffff
    80005742:	e4e080e7          	jalr	-434(ra) # 8000458c <nameiparent>
    80005746:	84aa                	mv	s1,a0
    80005748:	16050063          	beqz	a0,800058a8 <create+0x188>
    return 0;

  ilock(dp);
    8000574c:	ffffe097          	auipc	ra,0xffffe
    80005750:	67c080e7          	jalr	1660(ra) # 80003dc8 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005754:	4601                	li	a2,0
    80005756:	fb040593          	addi	a1,s0,-80
    8000575a:	8526                	mv	a0,s1
    8000575c:	fffff097          	auipc	ra,0xfffff
    80005760:	b50080e7          	jalr	-1200(ra) # 800042ac <dirlookup>
    80005764:	8aaa                	mv	s5,a0
    80005766:	c931                	beqz	a0,800057ba <create+0x9a>
    iunlockput(dp);
    80005768:	8526                	mv	a0,s1
    8000576a:	fffff097          	auipc	ra,0xfffff
    8000576e:	8c0080e7          	jalr	-1856(ra) # 8000402a <iunlockput>
    ilock(ip);
    80005772:	8556                	mv	a0,s5
    80005774:	ffffe097          	auipc	ra,0xffffe
    80005778:	654080e7          	jalr	1620(ra) # 80003dc8 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000577c:	000b059b          	sext.w	a1,s6
    80005780:	4789                	li	a5,2
    80005782:	02f59563          	bne	a1,a5,800057ac <create+0x8c>
    80005786:	044ad783          	lhu	a5,68(s5)
    8000578a:	37f9                	addiw	a5,a5,-2
    8000578c:	17c2                	slli	a5,a5,0x30
    8000578e:	93c1                	srli	a5,a5,0x30
    80005790:	4705                	li	a4,1
    80005792:	00f76d63          	bltu	a4,a5,800057ac <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005796:	8556                	mv	a0,s5
    80005798:	60a6                	ld	ra,72(sp)
    8000579a:	6406                	ld	s0,64(sp)
    8000579c:	74e2                	ld	s1,56(sp)
    8000579e:	7942                	ld	s2,48(sp)
    800057a0:	79a2                	ld	s3,40(sp)
    800057a2:	7a02                	ld	s4,32(sp)
    800057a4:	6ae2                	ld	s5,24(sp)
    800057a6:	6b42                	ld	s6,16(sp)
    800057a8:	6161                	addi	sp,sp,80
    800057aa:	8082                	ret
    iunlockput(ip);
    800057ac:	8556                	mv	a0,s5
    800057ae:	fffff097          	auipc	ra,0xfffff
    800057b2:	87c080e7          	jalr	-1924(ra) # 8000402a <iunlockput>
    return 0;
    800057b6:	4a81                	li	s5,0
    800057b8:	bff9                	j	80005796 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800057ba:	85da                	mv	a1,s6
    800057bc:	4088                	lw	a0,0(s1)
    800057be:	ffffe097          	auipc	ra,0xffffe
    800057c2:	46e080e7          	jalr	1134(ra) # 80003c2c <ialloc>
    800057c6:	8a2a                	mv	s4,a0
    800057c8:	c921                	beqz	a0,80005818 <create+0xf8>
  ilock(ip);
    800057ca:	ffffe097          	auipc	ra,0xffffe
    800057ce:	5fe080e7          	jalr	1534(ra) # 80003dc8 <ilock>
  ip->major = major;
    800057d2:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800057d6:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800057da:	4785                	li	a5,1
    800057dc:	04fa1523          	sh	a5,74(s4)
  iupdate(ip);
    800057e0:	8552                	mv	a0,s4
    800057e2:	ffffe097          	auipc	ra,0xffffe
    800057e6:	51c080e7          	jalr	1308(ra) # 80003cfe <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800057ea:	000b059b          	sext.w	a1,s6
    800057ee:	4785                	li	a5,1
    800057f0:	02f58b63          	beq	a1,a5,80005826 <create+0x106>
  if(dirlink(dp, name, ip->inum) < 0)
    800057f4:	004a2603          	lw	a2,4(s4)
    800057f8:	fb040593          	addi	a1,s0,-80
    800057fc:	8526                	mv	a0,s1
    800057fe:	fffff097          	auipc	ra,0xfffff
    80005802:	cbe080e7          	jalr	-834(ra) # 800044bc <dirlink>
    80005806:	06054f63          	bltz	a0,80005884 <create+0x164>
  iunlockput(dp);
    8000580a:	8526                	mv	a0,s1
    8000580c:	fffff097          	auipc	ra,0xfffff
    80005810:	81e080e7          	jalr	-2018(ra) # 8000402a <iunlockput>
  return ip;
    80005814:	8ad2                	mv	s5,s4
    80005816:	b741                	j	80005796 <create+0x76>
    iunlockput(dp);
    80005818:	8526                	mv	a0,s1
    8000581a:	fffff097          	auipc	ra,0xfffff
    8000581e:	810080e7          	jalr	-2032(ra) # 8000402a <iunlockput>
    return 0;
    80005822:	8ad2                	mv	s5,s4
    80005824:	bf8d                	j	80005796 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005826:	004a2603          	lw	a2,4(s4)
    8000582a:	00003597          	auipc	a1,0x3
    8000582e:	03e58593          	addi	a1,a1,62 # 80008868 <syscalls+0x2d0>
    80005832:	8552                	mv	a0,s4
    80005834:	fffff097          	auipc	ra,0xfffff
    80005838:	c88080e7          	jalr	-888(ra) # 800044bc <dirlink>
    8000583c:	04054463          	bltz	a0,80005884 <create+0x164>
    80005840:	40d0                	lw	a2,4(s1)
    80005842:	00003597          	auipc	a1,0x3
    80005846:	02e58593          	addi	a1,a1,46 # 80008870 <syscalls+0x2d8>
    8000584a:	8552                	mv	a0,s4
    8000584c:	fffff097          	auipc	ra,0xfffff
    80005850:	c70080e7          	jalr	-912(ra) # 800044bc <dirlink>
    80005854:	02054863          	bltz	a0,80005884 <create+0x164>
  if(dirlink(dp, name, ip->inum) < 0)
    80005858:	004a2603          	lw	a2,4(s4)
    8000585c:	fb040593          	addi	a1,s0,-80
    80005860:	8526                	mv	a0,s1
    80005862:	fffff097          	auipc	ra,0xfffff
    80005866:	c5a080e7          	jalr	-934(ra) # 800044bc <dirlink>
    8000586a:	00054d63          	bltz	a0,80005884 <create+0x164>
    dp->nlink++;  // for ".."
    8000586e:	04a4d783          	lhu	a5,74(s1)
    80005872:	2785                	addiw	a5,a5,1
    80005874:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005878:	8526                	mv	a0,s1
    8000587a:	ffffe097          	auipc	ra,0xffffe
    8000587e:	484080e7          	jalr	1156(ra) # 80003cfe <iupdate>
    80005882:	b761                	j	8000580a <create+0xea>
  ip->nlink = 0;
    80005884:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005888:	8552                	mv	a0,s4
    8000588a:	ffffe097          	auipc	ra,0xffffe
    8000588e:	474080e7          	jalr	1140(ra) # 80003cfe <iupdate>
  iunlockput(ip);
    80005892:	8552                	mv	a0,s4
    80005894:	ffffe097          	auipc	ra,0xffffe
    80005898:	796080e7          	jalr	1942(ra) # 8000402a <iunlockput>
  iunlockput(dp);
    8000589c:	8526                	mv	a0,s1
    8000589e:	ffffe097          	auipc	ra,0xffffe
    800058a2:	78c080e7          	jalr	1932(ra) # 8000402a <iunlockput>
  return 0;
    800058a6:	bdc5                	j	80005796 <create+0x76>
    return 0;
    800058a8:	8aaa                	mv	s5,a0
    800058aa:	b5f5                	j	80005796 <create+0x76>

00000000800058ac <sys_dup>:
{
    800058ac:	7179                	addi	sp,sp,-48
    800058ae:	f406                	sd	ra,40(sp)
    800058b0:	f022                	sd	s0,32(sp)
    800058b2:	ec26                	sd	s1,24(sp)
    800058b4:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800058b6:	fd840613          	addi	a2,s0,-40
    800058ba:	4581                	li	a1,0
    800058bc:	4501                	li	a0,0
    800058be:	00000097          	auipc	ra,0x0
    800058c2:	dc0080e7          	jalr	-576(ra) # 8000567e <argfd>
    return -1;
    800058c6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800058c8:	02054363          	bltz	a0,800058ee <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800058cc:	fd843503          	ld	a0,-40(s0)
    800058d0:	00000097          	auipc	ra,0x0
    800058d4:	e0e080e7          	jalr	-498(ra) # 800056de <fdalloc>
    800058d8:	84aa                	mv	s1,a0
    return -1;
    800058da:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800058dc:	00054963          	bltz	a0,800058ee <sys_dup+0x42>
  filedup(f);
    800058e0:	fd843503          	ld	a0,-40(s0)
    800058e4:	fffff097          	auipc	ra,0xfffff
    800058e8:	320080e7          	jalr	800(ra) # 80004c04 <filedup>
  return fd;
    800058ec:	87a6                	mv	a5,s1
}
    800058ee:	853e                	mv	a0,a5
    800058f0:	70a2                	ld	ra,40(sp)
    800058f2:	7402                	ld	s0,32(sp)
    800058f4:	64e2                	ld	s1,24(sp)
    800058f6:	6145                	addi	sp,sp,48
    800058f8:	8082                	ret

00000000800058fa <sys_read>:
{
    800058fa:	7179                	addi	sp,sp,-48
    800058fc:	f406                	sd	ra,40(sp)
    800058fe:	f022                	sd	s0,32(sp)
    80005900:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005902:	fd840593          	addi	a1,s0,-40
    80005906:	4505                	li	a0,1
    80005908:	ffffd097          	auipc	ra,0xffffd
    8000590c:	644080e7          	jalr	1604(ra) # 80002f4c <argaddr>
  argint(2, &n);
    80005910:	fe440593          	addi	a1,s0,-28
    80005914:	4509                	li	a0,2
    80005916:	ffffd097          	auipc	ra,0xffffd
    8000591a:	616080e7          	jalr	1558(ra) # 80002f2c <argint>
  if(argfd(0, 0, &f) < 0)
    8000591e:	fe840613          	addi	a2,s0,-24
    80005922:	4581                	li	a1,0
    80005924:	4501                	li	a0,0
    80005926:	00000097          	auipc	ra,0x0
    8000592a:	d58080e7          	jalr	-680(ra) # 8000567e <argfd>
    8000592e:	87aa                	mv	a5,a0
    return -1;
    80005930:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005932:	0007cc63          	bltz	a5,8000594a <sys_read+0x50>
  return fileread(f, p, n);
    80005936:	fe442603          	lw	a2,-28(s0)
    8000593a:	fd843583          	ld	a1,-40(s0)
    8000593e:	fe843503          	ld	a0,-24(s0)
    80005942:	fffff097          	auipc	ra,0xfffff
    80005946:	44e080e7          	jalr	1102(ra) # 80004d90 <fileread>
}
    8000594a:	70a2                	ld	ra,40(sp)
    8000594c:	7402                	ld	s0,32(sp)
    8000594e:	6145                	addi	sp,sp,48
    80005950:	8082                	ret

0000000080005952 <sys_write>:
{
    80005952:	7179                	addi	sp,sp,-48
    80005954:	f406                	sd	ra,40(sp)
    80005956:	f022                	sd	s0,32(sp)
    80005958:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000595a:	fd840593          	addi	a1,s0,-40
    8000595e:	4505                	li	a0,1
    80005960:	ffffd097          	auipc	ra,0xffffd
    80005964:	5ec080e7          	jalr	1516(ra) # 80002f4c <argaddr>
  argint(2, &n);
    80005968:	fe440593          	addi	a1,s0,-28
    8000596c:	4509                	li	a0,2
    8000596e:	ffffd097          	auipc	ra,0xffffd
    80005972:	5be080e7          	jalr	1470(ra) # 80002f2c <argint>
  if(argfd(0, 0, &f) < 0)
    80005976:	fe840613          	addi	a2,s0,-24
    8000597a:	4581                	li	a1,0
    8000597c:	4501                	li	a0,0
    8000597e:	00000097          	auipc	ra,0x0
    80005982:	d00080e7          	jalr	-768(ra) # 8000567e <argfd>
    80005986:	87aa                	mv	a5,a0
    return -1;
    80005988:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000598a:	0007cc63          	bltz	a5,800059a2 <sys_write+0x50>
  return filewrite(f, p, n);
    8000598e:	fe442603          	lw	a2,-28(s0)
    80005992:	fd843583          	ld	a1,-40(s0)
    80005996:	fe843503          	ld	a0,-24(s0)
    8000599a:	fffff097          	auipc	ra,0xfffff
    8000599e:	4b8080e7          	jalr	1208(ra) # 80004e52 <filewrite>
}
    800059a2:	70a2                	ld	ra,40(sp)
    800059a4:	7402                	ld	s0,32(sp)
    800059a6:	6145                	addi	sp,sp,48
    800059a8:	8082                	ret

00000000800059aa <sys_close>:
{
    800059aa:	1101                	addi	sp,sp,-32
    800059ac:	ec06                	sd	ra,24(sp)
    800059ae:	e822                	sd	s0,16(sp)
    800059b0:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800059b2:	fe040613          	addi	a2,s0,-32
    800059b6:	fec40593          	addi	a1,s0,-20
    800059ba:	4501                	li	a0,0
    800059bc:	00000097          	auipc	ra,0x0
    800059c0:	cc2080e7          	jalr	-830(ra) # 8000567e <argfd>
    return -1;
    800059c4:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800059c6:	02054463          	bltz	a0,800059ee <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800059ca:	ffffc097          	auipc	ra,0xffffc
    800059ce:	102080e7          	jalr	258(ra) # 80001acc <myproc>
    800059d2:	fec42783          	lw	a5,-20(s0)
    800059d6:	07e9                	addi	a5,a5,26
    800059d8:	078e                	slli	a5,a5,0x3
    800059da:	97aa                	add	a5,a5,a0
    800059dc:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    800059e0:	fe043503          	ld	a0,-32(s0)
    800059e4:	fffff097          	auipc	ra,0xfffff
    800059e8:	272080e7          	jalr	626(ra) # 80004c56 <fileclose>
  return 0;
    800059ec:	4781                	li	a5,0
}
    800059ee:	853e                	mv	a0,a5
    800059f0:	60e2                	ld	ra,24(sp)
    800059f2:	6442                	ld	s0,16(sp)
    800059f4:	6105                	addi	sp,sp,32
    800059f6:	8082                	ret

00000000800059f8 <sys_fstat>:
{
    800059f8:	1101                	addi	sp,sp,-32
    800059fa:	ec06                	sd	ra,24(sp)
    800059fc:	e822                	sd	s0,16(sp)
    800059fe:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005a00:	fe040593          	addi	a1,s0,-32
    80005a04:	4505                	li	a0,1
    80005a06:	ffffd097          	auipc	ra,0xffffd
    80005a0a:	546080e7          	jalr	1350(ra) # 80002f4c <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005a0e:	fe840613          	addi	a2,s0,-24
    80005a12:	4581                	li	a1,0
    80005a14:	4501                	li	a0,0
    80005a16:	00000097          	auipc	ra,0x0
    80005a1a:	c68080e7          	jalr	-920(ra) # 8000567e <argfd>
    80005a1e:	87aa                	mv	a5,a0
    return -1;
    80005a20:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005a22:	0007ca63          	bltz	a5,80005a36 <sys_fstat+0x3e>
  return filestat(f, st);
    80005a26:	fe043583          	ld	a1,-32(s0)
    80005a2a:	fe843503          	ld	a0,-24(s0)
    80005a2e:	fffff097          	auipc	ra,0xfffff
    80005a32:	2f0080e7          	jalr	752(ra) # 80004d1e <filestat>
}
    80005a36:	60e2                	ld	ra,24(sp)
    80005a38:	6442                	ld	s0,16(sp)
    80005a3a:	6105                	addi	sp,sp,32
    80005a3c:	8082                	ret

0000000080005a3e <sys_link>:
{
    80005a3e:	7169                	addi	sp,sp,-304
    80005a40:	f606                	sd	ra,296(sp)
    80005a42:	f222                	sd	s0,288(sp)
    80005a44:	ee26                	sd	s1,280(sp)
    80005a46:	ea4a                	sd	s2,272(sp)
    80005a48:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005a4a:	08000613          	li	a2,128
    80005a4e:	ed040593          	addi	a1,s0,-304
    80005a52:	4501                	li	a0,0
    80005a54:	ffffd097          	auipc	ra,0xffffd
    80005a58:	518080e7          	jalr	1304(ra) # 80002f6c <argstr>
    return -1;
    80005a5c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005a5e:	10054e63          	bltz	a0,80005b7a <sys_link+0x13c>
    80005a62:	08000613          	li	a2,128
    80005a66:	f5040593          	addi	a1,s0,-176
    80005a6a:	4505                	li	a0,1
    80005a6c:	ffffd097          	auipc	ra,0xffffd
    80005a70:	500080e7          	jalr	1280(ra) # 80002f6c <argstr>
    return -1;
    80005a74:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005a76:	10054263          	bltz	a0,80005b7a <sys_link+0x13c>
  begin_op();
    80005a7a:	fffff097          	auipc	ra,0xfffff
    80005a7e:	d10080e7          	jalr	-752(ra) # 8000478a <begin_op>
  if((ip = namei(old)) == 0){
    80005a82:	ed040513          	addi	a0,s0,-304
    80005a86:	fffff097          	auipc	ra,0xfffff
    80005a8a:	ae8080e7          	jalr	-1304(ra) # 8000456e <namei>
    80005a8e:	84aa                	mv	s1,a0
    80005a90:	c551                	beqz	a0,80005b1c <sys_link+0xde>
  ilock(ip);
    80005a92:	ffffe097          	auipc	ra,0xffffe
    80005a96:	336080e7          	jalr	822(ra) # 80003dc8 <ilock>
  if(ip->type == T_DIR){
    80005a9a:	04449703          	lh	a4,68(s1)
    80005a9e:	4785                	li	a5,1
    80005aa0:	08f70463          	beq	a4,a5,80005b28 <sys_link+0xea>
  ip->nlink++;
    80005aa4:	04a4d783          	lhu	a5,74(s1)
    80005aa8:	2785                	addiw	a5,a5,1
    80005aaa:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005aae:	8526                	mv	a0,s1
    80005ab0:	ffffe097          	auipc	ra,0xffffe
    80005ab4:	24e080e7          	jalr	590(ra) # 80003cfe <iupdate>
  iunlock(ip);
    80005ab8:	8526                	mv	a0,s1
    80005aba:	ffffe097          	auipc	ra,0xffffe
    80005abe:	3d0080e7          	jalr	976(ra) # 80003e8a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005ac2:	fd040593          	addi	a1,s0,-48
    80005ac6:	f5040513          	addi	a0,s0,-176
    80005aca:	fffff097          	auipc	ra,0xfffff
    80005ace:	ac2080e7          	jalr	-1342(ra) # 8000458c <nameiparent>
    80005ad2:	892a                	mv	s2,a0
    80005ad4:	c935                	beqz	a0,80005b48 <sys_link+0x10a>
  ilock(dp);
    80005ad6:	ffffe097          	auipc	ra,0xffffe
    80005ada:	2f2080e7          	jalr	754(ra) # 80003dc8 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005ade:	00092703          	lw	a4,0(s2)
    80005ae2:	409c                	lw	a5,0(s1)
    80005ae4:	04f71d63          	bne	a4,a5,80005b3e <sys_link+0x100>
    80005ae8:	40d0                	lw	a2,4(s1)
    80005aea:	fd040593          	addi	a1,s0,-48
    80005aee:	854a                	mv	a0,s2
    80005af0:	fffff097          	auipc	ra,0xfffff
    80005af4:	9cc080e7          	jalr	-1588(ra) # 800044bc <dirlink>
    80005af8:	04054363          	bltz	a0,80005b3e <sys_link+0x100>
  iunlockput(dp);
    80005afc:	854a                	mv	a0,s2
    80005afe:	ffffe097          	auipc	ra,0xffffe
    80005b02:	52c080e7          	jalr	1324(ra) # 8000402a <iunlockput>
  iput(ip);
    80005b06:	8526                	mv	a0,s1
    80005b08:	ffffe097          	auipc	ra,0xffffe
    80005b0c:	47a080e7          	jalr	1146(ra) # 80003f82 <iput>
  end_op();
    80005b10:	fffff097          	auipc	ra,0xfffff
    80005b14:	cfa080e7          	jalr	-774(ra) # 8000480a <end_op>
  return 0;
    80005b18:	4781                	li	a5,0
    80005b1a:	a085                	j	80005b7a <sys_link+0x13c>
    end_op();
    80005b1c:	fffff097          	auipc	ra,0xfffff
    80005b20:	cee080e7          	jalr	-786(ra) # 8000480a <end_op>
    return -1;
    80005b24:	57fd                	li	a5,-1
    80005b26:	a891                	j	80005b7a <sys_link+0x13c>
    iunlockput(ip);
    80005b28:	8526                	mv	a0,s1
    80005b2a:	ffffe097          	auipc	ra,0xffffe
    80005b2e:	500080e7          	jalr	1280(ra) # 8000402a <iunlockput>
    end_op();
    80005b32:	fffff097          	auipc	ra,0xfffff
    80005b36:	cd8080e7          	jalr	-808(ra) # 8000480a <end_op>
    return -1;
    80005b3a:	57fd                	li	a5,-1
    80005b3c:	a83d                	j	80005b7a <sys_link+0x13c>
    iunlockput(dp);
    80005b3e:	854a                	mv	a0,s2
    80005b40:	ffffe097          	auipc	ra,0xffffe
    80005b44:	4ea080e7          	jalr	1258(ra) # 8000402a <iunlockput>
  ilock(ip);
    80005b48:	8526                	mv	a0,s1
    80005b4a:	ffffe097          	auipc	ra,0xffffe
    80005b4e:	27e080e7          	jalr	638(ra) # 80003dc8 <ilock>
  ip->nlink--;
    80005b52:	04a4d783          	lhu	a5,74(s1)
    80005b56:	37fd                	addiw	a5,a5,-1
    80005b58:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005b5c:	8526                	mv	a0,s1
    80005b5e:	ffffe097          	auipc	ra,0xffffe
    80005b62:	1a0080e7          	jalr	416(ra) # 80003cfe <iupdate>
  iunlockput(ip);
    80005b66:	8526                	mv	a0,s1
    80005b68:	ffffe097          	auipc	ra,0xffffe
    80005b6c:	4c2080e7          	jalr	1218(ra) # 8000402a <iunlockput>
  end_op();
    80005b70:	fffff097          	auipc	ra,0xfffff
    80005b74:	c9a080e7          	jalr	-870(ra) # 8000480a <end_op>
  return -1;
    80005b78:	57fd                	li	a5,-1
}
    80005b7a:	853e                	mv	a0,a5
    80005b7c:	70b2                	ld	ra,296(sp)
    80005b7e:	7412                	ld	s0,288(sp)
    80005b80:	64f2                	ld	s1,280(sp)
    80005b82:	6952                	ld	s2,272(sp)
    80005b84:	6155                	addi	sp,sp,304
    80005b86:	8082                	ret

0000000080005b88 <sys_unlink>:
{
    80005b88:	7151                	addi	sp,sp,-240
    80005b8a:	f586                	sd	ra,232(sp)
    80005b8c:	f1a2                	sd	s0,224(sp)
    80005b8e:	eda6                	sd	s1,216(sp)
    80005b90:	e9ca                	sd	s2,208(sp)
    80005b92:	e5ce                	sd	s3,200(sp)
    80005b94:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005b96:	08000613          	li	a2,128
    80005b9a:	f3040593          	addi	a1,s0,-208
    80005b9e:	4501                	li	a0,0
    80005ba0:	ffffd097          	auipc	ra,0xffffd
    80005ba4:	3cc080e7          	jalr	972(ra) # 80002f6c <argstr>
    80005ba8:	18054163          	bltz	a0,80005d2a <sys_unlink+0x1a2>
  begin_op();
    80005bac:	fffff097          	auipc	ra,0xfffff
    80005bb0:	bde080e7          	jalr	-1058(ra) # 8000478a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005bb4:	fb040593          	addi	a1,s0,-80
    80005bb8:	f3040513          	addi	a0,s0,-208
    80005bbc:	fffff097          	auipc	ra,0xfffff
    80005bc0:	9d0080e7          	jalr	-1584(ra) # 8000458c <nameiparent>
    80005bc4:	84aa                	mv	s1,a0
    80005bc6:	c979                	beqz	a0,80005c9c <sys_unlink+0x114>
  ilock(dp);
    80005bc8:	ffffe097          	auipc	ra,0xffffe
    80005bcc:	200080e7          	jalr	512(ra) # 80003dc8 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005bd0:	00003597          	auipc	a1,0x3
    80005bd4:	c9858593          	addi	a1,a1,-872 # 80008868 <syscalls+0x2d0>
    80005bd8:	fb040513          	addi	a0,s0,-80
    80005bdc:	ffffe097          	auipc	ra,0xffffe
    80005be0:	6b6080e7          	jalr	1718(ra) # 80004292 <namecmp>
    80005be4:	14050a63          	beqz	a0,80005d38 <sys_unlink+0x1b0>
    80005be8:	00003597          	auipc	a1,0x3
    80005bec:	c8858593          	addi	a1,a1,-888 # 80008870 <syscalls+0x2d8>
    80005bf0:	fb040513          	addi	a0,s0,-80
    80005bf4:	ffffe097          	auipc	ra,0xffffe
    80005bf8:	69e080e7          	jalr	1694(ra) # 80004292 <namecmp>
    80005bfc:	12050e63          	beqz	a0,80005d38 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005c00:	f2c40613          	addi	a2,s0,-212
    80005c04:	fb040593          	addi	a1,s0,-80
    80005c08:	8526                	mv	a0,s1
    80005c0a:	ffffe097          	auipc	ra,0xffffe
    80005c0e:	6a2080e7          	jalr	1698(ra) # 800042ac <dirlookup>
    80005c12:	892a                	mv	s2,a0
    80005c14:	12050263          	beqz	a0,80005d38 <sys_unlink+0x1b0>
  ilock(ip);
    80005c18:	ffffe097          	auipc	ra,0xffffe
    80005c1c:	1b0080e7          	jalr	432(ra) # 80003dc8 <ilock>
  if(ip->nlink < 1)
    80005c20:	04a91783          	lh	a5,74(s2)
    80005c24:	08f05263          	blez	a5,80005ca8 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005c28:	04491703          	lh	a4,68(s2)
    80005c2c:	4785                	li	a5,1
    80005c2e:	08f70563          	beq	a4,a5,80005cb8 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005c32:	4641                	li	a2,16
    80005c34:	4581                	li	a1,0
    80005c36:	fc040513          	addi	a0,s0,-64
    80005c3a:	ffffb097          	auipc	ra,0xffffb
    80005c3e:	0ac080e7          	jalr	172(ra) # 80000ce6 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005c42:	4741                	li	a4,16
    80005c44:	f2c42683          	lw	a3,-212(s0)
    80005c48:	fc040613          	addi	a2,s0,-64
    80005c4c:	4581                	li	a1,0
    80005c4e:	8526                	mv	a0,s1
    80005c50:	ffffe097          	auipc	ra,0xffffe
    80005c54:	524080e7          	jalr	1316(ra) # 80004174 <writei>
    80005c58:	47c1                	li	a5,16
    80005c5a:	0af51563          	bne	a0,a5,80005d04 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005c5e:	04491703          	lh	a4,68(s2)
    80005c62:	4785                	li	a5,1
    80005c64:	0af70863          	beq	a4,a5,80005d14 <sys_unlink+0x18c>
  iunlockput(dp);
    80005c68:	8526                	mv	a0,s1
    80005c6a:	ffffe097          	auipc	ra,0xffffe
    80005c6e:	3c0080e7          	jalr	960(ra) # 8000402a <iunlockput>
  ip->nlink--;
    80005c72:	04a95783          	lhu	a5,74(s2)
    80005c76:	37fd                	addiw	a5,a5,-1
    80005c78:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005c7c:	854a                	mv	a0,s2
    80005c7e:	ffffe097          	auipc	ra,0xffffe
    80005c82:	080080e7          	jalr	128(ra) # 80003cfe <iupdate>
  iunlockput(ip);
    80005c86:	854a                	mv	a0,s2
    80005c88:	ffffe097          	auipc	ra,0xffffe
    80005c8c:	3a2080e7          	jalr	930(ra) # 8000402a <iunlockput>
  end_op();
    80005c90:	fffff097          	auipc	ra,0xfffff
    80005c94:	b7a080e7          	jalr	-1158(ra) # 8000480a <end_op>
  return 0;
    80005c98:	4501                	li	a0,0
    80005c9a:	a84d                	j	80005d4c <sys_unlink+0x1c4>
    end_op();
    80005c9c:	fffff097          	auipc	ra,0xfffff
    80005ca0:	b6e080e7          	jalr	-1170(ra) # 8000480a <end_op>
    return -1;
    80005ca4:	557d                	li	a0,-1
    80005ca6:	a05d                	j	80005d4c <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005ca8:	00003517          	auipc	a0,0x3
    80005cac:	bd050513          	addi	a0,a0,-1072 # 80008878 <syscalls+0x2e0>
    80005cb0:	ffffb097          	auipc	ra,0xffffb
    80005cb4:	894080e7          	jalr	-1900(ra) # 80000544 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005cb8:	04c92703          	lw	a4,76(s2)
    80005cbc:	02000793          	li	a5,32
    80005cc0:	f6e7f9e3          	bgeu	a5,a4,80005c32 <sys_unlink+0xaa>
    80005cc4:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005cc8:	4741                	li	a4,16
    80005cca:	86ce                	mv	a3,s3
    80005ccc:	f1840613          	addi	a2,s0,-232
    80005cd0:	4581                	li	a1,0
    80005cd2:	854a                	mv	a0,s2
    80005cd4:	ffffe097          	auipc	ra,0xffffe
    80005cd8:	3a8080e7          	jalr	936(ra) # 8000407c <readi>
    80005cdc:	47c1                	li	a5,16
    80005cde:	00f51b63          	bne	a0,a5,80005cf4 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005ce2:	f1845783          	lhu	a5,-232(s0)
    80005ce6:	e7a1                	bnez	a5,80005d2e <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005ce8:	29c1                	addiw	s3,s3,16
    80005cea:	04c92783          	lw	a5,76(s2)
    80005cee:	fcf9ede3          	bltu	s3,a5,80005cc8 <sys_unlink+0x140>
    80005cf2:	b781                	j	80005c32 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005cf4:	00003517          	auipc	a0,0x3
    80005cf8:	b9c50513          	addi	a0,a0,-1124 # 80008890 <syscalls+0x2f8>
    80005cfc:	ffffb097          	auipc	ra,0xffffb
    80005d00:	848080e7          	jalr	-1976(ra) # 80000544 <panic>
    panic("unlink: writei");
    80005d04:	00003517          	auipc	a0,0x3
    80005d08:	ba450513          	addi	a0,a0,-1116 # 800088a8 <syscalls+0x310>
    80005d0c:	ffffb097          	auipc	ra,0xffffb
    80005d10:	838080e7          	jalr	-1992(ra) # 80000544 <panic>
    dp->nlink--;
    80005d14:	04a4d783          	lhu	a5,74(s1)
    80005d18:	37fd                	addiw	a5,a5,-1
    80005d1a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005d1e:	8526                	mv	a0,s1
    80005d20:	ffffe097          	auipc	ra,0xffffe
    80005d24:	fde080e7          	jalr	-34(ra) # 80003cfe <iupdate>
    80005d28:	b781                	j	80005c68 <sys_unlink+0xe0>
    return -1;
    80005d2a:	557d                	li	a0,-1
    80005d2c:	a005                	j	80005d4c <sys_unlink+0x1c4>
    iunlockput(ip);
    80005d2e:	854a                	mv	a0,s2
    80005d30:	ffffe097          	auipc	ra,0xffffe
    80005d34:	2fa080e7          	jalr	762(ra) # 8000402a <iunlockput>
  iunlockput(dp);
    80005d38:	8526                	mv	a0,s1
    80005d3a:	ffffe097          	auipc	ra,0xffffe
    80005d3e:	2f0080e7          	jalr	752(ra) # 8000402a <iunlockput>
  end_op();
    80005d42:	fffff097          	auipc	ra,0xfffff
    80005d46:	ac8080e7          	jalr	-1336(ra) # 8000480a <end_op>
  return -1;
    80005d4a:	557d                	li	a0,-1
}
    80005d4c:	70ae                	ld	ra,232(sp)
    80005d4e:	740e                	ld	s0,224(sp)
    80005d50:	64ee                	ld	s1,216(sp)
    80005d52:	694e                	ld	s2,208(sp)
    80005d54:	69ae                	ld	s3,200(sp)
    80005d56:	616d                	addi	sp,sp,240
    80005d58:	8082                	ret

0000000080005d5a <sys_open>:

uint64
sys_open(void)
{
    80005d5a:	7131                	addi	sp,sp,-192
    80005d5c:	fd06                	sd	ra,184(sp)
    80005d5e:	f922                	sd	s0,176(sp)
    80005d60:	f526                	sd	s1,168(sp)
    80005d62:	f14a                	sd	s2,160(sp)
    80005d64:	ed4e                	sd	s3,152(sp)
    80005d66:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005d68:	f4c40593          	addi	a1,s0,-180
    80005d6c:	4505                	li	a0,1
    80005d6e:	ffffd097          	auipc	ra,0xffffd
    80005d72:	1be080e7          	jalr	446(ra) # 80002f2c <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005d76:	08000613          	li	a2,128
    80005d7a:	f5040593          	addi	a1,s0,-176
    80005d7e:	4501                	li	a0,0
    80005d80:	ffffd097          	auipc	ra,0xffffd
    80005d84:	1ec080e7          	jalr	492(ra) # 80002f6c <argstr>
    80005d88:	87aa                	mv	a5,a0
    return -1;
    80005d8a:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005d8c:	0a07c963          	bltz	a5,80005e3e <sys_open+0xe4>

  begin_op();
    80005d90:	fffff097          	auipc	ra,0xfffff
    80005d94:	9fa080e7          	jalr	-1542(ra) # 8000478a <begin_op>

  if(omode & O_CREATE){
    80005d98:	f4c42783          	lw	a5,-180(s0)
    80005d9c:	2007f793          	andi	a5,a5,512
    80005da0:	cfc5                	beqz	a5,80005e58 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005da2:	4681                	li	a3,0
    80005da4:	4601                	li	a2,0
    80005da6:	4589                	li	a1,2
    80005da8:	f5040513          	addi	a0,s0,-176
    80005dac:	00000097          	auipc	ra,0x0
    80005db0:	974080e7          	jalr	-1676(ra) # 80005720 <create>
    80005db4:	84aa                	mv	s1,a0
    if(ip == 0){
    80005db6:	c959                	beqz	a0,80005e4c <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005db8:	04449703          	lh	a4,68(s1)
    80005dbc:	478d                	li	a5,3
    80005dbe:	00f71763          	bne	a4,a5,80005dcc <sys_open+0x72>
    80005dc2:	0464d703          	lhu	a4,70(s1)
    80005dc6:	47a5                	li	a5,9
    80005dc8:	0ce7ed63          	bltu	a5,a4,80005ea2 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005dcc:	fffff097          	auipc	ra,0xfffff
    80005dd0:	dce080e7          	jalr	-562(ra) # 80004b9a <filealloc>
    80005dd4:	89aa                	mv	s3,a0
    80005dd6:	10050363          	beqz	a0,80005edc <sys_open+0x182>
    80005dda:	00000097          	auipc	ra,0x0
    80005dde:	904080e7          	jalr	-1788(ra) # 800056de <fdalloc>
    80005de2:	892a                	mv	s2,a0
    80005de4:	0e054763          	bltz	a0,80005ed2 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005de8:	04449703          	lh	a4,68(s1)
    80005dec:	478d                	li	a5,3
    80005dee:	0cf70563          	beq	a4,a5,80005eb8 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005df2:	4789                	li	a5,2
    80005df4:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005df8:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005dfc:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005e00:	f4c42783          	lw	a5,-180(s0)
    80005e04:	0017c713          	xori	a4,a5,1
    80005e08:	8b05                	andi	a4,a4,1
    80005e0a:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005e0e:	0037f713          	andi	a4,a5,3
    80005e12:	00e03733          	snez	a4,a4
    80005e16:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005e1a:	4007f793          	andi	a5,a5,1024
    80005e1e:	c791                	beqz	a5,80005e2a <sys_open+0xd0>
    80005e20:	04449703          	lh	a4,68(s1)
    80005e24:	4789                	li	a5,2
    80005e26:	0af70063          	beq	a4,a5,80005ec6 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005e2a:	8526                	mv	a0,s1
    80005e2c:	ffffe097          	auipc	ra,0xffffe
    80005e30:	05e080e7          	jalr	94(ra) # 80003e8a <iunlock>
  end_op();
    80005e34:	fffff097          	auipc	ra,0xfffff
    80005e38:	9d6080e7          	jalr	-1578(ra) # 8000480a <end_op>

  return fd;
    80005e3c:	854a                	mv	a0,s2
}
    80005e3e:	70ea                	ld	ra,184(sp)
    80005e40:	744a                	ld	s0,176(sp)
    80005e42:	74aa                	ld	s1,168(sp)
    80005e44:	790a                	ld	s2,160(sp)
    80005e46:	69ea                	ld	s3,152(sp)
    80005e48:	6129                	addi	sp,sp,192
    80005e4a:	8082                	ret
      end_op();
    80005e4c:	fffff097          	auipc	ra,0xfffff
    80005e50:	9be080e7          	jalr	-1602(ra) # 8000480a <end_op>
      return -1;
    80005e54:	557d                	li	a0,-1
    80005e56:	b7e5                	j	80005e3e <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005e58:	f5040513          	addi	a0,s0,-176
    80005e5c:	ffffe097          	auipc	ra,0xffffe
    80005e60:	712080e7          	jalr	1810(ra) # 8000456e <namei>
    80005e64:	84aa                	mv	s1,a0
    80005e66:	c905                	beqz	a0,80005e96 <sys_open+0x13c>
    ilock(ip);
    80005e68:	ffffe097          	auipc	ra,0xffffe
    80005e6c:	f60080e7          	jalr	-160(ra) # 80003dc8 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005e70:	04449703          	lh	a4,68(s1)
    80005e74:	4785                	li	a5,1
    80005e76:	f4f711e3          	bne	a4,a5,80005db8 <sys_open+0x5e>
    80005e7a:	f4c42783          	lw	a5,-180(s0)
    80005e7e:	d7b9                	beqz	a5,80005dcc <sys_open+0x72>
      iunlockput(ip);
    80005e80:	8526                	mv	a0,s1
    80005e82:	ffffe097          	auipc	ra,0xffffe
    80005e86:	1a8080e7          	jalr	424(ra) # 8000402a <iunlockput>
      end_op();
    80005e8a:	fffff097          	auipc	ra,0xfffff
    80005e8e:	980080e7          	jalr	-1664(ra) # 8000480a <end_op>
      return -1;
    80005e92:	557d                	li	a0,-1
    80005e94:	b76d                	j	80005e3e <sys_open+0xe4>
      end_op();
    80005e96:	fffff097          	auipc	ra,0xfffff
    80005e9a:	974080e7          	jalr	-1676(ra) # 8000480a <end_op>
      return -1;
    80005e9e:	557d                	li	a0,-1
    80005ea0:	bf79                	j	80005e3e <sys_open+0xe4>
    iunlockput(ip);
    80005ea2:	8526                	mv	a0,s1
    80005ea4:	ffffe097          	auipc	ra,0xffffe
    80005ea8:	186080e7          	jalr	390(ra) # 8000402a <iunlockput>
    end_op();
    80005eac:	fffff097          	auipc	ra,0xfffff
    80005eb0:	95e080e7          	jalr	-1698(ra) # 8000480a <end_op>
    return -1;
    80005eb4:	557d                	li	a0,-1
    80005eb6:	b761                	j	80005e3e <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005eb8:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005ebc:	04649783          	lh	a5,70(s1)
    80005ec0:	02f99223          	sh	a5,36(s3)
    80005ec4:	bf25                	j	80005dfc <sys_open+0xa2>
    itrunc(ip);
    80005ec6:	8526                	mv	a0,s1
    80005ec8:	ffffe097          	auipc	ra,0xffffe
    80005ecc:	00e080e7          	jalr	14(ra) # 80003ed6 <itrunc>
    80005ed0:	bfa9                	j	80005e2a <sys_open+0xd0>
      fileclose(f);
    80005ed2:	854e                	mv	a0,s3
    80005ed4:	fffff097          	auipc	ra,0xfffff
    80005ed8:	d82080e7          	jalr	-638(ra) # 80004c56 <fileclose>
    iunlockput(ip);
    80005edc:	8526                	mv	a0,s1
    80005ede:	ffffe097          	auipc	ra,0xffffe
    80005ee2:	14c080e7          	jalr	332(ra) # 8000402a <iunlockput>
    end_op();
    80005ee6:	fffff097          	auipc	ra,0xfffff
    80005eea:	924080e7          	jalr	-1756(ra) # 8000480a <end_op>
    return -1;
    80005eee:	557d                	li	a0,-1
    80005ef0:	b7b9                	j	80005e3e <sys_open+0xe4>

0000000080005ef2 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005ef2:	7175                	addi	sp,sp,-144
    80005ef4:	e506                	sd	ra,136(sp)
    80005ef6:	e122                	sd	s0,128(sp)
    80005ef8:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005efa:	fffff097          	auipc	ra,0xfffff
    80005efe:	890080e7          	jalr	-1904(ra) # 8000478a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005f02:	08000613          	li	a2,128
    80005f06:	f7040593          	addi	a1,s0,-144
    80005f0a:	4501                	li	a0,0
    80005f0c:	ffffd097          	auipc	ra,0xffffd
    80005f10:	060080e7          	jalr	96(ra) # 80002f6c <argstr>
    80005f14:	02054963          	bltz	a0,80005f46 <sys_mkdir+0x54>
    80005f18:	4681                	li	a3,0
    80005f1a:	4601                	li	a2,0
    80005f1c:	4585                	li	a1,1
    80005f1e:	f7040513          	addi	a0,s0,-144
    80005f22:	fffff097          	auipc	ra,0xfffff
    80005f26:	7fe080e7          	jalr	2046(ra) # 80005720 <create>
    80005f2a:	cd11                	beqz	a0,80005f46 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005f2c:	ffffe097          	auipc	ra,0xffffe
    80005f30:	0fe080e7          	jalr	254(ra) # 8000402a <iunlockput>
  end_op();
    80005f34:	fffff097          	auipc	ra,0xfffff
    80005f38:	8d6080e7          	jalr	-1834(ra) # 8000480a <end_op>
  return 0;
    80005f3c:	4501                	li	a0,0
}
    80005f3e:	60aa                	ld	ra,136(sp)
    80005f40:	640a                	ld	s0,128(sp)
    80005f42:	6149                	addi	sp,sp,144
    80005f44:	8082                	ret
    end_op();
    80005f46:	fffff097          	auipc	ra,0xfffff
    80005f4a:	8c4080e7          	jalr	-1852(ra) # 8000480a <end_op>
    return -1;
    80005f4e:	557d                	li	a0,-1
    80005f50:	b7fd                	j	80005f3e <sys_mkdir+0x4c>

0000000080005f52 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005f52:	7135                	addi	sp,sp,-160
    80005f54:	ed06                	sd	ra,152(sp)
    80005f56:	e922                	sd	s0,144(sp)
    80005f58:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005f5a:	fffff097          	auipc	ra,0xfffff
    80005f5e:	830080e7          	jalr	-2000(ra) # 8000478a <begin_op>
  argint(1, &major);
    80005f62:	f6c40593          	addi	a1,s0,-148
    80005f66:	4505                	li	a0,1
    80005f68:	ffffd097          	auipc	ra,0xffffd
    80005f6c:	fc4080e7          	jalr	-60(ra) # 80002f2c <argint>
  argint(2, &minor);
    80005f70:	f6840593          	addi	a1,s0,-152
    80005f74:	4509                	li	a0,2
    80005f76:	ffffd097          	auipc	ra,0xffffd
    80005f7a:	fb6080e7          	jalr	-74(ra) # 80002f2c <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005f7e:	08000613          	li	a2,128
    80005f82:	f7040593          	addi	a1,s0,-144
    80005f86:	4501                	li	a0,0
    80005f88:	ffffd097          	auipc	ra,0xffffd
    80005f8c:	fe4080e7          	jalr	-28(ra) # 80002f6c <argstr>
    80005f90:	02054b63          	bltz	a0,80005fc6 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005f94:	f6841683          	lh	a3,-152(s0)
    80005f98:	f6c41603          	lh	a2,-148(s0)
    80005f9c:	458d                	li	a1,3
    80005f9e:	f7040513          	addi	a0,s0,-144
    80005fa2:	fffff097          	auipc	ra,0xfffff
    80005fa6:	77e080e7          	jalr	1918(ra) # 80005720 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005faa:	cd11                	beqz	a0,80005fc6 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005fac:	ffffe097          	auipc	ra,0xffffe
    80005fb0:	07e080e7          	jalr	126(ra) # 8000402a <iunlockput>
  end_op();
    80005fb4:	fffff097          	auipc	ra,0xfffff
    80005fb8:	856080e7          	jalr	-1962(ra) # 8000480a <end_op>
  return 0;
    80005fbc:	4501                	li	a0,0
}
    80005fbe:	60ea                	ld	ra,152(sp)
    80005fc0:	644a                	ld	s0,144(sp)
    80005fc2:	610d                	addi	sp,sp,160
    80005fc4:	8082                	ret
    end_op();
    80005fc6:	fffff097          	auipc	ra,0xfffff
    80005fca:	844080e7          	jalr	-1980(ra) # 8000480a <end_op>
    return -1;
    80005fce:	557d                	li	a0,-1
    80005fd0:	b7fd                	j	80005fbe <sys_mknod+0x6c>

0000000080005fd2 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005fd2:	7135                	addi	sp,sp,-160
    80005fd4:	ed06                	sd	ra,152(sp)
    80005fd6:	e922                	sd	s0,144(sp)
    80005fd8:	e526                	sd	s1,136(sp)
    80005fda:	e14a                	sd	s2,128(sp)
    80005fdc:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005fde:	ffffc097          	auipc	ra,0xffffc
    80005fe2:	aee080e7          	jalr	-1298(ra) # 80001acc <myproc>
    80005fe6:	892a                	mv	s2,a0
  
  begin_op();
    80005fe8:	ffffe097          	auipc	ra,0xffffe
    80005fec:	7a2080e7          	jalr	1954(ra) # 8000478a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005ff0:	08000613          	li	a2,128
    80005ff4:	f6040593          	addi	a1,s0,-160
    80005ff8:	4501                	li	a0,0
    80005ffa:	ffffd097          	auipc	ra,0xffffd
    80005ffe:	f72080e7          	jalr	-142(ra) # 80002f6c <argstr>
    80006002:	04054b63          	bltz	a0,80006058 <sys_chdir+0x86>
    80006006:	f6040513          	addi	a0,s0,-160
    8000600a:	ffffe097          	auipc	ra,0xffffe
    8000600e:	564080e7          	jalr	1380(ra) # 8000456e <namei>
    80006012:	84aa                	mv	s1,a0
    80006014:	c131                	beqz	a0,80006058 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006016:	ffffe097          	auipc	ra,0xffffe
    8000601a:	db2080e7          	jalr	-590(ra) # 80003dc8 <ilock>
  if(ip->type != T_DIR){
    8000601e:	04449703          	lh	a4,68(s1)
    80006022:	4785                	li	a5,1
    80006024:	04f71063          	bne	a4,a5,80006064 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006028:	8526                	mv	a0,s1
    8000602a:	ffffe097          	auipc	ra,0xffffe
    8000602e:	e60080e7          	jalr	-416(ra) # 80003e8a <iunlock>
  iput(p->cwd);
    80006032:	15893503          	ld	a0,344(s2)
    80006036:	ffffe097          	auipc	ra,0xffffe
    8000603a:	f4c080e7          	jalr	-180(ra) # 80003f82 <iput>
  end_op();
    8000603e:	ffffe097          	auipc	ra,0xffffe
    80006042:	7cc080e7          	jalr	1996(ra) # 8000480a <end_op>
  p->cwd = ip;
    80006046:	14993c23          	sd	s1,344(s2)
  return 0;
    8000604a:	4501                	li	a0,0
}
    8000604c:	60ea                	ld	ra,152(sp)
    8000604e:	644a                	ld	s0,144(sp)
    80006050:	64aa                	ld	s1,136(sp)
    80006052:	690a                	ld	s2,128(sp)
    80006054:	610d                	addi	sp,sp,160
    80006056:	8082                	ret
    end_op();
    80006058:	ffffe097          	auipc	ra,0xffffe
    8000605c:	7b2080e7          	jalr	1970(ra) # 8000480a <end_op>
    return -1;
    80006060:	557d                	li	a0,-1
    80006062:	b7ed                	j	8000604c <sys_chdir+0x7a>
    iunlockput(ip);
    80006064:	8526                	mv	a0,s1
    80006066:	ffffe097          	auipc	ra,0xffffe
    8000606a:	fc4080e7          	jalr	-60(ra) # 8000402a <iunlockput>
    end_op();
    8000606e:	ffffe097          	auipc	ra,0xffffe
    80006072:	79c080e7          	jalr	1948(ra) # 8000480a <end_op>
    return -1;
    80006076:	557d                	li	a0,-1
    80006078:	bfd1                	j	8000604c <sys_chdir+0x7a>

000000008000607a <sys_exec>:

uint64
sys_exec(void)
{
    8000607a:	7145                	addi	sp,sp,-464
    8000607c:	e786                	sd	ra,456(sp)
    8000607e:	e3a2                	sd	s0,448(sp)
    80006080:	ff26                	sd	s1,440(sp)
    80006082:	fb4a                	sd	s2,432(sp)
    80006084:	f74e                	sd	s3,424(sp)
    80006086:	f352                	sd	s4,416(sp)
    80006088:	ef56                	sd	s5,408(sp)
    8000608a:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000608c:	e3840593          	addi	a1,s0,-456
    80006090:	4505                	li	a0,1
    80006092:	ffffd097          	auipc	ra,0xffffd
    80006096:	eba080e7          	jalr	-326(ra) # 80002f4c <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000609a:	08000613          	li	a2,128
    8000609e:	f4040593          	addi	a1,s0,-192
    800060a2:	4501                	li	a0,0
    800060a4:	ffffd097          	auipc	ra,0xffffd
    800060a8:	ec8080e7          	jalr	-312(ra) # 80002f6c <argstr>
    800060ac:	87aa                	mv	a5,a0
    return -1;
    800060ae:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800060b0:	0c07c263          	bltz	a5,80006174 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    800060b4:	10000613          	li	a2,256
    800060b8:	4581                	li	a1,0
    800060ba:	e4040513          	addi	a0,s0,-448
    800060be:	ffffb097          	auipc	ra,0xffffb
    800060c2:	c28080e7          	jalr	-984(ra) # 80000ce6 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800060c6:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800060ca:	89a6                	mv	s3,s1
    800060cc:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800060ce:	02000a13          	li	s4,32
    800060d2:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800060d6:	00391513          	slli	a0,s2,0x3
    800060da:	e3040593          	addi	a1,s0,-464
    800060de:	e3843783          	ld	a5,-456(s0)
    800060e2:	953e                	add	a0,a0,a5
    800060e4:	ffffd097          	auipc	ra,0xffffd
    800060e8:	daa080e7          	jalr	-598(ra) # 80002e8e <fetchaddr>
    800060ec:	02054a63          	bltz	a0,80006120 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    800060f0:	e3043783          	ld	a5,-464(s0)
    800060f4:	c3b9                	beqz	a5,8000613a <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800060f6:	ffffb097          	auipc	ra,0xffffb
    800060fa:	a04080e7          	jalr	-1532(ra) # 80000afa <kalloc>
    800060fe:	85aa                	mv	a1,a0
    80006100:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006104:	cd11                	beqz	a0,80006120 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006106:	6605                	lui	a2,0x1
    80006108:	e3043503          	ld	a0,-464(s0)
    8000610c:	ffffd097          	auipc	ra,0xffffd
    80006110:	dd4080e7          	jalr	-556(ra) # 80002ee0 <fetchstr>
    80006114:	00054663          	bltz	a0,80006120 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80006118:	0905                	addi	s2,s2,1
    8000611a:	09a1                	addi	s3,s3,8
    8000611c:	fb491be3          	bne	s2,s4,800060d2 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006120:	10048913          	addi	s2,s1,256
    80006124:	6088                	ld	a0,0(s1)
    80006126:	c531                	beqz	a0,80006172 <sys_exec+0xf8>
    kfree(argv[i]);
    80006128:	ffffb097          	auipc	ra,0xffffb
    8000612c:	8d6080e7          	jalr	-1834(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006130:	04a1                	addi	s1,s1,8
    80006132:	ff2499e3          	bne	s1,s2,80006124 <sys_exec+0xaa>
  return -1;
    80006136:	557d                	li	a0,-1
    80006138:	a835                	j	80006174 <sys_exec+0xfa>
      argv[i] = 0;
    8000613a:	0a8e                	slli	s5,s5,0x3
    8000613c:	fc040793          	addi	a5,s0,-64
    80006140:	9abe                	add	s5,s5,a5
    80006142:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80006146:	e4040593          	addi	a1,s0,-448
    8000614a:	f4040513          	addi	a0,s0,-192
    8000614e:	fffff097          	auipc	ra,0xfffff
    80006152:	190080e7          	jalr	400(ra) # 800052de <exec>
    80006156:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006158:	10048993          	addi	s3,s1,256
    8000615c:	6088                	ld	a0,0(s1)
    8000615e:	c901                	beqz	a0,8000616e <sys_exec+0xf4>
    kfree(argv[i]);
    80006160:	ffffb097          	auipc	ra,0xffffb
    80006164:	89e080e7          	jalr	-1890(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006168:	04a1                	addi	s1,s1,8
    8000616a:	ff3499e3          	bne	s1,s3,8000615c <sys_exec+0xe2>
  return ret;
    8000616e:	854a                	mv	a0,s2
    80006170:	a011                	j	80006174 <sys_exec+0xfa>
  return -1;
    80006172:	557d                	li	a0,-1
}
    80006174:	60be                	ld	ra,456(sp)
    80006176:	641e                	ld	s0,448(sp)
    80006178:	74fa                	ld	s1,440(sp)
    8000617a:	795a                	ld	s2,432(sp)
    8000617c:	79ba                	ld	s3,424(sp)
    8000617e:	7a1a                	ld	s4,416(sp)
    80006180:	6afa                	ld	s5,408(sp)
    80006182:	6179                	addi	sp,sp,464
    80006184:	8082                	ret

0000000080006186 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006186:	7139                	addi	sp,sp,-64
    80006188:	fc06                	sd	ra,56(sp)
    8000618a:	f822                	sd	s0,48(sp)
    8000618c:	f426                	sd	s1,40(sp)
    8000618e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006190:	ffffc097          	auipc	ra,0xffffc
    80006194:	93c080e7          	jalr	-1732(ra) # 80001acc <myproc>
    80006198:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000619a:	fd840593          	addi	a1,s0,-40
    8000619e:	4501                	li	a0,0
    800061a0:	ffffd097          	auipc	ra,0xffffd
    800061a4:	dac080e7          	jalr	-596(ra) # 80002f4c <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800061a8:	fc840593          	addi	a1,s0,-56
    800061ac:	fd040513          	addi	a0,s0,-48
    800061b0:	fffff097          	auipc	ra,0xfffff
    800061b4:	dd6080e7          	jalr	-554(ra) # 80004f86 <pipealloc>
    return -1;
    800061b8:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800061ba:	0c054463          	bltz	a0,80006282 <sys_pipe+0xfc>
  fd0 = -1;
    800061be:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800061c2:	fd043503          	ld	a0,-48(s0)
    800061c6:	fffff097          	auipc	ra,0xfffff
    800061ca:	518080e7          	jalr	1304(ra) # 800056de <fdalloc>
    800061ce:	fca42223          	sw	a0,-60(s0)
    800061d2:	08054b63          	bltz	a0,80006268 <sys_pipe+0xe2>
    800061d6:	fc843503          	ld	a0,-56(s0)
    800061da:	fffff097          	auipc	ra,0xfffff
    800061de:	504080e7          	jalr	1284(ra) # 800056de <fdalloc>
    800061e2:	fca42023          	sw	a0,-64(s0)
    800061e6:	06054863          	bltz	a0,80006256 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800061ea:	4691                	li	a3,4
    800061ec:	fc440613          	addi	a2,s0,-60
    800061f0:	fd843583          	ld	a1,-40(s0)
    800061f4:	6ca8                	ld	a0,88(s1)
    800061f6:	ffffb097          	auipc	ra,0xffffb
    800061fa:	48e080e7          	jalr	1166(ra) # 80001684 <copyout>
    800061fe:	02054063          	bltz	a0,8000621e <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006202:	4691                	li	a3,4
    80006204:	fc040613          	addi	a2,s0,-64
    80006208:	fd843583          	ld	a1,-40(s0)
    8000620c:	0591                	addi	a1,a1,4
    8000620e:	6ca8                	ld	a0,88(s1)
    80006210:	ffffb097          	auipc	ra,0xffffb
    80006214:	474080e7          	jalr	1140(ra) # 80001684 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006218:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000621a:	06055463          	bgez	a0,80006282 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    8000621e:	fc442783          	lw	a5,-60(s0)
    80006222:	07e9                	addi	a5,a5,26
    80006224:	078e                	slli	a5,a5,0x3
    80006226:	97a6                	add	a5,a5,s1
    80006228:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    8000622c:	fc042503          	lw	a0,-64(s0)
    80006230:	0569                	addi	a0,a0,26
    80006232:	050e                	slli	a0,a0,0x3
    80006234:	94aa                	add	s1,s1,a0
    80006236:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    8000623a:	fd043503          	ld	a0,-48(s0)
    8000623e:	fffff097          	auipc	ra,0xfffff
    80006242:	a18080e7          	jalr	-1512(ra) # 80004c56 <fileclose>
    fileclose(wf);
    80006246:	fc843503          	ld	a0,-56(s0)
    8000624a:	fffff097          	auipc	ra,0xfffff
    8000624e:	a0c080e7          	jalr	-1524(ra) # 80004c56 <fileclose>
    return -1;
    80006252:	57fd                	li	a5,-1
    80006254:	a03d                	j	80006282 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80006256:	fc442783          	lw	a5,-60(s0)
    8000625a:	0007c763          	bltz	a5,80006268 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    8000625e:	07e9                	addi	a5,a5,26
    80006260:	078e                	slli	a5,a5,0x3
    80006262:	94be                	add	s1,s1,a5
    80006264:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80006268:	fd043503          	ld	a0,-48(s0)
    8000626c:	fffff097          	auipc	ra,0xfffff
    80006270:	9ea080e7          	jalr	-1558(ra) # 80004c56 <fileclose>
    fileclose(wf);
    80006274:	fc843503          	ld	a0,-56(s0)
    80006278:	fffff097          	auipc	ra,0xfffff
    8000627c:	9de080e7          	jalr	-1570(ra) # 80004c56 <fileclose>
    return -1;
    80006280:	57fd                	li	a5,-1
}
    80006282:	853e                	mv	a0,a5
    80006284:	70e2                	ld	ra,56(sp)
    80006286:	7442                	ld	s0,48(sp)
    80006288:	74a2                	ld	s1,40(sp)
    8000628a:	6121                	addi	sp,sp,64
    8000628c:	8082                	ret
	...

0000000080006290 <kernelvec>:
    80006290:	7111                	addi	sp,sp,-256
    80006292:	e006                	sd	ra,0(sp)
    80006294:	e40a                	sd	sp,8(sp)
    80006296:	e80e                	sd	gp,16(sp)
    80006298:	ec12                	sd	tp,24(sp)
    8000629a:	f016                	sd	t0,32(sp)
    8000629c:	f41a                	sd	t1,40(sp)
    8000629e:	f81e                	sd	t2,48(sp)
    800062a0:	fc22                	sd	s0,56(sp)
    800062a2:	e0a6                	sd	s1,64(sp)
    800062a4:	e4aa                	sd	a0,72(sp)
    800062a6:	e8ae                	sd	a1,80(sp)
    800062a8:	ecb2                	sd	a2,88(sp)
    800062aa:	f0b6                	sd	a3,96(sp)
    800062ac:	f4ba                	sd	a4,104(sp)
    800062ae:	f8be                	sd	a5,112(sp)
    800062b0:	fcc2                	sd	a6,120(sp)
    800062b2:	e146                	sd	a7,128(sp)
    800062b4:	e54a                	sd	s2,136(sp)
    800062b6:	e94e                	sd	s3,144(sp)
    800062b8:	ed52                	sd	s4,152(sp)
    800062ba:	f156                	sd	s5,160(sp)
    800062bc:	f55a                	sd	s6,168(sp)
    800062be:	f95e                	sd	s7,176(sp)
    800062c0:	fd62                	sd	s8,184(sp)
    800062c2:	e1e6                	sd	s9,192(sp)
    800062c4:	e5ea                	sd	s10,200(sp)
    800062c6:	e9ee                	sd	s11,208(sp)
    800062c8:	edf2                	sd	t3,216(sp)
    800062ca:	f1f6                	sd	t4,224(sp)
    800062cc:	f5fa                	sd	t5,232(sp)
    800062ce:	f9fe                	sd	t6,240(sp)
    800062d0:	a71fc0ef          	jal	ra,80002d40 <kerneltrap>
    800062d4:	6082                	ld	ra,0(sp)
    800062d6:	6122                	ld	sp,8(sp)
    800062d8:	61c2                	ld	gp,16(sp)
    800062da:	7282                	ld	t0,32(sp)
    800062dc:	7322                	ld	t1,40(sp)
    800062de:	73c2                	ld	t2,48(sp)
    800062e0:	7462                	ld	s0,56(sp)
    800062e2:	6486                	ld	s1,64(sp)
    800062e4:	6526                	ld	a0,72(sp)
    800062e6:	65c6                	ld	a1,80(sp)
    800062e8:	6666                	ld	a2,88(sp)
    800062ea:	7686                	ld	a3,96(sp)
    800062ec:	7726                	ld	a4,104(sp)
    800062ee:	77c6                	ld	a5,112(sp)
    800062f0:	7866                	ld	a6,120(sp)
    800062f2:	688a                	ld	a7,128(sp)
    800062f4:	692a                	ld	s2,136(sp)
    800062f6:	69ca                	ld	s3,144(sp)
    800062f8:	6a6a                	ld	s4,152(sp)
    800062fa:	7a8a                	ld	s5,160(sp)
    800062fc:	7b2a                	ld	s6,168(sp)
    800062fe:	7bca                	ld	s7,176(sp)
    80006300:	7c6a                	ld	s8,184(sp)
    80006302:	6c8e                	ld	s9,192(sp)
    80006304:	6d2e                	ld	s10,200(sp)
    80006306:	6dce                	ld	s11,208(sp)
    80006308:	6e6e                	ld	t3,216(sp)
    8000630a:	7e8e                	ld	t4,224(sp)
    8000630c:	7f2e                	ld	t5,232(sp)
    8000630e:	7fce                	ld	t6,240(sp)
    80006310:	6111                	addi	sp,sp,256
    80006312:	10200073          	sret
    80006316:	00000013          	nop
    8000631a:	00000013          	nop
    8000631e:	0001                	nop

0000000080006320 <timervec>:
    80006320:	34051573          	csrrw	a0,mscratch,a0
    80006324:	e10c                	sd	a1,0(a0)
    80006326:	e510                	sd	a2,8(a0)
    80006328:	e914                	sd	a3,16(a0)
    8000632a:	6d0c                	ld	a1,24(a0)
    8000632c:	7110                	ld	a2,32(a0)
    8000632e:	6194                	ld	a3,0(a1)
    80006330:	96b2                	add	a3,a3,a2
    80006332:	e194                	sd	a3,0(a1)
    80006334:	4589                	li	a1,2
    80006336:	14459073          	csrw	sip,a1
    8000633a:	6914                	ld	a3,16(a0)
    8000633c:	6510                	ld	a2,8(a0)
    8000633e:	610c                	ld	a1,0(a0)
    80006340:	34051573          	csrrw	a0,mscratch,a0
    80006344:	30200073          	mret
	...

000000008000634a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000634a:	1141                	addi	sp,sp,-16
    8000634c:	e422                	sd	s0,8(sp)
    8000634e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006350:	0c0007b7          	lui	a5,0xc000
    80006354:	4705                	li	a4,1
    80006356:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006358:	c3d8                	sw	a4,4(a5)
}
    8000635a:	6422                	ld	s0,8(sp)
    8000635c:	0141                	addi	sp,sp,16
    8000635e:	8082                	ret

0000000080006360 <plicinithart>:

void
plicinithart(void)
{
    80006360:	1141                	addi	sp,sp,-16
    80006362:	e406                	sd	ra,8(sp)
    80006364:	e022                	sd	s0,0(sp)
    80006366:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006368:	ffffb097          	auipc	ra,0xffffb
    8000636c:	738080e7          	jalr	1848(ra) # 80001aa0 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006370:	0085171b          	slliw	a4,a0,0x8
    80006374:	0c0027b7          	lui	a5,0xc002
    80006378:	97ba                	add	a5,a5,a4
    8000637a:	40200713          	li	a4,1026
    8000637e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006382:	00d5151b          	slliw	a0,a0,0xd
    80006386:	0c2017b7          	lui	a5,0xc201
    8000638a:	953e                	add	a0,a0,a5
    8000638c:	00052023          	sw	zero,0(a0)
}
    80006390:	60a2                	ld	ra,8(sp)
    80006392:	6402                	ld	s0,0(sp)
    80006394:	0141                	addi	sp,sp,16
    80006396:	8082                	ret

0000000080006398 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006398:	1141                	addi	sp,sp,-16
    8000639a:	e406                	sd	ra,8(sp)
    8000639c:	e022                	sd	s0,0(sp)
    8000639e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800063a0:	ffffb097          	auipc	ra,0xffffb
    800063a4:	700080e7          	jalr	1792(ra) # 80001aa0 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800063a8:	00d5179b          	slliw	a5,a0,0xd
    800063ac:	0c201537          	lui	a0,0xc201
    800063b0:	953e                	add	a0,a0,a5
  return irq;
}
    800063b2:	4148                	lw	a0,4(a0)
    800063b4:	60a2                	ld	ra,8(sp)
    800063b6:	6402                	ld	s0,0(sp)
    800063b8:	0141                	addi	sp,sp,16
    800063ba:	8082                	ret

00000000800063bc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800063bc:	1101                	addi	sp,sp,-32
    800063be:	ec06                	sd	ra,24(sp)
    800063c0:	e822                	sd	s0,16(sp)
    800063c2:	e426                	sd	s1,8(sp)
    800063c4:	1000                	addi	s0,sp,32
    800063c6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800063c8:	ffffb097          	auipc	ra,0xffffb
    800063cc:	6d8080e7          	jalr	1752(ra) # 80001aa0 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800063d0:	00d5151b          	slliw	a0,a0,0xd
    800063d4:	0c2017b7          	lui	a5,0xc201
    800063d8:	97aa                	add	a5,a5,a0
    800063da:	c3c4                	sw	s1,4(a5)
}
    800063dc:	60e2                	ld	ra,24(sp)
    800063de:	6442                	ld	s0,16(sp)
    800063e0:	64a2                	ld	s1,8(sp)
    800063e2:	6105                	addi	sp,sp,32
    800063e4:	8082                	ret

00000000800063e6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800063e6:	1141                	addi	sp,sp,-16
    800063e8:	e406                	sd	ra,8(sp)
    800063ea:	e022                	sd	s0,0(sp)
    800063ec:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800063ee:	479d                	li	a5,7
    800063f0:	04a7cc63          	blt	a5,a0,80006448 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800063f4:	0001e797          	auipc	a5,0x1e
    800063f8:	d7c78793          	addi	a5,a5,-644 # 80024170 <disk>
    800063fc:	97aa                	add	a5,a5,a0
    800063fe:	0187c783          	lbu	a5,24(a5)
    80006402:	ebb9                	bnez	a5,80006458 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006404:	00451613          	slli	a2,a0,0x4
    80006408:	0001e797          	auipc	a5,0x1e
    8000640c:	d6878793          	addi	a5,a5,-664 # 80024170 <disk>
    80006410:	6394                	ld	a3,0(a5)
    80006412:	96b2                	add	a3,a3,a2
    80006414:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006418:	6398                	ld	a4,0(a5)
    8000641a:	9732                	add	a4,a4,a2
    8000641c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006420:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006424:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006428:	953e                	add	a0,a0,a5
    8000642a:	4785                	li	a5,1
    8000642c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80006430:	0001e517          	auipc	a0,0x1e
    80006434:	d5850513          	addi	a0,a0,-680 # 80024188 <disk+0x18>
    80006438:	ffffc097          	auipc	ra,0xffffc
    8000643c:	fca080e7          	jalr	-54(ra) # 80002402 <wakeup>
}
    80006440:	60a2                	ld	ra,8(sp)
    80006442:	6402                	ld	s0,0(sp)
    80006444:	0141                	addi	sp,sp,16
    80006446:	8082                	ret
    panic("free_desc 1");
    80006448:	00002517          	auipc	a0,0x2
    8000644c:	47050513          	addi	a0,a0,1136 # 800088b8 <syscalls+0x320>
    80006450:	ffffa097          	auipc	ra,0xffffa
    80006454:	0f4080e7          	jalr	244(ra) # 80000544 <panic>
    panic("free_desc 2");
    80006458:	00002517          	auipc	a0,0x2
    8000645c:	47050513          	addi	a0,a0,1136 # 800088c8 <syscalls+0x330>
    80006460:	ffffa097          	auipc	ra,0xffffa
    80006464:	0e4080e7          	jalr	228(ra) # 80000544 <panic>

0000000080006468 <virtio_disk_init>:
{
    80006468:	1101                	addi	sp,sp,-32
    8000646a:	ec06                	sd	ra,24(sp)
    8000646c:	e822                	sd	s0,16(sp)
    8000646e:	e426                	sd	s1,8(sp)
    80006470:	e04a                	sd	s2,0(sp)
    80006472:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006474:	00002597          	auipc	a1,0x2
    80006478:	46458593          	addi	a1,a1,1124 # 800088d8 <syscalls+0x340>
    8000647c:	0001e517          	auipc	a0,0x1e
    80006480:	e1c50513          	addi	a0,a0,-484 # 80024298 <disk+0x128>
    80006484:	ffffa097          	auipc	ra,0xffffa
    80006488:	6d6080e7          	jalr	1750(ra) # 80000b5a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000648c:	100017b7          	lui	a5,0x10001
    80006490:	4398                	lw	a4,0(a5)
    80006492:	2701                	sext.w	a4,a4
    80006494:	747277b7          	lui	a5,0x74727
    80006498:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000649c:	14f71e63          	bne	a4,a5,800065f8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800064a0:	100017b7          	lui	a5,0x10001
    800064a4:	43dc                	lw	a5,4(a5)
    800064a6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800064a8:	4709                	li	a4,2
    800064aa:	14e79763          	bne	a5,a4,800065f8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800064ae:	100017b7          	lui	a5,0x10001
    800064b2:	479c                	lw	a5,8(a5)
    800064b4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800064b6:	14e79163          	bne	a5,a4,800065f8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800064ba:	100017b7          	lui	a5,0x10001
    800064be:	47d8                	lw	a4,12(a5)
    800064c0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800064c2:	554d47b7          	lui	a5,0x554d4
    800064c6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800064ca:	12f71763          	bne	a4,a5,800065f8 <virtio_disk_init+0x190>
  *R(VIRTIO_MMIO_STATUS) = status;
    800064ce:	100017b7          	lui	a5,0x10001
    800064d2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800064d6:	4705                	li	a4,1
    800064d8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800064da:	470d                	li	a4,3
    800064dc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800064de:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800064e0:	c7ffe737          	lui	a4,0xc7ffe
    800064e4:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fda4af>
    800064e8:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800064ea:	2701                	sext.w	a4,a4
    800064ec:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800064ee:	472d                	li	a4,11
    800064f0:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800064f2:	0707a903          	lw	s2,112(a5)
    800064f6:	2901                	sext.w	s2,s2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800064f8:	00897793          	andi	a5,s2,8
    800064fc:	10078663          	beqz	a5,80006608 <virtio_disk_init+0x1a0>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006500:	100017b7          	lui	a5,0x10001
    80006504:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006508:	43fc                	lw	a5,68(a5)
    8000650a:	2781                	sext.w	a5,a5
    8000650c:	10079663          	bnez	a5,80006618 <virtio_disk_init+0x1b0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006510:	100017b7          	lui	a5,0x10001
    80006514:	5bdc                	lw	a5,52(a5)
    80006516:	2781                	sext.w	a5,a5
  if(max == 0)
    80006518:	10078863          	beqz	a5,80006628 <virtio_disk_init+0x1c0>
  if(max < NUM)
    8000651c:	471d                	li	a4,7
    8000651e:	10f77d63          	bgeu	a4,a5,80006638 <virtio_disk_init+0x1d0>
  disk.desc = kalloc();
    80006522:	ffffa097          	auipc	ra,0xffffa
    80006526:	5d8080e7          	jalr	1496(ra) # 80000afa <kalloc>
    8000652a:	0001e497          	auipc	s1,0x1e
    8000652e:	c4648493          	addi	s1,s1,-954 # 80024170 <disk>
    80006532:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006534:	ffffa097          	auipc	ra,0xffffa
    80006538:	5c6080e7          	jalr	1478(ra) # 80000afa <kalloc>
    8000653c:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000653e:	ffffa097          	auipc	ra,0xffffa
    80006542:	5bc080e7          	jalr	1468(ra) # 80000afa <kalloc>
    80006546:	87aa                	mv	a5,a0
    80006548:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    8000654a:	6088                	ld	a0,0(s1)
    8000654c:	cd75                	beqz	a0,80006648 <virtio_disk_init+0x1e0>
    8000654e:	0001e717          	auipc	a4,0x1e
    80006552:	c2a73703          	ld	a4,-982(a4) # 80024178 <disk+0x8>
    80006556:	cb6d                	beqz	a4,80006648 <virtio_disk_init+0x1e0>
    80006558:	cbe5                	beqz	a5,80006648 <virtio_disk_init+0x1e0>
  memset(disk.desc, 0, PGSIZE);
    8000655a:	6605                	lui	a2,0x1
    8000655c:	4581                	li	a1,0
    8000655e:	ffffa097          	auipc	ra,0xffffa
    80006562:	788080e7          	jalr	1928(ra) # 80000ce6 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006566:	0001e497          	auipc	s1,0x1e
    8000656a:	c0a48493          	addi	s1,s1,-1014 # 80024170 <disk>
    8000656e:	6605                	lui	a2,0x1
    80006570:	4581                	li	a1,0
    80006572:	6488                	ld	a0,8(s1)
    80006574:	ffffa097          	auipc	ra,0xffffa
    80006578:	772080e7          	jalr	1906(ra) # 80000ce6 <memset>
  memset(disk.used, 0, PGSIZE);
    8000657c:	6605                	lui	a2,0x1
    8000657e:	4581                	li	a1,0
    80006580:	6888                	ld	a0,16(s1)
    80006582:	ffffa097          	auipc	ra,0xffffa
    80006586:	764080e7          	jalr	1892(ra) # 80000ce6 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000658a:	100017b7          	lui	a5,0x10001
    8000658e:	4721                	li	a4,8
    80006590:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006592:	4098                	lw	a4,0(s1)
    80006594:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006598:	40d8                	lw	a4,4(s1)
    8000659a:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000659e:	6498                	ld	a4,8(s1)
    800065a0:	0007069b          	sext.w	a3,a4
    800065a4:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800065a8:	9701                	srai	a4,a4,0x20
    800065aa:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800065ae:	6898                	ld	a4,16(s1)
    800065b0:	0007069b          	sext.w	a3,a4
    800065b4:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800065b8:	9701                	srai	a4,a4,0x20
    800065ba:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800065be:	4685                	li	a3,1
    800065c0:	c3f4                	sw	a3,68(a5)
    disk.free[i] = 1;
    800065c2:	4705                	li	a4,1
    800065c4:	00d48c23          	sb	a3,24(s1)
    800065c8:	00e48ca3          	sb	a4,25(s1)
    800065cc:	00e48d23          	sb	a4,26(s1)
    800065d0:	00e48da3          	sb	a4,27(s1)
    800065d4:	00e48e23          	sb	a4,28(s1)
    800065d8:	00e48ea3          	sb	a4,29(s1)
    800065dc:	00e48f23          	sb	a4,30(s1)
    800065e0:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800065e4:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800065e8:	0727a823          	sw	s2,112(a5)
}
    800065ec:	60e2                	ld	ra,24(sp)
    800065ee:	6442                	ld	s0,16(sp)
    800065f0:	64a2                	ld	s1,8(sp)
    800065f2:	6902                	ld	s2,0(sp)
    800065f4:	6105                	addi	sp,sp,32
    800065f6:	8082                	ret
    panic("could not find virtio disk");
    800065f8:	00002517          	auipc	a0,0x2
    800065fc:	2f050513          	addi	a0,a0,752 # 800088e8 <syscalls+0x350>
    80006600:	ffffa097          	auipc	ra,0xffffa
    80006604:	f44080e7          	jalr	-188(ra) # 80000544 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006608:	00002517          	auipc	a0,0x2
    8000660c:	30050513          	addi	a0,a0,768 # 80008908 <syscalls+0x370>
    80006610:	ffffa097          	auipc	ra,0xffffa
    80006614:	f34080e7          	jalr	-204(ra) # 80000544 <panic>
    panic("virtio disk should not be ready");
    80006618:	00002517          	auipc	a0,0x2
    8000661c:	31050513          	addi	a0,a0,784 # 80008928 <syscalls+0x390>
    80006620:	ffffa097          	auipc	ra,0xffffa
    80006624:	f24080e7          	jalr	-220(ra) # 80000544 <panic>
    panic("virtio disk has no queue 0");
    80006628:	00002517          	auipc	a0,0x2
    8000662c:	32050513          	addi	a0,a0,800 # 80008948 <syscalls+0x3b0>
    80006630:	ffffa097          	auipc	ra,0xffffa
    80006634:	f14080e7          	jalr	-236(ra) # 80000544 <panic>
    panic("virtio disk max queue too short");
    80006638:	00002517          	auipc	a0,0x2
    8000663c:	33050513          	addi	a0,a0,816 # 80008968 <syscalls+0x3d0>
    80006640:	ffffa097          	auipc	ra,0xffffa
    80006644:	f04080e7          	jalr	-252(ra) # 80000544 <panic>
    panic("virtio disk kalloc");
    80006648:	00002517          	auipc	a0,0x2
    8000664c:	34050513          	addi	a0,a0,832 # 80008988 <syscalls+0x3f0>
    80006650:	ffffa097          	auipc	ra,0xffffa
    80006654:	ef4080e7          	jalr	-268(ra) # 80000544 <panic>

0000000080006658 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006658:	7159                	addi	sp,sp,-112
    8000665a:	f486                	sd	ra,104(sp)
    8000665c:	f0a2                	sd	s0,96(sp)
    8000665e:	eca6                	sd	s1,88(sp)
    80006660:	e8ca                	sd	s2,80(sp)
    80006662:	e4ce                	sd	s3,72(sp)
    80006664:	e0d2                	sd	s4,64(sp)
    80006666:	fc56                	sd	s5,56(sp)
    80006668:	f85a                	sd	s6,48(sp)
    8000666a:	f45e                	sd	s7,40(sp)
    8000666c:	f062                	sd	s8,32(sp)
    8000666e:	ec66                	sd	s9,24(sp)
    80006670:	e86a                	sd	s10,16(sp)
    80006672:	1880                	addi	s0,sp,112
    80006674:	892a                	mv	s2,a0
    80006676:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006678:	00c52c83          	lw	s9,12(a0)
    8000667c:	001c9c9b          	slliw	s9,s9,0x1
    80006680:	1c82                	slli	s9,s9,0x20
    80006682:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006686:	0001e517          	auipc	a0,0x1e
    8000668a:	c1250513          	addi	a0,a0,-1006 # 80024298 <disk+0x128>
    8000668e:	ffffa097          	auipc	ra,0xffffa
    80006692:	55c080e7          	jalr	1372(ra) # 80000bea <acquire>
  for(int i = 0; i < 3; i++){
    80006696:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006698:	4ba1                	li	s7,8
      disk.free[i] = 0;
    8000669a:	0001eb17          	auipc	s6,0x1e
    8000669e:	ad6b0b13          	addi	s6,s6,-1322 # 80024170 <disk>
  for(int i = 0; i < 3; i++){
    800066a2:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    800066a4:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800066a6:	0001ec17          	auipc	s8,0x1e
    800066aa:	bf2c0c13          	addi	s8,s8,-1038 # 80024298 <disk+0x128>
    800066ae:	a8b5                	j	8000672a <virtio_disk_rw+0xd2>
      disk.free[i] = 0;
    800066b0:	00fb06b3          	add	a3,s6,a5
    800066b4:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    800066b8:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    800066ba:	0207c563          	bltz	a5,800066e4 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800066be:	2485                	addiw	s1,s1,1
    800066c0:	0711                	addi	a4,a4,4
    800066c2:	1f548a63          	beq	s1,s5,800068b6 <virtio_disk_rw+0x25e>
    idx[i] = alloc_desc();
    800066c6:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    800066c8:	0001e697          	auipc	a3,0x1e
    800066cc:	aa868693          	addi	a3,a3,-1368 # 80024170 <disk>
    800066d0:	87d2                	mv	a5,s4
    if(disk.free[i]){
    800066d2:	0186c583          	lbu	a1,24(a3)
    800066d6:	fde9                	bnez	a1,800066b0 <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800066d8:	2785                	addiw	a5,a5,1
    800066da:	0685                	addi	a3,a3,1
    800066dc:	ff779be3          	bne	a5,s7,800066d2 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800066e0:	57fd                	li	a5,-1
    800066e2:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    800066e4:	02905a63          	blez	s1,80006718 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800066e8:	f9042503          	lw	a0,-112(s0)
    800066ec:	00000097          	auipc	ra,0x0
    800066f0:	cfa080e7          	jalr	-774(ra) # 800063e6 <free_desc>
      for(int j = 0; j < i; j++)
    800066f4:	4785                	li	a5,1
    800066f6:	0297d163          	bge	a5,s1,80006718 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800066fa:	f9442503          	lw	a0,-108(s0)
    800066fe:	00000097          	auipc	ra,0x0
    80006702:	ce8080e7          	jalr	-792(ra) # 800063e6 <free_desc>
      for(int j = 0; j < i; j++)
    80006706:	4789                	li	a5,2
    80006708:	0097d863          	bge	a5,s1,80006718 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000670c:	f9842503          	lw	a0,-104(s0)
    80006710:	00000097          	auipc	ra,0x0
    80006714:	cd6080e7          	jalr	-810(ra) # 800063e6 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006718:	85e2                	mv	a1,s8
    8000671a:	0001e517          	auipc	a0,0x1e
    8000671e:	a6e50513          	addi	a0,a0,-1426 # 80024188 <disk+0x18>
    80006722:	ffffc097          	auipc	ra,0xffffc
    80006726:	b1e080e7          	jalr	-1250(ra) # 80002240 <sleep>
  for(int i = 0; i < 3; i++){
    8000672a:	f9040713          	addi	a4,s0,-112
    8000672e:	84ce                	mv	s1,s3
    80006730:	bf59                	j	800066c6 <virtio_disk_rw+0x6e>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80006732:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    80006736:	00479693          	slli	a3,a5,0x4
    8000673a:	0001e797          	auipc	a5,0x1e
    8000673e:	a3678793          	addi	a5,a5,-1482 # 80024170 <disk>
    80006742:	97b6                	add	a5,a5,a3
    80006744:	4685                	li	a3,1
    80006746:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006748:	0001e597          	auipc	a1,0x1e
    8000674c:	a2858593          	addi	a1,a1,-1496 # 80024170 <disk>
    80006750:	00a60793          	addi	a5,a2,10
    80006754:	0792                	slli	a5,a5,0x4
    80006756:	97ae                	add	a5,a5,a1
    80006758:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    8000675c:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006760:	f6070693          	addi	a3,a4,-160
    80006764:	619c                	ld	a5,0(a1)
    80006766:	97b6                	add	a5,a5,a3
    80006768:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000676a:	6188                	ld	a0,0(a1)
    8000676c:	96aa                	add	a3,a3,a0
    8000676e:	47c1                	li	a5,16
    80006770:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006772:	4785                	li	a5,1
    80006774:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006778:	f9442783          	lw	a5,-108(s0)
    8000677c:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006780:	0792                	slli	a5,a5,0x4
    80006782:	953e                	add	a0,a0,a5
    80006784:	05890693          	addi	a3,s2,88
    80006788:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000678a:	6188                	ld	a0,0(a1)
    8000678c:	97aa                	add	a5,a5,a0
    8000678e:	40000693          	li	a3,1024
    80006792:	c794                	sw	a3,8(a5)
  if(write)
    80006794:	100d0d63          	beqz	s10,800068ae <virtio_disk_rw+0x256>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006798:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000679c:	00c7d683          	lhu	a3,12(a5)
    800067a0:	0016e693          	ori	a3,a3,1
    800067a4:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    800067a8:	f9842583          	lw	a1,-104(s0)
    800067ac:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800067b0:	0001e697          	auipc	a3,0x1e
    800067b4:	9c068693          	addi	a3,a3,-1600 # 80024170 <disk>
    800067b8:	00260793          	addi	a5,a2,2
    800067bc:	0792                	slli	a5,a5,0x4
    800067be:	97b6                	add	a5,a5,a3
    800067c0:	587d                	li	a6,-1
    800067c2:	01078823          	sb	a6,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800067c6:	0592                	slli	a1,a1,0x4
    800067c8:	952e                	add	a0,a0,a1
    800067ca:	f9070713          	addi	a4,a4,-112
    800067ce:	9736                	add	a4,a4,a3
    800067d0:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    800067d2:	6298                	ld	a4,0(a3)
    800067d4:	972e                	add	a4,a4,a1
    800067d6:	4585                	li	a1,1
    800067d8:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800067da:	4509                	li	a0,2
    800067dc:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    800067e0:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800067e4:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    800067e8:	0127b423          	sd	s2,8(a5)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800067ec:	6698                	ld	a4,8(a3)
    800067ee:	00275783          	lhu	a5,2(a4)
    800067f2:	8b9d                	andi	a5,a5,7
    800067f4:	0786                	slli	a5,a5,0x1
    800067f6:	97ba                	add	a5,a5,a4
    800067f8:	00c79223          	sh	a2,4(a5)

  __sync_synchronize();
    800067fc:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006800:	6698                	ld	a4,8(a3)
    80006802:	00275783          	lhu	a5,2(a4)
    80006806:	2785                	addiw	a5,a5,1
    80006808:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000680c:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006810:	100017b7          	lui	a5,0x10001
    80006814:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006818:	00492703          	lw	a4,4(s2)
    8000681c:	4785                	li	a5,1
    8000681e:	02f71163          	bne	a4,a5,80006840 <virtio_disk_rw+0x1e8>
    sleep(b, &disk.vdisk_lock);
    80006822:	0001e997          	auipc	s3,0x1e
    80006826:	a7698993          	addi	s3,s3,-1418 # 80024298 <disk+0x128>
  while(b->disk == 1) {
    8000682a:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000682c:	85ce                	mv	a1,s3
    8000682e:	854a                	mv	a0,s2
    80006830:	ffffc097          	auipc	ra,0xffffc
    80006834:	a10080e7          	jalr	-1520(ra) # 80002240 <sleep>
  while(b->disk == 1) {
    80006838:	00492783          	lw	a5,4(s2)
    8000683c:	fe9788e3          	beq	a5,s1,8000682c <virtio_disk_rw+0x1d4>
  }

  disk.info[idx[0]].b = 0;
    80006840:	f9042903          	lw	s2,-112(s0)
    80006844:	00290793          	addi	a5,s2,2
    80006848:	00479713          	slli	a4,a5,0x4
    8000684c:	0001e797          	auipc	a5,0x1e
    80006850:	92478793          	addi	a5,a5,-1756 # 80024170 <disk>
    80006854:	97ba                	add	a5,a5,a4
    80006856:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000685a:	0001e997          	auipc	s3,0x1e
    8000685e:	91698993          	addi	s3,s3,-1770 # 80024170 <disk>
    80006862:	00491713          	slli	a4,s2,0x4
    80006866:	0009b783          	ld	a5,0(s3)
    8000686a:	97ba                	add	a5,a5,a4
    8000686c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006870:	854a                	mv	a0,s2
    80006872:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006876:	00000097          	auipc	ra,0x0
    8000687a:	b70080e7          	jalr	-1168(ra) # 800063e6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000687e:	8885                	andi	s1,s1,1
    80006880:	f0ed                	bnez	s1,80006862 <virtio_disk_rw+0x20a>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006882:	0001e517          	auipc	a0,0x1e
    80006886:	a1650513          	addi	a0,a0,-1514 # 80024298 <disk+0x128>
    8000688a:	ffffa097          	auipc	ra,0xffffa
    8000688e:	414080e7          	jalr	1044(ra) # 80000c9e <release>
}
    80006892:	70a6                	ld	ra,104(sp)
    80006894:	7406                	ld	s0,96(sp)
    80006896:	64e6                	ld	s1,88(sp)
    80006898:	6946                	ld	s2,80(sp)
    8000689a:	69a6                	ld	s3,72(sp)
    8000689c:	6a06                	ld	s4,64(sp)
    8000689e:	7ae2                	ld	s5,56(sp)
    800068a0:	7b42                	ld	s6,48(sp)
    800068a2:	7ba2                	ld	s7,40(sp)
    800068a4:	7c02                	ld	s8,32(sp)
    800068a6:	6ce2                	ld	s9,24(sp)
    800068a8:	6d42                	ld	s10,16(sp)
    800068aa:	6165                	addi	sp,sp,112
    800068ac:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800068ae:	4689                	li	a3,2
    800068b0:	00d79623          	sh	a3,12(a5)
    800068b4:	b5e5                	j	8000679c <virtio_disk_rw+0x144>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800068b6:	f9042603          	lw	a2,-112(s0)
    800068ba:	00a60713          	addi	a4,a2,10
    800068be:	0712                	slli	a4,a4,0x4
    800068c0:	0001e517          	auipc	a0,0x1e
    800068c4:	8b850513          	addi	a0,a0,-1864 # 80024178 <disk+0x8>
    800068c8:	953a                	add	a0,a0,a4
  if(write)
    800068ca:	e60d14e3          	bnez	s10,80006732 <virtio_disk_rw+0xda>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    800068ce:	00a60793          	addi	a5,a2,10
    800068d2:	00479693          	slli	a3,a5,0x4
    800068d6:	0001e797          	auipc	a5,0x1e
    800068da:	89a78793          	addi	a5,a5,-1894 # 80024170 <disk>
    800068de:	97b6                	add	a5,a5,a3
    800068e0:	0007a423          	sw	zero,8(a5)
    800068e4:	b595                	j	80006748 <virtio_disk_rw+0xf0>

00000000800068e6 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800068e6:	1101                	addi	sp,sp,-32
    800068e8:	ec06                	sd	ra,24(sp)
    800068ea:	e822                	sd	s0,16(sp)
    800068ec:	e426                	sd	s1,8(sp)
    800068ee:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800068f0:	0001e497          	auipc	s1,0x1e
    800068f4:	88048493          	addi	s1,s1,-1920 # 80024170 <disk>
    800068f8:	0001e517          	auipc	a0,0x1e
    800068fc:	9a050513          	addi	a0,a0,-1632 # 80024298 <disk+0x128>
    80006900:	ffffa097          	auipc	ra,0xffffa
    80006904:	2ea080e7          	jalr	746(ra) # 80000bea <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006908:	10001737          	lui	a4,0x10001
    8000690c:	533c                	lw	a5,96(a4)
    8000690e:	8b8d                	andi	a5,a5,3
    80006910:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006912:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006916:	689c                	ld	a5,16(s1)
    80006918:	0204d703          	lhu	a4,32(s1)
    8000691c:	0027d783          	lhu	a5,2(a5)
    80006920:	04f70863          	beq	a4,a5,80006970 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006924:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006928:	6898                	ld	a4,16(s1)
    8000692a:	0204d783          	lhu	a5,32(s1)
    8000692e:	8b9d                	andi	a5,a5,7
    80006930:	078e                	slli	a5,a5,0x3
    80006932:	97ba                	add	a5,a5,a4
    80006934:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006936:	00278713          	addi	a4,a5,2
    8000693a:	0712                	slli	a4,a4,0x4
    8000693c:	9726                	add	a4,a4,s1
    8000693e:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006942:	e721                	bnez	a4,8000698a <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006944:	0789                	addi	a5,a5,2
    80006946:	0792                	slli	a5,a5,0x4
    80006948:	97a6                	add	a5,a5,s1
    8000694a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000694c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006950:	ffffc097          	auipc	ra,0xffffc
    80006954:	ab2080e7          	jalr	-1358(ra) # 80002402 <wakeup>

    disk.used_idx += 1;
    80006958:	0204d783          	lhu	a5,32(s1)
    8000695c:	2785                	addiw	a5,a5,1
    8000695e:	17c2                	slli	a5,a5,0x30
    80006960:	93c1                	srli	a5,a5,0x30
    80006962:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006966:	6898                	ld	a4,16(s1)
    80006968:	00275703          	lhu	a4,2(a4)
    8000696c:	faf71ce3          	bne	a4,a5,80006924 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006970:	0001e517          	auipc	a0,0x1e
    80006974:	92850513          	addi	a0,a0,-1752 # 80024298 <disk+0x128>
    80006978:	ffffa097          	auipc	ra,0xffffa
    8000697c:	326080e7          	jalr	806(ra) # 80000c9e <release>
}
    80006980:	60e2                	ld	ra,24(sp)
    80006982:	6442                	ld	s0,16(sp)
    80006984:	64a2                	ld	s1,8(sp)
    80006986:	6105                	addi	sp,sp,32
    80006988:	8082                	ret
      panic("virtio_disk_intr status");
    8000698a:	00002517          	auipc	a0,0x2
    8000698e:	01650513          	addi	a0,a0,22 # 800089a0 <syscalls+0x408>
    80006992:	ffffa097          	auipc	ra,0xffffa
    80006996:	bb2080e7          	jalr	-1102(ra) # 80000544 <panic>
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
