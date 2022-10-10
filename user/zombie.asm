
user/_zombie:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
   8:	00000097          	auipc	ra,0x0
   c:	2aa080e7          	jalr	682(ra) # 2b2 <fork>
  10:	00a04763          	bgtz	a0,1e <main+0x1e>
  14:	4501                	li	a0,0
  16:	00000097          	auipc	ra,0x0
  1a:	2a4080e7          	jalr	676(ra) # 2ba <exit>
  1e:	4515                	li	a0,5
  20:	00000097          	auipc	ra,0x0
  24:	32a080e7          	jalr	810(ra) # 34a <sleep>
  28:	b7f5                	j	14 <main+0x14>

000000000000002a <_main>:
  2a:	1141                	addi	sp,sp,-16
  2c:	e406                	sd	ra,8(sp)
  2e:	e022                	sd	s0,0(sp)
  30:	0800                	addi	s0,sp,16
  32:	00000097          	auipc	ra,0x0
  36:	fce080e7          	jalr	-50(ra) # 0 <main>
  3a:	4501                	li	a0,0
  3c:	00000097          	auipc	ra,0x0
  40:	27e080e7          	jalr	638(ra) # 2ba <exit>

0000000000000044 <strcpy>:
  44:	1141                	addi	sp,sp,-16
  46:	e422                	sd	s0,8(sp)
  48:	0800                	addi	s0,sp,16
  4a:	87aa                	mv	a5,a0
  4c:	0585                	addi	a1,a1,1
  4e:	0785                	addi	a5,a5,1
  50:	fff5c703          	lbu	a4,-1(a1)
  54:	fee78fa3          	sb	a4,-1(a5)
  58:	fb75                	bnez	a4,4c <strcpy+0x8>
  5a:	6422                	ld	s0,8(sp)
  5c:	0141                	addi	sp,sp,16
  5e:	8082                	ret

0000000000000060 <strcmp>:
  60:	1141                	addi	sp,sp,-16
  62:	e422                	sd	s0,8(sp)
  64:	0800                	addi	s0,sp,16
  66:	00054783          	lbu	a5,0(a0)
  6a:	cb91                	beqz	a5,7e <strcmp+0x1e>
  6c:	0005c703          	lbu	a4,0(a1)
  70:	00f71763          	bne	a4,a5,7e <strcmp+0x1e>
  74:	0505                	addi	a0,a0,1
  76:	0585                	addi	a1,a1,1
  78:	00054783          	lbu	a5,0(a0)
  7c:	fbe5                	bnez	a5,6c <strcmp+0xc>
  7e:	0005c503          	lbu	a0,0(a1)
  82:	40a7853b          	subw	a0,a5,a0
  86:	6422                	ld	s0,8(sp)
  88:	0141                	addi	sp,sp,16
  8a:	8082                	ret

000000000000008c <strlen>:
  8c:	1141                	addi	sp,sp,-16
  8e:	e422                	sd	s0,8(sp)
  90:	0800                	addi	s0,sp,16
  92:	00054783          	lbu	a5,0(a0)
  96:	cf91                	beqz	a5,b2 <strlen+0x26>
  98:	0505                	addi	a0,a0,1
  9a:	87aa                	mv	a5,a0
  9c:	4685                	li	a3,1
  9e:	9e89                	subw	a3,a3,a0
  a0:	00f6853b          	addw	a0,a3,a5
  a4:	0785                	addi	a5,a5,1
  a6:	fff7c703          	lbu	a4,-1(a5)
  aa:	fb7d                	bnez	a4,a0 <strlen+0x14>
  ac:	6422                	ld	s0,8(sp)
  ae:	0141                	addi	sp,sp,16
  b0:	8082                	ret
  b2:	4501                	li	a0,0
  b4:	bfe5                	j	ac <strlen+0x20>

00000000000000b6 <memset>:
  b6:	1141                	addi	sp,sp,-16
  b8:	e422                	sd	s0,8(sp)
  ba:	0800                	addi	s0,sp,16
  bc:	ce09                	beqz	a2,d6 <memset+0x20>
  be:	87aa                	mv	a5,a0
  c0:	fff6071b          	addiw	a4,a2,-1
  c4:	1702                	slli	a4,a4,0x20
  c6:	9301                	srli	a4,a4,0x20
  c8:	0705                	addi	a4,a4,1
  ca:	972a                	add	a4,a4,a0
  cc:	00b78023          	sb	a1,0(a5)
  d0:	0785                	addi	a5,a5,1
  d2:	fee79de3          	bne	a5,a4,cc <memset+0x16>
  d6:	6422                	ld	s0,8(sp)
  d8:	0141                	addi	sp,sp,16
  da:	8082                	ret

00000000000000dc <strchr>:
  dc:	1141                	addi	sp,sp,-16
  de:	e422                	sd	s0,8(sp)
  e0:	0800                	addi	s0,sp,16
  e2:	00054783          	lbu	a5,0(a0)
  e6:	cb99                	beqz	a5,fc <strchr+0x20>
  e8:	00f58763          	beq	a1,a5,f6 <strchr+0x1a>
  ec:	0505                	addi	a0,a0,1
  ee:	00054783          	lbu	a5,0(a0)
  f2:	fbfd                	bnez	a5,e8 <strchr+0xc>
  f4:	4501                	li	a0,0
  f6:	6422                	ld	s0,8(sp)
  f8:	0141                	addi	sp,sp,16
  fa:	8082                	ret
  fc:	4501                	li	a0,0
  fe:	bfe5                	j	f6 <strchr+0x1a>

0000000000000100 <gets>:
 100:	711d                	addi	sp,sp,-96
 102:	ec86                	sd	ra,88(sp)
 104:	e8a2                	sd	s0,80(sp)
 106:	e4a6                	sd	s1,72(sp)
 108:	e0ca                	sd	s2,64(sp)
 10a:	fc4e                	sd	s3,56(sp)
 10c:	f852                	sd	s4,48(sp)
 10e:	f456                	sd	s5,40(sp)
 110:	f05a                	sd	s6,32(sp)
 112:	ec5e                	sd	s7,24(sp)
 114:	1080                	addi	s0,sp,96
 116:	8baa                	mv	s7,a0
 118:	8a2e                	mv	s4,a1
 11a:	892a                	mv	s2,a0
 11c:	4481                	li	s1,0
 11e:	4aa9                	li	s5,10
 120:	4b35                	li	s6,13
 122:	89a6                	mv	s3,s1
 124:	2485                	addiw	s1,s1,1
 126:	0344d863          	bge	s1,s4,156 <gets+0x56>
 12a:	4605                	li	a2,1
 12c:	faf40593          	addi	a1,s0,-81
 130:	4501                	li	a0,0
 132:	00000097          	auipc	ra,0x0
 136:	1a0080e7          	jalr	416(ra) # 2d2 <read>
 13a:	00a05e63          	blez	a0,156 <gets+0x56>
 13e:	faf44783          	lbu	a5,-81(s0)
 142:	00f90023          	sb	a5,0(s2)
 146:	01578763          	beq	a5,s5,154 <gets+0x54>
 14a:	0905                	addi	s2,s2,1
 14c:	fd679be3          	bne	a5,s6,122 <gets+0x22>
 150:	89a6                	mv	s3,s1
 152:	a011                	j	156 <gets+0x56>
 154:	89a6                	mv	s3,s1
 156:	99de                	add	s3,s3,s7
 158:	00098023          	sb	zero,0(s3)
 15c:	855e                	mv	a0,s7
 15e:	60e6                	ld	ra,88(sp)
 160:	6446                	ld	s0,80(sp)
 162:	64a6                	ld	s1,72(sp)
 164:	6906                	ld	s2,64(sp)
 166:	79e2                	ld	s3,56(sp)
 168:	7a42                	ld	s4,48(sp)
 16a:	7aa2                	ld	s5,40(sp)
 16c:	7b02                	ld	s6,32(sp)
 16e:	6be2                	ld	s7,24(sp)
 170:	6125                	addi	sp,sp,96
 172:	8082                	ret

0000000000000174 <stat>:
 174:	1101                	addi	sp,sp,-32
 176:	ec06                	sd	ra,24(sp)
 178:	e822                	sd	s0,16(sp)
 17a:	e426                	sd	s1,8(sp)
 17c:	e04a                	sd	s2,0(sp)
 17e:	1000                	addi	s0,sp,32
 180:	892e                	mv	s2,a1
 182:	4581                	li	a1,0
 184:	00000097          	auipc	ra,0x0
 188:	176080e7          	jalr	374(ra) # 2fa <open>
 18c:	02054563          	bltz	a0,1b6 <stat+0x42>
 190:	84aa                	mv	s1,a0
 192:	85ca                	mv	a1,s2
 194:	00000097          	auipc	ra,0x0
 198:	17e080e7          	jalr	382(ra) # 312 <fstat>
 19c:	892a                	mv	s2,a0
 19e:	8526                	mv	a0,s1
 1a0:	00000097          	auipc	ra,0x0
 1a4:	142080e7          	jalr	322(ra) # 2e2 <close>
 1a8:	854a                	mv	a0,s2
 1aa:	60e2                	ld	ra,24(sp)
 1ac:	6442                	ld	s0,16(sp)
 1ae:	64a2                	ld	s1,8(sp)
 1b0:	6902                	ld	s2,0(sp)
 1b2:	6105                	addi	sp,sp,32
 1b4:	8082                	ret
 1b6:	597d                	li	s2,-1
 1b8:	bfc5                	j	1a8 <stat+0x34>

00000000000001ba <atoi>:
 1ba:	1141                	addi	sp,sp,-16
 1bc:	e422                	sd	s0,8(sp)
 1be:	0800                	addi	s0,sp,16
 1c0:	00054603          	lbu	a2,0(a0)
 1c4:	fd06079b          	addiw	a5,a2,-48
 1c8:	0ff7f793          	andi	a5,a5,255
 1cc:	4725                	li	a4,9
 1ce:	02f76963          	bltu	a4,a5,200 <atoi+0x46>
 1d2:	86aa                	mv	a3,a0
 1d4:	4501                	li	a0,0
 1d6:	45a5                	li	a1,9
 1d8:	0685                	addi	a3,a3,1
 1da:	0025179b          	slliw	a5,a0,0x2
 1de:	9fa9                	addw	a5,a5,a0
 1e0:	0017979b          	slliw	a5,a5,0x1
 1e4:	9fb1                	addw	a5,a5,a2
 1e6:	fd07851b          	addiw	a0,a5,-48
 1ea:	0006c603          	lbu	a2,0(a3)
 1ee:	fd06071b          	addiw	a4,a2,-48
 1f2:	0ff77713          	andi	a4,a4,255
 1f6:	fee5f1e3          	bgeu	a1,a4,1d8 <atoi+0x1e>
 1fa:	6422                	ld	s0,8(sp)
 1fc:	0141                	addi	sp,sp,16
 1fe:	8082                	ret
 200:	4501                	li	a0,0
 202:	bfe5                	j	1fa <atoi+0x40>

0000000000000204 <memmove>:
 204:	1141                	addi	sp,sp,-16
 206:	e422                	sd	s0,8(sp)
 208:	0800                	addi	s0,sp,16
 20a:	02b57663          	bgeu	a0,a1,236 <memmove+0x32>
 20e:	02c05163          	blez	a2,230 <memmove+0x2c>
 212:	fff6079b          	addiw	a5,a2,-1
 216:	1782                	slli	a5,a5,0x20
 218:	9381                	srli	a5,a5,0x20
 21a:	0785                	addi	a5,a5,1
 21c:	97aa                	add	a5,a5,a0
 21e:	872a                	mv	a4,a0
 220:	0585                	addi	a1,a1,1
 222:	0705                	addi	a4,a4,1
 224:	fff5c683          	lbu	a3,-1(a1)
 228:	fed70fa3          	sb	a3,-1(a4)
 22c:	fee79ae3          	bne	a5,a4,220 <memmove+0x1c>
 230:	6422                	ld	s0,8(sp)
 232:	0141                	addi	sp,sp,16
 234:	8082                	ret
 236:	00c50733          	add	a4,a0,a2
 23a:	95b2                	add	a1,a1,a2
 23c:	fec05ae3          	blez	a2,230 <memmove+0x2c>
 240:	fff6079b          	addiw	a5,a2,-1
 244:	1782                	slli	a5,a5,0x20
 246:	9381                	srli	a5,a5,0x20
 248:	fff7c793          	not	a5,a5
 24c:	97ba                	add	a5,a5,a4
 24e:	15fd                	addi	a1,a1,-1
 250:	177d                	addi	a4,a4,-1
 252:	0005c683          	lbu	a3,0(a1)
 256:	00d70023          	sb	a3,0(a4)
 25a:	fee79ae3          	bne	a5,a4,24e <memmove+0x4a>
 25e:	bfc9                	j	230 <memmove+0x2c>

0000000000000260 <memcmp>:
 260:	1141                	addi	sp,sp,-16
 262:	e422                	sd	s0,8(sp)
 264:	0800                	addi	s0,sp,16
 266:	ca05                	beqz	a2,296 <memcmp+0x36>
 268:	fff6069b          	addiw	a3,a2,-1
 26c:	1682                	slli	a3,a3,0x20
 26e:	9281                	srli	a3,a3,0x20
 270:	0685                	addi	a3,a3,1
 272:	96aa                	add	a3,a3,a0
 274:	00054783          	lbu	a5,0(a0)
 278:	0005c703          	lbu	a4,0(a1)
 27c:	00e79863          	bne	a5,a4,28c <memcmp+0x2c>
 280:	0505                	addi	a0,a0,1
 282:	0585                	addi	a1,a1,1
 284:	fed518e3          	bne	a0,a3,274 <memcmp+0x14>
 288:	4501                	li	a0,0
 28a:	a019                	j	290 <memcmp+0x30>
 28c:	40e7853b          	subw	a0,a5,a4
 290:	6422                	ld	s0,8(sp)
 292:	0141                	addi	sp,sp,16
 294:	8082                	ret
 296:	4501                	li	a0,0
 298:	bfe5                	j	290 <memcmp+0x30>

000000000000029a <memcpy>:
 29a:	1141                	addi	sp,sp,-16
 29c:	e406                	sd	ra,8(sp)
 29e:	e022                	sd	s0,0(sp)
 2a0:	0800                	addi	s0,sp,16
 2a2:	00000097          	auipc	ra,0x0
 2a6:	f62080e7          	jalr	-158(ra) # 204 <memmove>
 2aa:	60a2                	ld	ra,8(sp)
 2ac:	6402                	ld	s0,0(sp)
 2ae:	0141                	addi	sp,sp,16
 2b0:	8082                	ret

00000000000002b2 <fork>:
 2b2:	4885                	li	a7,1
 2b4:	00000073          	ecall
 2b8:	8082                	ret

00000000000002ba <exit>:
 2ba:	4889                	li	a7,2
 2bc:	00000073          	ecall
 2c0:	8082                	ret

00000000000002c2 <wait>:
 2c2:	488d                	li	a7,3
 2c4:	00000073          	ecall
 2c8:	8082                	ret

00000000000002ca <pipe>:
 2ca:	4891                	li	a7,4
 2cc:	00000073          	ecall
 2d0:	8082                	ret

00000000000002d2 <read>:
 2d2:	4895                	li	a7,5
 2d4:	00000073          	ecall
 2d8:	8082                	ret

00000000000002da <write>:
 2da:	48c1                	li	a7,16
 2dc:	00000073          	ecall
 2e0:	8082                	ret

00000000000002e2 <close>:
 2e2:	48d5                	li	a7,21
 2e4:	00000073          	ecall
 2e8:	8082                	ret

00000000000002ea <kill>:
 2ea:	4899                	li	a7,6
 2ec:	00000073          	ecall
 2f0:	8082                	ret

00000000000002f2 <exec>:
 2f2:	489d                	li	a7,7
 2f4:	00000073          	ecall
 2f8:	8082                	ret

00000000000002fa <open>:
 2fa:	48bd                	li	a7,15
 2fc:	00000073          	ecall
 300:	8082                	ret

0000000000000302 <mknod>:
 302:	48c5                	li	a7,17
 304:	00000073          	ecall
 308:	8082                	ret

000000000000030a <unlink>:
 30a:	48c9                	li	a7,18
 30c:	00000073          	ecall
 310:	8082                	ret

0000000000000312 <fstat>:
 312:	48a1                	li	a7,8
 314:	00000073          	ecall
 318:	8082                	ret

000000000000031a <link>:
 31a:	48cd                	li	a7,19
 31c:	00000073          	ecall
 320:	8082                	ret

0000000000000322 <mkdir>:
 322:	48d1                	li	a7,20
 324:	00000073          	ecall
 328:	8082                	ret

000000000000032a <chdir>:
 32a:	48a5                	li	a7,9
 32c:	00000073          	ecall
 330:	8082                	ret

0000000000000332 <dup>:
 332:	48a9                	li	a7,10
 334:	00000073          	ecall
 338:	8082                	ret

000000000000033a <getpid>:
 33a:	48ad                	li	a7,11
 33c:	00000073          	ecall
 340:	8082                	ret

0000000000000342 <sbrk>:
 342:	48b1                	li	a7,12
 344:	00000073          	ecall
 348:	8082                	ret

000000000000034a <sleep>:
 34a:	48b5                	li	a7,13
 34c:	00000073          	ecall
 350:	8082                	ret

0000000000000352 <uptime>:
 352:	48b9                	li	a7,14
 354:	00000073          	ecall
 358:	8082                	ret

000000000000035a <trace>:
 35a:	48d9                	li	a7,22
 35c:	00000073          	ecall
 360:	8082                	ret

0000000000000362 <putc>:
 362:	1101                	addi	sp,sp,-32
 364:	ec06                	sd	ra,24(sp)
 366:	e822                	sd	s0,16(sp)
 368:	1000                	addi	s0,sp,32
 36a:	feb407a3          	sb	a1,-17(s0)
 36e:	4605                	li	a2,1
 370:	fef40593          	addi	a1,s0,-17
 374:	00000097          	auipc	ra,0x0
 378:	f66080e7          	jalr	-154(ra) # 2da <write>
 37c:	60e2                	ld	ra,24(sp)
 37e:	6442                	ld	s0,16(sp)
 380:	6105                	addi	sp,sp,32
 382:	8082                	ret

0000000000000384 <printint>:
 384:	7139                	addi	sp,sp,-64
 386:	fc06                	sd	ra,56(sp)
 388:	f822                	sd	s0,48(sp)
 38a:	f426                	sd	s1,40(sp)
 38c:	f04a                	sd	s2,32(sp)
 38e:	ec4e                	sd	s3,24(sp)
 390:	0080                	addi	s0,sp,64
 392:	84aa                	mv	s1,a0
 394:	c299                	beqz	a3,39a <printint+0x16>
 396:	0805c863          	bltz	a1,426 <printint+0xa2>
 39a:	2581                	sext.w	a1,a1
 39c:	4881                	li	a7,0
 39e:	fc040693          	addi	a3,s0,-64
 3a2:	4701                	li	a4,0
 3a4:	2601                	sext.w	a2,a2
 3a6:	00000517          	auipc	a0,0x0
 3aa:	44250513          	addi	a0,a0,1090 # 7e8 <digits>
 3ae:	883a                	mv	a6,a4
 3b0:	2705                	addiw	a4,a4,1
 3b2:	02c5f7bb          	remuw	a5,a1,a2
 3b6:	1782                	slli	a5,a5,0x20
 3b8:	9381                	srli	a5,a5,0x20
 3ba:	97aa                	add	a5,a5,a0
 3bc:	0007c783          	lbu	a5,0(a5)
 3c0:	00f68023          	sb	a5,0(a3)
 3c4:	0005879b          	sext.w	a5,a1
 3c8:	02c5d5bb          	divuw	a1,a1,a2
 3cc:	0685                	addi	a3,a3,1
 3ce:	fec7f0e3          	bgeu	a5,a2,3ae <printint+0x2a>
 3d2:	00088b63          	beqz	a7,3e8 <printint+0x64>
 3d6:	fd040793          	addi	a5,s0,-48
 3da:	973e                	add	a4,a4,a5
 3dc:	02d00793          	li	a5,45
 3e0:	fef70823          	sb	a5,-16(a4)
 3e4:	0028071b          	addiw	a4,a6,2
 3e8:	02e05863          	blez	a4,418 <printint+0x94>
 3ec:	fc040793          	addi	a5,s0,-64
 3f0:	00e78933          	add	s2,a5,a4
 3f4:	fff78993          	addi	s3,a5,-1
 3f8:	99ba                	add	s3,s3,a4
 3fa:	377d                	addiw	a4,a4,-1
 3fc:	1702                	slli	a4,a4,0x20
 3fe:	9301                	srli	a4,a4,0x20
 400:	40e989b3          	sub	s3,s3,a4
 404:	fff94583          	lbu	a1,-1(s2)
 408:	8526                	mv	a0,s1
 40a:	00000097          	auipc	ra,0x0
 40e:	f58080e7          	jalr	-168(ra) # 362 <putc>
 412:	197d                	addi	s2,s2,-1
 414:	ff3918e3          	bne	s2,s3,404 <printint+0x80>
 418:	70e2                	ld	ra,56(sp)
 41a:	7442                	ld	s0,48(sp)
 41c:	74a2                	ld	s1,40(sp)
 41e:	7902                	ld	s2,32(sp)
 420:	69e2                	ld	s3,24(sp)
 422:	6121                	addi	sp,sp,64
 424:	8082                	ret
 426:	40b005bb          	negw	a1,a1
 42a:	4885                	li	a7,1
 42c:	bf8d                	j	39e <printint+0x1a>

000000000000042e <vprintf>:
 42e:	7119                	addi	sp,sp,-128
 430:	fc86                	sd	ra,120(sp)
 432:	f8a2                	sd	s0,112(sp)
 434:	f4a6                	sd	s1,104(sp)
 436:	f0ca                	sd	s2,96(sp)
 438:	ecce                	sd	s3,88(sp)
 43a:	e8d2                	sd	s4,80(sp)
 43c:	e4d6                	sd	s5,72(sp)
 43e:	e0da                	sd	s6,64(sp)
 440:	fc5e                	sd	s7,56(sp)
 442:	f862                	sd	s8,48(sp)
 444:	f466                	sd	s9,40(sp)
 446:	f06a                	sd	s10,32(sp)
 448:	ec6e                	sd	s11,24(sp)
 44a:	0100                	addi	s0,sp,128
 44c:	0005c903          	lbu	s2,0(a1)
 450:	18090f63          	beqz	s2,5ee <vprintf+0x1c0>
 454:	8aaa                	mv	s5,a0
 456:	8b32                	mv	s6,a2
 458:	00158493          	addi	s1,a1,1
 45c:	4981                	li	s3,0
 45e:	02500a13          	li	s4,37
 462:	06400c13          	li	s8,100
 466:	06c00c93          	li	s9,108
 46a:	07800d13          	li	s10,120
 46e:	07000d93          	li	s11,112
 472:	00000b97          	auipc	s7,0x0
 476:	376b8b93          	addi	s7,s7,886 # 7e8 <digits>
 47a:	a839                	j	498 <vprintf+0x6a>
 47c:	85ca                	mv	a1,s2
 47e:	8556                	mv	a0,s5
 480:	00000097          	auipc	ra,0x0
 484:	ee2080e7          	jalr	-286(ra) # 362 <putc>
 488:	a019                	j	48e <vprintf+0x60>
 48a:	01498f63          	beq	s3,s4,4a8 <vprintf+0x7a>
 48e:	0485                	addi	s1,s1,1
 490:	fff4c903          	lbu	s2,-1(s1)
 494:	14090d63          	beqz	s2,5ee <vprintf+0x1c0>
 498:	0009079b          	sext.w	a5,s2
 49c:	fe0997e3          	bnez	s3,48a <vprintf+0x5c>
 4a0:	fd479ee3          	bne	a5,s4,47c <vprintf+0x4e>
 4a4:	89be                	mv	s3,a5
 4a6:	b7e5                	j	48e <vprintf+0x60>
 4a8:	05878063          	beq	a5,s8,4e8 <vprintf+0xba>
 4ac:	05978c63          	beq	a5,s9,504 <vprintf+0xd6>
 4b0:	07a78863          	beq	a5,s10,520 <vprintf+0xf2>
 4b4:	09b78463          	beq	a5,s11,53c <vprintf+0x10e>
 4b8:	07300713          	li	a4,115
 4bc:	0ce78663          	beq	a5,a4,588 <vprintf+0x15a>
 4c0:	06300713          	li	a4,99
 4c4:	0ee78e63          	beq	a5,a4,5c0 <vprintf+0x192>
 4c8:	11478863          	beq	a5,s4,5d8 <vprintf+0x1aa>
 4cc:	85d2                	mv	a1,s4
 4ce:	8556                	mv	a0,s5
 4d0:	00000097          	auipc	ra,0x0
 4d4:	e92080e7          	jalr	-366(ra) # 362 <putc>
 4d8:	85ca                	mv	a1,s2
 4da:	8556                	mv	a0,s5
 4dc:	00000097          	auipc	ra,0x0
 4e0:	e86080e7          	jalr	-378(ra) # 362 <putc>
 4e4:	4981                	li	s3,0
 4e6:	b765                	j	48e <vprintf+0x60>
 4e8:	008b0913          	addi	s2,s6,8
 4ec:	4685                	li	a3,1
 4ee:	4629                	li	a2,10
 4f0:	000b2583          	lw	a1,0(s6)
 4f4:	8556                	mv	a0,s5
 4f6:	00000097          	auipc	ra,0x0
 4fa:	e8e080e7          	jalr	-370(ra) # 384 <printint>
 4fe:	8b4a                	mv	s6,s2
 500:	4981                	li	s3,0
 502:	b771                	j	48e <vprintf+0x60>
 504:	008b0913          	addi	s2,s6,8
 508:	4681                	li	a3,0
 50a:	4629                	li	a2,10
 50c:	000b2583          	lw	a1,0(s6)
 510:	8556                	mv	a0,s5
 512:	00000097          	auipc	ra,0x0
 516:	e72080e7          	jalr	-398(ra) # 384 <printint>
 51a:	8b4a                	mv	s6,s2
 51c:	4981                	li	s3,0
 51e:	bf85                	j	48e <vprintf+0x60>
 520:	008b0913          	addi	s2,s6,8
 524:	4681                	li	a3,0
 526:	4641                	li	a2,16
 528:	000b2583          	lw	a1,0(s6)
 52c:	8556                	mv	a0,s5
 52e:	00000097          	auipc	ra,0x0
 532:	e56080e7          	jalr	-426(ra) # 384 <printint>
 536:	8b4a                	mv	s6,s2
 538:	4981                	li	s3,0
 53a:	bf91                	j	48e <vprintf+0x60>
 53c:	008b0793          	addi	a5,s6,8
 540:	f8f43423          	sd	a5,-120(s0)
 544:	000b3983          	ld	s3,0(s6)
 548:	03000593          	li	a1,48
 54c:	8556                	mv	a0,s5
 54e:	00000097          	auipc	ra,0x0
 552:	e14080e7          	jalr	-492(ra) # 362 <putc>
 556:	85ea                	mv	a1,s10
 558:	8556                	mv	a0,s5
 55a:	00000097          	auipc	ra,0x0
 55e:	e08080e7          	jalr	-504(ra) # 362 <putc>
 562:	4941                	li	s2,16
 564:	03c9d793          	srli	a5,s3,0x3c
 568:	97de                	add	a5,a5,s7
 56a:	0007c583          	lbu	a1,0(a5)
 56e:	8556                	mv	a0,s5
 570:	00000097          	auipc	ra,0x0
 574:	df2080e7          	jalr	-526(ra) # 362 <putc>
 578:	0992                	slli	s3,s3,0x4
 57a:	397d                	addiw	s2,s2,-1
 57c:	fe0914e3          	bnez	s2,564 <vprintf+0x136>
 580:	f8843b03          	ld	s6,-120(s0)
 584:	4981                	li	s3,0
 586:	b721                	j	48e <vprintf+0x60>
 588:	008b0993          	addi	s3,s6,8
 58c:	000b3903          	ld	s2,0(s6)
 590:	02090163          	beqz	s2,5b2 <vprintf+0x184>
 594:	00094583          	lbu	a1,0(s2)
 598:	c9a1                	beqz	a1,5e8 <vprintf+0x1ba>
 59a:	8556                	mv	a0,s5
 59c:	00000097          	auipc	ra,0x0
 5a0:	dc6080e7          	jalr	-570(ra) # 362 <putc>
 5a4:	0905                	addi	s2,s2,1
 5a6:	00094583          	lbu	a1,0(s2)
 5aa:	f9e5                	bnez	a1,59a <vprintf+0x16c>
 5ac:	8b4e                	mv	s6,s3
 5ae:	4981                	li	s3,0
 5b0:	bdf9                	j	48e <vprintf+0x60>
 5b2:	00000917          	auipc	s2,0x0
 5b6:	22e90913          	addi	s2,s2,558 # 7e0 <malloc+0xe8>
 5ba:	02800593          	li	a1,40
 5be:	bff1                	j	59a <vprintf+0x16c>
 5c0:	008b0913          	addi	s2,s6,8
 5c4:	000b4583          	lbu	a1,0(s6)
 5c8:	8556                	mv	a0,s5
 5ca:	00000097          	auipc	ra,0x0
 5ce:	d98080e7          	jalr	-616(ra) # 362 <putc>
 5d2:	8b4a                	mv	s6,s2
 5d4:	4981                	li	s3,0
 5d6:	bd65                	j	48e <vprintf+0x60>
 5d8:	85d2                	mv	a1,s4
 5da:	8556                	mv	a0,s5
 5dc:	00000097          	auipc	ra,0x0
 5e0:	d86080e7          	jalr	-634(ra) # 362 <putc>
 5e4:	4981                	li	s3,0
 5e6:	b565                	j	48e <vprintf+0x60>
 5e8:	8b4e                	mv	s6,s3
 5ea:	4981                	li	s3,0
 5ec:	b54d                	j	48e <vprintf+0x60>
 5ee:	70e6                	ld	ra,120(sp)
 5f0:	7446                	ld	s0,112(sp)
 5f2:	74a6                	ld	s1,104(sp)
 5f4:	7906                	ld	s2,96(sp)
 5f6:	69e6                	ld	s3,88(sp)
 5f8:	6a46                	ld	s4,80(sp)
 5fa:	6aa6                	ld	s5,72(sp)
 5fc:	6b06                	ld	s6,64(sp)
 5fe:	7be2                	ld	s7,56(sp)
 600:	7c42                	ld	s8,48(sp)
 602:	7ca2                	ld	s9,40(sp)
 604:	7d02                	ld	s10,32(sp)
 606:	6de2                	ld	s11,24(sp)
 608:	6109                	addi	sp,sp,128
 60a:	8082                	ret

000000000000060c <fprintf>:
 60c:	715d                	addi	sp,sp,-80
 60e:	ec06                	sd	ra,24(sp)
 610:	e822                	sd	s0,16(sp)
 612:	1000                	addi	s0,sp,32
 614:	e010                	sd	a2,0(s0)
 616:	e414                	sd	a3,8(s0)
 618:	e818                	sd	a4,16(s0)
 61a:	ec1c                	sd	a5,24(s0)
 61c:	03043023          	sd	a6,32(s0)
 620:	03143423          	sd	a7,40(s0)
 624:	fe843423          	sd	s0,-24(s0)
 628:	8622                	mv	a2,s0
 62a:	00000097          	auipc	ra,0x0
 62e:	e04080e7          	jalr	-508(ra) # 42e <vprintf>
 632:	60e2                	ld	ra,24(sp)
 634:	6442                	ld	s0,16(sp)
 636:	6161                	addi	sp,sp,80
 638:	8082                	ret

000000000000063a <printf>:
 63a:	711d                	addi	sp,sp,-96
 63c:	ec06                	sd	ra,24(sp)
 63e:	e822                	sd	s0,16(sp)
 640:	1000                	addi	s0,sp,32
 642:	e40c                	sd	a1,8(s0)
 644:	e810                	sd	a2,16(s0)
 646:	ec14                	sd	a3,24(s0)
 648:	f018                	sd	a4,32(s0)
 64a:	f41c                	sd	a5,40(s0)
 64c:	03043823          	sd	a6,48(s0)
 650:	03143c23          	sd	a7,56(s0)
 654:	00840613          	addi	a2,s0,8
 658:	fec43423          	sd	a2,-24(s0)
 65c:	85aa                	mv	a1,a0
 65e:	4505                	li	a0,1
 660:	00000097          	auipc	ra,0x0
 664:	dce080e7          	jalr	-562(ra) # 42e <vprintf>
 668:	60e2                	ld	ra,24(sp)
 66a:	6442                	ld	s0,16(sp)
 66c:	6125                	addi	sp,sp,96
 66e:	8082                	ret

0000000000000670 <free>:
 670:	1141                	addi	sp,sp,-16
 672:	e422                	sd	s0,8(sp)
 674:	0800                	addi	s0,sp,16
 676:	ff050693          	addi	a3,a0,-16
 67a:	00001797          	auipc	a5,0x1
 67e:	9867b783          	ld	a5,-1658(a5) # 1000 <freep>
 682:	a805                	j	6b2 <free+0x42>
 684:	4618                	lw	a4,8(a2)
 686:	9db9                	addw	a1,a1,a4
 688:	feb52c23          	sw	a1,-8(a0)
 68c:	6398                	ld	a4,0(a5)
 68e:	6318                	ld	a4,0(a4)
 690:	fee53823          	sd	a4,-16(a0)
 694:	a091                	j	6d8 <free+0x68>
 696:	ff852703          	lw	a4,-8(a0)
 69a:	9e39                	addw	a2,a2,a4
 69c:	c790                	sw	a2,8(a5)
 69e:	ff053703          	ld	a4,-16(a0)
 6a2:	e398                	sd	a4,0(a5)
 6a4:	a099                	j	6ea <free+0x7a>
 6a6:	6398                	ld	a4,0(a5)
 6a8:	00e7e463          	bltu	a5,a4,6b0 <free+0x40>
 6ac:	00e6ea63          	bltu	a3,a4,6c0 <free+0x50>
 6b0:	87ba                	mv	a5,a4
 6b2:	fed7fae3          	bgeu	a5,a3,6a6 <free+0x36>
 6b6:	6398                	ld	a4,0(a5)
 6b8:	00e6e463          	bltu	a3,a4,6c0 <free+0x50>
 6bc:	fee7eae3          	bltu	a5,a4,6b0 <free+0x40>
 6c0:	ff852583          	lw	a1,-8(a0)
 6c4:	6390                	ld	a2,0(a5)
 6c6:	02059713          	slli	a4,a1,0x20
 6ca:	9301                	srli	a4,a4,0x20
 6cc:	0712                	slli	a4,a4,0x4
 6ce:	9736                	add	a4,a4,a3
 6d0:	fae60ae3          	beq	a2,a4,684 <free+0x14>
 6d4:	fec53823          	sd	a2,-16(a0)
 6d8:	4790                	lw	a2,8(a5)
 6da:	02061713          	slli	a4,a2,0x20
 6de:	9301                	srli	a4,a4,0x20
 6e0:	0712                	slli	a4,a4,0x4
 6e2:	973e                	add	a4,a4,a5
 6e4:	fae689e3          	beq	a3,a4,696 <free+0x26>
 6e8:	e394                	sd	a3,0(a5)
 6ea:	00001717          	auipc	a4,0x1
 6ee:	90f73b23          	sd	a5,-1770(a4) # 1000 <freep>
 6f2:	6422                	ld	s0,8(sp)
 6f4:	0141                	addi	sp,sp,16
 6f6:	8082                	ret

00000000000006f8 <malloc>:
 6f8:	7139                	addi	sp,sp,-64
 6fa:	fc06                	sd	ra,56(sp)
 6fc:	f822                	sd	s0,48(sp)
 6fe:	f426                	sd	s1,40(sp)
 700:	f04a                	sd	s2,32(sp)
 702:	ec4e                	sd	s3,24(sp)
 704:	e852                	sd	s4,16(sp)
 706:	e456                	sd	s5,8(sp)
 708:	e05a                	sd	s6,0(sp)
 70a:	0080                	addi	s0,sp,64
 70c:	02051493          	slli	s1,a0,0x20
 710:	9081                	srli	s1,s1,0x20
 712:	04bd                	addi	s1,s1,15
 714:	8091                	srli	s1,s1,0x4
 716:	0014899b          	addiw	s3,s1,1
 71a:	0485                	addi	s1,s1,1
 71c:	00001517          	auipc	a0,0x1
 720:	8e453503          	ld	a0,-1820(a0) # 1000 <freep>
 724:	c515                	beqz	a0,750 <malloc+0x58>
 726:	611c                	ld	a5,0(a0)
 728:	4798                	lw	a4,8(a5)
 72a:	02977f63          	bgeu	a4,s1,768 <malloc+0x70>
 72e:	8a4e                	mv	s4,s3
 730:	0009871b          	sext.w	a4,s3
 734:	6685                	lui	a3,0x1
 736:	00d77363          	bgeu	a4,a3,73c <malloc+0x44>
 73a:	6a05                	lui	s4,0x1
 73c:	000a0b1b          	sext.w	s6,s4
 740:	004a1a1b          	slliw	s4,s4,0x4
 744:	00001917          	auipc	s2,0x1
 748:	8bc90913          	addi	s2,s2,-1860 # 1000 <freep>
 74c:	5afd                	li	s5,-1
 74e:	a88d                	j	7c0 <malloc+0xc8>
 750:	00001797          	auipc	a5,0x1
 754:	8c078793          	addi	a5,a5,-1856 # 1010 <base>
 758:	00001717          	auipc	a4,0x1
 75c:	8af73423          	sd	a5,-1880(a4) # 1000 <freep>
 760:	e39c                	sd	a5,0(a5)
 762:	0007a423          	sw	zero,8(a5)
 766:	b7e1                	j	72e <malloc+0x36>
 768:	02e48b63          	beq	s1,a4,79e <malloc+0xa6>
 76c:	4137073b          	subw	a4,a4,s3
 770:	c798                	sw	a4,8(a5)
 772:	1702                	slli	a4,a4,0x20
 774:	9301                	srli	a4,a4,0x20
 776:	0712                	slli	a4,a4,0x4
 778:	97ba                	add	a5,a5,a4
 77a:	0137a423          	sw	s3,8(a5)
 77e:	00001717          	auipc	a4,0x1
 782:	88a73123          	sd	a0,-1918(a4) # 1000 <freep>
 786:	01078513          	addi	a0,a5,16
 78a:	70e2                	ld	ra,56(sp)
 78c:	7442                	ld	s0,48(sp)
 78e:	74a2                	ld	s1,40(sp)
 790:	7902                	ld	s2,32(sp)
 792:	69e2                	ld	s3,24(sp)
 794:	6a42                	ld	s4,16(sp)
 796:	6aa2                	ld	s5,8(sp)
 798:	6b02                	ld	s6,0(sp)
 79a:	6121                	addi	sp,sp,64
 79c:	8082                	ret
 79e:	6398                	ld	a4,0(a5)
 7a0:	e118                	sd	a4,0(a0)
 7a2:	bff1                	j	77e <malloc+0x86>
 7a4:	01652423          	sw	s6,8(a0)
 7a8:	0541                	addi	a0,a0,16
 7aa:	00000097          	auipc	ra,0x0
 7ae:	ec6080e7          	jalr	-314(ra) # 670 <free>
 7b2:	00093503          	ld	a0,0(s2)
 7b6:	d971                	beqz	a0,78a <malloc+0x92>
 7b8:	611c                	ld	a5,0(a0)
 7ba:	4798                	lw	a4,8(a5)
 7bc:	fa9776e3          	bgeu	a4,s1,768 <malloc+0x70>
 7c0:	00093703          	ld	a4,0(s2)
 7c4:	853e                	mv	a0,a5
 7c6:	fef719e3          	bne	a4,a5,7b8 <malloc+0xc0>
 7ca:	8552                	mv	a0,s4
 7cc:	00000097          	auipc	ra,0x0
 7d0:	b76080e7          	jalr	-1162(ra) # 342 <sbrk>
 7d4:	fd5518e3          	bne	a0,s5,7a4 <malloc+0xac>
 7d8:	4501                	li	a0,0
 7da:	bf45                	j	78a <malloc+0x92>
