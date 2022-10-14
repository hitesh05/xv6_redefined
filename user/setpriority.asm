
user/_setpriority:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "../kernel/stat.h"
#include "../user/user.h"
#include "../kernel/fcntl.h"

int main(int argc,char **argv)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
    if(argc < 3)
   c:	4789                	li	a5,2
   e:	00a7cf63          	blt	a5,a0,2c <main+0x2c>
    {
        printf("Invalid command\n");
  12:	00001517          	auipc	a0,0x1
  16:	80e50513          	addi	a0,a0,-2034 # 820 <malloc+0xe8>
  1a:	00000097          	auipc	ra,0x0
  1e:	660080e7          	jalr	1632(ra) # 67a <printf>
        exit(0);
  22:	4501                	li	a0,0
  24:	00000097          	auipc	ra,0x0
  28:	2c6080e7          	jalr	710(ra) # 2ea <exit>
  2c:	84ae                	mv	s1,a1
    }
    int new_priority = atoi(argv[1]);
  2e:	6588                	ld	a0,8(a1)
  30:	00000097          	auipc	ra,0x0
  34:	1ba080e7          	jalr	442(ra) # 1ea <atoi>
  38:	892a                	mv	s2,a0
    int pid = atoi(argv[2]);
  3a:	6888                	ld	a0,16(s1)
  3c:	00000097          	auipc	ra,0x0
  40:	1ae080e7          	jalr	430(ra) # 1ea <atoi>
  44:	85aa                	mv	a1,a0
    setpriority(new_priority,pid);
  46:	854a                	mv	a0,s2
  48:	00000097          	auipc	ra,0x0
  4c:	34a080e7          	jalr	842(ra) # 392 <setpriority>
    exit(0);
  50:	4501                	li	a0,0
  52:	00000097          	auipc	ra,0x0
  56:	298080e7          	jalr	664(ra) # 2ea <exit>

000000000000005a <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  5a:	1141                	addi	sp,sp,-16
  5c:	e406                	sd	ra,8(sp)
  5e:	e022                	sd	s0,0(sp)
  60:	0800                	addi	s0,sp,16
  extern int main();
  main();
  62:	00000097          	auipc	ra,0x0
  66:	f9e080e7          	jalr	-98(ra) # 0 <main>
  exit(0);
  6a:	4501                	li	a0,0
  6c:	00000097          	auipc	ra,0x0
  70:	27e080e7          	jalr	638(ra) # 2ea <exit>

0000000000000074 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  74:	1141                	addi	sp,sp,-16
  76:	e422                	sd	s0,8(sp)
  78:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  7a:	87aa                	mv	a5,a0
  7c:	0585                	addi	a1,a1,1
  7e:	0785                	addi	a5,a5,1
  80:	fff5c703          	lbu	a4,-1(a1)
  84:	fee78fa3          	sb	a4,-1(a5)
  88:	fb75                	bnez	a4,7c <strcpy+0x8>
    ;
  return os;
}
  8a:	6422                	ld	s0,8(sp)
  8c:	0141                	addi	sp,sp,16
  8e:	8082                	ret

0000000000000090 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  90:	1141                	addi	sp,sp,-16
  92:	e422                	sd	s0,8(sp)
  94:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  96:	00054783          	lbu	a5,0(a0)
  9a:	cb91                	beqz	a5,ae <strcmp+0x1e>
  9c:	0005c703          	lbu	a4,0(a1)
  a0:	00f71763          	bne	a4,a5,ae <strcmp+0x1e>
    p++, q++;
  a4:	0505                	addi	a0,a0,1
  a6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  a8:	00054783          	lbu	a5,0(a0)
  ac:	fbe5                	bnez	a5,9c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  ae:	0005c503          	lbu	a0,0(a1)
}
  b2:	40a7853b          	subw	a0,a5,a0
  b6:	6422                	ld	s0,8(sp)
  b8:	0141                	addi	sp,sp,16
  ba:	8082                	ret

00000000000000bc <strlen>:

uint
strlen(const char *s)
{
  bc:	1141                	addi	sp,sp,-16
  be:	e422                	sd	s0,8(sp)
  c0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  c2:	00054783          	lbu	a5,0(a0)
  c6:	cf91                	beqz	a5,e2 <strlen+0x26>
  c8:	0505                	addi	a0,a0,1
  ca:	87aa                	mv	a5,a0
  cc:	4685                	li	a3,1
  ce:	9e89                	subw	a3,a3,a0
  d0:	00f6853b          	addw	a0,a3,a5
  d4:	0785                	addi	a5,a5,1
  d6:	fff7c703          	lbu	a4,-1(a5)
  da:	fb7d                	bnez	a4,d0 <strlen+0x14>
    ;
  return n;
}
  dc:	6422                	ld	s0,8(sp)
  de:	0141                	addi	sp,sp,16
  e0:	8082                	ret
  for(n = 0; s[n]; n++)
  e2:	4501                	li	a0,0
  e4:	bfe5                	j	dc <strlen+0x20>

00000000000000e6 <memset>:

void*
memset(void *dst, int c, uint n)
{
  e6:	1141                	addi	sp,sp,-16
  e8:	e422                	sd	s0,8(sp)
  ea:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  ec:	ce09                	beqz	a2,106 <memset+0x20>
  ee:	87aa                	mv	a5,a0
  f0:	fff6071b          	addiw	a4,a2,-1
  f4:	1702                	slli	a4,a4,0x20
  f6:	9301                	srli	a4,a4,0x20
  f8:	0705                	addi	a4,a4,1
  fa:	972a                	add	a4,a4,a0
    cdst[i] = c;
  fc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 100:	0785                	addi	a5,a5,1
 102:	fee79de3          	bne	a5,a4,fc <memset+0x16>
  }
  return dst;
}
 106:	6422                	ld	s0,8(sp)
 108:	0141                	addi	sp,sp,16
 10a:	8082                	ret

000000000000010c <strchr>:

char*
strchr(const char *s, char c)
{
 10c:	1141                	addi	sp,sp,-16
 10e:	e422                	sd	s0,8(sp)
 110:	0800                	addi	s0,sp,16
  for(; *s; s++)
 112:	00054783          	lbu	a5,0(a0)
 116:	cb99                	beqz	a5,12c <strchr+0x20>
    if(*s == c)
 118:	00f58763          	beq	a1,a5,126 <strchr+0x1a>
  for(; *s; s++)
 11c:	0505                	addi	a0,a0,1
 11e:	00054783          	lbu	a5,0(a0)
 122:	fbfd                	bnez	a5,118 <strchr+0xc>
      return (char*)s;
  return 0;
 124:	4501                	li	a0,0
}
 126:	6422                	ld	s0,8(sp)
 128:	0141                	addi	sp,sp,16
 12a:	8082                	ret
  return 0;
 12c:	4501                	li	a0,0
 12e:	bfe5                	j	126 <strchr+0x1a>

0000000000000130 <gets>:

char*
gets(char *buf, int max)
{
 130:	711d                	addi	sp,sp,-96
 132:	ec86                	sd	ra,88(sp)
 134:	e8a2                	sd	s0,80(sp)
 136:	e4a6                	sd	s1,72(sp)
 138:	e0ca                	sd	s2,64(sp)
 13a:	fc4e                	sd	s3,56(sp)
 13c:	f852                	sd	s4,48(sp)
 13e:	f456                	sd	s5,40(sp)
 140:	f05a                	sd	s6,32(sp)
 142:	ec5e                	sd	s7,24(sp)
 144:	1080                	addi	s0,sp,96
 146:	8baa                	mv	s7,a0
 148:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 14a:	892a                	mv	s2,a0
 14c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 14e:	4aa9                	li	s5,10
 150:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 152:	89a6                	mv	s3,s1
 154:	2485                	addiw	s1,s1,1
 156:	0344d863          	bge	s1,s4,186 <gets+0x56>
    cc = read(0, &c, 1);
 15a:	4605                	li	a2,1
 15c:	faf40593          	addi	a1,s0,-81
 160:	4501                	li	a0,0
 162:	00000097          	auipc	ra,0x0
 166:	1a0080e7          	jalr	416(ra) # 302 <read>
    if(cc < 1)
 16a:	00a05e63          	blez	a0,186 <gets+0x56>
    buf[i++] = c;
 16e:	faf44783          	lbu	a5,-81(s0)
 172:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 176:	01578763          	beq	a5,s5,184 <gets+0x54>
 17a:	0905                	addi	s2,s2,1
 17c:	fd679be3          	bne	a5,s6,152 <gets+0x22>
  for(i=0; i+1 < max; ){
 180:	89a6                	mv	s3,s1
 182:	a011                	j	186 <gets+0x56>
 184:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 186:	99de                	add	s3,s3,s7
 188:	00098023          	sb	zero,0(s3)
  return buf;
}
 18c:	855e                	mv	a0,s7
 18e:	60e6                	ld	ra,88(sp)
 190:	6446                	ld	s0,80(sp)
 192:	64a6                	ld	s1,72(sp)
 194:	6906                	ld	s2,64(sp)
 196:	79e2                	ld	s3,56(sp)
 198:	7a42                	ld	s4,48(sp)
 19a:	7aa2                	ld	s5,40(sp)
 19c:	7b02                	ld	s6,32(sp)
 19e:	6be2                	ld	s7,24(sp)
 1a0:	6125                	addi	sp,sp,96
 1a2:	8082                	ret

00000000000001a4 <stat>:

int
stat(const char *n, struct stat *st)
{
 1a4:	1101                	addi	sp,sp,-32
 1a6:	ec06                	sd	ra,24(sp)
 1a8:	e822                	sd	s0,16(sp)
 1aa:	e426                	sd	s1,8(sp)
 1ac:	e04a                	sd	s2,0(sp)
 1ae:	1000                	addi	s0,sp,32
 1b0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1b2:	4581                	li	a1,0
 1b4:	00000097          	auipc	ra,0x0
 1b8:	176080e7          	jalr	374(ra) # 32a <open>
  if(fd < 0)
 1bc:	02054563          	bltz	a0,1e6 <stat+0x42>
 1c0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1c2:	85ca                	mv	a1,s2
 1c4:	00000097          	auipc	ra,0x0
 1c8:	17e080e7          	jalr	382(ra) # 342 <fstat>
 1cc:	892a                	mv	s2,a0
  close(fd);
 1ce:	8526                	mv	a0,s1
 1d0:	00000097          	auipc	ra,0x0
 1d4:	142080e7          	jalr	322(ra) # 312 <close>
  return r;
}
 1d8:	854a                	mv	a0,s2
 1da:	60e2                	ld	ra,24(sp)
 1dc:	6442                	ld	s0,16(sp)
 1de:	64a2                	ld	s1,8(sp)
 1e0:	6902                	ld	s2,0(sp)
 1e2:	6105                	addi	sp,sp,32
 1e4:	8082                	ret
    return -1;
 1e6:	597d                	li	s2,-1
 1e8:	bfc5                	j	1d8 <stat+0x34>

00000000000001ea <atoi>:

int
atoi(const char *s)
{
 1ea:	1141                	addi	sp,sp,-16
 1ec:	e422                	sd	s0,8(sp)
 1ee:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1f0:	00054603          	lbu	a2,0(a0)
 1f4:	fd06079b          	addiw	a5,a2,-48
 1f8:	0ff7f793          	andi	a5,a5,255
 1fc:	4725                	li	a4,9
 1fe:	02f76963          	bltu	a4,a5,230 <atoi+0x46>
 202:	86aa                	mv	a3,a0
  n = 0;
 204:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 206:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 208:	0685                	addi	a3,a3,1
 20a:	0025179b          	slliw	a5,a0,0x2
 20e:	9fa9                	addw	a5,a5,a0
 210:	0017979b          	slliw	a5,a5,0x1
 214:	9fb1                	addw	a5,a5,a2
 216:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 21a:	0006c603          	lbu	a2,0(a3)
 21e:	fd06071b          	addiw	a4,a2,-48
 222:	0ff77713          	andi	a4,a4,255
 226:	fee5f1e3          	bgeu	a1,a4,208 <atoi+0x1e>
  return n;
}
 22a:	6422                	ld	s0,8(sp)
 22c:	0141                	addi	sp,sp,16
 22e:	8082                	ret
  n = 0;
 230:	4501                	li	a0,0
 232:	bfe5                	j	22a <atoi+0x40>

0000000000000234 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 234:	1141                	addi	sp,sp,-16
 236:	e422                	sd	s0,8(sp)
 238:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 23a:	02b57663          	bgeu	a0,a1,266 <memmove+0x32>
    while(n-- > 0)
 23e:	02c05163          	blez	a2,260 <memmove+0x2c>
 242:	fff6079b          	addiw	a5,a2,-1
 246:	1782                	slli	a5,a5,0x20
 248:	9381                	srli	a5,a5,0x20
 24a:	0785                	addi	a5,a5,1
 24c:	97aa                	add	a5,a5,a0
  dst = vdst;
 24e:	872a                	mv	a4,a0
      *dst++ = *src++;
 250:	0585                	addi	a1,a1,1
 252:	0705                	addi	a4,a4,1
 254:	fff5c683          	lbu	a3,-1(a1)
 258:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 25c:	fee79ae3          	bne	a5,a4,250 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 260:	6422                	ld	s0,8(sp)
 262:	0141                	addi	sp,sp,16
 264:	8082                	ret
    dst += n;
 266:	00c50733          	add	a4,a0,a2
    src += n;
 26a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 26c:	fec05ae3          	blez	a2,260 <memmove+0x2c>
 270:	fff6079b          	addiw	a5,a2,-1
 274:	1782                	slli	a5,a5,0x20
 276:	9381                	srli	a5,a5,0x20
 278:	fff7c793          	not	a5,a5
 27c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 27e:	15fd                	addi	a1,a1,-1
 280:	177d                	addi	a4,a4,-1
 282:	0005c683          	lbu	a3,0(a1)
 286:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 28a:	fee79ae3          	bne	a5,a4,27e <memmove+0x4a>
 28e:	bfc9                	j	260 <memmove+0x2c>

0000000000000290 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 290:	1141                	addi	sp,sp,-16
 292:	e422                	sd	s0,8(sp)
 294:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 296:	ca05                	beqz	a2,2c6 <memcmp+0x36>
 298:	fff6069b          	addiw	a3,a2,-1
 29c:	1682                	slli	a3,a3,0x20
 29e:	9281                	srli	a3,a3,0x20
 2a0:	0685                	addi	a3,a3,1
 2a2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2a4:	00054783          	lbu	a5,0(a0)
 2a8:	0005c703          	lbu	a4,0(a1)
 2ac:	00e79863          	bne	a5,a4,2bc <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2b0:	0505                	addi	a0,a0,1
    p2++;
 2b2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2b4:	fed518e3          	bne	a0,a3,2a4 <memcmp+0x14>
  }
  return 0;
 2b8:	4501                	li	a0,0
 2ba:	a019                	j	2c0 <memcmp+0x30>
      return *p1 - *p2;
 2bc:	40e7853b          	subw	a0,a5,a4
}
 2c0:	6422                	ld	s0,8(sp)
 2c2:	0141                	addi	sp,sp,16
 2c4:	8082                	ret
  return 0;
 2c6:	4501                	li	a0,0
 2c8:	bfe5                	j	2c0 <memcmp+0x30>

00000000000002ca <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2ca:	1141                	addi	sp,sp,-16
 2cc:	e406                	sd	ra,8(sp)
 2ce:	e022                	sd	s0,0(sp)
 2d0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2d2:	00000097          	auipc	ra,0x0
 2d6:	f62080e7          	jalr	-158(ra) # 234 <memmove>
}
 2da:	60a2                	ld	ra,8(sp)
 2dc:	6402                	ld	s0,0(sp)
 2de:	0141                	addi	sp,sp,16
 2e0:	8082                	ret

00000000000002e2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2e2:	4885                	li	a7,1
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <exit>:
.global exit
exit:
 li a7, SYS_exit
 2ea:	4889                	li	a7,2
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2f2:	488d                	li	a7,3
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2fa:	4891                	li	a7,4
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <read>:
.global read
read:
 li a7, SYS_read
 302:	4895                	li	a7,5
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <write>:
.global write
write:
 li a7, SYS_write
 30a:	48c1                	li	a7,16
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <close>:
.global close
close:
 li a7, SYS_close
 312:	48d5                	li	a7,21
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <kill>:
.global kill
kill:
 li a7, SYS_kill
 31a:	4899                	li	a7,6
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <exec>:
.global exec
exec:
 li a7, SYS_exec
 322:	489d                	li	a7,7
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <open>:
.global open
open:
 li a7, SYS_open
 32a:	48bd                	li	a7,15
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 332:	48c5                	li	a7,17
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 33a:	48c9                	li	a7,18
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 342:	48a1                	li	a7,8
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <link>:
.global link
link:
 li a7, SYS_link
 34a:	48cd                	li	a7,19
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 352:	48d1                	li	a7,20
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 35a:	48a5                	li	a7,9
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <dup>:
.global dup
dup:
 li a7, SYS_dup
 362:	48a9                	li	a7,10
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 36a:	48ad                	li	a7,11
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 372:	48b1                	li	a7,12
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 37a:	48b5                	li	a7,13
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 382:	48b9                	li	a7,14
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <trace>:
.global trace
trace:
 li a7, SYS_trace
 38a:	48d9                	li	a7,22
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <setpriority>:
.global setpriority
setpriority:
 li a7, SYS_setpriority
 392:	48e1                	li	a7,24
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 39a:	48e9                	li	a7,26
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3a2:	1101                	addi	sp,sp,-32
 3a4:	ec06                	sd	ra,24(sp)
 3a6:	e822                	sd	s0,16(sp)
 3a8:	1000                	addi	s0,sp,32
 3aa:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3ae:	4605                	li	a2,1
 3b0:	fef40593          	addi	a1,s0,-17
 3b4:	00000097          	auipc	ra,0x0
 3b8:	f56080e7          	jalr	-170(ra) # 30a <write>
}
 3bc:	60e2                	ld	ra,24(sp)
 3be:	6442                	ld	s0,16(sp)
 3c0:	6105                	addi	sp,sp,32
 3c2:	8082                	ret

00000000000003c4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3c4:	7139                	addi	sp,sp,-64
 3c6:	fc06                	sd	ra,56(sp)
 3c8:	f822                	sd	s0,48(sp)
 3ca:	f426                	sd	s1,40(sp)
 3cc:	f04a                	sd	s2,32(sp)
 3ce:	ec4e                	sd	s3,24(sp)
 3d0:	0080                	addi	s0,sp,64
 3d2:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3d4:	c299                	beqz	a3,3da <printint+0x16>
 3d6:	0805c863          	bltz	a1,466 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3da:	2581                	sext.w	a1,a1
  neg = 0;
 3dc:	4881                	li	a7,0
 3de:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3e2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3e4:	2601                	sext.w	a2,a2
 3e6:	00000517          	auipc	a0,0x0
 3ea:	45a50513          	addi	a0,a0,1114 # 840 <digits>
 3ee:	883a                	mv	a6,a4
 3f0:	2705                	addiw	a4,a4,1
 3f2:	02c5f7bb          	remuw	a5,a1,a2
 3f6:	1782                	slli	a5,a5,0x20
 3f8:	9381                	srli	a5,a5,0x20
 3fa:	97aa                	add	a5,a5,a0
 3fc:	0007c783          	lbu	a5,0(a5)
 400:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 404:	0005879b          	sext.w	a5,a1
 408:	02c5d5bb          	divuw	a1,a1,a2
 40c:	0685                	addi	a3,a3,1
 40e:	fec7f0e3          	bgeu	a5,a2,3ee <printint+0x2a>
  if(neg)
 412:	00088b63          	beqz	a7,428 <printint+0x64>
    buf[i++] = '-';
 416:	fd040793          	addi	a5,s0,-48
 41a:	973e                	add	a4,a4,a5
 41c:	02d00793          	li	a5,45
 420:	fef70823          	sb	a5,-16(a4)
 424:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 428:	02e05863          	blez	a4,458 <printint+0x94>
 42c:	fc040793          	addi	a5,s0,-64
 430:	00e78933          	add	s2,a5,a4
 434:	fff78993          	addi	s3,a5,-1
 438:	99ba                	add	s3,s3,a4
 43a:	377d                	addiw	a4,a4,-1
 43c:	1702                	slli	a4,a4,0x20
 43e:	9301                	srli	a4,a4,0x20
 440:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 444:	fff94583          	lbu	a1,-1(s2)
 448:	8526                	mv	a0,s1
 44a:	00000097          	auipc	ra,0x0
 44e:	f58080e7          	jalr	-168(ra) # 3a2 <putc>
  while(--i >= 0)
 452:	197d                	addi	s2,s2,-1
 454:	ff3918e3          	bne	s2,s3,444 <printint+0x80>
}
 458:	70e2                	ld	ra,56(sp)
 45a:	7442                	ld	s0,48(sp)
 45c:	74a2                	ld	s1,40(sp)
 45e:	7902                	ld	s2,32(sp)
 460:	69e2                	ld	s3,24(sp)
 462:	6121                	addi	sp,sp,64
 464:	8082                	ret
    x = -xx;
 466:	40b005bb          	negw	a1,a1
    neg = 1;
 46a:	4885                	li	a7,1
    x = -xx;
 46c:	bf8d                	j	3de <printint+0x1a>

000000000000046e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 46e:	7119                	addi	sp,sp,-128
 470:	fc86                	sd	ra,120(sp)
 472:	f8a2                	sd	s0,112(sp)
 474:	f4a6                	sd	s1,104(sp)
 476:	f0ca                	sd	s2,96(sp)
 478:	ecce                	sd	s3,88(sp)
 47a:	e8d2                	sd	s4,80(sp)
 47c:	e4d6                	sd	s5,72(sp)
 47e:	e0da                	sd	s6,64(sp)
 480:	fc5e                	sd	s7,56(sp)
 482:	f862                	sd	s8,48(sp)
 484:	f466                	sd	s9,40(sp)
 486:	f06a                	sd	s10,32(sp)
 488:	ec6e                	sd	s11,24(sp)
 48a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 48c:	0005c903          	lbu	s2,0(a1)
 490:	18090f63          	beqz	s2,62e <vprintf+0x1c0>
 494:	8aaa                	mv	s5,a0
 496:	8b32                	mv	s6,a2
 498:	00158493          	addi	s1,a1,1
  state = 0;
 49c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 49e:	02500a13          	li	s4,37
      if(c == 'd'){
 4a2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 4a6:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 4aa:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 4ae:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4b2:	00000b97          	auipc	s7,0x0
 4b6:	38eb8b93          	addi	s7,s7,910 # 840 <digits>
 4ba:	a839                	j	4d8 <vprintf+0x6a>
        putc(fd, c);
 4bc:	85ca                	mv	a1,s2
 4be:	8556                	mv	a0,s5
 4c0:	00000097          	auipc	ra,0x0
 4c4:	ee2080e7          	jalr	-286(ra) # 3a2 <putc>
 4c8:	a019                	j	4ce <vprintf+0x60>
    } else if(state == '%'){
 4ca:	01498f63          	beq	s3,s4,4e8 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4ce:	0485                	addi	s1,s1,1
 4d0:	fff4c903          	lbu	s2,-1(s1)
 4d4:	14090d63          	beqz	s2,62e <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 4d8:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4dc:	fe0997e3          	bnez	s3,4ca <vprintf+0x5c>
      if(c == '%'){
 4e0:	fd479ee3          	bne	a5,s4,4bc <vprintf+0x4e>
        state = '%';
 4e4:	89be                	mv	s3,a5
 4e6:	b7e5                	j	4ce <vprintf+0x60>
      if(c == 'd'){
 4e8:	05878063          	beq	a5,s8,528 <vprintf+0xba>
      } else if(c == 'l') {
 4ec:	05978c63          	beq	a5,s9,544 <vprintf+0xd6>
      } else if(c == 'x') {
 4f0:	07a78863          	beq	a5,s10,560 <vprintf+0xf2>
      } else if(c == 'p') {
 4f4:	09b78463          	beq	a5,s11,57c <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 4f8:	07300713          	li	a4,115
 4fc:	0ce78663          	beq	a5,a4,5c8 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 500:	06300713          	li	a4,99
 504:	0ee78e63          	beq	a5,a4,600 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 508:	11478863          	beq	a5,s4,618 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 50c:	85d2                	mv	a1,s4
 50e:	8556                	mv	a0,s5
 510:	00000097          	auipc	ra,0x0
 514:	e92080e7          	jalr	-366(ra) # 3a2 <putc>
        putc(fd, c);
 518:	85ca                	mv	a1,s2
 51a:	8556                	mv	a0,s5
 51c:	00000097          	auipc	ra,0x0
 520:	e86080e7          	jalr	-378(ra) # 3a2 <putc>
      }
      state = 0;
 524:	4981                	li	s3,0
 526:	b765                	j	4ce <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 528:	008b0913          	addi	s2,s6,8
 52c:	4685                	li	a3,1
 52e:	4629                	li	a2,10
 530:	000b2583          	lw	a1,0(s6)
 534:	8556                	mv	a0,s5
 536:	00000097          	auipc	ra,0x0
 53a:	e8e080e7          	jalr	-370(ra) # 3c4 <printint>
 53e:	8b4a                	mv	s6,s2
      state = 0;
 540:	4981                	li	s3,0
 542:	b771                	j	4ce <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 544:	008b0913          	addi	s2,s6,8
 548:	4681                	li	a3,0
 54a:	4629                	li	a2,10
 54c:	000b2583          	lw	a1,0(s6)
 550:	8556                	mv	a0,s5
 552:	00000097          	auipc	ra,0x0
 556:	e72080e7          	jalr	-398(ra) # 3c4 <printint>
 55a:	8b4a                	mv	s6,s2
      state = 0;
 55c:	4981                	li	s3,0
 55e:	bf85                	j	4ce <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 560:	008b0913          	addi	s2,s6,8
 564:	4681                	li	a3,0
 566:	4641                	li	a2,16
 568:	000b2583          	lw	a1,0(s6)
 56c:	8556                	mv	a0,s5
 56e:	00000097          	auipc	ra,0x0
 572:	e56080e7          	jalr	-426(ra) # 3c4 <printint>
 576:	8b4a                	mv	s6,s2
      state = 0;
 578:	4981                	li	s3,0
 57a:	bf91                	j	4ce <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 57c:	008b0793          	addi	a5,s6,8
 580:	f8f43423          	sd	a5,-120(s0)
 584:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 588:	03000593          	li	a1,48
 58c:	8556                	mv	a0,s5
 58e:	00000097          	auipc	ra,0x0
 592:	e14080e7          	jalr	-492(ra) # 3a2 <putc>
  putc(fd, 'x');
 596:	85ea                	mv	a1,s10
 598:	8556                	mv	a0,s5
 59a:	00000097          	auipc	ra,0x0
 59e:	e08080e7          	jalr	-504(ra) # 3a2 <putc>
 5a2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5a4:	03c9d793          	srli	a5,s3,0x3c
 5a8:	97de                	add	a5,a5,s7
 5aa:	0007c583          	lbu	a1,0(a5)
 5ae:	8556                	mv	a0,s5
 5b0:	00000097          	auipc	ra,0x0
 5b4:	df2080e7          	jalr	-526(ra) # 3a2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5b8:	0992                	slli	s3,s3,0x4
 5ba:	397d                	addiw	s2,s2,-1
 5bc:	fe0914e3          	bnez	s2,5a4 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 5c0:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 5c4:	4981                	li	s3,0
 5c6:	b721                	j	4ce <vprintf+0x60>
        s = va_arg(ap, char*);
 5c8:	008b0993          	addi	s3,s6,8
 5cc:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 5d0:	02090163          	beqz	s2,5f2 <vprintf+0x184>
        while(*s != 0){
 5d4:	00094583          	lbu	a1,0(s2)
 5d8:	c9a1                	beqz	a1,628 <vprintf+0x1ba>
          putc(fd, *s);
 5da:	8556                	mv	a0,s5
 5dc:	00000097          	auipc	ra,0x0
 5e0:	dc6080e7          	jalr	-570(ra) # 3a2 <putc>
          s++;
 5e4:	0905                	addi	s2,s2,1
        while(*s != 0){
 5e6:	00094583          	lbu	a1,0(s2)
 5ea:	f9e5                	bnez	a1,5da <vprintf+0x16c>
        s = va_arg(ap, char*);
 5ec:	8b4e                	mv	s6,s3
      state = 0;
 5ee:	4981                	li	s3,0
 5f0:	bdf9                	j	4ce <vprintf+0x60>
          s = "(null)";
 5f2:	00000917          	auipc	s2,0x0
 5f6:	24690913          	addi	s2,s2,582 # 838 <malloc+0x100>
        while(*s != 0){
 5fa:	02800593          	li	a1,40
 5fe:	bff1                	j	5da <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 600:	008b0913          	addi	s2,s6,8
 604:	000b4583          	lbu	a1,0(s6)
 608:	8556                	mv	a0,s5
 60a:	00000097          	auipc	ra,0x0
 60e:	d98080e7          	jalr	-616(ra) # 3a2 <putc>
 612:	8b4a                	mv	s6,s2
      state = 0;
 614:	4981                	li	s3,0
 616:	bd65                	j	4ce <vprintf+0x60>
        putc(fd, c);
 618:	85d2                	mv	a1,s4
 61a:	8556                	mv	a0,s5
 61c:	00000097          	auipc	ra,0x0
 620:	d86080e7          	jalr	-634(ra) # 3a2 <putc>
      state = 0;
 624:	4981                	li	s3,0
 626:	b565                	j	4ce <vprintf+0x60>
        s = va_arg(ap, char*);
 628:	8b4e                	mv	s6,s3
      state = 0;
 62a:	4981                	li	s3,0
 62c:	b54d                	j	4ce <vprintf+0x60>
    }
  }
}
 62e:	70e6                	ld	ra,120(sp)
 630:	7446                	ld	s0,112(sp)
 632:	74a6                	ld	s1,104(sp)
 634:	7906                	ld	s2,96(sp)
 636:	69e6                	ld	s3,88(sp)
 638:	6a46                	ld	s4,80(sp)
 63a:	6aa6                	ld	s5,72(sp)
 63c:	6b06                	ld	s6,64(sp)
 63e:	7be2                	ld	s7,56(sp)
 640:	7c42                	ld	s8,48(sp)
 642:	7ca2                	ld	s9,40(sp)
 644:	7d02                	ld	s10,32(sp)
 646:	6de2                	ld	s11,24(sp)
 648:	6109                	addi	sp,sp,128
 64a:	8082                	ret

000000000000064c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 64c:	715d                	addi	sp,sp,-80
 64e:	ec06                	sd	ra,24(sp)
 650:	e822                	sd	s0,16(sp)
 652:	1000                	addi	s0,sp,32
 654:	e010                	sd	a2,0(s0)
 656:	e414                	sd	a3,8(s0)
 658:	e818                	sd	a4,16(s0)
 65a:	ec1c                	sd	a5,24(s0)
 65c:	03043023          	sd	a6,32(s0)
 660:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 664:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 668:	8622                	mv	a2,s0
 66a:	00000097          	auipc	ra,0x0
 66e:	e04080e7          	jalr	-508(ra) # 46e <vprintf>
}
 672:	60e2                	ld	ra,24(sp)
 674:	6442                	ld	s0,16(sp)
 676:	6161                	addi	sp,sp,80
 678:	8082                	ret

000000000000067a <printf>:

void
printf(const char *fmt, ...)
{
 67a:	711d                	addi	sp,sp,-96
 67c:	ec06                	sd	ra,24(sp)
 67e:	e822                	sd	s0,16(sp)
 680:	1000                	addi	s0,sp,32
 682:	e40c                	sd	a1,8(s0)
 684:	e810                	sd	a2,16(s0)
 686:	ec14                	sd	a3,24(s0)
 688:	f018                	sd	a4,32(s0)
 68a:	f41c                	sd	a5,40(s0)
 68c:	03043823          	sd	a6,48(s0)
 690:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 694:	00840613          	addi	a2,s0,8
 698:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 69c:	85aa                	mv	a1,a0
 69e:	4505                	li	a0,1
 6a0:	00000097          	auipc	ra,0x0
 6a4:	dce080e7          	jalr	-562(ra) # 46e <vprintf>
}
 6a8:	60e2                	ld	ra,24(sp)
 6aa:	6442                	ld	s0,16(sp)
 6ac:	6125                	addi	sp,sp,96
 6ae:	8082                	ret

00000000000006b0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6b0:	1141                	addi	sp,sp,-16
 6b2:	e422                	sd	s0,8(sp)
 6b4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6b6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ba:	00001797          	auipc	a5,0x1
 6be:	9467b783          	ld	a5,-1722(a5) # 1000 <freep>
 6c2:	a805                	j	6f2 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6c4:	4618                	lw	a4,8(a2)
 6c6:	9db9                	addw	a1,a1,a4
 6c8:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6cc:	6398                	ld	a4,0(a5)
 6ce:	6318                	ld	a4,0(a4)
 6d0:	fee53823          	sd	a4,-16(a0)
 6d4:	a091                	j	718 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6d6:	ff852703          	lw	a4,-8(a0)
 6da:	9e39                	addw	a2,a2,a4
 6dc:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 6de:	ff053703          	ld	a4,-16(a0)
 6e2:	e398                	sd	a4,0(a5)
 6e4:	a099                	j	72a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6e6:	6398                	ld	a4,0(a5)
 6e8:	00e7e463          	bltu	a5,a4,6f0 <free+0x40>
 6ec:	00e6ea63          	bltu	a3,a4,700 <free+0x50>
{
 6f0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6f2:	fed7fae3          	bgeu	a5,a3,6e6 <free+0x36>
 6f6:	6398                	ld	a4,0(a5)
 6f8:	00e6e463          	bltu	a3,a4,700 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6fc:	fee7eae3          	bltu	a5,a4,6f0 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 700:	ff852583          	lw	a1,-8(a0)
 704:	6390                	ld	a2,0(a5)
 706:	02059713          	slli	a4,a1,0x20
 70a:	9301                	srli	a4,a4,0x20
 70c:	0712                	slli	a4,a4,0x4
 70e:	9736                	add	a4,a4,a3
 710:	fae60ae3          	beq	a2,a4,6c4 <free+0x14>
    bp->s.ptr = p->s.ptr;
 714:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 718:	4790                	lw	a2,8(a5)
 71a:	02061713          	slli	a4,a2,0x20
 71e:	9301                	srli	a4,a4,0x20
 720:	0712                	slli	a4,a4,0x4
 722:	973e                	add	a4,a4,a5
 724:	fae689e3          	beq	a3,a4,6d6 <free+0x26>
  } else
    p->s.ptr = bp;
 728:	e394                	sd	a3,0(a5)
  freep = p;
 72a:	00001717          	auipc	a4,0x1
 72e:	8cf73b23          	sd	a5,-1834(a4) # 1000 <freep>
}
 732:	6422                	ld	s0,8(sp)
 734:	0141                	addi	sp,sp,16
 736:	8082                	ret

0000000000000738 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 738:	7139                	addi	sp,sp,-64
 73a:	fc06                	sd	ra,56(sp)
 73c:	f822                	sd	s0,48(sp)
 73e:	f426                	sd	s1,40(sp)
 740:	f04a                	sd	s2,32(sp)
 742:	ec4e                	sd	s3,24(sp)
 744:	e852                	sd	s4,16(sp)
 746:	e456                	sd	s5,8(sp)
 748:	e05a                	sd	s6,0(sp)
 74a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 74c:	02051493          	slli	s1,a0,0x20
 750:	9081                	srli	s1,s1,0x20
 752:	04bd                	addi	s1,s1,15
 754:	8091                	srli	s1,s1,0x4
 756:	0014899b          	addiw	s3,s1,1
 75a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 75c:	00001517          	auipc	a0,0x1
 760:	8a453503          	ld	a0,-1884(a0) # 1000 <freep>
 764:	c515                	beqz	a0,790 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 766:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 768:	4798                	lw	a4,8(a5)
 76a:	02977f63          	bgeu	a4,s1,7a8 <malloc+0x70>
 76e:	8a4e                	mv	s4,s3
 770:	0009871b          	sext.w	a4,s3
 774:	6685                	lui	a3,0x1
 776:	00d77363          	bgeu	a4,a3,77c <malloc+0x44>
 77a:	6a05                	lui	s4,0x1
 77c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 780:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 784:	00001917          	auipc	s2,0x1
 788:	87c90913          	addi	s2,s2,-1924 # 1000 <freep>
  if(p == (char*)-1)
 78c:	5afd                	li	s5,-1
 78e:	a88d                	j	800 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 790:	00001797          	auipc	a5,0x1
 794:	88078793          	addi	a5,a5,-1920 # 1010 <base>
 798:	00001717          	auipc	a4,0x1
 79c:	86f73423          	sd	a5,-1944(a4) # 1000 <freep>
 7a0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7a2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7a6:	b7e1                	j	76e <malloc+0x36>
      if(p->s.size == nunits)
 7a8:	02e48b63          	beq	s1,a4,7de <malloc+0xa6>
        p->s.size -= nunits;
 7ac:	4137073b          	subw	a4,a4,s3
 7b0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7b2:	1702                	slli	a4,a4,0x20
 7b4:	9301                	srli	a4,a4,0x20
 7b6:	0712                	slli	a4,a4,0x4
 7b8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7ba:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7be:	00001717          	auipc	a4,0x1
 7c2:	84a73123          	sd	a0,-1982(a4) # 1000 <freep>
      return (void*)(p + 1);
 7c6:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7ca:	70e2                	ld	ra,56(sp)
 7cc:	7442                	ld	s0,48(sp)
 7ce:	74a2                	ld	s1,40(sp)
 7d0:	7902                	ld	s2,32(sp)
 7d2:	69e2                	ld	s3,24(sp)
 7d4:	6a42                	ld	s4,16(sp)
 7d6:	6aa2                	ld	s5,8(sp)
 7d8:	6b02                	ld	s6,0(sp)
 7da:	6121                	addi	sp,sp,64
 7dc:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7de:	6398                	ld	a4,0(a5)
 7e0:	e118                	sd	a4,0(a0)
 7e2:	bff1                	j	7be <malloc+0x86>
  hp->s.size = nu;
 7e4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7e8:	0541                	addi	a0,a0,16
 7ea:	00000097          	auipc	ra,0x0
 7ee:	ec6080e7          	jalr	-314(ra) # 6b0 <free>
  return freep;
 7f2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7f6:	d971                	beqz	a0,7ca <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7f8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7fa:	4798                	lw	a4,8(a5)
 7fc:	fa9776e3          	bgeu	a4,s1,7a8 <malloc+0x70>
    if(p == freep)
 800:	00093703          	ld	a4,0(s2)
 804:	853e                	mv	a0,a5
 806:	fef719e3          	bne	a4,a5,7f8 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 80a:	8552                	mv	a0,s4
 80c:	00000097          	auipc	ra,0x0
 810:	b66080e7          	jalr	-1178(ra) # 372 <sbrk>
  if(p == (char*)-1)
 814:	fd5518e3          	bne	a0,s5,7e4 <malloc+0xac>
        return 0;
 818:	4501                	li	a0,0
 81a:	bf45                	j	7ca <malloc+0x92>
