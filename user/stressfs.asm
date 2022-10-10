
user/_stressfs:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
   0:	dd010113          	addi	sp,sp,-560
   4:	22113423          	sd	ra,552(sp)
   8:	22813023          	sd	s0,544(sp)
   c:	20913c23          	sd	s1,536(sp)
  10:	21213823          	sd	s2,528(sp)
  14:	1c00                	addi	s0,sp,560
  16:	00001797          	auipc	a5,0x1
  1a:	8da78793          	addi	a5,a5,-1830 # 8f0 <malloc+0x116>
  1e:	6398                	ld	a4,0(a5)
  20:	fce43823          	sd	a4,-48(s0)
  24:	0087d783          	lhu	a5,8(a5)
  28:	fcf41c23          	sh	a5,-40(s0)
  2c:	00001517          	auipc	a0,0x1
  30:	89450513          	addi	a0,a0,-1900 # 8c0 <malloc+0xe6>
  34:	00000097          	auipc	ra,0x0
  38:	6e8080e7          	jalr	1768(ra) # 71c <printf>
  3c:	20000613          	li	a2,512
  40:	06100593          	li	a1,97
  44:	dd040513          	addi	a0,s0,-560
  48:	00000097          	auipc	ra,0x0
  4c:	150080e7          	jalr	336(ra) # 198 <memset>
  50:	4481                	li	s1,0
  52:	4911                	li	s2,4
  54:	00000097          	auipc	ra,0x0
  58:	340080e7          	jalr	832(ra) # 394 <fork>
  5c:	00a04563          	bgtz	a0,66 <main+0x66>
  60:	2485                	addiw	s1,s1,1
  62:	ff2499e3          	bne	s1,s2,54 <main+0x54>
  66:	85a6                	mv	a1,s1
  68:	00001517          	auipc	a0,0x1
  6c:	87050513          	addi	a0,a0,-1936 # 8d8 <malloc+0xfe>
  70:	00000097          	auipc	ra,0x0
  74:	6ac080e7          	jalr	1708(ra) # 71c <printf>
  78:	fd844783          	lbu	a5,-40(s0)
  7c:	9cbd                	addw	s1,s1,a5
  7e:	fc940c23          	sb	s1,-40(s0)
  82:	20200593          	li	a1,514
  86:	fd040513          	addi	a0,s0,-48
  8a:	00000097          	auipc	ra,0x0
  8e:	352080e7          	jalr	850(ra) # 3dc <open>
  92:	892a                	mv	s2,a0
  94:	44d1                	li	s1,20
  96:	20000613          	li	a2,512
  9a:	dd040593          	addi	a1,s0,-560
  9e:	854a                	mv	a0,s2
  a0:	00000097          	auipc	ra,0x0
  a4:	31c080e7          	jalr	796(ra) # 3bc <write>
  a8:	34fd                	addiw	s1,s1,-1
  aa:	f4f5                	bnez	s1,96 <main+0x96>
  ac:	854a                	mv	a0,s2
  ae:	00000097          	auipc	ra,0x0
  b2:	316080e7          	jalr	790(ra) # 3c4 <close>
  b6:	00001517          	auipc	a0,0x1
  ba:	83250513          	addi	a0,a0,-1998 # 8e8 <malloc+0x10e>
  be:	00000097          	auipc	ra,0x0
  c2:	65e080e7          	jalr	1630(ra) # 71c <printf>
  c6:	4581                	li	a1,0
  c8:	fd040513          	addi	a0,s0,-48
  cc:	00000097          	auipc	ra,0x0
  d0:	310080e7          	jalr	784(ra) # 3dc <open>
  d4:	892a                	mv	s2,a0
  d6:	44d1                	li	s1,20
  d8:	20000613          	li	a2,512
  dc:	dd040593          	addi	a1,s0,-560
  e0:	854a                	mv	a0,s2
  e2:	00000097          	auipc	ra,0x0
  e6:	2d2080e7          	jalr	722(ra) # 3b4 <read>
  ea:	34fd                	addiw	s1,s1,-1
  ec:	f4f5                	bnez	s1,d8 <main+0xd8>
  ee:	854a                	mv	a0,s2
  f0:	00000097          	auipc	ra,0x0
  f4:	2d4080e7          	jalr	724(ra) # 3c4 <close>
  f8:	4501                	li	a0,0
  fa:	00000097          	auipc	ra,0x0
  fe:	2aa080e7          	jalr	682(ra) # 3a4 <wait>
 102:	4501                	li	a0,0
 104:	00000097          	auipc	ra,0x0
 108:	298080e7          	jalr	664(ra) # 39c <exit>

000000000000010c <_main>:
 10c:	1141                	addi	sp,sp,-16
 10e:	e406                	sd	ra,8(sp)
 110:	e022                	sd	s0,0(sp)
 112:	0800                	addi	s0,sp,16
 114:	00000097          	auipc	ra,0x0
 118:	eec080e7          	jalr	-276(ra) # 0 <main>
 11c:	4501                	li	a0,0
 11e:	00000097          	auipc	ra,0x0
 122:	27e080e7          	jalr	638(ra) # 39c <exit>

0000000000000126 <strcpy>:
 126:	1141                	addi	sp,sp,-16
 128:	e422                	sd	s0,8(sp)
 12a:	0800                	addi	s0,sp,16
 12c:	87aa                	mv	a5,a0
 12e:	0585                	addi	a1,a1,1
 130:	0785                	addi	a5,a5,1
 132:	fff5c703          	lbu	a4,-1(a1)
 136:	fee78fa3          	sb	a4,-1(a5)
 13a:	fb75                	bnez	a4,12e <strcpy+0x8>
 13c:	6422                	ld	s0,8(sp)
 13e:	0141                	addi	sp,sp,16
 140:	8082                	ret

0000000000000142 <strcmp>:
 142:	1141                	addi	sp,sp,-16
 144:	e422                	sd	s0,8(sp)
 146:	0800                	addi	s0,sp,16
 148:	00054783          	lbu	a5,0(a0)
 14c:	cb91                	beqz	a5,160 <strcmp+0x1e>
 14e:	0005c703          	lbu	a4,0(a1)
 152:	00f71763          	bne	a4,a5,160 <strcmp+0x1e>
 156:	0505                	addi	a0,a0,1
 158:	0585                	addi	a1,a1,1
 15a:	00054783          	lbu	a5,0(a0)
 15e:	fbe5                	bnez	a5,14e <strcmp+0xc>
 160:	0005c503          	lbu	a0,0(a1)
 164:	40a7853b          	subw	a0,a5,a0
 168:	6422                	ld	s0,8(sp)
 16a:	0141                	addi	sp,sp,16
 16c:	8082                	ret

000000000000016e <strlen>:
 16e:	1141                	addi	sp,sp,-16
 170:	e422                	sd	s0,8(sp)
 172:	0800                	addi	s0,sp,16
 174:	00054783          	lbu	a5,0(a0)
 178:	cf91                	beqz	a5,194 <strlen+0x26>
 17a:	0505                	addi	a0,a0,1
 17c:	87aa                	mv	a5,a0
 17e:	4685                	li	a3,1
 180:	9e89                	subw	a3,a3,a0
 182:	00f6853b          	addw	a0,a3,a5
 186:	0785                	addi	a5,a5,1
 188:	fff7c703          	lbu	a4,-1(a5)
 18c:	fb7d                	bnez	a4,182 <strlen+0x14>
 18e:	6422                	ld	s0,8(sp)
 190:	0141                	addi	sp,sp,16
 192:	8082                	ret
 194:	4501                	li	a0,0
 196:	bfe5                	j	18e <strlen+0x20>

0000000000000198 <memset>:
 198:	1141                	addi	sp,sp,-16
 19a:	e422                	sd	s0,8(sp)
 19c:	0800                	addi	s0,sp,16
 19e:	ce09                	beqz	a2,1b8 <memset+0x20>
 1a0:	87aa                	mv	a5,a0
 1a2:	fff6071b          	addiw	a4,a2,-1
 1a6:	1702                	slli	a4,a4,0x20
 1a8:	9301                	srli	a4,a4,0x20
 1aa:	0705                	addi	a4,a4,1
 1ac:	972a                	add	a4,a4,a0
 1ae:	00b78023          	sb	a1,0(a5)
 1b2:	0785                	addi	a5,a5,1
 1b4:	fee79de3          	bne	a5,a4,1ae <memset+0x16>
 1b8:	6422                	ld	s0,8(sp)
 1ba:	0141                	addi	sp,sp,16
 1bc:	8082                	ret

00000000000001be <strchr>:
 1be:	1141                	addi	sp,sp,-16
 1c0:	e422                	sd	s0,8(sp)
 1c2:	0800                	addi	s0,sp,16
 1c4:	00054783          	lbu	a5,0(a0)
 1c8:	cb99                	beqz	a5,1de <strchr+0x20>
 1ca:	00f58763          	beq	a1,a5,1d8 <strchr+0x1a>
 1ce:	0505                	addi	a0,a0,1
 1d0:	00054783          	lbu	a5,0(a0)
 1d4:	fbfd                	bnez	a5,1ca <strchr+0xc>
 1d6:	4501                	li	a0,0
 1d8:	6422                	ld	s0,8(sp)
 1da:	0141                	addi	sp,sp,16
 1dc:	8082                	ret
 1de:	4501                	li	a0,0
 1e0:	bfe5                	j	1d8 <strchr+0x1a>

00000000000001e2 <gets>:
 1e2:	711d                	addi	sp,sp,-96
 1e4:	ec86                	sd	ra,88(sp)
 1e6:	e8a2                	sd	s0,80(sp)
 1e8:	e4a6                	sd	s1,72(sp)
 1ea:	e0ca                	sd	s2,64(sp)
 1ec:	fc4e                	sd	s3,56(sp)
 1ee:	f852                	sd	s4,48(sp)
 1f0:	f456                	sd	s5,40(sp)
 1f2:	f05a                	sd	s6,32(sp)
 1f4:	ec5e                	sd	s7,24(sp)
 1f6:	1080                	addi	s0,sp,96
 1f8:	8baa                	mv	s7,a0
 1fa:	8a2e                	mv	s4,a1
 1fc:	892a                	mv	s2,a0
 1fe:	4481                	li	s1,0
 200:	4aa9                	li	s5,10
 202:	4b35                	li	s6,13
 204:	89a6                	mv	s3,s1
 206:	2485                	addiw	s1,s1,1
 208:	0344d863          	bge	s1,s4,238 <gets+0x56>
 20c:	4605                	li	a2,1
 20e:	faf40593          	addi	a1,s0,-81
 212:	4501                	li	a0,0
 214:	00000097          	auipc	ra,0x0
 218:	1a0080e7          	jalr	416(ra) # 3b4 <read>
 21c:	00a05e63          	blez	a0,238 <gets+0x56>
 220:	faf44783          	lbu	a5,-81(s0)
 224:	00f90023          	sb	a5,0(s2)
 228:	01578763          	beq	a5,s5,236 <gets+0x54>
 22c:	0905                	addi	s2,s2,1
 22e:	fd679be3          	bne	a5,s6,204 <gets+0x22>
 232:	89a6                	mv	s3,s1
 234:	a011                	j	238 <gets+0x56>
 236:	89a6                	mv	s3,s1
 238:	99de                	add	s3,s3,s7
 23a:	00098023          	sb	zero,0(s3)
 23e:	855e                	mv	a0,s7
 240:	60e6                	ld	ra,88(sp)
 242:	6446                	ld	s0,80(sp)
 244:	64a6                	ld	s1,72(sp)
 246:	6906                	ld	s2,64(sp)
 248:	79e2                	ld	s3,56(sp)
 24a:	7a42                	ld	s4,48(sp)
 24c:	7aa2                	ld	s5,40(sp)
 24e:	7b02                	ld	s6,32(sp)
 250:	6be2                	ld	s7,24(sp)
 252:	6125                	addi	sp,sp,96
 254:	8082                	ret

0000000000000256 <stat>:
 256:	1101                	addi	sp,sp,-32
 258:	ec06                	sd	ra,24(sp)
 25a:	e822                	sd	s0,16(sp)
 25c:	e426                	sd	s1,8(sp)
 25e:	e04a                	sd	s2,0(sp)
 260:	1000                	addi	s0,sp,32
 262:	892e                	mv	s2,a1
 264:	4581                	li	a1,0
 266:	00000097          	auipc	ra,0x0
 26a:	176080e7          	jalr	374(ra) # 3dc <open>
 26e:	02054563          	bltz	a0,298 <stat+0x42>
 272:	84aa                	mv	s1,a0
 274:	85ca                	mv	a1,s2
 276:	00000097          	auipc	ra,0x0
 27a:	17e080e7          	jalr	382(ra) # 3f4 <fstat>
 27e:	892a                	mv	s2,a0
 280:	8526                	mv	a0,s1
 282:	00000097          	auipc	ra,0x0
 286:	142080e7          	jalr	322(ra) # 3c4 <close>
 28a:	854a                	mv	a0,s2
 28c:	60e2                	ld	ra,24(sp)
 28e:	6442                	ld	s0,16(sp)
 290:	64a2                	ld	s1,8(sp)
 292:	6902                	ld	s2,0(sp)
 294:	6105                	addi	sp,sp,32
 296:	8082                	ret
 298:	597d                	li	s2,-1
 29a:	bfc5                	j	28a <stat+0x34>

000000000000029c <atoi>:
 29c:	1141                	addi	sp,sp,-16
 29e:	e422                	sd	s0,8(sp)
 2a0:	0800                	addi	s0,sp,16
 2a2:	00054603          	lbu	a2,0(a0)
 2a6:	fd06079b          	addiw	a5,a2,-48
 2aa:	0ff7f793          	andi	a5,a5,255
 2ae:	4725                	li	a4,9
 2b0:	02f76963          	bltu	a4,a5,2e2 <atoi+0x46>
 2b4:	86aa                	mv	a3,a0
 2b6:	4501                	li	a0,0
 2b8:	45a5                	li	a1,9
 2ba:	0685                	addi	a3,a3,1
 2bc:	0025179b          	slliw	a5,a0,0x2
 2c0:	9fa9                	addw	a5,a5,a0
 2c2:	0017979b          	slliw	a5,a5,0x1
 2c6:	9fb1                	addw	a5,a5,a2
 2c8:	fd07851b          	addiw	a0,a5,-48
 2cc:	0006c603          	lbu	a2,0(a3)
 2d0:	fd06071b          	addiw	a4,a2,-48
 2d4:	0ff77713          	andi	a4,a4,255
 2d8:	fee5f1e3          	bgeu	a1,a4,2ba <atoi+0x1e>
 2dc:	6422                	ld	s0,8(sp)
 2de:	0141                	addi	sp,sp,16
 2e0:	8082                	ret
 2e2:	4501                	li	a0,0
 2e4:	bfe5                	j	2dc <atoi+0x40>

00000000000002e6 <memmove>:
 2e6:	1141                	addi	sp,sp,-16
 2e8:	e422                	sd	s0,8(sp)
 2ea:	0800                	addi	s0,sp,16
 2ec:	02b57663          	bgeu	a0,a1,318 <memmove+0x32>
 2f0:	02c05163          	blez	a2,312 <memmove+0x2c>
 2f4:	fff6079b          	addiw	a5,a2,-1
 2f8:	1782                	slli	a5,a5,0x20
 2fa:	9381                	srli	a5,a5,0x20
 2fc:	0785                	addi	a5,a5,1
 2fe:	97aa                	add	a5,a5,a0
 300:	872a                	mv	a4,a0
 302:	0585                	addi	a1,a1,1
 304:	0705                	addi	a4,a4,1
 306:	fff5c683          	lbu	a3,-1(a1)
 30a:	fed70fa3          	sb	a3,-1(a4)
 30e:	fee79ae3          	bne	a5,a4,302 <memmove+0x1c>
 312:	6422                	ld	s0,8(sp)
 314:	0141                	addi	sp,sp,16
 316:	8082                	ret
 318:	00c50733          	add	a4,a0,a2
 31c:	95b2                	add	a1,a1,a2
 31e:	fec05ae3          	blez	a2,312 <memmove+0x2c>
 322:	fff6079b          	addiw	a5,a2,-1
 326:	1782                	slli	a5,a5,0x20
 328:	9381                	srli	a5,a5,0x20
 32a:	fff7c793          	not	a5,a5
 32e:	97ba                	add	a5,a5,a4
 330:	15fd                	addi	a1,a1,-1
 332:	177d                	addi	a4,a4,-1
 334:	0005c683          	lbu	a3,0(a1)
 338:	00d70023          	sb	a3,0(a4)
 33c:	fee79ae3          	bne	a5,a4,330 <memmove+0x4a>
 340:	bfc9                	j	312 <memmove+0x2c>

0000000000000342 <memcmp>:
 342:	1141                	addi	sp,sp,-16
 344:	e422                	sd	s0,8(sp)
 346:	0800                	addi	s0,sp,16
 348:	ca05                	beqz	a2,378 <memcmp+0x36>
 34a:	fff6069b          	addiw	a3,a2,-1
 34e:	1682                	slli	a3,a3,0x20
 350:	9281                	srli	a3,a3,0x20
 352:	0685                	addi	a3,a3,1
 354:	96aa                	add	a3,a3,a0
 356:	00054783          	lbu	a5,0(a0)
 35a:	0005c703          	lbu	a4,0(a1)
 35e:	00e79863          	bne	a5,a4,36e <memcmp+0x2c>
 362:	0505                	addi	a0,a0,1
 364:	0585                	addi	a1,a1,1
 366:	fed518e3          	bne	a0,a3,356 <memcmp+0x14>
 36a:	4501                	li	a0,0
 36c:	a019                	j	372 <memcmp+0x30>
 36e:	40e7853b          	subw	a0,a5,a4
 372:	6422                	ld	s0,8(sp)
 374:	0141                	addi	sp,sp,16
 376:	8082                	ret
 378:	4501                	li	a0,0
 37a:	bfe5                	j	372 <memcmp+0x30>

000000000000037c <memcpy>:
 37c:	1141                	addi	sp,sp,-16
 37e:	e406                	sd	ra,8(sp)
 380:	e022                	sd	s0,0(sp)
 382:	0800                	addi	s0,sp,16
 384:	00000097          	auipc	ra,0x0
 388:	f62080e7          	jalr	-158(ra) # 2e6 <memmove>
 38c:	60a2                	ld	ra,8(sp)
 38e:	6402                	ld	s0,0(sp)
 390:	0141                	addi	sp,sp,16
 392:	8082                	ret

0000000000000394 <fork>:
 394:	4885                	li	a7,1
 396:	00000073          	ecall
 39a:	8082                	ret

000000000000039c <exit>:
 39c:	4889                	li	a7,2
 39e:	00000073          	ecall
 3a2:	8082                	ret

00000000000003a4 <wait>:
 3a4:	488d                	li	a7,3
 3a6:	00000073          	ecall
 3aa:	8082                	ret

00000000000003ac <pipe>:
 3ac:	4891                	li	a7,4
 3ae:	00000073          	ecall
 3b2:	8082                	ret

00000000000003b4 <read>:
 3b4:	4895                	li	a7,5
 3b6:	00000073          	ecall
 3ba:	8082                	ret

00000000000003bc <write>:
 3bc:	48c1                	li	a7,16
 3be:	00000073          	ecall
 3c2:	8082                	ret

00000000000003c4 <close>:
 3c4:	48d5                	li	a7,21
 3c6:	00000073          	ecall
 3ca:	8082                	ret

00000000000003cc <kill>:
 3cc:	4899                	li	a7,6
 3ce:	00000073          	ecall
 3d2:	8082                	ret

00000000000003d4 <exec>:
 3d4:	489d                	li	a7,7
 3d6:	00000073          	ecall
 3da:	8082                	ret

00000000000003dc <open>:
 3dc:	48bd                	li	a7,15
 3de:	00000073          	ecall
 3e2:	8082                	ret

00000000000003e4 <mknod>:
 3e4:	48c5                	li	a7,17
 3e6:	00000073          	ecall
 3ea:	8082                	ret

00000000000003ec <unlink>:
 3ec:	48c9                	li	a7,18
 3ee:	00000073          	ecall
 3f2:	8082                	ret

00000000000003f4 <fstat>:
 3f4:	48a1                	li	a7,8
 3f6:	00000073          	ecall
 3fa:	8082                	ret

00000000000003fc <link>:
 3fc:	48cd                	li	a7,19
 3fe:	00000073          	ecall
 402:	8082                	ret

0000000000000404 <mkdir>:
 404:	48d1                	li	a7,20
 406:	00000073          	ecall
 40a:	8082                	ret

000000000000040c <chdir>:
 40c:	48a5                	li	a7,9
 40e:	00000073          	ecall
 412:	8082                	ret

0000000000000414 <dup>:
 414:	48a9                	li	a7,10
 416:	00000073          	ecall
 41a:	8082                	ret

000000000000041c <getpid>:
 41c:	48ad                	li	a7,11
 41e:	00000073          	ecall
 422:	8082                	ret

0000000000000424 <sbrk>:
 424:	48b1                	li	a7,12
 426:	00000073          	ecall
 42a:	8082                	ret

000000000000042c <sleep>:
 42c:	48b5                	li	a7,13
 42e:	00000073          	ecall
 432:	8082                	ret

0000000000000434 <uptime>:
 434:	48b9                	li	a7,14
 436:	00000073          	ecall
 43a:	8082                	ret

000000000000043c <trace>:
 43c:	48d9                	li	a7,22
 43e:	00000073          	ecall
 442:	8082                	ret

0000000000000444 <putc>:
 444:	1101                	addi	sp,sp,-32
 446:	ec06                	sd	ra,24(sp)
 448:	e822                	sd	s0,16(sp)
 44a:	1000                	addi	s0,sp,32
 44c:	feb407a3          	sb	a1,-17(s0)
 450:	4605                	li	a2,1
 452:	fef40593          	addi	a1,s0,-17
 456:	00000097          	auipc	ra,0x0
 45a:	f66080e7          	jalr	-154(ra) # 3bc <write>
 45e:	60e2                	ld	ra,24(sp)
 460:	6442                	ld	s0,16(sp)
 462:	6105                	addi	sp,sp,32
 464:	8082                	ret

0000000000000466 <printint>:
 466:	7139                	addi	sp,sp,-64
 468:	fc06                	sd	ra,56(sp)
 46a:	f822                	sd	s0,48(sp)
 46c:	f426                	sd	s1,40(sp)
 46e:	f04a                	sd	s2,32(sp)
 470:	ec4e                	sd	s3,24(sp)
 472:	0080                	addi	s0,sp,64
 474:	84aa                	mv	s1,a0
 476:	c299                	beqz	a3,47c <printint+0x16>
 478:	0805c863          	bltz	a1,508 <printint+0xa2>
 47c:	2581                	sext.w	a1,a1
 47e:	4881                	li	a7,0
 480:	fc040693          	addi	a3,s0,-64
 484:	4701                	li	a4,0
 486:	2601                	sext.w	a2,a2
 488:	00000517          	auipc	a0,0x0
 48c:	48050513          	addi	a0,a0,1152 # 908 <digits>
 490:	883a                	mv	a6,a4
 492:	2705                	addiw	a4,a4,1
 494:	02c5f7bb          	remuw	a5,a1,a2
 498:	1782                	slli	a5,a5,0x20
 49a:	9381                	srli	a5,a5,0x20
 49c:	97aa                	add	a5,a5,a0
 49e:	0007c783          	lbu	a5,0(a5)
 4a2:	00f68023          	sb	a5,0(a3)
 4a6:	0005879b          	sext.w	a5,a1
 4aa:	02c5d5bb          	divuw	a1,a1,a2
 4ae:	0685                	addi	a3,a3,1
 4b0:	fec7f0e3          	bgeu	a5,a2,490 <printint+0x2a>
 4b4:	00088b63          	beqz	a7,4ca <printint+0x64>
 4b8:	fd040793          	addi	a5,s0,-48
 4bc:	973e                	add	a4,a4,a5
 4be:	02d00793          	li	a5,45
 4c2:	fef70823          	sb	a5,-16(a4)
 4c6:	0028071b          	addiw	a4,a6,2
 4ca:	02e05863          	blez	a4,4fa <printint+0x94>
 4ce:	fc040793          	addi	a5,s0,-64
 4d2:	00e78933          	add	s2,a5,a4
 4d6:	fff78993          	addi	s3,a5,-1
 4da:	99ba                	add	s3,s3,a4
 4dc:	377d                	addiw	a4,a4,-1
 4de:	1702                	slli	a4,a4,0x20
 4e0:	9301                	srli	a4,a4,0x20
 4e2:	40e989b3          	sub	s3,s3,a4
 4e6:	fff94583          	lbu	a1,-1(s2)
 4ea:	8526                	mv	a0,s1
 4ec:	00000097          	auipc	ra,0x0
 4f0:	f58080e7          	jalr	-168(ra) # 444 <putc>
 4f4:	197d                	addi	s2,s2,-1
 4f6:	ff3918e3          	bne	s2,s3,4e6 <printint+0x80>
 4fa:	70e2                	ld	ra,56(sp)
 4fc:	7442                	ld	s0,48(sp)
 4fe:	74a2                	ld	s1,40(sp)
 500:	7902                	ld	s2,32(sp)
 502:	69e2                	ld	s3,24(sp)
 504:	6121                	addi	sp,sp,64
 506:	8082                	ret
 508:	40b005bb          	negw	a1,a1
 50c:	4885                	li	a7,1
 50e:	bf8d                	j	480 <printint+0x1a>

0000000000000510 <vprintf>:
 510:	7119                	addi	sp,sp,-128
 512:	fc86                	sd	ra,120(sp)
 514:	f8a2                	sd	s0,112(sp)
 516:	f4a6                	sd	s1,104(sp)
 518:	f0ca                	sd	s2,96(sp)
 51a:	ecce                	sd	s3,88(sp)
 51c:	e8d2                	sd	s4,80(sp)
 51e:	e4d6                	sd	s5,72(sp)
 520:	e0da                	sd	s6,64(sp)
 522:	fc5e                	sd	s7,56(sp)
 524:	f862                	sd	s8,48(sp)
 526:	f466                	sd	s9,40(sp)
 528:	f06a                	sd	s10,32(sp)
 52a:	ec6e                	sd	s11,24(sp)
 52c:	0100                	addi	s0,sp,128
 52e:	0005c903          	lbu	s2,0(a1)
 532:	18090f63          	beqz	s2,6d0 <vprintf+0x1c0>
 536:	8aaa                	mv	s5,a0
 538:	8b32                	mv	s6,a2
 53a:	00158493          	addi	s1,a1,1
 53e:	4981                	li	s3,0
 540:	02500a13          	li	s4,37
 544:	06400c13          	li	s8,100
 548:	06c00c93          	li	s9,108
 54c:	07800d13          	li	s10,120
 550:	07000d93          	li	s11,112
 554:	00000b97          	auipc	s7,0x0
 558:	3b4b8b93          	addi	s7,s7,948 # 908 <digits>
 55c:	a839                	j	57a <vprintf+0x6a>
 55e:	85ca                	mv	a1,s2
 560:	8556                	mv	a0,s5
 562:	00000097          	auipc	ra,0x0
 566:	ee2080e7          	jalr	-286(ra) # 444 <putc>
 56a:	a019                	j	570 <vprintf+0x60>
 56c:	01498f63          	beq	s3,s4,58a <vprintf+0x7a>
 570:	0485                	addi	s1,s1,1
 572:	fff4c903          	lbu	s2,-1(s1)
 576:	14090d63          	beqz	s2,6d0 <vprintf+0x1c0>
 57a:	0009079b          	sext.w	a5,s2
 57e:	fe0997e3          	bnez	s3,56c <vprintf+0x5c>
 582:	fd479ee3          	bne	a5,s4,55e <vprintf+0x4e>
 586:	89be                	mv	s3,a5
 588:	b7e5                	j	570 <vprintf+0x60>
 58a:	05878063          	beq	a5,s8,5ca <vprintf+0xba>
 58e:	05978c63          	beq	a5,s9,5e6 <vprintf+0xd6>
 592:	07a78863          	beq	a5,s10,602 <vprintf+0xf2>
 596:	09b78463          	beq	a5,s11,61e <vprintf+0x10e>
 59a:	07300713          	li	a4,115
 59e:	0ce78663          	beq	a5,a4,66a <vprintf+0x15a>
 5a2:	06300713          	li	a4,99
 5a6:	0ee78e63          	beq	a5,a4,6a2 <vprintf+0x192>
 5aa:	11478863          	beq	a5,s4,6ba <vprintf+0x1aa>
 5ae:	85d2                	mv	a1,s4
 5b0:	8556                	mv	a0,s5
 5b2:	00000097          	auipc	ra,0x0
 5b6:	e92080e7          	jalr	-366(ra) # 444 <putc>
 5ba:	85ca                	mv	a1,s2
 5bc:	8556                	mv	a0,s5
 5be:	00000097          	auipc	ra,0x0
 5c2:	e86080e7          	jalr	-378(ra) # 444 <putc>
 5c6:	4981                	li	s3,0
 5c8:	b765                	j	570 <vprintf+0x60>
 5ca:	008b0913          	addi	s2,s6,8
 5ce:	4685                	li	a3,1
 5d0:	4629                	li	a2,10
 5d2:	000b2583          	lw	a1,0(s6)
 5d6:	8556                	mv	a0,s5
 5d8:	00000097          	auipc	ra,0x0
 5dc:	e8e080e7          	jalr	-370(ra) # 466 <printint>
 5e0:	8b4a                	mv	s6,s2
 5e2:	4981                	li	s3,0
 5e4:	b771                	j	570 <vprintf+0x60>
 5e6:	008b0913          	addi	s2,s6,8
 5ea:	4681                	li	a3,0
 5ec:	4629                	li	a2,10
 5ee:	000b2583          	lw	a1,0(s6)
 5f2:	8556                	mv	a0,s5
 5f4:	00000097          	auipc	ra,0x0
 5f8:	e72080e7          	jalr	-398(ra) # 466 <printint>
 5fc:	8b4a                	mv	s6,s2
 5fe:	4981                	li	s3,0
 600:	bf85                	j	570 <vprintf+0x60>
 602:	008b0913          	addi	s2,s6,8
 606:	4681                	li	a3,0
 608:	4641                	li	a2,16
 60a:	000b2583          	lw	a1,0(s6)
 60e:	8556                	mv	a0,s5
 610:	00000097          	auipc	ra,0x0
 614:	e56080e7          	jalr	-426(ra) # 466 <printint>
 618:	8b4a                	mv	s6,s2
 61a:	4981                	li	s3,0
 61c:	bf91                	j	570 <vprintf+0x60>
 61e:	008b0793          	addi	a5,s6,8
 622:	f8f43423          	sd	a5,-120(s0)
 626:	000b3983          	ld	s3,0(s6)
 62a:	03000593          	li	a1,48
 62e:	8556                	mv	a0,s5
 630:	00000097          	auipc	ra,0x0
 634:	e14080e7          	jalr	-492(ra) # 444 <putc>
 638:	85ea                	mv	a1,s10
 63a:	8556                	mv	a0,s5
 63c:	00000097          	auipc	ra,0x0
 640:	e08080e7          	jalr	-504(ra) # 444 <putc>
 644:	4941                	li	s2,16
 646:	03c9d793          	srli	a5,s3,0x3c
 64a:	97de                	add	a5,a5,s7
 64c:	0007c583          	lbu	a1,0(a5)
 650:	8556                	mv	a0,s5
 652:	00000097          	auipc	ra,0x0
 656:	df2080e7          	jalr	-526(ra) # 444 <putc>
 65a:	0992                	slli	s3,s3,0x4
 65c:	397d                	addiw	s2,s2,-1
 65e:	fe0914e3          	bnez	s2,646 <vprintf+0x136>
 662:	f8843b03          	ld	s6,-120(s0)
 666:	4981                	li	s3,0
 668:	b721                	j	570 <vprintf+0x60>
 66a:	008b0993          	addi	s3,s6,8
 66e:	000b3903          	ld	s2,0(s6)
 672:	02090163          	beqz	s2,694 <vprintf+0x184>
 676:	00094583          	lbu	a1,0(s2)
 67a:	c9a1                	beqz	a1,6ca <vprintf+0x1ba>
 67c:	8556                	mv	a0,s5
 67e:	00000097          	auipc	ra,0x0
 682:	dc6080e7          	jalr	-570(ra) # 444 <putc>
 686:	0905                	addi	s2,s2,1
 688:	00094583          	lbu	a1,0(s2)
 68c:	f9e5                	bnez	a1,67c <vprintf+0x16c>
 68e:	8b4e                	mv	s6,s3
 690:	4981                	li	s3,0
 692:	bdf9                	j	570 <vprintf+0x60>
 694:	00000917          	auipc	s2,0x0
 698:	26c90913          	addi	s2,s2,620 # 900 <malloc+0x126>
 69c:	02800593          	li	a1,40
 6a0:	bff1                	j	67c <vprintf+0x16c>
 6a2:	008b0913          	addi	s2,s6,8
 6a6:	000b4583          	lbu	a1,0(s6)
 6aa:	8556                	mv	a0,s5
 6ac:	00000097          	auipc	ra,0x0
 6b0:	d98080e7          	jalr	-616(ra) # 444 <putc>
 6b4:	8b4a                	mv	s6,s2
 6b6:	4981                	li	s3,0
 6b8:	bd65                	j	570 <vprintf+0x60>
 6ba:	85d2                	mv	a1,s4
 6bc:	8556                	mv	a0,s5
 6be:	00000097          	auipc	ra,0x0
 6c2:	d86080e7          	jalr	-634(ra) # 444 <putc>
 6c6:	4981                	li	s3,0
 6c8:	b565                	j	570 <vprintf+0x60>
 6ca:	8b4e                	mv	s6,s3
 6cc:	4981                	li	s3,0
 6ce:	b54d                	j	570 <vprintf+0x60>
 6d0:	70e6                	ld	ra,120(sp)
 6d2:	7446                	ld	s0,112(sp)
 6d4:	74a6                	ld	s1,104(sp)
 6d6:	7906                	ld	s2,96(sp)
 6d8:	69e6                	ld	s3,88(sp)
 6da:	6a46                	ld	s4,80(sp)
 6dc:	6aa6                	ld	s5,72(sp)
 6de:	6b06                	ld	s6,64(sp)
 6e0:	7be2                	ld	s7,56(sp)
 6e2:	7c42                	ld	s8,48(sp)
 6e4:	7ca2                	ld	s9,40(sp)
 6e6:	7d02                	ld	s10,32(sp)
 6e8:	6de2                	ld	s11,24(sp)
 6ea:	6109                	addi	sp,sp,128
 6ec:	8082                	ret

00000000000006ee <fprintf>:
 6ee:	715d                	addi	sp,sp,-80
 6f0:	ec06                	sd	ra,24(sp)
 6f2:	e822                	sd	s0,16(sp)
 6f4:	1000                	addi	s0,sp,32
 6f6:	e010                	sd	a2,0(s0)
 6f8:	e414                	sd	a3,8(s0)
 6fa:	e818                	sd	a4,16(s0)
 6fc:	ec1c                	sd	a5,24(s0)
 6fe:	03043023          	sd	a6,32(s0)
 702:	03143423          	sd	a7,40(s0)
 706:	fe843423          	sd	s0,-24(s0)
 70a:	8622                	mv	a2,s0
 70c:	00000097          	auipc	ra,0x0
 710:	e04080e7          	jalr	-508(ra) # 510 <vprintf>
 714:	60e2                	ld	ra,24(sp)
 716:	6442                	ld	s0,16(sp)
 718:	6161                	addi	sp,sp,80
 71a:	8082                	ret

000000000000071c <printf>:
 71c:	711d                	addi	sp,sp,-96
 71e:	ec06                	sd	ra,24(sp)
 720:	e822                	sd	s0,16(sp)
 722:	1000                	addi	s0,sp,32
 724:	e40c                	sd	a1,8(s0)
 726:	e810                	sd	a2,16(s0)
 728:	ec14                	sd	a3,24(s0)
 72a:	f018                	sd	a4,32(s0)
 72c:	f41c                	sd	a5,40(s0)
 72e:	03043823          	sd	a6,48(s0)
 732:	03143c23          	sd	a7,56(s0)
 736:	00840613          	addi	a2,s0,8
 73a:	fec43423          	sd	a2,-24(s0)
 73e:	85aa                	mv	a1,a0
 740:	4505                	li	a0,1
 742:	00000097          	auipc	ra,0x0
 746:	dce080e7          	jalr	-562(ra) # 510 <vprintf>
 74a:	60e2                	ld	ra,24(sp)
 74c:	6442                	ld	s0,16(sp)
 74e:	6125                	addi	sp,sp,96
 750:	8082                	ret

0000000000000752 <free>:
 752:	1141                	addi	sp,sp,-16
 754:	e422                	sd	s0,8(sp)
 756:	0800                	addi	s0,sp,16
 758:	ff050693          	addi	a3,a0,-16
 75c:	00001797          	auipc	a5,0x1
 760:	8a47b783          	ld	a5,-1884(a5) # 1000 <freep>
 764:	a805                	j	794 <free+0x42>
 766:	4618                	lw	a4,8(a2)
 768:	9db9                	addw	a1,a1,a4
 76a:	feb52c23          	sw	a1,-8(a0)
 76e:	6398                	ld	a4,0(a5)
 770:	6318                	ld	a4,0(a4)
 772:	fee53823          	sd	a4,-16(a0)
 776:	a091                	j	7ba <free+0x68>
 778:	ff852703          	lw	a4,-8(a0)
 77c:	9e39                	addw	a2,a2,a4
 77e:	c790                	sw	a2,8(a5)
 780:	ff053703          	ld	a4,-16(a0)
 784:	e398                	sd	a4,0(a5)
 786:	a099                	j	7cc <free+0x7a>
 788:	6398                	ld	a4,0(a5)
 78a:	00e7e463          	bltu	a5,a4,792 <free+0x40>
 78e:	00e6ea63          	bltu	a3,a4,7a2 <free+0x50>
 792:	87ba                	mv	a5,a4
 794:	fed7fae3          	bgeu	a5,a3,788 <free+0x36>
 798:	6398                	ld	a4,0(a5)
 79a:	00e6e463          	bltu	a3,a4,7a2 <free+0x50>
 79e:	fee7eae3          	bltu	a5,a4,792 <free+0x40>
 7a2:	ff852583          	lw	a1,-8(a0)
 7a6:	6390                	ld	a2,0(a5)
 7a8:	02059713          	slli	a4,a1,0x20
 7ac:	9301                	srli	a4,a4,0x20
 7ae:	0712                	slli	a4,a4,0x4
 7b0:	9736                	add	a4,a4,a3
 7b2:	fae60ae3          	beq	a2,a4,766 <free+0x14>
 7b6:	fec53823          	sd	a2,-16(a0)
 7ba:	4790                	lw	a2,8(a5)
 7bc:	02061713          	slli	a4,a2,0x20
 7c0:	9301                	srli	a4,a4,0x20
 7c2:	0712                	slli	a4,a4,0x4
 7c4:	973e                	add	a4,a4,a5
 7c6:	fae689e3          	beq	a3,a4,778 <free+0x26>
 7ca:	e394                	sd	a3,0(a5)
 7cc:	00001717          	auipc	a4,0x1
 7d0:	82f73a23          	sd	a5,-1996(a4) # 1000 <freep>
 7d4:	6422                	ld	s0,8(sp)
 7d6:	0141                	addi	sp,sp,16
 7d8:	8082                	ret

00000000000007da <malloc>:
 7da:	7139                	addi	sp,sp,-64
 7dc:	fc06                	sd	ra,56(sp)
 7de:	f822                	sd	s0,48(sp)
 7e0:	f426                	sd	s1,40(sp)
 7e2:	f04a                	sd	s2,32(sp)
 7e4:	ec4e                	sd	s3,24(sp)
 7e6:	e852                	sd	s4,16(sp)
 7e8:	e456                	sd	s5,8(sp)
 7ea:	e05a                	sd	s6,0(sp)
 7ec:	0080                	addi	s0,sp,64
 7ee:	02051493          	slli	s1,a0,0x20
 7f2:	9081                	srli	s1,s1,0x20
 7f4:	04bd                	addi	s1,s1,15
 7f6:	8091                	srli	s1,s1,0x4
 7f8:	0014899b          	addiw	s3,s1,1
 7fc:	0485                	addi	s1,s1,1
 7fe:	00001517          	auipc	a0,0x1
 802:	80253503          	ld	a0,-2046(a0) # 1000 <freep>
 806:	c515                	beqz	a0,832 <malloc+0x58>
 808:	611c                	ld	a5,0(a0)
 80a:	4798                	lw	a4,8(a5)
 80c:	02977f63          	bgeu	a4,s1,84a <malloc+0x70>
 810:	8a4e                	mv	s4,s3
 812:	0009871b          	sext.w	a4,s3
 816:	6685                	lui	a3,0x1
 818:	00d77363          	bgeu	a4,a3,81e <malloc+0x44>
 81c:	6a05                	lui	s4,0x1
 81e:	000a0b1b          	sext.w	s6,s4
 822:	004a1a1b          	slliw	s4,s4,0x4
 826:	00000917          	auipc	s2,0x0
 82a:	7da90913          	addi	s2,s2,2010 # 1000 <freep>
 82e:	5afd                	li	s5,-1
 830:	a88d                	j	8a2 <malloc+0xc8>
 832:	00000797          	auipc	a5,0x0
 836:	7de78793          	addi	a5,a5,2014 # 1010 <base>
 83a:	00000717          	auipc	a4,0x0
 83e:	7cf73323          	sd	a5,1990(a4) # 1000 <freep>
 842:	e39c                	sd	a5,0(a5)
 844:	0007a423          	sw	zero,8(a5)
 848:	b7e1                	j	810 <malloc+0x36>
 84a:	02e48b63          	beq	s1,a4,880 <malloc+0xa6>
 84e:	4137073b          	subw	a4,a4,s3
 852:	c798                	sw	a4,8(a5)
 854:	1702                	slli	a4,a4,0x20
 856:	9301                	srli	a4,a4,0x20
 858:	0712                	slli	a4,a4,0x4
 85a:	97ba                	add	a5,a5,a4
 85c:	0137a423          	sw	s3,8(a5)
 860:	00000717          	auipc	a4,0x0
 864:	7aa73023          	sd	a0,1952(a4) # 1000 <freep>
 868:	01078513          	addi	a0,a5,16
 86c:	70e2                	ld	ra,56(sp)
 86e:	7442                	ld	s0,48(sp)
 870:	74a2                	ld	s1,40(sp)
 872:	7902                	ld	s2,32(sp)
 874:	69e2                	ld	s3,24(sp)
 876:	6a42                	ld	s4,16(sp)
 878:	6aa2                	ld	s5,8(sp)
 87a:	6b02                	ld	s6,0(sp)
 87c:	6121                	addi	sp,sp,64
 87e:	8082                	ret
 880:	6398                	ld	a4,0(a5)
 882:	e118                	sd	a4,0(a0)
 884:	bff1                	j	860 <malloc+0x86>
 886:	01652423          	sw	s6,8(a0)
 88a:	0541                	addi	a0,a0,16
 88c:	00000097          	auipc	ra,0x0
 890:	ec6080e7          	jalr	-314(ra) # 752 <free>
 894:	00093503          	ld	a0,0(s2)
 898:	d971                	beqz	a0,86c <malloc+0x92>
 89a:	611c                	ld	a5,0(a0)
 89c:	4798                	lw	a4,8(a5)
 89e:	fa9776e3          	bgeu	a4,s1,84a <malloc+0x70>
 8a2:	00093703          	ld	a4,0(s2)
 8a6:	853e                	mv	a0,a5
 8a8:	fef719e3          	bne	a4,a5,89a <malloc+0xc0>
 8ac:	8552                	mv	a0,s4
 8ae:	00000097          	auipc	ra,0x0
 8b2:	b76080e7          	jalr	-1162(ra) # 424 <sbrk>
 8b6:	fd5518e3          	bne	a0,s5,886 <malloc+0xac>
 8ba:	4501                	li	a0,0
 8bc:	bf45                	j	86c <malloc+0x92>
