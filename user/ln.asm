
user/_ln:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
   a:	478d                	li	a5,3
   c:	02f50063          	beq	a0,a5,2c <main+0x2c>
  10:	00001597          	auipc	a1,0x1
  14:	81058593          	addi	a1,a1,-2032 # 820 <malloc+0xf2>
  18:	4509                	li	a0,2
  1a:	00000097          	auipc	ra,0x0
  1e:	628080e7          	jalr	1576(ra) # 642 <fprintf>
  22:	4505                	li	a0,1
  24:	00000097          	auipc	ra,0x0
  28:	2cc080e7          	jalr	716(ra) # 2f0 <exit>
  2c:	84ae                	mv	s1,a1
  2e:	698c                	ld	a1,16(a1)
  30:	6488                	ld	a0,8(s1)
  32:	00000097          	auipc	ra,0x0
  36:	31e080e7          	jalr	798(ra) # 350 <link>
  3a:	00054763          	bltz	a0,48 <main+0x48>
  3e:	4501                	li	a0,0
  40:	00000097          	auipc	ra,0x0
  44:	2b0080e7          	jalr	688(ra) # 2f0 <exit>
  48:	6894                	ld	a3,16(s1)
  4a:	6490                	ld	a2,8(s1)
  4c:	00000597          	auipc	a1,0x0
  50:	7ec58593          	addi	a1,a1,2028 # 838 <malloc+0x10a>
  54:	4509                	li	a0,2
  56:	00000097          	auipc	ra,0x0
  5a:	5ec080e7          	jalr	1516(ra) # 642 <fprintf>
  5e:	b7c5                	j	3e <main+0x3e>

0000000000000060 <_main>:
  60:	1141                	addi	sp,sp,-16
  62:	e406                	sd	ra,8(sp)
  64:	e022                	sd	s0,0(sp)
  66:	0800                	addi	s0,sp,16
  68:	00000097          	auipc	ra,0x0
  6c:	f98080e7          	jalr	-104(ra) # 0 <main>
  70:	4501                	li	a0,0
  72:	00000097          	auipc	ra,0x0
  76:	27e080e7          	jalr	638(ra) # 2f0 <exit>

000000000000007a <strcpy>:
  7a:	1141                	addi	sp,sp,-16
  7c:	e422                	sd	s0,8(sp)
  7e:	0800                	addi	s0,sp,16
  80:	87aa                	mv	a5,a0
  82:	0585                	addi	a1,a1,1
  84:	0785                	addi	a5,a5,1
  86:	fff5c703          	lbu	a4,-1(a1)
  8a:	fee78fa3          	sb	a4,-1(a5)
  8e:	fb75                	bnez	a4,82 <strcpy+0x8>
  90:	6422                	ld	s0,8(sp)
  92:	0141                	addi	sp,sp,16
  94:	8082                	ret

0000000000000096 <strcmp>:
  96:	1141                	addi	sp,sp,-16
  98:	e422                	sd	s0,8(sp)
  9a:	0800                	addi	s0,sp,16
  9c:	00054783          	lbu	a5,0(a0)
  a0:	cb91                	beqz	a5,b4 <strcmp+0x1e>
  a2:	0005c703          	lbu	a4,0(a1)
  a6:	00f71763          	bne	a4,a5,b4 <strcmp+0x1e>
  aa:	0505                	addi	a0,a0,1
  ac:	0585                	addi	a1,a1,1
  ae:	00054783          	lbu	a5,0(a0)
  b2:	fbe5                	bnez	a5,a2 <strcmp+0xc>
  b4:	0005c503          	lbu	a0,0(a1)
  b8:	40a7853b          	subw	a0,a5,a0
  bc:	6422                	ld	s0,8(sp)
  be:	0141                	addi	sp,sp,16
  c0:	8082                	ret

00000000000000c2 <strlen>:
  c2:	1141                	addi	sp,sp,-16
  c4:	e422                	sd	s0,8(sp)
  c6:	0800                	addi	s0,sp,16
  c8:	00054783          	lbu	a5,0(a0)
  cc:	cf91                	beqz	a5,e8 <strlen+0x26>
  ce:	0505                	addi	a0,a0,1
  d0:	87aa                	mv	a5,a0
  d2:	4685                	li	a3,1
  d4:	9e89                	subw	a3,a3,a0
  d6:	00f6853b          	addw	a0,a3,a5
  da:	0785                	addi	a5,a5,1
  dc:	fff7c703          	lbu	a4,-1(a5)
  e0:	fb7d                	bnez	a4,d6 <strlen+0x14>
  e2:	6422                	ld	s0,8(sp)
  e4:	0141                	addi	sp,sp,16
  e6:	8082                	ret
  e8:	4501                	li	a0,0
  ea:	bfe5                	j	e2 <strlen+0x20>

00000000000000ec <memset>:
  ec:	1141                	addi	sp,sp,-16
  ee:	e422                	sd	s0,8(sp)
  f0:	0800                	addi	s0,sp,16
  f2:	ce09                	beqz	a2,10c <memset+0x20>
  f4:	87aa                	mv	a5,a0
  f6:	fff6071b          	addiw	a4,a2,-1
  fa:	1702                	slli	a4,a4,0x20
  fc:	9301                	srli	a4,a4,0x20
  fe:	0705                	addi	a4,a4,1
 100:	972a                	add	a4,a4,a0
 102:	00b78023          	sb	a1,0(a5)
 106:	0785                	addi	a5,a5,1
 108:	fee79de3          	bne	a5,a4,102 <memset+0x16>
 10c:	6422                	ld	s0,8(sp)
 10e:	0141                	addi	sp,sp,16
 110:	8082                	ret

0000000000000112 <strchr>:
 112:	1141                	addi	sp,sp,-16
 114:	e422                	sd	s0,8(sp)
 116:	0800                	addi	s0,sp,16
 118:	00054783          	lbu	a5,0(a0)
 11c:	cb99                	beqz	a5,132 <strchr+0x20>
 11e:	00f58763          	beq	a1,a5,12c <strchr+0x1a>
 122:	0505                	addi	a0,a0,1
 124:	00054783          	lbu	a5,0(a0)
 128:	fbfd                	bnez	a5,11e <strchr+0xc>
 12a:	4501                	li	a0,0
 12c:	6422                	ld	s0,8(sp)
 12e:	0141                	addi	sp,sp,16
 130:	8082                	ret
 132:	4501                	li	a0,0
 134:	bfe5                	j	12c <strchr+0x1a>

0000000000000136 <gets>:
 136:	711d                	addi	sp,sp,-96
 138:	ec86                	sd	ra,88(sp)
 13a:	e8a2                	sd	s0,80(sp)
 13c:	e4a6                	sd	s1,72(sp)
 13e:	e0ca                	sd	s2,64(sp)
 140:	fc4e                	sd	s3,56(sp)
 142:	f852                	sd	s4,48(sp)
 144:	f456                	sd	s5,40(sp)
 146:	f05a                	sd	s6,32(sp)
 148:	ec5e                	sd	s7,24(sp)
 14a:	1080                	addi	s0,sp,96
 14c:	8baa                	mv	s7,a0
 14e:	8a2e                	mv	s4,a1
 150:	892a                	mv	s2,a0
 152:	4481                	li	s1,0
 154:	4aa9                	li	s5,10
 156:	4b35                	li	s6,13
 158:	89a6                	mv	s3,s1
 15a:	2485                	addiw	s1,s1,1
 15c:	0344d863          	bge	s1,s4,18c <gets+0x56>
 160:	4605                	li	a2,1
 162:	faf40593          	addi	a1,s0,-81
 166:	4501                	li	a0,0
 168:	00000097          	auipc	ra,0x0
 16c:	1a0080e7          	jalr	416(ra) # 308 <read>
 170:	00a05e63          	blez	a0,18c <gets+0x56>
 174:	faf44783          	lbu	a5,-81(s0)
 178:	00f90023          	sb	a5,0(s2)
 17c:	01578763          	beq	a5,s5,18a <gets+0x54>
 180:	0905                	addi	s2,s2,1
 182:	fd679be3          	bne	a5,s6,158 <gets+0x22>
 186:	89a6                	mv	s3,s1
 188:	a011                	j	18c <gets+0x56>
 18a:	89a6                	mv	s3,s1
 18c:	99de                	add	s3,s3,s7
 18e:	00098023          	sb	zero,0(s3)
 192:	855e                	mv	a0,s7
 194:	60e6                	ld	ra,88(sp)
 196:	6446                	ld	s0,80(sp)
 198:	64a6                	ld	s1,72(sp)
 19a:	6906                	ld	s2,64(sp)
 19c:	79e2                	ld	s3,56(sp)
 19e:	7a42                	ld	s4,48(sp)
 1a0:	7aa2                	ld	s5,40(sp)
 1a2:	7b02                	ld	s6,32(sp)
 1a4:	6be2                	ld	s7,24(sp)
 1a6:	6125                	addi	sp,sp,96
 1a8:	8082                	ret

00000000000001aa <stat>:
 1aa:	1101                	addi	sp,sp,-32
 1ac:	ec06                	sd	ra,24(sp)
 1ae:	e822                	sd	s0,16(sp)
 1b0:	e426                	sd	s1,8(sp)
 1b2:	e04a                	sd	s2,0(sp)
 1b4:	1000                	addi	s0,sp,32
 1b6:	892e                	mv	s2,a1
 1b8:	4581                	li	a1,0
 1ba:	00000097          	auipc	ra,0x0
 1be:	176080e7          	jalr	374(ra) # 330 <open>
 1c2:	02054563          	bltz	a0,1ec <stat+0x42>
 1c6:	84aa                	mv	s1,a0
 1c8:	85ca                	mv	a1,s2
 1ca:	00000097          	auipc	ra,0x0
 1ce:	17e080e7          	jalr	382(ra) # 348 <fstat>
 1d2:	892a                	mv	s2,a0
 1d4:	8526                	mv	a0,s1
 1d6:	00000097          	auipc	ra,0x0
 1da:	142080e7          	jalr	322(ra) # 318 <close>
 1de:	854a                	mv	a0,s2
 1e0:	60e2                	ld	ra,24(sp)
 1e2:	6442                	ld	s0,16(sp)
 1e4:	64a2                	ld	s1,8(sp)
 1e6:	6902                	ld	s2,0(sp)
 1e8:	6105                	addi	sp,sp,32
 1ea:	8082                	ret
 1ec:	597d                	li	s2,-1
 1ee:	bfc5                	j	1de <stat+0x34>

00000000000001f0 <atoi>:
 1f0:	1141                	addi	sp,sp,-16
 1f2:	e422                	sd	s0,8(sp)
 1f4:	0800                	addi	s0,sp,16
 1f6:	00054603          	lbu	a2,0(a0)
 1fa:	fd06079b          	addiw	a5,a2,-48
 1fe:	0ff7f793          	andi	a5,a5,255
 202:	4725                	li	a4,9
 204:	02f76963          	bltu	a4,a5,236 <atoi+0x46>
 208:	86aa                	mv	a3,a0
 20a:	4501                	li	a0,0
 20c:	45a5                	li	a1,9
 20e:	0685                	addi	a3,a3,1
 210:	0025179b          	slliw	a5,a0,0x2
 214:	9fa9                	addw	a5,a5,a0
 216:	0017979b          	slliw	a5,a5,0x1
 21a:	9fb1                	addw	a5,a5,a2
 21c:	fd07851b          	addiw	a0,a5,-48
 220:	0006c603          	lbu	a2,0(a3)
 224:	fd06071b          	addiw	a4,a2,-48
 228:	0ff77713          	andi	a4,a4,255
 22c:	fee5f1e3          	bgeu	a1,a4,20e <atoi+0x1e>
 230:	6422                	ld	s0,8(sp)
 232:	0141                	addi	sp,sp,16
 234:	8082                	ret
 236:	4501                	li	a0,0
 238:	bfe5                	j	230 <atoi+0x40>

000000000000023a <memmove>:
 23a:	1141                	addi	sp,sp,-16
 23c:	e422                	sd	s0,8(sp)
 23e:	0800                	addi	s0,sp,16
 240:	02b57663          	bgeu	a0,a1,26c <memmove+0x32>
 244:	02c05163          	blez	a2,266 <memmove+0x2c>
 248:	fff6079b          	addiw	a5,a2,-1
 24c:	1782                	slli	a5,a5,0x20
 24e:	9381                	srli	a5,a5,0x20
 250:	0785                	addi	a5,a5,1
 252:	97aa                	add	a5,a5,a0
 254:	872a                	mv	a4,a0
 256:	0585                	addi	a1,a1,1
 258:	0705                	addi	a4,a4,1
 25a:	fff5c683          	lbu	a3,-1(a1)
 25e:	fed70fa3          	sb	a3,-1(a4)
 262:	fee79ae3          	bne	a5,a4,256 <memmove+0x1c>
 266:	6422                	ld	s0,8(sp)
 268:	0141                	addi	sp,sp,16
 26a:	8082                	ret
 26c:	00c50733          	add	a4,a0,a2
 270:	95b2                	add	a1,a1,a2
 272:	fec05ae3          	blez	a2,266 <memmove+0x2c>
 276:	fff6079b          	addiw	a5,a2,-1
 27a:	1782                	slli	a5,a5,0x20
 27c:	9381                	srli	a5,a5,0x20
 27e:	fff7c793          	not	a5,a5
 282:	97ba                	add	a5,a5,a4
 284:	15fd                	addi	a1,a1,-1
 286:	177d                	addi	a4,a4,-1
 288:	0005c683          	lbu	a3,0(a1)
 28c:	00d70023          	sb	a3,0(a4)
 290:	fee79ae3          	bne	a5,a4,284 <memmove+0x4a>
 294:	bfc9                	j	266 <memmove+0x2c>

0000000000000296 <memcmp>:
 296:	1141                	addi	sp,sp,-16
 298:	e422                	sd	s0,8(sp)
 29a:	0800                	addi	s0,sp,16
 29c:	ca05                	beqz	a2,2cc <memcmp+0x36>
 29e:	fff6069b          	addiw	a3,a2,-1
 2a2:	1682                	slli	a3,a3,0x20
 2a4:	9281                	srli	a3,a3,0x20
 2a6:	0685                	addi	a3,a3,1
 2a8:	96aa                	add	a3,a3,a0
 2aa:	00054783          	lbu	a5,0(a0)
 2ae:	0005c703          	lbu	a4,0(a1)
 2b2:	00e79863          	bne	a5,a4,2c2 <memcmp+0x2c>
 2b6:	0505                	addi	a0,a0,1
 2b8:	0585                	addi	a1,a1,1
 2ba:	fed518e3          	bne	a0,a3,2aa <memcmp+0x14>
 2be:	4501                	li	a0,0
 2c0:	a019                	j	2c6 <memcmp+0x30>
 2c2:	40e7853b          	subw	a0,a5,a4
 2c6:	6422                	ld	s0,8(sp)
 2c8:	0141                	addi	sp,sp,16
 2ca:	8082                	ret
 2cc:	4501                	li	a0,0
 2ce:	bfe5                	j	2c6 <memcmp+0x30>

00000000000002d0 <memcpy>:
 2d0:	1141                	addi	sp,sp,-16
 2d2:	e406                	sd	ra,8(sp)
 2d4:	e022                	sd	s0,0(sp)
 2d6:	0800                	addi	s0,sp,16
 2d8:	00000097          	auipc	ra,0x0
 2dc:	f62080e7          	jalr	-158(ra) # 23a <memmove>
 2e0:	60a2                	ld	ra,8(sp)
 2e2:	6402                	ld	s0,0(sp)
 2e4:	0141                	addi	sp,sp,16
 2e6:	8082                	ret

00000000000002e8 <fork>:
 2e8:	4885                	li	a7,1
 2ea:	00000073          	ecall
 2ee:	8082                	ret

00000000000002f0 <exit>:
 2f0:	4889                	li	a7,2
 2f2:	00000073          	ecall
 2f6:	8082                	ret

00000000000002f8 <wait>:
 2f8:	488d                	li	a7,3
 2fa:	00000073          	ecall
 2fe:	8082                	ret

0000000000000300 <pipe>:
 300:	4891                	li	a7,4
 302:	00000073          	ecall
 306:	8082                	ret

0000000000000308 <read>:
 308:	4895                	li	a7,5
 30a:	00000073          	ecall
 30e:	8082                	ret

0000000000000310 <write>:
 310:	48c1                	li	a7,16
 312:	00000073          	ecall
 316:	8082                	ret

0000000000000318 <close>:
 318:	48d5                	li	a7,21
 31a:	00000073          	ecall
 31e:	8082                	ret

0000000000000320 <kill>:
 320:	4899                	li	a7,6
 322:	00000073          	ecall
 326:	8082                	ret

0000000000000328 <exec>:
 328:	489d                	li	a7,7
 32a:	00000073          	ecall
 32e:	8082                	ret

0000000000000330 <open>:
 330:	48bd                	li	a7,15
 332:	00000073          	ecall
 336:	8082                	ret

0000000000000338 <mknod>:
 338:	48c5                	li	a7,17
 33a:	00000073          	ecall
 33e:	8082                	ret

0000000000000340 <unlink>:
 340:	48c9                	li	a7,18
 342:	00000073          	ecall
 346:	8082                	ret

0000000000000348 <fstat>:
 348:	48a1                	li	a7,8
 34a:	00000073          	ecall
 34e:	8082                	ret

0000000000000350 <link>:
 350:	48cd                	li	a7,19
 352:	00000073          	ecall
 356:	8082                	ret

0000000000000358 <mkdir>:
 358:	48d1                	li	a7,20
 35a:	00000073          	ecall
 35e:	8082                	ret

0000000000000360 <chdir>:
 360:	48a5                	li	a7,9
 362:	00000073          	ecall
 366:	8082                	ret

0000000000000368 <dup>:
 368:	48a9                	li	a7,10
 36a:	00000073          	ecall
 36e:	8082                	ret

0000000000000370 <getpid>:
 370:	48ad                	li	a7,11
 372:	00000073          	ecall
 376:	8082                	ret

0000000000000378 <sbrk>:
 378:	48b1                	li	a7,12
 37a:	00000073          	ecall
 37e:	8082                	ret

0000000000000380 <sleep>:
 380:	48b5                	li	a7,13
 382:	00000073          	ecall
 386:	8082                	ret

0000000000000388 <uptime>:
 388:	48b9                	li	a7,14
 38a:	00000073          	ecall
 38e:	8082                	ret

0000000000000390 <trace>:
 390:	48d9                	li	a7,22
 392:	00000073          	ecall
 396:	8082                	ret

0000000000000398 <putc>:
 398:	1101                	addi	sp,sp,-32
 39a:	ec06                	sd	ra,24(sp)
 39c:	e822                	sd	s0,16(sp)
 39e:	1000                	addi	s0,sp,32
 3a0:	feb407a3          	sb	a1,-17(s0)
 3a4:	4605                	li	a2,1
 3a6:	fef40593          	addi	a1,s0,-17
 3aa:	00000097          	auipc	ra,0x0
 3ae:	f66080e7          	jalr	-154(ra) # 310 <write>
 3b2:	60e2                	ld	ra,24(sp)
 3b4:	6442                	ld	s0,16(sp)
 3b6:	6105                	addi	sp,sp,32
 3b8:	8082                	ret

00000000000003ba <printint>:
 3ba:	7139                	addi	sp,sp,-64
 3bc:	fc06                	sd	ra,56(sp)
 3be:	f822                	sd	s0,48(sp)
 3c0:	f426                	sd	s1,40(sp)
 3c2:	f04a                	sd	s2,32(sp)
 3c4:	ec4e                	sd	s3,24(sp)
 3c6:	0080                	addi	s0,sp,64
 3c8:	84aa                	mv	s1,a0
 3ca:	c299                	beqz	a3,3d0 <printint+0x16>
 3cc:	0805c863          	bltz	a1,45c <printint+0xa2>
 3d0:	2581                	sext.w	a1,a1
 3d2:	4881                	li	a7,0
 3d4:	fc040693          	addi	a3,s0,-64
 3d8:	4701                	li	a4,0
 3da:	2601                	sext.w	a2,a2
 3dc:	00000517          	auipc	a0,0x0
 3e0:	47c50513          	addi	a0,a0,1148 # 858 <digits>
 3e4:	883a                	mv	a6,a4
 3e6:	2705                	addiw	a4,a4,1
 3e8:	02c5f7bb          	remuw	a5,a1,a2
 3ec:	1782                	slli	a5,a5,0x20
 3ee:	9381                	srli	a5,a5,0x20
 3f0:	97aa                	add	a5,a5,a0
 3f2:	0007c783          	lbu	a5,0(a5)
 3f6:	00f68023          	sb	a5,0(a3)
 3fa:	0005879b          	sext.w	a5,a1
 3fe:	02c5d5bb          	divuw	a1,a1,a2
 402:	0685                	addi	a3,a3,1
 404:	fec7f0e3          	bgeu	a5,a2,3e4 <printint+0x2a>
 408:	00088b63          	beqz	a7,41e <printint+0x64>
 40c:	fd040793          	addi	a5,s0,-48
 410:	973e                	add	a4,a4,a5
 412:	02d00793          	li	a5,45
 416:	fef70823          	sb	a5,-16(a4)
 41a:	0028071b          	addiw	a4,a6,2
 41e:	02e05863          	blez	a4,44e <printint+0x94>
 422:	fc040793          	addi	a5,s0,-64
 426:	00e78933          	add	s2,a5,a4
 42a:	fff78993          	addi	s3,a5,-1
 42e:	99ba                	add	s3,s3,a4
 430:	377d                	addiw	a4,a4,-1
 432:	1702                	slli	a4,a4,0x20
 434:	9301                	srli	a4,a4,0x20
 436:	40e989b3          	sub	s3,s3,a4
 43a:	fff94583          	lbu	a1,-1(s2)
 43e:	8526                	mv	a0,s1
 440:	00000097          	auipc	ra,0x0
 444:	f58080e7          	jalr	-168(ra) # 398 <putc>
 448:	197d                	addi	s2,s2,-1
 44a:	ff3918e3          	bne	s2,s3,43a <printint+0x80>
 44e:	70e2                	ld	ra,56(sp)
 450:	7442                	ld	s0,48(sp)
 452:	74a2                	ld	s1,40(sp)
 454:	7902                	ld	s2,32(sp)
 456:	69e2                	ld	s3,24(sp)
 458:	6121                	addi	sp,sp,64
 45a:	8082                	ret
 45c:	40b005bb          	negw	a1,a1
 460:	4885                	li	a7,1
 462:	bf8d                	j	3d4 <printint+0x1a>

0000000000000464 <vprintf>:
 464:	7119                	addi	sp,sp,-128
 466:	fc86                	sd	ra,120(sp)
 468:	f8a2                	sd	s0,112(sp)
 46a:	f4a6                	sd	s1,104(sp)
 46c:	f0ca                	sd	s2,96(sp)
 46e:	ecce                	sd	s3,88(sp)
 470:	e8d2                	sd	s4,80(sp)
 472:	e4d6                	sd	s5,72(sp)
 474:	e0da                	sd	s6,64(sp)
 476:	fc5e                	sd	s7,56(sp)
 478:	f862                	sd	s8,48(sp)
 47a:	f466                	sd	s9,40(sp)
 47c:	f06a                	sd	s10,32(sp)
 47e:	ec6e                	sd	s11,24(sp)
 480:	0100                	addi	s0,sp,128
 482:	0005c903          	lbu	s2,0(a1)
 486:	18090f63          	beqz	s2,624 <vprintf+0x1c0>
 48a:	8aaa                	mv	s5,a0
 48c:	8b32                	mv	s6,a2
 48e:	00158493          	addi	s1,a1,1
 492:	4981                	li	s3,0
 494:	02500a13          	li	s4,37
 498:	06400c13          	li	s8,100
 49c:	06c00c93          	li	s9,108
 4a0:	07800d13          	li	s10,120
 4a4:	07000d93          	li	s11,112
 4a8:	00000b97          	auipc	s7,0x0
 4ac:	3b0b8b93          	addi	s7,s7,944 # 858 <digits>
 4b0:	a839                	j	4ce <vprintf+0x6a>
 4b2:	85ca                	mv	a1,s2
 4b4:	8556                	mv	a0,s5
 4b6:	00000097          	auipc	ra,0x0
 4ba:	ee2080e7          	jalr	-286(ra) # 398 <putc>
 4be:	a019                	j	4c4 <vprintf+0x60>
 4c0:	01498f63          	beq	s3,s4,4de <vprintf+0x7a>
 4c4:	0485                	addi	s1,s1,1
 4c6:	fff4c903          	lbu	s2,-1(s1)
 4ca:	14090d63          	beqz	s2,624 <vprintf+0x1c0>
 4ce:	0009079b          	sext.w	a5,s2
 4d2:	fe0997e3          	bnez	s3,4c0 <vprintf+0x5c>
 4d6:	fd479ee3          	bne	a5,s4,4b2 <vprintf+0x4e>
 4da:	89be                	mv	s3,a5
 4dc:	b7e5                	j	4c4 <vprintf+0x60>
 4de:	05878063          	beq	a5,s8,51e <vprintf+0xba>
 4e2:	05978c63          	beq	a5,s9,53a <vprintf+0xd6>
 4e6:	07a78863          	beq	a5,s10,556 <vprintf+0xf2>
 4ea:	09b78463          	beq	a5,s11,572 <vprintf+0x10e>
 4ee:	07300713          	li	a4,115
 4f2:	0ce78663          	beq	a5,a4,5be <vprintf+0x15a>
 4f6:	06300713          	li	a4,99
 4fa:	0ee78e63          	beq	a5,a4,5f6 <vprintf+0x192>
 4fe:	11478863          	beq	a5,s4,60e <vprintf+0x1aa>
 502:	85d2                	mv	a1,s4
 504:	8556                	mv	a0,s5
 506:	00000097          	auipc	ra,0x0
 50a:	e92080e7          	jalr	-366(ra) # 398 <putc>
 50e:	85ca                	mv	a1,s2
 510:	8556                	mv	a0,s5
 512:	00000097          	auipc	ra,0x0
 516:	e86080e7          	jalr	-378(ra) # 398 <putc>
 51a:	4981                	li	s3,0
 51c:	b765                	j	4c4 <vprintf+0x60>
 51e:	008b0913          	addi	s2,s6,8
 522:	4685                	li	a3,1
 524:	4629                	li	a2,10
 526:	000b2583          	lw	a1,0(s6)
 52a:	8556                	mv	a0,s5
 52c:	00000097          	auipc	ra,0x0
 530:	e8e080e7          	jalr	-370(ra) # 3ba <printint>
 534:	8b4a                	mv	s6,s2
 536:	4981                	li	s3,0
 538:	b771                	j	4c4 <vprintf+0x60>
 53a:	008b0913          	addi	s2,s6,8
 53e:	4681                	li	a3,0
 540:	4629                	li	a2,10
 542:	000b2583          	lw	a1,0(s6)
 546:	8556                	mv	a0,s5
 548:	00000097          	auipc	ra,0x0
 54c:	e72080e7          	jalr	-398(ra) # 3ba <printint>
 550:	8b4a                	mv	s6,s2
 552:	4981                	li	s3,0
 554:	bf85                	j	4c4 <vprintf+0x60>
 556:	008b0913          	addi	s2,s6,8
 55a:	4681                	li	a3,0
 55c:	4641                	li	a2,16
 55e:	000b2583          	lw	a1,0(s6)
 562:	8556                	mv	a0,s5
 564:	00000097          	auipc	ra,0x0
 568:	e56080e7          	jalr	-426(ra) # 3ba <printint>
 56c:	8b4a                	mv	s6,s2
 56e:	4981                	li	s3,0
 570:	bf91                	j	4c4 <vprintf+0x60>
 572:	008b0793          	addi	a5,s6,8
 576:	f8f43423          	sd	a5,-120(s0)
 57a:	000b3983          	ld	s3,0(s6)
 57e:	03000593          	li	a1,48
 582:	8556                	mv	a0,s5
 584:	00000097          	auipc	ra,0x0
 588:	e14080e7          	jalr	-492(ra) # 398 <putc>
 58c:	85ea                	mv	a1,s10
 58e:	8556                	mv	a0,s5
 590:	00000097          	auipc	ra,0x0
 594:	e08080e7          	jalr	-504(ra) # 398 <putc>
 598:	4941                	li	s2,16
 59a:	03c9d793          	srli	a5,s3,0x3c
 59e:	97de                	add	a5,a5,s7
 5a0:	0007c583          	lbu	a1,0(a5)
 5a4:	8556                	mv	a0,s5
 5a6:	00000097          	auipc	ra,0x0
 5aa:	df2080e7          	jalr	-526(ra) # 398 <putc>
 5ae:	0992                	slli	s3,s3,0x4
 5b0:	397d                	addiw	s2,s2,-1
 5b2:	fe0914e3          	bnez	s2,59a <vprintf+0x136>
 5b6:	f8843b03          	ld	s6,-120(s0)
 5ba:	4981                	li	s3,0
 5bc:	b721                	j	4c4 <vprintf+0x60>
 5be:	008b0993          	addi	s3,s6,8
 5c2:	000b3903          	ld	s2,0(s6)
 5c6:	02090163          	beqz	s2,5e8 <vprintf+0x184>
 5ca:	00094583          	lbu	a1,0(s2)
 5ce:	c9a1                	beqz	a1,61e <vprintf+0x1ba>
 5d0:	8556                	mv	a0,s5
 5d2:	00000097          	auipc	ra,0x0
 5d6:	dc6080e7          	jalr	-570(ra) # 398 <putc>
 5da:	0905                	addi	s2,s2,1
 5dc:	00094583          	lbu	a1,0(s2)
 5e0:	f9e5                	bnez	a1,5d0 <vprintf+0x16c>
 5e2:	8b4e                	mv	s6,s3
 5e4:	4981                	li	s3,0
 5e6:	bdf9                	j	4c4 <vprintf+0x60>
 5e8:	00000917          	auipc	s2,0x0
 5ec:	26890913          	addi	s2,s2,616 # 850 <malloc+0x122>
 5f0:	02800593          	li	a1,40
 5f4:	bff1                	j	5d0 <vprintf+0x16c>
 5f6:	008b0913          	addi	s2,s6,8
 5fa:	000b4583          	lbu	a1,0(s6)
 5fe:	8556                	mv	a0,s5
 600:	00000097          	auipc	ra,0x0
 604:	d98080e7          	jalr	-616(ra) # 398 <putc>
 608:	8b4a                	mv	s6,s2
 60a:	4981                	li	s3,0
 60c:	bd65                	j	4c4 <vprintf+0x60>
 60e:	85d2                	mv	a1,s4
 610:	8556                	mv	a0,s5
 612:	00000097          	auipc	ra,0x0
 616:	d86080e7          	jalr	-634(ra) # 398 <putc>
 61a:	4981                	li	s3,0
 61c:	b565                	j	4c4 <vprintf+0x60>
 61e:	8b4e                	mv	s6,s3
 620:	4981                	li	s3,0
 622:	b54d                	j	4c4 <vprintf+0x60>
 624:	70e6                	ld	ra,120(sp)
 626:	7446                	ld	s0,112(sp)
 628:	74a6                	ld	s1,104(sp)
 62a:	7906                	ld	s2,96(sp)
 62c:	69e6                	ld	s3,88(sp)
 62e:	6a46                	ld	s4,80(sp)
 630:	6aa6                	ld	s5,72(sp)
 632:	6b06                	ld	s6,64(sp)
 634:	7be2                	ld	s7,56(sp)
 636:	7c42                	ld	s8,48(sp)
 638:	7ca2                	ld	s9,40(sp)
 63a:	7d02                	ld	s10,32(sp)
 63c:	6de2                	ld	s11,24(sp)
 63e:	6109                	addi	sp,sp,128
 640:	8082                	ret

0000000000000642 <fprintf>:
 642:	715d                	addi	sp,sp,-80
 644:	ec06                	sd	ra,24(sp)
 646:	e822                	sd	s0,16(sp)
 648:	1000                	addi	s0,sp,32
 64a:	e010                	sd	a2,0(s0)
 64c:	e414                	sd	a3,8(s0)
 64e:	e818                	sd	a4,16(s0)
 650:	ec1c                	sd	a5,24(s0)
 652:	03043023          	sd	a6,32(s0)
 656:	03143423          	sd	a7,40(s0)
 65a:	fe843423          	sd	s0,-24(s0)
 65e:	8622                	mv	a2,s0
 660:	00000097          	auipc	ra,0x0
 664:	e04080e7          	jalr	-508(ra) # 464 <vprintf>
 668:	60e2                	ld	ra,24(sp)
 66a:	6442                	ld	s0,16(sp)
 66c:	6161                	addi	sp,sp,80
 66e:	8082                	ret

0000000000000670 <printf>:
 670:	711d                	addi	sp,sp,-96
 672:	ec06                	sd	ra,24(sp)
 674:	e822                	sd	s0,16(sp)
 676:	1000                	addi	s0,sp,32
 678:	e40c                	sd	a1,8(s0)
 67a:	e810                	sd	a2,16(s0)
 67c:	ec14                	sd	a3,24(s0)
 67e:	f018                	sd	a4,32(s0)
 680:	f41c                	sd	a5,40(s0)
 682:	03043823          	sd	a6,48(s0)
 686:	03143c23          	sd	a7,56(s0)
 68a:	00840613          	addi	a2,s0,8
 68e:	fec43423          	sd	a2,-24(s0)
 692:	85aa                	mv	a1,a0
 694:	4505                	li	a0,1
 696:	00000097          	auipc	ra,0x0
 69a:	dce080e7          	jalr	-562(ra) # 464 <vprintf>
 69e:	60e2                	ld	ra,24(sp)
 6a0:	6442                	ld	s0,16(sp)
 6a2:	6125                	addi	sp,sp,96
 6a4:	8082                	ret

00000000000006a6 <free>:
 6a6:	1141                	addi	sp,sp,-16
 6a8:	e422                	sd	s0,8(sp)
 6aa:	0800                	addi	s0,sp,16
 6ac:	ff050693          	addi	a3,a0,-16
 6b0:	00001797          	auipc	a5,0x1
 6b4:	9507b783          	ld	a5,-1712(a5) # 1000 <freep>
 6b8:	a805                	j	6e8 <free+0x42>
 6ba:	4618                	lw	a4,8(a2)
 6bc:	9db9                	addw	a1,a1,a4
 6be:	feb52c23          	sw	a1,-8(a0)
 6c2:	6398                	ld	a4,0(a5)
 6c4:	6318                	ld	a4,0(a4)
 6c6:	fee53823          	sd	a4,-16(a0)
 6ca:	a091                	j	70e <free+0x68>
 6cc:	ff852703          	lw	a4,-8(a0)
 6d0:	9e39                	addw	a2,a2,a4
 6d2:	c790                	sw	a2,8(a5)
 6d4:	ff053703          	ld	a4,-16(a0)
 6d8:	e398                	sd	a4,0(a5)
 6da:	a099                	j	720 <free+0x7a>
 6dc:	6398                	ld	a4,0(a5)
 6de:	00e7e463          	bltu	a5,a4,6e6 <free+0x40>
 6e2:	00e6ea63          	bltu	a3,a4,6f6 <free+0x50>
 6e6:	87ba                	mv	a5,a4
 6e8:	fed7fae3          	bgeu	a5,a3,6dc <free+0x36>
 6ec:	6398                	ld	a4,0(a5)
 6ee:	00e6e463          	bltu	a3,a4,6f6 <free+0x50>
 6f2:	fee7eae3          	bltu	a5,a4,6e6 <free+0x40>
 6f6:	ff852583          	lw	a1,-8(a0)
 6fa:	6390                	ld	a2,0(a5)
 6fc:	02059713          	slli	a4,a1,0x20
 700:	9301                	srli	a4,a4,0x20
 702:	0712                	slli	a4,a4,0x4
 704:	9736                	add	a4,a4,a3
 706:	fae60ae3          	beq	a2,a4,6ba <free+0x14>
 70a:	fec53823          	sd	a2,-16(a0)
 70e:	4790                	lw	a2,8(a5)
 710:	02061713          	slli	a4,a2,0x20
 714:	9301                	srli	a4,a4,0x20
 716:	0712                	slli	a4,a4,0x4
 718:	973e                	add	a4,a4,a5
 71a:	fae689e3          	beq	a3,a4,6cc <free+0x26>
 71e:	e394                	sd	a3,0(a5)
 720:	00001717          	auipc	a4,0x1
 724:	8ef73023          	sd	a5,-1824(a4) # 1000 <freep>
 728:	6422                	ld	s0,8(sp)
 72a:	0141                	addi	sp,sp,16
 72c:	8082                	ret

000000000000072e <malloc>:
 72e:	7139                	addi	sp,sp,-64
 730:	fc06                	sd	ra,56(sp)
 732:	f822                	sd	s0,48(sp)
 734:	f426                	sd	s1,40(sp)
 736:	f04a                	sd	s2,32(sp)
 738:	ec4e                	sd	s3,24(sp)
 73a:	e852                	sd	s4,16(sp)
 73c:	e456                	sd	s5,8(sp)
 73e:	e05a                	sd	s6,0(sp)
 740:	0080                	addi	s0,sp,64
 742:	02051493          	slli	s1,a0,0x20
 746:	9081                	srli	s1,s1,0x20
 748:	04bd                	addi	s1,s1,15
 74a:	8091                	srli	s1,s1,0x4
 74c:	0014899b          	addiw	s3,s1,1
 750:	0485                	addi	s1,s1,1
 752:	00001517          	auipc	a0,0x1
 756:	8ae53503          	ld	a0,-1874(a0) # 1000 <freep>
 75a:	c515                	beqz	a0,786 <malloc+0x58>
 75c:	611c                	ld	a5,0(a0)
 75e:	4798                	lw	a4,8(a5)
 760:	02977f63          	bgeu	a4,s1,79e <malloc+0x70>
 764:	8a4e                	mv	s4,s3
 766:	0009871b          	sext.w	a4,s3
 76a:	6685                	lui	a3,0x1
 76c:	00d77363          	bgeu	a4,a3,772 <malloc+0x44>
 770:	6a05                	lui	s4,0x1
 772:	000a0b1b          	sext.w	s6,s4
 776:	004a1a1b          	slliw	s4,s4,0x4
 77a:	00001917          	auipc	s2,0x1
 77e:	88690913          	addi	s2,s2,-1914 # 1000 <freep>
 782:	5afd                	li	s5,-1
 784:	a88d                	j	7f6 <malloc+0xc8>
 786:	00001797          	auipc	a5,0x1
 78a:	88a78793          	addi	a5,a5,-1910 # 1010 <base>
 78e:	00001717          	auipc	a4,0x1
 792:	86f73923          	sd	a5,-1934(a4) # 1000 <freep>
 796:	e39c                	sd	a5,0(a5)
 798:	0007a423          	sw	zero,8(a5)
 79c:	b7e1                	j	764 <malloc+0x36>
 79e:	02e48b63          	beq	s1,a4,7d4 <malloc+0xa6>
 7a2:	4137073b          	subw	a4,a4,s3
 7a6:	c798                	sw	a4,8(a5)
 7a8:	1702                	slli	a4,a4,0x20
 7aa:	9301                	srli	a4,a4,0x20
 7ac:	0712                	slli	a4,a4,0x4
 7ae:	97ba                	add	a5,a5,a4
 7b0:	0137a423          	sw	s3,8(a5)
 7b4:	00001717          	auipc	a4,0x1
 7b8:	84a73623          	sd	a0,-1972(a4) # 1000 <freep>
 7bc:	01078513          	addi	a0,a5,16
 7c0:	70e2                	ld	ra,56(sp)
 7c2:	7442                	ld	s0,48(sp)
 7c4:	74a2                	ld	s1,40(sp)
 7c6:	7902                	ld	s2,32(sp)
 7c8:	69e2                	ld	s3,24(sp)
 7ca:	6a42                	ld	s4,16(sp)
 7cc:	6aa2                	ld	s5,8(sp)
 7ce:	6b02                	ld	s6,0(sp)
 7d0:	6121                	addi	sp,sp,64
 7d2:	8082                	ret
 7d4:	6398                	ld	a4,0(a5)
 7d6:	e118                	sd	a4,0(a0)
 7d8:	bff1                	j	7b4 <malloc+0x86>
 7da:	01652423          	sw	s6,8(a0)
 7de:	0541                	addi	a0,a0,16
 7e0:	00000097          	auipc	ra,0x0
 7e4:	ec6080e7          	jalr	-314(ra) # 6a6 <free>
 7e8:	00093503          	ld	a0,0(s2)
 7ec:	d971                	beqz	a0,7c0 <malloc+0x92>
 7ee:	611c                	ld	a5,0(a0)
 7f0:	4798                	lw	a4,8(a5)
 7f2:	fa9776e3          	bgeu	a4,s1,79e <malloc+0x70>
 7f6:	00093703          	ld	a4,0(s2)
 7fa:	853e                	mv	a0,a5
 7fc:	fef719e3          	bne	a4,a5,7ee <malloc+0xc0>
 800:	8552                	mv	a0,s4
 802:	00000097          	auipc	ra,0x0
 806:	b76080e7          	jalr	-1162(ra) # 378 <sbrk>
 80a:	fd5518e3          	bne	a0,s5,7da <malloc+0xac>
 80e:	4501                	li	a0,0
 810:	bf45                	j	7c0 <malloc+0x92>
