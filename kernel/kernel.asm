
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
    80000068:	03c78793          	addi	a5,a5,60 # 800060a0 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffda357>
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
    80000130:	6c6080e7          	jalr	1734(ra) # 800027f2 <either_copyin>
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
    800001c8:	a2e080e7          	jalr	-1490(ra) # 80001bf2 <myproc>
    800001cc:	00002097          	auipc	ra,0x2
    800001d0:	464080e7          	jalr	1124(ra) # 80002630 <killed>
    800001d4:	e535                	bnez	a0,80000240 <consoleread+0xdc>
      sleep(&cons.r, &cons.lock);
    800001d6:	85ce                	mv	a1,s3
    800001d8:	854a                	mv	a0,s2
    800001da:	00002097          	auipc	ra,0x2
    800001de:	14e080e7          	jalr	334(ra) # 80002328 <sleep>
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
    8000021a:	586080e7          	jalr	1414(ra) # 8000279c <either_copyout>
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
    800002fc:	550080e7          	jalr	1360(ra) # 80002848 <procdump>
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
    80000450:	f4a080e7          	jalr	-182(ra) # 80002396 <wakeup>
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
    8000046a:	89a50513          	addi	a0,a0,-1894 # 80010d00 <cons>
    8000046e:	00000097          	auipc	ra,0x0
    80000472:	6ec080e7          	jalr	1772(ra) # 80000b5a <initlock>

  uartinit();
    80000476:	00000097          	auipc	ra,0x0
    8000047a:	330080e7          	jalr	816(ra) # 800007a6 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000047e:	00023797          	auipc	a5,0x23
    80000482:	e9278793          	addi	a5,a5,-366 # 80023310 <devsw>
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
    8000055c:	ac050513          	addi	a0,a0,-1344 # 80008018 <num_levels+0x10>
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
    800008aa:	af0080e7          	jalr	-1296(ra) # 80002396 <wakeup>
    
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
    80000934:	9f8080e7          	jalr	-1544(ra) # 80002328 <sleep>
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
    80000a12:	00024797          	auipc	a5,0x24
    80000a16:	a9678793          	addi	a5,a5,-1386 # 800244a8 <end>
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
    80000ae2:	00024517          	auipc	a0,0x24
    80000ae6:	9c650513          	addi	a0,a0,-1594 # 800244a8 <end>
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
    80000b88:	052080e7          	jalr	82(ra) # 80001bd6 <mycpu>
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
    80000bba:	020080e7          	jalr	32(ra) # 80001bd6 <mycpu>
    80000bbe:	5d3c                	lw	a5,120(a0)
    80000bc0:	cf89                	beqz	a5,80000bda <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bc2:	00001097          	auipc	ra,0x1
    80000bc6:	014080e7          	jalr	20(ra) # 80001bd6 <mycpu>
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
    80000bde:	ffc080e7          	jalr	-4(ra) # 80001bd6 <mycpu>
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
    80000c1e:	fbc080e7          	jalr	-68(ra) # 80001bd6 <mycpu>
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
    80000c4a:	f90080e7          	jalr	-112(ra) # 80001bd6 <mycpu>
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
    80000ea0:	d2a080e7          	jalr	-726(ra) # 80001bc6 <cpuid>
    userinit();      // first user process
    pinit();
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
    80000ebc:	d0e080e7          	jalr	-754(ra) # 80001bc6 <cpuid>
    80000ec0:	85aa                	mv	a1,a0
    80000ec2:	00007517          	auipc	a0,0x7
    80000ec6:	1f650513          	addi	a0,a0,502 # 800080b8 <digits+0x78>
    80000eca:	fffff097          	auipc	ra,0xfffff
    80000ece:	6c4080e7          	jalr	1732(ra) # 8000058e <printf>
    kvminithart();    // turn on paging
    80000ed2:	00000097          	auipc	ra,0x0
    80000ed6:	0e0080e7          	jalr	224(ra) # 80000fb2 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eda:	00002097          	auipc	ra,0x2
    80000ede:	aae080e7          	jalr	-1362(ra) # 80002988 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ee2:	00005097          	auipc	ra,0x5
    80000ee6:	1fe080e7          	jalr	510(ra) # 800060e0 <plicinithart>
  }

  scheduler();        
    80000eea:	00001097          	auipc	ra,0x1
    80000eee:	2f8080e7          	jalr	760(ra) # 800021e2 <scheduler>
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
    80000f3e:	32e080e7          	jalr	814(ra) # 80001268 <kvminit>
    kvminithart();   // turn on paging
    80000f42:	00000097          	auipc	ra,0x0
    80000f46:	070080e7          	jalr	112(ra) # 80000fb2 <kvminithart>
    procinit();      // process table
    80000f4a:	00001097          	auipc	ra,0x1
    80000f4e:	bc6080e7          	jalr	-1082(ra) # 80001b10 <procinit>
    trapinit();      // trap vectors
    80000f52:	00002097          	auipc	ra,0x2
    80000f56:	a0e080e7          	jalr	-1522(ra) # 80002960 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f5a:	00002097          	auipc	ra,0x2
    80000f5e:	a2e080e7          	jalr	-1490(ra) # 80002988 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	168080e7          	jalr	360(ra) # 800060ca <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f6a:	00005097          	auipc	ra,0x5
    80000f6e:	176080e7          	jalr	374(ra) # 800060e0 <plicinithart>
    binit();         // buffer cache
    80000f72:	00002097          	auipc	ra,0x2
    80000f76:	32e080e7          	jalr	814(ra) # 800032a0 <binit>
    iinit();         // inode table
    80000f7a:	00003097          	auipc	ra,0x3
    80000f7e:	9d2080e7          	jalr	-1582(ra) # 8000394c <iinit>
    fileinit();      // file table
    80000f82:	00004097          	auipc	ra,0x4
    80000f86:	970080e7          	jalr	-1680(ra) # 800048f2 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f8a:	00005097          	auipc	ra,0x5
    80000f8e:	25e080e7          	jalr	606(ra) # 800061e8 <virtio_disk_init>
    userinit();      // first user process
    80000f92:	00001097          	auipc	ra,0x1
    80000f96:	fac080e7          	jalr	-84(ra) # 80001f3e <userinit>
    pinit();
    80000f9a:	00001097          	auipc	ra,0x1
    80000f9e:	9c6080e7          	jalr	-1594(ra) # 80001960 <pinit>
    __sync_synchronize();
    80000fa2:	0ff0000f          	fence
    started = 1;
    80000fa6:	4785                	li	a5,1
    80000fa8:	00008717          	auipc	a4,0x8
    80000fac:	bef72823          	sw	a5,-1040(a4) # 80008b98 <started>
    80000fb0:	bf2d                	j	80000eea <main+0x56>

0000000080000fb2 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fb2:	1141                	addi	sp,sp,-16
    80000fb4:	e422                	sd	s0,8(sp)
    80000fb6:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fb8:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000fbc:	00008797          	auipc	a5,0x8
    80000fc0:	be47b783          	ld	a5,-1052(a5) # 80008ba0 <kernel_pagetable>
    80000fc4:	83b1                	srli	a5,a5,0xc
    80000fc6:	577d                	li	a4,-1
    80000fc8:	177e                	slli	a4,a4,0x3f
    80000fca:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fcc:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fd0:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fd4:	6422                	ld	s0,8(sp)
    80000fd6:	0141                	addi	sp,sp,16
    80000fd8:	8082                	ret

0000000080000fda <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fda:	7139                	addi	sp,sp,-64
    80000fdc:	fc06                	sd	ra,56(sp)
    80000fde:	f822                	sd	s0,48(sp)
    80000fe0:	f426                	sd	s1,40(sp)
    80000fe2:	f04a                	sd	s2,32(sp)
    80000fe4:	ec4e                	sd	s3,24(sp)
    80000fe6:	e852                	sd	s4,16(sp)
    80000fe8:	e456                	sd	s5,8(sp)
    80000fea:	e05a                	sd	s6,0(sp)
    80000fec:	0080                	addi	s0,sp,64
    80000fee:	84aa                	mv	s1,a0
    80000ff0:	89ae                	mv	s3,a1
    80000ff2:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000ff4:	57fd                	li	a5,-1
    80000ff6:	83e9                	srli	a5,a5,0x1a
    80000ff8:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000ffa:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000ffc:	04b7f263          	bgeu	a5,a1,80001040 <walk+0x66>
    panic("walk");
    80001000:	00007517          	auipc	a0,0x7
    80001004:	0d050513          	addi	a0,a0,208 # 800080d0 <digits+0x90>
    80001008:	fffff097          	auipc	ra,0xfffff
    8000100c:	53c080e7          	jalr	1340(ra) # 80000544 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001010:	060a8663          	beqz	s5,8000107c <walk+0xa2>
    80001014:	00000097          	auipc	ra,0x0
    80001018:	ae6080e7          	jalr	-1306(ra) # 80000afa <kalloc>
    8000101c:	84aa                	mv	s1,a0
    8000101e:	c529                	beqz	a0,80001068 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001020:	6605                	lui	a2,0x1
    80001022:	4581                	li	a1,0
    80001024:	00000097          	auipc	ra,0x0
    80001028:	cc2080e7          	jalr	-830(ra) # 80000ce6 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000102c:	00c4d793          	srli	a5,s1,0xc
    80001030:	07aa                	slli	a5,a5,0xa
    80001032:	0017e793          	ori	a5,a5,1
    80001036:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000103a:	3a5d                	addiw	s4,s4,-9
    8000103c:	036a0063          	beq	s4,s6,8000105c <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001040:	0149d933          	srl	s2,s3,s4
    80001044:	1ff97913          	andi	s2,s2,511
    80001048:	090e                	slli	s2,s2,0x3
    8000104a:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000104c:	00093483          	ld	s1,0(s2)
    80001050:	0014f793          	andi	a5,s1,1
    80001054:	dfd5                	beqz	a5,80001010 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001056:	80a9                	srli	s1,s1,0xa
    80001058:	04b2                	slli	s1,s1,0xc
    8000105a:	b7c5                	j	8000103a <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000105c:	00c9d513          	srli	a0,s3,0xc
    80001060:	1ff57513          	andi	a0,a0,511
    80001064:	050e                	slli	a0,a0,0x3
    80001066:	9526                	add	a0,a0,s1
}
    80001068:	70e2                	ld	ra,56(sp)
    8000106a:	7442                	ld	s0,48(sp)
    8000106c:	74a2                	ld	s1,40(sp)
    8000106e:	7902                	ld	s2,32(sp)
    80001070:	69e2                	ld	s3,24(sp)
    80001072:	6a42                	ld	s4,16(sp)
    80001074:	6aa2                	ld	s5,8(sp)
    80001076:	6b02                	ld	s6,0(sp)
    80001078:	6121                	addi	sp,sp,64
    8000107a:	8082                	ret
        return 0;
    8000107c:	4501                	li	a0,0
    8000107e:	b7ed                	j	80001068 <walk+0x8e>

0000000080001080 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001080:	57fd                	li	a5,-1
    80001082:	83e9                	srli	a5,a5,0x1a
    80001084:	00b7f463          	bgeu	a5,a1,8000108c <walkaddr+0xc>
    return 0;
    80001088:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000108a:	8082                	ret
{
    8000108c:	1141                	addi	sp,sp,-16
    8000108e:	e406                	sd	ra,8(sp)
    80001090:	e022                	sd	s0,0(sp)
    80001092:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001094:	4601                	li	a2,0
    80001096:	00000097          	auipc	ra,0x0
    8000109a:	f44080e7          	jalr	-188(ra) # 80000fda <walk>
  if(pte == 0)
    8000109e:	c105                	beqz	a0,800010be <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800010a0:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010a2:	0117f693          	andi	a3,a5,17
    800010a6:	4745                	li	a4,17
    return 0;
    800010a8:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010aa:	00e68663          	beq	a3,a4,800010b6 <walkaddr+0x36>
}
    800010ae:	60a2                	ld	ra,8(sp)
    800010b0:	6402                	ld	s0,0(sp)
    800010b2:	0141                	addi	sp,sp,16
    800010b4:	8082                	ret
  pa = PTE2PA(*pte);
    800010b6:	00a7d513          	srli	a0,a5,0xa
    800010ba:	0532                	slli	a0,a0,0xc
  return pa;
    800010bc:	bfcd                	j	800010ae <walkaddr+0x2e>
    return 0;
    800010be:	4501                	li	a0,0
    800010c0:	b7fd                	j	800010ae <walkaddr+0x2e>

00000000800010c2 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010c2:	715d                	addi	sp,sp,-80
    800010c4:	e486                	sd	ra,72(sp)
    800010c6:	e0a2                	sd	s0,64(sp)
    800010c8:	fc26                	sd	s1,56(sp)
    800010ca:	f84a                	sd	s2,48(sp)
    800010cc:	f44e                	sd	s3,40(sp)
    800010ce:	f052                	sd	s4,32(sp)
    800010d0:	ec56                	sd	s5,24(sp)
    800010d2:	e85a                	sd	s6,16(sp)
    800010d4:	e45e                	sd	s7,8(sp)
    800010d6:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010d8:	c205                	beqz	a2,800010f8 <mappages+0x36>
    800010da:	8aaa                	mv	s5,a0
    800010dc:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010de:	77fd                	lui	a5,0xfffff
    800010e0:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800010e4:	15fd                	addi	a1,a1,-1
    800010e6:	00c589b3          	add	s3,a1,a2
    800010ea:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    800010ee:	8952                	mv	s2,s4
    800010f0:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010f4:	6b85                	lui	s7,0x1
    800010f6:	a015                	j	8000111a <mappages+0x58>
    panic("mappages: size");
    800010f8:	00007517          	auipc	a0,0x7
    800010fc:	fe050513          	addi	a0,a0,-32 # 800080d8 <digits+0x98>
    80001100:	fffff097          	auipc	ra,0xfffff
    80001104:	444080e7          	jalr	1092(ra) # 80000544 <panic>
      panic("mappages: remap");
    80001108:	00007517          	auipc	a0,0x7
    8000110c:	fe050513          	addi	a0,a0,-32 # 800080e8 <digits+0xa8>
    80001110:	fffff097          	auipc	ra,0xfffff
    80001114:	434080e7          	jalr	1076(ra) # 80000544 <panic>
    a += PGSIZE;
    80001118:	995e                	add	s2,s2,s7
  for(;;){
    8000111a:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000111e:	4605                	li	a2,1
    80001120:	85ca                	mv	a1,s2
    80001122:	8556                	mv	a0,s5
    80001124:	00000097          	auipc	ra,0x0
    80001128:	eb6080e7          	jalr	-330(ra) # 80000fda <walk>
    8000112c:	cd19                	beqz	a0,8000114a <mappages+0x88>
    if(*pte & PTE_V)
    8000112e:	611c                	ld	a5,0(a0)
    80001130:	8b85                	andi	a5,a5,1
    80001132:	fbf9                	bnez	a5,80001108 <mappages+0x46>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001134:	80b1                	srli	s1,s1,0xc
    80001136:	04aa                	slli	s1,s1,0xa
    80001138:	0164e4b3          	or	s1,s1,s6
    8000113c:	0014e493          	ori	s1,s1,1
    80001140:	e104                	sd	s1,0(a0)
    if(a == last)
    80001142:	fd391be3          	bne	s2,s3,80001118 <mappages+0x56>
    pa += PGSIZE;
  }
  return 0;
    80001146:	4501                	li	a0,0
    80001148:	a011                	j	8000114c <mappages+0x8a>
      return -1;
    8000114a:	557d                	li	a0,-1
}
    8000114c:	60a6                	ld	ra,72(sp)
    8000114e:	6406                	ld	s0,64(sp)
    80001150:	74e2                	ld	s1,56(sp)
    80001152:	7942                	ld	s2,48(sp)
    80001154:	79a2                	ld	s3,40(sp)
    80001156:	7a02                	ld	s4,32(sp)
    80001158:	6ae2                	ld	s5,24(sp)
    8000115a:	6b42                	ld	s6,16(sp)
    8000115c:	6ba2                	ld	s7,8(sp)
    8000115e:	6161                	addi	sp,sp,80
    80001160:	8082                	ret

0000000080001162 <kvmmap>:
{
    80001162:	1141                	addi	sp,sp,-16
    80001164:	e406                	sd	ra,8(sp)
    80001166:	e022                	sd	s0,0(sp)
    80001168:	0800                	addi	s0,sp,16
    8000116a:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000116c:	86b2                	mv	a3,a2
    8000116e:	863e                	mv	a2,a5
    80001170:	00000097          	auipc	ra,0x0
    80001174:	f52080e7          	jalr	-174(ra) # 800010c2 <mappages>
    80001178:	e509                	bnez	a0,80001182 <kvmmap+0x20>
}
    8000117a:	60a2                	ld	ra,8(sp)
    8000117c:	6402                	ld	s0,0(sp)
    8000117e:	0141                	addi	sp,sp,16
    80001180:	8082                	ret
    panic("kvmmap");
    80001182:	00007517          	auipc	a0,0x7
    80001186:	f7650513          	addi	a0,a0,-138 # 800080f8 <digits+0xb8>
    8000118a:	fffff097          	auipc	ra,0xfffff
    8000118e:	3ba080e7          	jalr	954(ra) # 80000544 <panic>

0000000080001192 <kvmmake>:
{
    80001192:	1101                	addi	sp,sp,-32
    80001194:	ec06                	sd	ra,24(sp)
    80001196:	e822                	sd	s0,16(sp)
    80001198:	e426                	sd	s1,8(sp)
    8000119a:	e04a                	sd	s2,0(sp)
    8000119c:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000119e:	00000097          	auipc	ra,0x0
    800011a2:	95c080e7          	jalr	-1700(ra) # 80000afa <kalloc>
    800011a6:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800011a8:	6605                	lui	a2,0x1
    800011aa:	4581                	li	a1,0
    800011ac:	00000097          	auipc	ra,0x0
    800011b0:	b3a080e7          	jalr	-1222(ra) # 80000ce6 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011b4:	4719                	li	a4,6
    800011b6:	6685                	lui	a3,0x1
    800011b8:	10000637          	lui	a2,0x10000
    800011bc:	100005b7          	lui	a1,0x10000
    800011c0:	8526                	mv	a0,s1
    800011c2:	00000097          	auipc	ra,0x0
    800011c6:	fa0080e7          	jalr	-96(ra) # 80001162 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011ca:	4719                	li	a4,6
    800011cc:	6685                	lui	a3,0x1
    800011ce:	10001637          	lui	a2,0x10001
    800011d2:	100015b7          	lui	a1,0x10001
    800011d6:	8526                	mv	a0,s1
    800011d8:	00000097          	auipc	ra,0x0
    800011dc:	f8a080e7          	jalr	-118(ra) # 80001162 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011e0:	4719                	li	a4,6
    800011e2:	004006b7          	lui	a3,0x400
    800011e6:	0c000637          	lui	a2,0xc000
    800011ea:	0c0005b7          	lui	a1,0xc000
    800011ee:	8526                	mv	a0,s1
    800011f0:	00000097          	auipc	ra,0x0
    800011f4:	f72080e7          	jalr	-142(ra) # 80001162 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011f8:	00007917          	auipc	s2,0x7
    800011fc:	e0890913          	addi	s2,s2,-504 # 80008000 <etext>
    80001200:	4729                	li	a4,10
    80001202:	80007697          	auipc	a3,0x80007
    80001206:	dfe68693          	addi	a3,a3,-514 # 8000 <_entry-0x7fff8000>
    8000120a:	4605                	li	a2,1
    8000120c:	067e                	slli	a2,a2,0x1f
    8000120e:	85b2                	mv	a1,a2
    80001210:	8526                	mv	a0,s1
    80001212:	00000097          	auipc	ra,0x0
    80001216:	f50080e7          	jalr	-176(ra) # 80001162 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000121a:	4719                	li	a4,6
    8000121c:	46c5                	li	a3,17
    8000121e:	06ee                	slli	a3,a3,0x1b
    80001220:	412686b3          	sub	a3,a3,s2
    80001224:	864a                	mv	a2,s2
    80001226:	85ca                	mv	a1,s2
    80001228:	8526                	mv	a0,s1
    8000122a:	00000097          	auipc	ra,0x0
    8000122e:	f38080e7          	jalr	-200(ra) # 80001162 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001232:	4729                	li	a4,10
    80001234:	6685                	lui	a3,0x1
    80001236:	00006617          	auipc	a2,0x6
    8000123a:	dca60613          	addi	a2,a2,-566 # 80007000 <_trampoline>
    8000123e:	040005b7          	lui	a1,0x4000
    80001242:	15fd                	addi	a1,a1,-1
    80001244:	05b2                	slli	a1,a1,0xc
    80001246:	8526                	mv	a0,s1
    80001248:	00000097          	auipc	ra,0x0
    8000124c:	f1a080e7          	jalr	-230(ra) # 80001162 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001250:	8526                	mv	a0,s1
    80001252:	00001097          	auipc	ra,0x1
    80001256:	828080e7          	jalr	-2008(ra) # 80001a7a <proc_mapstacks>
}
    8000125a:	8526                	mv	a0,s1
    8000125c:	60e2                	ld	ra,24(sp)
    8000125e:	6442                	ld	s0,16(sp)
    80001260:	64a2                	ld	s1,8(sp)
    80001262:	6902                	ld	s2,0(sp)
    80001264:	6105                	addi	sp,sp,32
    80001266:	8082                	ret

0000000080001268 <kvminit>:
{
    80001268:	1141                	addi	sp,sp,-16
    8000126a:	e406                	sd	ra,8(sp)
    8000126c:	e022                	sd	s0,0(sp)
    8000126e:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001270:	00000097          	auipc	ra,0x0
    80001274:	f22080e7          	jalr	-222(ra) # 80001192 <kvmmake>
    80001278:	00008797          	auipc	a5,0x8
    8000127c:	92a7b423          	sd	a0,-1752(a5) # 80008ba0 <kernel_pagetable>
}
    80001280:	60a2                	ld	ra,8(sp)
    80001282:	6402                	ld	s0,0(sp)
    80001284:	0141                	addi	sp,sp,16
    80001286:	8082                	ret

0000000080001288 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001288:	715d                	addi	sp,sp,-80
    8000128a:	e486                	sd	ra,72(sp)
    8000128c:	e0a2                	sd	s0,64(sp)
    8000128e:	fc26                	sd	s1,56(sp)
    80001290:	f84a                	sd	s2,48(sp)
    80001292:	f44e                	sd	s3,40(sp)
    80001294:	f052                	sd	s4,32(sp)
    80001296:	ec56                	sd	s5,24(sp)
    80001298:	e85a                	sd	s6,16(sp)
    8000129a:	e45e                	sd	s7,8(sp)
    8000129c:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000129e:	03459793          	slli	a5,a1,0x34
    800012a2:	e795                	bnez	a5,800012ce <uvmunmap+0x46>
    800012a4:	8a2a                	mv	s4,a0
    800012a6:	892e                	mv	s2,a1
    800012a8:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012aa:	0632                	slli	a2,a2,0xc
    800012ac:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800012b0:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012b2:	6b05                	lui	s6,0x1
    800012b4:	0735e863          	bltu	a1,s3,80001324 <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012b8:	60a6                	ld	ra,72(sp)
    800012ba:	6406                	ld	s0,64(sp)
    800012bc:	74e2                	ld	s1,56(sp)
    800012be:	7942                	ld	s2,48(sp)
    800012c0:	79a2                	ld	s3,40(sp)
    800012c2:	7a02                	ld	s4,32(sp)
    800012c4:	6ae2                	ld	s5,24(sp)
    800012c6:	6b42                	ld	s6,16(sp)
    800012c8:	6ba2                	ld	s7,8(sp)
    800012ca:	6161                	addi	sp,sp,80
    800012cc:	8082                	ret
    panic("uvmunmap: not aligned");
    800012ce:	00007517          	auipc	a0,0x7
    800012d2:	e3250513          	addi	a0,a0,-462 # 80008100 <digits+0xc0>
    800012d6:	fffff097          	auipc	ra,0xfffff
    800012da:	26e080e7          	jalr	622(ra) # 80000544 <panic>
      panic("uvmunmap: walk");
    800012de:	00007517          	auipc	a0,0x7
    800012e2:	e3a50513          	addi	a0,a0,-454 # 80008118 <digits+0xd8>
    800012e6:	fffff097          	auipc	ra,0xfffff
    800012ea:	25e080e7          	jalr	606(ra) # 80000544 <panic>
      panic("uvmunmap: not mapped");
    800012ee:	00007517          	auipc	a0,0x7
    800012f2:	e3a50513          	addi	a0,a0,-454 # 80008128 <digits+0xe8>
    800012f6:	fffff097          	auipc	ra,0xfffff
    800012fa:	24e080e7          	jalr	590(ra) # 80000544 <panic>
      panic("uvmunmap: not a leaf");
    800012fe:	00007517          	auipc	a0,0x7
    80001302:	e4250513          	addi	a0,a0,-446 # 80008140 <digits+0x100>
    80001306:	fffff097          	auipc	ra,0xfffff
    8000130a:	23e080e7          	jalr	574(ra) # 80000544 <panic>
      uint64 pa = PTE2PA(*pte);
    8000130e:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001310:	0532                	slli	a0,a0,0xc
    80001312:	fffff097          	auipc	ra,0xfffff
    80001316:	6ec080e7          	jalr	1772(ra) # 800009fe <kfree>
    *pte = 0;
    8000131a:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000131e:	995a                	add	s2,s2,s6
    80001320:	f9397ce3          	bgeu	s2,s3,800012b8 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001324:	4601                	li	a2,0
    80001326:	85ca                	mv	a1,s2
    80001328:	8552                	mv	a0,s4
    8000132a:	00000097          	auipc	ra,0x0
    8000132e:	cb0080e7          	jalr	-848(ra) # 80000fda <walk>
    80001332:	84aa                	mv	s1,a0
    80001334:	d54d                	beqz	a0,800012de <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001336:	6108                	ld	a0,0(a0)
    80001338:	00157793          	andi	a5,a0,1
    8000133c:	dbcd                	beqz	a5,800012ee <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000133e:	3ff57793          	andi	a5,a0,1023
    80001342:	fb778ee3          	beq	a5,s7,800012fe <uvmunmap+0x76>
    if(do_free){
    80001346:	fc0a8ae3          	beqz	s5,8000131a <uvmunmap+0x92>
    8000134a:	b7d1                	j	8000130e <uvmunmap+0x86>

000000008000134c <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000134c:	1101                	addi	sp,sp,-32
    8000134e:	ec06                	sd	ra,24(sp)
    80001350:	e822                	sd	s0,16(sp)
    80001352:	e426                	sd	s1,8(sp)
    80001354:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001356:	fffff097          	auipc	ra,0xfffff
    8000135a:	7a4080e7          	jalr	1956(ra) # 80000afa <kalloc>
    8000135e:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001360:	c519                	beqz	a0,8000136e <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001362:	6605                	lui	a2,0x1
    80001364:	4581                	li	a1,0
    80001366:	00000097          	auipc	ra,0x0
    8000136a:	980080e7          	jalr	-1664(ra) # 80000ce6 <memset>
  return pagetable;
}
    8000136e:	8526                	mv	a0,s1
    80001370:	60e2                	ld	ra,24(sp)
    80001372:	6442                	ld	s0,16(sp)
    80001374:	64a2                	ld	s1,8(sp)
    80001376:	6105                	addi	sp,sp,32
    80001378:	8082                	ret

000000008000137a <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    8000137a:	7179                	addi	sp,sp,-48
    8000137c:	f406                	sd	ra,40(sp)
    8000137e:	f022                	sd	s0,32(sp)
    80001380:	ec26                	sd	s1,24(sp)
    80001382:	e84a                	sd	s2,16(sp)
    80001384:	e44e                	sd	s3,8(sp)
    80001386:	e052                	sd	s4,0(sp)
    80001388:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000138a:	6785                	lui	a5,0x1
    8000138c:	04f67863          	bgeu	a2,a5,800013dc <uvmfirst+0x62>
    80001390:	8a2a                	mv	s4,a0
    80001392:	89ae                	mv	s3,a1
    80001394:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001396:	fffff097          	auipc	ra,0xfffff
    8000139a:	764080e7          	jalr	1892(ra) # 80000afa <kalloc>
    8000139e:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800013a0:	6605                	lui	a2,0x1
    800013a2:	4581                	li	a1,0
    800013a4:	00000097          	auipc	ra,0x0
    800013a8:	942080e7          	jalr	-1726(ra) # 80000ce6 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800013ac:	4779                	li	a4,30
    800013ae:	86ca                	mv	a3,s2
    800013b0:	6605                	lui	a2,0x1
    800013b2:	4581                	li	a1,0
    800013b4:	8552                	mv	a0,s4
    800013b6:	00000097          	auipc	ra,0x0
    800013ba:	d0c080e7          	jalr	-756(ra) # 800010c2 <mappages>
  memmove(mem, src, sz);
    800013be:	8626                	mv	a2,s1
    800013c0:	85ce                	mv	a1,s3
    800013c2:	854a                	mv	a0,s2
    800013c4:	00000097          	auipc	ra,0x0
    800013c8:	982080e7          	jalr	-1662(ra) # 80000d46 <memmove>
}
    800013cc:	70a2                	ld	ra,40(sp)
    800013ce:	7402                	ld	s0,32(sp)
    800013d0:	64e2                	ld	s1,24(sp)
    800013d2:	6942                	ld	s2,16(sp)
    800013d4:	69a2                	ld	s3,8(sp)
    800013d6:	6a02                	ld	s4,0(sp)
    800013d8:	6145                	addi	sp,sp,48
    800013da:	8082                	ret
    panic("uvmfirst: more than a page");
    800013dc:	00007517          	auipc	a0,0x7
    800013e0:	d7c50513          	addi	a0,a0,-644 # 80008158 <digits+0x118>
    800013e4:	fffff097          	auipc	ra,0xfffff
    800013e8:	160080e7          	jalr	352(ra) # 80000544 <panic>

00000000800013ec <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013ec:	1101                	addi	sp,sp,-32
    800013ee:	ec06                	sd	ra,24(sp)
    800013f0:	e822                	sd	s0,16(sp)
    800013f2:	e426                	sd	s1,8(sp)
    800013f4:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013f6:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013f8:	00b67d63          	bgeu	a2,a1,80001412 <uvmdealloc+0x26>
    800013fc:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013fe:	6785                	lui	a5,0x1
    80001400:	17fd                	addi	a5,a5,-1
    80001402:	00f60733          	add	a4,a2,a5
    80001406:	767d                	lui	a2,0xfffff
    80001408:	8f71                	and	a4,a4,a2
    8000140a:	97ae                	add	a5,a5,a1
    8000140c:	8ff1                	and	a5,a5,a2
    8000140e:	00f76863          	bltu	a4,a5,8000141e <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001412:	8526                	mv	a0,s1
    80001414:	60e2                	ld	ra,24(sp)
    80001416:	6442                	ld	s0,16(sp)
    80001418:	64a2                	ld	s1,8(sp)
    8000141a:	6105                	addi	sp,sp,32
    8000141c:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000141e:	8f99                	sub	a5,a5,a4
    80001420:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001422:	4685                	li	a3,1
    80001424:	0007861b          	sext.w	a2,a5
    80001428:	85ba                	mv	a1,a4
    8000142a:	00000097          	auipc	ra,0x0
    8000142e:	e5e080e7          	jalr	-418(ra) # 80001288 <uvmunmap>
    80001432:	b7c5                	j	80001412 <uvmdealloc+0x26>

0000000080001434 <uvmalloc>:
  if(newsz < oldsz)
    80001434:	0ab66563          	bltu	a2,a1,800014de <uvmalloc+0xaa>
{
    80001438:	7139                	addi	sp,sp,-64
    8000143a:	fc06                	sd	ra,56(sp)
    8000143c:	f822                	sd	s0,48(sp)
    8000143e:	f426                	sd	s1,40(sp)
    80001440:	f04a                	sd	s2,32(sp)
    80001442:	ec4e                	sd	s3,24(sp)
    80001444:	e852                	sd	s4,16(sp)
    80001446:	e456                	sd	s5,8(sp)
    80001448:	e05a                	sd	s6,0(sp)
    8000144a:	0080                	addi	s0,sp,64
    8000144c:	8aaa                	mv	s5,a0
    8000144e:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001450:	6985                	lui	s3,0x1
    80001452:	19fd                	addi	s3,s3,-1
    80001454:	95ce                	add	a1,a1,s3
    80001456:	79fd                	lui	s3,0xfffff
    80001458:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000145c:	08c9f363          	bgeu	s3,a2,800014e2 <uvmalloc+0xae>
    80001460:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001462:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001466:	fffff097          	auipc	ra,0xfffff
    8000146a:	694080e7          	jalr	1684(ra) # 80000afa <kalloc>
    8000146e:	84aa                	mv	s1,a0
    if(mem == 0){
    80001470:	c51d                	beqz	a0,8000149e <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    80001472:	6605                	lui	a2,0x1
    80001474:	4581                	li	a1,0
    80001476:	00000097          	auipc	ra,0x0
    8000147a:	870080e7          	jalr	-1936(ra) # 80000ce6 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000147e:	875a                	mv	a4,s6
    80001480:	86a6                	mv	a3,s1
    80001482:	6605                	lui	a2,0x1
    80001484:	85ca                	mv	a1,s2
    80001486:	8556                	mv	a0,s5
    80001488:	00000097          	auipc	ra,0x0
    8000148c:	c3a080e7          	jalr	-966(ra) # 800010c2 <mappages>
    80001490:	e90d                	bnez	a0,800014c2 <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001492:	6785                	lui	a5,0x1
    80001494:	993e                	add	s2,s2,a5
    80001496:	fd4968e3          	bltu	s2,s4,80001466 <uvmalloc+0x32>
  return newsz;
    8000149a:	8552                	mv	a0,s4
    8000149c:	a809                	j	800014ae <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000149e:	864e                	mv	a2,s3
    800014a0:	85ca                	mv	a1,s2
    800014a2:	8556                	mv	a0,s5
    800014a4:	00000097          	auipc	ra,0x0
    800014a8:	f48080e7          	jalr	-184(ra) # 800013ec <uvmdealloc>
      return 0;
    800014ac:	4501                	li	a0,0
}
    800014ae:	70e2                	ld	ra,56(sp)
    800014b0:	7442                	ld	s0,48(sp)
    800014b2:	74a2                	ld	s1,40(sp)
    800014b4:	7902                	ld	s2,32(sp)
    800014b6:	69e2                	ld	s3,24(sp)
    800014b8:	6a42                	ld	s4,16(sp)
    800014ba:	6aa2                	ld	s5,8(sp)
    800014bc:	6b02                	ld	s6,0(sp)
    800014be:	6121                	addi	sp,sp,64
    800014c0:	8082                	ret
      kfree(mem);
    800014c2:	8526                	mv	a0,s1
    800014c4:	fffff097          	auipc	ra,0xfffff
    800014c8:	53a080e7          	jalr	1338(ra) # 800009fe <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014cc:	864e                	mv	a2,s3
    800014ce:	85ca                	mv	a1,s2
    800014d0:	8556                	mv	a0,s5
    800014d2:	00000097          	auipc	ra,0x0
    800014d6:	f1a080e7          	jalr	-230(ra) # 800013ec <uvmdealloc>
      return 0;
    800014da:	4501                	li	a0,0
    800014dc:	bfc9                	j	800014ae <uvmalloc+0x7a>
    return oldsz;
    800014de:	852e                	mv	a0,a1
}
    800014e0:	8082                	ret
  return newsz;
    800014e2:	8532                	mv	a0,a2
    800014e4:	b7e9                	j	800014ae <uvmalloc+0x7a>

00000000800014e6 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014e6:	7179                	addi	sp,sp,-48
    800014e8:	f406                	sd	ra,40(sp)
    800014ea:	f022                	sd	s0,32(sp)
    800014ec:	ec26                	sd	s1,24(sp)
    800014ee:	e84a                	sd	s2,16(sp)
    800014f0:	e44e                	sd	s3,8(sp)
    800014f2:	e052                	sd	s4,0(sp)
    800014f4:	1800                	addi	s0,sp,48
    800014f6:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014f8:	84aa                	mv	s1,a0
    800014fa:	6905                	lui	s2,0x1
    800014fc:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014fe:	4985                	li	s3,1
    80001500:	a821                	j	80001518 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001502:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80001504:	0532                	slli	a0,a0,0xc
    80001506:	00000097          	auipc	ra,0x0
    8000150a:	fe0080e7          	jalr	-32(ra) # 800014e6 <freewalk>
      pagetable[i] = 0;
    8000150e:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001512:	04a1                	addi	s1,s1,8
    80001514:	03248163          	beq	s1,s2,80001536 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001518:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000151a:	00f57793          	andi	a5,a0,15
    8000151e:	ff3782e3          	beq	a5,s3,80001502 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001522:	8905                	andi	a0,a0,1
    80001524:	d57d                	beqz	a0,80001512 <freewalk+0x2c>
      panic("freewalk: leaf");
    80001526:	00007517          	auipc	a0,0x7
    8000152a:	c5250513          	addi	a0,a0,-942 # 80008178 <digits+0x138>
    8000152e:	fffff097          	auipc	ra,0xfffff
    80001532:	016080e7          	jalr	22(ra) # 80000544 <panic>
    }
  }
  kfree((void*)pagetable);
    80001536:	8552                	mv	a0,s4
    80001538:	fffff097          	auipc	ra,0xfffff
    8000153c:	4c6080e7          	jalr	1222(ra) # 800009fe <kfree>
}
    80001540:	70a2                	ld	ra,40(sp)
    80001542:	7402                	ld	s0,32(sp)
    80001544:	64e2                	ld	s1,24(sp)
    80001546:	6942                	ld	s2,16(sp)
    80001548:	69a2                	ld	s3,8(sp)
    8000154a:	6a02                	ld	s4,0(sp)
    8000154c:	6145                	addi	sp,sp,48
    8000154e:	8082                	ret

0000000080001550 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001550:	1101                	addi	sp,sp,-32
    80001552:	ec06                	sd	ra,24(sp)
    80001554:	e822                	sd	s0,16(sp)
    80001556:	e426                	sd	s1,8(sp)
    80001558:	1000                	addi	s0,sp,32
    8000155a:	84aa                	mv	s1,a0
  if(sz > 0)
    8000155c:	e999                	bnez	a1,80001572 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000155e:	8526                	mv	a0,s1
    80001560:	00000097          	auipc	ra,0x0
    80001564:	f86080e7          	jalr	-122(ra) # 800014e6 <freewalk>
}
    80001568:	60e2                	ld	ra,24(sp)
    8000156a:	6442                	ld	s0,16(sp)
    8000156c:	64a2                	ld	s1,8(sp)
    8000156e:	6105                	addi	sp,sp,32
    80001570:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001572:	6605                	lui	a2,0x1
    80001574:	167d                	addi	a2,a2,-1
    80001576:	962e                	add	a2,a2,a1
    80001578:	4685                	li	a3,1
    8000157a:	8231                	srli	a2,a2,0xc
    8000157c:	4581                	li	a1,0
    8000157e:	00000097          	auipc	ra,0x0
    80001582:	d0a080e7          	jalr	-758(ra) # 80001288 <uvmunmap>
    80001586:	bfe1                	j	8000155e <uvmfree+0xe>

0000000080001588 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001588:	c679                	beqz	a2,80001656 <uvmcopy+0xce>
{
    8000158a:	715d                	addi	sp,sp,-80
    8000158c:	e486                	sd	ra,72(sp)
    8000158e:	e0a2                	sd	s0,64(sp)
    80001590:	fc26                	sd	s1,56(sp)
    80001592:	f84a                	sd	s2,48(sp)
    80001594:	f44e                	sd	s3,40(sp)
    80001596:	f052                	sd	s4,32(sp)
    80001598:	ec56                	sd	s5,24(sp)
    8000159a:	e85a                	sd	s6,16(sp)
    8000159c:	e45e                	sd	s7,8(sp)
    8000159e:	0880                	addi	s0,sp,80
    800015a0:	8b2a                	mv	s6,a0
    800015a2:	8aae                	mv	s5,a1
    800015a4:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800015a6:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800015a8:	4601                	li	a2,0
    800015aa:	85ce                	mv	a1,s3
    800015ac:	855a                	mv	a0,s6
    800015ae:	00000097          	auipc	ra,0x0
    800015b2:	a2c080e7          	jalr	-1492(ra) # 80000fda <walk>
    800015b6:	c531                	beqz	a0,80001602 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800015b8:	6118                	ld	a4,0(a0)
    800015ba:	00177793          	andi	a5,a4,1
    800015be:	cbb1                	beqz	a5,80001612 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015c0:	00a75593          	srli	a1,a4,0xa
    800015c4:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015c8:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015cc:	fffff097          	auipc	ra,0xfffff
    800015d0:	52e080e7          	jalr	1326(ra) # 80000afa <kalloc>
    800015d4:	892a                	mv	s2,a0
    800015d6:	c939                	beqz	a0,8000162c <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015d8:	6605                	lui	a2,0x1
    800015da:	85de                	mv	a1,s7
    800015dc:	fffff097          	auipc	ra,0xfffff
    800015e0:	76a080e7          	jalr	1898(ra) # 80000d46 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015e4:	8726                	mv	a4,s1
    800015e6:	86ca                	mv	a3,s2
    800015e8:	6605                	lui	a2,0x1
    800015ea:	85ce                	mv	a1,s3
    800015ec:	8556                	mv	a0,s5
    800015ee:	00000097          	auipc	ra,0x0
    800015f2:	ad4080e7          	jalr	-1324(ra) # 800010c2 <mappages>
    800015f6:	e515                	bnez	a0,80001622 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015f8:	6785                	lui	a5,0x1
    800015fa:	99be                	add	s3,s3,a5
    800015fc:	fb49e6e3          	bltu	s3,s4,800015a8 <uvmcopy+0x20>
    80001600:	a081                	j	80001640 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80001602:	00007517          	auipc	a0,0x7
    80001606:	b8650513          	addi	a0,a0,-1146 # 80008188 <digits+0x148>
    8000160a:	fffff097          	auipc	ra,0xfffff
    8000160e:	f3a080e7          	jalr	-198(ra) # 80000544 <panic>
      panic("uvmcopy: page not present");
    80001612:	00007517          	auipc	a0,0x7
    80001616:	b9650513          	addi	a0,a0,-1130 # 800081a8 <digits+0x168>
    8000161a:	fffff097          	auipc	ra,0xfffff
    8000161e:	f2a080e7          	jalr	-214(ra) # 80000544 <panic>
      kfree(mem);
    80001622:	854a                	mv	a0,s2
    80001624:	fffff097          	auipc	ra,0xfffff
    80001628:	3da080e7          	jalr	986(ra) # 800009fe <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000162c:	4685                	li	a3,1
    8000162e:	00c9d613          	srli	a2,s3,0xc
    80001632:	4581                	li	a1,0
    80001634:	8556                	mv	a0,s5
    80001636:	00000097          	auipc	ra,0x0
    8000163a:	c52080e7          	jalr	-942(ra) # 80001288 <uvmunmap>
  return -1;
    8000163e:	557d                	li	a0,-1
}
    80001640:	60a6                	ld	ra,72(sp)
    80001642:	6406                	ld	s0,64(sp)
    80001644:	74e2                	ld	s1,56(sp)
    80001646:	7942                	ld	s2,48(sp)
    80001648:	79a2                	ld	s3,40(sp)
    8000164a:	7a02                	ld	s4,32(sp)
    8000164c:	6ae2                	ld	s5,24(sp)
    8000164e:	6b42                	ld	s6,16(sp)
    80001650:	6ba2                	ld	s7,8(sp)
    80001652:	6161                	addi	sp,sp,80
    80001654:	8082                	ret
  return 0;
    80001656:	4501                	li	a0,0
}
    80001658:	8082                	ret

000000008000165a <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000165a:	1141                	addi	sp,sp,-16
    8000165c:	e406                	sd	ra,8(sp)
    8000165e:	e022                	sd	s0,0(sp)
    80001660:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001662:	4601                	li	a2,0
    80001664:	00000097          	auipc	ra,0x0
    80001668:	976080e7          	jalr	-1674(ra) # 80000fda <walk>
  if(pte == 0)
    8000166c:	c901                	beqz	a0,8000167c <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000166e:	611c                	ld	a5,0(a0)
    80001670:	9bbd                	andi	a5,a5,-17
    80001672:	e11c                	sd	a5,0(a0)
}
    80001674:	60a2                	ld	ra,8(sp)
    80001676:	6402                	ld	s0,0(sp)
    80001678:	0141                	addi	sp,sp,16
    8000167a:	8082                	ret
    panic("uvmclear");
    8000167c:	00007517          	auipc	a0,0x7
    80001680:	b4c50513          	addi	a0,a0,-1204 # 800081c8 <digits+0x188>
    80001684:	fffff097          	auipc	ra,0xfffff
    80001688:	ec0080e7          	jalr	-320(ra) # 80000544 <panic>

000000008000168c <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000168c:	c6bd                	beqz	a3,800016fa <copyout+0x6e>
{
    8000168e:	715d                	addi	sp,sp,-80
    80001690:	e486                	sd	ra,72(sp)
    80001692:	e0a2                	sd	s0,64(sp)
    80001694:	fc26                	sd	s1,56(sp)
    80001696:	f84a                	sd	s2,48(sp)
    80001698:	f44e                	sd	s3,40(sp)
    8000169a:	f052                	sd	s4,32(sp)
    8000169c:	ec56                	sd	s5,24(sp)
    8000169e:	e85a                	sd	s6,16(sp)
    800016a0:	e45e                	sd	s7,8(sp)
    800016a2:	e062                	sd	s8,0(sp)
    800016a4:	0880                	addi	s0,sp,80
    800016a6:	8b2a                	mv	s6,a0
    800016a8:	8c2e                	mv	s8,a1
    800016aa:	8a32                	mv	s4,a2
    800016ac:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800016ae:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800016b0:	6a85                	lui	s5,0x1
    800016b2:	a015                	j	800016d6 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800016b4:	9562                	add	a0,a0,s8
    800016b6:	0004861b          	sext.w	a2,s1
    800016ba:	85d2                	mv	a1,s4
    800016bc:	41250533          	sub	a0,a0,s2
    800016c0:	fffff097          	auipc	ra,0xfffff
    800016c4:	686080e7          	jalr	1670(ra) # 80000d46 <memmove>

    len -= n;
    800016c8:	409989b3          	sub	s3,s3,s1
    src += n;
    800016cc:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016ce:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016d2:	02098263          	beqz	s3,800016f6 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016d6:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016da:	85ca                	mv	a1,s2
    800016dc:	855a                	mv	a0,s6
    800016de:	00000097          	auipc	ra,0x0
    800016e2:	9a2080e7          	jalr	-1630(ra) # 80001080 <walkaddr>
    if(pa0 == 0)
    800016e6:	cd01                	beqz	a0,800016fe <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016e8:	418904b3          	sub	s1,s2,s8
    800016ec:	94d6                	add	s1,s1,s5
    if(n > len)
    800016ee:	fc99f3e3          	bgeu	s3,s1,800016b4 <copyout+0x28>
    800016f2:	84ce                	mv	s1,s3
    800016f4:	b7c1                	j	800016b4 <copyout+0x28>
  }
  return 0;
    800016f6:	4501                	li	a0,0
    800016f8:	a021                	j	80001700 <copyout+0x74>
    800016fa:	4501                	li	a0,0
}
    800016fc:	8082                	ret
      return -1;
    800016fe:	557d                	li	a0,-1
}
    80001700:	60a6                	ld	ra,72(sp)
    80001702:	6406                	ld	s0,64(sp)
    80001704:	74e2                	ld	s1,56(sp)
    80001706:	7942                	ld	s2,48(sp)
    80001708:	79a2                	ld	s3,40(sp)
    8000170a:	7a02                	ld	s4,32(sp)
    8000170c:	6ae2                	ld	s5,24(sp)
    8000170e:	6b42                	ld	s6,16(sp)
    80001710:	6ba2                	ld	s7,8(sp)
    80001712:	6c02                	ld	s8,0(sp)
    80001714:	6161                	addi	sp,sp,80
    80001716:	8082                	ret

0000000080001718 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001718:	c6bd                	beqz	a3,80001786 <copyin+0x6e>
{
    8000171a:	715d                	addi	sp,sp,-80
    8000171c:	e486                	sd	ra,72(sp)
    8000171e:	e0a2                	sd	s0,64(sp)
    80001720:	fc26                	sd	s1,56(sp)
    80001722:	f84a                	sd	s2,48(sp)
    80001724:	f44e                	sd	s3,40(sp)
    80001726:	f052                	sd	s4,32(sp)
    80001728:	ec56                	sd	s5,24(sp)
    8000172a:	e85a                	sd	s6,16(sp)
    8000172c:	e45e                	sd	s7,8(sp)
    8000172e:	e062                	sd	s8,0(sp)
    80001730:	0880                	addi	s0,sp,80
    80001732:	8b2a                	mv	s6,a0
    80001734:	8a2e                	mv	s4,a1
    80001736:	8c32                	mv	s8,a2
    80001738:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000173a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000173c:	6a85                	lui	s5,0x1
    8000173e:	a015                	j	80001762 <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001740:	9562                	add	a0,a0,s8
    80001742:	0004861b          	sext.w	a2,s1
    80001746:	412505b3          	sub	a1,a0,s2
    8000174a:	8552                	mv	a0,s4
    8000174c:	fffff097          	auipc	ra,0xfffff
    80001750:	5fa080e7          	jalr	1530(ra) # 80000d46 <memmove>

    len -= n;
    80001754:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001758:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000175a:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000175e:	02098263          	beqz	s3,80001782 <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    80001762:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001766:	85ca                	mv	a1,s2
    80001768:	855a                	mv	a0,s6
    8000176a:	00000097          	auipc	ra,0x0
    8000176e:	916080e7          	jalr	-1770(ra) # 80001080 <walkaddr>
    if(pa0 == 0)
    80001772:	cd01                	beqz	a0,8000178a <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    80001774:	418904b3          	sub	s1,s2,s8
    80001778:	94d6                	add	s1,s1,s5
    if(n > len)
    8000177a:	fc99f3e3          	bgeu	s3,s1,80001740 <copyin+0x28>
    8000177e:	84ce                	mv	s1,s3
    80001780:	b7c1                	j	80001740 <copyin+0x28>
  }
  return 0;
    80001782:	4501                	li	a0,0
    80001784:	a021                	j	8000178c <copyin+0x74>
    80001786:	4501                	li	a0,0
}
    80001788:	8082                	ret
      return -1;
    8000178a:	557d                	li	a0,-1
}
    8000178c:	60a6                	ld	ra,72(sp)
    8000178e:	6406                	ld	s0,64(sp)
    80001790:	74e2                	ld	s1,56(sp)
    80001792:	7942                	ld	s2,48(sp)
    80001794:	79a2                	ld	s3,40(sp)
    80001796:	7a02                	ld	s4,32(sp)
    80001798:	6ae2                	ld	s5,24(sp)
    8000179a:	6b42                	ld	s6,16(sp)
    8000179c:	6ba2                	ld	s7,8(sp)
    8000179e:	6c02                	ld	s8,0(sp)
    800017a0:	6161                	addi	sp,sp,80
    800017a2:	8082                	ret

00000000800017a4 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800017a4:	c6c5                	beqz	a3,8000184c <copyinstr+0xa8>
{
    800017a6:	715d                	addi	sp,sp,-80
    800017a8:	e486                	sd	ra,72(sp)
    800017aa:	e0a2                	sd	s0,64(sp)
    800017ac:	fc26                	sd	s1,56(sp)
    800017ae:	f84a                	sd	s2,48(sp)
    800017b0:	f44e                	sd	s3,40(sp)
    800017b2:	f052                	sd	s4,32(sp)
    800017b4:	ec56                	sd	s5,24(sp)
    800017b6:	e85a                	sd	s6,16(sp)
    800017b8:	e45e                	sd	s7,8(sp)
    800017ba:	0880                	addi	s0,sp,80
    800017bc:	8a2a                	mv	s4,a0
    800017be:	8b2e                	mv	s6,a1
    800017c0:	8bb2                	mv	s7,a2
    800017c2:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017c4:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017c6:	6985                	lui	s3,0x1
    800017c8:	a035                	j	800017f4 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017ca:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017ce:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017d0:	0017b793          	seqz	a5,a5
    800017d4:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017d8:	60a6                	ld	ra,72(sp)
    800017da:	6406                	ld	s0,64(sp)
    800017dc:	74e2                	ld	s1,56(sp)
    800017de:	7942                	ld	s2,48(sp)
    800017e0:	79a2                	ld	s3,40(sp)
    800017e2:	7a02                	ld	s4,32(sp)
    800017e4:	6ae2                	ld	s5,24(sp)
    800017e6:	6b42                	ld	s6,16(sp)
    800017e8:	6ba2                	ld	s7,8(sp)
    800017ea:	6161                	addi	sp,sp,80
    800017ec:	8082                	ret
    srcva = va0 + PGSIZE;
    800017ee:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017f2:	c8a9                	beqz	s1,80001844 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017f4:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017f8:	85ca                	mv	a1,s2
    800017fa:	8552                	mv	a0,s4
    800017fc:	00000097          	auipc	ra,0x0
    80001800:	884080e7          	jalr	-1916(ra) # 80001080 <walkaddr>
    if(pa0 == 0)
    80001804:	c131                	beqz	a0,80001848 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001806:	41790833          	sub	a6,s2,s7
    8000180a:	984e                	add	a6,a6,s3
    if(n > max)
    8000180c:	0104f363          	bgeu	s1,a6,80001812 <copyinstr+0x6e>
    80001810:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001812:	955e                	add	a0,a0,s7
    80001814:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001818:	fc080be3          	beqz	a6,800017ee <copyinstr+0x4a>
    8000181c:	985a                	add	a6,a6,s6
    8000181e:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001820:	41650633          	sub	a2,a0,s6
    80001824:	14fd                	addi	s1,s1,-1
    80001826:	9b26                	add	s6,s6,s1
    80001828:	00f60733          	add	a4,a2,a5
    8000182c:	00074703          	lbu	a4,0(a4)
    80001830:	df49                	beqz	a4,800017ca <copyinstr+0x26>
        *dst = *p;
    80001832:	00e78023          	sb	a4,0(a5)
      --max;
    80001836:	40fb04b3          	sub	s1,s6,a5
      dst++;
    8000183a:	0785                	addi	a5,a5,1
    while(n > 0){
    8000183c:	ff0796e3          	bne	a5,a6,80001828 <copyinstr+0x84>
      dst++;
    80001840:	8b42                	mv	s6,a6
    80001842:	b775                	j	800017ee <copyinstr+0x4a>
    80001844:	4781                	li	a5,0
    80001846:	b769                	j	800017d0 <copyinstr+0x2c>
      return -1;
    80001848:	557d                	li	a0,-1
    8000184a:	b779                	j	800017d8 <copyinstr+0x34>
  int got_null = 0;
    8000184c:	4781                	li	a5,0
  if(got_null){
    8000184e:	0017b793          	seqz	a5,a5
    80001852:	40f00533          	neg	a0,a5
}
    80001856:	8082                	ret

0000000080001858 <calculateDynamicPriority>:

// #ifdef MLFQ
const int num_levels = 5;
Queue mlfq[5];
int calculateDynamicPriority(struct proc *process)
{
    80001858:	1141                	addi	sp,sp,-16
    8000185a:	e422                	sd	s0,8(sp)
    8000185c:	0800                	addi	s0,sp,16
	process->niceness = 5;
    8000185e:	4795                	li	a5,5
    80001860:	1af52223          	sw	a5,420(a0)
	if (process->runTimePrev == 0)
    80001864:	19452783          	lw	a5,404(a0)
    80001868:	e791                	bnez	a5,80001874 <calculateDynamicPriority+0x1c>
	{
		if (process->sleepTimePrev == 0)
    8000186a:	18c52783          	lw	a5,396(a0)
    8000186e:	e399                	bnez	a5,80001874 <calculateDynamicPriority+0x1c>
		{
			process->niceness = process->sleepTimePrev * 10;
			process->niceness /= (process->runTimePrev + process->sleepTimePrev);
    80001870:	1a052223          	sw	zero,420(a0)
		}
	}
	int retval = 0, checker = process->sprior - process->niceness + 5;
    80001874:	19c52783          	lw	a5,412(a0)
    80001878:	2795                	addiw	a5,a5,5
    8000187a:	1a452503          	lw	a0,420(a0)
    8000187e:	40a7853b          	subw	a0,a5,a0
	}
	else
	{
		retval = checker;
	}
	return retval;
    80001882:	0005079b          	sext.w	a5,a0
    80001886:	fff7c793          	not	a5,a5
    8000188a:	97fd                	srai	a5,a5,0x3f
    8000188c:	8d7d                	and	a0,a0,a5
    8000188e:	0005071b          	sext.w	a4,a0
    80001892:	06400793          	li	a5,100
    80001896:	00e7d463          	bge	a5,a4,8000189e <calculateDynamicPriority+0x46>
    8000189a:	06400513          	li	a0,100
}
    8000189e:	2501                	sext.w	a0,a0
    800018a0:	6422                	ld	s0,8(sp)
    800018a2:	0141                	addi	sp,sp,16
    800018a4:	8082                	ret

00000000800018a6 <set_priority>:

int set_priority(int static_prior, int pid)
{
    800018a6:	7139                	addi	sp,sp,-64
    800018a8:	fc06                	sd	ra,56(sp)
    800018aa:	f822                	sd	s0,48(sp)
    800018ac:	f426                	sd	s1,40(sp)
    800018ae:	f04a                	sd	s2,32(sp)
    800018b0:	ec4e                	sd	s3,24(sp)
    800018b2:	e852                	sd	s4,16(sp)
    800018b4:	e456                	sd	s5,8(sp)
    800018b6:	0080                	addi	s0,sp,64
    800018b8:	89ae                	mv	s3,a1
	int old_prior = -1, checkIfAvailable = 0;
	if (static_prior < 0 || static_prior > 100)
    800018ba:	8aaa                	mv	s5,a0
    800018bc:	06400793          	li	a5,100
	{
		printf("Priority is not right\n");
		return -1;
	}
	struct proc *i;
	for (i = proc; i < &proc[NPROC]; i++)
    800018c0:	00010497          	auipc	s1,0x10
    800018c4:	40848493          	addi	s1,s1,1032 # 80011cc8 <proc>
    800018c8:	00018a17          	auipc	s4,0x18
    800018cc:	800a0a13          	addi	s4,s4,-2048 # 800190c8 <tickslock>
	if (static_prior < 0 || static_prior > 100)
    800018d0:	02a7e763          	bltu	a5,a0,800018fe <set_priority+0x58>
	{
		acquire(&i->lock);
    800018d4:	00848913          	addi	s2,s1,8
    800018d8:	854a                	mv	a0,s2
    800018da:	fffff097          	auipc	ra,0xfffff
    800018de:	310080e7          	jalr	784(ra) # 80000bea <acquire>
		if (i->pid == pid)
    800018e2:	5c9c                	lw	a5,56(s1)
    800018e4:	03378763          	beq	a5,s3,80001912 <set_priority+0x6c>
		{
			checkIfAvailable = 1;
			release(&i->lock);
			break;
		}
		release(&i->lock);
    800018e8:	854a                	mv	a0,s2
    800018ea:	fffff097          	auipc	ra,0xfffff
    800018ee:	3b4080e7          	jalr	948(ra) # 80000c9e <release>
	for (i = proc; i < &proc[NPROC]; i++)
    800018f2:	1d048493          	addi	s1,s1,464
    800018f6:	fd449fe3          	bne	s1,s4,800018d4 <set_priority+0x2e>
		i->dprior = calculateDynamicPriority(i);
		release(&i->lock);
	}
	else
	{
		return -1;
    800018fa:	59fd                	li	s3,-1
    800018fc:	a881                	j	8000194c <set_priority+0xa6>
		printf("Priority is not right\n");
    800018fe:	00007517          	auipc	a0,0x7
    80001902:	8da50513          	addi	a0,a0,-1830 # 800081d8 <digits+0x198>
    80001906:	fffff097          	auipc	ra,0xfffff
    8000190a:	c88080e7          	jalr	-888(ra) # 8000058e <printf>
		return -1;
    8000190e:	59fd                	li	s3,-1
    80001910:	a835                	j	8000194c <set_priority+0xa6>
			release(&i->lock);
    80001912:	854a                	mv	a0,s2
    80001914:	fffff097          	auipc	ra,0xfffff
    80001918:	38a080e7          	jalr	906(ra) # 80000c9e <release>
		acquire(&i->lock);
    8000191c:	854a                	mv	a0,s2
    8000191e:	fffff097          	auipc	ra,0xfffff
    80001922:	2cc080e7          	jalr	716(ra) # 80000bea <acquire>
		old_prior = i->sprior;
    80001926:	19c4a983          	lw	s3,412(s1)
		i->sprior = static_prior;
    8000192a:	1954ae23          	sw	s5,412(s1)
		i->niceness = 5;
    8000192e:	4795                	li	a5,5
    80001930:	1af4a223          	sw	a5,420(s1)
		i->dprior = calculateDynamicPriority(i);
    80001934:	8526                	mv	a0,s1
    80001936:	00000097          	auipc	ra,0x0
    8000193a:	f22080e7          	jalr	-222(ra) # 80001858 <calculateDynamicPriority>
    8000193e:	1aa4a023          	sw	a0,416(s1)
		release(&i->lock);
    80001942:	854a                	mv	a0,s2
    80001944:	fffff097          	auipc	ra,0xfffff
    80001948:	35a080e7          	jalr	858(ra) # 80000c9e <release>
	}
	return old_prior;
}
    8000194c:	854e                	mv	a0,s3
    8000194e:	70e2                	ld	ra,56(sp)
    80001950:	7442                	ld	s0,48(sp)
    80001952:	74a2                	ld	s1,40(sp)
    80001954:	7902                	ld	s2,32(sp)
    80001956:	69e2                	ld	s3,24(sp)
    80001958:	6a42                	ld	s4,16(sp)
    8000195a:	6aa2                	ld	s5,8(sp)
    8000195c:	6121                	addi	sp,sp,64
    8000195e:	8082                	ret

0000000080001960 <pinit>:
void pinit(void)
{
    80001960:	1141                	addi	sp,sp,-16
    80001962:	e422                	sd	s0,8(sp)
    80001964:	0800                	addi	s0,sp,16
	int i = 0;
	while (i < num_levels)
    80001966:	00010797          	auipc	a5,0x10
    8000196a:	8ea78793          	addi	a5,a5,-1814 # 80011250 <mlfq>
    8000196e:	00010717          	auipc	a4,0x10
    80001972:	35a70713          	addi	a4,a4,858 # 80011cc8 <proc>
	{
		mlfq[i].head = 0;
    80001976:	0007a023          	sw	zero,0(a5)
		mlfq[i].tail = 0;
    8000197a:	0007a223          	sw	zero,4(a5)
		mlfq[i].size = 0;
    8000197e:	2007a823          	sw	zero,528(a5)
	while (i < num_levels)
    80001982:	21878793          	addi	a5,a5,536
    80001986:	fee798e3          	bne	a5,a4,80001976 <pinit+0x16>
		i++;
	}
}
    8000198a:	6422                	ld	s0,8(sp)
    8000198c:	0141                	addi	sp,sp,16
    8000198e:	8082                	ret

0000000080001990 <push>:

void push(Queue *q, struct proc *pr)
{
    80001990:	1141                	addi	sp,sp,-16
    80001992:	e422                	sd	s0,8(sp)
    80001994:	0800                	addi	s0,sp,16
	int tail = q->tail;
    80001996:	415c                	lw	a5,4(a0)
	q->p[tail] = pr;
    80001998:	00379713          	slli	a4,a5,0x3
    8000199c:	972a                	add	a4,a4,a0
    8000199e:	e70c                	sd	a1,8(a4)
	q->tail++;
    800019a0:	2785                	addiw	a5,a5,1
    800019a2:	0007869b          	sext.w	a3,a5

	int x = NPROC + 1;
	if (q->tail == x)
    800019a6:	04100713          	li	a4,65
    800019aa:	00e68b63          	beq	a3,a4,800019c0 <push+0x30>
	q->tail++;
    800019ae:	c15c                	sw	a5,4(a0)
	{
		q->tail = 0;
	}
	q->size++;
    800019b0:	21052783          	lw	a5,528(a0)
    800019b4:	2785                	addiw	a5,a5,1
    800019b6:	20f52823          	sw	a5,528(a0)
}
    800019ba:	6422                	ld	s0,8(sp)
    800019bc:	0141                	addi	sp,sp,16
    800019be:	8082                	ret
		q->tail = 0;
    800019c0:	00052223          	sw	zero,4(a0)
    800019c4:	b7f5                	j	800019b0 <push+0x20>

00000000800019c6 <pop>:

void pop(Queue *q)
{
    800019c6:	1141                	addi	sp,sp,-16
    800019c8:	e422                	sd	s0,8(sp)
    800019ca:	0800                	addi	s0,sp,16
	q->head++;
    800019cc:	411c                	lw	a5,0(a0)
    800019ce:	2785                	addiw	a5,a5,1
    800019d0:	0007869b          	sext.w	a3,a5
	int x = NPROC + 1;
	if (q->head == x)
    800019d4:	04100713          	li	a4,65
    800019d8:	00e68b63          	beq	a3,a4,800019ee <pop+0x28>
	q->head++;
    800019dc:	c11c                	sw	a5,0(a0)
	{
		q->head = 0;
	}

	q->size--;
    800019de:	21052783          	lw	a5,528(a0)
    800019e2:	37fd                	addiw	a5,a5,-1
    800019e4:	20f52823          	sw	a5,528(a0)
}
    800019e8:	6422                	ld	s0,8(sp)
    800019ea:	0141                	addi	sp,sp,16
    800019ec:	8082                	ret
		q->head = 0;
    800019ee:	00052023          	sw	zero,0(a0)
    800019f2:	b7f5                	j	800019de <pop+0x18>

00000000800019f4 <front>:

struct proc *front(Queue *q)
{
    800019f4:	1141                	addi	sp,sp,-16
    800019f6:	e422                	sd	s0,8(sp)
    800019f8:	0800                	addi	s0,sp,16
	if (q->head != q->tail)
    800019fa:	411c                	lw	a5,0(a0)
    800019fc:	4158                	lw	a4,4(a0)
    800019fe:	00f70863          	beq	a4,a5,80001a0e <front+0x1a>
	{
		return q->p[q->head];
    80001a02:	078e                	slli	a5,a5,0x3
    80001a04:	953e                	add	a0,a0,a5
    80001a06:	6508                	ld	a0,8(a0)
	}
	else
	{
		return 0;
	}
}
    80001a08:	6422                	ld	s0,8(sp)
    80001a0a:	0141                	addi	sp,sp,16
    80001a0c:	8082                	ret
		return 0;
    80001a0e:	4501                	li	a0,0
    80001a10:	bfe5                	j	80001a08 <front+0x14>

0000000080001a12 <qerase>:

void qerase(Queue *q, int pid)
{
    80001a12:	1141                	addi	sp,sp,-16
    80001a14:	e422                	sd	s0,8(sp)
    80001a16:	0800                	addi	s0,sp,16
	int head = q->head;
    80001a18:	411c                	lw	a5,0(a0)
	int tail = q->tail;
    80001a1a:	00452883          	lw	a7,4(a0)
	int x = NPROC + 1;

	for (int curr = head; curr != tail; curr = (curr + 1) % x)
    80001a1e:	03178d63          	beq	a5,a7,80001a58 <qerase+0x46>
		if (q->p[curr]->pid != pid)
		{
			continue;
		}
		struct proc *pr = q->p[curr];
		int z = (curr + 1) % x;
    80001a22:	04100813          	li	a6,65
    80001a26:	a031                	j	80001a32 <qerase+0x20>
	for (int curr = head; curr != tail; curr = (curr + 1) % x)
    80001a28:	2785                	addiw	a5,a5,1
    80001a2a:	0307e7bb          	remw	a5,a5,a6
    80001a2e:	02f88563          	beq	a7,a5,80001a58 <qerase+0x46>
		if (q->p[curr]->pid != pid)
    80001a32:	00379693          	slli	a3,a5,0x3
    80001a36:	96aa                	add	a3,a3,a0
    80001a38:	6690                	ld	a2,8(a3)
    80001a3a:	5e18                	lw	a4,56(a2)
    80001a3c:	feb716e3          	bne	a4,a1,80001a28 <qerase+0x16>
		int z = (curr + 1) % x;
    80001a40:	0017871b          	addiw	a4,a5,1
    80001a44:	0307673b          	remw	a4,a4,a6
    80001a48:	070e                	slli	a4,a4,0x3
    80001a4a:	972a                	add	a4,a4,a0
		q->p[curr] = q->p[z];
    80001a4c:	00873303          	ld	t1,8(a4)
    80001a50:	0066b423          	sd	t1,8(a3) # 1008 <_entry-0x7fffeff8>
		q->p[z] = pr;
    80001a54:	e710                	sd	a2,8(a4)
    80001a56:	bfc9                	j	80001a28 <qerase+0x16>
	}
	if (q->tail == 0)
    80001a58:	00089d63          	bnez	a7,80001a72 <qerase+0x60>
	{
		q->tail = NPROC;
    80001a5c:	04000793          	li	a5,64
    80001a60:	c15c                	sw	a5,4(a0)
	}
	else
	{
		q->tail--;
	}
	q->size--;
    80001a62:	21052783          	lw	a5,528(a0)
    80001a66:	37fd                	addiw	a5,a5,-1
    80001a68:	20f52823          	sw	a5,528(a0)
}
    80001a6c:	6422                	ld	s0,8(sp)
    80001a6e:	0141                	addi	sp,sp,16
    80001a70:	8082                	ret
		q->tail--;
    80001a72:	38fd                	addiw	a7,a7,-1
    80001a74:	01152223          	sw	a7,4(a0)
    80001a78:	b7ed                	j	80001a62 <qerase+0x50>

0000000080001a7a <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    80001a7a:	7139                	addi	sp,sp,-64
    80001a7c:	fc06                	sd	ra,56(sp)
    80001a7e:	f822                	sd	s0,48(sp)
    80001a80:	f426                	sd	s1,40(sp)
    80001a82:	f04a                	sd	s2,32(sp)
    80001a84:	ec4e                	sd	s3,24(sp)
    80001a86:	e852                	sd	s4,16(sp)
    80001a88:	e456                	sd	s5,8(sp)
    80001a8a:	e05a                	sd	s6,0(sp)
    80001a8c:	0080                	addi	s0,sp,64
    80001a8e:	89aa                	mv	s3,a0
	struct proc *p;

	for (p = proc; p < &proc[NPROC]; p++)
    80001a90:	00010497          	auipc	s1,0x10
    80001a94:	23848493          	addi	s1,s1,568 # 80011cc8 <proc>
	{
		char *pa = kalloc();
		if (pa == 0)
			panic("kalloc");
		uint64 va = KSTACK((int)(p - proc));
    80001a98:	8b26                	mv	s6,s1
    80001a9a:	00006a97          	auipc	s5,0x6
    80001a9e:	566a8a93          	addi	s5,s5,1382 # 80008000 <etext>
    80001aa2:	04000937          	lui	s2,0x4000
    80001aa6:	197d                	addi	s2,s2,-1
    80001aa8:	0932                	slli	s2,s2,0xc
	for (p = proc; p < &proc[NPROC]; p++)
    80001aaa:	00017a17          	auipc	s4,0x17
    80001aae:	61ea0a13          	addi	s4,s4,1566 # 800190c8 <tickslock>
		char *pa = kalloc();
    80001ab2:	fffff097          	auipc	ra,0xfffff
    80001ab6:	048080e7          	jalr	72(ra) # 80000afa <kalloc>
    80001aba:	862a                	mv	a2,a0
		if (pa == 0)
    80001abc:	c131                	beqz	a0,80001b00 <proc_mapstacks+0x86>
		uint64 va = KSTACK((int)(p - proc));
    80001abe:	416485b3          	sub	a1,s1,s6
    80001ac2:	8591                	srai	a1,a1,0x4
    80001ac4:	000ab783          	ld	a5,0(s5)
    80001ac8:	02f585b3          	mul	a1,a1,a5
    80001acc:	2585                	addiw	a1,a1,1
    80001ace:	00d5959b          	slliw	a1,a1,0xd
		kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001ad2:	4719                	li	a4,6
    80001ad4:	6685                	lui	a3,0x1
    80001ad6:	40b905b3          	sub	a1,s2,a1
    80001ada:	854e                	mv	a0,s3
    80001adc:	fffff097          	auipc	ra,0xfffff
    80001ae0:	686080e7          	jalr	1670(ra) # 80001162 <kvmmap>
	for (p = proc; p < &proc[NPROC]; p++)
    80001ae4:	1d048493          	addi	s1,s1,464
    80001ae8:	fd4495e3          	bne	s1,s4,80001ab2 <proc_mapstacks+0x38>
	}
}
    80001aec:	70e2                	ld	ra,56(sp)
    80001aee:	7442                	ld	s0,48(sp)
    80001af0:	74a2                	ld	s1,40(sp)
    80001af2:	7902                	ld	s2,32(sp)
    80001af4:	69e2                	ld	s3,24(sp)
    80001af6:	6a42                	ld	s4,16(sp)
    80001af8:	6aa2                	ld	s5,8(sp)
    80001afa:	6b02                	ld	s6,0(sp)
    80001afc:	6121                	addi	sp,sp,64
    80001afe:	8082                	ret
			panic("kalloc");
    80001b00:	00006517          	auipc	a0,0x6
    80001b04:	6f050513          	addi	a0,a0,1776 # 800081f0 <digits+0x1b0>
    80001b08:	fffff097          	auipc	ra,0xfffff
    80001b0c:	a3c080e7          	jalr	-1476(ra) # 80000544 <panic>

0000000080001b10 <procinit>:

// initialize the proc table.
void procinit(void)
{
    80001b10:	7139                	addi	sp,sp,-64
    80001b12:	fc06                	sd	ra,56(sp)
    80001b14:	f822                	sd	s0,48(sp)
    80001b16:	f426                	sd	s1,40(sp)
    80001b18:	f04a                	sd	s2,32(sp)
    80001b1a:	ec4e                	sd	s3,24(sp)
    80001b1c:	e852                	sd	s4,16(sp)
    80001b1e:	e456                	sd	s5,8(sp)
    80001b20:	e05a                	sd	s6,0(sp)
    80001b22:	0080                	addi	s0,sp,64
	struct proc *p;

	initlock(&pid_lock, "nextpid");
    80001b24:	00006597          	auipc	a1,0x6
    80001b28:	6d458593          	addi	a1,a1,1748 # 800081f8 <digits+0x1b8>
    80001b2c:	0000f517          	auipc	a0,0xf
    80001b30:	2f450513          	addi	a0,a0,756 # 80010e20 <pid_lock>
    80001b34:	fffff097          	auipc	ra,0xfffff
    80001b38:	026080e7          	jalr	38(ra) # 80000b5a <initlock>
	initlock(&wait_lock, "wait_lock");
    80001b3c:	00006597          	auipc	a1,0x6
    80001b40:	6c458593          	addi	a1,a1,1732 # 80008200 <digits+0x1c0>
    80001b44:	0000f517          	auipc	a0,0xf
    80001b48:	2f450513          	addi	a0,a0,756 # 80010e38 <wait_lock>
    80001b4c:	fffff097          	auipc	ra,0xfffff
    80001b50:	00e080e7          	jalr	14(ra) # 80000b5a <initlock>
	for (p = proc; p < &proc[NPROC]; p++)
    80001b54:	00010497          	auipc	s1,0x10
    80001b58:	17448493          	addi	s1,s1,372 # 80011cc8 <proc>
	{
		initlock(&p->lock, "proc");
    80001b5c:	00006b17          	auipc	s6,0x6
    80001b60:	6b4b0b13          	addi	s6,s6,1716 # 80008210 <digits+0x1d0>
		p->state = UNUSED;
		p->kstack = KSTACK((int)(p - proc));
    80001b64:	8aa6                	mv	s5,s1
    80001b66:	00006a17          	auipc	s4,0x6
    80001b6a:	49aa0a13          	addi	s4,s4,1178 # 80008000 <etext>
    80001b6e:	04000937          	lui	s2,0x4000
    80001b72:	197d                	addi	s2,s2,-1
    80001b74:	0932                	slli	s2,s2,0xc
	for (p = proc; p < &proc[NPROC]; p++)
    80001b76:	00017997          	auipc	s3,0x17
    80001b7a:	55298993          	addi	s3,s3,1362 # 800190c8 <tickslock>
		initlock(&p->lock, "proc");
    80001b7e:	85da                	mv	a1,s6
    80001b80:	00848513          	addi	a0,s1,8
    80001b84:	fffff097          	auipc	ra,0xfffff
    80001b88:	fd6080e7          	jalr	-42(ra) # 80000b5a <initlock>
		p->state = UNUSED;
    80001b8c:	0204a023          	sw	zero,32(s1)
		p->kstack = KSTACK((int)(p - proc));
    80001b90:	415487b3          	sub	a5,s1,s5
    80001b94:	8791                	srai	a5,a5,0x4
    80001b96:	000a3703          	ld	a4,0(s4)
    80001b9a:	02e787b3          	mul	a5,a5,a4
    80001b9e:	2785                	addiw	a5,a5,1
    80001ba0:	00d7979b          	slliw	a5,a5,0xd
    80001ba4:	40f907b3          	sub	a5,s2,a5
    80001ba8:	e4bc                	sd	a5,72(s1)
	for (p = proc; p < &proc[NPROC]; p++)
    80001baa:	1d048493          	addi	s1,s1,464
    80001bae:	fd3498e3          	bne	s1,s3,80001b7e <procinit+0x6e>
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

0000000080001bc6 <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    80001bc6:	1141                	addi	sp,sp,-16
    80001bc8:	e422                	sd	s0,8(sp)
    80001bca:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001bcc:	8512                	mv	a0,tp
	int id = r_tp();
	return id;
}
    80001bce:	2501                	sext.w	a0,a0
    80001bd0:	6422                	ld	s0,8(sp)
    80001bd2:	0141                	addi	sp,sp,16
    80001bd4:	8082                	ret

0000000080001bd6 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001bd6:	1141                	addi	sp,sp,-16
    80001bd8:	e422                	sd	s0,8(sp)
    80001bda:	0800                	addi	s0,sp,16
    80001bdc:	8792                	mv	a5,tp
	int id = cpuid();
	struct cpu *c = &cpus[id];
    80001bde:	2781                	sext.w	a5,a5
    80001be0:	079e                	slli	a5,a5,0x7
	return c;
}
    80001be2:	0000f517          	auipc	a0,0xf
    80001be6:	26e50513          	addi	a0,a0,622 # 80010e50 <cpus>
    80001bea:	953e                	add	a0,a0,a5
    80001bec:	6422                	ld	s0,8(sp)
    80001bee:	0141                	addi	sp,sp,16
    80001bf0:	8082                	ret

0000000080001bf2 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001bf2:	1101                	addi	sp,sp,-32
    80001bf4:	ec06                	sd	ra,24(sp)
    80001bf6:	e822                	sd	s0,16(sp)
    80001bf8:	e426                	sd	s1,8(sp)
    80001bfa:	1000                	addi	s0,sp,32
	push_off();
    80001bfc:	fffff097          	auipc	ra,0xfffff
    80001c00:	fa2080e7          	jalr	-94(ra) # 80000b9e <push_off>
    80001c04:	8792                	mv	a5,tp
	struct cpu *c = mycpu();
	struct proc *p = c->proc;
    80001c06:	2781                	sext.w	a5,a5
    80001c08:	079e                	slli	a5,a5,0x7
    80001c0a:	0000f717          	auipc	a4,0xf
    80001c0e:	21670713          	addi	a4,a4,534 # 80010e20 <pid_lock>
    80001c12:	97ba                	add	a5,a5,a4
    80001c14:	7b84                	ld	s1,48(a5)
	pop_off();
    80001c16:	fffff097          	auipc	ra,0xfffff
    80001c1a:	028080e7          	jalr	40(ra) # 80000c3e <pop_off>
	return p;
}
    80001c1e:	8526                	mv	a0,s1
    80001c20:	60e2                	ld	ra,24(sp)
    80001c22:	6442                	ld	s0,16(sp)
    80001c24:	64a2                	ld	s1,8(sp)
    80001c26:	6105                	addi	sp,sp,32
    80001c28:	8082                	ret

0000000080001c2a <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001c2a:	1141                	addi	sp,sp,-16
    80001c2c:	e406                	sd	ra,8(sp)
    80001c2e:	e022                	sd	s0,0(sp)
    80001c30:	0800                	addi	s0,sp,16
	static int first = 1;

	// Still holding p->lock from scheduler.
	release(&myproc()->lock);
    80001c32:	00000097          	auipc	ra,0x0
    80001c36:	fc0080e7          	jalr	-64(ra) # 80001bf2 <myproc>
    80001c3a:	0521                	addi	a0,a0,8
    80001c3c:	fffff097          	auipc	ra,0xfffff
    80001c40:	062080e7          	jalr	98(ra) # 80000c9e <release>

	if (first)
    80001c44:	00007797          	auipc	a5,0x7
    80001c48:	d3c7a783          	lw	a5,-708(a5) # 80008980 <first.2469>
    80001c4c:	eb89                	bnez	a5,80001c5e <forkret+0x34>
		// be run from main().
		first = 0;
		fsinit(ROOTDEV);
	}

	usertrapret();
    80001c4e:	00001097          	auipc	ra,0x1
    80001c52:	d52080e7          	jalr	-686(ra) # 800029a0 <usertrapret>
}
    80001c56:	60a2                	ld	ra,8(sp)
    80001c58:	6402                	ld	s0,0(sp)
    80001c5a:	0141                	addi	sp,sp,16
    80001c5c:	8082                	ret
		first = 0;
    80001c5e:	00007797          	auipc	a5,0x7
    80001c62:	d207a123          	sw	zero,-734(a5) # 80008980 <first.2469>
		fsinit(ROOTDEV);
    80001c66:	4505                	li	a0,1
    80001c68:	00002097          	auipc	ra,0x2
    80001c6c:	c64080e7          	jalr	-924(ra) # 800038cc <fsinit>
    80001c70:	bff9                	j	80001c4e <forkret+0x24>

0000000080001c72 <allocpid>:
{
    80001c72:	1101                	addi	sp,sp,-32
    80001c74:	ec06                	sd	ra,24(sp)
    80001c76:	e822                	sd	s0,16(sp)
    80001c78:	e426                	sd	s1,8(sp)
    80001c7a:	e04a                	sd	s2,0(sp)
    80001c7c:	1000                	addi	s0,sp,32
	acquire(&pid_lock);
    80001c7e:	0000f917          	auipc	s2,0xf
    80001c82:	1a290913          	addi	s2,s2,418 # 80010e20 <pid_lock>
    80001c86:	854a                	mv	a0,s2
    80001c88:	fffff097          	auipc	ra,0xfffff
    80001c8c:	f62080e7          	jalr	-158(ra) # 80000bea <acquire>
	pid = nextpid;
    80001c90:	00007797          	auipc	a5,0x7
    80001c94:	cf478793          	addi	a5,a5,-780 # 80008984 <nextpid>
    80001c98:	4384                	lw	s1,0(a5)
	nextpid = nextpid + 1;
    80001c9a:	0014871b          	addiw	a4,s1,1
    80001c9e:	c398                	sw	a4,0(a5)
	release(&pid_lock);
    80001ca0:	854a                	mv	a0,s2
    80001ca2:	fffff097          	auipc	ra,0xfffff
    80001ca6:	ffc080e7          	jalr	-4(ra) # 80000c9e <release>
}
    80001caa:	8526                	mv	a0,s1
    80001cac:	60e2                	ld	ra,24(sp)
    80001cae:	6442                	ld	s0,16(sp)
    80001cb0:	64a2                	ld	s1,8(sp)
    80001cb2:	6902                	ld	s2,0(sp)
    80001cb4:	6105                	addi	sp,sp,32
    80001cb6:	8082                	ret

0000000080001cb8 <proc_pagetable>:
{
    80001cb8:	1101                	addi	sp,sp,-32
    80001cba:	ec06                	sd	ra,24(sp)
    80001cbc:	e822                	sd	s0,16(sp)
    80001cbe:	e426                	sd	s1,8(sp)
    80001cc0:	e04a                	sd	s2,0(sp)
    80001cc2:	1000                	addi	s0,sp,32
    80001cc4:	892a                	mv	s2,a0
	pagetable = uvmcreate();
    80001cc6:	fffff097          	auipc	ra,0xfffff
    80001cca:	686080e7          	jalr	1670(ra) # 8000134c <uvmcreate>
    80001cce:	84aa                	mv	s1,a0
	if (pagetable == 0)
    80001cd0:	c121                	beqz	a0,80001d10 <proc_pagetable+0x58>
	if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001cd2:	4729                	li	a4,10
    80001cd4:	00005697          	auipc	a3,0x5
    80001cd8:	32c68693          	addi	a3,a3,812 # 80007000 <_trampoline>
    80001cdc:	6605                	lui	a2,0x1
    80001cde:	040005b7          	lui	a1,0x4000
    80001ce2:	15fd                	addi	a1,a1,-1
    80001ce4:	05b2                	slli	a1,a1,0xc
    80001ce6:	fffff097          	auipc	ra,0xfffff
    80001cea:	3dc080e7          	jalr	988(ra) # 800010c2 <mappages>
    80001cee:	02054863          	bltz	a0,80001d1e <proc_pagetable+0x66>
	if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001cf2:	4719                	li	a4,6
    80001cf4:	06093683          	ld	a3,96(s2)
    80001cf8:	6605                	lui	a2,0x1
    80001cfa:	020005b7          	lui	a1,0x2000
    80001cfe:	15fd                	addi	a1,a1,-1
    80001d00:	05b6                	slli	a1,a1,0xd
    80001d02:	8526                	mv	a0,s1
    80001d04:	fffff097          	auipc	ra,0xfffff
    80001d08:	3be080e7          	jalr	958(ra) # 800010c2 <mappages>
    80001d0c:	02054163          	bltz	a0,80001d2e <proc_pagetable+0x76>
}
    80001d10:	8526                	mv	a0,s1
    80001d12:	60e2                	ld	ra,24(sp)
    80001d14:	6442                	ld	s0,16(sp)
    80001d16:	64a2                	ld	s1,8(sp)
    80001d18:	6902                	ld	s2,0(sp)
    80001d1a:	6105                	addi	sp,sp,32
    80001d1c:	8082                	ret
		uvmfree(pagetable, 0);
    80001d1e:	4581                	li	a1,0
    80001d20:	8526                	mv	a0,s1
    80001d22:	00000097          	auipc	ra,0x0
    80001d26:	82e080e7          	jalr	-2002(ra) # 80001550 <uvmfree>
		return 0;
    80001d2a:	4481                	li	s1,0
    80001d2c:	b7d5                	j	80001d10 <proc_pagetable+0x58>
		uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d2e:	4681                	li	a3,0
    80001d30:	4605                	li	a2,1
    80001d32:	040005b7          	lui	a1,0x4000
    80001d36:	15fd                	addi	a1,a1,-1
    80001d38:	05b2                	slli	a1,a1,0xc
    80001d3a:	8526                	mv	a0,s1
    80001d3c:	fffff097          	auipc	ra,0xfffff
    80001d40:	54c080e7          	jalr	1356(ra) # 80001288 <uvmunmap>
		uvmfree(pagetable, 0);
    80001d44:	4581                	li	a1,0
    80001d46:	8526                	mv	a0,s1
    80001d48:	00000097          	auipc	ra,0x0
    80001d4c:	808080e7          	jalr	-2040(ra) # 80001550 <uvmfree>
		return 0;
    80001d50:	4481                	li	s1,0
    80001d52:	bf7d                	j	80001d10 <proc_pagetable+0x58>

0000000080001d54 <proc_freepagetable>:
{
    80001d54:	1101                	addi	sp,sp,-32
    80001d56:	ec06                	sd	ra,24(sp)
    80001d58:	e822                	sd	s0,16(sp)
    80001d5a:	e426                	sd	s1,8(sp)
    80001d5c:	e04a                	sd	s2,0(sp)
    80001d5e:	1000                	addi	s0,sp,32
    80001d60:	84aa                	mv	s1,a0
    80001d62:	892e                	mv	s2,a1
	uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d64:	4681                	li	a3,0
    80001d66:	4605                	li	a2,1
    80001d68:	040005b7          	lui	a1,0x4000
    80001d6c:	15fd                	addi	a1,a1,-1
    80001d6e:	05b2                	slli	a1,a1,0xc
    80001d70:	fffff097          	auipc	ra,0xfffff
    80001d74:	518080e7          	jalr	1304(ra) # 80001288 <uvmunmap>
	uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001d78:	4681                	li	a3,0
    80001d7a:	4605                	li	a2,1
    80001d7c:	020005b7          	lui	a1,0x2000
    80001d80:	15fd                	addi	a1,a1,-1
    80001d82:	05b6                	slli	a1,a1,0xd
    80001d84:	8526                	mv	a0,s1
    80001d86:	fffff097          	auipc	ra,0xfffff
    80001d8a:	502080e7          	jalr	1282(ra) # 80001288 <uvmunmap>
	uvmfree(pagetable, sz);
    80001d8e:	85ca                	mv	a1,s2
    80001d90:	8526                	mv	a0,s1
    80001d92:	fffff097          	auipc	ra,0xfffff
    80001d96:	7be080e7          	jalr	1982(ra) # 80001550 <uvmfree>
}
    80001d9a:	60e2                	ld	ra,24(sp)
    80001d9c:	6442                	ld	s0,16(sp)
    80001d9e:	64a2                	ld	s1,8(sp)
    80001da0:	6902                	ld	s2,0(sp)
    80001da2:	6105                	addi	sp,sp,32
    80001da4:	8082                	ret

0000000080001da6 <freeproc>:
{
    80001da6:	1101                	addi	sp,sp,-32
    80001da8:	ec06                	sd	ra,24(sp)
    80001daa:	e822                	sd	s0,16(sp)
    80001dac:	e426                	sd	s1,8(sp)
    80001dae:	1000                	addi	s0,sp,32
    80001db0:	84aa                	mv	s1,a0
	if (p->trapframe)
    80001db2:	7128                	ld	a0,96(a0)
    80001db4:	c509                	beqz	a0,80001dbe <freeproc+0x18>
		kfree((void *)p->trapframe);
    80001db6:	fffff097          	auipc	ra,0xfffff
    80001dba:	c48080e7          	jalr	-952(ra) # 800009fe <kfree>
	p->trapframe = 0;
    80001dbe:	0604b023          	sd	zero,96(s1)
	if (p->pagetable)
    80001dc2:	6ca8                	ld	a0,88(s1)
    80001dc4:	c511                	beqz	a0,80001dd0 <freeproc+0x2a>
		proc_freepagetable(p->pagetable, p->sz);
    80001dc6:	68ac                	ld	a1,80(s1)
    80001dc8:	00000097          	auipc	ra,0x0
    80001dcc:	f8c080e7          	jalr	-116(ra) # 80001d54 <proc_freepagetable>
	p->pagetable = 0;
    80001dd0:	0404bc23          	sd	zero,88(s1)
	p->sz = 0;
    80001dd4:	0404b823          	sd	zero,80(s1)
	p->pid = 0;
    80001dd8:	0204ac23          	sw	zero,56(s1)
	p->parent = 0;
    80001ddc:	0404b023          	sd	zero,64(s1)
	p->name[0] = 0;
    80001de0:	16048023          	sb	zero,352(s1)
	p->chan = 0;
    80001de4:	0204b423          	sd	zero,40(s1)
	p->killed = 0;
    80001de8:	0204a823          	sw	zero,48(s1)
	p->xstate = 0;
    80001dec:	0204aa23          	sw	zero,52(s1)
	p->state = UNUSED;
    80001df0:	0204a023          	sw	zero,32(s1)
}
    80001df4:	60e2                	ld	ra,24(sp)
    80001df6:	6442                	ld	s0,16(sp)
    80001df8:	64a2                	ld	s1,8(sp)
    80001dfa:	6105                	addi	sp,sp,32
    80001dfc:	8082                	ret

0000000080001dfe <allocproc>:
{
    80001dfe:	7179                	addi	sp,sp,-48
    80001e00:	f406                	sd	ra,40(sp)
    80001e02:	f022                	sd	s0,32(sp)
    80001e04:	ec26                	sd	s1,24(sp)
    80001e06:	e84a                	sd	s2,16(sp)
    80001e08:	e44e                	sd	s3,8(sp)
    80001e0a:	1800                	addi	s0,sp,48
	for (p = proc; p < &proc[NPROC]; p++)
    80001e0c:	00010497          	auipc	s1,0x10
    80001e10:	ebc48493          	addi	s1,s1,-324 # 80011cc8 <proc>
    80001e14:	00017997          	auipc	s3,0x17
    80001e18:	2b498993          	addi	s3,s3,692 # 800190c8 <tickslock>
		acquire(&p->lock);
    80001e1c:	00848913          	addi	s2,s1,8
    80001e20:	854a                	mv	a0,s2
    80001e22:	fffff097          	auipc	ra,0xfffff
    80001e26:	dc8080e7          	jalr	-568(ra) # 80000bea <acquire>
		if (p->state == UNUSED)
    80001e2a:	509c                	lw	a5,32(s1)
    80001e2c:	cf81                	beqz	a5,80001e44 <allocproc+0x46>
			release(&p->lock);
    80001e2e:	854a                	mv	a0,s2
    80001e30:	fffff097          	auipc	ra,0xfffff
    80001e34:	e6e080e7          	jalr	-402(ra) # 80000c9e <release>
	for (p = proc; p < &proc[NPROC]; p++)
    80001e38:	1d048493          	addi	s1,s1,464
    80001e3c:	ff3490e3          	bne	s1,s3,80001e1c <allocproc+0x1e>
	return 0;
    80001e40:	4481                	li	s1,0
    80001e42:	a875                	j	80001efe <allocproc+0x100>
	p->pid = allocpid();
    80001e44:	00000097          	auipc	ra,0x0
    80001e48:	e2e080e7          	jalr	-466(ra) # 80001c72 <allocpid>
    80001e4c:	dc88                	sw	a0,56(s1)
	p->state = USED;
    80001e4e:	4785                	li	a5,1
    80001e50:	d09c                	sw	a5,32(s1)
	p->tickets = 1;
    80001e52:	16f4a823          	sw	a5,368(s1)
	p->time_spent = 0;
    80001e56:	1604aa23          	sw	zero,372(s1)
	p->time_avail = 0;
    80001e5a:	1604ac23          	sw	zero,376(s1)
	p->curr_queue = 0;
    80001e5e:	1a04a423          	sw	zero,424(s1)
	p->ticks_spent = 0;
    80001e62:	1a04a623          	sw	zero,428(s1)
	p->enter_time = ticks;
    80001e66:	00007717          	auipc	a4,0x7
    80001e6a:	d4a72703          	lw	a4,-694(a4) # 80008bb0 <ticks>
    80001e6e:	1ae4a823          	sw	a4,432(s1)
	p->time_slice = slices[p->curr_queue];
    80001e72:	1af4ac23          	sw	a5,440(s1)
	p->in_queue = 0;
    80001e76:	1a04aa23          	sw	zero,436(s1)
		p->queue[i] = 0;
    80001e7a:	1a04ae23          	sw	zero,444(s1)
    80001e7e:	1c04a023          	sw	zero,448(s1)
    80001e82:	1c04a223          	sw	zero,452(s1)
    80001e86:	1c04a423          	sw	zero,456(s1)
    80001e8a:	1c04a623          	sw	zero,460(s1)
	if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001e8e:	fffff097          	auipc	ra,0xfffff
    80001e92:	c6c080e7          	jalr	-916(ra) # 80000afa <kalloc>
    80001e96:	89aa                	mv	s3,a0
    80001e98:	f0a8                	sd	a0,96(s1)
    80001e9a:	c935                	beqz	a0,80001f0e <allocproc+0x110>
	p->pagetable = proc_pagetable(p);
    80001e9c:	8526                	mv	a0,s1
    80001e9e:	00000097          	auipc	ra,0x0
    80001ea2:	e1a080e7          	jalr	-486(ra) # 80001cb8 <proc_pagetable>
    80001ea6:	89aa                	mv	s3,a0
    80001ea8:	eca8                	sd	a0,88(s1)
	if (p->pagetable == 0)
    80001eaa:	cd35                	beqz	a0,80001f26 <allocproc+0x128>
	memset(&p->context, 0, sizeof(p->context));
    80001eac:	07000613          	li	a2,112
    80001eb0:	4581                	li	a1,0
    80001eb2:	06848513          	addi	a0,s1,104
    80001eb6:	fffff097          	auipc	ra,0xfffff
    80001eba:	e30080e7          	jalr	-464(ra) # 80000ce6 <memset>
	p->context.ra = (uint64)forkret;
    80001ebe:	00000797          	auipc	a5,0x0
    80001ec2:	d6c78793          	addi	a5,a5,-660 # 80001c2a <forkret>
    80001ec6:	f4bc                	sd	a5,104(s1)
	p->context.sp = p->kstack + PGSIZE;
    80001ec8:	64bc                	ld	a5,72(s1)
    80001eca:	6705                	lui	a4,0x1
    80001ecc:	97ba                	add	a5,a5,a4
    80001ece:	f8bc                	sd	a5,112(s1)
	p->creationTime = ticks;
    80001ed0:	00007797          	auipc	a5,0x7
    80001ed4:	ce07a783          	lw	a5,-800(a5) # 80008bb0 <ticks>
    80001ed8:	16f4ae23          	sw	a5,380(s1)
	p->sprior = 60;
    80001edc:	03c00793          	li	a5,60
    80001ee0:	18f4ae23          	sw	a5,412(s1)
	p->niceness = 5;
    80001ee4:	4795                	li	a5,5
    80001ee6:	1af4a223          	sw	a5,420(s1)
	p->runTime = 0;
    80001eea:	1804a023          	sw	zero,384(s1)
	p->endTime = 0;
    80001eee:	1804a223          	sw	zero,388(s1)
	p->runTimePrev = 0;
    80001ef2:	1804aa23          	sw	zero,404(s1)
	p->sleepTimePrev = 0;
    80001ef6:	1804a623          	sw	zero,396(s1)
	p->sleepStartTime = 0;
    80001efa:	1804a823          	sw	zero,400(s1)
}
    80001efe:	8526                	mv	a0,s1
    80001f00:	70a2                	ld	ra,40(sp)
    80001f02:	7402                	ld	s0,32(sp)
    80001f04:	64e2                	ld	s1,24(sp)
    80001f06:	6942                	ld	s2,16(sp)
    80001f08:	69a2                	ld	s3,8(sp)
    80001f0a:	6145                	addi	sp,sp,48
    80001f0c:	8082                	ret
		freeproc(p);
    80001f0e:	8526                	mv	a0,s1
    80001f10:	00000097          	auipc	ra,0x0
    80001f14:	e96080e7          	jalr	-362(ra) # 80001da6 <freeproc>
		release(&p->lock);
    80001f18:	854a                	mv	a0,s2
    80001f1a:	fffff097          	auipc	ra,0xfffff
    80001f1e:	d84080e7          	jalr	-636(ra) # 80000c9e <release>
		return 0;
    80001f22:	84ce                	mv	s1,s3
    80001f24:	bfe9                	j	80001efe <allocproc+0x100>
		freeproc(p);
    80001f26:	8526                	mv	a0,s1
    80001f28:	00000097          	auipc	ra,0x0
    80001f2c:	e7e080e7          	jalr	-386(ra) # 80001da6 <freeproc>
		release(&p->lock);
    80001f30:	854a                	mv	a0,s2
    80001f32:	fffff097          	auipc	ra,0xfffff
    80001f36:	d6c080e7          	jalr	-660(ra) # 80000c9e <release>
		return 0;
    80001f3a:	84ce                	mv	s1,s3
    80001f3c:	b7c9                	j	80001efe <allocproc+0x100>

0000000080001f3e <userinit>:
{
    80001f3e:	1101                	addi	sp,sp,-32
    80001f40:	ec06                	sd	ra,24(sp)
    80001f42:	e822                	sd	s0,16(sp)
    80001f44:	e426                	sd	s1,8(sp)
    80001f46:	1000                	addi	s0,sp,32
	p = allocproc();
    80001f48:	00000097          	auipc	ra,0x0
    80001f4c:	eb6080e7          	jalr	-330(ra) # 80001dfe <allocproc>
    80001f50:	84aa                	mv	s1,a0
	initproc = p;
    80001f52:	00007797          	auipc	a5,0x7
    80001f56:	c4a7bb23          	sd	a0,-938(a5) # 80008ba8 <initproc>
	uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001f5a:	03400613          	li	a2,52
    80001f5e:	00007597          	auipc	a1,0x7
    80001f62:	a3258593          	addi	a1,a1,-1486 # 80008990 <initcode>
    80001f66:	6d28                	ld	a0,88(a0)
    80001f68:	fffff097          	auipc	ra,0xfffff
    80001f6c:	412080e7          	jalr	1042(ra) # 8000137a <uvmfirst>
	p->sz = PGSIZE;
    80001f70:	6785                	lui	a5,0x1
    80001f72:	e8bc                	sd	a5,80(s1)
	p->trapframe->epc = 0;	   // user program counter
    80001f74:	70b8                	ld	a4,96(s1)
    80001f76:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
	p->trapframe->sp = PGSIZE; // user stack pointer
    80001f7a:	70b8                	ld	a4,96(s1)
    80001f7c:	fb1c                	sd	a5,48(a4)
	safestrcpy(p->name, "initcode", sizeof(p->name));
    80001f7e:	4641                	li	a2,16
    80001f80:	00006597          	auipc	a1,0x6
    80001f84:	29858593          	addi	a1,a1,664 # 80008218 <digits+0x1d8>
    80001f88:	16048513          	addi	a0,s1,352
    80001f8c:	fffff097          	auipc	ra,0xfffff
    80001f90:	eac080e7          	jalr	-340(ra) # 80000e38 <safestrcpy>
	p->cwd = namei("/");
    80001f94:	00006517          	auipc	a0,0x6
    80001f98:	29450513          	addi	a0,a0,660 # 80008228 <digits+0x1e8>
    80001f9c:	00002097          	auipc	ra,0x2
    80001fa0:	352080e7          	jalr	850(ra) # 800042ee <namei>
    80001fa4:	14a4bc23          	sd	a0,344(s1)
	p->state = RUNNABLE;
    80001fa8:	478d                	li	a5,3
    80001faa:	d09c                	sw	a5,32(s1)
	release(&p->lock);
    80001fac:	00848513          	addi	a0,s1,8
    80001fb0:	fffff097          	auipc	ra,0xfffff
    80001fb4:	cee080e7          	jalr	-786(ra) # 80000c9e <release>
}
    80001fb8:	60e2                	ld	ra,24(sp)
    80001fba:	6442                	ld	s0,16(sp)
    80001fbc:	64a2                	ld	s1,8(sp)
    80001fbe:	6105                	addi	sp,sp,32
    80001fc0:	8082                	ret

0000000080001fc2 <growproc>:
{
    80001fc2:	1101                	addi	sp,sp,-32
    80001fc4:	ec06                	sd	ra,24(sp)
    80001fc6:	e822                	sd	s0,16(sp)
    80001fc8:	e426                	sd	s1,8(sp)
    80001fca:	e04a                	sd	s2,0(sp)
    80001fcc:	1000                	addi	s0,sp,32
    80001fce:	892a                	mv	s2,a0
	struct proc *p = myproc();
    80001fd0:	00000097          	auipc	ra,0x0
    80001fd4:	c22080e7          	jalr	-990(ra) # 80001bf2 <myproc>
    80001fd8:	84aa                	mv	s1,a0
	sz = p->sz;
    80001fda:	692c                	ld	a1,80(a0)
	if (n > 0)
    80001fdc:	01204c63          	bgtz	s2,80001ff4 <growproc+0x32>
	else if (n < 0)
    80001fe0:	02094663          	bltz	s2,8000200c <growproc+0x4a>
	p->sz = sz;
    80001fe4:	e8ac                	sd	a1,80(s1)
	return 0;
    80001fe6:	4501                	li	a0,0
}
    80001fe8:	60e2                	ld	ra,24(sp)
    80001fea:	6442                	ld	s0,16(sp)
    80001fec:	64a2                	ld	s1,8(sp)
    80001fee:	6902                	ld	s2,0(sp)
    80001ff0:	6105                	addi	sp,sp,32
    80001ff2:	8082                	ret
		if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001ff4:	4691                	li	a3,4
    80001ff6:	00b90633          	add	a2,s2,a1
    80001ffa:	6d28                	ld	a0,88(a0)
    80001ffc:	fffff097          	auipc	ra,0xfffff
    80002000:	438080e7          	jalr	1080(ra) # 80001434 <uvmalloc>
    80002004:	85aa                	mv	a1,a0
    80002006:	fd79                	bnez	a0,80001fe4 <growproc+0x22>
			return -1;
    80002008:	557d                	li	a0,-1
    8000200a:	bff9                	j	80001fe8 <growproc+0x26>
		sz = uvmdealloc(p->pagetable, sz, sz + n);
    8000200c:	00b90633          	add	a2,s2,a1
    80002010:	6d28                	ld	a0,88(a0)
    80002012:	fffff097          	auipc	ra,0xfffff
    80002016:	3da080e7          	jalr	986(ra) # 800013ec <uvmdealloc>
    8000201a:	85aa                	mv	a1,a0
    8000201c:	b7e1                	j	80001fe4 <growproc+0x22>

000000008000201e <fork>:
{
    8000201e:	7139                	addi	sp,sp,-64
    80002020:	fc06                	sd	ra,56(sp)
    80002022:	f822                	sd	s0,48(sp)
    80002024:	f426                	sd	s1,40(sp)
    80002026:	f04a                	sd	s2,32(sp)
    80002028:	ec4e                	sd	s3,24(sp)
    8000202a:	e852                	sd	s4,16(sp)
    8000202c:	e456                	sd	s5,8(sp)
    8000202e:	0080                	addi	s0,sp,64
	struct proc *p = myproc();
    80002030:	00000097          	auipc	ra,0x0
    80002034:	bc2080e7          	jalr	-1086(ra) # 80001bf2 <myproc>
    80002038:	892a                	mv	s2,a0
	if ((np = allocproc()) == 0)
    8000203a:	00000097          	auipc	ra,0x0
    8000203e:	dc4080e7          	jalr	-572(ra) # 80001dfe <allocproc>
    80002042:	12050763          	beqz	a0,80002170 <fork+0x152>
    80002046:	89aa                	mv	s3,a0
	if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80002048:	05093603          	ld	a2,80(s2)
    8000204c:	6d2c                	ld	a1,88(a0)
    8000204e:	05893503          	ld	a0,88(s2)
    80002052:	fffff097          	auipc	ra,0xfffff
    80002056:	536080e7          	jalr	1334(ra) # 80001588 <uvmcopy>
    8000205a:	04054e63          	bltz	a0,800020b6 <fork+0x98>
	np->mask = p->mask;		  // copying mask so that we can also trace child processes
    8000205e:	00092783          	lw	a5,0(s2)
    80002062:	00f9a023          	sw	a5,0(s3)
	np->tickets = p->tickets; // child inherits same number of tickets as parent
    80002066:	17092783          	lw	a5,368(s2)
    8000206a:	16f9a823          	sw	a5,368(s3)
	np->sz = p->sz;
    8000206e:	05093783          	ld	a5,80(s2)
    80002072:	04f9b823          	sd	a5,80(s3)
	*(np->trapframe) = *(p->trapframe);
    80002076:	06093683          	ld	a3,96(s2)
    8000207a:	87b6                	mv	a5,a3
    8000207c:	0609b703          	ld	a4,96(s3)
    80002080:	12068693          	addi	a3,a3,288
    80002084:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80002088:	6788                	ld	a0,8(a5)
    8000208a:	6b8c                	ld	a1,16(a5)
    8000208c:	6f90                	ld	a2,24(a5)
    8000208e:	01073023          	sd	a6,0(a4)
    80002092:	e708                	sd	a0,8(a4)
    80002094:	eb0c                	sd	a1,16(a4)
    80002096:	ef10                	sd	a2,24(a4)
    80002098:	02078793          	addi	a5,a5,32
    8000209c:	02070713          	addi	a4,a4,32
    800020a0:	fed792e3          	bne	a5,a3,80002084 <fork+0x66>
	np->trapframe->a0 = 0;
    800020a4:	0609b783          	ld	a5,96(s3)
    800020a8:	0607b823          	sd	zero,112(a5)
    800020ac:	0d800493          	li	s1,216
	for (i = 0; i < NOFILE; i++)
    800020b0:	15800a13          	li	s4,344
    800020b4:	a805                	j	800020e4 <fork+0xc6>
		freeproc(np);
    800020b6:	854e                	mv	a0,s3
    800020b8:	00000097          	auipc	ra,0x0
    800020bc:	cee080e7          	jalr	-786(ra) # 80001da6 <freeproc>
		release(&np->lock);
    800020c0:	00898513          	addi	a0,s3,8
    800020c4:	fffff097          	auipc	ra,0xfffff
    800020c8:	bda080e7          	jalr	-1062(ra) # 80000c9e <release>
		return -1;
    800020cc:	5afd                	li	s5,-1
    800020ce:	a079                	j	8000215c <fork+0x13e>
			np->ofile[i] = filedup(p->ofile[i]);
    800020d0:	00003097          	auipc	ra,0x3
    800020d4:	8b4080e7          	jalr	-1868(ra) # 80004984 <filedup>
    800020d8:	009987b3          	add	a5,s3,s1
    800020dc:	e388                	sd	a0,0(a5)
	for (i = 0; i < NOFILE; i++)
    800020de:	04a1                	addi	s1,s1,8
    800020e0:	01448763          	beq	s1,s4,800020ee <fork+0xd0>
		if (p->ofile[i])
    800020e4:	009907b3          	add	a5,s2,s1
    800020e8:	6388                	ld	a0,0(a5)
    800020ea:	f17d                	bnez	a0,800020d0 <fork+0xb2>
    800020ec:	bfcd                	j	800020de <fork+0xc0>
	np->cwd = idup(p->cwd);
    800020ee:	15893503          	ld	a0,344(s2)
    800020f2:	00002097          	auipc	ra,0x2
    800020f6:	a18080e7          	jalr	-1512(ra) # 80003b0a <idup>
    800020fa:	14a9bc23          	sd	a0,344(s3)
	safestrcpy(np->name, p->name, sizeof(p->name));
    800020fe:	4641                	li	a2,16
    80002100:	16090593          	addi	a1,s2,352
    80002104:	16098513          	addi	a0,s3,352
    80002108:	fffff097          	auipc	ra,0xfffff
    8000210c:	d30080e7          	jalr	-720(ra) # 80000e38 <safestrcpy>
	pid = np->pid;
    80002110:	0389aa83          	lw	s5,56(s3)
	release(&np->lock);
    80002114:	00898493          	addi	s1,s3,8
    80002118:	8526                	mv	a0,s1
    8000211a:	fffff097          	auipc	ra,0xfffff
    8000211e:	b84080e7          	jalr	-1148(ra) # 80000c9e <release>
	acquire(&wait_lock);
    80002122:	0000fa17          	auipc	s4,0xf
    80002126:	d16a0a13          	addi	s4,s4,-746 # 80010e38 <wait_lock>
    8000212a:	8552                	mv	a0,s4
    8000212c:	fffff097          	auipc	ra,0xfffff
    80002130:	abe080e7          	jalr	-1346(ra) # 80000bea <acquire>
	np->parent = p;
    80002134:	0529b023          	sd	s2,64(s3)
	release(&wait_lock);
    80002138:	8552                	mv	a0,s4
    8000213a:	fffff097          	auipc	ra,0xfffff
    8000213e:	b64080e7          	jalr	-1180(ra) # 80000c9e <release>
	acquire(&np->lock);
    80002142:	8526                	mv	a0,s1
    80002144:	fffff097          	auipc	ra,0xfffff
    80002148:	aa6080e7          	jalr	-1370(ra) # 80000bea <acquire>
	np->state = RUNNABLE;
    8000214c:	478d                	li	a5,3
    8000214e:	02f9a023          	sw	a5,32(s3)
	release(&np->lock);
    80002152:	8526                	mv	a0,s1
    80002154:	fffff097          	auipc	ra,0xfffff
    80002158:	b4a080e7          	jalr	-1206(ra) # 80000c9e <release>
}
    8000215c:	8556                	mv	a0,s5
    8000215e:	70e2                	ld	ra,56(sp)
    80002160:	7442                	ld	s0,48(sp)
    80002162:	74a2                	ld	s1,40(sp)
    80002164:	7902                	ld	s2,32(sp)
    80002166:	69e2                	ld	s3,24(sp)
    80002168:	6a42                	ld	s4,16(sp)
    8000216a:	6aa2                	ld	s5,8(sp)
    8000216c:	6121                	addi	sp,sp,64
    8000216e:	8082                	ret
		return -1;
    80002170:	5afd                	li	s5,-1
    80002172:	b7ed                	j	8000215c <fork+0x13e>

0000000080002174 <upd_time>:
{
    80002174:	7179                	addi	sp,sp,-48
    80002176:	f406                	sd	ra,40(sp)
    80002178:	f022                	sd	s0,32(sp)
    8000217a:	ec26                	sd	s1,24(sp)
    8000217c:	e84a                	sd	s2,16(sp)
    8000217e:	e44e                	sd	s3,8(sp)
    80002180:	e052                	sd	s4,0(sp)
    80002182:	1800                	addi	s0,sp,48
	while (pr < &proc[NPROC])
    80002184:	00010497          	auipc	s1,0x10
    80002188:	b4c48493          	addi	s1,s1,-1204 # 80011cd0 <proc+0x8>
    8000218c:	00017a17          	auipc	s4,0x17
    80002190:	f44a0a13          	addi	s4,s4,-188 # 800190d0 <tickslock+0x8>
		if (pr->state == RUNNING)
    80002194:	4991                	li	s3,4
    80002196:	a811                	j	800021aa <upd_time+0x36>
		release(&pr->lock);
    80002198:	854a                	mv	a0,s2
    8000219a:	fffff097          	auipc	ra,0xfffff
    8000219e:	b04080e7          	jalr	-1276(ra) # 80000c9e <release>
	while (pr < &proc[NPROC])
    800021a2:	1d048493          	addi	s1,s1,464
    800021a6:	03448663          	beq	s1,s4,800021d2 <upd_time+0x5e>
		acquire(&pr->lock);
    800021aa:	8926                	mv	s2,s1
    800021ac:	8526                	mv	a0,s1
    800021ae:	fffff097          	auipc	ra,0xfffff
    800021b2:	a3c080e7          	jalr	-1476(ra) # 80000bea <acquire>
		if (pr->state == RUNNING)
    800021b6:	4c9c                	lw	a5,24(s1)
    800021b8:	ff3790e3          	bne	a5,s3,80002198 <upd_time+0x24>
			pr->runTime++;
    800021bc:	1784a783          	lw	a5,376(s1)
    800021c0:	2785                	addiw	a5,a5,1
    800021c2:	16f4ac23          	sw	a5,376(s1)
			pr->runTimePrev++;
    800021c6:	18c4a783          	lw	a5,396(s1)
    800021ca:	2785                	addiw	a5,a5,1
    800021cc:	18f4a623          	sw	a5,396(s1)
    800021d0:	b7e1                	j	80002198 <upd_time+0x24>
}
    800021d2:	70a2                	ld	ra,40(sp)
    800021d4:	7402                	ld	s0,32(sp)
    800021d6:	64e2                	ld	s1,24(sp)
    800021d8:	6942                	ld	s2,16(sp)
    800021da:	69a2                	ld	s3,8(sp)
    800021dc:	6a02                	ld	s4,0(sp)
    800021de:	6145                	addi	sp,sp,48
    800021e0:	8082                	ret

00000000800021e2 <scheduler>:
{
    800021e2:	1141                	addi	sp,sp,-16
    800021e4:	e422                	sd	s0,8(sp)
    800021e6:	0800                	addi	s0,sp,16
    800021e8:	8792                	mv	a5,tp
	c->proc = 0;
    800021ea:	2781                	sext.w	a5,a5
    800021ec:	079e                	slli	a5,a5,0x7
    800021ee:	0000f717          	auipc	a4,0xf
    800021f2:	c3270713          	addi	a4,a4,-974 # 80010e20 <pid_lock>
    800021f6:	97ba                	add	a5,a5,a4
    800021f8:	0207b823          	sd	zero,48(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800021fc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002200:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002204:	10079073          	csrw	sstatus,a5
    80002208:	bfd5                	j	800021fc <scheduler+0x1a>

000000008000220a <sched>:
{
    8000220a:	7179                	addi	sp,sp,-48
    8000220c:	f406                	sd	ra,40(sp)
    8000220e:	f022                	sd	s0,32(sp)
    80002210:	ec26                	sd	s1,24(sp)
    80002212:	e84a                	sd	s2,16(sp)
    80002214:	e44e                	sd	s3,8(sp)
    80002216:	1800                	addi	s0,sp,48
	struct proc *p = myproc();
    80002218:	00000097          	auipc	ra,0x0
    8000221c:	9da080e7          	jalr	-1574(ra) # 80001bf2 <myproc>
    80002220:	84aa                	mv	s1,a0
	if (!holding(&p->lock))
    80002222:	0521                	addi	a0,a0,8
    80002224:	fffff097          	auipc	ra,0xfffff
    80002228:	94c080e7          	jalr	-1716(ra) # 80000b70 <holding>
    8000222c:	c93d                	beqz	a0,800022a2 <sched+0x98>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000222e:	8792                	mv	a5,tp
	if (mycpu()->noff != 1)
    80002230:	2781                	sext.w	a5,a5
    80002232:	079e                	slli	a5,a5,0x7
    80002234:	0000f717          	auipc	a4,0xf
    80002238:	bec70713          	addi	a4,a4,-1044 # 80010e20 <pid_lock>
    8000223c:	97ba                	add	a5,a5,a4
    8000223e:	0a87a703          	lw	a4,168(a5)
    80002242:	4785                	li	a5,1
    80002244:	06f71763          	bne	a4,a5,800022b2 <sched+0xa8>
	if (p->state == RUNNING)
    80002248:	5098                	lw	a4,32(s1)
    8000224a:	4791                	li	a5,4
    8000224c:	06f70b63          	beq	a4,a5,800022c2 <sched+0xb8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002250:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002254:	8b89                	andi	a5,a5,2
	if (intr_get())
    80002256:	efb5                	bnez	a5,800022d2 <sched+0xc8>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002258:	8792                	mv	a5,tp
	intena = mycpu()->intena;
    8000225a:	0000f917          	auipc	s2,0xf
    8000225e:	bc690913          	addi	s2,s2,-1082 # 80010e20 <pid_lock>
    80002262:	2781                	sext.w	a5,a5
    80002264:	079e                	slli	a5,a5,0x7
    80002266:	97ca                	add	a5,a5,s2
    80002268:	0ac7a983          	lw	s3,172(a5)
    8000226c:	8792                	mv	a5,tp
	swtch(&p->context, &mycpu()->context);
    8000226e:	2781                	sext.w	a5,a5
    80002270:	079e                	slli	a5,a5,0x7
    80002272:	0000f597          	auipc	a1,0xf
    80002276:	be658593          	addi	a1,a1,-1050 # 80010e58 <cpus+0x8>
    8000227a:	95be                	add	a1,a1,a5
    8000227c:	06848513          	addi	a0,s1,104
    80002280:	00000097          	auipc	ra,0x0
    80002284:	676080e7          	jalr	1654(ra) # 800028f6 <swtch>
    80002288:	8792                	mv	a5,tp
	mycpu()->intena = intena;
    8000228a:	2781                	sext.w	a5,a5
    8000228c:	079e                	slli	a5,a5,0x7
    8000228e:	97ca                	add	a5,a5,s2
    80002290:	0b37a623          	sw	s3,172(a5)
}
    80002294:	70a2                	ld	ra,40(sp)
    80002296:	7402                	ld	s0,32(sp)
    80002298:	64e2                	ld	s1,24(sp)
    8000229a:	6942                	ld	s2,16(sp)
    8000229c:	69a2                	ld	s3,8(sp)
    8000229e:	6145                	addi	sp,sp,48
    800022a0:	8082                	ret
		panic("sched p->lock");
    800022a2:	00006517          	auipc	a0,0x6
    800022a6:	f8e50513          	addi	a0,a0,-114 # 80008230 <digits+0x1f0>
    800022aa:	ffffe097          	auipc	ra,0xffffe
    800022ae:	29a080e7          	jalr	666(ra) # 80000544 <panic>
		panic("sched locks");
    800022b2:	00006517          	auipc	a0,0x6
    800022b6:	f8e50513          	addi	a0,a0,-114 # 80008240 <digits+0x200>
    800022ba:	ffffe097          	auipc	ra,0xffffe
    800022be:	28a080e7          	jalr	650(ra) # 80000544 <panic>
		panic("sched running");
    800022c2:	00006517          	auipc	a0,0x6
    800022c6:	f8e50513          	addi	a0,a0,-114 # 80008250 <digits+0x210>
    800022ca:	ffffe097          	auipc	ra,0xffffe
    800022ce:	27a080e7          	jalr	634(ra) # 80000544 <panic>
		panic("sched interruptible");
    800022d2:	00006517          	auipc	a0,0x6
    800022d6:	f8e50513          	addi	a0,a0,-114 # 80008260 <digits+0x220>
    800022da:	ffffe097          	auipc	ra,0xffffe
    800022de:	26a080e7          	jalr	618(ra) # 80000544 <panic>

00000000800022e2 <yield>:
{
    800022e2:	1101                	addi	sp,sp,-32
    800022e4:	ec06                	sd	ra,24(sp)
    800022e6:	e822                	sd	s0,16(sp)
    800022e8:	e426                	sd	s1,8(sp)
    800022ea:	e04a                	sd	s2,0(sp)
    800022ec:	1000                	addi	s0,sp,32
	struct proc *p = myproc();
    800022ee:	00000097          	auipc	ra,0x0
    800022f2:	904080e7          	jalr	-1788(ra) # 80001bf2 <myproc>
    800022f6:	84aa                	mv	s1,a0
	acquire(&p->lock);
    800022f8:	00850913          	addi	s2,a0,8
    800022fc:	854a                	mv	a0,s2
    800022fe:	fffff097          	auipc	ra,0xfffff
    80002302:	8ec080e7          	jalr	-1812(ra) # 80000bea <acquire>
	p->state = RUNNABLE;
    80002306:	478d                	li	a5,3
    80002308:	d09c                	sw	a5,32(s1)
	sched();
    8000230a:	00000097          	auipc	ra,0x0
    8000230e:	f00080e7          	jalr	-256(ra) # 8000220a <sched>
	release(&p->lock);
    80002312:	854a                	mv	a0,s2
    80002314:	fffff097          	auipc	ra,0xfffff
    80002318:	98a080e7          	jalr	-1654(ra) # 80000c9e <release>
}
    8000231c:	60e2                	ld	ra,24(sp)
    8000231e:	6442                	ld	s0,16(sp)
    80002320:	64a2                	ld	s1,8(sp)
    80002322:	6902                	ld	s2,0(sp)
    80002324:	6105                	addi	sp,sp,32
    80002326:	8082                	ret

0000000080002328 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    80002328:	7179                	addi	sp,sp,-48
    8000232a:	f406                	sd	ra,40(sp)
    8000232c:	f022                	sd	s0,32(sp)
    8000232e:	ec26                	sd	s1,24(sp)
    80002330:	e84a                	sd	s2,16(sp)
    80002332:	e44e                	sd	s3,8(sp)
    80002334:	e052                	sd	s4,0(sp)
    80002336:	1800                	addi	s0,sp,48
    80002338:	89aa                	mv	s3,a0
    8000233a:	892e                	mv	s2,a1
	struct proc *p = myproc();
    8000233c:	00000097          	auipc	ra,0x0
    80002340:	8b6080e7          	jalr	-1866(ra) # 80001bf2 <myproc>
    80002344:	84aa                	mv	s1,a0
	// Once we hold p->lock, we can be
	// guaranteed that we won't miss any wakeup
	// (wakeup locks p->lock),
	// so it's okay to release lk.

	acquire(&p->lock); // DOC: sleeplock1
    80002346:	00850a13          	addi	s4,a0,8
    8000234a:	8552                	mv	a0,s4
    8000234c:	fffff097          	auipc	ra,0xfffff
    80002350:	89e080e7          	jalr	-1890(ra) # 80000bea <acquire>
	release(lk);
    80002354:	854a                	mv	a0,s2
    80002356:	fffff097          	auipc	ra,0xfffff
    8000235a:	948080e7          	jalr	-1720(ra) # 80000c9e <release>

	// Go to sleep.
	p->chan = chan;
    8000235e:	0334b423          	sd	s3,40(s1)
	p->state = SLEEPING;
    80002362:	4789                	li	a5,2
    80002364:	d09c                	sw	a5,32(s1)

	sched();
    80002366:	00000097          	auipc	ra,0x0
    8000236a:	ea4080e7          	jalr	-348(ra) # 8000220a <sched>

	// Tidy up.
	p->chan = 0;
    8000236e:	0204b423          	sd	zero,40(s1)

	// Reacquire original lock.
	release(&p->lock);
    80002372:	8552                	mv	a0,s4
    80002374:	fffff097          	auipc	ra,0xfffff
    80002378:	92a080e7          	jalr	-1750(ra) # 80000c9e <release>
	acquire(lk);
    8000237c:	854a                	mv	a0,s2
    8000237e:	fffff097          	auipc	ra,0xfffff
    80002382:	86c080e7          	jalr	-1940(ra) # 80000bea <acquire>
}
    80002386:	70a2                	ld	ra,40(sp)
    80002388:	7402                	ld	s0,32(sp)
    8000238a:	64e2                	ld	s1,24(sp)
    8000238c:	6942                	ld	s2,16(sp)
    8000238e:	69a2                	ld	s3,8(sp)
    80002390:	6a02                	ld	s4,0(sp)
    80002392:	6145                	addi	sp,sp,48
    80002394:	8082                	ret

0000000080002396 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    80002396:	715d                	addi	sp,sp,-80
    80002398:	e486                	sd	ra,72(sp)
    8000239a:	e0a2                	sd	s0,64(sp)
    8000239c:	fc26                	sd	s1,56(sp)
    8000239e:	f84a                	sd	s2,48(sp)
    800023a0:	f44e                	sd	s3,40(sp)
    800023a2:	f052                	sd	s4,32(sp)
    800023a4:	ec56                	sd	s5,24(sp)
    800023a6:	e85a                	sd	s6,16(sp)
    800023a8:	e45e                	sd	s7,8(sp)
    800023aa:	0880                	addi	s0,sp,80
    800023ac:	8aaa                	mv	s5,a0
	struct proc *p;

	for (p = proc; p < &proc[NPROC]; p++)
    800023ae:	00010497          	auipc	s1,0x10
    800023b2:	91a48493          	addi	s1,s1,-1766 # 80011cc8 <proc>
	{
		if (p != myproc())
		{
			acquire(&p->lock);
			if (p->state == SLEEPING && p->chan == chan)
    800023b6:	4a09                	li	s4,2
			{
				p->state = RUNNABLE;
    800023b8:	4b0d                	li	s6,3
				if (p->sleepStartTime != 0)
				{
					p->sleepTimePrev = ticks - p->sleepStartTime;
    800023ba:	00006b97          	auipc	s7,0x6
    800023be:	7f6b8b93          	addi	s7,s7,2038 # 80008bb0 <ticks>
	for (p = proc; p < &proc[NPROC]; p++)
    800023c2:	00017997          	auipc	s3,0x17
    800023c6:	d0698993          	addi	s3,s3,-762 # 800190c8 <tickslock>
    800023ca:	a811                	j	800023de <wakeup+0x48>
				int slices[5] = {1, 2, 4, 8, 16};
				p->time_slice = slices[p->curr_queue];
				push(&mlfq[p->curr_queue], p);
#endif
			}
			release(&p->lock);
    800023cc:	854a                	mv	a0,s2
    800023ce:	fffff097          	auipc	ra,0xfffff
    800023d2:	8d0080e7          	jalr	-1840(ra) # 80000c9e <release>
	for (p = proc; p < &proc[NPROC]; p++)
    800023d6:	1d048493          	addi	s1,s1,464
    800023da:	05348663          	beq	s1,s3,80002426 <wakeup+0x90>
		if (p != myproc())
    800023de:	00000097          	auipc	ra,0x0
    800023e2:	814080e7          	jalr	-2028(ra) # 80001bf2 <myproc>
    800023e6:	fea488e3          	beq	s1,a0,800023d6 <wakeup+0x40>
			acquire(&p->lock);
    800023ea:	00848913          	addi	s2,s1,8
    800023ee:	854a                	mv	a0,s2
    800023f0:	ffffe097          	auipc	ra,0xffffe
    800023f4:	7fa080e7          	jalr	2042(ra) # 80000bea <acquire>
			if (p->state == SLEEPING && p->chan == chan)
    800023f8:	509c                	lw	a5,32(s1)
    800023fa:	fd4799e3          	bne	a5,s4,800023cc <wakeup+0x36>
    800023fe:	749c                	ld	a5,40(s1)
    80002400:	fd5796e3          	bne	a5,s5,800023cc <wakeup+0x36>
				p->state = RUNNABLE;
    80002404:	0364a023          	sw	s6,32(s1)
				if (p->sleepStartTime != 0)
    80002408:	1904a783          	lw	a5,400(s1)
    8000240c:	d3e1                	beqz	a5,800023cc <wakeup+0x36>
					p->sleepTimePrev = ticks - p->sleepStartTime;
    8000240e:	000ba703          	lw	a4,0(s7)
    80002412:	40f707bb          	subw	a5,a4,a5
    80002416:	18f4a623          	sw	a5,396(s1)
					p->totalSleep += p->sleepTimePrev;
    8000241a:	1884a703          	lw	a4,392(s1)
    8000241e:	9fb9                	addw	a5,a5,a4
    80002420:	18f4a423          	sw	a5,392(s1)
    80002424:	b765                	j	800023cc <wakeup+0x36>
		}
	}
}
    80002426:	60a6                	ld	ra,72(sp)
    80002428:	6406                	ld	s0,64(sp)
    8000242a:	74e2                	ld	s1,56(sp)
    8000242c:	7942                	ld	s2,48(sp)
    8000242e:	79a2                	ld	s3,40(sp)
    80002430:	7a02                	ld	s4,32(sp)
    80002432:	6ae2                	ld	s5,24(sp)
    80002434:	6b42                	ld	s6,16(sp)
    80002436:	6ba2                	ld	s7,8(sp)
    80002438:	6161                	addi	sp,sp,80
    8000243a:	8082                	ret

000000008000243c <reparent>:
{
    8000243c:	7179                	addi	sp,sp,-48
    8000243e:	f406                	sd	ra,40(sp)
    80002440:	f022                	sd	s0,32(sp)
    80002442:	ec26                	sd	s1,24(sp)
    80002444:	e84a                	sd	s2,16(sp)
    80002446:	e44e                	sd	s3,8(sp)
    80002448:	e052                	sd	s4,0(sp)
    8000244a:	1800                	addi	s0,sp,48
    8000244c:	892a                	mv	s2,a0
	for (pp = proc; pp < &proc[NPROC]; pp++)
    8000244e:	00010497          	auipc	s1,0x10
    80002452:	87a48493          	addi	s1,s1,-1926 # 80011cc8 <proc>
			pp->parent = initproc;
    80002456:	00006a17          	auipc	s4,0x6
    8000245a:	752a0a13          	addi	s4,s4,1874 # 80008ba8 <initproc>
	for (pp = proc; pp < &proc[NPROC]; pp++)
    8000245e:	00017997          	auipc	s3,0x17
    80002462:	c6a98993          	addi	s3,s3,-918 # 800190c8 <tickslock>
    80002466:	a029                	j	80002470 <reparent+0x34>
    80002468:	1d048493          	addi	s1,s1,464
    8000246c:	01348d63          	beq	s1,s3,80002486 <reparent+0x4a>
		if (pp->parent == p)
    80002470:	60bc                	ld	a5,64(s1)
    80002472:	ff279be3          	bne	a5,s2,80002468 <reparent+0x2c>
			pp->parent = initproc;
    80002476:	000a3503          	ld	a0,0(s4)
    8000247a:	e0a8                	sd	a0,64(s1)
			wakeup(initproc);
    8000247c:	00000097          	auipc	ra,0x0
    80002480:	f1a080e7          	jalr	-230(ra) # 80002396 <wakeup>
    80002484:	b7d5                	j	80002468 <reparent+0x2c>
}
    80002486:	70a2                	ld	ra,40(sp)
    80002488:	7402                	ld	s0,32(sp)
    8000248a:	64e2                	ld	s1,24(sp)
    8000248c:	6942                	ld	s2,16(sp)
    8000248e:	69a2                	ld	s3,8(sp)
    80002490:	6a02                	ld	s4,0(sp)
    80002492:	6145                	addi	sp,sp,48
    80002494:	8082                	ret

0000000080002496 <exit>:
{
    80002496:	7179                	addi	sp,sp,-48
    80002498:	f406                	sd	ra,40(sp)
    8000249a:	f022                	sd	s0,32(sp)
    8000249c:	ec26                	sd	s1,24(sp)
    8000249e:	e84a                	sd	s2,16(sp)
    800024a0:	e44e                	sd	s3,8(sp)
    800024a2:	e052                	sd	s4,0(sp)
    800024a4:	1800                	addi	s0,sp,48
    800024a6:	8a2a                	mv	s4,a0
	struct proc *p = myproc();
    800024a8:	fffff097          	auipc	ra,0xfffff
    800024ac:	74a080e7          	jalr	1866(ra) # 80001bf2 <myproc>
    800024b0:	89aa                	mv	s3,a0
	if (p == initproc)
    800024b2:	00006797          	auipc	a5,0x6
    800024b6:	6f67b783          	ld	a5,1782(a5) # 80008ba8 <initproc>
    800024ba:	0d850493          	addi	s1,a0,216
    800024be:	15850913          	addi	s2,a0,344
    800024c2:	02a79363          	bne	a5,a0,800024e8 <exit+0x52>
		panic("init exiting");
    800024c6:	00006517          	auipc	a0,0x6
    800024ca:	db250513          	addi	a0,a0,-590 # 80008278 <digits+0x238>
    800024ce:	ffffe097          	auipc	ra,0xffffe
    800024d2:	076080e7          	jalr	118(ra) # 80000544 <panic>
			fileclose(f);
    800024d6:	00002097          	auipc	ra,0x2
    800024da:	500080e7          	jalr	1280(ra) # 800049d6 <fileclose>
			p->ofile[fd] = 0;
    800024de:	0004b023          	sd	zero,0(s1)
	for (int fd = 0; fd < NOFILE; fd++)
    800024e2:	04a1                	addi	s1,s1,8
    800024e4:	01248563          	beq	s1,s2,800024ee <exit+0x58>
		if (p->ofile[fd])
    800024e8:	6088                	ld	a0,0(s1)
    800024ea:	f575                	bnez	a0,800024d6 <exit+0x40>
    800024ec:	bfdd                	j	800024e2 <exit+0x4c>
	begin_op();
    800024ee:	00002097          	auipc	ra,0x2
    800024f2:	01c080e7          	jalr	28(ra) # 8000450a <begin_op>
	iput(p->cwd);
    800024f6:	1589b503          	ld	a0,344(s3)
    800024fa:	00002097          	auipc	ra,0x2
    800024fe:	808080e7          	jalr	-2040(ra) # 80003d02 <iput>
	end_op();
    80002502:	00002097          	auipc	ra,0x2
    80002506:	088080e7          	jalr	136(ra) # 8000458a <end_op>
	p->cwd = 0;
    8000250a:	1409bc23          	sd	zero,344(s3)
	acquire(&wait_lock);
    8000250e:	0000f497          	auipc	s1,0xf
    80002512:	92a48493          	addi	s1,s1,-1750 # 80010e38 <wait_lock>
    80002516:	8526                	mv	a0,s1
    80002518:	ffffe097          	auipc	ra,0xffffe
    8000251c:	6d2080e7          	jalr	1746(ra) # 80000bea <acquire>
	reparent(p);
    80002520:	854e                	mv	a0,s3
    80002522:	00000097          	auipc	ra,0x0
    80002526:	f1a080e7          	jalr	-230(ra) # 8000243c <reparent>
	wakeup(p->parent);
    8000252a:	0409b503          	ld	a0,64(s3)
    8000252e:	00000097          	auipc	ra,0x0
    80002532:	e68080e7          	jalr	-408(ra) # 80002396 <wakeup>
	acquire(&p->lock);
    80002536:	00898513          	addi	a0,s3,8
    8000253a:	ffffe097          	auipc	ra,0xffffe
    8000253e:	6b0080e7          	jalr	1712(ra) # 80000bea <acquire>
	p->xstate = status;
    80002542:	0349aa23          	sw	s4,52(s3)
	p->state = ZOMBIE;
    80002546:	4795                	li	a5,5
    80002548:	02f9a023          	sw	a5,32(s3)
	release(&wait_lock);
    8000254c:	8526                	mv	a0,s1
    8000254e:	ffffe097          	auipc	ra,0xffffe
    80002552:	750080e7          	jalr	1872(ra) # 80000c9e <release>
	sched();
    80002556:	00000097          	auipc	ra,0x0
    8000255a:	cb4080e7          	jalr	-844(ra) # 8000220a <sched>
	panic("zombie exit");
    8000255e:	00006517          	auipc	a0,0x6
    80002562:	d2a50513          	addi	a0,a0,-726 # 80008288 <digits+0x248>
    80002566:	ffffe097          	auipc	ra,0xffffe
    8000256a:	fde080e7          	jalr	-34(ra) # 80000544 <panic>

000000008000256e <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    8000256e:	7179                	addi	sp,sp,-48
    80002570:	f406                	sd	ra,40(sp)
    80002572:	f022                	sd	s0,32(sp)
    80002574:	ec26                	sd	s1,24(sp)
    80002576:	e84a                	sd	s2,16(sp)
    80002578:	e44e                	sd	s3,8(sp)
    8000257a:	e052                	sd	s4,0(sp)
    8000257c:	1800                	addi	s0,sp,48
    8000257e:	89aa                	mv	s3,a0
	struct proc *p;

	for (p = proc; p < &proc[NPROC]; p++)
    80002580:	0000f497          	auipc	s1,0xf
    80002584:	74848493          	addi	s1,s1,1864 # 80011cc8 <proc>
    80002588:	00017a17          	auipc	s4,0x17
    8000258c:	b40a0a13          	addi	s4,s4,-1216 # 800190c8 <tickslock>
	{
		acquire(&p->lock);
    80002590:	00848913          	addi	s2,s1,8
    80002594:	854a                	mv	a0,s2
    80002596:	ffffe097          	auipc	ra,0xffffe
    8000259a:	654080e7          	jalr	1620(ra) # 80000bea <acquire>
		if (p->pid == pid)
    8000259e:	5c9c                	lw	a5,56(s1)
    800025a0:	01378d63          	beq	a5,s3,800025ba <kill+0x4c>
#endif
			}
			release(&p->lock);
			return 0;
		}
		release(&p->lock);
    800025a4:	854a                	mv	a0,s2
    800025a6:	ffffe097          	auipc	ra,0xffffe
    800025aa:	6f8080e7          	jalr	1784(ra) # 80000c9e <release>
	for (p = proc; p < &proc[NPROC]; p++)
    800025ae:	1d048493          	addi	s1,s1,464
    800025b2:	fd449fe3          	bne	s1,s4,80002590 <kill+0x22>
	}
	return -1;
    800025b6:	557d                	li	a0,-1
    800025b8:	a829                	j	800025d2 <kill+0x64>
			p->killed = 1;
    800025ba:	4785                	li	a5,1
    800025bc:	d89c                	sw	a5,48(s1)
			if (p->state == SLEEPING)
    800025be:	5098                	lw	a4,32(s1)
    800025c0:	4789                	li	a5,2
    800025c2:	02f70063          	beq	a4,a5,800025e2 <kill+0x74>
			release(&p->lock);
    800025c6:	854a                	mv	a0,s2
    800025c8:	ffffe097          	auipc	ra,0xffffe
    800025cc:	6d6080e7          	jalr	1750(ra) # 80000c9e <release>
			return 0;
    800025d0:	4501                	li	a0,0
}
    800025d2:	70a2                	ld	ra,40(sp)
    800025d4:	7402                	ld	s0,32(sp)
    800025d6:	64e2                	ld	s1,24(sp)
    800025d8:	6942                	ld	s2,16(sp)
    800025da:	69a2                	ld	s3,8(sp)
    800025dc:	6a02                	ld	s4,0(sp)
    800025de:	6145                	addi	sp,sp,48
    800025e0:	8082                	ret
				p->sleepTimePrev = ticks - p->sleepStartTime;
    800025e2:	1904a703          	lw	a4,400(s1)
    800025e6:	00006797          	auipc	a5,0x6
    800025ea:	5ca7a783          	lw	a5,1482(a5) # 80008bb0 <ticks>
    800025ee:	9f99                	subw	a5,a5,a4
    800025f0:	18f4a623          	sw	a5,396(s1)
				p->state = RUNNABLE;
    800025f4:	478d                	li	a5,3
    800025f6:	d09c                	sw	a5,32(s1)
    800025f8:	b7f9                	j	800025c6 <kill+0x58>

00000000800025fa <setkilled>:

void setkilled(struct proc *p)
{
    800025fa:	1101                	addi	sp,sp,-32
    800025fc:	ec06                	sd	ra,24(sp)
    800025fe:	e822                	sd	s0,16(sp)
    80002600:	e426                	sd	s1,8(sp)
    80002602:	e04a                	sd	s2,0(sp)
    80002604:	1000                	addi	s0,sp,32
    80002606:	84aa                	mv	s1,a0
	acquire(&p->lock);
    80002608:	00850913          	addi	s2,a0,8
    8000260c:	854a                	mv	a0,s2
    8000260e:	ffffe097          	auipc	ra,0xffffe
    80002612:	5dc080e7          	jalr	1500(ra) # 80000bea <acquire>
	p->killed = 1;
    80002616:	4785                	li	a5,1
    80002618:	d89c                	sw	a5,48(s1)
	release(&p->lock);
    8000261a:	854a                	mv	a0,s2
    8000261c:	ffffe097          	auipc	ra,0xffffe
    80002620:	682080e7          	jalr	1666(ra) # 80000c9e <release>
}
    80002624:	60e2                	ld	ra,24(sp)
    80002626:	6442                	ld	s0,16(sp)
    80002628:	64a2                	ld	s1,8(sp)
    8000262a:	6902                	ld	s2,0(sp)
    8000262c:	6105                	addi	sp,sp,32
    8000262e:	8082                	ret

0000000080002630 <killed>:

int killed(struct proc *p)
{
    80002630:	1101                	addi	sp,sp,-32
    80002632:	ec06                	sd	ra,24(sp)
    80002634:	e822                	sd	s0,16(sp)
    80002636:	e426                	sd	s1,8(sp)
    80002638:	e04a                	sd	s2,0(sp)
    8000263a:	1000                	addi	s0,sp,32
    8000263c:	84aa                	mv	s1,a0
	int k;

	acquire(&p->lock);
    8000263e:	00850913          	addi	s2,a0,8
    80002642:	854a                	mv	a0,s2
    80002644:	ffffe097          	auipc	ra,0xffffe
    80002648:	5a6080e7          	jalr	1446(ra) # 80000bea <acquire>
	k = p->killed;
    8000264c:	5884                	lw	s1,48(s1)
	release(&p->lock);
    8000264e:	854a                	mv	a0,s2
    80002650:	ffffe097          	auipc	ra,0xffffe
    80002654:	64e080e7          	jalr	1614(ra) # 80000c9e <release>
	return k;
}
    80002658:	8526                	mv	a0,s1
    8000265a:	60e2                	ld	ra,24(sp)
    8000265c:	6442                	ld	s0,16(sp)
    8000265e:	64a2                	ld	s1,8(sp)
    80002660:	6902                	ld	s2,0(sp)
    80002662:	6105                	addi	sp,sp,32
    80002664:	8082                	ret

0000000080002666 <wait>:
{
    80002666:	711d                	addi	sp,sp,-96
    80002668:	ec86                	sd	ra,88(sp)
    8000266a:	e8a2                	sd	s0,80(sp)
    8000266c:	e4a6                	sd	s1,72(sp)
    8000266e:	e0ca                	sd	s2,64(sp)
    80002670:	fc4e                	sd	s3,56(sp)
    80002672:	f852                	sd	s4,48(sp)
    80002674:	f456                	sd	s5,40(sp)
    80002676:	f05a                	sd	s6,32(sp)
    80002678:	ec5e                	sd	s7,24(sp)
    8000267a:	e862                	sd	s8,16(sp)
    8000267c:	e466                	sd	s9,8(sp)
    8000267e:	1080                	addi	s0,sp,96
    80002680:	8baa                	mv	s7,a0
	struct proc *p = myproc();
    80002682:	fffff097          	auipc	ra,0xfffff
    80002686:	570080e7          	jalr	1392(ra) # 80001bf2 <myproc>
    8000268a:	892a                	mv	s2,a0
	acquire(&wait_lock);
    8000268c:	0000e517          	auipc	a0,0xe
    80002690:	7ac50513          	addi	a0,a0,1964 # 80010e38 <wait_lock>
    80002694:	ffffe097          	auipc	ra,0xffffe
    80002698:	556080e7          	jalr	1366(ra) # 80000bea <acquire>
		havekids = 0;
    8000269c:	4c01                	li	s8,0
				if (pp->state == ZOMBIE)
    8000269e:	4a95                	li	s5,5
		for (pp = proc; pp < &proc[NPROC]; pp++)
    800026a0:	00017997          	auipc	s3,0x17
    800026a4:	a2898993          	addi	s3,s3,-1496 # 800190c8 <tickslock>
				havekids = 1;
    800026a8:	4b05                	li	s6,1
		sleep(p, &wait_lock); // DOC: wait-sleep
    800026aa:	0000ec97          	auipc	s9,0xe
    800026ae:	78ec8c93          	addi	s9,s9,1934 # 80010e38 <wait_lock>
		havekids = 0;
    800026b2:	8762                	mv	a4,s8
		for (pp = proc; pp < &proc[NPROC]; pp++)
    800026b4:	0000f497          	auipc	s1,0xf
    800026b8:	61448493          	addi	s1,s1,1556 # 80011cc8 <proc>
    800026bc:	a0bd                	j	8000272a <wait+0xc4>
					pid = pp->pid;
    800026be:	0384a983          	lw	s3,56(s1)
					if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800026c2:	000b8e63          	beqz	s7,800026de <wait+0x78>
    800026c6:	4691                	li	a3,4
    800026c8:	03448613          	addi	a2,s1,52
    800026cc:	85de                	mv	a1,s7
    800026ce:	05893503          	ld	a0,88(s2)
    800026d2:	fffff097          	auipc	ra,0xfffff
    800026d6:	fba080e7          	jalr	-70(ra) # 8000168c <copyout>
    800026da:	02054563          	bltz	a0,80002704 <wait+0x9e>
					freeproc(pp);
    800026de:	8526                	mv	a0,s1
    800026e0:	fffff097          	auipc	ra,0xfffff
    800026e4:	6c6080e7          	jalr	1734(ra) # 80001da6 <freeproc>
					release(&pp->lock);
    800026e8:	8552                	mv	a0,s4
    800026ea:	ffffe097          	auipc	ra,0xffffe
    800026ee:	5b4080e7          	jalr	1460(ra) # 80000c9e <release>
					release(&wait_lock);
    800026f2:	0000e517          	auipc	a0,0xe
    800026f6:	74650513          	addi	a0,a0,1862 # 80010e38 <wait_lock>
    800026fa:	ffffe097          	auipc	ra,0xffffe
    800026fe:	5a4080e7          	jalr	1444(ra) # 80000c9e <release>
					return pid;
    80002702:	a885                	j	80002772 <wait+0x10c>
						release(&pp->lock);
    80002704:	8552                	mv	a0,s4
    80002706:	ffffe097          	auipc	ra,0xffffe
    8000270a:	598080e7          	jalr	1432(ra) # 80000c9e <release>
						release(&wait_lock);
    8000270e:	0000e517          	auipc	a0,0xe
    80002712:	72a50513          	addi	a0,a0,1834 # 80010e38 <wait_lock>
    80002716:	ffffe097          	auipc	ra,0xffffe
    8000271a:	588080e7          	jalr	1416(ra) # 80000c9e <release>
						return -1;
    8000271e:	59fd                	li	s3,-1
    80002720:	a889                	j	80002772 <wait+0x10c>
		for (pp = proc; pp < &proc[NPROC]; pp++)
    80002722:	1d048493          	addi	s1,s1,464
    80002726:	03348663          	beq	s1,s3,80002752 <wait+0xec>
			if (pp->parent == p)
    8000272a:	60bc                	ld	a5,64(s1)
    8000272c:	ff279be3          	bne	a5,s2,80002722 <wait+0xbc>
				acquire(&pp->lock);
    80002730:	00848a13          	addi	s4,s1,8
    80002734:	8552                	mv	a0,s4
    80002736:	ffffe097          	auipc	ra,0xffffe
    8000273a:	4b4080e7          	jalr	1204(ra) # 80000bea <acquire>
				if (pp->state == ZOMBIE)
    8000273e:	509c                	lw	a5,32(s1)
    80002740:	f7578fe3          	beq	a5,s5,800026be <wait+0x58>
				release(&pp->lock);
    80002744:	8552                	mv	a0,s4
    80002746:	ffffe097          	auipc	ra,0xffffe
    8000274a:	558080e7          	jalr	1368(ra) # 80000c9e <release>
				havekids = 1;
    8000274e:	875a                	mv	a4,s6
    80002750:	bfc9                	j	80002722 <wait+0xbc>
		if (!havekids || killed(p))
    80002752:	c719                	beqz	a4,80002760 <wait+0xfa>
    80002754:	854a                	mv	a0,s2
    80002756:	00000097          	auipc	ra,0x0
    8000275a:	eda080e7          	jalr	-294(ra) # 80002630 <killed>
    8000275e:	c905                	beqz	a0,8000278e <wait+0x128>
			release(&wait_lock);
    80002760:	0000e517          	auipc	a0,0xe
    80002764:	6d850513          	addi	a0,a0,1752 # 80010e38 <wait_lock>
    80002768:	ffffe097          	auipc	ra,0xffffe
    8000276c:	536080e7          	jalr	1334(ra) # 80000c9e <release>
			return -1;
    80002770:	59fd                	li	s3,-1
}
    80002772:	854e                	mv	a0,s3
    80002774:	60e6                	ld	ra,88(sp)
    80002776:	6446                	ld	s0,80(sp)
    80002778:	64a6                	ld	s1,72(sp)
    8000277a:	6906                	ld	s2,64(sp)
    8000277c:	79e2                	ld	s3,56(sp)
    8000277e:	7a42                	ld	s4,48(sp)
    80002780:	7aa2                	ld	s5,40(sp)
    80002782:	7b02                	ld	s6,32(sp)
    80002784:	6be2                	ld	s7,24(sp)
    80002786:	6c42                	ld	s8,16(sp)
    80002788:	6ca2                	ld	s9,8(sp)
    8000278a:	6125                	addi	sp,sp,96
    8000278c:	8082                	ret
		sleep(p, &wait_lock); // DOC: wait-sleep
    8000278e:	85e6                	mv	a1,s9
    80002790:	854a                	mv	a0,s2
    80002792:	00000097          	auipc	ra,0x0
    80002796:	b96080e7          	jalr	-1130(ra) # 80002328 <sleep>
		havekids = 0;
    8000279a:	bf21                	j	800026b2 <wait+0x4c>

000000008000279c <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000279c:	7179                	addi	sp,sp,-48
    8000279e:	f406                	sd	ra,40(sp)
    800027a0:	f022                	sd	s0,32(sp)
    800027a2:	ec26                	sd	s1,24(sp)
    800027a4:	e84a                	sd	s2,16(sp)
    800027a6:	e44e                	sd	s3,8(sp)
    800027a8:	e052                	sd	s4,0(sp)
    800027aa:	1800                	addi	s0,sp,48
    800027ac:	84aa                	mv	s1,a0
    800027ae:	892e                	mv	s2,a1
    800027b0:	89b2                	mv	s3,a2
    800027b2:	8a36                	mv	s4,a3
	struct proc *p = myproc();
    800027b4:	fffff097          	auipc	ra,0xfffff
    800027b8:	43e080e7          	jalr	1086(ra) # 80001bf2 <myproc>
	if (user_dst)
    800027bc:	c08d                	beqz	s1,800027de <either_copyout+0x42>
	{
		return copyout(p->pagetable, dst, src, len);
    800027be:	86d2                	mv	a3,s4
    800027c0:	864e                	mv	a2,s3
    800027c2:	85ca                	mv	a1,s2
    800027c4:	6d28                	ld	a0,88(a0)
    800027c6:	fffff097          	auipc	ra,0xfffff
    800027ca:	ec6080e7          	jalr	-314(ra) # 8000168c <copyout>
	else
	{
		memmove((char *)dst, src, len);
		return 0;
	}
}
    800027ce:	70a2                	ld	ra,40(sp)
    800027d0:	7402                	ld	s0,32(sp)
    800027d2:	64e2                	ld	s1,24(sp)
    800027d4:	6942                	ld	s2,16(sp)
    800027d6:	69a2                	ld	s3,8(sp)
    800027d8:	6a02                	ld	s4,0(sp)
    800027da:	6145                	addi	sp,sp,48
    800027dc:	8082                	ret
		memmove((char *)dst, src, len);
    800027de:	000a061b          	sext.w	a2,s4
    800027e2:	85ce                	mv	a1,s3
    800027e4:	854a                	mv	a0,s2
    800027e6:	ffffe097          	auipc	ra,0xffffe
    800027ea:	560080e7          	jalr	1376(ra) # 80000d46 <memmove>
		return 0;
    800027ee:	8526                	mv	a0,s1
    800027f0:	bff9                	j	800027ce <either_copyout+0x32>

00000000800027f2 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800027f2:	7179                	addi	sp,sp,-48
    800027f4:	f406                	sd	ra,40(sp)
    800027f6:	f022                	sd	s0,32(sp)
    800027f8:	ec26                	sd	s1,24(sp)
    800027fa:	e84a                	sd	s2,16(sp)
    800027fc:	e44e                	sd	s3,8(sp)
    800027fe:	e052                	sd	s4,0(sp)
    80002800:	1800                	addi	s0,sp,48
    80002802:	892a                	mv	s2,a0
    80002804:	84ae                	mv	s1,a1
    80002806:	89b2                	mv	s3,a2
    80002808:	8a36                	mv	s4,a3
	struct proc *p = myproc();
    8000280a:	fffff097          	auipc	ra,0xfffff
    8000280e:	3e8080e7          	jalr	1000(ra) # 80001bf2 <myproc>
	if (user_src)
    80002812:	c08d                	beqz	s1,80002834 <either_copyin+0x42>
	{
		return copyin(p->pagetable, dst, src, len);
    80002814:	86d2                	mv	a3,s4
    80002816:	864e                	mv	a2,s3
    80002818:	85ca                	mv	a1,s2
    8000281a:	6d28                	ld	a0,88(a0)
    8000281c:	fffff097          	auipc	ra,0xfffff
    80002820:	efc080e7          	jalr	-260(ra) # 80001718 <copyin>
	else
	{
		memmove(dst, (char *)src, len);
		return 0;
	}
}
    80002824:	70a2                	ld	ra,40(sp)
    80002826:	7402                	ld	s0,32(sp)
    80002828:	64e2                	ld	s1,24(sp)
    8000282a:	6942                	ld	s2,16(sp)
    8000282c:	69a2                	ld	s3,8(sp)
    8000282e:	6a02                	ld	s4,0(sp)
    80002830:	6145                	addi	sp,sp,48
    80002832:	8082                	ret
		memmove(dst, (char *)src, len);
    80002834:	000a061b          	sext.w	a2,s4
    80002838:	85ce                	mv	a1,s3
    8000283a:	854a                	mv	a0,s2
    8000283c:	ffffe097          	auipc	ra,0xffffe
    80002840:	50a080e7          	jalr	1290(ra) # 80000d46 <memmove>
		return 0;
    80002844:	8526                	mv	a0,s1
    80002846:	bff9                	j	80002824 <either_copyin+0x32>

0000000080002848 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002848:	715d                	addi	sp,sp,-80
    8000284a:	e486                	sd	ra,72(sp)
    8000284c:	e0a2                	sd	s0,64(sp)
    8000284e:	fc26                	sd	s1,56(sp)
    80002850:	f84a                	sd	s2,48(sp)
    80002852:	f44e                	sd	s3,40(sp)
    80002854:	f052                	sd	s4,32(sp)
    80002856:	ec56                	sd	s5,24(sp)
    80002858:	e85a                	sd	s6,16(sp)
    8000285a:	e45e                	sd	s7,8(sp)
    8000285c:	0880                	addi	s0,sp,80
		[RUNNING] "run   ",
		[ZOMBIE] "zombie"};
	struct proc *p;
	char *state;

	printf("\n");
    8000285e:	00006517          	auipc	a0,0x6
    80002862:	86a50513          	addi	a0,a0,-1942 # 800080c8 <digits+0x88>
    80002866:	ffffe097          	auipc	ra,0xffffe
    8000286a:	d28080e7          	jalr	-728(ra) # 8000058e <printf>
	for (p = proc; p < &proc[NPROC]; p++)
    8000286e:	0000f497          	auipc	s1,0xf
    80002872:	5ba48493          	addi	s1,s1,1466 # 80011e28 <proc+0x160>
    80002876:	00017917          	auipc	s2,0x17
    8000287a:	9b290913          	addi	s2,s2,-1614 # 80019228 <bcache+0x148>
	{
		if (p->state == UNUSED)
			continue;
		if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000287e:	4b15                	li	s6,5
			state = states[p->state];
		else
			state = "???";
    80002880:	00006997          	auipc	s3,0x6
    80002884:	a1898993          	addi	s3,s3,-1512 # 80008298 <digits+0x258>
		printf("%d %s %s", p->pid, state, p->name);
    80002888:	00006a97          	auipc	s5,0x6
    8000288c:	a18a8a93          	addi	s5,s5,-1512 # 800082a0 <digits+0x260>
		printf("\n");
    80002890:	00006a17          	auipc	s4,0x6
    80002894:	838a0a13          	addi	s4,s4,-1992 # 800080c8 <digits+0x88>
		if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002898:	00006b97          	auipc	s7,0x6
    8000289c:	a48b8b93          	addi	s7,s7,-1464 # 800082e0 <states.2513>
    800028a0:	a00d                	j	800028c2 <procdump+0x7a>
		printf("%d %s %s", p->pid, state, p->name);
    800028a2:	ed86a583          	lw	a1,-296(a3)
    800028a6:	8556                	mv	a0,s5
    800028a8:	ffffe097          	auipc	ra,0xffffe
    800028ac:	ce6080e7          	jalr	-794(ra) # 8000058e <printf>
		printf("\n");
    800028b0:	8552                	mv	a0,s4
    800028b2:	ffffe097          	auipc	ra,0xffffe
    800028b6:	cdc080e7          	jalr	-804(ra) # 8000058e <printf>
	for (p = proc; p < &proc[NPROC]; p++)
    800028ba:	1d048493          	addi	s1,s1,464
    800028be:	03248163          	beq	s1,s2,800028e0 <procdump+0x98>
		if (p->state == UNUSED)
    800028c2:	86a6                	mv	a3,s1
    800028c4:	ec04a783          	lw	a5,-320(s1)
    800028c8:	dbed                	beqz	a5,800028ba <procdump+0x72>
			state = "???";
    800028ca:	864e                	mv	a2,s3
		if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028cc:	fcfb6be3          	bltu	s6,a5,800028a2 <procdump+0x5a>
    800028d0:	1782                	slli	a5,a5,0x20
    800028d2:	9381                	srli	a5,a5,0x20
    800028d4:	078e                	slli	a5,a5,0x3
    800028d6:	97de                	add	a5,a5,s7
    800028d8:	6390                	ld	a2,0(a5)
    800028da:	f661                	bnez	a2,800028a2 <procdump+0x5a>
			state = "???";
    800028dc:	864e                	mv	a2,s3
    800028de:	b7d1                	j	800028a2 <procdump+0x5a>
	}
}
    800028e0:	60a6                	ld	ra,72(sp)
    800028e2:	6406                	ld	s0,64(sp)
    800028e4:	74e2                	ld	s1,56(sp)
    800028e6:	7942                	ld	s2,48(sp)
    800028e8:	79a2                	ld	s3,40(sp)
    800028ea:	7a02                	ld	s4,32(sp)
    800028ec:	6ae2                	ld	s5,24(sp)
    800028ee:	6b42                	ld	s6,16(sp)
    800028f0:	6ba2                	ld	s7,8(sp)
    800028f2:	6161                	addi	sp,sp,80
    800028f4:	8082                	ret

00000000800028f6 <swtch>:
    800028f6:	00153023          	sd	ra,0(a0)
    800028fa:	00253423          	sd	sp,8(a0)
    800028fe:	e900                	sd	s0,16(a0)
    80002900:	ed04                	sd	s1,24(a0)
    80002902:	03253023          	sd	s2,32(a0)
    80002906:	03353423          	sd	s3,40(a0)
    8000290a:	03453823          	sd	s4,48(a0)
    8000290e:	03553c23          	sd	s5,56(a0)
    80002912:	05653023          	sd	s6,64(a0)
    80002916:	05753423          	sd	s7,72(a0)
    8000291a:	05853823          	sd	s8,80(a0)
    8000291e:	05953c23          	sd	s9,88(a0)
    80002922:	07a53023          	sd	s10,96(a0)
    80002926:	07b53423          	sd	s11,104(a0)
    8000292a:	0005b083          	ld	ra,0(a1)
    8000292e:	0085b103          	ld	sp,8(a1)
    80002932:	6980                	ld	s0,16(a1)
    80002934:	6d84                	ld	s1,24(a1)
    80002936:	0205b903          	ld	s2,32(a1)
    8000293a:	0285b983          	ld	s3,40(a1)
    8000293e:	0305ba03          	ld	s4,48(a1)
    80002942:	0385ba83          	ld	s5,56(a1)
    80002946:	0405bb03          	ld	s6,64(a1)
    8000294a:	0485bb83          	ld	s7,72(a1)
    8000294e:	0505bc03          	ld	s8,80(a1)
    80002952:	0585bc83          	ld	s9,88(a1)
    80002956:	0605bd03          	ld	s10,96(a1)
    8000295a:	0685bd83          	ld	s11,104(a1)
    8000295e:	8082                	ret

0000000080002960 <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002960:	1141                	addi	sp,sp,-16
    80002962:	e406                	sd	ra,8(sp)
    80002964:	e022                	sd	s0,0(sp)
    80002966:	0800                	addi	s0,sp,16
	initlock(&tickslock, "time");
    80002968:	00006597          	auipc	a1,0x6
    8000296c:	9a858593          	addi	a1,a1,-1624 # 80008310 <states.2513+0x30>
    80002970:	00016517          	auipc	a0,0x16
    80002974:	75850513          	addi	a0,a0,1880 # 800190c8 <tickslock>
    80002978:	ffffe097          	auipc	ra,0xffffe
    8000297c:	1e2080e7          	jalr	482(ra) # 80000b5a <initlock>
}
    80002980:	60a2                	ld	ra,8(sp)
    80002982:	6402                	ld	s0,0(sp)
    80002984:	0141                	addi	sp,sp,16
    80002986:	8082                	ret

0000000080002988 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002988:	1141                	addi	sp,sp,-16
    8000298a:	e422                	sd	s0,8(sp)
    8000298c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000298e:	00003797          	auipc	a5,0x3
    80002992:	68278793          	addi	a5,a5,1666 # 80006010 <kernelvec>
    80002996:	10579073          	csrw	stvec,a5
	w_stvec((uint64)kernelvec);
}
    8000299a:	6422                	ld	s0,8(sp)
    8000299c:	0141                	addi	sp,sp,16
    8000299e:	8082                	ret

00000000800029a0 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    800029a0:	1141                	addi	sp,sp,-16
    800029a2:	e406                	sd	ra,8(sp)
    800029a4:	e022                	sd	s0,0(sp)
    800029a6:	0800                	addi	s0,sp,16
	struct proc *p = myproc();
    800029a8:	fffff097          	auipc	ra,0xfffff
    800029ac:	24a080e7          	jalr	586(ra) # 80001bf2 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029b0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800029b4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029b6:	10079073          	csrw	sstatus,a5
	// kerneltrap() to usertrap(), so turn off interrupts until
	// we're back in user space, where usertrap() is correct.
	intr_off();

	// send syscalls, interrupts, and exceptions to uservec in trampoline.S
	uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800029ba:	00004617          	auipc	a2,0x4
    800029be:	64660613          	addi	a2,a2,1606 # 80007000 <_trampoline>
    800029c2:	00004697          	auipc	a3,0x4
    800029c6:	63e68693          	addi	a3,a3,1598 # 80007000 <_trampoline>
    800029ca:	8e91                	sub	a3,a3,a2
    800029cc:	040007b7          	lui	a5,0x4000
    800029d0:	17fd                	addi	a5,a5,-1
    800029d2:	07b2                	slli	a5,a5,0xc
    800029d4:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029d6:	10569073          	csrw	stvec,a3
	w_stvec(trampoline_uservec);

	// set up trapframe values that uservec will need when
	// the process next traps into the kernel.
	p->trapframe->kernel_satp = r_satp();		  // kernel page table
    800029da:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800029dc:	180026f3          	csrr	a3,satp
    800029e0:	e314                	sd	a3,0(a4)
	p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800029e2:	7138                	ld	a4,96(a0)
    800029e4:	6534                	ld	a3,72(a0)
    800029e6:	6585                	lui	a1,0x1
    800029e8:	96ae                	add	a3,a3,a1
    800029ea:	e714                	sd	a3,8(a4)
	p->trapframe->kernel_trap = (uint64)usertrap;
    800029ec:	7138                	ld	a4,96(a0)
    800029ee:	00000697          	auipc	a3,0x0
    800029f2:	13e68693          	addi	a3,a3,318 # 80002b2c <usertrap>
    800029f6:	eb14                	sd	a3,16(a4)
	p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    800029f8:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800029fa:	8692                	mv	a3,tp
    800029fc:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029fe:	100026f3          	csrr	a3,sstatus
	// set up the registers that trampoline.S's sret will use
	// to get to user space.

	// set S Previous Privilege mode to User.
	unsigned long x = r_sstatus();
	x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002a02:	eff6f693          	andi	a3,a3,-257
	x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002a06:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a0a:	10069073          	csrw	sstatus,a3
	w_sstatus(x);

	// set S Exception Program Counter to the saved user pc.
	w_sepc(p->trapframe->epc);
    80002a0e:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a10:	6f18                	ld	a4,24(a4)
    80002a12:	14171073          	csrw	sepc,a4

	// tell trampoline.S the user page table to switch to.
	uint64 satp = MAKE_SATP(p->pagetable);
    80002a16:	6d28                	ld	a0,88(a0)
    80002a18:	8131                	srli	a0,a0,0xc

	// jump to userret in trampoline.S at the top of memory, which
	// switches to the user page table, restores user registers,
	// and switches to user mode with sret.
	uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002a1a:	00004717          	auipc	a4,0x4
    80002a1e:	68270713          	addi	a4,a4,1666 # 8000709c <userret>
    80002a22:	8f11                	sub	a4,a4,a2
    80002a24:	97ba                	add	a5,a5,a4
	((void (*)(uint64))trampoline_userret)(satp);
    80002a26:	577d                	li	a4,-1
    80002a28:	177e                	slli	a4,a4,0x3f
    80002a2a:	8d59                	or	a0,a0,a4
    80002a2c:	9782                	jalr	a5
}
    80002a2e:	60a2                	ld	ra,8(sp)
    80002a30:	6402                	ld	s0,0(sp)
    80002a32:	0141                	addi	sp,sp,16
    80002a34:	8082                	ret

0000000080002a36 <clockintr>:
	w_sepc(sepc);
	w_sstatus(sstatus);
}

void clockintr()
{
    80002a36:	1101                	addi	sp,sp,-32
    80002a38:	ec06                	sd	ra,24(sp)
    80002a3a:	e822                	sd	s0,16(sp)
    80002a3c:	e426                	sd	s1,8(sp)
    80002a3e:	e04a                	sd	s2,0(sp)
    80002a40:	1000                	addi	s0,sp,32
	acquire(&tickslock);
    80002a42:	00016917          	auipc	s2,0x16
    80002a46:	68690913          	addi	s2,s2,1670 # 800190c8 <tickslock>
    80002a4a:	854a                	mv	a0,s2
    80002a4c:	ffffe097          	auipc	ra,0xffffe
    80002a50:	19e080e7          	jalr	414(ra) # 80000bea <acquire>
	ticks++;
    80002a54:	00006497          	auipc	s1,0x6
    80002a58:	15c48493          	addi	s1,s1,348 # 80008bb0 <ticks>
    80002a5c:	409c                	lw	a5,0(s1)
    80002a5e:	2785                	addiw	a5,a5,1
    80002a60:	c09c                	sw	a5,0(s1)
	upd_time();
    80002a62:	fffff097          	auipc	ra,0xfffff
    80002a66:	712080e7          	jalr	1810(ra) # 80002174 <upd_time>
	wakeup(&ticks);
    80002a6a:	8526                	mv	a0,s1
    80002a6c:	00000097          	auipc	ra,0x0
    80002a70:	92a080e7          	jalr	-1750(ra) # 80002396 <wakeup>
	release(&tickslock);
    80002a74:	854a                	mv	a0,s2
    80002a76:	ffffe097          	auipc	ra,0xffffe
    80002a7a:	228080e7          	jalr	552(ra) # 80000c9e <release>
}
    80002a7e:	60e2                	ld	ra,24(sp)
    80002a80:	6442                	ld	s0,16(sp)
    80002a82:	64a2                	ld	s1,8(sp)
    80002a84:	6902                	ld	s2,0(sp)
    80002a86:	6105                	addi	sp,sp,32
    80002a88:	8082                	ret

0000000080002a8a <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    80002a8a:	1101                	addi	sp,sp,-32
    80002a8c:	ec06                	sd	ra,24(sp)
    80002a8e:	e822                	sd	s0,16(sp)
    80002a90:	e426                	sd	s1,8(sp)
    80002a92:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a94:	14202773          	csrr	a4,scause
	uint64 scause = r_scause();

	if ((scause & 0x8000000000000000L) &&
    80002a98:	00074d63          	bltz	a4,80002ab2 <devintr+0x28>
		if (irq)
			plic_complete(irq);

		return 1;
	}
	else if (scause == 0x8000000000000001L)
    80002a9c:	57fd                	li	a5,-1
    80002a9e:	17fe                	slli	a5,a5,0x3f
    80002aa0:	0785                	addi	a5,a5,1

		return 2;
	}
	else
	{
		return 0;
    80002aa2:	4501                	li	a0,0
	else if (scause == 0x8000000000000001L)
    80002aa4:	06f70363          	beq	a4,a5,80002b0a <devintr+0x80>
	}
}
    80002aa8:	60e2                	ld	ra,24(sp)
    80002aaa:	6442                	ld	s0,16(sp)
    80002aac:	64a2                	ld	s1,8(sp)
    80002aae:	6105                	addi	sp,sp,32
    80002ab0:	8082                	ret
		(scause & 0xff) == 9)
    80002ab2:	0ff77793          	andi	a5,a4,255
	if ((scause & 0x8000000000000000L) &&
    80002ab6:	46a5                	li	a3,9
    80002ab8:	fed792e3          	bne	a5,a3,80002a9c <devintr+0x12>
		int irq = plic_claim();
    80002abc:	00003097          	auipc	ra,0x3
    80002ac0:	65c080e7          	jalr	1628(ra) # 80006118 <plic_claim>
    80002ac4:	84aa                	mv	s1,a0
		if (irq == UART0_IRQ)
    80002ac6:	47a9                	li	a5,10
    80002ac8:	02f50763          	beq	a0,a5,80002af6 <devintr+0x6c>
		else if (irq == VIRTIO0_IRQ)
    80002acc:	4785                	li	a5,1
    80002ace:	02f50963          	beq	a0,a5,80002b00 <devintr+0x76>
		return 1;
    80002ad2:	4505                	li	a0,1
		else if (irq)
    80002ad4:	d8f1                	beqz	s1,80002aa8 <devintr+0x1e>
			printf("unexpected interrupt irq=%d\n", irq);
    80002ad6:	85a6                	mv	a1,s1
    80002ad8:	00006517          	auipc	a0,0x6
    80002adc:	84050513          	addi	a0,a0,-1984 # 80008318 <states.2513+0x38>
    80002ae0:	ffffe097          	auipc	ra,0xffffe
    80002ae4:	aae080e7          	jalr	-1362(ra) # 8000058e <printf>
			plic_complete(irq);
    80002ae8:	8526                	mv	a0,s1
    80002aea:	00003097          	auipc	ra,0x3
    80002aee:	652080e7          	jalr	1618(ra) # 8000613c <plic_complete>
		return 1;
    80002af2:	4505                	li	a0,1
    80002af4:	bf55                	j	80002aa8 <devintr+0x1e>
			uartintr();
    80002af6:	ffffe097          	auipc	ra,0xffffe
    80002afa:	eb8080e7          	jalr	-328(ra) # 800009ae <uartintr>
    80002afe:	b7ed                	j	80002ae8 <devintr+0x5e>
			virtio_disk_intr();
    80002b00:	00004097          	auipc	ra,0x4
    80002b04:	b66080e7          	jalr	-1178(ra) # 80006666 <virtio_disk_intr>
    80002b08:	b7c5                	j	80002ae8 <devintr+0x5e>
		if (cpuid() == 0)
    80002b0a:	fffff097          	auipc	ra,0xfffff
    80002b0e:	0bc080e7          	jalr	188(ra) # 80001bc6 <cpuid>
    80002b12:	c901                	beqz	a0,80002b22 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002b14:	144027f3          	csrr	a5,sip
		w_sip(r_sip() & ~2);
    80002b18:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002b1a:	14479073          	csrw	sip,a5
		return 2;
    80002b1e:	4509                	li	a0,2
    80002b20:	b761                	j	80002aa8 <devintr+0x1e>
			clockintr();
    80002b22:	00000097          	auipc	ra,0x0
    80002b26:	f14080e7          	jalr	-236(ra) # 80002a36 <clockintr>
    80002b2a:	b7ed                	j	80002b14 <devintr+0x8a>

0000000080002b2c <usertrap>:
{
    80002b2c:	1101                	addi	sp,sp,-32
    80002b2e:	ec06                	sd	ra,24(sp)
    80002b30:	e822                	sd	s0,16(sp)
    80002b32:	e426                	sd	s1,8(sp)
    80002b34:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b36:	100027f3          	csrr	a5,sstatus
	if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002b3a:	1007f793          	andi	a5,a5,256
    80002b3e:	eba9                	bnez	a5,80002b90 <usertrap+0x64>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b40:	00003797          	auipc	a5,0x3
    80002b44:	4d078793          	addi	a5,a5,1232 # 80006010 <kernelvec>
    80002b48:	10579073          	csrw	stvec,a5
	struct proc *p = myproc();
    80002b4c:	fffff097          	auipc	ra,0xfffff
    80002b50:	0a6080e7          	jalr	166(ra) # 80001bf2 <myproc>
    80002b54:	84aa                	mv	s1,a0
	p->trapframe->epc = r_sepc();
    80002b56:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b58:	14102773          	csrr	a4,sepc
    80002b5c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b5e:	14202773          	csrr	a4,scause
	if (r_scause() == 8)
    80002b62:	47a1                	li	a5,8
    80002b64:	02f70e63          	beq	a4,a5,80002ba0 <usertrap+0x74>
	else if ((which_dev = devintr()) != 0)
    80002b68:	00000097          	auipc	ra,0x0
    80002b6c:	f22080e7          	jalr	-222(ra) # 80002a8a <devintr>
    80002b70:	c135                	beqz	a0,80002bd4 <usertrap+0xa8>
	if (killed(p))
    80002b72:	8526                	mv	a0,s1
    80002b74:	00000097          	auipc	ra,0x0
    80002b78:	abc080e7          	jalr	-1348(ra) # 80002630 <killed>
    80002b7c:	e949                	bnez	a0,80002c0e <usertrap+0xe2>
	usertrapret();
    80002b7e:	00000097          	auipc	ra,0x0
    80002b82:	e22080e7          	jalr	-478(ra) # 800029a0 <usertrapret>
}
    80002b86:	60e2                	ld	ra,24(sp)
    80002b88:	6442                	ld	s0,16(sp)
    80002b8a:	64a2                	ld	s1,8(sp)
    80002b8c:	6105                	addi	sp,sp,32
    80002b8e:	8082                	ret
		panic("usertrap: not from user mode");
    80002b90:	00005517          	auipc	a0,0x5
    80002b94:	7a850513          	addi	a0,a0,1960 # 80008338 <states.2513+0x58>
    80002b98:	ffffe097          	auipc	ra,0xffffe
    80002b9c:	9ac080e7          	jalr	-1620(ra) # 80000544 <panic>
		if (killed(p))
    80002ba0:	00000097          	auipc	ra,0x0
    80002ba4:	a90080e7          	jalr	-1392(ra) # 80002630 <killed>
    80002ba8:	e105                	bnez	a0,80002bc8 <usertrap+0x9c>
		p->trapframe->epc += 4;
    80002baa:	70b8                	ld	a4,96(s1)
    80002bac:	6f1c                	ld	a5,24(a4)
    80002bae:	0791                	addi	a5,a5,4
    80002bb0:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bb2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002bb6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bba:	10079073          	csrw	sstatus,a5
		syscall();
    80002bbe:	00000097          	auipc	ra,0x0
    80002bc2:	27c080e7          	jalr	636(ra) # 80002e3a <syscall>
    80002bc6:	b775                	j	80002b72 <usertrap+0x46>
			exit(-1);
    80002bc8:	557d                	li	a0,-1
    80002bca:	00000097          	auipc	ra,0x0
    80002bce:	8cc080e7          	jalr	-1844(ra) # 80002496 <exit>
    80002bd2:	bfe1                	j	80002baa <usertrap+0x7e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bd4:	142025f3          	csrr	a1,scause
		printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002bd8:	5c90                	lw	a2,56(s1)
    80002bda:	00005517          	auipc	a0,0x5
    80002bde:	77e50513          	addi	a0,a0,1918 # 80008358 <states.2513+0x78>
    80002be2:	ffffe097          	auipc	ra,0xffffe
    80002be6:	9ac080e7          	jalr	-1620(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bea:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002bee:	14302673          	csrr	a2,stval
		printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002bf2:	00005517          	auipc	a0,0x5
    80002bf6:	79650513          	addi	a0,a0,1942 # 80008388 <states.2513+0xa8>
    80002bfa:	ffffe097          	auipc	ra,0xffffe
    80002bfe:	994080e7          	jalr	-1644(ra) # 8000058e <printf>
		setkilled(p);
    80002c02:	8526                	mv	a0,s1
    80002c04:	00000097          	auipc	ra,0x0
    80002c08:	9f6080e7          	jalr	-1546(ra) # 800025fa <setkilled>
    80002c0c:	b79d                	j	80002b72 <usertrap+0x46>
		exit(-1);
    80002c0e:	557d                	li	a0,-1
    80002c10:	00000097          	auipc	ra,0x0
    80002c14:	886080e7          	jalr	-1914(ra) # 80002496 <exit>
    80002c18:	b79d                	j	80002b7e <usertrap+0x52>

0000000080002c1a <kerneltrap>:
{
    80002c1a:	7179                	addi	sp,sp,-48
    80002c1c:	f406                	sd	ra,40(sp)
    80002c1e:	f022                	sd	s0,32(sp)
    80002c20:	ec26                	sd	s1,24(sp)
    80002c22:	e84a                	sd	s2,16(sp)
    80002c24:	e44e                	sd	s3,8(sp)
    80002c26:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c28:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c2c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c30:	142029f3          	csrr	s3,scause
	if ((sstatus & SSTATUS_SPP) == 0)
    80002c34:	1004f793          	andi	a5,s1,256
    80002c38:	c78d                	beqz	a5,80002c62 <kerneltrap+0x48>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c3e:	8b89                	andi	a5,a5,2
	if (intr_get() != 0)
    80002c40:	eb8d                	bnez	a5,80002c72 <kerneltrap+0x58>
	if ((which_dev = devintr()) == 0)
    80002c42:	00000097          	auipc	ra,0x0
    80002c46:	e48080e7          	jalr	-440(ra) # 80002a8a <devintr>
    80002c4a:	cd05                	beqz	a0,80002c82 <kerneltrap+0x68>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c4c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c50:	10049073          	csrw	sstatus,s1
}
    80002c54:	70a2                	ld	ra,40(sp)
    80002c56:	7402                	ld	s0,32(sp)
    80002c58:	64e2                	ld	s1,24(sp)
    80002c5a:	6942                	ld	s2,16(sp)
    80002c5c:	69a2                	ld	s3,8(sp)
    80002c5e:	6145                	addi	sp,sp,48
    80002c60:	8082                	ret
		panic("kerneltrap: not from supervisor mode");
    80002c62:	00005517          	auipc	a0,0x5
    80002c66:	74650513          	addi	a0,a0,1862 # 800083a8 <states.2513+0xc8>
    80002c6a:	ffffe097          	auipc	ra,0xffffe
    80002c6e:	8da080e7          	jalr	-1830(ra) # 80000544 <panic>
		panic("kerneltrap: interrupts enabled");
    80002c72:	00005517          	auipc	a0,0x5
    80002c76:	75e50513          	addi	a0,a0,1886 # 800083d0 <states.2513+0xf0>
    80002c7a:	ffffe097          	auipc	ra,0xffffe
    80002c7e:	8ca080e7          	jalr	-1846(ra) # 80000544 <panic>
		printf("scause %p\n", scause);
    80002c82:	85ce                	mv	a1,s3
    80002c84:	00005517          	auipc	a0,0x5
    80002c88:	76c50513          	addi	a0,a0,1900 # 800083f0 <states.2513+0x110>
    80002c8c:	ffffe097          	auipc	ra,0xffffe
    80002c90:	902080e7          	jalr	-1790(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c94:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c98:	14302673          	csrr	a2,stval
		printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c9c:	00005517          	auipc	a0,0x5
    80002ca0:	76450513          	addi	a0,a0,1892 # 80008400 <states.2513+0x120>
    80002ca4:	ffffe097          	auipc	ra,0xffffe
    80002ca8:	8ea080e7          	jalr	-1814(ra) # 8000058e <printf>
		panic("kerneltrap");
    80002cac:	00005517          	auipc	a0,0x5
    80002cb0:	76c50513          	addi	a0,a0,1900 # 80008418 <states.2513+0x138>
    80002cb4:	ffffe097          	auipc	ra,0xffffe
    80002cb8:	890080e7          	jalr	-1904(ra) # 80000544 <panic>

0000000080002cbc <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002cbc:	1101                	addi	sp,sp,-32
    80002cbe:	ec06                	sd	ra,24(sp)
    80002cc0:	e822                	sd	s0,16(sp)
    80002cc2:	e426                	sd	s1,8(sp)
    80002cc4:	1000                	addi	s0,sp,32
    80002cc6:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002cc8:	fffff097          	auipc	ra,0xfffff
    80002ccc:	f2a080e7          	jalr	-214(ra) # 80001bf2 <myproc>
  switch (n)
    80002cd0:	4795                	li	a5,5
    80002cd2:	0497e163          	bltu	a5,s1,80002d14 <argraw+0x58>
    80002cd6:	048a                	slli	s1,s1,0x2
    80002cd8:	00006717          	auipc	a4,0x6
    80002cdc:	88070713          	addi	a4,a4,-1920 # 80008558 <states.2513+0x278>
    80002ce0:	94ba                	add	s1,s1,a4
    80002ce2:	409c                	lw	a5,0(s1)
    80002ce4:	97ba                	add	a5,a5,a4
    80002ce6:	8782                	jr	a5
  {
  case 0:
    return p->trapframe->a0;
    80002ce8:	713c                	ld	a5,96(a0)
    80002cea:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002cec:	60e2                	ld	ra,24(sp)
    80002cee:	6442                	ld	s0,16(sp)
    80002cf0:	64a2                	ld	s1,8(sp)
    80002cf2:	6105                	addi	sp,sp,32
    80002cf4:	8082                	ret
    return p->trapframe->a1;
    80002cf6:	713c                	ld	a5,96(a0)
    80002cf8:	7fa8                	ld	a0,120(a5)
    80002cfa:	bfcd                	j	80002cec <argraw+0x30>
    return p->trapframe->a2;
    80002cfc:	713c                	ld	a5,96(a0)
    80002cfe:	63c8                	ld	a0,128(a5)
    80002d00:	b7f5                	j	80002cec <argraw+0x30>
    return p->trapframe->a3;
    80002d02:	713c                	ld	a5,96(a0)
    80002d04:	67c8                	ld	a0,136(a5)
    80002d06:	b7dd                	j	80002cec <argraw+0x30>
    return p->trapframe->a4;
    80002d08:	713c                	ld	a5,96(a0)
    80002d0a:	6bc8                	ld	a0,144(a5)
    80002d0c:	b7c5                	j	80002cec <argraw+0x30>
    return p->trapframe->a5;
    80002d0e:	713c                	ld	a5,96(a0)
    80002d10:	6fc8                	ld	a0,152(a5)
    80002d12:	bfe9                	j	80002cec <argraw+0x30>
  panic("argraw");
    80002d14:	00005517          	auipc	a0,0x5
    80002d18:	71450513          	addi	a0,a0,1812 # 80008428 <states.2513+0x148>
    80002d1c:	ffffe097          	auipc	ra,0xffffe
    80002d20:	828080e7          	jalr	-2008(ra) # 80000544 <panic>

0000000080002d24 <fetchaddr>:
{
    80002d24:	1101                	addi	sp,sp,-32
    80002d26:	ec06                	sd	ra,24(sp)
    80002d28:	e822                	sd	s0,16(sp)
    80002d2a:	e426                	sd	s1,8(sp)
    80002d2c:	e04a                	sd	s2,0(sp)
    80002d2e:	1000                	addi	s0,sp,32
    80002d30:	84aa                	mv	s1,a0
    80002d32:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d34:	fffff097          	auipc	ra,0xfffff
    80002d38:	ebe080e7          	jalr	-322(ra) # 80001bf2 <myproc>
  if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002d3c:	693c                	ld	a5,80(a0)
    80002d3e:	02f4f863          	bgeu	s1,a5,80002d6e <fetchaddr+0x4a>
    80002d42:	00848713          	addi	a4,s1,8
    80002d46:	02e7e663          	bltu	a5,a4,80002d72 <fetchaddr+0x4e>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d4a:	46a1                	li	a3,8
    80002d4c:	8626                	mv	a2,s1
    80002d4e:	85ca                	mv	a1,s2
    80002d50:	6d28                	ld	a0,88(a0)
    80002d52:	fffff097          	auipc	ra,0xfffff
    80002d56:	9c6080e7          	jalr	-1594(ra) # 80001718 <copyin>
    80002d5a:	00a03533          	snez	a0,a0
    80002d5e:	40a00533          	neg	a0,a0
}
    80002d62:	60e2                	ld	ra,24(sp)
    80002d64:	6442                	ld	s0,16(sp)
    80002d66:	64a2                	ld	s1,8(sp)
    80002d68:	6902                	ld	s2,0(sp)
    80002d6a:	6105                	addi	sp,sp,32
    80002d6c:	8082                	ret
    return -1;
    80002d6e:	557d                	li	a0,-1
    80002d70:	bfcd                	j	80002d62 <fetchaddr+0x3e>
    80002d72:	557d                	li	a0,-1
    80002d74:	b7fd                	j	80002d62 <fetchaddr+0x3e>

0000000080002d76 <fetchstr>:
{
    80002d76:	7179                	addi	sp,sp,-48
    80002d78:	f406                	sd	ra,40(sp)
    80002d7a:	f022                	sd	s0,32(sp)
    80002d7c:	ec26                	sd	s1,24(sp)
    80002d7e:	e84a                	sd	s2,16(sp)
    80002d80:	e44e                	sd	s3,8(sp)
    80002d82:	1800                	addi	s0,sp,48
    80002d84:	892a                	mv	s2,a0
    80002d86:	84ae                	mv	s1,a1
    80002d88:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002d8a:	fffff097          	auipc	ra,0xfffff
    80002d8e:	e68080e7          	jalr	-408(ra) # 80001bf2 <myproc>
  if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80002d92:	86ce                	mv	a3,s3
    80002d94:	864a                	mv	a2,s2
    80002d96:	85a6                	mv	a1,s1
    80002d98:	6d28                	ld	a0,88(a0)
    80002d9a:	fffff097          	auipc	ra,0xfffff
    80002d9e:	a0a080e7          	jalr	-1526(ra) # 800017a4 <copyinstr>
    80002da2:	00054e63          	bltz	a0,80002dbe <fetchstr+0x48>
  return strlen(buf);
    80002da6:	8526                	mv	a0,s1
    80002da8:	ffffe097          	auipc	ra,0xffffe
    80002dac:	0c2080e7          	jalr	194(ra) # 80000e6a <strlen>
}
    80002db0:	70a2                	ld	ra,40(sp)
    80002db2:	7402                	ld	s0,32(sp)
    80002db4:	64e2                	ld	s1,24(sp)
    80002db6:	6942                	ld	s2,16(sp)
    80002db8:	69a2                	ld	s3,8(sp)
    80002dba:	6145                	addi	sp,sp,48
    80002dbc:	8082                	ret
    return -1;
    80002dbe:	557d                	li	a0,-1
    80002dc0:	bfc5                	j	80002db0 <fetchstr+0x3a>

0000000080002dc2 <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80002dc2:	1101                	addi	sp,sp,-32
    80002dc4:	ec06                	sd	ra,24(sp)
    80002dc6:	e822                	sd	s0,16(sp)
    80002dc8:	e426                	sd	s1,8(sp)
    80002dca:	1000                	addi	s0,sp,32
    80002dcc:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002dce:	00000097          	auipc	ra,0x0
    80002dd2:	eee080e7          	jalr	-274(ra) # 80002cbc <argraw>
    80002dd6:	c088                	sw	a0,0(s1)
}
    80002dd8:	60e2                	ld	ra,24(sp)
    80002dda:	6442                	ld	s0,16(sp)
    80002ddc:	64a2                	ld	s1,8(sp)
    80002dde:	6105                	addi	sp,sp,32
    80002de0:	8082                	ret

0000000080002de2 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80002de2:	1101                	addi	sp,sp,-32
    80002de4:	ec06                	sd	ra,24(sp)
    80002de6:	e822                	sd	s0,16(sp)
    80002de8:	e426                	sd	s1,8(sp)
    80002dea:	1000                	addi	s0,sp,32
    80002dec:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002dee:	00000097          	auipc	ra,0x0
    80002df2:	ece080e7          	jalr	-306(ra) # 80002cbc <argraw>
    80002df6:	e088                	sd	a0,0(s1)
}
    80002df8:	60e2                	ld	ra,24(sp)
    80002dfa:	6442                	ld	s0,16(sp)
    80002dfc:	64a2                	ld	s1,8(sp)
    80002dfe:	6105                	addi	sp,sp,32
    80002e00:	8082                	ret

0000000080002e02 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80002e02:	7179                	addi	sp,sp,-48
    80002e04:	f406                	sd	ra,40(sp)
    80002e06:	f022                	sd	s0,32(sp)
    80002e08:	ec26                	sd	s1,24(sp)
    80002e0a:	e84a                	sd	s2,16(sp)
    80002e0c:	1800                	addi	s0,sp,48
    80002e0e:	84ae                	mv	s1,a1
    80002e10:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002e12:	fd840593          	addi	a1,s0,-40
    80002e16:	00000097          	auipc	ra,0x0
    80002e1a:	fcc080e7          	jalr	-52(ra) # 80002de2 <argaddr>
  return fetchstr(addr, buf, max);
    80002e1e:	864a                	mv	a2,s2
    80002e20:	85a6                	mv	a1,s1
    80002e22:	fd843503          	ld	a0,-40(s0)
    80002e26:	00000097          	auipc	ra,0x0
    80002e2a:	f50080e7          	jalr	-176(ra) # 80002d76 <fetchstr>
}
    80002e2e:	70a2                	ld	ra,40(sp)
    80002e30:	7402                	ld	s0,32(sp)
    80002e32:	64e2                	ld	s1,24(sp)
    80002e34:	6942                	ld	s2,16(sp)
    80002e36:	6145                	addi	sp,sp,48
    80002e38:	8082                	ret

0000000080002e3a <syscall>:
    {"setpriority", 2}, // CHECK
    {"settickets", 1},
};

void syscall(void)
{
    80002e3a:	711d                	addi	sp,sp,-96
    80002e3c:	ec86                	sd	ra,88(sp)
    80002e3e:	e8a2                	sd	s0,80(sp)
    80002e40:	e4a6                	sd	s1,72(sp)
    80002e42:	e0ca                	sd	s2,64(sp)
    80002e44:	fc4e                	sd	s3,56(sp)
    80002e46:	f852                	sd	s4,48(sp)
    80002e48:	f456                	sd	s5,40(sp)
    80002e4a:	f05a                	sd	s6,32(sp)
    80002e4c:	ec5e                	sd	s7,24(sp)
    80002e4e:	e862                	sd	s8,16(sp)
    80002e50:	e466                	sd	s9,8(sp)
    80002e52:	e06a                	sd	s10,0(sp)
    80002e54:	1080                	addi	s0,sp,96
  int num;
  struct proc *p = myproc();
    80002e56:	fffff097          	auipc	ra,0xfffff
    80002e5a:	d9c080e7          	jalr	-612(ra) # 80001bf2 <myproc>
    80002e5e:	8a2a                	mv	s4,a0

  num = p->trapframe->a7; // return reg
    80002e60:	7124                	ld	s1,96(a0)
    80002e62:	74dc                	ld	a5,168(s1)
    80002e64:	00078b1b          	sext.w	s6,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    80002e68:	37fd                	addiw	a5,a5,-1
    80002e6a:	4761                	li	a4,24
    80002e6c:	06f76f63          	bltu	a4,a5,80002eea <syscall+0xb0>
    80002e70:	003b1713          	slli	a4,s6,0x3
    80002e74:	00005797          	auipc	a5,0x5
    80002e78:	6fc78793          	addi	a5,a5,1788 # 80008570 <syscalls>
    80002e7c:	97ba                	add	a5,a5,a4
    80002e7e:	0007bd03          	ld	s10,0(a5)
    80002e82:	060d0463          	beqz	s10,80002eea <syscall+0xb0>
  {
    80002e86:	8c8a                	mv	s9,sp
    int numargs = syscall_info[num - 1].num;
    80002e88:	fffb0c1b          	addiw	s8,s6,-1
    80002e8c:	004c1713          	slli	a4,s8,0x4
    80002e90:	00006797          	auipc	a5,0x6
    80002e94:	b3878793          	addi	a5,a5,-1224 # 800089c8 <syscall_info>
    80002e98:	97ba                	add	a5,a5,a4
    80002e9a:	0087a983          	lw	s3,8(a5)
    int Args[numargs]; // to store value of registers acc to the number of args of the syscall
    80002e9e:	00299793          	slli	a5,s3,0x2
    80002ea2:	07bd                	addi	a5,a5,15
    80002ea4:	9bc1                	andi	a5,a5,-16
    80002ea6:	40f10133          	sub	sp,sp,a5
    80002eaa:	8b8a                	mv	s7,sp
    int j = 0;
    while (j < numargs)
    80002eac:	11305363          	blez	s3,80002fb2 <syscall+0x178>
    80002eb0:	8ade                	mv	s5,s7
    80002eb2:	895e                	mv	s2,s7
    int j = 0;
    80002eb4:	4481                	li	s1,0
    {
      Args[j] = argraw(j);
    80002eb6:	8526                	mv	a0,s1
    80002eb8:	00000097          	auipc	ra,0x0
    80002ebc:	e04080e7          	jalr	-508(ra) # 80002cbc <argraw>
    80002ec0:	00a92023          	sw	a0,0(s2)
      j++;
    80002ec4:	2485                	addiw	s1,s1,1
    while (j < numargs)
    80002ec6:	0911                	addi	s2,s2,4
    80002ec8:	fe9997e3          	bne	s3,s1,80002eb6 <syscall+0x7c>
    }

    int shift = 1 << num; // mask for num
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002ecc:	060a3483          	ld	s1,96(s4)
    80002ed0:	9d02                	jalr	s10
    80002ed2:	f8a8                	sd	a0,112(s1)
    int shift = 1 << num; // mask for num
    80002ed4:	4785                	li	a5,1
    80002ed6:	016797bb          	sllw	a5,a5,s6

    if (p->mask & shift)
    80002eda:	000a2b03          	lw	s6,0(s4)
    80002ede:	0167f7b3          	and	a5,a5,s6
    80002ee2:	2781                	sext.w	a5,a5
    80002ee4:	e7a1                	bnez	a5,80002f2c <syscall+0xf2>
    80002ee6:	8166                	mv	sp,s9
  {
    80002ee8:	a015                	j	80002f0c <syscall+0xd2>
      printf(" -> %d\n", p->trapframe->a0);
    }
  }
  else
  {
    printf("%d %s: unknown sys call %d\n",
    80002eea:	86da                	mv	a3,s6
    80002eec:	160a0613          	addi	a2,s4,352
    80002ef0:	038a2583          	lw	a1,56(s4)
    80002ef4:	00005517          	auipc	a0,0x5
    80002ef8:	55450513          	addi	a0,a0,1364 # 80008448 <states.2513+0x168>
    80002efc:	ffffd097          	auipc	ra,0xffffd
    80002f00:	692080e7          	jalr	1682(ra) # 8000058e <printf>
           p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002f04:	060a3783          	ld	a5,96(s4)
    80002f08:	577d                	li	a4,-1
    80002f0a:	fbb8                	sd	a4,112(a5)
  }
}
    80002f0c:	fa040113          	addi	sp,s0,-96
    80002f10:	60e6                	ld	ra,88(sp)
    80002f12:	6446                	ld	s0,80(sp)
    80002f14:	64a6                	ld	s1,72(sp)
    80002f16:	6906                	ld	s2,64(sp)
    80002f18:	79e2                	ld	s3,56(sp)
    80002f1a:	7a42                	ld	s4,48(sp)
    80002f1c:	7aa2                	ld	s5,40(sp)
    80002f1e:	7b02                	ld	s6,32(sp)
    80002f20:	6be2                	ld	s7,24(sp)
    80002f22:	6c42                	ld	s8,16(sp)
    80002f24:	6ca2                	ld	s9,8(sp)
    80002f26:	6d02                	ld	s10,0(sp)
    80002f28:	6125                	addi	sp,sp,96
    80002f2a:	8082                	ret
      printf("%d: syscall %s ", p->pid, syscall_info[num - 1].name);
    80002f2c:	0c12                	slli	s8,s8,0x4
    80002f2e:	00006797          	auipc	a5,0x6
    80002f32:	a9a78793          	addi	a5,a5,-1382 # 800089c8 <syscall_info>
    80002f36:	9c3e                	add	s8,s8,a5
    80002f38:	000c3603          	ld	a2,0(s8)
    80002f3c:	038a2583          	lw	a1,56(s4)
    80002f40:	00005517          	auipc	a0,0x5
    80002f44:	52850513          	addi	a0,a0,1320 # 80008468 <states.2513+0x188>
    80002f48:	ffffd097          	auipc	ra,0xffffd
    80002f4c:	646080e7          	jalr	1606(ra) # 8000058e <printf>
      printf("(");
    80002f50:	00005517          	auipc	a0,0x5
    80002f54:	52850513          	addi	a0,a0,1320 # 80008478 <states.2513+0x198>
    80002f58:	ffffd097          	auipc	ra,0xffffd
    80002f5c:	636080e7          	jalr	1590(ra) # 8000058e <printf>
      while (i < numargs)
    80002f60:	fff9879b          	addiw	a5,s3,-1
    80002f64:	1782                	slli	a5,a5,0x20
    80002f66:	9381                	srli	a5,a5,0x20
    80002f68:	0785                	addi	a5,a5,1
    80002f6a:	078a                	slli	a5,a5,0x2
    80002f6c:	9bbe                	add	s7,s7,a5
        printf("%d ", Args[i]);
    80002f6e:	00005497          	auipc	s1,0x5
    80002f72:	4c248493          	addi	s1,s1,1218 # 80008430 <states.2513+0x150>
    80002f76:	000aa583          	lw	a1,0(s5)
    80002f7a:	8526                	mv	a0,s1
    80002f7c:	ffffd097          	auipc	ra,0xffffd
    80002f80:	612080e7          	jalr	1554(ra) # 8000058e <printf>
      while (i < numargs)
    80002f84:	0a91                	addi	s5,s5,4
    80002f86:	ff7a98e3          	bne	s5,s7,80002f76 <syscall+0x13c>
      printf(")");
    80002f8a:	00005517          	auipc	a0,0x5
    80002f8e:	4ae50513          	addi	a0,a0,1198 # 80008438 <states.2513+0x158>
    80002f92:	ffffd097          	auipc	ra,0xffffd
    80002f96:	5fc080e7          	jalr	1532(ra) # 8000058e <printf>
      printf(" -> %d\n", p->trapframe->a0);
    80002f9a:	060a3783          	ld	a5,96(s4)
    80002f9e:	7bac                	ld	a1,112(a5)
    80002fa0:	00005517          	auipc	a0,0x5
    80002fa4:	4a050513          	addi	a0,a0,1184 # 80008440 <states.2513+0x160>
    80002fa8:	ffffd097          	auipc	ra,0xffffd
    80002fac:	5e6080e7          	jalr	1510(ra) # 8000058e <printf>
    80002fb0:	bf1d                	j	80002ee6 <syscall+0xac>
    p->trapframe->a0 = syscalls[num]();
    80002fb2:	9d02                	jalr	s10
    80002fb4:	f8a8                	sd	a0,112(s1)
    int shift = 1 << num; // mask for num
    80002fb6:	4785                	li	a5,1
    80002fb8:	016797bb          	sllw	a5,a5,s6
    if (p->mask & shift)
    80002fbc:	000a2703          	lw	a4,0(s4)
    80002fc0:	8ff9                	and	a5,a5,a4
    80002fc2:	2781                	sext.w	a5,a5
    80002fc4:	d38d                	beqz	a5,80002ee6 <syscall+0xac>
      printf("%d: syscall %s ", p->pid, syscall_info[num - 1].name);
    80002fc6:	0c12                	slli	s8,s8,0x4
    80002fc8:	00006797          	auipc	a5,0x6
    80002fcc:	a0078793          	addi	a5,a5,-1536 # 800089c8 <syscall_info>
    80002fd0:	97e2                	add	a5,a5,s8
    80002fd2:	6390                	ld	a2,0(a5)
    80002fd4:	038a2583          	lw	a1,56(s4)
    80002fd8:	00005517          	auipc	a0,0x5
    80002fdc:	49050513          	addi	a0,a0,1168 # 80008468 <states.2513+0x188>
    80002fe0:	ffffd097          	auipc	ra,0xffffd
    80002fe4:	5ae080e7          	jalr	1454(ra) # 8000058e <printf>
      printf("(");
    80002fe8:	00005517          	auipc	a0,0x5
    80002fec:	49050513          	addi	a0,a0,1168 # 80008478 <states.2513+0x198>
    80002ff0:	ffffd097          	auipc	ra,0xffffd
    80002ff4:	59e080e7          	jalr	1438(ra) # 8000058e <printf>
      while (i < numargs)
    80002ff8:	bf49                	j	80002f8a <syscall+0x150>

0000000080002ffa <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002ffa:	1101                	addi	sp,sp,-32
    80002ffc:	ec06                	sd	ra,24(sp)
    80002ffe:	e822                	sd	s0,16(sp)
    80003000:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80003002:	fec40593          	addi	a1,s0,-20
    80003006:	4501                	li	a0,0
    80003008:	00000097          	auipc	ra,0x0
    8000300c:	dba080e7          	jalr	-582(ra) # 80002dc2 <argint>
  exit(n);
    80003010:	fec42503          	lw	a0,-20(s0)
    80003014:	fffff097          	auipc	ra,0xfffff
    80003018:	482080e7          	jalr	1154(ra) # 80002496 <exit>
  return 0; // not reached
}
    8000301c:	4501                	li	a0,0
    8000301e:	60e2                	ld	ra,24(sp)
    80003020:	6442                	ld	s0,16(sp)
    80003022:	6105                	addi	sp,sp,32
    80003024:	8082                	ret

0000000080003026 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003026:	1141                	addi	sp,sp,-16
    80003028:	e406                	sd	ra,8(sp)
    8000302a:	e022                	sd	s0,0(sp)
    8000302c:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000302e:	fffff097          	auipc	ra,0xfffff
    80003032:	bc4080e7          	jalr	-1084(ra) # 80001bf2 <myproc>
}
    80003036:	5d08                	lw	a0,56(a0)
    80003038:	60a2                	ld	ra,8(sp)
    8000303a:	6402                	ld	s0,0(sp)
    8000303c:	0141                	addi	sp,sp,16
    8000303e:	8082                	ret

0000000080003040 <sys_fork>:

uint64
sys_fork(void)
{
    80003040:	1141                	addi	sp,sp,-16
    80003042:	e406                	sd	ra,8(sp)
    80003044:	e022                	sd	s0,0(sp)
    80003046:	0800                	addi	s0,sp,16
  return fork();
    80003048:	fffff097          	auipc	ra,0xfffff
    8000304c:	fd6080e7          	jalr	-42(ra) # 8000201e <fork>
}
    80003050:	60a2                	ld	ra,8(sp)
    80003052:	6402                	ld	s0,0(sp)
    80003054:	0141                	addi	sp,sp,16
    80003056:	8082                	ret

0000000080003058 <sys_wait>:

uint64
sys_wait(void)
{
    80003058:	1101                	addi	sp,sp,-32
    8000305a:	ec06                	sd	ra,24(sp)
    8000305c:	e822                	sd	s0,16(sp)
    8000305e:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80003060:	fe840593          	addi	a1,s0,-24
    80003064:	4501                	li	a0,0
    80003066:	00000097          	auipc	ra,0x0
    8000306a:	d7c080e7          	jalr	-644(ra) # 80002de2 <argaddr>
  return wait(p);
    8000306e:	fe843503          	ld	a0,-24(s0)
    80003072:	fffff097          	auipc	ra,0xfffff
    80003076:	5f4080e7          	jalr	1524(ra) # 80002666 <wait>
}
    8000307a:	60e2                	ld	ra,24(sp)
    8000307c:	6442                	ld	s0,16(sp)
    8000307e:	6105                	addi	sp,sp,32
    80003080:	8082                	ret

0000000080003082 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003082:	7179                	addi	sp,sp,-48
    80003084:	f406                	sd	ra,40(sp)
    80003086:	f022                	sd	s0,32(sp)
    80003088:	ec26                	sd	s1,24(sp)
    8000308a:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    8000308c:	fdc40593          	addi	a1,s0,-36
    80003090:	4501                	li	a0,0
    80003092:	00000097          	auipc	ra,0x0
    80003096:	d30080e7          	jalr	-720(ra) # 80002dc2 <argint>
  addr = myproc()->sz;
    8000309a:	fffff097          	auipc	ra,0xfffff
    8000309e:	b58080e7          	jalr	-1192(ra) # 80001bf2 <myproc>
    800030a2:	6924                	ld	s1,80(a0)
  if (growproc(n) < 0)
    800030a4:	fdc42503          	lw	a0,-36(s0)
    800030a8:	fffff097          	auipc	ra,0xfffff
    800030ac:	f1a080e7          	jalr	-230(ra) # 80001fc2 <growproc>
    800030b0:	00054863          	bltz	a0,800030c0 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    800030b4:	8526                	mv	a0,s1
    800030b6:	70a2                	ld	ra,40(sp)
    800030b8:	7402                	ld	s0,32(sp)
    800030ba:	64e2                	ld	s1,24(sp)
    800030bc:	6145                	addi	sp,sp,48
    800030be:	8082                	ret
    return -1;
    800030c0:	54fd                	li	s1,-1
    800030c2:	bfcd                	j	800030b4 <sys_sbrk+0x32>

00000000800030c4 <sys_sleep>:

uint64
sys_sleep(void)
{
    800030c4:	7139                	addi	sp,sp,-64
    800030c6:	fc06                	sd	ra,56(sp)
    800030c8:	f822                	sd	s0,48(sp)
    800030ca:	f426                	sd	s1,40(sp)
    800030cc:	f04a                	sd	s2,32(sp)
    800030ce:	ec4e                	sd	s3,24(sp)
    800030d0:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800030d2:	fcc40593          	addi	a1,s0,-52
    800030d6:	4501                	li	a0,0
    800030d8:	00000097          	auipc	ra,0x0
    800030dc:	cea080e7          	jalr	-790(ra) # 80002dc2 <argint>
  acquire(&tickslock);
    800030e0:	00016517          	auipc	a0,0x16
    800030e4:	fe850513          	addi	a0,a0,-24 # 800190c8 <tickslock>
    800030e8:	ffffe097          	auipc	ra,0xffffe
    800030ec:	b02080e7          	jalr	-1278(ra) # 80000bea <acquire>
  ticks0 = ticks;
    800030f0:	00006917          	auipc	s2,0x6
    800030f4:	ac092903          	lw	s2,-1344(s2) # 80008bb0 <ticks>
  while (ticks - ticks0 < n)
    800030f8:	fcc42783          	lw	a5,-52(s0)
    800030fc:	cf9d                	beqz	a5,8000313a <sys_sleep+0x76>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800030fe:	00016997          	auipc	s3,0x16
    80003102:	fca98993          	addi	s3,s3,-54 # 800190c8 <tickslock>
    80003106:	00006497          	auipc	s1,0x6
    8000310a:	aaa48493          	addi	s1,s1,-1366 # 80008bb0 <ticks>
    if (killed(myproc()))
    8000310e:	fffff097          	auipc	ra,0xfffff
    80003112:	ae4080e7          	jalr	-1308(ra) # 80001bf2 <myproc>
    80003116:	fffff097          	auipc	ra,0xfffff
    8000311a:	51a080e7          	jalr	1306(ra) # 80002630 <killed>
    8000311e:	ed15                	bnez	a0,8000315a <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80003120:	85ce                	mv	a1,s3
    80003122:	8526                	mv	a0,s1
    80003124:	fffff097          	auipc	ra,0xfffff
    80003128:	204080e7          	jalr	516(ra) # 80002328 <sleep>
  while (ticks - ticks0 < n)
    8000312c:	409c                	lw	a5,0(s1)
    8000312e:	412787bb          	subw	a5,a5,s2
    80003132:	fcc42703          	lw	a4,-52(s0)
    80003136:	fce7ece3          	bltu	a5,a4,8000310e <sys_sleep+0x4a>
  }
  release(&tickslock);
    8000313a:	00016517          	auipc	a0,0x16
    8000313e:	f8e50513          	addi	a0,a0,-114 # 800190c8 <tickslock>
    80003142:	ffffe097          	auipc	ra,0xffffe
    80003146:	b5c080e7          	jalr	-1188(ra) # 80000c9e <release>
  return 0;
    8000314a:	4501                	li	a0,0
}
    8000314c:	70e2                	ld	ra,56(sp)
    8000314e:	7442                	ld	s0,48(sp)
    80003150:	74a2                	ld	s1,40(sp)
    80003152:	7902                	ld	s2,32(sp)
    80003154:	69e2                	ld	s3,24(sp)
    80003156:	6121                	addi	sp,sp,64
    80003158:	8082                	ret
      release(&tickslock);
    8000315a:	00016517          	auipc	a0,0x16
    8000315e:	f6e50513          	addi	a0,a0,-146 # 800190c8 <tickslock>
    80003162:	ffffe097          	auipc	ra,0xffffe
    80003166:	b3c080e7          	jalr	-1220(ra) # 80000c9e <release>
      return -1;
    8000316a:	557d                	li	a0,-1
    8000316c:	b7c5                	j	8000314c <sys_sleep+0x88>

000000008000316e <sys_kill>:

uint64
sys_kill(void)
{
    8000316e:	1101                	addi	sp,sp,-32
    80003170:	ec06                	sd	ra,24(sp)
    80003172:	e822                	sd	s0,16(sp)
    80003174:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80003176:	fec40593          	addi	a1,s0,-20
    8000317a:	4501                	li	a0,0
    8000317c:	00000097          	auipc	ra,0x0
    80003180:	c46080e7          	jalr	-954(ra) # 80002dc2 <argint>
  return kill(pid);
    80003184:	fec42503          	lw	a0,-20(s0)
    80003188:	fffff097          	auipc	ra,0xfffff
    8000318c:	3e6080e7          	jalr	998(ra) # 8000256e <kill>
}
    80003190:	60e2                	ld	ra,24(sp)
    80003192:	6442                	ld	s0,16(sp)
    80003194:	6105                	addi	sp,sp,32
    80003196:	8082                	ret

0000000080003198 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003198:	1101                	addi	sp,sp,-32
    8000319a:	ec06                	sd	ra,24(sp)
    8000319c:	e822                	sd	s0,16(sp)
    8000319e:	e426                	sd	s1,8(sp)
    800031a0:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800031a2:	00016517          	auipc	a0,0x16
    800031a6:	f2650513          	addi	a0,a0,-218 # 800190c8 <tickslock>
    800031aa:	ffffe097          	auipc	ra,0xffffe
    800031ae:	a40080e7          	jalr	-1472(ra) # 80000bea <acquire>
  xticks = ticks;
    800031b2:	00006497          	auipc	s1,0x6
    800031b6:	9fe4a483          	lw	s1,-1538(s1) # 80008bb0 <ticks>
  release(&tickslock);
    800031ba:	00016517          	auipc	a0,0x16
    800031be:	f0e50513          	addi	a0,a0,-242 # 800190c8 <tickslock>
    800031c2:	ffffe097          	auipc	ra,0xffffe
    800031c6:	adc080e7          	jalr	-1316(ra) # 80000c9e <release>
  return xticks;
}
    800031ca:	02049513          	slli	a0,s1,0x20
    800031ce:	9101                	srli	a0,a0,0x20
    800031d0:	60e2                	ld	ra,24(sp)
    800031d2:	6442                	ld	s0,16(sp)
    800031d4:	64a2                	ld	s1,8(sp)
    800031d6:	6105                	addi	sp,sp,32
    800031d8:	8082                	ret

00000000800031da <sys_trace>:

uint64
sys_trace(void)
{
    800031da:	1101                	addi	sp,sp,-32
    800031dc:	ec06                	sd	ra,24(sp)
    800031de:	e822                	sd	s0,16(sp)
    800031e0:	1000                	addi	s0,sp,32
  int n; // mask
  argint(0, &n);
    800031e2:	fec40593          	addi	a1,s0,-20
    800031e6:	4501                	li	a0,0
    800031e8:	00000097          	auipc	ra,0x0
    800031ec:	bda080e7          	jalr	-1062(ra) # 80002dc2 <argint>
  myproc()->mask = n;
    800031f0:	fffff097          	auipc	ra,0xfffff
    800031f4:	a02080e7          	jalr	-1534(ra) # 80001bf2 <myproc>
    800031f8:	fec42783          	lw	a5,-20(s0)
    800031fc:	c11c                	sw	a5,0(a0)
  return 0;
}
    800031fe:	4501                	li	a0,0
    80003200:	60e2                	ld	ra,24(sp)
    80003202:	6442                	ld	s0,16(sp)
    80003204:	6105                	addi	sp,sp,32
    80003206:	8082                	ret

0000000080003208 <sys_sigalarm>:

uint64
sys_sigalarm(void)
{
    80003208:	1101                	addi	sp,sp,-32
    8000320a:	ec06                	sd	ra,24(sp)
    8000320c:	e822                	sd	s0,16(sp)
    8000320e:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80003210:	fec40593          	addi	a1,s0,-20
    80003214:	4501                	li	a0,0
    80003216:	00000097          	auipc	ra,0x0
    8000321a:	bac080e7          	jalr	-1108(ra) # 80002dc2 <argint>
  myproc()->ticks0 = 0;
    8000321e:	fffff097          	auipc	ra,0xfffff
    80003222:	9d4080e7          	jalr	-1580(ra) # 80001bf2 <myproc>
    80003226:	00052223          	sw	zero,4(a0)
  return 0;
}
    8000322a:	4501                	li	a0,0
    8000322c:	60e2                	ld	ra,24(sp)
    8000322e:	6442                	ld	s0,16(sp)
    80003230:	6105                	addi	sp,sp,32
    80003232:	8082                	ret

0000000080003234 <sys_set_priority>:
uint64
sys_set_priority(void)
{
    80003234:	1101                	addi	sp,sp,-32
    80003236:	ec06                	sd	ra,24(sp)
    80003238:	e822                	sd	s0,16(sp)
    8000323a:	1000                	addi	s0,sp,32
  int priority;
  int pid;
  argint(0, &priority);
    8000323c:	fec40593          	addi	a1,s0,-20
    80003240:	4501                	li	a0,0
    80003242:	00000097          	auipc	ra,0x0
    80003246:	b80080e7          	jalr	-1152(ra) # 80002dc2 <argint>
  argint(1, &pid);
    8000324a:	fe840593          	addi	a1,s0,-24
    8000324e:	4505                	li	a0,1
    80003250:	00000097          	auipc	ra,0x0
    80003254:	b72080e7          	jalr	-1166(ra) # 80002dc2 <argint>
  return set_priority(priority, pid);
    80003258:	fe842583          	lw	a1,-24(s0)
    8000325c:	fec42503          	lw	a0,-20(s0)
    80003260:	ffffe097          	auipc	ra,0xffffe
    80003264:	646080e7          	jalr	1606(ra) # 800018a6 <set_priority>
}
    80003268:	60e2                	ld	ra,24(sp)
    8000326a:	6442                	ld	s0,16(sp)
    8000326c:	6105                	addi	sp,sp,32
    8000326e:	8082                	ret

0000000080003270 <sys_settickets>:
uint64
sys_settickets(void){
    80003270:	1101                	addi	sp,sp,-32
    80003272:	ec06                	sd	ra,24(sp)
    80003274:	e822                	sd	s0,16(sp)
    80003276:	1000                	addi	s0,sp,32
  int n; // tickets
  argint(0, &n);
    80003278:	fec40593          	addi	a1,s0,-20
    8000327c:	4501                	li	a0,0
    8000327e:	00000097          	auipc	ra,0x0
    80003282:	b44080e7          	jalr	-1212(ra) # 80002dc2 <argint>
  myproc()->tickets = n;
    80003286:	fffff097          	auipc	ra,0xfffff
    8000328a:	96c080e7          	jalr	-1684(ra) # 80001bf2 <myproc>
    8000328e:	fec42783          	lw	a5,-20(s0)
    80003292:	16f52823          	sw	a5,368(a0)
  return 0;
}
    80003296:	4501                	li	a0,0
    80003298:	60e2                	ld	ra,24(sp)
    8000329a:	6442                	ld	s0,16(sp)
    8000329c:	6105                	addi	sp,sp,32
    8000329e:	8082                	ret

00000000800032a0 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800032a0:	7179                	addi	sp,sp,-48
    800032a2:	f406                	sd	ra,40(sp)
    800032a4:	f022                	sd	s0,32(sp)
    800032a6:	ec26                	sd	s1,24(sp)
    800032a8:	e84a                	sd	s2,16(sp)
    800032aa:	e44e                	sd	s3,8(sp)
    800032ac:	e052                	sd	s4,0(sp)
    800032ae:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800032b0:	00005597          	auipc	a1,0x5
    800032b4:	39058593          	addi	a1,a1,912 # 80008640 <syscalls+0xd0>
    800032b8:	00016517          	auipc	a0,0x16
    800032bc:	e2850513          	addi	a0,a0,-472 # 800190e0 <bcache>
    800032c0:	ffffe097          	auipc	ra,0xffffe
    800032c4:	89a080e7          	jalr	-1894(ra) # 80000b5a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800032c8:	0001e797          	auipc	a5,0x1e
    800032cc:	e1878793          	addi	a5,a5,-488 # 800210e0 <bcache+0x8000>
    800032d0:	0001e717          	auipc	a4,0x1e
    800032d4:	07870713          	addi	a4,a4,120 # 80021348 <bcache+0x8268>
    800032d8:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800032dc:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800032e0:	00016497          	auipc	s1,0x16
    800032e4:	e1848493          	addi	s1,s1,-488 # 800190f8 <bcache+0x18>
    b->next = bcache.head.next;
    800032e8:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800032ea:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800032ec:	00005a17          	auipc	s4,0x5
    800032f0:	35ca0a13          	addi	s4,s4,860 # 80008648 <syscalls+0xd8>
    b->next = bcache.head.next;
    800032f4:	2b893783          	ld	a5,696(s2)
    800032f8:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800032fa:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800032fe:	85d2                	mv	a1,s4
    80003300:	01048513          	addi	a0,s1,16
    80003304:	00001097          	auipc	ra,0x1
    80003308:	4c4080e7          	jalr	1220(ra) # 800047c8 <initsleeplock>
    bcache.head.next->prev = b;
    8000330c:	2b893783          	ld	a5,696(s2)
    80003310:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003312:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003316:	45848493          	addi	s1,s1,1112
    8000331a:	fd349de3          	bne	s1,s3,800032f4 <binit+0x54>
  }
}
    8000331e:	70a2                	ld	ra,40(sp)
    80003320:	7402                	ld	s0,32(sp)
    80003322:	64e2                	ld	s1,24(sp)
    80003324:	6942                	ld	s2,16(sp)
    80003326:	69a2                	ld	s3,8(sp)
    80003328:	6a02                	ld	s4,0(sp)
    8000332a:	6145                	addi	sp,sp,48
    8000332c:	8082                	ret

000000008000332e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000332e:	7179                	addi	sp,sp,-48
    80003330:	f406                	sd	ra,40(sp)
    80003332:	f022                	sd	s0,32(sp)
    80003334:	ec26                	sd	s1,24(sp)
    80003336:	e84a                	sd	s2,16(sp)
    80003338:	e44e                	sd	s3,8(sp)
    8000333a:	1800                	addi	s0,sp,48
    8000333c:	89aa                	mv	s3,a0
    8000333e:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80003340:	00016517          	auipc	a0,0x16
    80003344:	da050513          	addi	a0,a0,-608 # 800190e0 <bcache>
    80003348:	ffffe097          	auipc	ra,0xffffe
    8000334c:	8a2080e7          	jalr	-1886(ra) # 80000bea <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003350:	0001e497          	auipc	s1,0x1e
    80003354:	0484b483          	ld	s1,72(s1) # 80021398 <bcache+0x82b8>
    80003358:	0001e797          	auipc	a5,0x1e
    8000335c:	ff078793          	addi	a5,a5,-16 # 80021348 <bcache+0x8268>
    80003360:	02f48f63          	beq	s1,a5,8000339e <bread+0x70>
    80003364:	873e                	mv	a4,a5
    80003366:	a021                	j	8000336e <bread+0x40>
    80003368:	68a4                	ld	s1,80(s1)
    8000336a:	02e48a63          	beq	s1,a4,8000339e <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000336e:	449c                	lw	a5,8(s1)
    80003370:	ff379ce3          	bne	a5,s3,80003368 <bread+0x3a>
    80003374:	44dc                	lw	a5,12(s1)
    80003376:	ff2799e3          	bne	a5,s2,80003368 <bread+0x3a>
      b->refcnt++;
    8000337a:	40bc                	lw	a5,64(s1)
    8000337c:	2785                	addiw	a5,a5,1
    8000337e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003380:	00016517          	auipc	a0,0x16
    80003384:	d6050513          	addi	a0,a0,-672 # 800190e0 <bcache>
    80003388:	ffffe097          	auipc	ra,0xffffe
    8000338c:	916080e7          	jalr	-1770(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    80003390:	01048513          	addi	a0,s1,16
    80003394:	00001097          	auipc	ra,0x1
    80003398:	46e080e7          	jalr	1134(ra) # 80004802 <acquiresleep>
      return b;
    8000339c:	a8b9                	j	800033fa <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000339e:	0001e497          	auipc	s1,0x1e
    800033a2:	ff24b483          	ld	s1,-14(s1) # 80021390 <bcache+0x82b0>
    800033a6:	0001e797          	auipc	a5,0x1e
    800033aa:	fa278793          	addi	a5,a5,-94 # 80021348 <bcache+0x8268>
    800033ae:	00f48863          	beq	s1,a5,800033be <bread+0x90>
    800033b2:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800033b4:	40bc                	lw	a5,64(s1)
    800033b6:	cf81                	beqz	a5,800033ce <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800033b8:	64a4                	ld	s1,72(s1)
    800033ba:	fee49de3          	bne	s1,a4,800033b4 <bread+0x86>
  panic("bget: no buffers");
    800033be:	00005517          	auipc	a0,0x5
    800033c2:	29250513          	addi	a0,a0,658 # 80008650 <syscalls+0xe0>
    800033c6:	ffffd097          	auipc	ra,0xffffd
    800033ca:	17e080e7          	jalr	382(ra) # 80000544 <panic>
      b->dev = dev;
    800033ce:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    800033d2:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    800033d6:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800033da:	4785                	li	a5,1
    800033dc:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800033de:	00016517          	auipc	a0,0x16
    800033e2:	d0250513          	addi	a0,a0,-766 # 800190e0 <bcache>
    800033e6:	ffffe097          	auipc	ra,0xffffe
    800033ea:	8b8080e7          	jalr	-1864(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    800033ee:	01048513          	addi	a0,s1,16
    800033f2:	00001097          	auipc	ra,0x1
    800033f6:	410080e7          	jalr	1040(ra) # 80004802 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800033fa:	409c                	lw	a5,0(s1)
    800033fc:	cb89                	beqz	a5,8000340e <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800033fe:	8526                	mv	a0,s1
    80003400:	70a2                	ld	ra,40(sp)
    80003402:	7402                	ld	s0,32(sp)
    80003404:	64e2                	ld	s1,24(sp)
    80003406:	6942                	ld	s2,16(sp)
    80003408:	69a2                	ld	s3,8(sp)
    8000340a:	6145                	addi	sp,sp,48
    8000340c:	8082                	ret
    virtio_disk_rw(b, 0);
    8000340e:	4581                	li	a1,0
    80003410:	8526                	mv	a0,s1
    80003412:	00003097          	auipc	ra,0x3
    80003416:	fc6080e7          	jalr	-58(ra) # 800063d8 <virtio_disk_rw>
    b->valid = 1;
    8000341a:	4785                	li	a5,1
    8000341c:	c09c                	sw	a5,0(s1)
  return b;
    8000341e:	b7c5                	j	800033fe <bread+0xd0>

0000000080003420 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003420:	1101                	addi	sp,sp,-32
    80003422:	ec06                	sd	ra,24(sp)
    80003424:	e822                	sd	s0,16(sp)
    80003426:	e426                	sd	s1,8(sp)
    80003428:	1000                	addi	s0,sp,32
    8000342a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000342c:	0541                	addi	a0,a0,16
    8000342e:	00001097          	auipc	ra,0x1
    80003432:	46e080e7          	jalr	1134(ra) # 8000489c <holdingsleep>
    80003436:	cd01                	beqz	a0,8000344e <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003438:	4585                	li	a1,1
    8000343a:	8526                	mv	a0,s1
    8000343c:	00003097          	auipc	ra,0x3
    80003440:	f9c080e7          	jalr	-100(ra) # 800063d8 <virtio_disk_rw>
}
    80003444:	60e2                	ld	ra,24(sp)
    80003446:	6442                	ld	s0,16(sp)
    80003448:	64a2                	ld	s1,8(sp)
    8000344a:	6105                	addi	sp,sp,32
    8000344c:	8082                	ret
    panic("bwrite");
    8000344e:	00005517          	auipc	a0,0x5
    80003452:	21a50513          	addi	a0,a0,538 # 80008668 <syscalls+0xf8>
    80003456:	ffffd097          	auipc	ra,0xffffd
    8000345a:	0ee080e7          	jalr	238(ra) # 80000544 <panic>

000000008000345e <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000345e:	1101                	addi	sp,sp,-32
    80003460:	ec06                	sd	ra,24(sp)
    80003462:	e822                	sd	s0,16(sp)
    80003464:	e426                	sd	s1,8(sp)
    80003466:	e04a                	sd	s2,0(sp)
    80003468:	1000                	addi	s0,sp,32
    8000346a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000346c:	01050913          	addi	s2,a0,16
    80003470:	854a                	mv	a0,s2
    80003472:	00001097          	auipc	ra,0x1
    80003476:	42a080e7          	jalr	1066(ra) # 8000489c <holdingsleep>
    8000347a:	c92d                	beqz	a0,800034ec <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000347c:	854a                	mv	a0,s2
    8000347e:	00001097          	auipc	ra,0x1
    80003482:	3da080e7          	jalr	986(ra) # 80004858 <releasesleep>

  acquire(&bcache.lock);
    80003486:	00016517          	auipc	a0,0x16
    8000348a:	c5a50513          	addi	a0,a0,-934 # 800190e0 <bcache>
    8000348e:	ffffd097          	auipc	ra,0xffffd
    80003492:	75c080e7          	jalr	1884(ra) # 80000bea <acquire>
  b->refcnt--;
    80003496:	40bc                	lw	a5,64(s1)
    80003498:	37fd                	addiw	a5,a5,-1
    8000349a:	0007871b          	sext.w	a4,a5
    8000349e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800034a0:	eb05                	bnez	a4,800034d0 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800034a2:	68bc                	ld	a5,80(s1)
    800034a4:	64b8                	ld	a4,72(s1)
    800034a6:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800034a8:	64bc                	ld	a5,72(s1)
    800034aa:	68b8                	ld	a4,80(s1)
    800034ac:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800034ae:	0001e797          	auipc	a5,0x1e
    800034b2:	c3278793          	addi	a5,a5,-974 # 800210e0 <bcache+0x8000>
    800034b6:	2b87b703          	ld	a4,696(a5)
    800034ba:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800034bc:	0001e717          	auipc	a4,0x1e
    800034c0:	e8c70713          	addi	a4,a4,-372 # 80021348 <bcache+0x8268>
    800034c4:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800034c6:	2b87b703          	ld	a4,696(a5)
    800034ca:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800034cc:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800034d0:	00016517          	auipc	a0,0x16
    800034d4:	c1050513          	addi	a0,a0,-1008 # 800190e0 <bcache>
    800034d8:	ffffd097          	auipc	ra,0xffffd
    800034dc:	7c6080e7          	jalr	1990(ra) # 80000c9e <release>
}
    800034e0:	60e2                	ld	ra,24(sp)
    800034e2:	6442                	ld	s0,16(sp)
    800034e4:	64a2                	ld	s1,8(sp)
    800034e6:	6902                	ld	s2,0(sp)
    800034e8:	6105                	addi	sp,sp,32
    800034ea:	8082                	ret
    panic("brelse");
    800034ec:	00005517          	auipc	a0,0x5
    800034f0:	18450513          	addi	a0,a0,388 # 80008670 <syscalls+0x100>
    800034f4:	ffffd097          	auipc	ra,0xffffd
    800034f8:	050080e7          	jalr	80(ra) # 80000544 <panic>

00000000800034fc <bpin>:

void
bpin(struct buf *b) {
    800034fc:	1101                	addi	sp,sp,-32
    800034fe:	ec06                	sd	ra,24(sp)
    80003500:	e822                	sd	s0,16(sp)
    80003502:	e426                	sd	s1,8(sp)
    80003504:	1000                	addi	s0,sp,32
    80003506:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003508:	00016517          	auipc	a0,0x16
    8000350c:	bd850513          	addi	a0,a0,-1064 # 800190e0 <bcache>
    80003510:	ffffd097          	auipc	ra,0xffffd
    80003514:	6da080e7          	jalr	1754(ra) # 80000bea <acquire>
  b->refcnt++;
    80003518:	40bc                	lw	a5,64(s1)
    8000351a:	2785                	addiw	a5,a5,1
    8000351c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000351e:	00016517          	auipc	a0,0x16
    80003522:	bc250513          	addi	a0,a0,-1086 # 800190e0 <bcache>
    80003526:	ffffd097          	auipc	ra,0xffffd
    8000352a:	778080e7          	jalr	1912(ra) # 80000c9e <release>
}
    8000352e:	60e2                	ld	ra,24(sp)
    80003530:	6442                	ld	s0,16(sp)
    80003532:	64a2                	ld	s1,8(sp)
    80003534:	6105                	addi	sp,sp,32
    80003536:	8082                	ret

0000000080003538 <bunpin>:

void
bunpin(struct buf *b) {
    80003538:	1101                	addi	sp,sp,-32
    8000353a:	ec06                	sd	ra,24(sp)
    8000353c:	e822                	sd	s0,16(sp)
    8000353e:	e426                	sd	s1,8(sp)
    80003540:	1000                	addi	s0,sp,32
    80003542:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003544:	00016517          	auipc	a0,0x16
    80003548:	b9c50513          	addi	a0,a0,-1124 # 800190e0 <bcache>
    8000354c:	ffffd097          	auipc	ra,0xffffd
    80003550:	69e080e7          	jalr	1694(ra) # 80000bea <acquire>
  b->refcnt--;
    80003554:	40bc                	lw	a5,64(s1)
    80003556:	37fd                	addiw	a5,a5,-1
    80003558:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000355a:	00016517          	auipc	a0,0x16
    8000355e:	b8650513          	addi	a0,a0,-1146 # 800190e0 <bcache>
    80003562:	ffffd097          	auipc	ra,0xffffd
    80003566:	73c080e7          	jalr	1852(ra) # 80000c9e <release>
}
    8000356a:	60e2                	ld	ra,24(sp)
    8000356c:	6442                	ld	s0,16(sp)
    8000356e:	64a2                	ld	s1,8(sp)
    80003570:	6105                	addi	sp,sp,32
    80003572:	8082                	ret

0000000080003574 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003574:	1101                	addi	sp,sp,-32
    80003576:	ec06                	sd	ra,24(sp)
    80003578:	e822                	sd	s0,16(sp)
    8000357a:	e426                	sd	s1,8(sp)
    8000357c:	e04a                	sd	s2,0(sp)
    8000357e:	1000                	addi	s0,sp,32
    80003580:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003582:	00d5d59b          	srliw	a1,a1,0xd
    80003586:	0001e797          	auipc	a5,0x1e
    8000358a:	2367a783          	lw	a5,566(a5) # 800217bc <sb+0x1c>
    8000358e:	9dbd                	addw	a1,a1,a5
    80003590:	00000097          	auipc	ra,0x0
    80003594:	d9e080e7          	jalr	-610(ra) # 8000332e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003598:	0074f713          	andi	a4,s1,7
    8000359c:	4785                	li	a5,1
    8000359e:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800035a2:	14ce                	slli	s1,s1,0x33
    800035a4:	90d9                	srli	s1,s1,0x36
    800035a6:	00950733          	add	a4,a0,s1
    800035aa:	05874703          	lbu	a4,88(a4)
    800035ae:	00e7f6b3          	and	a3,a5,a4
    800035b2:	c69d                	beqz	a3,800035e0 <bfree+0x6c>
    800035b4:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800035b6:	94aa                	add	s1,s1,a0
    800035b8:	fff7c793          	not	a5,a5
    800035bc:	8ff9                	and	a5,a5,a4
    800035be:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800035c2:	00001097          	auipc	ra,0x1
    800035c6:	120080e7          	jalr	288(ra) # 800046e2 <log_write>
  brelse(bp);
    800035ca:	854a                	mv	a0,s2
    800035cc:	00000097          	auipc	ra,0x0
    800035d0:	e92080e7          	jalr	-366(ra) # 8000345e <brelse>
}
    800035d4:	60e2                	ld	ra,24(sp)
    800035d6:	6442                	ld	s0,16(sp)
    800035d8:	64a2                	ld	s1,8(sp)
    800035da:	6902                	ld	s2,0(sp)
    800035dc:	6105                	addi	sp,sp,32
    800035de:	8082                	ret
    panic("freeing free block");
    800035e0:	00005517          	auipc	a0,0x5
    800035e4:	09850513          	addi	a0,a0,152 # 80008678 <syscalls+0x108>
    800035e8:	ffffd097          	auipc	ra,0xffffd
    800035ec:	f5c080e7          	jalr	-164(ra) # 80000544 <panic>

00000000800035f0 <balloc>:
{
    800035f0:	711d                	addi	sp,sp,-96
    800035f2:	ec86                	sd	ra,88(sp)
    800035f4:	e8a2                	sd	s0,80(sp)
    800035f6:	e4a6                	sd	s1,72(sp)
    800035f8:	e0ca                	sd	s2,64(sp)
    800035fa:	fc4e                	sd	s3,56(sp)
    800035fc:	f852                	sd	s4,48(sp)
    800035fe:	f456                	sd	s5,40(sp)
    80003600:	f05a                	sd	s6,32(sp)
    80003602:	ec5e                	sd	s7,24(sp)
    80003604:	e862                	sd	s8,16(sp)
    80003606:	e466                	sd	s9,8(sp)
    80003608:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000360a:	0001e797          	auipc	a5,0x1e
    8000360e:	19a7a783          	lw	a5,410(a5) # 800217a4 <sb+0x4>
    80003612:	10078163          	beqz	a5,80003714 <balloc+0x124>
    80003616:	8baa                	mv	s7,a0
    80003618:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000361a:	0001eb17          	auipc	s6,0x1e
    8000361e:	186b0b13          	addi	s6,s6,390 # 800217a0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003622:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003624:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003626:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003628:	6c89                	lui	s9,0x2
    8000362a:	a061                	j	800036b2 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000362c:	974a                	add	a4,a4,s2
    8000362e:	8fd5                	or	a5,a5,a3
    80003630:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003634:	854a                	mv	a0,s2
    80003636:	00001097          	auipc	ra,0x1
    8000363a:	0ac080e7          	jalr	172(ra) # 800046e2 <log_write>
        brelse(bp);
    8000363e:	854a                	mv	a0,s2
    80003640:	00000097          	auipc	ra,0x0
    80003644:	e1e080e7          	jalr	-482(ra) # 8000345e <brelse>
  bp = bread(dev, bno);
    80003648:	85a6                	mv	a1,s1
    8000364a:	855e                	mv	a0,s7
    8000364c:	00000097          	auipc	ra,0x0
    80003650:	ce2080e7          	jalr	-798(ra) # 8000332e <bread>
    80003654:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003656:	40000613          	li	a2,1024
    8000365a:	4581                	li	a1,0
    8000365c:	05850513          	addi	a0,a0,88
    80003660:	ffffd097          	auipc	ra,0xffffd
    80003664:	686080e7          	jalr	1670(ra) # 80000ce6 <memset>
  log_write(bp);
    80003668:	854a                	mv	a0,s2
    8000366a:	00001097          	auipc	ra,0x1
    8000366e:	078080e7          	jalr	120(ra) # 800046e2 <log_write>
  brelse(bp);
    80003672:	854a                	mv	a0,s2
    80003674:	00000097          	auipc	ra,0x0
    80003678:	dea080e7          	jalr	-534(ra) # 8000345e <brelse>
}
    8000367c:	8526                	mv	a0,s1
    8000367e:	60e6                	ld	ra,88(sp)
    80003680:	6446                	ld	s0,80(sp)
    80003682:	64a6                	ld	s1,72(sp)
    80003684:	6906                	ld	s2,64(sp)
    80003686:	79e2                	ld	s3,56(sp)
    80003688:	7a42                	ld	s4,48(sp)
    8000368a:	7aa2                	ld	s5,40(sp)
    8000368c:	7b02                	ld	s6,32(sp)
    8000368e:	6be2                	ld	s7,24(sp)
    80003690:	6c42                	ld	s8,16(sp)
    80003692:	6ca2                	ld	s9,8(sp)
    80003694:	6125                	addi	sp,sp,96
    80003696:	8082                	ret
    brelse(bp);
    80003698:	854a                	mv	a0,s2
    8000369a:	00000097          	auipc	ra,0x0
    8000369e:	dc4080e7          	jalr	-572(ra) # 8000345e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800036a2:	015c87bb          	addw	a5,s9,s5
    800036a6:	00078a9b          	sext.w	s5,a5
    800036aa:	004b2703          	lw	a4,4(s6)
    800036ae:	06eaf363          	bgeu	s5,a4,80003714 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    800036b2:	41fad79b          	sraiw	a5,s5,0x1f
    800036b6:	0137d79b          	srliw	a5,a5,0x13
    800036ba:	015787bb          	addw	a5,a5,s5
    800036be:	40d7d79b          	sraiw	a5,a5,0xd
    800036c2:	01cb2583          	lw	a1,28(s6)
    800036c6:	9dbd                	addw	a1,a1,a5
    800036c8:	855e                	mv	a0,s7
    800036ca:	00000097          	auipc	ra,0x0
    800036ce:	c64080e7          	jalr	-924(ra) # 8000332e <bread>
    800036d2:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036d4:	004b2503          	lw	a0,4(s6)
    800036d8:	000a849b          	sext.w	s1,s5
    800036dc:	8662                	mv	a2,s8
    800036de:	faa4fde3          	bgeu	s1,a0,80003698 <balloc+0xa8>
      m = 1 << (bi % 8);
    800036e2:	41f6579b          	sraiw	a5,a2,0x1f
    800036e6:	01d7d69b          	srliw	a3,a5,0x1d
    800036ea:	00c6873b          	addw	a4,a3,a2
    800036ee:	00777793          	andi	a5,a4,7
    800036f2:	9f95                	subw	a5,a5,a3
    800036f4:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800036f8:	4037571b          	sraiw	a4,a4,0x3
    800036fc:	00e906b3          	add	a3,s2,a4
    80003700:	0586c683          	lbu	a3,88(a3)
    80003704:	00d7f5b3          	and	a1,a5,a3
    80003708:	d195                	beqz	a1,8000362c <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000370a:	2605                	addiw	a2,a2,1
    8000370c:	2485                	addiw	s1,s1,1
    8000370e:	fd4618e3          	bne	a2,s4,800036de <balloc+0xee>
    80003712:	b759                	j	80003698 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003714:	00005517          	auipc	a0,0x5
    80003718:	f7c50513          	addi	a0,a0,-132 # 80008690 <syscalls+0x120>
    8000371c:	ffffd097          	auipc	ra,0xffffd
    80003720:	e72080e7          	jalr	-398(ra) # 8000058e <printf>
  return 0;
    80003724:	4481                	li	s1,0
    80003726:	bf99                	j	8000367c <balloc+0x8c>

0000000080003728 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003728:	7179                	addi	sp,sp,-48
    8000372a:	f406                	sd	ra,40(sp)
    8000372c:	f022                	sd	s0,32(sp)
    8000372e:	ec26                	sd	s1,24(sp)
    80003730:	e84a                	sd	s2,16(sp)
    80003732:	e44e                	sd	s3,8(sp)
    80003734:	e052                	sd	s4,0(sp)
    80003736:	1800                	addi	s0,sp,48
    80003738:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000373a:	47ad                	li	a5,11
    8000373c:	02b7e763          	bltu	a5,a1,8000376a <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003740:	02059493          	slli	s1,a1,0x20
    80003744:	9081                	srli	s1,s1,0x20
    80003746:	048a                	slli	s1,s1,0x2
    80003748:	94aa                	add	s1,s1,a0
    8000374a:	0504a903          	lw	s2,80(s1)
    8000374e:	06091e63          	bnez	s2,800037ca <bmap+0xa2>
      addr = balloc(ip->dev);
    80003752:	4108                	lw	a0,0(a0)
    80003754:	00000097          	auipc	ra,0x0
    80003758:	e9c080e7          	jalr	-356(ra) # 800035f0 <balloc>
    8000375c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003760:	06090563          	beqz	s2,800037ca <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80003764:	0524a823          	sw	s2,80(s1)
    80003768:	a08d                	j	800037ca <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000376a:	ff45849b          	addiw	s1,a1,-12
    8000376e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003772:	0ff00793          	li	a5,255
    80003776:	08e7e563          	bltu	a5,a4,80003800 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000377a:	08052903          	lw	s2,128(a0)
    8000377e:	00091d63          	bnez	s2,80003798 <bmap+0x70>
      addr = balloc(ip->dev);
    80003782:	4108                	lw	a0,0(a0)
    80003784:	00000097          	auipc	ra,0x0
    80003788:	e6c080e7          	jalr	-404(ra) # 800035f0 <balloc>
    8000378c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003790:	02090d63          	beqz	s2,800037ca <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003794:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003798:	85ca                	mv	a1,s2
    8000379a:	0009a503          	lw	a0,0(s3)
    8000379e:	00000097          	auipc	ra,0x0
    800037a2:	b90080e7          	jalr	-1136(ra) # 8000332e <bread>
    800037a6:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800037a8:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800037ac:	02049593          	slli	a1,s1,0x20
    800037b0:	9181                	srli	a1,a1,0x20
    800037b2:	058a                	slli	a1,a1,0x2
    800037b4:	00b784b3          	add	s1,a5,a1
    800037b8:	0004a903          	lw	s2,0(s1)
    800037bc:	02090063          	beqz	s2,800037dc <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800037c0:	8552                	mv	a0,s4
    800037c2:	00000097          	auipc	ra,0x0
    800037c6:	c9c080e7          	jalr	-868(ra) # 8000345e <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800037ca:	854a                	mv	a0,s2
    800037cc:	70a2                	ld	ra,40(sp)
    800037ce:	7402                	ld	s0,32(sp)
    800037d0:	64e2                	ld	s1,24(sp)
    800037d2:	6942                	ld	s2,16(sp)
    800037d4:	69a2                	ld	s3,8(sp)
    800037d6:	6a02                	ld	s4,0(sp)
    800037d8:	6145                	addi	sp,sp,48
    800037da:	8082                	ret
      addr = balloc(ip->dev);
    800037dc:	0009a503          	lw	a0,0(s3)
    800037e0:	00000097          	auipc	ra,0x0
    800037e4:	e10080e7          	jalr	-496(ra) # 800035f0 <balloc>
    800037e8:	0005091b          	sext.w	s2,a0
      if(addr){
    800037ec:	fc090ae3          	beqz	s2,800037c0 <bmap+0x98>
        a[bn] = addr;
    800037f0:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800037f4:	8552                	mv	a0,s4
    800037f6:	00001097          	auipc	ra,0x1
    800037fa:	eec080e7          	jalr	-276(ra) # 800046e2 <log_write>
    800037fe:	b7c9                	j	800037c0 <bmap+0x98>
  panic("bmap: out of range");
    80003800:	00005517          	auipc	a0,0x5
    80003804:	ea850513          	addi	a0,a0,-344 # 800086a8 <syscalls+0x138>
    80003808:	ffffd097          	auipc	ra,0xffffd
    8000380c:	d3c080e7          	jalr	-708(ra) # 80000544 <panic>

0000000080003810 <iget>:
{
    80003810:	7179                	addi	sp,sp,-48
    80003812:	f406                	sd	ra,40(sp)
    80003814:	f022                	sd	s0,32(sp)
    80003816:	ec26                	sd	s1,24(sp)
    80003818:	e84a                	sd	s2,16(sp)
    8000381a:	e44e                	sd	s3,8(sp)
    8000381c:	e052                	sd	s4,0(sp)
    8000381e:	1800                	addi	s0,sp,48
    80003820:	89aa                	mv	s3,a0
    80003822:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003824:	0001e517          	auipc	a0,0x1e
    80003828:	f9c50513          	addi	a0,a0,-100 # 800217c0 <itable>
    8000382c:	ffffd097          	auipc	ra,0xffffd
    80003830:	3be080e7          	jalr	958(ra) # 80000bea <acquire>
  empty = 0;
    80003834:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003836:	0001e497          	auipc	s1,0x1e
    8000383a:	fa248493          	addi	s1,s1,-94 # 800217d8 <itable+0x18>
    8000383e:	00020697          	auipc	a3,0x20
    80003842:	a2a68693          	addi	a3,a3,-1494 # 80023268 <log>
    80003846:	a039                	j	80003854 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003848:	02090b63          	beqz	s2,8000387e <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000384c:	08848493          	addi	s1,s1,136
    80003850:	02d48a63          	beq	s1,a3,80003884 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003854:	449c                	lw	a5,8(s1)
    80003856:	fef059e3          	blez	a5,80003848 <iget+0x38>
    8000385a:	4098                	lw	a4,0(s1)
    8000385c:	ff3716e3          	bne	a4,s3,80003848 <iget+0x38>
    80003860:	40d8                	lw	a4,4(s1)
    80003862:	ff4713e3          	bne	a4,s4,80003848 <iget+0x38>
      ip->ref++;
    80003866:	2785                	addiw	a5,a5,1
    80003868:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000386a:	0001e517          	auipc	a0,0x1e
    8000386e:	f5650513          	addi	a0,a0,-170 # 800217c0 <itable>
    80003872:	ffffd097          	auipc	ra,0xffffd
    80003876:	42c080e7          	jalr	1068(ra) # 80000c9e <release>
      return ip;
    8000387a:	8926                	mv	s2,s1
    8000387c:	a03d                	j	800038aa <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000387e:	f7f9                	bnez	a5,8000384c <iget+0x3c>
    80003880:	8926                	mv	s2,s1
    80003882:	b7e9                	j	8000384c <iget+0x3c>
  if(empty == 0)
    80003884:	02090c63          	beqz	s2,800038bc <iget+0xac>
  ip->dev = dev;
    80003888:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000388c:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003890:	4785                	li	a5,1
    80003892:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003896:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000389a:	0001e517          	auipc	a0,0x1e
    8000389e:	f2650513          	addi	a0,a0,-218 # 800217c0 <itable>
    800038a2:	ffffd097          	auipc	ra,0xffffd
    800038a6:	3fc080e7          	jalr	1020(ra) # 80000c9e <release>
}
    800038aa:	854a                	mv	a0,s2
    800038ac:	70a2                	ld	ra,40(sp)
    800038ae:	7402                	ld	s0,32(sp)
    800038b0:	64e2                	ld	s1,24(sp)
    800038b2:	6942                	ld	s2,16(sp)
    800038b4:	69a2                	ld	s3,8(sp)
    800038b6:	6a02                	ld	s4,0(sp)
    800038b8:	6145                	addi	sp,sp,48
    800038ba:	8082                	ret
    panic("iget: no inodes");
    800038bc:	00005517          	auipc	a0,0x5
    800038c0:	e0450513          	addi	a0,a0,-508 # 800086c0 <syscalls+0x150>
    800038c4:	ffffd097          	auipc	ra,0xffffd
    800038c8:	c80080e7          	jalr	-896(ra) # 80000544 <panic>

00000000800038cc <fsinit>:
fsinit(int dev) {
    800038cc:	7179                	addi	sp,sp,-48
    800038ce:	f406                	sd	ra,40(sp)
    800038d0:	f022                	sd	s0,32(sp)
    800038d2:	ec26                	sd	s1,24(sp)
    800038d4:	e84a                	sd	s2,16(sp)
    800038d6:	e44e                	sd	s3,8(sp)
    800038d8:	1800                	addi	s0,sp,48
    800038da:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800038dc:	4585                	li	a1,1
    800038de:	00000097          	auipc	ra,0x0
    800038e2:	a50080e7          	jalr	-1456(ra) # 8000332e <bread>
    800038e6:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800038e8:	0001e997          	auipc	s3,0x1e
    800038ec:	eb898993          	addi	s3,s3,-328 # 800217a0 <sb>
    800038f0:	02000613          	li	a2,32
    800038f4:	05850593          	addi	a1,a0,88
    800038f8:	854e                	mv	a0,s3
    800038fa:	ffffd097          	auipc	ra,0xffffd
    800038fe:	44c080e7          	jalr	1100(ra) # 80000d46 <memmove>
  brelse(bp);
    80003902:	8526                	mv	a0,s1
    80003904:	00000097          	auipc	ra,0x0
    80003908:	b5a080e7          	jalr	-1190(ra) # 8000345e <brelse>
  if(sb.magic != FSMAGIC)
    8000390c:	0009a703          	lw	a4,0(s3)
    80003910:	102037b7          	lui	a5,0x10203
    80003914:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003918:	02f71263          	bne	a4,a5,8000393c <fsinit+0x70>
  initlog(dev, &sb);
    8000391c:	0001e597          	auipc	a1,0x1e
    80003920:	e8458593          	addi	a1,a1,-380 # 800217a0 <sb>
    80003924:	854a                	mv	a0,s2
    80003926:	00001097          	auipc	ra,0x1
    8000392a:	b40080e7          	jalr	-1216(ra) # 80004466 <initlog>
}
    8000392e:	70a2                	ld	ra,40(sp)
    80003930:	7402                	ld	s0,32(sp)
    80003932:	64e2                	ld	s1,24(sp)
    80003934:	6942                	ld	s2,16(sp)
    80003936:	69a2                	ld	s3,8(sp)
    80003938:	6145                	addi	sp,sp,48
    8000393a:	8082                	ret
    panic("invalid file system");
    8000393c:	00005517          	auipc	a0,0x5
    80003940:	d9450513          	addi	a0,a0,-620 # 800086d0 <syscalls+0x160>
    80003944:	ffffd097          	auipc	ra,0xffffd
    80003948:	c00080e7          	jalr	-1024(ra) # 80000544 <panic>

000000008000394c <iinit>:
{
    8000394c:	7179                	addi	sp,sp,-48
    8000394e:	f406                	sd	ra,40(sp)
    80003950:	f022                	sd	s0,32(sp)
    80003952:	ec26                	sd	s1,24(sp)
    80003954:	e84a                	sd	s2,16(sp)
    80003956:	e44e                	sd	s3,8(sp)
    80003958:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000395a:	00005597          	auipc	a1,0x5
    8000395e:	d8e58593          	addi	a1,a1,-626 # 800086e8 <syscalls+0x178>
    80003962:	0001e517          	auipc	a0,0x1e
    80003966:	e5e50513          	addi	a0,a0,-418 # 800217c0 <itable>
    8000396a:	ffffd097          	auipc	ra,0xffffd
    8000396e:	1f0080e7          	jalr	496(ra) # 80000b5a <initlock>
  for(i = 0; i < NINODE; i++) {
    80003972:	0001e497          	auipc	s1,0x1e
    80003976:	e7648493          	addi	s1,s1,-394 # 800217e8 <itable+0x28>
    8000397a:	00020997          	auipc	s3,0x20
    8000397e:	8fe98993          	addi	s3,s3,-1794 # 80023278 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003982:	00005917          	auipc	s2,0x5
    80003986:	d6e90913          	addi	s2,s2,-658 # 800086f0 <syscalls+0x180>
    8000398a:	85ca                	mv	a1,s2
    8000398c:	8526                	mv	a0,s1
    8000398e:	00001097          	auipc	ra,0x1
    80003992:	e3a080e7          	jalr	-454(ra) # 800047c8 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003996:	08848493          	addi	s1,s1,136
    8000399a:	ff3498e3          	bne	s1,s3,8000398a <iinit+0x3e>
}
    8000399e:	70a2                	ld	ra,40(sp)
    800039a0:	7402                	ld	s0,32(sp)
    800039a2:	64e2                	ld	s1,24(sp)
    800039a4:	6942                	ld	s2,16(sp)
    800039a6:	69a2                	ld	s3,8(sp)
    800039a8:	6145                	addi	sp,sp,48
    800039aa:	8082                	ret

00000000800039ac <ialloc>:
{
    800039ac:	715d                	addi	sp,sp,-80
    800039ae:	e486                	sd	ra,72(sp)
    800039b0:	e0a2                	sd	s0,64(sp)
    800039b2:	fc26                	sd	s1,56(sp)
    800039b4:	f84a                	sd	s2,48(sp)
    800039b6:	f44e                	sd	s3,40(sp)
    800039b8:	f052                	sd	s4,32(sp)
    800039ba:	ec56                	sd	s5,24(sp)
    800039bc:	e85a                	sd	s6,16(sp)
    800039be:	e45e                	sd	s7,8(sp)
    800039c0:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800039c2:	0001e717          	auipc	a4,0x1e
    800039c6:	dea72703          	lw	a4,-534(a4) # 800217ac <sb+0xc>
    800039ca:	4785                	li	a5,1
    800039cc:	04e7fa63          	bgeu	a5,a4,80003a20 <ialloc+0x74>
    800039d0:	8aaa                	mv	s5,a0
    800039d2:	8bae                	mv	s7,a1
    800039d4:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800039d6:	0001ea17          	auipc	s4,0x1e
    800039da:	dcaa0a13          	addi	s4,s4,-566 # 800217a0 <sb>
    800039de:	00048b1b          	sext.w	s6,s1
    800039e2:	0044d593          	srli	a1,s1,0x4
    800039e6:	018a2783          	lw	a5,24(s4)
    800039ea:	9dbd                	addw	a1,a1,a5
    800039ec:	8556                	mv	a0,s5
    800039ee:	00000097          	auipc	ra,0x0
    800039f2:	940080e7          	jalr	-1728(ra) # 8000332e <bread>
    800039f6:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800039f8:	05850993          	addi	s3,a0,88
    800039fc:	00f4f793          	andi	a5,s1,15
    80003a00:	079a                	slli	a5,a5,0x6
    80003a02:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003a04:	00099783          	lh	a5,0(s3)
    80003a08:	c3a1                	beqz	a5,80003a48 <ialloc+0x9c>
    brelse(bp);
    80003a0a:	00000097          	auipc	ra,0x0
    80003a0e:	a54080e7          	jalr	-1452(ra) # 8000345e <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003a12:	0485                	addi	s1,s1,1
    80003a14:	00ca2703          	lw	a4,12(s4)
    80003a18:	0004879b          	sext.w	a5,s1
    80003a1c:	fce7e1e3          	bltu	a5,a4,800039de <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003a20:	00005517          	auipc	a0,0x5
    80003a24:	cd850513          	addi	a0,a0,-808 # 800086f8 <syscalls+0x188>
    80003a28:	ffffd097          	auipc	ra,0xffffd
    80003a2c:	b66080e7          	jalr	-1178(ra) # 8000058e <printf>
  return 0;
    80003a30:	4501                	li	a0,0
}
    80003a32:	60a6                	ld	ra,72(sp)
    80003a34:	6406                	ld	s0,64(sp)
    80003a36:	74e2                	ld	s1,56(sp)
    80003a38:	7942                	ld	s2,48(sp)
    80003a3a:	79a2                	ld	s3,40(sp)
    80003a3c:	7a02                	ld	s4,32(sp)
    80003a3e:	6ae2                	ld	s5,24(sp)
    80003a40:	6b42                	ld	s6,16(sp)
    80003a42:	6ba2                	ld	s7,8(sp)
    80003a44:	6161                	addi	sp,sp,80
    80003a46:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003a48:	04000613          	li	a2,64
    80003a4c:	4581                	li	a1,0
    80003a4e:	854e                	mv	a0,s3
    80003a50:	ffffd097          	auipc	ra,0xffffd
    80003a54:	296080e7          	jalr	662(ra) # 80000ce6 <memset>
      dip->type = type;
    80003a58:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003a5c:	854a                	mv	a0,s2
    80003a5e:	00001097          	auipc	ra,0x1
    80003a62:	c84080e7          	jalr	-892(ra) # 800046e2 <log_write>
      brelse(bp);
    80003a66:	854a                	mv	a0,s2
    80003a68:	00000097          	auipc	ra,0x0
    80003a6c:	9f6080e7          	jalr	-1546(ra) # 8000345e <brelse>
      return iget(dev, inum);
    80003a70:	85da                	mv	a1,s6
    80003a72:	8556                	mv	a0,s5
    80003a74:	00000097          	auipc	ra,0x0
    80003a78:	d9c080e7          	jalr	-612(ra) # 80003810 <iget>
    80003a7c:	bf5d                	j	80003a32 <ialloc+0x86>

0000000080003a7e <iupdate>:
{
    80003a7e:	1101                	addi	sp,sp,-32
    80003a80:	ec06                	sd	ra,24(sp)
    80003a82:	e822                	sd	s0,16(sp)
    80003a84:	e426                	sd	s1,8(sp)
    80003a86:	e04a                	sd	s2,0(sp)
    80003a88:	1000                	addi	s0,sp,32
    80003a8a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a8c:	415c                	lw	a5,4(a0)
    80003a8e:	0047d79b          	srliw	a5,a5,0x4
    80003a92:	0001e597          	auipc	a1,0x1e
    80003a96:	d265a583          	lw	a1,-730(a1) # 800217b8 <sb+0x18>
    80003a9a:	9dbd                	addw	a1,a1,a5
    80003a9c:	4108                	lw	a0,0(a0)
    80003a9e:	00000097          	auipc	ra,0x0
    80003aa2:	890080e7          	jalr	-1904(ra) # 8000332e <bread>
    80003aa6:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003aa8:	05850793          	addi	a5,a0,88
    80003aac:	40c8                	lw	a0,4(s1)
    80003aae:	893d                	andi	a0,a0,15
    80003ab0:	051a                	slli	a0,a0,0x6
    80003ab2:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003ab4:	04449703          	lh	a4,68(s1)
    80003ab8:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003abc:	04649703          	lh	a4,70(s1)
    80003ac0:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003ac4:	04849703          	lh	a4,72(s1)
    80003ac8:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003acc:	04a49703          	lh	a4,74(s1)
    80003ad0:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003ad4:	44f8                	lw	a4,76(s1)
    80003ad6:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003ad8:	03400613          	li	a2,52
    80003adc:	05048593          	addi	a1,s1,80
    80003ae0:	0531                	addi	a0,a0,12
    80003ae2:	ffffd097          	auipc	ra,0xffffd
    80003ae6:	264080e7          	jalr	612(ra) # 80000d46 <memmove>
  log_write(bp);
    80003aea:	854a                	mv	a0,s2
    80003aec:	00001097          	auipc	ra,0x1
    80003af0:	bf6080e7          	jalr	-1034(ra) # 800046e2 <log_write>
  brelse(bp);
    80003af4:	854a                	mv	a0,s2
    80003af6:	00000097          	auipc	ra,0x0
    80003afa:	968080e7          	jalr	-1688(ra) # 8000345e <brelse>
}
    80003afe:	60e2                	ld	ra,24(sp)
    80003b00:	6442                	ld	s0,16(sp)
    80003b02:	64a2                	ld	s1,8(sp)
    80003b04:	6902                	ld	s2,0(sp)
    80003b06:	6105                	addi	sp,sp,32
    80003b08:	8082                	ret

0000000080003b0a <idup>:
{
    80003b0a:	1101                	addi	sp,sp,-32
    80003b0c:	ec06                	sd	ra,24(sp)
    80003b0e:	e822                	sd	s0,16(sp)
    80003b10:	e426                	sd	s1,8(sp)
    80003b12:	1000                	addi	s0,sp,32
    80003b14:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003b16:	0001e517          	auipc	a0,0x1e
    80003b1a:	caa50513          	addi	a0,a0,-854 # 800217c0 <itable>
    80003b1e:	ffffd097          	auipc	ra,0xffffd
    80003b22:	0cc080e7          	jalr	204(ra) # 80000bea <acquire>
  ip->ref++;
    80003b26:	449c                	lw	a5,8(s1)
    80003b28:	2785                	addiw	a5,a5,1
    80003b2a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003b2c:	0001e517          	auipc	a0,0x1e
    80003b30:	c9450513          	addi	a0,a0,-876 # 800217c0 <itable>
    80003b34:	ffffd097          	auipc	ra,0xffffd
    80003b38:	16a080e7          	jalr	362(ra) # 80000c9e <release>
}
    80003b3c:	8526                	mv	a0,s1
    80003b3e:	60e2                	ld	ra,24(sp)
    80003b40:	6442                	ld	s0,16(sp)
    80003b42:	64a2                	ld	s1,8(sp)
    80003b44:	6105                	addi	sp,sp,32
    80003b46:	8082                	ret

0000000080003b48 <ilock>:
{
    80003b48:	1101                	addi	sp,sp,-32
    80003b4a:	ec06                	sd	ra,24(sp)
    80003b4c:	e822                	sd	s0,16(sp)
    80003b4e:	e426                	sd	s1,8(sp)
    80003b50:	e04a                	sd	s2,0(sp)
    80003b52:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003b54:	c115                	beqz	a0,80003b78 <ilock+0x30>
    80003b56:	84aa                	mv	s1,a0
    80003b58:	451c                	lw	a5,8(a0)
    80003b5a:	00f05f63          	blez	a5,80003b78 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003b5e:	0541                	addi	a0,a0,16
    80003b60:	00001097          	auipc	ra,0x1
    80003b64:	ca2080e7          	jalr	-862(ra) # 80004802 <acquiresleep>
  if(ip->valid == 0){
    80003b68:	40bc                	lw	a5,64(s1)
    80003b6a:	cf99                	beqz	a5,80003b88 <ilock+0x40>
}
    80003b6c:	60e2                	ld	ra,24(sp)
    80003b6e:	6442                	ld	s0,16(sp)
    80003b70:	64a2                	ld	s1,8(sp)
    80003b72:	6902                	ld	s2,0(sp)
    80003b74:	6105                	addi	sp,sp,32
    80003b76:	8082                	ret
    panic("ilock");
    80003b78:	00005517          	auipc	a0,0x5
    80003b7c:	b9850513          	addi	a0,a0,-1128 # 80008710 <syscalls+0x1a0>
    80003b80:	ffffd097          	auipc	ra,0xffffd
    80003b84:	9c4080e7          	jalr	-1596(ra) # 80000544 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b88:	40dc                	lw	a5,4(s1)
    80003b8a:	0047d79b          	srliw	a5,a5,0x4
    80003b8e:	0001e597          	auipc	a1,0x1e
    80003b92:	c2a5a583          	lw	a1,-982(a1) # 800217b8 <sb+0x18>
    80003b96:	9dbd                	addw	a1,a1,a5
    80003b98:	4088                	lw	a0,0(s1)
    80003b9a:	fffff097          	auipc	ra,0xfffff
    80003b9e:	794080e7          	jalr	1940(ra) # 8000332e <bread>
    80003ba2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003ba4:	05850593          	addi	a1,a0,88
    80003ba8:	40dc                	lw	a5,4(s1)
    80003baa:	8bbd                	andi	a5,a5,15
    80003bac:	079a                	slli	a5,a5,0x6
    80003bae:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003bb0:	00059783          	lh	a5,0(a1)
    80003bb4:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003bb8:	00259783          	lh	a5,2(a1)
    80003bbc:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003bc0:	00459783          	lh	a5,4(a1)
    80003bc4:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003bc8:	00659783          	lh	a5,6(a1)
    80003bcc:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003bd0:	459c                	lw	a5,8(a1)
    80003bd2:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003bd4:	03400613          	li	a2,52
    80003bd8:	05b1                	addi	a1,a1,12
    80003bda:	05048513          	addi	a0,s1,80
    80003bde:	ffffd097          	auipc	ra,0xffffd
    80003be2:	168080e7          	jalr	360(ra) # 80000d46 <memmove>
    brelse(bp);
    80003be6:	854a                	mv	a0,s2
    80003be8:	00000097          	auipc	ra,0x0
    80003bec:	876080e7          	jalr	-1930(ra) # 8000345e <brelse>
    ip->valid = 1;
    80003bf0:	4785                	li	a5,1
    80003bf2:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003bf4:	04449783          	lh	a5,68(s1)
    80003bf8:	fbb5                	bnez	a5,80003b6c <ilock+0x24>
      panic("ilock: no type");
    80003bfa:	00005517          	auipc	a0,0x5
    80003bfe:	b1e50513          	addi	a0,a0,-1250 # 80008718 <syscalls+0x1a8>
    80003c02:	ffffd097          	auipc	ra,0xffffd
    80003c06:	942080e7          	jalr	-1726(ra) # 80000544 <panic>

0000000080003c0a <iunlock>:
{
    80003c0a:	1101                	addi	sp,sp,-32
    80003c0c:	ec06                	sd	ra,24(sp)
    80003c0e:	e822                	sd	s0,16(sp)
    80003c10:	e426                	sd	s1,8(sp)
    80003c12:	e04a                	sd	s2,0(sp)
    80003c14:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003c16:	c905                	beqz	a0,80003c46 <iunlock+0x3c>
    80003c18:	84aa                	mv	s1,a0
    80003c1a:	01050913          	addi	s2,a0,16
    80003c1e:	854a                	mv	a0,s2
    80003c20:	00001097          	auipc	ra,0x1
    80003c24:	c7c080e7          	jalr	-900(ra) # 8000489c <holdingsleep>
    80003c28:	cd19                	beqz	a0,80003c46 <iunlock+0x3c>
    80003c2a:	449c                	lw	a5,8(s1)
    80003c2c:	00f05d63          	blez	a5,80003c46 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003c30:	854a                	mv	a0,s2
    80003c32:	00001097          	auipc	ra,0x1
    80003c36:	c26080e7          	jalr	-986(ra) # 80004858 <releasesleep>
}
    80003c3a:	60e2                	ld	ra,24(sp)
    80003c3c:	6442                	ld	s0,16(sp)
    80003c3e:	64a2                	ld	s1,8(sp)
    80003c40:	6902                	ld	s2,0(sp)
    80003c42:	6105                	addi	sp,sp,32
    80003c44:	8082                	ret
    panic("iunlock");
    80003c46:	00005517          	auipc	a0,0x5
    80003c4a:	ae250513          	addi	a0,a0,-1310 # 80008728 <syscalls+0x1b8>
    80003c4e:	ffffd097          	auipc	ra,0xffffd
    80003c52:	8f6080e7          	jalr	-1802(ra) # 80000544 <panic>

0000000080003c56 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003c56:	7179                	addi	sp,sp,-48
    80003c58:	f406                	sd	ra,40(sp)
    80003c5a:	f022                	sd	s0,32(sp)
    80003c5c:	ec26                	sd	s1,24(sp)
    80003c5e:	e84a                	sd	s2,16(sp)
    80003c60:	e44e                	sd	s3,8(sp)
    80003c62:	e052                	sd	s4,0(sp)
    80003c64:	1800                	addi	s0,sp,48
    80003c66:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003c68:	05050493          	addi	s1,a0,80
    80003c6c:	08050913          	addi	s2,a0,128
    80003c70:	a021                	j	80003c78 <itrunc+0x22>
    80003c72:	0491                	addi	s1,s1,4
    80003c74:	01248d63          	beq	s1,s2,80003c8e <itrunc+0x38>
    if(ip->addrs[i]){
    80003c78:	408c                	lw	a1,0(s1)
    80003c7a:	dde5                	beqz	a1,80003c72 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003c7c:	0009a503          	lw	a0,0(s3)
    80003c80:	00000097          	auipc	ra,0x0
    80003c84:	8f4080e7          	jalr	-1804(ra) # 80003574 <bfree>
      ip->addrs[i] = 0;
    80003c88:	0004a023          	sw	zero,0(s1)
    80003c8c:	b7dd                	j	80003c72 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003c8e:	0809a583          	lw	a1,128(s3)
    80003c92:	e185                	bnez	a1,80003cb2 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003c94:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003c98:	854e                	mv	a0,s3
    80003c9a:	00000097          	auipc	ra,0x0
    80003c9e:	de4080e7          	jalr	-540(ra) # 80003a7e <iupdate>
}
    80003ca2:	70a2                	ld	ra,40(sp)
    80003ca4:	7402                	ld	s0,32(sp)
    80003ca6:	64e2                	ld	s1,24(sp)
    80003ca8:	6942                	ld	s2,16(sp)
    80003caa:	69a2                	ld	s3,8(sp)
    80003cac:	6a02                	ld	s4,0(sp)
    80003cae:	6145                	addi	sp,sp,48
    80003cb0:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003cb2:	0009a503          	lw	a0,0(s3)
    80003cb6:	fffff097          	auipc	ra,0xfffff
    80003cba:	678080e7          	jalr	1656(ra) # 8000332e <bread>
    80003cbe:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003cc0:	05850493          	addi	s1,a0,88
    80003cc4:	45850913          	addi	s2,a0,1112
    80003cc8:	a811                	j	80003cdc <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003cca:	0009a503          	lw	a0,0(s3)
    80003cce:	00000097          	auipc	ra,0x0
    80003cd2:	8a6080e7          	jalr	-1882(ra) # 80003574 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003cd6:	0491                	addi	s1,s1,4
    80003cd8:	01248563          	beq	s1,s2,80003ce2 <itrunc+0x8c>
      if(a[j])
    80003cdc:	408c                	lw	a1,0(s1)
    80003cde:	dde5                	beqz	a1,80003cd6 <itrunc+0x80>
    80003ce0:	b7ed                	j	80003cca <itrunc+0x74>
    brelse(bp);
    80003ce2:	8552                	mv	a0,s4
    80003ce4:	fffff097          	auipc	ra,0xfffff
    80003ce8:	77a080e7          	jalr	1914(ra) # 8000345e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003cec:	0809a583          	lw	a1,128(s3)
    80003cf0:	0009a503          	lw	a0,0(s3)
    80003cf4:	00000097          	auipc	ra,0x0
    80003cf8:	880080e7          	jalr	-1920(ra) # 80003574 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003cfc:	0809a023          	sw	zero,128(s3)
    80003d00:	bf51                	j	80003c94 <itrunc+0x3e>

0000000080003d02 <iput>:
{
    80003d02:	1101                	addi	sp,sp,-32
    80003d04:	ec06                	sd	ra,24(sp)
    80003d06:	e822                	sd	s0,16(sp)
    80003d08:	e426                	sd	s1,8(sp)
    80003d0a:	e04a                	sd	s2,0(sp)
    80003d0c:	1000                	addi	s0,sp,32
    80003d0e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003d10:	0001e517          	auipc	a0,0x1e
    80003d14:	ab050513          	addi	a0,a0,-1360 # 800217c0 <itable>
    80003d18:	ffffd097          	auipc	ra,0xffffd
    80003d1c:	ed2080e7          	jalr	-302(ra) # 80000bea <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003d20:	4498                	lw	a4,8(s1)
    80003d22:	4785                	li	a5,1
    80003d24:	02f70363          	beq	a4,a5,80003d4a <iput+0x48>
  ip->ref--;
    80003d28:	449c                	lw	a5,8(s1)
    80003d2a:	37fd                	addiw	a5,a5,-1
    80003d2c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003d2e:	0001e517          	auipc	a0,0x1e
    80003d32:	a9250513          	addi	a0,a0,-1390 # 800217c0 <itable>
    80003d36:	ffffd097          	auipc	ra,0xffffd
    80003d3a:	f68080e7          	jalr	-152(ra) # 80000c9e <release>
}
    80003d3e:	60e2                	ld	ra,24(sp)
    80003d40:	6442                	ld	s0,16(sp)
    80003d42:	64a2                	ld	s1,8(sp)
    80003d44:	6902                	ld	s2,0(sp)
    80003d46:	6105                	addi	sp,sp,32
    80003d48:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003d4a:	40bc                	lw	a5,64(s1)
    80003d4c:	dff1                	beqz	a5,80003d28 <iput+0x26>
    80003d4e:	04a49783          	lh	a5,74(s1)
    80003d52:	fbf9                	bnez	a5,80003d28 <iput+0x26>
    acquiresleep(&ip->lock);
    80003d54:	01048913          	addi	s2,s1,16
    80003d58:	854a                	mv	a0,s2
    80003d5a:	00001097          	auipc	ra,0x1
    80003d5e:	aa8080e7          	jalr	-1368(ra) # 80004802 <acquiresleep>
    release(&itable.lock);
    80003d62:	0001e517          	auipc	a0,0x1e
    80003d66:	a5e50513          	addi	a0,a0,-1442 # 800217c0 <itable>
    80003d6a:	ffffd097          	auipc	ra,0xffffd
    80003d6e:	f34080e7          	jalr	-204(ra) # 80000c9e <release>
    itrunc(ip);
    80003d72:	8526                	mv	a0,s1
    80003d74:	00000097          	auipc	ra,0x0
    80003d78:	ee2080e7          	jalr	-286(ra) # 80003c56 <itrunc>
    ip->type = 0;
    80003d7c:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003d80:	8526                	mv	a0,s1
    80003d82:	00000097          	auipc	ra,0x0
    80003d86:	cfc080e7          	jalr	-772(ra) # 80003a7e <iupdate>
    ip->valid = 0;
    80003d8a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003d8e:	854a                	mv	a0,s2
    80003d90:	00001097          	auipc	ra,0x1
    80003d94:	ac8080e7          	jalr	-1336(ra) # 80004858 <releasesleep>
    acquire(&itable.lock);
    80003d98:	0001e517          	auipc	a0,0x1e
    80003d9c:	a2850513          	addi	a0,a0,-1496 # 800217c0 <itable>
    80003da0:	ffffd097          	auipc	ra,0xffffd
    80003da4:	e4a080e7          	jalr	-438(ra) # 80000bea <acquire>
    80003da8:	b741                	j	80003d28 <iput+0x26>

0000000080003daa <iunlockput>:
{
    80003daa:	1101                	addi	sp,sp,-32
    80003dac:	ec06                	sd	ra,24(sp)
    80003dae:	e822                	sd	s0,16(sp)
    80003db0:	e426                	sd	s1,8(sp)
    80003db2:	1000                	addi	s0,sp,32
    80003db4:	84aa                	mv	s1,a0
  iunlock(ip);
    80003db6:	00000097          	auipc	ra,0x0
    80003dba:	e54080e7          	jalr	-428(ra) # 80003c0a <iunlock>
  iput(ip);
    80003dbe:	8526                	mv	a0,s1
    80003dc0:	00000097          	auipc	ra,0x0
    80003dc4:	f42080e7          	jalr	-190(ra) # 80003d02 <iput>
}
    80003dc8:	60e2                	ld	ra,24(sp)
    80003dca:	6442                	ld	s0,16(sp)
    80003dcc:	64a2                	ld	s1,8(sp)
    80003dce:	6105                	addi	sp,sp,32
    80003dd0:	8082                	ret

0000000080003dd2 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003dd2:	1141                	addi	sp,sp,-16
    80003dd4:	e422                	sd	s0,8(sp)
    80003dd6:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003dd8:	411c                	lw	a5,0(a0)
    80003dda:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003ddc:	415c                	lw	a5,4(a0)
    80003dde:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003de0:	04451783          	lh	a5,68(a0)
    80003de4:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003de8:	04a51783          	lh	a5,74(a0)
    80003dec:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003df0:	04c56783          	lwu	a5,76(a0)
    80003df4:	e99c                	sd	a5,16(a1)
}
    80003df6:	6422                	ld	s0,8(sp)
    80003df8:	0141                	addi	sp,sp,16
    80003dfa:	8082                	ret

0000000080003dfc <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003dfc:	457c                	lw	a5,76(a0)
    80003dfe:	0ed7e963          	bltu	a5,a3,80003ef0 <readi+0xf4>
{
    80003e02:	7159                	addi	sp,sp,-112
    80003e04:	f486                	sd	ra,104(sp)
    80003e06:	f0a2                	sd	s0,96(sp)
    80003e08:	eca6                	sd	s1,88(sp)
    80003e0a:	e8ca                	sd	s2,80(sp)
    80003e0c:	e4ce                	sd	s3,72(sp)
    80003e0e:	e0d2                	sd	s4,64(sp)
    80003e10:	fc56                	sd	s5,56(sp)
    80003e12:	f85a                	sd	s6,48(sp)
    80003e14:	f45e                	sd	s7,40(sp)
    80003e16:	f062                	sd	s8,32(sp)
    80003e18:	ec66                	sd	s9,24(sp)
    80003e1a:	e86a                	sd	s10,16(sp)
    80003e1c:	e46e                	sd	s11,8(sp)
    80003e1e:	1880                	addi	s0,sp,112
    80003e20:	8b2a                	mv	s6,a0
    80003e22:	8bae                	mv	s7,a1
    80003e24:	8a32                	mv	s4,a2
    80003e26:	84b6                	mv	s1,a3
    80003e28:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003e2a:	9f35                	addw	a4,a4,a3
    return 0;
    80003e2c:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003e2e:	0ad76063          	bltu	a4,a3,80003ece <readi+0xd2>
  if(off + n > ip->size)
    80003e32:	00e7f463          	bgeu	a5,a4,80003e3a <readi+0x3e>
    n = ip->size - off;
    80003e36:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e3a:	0a0a8963          	beqz	s5,80003eec <readi+0xf0>
    80003e3e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e40:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003e44:	5c7d                	li	s8,-1
    80003e46:	a82d                	j	80003e80 <readi+0x84>
    80003e48:	020d1d93          	slli	s11,s10,0x20
    80003e4c:	020ddd93          	srli	s11,s11,0x20
    80003e50:	05890613          	addi	a2,s2,88
    80003e54:	86ee                	mv	a3,s11
    80003e56:	963a                	add	a2,a2,a4
    80003e58:	85d2                	mv	a1,s4
    80003e5a:	855e                	mv	a0,s7
    80003e5c:	fffff097          	auipc	ra,0xfffff
    80003e60:	940080e7          	jalr	-1728(ra) # 8000279c <either_copyout>
    80003e64:	05850d63          	beq	a0,s8,80003ebe <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003e68:	854a                	mv	a0,s2
    80003e6a:	fffff097          	auipc	ra,0xfffff
    80003e6e:	5f4080e7          	jalr	1524(ra) # 8000345e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e72:	013d09bb          	addw	s3,s10,s3
    80003e76:	009d04bb          	addw	s1,s10,s1
    80003e7a:	9a6e                	add	s4,s4,s11
    80003e7c:	0559f763          	bgeu	s3,s5,80003eca <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003e80:	00a4d59b          	srliw	a1,s1,0xa
    80003e84:	855a                	mv	a0,s6
    80003e86:	00000097          	auipc	ra,0x0
    80003e8a:	8a2080e7          	jalr	-1886(ra) # 80003728 <bmap>
    80003e8e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003e92:	cd85                	beqz	a1,80003eca <readi+0xce>
    bp = bread(ip->dev, addr);
    80003e94:	000b2503          	lw	a0,0(s6)
    80003e98:	fffff097          	auipc	ra,0xfffff
    80003e9c:	496080e7          	jalr	1174(ra) # 8000332e <bread>
    80003ea0:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ea2:	3ff4f713          	andi	a4,s1,1023
    80003ea6:	40ec87bb          	subw	a5,s9,a4
    80003eaa:	413a86bb          	subw	a3,s5,s3
    80003eae:	8d3e                	mv	s10,a5
    80003eb0:	2781                	sext.w	a5,a5
    80003eb2:	0006861b          	sext.w	a2,a3
    80003eb6:	f8f679e3          	bgeu	a2,a5,80003e48 <readi+0x4c>
    80003eba:	8d36                	mv	s10,a3
    80003ebc:	b771                	j	80003e48 <readi+0x4c>
      brelse(bp);
    80003ebe:	854a                	mv	a0,s2
    80003ec0:	fffff097          	auipc	ra,0xfffff
    80003ec4:	59e080e7          	jalr	1438(ra) # 8000345e <brelse>
      tot = -1;
    80003ec8:	59fd                	li	s3,-1
  }
  return tot;
    80003eca:	0009851b          	sext.w	a0,s3
}
    80003ece:	70a6                	ld	ra,104(sp)
    80003ed0:	7406                	ld	s0,96(sp)
    80003ed2:	64e6                	ld	s1,88(sp)
    80003ed4:	6946                	ld	s2,80(sp)
    80003ed6:	69a6                	ld	s3,72(sp)
    80003ed8:	6a06                	ld	s4,64(sp)
    80003eda:	7ae2                	ld	s5,56(sp)
    80003edc:	7b42                	ld	s6,48(sp)
    80003ede:	7ba2                	ld	s7,40(sp)
    80003ee0:	7c02                	ld	s8,32(sp)
    80003ee2:	6ce2                	ld	s9,24(sp)
    80003ee4:	6d42                	ld	s10,16(sp)
    80003ee6:	6da2                	ld	s11,8(sp)
    80003ee8:	6165                	addi	sp,sp,112
    80003eea:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003eec:	89d6                	mv	s3,s5
    80003eee:	bff1                	j	80003eca <readi+0xce>
    return 0;
    80003ef0:	4501                	li	a0,0
}
    80003ef2:	8082                	ret

0000000080003ef4 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003ef4:	457c                	lw	a5,76(a0)
    80003ef6:	10d7e863          	bltu	a5,a3,80004006 <writei+0x112>
{
    80003efa:	7159                	addi	sp,sp,-112
    80003efc:	f486                	sd	ra,104(sp)
    80003efe:	f0a2                	sd	s0,96(sp)
    80003f00:	eca6                	sd	s1,88(sp)
    80003f02:	e8ca                	sd	s2,80(sp)
    80003f04:	e4ce                	sd	s3,72(sp)
    80003f06:	e0d2                	sd	s4,64(sp)
    80003f08:	fc56                	sd	s5,56(sp)
    80003f0a:	f85a                	sd	s6,48(sp)
    80003f0c:	f45e                	sd	s7,40(sp)
    80003f0e:	f062                	sd	s8,32(sp)
    80003f10:	ec66                	sd	s9,24(sp)
    80003f12:	e86a                	sd	s10,16(sp)
    80003f14:	e46e                	sd	s11,8(sp)
    80003f16:	1880                	addi	s0,sp,112
    80003f18:	8aaa                	mv	s5,a0
    80003f1a:	8bae                	mv	s7,a1
    80003f1c:	8a32                	mv	s4,a2
    80003f1e:	8936                	mv	s2,a3
    80003f20:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003f22:	00e687bb          	addw	a5,a3,a4
    80003f26:	0ed7e263          	bltu	a5,a3,8000400a <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003f2a:	00043737          	lui	a4,0x43
    80003f2e:	0ef76063          	bltu	a4,a5,8000400e <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f32:	0c0b0863          	beqz	s6,80004002 <writei+0x10e>
    80003f36:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f38:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003f3c:	5c7d                	li	s8,-1
    80003f3e:	a091                	j	80003f82 <writei+0x8e>
    80003f40:	020d1d93          	slli	s11,s10,0x20
    80003f44:	020ddd93          	srli	s11,s11,0x20
    80003f48:	05848513          	addi	a0,s1,88
    80003f4c:	86ee                	mv	a3,s11
    80003f4e:	8652                	mv	a2,s4
    80003f50:	85de                	mv	a1,s7
    80003f52:	953a                	add	a0,a0,a4
    80003f54:	fffff097          	auipc	ra,0xfffff
    80003f58:	89e080e7          	jalr	-1890(ra) # 800027f2 <either_copyin>
    80003f5c:	07850263          	beq	a0,s8,80003fc0 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003f60:	8526                	mv	a0,s1
    80003f62:	00000097          	auipc	ra,0x0
    80003f66:	780080e7          	jalr	1920(ra) # 800046e2 <log_write>
    brelse(bp);
    80003f6a:	8526                	mv	a0,s1
    80003f6c:	fffff097          	auipc	ra,0xfffff
    80003f70:	4f2080e7          	jalr	1266(ra) # 8000345e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f74:	013d09bb          	addw	s3,s10,s3
    80003f78:	012d093b          	addw	s2,s10,s2
    80003f7c:	9a6e                	add	s4,s4,s11
    80003f7e:	0569f663          	bgeu	s3,s6,80003fca <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003f82:	00a9559b          	srliw	a1,s2,0xa
    80003f86:	8556                	mv	a0,s5
    80003f88:	fffff097          	auipc	ra,0xfffff
    80003f8c:	7a0080e7          	jalr	1952(ra) # 80003728 <bmap>
    80003f90:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003f94:	c99d                	beqz	a1,80003fca <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003f96:	000aa503          	lw	a0,0(s5)
    80003f9a:	fffff097          	auipc	ra,0xfffff
    80003f9e:	394080e7          	jalr	916(ra) # 8000332e <bread>
    80003fa2:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fa4:	3ff97713          	andi	a4,s2,1023
    80003fa8:	40ec87bb          	subw	a5,s9,a4
    80003fac:	413b06bb          	subw	a3,s6,s3
    80003fb0:	8d3e                	mv	s10,a5
    80003fb2:	2781                	sext.w	a5,a5
    80003fb4:	0006861b          	sext.w	a2,a3
    80003fb8:	f8f674e3          	bgeu	a2,a5,80003f40 <writei+0x4c>
    80003fbc:	8d36                	mv	s10,a3
    80003fbe:	b749                	j	80003f40 <writei+0x4c>
      brelse(bp);
    80003fc0:	8526                	mv	a0,s1
    80003fc2:	fffff097          	auipc	ra,0xfffff
    80003fc6:	49c080e7          	jalr	1180(ra) # 8000345e <brelse>
  }

  if(off > ip->size)
    80003fca:	04caa783          	lw	a5,76(s5)
    80003fce:	0127f463          	bgeu	a5,s2,80003fd6 <writei+0xe2>
    ip->size = off;
    80003fd2:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003fd6:	8556                	mv	a0,s5
    80003fd8:	00000097          	auipc	ra,0x0
    80003fdc:	aa6080e7          	jalr	-1370(ra) # 80003a7e <iupdate>

  return tot;
    80003fe0:	0009851b          	sext.w	a0,s3
}
    80003fe4:	70a6                	ld	ra,104(sp)
    80003fe6:	7406                	ld	s0,96(sp)
    80003fe8:	64e6                	ld	s1,88(sp)
    80003fea:	6946                	ld	s2,80(sp)
    80003fec:	69a6                	ld	s3,72(sp)
    80003fee:	6a06                	ld	s4,64(sp)
    80003ff0:	7ae2                	ld	s5,56(sp)
    80003ff2:	7b42                	ld	s6,48(sp)
    80003ff4:	7ba2                	ld	s7,40(sp)
    80003ff6:	7c02                	ld	s8,32(sp)
    80003ff8:	6ce2                	ld	s9,24(sp)
    80003ffa:	6d42                	ld	s10,16(sp)
    80003ffc:	6da2                	ld	s11,8(sp)
    80003ffe:	6165                	addi	sp,sp,112
    80004000:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004002:	89da                	mv	s3,s6
    80004004:	bfc9                	j	80003fd6 <writei+0xe2>
    return -1;
    80004006:	557d                	li	a0,-1
}
    80004008:	8082                	ret
    return -1;
    8000400a:	557d                	li	a0,-1
    8000400c:	bfe1                	j	80003fe4 <writei+0xf0>
    return -1;
    8000400e:	557d                	li	a0,-1
    80004010:	bfd1                	j	80003fe4 <writei+0xf0>

0000000080004012 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004012:	1141                	addi	sp,sp,-16
    80004014:	e406                	sd	ra,8(sp)
    80004016:	e022                	sd	s0,0(sp)
    80004018:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000401a:	4639                	li	a2,14
    8000401c:	ffffd097          	auipc	ra,0xffffd
    80004020:	da2080e7          	jalr	-606(ra) # 80000dbe <strncmp>
}
    80004024:	60a2                	ld	ra,8(sp)
    80004026:	6402                	ld	s0,0(sp)
    80004028:	0141                	addi	sp,sp,16
    8000402a:	8082                	ret

000000008000402c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000402c:	7139                	addi	sp,sp,-64
    8000402e:	fc06                	sd	ra,56(sp)
    80004030:	f822                	sd	s0,48(sp)
    80004032:	f426                	sd	s1,40(sp)
    80004034:	f04a                	sd	s2,32(sp)
    80004036:	ec4e                	sd	s3,24(sp)
    80004038:	e852                	sd	s4,16(sp)
    8000403a:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000403c:	04451703          	lh	a4,68(a0)
    80004040:	4785                	li	a5,1
    80004042:	00f71a63          	bne	a4,a5,80004056 <dirlookup+0x2a>
    80004046:	892a                	mv	s2,a0
    80004048:	89ae                	mv	s3,a1
    8000404a:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000404c:	457c                	lw	a5,76(a0)
    8000404e:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004050:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004052:	e79d                	bnez	a5,80004080 <dirlookup+0x54>
    80004054:	a8a5                	j	800040cc <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004056:	00004517          	auipc	a0,0x4
    8000405a:	6da50513          	addi	a0,a0,1754 # 80008730 <syscalls+0x1c0>
    8000405e:	ffffc097          	auipc	ra,0xffffc
    80004062:	4e6080e7          	jalr	1254(ra) # 80000544 <panic>
      panic("dirlookup read");
    80004066:	00004517          	auipc	a0,0x4
    8000406a:	6e250513          	addi	a0,a0,1762 # 80008748 <syscalls+0x1d8>
    8000406e:	ffffc097          	auipc	ra,0xffffc
    80004072:	4d6080e7          	jalr	1238(ra) # 80000544 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004076:	24c1                	addiw	s1,s1,16
    80004078:	04c92783          	lw	a5,76(s2)
    8000407c:	04f4f763          	bgeu	s1,a5,800040ca <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004080:	4741                	li	a4,16
    80004082:	86a6                	mv	a3,s1
    80004084:	fc040613          	addi	a2,s0,-64
    80004088:	4581                	li	a1,0
    8000408a:	854a                	mv	a0,s2
    8000408c:	00000097          	auipc	ra,0x0
    80004090:	d70080e7          	jalr	-656(ra) # 80003dfc <readi>
    80004094:	47c1                	li	a5,16
    80004096:	fcf518e3          	bne	a0,a5,80004066 <dirlookup+0x3a>
    if(de.inum == 0)
    8000409a:	fc045783          	lhu	a5,-64(s0)
    8000409e:	dfe1                	beqz	a5,80004076 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800040a0:	fc240593          	addi	a1,s0,-62
    800040a4:	854e                	mv	a0,s3
    800040a6:	00000097          	auipc	ra,0x0
    800040aa:	f6c080e7          	jalr	-148(ra) # 80004012 <namecmp>
    800040ae:	f561                	bnez	a0,80004076 <dirlookup+0x4a>
      if(poff)
    800040b0:	000a0463          	beqz	s4,800040b8 <dirlookup+0x8c>
        *poff = off;
    800040b4:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800040b8:	fc045583          	lhu	a1,-64(s0)
    800040bc:	00092503          	lw	a0,0(s2)
    800040c0:	fffff097          	auipc	ra,0xfffff
    800040c4:	750080e7          	jalr	1872(ra) # 80003810 <iget>
    800040c8:	a011                	j	800040cc <dirlookup+0xa0>
  return 0;
    800040ca:	4501                	li	a0,0
}
    800040cc:	70e2                	ld	ra,56(sp)
    800040ce:	7442                	ld	s0,48(sp)
    800040d0:	74a2                	ld	s1,40(sp)
    800040d2:	7902                	ld	s2,32(sp)
    800040d4:	69e2                	ld	s3,24(sp)
    800040d6:	6a42                	ld	s4,16(sp)
    800040d8:	6121                	addi	sp,sp,64
    800040da:	8082                	ret

00000000800040dc <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800040dc:	711d                	addi	sp,sp,-96
    800040de:	ec86                	sd	ra,88(sp)
    800040e0:	e8a2                	sd	s0,80(sp)
    800040e2:	e4a6                	sd	s1,72(sp)
    800040e4:	e0ca                	sd	s2,64(sp)
    800040e6:	fc4e                	sd	s3,56(sp)
    800040e8:	f852                	sd	s4,48(sp)
    800040ea:	f456                	sd	s5,40(sp)
    800040ec:	f05a                	sd	s6,32(sp)
    800040ee:	ec5e                	sd	s7,24(sp)
    800040f0:	e862                	sd	s8,16(sp)
    800040f2:	e466                	sd	s9,8(sp)
    800040f4:	1080                	addi	s0,sp,96
    800040f6:	84aa                	mv	s1,a0
    800040f8:	8b2e                	mv	s6,a1
    800040fa:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800040fc:	00054703          	lbu	a4,0(a0)
    80004100:	02f00793          	li	a5,47
    80004104:	02f70363          	beq	a4,a5,8000412a <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004108:	ffffe097          	auipc	ra,0xffffe
    8000410c:	aea080e7          	jalr	-1302(ra) # 80001bf2 <myproc>
    80004110:	15853503          	ld	a0,344(a0)
    80004114:	00000097          	auipc	ra,0x0
    80004118:	9f6080e7          	jalr	-1546(ra) # 80003b0a <idup>
    8000411c:	89aa                	mv	s3,a0
  while(*path == '/')
    8000411e:	02f00913          	li	s2,47
  len = path - s;
    80004122:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80004124:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004126:	4c05                	li	s8,1
    80004128:	a865                	j	800041e0 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    8000412a:	4585                	li	a1,1
    8000412c:	4505                	li	a0,1
    8000412e:	fffff097          	auipc	ra,0xfffff
    80004132:	6e2080e7          	jalr	1762(ra) # 80003810 <iget>
    80004136:	89aa                	mv	s3,a0
    80004138:	b7dd                	j	8000411e <namex+0x42>
      iunlockput(ip);
    8000413a:	854e                	mv	a0,s3
    8000413c:	00000097          	auipc	ra,0x0
    80004140:	c6e080e7          	jalr	-914(ra) # 80003daa <iunlockput>
      return 0;
    80004144:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004146:	854e                	mv	a0,s3
    80004148:	60e6                	ld	ra,88(sp)
    8000414a:	6446                	ld	s0,80(sp)
    8000414c:	64a6                	ld	s1,72(sp)
    8000414e:	6906                	ld	s2,64(sp)
    80004150:	79e2                	ld	s3,56(sp)
    80004152:	7a42                	ld	s4,48(sp)
    80004154:	7aa2                	ld	s5,40(sp)
    80004156:	7b02                	ld	s6,32(sp)
    80004158:	6be2                	ld	s7,24(sp)
    8000415a:	6c42                	ld	s8,16(sp)
    8000415c:	6ca2                	ld	s9,8(sp)
    8000415e:	6125                	addi	sp,sp,96
    80004160:	8082                	ret
      iunlock(ip);
    80004162:	854e                	mv	a0,s3
    80004164:	00000097          	auipc	ra,0x0
    80004168:	aa6080e7          	jalr	-1370(ra) # 80003c0a <iunlock>
      return ip;
    8000416c:	bfe9                	j	80004146 <namex+0x6a>
      iunlockput(ip);
    8000416e:	854e                	mv	a0,s3
    80004170:	00000097          	auipc	ra,0x0
    80004174:	c3a080e7          	jalr	-966(ra) # 80003daa <iunlockput>
      return 0;
    80004178:	89d2                	mv	s3,s4
    8000417a:	b7f1                	j	80004146 <namex+0x6a>
  len = path - s;
    8000417c:	40b48633          	sub	a2,s1,a1
    80004180:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80004184:	094cd463          	bge	s9,s4,8000420c <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004188:	4639                	li	a2,14
    8000418a:	8556                	mv	a0,s5
    8000418c:	ffffd097          	auipc	ra,0xffffd
    80004190:	bba080e7          	jalr	-1094(ra) # 80000d46 <memmove>
  while(*path == '/')
    80004194:	0004c783          	lbu	a5,0(s1)
    80004198:	01279763          	bne	a5,s2,800041a6 <namex+0xca>
    path++;
    8000419c:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000419e:	0004c783          	lbu	a5,0(s1)
    800041a2:	ff278de3          	beq	a5,s2,8000419c <namex+0xc0>
    ilock(ip);
    800041a6:	854e                	mv	a0,s3
    800041a8:	00000097          	auipc	ra,0x0
    800041ac:	9a0080e7          	jalr	-1632(ra) # 80003b48 <ilock>
    if(ip->type != T_DIR){
    800041b0:	04499783          	lh	a5,68(s3)
    800041b4:	f98793e3          	bne	a5,s8,8000413a <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800041b8:	000b0563          	beqz	s6,800041c2 <namex+0xe6>
    800041bc:	0004c783          	lbu	a5,0(s1)
    800041c0:	d3cd                	beqz	a5,80004162 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800041c2:	865e                	mv	a2,s7
    800041c4:	85d6                	mv	a1,s5
    800041c6:	854e                	mv	a0,s3
    800041c8:	00000097          	auipc	ra,0x0
    800041cc:	e64080e7          	jalr	-412(ra) # 8000402c <dirlookup>
    800041d0:	8a2a                	mv	s4,a0
    800041d2:	dd51                	beqz	a0,8000416e <namex+0x92>
    iunlockput(ip);
    800041d4:	854e                	mv	a0,s3
    800041d6:	00000097          	auipc	ra,0x0
    800041da:	bd4080e7          	jalr	-1068(ra) # 80003daa <iunlockput>
    ip = next;
    800041de:	89d2                	mv	s3,s4
  while(*path == '/')
    800041e0:	0004c783          	lbu	a5,0(s1)
    800041e4:	05279763          	bne	a5,s2,80004232 <namex+0x156>
    path++;
    800041e8:	0485                	addi	s1,s1,1
  while(*path == '/')
    800041ea:	0004c783          	lbu	a5,0(s1)
    800041ee:	ff278de3          	beq	a5,s2,800041e8 <namex+0x10c>
  if(*path == 0)
    800041f2:	c79d                	beqz	a5,80004220 <namex+0x144>
    path++;
    800041f4:	85a6                	mv	a1,s1
  len = path - s;
    800041f6:	8a5e                	mv	s4,s7
    800041f8:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    800041fa:	01278963          	beq	a5,s2,8000420c <namex+0x130>
    800041fe:	dfbd                	beqz	a5,8000417c <namex+0xa0>
    path++;
    80004200:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004202:	0004c783          	lbu	a5,0(s1)
    80004206:	ff279ce3          	bne	a5,s2,800041fe <namex+0x122>
    8000420a:	bf8d                	j	8000417c <namex+0xa0>
    memmove(name, s, len);
    8000420c:	2601                	sext.w	a2,a2
    8000420e:	8556                	mv	a0,s5
    80004210:	ffffd097          	auipc	ra,0xffffd
    80004214:	b36080e7          	jalr	-1226(ra) # 80000d46 <memmove>
    name[len] = 0;
    80004218:	9a56                	add	s4,s4,s5
    8000421a:	000a0023          	sb	zero,0(s4)
    8000421e:	bf9d                	j	80004194 <namex+0xb8>
  if(nameiparent){
    80004220:	f20b03e3          	beqz	s6,80004146 <namex+0x6a>
    iput(ip);
    80004224:	854e                	mv	a0,s3
    80004226:	00000097          	auipc	ra,0x0
    8000422a:	adc080e7          	jalr	-1316(ra) # 80003d02 <iput>
    return 0;
    8000422e:	4981                	li	s3,0
    80004230:	bf19                	j	80004146 <namex+0x6a>
  if(*path == 0)
    80004232:	d7fd                	beqz	a5,80004220 <namex+0x144>
  while(*path != '/' && *path != 0)
    80004234:	0004c783          	lbu	a5,0(s1)
    80004238:	85a6                	mv	a1,s1
    8000423a:	b7d1                	j	800041fe <namex+0x122>

000000008000423c <dirlink>:
{
    8000423c:	7139                	addi	sp,sp,-64
    8000423e:	fc06                	sd	ra,56(sp)
    80004240:	f822                	sd	s0,48(sp)
    80004242:	f426                	sd	s1,40(sp)
    80004244:	f04a                	sd	s2,32(sp)
    80004246:	ec4e                	sd	s3,24(sp)
    80004248:	e852                	sd	s4,16(sp)
    8000424a:	0080                	addi	s0,sp,64
    8000424c:	892a                	mv	s2,a0
    8000424e:	8a2e                	mv	s4,a1
    80004250:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004252:	4601                	li	a2,0
    80004254:	00000097          	auipc	ra,0x0
    80004258:	dd8080e7          	jalr	-552(ra) # 8000402c <dirlookup>
    8000425c:	e93d                	bnez	a0,800042d2 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000425e:	04c92483          	lw	s1,76(s2)
    80004262:	c49d                	beqz	s1,80004290 <dirlink+0x54>
    80004264:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004266:	4741                	li	a4,16
    80004268:	86a6                	mv	a3,s1
    8000426a:	fc040613          	addi	a2,s0,-64
    8000426e:	4581                	li	a1,0
    80004270:	854a                	mv	a0,s2
    80004272:	00000097          	auipc	ra,0x0
    80004276:	b8a080e7          	jalr	-1142(ra) # 80003dfc <readi>
    8000427a:	47c1                	li	a5,16
    8000427c:	06f51163          	bne	a0,a5,800042de <dirlink+0xa2>
    if(de.inum == 0)
    80004280:	fc045783          	lhu	a5,-64(s0)
    80004284:	c791                	beqz	a5,80004290 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004286:	24c1                	addiw	s1,s1,16
    80004288:	04c92783          	lw	a5,76(s2)
    8000428c:	fcf4ede3          	bltu	s1,a5,80004266 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004290:	4639                	li	a2,14
    80004292:	85d2                	mv	a1,s4
    80004294:	fc240513          	addi	a0,s0,-62
    80004298:	ffffd097          	auipc	ra,0xffffd
    8000429c:	b62080e7          	jalr	-1182(ra) # 80000dfa <strncpy>
  de.inum = inum;
    800042a0:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042a4:	4741                	li	a4,16
    800042a6:	86a6                	mv	a3,s1
    800042a8:	fc040613          	addi	a2,s0,-64
    800042ac:	4581                	li	a1,0
    800042ae:	854a                	mv	a0,s2
    800042b0:	00000097          	auipc	ra,0x0
    800042b4:	c44080e7          	jalr	-956(ra) # 80003ef4 <writei>
    800042b8:	1541                	addi	a0,a0,-16
    800042ba:	00a03533          	snez	a0,a0
    800042be:	40a00533          	neg	a0,a0
}
    800042c2:	70e2                	ld	ra,56(sp)
    800042c4:	7442                	ld	s0,48(sp)
    800042c6:	74a2                	ld	s1,40(sp)
    800042c8:	7902                	ld	s2,32(sp)
    800042ca:	69e2                	ld	s3,24(sp)
    800042cc:	6a42                	ld	s4,16(sp)
    800042ce:	6121                	addi	sp,sp,64
    800042d0:	8082                	ret
    iput(ip);
    800042d2:	00000097          	auipc	ra,0x0
    800042d6:	a30080e7          	jalr	-1488(ra) # 80003d02 <iput>
    return -1;
    800042da:	557d                	li	a0,-1
    800042dc:	b7dd                	j	800042c2 <dirlink+0x86>
      panic("dirlink read");
    800042de:	00004517          	auipc	a0,0x4
    800042e2:	47a50513          	addi	a0,a0,1146 # 80008758 <syscalls+0x1e8>
    800042e6:	ffffc097          	auipc	ra,0xffffc
    800042ea:	25e080e7          	jalr	606(ra) # 80000544 <panic>

00000000800042ee <namei>:

struct inode*
namei(char *path)
{
    800042ee:	1101                	addi	sp,sp,-32
    800042f0:	ec06                	sd	ra,24(sp)
    800042f2:	e822                	sd	s0,16(sp)
    800042f4:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800042f6:	fe040613          	addi	a2,s0,-32
    800042fa:	4581                	li	a1,0
    800042fc:	00000097          	auipc	ra,0x0
    80004300:	de0080e7          	jalr	-544(ra) # 800040dc <namex>
}
    80004304:	60e2                	ld	ra,24(sp)
    80004306:	6442                	ld	s0,16(sp)
    80004308:	6105                	addi	sp,sp,32
    8000430a:	8082                	ret

000000008000430c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000430c:	1141                	addi	sp,sp,-16
    8000430e:	e406                	sd	ra,8(sp)
    80004310:	e022                	sd	s0,0(sp)
    80004312:	0800                	addi	s0,sp,16
    80004314:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004316:	4585                	li	a1,1
    80004318:	00000097          	auipc	ra,0x0
    8000431c:	dc4080e7          	jalr	-572(ra) # 800040dc <namex>
}
    80004320:	60a2                	ld	ra,8(sp)
    80004322:	6402                	ld	s0,0(sp)
    80004324:	0141                	addi	sp,sp,16
    80004326:	8082                	ret

0000000080004328 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004328:	1101                	addi	sp,sp,-32
    8000432a:	ec06                	sd	ra,24(sp)
    8000432c:	e822                	sd	s0,16(sp)
    8000432e:	e426                	sd	s1,8(sp)
    80004330:	e04a                	sd	s2,0(sp)
    80004332:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004334:	0001f917          	auipc	s2,0x1f
    80004338:	f3490913          	addi	s2,s2,-204 # 80023268 <log>
    8000433c:	01892583          	lw	a1,24(s2)
    80004340:	02892503          	lw	a0,40(s2)
    80004344:	fffff097          	auipc	ra,0xfffff
    80004348:	fea080e7          	jalr	-22(ra) # 8000332e <bread>
    8000434c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000434e:	02c92683          	lw	a3,44(s2)
    80004352:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004354:	02d05763          	blez	a3,80004382 <write_head+0x5a>
    80004358:	0001f797          	auipc	a5,0x1f
    8000435c:	f4078793          	addi	a5,a5,-192 # 80023298 <log+0x30>
    80004360:	05c50713          	addi	a4,a0,92
    80004364:	36fd                	addiw	a3,a3,-1
    80004366:	1682                	slli	a3,a3,0x20
    80004368:	9281                	srli	a3,a3,0x20
    8000436a:	068a                	slli	a3,a3,0x2
    8000436c:	0001f617          	auipc	a2,0x1f
    80004370:	f3060613          	addi	a2,a2,-208 # 8002329c <log+0x34>
    80004374:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004376:	4390                	lw	a2,0(a5)
    80004378:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000437a:	0791                	addi	a5,a5,4
    8000437c:	0711                	addi	a4,a4,4
    8000437e:	fed79ce3          	bne	a5,a3,80004376 <write_head+0x4e>
  }
  bwrite(buf);
    80004382:	8526                	mv	a0,s1
    80004384:	fffff097          	auipc	ra,0xfffff
    80004388:	09c080e7          	jalr	156(ra) # 80003420 <bwrite>
  brelse(buf);
    8000438c:	8526                	mv	a0,s1
    8000438e:	fffff097          	auipc	ra,0xfffff
    80004392:	0d0080e7          	jalr	208(ra) # 8000345e <brelse>
}
    80004396:	60e2                	ld	ra,24(sp)
    80004398:	6442                	ld	s0,16(sp)
    8000439a:	64a2                	ld	s1,8(sp)
    8000439c:	6902                	ld	s2,0(sp)
    8000439e:	6105                	addi	sp,sp,32
    800043a0:	8082                	ret

00000000800043a2 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800043a2:	0001f797          	auipc	a5,0x1f
    800043a6:	ef27a783          	lw	a5,-270(a5) # 80023294 <log+0x2c>
    800043aa:	0af05d63          	blez	a5,80004464 <install_trans+0xc2>
{
    800043ae:	7139                	addi	sp,sp,-64
    800043b0:	fc06                	sd	ra,56(sp)
    800043b2:	f822                	sd	s0,48(sp)
    800043b4:	f426                	sd	s1,40(sp)
    800043b6:	f04a                	sd	s2,32(sp)
    800043b8:	ec4e                	sd	s3,24(sp)
    800043ba:	e852                	sd	s4,16(sp)
    800043bc:	e456                	sd	s5,8(sp)
    800043be:	e05a                	sd	s6,0(sp)
    800043c0:	0080                	addi	s0,sp,64
    800043c2:	8b2a                	mv	s6,a0
    800043c4:	0001fa97          	auipc	s5,0x1f
    800043c8:	ed4a8a93          	addi	s5,s5,-300 # 80023298 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043cc:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800043ce:	0001f997          	auipc	s3,0x1f
    800043d2:	e9a98993          	addi	s3,s3,-358 # 80023268 <log>
    800043d6:	a035                	j	80004402 <install_trans+0x60>
      bunpin(dbuf);
    800043d8:	8526                	mv	a0,s1
    800043da:	fffff097          	auipc	ra,0xfffff
    800043de:	15e080e7          	jalr	350(ra) # 80003538 <bunpin>
    brelse(lbuf);
    800043e2:	854a                	mv	a0,s2
    800043e4:	fffff097          	auipc	ra,0xfffff
    800043e8:	07a080e7          	jalr	122(ra) # 8000345e <brelse>
    brelse(dbuf);
    800043ec:	8526                	mv	a0,s1
    800043ee:	fffff097          	auipc	ra,0xfffff
    800043f2:	070080e7          	jalr	112(ra) # 8000345e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043f6:	2a05                	addiw	s4,s4,1
    800043f8:	0a91                	addi	s5,s5,4
    800043fa:	02c9a783          	lw	a5,44(s3)
    800043fe:	04fa5963          	bge	s4,a5,80004450 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004402:	0189a583          	lw	a1,24(s3)
    80004406:	014585bb          	addw	a1,a1,s4
    8000440a:	2585                	addiw	a1,a1,1
    8000440c:	0289a503          	lw	a0,40(s3)
    80004410:	fffff097          	auipc	ra,0xfffff
    80004414:	f1e080e7          	jalr	-226(ra) # 8000332e <bread>
    80004418:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000441a:	000aa583          	lw	a1,0(s5)
    8000441e:	0289a503          	lw	a0,40(s3)
    80004422:	fffff097          	auipc	ra,0xfffff
    80004426:	f0c080e7          	jalr	-244(ra) # 8000332e <bread>
    8000442a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000442c:	40000613          	li	a2,1024
    80004430:	05890593          	addi	a1,s2,88
    80004434:	05850513          	addi	a0,a0,88
    80004438:	ffffd097          	auipc	ra,0xffffd
    8000443c:	90e080e7          	jalr	-1778(ra) # 80000d46 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004440:	8526                	mv	a0,s1
    80004442:	fffff097          	auipc	ra,0xfffff
    80004446:	fde080e7          	jalr	-34(ra) # 80003420 <bwrite>
    if(recovering == 0)
    8000444a:	f80b1ce3          	bnez	s6,800043e2 <install_trans+0x40>
    8000444e:	b769                	j	800043d8 <install_trans+0x36>
}
    80004450:	70e2                	ld	ra,56(sp)
    80004452:	7442                	ld	s0,48(sp)
    80004454:	74a2                	ld	s1,40(sp)
    80004456:	7902                	ld	s2,32(sp)
    80004458:	69e2                	ld	s3,24(sp)
    8000445a:	6a42                	ld	s4,16(sp)
    8000445c:	6aa2                	ld	s5,8(sp)
    8000445e:	6b02                	ld	s6,0(sp)
    80004460:	6121                	addi	sp,sp,64
    80004462:	8082                	ret
    80004464:	8082                	ret

0000000080004466 <initlog>:
{
    80004466:	7179                	addi	sp,sp,-48
    80004468:	f406                	sd	ra,40(sp)
    8000446a:	f022                	sd	s0,32(sp)
    8000446c:	ec26                	sd	s1,24(sp)
    8000446e:	e84a                	sd	s2,16(sp)
    80004470:	e44e                	sd	s3,8(sp)
    80004472:	1800                	addi	s0,sp,48
    80004474:	892a                	mv	s2,a0
    80004476:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004478:	0001f497          	auipc	s1,0x1f
    8000447c:	df048493          	addi	s1,s1,-528 # 80023268 <log>
    80004480:	00004597          	auipc	a1,0x4
    80004484:	2e858593          	addi	a1,a1,744 # 80008768 <syscalls+0x1f8>
    80004488:	8526                	mv	a0,s1
    8000448a:	ffffc097          	auipc	ra,0xffffc
    8000448e:	6d0080e7          	jalr	1744(ra) # 80000b5a <initlock>
  log.start = sb->logstart;
    80004492:	0149a583          	lw	a1,20(s3)
    80004496:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004498:	0109a783          	lw	a5,16(s3)
    8000449c:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000449e:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800044a2:	854a                	mv	a0,s2
    800044a4:	fffff097          	auipc	ra,0xfffff
    800044a8:	e8a080e7          	jalr	-374(ra) # 8000332e <bread>
  log.lh.n = lh->n;
    800044ac:	4d3c                	lw	a5,88(a0)
    800044ae:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800044b0:	02f05563          	blez	a5,800044da <initlog+0x74>
    800044b4:	05c50713          	addi	a4,a0,92
    800044b8:	0001f697          	auipc	a3,0x1f
    800044bc:	de068693          	addi	a3,a3,-544 # 80023298 <log+0x30>
    800044c0:	37fd                	addiw	a5,a5,-1
    800044c2:	1782                	slli	a5,a5,0x20
    800044c4:	9381                	srli	a5,a5,0x20
    800044c6:	078a                	slli	a5,a5,0x2
    800044c8:	06050613          	addi	a2,a0,96
    800044cc:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    800044ce:	4310                	lw	a2,0(a4)
    800044d0:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    800044d2:	0711                	addi	a4,a4,4
    800044d4:	0691                	addi	a3,a3,4
    800044d6:	fef71ce3          	bne	a4,a5,800044ce <initlog+0x68>
  brelse(buf);
    800044da:	fffff097          	auipc	ra,0xfffff
    800044de:	f84080e7          	jalr	-124(ra) # 8000345e <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800044e2:	4505                	li	a0,1
    800044e4:	00000097          	auipc	ra,0x0
    800044e8:	ebe080e7          	jalr	-322(ra) # 800043a2 <install_trans>
  log.lh.n = 0;
    800044ec:	0001f797          	auipc	a5,0x1f
    800044f0:	da07a423          	sw	zero,-600(a5) # 80023294 <log+0x2c>
  write_head(); // clear the log
    800044f4:	00000097          	auipc	ra,0x0
    800044f8:	e34080e7          	jalr	-460(ra) # 80004328 <write_head>
}
    800044fc:	70a2                	ld	ra,40(sp)
    800044fe:	7402                	ld	s0,32(sp)
    80004500:	64e2                	ld	s1,24(sp)
    80004502:	6942                	ld	s2,16(sp)
    80004504:	69a2                	ld	s3,8(sp)
    80004506:	6145                	addi	sp,sp,48
    80004508:	8082                	ret

000000008000450a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000450a:	1101                	addi	sp,sp,-32
    8000450c:	ec06                	sd	ra,24(sp)
    8000450e:	e822                	sd	s0,16(sp)
    80004510:	e426                	sd	s1,8(sp)
    80004512:	e04a                	sd	s2,0(sp)
    80004514:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004516:	0001f517          	auipc	a0,0x1f
    8000451a:	d5250513          	addi	a0,a0,-686 # 80023268 <log>
    8000451e:	ffffc097          	auipc	ra,0xffffc
    80004522:	6cc080e7          	jalr	1740(ra) # 80000bea <acquire>
  while(1){
    if(log.committing){
    80004526:	0001f497          	auipc	s1,0x1f
    8000452a:	d4248493          	addi	s1,s1,-702 # 80023268 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000452e:	4979                	li	s2,30
    80004530:	a039                	j	8000453e <begin_op+0x34>
      sleep(&log, &log.lock);
    80004532:	85a6                	mv	a1,s1
    80004534:	8526                	mv	a0,s1
    80004536:	ffffe097          	auipc	ra,0xffffe
    8000453a:	df2080e7          	jalr	-526(ra) # 80002328 <sleep>
    if(log.committing){
    8000453e:	50dc                	lw	a5,36(s1)
    80004540:	fbed                	bnez	a5,80004532 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004542:	509c                	lw	a5,32(s1)
    80004544:	0017871b          	addiw	a4,a5,1
    80004548:	0007069b          	sext.w	a3,a4
    8000454c:	0027179b          	slliw	a5,a4,0x2
    80004550:	9fb9                	addw	a5,a5,a4
    80004552:	0017979b          	slliw	a5,a5,0x1
    80004556:	54d8                	lw	a4,44(s1)
    80004558:	9fb9                	addw	a5,a5,a4
    8000455a:	00f95963          	bge	s2,a5,8000456c <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000455e:	85a6                	mv	a1,s1
    80004560:	8526                	mv	a0,s1
    80004562:	ffffe097          	auipc	ra,0xffffe
    80004566:	dc6080e7          	jalr	-570(ra) # 80002328 <sleep>
    8000456a:	bfd1                	j	8000453e <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000456c:	0001f517          	auipc	a0,0x1f
    80004570:	cfc50513          	addi	a0,a0,-772 # 80023268 <log>
    80004574:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004576:	ffffc097          	auipc	ra,0xffffc
    8000457a:	728080e7          	jalr	1832(ra) # 80000c9e <release>
      break;
    }
  }
}
    8000457e:	60e2                	ld	ra,24(sp)
    80004580:	6442                	ld	s0,16(sp)
    80004582:	64a2                	ld	s1,8(sp)
    80004584:	6902                	ld	s2,0(sp)
    80004586:	6105                	addi	sp,sp,32
    80004588:	8082                	ret

000000008000458a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000458a:	7139                	addi	sp,sp,-64
    8000458c:	fc06                	sd	ra,56(sp)
    8000458e:	f822                	sd	s0,48(sp)
    80004590:	f426                	sd	s1,40(sp)
    80004592:	f04a                	sd	s2,32(sp)
    80004594:	ec4e                	sd	s3,24(sp)
    80004596:	e852                	sd	s4,16(sp)
    80004598:	e456                	sd	s5,8(sp)
    8000459a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000459c:	0001f497          	auipc	s1,0x1f
    800045a0:	ccc48493          	addi	s1,s1,-820 # 80023268 <log>
    800045a4:	8526                	mv	a0,s1
    800045a6:	ffffc097          	auipc	ra,0xffffc
    800045aa:	644080e7          	jalr	1604(ra) # 80000bea <acquire>
  log.outstanding -= 1;
    800045ae:	509c                	lw	a5,32(s1)
    800045b0:	37fd                	addiw	a5,a5,-1
    800045b2:	0007891b          	sext.w	s2,a5
    800045b6:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800045b8:	50dc                	lw	a5,36(s1)
    800045ba:	efb9                	bnez	a5,80004618 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    800045bc:	06091663          	bnez	s2,80004628 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    800045c0:	0001f497          	auipc	s1,0x1f
    800045c4:	ca848493          	addi	s1,s1,-856 # 80023268 <log>
    800045c8:	4785                	li	a5,1
    800045ca:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800045cc:	8526                	mv	a0,s1
    800045ce:	ffffc097          	auipc	ra,0xffffc
    800045d2:	6d0080e7          	jalr	1744(ra) # 80000c9e <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800045d6:	54dc                	lw	a5,44(s1)
    800045d8:	06f04763          	bgtz	a5,80004646 <end_op+0xbc>
    acquire(&log.lock);
    800045dc:	0001f497          	auipc	s1,0x1f
    800045e0:	c8c48493          	addi	s1,s1,-884 # 80023268 <log>
    800045e4:	8526                	mv	a0,s1
    800045e6:	ffffc097          	auipc	ra,0xffffc
    800045ea:	604080e7          	jalr	1540(ra) # 80000bea <acquire>
    log.committing = 0;
    800045ee:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800045f2:	8526                	mv	a0,s1
    800045f4:	ffffe097          	auipc	ra,0xffffe
    800045f8:	da2080e7          	jalr	-606(ra) # 80002396 <wakeup>
    release(&log.lock);
    800045fc:	8526                	mv	a0,s1
    800045fe:	ffffc097          	auipc	ra,0xffffc
    80004602:	6a0080e7          	jalr	1696(ra) # 80000c9e <release>
}
    80004606:	70e2                	ld	ra,56(sp)
    80004608:	7442                	ld	s0,48(sp)
    8000460a:	74a2                	ld	s1,40(sp)
    8000460c:	7902                	ld	s2,32(sp)
    8000460e:	69e2                	ld	s3,24(sp)
    80004610:	6a42                	ld	s4,16(sp)
    80004612:	6aa2                	ld	s5,8(sp)
    80004614:	6121                	addi	sp,sp,64
    80004616:	8082                	ret
    panic("log.committing");
    80004618:	00004517          	auipc	a0,0x4
    8000461c:	15850513          	addi	a0,a0,344 # 80008770 <syscalls+0x200>
    80004620:	ffffc097          	auipc	ra,0xffffc
    80004624:	f24080e7          	jalr	-220(ra) # 80000544 <panic>
    wakeup(&log);
    80004628:	0001f497          	auipc	s1,0x1f
    8000462c:	c4048493          	addi	s1,s1,-960 # 80023268 <log>
    80004630:	8526                	mv	a0,s1
    80004632:	ffffe097          	auipc	ra,0xffffe
    80004636:	d64080e7          	jalr	-668(ra) # 80002396 <wakeup>
  release(&log.lock);
    8000463a:	8526                	mv	a0,s1
    8000463c:	ffffc097          	auipc	ra,0xffffc
    80004640:	662080e7          	jalr	1634(ra) # 80000c9e <release>
  if(do_commit){
    80004644:	b7c9                	j	80004606 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004646:	0001fa97          	auipc	s5,0x1f
    8000464a:	c52a8a93          	addi	s5,s5,-942 # 80023298 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000464e:	0001fa17          	auipc	s4,0x1f
    80004652:	c1aa0a13          	addi	s4,s4,-998 # 80023268 <log>
    80004656:	018a2583          	lw	a1,24(s4)
    8000465a:	012585bb          	addw	a1,a1,s2
    8000465e:	2585                	addiw	a1,a1,1
    80004660:	028a2503          	lw	a0,40(s4)
    80004664:	fffff097          	auipc	ra,0xfffff
    80004668:	cca080e7          	jalr	-822(ra) # 8000332e <bread>
    8000466c:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000466e:	000aa583          	lw	a1,0(s5)
    80004672:	028a2503          	lw	a0,40(s4)
    80004676:	fffff097          	auipc	ra,0xfffff
    8000467a:	cb8080e7          	jalr	-840(ra) # 8000332e <bread>
    8000467e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004680:	40000613          	li	a2,1024
    80004684:	05850593          	addi	a1,a0,88
    80004688:	05848513          	addi	a0,s1,88
    8000468c:	ffffc097          	auipc	ra,0xffffc
    80004690:	6ba080e7          	jalr	1722(ra) # 80000d46 <memmove>
    bwrite(to);  // write the log
    80004694:	8526                	mv	a0,s1
    80004696:	fffff097          	auipc	ra,0xfffff
    8000469a:	d8a080e7          	jalr	-630(ra) # 80003420 <bwrite>
    brelse(from);
    8000469e:	854e                	mv	a0,s3
    800046a0:	fffff097          	auipc	ra,0xfffff
    800046a4:	dbe080e7          	jalr	-578(ra) # 8000345e <brelse>
    brelse(to);
    800046a8:	8526                	mv	a0,s1
    800046aa:	fffff097          	auipc	ra,0xfffff
    800046ae:	db4080e7          	jalr	-588(ra) # 8000345e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800046b2:	2905                	addiw	s2,s2,1
    800046b4:	0a91                	addi	s5,s5,4
    800046b6:	02ca2783          	lw	a5,44(s4)
    800046ba:	f8f94ee3          	blt	s2,a5,80004656 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800046be:	00000097          	auipc	ra,0x0
    800046c2:	c6a080e7          	jalr	-918(ra) # 80004328 <write_head>
    install_trans(0); // Now install writes to home locations
    800046c6:	4501                	li	a0,0
    800046c8:	00000097          	auipc	ra,0x0
    800046cc:	cda080e7          	jalr	-806(ra) # 800043a2 <install_trans>
    log.lh.n = 0;
    800046d0:	0001f797          	auipc	a5,0x1f
    800046d4:	bc07a223          	sw	zero,-1084(a5) # 80023294 <log+0x2c>
    write_head();    // Erase the transaction from the log
    800046d8:	00000097          	auipc	ra,0x0
    800046dc:	c50080e7          	jalr	-944(ra) # 80004328 <write_head>
    800046e0:	bdf5                	j	800045dc <end_op+0x52>

00000000800046e2 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800046e2:	1101                	addi	sp,sp,-32
    800046e4:	ec06                	sd	ra,24(sp)
    800046e6:	e822                	sd	s0,16(sp)
    800046e8:	e426                	sd	s1,8(sp)
    800046ea:	e04a                	sd	s2,0(sp)
    800046ec:	1000                	addi	s0,sp,32
    800046ee:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800046f0:	0001f917          	auipc	s2,0x1f
    800046f4:	b7890913          	addi	s2,s2,-1160 # 80023268 <log>
    800046f8:	854a                	mv	a0,s2
    800046fa:	ffffc097          	auipc	ra,0xffffc
    800046fe:	4f0080e7          	jalr	1264(ra) # 80000bea <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004702:	02c92603          	lw	a2,44(s2)
    80004706:	47f5                	li	a5,29
    80004708:	06c7c563          	blt	a5,a2,80004772 <log_write+0x90>
    8000470c:	0001f797          	auipc	a5,0x1f
    80004710:	b787a783          	lw	a5,-1160(a5) # 80023284 <log+0x1c>
    80004714:	37fd                	addiw	a5,a5,-1
    80004716:	04f65e63          	bge	a2,a5,80004772 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000471a:	0001f797          	auipc	a5,0x1f
    8000471e:	b6e7a783          	lw	a5,-1170(a5) # 80023288 <log+0x20>
    80004722:	06f05063          	blez	a5,80004782 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004726:	4781                	li	a5,0
    80004728:	06c05563          	blez	a2,80004792 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000472c:	44cc                	lw	a1,12(s1)
    8000472e:	0001f717          	auipc	a4,0x1f
    80004732:	b6a70713          	addi	a4,a4,-1174 # 80023298 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004736:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004738:	4314                	lw	a3,0(a4)
    8000473a:	04b68c63          	beq	a3,a1,80004792 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000473e:	2785                	addiw	a5,a5,1
    80004740:	0711                	addi	a4,a4,4
    80004742:	fef61be3          	bne	a2,a5,80004738 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004746:	0621                	addi	a2,a2,8
    80004748:	060a                	slli	a2,a2,0x2
    8000474a:	0001f797          	auipc	a5,0x1f
    8000474e:	b1e78793          	addi	a5,a5,-1250 # 80023268 <log>
    80004752:	963e                	add	a2,a2,a5
    80004754:	44dc                	lw	a5,12(s1)
    80004756:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004758:	8526                	mv	a0,s1
    8000475a:	fffff097          	auipc	ra,0xfffff
    8000475e:	da2080e7          	jalr	-606(ra) # 800034fc <bpin>
    log.lh.n++;
    80004762:	0001f717          	auipc	a4,0x1f
    80004766:	b0670713          	addi	a4,a4,-1274 # 80023268 <log>
    8000476a:	575c                	lw	a5,44(a4)
    8000476c:	2785                	addiw	a5,a5,1
    8000476e:	d75c                	sw	a5,44(a4)
    80004770:	a835                	j	800047ac <log_write+0xca>
    panic("too big a transaction");
    80004772:	00004517          	auipc	a0,0x4
    80004776:	00e50513          	addi	a0,a0,14 # 80008780 <syscalls+0x210>
    8000477a:	ffffc097          	auipc	ra,0xffffc
    8000477e:	dca080e7          	jalr	-566(ra) # 80000544 <panic>
    panic("log_write outside of trans");
    80004782:	00004517          	auipc	a0,0x4
    80004786:	01650513          	addi	a0,a0,22 # 80008798 <syscalls+0x228>
    8000478a:	ffffc097          	auipc	ra,0xffffc
    8000478e:	dba080e7          	jalr	-582(ra) # 80000544 <panic>
  log.lh.block[i] = b->blockno;
    80004792:	00878713          	addi	a4,a5,8
    80004796:	00271693          	slli	a3,a4,0x2
    8000479a:	0001f717          	auipc	a4,0x1f
    8000479e:	ace70713          	addi	a4,a4,-1330 # 80023268 <log>
    800047a2:	9736                	add	a4,a4,a3
    800047a4:	44d4                	lw	a3,12(s1)
    800047a6:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800047a8:	faf608e3          	beq	a2,a5,80004758 <log_write+0x76>
  }
  release(&log.lock);
    800047ac:	0001f517          	auipc	a0,0x1f
    800047b0:	abc50513          	addi	a0,a0,-1348 # 80023268 <log>
    800047b4:	ffffc097          	auipc	ra,0xffffc
    800047b8:	4ea080e7          	jalr	1258(ra) # 80000c9e <release>
}
    800047bc:	60e2                	ld	ra,24(sp)
    800047be:	6442                	ld	s0,16(sp)
    800047c0:	64a2                	ld	s1,8(sp)
    800047c2:	6902                	ld	s2,0(sp)
    800047c4:	6105                	addi	sp,sp,32
    800047c6:	8082                	ret

00000000800047c8 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800047c8:	1101                	addi	sp,sp,-32
    800047ca:	ec06                	sd	ra,24(sp)
    800047cc:	e822                	sd	s0,16(sp)
    800047ce:	e426                	sd	s1,8(sp)
    800047d0:	e04a                	sd	s2,0(sp)
    800047d2:	1000                	addi	s0,sp,32
    800047d4:	84aa                	mv	s1,a0
    800047d6:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800047d8:	00004597          	auipc	a1,0x4
    800047dc:	fe058593          	addi	a1,a1,-32 # 800087b8 <syscalls+0x248>
    800047e0:	0521                	addi	a0,a0,8
    800047e2:	ffffc097          	auipc	ra,0xffffc
    800047e6:	378080e7          	jalr	888(ra) # 80000b5a <initlock>
  lk->name = name;
    800047ea:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800047ee:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800047f2:	0204a423          	sw	zero,40(s1)
}
    800047f6:	60e2                	ld	ra,24(sp)
    800047f8:	6442                	ld	s0,16(sp)
    800047fa:	64a2                	ld	s1,8(sp)
    800047fc:	6902                	ld	s2,0(sp)
    800047fe:	6105                	addi	sp,sp,32
    80004800:	8082                	ret

0000000080004802 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004802:	1101                	addi	sp,sp,-32
    80004804:	ec06                	sd	ra,24(sp)
    80004806:	e822                	sd	s0,16(sp)
    80004808:	e426                	sd	s1,8(sp)
    8000480a:	e04a                	sd	s2,0(sp)
    8000480c:	1000                	addi	s0,sp,32
    8000480e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004810:	00850913          	addi	s2,a0,8
    80004814:	854a                	mv	a0,s2
    80004816:	ffffc097          	auipc	ra,0xffffc
    8000481a:	3d4080e7          	jalr	980(ra) # 80000bea <acquire>
  while (lk->locked) {
    8000481e:	409c                	lw	a5,0(s1)
    80004820:	cb89                	beqz	a5,80004832 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004822:	85ca                	mv	a1,s2
    80004824:	8526                	mv	a0,s1
    80004826:	ffffe097          	auipc	ra,0xffffe
    8000482a:	b02080e7          	jalr	-1278(ra) # 80002328 <sleep>
  while (lk->locked) {
    8000482e:	409c                	lw	a5,0(s1)
    80004830:	fbed                	bnez	a5,80004822 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004832:	4785                	li	a5,1
    80004834:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004836:	ffffd097          	auipc	ra,0xffffd
    8000483a:	3bc080e7          	jalr	956(ra) # 80001bf2 <myproc>
    8000483e:	5d1c                	lw	a5,56(a0)
    80004840:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004842:	854a                	mv	a0,s2
    80004844:	ffffc097          	auipc	ra,0xffffc
    80004848:	45a080e7          	jalr	1114(ra) # 80000c9e <release>
}
    8000484c:	60e2                	ld	ra,24(sp)
    8000484e:	6442                	ld	s0,16(sp)
    80004850:	64a2                	ld	s1,8(sp)
    80004852:	6902                	ld	s2,0(sp)
    80004854:	6105                	addi	sp,sp,32
    80004856:	8082                	ret

0000000080004858 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004858:	1101                	addi	sp,sp,-32
    8000485a:	ec06                	sd	ra,24(sp)
    8000485c:	e822                	sd	s0,16(sp)
    8000485e:	e426                	sd	s1,8(sp)
    80004860:	e04a                	sd	s2,0(sp)
    80004862:	1000                	addi	s0,sp,32
    80004864:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004866:	00850913          	addi	s2,a0,8
    8000486a:	854a                	mv	a0,s2
    8000486c:	ffffc097          	auipc	ra,0xffffc
    80004870:	37e080e7          	jalr	894(ra) # 80000bea <acquire>
  lk->locked = 0;
    80004874:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004878:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000487c:	8526                	mv	a0,s1
    8000487e:	ffffe097          	auipc	ra,0xffffe
    80004882:	b18080e7          	jalr	-1256(ra) # 80002396 <wakeup>
  release(&lk->lk);
    80004886:	854a                	mv	a0,s2
    80004888:	ffffc097          	auipc	ra,0xffffc
    8000488c:	416080e7          	jalr	1046(ra) # 80000c9e <release>
}
    80004890:	60e2                	ld	ra,24(sp)
    80004892:	6442                	ld	s0,16(sp)
    80004894:	64a2                	ld	s1,8(sp)
    80004896:	6902                	ld	s2,0(sp)
    80004898:	6105                	addi	sp,sp,32
    8000489a:	8082                	ret

000000008000489c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000489c:	7179                	addi	sp,sp,-48
    8000489e:	f406                	sd	ra,40(sp)
    800048a0:	f022                	sd	s0,32(sp)
    800048a2:	ec26                	sd	s1,24(sp)
    800048a4:	e84a                	sd	s2,16(sp)
    800048a6:	e44e                	sd	s3,8(sp)
    800048a8:	1800                	addi	s0,sp,48
    800048aa:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800048ac:	00850913          	addi	s2,a0,8
    800048b0:	854a                	mv	a0,s2
    800048b2:	ffffc097          	auipc	ra,0xffffc
    800048b6:	338080e7          	jalr	824(ra) # 80000bea <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800048ba:	409c                	lw	a5,0(s1)
    800048bc:	ef99                	bnez	a5,800048da <holdingsleep+0x3e>
    800048be:	4481                	li	s1,0
  release(&lk->lk);
    800048c0:	854a                	mv	a0,s2
    800048c2:	ffffc097          	auipc	ra,0xffffc
    800048c6:	3dc080e7          	jalr	988(ra) # 80000c9e <release>
  return r;
}
    800048ca:	8526                	mv	a0,s1
    800048cc:	70a2                	ld	ra,40(sp)
    800048ce:	7402                	ld	s0,32(sp)
    800048d0:	64e2                	ld	s1,24(sp)
    800048d2:	6942                	ld	s2,16(sp)
    800048d4:	69a2                	ld	s3,8(sp)
    800048d6:	6145                	addi	sp,sp,48
    800048d8:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800048da:	0284a983          	lw	s3,40(s1)
    800048de:	ffffd097          	auipc	ra,0xffffd
    800048e2:	314080e7          	jalr	788(ra) # 80001bf2 <myproc>
    800048e6:	5d04                	lw	s1,56(a0)
    800048e8:	413484b3          	sub	s1,s1,s3
    800048ec:	0014b493          	seqz	s1,s1
    800048f0:	bfc1                	j	800048c0 <holdingsleep+0x24>

00000000800048f2 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800048f2:	1141                	addi	sp,sp,-16
    800048f4:	e406                	sd	ra,8(sp)
    800048f6:	e022                	sd	s0,0(sp)
    800048f8:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800048fa:	00004597          	auipc	a1,0x4
    800048fe:	ece58593          	addi	a1,a1,-306 # 800087c8 <syscalls+0x258>
    80004902:	0001f517          	auipc	a0,0x1f
    80004906:	aae50513          	addi	a0,a0,-1362 # 800233b0 <ftable>
    8000490a:	ffffc097          	auipc	ra,0xffffc
    8000490e:	250080e7          	jalr	592(ra) # 80000b5a <initlock>
}
    80004912:	60a2                	ld	ra,8(sp)
    80004914:	6402                	ld	s0,0(sp)
    80004916:	0141                	addi	sp,sp,16
    80004918:	8082                	ret

000000008000491a <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000491a:	1101                	addi	sp,sp,-32
    8000491c:	ec06                	sd	ra,24(sp)
    8000491e:	e822                	sd	s0,16(sp)
    80004920:	e426                	sd	s1,8(sp)
    80004922:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004924:	0001f517          	auipc	a0,0x1f
    80004928:	a8c50513          	addi	a0,a0,-1396 # 800233b0 <ftable>
    8000492c:	ffffc097          	auipc	ra,0xffffc
    80004930:	2be080e7          	jalr	702(ra) # 80000bea <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004934:	0001f497          	auipc	s1,0x1f
    80004938:	a9448493          	addi	s1,s1,-1388 # 800233c8 <ftable+0x18>
    8000493c:	00020717          	auipc	a4,0x20
    80004940:	a2c70713          	addi	a4,a4,-1492 # 80024368 <disk>
    if(f->ref == 0){
    80004944:	40dc                	lw	a5,4(s1)
    80004946:	cf99                	beqz	a5,80004964 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004948:	02848493          	addi	s1,s1,40
    8000494c:	fee49ce3          	bne	s1,a4,80004944 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004950:	0001f517          	auipc	a0,0x1f
    80004954:	a6050513          	addi	a0,a0,-1440 # 800233b0 <ftable>
    80004958:	ffffc097          	auipc	ra,0xffffc
    8000495c:	346080e7          	jalr	838(ra) # 80000c9e <release>
  return 0;
    80004960:	4481                	li	s1,0
    80004962:	a819                	j	80004978 <filealloc+0x5e>
      f->ref = 1;
    80004964:	4785                	li	a5,1
    80004966:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004968:	0001f517          	auipc	a0,0x1f
    8000496c:	a4850513          	addi	a0,a0,-1464 # 800233b0 <ftable>
    80004970:	ffffc097          	auipc	ra,0xffffc
    80004974:	32e080e7          	jalr	814(ra) # 80000c9e <release>
}
    80004978:	8526                	mv	a0,s1
    8000497a:	60e2                	ld	ra,24(sp)
    8000497c:	6442                	ld	s0,16(sp)
    8000497e:	64a2                	ld	s1,8(sp)
    80004980:	6105                	addi	sp,sp,32
    80004982:	8082                	ret

0000000080004984 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004984:	1101                	addi	sp,sp,-32
    80004986:	ec06                	sd	ra,24(sp)
    80004988:	e822                	sd	s0,16(sp)
    8000498a:	e426                	sd	s1,8(sp)
    8000498c:	1000                	addi	s0,sp,32
    8000498e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004990:	0001f517          	auipc	a0,0x1f
    80004994:	a2050513          	addi	a0,a0,-1504 # 800233b0 <ftable>
    80004998:	ffffc097          	auipc	ra,0xffffc
    8000499c:	252080e7          	jalr	594(ra) # 80000bea <acquire>
  if(f->ref < 1)
    800049a0:	40dc                	lw	a5,4(s1)
    800049a2:	02f05263          	blez	a5,800049c6 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800049a6:	2785                	addiw	a5,a5,1
    800049a8:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800049aa:	0001f517          	auipc	a0,0x1f
    800049ae:	a0650513          	addi	a0,a0,-1530 # 800233b0 <ftable>
    800049b2:	ffffc097          	auipc	ra,0xffffc
    800049b6:	2ec080e7          	jalr	748(ra) # 80000c9e <release>
  return f;
}
    800049ba:	8526                	mv	a0,s1
    800049bc:	60e2                	ld	ra,24(sp)
    800049be:	6442                	ld	s0,16(sp)
    800049c0:	64a2                	ld	s1,8(sp)
    800049c2:	6105                	addi	sp,sp,32
    800049c4:	8082                	ret
    panic("filedup");
    800049c6:	00004517          	auipc	a0,0x4
    800049ca:	e0a50513          	addi	a0,a0,-502 # 800087d0 <syscalls+0x260>
    800049ce:	ffffc097          	auipc	ra,0xffffc
    800049d2:	b76080e7          	jalr	-1162(ra) # 80000544 <panic>

00000000800049d6 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800049d6:	7139                	addi	sp,sp,-64
    800049d8:	fc06                	sd	ra,56(sp)
    800049da:	f822                	sd	s0,48(sp)
    800049dc:	f426                	sd	s1,40(sp)
    800049de:	f04a                	sd	s2,32(sp)
    800049e0:	ec4e                	sd	s3,24(sp)
    800049e2:	e852                	sd	s4,16(sp)
    800049e4:	e456                	sd	s5,8(sp)
    800049e6:	0080                	addi	s0,sp,64
    800049e8:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800049ea:	0001f517          	auipc	a0,0x1f
    800049ee:	9c650513          	addi	a0,a0,-1594 # 800233b0 <ftable>
    800049f2:	ffffc097          	auipc	ra,0xffffc
    800049f6:	1f8080e7          	jalr	504(ra) # 80000bea <acquire>
  if(f->ref < 1)
    800049fa:	40dc                	lw	a5,4(s1)
    800049fc:	06f05163          	blez	a5,80004a5e <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004a00:	37fd                	addiw	a5,a5,-1
    80004a02:	0007871b          	sext.w	a4,a5
    80004a06:	c0dc                	sw	a5,4(s1)
    80004a08:	06e04363          	bgtz	a4,80004a6e <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004a0c:	0004a903          	lw	s2,0(s1)
    80004a10:	0094ca83          	lbu	s5,9(s1)
    80004a14:	0104ba03          	ld	s4,16(s1)
    80004a18:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004a1c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004a20:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004a24:	0001f517          	auipc	a0,0x1f
    80004a28:	98c50513          	addi	a0,a0,-1652 # 800233b0 <ftable>
    80004a2c:	ffffc097          	auipc	ra,0xffffc
    80004a30:	272080e7          	jalr	626(ra) # 80000c9e <release>

  if(ff.type == FD_PIPE){
    80004a34:	4785                	li	a5,1
    80004a36:	04f90d63          	beq	s2,a5,80004a90 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004a3a:	3979                	addiw	s2,s2,-2
    80004a3c:	4785                	li	a5,1
    80004a3e:	0527e063          	bltu	a5,s2,80004a7e <fileclose+0xa8>
    begin_op();
    80004a42:	00000097          	auipc	ra,0x0
    80004a46:	ac8080e7          	jalr	-1336(ra) # 8000450a <begin_op>
    iput(ff.ip);
    80004a4a:	854e                	mv	a0,s3
    80004a4c:	fffff097          	auipc	ra,0xfffff
    80004a50:	2b6080e7          	jalr	694(ra) # 80003d02 <iput>
    end_op();
    80004a54:	00000097          	auipc	ra,0x0
    80004a58:	b36080e7          	jalr	-1226(ra) # 8000458a <end_op>
    80004a5c:	a00d                	j	80004a7e <fileclose+0xa8>
    panic("fileclose");
    80004a5e:	00004517          	auipc	a0,0x4
    80004a62:	d7a50513          	addi	a0,a0,-646 # 800087d8 <syscalls+0x268>
    80004a66:	ffffc097          	auipc	ra,0xffffc
    80004a6a:	ade080e7          	jalr	-1314(ra) # 80000544 <panic>
    release(&ftable.lock);
    80004a6e:	0001f517          	auipc	a0,0x1f
    80004a72:	94250513          	addi	a0,a0,-1726 # 800233b0 <ftable>
    80004a76:	ffffc097          	auipc	ra,0xffffc
    80004a7a:	228080e7          	jalr	552(ra) # 80000c9e <release>
  }
}
    80004a7e:	70e2                	ld	ra,56(sp)
    80004a80:	7442                	ld	s0,48(sp)
    80004a82:	74a2                	ld	s1,40(sp)
    80004a84:	7902                	ld	s2,32(sp)
    80004a86:	69e2                	ld	s3,24(sp)
    80004a88:	6a42                	ld	s4,16(sp)
    80004a8a:	6aa2                	ld	s5,8(sp)
    80004a8c:	6121                	addi	sp,sp,64
    80004a8e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004a90:	85d6                	mv	a1,s5
    80004a92:	8552                	mv	a0,s4
    80004a94:	00000097          	auipc	ra,0x0
    80004a98:	34c080e7          	jalr	844(ra) # 80004de0 <pipeclose>
    80004a9c:	b7cd                	j	80004a7e <fileclose+0xa8>

0000000080004a9e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004a9e:	715d                	addi	sp,sp,-80
    80004aa0:	e486                	sd	ra,72(sp)
    80004aa2:	e0a2                	sd	s0,64(sp)
    80004aa4:	fc26                	sd	s1,56(sp)
    80004aa6:	f84a                	sd	s2,48(sp)
    80004aa8:	f44e                	sd	s3,40(sp)
    80004aaa:	0880                	addi	s0,sp,80
    80004aac:	84aa                	mv	s1,a0
    80004aae:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004ab0:	ffffd097          	auipc	ra,0xffffd
    80004ab4:	142080e7          	jalr	322(ra) # 80001bf2 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004ab8:	409c                	lw	a5,0(s1)
    80004aba:	37f9                	addiw	a5,a5,-2
    80004abc:	4705                	li	a4,1
    80004abe:	04f76763          	bltu	a4,a5,80004b0c <filestat+0x6e>
    80004ac2:	892a                	mv	s2,a0
    ilock(f->ip);
    80004ac4:	6c88                	ld	a0,24(s1)
    80004ac6:	fffff097          	auipc	ra,0xfffff
    80004aca:	082080e7          	jalr	130(ra) # 80003b48 <ilock>
    stati(f->ip, &st);
    80004ace:	fb840593          	addi	a1,s0,-72
    80004ad2:	6c88                	ld	a0,24(s1)
    80004ad4:	fffff097          	auipc	ra,0xfffff
    80004ad8:	2fe080e7          	jalr	766(ra) # 80003dd2 <stati>
    iunlock(f->ip);
    80004adc:	6c88                	ld	a0,24(s1)
    80004ade:	fffff097          	auipc	ra,0xfffff
    80004ae2:	12c080e7          	jalr	300(ra) # 80003c0a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004ae6:	46e1                	li	a3,24
    80004ae8:	fb840613          	addi	a2,s0,-72
    80004aec:	85ce                	mv	a1,s3
    80004aee:	05893503          	ld	a0,88(s2)
    80004af2:	ffffd097          	auipc	ra,0xffffd
    80004af6:	b9a080e7          	jalr	-1126(ra) # 8000168c <copyout>
    80004afa:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004afe:	60a6                	ld	ra,72(sp)
    80004b00:	6406                	ld	s0,64(sp)
    80004b02:	74e2                	ld	s1,56(sp)
    80004b04:	7942                	ld	s2,48(sp)
    80004b06:	79a2                	ld	s3,40(sp)
    80004b08:	6161                	addi	sp,sp,80
    80004b0a:	8082                	ret
  return -1;
    80004b0c:	557d                	li	a0,-1
    80004b0e:	bfc5                	j	80004afe <filestat+0x60>

0000000080004b10 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004b10:	7179                	addi	sp,sp,-48
    80004b12:	f406                	sd	ra,40(sp)
    80004b14:	f022                	sd	s0,32(sp)
    80004b16:	ec26                	sd	s1,24(sp)
    80004b18:	e84a                	sd	s2,16(sp)
    80004b1a:	e44e                	sd	s3,8(sp)
    80004b1c:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004b1e:	00854783          	lbu	a5,8(a0)
    80004b22:	c3d5                	beqz	a5,80004bc6 <fileread+0xb6>
    80004b24:	84aa                	mv	s1,a0
    80004b26:	89ae                	mv	s3,a1
    80004b28:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004b2a:	411c                	lw	a5,0(a0)
    80004b2c:	4705                	li	a4,1
    80004b2e:	04e78963          	beq	a5,a4,80004b80 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004b32:	470d                	li	a4,3
    80004b34:	04e78d63          	beq	a5,a4,80004b8e <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004b38:	4709                	li	a4,2
    80004b3a:	06e79e63          	bne	a5,a4,80004bb6 <fileread+0xa6>
    ilock(f->ip);
    80004b3e:	6d08                	ld	a0,24(a0)
    80004b40:	fffff097          	auipc	ra,0xfffff
    80004b44:	008080e7          	jalr	8(ra) # 80003b48 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004b48:	874a                	mv	a4,s2
    80004b4a:	5094                	lw	a3,32(s1)
    80004b4c:	864e                	mv	a2,s3
    80004b4e:	4585                	li	a1,1
    80004b50:	6c88                	ld	a0,24(s1)
    80004b52:	fffff097          	auipc	ra,0xfffff
    80004b56:	2aa080e7          	jalr	682(ra) # 80003dfc <readi>
    80004b5a:	892a                	mv	s2,a0
    80004b5c:	00a05563          	blez	a0,80004b66 <fileread+0x56>
      f->off += r;
    80004b60:	509c                	lw	a5,32(s1)
    80004b62:	9fa9                	addw	a5,a5,a0
    80004b64:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004b66:	6c88                	ld	a0,24(s1)
    80004b68:	fffff097          	auipc	ra,0xfffff
    80004b6c:	0a2080e7          	jalr	162(ra) # 80003c0a <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004b70:	854a                	mv	a0,s2
    80004b72:	70a2                	ld	ra,40(sp)
    80004b74:	7402                	ld	s0,32(sp)
    80004b76:	64e2                	ld	s1,24(sp)
    80004b78:	6942                	ld	s2,16(sp)
    80004b7a:	69a2                	ld	s3,8(sp)
    80004b7c:	6145                	addi	sp,sp,48
    80004b7e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004b80:	6908                	ld	a0,16(a0)
    80004b82:	00000097          	auipc	ra,0x0
    80004b86:	3ce080e7          	jalr	974(ra) # 80004f50 <piperead>
    80004b8a:	892a                	mv	s2,a0
    80004b8c:	b7d5                	j	80004b70 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004b8e:	02451783          	lh	a5,36(a0)
    80004b92:	03079693          	slli	a3,a5,0x30
    80004b96:	92c1                	srli	a3,a3,0x30
    80004b98:	4725                	li	a4,9
    80004b9a:	02d76863          	bltu	a4,a3,80004bca <fileread+0xba>
    80004b9e:	0792                	slli	a5,a5,0x4
    80004ba0:	0001e717          	auipc	a4,0x1e
    80004ba4:	77070713          	addi	a4,a4,1904 # 80023310 <devsw>
    80004ba8:	97ba                	add	a5,a5,a4
    80004baa:	639c                	ld	a5,0(a5)
    80004bac:	c38d                	beqz	a5,80004bce <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004bae:	4505                	li	a0,1
    80004bb0:	9782                	jalr	a5
    80004bb2:	892a                	mv	s2,a0
    80004bb4:	bf75                	j	80004b70 <fileread+0x60>
    panic("fileread");
    80004bb6:	00004517          	auipc	a0,0x4
    80004bba:	c3250513          	addi	a0,a0,-974 # 800087e8 <syscalls+0x278>
    80004bbe:	ffffc097          	auipc	ra,0xffffc
    80004bc2:	986080e7          	jalr	-1658(ra) # 80000544 <panic>
    return -1;
    80004bc6:	597d                	li	s2,-1
    80004bc8:	b765                	j	80004b70 <fileread+0x60>
      return -1;
    80004bca:	597d                	li	s2,-1
    80004bcc:	b755                	j	80004b70 <fileread+0x60>
    80004bce:	597d                	li	s2,-1
    80004bd0:	b745                	j	80004b70 <fileread+0x60>

0000000080004bd2 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004bd2:	715d                	addi	sp,sp,-80
    80004bd4:	e486                	sd	ra,72(sp)
    80004bd6:	e0a2                	sd	s0,64(sp)
    80004bd8:	fc26                	sd	s1,56(sp)
    80004bda:	f84a                	sd	s2,48(sp)
    80004bdc:	f44e                	sd	s3,40(sp)
    80004bde:	f052                	sd	s4,32(sp)
    80004be0:	ec56                	sd	s5,24(sp)
    80004be2:	e85a                	sd	s6,16(sp)
    80004be4:	e45e                	sd	s7,8(sp)
    80004be6:	e062                	sd	s8,0(sp)
    80004be8:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004bea:	00954783          	lbu	a5,9(a0)
    80004bee:	10078663          	beqz	a5,80004cfa <filewrite+0x128>
    80004bf2:	892a                	mv	s2,a0
    80004bf4:	8aae                	mv	s5,a1
    80004bf6:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004bf8:	411c                	lw	a5,0(a0)
    80004bfa:	4705                	li	a4,1
    80004bfc:	02e78263          	beq	a5,a4,80004c20 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004c00:	470d                	li	a4,3
    80004c02:	02e78663          	beq	a5,a4,80004c2e <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004c06:	4709                	li	a4,2
    80004c08:	0ee79163          	bne	a5,a4,80004cea <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004c0c:	0ac05d63          	blez	a2,80004cc6 <filewrite+0xf4>
    int i = 0;
    80004c10:	4981                	li	s3,0
    80004c12:	6b05                	lui	s6,0x1
    80004c14:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004c18:	6b85                	lui	s7,0x1
    80004c1a:	c00b8b9b          	addiw	s7,s7,-1024
    80004c1e:	a861                	j	80004cb6 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004c20:	6908                	ld	a0,16(a0)
    80004c22:	00000097          	auipc	ra,0x0
    80004c26:	22e080e7          	jalr	558(ra) # 80004e50 <pipewrite>
    80004c2a:	8a2a                	mv	s4,a0
    80004c2c:	a045                	j	80004ccc <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004c2e:	02451783          	lh	a5,36(a0)
    80004c32:	03079693          	slli	a3,a5,0x30
    80004c36:	92c1                	srli	a3,a3,0x30
    80004c38:	4725                	li	a4,9
    80004c3a:	0cd76263          	bltu	a4,a3,80004cfe <filewrite+0x12c>
    80004c3e:	0792                	slli	a5,a5,0x4
    80004c40:	0001e717          	auipc	a4,0x1e
    80004c44:	6d070713          	addi	a4,a4,1744 # 80023310 <devsw>
    80004c48:	97ba                	add	a5,a5,a4
    80004c4a:	679c                	ld	a5,8(a5)
    80004c4c:	cbdd                	beqz	a5,80004d02 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004c4e:	4505                	li	a0,1
    80004c50:	9782                	jalr	a5
    80004c52:	8a2a                	mv	s4,a0
    80004c54:	a8a5                	j	80004ccc <filewrite+0xfa>
    80004c56:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004c5a:	00000097          	auipc	ra,0x0
    80004c5e:	8b0080e7          	jalr	-1872(ra) # 8000450a <begin_op>
      ilock(f->ip);
    80004c62:	01893503          	ld	a0,24(s2)
    80004c66:	fffff097          	auipc	ra,0xfffff
    80004c6a:	ee2080e7          	jalr	-286(ra) # 80003b48 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004c6e:	8762                	mv	a4,s8
    80004c70:	02092683          	lw	a3,32(s2)
    80004c74:	01598633          	add	a2,s3,s5
    80004c78:	4585                	li	a1,1
    80004c7a:	01893503          	ld	a0,24(s2)
    80004c7e:	fffff097          	auipc	ra,0xfffff
    80004c82:	276080e7          	jalr	630(ra) # 80003ef4 <writei>
    80004c86:	84aa                	mv	s1,a0
    80004c88:	00a05763          	blez	a0,80004c96 <filewrite+0xc4>
        f->off += r;
    80004c8c:	02092783          	lw	a5,32(s2)
    80004c90:	9fa9                	addw	a5,a5,a0
    80004c92:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004c96:	01893503          	ld	a0,24(s2)
    80004c9a:	fffff097          	auipc	ra,0xfffff
    80004c9e:	f70080e7          	jalr	-144(ra) # 80003c0a <iunlock>
      end_op();
    80004ca2:	00000097          	auipc	ra,0x0
    80004ca6:	8e8080e7          	jalr	-1816(ra) # 8000458a <end_op>

      if(r != n1){
    80004caa:	009c1f63          	bne	s8,s1,80004cc8 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004cae:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004cb2:	0149db63          	bge	s3,s4,80004cc8 <filewrite+0xf6>
      int n1 = n - i;
    80004cb6:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004cba:	84be                	mv	s1,a5
    80004cbc:	2781                	sext.w	a5,a5
    80004cbe:	f8fb5ce3          	bge	s6,a5,80004c56 <filewrite+0x84>
    80004cc2:	84de                	mv	s1,s7
    80004cc4:	bf49                	j	80004c56 <filewrite+0x84>
    int i = 0;
    80004cc6:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004cc8:	013a1f63          	bne	s4,s3,80004ce6 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004ccc:	8552                	mv	a0,s4
    80004cce:	60a6                	ld	ra,72(sp)
    80004cd0:	6406                	ld	s0,64(sp)
    80004cd2:	74e2                	ld	s1,56(sp)
    80004cd4:	7942                	ld	s2,48(sp)
    80004cd6:	79a2                	ld	s3,40(sp)
    80004cd8:	7a02                	ld	s4,32(sp)
    80004cda:	6ae2                	ld	s5,24(sp)
    80004cdc:	6b42                	ld	s6,16(sp)
    80004cde:	6ba2                	ld	s7,8(sp)
    80004ce0:	6c02                	ld	s8,0(sp)
    80004ce2:	6161                	addi	sp,sp,80
    80004ce4:	8082                	ret
    ret = (i == n ? n : -1);
    80004ce6:	5a7d                	li	s4,-1
    80004ce8:	b7d5                	j	80004ccc <filewrite+0xfa>
    panic("filewrite");
    80004cea:	00004517          	auipc	a0,0x4
    80004cee:	b0e50513          	addi	a0,a0,-1266 # 800087f8 <syscalls+0x288>
    80004cf2:	ffffc097          	auipc	ra,0xffffc
    80004cf6:	852080e7          	jalr	-1966(ra) # 80000544 <panic>
    return -1;
    80004cfa:	5a7d                	li	s4,-1
    80004cfc:	bfc1                	j	80004ccc <filewrite+0xfa>
      return -1;
    80004cfe:	5a7d                	li	s4,-1
    80004d00:	b7f1                	j	80004ccc <filewrite+0xfa>
    80004d02:	5a7d                	li	s4,-1
    80004d04:	b7e1                	j	80004ccc <filewrite+0xfa>

0000000080004d06 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004d06:	7179                	addi	sp,sp,-48
    80004d08:	f406                	sd	ra,40(sp)
    80004d0a:	f022                	sd	s0,32(sp)
    80004d0c:	ec26                	sd	s1,24(sp)
    80004d0e:	e84a                	sd	s2,16(sp)
    80004d10:	e44e                	sd	s3,8(sp)
    80004d12:	e052                	sd	s4,0(sp)
    80004d14:	1800                	addi	s0,sp,48
    80004d16:	84aa                	mv	s1,a0
    80004d18:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004d1a:	0005b023          	sd	zero,0(a1)
    80004d1e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004d22:	00000097          	auipc	ra,0x0
    80004d26:	bf8080e7          	jalr	-1032(ra) # 8000491a <filealloc>
    80004d2a:	e088                	sd	a0,0(s1)
    80004d2c:	c551                	beqz	a0,80004db8 <pipealloc+0xb2>
    80004d2e:	00000097          	auipc	ra,0x0
    80004d32:	bec080e7          	jalr	-1044(ra) # 8000491a <filealloc>
    80004d36:	00aa3023          	sd	a0,0(s4)
    80004d3a:	c92d                	beqz	a0,80004dac <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004d3c:	ffffc097          	auipc	ra,0xffffc
    80004d40:	dbe080e7          	jalr	-578(ra) # 80000afa <kalloc>
    80004d44:	892a                	mv	s2,a0
    80004d46:	c125                	beqz	a0,80004da6 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004d48:	4985                	li	s3,1
    80004d4a:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004d4e:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004d52:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004d56:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004d5a:	00003597          	auipc	a1,0x3
    80004d5e:	73e58593          	addi	a1,a1,1854 # 80008498 <states.2513+0x1b8>
    80004d62:	ffffc097          	auipc	ra,0xffffc
    80004d66:	df8080e7          	jalr	-520(ra) # 80000b5a <initlock>
  (*f0)->type = FD_PIPE;
    80004d6a:	609c                	ld	a5,0(s1)
    80004d6c:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004d70:	609c                	ld	a5,0(s1)
    80004d72:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004d76:	609c                	ld	a5,0(s1)
    80004d78:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004d7c:	609c                	ld	a5,0(s1)
    80004d7e:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004d82:	000a3783          	ld	a5,0(s4)
    80004d86:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004d8a:	000a3783          	ld	a5,0(s4)
    80004d8e:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004d92:	000a3783          	ld	a5,0(s4)
    80004d96:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004d9a:	000a3783          	ld	a5,0(s4)
    80004d9e:	0127b823          	sd	s2,16(a5)
  return 0;
    80004da2:	4501                	li	a0,0
    80004da4:	a025                	j	80004dcc <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004da6:	6088                	ld	a0,0(s1)
    80004da8:	e501                	bnez	a0,80004db0 <pipealloc+0xaa>
    80004daa:	a039                	j	80004db8 <pipealloc+0xb2>
    80004dac:	6088                	ld	a0,0(s1)
    80004dae:	c51d                	beqz	a0,80004ddc <pipealloc+0xd6>
    fileclose(*f0);
    80004db0:	00000097          	auipc	ra,0x0
    80004db4:	c26080e7          	jalr	-986(ra) # 800049d6 <fileclose>
  if(*f1)
    80004db8:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004dbc:	557d                	li	a0,-1
  if(*f1)
    80004dbe:	c799                	beqz	a5,80004dcc <pipealloc+0xc6>
    fileclose(*f1);
    80004dc0:	853e                	mv	a0,a5
    80004dc2:	00000097          	auipc	ra,0x0
    80004dc6:	c14080e7          	jalr	-1004(ra) # 800049d6 <fileclose>
  return -1;
    80004dca:	557d                	li	a0,-1
}
    80004dcc:	70a2                	ld	ra,40(sp)
    80004dce:	7402                	ld	s0,32(sp)
    80004dd0:	64e2                	ld	s1,24(sp)
    80004dd2:	6942                	ld	s2,16(sp)
    80004dd4:	69a2                	ld	s3,8(sp)
    80004dd6:	6a02                	ld	s4,0(sp)
    80004dd8:	6145                	addi	sp,sp,48
    80004dda:	8082                	ret
  return -1;
    80004ddc:	557d                	li	a0,-1
    80004dde:	b7fd                	j	80004dcc <pipealloc+0xc6>

0000000080004de0 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004de0:	1101                	addi	sp,sp,-32
    80004de2:	ec06                	sd	ra,24(sp)
    80004de4:	e822                	sd	s0,16(sp)
    80004de6:	e426                	sd	s1,8(sp)
    80004de8:	e04a                	sd	s2,0(sp)
    80004dea:	1000                	addi	s0,sp,32
    80004dec:	84aa                	mv	s1,a0
    80004dee:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004df0:	ffffc097          	auipc	ra,0xffffc
    80004df4:	dfa080e7          	jalr	-518(ra) # 80000bea <acquire>
  if(writable){
    80004df8:	02090d63          	beqz	s2,80004e32 <pipeclose+0x52>
    pi->writeopen = 0;
    80004dfc:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004e00:	21848513          	addi	a0,s1,536
    80004e04:	ffffd097          	auipc	ra,0xffffd
    80004e08:	592080e7          	jalr	1426(ra) # 80002396 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004e0c:	2204b783          	ld	a5,544(s1)
    80004e10:	eb95                	bnez	a5,80004e44 <pipeclose+0x64>
    release(&pi->lock);
    80004e12:	8526                	mv	a0,s1
    80004e14:	ffffc097          	auipc	ra,0xffffc
    80004e18:	e8a080e7          	jalr	-374(ra) # 80000c9e <release>
    kfree((char*)pi);
    80004e1c:	8526                	mv	a0,s1
    80004e1e:	ffffc097          	auipc	ra,0xffffc
    80004e22:	be0080e7          	jalr	-1056(ra) # 800009fe <kfree>
  } else
    release(&pi->lock);
}
    80004e26:	60e2                	ld	ra,24(sp)
    80004e28:	6442                	ld	s0,16(sp)
    80004e2a:	64a2                	ld	s1,8(sp)
    80004e2c:	6902                	ld	s2,0(sp)
    80004e2e:	6105                	addi	sp,sp,32
    80004e30:	8082                	ret
    pi->readopen = 0;
    80004e32:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004e36:	21c48513          	addi	a0,s1,540
    80004e3a:	ffffd097          	auipc	ra,0xffffd
    80004e3e:	55c080e7          	jalr	1372(ra) # 80002396 <wakeup>
    80004e42:	b7e9                	j	80004e0c <pipeclose+0x2c>
    release(&pi->lock);
    80004e44:	8526                	mv	a0,s1
    80004e46:	ffffc097          	auipc	ra,0xffffc
    80004e4a:	e58080e7          	jalr	-424(ra) # 80000c9e <release>
}
    80004e4e:	bfe1                	j	80004e26 <pipeclose+0x46>

0000000080004e50 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004e50:	7159                	addi	sp,sp,-112
    80004e52:	f486                	sd	ra,104(sp)
    80004e54:	f0a2                	sd	s0,96(sp)
    80004e56:	eca6                	sd	s1,88(sp)
    80004e58:	e8ca                	sd	s2,80(sp)
    80004e5a:	e4ce                	sd	s3,72(sp)
    80004e5c:	e0d2                	sd	s4,64(sp)
    80004e5e:	fc56                	sd	s5,56(sp)
    80004e60:	f85a                	sd	s6,48(sp)
    80004e62:	f45e                	sd	s7,40(sp)
    80004e64:	f062                	sd	s8,32(sp)
    80004e66:	ec66                	sd	s9,24(sp)
    80004e68:	1880                	addi	s0,sp,112
    80004e6a:	84aa                	mv	s1,a0
    80004e6c:	8aae                	mv	s5,a1
    80004e6e:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004e70:	ffffd097          	auipc	ra,0xffffd
    80004e74:	d82080e7          	jalr	-638(ra) # 80001bf2 <myproc>
    80004e78:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004e7a:	8526                	mv	a0,s1
    80004e7c:	ffffc097          	auipc	ra,0xffffc
    80004e80:	d6e080e7          	jalr	-658(ra) # 80000bea <acquire>
  while(i < n){
    80004e84:	0d405463          	blez	s4,80004f4c <pipewrite+0xfc>
    80004e88:	8ba6                	mv	s7,s1
  int i = 0;
    80004e8a:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004e8c:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004e8e:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004e92:	21c48c13          	addi	s8,s1,540
    80004e96:	a08d                	j	80004ef8 <pipewrite+0xa8>
      release(&pi->lock);
    80004e98:	8526                	mv	a0,s1
    80004e9a:	ffffc097          	auipc	ra,0xffffc
    80004e9e:	e04080e7          	jalr	-508(ra) # 80000c9e <release>
      return -1;
    80004ea2:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004ea4:	854a                	mv	a0,s2
    80004ea6:	70a6                	ld	ra,104(sp)
    80004ea8:	7406                	ld	s0,96(sp)
    80004eaa:	64e6                	ld	s1,88(sp)
    80004eac:	6946                	ld	s2,80(sp)
    80004eae:	69a6                	ld	s3,72(sp)
    80004eb0:	6a06                	ld	s4,64(sp)
    80004eb2:	7ae2                	ld	s5,56(sp)
    80004eb4:	7b42                	ld	s6,48(sp)
    80004eb6:	7ba2                	ld	s7,40(sp)
    80004eb8:	7c02                	ld	s8,32(sp)
    80004eba:	6ce2                	ld	s9,24(sp)
    80004ebc:	6165                	addi	sp,sp,112
    80004ebe:	8082                	ret
      wakeup(&pi->nread);
    80004ec0:	8566                	mv	a0,s9
    80004ec2:	ffffd097          	auipc	ra,0xffffd
    80004ec6:	4d4080e7          	jalr	1236(ra) # 80002396 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004eca:	85de                	mv	a1,s7
    80004ecc:	8562                	mv	a0,s8
    80004ece:	ffffd097          	auipc	ra,0xffffd
    80004ed2:	45a080e7          	jalr	1114(ra) # 80002328 <sleep>
    80004ed6:	a839                	j	80004ef4 <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004ed8:	21c4a783          	lw	a5,540(s1)
    80004edc:	0017871b          	addiw	a4,a5,1
    80004ee0:	20e4ae23          	sw	a4,540(s1)
    80004ee4:	1ff7f793          	andi	a5,a5,511
    80004ee8:	97a6                	add	a5,a5,s1
    80004eea:	f9f44703          	lbu	a4,-97(s0)
    80004eee:	00e78c23          	sb	a4,24(a5)
      i++;
    80004ef2:	2905                	addiw	s2,s2,1
  while(i < n){
    80004ef4:	05495063          	bge	s2,s4,80004f34 <pipewrite+0xe4>
    if(pi->readopen == 0 || killed(pr)){
    80004ef8:	2204a783          	lw	a5,544(s1)
    80004efc:	dfd1                	beqz	a5,80004e98 <pipewrite+0x48>
    80004efe:	854e                	mv	a0,s3
    80004f00:	ffffd097          	auipc	ra,0xffffd
    80004f04:	730080e7          	jalr	1840(ra) # 80002630 <killed>
    80004f08:	f941                	bnez	a0,80004e98 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004f0a:	2184a783          	lw	a5,536(s1)
    80004f0e:	21c4a703          	lw	a4,540(s1)
    80004f12:	2007879b          	addiw	a5,a5,512
    80004f16:	faf705e3          	beq	a4,a5,80004ec0 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f1a:	4685                	li	a3,1
    80004f1c:	01590633          	add	a2,s2,s5
    80004f20:	f9f40593          	addi	a1,s0,-97
    80004f24:	0589b503          	ld	a0,88(s3)
    80004f28:	ffffc097          	auipc	ra,0xffffc
    80004f2c:	7f0080e7          	jalr	2032(ra) # 80001718 <copyin>
    80004f30:	fb6514e3          	bne	a0,s6,80004ed8 <pipewrite+0x88>
  wakeup(&pi->nread);
    80004f34:	21848513          	addi	a0,s1,536
    80004f38:	ffffd097          	auipc	ra,0xffffd
    80004f3c:	45e080e7          	jalr	1118(ra) # 80002396 <wakeup>
  release(&pi->lock);
    80004f40:	8526                	mv	a0,s1
    80004f42:	ffffc097          	auipc	ra,0xffffc
    80004f46:	d5c080e7          	jalr	-676(ra) # 80000c9e <release>
  return i;
    80004f4a:	bfa9                	j	80004ea4 <pipewrite+0x54>
  int i = 0;
    80004f4c:	4901                	li	s2,0
    80004f4e:	b7dd                	j	80004f34 <pipewrite+0xe4>

0000000080004f50 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004f50:	715d                	addi	sp,sp,-80
    80004f52:	e486                	sd	ra,72(sp)
    80004f54:	e0a2                	sd	s0,64(sp)
    80004f56:	fc26                	sd	s1,56(sp)
    80004f58:	f84a                	sd	s2,48(sp)
    80004f5a:	f44e                	sd	s3,40(sp)
    80004f5c:	f052                	sd	s4,32(sp)
    80004f5e:	ec56                	sd	s5,24(sp)
    80004f60:	e85a                	sd	s6,16(sp)
    80004f62:	0880                	addi	s0,sp,80
    80004f64:	84aa                	mv	s1,a0
    80004f66:	892e                	mv	s2,a1
    80004f68:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004f6a:	ffffd097          	auipc	ra,0xffffd
    80004f6e:	c88080e7          	jalr	-888(ra) # 80001bf2 <myproc>
    80004f72:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004f74:	8b26                	mv	s6,s1
    80004f76:	8526                	mv	a0,s1
    80004f78:	ffffc097          	auipc	ra,0xffffc
    80004f7c:	c72080e7          	jalr	-910(ra) # 80000bea <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f80:	2184a703          	lw	a4,536(s1)
    80004f84:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004f88:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f8c:	02f71763          	bne	a4,a5,80004fba <piperead+0x6a>
    80004f90:	2244a783          	lw	a5,548(s1)
    80004f94:	c39d                	beqz	a5,80004fba <piperead+0x6a>
    if(killed(pr)){
    80004f96:	8552                	mv	a0,s4
    80004f98:	ffffd097          	auipc	ra,0xffffd
    80004f9c:	698080e7          	jalr	1688(ra) # 80002630 <killed>
    80004fa0:	e941                	bnez	a0,80005030 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004fa2:	85da                	mv	a1,s6
    80004fa4:	854e                	mv	a0,s3
    80004fa6:	ffffd097          	auipc	ra,0xffffd
    80004faa:	382080e7          	jalr	898(ra) # 80002328 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004fae:	2184a703          	lw	a4,536(s1)
    80004fb2:	21c4a783          	lw	a5,540(s1)
    80004fb6:	fcf70de3          	beq	a4,a5,80004f90 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004fba:	09505263          	blez	s5,8000503e <piperead+0xee>
    80004fbe:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004fc0:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004fc2:	2184a783          	lw	a5,536(s1)
    80004fc6:	21c4a703          	lw	a4,540(s1)
    80004fca:	02f70d63          	beq	a4,a5,80005004 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004fce:	0017871b          	addiw	a4,a5,1
    80004fd2:	20e4ac23          	sw	a4,536(s1)
    80004fd6:	1ff7f793          	andi	a5,a5,511
    80004fda:	97a6                	add	a5,a5,s1
    80004fdc:	0187c783          	lbu	a5,24(a5)
    80004fe0:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004fe4:	4685                	li	a3,1
    80004fe6:	fbf40613          	addi	a2,s0,-65
    80004fea:	85ca                	mv	a1,s2
    80004fec:	058a3503          	ld	a0,88(s4)
    80004ff0:	ffffc097          	auipc	ra,0xffffc
    80004ff4:	69c080e7          	jalr	1692(ra) # 8000168c <copyout>
    80004ff8:	01650663          	beq	a0,s6,80005004 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ffc:	2985                	addiw	s3,s3,1
    80004ffe:	0905                	addi	s2,s2,1
    80005000:	fd3a91e3          	bne	s5,s3,80004fc2 <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005004:	21c48513          	addi	a0,s1,540
    80005008:	ffffd097          	auipc	ra,0xffffd
    8000500c:	38e080e7          	jalr	910(ra) # 80002396 <wakeup>
  release(&pi->lock);
    80005010:	8526                	mv	a0,s1
    80005012:	ffffc097          	auipc	ra,0xffffc
    80005016:	c8c080e7          	jalr	-884(ra) # 80000c9e <release>
  return i;
}
    8000501a:	854e                	mv	a0,s3
    8000501c:	60a6                	ld	ra,72(sp)
    8000501e:	6406                	ld	s0,64(sp)
    80005020:	74e2                	ld	s1,56(sp)
    80005022:	7942                	ld	s2,48(sp)
    80005024:	79a2                	ld	s3,40(sp)
    80005026:	7a02                	ld	s4,32(sp)
    80005028:	6ae2                	ld	s5,24(sp)
    8000502a:	6b42                	ld	s6,16(sp)
    8000502c:	6161                	addi	sp,sp,80
    8000502e:	8082                	ret
      release(&pi->lock);
    80005030:	8526                	mv	a0,s1
    80005032:	ffffc097          	auipc	ra,0xffffc
    80005036:	c6c080e7          	jalr	-916(ra) # 80000c9e <release>
      return -1;
    8000503a:	59fd                	li	s3,-1
    8000503c:	bff9                	j	8000501a <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000503e:	4981                	li	s3,0
    80005040:	b7d1                	j	80005004 <piperead+0xb4>

0000000080005042 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80005042:	1141                	addi	sp,sp,-16
    80005044:	e422                	sd	s0,8(sp)
    80005046:	0800                	addi	s0,sp,16
    80005048:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000504a:	8905                	andi	a0,a0,1
    8000504c:	c111                	beqz	a0,80005050 <flags2perm+0xe>
      perm = PTE_X;
    8000504e:	4521                	li	a0,8
    if(flags & 0x2)
    80005050:	8b89                	andi	a5,a5,2
    80005052:	c399                	beqz	a5,80005058 <flags2perm+0x16>
      perm |= PTE_W;
    80005054:	00456513          	ori	a0,a0,4
    return perm;
}
    80005058:	6422                	ld	s0,8(sp)
    8000505a:	0141                	addi	sp,sp,16
    8000505c:	8082                	ret

000000008000505e <exec>:

int
exec(char *path, char **argv)
{
    8000505e:	df010113          	addi	sp,sp,-528
    80005062:	20113423          	sd	ra,520(sp)
    80005066:	20813023          	sd	s0,512(sp)
    8000506a:	ffa6                	sd	s1,504(sp)
    8000506c:	fbca                	sd	s2,496(sp)
    8000506e:	f7ce                	sd	s3,488(sp)
    80005070:	f3d2                	sd	s4,480(sp)
    80005072:	efd6                	sd	s5,472(sp)
    80005074:	ebda                	sd	s6,464(sp)
    80005076:	e7de                	sd	s7,456(sp)
    80005078:	e3e2                	sd	s8,448(sp)
    8000507a:	ff66                	sd	s9,440(sp)
    8000507c:	fb6a                	sd	s10,432(sp)
    8000507e:	f76e                	sd	s11,424(sp)
    80005080:	0c00                	addi	s0,sp,528
    80005082:	84aa                	mv	s1,a0
    80005084:	dea43c23          	sd	a0,-520(s0)
    80005088:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000508c:	ffffd097          	auipc	ra,0xffffd
    80005090:	b66080e7          	jalr	-1178(ra) # 80001bf2 <myproc>
    80005094:	892a                	mv	s2,a0

  begin_op();
    80005096:	fffff097          	auipc	ra,0xfffff
    8000509a:	474080e7          	jalr	1140(ra) # 8000450a <begin_op>

  if((ip = namei(path)) == 0){
    8000509e:	8526                	mv	a0,s1
    800050a0:	fffff097          	auipc	ra,0xfffff
    800050a4:	24e080e7          	jalr	590(ra) # 800042ee <namei>
    800050a8:	c92d                	beqz	a0,8000511a <exec+0xbc>
    800050aa:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800050ac:	fffff097          	auipc	ra,0xfffff
    800050b0:	a9c080e7          	jalr	-1380(ra) # 80003b48 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800050b4:	04000713          	li	a4,64
    800050b8:	4681                	li	a3,0
    800050ba:	e5040613          	addi	a2,s0,-432
    800050be:	4581                	li	a1,0
    800050c0:	8526                	mv	a0,s1
    800050c2:	fffff097          	auipc	ra,0xfffff
    800050c6:	d3a080e7          	jalr	-710(ra) # 80003dfc <readi>
    800050ca:	04000793          	li	a5,64
    800050ce:	00f51a63          	bne	a0,a5,800050e2 <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800050d2:	e5042703          	lw	a4,-432(s0)
    800050d6:	464c47b7          	lui	a5,0x464c4
    800050da:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800050de:	04f70463          	beq	a4,a5,80005126 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800050e2:	8526                	mv	a0,s1
    800050e4:	fffff097          	auipc	ra,0xfffff
    800050e8:	cc6080e7          	jalr	-826(ra) # 80003daa <iunlockput>
    end_op();
    800050ec:	fffff097          	auipc	ra,0xfffff
    800050f0:	49e080e7          	jalr	1182(ra) # 8000458a <end_op>
  }
  return -1;
    800050f4:	557d                	li	a0,-1
}
    800050f6:	20813083          	ld	ra,520(sp)
    800050fa:	20013403          	ld	s0,512(sp)
    800050fe:	74fe                	ld	s1,504(sp)
    80005100:	795e                	ld	s2,496(sp)
    80005102:	79be                	ld	s3,488(sp)
    80005104:	7a1e                	ld	s4,480(sp)
    80005106:	6afe                	ld	s5,472(sp)
    80005108:	6b5e                	ld	s6,464(sp)
    8000510a:	6bbe                	ld	s7,456(sp)
    8000510c:	6c1e                	ld	s8,448(sp)
    8000510e:	7cfa                	ld	s9,440(sp)
    80005110:	7d5a                	ld	s10,432(sp)
    80005112:	7dba                	ld	s11,424(sp)
    80005114:	21010113          	addi	sp,sp,528
    80005118:	8082                	ret
    end_op();
    8000511a:	fffff097          	auipc	ra,0xfffff
    8000511e:	470080e7          	jalr	1136(ra) # 8000458a <end_op>
    return -1;
    80005122:	557d                	li	a0,-1
    80005124:	bfc9                	j	800050f6 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80005126:	854a                	mv	a0,s2
    80005128:	ffffd097          	auipc	ra,0xffffd
    8000512c:	b90080e7          	jalr	-1136(ra) # 80001cb8 <proc_pagetable>
    80005130:	8baa                	mv	s7,a0
    80005132:	d945                	beqz	a0,800050e2 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005134:	e7042983          	lw	s3,-400(s0)
    80005138:	e8845783          	lhu	a5,-376(s0)
    8000513c:	c7ad                	beqz	a5,800051a6 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000513e:	4a01                	li	s4,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005140:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80005142:	6c85                	lui	s9,0x1
    80005144:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80005148:	def43823          	sd	a5,-528(s0)
    8000514c:	ac0d                	j	8000537e <exec+0x320>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    8000514e:	00003517          	auipc	a0,0x3
    80005152:	6ba50513          	addi	a0,a0,1722 # 80008808 <syscalls+0x298>
    80005156:	ffffb097          	auipc	ra,0xffffb
    8000515a:	3ee080e7          	jalr	1006(ra) # 80000544 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000515e:	8756                	mv	a4,s5
    80005160:	012d86bb          	addw	a3,s11,s2
    80005164:	4581                	li	a1,0
    80005166:	8526                	mv	a0,s1
    80005168:	fffff097          	auipc	ra,0xfffff
    8000516c:	c94080e7          	jalr	-876(ra) # 80003dfc <readi>
    80005170:	2501                	sext.w	a0,a0
    80005172:	1aaa9a63          	bne	s5,a0,80005326 <exec+0x2c8>
  for(i = 0; i < sz; i += PGSIZE){
    80005176:	6785                	lui	a5,0x1
    80005178:	0127893b          	addw	s2,a5,s2
    8000517c:	77fd                	lui	a5,0xfffff
    8000517e:	01478a3b          	addw	s4,a5,s4
    80005182:	1f897563          	bgeu	s2,s8,8000536c <exec+0x30e>
    pa = walkaddr(pagetable, va + i);
    80005186:	02091593          	slli	a1,s2,0x20
    8000518a:	9181                	srli	a1,a1,0x20
    8000518c:	95ea                	add	a1,a1,s10
    8000518e:	855e                	mv	a0,s7
    80005190:	ffffc097          	auipc	ra,0xffffc
    80005194:	ef0080e7          	jalr	-272(ra) # 80001080 <walkaddr>
    80005198:	862a                	mv	a2,a0
    if(pa == 0)
    8000519a:	d955                	beqz	a0,8000514e <exec+0xf0>
      n = PGSIZE;
    8000519c:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    8000519e:	fd9a70e3          	bgeu	s4,s9,8000515e <exec+0x100>
      n = sz - i;
    800051a2:	8ad2                	mv	s5,s4
    800051a4:	bf6d                	j	8000515e <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800051a6:	4a01                	li	s4,0
  iunlockput(ip);
    800051a8:	8526                	mv	a0,s1
    800051aa:	fffff097          	auipc	ra,0xfffff
    800051ae:	c00080e7          	jalr	-1024(ra) # 80003daa <iunlockput>
  end_op();
    800051b2:	fffff097          	auipc	ra,0xfffff
    800051b6:	3d8080e7          	jalr	984(ra) # 8000458a <end_op>
  p = myproc();
    800051ba:	ffffd097          	auipc	ra,0xffffd
    800051be:	a38080e7          	jalr	-1480(ra) # 80001bf2 <myproc>
    800051c2:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800051c4:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    800051c8:	6785                	lui	a5,0x1
    800051ca:	17fd                	addi	a5,a5,-1
    800051cc:	9a3e                	add	s4,s4,a5
    800051ce:	757d                	lui	a0,0xfffff
    800051d0:	00aa77b3          	and	a5,s4,a0
    800051d4:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800051d8:	4691                	li	a3,4
    800051da:	6609                	lui	a2,0x2
    800051dc:	963e                	add	a2,a2,a5
    800051de:	85be                	mv	a1,a5
    800051e0:	855e                	mv	a0,s7
    800051e2:	ffffc097          	auipc	ra,0xffffc
    800051e6:	252080e7          	jalr	594(ra) # 80001434 <uvmalloc>
    800051ea:	8b2a                	mv	s6,a0
  ip = 0;
    800051ec:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800051ee:	12050c63          	beqz	a0,80005326 <exec+0x2c8>
  uvmclear(pagetable, sz-2*PGSIZE);
    800051f2:	75f9                	lui	a1,0xffffe
    800051f4:	95aa                	add	a1,a1,a0
    800051f6:	855e                	mv	a0,s7
    800051f8:	ffffc097          	auipc	ra,0xffffc
    800051fc:	462080e7          	jalr	1122(ra) # 8000165a <uvmclear>
  stackbase = sp - PGSIZE;
    80005200:	7c7d                	lui	s8,0xfffff
    80005202:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80005204:	e0043783          	ld	a5,-512(s0)
    80005208:	6388                	ld	a0,0(a5)
    8000520a:	c535                	beqz	a0,80005276 <exec+0x218>
    8000520c:	e9040993          	addi	s3,s0,-368
    80005210:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80005214:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80005216:	ffffc097          	auipc	ra,0xffffc
    8000521a:	c54080e7          	jalr	-940(ra) # 80000e6a <strlen>
    8000521e:	2505                	addiw	a0,a0,1
    80005220:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005224:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005228:	13896663          	bltu	s2,s8,80005354 <exec+0x2f6>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000522c:	e0043d83          	ld	s11,-512(s0)
    80005230:	000dba03          	ld	s4,0(s11)
    80005234:	8552                	mv	a0,s4
    80005236:	ffffc097          	auipc	ra,0xffffc
    8000523a:	c34080e7          	jalr	-972(ra) # 80000e6a <strlen>
    8000523e:	0015069b          	addiw	a3,a0,1
    80005242:	8652                	mv	a2,s4
    80005244:	85ca                	mv	a1,s2
    80005246:	855e                	mv	a0,s7
    80005248:	ffffc097          	auipc	ra,0xffffc
    8000524c:	444080e7          	jalr	1092(ra) # 8000168c <copyout>
    80005250:	10054663          	bltz	a0,8000535c <exec+0x2fe>
    ustack[argc] = sp;
    80005254:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005258:	0485                	addi	s1,s1,1
    8000525a:	008d8793          	addi	a5,s11,8
    8000525e:	e0f43023          	sd	a5,-512(s0)
    80005262:	008db503          	ld	a0,8(s11)
    80005266:	c911                	beqz	a0,8000527a <exec+0x21c>
    if(argc >= MAXARG)
    80005268:	09a1                	addi	s3,s3,8
    8000526a:	fb3c96e3          	bne	s9,s3,80005216 <exec+0x1b8>
  sz = sz1;
    8000526e:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005272:	4481                	li	s1,0
    80005274:	a84d                	j	80005326 <exec+0x2c8>
  sp = sz;
    80005276:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005278:	4481                	li	s1,0
  ustack[argc] = 0;
    8000527a:	00349793          	slli	a5,s1,0x3
    8000527e:	f9040713          	addi	a4,s0,-112
    80005282:	97ba                	add	a5,a5,a4
    80005284:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    80005288:	00148693          	addi	a3,s1,1
    8000528c:	068e                	slli	a3,a3,0x3
    8000528e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005292:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005296:	01897663          	bgeu	s2,s8,800052a2 <exec+0x244>
  sz = sz1;
    8000529a:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000529e:	4481                	li	s1,0
    800052a0:	a059                	j	80005326 <exec+0x2c8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800052a2:	e9040613          	addi	a2,s0,-368
    800052a6:	85ca                	mv	a1,s2
    800052a8:	855e                	mv	a0,s7
    800052aa:	ffffc097          	auipc	ra,0xffffc
    800052ae:	3e2080e7          	jalr	994(ra) # 8000168c <copyout>
    800052b2:	0a054963          	bltz	a0,80005364 <exec+0x306>
  p->trapframe->a1 = sp;
    800052b6:	060ab783          	ld	a5,96(s5)
    800052ba:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800052be:	df843783          	ld	a5,-520(s0)
    800052c2:	0007c703          	lbu	a4,0(a5)
    800052c6:	cf11                	beqz	a4,800052e2 <exec+0x284>
    800052c8:	0785                	addi	a5,a5,1
    if(*s == '/')
    800052ca:	02f00693          	li	a3,47
    800052ce:	a039                	j	800052dc <exec+0x27e>
      last = s+1;
    800052d0:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800052d4:	0785                	addi	a5,a5,1
    800052d6:	fff7c703          	lbu	a4,-1(a5)
    800052da:	c701                	beqz	a4,800052e2 <exec+0x284>
    if(*s == '/')
    800052dc:	fed71ce3          	bne	a4,a3,800052d4 <exec+0x276>
    800052e0:	bfc5                	j	800052d0 <exec+0x272>
  safestrcpy(p->name, last, sizeof(p->name));
    800052e2:	4641                	li	a2,16
    800052e4:	df843583          	ld	a1,-520(s0)
    800052e8:	160a8513          	addi	a0,s5,352
    800052ec:	ffffc097          	auipc	ra,0xffffc
    800052f0:	b4c080e7          	jalr	-1204(ra) # 80000e38 <safestrcpy>
  oldpagetable = p->pagetable;
    800052f4:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    800052f8:	057abc23          	sd	s7,88(s5)
  p->sz = sz;
    800052fc:	056ab823          	sd	s6,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005300:	060ab783          	ld	a5,96(s5)
    80005304:	e6843703          	ld	a4,-408(s0)
    80005308:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000530a:	060ab783          	ld	a5,96(s5)
    8000530e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005312:	85ea                	mv	a1,s10
    80005314:	ffffd097          	auipc	ra,0xffffd
    80005318:	a40080e7          	jalr	-1472(ra) # 80001d54 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000531c:	0004851b          	sext.w	a0,s1
    80005320:	bbd9                	j	800050f6 <exec+0x98>
    80005322:	e1443423          	sd	s4,-504(s0)
    proc_freepagetable(pagetable, sz);
    80005326:	e0843583          	ld	a1,-504(s0)
    8000532a:	855e                	mv	a0,s7
    8000532c:	ffffd097          	auipc	ra,0xffffd
    80005330:	a28080e7          	jalr	-1496(ra) # 80001d54 <proc_freepagetable>
  if(ip){
    80005334:	da0497e3          	bnez	s1,800050e2 <exec+0x84>
  return -1;
    80005338:	557d                	li	a0,-1
    8000533a:	bb75                	j	800050f6 <exec+0x98>
    8000533c:	e1443423          	sd	s4,-504(s0)
    80005340:	b7dd                	j	80005326 <exec+0x2c8>
    80005342:	e1443423          	sd	s4,-504(s0)
    80005346:	b7c5                	j	80005326 <exec+0x2c8>
    80005348:	e1443423          	sd	s4,-504(s0)
    8000534c:	bfe9                	j	80005326 <exec+0x2c8>
    8000534e:	e1443423          	sd	s4,-504(s0)
    80005352:	bfd1                	j	80005326 <exec+0x2c8>
  sz = sz1;
    80005354:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005358:	4481                	li	s1,0
    8000535a:	b7f1                	j	80005326 <exec+0x2c8>
  sz = sz1;
    8000535c:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005360:	4481                	li	s1,0
    80005362:	b7d1                	j	80005326 <exec+0x2c8>
  sz = sz1;
    80005364:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005368:	4481                	li	s1,0
    8000536a:	bf75                	j	80005326 <exec+0x2c8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000536c:	e0843a03          	ld	s4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005370:	2b05                	addiw	s6,s6,1
    80005372:	0389899b          	addiw	s3,s3,56
    80005376:	e8845783          	lhu	a5,-376(s0)
    8000537a:	e2fb57e3          	bge	s6,a5,800051a8 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000537e:	2981                	sext.w	s3,s3
    80005380:	03800713          	li	a4,56
    80005384:	86ce                	mv	a3,s3
    80005386:	e1840613          	addi	a2,s0,-488
    8000538a:	4581                	li	a1,0
    8000538c:	8526                	mv	a0,s1
    8000538e:	fffff097          	auipc	ra,0xfffff
    80005392:	a6e080e7          	jalr	-1426(ra) # 80003dfc <readi>
    80005396:	03800793          	li	a5,56
    8000539a:	f8f514e3          	bne	a0,a5,80005322 <exec+0x2c4>
    if(ph.type != ELF_PROG_LOAD)
    8000539e:	e1842783          	lw	a5,-488(s0)
    800053a2:	4705                	li	a4,1
    800053a4:	fce796e3          	bne	a5,a4,80005370 <exec+0x312>
    if(ph.memsz < ph.filesz)
    800053a8:	e4043903          	ld	s2,-448(s0)
    800053ac:	e3843783          	ld	a5,-456(s0)
    800053b0:	f8f966e3          	bltu	s2,a5,8000533c <exec+0x2de>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800053b4:	e2843783          	ld	a5,-472(s0)
    800053b8:	993e                	add	s2,s2,a5
    800053ba:	f8f964e3          	bltu	s2,a5,80005342 <exec+0x2e4>
    if(ph.vaddr % PGSIZE != 0)
    800053be:	df043703          	ld	a4,-528(s0)
    800053c2:	8ff9                	and	a5,a5,a4
    800053c4:	f3d1                	bnez	a5,80005348 <exec+0x2ea>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800053c6:	e1c42503          	lw	a0,-484(s0)
    800053ca:	00000097          	auipc	ra,0x0
    800053ce:	c78080e7          	jalr	-904(ra) # 80005042 <flags2perm>
    800053d2:	86aa                	mv	a3,a0
    800053d4:	864a                	mv	a2,s2
    800053d6:	85d2                	mv	a1,s4
    800053d8:	855e                	mv	a0,s7
    800053da:	ffffc097          	auipc	ra,0xffffc
    800053de:	05a080e7          	jalr	90(ra) # 80001434 <uvmalloc>
    800053e2:	e0a43423          	sd	a0,-504(s0)
    800053e6:	d525                	beqz	a0,8000534e <exec+0x2f0>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800053e8:	e2843d03          	ld	s10,-472(s0)
    800053ec:	e2042d83          	lw	s11,-480(s0)
    800053f0:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800053f4:	f60c0ce3          	beqz	s8,8000536c <exec+0x30e>
    800053f8:	8a62                	mv	s4,s8
    800053fa:	4901                	li	s2,0
    800053fc:	b369                	j	80005186 <exec+0x128>

00000000800053fe <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800053fe:	7179                	addi	sp,sp,-48
    80005400:	f406                	sd	ra,40(sp)
    80005402:	f022                	sd	s0,32(sp)
    80005404:	ec26                	sd	s1,24(sp)
    80005406:	e84a                	sd	s2,16(sp)
    80005408:	1800                	addi	s0,sp,48
    8000540a:	892e                	mv	s2,a1
    8000540c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000540e:	fdc40593          	addi	a1,s0,-36
    80005412:	ffffe097          	auipc	ra,0xffffe
    80005416:	9b0080e7          	jalr	-1616(ra) # 80002dc2 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000541a:	fdc42703          	lw	a4,-36(s0)
    8000541e:	47bd                	li	a5,15
    80005420:	02e7eb63          	bltu	a5,a4,80005456 <argfd+0x58>
    80005424:	ffffc097          	auipc	ra,0xffffc
    80005428:	7ce080e7          	jalr	1998(ra) # 80001bf2 <myproc>
    8000542c:	fdc42703          	lw	a4,-36(s0)
    80005430:	01a70793          	addi	a5,a4,26
    80005434:	078e                	slli	a5,a5,0x3
    80005436:	953e                	add	a0,a0,a5
    80005438:	651c                	ld	a5,8(a0)
    8000543a:	c385                	beqz	a5,8000545a <argfd+0x5c>
    return -1;
  if(pfd)
    8000543c:	00090463          	beqz	s2,80005444 <argfd+0x46>
    *pfd = fd;
    80005440:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005444:	4501                	li	a0,0
  if(pf)
    80005446:	c091                	beqz	s1,8000544a <argfd+0x4c>
    *pf = f;
    80005448:	e09c                	sd	a5,0(s1)
}
    8000544a:	70a2                	ld	ra,40(sp)
    8000544c:	7402                	ld	s0,32(sp)
    8000544e:	64e2                	ld	s1,24(sp)
    80005450:	6942                	ld	s2,16(sp)
    80005452:	6145                	addi	sp,sp,48
    80005454:	8082                	ret
    return -1;
    80005456:	557d                	li	a0,-1
    80005458:	bfcd                	j	8000544a <argfd+0x4c>
    8000545a:	557d                	li	a0,-1
    8000545c:	b7fd                	j	8000544a <argfd+0x4c>

000000008000545e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000545e:	1101                	addi	sp,sp,-32
    80005460:	ec06                	sd	ra,24(sp)
    80005462:	e822                	sd	s0,16(sp)
    80005464:	e426                	sd	s1,8(sp)
    80005466:	1000                	addi	s0,sp,32
    80005468:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000546a:	ffffc097          	auipc	ra,0xffffc
    8000546e:	788080e7          	jalr	1928(ra) # 80001bf2 <myproc>
    80005472:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005474:	0d850793          	addi	a5,a0,216 # fffffffffffff0d8 <end+0xffffffff7ffdac30>
    80005478:	4501                	li	a0,0
    8000547a:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000547c:	6398                	ld	a4,0(a5)
    8000547e:	cb19                	beqz	a4,80005494 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005480:	2505                	addiw	a0,a0,1
    80005482:	07a1                	addi	a5,a5,8
    80005484:	fed51ce3          	bne	a0,a3,8000547c <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005488:	557d                	li	a0,-1
}
    8000548a:	60e2                	ld	ra,24(sp)
    8000548c:	6442                	ld	s0,16(sp)
    8000548e:	64a2                	ld	s1,8(sp)
    80005490:	6105                	addi	sp,sp,32
    80005492:	8082                	ret
      p->ofile[fd] = f;
    80005494:	01a50793          	addi	a5,a0,26
    80005498:	078e                	slli	a5,a5,0x3
    8000549a:	963e                	add	a2,a2,a5
    8000549c:	e604                	sd	s1,8(a2)
      return fd;
    8000549e:	b7f5                	j	8000548a <fdalloc+0x2c>

00000000800054a0 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800054a0:	715d                	addi	sp,sp,-80
    800054a2:	e486                	sd	ra,72(sp)
    800054a4:	e0a2                	sd	s0,64(sp)
    800054a6:	fc26                	sd	s1,56(sp)
    800054a8:	f84a                	sd	s2,48(sp)
    800054aa:	f44e                	sd	s3,40(sp)
    800054ac:	f052                	sd	s4,32(sp)
    800054ae:	ec56                	sd	s5,24(sp)
    800054b0:	e85a                	sd	s6,16(sp)
    800054b2:	0880                	addi	s0,sp,80
    800054b4:	8b2e                	mv	s6,a1
    800054b6:	89b2                	mv	s3,a2
    800054b8:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800054ba:	fb040593          	addi	a1,s0,-80
    800054be:	fffff097          	auipc	ra,0xfffff
    800054c2:	e4e080e7          	jalr	-434(ra) # 8000430c <nameiparent>
    800054c6:	84aa                	mv	s1,a0
    800054c8:	16050063          	beqz	a0,80005628 <create+0x188>
    return 0;

  ilock(dp);
    800054cc:	ffffe097          	auipc	ra,0xffffe
    800054d0:	67c080e7          	jalr	1660(ra) # 80003b48 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800054d4:	4601                	li	a2,0
    800054d6:	fb040593          	addi	a1,s0,-80
    800054da:	8526                	mv	a0,s1
    800054dc:	fffff097          	auipc	ra,0xfffff
    800054e0:	b50080e7          	jalr	-1200(ra) # 8000402c <dirlookup>
    800054e4:	8aaa                	mv	s5,a0
    800054e6:	c931                	beqz	a0,8000553a <create+0x9a>
    iunlockput(dp);
    800054e8:	8526                	mv	a0,s1
    800054ea:	fffff097          	auipc	ra,0xfffff
    800054ee:	8c0080e7          	jalr	-1856(ra) # 80003daa <iunlockput>
    ilock(ip);
    800054f2:	8556                	mv	a0,s5
    800054f4:	ffffe097          	auipc	ra,0xffffe
    800054f8:	654080e7          	jalr	1620(ra) # 80003b48 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800054fc:	000b059b          	sext.w	a1,s6
    80005500:	4789                	li	a5,2
    80005502:	02f59563          	bne	a1,a5,8000552c <create+0x8c>
    80005506:	044ad783          	lhu	a5,68(s5)
    8000550a:	37f9                	addiw	a5,a5,-2
    8000550c:	17c2                	slli	a5,a5,0x30
    8000550e:	93c1                	srli	a5,a5,0x30
    80005510:	4705                	li	a4,1
    80005512:	00f76d63          	bltu	a4,a5,8000552c <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005516:	8556                	mv	a0,s5
    80005518:	60a6                	ld	ra,72(sp)
    8000551a:	6406                	ld	s0,64(sp)
    8000551c:	74e2                	ld	s1,56(sp)
    8000551e:	7942                	ld	s2,48(sp)
    80005520:	79a2                	ld	s3,40(sp)
    80005522:	7a02                	ld	s4,32(sp)
    80005524:	6ae2                	ld	s5,24(sp)
    80005526:	6b42                	ld	s6,16(sp)
    80005528:	6161                	addi	sp,sp,80
    8000552a:	8082                	ret
    iunlockput(ip);
    8000552c:	8556                	mv	a0,s5
    8000552e:	fffff097          	auipc	ra,0xfffff
    80005532:	87c080e7          	jalr	-1924(ra) # 80003daa <iunlockput>
    return 0;
    80005536:	4a81                	li	s5,0
    80005538:	bff9                	j	80005516 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000553a:	85da                	mv	a1,s6
    8000553c:	4088                	lw	a0,0(s1)
    8000553e:	ffffe097          	auipc	ra,0xffffe
    80005542:	46e080e7          	jalr	1134(ra) # 800039ac <ialloc>
    80005546:	8a2a                	mv	s4,a0
    80005548:	c921                	beqz	a0,80005598 <create+0xf8>
  ilock(ip);
    8000554a:	ffffe097          	auipc	ra,0xffffe
    8000554e:	5fe080e7          	jalr	1534(ra) # 80003b48 <ilock>
  ip->major = major;
    80005552:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005556:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000555a:	4785                	li	a5,1
    8000555c:	04fa1523          	sh	a5,74(s4)
  iupdate(ip);
    80005560:	8552                	mv	a0,s4
    80005562:	ffffe097          	auipc	ra,0xffffe
    80005566:	51c080e7          	jalr	1308(ra) # 80003a7e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000556a:	000b059b          	sext.w	a1,s6
    8000556e:	4785                	li	a5,1
    80005570:	02f58b63          	beq	a1,a5,800055a6 <create+0x106>
  if(dirlink(dp, name, ip->inum) < 0)
    80005574:	004a2603          	lw	a2,4(s4)
    80005578:	fb040593          	addi	a1,s0,-80
    8000557c:	8526                	mv	a0,s1
    8000557e:	fffff097          	auipc	ra,0xfffff
    80005582:	cbe080e7          	jalr	-834(ra) # 8000423c <dirlink>
    80005586:	06054f63          	bltz	a0,80005604 <create+0x164>
  iunlockput(dp);
    8000558a:	8526                	mv	a0,s1
    8000558c:	fffff097          	auipc	ra,0xfffff
    80005590:	81e080e7          	jalr	-2018(ra) # 80003daa <iunlockput>
  return ip;
    80005594:	8ad2                	mv	s5,s4
    80005596:	b741                	j	80005516 <create+0x76>
    iunlockput(dp);
    80005598:	8526                	mv	a0,s1
    8000559a:	fffff097          	auipc	ra,0xfffff
    8000559e:	810080e7          	jalr	-2032(ra) # 80003daa <iunlockput>
    return 0;
    800055a2:	8ad2                	mv	s5,s4
    800055a4:	bf8d                	j	80005516 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800055a6:	004a2603          	lw	a2,4(s4)
    800055aa:	00003597          	auipc	a1,0x3
    800055ae:	27e58593          	addi	a1,a1,638 # 80008828 <syscalls+0x2b8>
    800055b2:	8552                	mv	a0,s4
    800055b4:	fffff097          	auipc	ra,0xfffff
    800055b8:	c88080e7          	jalr	-888(ra) # 8000423c <dirlink>
    800055bc:	04054463          	bltz	a0,80005604 <create+0x164>
    800055c0:	40d0                	lw	a2,4(s1)
    800055c2:	00003597          	auipc	a1,0x3
    800055c6:	26e58593          	addi	a1,a1,622 # 80008830 <syscalls+0x2c0>
    800055ca:	8552                	mv	a0,s4
    800055cc:	fffff097          	auipc	ra,0xfffff
    800055d0:	c70080e7          	jalr	-912(ra) # 8000423c <dirlink>
    800055d4:	02054863          	bltz	a0,80005604 <create+0x164>
  if(dirlink(dp, name, ip->inum) < 0)
    800055d8:	004a2603          	lw	a2,4(s4)
    800055dc:	fb040593          	addi	a1,s0,-80
    800055e0:	8526                	mv	a0,s1
    800055e2:	fffff097          	auipc	ra,0xfffff
    800055e6:	c5a080e7          	jalr	-934(ra) # 8000423c <dirlink>
    800055ea:	00054d63          	bltz	a0,80005604 <create+0x164>
    dp->nlink++;  // for ".."
    800055ee:	04a4d783          	lhu	a5,74(s1)
    800055f2:	2785                	addiw	a5,a5,1
    800055f4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800055f8:	8526                	mv	a0,s1
    800055fa:	ffffe097          	auipc	ra,0xffffe
    800055fe:	484080e7          	jalr	1156(ra) # 80003a7e <iupdate>
    80005602:	b761                	j	8000558a <create+0xea>
  ip->nlink = 0;
    80005604:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005608:	8552                	mv	a0,s4
    8000560a:	ffffe097          	auipc	ra,0xffffe
    8000560e:	474080e7          	jalr	1140(ra) # 80003a7e <iupdate>
  iunlockput(ip);
    80005612:	8552                	mv	a0,s4
    80005614:	ffffe097          	auipc	ra,0xffffe
    80005618:	796080e7          	jalr	1942(ra) # 80003daa <iunlockput>
  iunlockput(dp);
    8000561c:	8526                	mv	a0,s1
    8000561e:	ffffe097          	auipc	ra,0xffffe
    80005622:	78c080e7          	jalr	1932(ra) # 80003daa <iunlockput>
  return 0;
    80005626:	bdc5                	j	80005516 <create+0x76>
    return 0;
    80005628:	8aaa                	mv	s5,a0
    8000562a:	b5f5                	j	80005516 <create+0x76>

000000008000562c <sys_dup>:
{
    8000562c:	7179                	addi	sp,sp,-48
    8000562e:	f406                	sd	ra,40(sp)
    80005630:	f022                	sd	s0,32(sp)
    80005632:	ec26                	sd	s1,24(sp)
    80005634:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005636:	fd840613          	addi	a2,s0,-40
    8000563a:	4581                	li	a1,0
    8000563c:	4501                	li	a0,0
    8000563e:	00000097          	auipc	ra,0x0
    80005642:	dc0080e7          	jalr	-576(ra) # 800053fe <argfd>
    return -1;
    80005646:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005648:	02054363          	bltz	a0,8000566e <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000564c:	fd843503          	ld	a0,-40(s0)
    80005650:	00000097          	auipc	ra,0x0
    80005654:	e0e080e7          	jalr	-498(ra) # 8000545e <fdalloc>
    80005658:	84aa                	mv	s1,a0
    return -1;
    8000565a:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000565c:	00054963          	bltz	a0,8000566e <sys_dup+0x42>
  filedup(f);
    80005660:	fd843503          	ld	a0,-40(s0)
    80005664:	fffff097          	auipc	ra,0xfffff
    80005668:	320080e7          	jalr	800(ra) # 80004984 <filedup>
  return fd;
    8000566c:	87a6                	mv	a5,s1
}
    8000566e:	853e                	mv	a0,a5
    80005670:	70a2                	ld	ra,40(sp)
    80005672:	7402                	ld	s0,32(sp)
    80005674:	64e2                	ld	s1,24(sp)
    80005676:	6145                	addi	sp,sp,48
    80005678:	8082                	ret

000000008000567a <sys_read>:
{
    8000567a:	7179                	addi	sp,sp,-48
    8000567c:	f406                	sd	ra,40(sp)
    8000567e:	f022                	sd	s0,32(sp)
    80005680:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005682:	fd840593          	addi	a1,s0,-40
    80005686:	4505                	li	a0,1
    80005688:	ffffd097          	auipc	ra,0xffffd
    8000568c:	75a080e7          	jalr	1882(ra) # 80002de2 <argaddr>
  argint(2, &n);
    80005690:	fe440593          	addi	a1,s0,-28
    80005694:	4509                	li	a0,2
    80005696:	ffffd097          	auipc	ra,0xffffd
    8000569a:	72c080e7          	jalr	1836(ra) # 80002dc2 <argint>
  if(argfd(0, 0, &f) < 0)
    8000569e:	fe840613          	addi	a2,s0,-24
    800056a2:	4581                	li	a1,0
    800056a4:	4501                	li	a0,0
    800056a6:	00000097          	auipc	ra,0x0
    800056aa:	d58080e7          	jalr	-680(ra) # 800053fe <argfd>
    800056ae:	87aa                	mv	a5,a0
    return -1;
    800056b0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800056b2:	0007cc63          	bltz	a5,800056ca <sys_read+0x50>
  return fileread(f, p, n);
    800056b6:	fe442603          	lw	a2,-28(s0)
    800056ba:	fd843583          	ld	a1,-40(s0)
    800056be:	fe843503          	ld	a0,-24(s0)
    800056c2:	fffff097          	auipc	ra,0xfffff
    800056c6:	44e080e7          	jalr	1102(ra) # 80004b10 <fileread>
}
    800056ca:	70a2                	ld	ra,40(sp)
    800056cc:	7402                	ld	s0,32(sp)
    800056ce:	6145                	addi	sp,sp,48
    800056d0:	8082                	ret

00000000800056d2 <sys_write>:
{
    800056d2:	7179                	addi	sp,sp,-48
    800056d4:	f406                	sd	ra,40(sp)
    800056d6:	f022                	sd	s0,32(sp)
    800056d8:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800056da:	fd840593          	addi	a1,s0,-40
    800056de:	4505                	li	a0,1
    800056e0:	ffffd097          	auipc	ra,0xffffd
    800056e4:	702080e7          	jalr	1794(ra) # 80002de2 <argaddr>
  argint(2, &n);
    800056e8:	fe440593          	addi	a1,s0,-28
    800056ec:	4509                	li	a0,2
    800056ee:	ffffd097          	auipc	ra,0xffffd
    800056f2:	6d4080e7          	jalr	1748(ra) # 80002dc2 <argint>
  if(argfd(0, 0, &f) < 0)
    800056f6:	fe840613          	addi	a2,s0,-24
    800056fa:	4581                	li	a1,0
    800056fc:	4501                	li	a0,0
    800056fe:	00000097          	auipc	ra,0x0
    80005702:	d00080e7          	jalr	-768(ra) # 800053fe <argfd>
    80005706:	87aa                	mv	a5,a0
    return -1;
    80005708:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000570a:	0007cc63          	bltz	a5,80005722 <sys_write+0x50>
  return filewrite(f, p, n);
    8000570e:	fe442603          	lw	a2,-28(s0)
    80005712:	fd843583          	ld	a1,-40(s0)
    80005716:	fe843503          	ld	a0,-24(s0)
    8000571a:	fffff097          	auipc	ra,0xfffff
    8000571e:	4b8080e7          	jalr	1208(ra) # 80004bd2 <filewrite>
}
    80005722:	70a2                	ld	ra,40(sp)
    80005724:	7402                	ld	s0,32(sp)
    80005726:	6145                	addi	sp,sp,48
    80005728:	8082                	ret

000000008000572a <sys_close>:
{
    8000572a:	1101                	addi	sp,sp,-32
    8000572c:	ec06                	sd	ra,24(sp)
    8000572e:	e822                	sd	s0,16(sp)
    80005730:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005732:	fe040613          	addi	a2,s0,-32
    80005736:	fec40593          	addi	a1,s0,-20
    8000573a:	4501                	li	a0,0
    8000573c:	00000097          	auipc	ra,0x0
    80005740:	cc2080e7          	jalr	-830(ra) # 800053fe <argfd>
    return -1;
    80005744:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005746:	02054463          	bltz	a0,8000576e <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000574a:	ffffc097          	auipc	ra,0xffffc
    8000574e:	4a8080e7          	jalr	1192(ra) # 80001bf2 <myproc>
    80005752:	fec42783          	lw	a5,-20(s0)
    80005756:	07e9                	addi	a5,a5,26
    80005758:	078e                	slli	a5,a5,0x3
    8000575a:	97aa                	add	a5,a5,a0
    8000575c:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    80005760:	fe043503          	ld	a0,-32(s0)
    80005764:	fffff097          	auipc	ra,0xfffff
    80005768:	272080e7          	jalr	626(ra) # 800049d6 <fileclose>
  return 0;
    8000576c:	4781                	li	a5,0
}
    8000576e:	853e                	mv	a0,a5
    80005770:	60e2                	ld	ra,24(sp)
    80005772:	6442                	ld	s0,16(sp)
    80005774:	6105                	addi	sp,sp,32
    80005776:	8082                	ret

0000000080005778 <sys_fstat>:
{
    80005778:	1101                	addi	sp,sp,-32
    8000577a:	ec06                	sd	ra,24(sp)
    8000577c:	e822                	sd	s0,16(sp)
    8000577e:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005780:	fe040593          	addi	a1,s0,-32
    80005784:	4505                	li	a0,1
    80005786:	ffffd097          	auipc	ra,0xffffd
    8000578a:	65c080e7          	jalr	1628(ra) # 80002de2 <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000578e:	fe840613          	addi	a2,s0,-24
    80005792:	4581                	li	a1,0
    80005794:	4501                	li	a0,0
    80005796:	00000097          	auipc	ra,0x0
    8000579a:	c68080e7          	jalr	-920(ra) # 800053fe <argfd>
    8000579e:	87aa                	mv	a5,a0
    return -1;
    800057a0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800057a2:	0007ca63          	bltz	a5,800057b6 <sys_fstat+0x3e>
  return filestat(f, st);
    800057a6:	fe043583          	ld	a1,-32(s0)
    800057aa:	fe843503          	ld	a0,-24(s0)
    800057ae:	fffff097          	auipc	ra,0xfffff
    800057b2:	2f0080e7          	jalr	752(ra) # 80004a9e <filestat>
}
    800057b6:	60e2                	ld	ra,24(sp)
    800057b8:	6442                	ld	s0,16(sp)
    800057ba:	6105                	addi	sp,sp,32
    800057bc:	8082                	ret

00000000800057be <sys_link>:
{
    800057be:	7169                	addi	sp,sp,-304
    800057c0:	f606                	sd	ra,296(sp)
    800057c2:	f222                	sd	s0,288(sp)
    800057c4:	ee26                	sd	s1,280(sp)
    800057c6:	ea4a                	sd	s2,272(sp)
    800057c8:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800057ca:	08000613          	li	a2,128
    800057ce:	ed040593          	addi	a1,s0,-304
    800057d2:	4501                	li	a0,0
    800057d4:	ffffd097          	auipc	ra,0xffffd
    800057d8:	62e080e7          	jalr	1582(ra) # 80002e02 <argstr>
    return -1;
    800057dc:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800057de:	10054e63          	bltz	a0,800058fa <sys_link+0x13c>
    800057e2:	08000613          	li	a2,128
    800057e6:	f5040593          	addi	a1,s0,-176
    800057ea:	4505                	li	a0,1
    800057ec:	ffffd097          	auipc	ra,0xffffd
    800057f0:	616080e7          	jalr	1558(ra) # 80002e02 <argstr>
    return -1;
    800057f4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800057f6:	10054263          	bltz	a0,800058fa <sys_link+0x13c>
  begin_op();
    800057fa:	fffff097          	auipc	ra,0xfffff
    800057fe:	d10080e7          	jalr	-752(ra) # 8000450a <begin_op>
  if((ip = namei(old)) == 0){
    80005802:	ed040513          	addi	a0,s0,-304
    80005806:	fffff097          	auipc	ra,0xfffff
    8000580a:	ae8080e7          	jalr	-1304(ra) # 800042ee <namei>
    8000580e:	84aa                	mv	s1,a0
    80005810:	c551                	beqz	a0,8000589c <sys_link+0xde>
  ilock(ip);
    80005812:	ffffe097          	auipc	ra,0xffffe
    80005816:	336080e7          	jalr	822(ra) # 80003b48 <ilock>
  if(ip->type == T_DIR){
    8000581a:	04449703          	lh	a4,68(s1)
    8000581e:	4785                	li	a5,1
    80005820:	08f70463          	beq	a4,a5,800058a8 <sys_link+0xea>
  ip->nlink++;
    80005824:	04a4d783          	lhu	a5,74(s1)
    80005828:	2785                	addiw	a5,a5,1
    8000582a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000582e:	8526                	mv	a0,s1
    80005830:	ffffe097          	auipc	ra,0xffffe
    80005834:	24e080e7          	jalr	590(ra) # 80003a7e <iupdate>
  iunlock(ip);
    80005838:	8526                	mv	a0,s1
    8000583a:	ffffe097          	auipc	ra,0xffffe
    8000583e:	3d0080e7          	jalr	976(ra) # 80003c0a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005842:	fd040593          	addi	a1,s0,-48
    80005846:	f5040513          	addi	a0,s0,-176
    8000584a:	fffff097          	auipc	ra,0xfffff
    8000584e:	ac2080e7          	jalr	-1342(ra) # 8000430c <nameiparent>
    80005852:	892a                	mv	s2,a0
    80005854:	c935                	beqz	a0,800058c8 <sys_link+0x10a>
  ilock(dp);
    80005856:	ffffe097          	auipc	ra,0xffffe
    8000585a:	2f2080e7          	jalr	754(ra) # 80003b48 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000585e:	00092703          	lw	a4,0(s2)
    80005862:	409c                	lw	a5,0(s1)
    80005864:	04f71d63          	bne	a4,a5,800058be <sys_link+0x100>
    80005868:	40d0                	lw	a2,4(s1)
    8000586a:	fd040593          	addi	a1,s0,-48
    8000586e:	854a                	mv	a0,s2
    80005870:	fffff097          	auipc	ra,0xfffff
    80005874:	9cc080e7          	jalr	-1588(ra) # 8000423c <dirlink>
    80005878:	04054363          	bltz	a0,800058be <sys_link+0x100>
  iunlockput(dp);
    8000587c:	854a                	mv	a0,s2
    8000587e:	ffffe097          	auipc	ra,0xffffe
    80005882:	52c080e7          	jalr	1324(ra) # 80003daa <iunlockput>
  iput(ip);
    80005886:	8526                	mv	a0,s1
    80005888:	ffffe097          	auipc	ra,0xffffe
    8000588c:	47a080e7          	jalr	1146(ra) # 80003d02 <iput>
  end_op();
    80005890:	fffff097          	auipc	ra,0xfffff
    80005894:	cfa080e7          	jalr	-774(ra) # 8000458a <end_op>
  return 0;
    80005898:	4781                	li	a5,0
    8000589a:	a085                	j	800058fa <sys_link+0x13c>
    end_op();
    8000589c:	fffff097          	auipc	ra,0xfffff
    800058a0:	cee080e7          	jalr	-786(ra) # 8000458a <end_op>
    return -1;
    800058a4:	57fd                	li	a5,-1
    800058a6:	a891                	j	800058fa <sys_link+0x13c>
    iunlockput(ip);
    800058a8:	8526                	mv	a0,s1
    800058aa:	ffffe097          	auipc	ra,0xffffe
    800058ae:	500080e7          	jalr	1280(ra) # 80003daa <iunlockput>
    end_op();
    800058b2:	fffff097          	auipc	ra,0xfffff
    800058b6:	cd8080e7          	jalr	-808(ra) # 8000458a <end_op>
    return -1;
    800058ba:	57fd                	li	a5,-1
    800058bc:	a83d                	j	800058fa <sys_link+0x13c>
    iunlockput(dp);
    800058be:	854a                	mv	a0,s2
    800058c0:	ffffe097          	auipc	ra,0xffffe
    800058c4:	4ea080e7          	jalr	1258(ra) # 80003daa <iunlockput>
  ilock(ip);
    800058c8:	8526                	mv	a0,s1
    800058ca:	ffffe097          	auipc	ra,0xffffe
    800058ce:	27e080e7          	jalr	638(ra) # 80003b48 <ilock>
  ip->nlink--;
    800058d2:	04a4d783          	lhu	a5,74(s1)
    800058d6:	37fd                	addiw	a5,a5,-1
    800058d8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800058dc:	8526                	mv	a0,s1
    800058de:	ffffe097          	auipc	ra,0xffffe
    800058e2:	1a0080e7          	jalr	416(ra) # 80003a7e <iupdate>
  iunlockput(ip);
    800058e6:	8526                	mv	a0,s1
    800058e8:	ffffe097          	auipc	ra,0xffffe
    800058ec:	4c2080e7          	jalr	1218(ra) # 80003daa <iunlockput>
  end_op();
    800058f0:	fffff097          	auipc	ra,0xfffff
    800058f4:	c9a080e7          	jalr	-870(ra) # 8000458a <end_op>
  return -1;
    800058f8:	57fd                	li	a5,-1
}
    800058fa:	853e                	mv	a0,a5
    800058fc:	70b2                	ld	ra,296(sp)
    800058fe:	7412                	ld	s0,288(sp)
    80005900:	64f2                	ld	s1,280(sp)
    80005902:	6952                	ld	s2,272(sp)
    80005904:	6155                	addi	sp,sp,304
    80005906:	8082                	ret

0000000080005908 <sys_unlink>:
{
    80005908:	7151                	addi	sp,sp,-240
    8000590a:	f586                	sd	ra,232(sp)
    8000590c:	f1a2                	sd	s0,224(sp)
    8000590e:	eda6                	sd	s1,216(sp)
    80005910:	e9ca                	sd	s2,208(sp)
    80005912:	e5ce                	sd	s3,200(sp)
    80005914:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005916:	08000613          	li	a2,128
    8000591a:	f3040593          	addi	a1,s0,-208
    8000591e:	4501                	li	a0,0
    80005920:	ffffd097          	auipc	ra,0xffffd
    80005924:	4e2080e7          	jalr	1250(ra) # 80002e02 <argstr>
    80005928:	18054163          	bltz	a0,80005aaa <sys_unlink+0x1a2>
  begin_op();
    8000592c:	fffff097          	auipc	ra,0xfffff
    80005930:	bde080e7          	jalr	-1058(ra) # 8000450a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005934:	fb040593          	addi	a1,s0,-80
    80005938:	f3040513          	addi	a0,s0,-208
    8000593c:	fffff097          	auipc	ra,0xfffff
    80005940:	9d0080e7          	jalr	-1584(ra) # 8000430c <nameiparent>
    80005944:	84aa                	mv	s1,a0
    80005946:	c979                	beqz	a0,80005a1c <sys_unlink+0x114>
  ilock(dp);
    80005948:	ffffe097          	auipc	ra,0xffffe
    8000594c:	200080e7          	jalr	512(ra) # 80003b48 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005950:	00003597          	auipc	a1,0x3
    80005954:	ed858593          	addi	a1,a1,-296 # 80008828 <syscalls+0x2b8>
    80005958:	fb040513          	addi	a0,s0,-80
    8000595c:	ffffe097          	auipc	ra,0xffffe
    80005960:	6b6080e7          	jalr	1718(ra) # 80004012 <namecmp>
    80005964:	14050a63          	beqz	a0,80005ab8 <sys_unlink+0x1b0>
    80005968:	00003597          	auipc	a1,0x3
    8000596c:	ec858593          	addi	a1,a1,-312 # 80008830 <syscalls+0x2c0>
    80005970:	fb040513          	addi	a0,s0,-80
    80005974:	ffffe097          	auipc	ra,0xffffe
    80005978:	69e080e7          	jalr	1694(ra) # 80004012 <namecmp>
    8000597c:	12050e63          	beqz	a0,80005ab8 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005980:	f2c40613          	addi	a2,s0,-212
    80005984:	fb040593          	addi	a1,s0,-80
    80005988:	8526                	mv	a0,s1
    8000598a:	ffffe097          	auipc	ra,0xffffe
    8000598e:	6a2080e7          	jalr	1698(ra) # 8000402c <dirlookup>
    80005992:	892a                	mv	s2,a0
    80005994:	12050263          	beqz	a0,80005ab8 <sys_unlink+0x1b0>
  ilock(ip);
    80005998:	ffffe097          	auipc	ra,0xffffe
    8000599c:	1b0080e7          	jalr	432(ra) # 80003b48 <ilock>
  if(ip->nlink < 1)
    800059a0:	04a91783          	lh	a5,74(s2)
    800059a4:	08f05263          	blez	a5,80005a28 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800059a8:	04491703          	lh	a4,68(s2)
    800059ac:	4785                	li	a5,1
    800059ae:	08f70563          	beq	a4,a5,80005a38 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800059b2:	4641                	li	a2,16
    800059b4:	4581                	li	a1,0
    800059b6:	fc040513          	addi	a0,s0,-64
    800059ba:	ffffb097          	auipc	ra,0xffffb
    800059be:	32c080e7          	jalr	812(ra) # 80000ce6 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800059c2:	4741                	li	a4,16
    800059c4:	f2c42683          	lw	a3,-212(s0)
    800059c8:	fc040613          	addi	a2,s0,-64
    800059cc:	4581                	li	a1,0
    800059ce:	8526                	mv	a0,s1
    800059d0:	ffffe097          	auipc	ra,0xffffe
    800059d4:	524080e7          	jalr	1316(ra) # 80003ef4 <writei>
    800059d8:	47c1                	li	a5,16
    800059da:	0af51563          	bne	a0,a5,80005a84 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800059de:	04491703          	lh	a4,68(s2)
    800059e2:	4785                	li	a5,1
    800059e4:	0af70863          	beq	a4,a5,80005a94 <sys_unlink+0x18c>
  iunlockput(dp);
    800059e8:	8526                	mv	a0,s1
    800059ea:	ffffe097          	auipc	ra,0xffffe
    800059ee:	3c0080e7          	jalr	960(ra) # 80003daa <iunlockput>
  ip->nlink--;
    800059f2:	04a95783          	lhu	a5,74(s2)
    800059f6:	37fd                	addiw	a5,a5,-1
    800059f8:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800059fc:	854a                	mv	a0,s2
    800059fe:	ffffe097          	auipc	ra,0xffffe
    80005a02:	080080e7          	jalr	128(ra) # 80003a7e <iupdate>
  iunlockput(ip);
    80005a06:	854a                	mv	a0,s2
    80005a08:	ffffe097          	auipc	ra,0xffffe
    80005a0c:	3a2080e7          	jalr	930(ra) # 80003daa <iunlockput>
  end_op();
    80005a10:	fffff097          	auipc	ra,0xfffff
    80005a14:	b7a080e7          	jalr	-1158(ra) # 8000458a <end_op>
  return 0;
    80005a18:	4501                	li	a0,0
    80005a1a:	a84d                	j	80005acc <sys_unlink+0x1c4>
    end_op();
    80005a1c:	fffff097          	auipc	ra,0xfffff
    80005a20:	b6e080e7          	jalr	-1170(ra) # 8000458a <end_op>
    return -1;
    80005a24:	557d                	li	a0,-1
    80005a26:	a05d                	j	80005acc <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005a28:	00003517          	auipc	a0,0x3
    80005a2c:	e1050513          	addi	a0,a0,-496 # 80008838 <syscalls+0x2c8>
    80005a30:	ffffb097          	auipc	ra,0xffffb
    80005a34:	b14080e7          	jalr	-1260(ra) # 80000544 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005a38:	04c92703          	lw	a4,76(s2)
    80005a3c:	02000793          	li	a5,32
    80005a40:	f6e7f9e3          	bgeu	a5,a4,800059b2 <sys_unlink+0xaa>
    80005a44:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005a48:	4741                	li	a4,16
    80005a4a:	86ce                	mv	a3,s3
    80005a4c:	f1840613          	addi	a2,s0,-232
    80005a50:	4581                	li	a1,0
    80005a52:	854a                	mv	a0,s2
    80005a54:	ffffe097          	auipc	ra,0xffffe
    80005a58:	3a8080e7          	jalr	936(ra) # 80003dfc <readi>
    80005a5c:	47c1                	li	a5,16
    80005a5e:	00f51b63          	bne	a0,a5,80005a74 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005a62:	f1845783          	lhu	a5,-232(s0)
    80005a66:	e7a1                	bnez	a5,80005aae <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005a68:	29c1                	addiw	s3,s3,16
    80005a6a:	04c92783          	lw	a5,76(s2)
    80005a6e:	fcf9ede3          	bltu	s3,a5,80005a48 <sys_unlink+0x140>
    80005a72:	b781                	j	800059b2 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005a74:	00003517          	auipc	a0,0x3
    80005a78:	ddc50513          	addi	a0,a0,-548 # 80008850 <syscalls+0x2e0>
    80005a7c:	ffffb097          	auipc	ra,0xffffb
    80005a80:	ac8080e7          	jalr	-1336(ra) # 80000544 <panic>
    panic("unlink: writei");
    80005a84:	00003517          	auipc	a0,0x3
    80005a88:	de450513          	addi	a0,a0,-540 # 80008868 <syscalls+0x2f8>
    80005a8c:	ffffb097          	auipc	ra,0xffffb
    80005a90:	ab8080e7          	jalr	-1352(ra) # 80000544 <panic>
    dp->nlink--;
    80005a94:	04a4d783          	lhu	a5,74(s1)
    80005a98:	37fd                	addiw	a5,a5,-1
    80005a9a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005a9e:	8526                	mv	a0,s1
    80005aa0:	ffffe097          	auipc	ra,0xffffe
    80005aa4:	fde080e7          	jalr	-34(ra) # 80003a7e <iupdate>
    80005aa8:	b781                	j	800059e8 <sys_unlink+0xe0>
    return -1;
    80005aaa:	557d                	li	a0,-1
    80005aac:	a005                	j	80005acc <sys_unlink+0x1c4>
    iunlockput(ip);
    80005aae:	854a                	mv	a0,s2
    80005ab0:	ffffe097          	auipc	ra,0xffffe
    80005ab4:	2fa080e7          	jalr	762(ra) # 80003daa <iunlockput>
  iunlockput(dp);
    80005ab8:	8526                	mv	a0,s1
    80005aba:	ffffe097          	auipc	ra,0xffffe
    80005abe:	2f0080e7          	jalr	752(ra) # 80003daa <iunlockput>
  end_op();
    80005ac2:	fffff097          	auipc	ra,0xfffff
    80005ac6:	ac8080e7          	jalr	-1336(ra) # 8000458a <end_op>
  return -1;
    80005aca:	557d                	li	a0,-1
}
    80005acc:	70ae                	ld	ra,232(sp)
    80005ace:	740e                	ld	s0,224(sp)
    80005ad0:	64ee                	ld	s1,216(sp)
    80005ad2:	694e                	ld	s2,208(sp)
    80005ad4:	69ae                	ld	s3,200(sp)
    80005ad6:	616d                	addi	sp,sp,240
    80005ad8:	8082                	ret

0000000080005ada <sys_open>:

uint64
sys_open(void)
{
    80005ada:	7131                	addi	sp,sp,-192
    80005adc:	fd06                	sd	ra,184(sp)
    80005ade:	f922                	sd	s0,176(sp)
    80005ae0:	f526                	sd	s1,168(sp)
    80005ae2:	f14a                	sd	s2,160(sp)
    80005ae4:	ed4e                	sd	s3,152(sp)
    80005ae6:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005ae8:	f4c40593          	addi	a1,s0,-180
    80005aec:	4505                	li	a0,1
    80005aee:	ffffd097          	auipc	ra,0xffffd
    80005af2:	2d4080e7          	jalr	724(ra) # 80002dc2 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005af6:	08000613          	li	a2,128
    80005afa:	f5040593          	addi	a1,s0,-176
    80005afe:	4501                	li	a0,0
    80005b00:	ffffd097          	auipc	ra,0xffffd
    80005b04:	302080e7          	jalr	770(ra) # 80002e02 <argstr>
    80005b08:	87aa                	mv	a5,a0
    return -1;
    80005b0a:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005b0c:	0a07c963          	bltz	a5,80005bbe <sys_open+0xe4>

  begin_op();
    80005b10:	fffff097          	auipc	ra,0xfffff
    80005b14:	9fa080e7          	jalr	-1542(ra) # 8000450a <begin_op>

  if(omode & O_CREATE){
    80005b18:	f4c42783          	lw	a5,-180(s0)
    80005b1c:	2007f793          	andi	a5,a5,512
    80005b20:	cfc5                	beqz	a5,80005bd8 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005b22:	4681                	li	a3,0
    80005b24:	4601                	li	a2,0
    80005b26:	4589                	li	a1,2
    80005b28:	f5040513          	addi	a0,s0,-176
    80005b2c:	00000097          	auipc	ra,0x0
    80005b30:	974080e7          	jalr	-1676(ra) # 800054a0 <create>
    80005b34:	84aa                	mv	s1,a0
    if(ip == 0){
    80005b36:	c959                	beqz	a0,80005bcc <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005b38:	04449703          	lh	a4,68(s1)
    80005b3c:	478d                	li	a5,3
    80005b3e:	00f71763          	bne	a4,a5,80005b4c <sys_open+0x72>
    80005b42:	0464d703          	lhu	a4,70(s1)
    80005b46:	47a5                	li	a5,9
    80005b48:	0ce7ed63          	bltu	a5,a4,80005c22 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005b4c:	fffff097          	auipc	ra,0xfffff
    80005b50:	dce080e7          	jalr	-562(ra) # 8000491a <filealloc>
    80005b54:	89aa                	mv	s3,a0
    80005b56:	10050363          	beqz	a0,80005c5c <sys_open+0x182>
    80005b5a:	00000097          	auipc	ra,0x0
    80005b5e:	904080e7          	jalr	-1788(ra) # 8000545e <fdalloc>
    80005b62:	892a                	mv	s2,a0
    80005b64:	0e054763          	bltz	a0,80005c52 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005b68:	04449703          	lh	a4,68(s1)
    80005b6c:	478d                	li	a5,3
    80005b6e:	0cf70563          	beq	a4,a5,80005c38 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005b72:	4789                	li	a5,2
    80005b74:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005b78:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005b7c:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005b80:	f4c42783          	lw	a5,-180(s0)
    80005b84:	0017c713          	xori	a4,a5,1
    80005b88:	8b05                	andi	a4,a4,1
    80005b8a:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005b8e:	0037f713          	andi	a4,a5,3
    80005b92:	00e03733          	snez	a4,a4
    80005b96:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005b9a:	4007f793          	andi	a5,a5,1024
    80005b9e:	c791                	beqz	a5,80005baa <sys_open+0xd0>
    80005ba0:	04449703          	lh	a4,68(s1)
    80005ba4:	4789                	li	a5,2
    80005ba6:	0af70063          	beq	a4,a5,80005c46 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005baa:	8526                	mv	a0,s1
    80005bac:	ffffe097          	auipc	ra,0xffffe
    80005bb0:	05e080e7          	jalr	94(ra) # 80003c0a <iunlock>
  end_op();
    80005bb4:	fffff097          	auipc	ra,0xfffff
    80005bb8:	9d6080e7          	jalr	-1578(ra) # 8000458a <end_op>

  return fd;
    80005bbc:	854a                	mv	a0,s2
}
    80005bbe:	70ea                	ld	ra,184(sp)
    80005bc0:	744a                	ld	s0,176(sp)
    80005bc2:	74aa                	ld	s1,168(sp)
    80005bc4:	790a                	ld	s2,160(sp)
    80005bc6:	69ea                	ld	s3,152(sp)
    80005bc8:	6129                	addi	sp,sp,192
    80005bca:	8082                	ret
      end_op();
    80005bcc:	fffff097          	auipc	ra,0xfffff
    80005bd0:	9be080e7          	jalr	-1602(ra) # 8000458a <end_op>
      return -1;
    80005bd4:	557d                	li	a0,-1
    80005bd6:	b7e5                	j	80005bbe <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005bd8:	f5040513          	addi	a0,s0,-176
    80005bdc:	ffffe097          	auipc	ra,0xffffe
    80005be0:	712080e7          	jalr	1810(ra) # 800042ee <namei>
    80005be4:	84aa                	mv	s1,a0
    80005be6:	c905                	beqz	a0,80005c16 <sys_open+0x13c>
    ilock(ip);
    80005be8:	ffffe097          	auipc	ra,0xffffe
    80005bec:	f60080e7          	jalr	-160(ra) # 80003b48 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005bf0:	04449703          	lh	a4,68(s1)
    80005bf4:	4785                	li	a5,1
    80005bf6:	f4f711e3          	bne	a4,a5,80005b38 <sys_open+0x5e>
    80005bfa:	f4c42783          	lw	a5,-180(s0)
    80005bfe:	d7b9                	beqz	a5,80005b4c <sys_open+0x72>
      iunlockput(ip);
    80005c00:	8526                	mv	a0,s1
    80005c02:	ffffe097          	auipc	ra,0xffffe
    80005c06:	1a8080e7          	jalr	424(ra) # 80003daa <iunlockput>
      end_op();
    80005c0a:	fffff097          	auipc	ra,0xfffff
    80005c0e:	980080e7          	jalr	-1664(ra) # 8000458a <end_op>
      return -1;
    80005c12:	557d                	li	a0,-1
    80005c14:	b76d                	j	80005bbe <sys_open+0xe4>
      end_op();
    80005c16:	fffff097          	auipc	ra,0xfffff
    80005c1a:	974080e7          	jalr	-1676(ra) # 8000458a <end_op>
      return -1;
    80005c1e:	557d                	li	a0,-1
    80005c20:	bf79                	j	80005bbe <sys_open+0xe4>
    iunlockput(ip);
    80005c22:	8526                	mv	a0,s1
    80005c24:	ffffe097          	auipc	ra,0xffffe
    80005c28:	186080e7          	jalr	390(ra) # 80003daa <iunlockput>
    end_op();
    80005c2c:	fffff097          	auipc	ra,0xfffff
    80005c30:	95e080e7          	jalr	-1698(ra) # 8000458a <end_op>
    return -1;
    80005c34:	557d                	li	a0,-1
    80005c36:	b761                	j	80005bbe <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005c38:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005c3c:	04649783          	lh	a5,70(s1)
    80005c40:	02f99223          	sh	a5,36(s3)
    80005c44:	bf25                	j	80005b7c <sys_open+0xa2>
    itrunc(ip);
    80005c46:	8526                	mv	a0,s1
    80005c48:	ffffe097          	auipc	ra,0xffffe
    80005c4c:	00e080e7          	jalr	14(ra) # 80003c56 <itrunc>
    80005c50:	bfa9                	j	80005baa <sys_open+0xd0>
      fileclose(f);
    80005c52:	854e                	mv	a0,s3
    80005c54:	fffff097          	auipc	ra,0xfffff
    80005c58:	d82080e7          	jalr	-638(ra) # 800049d6 <fileclose>
    iunlockput(ip);
    80005c5c:	8526                	mv	a0,s1
    80005c5e:	ffffe097          	auipc	ra,0xffffe
    80005c62:	14c080e7          	jalr	332(ra) # 80003daa <iunlockput>
    end_op();
    80005c66:	fffff097          	auipc	ra,0xfffff
    80005c6a:	924080e7          	jalr	-1756(ra) # 8000458a <end_op>
    return -1;
    80005c6e:	557d                	li	a0,-1
    80005c70:	b7b9                	j	80005bbe <sys_open+0xe4>

0000000080005c72 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005c72:	7175                	addi	sp,sp,-144
    80005c74:	e506                	sd	ra,136(sp)
    80005c76:	e122                	sd	s0,128(sp)
    80005c78:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005c7a:	fffff097          	auipc	ra,0xfffff
    80005c7e:	890080e7          	jalr	-1904(ra) # 8000450a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005c82:	08000613          	li	a2,128
    80005c86:	f7040593          	addi	a1,s0,-144
    80005c8a:	4501                	li	a0,0
    80005c8c:	ffffd097          	auipc	ra,0xffffd
    80005c90:	176080e7          	jalr	374(ra) # 80002e02 <argstr>
    80005c94:	02054963          	bltz	a0,80005cc6 <sys_mkdir+0x54>
    80005c98:	4681                	li	a3,0
    80005c9a:	4601                	li	a2,0
    80005c9c:	4585                	li	a1,1
    80005c9e:	f7040513          	addi	a0,s0,-144
    80005ca2:	fffff097          	auipc	ra,0xfffff
    80005ca6:	7fe080e7          	jalr	2046(ra) # 800054a0 <create>
    80005caa:	cd11                	beqz	a0,80005cc6 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005cac:	ffffe097          	auipc	ra,0xffffe
    80005cb0:	0fe080e7          	jalr	254(ra) # 80003daa <iunlockput>
  end_op();
    80005cb4:	fffff097          	auipc	ra,0xfffff
    80005cb8:	8d6080e7          	jalr	-1834(ra) # 8000458a <end_op>
  return 0;
    80005cbc:	4501                	li	a0,0
}
    80005cbe:	60aa                	ld	ra,136(sp)
    80005cc0:	640a                	ld	s0,128(sp)
    80005cc2:	6149                	addi	sp,sp,144
    80005cc4:	8082                	ret
    end_op();
    80005cc6:	fffff097          	auipc	ra,0xfffff
    80005cca:	8c4080e7          	jalr	-1852(ra) # 8000458a <end_op>
    return -1;
    80005cce:	557d                	li	a0,-1
    80005cd0:	b7fd                	j	80005cbe <sys_mkdir+0x4c>

0000000080005cd2 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005cd2:	7135                	addi	sp,sp,-160
    80005cd4:	ed06                	sd	ra,152(sp)
    80005cd6:	e922                	sd	s0,144(sp)
    80005cd8:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005cda:	fffff097          	auipc	ra,0xfffff
    80005cde:	830080e7          	jalr	-2000(ra) # 8000450a <begin_op>
  argint(1, &major);
    80005ce2:	f6c40593          	addi	a1,s0,-148
    80005ce6:	4505                	li	a0,1
    80005ce8:	ffffd097          	auipc	ra,0xffffd
    80005cec:	0da080e7          	jalr	218(ra) # 80002dc2 <argint>
  argint(2, &minor);
    80005cf0:	f6840593          	addi	a1,s0,-152
    80005cf4:	4509                	li	a0,2
    80005cf6:	ffffd097          	auipc	ra,0xffffd
    80005cfa:	0cc080e7          	jalr	204(ra) # 80002dc2 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005cfe:	08000613          	li	a2,128
    80005d02:	f7040593          	addi	a1,s0,-144
    80005d06:	4501                	li	a0,0
    80005d08:	ffffd097          	auipc	ra,0xffffd
    80005d0c:	0fa080e7          	jalr	250(ra) # 80002e02 <argstr>
    80005d10:	02054b63          	bltz	a0,80005d46 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005d14:	f6841683          	lh	a3,-152(s0)
    80005d18:	f6c41603          	lh	a2,-148(s0)
    80005d1c:	458d                	li	a1,3
    80005d1e:	f7040513          	addi	a0,s0,-144
    80005d22:	fffff097          	auipc	ra,0xfffff
    80005d26:	77e080e7          	jalr	1918(ra) # 800054a0 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005d2a:	cd11                	beqz	a0,80005d46 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d2c:	ffffe097          	auipc	ra,0xffffe
    80005d30:	07e080e7          	jalr	126(ra) # 80003daa <iunlockput>
  end_op();
    80005d34:	fffff097          	auipc	ra,0xfffff
    80005d38:	856080e7          	jalr	-1962(ra) # 8000458a <end_op>
  return 0;
    80005d3c:	4501                	li	a0,0
}
    80005d3e:	60ea                	ld	ra,152(sp)
    80005d40:	644a                	ld	s0,144(sp)
    80005d42:	610d                	addi	sp,sp,160
    80005d44:	8082                	ret
    end_op();
    80005d46:	fffff097          	auipc	ra,0xfffff
    80005d4a:	844080e7          	jalr	-1980(ra) # 8000458a <end_op>
    return -1;
    80005d4e:	557d                	li	a0,-1
    80005d50:	b7fd                	j	80005d3e <sys_mknod+0x6c>

0000000080005d52 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005d52:	7135                	addi	sp,sp,-160
    80005d54:	ed06                	sd	ra,152(sp)
    80005d56:	e922                	sd	s0,144(sp)
    80005d58:	e526                	sd	s1,136(sp)
    80005d5a:	e14a                	sd	s2,128(sp)
    80005d5c:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005d5e:	ffffc097          	auipc	ra,0xffffc
    80005d62:	e94080e7          	jalr	-364(ra) # 80001bf2 <myproc>
    80005d66:	892a                	mv	s2,a0
  
  begin_op();
    80005d68:	ffffe097          	auipc	ra,0xffffe
    80005d6c:	7a2080e7          	jalr	1954(ra) # 8000450a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005d70:	08000613          	li	a2,128
    80005d74:	f6040593          	addi	a1,s0,-160
    80005d78:	4501                	li	a0,0
    80005d7a:	ffffd097          	auipc	ra,0xffffd
    80005d7e:	088080e7          	jalr	136(ra) # 80002e02 <argstr>
    80005d82:	04054b63          	bltz	a0,80005dd8 <sys_chdir+0x86>
    80005d86:	f6040513          	addi	a0,s0,-160
    80005d8a:	ffffe097          	auipc	ra,0xffffe
    80005d8e:	564080e7          	jalr	1380(ra) # 800042ee <namei>
    80005d92:	84aa                	mv	s1,a0
    80005d94:	c131                	beqz	a0,80005dd8 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005d96:	ffffe097          	auipc	ra,0xffffe
    80005d9a:	db2080e7          	jalr	-590(ra) # 80003b48 <ilock>
  if(ip->type != T_DIR){
    80005d9e:	04449703          	lh	a4,68(s1)
    80005da2:	4785                	li	a5,1
    80005da4:	04f71063          	bne	a4,a5,80005de4 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005da8:	8526                	mv	a0,s1
    80005daa:	ffffe097          	auipc	ra,0xffffe
    80005dae:	e60080e7          	jalr	-416(ra) # 80003c0a <iunlock>
  iput(p->cwd);
    80005db2:	15893503          	ld	a0,344(s2)
    80005db6:	ffffe097          	auipc	ra,0xffffe
    80005dba:	f4c080e7          	jalr	-180(ra) # 80003d02 <iput>
  end_op();
    80005dbe:	ffffe097          	auipc	ra,0xffffe
    80005dc2:	7cc080e7          	jalr	1996(ra) # 8000458a <end_op>
  p->cwd = ip;
    80005dc6:	14993c23          	sd	s1,344(s2)
  return 0;
    80005dca:	4501                	li	a0,0
}
    80005dcc:	60ea                	ld	ra,152(sp)
    80005dce:	644a                	ld	s0,144(sp)
    80005dd0:	64aa                	ld	s1,136(sp)
    80005dd2:	690a                	ld	s2,128(sp)
    80005dd4:	610d                	addi	sp,sp,160
    80005dd6:	8082                	ret
    end_op();
    80005dd8:	ffffe097          	auipc	ra,0xffffe
    80005ddc:	7b2080e7          	jalr	1970(ra) # 8000458a <end_op>
    return -1;
    80005de0:	557d                	li	a0,-1
    80005de2:	b7ed                	j	80005dcc <sys_chdir+0x7a>
    iunlockput(ip);
    80005de4:	8526                	mv	a0,s1
    80005de6:	ffffe097          	auipc	ra,0xffffe
    80005dea:	fc4080e7          	jalr	-60(ra) # 80003daa <iunlockput>
    end_op();
    80005dee:	ffffe097          	auipc	ra,0xffffe
    80005df2:	79c080e7          	jalr	1948(ra) # 8000458a <end_op>
    return -1;
    80005df6:	557d                	li	a0,-1
    80005df8:	bfd1                	j	80005dcc <sys_chdir+0x7a>

0000000080005dfa <sys_exec>:

uint64
sys_exec(void)
{
    80005dfa:	7145                	addi	sp,sp,-464
    80005dfc:	e786                	sd	ra,456(sp)
    80005dfe:	e3a2                	sd	s0,448(sp)
    80005e00:	ff26                	sd	s1,440(sp)
    80005e02:	fb4a                	sd	s2,432(sp)
    80005e04:	f74e                	sd	s3,424(sp)
    80005e06:	f352                	sd	s4,416(sp)
    80005e08:	ef56                	sd	s5,408(sp)
    80005e0a:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005e0c:	e3840593          	addi	a1,s0,-456
    80005e10:	4505                	li	a0,1
    80005e12:	ffffd097          	auipc	ra,0xffffd
    80005e16:	fd0080e7          	jalr	-48(ra) # 80002de2 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005e1a:	08000613          	li	a2,128
    80005e1e:	f4040593          	addi	a1,s0,-192
    80005e22:	4501                	li	a0,0
    80005e24:	ffffd097          	auipc	ra,0xffffd
    80005e28:	fde080e7          	jalr	-34(ra) # 80002e02 <argstr>
    80005e2c:	87aa                	mv	a5,a0
    return -1;
    80005e2e:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005e30:	0c07c263          	bltz	a5,80005ef4 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005e34:	10000613          	li	a2,256
    80005e38:	4581                	li	a1,0
    80005e3a:	e4040513          	addi	a0,s0,-448
    80005e3e:	ffffb097          	auipc	ra,0xffffb
    80005e42:	ea8080e7          	jalr	-344(ra) # 80000ce6 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005e46:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005e4a:	89a6                	mv	s3,s1
    80005e4c:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005e4e:	02000a13          	li	s4,32
    80005e52:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005e56:	00391513          	slli	a0,s2,0x3
    80005e5a:	e3040593          	addi	a1,s0,-464
    80005e5e:	e3843783          	ld	a5,-456(s0)
    80005e62:	953e                	add	a0,a0,a5
    80005e64:	ffffd097          	auipc	ra,0xffffd
    80005e68:	ec0080e7          	jalr	-320(ra) # 80002d24 <fetchaddr>
    80005e6c:	02054a63          	bltz	a0,80005ea0 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005e70:	e3043783          	ld	a5,-464(s0)
    80005e74:	c3b9                	beqz	a5,80005eba <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005e76:	ffffb097          	auipc	ra,0xffffb
    80005e7a:	c84080e7          	jalr	-892(ra) # 80000afa <kalloc>
    80005e7e:	85aa                	mv	a1,a0
    80005e80:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005e84:	cd11                	beqz	a0,80005ea0 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005e86:	6605                	lui	a2,0x1
    80005e88:	e3043503          	ld	a0,-464(s0)
    80005e8c:	ffffd097          	auipc	ra,0xffffd
    80005e90:	eea080e7          	jalr	-278(ra) # 80002d76 <fetchstr>
    80005e94:	00054663          	bltz	a0,80005ea0 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005e98:	0905                	addi	s2,s2,1
    80005e9a:	09a1                	addi	s3,s3,8
    80005e9c:	fb491be3          	bne	s2,s4,80005e52 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ea0:	10048913          	addi	s2,s1,256
    80005ea4:	6088                	ld	a0,0(s1)
    80005ea6:	c531                	beqz	a0,80005ef2 <sys_exec+0xf8>
    kfree(argv[i]);
    80005ea8:	ffffb097          	auipc	ra,0xffffb
    80005eac:	b56080e7          	jalr	-1194(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005eb0:	04a1                	addi	s1,s1,8
    80005eb2:	ff2499e3          	bne	s1,s2,80005ea4 <sys_exec+0xaa>
  return -1;
    80005eb6:	557d                	li	a0,-1
    80005eb8:	a835                	j	80005ef4 <sys_exec+0xfa>
      argv[i] = 0;
    80005eba:	0a8e                	slli	s5,s5,0x3
    80005ebc:	fc040793          	addi	a5,s0,-64
    80005ec0:	9abe                	add	s5,s5,a5
    80005ec2:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005ec6:	e4040593          	addi	a1,s0,-448
    80005eca:	f4040513          	addi	a0,s0,-192
    80005ece:	fffff097          	auipc	ra,0xfffff
    80005ed2:	190080e7          	jalr	400(ra) # 8000505e <exec>
    80005ed6:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ed8:	10048993          	addi	s3,s1,256
    80005edc:	6088                	ld	a0,0(s1)
    80005ede:	c901                	beqz	a0,80005eee <sys_exec+0xf4>
    kfree(argv[i]);
    80005ee0:	ffffb097          	auipc	ra,0xffffb
    80005ee4:	b1e080e7          	jalr	-1250(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ee8:	04a1                	addi	s1,s1,8
    80005eea:	ff3499e3          	bne	s1,s3,80005edc <sys_exec+0xe2>
  return ret;
    80005eee:	854a                	mv	a0,s2
    80005ef0:	a011                	j	80005ef4 <sys_exec+0xfa>
  return -1;
    80005ef2:	557d                	li	a0,-1
}
    80005ef4:	60be                	ld	ra,456(sp)
    80005ef6:	641e                	ld	s0,448(sp)
    80005ef8:	74fa                	ld	s1,440(sp)
    80005efa:	795a                	ld	s2,432(sp)
    80005efc:	79ba                	ld	s3,424(sp)
    80005efe:	7a1a                	ld	s4,416(sp)
    80005f00:	6afa                	ld	s5,408(sp)
    80005f02:	6179                	addi	sp,sp,464
    80005f04:	8082                	ret

0000000080005f06 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005f06:	7139                	addi	sp,sp,-64
    80005f08:	fc06                	sd	ra,56(sp)
    80005f0a:	f822                	sd	s0,48(sp)
    80005f0c:	f426                	sd	s1,40(sp)
    80005f0e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005f10:	ffffc097          	auipc	ra,0xffffc
    80005f14:	ce2080e7          	jalr	-798(ra) # 80001bf2 <myproc>
    80005f18:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005f1a:	fd840593          	addi	a1,s0,-40
    80005f1e:	4501                	li	a0,0
    80005f20:	ffffd097          	auipc	ra,0xffffd
    80005f24:	ec2080e7          	jalr	-318(ra) # 80002de2 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005f28:	fc840593          	addi	a1,s0,-56
    80005f2c:	fd040513          	addi	a0,s0,-48
    80005f30:	fffff097          	auipc	ra,0xfffff
    80005f34:	dd6080e7          	jalr	-554(ra) # 80004d06 <pipealloc>
    return -1;
    80005f38:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005f3a:	0c054463          	bltz	a0,80006002 <sys_pipe+0xfc>
  fd0 = -1;
    80005f3e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005f42:	fd043503          	ld	a0,-48(s0)
    80005f46:	fffff097          	auipc	ra,0xfffff
    80005f4a:	518080e7          	jalr	1304(ra) # 8000545e <fdalloc>
    80005f4e:	fca42223          	sw	a0,-60(s0)
    80005f52:	08054b63          	bltz	a0,80005fe8 <sys_pipe+0xe2>
    80005f56:	fc843503          	ld	a0,-56(s0)
    80005f5a:	fffff097          	auipc	ra,0xfffff
    80005f5e:	504080e7          	jalr	1284(ra) # 8000545e <fdalloc>
    80005f62:	fca42023          	sw	a0,-64(s0)
    80005f66:	06054863          	bltz	a0,80005fd6 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f6a:	4691                	li	a3,4
    80005f6c:	fc440613          	addi	a2,s0,-60
    80005f70:	fd843583          	ld	a1,-40(s0)
    80005f74:	6ca8                	ld	a0,88(s1)
    80005f76:	ffffb097          	auipc	ra,0xffffb
    80005f7a:	716080e7          	jalr	1814(ra) # 8000168c <copyout>
    80005f7e:	02054063          	bltz	a0,80005f9e <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005f82:	4691                	li	a3,4
    80005f84:	fc040613          	addi	a2,s0,-64
    80005f88:	fd843583          	ld	a1,-40(s0)
    80005f8c:	0591                	addi	a1,a1,4
    80005f8e:	6ca8                	ld	a0,88(s1)
    80005f90:	ffffb097          	auipc	ra,0xffffb
    80005f94:	6fc080e7          	jalr	1788(ra) # 8000168c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005f98:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f9a:	06055463          	bgez	a0,80006002 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005f9e:	fc442783          	lw	a5,-60(s0)
    80005fa2:	07e9                	addi	a5,a5,26
    80005fa4:	078e                	slli	a5,a5,0x3
    80005fa6:	97a6                	add	a5,a5,s1
    80005fa8:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005fac:	fc042503          	lw	a0,-64(s0)
    80005fb0:	0569                	addi	a0,a0,26
    80005fb2:	050e                	slli	a0,a0,0x3
    80005fb4:	94aa                	add	s1,s1,a0
    80005fb6:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80005fba:	fd043503          	ld	a0,-48(s0)
    80005fbe:	fffff097          	auipc	ra,0xfffff
    80005fc2:	a18080e7          	jalr	-1512(ra) # 800049d6 <fileclose>
    fileclose(wf);
    80005fc6:	fc843503          	ld	a0,-56(s0)
    80005fca:	fffff097          	auipc	ra,0xfffff
    80005fce:	a0c080e7          	jalr	-1524(ra) # 800049d6 <fileclose>
    return -1;
    80005fd2:	57fd                	li	a5,-1
    80005fd4:	a03d                	j	80006002 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005fd6:	fc442783          	lw	a5,-60(s0)
    80005fda:	0007c763          	bltz	a5,80005fe8 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005fde:	07e9                	addi	a5,a5,26
    80005fe0:	078e                	slli	a5,a5,0x3
    80005fe2:	94be                	add	s1,s1,a5
    80005fe4:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80005fe8:	fd043503          	ld	a0,-48(s0)
    80005fec:	fffff097          	auipc	ra,0xfffff
    80005ff0:	9ea080e7          	jalr	-1558(ra) # 800049d6 <fileclose>
    fileclose(wf);
    80005ff4:	fc843503          	ld	a0,-56(s0)
    80005ff8:	fffff097          	auipc	ra,0xfffff
    80005ffc:	9de080e7          	jalr	-1570(ra) # 800049d6 <fileclose>
    return -1;
    80006000:	57fd                	li	a5,-1
}
    80006002:	853e                	mv	a0,a5
    80006004:	70e2                	ld	ra,56(sp)
    80006006:	7442                	ld	s0,48(sp)
    80006008:	74a2                	ld	s1,40(sp)
    8000600a:	6121                	addi	sp,sp,64
    8000600c:	8082                	ret
	...

0000000080006010 <kernelvec>:
    80006010:	7111                	addi	sp,sp,-256
    80006012:	e006                	sd	ra,0(sp)
    80006014:	e40a                	sd	sp,8(sp)
    80006016:	e80e                	sd	gp,16(sp)
    80006018:	ec12                	sd	tp,24(sp)
    8000601a:	f016                	sd	t0,32(sp)
    8000601c:	f41a                	sd	t1,40(sp)
    8000601e:	f81e                	sd	t2,48(sp)
    80006020:	fc22                	sd	s0,56(sp)
    80006022:	e0a6                	sd	s1,64(sp)
    80006024:	e4aa                	sd	a0,72(sp)
    80006026:	e8ae                	sd	a1,80(sp)
    80006028:	ecb2                	sd	a2,88(sp)
    8000602a:	f0b6                	sd	a3,96(sp)
    8000602c:	f4ba                	sd	a4,104(sp)
    8000602e:	f8be                	sd	a5,112(sp)
    80006030:	fcc2                	sd	a6,120(sp)
    80006032:	e146                	sd	a7,128(sp)
    80006034:	e54a                	sd	s2,136(sp)
    80006036:	e94e                	sd	s3,144(sp)
    80006038:	ed52                	sd	s4,152(sp)
    8000603a:	f156                	sd	s5,160(sp)
    8000603c:	f55a                	sd	s6,168(sp)
    8000603e:	f95e                	sd	s7,176(sp)
    80006040:	fd62                	sd	s8,184(sp)
    80006042:	e1e6                	sd	s9,192(sp)
    80006044:	e5ea                	sd	s10,200(sp)
    80006046:	e9ee                	sd	s11,208(sp)
    80006048:	edf2                	sd	t3,216(sp)
    8000604a:	f1f6                	sd	t4,224(sp)
    8000604c:	f5fa                	sd	t5,232(sp)
    8000604e:	f9fe                	sd	t6,240(sp)
    80006050:	bcbfc0ef          	jal	ra,80002c1a <kerneltrap>
    80006054:	6082                	ld	ra,0(sp)
    80006056:	6122                	ld	sp,8(sp)
    80006058:	61c2                	ld	gp,16(sp)
    8000605a:	7282                	ld	t0,32(sp)
    8000605c:	7322                	ld	t1,40(sp)
    8000605e:	73c2                	ld	t2,48(sp)
    80006060:	7462                	ld	s0,56(sp)
    80006062:	6486                	ld	s1,64(sp)
    80006064:	6526                	ld	a0,72(sp)
    80006066:	65c6                	ld	a1,80(sp)
    80006068:	6666                	ld	a2,88(sp)
    8000606a:	7686                	ld	a3,96(sp)
    8000606c:	7726                	ld	a4,104(sp)
    8000606e:	77c6                	ld	a5,112(sp)
    80006070:	7866                	ld	a6,120(sp)
    80006072:	688a                	ld	a7,128(sp)
    80006074:	692a                	ld	s2,136(sp)
    80006076:	69ca                	ld	s3,144(sp)
    80006078:	6a6a                	ld	s4,152(sp)
    8000607a:	7a8a                	ld	s5,160(sp)
    8000607c:	7b2a                	ld	s6,168(sp)
    8000607e:	7bca                	ld	s7,176(sp)
    80006080:	7c6a                	ld	s8,184(sp)
    80006082:	6c8e                	ld	s9,192(sp)
    80006084:	6d2e                	ld	s10,200(sp)
    80006086:	6dce                	ld	s11,208(sp)
    80006088:	6e6e                	ld	t3,216(sp)
    8000608a:	7e8e                	ld	t4,224(sp)
    8000608c:	7f2e                	ld	t5,232(sp)
    8000608e:	7fce                	ld	t6,240(sp)
    80006090:	6111                	addi	sp,sp,256
    80006092:	10200073          	sret
    80006096:	00000013          	nop
    8000609a:	00000013          	nop
    8000609e:	0001                	nop

00000000800060a0 <timervec>:
    800060a0:	34051573          	csrrw	a0,mscratch,a0
    800060a4:	e10c                	sd	a1,0(a0)
    800060a6:	e510                	sd	a2,8(a0)
    800060a8:	e914                	sd	a3,16(a0)
    800060aa:	6d0c                	ld	a1,24(a0)
    800060ac:	7110                	ld	a2,32(a0)
    800060ae:	6194                	ld	a3,0(a1)
    800060b0:	96b2                	add	a3,a3,a2
    800060b2:	e194                	sd	a3,0(a1)
    800060b4:	4589                	li	a1,2
    800060b6:	14459073          	csrw	sip,a1
    800060ba:	6914                	ld	a3,16(a0)
    800060bc:	6510                	ld	a2,8(a0)
    800060be:	610c                	ld	a1,0(a0)
    800060c0:	34051573          	csrrw	a0,mscratch,a0
    800060c4:	30200073          	mret
	...

00000000800060ca <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800060ca:	1141                	addi	sp,sp,-16
    800060cc:	e422                	sd	s0,8(sp)
    800060ce:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800060d0:	0c0007b7          	lui	a5,0xc000
    800060d4:	4705                	li	a4,1
    800060d6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800060d8:	c3d8                	sw	a4,4(a5)
}
    800060da:	6422                	ld	s0,8(sp)
    800060dc:	0141                	addi	sp,sp,16
    800060de:	8082                	ret

00000000800060e0 <plicinithart>:

void
plicinithart(void)
{
    800060e0:	1141                	addi	sp,sp,-16
    800060e2:	e406                	sd	ra,8(sp)
    800060e4:	e022                	sd	s0,0(sp)
    800060e6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800060e8:	ffffc097          	auipc	ra,0xffffc
    800060ec:	ade080e7          	jalr	-1314(ra) # 80001bc6 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800060f0:	0085171b          	slliw	a4,a0,0x8
    800060f4:	0c0027b7          	lui	a5,0xc002
    800060f8:	97ba                	add	a5,a5,a4
    800060fa:	40200713          	li	a4,1026
    800060fe:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006102:	00d5151b          	slliw	a0,a0,0xd
    80006106:	0c2017b7          	lui	a5,0xc201
    8000610a:	953e                	add	a0,a0,a5
    8000610c:	00052023          	sw	zero,0(a0)
}
    80006110:	60a2                	ld	ra,8(sp)
    80006112:	6402                	ld	s0,0(sp)
    80006114:	0141                	addi	sp,sp,16
    80006116:	8082                	ret

0000000080006118 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006118:	1141                	addi	sp,sp,-16
    8000611a:	e406                	sd	ra,8(sp)
    8000611c:	e022                	sd	s0,0(sp)
    8000611e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006120:	ffffc097          	auipc	ra,0xffffc
    80006124:	aa6080e7          	jalr	-1370(ra) # 80001bc6 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006128:	00d5179b          	slliw	a5,a0,0xd
    8000612c:	0c201537          	lui	a0,0xc201
    80006130:	953e                	add	a0,a0,a5
  return irq;
}
    80006132:	4148                	lw	a0,4(a0)
    80006134:	60a2                	ld	ra,8(sp)
    80006136:	6402                	ld	s0,0(sp)
    80006138:	0141                	addi	sp,sp,16
    8000613a:	8082                	ret

000000008000613c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000613c:	1101                	addi	sp,sp,-32
    8000613e:	ec06                	sd	ra,24(sp)
    80006140:	e822                	sd	s0,16(sp)
    80006142:	e426                	sd	s1,8(sp)
    80006144:	1000                	addi	s0,sp,32
    80006146:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006148:	ffffc097          	auipc	ra,0xffffc
    8000614c:	a7e080e7          	jalr	-1410(ra) # 80001bc6 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006150:	00d5151b          	slliw	a0,a0,0xd
    80006154:	0c2017b7          	lui	a5,0xc201
    80006158:	97aa                	add	a5,a5,a0
    8000615a:	c3c4                	sw	s1,4(a5)
}
    8000615c:	60e2                	ld	ra,24(sp)
    8000615e:	6442                	ld	s0,16(sp)
    80006160:	64a2                	ld	s1,8(sp)
    80006162:	6105                	addi	sp,sp,32
    80006164:	8082                	ret

0000000080006166 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006166:	1141                	addi	sp,sp,-16
    80006168:	e406                	sd	ra,8(sp)
    8000616a:	e022                	sd	s0,0(sp)
    8000616c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000616e:	479d                	li	a5,7
    80006170:	04a7cc63          	blt	a5,a0,800061c8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006174:	0001e797          	auipc	a5,0x1e
    80006178:	1f478793          	addi	a5,a5,500 # 80024368 <disk>
    8000617c:	97aa                	add	a5,a5,a0
    8000617e:	0187c783          	lbu	a5,24(a5)
    80006182:	ebb9                	bnez	a5,800061d8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006184:	00451613          	slli	a2,a0,0x4
    80006188:	0001e797          	auipc	a5,0x1e
    8000618c:	1e078793          	addi	a5,a5,480 # 80024368 <disk>
    80006190:	6394                	ld	a3,0(a5)
    80006192:	96b2                	add	a3,a3,a2
    80006194:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006198:	6398                	ld	a4,0(a5)
    8000619a:	9732                	add	a4,a4,a2
    8000619c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800061a0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800061a4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800061a8:	953e                	add	a0,a0,a5
    800061aa:	4785                	li	a5,1
    800061ac:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    800061b0:	0001e517          	auipc	a0,0x1e
    800061b4:	1d050513          	addi	a0,a0,464 # 80024380 <disk+0x18>
    800061b8:	ffffc097          	auipc	ra,0xffffc
    800061bc:	1de080e7          	jalr	478(ra) # 80002396 <wakeup>
}
    800061c0:	60a2                	ld	ra,8(sp)
    800061c2:	6402                	ld	s0,0(sp)
    800061c4:	0141                	addi	sp,sp,16
    800061c6:	8082                	ret
    panic("free_desc 1");
    800061c8:	00002517          	auipc	a0,0x2
    800061cc:	6b050513          	addi	a0,a0,1712 # 80008878 <syscalls+0x308>
    800061d0:	ffffa097          	auipc	ra,0xffffa
    800061d4:	374080e7          	jalr	884(ra) # 80000544 <panic>
    panic("free_desc 2");
    800061d8:	00002517          	auipc	a0,0x2
    800061dc:	6b050513          	addi	a0,a0,1712 # 80008888 <syscalls+0x318>
    800061e0:	ffffa097          	auipc	ra,0xffffa
    800061e4:	364080e7          	jalr	868(ra) # 80000544 <panic>

00000000800061e8 <virtio_disk_init>:
{
    800061e8:	1101                	addi	sp,sp,-32
    800061ea:	ec06                	sd	ra,24(sp)
    800061ec:	e822                	sd	s0,16(sp)
    800061ee:	e426                	sd	s1,8(sp)
    800061f0:	e04a                	sd	s2,0(sp)
    800061f2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800061f4:	00002597          	auipc	a1,0x2
    800061f8:	6a458593          	addi	a1,a1,1700 # 80008898 <syscalls+0x328>
    800061fc:	0001e517          	auipc	a0,0x1e
    80006200:	29450513          	addi	a0,a0,660 # 80024490 <disk+0x128>
    80006204:	ffffb097          	auipc	ra,0xffffb
    80006208:	956080e7          	jalr	-1706(ra) # 80000b5a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000620c:	100017b7          	lui	a5,0x10001
    80006210:	4398                	lw	a4,0(a5)
    80006212:	2701                	sext.w	a4,a4
    80006214:	747277b7          	lui	a5,0x74727
    80006218:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000621c:	14f71e63          	bne	a4,a5,80006378 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006220:	100017b7          	lui	a5,0x10001
    80006224:	43dc                	lw	a5,4(a5)
    80006226:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006228:	4709                	li	a4,2
    8000622a:	14e79763          	bne	a5,a4,80006378 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000622e:	100017b7          	lui	a5,0x10001
    80006232:	479c                	lw	a5,8(a5)
    80006234:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006236:	14e79163          	bne	a5,a4,80006378 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000623a:	100017b7          	lui	a5,0x10001
    8000623e:	47d8                	lw	a4,12(a5)
    80006240:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006242:	554d47b7          	lui	a5,0x554d4
    80006246:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000624a:	12f71763          	bne	a4,a5,80006378 <virtio_disk_init+0x190>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000624e:	100017b7          	lui	a5,0x10001
    80006252:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006256:	4705                	li	a4,1
    80006258:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000625a:	470d                	li	a4,3
    8000625c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000625e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006260:	c7ffe737          	lui	a4,0xc7ffe
    80006264:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fda2b7>
    80006268:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000626a:	2701                	sext.w	a4,a4
    8000626c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000626e:	472d                	li	a4,11
    80006270:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006272:	0707a903          	lw	s2,112(a5)
    80006276:	2901                	sext.w	s2,s2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006278:	00897793          	andi	a5,s2,8
    8000627c:	10078663          	beqz	a5,80006388 <virtio_disk_init+0x1a0>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006280:	100017b7          	lui	a5,0x10001
    80006284:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006288:	43fc                	lw	a5,68(a5)
    8000628a:	2781                	sext.w	a5,a5
    8000628c:	10079663          	bnez	a5,80006398 <virtio_disk_init+0x1b0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006290:	100017b7          	lui	a5,0x10001
    80006294:	5bdc                	lw	a5,52(a5)
    80006296:	2781                	sext.w	a5,a5
  if(max == 0)
    80006298:	10078863          	beqz	a5,800063a8 <virtio_disk_init+0x1c0>
  if(max < NUM)
    8000629c:	471d                	li	a4,7
    8000629e:	10f77d63          	bgeu	a4,a5,800063b8 <virtio_disk_init+0x1d0>
  disk.desc = kalloc();
    800062a2:	ffffb097          	auipc	ra,0xffffb
    800062a6:	858080e7          	jalr	-1960(ra) # 80000afa <kalloc>
    800062aa:	0001e497          	auipc	s1,0x1e
    800062ae:	0be48493          	addi	s1,s1,190 # 80024368 <disk>
    800062b2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800062b4:	ffffb097          	auipc	ra,0xffffb
    800062b8:	846080e7          	jalr	-1978(ra) # 80000afa <kalloc>
    800062bc:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800062be:	ffffb097          	auipc	ra,0xffffb
    800062c2:	83c080e7          	jalr	-1988(ra) # 80000afa <kalloc>
    800062c6:	87aa                	mv	a5,a0
    800062c8:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800062ca:	6088                	ld	a0,0(s1)
    800062cc:	cd75                	beqz	a0,800063c8 <virtio_disk_init+0x1e0>
    800062ce:	0001e717          	auipc	a4,0x1e
    800062d2:	0a273703          	ld	a4,162(a4) # 80024370 <disk+0x8>
    800062d6:	cb6d                	beqz	a4,800063c8 <virtio_disk_init+0x1e0>
    800062d8:	cbe5                	beqz	a5,800063c8 <virtio_disk_init+0x1e0>
  memset(disk.desc, 0, PGSIZE);
    800062da:	6605                	lui	a2,0x1
    800062dc:	4581                	li	a1,0
    800062de:	ffffb097          	auipc	ra,0xffffb
    800062e2:	a08080e7          	jalr	-1528(ra) # 80000ce6 <memset>
  memset(disk.avail, 0, PGSIZE);
    800062e6:	0001e497          	auipc	s1,0x1e
    800062ea:	08248493          	addi	s1,s1,130 # 80024368 <disk>
    800062ee:	6605                	lui	a2,0x1
    800062f0:	4581                	li	a1,0
    800062f2:	6488                	ld	a0,8(s1)
    800062f4:	ffffb097          	auipc	ra,0xffffb
    800062f8:	9f2080e7          	jalr	-1550(ra) # 80000ce6 <memset>
  memset(disk.used, 0, PGSIZE);
    800062fc:	6605                	lui	a2,0x1
    800062fe:	4581                	li	a1,0
    80006300:	6888                	ld	a0,16(s1)
    80006302:	ffffb097          	auipc	ra,0xffffb
    80006306:	9e4080e7          	jalr	-1564(ra) # 80000ce6 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000630a:	100017b7          	lui	a5,0x10001
    8000630e:	4721                	li	a4,8
    80006310:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006312:	4098                	lw	a4,0(s1)
    80006314:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006318:	40d8                	lw	a4,4(s1)
    8000631a:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000631e:	6498                	ld	a4,8(s1)
    80006320:	0007069b          	sext.w	a3,a4
    80006324:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006328:	9701                	srai	a4,a4,0x20
    8000632a:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000632e:	6898                	ld	a4,16(s1)
    80006330:	0007069b          	sext.w	a3,a4
    80006334:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006338:	9701                	srai	a4,a4,0x20
    8000633a:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000633e:	4685                	li	a3,1
    80006340:	c3f4                	sw	a3,68(a5)
    disk.free[i] = 1;
    80006342:	4705                	li	a4,1
    80006344:	00d48c23          	sb	a3,24(s1)
    80006348:	00e48ca3          	sb	a4,25(s1)
    8000634c:	00e48d23          	sb	a4,26(s1)
    80006350:	00e48da3          	sb	a4,27(s1)
    80006354:	00e48e23          	sb	a4,28(s1)
    80006358:	00e48ea3          	sb	a4,29(s1)
    8000635c:	00e48f23          	sb	a4,30(s1)
    80006360:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006364:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006368:	0727a823          	sw	s2,112(a5)
}
    8000636c:	60e2                	ld	ra,24(sp)
    8000636e:	6442                	ld	s0,16(sp)
    80006370:	64a2                	ld	s1,8(sp)
    80006372:	6902                	ld	s2,0(sp)
    80006374:	6105                	addi	sp,sp,32
    80006376:	8082                	ret
    panic("could not find virtio disk");
    80006378:	00002517          	auipc	a0,0x2
    8000637c:	53050513          	addi	a0,a0,1328 # 800088a8 <syscalls+0x338>
    80006380:	ffffa097          	auipc	ra,0xffffa
    80006384:	1c4080e7          	jalr	452(ra) # 80000544 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006388:	00002517          	auipc	a0,0x2
    8000638c:	54050513          	addi	a0,a0,1344 # 800088c8 <syscalls+0x358>
    80006390:	ffffa097          	auipc	ra,0xffffa
    80006394:	1b4080e7          	jalr	436(ra) # 80000544 <panic>
    panic("virtio disk should not be ready");
    80006398:	00002517          	auipc	a0,0x2
    8000639c:	55050513          	addi	a0,a0,1360 # 800088e8 <syscalls+0x378>
    800063a0:	ffffa097          	auipc	ra,0xffffa
    800063a4:	1a4080e7          	jalr	420(ra) # 80000544 <panic>
    panic("virtio disk has no queue 0");
    800063a8:	00002517          	auipc	a0,0x2
    800063ac:	56050513          	addi	a0,a0,1376 # 80008908 <syscalls+0x398>
    800063b0:	ffffa097          	auipc	ra,0xffffa
    800063b4:	194080e7          	jalr	404(ra) # 80000544 <panic>
    panic("virtio disk max queue too short");
    800063b8:	00002517          	auipc	a0,0x2
    800063bc:	57050513          	addi	a0,a0,1392 # 80008928 <syscalls+0x3b8>
    800063c0:	ffffa097          	auipc	ra,0xffffa
    800063c4:	184080e7          	jalr	388(ra) # 80000544 <panic>
    panic("virtio disk kalloc");
    800063c8:	00002517          	auipc	a0,0x2
    800063cc:	58050513          	addi	a0,a0,1408 # 80008948 <syscalls+0x3d8>
    800063d0:	ffffa097          	auipc	ra,0xffffa
    800063d4:	174080e7          	jalr	372(ra) # 80000544 <panic>

00000000800063d8 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800063d8:	7159                	addi	sp,sp,-112
    800063da:	f486                	sd	ra,104(sp)
    800063dc:	f0a2                	sd	s0,96(sp)
    800063de:	eca6                	sd	s1,88(sp)
    800063e0:	e8ca                	sd	s2,80(sp)
    800063e2:	e4ce                	sd	s3,72(sp)
    800063e4:	e0d2                	sd	s4,64(sp)
    800063e6:	fc56                	sd	s5,56(sp)
    800063e8:	f85a                	sd	s6,48(sp)
    800063ea:	f45e                	sd	s7,40(sp)
    800063ec:	f062                	sd	s8,32(sp)
    800063ee:	ec66                	sd	s9,24(sp)
    800063f0:	e86a                	sd	s10,16(sp)
    800063f2:	1880                	addi	s0,sp,112
    800063f4:	892a                	mv	s2,a0
    800063f6:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800063f8:	00c52c83          	lw	s9,12(a0)
    800063fc:	001c9c9b          	slliw	s9,s9,0x1
    80006400:	1c82                	slli	s9,s9,0x20
    80006402:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006406:	0001e517          	auipc	a0,0x1e
    8000640a:	08a50513          	addi	a0,a0,138 # 80024490 <disk+0x128>
    8000640e:	ffffa097          	auipc	ra,0xffffa
    80006412:	7dc080e7          	jalr	2012(ra) # 80000bea <acquire>
  for(int i = 0; i < 3; i++){
    80006416:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006418:	4ba1                	li	s7,8
      disk.free[i] = 0;
    8000641a:	0001eb17          	auipc	s6,0x1e
    8000641e:	f4eb0b13          	addi	s6,s6,-178 # 80024368 <disk>
  for(int i = 0; i < 3; i++){
    80006422:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80006424:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006426:	0001ec17          	auipc	s8,0x1e
    8000642a:	06ac0c13          	addi	s8,s8,106 # 80024490 <disk+0x128>
    8000642e:	a8b5                	j	800064aa <virtio_disk_rw+0xd2>
      disk.free[i] = 0;
    80006430:	00fb06b3          	add	a3,s6,a5
    80006434:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006438:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    8000643a:	0207c563          	bltz	a5,80006464 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000643e:	2485                	addiw	s1,s1,1
    80006440:	0711                	addi	a4,a4,4
    80006442:	1f548a63          	beq	s1,s5,80006636 <virtio_disk_rw+0x25e>
    idx[i] = alloc_desc();
    80006446:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80006448:	0001e697          	auipc	a3,0x1e
    8000644c:	f2068693          	addi	a3,a3,-224 # 80024368 <disk>
    80006450:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80006452:	0186c583          	lbu	a1,24(a3)
    80006456:	fde9                	bnez	a1,80006430 <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006458:	2785                	addiw	a5,a5,1
    8000645a:	0685                	addi	a3,a3,1
    8000645c:	ff779be3          	bne	a5,s7,80006452 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    80006460:	57fd                	li	a5,-1
    80006462:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80006464:	02905a63          	blez	s1,80006498 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    80006468:	f9042503          	lw	a0,-112(s0)
    8000646c:	00000097          	auipc	ra,0x0
    80006470:	cfa080e7          	jalr	-774(ra) # 80006166 <free_desc>
      for(int j = 0; j < i; j++)
    80006474:	4785                	li	a5,1
    80006476:	0297d163          	bge	a5,s1,80006498 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000647a:	f9442503          	lw	a0,-108(s0)
    8000647e:	00000097          	auipc	ra,0x0
    80006482:	ce8080e7          	jalr	-792(ra) # 80006166 <free_desc>
      for(int j = 0; j < i; j++)
    80006486:	4789                	li	a5,2
    80006488:	0097d863          	bge	a5,s1,80006498 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000648c:	f9842503          	lw	a0,-104(s0)
    80006490:	00000097          	auipc	ra,0x0
    80006494:	cd6080e7          	jalr	-810(ra) # 80006166 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006498:	85e2                	mv	a1,s8
    8000649a:	0001e517          	auipc	a0,0x1e
    8000649e:	ee650513          	addi	a0,a0,-282 # 80024380 <disk+0x18>
    800064a2:	ffffc097          	auipc	ra,0xffffc
    800064a6:	e86080e7          	jalr	-378(ra) # 80002328 <sleep>
  for(int i = 0; i < 3; i++){
    800064aa:	f9040713          	addi	a4,s0,-112
    800064ae:	84ce                	mv	s1,s3
    800064b0:	bf59                	j	80006446 <virtio_disk_rw+0x6e>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    800064b2:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    800064b6:	00479693          	slli	a3,a5,0x4
    800064ba:	0001e797          	auipc	a5,0x1e
    800064be:	eae78793          	addi	a5,a5,-338 # 80024368 <disk>
    800064c2:	97b6                	add	a5,a5,a3
    800064c4:	4685                	li	a3,1
    800064c6:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800064c8:	0001e597          	auipc	a1,0x1e
    800064cc:	ea058593          	addi	a1,a1,-352 # 80024368 <disk>
    800064d0:	00a60793          	addi	a5,a2,10
    800064d4:	0792                	slli	a5,a5,0x4
    800064d6:	97ae                	add	a5,a5,a1
    800064d8:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    800064dc:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800064e0:	f6070693          	addi	a3,a4,-160
    800064e4:	619c                	ld	a5,0(a1)
    800064e6:	97b6                	add	a5,a5,a3
    800064e8:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800064ea:	6188                	ld	a0,0(a1)
    800064ec:	96aa                	add	a3,a3,a0
    800064ee:	47c1                	li	a5,16
    800064f0:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800064f2:	4785                	li	a5,1
    800064f4:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    800064f8:	f9442783          	lw	a5,-108(s0)
    800064fc:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006500:	0792                	slli	a5,a5,0x4
    80006502:	953e                	add	a0,a0,a5
    80006504:	05890693          	addi	a3,s2,88
    80006508:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000650a:	6188                	ld	a0,0(a1)
    8000650c:	97aa                	add	a5,a5,a0
    8000650e:	40000693          	li	a3,1024
    80006512:	c794                	sw	a3,8(a5)
  if(write)
    80006514:	100d0d63          	beqz	s10,8000662e <virtio_disk_rw+0x256>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006518:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000651c:	00c7d683          	lhu	a3,12(a5)
    80006520:	0016e693          	ori	a3,a3,1
    80006524:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    80006528:	f9842583          	lw	a1,-104(s0)
    8000652c:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006530:	0001e697          	auipc	a3,0x1e
    80006534:	e3868693          	addi	a3,a3,-456 # 80024368 <disk>
    80006538:	00260793          	addi	a5,a2,2
    8000653c:	0792                	slli	a5,a5,0x4
    8000653e:	97b6                	add	a5,a5,a3
    80006540:	587d                	li	a6,-1
    80006542:	01078823          	sb	a6,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006546:	0592                	slli	a1,a1,0x4
    80006548:	952e                	add	a0,a0,a1
    8000654a:	f9070713          	addi	a4,a4,-112
    8000654e:	9736                	add	a4,a4,a3
    80006550:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    80006552:	6298                	ld	a4,0(a3)
    80006554:	972e                	add	a4,a4,a1
    80006556:	4585                	li	a1,1
    80006558:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000655a:	4509                	li	a0,2
    8000655c:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    80006560:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006564:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    80006568:	0127b423          	sd	s2,8(a5)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000656c:	6698                	ld	a4,8(a3)
    8000656e:	00275783          	lhu	a5,2(a4)
    80006572:	8b9d                	andi	a5,a5,7
    80006574:	0786                	slli	a5,a5,0x1
    80006576:	97ba                	add	a5,a5,a4
    80006578:	00c79223          	sh	a2,4(a5)

  __sync_synchronize();
    8000657c:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006580:	6698                	ld	a4,8(a3)
    80006582:	00275783          	lhu	a5,2(a4)
    80006586:	2785                	addiw	a5,a5,1
    80006588:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000658c:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006590:	100017b7          	lui	a5,0x10001
    80006594:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006598:	00492703          	lw	a4,4(s2)
    8000659c:	4785                	li	a5,1
    8000659e:	02f71163          	bne	a4,a5,800065c0 <virtio_disk_rw+0x1e8>
    sleep(b, &disk.vdisk_lock);
    800065a2:	0001e997          	auipc	s3,0x1e
    800065a6:	eee98993          	addi	s3,s3,-274 # 80024490 <disk+0x128>
  while(b->disk == 1) {
    800065aa:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800065ac:	85ce                	mv	a1,s3
    800065ae:	854a                	mv	a0,s2
    800065b0:	ffffc097          	auipc	ra,0xffffc
    800065b4:	d78080e7          	jalr	-648(ra) # 80002328 <sleep>
  while(b->disk == 1) {
    800065b8:	00492783          	lw	a5,4(s2)
    800065bc:	fe9788e3          	beq	a5,s1,800065ac <virtio_disk_rw+0x1d4>
  }

  disk.info[idx[0]].b = 0;
    800065c0:	f9042903          	lw	s2,-112(s0)
    800065c4:	00290793          	addi	a5,s2,2
    800065c8:	00479713          	slli	a4,a5,0x4
    800065cc:	0001e797          	auipc	a5,0x1e
    800065d0:	d9c78793          	addi	a5,a5,-612 # 80024368 <disk>
    800065d4:	97ba                	add	a5,a5,a4
    800065d6:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800065da:	0001e997          	auipc	s3,0x1e
    800065de:	d8e98993          	addi	s3,s3,-626 # 80024368 <disk>
    800065e2:	00491713          	slli	a4,s2,0x4
    800065e6:	0009b783          	ld	a5,0(s3)
    800065ea:	97ba                	add	a5,a5,a4
    800065ec:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800065f0:	854a                	mv	a0,s2
    800065f2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800065f6:	00000097          	auipc	ra,0x0
    800065fa:	b70080e7          	jalr	-1168(ra) # 80006166 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800065fe:	8885                	andi	s1,s1,1
    80006600:	f0ed                	bnez	s1,800065e2 <virtio_disk_rw+0x20a>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006602:	0001e517          	auipc	a0,0x1e
    80006606:	e8e50513          	addi	a0,a0,-370 # 80024490 <disk+0x128>
    8000660a:	ffffa097          	auipc	ra,0xffffa
    8000660e:	694080e7          	jalr	1684(ra) # 80000c9e <release>
}
    80006612:	70a6                	ld	ra,104(sp)
    80006614:	7406                	ld	s0,96(sp)
    80006616:	64e6                	ld	s1,88(sp)
    80006618:	6946                	ld	s2,80(sp)
    8000661a:	69a6                	ld	s3,72(sp)
    8000661c:	6a06                	ld	s4,64(sp)
    8000661e:	7ae2                	ld	s5,56(sp)
    80006620:	7b42                	ld	s6,48(sp)
    80006622:	7ba2                	ld	s7,40(sp)
    80006624:	7c02                	ld	s8,32(sp)
    80006626:	6ce2                	ld	s9,24(sp)
    80006628:	6d42                	ld	s10,16(sp)
    8000662a:	6165                	addi	sp,sp,112
    8000662c:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000662e:	4689                	li	a3,2
    80006630:	00d79623          	sh	a3,12(a5)
    80006634:	b5e5                	j	8000651c <virtio_disk_rw+0x144>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006636:	f9042603          	lw	a2,-112(s0)
    8000663a:	00a60713          	addi	a4,a2,10
    8000663e:	0712                	slli	a4,a4,0x4
    80006640:	0001e517          	auipc	a0,0x1e
    80006644:	d3050513          	addi	a0,a0,-720 # 80024370 <disk+0x8>
    80006648:	953a                	add	a0,a0,a4
  if(write)
    8000664a:	e60d14e3          	bnez	s10,800064b2 <virtio_disk_rw+0xda>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    8000664e:	00a60793          	addi	a5,a2,10
    80006652:	00479693          	slli	a3,a5,0x4
    80006656:	0001e797          	auipc	a5,0x1e
    8000665a:	d1278793          	addi	a5,a5,-750 # 80024368 <disk>
    8000665e:	97b6                	add	a5,a5,a3
    80006660:	0007a423          	sw	zero,8(a5)
    80006664:	b595                	j	800064c8 <virtio_disk_rw+0xf0>

0000000080006666 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006666:	1101                	addi	sp,sp,-32
    80006668:	ec06                	sd	ra,24(sp)
    8000666a:	e822                	sd	s0,16(sp)
    8000666c:	e426                	sd	s1,8(sp)
    8000666e:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006670:	0001e497          	auipc	s1,0x1e
    80006674:	cf848493          	addi	s1,s1,-776 # 80024368 <disk>
    80006678:	0001e517          	auipc	a0,0x1e
    8000667c:	e1850513          	addi	a0,a0,-488 # 80024490 <disk+0x128>
    80006680:	ffffa097          	auipc	ra,0xffffa
    80006684:	56a080e7          	jalr	1386(ra) # 80000bea <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006688:	10001737          	lui	a4,0x10001
    8000668c:	533c                	lw	a5,96(a4)
    8000668e:	8b8d                	andi	a5,a5,3
    80006690:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006692:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006696:	689c                	ld	a5,16(s1)
    80006698:	0204d703          	lhu	a4,32(s1)
    8000669c:	0027d783          	lhu	a5,2(a5)
    800066a0:	04f70863          	beq	a4,a5,800066f0 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800066a4:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800066a8:	6898                	ld	a4,16(s1)
    800066aa:	0204d783          	lhu	a5,32(s1)
    800066ae:	8b9d                	andi	a5,a5,7
    800066b0:	078e                	slli	a5,a5,0x3
    800066b2:	97ba                	add	a5,a5,a4
    800066b4:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800066b6:	00278713          	addi	a4,a5,2
    800066ba:	0712                	slli	a4,a4,0x4
    800066bc:	9726                	add	a4,a4,s1
    800066be:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800066c2:	e721                	bnez	a4,8000670a <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800066c4:	0789                	addi	a5,a5,2
    800066c6:	0792                	slli	a5,a5,0x4
    800066c8:	97a6                	add	a5,a5,s1
    800066ca:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800066cc:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800066d0:	ffffc097          	auipc	ra,0xffffc
    800066d4:	cc6080e7          	jalr	-826(ra) # 80002396 <wakeup>

    disk.used_idx += 1;
    800066d8:	0204d783          	lhu	a5,32(s1)
    800066dc:	2785                	addiw	a5,a5,1
    800066de:	17c2                	slli	a5,a5,0x30
    800066e0:	93c1                	srli	a5,a5,0x30
    800066e2:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800066e6:	6898                	ld	a4,16(s1)
    800066e8:	00275703          	lhu	a4,2(a4)
    800066ec:	faf71ce3          	bne	a4,a5,800066a4 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800066f0:	0001e517          	auipc	a0,0x1e
    800066f4:	da050513          	addi	a0,a0,-608 # 80024490 <disk+0x128>
    800066f8:	ffffa097          	auipc	ra,0xffffa
    800066fc:	5a6080e7          	jalr	1446(ra) # 80000c9e <release>
}
    80006700:	60e2                	ld	ra,24(sp)
    80006702:	6442                	ld	s0,16(sp)
    80006704:	64a2                	ld	s1,8(sp)
    80006706:	6105                	addi	sp,sp,32
    80006708:	8082                	ret
      panic("virtio_disk_intr status");
    8000670a:	00002517          	auipc	a0,0x2
    8000670e:	25650513          	addi	a0,a0,598 # 80008960 <syscalls+0x3f0>
    80006712:	ffffa097          	auipc	ra,0xffffa
    80006716:	e32080e7          	jalr	-462(ra) # 80000544 <panic>
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
