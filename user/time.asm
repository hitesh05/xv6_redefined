
user/_time:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	1800                	addi	s0,sp,48
   c:	892a                	mv	s2,a0
   e:	84ae                	mv	s1,a1
  10:	00000097          	auipc	ra,0x0
  14:	32e080e7          	jalr	814(ra) # 33e <fork>
  18:	02054a63          	bltz	a0,4c <main+0x4c>
  1c:	ed39                	bnez	a0,7a <main+0x7a>
  1e:	4785                	li	a5,1
  20:	04f90363          	beq	s2,a5,66 <main+0x66>
  24:	00848593          	addi	a1,s1,8
  28:	6488                	ld	a0,8(s1)
  2a:	00000097          	auipc	ra,0x0
  2e:	354080e7          	jalr	852(ra) # 37e <exec>
  32:	00001517          	auipc	a0,0x1
  36:	86e50513          	addi	a0,a0,-1938 # 8a0 <malloc+0xfc>
  3a:	00000097          	auipc	ra,0x0
  3e:	6ac080e7          	jalr	1708(ra) # 6e6 <printf>
  42:	4505                	li	a0,1
  44:	00000097          	auipc	ra,0x0
  48:	302080e7          	jalr	770(ra) # 346 <exit>
  4c:	00001517          	auipc	a0,0x1
  50:	84450513          	addi	a0,a0,-1980 # 890 <malloc+0xec>
  54:	00000097          	auipc	ra,0x0
  58:	692080e7          	jalr	1682(ra) # 6e6 <printf>
  5c:	4505                	li	a0,1
  5e:	00000097          	auipc	ra,0x0
  62:	2e8080e7          	jalr	744(ra) # 346 <exit>
  66:	4529                	li	a0,10
  68:	00000097          	auipc	ra,0x0
  6c:	36e080e7          	jalr	878(ra) # 3d6 <sleep>
  70:	4501                	li	a0,0
  72:	00000097          	auipc	ra,0x0
  76:	2d4080e7          	jalr	724(ra) # 346 <exit>
  7a:	fc042c23          	sw	zero,-40(s0)
  7e:	fc042e23          	sw	zero,-36(s0)
  82:	fd840613          	addi	a2,s0,-40
  86:	fdc40593          	addi	a1,s0,-36
  8a:	4501                	li	a0,0
  8c:	00000097          	auipc	ra,0x0
  90:	36a080e7          	jalr	874(ra) # 3f6 <waitx>
  94:	fd842603          	lw	a2,-40(s0)
  98:	fdc42583          	lw	a1,-36(s0)
  9c:	00001517          	auipc	a0,0x1
  a0:	81450513          	addi	a0,a0,-2028 # 8b0 <malloc+0x10c>
  a4:	00000097          	auipc	ra,0x0
  a8:	642080e7          	jalr	1602(ra) # 6e6 <printf>
  ac:	4501                	li	a0,0
  ae:	00000097          	auipc	ra,0x0
  b2:	298080e7          	jalr	664(ra) # 346 <exit>

00000000000000b6 <_main>:
  b6:	1141                	addi	sp,sp,-16
  b8:	e406                	sd	ra,8(sp)
  ba:	e022                	sd	s0,0(sp)
  bc:	0800                	addi	s0,sp,16
  be:	00000097          	auipc	ra,0x0
  c2:	f42080e7          	jalr	-190(ra) # 0 <main>
  c6:	4501                	li	a0,0
  c8:	00000097          	auipc	ra,0x0
  cc:	27e080e7          	jalr	638(ra) # 346 <exit>

00000000000000d0 <strcpy>:
  d0:	1141                	addi	sp,sp,-16
  d2:	e422                	sd	s0,8(sp)
  d4:	0800                	addi	s0,sp,16
  d6:	87aa                	mv	a5,a0
  d8:	0585                	addi	a1,a1,1
  da:	0785                	addi	a5,a5,1
  dc:	fff5c703          	lbu	a4,-1(a1)
  e0:	fee78fa3          	sb	a4,-1(a5)
  e4:	fb75                	bnez	a4,d8 <strcpy+0x8>
  e6:	6422                	ld	s0,8(sp)
  e8:	0141                	addi	sp,sp,16
  ea:	8082                	ret

00000000000000ec <strcmp>:
  ec:	1141                	addi	sp,sp,-16
  ee:	e422                	sd	s0,8(sp)
  f0:	0800                	addi	s0,sp,16
  f2:	00054783          	lbu	a5,0(a0)
  f6:	cb91                	beqz	a5,10a <strcmp+0x1e>
  f8:	0005c703          	lbu	a4,0(a1)
  fc:	00f71763          	bne	a4,a5,10a <strcmp+0x1e>
 100:	0505                	addi	a0,a0,1
 102:	0585                	addi	a1,a1,1
 104:	00054783          	lbu	a5,0(a0)
 108:	fbe5                	bnez	a5,f8 <strcmp+0xc>
 10a:	0005c503          	lbu	a0,0(a1)
 10e:	40a7853b          	subw	a0,a5,a0
 112:	6422                	ld	s0,8(sp)
 114:	0141                	addi	sp,sp,16
 116:	8082                	ret

0000000000000118 <strlen>:
 118:	1141                	addi	sp,sp,-16
 11a:	e422                	sd	s0,8(sp)
 11c:	0800                	addi	s0,sp,16
 11e:	00054783          	lbu	a5,0(a0)
 122:	cf91                	beqz	a5,13e <strlen+0x26>
 124:	0505                	addi	a0,a0,1
 126:	87aa                	mv	a5,a0
 128:	4685                	li	a3,1
 12a:	9e89                	subw	a3,a3,a0
 12c:	00f6853b          	addw	a0,a3,a5
 130:	0785                	addi	a5,a5,1
 132:	fff7c703          	lbu	a4,-1(a5)
 136:	fb7d                	bnez	a4,12c <strlen+0x14>
 138:	6422                	ld	s0,8(sp)
 13a:	0141                	addi	sp,sp,16
 13c:	8082                	ret
 13e:	4501                	li	a0,0
 140:	bfe5                	j	138 <strlen+0x20>

0000000000000142 <memset>:
 142:	1141                	addi	sp,sp,-16
 144:	e422                	sd	s0,8(sp)
 146:	0800                	addi	s0,sp,16
 148:	ce09                	beqz	a2,162 <memset+0x20>
 14a:	87aa                	mv	a5,a0
 14c:	fff6071b          	addiw	a4,a2,-1
 150:	1702                	slli	a4,a4,0x20
 152:	9301                	srli	a4,a4,0x20
 154:	0705                	addi	a4,a4,1
 156:	972a                	add	a4,a4,a0
 158:	00b78023          	sb	a1,0(a5)
 15c:	0785                	addi	a5,a5,1
 15e:	fee79de3          	bne	a5,a4,158 <memset+0x16>
 162:	6422                	ld	s0,8(sp)
 164:	0141                	addi	sp,sp,16
 166:	8082                	ret

0000000000000168 <strchr>:
 168:	1141                	addi	sp,sp,-16
 16a:	e422                	sd	s0,8(sp)
 16c:	0800                	addi	s0,sp,16
 16e:	00054783          	lbu	a5,0(a0)
 172:	cb99                	beqz	a5,188 <strchr+0x20>
 174:	00f58763          	beq	a1,a5,182 <strchr+0x1a>
 178:	0505                	addi	a0,a0,1
 17a:	00054783          	lbu	a5,0(a0)
 17e:	fbfd                	bnez	a5,174 <strchr+0xc>
 180:	4501                	li	a0,0
 182:	6422                	ld	s0,8(sp)
 184:	0141                	addi	sp,sp,16
 186:	8082                	ret
 188:	4501                	li	a0,0
 18a:	bfe5                	j	182 <strchr+0x1a>

000000000000018c <gets>:
 18c:	711d                	addi	sp,sp,-96
 18e:	ec86                	sd	ra,88(sp)
 190:	e8a2                	sd	s0,80(sp)
 192:	e4a6                	sd	s1,72(sp)
 194:	e0ca                	sd	s2,64(sp)
 196:	fc4e                	sd	s3,56(sp)
 198:	f852                	sd	s4,48(sp)
 19a:	f456                	sd	s5,40(sp)
 19c:	f05a                	sd	s6,32(sp)
 19e:	ec5e                	sd	s7,24(sp)
 1a0:	1080                	addi	s0,sp,96
 1a2:	8baa                	mv	s7,a0
 1a4:	8a2e                	mv	s4,a1
 1a6:	892a                	mv	s2,a0
 1a8:	4481                	li	s1,0
 1aa:	4aa9                	li	s5,10
 1ac:	4b35                	li	s6,13
 1ae:	89a6                	mv	s3,s1
 1b0:	2485                	addiw	s1,s1,1
 1b2:	0344d863          	bge	s1,s4,1e2 <gets+0x56>
 1b6:	4605                	li	a2,1
 1b8:	faf40593          	addi	a1,s0,-81
 1bc:	4501                	li	a0,0
 1be:	00000097          	auipc	ra,0x0
 1c2:	1a0080e7          	jalr	416(ra) # 35e <read>
 1c6:	00a05e63          	blez	a0,1e2 <gets+0x56>
 1ca:	faf44783          	lbu	a5,-81(s0)
 1ce:	00f90023          	sb	a5,0(s2)
 1d2:	01578763          	beq	a5,s5,1e0 <gets+0x54>
 1d6:	0905                	addi	s2,s2,1
 1d8:	fd679be3          	bne	a5,s6,1ae <gets+0x22>
 1dc:	89a6                	mv	s3,s1
 1de:	a011                	j	1e2 <gets+0x56>
 1e0:	89a6                	mv	s3,s1
 1e2:	99de                	add	s3,s3,s7
 1e4:	00098023          	sb	zero,0(s3)
 1e8:	855e                	mv	a0,s7
 1ea:	60e6                	ld	ra,88(sp)
 1ec:	6446                	ld	s0,80(sp)
 1ee:	64a6                	ld	s1,72(sp)
 1f0:	6906                	ld	s2,64(sp)
 1f2:	79e2                	ld	s3,56(sp)
 1f4:	7a42                	ld	s4,48(sp)
 1f6:	7aa2                	ld	s5,40(sp)
 1f8:	7b02                	ld	s6,32(sp)
 1fa:	6be2                	ld	s7,24(sp)
 1fc:	6125                	addi	sp,sp,96
 1fe:	8082                	ret

0000000000000200 <stat>:
 200:	1101                	addi	sp,sp,-32
 202:	ec06                	sd	ra,24(sp)
 204:	e822                	sd	s0,16(sp)
 206:	e426                	sd	s1,8(sp)
 208:	e04a                	sd	s2,0(sp)
 20a:	1000                	addi	s0,sp,32
 20c:	892e                	mv	s2,a1
 20e:	4581                	li	a1,0
 210:	00000097          	auipc	ra,0x0
 214:	176080e7          	jalr	374(ra) # 386 <open>
 218:	02054563          	bltz	a0,242 <stat+0x42>
 21c:	84aa                	mv	s1,a0
 21e:	85ca                	mv	a1,s2
 220:	00000097          	auipc	ra,0x0
 224:	17e080e7          	jalr	382(ra) # 39e <fstat>
 228:	892a                	mv	s2,a0
 22a:	8526                	mv	a0,s1
 22c:	00000097          	auipc	ra,0x0
 230:	142080e7          	jalr	322(ra) # 36e <close>
 234:	854a                	mv	a0,s2
 236:	60e2                	ld	ra,24(sp)
 238:	6442                	ld	s0,16(sp)
 23a:	64a2                	ld	s1,8(sp)
 23c:	6902                	ld	s2,0(sp)
 23e:	6105                	addi	sp,sp,32
 240:	8082                	ret
 242:	597d                	li	s2,-1
 244:	bfc5                	j	234 <stat+0x34>

0000000000000246 <atoi>:
 246:	1141                	addi	sp,sp,-16
 248:	e422                	sd	s0,8(sp)
 24a:	0800                	addi	s0,sp,16
 24c:	00054603          	lbu	a2,0(a0)
 250:	fd06079b          	addiw	a5,a2,-48
 254:	0ff7f793          	andi	a5,a5,255
 258:	4725                	li	a4,9
 25a:	02f76963          	bltu	a4,a5,28c <atoi+0x46>
 25e:	86aa                	mv	a3,a0
 260:	4501                	li	a0,0
 262:	45a5                	li	a1,9
 264:	0685                	addi	a3,a3,1
 266:	0025179b          	slliw	a5,a0,0x2
 26a:	9fa9                	addw	a5,a5,a0
 26c:	0017979b          	slliw	a5,a5,0x1
 270:	9fb1                	addw	a5,a5,a2
 272:	fd07851b          	addiw	a0,a5,-48
 276:	0006c603          	lbu	a2,0(a3)
 27a:	fd06071b          	addiw	a4,a2,-48
 27e:	0ff77713          	andi	a4,a4,255
 282:	fee5f1e3          	bgeu	a1,a4,264 <atoi+0x1e>
 286:	6422                	ld	s0,8(sp)
 288:	0141                	addi	sp,sp,16
 28a:	8082                	ret
 28c:	4501                	li	a0,0
 28e:	bfe5                	j	286 <atoi+0x40>

0000000000000290 <memmove>:
 290:	1141                	addi	sp,sp,-16
 292:	e422                	sd	s0,8(sp)
 294:	0800                	addi	s0,sp,16
 296:	02b57663          	bgeu	a0,a1,2c2 <memmove+0x32>
 29a:	02c05163          	blez	a2,2bc <memmove+0x2c>
 29e:	fff6079b          	addiw	a5,a2,-1
 2a2:	1782                	slli	a5,a5,0x20
 2a4:	9381                	srli	a5,a5,0x20
 2a6:	0785                	addi	a5,a5,1
 2a8:	97aa                	add	a5,a5,a0
 2aa:	872a                	mv	a4,a0
 2ac:	0585                	addi	a1,a1,1
 2ae:	0705                	addi	a4,a4,1
 2b0:	fff5c683          	lbu	a3,-1(a1)
 2b4:	fed70fa3          	sb	a3,-1(a4)
 2b8:	fee79ae3          	bne	a5,a4,2ac <memmove+0x1c>
 2bc:	6422                	ld	s0,8(sp)
 2be:	0141                	addi	sp,sp,16
 2c0:	8082                	ret
 2c2:	00c50733          	add	a4,a0,a2
 2c6:	95b2                	add	a1,a1,a2
 2c8:	fec05ae3          	blez	a2,2bc <memmove+0x2c>
 2cc:	fff6079b          	addiw	a5,a2,-1
 2d0:	1782                	slli	a5,a5,0x20
 2d2:	9381                	srli	a5,a5,0x20
 2d4:	fff7c793          	not	a5,a5
 2d8:	97ba                	add	a5,a5,a4
 2da:	15fd                	addi	a1,a1,-1
 2dc:	177d                	addi	a4,a4,-1
 2de:	0005c683          	lbu	a3,0(a1)
 2e2:	00d70023          	sb	a3,0(a4)
 2e6:	fee79ae3          	bne	a5,a4,2da <memmove+0x4a>
 2ea:	bfc9                	j	2bc <memmove+0x2c>

00000000000002ec <memcmp>:
 2ec:	1141                	addi	sp,sp,-16
 2ee:	e422                	sd	s0,8(sp)
 2f0:	0800                	addi	s0,sp,16
 2f2:	ca05                	beqz	a2,322 <memcmp+0x36>
 2f4:	fff6069b          	addiw	a3,a2,-1
 2f8:	1682                	slli	a3,a3,0x20
 2fa:	9281                	srli	a3,a3,0x20
 2fc:	0685                	addi	a3,a3,1
 2fe:	96aa                	add	a3,a3,a0
 300:	00054783          	lbu	a5,0(a0)
 304:	0005c703          	lbu	a4,0(a1)
 308:	00e79863          	bne	a5,a4,318 <memcmp+0x2c>
 30c:	0505                	addi	a0,a0,1
 30e:	0585                	addi	a1,a1,1
 310:	fed518e3          	bne	a0,a3,300 <memcmp+0x14>
 314:	4501                	li	a0,0
 316:	a019                	j	31c <memcmp+0x30>
 318:	40e7853b          	subw	a0,a5,a4
 31c:	6422                	ld	s0,8(sp)
 31e:	0141                	addi	sp,sp,16
 320:	8082                	ret
 322:	4501                	li	a0,0
 324:	bfe5                	j	31c <memcmp+0x30>

0000000000000326 <memcpy>:
 326:	1141                	addi	sp,sp,-16
 328:	e406                	sd	ra,8(sp)
 32a:	e022                	sd	s0,0(sp)
 32c:	0800                	addi	s0,sp,16
 32e:	00000097          	auipc	ra,0x0
 332:	f62080e7          	jalr	-158(ra) # 290 <memmove>
 336:	60a2                	ld	ra,8(sp)
 338:	6402                	ld	s0,0(sp)
 33a:	0141                	addi	sp,sp,16
 33c:	8082                	ret

000000000000033e <fork>:
 33e:	4885                	li	a7,1
 340:	00000073          	ecall
 344:	8082                	ret

0000000000000346 <exit>:
 346:	4889                	li	a7,2
 348:	00000073          	ecall
 34c:	8082                	ret

000000000000034e <wait>:
 34e:	488d                	li	a7,3
 350:	00000073          	ecall
 354:	8082                	ret

0000000000000356 <pipe>:
 356:	4891                	li	a7,4
 358:	00000073          	ecall
 35c:	8082                	ret

000000000000035e <read>:
 35e:	4895                	li	a7,5
 360:	00000073          	ecall
 364:	8082                	ret

0000000000000366 <write>:
 366:	48c1                	li	a7,16
 368:	00000073          	ecall
 36c:	8082                	ret

000000000000036e <close>:
 36e:	48d5                	li	a7,21
 370:	00000073          	ecall
 374:	8082                	ret

0000000000000376 <kill>:
 376:	4899                	li	a7,6
 378:	00000073          	ecall
 37c:	8082                	ret

000000000000037e <exec>:
 37e:	489d                	li	a7,7
 380:	00000073          	ecall
 384:	8082                	ret

0000000000000386 <open>:
 386:	48bd                	li	a7,15
 388:	00000073          	ecall
 38c:	8082                	ret

000000000000038e <mknod>:
 38e:	48c5                	li	a7,17
 390:	00000073          	ecall
 394:	8082                	ret

0000000000000396 <unlink>:
 396:	48c9                	li	a7,18
 398:	00000073          	ecall
 39c:	8082                	ret

000000000000039e <fstat>:
 39e:	48a1                	li	a7,8
 3a0:	00000073          	ecall
 3a4:	8082                	ret

00000000000003a6 <link>:
 3a6:	48cd                	li	a7,19
 3a8:	00000073          	ecall
 3ac:	8082                	ret

00000000000003ae <mkdir>:
 3ae:	48d1                	li	a7,20
 3b0:	00000073          	ecall
 3b4:	8082                	ret

00000000000003b6 <chdir>:
 3b6:	48a5                	li	a7,9
 3b8:	00000073          	ecall
 3bc:	8082                	ret

00000000000003be <dup>:
 3be:	48a9                	li	a7,10
 3c0:	00000073          	ecall
 3c4:	8082                	ret

00000000000003c6 <getpid>:
 3c6:	48ad                	li	a7,11
 3c8:	00000073          	ecall
 3cc:	8082                	ret

00000000000003ce <sbrk>:
 3ce:	48b1                	li	a7,12
 3d0:	00000073          	ecall
 3d4:	8082                	ret

00000000000003d6 <sleep>:
 3d6:	48b5                	li	a7,13
 3d8:	00000073          	ecall
 3dc:	8082                	ret

00000000000003de <uptime>:
 3de:	48b9                	li	a7,14
 3e0:	00000073          	ecall
 3e4:	8082                	ret

00000000000003e6 <trace>:
 3e6:	48d9                	li	a7,22
 3e8:	00000073          	ecall
 3ec:	8082                	ret

00000000000003ee <setpriority>:
 3ee:	48e1                	li	a7,24
 3f0:	00000073          	ecall
 3f4:	8082                	ret

00000000000003f6 <waitx>:
 3f6:	48e9                	li	a7,26
 3f8:	00000073          	ecall
 3fc:	8082                	ret

00000000000003fe <sigalarm>:
 3fe:	48dd                	li	a7,23
 400:	00000073          	ecall
 404:	8082                	ret

0000000000000406 <sigreturn>:
 406:	48ed                	li	a7,27
 408:	00000073          	ecall
 40c:	8082                	ret

000000000000040e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 40e:	1101                	addi	sp,sp,-32
 410:	ec06                	sd	ra,24(sp)
 412:	e822                	sd	s0,16(sp)
 414:	1000                	addi	s0,sp,32
 416:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 41a:	4605                	li	a2,1
 41c:	fef40593          	addi	a1,s0,-17
 420:	00000097          	auipc	ra,0x0
 424:	f46080e7          	jalr	-186(ra) # 366 <write>
}
 428:	60e2                	ld	ra,24(sp)
 42a:	6442                	ld	s0,16(sp)
 42c:	6105                	addi	sp,sp,32
 42e:	8082                	ret

0000000000000430 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 430:	7139                	addi	sp,sp,-64
 432:	fc06                	sd	ra,56(sp)
 434:	f822                	sd	s0,48(sp)
 436:	f426                	sd	s1,40(sp)
 438:	f04a                	sd	s2,32(sp)
 43a:	ec4e                	sd	s3,24(sp)
 43c:	0080                	addi	s0,sp,64
 43e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 440:	c299                	beqz	a3,446 <printint+0x16>
 442:	0805c863          	bltz	a1,4d2 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 446:	2581                	sext.w	a1,a1
  neg = 0;
 448:	4881                	li	a7,0
 44a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 44e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 450:	2601                	sext.w	a2,a2
 452:	00000517          	auipc	a0,0x0
 456:	47e50513          	addi	a0,a0,1150 # 8d0 <digits>
 45a:	883a                	mv	a6,a4
 45c:	2705                	addiw	a4,a4,1
 45e:	02c5f7bb          	remuw	a5,a1,a2
 462:	1782                	slli	a5,a5,0x20
 464:	9381                	srli	a5,a5,0x20
 466:	97aa                	add	a5,a5,a0
 468:	0007c783          	lbu	a5,0(a5)
 46c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 470:	0005879b          	sext.w	a5,a1
 474:	02c5d5bb          	divuw	a1,a1,a2
 478:	0685                	addi	a3,a3,1
 47a:	fec7f0e3          	bgeu	a5,a2,45a <printint+0x2a>
  if(neg)
 47e:	00088b63          	beqz	a7,494 <printint+0x64>
    buf[i++] = '-';
 482:	fd040793          	addi	a5,s0,-48
 486:	973e                	add	a4,a4,a5
 488:	02d00793          	li	a5,45
 48c:	fef70823          	sb	a5,-16(a4)
 490:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 494:	02e05863          	blez	a4,4c4 <printint+0x94>
 498:	fc040793          	addi	a5,s0,-64
 49c:	00e78933          	add	s2,a5,a4
 4a0:	fff78993          	addi	s3,a5,-1
 4a4:	99ba                	add	s3,s3,a4
 4a6:	377d                	addiw	a4,a4,-1
 4a8:	1702                	slli	a4,a4,0x20
 4aa:	9301                	srli	a4,a4,0x20
 4ac:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4b0:	fff94583          	lbu	a1,-1(s2)
 4b4:	8526                	mv	a0,s1
 4b6:	00000097          	auipc	ra,0x0
 4ba:	f58080e7          	jalr	-168(ra) # 40e <putc>
  while(--i >= 0)
 4be:	197d                	addi	s2,s2,-1
 4c0:	ff3918e3          	bne	s2,s3,4b0 <printint+0x80>
}
 4c4:	70e2                	ld	ra,56(sp)
 4c6:	7442                	ld	s0,48(sp)
 4c8:	74a2                	ld	s1,40(sp)
 4ca:	7902                	ld	s2,32(sp)
 4cc:	69e2                	ld	s3,24(sp)
 4ce:	6121                	addi	sp,sp,64
 4d0:	8082                	ret
    x = -xx;
 4d2:	40b005bb          	negw	a1,a1
    neg = 1;
 4d6:	4885                	li	a7,1
    x = -xx;
 4d8:	bf8d                	j	44a <printint+0x1a>

00000000000004da <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4da:	7119                	addi	sp,sp,-128
 4dc:	fc86                	sd	ra,120(sp)
 4de:	f8a2                	sd	s0,112(sp)
 4e0:	f4a6                	sd	s1,104(sp)
 4e2:	f0ca                	sd	s2,96(sp)
 4e4:	ecce                	sd	s3,88(sp)
 4e6:	e8d2                	sd	s4,80(sp)
 4e8:	e4d6                	sd	s5,72(sp)
 4ea:	e0da                	sd	s6,64(sp)
 4ec:	fc5e                	sd	s7,56(sp)
 4ee:	f862                	sd	s8,48(sp)
 4f0:	f466                	sd	s9,40(sp)
 4f2:	f06a                	sd	s10,32(sp)
 4f4:	ec6e                	sd	s11,24(sp)
 4f6:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4f8:	0005c903          	lbu	s2,0(a1)
 4fc:	18090f63          	beqz	s2,69a <vprintf+0x1c0>
 500:	8aaa                	mv	s5,a0
 502:	8b32                	mv	s6,a2
 504:	00158493          	addi	s1,a1,1
  state = 0;
 508:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 50a:	02500a13          	li	s4,37
      if(c == 'd'){
 50e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 512:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 516:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 51a:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 51e:	00000b97          	auipc	s7,0x0
 522:	3b2b8b93          	addi	s7,s7,946 # 8d0 <digits>
 526:	a839                	j	544 <vprintf+0x6a>
        putc(fd, c);
 528:	85ca                	mv	a1,s2
 52a:	8556                	mv	a0,s5
 52c:	00000097          	auipc	ra,0x0
 530:	ee2080e7          	jalr	-286(ra) # 40e <putc>
 534:	a019                	j	53a <vprintf+0x60>
    } else if(state == '%'){
 536:	01498f63          	beq	s3,s4,554 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 53a:	0485                	addi	s1,s1,1
 53c:	fff4c903          	lbu	s2,-1(s1)
 540:	14090d63          	beqz	s2,69a <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 544:	0009079b          	sext.w	a5,s2
    if(state == 0){
 548:	fe0997e3          	bnez	s3,536 <vprintf+0x5c>
      if(c == '%'){
 54c:	fd479ee3          	bne	a5,s4,528 <vprintf+0x4e>
        state = '%';
 550:	89be                	mv	s3,a5
 552:	b7e5                	j	53a <vprintf+0x60>
      if(c == 'd'){
 554:	05878063          	beq	a5,s8,594 <vprintf+0xba>
      } else if(c == 'l') {
 558:	05978c63          	beq	a5,s9,5b0 <vprintf+0xd6>
      } else if(c == 'x') {
 55c:	07a78863          	beq	a5,s10,5cc <vprintf+0xf2>
      } else if(c == 'p') {
 560:	09b78463          	beq	a5,s11,5e8 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 564:	07300713          	li	a4,115
 568:	0ce78663          	beq	a5,a4,634 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 56c:	06300713          	li	a4,99
 570:	0ee78e63          	beq	a5,a4,66c <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 574:	11478863          	beq	a5,s4,684 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 578:	85d2                	mv	a1,s4
 57a:	8556                	mv	a0,s5
 57c:	00000097          	auipc	ra,0x0
 580:	e92080e7          	jalr	-366(ra) # 40e <putc>
        putc(fd, c);
 584:	85ca                	mv	a1,s2
 586:	8556                	mv	a0,s5
 588:	00000097          	auipc	ra,0x0
 58c:	e86080e7          	jalr	-378(ra) # 40e <putc>
      }
      state = 0;
 590:	4981                	li	s3,0
 592:	b765                	j	53a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 594:	008b0913          	addi	s2,s6,8
 598:	4685                	li	a3,1
 59a:	4629                	li	a2,10
 59c:	000b2583          	lw	a1,0(s6)
 5a0:	8556                	mv	a0,s5
 5a2:	00000097          	auipc	ra,0x0
 5a6:	e8e080e7          	jalr	-370(ra) # 430 <printint>
 5aa:	8b4a                	mv	s6,s2
      state = 0;
 5ac:	4981                	li	s3,0
 5ae:	b771                	j	53a <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5b0:	008b0913          	addi	s2,s6,8
 5b4:	4681                	li	a3,0
 5b6:	4629                	li	a2,10
 5b8:	000b2583          	lw	a1,0(s6)
 5bc:	8556                	mv	a0,s5
 5be:	00000097          	auipc	ra,0x0
 5c2:	e72080e7          	jalr	-398(ra) # 430 <printint>
 5c6:	8b4a                	mv	s6,s2
      state = 0;
 5c8:	4981                	li	s3,0
 5ca:	bf85                	j	53a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5cc:	008b0913          	addi	s2,s6,8
 5d0:	4681                	li	a3,0
 5d2:	4641                	li	a2,16
 5d4:	000b2583          	lw	a1,0(s6)
 5d8:	8556                	mv	a0,s5
 5da:	00000097          	auipc	ra,0x0
 5de:	e56080e7          	jalr	-426(ra) # 430 <printint>
 5e2:	8b4a                	mv	s6,s2
      state = 0;
 5e4:	4981                	li	s3,0
 5e6:	bf91                	j	53a <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5e8:	008b0793          	addi	a5,s6,8
 5ec:	f8f43423          	sd	a5,-120(s0)
 5f0:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 5f4:	03000593          	li	a1,48
 5f8:	8556                	mv	a0,s5
 5fa:	00000097          	auipc	ra,0x0
 5fe:	e14080e7          	jalr	-492(ra) # 40e <putc>
  putc(fd, 'x');
 602:	85ea                	mv	a1,s10
 604:	8556                	mv	a0,s5
 606:	00000097          	auipc	ra,0x0
 60a:	e08080e7          	jalr	-504(ra) # 40e <putc>
 60e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 610:	03c9d793          	srli	a5,s3,0x3c
 614:	97de                	add	a5,a5,s7
 616:	0007c583          	lbu	a1,0(a5)
 61a:	8556                	mv	a0,s5
 61c:	00000097          	auipc	ra,0x0
 620:	df2080e7          	jalr	-526(ra) # 40e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 624:	0992                	slli	s3,s3,0x4
 626:	397d                	addiw	s2,s2,-1
 628:	fe0914e3          	bnez	s2,610 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 62c:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 630:	4981                	li	s3,0
 632:	b721                	j	53a <vprintf+0x60>
        s = va_arg(ap, char*);
 634:	008b0993          	addi	s3,s6,8
 638:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 63c:	02090163          	beqz	s2,65e <vprintf+0x184>
        while(*s != 0){
 640:	00094583          	lbu	a1,0(s2)
 644:	c9a1                	beqz	a1,694 <vprintf+0x1ba>
          putc(fd, *s);
 646:	8556                	mv	a0,s5
 648:	00000097          	auipc	ra,0x0
 64c:	dc6080e7          	jalr	-570(ra) # 40e <putc>
          s++;
 650:	0905                	addi	s2,s2,1
        while(*s != 0){
 652:	00094583          	lbu	a1,0(s2)
 656:	f9e5                	bnez	a1,646 <vprintf+0x16c>
        s = va_arg(ap, char*);
 658:	8b4e                	mv	s6,s3
      state = 0;
 65a:	4981                	li	s3,0
 65c:	bdf9                	j	53a <vprintf+0x60>
          s = "(null)";
 65e:	00000917          	auipc	s2,0x0
 662:	26a90913          	addi	s2,s2,618 # 8c8 <malloc+0x124>
        while(*s != 0){
 666:	02800593          	li	a1,40
 66a:	bff1                	j	646 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 66c:	008b0913          	addi	s2,s6,8
 670:	000b4583          	lbu	a1,0(s6)
 674:	8556                	mv	a0,s5
 676:	00000097          	auipc	ra,0x0
 67a:	d98080e7          	jalr	-616(ra) # 40e <putc>
 67e:	8b4a                	mv	s6,s2
      state = 0;
 680:	4981                	li	s3,0
 682:	bd65                	j	53a <vprintf+0x60>
        putc(fd, c);
 684:	85d2                	mv	a1,s4
 686:	8556                	mv	a0,s5
 688:	00000097          	auipc	ra,0x0
 68c:	d86080e7          	jalr	-634(ra) # 40e <putc>
      state = 0;
 690:	4981                	li	s3,0
 692:	b565                	j	53a <vprintf+0x60>
        s = va_arg(ap, char*);
 694:	8b4e                	mv	s6,s3
      state = 0;
 696:	4981                	li	s3,0
 698:	b54d                	j	53a <vprintf+0x60>
    }
  }
}
 69a:	70e6                	ld	ra,120(sp)
 69c:	7446                	ld	s0,112(sp)
 69e:	74a6                	ld	s1,104(sp)
 6a0:	7906                	ld	s2,96(sp)
 6a2:	69e6                	ld	s3,88(sp)
 6a4:	6a46                	ld	s4,80(sp)
 6a6:	6aa6                	ld	s5,72(sp)
 6a8:	6b06                	ld	s6,64(sp)
 6aa:	7be2                	ld	s7,56(sp)
 6ac:	7c42                	ld	s8,48(sp)
 6ae:	7ca2                	ld	s9,40(sp)
 6b0:	7d02                	ld	s10,32(sp)
 6b2:	6de2                	ld	s11,24(sp)
 6b4:	6109                	addi	sp,sp,128
 6b6:	8082                	ret

00000000000006b8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6b8:	715d                	addi	sp,sp,-80
 6ba:	ec06                	sd	ra,24(sp)
 6bc:	e822                	sd	s0,16(sp)
 6be:	1000                	addi	s0,sp,32
 6c0:	e010                	sd	a2,0(s0)
 6c2:	e414                	sd	a3,8(s0)
 6c4:	e818                	sd	a4,16(s0)
 6c6:	ec1c                	sd	a5,24(s0)
 6c8:	03043023          	sd	a6,32(s0)
 6cc:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6d0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6d4:	8622                	mv	a2,s0
 6d6:	00000097          	auipc	ra,0x0
 6da:	e04080e7          	jalr	-508(ra) # 4da <vprintf>
}
 6de:	60e2                	ld	ra,24(sp)
 6e0:	6442                	ld	s0,16(sp)
 6e2:	6161                	addi	sp,sp,80
 6e4:	8082                	ret

00000000000006e6 <printf>:

void
printf(const char *fmt, ...)
{
 6e6:	711d                	addi	sp,sp,-96
 6e8:	ec06                	sd	ra,24(sp)
 6ea:	e822                	sd	s0,16(sp)
 6ec:	1000                	addi	s0,sp,32
 6ee:	e40c                	sd	a1,8(s0)
 6f0:	e810                	sd	a2,16(s0)
 6f2:	ec14                	sd	a3,24(s0)
 6f4:	f018                	sd	a4,32(s0)
 6f6:	f41c                	sd	a5,40(s0)
 6f8:	03043823          	sd	a6,48(s0)
 6fc:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 700:	00840613          	addi	a2,s0,8
 704:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 708:	85aa                	mv	a1,a0
 70a:	4505                	li	a0,1
 70c:	00000097          	auipc	ra,0x0
 710:	dce080e7          	jalr	-562(ra) # 4da <vprintf>
}
 714:	60e2                	ld	ra,24(sp)
 716:	6442                	ld	s0,16(sp)
 718:	6125                	addi	sp,sp,96
 71a:	8082                	ret

000000000000071c <free>:
 71c:	1141                	addi	sp,sp,-16
 71e:	e422                	sd	s0,8(sp)
 720:	0800                	addi	s0,sp,16
 722:	ff050693          	addi	a3,a0,-16
 726:	00001797          	auipc	a5,0x1
 72a:	8da7b783          	ld	a5,-1830(a5) # 1000 <freep>
 72e:	a805                	j	75e <free+0x42>
 730:	4618                	lw	a4,8(a2)
 732:	9db9                	addw	a1,a1,a4
 734:	feb52c23          	sw	a1,-8(a0)
 738:	6398                	ld	a4,0(a5)
 73a:	6318                	ld	a4,0(a4)
 73c:	fee53823          	sd	a4,-16(a0)
 740:	a091                	j	784 <free+0x68>
 742:	ff852703          	lw	a4,-8(a0)
 746:	9e39                	addw	a2,a2,a4
 748:	c790                	sw	a2,8(a5)
 74a:	ff053703          	ld	a4,-16(a0)
 74e:	e398                	sd	a4,0(a5)
 750:	a099                	j	796 <free+0x7a>
 752:	6398                	ld	a4,0(a5)
 754:	00e7e463          	bltu	a5,a4,75c <free+0x40>
 758:	00e6ea63          	bltu	a3,a4,76c <free+0x50>
 75c:	87ba                	mv	a5,a4
 75e:	fed7fae3          	bgeu	a5,a3,752 <free+0x36>
 762:	6398                	ld	a4,0(a5)
 764:	00e6e463          	bltu	a3,a4,76c <free+0x50>
 768:	fee7eae3          	bltu	a5,a4,75c <free+0x40>
 76c:	ff852583          	lw	a1,-8(a0)
 770:	6390                	ld	a2,0(a5)
 772:	02059713          	slli	a4,a1,0x20
 776:	9301                	srli	a4,a4,0x20
 778:	0712                	slli	a4,a4,0x4
 77a:	9736                	add	a4,a4,a3
 77c:	fae60ae3          	beq	a2,a4,730 <free+0x14>
 780:	fec53823          	sd	a2,-16(a0)
 784:	4790                	lw	a2,8(a5)
 786:	02061713          	slli	a4,a2,0x20
 78a:	9301                	srli	a4,a4,0x20
 78c:	0712                	slli	a4,a4,0x4
 78e:	973e                	add	a4,a4,a5
 790:	fae689e3          	beq	a3,a4,742 <free+0x26>
 794:	e394                	sd	a3,0(a5)
 796:	00001717          	auipc	a4,0x1
 79a:	86f73523          	sd	a5,-1942(a4) # 1000 <freep>
 79e:	6422                	ld	s0,8(sp)
 7a0:	0141                	addi	sp,sp,16
 7a2:	8082                	ret

00000000000007a4 <malloc>:
 7a4:	7139                	addi	sp,sp,-64
 7a6:	fc06                	sd	ra,56(sp)
 7a8:	f822                	sd	s0,48(sp)
 7aa:	f426                	sd	s1,40(sp)
 7ac:	f04a                	sd	s2,32(sp)
 7ae:	ec4e                	sd	s3,24(sp)
 7b0:	e852                	sd	s4,16(sp)
 7b2:	e456                	sd	s5,8(sp)
 7b4:	e05a                	sd	s6,0(sp)
 7b6:	0080                	addi	s0,sp,64
 7b8:	02051493          	slli	s1,a0,0x20
 7bc:	9081                	srli	s1,s1,0x20
 7be:	04bd                	addi	s1,s1,15
 7c0:	8091                	srli	s1,s1,0x4
 7c2:	0014899b          	addiw	s3,s1,1
 7c6:	0485                	addi	s1,s1,1
 7c8:	00001517          	auipc	a0,0x1
 7cc:	83853503          	ld	a0,-1992(a0) # 1000 <freep>
 7d0:	c515                	beqz	a0,7fc <malloc+0x58>
 7d2:	611c                	ld	a5,0(a0)
 7d4:	4798                	lw	a4,8(a5)
 7d6:	02977f63          	bgeu	a4,s1,814 <malloc+0x70>
 7da:	8a4e                	mv	s4,s3
 7dc:	0009871b          	sext.w	a4,s3
 7e0:	6685                	lui	a3,0x1
 7e2:	00d77363          	bgeu	a4,a3,7e8 <malloc+0x44>
 7e6:	6a05                	lui	s4,0x1
 7e8:	000a0b1b          	sext.w	s6,s4
 7ec:	004a1a1b          	slliw	s4,s4,0x4
 7f0:	00001917          	auipc	s2,0x1
 7f4:	81090913          	addi	s2,s2,-2032 # 1000 <freep>
 7f8:	5afd                	li	s5,-1
 7fa:	a88d                	j	86c <malloc+0xc8>
 7fc:	00001797          	auipc	a5,0x1
 800:	81478793          	addi	a5,a5,-2028 # 1010 <base>
 804:	00000717          	auipc	a4,0x0
 808:	7ef73e23          	sd	a5,2044(a4) # 1000 <freep>
 80c:	e39c                	sd	a5,0(a5)
 80e:	0007a423          	sw	zero,8(a5)
 812:	b7e1                	j	7da <malloc+0x36>
 814:	02e48b63          	beq	s1,a4,84a <malloc+0xa6>
 818:	4137073b          	subw	a4,a4,s3
 81c:	c798                	sw	a4,8(a5)
 81e:	1702                	slli	a4,a4,0x20
 820:	9301                	srli	a4,a4,0x20
 822:	0712                	slli	a4,a4,0x4
 824:	97ba                	add	a5,a5,a4
 826:	0137a423          	sw	s3,8(a5)
 82a:	00000717          	auipc	a4,0x0
 82e:	7ca73b23          	sd	a0,2006(a4) # 1000 <freep>
 832:	01078513          	addi	a0,a5,16
 836:	70e2                	ld	ra,56(sp)
 838:	7442                	ld	s0,48(sp)
 83a:	74a2                	ld	s1,40(sp)
 83c:	7902                	ld	s2,32(sp)
 83e:	69e2                	ld	s3,24(sp)
 840:	6a42                	ld	s4,16(sp)
 842:	6aa2                	ld	s5,8(sp)
 844:	6b02                	ld	s6,0(sp)
 846:	6121                	addi	sp,sp,64
 848:	8082                	ret
 84a:	6398                	ld	a4,0(a5)
 84c:	e118                	sd	a4,0(a0)
 84e:	bff1                	j	82a <malloc+0x86>
 850:	01652423          	sw	s6,8(a0)
 854:	0541                	addi	a0,a0,16
 856:	00000097          	auipc	ra,0x0
 85a:	ec6080e7          	jalr	-314(ra) # 71c <free>
 85e:	00093503          	ld	a0,0(s2)
 862:	d971                	beqz	a0,836 <malloc+0x92>
 864:	611c                	ld	a5,0(a0)
 866:	4798                	lw	a4,8(a5)
 868:	fa9776e3          	bgeu	a4,s1,814 <malloc+0x70>
 86c:	00093703          	ld	a4,0(s2)
 870:	853e                	mv	a0,a5
 872:	fef719e3          	bne	a4,a5,864 <malloc+0xc0>
 876:	8552                	mv	a0,s4
 878:	00000097          	auipc	ra,0x0
 87c:	b56080e7          	jalr	-1194(ra) # 3ce <sbrk>
 880:	fd5518e3          	bne	a0,s5,850 <malloc+0xac>
 884:	4501                	li	a0,0
 886:	bf45                	j	836 <malloc+0x92>
