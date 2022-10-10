
user/_echo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  10:	4785                	li	a5,1
  12:	06a7d463          	bge	a5,a0,7a <main+0x7a>
  16:	00858493          	addi	s1,a1,8
  1a:	ffe5099b          	addiw	s3,a0,-2
  1e:	1982                	slli	s3,s3,0x20
  20:	0209d993          	srli	s3,s3,0x20
  24:	098e                	slli	s3,s3,0x3
  26:	05c1                	addi	a1,a1,16
  28:	99ae                	add	s3,s3,a1
  2a:	00001a17          	auipc	s4,0x1
  2e:	816a0a13          	addi	s4,s4,-2026 # 840 <malloc+0xee>
  32:	0004b903          	ld	s2,0(s1)
  36:	854a                	mv	a0,s2
  38:	00000097          	auipc	ra,0x0
  3c:	0ae080e7          	jalr	174(ra) # e6 <strlen>
  40:	0005061b          	sext.w	a2,a0
  44:	85ca                	mv	a1,s2
  46:	4505                	li	a0,1
  48:	00000097          	auipc	ra,0x0
  4c:	2ec080e7          	jalr	748(ra) # 334 <write>
  50:	04a1                	addi	s1,s1,8
  52:	01348a63          	beq	s1,s3,66 <main+0x66>
  56:	4605                	li	a2,1
  58:	85d2                	mv	a1,s4
  5a:	4505                	li	a0,1
  5c:	00000097          	auipc	ra,0x0
  60:	2d8080e7          	jalr	728(ra) # 334 <write>
  64:	b7f9                	j	32 <main+0x32>
  66:	4605                	li	a2,1
  68:	00000597          	auipc	a1,0x0
  6c:	7e058593          	addi	a1,a1,2016 # 848 <malloc+0xf6>
  70:	4505                	li	a0,1
  72:	00000097          	auipc	ra,0x0
  76:	2c2080e7          	jalr	706(ra) # 334 <write>
  7a:	4501                	li	a0,0
  7c:	00000097          	auipc	ra,0x0
  80:	298080e7          	jalr	664(ra) # 314 <exit>

0000000000000084 <_main>:
  84:	1141                	addi	sp,sp,-16
  86:	e406                	sd	ra,8(sp)
  88:	e022                	sd	s0,0(sp)
  8a:	0800                	addi	s0,sp,16
  8c:	00000097          	auipc	ra,0x0
  90:	f74080e7          	jalr	-140(ra) # 0 <main>
  94:	4501                	li	a0,0
  96:	00000097          	auipc	ra,0x0
  9a:	27e080e7          	jalr	638(ra) # 314 <exit>

000000000000009e <strcpy>:
  9e:	1141                	addi	sp,sp,-16
  a0:	e422                	sd	s0,8(sp)
  a2:	0800                	addi	s0,sp,16
  a4:	87aa                	mv	a5,a0
  a6:	0585                	addi	a1,a1,1
  a8:	0785                	addi	a5,a5,1
  aa:	fff5c703          	lbu	a4,-1(a1)
  ae:	fee78fa3          	sb	a4,-1(a5)
  b2:	fb75                	bnez	a4,a6 <strcpy+0x8>
  b4:	6422                	ld	s0,8(sp)
  b6:	0141                	addi	sp,sp,16
  b8:	8082                	ret

00000000000000ba <strcmp>:
  ba:	1141                	addi	sp,sp,-16
  bc:	e422                	sd	s0,8(sp)
  be:	0800                	addi	s0,sp,16
  c0:	00054783          	lbu	a5,0(a0)
  c4:	cb91                	beqz	a5,d8 <strcmp+0x1e>
  c6:	0005c703          	lbu	a4,0(a1)
  ca:	00f71763          	bne	a4,a5,d8 <strcmp+0x1e>
  ce:	0505                	addi	a0,a0,1
  d0:	0585                	addi	a1,a1,1
  d2:	00054783          	lbu	a5,0(a0)
  d6:	fbe5                	bnez	a5,c6 <strcmp+0xc>
  d8:	0005c503          	lbu	a0,0(a1)
  dc:	40a7853b          	subw	a0,a5,a0
  e0:	6422                	ld	s0,8(sp)
  e2:	0141                	addi	sp,sp,16
  e4:	8082                	ret

00000000000000e6 <strlen>:
  e6:	1141                	addi	sp,sp,-16
  e8:	e422                	sd	s0,8(sp)
  ea:	0800                	addi	s0,sp,16
  ec:	00054783          	lbu	a5,0(a0)
  f0:	cf91                	beqz	a5,10c <strlen+0x26>
  f2:	0505                	addi	a0,a0,1
  f4:	87aa                	mv	a5,a0
  f6:	4685                	li	a3,1
  f8:	9e89                	subw	a3,a3,a0
  fa:	00f6853b          	addw	a0,a3,a5
  fe:	0785                	addi	a5,a5,1
 100:	fff7c703          	lbu	a4,-1(a5)
 104:	fb7d                	bnez	a4,fa <strlen+0x14>
 106:	6422                	ld	s0,8(sp)
 108:	0141                	addi	sp,sp,16
 10a:	8082                	ret
 10c:	4501                	li	a0,0
 10e:	bfe5                	j	106 <strlen+0x20>

0000000000000110 <memset>:
 110:	1141                	addi	sp,sp,-16
 112:	e422                	sd	s0,8(sp)
 114:	0800                	addi	s0,sp,16
 116:	ce09                	beqz	a2,130 <memset+0x20>
 118:	87aa                	mv	a5,a0
 11a:	fff6071b          	addiw	a4,a2,-1
 11e:	1702                	slli	a4,a4,0x20
 120:	9301                	srli	a4,a4,0x20
 122:	0705                	addi	a4,a4,1
 124:	972a                	add	a4,a4,a0
 126:	00b78023          	sb	a1,0(a5)
 12a:	0785                	addi	a5,a5,1
 12c:	fee79de3          	bne	a5,a4,126 <memset+0x16>
 130:	6422                	ld	s0,8(sp)
 132:	0141                	addi	sp,sp,16
 134:	8082                	ret

0000000000000136 <strchr>:
 136:	1141                	addi	sp,sp,-16
 138:	e422                	sd	s0,8(sp)
 13a:	0800                	addi	s0,sp,16
 13c:	00054783          	lbu	a5,0(a0)
 140:	cb99                	beqz	a5,156 <strchr+0x20>
 142:	00f58763          	beq	a1,a5,150 <strchr+0x1a>
 146:	0505                	addi	a0,a0,1
 148:	00054783          	lbu	a5,0(a0)
 14c:	fbfd                	bnez	a5,142 <strchr+0xc>
 14e:	4501                	li	a0,0
 150:	6422                	ld	s0,8(sp)
 152:	0141                	addi	sp,sp,16
 154:	8082                	ret
 156:	4501                	li	a0,0
 158:	bfe5                	j	150 <strchr+0x1a>

000000000000015a <gets>:
 15a:	711d                	addi	sp,sp,-96
 15c:	ec86                	sd	ra,88(sp)
 15e:	e8a2                	sd	s0,80(sp)
 160:	e4a6                	sd	s1,72(sp)
 162:	e0ca                	sd	s2,64(sp)
 164:	fc4e                	sd	s3,56(sp)
 166:	f852                	sd	s4,48(sp)
 168:	f456                	sd	s5,40(sp)
 16a:	f05a                	sd	s6,32(sp)
 16c:	ec5e                	sd	s7,24(sp)
 16e:	1080                	addi	s0,sp,96
 170:	8baa                	mv	s7,a0
 172:	8a2e                	mv	s4,a1
 174:	892a                	mv	s2,a0
 176:	4481                	li	s1,0
 178:	4aa9                	li	s5,10
 17a:	4b35                	li	s6,13
 17c:	89a6                	mv	s3,s1
 17e:	2485                	addiw	s1,s1,1
 180:	0344d863          	bge	s1,s4,1b0 <gets+0x56>
 184:	4605                	li	a2,1
 186:	faf40593          	addi	a1,s0,-81
 18a:	4501                	li	a0,0
 18c:	00000097          	auipc	ra,0x0
 190:	1a0080e7          	jalr	416(ra) # 32c <read>
 194:	00a05e63          	blez	a0,1b0 <gets+0x56>
 198:	faf44783          	lbu	a5,-81(s0)
 19c:	00f90023          	sb	a5,0(s2)
 1a0:	01578763          	beq	a5,s5,1ae <gets+0x54>
 1a4:	0905                	addi	s2,s2,1
 1a6:	fd679be3          	bne	a5,s6,17c <gets+0x22>
 1aa:	89a6                	mv	s3,s1
 1ac:	a011                	j	1b0 <gets+0x56>
 1ae:	89a6                	mv	s3,s1
 1b0:	99de                	add	s3,s3,s7
 1b2:	00098023          	sb	zero,0(s3)
 1b6:	855e                	mv	a0,s7
 1b8:	60e6                	ld	ra,88(sp)
 1ba:	6446                	ld	s0,80(sp)
 1bc:	64a6                	ld	s1,72(sp)
 1be:	6906                	ld	s2,64(sp)
 1c0:	79e2                	ld	s3,56(sp)
 1c2:	7a42                	ld	s4,48(sp)
 1c4:	7aa2                	ld	s5,40(sp)
 1c6:	7b02                	ld	s6,32(sp)
 1c8:	6be2                	ld	s7,24(sp)
 1ca:	6125                	addi	sp,sp,96
 1cc:	8082                	ret

00000000000001ce <stat>:
 1ce:	1101                	addi	sp,sp,-32
 1d0:	ec06                	sd	ra,24(sp)
 1d2:	e822                	sd	s0,16(sp)
 1d4:	e426                	sd	s1,8(sp)
 1d6:	e04a                	sd	s2,0(sp)
 1d8:	1000                	addi	s0,sp,32
 1da:	892e                	mv	s2,a1
 1dc:	4581                	li	a1,0
 1de:	00000097          	auipc	ra,0x0
 1e2:	176080e7          	jalr	374(ra) # 354 <open>
 1e6:	02054563          	bltz	a0,210 <stat+0x42>
 1ea:	84aa                	mv	s1,a0
 1ec:	85ca                	mv	a1,s2
 1ee:	00000097          	auipc	ra,0x0
 1f2:	17e080e7          	jalr	382(ra) # 36c <fstat>
 1f6:	892a                	mv	s2,a0
 1f8:	8526                	mv	a0,s1
 1fa:	00000097          	auipc	ra,0x0
 1fe:	142080e7          	jalr	322(ra) # 33c <close>
 202:	854a                	mv	a0,s2
 204:	60e2                	ld	ra,24(sp)
 206:	6442                	ld	s0,16(sp)
 208:	64a2                	ld	s1,8(sp)
 20a:	6902                	ld	s2,0(sp)
 20c:	6105                	addi	sp,sp,32
 20e:	8082                	ret
 210:	597d                	li	s2,-1
 212:	bfc5                	j	202 <stat+0x34>

0000000000000214 <atoi>:
 214:	1141                	addi	sp,sp,-16
 216:	e422                	sd	s0,8(sp)
 218:	0800                	addi	s0,sp,16
 21a:	00054603          	lbu	a2,0(a0)
 21e:	fd06079b          	addiw	a5,a2,-48
 222:	0ff7f793          	andi	a5,a5,255
 226:	4725                	li	a4,9
 228:	02f76963          	bltu	a4,a5,25a <atoi+0x46>
 22c:	86aa                	mv	a3,a0
 22e:	4501                	li	a0,0
 230:	45a5                	li	a1,9
 232:	0685                	addi	a3,a3,1
 234:	0025179b          	slliw	a5,a0,0x2
 238:	9fa9                	addw	a5,a5,a0
 23a:	0017979b          	slliw	a5,a5,0x1
 23e:	9fb1                	addw	a5,a5,a2
 240:	fd07851b          	addiw	a0,a5,-48
 244:	0006c603          	lbu	a2,0(a3)
 248:	fd06071b          	addiw	a4,a2,-48
 24c:	0ff77713          	andi	a4,a4,255
 250:	fee5f1e3          	bgeu	a1,a4,232 <atoi+0x1e>
 254:	6422                	ld	s0,8(sp)
 256:	0141                	addi	sp,sp,16
 258:	8082                	ret
 25a:	4501                	li	a0,0
 25c:	bfe5                	j	254 <atoi+0x40>

000000000000025e <memmove>:
 25e:	1141                	addi	sp,sp,-16
 260:	e422                	sd	s0,8(sp)
 262:	0800                	addi	s0,sp,16
 264:	02b57663          	bgeu	a0,a1,290 <memmove+0x32>
 268:	02c05163          	blez	a2,28a <memmove+0x2c>
 26c:	fff6079b          	addiw	a5,a2,-1
 270:	1782                	slli	a5,a5,0x20
 272:	9381                	srli	a5,a5,0x20
 274:	0785                	addi	a5,a5,1
 276:	97aa                	add	a5,a5,a0
 278:	872a                	mv	a4,a0
 27a:	0585                	addi	a1,a1,1
 27c:	0705                	addi	a4,a4,1
 27e:	fff5c683          	lbu	a3,-1(a1)
 282:	fed70fa3          	sb	a3,-1(a4)
 286:	fee79ae3          	bne	a5,a4,27a <memmove+0x1c>
 28a:	6422                	ld	s0,8(sp)
 28c:	0141                	addi	sp,sp,16
 28e:	8082                	ret
 290:	00c50733          	add	a4,a0,a2
 294:	95b2                	add	a1,a1,a2
 296:	fec05ae3          	blez	a2,28a <memmove+0x2c>
 29a:	fff6079b          	addiw	a5,a2,-1
 29e:	1782                	slli	a5,a5,0x20
 2a0:	9381                	srli	a5,a5,0x20
 2a2:	fff7c793          	not	a5,a5
 2a6:	97ba                	add	a5,a5,a4
 2a8:	15fd                	addi	a1,a1,-1
 2aa:	177d                	addi	a4,a4,-1
 2ac:	0005c683          	lbu	a3,0(a1)
 2b0:	00d70023          	sb	a3,0(a4)
 2b4:	fee79ae3          	bne	a5,a4,2a8 <memmove+0x4a>
 2b8:	bfc9                	j	28a <memmove+0x2c>

00000000000002ba <memcmp>:
 2ba:	1141                	addi	sp,sp,-16
 2bc:	e422                	sd	s0,8(sp)
 2be:	0800                	addi	s0,sp,16
 2c0:	ca05                	beqz	a2,2f0 <memcmp+0x36>
 2c2:	fff6069b          	addiw	a3,a2,-1
 2c6:	1682                	slli	a3,a3,0x20
 2c8:	9281                	srli	a3,a3,0x20
 2ca:	0685                	addi	a3,a3,1
 2cc:	96aa                	add	a3,a3,a0
 2ce:	00054783          	lbu	a5,0(a0)
 2d2:	0005c703          	lbu	a4,0(a1)
 2d6:	00e79863          	bne	a5,a4,2e6 <memcmp+0x2c>
 2da:	0505                	addi	a0,a0,1
 2dc:	0585                	addi	a1,a1,1
 2de:	fed518e3          	bne	a0,a3,2ce <memcmp+0x14>
 2e2:	4501                	li	a0,0
 2e4:	a019                	j	2ea <memcmp+0x30>
 2e6:	40e7853b          	subw	a0,a5,a4
 2ea:	6422                	ld	s0,8(sp)
 2ec:	0141                	addi	sp,sp,16
 2ee:	8082                	ret
 2f0:	4501                	li	a0,0
 2f2:	bfe5                	j	2ea <memcmp+0x30>

00000000000002f4 <memcpy>:
 2f4:	1141                	addi	sp,sp,-16
 2f6:	e406                	sd	ra,8(sp)
 2f8:	e022                	sd	s0,0(sp)
 2fa:	0800                	addi	s0,sp,16
 2fc:	00000097          	auipc	ra,0x0
 300:	f62080e7          	jalr	-158(ra) # 25e <memmove>
 304:	60a2                	ld	ra,8(sp)
 306:	6402                	ld	s0,0(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret

000000000000030c <fork>:
 30c:	4885                	li	a7,1
 30e:	00000073          	ecall
 312:	8082                	ret

0000000000000314 <exit>:
 314:	4889                	li	a7,2
 316:	00000073          	ecall
 31a:	8082                	ret

000000000000031c <wait>:
 31c:	488d                	li	a7,3
 31e:	00000073          	ecall
 322:	8082                	ret

0000000000000324 <pipe>:
 324:	4891                	li	a7,4
 326:	00000073          	ecall
 32a:	8082                	ret

000000000000032c <read>:
 32c:	4895                	li	a7,5
 32e:	00000073          	ecall
 332:	8082                	ret

0000000000000334 <write>:
 334:	48c1                	li	a7,16
 336:	00000073          	ecall
 33a:	8082                	ret

000000000000033c <close>:
 33c:	48d5                	li	a7,21
 33e:	00000073          	ecall
 342:	8082                	ret

0000000000000344 <kill>:
 344:	4899                	li	a7,6
 346:	00000073          	ecall
 34a:	8082                	ret

000000000000034c <exec>:
 34c:	489d                	li	a7,7
 34e:	00000073          	ecall
 352:	8082                	ret

0000000000000354 <open>:
 354:	48bd                	li	a7,15
 356:	00000073          	ecall
 35a:	8082                	ret

000000000000035c <mknod>:
 35c:	48c5                	li	a7,17
 35e:	00000073          	ecall
 362:	8082                	ret

0000000000000364 <unlink>:
 364:	48c9                	li	a7,18
 366:	00000073          	ecall
 36a:	8082                	ret

000000000000036c <fstat>:
 36c:	48a1                	li	a7,8
 36e:	00000073          	ecall
 372:	8082                	ret

0000000000000374 <link>:
 374:	48cd                	li	a7,19
 376:	00000073          	ecall
 37a:	8082                	ret

000000000000037c <mkdir>:
 37c:	48d1                	li	a7,20
 37e:	00000073          	ecall
 382:	8082                	ret

0000000000000384 <chdir>:
 384:	48a5                	li	a7,9
 386:	00000073          	ecall
 38a:	8082                	ret

000000000000038c <dup>:
 38c:	48a9                	li	a7,10
 38e:	00000073          	ecall
 392:	8082                	ret

0000000000000394 <getpid>:
 394:	48ad                	li	a7,11
 396:	00000073          	ecall
 39a:	8082                	ret

000000000000039c <sbrk>:
 39c:	48b1                	li	a7,12
 39e:	00000073          	ecall
 3a2:	8082                	ret

00000000000003a4 <sleep>:
 3a4:	48b5                	li	a7,13
 3a6:	00000073          	ecall
 3aa:	8082                	ret

00000000000003ac <uptime>:
 3ac:	48b9                	li	a7,14
 3ae:	00000073          	ecall
 3b2:	8082                	ret

00000000000003b4 <trace>:
 3b4:	48d9                	li	a7,22
 3b6:	00000073          	ecall
 3ba:	8082                	ret

00000000000003bc <putc>:
 3bc:	1101                	addi	sp,sp,-32
 3be:	ec06                	sd	ra,24(sp)
 3c0:	e822                	sd	s0,16(sp)
 3c2:	1000                	addi	s0,sp,32
 3c4:	feb407a3          	sb	a1,-17(s0)
 3c8:	4605                	li	a2,1
 3ca:	fef40593          	addi	a1,s0,-17
 3ce:	00000097          	auipc	ra,0x0
 3d2:	f66080e7          	jalr	-154(ra) # 334 <write>
 3d6:	60e2                	ld	ra,24(sp)
 3d8:	6442                	ld	s0,16(sp)
 3da:	6105                	addi	sp,sp,32
 3dc:	8082                	ret

00000000000003de <printint>:
 3de:	7139                	addi	sp,sp,-64
 3e0:	fc06                	sd	ra,56(sp)
 3e2:	f822                	sd	s0,48(sp)
 3e4:	f426                	sd	s1,40(sp)
 3e6:	f04a                	sd	s2,32(sp)
 3e8:	ec4e                	sd	s3,24(sp)
 3ea:	0080                	addi	s0,sp,64
 3ec:	84aa                	mv	s1,a0
 3ee:	c299                	beqz	a3,3f4 <printint+0x16>
 3f0:	0805c863          	bltz	a1,480 <printint+0xa2>
 3f4:	2581                	sext.w	a1,a1
 3f6:	4881                	li	a7,0
 3f8:	fc040693          	addi	a3,s0,-64
 3fc:	4701                	li	a4,0
 3fe:	2601                	sext.w	a2,a2
 400:	00000517          	auipc	a0,0x0
 404:	45850513          	addi	a0,a0,1112 # 858 <digits>
 408:	883a                	mv	a6,a4
 40a:	2705                	addiw	a4,a4,1
 40c:	02c5f7bb          	remuw	a5,a1,a2
 410:	1782                	slli	a5,a5,0x20
 412:	9381                	srli	a5,a5,0x20
 414:	97aa                	add	a5,a5,a0
 416:	0007c783          	lbu	a5,0(a5)
 41a:	00f68023          	sb	a5,0(a3)
 41e:	0005879b          	sext.w	a5,a1
 422:	02c5d5bb          	divuw	a1,a1,a2
 426:	0685                	addi	a3,a3,1
 428:	fec7f0e3          	bgeu	a5,a2,408 <printint+0x2a>
 42c:	00088b63          	beqz	a7,442 <printint+0x64>
 430:	fd040793          	addi	a5,s0,-48
 434:	973e                	add	a4,a4,a5
 436:	02d00793          	li	a5,45
 43a:	fef70823          	sb	a5,-16(a4)
 43e:	0028071b          	addiw	a4,a6,2
 442:	02e05863          	blez	a4,472 <printint+0x94>
 446:	fc040793          	addi	a5,s0,-64
 44a:	00e78933          	add	s2,a5,a4
 44e:	fff78993          	addi	s3,a5,-1
 452:	99ba                	add	s3,s3,a4
 454:	377d                	addiw	a4,a4,-1
 456:	1702                	slli	a4,a4,0x20
 458:	9301                	srli	a4,a4,0x20
 45a:	40e989b3          	sub	s3,s3,a4
 45e:	fff94583          	lbu	a1,-1(s2)
 462:	8526                	mv	a0,s1
 464:	00000097          	auipc	ra,0x0
 468:	f58080e7          	jalr	-168(ra) # 3bc <putc>
 46c:	197d                	addi	s2,s2,-1
 46e:	ff3918e3          	bne	s2,s3,45e <printint+0x80>
 472:	70e2                	ld	ra,56(sp)
 474:	7442                	ld	s0,48(sp)
 476:	74a2                	ld	s1,40(sp)
 478:	7902                	ld	s2,32(sp)
 47a:	69e2                	ld	s3,24(sp)
 47c:	6121                	addi	sp,sp,64
 47e:	8082                	ret
 480:	40b005bb          	negw	a1,a1
 484:	4885                	li	a7,1
 486:	bf8d                	j	3f8 <printint+0x1a>

0000000000000488 <vprintf>:
 488:	7119                	addi	sp,sp,-128
 48a:	fc86                	sd	ra,120(sp)
 48c:	f8a2                	sd	s0,112(sp)
 48e:	f4a6                	sd	s1,104(sp)
 490:	f0ca                	sd	s2,96(sp)
 492:	ecce                	sd	s3,88(sp)
 494:	e8d2                	sd	s4,80(sp)
 496:	e4d6                	sd	s5,72(sp)
 498:	e0da                	sd	s6,64(sp)
 49a:	fc5e                	sd	s7,56(sp)
 49c:	f862                	sd	s8,48(sp)
 49e:	f466                	sd	s9,40(sp)
 4a0:	f06a                	sd	s10,32(sp)
 4a2:	ec6e                	sd	s11,24(sp)
 4a4:	0100                	addi	s0,sp,128
 4a6:	0005c903          	lbu	s2,0(a1)
 4aa:	18090f63          	beqz	s2,648 <vprintf+0x1c0>
 4ae:	8aaa                	mv	s5,a0
 4b0:	8b32                	mv	s6,a2
 4b2:	00158493          	addi	s1,a1,1
 4b6:	4981                	li	s3,0
 4b8:	02500a13          	li	s4,37
 4bc:	06400c13          	li	s8,100
 4c0:	06c00c93          	li	s9,108
 4c4:	07800d13          	li	s10,120
 4c8:	07000d93          	li	s11,112
 4cc:	00000b97          	auipc	s7,0x0
 4d0:	38cb8b93          	addi	s7,s7,908 # 858 <digits>
 4d4:	a839                	j	4f2 <vprintf+0x6a>
 4d6:	85ca                	mv	a1,s2
 4d8:	8556                	mv	a0,s5
 4da:	00000097          	auipc	ra,0x0
 4de:	ee2080e7          	jalr	-286(ra) # 3bc <putc>
 4e2:	a019                	j	4e8 <vprintf+0x60>
 4e4:	01498f63          	beq	s3,s4,502 <vprintf+0x7a>
 4e8:	0485                	addi	s1,s1,1
 4ea:	fff4c903          	lbu	s2,-1(s1)
 4ee:	14090d63          	beqz	s2,648 <vprintf+0x1c0>
 4f2:	0009079b          	sext.w	a5,s2
 4f6:	fe0997e3          	bnez	s3,4e4 <vprintf+0x5c>
 4fa:	fd479ee3          	bne	a5,s4,4d6 <vprintf+0x4e>
 4fe:	89be                	mv	s3,a5
 500:	b7e5                	j	4e8 <vprintf+0x60>
 502:	05878063          	beq	a5,s8,542 <vprintf+0xba>
 506:	05978c63          	beq	a5,s9,55e <vprintf+0xd6>
 50a:	07a78863          	beq	a5,s10,57a <vprintf+0xf2>
 50e:	09b78463          	beq	a5,s11,596 <vprintf+0x10e>
 512:	07300713          	li	a4,115
 516:	0ce78663          	beq	a5,a4,5e2 <vprintf+0x15a>
 51a:	06300713          	li	a4,99
 51e:	0ee78e63          	beq	a5,a4,61a <vprintf+0x192>
 522:	11478863          	beq	a5,s4,632 <vprintf+0x1aa>
 526:	85d2                	mv	a1,s4
 528:	8556                	mv	a0,s5
 52a:	00000097          	auipc	ra,0x0
 52e:	e92080e7          	jalr	-366(ra) # 3bc <putc>
 532:	85ca                	mv	a1,s2
 534:	8556                	mv	a0,s5
 536:	00000097          	auipc	ra,0x0
 53a:	e86080e7          	jalr	-378(ra) # 3bc <putc>
 53e:	4981                	li	s3,0
 540:	b765                	j	4e8 <vprintf+0x60>
 542:	008b0913          	addi	s2,s6,8
 546:	4685                	li	a3,1
 548:	4629                	li	a2,10
 54a:	000b2583          	lw	a1,0(s6)
 54e:	8556                	mv	a0,s5
 550:	00000097          	auipc	ra,0x0
 554:	e8e080e7          	jalr	-370(ra) # 3de <printint>
 558:	8b4a                	mv	s6,s2
 55a:	4981                	li	s3,0
 55c:	b771                	j	4e8 <vprintf+0x60>
 55e:	008b0913          	addi	s2,s6,8
 562:	4681                	li	a3,0
 564:	4629                	li	a2,10
 566:	000b2583          	lw	a1,0(s6)
 56a:	8556                	mv	a0,s5
 56c:	00000097          	auipc	ra,0x0
 570:	e72080e7          	jalr	-398(ra) # 3de <printint>
 574:	8b4a                	mv	s6,s2
 576:	4981                	li	s3,0
 578:	bf85                	j	4e8 <vprintf+0x60>
 57a:	008b0913          	addi	s2,s6,8
 57e:	4681                	li	a3,0
 580:	4641                	li	a2,16
 582:	000b2583          	lw	a1,0(s6)
 586:	8556                	mv	a0,s5
 588:	00000097          	auipc	ra,0x0
 58c:	e56080e7          	jalr	-426(ra) # 3de <printint>
 590:	8b4a                	mv	s6,s2
 592:	4981                	li	s3,0
 594:	bf91                	j	4e8 <vprintf+0x60>
 596:	008b0793          	addi	a5,s6,8
 59a:	f8f43423          	sd	a5,-120(s0)
 59e:	000b3983          	ld	s3,0(s6)
 5a2:	03000593          	li	a1,48
 5a6:	8556                	mv	a0,s5
 5a8:	00000097          	auipc	ra,0x0
 5ac:	e14080e7          	jalr	-492(ra) # 3bc <putc>
 5b0:	85ea                	mv	a1,s10
 5b2:	8556                	mv	a0,s5
 5b4:	00000097          	auipc	ra,0x0
 5b8:	e08080e7          	jalr	-504(ra) # 3bc <putc>
 5bc:	4941                	li	s2,16
 5be:	03c9d793          	srli	a5,s3,0x3c
 5c2:	97de                	add	a5,a5,s7
 5c4:	0007c583          	lbu	a1,0(a5)
 5c8:	8556                	mv	a0,s5
 5ca:	00000097          	auipc	ra,0x0
 5ce:	df2080e7          	jalr	-526(ra) # 3bc <putc>
 5d2:	0992                	slli	s3,s3,0x4
 5d4:	397d                	addiw	s2,s2,-1
 5d6:	fe0914e3          	bnez	s2,5be <vprintf+0x136>
 5da:	f8843b03          	ld	s6,-120(s0)
 5de:	4981                	li	s3,0
 5e0:	b721                	j	4e8 <vprintf+0x60>
 5e2:	008b0993          	addi	s3,s6,8
 5e6:	000b3903          	ld	s2,0(s6)
 5ea:	02090163          	beqz	s2,60c <vprintf+0x184>
 5ee:	00094583          	lbu	a1,0(s2)
 5f2:	c9a1                	beqz	a1,642 <vprintf+0x1ba>
 5f4:	8556                	mv	a0,s5
 5f6:	00000097          	auipc	ra,0x0
 5fa:	dc6080e7          	jalr	-570(ra) # 3bc <putc>
 5fe:	0905                	addi	s2,s2,1
 600:	00094583          	lbu	a1,0(s2)
 604:	f9e5                	bnez	a1,5f4 <vprintf+0x16c>
 606:	8b4e                	mv	s6,s3
 608:	4981                	li	s3,0
 60a:	bdf9                	j	4e8 <vprintf+0x60>
 60c:	00000917          	auipc	s2,0x0
 610:	24490913          	addi	s2,s2,580 # 850 <malloc+0xfe>
 614:	02800593          	li	a1,40
 618:	bff1                	j	5f4 <vprintf+0x16c>
 61a:	008b0913          	addi	s2,s6,8
 61e:	000b4583          	lbu	a1,0(s6)
 622:	8556                	mv	a0,s5
 624:	00000097          	auipc	ra,0x0
 628:	d98080e7          	jalr	-616(ra) # 3bc <putc>
 62c:	8b4a                	mv	s6,s2
 62e:	4981                	li	s3,0
 630:	bd65                	j	4e8 <vprintf+0x60>
 632:	85d2                	mv	a1,s4
 634:	8556                	mv	a0,s5
 636:	00000097          	auipc	ra,0x0
 63a:	d86080e7          	jalr	-634(ra) # 3bc <putc>
 63e:	4981                	li	s3,0
 640:	b565                	j	4e8 <vprintf+0x60>
 642:	8b4e                	mv	s6,s3
 644:	4981                	li	s3,0
 646:	b54d                	j	4e8 <vprintf+0x60>
 648:	70e6                	ld	ra,120(sp)
 64a:	7446                	ld	s0,112(sp)
 64c:	74a6                	ld	s1,104(sp)
 64e:	7906                	ld	s2,96(sp)
 650:	69e6                	ld	s3,88(sp)
 652:	6a46                	ld	s4,80(sp)
 654:	6aa6                	ld	s5,72(sp)
 656:	6b06                	ld	s6,64(sp)
 658:	7be2                	ld	s7,56(sp)
 65a:	7c42                	ld	s8,48(sp)
 65c:	7ca2                	ld	s9,40(sp)
 65e:	7d02                	ld	s10,32(sp)
 660:	6de2                	ld	s11,24(sp)
 662:	6109                	addi	sp,sp,128
 664:	8082                	ret

0000000000000666 <fprintf>:
 666:	715d                	addi	sp,sp,-80
 668:	ec06                	sd	ra,24(sp)
 66a:	e822                	sd	s0,16(sp)
 66c:	1000                	addi	s0,sp,32
 66e:	e010                	sd	a2,0(s0)
 670:	e414                	sd	a3,8(s0)
 672:	e818                	sd	a4,16(s0)
 674:	ec1c                	sd	a5,24(s0)
 676:	03043023          	sd	a6,32(s0)
 67a:	03143423          	sd	a7,40(s0)
 67e:	fe843423          	sd	s0,-24(s0)
 682:	8622                	mv	a2,s0
 684:	00000097          	auipc	ra,0x0
 688:	e04080e7          	jalr	-508(ra) # 488 <vprintf>
 68c:	60e2                	ld	ra,24(sp)
 68e:	6442                	ld	s0,16(sp)
 690:	6161                	addi	sp,sp,80
 692:	8082                	ret

0000000000000694 <printf>:
 694:	711d                	addi	sp,sp,-96
 696:	ec06                	sd	ra,24(sp)
 698:	e822                	sd	s0,16(sp)
 69a:	1000                	addi	s0,sp,32
 69c:	e40c                	sd	a1,8(s0)
 69e:	e810                	sd	a2,16(s0)
 6a0:	ec14                	sd	a3,24(s0)
 6a2:	f018                	sd	a4,32(s0)
 6a4:	f41c                	sd	a5,40(s0)
 6a6:	03043823          	sd	a6,48(s0)
 6aa:	03143c23          	sd	a7,56(s0)
 6ae:	00840613          	addi	a2,s0,8
 6b2:	fec43423          	sd	a2,-24(s0)
 6b6:	85aa                	mv	a1,a0
 6b8:	4505                	li	a0,1
 6ba:	00000097          	auipc	ra,0x0
 6be:	dce080e7          	jalr	-562(ra) # 488 <vprintf>
 6c2:	60e2                	ld	ra,24(sp)
 6c4:	6442                	ld	s0,16(sp)
 6c6:	6125                	addi	sp,sp,96
 6c8:	8082                	ret

00000000000006ca <free>:
 6ca:	1141                	addi	sp,sp,-16
 6cc:	e422                	sd	s0,8(sp)
 6ce:	0800                	addi	s0,sp,16
 6d0:	ff050693          	addi	a3,a0,-16
 6d4:	00001797          	auipc	a5,0x1
 6d8:	92c7b783          	ld	a5,-1748(a5) # 1000 <freep>
 6dc:	a805                	j	70c <free+0x42>
 6de:	4618                	lw	a4,8(a2)
 6e0:	9db9                	addw	a1,a1,a4
 6e2:	feb52c23          	sw	a1,-8(a0)
 6e6:	6398                	ld	a4,0(a5)
 6e8:	6318                	ld	a4,0(a4)
 6ea:	fee53823          	sd	a4,-16(a0)
 6ee:	a091                	j	732 <free+0x68>
 6f0:	ff852703          	lw	a4,-8(a0)
 6f4:	9e39                	addw	a2,a2,a4
 6f6:	c790                	sw	a2,8(a5)
 6f8:	ff053703          	ld	a4,-16(a0)
 6fc:	e398                	sd	a4,0(a5)
 6fe:	a099                	j	744 <free+0x7a>
 700:	6398                	ld	a4,0(a5)
 702:	00e7e463          	bltu	a5,a4,70a <free+0x40>
 706:	00e6ea63          	bltu	a3,a4,71a <free+0x50>
 70a:	87ba                	mv	a5,a4
 70c:	fed7fae3          	bgeu	a5,a3,700 <free+0x36>
 710:	6398                	ld	a4,0(a5)
 712:	00e6e463          	bltu	a3,a4,71a <free+0x50>
 716:	fee7eae3          	bltu	a5,a4,70a <free+0x40>
 71a:	ff852583          	lw	a1,-8(a0)
 71e:	6390                	ld	a2,0(a5)
 720:	02059713          	slli	a4,a1,0x20
 724:	9301                	srli	a4,a4,0x20
 726:	0712                	slli	a4,a4,0x4
 728:	9736                	add	a4,a4,a3
 72a:	fae60ae3          	beq	a2,a4,6de <free+0x14>
 72e:	fec53823          	sd	a2,-16(a0)
 732:	4790                	lw	a2,8(a5)
 734:	02061713          	slli	a4,a2,0x20
 738:	9301                	srli	a4,a4,0x20
 73a:	0712                	slli	a4,a4,0x4
 73c:	973e                	add	a4,a4,a5
 73e:	fae689e3          	beq	a3,a4,6f0 <free+0x26>
 742:	e394                	sd	a3,0(a5)
 744:	00001717          	auipc	a4,0x1
 748:	8af73e23          	sd	a5,-1860(a4) # 1000 <freep>
 74c:	6422                	ld	s0,8(sp)
 74e:	0141                	addi	sp,sp,16
 750:	8082                	ret

0000000000000752 <malloc>:
 752:	7139                	addi	sp,sp,-64
 754:	fc06                	sd	ra,56(sp)
 756:	f822                	sd	s0,48(sp)
 758:	f426                	sd	s1,40(sp)
 75a:	f04a                	sd	s2,32(sp)
 75c:	ec4e                	sd	s3,24(sp)
 75e:	e852                	sd	s4,16(sp)
 760:	e456                	sd	s5,8(sp)
 762:	e05a                	sd	s6,0(sp)
 764:	0080                	addi	s0,sp,64
 766:	02051493          	slli	s1,a0,0x20
 76a:	9081                	srli	s1,s1,0x20
 76c:	04bd                	addi	s1,s1,15
 76e:	8091                	srli	s1,s1,0x4
 770:	0014899b          	addiw	s3,s1,1
 774:	0485                	addi	s1,s1,1
 776:	00001517          	auipc	a0,0x1
 77a:	88a53503          	ld	a0,-1910(a0) # 1000 <freep>
 77e:	c515                	beqz	a0,7aa <malloc+0x58>
 780:	611c                	ld	a5,0(a0)
 782:	4798                	lw	a4,8(a5)
 784:	02977f63          	bgeu	a4,s1,7c2 <malloc+0x70>
 788:	8a4e                	mv	s4,s3
 78a:	0009871b          	sext.w	a4,s3
 78e:	6685                	lui	a3,0x1
 790:	00d77363          	bgeu	a4,a3,796 <malloc+0x44>
 794:	6a05                	lui	s4,0x1
 796:	000a0b1b          	sext.w	s6,s4
 79a:	004a1a1b          	slliw	s4,s4,0x4
 79e:	00001917          	auipc	s2,0x1
 7a2:	86290913          	addi	s2,s2,-1950 # 1000 <freep>
 7a6:	5afd                	li	s5,-1
 7a8:	a88d                	j	81a <malloc+0xc8>
 7aa:	00001797          	auipc	a5,0x1
 7ae:	86678793          	addi	a5,a5,-1946 # 1010 <base>
 7b2:	00001717          	auipc	a4,0x1
 7b6:	84f73723          	sd	a5,-1970(a4) # 1000 <freep>
 7ba:	e39c                	sd	a5,0(a5)
 7bc:	0007a423          	sw	zero,8(a5)
 7c0:	b7e1                	j	788 <malloc+0x36>
 7c2:	02e48b63          	beq	s1,a4,7f8 <malloc+0xa6>
 7c6:	4137073b          	subw	a4,a4,s3
 7ca:	c798                	sw	a4,8(a5)
 7cc:	1702                	slli	a4,a4,0x20
 7ce:	9301                	srli	a4,a4,0x20
 7d0:	0712                	slli	a4,a4,0x4
 7d2:	97ba                	add	a5,a5,a4
 7d4:	0137a423          	sw	s3,8(a5)
 7d8:	00001717          	auipc	a4,0x1
 7dc:	82a73423          	sd	a0,-2008(a4) # 1000 <freep>
 7e0:	01078513          	addi	a0,a5,16
 7e4:	70e2                	ld	ra,56(sp)
 7e6:	7442                	ld	s0,48(sp)
 7e8:	74a2                	ld	s1,40(sp)
 7ea:	7902                	ld	s2,32(sp)
 7ec:	69e2                	ld	s3,24(sp)
 7ee:	6a42                	ld	s4,16(sp)
 7f0:	6aa2                	ld	s5,8(sp)
 7f2:	6b02                	ld	s6,0(sp)
 7f4:	6121                	addi	sp,sp,64
 7f6:	8082                	ret
 7f8:	6398                	ld	a4,0(a5)
 7fa:	e118                	sd	a4,0(a0)
 7fc:	bff1                	j	7d8 <malloc+0x86>
 7fe:	01652423          	sw	s6,8(a0)
 802:	0541                	addi	a0,a0,16
 804:	00000097          	auipc	ra,0x0
 808:	ec6080e7          	jalr	-314(ra) # 6ca <free>
 80c:	00093503          	ld	a0,0(s2)
 810:	d971                	beqz	a0,7e4 <malloc+0x92>
 812:	611c                	ld	a5,0(a0)
 814:	4798                	lw	a4,8(a5)
 816:	fa9776e3          	bgeu	a4,s1,7c2 <malloc+0x70>
 81a:	00093703          	ld	a4,0(s2)
 81e:	853e                	mv	a0,a5
 820:	fef719e3          	bne	a4,a5,812 <malloc+0xc0>
 824:	8552                	mv	a0,s4
 826:	00000097          	auipc	ra,0x0
 82a:	b76080e7          	jalr	-1162(ra) # 39c <sbrk>
 82e:	fd5518e3          	bne	a0,s5,7fe <malloc+0xac>
 832:	4501                	li	a0,0
 834:	bf45                	j	7e4 <malloc+0x92>
