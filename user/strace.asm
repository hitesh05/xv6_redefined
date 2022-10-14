
user/_strace:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	4789                	li	a5,2
  10:	02a7c063          	blt	a5,a0,30 <main+0x30>
  14:	00001597          	auipc	a1,0x1
  18:	87c58593          	addi	a1,a1,-1924 # 890 <malloc+0xf0>
  1c:	4509                	li	a0,2
  1e:	00000097          	auipc	ra,0x0
  22:	696080e7          	jalr	1686(ra) # 6b4 <fprintf>
  26:	4505                	li	a0,1
  28:	00000097          	auipc	ra,0x0
  2c:	31a080e7          	jalr	794(ra) # 342 <exit>
  30:	84aa                	mv	s1,a0
  32:	892e                	mv	s2,a1
  34:	6588                	ld	a0,8(a1)
  36:	00000097          	auipc	ra,0x0
  3a:	20c080e7          	jalr	524(ra) # 242 <atoi>
  3e:	00000097          	auipc	ra,0x0
  42:	3a4080e7          	jalr	932(ra) # 3e2 <trace>
  46:	ffe4859b          	addiw	a1,s1,-2
  4a:	fff4879b          	addiw	a5,s1,-1
  4e:	078e                	slli	a5,a5,0x3
  50:	07bd                	addi	a5,a5,15
  52:	9bc1                	andi	a5,a5,-16
  54:	40f10133          	sub	sp,sp,a5
  58:	898a                	mv	s3,sp
  5a:	01090793          	addi	a5,s2,16
  5e:	874e                	mv	a4,s3
  60:	ffd4869b          	addiw	a3,s1,-3
  64:	1682                	slli	a3,a3,0x20
  66:	9281                	srli	a3,a3,0x20
  68:	068e                	slli	a3,a3,0x3
  6a:	0961                	addi	s2,s2,24
  6c:	96ca                	add	a3,a3,s2
  6e:	6390                	ld	a2,0(a5)
  70:	e310                	sd	a2,0(a4)
  72:	07a1                	addi	a5,a5,8
  74:	0721                	addi	a4,a4,8
  76:	fed79ce3          	bne	a5,a3,6e <main+0x6e>
  7a:	00359793          	slli	a5,a1,0x3
  7e:	97ce                	add	a5,a5,s3
  80:	0007b023          	sd	zero,0(a5)
  84:	85ce                	mv	a1,s3
  86:	0009b503          	ld	a0,0(s3)
  8a:	00000097          	auipc	ra,0x0
  8e:	2f0080e7          	jalr	752(ra) # 37a <exec>
  92:	0009b603          	ld	a2,0(s3)
  96:	00001597          	auipc	a1,0x1
  9a:	81258593          	addi	a1,a1,-2030 # 8a8 <malloc+0x108>
  9e:	4509                	li	a0,2
  a0:	00000097          	auipc	ra,0x0
  a4:	614080e7          	jalr	1556(ra) # 6b4 <fprintf>
  a8:	4501                	li	a0,0
  aa:	00000097          	auipc	ra,0x0
  ae:	298080e7          	jalr	664(ra) # 342 <exit>

00000000000000b2 <_main>:
  b2:	1141                	addi	sp,sp,-16
  b4:	e406                	sd	ra,8(sp)
  b6:	e022                	sd	s0,0(sp)
  b8:	0800                	addi	s0,sp,16
  ba:	00000097          	auipc	ra,0x0
  be:	f46080e7          	jalr	-186(ra) # 0 <main>
  c2:	4501                	li	a0,0
  c4:	00000097          	auipc	ra,0x0
  c8:	27e080e7          	jalr	638(ra) # 342 <exit>

00000000000000cc <strcpy>:
  cc:	1141                	addi	sp,sp,-16
  ce:	e422                	sd	s0,8(sp)
  d0:	0800                	addi	s0,sp,16
  d2:	87aa                	mv	a5,a0
  d4:	0585                	addi	a1,a1,1
  d6:	0785                	addi	a5,a5,1
  d8:	fff5c703          	lbu	a4,-1(a1)
  dc:	fee78fa3          	sb	a4,-1(a5)
  e0:	fb75                	bnez	a4,d4 <strcpy+0x8>
  e2:	6422                	ld	s0,8(sp)
  e4:	0141                	addi	sp,sp,16
  e6:	8082                	ret

00000000000000e8 <strcmp>:
  e8:	1141                	addi	sp,sp,-16
  ea:	e422                	sd	s0,8(sp)
  ec:	0800                	addi	s0,sp,16
  ee:	00054783          	lbu	a5,0(a0)
  f2:	cb91                	beqz	a5,106 <strcmp+0x1e>
  f4:	0005c703          	lbu	a4,0(a1)
  f8:	00f71763          	bne	a4,a5,106 <strcmp+0x1e>
  fc:	0505                	addi	a0,a0,1
  fe:	0585                	addi	a1,a1,1
 100:	00054783          	lbu	a5,0(a0)
 104:	fbe5                	bnez	a5,f4 <strcmp+0xc>
 106:	0005c503          	lbu	a0,0(a1)
 10a:	40a7853b          	subw	a0,a5,a0
 10e:	6422                	ld	s0,8(sp)
 110:	0141                	addi	sp,sp,16
 112:	8082                	ret

0000000000000114 <strlen>:
 114:	1141                	addi	sp,sp,-16
 116:	e422                	sd	s0,8(sp)
 118:	0800                	addi	s0,sp,16
 11a:	00054783          	lbu	a5,0(a0)
 11e:	cf91                	beqz	a5,13a <strlen+0x26>
 120:	0505                	addi	a0,a0,1
 122:	87aa                	mv	a5,a0
 124:	4685                	li	a3,1
 126:	9e89                	subw	a3,a3,a0
 128:	00f6853b          	addw	a0,a3,a5
 12c:	0785                	addi	a5,a5,1
 12e:	fff7c703          	lbu	a4,-1(a5)
 132:	fb7d                	bnez	a4,128 <strlen+0x14>
 134:	6422                	ld	s0,8(sp)
 136:	0141                	addi	sp,sp,16
 138:	8082                	ret
 13a:	4501                	li	a0,0
 13c:	bfe5                	j	134 <strlen+0x20>

000000000000013e <memset>:
 13e:	1141                	addi	sp,sp,-16
 140:	e422                	sd	s0,8(sp)
 142:	0800                	addi	s0,sp,16
 144:	ce09                	beqz	a2,15e <memset+0x20>
 146:	87aa                	mv	a5,a0
 148:	fff6071b          	addiw	a4,a2,-1
 14c:	1702                	slli	a4,a4,0x20
 14e:	9301                	srli	a4,a4,0x20
 150:	0705                	addi	a4,a4,1
 152:	972a                	add	a4,a4,a0
 154:	00b78023          	sb	a1,0(a5)
 158:	0785                	addi	a5,a5,1
 15a:	fee79de3          	bne	a5,a4,154 <memset+0x16>
 15e:	6422                	ld	s0,8(sp)
 160:	0141                	addi	sp,sp,16
 162:	8082                	ret

0000000000000164 <strchr>:
 164:	1141                	addi	sp,sp,-16
 166:	e422                	sd	s0,8(sp)
 168:	0800                	addi	s0,sp,16
 16a:	00054783          	lbu	a5,0(a0)
 16e:	cb99                	beqz	a5,184 <strchr+0x20>
 170:	00f58763          	beq	a1,a5,17e <strchr+0x1a>
 174:	0505                	addi	a0,a0,1
 176:	00054783          	lbu	a5,0(a0)
 17a:	fbfd                	bnez	a5,170 <strchr+0xc>
 17c:	4501                	li	a0,0
 17e:	6422                	ld	s0,8(sp)
 180:	0141                	addi	sp,sp,16
 182:	8082                	ret
 184:	4501                	li	a0,0
 186:	bfe5                	j	17e <strchr+0x1a>

0000000000000188 <gets>:
 188:	711d                	addi	sp,sp,-96
 18a:	ec86                	sd	ra,88(sp)
 18c:	e8a2                	sd	s0,80(sp)
 18e:	e4a6                	sd	s1,72(sp)
 190:	e0ca                	sd	s2,64(sp)
 192:	fc4e                	sd	s3,56(sp)
 194:	f852                	sd	s4,48(sp)
 196:	f456                	sd	s5,40(sp)
 198:	f05a                	sd	s6,32(sp)
 19a:	ec5e                	sd	s7,24(sp)
 19c:	1080                	addi	s0,sp,96
 19e:	8baa                	mv	s7,a0
 1a0:	8a2e                	mv	s4,a1
 1a2:	892a                	mv	s2,a0
 1a4:	4481                	li	s1,0
 1a6:	4aa9                	li	s5,10
 1a8:	4b35                	li	s6,13
 1aa:	89a6                	mv	s3,s1
 1ac:	2485                	addiw	s1,s1,1
 1ae:	0344d863          	bge	s1,s4,1de <gets+0x56>
 1b2:	4605                	li	a2,1
 1b4:	faf40593          	addi	a1,s0,-81
 1b8:	4501                	li	a0,0
 1ba:	00000097          	auipc	ra,0x0
 1be:	1a0080e7          	jalr	416(ra) # 35a <read>
 1c2:	00a05e63          	blez	a0,1de <gets+0x56>
 1c6:	faf44783          	lbu	a5,-81(s0)
 1ca:	00f90023          	sb	a5,0(s2)
 1ce:	01578763          	beq	a5,s5,1dc <gets+0x54>
 1d2:	0905                	addi	s2,s2,1
 1d4:	fd679be3          	bne	a5,s6,1aa <gets+0x22>
 1d8:	89a6                	mv	s3,s1
 1da:	a011                	j	1de <gets+0x56>
 1dc:	89a6                	mv	s3,s1
 1de:	99de                	add	s3,s3,s7
 1e0:	00098023          	sb	zero,0(s3)
 1e4:	855e                	mv	a0,s7
 1e6:	60e6                	ld	ra,88(sp)
 1e8:	6446                	ld	s0,80(sp)
 1ea:	64a6                	ld	s1,72(sp)
 1ec:	6906                	ld	s2,64(sp)
 1ee:	79e2                	ld	s3,56(sp)
 1f0:	7a42                	ld	s4,48(sp)
 1f2:	7aa2                	ld	s5,40(sp)
 1f4:	7b02                	ld	s6,32(sp)
 1f6:	6be2                	ld	s7,24(sp)
 1f8:	6125                	addi	sp,sp,96
 1fa:	8082                	ret

00000000000001fc <stat>:
 1fc:	1101                	addi	sp,sp,-32
 1fe:	ec06                	sd	ra,24(sp)
 200:	e822                	sd	s0,16(sp)
 202:	e426                	sd	s1,8(sp)
 204:	e04a                	sd	s2,0(sp)
 206:	1000                	addi	s0,sp,32
 208:	892e                	mv	s2,a1
 20a:	4581                	li	a1,0
 20c:	00000097          	auipc	ra,0x0
 210:	176080e7          	jalr	374(ra) # 382 <open>
 214:	02054563          	bltz	a0,23e <stat+0x42>
 218:	84aa                	mv	s1,a0
 21a:	85ca                	mv	a1,s2
 21c:	00000097          	auipc	ra,0x0
 220:	17e080e7          	jalr	382(ra) # 39a <fstat>
 224:	892a                	mv	s2,a0
 226:	8526                	mv	a0,s1
 228:	00000097          	auipc	ra,0x0
 22c:	142080e7          	jalr	322(ra) # 36a <close>
 230:	854a                	mv	a0,s2
 232:	60e2                	ld	ra,24(sp)
 234:	6442                	ld	s0,16(sp)
 236:	64a2                	ld	s1,8(sp)
 238:	6902                	ld	s2,0(sp)
 23a:	6105                	addi	sp,sp,32
 23c:	8082                	ret
 23e:	597d                	li	s2,-1
 240:	bfc5                	j	230 <stat+0x34>

0000000000000242 <atoi>:
 242:	1141                	addi	sp,sp,-16
 244:	e422                	sd	s0,8(sp)
 246:	0800                	addi	s0,sp,16
 248:	00054603          	lbu	a2,0(a0)
 24c:	fd06079b          	addiw	a5,a2,-48
 250:	0ff7f793          	andi	a5,a5,255
 254:	4725                	li	a4,9
 256:	02f76963          	bltu	a4,a5,288 <atoi+0x46>
 25a:	86aa                	mv	a3,a0
 25c:	4501                	li	a0,0
 25e:	45a5                	li	a1,9
 260:	0685                	addi	a3,a3,1
 262:	0025179b          	slliw	a5,a0,0x2
 266:	9fa9                	addw	a5,a5,a0
 268:	0017979b          	slliw	a5,a5,0x1
 26c:	9fb1                	addw	a5,a5,a2
 26e:	fd07851b          	addiw	a0,a5,-48
 272:	0006c603          	lbu	a2,0(a3)
 276:	fd06071b          	addiw	a4,a2,-48
 27a:	0ff77713          	andi	a4,a4,255
 27e:	fee5f1e3          	bgeu	a1,a4,260 <atoi+0x1e>
 282:	6422                	ld	s0,8(sp)
 284:	0141                	addi	sp,sp,16
 286:	8082                	ret
 288:	4501                	li	a0,0
 28a:	bfe5                	j	282 <atoi+0x40>

000000000000028c <memmove>:
 28c:	1141                	addi	sp,sp,-16
 28e:	e422                	sd	s0,8(sp)
 290:	0800                	addi	s0,sp,16
 292:	02b57663          	bgeu	a0,a1,2be <memmove+0x32>
 296:	02c05163          	blez	a2,2b8 <memmove+0x2c>
 29a:	fff6079b          	addiw	a5,a2,-1
 29e:	1782                	slli	a5,a5,0x20
 2a0:	9381                	srli	a5,a5,0x20
 2a2:	0785                	addi	a5,a5,1
 2a4:	97aa                	add	a5,a5,a0
 2a6:	872a                	mv	a4,a0
 2a8:	0585                	addi	a1,a1,1
 2aa:	0705                	addi	a4,a4,1
 2ac:	fff5c683          	lbu	a3,-1(a1)
 2b0:	fed70fa3          	sb	a3,-1(a4)
 2b4:	fee79ae3          	bne	a5,a4,2a8 <memmove+0x1c>
 2b8:	6422                	ld	s0,8(sp)
 2ba:	0141                	addi	sp,sp,16
 2bc:	8082                	ret
 2be:	00c50733          	add	a4,a0,a2
 2c2:	95b2                	add	a1,a1,a2
 2c4:	fec05ae3          	blez	a2,2b8 <memmove+0x2c>
 2c8:	fff6079b          	addiw	a5,a2,-1
 2cc:	1782                	slli	a5,a5,0x20
 2ce:	9381                	srli	a5,a5,0x20
 2d0:	fff7c793          	not	a5,a5
 2d4:	97ba                	add	a5,a5,a4
 2d6:	15fd                	addi	a1,a1,-1
 2d8:	177d                	addi	a4,a4,-1
 2da:	0005c683          	lbu	a3,0(a1)
 2de:	00d70023          	sb	a3,0(a4)
 2e2:	fee79ae3          	bne	a5,a4,2d6 <memmove+0x4a>
 2e6:	bfc9                	j	2b8 <memmove+0x2c>

00000000000002e8 <memcmp>:
 2e8:	1141                	addi	sp,sp,-16
 2ea:	e422                	sd	s0,8(sp)
 2ec:	0800                	addi	s0,sp,16
 2ee:	ca05                	beqz	a2,31e <memcmp+0x36>
 2f0:	fff6069b          	addiw	a3,a2,-1
 2f4:	1682                	slli	a3,a3,0x20
 2f6:	9281                	srli	a3,a3,0x20
 2f8:	0685                	addi	a3,a3,1
 2fa:	96aa                	add	a3,a3,a0
 2fc:	00054783          	lbu	a5,0(a0)
 300:	0005c703          	lbu	a4,0(a1)
 304:	00e79863          	bne	a5,a4,314 <memcmp+0x2c>
 308:	0505                	addi	a0,a0,1
 30a:	0585                	addi	a1,a1,1
 30c:	fed518e3          	bne	a0,a3,2fc <memcmp+0x14>
 310:	4501                	li	a0,0
 312:	a019                	j	318 <memcmp+0x30>
 314:	40e7853b          	subw	a0,a5,a4
 318:	6422                	ld	s0,8(sp)
 31a:	0141                	addi	sp,sp,16
 31c:	8082                	ret
 31e:	4501                	li	a0,0
 320:	bfe5                	j	318 <memcmp+0x30>

0000000000000322 <memcpy>:
 322:	1141                	addi	sp,sp,-16
 324:	e406                	sd	ra,8(sp)
 326:	e022                	sd	s0,0(sp)
 328:	0800                	addi	s0,sp,16
 32a:	00000097          	auipc	ra,0x0
 32e:	f62080e7          	jalr	-158(ra) # 28c <memmove>
 332:	60a2                	ld	ra,8(sp)
 334:	6402                	ld	s0,0(sp)
 336:	0141                	addi	sp,sp,16
 338:	8082                	ret

000000000000033a <fork>:
 33a:	4885                	li	a7,1
 33c:	00000073          	ecall
 340:	8082                	ret

0000000000000342 <exit>:
 342:	4889                	li	a7,2
 344:	00000073          	ecall
 348:	8082                	ret

000000000000034a <wait>:
 34a:	488d                	li	a7,3
 34c:	00000073          	ecall
 350:	8082                	ret

0000000000000352 <pipe>:
 352:	4891                	li	a7,4
 354:	00000073          	ecall
 358:	8082                	ret

000000000000035a <read>:
 35a:	4895                	li	a7,5
 35c:	00000073          	ecall
 360:	8082                	ret

0000000000000362 <write>:
 362:	48c1                	li	a7,16
 364:	00000073          	ecall
 368:	8082                	ret

000000000000036a <close>:
 36a:	48d5                	li	a7,21
 36c:	00000073          	ecall
 370:	8082                	ret

0000000000000372 <kill>:
 372:	4899                	li	a7,6
 374:	00000073          	ecall
 378:	8082                	ret

000000000000037a <exec>:
 37a:	489d                	li	a7,7
 37c:	00000073          	ecall
 380:	8082                	ret

0000000000000382 <open>:
 382:	48bd                	li	a7,15
 384:	00000073          	ecall
 388:	8082                	ret

000000000000038a <mknod>:
 38a:	48c5                	li	a7,17
 38c:	00000073          	ecall
 390:	8082                	ret

0000000000000392 <unlink>:
 392:	48c9                	li	a7,18
 394:	00000073          	ecall
 398:	8082                	ret

000000000000039a <fstat>:
 39a:	48a1                	li	a7,8
 39c:	00000073          	ecall
 3a0:	8082                	ret

00000000000003a2 <link>:
 3a2:	48cd                	li	a7,19
 3a4:	00000073          	ecall
 3a8:	8082                	ret

00000000000003aa <mkdir>:
 3aa:	48d1                	li	a7,20
 3ac:	00000073          	ecall
 3b0:	8082                	ret

00000000000003b2 <chdir>:
 3b2:	48a5                	li	a7,9
 3b4:	00000073          	ecall
 3b8:	8082                	ret

00000000000003ba <dup>:
 3ba:	48a9                	li	a7,10
 3bc:	00000073          	ecall
 3c0:	8082                	ret

00000000000003c2 <getpid>:
 3c2:	48ad                	li	a7,11
 3c4:	00000073          	ecall
 3c8:	8082                	ret

00000000000003ca <sbrk>:
 3ca:	48b1                	li	a7,12
 3cc:	00000073          	ecall
 3d0:	8082                	ret

00000000000003d2 <sleep>:
 3d2:	48b5                	li	a7,13
 3d4:	00000073          	ecall
 3d8:	8082                	ret

00000000000003da <uptime>:
 3da:	48b9                	li	a7,14
 3dc:	00000073          	ecall
 3e0:	8082                	ret

00000000000003e2 <trace>:
 3e2:	48d9                	li	a7,22
 3e4:	00000073          	ecall
 3e8:	8082                	ret

00000000000003ea <setpriority>:
 3ea:	48e1                	li	a7,24
 3ec:	00000073          	ecall
 3f0:	8082                	ret

00000000000003f2 <waitx>:
 3f2:	48e9                	li	a7,26
 3f4:	00000073          	ecall
 3f8:	8082                	ret

00000000000003fa <sigalarm>:
 3fa:	48dd                	li	a7,23
 3fc:	00000073          	ecall
 400:	8082                	ret

0000000000000402 <sigreturn>:
 402:	48ed                	li	a7,27
 404:	00000073          	ecall
 408:	8082                	ret

000000000000040a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 40a:	1101                	addi	sp,sp,-32
 40c:	ec06                	sd	ra,24(sp)
 40e:	e822                	sd	s0,16(sp)
 410:	1000                	addi	s0,sp,32
 412:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 416:	4605                	li	a2,1
 418:	fef40593          	addi	a1,s0,-17
 41c:	00000097          	auipc	ra,0x0
 420:	f46080e7          	jalr	-186(ra) # 362 <write>
}
 424:	60e2                	ld	ra,24(sp)
 426:	6442                	ld	s0,16(sp)
 428:	6105                	addi	sp,sp,32
 42a:	8082                	ret

000000000000042c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 42c:	7139                	addi	sp,sp,-64
 42e:	fc06                	sd	ra,56(sp)
 430:	f822                	sd	s0,48(sp)
 432:	f426                	sd	s1,40(sp)
 434:	f04a                	sd	s2,32(sp)
 436:	ec4e                	sd	s3,24(sp)
 438:	0080                	addi	s0,sp,64
 43a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 43c:	c299                	beqz	a3,442 <printint+0x16>
 43e:	0805c863          	bltz	a1,4ce <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 442:	2581                	sext.w	a1,a1
  neg = 0;
 444:	4881                	li	a7,0
 446:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 44a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 44c:	2601                	sext.w	a2,a2
 44e:	00000517          	auipc	a0,0x0
 452:	47a50513          	addi	a0,a0,1146 # 8c8 <digits>
 456:	883a                	mv	a6,a4
 458:	2705                	addiw	a4,a4,1
 45a:	02c5f7bb          	remuw	a5,a1,a2
 45e:	1782                	slli	a5,a5,0x20
 460:	9381                	srli	a5,a5,0x20
 462:	97aa                	add	a5,a5,a0
 464:	0007c783          	lbu	a5,0(a5)
 468:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 46c:	0005879b          	sext.w	a5,a1
 470:	02c5d5bb          	divuw	a1,a1,a2
 474:	0685                	addi	a3,a3,1
 476:	fec7f0e3          	bgeu	a5,a2,456 <printint+0x2a>
  if(neg)
 47a:	00088b63          	beqz	a7,490 <printint+0x64>
    buf[i++] = '-';
 47e:	fd040793          	addi	a5,s0,-48
 482:	973e                	add	a4,a4,a5
 484:	02d00793          	li	a5,45
 488:	fef70823          	sb	a5,-16(a4)
 48c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 490:	02e05863          	blez	a4,4c0 <printint+0x94>
 494:	fc040793          	addi	a5,s0,-64
 498:	00e78933          	add	s2,a5,a4
 49c:	fff78993          	addi	s3,a5,-1
 4a0:	99ba                	add	s3,s3,a4
 4a2:	377d                	addiw	a4,a4,-1
 4a4:	1702                	slli	a4,a4,0x20
 4a6:	9301                	srli	a4,a4,0x20
 4a8:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4ac:	fff94583          	lbu	a1,-1(s2)
 4b0:	8526                	mv	a0,s1
 4b2:	00000097          	auipc	ra,0x0
 4b6:	f58080e7          	jalr	-168(ra) # 40a <putc>
  while(--i >= 0)
 4ba:	197d                	addi	s2,s2,-1
 4bc:	ff3918e3          	bne	s2,s3,4ac <printint+0x80>
}
 4c0:	70e2                	ld	ra,56(sp)
 4c2:	7442                	ld	s0,48(sp)
 4c4:	74a2                	ld	s1,40(sp)
 4c6:	7902                	ld	s2,32(sp)
 4c8:	69e2                	ld	s3,24(sp)
 4ca:	6121                	addi	sp,sp,64
 4cc:	8082                	ret
    x = -xx;
 4ce:	40b005bb          	negw	a1,a1
    neg = 1;
 4d2:	4885                	li	a7,1
    x = -xx;
 4d4:	bf8d                	j	446 <printint+0x1a>

00000000000004d6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4d6:	7119                	addi	sp,sp,-128
 4d8:	fc86                	sd	ra,120(sp)
 4da:	f8a2                	sd	s0,112(sp)
 4dc:	f4a6                	sd	s1,104(sp)
 4de:	f0ca                	sd	s2,96(sp)
 4e0:	ecce                	sd	s3,88(sp)
 4e2:	e8d2                	sd	s4,80(sp)
 4e4:	e4d6                	sd	s5,72(sp)
 4e6:	e0da                	sd	s6,64(sp)
 4e8:	fc5e                	sd	s7,56(sp)
 4ea:	f862                	sd	s8,48(sp)
 4ec:	f466                	sd	s9,40(sp)
 4ee:	f06a                	sd	s10,32(sp)
 4f0:	ec6e                	sd	s11,24(sp)
 4f2:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4f4:	0005c903          	lbu	s2,0(a1)
 4f8:	18090f63          	beqz	s2,696 <vprintf+0x1c0>
 4fc:	8aaa                	mv	s5,a0
 4fe:	8b32                	mv	s6,a2
 500:	00158493          	addi	s1,a1,1
  state = 0;
 504:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 506:	02500a13          	li	s4,37
      if(c == 'd'){
 50a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 50e:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 512:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 516:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 51a:	00000b97          	auipc	s7,0x0
 51e:	3aeb8b93          	addi	s7,s7,942 # 8c8 <digits>
 522:	a839                	j	540 <vprintf+0x6a>
        putc(fd, c);
 524:	85ca                	mv	a1,s2
 526:	8556                	mv	a0,s5
 528:	00000097          	auipc	ra,0x0
 52c:	ee2080e7          	jalr	-286(ra) # 40a <putc>
 530:	a019                	j	536 <vprintf+0x60>
    } else if(state == '%'){
 532:	01498f63          	beq	s3,s4,550 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 536:	0485                	addi	s1,s1,1
 538:	fff4c903          	lbu	s2,-1(s1)
 53c:	14090d63          	beqz	s2,696 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 540:	0009079b          	sext.w	a5,s2
    if(state == 0){
 544:	fe0997e3          	bnez	s3,532 <vprintf+0x5c>
      if(c == '%'){
 548:	fd479ee3          	bne	a5,s4,524 <vprintf+0x4e>
        state = '%';
 54c:	89be                	mv	s3,a5
 54e:	b7e5                	j	536 <vprintf+0x60>
      if(c == 'd'){
 550:	05878063          	beq	a5,s8,590 <vprintf+0xba>
      } else if(c == 'l') {
 554:	05978c63          	beq	a5,s9,5ac <vprintf+0xd6>
      } else if(c == 'x') {
 558:	07a78863          	beq	a5,s10,5c8 <vprintf+0xf2>
      } else if(c == 'p') {
 55c:	09b78463          	beq	a5,s11,5e4 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 560:	07300713          	li	a4,115
 564:	0ce78663          	beq	a5,a4,630 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 568:	06300713          	li	a4,99
 56c:	0ee78e63          	beq	a5,a4,668 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 570:	11478863          	beq	a5,s4,680 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 574:	85d2                	mv	a1,s4
 576:	8556                	mv	a0,s5
 578:	00000097          	auipc	ra,0x0
 57c:	e92080e7          	jalr	-366(ra) # 40a <putc>
        putc(fd, c);
 580:	85ca                	mv	a1,s2
 582:	8556                	mv	a0,s5
 584:	00000097          	auipc	ra,0x0
 588:	e86080e7          	jalr	-378(ra) # 40a <putc>
      }
      state = 0;
 58c:	4981                	li	s3,0
 58e:	b765                	j	536 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 590:	008b0913          	addi	s2,s6,8
 594:	4685                	li	a3,1
 596:	4629                	li	a2,10
 598:	000b2583          	lw	a1,0(s6)
 59c:	8556                	mv	a0,s5
 59e:	00000097          	auipc	ra,0x0
 5a2:	e8e080e7          	jalr	-370(ra) # 42c <printint>
 5a6:	8b4a                	mv	s6,s2
      state = 0;
 5a8:	4981                	li	s3,0
 5aa:	b771                	j	536 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ac:	008b0913          	addi	s2,s6,8
 5b0:	4681                	li	a3,0
 5b2:	4629                	li	a2,10
 5b4:	000b2583          	lw	a1,0(s6)
 5b8:	8556                	mv	a0,s5
 5ba:	00000097          	auipc	ra,0x0
 5be:	e72080e7          	jalr	-398(ra) # 42c <printint>
 5c2:	8b4a                	mv	s6,s2
      state = 0;
 5c4:	4981                	li	s3,0
 5c6:	bf85                	j	536 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5c8:	008b0913          	addi	s2,s6,8
 5cc:	4681                	li	a3,0
 5ce:	4641                	li	a2,16
 5d0:	000b2583          	lw	a1,0(s6)
 5d4:	8556                	mv	a0,s5
 5d6:	00000097          	auipc	ra,0x0
 5da:	e56080e7          	jalr	-426(ra) # 42c <printint>
 5de:	8b4a                	mv	s6,s2
      state = 0;
 5e0:	4981                	li	s3,0
 5e2:	bf91                	j	536 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5e4:	008b0793          	addi	a5,s6,8
 5e8:	f8f43423          	sd	a5,-120(s0)
 5ec:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 5f0:	03000593          	li	a1,48
 5f4:	8556                	mv	a0,s5
 5f6:	00000097          	auipc	ra,0x0
 5fa:	e14080e7          	jalr	-492(ra) # 40a <putc>
  putc(fd, 'x');
 5fe:	85ea                	mv	a1,s10
 600:	8556                	mv	a0,s5
 602:	00000097          	auipc	ra,0x0
 606:	e08080e7          	jalr	-504(ra) # 40a <putc>
 60a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 60c:	03c9d793          	srli	a5,s3,0x3c
 610:	97de                	add	a5,a5,s7
 612:	0007c583          	lbu	a1,0(a5)
 616:	8556                	mv	a0,s5
 618:	00000097          	auipc	ra,0x0
 61c:	df2080e7          	jalr	-526(ra) # 40a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 620:	0992                	slli	s3,s3,0x4
 622:	397d                	addiw	s2,s2,-1
 624:	fe0914e3          	bnez	s2,60c <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 628:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 62c:	4981                	li	s3,0
 62e:	b721                	j	536 <vprintf+0x60>
        s = va_arg(ap, char*);
 630:	008b0993          	addi	s3,s6,8
 634:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 638:	02090163          	beqz	s2,65a <vprintf+0x184>
        while(*s != 0){
 63c:	00094583          	lbu	a1,0(s2)
 640:	c9a1                	beqz	a1,690 <vprintf+0x1ba>
          putc(fd, *s);
 642:	8556                	mv	a0,s5
 644:	00000097          	auipc	ra,0x0
 648:	dc6080e7          	jalr	-570(ra) # 40a <putc>
          s++;
 64c:	0905                	addi	s2,s2,1
        while(*s != 0){
 64e:	00094583          	lbu	a1,0(s2)
 652:	f9e5                	bnez	a1,642 <vprintf+0x16c>
        s = va_arg(ap, char*);
 654:	8b4e                	mv	s6,s3
      state = 0;
 656:	4981                	li	s3,0
 658:	bdf9                	j	536 <vprintf+0x60>
          s = "(null)";
 65a:	00000917          	auipc	s2,0x0
 65e:	26690913          	addi	s2,s2,614 # 8c0 <malloc+0x120>
        while(*s != 0){
 662:	02800593          	li	a1,40
 666:	bff1                	j	642 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 668:	008b0913          	addi	s2,s6,8
 66c:	000b4583          	lbu	a1,0(s6)
 670:	8556                	mv	a0,s5
 672:	00000097          	auipc	ra,0x0
 676:	d98080e7          	jalr	-616(ra) # 40a <putc>
 67a:	8b4a                	mv	s6,s2
      state = 0;
 67c:	4981                	li	s3,0
 67e:	bd65                	j	536 <vprintf+0x60>
        putc(fd, c);
 680:	85d2                	mv	a1,s4
 682:	8556                	mv	a0,s5
 684:	00000097          	auipc	ra,0x0
 688:	d86080e7          	jalr	-634(ra) # 40a <putc>
      state = 0;
 68c:	4981                	li	s3,0
 68e:	b565                	j	536 <vprintf+0x60>
        s = va_arg(ap, char*);
 690:	8b4e                	mv	s6,s3
      state = 0;
 692:	4981                	li	s3,0
 694:	b54d                	j	536 <vprintf+0x60>
    }
  }
}
 696:	70e6                	ld	ra,120(sp)
 698:	7446                	ld	s0,112(sp)
 69a:	74a6                	ld	s1,104(sp)
 69c:	7906                	ld	s2,96(sp)
 69e:	69e6                	ld	s3,88(sp)
 6a0:	6a46                	ld	s4,80(sp)
 6a2:	6aa6                	ld	s5,72(sp)
 6a4:	6b06                	ld	s6,64(sp)
 6a6:	7be2                	ld	s7,56(sp)
 6a8:	7c42                	ld	s8,48(sp)
 6aa:	7ca2                	ld	s9,40(sp)
 6ac:	7d02                	ld	s10,32(sp)
 6ae:	6de2                	ld	s11,24(sp)
 6b0:	6109                	addi	sp,sp,128
 6b2:	8082                	ret

00000000000006b4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6b4:	715d                	addi	sp,sp,-80
 6b6:	ec06                	sd	ra,24(sp)
 6b8:	e822                	sd	s0,16(sp)
 6ba:	1000                	addi	s0,sp,32
 6bc:	e010                	sd	a2,0(s0)
 6be:	e414                	sd	a3,8(s0)
 6c0:	e818                	sd	a4,16(s0)
 6c2:	ec1c                	sd	a5,24(s0)
 6c4:	03043023          	sd	a6,32(s0)
 6c8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6cc:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6d0:	8622                	mv	a2,s0
 6d2:	00000097          	auipc	ra,0x0
 6d6:	e04080e7          	jalr	-508(ra) # 4d6 <vprintf>
}
 6da:	60e2                	ld	ra,24(sp)
 6dc:	6442                	ld	s0,16(sp)
 6de:	6161                	addi	sp,sp,80
 6e0:	8082                	ret

00000000000006e2 <printf>:

void
printf(const char *fmt, ...)
{
 6e2:	711d                	addi	sp,sp,-96
 6e4:	ec06                	sd	ra,24(sp)
 6e6:	e822                	sd	s0,16(sp)
 6e8:	1000                	addi	s0,sp,32
 6ea:	e40c                	sd	a1,8(s0)
 6ec:	e810                	sd	a2,16(s0)
 6ee:	ec14                	sd	a3,24(s0)
 6f0:	f018                	sd	a4,32(s0)
 6f2:	f41c                	sd	a5,40(s0)
 6f4:	03043823          	sd	a6,48(s0)
 6f8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6fc:	00840613          	addi	a2,s0,8
 700:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 704:	85aa                	mv	a1,a0
 706:	4505                	li	a0,1
 708:	00000097          	auipc	ra,0x0
 70c:	dce080e7          	jalr	-562(ra) # 4d6 <vprintf>
}
 710:	60e2                	ld	ra,24(sp)
 712:	6442                	ld	s0,16(sp)
 714:	6125                	addi	sp,sp,96
 716:	8082                	ret

0000000000000718 <free>:
 718:	1141                	addi	sp,sp,-16
 71a:	e422                	sd	s0,8(sp)
 71c:	0800                	addi	s0,sp,16
 71e:	ff050693          	addi	a3,a0,-16
 722:	00001797          	auipc	a5,0x1
 726:	8de7b783          	ld	a5,-1826(a5) # 1000 <freep>
 72a:	a805                	j	75a <free+0x42>
 72c:	4618                	lw	a4,8(a2)
 72e:	9db9                	addw	a1,a1,a4
 730:	feb52c23          	sw	a1,-8(a0)
 734:	6398                	ld	a4,0(a5)
 736:	6318                	ld	a4,0(a4)
 738:	fee53823          	sd	a4,-16(a0)
 73c:	a091                	j	780 <free+0x68>
 73e:	ff852703          	lw	a4,-8(a0)
 742:	9e39                	addw	a2,a2,a4
 744:	c790                	sw	a2,8(a5)
 746:	ff053703          	ld	a4,-16(a0)
 74a:	e398                	sd	a4,0(a5)
 74c:	a099                	j	792 <free+0x7a>
 74e:	6398                	ld	a4,0(a5)
 750:	00e7e463          	bltu	a5,a4,758 <free+0x40>
 754:	00e6ea63          	bltu	a3,a4,768 <free+0x50>
 758:	87ba                	mv	a5,a4
 75a:	fed7fae3          	bgeu	a5,a3,74e <free+0x36>
 75e:	6398                	ld	a4,0(a5)
 760:	00e6e463          	bltu	a3,a4,768 <free+0x50>
 764:	fee7eae3          	bltu	a5,a4,758 <free+0x40>
 768:	ff852583          	lw	a1,-8(a0)
 76c:	6390                	ld	a2,0(a5)
 76e:	02059713          	slli	a4,a1,0x20
 772:	9301                	srli	a4,a4,0x20
 774:	0712                	slli	a4,a4,0x4
 776:	9736                	add	a4,a4,a3
 778:	fae60ae3          	beq	a2,a4,72c <free+0x14>
 77c:	fec53823          	sd	a2,-16(a0)
 780:	4790                	lw	a2,8(a5)
 782:	02061713          	slli	a4,a2,0x20
 786:	9301                	srli	a4,a4,0x20
 788:	0712                	slli	a4,a4,0x4
 78a:	973e                	add	a4,a4,a5
 78c:	fae689e3          	beq	a3,a4,73e <free+0x26>
 790:	e394                	sd	a3,0(a5)
 792:	00001717          	auipc	a4,0x1
 796:	86f73723          	sd	a5,-1938(a4) # 1000 <freep>
 79a:	6422                	ld	s0,8(sp)
 79c:	0141                	addi	sp,sp,16
 79e:	8082                	ret

00000000000007a0 <malloc>:
 7a0:	7139                	addi	sp,sp,-64
 7a2:	fc06                	sd	ra,56(sp)
 7a4:	f822                	sd	s0,48(sp)
 7a6:	f426                	sd	s1,40(sp)
 7a8:	f04a                	sd	s2,32(sp)
 7aa:	ec4e                	sd	s3,24(sp)
 7ac:	e852                	sd	s4,16(sp)
 7ae:	e456                	sd	s5,8(sp)
 7b0:	e05a                	sd	s6,0(sp)
 7b2:	0080                	addi	s0,sp,64
 7b4:	02051493          	slli	s1,a0,0x20
 7b8:	9081                	srli	s1,s1,0x20
 7ba:	04bd                	addi	s1,s1,15
 7bc:	8091                	srli	s1,s1,0x4
 7be:	0014899b          	addiw	s3,s1,1
 7c2:	0485                	addi	s1,s1,1
 7c4:	00001517          	auipc	a0,0x1
 7c8:	83c53503          	ld	a0,-1988(a0) # 1000 <freep>
 7cc:	c515                	beqz	a0,7f8 <malloc+0x58>
 7ce:	611c                	ld	a5,0(a0)
 7d0:	4798                	lw	a4,8(a5)
 7d2:	02977f63          	bgeu	a4,s1,810 <malloc+0x70>
 7d6:	8a4e                	mv	s4,s3
 7d8:	0009871b          	sext.w	a4,s3
 7dc:	6685                	lui	a3,0x1
 7de:	00d77363          	bgeu	a4,a3,7e4 <malloc+0x44>
 7e2:	6a05                	lui	s4,0x1
 7e4:	000a0b1b          	sext.w	s6,s4
 7e8:	004a1a1b          	slliw	s4,s4,0x4
 7ec:	00001917          	auipc	s2,0x1
 7f0:	81490913          	addi	s2,s2,-2028 # 1000 <freep>
 7f4:	5afd                	li	s5,-1
 7f6:	a88d                	j	868 <malloc+0xc8>
 7f8:	00001797          	auipc	a5,0x1
 7fc:	81878793          	addi	a5,a5,-2024 # 1010 <base>
 800:	00001717          	auipc	a4,0x1
 804:	80f73023          	sd	a5,-2048(a4) # 1000 <freep>
 808:	e39c                	sd	a5,0(a5)
 80a:	0007a423          	sw	zero,8(a5)
 80e:	b7e1                	j	7d6 <malloc+0x36>
 810:	02e48b63          	beq	s1,a4,846 <malloc+0xa6>
 814:	4137073b          	subw	a4,a4,s3
 818:	c798                	sw	a4,8(a5)
 81a:	1702                	slli	a4,a4,0x20
 81c:	9301                	srli	a4,a4,0x20
 81e:	0712                	slli	a4,a4,0x4
 820:	97ba                	add	a5,a5,a4
 822:	0137a423          	sw	s3,8(a5)
 826:	00000717          	auipc	a4,0x0
 82a:	7ca73d23          	sd	a0,2010(a4) # 1000 <freep>
 82e:	01078513          	addi	a0,a5,16
 832:	70e2                	ld	ra,56(sp)
 834:	7442                	ld	s0,48(sp)
 836:	74a2                	ld	s1,40(sp)
 838:	7902                	ld	s2,32(sp)
 83a:	69e2                	ld	s3,24(sp)
 83c:	6a42                	ld	s4,16(sp)
 83e:	6aa2                	ld	s5,8(sp)
 840:	6b02                	ld	s6,0(sp)
 842:	6121                	addi	sp,sp,64
 844:	8082                	ret
 846:	6398                	ld	a4,0(a5)
 848:	e118                	sd	a4,0(a0)
 84a:	bff1                	j	826 <malloc+0x86>
 84c:	01652423          	sw	s6,8(a0)
 850:	0541                	addi	a0,a0,16
 852:	00000097          	auipc	ra,0x0
 856:	ec6080e7          	jalr	-314(ra) # 718 <free>
 85a:	00093503          	ld	a0,0(s2)
 85e:	d971                	beqz	a0,832 <malloc+0x92>
 860:	611c                	ld	a5,0(a0)
 862:	4798                	lw	a4,8(a5)
 864:	fa9776e3          	bgeu	a4,s1,810 <malloc+0x70>
 868:	00093703          	ld	a4,0(s2)
 86c:	853e                	mv	a0,a5
 86e:	fef719e3          	bne	a4,a5,860 <malloc+0xc0>
 872:	8552                	mv	a0,s4
 874:	00000097          	auipc	ra,0x0
 878:	b56080e7          	jalr	-1194(ra) # 3ca <sbrk>
 87c:	fd5518e3          	bne	a0,s5,84c <malloc+0xac>
 880:	4501                	li	a0,0
 882:	bf45                	j	832 <malloc+0x92>
