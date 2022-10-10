
user/_rm:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	4785                	li	a5,1
  10:	02a7d763          	bge	a5,a0,3e <main+0x3e>
  14:	00858493          	addi	s1,a1,8
  18:	ffe5091b          	addiw	s2,a0,-2
  1c:	1902                	slli	s2,s2,0x20
  1e:	02095913          	srli	s2,s2,0x20
  22:	090e                	slli	s2,s2,0x3
  24:	05c1                	addi	a1,a1,16
  26:	992e                	add	s2,s2,a1
  28:	6088                	ld	a0,0(s1)
  2a:	00000097          	auipc	ra,0x0
  2e:	32e080e7          	jalr	814(ra) # 358 <unlink>
  32:	02054463          	bltz	a0,5a <main+0x5a>
  36:	04a1                	addi	s1,s1,8
  38:	ff2498e3          	bne	s1,s2,28 <main+0x28>
  3c:	a80d                	j	6e <main+0x6e>
  3e:	00000597          	auipc	a1,0x0
  42:	7f258593          	addi	a1,a1,2034 # 830 <malloc+0xea>
  46:	4509                	li	a0,2
  48:	00000097          	auipc	ra,0x0
  4c:	612080e7          	jalr	1554(ra) # 65a <fprintf>
  50:	4505                	li	a0,1
  52:	00000097          	auipc	ra,0x0
  56:	2b6080e7          	jalr	694(ra) # 308 <exit>
  5a:	6090                	ld	a2,0(s1)
  5c:	00000597          	auipc	a1,0x0
  60:	7ec58593          	addi	a1,a1,2028 # 848 <malloc+0x102>
  64:	4509                	li	a0,2
  66:	00000097          	auipc	ra,0x0
  6a:	5f4080e7          	jalr	1524(ra) # 65a <fprintf>
  6e:	4501                	li	a0,0
  70:	00000097          	auipc	ra,0x0
  74:	298080e7          	jalr	664(ra) # 308 <exit>

0000000000000078 <_main>:
  78:	1141                	addi	sp,sp,-16
  7a:	e406                	sd	ra,8(sp)
  7c:	e022                	sd	s0,0(sp)
  7e:	0800                	addi	s0,sp,16
  80:	00000097          	auipc	ra,0x0
  84:	f80080e7          	jalr	-128(ra) # 0 <main>
  88:	4501                	li	a0,0
  8a:	00000097          	auipc	ra,0x0
  8e:	27e080e7          	jalr	638(ra) # 308 <exit>

0000000000000092 <strcpy>:
  92:	1141                	addi	sp,sp,-16
  94:	e422                	sd	s0,8(sp)
  96:	0800                	addi	s0,sp,16
  98:	87aa                	mv	a5,a0
  9a:	0585                	addi	a1,a1,1
  9c:	0785                	addi	a5,a5,1
  9e:	fff5c703          	lbu	a4,-1(a1)
  a2:	fee78fa3          	sb	a4,-1(a5)
  a6:	fb75                	bnez	a4,9a <strcpy+0x8>
  a8:	6422                	ld	s0,8(sp)
  aa:	0141                	addi	sp,sp,16
  ac:	8082                	ret

00000000000000ae <strcmp>:
  ae:	1141                	addi	sp,sp,-16
  b0:	e422                	sd	s0,8(sp)
  b2:	0800                	addi	s0,sp,16
  b4:	00054783          	lbu	a5,0(a0)
  b8:	cb91                	beqz	a5,cc <strcmp+0x1e>
  ba:	0005c703          	lbu	a4,0(a1)
  be:	00f71763          	bne	a4,a5,cc <strcmp+0x1e>
  c2:	0505                	addi	a0,a0,1
  c4:	0585                	addi	a1,a1,1
  c6:	00054783          	lbu	a5,0(a0)
  ca:	fbe5                	bnez	a5,ba <strcmp+0xc>
  cc:	0005c503          	lbu	a0,0(a1)
  d0:	40a7853b          	subw	a0,a5,a0
  d4:	6422                	ld	s0,8(sp)
  d6:	0141                	addi	sp,sp,16
  d8:	8082                	ret

00000000000000da <strlen>:
  da:	1141                	addi	sp,sp,-16
  dc:	e422                	sd	s0,8(sp)
  de:	0800                	addi	s0,sp,16
  e0:	00054783          	lbu	a5,0(a0)
  e4:	cf91                	beqz	a5,100 <strlen+0x26>
  e6:	0505                	addi	a0,a0,1
  e8:	87aa                	mv	a5,a0
  ea:	4685                	li	a3,1
  ec:	9e89                	subw	a3,a3,a0
  ee:	00f6853b          	addw	a0,a3,a5
  f2:	0785                	addi	a5,a5,1
  f4:	fff7c703          	lbu	a4,-1(a5)
  f8:	fb7d                	bnez	a4,ee <strlen+0x14>
  fa:	6422                	ld	s0,8(sp)
  fc:	0141                	addi	sp,sp,16
  fe:	8082                	ret
 100:	4501                	li	a0,0
 102:	bfe5                	j	fa <strlen+0x20>

0000000000000104 <memset>:
 104:	1141                	addi	sp,sp,-16
 106:	e422                	sd	s0,8(sp)
 108:	0800                	addi	s0,sp,16
 10a:	ce09                	beqz	a2,124 <memset+0x20>
 10c:	87aa                	mv	a5,a0
 10e:	fff6071b          	addiw	a4,a2,-1
 112:	1702                	slli	a4,a4,0x20
 114:	9301                	srli	a4,a4,0x20
 116:	0705                	addi	a4,a4,1
 118:	972a                	add	a4,a4,a0
 11a:	00b78023          	sb	a1,0(a5)
 11e:	0785                	addi	a5,a5,1
 120:	fee79de3          	bne	a5,a4,11a <memset+0x16>
 124:	6422                	ld	s0,8(sp)
 126:	0141                	addi	sp,sp,16
 128:	8082                	ret

000000000000012a <strchr>:
 12a:	1141                	addi	sp,sp,-16
 12c:	e422                	sd	s0,8(sp)
 12e:	0800                	addi	s0,sp,16
 130:	00054783          	lbu	a5,0(a0)
 134:	cb99                	beqz	a5,14a <strchr+0x20>
 136:	00f58763          	beq	a1,a5,144 <strchr+0x1a>
 13a:	0505                	addi	a0,a0,1
 13c:	00054783          	lbu	a5,0(a0)
 140:	fbfd                	bnez	a5,136 <strchr+0xc>
 142:	4501                	li	a0,0
 144:	6422                	ld	s0,8(sp)
 146:	0141                	addi	sp,sp,16
 148:	8082                	ret
 14a:	4501                	li	a0,0
 14c:	bfe5                	j	144 <strchr+0x1a>

000000000000014e <gets>:
 14e:	711d                	addi	sp,sp,-96
 150:	ec86                	sd	ra,88(sp)
 152:	e8a2                	sd	s0,80(sp)
 154:	e4a6                	sd	s1,72(sp)
 156:	e0ca                	sd	s2,64(sp)
 158:	fc4e                	sd	s3,56(sp)
 15a:	f852                	sd	s4,48(sp)
 15c:	f456                	sd	s5,40(sp)
 15e:	f05a                	sd	s6,32(sp)
 160:	ec5e                	sd	s7,24(sp)
 162:	1080                	addi	s0,sp,96
 164:	8baa                	mv	s7,a0
 166:	8a2e                	mv	s4,a1
 168:	892a                	mv	s2,a0
 16a:	4481                	li	s1,0
 16c:	4aa9                	li	s5,10
 16e:	4b35                	li	s6,13
 170:	89a6                	mv	s3,s1
 172:	2485                	addiw	s1,s1,1
 174:	0344d863          	bge	s1,s4,1a4 <gets+0x56>
 178:	4605                	li	a2,1
 17a:	faf40593          	addi	a1,s0,-81
 17e:	4501                	li	a0,0
 180:	00000097          	auipc	ra,0x0
 184:	1a0080e7          	jalr	416(ra) # 320 <read>
 188:	00a05e63          	blez	a0,1a4 <gets+0x56>
 18c:	faf44783          	lbu	a5,-81(s0)
 190:	00f90023          	sb	a5,0(s2)
 194:	01578763          	beq	a5,s5,1a2 <gets+0x54>
 198:	0905                	addi	s2,s2,1
 19a:	fd679be3          	bne	a5,s6,170 <gets+0x22>
 19e:	89a6                	mv	s3,s1
 1a0:	a011                	j	1a4 <gets+0x56>
 1a2:	89a6                	mv	s3,s1
 1a4:	99de                	add	s3,s3,s7
 1a6:	00098023          	sb	zero,0(s3)
 1aa:	855e                	mv	a0,s7
 1ac:	60e6                	ld	ra,88(sp)
 1ae:	6446                	ld	s0,80(sp)
 1b0:	64a6                	ld	s1,72(sp)
 1b2:	6906                	ld	s2,64(sp)
 1b4:	79e2                	ld	s3,56(sp)
 1b6:	7a42                	ld	s4,48(sp)
 1b8:	7aa2                	ld	s5,40(sp)
 1ba:	7b02                	ld	s6,32(sp)
 1bc:	6be2                	ld	s7,24(sp)
 1be:	6125                	addi	sp,sp,96
 1c0:	8082                	ret

00000000000001c2 <stat>:
 1c2:	1101                	addi	sp,sp,-32
 1c4:	ec06                	sd	ra,24(sp)
 1c6:	e822                	sd	s0,16(sp)
 1c8:	e426                	sd	s1,8(sp)
 1ca:	e04a                	sd	s2,0(sp)
 1cc:	1000                	addi	s0,sp,32
 1ce:	892e                	mv	s2,a1
 1d0:	4581                	li	a1,0
 1d2:	00000097          	auipc	ra,0x0
 1d6:	176080e7          	jalr	374(ra) # 348 <open>
 1da:	02054563          	bltz	a0,204 <stat+0x42>
 1de:	84aa                	mv	s1,a0
 1e0:	85ca                	mv	a1,s2
 1e2:	00000097          	auipc	ra,0x0
 1e6:	17e080e7          	jalr	382(ra) # 360 <fstat>
 1ea:	892a                	mv	s2,a0
 1ec:	8526                	mv	a0,s1
 1ee:	00000097          	auipc	ra,0x0
 1f2:	142080e7          	jalr	322(ra) # 330 <close>
 1f6:	854a                	mv	a0,s2
 1f8:	60e2                	ld	ra,24(sp)
 1fa:	6442                	ld	s0,16(sp)
 1fc:	64a2                	ld	s1,8(sp)
 1fe:	6902                	ld	s2,0(sp)
 200:	6105                	addi	sp,sp,32
 202:	8082                	ret
 204:	597d                	li	s2,-1
 206:	bfc5                	j	1f6 <stat+0x34>

0000000000000208 <atoi>:
 208:	1141                	addi	sp,sp,-16
 20a:	e422                	sd	s0,8(sp)
 20c:	0800                	addi	s0,sp,16
 20e:	00054603          	lbu	a2,0(a0)
 212:	fd06079b          	addiw	a5,a2,-48
 216:	0ff7f793          	andi	a5,a5,255
 21a:	4725                	li	a4,9
 21c:	02f76963          	bltu	a4,a5,24e <atoi+0x46>
 220:	86aa                	mv	a3,a0
 222:	4501                	li	a0,0
 224:	45a5                	li	a1,9
 226:	0685                	addi	a3,a3,1
 228:	0025179b          	slliw	a5,a0,0x2
 22c:	9fa9                	addw	a5,a5,a0
 22e:	0017979b          	slliw	a5,a5,0x1
 232:	9fb1                	addw	a5,a5,a2
 234:	fd07851b          	addiw	a0,a5,-48
 238:	0006c603          	lbu	a2,0(a3)
 23c:	fd06071b          	addiw	a4,a2,-48
 240:	0ff77713          	andi	a4,a4,255
 244:	fee5f1e3          	bgeu	a1,a4,226 <atoi+0x1e>
 248:	6422                	ld	s0,8(sp)
 24a:	0141                	addi	sp,sp,16
 24c:	8082                	ret
 24e:	4501                	li	a0,0
 250:	bfe5                	j	248 <atoi+0x40>

0000000000000252 <memmove>:
 252:	1141                	addi	sp,sp,-16
 254:	e422                	sd	s0,8(sp)
 256:	0800                	addi	s0,sp,16
 258:	02b57663          	bgeu	a0,a1,284 <memmove+0x32>
 25c:	02c05163          	blez	a2,27e <memmove+0x2c>
 260:	fff6079b          	addiw	a5,a2,-1
 264:	1782                	slli	a5,a5,0x20
 266:	9381                	srli	a5,a5,0x20
 268:	0785                	addi	a5,a5,1
 26a:	97aa                	add	a5,a5,a0
 26c:	872a                	mv	a4,a0
 26e:	0585                	addi	a1,a1,1
 270:	0705                	addi	a4,a4,1
 272:	fff5c683          	lbu	a3,-1(a1)
 276:	fed70fa3          	sb	a3,-1(a4)
 27a:	fee79ae3          	bne	a5,a4,26e <memmove+0x1c>
 27e:	6422                	ld	s0,8(sp)
 280:	0141                	addi	sp,sp,16
 282:	8082                	ret
 284:	00c50733          	add	a4,a0,a2
 288:	95b2                	add	a1,a1,a2
 28a:	fec05ae3          	blez	a2,27e <memmove+0x2c>
 28e:	fff6079b          	addiw	a5,a2,-1
 292:	1782                	slli	a5,a5,0x20
 294:	9381                	srli	a5,a5,0x20
 296:	fff7c793          	not	a5,a5
 29a:	97ba                	add	a5,a5,a4
 29c:	15fd                	addi	a1,a1,-1
 29e:	177d                	addi	a4,a4,-1
 2a0:	0005c683          	lbu	a3,0(a1)
 2a4:	00d70023          	sb	a3,0(a4)
 2a8:	fee79ae3          	bne	a5,a4,29c <memmove+0x4a>
 2ac:	bfc9                	j	27e <memmove+0x2c>

00000000000002ae <memcmp>:
 2ae:	1141                	addi	sp,sp,-16
 2b0:	e422                	sd	s0,8(sp)
 2b2:	0800                	addi	s0,sp,16
 2b4:	ca05                	beqz	a2,2e4 <memcmp+0x36>
 2b6:	fff6069b          	addiw	a3,a2,-1
 2ba:	1682                	slli	a3,a3,0x20
 2bc:	9281                	srli	a3,a3,0x20
 2be:	0685                	addi	a3,a3,1
 2c0:	96aa                	add	a3,a3,a0
 2c2:	00054783          	lbu	a5,0(a0)
 2c6:	0005c703          	lbu	a4,0(a1)
 2ca:	00e79863          	bne	a5,a4,2da <memcmp+0x2c>
 2ce:	0505                	addi	a0,a0,1
 2d0:	0585                	addi	a1,a1,1
 2d2:	fed518e3          	bne	a0,a3,2c2 <memcmp+0x14>
 2d6:	4501                	li	a0,0
 2d8:	a019                	j	2de <memcmp+0x30>
 2da:	40e7853b          	subw	a0,a5,a4
 2de:	6422                	ld	s0,8(sp)
 2e0:	0141                	addi	sp,sp,16
 2e2:	8082                	ret
 2e4:	4501                	li	a0,0
 2e6:	bfe5                	j	2de <memcmp+0x30>

00000000000002e8 <memcpy>:
 2e8:	1141                	addi	sp,sp,-16
 2ea:	e406                	sd	ra,8(sp)
 2ec:	e022                	sd	s0,0(sp)
 2ee:	0800                	addi	s0,sp,16
 2f0:	00000097          	auipc	ra,0x0
 2f4:	f62080e7          	jalr	-158(ra) # 252 <memmove>
 2f8:	60a2                	ld	ra,8(sp)
 2fa:	6402                	ld	s0,0(sp)
 2fc:	0141                	addi	sp,sp,16
 2fe:	8082                	ret

0000000000000300 <fork>:
 300:	4885                	li	a7,1
 302:	00000073          	ecall
 306:	8082                	ret

0000000000000308 <exit>:
 308:	4889                	li	a7,2
 30a:	00000073          	ecall
 30e:	8082                	ret

0000000000000310 <wait>:
 310:	488d                	li	a7,3
 312:	00000073          	ecall
 316:	8082                	ret

0000000000000318 <pipe>:
 318:	4891                	li	a7,4
 31a:	00000073          	ecall
 31e:	8082                	ret

0000000000000320 <read>:
 320:	4895                	li	a7,5
 322:	00000073          	ecall
 326:	8082                	ret

0000000000000328 <write>:
 328:	48c1                	li	a7,16
 32a:	00000073          	ecall
 32e:	8082                	ret

0000000000000330 <close>:
 330:	48d5                	li	a7,21
 332:	00000073          	ecall
 336:	8082                	ret

0000000000000338 <kill>:
 338:	4899                	li	a7,6
 33a:	00000073          	ecall
 33e:	8082                	ret

0000000000000340 <exec>:
 340:	489d                	li	a7,7
 342:	00000073          	ecall
 346:	8082                	ret

0000000000000348 <open>:
 348:	48bd                	li	a7,15
 34a:	00000073          	ecall
 34e:	8082                	ret

0000000000000350 <mknod>:
 350:	48c5                	li	a7,17
 352:	00000073          	ecall
 356:	8082                	ret

0000000000000358 <unlink>:
 358:	48c9                	li	a7,18
 35a:	00000073          	ecall
 35e:	8082                	ret

0000000000000360 <fstat>:
 360:	48a1                	li	a7,8
 362:	00000073          	ecall
 366:	8082                	ret

0000000000000368 <link>:
 368:	48cd                	li	a7,19
 36a:	00000073          	ecall
 36e:	8082                	ret

0000000000000370 <mkdir>:
 370:	48d1                	li	a7,20
 372:	00000073          	ecall
 376:	8082                	ret

0000000000000378 <chdir>:
 378:	48a5                	li	a7,9
 37a:	00000073          	ecall
 37e:	8082                	ret

0000000000000380 <dup>:
 380:	48a9                	li	a7,10
 382:	00000073          	ecall
 386:	8082                	ret

0000000000000388 <getpid>:
 388:	48ad                	li	a7,11
 38a:	00000073          	ecall
 38e:	8082                	ret

0000000000000390 <sbrk>:
 390:	48b1                	li	a7,12
 392:	00000073          	ecall
 396:	8082                	ret

0000000000000398 <sleep>:
 398:	48b5                	li	a7,13
 39a:	00000073          	ecall
 39e:	8082                	ret

00000000000003a0 <uptime>:
 3a0:	48b9                	li	a7,14
 3a2:	00000073          	ecall
 3a6:	8082                	ret

00000000000003a8 <trace>:
 3a8:	48d9                	li	a7,22
 3aa:	00000073          	ecall
 3ae:	8082                	ret

00000000000003b0 <putc>:
 3b0:	1101                	addi	sp,sp,-32
 3b2:	ec06                	sd	ra,24(sp)
 3b4:	e822                	sd	s0,16(sp)
 3b6:	1000                	addi	s0,sp,32
 3b8:	feb407a3          	sb	a1,-17(s0)
 3bc:	4605                	li	a2,1
 3be:	fef40593          	addi	a1,s0,-17
 3c2:	00000097          	auipc	ra,0x0
 3c6:	f66080e7          	jalr	-154(ra) # 328 <write>
 3ca:	60e2                	ld	ra,24(sp)
 3cc:	6442                	ld	s0,16(sp)
 3ce:	6105                	addi	sp,sp,32
 3d0:	8082                	ret

00000000000003d2 <printint>:
 3d2:	7139                	addi	sp,sp,-64
 3d4:	fc06                	sd	ra,56(sp)
 3d6:	f822                	sd	s0,48(sp)
 3d8:	f426                	sd	s1,40(sp)
 3da:	f04a                	sd	s2,32(sp)
 3dc:	ec4e                	sd	s3,24(sp)
 3de:	0080                	addi	s0,sp,64
 3e0:	84aa                	mv	s1,a0
 3e2:	c299                	beqz	a3,3e8 <printint+0x16>
 3e4:	0805c863          	bltz	a1,474 <printint+0xa2>
 3e8:	2581                	sext.w	a1,a1
 3ea:	4881                	li	a7,0
 3ec:	fc040693          	addi	a3,s0,-64
 3f0:	4701                	li	a4,0
 3f2:	2601                	sext.w	a2,a2
 3f4:	00000517          	auipc	a0,0x0
 3f8:	47c50513          	addi	a0,a0,1148 # 870 <digits>
 3fc:	883a                	mv	a6,a4
 3fe:	2705                	addiw	a4,a4,1
 400:	02c5f7bb          	remuw	a5,a1,a2
 404:	1782                	slli	a5,a5,0x20
 406:	9381                	srli	a5,a5,0x20
 408:	97aa                	add	a5,a5,a0
 40a:	0007c783          	lbu	a5,0(a5)
 40e:	00f68023          	sb	a5,0(a3)
 412:	0005879b          	sext.w	a5,a1
 416:	02c5d5bb          	divuw	a1,a1,a2
 41a:	0685                	addi	a3,a3,1
 41c:	fec7f0e3          	bgeu	a5,a2,3fc <printint+0x2a>
 420:	00088b63          	beqz	a7,436 <printint+0x64>
 424:	fd040793          	addi	a5,s0,-48
 428:	973e                	add	a4,a4,a5
 42a:	02d00793          	li	a5,45
 42e:	fef70823          	sb	a5,-16(a4)
 432:	0028071b          	addiw	a4,a6,2
 436:	02e05863          	blez	a4,466 <printint+0x94>
 43a:	fc040793          	addi	a5,s0,-64
 43e:	00e78933          	add	s2,a5,a4
 442:	fff78993          	addi	s3,a5,-1
 446:	99ba                	add	s3,s3,a4
 448:	377d                	addiw	a4,a4,-1
 44a:	1702                	slli	a4,a4,0x20
 44c:	9301                	srli	a4,a4,0x20
 44e:	40e989b3          	sub	s3,s3,a4
 452:	fff94583          	lbu	a1,-1(s2)
 456:	8526                	mv	a0,s1
 458:	00000097          	auipc	ra,0x0
 45c:	f58080e7          	jalr	-168(ra) # 3b0 <putc>
 460:	197d                	addi	s2,s2,-1
 462:	ff3918e3          	bne	s2,s3,452 <printint+0x80>
 466:	70e2                	ld	ra,56(sp)
 468:	7442                	ld	s0,48(sp)
 46a:	74a2                	ld	s1,40(sp)
 46c:	7902                	ld	s2,32(sp)
 46e:	69e2                	ld	s3,24(sp)
 470:	6121                	addi	sp,sp,64
 472:	8082                	ret
 474:	40b005bb          	negw	a1,a1
 478:	4885                	li	a7,1
 47a:	bf8d                	j	3ec <printint+0x1a>

000000000000047c <vprintf>:
 47c:	7119                	addi	sp,sp,-128
 47e:	fc86                	sd	ra,120(sp)
 480:	f8a2                	sd	s0,112(sp)
 482:	f4a6                	sd	s1,104(sp)
 484:	f0ca                	sd	s2,96(sp)
 486:	ecce                	sd	s3,88(sp)
 488:	e8d2                	sd	s4,80(sp)
 48a:	e4d6                	sd	s5,72(sp)
 48c:	e0da                	sd	s6,64(sp)
 48e:	fc5e                	sd	s7,56(sp)
 490:	f862                	sd	s8,48(sp)
 492:	f466                	sd	s9,40(sp)
 494:	f06a                	sd	s10,32(sp)
 496:	ec6e                	sd	s11,24(sp)
 498:	0100                	addi	s0,sp,128
 49a:	0005c903          	lbu	s2,0(a1)
 49e:	18090f63          	beqz	s2,63c <vprintf+0x1c0>
 4a2:	8aaa                	mv	s5,a0
 4a4:	8b32                	mv	s6,a2
 4a6:	00158493          	addi	s1,a1,1
 4aa:	4981                	li	s3,0
 4ac:	02500a13          	li	s4,37
 4b0:	06400c13          	li	s8,100
 4b4:	06c00c93          	li	s9,108
 4b8:	07800d13          	li	s10,120
 4bc:	07000d93          	li	s11,112
 4c0:	00000b97          	auipc	s7,0x0
 4c4:	3b0b8b93          	addi	s7,s7,944 # 870 <digits>
 4c8:	a839                	j	4e6 <vprintf+0x6a>
 4ca:	85ca                	mv	a1,s2
 4cc:	8556                	mv	a0,s5
 4ce:	00000097          	auipc	ra,0x0
 4d2:	ee2080e7          	jalr	-286(ra) # 3b0 <putc>
 4d6:	a019                	j	4dc <vprintf+0x60>
 4d8:	01498f63          	beq	s3,s4,4f6 <vprintf+0x7a>
 4dc:	0485                	addi	s1,s1,1
 4de:	fff4c903          	lbu	s2,-1(s1)
 4e2:	14090d63          	beqz	s2,63c <vprintf+0x1c0>
 4e6:	0009079b          	sext.w	a5,s2
 4ea:	fe0997e3          	bnez	s3,4d8 <vprintf+0x5c>
 4ee:	fd479ee3          	bne	a5,s4,4ca <vprintf+0x4e>
 4f2:	89be                	mv	s3,a5
 4f4:	b7e5                	j	4dc <vprintf+0x60>
 4f6:	05878063          	beq	a5,s8,536 <vprintf+0xba>
 4fa:	05978c63          	beq	a5,s9,552 <vprintf+0xd6>
 4fe:	07a78863          	beq	a5,s10,56e <vprintf+0xf2>
 502:	09b78463          	beq	a5,s11,58a <vprintf+0x10e>
 506:	07300713          	li	a4,115
 50a:	0ce78663          	beq	a5,a4,5d6 <vprintf+0x15a>
 50e:	06300713          	li	a4,99
 512:	0ee78e63          	beq	a5,a4,60e <vprintf+0x192>
 516:	11478863          	beq	a5,s4,626 <vprintf+0x1aa>
 51a:	85d2                	mv	a1,s4
 51c:	8556                	mv	a0,s5
 51e:	00000097          	auipc	ra,0x0
 522:	e92080e7          	jalr	-366(ra) # 3b0 <putc>
 526:	85ca                	mv	a1,s2
 528:	8556                	mv	a0,s5
 52a:	00000097          	auipc	ra,0x0
 52e:	e86080e7          	jalr	-378(ra) # 3b0 <putc>
 532:	4981                	li	s3,0
 534:	b765                	j	4dc <vprintf+0x60>
 536:	008b0913          	addi	s2,s6,8
 53a:	4685                	li	a3,1
 53c:	4629                	li	a2,10
 53e:	000b2583          	lw	a1,0(s6)
 542:	8556                	mv	a0,s5
 544:	00000097          	auipc	ra,0x0
 548:	e8e080e7          	jalr	-370(ra) # 3d2 <printint>
 54c:	8b4a                	mv	s6,s2
 54e:	4981                	li	s3,0
 550:	b771                	j	4dc <vprintf+0x60>
 552:	008b0913          	addi	s2,s6,8
 556:	4681                	li	a3,0
 558:	4629                	li	a2,10
 55a:	000b2583          	lw	a1,0(s6)
 55e:	8556                	mv	a0,s5
 560:	00000097          	auipc	ra,0x0
 564:	e72080e7          	jalr	-398(ra) # 3d2 <printint>
 568:	8b4a                	mv	s6,s2
 56a:	4981                	li	s3,0
 56c:	bf85                	j	4dc <vprintf+0x60>
 56e:	008b0913          	addi	s2,s6,8
 572:	4681                	li	a3,0
 574:	4641                	li	a2,16
 576:	000b2583          	lw	a1,0(s6)
 57a:	8556                	mv	a0,s5
 57c:	00000097          	auipc	ra,0x0
 580:	e56080e7          	jalr	-426(ra) # 3d2 <printint>
 584:	8b4a                	mv	s6,s2
 586:	4981                	li	s3,0
 588:	bf91                	j	4dc <vprintf+0x60>
 58a:	008b0793          	addi	a5,s6,8
 58e:	f8f43423          	sd	a5,-120(s0)
 592:	000b3983          	ld	s3,0(s6)
 596:	03000593          	li	a1,48
 59a:	8556                	mv	a0,s5
 59c:	00000097          	auipc	ra,0x0
 5a0:	e14080e7          	jalr	-492(ra) # 3b0 <putc>
 5a4:	85ea                	mv	a1,s10
 5a6:	8556                	mv	a0,s5
 5a8:	00000097          	auipc	ra,0x0
 5ac:	e08080e7          	jalr	-504(ra) # 3b0 <putc>
 5b0:	4941                	li	s2,16
 5b2:	03c9d793          	srli	a5,s3,0x3c
 5b6:	97de                	add	a5,a5,s7
 5b8:	0007c583          	lbu	a1,0(a5)
 5bc:	8556                	mv	a0,s5
 5be:	00000097          	auipc	ra,0x0
 5c2:	df2080e7          	jalr	-526(ra) # 3b0 <putc>
 5c6:	0992                	slli	s3,s3,0x4
 5c8:	397d                	addiw	s2,s2,-1
 5ca:	fe0914e3          	bnez	s2,5b2 <vprintf+0x136>
 5ce:	f8843b03          	ld	s6,-120(s0)
 5d2:	4981                	li	s3,0
 5d4:	b721                	j	4dc <vprintf+0x60>
 5d6:	008b0993          	addi	s3,s6,8
 5da:	000b3903          	ld	s2,0(s6)
 5de:	02090163          	beqz	s2,600 <vprintf+0x184>
 5e2:	00094583          	lbu	a1,0(s2)
 5e6:	c9a1                	beqz	a1,636 <vprintf+0x1ba>
 5e8:	8556                	mv	a0,s5
 5ea:	00000097          	auipc	ra,0x0
 5ee:	dc6080e7          	jalr	-570(ra) # 3b0 <putc>
 5f2:	0905                	addi	s2,s2,1
 5f4:	00094583          	lbu	a1,0(s2)
 5f8:	f9e5                	bnez	a1,5e8 <vprintf+0x16c>
 5fa:	8b4e                	mv	s6,s3
 5fc:	4981                	li	s3,0
 5fe:	bdf9                	j	4dc <vprintf+0x60>
 600:	00000917          	auipc	s2,0x0
 604:	26890913          	addi	s2,s2,616 # 868 <malloc+0x122>
 608:	02800593          	li	a1,40
 60c:	bff1                	j	5e8 <vprintf+0x16c>
 60e:	008b0913          	addi	s2,s6,8
 612:	000b4583          	lbu	a1,0(s6)
 616:	8556                	mv	a0,s5
 618:	00000097          	auipc	ra,0x0
 61c:	d98080e7          	jalr	-616(ra) # 3b0 <putc>
 620:	8b4a                	mv	s6,s2
 622:	4981                	li	s3,0
 624:	bd65                	j	4dc <vprintf+0x60>
 626:	85d2                	mv	a1,s4
 628:	8556                	mv	a0,s5
 62a:	00000097          	auipc	ra,0x0
 62e:	d86080e7          	jalr	-634(ra) # 3b0 <putc>
 632:	4981                	li	s3,0
 634:	b565                	j	4dc <vprintf+0x60>
 636:	8b4e                	mv	s6,s3
 638:	4981                	li	s3,0
 63a:	b54d                	j	4dc <vprintf+0x60>
 63c:	70e6                	ld	ra,120(sp)
 63e:	7446                	ld	s0,112(sp)
 640:	74a6                	ld	s1,104(sp)
 642:	7906                	ld	s2,96(sp)
 644:	69e6                	ld	s3,88(sp)
 646:	6a46                	ld	s4,80(sp)
 648:	6aa6                	ld	s5,72(sp)
 64a:	6b06                	ld	s6,64(sp)
 64c:	7be2                	ld	s7,56(sp)
 64e:	7c42                	ld	s8,48(sp)
 650:	7ca2                	ld	s9,40(sp)
 652:	7d02                	ld	s10,32(sp)
 654:	6de2                	ld	s11,24(sp)
 656:	6109                	addi	sp,sp,128
 658:	8082                	ret

000000000000065a <fprintf>:
 65a:	715d                	addi	sp,sp,-80
 65c:	ec06                	sd	ra,24(sp)
 65e:	e822                	sd	s0,16(sp)
 660:	1000                	addi	s0,sp,32
 662:	e010                	sd	a2,0(s0)
 664:	e414                	sd	a3,8(s0)
 666:	e818                	sd	a4,16(s0)
 668:	ec1c                	sd	a5,24(s0)
 66a:	03043023          	sd	a6,32(s0)
 66e:	03143423          	sd	a7,40(s0)
 672:	fe843423          	sd	s0,-24(s0)
 676:	8622                	mv	a2,s0
 678:	00000097          	auipc	ra,0x0
 67c:	e04080e7          	jalr	-508(ra) # 47c <vprintf>
 680:	60e2                	ld	ra,24(sp)
 682:	6442                	ld	s0,16(sp)
 684:	6161                	addi	sp,sp,80
 686:	8082                	ret

0000000000000688 <printf>:
 688:	711d                	addi	sp,sp,-96
 68a:	ec06                	sd	ra,24(sp)
 68c:	e822                	sd	s0,16(sp)
 68e:	1000                	addi	s0,sp,32
 690:	e40c                	sd	a1,8(s0)
 692:	e810                	sd	a2,16(s0)
 694:	ec14                	sd	a3,24(s0)
 696:	f018                	sd	a4,32(s0)
 698:	f41c                	sd	a5,40(s0)
 69a:	03043823          	sd	a6,48(s0)
 69e:	03143c23          	sd	a7,56(s0)
 6a2:	00840613          	addi	a2,s0,8
 6a6:	fec43423          	sd	a2,-24(s0)
 6aa:	85aa                	mv	a1,a0
 6ac:	4505                	li	a0,1
 6ae:	00000097          	auipc	ra,0x0
 6b2:	dce080e7          	jalr	-562(ra) # 47c <vprintf>
 6b6:	60e2                	ld	ra,24(sp)
 6b8:	6442                	ld	s0,16(sp)
 6ba:	6125                	addi	sp,sp,96
 6bc:	8082                	ret

00000000000006be <free>:
 6be:	1141                	addi	sp,sp,-16
 6c0:	e422                	sd	s0,8(sp)
 6c2:	0800                	addi	s0,sp,16
 6c4:	ff050693          	addi	a3,a0,-16
 6c8:	00001797          	auipc	a5,0x1
 6cc:	9387b783          	ld	a5,-1736(a5) # 1000 <freep>
 6d0:	a805                	j	700 <free+0x42>
 6d2:	4618                	lw	a4,8(a2)
 6d4:	9db9                	addw	a1,a1,a4
 6d6:	feb52c23          	sw	a1,-8(a0)
 6da:	6398                	ld	a4,0(a5)
 6dc:	6318                	ld	a4,0(a4)
 6de:	fee53823          	sd	a4,-16(a0)
 6e2:	a091                	j	726 <free+0x68>
 6e4:	ff852703          	lw	a4,-8(a0)
 6e8:	9e39                	addw	a2,a2,a4
 6ea:	c790                	sw	a2,8(a5)
 6ec:	ff053703          	ld	a4,-16(a0)
 6f0:	e398                	sd	a4,0(a5)
 6f2:	a099                	j	738 <free+0x7a>
 6f4:	6398                	ld	a4,0(a5)
 6f6:	00e7e463          	bltu	a5,a4,6fe <free+0x40>
 6fa:	00e6ea63          	bltu	a3,a4,70e <free+0x50>
 6fe:	87ba                	mv	a5,a4
 700:	fed7fae3          	bgeu	a5,a3,6f4 <free+0x36>
 704:	6398                	ld	a4,0(a5)
 706:	00e6e463          	bltu	a3,a4,70e <free+0x50>
 70a:	fee7eae3          	bltu	a5,a4,6fe <free+0x40>
 70e:	ff852583          	lw	a1,-8(a0)
 712:	6390                	ld	a2,0(a5)
 714:	02059713          	slli	a4,a1,0x20
 718:	9301                	srli	a4,a4,0x20
 71a:	0712                	slli	a4,a4,0x4
 71c:	9736                	add	a4,a4,a3
 71e:	fae60ae3          	beq	a2,a4,6d2 <free+0x14>
 722:	fec53823          	sd	a2,-16(a0)
 726:	4790                	lw	a2,8(a5)
 728:	02061713          	slli	a4,a2,0x20
 72c:	9301                	srli	a4,a4,0x20
 72e:	0712                	slli	a4,a4,0x4
 730:	973e                	add	a4,a4,a5
 732:	fae689e3          	beq	a3,a4,6e4 <free+0x26>
 736:	e394                	sd	a3,0(a5)
 738:	00001717          	auipc	a4,0x1
 73c:	8cf73423          	sd	a5,-1848(a4) # 1000 <freep>
 740:	6422                	ld	s0,8(sp)
 742:	0141                	addi	sp,sp,16
 744:	8082                	ret

0000000000000746 <malloc>:
 746:	7139                	addi	sp,sp,-64
 748:	fc06                	sd	ra,56(sp)
 74a:	f822                	sd	s0,48(sp)
 74c:	f426                	sd	s1,40(sp)
 74e:	f04a                	sd	s2,32(sp)
 750:	ec4e                	sd	s3,24(sp)
 752:	e852                	sd	s4,16(sp)
 754:	e456                	sd	s5,8(sp)
 756:	e05a                	sd	s6,0(sp)
 758:	0080                	addi	s0,sp,64
 75a:	02051493          	slli	s1,a0,0x20
 75e:	9081                	srli	s1,s1,0x20
 760:	04bd                	addi	s1,s1,15
 762:	8091                	srli	s1,s1,0x4
 764:	0014899b          	addiw	s3,s1,1
 768:	0485                	addi	s1,s1,1
 76a:	00001517          	auipc	a0,0x1
 76e:	89653503          	ld	a0,-1898(a0) # 1000 <freep>
 772:	c515                	beqz	a0,79e <malloc+0x58>
 774:	611c                	ld	a5,0(a0)
 776:	4798                	lw	a4,8(a5)
 778:	02977f63          	bgeu	a4,s1,7b6 <malloc+0x70>
 77c:	8a4e                	mv	s4,s3
 77e:	0009871b          	sext.w	a4,s3
 782:	6685                	lui	a3,0x1
 784:	00d77363          	bgeu	a4,a3,78a <malloc+0x44>
 788:	6a05                	lui	s4,0x1
 78a:	000a0b1b          	sext.w	s6,s4
 78e:	004a1a1b          	slliw	s4,s4,0x4
 792:	00001917          	auipc	s2,0x1
 796:	86e90913          	addi	s2,s2,-1938 # 1000 <freep>
 79a:	5afd                	li	s5,-1
 79c:	a88d                	j	80e <malloc+0xc8>
 79e:	00001797          	auipc	a5,0x1
 7a2:	87278793          	addi	a5,a5,-1934 # 1010 <base>
 7a6:	00001717          	auipc	a4,0x1
 7aa:	84f73d23          	sd	a5,-1958(a4) # 1000 <freep>
 7ae:	e39c                	sd	a5,0(a5)
 7b0:	0007a423          	sw	zero,8(a5)
 7b4:	b7e1                	j	77c <malloc+0x36>
 7b6:	02e48b63          	beq	s1,a4,7ec <malloc+0xa6>
 7ba:	4137073b          	subw	a4,a4,s3
 7be:	c798                	sw	a4,8(a5)
 7c0:	1702                	slli	a4,a4,0x20
 7c2:	9301                	srli	a4,a4,0x20
 7c4:	0712                	slli	a4,a4,0x4
 7c6:	97ba                	add	a5,a5,a4
 7c8:	0137a423          	sw	s3,8(a5)
 7cc:	00001717          	auipc	a4,0x1
 7d0:	82a73a23          	sd	a0,-1996(a4) # 1000 <freep>
 7d4:	01078513          	addi	a0,a5,16
 7d8:	70e2                	ld	ra,56(sp)
 7da:	7442                	ld	s0,48(sp)
 7dc:	74a2                	ld	s1,40(sp)
 7de:	7902                	ld	s2,32(sp)
 7e0:	69e2                	ld	s3,24(sp)
 7e2:	6a42                	ld	s4,16(sp)
 7e4:	6aa2                	ld	s5,8(sp)
 7e6:	6b02                	ld	s6,0(sp)
 7e8:	6121                	addi	sp,sp,64
 7ea:	8082                	ret
 7ec:	6398                	ld	a4,0(a5)
 7ee:	e118                	sd	a4,0(a0)
 7f0:	bff1                	j	7cc <malloc+0x86>
 7f2:	01652423          	sw	s6,8(a0)
 7f6:	0541                	addi	a0,a0,16
 7f8:	00000097          	auipc	ra,0x0
 7fc:	ec6080e7          	jalr	-314(ra) # 6be <free>
 800:	00093503          	ld	a0,0(s2)
 804:	d971                	beqz	a0,7d8 <malloc+0x92>
 806:	611c                	ld	a5,0(a0)
 808:	4798                	lw	a4,8(a5)
 80a:	fa9776e3          	bgeu	a4,s1,7b6 <malloc+0x70>
 80e:	00093703          	ld	a4,0(s2)
 812:	853e                	mv	a0,a5
 814:	fef719e3          	bne	a4,a5,806 <malloc+0xc0>
 818:	8552                	mv	a0,s4
 81a:	00000097          	auipc	ra,0x0
 81e:	b76080e7          	jalr	-1162(ra) # 390 <sbrk>
 822:	fd5518e3          	bne	a0,s5,7f2 <malloc+0xac>
 826:	4501                	li	a0,0
 828:	bf45                	j	7d8 <malloc+0x92>
