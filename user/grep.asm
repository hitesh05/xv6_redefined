
user/_grep:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <matchstar>:
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  10:	892a                	mv	s2,a0
  12:	89ae                	mv	s3,a1
  14:	84b2                	mv	s1,a2
  16:	02e00a13          	li	s4,46
  1a:	85a6                	mv	a1,s1
  1c:	854e                	mv	a0,s3
  1e:	00000097          	auipc	ra,0x0
  22:	030080e7          	jalr	48(ra) # 4e <matchhere>
  26:	e919                	bnez	a0,3c <matchstar+0x3c>
  28:	0004c783          	lbu	a5,0(s1)
  2c:	cb89                	beqz	a5,3e <matchstar+0x3e>
  2e:	0485                	addi	s1,s1,1
  30:	2781                	sext.w	a5,a5
  32:	ff2784e3          	beq	a5,s2,1a <matchstar+0x1a>
  36:	ff4902e3          	beq	s2,s4,1a <matchstar+0x1a>
  3a:	a011                	j	3e <matchstar+0x3e>
  3c:	4505                	li	a0,1
  3e:	70a2                	ld	ra,40(sp)
  40:	7402                	ld	s0,32(sp)
  42:	64e2                	ld	s1,24(sp)
  44:	6942                	ld	s2,16(sp)
  46:	69a2                	ld	s3,8(sp)
  48:	6a02                	ld	s4,0(sp)
  4a:	6145                	addi	sp,sp,48
  4c:	8082                	ret

000000000000004e <matchhere>:
  4e:	00054703          	lbu	a4,0(a0)
  52:	cb3d                	beqz	a4,c8 <matchhere+0x7a>
  54:	1141                	addi	sp,sp,-16
  56:	e406                	sd	ra,8(sp)
  58:	e022                	sd	s0,0(sp)
  5a:	0800                	addi	s0,sp,16
  5c:	87aa                	mv	a5,a0
  5e:	00154683          	lbu	a3,1(a0)
  62:	02a00613          	li	a2,42
  66:	02c68563          	beq	a3,a2,90 <matchhere+0x42>
  6a:	02400613          	li	a2,36
  6e:	02c70a63          	beq	a4,a2,a2 <matchhere+0x54>
  72:	0005c683          	lbu	a3,0(a1)
  76:	4501                	li	a0,0
  78:	ca81                	beqz	a3,88 <matchhere+0x3a>
  7a:	02e00613          	li	a2,46
  7e:	02c70d63          	beq	a4,a2,b8 <matchhere+0x6a>
  82:	4501                	li	a0,0
  84:	02d70a63          	beq	a4,a3,b8 <matchhere+0x6a>
  88:	60a2                	ld	ra,8(sp)
  8a:	6402                	ld	s0,0(sp)
  8c:	0141                	addi	sp,sp,16
  8e:	8082                	ret
  90:	862e                	mv	a2,a1
  92:	00250593          	addi	a1,a0,2
  96:	853a                	mv	a0,a4
  98:	00000097          	auipc	ra,0x0
  9c:	f68080e7          	jalr	-152(ra) # 0 <matchstar>
  a0:	b7e5                	j	88 <matchhere+0x3a>
  a2:	c691                	beqz	a3,ae <matchhere+0x60>
  a4:	0005c683          	lbu	a3,0(a1)
  a8:	fee9                	bnez	a3,82 <matchhere+0x34>
  aa:	4501                	li	a0,0
  ac:	bff1                	j	88 <matchhere+0x3a>
  ae:	0005c503          	lbu	a0,0(a1)
  b2:	00153513          	seqz	a0,a0
  b6:	bfc9                	j	88 <matchhere+0x3a>
  b8:	0585                	addi	a1,a1,1
  ba:	00178513          	addi	a0,a5,1
  be:	00000097          	auipc	ra,0x0
  c2:	f90080e7          	jalr	-112(ra) # 4e <matchhere>
  c6:	b7c9                	j	88 <matchhere+0x3a>
  c8:	4505                	li	a0,1
  ca:	8082                	ret

00000000000000cc <match>:
  cc:	1101                	addi	sp,sp,-32
  ce:	ec06                	sd	ra,24(sp)
  d0:	e822                	sd	s0,16(sp)
  d2:	e426                	sd	s1,8(sp)
  d4:	e04a                	sd	s2,0(sp)
  d6:	1000                	addi	s0,sp,32
  d8:	892a                	mv	s2,a0
  da:	84ae                	mv	s1,a1
  dc:	00054703          	lbu	a4,0(a0)
  e0:	05e00793          	li	a5,94
  e4:	00f70e63          	beq	a4,a5,100 <match+0x34>
  e8:	85a6                	mv	a1,s1
  ea:	854a                	mv	a0,s2
  ec:	00000097          	auipc	ra,0x0
  f0:	f62080e7          	jalr	-158(ra) # 4e <matchhere>
  f4:	ed01                	bnez	a0,10c <match+0x40>
  f6:	0485                	addi	s1,s1,1
  f8:	fff4c783          	lbu	a5,-1(s1)
  fc:	f7f5                	bnez	a5,e8 <match+0x1c>
  fe:	a801                	j	10e <match+0x42>
 100:	0505                	addi	a0,a0,1
 102:	00000097          	auipc	ra,0x0
 106:	f4c080e7          	jalr	-180(ra) # 4e <matchhere>
 10a:	a011                	j	10e <match+0x42>
 10c:	4505                	li	a0,1
 10e:	60e2                	ld	ra,24(sp)
 110:	6442                	ld	s0,16(sp)
 112:	64a2                	ld	s1,8(sp)
 114:	6902                	ld	s2,0(sp)
 116:	6105                	addi	sp,sp,32
 118:	8082                	ret

000000000000011a <grep>:
 11a:	711d                	addi	sp,sp,-96
 11c:	ec86                	sd	ra,88(sp)
 11e:	e8a2                	sd	s0,80(sp)
 120:	e4a6                	sd	s1,72(sp)
 122:	e0ca                	sd	s2,64(sp)
 124:	fc4e                	sd	s3,56(sp)
 126:	f852                	sd	s4,48(sp)
 128:	f456                	sd	s5,40(sp)
 12a:	f05a                	sd	s6,32(sp)
 12c:	ec5e                	sd	s7,24(sp)
 12e:	e862                	sd	s8,16(sp)
 130:	e466                	sd	s9,8(sp)
 132:	e06a                	sd	s10,0(sp)
 134:	1080                	addi	s0,sp,96
 136:	89aa                	mv	s3,a0
 138:	8bae                	mv	s7,a1
 13a:	4a01                	li	s4,0
 13c:	3ff00c13          	li	s8,1023
 140:	00001b17          	auipc	s6,0x1
 144:	ed0b0b13          	addi	s6,s6,-304 # 1010 <buf>
 148:	8d5a                	mv	s10,s6
 14a:	4aa9                	li	s5,10
 14c:	8cda                	mv	s9,s6
 14e:	a099                	j	194 <grep+0x7a>
 150:	01548023          	sb	s5,0(s1)
 154:	00148613          	addi	a2,s1,1
 158:	4126063b          	subw	a2,a2,s2
 15c:	85ca                	mv	a1,s2
 15e:	4505                	li	a0,1
 160:	00000097          	auipc	ra,0x0
 164:	3fe080e7          	jalr	1022(ra) # 55e <write>
 168:	00148913          	addi	s2,s1,1
 16c:	45a9                	li	a1,10
 16e:	854a                	mv	a0,s2
 170:	00000097          	auipc	ra,0x0
 174:	1f0080e7          	jalr	496(ra) # 360 <strchr>
 178:	84aa                	mv	s1,a0
 17a:	c919                	beqz	a0,190 <grep+0x76>
 17c:	00048023          	sb	zero,0(s1)
 180:	85ca                	mv	a1,s2
 182:	854e                	mv	a0,s3
 184:	00000097          	auipc	ra,0x0
 188:	f48080e7          	jalr	-184(ra) # cc <match>
 18c:	dd71                	beqz	a0,168 <grep+0x4e>
 18e:	b7c9                	j	150 <grep+0x36>
 190:	03404563          	bgtz	s4,1ba <grep+0xa0>
 194:	414c063b          	subw	a2,s8,s4
 198:	014b05b3          	add	a1,s6,s4
 19c:	855e                	mv	a0,s7
 19e:	00000097          	auipc	ra,0x0
 1a2:	3b8080e7          	jalr	952(ra) # 556 <read>
 1a6:	02a05663          	blez	a0,1d2 <grep+0xb8>
 1aa:	00aa0a3b          	addw	s4,s4,a0
 1ae:	014b07b3          	add	a5,s6,s4
 1b2:	00078023          	sb	zero,0(a5)
 1b6:	8966                	mv	s2,s9
 1b8:	bf55                	j	16c <grep+0x52>
 1ba:	416907b3          	sub	a5,s2,s6
 1be:	40fa0a3b          	subw	s4,s4,a5
 1c2:	8652                	mv	a2,s4
 1c4:	85ca                	mv	a1,s2
 1c6:	856a                	mv	a0,s10
 1c8:	00000097          	auipc	ra,0x0
 1cc:	2c0080e7          	jalr	704(ra) # 488 <memmove>
 1d0:	b7d1                	j	194 <grep+0x7a>
 1d2:	60e6                	ld	ra,88(sp)
 1d4:	6446                	ld	s0,80(sp)
 1d6:	64a6                	ld	s1,72(sp)
 1d8:	6906                	ld	s2,64(sp)
 1da:	79e2                	ld	s3,56(sp)
 1dc:	7a42                	ld	s4,48(sp)
 1de:	7aa2                	ld	s5,40(sp)
 1e0:	7b02                	ld	s6,32(sp)
 1e2:	6be2                	ld	s7,24(sp)
 1e4:	6c42                	ld	s8,16(sp)
 1e6:	6ca2                	ld	s9,8(sp)
 1e8:	6d02                	ld	s10,0(sp)
 1ea:	6125                	addi	sp,sp,96
 1ec:	8082                	ret

00000000000001ee <main>:
 1ee:	7139                	addi	sp,sp,-64
 1f0:	fc06                	sd	ra,56(sp)
 1f2:	f822                	sd	s0,48(sp)
 1f4:	f426                	sd	s1,40(sp)
 1f6:	f04a                	sd	s2,32(sp)
 1f8:	ec4e                	sd	s3,24(sp)
 1fa:	e852                	sd	s4,16(sp)
 1fc:	e456                	sd	s5,8(sp)
 1fe:	0080                	addi	s0,sp,64
 200:	4785                	li	a5,1
 202:	04a7de63          	bge	a5,a0,25e <main+0x70>
 206:	0085ba03          	ld	s4,8(a1)
 20a:	4789                	li	a5,2
 20c:	06a7d763          	bge	a5,a0,27a <main+0x8c>
 210:	01058913          	addi	s2,a1,16
 214:	ffd5099b          	addiw	s3,a0,-3
 218:	1982                	slli	s3,s3,0x20
 21a:	0209d993          	srli	s3,s3,0x20
 21e:	098e                	slli	s3,s3,0x3
 220:	05e1                	addi	a1,a1,24
 222:	99ae                	add	s3,s3,a1
 224:	4581                	li	a1,0
 226:	00093503          	ld	a0,0(s2)
 22a:	00000097          	auipc	ra,0x0
 22e:	354080e7          	jalr	852(ra) # 57e <open>
 232:	84aa                	mv	s1,a0
 234:	04054e63          	bltz	a0,290 <main+0xa2>
 238:	85aa                	mv	a1,a0
 23a:	8552                	mv	a0,s4
 23c:	00000097          	auipc	ra,0x0
 240:	ede080e7          	jalr	-290(ra) # 11a <grep>
 244:	8526                	mv	a0,s1
 246:	00000097          	auipc	ra,0x0
 24a:	320080e7          	jalr	800(ra) # 566 <close>
 24e:	0921                	addi	s2,s2,8
 250:	fd391ae3          	bne	s2,s3,224 <main+0x36>
 254:	4501                	li	a0,0
 256:	00000097          	auipc	ra,0x0
 25a:	2e8080e7          	jalr	744(ra) # 53e <exit>
 25e:	00001597          	auipc	a1,0x1
 262:	80258593          	addi	a1,a1,-2046 # a60 <malloc+0xe4>
 266:	4509                	li	a0,2
 268:	00000097          	auipc	ra,0x0
 26c:	628080e7          	jalr	1576(ra) # 890 <fprintf>
 270:	4505                	li	a0,1
 272:	00000097          	auipc	ra,0x0
 276:	2cc080e7          	jalr	716(ra) # 53e <exit>
 27a:	4581                	li	a1,0
 27c:	8552                	mv	a0,s4
 27e:	00000097          	auipc	ra,0x0
 282:	e9c080e7          	jalr	-356(ra) # 11a <grep>
 286:	4501                	li	a0,0
 288:	00000097          	auipc	ra,0x0
 28c:	2b6080e7          	jalr	694(ra) # 53e <exit>
 290:	00093583          	ld	a1,0(s2)
 294:	00000517          	auipc	a0,0x0
 298:	7ec50513          	addi	a0,a0,2028 # a80 <malloc+0x104>
 29c:	00000097          	auipc	ra,0x0
 2a0:	622080e7          	jalr	1570(ra) # 8be <printf>
 2a4:	4505                	li	a0,1
 2a6:	00000097          	auipc	ra,0x0
 2aa:	298080e7          	jalr	664(ra) # 53e <exit>

00000000000002ae <_main>:
 2ae:	1141                	addi	sp,sp,-16
 2b0:	e406                	sd	ra,8(sp)
 2b2:	e022                	sd	s0,0(sp)
 2b4:	0800                	addi	s0,sp,16
 2b6:	00000097          	auipc	ra,0x0
 2ba:	f38080e7          	jalr	-200(ra) # 1ee <main>
 2be:	4501                	li	a0,0
 2c0:	00000097          	auipc	ra,0x0
 2c4:	27e080e7          	jalr	638(ra) # 53e <exit>

00000000000002c8 <strcpy>:
 2c8:	1141                	addi	sp,sp,-16
 2ca:	e422                	sd	s0,8(sp)
 2cc:	0800                	addi	s0,sp,16
 2ce:	87aa                	mv	a5,a0
 2d0:	0585                	addi	a1,a1,1
 2d2:	0785                	addi	a5,a5,1
 2d4:	fff5c703          	lbu	a4,-1(a1)
 2d8:	fee78fa3          	sb	a4,-1(a5)
 2dc:	fb75                	bnez	a4,2d0 <strcpy+0x8>
 2de:	6422                	ld	s0,8(sp)
 2e0:	0141                	addi	sp,sp,16
 2e2:	8082                	ret

00000000000002e4 <strcmp>:
 2e4:	1141                	addi	sp,sp,-16
 2e6:	e422                	sd	s0,8(sp)
 2e8:	0800                	addi	s0,sp,16
 2ea:	00054783          	lbu	a5,0(a0)
 2ee:	cb91                	beqz	a5,302 <strcmp+0x1e>
 2f0:	0005c703          	lbu	a4,0(a1)
 2f4:	00f71763          	bne	a4,a5,302 <strcmp+0x1e>
 2f8:	0505                	addi	a0,a0,1
 2fa:	0585                	addi	a1,a1,1
 2fc:	00054783          	lbu	a5,0(a0)
 300:	fbe5                	bnez	a5,2f0 <strcmp+0xc>
 302:	0005c503          	lbu	a0,0(a1)
 306:	40a7853b          	subw	a0,a5,a0
 30a:	6422                	ld	s0,8(sp)
 30c:	0141                	addi	sp,sp,16
 30e:	8082                	ret

0000000000000310 <strlen>:
 310:	1141                	addi	sp,sp,-16
 312:	e422                	sd	s0,8(sp)
 314:	0800                	addi	s0,sp,16
 316:	00054783          	lbu	a5,0(a0)
 31a:	cf91                	beqz	a5,336 <strlen+0x26>
 31c:	0505                	addi	a0,a0,1
 31e:	87aa                	mv	a5,a0
 320:	4685                	li	a3,1
 322:	9e89                	subw	a3,a3,a0
 324:	00f6853b          	addw	a0,a3,a5
 328:	0785                	addi	a5,a5,1
 32a:	fff7c703          	lbu	a4,-1(a5)
 32e:	fb7d                	bnez	a4,324 <strlen+0x14>
 330:	6422                	ld	s0,8(sp)
 332:	0141                	addi	sp,sp,16
 334:	8082                	ret
 336:	4501                	li	a0,0
 338:	bfe5                	j	330 <strlen+0x20>

000000000000033a <memset>:
 33a:	1141                	addi	sp,sp,-16
 33c:	e422                	sd	s0,8(sp)
 33e:	0800                	addi	s0,sp,16
 340:	ce09                	beqz	a2,35a <memset+0x20>
 342:	87aa                	mv	a5,a0
 344:	fff6071b          	addiw	a4,a2,-1
 348:	1702                	slli	a4,a4,0x20
 34a:	9301                	srli	a4,a4,0x20
 34c:	0705                	addi	a4,a4,1
 34e:	972a                	add	a4,a4,a0
 350:	00b78023          	sb	a1,0(a5)
 354:	0785                	addi	a5,a5,1
 356:	fee79de3          	bne	a5,a4,350 <memset+0x16>
 35a:	6422                	ld	s0,8(sp)
 35c:	0141                	addi	sp,sp,16
 35e:	8082                	ret

0000000000000360 <strchr>:
 360:	1141                	addi	sp,sp,-16
 362:	e422                	sd	s0,8(sp)
 364:	0800                	addi	s0,sp,16
 366:	00054783          	lbu	a5,0(a0)
 36a:	cb99                	beqz	a5,380 <strchr+0x20>
 36c:	00f58763          	beq	a1,a5,37a <strchr+0x1a>
 370:	0505                	addi	a0,a0,1
 372:	00054783          	lbu	a5,0(a0)
 376:	fbfd                	bnez	a5,36c <strchr+0xc>
 378:	4501                	li	a0,0
 37a:	6422                	ld	s0,8(sp)
 37c:	0141                	addi	sp,sp,16
 37e:	8082                	ret
 380:	4501                	li	a0,0
 382:	bfe5                	j	37a <strchr+0x1a>

0000000000000384 <gets>:
 384:	711d                	addi	sp,sp,-96
 386:	ec86                	sd	ra,88(sp)
 388:	e8a2                	sd	s0,80(sp)
 38a:	e4a6                	sd	s1,72(sp)
 38c:	e0ca                	sd	s2,64(sp)
 38e:	fc4e                	sd	s3,56(sp)
 390:	f852                	sd	s4,48(sp)
 392:	f456                	sd	s5,40(sp)
 394:	f05a                	sd	s6,32(sp)
 396:	ec5e                	sd	s7,24(sp)
 398:	1080                	addi	s0,sp,96
 39a:	8baa                	mv	s7,a0
 39c:	8a2e                	mv	s4,a1
 39e:	892a                	mv	s2,a0
 3a0:	4481                	li	s1,0
 3a2:	4aa9                	li	s5,10
 3a4:	4b35                	li	s6,13
 3a6:	89a6                	mv	s3,s1
 3a8:	2485                	addiw	s1,s1,1
 3aa:	0344d863          	bge	s1,s4,3da <gets+0x56>
 3ae:	4605                	li	a2,1
 3b0:	faf40593          	addi	a1,s0,-81
 3b4:	4501                	li	a0,0
 3b6:	00000097          	auipc	ra,0x0
 3ba:	1a0080e7          	jalr	416(ra) # 556 <read>
 3be:	00a05e63          	blez	a0,3da <gets+0x56>
 3c2:	faf44783          	lbu	a5,-81(s0)
 3c6:	00f90023          	sb	a5,0(s2)
 3ca:	01578763          	beq	a5,s5,3d8 <gets+0x54>
 3ce:	0905                	addi	s2,s2,1
 3d0:	fd679be3          	bne	a5,s6,3a6 <gets+0x22>
 3d4:	89a6                	mv	s3,s1
 3d6:	a011                	j	3da <gets+0x56>
 3d8:	89a6                	mv	s3,s1
 3da:	99de                	add	s3,s3,s7
 3dc:	00098023          	sb	zero,0(s3)
 3e0:	855e                	mv	a0,s7
 3e2:	60e6                	ld	ra,88(sp)
 3e4:	6446                	ld	s0,80(sp)
 3e6:	64a6                	ld	s1,72(sp)
 3e8:	6906                	ld	s2,64(sp)
 3ea:	79e2                	ld	s3,56(sp)
 3ec:	7a42                	ld	s4,48(sp)
 3ee:	7aa2                	ld	s5,40(sp)
 3f0:	7b02                	ld	s6,32(sp)
 3f2:	6be2                	ld	s7,24(sp)
 3f4:	6125                	addi	sp,sp,96
 3f6:	8082                	ret

00000000000003f8 <stat>:
 3f8:	1101                	addi	sp,sp,-32
 3fa:	ec06                	sd	ra,24(sp)
 3fc:	e822                	sd	s0,16(sp)
 3fe:	e426                	sd	s1,8(sp)
 400:	e04a                	sd	s2,0(sp)
 402:	1000                	addi	s0,sp,32
 404:	892e                	mv	s2,a1
 406:	4581                	li	a1,0
 408:	00000097          	auipc	ra,0x0
 40c:	176080e7          	jalr	374(ra) # 57e <open>
 410:	02054563          	bltz	a0,43a <stat+0x42>
 414:	84aa                	mv	s1,a0
 416:	85ca                	mv	a1,s2
 418:	00000097          	auipc	ra,0x0
 41c:	17e080e7          	jalr	382(ra) # 596 <fstat>
 420:	892a                	mv	s2,a0
 422:	8526                	mv	a0,s1
 424:	00000097          	auipc	ra,0x0
 428:	142080e7          	jalr	322(ra) # 566 <close>
 42c:	854a                	mv	a0,s2
 42e:	60e2                	ld	ra,24(sp)
 430:	6442                	ld	s0,16(sp)
 432:	64a2                	ld	s1,8(sp)
 434:	6902                	ld	s2,0(sp)
 436:	6105                	addi	sp,sp,32
 438:	8082                	ret
 43a:	597d                	li	s2,-1
 43c:	bfc5                	j	42c <stat+0x34>

000000000000043e <atoi>:
 43e:	1141                	addi	sp,sp,-16
 440:	e422                	sd	s0,8(sp)
 442:	0800                	addi	s0,sp,16
 444:	00054603          	lbu	a2,0(a0)
 448:	fd06079b          	addiw	a5,a2,-48
 44c:	0ff7f793          	andi	a5,a5,255
 450:	4725                	li	a4,9
 452:	02f76963          	bltu	a4,a5,484 <atoi+0x46>
 456:	86aa                	mv	a3,a0
 458:	4501                	li	a0,0
 45a:	45a5                	li	a1,9
 45c:	0685                	addi	a3,a3,1
 45e:	0025179b          	slliw	a5,a0,0x2
 462:	9fa9                	addw	a5,a5,a0
 464:	0017979b          	slliw	a5,a5,0x1
 468:	9fb1                	addw	a5,a5,a2
 46a:	fd07851b          	addiw	a0,a5,-48
 46e:	0006c603          	lbu	a2,0(a3)
 472:	fd06071b          	addiw	a4,a2,-48
 476:	0ff77713          	andi	a4,a4,255
 47a:	fee5f1e3          	bgeu	a1,a4,45c <atoi+0x1e>
 47e:	6422                	ld	s0,8(sp)
 480:	0141                	addi	sp,sp,16
 482:	8082                	ret
 484:	4501                	li	a0,0
 486:	bfe5                	j	47e <atoi+0x40>

0000000000000488 <memmove>:
 488:	1141                	addi	sp,sp,-16
 48a:	e422                	sd	s0,8(sp)
 48c:	0800                	addi	s0,sp,16
 48e:	02b57663          	bgeu	a0,a1,4ba <memmove+0x32>
 492:	02c05163          	blez	a2,4b4 <memmove+0x2c>
 496:	fff6079b          	addiw	a5,a2,-1
 49a:	1782                	slli	a5,a5,0x20
 49c:	9381                	srli	a5,a5,0x20
 49e:	0785                	addi	a5,a5,1
 4a0:	97aa                	add	a5,a5,a0
 4a2:	872a                	mv	a4,a0
 4a4:	0585                	addi	a1,a1,1
 4a6:	0705                	addi	a4,a4,1
 4a8:	fff5c683          	lbu	a3,-1(a1)
 4ac:	fed70fa3          	sb	a3,-1(a4)
 4b0:	fee79ae3          	bne	a5,a4,4a4 <memmove+0x1c>
 4b4:	6422                	ld	s0,8(sp)
 4b6:	0141                	addi	sp,sp,16
 4b8:	8082                	ret
 4ba:	00c50733          	add	a4,a0,a2
 4be:	95b2                	add	a1,a1,a2
 4c0:	fec05ae3          	blez	a2,4b4 <memmove+0x2c>
 4c4:	fff6079b          	addiw	a5,a2,-1
 4c8:	1782                	slli	a5,a5,0x20
 4ca:	9381                	srli	a5,a5,0x20
 4cc:	fff7c793          	not	a5,a5
 4d0:	97ba                	add	a5,a5,a4
 4d2:	15fd                	addi	a1,a1,-1
 4d4:	177d                	addi	a4,a4,-1
 4d6:	0005c683          	lbu	a3,0(a1)
 4da:	00d70023          	sb	a3,0(a4)
 4de:	fee79ae3          	bne	a5,a4,4d2 <memmove+0x4a>
 4e2:	bfc9                	j	4b4 <memmove+0x2c>

00000000000004e4 <memcmp>:
 4e4:	1141                	addi	sp,sp,-16
 4e6:	e422                	sd	s0,8(sp)
 4e8:	0800                	addi	s0,sp,16
 4ea:	ca05                	beqz	a2,51a <memcmp+0x36>
 4ec:	fff6069b          	addiw	a3,a2,-1
 4f0:	1682                	slli	a3,a3,0x20
 4f2:	9281                	srli	a3,a3,0x20
 4f4:	0685                	addi	a3,a3,1
 4f6:	96aa                	add	a3,a3,a0
 4f8:	00054783          	lbu	a5,0(a0)
 4fc:	0005c703          	lbu	a4,0(a1)
 500:	00e79863          	bne	a5,a4,510 <memcmp+0x2c>
 504:	0505                	addi	a0,a0,1
 506:	0585                	addi	a1,a1,1
 508:	fed518e3          	bne	a0,a3,4f8 <memcmp+0x14>
 50c:	4501                	li	a0,0
 50e:	a019                	j	514 <memcmp+0x30>
 510:	40e7853b          	subw	a0,a5,a4
 514:	6422                	ld	s0,8(sp)
 516:	0141                	addi	sp,sp,16
 518:	8082                	ret
 51a:	4501                	li	a0,0
 51c:	bfe5                	j	514 <memcmp+0x30>

000000000000051e <memcpy>:
 51e:	1141                	addi	sp,sp,-16
 520:	e406                	sd	ra,8(sp)
 522:	e022                	sd	s0,0(sp)
 524:	0800                	addi	s0,sp,16
 526:	00000097          	auipc	ra,0x0
 52a:	f62080e7          	jalr	-158(ra) # 488 <memmove>
 52e:	60a2                	ld	ra,8(sp)
 530:	6402                	ld	s0,0(sp)
 532:	0141                	addi	sp,sp,16
 534:	8082                	ret

0000000000000536 <fork>:
 536:	4885                	li	a7,1
 538:	00000073          	ecall
 53c:	8082                	ret

000000000000053e <exit>:
 53e:	4889                	li	a7,2
 540:	00000073          	ecall
 544:	8082                	ret

0000000000000546 <wait>:
 546:	488d                	li	a7,3
 548:	00000073          	ecall
 54c:	8082                	ret

000000000000054e <pipe>:
 54e:	4891                	li	a7,4
 550:	00000073          	ecall
 554:	8082                	ret

0000000000000556 <read>:
 556:	4895                	li	a7,5
 558:	00000073          	ecall
 55c:	8082                	ret

000000000000055e <write>:
 55e:	48c1                	li	a7,16
 560:	00000073          	ecall
 564:	8082                	ret

0000000000000566 <close>:
 566:	48d5                	li	a7,21
 568:	00000073          	ecall
 56c:	8082                	ret

000000000000056e <kill>:
 56e:	4899                	li	a7,6
 570:	00000073          	ecall
 574:	8082                	ret

0000000000000576 <exec>:
 576:	489d                	li	a7,7
 578:	00000073          	ecall
 57c:	8082                	ret

000000000000057e <open>:
 57e:	48bd                	li	a7,15
 580:	00000073          	ecall
 584:	8082                	ret

0000000000000586 <mknod>:
 586:	48c5                	li	a7,17
 588:	00000073          	ecall
 58c:	8082                	ret

000000000000058e <unlink>:
 58e:	48c9                	li	a7,18
 590:	00000073          	ecall
 594:	8082                	ret

0000000000000596 <fstat>:
 596:	48a1                	li	a7,8
 598:	00000073          	ecall
 59c:	8082                	ret

000000000000059e <link>:
 59e:	48cd                	li	a7,19
 5a0:	00000073          	ecall
 5a4:	8082                	ret

00000000000005a6 <mkdir>:
 5a6:	48d1                	li	a7,20
 5a8:	00000073          	ecall
 5ac:	8082                	ret

00000000000005ae <chdir>:
 5ae:	48a5                	li	a7,9
 5b0:	00000073          	ecall
 5b4:	8082                	ret

00000000000005b6 <dup>:
 5b6:	48a9                	li	a7,10
 5b8:	00000073          	ecall
 5bc:	8082                	ret

00000000000005be <getpid>:
 5be:	48ad                	li	a7,11
 5c0:	00000073          	ecall
 5c4:	8082                	ret

00000000000005c6 <sbrk>:
 5c6:	48b1                	li	a7,12
 5c8:	00000073          	ecall
 5cc:	8082                	ret

00000000000005ce <sleep>:
 5ce:	48b5                	li	a7,13
 5d0:	00000073          	ecall
 5d4:	8082                	ret

00000000000005d6 <uptime>:
 5d6:	48b9                	li	a7,14
 5d8:	00000073          	ecall
 5dc:	8082                	ret

00000000000005de <trace>:
 5de:	48d9                	li	a7,22
 5e0:	00000073          	ecall
 5e4:	8082                	ret

00000000000005e6 <putc>:
 5e6:	1101                	addi	sp,sp,-32
 5e8:	ec06                	sd	ra,24(sp)
 5ea:	e822                	sd	s0,16(sp)
 5ec:	1000                	addi	s0,sp,32
 5ee:	feb407a3          	sb	a1,-17(s0)
 5f2:	4605                	li	a2,1
 5f4:	fef40593          	addi	a1,s0,-17
 5f8:	00000097          	auipc	ra,0x0
 5fc:	f66080e7          	jalr	-154(ra) # 55e <write>
 600:	60e2                	ld	ra,24(sp)
 602:	6442                	ld	s0,16(sp)
 604:	6105                	addi	sp,sp,32
 606:	8082                	ret

0000000000000608 <printint>:
 608:	7139                	addi	sp,sp,-64
 60a:	fc06                	sd	ra,56(sp)
 60c:	f822                	sd	s0,48(sp)
 60e:	f426                	sd	s1,40(sp)
 610:	f04a                	sd	s2,32(sp)
 612:	ec4e                	sd	s3,24(sp)
 614:	0080                	addi	s0,sp,64
 616:	84aa                	mv	s1,a0
 618:	c299                	beqz	a3,61e <printint+0x16>
 61a:	0805c863          	bltz	a1,6aa <printint+0xa2>
 61e:	2581                	sext.w	a1,a1
 620:	4881                	li	a7,0
 622:	fc040693          	addi	a3,s0,-64
 626:	4701                	li	a4,0
 628:	2601                	sext.w	a2,a2
 62a:	00000517          	auipc	a0,0x0
 62e:	47650513          	addi	a0,a0,1142 # aa0 <digits>
 632:	883a                	mv	a6,a4
 634:	2705                	addiw	a4,a4,1
 636:	02c5f7bb          	remuw	a5,a1,a2
 63a:	1782                	slli	a5,a5,0x20
 63c:	9381                	srli	a5,a5,0x20
 63e:	97aa                	add	a5,a5,a0
 640:	0007c783          	lbu	a5,0(a5)
 644:	00f68023          	sb	a5,0(a3)
 648:	0005879b          	sext.w	a5,a1
 64c:	02c5d5bb          	divuw	a1,a1,a2
 650:	0685                	addi	a3,a3,1
 652:	fec7f0e3          	bgeu	a5,a2,632 <printint+0x2a>
 656:	00088b63          	beqz	a7,66c <printint+0x64>
 65a:	fd040793          	addi	a5,s0,-48
 65e:	973e                	add	a4,a4,a5
 660:	02d00793          	li	a5,45
 664:	fef70823          	sb	a5,-16(a4)
 668:	0028071b          	addiw	a4,a6,2
 66c:	02e05863          	blez	a4,69c <printint+0x94>
 670:	fc040793          	addi	a5,s0,-64
 674:	00e78933          	add	s2,a5,a4
 678:	fff78993          	addi	s3,a5,-1
 67c:	99ba                	add	s3,s3,a4
 67e:	377d                	addiw	a4,a4,-1
 680:	1702                	slli	a4,a4,0x20
 682:	9301                	srli	a4,a4,0x20
 684:	40e989b3          	sub	s3,s3,a4
 688:	fff94583          	lbu	a1,-1(s2)
 68c:	8526                	mv	a0,s1
 68e:	00000097          	auipc	ra,0x0
 692:	f58080e7          	jalr	-168(ra) # 5e6 <putc>
 696:	197d                	addi	s2,s2,-1
 698:	ff3918e3          	bne	s2,s3,688 <printint+0x80>
 69c:	70e2                	ld	ra,56(sp)
 69e:	7442                	ld	s0,48(sp)
 6a0:	74a2                	ld	s1,40(sp)
 6a2:	7902                	ld	s2,32(sp)
 6a4:	69e2                	ld	s3,24(sp)
 6a6:	6121                	addi	sp,sp,64
 6a8:	8082                	ret
 6aa:	40b005bb          	negw	a1,a1
 6ae:	4885                	li	a7,1
 6b0:	bf8d                	j	622 <printint+0x1a>

00000000000006b2 <vprintf>:
 6b2:	7119                	addi	sp,sp,-128
 6b4:	fc86                	sd	ra,120(sp)
 6b6:	f8a2                	sd	s0,112(sp)
 6b8:	f4a6                	sd	s1,104(sp)
 6ba:	f0ca                	sd	s2,96(sp)
 6bc:	ecce                	sd	s3,88(sp)
 6be:	e8d2                	sd	s4,80(sp)
 6c0:	e4d6                	sd	s5,72(sp)
 6c2:	e0da                	sd	s6,64(sp)
 6c4:	fc5e                	sd	s7,56(sp)
 6c6:	f862                	sd	s8,48(sp)
 6c8:	f466                	sd	s9,40(sp)
 6ca:	f06a                	sd	s10,32(sp)
 6cc:	ec6e                	sd	s11,24(sp)
 6ce:	0100                	addi	s0,sp,128
 6d0:	0005c903          	lbu	s2,0(a1)
 6d4:	18090f63          	beqz	s2,872 <vprintf+0x1c0>
 6d8:	8aaa                	mv	s5,a0
 6da:	8b32                	mv	s6,a2
 6dc:	00158493          	addi	s1,a1,1
 6e0:	4981                	li	s3,0
 6e2:	02500a13          	li	s4,37
 6e6:	06400c13          	li	s8,100
 6ea:	06c00c93          	li	s9,108
 6ee:	07800d13          	li	s10,120
 6f2:	07000d93          	li	s11,112
 6f6:	00000b97          	auipc	s7,0x0
 6fa:	3aab8b93          	addi	s7,s7,938 # aa0 <digits>
 6fe:	a839                	j	71c <vprintf+0x6a>
 700:	85ca                	mv	a1,s2
 702:	8556                	mv	a0,s5
 704:	00000097          	auipc	ra,0x0
 708:	ee2080e7          	jalr	-286(ra) # 5e6 <putc>
 70c:	a019                	j	712 <vprintf+0x60>
 70e:	01498f63          	beq	s3,s4,72c <vprintf+0x7a>
 712:	0485                	addi	s1,s1,1
 714:	fff4c903          	lbu	s2,-1(s1)
 718:	14090d63          	beqz	s2,872 <vprintf+0x1c0>
 71c:	0009079b          	sext.w	a5,s2
 720:	fe0997e3          	bnez	s3,70e <vprintf+0x5c>
 724:	fd479ee3          	bne	a5,s4,700 <vprintf+0x4e>
 728:	89be                	mv	s3,a5
 72a:	b7e5                	j	712 <vprintf+0x60>
 72c:	05878063          	beq	a5,s8,76c <vprintf+0xba>
 730:	05978c63          	beq	a5,s9,788 <vprintf+0xd6>
 734:	07a78863          	beq	a5,s10,7a4 <vprintf+0xf2>
 738:	09b78463          	beq	a5,s11,7c0 <vprintf+0x10e>
 73c:	07300713          	li	a4,115
 740:	0ce78663          	beq	a5,a4,80c <vprintf+0x15a>
 744:	06300713          	li	a4,99
 748:	0ee78e63          	beq	a5,a4,844 <vprintf+0x192>
 74c:	11478863          	beq	a5,s4,85c <vprintf+0x1aa>
 750:	85d2                	mv	a1,s4
 752:	8556                	mv	a0,s5
 754:	00000097          	auipc	ra,0x0
 758:	e92080e7          	jalr	-366(ra) # 5e6 <putc>
 75c:	85ca                	mv	a1,s2
 75e:	8556                	mv	a0,s5
 760:	00000097          	auipc	ra,0x0
 764:	e86080e7          	jalr	-378(ra) # 5e6 <putc>
 768:	4981                	li	s3,0
 76a:	b765                	j	712 <vprintf+0x60>
 76c:	008b0913          	addi	s2,s6,8
 770:	4685                	li	a3,1
 772:	4629                	li	a2,10
 774:	000b2583          	lw	a1,0(s6)
 778:	8556                	mv	a0,s5
 77a:	00000097          	auipc	ra,0x0
 77e:	e8e080e7          	jalr	-370(ra) # 608 <printint>
 782:	8b4a                	mv	s6,s2
 784:	4981                	li	s3,0
 786:	b771                	j	712 <vprintf+0x60>
 788:	008b0913          	addi	s2,s6,8
 78c:	4681                	li	a3,0
 78e:	4629                	li	a2,10
 790:	000b2583          	lw	a1,0(s6)
 794:	8556                	mv	a0,s5
 796:	00000097          	auipc	ra,0x0
 79a:	e72080e7          	jalr	-398(ra) # 608 <printint>
 79e:	8b4a                	mv	s6,s2
 7a0:	4981                	li	s3,0
 7a2:	bf85                	j	712 <vprintf+0x60>
 7a4:	008b0913          	addi	s2,s6,8
 7a8:	4681                	li	a3,0
 7aa:	4641                	li	a2,16
 7ac:	000b2583          	lw	a1,0(s6)
 7b0:	8556                	mv	a0,s5
 7b2:	00000097          	auipc	ra,0x0
 7b6:	e56080e7          	jalr	-426(ra) # 608 <printint>
 7ba:	8b4a                	mv	s6,s2
 7bc:	4981                	li	s3,0
 7be:	bf91                	j	712 <vprintf+0x60>
 7c0:	008b0793          	addi	a5,s6,8
 7c4:	f8f43423          	sd	a5,-120(s0)
 7c8:	000b3983          	ld	s3,0(s6)
 7cc:	03000593          	li	a1,48
 7d0:	8556                	mv	a0,s5
 7d2:	00000097          	auipc	ra,0x0
 7d6:	e14080e7          	jalr	-492(ra) # 5e6 <putc>
 7da:	85ea                	mv	a1,s10
 7dc:	8556                	mv	a0,s5
 7de:	00000097          	auipc	ra,0x0
 7e2:	e08080e7          	jalr	-504(ra) # 5e6 <putc>
 7e6:	4941                	li	s2,16
 7e8:	03c9d793          	srli	a5,s3,0x3c
 7ec:	97de                	add	a5,a5,s7
 7ee:	0007c583          	lbu	a1,0(a5)
 7f2:	8556                	mv	a0,s5
 7f4:	00000097          	auipc	ra,0x0
 7f8:	df2080e7          	jalr	-526(ra) # 5e6 <putc>
 7fc:	0992                	slli	s3,s3,0x4
 7fe:	397d                	addiw	s2,s2,-1
 800:	fe0914e3          	bnez	s2,7e8 <vprintf+0x136>
 804:	f8843b03          	ld	s6,-120(s0)
 808:	4981                	li	s3,0
 80a:	b721                	j	712 <vprintf+0x60>
 80c:	008b0993          	addi	s3,s6,8
 810:	000b3903          	ld	s2,0(s6)
 814:	02090163          	beqz	s2,836 <vprintf+0x184>
 818:	00094583          	lbu	a1,0(s2)
 81c:	c9a1                	beqz	a1,86c <vprintf+0x1ba>
 81e:	8556                	mv	a0,s5
 820:	00000097          	auipc	ra,0x0
 824:	dc6080e7          	jalr	-570(ra) # 5e6 <putc>
 828:	0905                	addi	s2,s2,1
 82a:	00094583          	lbu	a1,0(s2)
 82e:	f9e5                	bnez	a1,81e <vprintf+0x16c>
 830:	8b4e                	mv	s6,s3
 832:	4981                	li	s3,0
 834:	bdf9                	j	712 <vprintf+0x60>
 836:	00000917          	auipc	s2,0x0
 83a:	26290913          	addi	s2,s2,610 # a98 <malloc+0x11c>
 83e:	02800593          	li	a1,40
 842:	bff1                	j	81e <vprintf+0x16c>
 844:	008b0913          	addi	s2,s6,8
 848:	000b4583          	lbu	a1,0(s6)
 84c:	8556                	mv	a0,s5
 84e:	00000097          	auipc	ra,0x0
 852:	d98080e7          	jalr	-616(ra) # 5e6 <putc>
 856:	8b4a                	mv	s6,s2
 858:	4981                	li	s3,0
 85a:	bd65                	j	712 <vprintf+0x60>
 85c:	85d2                	mv	a1,s4
 85e:	8556                	mv	a0,s5
 860:	00000097          	auipc	ra,0x0
 864:	d86080e7          	jalr	-634(ra) # 5e6 <putc>
 868:	4981                	li	s3,0
 86a:	b565                	j	712 <vprintf+0x60>
 86c:	8b4e                	mv	s6,s3
 86e:	4981                	li	s3,0
 870:	b54d                	j	712 <vprintf+0x60>
 872:	70e6                	ld	ra,120(sp)
 874:	7446                	ld	s0,112(sp)
 876:	74a6                	ld	s1,104(sp)
 878:	7906                	ld	s2,96(sp)
 87a:	69e6                	ld	s3,88(sp)
 87c:	6a46                	ld	s4,80(sp)
 87e:	6aa6                	ld	s5,72(sp)
 880:	6b06                	ld	s6,64(sp)
 882:	7be2                	ld	s7,56(sp)
 884:	7c42                	ld	s8,48(sp)
 886:	7ca2                	ld	s9,40(sp)
 888:	7d02                	ld	s10,32(sp)
 88a:	6de2                	ld	s11,24(sp)
 88c:	6109                	addi	sp,sp,128
 88e:	8082                	ret

0000000000000890 <fprintf>:
 890:	715d                	addi	sp,sp,-80
 892:	ec06                	sd	ra,24(sp)
 894:	e822                	sd	s0,16(sp)
 896:	1000                	addi	s0,sp,32
 898:	e010                	sd	a2,0(s0)
 89a:	e414                	sd	a3,8(s0)
 89c:	e818                	sd	a4,16(s0)
 89e:	ec1c                	sd	a5,24(s0)
 8a0:	03043023          	sd	a6,32(s0)
 8a4:	03143423          	sd	a7,40(s0)
 8a8:	fe843423          	sd	s0,-24(s0)
 8ac:	8622                	mv	a2,s0
 8ae:	00000097          	auipc	ra,0x0
 8b2:	e04080e7          	jalr	-508(ra) # 6b2 <vprintf>
 8b6:	60e2                	ld	ra,24(sp)
 8b8:	6442                	ld	s0,16(sp)
 8ba:	6161                	addi	sp,sp,80
 8bc:	8082                	ret

00000000000008be <printf>:
 8be:	711d                	addi	sp,sp,-96
 8c0:	ec06                	sd	ra,24(sp)
 8c2:	e822                	sd	s0,16(sp)
 8c4:	1000                	addi	s0,sp,32
 8c6:	e40c                	sd	a1,8(s0)
 8c8:	e810                	sd	a2,16(s0)
 8ca:	ec14                	sd	a3,24(s0)
 8cc:	f018                	sd	a4,32(s0)
 8ce:	f41c                	sd	a5,40(s0)
 8d0:	03043823          	sd	a6,48(s0)
 8d4:	03143c23          	sd	a7,56(s0)
 8d8:	00840613          	addi	a2,s0,8
 8dc:	fec43423          	sd	a2,-24(s0)
 8e0:	85aa                	mv	a1,a0
 8e2:	4505                	li	a0,1
 8e4:	00000097          	auipc	ra,0x0
 8e8:	dce080e7          	jalr	-562(ra) # 6b2 <vprintf>
 8ec:	60e2                	ld	ra,24(sp)
 8ee:	6442                	ld	s0,16(sp)
 8f0:	6125                	addi	sp,sp,96
 8f2:	8082                	ret

00000000000008f4 <free>:
 8f4:	1141                	addi	sp,sp,-16
 8f6:	e422                	sd	s0,8(sp)
 8f8:	0800                	addi	s0,sp,16
 8fa:	ff050693          	addi	a3,a0,-16
 8fe:	00000797          	auipc	a5,0x0
 902:	7027b783          	ld	a5,1794(a5) # 1000 <freep>
 906:	a805                	j	936 <free+0x42>
 908:	4618                	lw	a4,8(a2)
 90a:	9db9                	addw	a1,a1,a4
 90c:	feb52c23          	sw	a1,-8(a0)
 910:	6398                	ld	a4,0(a5)
 912:	6318                	ld	a4,0(a4)
 914:	fee53823          	sd	a4,-16(a0)
 918:	a091                	j	95c <free+0x68>
 91a:	ff852703          	lw	a4,-8(a0)
 91e:	9e39                	addw	a2,a2,a4
 920:	c790                	sw	a2,8(a5)
 922:	ff053703          	ld	a4,-16(a0)
 926:	e398                	sd	a4,0(a5)
 928:	a099                	j	96e <free+0x7a>
 92a:	6398                	ld	a4,0(a5)
 92c:	00e7e463          	bltu	a5,a4,934 <free+0x40>
 930:	00e6ea63          	bltu	a3,a4,944 <free+0x50>
 934:	87ba                	mv	a5,a4
 936:	fed7fae3          	bgeu	a5,a3,92a <free+0x36>
 93a:	6398                	ld	a4,0(a5)
 93c:	00e6e463          	bltu	a3,a4,944 <free+0x50>
 940:	fee7eae3          	bltu	a5,a4,934 <free+0x40>
 944:	ff852583          	lw	a1,-8(a0)
 948:	6390                	ld	a2,0(a5)
 94a:	02059713          	slli	a4,a1,0x20
 94e:	9301                	srli	a4,a4,0x20
 950:	0712                	slli	a4,a4,0x4
 952:	9736                	add	a4,a4,a3
 954:	fae60ae3          	beq	a2,a4,908 <free+0x14>
 958:	fec53823          	sd	a2,-16(a0)
 95c:	4790                	lw	a2,8(a5)
 95e:	02061713          	slli	a4,a2,0x20
 962:	9301                	srli	a4,a4,0x20
 964:	0712                	slli	a4,a4,0x4
 966:	973e                	add	a4,a4,a5
 968:	fae689e3          	beq	a3,a4,91a <free+0x26>
 96c:	e394                	sd	a3,0(a5)
 96e:	00000717          	auipc	a4,0x0
 972:	68f73923          	sd	a5,1682(a4) # 1000 <freep>
 976:	6422                	ld	s0,8(sp)
 978:	0141                	addi	sp,sp,16
 97a:	8082                	ret

000000000000097c <malloc>:
 97c:	7139                	addi	sp,sp,-64
 97e:	fc06                	sd	ra,56(sp)
 980:	f822                	sd	s0,48(sp)
 982:	f426                	sd	s1,40(sp)
 984:	f04a                	sd	s2,32(sp)
 986:	ec4e                	sd	s3,24(sp)
 988:	e852                	sd	s4,16(sp)
 98a:	e456                	sd	s5,8(sp)
 98c:	e05a                	sd	s6,0(sp)
 98e:	0080                	addi	s0,sp,64
 990:	02051493          	slli	s1,a0,0x20
 994:	9081                	srli	s1,s1,0x20
 996:	04bd                	addi	s1,s1,15
 998:	8091                	srli	s1,s1,0x4
 99a:	0014899b          	addiw	s3,s1,1
 99e:	0485                	addi	s1,s1,1
 9a0:	00000517          	auipc	a0,0x0
 9a4:	66053503          	ld	a0,1632(a0) # 1000 <freep>
 9a8:	c515                	beqz	a0,9d4 <malloc+0x58>
 9aa:	611c                	ld	a5,0(a0)
 9ac:	4798                	lw	a4,8(a5)
 9ae:	02977f63          	bgeu	a4,s1,9ec <malloc+0x70>
 9b2:	8a4e                	mv	s4,s3
 9b4:	0009871b          	sext.w	a4,s3
 9b8:	6685                	lui	a3,0x1
 9ba:	00d77363          	bgeu	a4,a3,9c0 <malloc+0x44>
 9be:	6a05                	lui	s4,0x1
 9c0:	000a0b1b          	sext.w	s6,s4
 9c4:	004a1a1b          	slliw	s4,s4,0x4
 9c8:	00000917          	auipc	s2,0x0
 9cc:	63890913          	addi	s2,s2,1592 # 1000 <freep>
 9d0:	5afd                	li	s5,-1
 9d2:	a88d                	j	a44 <malloc+0xc8>
 9d4:	00001797          	auipc	a5,0x1
 9d8:	a3c78793          	addi	a5,a5,-1476 # 1410 <base>
 9dc:	00000717          	auipc	a4,0x0
 9e0:	62f73223          	sd	a5,1572(a4) # 1000 <freep>
 9e4:	e39c                	sd	a5,0(a5)
 9e6:	0007a423          	sw	zero,8(a5)
 9ea:	b7e1                	j	9b2 <malloc+0x36>
 9ec:	02e48b63          	beq	s1,a4,a22 <malloc+0xa6>
 9f0:	4137073b          	subw	a4,a4,s3
 9f4:	c798                	sw	a4,8(a5)
 9f6:	1702                	slli	a4,a4,0x20
 9f8:	9301                	srli	a4,a4,0x20
 9fa:	0712                	slli	a4,a4,0x4
 9fc:	97ba                	add	a5,a5,a4
 9fe:	0137a423          	sw	s3,8(a5)
 a02:	00000717          	auipc	a4,0x0
 a06:	5ea73f23          	sd	a0,1534(a4) # 1000 <freep>
 a0a:	01078513          	addi	a0,a5,16
 a0e:	70e2                	ld	ra,56(sp)
 a10:	7442                	ld	s0,48(sp)
 a12:	74a2                	ld	s1,40(sp)
 a14:	7902                	ld	s2,32(sp)
 a16:	69e2                	ld	s3,24(sp)
 a18:	6a42                	ld	s4,16(sp)
 a1a:	6aa2                	ld	s5,8(sp)
 a1c:	6b02                	ld	s6,0(sp)
 a1e:	6121                	addi	sp,sp,64
 a20:	8082                	ret
 a22:	6398                	ld	a4,0(a5)
 a24:	e118                	sd	a4,0(a0)
 a26:	bff1                	j	a02 <malloc+0x86>
 a28:	01652423          	sw	s6,8(a0)
 a2c:	0541                	addi	a0,a0,16
 a2e:	00000097          	auipc	ra,0x0
 a32:	ec6080e7          	jalr	-314(ra) # 8f4 <free>
 a36:	00093503          	ld	a0,0(s2)
 a3a:	d971                	beqz	a0,a0e <malloc+0x92>
 a3c:	611c                	ld	a5,0(a0)
 a3e:	4798                	lw	a4,8(a5)
 a40:	fa9776e3          	bgeu	a4,s1,9ec <malloc+0x70>
 a44:	00093703          	ld	a4,0(s2)
 a48:	853e                	mv	a0,a5
 a4a:	fef719e3          	bne	a4,a5,a3c <malloc+0xc0>
 a4e:	8552                	mv	a0,s4
 a50:	00000097          	auipc	ra,0x0
 a54:	b76080e7          	jalr	-1162(ra) # 5c6 <sbrk>
 a58:	fd5518e3          	bne	a0,s5,a28 <malloc+0xac>
 a5c:	4501                	li	a0,0
 a5e:	bf45                	j	a0e <malloc+0x92>
