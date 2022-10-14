
user/_schedulertest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	0080                	addi	s0,sp,64
   e:	4481                	li	s1,0
  10:	4929                	li	s2,10
  12:	00000097          	auipc	ra,0x0
  16:	326080e7          	jalr	806(ra) # 338 <fork>
  1a:	02054f63          	bltz	a0,58 <main+0x58>
  1e:	c519                	beqz	a0,2c <main+0x2c>
  20:	2485                	addiw	s1,s1,1
  22:	ff2498e3          	bne	s1,s2,12 <main+0x12>
  26:	4901                	li	s2,0
  28:	4981                	li	s3,0
  2a:	a8b9                	j	88 <main+0x88>
  2c:	4791                	li	a5,4
  2e:	0097de63          	bge	a5,s1,4a <main+0x4a>
  32:	009507b7          	lui	a5,0x950
  36:	2f978793          	addi	a5,a5,761 # 9502f9 <base+0x94f2e9>
  3a:	07aa                	slli	a5,a5,0xa
  3c:	17fd                	addi	a5,a5,-1
  3e:	fffd                	bnez	a5,3c <main+0x3c>
  40:	4501                	li	a0,0
  42:	00000097          	auipc	ra,0x0
  46:	2fe080e7          	jalr	766(ra) # 340 <exit>
  4a:	0c800513          	li	a0,200
  4e:	00000097          	auipc	ra,0x0
  52:	382080e7          	jalr	898(ra) # 3d0 <sleep>
  56:	b7ed                	j	40 <main+0x40>
  58:	fc9047e3          	bgtz	s1,26 <main+0x26>
  5c:	4901                	li	s2,0
  5e:	4981                	li	s3,0
  60:	45a9                	li	a1,10
  62:	02b9c63b          	divw	a2,s3,a1
  66:	02b945bb          	divw	a1,s2,a1
  6a:	00001517          	auipc	a0,0x1
  6e:	82650513          	addi	a0,a0,-2010 # 890 <malloc+0xf2>
  72:	00000097          	auipc	ra,0x0
  76:	66e080e7          	jalr	1646(ra) # 6e0 <printf>
  7a:	4501                	li	a0,0
  7c:	00000097          	auipc	ra,0x0
  80:	2c4080e7          	jalr	708(ra) # 340 <exit>
  84:	34fd                	addiw	s1,s1,-1
  86:	dce9                	beqz	s1,60 <main+0x60>
  88:	fc840613          	addi	a2,s0,-56
  8c:	fcc40593          	addi	a1,s0,-52
  90:	4501                	li	a0,0
  92:	00000097          	auipc	ra,0x0
  96:	35e080e7          	jalr	862(ra) # 3f0 <waitx>
  9a:	fe0545e3          	bltz	a0,84 <main+0x84>
  9e:	fc842783          	lw	a5,-56(s0)
  a2:	0127893b          	addw	s2,a5,s2
  a6:	fcc42783          	lw	a5,-52(s0)
  aa:	013789bb          	addw	s3,a5,s3
  ae:	bfd9                	j	84 <main+0x84>

00000000000000b0 <_main>:
  b0:	1141                	addi	sp,sp,-16
  b2:	e406                	sd	ra,8(sp)
  b4:	e022                	sd	s0,0(sp)
  b6:	0800                	addi	s0,sp,16
  b8:	00000097          	auipc	ra,0x0
  bc:	f48080e7          	jalr	-184(ra) # 0 <main>
  c0:	4501                	li	a0,0
  c2:	00000097          	auipc	ra,0x0
  c6:	27e080e7          	jalr	638(ra) # 340 <exit>

00000000000000ca <strcpy>:
  ca:	1141                	addi	sp,sp,-16
  cc:	e422                	sd	s0,8(sp)
  ce:	0800                	addi	s0,sp,16
  d0:	87aa                	mv	a5,a0
  d2:	0585                	addi	a1,a1,1
  d4:	0785                	addi	a5,a5,1
  d6:	fff5c703          	lbu	a4,-1(a1)
  da:	fee78fa3          	sb	a4,-1(a5)
  de:	fb75                	bnez	a4,d2 <strcpy+0x8>
  e0:	6422                	ld	s0,8(sp)
  e2:	0141                	addi	sp,sp,16
  e4:	8082                	ret

00000000000000e6 <strcmp>:
  e6:	1141                	addi	sp,sp,-16
  e8:	e422                	sd	s0,8(sp)
  ea:	0800                	addi	s0,sp,16
  ec:	00054783          	lbu	a5,0(a0)
  f0:	cb91                	beqz	a5,104 <strcmp+0x1e>
  f2:	0005c703          	lbu	a4,0(a1)
  f6:	00f71763          	bne	a4,a5,104 <strcmp+0x1e>
  fa:	0505                	addi	a0,a0,1
  fc:	0585                	addi	a1,a1,1
  fe:	00054783          	lbu	a5,0(a0)
 102:	fbe5                	bnez	a5,f2 <strcmp+0xc>
 104:	0005c503          	lbu	a0,0(a1)
 108:	40a7853b          	subw	a0,a5,a0
 10c:	6422                	ld	s0,8(sp)
 10e:	0141                	addi	sp,sp,16
 110:	8082                	ret

0000000000000112 <strlen>:
 112:	1141                	addi	sp,sp,-16
 114:	e422                	sd	s0,8(sp)
 116:	0800                	addi	s0,sp,16
 118:	00054783          	lbu	a5,0(a0)
 11c:	cf91                	beqz	a5,138 <strlen+0x26>
 11e:	0505                	addi	a0,a0,1
 120:	87aa                	mv	a5,a0
 122:	4685                	li	a3,1
 124:	9e89                	subw	a3,a3,a0
 126:	00f6853b          	addw	a0,a3,a5
 12a:	0785                	addi	a5,a5,1
 12c:	fff7c703          	lbu	a4,-1(a5)
 130:	fb7d                	bnez	a4,126 <strlen+0x14>
 132:	6422                	ld	s0,8(sp)
 134:	0141                	addi	sp,sp,16
 136:	8082                	ret
 138:	4501                	li	a0,0
 13a:	bfe5                	j	132 <strlen+0x20>

000000000000013c <memset>:
 13c:	1141                	addi	sp,sp,-16
 13e:	e422                	sd	s0,8(sp)
 140:	0800                	addi	s0,sp,16
 142:	ce09                	beqz	a2,15c <memset+0x20>
 144:	87aa                	mv	a5,a0
 146:	fff6071b          	addiw	a4,a2,-1
 14a:	1702                	slli	a4,a4,0x20
 14c:	9301                	srli	a4,a4,0x20
 14e:	0705                	addi	a4,a4,1
 150:	972a                	add	a4,a4,a0
 152:	00b78023          	sb	a1,0(a5)
 156:	0785                	addi	a5,a5,1
 158:	fee79de3          	bne	a5,a4,152 <memset+0x16>
 15c:	6422                	ld	s0,8(sp)
 15e:	0141                	addi	sp,sp,16
 160:	8082                	ret

0000000000000162 <strchr>:
 162:	1141                	addi	sp,sp,-16
 164:	e422                	sd	s0,8(sp)
 166:	0800                	addi	s0,sp,16
 168:	00054783          	lbu	a5,0(a0)
 16c:	cb99                	beqz	a5,182 <strchr+0x20>
 16e:	00f58763          	beq	a1,a5,17c <strchr+0x1a>
 172:	0505                	addi	a0,a0,1
 174:	00054783          	lbu	a5,0(a0)
 178:	fbfd                	bnez	a5,16e <strchr+0xc>
 17a:	4501                	li	a0,0
 17c:	6422                	ld	s0,8(sp)
 17e:	0141                	addi	sp,sp,16
 180:	8082                	ret
 182:	4501                	li	a0,0
 184:	bfe5                	j	17c <strchr+0x1a>

0000000000000186 <gets>:
 186:	711d                	addi	sp,sp,-96
 188:	ec86                	sd	ra,88(sp)
 18a:	e8a2                	sd	s0,80(sp)
 18c:	e4a6                	sd	s1,72(sp)
 18e:	e0ca                	sd	s2,64(sp)
 190:	fc4e                	sd	s3,56(sp)
 192:	f852                	sd	s4,48(sp)
 194:	f456                	sd	s5,40(sp)
 196:	f05a                	sd	s6,32(sp)
 198:	ec5e                	sd	s7,24(sp)
 19a:	1080                	addi	s0,sp,96
 19c:	8baa                	mv	s7,a0
 19e:	8a2e                	mv	s4,a1
 1a0:	892a                	mv	s2,a0
 1a2:	4481                	li	s1,0
 1a4:	4aa9                	li	s5,10
 1a6:	4b35                	li	s6,13
 1a8:	89a6                	mv	s3,s1
 1aa:	2485                	addiw	s1,s1,1
 1ac:	0344d863          	bge	s1,s4,1dc <gets+0x56>
 1b0:	4605                	li	a2,1
 1b2:	faf40593          	addi	a1,s0,-81
 1b6:	4501                	li	a0,0
 1b8:	00000097          	auipc	ra,0x0
 1bc:	1a0080e7          	jalr	416(ra) # 358 <read>
 1c0:	00a05e63          	blez	a0,1dc <gets+0x56>
 1c4:	faf44783          	lbu	a5,-81(s0)
 1c8:	00f90023          	sb	a5,0(s2)
 1cc:	01578763          	beq	a5,s5,1da <gets+0x54>
 1d0:	0905                	addi	s2,s2,1
 1d2:	fd679be3          	bne	a5,s6,1a8 <gets+0x22>
 1d6:	89a6                	mv	s3,s1
 1d8:	a011                	j	1dc <gets+0x56>
 1da:	89a6                	mv	s3,s1
 1dc:	99de                	add	s3,s3,s7
 1de:	00098023          	sb	zero,0(s3)
 1e2:	855e                	mv	a0,s7
 1e4:	60e6                	ld	ra,88(sp)
 1e6:	6446                	ld	s0,80(sp)
 1e8:	64a6                	ld	s1,72(sp)
 1ea:	6906                	ld	s2,64(sp)
 1ec:	79e2                	ld	s3,56(sp)
 1ee:	7a42                	ld	s4,48(sp)
 1f0:	7aa2                	ld	s5,40(sp)
 1f2:	7b02                	ld	s6,32(sp)
 1f4:	6be2                	ld	s7,24(sp)
 1f6:	6125                	addi	sp,sp,96
 1f8:	8082                	ret

00000000000001fa <stat>:
 1fa:	1101                	addi	sp,sp,-32
 1fc:	ec06                	sd	ra,24(sp)
 1fe:	e822                	sd	s0,16(sp)
 200:	e426                	sd	s1,8(sp)
 202:	e04a                	sd	s2,0(sp)
 204:	1000                	addi	s0,sp,32
 206:	892e                	mv	s2,a1
 208:	4581                	li	a1,0
 20a:	00000097          	auipc	ra,0x0
 20e:	176080e7          	jalr	374(ra) # 380 <open>
 212:	02054563          	bltz	a0,23c <stat+0x42>
 216:	84aa                	mv	s1,a0
 218:	85ca                	mv	a1,s2
 21a:	00000097          	auipc	ra,0x0
 21e:	17e080e7          	jalr	382(ra) # 398 <fstat>
 222:	892a                	mv	s2,a0
 224:	8526                	mv	a0,s1
 226:	00000097          	auipc	ra,0x0
 22a:	142080e7          	jalr	322(ra) # 368 <close>
 22e:	854a                	mv	a0,s2
 230:	60e2                	ld	ra,24(sp)
 232:	6442                	ld	s0,16(sp)
 234:	64a2                	ld	s1,8(sp)
 236:	6902                	ld	s2,0(sp)
 238:	6105                	addi	sp,sp,32
 23a:	8082                	ret
 23c:	597d                	li	s2,-1
 23e:	bfc5                	j	22e <stat+0x34>

0000000000000240 <atoi>:
 240:	1141                	addi	sp,sp,-16
 242:	e422                	sd	s0,8(sp)
 244:	0800                	addi	s0,sp,16
 246:	00054603          	lbu	a2,0(a0)
 24a:	fd06079b          	addiw	a5,a2,-48
 24e:	0ff7f793          	andi	a5,a5,255
 252:	4725                	li	a4,9
 254:	02f76963          	bltu	a4,a5,286 <atoi+0x46>
 258:	86aa                	mv	a3,a0
 25a:	4501                	li	a0,0
 25c:	45a5                	li	a1,9
 25e:	0685                	addi	a3,a3,1
 260:	0025179b          	slliw	a5,a0,0x2
 264:	9fa9                	addw	a5,a5,a0
 266:	0017979b          	slliw	a5,a5,0x1
 26a:	9fb1                	addw	a5,a5,a2
 26c:	fd07851b          	addiw	a0,a5,-48
 270:	0006c603          	lbu	a2,0(a3)
 274:	fd06071b          	addiw	a4,a2,-48
 278:	0ff77713          	andi	a4,a4,255
 27c:	fee5f1e3          	bgeu	a1,a4,25e <atoi+0x1e>
 280:	6422                	ld	s0,8(sp)
 282:	0141                	addi	sp,sp,16
 284:	8082                	ret
 286:	4501                	li	a0,0
 288:	bfe5                	j	280 <atoi+0x40>

000000000000028a <memmove>:
 28a:	1141                	addi	sp,sp,-16
 28c:	e422                	sd	s0,8(sp)
 28e:	0800                	addi	s0,sp,16
 290:	02b57663          	bgeu	a0,a1,2bc <memmove+0x32>
 294:	02c05163          	blez	a2,2b6 <memmove+0x2c>
 298:	fff6079b          	addiw	a5,a2,-1
 29c:	1782                	slli	a5,a5,0x20
 29e:	9381                	srli	a5,a5,0x20
 2a0:	0785                	addi	a5,a5,1
 2a2:	97aa                	add	a5,a5,a0
 2a4:	872a                	mv	a4,a0
 2a6:	0585                	addi	a1,a1,1
 2a8:	0705                	addi	a4,a4,1
 2aa:	fff5c683          	lbu	a3,-1(a1)
 2ae:	fed70fa3          	sb	a3,-1(a4)
 2b2:	fee79ae3          	bne	a5,a4,2a6 <memmove+0x1c>
 2b6:	6422                	ld	s0,8(sp)
 2b8:	0141                	addi	sp,sp,16
 2ba:	8082                	ret
 2bc:	00c50733          	add	a4,a0,a2
 2c0:	95b2                	add	a1,a1,a2
 2c2:	fec05ae3          	blez	a2,2b6 <memmove+0x2c>
 2c6:	fff6079b          	addiw	a5,a2,-1
 2ca:	1782                	slli	a5,a5,0x20
 2cc:	9381                	srli	a5,a5,0x20
 2ce:	fff7c793          	not	a5,a5
 2d2:	97ba                	add	a5,a5,a4
 2d4:	15fd                	addi	a1,a1,-1
 2d6:	177d                	addi	a4,a4,-1
 2d8:	0005c683          	lbu	a3,0(a1)
 2dc:	00d70023          	sb	a3,0(a4)
 2e0:	fee79ae3          	bne	a5,a4,2d4 <memmove+0x4a>
 2e4:	bfc9                	j	2b6 <memmove+0x2c>

00000000000002e6 <memcmp>:
 2e6:	1141                	addi	sp,sp,-16
 2e8:	e422                	sd	s0,8(sp)
 2ea:	0800                	addi	s0,sp,16
 2ec:	ca05                	beqz	a2,31c <memcmp+0x36>
 2ee:	fff6069b          	addiw	a3,a2,-1
 2f2:	1682                	slli	a3,a3,0x20
 2f4:	9281                	srli	a3,a3,0x20
 2f6:	0685                	addi	a3,a3,1
 2f8:	96aa                	add	a3,a3,a0
 2fa:	00054783          	lbu	a5,0(a0)
 2fe:	0005c703          	lbu	a4,0(a1)
 302:	00e79863          	bne	a5,a4,312 <memcmp+0x2c>
 306:	0505                	addi	a0,a0,1
 308:	0585                	addi	a1,a1,1
 30a:	fed518e3          	bne	a0,a3,2fa <memcmp+0x14>
 30e:	4501                	li	a0,0
 310:	a019                	j	316 <memcmp+0x30>
 312:	40e7853b          	subw	a0,a5,a4
 316:	6422                	ld	s0,8(sp)
 318:	0141                	addi	sp,sp,16
 31a:	8082                	ret
 31c:	4501                	li	a0,0
 31e:	bfe5                	j	316 <memcmp+0x30>

0000000000000320 <memcpy>:
 320:	1141                	addi	sp,sp,-16
 322:	e406                	sd	ra,8(sp)
 324:	e022                	sd	s0,0(sp)
 326:	0800                	addi	s0,sp,16
 328:	00000097          	auipc	ra,0x0
 32c:	f62080e7          	jalr	-158(ra) # 28a <memmove>
 330:	60a2                	ld	ra,8(sp)
 332:	6402                	ld	s0,0(sp)
 334:	0141                	addi	sp,sp,16
 336:	8082                	ret

0000000000000338 <fork>:
 338:	4885                	li	a7,1
 33a:	00000073          	ecall
 33e:	8082                	ret

0000000000000340 <exit>:
 340:	4889                	li	a7,2
 342:	00000073          	ecall
 346:	8082                	ret

0000000000000348 <wait>:
 348:	488d                	li	a7,3
 34a:	00000073          	ecall
 34e:	8082                	ret

0000000000000350 <pipe>:
 350:	4891                	li	a7,4
 352:	00000073          	ecall
 356:	8082                	ret

0000000000000358 <read>:
 358:	4895                	li	a7,5
 35a:	00000073          	ecall
 35e:	8082                	ret

0000000000000360 <write>:
 360:	48c1                	li	a7,16
 362:	00000073          	ecall
 366:	8082                	ret

0000000000000368 <close>:
 368:	48d5                	li	a7,21
 36a:	00000073          	ecall
 36e:	8082                	ret

0000000000000370 <kill>:
 370:	4899                	li	a7,6
 372:	00000073          	ecall
 376:	8082                	ret

0000000000000378 <exec>:
 378:	489d                	li	a7,7
 37a:	00000073          	ecall
 37e:	8082                	ret

0000000000000380 <open>:
 380:	48bd                	li	a7,15
 382:	00000073          	ecall
 386:	8082                	ret

0000000000000388 <mknod>:
 388:	48c5                	li	a7,17
 38a:	00000073          	ecall
 38e:	8082                	ret

0000000000000390 <unlink>:
 390:	48c9                	li	a7,18
 392:	00000073          	ecall
 396:	8082                	ret

0000000000000398 <fstat>:
 398:	48a1                	li	a7,8
 39a:	00000073          	ecall
 39e:	8082                	ret

00000000000003a0 <link>:
 3a0:	48cd                	li	a7,19
 3a2:	00000073          	ecall
 3a6:	8082                	ret

00000000000003a8 <mkdir>:
 3a8:	48d1                	li	a7,20
 3aa:	00000073          	ecall
 3ae:	8082                	ret

00000000000003b0 <chdir>:
 3b0:	48a5                	li	a7,9
 3b2:	00000073          	ecall
 3b6:	8082                	ret

00000000000003b8 <dup>:
 3b8:	48a9                	li	a7,10
 3ba:	00000073          	ecall
 3be:	8082                	ret

00000000000003c0 <getpid>:
 3c0:	48ad                	li	a7,11
 3c2:	00000073          	ecall
 3c6:	8082                	ret

00000000000003c8 <sbrk>:
 3c8:	48b1                	li	a7,12
 3ca:	00000073          	ecall
 3ce:	8082                	ret

00000000000003d0 <sleep>:
 3d0:	48b5                	li	a7,13
 3d2:	00000073          	ecall
 3d6:	8082                	ret

00000000000003d8 <uptime>:
 3d8:	48b9                	li	a7,14
 3da:	00000073          	ecall
 3de:	8082                	ret

00000000000003e0 <trace>:
 3e0:	48d9                	li	a7,22
 3e2:	00000073          	ecall
 3e6:	8082                	ret

00000000000003e8 <setpriority>:
 3e8:	48e1                	li	a7,24
 3ea:	00000073          	ecall
 3ee:	8082                	ret

00000000000003f0 <waitx>:
 3f0:	48e9                	li	a7,26
 3f2:	00000073          	ecall
 3f6:	8082                	ret

00000000000003f8 <sigalarm>:
 3f8:	48dd                	li	a7,23
 3fa:	00000073          	ecall
 3fe:	8082                	ret

0000000000000400 <sigreturn>:
 400:	48ed                	li	a7,27
 402:	00000073          	ecall
 406:	8082                	ret

0000000000000408 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 408:	1101                	addi	sp,sp,-32
 40a:	ec06                	sd	ra,24(sp)
 40c:	e822                	sd	s0,16(sp)
 40e:	1000                	addi	s0,sp,32
 410:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 414:	4605                	li	a2,1
 416:	fef40593          	addi	a1,s0,-17
 41a:	00000097          	auipc	ra,0x0
 41e:	f46080e7          	jalr	-186(ra) # 360 <write>
}
 422:	60e2                	ld	ra,24(sp)
 424:	6442                	ld	s0,16(sp)
 426:	6105                	addi	sp,sp,32
 428:	8082                	ret

000000000000042a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 42a:	7139                	addi	sp,sp,-64
 42c:	fc06                	sd	ra,56(sp)
 42e:	f822                	sd	s0,48(sp)
 430:	f426                	sd	s1,40(sp)
 432:	f04a                	sd	s2,32(sp)
 434:	ec4e                	sd	s3,24(sp)
 436:	0080                	addi	s0,sp,64
 438:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 43a:	c299                	beqz	a3,440 <printint+0x16>
 43c:	0805c863          	bltz	a1,4cc <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 440:	2581                	sext.w	a1,a1
  neg = 0;
 442:	4881                	li	a7,0
 444:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 448:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 44a:	2601                	sext.w	a2,a2
 44c:	00000517          	auipc	a0,0x0
 450:	46c50513          	addi	a0,a0,1132 # 8b8 <digits>
 454:	883a                	mv	a6,a4
 456:	2705                	addiw	a4,a4,1
 458:	02c5f7bb          	remuw	a5,a1,a2
 45c:	1782                	slli	a5,a5,0x20
 45e:	9381                	srli	a5,a5,0x20
 460:	97aa                	add	a5,a5,a0
 462:	0007c783          	lbu	a5,0(a5)
 466:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 46a:	0005879b          	sext.w	a5,a1
 46e:	02c5d5bb          	divuw	a1,a1,a2
 472:	0685                	addi	a3,a3,1
 474:	fec7f0e3          	bgeu	a5,a2,454 <printint+0x2a>
  if(neg)
 478:	00088b63          	beqz	a7,48e <printint+0x64>
    buf[i++] = '-';
 47c:	fd040793          	addi	a5,s0,-48
 480:	973e                	add	a4,a4,a5
 482:	02d00793          	li	a5,45
 486:	fef70823          	sb	a5,-16(a4)
 48a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 48e:	02e05863          	blez	a4,4be <printint+0x94>
 492:	fc040793          	addi	a5,s0,-64
 496:	00e78933          	add	s2,a5,a4
 49a:	fff78993          	addi	s3,a5,-1
 49e:	99ba                	add	s3,s3,a4
 4a0:	377d                	addiw	a4,a4,-1
 4a2:	1702                	slli	a4,a4,0x20
 4a4:	9301                	srli	a4,a4,0x20
 4a6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4aa:	fff94583          	lbu	a1,-1(s2)
 4ae:	8526                	mv	a0,s1
 4b0:	00000097          	auipc	ra,0x0
 4b4:	f58080e7          	jalr	-168(ra) # 408 <putc>
  while(--i >= 0)
 4b8:	197d                	addi	s2,s2,-1
 4ba:	ff3918e3          	bne	s2,s3,4aa <printint+0x80>
}
 4be:	70e2                	ld	ra,56(sp)
 4c0:	7442                	ld	s0,48(sp)
 4c2:	74a2                	ld	s1,40(sp)
 4c4:	7902                	ld	s2,32(sp)
 4c6:	69e2                	ld	s3,24(sp)
 4c8:	6121                	addi	sp,sp,64
 4ca:	8082                	ret
    x = -xx;
 4cc:	40b005bb          	negw	a1,a1
    neg = 1;
 4d0:	4885                	li	a7,1
    x = -xx;
 4d2:	bf8d                	j	444 <printint+0x1a>

00000000000004d4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4d4:	7119                	addi	sp,sp,-128
 4d6:	fc86                	sd	ra,120(sp)
 4d8:	f8a2                	sd	s0,112(sp)
 4da:	f4a6                	sd	s1,104(sp)
 4dc:	f0ca                	sd	s2,96(sp)
 4de:	ecce                	sd	s3,88(sp)
 4e0:	e8d2                	sd	s4,80(sp)
 4e2:	e4d6                	sd	s5,72(sp)
 4e4:	e0da                	sd	s6,64(sp)
 4e6:	fc5e                	sd	s7,56(sp)
 4e8:	f862                	sd	s8,48(sp)
 4ea:	f466                	sd	s9,40(sp)
 4ec:	f06a                	sd	s10,32(sp)
 4ee:	ec6e                	sd	s11,24(sp)
 4f0:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4f2:	0005c903          	lbu	s2,0(a1)
 4f6:	18090f63          	beqz	s2,694 <vprintf+0x1c0>
 4fa:	8aaa                	mv	s5,a0
 4fc:	8b32                	mv	s6,a2
 4fe:	00158493          	addi	s1,a1,1
  state = 0;
 502:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 504:	02500a13          	li	s4,37
      if(c == 'd'){
 508:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 50c:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 510:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 514:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 518:	00000b97          	auipc	s7,0x0
 51c:	3a0b8b93          	addi	s7,s7,928 # 8b8 <digits>
 520:	a839                	j	53e <vprintf+0x6a>
        putc(fd, c);
 522:	85ca                	mv	a1,s2
 524:	8556                	mv	a0,s5
 526:	00000097          	auipc	ra,0x0
 52a:	ee2080e7          	jalr	-286(ra) # 408 <putc>
 52e:	a019                	j	534 <vprintf+0x60>
    } else if(state == '%'){
 530:	01498f63          	beq	s3,s4,54e <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 534:	0485                	addi	s1,s1,1
 536:	fff4c903          	lbu	s2,-1(s1)
 53a:	14090d63          	beqz	s2,694 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 53e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 542:	fe0997e3          	bnez	s3,530 <vprintf+0x5c>
      if(c == '%'){
 546:	fd479ee3          	bne	a5,s4,522 <vprintf+0x4e>
        state = '%';
 54a:	89be                	mv	s3,a5
 54c:	b7e5                	j	534 <vprintf+0x60>
      if(c == 'd'){
 54e:	05878063          	beq	a5,s8,58e <vprintf+0xba>
      } else if(c == 'l') {
 552:	05978c63          	beq	a5,s9,5aa <vprintf+0xd6>
      } else if(c == 'x') {
 556:	07a78863          	beq	a5,s10,5c6 <vprintf+0xf2>
      } else if(c == 'p') {
 55a:	09b78463          	beq	a5,s11,5e2 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 55e:	07300713          	li	a4,115
 562:	0ce78663          	beq	a5,a4,62e <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 566:	06300713          	li	a4,99
 56a:	0ee78e63          	beq	a5,a4,666 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 56e:	11478863          	beq	a5,s4,67e <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 572:	85d2                	mv	a1,s4
 574:	8556                	mv	a0,s5
 576:	00000097          	auipc	ra,0x0
 57a:	e92080e7          	jalr	-366(ra) # 408 <putc>
        putc(fd, c);
 57e:	85ca                	mv	a1,s2
 580:	8556                	mv	a0,s5
 582:	00000097          	auipc	ra,0x0
 586:	e86080e7          	jalr	-378(ra) # 408 <putc>
      }
      state = 0;
 58a:	4981                	li	s3,0
 58c:	b765                	j	534 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 58e:	008b0913          	addi	s2,s6,8
 592:	4685                	li	a3,1
 594:	4629                	li	a2,10
 596:	000b2583          	lw	a1,0(s6)
 59a:	8556                	mv	a0,s5
 59c:	00000097          	auipc	ra,0x0
 5a0:	e8e080e7          	jalr	-370(ra) # 42a <printint>
 5a4:	8b4a                	mv	s6,s2
      state = 0;
 5a6:	4981                	li	s3,0
 5a8:	b771                	j	534 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5aa:	008b0913          	addi	s2,s6,8
 5ae:	4681                	li	a3,0
 5b0:	4629                	li	a2,10
 5b2:	000b2583          	lw	a1,0(s6)
 5b6:	8556                	mv	a0,s5
 5b8:	00000097          	auipc	ra,0x0
 5bc:	e72080e7          	jalr	-398(ra) # 42a <printint>
 5c0:	8b4a                	mv	s6,s2
      state = 0;
 5c2:	4981                	li	s3,0
 5c4:	bf85                	j	534 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5c6:	008b0913          	addi	s2,s6,8
 5ca:	4681                	li	a3,0
 5cc:	4641                	li	a2,16
 5ce:	000b2583          	lw	a1,0(s6)
 5d2:	8556                	mv	a0,s5
 5d4:	00000097          	auipc	ra,0x0
 5d8:	e56080e7          	jalr	-426(ra) # 42a <printint>
 5dc:	8b4a                	mv	s6,s2
      state = 0;
 5de:	4981                	li	s3,0
 5e0:	bf91                	j	534 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5e2:	008b0793          	addi	a5,s6,8
 5e6:	f8f43423          	sd	a5,-120(s0)
 5ea:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 5ee:	03000593          	li	a1,48
 5f2:	8556                	mv	a0,s5
 5f4:	00000097          	auipc	ra,0x0
 5f8:	e14080e7          	jalr	-492(ra) # 408 <putc>
  putc(fd, 'x');
 5fc:	85ea                	mv	a1,s10
 5fe:	8556                	mv	a0,s5
 600:	00000097          	auipc	ra,0x0
 604:	e08080e7          	jalr	-504(ra) # 408 <putc>
 608:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 60a:	03c9d793          	srli	a5,s3,0x3c
 60e:	97de                	add	a5,a5,s7
 610:	0007c583          	lbu	a1,0(a5)
 614:	8556                	mv	a0,s5
 616:	00000097          	auipc	ra,0x0
 61a:	df2080e7          	jalr	-526(ra) # 408 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 61e:	0992                	slli	s3,s3,0x4
 620:	397d                	addiw	s2,s2,-1
 622:	fe0914e3          	bnez	s2,60a <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 626:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 62a:	4981                	li	s3,0
 62c:	b721                	j	534 <vprintf+0x60>
        s = va_arg(ap, char*);
 62e:	008b0993          	addi	s3,s6,8
 632:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 636:	02090163          	beqz	s2,658 <vprintf+0x184>
        while(*s != 0){
 63a:	00094583          	lbu	a1,0(s2)
 63e:	c9a1                	beqz	a1,68e <vprintf+0x1ba>
          putc(fd, *s);
 640:	8556                	mv	a0,s5
 642:	00000097          	auipc	ra,0x0
 646:	dc6080e7          	jalr	-570(ra) # 408 <putc>
          s++;
 64a:	0905                	addi	s2,s2,1
        while(*s != 0){
 64c:	00094583          	lbu	a1,0(s2)
 650:	f9e5                	bnez	a1,640 <vprintf+0x16c>
        s = va_arg(ap, char*);
 652:	8b4e                	mv	s6,s3
      state = 0;
 654:	4981                	li	s3,0
 656:	bdf9                	j	534 <vprintf+0x60>
          s = "(null)";
 658:	00000917          	auipc	s2,0x0
 65c:	25890913          	addi	s2,s2,600 # 8b0 <malloc+0x112>
        while(*s != 0){
 660:	02800593          	li	a1,40
 664:	bff1                	j	640 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 666:	008b0913          	addi	s2,s6,8
 66a:	000b4583          	lbu	a1,0(s6)
 66e:	8556                	mv	a0,s5
 670:	00000097          	auipc	ra,0x0
 674:	d98080e7          	jalr	-616(ra) # 408 <putc>
 678:	8b4a                	mv	s6,s2
      state = 0;
 67a:	4981                	li	s3,0
 67c:	bd65                	j	534 <vprintf+0x60>
        putc(fd, c);
 67e:	85d2                	mv	a1,s4
 680:	8556                	mv	a0,s5
 682:	00000097          	auipc	ra,0x0
 686:	d86080e7          	jalr	-634(ra) # 408 <putc>
      state = 0;
 68a:	4981                	li	s3,0
 68c:	b565                	j	534 <vprintf+0x60>
        s = va_arg(ap, char*);
 68e:	8b4e                	mv	s6,s3
      state = 0;
 690:	4981                	li	s3,0
 692:	b54d                	j	534 <vprintf+0x60>
    }
  }
}
 694:	70e6                	ld	ra,120(sp)
 696:	7446                	ld	s0,112(sp)
 698:	74a6                	ld	s1,104(sp)
 69a:	7906                	ld	s2,96(sp)
 69c:	69e6                	ld	s3,88(sp)
 69e:	6a46                	ld	s4,80(sp)
 6a0:	6aa6                	ld	s5,72(sp)
 6a2:	6b06                	ld	s6,64(sp)
 6a4:	7be2                	ld	s7,56(sp)
 6a6:	7c42                	ld	s8,48(sp)
 6a8:	7ca2                	ld	s9,40(sp)
 6aa:	7d02                	ld	s10,32(sp)
 6ac:	6de2                	ld	s11,24(sp)
 6ae:	6109                	addi	sp,sp,128
 6b0:	8082                	ret

00000000000006b2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6b2:	715d                	addi	sp,sp,-80
 6b4:	ec06                	sd	ra,24(sp)
 6b6:	e822                	sd	s0,16(sp)
 6b8:	1000                	addi	s0,sp,32
 6ba:	e010                	sd	a2,0(s0)
 6bc:	e414                	sd	a3,8(s0)
 6be:	e818                	sd	a4,16(s0)
 6c0:	ec1c                	sd	a5,24(s0)
 6c2:	03043023          	sd	a6,32(s0)
 6c6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6ca:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6ce:	8622                	mv	a2,s0
 6d0:	00000097          	auipc	ra,0x0
 6d4:	e04080e7          	jalr	-508(ra) # 4d4 <vprintf>
}
 6d8:	60e2                	ld	ra,24(sp)
 6da:	6442                	ld	s0,16(sp)
 6dc:	6161                	addi	sp,sp,80
 6de:	8082                	ret

00000000000006e0 <printf>:

void
printf(const char *fmt, ...)
{
 6e0:	711d                	addi	sp,sp,-96
 6e2:	ec06                	sd	ra,24(sp)
 6e4:	e822                	sd	s0,16(sp)
 6e6:	1000                	addi	s0,sp,32
 6e8:	e40c                	sd	a1,8(s0)
 6ea:	e810                	sd	a2,16(s0)
 6ec:	ec14                	sd	a3,24(s0)
 6ee:	f018                	sd	a4,32(s0)
 6f0:	f41c                	sd	a5,40(s0)
 6f2:	03043823          	sd	a6,48(s0)
 6f6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6fa:	00840613          	addi	a2,s0,8
 6fe:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 702:	85aa                	mv	a1,a0
 704:	4505                	li	a0,1
 706:	00000097          	auipc	ra,0x0
 70a:	dce080e7          	jalr	-562(ra) # 4d4 <vprintf>
}
 70e:	60e2                	ld	ra,24(sp)
 710:	6442                	ld	s0,16(sp)
 712:	6125                	addi	sp,sp,96
 714:	8082                	ret

0000000000000716 <free>:
 716:	1141                	addi	sp,sp,-16
 718:	e422                	sd	s0,8(sp)
 71a:	0800                	addi	s0,sp,16
 71c:	ff050693          	addi	a3,a0,-16
 720:	00001797          	auipc	a5,0x1
 724:	8e07b783          	ld	a5,-1824(a5) # 1000 <freep>
 728:	a805                	j	758 <free+0x42>
 72a:	4618                	lw	a4,8(a2)
 72c:	9db9                	addw	a1,a1,a4
 72e:	feb52c23          	sw	a1,-8(a0)
 732:	6398                	ld	a4,0(a5)
 734:	6318                	ld	a4,0(a4)
 736:	fee53823          	sd	a4,-16(a0)
 73a:	a091                	j	77e <free+0x68>
 73c:	ff852703          	lw	a4,-8(a0)
 740:	9e39                	addw	a2,a2,a4
 742:	c790                	sw	a2,8(a5)
 744:	ff053703          	ld	a4,-16(a0)
 748:	e398                	sd	a4,0(a5)
 74a:	a099                	j	790 <free+0x7a>
 74c:	6398                	ld	a4,0(a5)
 74e:	00e7e463          	bltu	a5,a4,756 <free+0x40>
 752:	00e6ea63          	bltu	a3,a4,766 <free+0x50>
 756:	87ba                	mv	a5,a4
 758:	fed7fae3          	bgeu	a5,a3,74c <free+0x36>
 75c:	6398                	ld	a4,0(a5)
 75e:	00e6e463          	bltu	a3,a4,766 <free+0x50>
 762:	fee7eae3          	bltu	a5,a4,756 <free+0x40>
 766:	ff852583          	lw	a1,-8(a0)
 76a:	6390                	ld	a2,0(a5)
 76c:	02059713          	slli	a4,a1,0x20
 770:	9301                	srli	a4,a4,0x20
 772:	0712                	slli	a4,a4,0x4
 774:	9736                	add	a4,a4,a3
 776:	fae60ae3          	beq	a2,a4,72a <free+0x14>
 77a:	fec53823          	sd	a2,-16(a0)
 77e:	4790                	lw	a2,8(a5)
 780:	02061713          	slli	a4,a2,0x20
 784:	9301                	srli	a4,a4,0x20
 786:	0712                	slli	a4,a4,0x4
 788:	973e                	add	a4,a4,a5
 78a:	fae689e3          	beq	a3,a4,73c <free+0x26>
 78e:	e394                	sd	a3,0(a5)
 790:	00001717          	auipc	a4,0x1
 794:	86f73823          	sd	a5,-1936(a4) # 1000 <freep>
 798:	6422                	ld	s0,8(sp)
 79a:	0141                	addi	sp,sp,16
 79c:	8082                	ret

000000000000079e <malloc>:
 79e:	7139                	addi	sp,sp,-64
 7a0:	fc06                	sd	ra,56(sp)
 7a2:	f822                	sd	s0,48(sp)
 7a4:	f426                	sd	s1,40(sp)
 7a6:	f04a                	sd	s2,32(sp)
 7a8:	ec4e                	sd	s3,24(sp)
 7aa:	e852                	sd	s4,16(sp)
 7ac:	e456                	sd	s5,8(sp)
 7ae:	e05a                	sd	s6,0(sp)
 7b0:	0080                	addi	s0,sp,64
 7b2:	02051493          	slli	s1,a0,0x20
 7b6:	9081                	srli	s1,s1,0x20
 7b8:	04bd                	addi	s1,s1,15
 7ba:	8091                	srli	s1,s1,0x4
 7bc:	0014899b          	addiw	s3,s1,1
 7c0:	0485                	addi	s1,s1,1
 7c2:	00001517          	auipc	a0,0x1
 7c6:	83e53503          	ld	a0,-1986(a0) # 1000 <freep>
 7ca:	c515                	beqz	a0,7f6 <malloc+0x58>
 7cc:	611c                	ld	a5,0(a0)
 7ce:	4798                	lw	a4,8(a5)
 7d0:	02977f63          	bgeu	a4,s1,80e <malloc+0x70>
 7d4:	8a4e                	mv	s4,s3
 7d6:	0009871b          	sext.w	a4,s3
 7da:	6685                	lui	a3,0x1
 7dc:	00d77363          	bgeu	a4,a3,7e2 <malloc+0x44>
 7e0:	6a05                	lui	s4,0x1
 7e2:	000a0b1b          	sext.w	s6,s4
 7e6:	004a1a1b          	slliw	s4,s4,0x4
 7ea:	00001917          	auipc	s2,0x1
 7ee:	81690913          	addi	s2,s2,-2026 # 1000 <freep>
 7f2:	5afd                	li	s5,-1
 7f4:	a88d                	j	866 <malloc+0xc8>
 7f6:	00001797          	auipc	a5,0x1
 7fa:	81a78793          	addi	a5,a5,-2022 # 1010 <base>
 7fe:	00001717          	auipc	a4,0x1
 802:	80f73123          	sd	a5,-2046(a4) # 1000 <freep>
 806:	e39c                	sd	a5,0(a5)
 808:	0007a423          	sw	zero,8(a5)
 80c:	b7e1                	j	7d4 <malloc+0x36>
 80e:	02e48b63          	beq	s1,a4,844 <malloc+0xa6>
 812:	4137073b          	subw	a4,a4,s3
 816:	c798                	sw	a4,8(a5)
 818:	1702                	slli	a4,a4,0x20
 81a:	9301                	srli	a4,a4,0x20
 81c:	0712                	slli	a4,a4,0x4
 81e:	97ba                	add	a5,a5,a4
 820:	0137a423          	sw	s3,8(a5)
 824:	00000717          	auipc	a4,0x0
 828:	7ca73e23          	sd	a0,2012(a4) # 1000 <freep>
 82c:	01078513          	addi	a0,a5,16
 830:	70e2                	ld	ra,56(sp)
 832:	7442                	ld	s0,48(sp)
 834:	74a2                	ld	s1,40(sp)
 836:	7902                	ld	s2,32(sp)
 838:	69e2                	ld	s3,24(sp)
 83a:	6a42                	ld	s4,16(sp)
 83c:	6aa2                	ld	s5,8(sp)
 83e:	6b02                	ld	s6,0(sp)
 840:	6121                	addi	sp,sp,64
 842:	8082                	ret
 844:	6398                	ld	a4,0(a5)
 846:	e118                	sd	a4,0(a0)
 848:	bff1                	j	824 <malloc+0x86>
 84a:	01652423          	sw	s6,8(a0)
 84e:	0541                	addi	a0,a0,16
 850:	00000097          	auipc	ra,0x0
 854:	ec6080e7          	jalr	-314(ra) # 716 <free>
 858:	00093503          	ld	a0,0(s2)
 85c:	d971                	beqz	a0,830 <malloc+0x92>
 85e:	611c                	ld	a5,0(a0)
 860:	4798                	lw	a4,8(a5)
 862:	fa9776e3          	bgeu	a4,s1,80e <malloc+0x70>
 866:	00093703          	ld	a4,0(s2)
 86a:	853e                	mv	a0,a5
 86c:	fef719e3          	bne	a4,a5,85e <malloc+0xc0>
 870:	8552                	mv	a0,s4
 872:	00000097          	auipc	ra,0x0
 876:	b56080e7          	jalr	-1194(ra) # 3c8 <sbrk>
 87a:	fd5518e3          	bne	a0,s5,84a <malloc+0xac>
 87e:	4501                	li	a0,0
 880:	bf45                	j	830 <malloc+0x92>
