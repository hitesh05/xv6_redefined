
user/_kill:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
   c:	4785                	li	a5,1
   e:	02a7dd63          	bge	a5,a0,48 <main+0x48>
  12:	00858493          	addi	s1,a1,8
  16:	ffe5091b          	addiw	s2,a0,-2
  1a:	1902                	slli	s2,s2,0x20
  1c:	02095913          	srli	s2,s2,0x20
  20:	090e                	slli	s2,s2,0x3
  22:	05c1                	addi	a1,a1,16
  24:	992e                	add	s2,s2,a1
  26:	6088                	ld	a0,0(s1)
  28:	00000097          	auipc	ra,0x0
  2c:	1cc080e7          	jalr	460(ra) # 1f4 <atoi>
  30:	00000097          	auipc	ra,0x0
  34:	2f4080e7          	jalr	756(ra) # 324 <kill>
  38:	04a1                	addi	s1,s1,8
  3a:	ff2496e3          	bne	s1,s2,26 <main+0x26>
  3e:	4501                	li	a0,0
  40:	00000097          	auipc	ra,0x0
  44:	2b4080e7          	jalr	692(ra) # 2f4 <exit>
  48:	00000597          	auipc	a1,0x0
  4c:	7d858593          	addi	a1,a1,2008 # 820 <malloc+0xee>
  50:	4509                	li	a0,2
  52:	00000097          	auipc	ra,0x0
  56:	5f4080e7          	jalr	1524(ra) # 646 <fprintf>
  5a:	4505                	li	a0,1
  5c:	00000097          	auipc	ra,0x0
  60:	298080e7          	jalr	664(ra) # 2f4 <exit>

0000000000000064 <_main>:
  64:	1141                	addi	sp,sp,-16
  66:	e406                	sd	ra,8(sp)
  68:	e022                	sd	s0,0(sp)
  6a:	0800                	addi	s0,sp,16
  6c:	00000097          	auipc	ra,0x0
  70:	f94080e7          	jalr	-108(ra) # 0 <main>
  74:	4501                	li	a0,0
  76:	00000097          	auipc	ra,0x0
  7a:	27e080e7          	jalr	638(ra) # 2f4 <exit>

000000000000007e <strcpy>:
  7e:	1141                	addi	sp,sp,-16
  80:	e422                	sd	s0,8(sp)
  82:	0800                	addi	s0,sp,16
  84:	87aa                	mv	a5,a0
  86:	0585                	addi	a1,a1,1
  88:	0785                	addi	a5,a5,1
  8a:	fff5c703          	lbu	a4,-1(a1)
  8e:	fee78fa3          	sb	a4,-1(a5)
  92:	fb75                	bnez	a4,86 <strcpy+0x8>
  94:	6422                	ld	s0,8(sp)
  96:	0141                	addi	sp,sp,16
  98:	8082                	ret

000000000000009a <strcmp>:
  9a:	1141                	addi	sp,sp,-16
  9c:	e422                	sd	s0,8(sp)
  9e:	0800                	addi	s0,sp,16
  a0:	00054783          	lbu	a5,0(a0)
  a4:	cb91                	beqz	a5,b8 <strcmp+0x1e>
  a6:	0005c703          	lbu	a4,0(a1)
  aa:	00f71763          	bne	a4,a5,b8 <strcmp+0x1e>
  ae:	0505                	addi	a0,a0,1
  b0:	0585                	addi	a1,a1,1
  b2:	00054783          	lbu	a5,0(a0)
  b6:	fbe5                	bnez	a5,a6 <strcmp+0xc>
  b8:	0005c503          	lbu	a0,0(a1)
  bc:	40a7853b          	subw	a0,a5,a0
  c0:	6422                	ld	s0,8(sp)
  c2:	0141                	addi	sp,sp,16
  c4:	8082                	ret

00000000000000c6 <strlen>:
  c6:	1141                	addi	sp,sp,-16
  c8:	e422                	sd	s0,8(sp)
  ca:	0800                	addi	s0,sp,16
  cc:	00054783          	lbu	a5,0(a0)
  d0:	cf91                	beqz	a5,ec <strlen+0x26>
  d2:	0505                	addi	a0,a0,1
  d4:	87aa                	mv	a5,a0
  d6:	4685                	li	a3,1
  d8:	9e89                	subw	a3,a3,a0
  da:	00f6853b          	addw	a0,a3,a5
  de:	0785                	addi	a5,a5,1
  e0:	fff7c703          	lbu	a4,-1(a5)
  e4:	fb7d                	bnez	a4,da <strlen+0x14>
  e6:	6422                	ld	s0,8(sp)
  e8:	0141                	addi	sp,sp,16
  ea:	8082                	ret
  ec:	4501                	li	a0,0
  ee:	bfe5                	j	e6 <strlen+0x20>

00000000000000f0 <memset>:
  f0:	1141                	addi	sp,sp,-16
  f2:	e422                	sd	s0,8(sp)
  f4:	0800                	addi	s0,sp,16
  f6:	ce09                	beqz	a2,110 <memset+0x20>
  f8:	87aa                	mv	a5,a0
  fa:	fff6071b          	addiw	a4,a2,-1
  fe:	1702                	slli	a4,a4,0x20
 100:	9301                	srli	a4,a4,0x20
 102:	0705                	addi	a4,a4,1
 104:	972a                	add	a4,a4,a0
 106:	00b78023          	sb	a1,0(a5)
 10a:	0785                	addi	a5,a5,1
 10c:	fee79de3          	bne	a5,a4,106 <memset+0x16>
 110:	6422                	ld	s0,8(sp)
 112:	0141                	addi	sp,sp,16
 114:	8082                	ret

0000000000000116 <strchr>:
 116:	1141                	addi	sp,sp,-16
 118:	e422                	sd	s0,8(sp)
 11a:	0800                	addi	s0,sp,16
 11c:	00054783          	lbu	a5,0(a0)
 120:	cb99                	beqz	a5,136 <strchr+0x20>
 122:	00f58763          	beq	a1,a5,130 <strchr+0x1a>
 126:	0505                	addi	a0,a0,1
 128:	00054783          	lbu	a5,0(a0)
 12c:	fbfd                	bnez	a5,122 <strchr+0xc>
 12e:	4501                	li	a0,0
 130:	6422                	ld	s0,8(sp)
 132:	0141                	addi	sp,sp,16
 134:	8082                	ret
 136:	4501                	li	a0,0
 138:	bfe5                	j	130 <strchr+0x1a>

000000000000013a <gets>:
 13a:	711d                	addi	sp,sp,-96
 13c:	ec86                	sd	ra,88(sp)
 13e:	e8a2                	sd	s0,80(sp)
 140:	e4a6                	sd	s1,72(sp)
 142:	e0ca                	sd	s2,64(sp)
 144:	fc4e                	sd	s3,56(sp)
 146:	f852                	sd	s4,48(sp)
 148:	f456                	sd	s5,40(sp)
 14a:	f05a                	sd	s6,32(sp)
 14c:	ec5e                	sd	s7,24(sp)
 14e:	1080                	addi	s0,sp,96
 150:	8baa                	mv	s7,a0
 152:	8a2e                	mv	s4,a1
 154:	892a                	mv	s2,a0
 156:	4481                	li	s1,0
 158:	4aa9                	li	s5,10
 15a:	4b35                	li	s6,13
 15c:	89a6                	mv	s3,s1
 15e:	2485                	addiw	s1,s1,1
 160:	0344d863          	bge	s1,s4,190 <gets+0x56>
 164:	4605                	li	a2,1
 166:	faf40593          	addi	a1,s0,-81
 16a:	4501                	li	a0,0
 16c:	00000097          	auipc	ra,0x0
 170:	1a0080e7          	jalr	416(ra) # 30c <read>
 174:	00a05e63          	blez	a0,190 <gets+0x56>
 178:	faf44783          	lbu	a5,-81(s0)
 17c:	00f90023          	sb	a5,0(s2)
 180:	01578763          	beq	a5,s5,18e <gets+0x54>
 184:	0905                	addi	s2,s2,1
 186:	fd679be3          	bne	a5,s6,15c <gets+0x22>
 18a:	89a6                	mv	s3,s1
 18c:	a011                	j	190 <gets+0x56>
 18e:	89a6                	mv	s3,s1
 190:	99de                	add	s3,s3,s7
 192:	00098023          	sb	zero,0(s3)
 196:	855e                	mv	a0,s7
 198:	60e6                	ld	ra,88(sp)
 19a:	6446                	ld	s0,80(sp)
 19c:	64a6                	ld	s1,72(sp)
 19e:	6906                	ld	s2,64(sp)
 1a0:	79e2                	ld	s3,56(sp)
 1a2:	7a42                	ld	s4,48(sp)
 1a4:	7aa2                	ld	s5,40(sp)
 1a6:	7b02                	ld	s6,32(sp)
 1a8:	6be2                	ld	s7,24(sp)
 1aa:	6125                	addi	sp,sp,96
 1ac:	8082                	ret

00000000000001ae <stat>:
 1ae:	1101                	addi	sp,sp,-32
 1b0:	ec06                	sd	ra,24(sp)
 1b2:	e822                	sd	s0,16(sp)
 1b4:	e426                	sd	s1,8(sp)
 1b6:	e04a                	sd	s2,0(sp)
 1b8:	1000                	addi	s0,sp,32
 1ba:	892e                	mv	s2,a1
 1bc:	4581                	li	a1,0
 1be:	00000097          	auipc	ra,0x0
 1c2:	176080e7          	jalr	374(ra) # 334 <open>
 1c6:	02054563          	bltz	a0,1f0 <stat+0x42>
 1ca:	84aa                	mv	s1,a0
 1cc:	85ca                	mv	a1,s2
 1ce:	00000097          	auipc	ra,0x0
 1d2:	17e080e7          	jalr	382(ra) # 34c <fstat>
 1d6:	892a                	mv	s2,a0
 1d8:	8526                	mv	a0,s1
 1da:	00000097          	auipc	ra,0x0
 1de:	142080e7          	jalr	322(ra) # 31c <close>
 1e2:	854a                	mv	a0,s2
 1e4:	60e2                	ld	ra,24(sp)
 1e6:	6442                	ld	s0,16(sp)
 1e8:	64a2                	ld	s1,8(sp)
 1ea:	6902                	ld	s2,0(sp)
 1ec:	6105                	addi	sp,sp,32
 1ee:	8082                	ret
 1f0:	597d                	li	s2,-1
 1f2:	bfc5                	j	1e2 <stat+0x34>

00000000000001f4 <atoi>:
 1f4:	1141                	addi	sp,sp,-16
 1f6:	e422                	sd	s0,8(sp)
 1f8:	0800                	addi	s0,sp,16
 1fa:	00054603          	lbu	a2,0(a0)
 1fe:	fd06079b          	addiw	a5,a2,-48
 202:	0ff7f793          	andi	a5,a5,255
 206:	4725                	li	a4,9
 208:	02f76963          	bltu	a4,a5,23a <atoi+0x46>
 20c:	86aa                	mv	a3,a0
 20e:	4501                	li	a0,0
 210:	45a5                	li	a1,9
 212:	0685                	addi	a3,a3,1
 214:	0025179b          	slliw	a5,a0,0x2
 218:	9fa9                	addw	a5,a5,a0
 21a:	0017979b          	slliw	a5,a5,0x1
 21e:	9fb1                	addw	a5,a5,a2
 220:	fd07851b          	addiw	a0,a5,-48
 224:	0006c603          	lbu	a2,0(a3)
 228:	fd06071b          	addiw	a4,a2,-48
 22c:	0ff77713          	andi	a4,a4,255
 230:	fee5f1e3          	bgeu	a1,a4,212 <atoi+0x1e>
 234:	6422                	ld	s0,8(sp)
 236:	0141                	addi	sp,sp,16
 238:	8082                	ret
 23a:	4501                	li	a0,0
 23c:	bfe5                	j	234 <atoi+0x40>

000000000000023e <memmove>:
 23e:	1141                	addi	sp,sp,-16
 240:	e422                	sd	s0,8(sp)
 242:	0800                	addi	s0,sp,16
 244:	02b57663          	bgeu	a0,a1,270 <memmove+0x32>
 248:	02c05163          	blez	a2,26a <memmove+0x2c>
 24c:	fff6079b          	addiw	a5,a2,-1
 250:	1782                	slli	a5,a5,0x20
 252:	9381                	srli	a5,a5,0x20
 254:	0785                	addi	a5,a5,1
 256:	97aa                	add	a5,a5,a0
 258:	872a                	mv	a4,a0
 25a:	0585                	addi	a1,a1,1
 25c:	0705                	addi	a4,a4,1
 25e:	fff5c683          	lbu	a3,-1(a1)
 262:	fed70fa3          	sb	a3,-1(a4)
 266:	fee79ae3          	bne	a5,a4,25a <memmove+0x1c>
 26a:	6422                	ld	s0,8(sp)
 26c:	0141                	addi	sp,sp,16
 26e:	8082                	ret
 270:	00c50733          	add	a4,a0,a2
 274:	95b2                	add	a1,a1,a2
 276:	fec05ae3          	blez	a2,26a <memmove+0x2c>
 27a:	fff6079b          	addiw	a5,a2,-1
 27e:	1782                	slli	a5,a5,0x20
 280:	9381                	srli	a5,a5,0x20
 282:	fff7c793          	not	a5,a5
 286:	97ba                	add	a5,a5,a4
 288:	15fd                	addi	a1,a1,-1
 28a:	177d                	addi	a4,a4,-1
 28c:	0005c683          	lbu	a3,0(a1)
 290:	00d70023          	sb	a3,0(a4)
 294:	fee79ae3          	bne	a5,a4,288 <memmove+0x4a>
 298:	bfc9                	j	26a <memmove+0x2c>

000000000000029a <memcmp>:
 29a:	1141                	addi	sp,sp,-16
 29c:	e422                	sd	s0,8(sp)
 29e:	0800                	addi	s0,sp,16
 2a0:	ca05                	beqz	a2,2d0 <memcmp+0x36>
 2a2:	fff6069b          	addiw	a3,a2,-1
 2a6:	1682                	slli	a3,a3,0x20
 2a8:	9281                	srli	a3,a3,0x20
 2aa:	0685                	addi	a3,a3,1
 2ac:	96aa                	add	a3,a3,a0
 2ae:	00054783          	lbu	a5,0(a0)
 2b2:	0005c703          	lbu	a4,0(a1)
 2b6:	00e79863          	bne	a5,a4,2c6 <memcmp+0x2c>
 2ba:	0505                	addi	a0,a0,1
 2bc:	0585                	addi	a1,a1,1
 2be:	fed518e3          	bne	a0,a3,2ae <memcmp+0x14>
 2c2:	4501                	li	a0,0
 2c4:	a019                	j	2ca <memcmp+0x30>
 2c6:	40e7853b          	subw	a0,a5,a4
 2ca:	6422                	ld	s0,8(sp)
 2cc:	0141                	addi	sp,sp,16
 2ce:	8082                	ret
 2d0:	4501                	li	a0,0
 2d2:	bfe5                	j	2ca <memcmp+0x30>

00000000000002d4 <memcpy>:
 2d4:	1141                	addi	sp,sp,-16
 2d6:	e406                	sd	ra,8(sp)
 2d8:	e022                	sd	s0,0(sp)
 2da:	0800                	addi	s0,sp,16
 2dc:	00000097          	auipc	ra,0x0
 2e0:	f62080e7          	jalr	-158(ra) # 23e <memmove>
 2e4:	60a2                	ld	ra,8(sp)
 2e6:	6402                	ld	s0,0(sp)
 2e8:	0141                	addi	sp,sp,16
 2ea:	8082                	ret

00000000000002ec <fork>:
 2ec:	4885                	li	a7,1
 2ee:	00000073          	ecall
 2f2:	8082                	ret

00000000000002f4 <exit>:
 2f4:	4889                	li	a7,2
 2f6:	00000073          	ecall
 2fa:	8082                	ret

00000000000002fc <wait>:
 2fc:	488d                	li	a7,3
 2fe:	00000073          	ecall
 302:	8082                	ret

0000000000000304 <pipe>:
 304:	4891                	li	a7,4
 306:	00000073          	ecall
 30a:	8082                	ret

000000000000030c <read>:
 30c:	4895                	li	a7,5
 30e:	00000073          	ecall
 312:	8082                	ret

0000000000000314 <write>:
 314:	48c1                	li	a7,16
 316:	00000073          	ecall
 31a:	8082                	ret

000000000000031c <close>:
 31c:	48d5                	li	a7,21
 31e:	00000073          	ecall
 322:	8082                	ret

0000000000000324 <kill>:
 324:	4899                	li	a7,6
 326:	00000073          	ecall
 32a:	8082                	ret

000000000000032c <exec>:
 32c:	489d                	li	a7,7
 32e:	00000073          	ecall
 332:	8082                	ret

0000000000000334 <open>:
 334:	48bd                	li	a7,15
 336:	00000073          	ecall
 33a:	8082                	ret

000000000000033c <mknod>:
 33c:	48c5                	li	a7,17
 33e:	00000073          	ecall
 342:	8082                	ret

0000000000000344 <unlink>:
 344:	48c9                	li	a7,18
 346:	00000073          	ecall
 34a:	8082                	ret

000000000000034c <fstat>:
 34c:	48a1                	li	a7,8
 34e:	00000073          	ecall
 352:	8082                	ret

0000000000000354 <link>:
 354:	48cd                	li	a7,19
 356:	00000073          	ecall
 35a:	8082                	ret

000000000000035c <mkdir>:
 35c:	48d1                	li	a7,20
 35e:	00000073          	ecall
 362:	8082                	ret

0000000000000364 <chdir>:
 364:	48a5                	li	a7,9
 366:	00000073          	ecall
 36a:	8082                	ret

000000000000036c <dup>:
 36c:	48a9                	li	a7,10
 36e:	00000073          	ecall
 372:	8082                	ret

0000000000000374 <getpid>:
 374:	48ad                	li	a7,11
 376:	00000073          	ecall
 37a:	8082                	ret

000000000000037c <sbrk>:
 37c:	48b1                	li	a7,12
 37e:	00000073          	ecall
 382:	8082                	ret

0000000000000384 <sleep>:
 384:	48b5                	li	a7,13
 386:	00000073          	ecall
 38a:	8082                	ret

000000000000038c <uptime>:
 38c:	48b9                	li	a7,14
 38e:	00000073          	ecall
 392:	8082                	ret

0000000000000394 <trace>:
 394:	48d9                	li	a7,22
 396:	00000073          	ecall
 39a:	8082                	ret

000000000000039c <putc>:
 39c:	1101                	addi	sp,sp,-32
 39e:	ec06                	sd	ra,24(sp)
 3a0:	e822                	sd	s0,16(sp)
 3a2:	1000                	addi	s0,sp,32
 3a4:	feb407a3          	sb	a1,-17(s0)
 3a8:	4605                	li	a2,1
 3aa:	fef40593          	addi	a1,s0,-17
 3ae:	00000097          	auipc	ra,0x0
 3b2:	f66080e7          	jalr	-154(ra) # 314 <write>
 3b6:	60e2                	ld	ra,24(sp)
 3b8:	6442                	ld	s0,16(sp)
 3ba:	6105                	addi	sp,sp,32
 3bc:	8082                	ret

00000000000003be <printint>:
 3be:	7139                	addi	sp,sp,-64
 3c0:	fc06                	sd	ra,56(sp)
 3c2:	f822                	sd	s0,48(sp)
 3c4:	f426                	sd	s1,40(sp)
 3c6:	f04a                	sd	s2,32(sp)
 3c8:	ec4e                	sd	s3,24(sp)
 3ca:	0080                	addi	s0,sp,64
 3cc:	84aa                	mv	s1,a0
 3ce:	c299                	beqz	a3,3d4 <printint+0x16>
 3d0:	0805c863          	bltz	a1,460 <printint+0xa2>
 3d4:	2581                	sext.w	a1,a1
 3d6:	4881                	li	a7,0
 3d8:	fc040693          	addi	a3,s0,-64
 3dc:	4701                	li	a4,0
 3de:	2601                	sext.w	a2,a2
 3e0:	00000517          	auipc	a0,0x0
 3e4:	46050513          	addi	a0,a0,1120 # 840 <digits>
 3e8:	883a                	mv	a6,a4
 3ea:	2705                	addiw	a4,a4,1
 3ec:	02c5f7bb          	remuw	a5,a1,a2
 3f0:	1782                	slli	a5,a5,0x20
 3f2:	9381                	srli	a5,a5,0x20
 3f4:	97aa                	add	a5,a5,a0
 3f6:	0007c783          	lbu	a5,0(a5)
 3fa:	00f68023          	sb	a5,0(a3)
 3fe:	0005879b          	sext.w	a5,a1
 402:	02c5d5bb          	divuw	a1,a1,a2
 406:	0685                	addi	a3,a3,1
 408:	fec7f0e3          	bgeu	a5,a2,3e8 <printint+0x2a>
 40c:	00088b63          	beqz	a7,422 <printint+0x64>
 410:	fd040793          	addi	a5,s0,-48
 414:	973e                	add	a4,a4,a5
 416:	02d00793          	li	a5,45
 41a:	fef70823          	sb	a5,-16(a4)
 41e:	0028071b          	addiw	a4,a6,2
 422:	02e05863          	blez	a4,452 <printint+0x94>
 426:	fc040793          	addi	a5,s0,-64
 42a:	00e78933          	add	s2,a5,a4
 42e:	fff78993          	addi	s3,a5,-1
 432:	99ba                	add	s3,s3,a4
 434:	377d                	addiw	a4,a4,-1
 436:	1702                	slli	a4,a4,0x20
 438:	9301                	srli	a4,a4,0x20
 43a:	40e989b3          	sub	s3,s3,a4
 43e:	fff94583          	lbu	a1,-1(s2)
 442:	8526                	mv	a0,s1
 444:	00000097          	auipc	ra,0x0
 448:	f58080e7          	jalr	-168(ra) # 39c <putc>
 44c:	197d                	addi	s2,s2,-1
 44e:	ff3918e3          	bne	s2,s3,43e <printint+0x80>
 452:	70e2                	ld	ra,56(sp)
 454:	7442                	ld	s0,48(sp)
 456:	74a2                	ld	s1,40(sp)
 458:	7902                	ld	s2,32(sp)
 45a:	69e2                	ld	s3,24(sp)
 45c:	6121                	addi	sp,sp,64
 45e:	8082                	ret
 460:	40b005bb          	negw	a1,a1
 464:	4885                	li	a7,1
 466:	bf8d                	j	3d8 <printint+0x1a>

0000000000000468 <vprintf>:
 468:	7119                	addi	sp,sp,-128
 46a:	fc86                	sd	ra,120(sp)
 46c:	f8a2                	sd	s0,112(sp)
 46e:	f4a6                	sd	s1,104(sp)
 470:	f0ca                	sd	s2,96(sp)
 472:	ecce                	sd	s3,88(sp)
 474:	e8d2                	sd	s4,80(sp)
 476:	e4d6                	sd	s5,72(sp)
 478:	e0da                	sd	s6,64(sp)
 47a:	fc5e                	sd	s7,56(sp)
 47c:	f862                	sd	s8,48(sp)
 47e:	f466                	sd	s9,40(sp)
 480:	f06a                	sd	s10,32(sp)
 482:	ec6e                	sd	s11,24(sp)
 484:	0100                	addi	s0,sp,128
 486:	0005c903          	lbu	s2,0(a1)
 48a:	18090f63          	beqz	s2,628 <vprintf+0x1c0>
 48e:	8aaa                	mv	s5,a0
 490:	8b32                	mv	s6,a2
 492:	00158493          	addi	s1,a1,1
 496:	4981                	li	s3,0
 498:	02500a13          	li	s4,37
 49c:	06400c13          	li	s8,100
 4a0:	06c00c93          	li	s9,108
 4a4:	07800d13          	li	s10,120
 4a8:	07000d93          	li	s11,112
 4ac:	00000b97          	auipc	s7,0x0
 4b0:	394b8b93          	addi	s7,s7,916 # 840 <digits>
 4b4:	a839                	j	4d2 <vprintf+0x6a>
 4b6:	85ca                	mv	a1,s2
 4b8:	8556                	mv	a0,s5
 4ba:	00000097          	auipc	ra,0x0
 4be:	ee2080e7          	jalr	-286(ra) # 39c <putc>
 4c2:	a019                	j	4c8 <vprintf+0x60>
 4c4:	01498f63          	beq	s3,s4,4e2 <vprintf+0x7a>
 4c8:	0485                	addi	s1,s1,1
 4ca:	fff4c903          	lbu	s2,-1(s1)
 4ce:	14090d63          	beqz	s2,628 <vprintf+0x1c0>
 4d2:	0009079b          	sext.w	a5,s2
 4d6:	fe0997e3          	bnez	s3,4c4 <vprintf+0x5c>
 4da:	fd479ee3          	bne	a5,s4,4b6 <vprintf+0x4e>
 4de:	89be                	mv	s3,a5
 4e0:	b7e5                	j	4c8 <vprintf+0x60>
 4e2:	05878063          	beq	a5,s8,522 <vprintf+0xba>
 4e6:	05978c63          	beq	a5,s9,53e <vprintf+0xd6>
 4ea:	07a78863          	beq	a5,s10,55a <vprintf+0xf2>
 4ee:	09b78463          	beq	a5,s11,576 <vprintf+0x10e>
 4f2:	07300713          	li	a4,115
 4f6:	0ce78663          	beq	a5,a4,5c2 <vprintf+0x15a>
 4fa:	06300713          	li	a4,99
 4fe:	0ee78e63          	beq	a5,a4,5fa <vprintf+0x192>
 502:	11478863          	beq	a5,s4,612 <vprintf+0x1aa>
 506:	85d2                	mv	a1,s4
 508:	8556                	mv	a0,s5
 50a:	00000097          	auipc	ra,0x0
 50e:	e92080e7          	jalr	-366(ra) # 39c <putc>
 512:	85ca                	mv	a1,s2
 514:	8556                	mv	a0,s5
 516:	00000097          	auipc	ra,0x0
 51a:	e86080e7          	jalr	-378(ra) # 39c <putc>
 51e:	4981                	li	s3,0
 520:	b765                	j	4c8 <vprintf+0x60>
 522:	008b0913          	addi	s2,s6,8
 526:	4685                	li	a3,1
 528:	4629                	li	a2,10
 52a:	000b2583          	lw	a1,0(s6)
 52e:	8556                	mv	a0,s5
 530:	00000097          	auipc	ra,0x0
 534:	e8e080e7          	jalr	-370(ra) # 3be <printint>
 538:	8b4a                	mv	s6,s2
 53a:	4981                	li	s3,0
 53c:	b771                	j	4c8 <vprintf+0x60>
 53e:	008b0913          	addi	s2,s6,8
 542:	4681                	li	a3,0
 544:	4629                	li	a2,10
 546:	000b2583          	lw	a1,0(s6)
 54a:	8556                	mv	a0,s5
 54c:	00000097          	auipc	ra,0x0
 550:	e72080e7          	jalr	-398(ra) # 3be <printint>
 554:	8b4a                	mv	s6,s2
 556:	4981                	li	s3,0
 558:	bf85                	j	4c8 <vprintf+0x60>
 55a:	008b0913          	addi	s2,s6,8
 55e:	4681                	li	a3,0
 560:	4641                	li	a2,16
 562:	000b2583          	lw	a1,0(s6)
 566:	8556                	mv	a0,s5
 568:	00000097          	auipc	ra,0x0
 56c:	e56080e7          	jalr	-426(ra) # 3be <printint>
 570:	8b4a                	mv	s6,s2
 572:	4981                	li	s3,0
 574:	bf91                	j	4c8 <vprintf+0x60>
 576:	008b0793          	addi	a5,s6,8
 57a:	f8f43423          	sd	a5,-120(s0)
 57e:	000b3983          	ld	s3,0(s6)
 582:	03000593          	li	a1,48
 586:	8556                	mv	a0,s5
 588:	00000097          	auipc	ra,0x0
 58c:	e14080e7          	jalr	-492(ra) # 39c <putc>
 590:	85ea                	mv	a1,s10
 592:	8556                	mv	a0,s5
 594:	00000097          	auipc	ra,0x0
 598:	e08080e7          	jalr	-504(ra) # 39c <putc>
 59c:	4941                	li	s2,16
 59e:	03c9d793          	srli	a5,s3,0x3c
 5a2:	97de                	add	a5,a5,s7
 5a4:	0007c583          	lbu	a1,0(a5)
 5a8:	8556                	mv	a0,s5
 5aa:	00000097          	auipc	ra,0x0
 5ae:	df2080e7          	jalr	-526(ra) # 39c <putc>
 5b2:	0992                	slli	s3,s3,0x4
 5b4:	397d                	addiw	s2,s2,-1
 5b6:	fe0914e3          	bnez	s2,59e <vprintf+0x136>
 5ba:	f8843b03          	ld	s6,-120(s0)
 5be:	4981                	li	s3,0
 5c0:	b721                	j	4c8 <vprintf+0x60>
 5c2:	008b0993          	addi	s3,s6,8
 5c6:	000b3903          	ld	s2,0(s6)
 5ca:	02090163          	beqz	s2,5ec <vprintf+0x184>
 5ce:	00094583          	lbu	a1,0(s2)
 5d2:	c9a1                	beqz	a1,622 <vprintf+0x1ba>
 5d4:	8556                	mv	a0,s5
 5d6:	00000097          	auipc	ra,0x0
 5da:	dc6080e7          	jalr	-570(ra) # 39c <putc>
 5de:	0905                	addi	s2,s2,1
 5e0:	00094583          	lbu	a1,0(s2)
 5e4:	f9e5                	bnez	a1,5d4 <vprintf+0x16c>
 5e6:	8b4e                	mv	s6,s3
 5e8:	4981                	li	s3,0
 5ea:	bdf9                	j	4c8 <vprintf+0x60>
 5ec:	00000917          	auipc	s2,0x0
 5f0:	24c90913          	addi	s2,s2,588 # 838 <malloc+0x106>
 5f4:	02800593          	li	a1,40
 5f8:	bff1                	j	5d4 <vprintf+0x16c>
 5fa:	008b0913          	addi	s2,s6,8
 5fe:	000b4583          	lbu	a1,0(s6)
 602:	8556                	mv	a0,s5
 604:	00000097          	auipc	ra,0x0
 608:	d98080e7          	jalr	-616(ra) # 39c <putc>
 60c:	8b4a                	mv	s6,s2
 60e:	4981                	li	s3,0
 610:	bd65                	j	4c8 <vprintf+0x60>
 612:	85d2                	mv	a1,s4
 614:	8556                	mv	a0,s5
 616:	00000097          	auipc	ra,0x0
 61a:	d86080e7          	jalr	-634(ra) # 39c <putc>
 61e:	4981                	li	s3,0
 620:	b565                	j	4c8 <vprintf+0x60>
 622:	8b4e                	mv	s6,s3
 624:	4981                	li	s3,0
 626:	b54d                	j	4c8 <vprintf+0x60>
 628:	70e6                	ld	ra,120(sp)
 62a:	7446                	ld	s0,112(sp)
 62c:	74a6                	ld	s1,104(sp)
 62e:	7906                	ld	s2,96(sp)
 630:	69e6                	ld	s3,88(sp)
 632:	6a46                	ld	s4,80(sp)
 634:	6aa6                	ld	s5,72(sp)
 636:	6b06                	ld	s6,64(sp)
 638:	7be2                	ld	s7,56(sp)
 63a:	7c42                	ld	s8,48(sp)
 63c:	7ca2                	ld	s9,40(sp)
 63e:	7d02                	ld	s10,32(sp)
 640:	6de2                	ld	s11,24(sp)
 642:	6109                	addi	sp,sp,128
 644:	8082                	ret

0000000000000646 <fprintf>:
 646:	715d                	addi	sp,sp,-80
 648:	ec06                	sd	ra,24(sp)
 64a:	e822                	sd	s0,16(sp)
 64c:	1000                	addi	s0,sp,32
 64e:	e010                	sd	a2,0(s0)
 650:	e414                	sd	a3,8(s0)
 652:	e818                	sd	a4,16(s0)
 654:	ec1c                	sd	a5,24(s0)
 656:	03043023          	sd	a6,32(s0)
 65a:	03143423          	sd	a7,40(s0)
 65e:	fe843423          	sd	s0,-24(s0)
 662:	8622                	mv	a2,s0
 664:	00000097          	auipc	ra,0x0
 668:	e04080e7          	jalr	-508(ra) # 468 <vprintf>
 66c:	60e2                	ld	ra,24(sp)
 66e:	6442                	ld	s0,16(sp)
 670:	6161                	addi	sp,sp,80
 672:	8082                	ret

0000000000000674 <printf>:
 674:	711d                	addi	sp,sp,-96
 676:	ec06                	sd	ra,24(sp)
 678:	e822                	sd	s0,16(sp)
 67a:	1000                	addi	s0,sp,32
 67c:	e40c                	sd	a1,8(s0)
 67e:	e810                	sd	a2,16(s0)
 680:	ec14                	sd	a3,24(s0)
 682:	f018                	sd	a4,32(s0)
 684:	f41c                	sd	a5,40(s0)
 686:	03043823          	sd	a6,48(s0)
 68a:	03143c23          	sd	a7,56(s0)
 68e:	00840613          	addi	a2,s0,8
 692:	fec43423          	sd	a2,-24(s0)
 696:	85aa                	mv	a1,a0
 698:	4505                	li	a0,1
 69a:	00000097          	auipc	ra,0x0
 69e:	dce080e7          	jalr	-562(ra) # 468 <vprintf>
 6a2:	60e2                	ld	ra,24(sp)
 6a4:	6442                	ld	s0,16(sp)
 6a6:	6125                	addi	sp,sp,96
 6a8:	8082                	ret

00000000000006aa <free>:
 6aa:	1141                	addi	sp,sp,-16
 6ac:	e422                	sd	s0,8(sp)
 6ae:	0800                	addi	s0,sp,16
 6b0:	ff050693          	addi	a3,a0,-16
 6b4:	00001797          	auipc	a5,0x1
 6b8:	94c7b783          	ld	a5,-1716(a5) # 1000 <freep>
 6bc:	a805                	j	6ec <free+0x42>
 6be:	4618                	lw	a4,8(a2)
 6c0:	9db9                	addw	a1,a1,a4
 6c2:	feb52c23          	sw	a1,-8(a0)
 6c6:	6398                	ld	a4,0(a5)
 6c8:	6318                	ld	a4,0(a4)
 6ca:	fee53823          	sd	a4,-16(a0)
 6ce:	a091                	j	712 <free+0x68>
 6d0:	ff852703          	lw	a4,-8(a0)
 6d4:	9e39                	addw	a2,a2,a4
 6d6:	c790                	sw	a2,8(a5)
 6d8:	ff053703          	ld	a4,-16(a0)
 6dc:	e398                	sd	a4,0(a5)
 6de:	a099                	j	724 <free+0x7a>
 6e0:	6398                	ld	a4,0(a5)
 6e2:	00e7e463          	bltu	a5,a4,6ea <free+0x40>
 6e6:	00e6ea63          	bltu	a3,a4,6fa <free+0x50>
 6ea:	87ba                	mv	a5,a4
 6ec:	fed7fae3          	bgeu	a5,a3,6e0 <free+0x36>
 6f0:	6398                	ld	a4,0(a5)
 6f2:	00e6e463          	bltu	a3,a4,6fa <free+0x50>
 6f6:	fee7eae3          	bltu	a5,a4,6ea <free+0x40>
 6fa:	ff852583          	lw	a1,-8(a0)
 6fe:	6390                	ld	a2,0(a5)
 700:	02059713          	slli	a4,a1,0x20
 704:	9301                	srli	a4,a4,0x20
 706:	0712                	slli	a4,a4,0x4
 708:	9736                	add	a4,a4,a3
 70a:	fae60ae3          	beq	a2,a4,6be <free+0x14>
 70e:	fec53823          	sd	a2,-16(a0)
 712:	4790                	lw	a2,8(a5)
 714:	02061713          	slli	a4,a2,0x20
 718:	9301                	srli	a4,a4,0x20
 71a:	0712                	slli	a4,a4,0x4
 71c:	973e                	add	a4,a4,a5
 71e:	fae689e3          	beq	a3,a4,6d0 <free+0x26>
 722:	e394                	sd	a3,0(a5)
 724:	00001717          	auipc	a4,0x1
 728:	8cf73e23          	sd	a5,-1828(a4) # 1000 <freep>
 72c:	6422                	ld	s0,8(sp)
 72e:	0141                	addi	sp,sp,16
 730:	8082                	ret

0000000000000732 <malloc>:
 732:	7139                	addi	sp,sp,-64
 734:	fc06                	sd	ra,56(sp)
 736:	f822                	sd	s0,48(sp)
 738:	f426                	sd	s1,40(sp)
 73a:	f04a                	sd	s2,32(sp)
 73c:	ec4e                	sd	s3,24(sp)
 73e:	e852                	sd	s4,16(sp)
 740:	e456                	sd	s5,8(sp)
 742:	e05a                	sd	s6,0(sp)
 744:	0080                	addi	s0,sp,64
 746:	02051493          	slli	s1,a0,0x20
 74a:	9081                	srli	s1,s1,0x20
 74c:	04bd                	addi	s1,s1,15
 74e:	8091                	srli	s1,s1,0x4
 750:	0014899b          	addiw	s3,s1,1
 754:	0485                	addi	s1,s1,1
 756:	00001517          	auipc	a0,0x1
 75a:	8aa53503          	ld	a0,-1878(a0) # 1000 <freep>
 75e:	c515                	beqz	a0,78a <malloc+0x58>
 760:	611c                	ld	a5,0(a0)
 762:	4798                	lw	a4,8(a5)
 764:	02977f63          	bgeu	a4,s1,7a2 <malloc+0x70>
 768:	8a4e                	mv	s4,s3
 76a:	0009871b          	sext.w	a4,s3
 76e:	6685                	lui	a3,0x1
 770:	00d77363          	bgeu	a4,a3,776 <malloc+0x44>
 774:	6a05                	lui	s4,0x1
 776:	000a0b1b          	sext.w	s6,s4
 77a:	004a1a1b          	slliw	s4,s4,0x4
 77e:	00001917          	auipc	s2,0x1
 782:	88290913          	addi	s2,s2,-1918 # 1000 <freep>
 786:	5afd                	li	s5,-1
 788:	a88d                	j	7fa <malloc+0xc8>
 78a:	00001797          	auipc	a5,0x1
 78e:	88678793          	addi	a5,a5,-1914 # 1010 <base>
 792:	00001717          	auipc	a4,0x1
 796:	86f73723          	sd	a5,-1938(a4) # 1000 <freep>
 79a:	e39c                	sd	a5,0(a5)
 79c:	0007a423          	sw	zero,8(a5)
 7a0:	b7e1                	j	768 <malloc+0x36>
 7a2:	02e48b63          	beq	s1,a4,7d8 <malloc+0xa6>
 7a6:	4137073b          	subw	a4,a4,s3
 7aa:	c798                	sw	a4,8(a5)
 7ac:	1702                	slli	a4,a4,0x20
 7ae:	9301                	srli	a4,a4,0x20
 7b0:	0712                	slli	a4,a4,0x4
 7b2:	97ba                	add	a5,a5,a4
 7b4:	0137a423          	sw	s3,8(a5)
 7b8:	00001717          	auipc	a4,0x1
 7bc:	84a73423          	sd	a0,-1976(a4) # 1000 <freep>
 7c0:	01078513          	addi	a0,a5,16
 7c4:	70e2                	ld	ra,56(sp)
 7c6:	7442                	ld	s0,48(sp)
 7c8:	74a2                	ld	s1,40(sp)
 7ca:	7902                	ld	s2,32(sp)
 7cc:	69e2                	ld	s3,24(sp)
 7ce:	6a42                	ld	s4,16(sp)
 7d0:	6aa2                	ld	s5,8(sp)
 7d2:	6b02                	ld	s6,0(sp)
 7d4:	6121                	addi	sp,sp,64
 7d6:	8082                	ret
 7d8:	6398                	ld	a4,0(a5)
 7da:	e118                	sd	a4,0(a0)
 7dc:	bff1                	j	7b8 <malloc+0x86>
 7de:	01652423          	sw	s6,8(a0)
 7e2:	0541                	addi	a0,a0,16
 7e4:	00000097          	auipc	ra,0x0
 7e8:	ec6080e7          	jalr	-314(ra) # 6aa <free>
 7ec:	00093503          	ld	a0,0(s2)
 7f0:	d971                	beqz	a0,7c4 <malloc+0x92>
 7f2:	611c                	ld	a5,0(a0)
 7f4:	4798                	lw	a4,8(a5)
 7f6:	fa9776e3          	bgeu	a4,s1,7a2 <malloc+0x70>
 7fa:	00093703          	ld	a4,0(s2)
 7fe:	853e                	mv	a0,a5
 800:	fef719e3          	bne	a4,a5,7f2 <malloc+0xc0>
 804:	8552                	mv	a0,s4
 806:	00000097          	auipc	ra,0x0
 80a:	b76080e7          	jalr	-1162(ra) # 37c <sbrk>
 80e:	fd5518e3          	bne	a0,s5,7de <malloc+0xac>
 812:	4501                	li	a0,0
 814:	bf45                	j	7c4 <malloc+0x92>
