
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	b8013103          	ld	sp,-1152(sp) # 80008b80 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000056:	b8e70713          	addi	a4,a4,-1138 # 80008be0 <timer_scratch>
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
    80000068:	0dc78793          	addi	a5,a5,220 # 80006140 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdadaf>
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
    80000130:	67c080e7          	jalr	1660(ra) # 800027a8 <either_copyin>
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
    80000190:	b9450513          	addi	a0,a0,-1132 # 80010d20 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	a56080e7          	jalr	-1450(ra) # 80000bea <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019c:	00011497          	auipc	s1,0x11
    800001a0:	b8448493          	addi	s1,s1,-1148 # 80010d20 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a4:	89a6                	mv	s3,s1
    800001a6:	00011917          	auipc	s2,0x11
    800001aa:	c1290913          	addi	s2,s2,-1006 # 80010db8 <cons+0x98>
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
    800001d0:	41a080e7          	jalr	1050(ra) # 800025e6 <killed>
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
    8000021a:	53c080e7          	jalr	1340(ra) # 80002752 <either_copyout>
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
    8000022e:	af650513          	addi	a0,a0,-1290 # 80010d20 <cons>
    80000232:	00001097          	auipc	ra,0x1
    80000236:	a6c080e7          	jalr	-1428(ra) # 80000c9e <release>

  return target - n;
    8000023a:	414b853b          	subw	a0,s7,s4
    8000023e:	a811                	j	80000252 <consoleread+0xee>
        release(&cons.lock);
    80000240:	00011517          	auipc	a0,0x11
    80000244:	ae050513          	addi	a0,a0,-1312 # 80010d20 <cons>
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
    8000027c:	b4f72023          	sw	a5,-1216(a4) # 80010db8 <cons+0x98>
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
    800002d6:	a4e50513          	addi	a0,a0,-1458 # 80010d20 <cons>
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
    800002fc:	506080e7          	jalr	1286(ra) # 800027fe <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000300:	00011517          	auipc	a0,0x11
    80000304:	a2050513          	addi	a0,a0,-1504 # 80010d20 <cons>
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
    80000328:	9fc70713          	addi	a4,a4,-1540 # 80010d20 <cons>
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
    80000352:	9d278793          	addi	a5,a5,-1582 # 80010d20 <cons>
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
    80000380:	a3c7a783          	lw	a5,-1476(a5) # 80010db8 <cons+0x98>
    80000384:	9f1d                	subw	a4,a4,a5
    80000386:	08000793          	li	a5,128
    8000038a:	f6f71be3          	bne	a4,a5,80000300 <consoleintr+0x3c>
    8000038e:	a07d                	j	8000043c <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000390:	00011717          	auipc	a4,0x11
    80000394:	99070713          	addi	a4,a4,-1648 # 80010d20 <cons>
    80000398:	0a072783          	lw	a5,160(a4)
    8000039c:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a0:	00011497          	auipc	s1,0x11
    800003a4:	98048493          	addi	s1,s1,-1664 # 80010d20 <cons>
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
    800003e0:	94470713          	addi	a4,a4,-1724 # 80010d20 <cons>
    800003e4:	0a072783          	lw	a5,160(a4)
    800003e8:	09c72703          	lw	a4,156(a4)
    800003ec:	f0f70ae3          	beq	a4,a5,80000300 <consoleintr+0x3c>
      cons.e--;
    800003f0:	37fd                	addiw	a5,a5,-1
    800003f2:	00011717          	auipc	a4,0x11
    800003f6:	9cf72723          	sw	a5,-1586(a4) # 80010dc0 <cons+0xa0>
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
    8000041c:	90878793          	addi	a5,a5,-1784 # 80010d20 <cons>
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
    80000440:	98c7a023          	sw	a2,-1664(a5) # 80010dbc <cons+0x9c>
        wakeup(&cons.r);
    80000444:	00011517          	auipc	a0,0x11
    80000448:	97450513          	addi	a0,a0,-1676 # 80010db8 <cons+0x98>
    8000044c:	00002097          	auipc	ra,0x2
    80000450:	f3a080e7          	jalr	-198(ra) # 80002386 <wakeup>
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
    8000046a:	8ba50513          	addi	a0,a0,-1862 # 80010d20 <cons>
    8000046e:	00000097          	auipc	ra,0x0
    80000472:	6ec080e7          	jalr	1772(ra) # 80000b5a <initlock>

  uartinit();
    80000476:	00000097          	auipc	ra,0x0
    8000047a:	330080e7          	jalr	816(ra) # 800007a6 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000047e:	00022797          	auipc	a5,0x22
    80000482:	43a78793          	addi	a5,a5,1082 # 800228b8 <devsw>
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
    80000554:	8807a823          	sw	zero,-1904(a5) # 80010de0 <pr+0x18>
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
    80000588:	60f72e23          	sw	a5,1564(a4) # 80008ba0 <panicked>
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
    800005c4:	820dad83          	lw	s11,-2016(s11) # 80010de0 <pr+0x18>
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
    80000602:	7ca50513          	addi	a0,a0,1994 # 80010dc8 <pr>
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
    80000766:	66650513          	addi	a0,a0,1638 # 80010dc8 <pr>
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
    80000782:	64a48493          	addi	s1,s1,1610 # 80010dc8 <pr>
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
    800007e2:	60a50513          	addi	a0,a0,1546 # 80010de8 <uart_tx_lock>
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
    8000080e:	3967a783          	lw	a5,918(a5) # 80008ba0 <panicked>
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
    8000084a:	36273703          	ld	a4,866(a4) # 80008ba8 <uart_tx_r>
    8000084e:	00008797          	auipc	a5,0x8
    80000852:	3627b783          	ld	a5,866(a5) # 80008bb0 <uart_tx_w>
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
    80000874:	578a0a13          	addi	s4,s4,1400 # 80010de8 <uart_tx_lock>
    uart_tx_r += 1;
    80000878:	00008497          	auipc	s1,0x8
    8000087c:	33048493          	addi	s1,s1,816 # 80008ba8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000880:	00008997          	auipc	s3,0x8
    80000884:	33098993          	addi	s3,s3,816 # 80008bb0 <uart_tx_w>
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
    800008aa:	ae0080e7          	jalr	-1312(ra) # 80002386 <wakeup>
    
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
    800008e6:	50650513          	addi	a0,a0,1286 # 80010de8 <uart_tx_lock>
    800008ea:	00000097          	auipc	ra,0x0
    800008ee:	300080e7          	jalr	768(ra) # 80000bea <acquire>
  if(panicked){
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	2ae7a783          	lw	a5,686(a5) # 80008ba0 <panicked>
    800008fa:	e7c9                	bnez	a5,80000984 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008fc:	00008797          	auipc	a5,0x8
    80000900:	2b47b783          	ld	a5,692(a5) # 80008bb0 <uart_tx_w>
    80000904:	00008717          	auipc	a4,0x8
    80000908:	2a473703          	ld	a4,676(a4) # 80008ba8 <uart_tx_r>
    8000090c:	02070713          	addi	a4,a4,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000910:	00010a17          	auipc	s4,0x10
    80000914:	4d8a0a13          	addi	s4,s4,1240 # 80010de8 <uart_tx_lock>
    80000918:	00008497          	auipc	s1,0x8
    8000091c:	29048493          	addi	s1,s1,656 # 80008ba8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000920:	00008917          	auipc	s2,0x8
    80000924:	29090913          	addi	s2,s2,656 # 80008bb0 <uart_tx_w>
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
    8000094a:	4a248493          	addi	s1,s1,1186 # 80010de8 <uart_tx_lock>
    8000094e:	01f7f713          	andi	a4,a5,31
    80000952:	9726                	add	a4,a4,s1
    80000954:	01370c23          	sb	s3,24(a4)
  uart_tx_w += 1;
    80000958:	0785                	addi	a5,a5,1
    8000095a:	00008717          	auipc	a4,0x8
    8000095e:	24f73b23          	sd	a5,598(a4) # 80008bb0 <uart_tx_w>
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
    800009d4:	41848493          	addi	s1,s1,1048 # 80010de8 <uart_tx_lock>
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
    80000a16:	03e78793          	addi	a5,a5,62 # 80023a50 <end>
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
    80000a36:	3ee90913          	addi	s2,s2,1006 # 80010e20 <kmem>
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
    80000ad2:	35250513          	addi	a0,a0,850 # 80010e20 <kmem>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	084080e7          	jalr	132(ra) # 80000b5a <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ade:	45c5                	li	a1,17
    80000ae0:	05ee                	slli	a1,a1,0x1b
    80000ae2:	00023517          	auipc	a0,0x23
    80000ae6:	f6e50513          	addi	a0,a0,-146 # 80023a50 <end>
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
    80000b08:	31c48493          	addi	s1,s1,796 # 80010e20 <kmem>
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
    80000b20:	30450513          	addi	a0,a0,772 # 80010e20 <kmem>
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
    80000b4c:	2d850513          	addi	a0,a0,728 # 80010e20 <kmem>
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
    80000ea8:	d1470713          	addi	a4,a4,-748 # 80008bb8 <started>
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
    80000ede:	a68080e7          	jalr	-1432(ra) # 80002942 <trapinithart>
    // printf("trapinit done\n");
    plicinithart();   // ask PLIC for device interrupts
    80000ee2:	00005097          	auipc	ra,0x5
    80000ee6:	29e080e7          	jalr	670(ra) # 80006180 <plicinithart>
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
    80000f56:	9c8080e7          	jalr	-1592(ra) # 8000291a <trapinit>
    trapinithart();  // install kernel trap vector
    80000f5a:	00002097          	auipc	ra,0x2
    80000f5e:	9e8080e7          	jalr	-1560(ra) # 80002942 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	208080e7          	jalr	520(ra) # 8000616a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f6a:	00005097          	auipc	ra,0x5
    80000f6e:	216080e7          	jalr	534(ra) # 80006180 <plicinithart>
    binit();         // buffer cache
    80000f72:	00002097          	auipc	ra,0x2
    80000f76:	3d0080e7          	jalr	976(ra) # 80003342 <binit>
    iinit();         // inode table
    80000f7a:	00003097          	auipc	ra,0x3
    80000f7e:	a74080e7          	jalr	-1420(ra) # 800039ee <iinit>
    fileinit();      // file table
    80000f82:	00004097          	auipc	ra,0x4
    80000f86:	a12080e7          	jalr	-1518(ra) # 80004994 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f8a:	00005097          	auipc	ra,0x5
    80000f8e:	2fe080e7          	jalr	766(ra) # 80006288 <virtio_disk_init>
    userinit();      // first user process
    80000f92:	00001097          	auipc	ra,0x1
    80000f96:	e20080e7          	jalr	-480(ra) # 80001db2 <userinit>
    __sync_synchronize();
    80000f9a:	0ff0000f          	fence
    started = 1;
    80000f9e:	4785                	li	a5,1
    80000fa0:	00008717          	auipc	a4,0x8
    80000fa4:	c0f72c23          	sw	a5,-1000(a4) # 80008bb8 <started>
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
    80000fb8:	c0c7b783          	ld	a5,-1012(a5) # 80008bc0 <kernel_pagetable>
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
    80001274:	94a7b823          	sd	a0,-1712(a5) # 80008bc0 <kernel_pagetable>
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
    800018bc:	9b848493          	addi	s1,s1,-1608 # 80011270 <proc>
    800018c0:	00017a17          	auipc	s4,0x17
    800018c4:	db0a0a13          	addi	s4,s4,-592 # 80018670 <tickslock>
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
    80001972:	90248493          	addi	s1,s1,-1790 # 80011270 <proc>
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
    8000198c:	ce8a0a13          	addi	s4,s4,-792 # 80018670 <tickslock>
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
    80001a0e:	43650513          	addi	a0,a0,1078 # 80010e40 <pid_lock>
    80001a12:	fffff097          	auipc	ra,0xfffff
    80001a16:	148080e7          	jalr	328(ra) # 80000b5a <initlock>
	initlock(&wait_lock, "wait_lock");
    80001a1a:	00006597          	auipc	a1,0x6
    80001a1e:	7e658593          	addi	a1,a1,2022 # 80008200 <digits+0x1c0>
    80001a22:	0000f517          	auipc	a0,0xf
    80001a26:	43650513          	addi	a0,a0,1078 # 80010e58 <wait_lock>
    80001a2a:	fffff097          	auipc	ra,0xfffff
    80001a2e:	130080e7          	jalr	304(ra) # 80000b5a <initlock>
	for (p = proc; p < &proc[NPROC]; p++)
    80001a32:	00010497          	auipc	s1,0x10
    80001a36:	83e48493          	addi	s1,s1,-1986 # 80011270 <proc>
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
    80001a58:	c1c98993          	addi	s3,s3,-996 # 80018670 <tickslock>
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
    80001ac4:	3b050513          	addi	a0,a0,944 # 80010e70 <cpus>
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
    80001aec:	35870713          	addi	a4,a4,856 # 80010e40 <pid_lock>
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
    80001b26:	e6e7a783          	lw	a5,-402(a5) # 80008990 <first.2449>
    80001b2a:	eb89                	bnez	a5,80001b3c <forkret+0x34>
		// be run from main().
		first = 0;
		fsinit(ROOTDEV);
	}

	usertrapret();
    80001b2c:	00001097          	auipc	ra,0x1
    80001b30:	e2e080e7          	jalr	-466(ra) # 8000295a <usertrapret>
}
    80001b34:	60a2                	ld	ra,8(sp)
    80001b36:	6402                	ld	s0,0(sp)
    80001b38:	0141                	addi	sp,sp,16
    80001b3a:	8082                	ret
		first = 0;
    80001b3c:	00007797          	auipc	a5,0x7
    80001b40:	e407aa23          	sw	zero,-428(a5) # 80008990 <first.2449>
		fsinit(ROOTDEV);
    80001b44:	4505                	li	a0,1
    80001b46:	00002097          	auipc	ra,0x2
    80001b4a:	e28080e7          	jalr	-472(ra) # 8000396e <fsinit>
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
    80001b60:	2e490913          	addi	s2,s2,740 # 80010e40 <pid_lock>
    80001b64:	854a                	mv	a0,s2
    80001b66:	fffff097          	auipc	ra,0xfffff
    80001b6a:	084080e7          	jalr	132(ra) # 80000bea <acquire>
	pid = nextpid;
    80001b6e:	00007797          	auipc	a5,0x7
    80001b72:	e2678793          	addi	a5,a5,-474 # 80008994 <nextpid>
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
    80001cee:	58648493          	addi	s1,s1,1414 # 80011270 <proc>
    80001cf2:	00017997          	auipc	s3,0x17
    80001cf6:	97e98993          	addi	s3,s3,-1666 # 80018670 <tickslock>
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
    80001dca:	e0a7b123          	sd	a0,-510(a5) # 80008bc8 <initproc>
	uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001dce:	03400613          	li	a2,52
    80001dd2:	00007597          	auipc	a1,0x7
    80001dd6:	bce58593          	addi	a1,a1,-1074 # 800089a0 <initcode>
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
    80001e14:	580080e7          	jalr	1408(ra) # 80004390 <namei>
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
    80001f40:	aea080e7          	jalr	-1302(ra) # 80004a26 <filedup>
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
    80001f62:	c4e080e7          	jalr	-946(ra) # 80003bac <idup>
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
    80001f92:	ecaa0a13          	addi	s4,s4,-310 # 80010e58 <wait_lock>
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
    80001ff0:	28c48493          	addi	s1,s1,652 # 80011278 <proc+0x8>
    80001ff4:	00016917          	auipc	s2,0x16
    80001ff8:	68490913          	addi	s2,s2,1668 # 80018678 <tickslock+0x8>
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
    80002046:	dfe70713          	addi	a4,a4,-514 # 80010e40 <pid_lock>
    8000204a:	975a                	add	a4,a4,s6
    8000204c:	02073823          	sd	zero,48(a4)
				swtch(&c->context, &p->context);
    80002050:	0000f717          	auipc	a4,0xf
    80002054:	e2870713          	addi	a4,a4,-472 # 80010e78 <cpus+0x8>
    80002058:	9b3a                	add	s6,s6,a4
			if (p->state == RUNNABLE)
    8000205a:	4a0d                	li	s4,3
				p->state = RUNNING;
    8000205c:	4b91                	li	s7,4
				c->proc = p;
    8000205e:	079e                	slli	a5,a5,0x7
    80002060:	0000fa97          	auipc	s5,0xf
    80002064:	de0a8a93          	addi	s5,s5,-544 # 80010e40 <pid_lock>
    80002068:	9abe                	add	s5,s5,a5
		for (p = proc; p < &proc[NPROC]; p++)
    8000206a:	00016997          	auipc	s3,0x16
    8000206e:	60698993          	addi	s3,s3,1542 # 80018670 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002072:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002076:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000207a:	10079073          	csrw	sstatus,a5
    8000207e:	0000f497          	auipc	s1,0xf
    80002082:	1f248493          	addi	s1,s1,498 # 80011270 <proc>
    80002086:	a03d                	j	800020b4 <scheduler+0x90>
				p->state = RUNNING;
    80002088:	0374a023          	sw	s7,32(s1)
				c->proc = p;
    8000208c:	029ab823          	sd	s1,48(s5)
				swtch(&c->context, &p->context);
    80002090:	06848593          	addi	a1,s1,104
    80002094:	855a                	mv	a0,s6
    80002096:	00001097          	auipc	ra,0x1
    8000209a:	81a080e7          	jalr	-2022(ra) # 800028b0 <swtch>
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
    800020f8:	d4c70713          	addi	a4,a4,-692 # 80010e40 <pid_lock>
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
    8000211e:	d2690913          	addi	s2,s2,-730 # 80010e40 <pid_lock>
    80002122:	2781                	sext.w	a5,a5
    80002124:	079e                	slli	a5,a5,0x7
    80002126:	97ca                	add	a5,a5,s2
    80002128:	0ac7a983          	lw	s3,172(a5)
    8000212c:	8792                	mv	a5,tp
	swtch(&p->context, &mycpu()->context);
    8000212e:	2781                	sext.w	a5,a5
    80002130:	079e                	slli	a5,a5,0x7
    80002132:	0000f597          	auipc	a1,0xf
    80002136:	d4658593          	addi	a1,a1,-698 # 80010e78 <cpus+0x8>
    8000213a:	95be                	add	a1,a1,a5
    8000213c:	06848513          	addi	a0,s1,104
    80002140:	00000097          	auipc	ra,0x0
    80002144:	770080e7          	jalr	1904(ra) # 800028b0 <swtch>
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

0000000080002256 <waitx>:
{
    80002256:	711d                	addi	sp,sp,-96
    80002258:	ec86                	sd	ra,88(sp)
    8000225a:	e8a2                	sd	s0,80(sp)
    8000225c:	e4a6                	sd	s1,72(sp)
    8000225e:	e0ca                	sd	s2,64(sp)
    80002260:	fc4e                	sd	s3,56(sp)
    80002262:	f852                	sd	s4,48(sp)
    80002264:	f456                	sd	s5,40(sp)
    80002266:	f05a                	sd	s6,32(sp)
    80002268:	ec5e                	sd	s7,24(sp)
    8000226a:	e862                	sd	s8,16(sp)
    8000226c:	e466                	sd	s9,8(sp)
    8000226e:	1080                	addi	s0,sp,96
    80002270:	8baa                	mv	s7,a0
	struct proc *p = myproc();
    80002272:	00000097          	auipc	ra,0x0
    80002276:	85e080e7          	jalr	-1954(ra) # 80001ad0 <myproc>
    8000227a:	892a                	mv	s2,a0
	acquire(&wait_lock);
    8000227c:	0000f517          	auipc	a0,0xf
    80002280:	bdc50513          	addi	a0,a0,-1060 # 80010e58 <wait_lock>
    80002284:	fffff097          	auipc	ra,0xfffff
    80002288:	966080e7          	jalr	-1690(ra) # 80000bea <acquire>
		havekids = 0;
    8000228c:	4c01                	li	s8,0
				if (np->state == ZOMBIE)
    8000228e:	4a95                	li	s5,5
		for (np = proc; np < &proc[NPROC]; np++)
    80002290:	00016997          	auipc	s3,0x16
    80002294:	3e098993          	addi	s3,s3,992 # 80018670 <tickslock>
				havekids = 1;
    80002298:	4b05                	li	s6,1
		sleep(p, &wait_lock); // DOC: wait-sleep
    8000229a:	0000fc97          	auipc	s9,0xf
    8000229e:	bbec8c93          	addi	s9,s9,-1090 # 80010e58 <wait_lock>
		havekids = 0;
    800022a2:	8762                	mv	a4,s8
		for (np = proc; np < &proc[NPROC]; np++)
    800022a4:	0000f497          	auipc	s1,0xf
    800022a8:	fcc48493          	addi	s1,s1,-52 # 80011270 <proc>
    800022ac:	a0bd                	j	8000231a <waitx+0xc4>
					pid = np->pid;
    800022ae:	0384a983          	lw	s3,56(s1)
					if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800022b2:	000b8e63          	beqz	s7,800022ce <waitx+0x78>
    800022b6:	4691                	li	a3,4
    800022b8:	03448613          	addi	a2,s1,52
    800022bc:	85de                	mv	a1,s7
    800022be:	05893503          	ld	a0,88(s2)
    800022c2:	fffff097          	auipc	ra,0xfffff
    800022c6:	3c2080e7          	jalr	962(ra) # 80001684 <copyout>
    800022ca:	02054563          	bltz	a0,800022f4 <waitx+0x9e>
					freeproc(np);
    800022ce:	8526                	mv	a0,s1
    800022d0:	00000097          	auipc	ra,0x0
    800022d4:	9b4080e7          	jalr	-1612(ra) # 80001c84 <freeproc>
					release(&np->lock);
    800022d8:	8552                	mv	a0,s4
    800022da:	fffff097          	auipc	ra,0xfffff
    800022de:	9c4080e7          	jalr	-1596(ra) # 80000c9e <release>
					release(&wait_lock);
    800022e2:	0000f517          	auipc	a0,0xf
    800022e6:	b7650513          	addi	a0,a0,-1162 # 80010e58 <wait_lock>
    800022ea:	fffff097          	auipc	ra,0xfffff
    800022ee:	9b4080e7          	jalr	-1612(ra) # 80000c9e <release>
					return pid;
    800022f2:	a0ad                	j	8000235c <waitx+0x106>
						release(&np->lock);
    800022f4:	8552                	mv	a0,s4
    800022f6:	fffff097          	auipc	ra,0xfffff
    800022fa:	9a8080e7          	jalr	-1624(ra) # 80000c9e <release>
						release(&wait_lock);
    800022fe:	0000f517          	auipc	a0,0xf
    80002302:	b5a50513          	addi	a0,a0,-1190 # 80010e58 <wait_lock>
    80002306:	fffff097          	auipc	ra,0xfffff
    8000230a:	998080e7          	jalr	-1640(ra) # 80000c9e <release>
						return -1;
    8000230e:	59fd                	li	s3,-1
    80002310:	a0b1                	j	8000235c <waitx+0x106>
		for (np = proc; np < &proc[NPROC]; np++)
    80002312:	1d048493          	addi	s1,s1,464
    80002316:	03348663          	beq	s1,s3,80002342 <waitx+0xec>
			if (np->parent == p)
    8000231a:	60bc                	ld	a5,64(s1)
    8000231c:	ff279be3          	bne	a5,s2,80002312 <waitx+0xbc>
				acquire(&np->lock);
    80002320:	00848a13          	addi	s4,s1,8
    80002324:	8552                	mv	a0,s4
    80002326:	fffff097          	auipc	ra,0xfffff
    8000232a:	8c4080e7          	jalr	-1852(ra) # 80000bea <acquire>
				if (np->state == ZOMBIE)
    8000232e:	509c                	lw	a5,32(s1)
    80002330:	f7578fe3          	beq	a5,s5,800022ae <waitx+0x58>
				release(&np->lock);
    80002334:	8552                	mv	a0,s4
    80002336:	fffff097          	auipc	ra,0xfffff
    8000233a:	968080e7          	jalr	-1688(ra) # 80000c9e <release>
				havekids = 1;
    8000233e:	875a                	mv	a4,s6
    80002340:	bfc9                	j	80002312 <waitx+0xbc>
		if (!havekids || p->killed)
    80002342:	c701                	beqz	a4,8000234a <waitx+0xf4>
    80002344:	03092783          	lw	a5,48(s2)
    80002348:	cb85                	beqz	a5,80002378 <waitx+0x122>
			release(&wait_lock);
    8000234a:	0000f517          	auipc	a0,0xf
    8000234e:	b0e50513          	addi	a0,a0,-1266 # 80010e58 <wait_lock>
    80002352:	fffff097          	auipc	ra,0xfffff
    80002356:	94c080e7          	jalr	-1716(ra) # 80000c9e <release>
			return -1;
    8000235a:	59fd                	li	s3,-1
}
    8000235c:	854e                	mv	a0,s3
    8000235e:	60e6                	ld	ra,88(sp)
    80002360:	6446                	ld	s0,80(sp)
    80002362:	64a6                	ld	s1,72(sp)
    80002364:	6906                	ld	s2,64(sp)
    80002366:	79e2                	ld	s3,56(sp)
    80002368:	7a42                	ld	s4,48(sp)
    8000236a:	7aa2                	ld	s5,40(sp)
    8000236c:	7b02                	ld	s6,32(sp)
    8000236e:	6be2                	ld	s7,24(sp)
    80002370:	6c42                	ld	s8,16(sp)
    80002372:	6ca2                	ld	s9,8(sp)
    80002374:	6125                	addi	sp,sp,96
    80002376:	8082                	ret
		sleep(p, &wait_lock); // DOC: wait-sleep
    80002378:	85e6                	mv	a1,s9
    8000237a:	854a                	mv	a0,s2
    8000237c:	00000097          	auipc	ra,0x0
    80002380:	e6c080e7          	jalr	-404(ra) # 800021e8 <sleep>
		havekids = 0;
    80002384:	bf39                	j	800022a2 <waitx+0x4c>

0000000080002386 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    80002386:	7139                	addi	sp,sp,-64
    80002388:	fc06                	sd	ra,56(sp)
    8000238a:	f822                	sd	s0,48(sp)
    8000238c:	f426                	sd	s1,40(sp)
    8000238e:	f04a                	sd	s2,32(sp)
    80002390:	ec4e                	sd	s3,24(sp)
    80002392:	e852                	sd	s4,16(sp)
    80002394:	e456                	sd	s5,8(sp)
    80002396:	e05a                	sd	s6,0(sp)
    80002398:	0080                	addi	s0,sp,64
    8000239a:	8aaa                	mv	s5,a0
	struct proc *p;

	for (p = proc; p < &proc[NPROC]; p++)
    8000239c:	0000f497          	auipc	s1,0xf
    800023a0:	ed448493          	addi	s1,s1,-300 # 80011270 <proc>
	{
		if (p != myproc())
		{
			acquire(&p->lock);
			if (p->state == SLEEPING && p->chan == chan)
    800023a4:	4a09                	li	s4,2
			{
				p->state = RUNNABLE;
    800023a6:	4b0d                	li	s6,3
	for (p = proc; p < &proc[NPROC]; p++)
    800023a8:	00016997          	auipc	s3,0x16
    800023ac:	2c898993          	addi	s3,s3,712 # 80018670 <tickslock>
    800023b0:	a821                	j	800023c8 <wakeup+0x42>
				p->state = RUNNABLE;
    800023b2:	0364a023          	sw	s6,32(s1)
				int slices[5] = {1, 2, 4, 8, 16};
				p->time_slice = slices[p->curr_queue];
				push(&mlfq[p->curr_queue], p);
#endif
			}
			release(&p->lock);
    800023b6:	854a                	mv	a0,s2
    800023b8:	fffff097          	auipc	ra,0xfffff
    800023bc:	8e6080e7          	jalr	-1818(ra) # 80000c9e <release>
	for (p = proc; p < &proc[NPROC]; p++)
    800023c0:	1d048493          	addi	s1,s1,464
    800023c4:	03348663          	beq	s1,s3,800023f0 <wakeup+0x6a>
		if (p != myproc())
    800023c8:	fffff097          	auipc	ra,0xfffff
    800023cc:	708080e7          	jalr	1800(ra) # 80001ad0 <myproc>
    800023d0:	fea488e3          	beq	s1,a0,800023c0 <wakeup+0x3a>
			acquire(&p->lock);
    800023d4:	00848913          	addi	s2,s1,8
    800023d8:	854a                	mv	a0,s2
    800023da:	fffff097          	auipc	ra,0xfffff
    800023de:	810080e7          	jalr	-2032(ra) # 80000bea <acquire>
			if (p->state == SLEEPING && p->chan == chan)
    800023e2:	509c                	lw	a5,32(s1)
    800023e4:	fd4799e3          	bne	a5,s4,800023b6 <wakeup+0x30>
    800023e8:	749c                	ld	a5,40(s1)
    800023ea:	fd5796e3          	bne	a5,s5,800023b6 <wakeup+0x30>
    800023ee:	b7d1                	j	800023b2 <wakeup+0x2c>
		}
	}
}
    800023f0:	70e2                	ld	ra,56(sp)
    800023f2:	7442                	ld	s0,48(sp)
    800023f4:	74a2                	ld	s1,40(sp)
    800023f6:	7902                	ld	s2,32(sp)
    800023f8:	69e2                	ld	s3,24(sp)
    800023fa:	6a42                	ld	s4,16(sp)
    800023fc:	6aa2                	ld	s5,8(sp)
    800023fe:	6b02                	ld	s6,0(sp)
    80002400:	6121                	addi	sp,sp,64
    80002402:	8082                	ret

0000000080002404 <reparent>:
{
    80002404:	7179                	addi	sp,sp,-48
    80002406:	f406                	sd	ra,40(sp)
    80002408:	f022                	sd	s0,32(sp)
    8000240a:	ec26                	sd	s1,24(sp)
    8000240c:	e84a                	sd	s2,16(sp)
    8000240e:	e44e                	sd	s3,8(sp)
    80002410:	e052                	sd	s4,0(sp)
    80002412:	1800                	addi	s0,sp,48
    80002414:	892a                	mv	s2,a0
	for (pp = proc; pp < &proc[NPROC]; pp++)
    80002416:	0000f497          	auipc	s1,0xf
    8000241a:	e5a48493          	addi	s1,s1,-422 # 80011270 <proc>
			pp->parent = initproc;
    8000241e:	00006a17          	auipc	s4,0x6
    80002422:	7aaa0a13          	addi	s4,s4,1962 # 80008bc8 <initproc>
	for (pp = proc; pp < &proc[NPROC]; pp++)
    80002426:	00016997          	auipc	s3,0x16
    8000242a:	24a98993          	addi	s3,s3,586 # 80018670 <tickslock>
    8000242e:	a029                	j	80002438 <reparent+0x34>
    80002430:	1d048493          	addi	s1,s1,464
    80002434:	01348d63          	beq	s1,s3,8000244e <reparent+0x4a>
		if (pp->parent == p)
    80002438:	60bc                	ld	a5,64(s1)
    8000243a:	ff279be3          	bne	a5,s2,80002430 <reparent+0x2c>
			pp->parent = initproc;
    8000243e:	000a3503          	ld	a0,0(s4)
    80002442:	e0a8                	sd	a0,64(s1)
			wakeup(initproc);
    80002444:	00000097          	auipc	ra,0x0
    80002448:	f42080e7          	jalr	-190(ra) # 80002386 <wakeup>
    8000244c:	b7d5                	j	80002430 <reparent+0x2c>
}
    8000244e:	70a2                	ld	ra,40(sp)
    80002450:	7402                	ld	s0,32(sp)
    80002452:	64e2                	ld	s1,24(sp)
    80002454:	6942                	ld	s2,16(sp)
    80002456:	69a2                	ld	s3,8(sp)
    80002458:	6a02                	ld	s4,0(sp)
    8000245a:	6145                	addi	sp,sp,48
    8000245c:	8082                	ret

000000008000245e <exit>:
{
    8000245e:	7179                	addi	sp,sp,-48
    80002460:	f406                	sd	ra,40(sp)
    80002462:	f022                	sd	s0,32(sp)
    80002464:	ec26                	sd	s1,24(sp)
    80002466:	e84a                	sd	s2,16(sp)
    80002468:	e44e                	sd	s3,8(sp)
    8000246a:	e052                	sd	s4,0(sp)
    8000246c:	1800                	addi	s0,sp,48
    8000246e:	8a2a                	mv	s4,a0
	struct proc *p = myproc();
    80002470:	fffff097          	auipc	ra,0xfffff
    80002474:	660080e7          	jalr	1632(ra) # 80001ad0 <myproc>
    80002478:	89aa                	mv	s3,a0
	if (p == initproc)
    8000247a:	00006797          	auipc	a5,0x6
    8000247e:	74e7b783          	ld	a5,1870(a5) # 80008bc8 <initproc>
    80002482:	0d850493          	addi	s1,a0,216
    80002486:	15850913          	addi	s2,a0,344
    8000248a:	02a79363          	bne	a5,a0,800024b0 <exit+0x52>
		panic("init exiting");
    8000248e:	00006517          	auipc	a0,0x6
    80002492:	dea50513          	addi	a0,a0,-534 # 80008278 <digits+0x238>
    80002496:	ffffe097          	auipc	ra,0xffffe
    8000249a:	0ae080e7          	jalr	174(ra) # 80000544 <panic>
			fileclose(f);
    8000249e:	00002097          	auipc	ra,0x2
    800024a2:	5da080e7          	jalr	1498(ra) # 80004a78 <fileclose>
			p->ofile[fd] = 0;
    800024a6:	0004b023          	sd	zero,0(s1)
	for (int fd = 0; fd < NOFILE; fd++)
    800024aa:	04a1                	addi	s1,s1,8
    800024ac:	01248563          	beq	s1,s2,800024b6 <exit+0x58>
		if (p->ofile[fd])
    800024b0:	6088                	ld	a0,0(s1)
    800024b2:	f575                	bnez	a0,8000249e <exit+0x40>
    800024b4:	bfdd                	j	800024aa <exit+0x4c>
	begin_op();
    800024b6:	00002097          	auipc	ra,0x2
    800024ba:	0f6080e7          	jalr	246(ra) # 800045ac <begin_op>
	iput(p->cwd);
    800024be:	1589b503          	ld	a0,344(s3)
    800024c2:	00002097          	auipc	ra,0x2
    800024c6:	8e2080e7          	jalr	-1822(ra) # 80003da4 <iput>
	end_op();
    800024ca:	00002097          	auipc	ra,0x2
    800024ce:	162080e7          	jalr	354(ra) # 8000462c <end_op>
	p->cwd = 0;
    800024d2:	1409bc23          	sd	zero,344(s3)
	acquire(&wait_lock);
    800024d6:	0000f497          	auipc	s1,0xf
    800024da:	98248493          	addi	s1,s1,-1662 # 80010e58 <wait_lock>
    800024de:	8526                	mv	a0,s1
    800024e0:	ffffe097          	auipc	ra,0xffffe
    800024e4:	70a080e7          	jalr	1802(ra) # 80000bea <acquire>
	reparent(p);
    800024e8:	854e                	mv	a0,s3
    800024ea:	00000097          	auipc	ra,0x0
    800024ee:	f1a080e7          	jalr	-230(ra) # 80002404 <reparent>
	wakeup(p->parent);
    800024f2:	0409b503          	ld	a0,64(s3)
    800024f6:	00000097          	auipc	ra,0x0
    800024fa:	e90080e7          	jalr	-368(ra) # 80002386 <wakeup>
	acquire(&p->lock);
    800024fe:	00898513          	addi	a0,s3,8
    80002502:	ffffe097          	auipc	ra,0xffffe
    80002506:	6e8080e7          	jalr	1768(ra) # 80000bea <acquire>
	p->xstate = status;
    8000250a:	0349aa23          	sw	s4,52(s3)
	p->state = ZOMBIE;
    8000250e:	4795                	li	a5,5
    80002510:	02f9a023          	sw	a5,32(s3)
	release(&wait_lock);
    80002514:	8526                	mv	a0,s1
    80002516:	ffffe097          	auipc	ra,0xffffe
    8000251a:	788080e7          	jalr	1928(ra) # 80000c9e <release>
	sched();
    8000251e:	00000097          	auipc	ra,0x0
    80002522:	bac080e7          	jalr	-1108(ra) # 800020ca <sched>
	panic("zombie exit");
    80002526:	00006517          	auipc	a0,0x6
    8000252a:	d6250513          	addi	a0,a0,-670 # 80008288 <digits+0x248>
    8000252e:	ffffe097          	auipc	ra,0xffffe
    80002532:	016080e7          	jalr	22(ra) # 80000544 <panic>

0000000080002536 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    80002536:	7179                	addi	sp,sp,-48
    80002538:	f406                	sd	ra,40(sp)
    8000253a:	f022                	sd	s0,32(sp)
    8000253c:	ec26                	sd	s1,24(sp)
    8000253e:	e84a                	sd	s2,16(sp)
    80002540:	e44e                	sd	s3,8(sp)
    80002542:	e052                	sd	s4,0(sp)
    80002544:	1800                	addi	s0,sp,48
    80002546:	89aa                	mv	s3,a0
	struct proc *p;

	for (p = proc; p < &proc[NPROC]; p++)
    80002548:	0000f497          	auipc	s1,0xf
    8000254c:	d2848493          	addi	s1,s1,-728 # 80011270 <proc>
    80002550:	00016a17          	auipc	s4,0x16
    80002554:	120a0a13          	addi	s4,s4,288 # 80018670 <tickslock>
	{
		acquire(&p->lock);
    80002558:	00848913          	addi	s2,s1,8
    8000255c:	854a                	mv	a0,s2
    8000255e:	ffffe097          	auipc	ra,0xffffe
    80002562:	68c080e7          	jalr	1676(ra) # 80000bea <acquire>
		if (p->pid == pid)
    80002566:	5c9c                	lw	a5,56(s1)
    80002568:	01378d63          	beq	a5,s3,80002582 <kill+0x4c>
#endif
			}
			release(&p->lock);
			return 0;
		}
		release(&p->lock);
    8000256c:	854a                	mv	a0,s2
    8000256e:	ffffe097          	auipc	ra,0xffffe
    80002572:	730080e7          	jalr	1840(ra) # 80000c9e <release>
	for (p = proc; p < &proc[NPROC]; p++)
    80002576:	1d048493          	addi	s1,s1,464
    8000257a:	fd449fe3          	bne	s1,s4,80002558 <kill+0x22>
	}
	return -1;
    8000257e:	557d                	li	a0,-1
    80002580:	a829                	j	8000259a <kill+0x64>
			p->killed = 1;
    80002582:	4785                	li	a5,1
    80002584:	d89c                	sw	a5,48(s1)
			if (p->state == SLEEPING)
    80002586:	5098                	lw	a4,32(s1)
    80002588:	4789                	li	a5,2
    8000258a:	02f70063          	beq	a4,a5,800025aa <kill+0x74>
			release(&p->lock);
    8000258e:	854a                	mv	a0,s2
    80002590:	ffffe097          	auipc	ra,0xffffe
    80002594:	70e080e7          	jalr	1806(ra) # 80000c9e <release>
			return 0;
    80002598:	4501                	li	a0,0
}
    8000259a:	70a2                	ld	ra,40(sp)
    8000259c:	7402                	ld	s0,32(sp)
    8000259e:	64e2                	ld	s1,24(sp)
    800025a0:	6942                	ld	s2,16(sp)
    800025a2:	69a2                	ld	s3,8(sp)
    800025a4:	6a02                	ld	s4,0(sp)
    800025a6:	6145                	addi	sp,sp,48
    800025a8:	8082                	ret
				p->state = RUNNABLE;
    800025aa:	478d                	li	a5,3
    800025ac:	d09c                	sw	a5,32(s1)
    800025ae:	b7c5                	j	8000258e <kill+0x58>

00000000800025b0 <setkilled>:

void setkilled(struct proc *p)
{
    800025b0:	1101                	addi	sp,sp,-32
    800025b2:	ec06                	sd	ra,24(sp)
    800025b4:	e822                	sd	s0,16(sp)
    800025b6:	e426                	sd	s1,8(sp)
    800025b8:	e04a                	sd	s2,0(sp)
    800025ba:	1000                	addi	s0,sp,32
    800025bc:	84aa                	mv	s1,a0
	acquire(&p->lock);
    800025be:	00850913          	addi	s2,a0,8
    800025c2:	854a                	mv	a0,s2
    800025c4:	ffffe097          	auipc	ra,0xffffe
    800025c8:	626080e7          	jalr	1574(ra) # 80000bea <acquire>
	p->killed = 1;
    800025cc:	4785                	li	a5,1
    800025ce:	d89c                	sw	a5,48(s1)
	release(&p->lock);
    800025d0:	854a                	mv	a0,s2
    800025d2:	ffffe097          	auipc	ra,0xffffe
    800025d6:	6cc080e7          	jalr	1740(ra) # 80000c9e <release>
}
    800025da:	60e2                	ld	ra,24(sp)
    800025dc:	6442                	ld	s0,16(sp)
    800025de:	64a2                	ld	s1,8(sp)
    800025e0:	6902                	ld	s2,0(sp)
    800025e2:	6105                	addi	sp,sp,32
    800025e4:	8082                	ret

00000000800025e6 <killed>:

int killed(struct proc *p)
{
    800025e6:	1101                	addi	sp,sp,-32
    800025e8:	ec06                	sd	ra,24(sp)
    800025ea:	e822                	sd	s0,16(sp)
    800025ec:	e426                	sd	s1,8(sp)
    800025ee:	e04a                	sd	s2,0(sp)
    800025f0:	1000                	addi	s0,sp,32
    800025f2:	84aa                	mv	s1,a0
	int k;

	acquire(&p->lock);
    800025f4:	00850913          	addi	s2,a0,8
    800025f8:	854a                	mv	a0,s2
    800025fa:	ffffe097          	auipc	ra,0xffffe
    800025fe:	5f0080e7          	jalr	1520(ra) # 80000bea <acquire>
	k = p->killed;
    80002602:	5884                	lw	s1,48(s1)
	release(&p->lock);
    80002604:	854a                	mv	a0,s2
    80002606:	ffffe097          	auipc	ra,0xffffe
    8000260a:	698080e7          	jalr	1688(ra) # 80000c9e <release>
	return k;
}
    8000260e:	8526                	mv	a0,s1
    80002610:	60e2                	ld	ra,24(sp)
    80002612:	6442                	ld	s0,16(sp)
    80002614:	64a2                	ld	s1,8(sp)
    80002616:	6902                	ld	s2,0(sp)
    80002618:	6105                	addi	sp,sp,32
    8000261a:	8082                	ret

000000008000261c <wait>:
{
    8000261c:	711d                	addi	sp,sp,-96
    8000261e:	ec86                	sd	ra,88(sp)
    80002620:	e8a2                	sd	s0,80(sp)
    80002622:	e4a6                	sd	s1,72(sp)
    80002624:	e0ca                	sd	s2,64(sp)
    80002626:	fc4e                	sd	s3,56(sp)
    80002628:	f852                	sd	s4,48(sp)
    8000262a:	f456                	sd	s5,40(sp)
    8000262c:	f05a                	sd	s6,32(sp)
    8000262e:	ec5e                	sd	s7,24(sp)
    80002630:	e862                	sd	s8,16(sp)
    80002632:	e466                	sd	s9,8(sp)
    80002634:	1080                	addi	s0,sp,96
    80002636:	8baa                	mv	s7,a0
	struct proc *p = myproc();
    80002638:	fffff097          	auipc	ra,0xfffff
    8000263c:	498080e7          	jalr	1176(ra) # 80001ad0 <myproc>
    80002640:	892a                	mv	s2,a0
	acquire(&wait_lock);
    80002642:	0000f517          	auipc	a0,0xf
    80002646:	81650513          	addi	a0,a0,-2026 # 80010e58 <wait_lock>
    8000264a:	ffffe097          	auipc	ra,0xffffe
    8000264e:	5a0080e7          	jalr	1440(ra) # 80000bea <acquire>
		havekids = 0;
    80002652:	4c01                	li	s8,0
				if (pp->state == ZOMBIE)
    80002654:	4a95                	li	s5,5
		for (pp = proc; pp < &proc[NPROC]; pp++)
    80002656:	00016997          	auipc	s3,0x16
    8000265a:	01a98993          	addi	s3,s3,26 # 80018670 <tickslock>
				havekids = 1;
    8000265e:	4b05                	li	s6,1
		sleep(p, &wait_lock); // DOC: wait-sleep
    80002660:	0000ec97          	auipc	s9,0xe
    80002664:	7f8c8c93          	addi	s9,s9,2040 # 80010e58 <wait_lock>
		havekids = 0;
    80002668:	8762                	mv	a4,s8
		for (pp = proc; pp < &proc[NPROC]; pp++)
    8000266a:	0000f497          	auipc	s1,0xf
    8000266e:	c0648493          	addi	s1,s1,-1018 # 80011270 <proc>
    80002672:	a0bd                	j	800026e0 <wait+0xc4>
					pid = pp->pid;
    80002674:	0384a983          	lw	s3,56(s1)
					if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002678:	000b8e63          	beqz	s7,80002694 <wait+0x78>
    8000267c:	4691                	li	a3,4
    8000267e:	03448613          	addi	a2,s1,52
    80002682:	85de                	mv	a1,s7
    80002684:	05893503          	ld	a0,88(s2)
    80002688:	fffff097          	auipc	ra,0xfffff
    8000268c:	ffc080e7          	jalr	-4(ra) # 80001684 <copyout>
    80002690:	02054563          	bltz	a0,800026ba <wait+0x9e>
					freeproc(pp);
    80002694:	8526                	mv	a0,s1
    80002696:	fffff097          	auipc	ra,0xfffff
    8000269a:	5ee080e7          	jalr	1518(ra) # 80001c84 <freeproc>
					release(&pp->lock);
    8000269e:	8552                	mv	a0,s4
    800026a0:	ffffe097          	auipc	ra,0xffffe
    800026a4:	5fe080e7          	jalr	1534(ra) # 80000c9e <release>
					release(&wait_lock);
    800026a8:	0000e517          	auipc	a0,0xe
    800026ac:	7b050513          	addi	a0,a0,1968 # 80010e58 <wait_lock>
    800026b0:	ffffe097          	auipc	ra,0xffffe
    800026b4:	5ee080e7          	jalr	1518(ra) # 80000c9e <release>
					return pid;
    800026b8:	a885                	j	80002728 <wait+0x10c>
						release(&pp->lock);
    800026ba:	8552                	mv	a0,s4
    800026bc:	ffffe097          	auipc	ra,0xffffe
    800026c0:	5e2080e7          	jalr	1506(ra) # 80000c9e <release>
						release(&wait_lock);
    800026c4:	0000e517          	auipc	a0,0xe
    800026c8:	79450513          	addi	a0,a0,1940 # 80010e58 <wait_lock>
    800026cc:	ffffe097          	auipc	ra,0xffffe
    800026d0:	5d2080e7          	jalr	1490(ra) # 80000c9e <release>
						return -1;
    800026d4:	59fd                	li	s3,-1
    800026d6:	a889                	j	80002728 <wait+0x10c>
		for (pp = proc; pp < &proc[NPROC]; pp++)
    800026d8:	1d048493          	addi	s1,s1,464
    800026dc:	03348663          	beq	s1,s3,80002708 <wait+0xec>
			if (pp->parent == p)
    800026e0:	60bc                	ld	a5,64(s1)
    800026e2:	ff279be3          	bne	a5,s2,800026d8 <wait+0xbc>
				acquire(&pp->lock);
    800026e6:	00848a13          	addi	s4,s1,8
    800026ea:	8552                	mv	a0,s4
    800026ec:	ffffe097          	auipc	ra,0xffffe
    800026f0:	4fe080e7          	jalr	1278(ra) # 80000bea <acquire>
				if (pp->state == ZOMBIE)
    800026f4:	509c                	lw	a5,32(s1)
    800026f6:	f7578fe3          	beq	a5,s5,80002674 <wait+0x58>
				release(&pp->lock);
    800026fa:	8552                	mv	a0,s4
    800026fc:	ffffe097          	auipc	ra,0xffffe
    80002700:	5a2080e7          	jalr	1442(ra) # 80000c9e <release>
				havekids = 1;
    80002704:	875a                	mv	a4,s6
    80002706:	bfc9                	j	800026d8 <wait+0xbc>
		if (!havekids || killed(p))
    80002708:	c719                	beqz	a4,80002716 <wait+0xfa>
    8000270a:	854a                	mv	a0,s2
    8000270c:	00000097          	auipc	ra,0x0
    80002710:	eda080e7          	jalr	-294(ra) # 800025e6 <killed>
    80002714:	c905                	beqz	a0,80002744 <wait+0x128>
			release(&wait_lock);
    80002716:	0000e517          	auipc	a0,0xe
    8000271a:	74250513          	addi	a0,a0,1858 # 80010e58 <wait_lock>
    8000271e:	ffffe097          	auipc	ra,0xffffe
    80002722:	580080e7          	jalr	1408(ra) # 80000c9e <release>
			return -1;
    80002726:	59fd                	li	s3,-1
}
    80002728:	854e                	mv	a0,s3
    8000272a:	60e6                	ld	ra,88(sp)
    8000272c:	6446                	ld	s0,80(sp)
    8000272e:	64a6                	ld	s1,72(sp)
    80002730:	6906                	ld	s2,64(sp)
    80002732:	79e2                	ld	s3,56(sp)
    80002734:	7a42                	ld	s4,48(sp)
    80002736:	7aa2                	ld	s5,40(sp)
    80002738:	7b02                	ld	s6,32(sp)
    8000273a:	6be2                	ld	s7,24(sp)
    8000273c:	6c42                	ld	s8,16(sp)
    8000273e:	6ca2                	ld	s9,8(sp)
    80002740:	6125                	addi	sp,sp,96
    80002742:	8082                	ret
		sleep(p, &wait_lock); // DOC: wait-sleep
    80002744:	85e6                	mv	a1,s9
    80002746:	854a                	mv	a0,s2
    80002748:	00000097          	auipc	ra,0x0
    8000274c:	aa0080e7          	jalr	-1376(ra) # 800021e8 <sleep>
		havekids = 0;
    80002750:	bf21                	j	80002668 <wait+0x4c>

0000000080002752 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002752:	7179                	addi	sp,sp,-48
    80002754:	f406                	sd	ra,40(sp)
    80002756:	f022                	sd	s0,32(sp)
    80002758:	ec26                	sd	s1,24(sp)
    8000275a:	e84a                	sd	s2,16(sp)
    8000275c:	e44e                	sd	s3,8(sp)
    8000275e:	e052                	sd	s4,0(sp)
    80002760:	1800                	addi	s0,sp,48
    80002762:	84aa                	mv	s1,a0
    80002764:	892e                	mv	s2,a1
    80002766:	89b2                	mv	s3,a2
    80002768:	8a36                	mv	s4,a3
	struct proc *p = myproc();
    8000276a:	fffff097          	auipc	ra,0xfffff
    8000276e:	366080e7          	jalr	870(ra) # 80001ad0 <myproc>
	if (user_dst)
    80002772:	c08d                	beqz	s1,80002794 <either_copyout+0x42>
	{
		return copyout(p->pagetable, dst, src, len);
    80002774:	86d2                	mv	a3,s4
    80002776:	864e                	mv	a2,s3
    80002778:	85ca                	mv	a1,s2
    8000277a:	6d28                	ld	a0,88(a0)
    8000277c:	fffff097          	auipc	ra,0xfffff
    80002780:	f08080e7          	jalr	-248(ra) # 80001684 <copyout>
	else
	{
		memmove((char *)dst, src, len);
		return 0;
	}
}
    80002784:	70a2                	ld	ra,40(sp)
    80002786:	7402                	ld	s0,32(sp)
    80002788:	64e2                	ld	s1,24(sp)
    8000278a:	6942                	ld	s2,16(sp)
    8000278c:	69a2                	ld	s3,8(sp)
    8000278e:	6a02                	ld	s4,0(sp)
    80002790:	6145                	addi	sp,sp,48
    80002792:	8082                	ret
		memmove((char *)dst, src, len);
    80002794:	000a061b          	sext.w	a2,s4
    80002798:	85ce                	mv	a1,s3
    8000279a:	854a                	mv	a0,s2
    8000279c:	ffffe097          	auipc	ra,0xffffe
    800027a0:	5aa080e7          	jalr	1450(ra) # 80000d46 <memmove>
		return 0;
    800027a4:	8526                	mv	a0,s1
    800027a6:	bff9                	j	80002784 <either_copyout+0x32>

00000000800027a8 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800027a8:	7179                	addi	sp,sp,-48
    800027aa:	f406                	sd	ra,40(sp)
    800027ac:	f022                	sd	s0,32(sp)
    800027ae:	ec26                	sd	s1,24(sp)
    800027b0:	e84a                	sd	s2,16(sp)
    800027b2:	e44e                	sd	s3,8(sp)
    800027b4:	e052                	sd	s4,0(sp)
    800027b6:	1800                	addi	s0,sp,48
    800027b8:	892a                	mv	s2,a0
    800027ba:	84ae                	mv	s1,a1
    800027bc:	89b2                	mv	s3,a2
    800027be:	8a36                	mv	s4,a3
	struct proc *p = myproc();
    800027c0:	fffff097          	auipc	ra,0xfffff
    800027c4:	310080e7          	jalr	784(ra) # 80001ad0 <myproc>
	if (user_src)
    800027c8:	c08d                	beqz	s1,800027ea <either_copyin+0x42>
	{
		return copyin(p->pagetable, dst, src, len);
    800027ca:	86d2                	mv	a3,s4
    800027cc:	864e                	mv	a2,s3
    800027ce:	85ca                	mv	a1,s2
    800027d0:	6d28                	ld	a0,88(a0)
    800027d2:	fffff097          	auipc	ra,0xfffff
    800027d6:	f3e080e7          	jalr	-194(ra) # 80001710 <copyin>
	else
	{
		memmove(dst, (char *)src, len);
		return 0;
	}
}
    800027da:	70a2                	ld	ra,40(sp)
    800027dc:	7402                	ld	s0,32(sp)
    800027de:	64e2                	ld	s1,24(sp)
    800027e0:	6942                	ld	s2,16(sp)
    800027e2:	69a2                	ld	s3,8(sp)
    800027e4:	6a02                	ld	s4,0(sp)
    800027e6:	6145                	addi	sp,sp,48
    800027e8:	8082                	ret
		memmove(dst, (char *)src, len);
    800027ea:	000a061b          	sext.w	a2,s4
    800027ee:	85ce                	mv	a1,s3
    800027f0:	854a                	mv	a0,s2
    800027f2:	ffffe097          	auipc	ra,0xffffe
    800027f6:	554080e7          	jalr	1364(ra) # 80000d46 <memmove>
		return 0;
    800027fa:	8526                	mv	a0,s1
    800027fc:	bff9                	j	800027da <either_copyin+0x32>

00000000800027fe <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    800027fe:	715d                	addi	sp,sp,-80
    80002800:	e486                	sd	ra,72(sp)
    80002802:	e0a2                	sd	s0,64(sp)
    80002804:	fc26                	sd	s1,56(sp)
    80002806:	f84a                	sd	s2,48(sp)
    80002808:	f44e                	sd	s3,40(sp)
    8000280a:	f052                	sd	s4,32(sp)
    8000280c:	ec56                	sd	s5,24(sp)
    8000280e:	e85a                	sd	s6,16(sp)
    80002810:	e45e                	sd	s7,8(sp)
    80002812:	0880                	addi	s0,sp,80
		[RUNNING] "run   ",
		[ZOMBIE] "zombie"};
	struct proc *p;
	char *state;

	printf("\n");
    80002814:	00006517          	auipc	a0,0x6
    80002818:	8b450513          	addi	a0,a0,-1868 # 800080c8 <digits+0x88>
    8000281c:	ffffe097          	auipc	ra,0xffffe
    80002820:	d72080e7          	jalr	-654(ra) # 8000058e <printf>
	for (p = proc; p < &proc[NPROC]; p++)
    80002824:	0000f497          	auipc	s1,0xf
    80002828:	bac48493          	addi	s1,s1,-1108 # 800113d0 <proc+0x160>
    8000282c:	00016917          	auipc	s2,0x16
    80002830:	fa490913          	addi	s2,s2,-92 # 800187d0 <bcache+0x148>
	{
		if (p->state == UNUSED)
			continue;
		if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002834:	4b15                	li	s6,5
			state = states[p->state];
		else
			state = "???";
    80002836:	00006997          	auipc	s3,0x6
    8000283a:	a6298993          	addi	s3,s3,-1438 # 80008298 <digits+0x258>
		printf("%d %s %s %d %d", p->pid, state, p->name, p->runTime, p->countTimeCalled);
    8000283e:	00006a97          	auipc	s5,0x6
    80002842:	a62a8a93          	addi	s5,s5,-1438 # 800082a0 <digits+0x260>
		printf("\n");
    80002846:	00006a17          	auipc	s4,0x6
    8000284a:	882a0a13          	addi	s4,s4,-1918 # 800080c8 <digits+0x88>
		if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000284e:	00006b97          	auipc	s7,0x6
    80002852:	a92b8b93          	addi	s7,s7,-1390 # 800082e0 <states.2493>
    80002856:	a01d                	j	8000287c <procdump+0x7e>
		printf("%d %s %s %d %d", p->pid, state, p->name, p->runTime, p->countTimeCalled);
    80002858:	5e9c                	lw	a5,56(a3)
    8000285a:	5298                	lw	a4,32(a3)
    8000285c:	ed86a583          	lw	a1,-296(a3)
    80002860:	8556                	mv	a0,s5
    80002862:	ffffe097          	auipc	ra,0xffffe
    80002866:	d2c080e7          	jalr	-724(ra) # 8000058e <printf>
		printf("\n");
    8000286a:	8552                	mv	a0,s4
    8000286c:	ffffe097          	auipc	ra,0xffffe
    80002870:	d22080e7          	jalr	-734(ra) # 8000058e <printf>
	for (p = proc; p < &proc[NPROC]; p++)
    80002874:	1d048493          	addi	s1,s1,464
    80002878:	03248163          	beq	s1,s2,8000289a <procdump+0x9c>
		if (p->state == UNUSED)
    8000287c:	86a6                	mv	a3,s1
    8000287e:	ec04a783          	lw	a5,-320(s1)
    80002882:	dbed                	beqz	a5,80002874 <procdump+0x76>
			state = "???";
    80002884:	864e                	mv	a2,s3
		if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002886:	fcfb69e3          	bltu	s6,a5,80002858 <procdump+0x5a>
    8000288a:	1782                	slli	a5,a5,0x20
    8000288c:	9381                	srli	a5,a5,0x20
    8000288e:	078e                	slli	a5,a5,0x3
    80002890:	97de                	add	a5,a5,s7
    80002892:	6390                	ld	a2,0(a5)
    80002894:	f271                	bnez	a2,80002858 <procdump+0x5a>
			state = "???";
    80002896:	864e                	mv	a2,s3
    80002898:	b7c1                	j	80002858 <procdump+0x5a>
	}
}
    8000289a:	60a6                	ld	ra,72(sp)
    8000289c:	6406                	ld	s0,64(sp)
    8000289e:	74e2                	ld	s1,56(sp)
    800028a0:	7942                	ld	s2,48(sp)
    800028a2:	79a2                	ld	s3,40(sp)
    800028a4:	7a02                	ld	s4,32(sp)
    800028a6:	6ae2                	ld	s5,24(sp)
    800028a8:	6b42                	ld	s6,16(sp)
    800028aa:	6ba2                	ld	s7,8(sp)
    800028ac:	6161                	addi	sp,sp,80
    800028ae:	8082                	ret

00000000800028b0 <swtch>:
    800028b0:	00153023          	sd	ra,0(a0)
    800028b4:	00253423          	sd	sp,8(a0)
    800028b8:	e900                	sd	s0,16(a0)
    800028ba:	ed04                	sd	s1,24(a0)
    800028bc:	03253023          	sd	s2,32(a0)
    800028c0:	03353423          	sd	s3,40(a0)
    800028c4:	03453823          	sd	s4,48(a0)
    800028c8:	03553c23          	sd	s5,56(a0)
    800028cc:	05653023          	sd	s6,64(a0)
    800028d0:	05753423          	sd	s7,72(a0)
    800028d4:	05853823          	sd	s8,80(a0)
    800028d8:	05953c23          	sd	s9,88(a0)
    800028dc:	07a53023          	sd	s10,96(a0)
    800028e0:	07b53423          	sd	s11,104(a0)
    800028e4:	0005b083          	ld	ra,0(a1)
    800028e8:	0085b103          	ld	sp,8(a1)
    800028ec:	6980                	ld	s0,16(a1)
    800028ee:	6d84                	ld	s1,24(a1)
    800028f0:	0205b903          	ld	s2,32(a1)
    800028f4:	0285b983          	ld	s3,40(a1)
    800028f8:	0305ba03          	ld	s4,48(a1)
    800028fc:	0385ba83          	ld	s5,56(a1)
    80002900:	0405bb03          	ld	s6,64(a1)
    80002904:	0485bb83          	ld	s7,72(a1)
    80002908:	0505bc03          	ld	s8,80(a1)
    8000290c:	0585bc83          	ld	s9,88(a1)
    80002910:	0605bd03          	ld	s10,96(a1)
    80002914:	0685bd83          	ld	s11,104(a1)
    80002918:	8082                	ret

000000008000291a <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    8000291a:	1141                	addi	sp,sp,-16
    8000291c:	e406                	sd	ra,8(sp)
    8000291e:	e022                	sd	s0,0(sp)
    80002920:	0800                	addi	s0,sp,16
	initlock(&tickslock, "time");
    80002922:	00006597          	auipc	a1,0x6
    80002926:	9ee58593          	addi	a1,a1,-1554 # 80008310 <states.2493+0x30>
    8000292a:	00016517          	auipc	a0,0x16
    8000292e:	d4650513          	addi	a0,a0,-698 # 80018670 <tickslock>
    80002932:	ffffe097          	auipc	ra,0xffffe
    80002936:	228080e7          	jalr	552(ra) # 80000b5a <initlock>
}
    8000293a:	60a2                	ld	ra,8(sp)
    8000293c:	6402                	ld	s0,0(sp)
    8000293e:	0141                	addi	sp,sp,16
    80002940:	8082                	ret

0000000080002942 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002942:	1141                	addi	sp,sp,-16
    80002944:	e422                	sd	s0,8(sp)
    80002946:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002948:	00003797          	auipc	a5,0x3
    8000294c:	76878793          	addi	a5,a5,1896 # 800060b0 <kernelvec>
    80002950:	10579073          	csrw	stvec,a5
	w_stvec((uint64)kernelvec);
}
    80002954:	6422                	ld	s0,8(sp)
    80002956:	0141                	addi	sp,sp,16
    80002958:	8082                	ret

000000008000295a <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    8000295a:	1141                	addi	sp,sp,-16
    8000295c:	e406                	sd	ra,8(sp)
    8000295e:	e022                	sd	s0,0(sp)
    80002960:	0800                	addi	s0,sp,16
	struct proc *p = myproc();
    80002962:	fffff097          	auipc	ra,0xfffff
    80002966:	16e080e7          	jalr	366(ra) # 80001ad0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000296a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000296e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002970:	10079073          	csrw	sstatus,a5
	// kerneltrap() to usertrap(), so turn off interrupts until
	// we're back in user space, where usertrap() is correct.
	intr_off();

	// send syscalls, interrupts, and exceptions to uservec in trampoline.S
	uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002974:	00004617          	auipc	a2,0x4
    80002978:	68c60613          	addi	a2,a2,1676 # 80007000 <_trampoline>
    8000297c:	00004697          	auipc	a3,0x4
    80002980:	68468693          	addi	a3,a3,1668 # 80007000 <_trampoline>
    80002984:	8e91                	sub	a3,a3,a2
    80002986:	040007b7          	lui	a5,0x4000
    8000298a:	17fd                	addi	a5,a5,-1
    8000298c:	07b2                	slli	a5,a5,0xc
    8000298e:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002990:	10569073          	csrw	stvec,a3
	w_stvec(trampoline_uservec);

	// set up trapframe values that uservec will need when
	// the process next traps into the kernel.
	p->trapframe->kernel_satp = r_satp();		  // kernel page table
    80002994:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002996:	180026f3          	csrr	a3,satp
    8000299a:	e314                	sd	a3,0(a4)
	p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000299c:	7138                	ld	a4,96(a0)
    8000299e:	6534                	ld	a3,72(a0)
    800029a0:	6585                	lui	a1,0x1
    800029a2:	96ae                	add	a3,a3,a1
    800029a4:	e714                	sd	a3,8(a4)
	p->trapframe->kernel_trap = (uint64)usertrap;
    800029a6:	7138                	ld	a4,96(a0)
    800029a8:	00000697          	auipc	a3,0x0
    800029ac:	13e68693          	addi	a3,a3,318 # 80002ae6 <usertrap>
    800029b0:	eb14                	sd	a3,16(a4)
	p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    800029b2:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800029b4:	8692                	mv	a3,tp
    800029b6:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029b8:	100026f3          	csrr	a3,sstatus
	// set up the registers that trampoline.S's sret will use
	// to get to user space.

	// set S Previous Privilege mode to User.
	unsigned long x = r_sstatus();
	x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800029bc:	eff6f693          	andi	a3,a3,-257
	x |= SSTATUS_SPIE; // enable interrupts in user mode
    800029c0:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029c4:	10069073          	csrw	sstatus,a3
	w_sstatus(x);

	// set S Exception Program Counter to the saved user pc.
	w_sepc(p->trapframe->epc);
    800029c8:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029ca:	6f18                	ld	a4,24(a4)
    800029cc:	14171073          	csrw	sepc,a4

	// tell trampoline.S the user page table to switch to.
	uint64 satp = MAKE_SATP(p->pagetable);
    800029d0:	6d28                	ld	a0,88(a0)
    800029d2:	8131                	srli	a0,a0,0xc

	// jump to userret in trampoline.S at the top of memory, which
	// switches to the user page table, restores user registers,
	// and switches to user mode with sret.
	uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800029d4:	00004717          	auipc	a4,0x4
    800029d8:	6c870713          	addi	a4,a4,1736 # 8000709c <userret>
    800029dc:	8f11                	sub	a4,a4,a2
    800029de:	97ba                	add	a5,a5,a4
	((void (*)(uint64))trampoline_userret)(satp);
    800029e0:	577d                	li	a4,-1
    800029e2:	177e                	slli	a4,a4,0x3f
    800029e4:	8d59                	or	a0,a0,a4
    800029e6:	9782                	jalr	a5
}
    800029e8:	60a2                	ld	ra,8(sp)
    800029ea:	6402                	ld	s0,0(sp)
    800029ec:	0141                	addi	sp,sp,16
    800029ee:	8082                	ret

00000000800029f0 <clockintr>:
	w_sepc(sepc);
	w_sstatus(sstatus);
}

void clockintr()
{
    800029f0:	1101                	addi	sp,sp,-32
    800029f2:	ec06                	sd	ra,24(sp)
    800029f4:	e822                	sd	s0,16(sp)
    800029f6:	e426                	sd	s1,8(sp)
    800029f8:	e04a                	sd	s2,0(sp)
    800029fa:	1000                	addi	s0,sp,32
	acquire(&tickslock);
    800029fc:	00016917          	auipc	s2,0x16
    80002a00:	c7490913          	addi	s2,s2,-908 # 80018670 <tickslock>
    80002a04:	854a                	mv	a0,s2
    80002a06:	ffffe097          	auipc	ra,0xffffe
    80002a0a:	1e4080e7          	jalr	484(ra) # 80000bea <acquire>
	ticks++;
    80002a0e:	00006497          	auipc	s1,0x6
    80002a12:	1c248493          	addi	s1,s1,450 # 80008bd0 <ticks>
    80002a16:	409c                	lw	a5,0(s1)
    80002a18:	2785                	addiw	a5,a5,1
    80002a1a:	c09c                	sw	a5,0(s1)
	upd_time();
    80002a1c:	fffff097          	auipc	ra,0xfffff
    80002a20:	5c4080e7          	jalr	1476(ra) # 80001fe0 <upd_time>
	wakeup(&ticks);
    80002a24:	8526                	mv	a0,s1
    80002a26:	00000097          	auipc	ra,0x0
    80002a2a:	960080e7          	jalr	-1696(ra) # 80002386 <wakeup>
	release(&tickslock);
    80002a2e:	854a                	mv	a0,s2
    80002a30:	ffffe097          	auipc	ra,0xffffe
    80002a34:	26e080e7          	jalr	622(ra) # 80000c9e <release>
}
    80002a38:	60e2                	ld	ra,24(sp)
    80002a3a:	6442                	ld	s0,16(sp)
    80002a3c:	64a2                	ld	s1,8(sp)
    80002a3e:	6902                	ld	s2,0(sp)
    80002a40:	6105                	addi	sp,sp,32
    80002a42:	8082                	ret

0000000080002a44 <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    80002a44:	1101                	addi	sp,sp,-32
    80002a46:	ec06                	sd	ra,24(sp)
    80002a48:	e822                	sd	s0,16(sp)
    80002a4a:	e426                	sd	s1,8(sp)
    80002a4c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a4e:	14202773          	csrr	a4,scause
	uint64 scause = r_scause();

	if ((scause & 0x8000000000000000L) &&
    80002a52:	00074d63          	bltz	a4,80002a6c <devintr+0x28>
		if (irq)
			plic_complete(irq);

		return 1;
	}
	else if (scause == 0x8000000000000001L)
    80002a56:	57fd                	li	a5,-1
    80002a58:	17fe                	slli	a5,a5,0x3f
    80002a5a:	0785                	addi	a5,a5,1

		return 2;
	}
	else
	{
		return 0;
    80002a5c:	4501                	li	a0,0
	else if (scause == 0x8000000000000001L)
    80002a5e:	06f70363          	beq	a4,a5,80002ac4 <devintr+0x80>
	}
}
    80002a62:	60e2                	ld	ra,24(sp)
    80002a64:	6442                	ld	s0,16(sp)
    80002a66:	64a2                	ld	s1,8(sp)
    80002a68:	6105                	addi	sp,sp,32
    80002a6a:	8082                	ret
		(scause & 0xff) == 9)
    80002a6c:	0ff77793          	andi	a5,a4,255
	if ((scause & 0x8000000000000000L) &&
    80002a70:	46a5                	li	a3,9
    80002a72:	fed792e3          	bne	a5,a3,80002a56 <devintr+0x12>
		int irq = plic_claim();
    80002a76:	00003097          	auipc	ra,0x3
    80002a7a:	742080e7          	jalr	1858(ra) # 800061b8 <plic_claim>
    80002a7e:	84aa                	mv	s1,a0
		if (irq == UART0_IRQ)
    80002a80:	47a9                	li	a5,10
    80002a82:	02f50763          	beq	a0,a5,80002ab0 <devintr+0x6c>
		else if (irq == VIRTIO0_IRQ)
    80002a86:	4785                	li	a5,1
    80002a88:	02f50963          	beq	a0,a5,80002aba <devintr+0x76>
		return 1;
    80002a8c:	4505                	li	a0,1
		else if (irq)
    80002a8e:	d8f1                	beqz	s1,80002a62 <devintr+0x1e>
			printf("unexpected interrupt irq=%d\n", irq);
    80002a90:	85a6                	mv	a1,s1
    80002a92:	00006517          	auipc	a0,0x6
    80002a96:	88650513          	addi	a0,a0,-1914 # 80008318 <states.2493+0x38>
    80002a9a:	ffffe097          	auipc	ra,0xffffe
    80002a9e:	af4080e7          	jalr	-1292(ra) # 8000058e <printf>
			plic_complete(irq);
    80002aa2:	8526                	mv	a0,s1
    80002aa4:	00003097          	auipc	ra,0x3
    80002aa8:	738080e7          	jalr	1848(ra) # 800061dc <plic_complete>
		return 1;
    80002aac:	4505                	li	a0,1
    80002aae:	bf55                	j	80002a62 <devintr+0x1e>
			uartintr();
    80002ab0:	ffffe097          	auipc	ra,0xffffe
    80002ab4:	efe080e7          	jalr	-258(ra) # 800009ae <uartintr>
    80002ab8:	b7ed                	j	80002aa2 <devintr+0x5e>
			virtio_disk_intr();
    80002aba:	00004097          	auipc	ra,0x4
    80002abe:	c4c080e7          	jalr	-948(ra) # 80006706 <virtio_disk_intr>
    80002ac2:	b7c5                	j	80002aa2 <devintr+0x5e>
		if (cpuid() == 0)
    80002ac4:	fffff097          	auipc	ra,0xfffff
    80002ac8:	fe0080e7          	jalr	-32(ra) # 80001aa4 <cpuid>
    80002acc:	c901                	beqz	a0,80002adc <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002ace:	144027f3          	csrr	a5,sip
		w_sip(r_sip() & ~2);
    80002ad2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002ad4:	14479073          	csrw	sip,a5
		return 2;
    80002ad8:	4509                	li	a0,2
    80002ada:	b761                	j	80002a62 <devintr+0x1e>
			clockintr();
    80002adc:	00000097          	auipc	ra,0x0
    80002ae0:	f14080e7          	jalr	-236(ra) # 800029f0 <clockintr>
    80002ae4:	b7ed                	j	80002ace <devintr+0x8a>

0000000080002ae6 <usertrap>:
{
    80002ae6:	1101                	addi	sp,sp,-32
    80002ae8:	ec06                	sd	ra,24(sp)
    80002aea:	e822                	sd	s0,16(sp)
    80002aec:	e426                	sd	s1,8(sp)
    80002aee:	e04a                	sd	s2,0(sp)
    80002af0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002af2:	100027f3          	csrr	a5,sstatus
	if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002af6:	1007f793          	andi	a5,a5,256
    80002afa:	e3b1                	bnez	a5,80002b3e <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002afc:	00003797          	auipc	a5,0x3
    80002b00:	5b478793          	addi	a5,a5,1460 # 800060b0 <kernelvec>
    80002b04:	10579073          	csrw	stvec,a5
	struct proc *p = myproc();
    80002b08:	fffff097          	auipc	ra,0xfffff
    80002b0c:	fc8080e7          	jalr	-56(ra) # 80001ad0 <myproc>
    80002b10:	84aa                	mv	s1,a0
	p->trapframe->epc = r_sepc();
    80002b12:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b14:	14102773          	csrr	a4,sepc
    80002b18:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b1a:	14202773          	csrr	a4,scause
	if (r_scause() == 8)
    80002b1e:	47a1                	li	a5,8
    80002b20:	02f70763          	beq	a4,a5,80002b4e <usertrap+0x68>
	else if ((which_dev = devintr()) != 0)
    80002b24:	00000097          	auipc	ra,0x0
    80002b28:	f20080e7          	jalr	-224(ra) # 80002a44 <devintr>
    80002b2c:	892a                	mv	s2,a0
    80002b2e:	c151                	beqz	a0,80002bb2 <usertrap+0xcc>
	if (killed(p))
    80002b30:	8526                	mv	a0,s1
    80002b32:	00000097          	auipc	ra,0x0
    80002b36:	ab4080e7          	jalr	-1356(ra) # 800025e6 <killed>
    80002b3a:	c929                	beqz	a0,80002b8c <usertrap+0xa6>
    80002b3c:	a099                	j	80002b82 <usertrap+0x9c>
		panic("usertrap: not from user mode");
    80002b3e:	00005517          	auipc	a0,0x5
    80002b42:	7fa50513          	addi	a0,a0,2042 # 80008338 <states.2493+0x58>
    80002b46:	ffffe097          	auipc	ra,0xffffe
    80002b4a:	9fe080e7          	jalr	-1538(ra) # 80000544 <panic>
		if (killed(p))
    80002b4e:	00000097          	auipc	ra,0x0
    80002b52:	a98080e7          	jalr	-1384(ra) # 800025e6 <killed>
    80002b56:	e921                	bnez	a0,80002ba6 <usertrap+0xc0>
		p->trapframe->epc += 4;
    80002b58:	70b8                	ld	a4,96(s1)
    80002b5a:	6f1c                	ld	a5,24(a4)
    80002b5c:	0791                	addi	a5,a5,4
    80002b5e:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b60:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b64:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b68:	10079073          	csrw	sstatus,a5
		syscall();
    80002b6c:	00000097          	auipc	ra,0x0
    80002b70:	2d4080e7          	jalr	724(ra) # 80002e40 <syscall>
	if (killed(p))
    80002b74:	8526                	mv	a0,s1
    80002b76:	00000097          	auipc	ra,0x0
    80002b7a:	a70080e7          	jalr	-1424(ra) # 800025e6 <killed>
    80002b7e:	c911                	beqz	a0,80002b92 <usertrap+0xac>
    80002b80:	4901                	li	s2,0
		exit(-1);
    80002b82:	557d                	li	a0,-1
    80002b84:	00000097          	auipc	ra,0x0
    80002b88:	8da080e7          	jalr	-1830(ra) # 8000245e <exit>
	if (which_dev == 2)
    80002b8c:	4789                	li	a5,2
    80002b8e:	04f90f63          	beq	s2,a5,80002bec <usertrap+0x106>
	usertrapret();
    80002b92:	00000097          	auipc	ra,0x0
    80002b96:	dc8080e7          	jalr	-568(ra) # 8000295a <usertrapret>
}
    80002b9a:	60e2                	ld	ra,24(sp)
    80002b9c:	6442                	ld	s0,16(sp)
    80002b9e:	64a2                	ld	s1,8(sp)
    80002ba0:	6902                	ld	s2,0(sp)
    80002ba2:	6105                	addi	sp,sp,32
    80002ba4:	8082                	ret
			exit(-1);
    80002ba6:	557d                	li	a0,-1
    80002ba8:	00000097          	auipc	ra,0x0
    80002bac:	8b6080e7          	jalr	-1866(ra) # 8000245e <exit>
    80002bb0:	b765                	j	80002b58 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bb2:	142025f3          	csrr	a1,scause
		printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002bb6:	5c90                	lw	a2,56(s1)
    80002bb8:	00005517          	auipc	a0,0x5
    80002bbc:	7a050513          	addi	a0,a0,1952 # 80008358 <states.2493+0x78>
    80002bc0:	ffffe097          	auipc	ra,0xffffe
    80002bc4:	9ce080e7          	jalr	-1586(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bc8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002bcc:	14302673          	csrr	a2,stval
		printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002bd0:	00005517          	auipc	a0,0x5
    80002bd4:	7b850513          	addi	a0,a0,1976 # 80008388 <states.2493+0xa8>
    80002bd8:	ffffe097          	auipc	ra,0xffffe
    80002bdc:	9b6080e7          	jalr	-1610(ra) # 8000058e <printf>
		setkilled(p);
    80002be0:	8526                	mv	a0,s1
    80002be2:	00000097          	auipc	ra,0x0
    80002be6:	9ce080e7          	jalr	-1586(ra) # 800025b0 <setkilled>
    80002bea:	b769                	j	80002b74 <usertrap+0x8e>
		yield();
    80002bec:	fffff097          	auipc	ra,0xfffff
    80002bf0:	5b6080e7          	jalr	1462(ra) # 800021a2 <yield>
    80002bf4:	bf79                	j	80002b92 <usertrap+0xac>

0000000080002bf6 <kerneltrap>:
{
    80002bf6:	7179                	addi	sp,sp,-48
    80002bf8:	f406                	sd	ra,40(sp)
    80002bfa:	f022                	sd	s0,32(sp)
    80002bfc:	ec26                	sd	s1,24(sp)
    80002bfe:	e84a                	sd	s2,16(sp)
    80002c00:	e44e                	sd	s3,8(sp)
    80002c02:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c04:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c08:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c0c:	142029f3          	csrr	s3,scause
	if ((sstatus & SSTATUS_SPP) == 0)
    80002c10:	1004f793          	andi	a5,s1,256
    80002c14:	cb85                	beqz	a5,80002c44 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c16:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c1a:	8b89                	andi	a5,a5,2
	if (intr_get() != 0)
    80002c1c:	ef85                	bnez	a5,80002c54 <kerneltrap+0x5e>
	if ((which_dev = devintr()) == 0)
    80002c1e:	00000097          	auipc	ra,0x0
    80002c22:	e26080e7          	jalr	-474(ra) # 80002a44 <devintr>
    80002c26:	cd1d                	beqz	a0,80002c64 <kerneltrap+0x6e>
	if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c28:	4789                	li	a5,2
    80002c2a:	06f50a63          	beq	a0,a5,80002c9e <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c2e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c32:	10049073          	csrw	sstatus,s1
}
    80002c36:	70a2                	ld	ra,40(sp)
    80002c38:	7402                	ld	s0,32(sp)
    80002c3a:	64e2                	ld	s1,24(sp)
    80002c3c:	6942                	ld	s2,16(sp)
    80002c3e:	69a2                	ld	s3,8(sp)
    80002c40:	6145                	addi	sp,sp,48
    80002c42:	8082                	ret
		panic("kerneltrap: not from supervisor mode");
    80002c44:	00005517          	auipc	a0,0x5
    80002c48:	76450513          	addi	a0,a0,1892 # 800083a8 <states.2493+0xc8>
    80002c4c:	ffffe097          	auipc	ra,0xffffe
    80002c50:	8f8080e7          	jalr	-1800(ra) # 80000544 <panic>
		panic("kerneltrap: interrupts enabled");
    80002c54:	00005517          	auipc	a0,0x5
    80002c58:	77c50513          	addi	a0,a0,1916 # 800083d0 <states.2493+0xf0>
    80002c5c:	ffffe097          	auipc	ra,0xffffe
    80002c60:	8e8080e7          	jalr	-1816(ra) # 80000544 <panic>
		printf("scause %p\n", scause);
    80002c64:	85ce                	mv	a1,s3
    80002c66:	00005517          	auipc	a0,0x5
    80002c6a:	78a50513          	addi	a0,a0,1930 # 800083f0 <states.2493+0x110>
    80002c6e:	ffffe097          	auipc	ra,0xffffe
    80002c72:	920080e7          	jalr	-1760(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c76:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c7a:	14302673          	csrr	a2,stval
		printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c7e:	00005517          	auipc	a0,0x5
    80002c82:	78250513          	addi	a0,a0,1922 # 80008400 <states.2493+0x120>
    80002c86:	ffffe097          	auipc	ra,0xffffe
    80002c8a:	908080e7          	jalr	-1784(ra) # 8000058e <printf>
		panic("kerneltrap");
    80002c8e:	00005517          	auipc	a0,0x5
    80002c92:	78a50513          	addi	a0,a0,1930 # 80008418 <states.2493+0x138>
    80002c96:	ffffe097          	auipc	ra,0xffffe
    80002c9a:	8ae080e7          	jalr	-1874(ra) # 80000544 <panic>
	if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c9e:	fffff097          	auipc	ra,0xfffff
    80002ca2:	e32080e7          	jalr	-462(ra) # 80001ad0 <myproc>
    80002ca6:	d541                	beqz	a0,80002c2e <kerneltrap+0x38>
    80002ca8:	fffff097          	auipc	ra,0xfffff
    80002cac:	e28080e7          	jalr	-472(ra) # 80001ad0 <myproc>
    80002cb0:	5118                	lw	a4,32(a0)
    80002cb2:	4791                	li	a5,4
    80002cb4:	f6f71de3          	bne	a4,a5,80002c2e <kerneltrap+0x38>
		yield();
    80002cb8:	fffff097          	auipc	ra,0xfffff
    80002cbc:	4ea080e7          	jalr	1258(ra) # 800021a2 <yield>
    80002cc0:	b7bd                	j	80002c2e <kerneltrap+0x38>

0000000080002cc2 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002cc2:	1101                	addi	sp,sp,-32
    80002cc4:	ec06                	sd	ra,24(sp)
    80002cc6:	e822                	sd	s0,16(sp)
    80002cc8:	e426                	sd	s1,8(sp)
    80002cca:	1000                	addi	s0,sp,32
    80002ccc:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002cce:	fffff097          	auipc	ra,0xfffff
    80002cd2:	e02080e7          	jalr	-510(ra) # 80001ad0 <myproc>
  switch (n)
    80002cd6:	4795                	li	a5,5
    80002cd8:	0497e163          	bltu	a5,s1,80002d1a <argraw+0x58>
    80002cdc:	048a                	slli	s1,s1,0x2
    80002cde:	00006717          	auipc	a4,0x6
    80002ce2:	88270713          	addi	a4,a4,-1918 # 80008560 <states.2493+0x280>
    80002ce6:	94ba                	add	s1,s1,a4
    80002ce8:	409c                	lw	a5,0(s1)
    80002cea:	97ba                	add	a5,a5,a4
    80002cec:	8782                	jr	a5
  {
  case 0:
    return p->trapframe->a0;
    80002cee:	713c                	ld	a5,96(a0)
    80002cf0:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002cf2:	60e2                	ld	ra,24(sp)
    80002cf4:	6442                	ld	s0,16(sp)
    80002cf6:	64a2                	ld	s1,8(sp)
    80002cf8:	6105                	addi	sp,sp,32
    80002cfa:	8082                	ret
    return p->trapframe->a1;
    80002cfc:	713c                	ld	a5,96(a0)
    80002cfe:	7fa8                	ld	a0,120(a5)
    80002d00:	bfcd                	j	80002cf2 <argraw+0x30>
    return p->trapframe->a2;
    80002d02:	713c                	ld	a5,96(a0)
    80002d04:	63c8                	ld	a0,128(a5)
    80002d06:	b7f5                	j	80002cf2 <argraw+0x30>
    return p->trapframe->a3;
    80002d08:	713c                	ld	a5,96(a0)
    80002d0a:	67c8                	ld	a0,136(a5)
    80002d0c:	b7dd                	j	80002cf2 <argraw+0x30>
    return p->trapframe->a4;
    80002d0e:	713c                	ld	a5,96(a0)
    80002d10:	6bc8                	ld	a0,144(a5)
    80002d12:	b7c5                	j	80002cf2 <argraw+0x30>
    return p->trapframe->a5;
    80002d14:	713c                	ld	a5,96(a0)
    80002d16:	6fc8                	ld	a0,152(a5)
    80002d18:	bfe9                	j	80002cf2 <argraw+0x30>
  panic("argraw");
    80002d1a:	00005517          	auipc	a0,0x5
    80002d1e:	70e50513          	addi	a0,a0,1806 # 80008428 <states.2493+0x148>
    80002d22:	ffffe097          	auipc	ra,0xffffe
    80002d26:	822080e7          	jalr	-2014(ra) # 80000544 <panic>

0000000080002d2a <fetchaddr>:
{
    80002d2a:	1101                	addi	sp,sp,-32
    80002d2c:	ec06                	sd	ra,24(sp)
    80002d2e:	e822                	sd	s0,16(sp)
    80002d30:	e426                	sd	s1,8(sp)
    80002d32:	e04a                	sd	s2,0(sp)
    80002d34:	1000                	addi	s0,sp,32
    80002d36:	84aa                	mv	s1,a0
    80002d38:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d3a:	fffff097          	auipc	ra,0xfffff
    80002d3e:	d96080e7          	jalr	-618(ra) # 80001ad0 <myproc>
  if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002d42:	693c                	ld	a5,80(a0)
    80002d44:	02f4f863          	bgeu	s1,a5,80002d74 <fetchaddr+0x4a>
    80002d48:	00848713          	addi	a4,s1,8
    80002d4c:	02e7e663          	bltu	a5,a4,80002d78 <fetchaddr+0x4e>
  if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d50:	46a1                	li	a3,8
    80002d52:	8626                	mv	a2,s1
    80002d54:	85ca                	mv	a1,s2
    80002d56:	6d28                	ld	a0,88(a0)
    80002d58:	fffff097          	auipc	ra,0xfffff
    80002d5c:	9b8080e7          	jalr	-1608(ra) # 80001710 <copyin>
    80002d60:	00a03533          	snez	a0,a0
    80002d64:	40a00533          	neg	a0,a0
}
    80002d68:	60e2                	ld	ra,24(sp)
    80002d6a:	6442                	ld	s0,16(sp)
    80002d6c:	64a2                	ld	s1,8(sp)
    80002d6e:	6902                	ld	s2,0(sp)
    80002d70:	6105                	addi	sp,sp,32
    80002d72:	8082                	ret
    return -1;
    80002d74:	557d                	li	a0,-1
    80002d76:	bfcd                	j	80002d68 <fetchaddr+0x3e>
    80002d78:	557d                	li	a0,-1
    80002d7a:	b7fd                	j	80002d68 <fetchaddr+0x3e>

0000000080002d7c <fetchstr>:
{
    80002d7c:	7179                	addi	sp,sp,-48
    80002d7e:	f406                	sd	ra,40(sp)
    80002d80:	f022                	sd	s0,32(sp)
    80002d82:	ec26                	sd	s1,24(sp)
    80002d84:	e84a                	sd	s2,16(sp)
    80002d86:	e44e                	sd	s3,8(sp)
    80002d88:	1800                	addi	s0,sp,48
    80002d8a:	892a                	mv	s2,a0
    80002d8c:	84ae                	mv	s1,a1
    80002d8e:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002d90:	fffff097          	auipc	ra,0xfffff
    80002d94:	d40080e7          	jalr	-704(ra) # 80001ad0 <myproc>
  if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80002d98:	86ce                	mv	a3,s3
    80002d9a:	864a                	mv	a2,s2
    80002d9c:	85a6                	mv	a1,s1
    80002d9e:	6d28                	ld	a0,88(a0)
    80002da0:	fffff097          	auipc	ra,0xfffff
    80002da4:	9fc080e7          	jalr	-1540(ra) # 8000179c <copyinstr>
    80002da8:	00054e63          	bltz	a0,80002dc4 <fetchstr+0x48>
  return strlen(buf);
    80002dac:	8526                	mv	a0,s1
    80002dae:	ffffe097          	auipc	ra,0xffffe
    80002db2:	0bc080e7          	jalr	188(ra) # 80000e6a <strlen>
}
    80002db6:	70a2                	ld	ra,40(sp)
    80002db8:	7402                	ld	s0,32(sp)
    80002dba:	64e2                	ld	s1,24(sp)
    80002dbc:	6942                	ld	s2,16(sp)
    80002dbe:	69a2                	ld	s3,8(sp)
    80002dc0:	6145                	addi	sp,sp,48
    80002dc2:	8082                	ret
    return -1;
    80002dc4:	557d                	li	a0,-1
    80002dc6:	bfc5                	j	80002db6 <fetchstr+0x3a>

0000000080002dc8 <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80002dc8:	1101                	addi	sp,sp,-32
    80002dca:	ec06                	sd	ra,24(sp)
    80002dcc:	e822                	sd	s0,16(sp)
    80002dce:	e426                	sd	s1,8(sp)
    80002dd0:	1000                	addi	s0,sp,32
    80002dd2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002dd4:	00000097          	auipc	ra,0x0
    80002dd8:	eee080e7          	jalr	-274(ra) # 80002cc2 <argraw>
    80002ddc:	c088                	sw	a0,0(s1)
}
    80002dde:	60e2                	ld	ra,24(sp)
    80002de0:	6442                	ld	s0,16(sp)
    80002de2:	64a2                	ld	s1,8(sp)
    80002de4:	6105                	addi	sp,sp,32
    80002de6:	8082                	ret

0000000080002de8 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80002de8:	1101                	addi	sp,sp,-32
    80002dea:	ec06                	sd	ra,24(sp)
    80002dec:	e822                	sd	s0,16(sp)
    80002dee:	e426                	sd	s1,8(sp)
    80002df0:	1000                	addi	s0,sp,32
    80002df2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002df4:	00000097          	auipc	ra,0x0
    80002df8:	ece080e7          	jalr	-306(ra) # 80002cc2 <argraw>
    80002dfc:	e088                	sd	a0,0(s1)
}
    80002dfe:	60e2                	ld	ra,24(sp)
    80002e00:	6442                	ld	s0,16(sp)
    80002e02:	64a2                	ld	s1,8(sp)
    80002e04:	6105                	addi	sp,sp,32
    80002e06:	8082                	ret

0000000080002e08 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80002e08:	7179                	addi	sp,sp,-48
    80002e0a:	f406                	sd	ra,40(sp)
    80002e0c:	f022                	sd	s0,32(sp)
    80002e0e:	ec26                	sd	s1,24(sp)
    80002e10:	e84a                	sd	s2,16(sp)
    80002e12:	1800                	addi	s0,sp,48
    80002e14:	84ae                	mv	s1,a1
    80002e16:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002e18:	fd840593          	addi	a1,s0,-40
    80002e1c:	00000097          	auipc	ra,0x0
    80002e20:	fcc080e7          	jalr	-52(ra) # 80002de8 <argaddr>
  return fetchstr(addr, buf, max);
    80002e24:	864a                	mv	a2,s2
    80002e26:	85a6                	mv	a1,s1
    80002e28:	fd843503          	ld	a0,-40(s0)
    80002e2c:	00000097          	auipc	ra,0x0
    80002e30:	f50080e7          	jalr	-176(ra) # 80002d7c <fetchstr>
}
    80002e34:	70a2                	ld	ra,40(sp)
    80002e36:	7402                	ld	s0,32(sp)
    80002e38:	64e2                	ld	s1,24(sp)
    80002e3a:	6942                	ld	s2,16(sp)
    80002e3c:	6145                	addi	sp,sp,48
    80002e3e:	8082                	ret

0000000080002e40 <syscall>:
    {"settickets", 1},
    {"waitx",3}
};

void syscall(void)
{
    80002e40:	711d                	addi	sp,sp,-96
    80002e42:	ec86                	sd	ra,88(sp)
    80002e44:	e8a2                	sd	s0,80(sp)
    80002e46:	e4a6                	sd	s1,72(sp)
    80002e48:	e0ca                	sd	s2,64(sp)
    80002e4a:	fc4e                	sd	s3,56(sp)
    80002e4c:	f852                	sd	s4,48(sp)
    80002e4e:	f456                	sd	s5,40(sp)
    80002e50:	f05a                	sd	s6,32(sp)
    80002e52:	ec5e                	sd	s7,24(sp)
    80002e54:	e862                	sd	s8,16(sp)
    80002e56:	e466                	sd	s9,8(sp)
    80002e58:	e06a                	sd	s10,0(sp)
    80002e5a:	1080                	addi	s0,sp,96
  int num;
  struct proc *p = myproc();
    80002e5c:	fffff097          	auipc	ra,0xfffff
    80002e60:	c74080e7          	jalr	-908(ra) # 80001ad0 <myproc>
    80002e64:	8a2a                	mv	s4,a0

  num = p->trapframe->a7; // return reg
    80002e66:	7124                	ld	s1,96(a0)
    80002e68:	74dc                	ld	a5,168(s1)
    80002e6a:	00078b1b          	sext.w	s6,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    80002e6e:	37fd                	addiw	a5,a5,-1
    80002e70:	4765                	li	a4,25
    80002e72:	06f76f63          	bltu	a4,a5,80002ef0 <syscall+0xb0>
    80002e76:	003b1713          	slli	a4,s6,0x3
    80002e7a:	00005797          	auipc	a5,0x5
    80002e7e:	6fe78793          	addi	a5,a5,1790 # 80008578 <syscalls>
    80002e82:	97ba                	add	a5,a5,a4
    80002e84:	0007bd03          	ld	s10,0(a5)
    80002e88:	060d0463          	beqz	s10,80002ef0 <syscall+0xb0>
  {
    80002e8c:	8c8a                	mv	s9,sp
    int numargs = syscall_info[num - 1].num;
    80002e8e:	fffb0c1b          	addiw	s8,s6,-1
    80002e92:	004c1713          	slli	a4,s8,0x4
    80002e96:	00006797          	auipc	a5,0x6
    80002e9a:	b4278793          	addi	a5,a5,-1214 # 800089d8 <syscall_info>
    80002e9e:	97ba                	add	a5,a5,a4
    80002ea0:	0087a983          	lw	s3,8(a5)
    int Args[numargs]; // to store value of registers acc to the number of args of the syscall
    80002ea4:	00299793          	slli	a5,s3,0x2
    80002ea8:	07bd                	addi	a5,a5,15
    80002eaa:	9bc1                	andi	a5,a5,-16
    80002eac:	40f10133          	sub	sp,sp,a5
    80002eb0:	8b8a                	mv	s7,sp
    int j = 0;
    while (j < numargs)
    80002eb2:	11305363          	blez	s3,80002fb8 <syscall+0x178>
    80002eb6:	8ade                	mv	s5,s7
    80002eb8:	895e                	mv	s2,s7
    int j = 0;
    80002eba:	4481                	li	s1,0
    {
      Args[j] = argraw(j);
    80002ebc:	8526                	mv	a0,s1
    80002ebe:	00000097          	auipc	ra,0x0
    80002ec2:	e04080e7          	jalr	-508(ra) # 80002cc2 <argraw>
    80002ec6:	00a92023          	sw	a0,0(s2)
      j++;
    80002eca:	2485                	addiw	s1,s1,1
    while (j < numargs)
    80002ecc:	0911                	addi	s2,s2,4
    80002ece:	fe9997e3          	bne	s3,s1,80002ebc <syscall+0x7c>
    }

    int shift = 1 << num; // mask for num
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002ed2:	060a3483          	ld	s1,96(s4)
    80002ed6:	9d02                	jalr	s10
    80002ed8:	f8a8                	sd	a0,112(s1)
    int shift = 1 << num; // mask for num
    80002eda:	4785                	li	a5,1
    80002edc:	016797bb          	sllw	a5,a5,s6

    if (p->mask & shift)
    80002ee0:	000a2b03          	lw	s6,0(s4)
    80002ee4:	0167f7b3          	and	a5,a5,s6
    80002ee8:	2781                	sext.w	a5,a5
    80002eea:	e7a1                	bnez	a5,80002f32 <syscall+0xf2>
    80002eec:	8166                	mv	sp,s9
  {
    80002eee:	a015                	j	80002f12 <syscall+0xd2>
      printf(" -> %d\n", p->trapframe->a0);
    }
  }
  else
  {
    printf("%d %s: unknown sys call %d\n",
    80002ef0:	86da                	mv	a3,s6
    80002ef2:	160a0613          	addi	a2,s4,352
    80002ef6:	038a2583          	lw	a1,56(s4)
    80002efa:	00005517          	auipc	a0,0x5
    80002efe:	54e50513          	addi	a0,a0,1358 # 80008448 <states.2493+0x168>
    80002f02:	ffffd097          	auipc	ra,0xffffd
    80002f06:	68c080e7          	jalr	1676(ra) # 8000058e <printf>
           p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002f0a:	060a3783          	ld	a5,96(s4)
    80002f0e:	577d                	li	a4,-1
    80002f10:	fbb8                	sd	a4,112(a5)
  }
}
    80002f12:	fa040113          	addi	sp,s0,-96
    80002f16:	60e6                	ld	ra,88(sp)
    80002f18:	6446                	ld	s0,80(sp)
    80002f1a:	64a6                	ld	s1,72(sp)
    80002f1c:	6906                	ld	s2,64(sp)
    80002f1e:	79e2                	ld	s3,56(sp)
    80002f20:	7a42                	ld	s4,48(sp)
    80002f22:	7aa2                	ld	s5,40(sp)
    80002f24:	7b02                	ld	s6,32(sp)
    80002f26:	6be2                	ld	s7,24(sp)
    80002f28:	6c42                	ld	s8,16(sp)
    80002f2a:	6ca2                	ld	s9,8(sp)
    80002f2c:	6d02                	ld	s10,0(sp)
    80002f2e:	6125                	addi	sp,sp,96
    80002f30:	8082                	ret
      printf("%d: syscall %s ", p->pid, syscall_info[num - 1].name);
    80002f32:	0c12                	slli	s8,s8,0x4
    80002f34:	00006797          	auipc	a5,0x6
    80002f38:	aa478793          	addi	a5,a5,-1372 # 800089d8 <syscall_info>
    80002f3c:	9c3e                	add	s8,s8,a5
    80002f3e:	000c3603          	ld	a2,0(s8)
    80002f42:	038a2583          	lw	a1,56(s4)
    80002f46:	00005517          	auipc	a0,0x5
    80002f4a:	52250513          	addi	a0,a0,1314 # 80008468 <states.2493+0x188>
    80002f4e:	ffffd097          	auipc	ra,0xffffd
    80002f52:	640080e7          	jalr	1600(ra) # 8000058e <printf>
      printf("(");
    80002f56:	00005517          	auipc	a0,0x5
    80002f5a:	52250513          	addi	a0,a0,1314 # 80008478 <states.2493+0x198>
    80002f5e:	ffffd097          	auipc	ra,0xffffd
    80002f62:	630080e7          	jalr	1584(ra) # 8000058e <printf>
      while (i < numargs)
    80002f66:	fff9879b          	addiw	a5,s3,-1
    80002f6a:	1782                	slli	a5,a5,0x20
    80002f6c:	9381                	srli	a5,a5,0x20
    80002f6e:	0785                	addi	a5,a5,1
    80002f70:	078a                	slli	a5,a5,0x2
    80002f72:	9bbe                	add	s7,s7,a5
        printf("%d ", Args[i]);
    80002f74:	00005497          	auipc	s1,0x5
    80002f78:	4bc48493          	addi	s1,s1,1212 # 80008430 <states.2493+0x150>
    80002f7c:	000aa583          	lw	a1,0(s5)
    80002f80:	8526                	mv	a0,s1
    80002f82:	ffffd097          	auipc	ra,0xffffd
    80002f86:	60c080e7          	jalr	1548(ra) # 8000058e <printf>
      while (i < numargs)
    80002f8a:	0a91                	addi	s5,s5,4
    80002f8c:	ff7a98e3          	bne	s5,s7,80002f7c <syscall+0x13c>
      printf(")");
    80002f90:	00005517          	auipc	a0,0x5
    80002f94:	4a850513          	addi	a0,a0,1192 # 80008438 <states.2493+0x158>
    80002f98:	ffffd097          	auipc	ra,0xffffd
    80002f9c:	5f6080e7          	jalr	1526(ra) # 8000058e <printf>
      printf(" -> %d\n", p->trapframe->a0);
    80002fa0:	060a3783          	ld	a5,96(s4)
    80002fa4:	7bac                	ld	a1,112(a5)
    80002fa6:	00005517          	auipc	a0,0x5
    80002faa:	49a50513          	addi	a0,a0,1178 # 80008440 <states.2493+0x160>
    80002fae:	ffffd097          	auipc	ra,0xffffd
    80002fb2:	5e0080e7          	jalr	1504(ra) # 8000058e <printf>
    80002fb6:	bf1d                	j	80002eec <syscall+0xac>
    p->trapframe->a0 = syscalls[num]();
    80002fb8:	9d02                	jalr	s10
    80002fba:	f8a8                	sd	a0,112(s1)
    int shift = 1 << num; // mask for num
    80002fbc:	4785                	li	a5,1
    80002fbe:	016797bb          	sllw	a5,a5,s6
    if (p->mask & shift)
    80002fc2:	000a2703          	lw	a4,0(s4)
    80002fc6:	8ff9                	and	a5,a5,a4
    80002fc8:	2781                	sext.w	a5,a5
    80002fca:	d38d                	beqz	a5,80002eec <syscall+0xac>
      printf("%d: syscall %s ", p->pid, syscall_info[num - 1].name);
    80002fcc:	0c12                	slli	s8,s8,0x4
    80002fce:	00006797          	auipc	a5,0x6
    80002fd2:	a0a78793          	addi	a5,a5,-1526 # 800089d8 <syscall_info>
    80002fd6:	97e2                	add	a5,a5,s8
    80002fd8:	6390                	ld	a2,0(a5)
    80002fda:	038a2583          	lw	a1,56(s4)
    80002fde:	00005517          	auipc	a0,0x5
    80002fe2:	48a50513          	addi	a0,a0,1162 # 80008468 <states.2493+0x188>
    80002fe6:	ffffd097          	auipc	ra,0xffffd
    80002fea:	5a8080e7          	jalr	1448(ra) # 8000058e <printf>
      printf("(");
    80002fee:	00005517          	auipc	a0,0x5
    80002ff2:	48a50513          	addi	a0,a0,1162 # 80008478 <states.2493+0x198>
    80002ff6:	ffffd097          	auipc	ra,0xffffd
    80002ffa:	598080e7          	jalr	1432(ra) # 8000058e <printf>
      while (i < numargs)
    80002ffe:	bf49                	j	80002f90 <syscall+0x150>

0000000080003000 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80003000:	1101                	addi	sp,sp,-32
    80003002:	ec06                	sd	ra,24(sp)
    80003004:	e822                	sd	s0,16(sp)
    80003006:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80003008:	fec40593          	addi	a1,s0,-20
    8000300c:	4501                	li	a0,0
    8000300e:	00000097          	auipc	ra,0x0
    80003012:	dba080e7          	jalr	-582(ra) # 80002dc8 <argint>
  exit(n);
    80003016:	fec42503          	lw	a0,-20(s0)
    8000301a:	fffff097          	auipc	ra,0xfffff
    8000301e:	444080e7          	jalr	1092(ra) # 8000245e <exit>
  return 0; // not reached
}
    80003022:	4501                	li	a0,0
    80003024:	60e2                	ld	ra,24(sp)
    80003026:	6442                	ld	s0,16(sp)
    80003028:	6105                	addi	sp,sp,32
    8000302a:	8082                	ret

000000008000302c <sys_getpid>:

uint64
sys_getpid(void)
{
    8000302c:	1141                	addi	sp,sp,-16
    8000302e:	e406                	sd	ra,8(sp)
    80003030:	e022                	sd	s0,0(sp)
    80003032:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003034:	fffff097          	auipc	ra,0xfffff
    80003038:	a9c080e7          	jalr	-1380(ra) # 80001ad0 <myproc>
}
    8000303c:	5d08                	lw	a0,56(a0)
    8000303e:	60a2                	ld	ra,8(sp)
    80003040:	6402                	ld	s0,0(sp)
    80003042:	0141                	addi	sp,sp,16
    80003044:	8082                	ret

0000000080003046 <sys_fork>:

uint64
sys_fork(void)
{
    80003046:	1141                	addi	sp,sp,-16
    80003048:	e406                	sd	ra,8(sp)
    8000304a:	e022                	sd	s0,0(sp)
    8000304c:	0800                	addi	s0,sp,16
  return fork();
    8000304e:	fffff097          	auipc	ra,0xfffff
    80003052:	e44080e7          	jalr	-444(ra) # 80001e92 <fork>
}
    80003056:	60a2                	ld	ra,8(sp)
    80003058:	6402                	ld	s0,0(sp)
    8000305a:	0141                	addi	sp,sp,16
    8000305c:	8082                	ret

000000008000305e <sys_wait>:

uint64
sys_wait(void)
{
    8000305e:	1101                	addi	sp,sp,-32
    80003060:	ec06                	sd	ra,24(sp)
    80003062:	e822                	sd	s0,16(sp)
    80003064:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80003066:	fe840593          	addi	a1,s0,-24
    8000306a:	4501                	li	a0,0
    8000306c:	00000097          	auipc	ra,0x0
    80003070:	d7c080e7          	jalr	-644(ra) # 80002de8 <argaddr>
  return wait(p);
    80003074:	fe843503          	ld	a0,-24(s0)
    80003078:	fffff097          	auipc	ra,0xfffff
    8000307c:	5a4080e7          	jalr	1444(ra) # 8000261c <wait>
}
    80003080:	60e2                	ld	ra,24(sp)
    80003082:	6442                	ld	s0,16(sp)
    80003084:	6105                	addi	sp,sp,32
    80003086:	8082                	ret

0000000080003088 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003088:	7179                	addi	sp,sp,-48
    8000308a:	f406                	sd	ra,40(sp)
    8000308c:	f022                	sd	s0,32(sp)
    8000308e:	ec26                	sd	s1,24(sp)
    80003090:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80003092:	fdc40593          	addi	a1,s0,-36
    80003096:	4501                	li	a0,0
    80003098:	00000097          	auipc	ra,0x0
    8000309c:	d30080e7          	jalr	-720(ra) # 80002dc8 <argint>
  addr = myproc()->sz;
    800030a0:	fffff097          	auipc	ra,0xfffff
    800030a4:	a30080e7          	jalr	-1488(ra) # 80001ad0 <myproc>
    800030a8:	6924                	ld	s1,80(a0)
  if (growproc(n) < 0)
    800030aa:	fdc42503          	lw	a0,-36(s0)
    800030ae:	fffff097          	auipc	ra,0xfffff
    800030b2:	d88080e7          	jalr	-632(ra) # 80001e36 <growproc>
    800030b6:	00054863          	bltz	a0,800030c6 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    800030ba:	8526                	mv	a0,s1
    800030bc:	70a2                	ld	ra,40(sp)
    800030be:	7402                	ld	s0,32(sp)
    800030c0:	64e2                	ld	s1,24(sp)
    800030c2:	6145                	addi	sp,sp,48
    800030c4:	8082                	ret
    return -1;
    800030c6:	54fd                	li	s1,-1
    800030c8:	bfcd                	j	800030ba <sys_sbrk+0x32>

00000000800030ca <sys_sleep>:

uint64
sys_sleep(void)
{
    800030ca:	7139                	addi	sp,sp,-64
    800030cc:	fc06                	sd	ra,56(sp)
    800030ce:	f822                	sd	s0,48(sp)
    800030d0:	f426                	sd	s1,40(sp)
    800030d2:	f04a                	sd	s2,32(sp)
    800030d4:	ec4e                	sd	s3,24(sp)
    800030d6:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800030d8:	fcc40593          	addi	a1,s0,-52
    800030dc:	4501                	li	a0,0
    800030de:	00000097          	auipc	ra,0x0
    800030e2:	cea080e7          	jalr	-790(ra) # 80002dc8 <argint>
  acquire(&tickslock);
    800030e6:	00015517          	auipc	a0,0x15
    800030ea:	58a50513          	addi	a0,a0,1418 # 80018670 <tickslock>
    800030ee:	ffffe097          	auipc	ra,0xffffe
    800030f2:	afc080e7          	jalr	-1284(ra) # 80000bea <acquire>
  ticks0 = ticks;
    800030f6:	00006917          	auipc	s2,0x6
    800030fa:	ada92903          	lw	s2,-1318(s2) # 80008bd0 <ticks>
  while (ticks - ticks0 < n)
    800030fe:	fcc42783          	lw	a5,-52(s0)
    80003102:	cf9d                	beqz	a5,80003140 <sys_sleep+0x76>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003104:	00015997          	auipc	s3,0x15
    80003108:	56c98993          	addi	s3,s3,1388 # 80018670 <tickslock>
    8000310c:	00006497          	auipc	s1,0x6
    80003110:	ac448493          	addi	s1,s1,-1340 # 80008bd0 <ticks>
    if (killed(myproc()))
    80003114:	fffff097          	auipc	ra,0xfffff
    80003118:	9bc080e7          	jalr	-1604(ra) # 80001ad0 <myproc>
    8000311c:	fffff097          	auipc	ra,0xfffff
    80003120:	4ca080e7          	jalr	1226(ra) # 800025e6 <killed>
    80003124:	ed15                	bnez	a0,80003160 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80003126:	85ce                	mv	a1,s3
    80003128:	8526                	mv	a0,s1
    8000312a:	fffff097          	auipc	ra,0xfffff
    8000312e:	0be080e7          	jalr	190(ra) # 800021e8 <sleep>
  while (ticks - ticks0 < n)
    80003132:	409c                	lw	a5,0(s1)
    80003134:	412787bb          	subw	a5,a5,s2
    80003138:	fcc42703          	lw	a4,-52(s0)
    8000313c:	fce7ece3          	bltu	a5,a4,80003114 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80003140:	00015517          	auipc	a0,0x15
    80003144:	53050513          	addi	a0,a0,1328 # 80018670 <tickslock>
    80003148:	ffffe097          	auipc	ra,0xffffe
    8000314c:	b56080e7          	jalr	-1194(ra) # 80000c9e <release>
  return 0;
    80003150:	4501                	li	a0,0
}
    80003152:	70e2                	ld	ra,56(sp)
    80003154:	7442                	ld	s0,48(sp)
    80003156:	74a2                	ld	s1,40(sp)
    80003158:	7902                	ld	s2,32(sp)
    8000315a:	69e2                	ld	s3,24(sp)
    8000315c:	6121                	addi	sp,sp,64
    8000315e:	8082                	ret
      release(&tickslock);
    80003160:	00015517          	auipc	a0,0x15
    80003164:	51050513          	addi	a0,a0,1296 # 80018670 <tickslock>
    80003168:	ffffe097          	auipc	ra,0xffffe
    8000316c:	b36080e7          	jalr	-1226(ra) # 80000c9e <release>
      return -1;
    80003170:	557d                	li	a0,-1
    80003172:	b7c5                	j	80003152 <sys_sleep+0x88>

0000000080003174 <sys_kill>:

uint64
sys_kill(void)
{
    80003174:	1101                	addi	sp,sp,-32
    80003176:	ec06                	sd	ra,24(sp)
    80003178:	e822                	sd	s0,16(sp)
    8000317a:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    8000317c:	fec40593          	addi	a1,s0,-20
    80003180:	4501                	li	a0,0
    80003182:	00000097          	auipc	ra,0x0
    80003186:	c46080e7          	jalr	-954(ra) # 80002dc8 <argint>
  return kill(pid);
    8000318a:	fec42503          	lw	a0,-20(s0)
    8000318e:	fffff097          	auipc	ra,0xfffff
    80003192:	3a8080e7          	jalr	936(ra) # 80002536 <kill>
}
    80003196:	60e2                	ld	ra,24(sp)
    80003198:	6442                	ld	s0,16(sp)
    8000319a:	6105                	addi	sp,sp,32
    8000319c:	8082                	ret

000000008000319e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000319e:	1101                	addi	sp,sp,-32
    800031a0:	ec06                	sd	ra,24(sp)
    800031a2:	e822                	sd	s0,16(sp)
    800031a4:	e426                	sd	s1,8(sp)
    800031a6:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800031a8:	00015517          	auipc	a0,0x15
    800031ac:	4c850513          	addi	a0,a0,1224 # 80018670 <tickslock>
    800031b0:	ffffe097          	auipc	ra,0xffffe
    800031b4:	a3a080e7          	jalr	-1478(ra) # 80000bea <acquire>
  xticks = ticks;
    800031b8:	00006497          	auipc	s1,0x6
    800031bc:	a184a483          	lw	s1,-1512(s1) # 80008bd0 <ticks>
  release(&tickslock);
    800031c0:	00015517          	auipc	a0,0x15
    800031c4:	4b050513          	addi	a0,a0,1200 # 80018670 <tickslock>
    800031c8:	ffffe097          	auipc	ra,0xffffe
    800031cc:	ad6080e7          	jalr	-1322(ra) # 80000c9e <release>
  return xticks;
}
    800031d0:	02049513          	slli	a0,s1,0x20
    800031d4:	9101                	srli	a0,a0,0x20
    800031d6:	60e2                	ld	ra,24(sp)
    800031d8:	6442                	ld	s0,16(sp)
    800031da:	64a2                	ld	s1,8(sp)
    800031dc:	6105                	addi	sp,sp,32
    800031de:	8082                	ret

00000000800031e0 <sys_trace>:

uint64
sys_trace(void)
{
    800031e0:	1101                	addi	sp,sp,-32
    800031e2:	ec06                	sd	ra,24(sp)
    800031e4:	e822                	sd	s0,16(sp)
    800031e6:	1000                	addi	s0,sp,32
  int n; // mask
  argint(0, &n);
    800031e8:	fec40593          	addi	a1,s0,-20
    800031ec:	4501                	li	a0,0
    800031ee:	00000097          	auipc	ra,0x0
    800031f2:	bda080e7          	jalr	-1062(ra) # 80002dc8 <argint>
  myproc()->mask = n;
    800031f6:	fffff097          	auipc	ra,0xfffff
    800031fa:	8da080e7          	jalr	-1830(ra) # 80001ad0 <myproc>
    800031fe:	fec42783          	lw	a5,-20(s0)
    80003202:	c11c                	sw	a5,0(a0)
  return 0;
}
    80003204:	4501                	li	a0,0
    80003206:	60e2                	ld	ra,24(sp)
    80003208:	6442                	ld	s0,16(sp)
    8000320a:	6105                	addi	sp,sp,32
    8000320c:	8082                	ret

000000008000320e <sys_sigalarm>:

uint64
sys_sigalarm(void)
{
    8000320e:	1101                	addi	sp,sp,-32
    80003210:	ec06                	sd	ra,24(sp)
    80003212:	e822                	sd	s0,16(sp)
    80003214:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80003216:	fec40593          	addi	a1,s0,-20
    8000321a:	4501                	li	a0,0
    8000321c:	00000097          	auipc	ra,0x0
    80003220:	bac080e7          	jalr	-1108(ra) # 80002dc8 <argint>
  myproc()->ticks0 = 0;
    80003224:	fffff097          	auipc	ra,0xfffff
    80003228:	8ac080e7          	jalr	-1876(ra) # 80001ad0 <myproc>
    8000322c:	00052223          	sw	zero,4(a0)
  return 0;
}
    80003230:	4501                	li	a0,0
    80003232:	60e2                	ld	ra,24(sp)
    80003234:	6442                	ld	s0,16(sp)
    80003236:	6105                	addi	sp,sp,32
    80003238:	8082                	ret

000000008000323a <sys_setpriority>:

uint64
sys_setpriority(void)
{
    8000323a:	1101                	addi	sp,sp,-32
    8000323c:	ec06                	sd	ra,24(sp)
    8000323e:	e822                	sd	s0,16(sp)
    80003240:	1000                	addi	s0,sp,32
  int priority;
  int pid;
  argint(0, &priority);
    80003242:	fec40593          	addi	a1,s0,-20
    80003246:	4501                	li	a0,0
    80003248:	00000097          	auipc	ra,0x0
    8000324c:	b80080e7          	jalr	-1152(ra) # 80002dc8 <argint>
  argint(1, &pid);
    80003250:	fe840593          	addi	a1,s0,-24
    80003254:	4505                	li	a0,1
    80003256:	00000097          	auipc	ra,0x0
    8000325a:	b72080e7          	jalr	-1166(ra) # 80002dc8 <argint>
  return set_priority(priority, pid);
    8000325e:	fe842583          	lw	a1,-24(s0)
    80003262:	fec42503          	lw	a0,-20(s0)
    80003266:	ffffe097          	auipc	ra,0xffffe
    8000326a:	638080e7          	jalr	1592(ra) # 8000189e <set_priority>
}
    8000326e:	60e2                	ld	ra,24(sp)
    80003270:	6442                	ld	s0,16(sp)
    80003272:	6105                	addi	sp,sp,32
    80003274:	8082                	ret

0000000080003276 <sys_settickets>:

uint64
sys_settickets(void){
    80003276:	1101                	addi	sp,sp,-32
    80003278:	ec06                	sd	ra,24(sp)
    8000327a:	e822                	sd	s0,16(sp)
    8000327c:	1000                	addi	s0,sp,32
  int n; // tickets
  argint(0, &n);
    8000327e:	fec40593          	addi	a1,s0,-20
    80003282:	4501                	li	a0,0
    80003284:	00000097          	auipc	ra,0x0
    80003288:	b44080e7          	jalr	-1212(ra) # 80002dc8 <argint>
  myproc()->tickets = n;
    8000328c:	fffff097          	auipc	ra,0xfffff
    80003290:	844080e7          	jalr	-1980(ra) # 80001ad0 <myproc>
    80003294:	fec42783          	lw	a5,-20(s0)
    80003298:	16f52823          	sw	a5,368(a0)
  return 0;
}
    8000329c:	4501                	li	a0,0
    8000329e:	60e2                	ld	ra,24(sp)
    800032a0:	6442                	ld	s0,16(sp)
    800032a2:	6105                	addi	sp,sp,32
    800032a4:	8082                	ret

00000000800032a6 <sys_waitx>:

uint64
sys_waitx(void)
{
    800032a6:	7139                	addi	sp,sp,-64
    800032a8:	fc06                	sd	ra,56(sp)
    800032aa:	f822                	sd	s0,48(sp)
    800032ac:	f426                	sd	s1,40(sp)
    800032ae:	f04a                	sd	s2,32(sp)
    800032b0:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    800032b2:	fd840593          	addi	a1,s0,-40
    800032b6:	4501                	li	a0,0
    800032b8:	00000097          	auipc	ra,0x0
    800032bc:	b30080e7          	jalr	-1232(ra) # 80002de8 <argaddr>
  argaddr(1, &addr1); // user virtual memory
    800032c0:	fd040593          	addi	a1,s0,-48
    800032c4:	4505                	li	a0,1
    800032c6:	00000097          	auipc	ra,0x0
    800032ca:	b22080e7          	jalr	-1246(ra) # 80002de8 <argaddr>
  argaddr(2, &addr2);
    800032ce:	fc840593          	addi	a1,s0,-56
    800032d2:	4509                	li	a0,2
    800032d4:	00000097          	auipc	ra,0x0
    800032d8:	b14080e7          	jalr	-1260(ra) # 80002de8 <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    800032dc:	fc040613          	addi	a2,s0,-64
    800032e0:	fc440593          	addi	a1,s0,-60
    800032e4:	fd843503          	ld	a0,-40(s0)
    800032e8:	fffff097          	auipc	ra,0xfffff
    800032ec:	f6e080e7          	jalr	-146(ra) # 80002256 <waitx>
    800032f0:	892a                	mv	s2,a0
  struct proc* p = myproc();
    800032f2:	ffffe097          	auipc	ra,0xffffe
    800032f6:	7de080e7          	jalr	2014(ra) # 80001ad0 <myproc>
    800032fa:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    800032fc:	4691                	li	a3,4
    800032fe:	fc440613          	addi	a2,s0,-60
    80003302:	fd043583          	ld	a1,-48(s0)
    80003306:	6d28                	ld	a0,88(a0)
    80003308:	ffffe097          	auipc	ra,0xffffe
    8000330c:	37c080e7          	jalr	892(ra) # 80001684 <copyout>
    return -1;
    80003310:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)
    80003312:	00054f63          	bltz	a0,80003330 <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2,(char*)&rtime, sizeof(int)) < 0)
    80003316:	4691                	li	a3,4
    80003318:	fc040613          	addi	a2,s0,-64
    8000331c:	fc843583          	ld	a1,-56(s0)
    80003320:	6ca8                	ld	a0,88(s1)
    80003322:	ffffe097          	auipc	ra,0xffffe
    80003326:	362080e7          	jalr	866(ra) # 80001684 <copyout>
    8000332a:	00054a63          	bltz	a0,8000333e <sys_waitx+0x98>
    return -1;
  return ret;
    8000332e:	87ca                	mv	a5,s2
    80003330:	853e                	mv	a0,a5
    80003332:	70e2                	ld	ra,56(sp)
    80003334:	7442                	ld	s0,48(sp)
    80003336:	74a2                	ld	s1,40(sp)
    80003338:	7902                	ld	s2,32(sp)
    8000333a:	6121                	addi	sp,sp,64
    8000333c:	8082                	ret
    return -1;
    8000333e:	57fd                	li	a5,-1
    80003340:	bfc5                	j	80003330 <sys_waitx+0x8a>

0000000080003342 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003342:	7179                	addi	sp,sp,-48
    80003344:	f406                	sd	ra,40(sp)
    80003346:	f022                	sd	s0,32(sp)
    80003348:	ec26                	sd	s1,24(sp)
    8000334a:	e84a                	sd	s2,16(sp)
    8000334c:	e44e                	sd	s3,8(sp)
    8000334e:	e052                	sd	s4,0(sp)
    80003350:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003352:	00005597          	auipc	a1,0x5
    80003356:	2fe58593          	addi	a1,a1,766 # 80008650 <syscalls+0xd8>
    8000335a:	00015517          	auipc	a0,0x15
    8000335e:	32e50513          	addi	a0,a0,814 # 80018688 <bcache>
    80003362:	ffffd097          	auipc	ra,0xffffd
    80003366:	7f8080e7          	jalr	2040(ra) # 80000b5a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000336a:	0001d797          	auipc	a5,0x1d
    8000336e:	31e78793          	addi	a5,a5,798 # 80020688 <bcache+0x8000>
    80003372:	0001d717          	auipc	a4,0x1d
    80003376:	57e70713          	addi	a4,a4,1406 # 800208f0 <bcache+0x8268>
    8000337a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000337e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003382:	00015497          	auipc	s1,0x15
    80003386:	31e48493          	addi	s1,s1,798 # 800186a0 <bcache+0x18>
    b->next = bcache.head.next;
    8000338a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000338c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000338e:	00005a17          	auipc	s4,0x5
    80003392:	2caa0a13          	addi	s4,s4,714 # 80008658 <syscalls+0xe0>
    b->next = bcache.head.next;
    80003396:	2b893783          	ld	a5,696(s2)
    8000339a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000339c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800033a0:	85d2                	mv	a1,s4
    800033a2:	01048513          	addi	a0,s1,16
    800033a6:	00001097          	auipc	ra,0x1
    800033aa:	4c4080e7          	jalr	1220(ra) # 8000486a <initsleeplock>
    bcache.head.next->prev = b;
    800033ae:	2b893783          	ld	a5,696(s2)
    800033b2:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800033b4:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800033b8:	45848493          	addi	s1,s1,1112
    800033bc:	fd349de3          	bne	s1,s3,80003396 <binit+0x54>
  }
}
    800033c0:	70a2                	ld	ra,40(sp)
    800033c2:	7402                	ld	s0,32(sp)
    800033c4:	64e2                	ld	s1,24(sp)
    800033c6:	6942                	ld	s2,16(sp)
    800033c8:	69a2                	ld	s3,8(sp)
    800033ca:	6a02                	ld	s4,0(sp)
    800033cc:	6145                	addi	sp,sp,48
    800033ce:	8082                	ret

00000000800033d0 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800033d0:	7179                	addi	sp,sp,-48
    800033d2:	f406                	sd	ra,40(sp)
    800033d4:	f022                	sd	s0,32(sp)
    800033d6:	ec26                	sd	s1,24(sp)
    800033d8:	e84a                	sd	s2,16(sp)
    800033da:	e44e                	sd	s3,8(sp)
    800033dc:	1800                	addi	s0,sp,48
    800033de:	89aa                	mv	s3,a0
    800033e0:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    800033e2:	00015517          	auipc	a0,0x15
    800033e6:	2a650513          	addi	a0,a0,678 # 80018688 <bcache>
    800033ea:	ffffe097          	auipc	ra,0xffffe
    800033ee:	800080e7          	jalr	-2048(ra) # 80000bea <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800033f2:	0001d497          	auipc	s1,0x1d
    800033f6:	54e4b483          	ld	s1,1358(s1) # 80020940 <bcache+0x82b8>
    800033fa:	0001d797          	auipc	a5,0x1d
    800033fe:	4f678793          	addi	a5,a5,1270 # 800208f0 <bcache+0x8268>
    80003402:	02f48f63          	beq	s1,a5,80003440 <bread+0x70>
    80003406:	873e                	mv	a4,a5
    80003408:	a021                	j	80003410 <bread+0x40>
    8000340a:	68a4                	ld	s1,80(s1)
    8000340c:	02e48a63          	beq	s1,a4,80003440 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003410:	449c                	lw	a5,8(s1)
    80003412:	ff379ce3          	bne	a5,s3,8000340a <bread+0x3a>
    80003416:	44dc                	lw	a5,12(s1)
    80003418:	ff2799e3          	bne	a5,s2,8000340a <bread+0x3a>
      b->refcnt++;
    8000341c:	40bc                	lw	a5,64(s1)
    8000341e:	2785                	addiw	a5,a5,1
    80003420:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003422:	00015517          	auipc	a0,0x15
    80003426:	26650513          	addi	a0,a0,614 # 80018688 <bcache>
    8000342a:	ffffe097          	auipc	ra,0xffffe
    8000342e:	874080e7          	jalr	-1932(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    80003432:	01048513          	addi	a0,s1,16
    80003436:	00001097          	auipc	ra,0x1
    8000343a:	46e080e7          	jalr	1134(ra) # 800048a4 <acquiresleep>
      return b;
    8000343e:	a8b9                	j	8000349c <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003440:	0001d497          	auipc	s1,0x1d
    80003444:	4f84b483          	ld	s1,1272(s1) # 80020938 <bcache+0x82b0>
    80003448:	0001d797          	auipc	a5,0x1d
    8000344c:	4a878793          	addi	a5,a5,1192 # 800208f0 <bcache+0x8268>
    80003450:	00f48863          	beq	s1,a5,80003460 <bread+0x90>
    80003454:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003456:	40bc                	lw	a5,64(s1)
    80003458:	cf81                	beqz	a5,80003470 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000345a:	64a4                	ld	s1,72(s1)
    8000345c:	fee49de3          	bne	s1,a4,80003456 <bread+0x86>
  panic("bget: no buffers");
    80003460:	00005517          	auipc	a0,0x5
    80003464:	20050513          	addi	a0,a0,512 # 80008660 <syscalls+0xe8>
    80003468:	ffffd097          	auipc	ra,0xffffd
    8000346c:	0dc080e7          	jalr	220(ra) # 80000544 <panic>
      b->dev = dev;
    80003470:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80003474:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80003478:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000347c:	4785                	li	a5,1
    8000347e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003480:	00015517          	auipc	a0,0x15
    80003484:	20850513          	addi	a0,a0,520 # 80018688 <bcache>
    80003488:	ffffe097          	auipc	ra,0xffffe
    8000348c:	816080e7          	jalr	-2026(ra) # 80000c9e <release>
      acquiresleep(&b->lock);
    80003490:	01048513          	addi	a0,s1,16
    80003494:	00001097          	auipc	ra,0x1
    80003498:	410080e7          	jalr	1040(ra) # 800048a4 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000349c:	409c                	lw	a5,0(s1)
    8000349e:	cb89                	beqz	a5,800034b0 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800034a0:	8526                	mv	a0,s1
    800034a2:	70a2                	ld	ra,40(sp)
    800034a4:	7402                	ld	s0,32(sp)
    800034a6:	64e2                	ld	s1,24(sp)
    800034a8:	6942                	ld	s2,16(sp)
    800034aa:	69a2                	ld	s3,8(sp)
    800034ac:	6145                	addi	sp,sp,48
    800034ae:	8082                	ret
    virtio_disk_rw(b, 0);
    800034b0:	4581                	li	a1,0
    800034b2:	8526                	mv	a0,s1
    800034b4:	00003097          	auipc	ra,0x3
    800034b8:	fc4080e7          	jalr	-60(ra) # 80006478 <virtio_disk_rw>
    b->valid = 1;
    800034bc:	4785                	li	a5,1
    800034be:	c09c                	sw	a5,0(s1)
  return b;
    800034c0:	b7c5                	j	800034a0 <bread+0xd0>

00000000800034c2 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800034c2:	1101                	addi	sp,sp,-32
    800034c4:	ec06                	sd	ra,24(sp)
    800034c6:	e822                	sd	s0,16(sp)
    800034c8:	e426                	sd	s1,8(sp)
    800034ca:	1000                	addi	s0,sp,32
    800034cc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800034ce:	0541                	addi	a0,a0,16
    800034d0:	00001097          	auipc	ra,0x1
    800034d4:	46e080e7          	jalr	1134(ra) # 8000493e <holdingsleep>
    800034d8:	cd01                	beqz	a0,800034f0 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800034da:	4585                	li	a1,1
    800034dc:	8526                	mv	a0,s1
    800034de:	00003097          	auipc	ra,0x3
    800034e2:	f9a080e7          	jalr	-102(ra) # 80006478 <virtio_disk_rw>
}
    800034e6:	60e2                	ld	ra,24(sp)
    800034e8:	6442                	ld	s0,16(sp)
    800034ea:	64a2                	ld	s1,8(sp)
    800034ec:	6105                	addi	sp,sp,32
    800034ee:	8082                	ret
    panic("bwrite");
    800034f0:	00005517          	auipc	a0,0x5
    800034f4:	18850513          	addi	a0,a0,392 # 80008678 <syscalls+0x100>
    800034f8:	ffffd097          	auipc	ra,0xffffd
    800034fc:	04c080e7          	jalr	76(ra) # 80000544 <panic>

0000000080003500 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003500:	1101                	addi	sp,sp,-32
    80003502:	ec06                	sd	ra,24(sp)
    80003504:	e822                	sd	s0,16(sp)
    80003506:	e426                	sd	s1,8(sp)
    80003508:	e04a                	sd	s2,0(sp)
    8000350a:	1000                	addi	s0,sp,32
    8000350c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000350e:	01050913          	addi	s2,a0,16
    80003512:	854a                	mv	a0,s2
    80003514:	00001097          	auipc	ra,0x1
    80003518:	42a080e7          	jalr	1066(ra) # 8000493e <holdingsleep>
    8000351c:	c92d                	beqz	a0,8000358e <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000351e:	854a                	mv	a0,s2
    80003520:	00001097          	auipc	ra,0x1
    80003524:	3da080e7          	jalr	986(ra) # 800048fa <releasesleep>

  acquire(&bcache.lock);
    80003528:	00015517          	auipc	a0,0x15
    8000352c:	16050513          	addi	a0,a0,352 # 80018688 <bcache>
    80003530:	ffffd097          	auipc	ra,0xffffd
    80003534:	6ba080e7          	jalr	1722(ra) # 80000bea <acquire>
  b->refcnt--;
    80003538:	40bc                	lw	a5,64(s1)
    8000353a:	37fd                	addiw	a5,a5,-1
    8000353c:	0007871b          	sext.w	a4,a5
    80003540:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003542:	eb05                	bnez	a4,80003572 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003544:	68bc                	ld	a5,80(s1)
    80003546:	64b8                	ld	a4,72(s1)
    80003548:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000354a:	64bc                	ld	a5,72(s1)
    8000354c:	68b8                	ld	a4,80(s1)
    8000354e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003550:	0001d797          	auipc	a5,0x1d
    80003554:	13878793          	addi	a5,a5,312 # 80020688 <bcache+0x8000>
    80003558:	2b87b703          	ld	a4,696(a5)
    8000355c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000355e:	0001d717          	auipc	a4,0x1d
    80003562:	39270713          	addi	a4,a4,914 # 800208f0 <bcache+0x8268>
    80003566:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003568:	2b87b703          	ld	a4,696(a5)
    8000356c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000356e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003572:	00015517          	auipc	a0,0x15
    80003576:	11650513          	addi	a0,a0,278 # 80018688 <bcache>
    8000357a:	ffffd097          	auipc	ra,0xffffd
    8000357e:	724080e7          	jalr	1828(ra) # 80000c9e <release>
}
    80003582:	60e2                	ld	ra,24(sp)
    80003584:	6442                	ld	s0,16(sp)
    80003586:	64a2                	ld	s1,8(sp)
    80003588:	6902                	ld	s2,0(sp)
    8000358a:	6105                	addi	sp,sp,32
    8000358c:	8082                	ret
    panic("brelse");
    8000358e:	00005517          	auipc	a0,0x5
    80003592:	0f250513          	addi	a0,a0,242 # 80008680 <syscalls+0x108>
    80003596:	ffffd097          	auipc	ra,0xffffd
    8000359a:	fae080e7          	jalr	-82(ra) # 80000544 <panic>

000000008000359e <bpin>:

void
bpin(struct buf *b) {
    8000359e:	1101                	addi	sp,sp,-32
    800035a0:	ec06                	sd	ra,24(sp)
    800035a2:	e822                	sd	s0,16(sp)
    800035a4:	e426                	sd	s1,8(sp)
    800035a6:	1000                	addi	s0,sp,32
    800035a8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800035aa:	00015517          	auipc	a0,0x15
    800035ae:	0de50513          	addi	a0,a0,222 # 80018688 <bcache>
    800035b2:	ffffd097          	auipc	ra,0xffffd
    800035b6:	638080e7          	jalr	1592(ra) # 80000bea <acquire>
  b->refcnt++;
    800035ba:	40bc                	lw	a5,64(s1)
    800035bc:	2785                	addiw	a5,a5,1
    800035be:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800035c0:	00015517          	auipc	a0,0x15
    800035c4:	0c850513          	addi	a0,a0,200 # 80018688 <bcache>
    800035c8:	ffffd097          	auipc	ra,0xffffd
    800035cc:	6d6080e7          	jalr	1750(ra) # 80000c9e <release>
}
    800035d0:	60e2                	ld	ra,24(sp)
    800035d2:	6442                	ld	s0,16(sp)
    800035d4:	64a2                	ld	s1,8(sp)
    800035d6:	6105                	addi	sp,sp,32
    800035d8:	8082                	ret

00000000800035da <bunpin>:

void
bunpin(struct buf *b) {
    800035da:	1101                	addi	sp,sp,-32
    800035dc:	ec06                	sd	ra,24(sp)
    800035de:	e822                	sd	s0,16(sp)
    800035e0:	e426                	sd	s1,8(sp)
    800035e2:	1000                	addi	s0,sp,32
    800035e4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800035e6:	00015517          	auipc	a0,0x15
    800035ea:	0a250513          	addi	a0,a0,162 # 80018688 <bcache>
    800035ee:	ffffd097          	auipc	ra,0xffffd
    800035f2:	5fc080e7          	jalr	1532(ra) # 80000bea <acquire>
  b->refcnt--;
    800035f6:	40bc                	lw	a5,64(s1)
    800035f8:	37fd                	addiw	a5,a5,-1
    800035fa:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800035fc:	00015517          	auipc	a0,0x15
    80003600:	08c50513          	addi	a0,a0,140 # 80018688 <bcache>
    80003604:	ffffd097          	auipc	ra,0xffffd
    80003608:	69a080e7          	jalr	1690(ra) # 80000c9e <release>
}
    8000360c:	60e2                	ld	ra,24(sp)
    8000360e:	6442                	ld	s0,16(sp)
    80003610:	64a2                	ld	s1,8(sp)
    80003612:	6105                	addi	sp,sp,32
    80003614:	8082                	ret

0000000080003616 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003616:	1101                	addi	sp,sp,-32
    80003618:	ec06                	sd	ra,24(sp)
    8000361a:	e822                	sd	s0,16(sp)
    8000361c:	e426                	sd	s1,8(sp)
    8000361e:	e04a                	sd	s2,0(sp)
    80003620:	1000                	addi	s0,sp,32
    80003622:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003624:	00d5d59b          	srliw	a1,a1,0xd
    80003628:	0001d797          	auipc	a5,0x1d
    8000362c:	73c7a783          	lw	a5,1852(a5) # 80020d64 <sb+0x1c>
    80003630:	9dbd                	addw	a1,a1,a5
    80003632:	00000097          	auipc	ra,0x0
    80003636:	d9e080e7          	jalr	-610(ra) # 800033d0 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000363a:	0074f713          	andi	a4,s1,7
    8000363e:	4785                	li	a5,1
    80003640:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003644:	14ce                	slli	s1,s1,0x33
    80003646:	90d9                	srli	s1,s1,0x36
    80003648:	00950733          	add	a4,a0,s1
    8000364c:	05874703          	lbu	a4,88(a4)
    80003650:	00e7f6b3          	and	a3,a5,a4
    80003654:	c69d                	beqz	a3,80003682 <bfree+0x6c>
    80003656:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003658:	94aa                	add	s1,s1,a0
    8000365a:	fff7c793          	not	a5,a5
    8000365e:	8ff9                	and	a5,a5,a4
    80003660:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003664:	00001097          	auipc	ra,0x1
    80003668:	120080e7          	jalr	288(ra) # 80004784 <log_write>
  brelse(bp);
    8000366c:	854a                	mv	a0,s2
    8000366e:	00000097          	auipc	ra,0x0
    80003672:	e92080e7          	jalr	-366(ra) # 80003500 <brelse>
}
    80003676:	60e2                	ld	ra,24(sp)
    80003678:	6442                	ld	s0,16(sp)
    8000367a:	64a2                	ld	s1,8(sp)
    8000367c:	6902                	ld	s2,0(sp)
    8000367e:	6105                	addi	sp,sp,32
    80003680:	8082                	ret
    panic("freeing free block");
    80003682:	00005517          	auipc	a0,0x5
    80003686:	00650513          	addi	a0,a0,6 # 80008688 <syscalls+0x110>
    8000368a:	ffffd097          	auipc	ra,0xffffd
    8000368e:	eba080e7          	jalr	-326(ra) # 80000544 <panic>

0000000080003692 <balloc>:
{
    80003692:	711d                	addi	sp,sp,-96
    80003694:	ec86                	sd	ra,88(sp)
    80003696:	e8a2                	sd	s0,80(sp)
    80003698:	e4a6                	sd	s1,72(sp)
    8000369a:	e0ca                	sd	s2,64(sp)
    8000369c:	fc4e                	sd	s3,56(sp)
    8000369e:	f852                	sd	s4,48(sp)
    800036a0:	f456                	sd	s5,40(sp)
    800036a2:	f05a                	sd	s6,32(sp)
    800036a4:	ec5e                	sd	s7,24(sp)
    800036a6:	e862                	sd	s8,16(sp)
    800036a8:	e466                	sd	s9,8(sp)
    800036aa:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800036ac:	0001d797          	auipc	a5,0x1d
    800036b0:	6a07a783          	lw	a5,1696(a5) # 80020d4c <sb+0x4>
    800036b4:	10078163          	beqz	a5,800037b6 <balloc+0x124>
    800036b8:	8baa                	mv	s7,a0
    800036ba:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800036bc:	0001db17          	auipc	s6,0x1d
    800036c0:	68cb0b13          	addi	s6,s6,1676 # 80020d48 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036c4:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800036c6:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036c8:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800036ca:	6c89                	lui	s9,0x2
    800036cc:	a061                	j	80003754 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    800036ce:	974a                	add	a4,a4,s2
    800036d0:	8fd5                	or	a5,a5,a3
    800036d2:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800036d6:	854a                	mv	a0,s2
    800036d8:	00001097          	auipc	ra,0x1
    800036dc:	0ac080e7          	jalr	172(ra) # 80004784 <log_write>
        brelse(bp);
    800036e0:	854a                	mv	a0,s2
    800036e2:	00000097          	auipc	ra,0x0
    800036e6:	e1e080e7          	jalr	-482(ra) # 80003500 <brelse>
  bp = bread(dev, bno);
    800036ea:	85a6                	mv	a1,s1
    800036ec:	855e                	mv	a0,s7
    800036ee:	00000097          	auipc	ra,0x0
    800036f2:	ce2080e7          	jalr	-798(ra) # 800033d0 <bread>
    800036f6:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800036f8:	40000613          	li	a2,1024
    800036fc:	4581                	li	a1,0
    800036fe:	05850513          	addi	a0,a0,88
    80003702:	ffffd097          	auipc	ra,0xffffd
    80003706:	5e4080e7          	jalr	1508(ra) # 80000ce6 <memset>
  log_write(bp);
    8000370a:	854a                	mv	a0,s2
    8000370c:	00001097          	auipc	ra,0x1
    80003710:	078080e7          	jalr	120(ra) # 80004784 <log_write>
  brelse(bp);
    80003714:	854a                	mv	a0,s2
    80003716:	00000097          	auipc	ra,0x0
    8000371a:	dea080e7          	jalr	-534(ra) # 80003500 <brelse>
}
    8000371e:	8526                	mv	a0,s1
    80003720:	60e6                	ld	ra,88(sp)
    80003722:	6446                	ld	s0,80(sp)
    80003724:	64a6                	ld	s1,72(sp)
    80003726:	6906                	ld	s2,64(sp)
    80003728:	79e2                	ld	s3,56(sp)
    8000372a:	7a42                	ld	s4,48(sp)
    8000372c:	7aa2                	ld	s5,40(sp)
    8000372e:	7b02                	ld	s6,32(sp)
    80003730:	6be2                	ld	s7,24(sp)
    80003732:	6c42                	ld	s8,16(sp)
    80003734:	6ca2                	ld	s9,8(sp)
    80003736:	6125                	addi	sp,sp,96
    80003738:	8082                	ret
    brelse(bp);
    8000373a:	854a                	mv	a0,s2
    8000373c:	00000097          	auipc	ra,0x0
    80003740:	dc4080e7          	jalr	-572(ra) # 80003500 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003744:	015c87bb          	addw	a5,s9,s5
    80003748:	00078a9b          	sext.w	s5,a5
    8000374c:	004b2703          	lw	a4,4(s6)
    80003750:	06eaf363          	bgeu	s5,a4,800037b6 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80003754:	41fad79b          	sraiw	a5,s5,0x1f
    80003758:	0137d79b          	srliw	a5,a5,0x13
    8000375c:	015787bb          	addw	a5,a5,s5
    80003760:	40d7d79b          	sraiw	a5,a5,0xd
    80003764:	01cb2583          	lw	a1,28(s6)
    80003768:	9dbd                	addw	a1,a1,a5
    8000376a:	855e                	mv	a0,s7
    8000376c:	00000097          	auipc	ra,0x0
    80003770:	c64080e7          	jalr	-924(ra) # 800033d0 <bread>
    80003774:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003776:	004b2503          	lw	a0,4(s6)
    8000377a:	000a849b          	sext.w	s1,s5
    8000377e:	8662                	mv	a2,s8
    80003780:	faa4fde3          	bgeu	s1,a0,8000373a <balloc+0xa8>
      m = 1 << (bi % 8);
    80003784:	41f6579b          	sraiw	a5,a2,0x1f
    80003788:	01d7d69b          	srliw	a3,a5,0x1d
    8000378c:	00c6873b          	addw	a4,a3,a2
    80003790:	00777793          	andi	a5,a4,7
    80003794:	9f95                	subw	a5,a5,a3
    80003796:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000379a:	4037571b          	sraiw	a4,a4,0x3
    8000379e:	00e906b3          	add	a3,s2,a4
    800037a2:	0586c683          	lbu	a3,88(a3)
    800037a6:	00d7f5b3          	and	a1,a5,a3
    800037aa:	d195                	beqz	a1,800036ce <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037ac:	2605                	addiw	a2,a2,1
    800037ae:	2485                	addiw	s1,s1,1
    800037b0:	fd4618e3          	bne	a2,s4,80003780 <balloc+0xee>
    800037b4:	b759                	j	8000373a <balloc+0xa8>
  printf("balloc: out of blocks\n");
    800037b6:	00005517          	auipc	a0,0x5
    800037ba:	eea50513          	addi	a0,a0,-278 # 800086a0 <syscalls+0x128>
    800037be:	ffffd097          	auipc	ra,0xffffd
    800037c2:	dd0080e7          	jalr	-560(ra) # 8000058e <printf>
  return 0;
    800037c6:	4481                	li	s1,0
    800037c8:	bf99                	j	8000371e <balloc+0x8c>

00000000800037ca <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800037ca:	7179                	addi	sp,sp,-48
    800037cc:	f406                	sd	ra,40(sp)
    800037ce:	f022                	sd	s0,32(sp)
    800037d0:	ec26                	sd	s1,24(sp)
    800037d2:	e84a                	sd	s2,16(sp)
    800037d4:	e44e                	sd	s3,8(sp)
    800037d6:	e052                	sd	s4,0(sp)
    800037d8:	1800                	addi	s0,sp,48
    800037da:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800037dc:	47ad                	li	a5,11
    800037de:	02b7e763          	bltu	a5,a1,8000380c <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    800037e2:	02059493          	slli	s1,a1,0x20
    800037e6:	9081                	srli	s1,s1,0x20
    800037e8:	048a                	slli	s1,s1,0x2
    800037ea:	94aa                	add	s1,s1,a0
    800037ec:	0504a903          	lw	s2,80(s1)
    800037f0:	06091e63          	bnez	s2,8000386c <bmap+0xa2>
      addr = balloc(ip->dev);
    800037f4:	4108                	lw	a0,0(a0)
    800037f6:	00000097          	auipc	ra,0x0
    800037fa:	e9c080e7          	jalr	-356(ra) # 80003692 <balloc>
    800037fe:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003802:	06090563          	beqz	s2,8000386c <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80003806:	0524a823          	sw	s2,80(s1)
    8000380a:	a08d                	j	8000386c <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000380c:	ff45849b          	addiw	s1,a1,-12
    80003810:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003814:	0ff00793          	li	a5,255
    80003818:	08e7e563          	bltu	a5,a4,800038a2 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000381c:	08052903          	lw	s2,128(a0)
    80003820:	00091d63          	bnez	s2,8000383a <bmap+0x70>
      addr = balloc(ip->dev);
    80003824:	4108                	lw	a0,0(a0)
    80003826:	00000097          	auipc	ra,0x0
    8000382a:	e6c080e7          	jalr	-404(ra) # 80003692 <balloc>
    8000382e:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003832:	02090d63          	beqz	s2,8000386c <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003836:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000383a:	85ca                	mv	a1,s2
    8000383c:	0009a503          	lw	a0,0(s3)
    80003840:	00000097          	auipc	ra,0x0
    80003844:	b90080e7          	jalr	-1136(ra) # 800033d0 <bread>
    80003848:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000384a:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000384e:	02049593          	slli	a1,s1,0x20
    80003852:	9181                	srli	a1,a1,0x20
    80003854:	058a                	slli	a1,a1,0x2
    80003856:	00b784b3          	add	s1,a5,a1
    8000385a:	0004a903          	lw	s2,0(s1)
    8000385e:	02090063          	beqz	s2,8000387e <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003862:	8552                	mv	a0,s4
    80003864:	00000097          	auipc	ra,0x0
    80003868:	c9c080e7          	jalr	-868(ra) # 80003500 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000386c:	854a                	mv	a0,s2
    8000386e:	70a2                	ld	ra,40(sp)
    80003870:	7402                	ld	s0,32(sp)
    80003872:	64e2                	ld	s1,24(sp)
    80003874:	6942                	ld	s2,16(sp)
    80003876:	69a2                	ld	s3,8(sp)
    80003878:	6a02                	ld	s4,0(sp)
    8000387a:	6145                	addi	sp,sp,48
    8000387c:	8082                	ret
      addr = balloc(ip->dev);
    8000387e:	0009a503          	lw	a0,0(s3)
    80003882:	00000097          	auipc	ra,0x0
    80003886:	e10080e7          	jalr	-496(ra) # 80003692 <balloc>
    8000388a:	0005091b          	sext.w	s2,a0
      if(addr){
    8000388e:	fc090ae3          	beqz	s2,80003862 <bmap+0x98>
        a[bn] = addr;
    80003892:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003896:	8552                	mv	a0,s4
    80003898:	00001097          	auipc	ra,0x1
    8000389c:	eec080e7          	jalr	-276(ra) # 80004784 <log_write>
    800038a0:	b7c9                	j	80003862 <bmap+0x98>
  panic("bmap: out of range");
    800038a2:	00005517          	auipc	a0,0x5
    800038a6:	e1650513          	addi	a0,a0,-490 # 800086b8 <syscalls+0x140>
    800038aa:	ffffd097          	auipc	ra,0xffffd
    800038ae:	c9a080e7          	jalr	-870(ra) # 80000544 <panic>

00000000800038b2 <iget>:
{
    800038b2:	7179                	addi	sp,sp,-48
    800038b4:	f406                	sd	ra,40(sp)
    800038b6:	f022                	sd	s0,32(sp)
    800038b8:	ec26                	sd	s1,24(sp)
    800038ba:	e84a                	sd	s2,16(sp)
    800038bc:	e44e                	sd	s3,8(sp)
    800038be:	e052                	sd	s4,0(sp)
    800038c0:	1800                	addi	s0,sp,48
    800038c2:	89aa                	mv	s3,a0
    800038c4:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800038c6:	0001d517          	auipc	a0,0x1d
    800038ca:	4a250513          	addi	a0,a0,1186 # 80020d68 <itable>
    800038ce:	ffffd097          	auipc	ra,0xffffd
    800038d2:	31c080e7          	jalr	796(ra) # 80000bea <acquire>
  empty = 0;
    800038d6:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800038d8:	0001d497          	auipc	s1,0x1d
    800038dc:	4a848493          	addi	s1,s1,1192 # 80020d80 <itable+0x18>
    800038e0:	0001f697          	auipc	a3,0x1f
    800038e4:	f3068693          	addi	a3,a3,-208 # 80022810 <log>
    800038e8:	a039                	j	800038f6 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800038ea:	02090b63          	beqz	s2,80003920 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800038ee:	08848493          	addi	s1,s1,136
    800038f2:	02d48a63          	beq	s1,a3,80003926 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800038f6:	449c                	lw	a5,8(s1)
    800038f8:	fef059e3          	blez	a5,800038ea <iget+0x38>
    800038fc:	4098                	lw	a4,0(s1)
    800038fe:	ff3716e3          	bne	a4,s3,800038ea <iget+0x38>
    80003902:	40d8                	lw	a4,4(s1)
    80003904:	ff4713e3          	bne	a4,s4,800038ea <iget+0x38>
      ip->ref++;
    80003908:	2785                	addiw	a5,a5,1
    8000390a:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000390c:	0001d517          	auipc	a0,0x1d
    80003910:	45c50513          	addi	a0,a0,1116 # 80020d68 <itable>
    80003914:	ffffd097          	auipc	ra,0xffffd
    80003918:	38a080e7          	jalr	906(ra) # 80000c9e <release>
      return ip;
    8000391c:	8926                	mv	s2,s1
    8000391e:	a03d                	j	8000394c <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003920:	f7f9                	bnez	a5,800038ee <iget+0x3c>
    80003922:	8926                	mv	s2,s1
    80003924:	b7e9                	j	800038ee <iget+0x3c>
  if(empty == 0)
    80003926:	02090c63          	beqz	s2,8000395e <iget+0xac>
  ip->dev = dev;
    8000392a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000392e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003932:	4785                	li	a5,1
    80003934:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003938:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000393c:	0001d517          	auipc	a0,0x1d
    80003940:	42c50513          	addi	a0,a0,1068 # 80020d68 <itable>
    80003944:	ffffd097          	auipc	ra,0xffffd
    80003948:	35a080e7          	jalr	858(ra) # 80000c9e <release>
}
    8000394c:	854a                	mv	a0,s2
    8000394e:	70a2                	ld	ra,40(sp)
    80003950:	7402                	ld	s0,32(sp)
    80003952:	64e2                	ld	s1,24(sp)
    80003954:	6942                	ld	s2,16(sp)
    80003956:	69a2                	ld	s3,8(sp)
    80003958:	6a02                	ld	s4,0(sp)
    8000395a:	6145                	addi	sp,sp,48
    8000395c:	8082                	ret
    panic("iget: no inodes");
    8000395e:	00005517          	auipc	a0,0x5
    80003962:	d7250513          	addi	a0,a0,-654 # 800086d0 <syscalls+0x158>
    80003966:	ffffd097          	auipc	ra,0xffffd
    8000396a:	bde080e7          	jalr	-1058(ra) # 80000544 <panic>

000000008000396e <fsinit>:
fsinit(int dev) {
    8000396e:	7179                	addi	sp,sp,-48
    80003970:	f406                	sd	ra,40(sp)
    80003972:	f022                	sd	s0,32(sp)
    80003974:	ec26                	sd	s1,24(sp)
    80003976:	e84a                	sd	s2,16(sp)
    80003978:	e44e                	sd	s3,8(sp)
    8000397a:	1800                	addi	s0,sp,48
    8000397c:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000397e:	4585                	li	a1,1
    80003980:	00000097          	auipc	ra,0x0
    80003984:	a50080e7          	jalr	-1456(ra) # 800033d0 <bread>
    80003988:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000398a:	0001d997          	auipc	s3,0x1d
    8000398e:	3be98993          	addi	s3,s3,958 # 80020d48 <sb>
    80003992:	02000613          	li	a2,32
    80003996:	05850593          	addi	a1,a0,88
    8000399a:	854e                	mv	a0,s3
    8000399c:	ffffd097          	auipc	ra,0xffffd
    800039a0:	3aa080e7          	jalr	938(ra) # 80000d46 <memmove>
  brelse(bp);
    800039a4:	8526                	mv	a0,s1
    800039a6:	00000097          	auipc	ra,0x0
    800039aa:	b5a080e7          	jalr	-1190(ra) # 80003500 <brelse>
  if(sb.magic != FSMAGIC)
    800039ae:	0009a703          	lw	a4,0(s3)
    800039b2:	102037b7          	lui	a5,0x10203
    800039b6:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800039ba:	02f71263          	bne	a4,a5,800039de <fsinit+0x70>
  initlog(dev, &sb);
    800039be:	0001d597          	auipc	a1,0x1d
    800039c2:	38a58593          	addi	a1,a1,906 # 80020d48 <sb>
    800039c6:	854a                	mv	a0,s2
    800039c8:	00001097          	auipc	ra,0x1
    800039cc:	b40080e7          	jalr	-1216(ra) # 80004508 <initlog>
}
    800039d0:	70a2                	ld	ra,40(sp)
    800039d2:	7402                	ld	s0,32(sp)
    800039d4:	64e2                	ld	s1,24(sp)
    800039d6:	6942                	ld	s2,16(sp)
    800039d8:	69a2                	ld	s3,8(sp)
    800039da:	6145                	addi	sp,sp,48
    800039dc:	8082                	ret
    panic("invalid file system");
    800039de:	00005517          	auipc	a0,0x5
    800039e2:	d0250513          	addi	a0,a0,-766 # 800086e0 <syscalls+0x168>
    800039e6:	ffffd097          	auipc	ra,0xffffd
    800039ea:	b5e080e7          	jalr	-1186(ra) # 80000544 <panic>

00000000800039ee <iinit>:
{
    800039ee:	7179                	addi	sp,sp,-48
    800039f0:	f406                	sd	ra,40(sp)
    800039f2:	f022                	sd	s0,32(sp)
    800039f4:	ec26                	sd	s1,24(sp)
    800039f6:	e84a                	sd	s2,16(sp)
    800039f8:	e44e                	sd	s3,8(sp)
    800039fa:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800039fc:	00005597          	auipc	a1,0x5
    80003a00:	cfc58593          	addi	a1,a1,-772 # 800086f8 <syscalls+0x180>
    80003a04:	0001d517          	auipc	a0,0x1d
    80003a08:	36450513          	addi	a0,a0,868 # 80020d68 <itable>
    80003a0c:	ffffd097          	auipc	ra,0xffffd
    80003a10:	14e080e7          	jalr	334(ra) # 80000b5a <initlock>
  for(i = 0; i < NINODE; i++) {
    80003a14:	0001d497          	auipc	s1,0x1d
    80003a18:	37c48493          	addi	s1,s1,892 # 80020d90 <itable+0x28>
    80003a1c:	0001f997          	auipc	s3,0x1f
    80003a20:	e0498993          	addi	s3,s3,-508 # 80022820 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003a24:	00005917          	auipc	s2,0x5
    80003a28:	cdc90913          	addi	s2,s2,-804 # 80008700 <syscalls+0x188>
    80003a2c:	85ca                	mv	a1,s2
    80003a2e:	8526                	mv	a0,s1
    80003a30:	00001097          	auipc	ra,0x1
    80003a34:	e3a080e7          	jalr	-454(ra) # 8000486a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003a38:	08848493          	addi	s1,s1,136
    80003a3c:	ff3498e3          	bne	s1,s3,80003a2c <iinit+0x3e>
}
    80003a40:	70a2                	ld	ra,40(sp)
    80003a42:	7402                	ld	s0,32(sp)
    80003a44:	64e2                	ld	s1,24(sp)
    80003a46:	6942                	ld	s2,16(sp)
    80003a48:	69a2                	ld	s3,8(sp)
    80003a4a:	6145                	addi	sp,sp,48
    80003a4c:	8082                	ret

0000000080003a4e <ialloc>:
{
    80003a4e:	715d                	addi	sp,sp,-80
    80003a50:	e486                	sd	ra,72(sp)
    80003a52:	e0a2                	sd	s0,64(sp)
    80003a54:	fc26                	sd	s1,56(sp)
    80003a56:	f84a                	sd	s2,48(sp)
    80003a58:	f44e                	sd	s3,40(sp)
    80003a5a:	f052                	sd	s4,32(sp)
    80003a5c:	ec56                	sd	s5,24(sp)
    80003a5e:	e85a                	sd	s6,16(sp)
    80003a60:	e45e                	sd	s7,8(sp)
    80003a62:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003a64:	0001d717          	auipc	a4,0x1d
    80003a68:	2f072703          	lw	a4,752(a4) # 80020d54 <sb+0xc>
    80003a6c:	4785                	li	a5,1
    80003a6e:	04e7fa63          	bgeu	a5,a4,80003ac2 <ialloc+0x74>
    80003a72:	8aaa                	mv	s5,a0
    80003a74:	8bae                	mv	s7,a1
    80003a76:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003a78:	0001da17          	auipc	s4,0x1d
    80003a7c:	2d0a0a13          	addi	s4,s4,720 # 80020d48 <sb>
    80003a80:	00048b1b          	sext.w	s6,s1
    80003a84:	0044d593          	srli	a1,s1,0x4
    80003a88:	018a2783          	lw	a5,24(s4)
    80003a8c:	9dbd                	addw	a1,a1,a5
    80003a8e:	8556                	mv	a0,s5
    80003a90:	00000097          	auipc	ra,0x0
    80003a94:	940080e7          	jalr	-1728(ra) # 800033d0 <bread>
    80003a98:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003a9a:	05850993          	addi	s3,a0,88
    80003a9e:	00f4f793          	andi	a5,s1,15
    80003aa2:	079a                	slli	a5,a5,0x6
    80003aa4:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003aa6:	00099783          	lh	a5,0(s3)
    80003aaa:	c3a1                	beqz	a5,80003aea <ialloc+0x9c>
    brelse(bp);
    80003aac:	00000097          	auipc	ra,0x0
    80003ab0:	a54080e7          	jalr	-1452(ra) # 80003500 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003ab4:	0485                	addi	s1,s1,1
    80003ab6:	00ca2703          	lw	a4,12(s4)
    80003aba:	0004879b          	sext.w	a5,s1
    80003abe:	fce7e1e3          	bltu	a5,a4,80003a80 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003ac2:	00005517          	auipc	a0,0x5
    80003ac6:	c4650513          	addi	a0,a0,-954 # 80008708 <syscalls+0x190>
    80003aca:	ffffd097          	auipc	ra,0xffffd
    80003ace:	ac4080e7          	jalr	-1340(ra) # 8000058e <printf>
  return 0;
    80003ad2:	4501                	li	a0,0
}
    80003ad4:	60a6                	ld	ra,72(sp)
    80003ad6:	6406                	ld	s0,64(sp)
    80003ad8:	74e2                	ld	s1,56(sp)
    80003ada:	7942                	ld	s2,48(sp)
    80003adc:	79a2                	ld	s3,40(sp)
    80003ade:	7a02                	ld	s4,32(sp)
    80003ae0:	6ae2                	ld	s5,24(sp)
    80003ae2:	6b42                	ld	s6,16(sp)
    80003ae4:	6ba2                	ld	s7,8(sp)
    80003ae6:	6161                	addi	sp,sp,80
    80003ae8:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003aea:	04000613          	li	a2,64
    80003aee:	4581                	li	a1,0
    80003af0:	854e                	mv	a0,s3
    80003af2:	ffffd097          	auipc	ra,0xffffd
    80003af6:	1f4080e7          	jalr	500(ra) # 80000ce6 <memset>
      dip->type = type;
    80003afa:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003afe:	854a                	mv	a0,s2
    80003b00:	00001097          	auipc	ra,0x1
    80003b04:	c84080e7          	jalr	-892(ra) # 80004784 <log_write>
      brelse(bp);
    80003b08:	854a                	mv	a0,s2
    80003b0a:	00000097          	auipc	ra,0x0
    80003b0e:	9f6080e7          	jalr	-1546(ra) # 80003500 <brelse>
      return iget(dev, inum);
    80003b12:	85da                	mv	a1,s6
    80003b14:	8556                	mv	a0,s5
    80003b16:	00000097          	auipc	ra,0x0
    80003b1a:	d9c080e7          	jalr	-612(ra) # 800038b2 <iget>
    80003b1e:	bf5d                	j	80003ad4 <ialloc+0x86>

0000000080003b20 <iupdate>:
{
    80003b20:	1101                	addi	sp,sp,-32
    80003b22:	ec06                	sd	ra,24(sp)
    80003b24:	e822                	sd	s0,16(sp)
    80003b26:	e426                	sd	s1,8(sp)
    80003b28:	e04a                	sd	s2,0(sp)
    80003b2a:	1000                	addi	s0,sp,32
    80003b2c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b2e:	415c                	lw	a5,4(a0)
    80003b30:	0047d79b          	srliw	a5,a5,0x4
    80003b34:	0001d597          	auipc	a1,0x1d
    80003b38:	22c5a583          	lw	a1,556(a1) # 80020d60 <sb+0x18>
    80003b3c:	9dbd                	addw	a1,a1,a5
    80003b3e:	4108                	lw	a0,0(a0)
    80003b40:	00000097          	auipc	ra,0x0
    80003b44:	890080e7          	jalr	-1904(ra) # 800033d0 <bread>
    80003b48:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b4a:	05850793          	addi	a5,a0,88
    80003b4e:	40c8                	lw	a0,4(s1)
    80003b50:	893d                	andi	a0,a0,15
    80003b52:	051a                	slli	a0,a0,0x6
    80003b54:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003b56:	04449703          	lh	a4,68(s1)
    80003b5a:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003b5e:	04649703          	lh	a4,70(s1)
    80003b62:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003b66:	04849703          	lh	a4,72(s1)
    80003b6a:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003b6e:	04a49703          	lh	a4,74(s1)
    80003b72:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003b76:	44f8                	lw	a4,76(s1)
    80003b78:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003b7a:	03400613          	li	a2,52
    80003b7e:	05048593          	addi	a1,s1,80
    80003b82:	0531                	addi	a0,a0,12
    80003b84:	ffffd097          	auipc	ra,0xffffd
    80003b88:	1c2080e7          	jalr	450(ra) # 80000d46 <memmove>
  log_write(bp);
    80003b8c:	854a                	mv	a0,s2
    80003b8e:	00001097          	auipc	ra,0x1
    80003b92:	bf6080e7          	jalr	-1034(ra) # 80004784 <log_write>
  brelse(bp);
    80003b96:	854a                	mv	a0,s2
    80003b98:	00000097          	auipc	ra,0x0
    80003b9c:	968080e7          	jalr	-1688(ra) # 80003500 <brelse>
}
    80003ba0:	60e2                	ld	ra,24(sp)
    80003ba2:	6442                	ld	s0,16(sp)
    80003ba4:	64a2                	ld	s1,8(sp)
    80003ba6:	6902                	ld	s2,0(sp)
    80003ba8:	6105                	addi	sp,sp,32
    80003baa:	8082                	ret

0000000080003bac <idup>:
{
    80003bac:	1101                	addi	sp,sp,-32
    80003bae:	ec06                	sd	ra,24(sp)
    80003bb0:	e822                	sd	s0,16(sp)
    80003bb2:	e426                	sd	s1,8(sp)
    80003bb4:	1000                	addi	s0,sp,32
    80003bb6:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003bb8:	0001d517          	auipc	a0,0x1d
    80003bbc:	1b050513          	addi	a0,a0,432 # 80020d68 <itable>
    80003bc0:	ffffd097          	auipc	ra,0xffffd
    80003bc4:	02a080e7          	jalr	42(ra) # 80000bea <acquire>
  ip->ref++;
    80003bc8:	449c                	lw	a5,8(s1)
    80003bca:	2785                	addiw	a5,a5,1
    80003bcc:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003bce:	0001d517          	auipc	a0,0x1d
    80003bd2:	19a50513          	addi	a0,a0,410 # 80020d68 <itable>
    80003bd6:	ffffd097          	auipc	ra,0xffffd
    80003bda:	0c8080e7          	jalr	200(ra) # 80000c9e <release>
}
    80003bde:	8526                	mv	a0,s1
    80003be0:	60e2                	ld	ra,24(sp)
    80003be2:	6442                	ld	s0,16(sp)
    80003be4:	64a2                	ld	s1,8(sp)
    80003be6:	6105                	addi	sp,sp,32
    80003be8:	8082                	ret

0000000080003bea <ilock>:
{
    80003bea:	1101                	addi	sp,sp,-32
    80003bec:	ec06                	sd	ra,24(sp)
    80003bee:	e822                	sd	s0,16(sp)
    80003bf0:	e426                	sd	s1,8(sp)
    80003bf2:	e04a                	sd	s2,0(sp)
    80003bf4:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003bf6:	c115                	beqz	a0,80003c1a <ilock+0x30>
    80003bf8:	84aa                	mv	s1,a0
    80003bfa:	451c                	lw	a5,8(a0)
    80003bfc:	00f05f63          	blez	a5,80003c1a <ilock+0x30>
  acquiresleep(&ip->lock);
    80003c00:	0541                	addi	a0,a0,16
    80003c02:	00001097          	auipc	ra,0x1
    80003c06:	ca2080e7          	jalr	-862(ra) # 800048a4 <acquiresleep>
  if(ip->valid == 0){
    80003c0a:	40bc                	lw	a5,64(s1)
    80003c0c:	cf99                	beqz	a5,80003c2a <ilock+0x40>
}
    80003c0e:	60e2                	ld	ra,24(sp)
    80003c10:	6442                	ld	s0,16(sp)
    80003c12:	64a2                	ld	s1,8(sp)
    80003c14:	6902                	ld	s2,0(sp)
    80003c16:	6105                	addi	sp,sp,32
    80003c18:	8082                	ret
    panic("ilock");
    80003c1a:	00005517          	auipc	a0,0x5
    80003c1e:	b0650513          	addi	a0,a0,-1274 # 80008720 <syscalls+0x1a8>
    80003c22:	ffffd097          	auipc	ra,0xffffd
    80003c26:	922080e7          	jalr	-1758(ra) # 80000544 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003c2a:	40dc                	lw	a5,4(s1)
    80003c2c:	0047d79b          	srliw	a5,a5,0x4
    80003c30:	0001d597          	auipc	a1,0x1d
    80003c34:	1305a583          	lw	a1,304(a1) # 80020d60 <sb+0x18>
    80003c38:	9dbd                	addw	a1,a1,a5
    80003c3a:	4088                	lw	a0,0(s1)
    80003c3c:	fffff097          	auipc	ra,0xfffff
    80003c40:	794080e7          	jalr	1940(ra) # 800033d0 <bread>
    80003c44:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c46:	05850593          	addi	a1,a0,88
    80003c4a:	40dc                	lw	a5,4(s1)
    80003c4c:	8bbd                	andi	a5,a5,15
    80003c4e:	079a                	slli	a5,a5,0x6
    80003c50:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003c52:	00059783          	lh	a5,0(a1)
    80003c56:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003c5a:	00259783          	lh	a5,2(a1)
    80003c5e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003c62:	00459783          	lh	a5,4(a1)
    80003c66:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003c6a:	00659783          	lh	a5,6(a1)
    80003c6e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003c72:	459c                	lw	a5,8(a1)
    80003c74:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003c76:	03400613          	li	a2,52
    80003c7a:	05b1                	addi	a1,a1,12
    80003c7c:	05048513          	addi	a0,s1,80
    80003c80:	ffffd097          	auipc	ra,0xffffd
    80003c84:	0c6080e7          	jalr	198(ra) # 80000d46 <memmove>
    brelse(bp);
    80003c88:	854a                	mv	a0,s2
    80003c8a:	00000097          	auipc	ra,0x0
    80003c8e:	876080e7          	jalr	-1930(ra) # 80003500 <brelse>
    ip->valid = 1;
    80003c92:	4785                	li	a5,1
    80003c94:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003c96:	04449783          	lh	a5,68(s1)
    80003c9a:	fbb5                	bnez	a5,80003c0e <ilock+0x24>
      panic("ilock: no type");
    80003c9c:	00005517          	auipc	a0,0x5
    80003ca0:	a8c50513          	addi	a0,a0,-1396 # 80008728 <syscalls+0x1b0>
    80003ca4:	ffffd097          	auipc	ra,0xffffd
    80003ca8:	8a0080e7          	jalr	-1888(ra) # 80000544 <panic>

0000000080003cac <iunlock>:
{
    80003cac:	1101                	addi	sp,sp,-32
    80003cae:	ec06                	sd	ra,24(sp)
    80003cb0:	e822                	sd	s0,16(sp)
    80003cb2:	e426                	sd	s1,8(sp)
    80003cb4:	e04a                	sd	s2,0(sp)
    80003cb6:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003cb8:	c905                	beqz	a0,80003ce8 <iunlock+0x3c>
    80003cba:	84aa                	mv	s1,a0
    80003cbc:	01050913          	addi	s2,a0,16
    80003cc0:	854a                	mv	a0,s2
    80003cc2:	00001097          	auipc	ra,0x1
    80003cc6:	c7c080e7          	jalr	-900(ra) # 8000493e <holdingsleep>
    80003cca:	cd19                	beqz	a0,80003ce8 <iunlock+0x3c>
    80003ccc:	449c                	lw	a5,8(s1)
    80003cce:	00f05d63          	blez	a5,80003ce8 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003cd2:	854a                	mv	a0,s2
    80003cd4:	00001097          	auipc	ra,0x1
    80003cd8:	c26080e7          	jalr	-986(ra) # 800048fa <releasesleep>
}
    80003cdc:	60e2                	ld	ra,24(sp)
    80003cde:	6442                	ld	s0,16(sp)
    80003ce0:	64a2                	ld	s1,8(sp)
    80003ce2:	6902                	ld	s2,0(sp)
    80003ce4:	6105                	addi	sp,sp,32
    80003ce6:	8082                	ret
    panic("iunlock");
    80003ce8:	00005517          	auipc	a0,0x5
    80003cec:	a5050513          	addi	a0,a0,-1456 # 80008738 <syscalls+0x1c0>
    80003cf0:	ffffd097          	auipc	ra,0xffffd
    80003cf4:	854080e7          	jalr	-1964(ra) # 80000544 <panic>

0000000080003cf8 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003cf8:	7179                	addi	sp,sp,-48
    80003cfa:	f406                	sd	ra,40(sp)
    80003cfc:	f022                	sd	s0,32(sp)
    80003cfe:	ec26                	sd	s1,24(sp)
    80003d00:	e84a                	sd	s2,16(sp)
    80003d02:	e44e                	sd	s3,8(sp)
    80003d04:	e052                	sd	s4,0(sp)
    80003d06:	1800                	addi	s0,sp,48
    80003d08:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003d0a:	05050493          	addi	s1,a0,80
    80003d0e:	08050913          	addi	s2,a0,128
    80003d12:	a021                	j	80003d1a <itrunc+0x22>
    80003d14:	0491                	addi	s1,s1,4
    80003d16:	01248d63          	beq	s1,s2,80003d30 <itrunc+0x38>
    if(ip->addrs[i]){
    80003d1a:	408c                	lw	a1,0(s1)
    80003d1c:	dde5                	beqz	a1,80003d14 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003d1e:	0009a503          	lw	a0,0(s3)
    80003d22:	00000097          	auipc	ra,0x0
    80003d26:	8f4080e7          	jalr	-1804(ra) # 80003616 <bfree>
      ip->addrs[i] = 0;
    80003d2a:	0004a023          	sw	zero,0(s1)
    80003d2e:	b7dd                	j	80003d14 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003d30:	0809a583          	lw	a1,128(s3)
    80003d34:	e185                	bnez	a1,80003d54 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003d36:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003d3a:	854e                	mv	a0,s3
    80003d3c:	00000097          	auipc	ra,0x0
    80003d40:	de4080e7          	jalr	-540(ra) # 80003b20 <iupdate>
}
    80003d44:	70a2                	ld	ra,40(sp)
    80003d46:	7402                	ld	s0,32(sp)
    80003d48:	64e2                	ld	s1,24(sp)
    80003d4a:	6942                	ld	s2,16(sp)
    80003d4c:	69a2                	ld	s3,8(sp)
    80003d4e:	6a02                	ld	s4,0(sp)
    80003d50:	6145                	addi	sp,sp,48
    80003d52:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003d54:	0009a503          	lw	a0,0(s3)
    80003d58:	fffff097          	auipc	ra,0xfffff
    80003d5c:	678080e7          	jalr	1656(ra) # 800033d0 <bread>
    80003d60:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003d62:	05850493          	addi	s1,a0,88
    80003d66:	45850913          	addi	s2,a0,1112
    80003d6a:	a811                	j	80003d7e <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003d6c:	0009a503          	lw	a0,0(s3)
    80003d70:	00000097          	auipc	ra,0x0
    80003d74:	8a6080e7          	jalr	-1882(ra) # 80003616 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003d78:	0491                	addi	s1,s1,4
    80003d7a:	01248563          	beq	s1,s2,80003d84 <itrunc+0x8c>
      if(a[j])
    80003d7e:	408c                	lw	a1,0(s1)
    80003d80:	dde5                	beqz	a1,80003d78 <itrunc+0x80>
    80003d82:	b7ed                	j	80003d6c <itrunc+0x74>
    brelse(bp);
    80003d84:	8552                	mv	a0,s4
    80003d86:	fffff097          	auipc	ra,0xfffff
    80003d8a:	77a080e7          	jalr	1914(ra) # 80003500 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003d8e:	0809a583          	lw	a1,128(s3)
    80003d92:	0009a503          	lw	a0,0(s3)
    80003d96:	00000097          	auipc	ra,0x0
    80003d9a:	880080e7          	jalr	-1920(ra) # 80003616 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003d9e:	0809a023          	sw	zero,128(s3)
    80003da2:	bf51                	j	80003d36 <itrunc+0x3e>

0000000080003da4 <iput>:
{
    80003da4:	1101                	addi	sp,sp,-32
    80003da6:	ec06                	sd	ra,24(sp)
    80003da8:	e822                	sd	s0,16(sp)
    80003daa:	e426                	sd	s1,8(sp)
    80003dac:	e04a                	sd	s2,0(sp)
    80003dae:	1000                	addi	s0,sp,32
    80003db0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003db2:	0001d517          	auipc	a0,0x1d
    80003db6:	fb650513          	addi	a0,a0,-74 # 80020d68 <itable>
    80003dba:	ffffd097          	auipc	ra,0xffffd
    80003dbe:	e30080e7          	jalr	-464(ra) # 80000bea <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003dc2:	4498                	lw	a4,8(s1)
    80003dc4:	4785                	li	a5,1
    80003dc6:	02f70363          	beq	a4,a5,80003dec <iput+0x48>
  ip->ref--;
    80003dca:	449c                	lw	a5,8(s1)
    80003dcc:	37fd                	addiw	a5,a5,-1
    80003dce:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003dd0:	0001d517          	auipc	a0,0x1d
    80003dd4:	f9850513          	addi	a0,a0,-104 # 80020d68 <itable>
    80003dd8:	ffffd097          	auipc	ra,0xffffd
    80003ddc:	ec6080e7          	jalr	-314(ra) # 80000c9e <release>
}
    80003de0:	60e2                	ld	ra,24(sp)
    80003de2:	6442                	ld	s0,16(sp)
    80003de4:	64a2                	ld	s1,8(sp)
    80003de6:	6902                	ld	s2,0(sp)
    80003de8:	6105                	addi	sp,sp,32
    80003dea:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003dec:	40bc                	lw	a5,64(s1)
    80003dee:	dff1                	beqz	a5,80003dca <iput+0x26>
    80003df0:	04a49783          	lh	a5,74(s1)
    80003df4:	fbf9                	bnez	a5,80003dca <iput+0x26>
    acquiresleep(&ip->lock);
    80003df6:	01048913          	addi	s2,s1,16
    80003dfa:	854a                	mv	a0,s2
    80003dfc:	00001097          	auipc	ra,0x1
    80003e00:	aa8080e7          	jalr	-1368(ra) # 800048a4 <acquiresleep>
    release(&itable.lock);
    80003e04:	0001d517          	auipc	a0,0x1d
    80003e08:	f6450513          	addi	a0,a0,-156 # 80020d68 <itable>
    80003e0c:	ffffd097          	auipc	ra,0xffffd
    80003e10:	e92080e7          	jalr	-366(ra) # 80000c9e <release>
    itrunc(ip);
    80003e14:	8526                	mv	a0,s1
    80003e16:	00000097          	auipc	ra,0x0
    80003e1a:	ee2080e7          	jalr	-286(ra) # 80003cf8 <itrunc>
    ip->type = 0;
    80003e1e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003e22:	8526                	mv	a0,s1
    80003e24:	00000097          	auipc	ra,0x0
    80003e28:	cfc080e7          	jalr	-772(ra) # 80003b20 <iupdate>
    ip->valid = 0;
    80003e2c:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003e30:	854a                	mv	a0,s2
    80003e32:	00001097          	auipc	ra,0x1
    80003e36:	ac8080e7          	jalr	-1336(ra) # 800048fa <releasesleep>
    acquire(&itable.lock);
    80003e3a:	0001d517          	auipc	a0,0x1d
    80003e3e:	f2e50513          	addi	a0,a0,-210 # 80020d68 <itable>
    80003e42:	ffffd097          	auipc	ra,0xffffd
    80003e46:	da8080e7          	jalr	-600(ra) # 80000bea <acquire>
    80003e4a:	b741                	j	80003dca <iput+0x26>

0000000080003e4c <iunlockput>:
{
    80003e4c:	1101                	addi	sp,sp,-32
    80003e4e:	ec06                	sd	ra,24(sp)
    80003e50:	e822                	sd	s0,16(sp)
    80003e52:	e426                	sd	s1,8(sp)
    80003e54:	1000                	addi	s0,sp,32
    80003e56:	84aa                	mv	s1,a0
  iunlock(ip);
    80003e58:	00000097          	auipc	ra,0x0
    80003e5c:	e54080e7          	jalr	-428(ra) # 80003cac <iunlock>
  iput(ip);
    80003e60:	8526                	mv	a0,s1
    80003e62:	00000097          	auipc	ra,0x0
    80003e66:	f42080e7          	jalr	-190(ra) # 80003da4 <iput>
}
    80003e6a:	60e2                	ld	ra,24(sp)
    80003e6c:	6442                	ld	s0,16(sp)
    80003e6e:	64a2                	ld	s1,8(sp)
    80003e70:	6105                	addi	sp,sp,32
    80003e72:	8082                	ret

0000000080003e74 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003e74:	1141                	addi	sp,sp,-16
    80003e76:	e422                	sd	s0,8(sp)
    80003e78:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003e7a:	411c                	lw	a5,0(a0)
    80003e7c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003e7e:	415c                	lw	a5,4(a0)
    80003e80:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003e82:	04451783          	lh	a5,68(a0)
    80003e86:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003e8a:	04a51783          	lh	a5,74(a0)
    80003e8e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003e92:	04c56783          	lwu	a5,76(a0)
    80003e96:	e99c                	sd	a5,16(a1)
}
    80003e98:	6422                	ld	s0,8(sp)
    80003e9a:	0141                	addi	sp,sp,16
    80003e9c:	8082                	ret

0000000080003e9e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003e9e:	457c                	lw	a5,76(a0)
    80003ea0:	0ed7e963          	bltu	a5,a3,80003f92 <readi+0xf4>
{
    80003ea4:	7159                	addi	sp,sp,-112
    80003ea6:	f486                	sd	ra,104(sp)
    80003ea8:	f0a2                	sd	s0,96(sp)
    80003eaa:	eca6                	sd	s1,88(sp)
    80003eac:	e8ca                	sd	s2,80(sp)
    80003eae:	e4ce                	sd	s3,72(sp)
    80003eb0:	e0d2                	sd	s4,64(sp)
    80003eb2:	fc56                	sd	s5,56(sp)
    80003eb4:	f85a                	sd	s6,48(sp)
    80003eb6:	f45e                	sd	s7,40(sp)
    80003eb8:	f062                	sd	s8,32(sp)
    80003eba:	ec66                	sd	s9,24(sp)
    80003ebc:	e86a                	sd	s10,16(sp)
    80003ebe:	e46e                	sd	s11,8(sp)
    80003ec0:	1880                	addi	s0,sp,112
    80003ec2:	8b2a                	mv	s6,a0
    80003ec4:	8bae                	mv	s7,a1
    80003ec6:	8a32                	mv	s4,a2
    80003ec8:	84b6                	mv	s1,a3
    80003eca:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003ecc:	9f35                	addw	a4,a4,a3
    return 0;
    80003ece:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003ed0:	0ad76063          	bltu	a4,a3,80003f70 <readi+0xd2>
  if(off + n > ip->size)
    80003ed4:	00e7f463          	bgeu	a5,a4,80003edc <readi+0x3e>
    n = ip->size - off;
    80003ed8:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003edc:	0a0a8963          	beqz	s5,80003f8e <readi+0xf0>
    80003ee0:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ee2:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003ee6:	5c7d                	li	s8,-1
    80003ee8:	a82d                	j	80003f22 <readi+0x84>
    80003eea:	020d1d93          	slli	s11,s10,0x20
    80003eee:	020ddd93          	srli	s11,s11,0x20
    80003ef2:	05890613          	addi	a2,s2,88
    80003ef6:	86ee                	mv	a3,s11
    80003ef8:	963a                	add	a2,a2,a4
    80003efa:	85d2                	mv	a1,s4
    80003efc:	855e                	mv	a0,s7
    80003efe:	fffff097          	auipc	ra,0xfffff
    80003f02:	854080e7          	jalr	-1964(ra) # 80002752 <either_copyout>
    80003f06:	05850d63          	beq	a0,s8,80003f60 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003f0a:	854a                	mv	a0,s2
    80003f0c:	fffff097          	auipc	ra,0xfffff
    80003f10:	5f4080e7          	jalr	1524(ra) # 80003500 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f14:	013d09bb          	addw	s3,s10,s3
    80003f18:	009d04bb          	addw	s1,s10,s1
    80003f1c:	9a6e                	add	s4,s4,s11
    80003f1e:	0559f763          	bgeu	s3,s5,80003f6c <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003f22:	00a4d59b          	srliw	a1,s1,0xa
    80003f26:	855a                	mv	a0,s6
    80003f28:	00000097          	auipc	ra,0x0
    80003f2c:	8a2080e7          	jalr	-1886(ra) # 800037ca <bmap>
    80003f30:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003f34:	cd85                	beqz	a1,80003f6c <readi+0xce>
    bp = bread(ip->dev, addr);
    80003f36:	000b2503          	lw	a0,0(s6)
    80003f3a:	fffff097          	auipc	ra,0xfffff
    80003f3e:	496080e7          	jalr	1174(ra) # 800033d0 <bread>
    80003f42:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f44:	3ff4f713          	andi	a4,s1,1023
    80003f48:	40ec87bb          	subw	a5,s9,a4
    80003f4c:	413a86bb          	subw	a3,s5,s3
    80003f50:	8d3e                	mv	s10,a5
    80003f52:	2781                	sext.w	a5,a5
    80003f54:	0006861b          	sext.w	a2,a3
    80003f58:	f8f679e3          	bgeu	a2,a5,80003eea <readi+0x4c>
    80003f5c:	8d36                	mv	s10,a3
    80003f5e:	b771                	j	80003eea <readi+0x4c>
      brelse(bp);
    80003f60:	854a                	mv	a0,s2
    80003f62:	fffff097          	auipc	ra,0xfffff
    80003f66:	59e080e7          	jalr	1438(ra) # 80003500 <brelse>
      tot = -1;
    80003f6a:	59fd                	li	s3,-1
  }
  return tot;
    80003f6c:	0009851b          	sext.w	a0,s3
}
    80003f70:	70a6                	ld	ra,104(sp)
    80003f72:	7406                	ld	s0,96(sp)
    80003f74:	64e6                	ld	s1,88(sp)
    80003f76:	6946                	ld	s2,80(sp)
    80003f78:	69a6                	ld	s3,72(sp)
    80003f7a:	6a06                	ld	s4,64(sp)
    80003f7c:	7ae2                	ld	s5,56(sp)
    80003f7e:	7b42                	ld	s6,48(sp)
    80003f80:	7ba2                	ld	s7,40(sp)
    80003f82:	7c02                	ld	s8,32(sp)
    80003f84:	6ce2                	ld	s9,24(sp)
    80003f86:	6d42                	ld	s10,16(sp)
    80003f88:	6da2                	ld	s11,8(sp)
    80003f8a:	6165                	addi	sp,sp,112
    80003f8c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f8e:	89d6                	mv	s3,s5
    80003f90:	bff1                	j	80003f6c <readi+0xce>
    return 0;
    80003f92:	4501                	li	a0,0
}
    80003f94:	8082                	ret

0000000080003f96 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003f96:	457c                	lw	a5,76(a0)
    80003f98:	10d7e863          	bltu	a5,a3,800040a8 <writei+0x112>
{
    80003f9c:	7159                	addi	sp,sp,-112
    80003f9e:	f486                	sd	ra,104(sp)
    80003fa0:	f0a2                	sd	s0,96(sp)
    80003fa2:	eca6                	sd	s1,88(sp)
    80003fa4:	e8ca                	sd	s2,80(sp)
    80003fa6:	e4ce                	sd	s3,72(sp)
    80003fa8:	e0d2                	sd	s4,64(sp)
    80003faa:	fc56                	sd	s5,56(sp)
    80003fac:	f85a                	sd	s6,48(sp)
    80003fae:	f45e                	sd	s7,40(sp)
    80003fb0:	f062                	sd	s8,32(sp)
    80003fb2:	ec66                	sd	s9,24(sp)
    80003fb4:	e86a                	sd	s10,16(sp)
    80003fb6:	e46e                	sd	s11,8(sp)
    80003fb8:	1880                	addi	s0,sp,112
    80003fba:	8aaa                	mv	s5,a0
    80003fbc:	8bae                	mv	s7,a1
    80003fbe:	8a32                	mv	s4,a2
    80003fc0:	8936                	mv	s2,a3
    80003fc2:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003fc4:	00e687bb          	addw	a5,a3,a4
    80003fc8:	0ed7e263          	bltu	a5,a3,800040ac <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003fcc:	00043737          	lui	a4,0x43
    80003fd0:	0ef76063          	bltu	a4,a5,800040b0 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003fd4:	0c0b0863          	beqz	s6,800040a4 <writei+0x10e>
    80003fd8:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fda:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003fde:	5c7d                	li	s8,-1
    80003fe0:	a091                	j	80004024 <writei+0x8e>
    80003fe2:	020d1d93          	slli	s11,s10,0x20
    80003fe6:	020ddd93          	srli	s11,s11,0x20
    80003fea:	05848513          	addi	a0,s1,88
    80003fee:	86ee                	mv	a3,s11
    80003ff0:	8652                	mv	a2,s4
    80003ff2:	85de                	mv	a1,s7
    80003ff4:	953a                	add	a0,a0,a4
    80003ff6:	ffffe097          	auipc	ra,0xffffe
    80003ffa:	7b2080e7          	jalr	1970(ra) # 800027a8 <either_copyin>
    80003ffe:	07850263          	beq	a0,s8,80004062 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004002:	8526                	mv	a0,s1
    80004004:	00000097          	auipc	ra,0x0
    80004008:	780080e7          	jalr	1920(ra) # 80004784 <log_write>
    brelse(bp);
    8000400c:	8526                	mv	a0,s1
    8000400e:	fffff097          	auipc	ra,0xfffff
    80004012:	4f2080e7          	jalr	1266(ra) # 80003500 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004016:	013d09bb          	addw	s3,s10,s3
    8000401a:	012d093b          	addw	s2,s10,s2
    8000401e:	9a6e                	add	s4,s4,s11
    80004020:	0569f663          	bgeu	s3,s6,8000406c <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80004024:	00a9559b          	srliw	a1,s2,0xa
    80004028:	8556                	mv	a0,s5
    8000402a:	fffff097          	auipc	ra,0xfffff
    8000402e:	7a0080e7          	jalr	1952(ra) # 800037ca <bmap>
    80004032:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004036:	c99d                	beqz	a1,8000406c <writei+0xd6>
    bp = bread(ip->dev, addr);
    80004038:	000aa503          	lw	a0,0(s5)
    8000403c:	fffff097          	auipc	ra,0xfffff
    80004040:	394080e7          	jalr	916(ra) # 800033d0 <bread>
    80004044:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004046:	3ff97713          	andi	a4,s2,1023
    8000404a:	40ec87bb          	subw	a5,s9,a4
    8000404e:	413b06bb          	subw	a3,s6,s3
    80004052:	8d3e                	mv	s10,a5
    80004054:	2781                	sext.w	a5,a5
    80004056:	0006861b          	sext.w	a2,a3
    8000405a:	f8f674e3          	bgeu	a2,a5,80003fe2 <writei+0x4c>
    8000405e:	8d36                	mv	s10,a3
    80004060:	b749                	j	80003fe2 <writei+0x4c>
      brelse(bp);
    80004062:	8526                	mv	a0,s1
    80004064:	fffff097          	auipc	ra,0xfffff
    80004068:	49c080e7          	jalr	1180(ra) # 80003500 <brelse>
  }

  if(off > ip->size)
    8000406c:	04caa783          	lw	a5,76(s5)
    80004070:	0127f463          	bgeu	a5,s2,80004078 <writei+0xe2>
    ip->size = off;
    80004074:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004078:	8556                	mv	a0,s5
    8000407a:	00000097          	auipc	ra,0x0
    8000407e:	aa6080e7          	jalr	-1370(ra) # 80003b20 <iupdate>

  return tot;
    80004082:	0009851b          	sext.w	a0,s3
}
    80004086:	70a6                	ld	ra,104(sp)
    80004088:	7406                	ld	s0,96(sp)
    8000408a:	64e6                	ld	s1,88(sp)
    8000408c:	6946                	ld	s2,80(sp)
    8000408e:	69a6                	ld	s3,72(sp)
    80004090:	6a06                	ld	s4,64(sp)
    80004092:	7ae2                	ld	s5,56(sp)
    80004094:	7b42                	ld	s6,48(sp)
    80004096:	7ba2                	ld	s7,40(sp)
    80004098:	7c02                	ld	s8,32(sp)
    8000409a:	6ce2                	ld	s9,24(sp)
    8000409c:	6d42                	ld	s10,16(sp)
    8000409e:	6da2                	ld	s11,8(sp)
    800040a0:	6165                	addi	sp,sp,112
    800040a2:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800040a4:	89da                	mv	s3,s6
    800040a6:	bfc9                	j	80004078 <writei+0xe2>
    return -1;
    800040a8:	557d                	li	a0,-1
}
    800040aa:	8082                	ret
    return -1;
    800040ac:	557d                	li	a0,-1
    800040ae:	bfe1                	j	80004086 <writei+0xf0>
    return -1;
    800040b0:	557d                	li	a0,-1
    800040b2:	bfd1                	j	80004086 <writei+0xf0>

00000000800040b4 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800040b4:	1141                	addi	sp,sp,-16
    800040b6:	e406                	sd	ra,8(sp)
    800040b8:	e022                	sd	s0,0(sp)
    800040ba:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800040bc:	4639                	li	a2,14
    800040be:	ffffd097          	auipc	ra,0xffffd
    800040c2:	d00080e7          	jalr	-768(ra) # 80000dbe <strncmp>
}
    800040c6:	60a2                	ld	ra,8(sp)
    800040c8:	6402                	ld	s0,0(sp)
    800040ca:	0141                	addi	sp,sp,16
    800040cc:	8082                	ret

00000000800040ce <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800040ce:	7139                	addi	sp,sp,-64
    800040d0:	fc06                	sd	ra,56(sp)
    800040d2:	f822                	sd	s0,48(sp)
    800040d4:	f426                	sd	s1,40(sp)
    800040d6:	f04a                	sd	s2,32(sp)
    800040d8:	ec4e                	sd	s3,24(sp)
    800040da:	e852                	sd	s4,16(sp)
    800040dc:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800040de:	04451703          	lh	a4,68(a0)
    800040e2:	4785                	li	a5,1
    800040e4:	00f71a63          	bne	a4,a5,800040f8 <dirlookup+0x2a>
    800040e8:	892a                	mv	s2,a0
    800040ea:	89ae                	mv	s3,a1
    800040ec:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800040ee:	457c                	lw	a5,76(a0)
    800040f0:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800040f2:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040f4:	e79d                	bnez	a5,80004122 <dirlookup+0x54>
    800040f6:	a8a5                	j	8000416e <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800040f8:	00004517          	auipc	a0,0x4
    800040fc:	64850513          	addi	a0,a0,1608 # 80008740 <syscalls+0x1c8>
    80004100:	ffffc097          	auipc	ra,0xffffc
    80004104:	444080e7          	jalr	1092(ra) # 80000544 <panic>
      panic("dirlookup read");
    80004108:	00004517          	auipc	a0,0x4
    8000410c:	65050513          	addi	a0,a0,1616 # 80008758 <syscalls+0x1e0>
    80004110:	ffffc097          	auipc	ra,0xffffc
    80004114:	434080e7          	jalr	1076(ra) # 80000544 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004118:	24c1                	addiw	s1,s1,16
    8000411a:	04c92783          	lw	a5,76(s2)
    8000411e:	04f4f763          	bgeu	s1,a5,8000416c <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004122:	4741                	li	a4,16
    80004124:	86a6                	mv	a3,s1
    80004126:	fc040613          	addi	a2,s0,-64
    8000412a:	4581                	li	a1,0
    8000412c:	854a                	mv	a0,s2
    8000412e:	00000097          	auipc	ra,0x0
    80004132:	d70080e7          	jalr	-656(ra) # 80003e9e <readi>
    80004136:	47c1                	li	a5,16
    80004138:	fcf518e3          	bne	a0,a5,80004108 <dirlookup+0x3a>
    if(de.inum == 0)
    8000413c:	fc045783          	lhu	a5,-64(s0)
    80004140:	dfe1                	beqz	a5,80004118 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004142:	fc240593          	addi	a1,s0,-62
    80004146:	854e                	mv	a0,s3
    80004148:	00000097          	auipc	ra,0x0
    8000414c:	f6c080e7          	jalr	-148(ra) # 800040b4 <namecmp>
    80004150:	f561                	bnez	a0,80004118 <dirlookup+0x4a>
      if(poff)
    80004152:	000a0463          	beqz	s4,8000415a <dirlookup+0x8c>
        *poff = off;
    80004156:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000415a:	fc045583          	lhu	a1,-64(s0)
    8000415e:	00092503          	lw	a0,0(s2)
    80004162:	fffff097          	auipc	ra,0xfffff
    80004166:	750080e7          	jalr	1872(ra) # 800038b2 <iget>
    8000416a:	a011                	j	8000416e <dirlookup+0xa0>
  return 0;
    8000416c:	4501                	li	a0,0
}
    8000416e:	70e2                	ld	ra,56(sp)
    80004170:	7442                	ld	s0,48(sp)
    80004172:	74a2                	ld	s1,40(sp)
    80004174:	7902                	ld	s2,32(sp)
    80004176:	69e2                	ld	s3,24(sp)
    80004178:	6a42                	ld	s4,16(sp)
    8000417a:	6121                	addi	sp,sp,64
    8000417c:	8082                	ret

000000008000417e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000417e:	711d                	addi	sp,sp,-96
    80004180:	ec86                	sd	ra,88(sp)
    80004182:	e8a2                	sd	s0,80(sp)
    80004184:	e4a6                	sd	s1,72(sp)
    80004186:	e0ca                	sd	s2,64(sp)
    80004188:	fc4e                	sd	s3,56(sp)
    8000418a:	f852                	sd	s4,48(sp)
    8000418c:	f456                	sd	s5,40(sp)
    8000418e:	f05a                	sd	s6,32(sp)
    80004190:	ec5e                	sd	s7,24(sp)
    80004192:	e862                	sd	s8,16(sp)
    80004194:	e466                	sd	s9,8(sp)
    80004196:	1080                	addi	s0,sp,96
    80004198:	84aa                	mv	s1,a0
    8000419a:	8b2e                	mv	s6,a1
    8000419c:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000419e:	00054703          	lbu	a4,0(a0)
    800041a2:	02f00793          	li	a5,47
    800041a6:	02f70363          	beq	a4,a5,800041cc <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800041aa:	ffffe097          	auipc	ra,0xffffe
    800041ae:	926080e7          	jalr	-1754(ra) # 80001ad0 <myproc>
    800041b2:	15853503          	ld	a0,344(a0)
    800041b6:	00000097          	auipc	ra,0x0
    800041ba:	9f6080e7          	jalr	-1546(ra) # 80003bac <idup>
    800041be:	89aa                	mv	s3,a0
  while(*path == '/')
    800041c0:	02f00913          	li	s2,47
  len = path - s;
    800041c4:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    800041c6:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800041c8:	4c05                	li	s8,1
    800041ca:	a865                	j	80004282 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    800041cc:	4585                	li	a1,1
    800041ce:	4505                	li	a0,1
    800041d0:	fffff097          	auipc	ra,0xfffff
    800041d4:	6e2080e7          	jalr	1762(ra) # 800038b2 <iget>
    800041d8:	89aa                	mv	s3,a0
    800041da:	b7dd                	j	800041c0 <namex+0x42>
      iunlockput(ip);
    800041dc:	854e                	mv	a0,s3
    800041de:	00000097          	auipc	ra,0x0
    800041e2:	c6e080e7          	jalr	-914(ra) # 80003e4c <iunlockput>
      return 0;
    800041e6:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800041e8:	854e                	mv	a0,s3
    800041ea:	60e6                	ld	ra,88(sp)
    800041ec:	6446                	ld	s0,80(sp)
    800041ee:	64a6                	ld	s1,72(sp)
    800041f0:	6906                	ld	s2,64(sp)
    800041f2:	79e2                	ld	s3,56(sp)
    800041f4:	7a42                	ld	s4,48(sp)
    800041f6:	7aa2                	ld	s5,40(sp)
    800041f8:	7b02                	ld	s6,32(sp)
    800041fa:	6be2                	ld	s7,24(sp)
    800041fc:	6c42                	ld	s8,16(sp)
    800041fe:	6ca2                	ld	s9,8(sp)
    80004200:	6125                	addi	sp,sp,96
    80004202:	8082                	ret
      iunlock(ip);
    80004204:	854e                	mv	a0,s3
    80004206:	00000097          	auipc	ra,0x0
    8000420a:	aa6080e7          	jalr	-1370(ra) # 80003cac <iunlock>
      return ip;
    8000420e:	bfe9                	j	800041e8 <namex+0x6a>
      iunlockput(ip);
    80004210:	854e                	mv	a0,s3
    80004212:	00000097          	auipc	ra,0x0
    80004216:	c3a080e7          	jalr	-966(ra) # 80003e4c <iunlockput>
      return 0;
    8000421a:	89d2                	mv	s3,s4
    8000421c:	b7f1                	j	800041e8 <namex+0x6a>
  len = path - s;
    8000421e:	40b48633          	sub	a2,s1,a1
    80004222:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80004226:	094cd463          	bge	s9,s4,800042ae <namex+0x130>
    memmove(name, s, DIRSIZ);
    8000422a:	4639                	li	a2,14
    8000422c:	8556                	mv	a0,s5
    8000422e:	ffffd097          	auipc	ra,0xffffd
    80004232:	b18080e7          	jalr	-1256(ra) # 80000d46 <memmove>
  while(*path == '/')
    80004236:	0004c783          	lbu	a5,0(s1)
    8000423a:	01279763          	bne	a5,s2,80004248 <namex+0xca>
    path++;
    8000423e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004240:	0004c783          	lbu	a5,0(s1)
    80004244:	ff278de3          	beq	a5,s2,8000423e <namex+0xc0>
    ilock(ip);
    80004248:	854e                	mv	a0,s3
    8000424a:	00000097          	auipc	ra,0x0
    8000424e:	9a0080e7          	jalr	-1632(ra) # 80003bea <ilock>
    if(ip->type != T_DIR){
    80004252:	04499783          	lh	a5,68(s3)
    80004256:	f98793e3          	bne	a5,s8,800041dc <namex+0x5e>
    if(nameiparent && *path == '\0'){
    8000425a:	000b0563          	beqz	s6,80004264 <namex+0xe6>
    8000425e:	0004c783          	lbu	a5,0(s1)
    80004262:	d3cd                	beqz	a5,80004204 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004264:	865e                	mv	a2,s7
    80004266:	85d6                	mv	a1,s5
    80004268:	854e                	mv	a0,s3
    8000426a:	00000097          	auipc	ra,0x0
    8000426e:	e64080e7          	jalr	-412(ra) # 800040ce <dirlookup>
    80004272:	8a2a                	mv	s4,a0
    80004274:	dd51                	beqz	a0,80004210 <namex+0x92>
    iunlockput(ip);
    80004276:	854e                	mv	a0,s3
    80004278:	00000097          	auipc	ra,0x0
    8000427c:	bd4080e7          	jalr	-1068(ra) # 80003e4c <iunlockput>
    ip = next;
    80004280:	89d2                	mv	s3,s4
  while(*path == '/')
    80004282:	0004c783          	lbu	a5,0(s1)
    80004286:	05279763          	bne	a5,s2,800042d4 <namex+0x156>
    path++;
    8000428a:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000428c:	0004c783          	lbu	a5,0(s1)
    80004290:	ff278de3          	beq	a5,s2,8000428a <namex+0x10c>
  if(*path == 0)
    80004294:	c79d                	beqz	a5,800042c2 <namex+0x144>
    path++;
    80004296:	85a6                	mv	a1,s1
  len = path - s;
    80004298:	8a5e                	mv	s4,s7
    8000429a:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    8000429c:	01278963          	beq	a5,s2,800042ae <namex+0x130>
    800042a0:	dfbd                	beqz	a5,8000421e <namex+0xa0>
    path++;
    800042a2:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800042a4:	0004c783          	lbu	a5,0(s1)
    800042a8:	ff279ce3          	bne	a5,s2,800042a0 <namex+0x122>
    800042ac:	bf8d                	j	8000421e <namex+0xa0>
    memmove(name, s, len);
    800042ae:	2601                	sext.w	a2,a2
    800042b0:	8556                	mv	a0,s5
    800042b2:	ffffd097          	auipc	ra,0xffffd
    800042b6:	a94080e7          	jalr	-1388(ra) # 80000d46 <memmove>
    name[len] = 0;
    800042ba:	9a56                	add	s4,s4,s5
    800042bc:	000a0023          	sb	zero,0(s4)
    800042c0:	bf9d                	j	80004236 <namex+0xb8>
  if(nameiparent){
    800042c2:	f20b03e3          	beqz	s6,800041e8 <namex+0x6a>
    iput(ip);
    800042c6:	854e                	mv	a0,s3
    800042c8:	00000097          	auipc	ra,0x0
    800042cc:	adc080e7          	jalr	-1316(ra) # 80003da4 <iput>
    return 0;
    800042d0:	4981                	li	s3,0
    800042d2:	bf19                	j	800041e8 <namex+0x6a>
  if(*path == 0)
    800042d4:	d7fd                	beqz	a5,800042c2 <namex+0x144>
  while(*path != '/' && *path != 0)
    800042d6:	0004c783          	lbu	a5,0(s1)
    800042da:	85a6                	mv	a1,s1
    800042dc:	b7d1                	j	800042a0 <namex+0x122>

00000000800042de <dirlink>:
{
    800042de:	7139                	addi	sp,sp,-64
    800042e0:	fc06                	sd	ra,56(sp)
    800042e2:	f822                	sd	s0,48(sp)
    800042e4:	f426                	sd	s1,40(sp)
    800042e6:	f04a                	sd	s2,32(sp)
    800042e8:	ec4e                	sd	s3,24(sp)
    800042ea:	e852                	sd	s4,16(sp)
    800042ec:	0080                	addi	s0,sp,64
    800042ee:	892a                	mv	s2,a0
    800042f0:	8a2e                	mv	s4,a1
    800042f2:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800042f4:	4601                	li	a2,0
    800042f6:	00000097          	auipc	ra,0x0
    800042fa:	dd8080e7          	jalr	-552(ra) # 800040ce <dirlookup>
    800042fe:	e93d                	bnez	a0,80004374 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004300:	04c92483          	lw	s1,76(s2)
    80004304:	c49d                	beqz	s1,80004332 <dirlink+0x54>
    80004306:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004308:	4741                	li	a4,16
    8000430a:	86a6                	mv	a3,s1
    8000430c:	fc040613          	addi	a2,s0,-64
    80004310:	4581                	li	a1,0
    80004312:	854a                	mv	a0,s2
    80004314:	00000097          	auipc	ra,0x0
    80004318:	b8a080e7          	jalr	-1142(ra) # 80003e9e <readi>
    8000431c:	47c1                	li	a5,16
    8000431e:	06f51163          	bne	a0,a5,80004380 <dirlink+0xa2>
    if(de.inum == 0)
    80004322:	fc045783          	lhu	a5,-64(s0)
    80004326:	c791                	beqz	a5,80004332 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004328:	24c1                	addiw	s1,s1,16
    8000432a:	04c92783          	lw	a5,76(s2)
    8000432e:	fcf4ede3          	bltu	s1,a5,80004308 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004332:	4639                	li	a2,14
    80004334:	85d2                	mv	a1,s4
    80004336:	fc240513          	addi	a0,s0,-62
    8000433a:	ffffd097          	auipc	ra,0xffffd
    8000433e:	ac0080e7          	jalr	-1344(ra) # 80000dfa <strncpy>
  de.inum = inum;
    80004342:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004346:	4741                	li	a4,16
    80004348:	86a6                	mv	a3,s1
    8000434a:	fc040613          	addi	a2,s0,-64
    8000434e:	4581                	li	a1,0
    80004350:	854a                	mv	a0,s2
    80004352:	00000097          	auipc	ra,0x0
    80004356:	c44080e7          	jalr	-956(ra) # 80003f96 <writei>
    8000435a:	1541                	addi	a0,a0,-16
    8000435c:	00a03533          	snez	a0,a0
    80004360:	40a00533          	neg	a0,a0
}
    80004364:	70e2                	ld	ra,56(sp)
    80004366:	7442                	ld	s0,48(sp)
    80004368:	74a2                	ld	s1,40(sp)
    8000436a:	7902                	ld	s2,32(sp)
    8000436c:	69e2                	ld	s3,24(sp)
    8000436e:	6a42                	ld	s4,16(sp)
    80004370:	6121                	addi	sp,sp,64
    80004372:	8082                	ret
    iput(ip);
    80004374:	00000097          	auipc	ra,0x0
    80004378:	a30080e7          	jalr	-1488(ra) # 80003da4 <iput>
    return -1;
    8000437c:	557d                	li	a0,-1
    8000437e:	b7dd                	j	80004364 <dirlink+0x86>
      panic("dirlink read");
    80004380:	00004517          	auipc	a0,0x4
    80004384:	3e850513          	addi	a0,a0,1000 # 80008768 <syscalls+0x1f0>
    80004388:	ffffc097          	auipc	ra,0xffffc
    8000438c:	1bc080e7          	jalr	444(ra) # 80000544 <panic>

0000000080004390 <namei>:

struct inode*
namei(char *path)
{
    80004390:	1101                	addi	sp,sp,-32
    80004392:	ec06                	sd	ra,24(sp)
    80004394:	e822                	sd	s0,16(sp)
    80004396:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004398:	fe040613          	addi	a2,s0,-32
    8000439c:	4581                	li	a1,0
    8000439e:	00000097          	auipc	ra,0x0
    800043a2:	de0080e7          	jalr	-544(ra) # 8000417e <namex>
}
    800043a6:	60e2                	ld	ra,24(sp)
    800043a8:	6442                	ld	s0,16(sp)
    800043aa:	6105                	addi	sp,sp,32
    800043ac:	8082                	ret

00000000800043ae <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800043ae:	1141                	addi	sp,sp,-16
    800043b0:	e406                	sd	ra,8(sp)
    800043b2:	e022                	sd	s0,0(sp)
    800043b4:	0800                	addi	s0,sp,16
    800043b6:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800043b8:	4585                	li	a1,1
    800043ba:	00000097          	auipc	ra,0x0
    800043be:	dc4080e7          	jalr	-572(ra) # 8000417e <namex>
}
    800043c2:	60a2                	ld	ra,8(sp)
    800043c4:	6402                	ld	s0,0(sp)
    800043c6:	0141                	addi	sp,sp,16
    800043c8:	8082                	ret

00000000800043ca <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800043ca:	1101                	addi	sp,sp,-32
    800043cc:	ec06                	sd	ra,24(sp)
    800043ce:	e822                	sd	s0,16(sp)
    800043d0:	e426                	sd	s1,8(sp)
    800043d2:	e04a                	sd	s2,0(sp)
    800043d4:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800043d6:	0001e917          	auipc	s2,0x1e
    800043da:	43a90913          	addi	s2,s2,1082 # 80022810 <log>
    800043de:	01892583          	lw	a1,24(s2)
    800043e2:	02892503          	lw	a0,40(s2)
    800043e6:	fffff097          	auipc	ra,0xfffff
    800043ea:	fea080e7          	jalr	-22(ra) # 800033d0 <bread>
    800043ee:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800043f0:	02c92683          	lw	a3,44(s2)
    800043f4:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800043f6:	02d05763          	blez	a3,80004424 <write_head+0x5a>
    800043fa:	0001e797          	auipc	a5,0x1e
    800043fe:	44678793          	addi	a5,a5,1094 # 80022840 <log+0x30>
    80004402:	05c50713          	addi	a4,a0,92
    80004406:	36fd                	addiw	a3,a3,-1
    80004408:	1682                	slli	a3,a3,0x20
    8000440a:	9281                	srli	a3,a3,0x20
    8000440c:	068a                	slli	a3,a3,0x2
    8000440e:	0001e617          	auipc	a2,0x1e
    80004412:	43660613          	addi	a2,a2,1078 # 80022844 <log+0x34>
    80004416:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004418:	4390                	lw	a2,0(a5)
    8000441a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000441c:	0791                	addi	a5,a5,4
    8000441e:	0711                	addi	a4,a4,4
    80004420:	fed79ce3          	bne	a5,a3,80004418 <write_head+0x4e>
  }
  bwrite(buf);
    80004424:	8526                	mv	a0,s1
    80004426:	fffff097          	auipc	ra,0xfffff
    8000442a:	09c080e7          	jalr	156(ra) # 800034c2 <bwrite>
  brelse(buf);
    8000442e:	8526                	mv	a0,s1
    80004430:	fffff097          	auipc	ra,0xfffff
    80004434:	0d0080e7          	jalr	208(ra) # 80003500 <brelse>
}
    80004438:	60e2                	ld	ra,24(sp)
    8000443a:	6442                	ld	s0,16(sp)
    8000443c:	64a2                	ld	s1,8(sp)
    8000443e:	6902                	ld	s2,0(sp)
    80004440:	6105                	addi	sp,sp,32
    80004442:	8082                	ret

0000000080004444 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004444:	0001e797          	auipc	a5,0x1e
    80004448:	3f87a783          	lw	a5,1016(a5) # 8002283c <log+0x2c>
    8000444c:	0af05d63          	blez	a5,80004506 <install_trans+0xc2>
{
    80004450:	7139                	addi	sp,sp,-64
    80004452:	fc06                	sd	ra,56(sp)
    80004454:	f822                	sd	s0,48(sp)
    80004456:	f426                	sd	s1,40(sp)
    80004458:	f04a                	sd	s2,32(sp)
    8000445a:	ec4e                	sd	s3,24(sp)
    8000445c:	e852                	sd	s4,16(sp)
    8000445e:	e456                	sd	s5,8(sp)
    80004460:	e05a                	sd	s6,0(sp)
    80004462:	0080                	addi	s0,sp,64
    80004464:	8b2a                	mv	s6,a0
    80004466:	0001ea97          	auipc	s5,0x1e
    8000446a:	3daa8a93          	addi	s5,s5,986 # 80022840 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000446e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004470:	0001e997          	auipc	s3,0x1e
    80004474:	3a098993          	addi	s3,s3,928 # 80022810 <log>
    80004478:	a035                	j	800044a4 <install_trans+0x60>
      bunpin(dbuf);
    8000447a:	8526                	mv	a0,s1
    8000447c:	fffff097          	auipc	ra,0xfffff
    80004480:	15e080e7          	jalr	350(ra) # 800035da <bunpin>
    brelse(lbuf);
    80004484:	854a                	mv	a0,s2
    80004486:	fffff097          	auipc	ra,0xfffff
    8000448a:	07a080e7          	jalr	122(ra) # 80003500 <brelse>
    brelse(dbuf);
    8000448e:	8526                	mv	a0,s1
    80004490:	fffff097          	auipc	ra,0xfffff
    80004494:	070080e7          	jalr	112(ra) # 80003500 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004498:	2a05                	addiw	s4,s4,1
    8000449a:	0a91                	addi	s5,s5,4
    8000449c:	02c9a783          	lw	a5,44(s3)
    800044a0:	04fa5963          	bge	s4,a5,800044f2 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800044a4:	0189a583          	lw	a1,24(s3)
    800044a8:	014585bb          	addw	a1,a1,s4
    800044ac:	2585                	addiw	a1,a1,1
    800044ae:	0289a503          	lw	a0,40(s3)
    800044b2:	fffff097          	auipc	ra,0xfffff
    800044b6:	f1e080e7          	jalr	-226(ra) # 800033d0 <bread>
    800044ba:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800044bc:	000aa583          	lw	a1,0(s5)
    800044c0:	0289a503          	lw	a0,40(s3)
    800044c4:	fffff097          	auipc	ra,0xfffff
    800044c8:	f0c080e7          	jalr	-244(ra) # 800033d0 <bread>
    800044cc:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800044ce:	40000613          	li	a2,1024
    800044d2:	05890593          	addi	a1,s2,88
    800044d6:	05850513          	addi	a0,a0,88
    800044da:	ffffd097          	auipc	ra,0xffffd
    800044de:	86c080e7          	jalr	-1940(ra) # 80000d46 <memmove>
    bwrite(dbuf);  // write dst to disk
    800044e2:	8526                	mv	a0,s1
    800044e4:	fffff097          	auipc	ra,0xfffff
    800044e8:	fde080e7          	jalr	-34(ra) # 800034c2 <bwrite>
    if(recovering == 0)
    800044ec:	f80b1ce3          	bnez	s6,80004484 <install_trans+0x40>
    800044f0:	b769                	j	8000447a <install_trans+0x36>
}
    800044f2:	70e2                	ld	ra,56(sp)
    800044f4:	7442                	ld	s0,48(sp)
    800044f6:	74a2                	ld	s1,40(sp)
    800044f8:	7902                	ld	s2,32(sp)
    800044fa:	69e2                	ld	s3,24(sp)
    800044fc:	6a42                	ld	s4,16(sp)
    800044fe:	6aa2                	ld	s5,8(sp)
    80004500:	6b02                	ld	s6,0(sp)
    80004502:	6121                	addi	sp,sp,64
    80004504:	8082                	ret
    80004506:	8082                	ret

0000000080004508 <initlog>:
{
    80004508:	7179                	addi	sp,sp,-48
    8000450a:	f406                	sd	ra,40(sp)
    8000450c:	f022                	sd	s0,32(sp)
    8000450e:	ec26                	sd	s1,24(sp)
    80004510:	e84a                	sd	s2,16(sp)
    80004512:	e44e                	sd	s3,8(sp)
    80004514:	1800                	addi	s0,sp,48
    80004516:	892a                	mv	s2,a0
    80004518:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000451a:	0001e497          	auipc	s1,0x1e
    8000451e:	2f648493          	addi	s1,s1,758 # 80022810 <log>
    80004522:	00004597          	auipc	a1,0x4
    80004526:	25658593          	addi	a1,a1,598 # 80008778 <syscalls+0x200>
    8000452a:	8526                	mv	a0,s1
    8000452c:	ffffc097          	auipc	ra,0xffffc
    80004530:	62e080e7          	jalr	1582(ra) # 80000b5a <initlock>
  log.start = sb->logstart;
    80004534:	0149a583          	lw	a1,20(s3)
    80004538:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000453a:	0109a783          	lw	a5,16(s3)
    8000453e:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004540:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004544:	854a                	mv	a0,s2
    80004546:	fffff097          	auipc	ra,0xfffff
    8000454a:	e8a080e7          	jalr	-374(ra) # 800033d0 <bread>
  log.lh.n = lh->n;
    8000454e:	4d3c                	lw	a5,88(a0)
    80004550:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004552:	02f05563          	blez	a5,8000457c <initlog+0x74>
    80004556:	05c50713          	addi	a4,a0,92
    8000455a:	0001e697          	auipc	a3,0x1e
    8000455e:	2e668693          	addi	a3,a3,742 # 80022840 <log+0x30>
    80004562:	37fd                	addiw	a5,a5,-1
    80004564:	1782                	slli	a5,a5,0x20
    80004566:	9381                	srli	a5,a5,0x20
    80004568:	078a                	slli	a5,a5,0x2
    8000456a:	06050613          	addi	a2,a0,96
    8000456e:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80004570:	4310                	lw	a2,0(a4)
    80004572:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80004574:	0711                	addi	a4,a4,4
    80004576:	0691                	addi	a3,a3,4
    80004578:	fef71ce3          	bne	a4,a5,80004570 <initlog+0x68>
  brelse(buf);
    8000457c:	fffff097          	auipc	ra,0xfffff
    80004580:	f84080e7          	jalr	-124(ra) # 80003500 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004584:	4505                	li	a0,1
    80004586:	00000097          	auipc	ra,0x0
    8000458a:	ebe080e7          	jalr	-322(ra) # 80004444 <install_trans>
  log.lh.n = 0;
    8000458e:	0001e797          	auipc	a5,0x1e
    80004592:	2a07a723          	sw	zero,686(a5) # 8002283c <log+0x2c>
  write_head(); // clear the log
    80004596:	00000097          	auipc	ra,0x0
    8000459a:	e34080e7          	jalr	-460(ra) # 800043ca <write_head>
}
    8000459e:	70a2                	ld	ra,40(sp)
    800045a0:	7402                	ld	s0,32(sp)
    800045a2:	64e2                	ld	s1,24(sp)
    800045a4:	6942                	ld	s2,16(sp)
    800045a6:	69a2                	ld	s3,8(sp)
    800045a8:	6145                	addi	sp,sp,48
    800045aa:	8082                	ret

00000000800045ac <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800045ac:	1101                	addi	sp,sp,-32
    800045ae:	ec06                	sd	ra,24(sp)
    800045b0:	e822                	sd	s0,16(sp)
    800045b2:	e426                	sd	s1,8(sp)
    800045b4:	e04a                	sd	s2,0(sp)
    800045b6:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800045b8:	0001e517          	auipc	a0,0x1e
    800045bc:	25850513          	addi	a0,a0,600 # 80022810 <log>
    800045c0:	ffffc097          	auipc	ra,0xffffc
    800045c4:	62a080e7          	jalr	1578(ra) # 80000bea <acquire>
  while(1){
    if(log.committing){
    800045c8:	0001e497          	auipc	s1,0x1e
    800045cc:	24848493          	addi	s1,s1,584 # 80022810 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800045d0:	4979                	li	s2,30
    800045d2:	a039                	j	800045e0 <begin_op+0x34>
      sleep(&log, &log.lock);
    800045d4:	85a6                	mv	a1,s1
    800045d6:	8526                	mv	a0,s1
    800045d8:	ffffe097          	auipc	ra,0xffffe
    800045dc:	c10080e7          	jalr	-1008(ra) # 800021e8 <sleep>
    if(log.committing){
    800045e0:	50dc                	lw	a5,36(s1)
    800045e2:	fbed                	bnez	a5,800045d4 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800045e4:	509c                	lw	a5,32(s1)
    800045e6:	0017871b          	addiw	a4,a5,1
    800045ea:	0007069b          	sext.w	a3,a4
    800045ee:	0027179b          	slliw	a5,a4,0x2
    800045f2:	9fb9                	addw	a5,a5,a4
    800045f4:	0017979b          	slliw	a5,a5,0x1
    800045f8:	54d8                	lw	a4,44(s1)
    800045fa:	9fb9                	addw	a5,a5,a4
    800045fc:	00f95963          	bge	s2,a5,8000460e <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004600:	85a6                	mv	a1,s1
    80004602:	8526                	mv	a0,s1
    80004604:	ffffe097          	auipc	ra,0xffffe
    80004608:	be4080e7          	jalr	-1052(ra) # 800021e8 <sleep>
    8000460c:	bfd1                	j	800045e0 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000460e:	0001e517          	auipc	a0,0x1e
    80004612:	20250513          	addi	a0,a0,514 # 80022810 <log>
    80004616:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004618:	ffffc097          	auipc	ra,0xffffc
    8000461c:	686080e7          	jalr	1670(ra) # 80000c9e <release>
      break;
    }
  }
}
    80004620:	60e2                	ld	ra,24(sp)
    80004622:	6442                	ld	s0,16(sp)
    80004624:	64a2                	ld	s1,8(sp)
    80004626:	6902                	ld	s2,0(sp)
    80004628:	6105                	addi	sp,sp,32
    8000462a:	8082                	ret

000000008000462c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000462c:	7139                	addi	sp,sp,-64
    8000462e:	fc06                	sd	ra,56(sp)
    80004630:	f822                	sd	s0,48(sp)
    80004632:	f426                	sd	s1,40(sp)
    80004634:	f04a                	sd	s2,32(sp)
    80004636:	ec4e                	sd	s3,24(sp)
    80004638:	e852                	sd	s4,16(sp)
    8000463a:	e456                	sd	s5,8(sp)
    8000463c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000463e:	0001e497          	auipc	s1,0x1e
    80004642:	1d248493          	addi	s1,s1,466 # 80022810 <log>
    80004646:	8526                	mv	a0,s1
    80004648:	ffffc097          	auipc	ra,0xffffc
    8000464c:	5a2080e7          	jalr	1442(ra) # 80000bea <acquire>
  log.outstanding -= 1;
    80004650:	509c                	lw	a5,32(s1)
    80004652:	37fd                	addiw	a5,a5,-1
    80004654:	0007891b          	sext.w	s2,a5
    80004658:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000465a:	50dc                	lw	a5,36(s1)
    8000465c:	efb9                	bnez	a5,800046ba <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000465e:	06091663          	bnez	s2,800046ca <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    80004662:	0001e497          	auipc	s1,0x1e
    80004666:	1ae48493          	addi	s1,s1,430 # 80022810 <log>
    8000466a:	4785                	li	a5,1
    8000466c:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000466e:	8526                	mv	a0,s1
    80004670:	ffffc097          	auipc	ra,0xffffc
    80004674:	62e080e7          	jalr	1582(ra) # 80000c9e <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004678:	54dc                	lw	a5,44(s1)
    8000467a:	06f04763          	bgtz	a5,800046e8 <end_op+0xbc>
    acquire(&log.lock);
    8000467e:	0001e497          	auipc	s1,0x1e
    80004682:	19248493          	addi	s1,s1,402 # 80022810 <log>
    80004686:	8526                	mv	a0,s1
    80004688:	ffffc097          	auipc	ra,0xffffc
    8000468c:	562080e7          	jalr	1378(ra) # 80000bea <acquire>
    log.committing = 0;
    80004690:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004694:	8526                	mv	a0,s1
    80004696:	ffffe097          	auipc	ra,0xffffe
    8000469a:	cf0080e7          	jalr	-784(ra) # 80002386 <wakeup>
    release(&log.lock);
    8000469e:	8526                	mv	a0,s1
    800046a0:	ffffc097          	auipc	ra,0xffffc
    800046a4:	5fe080e7          	jalr	1534(ra) # 80000c9e <release>
}
    800046a8:	70e2                	ld	ra,56(sp)
    800046aa:	7442                	ld	s0,48(sp)
    800046ac:	74a2                	ld	s1,40(sp)
    800046ae:	7902                	ld	s2,32(sp)
    800046b0:	69e2                	ld	s3,24(sp)
    800046b2:	6a42                	ld	s4,16(sp)
    800046b4:	6aa2                	ld	s5,8(sp)
    800046b6:	6121                	addi	sp,sp,64
    800046b8:	8082                	ret
    panic("log.committing");
    800046ba:	00004517          	auipc	a0,0x4
    800046be:	0c650513          	addi	a0,a0,198 # 80008780 <syscalls+0x208>
    800046c2:	ffffc097          	auipc	ra,0xffffc
    800046c6:	e82080e7          	jalr	-382(ra) # 80000544 <panic>
    wakeup(&log);
    800046ca:	0001e497          	auipc	s1,0x1e
    800046ce:	14648493          	addi	s1,s1,326 # 80022810 <log>
    800046d2:	8526                	mv	a0,s1
    800046d4:	ffffe097          	auipc	ra,0xffffe
    800046d8:	cb2080e7          	jalr	-846(ra) # 80002386 <wakeup>
  release(&log.lock);
    800046dc:	8526                	mv	a0,s1
    800046de:	ffffc097          	auipc	ra,0xffffc
    800046e2:	5c0080e7          	jalr	1472(ra) # 80000c9e <release>
  if(do_commit){
    800046e6:	b7c9                	j	800046a8 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800046e8:	0001ea97          	auipc	s5,0x1e
    800046ec:	158a8a93          	addi	s5,s5,344 # 80022840 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800046f0:	0001ea17          	auipc	s4,0x1e
    800046f4:	120a0a13          	addi	s4,s4,288 # 80022810 <log>
    800046f8:	018a2583          	lw	a1,24(s4)
    800046fc:	012585bb          	addw	a1,a1,s2
    80004700:	2585                	addiw	a1,a1,1
    80004702:	028a2503          	lw	a0,40(s4)
    80004706:	fffff097          	auipc	ra,0xfffff
    8000470a:	cca080e7          	jalr	-822(ra) # 800033d0 <bread>
    8000470e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004710:	000aa583          	lw	a1,0(s5)
    80004714:	028a2503          	lw	a0,40(s4)
    80004718:	fffff097          	auipc	ra,0xfffff
    8000471c:	cb8080e7          	jalr	-840(ra) # 800033d0 <bread>
    80004720:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004722:	40000613          	li	a2,1024
    80004726:	05850593          	addi	a1,a0,88
    8000472a:	05848513          	addi	a0,s1,88
    8000472e:	ffffc097          	auipc	ra,0xffffc
    80004732:	618080e7          	jalr	1560(ra) # 80000d46 <memmove>
    bwrite(to);  // write the log
    80004736:	8526                	mv	a0,s1
    80004738:	fffff097          	auipc	ra,0xfffff
    8000473c:	d8a080e7          	jalr	-630(ra) # 800034c2 <bwrite>
    brelse(from);
    80004740:	854e                	mv	a0,s3
    80004742:	fffff097          	auipc	ra,0xfffff
    80004746:	dbe080e7          	jalr	-578(ra) # 80003500 <brelse>
    brelse(to);
    8000474a:	8526                	mv	a0,s1
    8000474c:	fffff097          	auipc	ra,0xfffff
    80004750:	db4080e7          	jalr	-588(ra) # 80003500 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004754:	2905                	addiw	s2,s2,1
    80004756:	0a91                	addi	s5,s5,4
    80004758:	02ca2783          	lw	a5,44(s4)
    8000475c:	f8f94ee3          	blt	s2,a5,800046f8 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004760:	00000097          	auipc	ra,0x0
    80004764:	c6a080e7          	jalr	-918(ra) # 800043ca <write_head>
    install_trans(0); // Now install writes to home locations
    80004768:	4501                	li	a0,0
    8000476a:	00000097          	auipc	ra,0x0
    8000476e:	cda080e7          	jalr	-806(ra) # 80004444 <install_trans>
    log.lh.n = 0;
    80004772:	0001e797          	auipc	a5,0x1e
    80004776:	0c07a523          	sw	zero,202(a5) # 8002283c <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000477a:	00000097          	auipc	ra,0x0
    8000477e:	c50080e7          	jalr	-944(ra) # 800043ca <write_head>
    80004782:	bdf5                	j	8000467e <end_op+0x52>

0000000080004784 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004784:	1101                	addi	sp,sp,-32
    80004786:	ec06                	sd	ra,24(sp)
    80004788:	e822                	sd	s0,16(sp)
    8000478a:	e426                	sd	s1,8(sp)
    8000478c:	e04a                	sd	s2,0(sp)
    8000478e:	1000                	addi	s0,sp,32
    80004790:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004792:	0001e917          	auipc	s2,0x1e
    80004796:	07e90913          	addi	s2,s2,126 # 80022810 <log>
    8000479a:	854a                	mv	a0,s2
    8000479c:	ffffc097          	auipc	ra,0xffffc
    800047a0:	44e080e7          	jalr	1102(ra) # 80000bea <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800047a4:	02c92603          	lw	a2,44(s2)
    800047a8:	47f5                	li	a5,29
    800047aa:	06c7c563          	blt	a5,a2,80004814 <log_write+0x90>
    800047ae:	0001e797          	auipc	a5,0x1e
    800047b2:	07e7a783          	lw	a5,126(a5) # 8002282c <log+0x1c>
    800047b6:	37fd                	addiw	a5,a5,-1
    800047b8:	04f65e63          	bge	a2,a5,80004814 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800047bc:	0001e797          	auipc	a5,0x1e
    800047c0:	0747a783          	lw	a5,116(a5) # 80022830 <log+0x20>
    800047c4:	06f05063          	blez	a5,80004824 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800047c8:	4781                	li	a5,0
    800047ca:	06c05563          	blez	a2,80004834 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800047ce:	44cc                	lw	a1,12(s1)
    800047d0:	0001e717          	auipc	a4,0x1e
    800047d4:	07070713          	addi	a4,a4,112 # 80022840 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800047d8:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800047da:	4314                	lw	a3,0(a4)
    800047dc:	04b68c63          	beq	a3,a1,80004834 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800047e0:	2785                	addiw	a5,a5,1
    800047e2:	0711                	addi	a4,a4,4
    800047e4:	fef61be3          	bne	a2,a5,800047da <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800047e8:	0621                	addi	a2,a2,8
    800047ea:	060a                	slli	a2,a2,0x2
    800047ec:	0001e797          	auipc	a5,0x1e
    800047f0:	02478793          	addi	a5,a5,36 # 80022810 <log>
    800047f4:	963e                	add	a2,a2,a5
    800047f6:	44dc                	lw	a5,12(s1)
    800047f8:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800047fa:	8526                	mv	a0,s1
    800047fc:	fffff097          	auipc	ra,0xfffff
    80004800:	da2080e7          	jalr	-606(ra) # 8000359e <bpin>
    log.lh.n++;
    80004804:	0001e717          	auipc	a4,0x1e
    80004808:	00c70713          	addi	a4,a4,12 # 80022810 <log>
    8000480c:	575c                	lw	a5,44(a4)
    8000480e:	2785                	addiw	a5,a5,1
    80004810:	d75c                	sw	a5,44(a4)
    80004812:	a835                	j	8000484e <log_write+0xca>
    panic("too big a transaction");
    80004814:	00004517          	auipc	a0,0x4
    80004818:	f7c50513          	addi	a0,a0,-132 # 80008790 <syscalls+0x218>
    8000481c:	ffffc097          	auipc	ra,0xffffc
    80004820:	d28080e7          	jalr	-728(ra) # 80000544 <panic>
    panic("log_write outside of trans");
    80004824:	00004517          	auipc	a0,0x4
    80004828:	f8450513          	addi	a0,a0,-124 # 800087a8 <syscalls+0x230>
    8000482c:	ffffc097          	auipc	ra,0xffffc
    80004830:	d18080e7          	jalr	-744(ra) # 80000544 <panic>
  log.lh.block[i] = b->blockno;
    80004834:	00878713          	addi	a4,a5,8
    80004838:	00271693          	slli	a3,a4,0x2
    8000483c:	0001e717          	auipc	a4,0x1e
    80004840:	fd470713          	addi	a4,a4,-44 # 80022810 <log>
    80004844:	9736                	add	a4,a4,a3
    80004846:	44d4                	lw	a3,12(s1)
    80004848:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000484a:	faf608e3          	beq	a2,a5,800047fa <log_write+0x76>
  }
  release(&log.lock);
    8000484e:	0001e517          	auipc	a0,0x1e
    80004852:	fc250513          	addi	a0,a0,-62 # 80022810 <log>
    80004856:	ffffc097          	auipc	ra,0xffffc
    8000485a:	448080e7          	jalr	1096(ra) # 80000c9e <release>
}
    8000485e:	60e2                	ld	ra,24(sp)
    80004860:	6442                	ld	s0,16(sp)
    80004862:	64a2                	ld	s1,8(sp)
    80004864:	6902                	ld	s2,0(sp)
    80004866:	6105                	addi	sp,sp,32
    80004868:	8082                	ret

000000008000486a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000486a:	1101                	addi	sp,sp,-32
    8000486c:	ec06                	sd	ra,24(sp)
    8000486e:	e822                	sd	s0,16(sp)
    80004870:	e426                	sd	s1,8(sp)
    80004872:	e04a                	sd	s2,0(sp)
    80004874:	1000                	addi	s0,sp,32
    80004876:	84aa                	mv	s1,a0
    80004878:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000487a:	00004597          	auipc	a1,0x4
    8000487e:	f4e58593          	addi	a1,a1,-178 # 800087c8 <syscalls+0x250>
    80004882:	0521                	addi	a0,a0,8
    80004884:	ffffc097          	auipc	ra,0xffffc
    80004888:	2d6080e7          	jalr	726(ra) # 80000b5a <initlock>
  lk->name = name;
    8000488c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004890:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004894:	0204a423          	sw	zero,40(s1)
}
    80004898:	60e2                	ld	ra,24(sp)
    8000489a:	6442                	ld	s0,16(sp)
    8000489c:	64a2                	ld	s1,8(sp)
    8000489e:	6902                	ld	s2,0(sp)
    800048a0:	6105                	addi	sp,sp,32
    800048a2:	8082                	ret

00000000800048a4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800048a4:	1101                	addi	sp,sp,-32
    800048a6:	ec06                	sd	ra,24(sp)
    800048a8:	e822                	sd	s0,16(sp)
    800048aa:	e426                	sd	s1,8(sp)
    800048ac:	e04a                	sd	s2,0(sp)
    800048ae:	1000                	addi	s0,sp,32
    800048b0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800048b2:	00850913          	addi	s2,a0,8
    800048b6:	854a                	mv	a0,s2
    800048b8:	ffffc097          	auipc	ra,0xffffc
    800048bc:	332080e7          	jalr	818(ra) # 80000bea <acquire>
  while (lk->locked) {
    800048c0:	409c                	lw	a5,0(s1)
    800048c2:	cb89                	beqz	a5,800048d4 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800048c4:	85ca                	mv	a1,s2
    800048c6:	8526                	mv	a0,s1
    800048c8:	ffffe097          	auipc	ra,0xffffe
    800048cc:	920080e7          	jalr	-1760(ra) # 800021e8 <sleep>
  while (lk->locked) {
    800048d0:	409c                	lw	a5,0(s1)
    800048d2:	fbed                	bnez	a5,800048c4 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800048d4:	4785                	li	a5,1
    800048d6:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800048d8:	ffffd097          	auipc	ra,0xffffd
    800048dc:	1f8080e7          	jalr	504(ra) # 80001ad0 <myproc>
    800048e0:	5d1c                	lw	a5,56(a0)
    800048e2:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800048e4:	854a                	mv	a0,s2
    800048e6:	ffffc097          	auipc	ra,0xffffc
    800048ea:	3b8080e7          	jalr	952(ra) # 80000c9e <release>
}
    800048ee:	60e2                	ld	ra,24(sp)
    800048f0:	6442                	ld	s0,16(sp)
    800048f2:	64a2                	ld	s1,8(sp)
    800048f4:	6902                	ld	s2,0(sp)
    800048f6:	6105                	addi	sp,sp,32
    800048f8:	8082                	ret

00000000800048fa <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800048fa:	1101                	addi	sp,sp,-32
    800048fc:	ec06                	sd	ra,24(sp)
    800048fe:	e822                	sd	s0,16(sp)
    80004900:	e426                	sd	s1,8(sp)
    80004902:	e04a                	sd	s2,0(sp)
    80004904:	1000                	addi	s0,sp,32
    80004906:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004908:	00850913          	addi	s2,a0,8
    8000490c:	854a                	mv	a0,s2
    8000490e:	ffffc097          	auipc	ra,0xffffc
    80004912:	2dc080e7          	jalr	732(ra) # 80000bea <acquire>
  lk->locked = 0;
    80004916:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000491a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000491e:	8526                	mv	a0,s1
    80004920:	ffffe097          	auipc	ra,0xffffe
    80004924:	a66080e7          	jalr	-1434(ra) # 80002386 <wakeup>
  release(&lk->lk);
    80004928:	854a                	mv	a0,s2
    8000492a:	ffffc097          	auipc	ra,0xffffc
    8000492e:	374080e7          	jalr	884(ra) # 80000c9e <release>
}
    80004932:	60e2                	ld	ra,24(sp)
    80004934:	6442                	ld	s0,16(sp)
    80004936:	64a2                	ld	s1,8(sp)
    80004938:	6902                	ld	s2,0(sp)
    8000493a:	6105                	addi	sp,sp,32
    8000493c:	8082                	ret

000000008000493e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000493e:	7179                	addi	sp,sp,-48
    80004940:	f406                	sd	ra,40(sp)
    80004942:	f022                	sd	s0,32(sp)
    80004944:	ec26                	sd	s1,24(sp)
    80004946:	e84a                	sd	s2,16(sp)
    80004948:	e44e                	sd	s3,8(sp)
    8000494a:	1800                	addi	s0,sp,48
    8000494c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000494e:	00850913          	addi	s2,a0,8
    80004952:	854a                	mv	a0,s2
    80004954:	ffffc097          	auipc	ra,0xffffc
    80004958:	296080e7          	jalr	662(ra) # 80000bea <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000495c:	409c                	lw	a5,0(s1)
    8000495e:	ef99                	bnez	a5,8000497c <holdingsleep+0x3e>
    80004960:	4481                	li	s1,0
  release(&lk->lk);
    80004962:	854a                	mv	a0,s2
    80004964:	ffffc097          	auipc	ra,0xffffc
    80004968:	33a080e7          	jalr	826(ra) # 80000c9e <release>
  return r;
}
    8000496c:	8526                	mv	a0,s1
    8000496e:	70a2                	ld	ra,40(sp)
    80004970:	7402                	ld	s0,32(sp)
    80004972:	64e2                	ld	s1,24(sp)
    80004974:	6942                	ld	s2,16(sp)
    80004976:	69a2                	ld	s3,8(sp)
    80004978:	6145                	addi	sp,sp,48
    8000497a:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000497c:	0284a983          	lw	s3,40(s1)
    80004980:	ffffd097          	auipc	ra,0xffffd
    80004984:	150080e7          	jalr	336(ra) # 80001ad0 <myproc>
    80004988:	5d04                	lw	s1,56(a0)
    8000498a:	413484b3          	sub	s1,s1,s3
    8000498e:	0014b493          	seqz	s1,s1
    80004992:	bfc1                	j	80004962 <holdingsleep+0x24>

0000000080004994 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004994:	1141                	addi	sp,sp,-16
    80004996:	e406                	sd	ra,8(sp)
    80004998:	e022                	sd	s0,0(sp)
    8000499a:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000499c:	00004597          	auipc	a1,0x4
    800049a0:	e3c58593          	addi	a1,a1,-452 # 800087d8 <syscalls+0x260>
    800049a4:	0001e517          	auipc	a0,0x1e
    800049a8:	fb450513          	addi	a0,a0,-76 # 80022958 <ftable>
    800049ac:	ffffc097          	auipc	ra,0xffffc
    800049b0:	1ae080e7          	jalr	430(ra) # 80000b5a <initlock>
}
    800049b4:	60a2                	ld	ra,8(sp)
    800049b6:	6402                	ld	s0,0(sp)
    800049b8:	0141                	addi	sp,sp,16
    800049ba:	8082                	ret

00000000800049bc <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800049bc:	1101                	addi	sp,sp,-32
    800049be:	ec06                	sd	ra,24(sp)
    800049c0:	e822                	sd	s0,16(sp)
    800049c2:	e426                	sd	s1,8(sp)
    800049c4:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800049c6:	0001e517          	auipc	a0,0x1e
    800049ca:	f9250513          	addi	a0,a0,-110 # 80022958 <ftable>
    800049ce:	ffffc097          	auipc	ra,0xffffc
    800049d2:	21c080e7          	jalr	540(ra) # 80000bea <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800049d6:	0001e497          	auipc	s1,0x1e
    800049da:	f9a48493          	addi	s1,s1,-102 # 80022970 <ftable+0x18>
    800049de:	0001f717          	auipc	a4,0x1f
    800049e2:	f3270713          	addi	a4,a4,-206 # 80023910 <disk>
    if(f->ref == 0){
    800049e6:	40dc                	lw	a5,4(s1)
    800049e8:	cf99                	beqz	a5,80004a06 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800049ea:	02848493          	addi	s1,s1,40
    800049ee:	fee49ce3          	bne	s1,a4,800049e6 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800049f2:	0001e517          	auipc	a0,0x1e
    800049f6:	f6650513          	addi	a0,a0,-154 # 80022958 <ftable>
    800049fa:	ffffc097          	auipc	ra,0xffffc
    800049fe:	2a4080e7          	jalr	676(ra) # 80000c9e <release>
  return 0;
    80004a02:	4481                	li	s1,0
    80004a04:	a819                	j	80004a1a <filealloc+0x5e>
      f->ref = 1;
    80004a06:	4785                	li	a5,1
    80004a08:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004a0a:	0001e517          	auipc	a0,0x1e
    80004a0e:	f4e50513          	addi	a0,a0,-178 # 80022958 <ftable>
    80004a12:	ffffc097          	auipc	ra,0xffffc
    80004a16:	28c080e7          	jalr	652(ra) # 80000c9e <release>
}
    80004a1a:	8526                	mv	a0,s1
    80004a1c:	60e2                	ld	ra,24(sp)
    80004a1e:	6442                	ld	s0,16(sp)
    80004a20:	64a2                	ld	s1,8(sp)
    80004a22:	6105                	addi	sp,sp,32
    80004a24:	8082                	ret

0000000080004a26 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004a26:	1101                	addi	sp,sp,-32
    80004a28:	ec06                	sd	ra,24(sp)
    80004a2a:	e822                	sd	s0,16(sp)
    80004a2c:	e426                	sd	s1,8(sp)
    80004a2e:	1000                	addi	s0,sp,32
    80004a30:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004a32:	0001e517          	auipc	a0,0x1e
    80004a36:	f2650513          	addi	a0,a0,-218 # 80022958 <ftable>
    80004a3a:	ffffc097          	auipc	ra,0xffffc
    80004a3e:	1b0080e7          	jalr	432(ra) # 80000bea <acquire>
  if(f->ref < 1)
    80004a42:	40dc                	lw	a5,4(s1)
    80004a44:	02f05263          	blez	a5,80004a68 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004a48:	2785                	addiw	a5,a5,1
    80004a4a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004a4c:	0001e517          	auipc	a0,0x1e
    80004a50:	f0c50513          	addi	a0,a0,-244 # 80022958 <ftable>
    80004a54:	ffffc097          	auipc	ra,0xffffc
    80004a58:	24a080e7          	jalr	586(ra) # 80000c9e <release>
  return f;
}
    80004a5c:	8526                	mv	a0,s1
    80004a5e:	60e2                	ld	ra,24(sp)
    80004a60:	6442                	ld	s0,16(sp)
    80004a62:	64a2                	ld	s1,8(sp)
    80004a64:	6105                	addi	sp,sp,32
    80004a66:	8082                	ret
    panic("filedup");
    80004a68:	00004517          	auipc	a0,0x4
    80004a6c:	d7850513          	addi	a0,a0,-648 # 800087e0 <syscalls+0x268>
    80004a70:	ffffc097          	auipc	ra,0xffffc
    80004a74:	ad4080e7          	jalr	-1324(ra) # 80000544 <panic>

0000000080004a78 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004a78:	7139                	addi	sp,sp,-64
    80004a7a:	fc06                	sd	ra,56(sp)
    80004a7c:	f822                	sd	s0,48(sp)
    80004a7e:	f426                	sd	s1,40(sp)
    80004a80:	f04a                	sd	s2,32(sp)
    80004a82:	ec4e                	sd	s3,24(sp)
    80004a84:	e852                	sd	s4,16(sp)
    80004a86:	e456                	sd	s5,8(sp)
    80004a88:	0080                	addi	s0,sp,64
    80004a8a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004a8c:	0001e517          	auipc	a0,0x1e
    80004a90:	ecc50513          	addi	a0,a0,-308 # 80022958 <ftable>
    80004a94:	ffffc097          	auipc	ra,0xffffc
    80004a98:	156080e7          	jalr	342(ra) # 80000bea <acquire>
  if(f->ref < 1)
    80004a9c:	40dc                	lw	a5,4(s1)
    80004a9e:	06f05163          	blez	a5,80004b00 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004aa2:	37fd                	addiw	a5,a5,-1
    80004aa4:	0007871b          	sext.w	a4,a5
    80004aa8:	c0dc                	sw	a5,4(s1)
    80004aaa:	06e04363          	bgtz	a4,80004b10 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004aae:	0004a903          	lw	s2,0(s1)
    80004ab2:	0094ca83          	lbu	s5,9(s1)
    80004ab6:	0104ba03          	ld	s4,16(s1)
    80004aba:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004abe:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004ac2:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004ac6:	0001e517          	auipc	a0,0x1e
    80004aca:	e9250513          	addi	a0,a0,-366 # 80022958 <ftable>
    80004ace:	ffffc097          	auipc	ra,0xffffc
    80004ad2:	1d0080e7          	jalr	464(ra) # 80000c9e <release>

  if(ff.type == FD_PIPE){
    80004ad6:	4785                	li	a5,1
    80004ad8:	04f90d63          	beq	s2,a5,80004b32 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004adc:	3979                	addiw	s2,s2,-2
    80004ade:	4785                	li	a5,1
    80004ae0:	0527e063          	bltu	a5,s2,80004b20 <fileclose+0xa8>
    begin_op();
    80004ae4:	00000097          	auipc	ra,0x0
    80004ae8:	ac8080e7          	jalr	-1336(ra) # 800045ac <begin_op>
    iput(ff.ip);
    80004aec:	854e                	mv	a0,s3
    80004aee:	fffff097          	auipc	ra,0xfffff
    80004af2:	2b6080e7          	jalr	694(ra) # 80003da4 <iput>
    end_op();
    80004af6:	00000097          	auipc	ra,0x0
    80004afa:	b36080e7          	jalr	-1226(ra) # 8000462c <end_op>
    80004afe:	a00d                	j	80004b20 <fileclose+0xa8>
    panic("fileclose");
    80004b00:	00004517          	auipc	a0,0x4
    80004b04:	ce850513          	addi	a0,a0,-792 # 800087e8 <syscalls+0x270>
    80004b08:	ffffc097          	auipc	ra,0xffffc
    80004b0c:	a3c080e7          	jalr	-1476(ra) # 80000544 <panic>
    release(&ftable.lock);
    80004b10:	0001e517          	auipc	a0,0x1e
    80004b14:	e4850513          	addi	a0,a0,-440 # 80022958 <ftable>
    80004b18:	ffffc097          	auipc	ra,0xffffc
    80004b1c:	186080e7          	jalr	390(ra) # 80000c9e <release>
  }
}
    80004b20:	70e2                	ld	ra,56(sp)
    80004b22:	7442                	ld	s0,48(sp)
    80004b24:	74a2                	ld	s1,40(sp)
    80004b26:	7902                	ld	s2,32(sp)
    80004b28:	69e2                	ld	s3,24(sp)
    80004b2a:	6a42                	ld	s4,16(sp)
    80004b2c:	6aa2                	ld	s5,8(sp)
    80004b2e:	6121                	addi	sp,sp,64
    80004b30:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004b32:	85d6                	mv	a1,s5
    80004b34:	8552                	mv	a0,s4
    80004b36:	00000097          	auipc	ra,0x0
    80004b3a:	34c080e7          	jalr	844(ra) # 80004e82 <pipeclose>
    80004b3e:	b7cd                	j	80004b20 <fileclose+0xa8>

0000000080004b40 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004b40:	715d                	addi	sp,sp,-80
    80004b42:	e486                	sd	ra,72(sp)
    80004b44:	e0a2                	sd	s0,64(sp)
    80004b46:	fc26                	sd	s1,56(sp)
    80004b48:	f84a                	sd	s2,48(sp)
    80004b4a:	f44e                	sd	s3,40(sp)
    80004b4c:	0880                	addi	s0,sp,80
    80004b4e:	84aa                	mv	s1,a0
    80004b50:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004b52:	ffffd097          	auipc	ra,0xffffd
    80004b56:	f7e080e7          	jalr	-130(ra) # 80001ad0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004b5a:	409c                	lw	a5,0(s1)
    80004b5c:	37f9                	addiw	a5,a5,-2
    80004b5e:	4705                	li	a4,1
    80004b60:	04f76763          	bltu	a4,a5,80004bae <filestat+0x6e>
    80004b64:	892a                	mv	s2,a0
    ilock(f->ip);
    80004b66:	6c88                	ld	a0,24(s1)
    80004b68:	fffff097          	auipc	ra,0xfffff
    80004b6c:	082080e7          	jalr	130(ra) # 80003bea <ilock>
    stati(f->ip, &st);
    80004b70:	fb840593          	addi	a1,s0,-72
    80004b74:	6c88                	ld	a0,24(s1)
    80004b76:	fffff097          	auipc	ra,0xfffff
    80004b7a:	2fe080e7          	jalr	766(ra) # 80003e74 <stati>
    iunlock(f->ip);
    80004b7e:	6c88                	ld	a0,24(s1)
    80004b80:	fffff097          	auipc	ra,0xfffff
    80004b84:	12c080e7          	jalr	300(ra) # 80003cac <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004b88:	46e1                	li	a3,24
    80004b8a:	fb840613          	addi	a2,s0,-72
    80004b8e:	85ce                	mv	a1,s3
    80004b90:	05893503          	ld	a0,88(s2)
    80004b94:	ffffd097          	auipc	ra,0xffffd
    80004b98:	af0080e7          	jalr	-1296(ra) # 80001684 <copyout>
    80004b9c:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004ba0:	60a6                	ld	ra,72(sp)
    80004ba2:	6406                	ld	s0,64(sp)
    80004ba4:	74e2                	ld	s1,56(sp)
    80004ba6:	7942                	ld	s2,48(sp)
    80004ba8:	79a2                	ld	s3,40(sp)
    80004baa:	6161                	addi	sp,sp,80
    80004bac:	8082                	ret
  return -1;
    80004bae:	557d                	li	a0,-1
    80004bb0:	bfc5                	j	80004ba0 <filestat+0x60>

0000000080004bb2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004bb2:	7179                	addi	sp,sp,-48
    80004bb4:	f406                	sd	ra,40(sp)
    80004bb6:	f022                	sd	s0,32(sp)
    80004bb8:	ec26                	sd	s1,24(sp)
    80004bba:	e84a                	sd	s2,16(sp)
    80004bbc:	e44e                	sd	s3,8(sp)
    80004bbe:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004bc0:	00854783          	lbu	a5,8(a0)
    80004bc4:	c3d5                	beqz	a5,80004c68 <fileread+0xb6>
    80004bc6:	84aa                	mv	s1,a0
    80004bc8:	89ae                	mv	s3,a1
    80004bca:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004bcc:	411c                	lw	a5,0(a0)
    80004bce:	4705                	li	a4,1
    80004bd0:	04e78963          	beq	a5,a4,80004c22 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004bd4:	470d                	li	a4,3
    80004bd6:	04e78d63          	beq	a5,a4,80004c30 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004bda:	4709                	li	a4,2
    80004bdc:	06e79e63          	bne	a5,a4,80004c58 <fileread+0xa6>
    ilock(f->ip);
    80004be0:	6d08                	ld	a0,24(a0)
    80004be2:	fffff097          	auipc	ra,0xfffff
    80004be6:	008080e7          	jalr	8(ra) # 80003bea <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004bea:	874a                	mv	a4,s2
    80004bec:	5094                	lw	a3,32(s1)
    80004bee:	864e                	mv	a2,s3
    80004bf0:	4585                	li	a1,1
    80004bf2:	6c88                	ld	a0,24(s1)
    80004bf4:	fffff097          	auipc	ra,0xfffff
    80004bf8:	2aa080e7          	jalr	682(ra) # 80003e9e <readi>
    80004bfc:	892a                	mv	s2,a0
    80004bfe:	00a05563          	blez	a0,80004c08 <fileread+0x56>
      f->off += r;
    80004c02:	509c                	lw	a5,32(s1)
    80004c04:	9fa9                	addw	a5,a5,a0
    80004c06:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004c08:	6c88                	ld	a0,24(s1)
    80004c0a:	fffff097          	auipc	ra,0xfffff
    80004c0e:	0a2080e7          	jalr	162(ra) # 80003cac <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004c12:	854a                	mv	a0,s2
    80004c14:	70a2                	ld	ra,40(sp)
    80004c16:	7402                	ld	s0,32(sp)
    80004c18:	64e2                	ld	s1,24(sp)
    80004c1a:	6942                	ld	s2,16(sp)
    80004c1c:	69a2                	ld	s3,8(sp)
    80004c1e:	6145                	addi	sp,sp,48
    80004c20:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004c22:	6908                	ld	a0,16(a0)
    80004c24:	00000097          	auipc	ra,0x0
    80004c28:	3ce080e7          	jalr	974(ra) # 80004ff2 <piperead>
    80004c2c:	892a                	mv	s2,a0
    80004c2e:	b7d5                	j	80004c12 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004c30:	02451783          	lh	a5,36(a0)
    80004c34:	03079693          	slli	a3,a5,0x30
    80004c38:	92c1                	srli	a3,a3,0x30
    80004c3a:	4725                	li	a4,9
    80004c3c:	02d76863          	bltu	a4,a3,80004c6c <fileread+0xba>
    80004c40:	0792                	slli	a5,a5,0x4
    80004c42:	0001e717          	auipc	a4,0x1e
    80004c46:	c7670713          	addi	a4,a4,-906 # 800228b8 <devsw>
    80004c4a:	97ba                	add	a5,a5,a4
    80004c4c:	639c                	ld	a5,0(a5)
    80004c4e:	c38d                	beqz	a5,80004c70 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004c50:	4505                	li	a0,1
    80004c52:	9782                	jalr	a5
    80004c54:	892a                	mv	s2,a0
    80004c56:	bf75                	j	80004c12 <fileread+0x60>
    panic("fileread");
    80004c58:	00004517          	auipc	a0,0x4
    80004c5c:	ba050513          	addi	a0,a0,-1120 # 800087f8 <syscalls+0x280>
    80004c60:	ffffc097          	auipc	ra,0xffffc
    80004c64:	8e4080e7          	jalr	-1820(ra) # 80000544 <panic>
    return -1;
    80004c68:	597d                	li	s2,-1
    80004c6a:	b765                	j	80004c12 <fileread+0x60>
      return -1;
    80004c6c:	597d                	li	s2,-1
    80004c6e:	b755                	j	80004c12 <fileread+0x60>
    80004c70:	597d                	li	s2,-1
    80004c72:	b745                	j	80004c12 <fileread+0x60>

0000000080004c74 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004c74:	715d                	addi	sp,sp,-80
    80004c76:	e486                	sd	ra,72(sp)
    80004c78:	e0a2                	sd	s0,64(sp)
    80004c7a:	fc26                	sd	s1,56(sp)
    80004c7c:	f84a                	sd	s2,48(sp)
    80004c7e:	f44e                	sd	s3,40(sp)
    80004c80:	f052                	sd	s4,32(sp)
    80004c82:	ec56                	sd	s5,24(sp)
    80004c84:	e85a                	sd	s6,16(sp)
    80004c86:	e45e                	sd	s7,8(sp)
    80004c88:	e062                	sd	s8,0(sp)
    80004c8a:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004c8c:	00954783          	lbu	a5,9(a0)
    80004c90:	10078663          	beqz	a5,80004d9c <filewrite+0x128>
    80004c94:	892a                	mv	s2,a0
    80004c96:	8aae                	mv	s5,a1
    80004c98:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004c9a:	411c                	lw	a5,0(a0)
    80004c9c:	4705                	li	a4,1
    80004c9e:	02e78263          	beq	a5,a4,80004cc2 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004ca2:	470d                	li	a4,3
    80004ca4:	02e78663          	beq	a5,a4,80004cd0 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004ca8:	4709                	li	a4,2
    80004caa:	0ee79163          	bne	a5,a4,80004d8c <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004cae:	0ac05d63          	blez	a2,80004d68 <filewrite+0xf4>
    int i = 0;
    80004cb2:	4981                	li	s3,0
    80004cb4:	6b05                	lui	s6,0x1
    80004cb6:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004cba:	6b85                	lui	s7,0x1
    80004cbc:	c00b8b9b          	addiw	s7,s7,-1024
    80004cc0:	a861                	j	80004d58 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004cc2:	6908                	ld	a0,16(a0)
    80004cc4:	00000097          	auipc	ra,0x0
    80004cc8:	22e080e7          	jalr	558(ra) # 80004ef2 <pipewrite>
    80004ccc:	8a2a                	mv	s4,a0
    80004cce:	a045                	j	80004d6e <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004cd0:	02451783          	lh	a5,36(a0)
    80004cd4:	03079693          	slli	a3,a5,0x30
    80004cd8:	92c1                	srli	a3,a3,0x30
    80004cda:	4725                	li	a4,9
    80004cdc:	0cd76263          	bltu	a4,a3,80004da0 <filewrite+0x12c>
    80004ce0:	0792                	slli	a5,a5,0x4
    80004ce2:	0001e717          	auipc	a4,0x1e
    80004ce6:	bd670713          	addi	a4,a4,-1066 # 800228b8 <devsw>
    80004cea:	97ba                	add	a5,a5,a4
    80004cec:	679c                	ld	a5,8(a5)
    80004cee:	cbdd                	beqz	a5,80004da4 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004cf0:	4505                	li	a0,1
    80004cf2:	9782                	jalr	a5
    80004cf4:	8a2a                	mv	s4,a0
    80004cf6:	a8a5                	j	80004d6e <filewrite+0xfa>
    80004cf8:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004cfc:	00000097          	auipc	ra,0x0
    80004d00:	8b0080e7          	jalr	-1872(ra) # 800045ac <begin_op>
      ilock(f->ip);
    80004d04:	01893503          	ld	a0,24(s2)
    80004d08:	fffff097          	auipc	ra,0xfffff
    80004d0c:	ee2080e7          	jalr	-286(ra) # 80003bea <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004d10:	8762                	mv	a4,s8
    80004d12:	02092683          	lw	a3,32(s2)
    80004d16:	01598633          	add	a2,s3,s5
    80004d1a:	4585                	li	a1,1
    80004d1c:	01893503          	ld	a0,24(s2)
    80004d20:	fffff097          	auipc	ra,0xfffff
    80004d24:	276080e7          	jalr	630(ra) # 80003f96 <writei>
    80004d28:	84aa                	mv	s1,a0
    80004d2a:	00a05763          	blez	a0,80004d38 <filewrite+0xc4>
        f->off += r;
    80004d2e:	02092783          	lw	a5,32(s2)
    80004d32:	9fa9                	addw	a5,a5,a0
    80004d34:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004d38:	01893503          	ld	a0,24(s2)
    80004d3c:	fffff097          	auipc	ra,0xfffff
    80004d40:	f70080e7          	jalr	-144(ra) # 80003cac <iunlock>
      end_op();
    80004d44:	00000097          	auipc	ra,0x0
    80004d48:	8e8080e7          	jalr	-1816(ra) # 8000462c <end_op>

      if(r != n1){
    80004d4c:	009c1f63          	bne	s8,s1,80004d6a <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004d50:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004d54:	0149db63          	bge	s3,s4,80004d6a <filewrite+0xf6>
      int n1 = n - i;
    80004d58:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004d5c:	84be                	mv	s1,a5
    80004d5e:	2781                	sext.w	a5,a5
    80004d60:	f8fb5ce3          	bge	s6,a5,80004cf8 <filewrite+0x84>
    80004d64:	84de                	mv	s1,s7
    80004d66:	bf49                	j	80004cf8 <filewrite+0x84>
    int i = 0;
    80004d68:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004d6a:	013a1f63          	bne	s4,s3,80004d88 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004d6e:	8552                	mv	a0,s4
    80004d70:	60a6                	ld	ra,72(sp)
    80004d72:	6406                	ld	s0,64(sp)
    80004d74:	74e2                	ld	s1,56(sp)
    80004d76:	7942                	ld	s2,48(sp)
    80004d78:	79a2                	ld	s3,40(sp)
    80004d7a:	7a02                	ld	s4,32(sp)
    80004d7c:	6ae2                	ld	s5,24(sp)
    80004d7e:	6b42                	ld	s6,16(sp)
    80004d80:	6ba2                	ld	s7,8(sp)
    80004d82:	6c02                	ld	s8,0(sp)
    80004d84:	6161                	addi	sp,sp,80
    80004d86:	8082                	ret
    ret = (i == n ? n : -1);
    80004d88:	5a7d                	li	s4,-1
    80004d8a:	b7d5                	j	80004d6e <filewrite+0xfa>
    panic("filewrite");
    80004d8c:	00004517          	auipc	a0,0x4
    80004d90:	a7c50513          	addi	a0,a0,-1412 # 80008808 <syscalls+0x290>
    80004d94:	ffffb097          	auipc	ra,0xffffb
    80004d98:	7b0080e7          	jalr	1968(ra) # 80000544 <panic>
    return -1;
    80004d9c:	5a7d                	li	s4,-1
    80004d9e:	bfc1                	j	80004d6e <filewrite+0xfa>
      return -1;
    80004da0:	5a7d                	li	s4,-1
    80004da2:	b7f1                	j	80004d6e <filewrite+0xfa>
    80004da4:	5a7d                	li	s4,-1
    80004da6:	b7e1                	j	80004d6e <filewrite+0xfa>

0000000080004da8 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004da8:	7179                	addi	sp,sp,-48
    80004daa:	f406                	sd	ra,40(sp)
    80004dac:	f022                	sd	s0,32(sp)
    80004dae:	ec26                	sd	s1,24(sp)
    80004db0:	e84a                	sd	s2,16(sp)
    80004db2:	e44e                	sd	s3,8(sp)
    80004db4:	e052                	sd	s4,0(sp)
    80004db6:	1800                	addi	s0,sp,48
    80004db8:	84aa                	mv	s1,a0
    80004dba:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004dbc:	0005b023          	sd	zero,0(a1)
    80004dc0:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004dc4:	00000097          	auipc	ra,0x0
    80004dc8:	bf8080e7          	jalr	-1032(ra) # 800049bc <filealloc>
    80004dcc:	e088                	sd	a0,0(s1)
    80004dce:	c551                	beqz	a0,80004e5a <pipealloc+0xb2>
    80004dd0:	00000097          	auipc	ra,0x0
    80004dd4:	bec080e7          	jalr	-1044(ra) # 800049bc <filealloc>
    80004dd8:	00aa3023          	sd	a0,0(s4)
    80004ddc:	c92d                	beqz	a0,80004e4e <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004dde:	ffffc097          	auipc	ra,0xffffc
    80004de2:	d1c080e7          	jalr	-740(ra) # 80000afa <kalloc>
    80004de6:	892a                	mv	s2,a0
    80004de8:	c125                	beqz	a0,80004e48 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004dea:	4985                	li	s3,1
    80004dec:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004df0:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004df4:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004df8:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004dfc:	00003597          	auipc	a1,0x3
    80004e00:	69c58593          	addi	a1,a1,1692 # 80008498 <states.2493+0x1b8>
    80004e04:	ffffc097          	auipc	ra,0xffffc
    80004e08:	d56080e7          	jalr	-682(ra) # 80000b5a <initlock>
  (*f0)->type = FD_PIPE;
    80004e0c:	609c                	ld	a5,0(s1)
    80004e0e:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004e12:	609c                	ld	a5,0(s1)
    80004e14:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004e18:	609c                	ld	a5,0(s1)
    80004e1a:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004e1e:	609c                	ld	a5,0(s1)
    80004e20:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004e24:	000a3783          	ld	a5,0(s4)
    80004e28:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004e2c:	000a3783          	ld	a5,0(s4)
    80004e30:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004e34:	000a3783          	ld	a5,0(s4)
    80004e38:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004e3c:	000a3783          	ld	a5,0(s4)
    80004e40:	0127b823          	sd	s2,16(a5)
  return 0;
    80004e44:	4501                	li	a0,0
    80004e46:	a025                	j	80004e6e <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004e48:	6088                	ld	a0,0(s1)
    80004e4a:	e501                	bnez	a0,80004e52 <pipealloc+0xaa>
    80004e4c:	a039                	j	80004e5a <pipealloc+0xb2>
    80004e4e:	6088                	ld	a0,0(s1)
    80004e50:	c51d                	beqz	a0,80004e7e <pipealloc+0xd6>
    fileclose(*f0);
    80004e52:	00000097          	auipc	ra,0x0
    80004e56:	c26080e7          	jalr	-986(ra) # 80004a78 <fileclose>
  if(*f1)
    80004e5a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004e5e:	557d                	li	a0,-1
  if(*f1)
    80004e60:	c799                	beqz	a5,80004e6e <pipealloc+0xc6>
    fileclose(*f1);
    80004e62:	853e                	mv	a0,a5
    80004e64:	00000097          	auipc	ra,0x0
    80004e68:	c14080e7          	jalr	-1004(ra) # 80004a78 <fileclose>
  return -1;
    80004e6c:	557d                	li	a0,-1
}
    80004e6e:	70a2                	ld	ra,40(sp)
    80004e70:	7402                	ld	s0,32(sp)
    80004e72:	64e2                	ld	s1,24(sp)
    80004e74:	6942                	ld	s2,16(sp)
    80004e76:	69a2                	ld	s3,8(sp)
    80004e78:	6a02                	ld	s4,0(sp)
    80004e7a:	6145                	addi	sp,sp,48
    80004e7c:	8082                	ret
  return -1;
    80004e7e:	557d                	li	a0,-1
    80004e80:	b7fd                	j	80004e6e <pipealloc+0xc6>

0000000080004e82 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004e82:	1101                	addi	sp,sp,-32
    80004e84:	ec06                	sd	ra,24(sp)
    80004e86:	e822                	sd	s0,16(sp)
    80004e88:	e426                	sd	s1,8(sp)
    80004e8a:	e04a                	sd	s2,0(sp)
    80004e8c:	1000                	addi	s0,sp,32
    80004e8e:	84aa                	mv	s1,a0
    80004e90:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004e92:	ffffc097          	auipc	ra,0xffffc
    80004e96:	d58080e7          	jalr	-680(ra) # 80000bea <acquire>
  if(writable){
    80004e9a:	02090d63          	beqz	s2,80004ed4 <pipeclose+0x52>
    pi->writeopen = 0;
    80004e9e:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004ea2:	21848513          	addi	a0,s1,536
    80004ea6:	ffffd097          	auipc	ra,0xffffd
    80004eaa:	4e0080e7          	jalr	1248(ra) # 80002386 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004eae:	2204b783          	ld	a5,544(s1)
    80004eb2:	eb95                	bnez	a5,80004ee6 <pipeclose+0x64>
    release(&pi->lock);
    80004eb4:	8526                	mv	a0,s1
    80004eb6:	ffffc097          	auipc	ra,0xffffc
    80004eba:	de8080e7          	jalr	-536(ra) # 80000c9e <release>
    kfree((char*)pi);
    80004ebe:	8526                	mv	a0,s1
    80004ec0:	ffffc097          	auipc	ra,0xffffc
    80004ec4:	b3e080e7          	jalr	-1218(ra) # 800009fe <kfree>
  } else
    release(&pi->lock);
}
    80004ec8:	60e2                	ld	ra,24(sp)
    80004eca:	6442                	ld	s0,16(sp)
    80004ecc:	64a2                	ld	s1,8(sp)
    80004ece:	6902                	ld	s2,0(sp)
    80004ed0:	6105                	addi	sp,sp,32
    80004ed2:	8082                	ret
    pi->readopen = 0;
    80004ed4:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004ed8:	21c48513          	addi	a0,s1,540
    80004edc:	ffffd097          	auipc	ra,0xffffd
    80004ee0:	4aa080e7          	jalr	1194(ra) # 80002386 <wakeup>
    80004ee4:	b7e9                	j	80004eae <pipeclose+0x2c>
    release(&pi->lock);
    80004ee6:	8526                	mv	a0,s1
    80004ee8:	ffffc097          	auipc	ra,0xffffc
    80004eec:	db6080e7          	jalr	-586(ra) # 80000c9e <release>
}
    80004ef0:	bfe1                	j	80004ec8 <pipeclose+0x46>

0000000080004ef2 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004ef2:	7159                	addi	sp,sp,-112
    80004ef4:	f486                	sd	ra,104(sp)
    80004ef6:	f0a2                	sd	s0,96(sp)
    80004ef8:	eca6                	sd	s1,88(sp)
    80004efa:	e8ca                	sd	s2,80(sp)
    80004efc:	e4ce                	sd	s3,72(sp)
    80004efe:	e0d2                	sd	s4,64(sp)
    80004f00:	fc56                	sd	s5,56(sp)
    80004f02:	f85a                	sd	s6,48(sp)
    80004f04:	f45e                	sd	s7,40(sp)
    80004f06:	f062                	sd	s8,32(sp)
    80004f08:	ec66                	sd	s9,24(sp)
    80004f0a:	1880                	addi	s0,sp,112
    80004f0c:	84aa                	mv	s1,a0
    80004f0e:	8aae                	mv	s5,a1
    80004f10:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004f12:	ffffd097          	auipc	ra,0xffffd
    80004f16:	bbe080e7          	jalr	-1090(ra) # 80001ad0 <myproc>
    80004f1a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004f1c:	8526                	mv	a0,s1
    80004f1e:	ffffc097          	auipc	ra,0xffffc
    80004f22:	ccc080e7          	jalr	-820(ra) # 80000bea <acquire>
  while(i < n){
    80004f26:	0d405463          	blez	s4,80004fee <pipewrite+0xfc>
    80004f2a:	8ba6                	mv	s7,s1
  int i = 0;
    80004f2c:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f2e:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004f30:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004f34:	21c48c13          	addi	s8,s1,540
    80004f38:	a08d                	j	80004f9a <pipewrite+0xa8>
      release(&pi->lock);
    80004f3a:	8526                	mv	a0,s1
    80004f3c:	ffffc097          	auipc	ra,0xffffc
    80004f40:	d62080e7          	jalr	-670(ra) # 80000c9e <release>
      return -1;
    80004f44:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004f46:	854a                	mv	a0,s2
    80004f48:	70a6                	ld	ra,104(sp)
    80004f4a:	7406                	ld	s0,96(sp)
    80004f4c:	64e6                	ld	s1,88(sp)
    80004f4e:	6946                	ld	s2,80(sp)
    80004f50:	69a6                	ld	s3,72(sp)
    80004f52:	6a06                	ld	s4,64(sp)
    80004f54:	7ae2                	ld	s5,56(sp)
    80004f56:	7b42                	ld	s6,48(sp)
    80004f58:	7ba2                	ld	s7,40(sp)
    80004f5a:	7c02                	ld	s8,32(sp)
    80004f5c:	6ce2                	ld	s9,24(sp)
    80004f5e:	6165                	addi	sp,sp,112
    80004f60:	8082                	ret
      wakeup(&pi->nread);
    80004f62:	8566                	mv	a0,s9
    80004f64:	ffffd097          	auipc	ra,0xffffd
    80004f68:	422080e7          	jalr	1058(ra) # 80002386 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004f6c:	85de                	mv	a1,s7
    80004f6e:	8562                	mv	a0,s8
    80004f70:	ffffd097          	auipc	ra,0xffffd
    80004f74:	278080e7          	jalr	632(ra) # 800021e8 <sleep>
    80004f78:	a839                	j	80004f96 <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004f7a:	21c4a783          	lw	a5,540(s1)
    80004f7e:	0017871b          	addiw	a4,a5,1
    80004f82:	20e4ae23          	sw	a4,540(s1)
    80004f86:	1ff7f793          	andi	a5,a5,511
    80004f8a:	97a6                	add	a5,a5,s1
    80004f8c:	f9f44703          	lbu	a4,-97(s0)
    80004f90:	00e78c23          	sb	a4,24(a5)
      i++;
    80004f94:	2905                	addiw	s2,s2,1
  while(i < n){
    80004f96:	05495063          	bge	s2,s4,80004fd6 <pipewrite+0xe4>
    if(pi->readopen == 0 || killed(pr)){
    80004f9a:	2204a783          	lw	a5,544(s1)
    80004f9e:	dfd1                	beqz	a5,80004f3a <pipewrite+0x48>
    80004fa0:	854e                	mv	a0,s3
    80004fa2:	ffffd097          	auipc	ra,0xffffd
    80004fa6:	644080e7          	jalr	1604(ra) # 800025e6 <killed>
    80004faa:	f941                	bnez	a0,80004f3a <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004fac:	2184a783          	lw	a5,536(s1)
    80004fb0:	21c4a703          	lw	a4,540(s1)
    80004fb4:	2007879b          	addiw	a5,a5,512
    80004fb8:	faf705e3          	beq	a4,a5,80004f62 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004fbc:	4685                	li	a3,1
    80004fbe:	01590633          	add	a2,s2,s5
    80004fc2:	f9f40593          	addi	a1,s0,-97
    80004fc6:	0589b503          	ld	a0,88(s3)
    80004fca:	ffffc097          	auipc	ra,0xffffc
    80004fce:	746080e7          	jalr	1862(ra) # 80001710 <copyin>
    80004fd2:	fb6514e3          	bne	a0,s6,80004f7a <pipewrite+0x88>
  wakeup(&pi->nread);
    80004fd6:	21848513          	addi	a0,s1,536
    80004fda:	ffffd097          	auipc	ra,0xffffd
    80004fde:	3ac080e7          	jalr	940(ra) # 80002386 <wakeup>
  release(&pi->lock);
    80004fe2:	8526                	mv	a0,s1
    80004fe4:	ffffc097          	auipc	ra,0xffffc
    80004fe8:	cba080e7          	jalr	-838(ra) # 80000c9e <release>
  return i;
    80004fec:	bfa9                	j	80004f46 <pipewrite+0x54>
  int i = 0;
    80004fee:	4901                	li	s2,0
    80004ff0:	b7dd                	j	80004fd6 <pipewrite+0xe4>

0000000080004ff2 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004ff2:	715d                	addi	sp,sp,-80
    80004ff4:	e486                	sd	ra,72(sp)
    80004ff6:	e0a2                	sd	s0,64(sp)
    80004ff8:	fc26                	sd	s1,56(sp)
    80004ffa:	f84a                	sd	s2,48(sp)
    80004ffc:	f44e                	sd	s3,40(sp)
    80004ffe:	f052                	sd	s4,32(sp)
    80005000:	ec56                	sd	s5,24(sp)
    80005002:	e85a                	sd	s6,16(sp)
    80005004:	0880                	addi	s0,sp,80
    80005006:	84aa                	mv	s1,a0
    80005008:	892e                	mv	s2,a1
    8000500a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000500c:	ffffd097          	auipc	ra,0xffffd
    80005010:	ac4080e7          	jalr	-1340(ra) # 80001ad0 <myproc>
    80005014:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005016:	8b26                	mv	s6,s1
    80005018:	8526                	mv	a0,s1
    8000501a:	ffffc097          	auipc	ra,0xffffc
    8000501e:	bd0080e7          	jalr	-1072(ra) # 80000bea <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005022:	2184a703          	lw	a4,536(s1)
    80005026:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000502a:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000502e:	02f71763          	bne	a4,a5,8000505c <piperead+0x6a>
    80005032:	2244a783          	lw	a5,548(s1)
    80005036:	c39d                	beqz	a5,8000505c <piperead+0x6a>
    if(killed(pr)){
    80005038:	8552                	mv	a0,s4
    8000503a:	ffffd097          	auipc	ra,0xffffd
    8000503e:	5ac080e7          	jalr	1452(ra) # 800025e6 <killed>
    80005042:	e941                	bnez	a0,800050d2 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005044:	85da                	mv	a1,s6
    80005046:	854e                	mv	a0,s3
    80005048:	ffffd097          	auipc	ra,0xffffd
    8000504c:	1a0080e7          	jalr	416(ra) # 800021e8 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005050:	2184a703          	lw	a4,536(s1)
    80005054:	21c4a783          	lw	a5,540(s1)
    80005058:	fcf70de3          	beq	a4,a5,80005032 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000505c:	09505263          	blez	s5,800050e0 <piperead+0xee>
    80005060:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005062:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80005064:	2184a783          	lw	a5,536(s1)
    80005068:	21c4a703          	lw	a4,540(s1)
    8000506c:	02f70d63          	beq	a4,a5,800050a6 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005070:	0017871b          	addiw	a4,a5,1
    80005074:	20e4ac23          	sw	a4,536(s1)
    80005078:	1ff7f793          	andi	a5,a5,511
    8000507c:	97a6                	add	a5,a5,s1
    8000507e:	0187c783          	lbu	a5,24(a5)
    80005082:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005086:	4685                	li	a3,1
    80005088:	fbf40613          	addi	a2,s0,-65
    8000508c:	85ca                	mv	a1,s2
    8000508e:	058a3503          	ld	a0,88(s4)
    80005092:	ffffc097          	auipc	ra,0xffffc
    80005096:	5f2080e7          	jalr	1522(ra) # 80001684 <copyout>
    8000509a:	01650663          	beq	a0,s6,800050a6 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000509e:	2985                	addiw	s3,s3,1
    800050a0:	0905                	addi	s2,s2,1
    800050a2:	fd3a91e3          	bne	s5,s3,80005064 <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800050a6:	21c48513          	addi	a0,s1,540
    800050aa:	ffffd097          	auipc	ra,0xffffd
    800050ae:	2dc080e7          	jalr	732(ra) # 80002386 <wakeup>
  release(&pi->lock);
    800050b2:	8526                	mv	a0,s1
    800050b4:	ffffc097          	auipc	ra,0xffffc
    800050b8:	bea080e7          	jalr	-1046(ra) # 80000c9e <release>
  return i;
}
    800050bc:	854e                	mv	a0,s3
    800050be:	60a6                	ld	ra,72(sp)
    800050c0:	6406                	ld	s0,64(sp)
    800050c2:	74e2                	ld	s1,56(sp)
    800050c4:	7942                	ld	s2,48(sp)
    800050c6:	79a2                	ld	s3,40(sp)
    800050c8:	7a02                	ld	s4,32(sp)
    800050ca:	6ae2                	ld	s5,24(sp)
    800050cc:	6b42                	ld	s6,16(sp)
    800050ce:	6161                	addi	sp,sp,80
    800050d0:	8082                	ret
      release(&pi->lock);
    800050d2:	8526                	mv	a0,s1
    800050d4:	ffffc097          	auipc	ra,0xffffc
    800050d8:	bca080e7          	jalr	-1078(ra) # 80000c9e <release>
      return -1;
    800050dc:	59fd                	li	s3,-1
    800050de:	bff9                	j	800050bc <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050e0:	4981                	li	s3,0
    800050e2:	b7d1                	j	800050a6 <piperead+0xb4>

00000000800050e4 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800050e4:	1141                	addi	sp,sp,-16
    800050e6:	e422                	sd	s0,8(sp)
    800050e8:	0800                	addi	s0,sp,16
    800050ea:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800050ec:	8905                	andi	a0,a0,1
    800050ee:	c111                	beqz	a0,800050f2 <flags2perm+0xe>
      perm = PTE_X;
    800050f0:	4521                	li	a0,8
    if(flags & 0x2)
    800050f2:	8b89                	andi	a5,a5,2
    800050f4:	c399                	beqz	a5,800050fa <flags2perm+0x16>
      perm |= PTE_W;
    800050f6:	00456513          	ori	a0,a0,4
    return perm;
}
    800050fa:	6422                	ld	s0,8(sp)
    800050fc:	0141                	addi	sp,sp,16
    800050fe:	8082                	ret

0000000080005100 <exec>:

int
exec(char *path, char **argv)
{
    80005100:	df010113          	addi	sp,sp,-528
    80005104:	20113423          	sd	ra,520(sp)
    80005108:	20813023          	sd	s0,512(sp)
    8000510c:	ffa6                	sd	s1,504(sp)
    8000510e:	fbca                	sd	s2,496(sp)
    80005110:	f7ce                	sd	s3,488(sp)
    80005112:	f3d2                	sd	s4,480(sp)
    80005114:	efd6                	sd	s5,472(sp)
    80005116:	ebda                	sd	s6,464(sp)
    80005118:	e7de                	sd	s7,456(sp)
    8000511a:	e3e2                	sd	s8,448(sp)
    8000511c:	ff66                	sd	s9,440(sp)
    8000511e:	fb6a                	sd	s10,432(sp)
    80005120:	f76e                	sd	s11,424(sp)
    80005122:	0c00                	addi	s0,sp,528
    80005124:	84aa                	mv	s1,a0
    80005126:	dea43c23          	sd	a0,-520(s0)
    8000512a:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000512e:	ffffd097          	auipc	ra,0xffffd
    80005132:	9a2080e7          	jalr	-1630(ra) # 80001ad0 <myproc>
    80005136:	892a                	mv	s2,a0

  begin_op();
    80005138:	fffff097          	auipc	ra,0xfffff
    8000513c:	474080e7          	jalr	1140(ra) # 800045ac <begin_op>

  if((ip = namei(path)) == 0){
    80005140:	8526                	mv	a0,s1
    80005142:	fffff097          	auipc	ra,0xfffff
    80005146:	24e080e7          	jalr	590(ra) # 80004390 <namei>
    8000514a:	c92d                	beqz	a0,800051bc <exec+0xbc>
    8000514c:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000514e:	fffff097          	auipc	ra,0xfffff
    80005152:	a9c080e7          	jalr	-1380(ra) # 80003bea <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005156:	04000713          	li	a4,64
    8000515a:	4681                	li	a3,0
    8000515c:	e5040613          	addi	a2,s0,-432
    80005160:	4581                	li	a1,0
    80005162:	8526                	mv	a0,s1
    80005164:	fffff097          	auipc	ra,0xfffff
    80005168:	d3a080e7          	jalr	-710(ra) # 80003e9e <readi>
    8000516c:	04000793          	li	a5,64
    80005170:	00f51a63          	bne	a0,a5,80005184 <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80005174:	e5042703          	lw	a4,-432(s0)
    80005178:	464c47b7          	lui	a5,0x464c4
    8000517c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005180:	04f70463          	beq	a4,a5,800051c8 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005184:	8526                	mv	a0,s1
    80005186:	fffff097          	auipc	ra,0xfffff
    8000518a:	cc6080e7          	jalr	-826(ra) # 80003e4c <iunlockput>
    end_op();
    8000518e:	fffff097          	auipc	ra,0xfffff
    80005192:	49e080e7          	jalr	1182(ra) # 8000462c <end_op>
  }
  return -1;
    80005196:	557d                	li	a0,-1
}
    80005198:	20813083          	ld	ra,520(sp)
    8000519c:	20013403          	ld	s0,512(sp)
    800051a0:	74fe                	ld	s1,504(sp)
    800051a2:	795e                	ld	s2,496(sp)
    800051a4:	79be                	ld	s3,488(sp)
    800051a6:	7a1e                	ld	s4,480(sp)
    800051a8:	6afe                	ld	s5,472(sp)
    800051aa:	6b5e                	ld	s6,464(sp)
    800051ac:	6bbe                	ld	s7,456(sp)
    800051ae:	6c1e                	ld	s8,448(sp)
    800051b0:	7cfa                	ld	s9,440(sp)
    800051b2:	7d5a                	ld	s10,432(sp)
    800051b4:	7dba                	ld	s11,424(sp)
    800051b6:	21010113          	addi	sp,sp,528
    800051ba:	8082                	ret
    end_op();
    800051bc:	fffff097          	auipc	ra,0xfffff
    800051c0:	470080e7          	jalr	1136(ra) # 8000462c <end_op>
    return -1;
    800051c4:	557d                	li	a0,-1
    800051c6:	bfc9                	j	80005198 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    800051c8:	854a                	mv	a0,s2
    800051ca:	ffffd097          	auipc	ra,0xffffd
    800051ce:	9cc080e7          	jalr	-1588(ra) # 80001b96 <proc_pagetable>
    800051d2:	8baa                	mv	s7,a0
    800051d4:	d945                	beqz	a0,80005184 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051d6:	e7042983          	lw	s3,-400(s0)
    800051da:	e8845783          	lhu	a5,-376(s0)
    800051de:	c7ad                	beqz	a5,80005248 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800051e0:	4a01                	li	s4,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051e2:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    800051e4:	6c85                	lui	s9,0x1
    800051e6:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800051ea:	def43823          	sd	a5,-528(s0)
    800051ee:	ac0d                	j	80005420 <exec+0x320>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800051f0:	00003517          	auipc	a0,0x3
    800051f4:	62850513          	addi	a0,a0,1576 # 80008818 <syscalls+0x2a0>
    800051f8:	ffffb097          	auipc	ra,0xffffb
    800051fc:	34c080e7          	jalr	844(ra) # 80000544 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005200:	8756                	mv	a4,s5
    80005202:	012d86bb          	addw	a3,s11,s2
    80005206:	4581                	li	a1,0
    80005208:	8526                	mv	a0,s1
    8000520a:	fffff097          	auipc	ra,0xfffff
    8000520e:	c94080e7          	jalr	-876(ra) # 80003e9e <readi>
    80005212:	2501                	sext.w	a0,a0
    80005214:	1aaa9a63          	bne	s5,a0,800053c8 <exec+0x2c8>
  for(i = 0; i < sz; i += PGSIZE){
    80005218:	6785                	lui	a5,0x1
    8000521a:	0127893b          	addw	s2,a5,s2
    8000521e:	77fd                	lui	a5,0xfffff
    80005220:	01478a3b          	addw	s4,a5,s4
    80005224:	1f897563          	bgeu	s2,s8,8000540e <exec+0x30e>
    pa = walkaddr(pagetable, va + i);
    80005228:	02091593          	slli	a1,s2,0x20
    8000522c:	9181                	srli	a1,a1,0x20
    8000522e:	95ea                	add	a1,a1,s10
    80005230:	855e                	mv	a0,s7
    80005232:	ffffc097          	auipc	ra,0xffffc
    80005236:	e46080e7          	jalr	-442(ra) # 80001078 <walkaddr>
    8000523a:	862a                	mv	a2,a0
    if(pa == 0)
    8000523c:	d955                	beqz	a0,800051f0 <exec+0xf0>
      n = PGSIZE;
    8000523e:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80005240:	fd9a70e3          	bgeu	s4,s9,80005200 <exec+0x100>
      n = sz - i;
    80005244:	8ad2                	mv	s5,s4
    80005246:	bf6d                	j	80005200 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005248:	4a01                	li	s4,0
  iunlockput(ip);
    8000524a:	8526                	mv	a0,s1
    8000524c:	fffff097          	auipc	ra,0xfffff
    80005250:	c00080e7          	jalr	-1024(ra) # 80003e4c <iunlockput>
  end_op();
    80005254:	fffff097          	auipc	ra,0xfffff
    80005258:	3d8080e7          	jalr	984(ra) # 8000462c <end_op>
  p = myproc();
    8000525c:	ffffd097          	auipc	ra,0xffffd
    80005260:	874080e7          	jalr	-1932(ra) # 80001ad0 <myproc>
    80005264:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005266:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    8000526a:	6785                	lui	a5,0x1
    8000526c:	17fd                	addi	a5,a5,-1
    8000526e:	9a3e                	add	s4,s4,a5
    80005270:	757d                	lui	a0,0xfffff
    80005272:	00aa77b3          	and	a5,s4,a0
    80005276:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    8000527a:	4691                	li	a3,4
    8000527c:	6609                	lui	a2,0x2
    8000527e:	963e                	add	a2,a2,a5
    80005280:	85be                	mv	a1,a5
    80005282:	855e                	mv	a0,s7
    80005284:	ffffc097          	auipc	ra,0xffffc
    80005288:	1a8080e7          	jalr	424(ra) # 8000142c <uvmalloc>
    8000528c:	8b2a                	mv	s6,a0
  ip = 0;
    8000528e:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005290:	12050c63          	beqz	a0,800053c8 <exec+0x2c8>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005294:	75f9                	lui	a1,0xffffe
    80005296:	95aa                	add	a1,a1,a0
    80005298:	855e                	mv	a0,s7
    8000529a:	ffffc097          	auipc	ra,0xffffc
    8000529e:	3b8080e7          	jalr	952(ra) # 80001652 <uvmclear>
  stackbase = sp - PGSIZE;
    800052a2:	7c7d                	lui	s8,0xfffff
    800052a4:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    800052a6:	e0043783          	ld	a5,-512(s0)
    800052aa:	6388                	ld	a0,0(a5)
    800052ac:	c535                	beqz	a0,80005318 <exec+0x218>
    800052ae:	e9040993          	addi	s3,s0,-368
    800052b2:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800052b6:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    800052b8:	ffffc097          	auipc	ra,0xffffc
    800052bc:	bb2080e7          	jalr	-1102(ra) # 80000e6a <strlen>
    800052c0:	2505                	addiw	a0,a0,1
    800052c2:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800052c6:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800052ca:	13896663          	bltu	s2,s8,800053f6 <exec+0x2f6>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800052ce:	e0043d83          	ld	s11,-512(s0)
    800052d2:	000dba03          	ld	s4,0(s11)
    800052d6:	8552                	mv	a0,s4
    800052d8:	ffffc097          	auipc	ra,0xffffc
    800052dc:	b92080e7          	jalr	-1134(ra) # 80000e6a <strlen>
    800052e0:	0015069b          	addiw	a3,a0,1
    800052e4:	8652                	mv	a2,s4
    800052e6:	85ca                	mv	a1,s2
    800052e8:	855e                	mv	a0,s7
    800052ea:	ffffc097          	auipc	ra,0xffffc
    800052ee:	39a080e7          	jalr	922(ra) # 80001684 <copyout>
    800052f2:	10054663          	bltz	a0,800053fe <exec+0x2fe>
    ustack[argc] = sp;
    800052f6:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800052fa:	0485                	addi	s1,s1,1
    800052fc:	008d8793          	addi	a5,s11,8
    80005300:	e0f43023          	sd	a5,-512(s0)
    80005304:	008db503          	ld	a0,8(s11)
    80005308:	c911                	beqz	a0,8000531c <exec+0x21c>
    if(argc >= MAXARG)
    8000530a:	09a1                	addi	s3,s3,8
    8000530c:	fb3c96e3          	bne	s9,s3,800052b8 <exec+0x1b8>
  sz = sz1;
    80005310:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005314:	4481                	li	s1,0
    80005316:	a84d                	j	800053c8 <exec+0x2c8>
  sp = sz;
    80005318:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    8000531a:	4481                	li	s1,0
  ustack[argc] = 0;
    8000531c:	00349793          	slli	a5,s1,0x3
    80005320:	f9040713          	addi	a4,s0,-112
    80005324:	97ba                	add	a5,a5,a4
    80005326:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    8000532a:	00148693          	addi	a3,s1,1
    8000532e:	068e                	slli	a3,a3,0x3
    80005330:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005334:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005338:	01897663          	bgeu	s2,s8,80005344 <exec+0x244>
  sz = sz1;
    8000533c:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005340:	4481                	li	s1,0
    80005342:	a059                	j	800053c8 <exec+0x2c8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005344:	e9040613          	addi	a2,s0,-368
    80005348:	85ca                	mv	a1,s2
    8000534a:	855e                	mv	a0,s7
    8000534c:	ffffc097          	auipc	ra,0xffffc
    80005350:	338080e7          	jalr	824(ra) # 80001684 <copyout>
    80005354:	0a054963          	bltz	a0,80005406 <exec+0x306>
  p->trapframe->a1 = sp;
    80005358:	060ab783          	ld	a5,96(s5)
    8000535c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005360:	df843783          	ld	a5,-520(s0)
    80005364:	0007c703          	lbu	a4,0(a5)
    80005368:	cf11                	beqz	a4,80005384 <exec+0x284>
    8000536a:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000536c:	02f00693          	li	a3,47
    80005370:	a039                	j	8000537e <exec+0x27e>
      last = s+1;
    80005372:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80005376:	0785                	addi	a5,a5,1
    80005378:	fff7c703          	lbu	a4,-1(a5)
    8000537c:	c701                	beqz	a4,80005384 <exec+0x284>
    if(*s == '/')
    8000537e:	fed71ce3          	bne	a4,a3,80005376 <exec+0x276>
    80005382:	bfc5                	j	80005372 <exec+0x272>
  safestrcpy(p->name, last, sizeof(p->name));
    80005384:	4641                	li	a2,16
    80005386:	df843583          	ld	a1,-520(s0)
    8000538a:	160a8513          	addi	a0,s5,352
    8000538e:	ffffc097          	auipc	ra,0xffffc
    80005392:	aaa080e7          	jalr	-1366(ra) # 80000e38 <safestrcpy>
  oldpagetable = p->pagetable;
    80005396:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    8000539a:	057abc23          	sd	s7,88(s5)
  p->sz = sz;
    8000539e:	056ab823          	sd	s6,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800053a2:	060ab783          	ld	a5,96(s5)
    800053a6:	e6843703          	ld	a4,-408(s0)
    800053aa:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800053ac:	060ab783          	ld	a5,96(s5)
    800053b0:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800053b4:	85ea                	mv	a1,s10
    800053b6:	ffffd097          	auipc	ra,0xffffd
    800053ba:	87c080e7          	jalr	-1924(ra) # 80001c32 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800053be:	0004851b          	sext.w	a0,s1
    800053c2:	bbd9                	j	80005198 <exec+0x98>
    800053c4:	e1443423          	sd	s4,-504(s0)
    proc_freepagetable(pagetable, sz);
    800053c8:	e0843583          	ld	a1,-504(s0)
    800053cc:	855e                	mv	a0,s7
    800053ce:	ffffd097          	auipc	ra,0xffffd
    800053d2:	864080e7          	jalr	-1948(ra) # 80001c32 <proc_freepagetable>
  if(ip){
    800053d6:	da0497e3          	bnez	s1,80005184 <exec+0x84>
  return -1;
    800053da:	557d                	li	a0,-1
    800053dc:	bb75                	j	80005198 <exec+0x98>
    800053de:	e1443423          	sd	s4,-504(s0)
    800053e2:	b7dd                	j	800053c8 <exec+0x2c8>
    800053e4:	e1443423          	sd	s4,-504(s0)
    800053e8:	b7c5                	j	800053c8 <exec+0x2c8>
    800053ea:	e1443423          	sd	s4,-504(s0)
    800053ee:	bfe9                	j	800053c8 <exec+0x2c8>
    800053f0:	e1443423          	sd	s4,-504(s0)
    800053f4:	bfd1                	j	800053c8 <exec+0x2c8>
  sz = sz1;
    800053f6:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800053fa:	4481                	li	s1,0
    800053fc:	b7f1                	j	800053c8 <exec+0x2c8>
  sz = sz1;
    800053fe:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005402:	4481                	li	s1,0
    80005404:	b7d1                	j	800053c8 <exec+0x2c8>
  sz = sz1;
    80005406:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000540a:	4481                	li	s1,0
    8000540c:	bf75                	j	800053c8 <exec+0x2c8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000540e:	e0843a03          	ld	s4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005412:	2b05                	addiw	s6,s6,1
    80005414:	0389899b          	addiw	s3,s3,56
    80005418:	e8845783          	lhu	a5,-376(s0)
    8000541c:	e2fb57e3          	bge	s6,a5,8000524a <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005420:	2981                	sext.w	s3,s3
    80005422:	03800713          	li	a4,56
    80005426:	86ce                	mv	a3,s3
    80005428:	e1840613          	addi	a2,s0,-488
    8000542c:	4581                	li	a1,0
    8000542e:	8526                	mv	a0,s1
    80005430:	fffff097          	auipc	ra,0xfffff
    80005434:	a6e080e7          	jalr	-1426(ra) # 80003e9e <readi>
    80005438:	03800793          	li	a5,56
    8000543c:	f8f514e3          	bne	a0,a5,800053c4 <exec+0x2c4>
    if(ph.type != ELF_PROG_LOAD)
    80005440:	e1842783          	lw	a5,-488(s0)
    80005444:	4705                	li	a4,1
    80005446:	fce796e3          	bne	a5,a4,80005412 <exec+0x312>
    if(ph.memsz < ph.filesz)
    8000544a:	e4043903          	ld	s2,-448(s0)
    8000544e:	e3843783          	ld	a5,-456(s0)
    80005452:	f8f966e3          	bltu	s2,a5,800053de <exec+0x2de>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005456:	e2843783          	ld	a5,-472(s0)
    8000545a:	993e                	add	s2,s2,a5
    8000545c:	f8f964e3          	bltu	s2,a5,800053e4 <exec+0x2e4>
    if(ph.vaddr % PGSIZE != 0)
    80005460:	df043703          	ld	a4,-528(s0)
    80005464:	8ff9                	and	a5,a5,a4
    80005466:	f3d1                	bnez	a5,800053ea <exec+0x2ea>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005468:	e1c42503          	lw	a0,-484(s0)
    8000546c:	00000097          	auipc	ra,0x0
    80005470:	c78080e7          	jalr	-904(ra) # 800050e4 <flags2perm>
    80005474:	86aa                	mv	a3,a0
    80005476:	864a                	mv	a2,s2
    80005478:	85d2                	mv	a1,s4
    8000547a:	855e                	mv	a0,s7
    8000547c:	ffffc097          	auipc	ra,0xffffc
    80005480:	fb0080e7          	jalr	-80(ra) # 8000142c <uvmalloc>
    80005484:	e0a43423          	sd	a0,-504(s0)
    80005488:	d525                	beqz	a0,800053f0 <exec+0x2f0>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000548a:	e2843d03          	ld	s10,-472(s0)
    8000548e:	e2042d83          	lw	s11,-480(s0)
    80005492:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005496:	f60c0ce3          	beqz	s8,8000540e <exec+0x30e>
    8000549a:	8a62                	mv	s4,s8
    8000549c:	4901                	li	s2,0
    8000549e:	b369                	j	80005228 <exec+0x128>

00000000800054a0 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800054a0:	7179                	addi	sp,sp,-48
    800054a2:	f406                	sd	ra,40(sp)
    800054a4:	f022                	sd	s0,32(sp)
    800054a6:	ec26                	sd	s1,24(sp)
    800054a8:	e84a                	sd	s2,16(sp)
    800054aa:	1800                	addi	s0,sp,48
    800054ac:	892e                	mv	s2,a1
    800054ae:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800054b0:	fdc40593          	addi	a1,s0,-36
    800054b4:	ffffe097          	auipc	ra,0xffffe
    800054b8:	914080e7          	jalr	-1772(ra) # 80002dc8 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800054bc:	fdc42703          	lw	a4,-36(s0)
    800054c0:	47bd                	li	a5,15
    800054c2:	02e7eb63          	bltu	a5,a4,800054f8 <argfd+0x58>
    800054c6:	ffffc097          	auipc	ra,0xffffc
    800054ca:	60a080e7          	jalr	1546(ra) # 80001ad0 <myproc>
    800054ce:	fdc42703          	lw	a4,-36(s0)
    800054d2:	01a70793          	addi	a5,a4,26
    800054d6:	078e                	slli	a5,a5,0x3
    800054d8:	953e                	add	a0,a0,a5
    800054da:	651c                	ld	a5,8(a0)
    800054dc:	c385                	beqz	a5,800054fc <argfd+0x5c>
    return -1;
  if(pfd)
    800054de:	00090463          	beqz	s2,800054e6 <argfd+0x46>
    *pfd = fd;
    800054e2:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800054e6:	4501                	li	a0,0
  if(pf)
    800054e8:	c091                	beqz	s1,800054ec <argfd+0x4c>
    *pf = f;
    800054ea:	e09c                	sd	a5,0(s1)
}
    800054ec:	70a2                	ld	ra,40(sp)
    800054ee:	7402                	ld	s0,32(sp)
    800054f0:	64e2                	ld	s1,24(sp)
    800054f2:	6942                	ld	s2,16(sp)
    800054f4:	6145                	addi	sp,sp,48
    800054f6:	8082                	ret
    return -1;
    800054f8:	557d                	li	a0,-1
    800054fa:	bfcd                	j	800054ec <argfd+0x4c>
    800054fc:	557d                	li	a0,-1
    800054fe:	b7fd                	j	800054ec <argfd+0x4c>

0000000080005500 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005500:	1101                	addi	sp,sp,-32
    80005502:	ec06                	sd	ra,24(sp)
    80005504:	e822                	sd	s0,16(sp)
    80005506:	e426                	sd	s1,8(sp)
    80005508:	1000                	addi	s0,sp,32
    8000550a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000550c:	ffffc097          	auipc	ra,0xffffc
    80005510:	5c4080e7          	jalr	1476(ra) # 80001ad0 <myproc>
    80005514:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005516:	0d850793          	addi	a5,a0,216 # fffffffffffff0d8 <end+0xffffffff7ffdb688>
    8000551a:	4501                	li	a0,0
    8000551c:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000551e:	6398                	ld	a4,0(a5)
    80005520:	cb19                	beqz	a4,80005536 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005522:	2505                	addiw	a0,a0,1
    80005524:	07a1                	addi	a5,a5,8
    80005526:	fed51ce3          	bne	a0,a3,8000551e <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000552a:	557d                	li	a0,-1
}
    8000552c:	60e2                	ld	ra,24(sp)
    8000552e:	6442                	ld	s0,16(sp)
    80005530:	64a2                	ld	s1,8(sp)
    80005532:	6105                	addi	sp,sp,32
    80005534:	8082                	ret
      p->ofile[fd] = f;
    80005536:	01a50793          	addi	a5,a0,26
    8000553a:	078e                	slli	a5,a5,0x3
    8000553c:	963e                	add	a2,a2,a5
    8000553e:	e604                	sd	s1,8(a2)
      return fd;
    80005540:	b7f5                	j	8000552c <fdalloc+0x2c>

0000000080005542 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005542:	715d                	addi	sp,sp,-80
    80005544:	e486                	sd	ra,72(sp)
    80005546:	e0a2                	sd	s0,64(sp)
    80005548:	fc26                	sd	s1,56(sp)
    8000554a:	f84a                	sd	s2,48(sp)
    8000554c:	f44e                	sd	s3,40(sp)
    8000554e:	f052                	sd	s4,32(sp)
    80005550:	ec56                	sd	s5,24(sp)
    80005552:	e85a                	sd	s6,16(sp)
    80005554:	0880                	addi	s0,sp,80
    80005556:	8b2e                	mv	s6,a1
    80005558:	89b2                	mv	s3,a2
    8000555a:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000555c:	fb040593          	addi	a1,s0,-80
    80005560:	fffff097          	auipc	ra,0xfffff
    80005564:	e4e080e7          	jalr	-434(ra) # 800043ae <nameiparent>
    80005568:	84aa                	mv	s1,a0
    8000556a:	16050063          	beqz	a0,800056ca <create+0x188>
    return 0;

  ilock(dp);
    8000556e:	ffffe097          	auipc	ra,0xffffe
    80005572:	67c080e7          	jalr	1660(ra) # 80003bea <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005576:	4601                	li	a2,0
    80005578:	fb040593          	addi	a1,s0,-80
    8000557c:	8526                	mv	a0,s1
    8000557e:	fffff097          	auipc	ra,0xfffff
    80005582:	b50080e7          	jalr	-1200(ra) # 800040ce <dirlookup>
    80005586:	8aaa                	mv	s5,a0
    80005588:	c931                	beqz	a0,800055dc <create+0x9a>
    iunlockput(dp);
    8000558a:	8526                	mv	a0,s1
    8000558c:	fffff097          	auipc	ra,0xfffff
    80005590:	8c0080e7          	jalr	-1856(ra) # 80003e4c <iunlockput>
    ilock(ip);
    80005594:	8556                	mv	a0,s5
    80005596:	ffffe097          	auipc	ra,0xffffe
    8000559a:	654080e7          	jalr	1620(ra) # 80003bea <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000559e:	000b059b          	sext.w	a1,s6
    800055a2:	4789                	li	a5,2
    800055a4:	02f59563          	bne	a1,a5,800055ce <create+0x8c>
    800055a8:	044ad783          	lhu	a5,68(s5)
    800055ac:	37f9                	addiw	a5,a5,-2
    800055ae:	17c2                	slli	a5,a5,0x30
    800055b0:	93c1                	srli	a5,a5,0x30
    800055b2:	4705                	li	a4,1
    800055b4:	00f76d63          	bltu	a4,a5,800055ce <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800055b8:	8556                	mv	a0,s5
    800055ba:	60a6                	ld	ra,72(sp)
    800055bc:	6406                	ld	s0,64(sp)
    800055be:	74e2                	ld	s1,56(sp)
    800055c0:	7942                	ld	s2,48(sp)
    800055c2:	79a2                	ld	s3,40(sp)
    800055c4:	7a02                	ld	s4,32(sp)
    800055c6:	6ae2                	ld	s5,24(sp)
    800055c8:	6b42                	ld	s6,16(sp)
    800055ca:	6161                	addi	sp,sp,80
    800055cc:	8082                	ret
    iunlockput(ip);
    800055ce:	8556                	mv	a0,s5
    800055d0:	fffff097          	auipc	ra,0xfffff
    800055d4:	87c080e7          	jalr	-1924(ra) # 80003e4c <iunlockput>
    return 0;
    800055d8:	4a81                	li	s5,0
    800055da:	bff9                	j	800055b8 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800055dc:	85da                	mv	a1,s6
    800055de:	4088                	lw	a0,0(s1)
    800055e0:	ffffe097          	auipc	ra,0xffffe
    800055e4:	46e080e7          	jalr	1134(ra) # 80003a4e <ialloc>
    800055e8:	8a2a                	mv	s4,a0
    800055ea:	c921                	beqz	a0,8000563a <create+0xf8>
  ilock(ip);
    800055ec:	ffffe097          	auipc	ra,0xffffe
    800055f0:	5fe080e7          	jalr	1534(ra) # 80003bea <ilock>
  ip->major = major;
    800055f4:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800055f8:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800055fc:	4785                	li	a5,1
    800055fe:	04fa1523          	sh	a5,74(s4)
  iupdate(ip);
    80005602:	8552                	mv	a0,s4
    80005604:	ffffe097          	auipc	ra,0xffffe
    80005608:	51c080e7          	jalr	1308(ra) # 80003b20 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000560c:	000b059b          	sext.w	a1,s6
    80005610:	4785                	li	a5,1
    80005612:	02f58b63          	beq	a1,a5,80005648 <create+0x106>
  if(dirlink(dp, name, ip->inum) < 0)
    80005616:	004a2603          	lw	a2,4(s4)
    8000561a:	fb040593          	addi	a1,s0,-80
    8000561e:	8526                	mv	a0,s1
    80005620:	fffff097          	auipc	ra,0xfffff
    80005624:	cbe080e7          	jalr	-834(ra) # 800042de <dirlink>
    80005628:	06054f63          	bltz	a0,800056a6 <create+0x164>
  iunlockput(dp);
    8000562c:	8526                	mv	a0,s1
    8000562e:	fffff097          	auipc	ra,0xfffff
    80005632:	81e080e7          	jalr	-2018(ra) # 80003e4c <iunlockput>
  return ip;
    80005636:	8ad2                	mv	s5,s4
    80005638:	b741                	j	800055b8 <create+0x76>
    iunlockput(dp);
    8000563a:	8526                	mv	a0,s1
    8000563c:	fffff097          	auipc	ra,0xfffff
    80005640:	810080e7          	jalr	-2032(ra) # 80003e4c <iunlockput>
    return 0;
    80005644:	8ad2                	mv	s5,s4
    80005646:	bf8d                	j	800055b8 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005648:	004a2603          	lw	a2,4(s4)
    8000564c:	00003597          	auipc	a1,0x3
    80005650:	1ec58593          	addi	a1,a1,492 # 80008838 <syscalls+0x2c0>
    80005654:	8552                	mv	a0,s4
    80005656:	fffff097          	auipc	ra,0xfffff
    8000565a:	c88080e7          	jalr	-888(ra) # 800042de <dirlink>
    8000565e:	04054463          	bltz	a0,800056a6 <create+0x164>
    80005662:	40d0                	lw	a2,4(s1)
    80005664:	00003597          	auipc	a1,0x3
    80005668:	1dc58593          	addi	a1,a1,476 # 80008840 <syscalls+0x2c8>
    8000566c:	8552                	mv	a0,s4
    8000566e:	fffff097          	auipc	ra,0xfffff
    80005672:	c70080e7          	jalr	-912(ra) # 800042de <dirlink>
    80005676:	02054863          	bltz	a0,800056a6 <create+0x164>
  if(dirlink(dp, name, ip->inum) < 0)
    8000567a:	004a2603          	lw	a2,4(s4)
    8000567e:	fb040593          	addi	a1,s0,-80
    80005682:	8526                	mv	a0,s1
    80005684:	fffff097          	auipc	ra,0xfffff
    80005688:	c5a080e7          	jalr	-934(ra) # 800042de <dirlink>
    8000568c:	00054d63          	bltz	a0,800056a6 <create+0x164>
    dp->nlink++;  // for ".."
    80005690:	04a4d783          	lhu	a5,74(s1)
    80005694:	2785                	addiw	a5,a5,1
    80005696:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000569a:	8526                	mv	a0,s1
    8000569c:	ffffe097          	auipc	ra,0xffffe
    800056a0:	484080e7          	jalr	1156(ra) # 80003b20 <iupdate>
    800056a4:	b761                	j	8000562c <create+0xea>
  ip->nlink = 0;
    800056a6:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800056aa:	8552                	mv	a0,s4
    800056ac:	ffffe097          	auipc	ra,0xffffe
    800056b0:	474080e7          	jalr	1140(ra) # 80003b20 <iupdate>
  iunlockput(ip);
    800056b4:	8552                	mv	a0,s4
    800056b6:	ffffe097          	auipc	ra,0xffffe
    800056ba:	796080e7          	jalr	1942(ra) # 80003e4c <iunlockput>
  iunlockput(dp);
    800056be:	8526                	mv	a0,s1
    800056c0:	ffffe097          	auipc	ra,0xffffe
    800056c4:	78c080e7          	jalr	1932(ra) # 80003e4c <iunlockput>
  return 0;
    800056c8:	bdc5                	j	800055b8 <create+0x76>
    return 0;
    800056ca:	8aaa                	mv	s5,a0
    800056cc:	b5f5                	j	800055b8 <create+0x76>

00000000800056ce <sys_dup>:
{
    800056ce:	7179                	addi	sp,sp,-48
    800056d0:	f406                	sd	ra,40(sp)
    800056d2:	f022                	sd	s0,32(sp)
    800056d4:	ec26                	sd	s1,24(sp)
    800056d6:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800056d8:	fd840613          	addi	a2,s0,-40
    800056dc:	4581                	li	a1,0
    800056de:	4501                	li	a0,0
    800056e0:	00000097          	auipc	ra,0x0
    800056e4:	dc0080e7          	jalr	-576(ra) # 800054a0 <argfd>
    return -1;
    800056e8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800056ea:	02054363          	bltz	a0,80005710 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800056ee:	fd843503          	ld	a0,-40(s0)
    800056f2:	00000097          	auipc	ra,0x0
    800056f6:	e0e080e7          	jalr	-498(ra) # 80005500 <fdalloc>
    800056fa:	84aa                	mv	s1,a0
    return -1;
    800056fc:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800056fe:	00054963          	bltz	a0,80005710 <sys_dup+0x42>
  filedup(f);
    80005702:	fd843503          	ld	a0,-40(s0)
    80005706:	fffff097          	auipc	ra,0xfffff
    8000570a:	320080e7          	jalr	800(ra) # 80004a26 <filedup>
  return fd;
    8000570e:	87a6                	mv	a5,s1
}
    80005710:	853e                	mv	a0,a5
    80005712:	70a2                	ld	ra,40(sp)
    80005714:	7402                	ld	s0,32(sp)
    80005716:	64e2                	ld	s1,24(sp)
    80005718:	6145                	addi	sp,sp,48
    8000571a:	8082                	ret

000000008000571c <sys_read>:
{
    8000571c:	7179                	addi	sp,sp,-48
    8000571e:	f406                	sd	ra,40(sp)
    80005720:	f022                	sd	s0,32(sp)
    80005722:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005724:	fd840593          	addi	a1,s0,-40
    80005728:	4505                	li	a0,1
    8000572a:	ffffd097          	auipc	ra,0xffffd
    8000572e:	6be080e7          	jalr	1726(ra) # 80002de8 <argaddr>
  argint(2, &n);
    80005732:	fe440593          	addi	a1,s0,-28
    80005736:	4509                	li	a0,2
    80005738:	ffffd097          	auipc	ra,0xffffd
    8000573c:	690080e7          	jalr	1680(ra) # 80002dc8 <argint>
  if(argfd(0, 0, &f) < 0)
    80005740:	fe840613          	addi	a2,s0,-24
    80005744:	4581                	li	a1,0
    80005746:	4501                	li	a0,0
    80005748:	00000097          	auipc	ra,0x0
    8000574c:	d58080e7          	jalr	-680(ra) # 800054a0 <argfd>
    80005750:	87aa                	mv	a5,a0
    return -1;
    80005752:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005754:	0007cc63          	bltz	a5,8000576c <sys_read+0x50>
  return fileread(f, p, n);
    80005758:	fe442603          	lw	a2,-28(s0)
    8000575c:	fd843583          	ld	a1,-40(s0)
    80005760:	fe843503          	ld	a0,-24(s0)
    80005764:	fffff097          	auipc	ra,0xfffff
    80005768:	44e080e7          	jalr	1102(ra) # 80004bb2 <fileread>
}
    8000576c:	70a2                	ld	ra,40(sp)
    8000576e:	7402                	ld	s0,32(sp)
    80005770:	6145                	addi	sp,sp,48
    80005772:	8082                	ret

0000000080005774 <sys_write>:
{
    80005774:	7179                	addi	sp,sp,-48
    80005776:	f406                	sd	ra,40(sp)
    80005778:	f022                	sd	s0,32(sp)
    8000577a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000577c:	fd840593          	addi	a1,s0,-40
    80005780:	4505                	li	a0,1
    80005782:	ffffd097          	auipc	ra,0xffffd
    80005786:	666080e7          	jalr	1638(ra) # 80002de8 <argaddr>
  argint(2, &n);
    8000578a:	fe440593          	addi	a1,s0,-28
    8000578e:	4509                	li	a0,2
    80005790:	ffffd097          	auipc	ra,0xffffd
    80005794:	638080e7          	jalr	1592(ra) # 80002dc8 <argint>
  if(argfd(0, 0, &f) < 0)
    80005798:	fe840613          	addi	a2,s0,-24
    8000579c:	4581                	li	a1,0
    8000579e:	4501                	li	a0,0
    800057a0:	00000097          	auipc	ra,0x0
    800057a4:	d00080e7          	jalr	-768(ra) # 800054a0 <argfd>
    800057a8:	87aa                	mv	a5,a0
    return -1;
    800057aa:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800057ac:	0007cc63          	bltz	a5,800057c4 <sys_write+0x50>
  return filewrite(f, p, n);
    800057b0:	fe442603          	lw	a2,-28(s0)
    800057b4:	fd843583          	ld	a1,-40(s0)
    800057b8:	fe843503          	ld	a0,-24(s0)
    800057bc:	fffff097          	auipc	ra,0xfffff
    800057c0:	4b8080e7          	jalr	1208(ra) # 80004c74 <filewrite>
}
    800057c4:	70a2                	ld	ra,40(sp)
    800057c6:	7402                	ld	s0,32(sp)
    800057c8:	6145                	addi	sp,sp,48
    800057ca:	8082                	ret

00000000800057cc <sys_close>:
{
    800057cc:	1101                	addi	sp,sp,-32
    800057ce:	ec06                	sd	ra,24(sp)
    800057d0:	e822                	sd	s0,16(sp)
    800057d2:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800057d4:	fe040613          	addi	a2,s0,-32
    800057d8:	fec40593          	addi	a1,s0,-20
    800057dc:	4501                	li	a0,0
    800057de:	00000097          	auipc	ra,0x0
    800057e2:	cc2080e7          	jalr	-830(ra) # 800054a0 <argfd>
    return -1;
    800057e6:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800057e8:	02054463          	bltz	a0,80005810 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800057ec:	ffffc097          	auipc	ra,0xffffc
    800057f0:	2e4080e7          	jalr	740(ra) # 80001ad0 <myproc>
    800057f4:	fec42783          	lw	a5,-20(s0)
    800057f8:	07e9                	addi	a5,a5,26
    800057fa:	078e                	slli	a5,a5,0x3
    800057fc:	97aa                	add	a5,a5,a0
    800057fe:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    80005802:	fe043503          	ld	a0,-32(s0)
    80005806:	fffff097          	auipc	ra,0xfffff
    8000580a:	272080e7          	jalr	626(ra) # 80004a78 <fileclose>
  return 0;
    8000580e:	4781                	li	a5,0
}
    80005810:	853e                	mv	a0,a5
    80005812:	60e2                	ld	ra,24(sp)
    80005814:	6442                	ld	s0,16(sp)
    80005816:	6105                	addi	sp,sp,32
    80005818:	8082                	ret

000000008000581a <sys_fstat>:
{
    8000581a:	1101                	addi	sp,sp,-32
    8000581c:	ec06                	sd	ra,24(sp)
    8000581e:	e822                	sd	s0,16(sp)
    80005820:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005822:	fe040593          	addi	a1,s0,-32
    80005826:	4505                	li	a0,1
    80005828:	ffffd097          	auipc	ra,0xffffd
    8000582c:	5c0080e7          	jalr	1472(ra) # 80002de8 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005830:	fe840613          	addi	a2,s0,-24
    80005834:	4581                	li	a1,0
    80005836:	4501                	li	a0,0
    80005838:	00000097          	auipc	ra,0x0
    8000583c:	c68080e7          	jalr	-920(ra) # 800054a0 <argfd>
    80005840:	87aa                	mv	a5,a0
    return -1;
    80005842:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005844:	0007ca63          	bltz	a5,80005858 <sys_fstat+0x3e>
  return filestat(f, st);
    80005848:	fe043583          	ld	a1,-32(s0)
    8000584c:	fe843503          	ld	a0,-24(s0)
    80005850:	fffff097          	auipc	ra,0xfffff
    80005854:	2f0080e7          	jalr	752(ra) # 80004b40 <filestat>
}
    80005858:	60e2                	ld	ra,24(sp)
    8000585a:	6442                	ld	s0,16(sp)
    8000585c:	6105                	addi	sp,sp,32
    8000585e:	8082                	ret

0000000080005860 <sys_link>:
{
    80005860:	7169                	addi	sp,sp,-304
    80005862:	f606                	sd	ra,296(sp)
    80005864:	f222                	sd	s0,288(sp)
    80005866:	ee26                	sd	s1,280(sp)
    80005868:	ea4a                	sd	s2,272(sp)
    8000586a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000586c:	08000613          	li	a2,128
    80005870:	ed040593          	addi	a1,s0,-304
    80005874:	4501                	li	a0,0
    80005876:	ffffd097          	auipc	ra,0xffffd
    8000587a:	592080e7          	jalr	1426(ra) # 80002e08 <argstr>
    return -1;
    8000587e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005880:	10054e63          	bltz	a0,8000599c <sys_link+0x13c>
    80005884:	08000613          	li	a2,128
    80005888:	f5040593          	addi	a1,s0,-176
    8000588c:	4505                	li	a0,1
    8000588e:	ffffd097          	auipc	ra,0xffffd
    80005892:	57a080e7          	jalr	1402(ra) # 80002e08 <argstr>
    return -1;
    80005896:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005898:	10054263          	bltz	a0,8000599c <sys_link+0x13c>
  begin_op();
    8000589c:	fffff097          	auipc	ra,0xfffff
    800058a0:	d10080e7          	jalr	-752(ra) # 800045ac <begin_op>
  if((ip = namei(old)) == 0){
    800058a4:	ed040513          	addi	a0,s0,-304
    800058a8:	fffff097          	auipc	ra,0xfffff
    800058ac:	ae8080e7          	jalr	-1304(ra) # 80004390 <namei>
    800058b0:	84aa                	mv	s1,a0
    800058b2:	c551                	beqz	a0,8000593e <sys_link+0xde>
  ilock(ip);
    800058b4:	ffffe097          	auipc	ra,0xffffe
    800058b8:	336080e7          	jalr	822(ra) # 80003bea <ilock>
  if(ip->type == T_DIR){
    800058bc:	04449703          	lh	a4,68(s1)
    800058c0:	4785                	li	a5,1
    800058c2:	08f70463          	beq	a4,a5,8000594a <sys_link+0xea>
  ip->nlink++;
    800058c6:	04a4d783          	lhu	a5,74(s1)
    800058ca:	2785                	addiw	a5,a5,1
    800058cc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800058d0:	8526                	mv	a0,s1
    800058d2:	ffffe097          	auipc	ra,0xffffe
    800058d6:	24e080e7          	jalr	590(ra) # 80003b20 <iupdate>
  iunlock(ip);
    800058da:	8526                	mv	a0,s1
    800058dc:	ffffe097          	auipc	ra,0xffffe
    800058e0:	3d0080e7          	jalr	976(ra) # 80003cac <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800058e4:	fd040593          	addi	a1,s0,-48
    800058e8:	f5040513          	addi	a0,s0,-176
    800058ec:	fffff097          	auipc	ra,0xfffff
    800058f0:	ac2080e7          	jalr	-1342(ra) # 800043ae <nameiparent>
    800058f4:	892a                	mv	s2,a0
    800058f6:	c935                	beqz	a0,8000596a <sys_link+0x10a>
  ilock(dp);
    800058f8:	ffffe097          	auipc	ra,0xffffe
    800058fc:	2f2080e7          	jalr	754(ra) # 80003bea <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005900:	00092703          	lw	a4,0(s2)
    80005904:	409c                	lw	a5,0(s1)
    80005906:	04f71d63          	bne	a4,a5,80005960 <sys_link+0x100>
    8000590a:	40d0                	lw	a2,4(s1)
    8000590c:	fd040593          	addi	a1,s0,-48
    80005910:	854a                	mv	a0,s2
    80005912:	fffff097          	auipc	ra,0xfffff
    80005916:	9cc080e7          	jalr	-1588(ra) # 800042de <dirlink>
    8000591a:	04054363          	bltz	a0,80005960 <sys_link+0x100>
  iunlockput(dp);
    8000591e:	854a                	mv	a0,s2
    80005920:	ffffe097          	auipc	ra,0xffffe
    80005924:	52c080e7          	jalr	1324(ra) # 80003e4c <iunlockput>
  iput(ip);
    80005928:	8526                	mv	a0,s1
    8000592a:	ffffe097          	auipc	ra,0xffffe
    8000592e:	47a080e7          	jalr	1146(ra) # 80003da4 <iput>
  end_op();
    80005932:	fffff097          	auipc	ra,0xfffff
    80005936:	cfa080e7          	jalr	-774(ra) # 8000462c <end_op>
  return 0;
    8000593a:	4781                	li	a5,0
    8000593c:	a085                	j	8000599c <sys_link+0x13c>
    end_op();
    8000593e:	fffff097          	auipc	ra,0xfffff
    80005942:	cee080e7          	jalr	-786(ra) # 8000462c <end_op>
    return -1;
    80005946:	57fd                	li	a5,-1
    80005948:	a891                	j	8000599c <sys_link+0x13c>
    iunlockput(ip);
    8000594a:	8526                	mv	a0,s1
    8000594c:	ffffe097          	auipc	ra,0xffffe
    80005950:	500080e7          	jalr	1280(ra) # 80003e4c <iunlockput>
    end_op();
    80005954:	fffff097          	auipc	ra,0xfffff
    80005958:	cd8080e7          	jalr	-808(ra) # 8000462c <end_op>
    return -1;
    8000595c:	57fd                	li	a5,-1
    8000595e:	a83d                	j	8000599c <sys_link+0x13c>
    iunlockput(dp);
    80005960:	854a                	mv	a0,s2
    80005962:	ffffe097          	auipc	ra,0xffffe
    80005966:	4ea080e7          	jalr	1258(ra) # 80003e4c <iunlockput>
  ilock(ip);
    8000596a:	8526                	mv	a0,s1
    8000596c:	ffffe097          	auipc	ra,0xffffe
    80005970:	27e080e7          	jalr	638(ra) # 80003bea <ilock>
  ip->nlink--;
    80005974:	04a4d783          	lhu	a5,74(s1)
    80005978:	37fd                	addiw	a5,a5,-1
    8000597a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000597e:	8526                	mv	a0,s1
    80005980:	ffffe097          	auipc	ra,0xffffe
    80005984:	1a0080e7          	jalr	416(ra) # 80003b20 <iupdate>
  iunlockput(ip);
    80005988:	8526                	mv	a0,s1
    8000598a:	ffffe097          	auipc	ra,0xffffe
    8000598e:	4c2080e7          	jalr	1218(ra) # 80003e4c <iunlockput>
  end_op();
    80005992:	fffff097          	auipc	ra,0xfffff
    80005996:	c9a080e7          	jalr	-870(ra) # 8000462c <end_op>
  return -1;
    8000599a:	57fd                	li	a5,-1
}
    8000599c:	853e                	mv	a0,a5
    8000599e:	70b2                	ld	ra,296(sp)
    800059a0:	7412                	ld	s0,288(sp)
    800059a2:	64f2                	ld	s1,280(sp)
    800059a4:	6952                	ld	s2,272(sp)
    800059a6:	6155                	addi	sp,sp,304
    800059a8:	8082                	ret

00000000800059aa <sys_unlink>:
{
    800059aa:	7151                	addi	sp,sp,-240
    800059ac:	f586                	sd	ra,232(sp)
    800059ae:	f1a2                	sd	s0,224(sp)
    800059b0:	eda6                	sd	s1,216(sp)
    800059b2:	e9ca                	sd	s2,208(sp)
    800059b4:	e5ce                	sd	s3,200(sp)
    800059b6:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800059b8:	08000613          	li	a2,128
    800059bc:	f3040593          	addi	a1,s0,-208
    800059c0:	4501                	li	a0,0
    800059c2:	ffffd097          	auipc	ra,0xffffd
    800059c6:	446080e7          	jalr	1094(ra) # 80002e08 <argstr>
    800059ca:	18054163          	bltz	a0,80005b4c <sys_unlink+0x1a2>
  begin_op();
    800059ce:	fffff097          	auipc	ra,0xfffff
    800059d2:	bde080e7          	jalr	-1058(ra) # 800045ac <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800059d6:	fb040593          	addi	a1,s0,-80
    800059da:	f3040513          	addi	a0,s0,-208
    800059de:	fffff097          	auipc	ra,0xfffff
    800059e2:	9d0080e7          	jalr	-1584(ra) # 800043ae <nameiparent>
    800059e6:	84aa                	mv	s1,a0
    800059e8:	c979                	beqz	a0,80005abe <sys_unlink+0x114>
  ilock(dp);
    800059ea:	ffffe097          	auipc	ra,0xffffe
    800059ee:	200080e7          	jalr	512(ra) # 80003bea <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800059f2:	00003597          	auipc	a1,0x3
    800059f6:	e4658593          	addi	a1,a1,-442 # 80008838 <syscalls+0x2c0>
    800059fa:	fb040513          	addi	a0,s0,-80
    800059fe:	ffffe097          	auipc	ra,0xffffe
    80005a02:	6b6080e7          	jalr	1718(ra) # 800040b4 <namecmp>
    80005a06:	14050a63          	beqz	a0,80005b5a <sys_unlink+0x1b0>
    80005a0a:	00003597          	auipc	a1,0x3
    80005a0e:	e3658593          	addi	a1,a1,-458 # 80008840 <syscalls+0x2c8>
    80005a12:	fb040513          	addi	a0,s0,-80
    80005a16:	ffffe097          	auipc	ra,0xffffe
    80005a1a:	69e080e7          	jalr	1694(ra) # 800040b4 <namecmp>
    80005a1e:	12050e63          	beqz	a0,80005b5a <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005a22:	f2c40613          	addi	a2,s0,-212
    80005a26:	fb040593          	addi	a1,s0,-80
    80005a2a:	8526                	mv	a0,s1
    80005a2c:	ffffe097          	auipc	ra,0xffffe
    80005a30:	6a2080e7          	jalr	1698(ra) # 800040ce <dirlookup>
    80005a34:	892a                	mv	s2,a0
    80005a36:	12050263          	beqz	a0,80005b5a <sys_unlink+0x1b0>
  ilock(ip);
    80005a3a:	ffffe097          	auipc	ra,0xffffe
    80005a3e:	1b0080e7          	jalr	432(ra) # 80003bea <ilock>
  if(ip->nlink < 1)
    80005a42:	04a91783          	lh	a5,74(s2)
    80005a46:	08f05263          	blez	a5,80005aca <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005a4a:	04491703          	lh	a4,68(s2)
    80005a4e:	4785                	li	a5,1
    80005a50:	08f70563          	beq	a4,a5,80005ada <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005a54:	4641                	li	a2,16
    80005a56:	4581                	li	a1,0
    80005a58:	fc040513          	addi	a0,s0,-64
    80005a5c:	ffffb097          	auipc	ra,0xffffb
    80005a60:	28a080e7          	jalr	650(ra) # 80000ce6 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005a64:	4741                	li	a4,16
    80005a66:	f2c42683          	lw	a3,-212(s0)
    80005a6a:	fc040613          	addi	a2,s0,-64
    80005a6e:	4581                	li	a1,0
    80005a70:	8526                	mv	a0,s1
    80005a72:	ffffe097          	auipc	ra,0xffffe
    80005a76:	524080e7          	jalr	1316(ra) # 80003f96 <writei>
    80005a7a:	47c1                	li	a5,16
    80005a7c:	0af51563          	bne	a0,a5,80005b26 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005a80:	04491703          	lh	a4,68(s2)
    80005a84:	4785                	li	a5,1
    80005a86:	0af70863          	beq	a4,a5,80005b36 <sys_unlink+0x18c>
  iunlockput(dp);
    80005a8a:	8526                	mv	a0,s1
    80005a8c:	ffffe097          	auipc	ra,0xffffe
    80005a90:	3c0080e7          	jalr	960(ra) # 80003e4c <iunlockput>
  ip->nlink--;
    80005a94:	04a95783          	lhu	a5,74(s2)
    80005a98:	37fd                	addiw	a5,a5,-1
    80005a9a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005a9e:	854a                	mv	a0,s2
    80005aa0:	ffffe097          	auipc	ra,0xffffe
    80005aa4:	080080e7          	jalr	128(ra) # 80003b20 <iupdate>
  iunlockput(ip);
    80005aa8:	854a                	mv	a0,s2
    80005aaa:	ffffe097          	auipc	ra,0xffffe
    80005aae:	3a2080e7          	jalr	930(ra) # 80003e4c <iunlockput>
  end_op();
    80005ab2:	fffff097          	auipc	ra,0xfffff
    80005ab6:	b7a080e7          	jalr	-1158(ra) # 8000462c <end_op>
  return 0;
    80005aba:	4501                	li	a0,0
    80005abc:	a84d                	j	80005b6e <sys_unlink+0x1c4>
    end_op();
    80005abe:	fffff097          	auipc	ra,0xfffff
    80005ac2:	b6e080e7          	jalr	-1170(ra) # 8000462c <end_op>
    return -1;
    80005ac6:	557d                	li	a0,-1
    80005ac8:	a05d                	j	80005b6e <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005aca:	00003517          	auipc	a0,0x3
    80005ace:	d7e50513          	addi	a0,a0,-642 # 80008848 <syscalls+0x2d0>
    80005ad2:	ffffb097          	auipc	ra,0xffffb
    80005ad6:	a72080e7          	jalr	-1422(ra) # 80000544 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005ada:	04c92703          	lw	a4,76(s2)
    80005ade:	02000793          	li	a5,32
    80005ae2:	f6e7f9e3          	bgeu	a5,a4,80005a54 <sys_unlink+0xaa>
    80005ae6:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005aea:	4741                	li	a4,16
    80005aec:	86ce                	mv	a3,s3
    80005aee:	f1840613          	addi	a2,s0,-232
    80005af2:	4581                	li	a1,0
    80005af4:	854a                	mv	a0,s2
    80005af6:	ffffe097          	auipc	ra,0xffffe
    80005afa:	3a8080e7          	jalr	936(ra) # 80003e9e <readi>
    80005afe:	47c1                	li	a5,16
    80005b00:	00f51b63          	bne	a0,a5,80005b16 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005b04:	f1845783          	lhu	a5,-232(s0)
    80005b08:	e7a1                	bnez	a5,80005b50 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b0a:	29c1                	addiw	s3,s3,16
    80005b0c:	04c92783          	lw	a5,76(s2)
    80005b10:	fcf9ede3          	bltu	s3,a5,80005aea <sys_unlink+0x140>
    80005b14:	b781                	j	80005a54 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005b16:	00003517          	auipc	a0,0x3
    80005b1a:	d4a50513          	addi	a0,a0,-694 # 80008860 <syscalls+0x2e8>
    80005b1e:	ffffb097          	auipc	ra,0xffffb
    80005b22:	a26080e7          	jalr	-1498(ra) # 80000544 <panic>
    panic("unlink: writei");
    80005b26:	00003517          	auipc	a0,0x3
    80005b2a:	d5250513          	addi	a0,a0,-686 # 80008878 <syscalls+0x300>
    80005b2e:	ffffb097          	auipc	ra,0xffffb
    80005b32:	a16080e7          	jalr	-1514(ra) # 80000544 <panic>
    dp->nlink--;
    80005b36:	04a4d783          	lhu	a5,74(s1)
    80005b3a:	37fd                	addiw	a5,a5,-1
    80005b3c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005b40:	8526                	mv	a0,s1
    80005b42:	ffffe097          	auipc	ra,0xffffe
    80005b46:	fde080e7          	jalr	-34(ra) # 80003b20 <iupdate>
    80005b4a:	b781                	j	80005a8a <sys_unlink+0xe0>
    return -1;
    80005b4c:	557d                	li	a0,-1
    80005b4e:	a005                	j	80005b6e <sys_unlink+0x1c4>
    iunlockput(ip);
    80005b50:	854a                	mv	a0,s2
    80005b52:	ffffe097          	auipc	ra,0xffffe
    80005b56:	2fa080e7          	jalr	762(ra) # 80003e4c <iunlockput>
  iunlockput(dp);
    80005b5a:	8526                	mv	a0,s1
    80005b5c:	ffffe097          	auipc	ra,0xffffe
    80005b60:	2f0080e7          	jalr	752(ra) # 80003e4c <iunlockput>
  end_op();
    80005b64:	fffff097          	auipc	ra,0xfffff
    80005b68:	ac8080e7          	jalr	-1336(ra) # 8000462c <end_op>
  return -1;
    80005b6c:	557d                	li	a0,-1
}
    80005b6e:	70ae                	ld	ra,232(sp)
    80005b70:	740e                	ld	s0,224(sp)
    80005b72:	64ee                	ld	s1,216(sp)
    80005b74:	694e                	ld	s2,208(sp)
    80005b76:	69ae                	ld	s3,200(sp)
    80005b78:	616d                	addi	sp,sp,240
    80005b7a:	8082                	ret

0000000080005b7c <sys_open>:

uint64
sys_open(void)
{
    80005b7c:	7131                	addi	sp,sp,-192
    80005b7e:	fd06                	sd	ra,184(sp)
    80005b80:	f922                	sd	s0,176(sp)
    80005b82:	f526                	sd	s1,168(sp)
    80005b84:	f14a                	sd	s2,160(sp)
    80005b86:	ed4e                	sd	s3,152(sp)
    80005b88:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005b8a:	f4c40593          	addi	a1,s0,-180
    80005b8e:	4505                	li	a0,1
    80005b90:	ffffd097          	auipc	ra,0xffffd
    80005b94:	238080e7          	jalr	568(ra) # 80002dc8 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005b98:	08000613          	li	a2,128
    80005b9c:	f5040593          	addi	a1,s0,-176
    80005ba0:	4501                	li	a0,0
    80005ba2:	ffffd097          	auipc	ra,0xffffd
    80005ba6:	266080e7          	jalr	614(ra) # 80002e08 <argstr>
    80005baa:	87aa                	mv	a5,a0
    return -1;
    80005bac:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005bae:	0a07c963          	bltz	a5,80005c60 <sys_open+0xe4>

  begin_op();
    80005bb2:	fffff097          	auipc	ra,0xfffff
    80005bb6:	9fa080e7          	jalr	-1542(ra) # 800045ac <begin_op>

  if(omode & O_CREATE){
    80005bba:	f4c42783          	lw	a5,-180(s0)
    80005bbe:	2007f793          	andi	a5,a5,512
    80005bc2:	cfc5                	beqz	a5,80005c7a <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005bc4:	4681                	li	a3,0
    80005bc6:	4601                	li	a2,0
    80005bc8:	4589                	li	a1,2
    80005bca:	f5040513          	addi	a0,s0,-176
    80005bce:	00000097          	auipc	ra,0x0
    80005bd2:	974080e7          	jalr	-1676(ra) # 80005542 <create>
    80005bd6:	84aa                	mv	s1,a0
    if(ip == 0){
    80005bd8:	c959                	beqz	a0,80005c6e <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005bda:	04449703          	lh	a4,68(s1)
    80005bde:	478d                	li	a5,3
    80005be0:	00f71763          	bne	a4,a5,80005bee <sys_open+0x72>
    80005be4:	0464d703          	lhu	a4,70(s1)
    80005be8:	47a5                	li	a5,9
    80005bea:	0ce7ed63          	bltu	a5,a4,80005cc4 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005bee:	fffff097          	auipc	ra,0xfffff
    80005bf2:	dce080e7          	jalr	-562(ra) # 800049bc <filealloc>
    80005bf6:	89aa                	mv	s3,a0
    80005bf8:	10050363          	beqz	a0,80005cfe <sys_open+0x182>
    80005bfc:	00000097          	auipc	ra,0x0
    80005c00:	904080e7          	jalr	-1788(ra) # 80005500 <fdalloc>
    80005c04:	892a                	mv	s2,a0
    80005c06:	0e054763          	bltz	a0,80005cf4 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005c0a:	04449703          	lh	a4,68(s1)
    80005c0e:	478d                	li	a5,3
    80005c10:	0cf70563          	beq	a4,a5,80005cda <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005c14:	4789                	li	a5,2
    80005c16:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005c1a:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005c1e:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005c22:	f4c42783          	lw	a5,-180(s0)
    80005c26:	0017c713          	xori	a4,a5,1
    80005c2a:	8b05                	andi	a4,a4,1
    80005c2c:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005c30:	0037f713          	andi	a4,a5,3
    80005c34:	00e03733          	snez	a4,a4
    80005c38:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005c3c:	4007f793          	andi	a5,a5,1024
    80005c40:	c791                	beqz	a5,80005c4c <sys_open+0xd0>
    80005c42:	04449703          	lh	a4,68(s1)
    80005c46:	4789                	li	a5,2
    80005c48:	0af70063          	beq	a4,a5,80005ce8 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005c4c:	8526                	mv	a0,s1
    80005c4e:	ffffe097          	auipc	ra,0xffffe
    80005c52:	05e080e7          	jalr	94(ra) # 80003cac <iunlock>
  end_op();
    80005c56:	fffff097          	auipc	ra,0xfffff
    80005c5a:	9d6080e7          	jalr	-1578(ra) # 8000462c <end_op>

  return fd;
    80005c5e:	854a                	mv	a0,s2
}
    80005c60:	70ea                	ld	ra,184(sp)
    80005c62:	744a                	ld	s0,176(sp)
    80005c64:	74aa                	ld	s1,168(sp)
    80005c66:	790a                	ld	s2,160(sp)
    80005c68:	69ea                	ld	s3,152(sp)
    80005c6a:	6129                	addi	sp,sp,192
    80005c6c:	8082                	ret
      end_op();
    80005c6e:	fffff097          	auipc	ra,0xfffff
    80005c72:	9be080e7          	jalr	-1602(ra) # 8000462c <end_op>
      return -1;
    80005c76:	557d                	li	a0,-1
    80005c78:	b7e5                	j	80005c60 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005c7a:	f5040513          	addi	a0,s0,-176
    80005c7e:	ffffe097          	auipc	ra,0xffffe
    80005c82:	712080e7          	jalr	1810(ra) # 80004390 <namei>
    80005c86:	84aa                	mv	s1,a0
    80005c88:	c905                	beqz	a0,80005cb8 <sys_open+0x13c>
    ilock(ip);
    80005c8a:	ffffe097          	auipc	ra,0xffffe
    80005c8e:	f60080e7          	jalr	-160(ra) # 80003bea <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005c92:	04449703          	lh	a4,68(s1)
    80005c96:	4785                	li	a5,1
    80005c98:	f4f711e3          	bne	a4,a5,80005bda <sys_open+0x5e>
    80005c9c:	f4c42783          	lw	a5,-180(s0)
    80005ca0:	d7b9                	beqz	a5,80005bee <sys_open+0x72>
      iunlockput(ip);
    80005ca2:	8526                	mv	a0,s1
    80005ca4:	ffffe097          	auipc	ra,0xffffe
    80005ca8:	1a8080e7          	jalr	424(ra) # 80003e4c <iunlockput>
      end_op();
    80005cac:	fffff097          	auipc	ra,0xfffff
    80005cb0:	980080e7          	jalr	-1664(ra) # 8000462c <end_op>
      return -1;
    80005cb4:	557d                	li	a0,-1
    80005cb6:	b76d                	j	80005c60 <sys_open+0xe4>
      end_op();
    80005cb8:	fffff097          	auipc	ra,0xfffff
    80005cbc:	974080e7          	jalr	-1676(ra) # 8000462c <end_op>
      return -1;
    80005cc0:	557d                	li	a0,-1
    80005cc2:	bf79                	j	80005c60 <sys_open+0xe4>
    iunlockput(ip);
    80005cc4:	8526                	mv	a0,s1
    80005cc6:	ffffe097          	auipc	ra,0xffffe
    80005cca:	186080e7          	jalr	390(ra) # 80003e4c <iunlockput>
    end_op();
    80005cce:	fffff097          	auipc	ra,0xfffff
    80005cd2:	95e080e7          	jalr	-1698(ra) # 8000462c <end_op>
    return -1;
    80005cd6:	557d                	li	a0,-1
    80005cd8:	b761                	j	80005c60 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005cda:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005cde:	04649783          	lh	a5,70(s1)
    80005ce2:	02f99223          	sh	a5,36(s3)
    80005ce6:	bf25                	j	80005c1e <sys_open+0xa2>
    itrunc(ip);
    80005ce8:	8526                	mv	a0,s1
    80005cea:	ffffe097          	auipc	ra,0xffffe
    80005cee:	00e080e7          	jalr	14(ra) # 80003cf8 <itrunc>
    80005cf2:	bfa9                	j	80005c4c <sys_open+0xd0>
      fileclose(f);
    80005cf4:	854e                	mv	a0,s3
    80005cf6:	fffff097          	auipc	ra,0xfffff
    80005cfa:	d82080e7          	jalr	-638(ra) # 80004a78 <fileclose>
    iunlockput(ip);
    80005cfe:	8526                	mv	a0,s1
    80005d00:	ffffe097          	auipc	ra,0xffffe
    80005d04:	14c080e7          	jalr	332(ra) # 80003e4c <iunlockput>
    end_op();
    80005d08:	fffff097          	auipc	ra,0xfffff
    80005d0c:	924080e7          	jalr	-1756(ra) # 8000462c <end_op>
    return -1;
    80005d10:	557d                	li	a0,-1
    80005d12:	b7b9                	j	80005c60 <sys_open+0xe4>

0000000080005d14 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005d14:	7175                	addi	sp,sp,-144
    80005d16:	e506                	sd	ra,136(sp)
    80005d18:	e122                	sd	s0,128(sp)
    80005d1a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005d1c:	fffff097          	auipc	ra,0xfffff
    80005d20:	890080e7          	jalr	-1904(ra) # 800045ac <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005d24:	08000613          	li	a2,128
    80005d28:	f7040593          	addi	a1,s0,-144
    80005d2c:	4501                	li	a0,0
    80005d2e:	ffffd097          	auipc	ra,0xffffd
    80005d32:	0da080e7          	jalr	218(ra) # 80002e08 <argstr>
    80005d36:	02054963          	bltz	a0,80005d68 <sys_mkdir+0x54>
    80005d3a:	4681                	li	a3,0
    80005d3c:	4601                	li	a2,0
    80005d3e:	4585                	li	a1,1
    80005d40:	f7040513          	addi	a0,s0,-144
    80005d44:	fffff097          	auipc	ra,0xfffff
    80005d48:	7fe080e7          	jalr	2046(ra) # 80005542 <create>
    80005d4c:	cd11                	beqz	a0,80005d68 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d4e:	ffffe097          	auipc	ra,0xffffe
    80005d52:	0fe080e7          	jalr	254(ra) # 80003e4c <iunlockput>
  end_op();
    80005d56:	fffff097          	auipc	ra,0xfffff
    80005d5a:	8d6080e7          	jalr	-1834(ra) # 8000462c <end_op>
  return 0;
    80005d5e:	4501                	li	a0,0
}
    80005d60:	60aa                	ld	ra,136(sp)
    80005d62:	640a                	ld	s0,128(sp)
    80005d64:	6149                	addi	sp,sp,144
    80005d66:	8082                	ret
    end_op();
    80005d68:	fffff097          	auipc	ra,0xfffff
    80005d6c:	8c4080e7          	jalr	-1852(ra) # 8000462c <end_op>
    return -1;
    80005d70:	557d                	li	a0,-1
    80005d72:	b7fd                	j	80005d60 <sys_mkdir+0x4c>

0000000080005d74 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005d74:	7135                	addi	sp,sp,-160
    80005d76:	ed06                	sd	ra,152(sp)
    80005d78:	e922                	sd	s0,144(sp)
    80005d7a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005d7c:	fffff097          	auipc	ra,0xfffff
    80005d80:	830080e7          	jalr	-2000(ra) # 800045ac <begin_op>
  argint(1, &major);
    80005d84:	f6c40593          	addi	a1,s0,-148
    80005d88:	4505                	li	a0,1
    80005d8a:	ffffd097          	auipc	ra,0xffffd
    80005d8e:	03e080e7          	jalr	62(ra) # 80002dc8 <argint>
  argint(2, &minor);
    80005d92:	f6840593          	addi	a1,s0,-152
    80005d96:	4509                	li	a0,2
    80005d98:	ffffd097          	auipc	ra,0xffffd
    80005d9c:	030080e7          	jalr	48(ra) # 80002dc8 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005da0:	08000613          	li	a2,128
    80005da4:	f7040593          	addi	a1,s0,-144
    80005da8:	4501                	li	a0,0
    80005daa:	ffffd097          	auipc	ra,0xffffd
    80005dae:	05e080e7          	jalr	94(ra) # 80002e08 <argstr>
    80005db2:	02054b63          	bltz	a0,80005de8 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005db6:	f6841683          	lh	a3,-152(s0)
    80005dba:	f6c41603          	lh	a2,-148(s0)
    80005dbe:	458d                	li	a1,3
    80005dc0:	f7040513          	addi	a0,s0,-144
    80005dc4:	fffff097          	auipc	ra,0xfffff
    80005dc8:	77e080e7          	jalr	1918(ra) # 80005542 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005dcc:	cd11                	beqz	a0,80005de8 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005dce:	ffffe097          	auipc	ra,0xffffe
    80005dd2:	07e080e7          	jalr	126(ra) # 80003e4c <iunlockput>
  end_op();
    80005dd6:	fffff097          	auipc	ra,0xfffff
    80005dda:	856080e7          	jalr	-1962(ra) # 8000462c <end_op>
  return 0;
    80005dde:	4501                	li	a0,0
}
    80005de0:	60ea                	ld	ra,152(sp)
    80005de2:	644a                	ld	s0,144(sp)
    80005de4:	610d                	addi	sp,sp,160
    80005de6:	8082                	ret
    end_op();
    80005de8:	fffff097          	auipc	ra,0xfffff
    80005dec:	844080e7          	jalr	-1980(ra) # 8000462c <end_op>
    return -1;
    80005df0:	557d                	li	a0,-1
    80005df2:	b7fd                	j	80005de0 <sys_mknod+0x6c>

0000000080005df4 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005df4:	7135                	addi	sp,sp,-160
    80005df6:	ed06                	sd	ra,152(sp)
    80005df8:	e922                	sd	s0,144(sp)
    80005dfa:	e526                	sd	s1,136(sp)
    80005dfc:	e14a                	sd	s2,128(sp)
    80005dfe:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005e00:	ffffc097          	auipc	ra,0xffffc
    80005e04:	cd0080e7          	jalr	-816(ra) # 80001ad0 <myproc>
    80005e08:	892a                	mv	s2,a0
  
  begin_op();
    80005e0a:	ffffe097          	auipc	ra,0xffffe
    80005e0e:	7a2080e7          	jalr	1954(ra) # 800045ac <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005e12:	08000613          	li	a2,128
    80005e16:	f6040593          	addi	a1,s0,-160
    80005e1a:	4501                	li	a0,0
    80005e1c:	ffffd097          	auipc	ra,0xffffd
    80005e20:	fec080e7          	jalr	-20(ra) # 80002e08 <argstr>
    80005e24:	04054b63          	bltz	a0,80005e7a <sys_chdir+0x86>
    80005e28:	f6040513          	addi	a0,s0,-160
    80005e2c:	ffffe097          	auipc	ra,0xffffe
    80005e30:	564080e7          	jalr	1380(ra) # 80004390 <namei>
    80005e34:	84aa                	mv	s1,a0
    80005e36:	c131                	beqz	a0,80005e7a <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005e38:	ffffe097          	auipc	ra,0xffffe
    80005e3c:	db2080e7          	jalr	-590(ra) # 80003bea <ilock>
  if(ip->type != T_DIR){
    80005e40:	04449703          	lh	a4,68(s1)
    80005e44:	4785                	li	a5,1
    80005e46:	04f71063          	bne	a4,a5,80005e86 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005e4a:	8526                	mv	a0,s1
    80005e4c:	ffffe097          	auipc	ra,0xffffe
    80005e50:	e60080e7          	jalr	-416(ra) # 80003cac <iunlock>
  iput(p->cwd);
    80005e54:	15893503          	ld	a0,344(s2)
    80005e58:	ffffe097          	auipc	ra,0xffffe
    80005e5c:	f4c080e7          	jalr	-180(ra) # 80003da4 <iput>
  end_op();
    80005e60:	ffffe097          	auipc	ra,0xffffe
    80005e64:	7cc080e7          	jalr	1996(ra) # 8000462c <end_op>
  p->cwd = ip;
    80005e68:	14993c23          	sd	s1,344(s2)
  return 0;
    80005e6c:	4501                	li	a0,0
}
    80005e6e:	60ea                	ld	ra,152(sp)
    80005e70:	644a                	ld	s0,144(sp)
    80005e72:	64aa                	ld	s1,136(sp)
    80005e74:	690a                	ld	s2,128(sp)
    80005e76:	610d                	addi	sp,sp,160
    80005e78:	8082                	ret
    end_op();
    80005e7a:	ffffe097          	auipc	ra,0xffffe
    80005e7e:	7b2080e7          	jalr	1970(ra) # 8000462c <end_op>
    return -1;
    80005e82:	557d                	li	a0,-1
    80005e84:	b7ed                	j	80005e6e <sys_chdir+0x7a>
    iunlockput(ip);
    80005e86:	8526                	mv	a0,s1
    80005e88:	ffffe097          	auipc	ra,0xffffe
    80005e8c:	fc4080e7          	jalr	-60(ra) # 80003e4c <iunlockput>
    end_op();
    80005e90:	ffffe097          	auipc	ra,0xffffe
    80005e94:	79c080e7          	jalr	1948(ra) # 8000462c <end_op>
    return -1;
    80005e98:	557d                	li	a0,-1
    80005e9a:	bfd1                	j	80005e6e <sys_chdir+0x7a>

0000000080005e9c <sys_exec>:

uint64
sys_exec(void)
{
    80005e9c:	7145                	addi	sp,sp,-464
    80005e9e:	e786                	sd	ra,456(sp)
    80005ea0:	e3a2                	sd	s0,448(sp)
    80005ea2:	ff26                	sd	s1,440(sp)
    80005ea4:	fb4a                	sd	s2,432(sp)
    80005ea6:	f74e                	sd	s3,424(sp)
    80005ea8:	f352                	sd	s4,416(sp)
    80005eaa:	ef56                	sd	s5,408(sp)
    80005eac:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005eae:	e3840593          	addi	a1,s0,-456
    80005eb2:	4505                	li	a0,1
    80005eb4:	ffffd097          	auipc	ra,0xffffd
    80005eb8:	f34080e7          	jalr	-204(ra) # 80002de8 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005ebc:	08000613          	li	a2,128
    80005ec0:	f4040593          	addi	a1,s0,-192
    80005ec4:	4501                	li	a0,0
    80005ec6:	ffffd097          	auipc	ra,0xffffd
    80005eca:	f42080e7          	jalr	-190(ra) # 80002e08 <argstr>
    80005ece:	87aa                	mv	a5,a0
    return -1;
    80005ed0:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005ed2:	0c07c263          	bltz	a5,80005f96 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005ed6:	10000613          	li	a2,256
    80005eda:	4581                	li	a1,0
    80005edc:	e4040513          	addi	a0,s0,-448
    80005ee0:	ffffb097          	auipc	ra,0xffffb
    80005ee4:	e06080e7          	jalr	-506(ra) # 80000ce6 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005ee8:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005eec:	89a6                	mv	s3,s1
    80005eee:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005ef0:	02000a13          	li	s4,32
    80005ef4:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005ef8:	00391513          	slli	a0,s2,0x3
    80005efc:	e3040593          	addi	a1,s0,-464
    80005f00:	e3843783          	ld	a5,-456(s0)
    80005f04:	953e                	add	a0,a0,a5
    80005f06:	ffffd097          	auipc	ra,0xffffd
    80005f0a:	e24080e7          	jalr	-476(ra) # 80002d2a <fetchaddr>
    80005f0e:	02054a63          	bltz	a0,80005f42 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005f12:	e3043783          	ld	a5,-464(s0)
    80005f16:	c3b9                	beqz	a5,80005f5c <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005f18:	ffffb097          	auipc	ra,0xffffb
    80005f1c:	be2080e7          	jalr	-1054(ra) # 80000afa <kalloc>
    80005f20:	85aa                	mv	a1,a0
    80005f22:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005f26:	cd11                	beqz	a0,80005f42 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005f28:	6605                	lui	a2,0x1
    80005f2a:	e3043503          	ld	a0,-464(s0)
    80005f2e:	ffffd097          	auipc	ra,0xffffd
    80005f32:	e4e080e7          	jalr	-434(ra) # 80002d7c <fetchstr>
    80005f36:	00054663          	bltz	a0,80005f42 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005f3a:	0905                	addi	s2,s2,1
    80005f3c:	09a1                	addi	s3,s3,8
    80005f3e:	fb491be3          	bne	s2,s4,80005ef4 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f42:	10048913          	addi	s2,s1,256
    80005f46:	6088                	ld	a0,0(s1)
    80005f48:	c531                	beqz	a0,80005f94 <sys_exec+0xf8>
    kfree(argv[i]);
    80005f4a:	ffffb097          	auipc	ra,0xffffb
    80005f4e:	ab4080e7          	jalr	-1356(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f52:	04a1                	addi	s1,s1,8
    80005f54:	ff2499e3          	bne	s1,s2,80005f46 <sys_exec+0xaa>
  return -1;
    80005f58:	557d                	li	a0,-1
    80005f5a:	a835                	j	80005f96 <sys_exec+0xfa>
      argv[i] = 0;
    80005f5c:	0a8e                	slli	s5,s5,0x3
    80005f5e:	fc040793          	addi	a5,s0,-64
    80005f62:	9abe                	add	s5,s5,a5
    80005f64:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005f68:	e4040593          	addi	a1,s0,-448
    80005f6c:	f4040513          	addi	a0,s0,-192
    80005f70:	fffff097          	auipc	ra,0xfffff
    80005f74:	190080e7          	jalr	400(ra) # 80005100 <exec>
    80005f78:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f7a:	10048993          	addi	s3,s1,256
    80005f7e:	6088                	ld	a0,0(s1)
    80005f80:	c901                	beqz	a0,80005f90 <sys_exec+0xf4>
    kfree(argv[i]);
    80005f82:	ffffb097          	auipc	ra,0xffffb
    80005f86:	a7c080e7          	jalr	-1412(ra) # 800009fe <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f8a:	04a1                	addi	s1,s1,8
    80005f8c:	ff3499e3          	bne	s1,s3,80005f7e <sys_exec+0xe2>
  return ret;
    80005f90:	854a                	mv	a0,s2
    80005f92:	a011                	j	80005f96 <sys_exec+0xfa>
  return -1;
    80005f94:	557d                	li	a0,-1
}
    80005f96:	60be                	ld	ra,456(sp)
    80005f98:	641e                	ld	s0,448(sp)
    80005f9a:	74fa                	ld	s1,440(sp)
    80005f9c:	795a                	ld	s2,432(sp)
    80005f9e:	79ba                	ld	s3,424(sp)
    80005fa0:	7a1a                	ld	s4,416(sp)
    80005fa2:	6afa                	ld	s5,408(sp)
    80005fa4:	6179                	addi	sp,sp,464
    80005fa6:	8082                	ret

0000000080005fa8 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005fa8:	7139                	addi	sp,sp,-64
    80005faa:	fc06                	sd	ra,56(sp)
    80005fac:	f822                	sd	s0,48(sp)
    80005fae:	f426                	sd	s1,40(sp)
    80005fb0:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005fb2:	ffffc097          	auipc	ra,0xffffc
    80005fb6:	b1e080e7          	jalr	-1250(ra) # 80001ad0 <myproc>
    80005fba:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005fbc:	fd840593          	addi	a1,s0,-40
    80005fc0:	4501                	li	a0,0
    80005fc2:	ffffd097          	auipc	ra,0xffffd
    80005fc6:	e26080e7          	jalr	-474(ra) # 80002de8 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005fca:	fc840593          	addi	a1,s0,-56
    80005fce:	fd040513          	addi	a0,s0,-48
    80005fd2:	fffff097          	auipc	ra,0xfffff
    80005fd6:	dd6080e7          	jalr	-554(ra) # 80004da8 <pipealloc>
    return -1;
    80005fda:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005fdc:	0c054463          	bltz	a0,800060a4 <sys_pipe+0xfc>
  fd0 = -1;
    80005fe0:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005fe4:	fd043503          	ld	a0,-48(s0)
    80005fe8:	fffff097          	auipc	ra,0xfffff
    80005fec:	518080e7          	jalr	1304(ra) # 80005500 <fdalloc>
    80005ff0:	fca42223          	sw	a0,-60(s0)
    80005ff4:	08054b63          	bltz	a0,8000608a <sys_pipe+0xe2>
    80005ff8:	fc843503          	ld	a0,-56(s0)
    80005ffc:	fffff097          	auipc	ra,0xfffff
    80006000:	504080e7          	jalr	1284(ra) # 80005500 <fdalloc>
    80006004:	fca42023          	sw	a0,-64(s0)
    80006008:	06054863          	bltz	a0,80006078 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000600c:	4691                	li	a3,4
    8000600e:	fc440613          	addi	a2,s0,-60
    80006012:	fd843583          	ld	a1,-40(s0)
    80006016:	6ca8                	ld	a0,88(s1)
    80006018:	ffffb097          	auipc	ra,0xffffb
    8000601c:	66c080e7          	jalr	1644(ra) # 80001684 <copyout>
    80006020:	02054063          	bltz	a0,80006040 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006024:	4691                	li	a3,4
    80006026:	fc040613          	addi	a2,s0,-64
    8000602a:	fd843583          	ld	a1,-40(s0)
    8000602e:	0591                	addi	a1,a1,4
    80006030:	6ca8                	ld	a0,88(s1)
    80006032:	ffffb097          	auipc	ra,0xffffb
    80006036:	652080e7          	jalr	1618(ra) # 80001684 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000603a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000603c:	06055463          	bgez	a0,800060a4 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80006040:	fc442783          	lw	a5,-60(s0)
    80006044:	07e9                	addi	a5,a5,26
    80006046:	078e                	slli	a5,a5,0x3
    80006048:	97a6                	add	a5,a5,s1
    8000604a:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    8000604e:	fc042503          	lw	a0,-64(s0)
    80006052:	0569                	addi	a0,a0,26
    80006054:	050e                	slli	a0,a0,0x3
    80006056:	94aa                	add	s1,s1,a0
    80006058:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    8000605c:	fd043503          	ld	a0,-48(s0)
    80006060:	fffff097          	auipc	ra,0xfffff
    80006064:	a18080e7          	jalr	-1512(ra) # 80004a78 <fileclose>
    fileclose(wf);
    80006068:	fc843503          	ld	a0,-56(s0)
    8000606c:	fffff097          	auipc	ra,0xfffff
    80006070:	a0c080e7          	jalr	-1524(ra) # 80004a78 <fileclose>
    return -1;
    80006074:	57fd                	li	a5,-1
    80006076:	a03d                	j	800060a4 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80006078:	fc442783          	lw	a5,-60(s0)
    8000607c:	0007c763          	bltz	a5,8000608a <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80006080:	07e9                	addi	a5,a5,26
    80006082:	078e                	slli	a5,a5,0x3
    80006084:	94be                	add	s1,s1,a5
    80006086:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    8000608a:	fd043503          	ld	a0,-48(s0)
    8000608e:	fffff097          	auipc	ra,0xfffff
    80006092:	9ea080e7          	jalr	-1558(ra) # 80004a78 <fileclose>
    fileclose(wf);
    80006096:	fc843503          	ld	a0,-56(s0)
    8000609a:	fffff097          	auipc	ra,0xfffff
    8000609e:	9de080e7          	jalr	-1570(ra) # 80004a78 <fileclose>
    return -1;
    800060a2:	57fd                	li	a5,-1
}
    800060a4:	853e                	mv	a0,a5
    800060a6:	70e2                	ld	ra,56(sp)
    800060a8:	7442                	ld	s0,48(sp)
    800060aa:	74a2                	ld	s1,40(sp)
    800060ac:	6121                	addi	sp,sp,64
    800060ae:	8082                	ret

00000000800060b0 <kernelvec>:
    800060b0:	7111                	addi	sp,sp,-256
    800060b2:	e006                	sd	ra,0(sp)
    800060b4:	e40a                	sd	sp,8(sp)
    800060b6:	e80e                	sd	gp,16(sp)
    800060b8:	ec12                	sd	tp,24(sp)
    800060ba:	f016                	sd	t0,32(sp)
    800060bc:	f41a                	sd	t1,40(sp)
    800060be:	f81e                	sd	t2,48(sp)
    800060c0:	fc22                	sd	s0,56(sp)
    800060c2:	e0a6                	sd	s1,64(sp)
    800060c4:	e4aa                	sd	a0,72(sp)
    800060c6:	e8ae                	sd	a1,80(sp)
    800060c8:	ecb2                	sd	a2,88(sp)
    800060ca:	f0b6                	sd	a3,96(sp)
    800060cc:	f4ba                	sd	a4,104(sp)
    800060ce:	f8be                	sd	a5,112(sp)
    800060d0:	fcc2                	sd	a6,120(sp)
    800060d2:	e146                	sd	a7,128(sp)
    800060d4:	e54a                	sd	s2,136(sp)
    800060d6:	e94e                	sd	s3,144(sp)
    800060d8:	ed52                	sd	s4,152(sp)
    800060da:	f156                	sd	s5,160(sp)
    800060dc:	f55a                	sd	s6,168(sp)
    800060de:	f95e                	sd	s7,176(sp)
    800060e0:	fd62                	sd	s8,184(sp)
    800060e2:	e1e6                	sd	s9,192(sp)
    800060e4:	e5ea                	sd	s10,200(sp)
    800060e6:	e9ee                	sd	s11,208(sp)
    800060e8:	edf2                	sd	t3,216(sp)
    800060ea:	f1f6                	sd	t4,224(sp)
    800060ec:	f5fa                	sd	t5,232(sp)
    800060ee:	f9fe                	sd	t6,240(sp)
    800060f0:	b07fc0ef          	jal	ra,80002bf6 <kerneltrap>
    800060f4:	6082                	ld	ra,0(sp)
    800060f6:	6122                	ld	sp,8(sp)
    800060f8:	61c2                	ld	gp,16(sp)
    800060fa:	7282                	ld	t0,32(sp)
    800060fc:	7322                	ld	t1,40(sp)
    800060fe:	73c2                	ld	t2,48(sp)
    80006100:	7462                	ld	s0,56(sp)
    80006102:	6486                	ld	s1,64(sp)
    80006104:	6526                	ld	a0,72(sp)
    80006106:	65c6                	ld	a1,80(sp)
    80006108:	6666                	ld	a2,88(sp)
    8000610a:	7686                	ld	a3,96(sp)
    8000610c:	7726                	ld	a4,104(sp)
    8000610e:	77c6                	ld	a5,112(sp)
    80006110:	7866                	ld	a6,120(sp)
    80006112:	688a                	ld	a7,128(sp)
    80006114:	692a                	ld	s2,136(sp)
    80006116:	69ca                	ld	s3,144(sp)
    80006118:	6a6a                	ld	s4,152(sp)
    8000611a:	7a8a                	ld	s5,160(sp)
    8000611c:	7b2a                	ld	s6,168(sp)
    8000611e:	7bca                	ld	s7,176(sp)
    80006120:	7c6a                	ld	s8,184(sp)
    80006122:	6c8e                	ld	s9,192(sp)
    80006124:	6d2e                	ld	s10,200(sp)
    80006126:	6dce                	ld	s11,208(sp)
    80006128:	6e6e                	ld	t3,216(sp)
    8000612a:	7e8e                	ld	t4,224(sp)
    8000612c:	7f2e                	ld	t5,232(sp)
    8000612e:	7fce                	ld	t6,240(sp)
    80006130:	6111                	addi	sp,sp,256
    80006132:	10200073          	sret
    80006136:	00000013          	nop
    8000613a:	00000013          	nop
    8000613e:	0001                	nop

0000000080006140 <timervec>:
    80006140:	34051573          	csrrw	a0,mscratch,a0
    80006144:	e10c                	sd	a1,0(a0)
    80006146:	e510                	sd	a2,8(a0)
    80006148:	e914                	sd	a3,16(a0)
    8000614a:	6d0c                	ld	a1,24(a0)
    8000614c:	7110                	ld	a2,32(a0)
    8000614e:	6194                	ld	a3,0(a1)
    80006150:	96b2                	add	a3,a3,a2
    80006152:	e194                	sd	a3,0(a1)
    80006154:	4589                	li	a1,2
    80006156:	14459073          	csrw	sip,a1
    8000615a:	6914                	ld	a3,16(a0)
    8000615c:	6510                	ld	a2,8(a0)
    8000615e:	610c                	ld	a1,0(a0)
    80006160:	34051573          	csrrw	a0,mscratch,a0
    80006164:	30200073          	mret
	...

000000008000616a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000616a:	1141                	addi	sp,sp,-16
    8000616c:	e422                	sd	s0,8(sp)
    8000616e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006170:	0c0007b7          	lui	a5,0xc000
    80006174:	4705                	li	a4,1
    80006176:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006178:	c3d8                	sw	a4,4(a5)
}
    8000617a:	6422                	ld	s0,8(sp)
    8000617c:	0141                	addi	sp,sp,16
    8000617e:	8082                	ret

0000000080006180 <plicinithart>:

void
plicinithart(void)
{
    80006180:	1141                	addi	sp,sp,-16
    80006182:	e406                	sd	ra,8(sp)
    80006184:	e022                	sd	s0,0(sp)
    80006186:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006188:	ffffc097          	auipc	ra,0xffffc
    8000618c:	91c080e7          	jalr	-1764(ra) # 80001aa4 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006190:	0085171b          	slliw	a4,a0,0x8
    80006194:	0c0027b7          	lui	a5,0xc002
    80006198:	97ba                	add	a5,a5,a4
    8000619a:	40200713          	li	a4,1026
    8000619e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800061a2:	00d5151b          	slliw	a0,a0,0xd
    800061a6:	0c2017b7          	lui	a5,0xc201
    800061aa:	953e                	add	a0,a0,a5
    800061ac:	00052023          	sw	zero,0(a0)
}
    800061b0:	60a2                	ld	ra,8(sp)
    800061b2:	6402                	ld	s0,0(sp)
    800061b4:	0141                	addi	sp,sp,16
    800061b6:	8082                	ret

00000000800061b8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800061b8:	1141                	addi	sp,sp,-16
    800061ba:	e406                	sd	ra,8(sp)
    800061bc:	e022                	sd	s0,0(sp)
    800061be:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800061c0:	ffffc097          	auipc	ra,0xffffc
    800061c4:	8e4080e7          	jalr	-1820(ra) # 80001aa4 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800061c8:	00d5179b          	slliw	a5,a0,0xd
    800061cc:	0c201537          	lui	a0,0xc201
    800061d0:	953e                	add	a0,a0,a5
  return irq;
}
    800061d2:	4148                	lw	a0,4(a0)
    800061d4:	60a2                	ld	ra,8(sp)
    800061d6:	6402                	ld	s0,0(sp)
    800061d8:	0141                	addi	sp,sp,16
    800061da:	8082                	ret

00000000800061dc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800061dc:	1101                	addi	sp,sp,-32
    800061de:	ec06                	sd	ra,24(sp)
    800061e0:	e822                	sd	s0,16(sp)
    800061e2:	e426                	sd	s1,8(sp)
    800061e4:	1000                	addi	s0,sp,32
    800061e6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800061e8:	ffffc097          	auipc	ra,0xffffc
    800061ec:	8bc080e7          	jalr	-1860(ra) # 80001aa4 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800061f0:	00d5151b          	slliw	a0,a0,0xd
    800061f4:	0c2017b7          	lui	a5,0xc201
    800061f8:	97aa                	add	a5,a5,a0
    800061fa:	c3c4                	sw	s1,4(a5)
}
    800061fc:	60e2                	ld	ra,24(sp)
    800061fe:	6442                	ld	s0,16(sp)
    80006200:	64a2                	ld	s1,8(sp)
    80006202:	6105                	addi	sp,sp,32
    80006204:	8082                	ret

0000000080006206 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006206:	1141                	addi	sp,sp,-16
    80006208:	e406                	sd	ra,8(sp)
    8000620a:	e022                	sd	s0,0(sp)
    8000620c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000620e:	479d                	li	a5,7
    80006210:	04a7cc63          	blt	a5,a0,80006268 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006214:	0001d797          	auipc	a5,0x1d
    80006218:	6fc78793          	addi	a5,a5,1788 # 80023910 <disk>
    8000621c:	97aa                	add	a5,a5,a0
    8000621e:	0187c783          	lbu	a5,24(a5)
    80006222:	ebb9                	bnez	a5,80006278 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006224:	00451613          	slli	a2,a0,0x4
    80006228:	0001d797          	auipc	a5,0x1d
    8000622c:	6e878793          	addi	a5,a5,1768 # 80023910 <disk>
    80006230:	6394                	ld	a3,0(a5)
    80006232:	96b2                	add	a3,a3,a2
    80006234:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006238:	6398                	ld	a4,0(a5)
    8000623a:	9732                	add	a4,a4,a2
    8000623c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006240:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006244:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006248:	953e                	add	a0,a0,a5
    8000624a:	4785                	li	a5,1
    8000624c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80006250:	0001d517          	auipc	a0,0x1d
    80006254:	6d850513          	addi	a0,a0,1752 # 80023928 <disk+0x18>
    80006258:	ffffc097          	auipc	ra,0xffffc
    8000625c:	12e080e7          	jalr	302(ra) # 80002386 <wakeup>
}
    80006260:	60a2                	ld	ra,8(sp)
    80006262:	6402                	ld	s0,0(sp)
    80006264:	0141                	addi	sp,sp,16
    80006266:	8082                	ret
    panic("free_desc 1");
    80006268:	00002517          	auipc	a0,0x2
    8000626c:	62050513          	addi	a0,a0,1568 # 80008888 <syscalls+0x310>
    80006270:	ffffa097          	auipc	ra,0xffffa
    80006274:	2d4080e7          	jalr	724(ra) # 80000544 <panic>
    panic("free_desc 2");
    80006278:	00002517          	auipc	a0,0x2
    8000627c:	62050513          	addi	a0,a0,1568 # 80008898 <syscalls+0x320>
    80006280:	ffffa097          	auipc	ra,0xffffa
    80006284:	2c4080e7          	jalr	708(ra) # 80000544 <panic>

0000000080006288 <virtio_disk_init>:
{
    80006288:	1101                	addi	sp,sp,-32
    8000628a:	ec06                	sd	ra,24(sp)
    8000628c:	e822                	sd	s0,16(sp)
    8000628e:	e426                	sd	s1,8(sp)
    80006290:	e04a                	sd	s2,0(sp)
    80006292:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006294:	00002597          	auipc	a1,0x2
    80006298:	61458593          	addi	a1,a1,1556 # 800088a8 <syscalls+0x330>
    8000629c:	0001d517          	auipc	a0,0x1d
    800062a0:	79c50513          	addi	a0,a0,1948 # 80023a38 <disk+0x128>
    800062a4:	ffffb097          	auipc	ra,0xffffb
    800062a8:	8b6080e7          	jalr	-1866(ra) # 80000b5a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800062ac:	100017b7          	lui	a5,0x10001
    800062b0:	4398                	lw	a4,0(a5)
    800062b2:	2701                	sext.w	a4,a4
    800062b4:	747277b7          	lui	a5,0x74727
    800062b8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800062bc:	14f71e63          	bne	a4,a5,80006418 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800062c0:	100017b7          	lui	a5,0x10001
    800062c4:	43dc                	lw	a5,4(a5)
    800062c6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800062c8:	4709                	li	a4,2
    800062ca:	14e79763          	bne	a5,a4,80006418 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800062ce:	100017b7          	lui	a5,0x10001
    800062d2:	479c                	lw	a5,8(a5)
    800062d4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800062d6:	14e79163          	bne	a5,a4,80006418 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800062da:	100017b7          	lui	a5,0x10001
    800062de:	47d8                	lw	a4,12(a5)
    800062e0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800062e2:	554d47b7          	lui	a5,0x554d4
    800062e6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800062ea:	12f71763          	bne	a4,a5,80006418 <virtio_disk_init+0x190>
  *R(VIRTIO_MMIO_STATUS) = status;
    800062ee:	100017b7          	lui	a5,0x10001
    800062f2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800062f6:	4705                	li	a4,1
    800062f8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800062fa:	470d                	li	a4,3
    800062fc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800062fe:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006300:	c7ffe737          	lui	a4,0xc7ffe
    80006304:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdad0f>
    80006308:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000630a:	2701                	sext.w	a4,a4
    8000630c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000630e:	472d                	li	a4,11
    80006310:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006312:	0707a903          	lw	s2,112(a5)
    80006316:	2901                	sext.w	s2,s2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006318:	00897793          	andi	a5,s2,8
    8000631c:	10078663          	beqz	a5,80006428 <virtio_disk_init+0x1a0>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006320:	100017b7          	lui	a5,0x10001
    80006324:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006328:	43fc                	lw	a5,68(a5)
    8000632a:	2781                	sext.w	a5,a5
    8000632c:	10079663          	bnez	a5,80006438 <virtio_disk_init+0x1b0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006330:	100017b7          	lui	a5,0x10001
    80006334:	5bdc                	lw	a5,52(a5)
    80006336:	2781                	sext.w	a5,a5
  if(max == 0)
    80006338:	10078863          	beqz	a5,80006448 <virtio_disk_init+0x1c0>
  if(max < NUM)
    8000633c:	471d                	li	a4,7
    8000633e:	10f77d63          	bgeu	a4,a5,80006458 <virtio_disk_init+0x1d0>
  disk.desc = kalloc();
    80006342:	ffffa097          	auipc	ra,0xffffa
    80006346:	7b8080e7          	jalr	1976(ra) # 80000afa <kalloc>
    8000634a:	0001d497          	auipc	s1,0x1d
    8000634e:	5c648493          	addi	s1,s1,1478 # 80023910 <disk>
    80006352:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006354:	ffffa097          	auipc	ra,0xffffa
    80006358:	7a6080e7          	jalr	1958(ra) # 80000afa <kalloc>
    8000635c:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000635e:	ffffa097          	auipc	ra,0xffffa
    80006362:	79c080e7          	jalr	1948(ra) # 80000afa <kalloc>
    80006366:	87aa                	mv	a5,a0
    80006368:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    8000636a:	6088                	ld	a0,0(s1)
    8000636c:	cd75                	beqz	a0,80006468 <virtio_disk_init+0x1e0>
    8000636e:	0001d717          	auipc	a4,0x1d
    80006372:	5aa73703          	ld	a4,1450(a4) # 80023918 <disk+0x8>
    80006376:	cb6d                	beqz	a4,80006468 <virtio_disk_init+0x1e0>
    80006378:	cbe5                	beqz	a5,80006468 <virtio_disk_init+0x1e0>
  memset(disk.desc, 0, PGSIZE);
    8000637a:	6605                	lui	a2,0x1
    8000637c:	4581                	li	a1,0
    8000637e:	ffffb097          	auipc	ra,0xffffb
    80006382:	968080e7          	jalr	-1688(ra) # 80000ce6 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006386:	0001d497          	auipc	s1,0x1d
    8000638a:	58a48493          	addi	s1,s1,1418 # 80023910 <disk>
    8000638e:	6605                	lui	a2,0x1
    80006390:	4581                	li	a1,0
    80006392:	6488                	ld	a0,8(s1)
    80006394:	ffffb097          	auipc	ra,0xffffb
    80006398:	952080e7          	jalr	-1710(ra) # 80000ce6 <memset>
  memset(disk.used, 0, PGSIZE);
    8000639c:	6605                	lui	a2,0x1
    8000639e:	4581                	li	a1,0
    800063a0:	6888                	ld	a0,16(s1)
    800063a2:	ffffb097          	auipc	ra,0xffffb
    800063a6:	944080e7          	jalr	-1724(ra) # 80000ce6 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800063aa:	100017b7          	lui	a5,0x10001
    800063ae:	4721                	li	a4,8
    800063b0:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800063b2:	4098                	lw	a4,0(s1)
    800063b4:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800063b8:	40d8                	lw	a4,4(s1)
    800063ba:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800063be:	6498                	ld	a4,8(s1)
    800063c0:	0007069b          	sext.w	a3,a4
    800063c4:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800063c8:	9701                	srai	a4,a4,0x20
    800063ca:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800063ce:	6898                	ld	a4,16(s1)
    800063d0:	0007069b          	sext.w	a3,a4
    800063d4:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800063d8:	9701                	srai	a4,a4,0x20
    800063da:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800063de:	4685                	li	a3,1
    800063e0:	c3f4                	sw	a3,68(a5)
    disk.free[i] = 1;
    800063e2:	4705                	li	a4,1
    800063e4:	00d48c23          	sb	a3,24(s1)
    800063e8:	00e48ca3          	sb	a4,25(s1)
    800063ec:	00e48d23          	sb	a4,26(s1)
    800063f0:	00e48da3          	sb	a4,27(s1)
    800063f4:	00e48e23          	sb	a4,28(s1)
    800063f8:	00e48ea3          	sb	a4,29(s1)
    800063fc:	00e48f23          	sb	a4,30(s1)
    80006400:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006404:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006408:	0727a823          	sw	s2,112(a5)
}
    8000640c:	60e2                	ld	ra,24(sp)
    8000640e:	6442                	ld	s0,16(sp)
    80006410:	64a2                	ld	s1,8(sp)
    80006412:	6902                	ld	s2,0(sp)
    80006414:	6105                	addi	sp,sp,32
    80006416:	8082                	ret
    panic("could not find virtio disk");
    80006418:	00002517          	auipc	a0,0x2
    8000641c:	4a050513          	addi	a0,a0,1184 # 800088b8 <syscalls+0x340>
    80006420:	ffffa097          	auipc	ra,0xffffa
    80006424:	124080e7          	jalr	292(ra) # 80000544 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006428:	00002517          	auipc	a0,0x2
    8000642c:	4b050513          	addi	a0,a0,1200 # 800088d8 <syscalls+0x360>
    80006430:	ffffa097          	auipc	ra,0xffffa
    80006434:	114080e7          	jalr	276(ra) # 80000544 <panic>
    panic("virtio disk should not be ready");
    80006438:	00002517          	auipc	a0,0x2
    8000643c:	4c050513          	addi	a0,a0,1216 # 800088f8 <syscalls+0x380>
    80006440:	ffffa097          	auipc	ra,0xffffa
    80006444:	104080e7          	jalr	260(ra) # 80000544 <panic>
    panic("virtio disk has no queue 0");
    80006448:	00002517          	auipc	a0,0x2
    8000644c:	4d050513          	addi	a0,a0,1232 # 80008918 <syscalls+0x3a0>
    80006450:	ffffa097          	auipc	ra,0xffffa
    80006454:	0f4080e7          	jalr	244(ra) # 80000544 <panic>
    panic("virtio disk max queue too short");
    80006458:	00002517          	auipc	a0,0x2
    8000645c:	4e050513          	addi	a0,a0,1248 # 80008938 <syscalls+0x3c0>
    80006460:	ffffa097          	auipc	ra,0xffffa
    80006464:	0e4080e7          	jalr	228(ra) # 80000544 <panic>
    panic("virtio disk kalloc");
    80006468:	00002517          	auipc	a0,0x2
    8000646c:	4f050513          	addi	a0,a0,1264 # 80008958 <syscalls+0x3e0>
    80006470:	ffffa097          	auipc	ra,0xffffa
    80006474:	0d4080e7          	jalr	212(ra) # 80000544 <panic>

0000000080006478 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006478:	7159                	addi	sp,sp,-112
    8000647a:	f486                	sd	ra,104(sp)
    8000647c:	f0a2                	sd	s0,96(sp)
    8000647e:	eca6                	sd	s1,88(sp)
    80006480:	e8ca                	sd	s2,80(sp)
    80006482:	e4ce                	sd	s3,72(sp)
    80006484:	e0d2                	sd	s4,64(sp)
    80006486:	fc56                	sd	s5,56(sp)
    80006488:	f85a                	sd	s6,48(sp)
    8000648a:	f45e                	sd	s7,40(sp)
    8000648c:	f062                	sd	s8,32(sp)
    8000648e:	ec66                	sd	s9,24(sp)
    80006490:	e86a                	sd	s10,16(sp)
    80006492:	1880                	addi	s0,sp,112
    80006494:	892a                	mv	s2,a0
    80006496:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006498:	00c52c83          	lw	s9,12(a0)
    8000649c:	001c9c9b          	slliw	s9,s9,0x1
    800064a0:	1c82                	slli	s9,s9,0x20
    800064a2:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800064a6:	0001d517          	auipc	a0,0x1d
    800064aa:	59250513          	addi	a0,a0,1426 # 80023a38 <disk+0x128>
    800064ae:	ffffa097          	auipc	ra,0xffffa
    800064b2:	73c080e7          	jalr	1852(ra) # 80000bea <acquire>
  for(int i = 0; i < 3; i++){
    800064b6:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800064b8:	4ba1                	li	s7,8
      disk.free[i] = 0;
    800064ba:	0001db17          	auipc	s6,0x1d
    800064be:	456b0b13          	addi	s6,s6,1110 # 80023910 <disk>
  for(int i = 0; i < 3; i++){
    800064c2:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    800064c4:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800064c6:	0001dc17          	auipc	s8,0x1d
    800064ca:	572c0c13          	addi	s8,s8,1394 # 80023a38 <disk+0x128>
    800064ce:	a8b5                	j	8000654a <virtio_disk_rw+0xd2>
      disk.free[i] = 0;
    800064d0:	00fb06b3          	add	a3,s6,a5
    800064d4:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    800064d8:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    800064da:	0207c563          	bltz	a5,80006504 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800064de:	2485                	addiw	s1,s1,1
    800064e0:	0711                	addi	a4,a4,4
    800064e2:	1f548a63          	beq	s1,s5,800066d6 <virtio_disk_rw+0x25e>
    idx[i] = alloc_desc();
    800064e6:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    800064e8:	0001d697          	auipc	a3,0x1d
    800064ec:	42868693          	addi	a3,a3,1064 # 80023910 <disk>
    800064f0:	87d2                	mv	a5,s4
    if(disk.free[i]){
    800064f2:	0186c583          	lbu	a1,24(a3)
    800064f6:	fde9                	bnez	a1,800064d0 <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800064f8:	2785                	addiw	a5,a5,1
    800064fa:	0685                	addi	a3,a3,1
    800064fc:	ff779be3          	bne	a5,s7,800064f2 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    80006500:	57fd                	li	a5,-1
    80006502:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80006504:	02905a63          	blez	s1,80006538 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    80006508:	f9042503          	lw	a0,-112(s0)
    8000650c:	00000097          	auipc	ra,0x0
    80006510:	cfa080e7          	jalr	-774(ra) # 80006206 <free_desc>
      for(int j = 0; j < i; j++)
    80006514:	4785                	li	a5,1
    80006516:	0297d163          	bge	a5,s1,80006538 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000651a:	f9442503          	lw	a0,-108(s0)
    8000651e:	00000097          	auipc	ra,0x0
    80006522:	ce8080e7          	jalr	-792(ra) # 80006206 <free_desc>
      for(int j = 0; j < i; j++)
    80006526:	4789                	li	a5,2
    80006528:	0097d863          	bge	a5,s1,80006538 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000652c:	f9842503          	lw	a0,-104(s0)
    80006530:	00000097          	auipc	ra,0x0
    80006534:	cd6080e7          	jalr	-810(ra) # 80006206 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006538:	85e2                	mv	a1,s8
    8000653a:	0001d517          	auipc	a0,0x1d
    8000653e:	3ee50513          	addi	a0,a0,1006 # 80023928 <disk+0x18>
    80006542:	ffffc097          	auipc	ra,0xffffc
    80006546:	ca6080e7          	jalr	-858(ra) # 800021e8 <sleep>
  for(int i = 0; i < 3; i++){
    8000654a:	f9040713          	addi	a4,s0,-112
    8000654e:	84ce                	mv	s1,s3
    80006550:	bf59                	j	800064e6 <virtio_disk_rw+0x6e>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80006552:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    80006556:	00479693          	slli	a3,a5,0x4
    8000655a:	0001d797          	auipc	a5,0x1d
    8000655e:	3b678793          	addi	a5,a5,950 # 80023910 <disk>
    80006562:	97b6                	add	a5,a5,a3
    80006564:	4685                	li	a3,1
    80006566:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006568:	0001d597          	auipc	a1,0x1d
    8000656c:	3a858593          	addi	a1,a1,936 # 80023910 <disk>
    80006570:	00a60793          	addi	a5,a2,10
    80006574:	0792                	slli	a5,a5,0x4
    80006576:	97ae                	add	a5,a5,a1
    80006578:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    8000657c:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006580:	f6070693          	addi	a3,a4,-160
    80006584:	619c                	ld	a5,0(a1)
    80006586:	97b6                	add	a5,a5,a3
    80006588:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000658a:	6188                	ld	a0,0(a1)
    8000658c:	96aa                	add	a3,a3,a0
    8000658e:	47c1                	li	a5,16
    80006590:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006592:	4785                	li	a5,1
    80006594:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006598:	f9442783          	lw	a5,-108(s0)
    8000659c:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800065a0:	0792                	slli	a5,a5,0x4
    800065a2:	953e                	add	a0,a0,a5
    800065a4:	05890693          	addi	a3,s2,88
    800065a8:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    800065aa:	6188                	ld	a0,0(a1)
    800065ac:	97aa                	add	a5,a5,a0
    800065ae:	40000693          	li	a3,1024
    800065b2:	c794                	sw	a3,8(a5)
  if(write)
    800065b4:	100d0d63          	beqz	s10,800066ce <virtio_disk_rw+0x256>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800065b8:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800065bc:	00c7d683          	lhu	a3,12(a5)
    800065c0:	0016e693          	ori	a3,a3,1
    800065c4:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    800065c8:	f9842583          	lw	a1,-104(s0)
    800065cc:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800065d0:	0001d697          	auipc	a3,0x1d
    800065d4:	34068693          	addi	a3,a3,832 # 80023910 <disk>
    800065d8:	00260793          	addi	a5,a2,2
    800065dc:	0792                	slli	a5,a5,0x4
    800065de:	97b6                	add	a5,a5,a3
    800065e0:	587d                	li	a6,-1
    800065e2:	01078823          	sb	a6,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800065e6:	0592                	slli	a1,a1,0x4
    800065e8:	952e                	add	a0,a0,a1
    800065ea:	f9070713          	addi	a4,a4,-112
    800065ee:	9736                	add	a4,a4,a3
    800065f0:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    800065f2:	6298                	ld	a4,0(a3)
    800065f4:	972e                	add	a4,a4,a1
    800065f6:	4585                	li	a1,1
    800065f8:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800065fa:	4509                	li	a0,2
    800065fc:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    80006600:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006604:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    80006608:	0127b423          	sd	s2,8(a5)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000660c:	6698                	ld	a4,8(a3)
    8000660e:	00275783          	lhu	a5,2(a4)
    80006612:	8b9d                	andi	a5,a5,7
    80006614:	0786                	slli	a5,a5,0x1
    80006616:	97ba                	add	a5,a5,a4
    80006618:	00c79223          	sh	a2,4(a5)

  __sync_synchronize();
    8000661c:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006620:	6698                	ld	a4,8(a3)
    80006622:	00275783          	lhu	a5,2(a4)
    80006626:	2785                	addiw	a5,a5,1
    80006628:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000662c:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006630:	100017b7          	lui	a5,0x10001
    80006634:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006638:	00492703          	lw	a4,4(s2)
    8000663c:	4785                	li	a5,1
    8000663e:	02f71163          	bne	a4,a5,80006660 <virtio_disk_rw+0x1e8>
    sleep(b, &disk.vdisk_lock);
    80006642:	0001d997          	auipc	s3,0x1d
    80006646:	3f698993          	addi	s3,s3,1014 # 80023a38 <disk+0x128>
  while(b->disk == 1) {
    8000664a:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000664c:	85ce                	mv	a1,s3
    8000664e:	854a                	mv	a0,s2
    80006650:	ffffc097          	auipc	ra,0xffffc
    80006654:	b98080e7          	jalr	-1128(ra) # 800021e8 <sleep>
  while(b->disk == 1) {
    80006658:	00492783          	lw	a5,4(s2)
    8000665c:	fe9788e3          	beq	a5,s1,8000664c <virtio_disk_rw+0x1d4>
  }

  disk.info[idx[0]].b = 0;
    80006660:	f9042903          	lw	s2,-112(s0)
    80006664:	00290793          	addi	a5,s2,2
    80006668:	00479713          	slli	a4,a5,0x4
    8000666c:	0001d797          	auipc	a5,0x1d
    80006670:	2a478793          	addi	a5,a5,676 # 80023910 <disk>
    80006674:	97ba                	add	a5,a5,a4
    80006676:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000667a:	0001d997          	auipc	s3,0x1d
    8000667e:	29698993          	addi	s3,s3,662 # 80023910 <disk>
    80006682:	00491713          	slli	a4,s2,0x4
    80006686:	0009b783          	ld	a5,0(s3)
    8000668a:	97ba                	add	a5,a5,a4
    8000668c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006690:	854a                	mv	a0,s2
    80006692:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006696:	00000097          	auipc	ra,0x0
    8000669a:	b70080e7          	jalr	-1168(ra) # 80006206 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000669e:	8885                	andi	s1,s1,1
    800066a0:	f0ed                	bnez	s1,80006682 <virtio_disk_rw+0x20a>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800066a2:	0001d517          	auipc	a0,0x1d
    800066a6:	39650513          	addi	a0,a0,918 # 80023a38 <disk+0x128>
    800066aa:	ffffa097          	auipc	ra,0xffffa
    800066ae:	5f4080e7          	jalr	1524(ra) # 80000c9e <release>
}
    800066b2:	70a6                	ld	ra,104(sp)
    800066b4:	7406                	ld	s0,96(sp)
    800066b6:	64e6                	ld	s1,88(sp)
    800066b8:	6946                	ld	s2,80(sp)
    800066ba:	69a6                	ld	s3,72(sp)
    800066bc:	6a06                	ld	s4,64(sp)
    800066be:	7ae2                	ld	s5,56(sp)
    800066c0:	7b42                	ld	s6,48(sp)
    800066c2:	7ba2                	ld	s7,40(sp)
    800066c4:	7c02                	ld	s8,32(sp)
    800066c6:	6ce2                	ld	s9,24(sp)
    800066c8:	6d42                	ld	s10,16(sp)
    800066ca:	6165                	addi	sp,sp,112
    800066cc:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800066ce:	4689                	li	a3,2
    800066d0:	00d79623          	sh	a3,12(a5)
    800066d4:	b5e5                	j	800065bc <virtio_disk_rw+0x144>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800066d6:	f9042603          	lw	a2,-112(s0)
    800066da:	00a60713          	addi	a4,a2,10
    800066de:	0712                	slli	a4,a4,0x4
    800066e0:	0001d517          	auipc	a0,0x1d
    800066e4:	23850513          	addi	a0,a0,568 # 80023918 <disk+0x8>
    800066e8:	953a                	add	a0,a0,a4
  if(write)
    800066ea:	e60d14e3          	bnez	s10,80006552 <virtio_disk_rw+0xda>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    800066ee:	00a60793          	addi	a5,a2,10
    800066f2:	00479693          	slli	a3,a5,0x4
    800066f6:	0001d797          	auipc	a5,0x1d
    800066fa:	21a78793          	addi	a5,a5,538 # 80023910 <disk>
    800066fe:	97b6                	add	a5,a5,a3
    80006700:	0007a423          	sw	zero,8(a5)
    80006704:	b595                	j	80006568 <virtio_disk_rw+0xf0>

0000000080006706 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006706:	1101                	addi	sp,sp,-32
    80006708:	ec06                	sd	ra,24(sp)
    8000670a:	e822                	sd	s0,16(sp)
    8000670c:	e426                	sd	s1,8(sp)
    8000670e:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006710:	0001d497          	auipc	s1,0x1d
    80006714:	20048493          	addi	s1,s1,512 # 80023910 <disk>
    80006718:	0001d517          	auipc	a0,0x1d
    8000671c:	32050513          	addi	a0,a0,800 # 80023a38 <disk+0x128>
    80006720:	ffffa097          	auipc	ra,0xffffa
    80006724:	4ca080e7          	jalr	1226(ra) # 80000bea <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006728:	10001737          	lui	a4,0x10001
    8000672c:	533c                	lw	a5,96(a4)
    8000672e:	8b8d                	andi	a5,a5,3
    80006730:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006732:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006736:	689c                	ld	a5,16(s1)
    80006738:	0204d703          	lhu	a4,32(s1)
    8000673c:	0027d783          	lhu	a5,2(a5)
    80006740:	04f70863          	beq	a4,a5,80006790 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006744:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006748:	6898                	ld	a4,16(s1)
    8000674a:	0204d783          	lhu	a5,32(s1)
    8000674e:	8b9d                	andi	a5,a5,7
    80006750:	078e                	slli	a5,a5,0x3
    80006752:	97ba                	add	a5,a5,a4
    80006754:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006756:	00278713          	addi	a4,a5,2
    8000675a:	0712                	slli	a4,a4,0x4
    8000675c:	9726                	add	a4,a4,s1
    8000675e:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006762:	e721                	bnez	a4,800067aa <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006764:	0789                	addi	a5,a5,2
    80006766:	0792                	slli	a5,a5,0x4
    80006768:	97a6                	add	a5,a5,s1
    8000676a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000676c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006770:	ffffc097          	auipc	ra,0xffffc
    80006774:	c16080e7          	jalr	-1002(ra) # 80002386 <wakeup>

    disk.used_idx += 1;
    80006778:	0204d783          	lhu	a5,32(s1)
    8000677c:	2785                	addiw	a5,a5,1
    8000677e:	17c2                	slli	a5,a5,0x30
    80006780:	93c1                	srli	a5,a5,0x30
    80006782:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006786:	6898                	ld	a4,16(s1)
    80006788:	00275703          	lhu	a4,2(a4)
    8000678c:	faf71ce3          	bne	a4,a5,80006744 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006790:	0001d517          	auipc	a0,0x1d
    80006794:	2a850513          	addi	a0,a0,680 # 80023a38 <disk+0x128>
    80006798:	ffffa097          	auipc	ra,0xffffa
    8000679c:	506080e7          	jalr	1286(ra) # 80000c9e <release>
}
    800067a0:	60e2                	ld	ra,24(sp)
    800067a2:	6442                	ld	s0,16(sp)
    800067a4:	64a2                	ld	s1,8(sp)
    800067a6:	6105                	addi	sp,sp,32
    800067a8:	8082                	ret
      panic("virtio_disk_intr status");
    800067aa:	00002517          	auipc	a0,0x2
    800067ae:	1c650513          	addi	a0,a0,454 # 80008970 <syscalls+0x3f8>
    800067b2:	ffffa097          	auipc	ra,0xffffa
    800067b6:	d92080e7          	jalr	-622(ra) # 80000544 <panic>
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
