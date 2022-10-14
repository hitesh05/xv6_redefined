
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
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
    80000022:	f14027f3          	csrr	a5,mhartid
    80000026:	0007869b          	sext.w	a3,a5
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	bee70713          	addi	a4,a4,-1042 # 80008c40 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
    8000005c:	ef1c                	sd	a5,24(a4)
    8000005e:	f310                	sd	a2,32(a4)
    80000060:	34071073          	csrw	mscratch,a4
    80000064:	00006797          	auipc	a5,0x6
    80000068:	53c78793          	addi	a5,a5,1340 # 800065a0 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
    80000070:	300027f3          	csrr	a5,mstatus
    80000074:	0087e793          	ori	a5,a5,8
    80000078:	30079073          	csrw	mstatus,a5
    8000007c:	304027f3          	csrr	a5,mie
    80000080:	0807e793          	ori	a5,a5,128
    80000084:	30479073          	csrw	mie,a5
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
    80000096:	300027f3          	csrr	a5,mstatus
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7f97a537>
    800000a0:	8ff9                	and	a5,a5,a4
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
    800000aa:	30079073          	csrw	mstatus,a5
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	fa478793          	addi	a5,a5,-92 # 80001052 <main>
    800000b6:	34179073          	csrw	mepc,a5
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
    800000c8:	30379073          	csrw	mideleg,a5
    800000cc:	104027f3          	csrr	a5,sie
    800000d0:	2227e793          	ori	a5,a5,546
    800000d4:	10479073          	csrw	sie,a5
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
    800000ee:	f14027f3          	csrr	a5,mhartid
    800000f2:	2781                	sext.w	a5,a5
    800000f4:	823e                	mv	tp,a5
    800000f6:	30200073          	mret
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
    800002f8:	00002097          	auipc	ra,0x2
    800002fc:	7b6080e7          	jalr	1974(ra) # 80002aae <procdump>
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
    8000046a:	91a50513          	addi	a0,a0,-1766 # 80010d80 <cons>
    8000046e:	00001097          	auipc	ra,0x1
    80000472:	8aa080e7          	jalr	-1878(ra) # 80000d18 <initlock>

  uartinit();
    80000476:	00000097          	auipc	ra,0x0
    8000047a:	330080e7          	jalr	816(ra) # 800007a6 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000047e:	00683797          	auipc	a5,0x683
    80000482:	cb278793          	addi	a5,a5,-846 # 80683130 <devsw>
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
    800004a2:	7179                	addi	sp,sp,-48
    800004a4:	f406                	sd	ra,40(sp)
    800004a6:	f022                	sd	s0,32(sp)
    800004a8:	ec26                	sd	s1,24(sp)
    800004aa:	e84a                	sd	s2,16(sp)
    800004ac:	1800                	addi	s0,sp,48
    800004ae:	c219                	beqz	a2,800004b4 <printint+0x12>
    800004b0:	08054663          	bltz	a0,8000053c <printint+0x9a>
    800004b4:	2501                	sext.w	a0,a0
    800004b6:	4881                	li	a7,0
    800004b8:	fd040693          	addi	a3,s0,-48
    800004bc:	4701                	li	a4,0
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
    800004de:	0005079b          	sext.w	a5,a0
    800004e2:	02b5553b          	divuw	a0,a0,a1
    800004e6:	0685                	addi	a3,a3,1
    800004e8:	feb7f0e3          	bgeu	a5,a1,800004c8 <printint+0x26>
    800004ec:	00088b63          	beqz	a7,80000502 <printint+0x60>
    800004f0:	fe040793          	addi	a5,s0,-32
    800004f4:	973e                	add	a4,a4,a5
    800004f6:	02d00793          	li	a5,45
    800004fa:	fef70823          	sb	a5,-16(a4)
    800004fe:	0028071b          	addiw	a4,a6,2
    80000502:	02e05763          	blez	a4,80000530 <printint+0x8e>
    80000506:	fd040793          	addi	a5,s0,-48
    8000050a:	00e784b3          	add	s1,a5,a4
    8000050e:	fff78913          	addi	s2,a5,-1
    80000512:	993a                	add	s2,s2,a4
    80000514:	377d                	addiw	a4,a4,-1
    80000516:	1702                	slli	a4,a4,0x20
    80000518:	9301                	srli	a4,a4,0x20
    8000051a:	40e90933          	sub	s2,s2,a4
    8000051e:	fff4c503          	lbu	a0,-1(s1)
    80000522:	00000097          	auipc	ra,0x0
    80000526:	d60080e7          	jalr	-672(ra) # 80000282 <consputc>
    8000052a:	14fd                	addi	s1,s1,-1
    8000052c:	ff2499e3          	bne	s1,s2,8000051e <printint+0x7c>
    80000530:	70a2                	ld	ra,40(sp)
    80000532:	7402                	ld	s0,32(sp)
    80000534:	64e2                	ld	s1,24(sp)
    80000536:	6942                	ld	s2,16(sp)
    80000538:	6145                	addi	sp,sp,48
    8000053a:	8082                	ret
    8000053c:	40a0053b          	negw	a0,a0
    80000540:	4885                	li	a7,1
    80000542:	bf9d                	j	800004b8 <printint+0x16>

0000000080000544 <panic>:
    80000544:	1101                	addi	sp,sp,-32
    80000546:	ec06                	sd	ra,24(sp)
    80000548:	e822                	sd	s0,16(sp)
    8000054a:	e426                	sd	s1,8(sp)
    8000054c:	1000                	addi	s0,sp,32
    8000054e:	84aa                	mv	s1,a0
    80000550:	00011797          	auipc	a5,0x11
    80000554:	8e07a823          	sw	zero,-1808(a5) # 80010e40 <pr+0x18>
    80000558:	00008517          	auipc	a0,0x8
    8000055c:	ac050513          	addi	a0,a0,-1344 # 80008018 <etext+0x18>
    80000560:	00000097          	auipc	ra,0x0
    80000564:	02e080e7          	jalr	46(ra) # 8000058e <printf>
    80000568:	8526                	mv	a0,s1
    8000056a:	00000097          	auipc	ra,0x0
    8000056e:	024080e7          	jalr	36(ra) # 8000058e <printf>
    80000572:	00008517          	auipc	a0,0x8
    80000576:	b8650513          	addi	a0,a0,-1146 # 800080f8 <digits+0xb8>
    8000057a:	00000097          	auipc	ra,0x0
    8000057e:	014080e7          	jalr	20(ra) # 8000058e <printf>
    80000582:	4785                	li	a5,1
    80000584:	00008717          	auipc	a4,0x8
    80000588:	66f72e23          	sw	a5,1660(a4) # 80008c00 <panicked>
    8000058c:	a001                	j	8000058c <panic+0x48>

000000008000058e <printf>:
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
    800005c0:	00011d97          	auipc	s11,0x11
    800005c4:	880dad83          	lw	s11,-1920(s11) # 80010e40 <pr+0x18>
    800005c8:	020d9b63          	bnez	s11,800005fe <printf+0x70>
    800005cc:	040a0263          	beqz	s4,80000610 <printf+0x82>
    800005d0:	00840793          	addi	a5,s0,8
    800005d4:	f8f43423          	sd	a5,-120(s0)
    800005d8:	000a4503          	lbu	a0,0(s4)
    800005dc:	16050263          	beqz	a0,80000740 <printf+0x1b2>
    800005e0:	4481                	li	s1,0
    800005e2:	02500a93          	li	s5,37
    800005e6:	07000b13          	li	s6,112
    800005ea:	4d41                	li	s10,16
    800005ec:	00008b97          	auipc	s7,0x8
    800005f0:	a54b8b93          	addi	s7,s7,-1452 # 80008040 <digits>
    800005f4:	07300c93          	li	s9,115
    800005f8:	06400c13          	li	s8,100
    800005fc:	a82d                	j	80000636 <printf+0xa8>
    800005fe:	00011517          	auipc	a0,0x11
    80000602:	82a50513          	addi	a0,a0,-2006 # 80010e28 <pr>
    80000606:	00000097          	auipc	ra,0x0
    8000060a:	7a2080e7          	jalr	1954(ra) # 80000da8 <acquire>
    8000060e:	bf7d                	j	800005cc <printf+0x3e>
    80000610:	00008517          	auipc	a0,0x8
    80000614:	a1850513          	addi	a0,a0,-1512 # 80008028 <etext+0x28>
    80000618:	00000097          	auipc	ra,0x0
    8000061c:	f2c080e7          	jalr	-212(ra) # 80000544 <panic>
    80000620:	00000097          	auipc	ra,0x0
    80000624:	c62080e7          	jalr	-926(ra) # 80000282 <consputc>
    80000628:	2485                	addiw	s1,s1,1
    8000062a:	009a07b3          	add	a5,s4,s1
    8000062e:	0007c503          	lbu	a0,0(a5)
    80000632:	10050763          	beqz	a0,80000740 <printf+0x1b2>
    80000636:	ff5515e3          	bne	a0,s5,80000620 <printf+0x92>
    8000063a:	2485                	addiw	s1,s1,1
    8000063c:	009a07b3          	add	a5,s4,s1
    80000640:	0007c783          	lbu	a5,0(a5)
    80000644:	0007891b          	sext.w	s2,a5
    80000648:	cfe5                	beqz	a5,80000740 <printf+0x1b2>
    8000064a:	05678a63          	beq	a5,s6,8000069e <printf+0x110>
    8000064e:	02fb7663          	bgeu	s6,a5,8000067a <printf+0xec>
    80000652:	09978963          	beq	a5,s9,800006e4 <printf+0x156>
    80000656:	07800713          	li	a4,120
    8000065a:	0ce79863          	bne	a5,a4,8000072a <printf+0x19c>
    8000065e:	f8843783          	ld	a5,-120(s0)
    80000662:	00878713          	addi	a4,a5,8
    80000666:	f8e43423          	sd	a4,-120(s0)
    8000066a:	4605                	li	a2,1
    8000066c:	85ea                	mv	a1,s10
    8000066e:	4388                	lw	a0,0(a5)
    80000670:	00000097          	auipc	ra,0x0
    80000674:	e32080e7          	jalr	-462(ra) # 800004a2 <printint>
    80000678:	bf45                	j	80000628 <printf+0x9a>
    8000067a:	0b578263          	beq	a5,s5,8000071e <printf+0x190>
    8000067e:	0b879663          	bne	a5,s8,8000072a <printf+0x19c>
    80000682:	f8843783          	ld	a5,-120(s0)
    80000686:	00878713          	addi	a4,a5,8
    8000068a:	f8e43423          	sd	a4,-120(s0)
    8000068e:	4605                	li	a2,1
    80000690:	45a9                	li	a1,10
    80000692:	4388                	lw	a0,0(a5)
    80000694:	00000097          	auipc	ra,0x0
    80000698:	e0e080e7          	jalr	-498(ra) # 800004a2 <printint>
    8000069c:	b771                	j	80000628 <printf+0x9a>
    8000069e:	f8843783          	ld	a5,-120(s0)
    800006a2:	00878713          	addi	a4,a5,8
    800006a6:	f8e43423          	sd	a4,-120(s0)
    800006aa:	0007b983          	ld	s3,0(a5)
    800006ae:	03000513          	li	a0,48
    800006b2:	00000097          	auipc	ra,0x0
    800006b6:	bd0080e7          	jalr	-1072(ra) # 80000282 <consputc>
    800006ba:	07800513          	li	a0,120
    800006be:	00000097          	auipc	ra,0x0
    800006c2:	bc4080e7          	jalr	-1084(ra) # 80000282 <consputc>
    800006c6:	896a                	mv	s2,s10
    800006c8:	03c9d793          	srli	a5,s3,0x3c
    800006cc:	97de                	add	a5,a5,s7
    800006ce:	0007c503          	lbu	a0,0(a5)
    800006d2:	00000097          	auipc	ra,0x0
    800006d6:	bb0080e7          	jalr	-1104(ra) # 80000282 <consputc>
    800006da:	0992                	slli	s3,s3,0x4
    800006dc:	397d                	addiw	s2,s2,-1
    800006de:	fe0915e3          	bnez	s2,800006c8 <printf+0x13a>
    800006e2:	b799                	j	80000628 <printf+0x9a>
    800006e4:	f8843783          	ld	a5,-120(s0)
    800006e8:	00878713          	addi	a4,a5,8
    800006ec:	f8e43423          	sd	a4,-120(s0)
    800006f0:	0007b903          	ld	s2,0(a5)
    800006f4:	00090e63          	beqz	s2,80000710 <printf+0x182>
    800006f8:	00094503          	lbu	a0,0(s2)
    800006fc:	d515                	beqz	a0,80000628 <printf+0x9a>
    800006fe:	00000097          	auipc	ra,0x0
    80000702:	b84080e7          	jalr	-1148(ra) # 80000282 <consputc>
    80000706:	0905                	addi	s2,s2,1
    80000708:	00094503          	lbu	a0,0(s2)
    8000070c:	f96d                	bnez	a0,800006fe <printf+0x170>
    8000070e:	bf29                	j	80000628 <printf+0x9a>
    80000710:	00008917          	auipc	s2,0x8
    80000714:	91090913          	addi	s2,s2,-1776 # 80008020 <etext+0x20>
    80000718:	02800513          	li	a0,40
    8000071c:	b7cd                	j	800006fe <printf+0x170>
    8000071e:	8556                	mv	a0,s5
    80000720:	00000097          	auipc	ra,0x0
    80000724:	b62080e7          	jalr	-1182(ra) # 80000282 <consputc>
    80000728:	b701                	j	80000628 <printf+0x9a>
    8000072a:	8556                	mv	a0,s5
    8000072c:	00000097          	auipc	ra,0x0
    80000730:	b56080e7          	jalr	-1194(ra) # 80000282 <consputc>
    80000734:	854a                	mv	a0,s2
    80000736:	00000097          	auipc	ra,0x0
    8000073a:	b4c080e7          	jalr	-1204(ra) # 80000282 <consputc>
    8000073e:	b5ed                	j	80000628 <printf+0x9a>
    80000740:	020d9163          	bnez	s11,80000762 <printf+0x1d4>
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
    80000762:	00010517          	auipc	a0,0x10
    80000766:	6c650513          	addi	a0,a0,1734 # 80010e28 <pr>
    8000076a:	00000097          	auipc	ra,0x0
    8000076e:	6f2080e7          	jalr	1778(ra) # 80000e5c <release>
    80000772:	bfc9                	j	80000744 <printf+0x1b6>

0000000080000774 <printfinit>:
    80000774:	1101                	addi	sp,sp,-32
    80000776:	ec06                	sd	ra,24(sp)
    80000778:	e822                	sd	s0,16(sp)
    8000077a:	e426                	sd	s1,8(sp)
    8000077c:	1000                	addi	s0,sp,32
    8000077e:	00010497          	auipc	s1,0x10
    80000782:	6aa48493          	addi	s1,s1,1706 # 80010e28 <pr>
    80000786:	00008597          	auipc	a1,0x8
    8000078a:	8b258593          	addi	a1,a1,-1870 # 80008038 <etext+0x38>
    8000078e:	8526                	mv	a0,s1
    80000790:	00000097          	auipc	ra,0x0
    80000794:	588080e7          	jalr	1416(ra) # 80000d18 <initlock>
    80000798:	4785                	li	a5,1
    8000079a:	cc9c                	sw	a5,24(s1)
    8000079c:	60e2                	ld	ra,24(sp)
    8000079e:	6442                	ld	s0,16(sp)
    800007a0:	64a2                	ld	s1,8(sp)
    800007a2:	6105                	addi	sp,sp,32
    800007a4:	8082                	ret

00000000800007a6 <uartinit>:
    800007a6:	1141                	addi	sp,sp,-16
    800007a8:	e406                	sd	ra,8(sp)
    800007aa:	e022                	sd	s0,0(sp)
    800007ac:	0800                	addi	s0,sp,16
    800007ae:	100007b7          	lui	a5,0x10000
    800007b2:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>
    800007b6:	f8000713          	li	a4,-128
    800007ba:	00e781a3          	sb	a4,3(a5)
    800007be:	470d                	li	a4,3
    800007c0:	00e78023          	sb	a4,0(a5)
    800007c4:	000780a3          	sb	zero,1(a5)
    800007c8:	00e781a3          	sb	a4,3(a5)
    800007cc:	469d                	li	a3,7
    800007ce:	00d78123          	sb	a3,2(a5)
    800007d2:	00e780a3          	sb	a4,1(a5)
    800007d6:	00008597          	auipc	a1,0x8
    800007da:	88258593          	addi	a1,a1,-1918 # 80008058 <digits+0x18>
    800007de:	00010517          	auipc	a0,0x10
    800007e2:	66a50513          	addi	a0,a0,1642 # 80010e48 <uart_tx_lock>
    800007e6:	00000097          	auipc	ra,0x0
    800007ea:	532080e7          	jalr	1330(ra) # 80000d18 <initlock>
    800007ee:	60a2                	ld	ra,8(sp)
    800007f0:	6402                	ld	s0,0(sp)
    800007f2:	0141                	addi	sp,sp,16
    800007f4:	8082                	ret

00000000800007f6 <uartputc_sync>:
    800007f6:	1101                	addi	sp,sp,-32
    800007f8:	ec06                	sd	ra,24(sp)
    800007fa:	e822                	sd	s0,16(sp)
    800007fc:	e426                	sd	s1,8(sp)
    800007fe:	1000                	addi	s0,sp,32
    80000800:	84aa                	mv	s1,a0
    80000802:	00000097          	auipc	ra,0x0
    80000806:	55a080e7          	jalr	1370(ra) # 80000d5c <push_off>
    8000080a:	00008797          	auipc	a5,0x8
    8000080e:	3f67a783          	lw	a5,1014(a5) # 80008c00 <panicked>
    80000812:	10000737          	lui	a4,0x10000
    80000816:	c391                	beqz	a5,8000081a <uartputc_sync+0x24>
    80000818:	a001                	j	80000818 <uartputc_sync+0x22>
    8000081a:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000081e:	0ff7f793          	andi	a5,a5,255
    80000822:	0207f793          	andi	a5,a5,32
    80000826:	dbf5                	beqz	a5,8000081a <uartputc_sync+0x24>
    80000828:	0ff4f793          	andi	a5,s1,255
    8000082c:	10000737          	lui	a4,0x10000
    80000830:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>
    80000834:	00000097          	auipc	ra,0x0
    80000838:	5c8080e7          	jalr	1480(ra) # 80000dfc <pop_off>
    8000083c:	60e2                	ld	ra,24(sp)
    8000083e:	6442                	ld	s0,16(sp)
    80000840:	64a2                	ld	s1,8(sp)
    80000842:	6105                	addi	sp,sp,32
    80000844:	8082                	ret

0000000080000846 <uartstart>:
    80000846:	00008717          	auipc	a4,0x8
    8000084a:	3c273703          	ld	a4,962(a4) # 80008c08 <uart_tx_r>
    8000084e:	00008797          	auipc	a5,0x8
    80000852:	3c27b783          	ld	a5,962(a5) # 80008c10 <uart_tx_w>
    80000856:	06e78c63          	beq	a5,a4,800008ce <uartstart+0x88>
    8000085a:	7139                	addi	sp,sp,-64
    8000085c:	fc06                	sd	ra,56(sp)
    8000085e:	f822                	sd	s0,48(sp)
    80000860:	f426                	sd	s1,40(sp)
    80000862:	f04a                	sd	s2,32(sp)
    80000864:	ec4e                	sd	s3,24(sp)
    80000866:	e852                	sd	s4,16(sp)
    80000868:	e456                	sd	s5,8(sp)
    8000086a:	0080                	addi	s0,sp,64
    8000086c:	10000937          	lui	s2,0x10000
    80000870:	00010a17          	auipc	s4,0x10
    80000874:	5d8a0a13          	addi	s4,s4,1496 # 80010e48 <uart_tx_lock>
    80000878:	00008497          	auipc	s1,0x8
    8000087c:	39048493          	addi	s1,s1,912 # 80008c08 <uart_tx_r>
    80000880:	00008997          	auipc	s3,0x8
    80000884:	39098993          	addi	s3,s3,912 # 80008c10 <uart_tx_w>
    80000888:	00594783          	lbu	a5,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000088c:	0ff7f793          	andi	a5,a5,255
    80000890:	0207f793          	andi	a5,a5,32
    80000894:	c785                	beqz	a5,800008bc <uartstart+0x76>
    80000896:	01f77793          	andi	a5,a4,31
    8000089a:	97d2                	add	a5,a5,s4
    8000089c:	0187ca83          	lbu	s5,24(a5)
    800008a0:	0705                	addi	a4,a4,1
    800008a2:	e098                	sd	a4,0(s1)
    800008a4:	8526                	mv	a0,s1
    800008a6:	00002097          	auipc	ra,0x2
    800008aa:	e80080e7          	jalr	-384(ra) # 80002726 <wakeup>
    800008ae:	01590023          	sb	s5,0(s2)
    800008b2:	6098                	ld	a4,0(s1)
    800008b4:	0009b783          	ld	a5,0(s3)
    800008b8:	fce798e3          	bne	a5,a4,80000888 <uartstart+0x42>
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
    800008d0:	7179                	addi	sp,sp,-48
    800008d2:	f406                	sd	ra,40(sp)
    800008d4:	f022                	sd	s0,32(sp)
    800008d6:	ec26                	sd	s1,24(sp)
    800008d8:	e84a                	sd	s2,16(sp)
    800008da:	e44e                	sd	s3,8(sp)
    800008dc:	e052                	sd	s4,0(sp)
    800008de:	1800                	addi	s0,sp,48
    800008e0:	89aa                	mv	s3,a0
    800008e2:	00010517          	auipc	a0,0x10
    800008e6:	56650513          	addi	a0,a0,1382 # 80010e48 <uart_tx_lock>
    800008ea:	00000097          	auipc	ra,0x0
    800008ee:	4be080e7          	jalr	1214(ra) # 80000da8 <acquire>
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	30e7a783          	lw	a5,782(a5) # 80008c00 <panicked>
    800008fa:	e7c9                	bnez	a5,80000984 <uartputc+0xb4>
    800008fc:	00008797          	auipc	a5,0x8
    80000900:	3147b783          	ld	a5,788(a5) # 80008c10 <uart_tx_w>
    80000904:	00008717          	auipc	a4,0x8
    80000908:	30473703          	ld	a4,772(a4) # 80008c08 <uart_tx_r>
    8000090c:	02070713          	addi	a4,a4,32
    80000910:	00010a17          	auipc	s4,0x10
    80000914:	538a0a13          	addi	s4,s4,1336 # 80010e48 <uart_tx_lock>
    80000918:	00008497          	auipc	s1,0x8
    8000091c:	2f048493          	addi	s1,s1,752 # 80008c08 <uart_tx_r>
    80000920:	00008917          	auipc	s2,0x8
    80000924:	2f090913          	addi	s2,s2,752 # 80008c10 <uart_tx_w>
    80000928:	00f71f63          	bne	a4,a5,80000946 <uartputc+0x76>
    8000092c:	85d2                	mv	a1,s4
    8000092e:	8526                	mv	a0,s1
    80000930:	00002097          	auipc	ra,0x2
    80000934:	af8080e7          	jalr	-1288(ra) # 80002428 <sleep>
    80000938:	00093783          	ld	a5,0(s2)
    8000093c:	6098                	ld	a4,0(s1)
    8000093e:	02070713          	addi	a4,a4,32
    80000942:	fef705e3          	beq	a4,a5,8000092c <uartputc+0x5c>
    80000946:	00010497          	auipc	s1,0x10
    8000094a:	50248493          	addi	s1,s1,1282 # 80010e48 <uart_tx_lock>
    8000094e:	01f7f713          	andi	a4,a5,31
    80000952:	9726                	add	a4,a4,s1
    80000954:	01370c23          	sb	s3,24(a4)
    80000958:	0785                	addi	a5,a5,1
    8000095a:	00008717          	auipc	a4,0x8
    8000095e:	2af73b23          	sd	a5,694(a4) # 80008c10 <uart_tx_w>
    80000962:	00000097          	auipc	ra,0x0
    80000966:	ee4080e7          	jalr	-284(ra) # 80000846 <uartstart>
    8000096a:	8526                	mv	a0,s1
    8000096c:	00000097          	auipc	ra,0x0
    80000970:	4f0080e7          	jalr	1264(ra) # 80000e5c <release>
    80000974:	70a2                	ld	ra,40(sp)
    80000976:	7402                	ld	s0,32(sp)
    80000978:	64e2                	ld	s1,24(sp)
    8000097a:	6942                	ld	s2,16(sp)
    8000097c:	69a2                	ld	s3,8(sp)
    8000097e:	6a02                	ld	s4,0(sp)
    80000980:	6145                	addi	sp,sp,48
    80000982:	8082                	ret
    80000984:	a001                	j	80000984 <uartputc+0xb4>

0000000080000986 <uartgetc>:
    80000986:	1141                	addi	sp,sp,-16
    80000988:	e422                	sd	s0,8(sp)
    8000098a:	0800                	addi	s0,sp,16
    8000098c:	100007b7          	lui	a5,0x10000
    80000990:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000994:	8b85                	andi	a5,a5,1
    80000996:	cb91                	beqz	a5,800009aa <uartgetc+0x24>
    80000998:	100007b7          	lui	a5,0x10000
    8000099c:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800009a0:	0ff57513          	andi	a0,a0,255
    800009a4:	6422                	ld	s0,8(sp)
    800009a6:	0141                	addi	sp,sp,16
    800009a8:	8082                	ret
    800009aa:	557d                	li	a0,-1
    800009ac:	bfe5                	j	800009a4 <uartgetc+0x1e>

00000000800009ae <uartintr>:
    800009ae:	1101                	addi	sp,sp,-32
    800009b0:	ec06                	sd	ra,24(sp)
    800009b2:	e822                	sd	s0,16(sp)
    800009b4:	e426                	sd	s1,8(sp)
    800009b6:	1000                	addi	s0,sp,32
    800009b8:	54fd                	li	s1,-1
    800009ba:	00000097          	auipc	ra,0x0
    800009be:	fcc080e7          	jalr	-52(ra) # 80000986 <uartgetc>
    800009c2:	00950763          	beq	a0,s1,800009d0 <uartintr+0x22>
    800009c6:	00000097          	auipc	ra,0x0
    800009ca:	8fe080e7          	jalr	-1794(ra) # 800002c4 <consoleintr>
    800009ce:	b7f5                	j	800009ba <uartintr+0xc>
    800009d0:	00010497          	auipc	s1,0x10
    800009d4:	47848493          	addi	s1,s1,1144 # 80010e48 <uart_tx_lock>
    800009d8:	8526                	mv	a0,s1
    800009da:	00000097          	auipc	ra,0x0
    800009de:	3ce080e7          	jalr	974(ra) # 80000da8 <acquire>
    800009e2:	00000097          	auipc	ra,0x0
    800009e6:	e64080e7          	jalr	-412(ra) # 80000846 <uartstart>
    800009ea:	8526                	mv	a0,s1
    800009ec:	00000097          	auipc	ra,0x0
    800009f0:	470080e7          	jalr	1136(ra) # 80000e5c <release>
    800009f4:	60e2                	ld	ra,24(sp)
    800009f6:	6442                	ld	s0,16(sp)
    800009f8:	64a2                	ld	s1,8(sp)
    800009fa:	6105                	addi	sp,sp,32
    800009fc:	8082                	ret

00000000800009fe <krefincr>:
	struct spinlock lock;
	int count[(PHYSTOP / PGSIZE)*3];
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
    80000ae2:	00683797          	auipc	a5,0x683
    80000ae6:	7e678793          	addi	a5,a5,2022 # 806842c8 <end>
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
    80000c5c:	00683517          	auipc	a0,0x683
    80000c60:	66c50513          	addi	a0,a0,1644 # 806842c8 <end>
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
    80000d18:	1141                	addi	sp,sp,-16
    80000d1a:	e422                	sd	s0,8(sp)
    80000d1c:	0800                	addi	s0,sp,16
    80000d1e:	e50c                	sd	a1,8(a0)
    80000d20:	00052023          	sw	zero,0(a0)
    80000d24:	00053823          	sd	zero,16(a0)
    80000d28:	6422                	ld	s0,8(sp)
    80000d2a:	0141                	addi	sp,sp,16
    80000d2c:	8082                	ret

0000000080000d2e <holding>:
    80000d2e:	411c                	lw	a5,0(a0)
    80000d30:	e399                	bnez	a5,80000d36 <holding+0x8>
    80000d32:	4501                	li	a0,0
    80000d34:	8082                	ret
    80000d36:	1101                	addi	sp,sp,-32
    80000d38:	ec06                	sd	ra,24(sp)
    80000d3a:	e822                	sd	s0,16(sp)
    80000d3c:	e426                	sd	s1,8(sp)
    80000d3e:	1000                	addi	s0,sp,32
    80000d40:	6904                	ld	s1,16(a0)
    80000d42:	00001097          	auipc	ra,0x1
    80000d46:	f5a080e7          	jalr	-166(ra) # 80001c9c <mycpu>
    80000d4a:	40a48533          	sub	a0,s1,a0
    80000d4e:	00153513          	seqz	a0,a0
    80000d52:	60e2                	ld	ra,24(sp)
    80000d54:	6442                	ld	s0,16(sp)
    80000d56:	64a2                	ld	s1,8(sp)
    80000d58:	6105                	addi	sp,sp,32
    80000d5a:	8082                	ret

0000000080000d5c <push_off>:
    80000d5c:	1101                	addi	sp,sp,-32
    80000d5e:	ec06                	sd	ra,24(sp)
    80000d60:	e822                	sd	s0,16(sp)
    80000d62:	e426                	sd	s1,8(sp)
    80000d64:	1000                	addi	s0,sp,32
    80000d66:	100024f3          	csrr	s1,sstatus
    80000d6a:	100027f3          	csrr	a5,sstatus
    80000d6e:	9bf5                	andi	a5,a5,-3
    80000d70:	10079073          	csrw	sstatus,a5
    80000d74:	00001097          	auipc	ra,0x1
    80000d78:	f28080e7          	jalr	-216(ra) # 80001c9c <mycpu>
    80000d7c:	5d3c                	lw	a5,120(a0)
    80000d7e:	cf89                	beqz	a5,80000d98 <push_off+0x3c>
    80000d80:	00001097          	auipc	ra,0x1
    80000d84:	f1c080e7          	jalr	-228(ra) # 80001c9c <mycpu>
    80000d88:	5d3c                	lw	a5,120(a0)
    80000d8a:	2785                	addiw	a5,a5,1
    80000d8c:	dd3c                	sw	a5,120(a0)
    80000d8e:	60e2                	ld	ra,24(sp)
    80000d90:	6442                	ld	s0,16(sp)
    80000d92:	64a2                	ld	s1,8(sp)
    80000d94:	6105                	addi	sp,sp,32
    80000d96:	8082                	ret
    80000d98:	00001097          	auipc	ra,0x1
    80000d9c:	f04080e7          	jalr	-252(ra) # 80001c9c <mycpu>
    80000da0:	8085                	srli	s1,s1,0x1
    80000da2:	8885                	andi	s1,s1,1
    80000da4:	dd64                	sw	s1,124(a0)
    80000da6:	bfe9                	j	80000d80 <push_off+0x24>

0000000080000da8 <acquire>:
    80000da8:	1101                	addi	sp,sp,-32
    80000daa:	ec06                	sd	ra,24(sp)
    80000dac:	e822                	sd	s0,16(sp)
    80000dae:	e426                	sd	s1,8(sp)
    80000db0:	1000                	addi	s0,sp,32
    80000db2:	84aa                	mv	s1,a0
    80000db4:	00000097          	auipc	ra,0x0
    80000db8:	fa8080e7          	jalr	-88(ra) # 80000d5c <push_off>
    80000dbc:	8526                	mv	a0,s1
    80000dbe:	00000097          	auipc	ra,0x0
    80000dc2:	f70080e7          	jalr	-144(ra) # 80000d2e <holding>
    80000dc6:	4705                	li	a4,1
    80000dc8:	e115                	bnez	a0,80000dec <acquire+0x44>
    80000dca:	87ba                	mv	a5,a4
    80000dcc:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000dd0:	2781                	sext.w	a5,a5
    80000dd2:	ffe5                	bnez	a5,80000dca <acquire+0x22>
    80000dd4:	0ff0000f          	fence
    80000dd8:	00001097          	auipc	ra,0x1
    80000ddc:	ec4080e7          	jalr	-316(ra) # 80001c9c <mycpu>
    80000de0:	e888                	sd	a0,16(s1)
    80000de2:	60e2                	ld	ra,24(sp)
    80000de4:	6442                	ld	s0,16(sp)
    80000de6:	64a2                	ld	s1,8(sp)
    80000de8:	6105                	addi	sp,sp,32
    80000dea:	8082                	ret
    80000dec:	00007517          	auipc	a0,0x7
    80000df0:	2b450513          	addi	a0,a0,692 # 800080a0 <digits+0x60>
    80000df4:	fffff097          	auipc	ra,0xfffff
    80000df8:	750080e7          	jalr	1872(ra) # 80000544 <panic>

0000000080000dfc <pop_off>:
    80000dfc:	1141                	addi	sp,sp,-16
    80000dfe:	e406                	sd	ra,8(sp)
    80000e00:	e022                	sd	s0,0(sp)
    80000e02:	0800                	addi	s0,sp,16
    80000e04:	00001097          	auipc	ra,0x1
    80000e08:	e98080e7          	jalr	-360(ra) # 80001c9c <mycpu>
    80000e0c:	100027f3          	csrr	a5,sstatus
    80000e10:	8b89                	andi	a5,a5,2
    80000e12:	e78d                	bnez	a5,80000e3c <pop_off+0x40>
    80000e14:	5d3c                	lw	a5,120(a0)
    80000e16:	02f05b63          	blez	a5,80000e4c <pop_off+0x50>
    80000e1a:	37fd                	addiw	a5,a5,-1
    80000e1c:	0007871b          	sext.w	a4,a5
    80000e20:	dd3c                	sw	a5,120(a0)
    80000e22:	eb09                	bnez	a4,80000e34 <pop_off+0x38>
    80000e24:	5d7c                	lw	a5,124(a0)
    80000e26:	c799                	beqz	a5,80000e34 <pop_off+0x38>
    80000e28:	100027f3          	csrr	a5,sstatus
    80000e2c:	0027e793          	ori	a5,a5,2
    80000e30:	10079073          	csrw	sstatus,a5
    80000e34:	60a2                	ld	ra,8(sp)
    80000e36:	6402                	ld	s0,0(sp)
    80000e38:	0141                	addi	sp,sp,16
    80000e3a:	8082                	ret
    80000e3c:	00007517          	auipc	a0,0x7
    80000e40:	26c50513          	addi	a0,a0,620 # 800080a8 <digits+0x68>
    80000e44:	fffff097          	auipc	ra,0xfffff
    80000e48:	700080e7          	jalr	1792(ra) # 80000544 <panic>
    80000e4c:	00007517          	auipc	a0,0x7
    80000e50:	27450513          	addi	a0,a0,628 # 800080c0 <digits+0x80>
    80000e54:	fffff097          	auipc	ra,0xfffff
    80000e58:	6f0080e7          	jalr	1776(ra) # 80000544 <panic>

0000000080000e5c <release>:
    80000e5c:	1101                	addi	sp,sp,-32
    80000e5e:	ec06                	sd	ra,24(sp)
    80000e60:	e822                	sd	s0,16(sp)
    80000e62:	e426                	sd	s1,8(sp)
    80000e64:	1000                	addi	s0,sp,32
    80000e66:	84aa                	mv	s1,a0
    80000e68:	00000097          	auipc	ra,0x0
    80000e6c:	ec6080e7          	jalr	-314(ra) # 80000d2e <holding>
    80000e70:	c115                	beqz	a0,80000e94 <release+0x38>
    80000e72:	0004b823          	sd	zero,16(s1)
    80000e76:	0ff0000f          	fence
    80000e7a:	0f50000f          	fence	iorw,ow
    80000e7e:	0804a02f          	amoswap.w	zero,zero,(s1)
    80000e82:	00000097          	auipc	ra,0x0
    80000e86:	f7a080e7          	jalr	-134(ra) # 80000dfc <pop_off>
    80000e8a:	60e2                	ld	ra,24(sp)
    80000e8c:	6442                	ld	s0,16(sp)
    80000e8e:	64a2                	ld	s1,8(sp)
    80000e90:	6105                	addi	sp,sp,32
    80000e92:	8082                	ret
    80000e94:	00007517          	auipc	a0,0x7
    80000e98:	23450513          	addi	a0,a0,564 # 800080c8 <digits+0x88>
    80000e9c:	fffff097          	auipc	ra,0xfffff
    80000ea0:	6a8080e7          	jalr	1704(ra) # 80000544 <panic>

0000000080000ea4 <memset>:
    80000ea4:	1141                	addi	sp,sp,-16
    80000ea6:	e422                	sd	s0,8(sp)
    80000ea8:	0800                	addi	s0,sp,16
    80000eaa:	ce09                	beqz	a2,80000ec4 <memset+0x20>
    80000eac:	87aa                	mv	a5,a0
    80000eae:	fff6071b          	addiw	a4,a2,-1
    80000eb2:	1702                	slli	a4,a4,0x20
    80000eb4:	9301                	srli	a4,a4,0x20
    80000eb6:	0705                	addi	a4,a4,1
    80000eb8:	972a                	add	a4,a4,a0
    80000eba:	00b78023          	sb	a1,0(a5)
    80000ebe:	0785                	addi	a5,a5,1
    80000ec0:	fee79de3          	bne	a5,a4,80000eba <memset+0x16>
    80000ec4:	6422                	ld	s0,8(sp)
    80000ec6:	0141                	addi	sp,sp,16
    80000ec8:	8082                	ret

0000000080000eca <memcmp>:
    80000eca:	1141                	addi	sp,sp,-16
    80000ecc:	e422                	sd	s0,8(sp)
    80000ece:	0800                	addi	s0,sp,16
    80000ed0:	ca05                	beqz	a2,80000f00 <memcmp+0x36>
    80000ed2:	fff6069b          	addiw	a3,a2,-1
    80000ed6:	1682                	slli	a3,a3,0x20
    80000ed8:	9281                	srli	a3,a3,0x20
    80000eda:	0685                	addi	a3,a3,1
    80000edc:	96aa                	add	a3,a3,a0
    80000ede:	00054783          	lbu	a5,0(a0)
    80000ee2:	0005c703          	lbu	a4,0(a1)
    80000ee6:	00e79863          	bne	a5,a4,80000ef6 <memcmp+0x2c>
    80000eea:	0505                	addi	a0,a0,1
    80000eec:	0585                	addi	a1,a1,1
    80000eee:	fed518e3          	bne	a0,a3,80000ede <memcmp+0x14>
    80000ef2:	4501                	li	a0,0
    80000ef4:	a019                	j	80000efa <memcmp+0x30>
    80000ef6:	40e7853b          	subw	a0,a5,a4
    80000efa:	6422                	ld	s0,8(sp)
    80000efc:	0141                	addi	sp,sp,16
    80000efe:	8082                	ret
    80000f00:	4501                	li	a0,0
    80000f02:	bfe5                	j	80000efa <memcmp+0x30>

0000000080000f04 <memmove>:
    80000f04:	1141                	addi	sp,sp,-16
    80000f06:	e422                	sd	s0,8(sp)
    80000f08:	0800                	addi	s0,sp,16
    80000f0a:	ca0d                	beqz	a2,80000f3c <memmove+0x38>
    80000f0c:	00a5f963          	bgeu	a1,a0,80000f1e <memmove+0x1a>
    80000f10:	02061693          	slli	a3,a2,0x20
    80000f14:	9281                	srli	a3,a3,0x20
    80000f16:	00d58733          	add	a4,a1,a3
    80000f1a:	02e56463          	bltu	a0,a4,80000f42 <memmove+0x3e>
    80000f1e:	fff6079b          	addiw	a5,a2,-1
    80000f22:	1782                	slli	a5,a5,0x20
    80000f24:	9381                	srli	a5,a5,0x20
    80000f26:	0785                	addi	a5,a5,1
    80000f28:	97ae                	add	a5,a5,a1
    80000f2a:	872a                	mv	a4,a0
    80000f2c:	0585                	addi	a1,a1,1
    80000f2e:	0705                	addi	a4,a4,1
    80000f30:	fff5c683          	lbu	a3,-1(a1)
    80000f34:	fed70fa3          	sb	a3,-1(a4)
    80000f38:	fef59ae3          	bne	a1,a5,80000f2c <memmove+0x28>
    80000f3c:	6422                	ld	s0,8(sp)
    80000f3e:	0141                	addi	sp,sp,16
    80000f40:	8082                	ret
    80000f42:	96aa                	add	a3,a3,a0
    80000f44:	fff6079b          	addiw	a5,a2,-1
    80000f48:	1782                	slli	a5,a5,0x20
    80000f4a:	9381                	srli	a5,a5,0x20
    80000f4c:	fff7c793          	not	a5,a5
    80000f50:	97ba                	add	a5,a5,a4
    80000f52:	177d                	addi	a4,a4,-1
    80000f54:	16fd                	addi	a3,a3,-1
    80000f56:	00074603          	lbu	a2,0(a4)
    80000f5a:	00c68023          	sb	a2,0(a3)
    80000f5e:	fef71ae3          	bne	a4,a5,80000f52 <memmove+0x4e>
    80000f62:	bfe9                	j	80000f3c <memmove+0x38>

0000000080000f64 <memcpy>:
    80000f64:	1141                	addi	sp,sp,-16
    80000f66:	e406                	sd	ra,8(sp)
    80000f68:	e022                	sd	s0,0(sp)
    80000f6a:	0800                	addi	s0,sp,16
    80000f6c:	00000097          	auipc	ra,0x0
    80000f70:	f98080e7          	jalr	-104(ra) # 80000f04 <memmove>
    80000f74:	60a2                	ld	ra,8(sp)
    80000f76:	6402                	ld	s0,0(sp)
    80000f78:	0141                	addi	sp,sp,16
    80000f7a:	8082                	ret

0000000080000f7c <strncmp>:
    80000f7c:	1141                	addi	sp,sp,-16
    80000f7e:	e422                	sd	s0,8(sp)
    80000f80:	0800                	addi	s0,sp,16
    80000f82:	ce11                	beqz	a2,80000f9e <strncmp+0x22>
    80000f84:	00054783          	lbu	a5,0(a0)
    80000f88:	cf89                	beqz	a5,80000fa2 <strncmp+0x26>
    80000f8a:	0005c703          	lbu	a4,0(a1)
    80000f8e:	00f71a63          	bne	a4,a5,80000fa2 <strncmp+0x26>
    80000f92:	367d                	addiw	a2,a2,-1
    80000f94:	0505                	addi	a0,a0,1
    80000f96:	0585                	addi	a1,a1,1
    80000f98:	f675                	bnez	a2,80000f84 <strncmp+0x8>
    80000f9a:	4501                	li	a0,0
    80000f9c:	a809                	j	80000fae <strncmp+0x32>
    80000f9e:	4501                	li	a0,0
    80000fa0:	a039                	j	80000fae <strncmp+0x32>
    80000fa2:	ca09                	beqz	a2,80000fb4 <strncmp+0x38>
    80000fa4:	00054503          	lbu	a0,0(a0)
    80000fa8:	0005c783          	lbu	a5,0(a1)
    80000fac:	9d1d                	subw	a0,a0,a5
    80000fae:	6422                	ld	s0,8(sp)
    80000fb0:	0141                	addi	sp,sp,16
    80000fb2:	8082                	ret
    80000fb4:	4501                	li	a0,0
    80000fb6:	bfe5                	j	80000fae <strncmp+0x32>

0000000080000fb8 <strncpy>:
    80000fb8:	1141                	addi	sp,sp,-16
    80000fba:	e422                	sd	s0,8(sp)
    80000fbc:	0800                	addi	s0,sp,16
    80000fbe:	872a                	mv	a4,a0
    80000fc0:	8832                	mv	a6,a2
    80000fc2:	367d                	addiw	a2,a2,-1
    80000fc4:	01005963          	blez	a6,80000fd6 <strncpy+0x1e>
    80000fc8:	0705                	addi	a4,a4,1
    80000fca:	0005c783          	lbu	a5,0(a1)
    80000fce:	fef70fa3          	sb	a5,-1(a4)
    80000fd2:	0585                	addi	a1,a1,1
    80000fd4:	f7f5                	bnez	a5,80000fc0 <strncpy+0x8>
    80000fd6:	00c05d63          	blez	a2,80000ff0 <strncpy+0x38>
    80000fda:	86ba                	mv	a3,a4
    80000fdc:	0685                	addi	a3,a3,1
    80000fde:	fe068fa3          	sb	zero,-1(a3)
    80000fe2:	fff6c793          	not	a5,a3
    80000fe6:	9fb9                	addw	a5,a5,a4
    80000fe8:	010787bb          	addw	a5,a5,a6
    80000fec:	fef048e3          	bgtz	a5,80000fdc <strncpy+0x24>
    80000ff0:	6422                	ld	s0,8(sp)
    80000ff2:	0141                	addi	sp,sp,16
    80000ff4:	8082                	ret

0000000080000ff6 <safestrcpy>:
    80000ff6:	1141                	addi	sp,sp,-16
    80000ff8:	e422                	sd	s0,8(sp)
    80000ffa:	0800                	addi	s0,sp,16
    80000ffc:	02c05363          	blez	a2,80001022 <safestrcpy+0x2c>
    80001000:	fff6069b          	addiw	a3,a2,-1
    80001004:	1682                	slli	a3,a3,0x20
    80001006:	9281                	srli	a3,a3,0x20
    80001008:	96ae                	add	a3,a3,a1
    8000100a:	87aa                	mv	a5,a0
    8000100c:	00d58963          	beq	a1,a3,8000101e <safestrcpy+0x28>
    80001010:	0585                	addi	a1,a1,1
    80001012:	0785                	addi	a5,a5,1
    80001014:	fff5c703          	lbu	a4,-1(a1)
    80001018:	fee78fa3          	sb	a4,-1(a5)
    8000101c:	fb65                	bnez	a4,8000100c <safestrcpy+0x16>
    8000101e:	00078023          	sb	zero,0(a5)
    80001022:	6422                	ld	s0,8(sp)
    80001024:	0141                	addi	sp,sp,16
    80001026:	8082                	ret

0000000080001028 <strlen>:
    80001028:	1141                	addi	sp,sp,-16
    8000102a:	e422                	sd	s0,8(sp)
    8000102c:	0800                	addi	s0,sp,16
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
    80001048:	6422                	ld	s0,8(sp)
    8000104a:	0141                	addi	sp,sp,16
    8000104c:	8082                	ret
    8000104e:	4501                	li	a0,0
    80001050:	bfe5                	j	80001048 <strlen+0x20>

0000000080001052 <main>:
    80001052:	1141                	addi	sp,sp,-16
    80001054:	e406                	sd	ra,8(sp)
    80001056:	e022                	sd	s0,0(sp)
    80001058:	0800                	addi	s0,sp,16
    8000105a:	00001097          	auipc	ra,0x1
    8000105e:	c32080e7          	jalr	-974(ra) # 80001c8c <cpuid>
    80001062:	00008717          	auipc	a4,0x8
    80001066:	bb670713          	addi	a4,a4,-1098 # 80008c18 <started>
    8000106a:	c139                	beqz	a0,800010b0 <main+0x5e>
    8000106c:	431c                	lw	a5,0(a4)
    8000106e:	2781                	sext.w	a5,a5
    80001070:	dff5                	beqz	a5,8000106c <main+0x1a>
    80001072:	0ff0000f          	fence
    80001076:	00001097          	auipc	ra,0x1
    8000107a:	c16080e7          	jalr	-1002(ra) # 80001c8c <cpuid>
    8000107e:	85aa                	mv	a1,a0
    80001080:	00007517          	auipc	a0,0x7
    80001084:	06850513          	addi	a0,a0,104 # 800080e8 <digits+0xa8>
    80001088:	fffff097          	auipc	ra,0xfffff
    8000108c:	506080e7          	jalr	1286(ra) # 8000058e <printf>
    80001090:	00000097          	auipc	ra,0x0
    80001094:	0d8080e7          	jalr	216(ra) # 80001168 <kvminithart>
    80001098:	00002097          	auipc	ra,0x2
    8000109c:	b5a080e7          	jalr	-1190(ra) # 80002bf2 <trapinithart>
    800010a0:	00005097          	auipc	ra,0x5
    800010a4:	540080e7          	jalr	1344(ra) # 800065e0 <plicinithart>
    800010a8:	00001097          	auipc	ra,0x1
    800010ac:	1bc080e7          	jalr	444(ra) # 80002264 <scheduler>
    800010b0:	fffff097          	auipc	ra,0xfffff
    800010b4:	3a6080e7          	jalr	934(ra) # 80000456 <consoleinit>
    800010b8:	fffff097          	auipc	ra,0xfffff
    800010bc:	6bc080e7          	jalr	1724(ra) # 80000774 <printfinit>
    800010c0:	00007517          	auipc	a0,0x7
    800010c4:	03850513          	addi	a0,a0,56 # 800080f8 <digits+0xb8>
    800010c8:	fffff097          	auipc	ra,0xfffff
    800010cc:	4c6080e7          	jalr	1222(ra) # 8000058e <printf>
    800010d0:	00007517          	auipc	a0,0x7
    800010d4:	00050513          	mv	a0,a0
    800010d8:	fffff097          	auipc	ra,0xfffff
    800010dc:	4b6080e7          	jalr	1206(ra) # 8000058e <printf>
    800010e0:	00007517          	auipc	a0,0x7
    800010e4:	01850513          	addi	a0,a0,24 # 800080f8 <digits+0xb8>
    800010e8:	fffff097          	auipc	ra,0xfffff
    800010ec:	4a6080e7          	jalr	1190(ra) # 8000058e <printf>
    800010f0:	00000097          	auipc	ra,0x0
    800010f4:	b48080e7          	jalr	-1208(ra) # 80000c38 <kinit>
    800010f8:	00000097          	auipc	ra,0x0
    800010fc:	326080e7          	jalr	806(ra) # 8000141e <kvminit>
    80001100:	00000097          	auipc	ra,0x0
    80001104:	068080e7          	jalr	104(ra) # 80001168 <kvminithart>
    80001108:	00001097          	auipc	ra,0x1
    8000110c:	ace080e7          	jalr	-1330(ra) # 80001bd6 <procinit>
    80001110:	00002097          	auipc	ra,0x2
    80001114:	aba080e7          	jalr	-1350(ra) # 80002bca <trapinit>
    80001118:	00002097          	auipc	ra,0x2
    8000111c:	ada080e7          	jalr	-1318(ra) # 80002bf2 <trapinithart>
    80001120:	00005097          	auipc	ra,0x5
    80001124:	4aa080e7          	jalr	1194(ra) # 800065ca <plicinit>
    80001128:	00005097          	auipc	ra,0x5
    8000112c:	4b8080e7          	jalr	1208(ra) # 800065e0 <plicinithart>
    80001130:	00002097          	auipc	ra,0x2
    80001134:	66e080e7          	jalr	1646(ra) # 8000379e <binit>
    80001138:	00003097          	auipc	ra,0x3
    8000113c:	d12080e7          	jalr	-750(ra) # 80003e4a <iinit>
    80001140:	00004097          	auipc	ra,0x4
    80001144:	cb0080e7          	jalr	-848(ra) # 80004df0 <fileinit>
    80001148:	00005097          	auipc	ra,0x5
    8000114c:	5a0080e7          	jalr	1440(ra) # 800066e8 <virtio_disk_init>
    80001150:	00001097          	auipc	ra,0x1
    80001154:	e78080e7          	jalr	-392(ra) # 80001fc8 <userinit>
    80001158:	0ff0000f          	fence
    8000115c:	4785                	li	a5,1
    8000115e:	00008717          	auipc	a4,0x8
    80001162:	aaf72d23          	sw	a5,-1350(a4) # 80008c18 <started>
    80001166:	b789                	j	800010a8 <main+0x56>

0000000080001168 <kvminithart>:
    80001168:	1141                	addi	sp,sp,-16
    8000116a:	e422                	sd	s0,8(sp)
    8000116c:	0800                	addi	s0,sp,16
    8000116e:	12000073          	sfence.vma
    80001172:	00008797          	auipc	a5,0x8
    80001176:	aae7b783          	ld	a5,-1362(a5) # 80008c20 <kernel_pagetable>
    8000117a:	83b1                	srli	a5,a5,0xc
    8000117c:	577d                	li	a4,-1
    8000117e:	177e                	slli	a4,a4,0x3f
    80001180:	8fd9                	or	a5,a5,a4
    80001182:	18079073          	csrw	satp,a5
    80001186:	12000073          	sfence.vma
    8000118a:	6422                	ld	s0,8(sp)
    8000118c:	0141                	addi	sp,sp,16
    8000118e:	8082                	ret

0000000080001190 <walk>:
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
    800011aa:	57fd                	li	a5,-1
    800011ac:	83e9                	srli	a5,a5,0x1a
    800011ae:	4a79                	li	s4,30
    800011b0:	4b31                	li	s6,12
    800011b2:	04b7f263          	bgeu	a5,a1,800011f6 <walk+0x66>
    800011b6:	00007517          	auipc	a0,0x7
    800011ba:	f4a50513          	addi	a0,a0,-182 # 80008100 <digits+0xc0>
    800011be:	fffff097          	auipc	ra,0xfffff
    800011c2:	386080e7          	jalr	902(ra) # 80000544 <panic>
    800011c6:	060a8663          	beqz	s5,80001232 <walk+0xa2>
    800011ca:	00000097          	auipc	ra,0x0
    800011ce:	aaa080e7          	jalr	-1366(ra) # 80000c74 <kalloc>
    800011d2:	84aa                	mv	s1,a0
    800011d4:	c529                	beqz	a0,8000121e <walk+0x8e>
    800011d6:	6605                	lui	a2,0x1
    800011d8:	4581                	li	a1,0
    800011da:	00000097          	auipc	ra,0x0
    800011de:	cca080e7          	jalr	-822(ra) # 80000ea4 <memset>
    800011e2:	00c4d793          	srli	a5,s1,0xc
    800011e6:	07aa                	slli	a5,a5,0xa
    800011e8:	0017e793          	ori	a5,a5,1
    800011ec:	00f93023          	sd	a5,0(s2)
    800011f0:	3a5d                	addiw	s4,s4,-9
    800011f2:	036a0063          	beq	s4,s6,80001212 <walk+0x82>
    800011f6:	0149d933          	srl	s2,s3,s4
    800011fa:	1ff97913          	andi	s2,s2,511
    800011fe:	090e                	slli	s2,s2,0x3
    80001200:	9926                	add	s2,s2,s1
    80001202:	00093483          	ld	s1,0(s2)
    80001206:	0014f793          	andi	a5,s1,1
    8000120a:	dfd5                	beqz	a5,800011c6 <walk+0x36>
    8000120c:	80a9                	srli	s1,s1,0xa
    8000120e:	04b2                	slli	s1,s1,0xc
    80001210:	b7c5                	j	800011f0 <walk+0x60>
    80001212:	00c9d513          	srli	a0,s3,0xc
    80001216:	1ff57513          	andi	a0,a0,511
    8000121a:	050e                	slli	a0,a0,0x3
    8000121c:	9526                	add	a0,a0,s1
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
    80001232:	4501                	li	a0,0
    80001234:	b7ed                	j	8000121e <walk+0x8e>

0000000080001236 <walkaddr>:
    80001236:	57fd                	li	a5,-1
    80001238:	83e9                	srli	a5,a5,0x1a
    8000123a:	00b7f463          	bgeu	a5,a1,80001242 <walkaddr+0xc>
    8000123e:	4501                	li	a0,0
    80001240:	8082                	ret
    80001242:	1141                	addi	sp,sp,-16
    80001244:	e406                	sd	ra,8(sp)
    80001246:	e022                	sd	s0,0(sp)
    80001248:	0800                	addi	s0,sp,16
    8000124a:	4601                	li	a2,0
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	f44080e7          	jalr	-188(ra) # 80001190 <walk>
    80001254:	c105                	beqz	a0,80001274 <walkaddr+0x3e>
    80001256:	611c                	ld	a5,0(a0)
    80001258:	0117f693          	andi	a3,a5,17
    8000125c:	4745                	li	a4,17
    8000125e:	4501                	li	a0,0
    80001260:	00e68663          	beq	a3,a4,8000126c <walkaddr+0x36>
    80001264:	60a2                	ld	ra,8(sp)
    80001266:	6402                	ld	s0,0(sp)
    80001268:	0141                	addi	sp,sp,16
    8000126a:	8082                	ret
    8000126c:	00a7d513          	srli	a0,a5,0xa
    80001270:	0532                	slli	a0,a0,0xc
    80001272:	bfcd                	j	80001264 <walkaddr+0x2e>
    80001274:	4501                	li	a0,0
    80001276:	b7fd                	j	80001264 <walkaddr+0x2e>

0000000080001278 <mappages>:
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
    8000128e:	c205                	beqz	a2,800012ae <mappages+0x36>
    80001290:	8aaa                	mv	s5,a0
    80001292:	8b3a                	mv	s6,a4
    80001294:	77fd                	lui	a5,0xfffff
    80001296:	00f5fa33          	and	s4,a1,a5
    8000129a:	15fd                	addi	a1,a1,-1
    8000129c:	00c589b3          	add	s3,a1,a2
    800012a0:	00f9f9b3          	and	s3,s3,a5
    800012a4:	8952                	mv	s2,s4
    800012a6:	41468a33          	sub	s4,a3,s4
    800012aa:	6b85                	lui	s7,0x1
    800012ac:	a015                	j	800012d0 <mappages+0x58>
    800012ae:	00007517          	auipc	a0,0x7
    800012b2:	e5a50513          	addi	a0,a0,-422 # 80008108 <digits+0xc8>
    800012b6:	fffff097          	auipc	ra,0xfffff
    800012ba:	28e080e7          	jalr	654(ra) # 80000544 <panic>
    800012be:	00007517          	auipc	a0,0x7
    800012c2:	e5a50513          	addi	a0,a0,-422 # 80008118 <digits+0xd8>
    800012c6:	fffff097          	auipc	ra,0xfffff
    800012ca:	27e080e7          	jalr	638(ra) # 80000544 <panic>
    800012ce:	995e                	add	s2,s2,s7
    800012d0:	012a04b3          	add	s1,s4,s2
    800012d4:	4605                	li	a2,1
    800012d6:	85ca                	mv	a1,s2
    800012d8:	8556                	mv	a0,s5
    800012da:	00000097          	auipc	ra,0x0
    800012de:	eb6080e7          	jalr	-330(ra) # 80001190 <walk>
    800012e2:	cd19                	beqz	a0,80001300 <mappages+0x88>
    800012e4:	611c                	ld	a5,0(a0)
    800012e6:	8b85                	andi	a5,a5,1
    800012e8:	fbf9                	bnez	a5,800012be <mappages+0x46>
    800012ea:	80b1                	srli	s1,s1,0xc
    800012ec:	04aa                	slli	s1,s1,0xa
    800012ee:	0164e4b3          	or	s1,s1,s6
    800012f2:	0014e493          	ori	s1,s1,1
    800012f6:	e104                	sd	s1,0(a0)
    800012f8:	fd391be3          	bne	s2,s3,800012ce <mappages+0x56>
    800012fc:	4501                	li	a0,0
    800012fe:	a011                	j	80001302 <mappages+0x8a>
    80001300:	557d                	li	a0,-1
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
    80001318:	1141                	addi	sp,sp,-16
    8000131a:	e406                	sd	ra,8(sp)
    8000131c:	e022                	sd	s0,0(sp)
    8000131e:	0800                	addi	s0,sp,16
    80001320:	87b6                	mv	a5,a3
    80001322:	86b2                	mv	a3,a2
    80001324:	863e                	mv	a2,a5
    80001326:	00000097          	auipc	ra,0x0
    8000132a:	f52080e7          	jalr	-174(ra) # 80001278 <mappages>
    8000132e:	e509                	bnez	a0,80001338 <kvmmap+0x20>
    80001330:	60a2                	ld	ra,8(sp)
    80001332:	6402                	ld	s0,0(sp)
    80001334:	0141                	addi	sp,sp,16
    80001336:	8082                	ret
    80001338:	00007517          	auipc	a0,0x7
    8000133c:	df050513          	addi	a0,a0,-528 # 80008128 <digits+0xe8>
    80001340:	fffff097          	auipc	ra,0xfffff
    80001344:	204080e7          	jalr	516(ra) # 80000544 <panic>

0000000080001348 <kvmmake>:
    80001348:	1101                	addi	sp,sp,-32
    8000134a:	ec06                	sd	ra,24(sp)
    8000134c:	e822                	sd	s0,16(sp)
    8000134e:	e426                	sd	s1,8(sp)
    80001350:	e04a                	sd	s2,0(sp)
    80001352:	1000                	addi	s0,sp,32
    80001354:	00000097          	auipc	ra,0x0
    80001358:	920080e7          	jalr	-1760(ra) # 80000c74 <kalloc>
    8000135c:	84aa                	mv	s1,a0
    8000135e:	6605                	lui	a2,0x1
    80001360:	4581                	li	a1,0
    80001362:	00000097          	auipc	ra,0x0
    80001366:	b42080e7          	jalr	-1214(ra) # 80000ea4 <memset>
    8000136a:	4719                	li	a4,6
    8000136c:	6685                	lui	a3,0x1
    8000136e:	10000637          	lui	a2,0x10000
    80001372:	100005b7          	lui	a1,0x10000
    80001376:	8526                	mv	a0,s1
    80001378:	00000097          	auipc	ra,0x0
    8000137c:	fa0080e7          	jalr	-96(ra) # 80001318 <kvmmap>
    80001380:	4719                	li	a4,6
    80001382:	6685                	lui	a3,0x1
    80001384:	10001637          	lui	a2,0x10001
    80001388:	100015b7          	lui	a1,0x10001
    8000138c:	8526                	mv	a0,s1
    8000138e:	00000097          	auipc	ra,0x0
    80001392:	f8a080e7          	jalr	-118(ra) # 80001318 <kvmmap>
    80001396:	4719                	li	a4,6
    80001398:	004006b7          	lui	a3,0x400
    8000139c:	0c000637          	lui	a2,0xc000
    800013a0:	0c0005b7          	lui	a1,0xc000
    800013a4:	8526                	mv	a0,s1
    800013a6:	00000097          	auipc	ra,0x0
    800013aa:	f72080e7          	jalr	-142(ra) # 80001318 <kvmmap>
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
    800013d0:	4719                	li	a4,6
    800013d2:	46c5                	li	a3,17
    800013d4:	06ee                	slli	a3,a3,0x1b
    800013d6:	412686b3          	sub	a3,a3,s2
    800013da:	864a                	mv	a2,s2
    800013dc:	85ca                	mv	a1,s2
    800013de:	8526                	mv	a0,s1
    800013e0:	00000097          	auipc	ra,0x0
    800013e4:	f38080e7          	jalr	-200(ra) # 80001318 <kvmmap>
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
    80001406:	8526                	mv	a0,s1
    80001408:	00000097          	auipc	ra,0x0
    8000140c:	738080e7          	jalr	1848(ra) # 80001b40 <proc_mapstacks>
    80001410:	8526                	mv	a0,s1
    80001412:	60e2                	ld	ra,24(sp)
    80001414:	6442                	ld	s0,16(sp)
    80001416:	64a2                	ld	s1,8(sp)
    80001418:	6902                	ld	s2,0(sp)
    8000141a:	6105                	addi	sp,sp,32
    8000141c:	8082                	ret

000000008000141e <kvminit>:
    8000141e:	1141                	addi	sp,sp,-16
    80001420:	e406                	sd	ra,8(sp)
    80001422:	e022                	sd	s0,0(sp)
    80001424:	0800                	addi	s0,sp,16
    80001426:	00000097          	auipc	ra,0x0
    8000142a:	f22080e7          	jalr	-222(ra) # 80001348 <kvmmake>
    8000142e:	00007797          	auipc	a5,0x7
    80001432:	7ea7b923          	sd	a0,2034(a5) # 80008c20 <kernel_pagetable>
    80001436:	60a2                	ld	ra,8(sp)
    80001438:	6402                	ld	s0,0(sp)
    8000143a:	0141                	addi	sp,sp,16
    8000143c:	8082                	ret

000000008000143e <uvmunmap>:
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
    80001454:	03459793          	slli	a5,a1,0x34
    80001458:	e795                	bnez	a5,80001484 <uvmunmap+0x46>
    8000145a:	8a2a                	mv	s4,a0
    8000145c:	892e                	mv	s2,a1
    8000145e:	8ab6                	mv	s5,a3
    80001460:	0632                	slli	a2,a2,0xc
    80001462:	00b609b3          	add	s3,a2,a1
    80001466:	4b85                	li	s7,1
    80001468:	6b05                	lui	s6,0x1
    8000146a:	0735e863          	bltu	a1,s3,800014da <uvmunmap+0x9c>
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
    80001484:	00007517          	auipc	a0,0x7
    80001488:	cac50513          	addi	a0,a0,-852 # 80008130 <digits+0xf0>
    8000148c:	fffff097          	auipc	ra,0xfffff
    80001490:	0b8080e7          	jalr	184(ra) # 80000544 <panic>
    80001494:	00007517          	auipc	a0,0x7
    80001498:	cb450513          	addi	a0,a0,-844 # 80008148 <digits+0x108>
    8000149c:	fffff097          	auipc	ra,0xfffff
    800014a0:	0a8080e7          	jalr	168(ra) # 80000544 <panic>
    800014a4:	00007517          	auipc	a0,0x7
    800014a8:	cb450513          	addi	a0,a0,-844 # 80008158 <digits+0x118>
    800014ac:	fffff097          	auipc	ra,0xfffff
    800014b0:	098080e7          	jalr	152(ra) # 80000544 <panic>
    800014b4:	00007517          	auipc	a0,0x7
    800014b8:	cbc50513          	addi	a0,a0,-836 # 80008170 <digits+0x130>
    800014bc:	fffff097          	auipc	ra,0xfffff
    800014c0:	088080e7          	jalr	136(ra) # 80000544 <panic>
    800014c4:	8129                	srli	a0,a0,0xa
    800014c6:	0532                	slli	a0,a0,0xc
    800014c8:	fffff097          	auipc	ra,0xfffff
    800014cc:	606080e7          	jalr	1542(ra) # 80000ace <kfree>
    800014d0:	0004b023          	sd	zero,0(s1)
    800014d4:	995a                	add	s2,s2,s6
    800014d6:	f9397ce3          	bgeu	s2,s3,8000146e <uvmunmap+0x30>
    800014da:	4601                	li	a2,0
    800014dc:	85ca                	mv	a1,s2
    800014de:	8552                	mv	a0,s4
    800014e0:	00000097          	auipc	ra,0x0
    800014e4:	cb0080e7          	jalr	-848(ra) # 80001190 <walk>
    800014e8:	84aa                	mv	s1,a0
    800014ea:	d54d                	beqz	a0,80001494 <uvmunmap+0x56>
    800014ec:	6108                	ld	a0,0(a0)
    800014ee:	00157793          	andi	a5,a0,1
    800014f2:	dbcd                	beqz	a5,800014a4 <uvmunmap+0x66>
    800014f4:	3ff57793          	andi	a5,a0,1023
    800014f8:	fb778ee3          	beq	a5,s7,800014b4 <uvmunmap+0x76>
    800014fc:	fc0a8ae3          	beqz	s5,800014d0 <uvmunmap+0x92>
    80001500:	b7d1                	j	800014c4 <uvmunmap+0x86>

0000000080001502 <uvmcreate>:
    80001502:	1101                	addi	sp,sp,-32
    80001504:	ec06                	sd	ra,24(sp)
    80001506:	e822                	sd	s0,16(sp)
    80001508:	e426                	sd	s1,8(sp)
    8000150a:	1000                	addi	s0,sp,32
    8000150c:	fffff097          	auipc	ra,0xfffff
    80001510:	768080e7          	jalr	1896(ra) # 80000c74 <kalloc>
    80001514:	84aa                	mv	s1,a0
    80001516:	c519                	beqz	a0,80001524 <uvmcreate+0x22>
    80001518:	6605                	lui	a2,0x1
    8000151a:	4581                	li	a1,0
    8000151c:	00000097          	auipc	ra,0x0
    80001520:	988080e7          	jalr	-1656(ra) # 80000ea4 <memset>
    80001524:	8526                	mv	a0,s1
    80001526:	60e2                	ld	ra,24(sp)
    80001528:	6442                	ld	s0,16(sp)
    8000152a:	64a2                	ld	s1,8(sp)
    8000152c:	6105                	addi	sp,sp,32
    8000152e:	8082                	ret

0000000080001530 <uvmfirst>:
    80001530:	7179                	addi	sp,sp,-48
    80001532:	f406                	sd	ra,40(sp)
    80001534:	f022                	sd	s0,32(sp)
    80001536:	ec26                	sd	s1,24(sp)
    80001538:	e84a                	sd	s2,16(sp)
    8000153a:	e44e                	sd	s3,8(sp)
    8000153c:	e052                	sd	s4,0(sp)
    8000153e:	1800                	addi	s0,sp,48
    80001540:	6785                	lui	a5,0x1
    80001542:	04f67863          	bgeu	a2,a5,80001592 <uvmfirst+0x62>
    80001546:	8a2a                	mv	s4,a0
    80001548:	89ae                	mv	s3,a1
    8000154a:	84b2                	mv	s1,a2
    8000154c:	fffff097          	auipc	ra,0xfffff
    80001550:	728080e7          	jalr	1832(ra) # 80000c74 <kalloc>
    80001554:	892a                	mv	s2,a0
    80001556:	6605                	lui	a2,0x1
    80001558:	4581                	li	a1,0
    8000155a:	00000097          	auipc	ra,0x0
    8000155e:	94a080e7          	jalr	-1718(ra) # 80000ea4 <memset>
    80001562:	4779                	li	a4,30
    80001564:	86ca                	mv	a3,s2
    80001566:	6605                	lui	a2,0x1
    80001568:	4581                	li	a1,0
    8000156a:	8552                	mv	a0,s4
    8000156c:	00000097          	auipc	ra,0x0
    80001570:	d0c080e7          	jalr	-756(ra) # 80001278 <mappages>
    80001574:	8626                	mv	a2,s1
    80001576:	85ce                	mv	a1,s3
    80001578:	854a                	mv	a0,s2
    8000157a:	00000097          	auipc	ra,0x0
    8000157e:	98a080e7          	jalr	-1654(ra) # 80000f04 <memmove>
    80001582:	70a2                	ld	ra,40(sp)
    80001584:	7402                	ld	s0,32(sp)
    80001586:	64e2                	ld	s1,24(sp)
    80001588:	6942                	ld	s2,16(sp)
    8000158a:	69a2                	ld	s3,8(sp)
    8000158c:	6a02                	ld	s4,0(sp)
    8000158e:	6145                	addi	sp,sp,48
    80001590:	8082                	ret
    80001592:	00007517          	auipc	a0,0x7
    80001596:	bf650513          	addi	a0,a0,-1034 # 80008188 <digits+0x148>
    8000159a:	fffff097          	auipc	ra,0xfffff
    8000159e:	faa080e7          	jalr	-86(ra) # 80000544 <panic>

00000000800015a2 <uvmdealloc>:
    800015a2:	1101                	addi	sp,sp,-32
    800015a4:	ec06                	sd	ra,24(sp)
    800015a6:	e822                	sd	s0,16(sp)
    800015a8:	e426                	sd	s1,8(sp)
    800015aa:	1000                	addi	s0,sp,32
    800015ac:	84ae                	mv	s1,a1
    800015ae:	00b67d63          	bgeu	a2,a1,800015c8 <uvmdealloc+0x26>
    800015b2:	84b2                	mv	s1,a2
    800015b4:	6785                	lui	a5,0x1
    800015b6:	17fd                	addi	a5,a5,-1
    800015b8:	00f60733          	add	a4,a2,a5
    800015bc:	767d                	lui	a2,0xfffff
    800015be:	8f71                	and	a4,a4,a2
    800015c0:	97ae                	add	a5,a5,a1
    800015c2:	8ff1                	and	a5,a5,a2
    800015c4:	00f76863          	bltu	a4,a5,800015d4 <uvmdealloc+0x32>
    800015c8:	8526                	mv	a0,s1
    800015ca:	60e2                	ld	ra,24(sp)
    800015cc:	6442                	ld	s0,16(sp)
    800015ce:	64a2                	ld	s1,8(sp)
    800015d0:	6105                	addi	sp,sp,32
    800015d2:	8082                	ret
    800015d4:	8f99                	sub	a5,a5,a4
    800015d6:	83b1                	srli	a5,a5,0xc
    800015d8:	4685                	li	a3,1
    800015da:	0007861b          	sext.w	a2,a5
    800015de:	85ba                	mv	a1,a4
    800015e0:	00000097          	auipc	ra,0x0
    800015e4:	e5e080e7          	jalr	-418(ra) # 8000143e <uvmunmap>
    800015e8:	b7c5                	j	800015c8 <uvmdealloc+0x26>

00000000800015ea <uvmalloc>:
    800015ea:	0ab66563          	bltu	a2,a1,80001694 <uvmalloc+0xaa>
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
    80001606:	6985                	lui	s3,0x1
    80001608:	19fd                	addi	s3,s3,-1
    8000160a:	95ce                	add	a1,a1,s3
    8000160c:	79fd                	lui	s3,0xfffff
    8000160e:	0135f9b3          	and	s3,a1,s3
    80001612:	08c9f363          	bgeu	s3,a2,80001698 <uvmalloc+0xae>
    80001616:	894e                	mv	s2,s3
    80001618:	0126eb13          	ori	s6,a3,18
    8000161c:	fffff097          	auipc	ra,0xfffff
    80001620:	658080e7          	jalr	1624(ra) # 80000c74 <kalloc>
    80001624:	84aa                	mv	s1,a0
    80001626:	c51d                	beqz	a0,80001654 <uvmalloc+0x6a>
    80001628:	6605                	lui	a2,0x1
    8000162a:	4581                	li	a1,0
    8000162c:	00000097          	auipc	ra,0x0
    80001630:	878080e7          	jalr	-1928(ra) # 80000ea4 <memset>
    80001634:	875a                	mv	a4,s6
    80001636:	86a6                	mv	a3,s1
    80001638:	6605                	lui	a2,0x1
    8000163a:	85ca                	mv	a1,s2
    8000163c:	8556                	mv	a0,s5
    8000163e:	00000097          	auipc	ra,0x0
    80001642:	c3a080e7          	jalr	-966(ra) # 80001278 <mappages>
    80001646:	e90d                	bnez	a0,80001678 <uvmalloc+0x8e>
    80001648:	6785                	lui	a5,0x1
    8000164a:	993e                	add	s2,s2,a5
    8000164c:	fd4968e3          	bltu	s2,s4,8000161c <uvmalloc+0x32>
    80001650:	8552                	mv	a0,s4
    80001652:	a809                	j	80001664 <uvmalloc+0x7a>
    80001654:	864e                	mv	a2,s3
    80001656:	85ca                	mv	a1,s2
    80001658:	8556                	mv	a0,s5
    8000165a:	00000097          	auipc	ra,0x0
    8000165e:	f48080e7          	jalr	-184(ra) # 800015a2 <uvmdealloc>
    80001662:	4501                	li	a0,0
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
    80001678:	8526                	mv	a0,s1
    8000167a:	fffff097          	auipc	ra,0xfffff
    8000167e:	454080e7          	jalr	1108(ra) # 80000ace <kfree>
    80001682:	864e                	mv	a2,s3
    80001684:	85ca                	mv	a1,s2
    80001686:	8556                	mv	a0,s5
    80001688:	00000097          	auipc	ra,0x0
    8000168c:	f1a080e7          	jalr	-230(ra) # 800015a2 <uvmdealloc>
    80001690:	4501                	li	a0,0
    80001692:	bfc9                	j	80001664 <uvmalloc+0x7a>
    80001694:	852e                	mv	a0,a1
    80001696:	8082                	ret
    80001698:	8532                	mv	a0,a2
    8000169a:	b7e9                	j	80001664 <uvmalloc+0x7a>

000000008000169c <freewalk>:
    8000169c:	7179                	addi	sp,sp,-48
    8000169e:	f406                	sd	ra,40(sp)
    800016a0:	f022                	sd	s0,32(sp)
    800016a2:	ec26                	sd	s1,24(sp)
    800016a4:	e84a                	sd	s2,16(sp)
    800016a6:	e44e                	sd	s3,8(sp)
    800016a8:	e052                	sd	s4,0(sp)
    800016aa:	1800                	addi	s0,sp,48
    800016ac:	8a2a                	mv	s4,a0
    800016ae:	84aa                	mv	s1,a0
    800016b0:	6905                	lui	s2,0x1
    800016b2:	992a                	add	s2,s2,a0
    800016b4:	4985                	li	s3,1
    800016b6:	a821                	j	800016ce <freewalk+0x32>
    800016b8:	8129                	srli	a0,a0,0xa
    800016ba:	0532                	slli	a0,a0,0xc
    800016bc:	00000097          	auipc	ra,0x0
    800016c0:	fe0080e7          	jalr	-32(ra) # 8000169c <freewalk>
    800016c4:	0004b023          	sd	zero,0(s1)
    800016c8:	04a1                	addi	s1,s1,8
    800016ca:	03248163          	beq	s1,s2,800016ec <freewalk+0x50>
    800016ce:	6088                	ld	a0,0(s1)
    800016d0:	00f57793          	andi	a5,a0,15
    800016d4:	ff3782e3          	beq	a5,s3,800016b8 <freewalk+0x1c>
    800016d8:	8905                	andi	a0,a0,1
    800016da:	d57d                	beqz	a0,800016c8 <freewalk+0x2c>
    800016dc:	00007517          	auipc	a0,0x7
    800016e0:	acc50513          	addi	a0,a0,-1332 # 800081a8 <digits+0x168>
    800016e4:	fffff097          	auipc	ra,0xfffff
    800016e8:	e60080e7          	jalr	-416(ra) # 80000544 <panic>
    800016ec:	8552                	mv	a0,s4
    800016ee:	fffff097          	auipc	ra,0xfffff
    800016f2:	3e0080e7          	jalr	992(ra) # 80000ace <kfree>
    800016f6:	70a2                	ld	ra,40(sp)
    800016f8:	7402                	ld	s0,32(sp)
    800016fa:	64e2                	ld	s1,24(sp)
    800016fc:	6942                	ld	s2,16(sp)
    800016fe:	69a2                	ld	s3,8(sp)
    80001700:	6a02                	ld	s4,0(sp)
    80001702:	6145                	addi	sp,sp,48
    80001704:	8082                	ret

0000000080001706 <uvmfree>:
    80001706:	1101                	addi	sp,sp,-32
    80001708:	ec06                	sd	ra,24(sp)
    8000170a:	e822                	sd	s0,16(sp)
    8000170c:	e426                	sd	s1,8(sp)
    8000170e:	1000                	addi	s0,sp,32
    80001710:	84aa                	mv	s1,a0
    80001712:	e999                	bnez	a1,80001728 <uvmfree+0x22>
    80001714:	8526                	mv	a0,s1
    80001716:	00000097          	auipc	ra,0x0
    8000171a:	f86080e7          	jalr	-122(ra) # 8000169c <freewalk>
    8000171e:	60e2                	ld	ra,24(sp)
    80001720:	6442                	ld	s0,16(sp)
    80001722:	64a2                	ld	s1,8(sp)
    80001724:	6105                	addi	sp,sp,32
    80001726:	8082                	ret
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
    8000173e:	c271                	beqz	a2,80001802 <uvmcopy+0xc4>
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
    8000175a:	4901                	li	s2,0
    8000175c:	a0a9                	j	800017a6 <uvmcopy+0x68>
    8000175e:	00007517          	auipc	a0,0x7
    80001762:	a5a50513          	addi	a0,a0,-1446 # 800081b8 <digits+0x178>
    80001766:	fffff097          	auipc	ra,0xfffff
    8000176a:	dde080e7          	jalr	-546(ra) # 80000544 <panic>
    8000176e:	00007517          	auipc	a0,0x7
    80001772:	a6a50513          	addi	a0,a0,-1430 # 800081d8 <digits+0x198>
    80001776:	fffff097          	auipc	ra,0xfffff
    8000177a:	dce080e7          	jalr	-562(ra) # 80000544 <panic>
    8000177e:	854e                	mv	a0,s3
    80001780:	fffff097          	auipc	ra,0xfffff
    80001784:	27e080e7          	jalr	638(ra) # 800009fe <krefincr>
    80001788:	1004e713          	ori	a4,s1,256
    8000178c:	86ce                	mv	a3,s3
    8000178e:	6605                	lui	a2,0x1
    80001790:	85ca                	mv	a1,s2
    80001792:	8556                	mv	a0,s5
    80001794:	00000097          	auipc	ra,0x0
    80001798:	ae4080e7          	jalr	-1308(ra) # 80001278 <mappages>
    8000179c:	ed1d                	bnez	a0,800017da <uvmcopy+0x9c>
    8000179e:	6785                	lui	a5,0x1
    800017a0:	993e                	add	s2,s2,a5
    800017a2:	05497663          	bgeu	s2,s4,800017ee <uvmcopy+0xb0>
    800017a6:	4601                	li	a2,0
    800017a8:	85ca                	mv	a1,s2
    800017aa:	855a                	mv	a0,s6
    800017ac:	00000097          	auipc	ra,0x0
    800017b0:	9e4080e7          	jalr	-1564(ra) # 80001190 <walk>
    800017b4:	d54d                	beqz	a0,8000175e <uvmcopy+0x20>
    800017b6:	611c                	ld	a5,0(a0)
    800017b8:	0017f713          	andi	a4,a5,1
    800017bc:	db4d                	beqz	a4,8000176e <uvmcopy+0x30>
    800017be:	00a7d993          	srli	s3,a5,0xa
    800017c2:	09b2                	slli	s3,s3,0xc
    800017c4:	2781                	sext.w	a5,a5
    800017c6:	0047f713          	andi	a4,a5,4
    800017ca:	3ff7f493          	andi	s1,a5,1023
    800017ce:	db45                	beqz	a4,8000177e <uvmcopy+0x40>
    800017d0:	3fb7f793          	andi	a5,a5,1019
    800017d4:	1007e493          	ori	s1,a5,256
    800017d8:	b75d                	j	8000177e <uvmcopy+0x40>
    800017da:	4685                	li	a3,1
    800017dc:	00c95613          	srli	a2,s2,0xc
    800017e0:	4581                	li	a1,0
    800017e2:	8556                	mv	a0,s5
    800017e4:	00000097          	auipc	ra,0x0
    800017e8:	c5a080e7          	jalr	-934(ra) # 8000143e <uvmunmap>
    800017ec:	557d                	li	a0,-1
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
    80001802:	4501                	li	a0,0
    80001804:	8082                	ret

0000000080001806 <uvmclear>:
    80001806:	1141                	addi	sp,sp,-16
    80001808:	e406                	sd	ra,8(sp)
    8000180a:	e022                	sd	s0,0(sp)
    8000180c:	0800                	addi	s0,sp,16
    8000180e:	4601                	li	a2,0
    80001810:	00000097          	auipc	ra,0x0
    80001814:	980080e7          	jalr	-1664(ra) # 80001190 <walk>
    80001818:	c901                	beqz	a0,80001828 <uvmclear+0x22>
    8000181a:	611c                	ld	a5,0(a0)
    8000181c:	9bbd                	andi	a5,a5,-17
    8000181e:	e11c                	sd	a5,0(a0)
    80001820:	60a2                	ld	ra,8(sp)
    80001822:	6402                	ld	s0,0(sp)
    80001824:	0141                	addi	sp,sp,16
    80001826:	8082                	ret
    80001828:	00007517          	auipc	a0,0x7
    8000182c:	9d050513          	addi	a0,a0,-1584 # 800081f8 <digits+0x1b8>
    80001830:	fffff097          	auipc	ra,0xfffff
    80001834:	d14080e7          	jalr	-748(ra) # 80000544 <panic>

0000000080001838 <copyout>:
    80001838:	cad1                	beqz	a3,800018cc <copyout+0x94>
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
    8000185c:	74fd                	lui	s1,0xfffff
    8000185e:	8ced                	and	s1,s1,a1
    80001860:	4785                	li	a5,1
    80001862:	179a                	slli	a5,a5,0x26
    80001864:	0697e663          	bltu	a5,s1,800018d0 <copyout+0x98>
    80001868:	6c85                	lui	s9,0x1
    8000186a:	04000c37          	lui	s8,0x4000
    8000186e:	0c05                	addi	s8,s8,1
    80001870:	0c32                	slli	s8,s8,0xc
    80001872:	a025                	j	8000189a <copyout+0x62>
    80001874:	409a84b3          	sub	s1,s5,s1
    80001878:	0009061b          	sext.w	a2,s2
    8000187c:	85da                	mv	a1,s6
    8000187e:	9526                	add	a0,a0,s1
    80001880:	fffff097          	auipc	ra,0xfffff
    80001884:	684080e7          	jalr	1668(ra) # 80000f04 <memmove>
    80001888:	412989b3          	sub	s3,s3,s2
    8000188c:	9b4a                	add	s6,s6,s2
    8000188e:	02098d63          	beqz	s3,800018c8 <copyout+0x90>
    80001892:	058a0163          	beq	s4,s8,800018d4 <copyout+0x9c>
    80001896:	84d2                	mv	s1,s4
    80001898:	8ad2                	mv	s5,s4
    8000189a:	85a6                	mv	a1,s1
    8000189c:	855e                	mv	a0,s7
    8000189e:	00001097          	auipc	ra,0x1
    800018a2:	36c080e7          	jalr	876(ra) # 80002c0a <cowalloc>
    800018a6:	02054963          	bltz	a0,800018d8 <copyout+0xa0>
    800018aa:	85a6                	mv	a1,s1
    800018ac:	855e                	mv	a0,s7
    800018ae:	00000097          	auipc	ra,0x0
    800018b2:	988080e7          	jalr	-1656(ra) # 80001236 <walkaddr>
    800018b6:	cd1d                	beqz	a0,800018f4 <copyout+0xbc>
    800018b8:	01948a33          	add	s4,s1,s9
    800018bc:	415a0933          	sub	s2,s4,s5
    800018c0:	fb29fae3          	bgeu	s3,s2,80001874 <copyout+0x3c>
    800018c4:	894e                	mv	s2,s3
    800018c6:	b77d                	j	80001874 <copyout+0x3c>
    800018c8:	4501                	li	a0,0
    800018ca:	a801                	j	800018da <copyout+0xa2>
    800018cc:	4501                	li	a0,0
    800018ce:	8082                	ret
    800018d0:	557d                	li	a0,-1
    800018d2:	a021                	j	800018da <copyout+0xa2>
    800018d4:	557d                	li	a0,-1
    800018d6:	a011                	j	800018da <copyout+0xa2>
    800018d8:	557d                	li	a0,-1
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
    800018f4:	557d                	li	a0,-1
    800018f6:	b7d5                	j	800018da <copyout+0xa2>

00000000800018f8 <copyin>:
    800018f8:	c6bd                	beqz	a3,80001966 <copyin+0x6e>
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
    8000191a:	7bfd                	lui	s7,0xfffff
    8000191c:	6a85                	lui	s5,0x1
    8000191e:	a015                	j	80001942 <copyin+0x4a>
    80001920:	9562                	add	a0,a0,s8
    80001922:	0004861b          	sext.w	a2,s1
    80001926:	412505b3          	sub	a1,a0,s2
    8000192a:	8552                	mv	a0,s4
    8000192c:	fffff097          	auipc	ra,0xfffff
    80001930:	5d8080e7          	jalr	1496(ra) # 80000f04 <memmove>
    80001934:	409989b3          	sub	s3,s3,s1
    80001938:	9a26                	add	s4,s4,s1
    8000193a:	01590c33          	add	s8,s2,s5
    8000193e:	02098263          	beqz	s3,80001962 <copyin+0x6a>
    80001942:	017c7933          	and	s2,s8,s7
    80001946:	85ca                	mv	a1,s2
    80001948:	855a                	mv	a0,s6
    8000194a:	00000097          	auipc	ra,0x0
    8000194e:	8ec080e7          	jalr	-1812(ra) # 80001236 <walkaddr>
    80001952:	cd01                	beqz	a0,8000196a <copyin+0x72>
    80001954:	418904b3          	sub	s1,s2,s8
    80001958:	94d6                	add	s1,s1,s5
    8000195a:	fc99f3e3          	bgeu	s3,s1,80001920 <copyin+0x28>
    8000195e:	84ce                	mv	s1,s3
    80001960:	b7c1                	j	80001920 <copyin+0x28>
    80001962:	4501                	li	a0,0
    80001964:	a021                	j	8000196c <copyin+0x74>
    80001966:	4501                	li	a0,0
    80001968:	8082                	ret
    8000196a:	557d                	li	a0,-1
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
    80001984:	c6c5                	beqz	a3,80001a2c <copyinstr+0xa8>
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
    800019a4:	7afd                	lui	s5,0xfffff
    800019a6:	6985                	lui	s3,0x1
    800019a8:	a035                	j	800019d4 <copyinstr+0x50>
    800019aa:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800019ae:	4785                	li	a5,1
    800019b0:	0017b793          	seqz	a5,a5
    800019b4:	40f00533          	neg	a0,a5
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
    800019ce:	01390bb3          	add	s7,s2,s3
    800019d2:	c8a9                	beqz	s1,80001a24 <copyinstr+0xa0>
    800019d4:	015bf933          	and	s2,s7,s5
    800019d8:	85ca                	mv	a1,s2
    800019da:	8552                	mv	a0,s4
    800019dc:	00000097          	auipc	ra,0x0
    800019e0:	85a080e7          	jalr	-1958(ra) # 80001236 <walkaddr>
    800019e4:	c131                	beqz	a0,80001a28 <copyinstr+0xa4>
    800019e6:	41790833          	sub	a6,s2,s7
    800019ea:	984e                	add	a6,a6,s3
    800019ec:	0104f363          	bgeu	s1,a6,800019f2 <copyinstr+0x6e>
    800019f0:	8826                	mv	a6,s1
    800019f2:	955e                	add	a0,a0,s7
    800019f4:	41250533          	sub	a0,a0,s2
    800019f8:	fc080be3          	beqz	a6,800019ce <copyinstr+0x4a>
    800019fc:	985a                	add	a6,a6,s6
    800019fe:	87da                	mv	a5,s6
    80001a00:	41650633          	sub	a2,a0,s6
    80001a04:	14fd                	addi	s1,s1,-1
    80001a06:	9b26                	add	s6,s6,s1
    80001a08:	00f60733          	add	a4,a2,a5
    80001a0c:	00074703          	lbu	a4,0(a4)
    80001a10:	df49                	beqz	a4,800019aa <copyinstr+0x26>
    80001a12:	00e78023          	sb	a4,0(a5)
    80001a16:	40fb04b3          	sub	s1,s6,a5
    80001a1a:	0785                	addi	a5,a5,1
    80001a1c:	ff0796e3          	bne	a5,a6,80001a08 <copyinstr+0x84>
    80001a20:	8b42                	mv	s6,a6
    80001a22:	b775                	j	800019ce <copyinstr+0x4a>
    80001a24:	4781                	li	a5,0
    80001a26:	b769                	j	800019b0 <copyinstr+0x2c>
    80001a28:	557d                	li	a0,-1
    80001a2a:	b779                	j	800019b8 <copyinstr+0x34>
    80001a2c:	4781                	li	a5,0
    80001a2e:	0017b793          	seqz	a5,a5
    80001a32:	40f00533          	neg	a0,a5
    80001a36:	8082                	ret

0000000080001a38 <calculateDynamicPriority>:
    80001a38:	1141                	addi	sp,sp,-16
    80001a3a:	e422                	sd	s0,8(sp)
    80001a3c:	0800                	addi	s0,sp,16
    80001a3e:	4795                	li	a5,5
    80001a40:	1cf52023          	sw	a5,448(a0)
    80001a44:	1b052783          	lw	a5,432(a0)
    80001a48:	e791                	bnez	a5,80001a54 <calculateDynamicPriority+0x1c>
    80001a4a:	1a852783          	lw	a5,424(a0)
    80001a4e:	e399                	bnez	a5,80001a54 <calculateDynamicPriority+0x1c>
    80001a50:	1c052023          	sw	zero,448(a0)
    80001a54:	1b852783          	lw	a5,440(a0)
    80001a58:	2795                	addiw	a5,a5,5
    80001a5a:	1c052503          	lw	a0,448(a0)
    80001a5e:	40a7853b          	subw	a0,a5,a0
    80001a62:	0005079b          	sext.w	a5,a0
    80001a66:	fff7c793          	not	a5,a5
    80001a6a:	97fd                	srai	a5,a5,0x3f
    80001a6c:	8d7d                	and	a0,a0,a5
    80001a6e:	0005071b          	sext.w	a4,a0
    80001a72:	06400793          	li	a5,100
    80001a76:	00e7d463          	bge	a5,a4,80001a7e <calculateDynamicPriority+0x46>
    80001a7a:	06400513          	li	a0,100
    80001a7e:	2501                	sext.w	a0,a0
    80001a80:	6422                	ld	s0,8(sp)
    80001a82:	0141                	addi	sp,sp,16
    80001a84:	8082                	ret

0000000080001a86 <set_priority>:
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
    80001a9a:	8aaa                	mv	s5,a0
    80001a9c:	06400793          	li	a5,100
    80001aa0:	00670497          	auipc	s1,0x670
    80001aa4:	84848493          	addi	s1,s1,-1976 # 806712e8 <proc>
    80001aa8:	00677a17          	auipc	s4,0x677
    80001aac:	440a0a13          	addi	s4,s4,1088 # 80678ee8 <tickslock>
    80001ab0:	02a7e763          	bltu	a5,a0,80001ade <set_priority+0x58>
    80001ab4:	00848913          	addi	s2,s1,8
    80001ab8:	854a                	mv	a0,s2
    80001aba:	fffff097          	auipc	ra,0xfffff
    80001abe:	2ee080e7          	jalr	750(ra) # 80000da8 <acquire>
    80001ac2:	5c9c                	lw	a5,56(s1)
    80001ac4:	03378763          	beq	a5,s3,80001af2 <set_priority+0x6c>
    80001ac8:	854a                	mv	a0,s2
    80001aca:	fffff097          	auipc	ra,0xfffff
    80001ace:	392080e7          	jalr	914(ra) # 80000e5c <release>
    80001ad2:	1f048493          	addi	s1,s1,496
    80001ad6:	fd449fe3          	bne	s1,s4,80001ab4 <set_priority+0x2e>
    80001ada:	59fd                	li	s3,-1
    80001adc:	a881                	j	80001b2c <set_priority+0xa6>
    80001ade:	00006517          	auipc	a0,0x6
    80001ae2:	72a50513          	addi	a0,a0,1834 # 80008208 <digits+0x1c8>
    80001ae6:	fffff097          	auipc	ra,0xfffff
    80001aea:	aa8080e7          	jalr	-1368(ra) # 8000058e <printf>
    80001aee:	59fd                	li	s3,-1
    80001af0:	a835                	j	80001b2c <set_priority+0xa6>
    80001af2:	854a                	mv	a0,s2
    80001af4:	fffff097          	auipc	ra,0xfffff
    80001af8:	368080e7          	jalr	872(ra) # 80000e5c <release>
    80001afc:	854a                	mv	a0,s2
    80001afe:	fffff097          	auipc	ra,0xfffff
    80001b02:	2aa080e7          	jalr	682(ra) # 80000da8 <acquire>
    80001b06:	1b84a983          	lw	s3,440(s1)
    80001b0a:	1b54ac23          	sw	s5,440(s1)
    80001b0e:	4795                	li	a5,5
    80001b10:	1cf4a023          	sw	a5,448(s1)
    80001b14:	8526                	mv	a0,s1
    80001b16:	00000097          	auipc	ra,0x0
    80001b1a:	f22080e7          	jalr	-222(ra) # 80001a38 <calculateDynamicPriority>
    80001b1e:	1aa4ae23          	sw	a0,444(s1)
    80001b22:	854a                	mv	a0,s2
    80001b24:	fffff097          	auipc	ra,0xfffff
    80001b28:	338080e7          	jalr	824(ra) # 80000e5c <release>
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
    80001b56:	0066f497          	auipc	s1,0x66f
    80001b5a:	79248493          	addi	s1,s1,1938 # 806712e8 <proc>
    80001b5e:	8b26                	mv	s6,s1
    80001b60:	00006a97          	auipc	s5,0x6
    80001b64:	4a0a8a93          	addi	s5,s5,1184 # 80008000 <etext>
    80001b68:	04000937          	lui	s2,0x4000
    80001b6c:	197d                	addi	s2,s2,-1
    80001b6e:	0932                	slli	s2,s2,0xc
    80001b70:	00677a17          	auipc	s4,0x677
    80001b74:	378a0a13          	addi	s4,s4,888 # 80678ee8 <tickslock>
    80001b78:	fffff097          	auipc	ra,0xfffff
    80001b7c:	0fc080e7          	jalr	252(ra) # 80000c74 <kalloc>
    80001b80:	862a                	mv	a2,a0
    80001b82:	c131                	beqz	a0,80001bc6 <proc_mapstacks+0x86>
    80001b84:	416485b3          	sub	a1,s1,s6
    80001b88:	8591                	srai	a1,a1,0x4
    80001b8a:	000ab783          	ld	a5,0(s5)
    80001b8e:	02f585b3          	mul	a1,a1,a5
    80001b92:	2585                	addiw	a1,a1,1
    80001b94:	00d5959b          	slliw	a1,a1,0xd
    80001b98:	4719                	li	a4,6
    80001b9a:	6685                	lui	a3,0x1
    80001b9c:	40b905b3          	sub	a1,s2,a1
    80001ba0:	854e                	mv	a0,s3
    80001ba2:	fffff097          	auipc	ra,0xfffff
    80001ba6:	776080e7          	jalr	1910(ra) # 80001318 <kvmmap>
    80001baa:	1f048493          	addi	s1,s1,496
    80001bae:	fd4495e3          	bne	s1,s4,80001b78 <proc_mapstacks+0x38>
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
    80001bc6:	00006517          	auipc	a0,0x6
    80001bca:	65a50513          	addi	a0,a0,1626 # 80008220 <digits+0x1e0>
    80001bce:	fffff097          	auipc	ra,0xfffff
    80001bd2:	976080e7          	jalr	-1674(ra) # 80000544 <panic>

0000000080001bd6 <procinit>:
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
    80001bea:	00006597          	auipc	a1,0x6
    80001bee:	63e58593          	addi	a1,a1,1598 # 80008228 <digits+0x1e8>
    80001bf2:	0066f517          	auipc	a0,0x66f
    80001bf6:	2c650513          	addi	a0,a0,710 # 80670eb8 <pid_lock>
    80001bfa:	fffff097          	auipc	ra,0xfffff
    80001bfe:	11e080e7          	jalr	286(ra) # 80000d18 <initlock>
    80001c02:	00006597          	auipc	a1,0x6
    80001c06:	62e58593          	addi	a1,a1,1582 # 80008230 <digits+0x1f0>
    80001c0a:	0066f517          	auipc	a0,0x66f
    80001c0e:	2c650513          	addi	a0,a0,710 # 80670ed0 <wait_lock>
    80001c12:	fffff097          	auipc	ra,0xfffff
    80001c16:	106080e7          	jalr	262(ra) # 80000d18 <initlock>
    80001c1a:	0066f497          	auipc	s1,0x66f
    80001c1e:	6ce48493          	addi	s1,s1,1742 # 806712e8 <proc>
    80001c22:	00006b17          	auipc	s6,0x6
    80001c26:	61eb0b13          	addi	s6,s6,1566 # 80008240 <digits+0x200>
    80001c2a:	8aa6                	mv	s5,s1
    80001c2c:	00006a17          	auipc	s4,0x6
    80001c30:	3d4a0a13          	addi	s4,s4,980 # 80008000 <etext>
    80001c34:	04000937          	lui	s2,0x4000
    80001c38:	197d                	addi	s2,s2,-1
    80001c3a:	0932                	slli	s2,s2,0xc
    80001c3c:	00677997          	auipc	s3,0x677
    80001c40:	2ac98993          	addi	s3,s3,684 # 80678ee8 <tickslock>
    80001c44:	85da                	mv	a1,s6
    80001c46:	00848513          	addi	a0,s1,8
    80001c4a:	fffff097          	auipc	ra,0xfffff
    80001c4e:	0ce080e7          	jalr	206(ra) # 80000d18 <initlock>
    80001c52:	0204a023          	sw	zero,32(s1)
    80001c56:	415487b3          	sub	a5,s1,s5
    80001c5a:	8791                	srai	a5,a5,0x4
    80001c5c:	000a3703          	ld	a4,0(s4)
    80001c60:	02e787b3          	mul	a5,a5,a4
    80001c64:	2785                	addiw	a5,a5,1
    80001c66:	00d7979b          	slliw	a5,a5,0xd
    80001c6a:	40f907b3          	sub	a5,s2,a5
    80001c6e:	e4bc                	sd	a5,72(s1)
    80001c70:	1f048493          	addi	s1,s1,496
    80001c74:	fd3498e3          	bne	s1,s3,80001c44 <procinit+0x6e>
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
    80001c8c:	1141                	addi	sp,sp,-16
    80001c8e:	e422                	sd	s0,8(sp)
    80001c90:	0800                	addi	s0,sp,16
    80001c92:	8512                	mv	a0,tp
    80001c94:	2501                	sext.w	a0,a0
    80001c96:	6422                	ld	s0,8(sp)
    80001c98:	0141                	addi	sp,sp,16
    80001c9a:	8082                	ret

0000000080001c9c <mycpu>:
    80001c9c:	1141                	addi	sp,sp,-16
    80001c9e:	e422                	sd	s0,8(sp)
    80001ca0:	0800                	addi	s0,sp,16
    80001ca2:	8792                	mv	a5,tp
    80001ca4:	2781                	sext.w	a5,a5
    80001ca6:	079e                	slli	a5,a5,0x7
    80001ca8:	0066f517          	auipc	a0,0x66f
    80001cac:	24050513          	addi	a0,a0,576 # 80670ee8 <cpus>
    80001cb0:	953e                	add	a0,a0,a5
    80001cb2:	6422                	ld	s0,8(sp)
    80001cb4:	0141                	addi	sp,sp,16
    80001cb6:	8082                	ret

0000000080001cb8 <myproc>:
    80001cb8:	1101                	addi	sp,sp,-32
    80001cba:	ec06                	sd	ra,24(sp)
    80001cbc:	e822                	sd	s0,16(sp)
    80001cbe:	e426                	sd	s1,8(sp)
    80001cc0:	1000                	addi	s0,sp,32
    80001cc2:	fffff097          	auipc	ra,0xfffff
    80001cc6:	09a080e7          	jalr	154(ra) # 80000d5c <push_off>
    80001cca:	8792                	mv	a5,tp
    80001ccc:	2781                	sext.w	a5,a5
    80001cce:	079e                	slli	a5,a5,0x7
    80001cd0:	0066f717          	auipc	a4,0x66f
    80001cd4:	1e870713          	addi	a4,a4,488 # 80670eb8 <pid_lock>
    80001cd8:	97ba                	add	a5,a5,a4
    80001cda:	7b84                	ld	s1,48(a5)
    80001cdc:	fffff097          	auipc	ra,0xfffff
    80001ce0:	120080e7          	jalr	288(ra) # 80000dfc <pop_off>
    80001ce4:	8526                	mv	a0,s1
    80001ce6:	60e2                	ld	ra,24(sp)
    80001ce8:	6442                	ld	s0,16(sp)
    80001cea:	64a2                	ld	s1,8(sp)
    80001cec:	6105                	addi	sp,sp,32
    80001cee:	8082                	ret

0000000080001cf0 <forkret>:
    80001cf0:	1141                	addi	sp,sp,-16
    80001cf2:	e406                	sd	ra,8(sp)
    80001cf4:	e022                	sd	s0,0(sp)
    80001cf6:	0800                	addi	s0,sp,16
    80001cf8:	00000097          	auipc	ra,0x0
    80001cfc:	fc0080e7          	jalr	-64(ra) # 80001cb8 <myproc>
    80001d00:	0521                	addi	a0,a0,8
    80001d02:	fffff097          	auipc	ra,0xfffff
    80001d06:	15a080e7          	jalr	346(ra) # 80000e5c <release>
    80001d0a:	00007797          	auipc	a5,0x7
    80001d0e:	cc67a783          	lw	a5,-826(a5) # 800089d0 <first.2468>
    80001d12:	eb89                	bnez	a5,80001d24 <forkret+0x34>
    80001d14:	00001097          	auipc	ra,0x1
    80001d18:	f94080e7          	jalr	-108(ra) # 80002ca8 <usertrapret>
    80001d1c:	60a2                	ld	ra,8(sp)
    80001d1e:	6402                	ld	s0,0(sp)
    80001d20:	0141                	addi	sp,sp,16
    80001d22:	8082                	ret
    80001d24:	00007797          	auipc	a5,0x7
    80001d28:	ca07a623          	sw	zero,-852(a5) # 800089d0 <first.2468>
    80001d2c:	4505                	li	a0,1
    80001d2e:	00002097          	auipc	ra,0x2
    80001d32:	09c080e7          	jalr	156(ra) # 80003dca <fsinit>
    80001d36:	bff9                	j	80001d14 <forkret+0x24>

0000000080001d38 <allocpid>:
    80001d38:	1101                	addi	sp,sp,-32
    80001d3a:	ec06                	sd	ra,24(sp)
    80001d3c:	e822                	sd	s0,16(sp)
    80001d3e:	e426                	sd	s1,8(sp)
    80001d40:	e04a                	sd	s2,0(sp)
    80001d42:	1000                	addi	s0,sp,32
    80001d44:	0066f917          	auipc	s2,0x66f
    80001d48:	17490913          	addi	s2,s2,372 # 80670eb8 <pid_lock>
    80001d4c:	854a                	mv	a0,s2
    80001d4e:	fffff097          	auipc	ra,0xfffff
    80001d52:	05a080e7          	jalr	90(ra) # 80000da8 <acquire>
    80001d56:	00007797          	auipc	a5,0x7
    80001d5a:	c7e78793          	addi	a5,a5,-898 # 800089d4 <nextpid>
    80001d5e:	4384                	lw	s1,0(a5)
    80001d60:	0014871b          	addiw	a4,s1,1
    80001d64:	c398                	sw	a4,0(a5)
    80001d66:	854a                	mv	a0,s2
    80001d68:	fffff097          	auipc	ra,0xfffff
    80001d6c:	0f4080e7          	jalr	244(ra) # 80000e5c <release>
    80001d70:	8526                	mv	a0,s1
    80001d72:	60e2                	ld	ra,24(sp)
    80001d74:	6442                	ld	s0,16(sp)
    80001d76:	64a2                	ld	s1,8(sp)
    80001d78:	6902                	ld	s2,0(sp)
    80001d7a:	6105                	addi	sp,sp,32
    80001d7c:	8082                	ret

0000000080001d7e <proc_pagetable>:
    80001d7e:	1101                	addi	sp,sp,-32
    80001d80:	ec06                	sd	ra,24(sp)
    80001d82:	e822                	sd	s0,16(sp)
    80001d84:	e426                	sd	s1,8(sp)
    80001d86:	e04a                	sd	s2,0(sp)
    80001d88:	1000                	addi	s0,sp,32
    80001d8a:	892a                	mv	s2,a0
    80001d8c:	fffff097          	auipc	ra,0xfffff
    80001d90:	776080e7          	jalr	1910(ra) # 80001502 <uvmcreate>
    80001d94:	84aa                	mv	s1,a0
    80001d96:	c121                	beqz	a0,80001dd6 <proc_pagetable+0x58>
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
    80001dd6:	8526                	mv	a0,s1
    80001dd8:	60e2                	ld	ra,24(sp)
    80001dda:	6442                	ld	s0,16(sp)
    80001ddc:	64a2                	ld	s1,8(sp)
    80001dde:	6902                	ld	s2,0(sp)
    80001de0:	6105                	addi	sp,sp,32
    80001de2:	8082                	ret
    80001de4:	4581                	li	a1,0
    80001de6:	8526                	mv	a0,s1
    80001de8:	00000097          	auipc	ra,0x0
    80001dec:	91e080e7          	jalr	-1762(ra) # 80001706 <uvmfree>
    80001df0:	4481                	li	s1,0
    80001df2:	b7d5                	j	80001dd6 <proc_pagetable+0x58>
    80001df4:	4681                	li	a3,0
    80001df6:	4605                	li	a2,1
    80001df8:	040005b7          	lui	a1,0x4000
    80001dfc:	15fd                	addi	a1,a1,-1
    80001dfe:	05b2                	slli	a1,a1,0xc
    80001e00:	8526                	mv	a0,s1
    80001e02:	fffff097          	auipc	ra,0xfffff
    80001e06:	63c080e7          	jalr	1596(ra) # 8000143e <uvmunmap>
    80001e0a:	4581                	li	a1,0
    80001e0c:	8526                	mv	a0,s1
    80001e0e:	00000097          	auipc	ra,0x0
    80001e12:	8f8080e7          	jalr	-1800(ra) # 80001706 <uvmfree>
    80001e16:	4481                	li	s1,0
    80001e18:	bf7d                	j	80001dd6 <proc_pagetable+0x58>

0000000080001e1a <proc_freepagetable>:
    80001e1a:	1101                	addi	sp,sp,-32
    80001e1c:	ec06                	sd	ra,24(sp)
    80001e1e:	e822                	sd	s0,16(sp)
    80001e20:	e426                	sd	s1,8(sp)
    80001e22:	e04a                	sd	s2,0(sp)
    80001e24:	1000                	addi	s0,sp,32
    80001e26:	84aa                	mv	s1,a0
    80001e28:	892e                	mv	s2,a1
    80001e2a:	4681                	li	a3,0
    80001e2c:	4605                	li	a2,1
    80001e2e:	040005b7          	lui	a1,0x4000
    80001e32:	15fd                	addi	a1,a1,-1
    80001e34:	05b2                	slli	a1,a1,0xc
    80001e36:	fffff097          	auipc	ra,0xfffff
    80001e3a:	608080e7          	jalr	1544(ra) # 8000143e <uvmunmap>
    80001e3e:	4681                	li	a3,0
    80001e40:	4605                	li	a2,1
    80001e42:	020005b7          	lui	a1,0x2000
    80001e46:	15fd                	addi	a1,a1,-1
    80001e48:	05b6                	slli	a1,a1,0xd
    80001e4a:	8526                	mv	a0,s1
    80001e4c:	fffff097          	auipc	ra,0xfffff
    80001e50:	5f2080e7          	jalr	1522(ra) # 8000143e <uvmunmap>
    80001e54:	85ca                	mv	a1,s2
    80001e56:	8526                	mv	a0,s1
    80001e58:	00000097          	auipc	ra,0x0
    80001e5c:	8ae080e7          	jalr	-1874(ra) # 80001706 <uvmfree>
    80001e60:	60e2                	ld	ra,24(sp)
    80001e62:	6442                	ld	s0,16(sp)
    80001e64:	64a2                	ld	s1,8(sp)
    80001e66:	6902                	ld	s2,0(sp)
    80001e68:	6105                	addi	sp,sp,32
    80001e6a:	8082                	ret

0000000080001e6c <freeproc>:
    80001e6c:	1101                	addi	sp,sp,-32
    80001e6e:	ec06                	sd	ra,24(sp)
    80001e70:	e822                	sd	s0,16(sp)
    80001e72:	e426                	sd	s1,8(sp)
    80001e74:	1000                	addi	s0,sp,32
    80001e76:	84aa                	mv	s1,a0
    80001e78:	7128                	ld	a0,96(a0)
    80001e7a:	c509                	beqz	a0,80001e84 <freeproc+0x18>
    80001e7c:	fffff097          	auipc	ra,0xfffff
    80001e80:	c52080e7          	jalr	-942(ra) # 80000ace <kfree>
    80001e84:	0604b023          	sd	zero,96(s1)
    80001e88:	6ca8                	ld	a0,88(s1)
    80001e8a:	c511                	beqz	a0,80001e96 <freeproc+0x2a>
    80001e8c:	68ac                	ld	a1,80(s1)
    80001e8e:	00000097          	auipc	ra,0x0
    80001e92:	f8c080e7          	jalr	-116(ra) # 80001e1a <proc_freepagetable>
    80001e96:	0404bc23          	sd	zero,88(s1)
    80001e9a:	0404b823          	sd	zero,80(s1)
    80001e9e:	0204ac23          	sw	zero,56(s1)
    80001ea2:	0404b023          	sd	zero,64(s1)
    80001ea6:	16048023          	sb	zero,352(s1)
    80001eaa:	0204b423          	sd	zero,40(s1)
    80001eae:	0204a823          	sw	zero,48(s1)
    80001eb2:	0204aa23          	sw	zero,52(s1)
    80001eb6:	0204a023          	sw	zero,32(s1)
    80001eba:	60e2                	ld	ra,24(sp)
    80001ebc:	6442                	ld	s0,16(sp)
    80001ebe:	64a2                	ld	s1,8(sp)
    80001ec0:	6105                	addi	sp,sp,32
    80001ec2:	8082                	ret

0000000080001ec4 <allocproc>:
    80001ec4:	7179                	addi	sp,sp,-48
    80001ec6:	f406                	sd	ra,40(sp)
    80001ec8:	f022                	sd	s0,32(sp)
    80001eca:	ec26                	sd	s1,24(sp)
    80001ecc:	e84a                	sd	s2,16(sp)
    80001ece:	e44e                	sd	s3,8(sp)
    80001ed0:	1800                	addi	s0,sp,48
    80001ed2:	0066f497          	auipc	s1,0x66f
    80001ed6:	41648493          	addi	s1,s1,1046 # 806712e8 <proc>
    80001eda:	00677997          	auipc	s3,0x677
    80001ede:	00e98993          	addi	s3,s3,14 # 80678ee8 <tickslock>
    80001ee2:	00848913          	addi	s2,s1,8
    80001ee6:	854a                	mv	a0,s2
    80001ee8:	fffff097          	auipc	ra,0xfffff
    80001eec:	ec0080e7          	jalr	-320(ra) # 80000da8 <acquire>
    80001ef0:	509c                	lw	a5,32(s1)
    80001ef2:	cf81                	beqz	a5,80001f0a <allocproc+0x46>
    80001ef4:	854a                	mv	a0,s2
    80001ef6:	fffff097          	auipc	ra,0xfffff
    80001efa:	f66080e7          	jalr	-154(ra) # 80000e5c <release>
    80001efe:	1f048493          	addi	s1,s1,496
    80001f02:	ff3490e3          	bne	s1,s3,80001ee2 <allocproc+0x1e>
    80001f06:	4481                	li	s1,0
    80001f08:	a041                	j	80001f88 <allocproc+0xc4>
    80001f0a:	00000097          	auipc	ra,0x0
    80001f0e:	e2e080e7          	jalr	-466(ra) # 80001d38 <allocpid>
    80001f12:	dc88                	sw	a0,56(s1)
    80001f14:	4785                	li	a5,1
    80001f16:	d09c                	sw	a5,32(s1)
    80001f18:	fffff097          	auipc	ra,0xfffff
    80001f1c:	d5c080e7          	jalr	-676(ra) # 80000c74 <kalloc>
    80001f20:	89aa                	mv	s3,a0
    80001f22:	f0a8                	sd	a0,96(s1)
    80001f24:	c935                	beqz	a0,80001f98 <allocproc+0xd4>
    80001f26:	8526                	mv	a0,s1
    80001f28:	00000097          	auipc	ra,0x0
    80001f2c:	e56080e7          	jalr	-426(ra) # 80001d7e <proc_pagetable>
    80001f30:	89aa                	mv	s3,a0
    80001f32:	eca8                	sd	a0,88(s1)
    80001f34:	cd35                	beqz	a0,80001fb0 <allocproc+0xec>
    80001f36:	07000613          	li	a2,112
    80001f3a:	4581                	li	a1,0
    80001f3c:	06848513          	addi	a0,s1,104
    80001f40:	fffff097          	auipc	ra,0xfffff
    80001f44:	f64080e7          	jalr	-156(ra) # 80000ea4 <memset>
    80001f48:	00000797          	auipc	a5,0x0
    80001f4c:	da878793          	addi	a5,a5,-600 # 80001cf0 <forkret>
    80001f50:	f4bc                	sd	a5,104(s1)
    80001f52:	64bc                	ld	a5,72(s1)
    80001f54:	6705                	lui	a4,0x1
    80001f56:	97ba                	add	a5,a5,a4
    80001f58:	f8bc                	sd	a5,112(s1)
    80001f5a:	00007797          	auipc	a5,0x7
    80001f5e:	cd67a783          	lw	a5,-810(a5) # 80008c30 <ticks>
    80001f62:	18f4ac23          	sw	a5,408(s1)
    80001f66:	03c00793          	li	a5,60
    80001f6a:	1af4ac23          	sw	a5,440(s1)
    80001f6e:	4795                	li	a5,5
    80001f70:	1cf4a023          	sw	a5,448(s1)
    80001f74:	1804ae23          	sw	zero,412(s1)
    80001f78:	1a04a023          	sw	zero,416(s1)
    80001f7c:	1a04a823          	sw	zero,432(s1)
    80001f80:	1a04a423          	sw	zero,424(s1)
    80001f84:	1a04a623          	sw	zero,428(s1)
    80001f88:	8526                	mv	a0,s1
    80001f8a:	70a2                	ld	ra,40(sp)
    80001f8c:	7402                	ld	s0,32(sp)
    80001f8e:	64e2                	ld	s1,24(sp)
    80001f90:	6942                	ld	s2,16(sp)
    80001f92:	69a2                	ld	s3,8(sp)
    80001f94:	6145                	addi	sp,sp,48
    80001f96:	8082                	ret
    80001f98:	8526                	mv	a0,s1
    80001f9a:	00000097          	auipc	ra,0x0
    80001f9e:	ed2080e7          	jalr	-302(ra) # 80001e6c <freeproc>
    80001fa2:	854a                	mv	a0,s2
    80001fa4:	fffff097          	auipc	ra,0xfffff
    80001fa8:	eb8080e7          	jalr	-328(ra) # 80000e5c <release>
    80001fac:	84ce                	mv	s1,s3
    80001fae:	bfe9                	j	80001f88 <allocproc+0xc4>
    80001fb0:	8526                	mv	a0,s1
    80001fb2:	00000097          	auipc	ra,0x0
    80001fb6:	eba080e7          	jalr	-326(ra) # 80001e6c <freeproc>
    80001fba:	854a                	mv	a0,s2
    80001fbc:	fffff097          	auipc	ra,0xfffff
    80001fc0:	ea0080e7          	jalr	-352(ra) # 80000e5c <release>
    80001fc4:	84ce                	mv	s1,s3
    80001fc6:	b7c9                	j	80001f88 <allocproc+0xc4>

0000000080001fc8 <userinit>:
    80001fc8:	1101                	addi	sp,sp,-32
    80001fca:	ec06                	sd	ra,24(sp)
    80001fcc:	e822                	sd	s0,16(sp)
    80001fce:	e426                	sd	s1,8(sp)
    80001fd0:	1000                	addi	s0,sp,32
    80001fd2:	00000097          	auipc	ra,0x0
    80001fd6:	ef2080e7          	jalr	-270(ra) # 80001ec4 <allocproc>
    80001fda:	84aa                	mv	s1,a0
    80001fdc:	00007797          	auipc	a5,0x7
    80001fe0:	c4a7b623          	sd	a0,-948(a5) # 80008c28 <initproc>
    80001fe4:	03400613          	li	a2,52
    80001fe8:	00007597          	auipc	a1,0x7
    80001fec:	9f858593          	addi	a1,a1,-1544 # 800089e0 <initcode>
    80001ff0:	6d28                	ld	a0,88(a0)
    80001ff2:	fffff097          	auipc	ra,0xfffff
    80001ff6:	53e080e7          	jalr	1342(ra) # 80001530 <uvmfirst>
    80001ffa:	6785                	lui	a5,0x1
    80001ffc:	e8bc                	sd	a5,80(s1)
    80001ffe:	70b8                	ld	a4,96(s1)
    80002000:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    80002004:	70b8                	ld	a4,96(s1)
    80002006:	fb1c                	sd	a5,48(a4)
    80002008:	4641                	li	a2,16
    8000200a:	00006597          	auipc	a1,0x6
    8000200e:	23e58593          	addi	a1,a1,574 # 80008248 <digits+0x208>
    80002012:	16048513          	addi	a0,s1,352
    80002016:	fffff097          	auipc	ra,0xfffff
    8000201a:	fe0080e7          	jalr	-32(ra) # 80000ff6 <safestrcpy>
    8000201e:	00006517          	auipc	a0,0x6
    80002022:	23a50513          	addi	a0,a0,570 # 80008258 <digits+0x218>
    80002026:	00002097          	auipc	ra,0x2
    8000202a:	7c6080e7          	jalr	1990(ra) # 800047ec <namei>
    8000202e:	14a4bc23          	sd	a0,344(s1)
    80002032:	478d                	li	a5,3
    80002034:	d09c                	sw	a5,32(s1)
    80002036:	00848513          	addi	a0,s1,8
    8000203a:	fffff097          	auipc	ra,0xfffff
    8000203e:	e22080e7          	jalr	-478(ra) # 80000e5c <release>
    80002042:	60e2                	ld	ra,24(sp)
    80002044:	6442                	ld	s0,16(sp)
    80002046:	64a2                	ld	s1,8(sp)
    80002048:	6105                	addi	sp,sp,32
    8000204a:	8082                	ret

000000008000204c <growproc>:
    8000204c:	1101                	addi	sp,sp,-32
    8000204e:	ec06                	sd	ra,24(sp)
    80002050:	e822                	sd	s0,16(sp)
    80002052:	e426                	sd	s1,8(sp)
    80002054:	e04a                	sd	s2,0(sp)
    80002056:	1000                	addi	s0,sp,32
    80002058:	892a                	mv	s2,a0
    8000205a:	00000097          	auipc	ra,0x0
    8000205e:	c5e080e7          	jalr	-930(ra) # 80001cb8 <myproc>
    80002062:	84aa                	mv	s1,a0
    80002064:	692c                	ld	a1,80(a0)
    80002066:	01204c63          	bgtz	s2,8000207e <growproc+0x32>
    8000206a:	02094663          	bltz	s2,80002096 <growproc+0x4a>
    8000206e:	e8ac                	sd	a1,80(s1)
    80002070:	4501                	li	a0,0
    80002072:	60e2                	ld	ra,24(sp)
    80002074:	6442                	ld	s0,16(sp)
    80002076:	64a2                	ld	s1,8(sp)
    80002078:	6902                	ld	s2,0(sp)
    8000207a:	6105                	addi	sp,sp,32
    8000207c:	8082                	ret
    8000207e:	4691                	li	a3,4
    80002080:	00b90633          	add	a2,s2,a1
    80002084:	6d28                	ld	a0,88(a0)
    80002086:	fffff097          	auipc	ra,0xfffff
    8000208a:	564080e7          	jalr	1380(ra) # 800015ea <uvmalloc>
    8000208e:	85aa                	mv	a1,a0
    80002090:	fd79                	bnez	a0,8000206e <growproc+0x22>
    80002092:	557d                	li	a0,-1
    80002094:	bff9                	j	80002072 <growproc+0x26>
    80002096:	00b90633          	add	a2,s2,a1
    8000209a:	6d28                	ld	a0,88(a0)
    8000209c:	fffff097          	auipc	ra,0xfffff
    800020a0:	506080e7          	jalr	1286(ra) # 800015a2 <uvmdealloc>
    800020a4:	85aa                	mv	a1,a0
    800020a6:	b7e1                	j	8000206e <growproc+0x22>

00000000800020a8 <fork>:
    800020a8:	7139                	addi	sp,sp,-64
    800020aa:	fc06                	sd	ra,56(sp)
    800020ac:	f822                	sd	s0,48(sp)
    800020ae:	f426                	sd	s1,40(sp)
    800020b0:	f04a                	sd	s2,32(sp)
    800020b2:	ec4e                	sd	s3,24(sp)
    800020b4:	e852                	sd	s4,16(sp)
    800020b6:	e456                	sd	s5,8(sp)
    800020b8:	0080                	addi	s0,sp,64
    800020ba:	00000097          	auipc	ra,0x0
    800020be:	bfe080e7          	jalr	-1026(ra) # 80001cb8 <myproc>
    800020c2:	892a                	mv	s2,a0
    800020c4:	00000097          	auipc	ra,0x0
    800020c8:	e00080e7          	jalr	-512(ra) # 80001ec4 <allocproc>
    800020cc:	12050363          	beqz	a0,800021f2 <fork+0x14a>
    800020d0:	89aa                	mv	s3,a0
    800020d2:	05093603          	ld	a2,80(s2)
    800020d6:	6d2c                	ld	a1,88(a0)
    800020d8:	05893503          	ld	a0,88(s2)
    800020dc:	fffff097          	auipc	ra,0xfffff
    800020e0:	662080e7          	jalr	1634(ra) # 8000173e <uvmcopy>
    800020e4:	04054a63          	bltz	a0,80002138 <fork+0x90>
    800020e8:	00092783          	lw	a5,0(s2)
    800020ec:	00f9a023          	sw	a5,0(s3)
    800020f0:	05093783          	ld	a5,80(s2)
    800020f4:	04f9b823          	sd	a5,80(s3)
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
    80002126:	0609b783          	ld	a5,96(s3)
    8000212a:	0607b823          	sd	zero,112(a5)
    8000212e:	0d800493          	li	s1,216
    80002132:	15800a13          	li	s4,344
    80002136:	a805                	j	80002166 <fork+0xbe>
    80002138:	854e                	mv	a0,s3
    8000213a:	00000097          	auipc	ra,0x0
    8000213e:	d32080e7          	jalr	-718(ra) # 80001e6c <freeproc>
    80002142:	00898513          	addi	a0,s3,8
    80002146:	fffff097          	auipc	ra,0xfffff
    8000214a:	d16080e7          	jalr	-746(ra) # 80000e5c <release>
    8000214e:	5afd                	li	s5,-1
    80002150:	a079                	j	800021de <fork+0x136>
    80002152:	00003097          	auipc	ra,0x3
    80002156:	d30080e7          	jalr	-720(ra) # 80004e82 <filedup>
    8000215a:	009987b3          	add	a5,s3,s1
    8000215e:	e388                	sd	a0,0(a5)
    80002160:	04a1                	addi	s1,s1,8
    80002162:	01448763          	beq	s1,s4,80002170 <fork+0xc8>
    80002166:	009907b3          	add	a5,s2,s1
    8000216a:	6388                	ld	a0,0(a5)
    8000216c:	f17d                	bnez	a0,80002152 <fork+0xaa>
    8000216e:	bfcd                	j	80002160 <fork+0xb8>
    80002170:	15893503          	ld	a0,344(s2)
    80002174:	00002097          	auipc	ra,0x2
    80002178:	e94080e7          	jalr	-364(ra) # 80004008 <idup>
    8000217c:	14a9bc23          	sd	a0,344(s3)
    80002180:	4641                	li	a2,16
    80002182:	16090593          	addi	a1,s2,352
    80002186:	16098513          	addi	a0,s3,352
    8000218a:	fffff097          	auipc	ra,0xfffff
    8000218e:	e6c080e7          	jalr	-404(ra) # 80000ff6 <safestrcpy>
    80002192:	0389aa83          	lw	s5,56(s3)
    80002196:	00898493          	addi	s1,s3,8
    8000219a:	8526                	mv	a0,s1
    8000219c:	fffff097          	auipc	ra,0xfffff
    800021a0:	cc0080e7          	jalr	-832(ra) # 80000e5c <release>
    800021a4:	0066fa17          	auipc	s4,0x66f
    800021a8:	d2ca0a13          	addi	s4,s4,-724 # 80670ed0 <wait_lock>
    800021ac:	8552                	mv	a0,s4
    800021ae:	fffff097          	auipc	ra,0xfffff
    800021b2:	bfa080e7          	jalr	-1030(ra) # 80000da8 <acquire>
    800021b6:	0529b023          	sd	s2,64(s3)
    800021ba:	8552                	mv	a0,s4
    800021bc:	fffff097          	auipc	ra,0xfffff
    800021c0:	ca0080e7          	jalr	-864(ra) # 80000e5c <release>
    800021c4:	8526                	mv	a0,s1
    800021c6:	fffff097          	auipc	ra,0xfffff
    800021ca:	be2080e7          	jalr	-1054(ra) # 80000da8 <acquire>
    800021ce:	478d                	li	a5,3
    800021d0:	02f9a023          	sw	a5,32(s3)
    800021d4:	8526                	mv	a0,s1
    800021d6:	fffff097          	auipc	ra,0xfffff
    800021da:	c86080e7          	jalr	-890(ra) # 80000e5c <release>
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
    800021f2:	5afd                	li	s5,-1
    800021f4:	b7ed                	j	800021de <fork+0x136>

00000000800021f6 <upd_time>:
    800021f6:	7179                	addi	sp,sp,-48
    800021f8:	f406                	sd	ra,40(sp)
    800021fa:	f022                	sd	s0,32(sp)
    800021fc:	ec26                	sd	s1,24(sp)
    800021fe:	e84a                	sd	s2,16(sp)
    80002200:	e44e                	sd	s3,8(sp)
    80002202:	e052                	sd	s4,0(sp)
    80002204:	1800                	addi	s0,sp,48
    80002206:	0066f497          	auipc	s1,0x66f
    8000220a:	0ea48493          	addi	s1,s1,234 # 806712f0 <proc+0x8>
    8000220e:	00677a17          	auipc	s4,0x677
    80002212:	ce2a0a13          	addi	s4,s4,-798 # 80678ef0 <tickslock+0x8>
    80002216:	4991                	li	s3,4
    80002218:	a811                	j	8000222c <upd_time+0x36>
    8000221a:	854a                	mv	a0,s2
    8000221c:	fffff097          	auipc	ra,0xfffff
    80002220:	c40080e7          	jalr	-960(ra) # 80000e5c <release>
    80002224:	1f048493          	addi	s1,s1,496
    80002228:	03448663          	beq	s1,s4,80002254 <upd_time+0x5e>
    8000222c:	8926                	mv	s2,s1
    8000222e:	8526                	mv	a0,s1
    80002230:	fffff097          	auipc	ra,0xfffff
    80002234:	b78080e7          	jalr	-1160(ra) # 80000da8 <acquire>
    80002238:	4c9c                	lw	a5,24(s1)
    8000223a:	ff3790e3          	bne	a5,s3,8000221a <upd_time+0x24>
    8000223e:	1944a783          	lw	a5,404(s1)
    80002242:	2785                	addiw	a5,a5,1
    80002244:	18f4aa23          	sw	a5,404(s1)
    80002248:	1a84a783          	lw	a5,424(s1)
    8000224c:	2785                	addiw	a5,a5,1
    8000224e:	1af4a423          	sw	a5,424(s1)
    80002252:	b7e1                	j	8000221a <upd_time+0x24>
    80002254:	70a2                	ld	ra,40(sp)
    80002256:	7402                	ld	s0,32(sp)
    80002258:	64e2                	ld	s1,24(sp)
    8000225a:	6942                	ld	s2,16(sp)
    8000225c:	69a2                	ld	s3,8(sp)
    8000225e:	6a02                	ld	s4,0(sp)
    80002260:	6145                	addi	sp,sp,48
    80002262:	8082                	ret

0000000080002264 <scheduler>:
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
    8000227c:	2781                	sext.w	a5,a5
    8000227e:	00779b13          	slli	s6,a5,0x7
    80002282:	0066f717          	auipc	a4,0x66f
    80002286:	c3670713          	addi	a4,a4,-970 # 80670eb8 <pid_lock>
    8000228a:	975a                	add	a4,a4,s6
    8000228c:	02073823          	sd	zero,48(a4)
    80002290:	0066f717          	auipc	a4,0x66f
    80002294:	c6070713          	addi	a4,a4,-928 # 80670ef0 <cpus+0x8>
    80002298:	9b3a                	add	s6,s6,a4
    8000229a:	4a0d                	li	s4,3
    8000229c:	4b91                	li	s7,4
    8000229e:	079e                	slli	a5,a5,0x7
    800022a0:	0066fa97          	auipc	s5,0x66f
    800022a4:	c18a8a93          	addi	s5,s5,-1000 # 80670eb8 <pid_lock>
    800022a8:	9abe                	add	s5,s5,a5
    800022aa:	00677997          	auipc	s3,0x677
    800022ae:	c3e98993          	addi	s3,s3,-962 # 80678ee8 <tickslock>
    800022b2:	100027f3          	csrr	a5,sstatus
    800022b6:	0027e793          	ori	a5,a5,2
    800022ba:	10079073          	csrw	sstatus,a5
    800022be:	0066f497          	auipc	s1,0x66f
    800022c2:	02a48493          	addi	s1,s1,42 # 806712e8 <proc>
    800022c6:	a03d                	j	800022f4 <scheduler+0x90>
    800022c8:	0374a023          	sw	s7,32(s1)
    800022cc:	029ab823          	sd	s1,48(s5)
    800022d0:	06848593          	addi	a1,s1,104
    800022d4:	855a                	mv	a0,s6
    800022d6:	00001097          	auipc	ra,0x1
    800022da:	88a080e7          	jalr	-1910(ra) # 80002b60 <swtch>
    800022de:	020ab823          	sd	zero,48(s5)
    800022e2:	854a                	mv	a0,s2
    800022e4:	fffff097          	auipc	ra,0xfffff
    800022e8:	b78080e7          	jalr	-1160(ra) # 80000e5c <release>
    800022ec:	1f048493          	addi	s1,s1,496
    800022f0:	fd3481e3          	beq	s1,s3,800022b2 <scheduler+0x4e>
    800022f4:	00848913          	addi	s2,s1,8
    800022f8:	854a                	mv	a0,s2
    800022fa:	fffff097          	auipc	ra,0xfffff
    800022fe:	aae080e7          	jalr	-1362(ra) # 80000da8 <acquire>
    80002302:	509c                	lw	a5,32(s1)
    80002304:	fd479fe3          	bne	a5,s4,800022e2 <scheduler+0x7e>
    80002308:	b7c1                	j	800022c8 <scheduler+0x64>

000000008000230a <sched>:
    8000230a:	7179                	addi	sp,sp,-48
    8000230c:	f406                	sd	ra,40(sp)
    8000230e:	f022                	sd	s0,32(sp)
    80002310:	ec26                	sd	s1,24(sp)
    80002312:	e84a                	sd	s2,16(sp)
    80002314:	e44e                	sd	s3,8(sp)
    80002316:	1800                	addi	s0,sp,48
    80002318:	00000097          	auipc	ra,0x0
    8000231c:	9a0080e7          	jalr	-1632(ra) # 80001cb8 <myproc>
    80002320:	84aa                	mv	s1,a0
    80002322:	0521                	addi	a0,a0,8
    80002324:	fffff097          	auipc	ra,0xfffff
    80002328:	a0a080e7          	jalr	-1526(ra) # 80000d2e <holding>
    8000232c:	c93d                	beqz	a0,800023a2 <sched+0x98>
    8000232e:	8792                	mv	a5,tp
    80002330:	2781                	sext.w	a5,a5
    80002332:	079e                	slli	a5,a5,0x7
    80002334:	0066f717          	auipc	a4,0x66f
    80002338:	b8470713          	addi	a4,a4,-1148 # 80670eb8 <pid_lock>
    8000233c:	97ba                	add	a5,a5,a4
    8000233e:	0a87a703          	lw	a4,168(a5)
    80002342:	4785                	li	a5,1
    80002344:	06f71763          	bne	a4,a5,800023b2 <sched+0xa8>
    80002348:	5098                	lw	a4,32(s1)
    8000234a:	4791                	li	a5,4
    8000234c:	06f70b63          	beq	a4,a5,800023c2 <sched+0xb8>
    80002350:	100027f3          	csrr	a5,sstatus
    80002354:	8b89                	andi	a5,a5,2
    80002356:	efb5                	bnez	a5,800023d2 <sched+0xc8>
    80002358:	8792                	mv	a5,tp
    8000235a:	0066f917          	auipc	s2,0x66f
    8000235e:	b5e90913          	addi	s2,s2,-1186 # 80670eb8 <pid_lock>
    80002362:	2781                	sext.w	a5,a5
    80002364:	079e                	slli	a5,a5,0x7
    80002366:	97ca                	add	a5,a5,s2
    80002368:	0ac7a983          	lw	s3,172(a5)
    8000236c:	8792                	mv	a5,tp
    8000236e:	2781                	sext.w	a5,a5
    80002370:	079e                	slli	a5,a5,0x7
    80002372:	0066f597          	auipc	a1,0x66f
    80002376:	b7e58593          	addi	a1,a1,-1154 # 80670ef0 <cpus+0x8>
    8000237a:	95be                	add	a1,a1,a5
    8000237c:	06848513          	addi	a0,s1,104
    80002380:	00000097          	auipc	ra,0x0
    80002384:	7e0080e7          	jalr	2016(ra) # 80002b60 <swtch>
    80002388:	8792                	mv	a5,tp
    8000238a:	2781                	sext.w	a5,a5
    8000238c:	079e                	slli	a5,a5,0x7
    8000238e:	97ca                	add	a5,a5,s2
    80002390:	0b37a623          	sw	s3,172(a5)
    80002394:	70a2                	ld	ra,40(sp)
    80002396:	7402                	ld	s0,32(sp)
    80002398:	64e2                	ld	s1,24(sp)
    8000239a:	6942                	ld	s2,16(sp)
    8000239c:	69a2                	ld	s3,8(sp)
    8000239e:	6145                	addi	sp,sp,48
    800023a0:	8082                	ret
    800023a2:	00006517          	auipc	a0,0x6
    800023a6:	ebe50513          	addi	a0,a0,-322 # 80008260 <digits+0x220>
    800023aa:	ffffe097          	auipc	ra,0xffffe
    800023ae:	19a080e7          	jalr	410(ra) # 80000544 <panic>
    800023b2:	00006517          	auipc	a0,0x6
    800023b6:	ebe50513          	addi	a0,a0,-322 # 80008270 <digits+0x230>
    800023ba:	ffffe097          	auipc	ra,0xffffe
    800023be:	18a080e7          	jalr	394(ra) # 80000544 <panic>
    800023c2:	00006517          	auipc	a0,0x6
    800023c6:	ebe50513          	addi	a0,a0,-322 # 80008280 <digits+0x240>
    800023ca:	ffffe097          	auipc	ra,0xffffe
    800023ce:	17a080e7          	jalr	378(ra) # 80000544 <panic>
    800023d2:	00006517          	auipc	a0,0x6
    800023d6:	ebe50513          	addi	a0,a0,-322 # 80008290 <digits+0x250>
    800023da:	ffffe097          	auipc	ra,0xffffe
    800023de:	16a080e7          	jalr	362(ra) # 80000544 <panic>

00000000800023e2 <yield>:
    800023e2:	1101                	addi	sp,sp,-32
    800023e4:	ec06                	sd	ra,24(sp)
    800023e6:	e822                	sd	s0,16(sp)
    800023e8:	e426                	sd	s1,8(sp)
    800023ea:	e04a                	sd	s2,0(sp)
    800023ec:	1000                	addi	s0,sp,32
    800023ee:	00000097          	auipc	ra,0x0
    800023f2:	8ca080e7          	jalr	-1846(ra) # 80001cb8 <myproc>
    800023f6:	84aa                	mv	s1,a0
    800023f8:	00850913          	addi	s2,a0,8
    800023fc:	854a                	mv	a0,s2
    800023fe:	fffff097          	auipc	ra,0xfffff
    80002402:	9aa080e7          	jalr	-1622(ra) # 80000da8 <acquire>
    80002406:	478d                	li	a5,3
    80002408:	d09c                	sw	a5,32(s1)
    8000240a:	00000097          	auipc	ra,0x0
    8000240e:	f00080e7          	jalr	-256(ra) # 8000230a <sched>
    80002412:	854a                	mv	a0,s2
    80002414:	fffff097          	auipc	ra,0xfffff
    80002418:	a48080e7          	jalr	-1464(ra) # 80000e5c <release>
    8000241c:	60e2                	ld	ra,24(sp)
    8000241e:	6442                	ld	s0,16(sp)
    80002420:	64a2                	ld	s1,8(sp)
    80002422:	6902                	ld	s2,0(sp)
    80002424:	6105                	addi	sp,sp,32
    80002426:	8082                	ret

0000000080002428 <sleep>:
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
    8000243c:	00000097          	auipc	ra,0x0
    80002440:	87c080e7          	jalr	-1924(ra) # 80001cb8 <myproc>
    80002444:	84aa                	mv	s1,a0
    80002446:	00850a13          	addi	s4,a0,8
    8000244a:	8552                	mv	a0,s4
    8000244c:	fffff097          	auipc	ra,0xfffff
    80002450:	95c080e7          	jalr	-1700(ra) # 80000da8 <acquire>
    80002454:	854a                	mv	a0,s2
    80002456:	fffff097          	auipc	ra,0xfffff
    8000245a:	a06080e7          	jalr	-1530(ra) # 80000e5c <release>
    8000245e:	0334b423          	sd	s3,40(s1)
    80002462:	4789                	li	a5,2
    80002464:	d09c                	sw	a5,32(s1)
    80002466:	00000097          	auipc	ra,0x0
    8000246a:	ea4080e7          	jalr	-348(ra) # 8000230a <sched>
    8000246e:	0204b423          	sd	zero,40(s1)
    80002472:	8552                	mv	a0,s4
    80002474:	fffff097          	auipc	ra,0xfffff
    80002478:	9e8080e7          	jalr	-1560(ra) # 80000e5c <release>
    8000247c:	854a                	mv	a0,s2
    8000247e:	fffff097          	auipc	ra,0xfffff
    80002482:	92a080e7          	jalr	-1750(ra) # 80000da8 <acquire>
    80002486:	70a2                	ld	ra,40(sp)
    80002488:	7402                	ld	s0,32(sp)
    8000248a:	64e2                	ld	s1,24(sp)
    8000248c:	6942                	ld	s2,16(sp)
    8000248e:	69a2                	ld	s3,8(sp)
    80002490:	6a02                	ld	s4,0(sp)
    80002492:	6145                	addi	sp,sp,48
    80002494:	8082                	ret

0000000080002496 <waitx>:
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
    800024ba:	fffff097          	auipc	ra,0xfffff
    800024be:	7fe080e7          	jalr	2046(ra) # 80001cb8 <myproc>
    800024c2:	892a                	mv	s2,a0
    800024c4:	0066f517          	auipc	a0,0x66f
    800024c8:	a0c50513          	addi	a0,a0,-1524 # 80670ed0 <wait_lock>
    800024cc:	fffff097          	auipc	ra,0xfffff
    800024d0:	8dc080e7          	jalr	-1828(ra) # 80000da8 <acquire>
    800024d4:	4c81                	li	s9,0
    800024d6:	4a15                	li	s4,5
    800024d8:	00677997          	auipc	s3,0x677
    800024dc:	a1098993          	addi	s3,s3,-1520 # 80678ee8 <tickslock>
    800024e0:	4a85                	li	s5,1
    800024e2:	0066fd17          	auipc	s10,0x66f
    800024e6:	9eed0d13          	addi	s10,s10,-1554 # 80670ed0 <wait_lock>
    800024ea:	8766                	mv	a4,s9
    800024ec:	0066f497          	auipc	s1,0x66f
    800024f0:	dfc48493          	addi	s1,s1,-516 # 806712e8 <proc>
    800024f4:	a059                	j	8000257a <waitx+0xe4>
    800024f6:	0384a983          	lw	s3,56(s1)
    800024fa:	19c4a703          	lw	a4,412(s1)
    800024fe:	00ec2023          	sw	a4,0(s8) # 4000000 <_entry-0x7c000000>
    80002502:	1984a783          	lw	a5,408(s1)
    80002506:	9f3d                	addw	a4,a4,a5
    80002508:	1a04a783          	lw	a5,416(s1)
    8000250c:	9f99                	subw	a5,a5,a4
    8000250e:	00fba023          	sw	a5,0(s7) # fffffffffffff000 <end+0xffffffff7f97ad38>
    80002512:	000b0e63          	beqz	s6,8000252e <waitx+0x98>
    80002516:	4691                	li	a3,4
    80002518:	03448613          	addi	a2,s1,52
    8000251c:	85da                	mv	a1,s6
    8000251e:	05893503          	ld	a0,88(s2)
    80002522:	fffff097          	auipc	ra,0xfffff
    80002526:	316080e7          	jalr	790(ra) # 80001838 <copyout>
    8000252a:	02054563          	bltz	a0,80002554 <waitx+0xbe>
    8000252e:	8526                	mv	a0,s1
    80002530:	00000097          	auipc	ra,0x0
    80002534:	93c080e7          	jalr	-1732(ra) # 80001e6c <freeproc>
    80002538:	856e                	mv	a0,s11
    8000253a:	fffff097          	auipc	ra,0xfffff
    8000253e:	922080e7          	jalr	-1758(ra) # 80000e5c <release>
    80002542:	0066f517          	auipc	a0,0x66f
    80002546:	98e50513          	addi	a0,a0,-1650 # 80670ed0 <wait_lock>
    8000254a:	fffff097          	auipc	ra,0xfffff
    8000254e:	912080e7          	jalr	-1774(ra) # 80000e5c <release>
    80002552:	a0ad                	j	800025bc <waitx+0x126>
    80002554:	856e                	mv	a0,s11
    80002556:	fffff097          	auipc	ra,0xfffff
    8000255a:	906080e7          	jalr	-1786(ra) # 80000e5c <release>
    8000255e:	0066f517          	auipc	a0,0x66f
    80002562:	97250513          	addi	a0,a0,-1678 # 80670ed0 <wait_lock>
    80002566:	fffff097          	auipc	ra,0xfffff
    8000256a:	8f6080e7          	jalr	-1802(ra) # 80000e5c <release>
    8000256e:	59fd                	li	s3,-1
    80002570:	a0b1                	j	800025bc <waitx+0x126>
    80002572:	1f048493          	addi	s1,s1,496
    80002576:	03348663          	beq	s1,s3,800025a2 <waitx+0x10c>
    8000257a:	60bc                	ld	a5,64(s1)
    8000257c:	ff279be3          	bne	a5,s2,80002572 <waitx+0xdc>
    80002580:	00848d93          	addi	s11,s1,8
    80002584:	856e                	mv	a0,s11
    80002586:	fffff097          	auipc	ra,0xfffff
    8000258a:	822080e7          	jalr	-2014(ra) # 80000da8 <acquire>
    8000258e:	509c                	lw	a5,32(s1)
    80002590:	f74783e3          	beq	a5,s4,800024f6 <waitx+0x60>
    80002594:	856e                	mv	a0,s11
    80002596:	fffff097          	auipc	ra,0xfffff
    8000259a:	8c6080e7          	jalr	-1850(ra) # 80000e5c <release>
    8000259e:	8756                	mv	a4,s5
    800025a0:	bfc9                	j	80002572 <waitx+0xdc>
    800025a2:	c701                	beqz	a4,800025aa <waitx+0x114>
    800025a4:	03092783          	lw	a5,48(s2)
    800025a8:	cb95                	beqz	a5,800025dc <waitx+0x146>
    800025aa:	0066f517          	auipc	a0,0x66f
    800025ae:	92650513          	addi	a0,a0,-1754 # 80670ed0 <wait_lock>
    800025b2:	fffff097          	auipc	ra,0xfffff
    800025b6:	8aa080e7          	jalr	-1878(ra) # 80000e5c <release>
    800025ba:	59fd                	li	s3,-1
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
    800025dc:	85ea                	mv	a1,s10
    800025de:	854a                	mv	a0,s2
    800025e0:	00000097          	auipc	ra,0x0
    800025e4:	e48080e7          	jalr	-440(ra) # 80002428 <sleep>
    800025e8:	b709                	j	800024ea <waitx+0x54>

00000000800025ea <wait>:
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
    80002606:	fffff097          	auipc	ra,0xfffff
    8000260a:	6b2080e7          	jalr	1714(ra) # 80001cb8 <myproc>
    8000260e:	892a                	mv	s2,a0
    80002610:	0066f517          	auipc	a0,0x66f
    80002614:	8c050513          	addi	a0,a0,-1856 # 80670ed0 <wait_lock>
    80002618:	ffffe097          	auipc	ra,0xffffe
    8000261c:	790080e7          	jalr	1936(ra) # 80000da8 <acquire>
    80002620:	4c01                	li	s8,0
    80002622:	4a95                	li	s5,5
    80002624:	00677997          	auipc	s3,0x677
    80002628:	8c498993          	addi	s3,s3,-1852 # 80678ee8 <tickslock>
    8000262c:	4b05                	li	s6,1
    8000262e:	0066fc97          	auipc	s9,0x66f
    80002632:	8a2c8c93          	addi	s9,s9,-1886 # 80670ed0 <wait_lock>
    80002636:	8762                	mv	a4,s8
    80002638:	0066f497          	auipc	s1,0x66f
    8000263c:	cb048493          	addi	s1,s1,-848 # 806712e8 <proc>
    80002640:	a8ad                	j	800026ba <wait+0xd0>
    80002642:	0384a983          	lw	s3,56(s1)
    80002646:	000b8e63          	beqz	s7,80002662 <wait+0x78>
    8000264a:	4691                	li	a3,4
    8000264c:	03448613          	addi	a2,s1,52
    80002650:	85de                	mv	a1,s7
    80002652:	05893503          	ld	a0,88(s2)
    80002656:	fffff097          	auipc	ra,0xfffff
    8000265a:	1e2080e7          	jalr	482(ra) # 80001838 <copyout>
    8000265e:	02054b63          	bltz	a0,80002694 <wait+0xaa>
    80002662:	8526                	mv	a0,s1
    80002664:	00000097          	auipc	ra,0x0
    80002668:	808080e7          	jalr	-2040(ra) # 80001e6c <freeproc>
    8000266c:	8552                	mv	a0,s4
    8000266e:	ffffe097          	auipc	ra,0xffffe
    80002672:	7ee080e7          	jalr	2030(ra) # 80000e5c <release>
    80002676:	0066f517          	auipc	a0,0x66f
    8000267a:	85a50513          	addi	a0,a0,-1958 # 80670ed0 <wait_lock>
    8000267e:	ffffe097          	auipc	ra,0xffffe
    80002682:	7de080e7          	jalr	2014(ra) # 80000e5c <release>
    80002686:	00006797          	auipc	a5,0x6
    8000268a:	5aa7a783          	lw	a5,1450(a5) # 80008c30 <ticks>
    8000268e:	1af4a023          	sw	a5,416(s1)
    80002692:	a0ad                	j	800026fc <wait+0x112>
    80002694:	8552                	mv	a0,s4
    80002696:	ffffe097          	auipc	ra,0xffffe
    8000269a:	7c6080e7          	jalr	1990(ra) # 80000e5c <release>
    8000269e:	0066f517          	auipc	a0,0x66f
    800026a2:	83250513          	addi	a0,a0,-1998 # 80670ed0 <wait_lock>
    800026a6:	ffffe097          	auipc	ra,0xffffe
    800026aa:	7b6080e7          	jalr	1974(ra) # 80000e5c <release>
    800026ae:	59fd                	li	s3,-1
    800026b0:	a0b1                	j	800026fc <wait+0x112>
    800026b2:	1f048493          	addi	s1,s1,496
    800026b6:	03348663          	beq	s1,s3,800026e2 <wait+0xf8>
    800026ba:	60bc                	ld	a5,64(s1)
    800026bc:	ff279be3          	bne	a5,s2,800026b2 <wait+0xc8>
    800026c0:	00848a13          	addi	s4,s1,8
    800026c4:	8552                	mv	a0,s4
    800026c6:	ffffe097          	auipc	ra,0xffffe
    800026ca:	6e2080e7          	jalr	1762(ra) # 80000da8 <acquire>
    800026ce:	509c                	lw	a5,32(s1)
    800026d0:	f75789e3          	beq	a5,s5,80002642 <wait+0x58>
    800026d4:	8552                	mv	a0,s4
    800026d6:	ffffe097          	auipc	ra,0xffffe
    800026da:	786080e7          	jalr	1926(ra) # 80000e5c <release>
    800026de:	875a                	mv	a4,s6
    800026e0:	bfc9                	j	800026b2 <wait+0xc8>
    800026e2:	c701                	beqz	a4,800026ea <wait+0x100>
    800026e4:	03092783          	lw	a5,48(s2)
    800026e8:	cb85                	beqz	a5,80002718 <wait+0x12e>
    800026ea:	0066e517          	auipc	a0,0x66e
    800026ee:	7e650513          	addi	a0,a0,2022 # 80670ed0 <wait_lock>
    800026f2:	ffffe097          	auipc	ra,0xffffe
    800026f6:	76a080e7          	jalr	1898(ra) # 80000e5c <release>
    800026fa:	59fd                	li	s3,-1
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
    80002718:	85e6                	mv	a1,s9
    8000271a:	854a                	mv	a0,s2
    8000271c:	00000097          	auipc	ra,0x0
    80002720:	d0c080e7          	jalr	-756(ra) # 80002428 <sleep>
    80002724:	bf09                	j	80002636 <wait+0x4c>

0000000080002726 <wakeup>:
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
    8000273e:	0066f497          	auipc	s1,0x66f
    80002742:	baa48493          	addi	s1,s1,-1110 # 806712e8 <proc>
    80002746:	4a09                	li	s4,2
    80002748:	4b0d                	li	s6,3
    8000274a:	00006b97          	auipc	s7,0x6
    8000274e:	4e6b8b93          	addi	s7,s7,1254 # 80008c30 <ticks>
    80002752:	00676997          	auipc	s3,0x676
    80002756:	79698993          	addi	s3,s3,1942 # 80678ee8 <tickslock>
    8000275a:	a811                	j	8000276e <wakeup+0x48>
    8000275c:	854a                	mv	a0,s2
    8000275e:	ffffe097          	auipc	ra,0xffffe
    80002762:	6fe080e7          	jalr	1790(ra) # 80000e5c <release>
    80002766:	1f048493          	addi	s1,s1,496
    8000276a:	05348663          	beq	s1,s3,800027b6 <wakeup+0x90>
    8000276e:	fffff097          	auipc	ra,0xfffff
    80002772:	54a080e7          	jalr	1354(ra) # 80001cb8 <myproc>
    80002776:	fea488e3          	beq	s1,a0,80002766 <wakeup+0x40>
    8000277a:	00848913          	addi	s2,s1,8
    8000277e:	854a                	mv	a0,s2
    80002780:	ffffe097          	auipc	ra,0xffffe
    80002784:	628080e7          	jalr	1576(ra) # 80000da8 <acquire>
    80002788:	509c                	lw	a5,32(s1)
    8000278a:	fd4799e3          	bne	a5,s4,8000275c <wakeup+0x36>
    8000278e:	749c                	ld	a5,40(s1)
    80002790:	fd5796e3          	bne	a5,s5,8000275c <wakeup+0x36>
    80002794:	0364a023          	sw	s6,32(s1)
    80002798:	1ac4a783          	lw	a5,428(s1)
    8000279c:	d3e1                	beqz	a5,8000275c <wakeup+0x36>
    8000279e:	000ba703          	lw	a4,0(s7)
    800027a2:	40f707bb          	subw	a5,a4,a5
    800027a6:	1af4a423          	sw	a5,424(s1)
    800027aa:	1a44a703          	lw	a4,420(s1)
    800027ae:	9fb9                	addw	a5,a5,a4
    800027b0:	1af4a223          	sw	a5,420(s1)
    800027b4:	b765                	j	8000275c <wakeup+0x36>
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
    800027cc:	7179                	addi	sp,sp,-48
    800027ce:	f406                	sd	ra,40(sp)
    800027d0:	f022                	sd	s0,32(sp)
    800027d2:	ec26                	sd	s1,24(sp)
    800027d4:	e84a                	sd	s2,16(sp)
    800027d6:	e44e                	sd	s3,8(sp)
    800027d8:	e052                	sd	s4,0(sp)
    800027da:	1800                	addi	s0,sp,48
    800027dc:	892a                	mv	s2,a0
    800027de:	0066f497          	auipc	s1,0x66f
    800027e2:	b0a48493          	addi	s1,s1,-1270 # 806712e8 <proc>
    800027e6:	00006a17          	auipc	s4,0x6
    800027ea:	442a0a13          	addi	s4,s4,1090 # 80008c28 <initproc>
    800027ee:	00676997          	auipc	s3,0x676
    800027f2:	6fa98993          	addi	s3,s3,1786 # 80678ee8 <tickslock>
    800027f6:	a029                	j	80002800 <reparent+0x34>
    800027f8:	1f048493          	addi	s1,s1,496
    800027fc:	01348d63          	beq	s1,s3,80002816 <reparent+0x4a>
    80002800:	60bc                	ld	a5,64(s1)
    80002802:	ff279be3          	bne	a5,s2,800027f8 <reparent+0x2c>
    80002806:	000a3503          	ld	a0,0(s4)
    8000280a:	e0a8                	sd	a0,64(s1)
    8000280c:	00000097          	auipc	ra,0x0
    80002810:	f1a080e7          	jalr	-230(ra) # 80002726 <wakeup>
    80002814:	b7d5                	j	800027f8 <reparent+0x2c>
    80002816:	70a2                	ld	ra,40(sp)
    80002818:	7402                	ld	s0,32(sp)
    8000281a:	64e2                	ld	s1,24(sp)
    8000281c:	6942                	ld	s2,16(sp)
    8000281e:	69a2                	ld	s3,8(sp)
    80002820:	6a02                	ld	s4,0(sp)
    80002822:	6145                	addi	sp,sp,48
    80002824:	8082                	ret

0000000080002826 <exit>:
    80002826:	7179                	addi	sp,sp,-48
    80002828:	f406                	sd	ra,40(sp)
    8000282a:	f022                	sd	s0,32(sp)
    8000282c:	ec26                	sd	s1,24(sp)
    8000282e:	e84a                	sd	s2,16(sp)
    80002830:	e44e                	sd	s3,8(sp)
    80002832:	e052                	sd	s4,0(sp)
    80002834:	1800                	addi	s0,sp,48
    80002836:	8a2a                	mv	s4,a0
    80002838:	fffff097          	auipc	ra,0xfffff
    8000283c:	480080e7          	jalr	1152(ra) # 80001cb8 <myproc>
    80002840:	89aa                	mv	s3,a0
    80002842:	00006797          	auipc	a5,0x6
    80002846:	3e67b783          	ld	a5,998(a5) # 80008c28 <initproc>
    8000284a:	0d850493          	addi	s1,a0,216
    8000284e:	15850913          	addi	s2,a0,344
    80002852:	02a79363          	bne	a5,a0,80002878 <exit+0x52>
    80002856:	00006517          	auipc	a0,0x6
    8000285a:	a5250513          	addi	a0,a0,-1454 # 800082a8 <digits+0x268>
    8000285e:	ffffe097          	auipc	ra,0xffffe
    80002862:	ce6080e7          	jalr	-794(ra) # 80000544 <panic>
    80002866:	00002097          	auipc	ra,0x2
    8000286a:	66e080e7          	jalr	1646(ra) # 80004ed4 <fileclose>
    8000286e:	0004b023          	sd	zero,0(s1)
    80002872:	04a1                	addi	s1,s1,8
    80002874:	01248563          	beq	s1,s2,8000287e <exit+0x58>
    80002878:	6088                	ld	a0,0(s1)
    8000287a:	f575                	bnez	a0,80002866 <exit+0x40>
    8000287c:	bfdd                	j	80002872 <exit+0x4c>
    8000287e:	00002097          	auipc	ra,0x2
    80002882:	18a080e7          	jalr	394(ra) # 80004a08 <begin_op>
    80002886:	1589b503          	ld	a0,344(s3)
    8000288a:	00002097          	auipc	ra,0x2
    8000288e:	976080e7          	jalr	-1674(ra) # 80004200 <iput>
    80002892:	00002097          	auipc	ra,0x2
    80002896:	1f6080e7          	jalr	502(ra) # 80004a88 <end_op>
    8000289a:	1409bc23          	sd	zero,344(s3)
    8000289e:	0066e497          	auipc	s1,0x66e
    800028a2:	63248493          	addi	s1,s1,1586 # 80670ed0 <wait_lock>
    800028a6:	8526                	mv	a0,s1
    800028a8:	ffffe097          	auipc	ra,0xffffe
    800028ac:	500080e7          	jalr	1280(ra) # 80000da8 <acquire>
    800028b0:	854e                	mv	a0,s3
    800028b2:	00000097          	auipc	ra,0x0
    800028b6:	f1a080e7          	jalr	-230(ra) # 800027cc <reparent>
    800028ba:	0409b503          	ld	a0,64(s3)
    800028be:	00000097          	auipc	ra,0x0
    800028c2:	e68080e7          	jalr	-408(ra) # 80002726 <wakeup>
    800028c6:	00898513          	addi	a0,s3,8
    800028ca:	ffffe097          	auipc	ra,0xffffe
    800028ce:	4de080e7          	jalr	1246(ra) # 80000da8 <acquire>
    800028d2:	0349aa23          	sw	s4,52(s3)
    800028d6:	4795                	li	a5,5
    800028d8:	02f9a023          	sw	a5,32(s3)
    800028dc:	00006797          	auipc	a5,0x6
    800028e0:	3547a783          	lw	a5,852(a5) # 80008c30 <ticks>
    800028e4:	1af9a023          	sw	a5,416(s3)
    800028e8:	8526                	mv	a0,s1
    800028ea:	ffffe097          	auipc	ra,0xffffe
    800028ee:	572080e7          	jalr	1394(ra) # 80000e5c <release>
    800028f2:	00000097          	auipc	ra,0x0
    800028f6:	a18080e7          	jalr	-1512(ra) # 8000230a <sched>
    800028fa:	00006517          	auipc	a0,0x6
    800028fe:	9be50513          	addi	a0,a0,-1602 # 800082b8 <digits+0x278>
    80002902:	ffffe097          	auipc	ra,0xffffe
    80002906:	c42080e7          	jalr	-958(ra) # 80000544 <panic>

000000008000290a <kill>:
    8000290a:	7179                	addi	sp,sp,-48
    8000290c:	f406                	sd	ra,40(sp)
    8000290e:	f022                	sd	s0,32(sp)
    80002910:	ec26                	sd	s1,24(sp)
    80002912:	e84a                	sd	s2,16(sp)
    80002914:	e44e                	sd	s3,8(sp)
    80002916:	e052                	sd	s4,0(sp)
    80002918:	1800                	addi	s0,sp,48
    8000291a:	89aa                	mv	s3,a0
    8000291c:	0066f497          	auipc	s1,0x66f
    80002920:	9cc48493          	addi	s1,s1,-1588 # 806712e8 <proc>
    80002924:	00676a17          	auipc	s4,0x676
    80002928:	5c4a0a13          	addi	s4,s4,1476 # 80678ee8 <tickslock>
    8000292c:	00848913          	addi	s2,s1,8
    80002930:	854a                	mv	a0,s2
    80002932:	ffffe097          	auipc	ra,0xffffe
    80002936:	476080e7          	jalr	1142(ra) # 80000da8 <acquire>
    8000293a:	5c9c                	lw	a5,56(s1)
    8000293c:	01378d63          	beq	a5,s3,80002956 <kill+0x4c>
    80002940:	854a                	mv	a0,s2
    80002942:	ffffe097          	auipc	ra,0xffffe
    80002946:	51a080e7          	jalr	1306(ra) # 80000e5c <release>
    8000294a:	1f048493          	addi	s1,s1,496
    8000294e:	fd449fe3          	bne	s1,s4,8000292c <kill+0x22>
    80002952:	557d                	li	a0,-1
    80002954:	a829                	j	8000296e <kill+0x64>
    80002956:	4785                	li	a5,1
    80002958:	d89c                	sw	a5,48(s1)
    8000295a:	5098                	lw	a4,32(s1)
    8000295c:	4789                	li	a5,2
    8000295e:	02f70063          	beq	a4,a5,8000297e <kill+0x74>
    80002962:	854a                	mv	a0,s2
    80002964:	ffffe097          	auipc	ra,0xffffe
    80002968:	4f8080e7          	jalr	1272(ra) # 80000e5c <release>
    8000296c:	4501                	li	a0,0
    8000296e:	70a2                	ld	ra,40(sp)
    80002970:	7402                	ld	s0,32(sp)
    80002972:	64e2                	ld	s1,24(sp)
    80002974:	6942                	ld	s2,16(sp)
    80002976:	69a2                	ld	s3,8(sp)
    80002978:	6a02                	ld	s4,0(sp)
    8000297a:	6145                	addi	sp,sp,48
    8000297c:	8082                	ret
    8000297e:	1ac4a703          	lw	a4,428(s1)
    80002982:	00006797          	auipc	a5,0x6
    80002986:	2ae7a783          	lw	a5,686(a5) # 80008c30 <ticks>
    8000298a:	9f99                	subw	a5,a5,a4
    8000298c:	1af4a423          	sw	a5,424(s1)
    80002990:	478d                	li	a5,3
    80002992:	d09c                	sw	a5,32(s1)
    80002994:	b7f9                	j	80002962 <kill+0x58>

0000000080002996 <setkilled>:
    80002996:	1101                	addi	sp,sp,-32
    80002998:	ec06                	sd	ra,24(sp)
    8000299a:	e822                	sd	s0,16(sp)
    8000299c:	e426                	sd	s1,8(sp)
    8000299e:	e04a                	sd	s2,0(sp)
    800029a0:	1000                	addi	s0,sp,32
    800029a2:	84aa                	mv	s1,a0
    800029a4:	00850913          	addi	s2,a0,8
    800029a8:	854a                	mv	a0,s2
    800029aa:	ffffe097          	auipc	ra,0xffffe
    800029ae:	3fe080e7          	jalr	1022(ra) # 80000da8 <acquire>
    800029b2:	4785                	li	a5,1
    800029b4:	d89c                	sw	a5,48(s1)
    800029b6:	854a                	mv	a0,s2
    800029b8:	ffffe097          	auipc	ra,0xffffe
    800029bc:	4a4080e7          	jalr	1188(ra) # 80000e5c <release>
    800029c0:	60e2                	ld	ra,24(sp)
    800029c2:	6442                	ld	s0,16(sp)
    800029c4:	64a2                	ld	s1,8(sp)
    800029c6:	6902                	ld	s2,0(sp)
    800029c8:	6105                	addi	sp,sp,32
    800029ca:	8082                	ret

00000000800029cc <killed>:
    800029cc:	1101                	addi	sp,sp,-32
    800029ce:	ec06                	sd	ra,24(sp)
    800029d0:	e822                	sd	s0,16(sp)
    800029d2:	e426                	sd	s1,8(sp)
    800029d4:	e04a                	sd	s2,0(sp)
    800029d6:	1000                	addi	s0,sp,32
    800029d8:	84aa                	mv	s1,a0
    800029da:	00850913          	addi	s2,a0,8
    800029de:	854a                	mv	a0,s2
    800029e0:	ffffe097          	auipc	ra,0xffffe
    800029e4:	3c8080e7          	jalr	968(ra) # 80000da8 <acquire>
    800029e8:	5884                	lw	s1,48(s1)
    800029ea:	854a                	mv	a0,s2
    800029ec:	ffffe097          	auipc	ra,0xffffe
    800029f0:	470080e7          	jalr	1136(ra) # 80000e5c <release>
    800029f4:	8526                	mv	a0,s1
    800029f6:	60e2                	ld	ra,24(sp)
    800029f8:	6442                	ld	s0,16(sp)
    800029fa:	64a2                	ld	s1,8(sp)
    800029fc:	6902                	ld	s2,0(sp)
    800029fe:	6105                	addi	sp,sp,32
    80002a00:	8082                	ret

0000000080002a02 <either_copyout>:
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
    80002a1a:	fffff097          	auipc	ra,0xfffff
    80002a1e:	29e080e7          	jalr	670(ra) # 80001cb8 <myproc>
    80002a22:	c08d                	beqz	s1,80002a44 <either_copyout+0x42>
    80002a24:	86d2                	mv	a3,s4
    80002a26:	864e                	mv	a2,s3
    80002a28:	85ca                	mv	a1,s2
    80002a2a:	6d28                	ld	a0,88(a0)
    80002a2c:	fffff097          	auipc	ra,0xfffff
    80002a30:	e0c080e7          	jalr	-500(ra) # 80001838 <copyout>
    80002a34:	70a2                	ld	ra,40(sp)
    80002a36:	7402                	ld	s0,32(sp)
    80002a38:	64e2                	ld	s1,24(sp)
    80002a3a:	6942                	ld	s2,16(sp)
    80002a3c:	69a2                	ld	s3,8(sp)
    80002a3e:	6a02                	ld	s4,0(sp)
    80002a40:	6145                	addi	sp,sp,48
    80002a42:	8082                	ret
    80002a44:	000a061b          	sext.w	a2,s4
    80002a48:	85ce                	mv	a1,s3
    80002a4a:	854a                	mv	a0,s2
    80002a4c:	ffffe097          	auipc	ra,0xffffe
    80002a50:	4b8080e7          	jalr	1208(ra) # 80000f04 <memmove>
    80002a54:	8526                	mv	a0,s1
    80002a56:	bff9                	j	80002a34 <either_copyout+0x32>

0000000080002a58 <either_copyin>:
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
    80002a70:	fffff097          	auipc	ra,0xfffff
    80002a74:	248080e7          	jalr	584(ra) # 80001cb8 <myproc>
    80002a78:	c08d                	beqz	s1,80002a9a <either_copyin+0x42>
    80002a7a:	86d2                	mv	a3,s4
    80002a7c:	864e                	mv	a2,s3
    80002a7e:	85ca                	mv	a1,s2
    80002a80:	6d28                	ld	a0,88(a0)
    80002a82:	fffff097          	auipc	ra,0xfffff
    80002a86:	e76080e7          	jalr	-394(ra) # 800018f8 <copyin>
    80002a8a:	70a2                	ld	ra,40(sp)
    80002a8c:	7402                	ld	s0,32(sp)
    80002a8e:	64e2                	ld	s1,24(sp)
    80002a90:	6942                	ld	s2,16(sp)
    80002a92:	69a2                	ld	s3,8(sp)
    80002a94:	6a02                	ld	s4,0(sp)
    80002a96:	6145                	addi	sp,sp,48
    80002a98:	8082                	ret
    80002a9a:	000a061b          	sext.w	a2,s4
    80002a9e:	85ce                	mv	a1,s3
    80002aa0:	854a                	mv	a0,s2
    80002aa2:	ffffe097          	auipc	ra,0xffffe
    80002aa6:	462080e7          	jalr	1122(ra) # 80000f04 <memmove>
    80002aaa:	8526                	mv	a0,s1
    80002aac:	bff9                	j	80002a8a <either_copyin+0x32>

0000000080002aae <procdump>:
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
    80002ac4:	00005517          	auipc	a0,0x5
    80002ac8:	63450513          	addi	a0,a0,1588 # 800080f8 <digits+0xb8>
    80002acc:	ffffe097          	auipc	ra,0xffffe
    80002ad0:	ac2080e7          	jalr	-1342(ra) # 8000058e <printf>
    80002ad4:	0066f497          	auipc	s1,0x66f
    80002ad8:	97448493          	addi	s1,s1,-1676 # 80671448 <proc+0x160>
    80002adc:	00676917          	auipc	s2,0x676
    80002ae0:	56c90913          	addi	s2,s2,1388 # 80679048 <bcache+0x148>
    80002ae4:	4b15                	li	s6,5
    80002ae6:	00005997          	auipc	s3,0x5
    80002aea:	7e298993          	addi	s3,s3,2018 # 800082c8 <digits+0x288>
    80002aee:	00005a97          	auipc	s5,0x5
    80002af2:	7e2a8a93          	addi	s5,s5,2018 # 800082d0 <digits+0x290>
    80002af6:	00005a17          	auipc	s4,0x5
    80002afa:	602a0a13          	addi	s4,s4,1538 # 800080f8 <digits+0xb8>
    80002afe:	00006b97          	auipc	s7,0x6
    80002b02:	812b8b93          	addi	s7,s7,-2030 # 80008310 <states.2512>
    80002b06:	a01d                	j	80002b2c <procdump+0x7e>
    80002b08:	4afc                	lw	a5,84(a3)
    80002b0a:	5ed8                	lw	a4,60(a3)
    80002b0c:	ed86a583          	lw	a1,-296(a3)
    80002b10:	8556                	mv	a0,s5
    80002b12:	ffffe097          	auipc	ra,0xffffe
    80002b16:	a7c080e7          	jalr	-1412(ra) # 8000058e <printf>
    80002b1a:	8552                	mv	a0,s4
    80002b1c:	ffffe097          	auipc	ra,0xffffe
    80002b20:	a72080e7          	jalr	-1422(ra) # 8000058e <printf>
    80002b24:	1f048493          	addi	s1,s1,496
    80002b28:	03248163          	beq	s1,s2,80002b4a <procdump+0x9c>
    80002b2c:	86a6                	mv	a3,s1
    80002b2e:	ec04a783          	lw	a5,-320(s1)
    80002b32:	dbed                	beqz	a5,80002b24 <procdump+0x76>
    80002b34:	864e                	mv	a2,s3
    80002b36:	fcfb69e3          	bltu	s6,a5,80002b08 <procdump+0x5a>
    80002b3a:	1782                	slli	a5,a5,0x20
    80002b3c:	9381                	srli	a5,a5,0x20
    80002b3e:	078e                	slli	a5,a5,0x3
    80002b40:	97de                	add	a5,a5,s7
    80002b42:	6390                	ld	a2,0(a5)
    80002b44:	f271                	bnez	a2,80002b08 <procdump+0x5a>
    80002b46:	864e                	mv	a2,s3
    80002b48:	b7c1                	j	80002b08 <procdump+0x5a>
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
    80002bd6:	76e58593          	addi	a1,a1,1902 # 80008340 <states.2512+0x30>
    80002bda:	00676517          	auipc	a0,0x676
    80002bde:	30e50513          	addi	a0,a0,782 # 80678ee8 <tickslock>
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
// Supervisor Trap-Vector Base Address
// low two bits are mode.
static inline void 
w_stvec(uint64 x)
{
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002bf8:	00004797          	auipc	a5,0x4
    80002bfc:	91878793          	addi	a5,a5,-1768 # 80006510 <kernelvec>
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

// disable device interrupts
static inline void
intr_off()
{
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
// this core's hartid (core number), the index into cpus[].
static inline uint64
r_tp()
{
  uint64 x;
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
    80002d4a:	00676917          	auipc	s2,0x676
    80002d4e:	19e90913          	addi	s2,s2,414 # 80678ee8 <tickslock>
    80002d52:	854a                	mv	a0,s2
    80002d54:	ffffe097          	auipc	ra,0xffffe
    80002d58:	054080e7          	jalr	84(ra) # 80000da8 <acquire>
	ticks++;
    80002d5c:	00006497          	auipc	s1,0x6
    80002d60:	ed448493          	addi	s1,s1,-300 # 80008c30 <ticks>
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
    80002dc4:	00004097          	auipc	ra,0x4
    80002dc8:	854080e7          	jalr	-1964(ra) # 80006618 <plic_claim>
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
    80002de4:	56850513          	addi	a0,a0,1384 # 80008348 <states.2512+0x38>
    80002de8:	ffffd097          	auipc	ra,0xffffd
    80002dec:	7a6080e7          	jalr	1958(ra) # 8000058e <printf>
			plic_complete(irq);
    80002df0:	8526                	mv	a0,s1
    80002df2:	00004097          	auipc	ra,0x4
    80002df6:	84a080e7          	jalr	-1974(ra) # 8000663c <plic_complete>
		return 1;
    80002dfa:	4505                	li	a0,1
    80002dfc:	bf55                	j	80002db0 <devintr+0x1e>
			uartintr();
    80002dfe:	ffffe097          	auipc	ra,0xffffe
    80002e02:	bb0080e7          	jalr	-1104(ra) # 800009ae <uartintr>
    80002e06:	b7ed                	j	80002df0 <devintr+0x5e>
			virtio_disk_intr();
    80002e08:	00004097          	auipc	ra,0x4
    80002e0c:	d5e080e7          	jalr	-674(ra) # 80006b66 <virtio_disk_intr>
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
    80002e48:	efb5                	bnez	a5,80002ec4 <usertrap+0x90>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002e4a:	00003797          	auipc	a5,0x3
    80002e4e:	6c678793          	addi	a5,a5,1734 # 80006510 <kernelvec>
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
    80002e6e:	06f70363          	beq	a4,a5,80002ed4 <usertrap+0xa0>
    80002e72:	14202773          	csrr	a4,scause
	else if (r_scause() == 15)
    80002e76:	47bd                	li	a5,15
    80002e78:	0af71563          	bne	a4,a5,80002f22 <usertrap+0xee>
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
	int which_dev = 0;
    80002eb2:	4901                	li	s2,0
		if (cowalloc(p->pagetable, PGROUNDDOWN(addr)) < 0)
    80002eb4:	04055163          	bgez	a0,80002ef6 <usertrap+0xc2>
			setkilled(p);
    80002eb8:	8526                	mv	a0,s1
    80002eba:	00000097          	auipc	ra,0x0
    80002ebe:	adc080e7          	jalr	-1316(ra) # 80002996 <setkilled>
    80002ec2:	a815                	j	80002ef6 <usertrap+0xc2>
		panic("usertrap: not from user mode");
    80002ec4:	00005517          	auipc	a0,0x5
    80002ec8:	4a450513          	addi	a0,a0,1188 # 80008368 <states.2512+0x58>
    80002ecc:	ffffd097          	auipc	ra,0xffffd
    80002ed0:	678080e7          	jalr	1656(ra) # 80000544 <panic>
		if (p->killed)
    80002ed4:	591c                	lw	a5,48(a0)
    80002ed6:	e3a1                	bnez	a5,80002f16 <usertrap+0xe2>
		p->trapframe->epc += 4;
    80002ed8:	70b8                	ld	a4,96(s1)
    80002eda:	6f1c                	ld	a5,24(a4)
    80002edc:	0791                	addi	a5,a5,4
    80002ede:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ee0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002ee4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ee8:	10079073          	csrw	sstatus,a5
		syscall();
    80002eec:	00000097          	auipc	ra,0x0
    80002ef0:	344080e7          	jalr	836(ra) # 80003230 <syscall>
	int which_dev = 0;
    80002ef4:	4901                	li	s2,0
	if (killed(p))
    80002ef6:	8526                	mv	a0,s1
    80002ef8:	00000097          	auipc	ra,0x0
    80002efc:	ad4080e7          	jalr	-1324(ra) # 800029cc <killed>
    80002f00:	e571                	bnez	a0,80002fcc <usertrap+0x198>
	usertrapret();
    80002f02:	00000097          	auipc	ra,0x0
    80002f06:	da6080e7          	jalr	-602(ra) # 80002ca8 <usertrapret>
}
    80002f0a:	60e2                	ld	ra,24(sp)
    80002f0c:	6442                	ld	s0,16(sp)
    80002f0e:	64a2                	ld	s1,8(sp)
    80002f10:	6902                	ld	s2,0(sp)
    80002f12:	6105                	addi	sp,sp,32
    80002f14:	8082                	ret
			exit(-1);
    80002f16:	557d                	li	a0,-1
    80002f18:	00000097          	auipc	ra,0x0
    80002f1c:	90e080e7          	jalr	-1778(ra) # 80002826 <exit>
    80002f20:	bf65                	j	80002ed8 <usertrap+0xa4>
	else if ((which_dev = devintr()) != 0)
    80002f22:	00000097          	auipc	ra,0x0
    80002f26:	e70080e7          	jalr	-400(ra) # 80002d92 <devintr>
    80002f2a:	892a                	mv	s2,a0
    80002f2c:	c13d                	beqz	a0,80002f92 <usertrap+0x15e>
		if (p != 0 && which_dev == 2 && p->checkifAlarmOn == 0)
    80002f2e:	4789                	li	a5,2
    80002f30:	fcf513e3          	bne	a0,a5,80002ef6 <usertrap+0xc2>
    80002f34:	1804a783          	lw	a5,384(s1)
    80002f38:	cf89                	beqz	a5,80002f52 <usertrap+0x11e>
	if (killed(p))
    80002f3a:	8526                	mv	a0,s1
    80002f3c:	00000097          	auipc	ra,0x0
    80002f40:	a90080e7          	jalr	-1392(ra) # 800029cc <killed>
    80002f44:	cd41                	beqz	a0,80002fdc <usertrap+0x1a8>
		exit(-1);
    80002f46:	557d                	li	a0,-1
    80002f48:	00000097          	auipc	ra,0x0
    80002f4c:	8de080e7          	jalr	-1826(ra) # 80002826 <exit>
	if (which_dev == 2)
    80002f50:	a071                	j	80002fdc <usertrap+0x1a8>
			struct trapframe *tf = kalloc();
    80002f52:	ffffe097          	auipc	ra,0xffffe
    80002f56:	d22080e7          	jalr	-734(ra) # 80000c74 <kalloc>
    80002f5a:	892a                	mv	s2,a0
			memmove(tf, p->trapframe, PGSIZE);
    80002f5c:	6605                	lui	a2,0x1
    80002f5e:	70ac                	ld	a1,96(s1)
    80002f60:	ffffe097          	auipc	ra,0xffffe
    80002f64:	fa4080e7          	jalr	-92(ra) # 80000f04 <memmove>
			p->alarm_handler = tf;
    80002f68:	1724b823          	sd	s2,368(s1)
			p->sigticks++;
    80002f6c:	1844a783          	lw	a5,388(s1)
    80002f70:	2785                	addiw	a5,a5,1
    80002f72:	0007871b          	sext.w	a4,a5
    80002f76:	18f4a223          	sw	a5,388(s1)
			if (p->sigticks >= p->maxticks)
    80002f7a:	1884a783          	lw	a5,392(s1)
    80002f7e:	faf74ee3          	blt	a4,a5,80002f3a <usertrap+0x106>
				p->checkifAlarmOn = 1;
    80002f82:	4785                	li	a5,1
    80002f84:	18f4a023          	sw	a5,384(s1)
				p->trapframe->epc = p->handler;
    80002f88:	70bc                	ld	a5,96(s1)
    80002f8a:	1784b703          	ld	a4,376(s1)
    80002f8e:	ef98                	sd	a4,24(a5)
    80002f90:	b76d                	j	80002f3a <usertrap+0x106>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f92:	142025f3          	csrr	a1,scause
		printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002f96:	5c90                	lw	a2,56(s1)
    80002f98:	00005517          	auipc	a0,0x5
    80002f9c:	3f050513          	addi	a0,a0,1008 # 80008388 <states.2512+0x78>
    80002fa0:	ffffd097          	auipc	ra,0xffffd
    80002fa4:	5ee080e7          	jalr	1518(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002fa8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002fac:	14302673          	csrr	a2,stval
		printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002fb0:	00005517          	auipc	a0,0x5
    80002fb4:	40850513          	addi	a0,a0,1032 # 800083b8 <states.2512+0xa8>
    80002fb8:	ffffd097          	auipc	ra,0xffffd
    80002fbc:	5d6080e7          	jalr	1494(ra) # 8000058e <printf>
		setkilled(p);
    80002fc0:	8526                	mv	a0,s1
    80002fc2:	00000097          	auipc	ra,0x0
    80002fc6:	9d4080e7          	jalr	-1580(ra) # 80002996 <setkilled>
    80002fca:	b735                	j	80002ef6 <usertrap+0xc2>
		exit(-1);
    80002fcc:	557d                	li	a0,-1
    80002fce:	00000097          	auipc	ra,0x0
    80002fd2:	858080e7          	jalr	-1960(ra) # 80002826 <exit>
	if (which_dev == 2)
    80002fd6:	4789                	li	a5,2
    80002fd8:	f2f915e3          	bne	s2,a5,80002f02 <usertrap+0xce>
		yield();
    80002fdc:	fffff097          	auipc	ra,0xfffff
    80002fe0:	406080e7          	jalr	1030(ra) # 800023e2 <yield>
    80002fe4:	bf39                	j	80002f02 <usertrap+0xce>

0000000080002fe6 <kerneltrap>:
{
    80002fe6:	7179                	addi	sp,sp,-48
    80002fe8:	f406                	sd	ra,40(sp)
    80002fea:	f022                	sd	s0,32(sp)
    80002fec:	ec26                	sd	s1,24(sp)
    80002fee:	e84a                	sd	s2,16(sp)
    80002ff0:	e44e                	sd	s3,8(sp)
    80002ff2:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ff4:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ff8:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ffc:	142029f3          	csrr	s3,scause
	if ((sstatus & SSTATUS_SPP) == 0)
    80003000:	1004f793          	andi	a5,s1,256
    80003004:	cb85                	beqz	a5,80003034 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003006:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000300a:	8b89                	andi	a5,a5,2
	if (intr_get() != 0)
    8000300c:	ef85                	bnez	a5,80003044 <kerneltrap+0x5e>
	if ((which_dev = devintr()) == 0)
    8000300e:	00000097          	auipc	ra,0x0
    80003012:	d84080e7          	jalr	-636(ra) # 80002d92 <devintr>
    80003016:	cd1d                	beqz	a0,80003054 <kerneltrap+0x6e>
	if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003018:	4789                	li	a5,2
    8000301a:	06f50a63          	beq	a0,a5,8000308e <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000301e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003022:	10049073          	csrw	sstatus,s1
}
    80003026:	70a2                	ld	ra,40(sp)
    80003028:	7402                	ld	s0,32(sp)
    8000302a:	64e2                	ld	s1,24(sp)
    8000302c:	6942                	ld	s2,16(sp)
    8000302e:	69a2                	ld	s3,8(sp)
    80003030:	6145                	addi	sp,sp,48
    80003032:	8082                	ret
		panic("kerneltrap: not from supervisor mode");
    80003034:	00005517          	auipc	a0,0x5
    80003038:	3a450513          	addi	a0,a0,932 # 800083d8 <states.2512+0xc8>
    8000303c:	ffffd097          	auipc	ra,0xffffd
    80003040:	508080e7          	jalr	1288(ra) # 80000544 <panic>
		panic("kerneltrap: interrupts enabled");
    80003044:	00005517          	auipc	a0,0x5
    80003048:	3bc50513          	addi	a0,a0,956 # 80008400 <states.2512+0xf0>
    8000304c:	ffffd097          	auipc	ra,0xffffd
    80003050:	4f8080e7          	jalr	1272(ra) # 80000544 <panic>
		printf("scause %p\n", scause);
    80003054:	85ce                	mv	a1,s3
    80003056:	00005517          	auipc	a0,0x5
    8000305a:	3ca50513          	addi	a0,a0,970 # 80008420 <states.2512+0x110>
    8000305e:	ffffd097          	auipc	ra,0xffffd
    80003062:	530080e7          	jalr	1328(ra) # 8000058e <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003066:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000306a:	14302673          	csrr	a2,stval
		printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000306e:	00005517          	auipc	a0,0x5
    80003072:	3c250513          	addi	a0,a0,962 # 80008430 <states.2512+0x120>
    80003076:	ffffd097          	auipc	ra,0xffffd
    8000307a:	518080e7          	jalr	1304(ra) # 8000058e <printf>
		panic("kerneltrap");
    8000307e:	00005517          	auipc	a0,0x5
    80003082:	3ca50513          	addi	a0,a0,970 # 80008448 <states.2512+0x138>
    80003086:	ffffd097          	auipc	ra,0xffffd
    8000308a:	4be080e7          	jalr	1214(ra) # 80000544 <panic>
	if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000308e:	fffff097          	auipc	ra,0xfffff
    80003092:	c2a080e7          	jalr	-982(ra) # 80001cb8 <myproc>
    80003096:	d541                	beqz	a0,8000301e <kerneltrap+0x38>
    80003098:	fffff097          	auipc	ra,0xfffff
    8000309c:	c20080e7          	jalr	-992(ra) # 80001cb8 <myproc>
    800030a0:	5118                	lw	a4,32(a0)
    800030a2:	4791                	li	a5,4
    800030a4:	f6f71de3          	bne	a4,a5,8000301e <kerneltrap+0x38>
		yield();
    800030a8:	fffff097          	auipc	ra,0xfffff
    800030ac:	33a080e7          	jalr	826(ra) # 800023e2 <yield>
    800030b0:	b7bd                	j	8000301e <kerneltrap+0x38>

00000000800030b2 <argraw>:
    800030b2:	1101                	addi	sp,sp,-32
    800030b4:	ec06                	sd	ra,24(sp)
    800030b6:	e822                	sd	s0,16(sp)
    800030b8:	e426                	sd	s1,8(sp)
    800030ba:	1000                	addi	s0,sp,32
    800030bc:	84aa                	mv	s1,a0
    800030be:	fffff097          	auipc	ra,0xfffff
    800030c2:	bfa080e7          	jalr	-1030(ra) # 80001cb8 <myproc>
    800030c6:	4795                	li	a5,5
    800030c8:	0497e163          	bltu	a5,s1,8000310a <argraw+0x58>
    800030cc:	048a                	slli	s1,s1,0x2
    800030ce:	00005717          	auipc	a4,0x5
    800030d2:	4d270713          	addi	a4,a4,1234 # 800085a0 <states.2512+0x290>
    800030d6:	94ba                	add	s1,s1,a4
    800030d8:	409c                	lw	a5,0(s1)
    800030da:	97ba                	add	a5,a5,a4
    800030dc:	8782                	jr	a5
    800030de:	713c                	ld	a5,96(a0)
    800030e0:	7ba8                	ld	a0,112(a5)
    800030e2:	60e2                	ld	ra,24(sp)
    800030e4:	6442                	ld	s0,16(sp)
    800030e6:	64a2                	ld	s1,8(sp)
    800030e8:	6105                	addi	sp,sp,32
    800030ea:	8082                	ret
    800030ec:	713c                	ld	a5,96(a0)
    800030ee:	7fa8                	ld	a0,120(a5)
    800030f0:	bfcd                	j	800030e2 <argraw+0x30>
    800030f2:	713c                	ld	a5,96(a0)
    800030f4:	63c8                	ld	a0,128(a5)
    800030f6:	b7f5                	j	800030e2 <argraw+0x30>
    800030f8:	713c                	ld	a5,96(a0)
    800030fa:	67c8                	ld	a0,136(a5)
    800030fc:	b7dd                	j	800030e2 <argraw+0x30>
    800030fe:	713c                	ld	a5,96(a0)
    80003100:	6bc8                	ld	a0,144(a5)
    80003102:	b7c5                	j	800030e2 <argraw+0x30>
    80003104:	713c                	ld	a5,96(a0)
    80003106:	6fc8                	ld	a0,152(a5)
    80003108:	bfe9                	j	800030e2 <argraw+0x30>
    8000310a:	00005517          	auipc	a0,0x5
    8000310e:	34e50513          	addi	a0,a0,846 # 80008458 <states.2512+0x148>
    80003112:	ffffd097          	auipc	ra,0xffffd
    80003116:	432080e7          	jalr	1074(ra) # 80000544 <panic>

000000008000311a <fetchaddr>:
    8000311a:	1101                	addi	sp,sp,-32
    8000311c:	ec06                	sd	ra,24(sp)
    8000311e:	e822                	sd	s0,16(sp)
    80003120:	e426                	sd	s1,8(sp)
    80003122:	e04a                	sd	s2,0(sp)
    80003124:	1000                	addi	s0,sp,32
    80003126:	84aa                	mv	s1,a0
    80003128:	892e                	mv	s2,a1
    8000312a:	fffff097          	auipc	ra,0xfffff
    8000312e:	b8e080e7          	jalr	-1138(ra) # 80001cb8 <myproc>
    80003132:	693c                	ld	a5,80(a0)
    80003134:	02f4f863          	bgeu	s1,a5,80003164 <fetchaddr+0x4a>
    80003138:	00848713          	addi	a4,s1,8
    8000313c:	02e7e663          	bltu	a5,a4,80003168 <fetchaddr+0x4e>
    80003140:	46a1                	li	a3,8
    80003142:	8626                	mv	a2,s1
    80003144:	85ca                	mv	a1,s2
    80003146:	6d28                	ld	a0,88(a0)
    80003148:	ffffe097          	auipc	ra,0xffffe
    8000314c:	7b0080e7          	jalr	1968(ra) # 800018f8 <copyin>
    80003150:	00a03533          	snez	a0,a0
    80003154:	40a00533          	neg	a0,a0
    80003158:	60e2                	ld	ra,24(sp)
    8000315a:	6442                	ld	s0,16(sp)
    8000315c:	64a2                	ld	s1,8(sp)
    8000315e:	6902                	ld	s2,0(sp)
    80003160:	6105                	addi	sp,sp,32
    80003162:	8082                	ret
    80003164:	557d                	li	a0,-1
    80003166:	bfcd                	j	80003158 <fetchaddr+0x3e>
    80003168:	557d                	li	a0,-1
    8000316a:	b7fd                	j	80003158 <fetchaddr+0x3e>

000000008000316c <fetchstr>:
    8000316c:	7179                	addi	sp,sp,-48
    8000316e:	f406                	sd	ra,40(sp)
    80003170:	f022                	sd	s0,32(sp)
    80003172:	ec26                	sd	s1,24(sp)
    80003174:	e84a                	sd	s2,16(sp)
    80003176:	e44e                	sd	s3,8(sp)
    80003178:	1800                	addi	s0,sp,48
    8000317a:	892a                	mv	s2,a0
    8000317c:	84ae                	mv	s1,a1
    8000317e:	89b2                	mv	s3,a2
    80003180:	fffff097          	auipc	ra,0xfffff
    80003184:	b38080e7          	jalr	-1224(ra) # 80001cb8 <myproc>
    80003188:	86ce                	mv	a3,s3
    8000318a:	864a                	mv	a2,s2
    8000318c:	85a6                	mv	a1,s1
    8000318e:	6d28                	ld	a0,88(a0)
    80003190:	ffffe097          	auipc	ra,0xffffe
    80003194:	7f4080e7          	jalr	2036(ra) # 80001984 <copyinstr>
    80003198:	00054e63          	bltz	a0,800031b4 <fetchstr+0x48>
    8000319c:	8526                	mv	a0,s1
    8000319e:	ffffe097          	auipc	ra,0xffffe
    800031a2:	e8a080e7          	jalr	-374(ra) # 80001028 <strlen>
    800031a6:	70a2                	ld	ra,40(sp)
    800031a8:	7402                	ld	s0,32(sp)
    800031aa:	64e2                	ld	s1,24(sp)
    800031ac:	6942                	ld	s2,16(sp)
    800031ae:	69a2                	ld	s3,8(sp)
    800031b0:	6145                	addi	sp,sp,48
    800031b2:	8082                	ret
    800031b4:	557d                	li	a0,-1
    800031b6:	bfc5                	j	800031a6 <fetchstr+0x3a>

00000000800031b8 <argint>:
    800031b8:	1101                	addi	sp,sp,-32
    800031ba:	ec06                	sd	ra,24(sp)
    800031bc:	e822                	sd	s0,16(sp)
    800031be:	e426                	sd	s1,8(sp)
    800031c0:	1000                	addi	s0,sp,32
    800031c2:	84ae                	mv	s1,a1
    800031c4:	00000097          	auipc	ra,0x0
    800031c8:	eee080e7          	jalr	-274(ra) # 800030b2 <argraw>
    800031cc:	c088                	sw	a0,0(s1)
    800031ce:	60e2                	ld	ra,24(sp)
    800031d0:	6442                	ld	s0,16(sp)
    800031d2:	64a2                	ld	s1,8(sp)
    800031d4:	6105                	addi	sp,sp,32
    800031d6:	8082                	ret

00000000800031d8 <argaddr>:
    800031d8:	1101                	addi	sp,sp,-32
    800031da:	ec06                	sd	ra,24(sp)
    800031dc:	e822                	sd	s0,16(sp)
    800031de:	e426                	sd	s1,8(sp)
    800031e0:	1000                	addi	s0,sp,32
    800031e2:	84ae                	mv	s1,a1
    800031e4:	00000097          	auipc	ra,0x0
    800031e8:	ece080e7          	jalr	-306(ra) # 800030b2 <argraw>
    800031ec:	e088                	sd	a0,0(s1)
    800031ee:	60e2                	ld	ra,24(sp)
    800031f0:	6442                	ld	s0,16(sp)
    800031f2:	64a2                	ld	s1,8(sp)
    800031f4:	6105                	addi	sp,sp,32
    800031f6:	8082                	ret

00000000800031f8 <argstr>:
    800031f8:	7179                	addi	sp,sp,-48
    800031fa:	f406                	sd	ra,40(sp)
    800031fc:	f022                	sd	s0,32(sp)
    800031fe:	ec26                	sd	s1,24(sp)
    80003200:	e84a                	sd	s2,16(sp)
    80003202:	1800                	addi	s0,sp,48
    80003204:	84ae                	mv	s1,a1
    80003206:	8932                	mv	s2,a2
    80003208:	fd840593          	addi	a1,s0,-40
    8000320c:	00000097          	auipc	ra,0x0
    80003210:	fcc080e7          	jalr	-52(ra) # 800031d8 <argaddr>
    80003214:	864a                	mv	a2,s2
    80003216:	85a6                	mv	a1,s1
    80003218:	fd843503          	ld	a0,-40(s0)
    8000321c:	00000097          	auipc	ra,0x0
    80003220:	f50080e7          	jalr	-176(ra) # 8000316c <fetchstr>
    80003224:	70a2                	ld	ra,40(sp)
    80003226:	7402                	ld	s0,32(sp)
    80003228:	64e2                	ld	s1,24(sp)
    8000322a:	6942                	ld	s2,16(sp)
    8000322c:	6145                	addi	sp,sp,48
    8000322e:	8082                	ret

0000000080003230 <syscall>:
    80003230:	711d                	addi	sp,sp,-96
    80003232:	ec86                	sd	ra,88(sp)
    80003234:	e8a2                	sd	s0,80(sp)
    80003236:	e4a6                	sd	s1,72(sp)
    80003238:	e0ca                	sd	s2,64(sp)
    8000323a:	fc4e                	sd	s3,56(sp)
    8000323c:	f852                	sd	s4,48(sp)
    8000323e:	f456                	sd	s5,40(sp)
    80003240:	f05a                	sd	s6,32(sp)
    80003242:	ec5e                	sd	s7,24(sp)
    80003244:	e862                	sd	s8,16(sp)
    80003246:	e466                	sd	s9,8(sp)
    80003248:	e06a                	sd	s10,0(sp)
    8000324a:	1080                	addi	s0,sp,96
    8000324c:	fffff097          	auipc	ra,0xfffff
    80003250:	a6c080e7          	jalr	-1428(ra) # 80001cb8 <myproc>
    80003254:	8a2a                	mv	s4,a0
    80003256:	7124                	ld	s1,96(a0)
    80003258:	74dc                	ld	a5,168(s1)
    8000325a:	00078b1b          	sext.w	s6,a5
    8000325e:	37fd                	addiw	a5,a5,-1
    80003260:	4769                	li	a4,26
    80003262:	06f76f63          	bltu	a4,a5,800032e0 <syscall+0xb0>
    80003266:	003b1713          	slli	a4,s6,0x3
    8000326a:	00005797          	auipc	a5,0x5
    8000326e:	34e78793          	addi	a5,a5,846 # 800085b8 <syscalls>
    80003272:	97ba                	add	a5,a5,a4
    80003274:	0007bd03          	ld	s10,0(a5)
    80003278:	060d0463          	beqz	s10,800032e0 <syscall+0xb0>
    8000327c:	8c8a                	mv	s9,sp
    8000327e:	fffb0c1b          	addiw	s8,s6,-1
    80003282:	004c1713          	slli	a4,s8,0x4
    80003286:	00005797          	auipc	a5,0x5
    8000328a:	79278793          	addi	a5,a5,1938 # 80008a18 <syscall_info>
    8000328e:	97ba                	add	a5,a5,a4
    80003290:	0087a983          	lw	s3,8(a5)
    80003294:	00299793          	slli	a5,s3,0x2
    80003298:	07bd                	addi	a5,a5,15
    8000329a:	9bc1                	andi	a5,a5,-16
    8000329c:	40f10133          	sub	sp,sp,a5
    800032a0:	8b8a                	mv	s7,sp
    800032a2:	11305363          	blez	s3,800033a8 <syscall+0x178>
    800032a6:	8ade                	mv	s5,s7
    800032a8:	895e                	mv	s2,s7
    800032aa:	4481                	li	s1,0
    800032ac:	8526                	mv	a0,s1
    800032ae:	00000097          	auipc	ra,0x0
    800032b2:	e04080e7          	jalr	-508(ra) # 800030b2 <argraw>
    800032b6:	00a92023          	sw	a0,0(s2)
    800032ba:	2485                	addiw	s1,s1,1
    800032bc:	0911                	addi	s2,s2,4
    800032be:	fe9997e3          	bne	s3,s1,800032ac <syscall+0x7c>
    800032c2:	060a3483          	ld	s1,96(s4)
    800032c6:	9d02                	jalr	s10
    800032c8:	f8a8                	sd	a0,112(s1)
    800032ca:	4785                	li	a5,1
    800032cc:	016797bb          	sllw	a5,a5,s6
    800032d0:	000a2b03          	lw	s6,0(s4)
    800032d4:	0167f7b3          	and	a5,a5,s6
    800032d8:	2781                	sext.w	a5,a5
    800032da:	e7a1                	bnez	a5,80003322 <syscall+0xf2>
    800032dc:	8166                	mv	sp,s9
    800032de:	a015                	j	80003302 <syscall+0xd2>
    800032e0:	86da                	mv	a3,s6
    800032e2:	160a0613          	addi	a2,s4,352
    800032e6:	038a2583          	lw	a1,56(s4)
    800032ea:	00005517          	auipc	a0,0x5
    800032ee:	18e50513          	addi	a0,a0,398 # 80008478 <states.2512+0x168>
    800032f2:	ffffd097          	auipc	ra,0xffffd
    800032f6:	29c080e7          	jalr	668(ra) # 8000058e <printf>
    800032fa:	060a3783          	ld	a5,96(s4)
    800032fe:	577d                	li	a4,-1
    80003300:	fbb8                	sd	a4,112(a5)
    80003302:	fa040113          	addi	sp,s0,-96
    80003306:	60e6                	ld	ra,88(sp)
    80003308:	6446                	ld	s0,80(sp)
    8000330a:	64a6                	ld	s1,72(sp)
    8000330c:	6906                	ld	s2,64(sp)
    8000330e:	79e2                	ld	s3,56(sp)
    80003310:	7a42                	ld	s4,48(sp)
    80003312:	7aa2                	ld	s5,40(sp)
    80003314:	7b02                	ld	s6,32(sp)
    80003316:	6be2                	ld	s7,24(sp)
    80003318:	6c42                	ld	s8,16(sp)
    8000331a:	6ca2                	ld	s9,8(sp)
    8000331c:	6d02                	ld	s10,0(sp)
    8000331e:	6125                	addi	sp,sp,96
    80003320:	8082                	ret
    80003322:	0c12                	slli	s8,s8,0x4
    80003324:	00005797          	auipc	a5,0x5
    80003328:	6f478793          	addi	a5,a5,1780 # 80008a18 <syscall_info>
    8000332c:	9c3e                	add	s8,s8,a5
    8000332e:	000c3603          	ld	a2,0(s8)
    80003332:	038a2583          	lw	a1,56(s4)
    80003336:	00005517          	auipc	a0,0x5
    8000333a:	16250513          	addi	a0,a0,354 # 80008498 <states.2512+0x188>
    8000333e:	ffffd097          	auipc	ra,0xffffd
    80003342:	250080e7          	jalr	592(ra) # 8000058e <printf>
    80003346:	00005517          	auipc	a0,0x5
    8000334a:	16250513          	addi	a0,a0,354 # 800084a8 <states.2512+0x198>
    8000334e:	ffffd097          	auipc	ra,0xffffd
    80003352:	240080e7          	jalr	576(ra) # 8000058e <printf>
    80003356:	fff9879b          	addiw	a5,s3,-1
    8000335a:	1782                	slli	a5,a5,0x20
    8000335c:	9381                	srli	a5,a5,0x20
    8000335e:	0785                	addi	a5,a5,1
    80003360:	078a                	slli	a5,a5,0x2
    80003362:	9bbe                	add	s7,s7,a5
    80003364:	00005497          	auipc	s1,0x5
    80003368:	0fc48493          	addi	s1,s1,252 # 80008460 <states.2512+0x150>
    8000336c:	000aa583          	lw	a1,0(s5)
    80003370:	8526                	mv	a0,s1
    80003372:	ffffd097          	auipc	ra,0xffffd
    80003376:	21c080e7          	jalr	540(ra) # 8000058e <printf>
    8000337a:	0a91                	addi	s5,s5,4
    8000337c:	ff7a98e3          	bne	s5,s7,8000336c <syscall+0x13c>
    80003380:	00005517          	auipc	a0,0x5
    80003384:	0e850513          	addi	a0,a0,232 # 80008468 <states.2512+0x158>
    80003388:	ffffd097          	auipc	ra,0xffffd
    8000338c:	206080e7          	jalr	518(ra) # 8000058e <printf>
    80003390:	060a3783          	ld	a5,96(s4)
    80003394:	7bac                	ld	a1,112(a5)
    80003396:	00005517          	auipc	a0,0x5
    8000339a:	0da50513          	addi	a0,a0,218 # 80008470 <states.2512+0x160>
    8000339e:	ffffd097          	auipc	ra,0xffffd
    800033a2:	1f0080e7          	jalr	496(ra) # 8000058e <printf>
    800033a6:	bf1d                	j	800032dc <syscall+0xac>
    800033a8:	9d02                	jalr	s10
    800033aa:	f8a8                	sd	a0,112(s1)
    800033ac:	4785                	li	a5,1
    800033ae:	016797bb          	sllw	a5,a5,s6
    800033b2:	000a2703          	lw	a4,0(s4)
    800033b6:	8ff9                	and	a5,a5,a4
    800033b8:	2781                	sext.w	a5,a5
    800033ba:	d38d                	beqz	a5,800032dc <syscall+0xac>
    800033bc:	0c12                	slli	s8,s8,0x4
    800033be:	00005797          	auipc	a5,0x5
    800033c2:	65a78793          	addi	a5,a5,1626 # 80008a18 <syscall_info>
    800033c6:	97e2                	add	a5,a5,s8
    800033c8:	6390                	ld	a2,0(a5)
    800033ca:	038a2583          	lw	a1,56(s4)
    800033ce:	00005517          	auipc	a0,0x5
    800033d2:	0ca50513          	addi	a0,a0,202 # 80008498 <states.2512+0x188>
    800033d6:	ffffd097          	auipc	ra,0xffffd
    800033da:	1b8080e7          	jalr	440(ra) # 8000058e <printf>
    800033de:	00005517          	auipc	a0,0x5
    800033e2:	0ca50513          	addi	a0,a0,202 # 800084a8 <states.2512+0x198>
    800033e6:	ffffd097          	auipc	ra,0xffffd
    800033ea:	1a8080e7          	jalr	424(ra) # 8000058e <printf>
    800033ee:	bf49                	j	80003380 <syscall+0x150>

00000000800033f0 <sys_exit>:
    800033f0:	1101                	addi	sp,sp,-32
    800033f2:	ec06                	sd	ra,24(sp)
    800033f4:	e822                	sd	s0,16(sp)
    800033f6:	1000                	addi	s0,sp,32
    800033f8:	fec40593          	addi	a1,s0,-20
    800033fc:	4501                	li	a0,0
    800033fe:	00000097          	auipc	ra,0x0
    80003402:	dba080e7          	jalr	-582(ra) # 800031b8 <argint>
    80003406:	fec42503          	lw	a0,-20(s0)
    8000340a:	fffff097          	auipc	ra,0xfffff
    8000340e:	41c080e7          	jalr	1052(ra) # 80002826 <exit>
    80003412:	4501                	li	a0,0
    80003414:	60e2                	ld	ra,24(sp)
    80003416:	6442                	ld	s0,16(sp)
    80003418:	6105                	addi	sp,sp,32
    8000341a:	8082                	ret

000000008000341c <sys_getpid>:
    8000341c:	1141                	addi	sp,sp,-16
    8000341e:	e406                	sd	ra,8(sp)
    80003420:	e022                	sd	s0,0(sp)
    80003422:	0800                	addi	s0,sp,16
    80003424:	fffff097          	auipc	ra,0xfffff
    80003428:	894080e7          	jalr	-1900(ra) # 80001cb8 <myproc>
    8000342c:	5d08                	lw	a0,56(a0)
    8000342e:	60a2                	ld	ra,8(sp)
    80003430:	6402                	ld	s0,0(sp)
    80003432:	0141                	addi	sp,sp,16
    80003434:	8082                	ret

0000000080003436 <sys_fork>:
    80003436:	1141                	addi	sp,sp,-16
    80003438:	e406                	sd	ra,8(sp)
    8000343a:	e022                	sd	s0,0(sp)
    8000343c:	0800                	addi	s0,sp,16
    8000343e:	fffff097          	auipc	ra,0xfffff
    80003442:	c6a080e7          	jalr	-918(ra) # 800020a8 <fork>
    80003446:	60a2                	ld	ra,8(sp)
    80003448:	6402                	ld	s0,0(sp)
    8000344a:	0141                	addi	sp,sp,16
    8000344c:	8082                	ret

000000008000344e <sys_wait>:
    8000344e:	1101                	addi	sp,sp,-32
    80003450:	ec06                	sd	ra,24(sp)
    80003452:	e822                	sd	s0,16(sp)
    80003454:	1000                	addi	s0,sp,32
    80003456:	fe840593          	addi	a1,s0,-24
    8000345a:	4501                	li	a0,0
    8000345c:	00000097          	auipc	ra,0x0
    80003460:	d7c080e7          	jalr	-644(ra) # 800031d8 <argaddr>
    80003464:	fe843503          	ld	a0,-24(s0)
    80003468:	fffff097          	auipc	ra,0xfffff
    8000346c:	182080e7          	jalr	386(ra) # 800025ea <wait>
    80003470:	60e2                	ld	ra,24(sp)
    80003472:	6442                	ld	s0,16(sp)
    80003474:	6105                	addi	sp,sp,32
    80003476:	8082                	ret

0000000080003478 <sys_sbrk>:
    80003478:	7179                	addi	sp,sp,-48
    8000347a:	f406                	sd	ra,40(sp)
    8000347c:	f022                	sd	s0,32(sp)
    8000347e:	ec26                	sd	s1,24(sp)
    80003480:	1800                	addi	s0,sp,48
    80003482:	fdc40593          	addi	a1,s0,-36
    80003486:	4501                	li	a0,0
    80003488:	00000097          	auipc	ra,0x0
    8000348c:	d30080e7          	jalr	-720(ra) # 800031b8 <argint>
    80003490:	fffff097          	auipc	ra,0xfffff
    80003494:	828080e7          	jalr	-2008(ra) # 80001cb8 <myproc>
    80003498:	6924                	ld	s1,80(a0)
    8000349a:	fdc42503          	lw	a0,-36(s0)
    8000349e:	fffff097          	auipc	ra,0xfffff
    800034a2:	bae080e7          	jalr	-1106(ra) # 8000204c <growproc>
    800034a6:	00054863          	bltz	a0,800034b6 <sys_sbrk+0x3e>
    800034aa:	8526                	mv	a0,s1
    800034ac:	70a2                	ld	ra,40(sp)
    800034ae:	7402                	ld	s0,32(sp)
    800034b0:	64e2                	ld	s1,24(sp)
    800034b2:	6145                	addi	sp,sp,48
    800034b4:	8082                	ret
    800034b6:	54fd                	li	s1,-1
    800034b8:	bfcd                	j	800034aa <sys_sbrk+0x32>

00000000800034ba <sys_sleep>:
    800034ba:	7139                	addi	sp,sp,-64
    800034bc:	fc06                	sd	ra,56(sp)
    800034be:	f822                	sd	s0,48(sp)
    800034c0:	f426                	sd	s1,40(sp)
    800034c2:	f04a                	sd	s2,32(sp)
    800034c4:	ec4e                	sd	s3,24(sp)
    800034c6:	0080                	addi	s0,sp,64
    800034c8:	fcc40593          	addi	a1,s0,-52
    800034cc:	4501                	li	a0,0
    800034ce:	00000097          	auipc	ra,0x0
    800034d2:	cea080e7          	jalr	-790(ra) # 800031b8 <argint>
    800034d6:	00676517          	auipc	a0,0x676
    800034da:	a1250513          	addi	a0,a0,-1518 # 80678ee8 <tickslock>
    800034de:	ffffe097          	auipc	ra,0xffffe
    800034e2:	8ca080e7          	jalr	-1846(ra) # 80000da8 <acquire>
    800034e6:	00005917          	auipc	s2,0x5
    800034ea:	74a92903          	lw	s2,1866(s2) # 80008c30 <ticks>
    800034ee:	fcc42783          	lw	a5,-52(s0)
    800034f2:	cf9d                	beqz	a5,80003530 <sys_sleep+0x76>
    800034f4:	00676997          	auipc	s3,0x676
    800034f8:	9f498993          	addi	s3,s3,-1548 # 80678ee8 <tickslock>
    800034fc:	00005497          	auipc	s1,0x5
    80003500:	73448493          	addi	s1,s1,1844 # 80008c30 <ticks>
    80003504:	ffffe097          	auipc	ra,0xffffe
    80003508:	7b4080e7          	jalr	1972(ra) # 80001cb8 <myproc>
    8000350c:	fffff097          	auipc	ra,0xfffff
    80003510:	4c0080e7          	jalr	1216(ra) # 800029cc <killed>
    80003514:	ed15                	bnez	a0,80003550 <sys_sleep+0x96>
    80003516:	85ce                	mv	a1,s3
    80003518:	8526                	mv	a0,s1
    8000351a:	fffff097          	auipc	ra,0xfffff
    8000351e:	f0e080e7          	jalr	-242(ra) # 80002428 <sleep>
    80003522:	409c                	lw	a5,0(s1)
    80003524:	412787bb          	subw	a5,a5,s2
    80003528:	fcc42703          	lw	a4,-52(s0)
    8000352c:	fce7ece3          	bltu	a5,a4,80003504 <sys_sleep+0x4a>
    80003530:	00676517          	auipc	a0,0x676
    80003534:	9b850513          	addi	a0,a0,-1608 # 80678ee8 <tickslock>
    80003538:	ffffe097          	auipc	ra,0xffffe
    8000353c:	924080e7          	jalr	-1756(ra) # 80000e5c <release>
    80003540:	4501                	li	a0,0
    80003542:	70e2                	ld	ra,56(sp)
    80003544:	7442                	ld	s0,48(sp)
    80003546:	74a2                	ld	s1,40(sp)
    80003548:	7902                	ld	s2,32(sp)
    8000354a:	69e2                	ld	s3,24(sp)
    8000354c:	6121                	addi	sp,sp,64
    8000354e:	8082                	ret
    80003550:	00676517          	auipc	a0,0x676
    80003554:	99850513          	addi	a0,a0,-1640 # 80678ee8 <tickslock>
    80003558:	ffffe097          	auipc	ra,0xffffe
    8000355c:	904080e7          	jalr	-1788(ra) # 80000e5c <release>
    80003560:	557d                	li	a0,-1
    80003562:	b7c5                	j	80003542 <sys_sleep+0x88>

0000000080003564 <sys_kill>:
    80003564:	1101                	addi	sp,sp,-32
    80003566:	ec06                	sd	ra,24(sp)
    80003568:	e822                	sd	s0,16(sp)
    8000356a:	1000                	addi	s0,sp,32
    8000356c:	fec40593          	addi	a1,s0,-20
    80003570:	4501                	li	a0,0
    80003572:	00000097          	auipc	ra,0x0
    80003576:	c46080e7          	jalr	-954(ra) # 800031b8 <argint>
    8000357a:	fec42503          	lw	a0,-20(s0)
    8000357e:	fffff097          	auipc	ra,0xfffff
    80003582:	38c080e7          	jalr	908(ra) # 8000290a <kill>
    80003586:	60e2                	ld	ra,24(sp)
    80003588:	6442                	ld	s0,16(sp)
    8000358a:	6105                	addi	sp,sp,32
    8000358c:	8082                	ret

000000008000358e <sys_uptime>:
    8000358e:	1101                	addi	sp,sp,-32
    80003590:	ec06                	sd	ra,24(sp)
    80003592:	e822                	sd	s0,16(sp)
    80003594:	e426                	sd	s1,8(sp)
    80003596:	1000                	addi	s0,sp,32
    80003598:	00676517          	auipc	a0,0x676
    8000359c:	95050513          	addi	a0,a0,-1712 # 80678ee8 <tickslock>
    800035a0:	ffffe097          	auipc	ra,0xffffe
    800035a4:	808080e7          	jalr	-2040(ra) # 80000da8 <acquire>
    800035a8:	00005497          	auipc	s1,0x5
    800035ac:	6884a483          	lw	s1,1672(s1) # 80008c30 <ticks>
    800035b0:	00676517          	auipc	a0,0x676
    800035b4:	93850513          	addi	a0,a0,-1736 # 80678ee8 <tickslock>
    800035b8:	ffffe097          	auipc	ra,0xffffe
    800035bc:	8a4080e7          	jalr	-1884(ra) # 80000e5c <release>
    800035c0:	02049513          	slli	a0,s1,0x20
    800035c4:	9101                	srli	a0,a0,0x20
    800035c6:	60e2                	ld	ra,24(sp)
    800035c8:	6442                	ld	s0,16(sp)
    800035ca:	64a2                	ld	s1,8(sp)
    800035cc:	6105                	addi	sp,sp,32
    800035ce:	8082                	ret

00000000800035d0 <sys_trace>:
    800035d0:	1101                	addi	sp,sp,-32
    800035d2:	ec06                	sd	ra,24(sp)
    800035d4:	e822                	sd	s0,16(sp)
    800035d6:	1000                	addi	s0,sp,32
    800035d8:	fec40593          	addi	a1,s0,-20
    800035dc:	4501                	li	a0,0
    800035de:	00000097          	auipc	ra,0x0
    800035e2:	bda080e7          	jalr	-1062(ra) # 800031b8 <argint>
    800035e6:	ffffe097          	auipc	ra,0xffffe
    800035ea:	6d2080e7          	jalr	1746(ra) # 80001cb8 <myproc>
    800035ee:	fec42783          	lw	a5,-20(s0)
    800035f2:	c11c                	sw	a5,0(a0)
    800035f4:	4501                	li	a0,0
    800035f6:	60e2                	ld	ra,24(sp)
    800035f8:	6442                	ld	s0,16(sp)
    800035fa:	6105                	addi	sp,sp,32
    800035fc:	8082                	ret

00000000800035fe <sys_setpriority>:
    800035fe:	1101                	addi	sp,sp,-32
    80003600:	ec06                	sd	ra,24(sp)
    80003602:	e822                	sd	s0,16(sp)
    80003604:	1000                	addi	s0,sp,32
    80003606:	fec40593          	addi	a1,s0,-20
    8000360a:	4501                	li	a0,0
    8000360c:	00000097          	auipc	ra,0x0
    80003610:	bac080e7          	jalr	-1108(ra) # 800031b8 <argint>
    80003614:	fe840593          	addi	a1,s0,-24
    80003618:	4505                	li	a0,1
    8000361a:	00000097          	auipc	ra,0x0
    8000361e:	b9e080e7          	jalr	-1122(ra) # 800031b8 <argint>
    80003622:	fe842583          	lw	a1,-24(s0)
    80003626:	fec42503          	lw	a0,-20(s0)
    8000362a:	ffffe097          	auipc	ra,0xffffe
    8000362e:	45c080e7          	jalr	1116(ra) # 80001a86 <set_priority>
    80003632:	60e2                	ld	ra,24(sp)
    80003634:	6442                	ld	s0,16(sp)
    80003636:	6105                	addi	sp,sp,32
    80003638:	8082                	ret

000000008000363a <sys_settickets>:
    8000363a:	1101                	addi	sp,sp,-32
    8000363c:	ec06                	sd	ra,24(sp)
    8000363e:	e822                	sd	s0,16(sp)
    80003640:	1000                	addi	s0,sp,32
    80003642:	fec40593          	addi	a1,s0,-20
    80003646:	4501                	li	a0,0
    80003648:	00000097          	auipc	ra,0x0
    8000364c:	b70080e7          	jalr	-1168(ra) # 800031b8 <argint>
    80003650:	ffffe097          	auipc	ra,0xffffe
    80003654:	668080e7          	jalr	1640(ra) # 80001cb8 <myproc>
    80003658:	fec42783          	lw	a5,-20(s0)
    8000365c:	18f52623          	sw	a5,396(a0)
    80003660:	4501                	li	a0,0
    80003662:	60e2                	ld	ra,24(sp)
    80003664:	6442                	ld	s0,16(sp)
    80003666:	6105                	addi	sp,sp,32
    80003668:	8082                	ret

000000008000366a <sys_waitx>:
    8000366a:	7139                	addi	sp,sp,-64
    8000366c:	fc06                	sd	ra,56(sp)
    8000366e:	f822                	sd	s0,48(sp)
    80003670:	f426                	sd	s1,40(sp)
    80003672:	f04a                	sd	s2,32(sp)
    80003674:	0080                	addi	s0,sp,64
    80003676:	fd840593          	addi	a1,s0,-40
    8000367a:	4501                	li	a0,0
    8000367c:	00000097          	auipc	ra,0x0
    80003680:	b5c080e7          	jalr	-1188(ra) # 800031d8 <argaddr>
    80003684:	fd040593          	addi	a1,s0,-48
    80003688:	4505                	li	a0,1
    8000368a:	00000097          	auipc	ra,0x0
    8000368e:	b4e080e7          	jalr	-1202(ra) # 800031d8 <argaddr>
    80003692:	fc840593          	addi	a1,s0,-56
    80003696:	4509                	li	a0,2
    80003698:	00000097          	auipc	ra,0x0
    8000369c:	b40080e7          	jalr	-1216(ra) # 800031d8 <argaddr>
    800036a0:	fc040613          	addi	a2,s0,-64
    800036a4:	fc440593          	addi	a1,s0,-60
    800036a8:	fd843503          	ld	a0,-40(s0)
    800036ac:	fffff097          	auipc	ra,0xfffff
    800036b0:	dea080e7          	jalr	-534(ra) # 80002496 <waitx>
    800036b4:	892a                	mv	s2,a0
    800036b6:	ffffe097          	auipc	ra,0xffffe
    800036ba:	602080e7          	jalr	1538(ra) # 80001cb8 <myproc>
    800036be:	84aa                	mv	s1,a0
    800036c0:	4691                	li	a3,4
    800036c2:	fc440613          	addi	a2,s0,-60
    800036c6:	fd043583          	ld	a1,-48(s0)
    800036ca:	6d28                	ld	a0,88(a0)
    800036cc:	ffffe097          	auipc	ra,0xffffe
    800036d0:	16c080e7          	jalr	364(ra) # 80001838 <copyout>
    800036d4:	57fd                	li	a5,-1
    800036d6:	00054f63          	bltz	a0,800036f4 <sys_waitx+0x8a>
    800036da:	4691                	li	a3,4
    800036dc:	fc040613          	addi	a2,s0,-64
    800036e0:	fc843583          	ld	a1,-56(s0)
    800036e4:	6ca8                	ld	a0,88(s1)
    800036e6:	ffffe097          	auipc	ra,0xffffe
    800036ea:	152080e7          	jalr	338(ra) # 80001838 <copyout>
    800036ee:	00054a63          	bltz	a0,80003702 <sys_waitx+0x98>
    800036f2:	87ca                	mv	a5,s2
    800036f4:	853e                	mv	a0,a5
    800036f6:	70e2                	ld	ra,56(sp)
    800036f8:	7442                	ld	s0,48(sp)
    800036fa:	74a2                	ld	s1,40(sp)
    800036fc:	7902                	ld	s2,32(sp)
    800036fe:	6121                	addi	sp,sp,64
    80003700:	8082                	ret
    80003702:	57fd                	li	a5,-1
    80003704:	bfc5                	j	800036f4 <sys_waitx+0x8a>

0000000080003706 <sys_sigalarm>:
    80003706:	1101                	addi	sp,sp,-32
    80003708:	ec06                	sd	ra,24(sp)
    8000370a:	e822                	sd	s0,16(sp)
    8000370c:	1000                	addi	s0,sp,32
    8000370e:	fe440593          	addi	a1,s0,-28
    80003712:	4501                	li	a0,0
    80003714:	00000097          	auipc	ra,0x0
    80003718:	aa4080e7          	jalr	-1372(ra) # 800031b8 <argint>
    8000371c:	fe840593          	addi	a1,s0,-24
    80003720:	4505                	li	a0,1
    80003722:	00000097          	auipc	ra,0x0
    80003726:	ab6080e7          	jalr	-1354(ra) # 800031d8 <argaddr>
    8000372a:	ffffe097          	auipc	ra,0xffffe
    8000372e:	58e080e7          	jalr	1422(ra) # 80001cb8 <myproc>
    80003732:	fe442783          	lw	a5,-28(s0)
    80003736:	18f52423          	sw	a5,392(a0)
    8000373a:	ffffe097          	auipc	ra,0xffffe
    8000373e:	57e080e7          	jalr	1406(ra) # 80001cb8 <myproc>
    80003742:	fe843783          	ld	a5,-24(s0)
    80003746:	16f53c23          	sd	a5,376(a0)
    8000374a:	4501                	li	a0,0
    8000374c:	60e2                	ld	ra,24(sp)
    8000374e:	6442                	ld	s0,16(sp)
    80003750:	6105                	addi	sp,sp,32
    80003752:	8082                	ret

0000000080003754 <sys_sigreturn>:
    80003754:	1101                	addi	sp,sp,-32
    80003756:	ec06                	sd	ra,24(sp)
    80003758:	e822                	sd	s0,16(sp)
    8000375a:	e426                	sd	s1,8(sp)
    8000375c:	1000                	addi	s0,sp,32
    8000375e:	ffffe097          	auipc	ra,0xffffe
    80003762:	55a080e7          	jalr	1370(ra) # 80001cb8 <myproc>
    80003766:	84aa                	mv	s1,a0
    80003768:	6605                	lui	a2,0x1
    8000376a:	17053583          	ld	a1,368(a0)
    8000376e:	7128                	ld	a0,96(a0)
    80003770:	ffffd097          	auipc	ra,0xffffd
    80003774:	794080e7          	jalr	1940(ra) # 80000f04 <memmove>
    80003778:	1704b503          	ld	a0,368(s1)
    8000377c:	ffffd097          	auipc	ra,0xffffd
    80003780:	352080e7          	jalr	850(ra) # 80000ace <kfree>
    80003784:	1604b823          	sd	zero,368(s1)
    80003788:	1804a023          	sw	zero,384(s1)
    8000378c:	1804a223          	sw	zero,388(s1)
    80003790:	70bc                	ld	a5,96(s1)
    80003792:	7ba8                	ld	a0,112(a5)
    80003794:	60e2                	ld	ra,24(sp)
    80003796:	6442                	ld	s0,16(sp)
    80003798:	64a2                	ld	s1,8(sp)
    8000379a:	6105                	addi	sp,sp,32
    8000379c:	8082                	ret

000000008000379e <binit>:
    8000379e:	7179                	addi	sp,sp,-48
    800037a0:	f406                	sd	ra,40(sp)
    800037a2:	f022                	sd	s0,32(sp)
    800037a4:	ec26                	sd	s1,24(sp)
    800037a6:	e84a                	sd	s2,16(sp)
    800037a8:	e44e                	sd	s3,8(sp)
    800037aa:	e052                	sd	s4,0(sp)
    800037ac:	1800                	addi	s0,sp,48
    800037ae:	00005597          	auipc	a1,0x5
    800037b2:	eea58593          	addi	a1,a1,-278 # 80008698 <syscalls+0xe0>
    800037b6:	00675517          	auipc	a0,0x675
    800037ba:	74a50513          	addi	a0,a0,1866 # 80678f00 <bcache>
    800037be:	ffffd097          	auipc	ra,0xffffd
    800037c2:	55a080e7          	jalr	1370(ra) # 80000d18 <initlock>
    800037c6:	0067d797          	auipc	a5,0x67d
    800037ca:	73a78793          	addi	a5,a5,1850 # 80680f00 <bcache+0x8000>
    800037ce:	0067e717          	auipc	a4,0x67e
    800037d2:	99a70713          	addi	a4,a4,-1638 # 80681168 <bcache+0x8268>
    800037d6:	2ae7b823          	sd	a4,688(a5)
    800037da:	2ae7bc23          	sd	a4,696(a5)
    800037de:	00675497          	auipc	s1,0x675
    800037e2:	73a48493          	addi	s1,s1,1850 # 80678f18 <bcache+0x18>
    800037e6:	893e                	mv	s2,a5
    800037e8:	89ba                	mv	s3,a4
    800037ea:	00005a17          	auipc	s4,0x5
    800037ee:	eb6a0a13          	addi	s4,s4,-330 # 800086a0 <syscalls+0xe8>
    800037f2:	2b893783          	ld	a5,696(s2)
    800037f6:	e8bc                	sd	a5,80(s1)
    800037f8:	0534b423          	sd	s3,72(s1)
    800037fc:	85d2                	mv	a1,s4
    800037fe:	01048513          	addi	a0,s1,16
    80003802:	00001097          	auipc	ra,0x1
    80003806:	4c4080e7          	jalr	1220(ra) # 80004cc6 <initsleeplock>
    8000380a:	2b893783          	ld	a5,696(s2)
    8000380e:	e7a4                	sd	s1,72(a5)
    80003810:	2a993c23          	sd	s1,696(s2)
    80003814:	45848493          	addi	s1,s1,1112
    80003818:	fd349de3          	bne	s1,s3,800037f2 <binit+0x54>
    8000381c:	70a2                	ld	ra,40(sp)
    8000381e:	7402                	ld	s0,32(sp)
    80003820:	64e2                	ld	s1,24(sp)
    80003822:	6942                	ld	s2,16(sp)
    80003824:	69a2                	ld	s3,8(sp)
    80003826:	6a02                	ld	s4,0(sp)
    80003828:	6145                	addi	sp,sp,48
    8000382a:	8082                	ret

000000008000382c <bread>:
    8000382c:	7179                	addi	sp,sp,-48
    8000382e:	f406                	sd	ra,40(sp)
    80003830:	f022                	sd	s0,32(sp)
    80003832:	ec26                	sd	s1,24(sp)
    80003834:	e84a                	sd	s2,16(sp)
    80003836:	e44e                	sd	s3,8(sp)
    80003838:	1800                	addi	s0,sp,48
    8000383a:	89aa                	mv	s3,a0
    8000383c:	892e                	mv	s2,a1
    8000383e:	00675517          	auipc	a0,0x675
    80003842:	6c250513          	addi	a0,a0,1730 # 80678f00 <bcache>
    80003846:	ffffd097          	auipc	ra,0xffffd
    8000384a:	562080e7          	jalr	1378(ra) # 80000da8 <acquire>
    8000384e:	0067e497          	auipc	s1,0x67e
    80003852:	96a4b483          	ld	s1,-1686(s1) # 806811b8 <bcache+0x82b8>
    80003856:	0067e797          	auipc	a5,0x67e
    8000385a:	91278793          	addi	a5,a5,-1774 # 80681168 <bcache+0x8268>
    8000385e:	02f48f63          	beq	s1,a5,8000389c <bread+0x70>
    80003862:	873e                	mv	a4,a5
    80003864:	a021                	j	8000386c <bread+0x40>
    80003866:	68a4                	ld	s1,80(s1)
    80003868:	02e48a63          	beq	s1,a4,8000389c <bread+0x70>
    8000386c:	449c                	lw	a5,8(s1)
    8000386e:	ff379ce3          	bne	a5,s3,80003866 <bread+0x3a>
    80003872:	44dc                	lw	a5,12(s1)
    80003874:	ff2799e3          	bne	a5,s2,80003866 <bread+0x3a>
    80003878:	40bc                	lw	a5,64(s1)
    8000387a:	2785                	addiw	a5,a5,1
    8000387c:	c0bc                	sw	a5,64(s1)
    8000387e:	00675517          	auipc	a0,0x675
    80003882:	68250513          	addi	a0,a0,1666 # 80678f00 <bcache>
    80003886:	ffffd097          	auipc	ra,0xffffd
    8000388a:	5d6080e7          	jalr	1494(ra) # 80000e5c <release>
    8000388e:	01048513          	addi	a0,s1,16
    80003892:	00001097          	auipc	ra,0x1
    80003896:	46e080e7          	jalr	1134(ra) # 80004d00 <acquiresleep>
    8000389a:	a8b9                	j	800038f8 <bread+0xcc>
    8000389c:	0067e497          	auipc	s1,0x67e
    800038a0:	9144b483          	ld	s1,-1772(s1) # 806811b0 <bcache+0x82b0>
    800038a4:	0067e797          	auipc	a5,0x67e
    800038a8:	8c478793          	addi	a5,a5,-1852 # 80681168 <bcache+0x8268>
    800038ac:	00f48863          	beq	s1,a5,800038bc <bread+0x90>
    800038b0:	873e                	mv	a4,a5
    800038b2:	40bc                	lw	a5,64(s1)
    800038b4:	cf81                	beqz	a5,800038cc <bread+0xa0>
    800038b6:	64a4                	ld	s1,72(s1)
    800038b8:	fee49de3          	bne	s1,a4,800038b2 <bread+0x86>
    800038bc:	00005517          	auipc	a0,0x5
    800038c0:	dec50513          	addi	a0,a0,-532 # 800086a8 <syscalls+0xf0>
    800038c4:	ffffd097          	auipc	ra,0xffffd
    800038c8:	c80080e7          	jalr	-896(ra) # 80000544 <panic>
    800038cc:	0134a423          	sw	s3,8(s1)
    800038d0:	0124a623          	sw	s2,12(s1)
    800038d4:	0004a023          	sw	zero,0(s1)
    800038d8:	4785                	li	a5,1
    800038da:	c0bc                	sw	a5,64(s1)
    800038dc:	00675517          	auipc	a0,0x675
    800038e0:	62450513          	addi	a0,a0,1572 # 80678f00 <bcache>
    800038e4:	ffffd097          	auipc	ra,0xffffd
    800038e8:	578080e7          	jalr	1400(ra) # 80000e5c <release>
    800038ec:	01048513          	addi	a0,s1,16
    800038f0:	00001097          	auipc	ra,0x1
    800038f4:	410080e7          	jalr	1040(ra) # 80004d00 <acquiresleep>
    800038f8:	409c                	lw	a5,0(s1)
    800038fa:	cb89                	beqz	a5,8000390c <bread+0xe0>
    800038fc:	8526                	mv	a0,s1
    800038fe:	70a2                	ld	ra,40(sp)
    80003900:	7402                	ld	s0,32(sp)
    80003902:	64e2                	ld	s1,24(sp)
    80003904:	6942                	ld	s2,16(sp)
    80003906:	69a2                	ld	s3,8(sp)
    80003908:	6145                	addi	sp,sp,48
    8000390a:	8082                	ret
    8000390c:	4581                	li	a1,0
    8000390e:	8526                	mv	a0,s1
    80003910:	00003097          	auipc	ra,0x3
    80003914:	fc8080e7          	jalr	-56(ra) # 800068d8 <virtio_disk_rw>
    80003918:	4785                	li	a5,1
    8000391a:	c09c                	sw	a5,0(s1)
    8000391c:	b7c5                	j	800038fc <bread+0xd0>

000000008000391e <bwrite>:
    8000391e:	1101                	addi	sp,sp,-32
    80003920:	ec06                	sd	ra,24(sp)
    80003922:	e822                	sd	s0,16(sp)
    80003924:	e426                	sd	s1,8(sp)
    80003926:	1000                	addi	s0,sp,32
    80003928:	84aa                	mv	s1,a0
    8000392a:	0541                	addi	a0,a0,16
    8000392c:	00001097          	auipc	ra,0x1
    80003930:	46e080e7          	jalr	1134(ra) # 80004d9a <holdingsleep>
    80003934:	cd01                	beqz	a0,8000394c <bwrite+0x2e>
    80003936:	4585                	li	a1,1
    80003938:	8526                	mv	a0,s1
    8000393a:	00003097          	auipc	ra,0x3
    8000393e:	f9e080e7          	jalr	-98(ra) # 800068d8 <virtio_disk_rw>
    80003942:	60e2                	ld	ra,24(sp)
    80003944:	6442                	ld	s0,16(sp)
    80003946:	64a2                	ld	s1,8(sp)
    80003948:	6105                	addi	sp,sp,32
    8000394a:	8082                	ret
    8000394c:	00005517          	auipc	a0,0x5
    80003950:	d7450513          	addi	a0,a0,-652 # 800086c0 <syscalls+0x108>
    80003954:	ffffd097          	auipc	ra,0xffffd
    80003958:	bf0080e7          	jalr	-1040(ra) # 80000544 <panic>

000000008000395c <brelse>:
    8000395c:	1101                	addi	sp,sp,-32
    8000395e:	ec06                	sd	ra,24(sp)
    80003960:	e822                	sd	s0,16(sp)
    80003962:	e426                	sd	s1,8(sp)
    80003964:	e04a                	sd	s2,0(sp)
    80003966:	1000                	addi	s0,sp,32
    80003968:	84aa                	mv	s1,a0
    8000396a:	01050913          	addi	s2,a0,16
    8000396e:	854a                	mv	a0,s2
    80003970:	00001097          	auipc	ra,0x1
    80003974:	42a080e7          	jalr	1066(ra) # 80004d9a <holdingsleep>
    80003978:	c92d                	beqz	a0,800039ea <brelse+0x8e>
    8000397a:	854a                	mv	a0,s2
    8000397c:	00001097          	auipc	ra,0x1
    80003980:	3da080e7          	jalr	986(ra) # 80004d56 <releasesleep>
    80003984:	00675517          	auipc	a0,0x675
    80003988:	57c50513          	addi	a0,a0,1404 # 80678f00 <bcache>
    8000398c:	ffffd097          	auipc	ra,0xffffd
    80003990:	41c080e7          	jalr	1052(ra) # 80000da8 <acquire>
    80003994:	40bc                	lw	a5,64(s1)
    80003996:	37fd                	addiw	a5,a5,-1
    80003998:	0007871b          	sext.w	a4,a5
    8000399c:	c0bc                	sw	a5,64(s1)
    8000399e:	eb05                	bnez	a4,800039ce <brelse+0x72>
    800039a0:	68bc                	ld	a5,80(s1)
    800039a2:	64b8                	ld	a4,72(s1)
    800039a4:	e7b8                	sd	a4,72(a5)
    800039a6:	64bc                	ld	a5,72(s1)
    800039a8:	68b8                	ld	a4,80(s1)
    800039aa:	ebb8                	sd	a4,80(a5)
    800039ac:	0067d797          	auipc	a5,0x67d
    800039b0:	55478793          	addi	a5,a5,1364 # 80680f00 <bcache+0x8000>
    800039b4:	2b87b703          	ld	a4,696(a5)
    800039b8:	e8b8                	sd	a4,80(s1)
    800039ba:	0067d717          	auipc	a4,0x67d
    800039be:	7ae70713          	addi	a4,a4,1966 # 80681168 <bcache+0x8268>
    800039c2:	e4b8                	sd	a4,72(s1)
    800039c4:	2b87b703          	ld	a4,696(a5)
    800039c8:	e724                	sd	s1,72(a4)
    800039ca:	2a97bc23          	sd	s1,696(a5)
    800039ce:	00675517          	auipc	a0,0x675
    800039d2:	53250513          	addi	a0,a0,1330 # 80678f00 <bcache>
    800039d6:	ffffd097          	auipc	ra,0xffffd
    800039da:	486080e7          	jalr	1158(ra) # 80000e5c <release>
    800039de:	60e2                	ld	ra,24(sp)
    800039e0:	6442                	ld	s0,16(sp)
    800039e2:	64a2                	ld	s1,8(sp)
    800039e4:	6902                	ld	s2,0(sp)
    800039e6:	6105                	addi	sp,sp,32
    800039e8:	8082                	ret
    800039ea:	00005517          	auipc	a0,0x5
    800039ee:	cde50513          	addi	a0,a0,-802 # 800086c8 <syscalls+0x110>
    800039f2:	ffffd097          	auipc	ra,0xffffd
    800039f6:	b52080e7          	jalr	-1198(ra) # 80000544 <panic>

00000000800039fa <bpin>:
    800039fa:	1101                	addi	sp,sp,-32
    800039fc:	ec06                	sd	ra,24(sp)
    800039fe:	e822                	sd	s0,16(sp)
    80003a00:	e426                	sd	s1,8(sp)
    80003a02:	1000                	addi	s0,sp,32
    80003a04:	84aa                	mv	s1,a0
    80003a06:	00675517          	auipc	a0,0x675
    80003a0a:	4fa50513          	addi	a0,a0,1274 # 80678f00 <bcache>
    80003a0e:	ffffd097          	auipc	ra,0xffffd
    80003a12:	39a080e7          	jalr	922(ra) # 80000da8 <acquire>
    80003a16:	40bc                	lw	a5,64(s1)
    80003a18:	2785                	addiw	a5,a5,1
    80003a1a:	c0bc                	sw	a5,64(s1)
    80003a1c:	00675517          	auipc	a0,0x675
    80003a20:	4e450513          	addi	a0,a0,1252 # 80678f00 <bcache>
    80003a24:	ffffd097          	auipc	ra,0xffffd
    80003a28:	438080e7          	jalr	1080(ra) # 80000e5c <release>
    80003a2c:	60e2                	ld	ra,24(sp)
    80003a2e:	6442                	ld	s0,16(sp)
    80003a30:	64a2                	ld	s1,8(sp)
    80003a32:	6105                	addi	sp,sp,32
    80003a34:	8082                	ret

0000000080003a36 <bunpin>:
    80003a36:	1101                	addi	sp,sp,-32
    80003a38:	ec06                	sd	ra,24(sp)
    80003a3a:	e822                	sd	s0,16(sp)
    80003a3c:	e426                	sd	s1,8(sp)
    80003a3e:	1000                	addi	s0,sp,32
    80003a40:	84aa                	mv	s1,a0
    80003a42:	00675517          	auipc	a0,0x675
    80003a46:	4be50513          	addi	a0,a0,1214 # 80678f00 <bcache>
    80003a4a:	ffffd097          	auipc	ra,0xffffd
    80003a4e:	35e080e7          	jalr	862(ra) # 80000da8 <acquire>
    80003a52:	40bc                	lw	a5,64(s1)
    80003a54:	37fd                	addiw	a5,a5,-1
    80003a56:	c0bc                	sw	a5,64(s1)
    80003a58:	00675517          	auipc	a0,0x675
    80003a5c:	4a850513          	addi	a0,a0,1192 # 80678f00 <bcache>
    80003a60:	ffffd097          	auipc	ra,0xffffd
    80003a64:	3fc080e7          	jalr	1020(ra) # 80000e5c <release>
    80003a68:	60e2                	ld	ra,24(sp)
    80003a6a:	6442                	ld	s0,16(sp)
    80003a6c:	64a2                	ld	s1,8(sp)
    80003a6e:	6105                	addi	sp,sp,32
    80003a70:	8082                	ret

0000000080003a72 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003a72:	1101                	addi	sp,sp,-32
    80003a74:	ec06                	sd	ra,24(sp)
    80003a76:	e822                	sd	s0,16(sp)
    80003a78:	e426                	sd	s1,8(sp)
    80003a7a:	e04a                	sd	s2,0(sp)
    80003a7c:	1000                	addi	s0,sp,32
    80003a7e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003a80:	00d5d59b          	srliw	a1,a1,0xd
    80003a84:	0067e797          	auipc	a5,0x67e
    80003a88:	b587a783          	lw	a5,-1192(a5) # 806815dc <sb+0x1c>
    80003a8c:	9dbd                	addw	a1,a1,a5
    80003a8e:	00000097          	auipc	ra,0x0
    80003a92:	d9e080e7          	jalr	-610(ra) # 8000382c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003a96:	0074f713          	andi	a4,s1,7
    80003a9a:	4785                	li	a5,1
    80003a9c:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003aa0:	14ce                	slli	s1,s1,0x33
    80003aa2:	90d9                	srli	s1,s1,0x36
    80003aa4:	00950733          	add	a4,a0,s1
    80003aa8:	05874703          	lbu	a4,88(a4)
    80003aac:	00e7f6b3          	and	a3,a5,a4
    80003ab0:	c69d                	beqz	a3,80003ade <bfree+0x6c>
    80003ab2:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003ab4:	94aa                	add	s1,s1,a0
    80003ab6:	fff7c793          	not	a5,a5
    80003aba:	8ff9                	and	a5,a5,a4
    80003abc:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003ac0:	00001097          	auipc	ra,0x1
    80003ac4:	120080e7          	jalr	288(ra) # 80004be0 <log_write>
  brelse(bp);
    80003ac8:	854a                	mv	a0,s2
    80003aca:	00000097          	auipc	ra,0x0
    80003ace:	e92080e7          	jalr	-366(ra) # 8000395c <brelse>
}
    80003ad2:	60e2                	ld	ra,24(sp)
    80003ad4:	6442                	ld	s0,16(sp)
    80003ad6:	64a2                	ld	s1,8(sp)
    80003ad8:	6902                	ld	s2,0(sp)
    80003ada:	6105                	addi	sp,sp,32
    80003adc:	8082                	ret
    panic("freeing free block");
    80003ade:	00005517          	auipc	a0,0x5
    80003ae2:	bf250513          	addi	a0,a0,-1038 # 800086d0 <syscalls+0x118>
    80003ae6:	ffffd097          	auipc	ra,0xffffd
    80003aea:	a5e080e7          	jalr	-1442(ra) # 80000544 <panic>

0000000080003aee <balloc>:
{
    80003aee:	711d                	addi	sp,sp,-96
    80003af0:	ec86                	sd	ra,88(sp)
    80003af2:	e8a2                	sd	s0,80(sp)
    80003af4:	e4a6                	sd	s1,72(sp)
    80003af6:	e0ca                	sd	s2,64(sp)
    80003af8:	fc4e                	sd	s3,56(sp)
    80003afa:	f852                	sd	s4,48(sp)
    80003afc:	f456                	sd	s5,40(sp)
    80003afe:	f05a                	sd	s6,32(sp)
    80003b00:	ec5e                	sd	s7,24(sp)
    80003b02:	e862                	sd	s8,16(sp)
    80003b04:	e466                	sd	s9,8(sp)
    80003b06:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003b08:	0067e797          	auipc	a5,0x67e
    80003b0c:	abc7a783          	lw	a5,-1348(a5) # 806815c4 <sb+0x4>
    80003b10:	10078163          	beqz	a5,80003c12 <balloc+0x124>
    80003b14:	8baa                	mv	s7,a0
    80003b16:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003b18:	0067eb17          	auipc	s6,0x67e
    80003b1c:	aa8b0b13          	addi	s6,s6,-1368 # 806815c0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b20:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003b22:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003b24:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003b26:	6c89                	lui	s9,0x2
    80003b28:	a061                	j	80003bb0 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003b2a:	974a                	add	a4,a4,s2
    80003b2c:	8fd5                	or	a5,a5,a3
    80003b2e:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003b32:	854a                	mv	a0,s2
    80003b34:	00001097          	auipc	ra,0x1
    80003b38:	0ac080e7          	jalr	172(ra) # 80004be0 <log_write>
        brelse(bp);
    80003b3c:	854a                	mv	a0,s2
    80003b3e:	00000097          	auipc	ra,0x0
    80003b42:	e1e080e7          	jalr	-482(ra) # 8000395c <brelse>
  bp = bread(dev, bno);
    80003b46:	85a6                	mv	a1,s1
    80003b48:	855e                	mv	a0,s7
    80003b4a:	00000097          	auipc	ra,0x0
    80003b4e:	ce2080e7          	jalr	-798(ra) # 8000382c <bread>
    80003b52:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003b54:	40000613          	li	a2,1024
    80003b58:	4581                	li	a1,0
    80003b5a:	05850513          	addi	a0,a0,88
    80003b5e:	ffffd097          	auipc	ra,0xffffd
    80003b62:	346080e7          	jalr	838(ra) # 80000ea4 <memset>
  log_write(bp);
    80003b66:	854a                	mv	a0,s2
    80003b68:	00001097          	auipc	ra,0x1
    80003b6c:	078080e7          	jalr	120(ra) # 80004be0 <log_write>
  brelse(bp);
    80003b70:	854a                	mv	a0,s2
    80003b72:	00000097          	auipc	ra,0x0
    80003b76:	dea080e7          	jalr	-534(ra) # 8000395c <brelse>
}
    80003b7a:	8526                	mv	a0,s1
    80003b7c:	60e6                	ld	ra,88(sp)
    80003b7e:	6446                	ld	s0,80(sp)
    80003b80:	64a6                	ld	s1,72(sp)
    80003b82:	6906                	ld	s2,64(sp)
    80003b84:	79e2                	ld	s3,56(sp)
    80003b86:	7a42                	ld	s4,48(sp)
    80003b88:	7aa2                	ld	s5,40(sp)
    80003b8a:	7b02                	ld	s6,32(sp)
    80003b8c:	6be2                	ld	s7,24(sp)
    80003b8e:	6c42                	ld	s8,16(sp)
    80003b90:	6ca2                	ld	s9,8(sp)
    80003b92:	6125                	addi	sp,sp,96
    80003b94:	8082                	ret
    brelse(bp);
    80003b96:	854a                	mv	a0,s2
    80003b98:	00000097          	auipc	ra,0x0
    80003b9c:	dc4080e7          	jalr	-572(ra) # 8000395c <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003ba0:	015c87bb          	addw	a5,s9,s5
    80003ba4:	00078a9b          	sext.w	s5,a5
    80003ba8:	004b2703          	lw	a4,4(s6)
    80003bac:	06eaf363          	bgeu	s5,a4,80003c12 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80003bb0:	41fad79b          	sraiw	a5,s5,0x1f
    80003bb4:	0137d79b          	srliw	a5,a5,0x13
    80003bb8:	015787bb          	addw	a5,a5,s5
    80003bbc:	40d7d79b          	sraiw	a5,a5,0xd
    80003bc0:	01cb2583          	lw	a1,28(s6)
    80003bc4:	9dbd                	addw	a1,a1,a5
    80003bc6:	855e                	mv	a0,s7
    80003bc8:	00000097          	auipc	ra,0x0
    80003bcc:	c64080e7          	jalr	-924(ra) # 8000382c <bread>
    80003bd0:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003bd2:	004b2503          	lw	a0,4(s6)
    80003bd6:	000a849b          	sext.w	s1,s5
    80003bda:	8662                	mv	a2,s8
    80003bdc:	faa4fde3          	bgeu	s1,a0,80003b96 <balloc+0xa8>
      m = 1 << (bi % 8);
    80003be0:	41f6579b          	sraiw	a5,a2,0x1f
    80003be4:	01d7d69b          	srliw	a3,a5,0x1d
    80003be8:	00c6873b          	addw	a4,a3,a2
    80003bec:	00777793          	andi	a5,a4,7
    80003bf0:	9f95                	subw	a5,a5,a3
    80003bf2:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003bf6:	4037571b          	sraiw	a4,a4,0x3
    80003bfa:	00e906b3          	add	a3,s2,a4
    80003bfe:	0586c683          	lbu	a3,88(a3)
    80003c02:	00d7f5b3          	and	a1,a5,a3
    80003c06:	d195                	beqz	a1,80003b2a <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003c08:	2605                	addiw	a2,a2,1
    80003c0a:	2485                	addiw	s1,s1,1
    80003c0c:	fd4618e3          	bne	a2,s4,80003bdc <balloc+0xee>
    80003c10:	b759                	j	80003b96 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003c12:	00005517          	auipc	a0,0x5
    80003c16:	ad650513          	addi	a0,a0,-1322 # 800086e8 <syscalls+0x130>
    80003c1a:	ffffd097          	auipc	ra,0xffffd
    80003c1e:	974080e7          	jalr	-1676(ra) # 8000058e <printf>
  return 0;
    80003c22:	4481                	li	s1,0
    80003c24:	bf99                	j	80003b7a <balloc+0x8c>

0000000080003c26 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003c26:	7179                	addi	sp,sp,-48
    80003c28:	f406                	sd	ra,40(sp)
    80003c2a:	f022                	sd	s0,32(sp)
    80003c2c:	ec26                	sd	s1,24(sp)
    80003c2e:	e84a                	sd	s2,16(sp)
    80003c30:	e44e                	sd	s3,8(sp)
    80003c32:	e052                	sd	s4,0(sp)
    80003c34:	1800                	addi	s0,sp,48
    80003c36:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003c38:	47ad                	li	a5,11
    80003c3a:	02b7e763          	bltu	a5,a1,80003c68 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003c3e:	02059493          	slli	s1,a1,0x20
    80003c42:	9081                	srli	s1,s1,0x20
    80003c44:	048a                	slli	s1,s1,0x2
    80003c46:	94aa                	add	s1,s1,a0
    80003c48:	0504a903          	lw	s2,80(s1)
    80003c4c:	06091e63          	bnez	s2,80003cc8 <bmap+0xa2>
      addr = balloc(ip->dev);
    80003c50:	4108                	lw	a0,0(a0)
    80003c52:	00000097          	auipc	ra,0x0
    80003c56:	e9c080e7          	jalr	-356(ra) # 80003aee <balloc>
    80003c5a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003c5e:	06090563          	beqz	s2,80003cc8 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80003c62:	0524a823          	sw	s2,80(s1)
    80003c66:	a08d                	j	80003cc8 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003c68:	ff45849b          	addiw	s1,a1,-12
    80003c6c:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003c70:	0ff00793          	li	a5,255
    80003c74:	08e7e563          	bltu	a5,a4,80003cfe <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003c78:	08052903          	lw	s2,128(a0)
    80003c7c:	00091d63          	bnez	s2,80003c96 <bmap+0x70>
      addr = balloc(ip->dev);
    80003c80:	4108                	lw	a0,0(a0)
    80003c82:	00000097          	auipc	ra,0x0
    80003c86:	e6c080e7          	jalr	-404(ra) # 80003aee <balloc>
    80003c8a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003c8e:	02090d63          	beqz	s2,80003cc8 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003c92:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003c96:	85ca                	mv	a1,s2
    80003c98:	0009a503          	lw	a0,0(s3)
    80003c9c:	00000097          	auipc	ra,0x0
    80003ca0:	b90080e7          	jalr	-1136(ra) # 8000382c <bread>
    80003ca4:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003ca6:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003caa:	02049593          	slli	a1,s1,0x20
    80003cae:	9181                	srli	a1,a1,0x20
    80003cb0:	058a                	slli	a1,a1,0x2
    80003cb2:	00b784b3          	add	s1,a5,a1
    80003cb6:	0004a903          	lw	s2,0(s1)
    80003cba:	02090063          	beqz	s2,80003cda <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003cbe:	8552                	mv	a0,s4
    80003cc0:	00000097          	auipc	ra,0x0
    80003cc4:	c9c080e7          	jalr	-868(ra) # 8000395c <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003cc8:	854a                	mv	a0,s2
    80003cca:	70a2                	ld	ra,40(sp)
    80003ccc:	7402                	ld	s0,32(sp)
    80003cce:	64e2                	ld	s1,24(sp)
    80003cd0:	6942                	ld	s2,16(sp)
    80003cd2:	69a2                	ld	s3,8(sp)
    80003cd4:	6a02                	ld	s4,0(sp)
    80003cd6:	6145                	addi	sp,sp,48
    80003cd8:	8082                	ret
      addr = balloc(ip->dev);
    80003cda:	0009a503          	lw	a0,0(s3)
    80003cde:	00000097          	auipc	ra,0x0
    80003ce2:	e10080e7          	jalr	-496(ra) # 80003aee <balloc>
    80003ce6:	0005091b          	sext.w	s2,a0
      if(addr){
    80003cea:	fc090ae3          	beqz	s2,80003cbe <bmap+0x98>
        a[bn] = addr;
    80003cee:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003cf2:	8552                	mv	a0,s4
    80003cf4:	00001097          	auipc	ra,0x1
    80003cf8:	eec080e7          	jalr	-276(ra) # 80004be0 <log_write>
    80003cfc:	b7c9                	j	80003cbe <bmap+0x98>
  panic("bmap: out of range");
    80003cfe:	00005517          	auipc	a0,0x5
    80003d02:	a0250513          	addi	a0,a0,-1534 # 80008700 <syscalls+0x148>
    80003d06:	ffffd097          	auipc	ra,0xffffd
    80003d0a:	83e080e7          	jalr	-1986(ra) # 80000544 <panic>

0000000080003d0e <iget>:
{
    80003d0e:	7179                	addi	sp,sp,-48
    80003d10:	f406                	sd	ra,40(sp)
    80003d12:	f022                	sd	s0,32(sp)
    80003d14:	ec26                	sd	s1,24(sp)
    80003d16:	e84a                	sd	s2,16(sp)
    80003d18:	e44e                	sd	s3,8(sp)
    80003d1a:	e052                	sd	s4,0(sp)
    80003d1c:	1800                	addi	s0,sp,48
    80003d1e:	89aa                	mv	s3,a0
    80003d20:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003d22:	0067e517          	auipc	a0,0x67e
    80003d26:	8be50513          	addi	a0,a0,-1858 # 806815e0 <itable>
    80003d2a:	ffffd097          	auipc	ra,0xffffd
    80003d2e:	07e080e7          	jalr	126(ra) # 80000da8 <acquire>
  empty = 0;
    80003d32:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003d34:	0067e497          	auipc	s1,0x67e
    80003d38:	8c448493          	addi	s1,s1,-1852 # 806815f8 <itable+0x18>
    80003d3c:	0067f697          	auipc	a3,0x67f
    80003d40:	34c68693          	addi	a3,a3,844 # 80683088 <log>
    80003d44:	a039                	j	80003d52 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003d46:	02090b63          	beqz	s2,80003d7c <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003d4a:	08848493          	addi	s1,s1,136
    80003d4e:	02d48a63          	beq	s1,a3,80003d82 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003d52:	449c                	lw	a5,8(s1)
    80003d54:	fef059e3          	blez	a5,80003d46 <iget+0x38>
    80003d58:	4098                	lw	a4,0(s1)
    80003d5a:	ff3716e3          	bne	a4,s3,80003d46 <iget+0x38>
    80003d5e:	40d8                	lw	a4,4(s1)
    80003d60:	ff4713e3          	bne	a4,s4,80003d46 <iget+0x38>
      ip->ref++;
    80003d64:	2785                	addiw	a5,a5,1
    80003d66:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003d68:	0067e517          	auipc	a0,0x67e
    80003d6c:	87850513          	addi	a0,a0,-1928 # 806815e0 <itable>
    80003d70:	ffffd097          	auipc	ra,0xffffd
    80003d74:	0ec080e7          	jalr	236(ra) # 80000e5c <release>
      return ip;
    80003d78:	8926                	mv	s2,s1
    80003d7a:	a03d                	j	80003da8 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003d7c:	f7f9                	bnez	a5,80003d4a <iget+0x3c>
    80003d7e:	8926                	mv	s2,s1
    80003d80:	b7e9                	j	80003d4a <iget+0x3c>
  if(empty == 0)
    80003d82:	02090c63          	beqz	s2,80003dba <iget+0xac>
  ip->dev = dev;
    80003d86:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003d8a:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003d8e:	4785                	li	a5,1
    80003d90:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003d94:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003d98:	0067e517          	auipc	a0,0x67e
    80003d9c:	84850513          	addi	a0,a0,-1976 # 806815e0 <itable>
    80003da0:	ffffd097          	auipc	ra,0xffffd
    80003da4:	0bc080e7          	jalr	188(ra) # 80000e5c <release>
}
    80003da8:	854a                	mv	a0,s2
    80003daa:	70a2                	ld	ra,40(sp)
    80003dac:	7402                	ld	s0,32(sp)
    80003dae:	64e2                	ld	s1,24(sp)
    80003db0:	6942                	ld	s2,16(sp)
    80003db2:	69a2                	ld	s3,8(sp)
    80003db4:	6a02                	ld	s4,0(sp)
    80003db6:	6145                	addi	sp,sp,48
    80003db8:	8082                	ret
    panic("iget: no inodes");
    80003dba:	00005517          	auipc	a0,0x5
    80003dbe:	95e50513          	addi	a0,a0,-1698 # 80008718 <syscalls+0x160>
    80003dc2:	ffffc097          	auipc	ra,0xffffc
    80003dc6:	782080e7          	jalr	1922(ra) # 80000544 <panic>

0000000080003dca <fsinit>:
fsinit(int dev) {
    80003dca:	7179                	addi	sp,sp,-48
    80003dcc:	f406                	sd	ra,40(sp)
    80003dce:	f022                	sd	s0,32(sp)
    80003dd0:	ec26                	sd	s1,24(sp)
    80003dd2:	e84a                	sd	s2,16(sp)
    80003dd4:	e44e                	sd	s3,8(sp)
    80003dd6:	1800                	addi	s0,sp,48
    80003dd8:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003dda:	4585                	li	a1,1
    80003ddc:	00000097          	auipc	ra,0x0
    80003de0:	a50080e7          	jalr	-1456(ra) # 8000382c <bread>
    80003de4:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003de6:	0067d997          	auipc	s3,0x67d
    80003dea:	7da98993          	addi	s3,s3,2010 # 806815c0 <sb>
    80003dee:	02000613          	li	a2,32
    80003df2:	05850593          	addi	a1,a0,88
    80003df6:	854e                	mv	a0,s3
    80003df8:	ffffd097          	auipc	ra,0xffffd
    80003dfc:	10c080e7          	jalr	268(ra) # 80000f04 <memmove>
  brelse(bp);
    80003e00:	8526                	mv	a0,s1
    80003e02:	00000097          	auipc	ra,0x0
    80003e06:	b5a080e7          	jalr	-1190(ra) # 8000395c <brelse>
  if(sb.magic != FSMAGIC)
    80003e0a:	0009a703          	lw	a4,0(s3)
    80003e0e:	102037b7          	lui	a5,0x10203
    80003e12:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003e16:	02f71263          	bne	a4,a5,80003e3a <fsinit+0x70>
  initlog(dev, &sb);
    80003e1a:	0067d597          	auipc	a1,0x67d
    80003e1e:	7a658593          	addi	a1,a1,1958 # 806815c0 <sb>
    80003e22:	854a                	mv	a0,s2
    80003e24:	00001097          	auipc	ra,0x1
    80003e28:	b40080e7          	jalr	-1216(ra) # 80004964 <initlog>
}
    80003e2c:	70a2                	ld	ra,40(sp)
    80003e2e:	7402                	ld	s0,32(sp)
    80003e30:	64e2                	ld	s1,24(sp)
    80003e32:	6942                	ld	s2,16(sp)
    80003e34:	69a2                	ld	s3,8(sp)
    80003e36:	6145                	addi	sp,sp,48
    80003e38:	8082                	ret
    panic("invalid file system");
    80003e3a:	00005517          	auipc	a0,0x5
    80003e3e:	8ee50513          	addi	a0,a0,-1810 # 80008728 <syscalls+0x170>
    80003e42:	ffffc097          	auipc	ra,0xffffc
    80003e46:	702080e7          	jalr	1794(ra) # 80000544 <panic>

0000000080003e4a <iinit>:
{
    80003e4a:	7179                	addi	sp,sp,-48
    80003e4c:	f406                	sd	ra,40(sp)
    80003e4e:	f022                	sd	s0,32(sp)
    80003e50:	ec26                	sd	s1,24(sp)
    80003e52:	e84a                	sd	s2,16(sp)
    80003e54:	e44e                	sd	s3,8(sp)
    80003e56:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003e58:	00005597          	auipc	a1,0x5
    80003e5c:	8e858593          	addi	a1,a1,-1816 # 80008740 <syscalls+0x188>
    80003e60:	0067d517          	auipc	a0,0x67d
    80003e64:	78050513          	addi	a0,a0,1920 # 806815e0 <itable>
    80003e68:	ffffd097          	auipc	ra,0xffffd
    80003e6c:	eb0080e7          	jalr	-336(ra) # 80000d18 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003e70:	0067d497          	auipc	s1,0x67d
    80003e74:	79848493          	addi	s1,s1,1944 # 80681608 <itable+0x28>
    80003e78:	0067f997          	auipc	s3,0x67f
    80003e7c:	22098993          	addi	s3,s3,544 # 80683098 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003e80:	00005917          	auipc	s2,0x5
    80003e84:	8c890913          	addi	s2,s2,-1848 # 80008748 <syscalls+0x190>
    80003e88:	85ca                	mv	a1,s2
    80003e8a:	8526                	mv	a0,s1
    80003e8c:	00001097          	auipc	ra,0x1
    80003e90:	e3a080e7          	jalr	-454(ra) # 80004cc6 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003e94:	08848493          	addi	s1,s1,136
    80003e98:	ff3498e3          	bne	s1,s3,80003e88 <iinit+0x3e>
}
    80003e9c:	70a2                	ld	ra,40(sp)
    80003e9e:	7402                	ld	s0,32(sp)
    80003ea0:	64e2                	ld	s1,24(sp)
    80003ea2:	6942                	ld	s2,16(sp)
    80003ea4:	69a2                	ld	s3,8(sp)
    80003ea6:	6145                	addi	sp,sp,48
    80003ea8:	8082                	ret

0000000080003eaa <ialloc>:
{
    80003eaa:	715d                	addi	sp,sp,-80
    80003eac:	e486                	sd	ra,72(sp)
    80003eae:	e0a2                	sd	s0,64(sp)
    80003eb0:	fc26                	sd	s1,56(sp)
    80003eb2:	f84a                	sd	s2,48(sp)
    80003eb4:	f44e                	sd	s3,40(sp)
    80003eb6:	f052                	sd	s4,32(sp)
    80003eb8:	ec56                	sd	s5,24(sp)
    80003eba:	e85a                	sd	s6,16(sp)
    80003ebc:	e45e                	sd	s7,8(sp)
    80003ebe:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003ec0:	0067d717          	auipc	a4,0x67d
    80003ec4:	70c72703          	lw	a4,1804(a4) # 806815cc <sb+0xc>
    80003ec8:	4785                	li	a5,1
    80003eca:	04e7fa63          	bgeu	a5,a4,80003f1e <ialloc+0x74>
    80003ece:	8aaa                	mv	s5,a0
    80003ed0:	8bae                	mv	s7,a1
    80003ed2:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003ed4:	0067da17          	auipc	s4,0x67d
    80003ed8:	6eca0a13          	addi	s4,s4,1772 # 806815c0 <sb>
    80003edc:	00048b1b          	sext.w	s6,s1
    80003ee0:	0044d593          	srli	a1,s1,0x4
    80003ee4:	018a2783          	lw	a5,24(s4)
    80003ee8:	9dbd                	addw	a1,a1,a5
    80003eea:	8556                	mv	a0,s5
    80003eec:	00000097          	auipc	ra,0x0
    80003ef0:	940080e7          	jalr	-1728(ra) # 8000382c <bread>
    80003ef4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003ef6:	05850993          	addi	s3,a0,88
    80003efa:	00f4f793          	andi	a5,s1,15
    80003efe:	079a                	slli	a5,a5,0x6
    80003f00:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003f02:	00099783          	lh	a5,0(s3)
    80003f06:	c3a1                	beqz	a5,80003f46 <ialloc+0x9c>
    brelse(bp);
    80003f08:	00000097          	auipc	ra,0x0
    80003f0c:	a54080e7          	jalr	-1452(ra) # 8000395c <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003f10:	0485                	addi	s1,s1,1
    80003f12:	00ca2703          	lw	a4,12(s4)
    80003f16:	0004879b          	sext.w	a5,s1
    80003f1a:	fce7e1e3          	bltu	a5,a4,80003edc <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003f1e:	00005517          	auipc	a0,0x5
    80003f22:	83250513          	addi	a0,a0,-1998 # 80008750 <syscalls+0x198>
    80003f26:	ffffc097          	auipc	ra,0xffffc
    80003f2a:	668080e7          	jalr	1640(ra) # 8000058e <printf>
  return 0;
    80003f2e:	4501                	li	a0,0
}
    80003f30:	60a6                	ld	ra,72(sp)
    80003f32:	6406                	ld	s0,64(sp)
    80003f34:	74e2                	ld	s1,56(sp)
    80003f36:	7942                	ld	s2,48(sp)
    80003f38:	79a2                	ld	s3,40(sp)
    80003f3a:	7a02                	ld	s4,32(sp)
    80003f3c:	6ae2                	ld	s5,24(sp)
    80003f3e:	6b42                	ld	s6,16(sp)
    80003f40:	6ba2                	ld	s7,8(sp)
    80003f42:	6161                	addi	sp,sp,80
    80003f44:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003f46:	04000613          	li	a2,64
    80003f4a:	4581                	li	a1,0
    80003f4c:	854e                	mv	a0,s3
    80003f4e:	ffffd097          	auipc	ra,0xffffd
    80003f52:	f56080e7          	jalr	-170(ra) # 80000ea4 <memset>
      dip->type = type;
    80003f56:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003f5a:	854a                	mv	a0,s2
    80003f5c:	00001097          	auipc	ra,0x1
    80003f60:	c84080e7          	jalr	-892(ra) # 80004be0 <log_write>
      brelse(bp);
    80003f64:	854a                	mv	a0,s2
    80003f66:	00000097          	auipc	ra,0x0
    80003f6a:	9f6080e7          	jalr	-1546(ra) # 8000395c <brelse>
      return iget(dev, inum);
    80003f6e:	85da                	mv	a1,s6
    80003f70:	8556                	mv	a0,s5
    80003f72:	00000097          	auipc	ra,0x0
    80003f76:	d9c080e7          	jalr	-612(ra) # 80003d0e <iget>
    80003f7a:	bf5d                	j	80003f30 <ialloc+0x86>

0000000080003f7c <iupdate>:
{
    80003f7c:	1101                	addi	sp,sp,-32
    80003f7e:	ec06                	sd	ra,24(sp)
    80003f80:	e822                	sd	s0,16(sp)
    80003f82:	e426                	sd	s1,8(sp)
    80003f84:	e04a                	sd	s2,0(sp)
    80003f86:	1000                	addi	s0,sp,32
    80003f88:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003f8a:	415c                	lw	a5,4(a0)
    80003f8c:	0047d79b          	srliw	a5,a5,0x4
    80003f90:	0067d597          	auipc	a1,0x67d
    80003f94:	6485a583          	lw	a1,1608(a1) # 806815d8 <sb+0x18>
    80003f98:	9dbd                	addw	a1,a1,a5
    80003f9a:	4108                	lw	a0,0(a0)
    80003f9c:	00000097          	auipc	ra,0x0
    80003fa0:	890080e7          	jalr	-1904(ra) # 8000382c <bread>
    80003fa4:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003fa6:	05850793          	addi	a5,a0,88
    80003faa:	40c8                	lw	a0,4(s1)
    80003fac:	893d                	andi	a0,a0,15
    80003fae:	051a                	slli	a0,a0,0x6
    80003fb0:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003fb2:	04449703          	lh	a4,68(s1)
    80003fb6:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003fba:	04649703          	lh	a4,70(s1)
    80003fbe:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003fc2:	04849703          	lh	a4,72(s1)
    80003fc6:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003fca:	04a49703          	lh	a4,74(s1)
    80003fce:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003fd2:	44f8                	lw	a4,76(s1)
    80003fd4:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003fd6:	03400613          	li	a2,52
    80003fda:	05048593          	addi	a1,s1,80
    80003fde:	0531                	addi	a0,a0,12
    80003fe0:	ffffd097          	auipc	ra,0xffffd
    80003fe4:	f24080e7          	jalr	-220(ra) # 80000f04 <memmove>
  log_write(bp);
    80003fe8:	854a                	mv	a0,s2
    80003fea:	00001097          	auipc	ra,0x1
    80003fee:	bf6080e7          	jalr	-1034(ra) # 80004be0 <log_write>
  brelse(bp);
    80003ff2:	854a                	mv	a0,s2
    80003ff4:	00000097          	auipc	ra,0x0
    80003ff8:	968080e7          	jalr	-1688(ra) # 8000395c <brelse>
}
    80003ffc:	60e2                	ld	ra,24(sp)
    80003ffe:	6442                	ld	s0,16(sp)
    80004000:	64a2                	ld	s1,8(sp)
    80004002:	6902                	ld	s2,0(sp)
    80004004:	6105                	addi	sp,sp,32
    80004006:	8082                	ret

0000000080004008 <idup>:
{
    80004008:	1101                	addi	sp,sp,-32
    8000400a:	ec06                	sd	ra,24(sp)
    8000400c:	e822                	sd	s0,16(sp)
    8000400e:	e426                	sd	s1,8(sp)
    80004010:	1000                	addi	s0,sp,32
    80004012:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004014:	0067d517          	auipc	a0,0x67d
    80004018:	5cc50513          	addi	a0,a0,1484 # 806815e0 <itable>
    8000401c:	ffffd097          	auipc	ra,0xffffd
    80004020:	d8c080e7          	jalr	-628(ra) # 80000da8 <acquire>
  ip->ref++;
    80004024:	449c                	lw	a5,8(s1)
    80004026:	2785                	addiw	a5,a5,1
    80004028:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000402a:	0067d517          	auipc	a0,0x67d
    8000402e:	5b650513          	addi	a0,a0,1462 # 806815e0 <itable>
    80004032:	ffffd097          	auipc	ra,0xffffd
    80004036:	e2a080e7          	jalr	-470(ra) # 80000e5c <release>
}
    8000403a:	8526                	mv	a0,s1
    8000403c:	60e2                	ld	ra,24(sp)
    8000403e:	6442                	ld	s0,16(sp)
    80004040:	64a2                	ld	s1,8(sp)
    80004042:	6105                	addi	sp,sp,32
    80004044:	8082                	ret

0000000080004046 <ilock>:
{
    80004046:	1101                	addi	sp,sp,-32
    80004048:	ec06                	sd	ra,24(sp)
    8000404a:	e822                	sd	s0,16(sp)
    8000404c:	e426                	sd	s1,8(sp)
    8000404e:	e04a                	sd	s2,0(sp)
    80004050:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80004052:	c115                	beqz	a0,80004076 <ilock+0x30>
    80004054:	84aa                	mv	s1,a0
    80004056:	451c                	lw	a5,8(a0)
    80004058:	00f05f63          	blez	a5,80004076 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000405c:	0541                	addi	a0,a0,16
    8000405e:	00001097          	auipc	ra,0x1
    80004062:	ca2080e7          	jalr	-862(ra) # 80004d00 <acquiresleep>
  if(ip->valid == 0){
    80004066:	40bc                	lw	a5,64(s1)
    80004068:	cf99                	beqz	a5,80004086 <ilock+0x40>
}
    8000406a:	60e2                	ld	ra,24(sp)
    8000406c:	6442                	ld	s0,16(sp)
    8000406e:	64a2                	ld	s1,8(sp)
    80004070:	6902                	ld	s2,0(sp)
    80004072:	6105                	addi	sp,sp,32
    80004074:	8082                	ret
    panic("ilock");
    80004076:	00004517          	auipc	a0,0x4
    8000407a:	6f250513          	addi	a0,a0,1778 # 80008768 <syscalls+0x1b0>
    8000407e:	ffffc097          	auipc	ra,0xffffc
    80004082:	4c6080e7          	jalr	1222(ra) # 80000544 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004086:	40dc                	lw	a5,4(s1)
    80004088:	0047d79b          	srliw	a5,a5,0x4
    8000408c:	0067d597          	auipc	a1,0x67d
    80004090:	54c5a583          	lw	a1,1356(a1) # 806815d8 <sb+0x18>
    80004094:	9dbd                	addw	a1,a1,a5
    80004096:	4088                	lw	a0,0(s1)
    80004098:	fffff097          	auipc	ra,0xfffff
    8000409c:	794080e7          	jalr	1940(ra) # 8000382c <bread>
    800040a0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800040a2:	05850593          	addi	a1,a0,88
    800040a6:	40dc                	lw	a5,4(s1)
    800040a8:	8bbd                	andi	a5,a5,15
    800040aa:	079a                	slli	a5,a5,0x6
    800040ac:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800040ae:	00059783          	lh	a5,0(a1)
    800040b2:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800040b6:	00259783          	lh	a5,2(a1)
    800040ba:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800040be:	00459783          	lh	a5,4(a1)
    800040c2:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800040c6:	00659783          	lh	a5,6(a1)
    800040ca:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800040ce:	459c                	lw	a5,8(a1)
    800040d0:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800040d2:	03400613          	li	a2,52
    800040d6:	05b1                	addi	a1,a1,12
    800040d8:	05048513          	addi	a0,s1,80
    800040dc:	ffffd097          	auipc	ra,0xffffd
    800040e0:	e28080e7          	jalr	-472(ra) # 80000f04 <memmove>
    brelse(bp);
    800040e4:	854a                	mv	a0,s2
    800040e6:	00000097          	auipc	ra,0x0
    800040ea:	876080e7          	jalr	-1930(ra) # 8000395c <brelse>
    ip->valid = 1;
    800040ee:	4785                	li	a5,1
    800040f0:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800040f2:	04449783          	lh	a5,68(s1)
    800040f6:	fbb5                	bnez	a5,8000406a <ilock+0x24>
      panic("ilock: no type");
    800040f8:	00004517          	auipc	a0,0x4
    800040fc:	67850513          	addi	a0,a0,1656 # 80008770 <syscalls+0x1b8>
    80004100:	ffffc097          	auipc	ra,0xffffc
    80004104:	444080e7          	jalr	1092(ra) # 80000544 <panic>

0000000080004108 <iunlock>:
{
    80004108:	1101                	addi	sp,sp,-32
    8000410a:	ec06                	sd	ra,24(sp)
    8000410c:	e822                	sd	s0,16(sp)
    8000410e:	e426                	sd	s1,8(sp)
    80004110:	e04a                	sd	s2,0(sp)
    80004112:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80004114:	c905                	beqz	a0,80004144 <iunlock+0x3c>
    80004116:	84aa                	mv	s1,a0
    80004118:	01050913          	addi	s2,a0,16
    8000411c:	854a                	mv	a0,s2
    8000411e:	00001097          	auipc	ra,0x1
    80004122:	c7c080e7          	jalr	-900(ra) # 80004d9a <holdingsleep>
    80004126:	cd19                	beqz	a0,80004144 <iunlock+0x3c>
    80004128:	449c                	lw	a5,8(s1)
    8000412a:	00f05d63          	blez	a5,80004144 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000412e:	854a                	mv	a0,s2
    80004130:	00001097          	auipc	ra,0x1
    80004134:	c26080e7          	jalr	-986(ra) # 80004d56 <releasesleep>
}
    80004138:	60e2                	ld	ra,24(sp)
    8000413a:	6442                	ld	s0,16(sp)
    8000413c:	64a2                	ld	s1,8(sp)
    8000413e:	6902                	ld	s2,0(sp)
    80004140:	6105                	addi	sp,sp,32
    80004142:	8082                	ret
    panic("iunlock");
    80004144:	00004517          	auipc	a0,0x4
    80004148:	63c50513          	addi	a0,a0,1596 # 80008780 <syscalls+0x1c8>
    8000414c:	ffffc097          	auipc	ra,0xffffc
    80004150:	3f8080e7          	jalr	1016(ra) # 80000544 <panic>

0000000080004154 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80004154:	7179                	addi	sp,sp,-48
    80004156:	f406                	sd	ra,40(sp)
    80004158:	f022                	sd	s0,32(sp)
    8000415a:	ec26                	sd	s1,24(sp)
    8000415c:	e84a                	sd	s2,16(sp)
    8000415e:	e44e                	sd	s3,8(sp)
    80004160:	e052                	sd	s4,0(sp)
    80004162:	1800                	addi	s0,sp,48
    80004164:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80004166:	05050493          	addi	s1,a0,80
    8000416a:	08050913          	addi	s2,a0,128
    8000416e:	a021                	j	80004176 <itrunc+0x22>
    80004170:	0491                	addi	s1,s1,4
    80004172:	01248d63          	beq	s1,s2,8000418c <itrunc+0x38>
    if(ip->addrs[i]){
    80004176:	408c                	lw	a1,0(s1)
    80004178:	dde5                	beqz	a1,80004170 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    8000417a:	0009a503          	lw	a0,0(s3)
    8000417e:	00000097          	auipc	ra,0x0
    80004182:	8f4080e7          	jalr	-1804(ra) # 80003a72 <bfree>
      ip->addrs[i] = 0;
    80004186:	0004a023          	sw	zero,0(s1)
    8000418a:	b7dd                	j	80004170 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000418c:	0809a583          	lw	a1,128(s3)
    80004190:	e185                	bnez	a1,800041b0 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80004192:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80004196:	854e                	mv	a0,s3
    80004198:	00000097          	auipc	ra,0x0
    8000419c:	de4080e7          	jalr	-540(ra) # 80003f7c <iupdate>
}
    800041a0:	70a2                	ld	ra,40(sp)
    800041a2:	7402                	ld	s0,32(sp)
    800041a4:	64e2                	ld	s1,24(sp)
    800041a6:	6942                	ld	s2,16(sp)
    800041a8:	69a2                	ld	s3,8(sp)
    800041aa:	6a02                	ld	s4,0(sp)
    800041ac:	6145                	addi	sp,sp,48
    800041ae:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800041b0:	0009a503          	lw	a0,0(s3)
    800041b4:	fffff097          	auipc	ra,0xfffff
    800041b8:	678080e7          	jalr	1656(ra) # 8000382c <bread>
    800041bc:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800041be:	05850493          	addi	s1,a0,88
    800041c2:	45850913          	addi	s2,a0,1112
    800041c6:	a811                	j	800041da <itrunc+0x86>
        bfree(ip->dev, a[j]);
    800041c8:	0009a503          	lw	a0,0(s3)
    800041cc:	00000097          	auipc	ra,0x0
    800041d0:	8a6080e7          	jalr	-1882(ra) # 80003a72 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    800041d4:	0491                	addi	s1,s1,4
    800041d6:	01248563          	beq	s1,s2,800041e0 <itrunc+0x8c>
      if(a[j])
    800041da:	408c                	lw	a1,0(s1)
    800041dc:	dde5                	beqz	a1,800041d4 <itrunc+0x80>
    800041de:	b7ed                	j	800041c8 <itrunc+0x74>
    brelse(bp);
    800041e0:	8552                	mv	a0,s4
    800041e2:	fffff097          	auipc	ra,0xfffff
    800041e6:	77a080e7          	jalr	1914(ra) # 8000395c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800041ea:	0809a583          	lw	a1,128(s3)
    800041ee:	0009a503          	lw	a0,0(s3)
    800041f2:	00000097          	auipc	ra,0x0
    800041f6:	880080e7          	jalr	-1920(ra) # 80003a72 <bfree>
    ip->addrs[NDIRECT] = 0;
    800041fa:	0809a023          	sw	zero,128(s3)
    800041fe:	bf51                	j	80004192 <itrunc+0x3e>

0000000080004200 <iput>:
{
    80004200:	1101                	addi	sp,sp,-32
    80004202:	ec06                	sd	ra,24(sp)
    80004204:	e822                	sd	s0,16(sp)
    80004206:	e426                	sd	s1,8(sp)
    80004208:	e04a                	sd	s2,0(sp)
    8000420a:	1000                	addi	s0,sp,32
    8000420c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000420e:	0067d517          	auipc	a0,0x67d
    80004212:	3d250513          	addi	a0,a0,978 # 806815e0 <itable>
    80004216:	ffffd097          	auipc	ra,0xffffd
    8000421a:	b92080e7          	jalr	-1134(ra) # 80000da8 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000421e:	4498                	lw	a4,8(s1)
    80004220:	4785                	li	a5,1
    80004222:	02f70363          	beq	a4,a5,80004248 <iput+0x48>
  ip->ref--;
    80004226:	449c                	lw	a5,8(s1)
    80004228:	37fd                	addiw	a5,a5,-1
    8000422a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000422c:	0067d517          	auipc	a0,0x67d
    80004230:	3b450513          	addi	a0,a0,948 # 806815e0 <itable>
    80004234:	ffffd097          	auipc	ra,0xffffd
    80004238:	c28080e7          	jalr	-984(ra) # 80000e5c <release>
}
    8000423c:	60e2                	ld	ra,24(sp)
    8000423e:	6442                	ld	s0,16(sp)
    80004240:	64a2                	ld	s1,8(sp)
    80004242:	6902                	ld	s2,0(sp)
    80004244:	6105                	addi	sp,sp,32
    80004246:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004248:	40bc                	lw	a5,64(s1)
    8000424a:	dff1                	beqz	a5,80004226 <iput+0x26>
    8000424c:	04a49783          	lh	a5,74(s1)
    80004250:	fbf9                	bnez	a5,80004226 <iput+0x26>
    acquiresleep(&ip->lock);
    80004252:	01048913          	addi	s2,s1,16
    80004256:	854a                	mv	a0,s2
    80004258:	00001097          	auipc	ra,0x1
    8000425c:	aa8080e7          	jalr	-1368(ra) # 80004d00 <acquiresleep>
    release(&itable.lock);
    80004260:	0067d517          	auipc	a0,0x67d
    80004264:	38050513          	addi	a0,a0,896 # 806815e0 <itable>
    80004268:	ffffd097          	auipc	ra,0xffffd
    8000426c:	bf4080e7          	jalr	-1036(ra) # 80000e5c <release>
    itrunc(ip);
    80004270:	8526                	mv	a0,s1
    80004272:	00000097          	auipc	ra,0x0
    80004276:	ee2080e7          	jalr	-286(ra) # 80004154 <itrunc>
    ip->type = 0;
    8000427a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000427e:	8526                	mv	a0,s1
    80004280:	00000097          	auipc	ra,0x0
    80004284:	cfc080e7          	jalr	-772(ra) # 80003f7c <iupdate>
    ip->valid = 0;
    80004288:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000428c:	854a                	mv	a0,s2
    8000428e:	00001097          	auipc	ra,0x1
    80004292:	ac8080e7          	jalr	-1336(ra) # 80004d56 <releasesleep>
    acquire(&itable.lock);
    80004296:	0067d517          	auipc	a0,0x67d
    8000429a:	34a50513          	addi	a0,a0,842 # 806815e0 <itable>
    8000429e:	ffffd097          	auipc	ra,0xffffd
    800042a2:	b0a080e7          	jalr	-1270(ra) # 80000da8 <acquire>
    800042a6:	b741                	j	80004226 <iput+0x26>

00000000800042a8 <iunlockput>:
{
    800042a8:	1101                	addi	sp,sp,-32
    800042aa:	ec06                	sd	ra,24(sp)
    800042ac:	e822                	sd	s0,16(sp)
    800042ae:	e426                	sd	s1,8(sp)
    800042b0:	1000                	addi	s0,sp,32
    800042b2:	84aa                	mv	s1,a0
  iunlock(ip);
    800042b4:	00000097          	auipc	ra,0x0
    800042b8:	e54080e7          	jalr	-428(ra) # 80004108 <iunlock>
  iput(ip);
    800042bc:	8526                	mv	a0,s1
    800042be:	00000097          	auipc	ra,0x0
    800042c2:	f42080e7          	jalr	-190(ra) # 80004200 <iput>
}
    800042c6:	60e2                	ld	ra,24(sp)
    800042c8:	6442                	ld	s0,16(sp)
    800042ca:	64a2                	ld	s1,8(sp)
    800042cc:	6105                	addi	sp,sp,32
    800042ce:	8082                	ret

00000000800042d0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800042d0:	1141                	addi	sp,sp,-16
    800042d2:	e422                	sd	s0,8(sp)
    800042d4:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800042d6:	411c                	lw	a5,0(a0)
    800042d8:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800042da:	415c                	lw	a5,4(a0)
    800042dc:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800042de:	04451783          	lh	a5,68(a0)
    800042e2:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800042e6:	04a51783          	lh	a5,74(a0)
    800042ea:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800042ee:	04c56783          	lwu	a5,76(a0)
    800042f2:	e99c                	sd	a5,16(a1)
}
    800042f4:	6422                	ld	s0,8(sp)
    800042f6:	0141                	addi	sp,sp,16
    800042f8:	8082                	ret

00000000800042fa <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800042fa:	457c                	lw	a5,76(a0)
    800042fc:	0ed7e963          	bltu	a5,a3,800043ee <readi+0xf4>
{
    80004300:	7159                	addi	sp,sp,-112
    80004302:	f486                	sd	ra,104(sp)
    80004304:	f0a2                	sd	s0,96(sp)
    80004306:	eca6                	sd	s1,88(sp)
    80004308:	e8ca                	sd	s2,80(sp)
    8000430a:	e4ce                	sd	s3,72(sp)
    8000430c:	e0d2                	sd	s4,64(sp)
    8000430e:	fc56                	sd	s5,56(sp)
    80004310:	f85a                	sd	s6,48(sp)
    80004312:	f45e                	sd	s7,40(sp)
    80004314:	f062                	sd	s8,32(sp)
    80004316:	ec66                	sd	s9,24(sp)
    80004318:	e86a                	sd	s10,16(sp)
    8000431a:	e46e                	sd	s11,8(sp)
    8000431c:	1880                	addi	s0,sp,112
    8000431e:	8b2a                	mv	s6,a0
    80004320:	8bae                	mv	s7,a1
    80004322:	8a32                	mv	s4,a2
    80004324:	84b6                	mv	s1,a3
    80004326:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80004328:	9f35                	addw	a4,a4,a3
    return 0;
    8000432a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000432c:	0ad76063          	bltu	a4,a3,800043cc <readi+0xd2>
  if(off + n > ip->size)
    80004330:	00e7f463          	bgeu	a5,a4,80004338 <readi+0x3e>
    n = ip->size - off;
    80004334:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004338:	0a0a8963          	beqz	s5,800043ea <readi+0xf0>
    8000433c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000433e:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004342:	5c7d                	li	s8,-1
    80004344:	a82d                	j	8000437e <readi+0x84>
    80004346:	020d1d93          	slli	s11,s10,0x20
    8000434a:	020ddd93          	srli	s11,s11,0x20
    8000434e:	05890613          	addi	a2,s2,88
    80004352:	86ee                	mv	a3,s11
    80004354:	963a                	add	a2,a2,a4
    80004356:	85d2                	mv	a1,s4
    80004358:	855e                	mv	a0,s7
    8000435a:	ffffe097          	auipc	ra,0xffffe
    8000435e:	6a8080e7          	jalr	1704(ra) # 80002a02 <either_copyout>
    80004362:	05850d63          	beq	a0,s8,800043bc <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004366:	854a                	mv	a0,s2
    80004368:	fffff097          	auipc	ra,0xfffff
    8000436c:	5f4080e7          	jalr	1524(ra) # 8000395c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004370:	013d09bb          	addw	s3,s10,s3
    80004374:	009d04bb          	addw	s1,s10,s1
    80004378:	9a6e                	add	s4,s4,s11
    8000437a:	0559f763          	bgeu	s3,s5,800043c8 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    8000437e:	00a4d59b          	srliw	a1,s1,0xa
    80004382:	855a                	mv	a0,s6
    80004384:	00000097          	auipc	ra,0x0
    80004388:	8a2080e7          	jalr	-1886(ra) # 80003c26 <bmap>
    8000438c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004390:	cd85                	beqz	a1,800043c8 <readi+0xce>
    bp = bread(ip->dev, addr);
    80004392:	000b2503          	lw	a0,0(s6)
    80004396:	fffff097          	auipc	ra,0xfffff
    8000439a:	496080e7          	jalr	1174(ra) # 8000382c <bread>
    8000439e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800043a0:	3ff4f713          	andi	a4,s1,1023
    800043a4:	40ec87bb          	subw	a5,s9,a4
    800043a8:	413a86bb          	subw	a3,s5,s3
    800043ac:	8d3e                	mv	s10,a5
    800043ae:	2781                	sext.w	a5,a5
    800043b0:	0006861b          	sext.w	a2,a3
    800043b4:	f8f679e3          	bgeu	a2,a5,80004346 <readi+0x4c>
    800043b8:	8d36                	mv	s10,a3
    800043ba:	b771                	j	80004346 <readi+0x4c>
      brelse(bp);
    800043bc:	854a                	mv	a0,s2
    800043be:	fffff097          	auipc	ra,0xfffff
    800043c2:	59e080e7          	jalr	1438(ra) # 8000395c <brelse>
      tot = -1;
    800043c6:	59fd                	li	s3,-1
  }
  return tot;
    800043c8:	0009851b          	sext.w	a0,s3
}
    800043cc:	70a6                	ld	ra,104(sp)
    800043ce:	7406                	ld	s0,96(sp)
    800043d0:	64e6                	ld	s1,88(sp)
    800043d2:	6946                	ld	s2,80(sp)
    800043d4:	69a6                	ld	s3,72(sp)
    800043d6:	6a06                	ld	s4,64(sp)
    800043d8:	7ae2                	ld	s5,56(sp)
    800043da:	7b42                	ld	s6,48(sp)
    800043dc:	7ba2                	ld	s7,40(sp)
    800043de:	7c02                	ld	s8,32(sp)
    800043e0:	6ce2                	ld	s9,24(sp)
    800043e2:	6d42                	ld	s10,16(sp)
    800043e4:	6da2                	ld	s11,8(sp)
    800043e6:	6165                	addi	sp,sp,112
    800043e8:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800043ea:	89d6                	mv	s3,s5
    800043ec:	bff1                	j	800043c8 <readi+0xce>
    return 0;
    800043ee:	4501                	li	a0,0
}
    800043f0:	8082                	ret

00000000800043f2 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800043f2:	457c                	lw	a5,76(a0)
    800043f4:	10d7e863          	bltu	a5,a3,80004504 <writei+0x112>
{
    800043f8:	7159                	addi	sp,sp,-112
    800043fa:	f486                	sd	ra,104(sp)
    800043fc:	f0a2                	sd	s0,96(sp)
    800043fe:	eca6                	sd	s1,88(sp)
    80004400:	e8ca                	sd	s2,80(sp)
    80004402:	e4ce                	sd	s3,72(sp)
    80004404:	e0d2                	sd	s4,64(sp)
    80004406:	fc56                	sd	s5,56(sp)
    80004408:	f85a                	sd	s6,48(sp)
    8000440a:	f45e                	sd	s7,40(sp)
    8000440c:	f062                	sd	s8,32(sp)
    8000440e:	ec66                	sd	s9,24(sp)
    80004410:	e86a                	sd	s10,16(sp)
    80004412:	e46e                	sd	s11,8(sp)
    80004414:	1880                	addi	s0,sp,112
    80004416:	8aaa                	mv	s5,a0
    80004418:	8bae                	mv	s7,a1
    8000441a:	8a32                	mv	s4,a2
    8000441c:	8936                	mv	s2,a3
    8000441e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004420:	00e687bb          	addw	a5,a3,a4
    80004424:	0ed7e263          	bltu	a5,a3,80004508 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004428:	00043737          	lui	a4,0x43
    8000442c:	0ef76063          	bltu	a4,a5,8000450c <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004430:	0c0b0863          	beqz	s6,80004500 <writei+0x10e>
    80004434:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004436:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000443a:	5c7d                	li	s8,-1
    8000443c:	a091                	j	80004480 <writei+0x8e>
    8000443e:	020d1d93          	slli	s11,s10,0x20
    80004442:	020ddd93          	srli	s11,s11,0x20
    80004446:	05848513          	addi	a0,s1,88
    8000444a:	86ee                	mv	a3,s11
    8000444c:	8652                	mv	a2,s4
    8000444e:	85de                	mv	a1,s7
    80004450:	953a                	add	a0,a0,a4
    80004452:	ffffe097          	auipc	ra,0xffffe
    80004456:	606080e7          	jalr	1542(ra) # 80002a58 <either_copyin>
    8000445a:	07850263          	beq	a0,s8,800044be <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000445e:	8526                	mv	a0,s1
    80004460:	00000097          	auipc	ra,0x0
    80004464:	780080e7          	jalr	1920(ra) # 80004be0 <log_write>
    brelse(bp);
    80004468:	8526                	mv	a0,s1
    8000446a:	fffff097          	auipc	ra,0xfffff
    8000446e:	4f2080e7          	jalr	1266(ra) # 8000395c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004472:	013d09bb          	addw	s3,s10,s3
    80004476:	012d093b          	addw	s2,s10,s2
    8000447a:	9a6e                	add	s4,s4,s11
    8000447c:	0569f663          	bgeu	s3,s6,800044c8 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80004480:	00a9559b          	srliw	a1,s2,0xa
    80004484:	8556                	mv	a0,s5
    80004486:	fffff097          	auipc	ra,0xfffff
    8000448a:	7a0080e7          	jalr	1952(ra) # 80003c26 <bmap>
    8000448e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004492:	c99d                	beqz	a1,800044c8 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80004494:	000aa503          	lw	a0,0(s5)
    80004498:	fffff097          	auipc	ra,0xfffff
    8000449c:	394080e7          	jalr	916(ra) # 8000382c <bread>
    800044a0:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800044a2:	3ff97713          	andi	a4,s2,1023
    800044a6:	40ec87bb          	subw	a5,s9,a4
    800044aa:	413b06bb          	subw	a3,s6,s3
    800044ae:	8d3e                	mv	s10,a5
    800044b0:	2781                	sext.w	a5,a5
    800044b2:	0006861b          	sext.w	a2,a3
    800044b6:	f8f674e3          	bgeu	a2,a5,8000443e <writei+0x4c>
    800044ba:	8d36                	mv	s10,a3
    800044bc:	b749                	j	8000443e <writei+0x4c>
      brelse(bp);
    800044be:	8526                	mv	a0,s1
    800044c0:	fffff097          	auipc	ra,0xfffff
    800044c4:	49c080e7          	jalr	1180(ra) # 8000395c <brelse>
  }

  if(off > ip->size)
    800044c8:	04caa783          	lw	a5,76(s5)
    800044cc:	0127f463          	bgeu	a5,s2,800044d4 <writei+0xe2>
    ip->size = off;
    800044d0:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800044d4:	8556                	mv	a0,s5
    800044d6:	00000097          	auipc	ra,0x0
    800044da:	aa6080e7          	jalr	-1370(ra) # 80003f7c <iupdate>

  return tot;
    800044de:	0009851b          	sext.w	a0,s3
}
    800044e2:	70a6                	ld	ra,104(sp)
    800044e4:	7406                	ld	s0,96(sp)
    800044e6:	64e6                	ld	s1,88(sp)
    800044e8:	6946                	ld	s2,80(sp)
    800044ea:	69a6                	ld	s3,72(sp)
    800044ec:	6a06                	ld	s4,64(sp)
    800044ee:	7ae2                	ld	s5,56(sp)
    800044f0:	7b42                	ld	s6,48(sp)
    800044f2:	7ba2                	ld	s7,40(sp)
    800044f4:	7c02                	ld	s8,32(sp)
    800044f6:	6ce2                	ld	s9,24(sp)
    800044f8:	6d42                	ld	s10,16(sp)
    800044fa:	6da2                	ld	s11,8(sp)
    800044fc:	6165                	addi	sp,sp,112
    800044fe:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004500:	89da                	mv	s3,s6
    80004502:	bfc9                	j	800044d4 <writei+0xe2>
    return -1;
    80004504:	557d                	li	a0,-1
}
    80004506:	8082                	ret
    return -1;
    80004508:	557d                	li	a0,-1
    8000450a:	bfe1                	j	800044e2 <writei+0xf0>
    return -1;
    8000450c:	557d                	li	a0,-1
    8000450e:	bfd1                	j	800044e2 <writei+0xf0>

0000000080004510 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004510:	1141                	addi	sp,sp,-16
    80004512:	e406                	sd	ra,8(sp)
    80004514:	e022                	sd	s0,0(sp)
    80004516:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004518:	4639                	li	a2,14
    8000451a:	ffffd097          	auipc	ra,0xffffd
    8000451e:	a62080e7          	jalr	-1438(ra) # 80000f7c <strncmp>
}
    80004522:	60a2                	ld	ra,8(sp)
    80004524:	6402                	ld	s0,0(sp)
    80004526:	0141                	addi	sp,sp,16
    80004528:	8082                	ret

000000008000452a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000452a:	7139                	addi	sp,sp,-64
    8000452c:	fc06                	sd	ra,56(sp)
    8000452e:	f822                	sd	s0,48(sp)
    80004530:	f426                	sd	s1,40(sp)
    80004532:	f04a                	sd	s2,32(sp)
    80004534:	ec4e                	sd	s3,24(sp)
    80004536:	e852                	sd	s4,16(sp)
    80004538:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000453a:	04451703          	lh	a4,68(a0)
    8000453e:	4785                	li	a5,1
    80004540:	00f71a63          	bne	a4,a5,80004554 <dirlookup+0x2a>
    80004544:	892a                	mv	s2,a0
    80004546:	89ae                	mv	s3,a1
    80004548:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000454a:	457c                	lw	a5,76(a0)
    8000454c:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000454e:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004550:	e79d                	bnez	a5,8000457e <dirlookup+0x54>
    80004552:	a8a5                	j	800045ca <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004554:	00004517          	auipc	a0,0x4
    80004558:	23450513          	addi	a0,a0,564 # 80008788 <syscalls+0x1d0>
    8000455c:	ffffc097          	auipc	ra,0xffffc
    80004560:	fe8080e7          	jalr	-24(ra) # 80000544 <panic>
      panic("dirlookup read");
    80004564:	00004517          	auipc	a0,0x4
    80004568:	23c50513          	addi	a0,a0,572 # 800087a0 <syscalls+0x1e8>
    8000456c:	ffffc097          	auipc	ra,0xffffc
    80004570:	fd8080e7          	jalr	-40(ra) # 80000544 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004574:	24c1                	addiw	s1,s1,16
    80004576:	04c92783          	lw	a5,76(s2)
    8000457a:	04f4f763          	bgeu	s1,a5,800045c8 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000457e:	4741                	li	a4,16
    80004580:	86a6                	mv	a3,s1
    80004582:	fc040613          	addi	a2,s0,-64
    80004586:	4581                	li	a1,0
    80004588:	854a                	mv	a0,s2
    8000458a:	00000097          	auipc	ra,0x0
    8000458e:	d70080e7          	jalr	-656(ra) # 800042fa <readi>
    80004592:	47c1                	li	a5,16
    80004594:	fcf518e3          	bne	a0,a5,80004564 <dirlookup+0x3a>
    if(de.inum == 0)
    80004598:	fc045783          	lhu	a5,-64(s0)
    8000459c:	dfe1                	beqz	a5,80004574 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000459e:	fc240593          	addi	a1,s0,-62
    800045a2:	854e                	mv	a0,s3
    800045a4:	00000097          	auipc	ra,0x0
    800045a8:	f6c080e7          	jalr	-148(ra) # 80004510 <namecmp>
    800045ac:	f561                	bnez	a0,80004574 <dirlookup+0x4a>
      if(poff)
    800045ae:	000a0463          	beqz	s4,800045b6 <dirlookup+0x8c>
        *poff = off;
    800045b2:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800045b6:	fc045583          	lhu	a1,-64(s0)
    800045ba:	00092503          	lw	a0,0(s2)
    800045be:	fffff097          	auipc	ra,0xfffff
    800045c2:	750080e7          	jalr	1872(ra) # 80003d0e <iget>
    800045c6:	a011                	j	800045ca <dirlookup+0xa0>
  return 0;
    800045c8:	4501                	li	a0,0
}
    800045ca:	70e2                	ld	ra,56(sp)
    800045cc:	7442                	ld	s0,48(sp)
    800045ce:	74a2                	ld	s1,40(sp)
    800045d0:	7902                	ld	s2,32(sp)
    800045d2:	69e2                	ld	s3,24(sp)
    800045d4:	6a42                	ld	s4,16(sp)
    800045d6:	6121                	addi	sp,sp,64
    800045d8:	8082                	ret

00000000800045da <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800045da:	711d                	addi	sp,sp,-96
    800045dc:	ec86                	sd	ra,88(sp)
    800045de:	e8a2                	sd	s0,80(sp)
    800045e0:	e4a6                	sd	s1,72(sp)
    800045e2:	e0ca                	sd	s2,64(sp)
    800045e4:	fc4e                	sd	s3,56(sp)
    800045e6:	f852                	sd	s4,48(sp)
    800045e8:	f456                	sd	s5,40(sp)
    800045ea:	f05a                	sd	s6,32(sp)
    800045ec:	ec5e                	sd	s7,24(sp)
    800045ee:	e862                	sd	s8,16(sp)
    800045f0:	e466                	sd	s9,8(sp)
    800045f2:	1080                	addi	s0,sp,96
    800045f4:	84aa                	mv	s1,a0
    800045f6:	8b2e                	mv	s6,a1
    800045f8:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800045fa:	00054703          	lbu	a4,0(a0)
    800045fe:	02f00793          	li	a5,47
    80004602:	02f70363          	beq	a4,a5,80004628 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004606:	ffffd097          	auipc	ra,0xffffd
    8000460a:	6b2080e7          	jalr	1714(ra) # 80001cb8 <myproc>
    8000460e:	15853503          	ld	a0,344(a0)
    80004612:	00000097          	auipc	ra,0x0
    80004616:	9f6080e7          	jalr	-1546(ra) # 80004008 <idup>
    8000461a:	89aa                	mv	s3,a0
  while(*path == '/')
    8000461c:	02f00913          	li	s2,47
  len = path - s;
    80004620:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80004622:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004624:	4c05                	li	s8,1
    80004626:	a865                	j	800046de <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80004628:	4585                	li	a1,1
    8000462a:	4505                	li	a0,1
    8000462c:	fffff097          	auipc	ra,0xfffff
    80004630:	6e2080e7          	jalr	1762(ra) # 80003d0e <iget>
    80004634:	89aa                	mv	s3,a0
    80004636:	b7dd                	j	8000461c <namex+0x42>
      iunlockput(ip);
    80004638:	854e                	mv	a0,s3
    8000463a:	00000097          	auipc	ra,0x0
    8000463e:	c6e080e7          	jalr	-914(ra) # 800042a8 <iunlockput>
      return 0;
    80004642:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004644:	854e                	mv	a0,s3
    80004646:	60e6                	ld	ra,88(sp)
    80004648:	6446                	ld	s0,80(sp)
    8000464a:	64a6                	ld	s1,72(sp)
    8000464c:	6906                	ld	s2,64(sp)
    8000464e:	79e2                	ld	s3,56(sp)
    80004650:	7a42                	ld	s4,48(sp)
    80004652:	7aa2                	ld	s5,40(sp)
    80004654:	7b02                	ld	s6,32(sp)
    80004656:	6be2                	ld	s7,24(sp)
    80004658:	6c42                	ld	s8,16(sp)
    8000465a:	6ca2                	ld	s9,8(sp)
    8000465c:	6125                	addi	sp,sp,96
    8000465e:	8082                	ret
      iunlock(ip);
    80004660:	854e                	mv	a0,s3
    80004662:	00000097          	auipc	ra,0x0
    80004666:	aa6080e7          	jalr	-1370(ra) # 80004108 <iunlock>
      return ip;
    8000466a:	bfe9                	j	80004644 <namex+0x6a>
      iunlockput(ip);
    8000466c:	854e                	mv	a0,s3
    8000466e:	00000097          	auipc	ra,0x0
    80004672:	c3a080e7          	jalr	-966(ra) # 800042a8 <iunlockput>
      return 0;
    80004676:	89d2                	mv	s3,s4
    80004678:	b7f1                	j	80004644 <namex+0x6a>
  len = path - s;
    8000467a:	40b48633          	sub	a2,s1,a1
    8000467e:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80004682:	094cd463          	bge	s9,s4,8000470a <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004686:	4639                	li	a2,14
    80004688:	8556                	mv	a0,s5
    8000468a:	ffffd097          	auipc	ra,0xffffd
    8000468e:	87a080e7          	jalr	-1926(ra) # 80000f04 <memmove>
  while(*path == '/')
    80004692:	0004c783          	lbu	a5,0(s1)
    80004696:	01279763          	bne	a5,s2,800046a4 <namex+0xca>
    path++;
    8000469a:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000469c:	0004c783          	lbu	a5,0(s1)
    800046a0:	ff278de3          	beq	a5,s2,8000469a <namex+0xc0>
    ilock(ip);
    800046a4:	854e                	mv	a0,s3
    800046a6:	00000097          	auipc	ra,0x0
    800046aa:	9a0080e7          	jalr	-1632(ra) # 80004046 <ilock>
    if(ip->type != T_DIR){
    800046ae:	04499783          	lh	a5,68(s3)
    800046b2:	f98793e3          	bne	a5,s8,80004638 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800046b6:	000b0563          	beqz	s6,800046c0 <namex+0xe6>
    800046ba:	0004c783          	lbu	a5,0(s1)
    800046be:	d3cd                	beqz	a5,80004660 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800046c0:	865e                	mv	a2,s7
    800046c2:	85d6                	mv	a1,s5
    800046c4:	854e                	mv	a0,s3
    800046c6:	00000097          	auipc	ra,0x0
    800046ca:	e64080e7          	jalr	-412(ra) # 8000452a <dirlookup>
    800046ce:	8a2a                	mv	s4,a0
    800046d0:	dd51                	beqz	a0,8000466c <namex+0x92>
    iunlockput(ip);
    800046d2:	854e                	mv	a0,s3
    800046d4:	00000097          	auipc	ra,0x0
    800046d8:	bd4080e7          	jalr	-1068(ra) # 800042a8 <iunlockput>
    ip = next;
    800046dc:	89d2                	mv	s3,s4
  while(*path == '/')
    800046de:	0004c783          	lbu	a5,0(s1)
    800046e2:	05279763          	bne	a5,s2,80004730 <namex+0x156>
    path++;
    800046e6:	0485                	addi	s1,s1,1
  while(*path == '/')
    800046e8:	0004c783          	lbu	a5,0(s1)
    800046ec:	ff278de3          	beq	a5,s2,800046e6 <namex+0x10c>
  if(*path == 0)
    800046f0:	c79d                	beqz	a5,8000471e <namex+0x144>
    path++;
    800046f2:	85a6                	mv	a1,s1
  len = path - s;
    800046f4:	8a5e                	mv	s4,s7
    800046f6:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    800046f8:	01278963          	beq	a5,s2,8000470a <namex+0x130>
    800046fc:	dfbd                	beqz	a5,8000467a <namex+0xa0>
    path++;
    800046fe:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004700:	0004c783          	lbu	a5,0(s1)
    80004704:	ff279ce3          	bne	a5,s2,800046fc <namex+0x122>
    80004708:	bf8d                	j	8000467a <namex+0xa0>
    memmove(name, s, len);
    8000470a:	2601                	sext.w	a2,a2
    8000470c:	8556                	mv	a0,s5
    8000470e:	ffffc097          	auipc	ra,0xffffc
    80004712:	7f6080e7          	jalr	2038(ra) # 80000f04 <memmove>
    name[len] = 0;
    80004716:	9a56                	add	s4,s4,s5
    80004718:	000a0023          	sb	zero,0(s4)
    8000471c:	bf9d                	j	80004692 <namex+0xb8>
  if(nameiparent){
    8000471e:	f20b03e3          	beqz	s6,80004644 <namex+0x6a>
    iput(ip);
    80004722:	854e                	mv	a0,s3
    80004724:	00000097          	auipc	ra,0x0
    80004728:	adc080e7          	jalr	-1316(ra) # 80004200 <iput>
    return 0;
    8000472c:	4981                	li	s3,0
    8000472e:	bf19                	j	80004644 <namex+0x6a>
  if(*path == 0)
    80004730:	d7fd                	beqz	a5,8000471e <namex+0x144>
  while(*path != '/' && *path != 0)
    80004732:	0004c783          	lbu	a5,0(s1)
    80004736:	85a6                	mv	a1,s1
    80004738:	b7d1                	j	800046fc <namex+0x122>

000000008000473a <dirlink>:
{
    8000473a:	7139                	addi	sp,sp,-64
    8000473c:	fc06                	sd	ra,56(sp)
    8000473e:	f822                	sd	s0,48(sp)
    80004740:	f426                	sd	s1,40(sp)
    80004742:	f04a                	sd	s2,32(sp)
    80004744:	ec4e                	sd	s3,24(sp)
    80004746:	e852                	sd	s4,16(sp)
    80004748:	0080                	addi	s0,sp,64
    8000474a:	892a                	mv	s2,a0
    8000474c:	8a2e                	mv	s4,a1
    8000474e:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004750:	4601                	li	a2,0
    80004752:	00000097          	auipc	ra,0x0
    80004756:	dd8080e7          	jalr	-552(ra) # 8000452a <dirlookup>
    8000475a:	e93d                	bnez	a0,800047d0 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000475c:	04c92483          	lw	s1,76(s2)
    80004760:	c49d                	beqz	s1,8000478e <dirlink+0x54>
    80004762:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004764:	4741                	li	a4,16
    80004766:	86a6                	mv	a3,s1
    80004768:	fc040613          	addi	a2,s0,-64
    8000476c:	4581                	li	a1,0
    8000476e:	854a                	mv	a0,s2
    80004770:	00000097          	auipc	ra,0x0
    80004774:	b8a080e7          	jalr	-1142(ra) # 800042fa <readi>
    80004778:	47c1                	li	a5,16
    8000477a:	06f51163          	bne	a0,a5,800047dc <dirlink+0xa2>
    if(de.inum == 0)
    8000477e:	fc045783          	lhu	a5,-64(s0)
    80004782:	c791                	beqz	a5,8000478e <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004784:	24c1                	addiw	s1,s1,16
    80004786:	04c92783          	lw	a5,76(s2)
    8000478a:	fcf4ede3          	bltu	s1,a5,80004764 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000478e:	4639                	li	a2,14
    80004790:	85d2                	mv	a1,s4
    80004792:	fc240513          	addi	a0,s0,-62
    80004796:	ffffd097          	auipc	ra,0xffffd
    8000479a:	822080e7          	jalr	-2014(ra) # 80000fb8 <strncpy>
  de.inum = inum;
    8000479e:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800047a2:	4741                	li	a4,16
    800047a4:	86a6                	mv	a3,s1
    800047a6:	fc040613          	addi	a2,s0,-64
    800047aa:	4581                	li	a1,0
    800047ac:	854a                	mv	a0,s2
    800047ae:	00000097          	auipc	ra,0x0
    800047b2:	c44080e7          	jalr	-956(ra) # 800043f2 <writei>
    800047b6:	1541                	addi	a0,a0,-16
    800047b8:	00a03533          	snez	a0,a0
    800047bc:	40a00533          	neg	a0,a0
}
    800047c0:	70e2                	ld	ra,56(sp)
    800047c2:	7442                	ld	s0,48(sp)
    800047c4:	74a2                	ld	s1,40(sp)
    800047c6:	7902                	ld	s2,32(sp)
    800047c8:	69e2                	ld	s3,24(sp)
    800047ca:	6a42                	ld	s4,16(sp)
    800047cc:	6121                	addi	sp,sp,64
    800047ce:	8082                	ret
    iput(ip);
    800047d0:	00000097          	auipc	ra,0x0
    800047d4:	a30080e7          	jalr	-1488(ra) # 80004200 <iput>
    return -1;
    800047d8:	557d                	li	a0,-1
    800047da:	b7dd                	j	800047c0 <dirlink+0x86>
      panic("dirlink read");
    800047dc:	00004517          	auipc	a0,0x4
    800047e0:	fd450513          	addi	a0,a0,-44 # 800087b0 <syscalls+0x1f8>
    800047e4:	ffffc097          	auipc	ra,0xffffc
    800047e8:	d60080e7          	jalr	-672(ra) # 80000544 <panic>

00000000800047ec <namei>:

struct inode*
namei(char *path)
{
    800047ec:	1101                	addi	sp,sp,-32
    800047ee:	ec06                	sd	ra,24(sp)
    800047f0:	e822                	sd	s0,16(sp)
    800047f2:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800047f4:	fe040613          	addi	a2,s0,-32
    800047f8:	4581                	li	a1,0
    800047fa:	00000097          	auipc	ra,0x0
    800047fe:	de0080e7          	jalr	-544(ra) # 800045da <namex>
}
    80004802:	60e2                	ld	ra,24(sp)
    80004804:	6442                	ld	s0,16(sp)
    80004806:	6105                	addi	sp,sp,32
    80004808:	8082                	ret

000000008000480a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000480a:	1141                	addi	sp,sp,-16
    8000480c:	e406                	sd	ra,8(sp)
    8000480e:	e022                	sd	s0,0(sp)
    80004810:	0800                	addi	s0,sp,16
    80004812:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004814:	4585                	li	a1,1
    80004816:	00000097          	auipc	ra,0x0
    8000481a:	dc4080e7          	jalr	-572(ra) # 800045da <namex>
}
    8000481e:	60a2                	ld	ra,8(sp)
    80004820:	6402                	ld	s0,0(sp)
    80004822:	0141                	addi	sp,sp,16
    80004824:	8082                	ret

0000000080004826 <write_head>:
    80004826:	1101                	addi	sp,sp,-32
    80004828:	ec06                	sd	ra,24(sp)
    8000482a:	e822                	sd	s0,16(sp)
    8000482c:	e426                	sd	s1,8(sp)
    8000482e:	e04a                	sd	s2,0(sp)
    80004830:	1000                	addi	s0,sp,32
    80004832:	0067f917          	auipc	s2,0x67f
    80004836:	85690913          	addi	s2,s2,-1962 # 80683088 <log>
    8000483a:	01892583          	lw	a1,24(s2)
    8000483e:	02892503          	lw	a0,40(s2)
    80004842:	fffff097          	auipc	ra,0xfffff
    80004846:	fea080e7          	jalr	-22(ra) # 8000382c <bread>
    8000484a:	84aa                	mv	s1,a0
    8000484c:	02c92683          	lw	a3,44(s2)
    80004850:	cd34                	sw	a3,88(a0)
    80004852:	02d05763          	blez	a3,80004880 <write_head+0x5a>
    80004856:	0067f797          	auipc	a5,0x67f
    8000485a:	86278793          	addi	a5,a5,-1950 # 806830b8 <log+0x30>
    8000485e:	05c50713          	addi	a4,a0,92
    80004862:	36fd                	addiw	a3,a3,-1
    80004864:	1682                	slli	a3,a3,0x20
    80004866:	9281                	srli	a3,a3,0x20
    80004868:	068a                	slli	a3,a3,0x2
    8000486a:	0067f617          	auipc	a2,0x67f
    8000486e:	85260613          	addi	a2,a2,-1966 # 806830bc <log+0x34>
    80004872:	96b2                	add	a3,a3,a2
    80004874:	4390                	lw	a2,0(a5)
    80004876:	c310                	sw	a2,0(a4)
    80004878:	0791                	addi	a5,a5,4
    8000487a:	0711                	addi	a4,a4,4
    8000487c:	fed79ce3          	bne	a5,a3,80004874 <write_head+0x4e>
    80004880:	8526                	mv	a0,s1
    80004882:	fffff097          	auipc	ra,0xfffff
    80004886:	09c080e7          	jalr	156(ra) # 8000391e <bwrite>
    8000488a:	8526                	mv	a0,s1
    8000488c:	fffff097          	auipc	ra,0xfffff
    80004890:	0d0080e7          	jalr	208(ra) # 8000395c <brelse>
    80004894:	60e2                	ld	ra,24(sp)
    80004896:	6442                	ld	s0,16(sp)
    80004898:	64a2                	ld	s1,8(sp)
    8000489a:	6902                	ld	s2,0(sp)
    8000489c:	6105                	addi	sp,sp,32
    8000489e:	8082                	ret

00000000800048a0 <install_trans>:
    800048a0:	0067f797          	auipc	a5,0x67f
    800048a4:	8147a783          	lw	a5,-2028(a5) # 806830b4 <log+0x2c>
    800048a8:	0af05d63          	blez	a5,80004962 <install_trans+0xc2>
    800048ac:	7139                	addi	sp,sp,-64
    800048ae:	fc06                	sd	ra,56(sp)
    800048b0:	f822                	sd	s0,48(sp)
    800048b2:	f426                	sd	s1,40(sp)
    800048b4:	f04a                	sd	s2,32(sp)
    800048b6:	ec4e                	sd	s3,24(sp)
    800048b8:	e852                	sd	s4,16(sp)
    800048ba:	e456                	sd	s5,8(sp)
    800048bc:	e05a                	sd	s6,0(sp)
    800048be:	0080                	addi	s0,sp,64
    800048c0:	8b2a                	mv	s6,a0
    800048c2:	0067ea97          	auipc	s5,0x67e
    800048c6:	7f6a8a93          	addi	s5,s5,2038 # 806830b8 <log+0x30>
    800048ca:	4a01                	li	s4,0
    800048cc:	0067e997          	auipc	s3,0x67e
    800048d0:	7bc98993          	addi	s3,s3,1980 # 80683088 <log>
    800048d4:	a035                	j	80004900 <install_trans+0x60>
    800048d6:	8526                	mv	a0,s1
    800048d8:	fffff097          	auipc	ra,0xfffff
    800048dc:	15e080e7          	jalr	350(ra) # 80003a36 <bunpin>
    800048e0:	854a                	mv	a0,s2
    800048e2:	fffff097          	auipc	ra,0xfffff
    800048e6:	07a080e7          	jalr	122(ra) # 8000395c <brelse>
    800048ea:	8526                	mv	a0,s1
    800048ec:	fffff097          	auipc	ra,0xfffff
    800048f0:	070080e7          	jalr	112(ra) # 8000395c <brelse>
    800048f4:	2a05                	addiw	s4,s4,1
    800048f6:	0a91                	addi	s5,s5,4
    800048f8:	02c9a783          	lw	a5,44(s3)
    800048fc:	04fa5963          	bge	s4,a5,8000494e <install_trans+0xae>
    80004900:	0189a583          	lw	a1,24(s3)
    80004904:	014585bb          	addw	a1,a1,s4
    80004908:	2585                	addiw	a1,a1,1
    8000490a:	0289a503          	lw	a0,40(s3)
    8000490e:	fffff097          	auipc	ra,0xfffff
    80004912:	f1e080e7          	jalr	-226(ra) # 8000382c <bread>
    80004916:	892a                	mv	s2,a0
    80004918:	000aa583          	lw	a1,0(s5)
    8000491c:	0289a503          	lw	a0,40(s3)
    80004920:	fffff097          	auipc	ra,0xfffff
    80004924:	f0c080e7          	jalr	-244(ra) # 8000382c <bread>
    80004928:	84aa                	mv	s1,a0
    8000492a:	40000613          	li	a2,1024
    8000492e:	05890593          	addi	a1,s2,88
    80004932:	05850513          	addi	a0,a0,88
    80004936:	ffffc097          	auipc	ra,0xffffc
    8000493a:	5ce080e7          	jalr	1486(ra) # 80000f04 <memmove>
    8000493e:	8526                	mv	a0,s1
    80004940:	fffff097          	auipc	ra,0xfffff
    80004944:	fde080e7          	jalr	-34(ra) # 8000391e <bwrite>
    80004948:	f80b1ce3          	bnez	s6,800048e0 <install_trans+0x40>
    8000494c:	b769                	j	800048d6 <install_trans+0x36>
    8000494e:	70e2                	ld	ra,56(sp)
    80004950:	7442                	ld	s0,48(sp)
    80004952:	74a2                	ld	s1,40(sp)
    80004954:	7902                	ld	s2,32(sp)
    80004956:	69e2                	ld	s3,24(sp)
    80004958:	6a42                	ld	s4,16(sp)
    8000495a:	6aa2                	ld	s5,8(sp)
    8000495c:	6b02                	ld	s6,0(sp)
    8000495e:	6121                	addi	sp,sp,64
    80004960:	8082                	ret
    80004962:	8082                	ret

0000000080004964 <initlog>:
    80004964:	7179                	addi	sp,sp,-48
    80004966:	f406                	sd	ra,40(sp)
    80004968:	f022                	sd	s0,32(sp)
    8000496a:	ec26                	sd	s1,24(sp)
    8000496c:	e84a                	sd	s2,16(sp)
    8000496e:	e44e                	sd	s3,8(sp)
    80004970:	1800                	addi	s0,sp,48
    80004972:	892a                	mv	s2,a0
    80004974:	89ae                	mv	s3,a1
    80004976:	0067e497          	auipc	s1,0x67e
    8000497a:	71248493          	addi	s1,s1,1810 # 80683088 <log>
    8000497e:	00004597          	auipc	a1,0x4
    80004982:	e4258593          	addi	a1,a1,-446 # 800087c0 <syscalls+0x208>
    80004986:	8526                	mv	a0,s1
    80004988:	ffffc097          	auipc	ra,0xffffc
    8000498c:	390080e7          	jalr	912(ra) # 80000d18 <initlock>
    80004990:	0149a583          	lw	a1,20(s3)
    80004994:	cc8c                	sw	a1,24(s1)
    80004996:	0109a783          	lw	a5,16(s3)
    8000499a:	ccdc                	sw	a5,28(s1)
    8000499c:	0324a423          	sw	s2,40(s1)
    800049a0:	854a                	mv	a0,s2
    800049a2:	fffff097          	auipc	ra,0xfffff
    800049a6:	e8a080e7          	jalr	-374(ra) # 8000382c <bread>
    800049aa:	4d3c                	lw	a5,88(a0)
    800049ac:	d4dc                	sw	a5,44(s1)
    800049ae:	02f05563          	blez	a5,800049d8 <initlog+0x74>
    800049b2:	05c50713          	addi	a4,a0,92
    800049b6:	0067e697          	auipc	a3,0x67e
    800049ba:	70268693          	addi	a3,a3,1794 # 806830b8 <log+0x30>
    800049be:	37fd                	addiw	a5,a5,-1
    800049c0:	1782                	slli	a5,a5,0x20
    800049c2:	9381                	srli	a5,a5,0x20
    800049c4:	078a                	slli	a5,a5,0x2
    800049c6:	06050613          	addi	a2,a0,96
    800049ca:	97b2                	add	a5,a5,a2
    800049cc:	4310                	lw	a2,0(a4)
    800049ce:	c290                	sw	a2,0(a3)
    800049d0:	0711                	addi	a4,a4,4
    800049d2:	0691                	addi	a3,a3,4
    800049d4:	fef71ce3          	bne	a4,a5,800049cc <initlog+0x68>
    800049d8:	fffff097          	auipc	ra,0xfffff
    800049dc:	f84080e7          	jalr	-124(ra) # 8000395c <brelse>
    800049e0:	4505                	li	a0,1
    800049e2:	00000097          	auipc	ra,0x0
    800049e6:	ebe080e7          	jalr	-322(ra) # 800048a0 <install_trans>
    800049ea:	0067e797          	auipc	a5,0x67e
    800049ee:	6c07a523          	sw	zero,1738(a5) # 806830b4 <log+0x2c>
    800049f2:	00000097          	auipc	ra,0x0
    800049f6:	e34080e7          	jalr	-460(ra) # 80004826 <write_head>
    800049fa:	70a2                	ld	ra,40(sp)
    800049fc:	7402                	ld	s0,32(sp)
    800049fe:	64e2                	ld	s1,24(sp)
    80004a00:	6942                	ld	s2,16(sp)
    80004a02:	69a2                	ld	s3,8(sp)
    80004a04:	6145                	addi	sp,sp,48
    80004a06:	8082                	ret

0000000080004a08 <begin_op>:
    80004a08:	1101                	addi	sp,sp,-32
    80004a0a:	ec06                	sd	ra,24(sp)
    80004a0c:	e822                	sd	s0,16(sp)
    80004a0e:	e426                	sd	s1,8(sp)
    80004a10:	e04a                	sd	s2,0(sp)
    80004a12:	1000                	addi	s0,sp,32
    80004a14:	0067e517          	auipc	a0,0x67e
    80004a18:	67450513          	addi	a0,a0,1652 # 80683088 <log>
    80004a1c:	ffffc097          	auipc	ra,0xffffc
    80004a20:	38c080e7          	jalr	908(ra) # 80000da8 <acquire>
    80004a24:	0067e497          	auipc	s1,0x67e
    80004a28:	66448493          	addi	s1,s1,1636 # 80683088 <log>
    80004a2c:	4979                	li	s2,30
    80004a2e:	a039                	j	80004a3c <begin_op+0x34>
    80004a30:	85a6                	mv	a1,s1
    80004a32:	8526                	mv	a0,s1
    80004a34:	ffffe097          	auipc	ra,0xffffe
    80004a38:	9f4080e7          	jalr	-1548(ra) # 80002428 <sleep>
    80004a3c:	50dc                	lw	a5,36(s1)
    80004a3e:	fbed                	bnez	a5,80004a30 <begin_op+0x28>
    80004a40:	509c                	lw	a5,32(s1)
    80004a42:	0017871b          	addiw	a4,a5,1
    80004a46:	0007069b          	sext.w	a3,a4
    80004a4a:	0027179b          	slliw	a5,a4,0x2
    80004a4e:	9fb9                	addw	a5,a5,a4
    80004a50:	0017979b          	slliw	a5,a5,0x1
    80004a54:	54d8                	lw	a4,44(s1)
    80004a56:	9fb9                	addw	a5,a5,a4
    80004a58:	00f95963          	bge	s2,a5,80004a6a <begin_op+0x62>
    80004a5c:	85a6                	mv	a1,s1
    80004a5e:	8526                	mv	a0,s1
    80004a60:	ffffe097          	auipc	ra,0xffffe
    80004a64:	9c8080e7          	jalr	-1592(ra) # 80002428 <sleep>
    80004a68:	bfd1                	j	80004a3c <begin_op+0x34>
    80004a6a:	0067e517          	auipc	a0,0x67e
    80004a6e:	61e50513          	addi	a0,a0,1566 # 80683088 <log>
    80004a72:	d114                	sw	a3,32(a0)
    80004a74:	ffffc097          	auipc	ra,0xffffc
    80004a78:	3e8080e7          	jalr	1000(ra) # 80000e5c <release>
    80004a7c:	60e2                	ld	ra,24(sp)
    80004a7e:	6442                	ld	s0,16(sp)
    80004a80:	64a2                	ld	s1,8(sp)
    80004a82:	6902                	ld	s2,0(sp)
    80004a84:	6105                	addi	sp,sp,32
    80004a86:	8082                	ret

0000000080004a88 <end_op>:
    80004a88:	7139                	addi	sp,sp,-64
    80004a8a:	fc06                	sd	ra,56(sp)
    80004a8c:	f822                	sd	s0,48(sp)
    80004a8e:	f426                	sd	s1,40(sp)
    80004a90:	f04a                	sd	s2,32(sp)
    80004a92:	ec4e                	sd	s3,24(sp)
    80004a94:	e852                	sd	s4,16(sp)
    80004a96:	e456                	sd	s5,8(sp)
    80004a98:	0080                	addi	s0,sp,64
    80004a9a:	0067e497          	auipc	s1,0x67e
    80004a9e:	5ee48493          	addi	s1,s1,1518 # 80683088 <log>
    80004aa2:	8526                	mv	a0,s1
    80004aa4:	ffffc097          	auipc	ra,0xffffc
    80004aa8:	304080e7          	jalr	772(ra) # 80000da8 <acquire>
    80004aac:	509c                	lw	a5,32(s1)
    80004aae:	37fd                	addiw	a5,a5,-1
    80004ab0:	0007891b          	sext.w	s2,a5
    80004ab4:	d09c                	sw	a5,32(s1)
    80004ab6:	50dc                	lw	a5,36(s1)
    80004ab8:	efb9                	bnez	a5,80004b16 <end_op+0x8e>
    80004aba:	06091663          	bnez	s2,80004b26 <end_op+0x9e>
    80004abe:	0067e497          	auipc	s1,0x67e
    80004ac2:	5ca48493          	addi	s1,s1,1482 # 80683088 <log>
    80004ac6:	4785                	li	a5,1
    80004ac8:	d0dc                	sw	a5,36(s1)
    80004aca:	8526                	mv	a0,s1
    80004acc:	ffffc097          	auipc	ra,0xffffc
    80004ad0:	390080e7          	jalr	912(ra) # 80000e5c <release>
    80004ad4:	54dc                	lw	a5,44(s1)
    80004ad6:	06f04763          	bgtz	a5,80004b44 <end_op+0xbc>
    80004ada:	0067e497          	auipc	s1,0x67e
    80004ade:	5ae48493          	addi	s1,s1,1454 # 80683088 <log>
    80004ae2:	8526                	mv	a0,s1
    80004ae4:	ffffc097          	auipc	ra,0xffffc
    80004ae8:	2c4080e7          	jalr	708(ra) # 80000da8 <acquire>
    80004aec:	0204a223          	sw	zero,36(s1)
    80004af0:	8526                	mv	a0,s1
    80004af2:	ffffe097          	auipc	ra,0xffffe
    80004af6:	c34080e7          	jalr	-972(ra) # 80002726 <wakeup>
    80004afa:	8526                	mv	a0,s1
    80004afc:	ffffc097          	auipc	ra,0xffffc
    80004b00:	360080e7          	jalr	864(ra) # 80000e5c <release>
    80004b04:	70e2                	ld	ra,56(sp)
    80004b06:	7442                	ld	s0,48(sp)
    80004b08:	74a2                	ld	s1,40(sp)
    80004b0a:	7902                	ld	s2,32(sp)
    80004b0c:	69e2                	ld	s3,24(sp)
    80004b0e:	6a42                	ld	s4,16(sp)
    80004b10:	6aa2                	ld	s5,8(sp)
    80004b12:	6121                	addi	sp,sp,64
    80004b14:	8082                	ret
    80004b16:	00004517          	auipc	a0,0x4
    80004b1a:	cb250513          	addi	a0,a0,-846 # 800087c8 <syscalls+0x210>
    80004b1e:	ffffc097          	auipc	ra,0xffffc
    80004b22:	a26080e7          	jalr	-1498(ra) # 80000544 <panic>
    80004b26:	0067e497          	auipc	s1,0x67e
    80004b2a:	56248493          	addi	s1,s1,1378 # 80683088 <log>
    80004b2e:	8526                	mv	a0,s1
    80004b30:	ffffe097          	auipc	ra,0xffffe
    80004b34:	bf6080e7          	jalr	-1034(ra) # 80002726 <wakeup>
    80004b38:	8526                	mv	a0,s1
    80004b3a:	ffffc097          	auipc	ra,0xffffc
    80004b3e:	322080e7          	jalr	802(ra) # 80000e5c <release>
    80004b42:	b7c9                	j	80004b04 <end_op+0x7c>
    80004b44:	0067ea97          	auipc	s5,0x67e
    80004b48:	574a8a93          	addi	s5,s5,1396 # 806830b8 <log+0x30>
    80004b4c:	0067ea17          	auipc	s4,0x67e
    80004b50:	53ca0a13          	addi	s4,s4,1340 # 80683088 <log>
    80004b54:	018a2583          	lw	a1,24(s4)
    80004b58:	012585bb          	addw	a1,a1,s2
    80004b5c:	2585                	addiw	a1,a1,1
    80004b5e:	028a2503          	lw	a0,40(s4)
    80004b62:	fffff097          	auipc	ra,0xfffff
    80004b66:	cca080e7          	jalr	-822(ra) # 8000382c <bread>
    80004b6a:	84aa                	mv	s1,a0
    80004b6c:	000aa583          	lw	a1,0(s5)
    80004b70:	028a2503          	lw	a0,40(s4)
    80004b74:	fffff097          	auipc	ra,0xfffff
    80004b78:	cb8080e7          	jalr	-840(ra) # 8000382c <bread>
    80004b7c:	89aa                	mv	s3,a0
    80004b7e:	40000613          	li	a2,1024
    80004b82:	05850593          	addi	a1,a0,88
    80004b86:	05848513          	addi	a0,s1,88
    80004b8a:	ffffc097          	auipc	ra,0xffffc
    80004b8e:	37a080e7          	jalr	890(ra) # 80000f04 <memmove>
    80004b92:	8526                	mv	a0,s1
    80004b94:	fffff097          	auipc	ra,0xfffff
    80004b98:	d8a080e7          	jalr	-630(ra) # 8000391e <bwrite>
    80004b9c:	854e                	mv	a0,s3
    80004b9e:	fffff097          	auipc	ra,0xfffff
    80004ba2:	dbe080e7          	jalr	-578(ra) # 8000395c <brelse>
    80004ba6:	8526                	mv	a0,s1
    80004ba8:	fffff097          	auipc	ra,0xfffff
    80004bac:	db4080e7          	jalr	-588(ra) # 8000395c <brelse>
    80004bb0:	2905                	addiw	s2,s2,1
    80004bb2:	0a91                	addi	s5,s5,4
    80004bb4:	02ca2783          	lw	a5,44(s4)
    80004bb8:	f8f94ee3          	blt	s2,a5,80004b54 <end_op+0xcc>
    80004bbc:	00000097          	auipc	ra,0x0
    80004bc0:	c6a080e7          	jalr	-918(ra) # 80004826 <write_head>
    80004bc4:	4501                	li	a0,0
    80004bc6:	00000097          	auipc	ra,0x0
    80004bca:	cda080e7          	jalr	-806(ra) # 800048a0 <install_trans>
    80004bce:	0067e797          	auipc	a5,0x67e
    80004bd2:	4e07a323          	sw	zero,1254(a5) # 806830b4 <log+0x2c>
    80004bd6:	00000097          	auipc	ra,0x0
    80004bda:	c50080e7          	jalr	-944(ra) # 80004826 <write_head>
    80004bde:	bdf5                	j	80004ada <end_op+0x52>

0000000080004be0 <log_write>:
    80004be0:	1101                	addi	sp,sp,-32
    80004be2:	ec06                	sd	ra,24(sp)
    80004be4:	e822                	sd	s0,16(sp)
    80004be6:	e426                	sd	s1,8(sp)
    80004be8:	e04a                	sd	s2,0(sp)
    80004bea:	1000                	addi	s0,sp,32
    80004bec:	84aa                	mv	s1,a0
    80004bee:	0067e917          	auipc	s2,0x67e
    80004bf2:	49a90913          	addi	s2,s2,1178 # 80683088 <log>
    80004bf6:	854a                	mv	a0,s2
    80004bf8:	ffffc097          	auipc	ra,0xffffc
    80004bfc:	1b0080e7          	jalr	432(ra) # 80000da8 <acquire>
    80004c00:	02c92603          	lw	a2,44(s2)
    80004c04:	47f5                	li	a5,29
    80004c06:	06c7c563          	blt	a5,a2,80004c70 <log_write+0x90>
    80004c0a:	0067e797          	auipc	a5,0x67e
    80004c0e:	49a7a783          	lw	a5,1178(a5) # 806830a4 <log+0x1c>
    80004c12:	37fd                	addiw	a5,a5,-1
    80004c14:	04f65e63          	bge	a2,a5,80004c70 <log_write+0x90>
    80004c18:	0067e797          	auipc	a5,0x67e
    80004c1c:	4907a783          	lw	a5,1168(a5) # 806830a8 <log+0x20>
    80004c20:	06f05063          	blez	a5,80004c80 <log_write+0xa0>
    80004c24:	4781                	li	a5,0
    80004c26:	06c05563          	blez	a2,80004c90 <log_write+0xb0>
    80004c2a:	44cc                	lw	a1,12(s1)
    80004c2c:	0067e717          	auipc	a4,0x67e
    80004c30:	48c70713          	addi	a4,a4,1164 # 806830b8 <log+0x30>
    80004c34:	4781                	li	a5,0
    80004c36:	4314                	lw	a3,0(a4)
    80004c38:	04b68c63          	beq	a3,a1,80004c90 <log_write+0xb0>
    80004c3c:	2785                	addiw	a5,a5,1
    80004c3e:	0711                	addi	a4,a4,4
    80004c40:	fef61be3          	bne	a2,a5,80004c36 <log_write+0x56>
    80004c44:	0621                	addi	a2,a2,8
    80004c46:	060a                	slli	a2,a2,0x2
    80004c48:	0067e797          	auipc	a5,0x67e
    80004c4c:	44078793          	addi	a5,a5,1088 # 80683088 <log>
    80004c50:	963e                	add	a2,a2,a5
    80004c52:	44dc                	lw	a5,12(s1)
    80004c54:	ca1c                	sw	a5,16(a2)
    80004c56:	8526                	mv	a0,s1
    80004c58:	fffff097          	auipc	ra,0xfffff
    80004c5c:	da2080e7          	jalr	-606(ra) # 800039fa <bpin>
    80004c60:	0067e717          	auipc	a4,0x67e
    80004c64:	42870713          	addi	a4,a4,1064 # 80683088 <log>
    80004c68:	575c                	lw	a5,44(a4)
    80004c6a:	2785                	addiw	a5,a5,1
    80004c6c:	d75c                	sw	a5,44(a4)
    80004c6e:	a835                	j	80004caa <log_write+0xca>
    80004c70:	00004517          	auipc	a0,0x4
    80004c74:	b6850513          	addi	a0,a0,-1176 # 800087d8 <syscalls+0x220>
    80004c78:	ffffc097          	auipc	ra,0xffffc
    80004c7c:	8cc080e7          	jalr	-1844(ra) # 80000544 <panic>
    80004c80:	00004517          	auipc	a0,0x4
    80004c84:	b7050513          	addi	a0,a0,-1168 # 800087f0 <syscalls+0x238>
    80004c88:	ffffc097          	auipc	ra,0xffffc
    80004c8c:	8bc080e7          	jalr	-1860(ra) # 80000544 <panic>
    80004c90:	00878713          	addi	a4,a5,8
    80004c94:	00271693          	slli	a3,a4,0x2
    80004c98:	0067e717          	auipc	a4,0x67e
    80004c9c:	3f070713          	addi	a4,a4,1008 # 80683088 <log>
    80004ca0:	9736                	add	a4,a4,a3
    80004ca2:	44d4                	lw	a3,12(s1)
    80004ca4:	cb14                	sw	a3,16(a4)
    80004ca6:	faf608e3          	beq	a2,a5,80004c56 <log_write+0x76>
    80004caa:	0067e517          	auipc	a0,0x67e
    80004cae:	3de50513          	addi	a0,a0,990 # 80683088 <log>
    80004cb2:	ffffc097          	auipc	ra,0xffffc
    80004cb6:	1aa080e7          	jalr	426(ra) # 80000e5c <release>
    80004cba:	60e2                	ld	ra,24(sp)
    80004cbc:	6442                	ld	s0,16(sp)
    80004cbe:	64a2                	ld	s1,8(sp)
    80004cc0:	6902                	ld	s2,0(sp)
    80004cc2:	6105                	addi	sp,sp,32
    80004cc4:	8082                	ret

0000000080004cc6 <initsleeplock>:
    80004cc6:	1101                	addi	sp,sp,-32
    80004cc8:	ec06                	sd	ra,24(sp)
    80004cca:	e822                	sd	s0,16(sp)
    80004ccc:	e426                	sd	s1,8(sp)
    80004cce:	e04a                	sd	s2,0(sp)
    80004cd0:	1000                	addi	s0,sp,32
    80004cd2:	84aa                	mv	s1,a0
    80004cd4:	892e                	mv	s2,a1
    80004cd6:	00004597          	auipc	a1,0x4
    80004cda:	b3a58593          	addi	a1,a1,-1222 # 80008810 <syscalls+0x258>
    80004cde:	0521                	addi	a0,a0,8
    80004ce0:	ffffc097          	auipc	ra,0xffffc
    80004ce4:	038080e7          	jalr	56(ra) # 80000d18 <initlock>
    80004ce8:	0324b023          	sd	s2,32(s1)
    80004cec:	0004a023          	sw	zero,0(s1)
    80004cf0:	0204a423          	sw	zero,40(s1)
    80004cf4:	60e2                	ld	ra,24(sp)
    80004cf6:	6442                	ld	s0,16(sp)
    80004cf8:	64a2                	ld	s1,8(sp)
    80004cfa:	6902                	ld	s2,0(sp)
    80004cfc:	6105                	addi	sp,sp,32
    80004cfe:	8082                	ret

0000000080004d00 <acquiresleep>:
    80004d00:	1101                	addi	sp,sp,-32
    80004d02:	ec06                	sd	ra,24(sp)
    80004d04:	e822                	sd	s0,16(sp)
    80004d06:	e426                	sd	s1,8(sp)
    80004d08:	e04a                	sd	s2,0(sp)
    80004d0a:	1000                	addi	s0,sp,32
    80004d0c:	84aa                	mv	s1,a0
    80004d0e:	00850913          	addi	s2,a0,8
    80004d12:	854a                	mv	a0,s2
    80004d14:	ffffc097          	auipc	ra,0xffffc
    80004d18:	094080e7          	jalr	148(ra) # 80000da8 <acquire>
    80004d1c:	409c                	lw	a5,0(s1)
    80004d1e:	cb89                	beqz	a5,80004d30 <acquiresleep+0x30>
    80004d20:	85ca                	mv	a1,s2
    80004d22:	8526                	mv	a0,s1
    80004d24:	ffffd097          	auipc	ra,0xffffd
    80004d28:	704080e7          	jalr	1796(ra) # 80002428 <sleep>
    80004d2c:	409c                	lw	a5,0(s1)
    80004d2e:	fbed                	bnez	a5,80004d20 <acquiresleep+0x20>
    80004d30:	4785                	li	a5,1
    80004d32:	c09c                	sw	a5,0(s1)
    80004d34:	ffffd097          	auipc	ra,0xffffd
    80004d38:	f84080e7          	jalr	-124(ra) # 80001cb8 <myproc>
    80004d3c:	5d1c                	lw	a5,56(a0)
    80004d3e:	d49c                	sw	a5,40(s1)
    80004d40:	854a                	mv	a0,s2
    80004d42:	ffffc097          	auipc	ra,0xffffc
    80004d46:	11a080e7          	jalr	282(ra) # 80000e5c <release>
    80004d4a:	60e2                	ld	ra,24(sp)
    80004d4c:	6442                	ld	s0,16(sp)
    80004d4e:	64a2                	ld	s1,8(sp)
    80004d50:	6902                	ld	s2,0(sp)
    80004d52:	6105                	addi	sp,sp,32
    80004d54:	8082                	ret

0000000080004d56 <releasesleep>:
    80004d56:	1101                	addi	sp,sp,-32
    80004d58:	ec06                	sd	ra,24(sp)
    80004d5a:	e822                	sd	s0,16(sp)
    80004d5c:	e426                	sd	s1,8(sp)
    80004d5e:	e04a                	sd	s2,0(sp)
    80004d60:	1000                	addi	s0,sp,32
    80004d62:	84aa                	mv	s1,a0
    80004d64:	00850913          	addi	s2,a0,8
    80004d68:	854a                	mv	a0,s2
    80004d6a:	ffffc097          	auipc	ra,0xffffc
    80004d6e:	03e080e7          	jalr	62(ra) # 80000da8 <acquire>
    80004d72:	0004a023          	sw	zero,0(s1)
    80004d76:	0204a423          	sw	zero,40(s1)
    80004d7a:	8526                	mv	a0,s1
    80004d7c:	ffffe097          	auipc	ra,0xffffe
    80004d80:	9aa080e7          	jalr	-1622(ra) # 80002726 <wakeup>
    80004d84:	854a                	mv	a0,s2
    80004d86:	ffffc097          	auipc	ra,0xffffc
    80004d8a:	0d6080e7          	jalr	214(ra) # 80000e5c <release>
    80004d8e:	60e2                	ld	ra,24(sp)
    80004d90:	6442                	ld	s0,16(sp)
    80004d92:	64a2                	ld	s1,8(sp)
    80004d94:	6902                	ld	s2,0(sp)
    80004d96:	6105                	addi	sp,sp,32
    80004d98:	8082                	ret

0000000080004d9a <holdingsleep>:
    80004d9a:	7179                	addi	sp,sp,-48
    80004d9c:	f406                	sd	ra,40(sp)
    80004d9e:	f022                	sd	s0,32(sp)
    80004da0:	ec26                	sd	s1,24(sp)
    80004da2:	e84a                	sd	s2,16(sp)
    80004da4:	e44e                	sd	s3,8(sp)
    80004da6:	1800                	addi	s0,sp,48
    80004da8:	84aa                	mv	s1,a0
    80004daa:	00850913          	addi	s2,a0,8
    80004dae:	854a                	mv	a0,s2
    80004db0:	ffffc097          	auipc	ra,0xffffc
    80004db4:	ff8080e7          	jalr	-8(ra) # 80000da8 <acquire>
    80004db8:	409c                	lw	a5,0(s1)
    80004dba:	ef99                	bnez	a5,80004dd8 <holdingsleep+0x3e>
    80004dbc:	4481                	li	s1,0
    80004dbe:	854a                	mv	a0,s2
    80004dc0:	ffffc097          	auipc	ra,0xffffc
    80004dc4:	09c080e7          	jalr	156(ra) # 80000e5c <release>
    80004dc8:	8526                	mv	a0,s1
    80004dca:	70a2                	ld	ra,40(sp)
    80004dcc:	7402                	ld	s0,32(sp)
    80004dce:	64e2                	ld	s1,24(sp)
    80004dd0:	6942                	ld	s2,16(sp)
    80004dd2:	69a2                	ld	s3,8(sp)
    80004dd4:	6145                	addi	sp,sp,48
    80004dd6:	8082                	ret
    80004dd8:	0284a983          	lw	s3,40(s1)
    80004ddc:	ffffd097          	auipc	ra,0xffffd
    80004de0:	edc080e7          	jalr	-292(ra) # 80001cb8 <myproc>
    80004de4:	5d04                	lw	s1,56(a0)
    80004de6:	413484b3          	sub	s1,s1,s3
    80004dea:	0014b493          	seqz	s1,s1
    80004dee:	bfc1                	j	80004dbe <holdingsleep+0x24>

0000000080004df0 <fileinit>:
	struct spinlock lock;
	struct file file[NFILE];
} ftable;

void fileinit(void)
{
    80004df0:	1141                	addi	sp,sp,-16
    80004df2:	e406                	sd	ra,8(sp)
    80004df4:	e022                	sd	s0,0(sp)
    80004df6:	0800                	addi	s0,sp,16
	initlock(&ftable.lock, "ftable");
    80004df8:	00004597          	auipc	a1,0x4
    80004dfc:	a2858593          	addi	a1,a1,-1496 # 80008820 <syscalls+0x268>
    80004e00:	0067e517          	auipc	a0,0x67e
    80004e04:	3d050513          	addi	a0,a0,976 # 806831d0 <ftable>
    80004e08:	ffffc097          	auipc	ra,0xffffc
    80004e0c:	f10080e7          	jalr	-240(ra) # 80000d18 <initlock>
}
    80004e10:	60a2                	ld	ra,8(sp)
    80004e12:	6402                	ld	s0,0(sp)
    80004e14:	0141                	addi	sp,sp,16
    80004e16:	8082                	ret

0000000080004e18 <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    80004e18:	1101                	addi	sp,sp,-32
    80004e1a:	ec06                	sd	ra,24(sp)
    80004e1c:	e822                	sd	s0,16(sp)
    80004e1e:	e426                	sd	s1,8(sp)
    80004e20:	1000                	addi	s0,sp,32
	struct file *f;

	acquire(&ftable.lock);
    80004e22:	0067e517          	auipc	a0,0x67e
    80004e26:	3ae50513          	addi	a0,a0,942 # 806831d0 <ftable>
    80004e2a:	ffffc097          	auipc	ra,0xffffc
    80004e2e:	f7e080e7          	jalr	-130(ra) # 80000da8 <acquire>
	for (f = ftable.file; f < ftable.file + NFILE; f++)
    80004e32:	0067e497          	auipc	s1,0x67e
    80004e36:	3b648493          	addi	s1,s1,950 # 806831e8 <ftable+0x18>
    80004e3a:	0067f717          	auipc	a4,0x67f
    80004e3e:	34e70713          	addi	a4,a4,846 # 80684188 <disk>
	{
		if (f->ref == 0)
    80004e42:	40dc                	lw	a5,4(s1)
    80004e44:	cf99                	beqz	a5,80004e62 <filealloc+0x4a>
	for (f = ftable.file; f < ftable.file + NFILE; f++)
    80004e46:	02848493          	addi	s1,s1,40
    80004e4a:	fee49ce3          	bne	s1,a4,80004e42 <filealloc+0x2a>
			f->ref = 1;
			release(&ftable.lock);
			return f;
		}
	}
	release(&ftable.lock);
    80004e4e:	0067e517          	auipc	a0,0x67e
    80004e52:	38250513          	addi	a0,a0,898 # 806831d0 <ftable>
    80004e56:	ffffc097          	auipc	ra,0xffffc
    80004e5a:	006080e7          	jalr	6(ra) # 80000e5c <release>
	return 0;
    80004e5e:	4481                	li	s1,0
    80004e60:	a819                	j	80004e76 <filealloc+0x5e>
			f->ref = 1;
    80004e62:	4785                	li	a5,1
    80004e64:	c0dc                	sw	a5,4(s1)
			release(&ftable.lock);
    80004e66:	0067e517          	auipc	a0,0x67e
    80004e6a:	36a50513          	addi	a0,a0,874 # 806831d0 <ftable>
    80004e6e:	ffffc097          	auipc	ra,0xffffc
    80004e72:	fee080e7          	jalr	-18(ra) # 80000e5c <release>
}
    80004e76:	8526                	mv	a0,s1
    80004e78:	60e2                	ld	ra,24(sp)
    80004e7a:	6442                	ld	s0,16(sp)
    80004e7c:	64a2                	ld	s1,8(sp)
    80004e7e:	6105                	addi	sp,sp,32
    80004e80:	8082                	ret

0000000080004e82 <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    80004e82:	1101                	addi	sp,sp,-32
    80004e84:	ec06                	sd	ra,24(sp)
    80004e86:	e822                	sd	s0,16(sp)
    80004e88:	e426                	sd	s1,8(sp)
    80004e8a:	1000                	addi	s0,sp,32
    80004e8c:	84aa                	mv	s1,a0
	acquire(&ftable.lock);
    80004e8e:	0067e517          	auipc	a0,0x67e
    80004e92:	34250513          	addi	a0,a0,834 # 806831d0 <ftable>
    80004e96:	ffffc097          	auipc	ra,0xffffc
    80004e9a:	f12080e7          	jalr	-238(ra) # 80000da8 <acquire>
	if (f->ref < 1)
    80004e9e:	40dc                	lw	a5,4(s1)
    80004ea0:	02f05263          	blez	a5,80004ec4 <filedup+0x42>
		panic("filedup");
	f->ref++;
    80004ea4:	2785                	addiw	a5,a5,1
    80004ea6:	c0dc                	sw	a5,4(s1)
	release(&ftable.lock);
    80004ea8:	0067e517          	auipc	a0,0x67e
    80004eac:	32850513          	addi	a0,a0,808 # 806831d0 <ftable>
    80004eb0:	ffffc097          	auipc	ra,0xffffc
    80004eb4:	fac080e7          	jalr	-84(ra) # 80000e5c <release>
	return f;
}
    80004eb8:	8526                	mv	a0,s1
    80004eba:	60e2                	ld	ra,24(sp)
    80004ebc:	6442                	ld	s0,16(sp)
    80004ebe:	64a2                	ld	s1,8(sp)
    80004ec0:	6105                	addi	sp,sp,32
    80004ec2:	8082                	ret
		panic("filedup");
    80004ec4:	00004517          	auipc	a0,0x4
    80004ec8:	96450513          	addi	a0,a0,-1692 # 80008828 <syscalls+0x270>
    80004ecc:	ffffb097          	auipc	ra,0xffffb
    80004ed0:	678080e7          	jalr	1656(ra) # 80000544 <panic>

0000000080004ed4 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void fileclose(struct file *f)
{
    80004ed4:	7139                	addi	sp,sp,-64
    80004ed6:	fc06                	sd	ra,56(sp)
    80004ed8:	f822                	sd	s0,48(sp)
    80004eda:	f426                	sd	s1,40(sp)
    80004edc:	f04a                	sd	s2,32(sp)
    80004ede:	ec4e                	sd	s3,24(sp)
    80004ee0:	e852                	sd	s4,16(sp)
    80004ee2:	e456                	sd	s5,8(sp)
    80004ee4:	0080                	addi	s0,sp,64
    80004ee6:	84aa                	mv	s1,a0
	struct file ff;

	acquire(&ftable.lock);
    80004ee8:	0067e517          	auipc	a0,0x67e
    80004eec:	2e850513          	addi	a0,a0,744 # 806831d0 <ftable>
    80004ef0:	ffffc097          	auipc	ra,0xffffc
    80004ef4:	eb8080e7          	jalr	-328(ra) # 80000da8 <acquire>
	if (f->ref < 1)
    80004ef8:	40dc                	lw	a5,4(s1)
    80004efa:	06f05163          	blez	a5,80004f5c <fileclose+0x88>
		panic("fileclose");
	if (--f->ref > 0)
    80004efe:	37fd                	addiw	a5,a5,-1
    80004f00:	0007871b          	sext.w	a4,a5
    80004f04:	c0dc                	sw	a5,4(s1)
    80004f06:	06e04363          	bgtz	a4,80004f6c <fileclose+0x98>
	{
		release(&ftable.lock);
		return;
	}
	ff = *f;
    80004f0a:	0004a903          	lw	s2,0(s1)
    80004f0e:	0094ca83          	lbu	s5,9(s1)
    80004f12:	0104ba03          	ld	s4,16(s1)
    80004f16:	0184b983          	ld	s3,24(s1)
	f->ref = 0;
    80004f1a:	0004a223          	sw	zero,4(s1)
	f->type = FD_NONE;
    80004f1e:	0004a023          	sw	zero,0(s1)
	release(&ftable.lock);
    80004f22:	0067e517          	auipc	a0,0x67e
    80004f26:	2ae50513          	addi	a0,a0,686 # 806831d0 <ftable>
    80004f2a:	ffffc097          	auipc	ra,0xffffc
    80004f2e:	f32080e7          	jalr	-206(ra) # 80000e5c <release>

	if (ff.type == FD_PIPE)
    80004f32:	4785                	li	a5,1
    80004f34:	04f90d63          	beq	s2,a5,80004f8e <fileclose+0xba>
	{
		pipeclose(ff.pipe, ff.writable);
	}
	else if (ff.type == FD_INODE || ff.type == FD_DEVICE)
    80004f38:	3979                	addiw	s2,s2,-2
    80004f3a:	4785                	li	a5,1
    80004f3c:	0527e063          	bltu	a5,s2,80004f7c <fileclose+0xa8>
	{
		begin_op();
    80004f40:	00000097          	auipc	ra,0x0
    80004f44:	ac8080e7          	jalr	-1336(ra) # 80004a08 <begin_op>
		iput(ff.ip);
    80004f48:	854e                	mv	a0,s3
    80004f4a:	fffff097          	auipc	ra,0xfffff
    80004f4e:	2b6080e7          	jalr	694(ra) # 80004200 <iput>
		end_op();
    80004f52:	00000097          	auipc	ra,0x0
    80004f56:	b36080e7          	jalr	-1226(ra) # 80004a88 <end_op>
    80004f5a:	a00d                	j	80004f7c <fileclose+0xa8>
		panic("fileclose");
    80004f5c:	00004517          	auipc	a0,0x4
    80004f60:	8d450513          	addi	a0,a0,-1836 # 80008830 <syscalls+0x278>
    80004f64:	ffffb097          	auipc	ra,0xffffb
    80004f68:	5e0080e7          	jalr	1504(ra) # 80000544 <panic>
		release(&ftable.lock);
    80004f6c:	0067e517          	auipc	a0,0x67e
    80004f70:	26450513          	addi	a0,a0,612 # 806831d0 <ftable>
    80004f74:	ffffc097          	auipc	ra,0xffffc
    80004f78:	ee8080e7          	jalr	-280(ra) # 80000e5c <release>
	}
}
    80004f7c:	70e2                	ld	ra,56(sp)
    80004f7e:	7442                	ld	s0,48(sp)
    80004f80:	74a2                	ld	s1,40(sp)
    80004f82:	7902                	ld	s2,32(sp)
    80004f84:	69e2                	ld	s3,24(sp)
    80004f86:	6a42                	ld	s4,16(sp)
    80004f88:	6aa2                	ld	s5,8(sp)
    80004f8a:	6121                	addi	sp,sp,64
    80004f8c:	8082                	ret
		pipeclose(ff.pipe, ff.writable);
    80004f8e:	85d6                	mv	a1,s5
    80004f90:	8552                	mv	a0,s4
    80004f92:	00000097          	auipc	ra,0x0
    80004f96:	34c080e7          	jalr	844(ra) # 800052de <pipeclose>
    80004f9a:	b7cd                	j	80004f7c <fileclose+0xa8>

0000000080004f9c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int filestat(struct file *f, uint64 addr)
{
    80004f9c:	715d                	addi	sp,sp,-80
    80004f9e:	e486                	sd	ra,72(sp)
    80004fa0:	e0a2                	sd	s0,64(sp)
    80004fa2:	fc26                	sd	s1,56(sp)
    80004fa4:	f84a                	sd	s2,48(sp)
    80004fa6:	f44e                	sd	s3,40(sp)
    80004fa8:	0880                	addi	s0,sp,80
    80004faa:	84aa                	mv	s1,a0
    80004fac:	89ae                	mv	s3,a1
	struct proc *p = myproc();
    80004fae:	ffffd097          	auipc	ra,0xffffd
    80004fb2:	d0a080e7          	jalr	-758(ra) # 80001cb8 <myproc>
	struct stat st;

	if (f->type == FD_INODE || f->type == FD_DEVICE)
    80004fb6:	409c                	lw	a5,0(s1)
    80004fb8:	37f9                	addiw	a5,a5,-2
    80004fba:	4705                	li	a4,1
    80004fbc:	04f76763          	bltu	a4,a5,8000500a <filestat+0x6e>
    80004fc0:	892a                	mv	s2,a0
	{
		ilock(f->ip);
    80004fc2:	6c88                	ld	a0,24(s1)
    80004fc4:	fffff097          	auipc	ra,0xfffff
    80004fc8:	082080e7          	jalr	130(ra) # 80004046 <ilock>
		stati(f->ip, &st);
    80004fcc:	fb840593          	addi	a1,s0,-72
    80004fd0:	6c88                	ld	a0,24(s1)
    80004fd2:	fffff097          	auipc	ra,0xfffff
    80004fd6:	2fe080e7          	jalr	766(ra) # 800042d0 <stati>
		iunlock(f->ip);
    80004fda:	6c88                	ld	a0,24(s1)
    80004fdc:	fffff097          	auipc	ra,0xfffff
    80004fe0:	12c080e7          	jalr	300(ra) # 80004108 <iunlock>
		if (copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004fe4:	46e1                	li	a3,24
    80004fe6:	fb840613          	addi	a2,s0,-72
    80004fea:	85ce                	mv	a1,s3
    80004fec:	05893503          	ld	a0,88(s2)
    80004ff0:	ffffd097          	auipc	ra,0xffffd
    80004ff4:	848080e7          	jalr	-1976(ra) # 80001838 <copyout>
    80004ff8:	41f5551b          	sraiw	a0,a0,0x1f
			return -1;
		return 0;
	}
	return -1;
}
    80004ffc:	60a6                	ld	ra,72(sp)
    80004ffe:	6406                	ld	s0,64(sp)
    80005000:	74e2                	ld	s1,56(sp)
    80005002:	7942                	ld	s2,48(sp)
    80005004:	79a2                	ld	s3,40(sp)
    80005006:	6161                	addi	sp,sp,80
    80005008:	8082                	ret
	return -1;
    8000500a:	557d                	li	a0,-1
    8000500c:	bfc5                	j	80004ffc <filestat+0x60>

000000008000500e <fileread>:

// Read from file f.
// addr is a user virtual address.
int fileread(struct file *f, uint64 addr, int n)
{
    8000500e:	7179                	addi	sp,sp,-48
    80005010:	f406                	sd	ra,40(sp)
    80005012:	f022                	sd	s0,32(sp)
    80005014:	ec26                	sd	s1,24(sp)
    80005016:	e84a                	sd	s2,16(sp)
    80005018:	e44e                	sd	s3,8(sp)
    8000501a:	1800                	addi	s0,sp,48
	int r = 0;

	if (f->readable == 0)
    8000501c:	00854783          	lbu	a5,8(a0)
    80005020:	c3d5                	beqz	a5,800050c4 <fileread+0xb6>
    80005022:	84aa                	mv	s1,a0
    80005024:	89ae                	mv	s3,a1
    80005026:	8932                	mv	s2,a2
		return -1;

	if (f->type == FD_PIPE)
    80005028:	411c                	lw	a5,0(a0)
    8000502a:	4705                	li	a4,1
    8000502c:	04e78963          	beq	a5,a4,8000507e <fileread+0x70>
	{
		r = piperead(f->pipe, addr, n);
		// printf("here\n");
	}
	else if (f->type == FD_DEVICE)
    80005030:	470d                	li	a4,3
    80005032:	04e78d63          	beq	a5,a4,8000508c <fileread+0x7e>
	{
		if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
			return -1;
		r = devsw[f->major].read(1, addr, n);
	}
	else if (f->type == FD_INODE)
    80005036:	4709                	li	a4,2
    80005038:	06e79e63          	bne	a5,a4,800050b4 <fileread+0xa6>
	{
		ilock(f->ip);
    8000503c:	6d08                	ld	a0,24(a0)
    8000503e:	fffff097          	auipc	ra,0xfffff
    80005042:	008080e7          	jalr	8(ra) # 80004046 <ilock>
		if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80005046:	874a                	mv	a4,s2
    80005048:	5094                	lw	a3,32(s1)
    8000504a:	864e                	mv	a2,s3
    8000504c:	4585                	li	a1,1
    8000504e:	6c88                	ld	a0,24(s1)
    80005050:	fffff097          	auipc	ra,0xfffff
    80005054:	2aa080e7          	jalr	682(ra) # 800042fa <readi>
    80005058:	892a                	mv	s2,a0
    8000505a:	00a05563          	blez	a0,80005064 <fileread+0x56>
			f->off += r;
    8000505e:	509c                	lw	a5,32(s1)
    80005060:	9fa9                	addw	a5,a5,a0
    80005062:	d09c                	sw	a5,32(s1)
		iunlock(f->ip);
    80005064:	6c88                	ld	a0,24(s1)
    80005066:	fffff097          	auipc	ra,0xfffff
    8000506a:	0a2080e7          	jalr	162(ra) # 80004108 <iunlock>
	{
		panic("fileread");
	}

	return r;
}
    8000506e:	854a                	mv	a0,s2
    80005070:	70a2                	ld	ra,40(sp)
    80005072:	7402                	ld	s0,32(sp)
    80005074:	64e2                	ld	s1,24(sp)
    80005076:	6942                	ld	s2,16(sp)
    80005078:	69a2                	ld	s3,8(sp)
    8000507a:	6145                	addi	sp,sp,48
    8000507c:	8082                	ret
		r = piperead(f->pipe, addr, n);
    8000507e:	6908                	ld	a0,16(a0)
    80005080:	00000097          	auipc	ra,0x0
    80005084:	3ce080e7          	jalr	974(ra) # 8000544e <piperead>
    80005088:	892a                	mv	s2,a0
    8000508a:	b7d5                	j	8000506e <fileread+0x60>
		if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000508c:	02451783          	lh	a5,36(a0)
    80005090:	03079693          	slli	a3,a5,0x30
    80005094:	92c1                	srli	a3,a3,0x30
    80005096:	4725                	li	a4,9
    80005098:	02d76863          	bltu	a4,a3,800050c8 <fileread+0xba>
    8000509c:	0792                	slli	a5,a5,0x4
    8000509e:	0067e717          	auipc	a4,0x67e
    800050a2:	09270713          	addi	a4,a4,146 # 80683130 <devsw>
    800050a6:	97ba                	add	a5,a5,a4
    800050a8:	639c                	ld	a5,0(a5)
    800050aa:	c38d                	beqz	a5,800050cc <fileread+0xbe>
		r = devsw[f->major].read(1, addr, n);
    800050ac:	4505                	li	a0,1
    800050ae:	9782                	jalr	a5
    800050b0:	892a                	mv	s2,a0
    800050b2:	bf75                	j	8000506e <fileread+0x60>
		panic("fileread");
    800050b4:	00003517          	auipc	a0,0x3
    800050b8:	78c50513          	addi	a0,a0,1932 # 80008840 <syscalls+0x288>
    800050bc:	ffffb097          	auipc	ra,0xffffb
    800050c0:	488080e7          	jalr	1160(ra) # 80000544 <panic>
		return -1;
    800050c4:	597d                	li	s2,-1
    800050c6:	b765                	j	8000506e <fileread+0x60>
			return -1;
    800050c8:	597d                	li	s2,-1
    800050ca:	b755                	j	8000506e <fileread+0x60>
    800050cc:	597d                	li	s2,-1
    800050ce:	b745                	j	8000506e <fileread+0x60>

00000000800050d0 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int filewrite(struct file *f, uint64 addr, int n)
{
    800050d0:	715d                	addi	sp,sp,-80
    800050d2:	e486                	sd	ra,72(sp)
    800050d4:	e0a2                	sd	s0,64(sp)
    800050d6:	fc26                	sd	s1,56(sp)
    800050d8:	f84a                	sd	s2,48(sp)
    800050da:	f44e                	sd	s3,40(sp)
    800050dc:	f052                	sd	s4,32(sp)
    800050de:	ec56                	sd	s5,24(sp)
    800050e0:	e85a                	sd	s6,16(sp)
    800050e2:	e45e                	sd	s7,8(sp)
    800050e4:	e062                	sd	s8,0(sp)
    800050e6:	0880                	addi	s0,sp,80
	int r, ret = 0;

	if (f->writable == 0)
    800050e8:	00954783          	lbu	a5,9(a0)
    800050ec:	10078663          	beqz	a5,800051f8 <filewrite+0x128>
    800050f0:	892a                	mv	s2,a0
    800050f2:	8aae                	mv	s5,a1
    800050f4:	8a32                	mv	s4,a2
		return -1;

	if (f->type == FD_PIPE)
    800050f6:	411c                	lw	a5,0(a0)
    800050f8:	4705                	li	a4,1
    800050fa:	02e78263          	beq	a5,a4,8000511e <filewrite+0x4e>
	{
		ret = pipewrite(f->pipe, addr, n);
	}
	else if (f->type == FD_DEVICE)
    800050fe:	470d                	li	a4,3
    80005100:	02e78663          	beq	a5,a4,8000512c <filewrite+0x5c>
	{
		if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
			return -1;
		ret = devsw[f->major].write(1, addr, n);
	}
	else if (f->type == FD_INODE)
    80005104:	4709                	li	a4,2
    80005106:	0ee79163          	bne	a5,a4,800051e8 <filewrite+0x118>
		// and 2 blocks of slop for non-aligned writes.
		// this really belongs lower down, since writei()
		// might be writing a device like the console.
		int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
		int i = 0;
		while (i < n)
    8000510a:	0ac05d63          	blez	a2,800051c4 <filewrite+0xf4>
		int i = 0;
    8000510e:	4981                	li	s3,0
    80005110:	6b05                	lui	s6,0x1
    80005112:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80005116:	6b85                	lui	s7,0x1
    80005118:	c00b8b9b          	addiw	s7,s7,-1024
    8000511c:	a861                	j	800051b4 <filewrite+0xe4>
		ret = pipewrite(f->pipe, addr, n);
    8000511e:	6908                	ld	a0,16(a0)
    80005120:	00000097          	auipc	ra,0x0
    80005124:	22e080e7          	jalr	558(ra) # 8000534e <pipewrite>
    80005128:	8a2a                	mv	s4,a0
    8000512a:	a045                	j	800051ca <filewrite+0xfa>
		if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000512c:	02451783          	lh	a5,36(a0)
    80005130:	03079693          	slli	a3,a5,0x30
    80005134:	92c1                	srli	a3,a3,0x30
    80005136:	4725                	li	a4,9
    80005138:	0cd76263          	bltu	a4,a3,800051fc <filewrite+0x12c>
    8000513c:	0792                	slli	a5,a5,0x4
    8000513e:	0067e717          	auipc	a4,0x67e
    80005142:	ff270713          	addi	a4,a4,-14 # 80683130 <devsw>
    80005146:	97ba                	add	a5,a5,a4
    80005148:	679c                	ld	a5,8(a5)
    8000514a:	cbdd                	beqz	a5,80005200 <filewrite+0x130>
		ret = devsw[f->major].write(1, addr, n);
    8000514c:	4505                	li	a0,1
    8000514e:	9782                	jalr	a5
    80005150:	8a2a                	mv	s4,a0
    80005152:	a8a5                	j	800051ca <filewrite+0xfa>
    80005154:	00048c1b          	sext.w	s8,s1
		{
			int n1 = n - i;
			if (n1 > max)
				n1 = max;

			begin_op();
    80005158:	00000097          	auipc	ra,0x0
    8000515c:	8b0080e7          	jalr	-1872(ra) # 80004a08 <begin_op>
			ilock(f->ip);
    80005160:	01893503          	ld	a0,24(s2)
    80005164:	fffff097          	auipc	ra,0xfffff
    80005168:	ee2080e7          	jalr	-286(ra) # 80004046 <ilock>
			if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000516c:	8762                	mv	a4,s8
    8000516e:	02092683          	lw	a3,32(s2)
    80005172:	01598633          	add	a2,s3,s5
    80005176:	4585                	li	a1,1
    80005178:	01893503          	ld	a0,24(s2)
    8000517c:	fffff097          	auipc	ra,0xfffff
    80005180:	276080e7          	jalr	630(ra) # 800043f2 <writei>
    80005184:	84aa                	mv	s1,a0
    80005186:	00a05763          	blez	a0,80005194 <filewrite+0xc4>
				f->off += r;
    8000518a:	02092783          	lw	a5,32(s2)
    8000518e:	9fa9                	addw	a5,a5,a0
    80005190:	02f92023          	sw	a5,32(s2)
			iunlock(f->ip);
    80005194:	01893503          	ld	a0,24(s2)
    80005198:	fffff097          	auipc	ra,0xfffff
    8000519c:	f70080e7          	jalr	-144(ra) # 80004108 <iunlock>
			end_op();
    800051a0:	00000097          	auipc	ra,0x0
    800051a4:	8e8080e7          	jalr	-1816(ra) # 80004a88 <end_op>

			if (r != n1)
    800051a8:	009c1f63          	bne	s8,s1,800051c6 <filewrite+0xf6>
			{
				// error from writei
				break;
			}
			i += r;
    800051ac:	013489bb          	addw	s3,s1,s3
		while (i < n)
    800051b0:	0149db63          	bge	s3,s4,800051c6 <filewrite+0xf6>
			int n1 = n - i;
    800051b4:	413a07bb          	subw	a5,s4,s3
			if (n1 > max)
    800051b8:	84be                	mv	s1,a5
    800051ba:	2781                	sext.w	a5,a5
    800051bc:	f8fb5ce3          	bge	s6,a5,80005154 <filewrite+0x84>
    800051c0:	84de                	mv	s1,s7
    800051c2:	bf49                	j	80005154 <filewrite+0x84>
		int i = 0;
    800051c4:	4981                	li	s3,0
		}
		ret = (i == n ? n : -1);
    800051c6:	013a1f63          	bne	s4,s3,800051e4 <filewrite+0x114>
	{
		panic("filewrite");
	}

	return ret;
}
    800051ca:	8552                	mv	a0,s4
    800051cc:	60a6                	ld	ra,72(sp)
    800051ce:	6406                	ld	s0,64(sp)
    800051d0:	74e2                	ld	s1,56(sp)
    800051d2:	7942                	ld	s2,48(sp)
    800051d4:	79a2                	ld	s3,40(sp)
    800051d6:	7a02                	ld	s4,32(sp)
    800051d8:	6ae2                	ld	s5,24(sp)
    800051da:	6b42                	ld	s6,16(sp)
    800051dc:	6ba2                	ld	s7,8(sp)
    800051de:	6c02                	ld	s8,0(sp)
    800051e0:	6161                	addi	sp,sp,80
    800051e2:	8082                	ret
		ret = (i == n ? n : -1);
    800051e4:	5a7d                	li	s4,-1
    800051e6:	b7d5                	j	800051ca <filewrite+0xfa>
		panic("filewrite");
    800051e8:	00003517          	auipc	a0,0x3
    800051ec:	66850513          	addi	a0,a0,1640 # 80008850 <syscalls+0x298>
    800051f0:	ffffb097          	auipc	ra,0xffffb
    800051f4:	354080e7          	jalr	852(ra) # 80000544 <panic>
		return -1;
    800051f8:	5a7d                	li	s4,-1
    800051fa:	bfc1                	j	800051ca <filewrite+0xfa>
			return -1;
    800051fc:	5a7d                	li	s4,-1
    800051fe:	b7f1                	j	800051ca <filewrite+0xfa>
    80005200:	5a7d                	li	s4,-1
    80005202:	b7e1                	j	800051ca <filewrite+0xfa>

0000000080005204 <pipealloc>:
    80005204:	7179                	addi	sp,sp,-48
    80005206:	f406                	sd	ra,40(sp)
    80005208:	f022                	sd	s0,32(sp)
    8000520a:	ec26                	sd	s1,24(sp)
    8000520c:	e84a                	sd	s2,16(sp)
    8000520e:	e44e                	sd	s3,8(sp)
    80005210:	e052                	sd	s4,0(sp)
    80005212:	1800                	addi	s0,sp,48
    80005214:	84aa                	mv	s1,a0
    80005216:	8a2e                	mv	s4,a1
    80005218:	0005b023          	sd	zero,0(a1)
    8000521c:	00053023          	sd	zero,0(a0)
    80005220:	00000097          	auipc	ra,0x0
    80005224:	bf8080e7          	jalr	-1032(ra) # 80004e18 <filealloc>
    80005228:	e088                	sd	a0,0(s1)
    8000522a:	c551                	beqz	a0,800052b6 <pipealloc+0xb2>
    8000522c:	00000097          	auipc	ra,0x0
    80005230:	bec080e7          	jalr	-1044(ra) # 80004e18 <filealloc>
    80005234:	00aa3023          	sd	a0,0(s4)
    80005238:	c92d                	beqz	a0,800052aa <pipealloc+0xa6>
    8000523a:	ffffc097          	auipc	ra,0xffffc
    8000523e:	a3a080e7          	jalr	-1478(ra) # 80000c74 <kalloc>
    80005242:	892a                	mv	s2,a0
    80005244:	c125                	beqz	a0,800052a4 <pipealloc+0xa0>
    80005246:	4985                	li	s3,1
    80005248:	23352023          	sw	s3,544(a0)
    8000524c:	23352223          	sw	s3,548(a0)
    80005250:	20052e23          	sw	zero,540(a0)
    80005254:	20052c23          	sw	zero,536(a0)
    80005258:	00003597          	auipc	a1,0x3
    8000525c:	27058593          	addi	a1,a1,624 # 800084c8 <states.2512+0x1b8>
    80005260:	ffffc097          	auipc	ra,0xffffc
    80005264:	ab8080e7          	jalr	-1352(ra) # 80000d18 <initlock>
    80005268:	609c                	ld	a5,0(s1)
    8000526a:	0137a023          	sw	s3,0(a5)
    8000526e:	609c                	ld	a5,0(s1)
    80005270:	01378423          	sb	s3,8(a5)
    80005274:	609c                	ld	a5,0(s1)
    80005276:	000784a3          	sb	zero,9(a5)
    8000527a:	609c                	ld	a5,0(s1)
    8000527c:	0127b823          	sd	s2,16(a5)
    80005280:	000a3783          	ld	a5,0(s4)
    80005284:	0137a023          	sw	s3,0(a5)
    80005288:	000a3783          	ld	a5,0(s4)
    8000528c:	00078423          	sb	zero,8(a5)
    80005290:	000a3783          	ld	a5,0(s4)
    80005294:	013784a3          	sb	s3,9(a5)
    80005298:	000a3783          	ld	a5,0(s4)
    8000529c:	0127b823          	sd	s2,16(a5)
    800052a0:	4501                	li	a0,0
    800052a2:	a025                	j	800052ca <pipealloc+0xc6>
    800052a4:	6088                	ld	a0,0(s1)
    800052a6:	e501                	bnez	a0,800052ae <pipealloc+0xaa>
    800052a8:	a039                	j	800052b6 <pipealloc+0xb2>
    800052aa:	6088                	ld	a0,0(s1)
    800052ac:	c51d                	beqz	a0,800052da <pipealloc+0xd6>
    800052ae:	00000097          	auipc	ra,0x0
    800052b2:	c26080e7          	jalr	-986(ra) # 80004ed4 <fileclose>
    800052b6:	000a3783          	ld	a5,0(s4)
    800052ba:	557d                	li	a0,-1
    800052bc:	c799                	beqz	a5,800052ca <pipealloc+0xc6>
    800052be:	853e                	mv	a0,a5
    800052c0:	00000097          	auipc	ra,0x0
    800052c4:	c14080e7          	jalr	-1004(ra) # 80004ed4 <fileclose>
    800052c8:	557d                	li	a0,-1
    800052ca:	70a2                	ld	ra,40(sp)
    800052cc:	7402                	ld	s0,32(sp)
    800052ce:	64e2                	ld	s1,24(sp)
    800052d0:	6942                	ld	s2,16(sp)
    800052d2:	69a2                	ld	s3,8(sp)
    800052d4:	6a02                	ld	s4,0(sp)
    800052d6:	6145                	addi	sp,sp,48
    800052d8:	8082                	ret
    800052da:	557d                	li	a0,-1
    800052dc:	b7fd                	j	800052ca <pipealloc+0xc6>

00000000800052de <pipeclose>:
    800052de:	1101                	addi	sp,sp,-32
    800052e0:	ec06                	sd	ra,24(sp)
    800052e2:	e822                	sd	s0,16(sp)
    800052e4:	e426                	sd	s1,8(sp)
    800052e6:	e04a                	sd	s2,0(sp)
    800052e8:	1000                	addi	s0,sp,32
    800052ea:	84aa                	mv	s1,a0
    800052ec:	892e                	mv	s2,a1
    800052ee:	ffffc097          	auipc	ra,0xffffc
    800052f2:	aba080e7          	jalr	-1350(ra) # 80000da8 <acquire>
    800052f6:	02090d63          	beqz	s2,80005330 <pipeclose+0x52>
    800052fa:	2204a223          	sw	zero,548(s1)
    800052fe:	21848513          	addi	a0,s1,536
    80005302:	ffffd097          	auipc	ra,0xffffd
    80005306:	424080e7          	jalr	1060(ra) # 80002726 <wakeup>
    8000530a:	2204b783          	ld	a5,544(s1)
    8000530e:	eb95                	bnez	a5,80005342 <pipeclose+0x64>
    80005310:	8526                	mv	a0,s1
    80005312:	ffffc097          	auipc	ra,0xffffc
    80005316:	b4a080e7          	jalr	-1206(ra) # 80000e5c <release>
    8000531a:	8526                	mv	a0,s1
    8000531c:	ffffb097          	auipc	ra,0xffffb
    80005320:	7b2080e7          	jalr	1970(ra) # 80000ace <kfree>
    80005324:	60e2                	ld	ra,24(sp)
    80005326:	6442                	ld	s0,16(sp)
    80005328:	64a2                	ld	s1,8(sp)
    8000532a:	6902                	ld	s2,0(sp)
    8000532c:	6105                	addi	sp,sp,32
    8000532e:	8082                	ret
    80005330:	2204a023          	sw	zero,544(s1)
    80005334:	21c48513          	addi	a0,s1,540
    80005338:	ffffd097          	auipc	ra,0xffffd
    8000533c:	3ee080e7          	jalr	1006(ra) # 80002726 <wakeup>
    80005340:	b7e9                	j	8000530a <pipeclose+0x2c>
    80005342:	8526                	mv	a0,s1
    80005344:	ffffc097          	auipc	ra,0xffffc
    80005348:	b18080e7          	jalr	-1256(ra) # 80000e5c <release>
    8000534c:	bfe1                	j	80005324 <pipeclose+0x46>

000000008000534e <pipewrite>:
    8000534e:	7159                	addi	sp,sp,-112
    80005350:	f486                	sd	ra,104(sp)
    80005352:	f0a2                	sd	s0,96(sp)
    80005354:	eca6                	sd	s1,88(sp)
    80005356:	e8ca                	sd	s2,80(sp)
    80005358:	e4ce                	sd	s3,72(sp)
    8000535a:	e0d2                	sd	s4,64(sp)
    8000535c:	fc56                	sd	s5,56(sp)
    8000535e:	f85a                	sd	s6,48(sp)
    80005360:	f45e                	sd	s7,40(sp)
    80005362:	f062                	sd	s8,32(sp)
    80005364:	ec66                	sd	s9,24(sp)
    80005366:	1880                	addi	s0,sp,112
    80005368:	84aa                	mv	s1,a0
    8000536a:	8aae                	mv	s5,a1
    8000536c:	8a32                	mv	s4,a2
    8000536e:	ffffd097          	auipc	ra,0xffffd
    80005372:	94a080e7          	jalr	-1718(ra) # 80001cb8 <myproc>
    80005376:	89aa                	mv	s3,a0
    80005378:	8526                	mv	a0,s1
    8000537a:	ffffc097          	auipc	ra,0xffffc
    8000537e:	a2e080e7          	jalr	-1490(ra) # 80000da8 <acquire>
    80005382:	0d405463          	blez	s4,8000544a <pipewrite+0xfc>
    80005386:	8ba6                	mv	s7,s1
    80005388:	4901                	li	s2,0
    8000538a:	5b7d                	li	s6,-1
    8000538c:	21848c93          	addi	s9,s1,536
    80005390:	21c48c13          	addi	s8,s1,540
    80005394:	a08d                	j	800053f6 <pipewrite+0xa8>
    80005396:	8526                	mv	a0,s1
    80005398:	ffffc097          	auipc	ra,0xffffc
    8000539c:	ac4080e7          	jalr	-1340(ra) # 80000e5c <release>
    800053a0:	597d                	li	s2,-1
    800053a2:	854a                	mv	a0,s2
    800053a4:	70a6                	ld	ra,104(sp)
    800053a6:	7406                	ld	s0,96(sp)
    800053a8:	64e6                	ld	s1,88(sp)
    800053aa:	6946                	ld	s2,80(sp)
    800053ac:	69a6                	ld	s3,72(sp)
    800053ae:	6a06                	ld	s4,64(sp)
    800053b0:	7ae2                	ld	s5,56(sp)
    800053b2:	7b42                	ld	s6,48(sp)
    800053b4:	7ba2                	ld	s7,40(sp)
    800053b6:	7c02                	ld	s8,32(sp)
    800053b8:	6ce2                	ld	s9,24(sp)
    800053ba:	6165                	addi	sp,sp,112
    800053bc:	8082                	ret
    800053be:	8566                	mv	a0,s9
    800053c0:	ffffd097          	auipc	ra,0xffffd
    800053c4:	366080e7          	jalr	870(ra) # 80002726 <wakeup>
    800053c8:	85de                	mv	a1,s7
    800053ca:	8562                	mv	a0,s8
    800053cc:	ffffd097          	auipc	ra,0xffffd
    800053d0:	05c080e7          	jalr	92(ra) # 80002428 <sleep>
    800053d4:	a839                	j	800053f2 <pipewrite+0xa4>
    800053d6:	21c4a783          	lw	a5,540(s1)
    800053da:	0017871b          	addiw	a4,a5,1
    800053de:	20e4ae23          	sw	a4,540(s1)
    800053e2:	1ff7f793          	andi	a5,a5,511
    800053e6:	97a6                	add	a5,a5,s1
    800053e8:	f9f44703          	lbu	a4,-97(s0)
    800053ec:	00e78c23          	sb	a4,24(a5)
    800053f0:	2905                	addiw	s2,s2,1
    800053f2:	05495063          	bge	s2,s4,80005432 <pipewrite+0xe4>
    800053f6:	2204a783          	lw	a5,544(s1)
    800053fa:	dfd1                	beqz	a5,80005396 <pipewrite+0x48>
    800053fc:	854e                	mv	a0,s3
    800053fe:	ffffd097          	auipc	ra,0xffffd
    80005402:	5ce080e7          	jalr	1486(ra) # 800029cc <killed>
    80005406:	f941                	bnez	a0,80005396 <pipewrite+0x48>
    80005408:	2184a783          	lw	a5,536(s1)
    8000540c:	21c4a703          	lw	a4,540(s1)
    80005410:	2007879b          	addiw	a5,a5,512
    80005414:	faf705e3          	beq	a4,a5,800053be <pipewrite+0x70>
    80005418:	4685                	li	a3,1
    8000541a:	01590633          	add	a2,s2,s5
    8000541e:	f9f40593          	addi	a1,s0,-97
    80005422:	0589b503          	ld	a0,88(s3)
    80005426:	ffffc097          	auipc	ra,0xffffc
    8000542a:	4d2080e7          	jalr	1234(ra) # 800018f8 <copyin>
    8000542e:	fb6514e3          	bne	a0,s6,800053d6 <pipewrite+0x88>
    80005432:	21848513          	addi	a0,s1,536
    80005436:	ffffd097          	auipc	ra,0xffffd
    8000543a:	2f0080e7          	jalr	752(ra) # 80002726 <wakeup>
    8000543e:	8526                	mv	a0,s1
    80005440:	ffffc097          	auipc	ra,0xffffc
    80005444:	a1c080e7          	jalr	-1508(ra) # 80000e5c <release>
    80005448:	bfa9                	j	800053a2 <pipewrite+0x54>
    8000544a:	4901                	li	s2,0
    8000544c:	b7dd                	j	80005432 <pipewrite+0xe4>

000000008000544e <piperead>:
    8000544e:	715d                	addi	sp,sp,-80
    80005450:	e486                	sd	ra,72(sp)
    80005452:	e0a2                	sd	s0,64(sp)
    80005454:	fc26                	sd	s1,56(sp)
    80005456:	f84a                	sd	s2,48(sp)
    80005458:	f44e                	sd	s3,40(sp)
    8000545a:	f052                	sd	s4,32(sp)
    8000545c:	ec56                	sd	s5,24(sp)
    8000545e:	e85a                	sd	s6,16(sp)
    80005460:	0880                	addi	s0,sp,80
    80005462:	84aa                	mv	s1,a0
    80005464:	892e                	mv	s2,a1
    80005466:	8ab2                	mv	s5,a2
    80005468:	ffffd097          	auipc	ra,0xffffd
    8000546c:	850080e7          	jalr	-1968(ra) # 80001cb8 <myproc>
    80005470:	8a2a                	mv	s4,a0
    80005472:	8b26                	mv	s6,s1
    80005474:	8526                	mv	a0,s1
    80005476:	ffffc097          	auipc	ra,0xffffc
    8000547a:	932080e7          	jalr	-1742(ra) # 80000da8 <acquire>
    8000547e:	2184a703          	lw	a4,536(s1)
    80005482:	21c4a783          	lw	a5,540(s1)
    80005486:	21848993          	addi	s3,s1,536
    8000548a:	02f71763          	bne	a4,a5,800054b8 <piperead+0x6a>
    8000548e:	2244a783          	lw	a5,548(s1)
    80005492:	c39d                	beqz	a5,800054b8 <piperead+0x6a>
    80005494:	8552                	mv	a0,s4
    80005496:	ffffd097          	auipc	ra,0xffffd
    8000549a:	536080e7          	jalr	1334(ra) # 800029cc <killed>
    8000549e:	e941                	bnez	a0,8000552e <piperead+0xe0>
    800054a0:	85da                	mv	a1,s6
    800054a2:	854e                	mv	a0,s3
    800054a4:	ffffd097          	auipc	ra,0xffffd
    800054a8:	f84080e7          	jalr	-124(ra) # 80002428 <sleep>
    800054ac:	2184a703          	lw	a4,536(s1)
    800054b0:	21c4a783          	lw	a5,540(s1)
    800054b4:	fcf70de3          	beq	a4,a5,8000548e <piperead+0x40>
    800054b8:	09505263          	blez	s5,8000553c <piperead+0xee>
    800054bc:	4981                	li	s3,0
    800054be:	5b7d                	li	s6,-1
    800054c0:	2184a783          	lw	a5,536(s1)
    800054c4:	21c4a703          	lw	a4,540(s1)
    800054c8:	02f70d63          	beq	a4,a5,80005502 <piperead+0xb4>
    800054cc:	0017871b          	addiw	a4,a5,1
    800054d0:	20e4ac23          	sw	a4,536(s1)
    800054d4:	1ff7f793          	andi	a5,a5,511
    800054d8:	97a6                	add	a5,a5,s1
    800054da:	0187c783          	lbu	a5,24(a5)
    800054de:	faf40fa3          	sb	a5,-65(s0)
    800054e2:	4685                	li	a3,1
    800054e4:	fbf40613          	addi	a2,s0,-65
    800054e8:	85ca                	mv	a1,s2
    800054ea:	058a3503          	ld	a0,88(s4)
    800054ee:	ffffc097          	auipc	ra,0xffffc
    800054f2:	34a080e7          	jalr	842(ra) # 80001838 <copyout>
    800054f6:	01650663          	beq	a0,s6,80005502 <piperead+0xb4>
    800054fa:	2985                	addiw	s3,s3,1
    800054fc:	0905                	addi	s2,s2,1
    800054fe:	fd3a91e3          	bne	s5,s3,800054c0 <piperead+0x72>
    80005502:	21c48513          	addi	a0,s1,540
    80005506:	ffffd097          	auipc	ra,0xffffd
    8000550a:	220080e7          	jalr	544(ra) # 80002726 <wakeup>
    8000550e:	8526                	mv	a0,s1
    80005510:	ffffc097          	auipc	ra,0xffffc
    80005514:	94c080e7          	jalr	-1716(ra) # 80000e5c <release>
    80005518:	854e                	mv	a0,s3
    8000551a:	60a6                	ld	ra,72(sp)
    8000551c:	6406                	ld	s0,64(sp)
    8000551e:	74e2                	ld	s1,56(sp)
    80005520:	7942                	ld	s2,48(sp)
    80005522:	79a2                	ld	s3,40(sp)
    80005524:	7a02                	ld	s4,32(sp)
    80005526:	6ae2                	ld	s5,24(sp)
    80005528:	6b42                	ld	s6,16(sp)
    8000552a:	6161                	addi	sp,sp,80
    8000552c:	8082                	ret
    8000552e:	8526                	mv	a0,s1
    80005530:	ffffc097          	auipc	ra,0xffffc
    80005534:	92c080e7          	jalr	-1748(ra) # 80000e5c <release>
    80005538:	59fd                	li	s3,-1
    8000553a:	bff9                	j	80005518 <piperead+0xca>
    8000553c:	4981                	li	s3,0
    8000553e:	b7d1                	j	80005502 <piperead+0xb4>

0000000080005540 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80005540:	1141                	addi	sp,sp,-16
    80005542:	e422                	sd	s0,8(sp)
    80005544:	0800                	addi	s0,sp,16
    80005546:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80005548:	8905                	andi	a0,a0,1
    8000554a:	c111                	beqz	a0,8000554e <flags2perm+0xe>
      perm = PTE_X;
    8000554c:	4521                	li	a0,8
    if(flags & 0x2)
    8000554e:	8b89                	andi	a5,a5,2
    80005550:	c399                	beqz	a5,80005556 <flags2perm+0x16>
      perm |= PTE_W;
    80005552:	00456513          	ori	a0,a0,4
    return perm;
}
    80005556:	6422                	ld	s0,8(sp)
    80005558:	0141                	addi	sp,sp,16
    8000555a:	8082                	ret

000000008000555c <exec>:

int
exec(char *path, char **argv)
{
    8000555c:	df010113          	addi	sp,sp,-528
    80005560:	20113423          	sd	ra,520(sp)
    80005564:	20813023          	sd	s0,512(sp)
    80005568:	ffa6                	sd	s1,504(sp)
    8000556a:	fbca                	sd	s2,496(sp)
    8000556c:	f7ce                	sd	s3,488(sp)
    8000556e:	f3d2                	sd	s4,480(sp)
    80005570:	efd6                	sd	s5,472(sp)
    80005572:	ebda                	sd	s6,464(sp)
    80005574:	e7de                	sd	s7,456(sp)
    80005576:	e3e2                	sd	s8,448(sp)
    80005578:	ff66                	sd	s9,440(sp)
    8000557a:	fb6a                	sd	s10,432(sp)
    8000557c:	f76e                	sd	s11,424(sp)
    8000557e:	0c00                	addi	s0,sp,528
    80005580:	84aa                	mv	s1,a0
    80005582:	dea43c23          	sd	a0,-520(s0)
    80005586:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000558a:	ffffc097          	auipc	ra,0xffffc
    8000558e:	72e080e7          	jalr	1838(ra) # 80001cb8 <myproc>
    80005592:	892a                	mv	s2,a0

  begin_op();
    80005594:	fffff097          	auipc	ra,0xfffff
    80005598:	474080e7          	jalr	1140(ra) # 80004a08 <begin_op>

  if((ip = namei(path)) == 0){
    8000559c:	8526                	mv	a0,s1
    8000559e:	fffff097          	auipc	ra,0xfffff
    800055a2:	24e080e7          	jalr	590(ra) # 800047ec <namei>
    800055a6:	c92d                	beqz	a0,80005618 <exec+0xbc>
    800055a8:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800055aa:	fffff097          	auipc	ra,0xfffff
    800055ae:	a9c080e7          	jalr	-1380(ra) # 80004046 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800055b2:	04000713          	li	a4,64
    800055b6:	4681                	li	a3,0
    800055b8:	e5040613          	addi	a2,s0,-432
    800055bc:	4581                	li	a1,0
    800055be:	8526                	mv	a0,s1
    800055c0:	fffff097          	auipc	ra,0xfffff
    800055c4:	d3a080e7          	jalr	-710(ra) # 800042fa <readi>
    800055c8:	04000793          	li	a5,64
    800055cc:	00f51a63          	bne	a0,a5,800055e0 <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800055d0:	e5042703          	lw	a4,-432(s0)
    800055d4:	464c47b7          	lui	a5,0x464c4
    800055d8:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800055dc:	04f70463          	beq	a4,a5,80005624 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800055e0:	8526                	mv	a0,s1
    800055e2:	fffff097          	auipc	ra,0xfffff
    800055e6:	cc6080e7          	jalr	-826(ra) # 800042a8 <iunlockput>
    end_op();
    800055ea:	fffff097          	auipc	ra,0xfffff
    800055ee:	49e080e7          	jalr	1182(ra) # 80004a88 <end_op>
  }
  return -1;
    800055f2:	557d                	li	a0,-1
}
    800055f4:	20813083          	ld	ra,520(sp)
    800055f8:	20013403          	ld	s0,512(sp)
    800055fc:	74fe                	ld	s1,504(sp)
    800055fe:	795e                	ld	s2,496(sp)
    80005600:	79be                	ld	s3,488(sp)
    80005602:	7a1e                	ld	s4,480(sp)
    80005604:	6afe                	ld	s5,472(sp)
    80005606:	6b5e                	ld	s6,464(sp)
    80005608:	6bbe                	ld	s7,456(sp)
    8000560a:	6c1e                	ld	s8,448(sp)
    8000560c:	7cfa                	ld	s9,440(sp)
    8000560e:	7d5a                	ld	s10,432(sp)
    80005610:	7dba                	ld	s11,424(sp)
    80005612:	21010113          	addi	sp,sp,528
    80005616:	8082                	ret
    end_op();
    80005618:	fffff097          	auipc	ra,0xfffff
    8000561c:	470080e7          	jalr	1136(ra) # 80004a88 <end_op>
    return -1;
    80005620:	557d                	li	a0,-1
    80005622:	bfc9                	j	800055f4 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80005624:	854a                	mv	a0,s2
    80005626:	ffffc097          	auipc	ra,0xffffc
    8000562a:	758080e7          	jalr	1880(ra) # 80001d7e <proc_pagetable>
    8000562e:	8baa                	mv	s7,a0
    80005630:	d945                	beqz	a0,800055e0 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005632:	e7042983          	lw	s3,-400(s0)
    80005636:	e8845783          	lhu	a5,-376(s0)
    8000563a:	c7ad                	beqz	a5,800056a4 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000563c:	4a01                	li	s4,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000563e:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80005640:	6c85                	lui	s9,0x1
    80005642:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80005646:	def43823          	sd	a5,-528(s0)
    8000564a:	ac0d                	j	8000587c <exec+0x320>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    8000564c:	00003517          	auipc	a0,0x3
    80005650:	21450513          	addi	a0,a0,532 # 80008860 <syscalls+0x2a8>
    80005654:	ffffb097          	auipc	ra,0xffffb
    80005658:	ef0080e7          	jalr	-272(ra) # 80000544 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000565c:	8756                	mv	a4,s5
    8000565e:	012d86bb          	addw	a3,s11,s2
    80005662:	4581                	li	a1,0
    80005664:	8526                	mv	a0,s1
    80005666:	fffff097          	auipc	ra,0xfffff
    8000566a:	c94080e7          	jalr	-876(ra) # 800042fa <readi>
    8000566e:	2501                	sext.w	a0,a0
    80005670:	1aaa9a63          	bne	s5,a0,80005824 <exec+0x2c8>
  for(i = 0; i < sz; i += PGSIZE){
    80005674:	6785                	lui	a5,0x1
    80005676:	0127893b          	addw	s2,a5,s2
    8000567a:	77fd                	lui	a5,0xfffff
    8000567c:	01478a3b          	addw	s4,a5,s4
    80005680:	1f897563          	bgeu	s2,s8,8000586a <exec+0x30e>
    pa = walkaddr(pagetable, va + i);
    80005684:	02091593          	slli	a1,s2,0x20
    80005688:	9181                	srli	a1,a1,0x20
    8000568a:	95ea                	add	a1,a1,s10
    8000568c:	855e                	mv	a0,s7
    8000568e:	ffffc097          	auipc	ra,0xffffc
    80005692:	ba8080e7          	jalr	-1112(ra) # 80001236 <walkaddr>
    80005696:	862a                	mv	a2,a0
    if(pa == 0)
    80005698:	d955                	beqz	a0,8000564c <exec+0xf0>
      n = PGSIZE;
    8000569a:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    8000569c:	fd9a70e3          	bgeu	s4,s9,8000565c <exec+0x100>
      n = sz - i;
    800056a0:	8ad2                	mv	s5,s4
    800056a2:	bf6d                	j	8000565c <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800056a4:	4a01                	li	s4,0
  iunlockput(ip);
    800056a6:	8526                	mv	a0,s1
    800056a8:	fffff097          	auipc	ra,0xfffff
    800056ac:	c00080e7          	jalr	-1024(ra) # 800042a8 <iunlockput>
  end_op();
    800056b0:	fffff097          	auipc	ra,0xfffff
    800056b4:	3d8080e7          	jalr	984(ra) # 80004a88 <end_op>
  p = myproc();
    800056b8:	ffffc097          	auipc	ra,0xffffc
    800056bc:	600080e7          	jalr	1536(ra) # 80001cb8 <myproc>
    800056c0:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800056c2:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    800056c6:	6785                	lui	a5,0x1
    800056c8:	17fd                	addi	a5,a5,-1
    800056ca:	9a3e                	add	s4,s4,a5
    800056cc:	757d                	lui	a0,0xfffff
    800056ce:	00aa77b3          	and	a5,s4,a0
    800056d2:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800056d6:	4691                	li	a3,4
    800056d8:	6609                	lui	a2,0x2
    800056da:	963e                	add	a2,a2,a5
    800056dc:	85be                	mv	a1,a5
    800056de:	855e                	mv	a0,s7
    800056e0:	ffffc097          	auipc	ra,0xffffc
    800056e4:	f0a080e7          	jalr	-246(ra) # 800015ea <uvmalloc>
    800056e8:	8b2a                	mv	s6,a0
  ip = 0;
    800056ea:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800056ec:	12050c63          	beqz	a0,80005824 <exec+0x2c8>
  uvmclear(pagetable, sz-2*PGSIZE);
    800056f0:	75f9                	lui	a1,0xffffe
    800056f2:	95aa                	add	a1,a1,a0
    800056f4:	855e                	mv	a0,s7
    800056f6:	ffffc097          	auipc	ra,0xffffc
    800056fa:	110080e7          	jalr	272(ra) # 80001806 <uvmclear>
  stackbase = sp - PGSIZE;
    800056fe:	7c7d                	lui	s8,0xfffff
    80005700:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80005702:	e0043783          	ld	a5,-512(s0)
    80005706:	6388                	ld	a0,0(a5)
    80005708:	c535                	beqz	a0,80005774 <exec+0x218>
    8000570a:	e9040993          	addi	s3,s0,-368
    8000570e:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80005712:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80005714:	ffffc097          	auipc	ra,0xffffc
    80005718:	914080e7          	jalr	-1772(ra) # 80001028 <strlen>
    8000571c:	2505                	addiw	a0,a0,1
    8000571e:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005722:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005726:	13896663          	bltu	s2,s8,80005852 <exec+0x2f6>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000572a:	e0043d83          	ld	s11,-512(s0)
    8000572e:	000dba03          	ld	s4,0(s11)
    80005732:	8552                	mv	a0,s4
    80005734:	ffffc097          	auipc	ra,0xffffc
    80005738:	8f4080e7          	jalr	-1804(ra) # 80001028 <strlen>
    8000573c:	0015069b          	addiw	a3,a0,1
    80005740:	8652                	mv	a2,s4
    80005742:	85ca                	mv	a1,s2
    80005744:	855e                	mv	a0,s7
    80005746:	ffffc097          	auipc	ra,0xffffc
    8000574a:	0f2080e7          	jalr	242(ra) # 80001838 <copyout>
    8000574e:	10054663          	bltz	a0,8000585a <exec+0x2fe>
    ustack[argc] = sp;
    80005752:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005756:	0485                	addi	s1,s1,1
    80005758:	008d8793          	addi	a5,s11,8
    8000575c:	e0f43023          	sd	a5,-512(s0)
    80005760:	008db503          	ld	a0,8(s11)
    80005764:	c911                	beqz	a0,80005778 <exec+0x21c>
    if(argc >= MAXARG)
    80005766:	09a1                	addi	s3,s3,8
    80005768:	fb3c96e3          	bne	s9,s3,80005714 <exec+0x1b8>
  sz = sz1;
    8000576c:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005770:	4481                	li	s1,0
    80005772:	a84d                	j	80005824 <exec+0x2c8>
  sp = sz;
    80005774:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005776:	4481                	li	s1,0
  ustack[argc] = 0;
    80005778:	00349793          	slli	a5,s1,0x3
    8000577c:	f9040713          	addi	a4,s0,-112
    80005780:	97ba                	add	a5,a5,a4
    80005782:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    80005786:	00148693          	addi	a3,s1,1
    8000578a:	068e                	slli	a3,a3,0x3
    8000578c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005790:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005794:	01897663          	bgeu	s2,s8,800057a0 <exec+0x244>
  sz = sz1;
    80005798:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000579c:	4481                	li	s1,0
    8000579e:	a059                	j	80005824 <exec+0x2c8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800057a0:	e9040613          	addi	a2,s0,-368
    800057a4:	85ca                	mv	a1,s2
    800057a6:	855e                	mv	a0,s7
    800057a8:	ffffc097          	auipc	ra,0xffffc
    800057ac:	090080e7          	jalr	144(ra) # 80001838 <copyout>
    800057b0:	0a054963          	bltz	a0,80005862 <exec+0x306>
  p->trapframe->a1 = sp;
    800057b4:	060ab783          	ld	a5,96(s5)
    800057b8:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800057bc:	df843783          	ld	a5,-520(s0)
    800057c0:	0007c703          	lbu	a4,0(a5)
    800057c4:	cf11                	beqz	a4,800057e0 <exec+0x284>
    800057c6:	0785                	addi	a5,a5,1
    if(*s == '/')
    800057c8:	02f00693          	li	a3,47
    800057cc:	a039                	j	800057da <exec+0x27e>
      last = s+1;
    800057ce:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800057d2:	0785                	addi	a5,a5,1
    800057d4:	fff7c703          	lbu	a4,-1(a5)
    800057d8:	c701                	beqz	a4,800057e0 <exec+0x284>
    if(*s == '/')
    800057da:	fed71ce3          	bne	a4,a3,800057d2 <exec+0x276>
    800057de:	bfc5                	j	800057ce <exec+0x272>
  safestrcpy(p->name, last, sizeof(p->name));
    800057e0:	4641                	li	a2,16
    800057e2:	df843583          	ld	a1,-520(s0)
    800057e6:	160a8513          	addi	a0,s5,352
    800057ea:	ffffc097          	auipc	ra,0xffffc
    800057ee:	80c080e7          	jalr	-2036(ra) # 80000ff6 <safestrcpy>
  oldpagetable = p->pagetable;
    800057f2:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    800057f6:	057abc23          	sd	s7,88(s5)
  p->sz = sz;
    800057fa:	056ab823          	sd	s6,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800057fe:	060ab783          	ld	a5,96(s5)
    80005802:	e6843703          	ld	a4,-408(s0)
    80005806:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005808:	060ab783          	ld	a5,96(s5)
    8000580c:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005810:	85ea                	mv	a1,s10
    80005812:	ffffc097          	auipc	ra,0xffffc
    80005816:	608080e7          	jalr	1544(ra) # 80001e1a <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000581a:	0004851b          	sext.w	a0,s1
    8000581e:	bbd9                	j	800055f4 <exec+0x98>
    80005820:	e1443423          	sd	s4,-504(s0)
    proc_freepagetable(pagetable, sz);
    80005824:	e0843583          	ld	a1,-504(s0)
    80005828:	855e                	mv	a0,s7
    8000582a:	ffffc097          	auipc	ra,0xffffc
    8000582e:	5f0080e7          	jalr	1520(ra) # 80001e1a <proc_freepagetable>
  if(ip){
    80005832:	da0497e3          	bnez	s1,800055e0 <exec+0x84>
  return -1;
    80005836:	557d                	li	a0,-1
    80005838:	bb75                	j	800055f4 <exec+0x98>
    8000583a:	e1443423          	sd	s4,-504(s0)
    8000583e:	b7dd                	j	80005824 <exec+0x2c8>
    80005840:	e1443423          	sd	s4,-504(s0)
    80005844:	b7c5                	j	80005824 <exec+0x2c8>
    80005846:	e1443423          	sd	s4,-504(s0)
    8000584a:	bfe9                	j	80005824 <exec+0x2c8>
    8000584c:	e1443423          	sd	s4,-504(s0)
    80005850:	bfd1                	j	80005824 <exec+0x2c8>
  sz = sz1;
    80005852:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005856:	4481                	li	s1,0
    80005858:	b7f1                	j	80005824 <exec+0x2c8>
  sz = sz1;
    8000585a:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000585e:	4481                	li	s1,0
    80005860:	b7d1                	j	80005824 <exec+0x2c8>
  sz = sz1;
    80005862:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005866:	4481                	li	s1,0
    80005868:	bf75                	j	80005824 <exec+0x2c8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000586a:	e0843a03          	ld	s4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000586e:	2b05                	addiw	s6,s6,1
    80005870:	0389899b          	addiw	s3,s3,56
    80005874:	e8845783          	lhu	a5,-376(s0)
    80005878:	e2fb57e3          	bge	s6,a5,800056a6 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000587c:	2981                	sext.w	s3,s3
    8000587e:	03800713          	li	a4,56
    80005882:	86ce                	mv	a3,s3
    80005884:	e1840613          	addi	a2,s0,-488
    80005888:	4581                	li	a1,0
    8000588a:	8526                	mv	a0,s1
    8000588c:	fffff097          	auipc	ra,0xfffff
    80005890:	a6e080e7          	jalr	-1426(ra) # 800042fa <readi>
    80005894:	03800793          	li	a5,56
    80005898:	f8f514e3          	bne	a0,a5,80005820 <exec+0x2c4>
    if(ph.type != ELF_PROG_LOAD)
    8000589c:	e1842783          	lw	a5,-488(s0)
    800058a0:	4705                	li	a4,1
    800058a2:	fce796e3          	bne	a5,a4,8000586e <exec+0x312>
    if(ph.memsz < ph.filesz)
    800058a6:	e4043903          	ld	s2,-448(s0)
    800058aa:	e3843783          	ld	a5,-456(s0)
    800058ae:	f8f966e3          	bltu	s2,a5,8000583a <exec+0x2de>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800058b2:	e2843783          	ld	a5,-472(s0)
    800058b6:	993e                	add	s2,s2,a5
    800058b8:	f8f964e3          	bltu	s2,a5,80005840 <exec+0x2e4>
    if(ph.vaddr % PGSIZE != 0)
    800058bc:	df043703          	ld	a4,-528(s0)
    800058c0:	8ff9                	and	a5,a5,a4
    800058c2:	f3d1                	bnez	a5,80005846 <exec+0x2ea>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800058c4:	e1c42503          	lw	a0,-484(s0)
    800058c8:	00000097          	auipc	ra,0x0
    800058cc:	c78080e7          	jalr	-904(ra) # 80005540 <flags2perm>
    800058d0:	86aa                	mv	a3,a0
    800058d2:	864a                	mv	a2,s2
    800058d4:	85d2                	mv	a1,s4
    800058d6:	855e                	mv	a0,s7
    800058d8:	ffffc097          	auipc	ra,0xffffc
    800058dc:	d12080e7          	jalr	-750(ra) # 800015ea <uvmalloc>
    800058e0:	e0a43423          	sd	a0,-504(s0)
    800058e4:	d525                	beqz	a0,8000584c <exec+0x2f0>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800058e6:	e2843d03          	ld	s10,-472(s0)
    800058ea:	e2042d83          	lw	s11,-480(s0)
    800058ee:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800058f2:	f60c0ce3          	beqz	s8,8000586a <exec+0x30e>
    800058f6:	8a62                	mv	s4,s8
    800058f8:	4901                	li	s2,0
    800058fa:	b369                	j	80005684 <exec+0x128>

00000000800058fc <argfd>:
    800058fc:	7179                	addi	sp,sp,-48
    800058fe:	f406                	sd	ra,40(sp)
    80005900:	f022                	sd	s0,32(sp)
    80005902:	ec26                	sd	s1,24(sp)
    80005904:	e84a                	sd	s2,16(sp)
    80005906:	1800                	addi	s0,sp,48
    80005908:	892e                	mv	s2,a1
    8000590a:	84b2                	mv	s1,a2
    8000590c:	fdc40593          	addi	a1,s0,-36
    80005910:	ffffe097          	auipc	ra,0xffffe
    80005914:	8a8080e7          	jalr	-1880(ra) # 800031b8 <argint>
    80005918:	fdc42703          	lw	a4,-36(s0)
    8000591c:	47bd                	li	a5,15
    8000591e:	02e7eb63          	bltu	a5,a4,80005954 <argfd+0x58>
    80005922:	ffffc097          	auipc	ra,0xffffc
    80005926:	396080e7          	jalr	918(ra) # 80001cb8 <myproc>
    8000592a:	fdc42703          	lw	a4,-36(s0)
    8000592e:	01a70793          	addi	a5,a4,26
    80005932:	078e                	slli	a5,a5,0x3
    80005934:	953e                	add	a0,a0,a5
    80005936:	651c                	ld	a5,8(a0)
    80005938:	c385                	beqz	a5,80005958 <argfd+0x5c>
    8000593a:	00090463          	beqz	s2,80005942 <argfd+0x46>
    8000593e:	00e92023          	sw	a4,0(s2)
    80005942:	4501                	li	a0,0
    80005944:	c091                	beqz	s1,80005948 <argfd+0x4c>
    80005946:	e09c                	sd	a5,0(s1)
    80005948:	70a2                	ld	ra,40(sp)
    8000594a:	7402                	ld	s0,32(sp)
    8000594c:	64e2                	ld	s1,24(sp)
    8000594e:	6942                	ld	s2,16(sp)
    80005950:	6145                	addi	sp,sp,48
    80005952:	8082                	ret
    80005954:	557d                	li	a0,-1
    80005956:	bfcd                	j	80005948 <argfd+0x4c>
    80005958:	557d                	li	a0,-1
    8000595a:	b7fd                	j	80005948 <argfd+0x4c>

000000008000595c <fdalloc>:
    8000595c:	1101                	addi	sp,sp,-32
    8000595e:	ec06                	sd	ra,24(sp)
    80005960:	e822                	sd	s0,16(sp)
    80005962:	e426                	sd	s1,8(sp)
    80005964:	1000                	addi	s0,sp,32
    80005966:	84aa                	mv	s1,a0
    80005968:	ffffc097          	auipc	ra,0xffffc
    8000596c:	350080e7          	jalr	848(ra) # 80001cb8 <myproc>
    80005970:	862a                	mv	a2,a0
    80005972:	0d850793          	addi	a5,a0,216 # fffffffffffff0d8 <end+0xffffffff7f97ae10>
    80005976:	4501                	li	a0,0
    80005978:	46c1                	li	a3,16
    8000597a:	6398                	ld	a4,0(a5)
    8000597c:	cb19                	beqz	a4,80005992 <fdalloc+0x36>
    8000597e:	2505                	addiw	a0,a0,1
    80005980:	07a1                	addi	a5,a5,8
    80005982:	fed51ce3          	bne	a0,a3,8000597a <fdalloc+0x1e>
    80005986:	557d                	li	a0,-1
    80005988:	60e2                	ld	ra,24(sp)
    8000598a:	6442                	ld	s0,16(sp)
    8000598c:	64a2                	ld	s1,8(sp)
    8000598e:	6105                	addi	sp,sp,32
    80005990:	8082                	ret
    80005992:	01a50793          	addi	a5,a0,26
    80005996:	078e                	slli	a5,a5,0x3
    80005998:	963e                	add	a2,a2,a5
    8000599a:	e604                	sd	s1,8(a2)
    8000599c:	b7f5                	j	80005988 <fdalloc+0x2c>

000000008000599e <create>:
    8000599e:	715d                	addi	sp,sp,-80
    800059a0:	e486                	sd	ra,72(sp)
    800059a2:	e0a2                	sd	s0,64(sp)
    800059a4:	fc26                	sd	s1,56(sp)
    800059a6:	f84a                	sd	s2,48(sp)
    800059a8:	f44e                	sd	s3,40(sp)
    800059aa:	f052                	sd	s4,32(sp)
    800059ac:	ec56                	sd	s5,24(sp)
    800059ae:	e85a                	sd	s6,16(sp)
    800059b0:	0880                	addi	s0,sp,80
    800059b2:	8b2e                	mv	s6,a1
    800059b4:	89b2                	mv	s3,a2
    800059b6:	8936                	mv	s2,a3
    800059b8:	fb040593          	addi	a1,s0,-80
    800059bc:	fffff097          	auipc	ra,0xfffff
    800059c0:	e4e080e7          	jalr	-434(ra) # 8000480a <nameiparent>
    800059c4:	84aa                	mv	s1,a0
    800059c6:	16050063          	beqz	a0,80005b26 <create+0x188>
    800059ca:	ffffe097          	auipc	ra,0xffffe
    800059ce:	67c080e7          	jalr	1660(ra) # 80004046 <ilock>
    800059d2:	4601                	li	a2,0
    800059d4:	fb040593          	addi	a1,s0,-80
    800059d8:	8526                	mv	a0,s1
    800059da:	fffff097          	auipc	ra,0xfffff
    800059de:	b50080e7          	jalr	-1200(ra) # 8000452a <dirlookup>
    800059e2:	8aaa                	mv	s5,a0
    800059e4:	c931                	beqz	a0,80005a38 <create+0x9a>
    800059e6:	8526                	mv	a0,s1
    800059e8:	fffff097          	auipc	ra,0xfffff
    800059ec:	8c0080e7          	jalr	-1856(ra) # 800042a8 <iunlockput>
    800059f0:	8556                	mv	a0,s5
    800059f2:	ffffe097          	auipc	ra,0xffffe
    800059f6:	654080e7          	jalr	1620(ra) # 80004046 <ilock>
    800059fa:	000b059b          	sext.w	a1,s6
    800059fe:	4789                	li	a5,2
    80005a00:	02f59563          	bne	a1,a5,80005a2a <create+0x8c>
    80005a04:	044ad783          	lhu	a5,68(s5)
    80005a08:	37f9                	addiw	a5,a5,-2
    80005a0a:	17c2                	slli	a5,a5,0x30
    80005a0c:	93c1                	srli	a5,a5,0x30
    80005a0e:	4705                	li	a4,1
    80005a10:	00f76d63          	bltu	a4,a5,80005a2a <create+0x8c>
    80005a14:	8556                	mv	a0,s5
    80005a16:	60a6                	ld	ra,72(sp)
    80005a18:	6406                	ld	s0,64(sp)
    80005a1a:	74e2                	ld	s1,56(sp)
    80005a1c:	7942                	ld	s2,48(sp)
    80005a1e:	79a2                	ld	s3,40(sp)
    80005a20:	7a02                	ld	s4,32(sp)
    80005a22:	6ae2                	ld	s5,24(sp)
    80005a24:	6b42                	ld	s6,16(sp)
    80005a26:	6161                	addi	sp,sp,80
    80005a28:	8082                	ret
    80005a2a:	8556                	mv	a0,s5
    80005a2c:	fffff097          	auipc	ra,0xfffff
    80005a30:	87c080e7          	jalr	-1924(ra) # 800042a8 <iunlockput>
    80005a34:	4a81                	li	s5,0
    80005a36:	bff9                	j	80005a14 <create+0x76>
    80005a38:	85da                	mv	a1,s6
    80005a3a:	4088                	lw	a0,0(s1)
    80005a3c:	ffffe097          	auipc	ra,0xffffe
    80005a40:	46e080e7          	jalr	1134(ra) # 80003eaa <ialloc>
    80005a44:	8a2a                	mv	s4,a0
    80005a46:	c921                	beqz	a0,80005a96 <create+0xf8>
    80005a48:	ffffe097          	auipc	ra,0xffffe
    80005a4c:	5fe080e7          	jalr	1534(ra) # 80004046 <ilock>
    80005a50:	053a1323          	sh	s3,70(s4)
    80005a54:	052a1423          	sh	s2,72(s4)
    80005a58:	4785                	li	a5,1
    80005a5a:	04fa1523          	sh	a5,74(s4)
    80005a5e:	8552                	mv	a0,s4
    80005a60:	ffffe097          	auipc	ra,0xffffe
    80005a64:	51c080e7          	jalr	1308(ra) # 80003f7c <iupdate>
    80005a68:	000b059b          	sext.w	a1,s6
    80005a6c:	4785                	li	a5,1
    80005a6e:	02f58b63          	beq	a1,a5,80005aa4 <create+0x106>
    80005a72:	004a2603          	lw	a2,4(s4)
    80005a76:	fb040593          	addi	a1,s0,-80
    80005a7a:	8526                	mv	a0,s1
    80005a7c:	fffff097          	auipc	ra,0xfffff
    80005a80:	cbe080e7          	jalr	-834(ra) # 8000473a <dirlink>
    80005a84:	06054f63          	bltz	a0,80005b02 <create+0x164>
    80005a88:	8526                	mv	a0,s1
    80005a8a:	fffff097          	auipc	ra,0xfffff
    80005a8e:	81e080e7          	jalr	-2018(ra) # 800042a8 <iunlockput>
    80005a92:	8ad2                	mv	s5,s4
    80005a94:	b741                	j	80005a14 <create+0x76>
    80005a96:	8526                	mv	a0,s1
    80005a98:	fffff097          	auipc	ra,0xfffff
    80005a9c:	810080e7          	jalr	-2032(ra) # 800042a8 <iunlockput>
    80005aa0:	8ad2                	mv	s5,s4
    80005aa2:	bf8d                	j	80005a14 <create+0x76>
    80005aa4:	004a2603          	lw	a2,4(s4)
    80005aa8:	00003597          	auipc	a1,0x3
    80005aac:	dd858593          	addi	a1,a1,-552 # 80008880 <syscalls+0x2c8>
    80005ab0:	8552                	mv	a0,s4
    80005ab2:	fffff097          	auipc	ra,0xfffff
    80005ab6:	c88080e7          	jalr	-888(ra) # 8000473a <dirlink>
    80005aba:	04054463          	bltz	a0,80005b02 <create+0x164>
    80005abe:	40d0                	lw	a2,4(s1)
    80005ac0:	00003597          	auipc	a1,0x3
    80005ac4:	dc858593          	addi	a1,a1,-568 # 80008888 <syscalls+0x2d0>
    80005ac8:	8552                	mv	a0,s4
    80005aca:	fffff097          	auipc	ra,0xfffff
    80005ace:	c70080e7          	jalr	-912(ra) # 8000473a <dirlink>
    80005ad2:	02054863          	bltz	a0,80005b02 <create+0x164>
    80005ad6:	004a2603          	lw	a2,4(s4)
    80005ada:	fb040593          	addi	a1,s0,-80
    80005ade:	8526                	mv	a0,s1
    80005ae0:	fffff097          	auipc	ra,0xfffff
    80005ae4:	c5a080e7          	jalr	-934(ra) # 8000473a <dirlink>
    80005ae8:	00054d63          	bltz	a0,80005b02 <create+0x164>
    80005aec:	04a4d783          	lhu	a5,74(s1)
    80005af0:	2785                	addiw	a5,a5,1
    80005af2:	04f49523          	sh	a5,74(s1)
    80005af6:	8526                	mv	a0,s1
    80005af8:	ffffe097          	auipc	ra,0xffffe
    80005afc:	484080e7          	jalr	1156(ra) # 80003f7c <iupdate>
    80005b00:	b761                	j	80005a88 <create+0xea>
    80005b02:	040a1523          	sh	zero,74(s4)
    80005b06:	8552                	mv	a0,s4
    80005b08:	ffffe097          	auipc	ra,0xffffe
    80005b0c:	474080e7          	jalr	1140(ra) # 80003f7c <iupdate>
    80005b10:	8552                	mv	a0,s4
    80005b12:	ffffe097          	auipc	ra,0xffffe
    80005b16:	796080e7          	jalr	1942(ra) # 800042a8 <iunlockput>
    80005b1a:	8526                	mv	a0,s1
    80005b1c:	ffffe097          	auipc	ra,0xffffe
    80005b20:	78c080e7          	jalr	1932(ra) # 800042a8 <iunlockput>
    80005b24:	bdc5                	j	80005a14 <create+0x76>
    80005b26:	8aaa                	mv	s5,a0
    80005b28:	b5f5                	j	80005a14 <create+0x76>

0000000080005b2a <sys_dup>:
    80005b2a:	7179                	addi	sp,sp,-48
    80005b2c:	f406                	sd	ra,40(sp)
    80005b2e:	f022                	sd	s0,32(sp)
    80005b30:	ec26                	sd	s1,24(sp)
    80005b32:	1800                	addi	s0,sp,48
    80005b34:	fd840613          	addi	a2,s0,-40
    80005b38:	4581                	li	a1,0
    80005b3a:	4501                	li	a0,0
    80005b3c:	00000097          	auipc	ra,0x0
    80005b40:	dc0080e7          	jalr	-576(ra) # 800058fc <argfd>
    80005b44:	57fd                	li	a5,-1
    80005b46:	02054363          	bltz	a0,80005b6c <sys_dup+0x42>
    80005b4a:	fd843503          	ld	a0,-40(s0)
    80005b4e:	00000097          	auipc	ra,0x0
    80005b52:	e0e080e7          	jalr	-498(ra) # 8000595c <fdalloc>
    80005b56:	84aa                	mv	s1,a0
    80005b58:	57fd                	li	a5,-1
    80005b5a:	00054963          	bltz	a0,80005b6c <sys_dup+0x42>
    80005b5e:	fd843503          	ld	a0,-40(s0)
    80005b62:	fffff097          	auipc	ra,0xfffff
    80005b66:	320080e7          	jalr	800(ra) # 80004e82 <filedup>
    80005b6a:	87a6                	mv	a5,s1
    80005b6c:	853e                	mv	a0,a5
    80005b6e:	70a2                	ld	ra,40(sp)
    80005b70:	7402                	ld	s0,32(sp)
    80005b72:	64e2                	ld	s1,24(sp)
    80005b74:	6145                	addi	sp,sp,48
    80005b76:	8082                	ret

0000000080005b78 <sys_read>:
    80005b78:	7179                	addi	sp,sp,-48
    80005b7a:	f406                	sd	ra,40(sp)
    80005b7c:	f022                	sd	s0,32(sp)
    80005b7e:	1800                	addi	s0,sp,48
    80005b80:	fd840593          	addi	a1,s0,-40
    80005b84:	4505                	li	a0,1
    80005b86:	ffffd097          	auipc	ra,0xffffd
    80005b8a:	652080e7          	jalr	1618(ra) # 800031d8 <argaddr>
    80005b8e:	fe440593          	addi	a1,s0,-28
    80005b92:	4509                	li	a0,2
    80005b94:	ffffd097          	auipc	ra,0xffffd
    80005b98:	624080e7          	jalr	1572(ra) # 800031b8 <argint>
    80005b9c:	fe840613          	addi	a2,s0,-24
    80005ba0:	4581                	li	a1,0
    80005ba2:	4501                	li	a0,0
    80005ba4:	00000097          	auipc	ra,0x0
    80005ba8:	d58080e7          	jalr	-680(ra) # 800058fc <argfd>
    80005bac:	87aa                	mv	a5,a0
    80005bae:	557d                	li	a0,-1
    80005bb0:	0007cc63          	bltz	a5,80005bc8 <sys_read+0x50>
    80005bb4:	fe442603          	lw	a2,-28(s0)
    80005bb8:	fd843583          	ld	a1,-40(s0)
    80005bbc:	fe843503          	ld	a0,-24(s0)
    80005bc0:	fffff097          	auipc	ra,0xfffff
    80005bc4:	44e080e7          	jalr	1102(ra) # 8000500e <fileread>
    80005bc8:	70a2                	ld	ra,40(sp)
    80005bca:	7402                	ld	s0,32(sp)
    80005bcc:	6145                	addi	sp,sp,48
    80005bce:	8082                	ret

0000000080005bd0 <sys_write>:
    80005bd0:	7179                	addi	sp,sp,-48
    80005bd2:	f406                	sd	ra,40(sp)
    80005bd4:	f022                	sd	s0,32(sp)
    80005bd6:	1800                	addi	s0,sp,48
    80005bd8:	fd840593          	addi	a1,s0,-40
    80005bdc:	4505                	li	a0,1
    80005bde:	ffffd097          	auipc	ra,0xffffd
    80005be2:	5fa080e7          	jalr	1530(ra) # 800031d8 <argaddr>
    80005be6:	fe440593          	addi	a1,s0,-28
    80005bea:	4509                	li	a0,2
    80005bec:	ffffd097          	auipc	ra,0xffffd
    80005bf0:	5cc080e7          	jalr	1484(ra) # 800031b8 <argint>
    80005bf4:	fe840613          	addi	a2,s0,-24
    80005bf8:	4581                	li	a1,0
    80005bfa:	4501                	li	a0,0
    80005bfc:	00000097          	auipc	ra,0x0
    80005c00:	d00080e7          	jalr	-768(ra) # 800058fc <argfd>
    80005c04:	87aa                	mv	a5,a0
    80005c06:	557d                	li	a0,-1
    80005c08:	0007cc63          	bltz	a5,80005c20 <sys_write+0x50>
    80005c0c:	fe442603          	lw	a2,-28(s0)
    80005c10:	fd843583          	ld	a1,-40(s0)
    80005c14:	fe843503          	ld	a0,-24(s0)
    80005c18:	fffff097          	auipc	ra,0xfffff
    80005c1c:	4b8080e7          	jalr	1208(ra) # 800050d0 <filewrite>
    80005c20:	70a2                	ld	ra,40(sp)
    80005c22:	7402                	ld	s0,32(sp)
    80005c24:	6145                	addi	sp,sp,48
    80005c26:	8082                	ret

0000000080005c28 <sys_close>:
    80005c28:	1101                	addi	sp,sp,-32
    80005c2a:	ec06                	sd	ra,24(sp)
    80005c2c:	e822                	sd	s0,16(sp)
    80005c2e:	1000                	addi	s0,sp,32
    80005c30:	fe040613          	addi	a2,s0,-32
    80005c34:	fec40593          	addi	a1,s0,-20
    80005c38:	4501                	li	a0,0
    80005c3a:	00000097          	auipc	ra,0x0
    80005c3e:	cc2080e7          	jalr	-830(ra) # 800058fc <argfd>
    80005c42:	57fd                	li	a5,-1
    80005c44:	02054463          	bltz	a0,80005c6c <sys_close+0x44>
    80005c48:	ffffc097          	auipc	ra,0xffffc
    80005c4c:	070080e7          	jalr	112(ra) # 80001cb8 <myproc>
    80005c50:	fec42783          	lw	a5,-20(s0)
    80005c54:	07e9                	addi	a5,a5,26
    80005c56:	078e                	slli	a5,a5,0x3
    80005c58:	97aa                	add	a5,a5,a0
    80005c5a:	0007b423          	sd	zero,8(a5)
    80005c5e:	fe043503          	ld	a0,-32(s0)
    80005c62:	fffff097          	auipc	ra,0xfffff
    80005c66:	272080e7          	jalr	626(ra) # 80004ed4 <fileclose>
    80005c6a:	4781                	li	a5,0
    80005c6c:	853e                	mv	a0,a5
    80005c6e:	60e2                	ld	ra,24(sp)
    80005c70:	6442                	ld	s0,16(sp)
    80005c72:	6105                	addi	sp,sp,32
    80005c74:	8082                	ret

0000000080005c76 <sys_fstat>:
    80005c76:	1101                	addi	sp,sp,-32
    80005c78:	ec06                	sd	ra,24(sp)
    80005c7a:	e822                	sd	s0,16(sp)
    80005c7c:	1000                	addi	s0,sp,32
    80005c7e:	fe040593          	addi	a1,s0,-32
    80005c82:	4505                	li	a0,1
    80005c84:	ffffd097          	auipc	ra,0xffffd
    80005c88:	554080e7          	jalr	1364(ra) # 800031d8 <argaddr>
    80005c8c:	fe840613          	addi	a2,s0,-24
    80005c90:	4581                	li	a1,0
    80005c92:	4501                	li	a0,0
    80005c94:	00000097          	auipc	ra,0x0
    80005c98:	c68080e7          	jalr	-920(ra) # 800058fc <argfd>
    80005c9c:	87aa                	mv	a5,a0
    80005c9e:	557d                	li	a0,-1
    80005ca0:	0007ca63          	bltz	a5,80005cb4 <sys_fstat+0x3e>
    80005ca4:	fe043583          	ld	a1,-32(s0)
    80005ca8:	fe843503          	ld	a0,-24(s0)
    80005cac:	fffff097          	auipc	ra,0xfffff
    80005cb0:	2f0080e7          	jalr	752(ra) # 80004f9c <filestat>
    80005cb4:	60e2                	ld	ra,24(sp)
    80005cb6:	6442                	ld	s0,16(sp)
    80005cb8:	6105                	addi	sp,sp,32
    80005cba:	8082                	ret

0000000080005cbc <sys_link>:
    80005cbc:	7169                	addi	sp,sp,-304
    80005cbe:	f606                	sd	ra,296(sp)
    80005cc0:	f222                	sd	s0,288(sp)
    80005cc2:	ee26                	sd	s1,280(sp)
    80005cc4:	ea4a                	sd	s2,272(sp)
    80005cc6:	1a00                	addi	s0,sp,304
    80005cc8:	08000613          	li	a2,128
    80005ccc:	ed040593          	addi	a1,s0,-304
    80005cd0:	4501                	li	a0,0
    80005cd2:	ffffd097          	auipc	ra,0xffffd
    80005cd6:	526080e7          	jalr	1318(ra) # 800031f8 <argstr>
    80005cda:	57fd                	li	a5,-1
    80005cdc:	10054e63          	bltz	a0,80005df8 <sys_link+0x13c>
    80005ce0:	08000613          	li	a2,128
    80005ce4:	f5040593          	addi	a1,s0,-176
    80005ce8:	4505                	li	a0,1
    80005cea:	ffffd097          	auipc	ra,0xffffd
    80005cee:	50e080e7          	jalr	1294(ra) # 800031f8 <argstr>
    80005cf2:	57fd                	li	a5,-1
    80005cf4:	10054263          	bltz	a0,80005df8 <sys_link+0x13c>
    80005cf8:	fffff097          	auipc	ra,0xfffff
    80005cfc:	d10080e7          	jalr	-752(ra) # 80004a08 <begin_op>
    80005d00:	ed040513          	addi	a0,s0,-304
    80005d04:	fffff097          	auipc	ra,0xfffff
    80005d08:	ae8080e7          	jalr	-1304(ra) # 800047ec <namei>
    80005d0c:	84aa                	mv	s1,a0
    80005d0e:	c551                	beqz	a0,80005d9a <sys_link+0xde>
    80005d10:	ffffe097          	auipc	ra,0xffffe
    80005d14:	336080e7          	jalr	822(ra) # 80004046 <ilock>
    80005d18:	04449703          	lh	a4,68(s1)
    80005d1c:	4785                	li	a5,1
    80005d1e:	08f70463          	beq	a4,a5,80005da6 <sys_link+0xea>
    80005d22:	04a4d783          	lhu	a5,74(s1)
    80005d26:	2785                	addiw	a5,a5,1
    80005d28:	04f49523          	sh	a5,74(s1)
    80005d2c:	8526                	mv	a0,s1
    80005d2e:	ffffe097          	auipc	ra,0xffffe
    80005d32:	24e080e7          	jalr	590(ra) # 80003f7c <iupdate>
    80005d36:	8526                	mv	a0,s1
    80005d38:	ffffe097          	auipc	ra,0xffffe
    80005d3c:	3d0080e7          	jalr	976(ra) # 80004108 <iunlock>
    80005d40:	fd040593          	addi	a1,s0,-48
    80005d44:	f5040513          	addi	a0,s0,-176
    80005d48:	fffff097          	auipc	ra,0xfffff
    80005d4c:	ac2080e7          	jalr	-1342(ra) # 8000480a <nameiparent>
    80005d50:	892a                	mv	s2,a0
    80005d52:	c935                	beqz	a0,80005dc6 <sys_link+0x10a>
    80005d54:	ffffe097          	auipc	ra,0xffffe
    80005d58:	2f2080e7          	jalr	754(ra) # 80004046 <ilock>
    80005d5c:	00092703          	lw	a4,0(s2)
    80005d60:	409c                	lw	a5,0(s1)
    80005d62:	04f71d63          	bne	a4,a5,80005dbc <sys_link+0x100>
    80005d66:	40d0                	lw	a2,4(s1)
    80005d68:	fd040593          	addi	a1,s0,-48
    80005d6c:	854a                	mv	a0,s2
    80005d6e:	fffff097          	auipc	ra,0xfffff
    80005d72:	9cc080e7          	jalr	-1588(ra) # 8000473a <dirlink>
    80005d76:	04054363          	bltz	a0,80005dbc <sys_link+0x100>
    80005d7a:	854a                	mv	a0,s2
    80005d7c:	ffffe097          	auipc	ra,0xffffe
    80005d80:	52c080e7          	jalr	1324(ra) # 800042a8 <iunlockput>
    80005d84:	8526                	mv	a0,s1
    80005d86:	ffffe097          	auipc	ra,0xffffe
    80005d8a:	47a080e7          	jalr	1146(ra) # 80004200 <iput>
    80005d8e:	fffff097          	auipc	ra,0xfffff
    80005d92:	cfa080e7          	jalr	-774(ra) # 80004a88 <end_op>
    80005d96:	4781                	li	a5,0
    80005d98:	a085                	j	80005df8 <sys_link+0x13c>
    80005d9a:	fffff097          	auipc	ra,0xfffff
    80005d9e:	cee080e7          	jalr	-786(ra) # 80004a88 <end_op>
    80005da2:	57fd                	li	a5,-1
    80005da4:	a891                	j	80005df8 <sys_link+0x13c>
    80005da6:	8526                	mv	a0,s1
    80005da8:	ffffe097          	auipc	ra,0xffffe
    80005dac:	500080e7          	jalr	1280(ra) # 800042a8 <iunlockput>
    80005db0:	fffff097          	auipc	ra,0xfffff
    80005db4:	cd8080e7          	jalr	-808(ra) # 80004a88 <end_op>
    80005db8:	57fd                	li	a5,-1
    80005dba:	a83d                	j	80005df8 <sys_link+0x13c>
    80005dbc:	854a                	mv	a0,s2
    80005dbe:	ffffe097          	auipc	ra,0xffffe
    80005dc2:	4ea080e7          	jalr	1258(ra) # 800042a8 <iunlockput>
    80005dc6:	8526                	mv	a0,s1
    80005dc8:	ffffe097          	auipc	ra,0xffffe
    80005dcc:	27e080e7          	jalr	638(ra) # 80004046 <ilock>
    80005dd0:	04a4d783          	lhu	a5,74(s1)
    80005dd4:	37fd                	addiw	a5,a5,-1
    80005dd6:	04f49523          	sh	a5,74(s1)
    80005dda:	8526                	mv	a0,s1
    80005ddc:	ffffe097          	auipc	ra,0xffffe
    80005de0:	1a0080e7          	jalr	416(ra) # 80003f7c <iupdate>
    80005de4:	8526                	mv	a0,s1
    80005de6:	ffffe097          	auipc	ra,0xffffe
    80005dea:	4c2080e7          	jalr	1218(ra) # 800042a8 <iunlockput>
    80005dee:	fffff097          	auipc	ra,0xfffff
    80005df2:	c9a080e7          	jalr	-870(ra) # 80004a88 <end_op>
    80005df6:	57fd                	li	a5,-1
    80005df8:	853e                	mv	a0,a5
    80005dfa:	70b2                	ld	ra,296(sp)
    80005dfc:	7412                	ld	s0,288(sp)
    80005dfe:	64f2                	ld	s1,280(sp)
    80005e00:	6952                	ld	s2,272(sp)
    80005e02:	6155                	addi	sp,sp,304
    80005e04:	8082                	ret

0000000080005e06 <sys_unlink>:
    80005e06:	7151                	addi	sp,sp,-240
    80005e08:	f586                	sd	ra,232(sp)
    80005e0a:	f1a2                	sd	s0,224(sp)
    80005e0c:	eda6                	sd	s1,216(sp)
    80005e0e:	e9ca                	sd	s2,208(sp)
    80005e10:	e5ce                	sd	s3,200(sp)
    80005e12:	1980                	addi	s0,sp,240
    80005e14:	08000613          	li	a2,128
    80005e18:	f3040593          	addi	a1,s0,-208
    80005e1c:	4501                	li	a0,0
    80005e1e:	ffffd097          	auipc	ra,0xffffd
    80005e22:	3da080e7          	jalr	986(ra) # 800031f8 <argstr>
    80005e26:	18054163          	bltz	a0,80005fa8 <sys_unlink+0x1a2>
    80005e2a:	fffff097          	auipc	ra,0xfffff
    80005e2e:	bde080e7          	jalr	-1058(ra) # 80004a08 <begin_op>
    80005e32:	fb040593          	addi	a1,s0,-80
    80005e36:	f3040513          	addi	a0,s0,-208
    80005e3a:	fffff097          	auipc	ra,0xfffff
    80005e3e:	9d0080e7          	jalr	-1584(ra) # 8000480a <nameiparent>
    80005e42:	84aa                	mv	s1,a0
    80005e44:	c979                	beqz	a0,80005f1a <sys_unlink+0x114>
    80005e46:	ffffe097          	auipc	ra,0xffffe
    80005e4a:	200080e7          	jalr	512(ra) # 80004046 <ilock>
    80005e4e:	00003597          	auipc	a1,0x3
    80005e52:	a3258593          	addi	a1,a1,-1486 # 80008880 <syscalls+0x2c8>
    80005e56:	fb040513          	addi	a0,s0,-80
    80005e5a:	ffffe097          	auipc	ra,0xffffe
    80005e5e:	6b6080e7          	jalr	1718(ra) # 80004510 <namecmp>
    80005e62:	14050a63          	beqz	a0,80005fb6 <sys_unlink+0x1b0>
    80005e66:	00003597          	auipc	a1,0x3
    80005e6a:	a2258593          	addi	a1,a1,-1502 # 80008888 <syscalls+0x2d0>
    80005e6e:	fb040513          	addi	a0,s0,-80
    80005e72:	ffffe097          	auipc	ra,0xffffe
    80005e76:	69e080e7          	jalr	1694(ra) # 80004510 <namecmp>
    80005e7a:	12050e63          	beqz	a0,80005fb6 <sys_unlink+0x1b0>
    80005e7e:	f2c40613          	addi	a2,s0,-212
    80005e82:	fb040593          	addi	a1,s0,-80
    80005e86:	8526                	mv	a0,s1
    80005e88:	ffffe097          	auipc	ra,0xffffe
    80005e8c:	6a2080e7          	jalr	1698(ra) # 8000452a <dirlookup>
    80005e90:	892a                	mv	s2,a0
    80005e92:	12050263          	beqz	a0,80005fb6 <sys_unlink+0x1b0>
    80005e96:	ffffe097          	auipc	ra,0xffffe
    80005e9a:	1b0080e7          	jalr	432(ra) # 80004046 <ilock>
    80005e9e:	04a91783          	lh	a5,74(s2)
    80005ea2:	08f05263          	blez	a5,80005f26 <sys_unlink+0x120>
    80005ea6:	04491703          	lh	a4,68(s2)
    80005eaa:	4785                	li	a5,1
    80005eac:	08f70563          	beq	a4,a5,80005f36 <sys_unlink+0x130>
    80005eb0:	4641                	li	a2,16
    80005eb2:	4581                	li	a1,0
    80005eb4:	fc040513          	addi	a0,s0,-64
    80005eb8:	ffffb097          	auipc	ra,0xffffb
    80005ebc:	fec080e7          	jalr	-20(ra) # 80000ea4 <memset>
    80005ec0:	4741                	li	a4,16
    80005ec2:	f2c42683          	lw	a3,-212(s0)
    80005ec6:	fc040613          	addi	a2,s0,-64
    80005eca:	4581                	li	a1,0
    80005ecc:	8526                	mv	a0,s1
    80005ece:	ffffe097          	auipc	ra,0xffffe
    80005ed2:	524080e7          	jalr	1316(ra) # 800043f2 <writei>
    80005ed6:	47c1                	li	a5,16
    80005ed8:	0af51563          	bne	a0,a5,80005f82 <sys_unlink+0x17c>
    80005edc:	04491703          	lh	a4,68(s2)
    80005ee0:	4785                	li	a5,1
    80005ee2:	0af70863          	beq	a4,a5,80005f92 <sys_unlink+0x18c>
    80005ee6:	8526                	mv	a0,s1
    80005ee8:	ffffe097          	auipc	ra,0xffffe
    80005eec:	3c0080e7          	jalr	960(ra) # 800042a8 <iunlockput>
    80005ef0:	04a95783          	lhu	a5,74(s2)
    80005ef4:	37fd                	addiw	a5,a5,-1
    80005ef6:	04f91523          	sh	a5,74(s2)
    80005efa:	854a                	mv	a0,s2
    80005efc:	ffffe097          	auipc	ra,0xffffe
    80005f00:	080080e7          	jalr	128(ra) # 80003f7c <iupdate>
    80005f04:	854a                	mv	a0,s2
    80005f06:	ffffe097          	auipc	ra,0xffffe
    80005f0a:	3a2080e7          	jalr	930(ra) # 800042a8 <iunlockput>
    80005f0e:	fffff097          	auipc	ra,0xfffff
    80005f12:	b7a080e7          	jalr	-1158(ra) # 80004a88 <end_op>
    80005f16:	4501                	li	a0,0
    80005f18:	a84d                	j	80005fca <sys_unlink+0x1c4>
    80005f1a:	fffff097          	auipc	ra,0xfffff
    80005f1e:	b6e080e7          	jalr	-1170(ra) # 80004a88 <end_op>
    80005f22:	557d                	li	a0,-1
    80005f24:	a05d                	j	80005fca <sys_unlink+0x1c4>
    80005f26:	00003517          	auipc	a0,0x3
    80005f2a:	96a50513          	addi	a0,a0,-1686 # 80008890 <syscalls+0x2d8>
    80005f2e:	ffffa097          	auipc	ra,0xffffa
    80005f32:	616080e7          	jalr	1558(ra) # 80000544 <panic>
    80005f36:	04c92703          	lw	a4,76(s2)
    80005f3a:	02000793          	li	a5,32
    80005f3e:	f6e7f9e3          	bgeu	a5,a4,80005eb0 <sys_unlink+0xaa>
    80005f42:	02000993          	li	s3,32
    80005f46:	4741                	li	a4,16
    80005f48:	86ce                	mv	a3,s3
    80005f4a:	f1840613          	addi	a2,s0,-232
    80005f4e:	4581                	li	a1,0
    80005f50:	854a                	mv	a0,s2
    80005f52:	ffffe097          	auipc	ra,0xffffe
    80005f56:	3a8080e7          	jalr	936(ra) # 800042fa <readi>
    80005f5a:	47c1                	li	a5,16
    80005f5c:	00f51b63          	bne	a0,a5,80005f72 <sys_unlink+0x16c>
    80005f60:	f1845783          	lhu	a5,-232(s0)
    80005f64:	e7a1                	bnez	a5,80005fac <sys_unlink+0x1a6>
    80005f66:	29c1                	addiw	s3,s3,16
    80005f68:	04c92783          	lw	a5,76(s2)
    80005f6c:	fcf9ede3          	bltu	s3,a5,80005f46 <sys_unlink+0x140>
    80005f70:	b781                	j	80005eb0 <sys_unlink+0xaa>
    80005f72:	00003517          	auipc	a0,0x3
    80005f76:	93650513          	addi	a0,a0,-1738 # 800088a8 <syscalls+0x2f0>
    80005f7a:	ffffa097          	auipc	ra,0xffffa
    80005f7e:	5ca080e7          	jalr	1482(ra) # 80000544 <panic>
    80005f82:	00003517          	auipc	a0,0x3
    80005f86:	93e50513          	addi	a0,a0,-1730 # 800088c0 <syscalls+0x308>
    80005f8a:	ffffa097          	auipc	ra,0xffffa
    80005f8e:	5ba080e7          	jalr	1466(ra) # 80000544 <panic>
    80005f92:	04a4d783          	lhu	a5,74(s1)
    80005f96:	37fd                	addiw	a5,a5,-1
    80005f98:	04f49523          	sh	a5,74(s1)
    80005f9c:	8526                	mv	a0,s1
    80005f9e:	ffffe097          	auipc	ra,0xffffe
    80005fa2:	fde080e7          	jalr	-34(ra) # 80003f7c <iupdate>
    80005fa6:	b781                	j	80005ee6 <sys_unlink+0xe0>
    80005fa8:	557d                	li	a0,-1
    80005faa:	a005                	j	80005fca <sys_unlink+0x1c4>
    80005fac:	854a                	mv	a0,s2
    80005fae:	ffffe097          	auipc	ra,0xffffe
    80005fb2:	2fa080e7          	jalr	762(ra) # 800042a8 <iunlockput>
    80005fb6:	8526                	mv	a0,s1
    80005fb8:	ffffe097          	auipc	ra,0xffffe
    80005fbc:	2f0080e7          	jalr	752(ra) # 800042a8 <iunlockput>
    80005fc0:	fffff097          	auipc	ra,0xfffff
    80005fc4:	ac8080e7          	jalr	-1336(ra) # 80004a88 <end_op>
    80005fc8:	557d                	li	a0,-1
    80005fca:	70ae                	ld	ra,232(sp)
    80005fcc:	740e                	ld	s0,224(sp)
    80005fce:	64ee                	ld	s1,216(sp)
    80005fd0:	694e                	ld	s2,208(sp)
    80005fd2:	69ae                	ld	s3,200(sp)
    80005fd4:	616d                	addi	sp,sp,240
    80005fd6:	8082                	ret

0000000080005fd8 <sys_open>:
    80005fd8:	7131                	addi	sp,sp,-192
    80005fda:	fd06                	sd	ra,184(sp)
    80005fdc:	f922                	sd	s0,176(sp)
    80005fde:	f526                	sd	s1,168(sp)
    80005fe0:	f14a                	sd	s2,160(sp)
    80005fe2:	ed4e                	sd	s3,152(sp)
    80005fe4:	0180                	addi	s0,sp,192
    80005fe6:	f4c40593          	addi	a1,s0,-180
    80005fea:	4505                	li	a0,1
    80005fec:	ffffd097          	auipc	ra,0xffffd
    80005ff0:	1cc080e7          	jalr	460(ra) # 800031b8 <argint>
    80005ff4:	08000613          	li	a2,128
    80005ff8:	f5040593          	addi	a1,s0,-176
    80005ffc:	4501                	li	a0,0
    80005ffe:	ffffd097          	auipc	ra,0xffffd
    80006002:	1fa080e7          	jalr	506(ra) # 800031f8 <argstr>
    80006006:	87aa                	mv	a5,a0
    80006008:	557d                	li	a0,-1
    8000600a:	0a07c963          	bltz	a5,800060bc <sys_open+0xe4>
    8000600e:	fffff097          	auipc	ra,0xfffff
    80006012:	9fa080e7          	jalr	-1542(ra) # 80004a08 <begin_op>
    80006016:	f4c42783          	lw	a5,-180(s0)
    8000601a:	2007f793          	andi	a5,a5,512
    8000601e:	cfc5                	beqz	a5,800060d6 <sys_open+0xfe>
    80006020:	4681                	li	a3,0
    80006022:	4601                	li	a2,0
    80006024:	4589                	li	a1,2
    80006026:	f5040513          	addi	a0,s0,-176
    8000602a:	00000097          	auipc	ra,0x0
    8000602e:	974080e7          	jalr	-1676(ra) # 8000599e <create>
    80006032:	84aa                	mv	s1,a0
    80006034:	c959                	beqz	a0,800060ca <sys_open+0xf2>
    80006036:	04449703          	lh	a4,68(s1)
    8000603a:	478d                	li	a5,3
    8000603c:	00f71763          	bne	a4,a5,8000604a <sys_open+0x72>
    80006040:	0464d703          	lhu	a4,70(s1)
    80006044:	47a5                	li	a5,9
    80006046:	0ce7ed63          	bltu	a5,a4,80006120 <sys_open+0x148>
    8000604a:	fffff097          	auipc	ra,0xfffff
    8000604e:	dce080e7          	jalr	-562(ra) # 80004e18 <filealloc>
    80006052:	89aa                	mv	s3,a0
    80006054:	10050363          	beqz	a0,8000615a <sys_open+0x182>
    80006058:	00000097          	auipc	ra,0x0
    8000605c:	904080e7          	jalr	-1788(ra) # 8000595c <fdalloc>
    80006060:	892a                	mv	s2,a0
    80006062:	0e054763          	bltz	a0,80006150 <sys_open+0x178>
    80006066:	04449703          	lh	a4,68(s1)
    8000606a:	478d                	li	a5,3
    8000606c:	0cf70563          	beq	a4,a5,80006136 <sys_open+0x15e>
    80006070:	4789                	li	a5,2
    80006072:	00f9a023          	sw	a5,0(s3)
    80006076:	0209a023          	sw	zero,32(s3)
    8000607a:	0099bc23          	sd	s1,24(s3)
    8000607e:	f4c42783          	lw	a5,-180(s0)
    80006082:	0017c713          	xori	a4,a5,1
    80006086:	8b05                	andi	a4,a4,1
    80006088:	00e98423          	sb	a4,8(s3)
    8000608c:	0037f713          	andi	a4,a5,3
    80006090:	00e03733          	snez	a4,a4
    80006094:	00e984a3          	sb	a4,9(s3)
    80006098:	4007f793          	andi	a5,a5,1024
    8000609c:	c791                	beqz	a5,800060a8 <sys_open+0xd0>
    8000609e:	04449703          	lh	a4,68(s1)
    800060a2:	4789                	li	a5,2
    800060a4:	0af70063          	beq	a4,a5,80006144 <sys_open+0x16c>
    800060a8:	8526                	mv	a0,s1
    800060aa:	ffffe097          	auipc	ra,0xffffe
    800060ae:	05e080e7          	jalr	94(ra) # 80004108 <iunlock>
    800060b2:	fffff097          	auipc	ra,0xfffff
    800060b6:	9d6080e7          	jalr	-1578(ra) # 80004a88 <end_op>
    800060ba:	854a                	mv	a0,s2
    800060bc:	70ea                	ld	ra,184(sp)
    800060be:	744a                	ld	s0,176(sp)
    800060c0:	74aa                	ld	s1,168(sp)
    800060c2:	790a                	ld	s2,160(sp)
    800060c4:	69ea                	ld	s3,152(sp)
    800060c6:	6129                	addi	sp,sp,192
    800060c8:	8082                	ret
    800060ca:	fffff097          	auipc	ra,0xfffff
    800060ce:	9be080e7          	jalr	-1602(ra) # 80004a88 <end_op>
    800060d2:	557d                	li	a0,-1
    800060d4:	b7e5                	j	800060bc <sys_open+0xe4>
    800060d6:	f5040513          	addi	a0,s0,-176
    800060da:	ffffe097          	auipc	ra,0xffffe
    800060de:	712080e7          	jalr	1810(ra) # 800047ec <namei>
    800060e2:	84aa                	mv	s1,a0
    800060e4:	c905                	beqz	a0,80006114 <sys_open+0x13c>
    800060e6:	ffffe097          	auipc	ra,0xffffe
    800060ea:	f60080e7          	jalr	-160(ra) # 80004046 <ilock>
    800060ee:	04449703          	lh	a4,68(s1)
    800060f2:	4785                	li	a5,1
    800060f4:	f4f711e3          	bne	a4,a5,80006036 <sys_open+0x5e>
    800060f8:	f4c42783          	lw	a5,-180(s0)
    800060fc:	d7b9                	beqz	a5,8000604a <sys_open+0x72>
    800060fe:	8526                	mv	a0,s1
    80006100:	ffffe097          	auipc	ra,0xffffe
    80006104:	1a8080e7          	jalr	424(ra) # 800042a8 <iunlockput>
    80006108:	fffff097          	auipc	ra,0xfffff
    8000610c:	980080e7          	jalr	-1664(ra) # 80004a88 <end_op>
    80006110:	557d                	li	a0,-1
    80006112:	b76d                	j	800060bc <sys_open+0xe4>
    80006114:	fffff097          	auipc	ra,0xfffff
    80006118:	974080e7          	jalr	-1676(ra) # 80004a88 <end_op>
    8000611c:	557d                	li	a0,-1
    8000611e:	bf79                	j	800060bc <sys_open+0xe4>
    80006120:	8526                	mv	a0,s1
    80006122:	ffffe097          	auipc	ra,0xffffe
    80006126:	186080e7          	jalr	390(ra) # 800042a8 <iunlockput>
    8000612a:	fffff097          	auipc	ra,0xfffff
    8000612e:	95e080e7          	jalr	-1698(ra) # 80004a88 <end_op>
    80006132:	557d                	li	a0,-1
    80006134:	b761                	j	800060bc <sys_open+0xe4>
    80006136:	00f9a023          	sw	a5,0(s3)
    8000613a:	04649783          	lh	a5,70(s1)
    8000613e:	02f99223          	sh	a5,36(s3)
    80006142:	bf25                	j	8000607a <sys_open+0xa2>
    80006144:	8526                	mv	a0,s1
    80006146:	ffffe097          	auipc	ra,0xffffe
    8000614a:	00e080e7          	jalr	14(ra) # 80004154 <itrunc>
    8000614e:	bfa9                	j	800060a8 <sys_open+0xd0>
    80006150:	854e                	mv	a0,s3
    80006152:	fffff097          	auipc	ra,0xfffff
    80006156:	d82080e7          	jalr	-638(ra) # 80004ed4 <fileclose>
    8000615a:	8526                	mv	a0,s1
    8000615c:	ffffe097          	auipc	ra,0xffffe
    80006160:	14c080e7          	jalr	332(ra) # 800042a8 <iunlockput>
    80006164:	fffff097          	auipc	ra,0xfffff
    80006168:	924080e7          	jalr	-1756(ra) # 80004a88 <end_op>
    8000616c:	557d                	li	a0,-1
    8000616e:	b7b9                	j	800060bc <sys_open+0xe4>

0000000080006170 <sys_mkdir>:
    80006170:	7175                	addi	sp,sp,-144
    80006172:	e506                	sd	ra,136(sp)
    80006174:	e122                	sd	s0,128(sp)
    80006176:	0900                	addi	s0,sp,144
    80006178:	fffff097          	auipc	ra,0xfffff
    8000617c:	890080e7          	jalr	-1904(ra) # 80004a08 <begin_op>
    80006180:	08000613          	li	a2,128
    80006184:	f7040593          	addi	a1,s0,-144
    80006188:	4501                	li	a0,0
    8000618a:	ffffd097          	auipc	ra,0xffffd
    8000618e:	06e080e7          	jalr	110(ra) # 800031f8 <argstr>
    80006192:	02054963          	bltz	a0,800061c4 <sys_mkdir+0x54>
    80006196:	4681                	li	a3,0
    80006198:	4601                	li	a2,0
    8000619a:	4585                	li	a1,1
    8000619c:	f7040513          	addi	a0,s0,-144
    800061a0:	fffff097          	auipc	ra,0xfffff
    800061a4:	7fe080e7          	jalr	2046(ra) # 8000599e <create>
    800061a8:	cd11                	beqz	a0,800061c4 <sys_mkdir+0x54>
    800061aa:	ffffe097          	auipc	ra,0xffffe
    800061ae:	0fe080e7          	jalr	254(ra) # 800042a8 <iunlockput>
    800061b2:	fffff097          	auipc	ra,0xfffff
    800061b6:	8d6080e7          	jalr	-1834(ra) # 80004a88 <end_op>
    800061ba:	4501                	li	a0,0
    800061bc:	60aa                	ld	ra,136(sp)
    800061be:	640a                	ld	s0,128(sp)
    800061c0:	6149                	addi	sp,sp,144
    800061c2:	8082                	ret
    800061c4:	fffff097          	auipc	ra,0xfffff
    800061c8:	8c4080e7          	jalr	-1852(ra) # 80004a88 <end_op>
    800061cc:	557d                	li	a0,-1
    800061ce:	b7fd                	j	800061bc <sys_mkdir+0x4c>

00000000800061d0 <sys_mknod>:
    800061d0:	7135                	addi	sp,sp,-160
    800061d2:	ed06                	sd	ra,152(sp)
    800061d4:	e922                	sd	s0,144(sp)
    800061d6:	1100                	addi	s0,sp,160
    800061d8:	fffff097          	auipc	ra,0xfffff
    800061dc:	830080e7          	jalr	-2000(ra) # 80004a08 <begin_op>
    800061e0:	f6c40593          	addi	a1,s0,-148
    800061e4:	4505                	li	a0,1
    800061e6:	ffffd097          	auipc	ra,0xffffd
    800061ea:	fd2080e7          	jalr	-46(ra) # 800031b8 <argint>
    800061ee:	f6840593          	addi	a1,s0,-152
    800061f2:	4509                	li	a0,2
    800061f4:	ffffd097          	auipc	ra,0xffffd
    800061f8:	fc4080e7          	jalr	-60(ra) # 800031b8 <argint>
    800061fc:	08000613          	li	a2,128
    80006200:	f7040593          	addi	a1,s0,-144
    80006204:	4501                	li	a0,0
    80006206:	ffffd097          	auipc	ra,0xffffd
    8000620a:	ff2080e7          	jalr	-14(ra) # 800031f8 <argstr>
    8000620e:	02054b63          	bltz	a0,80006244 <sys_mknod+0x74>
    80006212:	f6841683          	lh	a3,-152(s0)
    80006216:	f6c41603          	lh	a2,-148(s0)
    8000621a:	458d                	li	a1,3
    8000621c:	f7040513          	addi	a0,s0,-144
    80006220:	fffff097          	auipc	ra,0xfffff
    80006224:	77e080e7          	jalr	1918(ra) # 8000599e <create>
    80006228:	cd11                	beqz	a0,80006244 <sys_mknod+0x74>
    8000622a:	ffffe097          	auipc	ra,0xffffe
    8000622e:	07e080e7          	jalr	126(ra) # 800042a8 <iunlockput>
    80006232:	fffff097          	auipc	ra,0xfffff
    80006236:	856080e7          	jalr	-1962(ra) # 80004a88 <end_op>
    8000623a:	4501                	li	a0,0
    8000623c:	60ea                	ld	ra,152(sp)
    8000623e:	644a                	ld	s0,144(sp)
    80006240:	610d                	addi	sp,sp,160
    80006242:	8082                	ret
    80006244:	fffff097          	auipc	ra,0xfffff
    80006248:	844080e7          	jalr	-1980(ra) # 80004a88 <end_op>
    8000624c:	557d                	li	a0,-1
    8000624e:	b7fd                	j	8000623c <sys_mknod+0x6c>

0000000080006250 <sys_chdir>:
    80006250:	7135                	addi	sp,sp,-160
    80006252:	ed06                	sd	ra,152(sp)
    80006254:	e922                	sd	s0,144(sp)
    80006256:	e526                	sd	s1,136(sp)
    80006258:	e14a                	sd	s2,128(sp)
    8000625a:	1100                	addi	s0,sp,160
    8000625c:	ffffc097          	auipc	ra,0xffffc
    80006260:	a5c080e7          	jalr	-1444(ra) # 80001cb8 <myproc>
    80006264:	892a                	mv	s2,a0
    80006266:	ffffe097          	auipc	ra,0xffffe
    8000626a:	7a2080e7          	jalr	1954(ra) # 80004a08 <begin_op>
    8000626e:	08000613          	li	a2,128
    80006272:	f6040593          	addi	a1,s0,-160
    80006276:	4501                	li	a0,0
    80006278:	ffffd097          	auipc	ra,0xffffd
    8000627c:	f80080e7          	jalr	-128(ra) # 800031f8 <argstr>
    80006280:	04054b63          	bltz	a0,800062d6 <sys_chdir+0x86>
    80006284:	f6040513          	addi	a0,s0,-160
    80006288:	ffffe097          	auipc	ra,0xffffe
    8000628c:	564080e7          	jalr	1380(ra) # 800047ec <namei>
    80006290:	84aa                	mv	s1,a0
    80006292:	c131                	beqz	a0,800062d6 <sys_chdir+0x86>
    80006294:	ffffe097          	auipc	ra,0xffffe
    80006298:	db2080e7          	jalr	-590(ra) # 80004046 <ilock>
    8000629c:	04449703          	lh	a4,68(s1)
    800062a0:	4785                	li	a5,1
    800062a2:	04f71063          	bne	a4,a5,800062e2 <sys_chdir+0x92>
    800062a6:	8526                	mv	a0,s1
    800062a8:	ffffe097          	auipc	ra,0xffffe
    800062ac:	e60080e7          	jalr	-416(ra) # 80004108 <iunlock>
    800062b0:	15893503          	ld	a0,344(s2)
    800062b4:	ffffe097          	auipc	ra,0xffffe
    800062b8:	f4c080e7          	jalr	-180(ra) # 80004200 <iput>
    800062bc:	ffffe097          	auipc	ra,0xffffe
    800062c0:	7cc080e7          	jalr	1996(ra) # 80004a88 <end_op>
    800062c4:	14993c23          	sd	s1,344(s2)
    800062c8:	4501                	li	a0,0
    800062ca:	60ea                	ld	ra,152(sp)
    800062cc:	644a                	ld	s0,144(sp)
    800062ce:	64aa                	ld	s1,136(sp)
    800062d0:	690a                	ld	s2,128(sp)
    800062d2:	610d                	addi	sp,sp,160
    800062d4:	8082                	ret
    800062d6:	ffffe097          	auipc	ra,0xffffe
    800062da:	7b2080e7          	jalr	1970(ra) # 80004a88 <end_op>
    800062de:	557d                	li	a0,-1
    800062e0:	b7ed                	j	800062ca <sys_chdir+0x7a>
    800062e2:	8526                	mv	a0,s1
    800062e4:	ffffe097          	auipc	ra,0xffffe
    800062e8:	fc4080e7          	jalr	-60(ra) # 800042a8 <iunlockput>
    800062ec:	ffffe097          	auipc	ra,0xffffe
    800062f0:	79c080e7          	jalr	1948(ra) # 80004a88 <end_op>
    800062f4:	557d                	li	a0,-1
    800062f6:	bfd1                	j	800062ca <sys_chdir+0x7a>

00000000800062f8 <sys_exec>:
    800062f8:	7145                	addi	sp,sp,-464
    800062fa:	e786                	sd	ra,456(sp)
    800062fc:	e3a2                	sd	s0,448(sp)
    800062fe:	ff26                	sd	s1,440(sp)
    80006300:	fb4a                	sd	s2,432(sp)
    80006302:	f74e                	sd	s3,424(sp)
    80006304:	f352                	sd	s4,416(sp)
    80006306:	ef56                	sd	s5,408(sp)
    80006308:	0b80                	addi	s0,sp,464
    8000630a:	e3840593          	addi	a1,s0,-456
    8000630e:	4505                	li	a0,1
    80006310:	ffffd097          	auipc	ra,0xffffd
    80006314:	ec8080e7          	jalr	-312(ra) # 800031d8 <argaddr>
    80006318:	08000613          	li	a2,128
    8000631c:	f4040593          	addi	a1,s0,-192
    80006320:	4501                	li	a0,0
    80006322:	ffffd097          	auipc	ra,0xffffd
    80006326:	ed6080e7          	jalr	-298(ra) # 800031f8 <argstr>
    8000632a:	87aa                	mv	a5,a0
    8000632c:	557d                	li	a0,-1
    8000632e:	0c07c263          	bltz	a5,800063f2 <sys_exec+0xfa>
    80006332:	10000613          	li	a2,256
    80006336:	4581                	li	a1,0
    80006338:	e4040513          	addi	a0,s0,-448
    8000633c:	ffffb097          	auipc	ra,0xffffb
    80006340:	b68080e7          	jalr	-1176(ra) # 80000ea4 <memset>
    80006344:	e4040493          	addi	s1,s0,-448
    80006348:	89a6                	mv	s3,s1
    8000634a:	4901                	li	s2,0
    8000634c:	02000a13          	li	s4,32
    80006350:	00090a9b          	sext.w	s5,s2
    80006354:	00391513          	slli	a0,s2,0x3
    80006358:	e3040593          	addi	a1,s0,-464
    8000635c:	e3843783          	ld	a5,-456(s0)
    80006360:	953e                	add	a0,a0,a5
    80006362:	ffffd097          	auipc	ra,0xffffd
    80006366:	db8080e7          	jalr	-584(ra) # 8000311a <fetchaddr>
    8000636a:	02054a63          	bltz	a0,8000639e <sys_exec+0xa6>
    8000636e:	e3043783          	ld	a5,-464(s0)
    80006372:	c3b9                	beqz	a5,800063b8 <sys_exec+0xc0>
    80006374:	ffffb097          	auipc	ra,0xffffb
    80006378:	900080e7          	jalr	-1792(ra) # 80000c74 <kalloc>
    8000637c:	85aa                	mv	a1,a0
    8000637e:	00a9b023          	sd	a0,0(s3)
    80006382:	cd11                	beqz	a0,8000639e <sys_exec+0xa6>
    80006384:	6605                	lui	a2,0x1
    80006386:	e3043503          	ld	a0,-464(s0)
    8000638a:	ffffd097          	auipc	ra,0xffffd
    8000638e:	de2080e7          	jalr	-542(ra) # 8000316c <fetchstr>
    80006392:	00054663          	bltz	a0,8000639e <sys_exec+0xa6>
    80006396:	0905                	addi	s2,s2,1
    80006398:	09a1                	addi	s3,s3,8
    8000639a:	fb491be3          	bne	s2,s4,80006350 <sys_exec+0x58>
    8000639e:	10048913          	addi	s2,s1,256
    800063a2:	6088                	ld	a0,0(s1)
    800063a4:	c531                	beqz	a0,800063f0 <sys_exec+0xf8>
    800063a6:	ffffa097          	auipc	ra,0xffffa
    800063aa:	728080e7          	jalr	1832(ra) # 80000ace <kfree>
    800063ae:	04a1                	addi	s1,s1,8
    800063b0:	ff2499e3          	bne	s1,s2,800063a2 <sys_exec+0xaa>
    800063b4:	557d                	li	a0,-1
    800063b6:	a835                	j	800063f2 <sys_exec+0xfa>
    800063b8:	0a8e                	slli	s5,s5,0x3
    800063ba:	fc040793          	addi	a5,s0,-64
    800063be:	9abe                	add	s5,s5,a5
    800063c0:	e80ab023          	sd	zero,-384(s5)
    800063c4:	e4040593          	addi	a1,s0,-448
    800063c8:	f4040513          	addi	a0,s0,-192
    800063cc:	fffff097          	auipc	ra,0xfffff
    800063d0:	190080e7          	jalr	400(ra) # 8000555c <exec>
    800063d4:	892a                	mv	s2,a0
    800063d6:	10048993          	addi	s3,s1,256
    800063da:	6088                	ld	a0,0(s1)
    800063dc:	c901                	beqz	a0,800063ec <sys_exec+0xf4>
    800063de:	ffffa097          	auipc	ra,0xffffa
    800063e2:	6f0080e7          	jalr	1776(ra) # 80000ace <kfree>
    800063e6:	04a1                	addi	s1,s1,8
    800063e8:	ff3499e3          	bne	s1,s3,800063da <sys_exec+0xe2>
    800063ec:	854a                	mv	a0,s2
    800063ee:	a011                	j	800063f2 <sys_exec+0xfa>
    800063f0:	557d                	li	a0,-1
    800063f2:	60be                	ld	ra,456(sp)
    800063f4:	641e                	ld	s0,448(sp)
    800063f6:	74fa                	ld	s1,440(sp)
    800063f8:	795a                	ld	s2,432(sp)
    800063fa:	79ba                	ld	s3,424(sp)
    800063fc:	7a1a                	ld	s4,416(sp)
    800063fe:	6afa                	ld	s5,408(sp)
    80006400:	6179                	addi	sp,sp,464
    80006402:	8082                	ret

0000000080006404 <sys_pipe>:
    80006404:	7139                	addi	sp,sp,-64
    80006406:	fc06                	sd	ra,56(sp)
    80006408:	f822                	sd	s0,48(sp)
    8000640a:	f426                	sd	s1,40(sp)
    8000640c:	0080                	addi	s0,sp,64
    8000640e:	ffffc097          	auipc	ra,0xffffc
    80006412:	8aa080e7          	jalr	-1878(ra) # 80001cb8 <myproc>
    80006416:	84aa                	mv	s1,a0
    80006418:	fd840593          	addi	a1,s0,-40
    8000641c:	4501                	li	a0,0
    8000641e:	ffffd097          	auipc	ra,0xffffd
    80006422:	dba080e7          	jalr	-582(ra) # 800031d8 <argaddr>
    80006426:	fc840593          	addi	a1,s0,-56
    8000642a:	fd040513          	addi	a0,s0,-48
    8000642e:	fffff097          	auipc	ra,0xfffff
    80006432:	dd6080e7          	jalr	-554(ra) # 80005204 <pipealloc>
    80006436:	57fd                	li	a5,-1
    80006438:	0c054463          	bltz	a0,80006500 <sys_pipe+0xfc>
    8000643c:	fcf42223          	sw	a5,-60(s0)
    80006440:	fd043503          	ld	a0,-48(s0)
    80006444:	fffff097          	auipc	ra,0xfffff
    80006448:	518080e7          	jalr	1304(ra) # 8000595c <fdalloc>
    8000644c:	fca42223          	sw	a0,-60(s0)
    80006450:	08054b63          	bltz	a0,800064e6 <sys_pipe+0xe2>
    80006454:	fc843503          	ld	a0,-56(s0)
    80006458:	fffff097          	auipc	ra,0xfffff
    8000645c:	504080e7          	jalr	1284(ra) # 8000595c <fdalloc>
    80006460:	fca42023          	sw	a0,-64(s0)
    80006464:	06054863          	bltz	a0,800064d4 <sys_pipe+0xd0>
    80006468:	4691                	li	a3,4
    8000646a:	fc440613          	addi	a2,s0,-60
    8000646e:	fd843583          	ld	a1,-40(s0)
    80006472:	6ca8                	ld	a0,88(s1)
    80006474:	ffffb097          	auipc	ra,0xffffb
    80006478:	3c4080e7          	jalr	964(ra) # 80001838 <copyout>
    8000647c:	02054063          	bltz	a0,8000649c <sys_pipe+0x98>
    80006480:	4691                	li	a3,4
    80006482:	fc040613          	addi	a2,s0,-64
    80006486:	fd843583          	ld	a1,-40(s0)
    8000648a:	0591                	addi	a1,a1,4
    8000648c:	6ca8                	ld	a0,88(s1)
    8000648e:	ffffb097          	auipc	ra,0xffffb
    80006492:	3aa080e7          	jalr	938(ra) # 80001838 <copyout>
    80006496:	4781                	li	a5,0
    80006498:	06055463          	bgez	a0,80006500 <sys_pipe+0xfc>
    8000649c:	fc442783          	lw	a5,-60(s0)
    800064a0:	07e9                	addi	a5,a5,26
    800064a2:	078e                	slli	a5,a5,0x3
    800064a4:	97a6                	add	a5,a5,s1
    800064a6:	0007b423          	sd	zero,8(a5)
    800064aa:	fc042503          	lw	a0,-64(s0)
    800064ae:	0569                	addi	a0,a0,26
    800064b0:	050e                	slli	a0,a0,0x3
    800064b2:	94aa                	add	s1,s1,a0
    800064b4:	0004b423          	sd	zero,8(s1)
    800064b8:	fd043503          	ld	a0,-48(s0)
    800064bc:	fffff097          	auipc	ra,0xfffff
    800064c0:	a18080e7          	jalr	-1512(ra) # 80004ed4 <fileclose>
    800064c4:	fc843503          	ld	a0,-56(s0)
    800064c8:	fffff097          	auipc	ra,0xfffff
    800064cc:	a0c080e7          	jalr	-1524(ra) # 80004ed4 <fileclose>
    800064d0:	57fd                	li	a5,-1
    800064d2:	a03d                	j	80006500 <sys_pipe+0xfc>
    800064d4:	fc442783          	lw	a5,-60(s0)
    800064d8:	0007c763          	bltz	a5,800064e6 <sys_pipe+0xe2>
    800064dc:	07e9                	addi	a5,a5,26
    800064de:	078e                	slli	a5,a5,0x3
    800064e0:	94be                	add	s1,s1,a5
    800064e2:	0004b423          	sd	zero,8(s1)
    800064e6:	fd043503          	ld	a0,-48(s0)
    800064ea:	fffff097          	auipc	ra,0xfffff
    800064ee:	9ea080e7          	jalr	-1558(ra) # 80004ed4 <fileclose>
    800064f2:	fc843503          	ld	a0,-56(s0)
    800064f6:	fffff097          	auipc	ra,0xfffff
    800064fa:	9de080e7          	jalr	-1570(ra) # 80004ed4 <fileclose>
    800064fe:	57fd                	li	a5,-1
    80006500:	853e                	mv	a0,a5
    80006502:	70e2                	ld	ra,56(sp)
    80006504:	7442                	ld	s0,48(sp)
    80006506:	74a2                	ld	s1,40(sp)
    80006508:	6121                	addi	sp,sp,64
    8000650a:	8082                	ret
    8000650c:	0000                	unimp
	...

0000000080006510 <kernelvec>:
    80006510:	7111                	addi	sp,sp,-256
    80006512:	e006                	sd	ra,0(sp)
    80006514:	e40a                	sd	sp,8(sp)
    80006516:	e80e                	sd	gp,16(sp)
    80006518:	ec12                	sd	tp,24(sp)
    8000651a:	f016                	sd	t0,32(sp)
    8000651c:	f41a                	sd	t1,40(sp)
    8000651e:	f81e                	sd	t2,48(sp)
    80006520:	fc22                	sd	s0,56(sp)
    80006522:	e0a6                	sd	s1,64(sp)
    80006524:	e4aa                	sd	a0,72(sp)
    80006526:	e8ae                	sd	a1,80(sp)
    80006528:	ecb2                	sd	a2,88(sp)
    8000652a:	f0b6                	sd	a3,96(sp)
    8000652c:	f4ba                	sd	a4,104(sp)
    8000652e:	f8be                	sd	a5,112(sp)
    80006530:	fcc2                	sd	a6,120(sp)
    80006532:	e146                	sd	a7,128(sp)
    80006534:	e54a                	sd	s2,136(sp)
    80006536:	e94e                	sd	s3,144(sp)
    80006538:	ed52                	sd	s4,152(sp)
    8000653a:	f156                	sd	s5,160(sp)
    8000653c:	f55a                	sd	s6,168(sp)
    8000653e:	f95e                	sd	s7,176(sp)
    80006540:	fd62                	sd	s8,184(sp)
    80006542:	e1e6                	sd	s9,192(sp)
    80006544:	e5ea                	sd	s10,200(sp)
    80006546:	e9ee                	sd	s11,208(sp)
    80006548:	edf2                	sd	t3,216(sp)
    8000654a:	f1f6                	sd	t4,224(sp)
    8000654c:	f5fa                	sd	t5,232(sp)
    8000654e:	f9fe                	sd	t6,240(sp)
    80006550:	a97fc0ef          	jal	ra,80002fe6 <kerneltrap>
    80006554:	6082                	ld	ra,0(sp)
    80006556:	6122                	ld	sp,8(sp)
    80006558:	61c2                	ld	gp,16(sp)
    8000655a:	7282                	ld	t0,32(sp)
    8000655c:	7322                	ld	t1,40(sp)
    8000655e:	73c2                	ld	t2,48(sp)
    80006560:	7462                	ld	s0,56(sp)
    80006562:	6486                	ld	s1,64(sp)
    80006564:	6526                	ld	a0,72(sp)
    80006566:	65c6                	ld	a1,80(sp)
    80006568:	6666                	ld	a2,88(sp)
    8000656a:	7686                	ld	a3,96(sp)
    8000656c:	7726                	ld	a4,104(sp)
    8000656e:	77c6                	ld	a5,112(sp)
    80006570:	7866                	ld	a6,120(sp)
    80006572:	688a                	ld	a7,128(sp)
    80006574:	692a                	ld	s2,136(sp)
    80006576:	69ca                	ld	s3,144(sp)
    80006578:	6a6a                	ld	s4,152(sp)
    8000657a:	7a8a                	ld	s5,160(sp)
    8000657c:	7b2a                	ld	s6,168(sp)
    8000657e:	7bca                	ld	s7,176(sp)
    80006580:	7c6a                	ld	s8,184(sp)
    80006582:	6c8e                	ld	s9,192(sp)
    80006584:	6d2e                	ld	s10,200(sp)
    80006586:	6dce                	ld	s11,208(sp)
    80006588:	6e6e                	ld	t3,216(sp)
    8000658a:	7e8e                	ld	t4,224(sp)
    8000658c:	7f2e                	ld	t5,232(sp)
    8000658e:	7fce                	ld	t6,240(sp)
    80006590:	6111                	addi	sp,sp,256
    80006592:	10200073          	sret
    80006596:	00000013          	nop
    8000659a:	00000013          	nop
    8000659e:	0001                	nop

00000000800065a0 <timervec>:
    800065a0:	34051573          	csrrw	a0,mscratch,a0
    800065a4:	e10c                	sd	a1,0(a0)
    800065a6:	e510                	sd	a2,8(a0)
    800065a8:	e914                	sd	a3,16(a0)
    800065aa:	6d0c                	ld	a1,24(a0)
    800065ac:	7110                	ld	a2,32(a0)
    800065ae:	6194                	ld	a3,0(a1)
    800065b0:	96b2                	add	a3,a3,a2
    800065b2:	e194                	sd	a3,0(a1)
    800065b4:	4589                	li	a1,2
    800065b6:	14459073          	csrw	sip,a1
    800065ba:	6914                	ld	a3,16(a0)
    800065bc:	6510                	ld	a2,8(a0)
    800065be:	610c                	ld	a1,0(a0)
    800065c0:	34051573          	csrrw	a0,mscratch,a0
    800065c4:	30200073          	mret
	...

00000000800065ca <plicinit>:
    800065ca:	1141                	addi	sp,sp,-16
    800065cc:	e422                	sd	s0,8(sp)
    800065ce:	0800                	addi	s0,sp,16
    800065d0:	0c0007b7          	lui	a5,0xc000
    800065d4:	4705                	li	a4,1
    800065d6:	d798                	sw	a4,40(a5)
    800065d8:	c3d8                	sw	a4,4(a5)
    800065da:	6422                	ld	s0,8(sp)
    800065dc:	0141                	addi	sp,sp,16
    800065de:	8082                	ret

00000000800065e0 <plicinithart>:
    800065e0:	1141                	addi	sp,sp,-16
    800065e2:	e406                	sd	ra,8(sp)
    800065e4:	e022                	sd	s0,0(sp)
    800065e6:	0800                	addi	s0,sp,16
    800065e8:	ffffb097          	auipc	ra,0xffffb
    800065ec:	6a4080e7          	jalr	1700(ra) # 80001c8c <cpuid>
    800065f0:	0085171b          	slliw	a4,a0,0x8
    800065f4:	0c0027b7          	lui	a5,0xc002
    800065f8:	97ba                	add	a5,a5,a4
    800065fa:	40200713          	li	a4,1026
    800065fe:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>
    80006602:	00d5151b          	slliw	a0,a0,0xd
    80006606:	0c2017b7          	lui	a5,0xc201
    8000660a:	953e                	add	a0,a0,a5
    8000660c:	00052023          	sw	zero,0(a0)
    80006610:	60a2                	ld	ra,8(sp)
    80006612:	6402                	ld	s0,0(sp)
    80006614:	0141                	addi	sp,sp,16
    80006616:	8082                	ret

0000000080006618 <plic_claim>:
    80006618:	1141                	addi	sp,sp,-16
    8000661a:	e406                	sd	ra,8(sp)
    8000661c:	e022                	sd	s0,0(sp)
    8000661e:	0800                	addi	s0,sp,16
    80006620:	ffffb097          	auipc	ra,0xffffb
    80006624:	66c080e7          	jalr	1644(ra) # 80001c8c <cpuid>
    80006628:	00d5179b          	slliw	a5,a0,0xd
    8000662c:	0c201537          	lui	a0,0xc201
    80006630:	953e                	add	a0,a0,a5
    80006632:	4148                	lw	a0,4(a0)
    80006634:	60a2                	ld	ra,8(sp)
    80006636:	6402                	ld	s0,0(sp)
    80006638:	0141                	addi	sp,sp,16
    8000663a:	8082                	ret

000000008000663c <plic_complete>:
    8000663c:	1101                	addi	sp,sp,-32
    8000663e:	ec06                	sd	ra,24(sp)
    80006640:	e822                	sd	s0,16(sp)
    80006642:	e426                	sd	s1,8(sp)
    80006644:	1000                	addi	s0,sp,32
    80006646:	84aa                	mv	s1,a0
    80006648:	ffffb097          	auipc	ra,0xffffb
    8000664c:	644080e7          	jalr	1604(ra) # 80001c8c <cpuid>
    80006650:	00d5151b          	slliw	a0,a0,0xd
    80006654:	0c2017b7          	lui	a5,0xc201
    80006658:	97aa                	add	a5,a5,a0
    8000665a:	c3c4                	sw	s1,4(a5)
    8000665c:	60e2                	ld	ra,24(sp)
    8000665e:	6442                	ld	s0,16(sp)
    80006660:	64a2                	ld	s1,8(sp)
    80006662:	6105                	addi	sp,sp,32
    80006664:	8082                	ret

0000000080006666 <free_desc>:
    80006666:	1141                	addi	sp,sp,-16
    80006668:	e406                	sd	ra,8(sp)
    8000666a:	e022                	sd	s0,0(sp)
    8000666c:	0800                	addi	s0,sp,16
    8000666e:	479d                	li	a5,7
    80006670:	04a7cc63          	blt	a5,a0,800066c8 <free_desc+0x62>
    80006674:	0067e797          	auipc	a5,0x67e
    80006678:	b1478793          	addi	a5,a5,-1260 # 80684188 <disk>
    8000667c:	97aa                	add	a5,a5,a0
    8000667e:	0187c783          	lbu	a5,24(a5)
    80006682:	ebb9                	bnez	a5,800066d8 <free_desc+0x72>
    80006684:	00451613          	slli	a2,a0,0x4
    80006688:	0067e797          	auipc	a5,0x67e
    8000668c:	b0078793          	addi	a5,a5,-1280 # 80684188 <disk>
    80006690:	6394                	ld	a3,0(a5)
    80006692:	96b2                	add	a3,a3,a2
    80006694:	0006b023          	sd	zero,0(a3)
    80006698:	6398                	ld	a4,0(a5)
    8000669a:	9732                	add	a4,a4,a2
    8000669c:	00072423          	sw	zero,8(a4)
    800066a0:	00071623          	sh	zero,12(a4)
    800066a4:	00071723          	sh	zero,14(a4)
    800066a8:	953e                	add	a0,a0,a5
    800066aa:	4785                	li	a5,1
    800066ac:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
    800066b0:	0067e517          	auipc	a0,0x67e
    800066b4:	af050513          	addi	a0,a0,-1296 # 806841a0 <disk+0x18>
    800066b8:	ffffc097          	auipc	ra,0xffffc
    800066bc:	06e080e7          	jalr	110(ra) # 80002726 <wakeup>
    800066c0:	60a2                	ld	ra,8(sp)
    800066c2:	6402                	ld	s0,0(sp)
    800066c4:	0141                	addi	sp,sp,16
    800066c6:	8082                	ret
    800066c8:	00002517          	auipc	a0,0x2
    800066cc:	20850513          	addi	a0,a0,520 # 800088d0 <syscalls+0x318>
    800066d0:	ffffa097          	auipc	ra,0xffffa
    800066d4:	e74080e7          	jalr	-396(ra) # 80000544 <panic>
    800066d8:	00002517          	auipc	a0,0x2
    800066dc:	20850513          	addi	a0,a0,520 # 800088e0 <syscalls+0x328>
    800066e0:	ffffa097          	auipc	ra,0xffffa
    800066e4:	e64080e7          	jalr	-412(ra) # 80000544 <panic>

00000000800066e8 <virtio_disk_init>:
    800066e8:	1101                	addi	sp,sp,-32
    800066ea:	ec06                	sd	ra,24(sp)
    800066ec:	e822                	sd	s0,16(sp)
    800066ee:	e426                	sd	s1,8(sp)
    800066f0:	e04a                	sd	s2,0(sp)
    800066f2:	1000                	addi	s0,sp,32
    800066f4:	00002597          	auipc	a1,0x2
    800066f8:	1fc58593          	addi	a1,a1,508 # 800088f0 <syscalls+0x338>
    800066fc:	0067e517          	auipc	a0,0x67e
    80006700:	bb450513          	addi	a0,a0,-1100 # 806842b0 <disk+0x128>
    80006704:	ffffa097          	auipc	ra,0xffffa
    80006708:	614080e7          	jalr	1556(ra) # 80000d18 <initlock>
    8000670c:	100017b7          	lui	a5,0x10001
    80006710:	4398                	lw	a4,0(a5)
    80006712:	2701                	sext.w	a4,a4
    80006714:	747277b7          	lui	a5,0x74727
    80006718:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000671c:	14f71e63          	bne	a4,a5,80006878 <virtio_disk_init+0x190>
    80006720:	100017b7          	lui	a5,0x10001
    80006724:	43dc                	lw	a5,4(a5)
    80006726:	2781                	sext.w	a5,a5
    80006728:	4709                	li	a4,2
    8000672a:	14e79763          	bne	a5,a4,80006878 <virtio_disk_init+0x190>
    8000672e:	100017b7          	lui	a5,0x10001
    80006732:	479c                	lw	a5,8(a5)
    80006734:	2781                	sext.w	a5,a5
    80006736:	14e79163          	bne	a5,a4,80006878 <virtio_disk_init+0x190>
    8000673a:	100017b7          	lui	a5,0x10001
    8000673e:	47d8                	lw	a4,12(a5)
    80006740:	2701                	sext.w	a4,a4
    80006742:	554d47b7          	lui	a5,0x554d4
    80006746:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000674a:	12f71763          	bne	a4,a5,80006878 <virtio_disk_init+0x190>
    8000674e:	100017b7          	lui	a5,0x10001
    80006752:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
    80006756:	4705                	li	a4,1
    80006758:	dbb8                	sw	a4,112(a5)
    8000675a:	470d                	li	a4,3
    8000675c:	dbb8                	sw	a4,112(a5)
    8000675e:	4b94                	lw	a3,16(a5)
    80006760:	c7ffe737          	lui	a4,0xc7ffe
    80006764:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff4797a497>
    80006768:	8f75                	and	a4,a4,a3
    8000676a:	2701                	sext.w	a4,a4
    8000676c:	d398                	sw	a4,32(a5)
    8000676e:	472d                	li	a4,11
    80006770:	dbb8                	sw	a4,112(a5)
    80006772:	0707a903          	lw	s2,112(a5)
    80006776:	2901                	sext.w	s2,s2
    80006778:	00897793          	andi	a5,s2,8
    8000677c:	10078663          	beqz	a5,80006888 <virtio_disk_init+0x1a0>
    80006780:	100017b7          	lui	a5,0x10001
    80006784:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
    80006788:	43fc                	lw	a5,68(a5)
    8000678a:	2781                	sext.w	a5,a5
    8000678c:	10079663          	bnez	a5,80006898 <virtio_disk_init+0x1b0>
    80006790:	100017b7          	lui	a5,0x10001
    80006794:	5bdc                	lw	a5,52(a5)
    80006796:	2781                	sext.w	a5,a5
    80006798:	10078863          	beqz	a5,800068a8 <virtio_disk_init+0x1c0>
    8000679c:	471d                	li	a4,7
    8000679e:	10f77d63          	bgeu	a4,a5,800068b8 <virtio_disk_init+0x1d0>
    800067a2:	ffffa097          	auipc	ra,0xffffa
    800067a6:	4d2080e7          	jalr	1234(ra) # 80000c74 <kalloc>
    800067aa:	0067e497          	auipc	s1,0x67e
    800067ae:	9de48493          	addi	s1,s1,-1570 # 80684188 <disk>
    800067b2:	e088                	sd	a0,0(s1)
    800067b4:	ffffa097          	auipc	ra,0xffffa
    800067b8:	4c0080e7          	jalr	1216(ra) # 80000c74 <kalloc>
    800067bc:	e488                	sd	a0,8(s1)
    800067be:	ffffa097          	auipc	ra,0xffffa
    800067c2:	4b6080e7          	jalr	1206(ra) # 80000c74 <kalloc>
    800067c6:	87aa                	mv	a5,a0
    800067c8:	e888                	sd	a0,16(s1)
    800067ca:	6088                	ld	a0,0(s1)
    800067cc:	cd75                	beqz	a0,800068c8 <virtio_disk_init+0x1e0>
    800067ce:	0067e717          	auipc	a4,0x67e
    800067d2:	9c273703          	ld	a4,-1598(a4) # 80684190 <disk+0x8>
    800067d6:	cb6d                	beqz	a4,800068c8 <virtio_disk_init+0x1e0>
    800067d8:	cbe5                	beqz	a5,800068c8 <virtio_disk_init+0x1e0>
    800067da:	6605                	lui	a2,0x1
    800067dc:	4581                	li	a1,0
    800067de:	ffffa097          	auipc	ra,0xffffa
    800067e2:	6c6080e7          	jalr	1734(ra) # 80000ea4 <memset>
    800067e6:	0067e497          	auipc	s1,0x67e
    800067ea:	9a248493          	addi	s1,s1,-1630 # 80684188 <disk>
    800067ee:	6605                	lui	a2,0x1
    800067f0:	4581                	li	a1,0
    800067f2:	6488                	ld	a0,8(s1)
    800067f4:	ffffa097          	auipc	ra,0xffffa
    800067f8:	6b0080e7          	jalr	1712(ra) # 80000ea4 <memset>
    800067fc:	6605                	lui	a2,0x1
    800067fe:	4581                	li	a1,0
    80006800:	6888                	ld	a0,16(s1)
    80006802:	ffffa097          	auipc	ra,0xffffa
    80006806:	6a2080e7          	jalr	1698(ra) # 80000ea4 <memset>
    8000680a:	100017b7          	lui	a5,0x10001
    8000680e:	4721                	li	a4,8
    80006810:	df98                	sw	a4,56(a5)
    80006812:	4098                	lw	a4,0(s1)
    80006814:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
    80006818:	40d8                	lw	a4,4(s1)
    8000681a:	08e7a223          	sw	a4,132(a5)
    8000681e:	6498                	ld	a4,8(s1)
    80006820:	0007069b          	sext.w	a3,a4
    80006824:	08d7a823          	sw	a3,144(a5)
    80006828:	9701                	srai	a4,a4,0x20
    8000682a:	08e7aa23          	sw	a4,148(a5)
    8000682e:	6898                	ld	a4,16(s1)
    80006830:	0007069b          	sext.w	a3,a4
    80006834:	0ad7a023          	sw	a3,160(a5)
    80006838:	9701                	srai	a4,a4,0x20
    8000683a:	0ae7a223          	sw	a4,164(a5)
    8000683e:	4685                	li	a3,1
    80006840:	c3f4                	sw	a3,68(a5)
    80006842:	4705                	li	a4,1
    80006844:	00d48c23          	sb	a3,24(s1)
    80006848:	00e48ca3          	sb	a4,25(s1)
    8000684c:	00e48d23          	sb	a4,26(s1)
    80006850:	00e48da3          	sb	a4,27(s1)
    80006854:	00e48e23          	sb	a4,28(s1)
    80006858:	00e48ea3          	sb	a4,29(s1)
    8000685c:	00e48f23          	sb	a4,30(s1)
    80006860:	00e48fa3          	sb	a4,31(s1)
    80006864:	00496913          	ori	s2,s2,4
    80006868:	0727a823          	sw	s2,112(a5)
    8000686c:	60e2                	ld	ra,24(sp)
    8000686e:	6442                	ld	s0,16(sp)
    80006870:	64a2                	ld	s1,8(sp)
    80006872:	6902                	ld	s2,0(sp)
    80006874:	6105                	addi	sp,sp,32
    80006876:	8082                	ret
    80006878:	00002517          	auipc	a0,0x2
    8000687c:	08850513          	addi	a0,a0,136 # 80008900 <syscalls+0x348>
    80006880:	ffffa097          	auipc	ra,0xffffa
    80006884:	cc4080e7          	jalr	-828(ra) # 80000544 <panic>
    80006888:	00002517          	auipc	a0,0x2
    8000688c:	09850513          	addi	a0,a0,152 # 80008920 <syscalls+0x368>
    80006890:	ffffa097          	auipc	ra,0xffffa
    80006894:	cb4080e7          	jalr	-844(ra) # 80000544 <panic>
    80006898:	00002517          	auipc	a0,0x2
    8000689c:	0a850513          	addi	a0,a0,168 # 80008940 <syscalls+0x388>
    800068a0:	ffffa097          	auipc	ra,0xffffa
    800068a4:	ca4080e7          	jalr	-860(ra) # 80000544 <panic>
    800068a8:	00002517          	auipc	a0,0x2
    800068ac:	0b850513          	addi	a0,a0,184 # 80008960 <syscalls+0x3a8>
    800068b0:	ffffa097          	auipc	ra,0xffffa
    800068b4:	c94080e7          	jalr	-876(ra) # 80000544 <panic>
    800068b8:	00002517          	auipc	a0,0x2
    800068bc:	0c850513          	addi	a0,a0,200 # 80008980 <syscalls+0x3c8>
    800068c0:	ffffa097          	auipc	ra,0xffffa
    800068c4:	c84080e7          	jalr	-892(ra) # 80000544 <panic>
    800068c8:	00002517          	auipc	a0,0x2
    800068cc:	0d850513          	addi	a0,a0,216 # 800089a0 <syscalls+0x3e8>
    800068d0:	ffffa097          	auipc	ra,0xffffa
    800068d4:	c74080e7          	jalr	-908(ra) # 80000544 <panic>

00000000800068d8 <virtio_disk_rw>:
    800068d8:	7159                	addi	sp,sp,-112
    800068da:	f486                	sd	ra,104(sp)
    800068dc:	f0a2                	sd	s0,96(sp)
    800068de:	eca6                	sd	s1,88(sp)
    800068e0:	e8ca                	sd	s2,80(sp)
    800068e2:	e4ce                	sd	s3,72(sp)
    800068e4:	e0d2                	sd	s4,64(sp)
    800068e6:	fc56                	sd	s5,56(sp)
    800068e8:	f85a                	sd	s6,48(sp)
    800068ea:	f45e                	sd	s7,40(sp)
    800068ec:	f062                	sd	s8,32(sp)
    800068ee:	ec66                	sd	s9,24(sp)
    800068f0:	e86a                	sd	s10,16(sp)
    800068f2:	1880                	addi	s0,sp,112
    800068f4:	892a                	mv	s2,a0
    800068f6:	8d2e                	mv	s10,a1
    800068f8:	00c52c83          	lw	s9,12(a0)
    800068fc:	001c9c9b          	slliw	s9,s9,0x1
    80006900:	1c82                	slli	s9,s9,0x20
    80006902:	020cdc93          	srli	s9,s9,0x20
    80006906:	0067e517          	auipc	a0,0x67e
    8000690a:	9aa50513          	addi	a0,a0,-1622 # 806842b0 <disk+0x128>
    8000690e:	ffffa097          	auipc	ra,0xffffa
    80006912:	49a080e7          	jalr	1178(ra) # 80000da8 <acquire>
    80006916:	4981                	li	s3,0
    80006918:	4ba1                	li	s7,8
    8000691a:	0067eb17          	auipc	s6,0x67e
    8000691e:	86eb0b13          	addi	s6,s6,-1938 # 80684188 <disk>
    80006922:	4a8d                	li	s5,3
    80006924:	8a4e                	mv	s4,s3
    80006926:	0067ec17          	auipc	s8,0x67e
    8000692a:	98ac0c13          	addi	s8,s8,-1654 # 806842b0 <disk+0x128>
    8000692e:	a8b5                	j	800069aa <virtio_disk_rw+0xd2>
    80006930:	00fb06b3          	add	a3,s6,a5
    80006934:	00068c23          	sb	zero,24(a3)
    80006938:	c21c                	sw	a5,0(a2)
    8000693a:	0207c563          	bltz	a5,80006964 <virtio_disk_rw+0x8c>
    8000693e:	2485                	addiw	s1,s1,1
    80006940:	0711                	addi	a4,a4,4
    80006942:	1f548a63          	beq	s1,s5,80006b36 <virtio_disk_rw+0x25e>
    80006946:	863a                	mv	a2,a4
    80006948:	0067e697          	auipc	a3,0x67e
    8000694c:	84068693          	addi	a3,a3,-1984 # 80684188 <disk>
    80006950:	87d2                	mv	a5,s4
    80006952:	0186c583          	lbu	a1,24(a3)
    80006956:	fde9                	bnez	a1,80006930 <virtio_disk_rw+0x58>
    80006958:	2785                	addiw	a5,a5,1
    8000695a:	0685                	addi	a3,a3,1
    8000695c:	ff779be3          	bne	a5,s7,80006952 <virtio_disk_rw+0x7a>
    80006960:	57fd                	li	a5,-1
    80006962:	c21c                	sw	a5,0(a2)
    80006964:	02905a63          	blez	s1,80006998 <virtio_disk_rw+0xc0>
    80006968:	f9042503          	lw	a0,-112(s0)
    8000696c:	00000097          	auipc	ra,0x0
    80006970:	cfa080e7          	jalr	-774(ra) # 80006666 <free_desc>
    80006974:	4785                	li	a5,1
    80006976:	0297d163          	bge	a5,s1,80006998 <virtio_disk_rw+0xc0>
    8000697a:	f9442503          	lw	a0,-108(s0)
    8000697e:	00000097          	auipc	ra,0x0
    80006982:	ce8080e7          	jalr	-792(ra) # 80006666 <free_desc>
    80006986:	4789                	li	a5,2
    80006988:	0097d863          	bge	a5,s1,80006998 <virtio_disk_rw+0xc0>
    8000698c:	f9842503          	lw	a0,-104(s0)
    80006990:	00000097          	auipc	ra,0x0
    80006994:	cd6080e7          	jalr	-810(ra) # 80006666 <free_desc>
    80006998:	85e2                	mv	a1,s8
    8000699a:	0067e517          	auipc	a0,0x67e
    8000699e:	80650513          	addi	a0,a0,-2042 # 806841a0 <disk+0x18>
    800069a2:	ffffc097          	auipc	ra,0xffffc
    800069a6:	a86080e7          	jalr	-1402(ra) # 80002428 <sleep>
    800069aa:	f9040713          	addi	a4,s0,-112
    800069ae:	84ce                	mv	s1,s3
    800069b0:	bf59                	j	80006946 <virtio_disk_rw+0x6e>
    800069b2:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    800069b6:	00479693          	slli	a3,a5,0x4
    800069ba:	0067d797          	auipc	a5,0x67d
    800069be:	7ce78793          	addi	a5,a5,1998 # 80684188 <disk>
    800069c2:	97b6                	add	a5,a5,a3
    800069c4:	4685                	li	a3,1
    800069c6:	c794                	sw	a3,8(a5)
    800069c8:	0067d597          	auipc	a1,0x67d
    800069cc:	7c058593          	addi	a1,a1,1984 # 80684188 <disk>
    800069d0:	00a60793          	addi	a5,a2,10
    800069d4:	0792                	slli	a5,a5,0x4
    800069d6:	97ae                	add	a5,a5,a1
    800069d8:	0007a623          	sw	zero,12(a5)
    800069dc:	0197b823          	sd	s9,16(a5)
    800069e0:	f6070693          	addi	a3,a4,-160
    800069e4:	619c                	ld	a5,0(a1)
    800069e6:	97b6                	add	a5,a5,a3
    800069e8:	e388                	sd	a0,0(a5)
    800069ea:	6188                	ld	a0,0(a1)
    800069ec:	96aa                	add	a3,a3,a0
    800069ee:	47c1                	li	a5,16
    800069f0:	c69c                	sw	a5,8(a3)
    800069f2:	4785                	li	a5,1
    800069f4:	00f69623          	sh	a5,12(a3)
    800069f8:	f9442783          	lw	a5,-108(s0)
    800069fc:	00f69723          	sh	a5,14(a3)
    80006a00:	0792                	slli	a5,a5,0x4
    80006a02:	953e                	add	a0,a0,a5
    80006a04:	05890693          	addi	a3,s2,88
    80006a08:	e114                	sd	a3,0(a0)
    80006a0a:	6188                	ld	a0,0(a1)
    80006a0c:	97aa                	add	a5,a5,a0
    80006a0e:	40000693          	li	a3,1024
    80006a12:	c794                	sw	a3,8(a5)
    80006a14:	100d0d63          	beqz	s10,80006b2e <virtio_disk_rw+0x256>
    80006a18:	00079623          	sh	zero,12(a5)
    80006a1c:	00c7d683          	lhu	a3,12(a5)
    80006a20:	0016e693          	ori	a3,a3,1
    80006a24:	00d79623          	sh	a3,12(a5)
    80006a28:	f9842583          	lw	a1,-104(s0)
    80006a2c:	00b79723          	sh	a1,14(a5)
    80006a30:	0067d697          	auipc	a3,0x67d
    80006a34:	75868693          	addi	a3,a3,1880 # 80684188 <disk>
    80006a38:	00260793          	addi	a5,a2,2
    80006a3c:	0792                	slli	a5,a5,0x4
    80006a3e:	97b6                	add	a5,a5,a3
    80006a40:	587d                	li	a6,-1
    80006a42:	01078823          	sb	a6,16(a5)
    80006a46:	0592                	slli	a1,a1,0x4
    80006a48:	952e                	add	a0,a0,a1
    80006a4a:	f9070713          	addi	a4,a4,-112
    80006a4e:	9736                	add	a4,a4,a3
    80006a50:	e118                	sd	a4,0(a0)
    80006a52:	6298                	ld	a4,0(a3)
    80006a54:	972e                	add	a4,a4,a1
    80006a56:	4585                	li	a1,1
    80006a58:	c70c                	sw	a1,8(a4)
    80006a5a:	4509                	li	a0,2
    80006a5c:	00a71623          	sh	a0,12(a4)
    80006a60:	00071723          	sh	zero,14(a4)
    80006a64:	00b92223          	sw	a1,4(s2)
    80006a68:	0127b423          	sd	s2,8(a5)
    80006a6c:	6698                	ld	a4,8(a3)
    80006a6e:	00275783          	lhu	a5,2(a4)
    80006a72:	8b9d                	andi	a5,a5,7
    80006a74:	0786                	slli	a5,a5,0x1
    80006a76:	97ba                	add	a5,a5,a4
    80006a78:	00c79223          	sh	a2,4(a5)
    80006a7c:	0ff0000f          	fence
    80006a80:	6698                	ld	a4,8(a3)
    80006a82:	00275783          	lhu	a5,2(a4)
    80006a86:	2785                	addiw	a5,a5,1
    80006a88:	00f71123          	sh	a5,2(a4)
    80006a8c:	0ff0000f          	fence
    80006a90:	100017b7          	lui	a5,0x10001
    80006a94:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>
    80006a98:	00492703          	lw	a4,4(s2)
    80006a9c:	4785                	li	a5,1
    80006a9e:	02f71163          	bne	a4,a5,80006ac0 <virtio_disk_rw+0x1e8>
    80006aa2:	0067e997          	auipc	s3,0x67e
    80006aa6:	80e98993          	addi	s3,s3,-2034 # 806842b0 <disk+0x128>
    80006aaa:	4485                	li	s1,1
    80006aac:	85ce                	mv	a1,s3
    80006aae:	854a                	mv	a0,s2
    80006ab0:	ffffc097          	auipc	ra,0xffffc
    80006ab4:	978080e7          	jalr	-1672(ra) # 80002428 <sleep>
    80006ab8:	00492783          	lw	a5,4(s2)
    80006abc:	fe9788e3          	beq	a5,s1,80006aac <virtio_disk_rw+0x1d4>
    80006ac0:	f9042903          	lw	s2,-112(s0)
    80006ac4:	00290793          	addi	a5,s2,2
    80006ac8:	00479713          	slli	a4,a5,0x4
    80006acc:	0067d797          	auipc	a5,0x67d
    80006ad0:	6bc78793          	addi	a5,a5,1724 # 80684188 <disk>
    80006ad4:	97ba                	add	a5,a5,a4
    80006ad6:	0007b423          	sd	zero,8(a5)
    80006ada:	0067d997          	auipc	s3,0x67d
    80006ade:	6ae98993          	addi	s3,s3,1710 # 80684188 <disk>
    80006ae2:	00491713          	slli	a4,s2,0x4
    80006ae6:	0009b783          	ld	a5,0(s3)
    80006aea:	97ba                	add	a5,a5,a4
    80006aec:	00c7d483          	lhu	s1,12(a5)
    80006af0:	854a                	mv	a0,s2
    80006af2:	00e7d903          	lhu	s2,14(a5)
    80006af6:	00000097          	auipc	ra,0x0
    80006afa:	b70080e7          	jalr	-1168(ra) # 80006666 <free_desc>
    80006afe:	8885                	andi	s1,s1,1
    80006b00:	f0ed                	bnez	s1,80006ae2 <virtio_disk_rw+0x20a>
    80006b02:	0067d517          	auipc	a0,0x67d
    80006b06:	7ae50513          	addi	a0,a0,1966 # 806842b0 <disk+0x128>
    80006b0a:	ffffa097          	auipc	ra,0xffffa
    80006b0e:	352080e7          	jalr	850(ra) # 80000e5c <release>
    80006b12:	70a6                	ld	ra,104(sp)
    80006b14:	7406                	ld	s0,96(sp)
    80006b16:	64e6                	ld	s1,88(sp)
    80006b18:	6946                	ld	s2,80(sp)
    80006b1a:	69a6                	ld	s3,72(sp)
    80006b1c:	6a06                	ld	s4,64(sp)
    80006b1e:	7ae2                	ld	s5,56(sp)
    80006b20:	7b42                	ld	s6,48(sp)
    80006b22:	7ba2                	ld	s7,40(sp)
    80006b24:	7c02                	ld	s8,32(sp)
    80006b26:	6ce2                	ld	s9,24(sp)
    80006b28:	6d42                	ld	s10,16(sp)
    80006b2a:	6165                	addi	sp,sp,112
    80006b2c:	8082                	ret
    80006b2e:	4689                	li	a3,2
    80006b30:	00d79623          	sh	a3,12(a5)
    80006b34:	b5e5                	j	80006a1c <virtio_disk_rw+0x144>
    80006b36:	f9042603          	lw	a2,-112(s0)
    80006b3a:	00a60713          	addi	a4,a2,10
    80006b3e:	0712                	slli	a4,a4,0x4
    80006b40:	0067d517          	auipc	a0,0x67d
    80006b44:	65050513          	addi	a0,a0,1616 # 80684190 <disk+0x8>
    80006b48:	953a                	add	a0,a0,a4
    80006b4a:	e60d14e3          	bnez	s10,800069b2 <virtio_disk_rw+0xda>
    80006b4e:	00a60793          	addi	a5,a2,10
    80006b52:	00479693          	slli	a3,a5,0x4
    80006b56:	0067d797          	auipc	a5,0x67d
    80006b5a:	63278793          	addi	a5,a5,1586 # 80684188 <disk>
    80006b5e:	97b6                	add	a5,a5,a3
    80006b60:	0007a423          	sw	zero,8(a5)
    80006b64:	b595                	j	800069c8 <virtio_disk_rw+0xf0>

0000000080006b66 <virtio_disk_intr>:
    80006b66:	1101                	addi	sp,sp,-32
    80006b68:	ec06                	sd	ra,24(sp)
    80006b6a:	e822                	sd	s0,16(sp)
    80006b6c:	e426                	sd	s1,8(sp)
    80006b6e:	1000                	addi	s0,sp,32
    80006b70:	0067d497          	auipc	s1,0x67d
    80006b74:	61848493          	addi	s1,s1,1560 # 80684188 <disk>
    80006b78:	0067d517          	auipc	a0,0x67d
    80006b7c:	73850513          	addi	a0,a0,1848 # 806842b0 <disk+0x128>
    80006b80:	ffffa097          	auipc	ra,0xffffa
    80006b84:	228080e7          	jalr	552(ra) # 80000da8 <acquire>
    80006b88:	10001737          	lui	a4,0x10001
    80006b8c:	533c                	lw	a5,96(a4)
    80006b8e:	8b8d                	andi	a5,a5,3
    80006b90:	d37c                	sw	a5,100(a4)
    80006b92:	0ff0000f          	fence
    80006b96:	689c                	ld	a5,16(s1)
    80006b98:	0204d703          	lhu	a4,32(s1)
    80006b9c:	0027d783          	lhu	a5,2(a5)
    80006ba0:	04f70863          	beq	a4,a5,80006bf0 <virtio_disk_intr+0x8a>
    80006ba4:	0ff0000f          	fence
    80006ba8:	6898                	ld	a4,16(s1)
    80006baa:	0204d783          	lhu	a5,32(s1)
    80006bae:	8b9d                	andi	a5,a5,7
    80006bb0:	078e                	slli	a5,a5,0x3
    80006bb2:	97ba                	add	a5,a5,a4
    80006bb4:	43dc                	lw	a5,4(a5)
    80006bb6:	00278713          	addi	a4,a5,2
    80006bba:	0712                	slli	a4,a4,0x4
    80006bbc:	9726                	add	a4,a4,s1
    80006bbe:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006bc2:	e721                	bnez	a4,80006c0a <virtio_disk_intr+0xa4>
    80006bc4:	0789                	addi	a5,a5,2
    80006bc6:	0792                	slli	a5,a5,0x4
    80006bc8:	97a6                	add	a5,a5,s1
    80006bca:	6788                	ld	a0,8(a5)
    80006bcc:	00052223          	sw	zero,4(a0)
    80006bd0:	ffffc097          	auipc	ra,0xffffc
    80006bd4:	b56080e7          	jalr	-1194(ra) # 80002726 <wakeup>
    80006bd8:	0204d783          	lhu	a5,32(s1)
    80006bdc:	2785                	addiw	a5,a5,1
    80006bde:	17c2                	slli	a5,a5,0x30
    80006be0:	93c1                	srli	a5,a5,0x30
    80006be2:	02f49023          	sh	a5,32(s1)
    80006be6:	6898                	ld	a4,16(s1)
    80006be8:	00275703          	lhu	a4,2(a4)
    80006bec:	faf71ce3          	bne	a4,a5,80006ba4 <virtio_disk_intr+0x3e>
    80006bf0:	0067d517          	auipc	a0,0x67d
    80006bf4:	6c050513          	addi	a0,a0,1728 # 806842b0 <disk+0x128>
    80006bf8:	ffffa097          	auipc	ra,0xffffa
    80006bfc:	264080e7          	jalr	612(ra) # 80000e5c <release>
    80006c00:	60e2                	ld	ra,24(sp)
    80006c02:	6442                	ld	s0,16(sp)
    80006c04:	64a2                	ld	s1,8(sp)
    80006c06:	6105                	addi	sp,sp,32
    80006c08:	8082                	ret
    80006c0a:	00002517          	auipc	a0,0x2
    80006c0e:	dae50513          	addi	a0,a0,-594 # 800089b8 <syscalls+0x400>
    80006c12:	ffffa097          	auipc	ra,0xffffa
    80006c16:	932080e7          	jalr	-1742(ra) # 80000544 <panic>
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
