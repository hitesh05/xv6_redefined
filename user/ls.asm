
user/_ls:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <fmtname>:
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	84aa                	mv	s1,a0
  10:	00000097          	auipc	ra,0x0
  14:	32a080e7          	jalr	810(ra) # 33a <strlen>
  18:	02051793          	slli	a5,a0,0x20
  1c:	9381                	srli	a5,a5,0x20
  1e:	97a6                	add	a5,a5,s1
  20:	02f00693          	li	a3,47
  24:	0097e963          	bltu	a5,s1,36 <fmtname+0x36>
  28:	0007c703          	lbu	a4,0(a5)
  2c:	00d70563          	beq	a4,a3,36 <fmtname+0x36>
  30:	17fd                	addi	a5,a5,-1
  32:	fe97fbe3          	bgeu	a5,s1,28 <fmtname+0x28>
  36:	00178493          	addi	s1,a5,1
  3a:	8526                	mv	a0,s1
  3c:	00000097          	auipc	ra,0x0
  40:	2fe080e7          	jalr	766(ra) # 33a <strlen>
  44:	2501                	sext.w	a0,a0
  46:	47b5                	li	a5,13
  48:	00a7fa63          	bgeu	a5,a0,5c <fmtname+0x5c>
  4c:	8526                	mv	a0,s1
  4e:	70a2                	ld	ra,40(sp)
  50:	7402                	ld	s0,32(sp)
  52:	64e2                	ld	s1,24(sp)
  54:	6942                	ld	s2,16(sp)
  56:	69a2                	ld	s3,8(sp)
  58:	6145                	addi	sp,sp,48
  5a:	8082                	ret
  5c:	8526                	mv	a0,s1
  5e:	00000097          	auipc	ra,0x0
  62:	2dc080e7          	jalr	732(ra) # 33a <strlen>
  66:	00001997          	auipc	s3,0x1
  6a:	faa98993          	addi	s3,s3,-86 # 1010 <buf.1111>
  6e:	0005061b          	sext.w	a2,a0
  72:	85a6                	mv	a1,s1
  74:	854e                	mv	a0,s3
  76:	00000097          	auipc	ra,0x0
  7a:	43c080e7          	jalr	1084(ra) # 4b2 <memmove>
  7e:	8526                	mv	a0,s1
  80:	00000097          	auipc	ra,0x0
  84:	2ba080e7          	jalr	698(ra) # 33a <strlen>
  88:	0005091b          	sext.w	s2,a0
  8c:	8526                	mv	a0,s1
  8e:	00000097          	auipc	ra,0x0
  92:	2ac080e7          	jalr	684(ra) # 33a <strlen>
  96:	1902                	slli	s2,s2,0x20
  98:	02095913          	srli	s2,s2,0x20
  9c:	4639                	li	a2,14
  9e:	9e09                	subw	a2,a2,a0
  a0:	02000593          	li	a1,32
  a4:	01298533          	add	a0,s3,s2
  a8:	00000097          	auipc	ra,0x0
  ac:	2bc080e7          	jalr	700(ra) # 364 <memset>
  b0:	84ce                	mv	s1,s3
  b2:	bf69                	j	4c <fmtname+0x4c>

00000000000000b4 <ls>:
  b4:	d9010113          	addi	sp,sp,-624
  b8:	26113423          	sd	ra,616(sp)
  bc:	26813023          	sd	s0,608(sp)
  c0:	24913c23          	sd	s1,600(sp)
  c4:	25213823          	sd	s2,592(sp)
  c8:	25313423          	sd	s3,584(sp)
  cc:	25413023          	sd	s4,576(sp)
  d0:	23513c23          	sd	s5,568(sp)
  d4:	1c80                	addi	s0,sp,624
  d6:	892a                	mv	s2,a0
  d8:	4581                	li	a1,0
  da:	00000097          	auipc	ra,0x0
  de:	4ce080e7          	jalr	1230(ra) # 5a8 <open>
  e2:	08054163          	bltz	a0,164 <ls+0xb0>
  e6:	84aa                	mv	s1,a0
  e8:	d9840593          	addi	a1,s0,-616
  ec:	00000097          	auipc	ra,0x0
  f0:	4d4080e7          	jalr	1236(ra) # 5c0 <fstat>
  f4:	08054363          	bltz	a0,17a <ls+0xc6>
  f8:	da041783          	lh	a5,-608(s0)
  fc:	0007869b          	sext.w	a3,a5
 100:	4705                	li	a4,1
 102:	08e68c63          	beq	a3,a4,19a <ls+0xe6>
 106:	37f9                	addiw	a5,a5,-2
 108:	17c2                	slli	a5,a5,0x30
 10a:	93c1                	srli	a5,a5,0x30
 10c:	02f76663          	bltu	a4,a5,138 <ls+0x84>
 110:	854a                	mv	a0,s2
 112:	00000097          	auipc	ra,0x0
 116:	eee080e7          	jalr	-274(ra) # 0 <fmtname>
 11a:	85aa                	mv	a1,a0
 11c:	da843703          	ld	a4,-600(s0)
 120:	d9c42683          	lw	a3,-612(s0)
 124:	da041603          	lh	a2,-608(s0)
 128:	00001517          	auipc	a0,0x1
 12c:	99850513          	addi	a0,a0,-1640 # ac0 <malloc+0x11a>
 130:	00000097          	auipc	ra,0x0
 134:	7b8080e7          	jalr	1976(ra) # 8e8 <printf>
 138:	8526                	mv	a0,s1
 13a:	00000097          	auipc	ra,0x0
 13e:	456080e7          	jalr	1110(ra) # 590 <close>
 142:	26813083          	ld	ra,616(sp)
 146:	26013403          	ld	s0,608(sp)
 14a:	25813483          	ld	s1,600(sp)
 14e:	25013903          	ld	s2,592(sp)
 152:	24813983          	ld	s3,584(sp)
 156:	24013a03          	ld	s4,576(sp)
 15a:	23813a83          	ld	s5,568(sp)
 15e:	27010113          	addi	sp,sp,624
 162:	8082                	ret
 164:	864a                	mv	a2,s2
 166:	00001597          	auipc	a1,0x1
 16a:	92a58593          	addi	a1,a1,-1750 # a90 <malloc+0xea>
 16e:	4509                	li	a0,2
 170:	00000097          	auipc	ra,0x0
 174:	74a080e7          	jalr	1866(ra) # 8ba <fprintf>
 178:	b7e9                	j	142 <ls+0x8e>
 17a:	864a                	mv	a2,s2
 17c:	00001597          	auipc	a1,0x1
 180:	92c58593          	addi	a1,a1,-1748 # aa8 <malloc+0x102>
 184:	4509                	li	a0,2
 186:	00000097          	auipc	ra,0x0
 18a:	734080e7          	jalr	1844(ra) # 8ba <fprintf>
 18e:	8526                	mv	a0,s1
 190:	00000097          	auipc	ra,0x0
 194:	400080e7          	jalr	1024(ra) # 590 <close>
 198:	b76d                	j	142 <ls+0x8e>
 19a:	854a                	mv	a0,s2
 19c:	00000097          	auipc	ra,0x0
 1a0:	19e080e7          	jalr	414(ra) # 33a <strlen>
 1a4:	2541                	addiw	a0,a0,16
 1a6:	20000793          	li	a5,512
 1aa:	00a7fb63          	bgeu	a5,a0,1c0 <ls+0x10c>
 1ae:	00001517          	auipc	a0,0x1
 1b2:	92250513          	addi	a0,a0,-1758 # ad0 <malloc+0x12a>
 1b6:	00000097          	auipc	ra,0x0
 1ba:	732080e7          	jalr	1842(ra) # 8e8 <printf>
 1be:	bfad                	j	138 <ls+0x84>
 1c0:	85ca                	mv	a1,s2
 1c2:	dc040513          	addi	a0,s0,-576
 1c6:	00000097          	auipc	ra,0x0
 1ca:	12c080e7          	jalr	300(ra) # 2f2 <strcpy>
 1ce:	dc040513          	addi	a0,s0,-576
 1d2:	00000097          	auipc	ra,0x0
 1d6:	168080e7          	jalr	360(ra) # 33a <strlen>
 1da:	02051913          	slli	s2,a0,0x20
 1de:	02095913          	srli	s2,s2,0x20
 1e2:	dc040793          	addi	a5,s0,-576
 1e6:	993e                	add	s2,s2,a5
 1e8:	00190993          	addi	s3,s2,1
 1ec:	02f00793          	li	a5,47
 1f0:	00f90023          	sb	a5,0(s2)
 1f4:	00001a17          	auipc	s4,0x1
 1f8:	8f4a0a13          	addi	s4,s4,-1804 # ae8 <malloc+0x142>
 1fc:	00001a97          	auipc	s5,0x1
 200:	8aca8a93          	addi	s5,s5,-1876 # aa8 <malloc+0x102>
 204:	a801                	j	214 <ls+0x160>
 206:	dc040593          	addi	a1,s0,-576
 20a:	8556                	mv	a0,s5
 20c:	00000097          	auipc	ra,0x0
 210:	6dc080e7          	jalr	1756(ra) # 8e8 <printf>
 214:	4641                	li	a2,16
 216:	db040593          	addi	a1,s0,-592
 21a:	8526                	mv	a0,s1
 21c:	00000097          	auipc	ra,0x0
 220:	364080e7          	jalr	868(ra) # 580 <read>
 224:	47c1                	li	a5,16
 226:	f0f519e3          	bne	a0,a5,138 <ls+0x84>
 22a:	db045783          	lhu	a5,-592(s0)
 22e:	d3fd                	beqz	a5,214 <ls+0x160>
 230:	4639                	li	a2,14
 232:	db240593          	addi	a1,s0,-590
 236:	854e                	mv	a0,s3
 238:	00000097          	auipc	ra,0x0
 23c:	27a080e7          	jalr	634(ra) # 4b2 <memmove>
 240:	000907a3          	sb	zero,15(s2)
 244:	d9840593          	addi	a1,s0,-616
 248:	dc040513          	addi	a0,s0,-576
 24c:	00000097          	auipc	ra,0x0
 250:	1d6080e7          	jalr	470(ra) # 422 <stat>
 254:	fa0549e3          	bltz	a0,206 <ls+0x152>
 258:	dc040513          	addi	a0,s0,-576
 25c:	00000097          	auipc	ra,0x0
 260:	da4080e7          	jalr	-604(ra) # 0 <fmtname>
 264:	85aa                	mv	a1,a0
 266:	da843703          	ld	a4,-600(s0)
 26a:	d9c42683          	lw	a3,-612(s0)
 26e:	da041603          	lh	a2,-608(s0)
 272:	8552                	mv	a0,s4
 274:	00000097          	auipc	ra,0x0
 278:	674080e7          	jalr	1652(ra) # 8e8 <printf>
 27c:	bf61                	j	214 <ls+0x160>

000000000000027e <main>:
 27e:	1101                	addi	sp,sp,-32
 280:	ec06                	sd	ra,24(sp)
 282:	e822                	sd	s0,16(sp)
 284:	e426                	sd	s1,8(sp)
 286:	e04a                	sd	s2,0(sp)
 288:	1000                	addi	s0,sp,32
 28a:	4785                	li	a5,1
 28c:	02a7d963          	bge	a5,a0,2be <main+0x40>
 290:	00858493          	addi	s1,a1,8
 294:	ffe5091b          	addiw	s2,a0,-2
 298:	1902                	slli	s2,s2,0x20
 29a:	02095913          	srli	s2,s2,0x20
 29e:	090e                	slli	s2,s2,0x3
 2a0:	05c1                	addi	a1,a1,16
 2a2:	992e                	add	s2,s2,a1
 2a4:	6088                	ld	a0,0(s1)
 2a6:	00000097          	auipc	ra,0x0
 2aa:	e0e080e7          	jalr	-498(ra) # b4 <ls>
 2ae:	04a1                	addi	s1,s1,8
 2b0:	ff249ae3          	bne	s1,s2,2a4 <main+0x26>
 2b4:	4501                	li	a0,0
 2b6:	00000097          	auipc	ra,0x0
 2ba:	2b2080e7          	jalr	690(ra) # 568 <exit>
 2be:	00001517          	auipc	a0,0x1
 2c2:	83a50513          	addi	a0,a0,-1990 # af8 <malloc+0x152>
 2c6:	00000097          	auipc	ra,0x0
 2ca:	dee080e7          	jalr	-530(ra) # b4 <ls>
 2ce:	4501                	li	a0,0
 2d0:	00000097          	auipc	ra,0x0
 2d4:	298080e7          	jalr	664(ra) # 568 <exit>

00000000000002d8 <_main>:
 2d8:	1141                	addi	sp,sp,-16
 2da:	e406                	sd	ra,8(sp)
 2dc:	e022                	sd	s0,0(sp)
 2de:	0800                	addi	s0,sp,16
 2e0:	00000097          	auipc	ra,0x0
 2e4:	f9e080e7          	jalr	-98(ra) # 27e <main>
 2e8:	4501                	li	a0,0
 2ea:	00000097          	auipc	ra,0x0
 2ee:	27e080e7          	jalr	638(ra) # 568 <exit>

00000000000002f2 <strcpy>:
 2f2:	1141                	addi	sp,sp,-16
 2f4:	e422                	sd	s0,8(sp)
 2f6:	0800                	addi	s0,sp,16
 2f8:	87aa                	mv	a5,a0
 2fa:	0585                	addi	a1,a1,1
 2fc:	0785                	addi	a5,a5,1
 2fe:	fff5c703          	lbu	a4,-1(a1)
 302:	fee78fa3          	sb	a4,-1(a5)
 306:	fb75                	bnez	a4,2fa <strcpy+0x8>
 308:	6422                	ld	s0,8(sp)
 30a:	0141                	addi	sp,sp,16
 30c:	8082                	ret

000000000000030e <strcmp>:
 30e:	1141                	addi	sp,sp,-16
 310:	e422                	sd	s0,8(sp)
 312:	0800                	addi	s0,sp,16
 314:	00054783          	lbu	a5,0(a0)
 318:	cb91                	beqz	a5,32c <strcmp+0x1e>
 31a:	0005c703          	lbu	a4,0(a1)
 31e:	00f71763          	bne	a4,a5,32c <strcmp+0x1e>
 322:	0505                	addi	a0,a0,1
 324:	0585                	addi	a1,a1,1
 326:	00054783          	lbu	a5,0(a0)
 32a:	fbe5                	bnez	a5,31a <strcmp+0xc>
 32c:	0005c503          	lbu	a0,0(a1)
 330:	40a7853b          	subw	a0,a5,a0
 334:	6422                	ld	s0,8(sp)
 336:	0141                	addi	sp,sp,16
 338:	8082                	ret

000000000000033a <strlen>:
 33a:	1141                	addi	sp,sp,-16
 33c:	e422                	sd	s0,8(sp)
 33e:	0800                	addi	s0,sp,16
 340:	00054783          	lbu	a5,0(a0)
 344:	cf91                	beqz	a5,360 <strlen+0x26>
 346:	0505                	addi	a0,a0,1
 348:	87aa                	mv	a5,a0
 34a:	4685                	li	a3,1
 34c:	9e89                	subw	a3,a3,a0
 34e:	00f6853b          	addw	a0,a3,a5
 352:	0785                	addi	a5,a5,1
 354:	fff7c703          	lbu	a4,-1(a5)
 358:	fb7d                	bnez	a4,34e <strlen+0x14>
 35a:	6422                	ld	s0,8(sp)
 35c:	0141                	addi	sp,sp,16
 35e:	8082                	ret
 360:	4501                	li	a0,0
 362:	bfe5                	j	35a <strlen+0x20>

0000000000000364 <memset>:
 364:	1141                	addi	sp,sp,-16
 366:	e422                	sd	s0,8(sp)
 368:	0800                	addi	s0,sp,16
 36a:	ce09                	beqz	a2,384 <memset+0x20>
 36c:	87aa                	mv	a5,a0
 36e:	fff6071b          	addiw	a4,a2,-1
 372:	1702                	slli	a4,a4,0x20
 374:	9301                	srli	a4,a4,0x20
 376:	0705                	addi	a4,a4,1
 378:	972a                	add	a4,a4,a0
 37a:	00b78023          	sb	a1,0(a5)
 37e:	0785                	addi	a5,a5,1
 380:	fee79de3          	bne	a5,a4,37a <memset+0x16>
 384:	6422                	ld	s0,8(sp)
 386:	0141                	addi	sp,sp,16
 388:	8082                	ret

000000000000038a <strchr>:
 38a:	1141                	addi	sp,sp,-16
 38c:	e422                	sd	s0,8(sp)
 38e:	0800                	addi	s0,sp,16
 390:	00054783          	lbu	a5,0(a0)
 394:	cb99                	beqz	a5,3aa <strchr+0x20>
 396:	00f58763          	beq	a1,a5,3a4 <strchr+0x1a>
 39a:	0505                	addi	a0,a0,1
 39c:	00054783          	lbu	a5,0(a0)
 3a0:	fbfd                	bnez	a5,396 <strchr+0xc>
 3a2:	4501                	li	a0,0
 3a4:	6422                	ld	s0,8(sp)
 3a6:	0141                	addi	sp,sp,16
 3a8:	8082                	ret
 3aa:	4501                	li	a0,0
 3ac:	bfe5                	j	3a4 <strchr+0x1a>

00000000000003ae <gets>:
 3ae:	711d                	addi	sp,sp,-96
 3b0:	ec86                	sd	ra,88(sp)
 3b2:	e8a2                	sd	s0,80(sp)
 3b4:	e4a6                	sd	s1,72(sp)
 3b6:	e0ca                	sd	s2,64(sp)
 3b8:	fc4e                	sd	s3,56(sp)
 3ba:	f852                	sd	s4,48(sp)
 3bc:	f456                	sd	s5,40(sp)
 3be:	f05a                	sd	s6,32(sp)
 3c0:	ec5e                	sd	s7,24(sp)
 3c2:	1080                	addi	s0,sp,96
 3c4:	8baa                	mv	s7,a0
 3c6:	8a2e                	mv	s4,a1
 3c8:	892a                	mv	s2,a0
 3ca:	4481                	li	s1,0
 3cc:	4aa9                	li	s5,10
 3ce:	4b35                	li	s6,13
 3d0:	89a6                	mv	s3,s1
 3d2:	2485                	addiw	s1,s1,1
 3d4:	0344d863          	bge	s1,s4,404 <gets+0x56>
 3d8:	4605                	li	a2,1
 3da:	faf40593          	addi	a1,s0,-81
 3de:	4501                	li	a0,0
 3e0:	00000097          	auipc	ra,0x0
 3e4:	1a0080e7          	jalr	416(ra) # 580 <read>
 3e8:	00a05e63          	blez	a0,404 <gets+0x56>
 3ec:	faf44783          	lbu	a5,-81(s0)
 3f0:	00f90023          	sb	a5,0(s2)
 3f4:	01578763          	beq	a5,s5,402 <gets+0x54>
 3f8:	0905                	addi	s2,s2,1
 3fa:	fd679be3          	bne	a5,s6,3d0 <gets+0x22>
 3fe:	89a6                	mv	s3,s1
 400:	a011                	j	404 <gets+0x56>
 402:	89a6                	mv	s3,s1
 404:	99de                	add	s3,s3,s7
 406:	00098023          	sb	zero,0(s3)
 40a:	855e                	mv	a0,s7
 40c:	60e6                	ld	ra,88(sp)
 40e:	6446                	ld	s0,80(sp)
 410:	64a6                	ld	s1,72(sp)
 412:	6906                	ld	s2,64(sp)
 414:	79e2                	ld	s3,56(sp)
 416:	7a42                	ld	s4,48(sp)
 418:	7aa2                	ld	s5,40(sp)
 41a:	7b02                	ld	s6,32(sp)
 41c:	6be2                	ld	s7,24(sp)
 41e:	6125                	addi	sp,sp,96
 420:	8082                	ret

0000000000000422 <stat>:
 422:	1101                	addi	sp,sp,-32
 424:	ec06                	sd	ra,24(sp)
 426:	e822                	sd	s0,16(sp)
 428:	e426                	sd	s1,8(sp)
 42a:	e04a                	sd	s2,0(sp)
 42c:	1000                	addi	s0,sp,32
 42e:	892e                	mv	s2,a1
 430:	4581                	li	a1,0
 432:	00000097          	auipc	ra,0x0
 436:	176080e7          	jalr	374(ra) # 5a8 <open>
 43a:	02054563          	bltz	a0,464 <stat+0x42>
 43e:	84aa                	mv	s1,a0
 440:	85ca                	mv	a1,s2
 442:	00000097          	auipc	ra,0x0
 446:	17e080e7          	jalr	382(ra) # 5c0 <fstat>
 44a:	892a                	mv	s2,a0
 44c:	8526                	mv	a0,s1
 44e:	00000097          	auipc	ra,0x0
 452:	142080e7          	jalr	322(ra) # 590 <close>
 456:	854a                	mv	a0,s2
 458:	60e2                	ld	ra,24(sp)
 45a:	6442                	ld	s0,16(sp)
 45c:	64a2                	ld	s1,8(sp)
 45e:	6902                	ld	s2,0(sp)
 460:	6105                	addi	sp,sp,32
 462:	8082                	ret
 464:	597d                	li	s2,-1
 466:	bfc5                	j	456 <stat+0x34>

0000000000000468 <atoi>:
 468:	1141                	addi	sp,sp,-16
 46a:	e422                	sd	s0,8(sp)
 46c:	0800                	addi	s0,sp,16
 46e:	00054603          	lbu	a2,0(a0)
 472:	fd06079b          	addiw	a5,a2,-48
 476:	0ff7f793          	andi	a5,a5,255
 47a:	4725                	li	a4,9
 47c:	02f76963          	bltu	a4,a5,4ae <atoi+0x46>
 480:	86aa                	mv	a3,a0
 482:	4501                	li	a0,0
 484:	45a5                	li	a1,9
 486:	0685                	addi	a3,a3,1
 488:	0025179b          	slliw	a5,a0,0x2
 48c:	9fa9                	addw	a5,a5,a0
 48e:	0017979b          	slliw	a5,a5,0x1
 492:	9fb1                	addw	a5,a5,a2
 494:	fd07851b          	addiw	a0,a5,-48
 498:	0006c603          	lbu	a2,0(a3)
 49c:	fd06071b          	addiw	a4,a2,-48
 4a0:	0ff77713          	andi	a4,a4,255
 4a4:	fee5f1e3          	bgeu	a1,a4,486 <atoi+0x1e>
 4a8:	6422                	ld	s0,8(sp)
 4aa:	0141                	addi	sp,sp,16
 4ac:	8082                	ret
 4ae:	4501                	li	a0,0
 4b0:	bfe5                	j	4a8 <atoi+0x40>

00000000000004b2 <memmove>:
 4b2:	1141                	addi	sp,sp,-16
 4b4:	e422                	sd	s0,8(sp)
 4b6:	0800                	addi	s0,sp,16
 4b8:	02b57663          	bgeu	a0,a1,4e4 <memmove+0x32>
 4bc:	02c05163          	blez	a2,4de <memmove+0x2c>
 4c0:	fff6079b          	addiw	a5,a2,-1
 4c4:	1782                	slli	a5,a5,0x20
 4c6:	9381                	srli	a5,a5,0x20
 4c8:	0785                	addi	a5,a5,1
 4ca:	97aa                	add	a5,a5,a0
 4cc:	872a                	mv	a4,a0
 4ce:	0585                	addi	a1,a1,1
 4d0:	0705                	addi	a4,a4,1
 4d2:	fff5c683          	lbu	a3,-1(a1)
 4d6:	fed70fa3          	sb	a3,-1(a4)
 4da:	fee79ae3          	bne	a5,a4,4ce <memmove+0x1c>
 4de:	6422                	ld	s0,8(sp)
 4e0:	0141                	addi	sp,sp,16
 4e2:	8082                	ret
 4e4:	00c50733          	add	a4,a0,a2
 4e8:	95b2                	add	a1,a1,a2
 4ea:	fec05ae3          	blez	a2,4de <memmove+0x2c>
 4ee:	fff6079b          	addiw	a5,a2,-1
 4f2:	1782                	slli	a5,a5,0x20
 4f4:	9381                	srli	a5,a5,0x20
 4f6:	fff7c793          	not	a5,a5
 4fa:	97ba                	add	a5,a5,a4
 4fc:	15fd                	addi	a1,a1,-1
 4fe:	177d                	addi	a4,a4,-1
 500:	0005c683          	lbu	a3,0(a1)
 504:	00d70023          	sb	a3,0(a4)
 508:	fee79ae3          	bne	a5,a4,4fc <memmove+0x4a>
 50c:	bfc9                	j	4de <memmove+0x2c>

000000000000050e <memcmp>:
 50e:	1141                	addi	sp,sp,-16
 510:	e422                	sd	s0,8(sp)
 512:	0800                	addi	s0,sp,16
 514:	ca05                	beqz	a2,544 <memcmp+0x36>
 516:	fff6069b          	addiw	a3,a2,-1
 51a:	1682                	slli	a3,a3,0x20
 51c:	9281                	srli	a3,a3,0x20
 51e:	0685                	addi	a3,a3,1
 520:	96aa                	add	a3,a3,a0
 522:	00054783          	lbu	a5,0(a0)
 526:	0005c703          	lbu	a4,0(a1)
 52a:	00e79863          	bne	a5,a4,53a <memcmp+0x2c>
 52e:	0505                	addi	a0,a0,1
 530:	0585                	addi	a1,a1,1
 532:	fed518e3          	bne	a0,a3,522 <memcmp+0x14>
 536:	4501                	li	a0,0
 538:	a019                	j	53e <memcmp+0x30>
 53a:	40e7853b          	subw	a0,a5,a4
 53e:	6422                	ld	s0,8(sp)
 540:	0141                	addi	sp,sp,16
 542:	8082                	ret
 544:	4501                	li	a0,0
 546:	bfe5                	j	53e <memcmp+0x30>

0000000000000548 <memcpy>:
 548:	1141                	addi	sp,sp,-16
 54a:	e406                	sd	ra,8(sp)
 54c:	e022                	sd	s0,0(sp)
 54e:	0800                	addi	s0,sp,16
 550:	00000097          	auipc	ra,0x0
 554:	f62080e7          	jalr	-158(ra) # 4b2 <memmove>
 558:	60a2                	ld	ra,8(sp)
 55a:	6402                	ld	s0,0(sp)
 55c:	0141                	addi	sp,sp,16
 55e:	8082                	ret

0000000000000560 <fork>:
 560:	4885                	li	a7,1
 562:	00000073          	ecall
 566:	8082                	ret

0000000000000568 <exit>:
 568:	4889                	li	a7,2
 56a:	00000073          	ecall
 56e:	8082                	ret

0000000000000570 <wait>:
 570:	488d                	li	a7,3
 572:	00000073          	ecall
 576:	8082                	ret

0000000000000578 <pipe>:
 578:	4891                	li	a7,4
 57a:	00000073          	ecall
 57e:	8082                	ret

0000000000000580 <read>:
 580:	4895                	li	a7,5
 582:	00000073          	ecall
 586:	8082                	ret

0000000000000588 <write>:
 588:	48c1                	li	a7,16
 58a:	00000073          	ecall
 58e:	8082                	ret

0000000000000590 <close>:
 590:	48d5                	li	a7,21
 592:	00000073          	ecall
 596:	8082                	ret

0000000000000598 <kill>:
 598:	4899                	li	a7,6
 59a:	00000073          	ecall
 59e:	8082                	ret

00000000000005a0 <exec>:
 5a0:	489d                	li	a7,7
 5a2:	00000073          	ecall
 5a6:	8082                	ret

00000000000005a8 <open>:
 5a8:	48bd                	li	a7,15
 5aa:	00000073          	ecall
 5ae:	8082                	ret

00000000000005b0 <mknod>:
 5b0:	48c5                	li	a7,17
 5b2:	00000073          	ecall
 5b6:	8082                	ret

00000000000005b8 <unlink>:
 5b8:	48c9                	li	a7,18
 5ba:	00000073          	ecall
 5be:	8082                	ret

00000000000005c0 <fstat>:
 5c0:	48a1                	li	a7,8
 5c2:	00000073          	ecall
 5c6:	8082                	ret

00000000000005c8 <link>:
 5c8:	48cd                	li	a7,19
 5ca:	00000073          	ecall
 5ce:	8082                	ret

00000000000005d0 <mkdir>:
 5d0:	48d1                	li	a7,20
 5d2:	00000073          	ecall
 5d6:	8082                	ret

00000000000005d8 <chdir>:
 5d8:	48a5                	li	a7,9
 5da:	00000073          	ecall
 5de:	8082                	ret

00000000000005e0 <dup>:
 5e0:	48a9                	li	a7,10
 5e2:	00000073          	ecall
 5e6:	8082                	ret

00000000000005e8 <getpid>:
 5e8:	48ad                	li	a7,11
 5ea:	00000073          	ecall
 5ee:	8082                	ret

00000000000005f0 <sbrk>:
 5f0:	48b1                	li	a7,12
 5f2:	00000073          	ecall
 5f6:	8082                	ret

00000000000005f8 <sleep>:
 5f8:	48b5                	li	a7,13
 5fa:	00000073          	ecall
 5fe:	8082                	ret

0000000000000600 <uptime>:
 600:	48b9                	li	a7,14
 602:	00000073          	ecall
 606:	8082                	ret

0000000000000608 <trace>:
 608:	48d9                	li	a7,22
 60a:	00000073          	ecall
 60e:	8082                	ret

0000000000000610 <putc>:
 610:	1101                	addi	sp,sp,-32
 612:	ec06                	sd	ra,24(sp)
 614:	e822                	sd	s0,16(sp)
 616:	1000                	addi	s0,sp,32
 618:	feb407a3          	sb	a1,-17(s0)
 61c:	4605                	li	a2,1
 61e:	fef40593          	addi	a1,s0,-17
 622:	00000097          	auipc	ra,0x0
 626:	f66080e7          	jalr	-154(ra) # 588 <write>
 62a:	60e2                	ld	ra,24(sp)
 62c:	6442                	ld	s0,16(sp)
 62e:	6105                	addi	sp,sp,32
 630:	8082                	ret

0000000000000632 <printint>:
 632:	7139                	addi	sp,sp,-64
 634:	fc06                	sd	ra,56(sp)
 636:	f822                	sd	s0,48(sp)
 638:	f426                	sd	s1,40(sp)
 63a:	f04a                	sd	s2,32(sp)
 63c:	ec4e                	sd	s3,24(sp)
 63e:	0080                	addi	s0,sp,64
 640:	84aa                	mv	s1,a0
 642:	c299                	beqz	a3,648 <printint+0x16>
 644:	0805c863          	bltz	a1,6d4 <printint+0xa2>
 648:	2581                	sext.w	a1,a1
 64a:	4881                	li	a7,0
 64c:	fc040693          	addi	a3,s0,-64
 650:	4701                	li	a4,0
 652:	2601                	sext.w	a2,a2
 654:	00000517          	auipc	a0,0x0
 658:	4b450513          	addi	a0,a0,1204 # b08 <digits>
 65c:	883a                	mv	a6,a4
 65e:	2705                	addiw	a4,a4,1
 660:	02c5f7bb          	remuw	a5,a1,a2
 664:	1782                	slli	a5,a5,0x20
 666:	9381                	srli	a5,a5,0x20
 668:	97aa                	add	a5,a5,a0
 66a:	0007c783          	lbu	a5,0(a5)
 66e:	00f68023          	sb	a5,0(a3)
 672:	0005879b          	sext.w	a5,a1
 676:	02c5d5bb          	divuw	a1,a1,a2
 67a:	0685                	addi	a3,a3,1
 67c:	fec7f0e3          	bgeu	a5,a2,65c <printint+0x2a>
 680:	00088b63          	beqz	a7,696 <printint+0x64>
 684:	fd040793          	addi	a5,s0,-48
 688:	973e                	add	a4,a4,a5
 68a:	02d00793          	li	a5,45
 68e:	fef70823          	sb	a5,-16(a4)
 692:	0028071b          	addiw	a4,a6,2
 696:	02e05863          	blez	a4,6c6 <printint+0x94>
 69a:	fc040793          	addi	a5,s0,-64
 69e:	00e78933          	add	s2,a5,a4
 6a2:	fff78993          	addi	s3,a5,-1
 6a6:	99ba                	add	s3,s3,a4
 6a8:	377d                	addiw	a4,a4,-1
 6aa:	1702                	slli	a4,a4,0x20
 6ac:	9301                	srli	a4,a4,0x20
 6ae:	40e989b3          	sub	s3,s3,a4
 6b2:	fff94583          	lbu	a1,-1(s2)
 6b6:	8526                	mv	a0,s1
 6b8:	00000097          	auipc	ra,0x0
 6bc:	f58080e7          	jalr	-168(ra) # 610 <putc>
 6c0:	197d                	addi	s2,s2,-1
 6c2:	ff3918e3          	bne	s2,s3,6b2 <printint+0x80>
 6c6:	70e2                	ld	ra,56(sp)
 6c8:	7442                	ld	s0,48(sp)
 6ca:	74a2                	ld	s1,40(sp)
 6cc:	7902                	ld	s2,32(sp)
 6ce:	69e2                	ld	s3,24(sp)
 6d0:	6121                	addi	sp,sp,64
 6d2:	8082                	ret
 6d4:	40b005bb          	negw	a1,a1
 6d8:	4885                	li	a7,1
 6da:	bf8d                	j	64c <printint+0x1a>

00000000000006dc <vprintf>:
 6dc:	7119                	addi	sp,sp,-128
 6de:	fc86                	sd	ra,120(sp)
 6e0:	f8a2                	sd	s0,112(sp)
 6e2:	f4a6                	sd	s1,104(sp)
 6e4:	f0ca                	sd	s2,96(sp)
 6e6:	ecce                	sd	s3,88(sp)
 6e8:	e8d2                	sd	s4,80(sp)
 6ea:	e4d6                	sd	s5,72(sp)
 6ec:	e0da                	sd	s6,64(sp)
 6ee:	fc5e                	sd	s7,56(sp)
 6f0:	f862                	sd	s8,48(sp)
 6f2:	f466                	sd	s9,40(sp)
 6f4:	f06a                	sd	s10,32(sp)
 6f6:	ec6e                	sd	s11,24(sp)
 6f8:	0100                	addi	s0,sp,128
 6fa:	0005c903          	lbu	s2,0(a1)
 6fe:	18090f63          	beqz	s2,89c <vprintf+0x1c0>
 702:	8aaa                	mv	s5,a0
 704:	8b32                	mv	s6,a2
 706:	00158493          	addi	s1,a1,1
 70a:	4981                	li	s3,0
 70c:	02500a13          	li	s4,37
 710:	06400c13          	li	s8,100
 714:	06c00c93          	li	s9,108
 718:	07800d13          	li	s10,120
 71c:	07000d93          	li	s11,112
 720:	00000b97          	auipc	s7,0x0
 724:	3e8b8b93          	addi	s7,s7,1000 # b08 <digits>
 728:	a839                	j	746 <vprintf+0x6a>
 72a:	85ca                	mv	a1,s2
 72c:	8556                	mv	a0,s5
 72e:	00000097          	auipc	ra,0x0
 732:	ee2080e7          	jalr	-286(ra) # 610 <putc>
 736:	a019                	j	73c <vprintf+0x60>
 738:	01498f63          	beq	s3,s4,756 <vprintf+0x7a>
 73c:	0485                	addi	s1,s1,1
 73e:	fff4c903          	lbu	s2,-1(s1)
 742:	14090d63          	beqz	s2,89c <vprintf+0x1c0>
 746:	0009079b          	sext.w	a5,s2
 74a:	fe0997e3          	bnez	s3,738 <vprintf+0x5c>
 74e:	fd479ee3          	bne	a5,s4,72a <vprintf+0x4e>
 752:	89be                	mv	s3,a5
 754:	b7e5                	j	73c <vprintf+0x60>
 756:	05878063          	beq	a5,s8,796 <vprintf+0xba>
 75a:	05978c63          	beq	a5,s9,7b2 <vprintf+0xd6>
 75e:	07a78863          	beq	a5,s10,7ce <vprintf+0xf2>
 762:	09b78463          	beq	a5,s11,7ea <vprintf+0x10e>
 766:	07300713          	li	a4,115
 76a:	0ce78663          	beq	a5,a4,836 <vprintf+0x15a>
 76e:	06300713          	li	a4,99
 772:	0ee78e63          	beq	a5,a4,86e <vprintf+0x192>
 776:	11478863          	beq	a5,s4,886 <vprintf+0x1aa>
 77a:	85d2                	mv	a1,s4
 77c:	8556                	mv	a0,s5
 77e:	00000097          	auipc	ra,0x0
 782:	e92080e7          	jalr	-366(ra) # 610 <putc>
 786:	85ca                	mv	a1,s2
 788:	8556                	mv	a0,s5
 78a:	00000097          	auipc	ra,0x0
 78e:	e86080e7          	jalr	-378(ra) # 610 <putc>
 792:	4981                	li	s3,0
 794:	b765                	j	73c <vprintf+0x60>
 796:	008b0913          	addi	s2,s6,8
 79a:	4685                	li	a3,1
 79c:	4629                	li	a2,10
 79e:	000b2583          	lw	a1,0(s6)
 7a2:	8556                	mv	a0,s5
 7a4:	00000097          	auipc	ra,0x0
 7a8:	e8e080e7          	jalr	-370(ra) # 632 <printint>
 7ac:	8b4a                	mv	s6,s2
 7ae:	4981                	li	s3,0
 7b0:	b771                	j	73c <vprintf+0x60>
 7b2:	008b0913          	addi	s2,s6,8
 7b6:	4681                	li	a3,0
 7b8:	4629                	li	a2,10
 7ba:	000b2583          	lw	a1,0(s6)
 7be:	8556                	mv	a0,s5
 7c0:	00000097          	auipc	ra,0x0
 7c4:	e72080e7          	jalr	-398(ra) # 632 <printint>
 7c8:	8b4a                	mv	s6,s2
 7ca:	4981                	li	s3,0
 7cc:	bf85                	j	73c <vprintf+0x60>
 7ce:	008b0913          	addi	s2,s6,8
 7d2:	4681                	li	a3,0
 7d4:	4641                	li	a2,16
 7d6:	000b2583          	lw	a1,0(s6)
 7da:	8556                	mv	a0,s5
 7dc:	00000097          	auipc	ra,0x0
 7e0:	e56080e7          	jalr	-426(ra) # 632 <printint>
 7e4:	8b4a                	mv	s6,s2
 7e6:	4981                	li	s3,0
 7e8:	bf91                	j	73c <vprintf+0x60>
 7ea:	008b0793          	addi	a5,s6,8
 7ee:	f8f43423          	sd	a5,-120(s0)
 7f2:	000b3983          	ld	s3,0(s6)
 7f6:	03000593          	li	a1,48
 7fa:	8556                	mv	a0,s5
 7fc:	00000097          	auipc	ra,0x0
 800:	e14080e7          	jalr	-492(ra) # 610 <putc>
 804:	85ea                	mv	a1,s10
 806:	8556                	mv	a0,s5
 808:	00000097          	auipc	ra,0x0
 80c:	e08080e7          	jalr	-504(ra) # 610 <putc>
 810:	4941                	li	s2,16
 812:	03c9d793          	srli	a5,s3,0x3c
 816:	97de                	add	a5,a5,s7
 818:	0007c583          	lbu	a1,0(a5)
 81c:	8556                	mv	a0,s5
 81e:	00000097          	auipc	ra,0x0
 822:	df2080e7          	jalr	-526(ra) # 610 <putc>
 826:	0992                	slli	s3,s3,0x4
 828:	397d                	addiw	s2,s2,-1
 82a:	fe0914e3          	bnez	s2,812 <vprintf+0x136>
 82e:	f8843b03          	ld	s6,-120(s0)
 832:	4981                	li	s3,0
 834:	b721                	j	73c <vprintf+0x60>
 836:	008b0993          	addi	s3,s6,8
 83a:	000b3903          	ld	s2,0(s6)
 83e:	02090163          	beqz	s2,860 <vprintf+0x184>
 842:	00094583          	lbu	a1,0(s2)
 846:	c9a1                	beqz	a1,896 <vprintf+0x1ba>
 848:	8556                	mv	a0,s5
 84a:	00000097          	auipc	ra,0x0
 84e:	dc6080e7          	jalr	-570(ra) # 610 <putc>
 852:	0905                	addi	s2,s2,1
 854:	00094583          	lbu	a1,0(s2)
 858:	f9e5                	bnez	a1,848 <vprintf+0x16c>
 85a:	8b4e                	mv	s6,s3
 85c:	4981                	li	s3,0
 85e:	bdf9                	j	73c <vprintf+0x60>
 860:	00000917          	auipc	s2,0x0
 864:	2a090913          	addi	s2,s2,672 # b00 <malloc+0x15a>
 868:	02800593          	li	a1,40
 86c:	bff1                	j	848 <vprintf+0x16c>
 86e:	008b0913          	addi	s2,s6,8
 872:	000b4583          	lbu	a1,0(s6)
 876:	8556                	mv	a0,s5
 878:	00000097          	auipc	ra,0x0
 87c:	d98080e7          	jalr	-616(ra) # 610 <putc>
 880:	8b4a                	mv	s6,s2
 882:	4981                	li	s3,0
 884:	bd65                	j	73c <vprintf+0x60>
 886:	85d2                	mv	a1,s4
 888:	8556                	mv	a0,s5
 88a:	00000097          	auipc	ra,0x0
 88e:	d86080e7          	jalr	-634(ra) # 610 <putc>
 892:	4981                	li	s3,0
 894:	b565                	j	73c <vprintf+0x60>
 896:	8b4e                	mv	s6,s3
 898:	4981                	li	s3,0
 89a:	b54d                	j	73c <vprintf+0x60>
 89c:	70e6                	ld	ra,120(sp)
 89e:	7446                	ld	s0,112(sp)
 8a0:	74a6                	ld	s1,104(sp)
 8a2:	7906                	ld	s2,96(sp)
 8a4:	69e6                	ld	s3,88(sp)
 8a6:	6a46                	ld	s4,80(sp)
 8a8:	6aa6                	ld	s5,72(sp)
 8aa:	6b06                	ld	s6,64(sp)
 8ac:	7be2                	ld	s7,56(sp)
 8ae:	7c42                	ld	s8,48(sp)
 8b0:	7ca2                	ld	s9,40(sp)
 8b2:	7d02                	ld	s10,32(sp)
 8b4:	6de2                	ld	s11,24(sp)
 8b6:	6109                	addi	sp,sp,128
 8b8:	8082                	ret

00000000000008ba <fprintf>:
 8ba:	715d                	addi	sp,sp,-80
 8bc:	ec06                	sd	ra,24(sp)
 8be:	e822                	sd	s0,16(sp)
 8c0:	1000                	addi	s0,sp,32
 8c2:	e010                	sd	a2,0(s0)
 8c4:	e414                	sd	a3,8(s0)
 8c6:	e818                	sd	a4,16(s0)
 8c8:	ec1c                	sd	a5,24(s0)
 8ca:	03043023          	sd	a6,32(s0)
 8ce:	03143423          	sd	a7,40(s0)
 8d2:	fe843423          	sd	s0,-24(s0)
 8d6:	8622                	mv	a2,s0
 8d8:	00000097          	auipc	ra,0x0
 8dc:	e04080e7          	jalr	-508(ra) # 6dc <vprintf>
 8e0:	60e2                	ld	ra,24(sp)
 8e2:	6442                	ld	s0,16(sp)
 8e4:	6161                	addi	sp,sp,80
 8e6:	8082                	ret

00000000000008e8 <printf>:
 8e8:	711d                	addi	sp,sp,-96
 8ea:	ec06                	sd	ra,24(sp)
 8ec:	e822                	sd	s0,16(sp)
 8ee:	1000                	addi	s0,sp,32
 8f0:	e40c                	sd	a1,8(s0)
 8f2:	e810                	sd	a2,16(s0)
 8f4:	ec14                	sd	a3,24(s0)
 8f6:	f018                	sd	a4,32(s0)
 8f8:	f41c                	sd	a5,40(s0)
 8fa:	03043823          	sd	a6,48(s0)
 8fe:	03143c23          	sd	a7,56(s0)
 902:	00840613          	addi	a2,s0,8
 906:	fec43423          	sd	a2,-24(s0)
 90a:	85aa                	mv	a1,a0
 90c:	4505                	li	a0,1
 90e:	00000097          	auipc	ra,0x0
 912:	dce080e7          	jalr	-562(ra) # 6dc <vprintf>
 916:	60e2                	ld	ra,24(sp)
 918:	6442                	ld	s0,16(sp)
 91a:	6125                	addi	sp,sp,96
 91c:	8082                	ret

000000000000091e <free>:
 91e:	1141                	addi	sp,sp,-16
 920:	e422                	sd	s0,8(sp)
 922:	0800                	addi	s0,sp,16
 924:	ff050693          	addi	a3,a0,-16
 928:	00000797          	auipc	a5,0x0
 92c:	6d87b783          	ld	a5,1752(a5) # 1000 <freep>
 930:	a805                	j	960 <free+0x42>
 932:	4618                	lw	a4,8(a2)
 934:	9db9                	addw	a1,a1,a4
 936:	feb52c23          	sw	a1,-8(a0)
 93a:	6398                	ld	a4,0(a5)
 93c:	6318                	ld	a4,0(a4)
 93e:	fee53823          	sd	a4,-16(a0)
 942:	a091                	j	986 <free+0x68>
 944:	ff852703          	lw	a4,-8(a0)
 948:	9e39                	addw	a2,a2,a4
 94a:	c790                	sw	a2,8(a5)
 94c:	ff053703          	ld	a4,-16(a0)
 950:	e398                	sd	a4,0(a5)
 952:	a099                	j	998 <free+0x7a>
 954:	6398                	ld	a4,0(a5)
 956:	00e7e463          	bltu	a5,a4,95e <free+0x40>
 95a:	00e6ea63          	bltu	a3,a4,96e <free+0x50>
 95e:	87ba                	mv	a5,a4
 960:	fed7fae3          	bgeu	a5,a3,954 <free+0x36>
 964:	6398                	ld	a4,0(a5)
 966:	00e6e463          	bltu	a3,a4,96e <free+0x50>
 96a:	fee7eae3          	bltu	a5,a4,95e <free+0x40>
 96e:	ff852583          	lw	a1,-8(a0)
 972:	6390                	ld	a2,0(a5)
 974:	02059713          	slli	a4,a1,0x20
 978:	9301                	srli	a4,a4,0x20
 97a:	0712                	slli	a4,a4,0x4
 97c:	9736                	add	a4,a4,a3
 97e:	fae60ae3          	beq	a2,a4,932 <free+0x14>
 982:	fec53823          	sd	a2,-16(a0)
 986:	4790                	lw	a2,8(a5)
 988:	02061713          	slli	a4,a2,0x20
 98c:	9301                	srli	a4,a4,0x20
 98e:	0712                	slli	a4,a4,0x4
 990:	973e                	add	a4,a4,a5
 992:	fae689e3          	beq	a3,a4,944 <free+0x26>
 996:	e394                	sd	a3,0(a5)
 998:	00000717          	auipc	a4,0x0
 99c:	66f73423          	sd	a5,1640(a4) # 1000 <freep>
 9a0:	6422                	ld	s0,8(sp)
 9a2:	0141                	addi	sp,sp,16
 9a4:	8082                	ret

00000000000009a6 <malloc>:
 9a6:	7139                	addi	sp,sp,-64
 9a8:	fc06                	sd	ra,56(sp)
 9aa:	f822                	sd	s0,48(sp)
 9ac:	f426                	sd	s1,40(sp)
 9ae:	f04a                	sd	s2,32(sp)
 9b0:	ec4e                	sd	s3,24(sp)
 9b2:	e852                	sd	s4,16(sp)
 9b4:	e456                	sd	s5,8(sp)
 9b6:	e05a                	sd	s6,0(sp)
 9b8:	0080                	addi	s0,sp,64
 9ba:	02051493          	slli	s1,a0,0x20
 9be:	9081                	srli	s1,s1,0x20
 9c0:	04bd                	addi	s1,s1,15
 9c2:	8091                	srli	s1,s1,0x4
 9c4:	0014899b          	addiw	s3,s1,1
 9c8:	0485                	addi	s1,s1,1
 9ca:	00000517          	auipc	a0,0x0
 9ce:	63653503          	ld	a0,1590(a0) # 1000 <freep>
 9d2:	c515                	beqz	a0,9fe <malloc+0x58>
 9d4:	611c                	ld	a5,0(a0)
 9d6:	4798                	lw	a4,8(a5)
 9d8:	02977f63          	bgeu	a4,s1,a16 <malloc+0x70>
 9dc:	8a4e                	mv	s4,s3
 9de:	0009871b          	sext.w	a4,s3
 9e2:	6685                	lui	a3,0x1
 9e4:	00d77363          	bgeu	a4,a3,9ea <malloc+0x44>
 9e8:	6a05                	lui	s4,0x1
 9ea:	000a0b1b          	sext.w	s6,s4
 9ee:	004a1a1b          	slliw	s4,s4,0x4
 9f2:	00000917          	auipc	s2,0x0
 9f6:	60e90913          	addi	s2,s2,1550 # 1000 <freep>
 9fa:	5afd                	li	s5,-1
 9fc:	a88d                	j	a6e <malloc+0xc8>
 9fe:	00000797          	auipc	a5,0x0
 a02:	62278793          	addi	a5,a5,1570 # 1020 <base>
 a06:	00000717          	auipc	a4,0x0
 a0a:	5ef73d23          	sd	a5,1530(a4) # 1000 <freep>
 a0e:	e39c                	sd	a5,0(a5)
 a10:	0007a423          	sw	zero,8(a5)
 a14:	b7e1                	j	9dc <malloc+0x36>
 a16:	02e48b63          	beq	s1,a4,a4c <malloc+0xa6>
 a1a:	4137073b          	subw	a4,a4,s3
 a1e:	c798                	sw	a4,8(a5)
 a20:	1702                	slli	a4,a4,0x20
 a22:	9301                	srli	a4,a4,0x20
 a24:	0712                	slli	a4,a4,0x4
 a26:	97ba                	add	a5,a5,a4
 a28:	0137a423          	sw	s3,8(a5)
 a2c:	00000717          	auipc	a4,0x0
 a30:	5ca73a23          	sd	a0,1492(a4) # 1000 <freep>
 a34:	01078513          	addi	a0,a5,16
 a38:	70e2                	ld	ra,56(sp)
 a3a:	7442                	ld	s0,48(sp)
 a3c:	74a2                	ld	s1,40(sp)
 a3e:	7902                	ld	s2,32(sp)
 a40:	69e2                	ld	s3,24(sp)
 a42:	6a42                	ld	s4,16(sp)
 a44:	6aa2                	ld	s5,8(sp)
 a46:	6b02                	ld	s6,0(sp)
 a48:	6121                	addi	sp,sp,64
 a4a:	8082                	ret
 a4c:	6398                	ld	a4,0(a5)
 a4e:	e118                	sd	a4,0(a0)
 a50:	bff1                	j	a2c <malloc+0x86>
 a52:	01652423          	sw	s6,8(a0)
 a56:	0541                	addi	a0,a0,16
 a58:	00000097          	auipc	ra,0x0
 a5c:	ec6080e7          	jalr	-314(ra) # 91e <free>
 a60:	00093503          	ld	a0,0(s2)
 a64:	d971                	beqz	a0,a38 <malloc+0x92>
 a66:	611c                	ld	a5,0(a0)
 a68:	4798                	lw	a4,8(a5)
 a6a:	fa9776e3          	bgeu	a4,s1,a16 <malloc+0x70>
 a6e:	00093703          	ld	a4,0(s2)
 a72:	853e                	mv	a0,a5
 a74:	fef719e3          	bne	a4,a5,a66 <malloc+0xc0>
 a78:	8552                	mv	a0,s4
 a7a:	00000097          	auipc	ra,0x0
 a7e:	b76080e7          	jalr	-1162(ra) # 5f0 <sbrk>
 a82:	fd5518e3          	bne	a0,s5,a52 <malloc+0xac>
 a86:	4501                	li	a0,0
 a88:	bf45                	j	a38 <malloc+0x92>
