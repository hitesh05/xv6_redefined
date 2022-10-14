
user/_ln:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
  if(argc != 3){
   a:	478d                	li	a5,3
   c:	02f50063          	beq	a0,a5,2c <main+0x2c>
    fprintf(2, "Usage: ln old new\n");
  10:	00001597          	auipc	a1,0x1
  14:	83058593          	addi	a1,a1,-2000 # 840 <malloc+0xf2>
  18:	4509                	li	a0,2
  1a:	00000097          	auipc	ra,0x0
  1e:	648080e7          	jalr	1608(ra) # 662 <fprintf>
    exit(1);
  22:	4505                	li	a0,1
  24:	00000097          	auipc	ra,0x0
  28:	2cc080e7          	jalr	716(ra) # 2f0 <exit>
  2c:	84ae                	mv	s1,a1
  }
  if(link(argv[1], argv[2]) < 0)
  2e:	698c                	ld	a1,16(a1)
  30:	6488                	ld	a0,8(s1)
  32:	00000097          	auipc	ra,0x0
  36:	31e080e7          	jalr	798(ra) # 350 <link>
  3a:	00054763          	bltz	a0,48 <main+0x48>
    fprintf(2, "link %s %s: failed\n", argv[1], argv[2]);
  exit(0);
  3e:	4501                	li	a0,0
  40:	00000097          	auipc	ra,0x0
  44:	2b0080e7          	jalr	688(ra) # 2f0 <exit>
    fprintf(2, "link %s %s: failed\n", argv[1], argv[2]);
  48:	6894                	ld	a3,16(s1)
  4a:	6490                	ld	a2,8(s1)
  4c:	00001597          	auipc	a1,0x1
  50:	80c58593          	addi	a1,a1,-2036 # 858 <malloc+0x10a>
  54:	4509                	li	a0,2
  56:	00000097          	auipc	ra,0x0
  5a:	60c080e7          	jalr	1548(ra) # 662 <fprintf>
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

0000000000000398 <setpriority>:
 398:	48e1                	li	a7,24
 39a:	00000073          	ecall
 39e:	8082                	ret

00000000000003a0 <waitx>:
 3a0:	48e9                	li	a7,26
 3a2:	00000073          	ecall
 3a6:	8082                	ret

00000000000003a8 <sigalarm>:
 3a8:	48dd                	li	a7,23
 3aa:	00000073          	ecall
 3ae:	8082                	ret

00000000000003b0 <sigreturn>:
 3b0:	48ed                	li	a7,27
 3b2:	00000073          	ecall
 3b6:	8082                	ret

00000000000003b8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3b8:	1101                	addi	sp,sp,-32
 3ba:	ec06                	sd	ra,24(sp)
 3bc:	e822                	sd	s0,16(sp)
 3be:	1000                	addi	s0,sp,32
 3c0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3c4:	4605                	li	a2,1
 3c6:	fef40593          	addi	a1,s0,-17
 3ca:	00000097          	auipc	ra,0x0
 3ce:	f46080e7          	jalr	-186(ra) # 310 <write>
}
 3d2:	60e2                	ld	ra,24(sp)
 3d4:	6442                	ld	s0,16(sp)
 3d6:	6105                	addi	sp,sp,32
 3d8:	8082                	ret

00000000000003da <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3da:	7139                	addi	sp,sp,-64
 3dc:	fc06                	sd	ra,56(sp)
 3de:	f822                	sd	s0,48(sp)
 3e0:	f426                	sd	s1,40(sp)
 3e2:	f04a                	sd	s2,32(sp)
 3e4:	ec4e                	sd	s3,24(sp)
 3e6:	0080                	addi	s0,sp,64
 3e8:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3ea:	c299                	beqz	a3,3f0 <printint+0x16>
 3ec:	0805c863          	bltz	a1,47c <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3f0:	2581                	sext.w	a1,a1
  neg = 0;
 3f2:	4881                	li	a7,0
 3f4:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3f8:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3fa:	2601                	sext.w	a2,a2
 3fc:	00000517          	auipc	a0,0x0
 400:	47c50513          	addi	a0,a0,1148 # 878 <digits>
 404:	883a                	mv	a6,a4
 406:	2705                	addiw	a4,a4,1
 408:	02c5f7bb          	remuw	a5,a1,a2
 40c:	1782                	slli	a5,a5,0x20
 40e:	9381                	srli	a5,a5,0x20
 410:	97aa                	add	a5,a5,a0
 412:	0007c783          	lbu	a5,0(a5)
 416:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 41a:	0005879b          	sext.w	a5,a1
 41e:	02c5d5bb          	divuw	a1,a1,a2
 422:	0685                	addi	a3,a3,1
 424:	fec7f0e3          	bgeu	a5,a2,404 <printint+0x2a>
  if(neg)
 428:	00088b63          	beqz	a7,43e <printint+0x64>
    buf[i++] = '-';
 42c:	fd040793          	addi	a5,s0,-48
 430:	973e                	add	a4,a4,a5
 432:	02d00793          	li	a5,45
 436:	fef70823          	sb	a5,-16(a4)
 43a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 43e:	02e05863          	blez	a4,46e <printint+0x94>
 442:	fc040793          	addi	a5,s0,-64
 446:	00e78933          	add	s2,a5,a4
 44a:	fff78993          	addi	s3,a5,-1
 44e:	99ba                	add	s3,s3,a4
 450:	377d                	addiw	a4,a4,-1
 452:	1702                	slli	a4,a4,0x20
 454:	9301                	srli	a4,a4,0x20
 456:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 45a:	fff94583          	lbu	a1,-1(s2)
 45e:	8526                	mv	a0,s1
 460:	00000097          	auipc	ra,0x0
 464:	f58080e7          	jalr	-168(ra) # 3b8 <putc>
  while(--i >= 0)
 468:	197d                	addi	s2,s2,-1
 46a:	ff3918e3          	bne	s2,s3,45a <printint+0x80>
}
 46e:	70e2                	ld	ra,56(sp)
 470:	7442                	ld	s0,48(sp)
 472:	74a2                	ld	s1,40(sp)
 474:	7902                	ld	s2,32(sp)
 476:	69e2                	ld	s3,24(sp)
 478:	6121                	addi	sp,sp,64
 47a:	8082                	ret
    x = -xx;
 47c:	40b005bb          	negw	a1,a1
    neg = 1;
 480:	4885                	li	a7,1
    x = -xx;
 482:	bf8d                	j	3f4 <printint+0x1a>

0000000000000484 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 484:	7119                	addi	sp,sp,-128
 486:	fc86                	sd	ra,120(sp)
 488:	f8a2                	sd	s0,112(sp)
 48a:	f4a6                	sd	s1,104(sp)
 48c:	f0ca                	sd	s2,96(sp)
 48e:	ecce                	sd	s3,88(sp)
 490:	e8d2                	sd	s4,80(sp)
 492:	e4d6                	sd	s5,72(sp)
 494:	e0da                	sd	s6,64(sp)
 496:	fc5e                	sd	s7,56(sp)
 498:	f862                	sd	s8,48(sp)
 49a:	f466                	sd	s9,40(sp)
 49c:	f06a                	sd	s10,32(sp)
 49e:	ec6e                	sd	s11,24(sp)
 4a0:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4a2:	0005c903          	lbu	s2,0(a1)
 4a6:	18090f63          	beqz	s2,644 <vprintf+0x1c0>
 4aa:	8aaa                	mv	s5,a0
 4ac:	8b32                	mv	s6,a2
 4ae:	00158493          	addi	s1,a1,1
  state = 0;
 4b2:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4b4:	02500a13          	li	s4,37
      if(c == 'd'){
 4b8:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 4bc:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 4c0:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 4c4:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4c8:	00000b97          	auipc	s7,0x0
 4cc:	3b0b8b93          	addi	s7,s7,944 # 878 <digits>
 4d0:	a839                	j	4ee <vprintf+0x6a>
        putc(fd, c);
 4d2:	85ca                	mv	a1,s2
 4d4:	8556                	mv	a0,s5
 4d6:	00000097          	auipc	ra,0x0
 4da:	ee2080e7          	jalr	-286(ra) # 3b8 <putc>
 4de:	a019                	j	4e4 <vprintf+0x60>
    } else if(state == '%'){
 4e0:	01498f63          	beq	s3,s4,4fe <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4e4:	0485                	addi	s1,s1,1
 4e6:	fff4c903          	lbu	s2,-1(s1)
 4ea:	14090d63          	beqz	s2,644 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 4ee:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4f2:	fe0997e3          	bnez	s3,4e0 <vprintf+0x5c>
      if(c == '%'){
 4f6:	fd479ee3          	bne	a5,s4,4d2 <vprintf+0x4e>
        state = '%';
 4fa:	89be                	mv	s3,a5
 4fc:	b7e5                	j	4e4 <vprintf+0x60>
      if(c == 'd'){
 4fe:	05878063          	beq	a5,s8,53e <vprintf+0xba>
      } else if(c == 'l') {
 502:	05978c63          	beq	a5,s9,55a <vprintf+0xd6>
      } else if(c == 'x') {
 506:	07a78863          	beq	a5,s10,576 <vprintf+0xf2>
      } else if(c == 'p') {
 50a:	09b78463          	beq	a5,s11,592 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 50e:	07300713          	li	a4,115
 512:	0ce78663          	beq	a5,a4,5de <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 516:	06300713          	li	a4,99
 51a:	0ee78e63          	beq	a5,a4,616 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 51e:	11478863          	beq	a5,s4,62e <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 522:	85d2                	mv	a1,s4
 524:	8556                	mv	a0,s5
 526:	00000097          	auipc	ra,0x0
 52a:	e92080e7          	jalr	-366(ra) # 3b8 <putc>
        putc(fd, c);
 52e:	85ca                	mv	a1,s2
 530:	8556                	mv	a0,s5
 532:	00000097          	auipc	ra,0x0
 536:	e86080e7          	jalr	-378(ra) # 3b8 <putc>
      }
      state = 0;
 53a:	4981                	li	s3,0
 53c:	b765                	j	4e4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 53e:	008b0913          	addi	s2,s6,8
 542:	4685                	li	a3,1
 544:	4629                	li	a2,10
 546:	000b2583          	lw	a1,0(s6)
 54a:	8556                	mv	a0,s5
 54c:	00000097          	auipc	ra,0x0
 550:	e8e080e7          	jalr	-370(ra) # 3da <printint>
 554:	8b4a                	mv	s6,s2
      state = 0;
 556:	4981                	li	s3,0
 558:	b771                	j	4e4 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 55a:	008b0913          	addi	s2,s6,8
 55e:	4681                	li	a3,0
 560:	4629                	li	a2,10
 562:	000b2583          	lw	a1,0(s6)
 566:	8556                	mv	a0,s5
 568:	00000097          	auipc	ra,0x0
 56c:	e72080e7          	jalr	-398(ra) # 3da <printint>
 570:	8b4a                	mv	s6,s2
      state = 0;
 572:	4981                	li	s3,0
 574:	bf85                	j	4e4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 576:	008b0913          	addi	s2,s6,8
 57a:	4681                	li	a3,0
 57c:	4641                	li	a2,16
 57e:	000b2583          	lw	a1,0(s6)
 582:	8556                	mv	a0,s5
 584:	00000097          	auipc	ra,0x0
 588:	e56080e7          	jalr	-426(ra) # 3da <printint>
 58c:	8b4a                	mv	s6,s2
      state = 0;
 58e:	4981                	li	s3,0
 590:	bf91                	j	4e4 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 592:	008b0793          	addi	a5,s6,8
 596:	f8f43423          	sd	a5,-120(s0)
 59a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 59e:	03000593          	li	a1,48
 5a2:	8556                	mv	a0,s5
 5a4:	00000097          	auipc	ra,0x0
 5a8:	e14080e7          	jalr	-492(ra) # 3b8 <putc>
  putc(fd, 'x');
 5ac:	85ea                	mv	a1,s10
 5ae:	8556                	mv	a0,s5
 5b0:	00000097          	auipc	ra,0x0
 5b4:	e08080e7          	jalr	-504(ra) # 3b8 <putc>
 5b8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5ba:	03c9d793          	srli	a5,s3,0x3c
 5be:	97de                	add	a5,a5,s7
 5c0:	0007c583          	lbu	a1,0(a5)
 5c4:	8556                	mv	a0,s5
 5c6:	00000097          	auipc	ra,0x0
 5ca:	df2080e7          	jalr	-526(ra) # 3b8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5ce:	0992                	slli	s3,s3,0x4
 5d0:	397d                	addiw	s2,s2,-1
 5d2:	fe0914e3          	bnez	s2,5ba <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 5d6:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 5da:	4981                	li	s3,0
 5dc:	b721                	j	4e4 <vprintf+0x60>
        s = va_arg(ap, char*);
 5de:	008b0993          	addi	s3,s6,8
 5e2:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 5e6:	02090163          	beqz	s2,608 <vprintf+0x184>
        while(*s != 0){
 5ea:	00094583          	lbu	a1,0(s2)
 5ee:	c9a1                	beqz	a1,63e <vprintf+0x1ba>
          putc(fd, *s);
 5f0:	8556                	mv	a0,s5
 5f2:	00000097          	auipc	ra,0x0
 5f6:	dc6080e7          	jalr	-570(ra) # 3b8 <putc>
          s++;
 5fa:	0905                	addi	s2,s2,1
        while(*s != 0){
 5fc:	00094583          	lbu	a1,0(s2)
 600:	f9e5                	bnez	a1,5f0 <vprintf+0x16c>
        s = va_arg(ap, char*);
 602:	8b4e                	mv	s6,s3
      state = 0;
 604:	4981                	li	s3,0
 606:	bdf9                	j	4e4 <vprintf+0x60>
          s = "(null)";
 608:	00000917          	auipc	s2,0x0
 60c:	26890913          	addi	s2,s2,616 # 870 <malloc+0x122>
        while(*s != 0){
 610:	02800593          	li	a1,40
 614:	bff1                	j	5f0 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 616:	008b0913          	addi	s2,s6,8
 61a:	000b4583          	lbu	a1,0(s6)
 61e:	8556                	mv	a0,s5
 620:	00000097          	auipc	ra,0x0
 624:	d98080e7          	jalr	-616(ra) # 3b8 <putc>
 628:	8b4a                	mv	s6,s2
      state = 0;
 62a:	4981                	li	s3,0
 62c:	bd65                	j	4e4 <vprintf+0x60>
        putc(fd, c);
 62e:	85d2                	mv	a1,s4
 630:	8556                	mv	a0,s5
 632:	00000097          	auipc	ra,0x0
 636:	d86080e7          	jalr	-634(ra) # 3b8 <putc>
      state = 0;
 63a:	4981                	li	s3,0
 63c:	b565                	j	4e4 <vprintf+0x60>
        s = va_arg(ap, char*);
 63e:	8b4e                	mv	s6,s3
      state = 0;
 640:	4981                	li	s3,0
 642:	b54d                	j	4e4 <vprintf+0x60>
    }
  }
}
 644:	70e6                	ld	ra,120(sp)
 646:	7446                	ld	s0,112(sp)
 648:	74a6                	ld	s1,104(sp)
 64a:	7906                	ld	s2,96(sp)
 64c:	69e6                	ld	s3,88(sp)
 64e:	6a46                	ld	s4,80(sp)
 650:	6aa6                	ld	s5,72(sp)
 652:	6b06                	ld	s6,64(sp)
 654:	7be2                	ld	s7,56(sp)
 656:	7c42                	ld	s8,48(sp)
 658:	7ca2                	ld	s9,40(sp)
 65a:	7d02                	ld	s10,32(sp)
 65c:	6de2                	ld	s11,24(sp)
 65e:	6109                	addi	sp,sp,128
 660:	8082                	ret

0000000000000662 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 662:	715d                	addi	sp,sp,-80
 664:	ec06                	sd	ra,24(sp)
 666:	e822                	sd	s0,16(sp)
 668:	1000                	addi	s0,sp,32
 66a:	e010                	sd	a2,0(s0)
 66c:	e414                	sd	a3,8(s0)
 66e:	e818                	sd	a4,16(s0)
 670:	ec1c                	sd	a5,24(s0)
 672:	03043023          	sd	a6,32(s0)
 676:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 67a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 67e:	8622                	mv	a2,s0
 680:	00000097          	auipc	ra,0x0
 684:	e04080e7          	jalr	-508(ra) # 484 <vprintf>
}
 688:	60e2                	ld	ra,24(sp)
 68a:	6442                	ld	s0,16(sp)
 68c:	6161                	addi	sp,sp,80
 68e:	8082                	ret

0000000000000690 <printf>:

void
printf(const char *fmt, ...)
{
 690:	711d                	addi	sp,sp,-96
 692:	ec06                	sd	ra,24(sp)
 694:	e822                	sd	s0,16(sp)
 696:	1000                	addi	s0,sp,32
 698:	e40c                	sd	a1,8(s0)
 69a:	e810                	sd	a2,16(s0)
 69c:	ec14                	sd	a3,24(s0)
 69e:	f018                	sd	a4,32(s0)
 6a0:	f41c                	sd	a5,40(s0)
 6a2:	03043823          	sd	a6,48(s0)
 6a6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6aa:	00840613          	addi	a2,s0,8
 6ae:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6b2:	85aa                	mv	a1,a0
 6b4:	4505                	li	a0,1
 6b6:	00000097          	auipc	ra,0x0
 6ba:	dce080e7          	jalr	-562(ra) # 484 <vprintf>
}
 6be:	60e2                	ld	ra,24(sp)
 6c0:	6442                	ld	s0,16(sp)
 6c2:	6125                	addi	sp,sp,96
 6c4:	8082                	ret

00000000000006c6 <free>:
 6c6:	1141                	addi	sp,sp,-16
 6c8:	e422                	sd	s0,8(sp)
 6ca:	0800                	addi	s0,sp,16
 6cc:	ff050693          	addi	a3,a0,-16
 6d0:	00001797          	auipc	a5,0x1
 6d4:	9307b783          	ld	a5,-1744(a5) # 1000 <freep>
 6d8:	a805                	j	708 <free+0x42>
 6da:	4618                	lw	a4,8(a2)
 6dc:	9db9                	addw	a1,a1,a4
 6de:	feb52c23          	sw	a1,-8(a0)
 6e2:	6398                	ld	a4,0(a5)
 6e4:	6318                	ld	a4,0(a4)
 6e6:	fee53823          	sd	a4,-16(a0)
 6ea:	a091                	j	72e <free+0x68>
 6ec:	ff852703          	lw	a4,-8(a0)
 6f0:	9e39                	addw	a2,a2,a4
 6f2:	c790                	sw	a2,8(a5)
 6f4:	ff053703          	ld	a4,-16(a0)
 6f8:	e398                	sd	a4,0(a5)
 6fa:	a099                	j	740 <free+0x7a>
 6fc:	6398                	ld	a4,0(a5)
 6fe:	00e7e463          	bltu	a5,a4,706 <free+0x40>
 702:	00e6ea63          	bltu	a3,a4,716 <free+0x50>
 706:	87ba                	mv	a5,a4
 708:	fed7fae3          	bgeu	a5,a3,6fc <free+0x36>
 70c:	6398                	ld	a4,0(a5)
 70e:	00e6e463          	bltu	a3,a4,716 <free+0x50>
 712:	fee7eae3          	bltu	a5,a4,706 <free+0x40>
 716:	ff852583          	lw	a1,-8(a0)
 71a:	6390                	ld	a2,0(a5)
 71c:	02059713          	slli	a4,a1,0x20
 720:	9301                	srli	a4,a4,0x20
 722:	0712                	slli	a4,a4,0x4
 724:	9736                	add	a4,a4,a3
 726:	fae60ae3          	beq	a2,a4,6da <free+0x14>
 72a:	fec53823          	sd	a2,-16(a0)
 72e:	4790                	lw	a2,8(a5)
 730:	02061713          	slli	a4,a2,0x20
 734:	9301                	srli	a4,a4,0x20
 736:	0712                	slli	a4,a4,0x4
 738:	973e                	add	a4,a4,a5
 73a:	fae689e3          	beq	a3,a4,6ec <free+0x26>
 73e:	e394                	sd	a3,0(a5)
 740:	00001717          	auipc	a4,0x1
 744:	8cf73023          	sd	a5,-1856(a4) # 1000 <freep>
 748:	6422                	ld	s0,8(sp)
 74a:	0141                	addi	sp,sp,16
 74c:	8082                	ret

000000000000074e <malloc>:
 74e:	7139                	addi	sp,sp,-64
 750:	fc06                	sd	ra,56(sp)
 752:	f822                	sd	s0,48(sp)
 754:	f426                	sd	s1,40(sp)
 756:	f04a                	sd	s2,32(sp)
 758:	ec4e                	sd	s3,24(sp)
 75a:	e852                	sd	s4,16(sp)
 75c:	e456                	sd	s5,8(sp)
 75e:	e05a                	sd	s6,0(sp)
 760:	0080                	addi	s0,sp,64
 762:	02051493          	slli	s1,a0,0x20
 766:	9081                	srli	s1,s1,0x20
 768:	04bd                	addi	s1,s1,15
 76a:	8091                	srli	s1,s1,0x4
 76c:	0014899b          	addiw	s3,s1,1
 770:	0485                	addi	s1,s1,1
 772:	00001517          	auipc	a0,0x1
 776:	88e53503          	ld	a0,-1906(a0) # 1000 <freep>
 77a:	c515                	beqz	a0,7a6 <malloc+0x58>
 77c:	611c                	ld	a5,0(a0)
 77e:	4798                	lw	a4,8(a5)
 780:	02977f63          	bgeu	a4,s1,7be <malloc+0x70>
 784:	8a4e                	mv	s4,s3
 786:	0009871b          	sext.w	a4,s3
 78a:	6685                	lui	a3,0x1
 78c:	00d77363          	bgeu	a4,a3,792 <malloc+0x44>
 790:	6a05                	lui	s4,0x1
 792:	000a0b1b          	sext.w	s6,s4
 796:	004a1a1b          	slliw	s4,s4,0x4
 79a:	00001917          	auipc	s2,0x1
 79e:	86690913          	addi	s2,s2,-1946 # 1000 <freep>
 7a2:	5afd                	li	s5,-1
 7a4:	a88d                	j	816 <malloc+0xc8>
 7a6:	00001797          	auipc	a5,0x1
 7aa:	86a78793          	addi	a5,a5,-1942 # 1010 <base>
 7ae:	00001717          	auipc	a4,0x1
 7b2:	84f73923          	sd	a5,-1966(a4) # 1000 <freep>
 7b6:	e39c                	sd	a5,0(a5)
 7b8:	0007a423          	sw	zero,8(a5)
 7bc:	b7e1                	j	784 <malloc+0x36>
 7be:	02e48b63          	beq	s1,a4,7f4 <malloc+0xa6>
 7c2:	4137073b          	subw	a4,a4,s3
 7c6:	c798                	sw	a4,8(a5)
 7c8:	1702                	slli	a4,a4,0x20
 7ca:	9301                	srli	a4,a4,0x20
 7cc:	0712                	slli	a4,a4,0x4
 7ce:	97ba                	add	a5,a5,a4
 7d0:	0137a423          	sw	s3,8(a5)
 7d4:	00001717          	auipc	a4,0x1
 7d8:	82a73623          	sd	a0,-2004(a4) # 1000 <freep>
 7dc:	01078513          	addi	a0,a5,16
 7e0:	70e2                	ld	ra,56(sp)
 7e2:	7442                	ld	s0,48(sp)
 7e4:	74a2                	ld	s1,40(sp)
 7e6:	7902                	ld	s2,32(sp)
 7e8:	69e2                	ld	s3,24(sp)
 7ea:	6a42                	ld	s4,16(sp)
 7ec:	6aa2                	ld	s5,8(sp)
 7ee:	6b02                	ld	s6,0(sp)
 7f0:	6121                	addi	sp,sp,64
 7f2:	8082                	ret
 7f4:	6398                	ld	a4,0(a5)
 7f6:	e118                	sd	a4,0(a0)
 7f8:	bff1                	j	7d4 <malloc+0x86>
 7fa:	01652423          	sw	s6,8(a0)
 7fe:	0541                	addi	a0,a0,16
 800:	00000097          	auipc	ra,0x0
 804:	ec6080e7          	jalr	-314(ra) # 6c6 <free>
 808:	00093503          	ld	a0,0(s2)
 80c:	d971                	beqz	a0,7e0 <malloc+0x92>
 80e:	611c                	ld	a5,0(a0)
 810:	4798                	lw	a4,8(a5)
 812:	fa9776e3          	bgeu	a4,s1,7be <malloc+0x70>
 816:	00093703          	ld	a4,0(s2)
 81a:	853e                	mv	a0,a5
 81c:	fef719e3          	bne	a4,a5,80e <malloc+0xc0>
 820:	8552                	mv	a0,s4
 822:	00000097          	auipc	ra,0x0
 826:	b56080e7          	jalr	-1194(ra) # 378 <sbrk>
 82a:	fd5518e3          	bne	a0,s5,7fa <malloc+0xac>
 82e:	4501                	li	a0,0
 830:	bf45                	j	7e0 <malloc+0x92>
