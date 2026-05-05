
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	00008117          	auipc	sp,0x8
    80000004:	87010113          	addi	sp,sp,-1936 # 80007870 <stack0>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	04e000ef          	jal	80000064 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000024:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000028:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002c:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80000030:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000034:	577d                	li	a4,-1
    80000036:	177e                	slli	a4,a4,0x3f
    80000038:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    8000003a:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003e:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000042:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000046:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    8000004a:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004e:	000f4737          	lui	a4,0xf4
    80000052:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000056:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000058:	14d79073          	csrw	stimecmp,a5
}
    8000005c:	60a2                	ld	ra,8(sp)
    8000005e:	6402                	ld	s0,0(sp)
    80000060:	0141                	addi	sp,sp,16
    80000062:	8082                	ret

0000000080000064 <start>:
{
    80000064:	1141                	addi	sp,sp,-16
    80000066:	e406                	sd	ra,8(sp)
    80000068:	e022                	sd	s0,0(sp)
    8000006a:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006c:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000070:	7779                	lui	a4,0xffffe
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffddc87>
    80000076:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000078:	6705                	lui	a4,0x1
    8000007a:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000080:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000084:	00001797          	auipc	a5,0x1
    80000088:	e2c78793          	addi	a5,a5,-468 # 80000eb0 <main>
    8000008c:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80000090:	4781                	li	a5,0
    80000092:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000096:	67c1                	lui	a5,0x10
    80000098:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000009a:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009e:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000a2:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000a6:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    800000aa:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000ae:	57fd                	li	a5,-1
    800000b0:	83a9                	srli	a5,a5,0xa
    800000b2:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b6:	47bd                	li	a5,15
    800000b8:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000bc:	f61ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000c0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c4:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c6:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c8:	30200073          	mret
}
    800000cc:	60a2                	ld	ra,8(sp)
    800000ce:	6402                	ld	s0,0(sp)
    800000d0:	0141                	addi	sp,sp,16
    800000d2:	8082                	ret

00000000800000d4 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d4:	7119                	addi	sp,sp,-128
    800000d6:	fc86                	sd	ra,120(sp)
    800000d8:	f8a2                	sd	s0,112(sp)
    800000da:	f4a6                	sd	s1,104(sp)
    800000dc:	0100                	addi	s0,sp,128
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while(i < n){
    800000de:	06c05b63          	blez	a2,80000154 <consolewrite+0x80>
    800000e2:	f0ca                	sd	s2,96(sp)
    800000e4:	ecce                	sd	s3,88(sp)
    800000e6:	e8d2                	sd	s4,80(sp)
    800000e8:	e4d6                	sd	s5,72(sp)
    800000ea:	e0da                	sd	s6,64(sp)
    800000ec:	fc5e                	sd	s7,56(sp)
    800000ee:	f862                	sd	s8,48(sp)
    800000f0:	f466                	sd	s9,40(sp)
    800000f2:	f06a                	sd	s10,32(sp)
    800000f4:	8b2a                	mv	s6,a0
    800000f6:	8bae                	mv	s7,a1
    800000f8:	8a32                	mv	s4,a2
  int i = 0;
    800000fa:	4481                	li	s1,0
    int nn = sizeof(buf);
    if(nn > n - i)
    800000fc:	02000c93          	li	s9,32
    80000100:	02000d13          	li	s10,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000104:	f8040a93          	addi	s5,s0,-128
    80000108:	5c7d                	li	s8,-1
    8000010a:	a025                	j	80000132 <consolewrite+0x5e>
    if(nn > n - i)
    8000010c:	0009099b          	sext.w	s3,s2
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000110:	86ce                	mv	a3,s3
    80000112:	01748633          	add	a2,s1,s7
    80000116:	85da                	mv	a1,s6
    80000118:	8556                	mv	a0,s5
    8000011a:	184020ef          	jal	8000229e <either_copyin>
    8000011e:	03850d63          	beq	a0,s8,80000158 <consolewrite+0x84>
      break;
    uartwrite(buf, nn);
    80000122:	85ce                	mv	a1,s3
    80000124:	8556                	mv	a0,s5
    80000126:	7c8000ef          	jal	800008ee <uartwrite>
    i += nn;
    8000012a:	009904bb          	addw	s1,s2,s1
  while(i < n){
    8000012e:	0144d963          	bge	s1,s4,80000140 <consolewrite+0x6c>
    if(nn > n - i)
    80000132:	409a07bb          	subw	a5,s4,s1
    80000136:	893e                	mv	s2,a5
    80000138:	fcfcdae3          	bge	s9,a5,8000010c <consolewrite+0x38>
    8000013c:	896a                	mv	s2,s10
    8000013e:	b7f9                	j	8000010c <consolewrite+0x38>
    80000140:	7906                	ld	s2,96(sp)
    80000142:	69e6                	ld	s3,88(sp)
    80000144:	6a46                	ld	s4,80(sp)
    80000146:	6aa6                	ld	s5,72(sp)
    80000148:	6b06                	ld	s6,64(sp)
    8000014a:	7be2                	ld	s7,56(sp)
    8000014c:	7c42                	ld	s8,48(sp)
    8000014e:	7ca2                	ld	s9,40(sp)
    80000150:	7d02                	ld	s10,32(sp)
    80000152:	a821                	j	8000016a <consolewrite+0x96>
  int i = 0;
    80000154:	4481                	li	s1,0
    80000156:	a811                	j	8000016a <consolewrite+0x96>
    80000158:	7906                	ld	s2,96(sp)
    8000015a:	69e6                	ld	s3,88(sp)
    8000015c:	6a46                	ld	s4,80(sp)
    8000015e:	6aa6                	ld	s5,72(sp)
    80000160:	6b06                	ld	s6,64(sp)
    80000162:	7be2                	ld	s7,56(sp)
    80000164:	7c42                	ld	s8,48(sp)
    80000166:	7ca2                	ld	s9,40(sp)
    80000168:	7d02                	ld	s10,32(sp)
  }

  return i;
}
    8000016a:	8526                	mv	a0,s1
    8000016c:	70e6                	ld	ra,120(sp)
    8000016e:	7446                	ld	s0,112(sp)
    80000170:	74a6                	ld	s1,104(sp)
    80000172:	6109                	addi	sp,sp,128
    80000174:	8082                	ret

0000000080000176 <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000176:	711d                	addi	sp,sp,-96
    80000178:	ec86                	sd	ra,88(sp)
    8000017a:	e8a2                	sd	s0,80(sp)
    8000017c:	e4a6                	sd	s1,72(sp)
    8000017e:	e0ca                	sd	s2,64(sp)
    80000180:	fc4e                	sd	s3,56(sp)
    80000182:	f852                	sd	s4,48(sp)
    80000184:	f05a                	sd	s6,32(sp)
    80000186:	ec5e                	sd	s7,24(sp)
    80000188:	1080                	addi	s0,sp,96
    8000018a:	8b2a                	mv	s6,a0
    8000018c:	8a2e                	mv	s4,a1
    8000018e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000190:	8bb2                	mv	s7,a2
  acquire(&cons.lock);
    80000192:	0000f517          	auipc	a0,0xf
    80000196:	6de50513          	addi	a0,a0,1758 # 8000f870 <cons>
    8000019a:	29f000ef          	jal	80000c38 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019e:	0000f497          	auipc	s1,0xf
    800001a2:	6d248493          	addi	s1,s1,1746 # 8000f870 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a6:	0000f917          	auipc	s2,0xf
    800001aa:	76290913          	addi	s2,s2,1890 # 8000f908 <cons+0x98>
  while(n > 0){
    800001ae:	0b305b63          	blez	s3,80000264 <consoleread+0xee>
    while(cons.r == cons.w){
    800001b2:	0984a783          	lw	a5,152(s1)
    800001b6:	09c4a703          	lw	a4,156(s1)
    800001ba:	0af71063          	bne	a4,a5,8000025a <consoleread+0xe4>
      if(killed(myproc())){
    800001be:	746010ef          	jal	80001904 <myproc>
    800001c2:	777010ef          	jal	80002138 <killed>
    800001c6:	e12d                	bnez	a0,80000228 <consoleread+0xb2>
      sleep(&cons.r, &cons.lock);
    800001c8:	85a6                	mv	a1,s1
    800001ca:	854a                	mv	a0,s2
    800001cc:	531010ef          	jal	80001efc <sleep>
    while(cons.r == cons.w){
    800001d0:	0984a783          	lw	a5,152(s1)
    800001d4:	09c4a703          	lw	a4,156(s1)
    800001d8:	fef703e3          	beq	a4,a5,800001be <consoleread+0x48>
    800001dc:	f456                	sd	s5,40(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	0000f717          	auipc	a4,0xf
    800001e2:	69270713          	addi	a4,a4,1682 # 8000f870 <cons>
    800001e6:	0017869b          	addiw	a3,a5,1
    800001ea:	08d72c23          	sw	a3,152(a4)
    800001ee:	07f7f693          	andi	a3,a5,127
    800001f2:	9736                	add	a4,a4,a3
    800001f4:	01874703          	lbu	a4,24(a4)
    800001f8:	00070a9b          	sext.w	s5,a4

    if(c == C('D')){  // end-of-file
    800001fc:	4691                	li	a3,4
    800001fe:	04da8663          	beq	s5,a3,8000024a <consoleread+0xd4>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000202:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	faf40613          	addi	a2,s0,-81
    8000020c:	85d2                	mv	a1,s4
    8000020e:	855a                	mv	a0,s6
    80000210:	044020ef          	jal	80002254 <either_copyout>
    80000214:	57fd                	li	a5,-1
    80000216:	04f50663          	beq	a0,a5,80000262 <consoleread+0xec>
      break;

    dst++;
    8000021a:	0a05                	addi	s4,s4,1
    --n;
    8000021c:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    8000021e:	47a9                	li	a5,10
    80000220:	04fa8b63          	beq	s5,a5,80000276 <consoleread+0x100>
    80000224:	7aa2                	ld	s5,40(sp)
    80000226:	b761                	j	800001ae <consoleread+0x38>
        release(&cons.lock);
    80000228:	0000f517          	auipc	a0,0xf
    8000022c:	64850513          	addi	a0,a0,1608 # 8000f870 <cons>
    80000230:	299000ef          	jal	80000cc8 <release>
        return -1;
    80000234:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000236:	60e6                	ld	ra,88(sp)
    80000238:	6446                	ld	s0,80(sp)
    8000023a:	64a6                	ld	s1,72(sp)
    8000023c:	6906                	ld	s2,64(sp)
    8000023e:	79e2                	ld	s3,56(sp)
    80000240:	7a42                	ld	s4,48(sp)
    80000242:	7b02                	ld	s6,32(sp)
    80000244:	6be2                	ld	s7,24(sp)
    80000246:	6125                	addi	sp,sp,96
    80000248:	8082                	ret
      if(n < target){
    8000024a:	0179fa63          	bgeu	s3,s7,8000025e <consoleread+0xe8>
        cons.r--;
    8000024e:	0000f717          	auipc	a4,0xf
    80000252:	6af72d23          	sw	a5,1722(a4) # 8000f908 <cons+0x98>
    80000256:	7aa2                	ld	s5,40(sp)
    80000258:	a031                	j	80000264 <consoleread+0xee>
    8000025a:	f456                	sd	s5,40(sp)
    8000025c:	b749                	j	800001de <consoleread+0x68>
    8000025e:	7aa2                	ld	s5,40(sp)
    80000260:	a011                	j	80000264 <consoleread+0xee>
    80000262:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000264:	0000f517          	auipc	a0,0xf
    80000268:	60c50513          	addi	a0,a0,1548 # 8000f870 <cons>
    8000026c:	25d000ef          	jal	80000cc8 <release>
  return target - n;
    80000270:	413b853b          	subw	a0,s7,s3
    80000274:	b7c9                	j	80000236 <consoleread+0xc0>
    80000276:	7aa2                	ld	s5,40(sp)
    80000278:	b7f5                	j	80000264 <consoleread+0xee>

000000008000027a <consputc>:
{
    8000027a:	1141                	addi	sp,sp,-16
    8000027c:	e406                	sd	ra,8(sp)
    8000027e:	e022                	sd	s0,0(sp)
    80000280:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000282:	10000793          	li	a5,256
    80000286:	00f50863          	beq	a0,a5,80000296 <consputc+0x1c>
    uartputc_sync(c);
    8000028a:	6f8000ef          	jal	80000982 <uartputc_sync>
}
    8000028e:	60a2                	ld	ra,8(sp)
    80000290:	6402                	ld	s0,0(sp)
    80000292:	0141                	addi	sp,sp,16
    80000294:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000296:	4521                	li	a0,8
    80000298:	6ea000ef          	jal	80000982 <uartputc_sync>
    8000029c:	02000513          	li	a0,32
    800002a0:	6e2000ef          	jal	80000982 <uartputc_sync>
    800002a4:	4521                	li	a0,8
    800002a6:	6dc000ef          	jal	80000982 <uartputc_sync>
    800002aa:	b7d5                	j	8000028e <consputc+0x14>

00000000800002ac <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ac:	1101                	addi	sp,sp,-32
    800002ae:	ec06                	sd	ra,24(sp)
    800002b0:	e822                	sd	s0,16(sp)
    800002b2:	e426                	sd	s1,8(sp)
    800002b4:	1000                	addi	s0,sp,32
    800002b6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b8:	0000f517          	auipc	a0,0xf
    800002bc:	5b850513          	addi	a0,a0,1464 # 8000f870 <cons>
    800002c0:	179000ef          	jal	80000c38 <acquire>

  switch(c){
    800002c4:	47d5                	li	a5,21
    800002c6:	0af48163          	beq	s1,a5,80000368 <consoleintr+0xbc>
    800002ca:	0297c563          	blt	a5,s1,800002f4 <consoleintr+0x48>
    800002ce:	47a1                	li	a5,8
    800002d0:	0ef48663          	beq	s1,a5,800003bc <consoleintr+0x110>
    800002d4:	47c1                	li	a5,16
    800002d6:	10f49763          	bne	s1,a5,800003e4 <consoleintr+0x138>
  case C('P'):  // Print process list.
    procdump();
    800002da:	00e020ef          	jal	800022e8 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002de:	0000f517          	auipc	a0,0xf
    800002e2:	59250513          	addi	a0,a0,1426 # 8000f870 <cons>
    800002e6:	1e3000ef          	jal	80000cc8 <release>
}
    800002ea:	60e2                	ld	ra,24(sp)
    800002ec:	6442                	ld	s0,16(sp)
    800002ee:	64a2                	ld	s1,8(sp)
    800002f0:	6105                	addi	sp,sp,32
    800002f2:	8082                	ret
  switch(c){
    800002f4:	07f00793          	li	a5,127
    800002f8:	0cf48263          	beq	s1,a5,800003bc <consoleintr+0x110>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002fc:	0000f717          	auipc	a4,0xf
    80000300:	57470713          	addi	a4,a4,1396 # 8000f870 <cons>
    80000304:	0a072783          	lw	a5,160(a4)
    80000308:	09872703          	lw	a4,152(a4)
    8000030c:	9f99                	subw	a5,a5,a4
    8000030e:	07f00713          	li	a4,127
    80000312:	fcf766e3          	bltu	a4,a5,800002de <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000316:	47b5                	li	a5,13
    80000318:	0cf48963          	beq	s1,a5,800003ea <consoleintr+0x13e>
      consputc(c);
    8000031c:	8526                	mv	a0,s1
    8000031e:	f5dff0ef          	jal	8000027a <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000322:	0000f717          	auipc	a4,0xf
    80000326:	54e70713          	addi	a4,a4,1358 # 8000f870 <cons>
    8000032a:	0a072683          	lw	a3,160(a4)
    8000032e:	0016879b          	addiw	a5,a3,1
    80000332:	863e                	mv	a2,a5
    80000334:	0af72023          	sw	a5,160(a4)
    80000338:	07f6f693          	andi	a3,a3,127
    8000033c:	9736                	add	a4,a4,a3
    8000033e:	00970c23          	sb	s1,24(a4)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000342:	ff648713          	addi	a4,s1,-10
    80000346:	00173713          	seqz	a4,a4
    8000034a:	14f1                	addi	s1,s1,-4
    8000034c:	0014b493          	seqz	s1,s1
    80000350:	8f45                	or	a4,a4,s1
    80000352:	e361                	bnez	a4,80000412 <consoleintr+0x166>
    80000354:	0000f717          	auipc	a4,0xf
    80000358:	5b472703          	lw	a4,1460(a4) # 8000f908 <cons+0x98>
    8000035c:	9f99                	subw	a5,a5,a4
    8000035e:	08000713          	li	a4,128
    80000362:	f6e79ee3          	bne	a5,a4,800002de <consoleintr+0x32>
    80000366:	a075                	j	80000412 <consoleintr+0x166>
    80000368:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    8000036a:	0000f717          	auipc	a4,0xf
    8000036e:	50670713          	addi	a4,a4,1286 # 8000f870 <cons>
    80000372:	0a072783          	lw	a5,160(a4)
    80000376:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000037a:	0000f497          	auipc	s1,0xf
    8000037e:	4f648493          	addi	s1,s1,1270 # 8000f870 <cons>
    while(cons.e != cons.w &&
    80000382:	4929                	li	s2,10
    80000384:	02f70863          	beq	a4,a5,800003b4 <consoleintr+0x108>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000388:	37fd                	addiw	a5,a5,-1
    8000038a:	07f7f713          	andi	a4,a5,127
    8000038e:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000390:	01874703          	lbu	a4,24(a4)
    80000394:	03270263          	beq	a4,s2,800003b8 <consoleintr+0x10c>
      cons.e--;
    80000398:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    8000039c:	10000513          	li	a0,256
    800003a0:	edbff0ef          	jal	8000027a <consputc>
    while(cons.e != cons.w &&
    800003a4:	0a04a783          	lw	a5,160(s1)
    800003a8:	09c4a703          	lw	a4,156(s1)
    800003ac:	fcf71ee3          	bne	a4,a5,80000388 <consoleintr+0xdc>
    800003b0:	6902                	ld	s2,0(sp)
    800003b2:	b735                	j	800002de <consoleintr+0x32>
    800003b4:	6902                	ld	s2,0(sp)
    800003b6:	b725                	j	800002de <consoleintr+0x32>
    800003b8:	6902                	ld	s2,0(sp)
    800003ba:	b715                	j	800002de <consoleintr+0x32>
    if(cons.e != cons.w){
    800003bc:	0000f717          	auipc	a4,0xf
    800003c0:	4b470713          	addi	a4,a4,1204 # 8000f870 <cons>
    800003c4:	0a072783          	lw	a5,160(a4)
    800003c8:	09c72703          	lw	a4,156(a4)
    800003cc:	f0f709e3          	beq	a4,a5,800002de <consoleintr+0x32>
      cons.e--;
    800003d0:	37fd                	addiw	a5,a5,-1
    800003d2:	0000f717          	auipc	a4,0xf
    800003d6:	52f72f23          	sw	a5,1342(a4) # 8000f910 <cons+0xa0>
      consputc(BACKSPACE);
    800003da:	10000513          	li	a0,256
    800003de:	e9dff0ef          	jal	8000027a <consputc>
    800003e2:	bdf5                	j	800002de <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003e4:	ee048de3          	beqz	s1,800002de <consoleintr+0x32>
    800003e8:	bf11                	j	800002fc <consoleintr+0x50>
      consputc(c);
    800003ea:	4529                	li	a0,10
    800003ec:	e8fff0ef          	jal	8000027a <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003f0:	0000f797          	auipc	a5,0xf
    800003f4:	48078793          	addi	a5,a5,1152 # 8000f870 <cons>
    800003f8:	0a07a703          	lw	a4,160(a5)
    800003fc:	0017069b          	addiw	a3,a4,1
    80000400:	8636                	mv	a2,a3
    80000402:	0ad7a023          	sw	a3,160(a5)
    80000406:	07f77713          	andi	a4,a4,127
    8000040a:	97ba                	add	a5,a5,a4
    8000040c:	4729                	li	a4,10
    8000040e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000412:	0000f797          	auipc	a5,0xf
    80000416:	4ec7ad23          	sw	a2,1274(a5) # 8000f90c <cons+0x9c>
        wakeup(&cons.r);
    8000041a:	0000f517          	auipc	a0,0xf
    8000041e:	4ee50513          	addi	a0,a0,1262 # 8000f908 <cons+0x98>
    80000422:	327010ef          	jal	80001f48 <wakeup>
    80000426:	bd65                	j	800002de <consoleintr+0x32>

0000000080000428 <consoleinit>:

void
consoleinit(void)
{
    80000428:	1141                	addi	sp,sp,-16
    8000042a:	e406                	sd	ra,8(sp)
    8000042c:	e022                	sd	s0,0(sp)
    8000042e:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000430:	00007597          	auipc	a1,0x7
    80000434:	bd058593          	addi	a1,a1,-1072 # 80007000 <etext>
    80000438:	0000f517          	auipc	a0,0xf
    8000043c:	43850513          	addi	a0,a0,1080 # 8000f870 <cons>
    80000440:	76e000ef          	jal	80000bae <initlock>

  uartinit();
    80000444:	454000ef          	jal	80000898 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000448:	0001f797          	auipc	a5,0x1f
    8000044c:	59878793          	addi	a5,a5,1432 # 8001f9e0 <devsw>
    80000450:	00000717          	auipc	a4,0x0
    80000454:	d2670713          	addi	a4,a4,-730 # 80000176 <consoleread>
    80000458:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000045a:	00000717          	auipc	a4,0x0
    8000045e:	c7a70713          	addi	a4,a4,-902 # 800000d4 <consolewrite>
    80000462:	ef98                	sd	a4,24(a5)
}
    80000464:	60a2                	ld	ra,8(sp)
    80000466:	6402                	ld	s0,0(sp)
    80000468:	0141                	addi	sp,sp,16
    8000046a:	8082                	ret

000000008000046c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    8000046c:	7139                	addi	sp,sp,-64
    8000046e:	fc06                	sd	ra,56(sp)
    80000470:	f822                	sd	s0,48(sp)
    80000472:	f04a                	sd	s2,32(sp)
    80000474:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000476:	c219                	beqz	a2,8000047c <printint+0x10>
    80000478:	08054063          	bltz	a0,800004f8 <printint+0x8c>
    x = -xx;
  else
    x = xx;
    8000047c:	4301                	li	t1,0

  i = 0;
    8000047e:	fc840913          	addi	s2,s0,-56
    x = xx;
    80000482:	86ca                	mv	a3,s2
  i = 0;
    80000484:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    80000486:	00007817          	auipc	a6,0x7
    8000048a:	28a80813          	addi	a6,a6,650 # 80007710 <digits>
    8000048e:	88ba                	mv	a7,a4
    80000490:	0017061b          	addiw	a2,a4,1
    80000494:	8732                	mv	a4,a2
    80000496:	02b577b3          	remu	a5,a0,a1
    8000049a:	97c2                	add	a5,a5,a6
    8000049c:	0007c783          	lbu	a5,0(a5)
    800004a0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004a4:	87aa                	mv	a5,a0
    800004a6:	02b55533          	divu	a0,a0,a1
    800004aa:	0685                	addi	a3,a3,1
    800004ac:	feb7f1e3          	bgeu	a5,a1,8000048e <printint+0x22>

  if(sign)
    800004b0:	00030b63          	beqz	t1,800004c6 <printint+0x5a>
    buf[i++] = '-';
    800004b4:	fe040793          	addi	a5,s0,-32
    800004b8:	963e                	add	a2,a2,a5
    800004ba:	02d00793          	li	a5,45
    800004be:	fef60423          	sb	a5,-24(a2)
    800004c2:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
    800004c6:	02e05463          	blez	a4,800004ee <printint+0x82>
    800004ca:	f426                	sd	s1,40(sp)
    800004cc:	377d                	addiw	a4,a4,-1
    800004ce:	00e904b3          	add	s1,s2,a4
    800004d2:	197d                	addi	s2,s2,-1
    800004d4:	993a                	add	s2,s2,a4
    800004d6:	1702                	slli	a4,a4,0x20
    800004d8:	9301                	srli	a4,a4,0x20
    800004da:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    800004de:	0004c503          	lbu	a0,0(s1)
    800004e2:	d99ff0ef          	jal	8000027a <consputc>
  while(--i >= 0)
    800004e6:	14fd                	addi	s1,s1,-1
    800004e8:	ff249be3          	bne	s1,s2,800004de <printint+0x72>
    800004ec:	74a2                	ld	s1,40(sp)
}
    800004ee:	70e2                	ld	ra,56(sp)
    800004f0:	7442                	ld	s0,48(sp)
    800004f2:	7902                	ld	s2,32(sp)
    800004f4:	6121                	addi	sp,sp,64
    800004f6:	8082                	ret
    x = -xx;
    800004f8:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004fc:	4305                	li	t1,1
    x = -xx;
    800004fe:	b741                	j	8000047e <printint+0x12>

0000000080000500 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    80000500:	7131                	addi	sp,sp,-192
    80000502:	fc86                	sd	ra,120(sp)
    80000504:	f8a2                	sd	s0,112(sp)
    80000506:	f4a6                	sd	s1,104(sp)
    80000508:	0100                	addi	s0,sp,128
    8000050a:	84aa                	mv	s1,a0
    8000050c:	e40c                	sd	a1,8(s0)
    8000050e:	e810                	sd	a2,16(s0)
    80000510:	ec14                	sd	a3,24(s0)
    80000512:	f018                	sd	a4,32(s0)
    80000514:	f41c                	sd	a5,40(s0)
    80000516:	03043823          	sd	a6,48(s0)
    8000051a:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    8000051e:	00007797          	auipc	a5,0x7
    80000522:	3267a783          	lw	a5,806(a5) # 80007844 <panicking>
    80000526:	cf9d                	beqz	a5,80000564 <printf+0x64>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000528:	00840793          	addi	a5,s0,8
    8000052c:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000530:	0004c503          	lbu	a0,0(s1)
    80000534:	22050363          	beqz	a0,8000075a <printf+0x25a>
    80000538:	f0ca                	sd	s2,96(sp)
    8000053a:	ecce                	sd	s3,88(sp)
    8000053c:	e8d2                	sd	s4,80(sp)
    8000053e:	e4d6                	sd	s5,72(sp)
    80000540:	e0da                	sd	s6,64(sp)
    80000542:	fc5e                	sd	s7,56(sp)
    80000544:	f862                	sd	s8,48(sp)
    80000546:	f06a                	sd	s10,32(sp)
    80000548:	ec6e                	sd	s11,24(sp)
    8000054a:	4a01                	li	s4,0
    if(cx != '%'){
    8000054c:	02500993          	li	s3,37
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    80000550:	07500c13          	li	s8,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000554:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000558:	07000d93          	li	s11,112
      printint(va_arg(ap, uint64), 10, 0);
    8000055c:	4b29                	li	s6,10
    if(c0 == 'd'){
    8000055e:	06400b93          	li	s7,100
    80000562:	a015                	j	80000586 <printf+0x86>
    acquire(&pr.lock);
    80000564:	0000f517          	auipc	a0,0xf
    80000568:	3b450513          	addi	a0,a0,948 # 8000f918 <pr>
    8000056c:	6cc000ef          	jal	80000c38 <acquire>
    80000570:	bf65                	j	80000528 <printf+0x28>
      consputc(cx);
    80000572:	d09ff0ef          	jal	8000027a <consputc>
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000576:	001a079b          	addiw	a5,s4,1
    8000057a:	8a3e                	mv	s4,a5
    8000057c:	97a6                	add	a5,a5,s1
    8000057e:	0007c503          	lbu	a0,0(a5)
    80000582:	1c050363          	beqz	a0,80000748 <printf+0x248>
    if(cx != '%'){
    80000586:	ff3516e3          	bne	a0,s3,80000572 <printf+0x72>
    i++;
    8000058a:	001a091b          	addiw	s2,s4,1
    c0 = fmt[i+0] & 0xff;
    8000058e:	012487b3          	add	a5,s1,s2
    80000592:	0007ca83          	lbu	s5,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000596:	200a8763          	beqz	s5,800007a4 <printf+0x2a4>
    8000059a:	0017c703          	lbu	a4,1(a5)
    if(c1) c2 = fmt[i+2] & 0xff;
    8000059e:	1e070a63          	beqz	a4,80000792 <printf+0x292>
    if(c0 == 'd'){
    800005a2:	037a8963          	beq	s5,s7,800005d4 <printf+0xd4>
    } else if(c0 == 'l' && c1 == 'd'){
    800005a6:	f94a8793          	addi	a5,s5,-108
    800005aa:	0017b793          	seqz	a5,a5
    800005ae:	f9c70693          	addi	a3,a4,-100
    800005b2:	0016b693          	seqz	a3,a3
    800005b6:	8efd                	and	a3,a3,a5
    800005b8:	ca9d                	beqz	a3,800005ee <printf+0xee>
      printint(va_arg(ap, uint64), 10, 1);
    800005ba:	f8843783          	ld	a5,-120(s0)
    800005be:	00878713          	addi	a4,a5,8
    800005c2:	f8e43423          	sd	a4,-120(s0)
    800005c6:	4605                	li	a2,1
    800005c8:	85da                	mv	a1,s6
    800005ca:	6388                	ld	a0,0(a5)
    800005cc:	ea1ff0ef          	jal	8000046c <printint>
      i += 1;
    800005d0:	2a09                	addiw	s4,s4,2
    800005d2:	b755                	j	80000576 <printf+0x76>
      printint(va_arg(ap, int), 10, 1);
    800005d4:	f8843783          	ld	a5,-120(s0)
    800005d8:	00878713          	addi	a4,a5,8
    800005dc:	f8e43423          	sd	a4,-120(s0)
    800005e0:	4605                	li	a2,1
    800005e2:	85da                	mv	a1,s6
    800005e4:	4388                	lw	a0,0(a5)
    800005e6:	e87ff0ef          	jal	8000046c <printint>
    i++;
    800005ea:	8a4a                	mv	s4,s2
    800005ec:	b769                	j	80000576 <printf+0x76>
    if(c1) c2 = fmt[i+2] & 0xff;
    800005ee:	012486b3          	add	a3,s1,s2
    800005f2:	863a                	mv	a2,a4
    800005f4:	0026c703          	lbu	a4,2(a3)
    800005f8:	aa65                	j	800007b0 <printf+0x2b0>
      printint(va_arg(ap, uint64), 10, 1);
    800005fa:	f8843783          	ld	a5,-120(s0)
    800005fe:	00878713          	addi	a4,a5,8
    80000602:	f8e43423          	sd	a4,-120(s0)
    80000606:	4605                	li	a2,1
    80000608:	45a9                	li	a1,10
    8000060a:	6388                	ld	a0,0(a5)
    8000060c:	e61ff0ef          	jal	8000046c <printint>
      i += 2;
    80000610:	2a0d                	addiw	s4,s4,3
    80000612:	b795                	j	80000576 <printf+0x76>
      printint(va_arg(ap, uint32), 10, 0);
    80000614:	f8843783          	ld	a5,-120(s0)
    80000618:	00878713          	addi	a4,a5,8
    8000061c:	f8e43423          	sd	a4,-120(s0)
    80000620:	4601                	li	a2,0
    80000622:	85da                	mv	a1,s6
    80000624:	0007e503          	lwu	a0,0(a5)
    80000628:	e45ff0ef          	jal	8000046c <printint>
    8000062c:	bf7d                	j	800005ea <printf+0xea>
      printint(va_arg(ap, uint64), 10, 0);
    8000062e:	f8843783          	ld	a5,-120(s0)
    80000632:	00878713          	addi	a4,a5,8
    80000636:	f8e43423          	sd	a4,-120(s0)
    8000063a:	4601                	li	a2,0
    8000063c:	85da                	mv	a1,s6
    8000063e:	6388                	ld	a0,0(a5)
    80000640:	e2dff0ef          	jal	8000046c <printint>
      i += 1;
    80000644:	2a09                	addiw	s4,s4,2
    80000646:	bf05                	j	80000576 <printf+0x76>
      printint(va_arg(ap, uint64), 10, 0);
    80000648:	f8843783          	ld	a5,-120(s0)
    8000064c:	00878713          	addi	a4,a5,8
    80000650:	f8e43423          	sd	a4,-120(s0)
    80000654:	4601                	li	a2,0
    80000656:	45a9                	li	a1,10
    80000658:	6388                	ld	a0,0(a5)
    8000065a:	e13ff0ef          	jal	8000046c <printint>
      i += 2;
    8000065e:	2a0d                	addiw	s4,s4,3
    80000660:	bf19                	j	80000576 <printf+0x76>
      printint(va_arg(ap, uint32), 16, 0);
    80000662:	f8843783          	ld	a5,-120(s0)
    80000666:	00878713          	addi	a4,a5,8
    8000066a:	f8e43423          	sd	a4,-120(s0)
    8000066e:	4601                	li	a2,0
    80000670:	45c1                	li	a1,16
    80000672:	0007e503          	lwu	a0,0(a5)
    80000676:	df7ff0ef          	jal	8000046c <printint>
    8000067a:	bf85                	j	800005ea <printf+0xea>
      printint(va_arg(ap, uint64), 16, 0);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4601                	li	a2,0
    8000068a:	45c1                	li	a1,16
    8000068c:	6388                	ld	a0,0(a5)
    8000068e:	ddfff0ef          	jal	8000046c <printint>
      i += 1;
    80000692:	2a09                	addiw	s4,s4,2
    80000694:	b5cd                	j	80000576 <printf+0x76>
      printint(va_arg(ap, uint64), 16, 0);
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	addi	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	45c1                	li	a1,16
    800006a4:	6388                	ld	a0,0(a5)
    800006a6:	dc7ff0ef          	jal	8000046c <printint>
      i += 2;
    800006aa:	2a0d                	addiw	s4,s4,3
    800006ac:	b5e9                	j	80000576 <printf+0x76>
    800006ae:	f466                	sd	s9,40(sp)
      printptr(va_arg(ap, uint64));
    800006b0:	f8843783          	ld	a5,-120(s0)
    800006b4:	00878713          	addi	a4,a5,8
    800006b8:	f8e43423          	sd	a4,-120(s0)
    800006bc:	0007ba83          	ld	s5,0(a5)
  consputc('0');
    800006c0:	03000513          	li	a0,48
    800006c4:	bb7ff0ef          	jal	8000027a <consputc>
  consputc('x');
    800006c8:	07800513          	li	a0,120
    800006cc:	bafff0ef          	jal	8000027a <consputc>
    800006d0:	4a41                	li	s4,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006d2:	00007c97          	auipc	s9,0x7
    800006d6:	03ec8c93          	addi	s9,s9,62 # 80007710 <digits>
    800006da:	03cad793          	srli	a5,s5,0x3c
    800006de:	97e6                	add	a5,a5,s9
    800006e0:	0007c503          	lbu	a0,0(a5)
    800006e4:	b97ff0ef          	jal	8000027a <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006e8:	0a92                	slli	s5,s5,0x4
    800006ea:	3a7d                	addiw	s4,s4,-1
    800006ec:	fe0a17e3          	bnez	s4,800006da <printf+0x1da>
    800006f0:	7ca2                	ld	s9,40(sp)
    800006f2:	bde5                	j	800005ea <printf+0xea>
    } else if(c0 == 'c'){
      consputc(va_arg(ap, uint));
    800006f4:	f8843783          	ld	a5,-120(s0)
    800006f8:	00878713          	addi	a4,a5,8
    800006fc:	f8e43423          	sd	a4,-120(s0)
    80000700:	4388                	lw	a0,0(a5)
    80000702:	b79ff0ef          	jal	8000027a <consputc>
    80000706:	b5d5                	j	800005ea <printf+0xea>
    } else if(c0 == 's'){
      if((s = va_arg(ap, char*)) == 0)
    80000708:	f8843783          	ld	a5,-120(s0)
    8000070c:	00878713          	addi	a4,a5,8
    80000710:	f8e43423          	sd	a4,-120(s0)
    80000714:	0007ba03          	ld	s4,0(a5)
    80000718:	000a0d63          	beqz	s4,80000732 <printf+0x232>
        s = "(null)";
      for(; *s; s++)
    8000071c:	000a4503          	lbu	a0,0(s4)
    80000720:	ec0505e3          	beqz	a0,800005ea <printf+0xea>
        consputc(*s);
    80000724:	b57ff0ef          	jal	8000027a <consputc>
      for(; *s; s++)
    80000728:	0a05                	addi	s4,s4,1
    8000072a:	000a4503          	lbu	a0,0(s4)
    8000072e:	f97d                	bnez	a0,80000724 <printf+0x224>
    80000730:	bd6d                	j	800005ea <printf+0xea>
        s = "(null)";
    80000732:	00007a17          	auipc	s4,0x7
    80000736:	8d6a0a13          	addi	s4,s4,-1834 # 80007008 <etext+0x8>
      for(; *s; s++)
    8000073a:	02800513          	li	a0,40
    8000073e:	b7dd                	j	80000724 <printf+0x224>
    } else if(c0 == '%'){
      consputc('%');
    80000740:	8556                	mv	a0,s5
    80000742:	b39ff0ef          	jal	8000027a <consputc>
    80000746:	b555                	j	800005ea <printf+0xea>
    80000748:	7906                	ld	s2,96(sp)
    8000074a:	69e6                	ld	s3,88(sp)
    8000074c:	6a46                	ld	s4,80(sp)
    8000074e:	6aa6                	ld	s5,72(sp)
    80000750:	6b06                	ld	s6,64(sp)
    80000752:	7be2                	ld	s7,56(sp)
    80000754:	7c42                	ld	s8,48(sp)
    80000756:	7d02                	ld	s10,32(sp)
    80000758:	6de2                	ld	s11,24(sp)
    }

  }
  va_end(ap);

  if(panicking == 0)
    8000075a:	00007797          	auipc	a5,0x7
    8000075e:	0ea7a783          	lw	a5,234(a5) # 80007844 <panicking>
    80000762:	c38d                	beqz	a5,80000784 <printf+0x284>
    release(&pr.lock);

  return 0;
}
    80000764:	4501                	li	a0,0
    80000766:	70e6                	ld	ra,120(sp)
    80000768:	7446                	ld	s0,112(sp)
    8000076a:	74a6                	ld	s1,104(sp)
    8000076c:	6129                	addi	sp,sp,192
    8000076e:	8082                	ret
    80000770:	7906                	ld	s2,96(sp)
    80000772:	69e6                	ld	s3,88(sp)
    80000774:	6a46                	ld	s4,80(sp)
    80000776:	6aa6                	ld	s5,72(sp)
    80000778:	6b06                	ld	s6,64(sp)
    8000077a:	7be2                	ld	s7,56(sp)
    8000077c:	7c42                	ld	s8,48(sp)
    8000077e:	7d02                	ld	s10,32(sp)
    80000780:	6de2                	ld	s11,24(sp)
    80000782:	bfe1                	j	8000075a <printf+0x25a>
    release(&pr.lock);
    80000784:	0000f517          	auipc	a0,0xf
    80000788:	19450513          	addi	a0,a0,404 # 8000f918 <pr>
    8000078c:	53c000ef          	jal	80000cc8 <release>
  return 0;
    80000790:	bfd1                	j	80000764 <printf+0x264>
    if(c0 == 'd'){
    80000792:	e57a81e3          	beq	s5,s7,800005d4 <printf+0xd4>
    } else if(c0 == 'l' && c1 == 'd'){
    80000796:	f94a8793          	addi	a5,s5,-108
    8000079a:	0017b793          	seqz	a5,a5
    8000079e:	863a                	mv	a2,a4
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800007a0:	4681                	li	a3,0
    800007a2:	a01d                	j	800007c8 <printf+0x2c8>
    } else if(c0 == 'l' && c1 == 'd'){
    800007a4:	f94a8793          	addi	a5,s5,-108
    800007a8:	0017b793          	seqz	a5,a5
    c1 = c2 = 0;
    800007ac:	8656                	mv	a2,s5
    800007ae:	8756                	mv	a4,s5
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800007b0:	f9460693          	addi	a3,a2,-108
    800007b4:	0016b693          	seqz	a3,a3
    800007b8:	8efd                	and	a3,a3,a5
    800007ba:	f9c70593          	addi	a1,a4,-100
    800007be:	0015b593          	seqz	a1,a1
    800007c2:	8df5                	and	a1,a1,a3
    800007c4:	e2059be3          	bnez	a1,800005fa <printf+0xfa>
    } else if(c0 == 'u'){
    800007c8:	e58a86e3          	beq	s5,s8,80000614 <printf+0x114>
    } else if(c0 == 'l' && c1 == 'u'){
    800007cc:	f8b60593          	addi	a1,a2,-117
    800007d0:	0015b593          	seqz	a1,a1
    800007d4:	8dfd                	and	a1,a1,a5
    800007d6:	e4059ce3          	bnez	a1,8000062e <printf+0x12e>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800007da:	f8b70593          	addi	a1,a4,-117
    800007de:	0015b593          	seqz	a1,a1
    800007e2:	8df5                	and	a1,a1,a3
    800007e4:	e60592e3          	bnez	a1,80000648 <printf+0x148>
    } else if(c0 == 'x'){
    800007e8:	e7aa8de3          	beq	s5,s10,80000662 <printf+0x162>
    } else if(c0 == 'l' && c1 == 'x'){
    800007ec:	f8860613          	addi	a2,a2,-120
    800007f0:	00163613          	seqz	a2,a2
    800007f4:	8e7d                	and	a2,a2,a5
    800007f6:	e80613e3          	bnez	a2,8000067c <printf+0x17c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    800007fa:	f8870713          	addi	a4,a4,-120
    800007fe:	00173713          	seqz	a4,a4
    80000802:	8f75                	and	a4,a4,a3
    80000804:	e80719e3          	bnez	a4,80000696 <printf+0x196>
    } else if(c0 == 'p'){
    80000808:	ebba83e3          	beq	s5,s11,800006ae <printf+0x1ae>
    } else if(c0 == 'c'){
    8000080c:	06300793          	li	a5,99
    80000810:	eefa82e3          	beq	s5,a5,800006f4 <printf+0x1f4>
    } else if(c0 == 's'){
    80000814:	07300793          	li	a5,115
    80000818:	eefa88e3          	beq	s5,a5,80000708 <printf+0x208>
    } else if(c0 == '%'){
    8000081c:	02500793          	li	a5,37
    80000820:	f2fa80e3          	beq	s5,a5,80000740 <printf+0x240>
    } else if(c0 == 0){
    80000824:	f40a86e3          	beqz	s5,80000770 <printf+0x270>
      consputc('%');
    80000828:	02500513          	li	a0,37
    8000082c:	a4fff0ef          	jal	8000027a <consputc>
      consputc(c0);
    80000830:	8556                	mv	a0,s5
    80000832:	a49ff0ef          	jal	8000027a <consputc>
    80000836:	bb55                	j	800005ea <printf+0xea>

0000000080000838 <panic>:

void
panic(char *s)
{
    80000838:	1101                	addi	sp,sp,-32
    8000083a:	ec06                	sd	ra,24(sp)
    8000083c:	e822                	sd	s0,16(sp)
    8000083e:	e426                	sd	s1,8(sp)
    80000840:	e04a                	sd	s2,0(sp)
    80000842:	1000                	addi	s0,sp,32
    80000844:	892a                	mv	s2,a0
  panicking = 1;
    80000846:	4485                	li	s1,1
    80000848:	00007797          	auipc	a5,0x7
    8000084c:	fe97ae23          	sw	s1,-4(a5) # 80007844 <panicking>
  printf("panic: ");
    80000850:	00006517          	auipc	a0,0x6
    80000854:	7c850513          	addi	a0,a0,1992 # 80007018 <etext+0x18>
    80000858:	ca9ff0ef          	jal	80000500 <printf>
  printf("%s\n", s);
    8000085c:	85ca                	mv	a1,s2
    8000085e:	00006517          	auipc	a0,0x6
    80000862:	7c250513          	addi	a0,a0,1986 # 80007020 <etext+0x20>
    80000866:	c9bff0ef          	jal	80000500 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000086a:	00007797          	auipc	a5,0x7
    8000086e:	fc97ab23          	sw	s1,-42(a5) # 80007840 <panicked>
  for(;;)
    80000872:	a001                	j	80000872 <panic+0x3a>

0000000080000874 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000874:	1141                	addi	sp,sp,-16
    80000876:	e406                	sd	ra,8(sp)
    80000878:	e022                	sd	s0,0(sp)
    8000087a:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    8000087c:	00006597          	auipc	a1,0x6
    80000880:	7ac58593          	addi	a1,a1,1964 # 80007028 <etext+0x28>
    80000884:	0000f517          	auipc	a0,0xf
    80000888:	09450513          	addi	a0,a0,148 # 8000f918 <pr>
    8000088c:	322000ef          	jal	80000bae <initlock>
}
    80000890:	60a2                	ld	ra,8(sp)
    80000892:	6402                	ld	s0,0(sp)
    80000894:	0141                	addi	sp,sp,16
    80000896:	8082                	ret

0000000080000898 <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    80000898:	1141                	addi	sp,sp,-16
    8000089a:	e406                	sd	ra,8(sp)
    8000089c:	e022                	sd	s0,0(sp)
    8000089e:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800008a0:	100007b7          	lui	a5,0x10000
    800008a4:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800008a8:	10000737          	lui	a4,0x10000
    800008ac:	f8000693          	li	a3,-128
    800008b0:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800008b4:	468d                	li	a3,3
    800008b6:	10000637          	lui	a2,0x10000
    800008ba:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800008be:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800008c2:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800008c6:	8732                	mv	a4,a2
    800008c8:	461d                	li	a2,7
    800008ca:	00c70123          	sb	a2,2(a4)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800008ce:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    800008d2:	00006597          	auipc	a1,0x6
    800008d6:	75e58593          	addi	a1,a1,1886 # 80007030 <etext+0x30>
    800008da:	0000f517          	auipc	a0,0xf
    800008de:	05650513          	addi	a0,a0,86 # 8000f930 <tx_lock>
    800008e2:	2cc000ef          	jal	80000bae <initlock>
}
    800008e6:	60a2                	ld	ra,8(sp)
    800008e8:	6402                	ld	s0,0(sp)
    800008ea:	0141                	addi	sp,sp,16
    800008ec:	8082                	ret

00000000800008ee <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    800008ee:	715d                	addi	sp,sp,-80
    800008f0:	e486                	sd	ra,72(sp)
    800008f2:	e0a2                	sd	s0,64(sp)
    800008f4:	fc26                	sd	s1,56(sp)
    800008f6:	ec56                	sd	s5,24(sp)
    800008f8:	0880                	addi	s0,sp,80
    800008fa:	8aaa                	mv	s5,a0
    800008fc:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    800008fe:	0000f517          	auipc	a0,0xf
    80000902:	03250513          	addi	a0,a0,50 # 8000f930 <tx_lock>
    80000906:	332000ef          	jal	80000c38 <acquire>

  int i = 0;
  while(i < n){ 
    8000090a:	06905063          	blez	s1,8000096a <uartwrite+0x7c>
    8000090e:	f84a                	sd	s2,48(sp)
    80000910:	f44e                	sd	s3,40(sp)
    80000912:	f052                	sd	s4,32(sp)
    80000914:	e85a                	sd	s6,16(sp)
    80000916:	e45e                	sd	s7,8(sp)
    80000918:	8a56                	mv	s4,s5
    8000091a:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    8000091c:	00007497          	auipc	s1,0x7
    80000920:	f3048493          	addi	s1,s1,-208 # 8000784c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000924:	0000f997          	auipc	s3,0xf
    80000928:	00c98993          	addi	s3,s3,12 # 8000f930 <tx_lock>
    8000092c:	00007917          	auipc	s2,0x7
    80000930:	f1c90913          	addi	s2,s2,-228 # 80007848 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    80000934:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    80000938:	4b05                	li	s6,1
    8000093a:	a005                	j	8000095a <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    8000093c:	85ce                	mv	a1,s3
    8000093e:	854a                	mv	a0,s2
    80000940:	5bc010ef          	jal	80001efc <sleep>
    while(tx_busy != 0){
    80000944:	409c                	lw	a5,0(s1)
    80000946:	fbfd                	bnez	a5,8000093c <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    80000948:	000a4783          	lbu	a5,0(s4)
    8000094c:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    80000950:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    80000954:	0a05                	addi	s4,s4,1
    80000956:	015a0563          	beq	s4,s5,80000960 <uartwrite+0x72>
    while(tx_busy != 0){
    8000095a:	409c                	lw	a5,0(s1)
    8000095c:	f3e5                	bnez	a5,8000093c <uartwrite+0x4e>
    8000095e:	b7ed                	j	80000948 <uartwrite+0x5a>
    80000960:	7942                	ld	s2,48(sp)
    80000962:	79a2                	ld	s3,40(sp)
    80000964:	7a02                	ld	s4,32(sp)
    80000966:	6b42                	ld	s6,16(sp)
    80000968:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    8000096a:	0000f517          	auipc	a0,0xf
    8000096e:	fc650513          	addi	a0,a0,-58 # 8000f930 <tx_lock>
    80000972:	356000ef          	jal	80000cc8 <release>
}
    80000976:	60a6                	ld	ra,72(sp)
    80000978:	6406                	ld	s0,64(sp)
    8000097a:	74e2                	ld	s1,56(sp)
    8000097c:	6ae2                	ld	s5,24(sp)
    8000097e:	6161                	addi	sp,sp,80
    80000980:	8082                	ret

0000000080000982 <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000982:	1101                	addi	sp,sp,-32
    80000984:	ec06                	sd	ra,24(sp)
    80000986:	e822                	sd	s0,16(sp)
    80000988:	e426                	sd	s1,8(sp)
    8000098a:	1000                	addi	s0,sp,32
    8000098c:	84aa                	mv	s1,a0
  if(panicking == 0)
    8000098e:	00007797          	auipc	a5,0x7
    80000992:	eb67a783          	lw	a5,-330(a5) # 80007844 <panicking>
    80000996:	cb91                	beqz	a5,800009aa <uartputc_sync+0x28>
    push_off();

  if(panicked){
    80000998:	00007797          	auipc	a5,0x7
    8000099c:	ea87a783          	lw	a5,-344(a5) # 80007840 <panicked>
    for(;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800009a0:	10000737          	lui	a4,0x10000
    800009a4:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
  if(panicked){
    800009a6:	c789                	beqz	a5,800009b0 <uartputc_sync+0x2e>
    for(;;)
    800009a8:	a001                	j	800009a8 <uartputc_sync+0x26>
    push_off();
    800009aa:	24a000ef          	jal	80000bf4 <push_off>
    800009ae:	b7ed                	j	80000998 <uartputc_sync+0x16>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800009b0:	00074783          	lbu	a5,0(a4)
    800009b4:	0207f793          	andi	a5,a5,32
    800009b8:	dfe5                	beqz	a5,800009b0 <uartputc_sync+0x2e>
    ;
  WriteReg(THR, c);
    800009ba:	100007b7          	lui	a5,0x10000
    800009be:	00978023          	sb	s1,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    800009c2:	00007797          	auipc	a5,0x7
    800009c6:	e827a783          	lw	a5,-382(a5) # 80007844 <panicking>
    800009ca:	c791                	beqz	a5,800009d6 <uartputc_sync+0x54>
    pop_off();
}
    800009cc:	60e2                	ld	ra,24(sp)
    800009ce:	6442                	ld	s0,16(sp)
    800009d0:	64a2                	ld	s1,8(sp)
    800009d2:	6105                	addi	sp,sp,32
    800009d4:	8082                	ret
    pop_off();
    800009d6:	2a2000ef          	jal	80000c78 <pop_off>
}
    800009da:	bfcd                	j	800009cc <uartputc_sync+0x4a>

00000000800009dc <uartgetc>:

// try to read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009dc:	1141                	addi	sp,sp,-16
    800009de:	e406                	sd	ra,8(sp)
    800009e0:	e022                	sd	s0,0(sp)
    800009e2:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    800009e4:	100007b7          	lui	a5,0x10000
    800009e8:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009ec:	8b85                	andi	a5,a5,1
    800009ee:	cb89                	beqz	a5,80000a00 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009f0:	100007b7          	lui	a5,0x10000
    800009f4:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009f8:	60a2                	ld	ra,8(sp)
    800009fa:	6402                	ld	s0,0(sp)
    800009fc:	0141                	addi	sp,sp,16
    800009fe:	8082                	ret
    return -1;
    80000a00:	557d                	li	a0,-1
    80000a02:	bfdd                	j	800009f8 <uartgetc+0x1c>

0000000080000a04 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000a04:	1101                	addi	sp,sp,-32
    80000a06:	ec06                	sd	ra,24(sp)
    80000a08:	e822                	sd	s0,16(sp)
    80000a0a:	e426                	sd	s1,8(sp)
    80000a0c:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    80000a0e:	100007b7          	lui	a5,0x10000
    80000a12:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>

  acquire(&tx_lock);
    80000a16:	0000f517          	auipc	a0,0xf
    80000a1a:	f1a50513          	addi	a0,a0,-230 # 8000f930 <tx_lock>
    80000a1e:	21a000ef          	jal	80000c38 <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    80000a22:	100007b7          	lui	a5,0x10000
    80000a26:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000a2a:	0207f793          	andi	a5,a5,32
    80000a2e:	ef99                	bnez	a5,80000a4c <uartintr+0x48>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    80000a30:	0000f517          	auipc	a0,0xf
    80000a34:	f0050513          	addi	a0,a0,-256 # 8000f930 <tx_lock>
    80000a38:	290000ef          	jal	80000cc8 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a3c:	54fd                	li	s1,-1
    int c = uartgetc();
    80000a3e:	f9fff0ef          	jal	800009dc <uartgetc>
    if(c == -1)
    80000a42:	02950063          	beq	a0,s1,80000a62 <uartintr+0x5e>
      break;
    consoleintr(c);
    80000a46:	867ff0ef          	jal	800002ac <consoleintr>
  while(1){
    80000a4a:	bfd5                	j	80000a3e <uartintr+0x3a>
    tx_busy = 0;
    80000a4c:	00007797          	auipc	a5,0x7
    80000a50:	e007a023          	sw	zero,-512(a5) # 8000784c <tx_busy>
    wakeup(&tx_chan);
    80000a54:	00007517          	auipc	a0,0x7
    80000a58:	df450513          	addi	a0,a0,-524 # 80007848 <tx_chan>
    80000a5c:	4ec010ef          	jal	80001f48 <wakeup>
    80000a60:	bfc1                	j	80000a30 <uartintr+0x2c>
  }
}
    80000a62:	60e2                	ld	ra,24(sp)
    80000a64:	6442                	ld	s0,16(sp)
    80000a66:	64a2                	ld	s1,8(sp)
    80000a68:	6105                	addi	sp,sp,32
    80000a6a:	8082                	ret

0000000080000a6c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a6c:	1101                	addi	sp,sp,-32
    80000a6e:	ec06                	sd	ra,24(sp)
    80000a70:	e822                	sd	s0,16(sp)
    80000a72:	e426                	sd	s1,8(sp)
    80000a74:	e04a                	sd	s2,0(sp)
    80000a76:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a78:	00020797          	auipc	a5,0x20
    80000a7c:	10078793          	addi	a5,a5,256 # 80020b78 <end>
    80000a80:	00f53733          	sltu	a4,a0,a5
    80000a84:	47c5                	li	a5,17
    80000a86:	07ee                	slli	a5,a5,0x1b
    80000a88:	17fd                	addi	a5,a5,-1
    80000a8a:	00a7b7b3          	sltu	a5,a5,a0
    80000a8e:	8fd9                	or	a5,a5,a4
    80000a90:	03451713          	slli	a4,a0,0x34
    80000a94:	8fd9                	or	a5,a5,a4
    80000a96:	eb9d                	bnez	a5,80000acc <kfree+0x60>
    80000a98:	84aa                	mv	s1,a0
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a9a:	6605                	lui	a2,0x1
    80000a9c:	4585                	li	a1,1
    80000a9e:	266000ef          	jal	80000d04 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000aa2:	0000f917          	auipc	s2,0xf
    80000aa6:	ea690913          	addi	s2,s2,-346 # 8000f948 <kmem>
    80000aaa:	854a                	mv	a0,s2
    80000aac:	18c000ef          	jal	80000c38 <acquire>
  r->next = kmem.freelist;
    80000ab0:	01893783          	ld	a5,24(s2)
    80000ab4:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000ab6:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000aba:	854a                	mv	a0,s2
    80000abc:	20c000ef          	jal	80000cc8 <release>
}
    80000ac0:	60e2                	ld	ra,24(sp)
    80000ac2:	6442                	ld	s0,16(sp)
    80000ac4:	64a2                	ld	s1,8(sp)
    80000ac6:	6902                	ld	s2,0(sp)
    80000ac8:	6105                	addi	sp,sp,32
    80000aca:	8082                	ret
    panic("kfree");
    80000acc:	00006517          	auipc	a0,0x6
    80000ad0:	56c50513          	addi	a0,a0,1388 # 80007038 <etext+0x38>
    80000ad4:	d65ff0ef          	jal	80000838 <panic>

0000000080000ad8 <freerange>:
{
    80000ad8:	7179                	addi	sp,sp,-48
    80000ada:	f406                	sd	ra,40(sp)
    80000adc:	f022                	sd	s0,32(sp)
    80000ade:	ec26                	sd	s1,24(sp)
    80000ae0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ae2:	6785                	lui	a5,0x1
    80000ae4:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ae8:	00e504b3          	add	s1,a0,a4
    80000aec:	777d                	lui	a4,0xfffff
    80000aee:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000af0:	94be                	add	s1,s1,a5
    80000af2:	0295e263          	bltu	a1,s1,80000b16 <freerange+0x3e>
    80000af6:	e84a                	sd	s2,16(sp)
    80000af8:	e44e                	sd	s3,8(sp)
    80000afa:	e052                	sd	s4,0(sp)
    80000afc:	892e                	mv	s2,a1
    kfree(p);
    80000afe:	8a3a                	mv	s4,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b00:	89be                	mv	s3,a5
    kfree(p);
    80000b02:	01448533          	add	a0,s1,s4
    80000b06:	f67ff0ef          	jal	80000a6c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b0a:	94ce                	add	s1,s1,s3
    80000b0c:	fe997be3          	bgeu	s2,s1,80000b02 <freerange+0x2a>
    80000b10:	6942                	ld	s2,16(sp)
    80000b12:	69a2                	ld	s3,8(sp)
    80000b14:	6a02                	ld	s4,0(sp)
}
    80000b16:	70a2                	ld	ra,40(sp)
    80000b18:	7402                	ld	s0,32(sp)
    80000b1a:	64e2                	ld	s1,24(sp)
    80000b1c:	6145                	addi	sp,sp,48
    80000b1e:	8082                	ret

0000000080000b20 <kinit>:
{
    80000b20:	1141                	addi	sp,sp,-16
    80000b22:	e406                	sd	ra,8(sp)
    80000b24:	e022                	sd	s0,0(sp)
    80000b26:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b28:	00006597          	auipc	a1,0x6
    80000b2c:	51858593          	addi	a1,a1,1304 # 80007040 <etext+0x40>
    80000b30:	0000f517          	auipc	a0,0xf
    80000b34:	e1850513          	addi	a0,a0,-488 # 8000f948 <kmem>
    80000b38:	076000ef          	jal	80000bae <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b3c:	45c5                	li	a1,17
    80000b3e:	05ee                	slli	a1,a1,0x1b
    80000b40:	00020517          	auipc	a0,0x20
    80000b44:	03850513          	addi	a0,a0,56 # 80020b78 <end>
    80000b48:	f91ff0ef          	jal	80000ad8 <freerange>
}
    80000b4c:	60a2                	ld	ra,8(sp)
    80000b4e:	6402                	ld	s0,0(sp)
    80000b50:	0141                	addi	sp,sp,16
    80000b52:	8082                	ret

0000000080000b54 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b54:	1101                	addi	sp,sp,-32
    80000b56:	ec06                	sd	ra,24(sp)
    80000b58:	e822                	sd	s0,16(sp)
    80000b5a:	e426                	sd	s1,8(sp)
    80000b5c:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b5e:	0000f517          	auipc	a0,0xf
    80000b62:	dea50513          	addi	a0,a0,-534 # 8000f948 <kmem>
    80000b66:	0d2000ef          	jal	80000c38 <acquire>
  r = kmem.freelist;
    80000b6a:	0000f497          	auipc	s1,0xf
    80000b6e:	df64b483          	ld	s1,-522(s1) # 8000f960 <kmem+0x18>
  if(r)
    80000b72:	c49d                	beqz	s1,80000ba0 <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b74:	609c                	ld	a5,0(s1)
    80000b76:	0000f717          	auipc	a4,0xf
    80000b7a:	def73523          	sd	a5,-534(a4) # 8000f960 <kmem+0x18>
  release(&kmem.lock);
    80000b7e:	0000f517          	auipc	a0,0xf
    80000b82:	dca50513          	addi	a0,a0,-566 # 8000f948 <kmem>
    80000b86:	142000ef          	jal	80000cc8 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b8a:	6605                	lui	a2,0x1
    80000b8c:	4595                	li	a1,5
    80000b8e:	8526                	mv	a0,s1
    80000b90:	174000ef          	jal	80000d04 <memset>
  return (void*)r;
}
    80000b94:	8526                	mv	a0,s1
    80000b96:	60e2                	ld	ra,24(sp)
    80000b98:	6442                	ld	s0,16(sp)
    80000b9a:	64a2                	ld	s1,8(sp)
    80000b9c:	6105                	addi	sp,sp,32
    80000b9e:	8082                	ret
  release(&kmem.lock);
    80000ba0:	0000f517          	auipc	a0,0xf
    80000ba4:	da850513          	addi	a0,a0,-600 # 8000f948 <kmem>
    80000ba8:	120000ef          	jal	80000cc8 <release>
  if(r)
    80000bac:	b7e5                	j	80000b94 <kalloc+0x40>

0000000080000bae <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000bae:	1141                	addi	sp,sp,-16
    80000bb0:	e406                	sd	ra,8(sp)
    80000bb2:	e022                	sd	s0,0(sp)
    80000bb4:	0800                	addi	s0,sp,16
  lk->name = name;
    80000bb6:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bb8:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bbc:	00053823          	sd	zero,16(a0)
}
    80000bc0:	60a2                	ld	ra,8(sp)
    80000bc2:	6402                	ld	s0,0(sp)
    80000bc4:	0141                	addi	sp,sp,16
    80000bc6:	8082                	ret

0000000080000bc8 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bc8:	411c                	lw	a5,0(a0)
    80000bca:	e399                	bnez	a5,80000bd0 <holding+0x8>
    80000bcc:	4501                	li	a0,0
  return r;
}
    80000bce:	8082                	ret
{
    80000bd0:	1101                	addi	sp,sp,-32
    80000bd2:	ec06                	sd	ra,24(sp)
    80000bd4:	e822                	sd	s0,16(sp)
    80000bd6:	e426                	sd	s1,8(sp)
    80000bd8:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bda:	691c                	ld	a5,16(a0)
    80000bdc:	84be                	mv	s1,a5
    80000bde:	507000ef          	jal	800018e4 <mycpu>
    80000be2:	40a48533          	sub	a0,s1,a0
    80000be6:	00153513          	seqz	a0,a0
}
    80000bea:	60e2                	ld	ra,24(sp)
    80000bec:	6442                	ld	s0,16(sp)
    80000bee:	64a2                	ld	s1,8(sp)
    80000bf0:	6105                	addi	sp,sp,32
    80000bf2:	8082                	ret

0000000080000bf4 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bf4:	1101                	addi	sp,sp,-32
    80000bf6:	ec06                	sd	ra,24(sp)
    80000bf8:	e822                	sd	s0,16(sp)
    80000bfa:	e426                	sd	s1,8(sp)
    80000bfc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bfe:	100027f3          	csrr	a5,sstatus
    80000c02:	84be                	mv	s1,a5
    80000c04:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c08:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c0a:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000c0e:	4d7000ef          	jal	800018e4 <mycpu>
    80000c12:	5d3c                	lw	a5,120(a0)
    80000c14:	cb99                	beqz	a5,80000c2a <push_off+0x36>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c16:	4cf000ef          	jal	800018e4 <mycpu>
    80000c1a:	5d3c                	lw	a5,120(a0)
    80000c1c:	2785                	addiw	a5,a5,1
    80000c1e:	dd3c                	sw	a5,120(a0)
}
    80000c20:	60e2                	ld	ra,24(sp)
    80000c22:	6442                	ld	s0,16(sp)
    80000c24:	64a2                	ld	s1,8(sp)
    80000c26:	6105                	addi	sp,sp,32
    80000c28:	8082                	ret
    mycpu()->intena = old;
    80000c2a:	4bb000ef          	jal	800018e4 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c2e:	0014d793          	srli	a5,s1,0x1
    80000c32:	8b85                	andi	a5,a5,1
    80000c34:	dd7c                	sw	a5,124(a0)
    80000c36:	b7c5                	j	80000c16 <push_off+0x22>

0000000080000c38 <acquire>:
{
    80000c38:	1101                	addi	sp,sp,-32
    80000c3a:	ec06                	sd	ra,24(sp)
    80000c3c:	e822                	sd	s0,16(sp)
    80000c3e:	e426                	sd	s1,8(sp)
    80000c40:	1000                	addi	s0,sp,32
    80000c42:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c44:	fb1ff0ef          	jal	80000bf4 <push_off>
  if(holding(lk))
    80000c48:	8526                	mv	a0,s1
    80000c4a:	f7fff0ef          	jal	80000bc8 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c4e:	4705                	li	a4,1
  if(holding(lk))
    80000c50:	ed11                	bnez	a0,80000c6c <acquire+0x34>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c52:	0ce4a7af          	amoswap.w.aq	a5,a4,(s1)
    80000c56:	fff5                	bnez	a5,80000c52 <acquire+0x1a>
  __sync_synchronize();
    80000c58:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c5c:	489000ef          	jal	800018e4 <mycpu>
    80000c60:	e888                	sd	a0,16(s1)
}
    80000c62:	60e2                	ld	ra,24(sp)
    80000c64:	6442                	ld	s0,16(sp)
    80000c66:	64a2                	ld	s1,8(sp)
    80000c68:	6105                	addi	sp,sp,32
    80000c6a:	8082                	ret
    panic("acquire");
    80000c6c:	00006517          	auipc	a0,0x6
    80000c70:	3dc50513          	addi	a0,a0,988 # 80007048 <etext+0x48>
    80000c74:	bc5ff0ef          	jal	80000838 <panic>

0000000080000c78 <pop_off>:

void
pop_off(void)
{
    80000c78:	1141                	addi	sp,sp,-16
    80000c7a:	e406                	sd	ra,8(sp)
    80000c7c:	e022                	sd	s0,0(sp)
    80000c7e:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c80:	465000ef          	jal	800018e4 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c84:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c88:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c8a:	e39d                	bnez	a5,80000cb0 <pop_off+0x38>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c8c:	5d3c                	lw	a5,120(a0)
    80000c8e:	02f05763          	blez	a5,80000cbc <pop_off+0x44>
    panic("pop_off");
  c->noff -= 1;
    80000c92:	37fd                	addiw	a5,a5,-1
    80000c94:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c96:	eb89                	bnez	a5,80000ca8 <pop_off+0x30>
    80000c98:	5d7c                	lw	a5,124(a0)
    80000c9a:	c799                	beqz	a5,80000ca8 <pop_off+0x30>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c9c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000ca0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000ca4:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000ca8:	60a2                	ld	ra,8(sp)
    80000caa:	6402                	ld	s0,0(sp)
    80000cac:	0141                	addi	sp,sp,16
    80000cae:	8082                	ret
    panic("pop_off - interruptible");
    80000cb0:	00006517          	auipc	a0,0x6
    80000cb4:	3a050513          	addi	a0,a0,928 # 80007050 <etext+0x50>
    80000cb8:	b81ff0ef          	jal	80000838 <panic>
    panic("pop_off");
    80000cbc:	00006517          	auipc	a0,0x6
    80000cc0:	3ac50513          	addi	a0,a0,940 # 80007068 <etext+0x68>
    80000cc4:	b75ff0ef          	jal	80000838 <panic>

0000000080000cc8 <release>:
{
    80000cc8:	1101                	addi	sp,sp,-32
    80000cca:	ec06                	sd	ra,24(sp)
    80000ccc:	e822                	sd	s0,16(sp)
    80000cce:	e426                	sd	s1,8(sp)
    80000cd0:	1000                	addi	s0,sp,32
    80000cd2:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cd4:	ef5ff0ef          	jal	80000bc8 <holding>
    80000cd8:	c105                	beqz	a0,80000cf8 <release+0x30>
  lk->cpu = 0;
    80000cda:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cde:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000ce2:	0310000f          	fence	rw,w
    80000ce6:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000cea:	f8fff0ef          	jal	80000c78 <pop_off>
}
    80000cee:	60e2                	ld	ra,24(sp)
    80000cf0:	6442                	ld	s0,16(sp)
    80000cf2:	64a2                	ld	s1,8(sp)
    80000cf4:	6105                	addi	sp,sp,32
    80000cf6:	8082                	ret
    panic("release");
    80000cf8:	00006517          	auipc	a0,0x6
    80000cfc:	37850513          	addi	a0,a0,888 # 80007070 <etext+0x70>
    80000d00:	b39ff0ef          	jal	80000838 <panic>

0000000080000d04 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d04:	1141                	addi	sp,sp,-16
    80000d06:	e406                	sd	ra,8(sp)
    80000d08:	e022                	sd	s0,0(sp)
    80000d0a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d0c:	ca19                	beqz	a2,80000d22 <memset+0x1e>
    80000d0e:	87aa                	mv	a5,a0
    80000d10:	1602                	slli	a2,a2,0x20
    80000d12:	9201                	srli	a2,a2,0x20
    80000d14:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d18:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d1c:	0785                	addi	a5,a5,1
    80000d1e:	fee79de3          	bne	a5,a4,80000d18 <memset+0x14>
  }
  return dst;
}
    80000d22:	60a2                	ld	ra,8(sp)
    80000d24:	6402                	ld	s0,0(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret

0000000080000d2a <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d2a:	1141                	addi	sp,sp,-16
    80000d2c:	e406                	sd	ra,8(sp)
    80000d2e:	e022                	sd	s0,0(sp)
    80000d30:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d32:	ce19                	beqz	a2,80000d50 <memcmp+0x26>
    80000d34:	1602                	slli	a2,a2,0x20
    80000d36:	9201                	srli	a2,a2,0x20
    80000d38:	00c506b3          	add	a3,a0,a2
    if(*s1 != *s2)
    80000d3c:	00054783          	lbu	a5,0(a0)
    80000d40:	0005c703          	lbu	a4,0(a1)
    80000d44:	00e79b63          	bne	a5,a4,80000d5a <memcmp+0x30>
      return *s1 - *s2;
    s1++, s2++;
    80000d48:	0505                	addi	a0,a0,1
    80000d4a:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d4c:	fed518e3          	bne	a0,a3,80000d3c <memcmp+0x12>
  }

  return 0;
    80000d50:	4501                	li	a0,0
}
    80000d52:	60a2                	ld	ra,8(sp)
    80000d54:	6402                	ld	s0,0(sp)
    80000d56:	0141                	addi	sp,sp,16
    80000d58:	8082                	ret
      return *s1 - *s2;
    80000d5a:	40e7853b          	subw	a0,a5,a4
    80000d5e:	bfd5                	j	80000d52 <memcmp+0x28>

0000000080000d60 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d60:	1141                	addi	sp,sp,-16
    80000d62:	e406                	sd	ra,8(sp)
    80000d64:	e022                	sd	s0,0(sp)
    80000d66:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d68:	c61d                	beqz	a2,80000d96 <memmove+0x36>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d6a:	00a5f963          	bgeu	a1,a0,80000d7c <memmove+0x1c>
    80000d6e:	02061693          	slli	a3,a2,0x20
    80000d72:	9281                	srli	a3,a3,0x20
    80000d74:	00d58733          	add	a4,a1,a3
    80000d78:	02e56363          	bltu	a0,a4,80000d9e <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d7c:	1602                	slli	a2,a2,0x20
    80000d7e:	9201                	srli	a2,a2,0x20
    80000d80:	00c587b3          	add	a5,a1,a2
{
    80000d84:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d86:	0585                	addi	a1,a1,1
    80000d88:	0705                	addi	a4,a4,1
    80000d8a:	fff5c683          	lbu	a3,-1(a1)
    80000d8e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d92:	fef59ae3          	bne	a1,a5,80000d86 <memmove+0x26>

  return dst;
}
    80000d96:	60a2                	ld	ra,8(sp)
    80000d98:	6402                	ld	s0,0(sp)
    80000d9a:	0141                	addi	sp,sp,16
    80000d9c:	8082                	ret
    d += n;
    80000d9e:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000da0:	fff6079b          	addiw	a5,a2,-1 # fff <_entry-0x7ffff001>
    80000da4:	1782                	slli	a5,a5,0x20
    80000da6:	9381                	srli	a5,a5,0x20
    80000da8:	fff7c793          	not	a5,a5
    80000dac:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000dae:	177d                	addi	a4,a4,-1
    80000db0:	16fd                	addi	a3,a3,-1
    80000db2:	00074603          	lbu	a2,0(a4)
    80000db6:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000dba:	fee79ae3          	bne	a5,a4,80000dae <memmove+0x4e>
    80000dbe:	bfe1                	j	80000d96 <memmove+0x36>

0000000080000dc0 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000dc0:	1141                	addi	sp,sp,-16
    80000dc2:	e406                	sd	ra,8(sp)
    80000dc4:	e022                	sd	s0,0(sp)
    80000dc6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000dc8:	f99ff0ef          	jal	80000d60 <memmove>
}
    80000dcc:	60a2                	ld	ra,8(sp)
    80000dce:	6402                	ld	s0,0(sp)
    80000dd0:	0141                	addi	sp,sp,16
    80000dd2:	8082                	ret

0000000080000dd4 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000dd4:	1141                	addi	sp,sp,-16
    80000dd6:	e406                	sd	ra,8(sp)
    80000dd8:	e022                	sd	s0,0(sp)
    80000dda:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000ddc:	ce01                	beqz	a2,80000df4 <strncmp+0x20>
    80000dde:	00054783          	lbu	a5,0(a0)
    80000de2:	cb99                	beqz	a5,80000df8 <strncmp+0x24>
    80000de4:	0005c703          	lbu	a4,0(a1)
    80000de8:	00f71863          	bne	a4,a5,80000df8 <strncmp+0x24>
    n--, p++, q++;
    80000dec:	367d                	addiw	a2,a2,-1
    80000dee:	0505                	addi	a0,a0,1
    80000df0:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000df2:	f675                	bnez	a2,80000dde <strncmp+0xa>
  if(n == 0)
    return 0;
    80000df4:	4501                	li	a0,0
    80000df6:	a031                	j	80000e02 <strncmp+0x2e>
  return (uchar)*p - (uchar)*q;
    80000df8:	00054503          	lbu	a0,0(a0)
    80000dfc:	0005c783          	lbu	a5,0(a1)
    80000e00:	9d1d                	subw	a0,a0,a5
}
    80000e02:	60a2                	ld	ra,8(sp)
    80000e04:	6402                	ld	s0,0(sp)
    80000e06:	0141                	addi	sp,sp,16
    80000e08:	8082                	ret

0000000080000e0a <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e0a:	1141                	addi	sp,sp,-16
    80000e0c:	e406                	sd	ra,8(sp)
    80000e0e:	e022                	sd	s0,0(sp)
    80000e10:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e12:	87aa                	mv	a5,a0
    80000e14:	a011                	j	80000e18 <strncpy+0xe>
    80000e16:	8636                	mv	a2,a3
    80000e18:	02c05763          	blez	a2,80000e46 <strncpy+0x3c>
    80000e1c:	fff6069b          	addiw	a3,a2,-1
    80000e20:	0785                	addi	a5,a5,1
    80000e22:	0005c703          	lbu	a4,0(a1)
    80000e26:	fee78fa3          	sb	a4,-1(a5)
    80000e2a:	0585                	addi	a1,a1,1
    80000e2c:	f76d                	bnez	a4,80000e16 <strncpy+0xc>
    ;
  while(n-- > 0)
    80000e2e:	873e                	mv	a4,a5
    80000e30:	00d05b63          	blez	a3,80000e46 <strncpy+0x3c>
    80000e34:	9fb1                	addw	a5,a5,a2
    80000e36:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000e38:	0705                	addi	a4,a4,1
    80000e3a:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e3e:	40e786bb          	subw	a3,a5,a4
    80000e42:	fed04be3          	bgtz	a3,80000e38 <strncpy+0x2e>
  return os;
}
    80000e46:	60a2                	ld	ra,8(sp)
    80000e48:	6402                	ld	s0,0(sp)
    80000e4a:	0141                	addi	sp,sp,16
    80000e4c:	8082                	ret

0000000080000e4e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e4e:	1141                	addi	sp,sp,-16
    80000e50:	e406                	sd	ra,8(sp)
    80000e52:	e022                	sd	s0,0(sp)
    80000e54:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e56:	02c05363          	blez	a2,80000e7c <safestrcpy+0x2e>
    80000e5a:	fff6069b          	addiw	a3,a2,-1
    80000e5e:	1682                	slli	a3,a3,0x20
    80000e60:	9281                	srli	a3,a3,0x20
    80000e62:	96ae                	add	a3,a3,a1
    80000e64:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e66:	00d58963          	beq	a1,a3,80000e78 <safestrcpy+0x2a>
    80000e6a:	0585                	addi	a1,a1,1
    80000e6c:	0785                	addi	a5,a5,1
    80000e6e:	fff5c703          	lbu	a4,-1(a1)
    80000e72:	fee78fa3          	sb	a4,-1(a5)
    80000e76:	fb65                	bnez	a4,80000e66 <safestrcpy+0x18>
    ;
  *s = 0;
    80000e78:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e7c:	60a2                	ld	ra,8(sp)
    80000e7e:	6402                	ld	s0,0(sp)
    80000e80:	0141                	addi	sp,sp,16
    80000e82:	8082                	ret

0000000080000e84 <strlen>:

int
strlen(const char *s)
{
    80000e84:	1141                	addi	sp,sp,-16
    80000e86:	e406                	sd	ra,8(sp)
    80000e88:	e022                	sd	s0,0(sp)
    80000e8a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e8c:	00054783          	lbu	a5,0(a0)
    80000e90:	cf91                	beqz	a5,80000eac <strlen+0x28>
    80000e92:	00150793          	addi	a5,a0,1
    80000e96:	86be                	mv	a3,a5
    80000e98:	0785                	addi	a5,a5,1
    80000e9a:	fff7c703          	lbu	a4,-1(a5)
    80000e9e:	ff65                	bnez	a4,80000e96 <strlen+0x12>
    80000ea0:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
    80000ea4:	60a2                	ld	ra,8(sp)
    80000ea6:	6402                	ld	s0,0(sp)
    80000ea8:	0141                	addi	sp,sp,16
    80000eaa:	8082                	ret
  for(n = 0; s[n]; n++)
    80000eac:	4501                	li	a0,0
    80000eae:	bfdd                	j	80000ea4 <strlen+0x20>

0000000080000eb0 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000eb0:	1141                	addi	sp,sp,-16
    80000eb2:	e406                	sd	ra,8(sp)
    80000eb4:	e022                	sd	s0,0(sp)
    80000eb6:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000eb8:	219000ef          	jal	800018d0 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000ebc:	00007717          	auipc	a4,0x7
    80000ec0:	99470713          	addi	a4,a4,-1644 # 80007850 <started>
  if(cpuid() == 0){
    80000ec4:	c515                	beqz	a0,80000ef0 <main+0x40>
    while(started == 0)
    80000ec6:	431c                	lw	a5,0(a4)
    80000ec8:	dffd                	beqz	a5,80000ec6 <main+0x16>
      ;
    __sync_synchronize();
    80000eca:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000ece:	203000ef          	jal	800018d0 <cpuid>
    80000ed2:	85aa                	mv	a1,a0
    80000ed4:	00006517          	auipc	a0,0x6
    80000ed8:	1c450513          	addi	a0,a0,452 # 80007098 <etext+0x98>
    80000edc:	e24ff0ef          	jal	80000500 <printf>
    kvminithart();    // turn on paging
    80000ee0:	080000ef          	jal	80000f60 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ee4:	532010ef          	jal	80002416 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ee8:	4e0040ef          	jal	800053c8 <plicinithart>
  }

  scheduler();        
    80000eec:	683000ef          	jal	80001d6e <scheduler>
    consoleinit();
    80000ef0:	d38ff0ef          	jal	80000428 <consoleinit>
    printfinit();
    80000ef4:	981ff0ef          	jal	80000874 <printfinit>
    printf("\n");
    80000ef8:	00006517          	auipc	a0,0x6
    80000efc:	18050513          	addi	a0,a0,384 # 80007078 <etext+0x78>
    80000f00:	e00ff0ef          	jal	80000500 <printf>
    printf("xv6 kernel is booting\n");
    80000f04:	00006517          	auipc	a0,0x6
    80000f08:	17c50513          	addi	a0,a0,380 # 80007080 <etext+0x80>
    80000f0c:	df4ff0ef          	jal	80000500 <printf>
    printf("\n");
    80000f10:	00006517          	auipc	a0,0x6
    80000f14:	16850513          	addi	a0,a0,360 # 80007078 <etext+0x78>
    80000f18:	de8ff0ef          	jal	80000500 <printf>
    kinit();         // physical page allocator
    80000f1c:	c05ff0ef          	jal	80000b20 <kinit>
    kvminit();       // create kernel page table
    80000f20:	2c0000ef          	jal	800011e0 <kvminit>
    kvminithart();   // turn on paging
    80000f24:	03c000ef          	jal	80000f60 <kvminithart>
    procinit();      // process table
    80000f28:	0f1000ef          	jal	80001818 <procinit>
    trapinit();      // trap vectors
    80000f2c:	4c6010ef          	jal	800023f2 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f30:	4e6010ef          	jal	80002416 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f34:	47a040ef          	jal	800053ae <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f38:	490040ef          	jal	800053c8 <plicinithart>
    binit();         // buffer cache
    80000f3c:	37f010ef          	jal	80002aba <binit>
    iinit();         // inode table
    80000f40:	0d8020ef          	jal	80003018 <iinit>
    fileinit();      // file table
    80000f44:	00a030ef          	jal	80003f4e <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f48:	570040ef          	jal	800054b8 <virtio_disk_init>
    userinit();      // first user process
    80000f4c:	481000ef          	jal	80001bcc <userinit>
    __sync_synchronize();
    80000f50:	0330000f          	fence	rw,rw
    started = 1;
    80000f54:	4785                	li	a5,1
    80000f56:	00007717          	auipc	a4,0x7
    80000f5a:	8ef72d23          	sw	a5,-1798(a4) # 80007850 <started>
    80000f5e:	b779                	j	80000eec <main+0x3c>

0000000080000f60 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000f60:	1141                	addi	sp,sp,-16
    80000f62:	e406                	sd	ra,8(sp)
    80000f64:	e022                	sd	s0,0(sp)
    80000f66:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f68:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f6c:	00007797          	auipc	a5,0x7
    80000f70:	8ec7b783          	ld	a5,-1812(a5) # 80007858 <kernel_pagetable>
    80000f74:	83b1                	srli	a5,a5,0xc
    80000f76:	577d                	li	a4,-1
    80000f78:	177e                	slli	a4,a4,0x3f
    80000f7a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f7c:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f80:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f84:	60a2                	ld	ra,8(sp)
    80000f86:	6402                	ld	s0,0(sp)
    80000f88:	0141                	addi	sp,sp,16
    80000f8a:	8082                	ret

0000000080000f8c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f8c:	7139                	addi	sp,sp,-64
    80000f8e:	fc06                	sd	ra,56(sp)
    80000f90:	f822                	sd	s0,48(sp)
    80000f92:	f426                	sd	s1,40(sp)
    80000f94:	f04a                	sd	s2,32(sp)
    80000f96:	ec4e                	sd	s3,24(sp)
    80000f98:	e852                	sd	s4,16(sp)
    80000f9a:	e456                	sd	s5,8(sp)
    80000f9c:	e05a                	sd	s6,0(sp)
    80000f9e:	0080                	addi	s0,sp,64
    80000fa0:	84aa                	mv	s1,a0
    80000fa2:	89ae                	mv	s3,a1
    80000fa4:	8b32                	mv	s6,a2
  if(va >= MAXVA)
    80000fa6:	57fd                	li	a5,-1
    80000fa8:	83e9                	srli	a5,a5,0x1a
    80000faa:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fac:	4ab1                	li	s5,12
  if(va >= MAXVA)
    80000fae:	06b7e363          	bltu	a5,a1,80001014 <walk+0x88>
    pte_t *pte = &pagetable[PX(level, va)];
    80000fb2:	0149d933          	srl	s2,s3,s4
    80000fb6:	1ff97913          	andi	s2,s2,511
    80000fba:	090e                	slli	s2,s2,0x3
    80000fbc:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000fbe:	00093483          	ld	s1,0(s2)
    80000fc2:	0014f793          	andi	a5,s1,1
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000fc6:	80a9                	srli	s1,s1,0xa
    80000fc8:	04b2                	slli	s1,s1,0xc
    if(*pte & PTE_V) {
    80000fca:	e395                	bnez	a5,80000fee <walk+0x62>
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fcc:	040b0a63          	beqz	s6,80001020 <walk+0x94>
    80000fd0:	b85ff0ef          	jal	80000b54 <kalloc>
    80000fd4:	84aa                	mv	s1,a0
    80000fd6:	c50d                	beqz	a0,80001000 <walk+0x74>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000fd8:	6605                	lui	a2,0x1
    80000fda:	4581                	li	a1,0
    80000fdc:	d29ff0ef          	jal	80000d04 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000fe0:	00c4d793          	srli	a5,s1,0xc
    80000fe4:	07aa                	slli	a5,a5,0xa
    80000fe6:	0017e793          	ori	a5,a5,1
    80000fea:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000fee:	3a5d                	addiw	s4,s4,-9
    80000ff0:	fd5a11e3          	bne	s4,s5,80000fb2 <walk+0x26>
    }
  }
  return &pagetable[PX(0, va)];
    80000ff4:	00c9d513          	srli	a0,s3,0xc
    80000ff8:	1ff57513          	andi	a0,a0,511
    80000ffc:	050e                	slli	a0,a0,0x3
    80000ffe:	9526                	add	a0,a0,s1
}
    80001000:	70e2                	ld	ra,56(sp)
    80001002:	7442                	ld	s0,48(sp)
    80001004:	74a2                	ld	s1,40(sp)
    80001006:	7902                	ld	s2,32(sp)
    80001008:	69e2                	ld	s3,24(sp)
    8000100a:	6a42                	ld	s4,16(sp)
    8000100c:	6aa2                	ld	s5,8(sp)
    8000100e:	6b02                	ld	s6,0(sp)
    80001010:	6121                	addi	sp,sp,64
    80001012:	8082                	ret
    panic("walk");
    80001014:	00006517          	auipc	a0,0x6
    80001018:	09c50513          	addi	a0,a0,156 # 800070b0 <etext+0xb0>
    8000101c:	81dff0ef          	jal	80000838 <panic>
        return 0;
    80001020:	4501                	li	a0,0
    80001022:	bff9                	j	80001000 <walk+0x74>

0000000080001024 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001024:	57fd                	li	a5,-1
    80001026:	83e9                	srli	a5,a5,0x1a
    80001028:	00b7f463          	bgeu	a5,a1,80001030 <walkaddr+0xc>
    return 0;
    8000102c:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000102e:	8082                	ret
{
    80001030:	1141                	addi	sp,sp,-16
    80001032:	e406                	sd	ra,8(sp)
    80001034:	e022                	sd	s0,0(sp)
    80001036:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001038:	4601                	li	a2,0
    8000103a:	f53ff0ef          	jal	80000f8c <walk>
  if(pte == 0)
    8000103e:	c519                	beqz	a0,8000104c <walkaddr+0x28>
  if((*pte & PTE_V) == 0)
    80001040:	6108                	ld	a0,0(a0)
  if((*pte & PTE_U) == 0)
    80001042:	01157713          	andi	a4,a0,17
    80001046:	47c5                	li	a5,17
    80001048:	00f70763          	beq	a4,a5,80001056 <walkaddr+0x32>
    return 0;
    8000104c:	4501                	li	a0,0
}
    8000104e:	60a2                	ld	ra,8(sp)
    80001050:	6402                	ld	s0,0(sp)
    80001052:	0141                	addi	sp,sp,16
    80001054:	8082                	ret
  pa = PTE2PA(*pte);
    80001056:	8129                	srli	a0,a0,0xa
    80001058:	0532                	slli	a0,a0,0xc
  return pa;
    8000105a:	bfd5                	j	8000104e <walkaddr+0x2a>

000000008000105c <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000105c:	715d                	addi	sp,sp,-80
    8000105e:	e486                	sd	ra,72(sp)
    80001060:	e0a2                	sd	s0,64(sp)
    80001062:	fc26                	sd	s1,56(sp)
    80001064:	f84a                	sd	s2,48(sp)
    80001066:	f44e                	sd	s3,40(sp)
    80001068:	f052                	sd	s4,32(sp)
    8000106a:	ec56                	sd	s5,24(sp)
    8000106c:	e85a                	sd	s6,16(sp)
    8000106e:	e45e                	sd	s7,8(sp)
    80001070:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001072:	03459793          	slli	a5,a1,0x34
    80001076:	e7b1                	bnez	a5,800010c2 <mappages+0x66>
    80001078:	8a2a                	mv	s4,a0
    8000107a:	8aba                	mv	s5,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    8000107c:	03461793          	slli	a5,a2,0x34
    80001080:	e7b9                	bnez	a5,800010ce <mappages+0x72>
    panic("mappages: size not aligned");

  if(size == 0)
    80001082:	ce21                	beqz	a2,800010da <mappages+0x7e>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80001084:	77fd                	lui	a5,0xfffff
    80001086:	963e                	add	a2,a2,a5
    80001088:	00b60933          	add	s2,a2,a1
  a = va;
    8000108c:	84ae                	mv	s1,a1
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
    8000108e:	4b05                	li	s6,1
    80001090:	40b689b3          	sub	s3,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001094:	6b85                	lui	s7,0x1
    if((pte = walk(pagetable, a, 1)) == 0)
    80001096:	865a                	mv	a2,s6
    80001098:	85a6                	mv	a1,s1
    8000109a:	8552                	mv	a0,s4
    8000109c:	ef1ff0ef          	jal	80000f8c <walk>
    800010a0:	c929                	beqz	a0,800010f2 <mappages+0x96>
    if(*pte & PTE_V)
    800010a2:	611c                	ld	a5,0(a0)
    800010a4:	8b85                	andi	a5,a5,1
    800010a6:	e3a1                	bnez	a5,800010e6 <mappages+0x8a>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010a8:	013487b3          	add	a5,s1,s3
    800010ac:	83b1                	srli	a5,a5,0xc
    800010ae:	07aa                	slli	a5,a5,0xa
    800010b0:	0157e7b3          	or	a5,a5,s5
    800010b4:	0017e793          	ori	a5,a5,1
    800010b8:	e11c                	sd	a5,0(a0)
    if(a == last)
    800010ba:	05248863          	beq	s1,s2,8000110a <mappages+0xae>
    a += PGSIZE;
    800010be:	94de                	add	s1,s1,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010c0:	bfd9                	j	80001096 <mappages+0x3a>
    panic("mappages: va not aligned");
    800010c2:	00006517          	auipc	a0,0x6
    800010c6:	ff650513          	addi	a0,a0,-10 # 800070b8 <etext+0xb8>
    800010ca:	f6eff0ef          	jal	80000838 <panic>
    panic("mappages: size not aligned");
    800010ce:	00006517          	auipc	a0,0x6
    800010d2:	00a50513          	addi	a0,a0,10 # 800070d8 <etext+0xd8>
    800010d6:	f62ff0ef          	jal	80000838 <panic>
    panic("mappages: size");
    800010da:	00006517          	auipc	a0,0x6
    800010de:	01e50513          	addi	a0,a0,30 # 800070f8 <etext+0xf8>
    800010e2:	f56ff0ef          	jal	80000838 <panic>
      panic("mappages: remap");
    800010e6:	00006517          	auipc	a0,0x6
    800010ea:	02250513          	addi	a0,a0,34 # 80007108 <etext+0x108>
    800010ee:	f4aff0ef          	jal	80000838 <panic>
      return -1;
    800010f2:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010f4:	60a6                	ld	ra,72(sp)
    800010f6:	6406                	ld	s0,64(sp)
    800010f8:	74e2                	ld	s1,56(sp)
    800010fa:	7942                	ld	s2,48(sp)
    800010fc:	79a2                	ld	s3,40(sp)
    800010fe:	7a02                	ld	s4,32(sp)
    80001100:	6ae2                	ld	s5,24(sp)
    80001102:	6b42                	ld	s6,16(sp)
    80001104:	6ba2                	ld	s7,8(sp)
    80001106:	6161                	addi	sp,sp,80
    80001108:	8082                	ret
  return 0;
    8000110a:	4501                	li	a0,0
    8000110c:	b7e5                	j	800010f4 <mappages+0x98>

000000008000110e <kvmmap>:
{
    8000110e:	1141                	addi	sp,sp,-16
    80001110:	e406                	sd	ra,8(sp)
    80001112:	e022                	sd	s0,0(sp)
    80001114:	0800                	addi	s0,sp,16
    80001116:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001118:	86b2                	mv	a3,a2
    8000111a:	863e                	mv	a2,a5
    8000111c:	f41ff0ef          	jal	8000105c <mappages>
    80001120:	e509                	bnez	a0,8000112a <kvmmap+0x1c>
}
    80001122:	60a2                	ld	ra,8(sp)
    80001124:	6402                	ld	s0,0(sp)
    80001126:	0141                	addi	sp,sp,16
    80001128:	8082                	ret
    panic("kvmmap");
    8000112a:	00006517          	auipc	a0,0x6
    8000112e:	fee50513          	addi	a0,a0,-18 # 80007118 <etext+0x118>
    80001132:	f06ff0ef          	jal	80000838 <panic>

0000000080001136 <kvmmake>:
{
    80001136:	1101                	addi	sp,sp,-32
    80001138:	ec06                	sd	ra,24(sp)
    8000113a:	e822                	sd	s0,16(sp)
    8000113c:	e426                	sd	s1,8(sp)
    8000113e:	e04a                	sd	s2,0(sp)
    80001140:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001142:	a13ff0ef          	jal	80000b54 <kalloc>
    80001146:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001148:	6605                	lui	a2,0x1
    8000114a:	4581                	li	a1,0
    8000114c:	bb9ff0ef          	jal	80000d04 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001150:	4719                	li	a4,6
    80001152:	6685                	lui	a3,0x1
    80001154:	10000637          	lui	a2,0x10000
    80001158:	85b2                	mv	a1,a2
    8000115a:	8526                	mv	a0,s1
    8000115c:	fb3ff0ef          	jal	8000110e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001160:	4719                	li	a4,6
    80001162:	6685                	lui	a3,0x1
    80001164:	10001637          	lui	a2,0x10001
    80001168:	85b2                	mv	a1,a2
    8000116a:	8526                	mv	a0,s1
    8000116c:	fa3ff0ef          	jal	8000110e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001170:	4719                	li	a4,6
    80001172:	040006b7          	lui	a3,0x4000
    80001176:	0c000637          	lui	a2,0xc000
    8000117a:	85b2                	mv	a1,a2
    8000117c:	8526                	mv	a0,s1
    8000117e:	f91ff0ef          	jal	8000110e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001182:	00006917          	auipc	s2,0x6
    80001186:	e7e90913          	addi	s2,s2,-386 # 80007000 <etext>
    8000118a:	4729                	li	a4,10
    8000118c:	800006b7          	lui	a3,0x80000
    80001190:	96ca                	add	a3,a3,s2
    80001192:	4605                	li	a2,1
    80001194:	067e                	slli	a2,a2,0x1f
    80001196:	85b2                	mv	a1,a2
    80001198:	8526                	mv	a0,s1
    8000119a:	f75ff0ef          	jal	8000110e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000119e:	4719                	li	a4,6
    800011a0:	46c5                	li	a3,17
    800011a2:	06ee                	slli	a3,a3,0x1b
    800011a4:	412686b3          	sub	a3,a3,s2
    800011a8:	864a                	mv	a2,s2
    800011aa:	85ca                	mv	a1,s2
    800011ac:	8526                	mv	a0,s1
    800011ae:	f61ff0ef          	jal	8000110e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011b2:	4729                	li	a4,10
    800011b4:	6685                	lui	a3,0x1
    800011b6:	00005617          	auipc	a2,0x5
    800011ba:	e4a60613          	addi	a2,a2,-438 # 80006000 <_trampoline>
    800011be:	040005b7          	lui	a1,0x4000
    800011c2:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800011c4:	05b2                	slli	a1,a1,0xc
    800011c6:	8526                	mv	a0,s1
    800011c8:	f47ff0ef          	jal	8000110e <kvmmap>
  proc_mapstacks(kpgtbl);
    800011cc:	8526                	mv	a0,s1
    800011ce:	5b6000ef          	jal	80001784 <proc_mapstacks>
}
    800011d2:	8526                	mv	a0,s1
    800011d4:	60e2                	ld	ra,24(sp)
    800011d6:	6442                	ld	s0,16(sp)
    800011d8:	64a2                	ld	s1,8(sp)
    800011da:	6902                	ld	s2,0(sp)
    800011dc:	6105                	addi	sp,sp,32
    800011de:	8082                	ret

00000000800011e0 <kvminit>:
{
    800011e0:	1141                	addi	sp,sp,-16
    800011e2:	e406                	sd	ra,8(sp)
    800011e4:	e022                	sd	s0,0(sp)
    800011e6:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011e8:	f4fff0ef          	jal	80001136 <kvmmake>
    800011ec:	00006797          	auipc	a5,0x6
    800011f0:	66a7b623          	sd	a0,1644(a5) # 80007858 <kernel_pagetable>
}
    800011f4:	60a2                	ld	ra,8(sp)
    800011f6:	6402                	ld	s0,0(sp)
    800011f8:	0141                	addi	sp,sp,16
    800011fa:	8082                	ret

00000000800011fc <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800011fc:	1101                	addi	sp,sp,-32
    800011fe:	ec06                	sd	ra,24(sp)
    80001200:	e822                	sd	s0,16(sp)
    80001202:	e426                	sd	s1,8(sp)
    80001204:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001206:	94fff0ef          	jal	80000b54 <kalloc>
    8000120a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000120c:	c509                	beqz	a0,80001216 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000120e:	6605                	lui	a2,0x1
    80001210:	4581                	li	a1,0
    80001212:	af3ff0ef          	jal	80000d04 <memset>
  return pagetable;
}
    80001216:	8526                	mv	a0,s1
    80001218:	60e2                	ld	ra,24(sp)
    8000121a:	6442                	ld	s0,16(sp)
    8000121c:	64a2                	ld	s1,8(sp)
    8000121e:	6105                	addi	sp,sp,32
    80001220:	8082                	ret

0000000080001222 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001222:	7139                	addi	sp,sp,-64
    80001224:	fc06                	sd	ra,56(sp)
    80001226:	f822                	sd	s0,48(sp)
    80001228:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000122a:	03459793          	slli	a5,a1,0x34
    8000122e:	e38d                	bnez	a5,80001250 <uvmunmap+0x2e>
    80001230:	f04a                	sd	s2,32(sp)
    80001232:	ec4e                	sd	s3,24(sp)
    80001234:	e852                	sd	s4,16(sp)
    80001236:	e456                	sd	s5,8(sp)
    80001238:	e05a                	sd	s6,0(sp)
    8000123a:	8a2a                	mv	s4,a0
    8000123c:	892e                	mv	s2,a1
    8000123e:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001240:	0632                	slli	a2,a2,0xc
    80001242:	00b609b3          	add	s3,a2,a1
    80001246:	6b05                	lui	s6,0x1
    80001248:	0535f963          	bgeu	a1,s3,8000129a <uvmunmap+0x78>
    8000124c:	f426                	sd	s1,40(sp)
    8000124e:	a015                	j	80001272 <uvmunmap+0x50>
    80001250:	f426                	sd	s1,40(sp)
    80001252:	f04a                	sd	s2,32(sp)
    80001254:	ec4e                	sd	s3,24(sp)
    80001256:	e852                	sd	s4,16(sp)
    80001258:	e456                	sd	s5,8(sp)
    8000125a:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    8000125c:	00006517          	auipc	a0,0x6
    80001260:	ec450513          	addi	a0,a0,-316 # 80007120 <etext+0x120>
    80001264:	dd4ff0ef          	jal	80000838 <panic>
      continue;
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80001268:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000126c:	995a                	add	s2,s2,s6
    8000126e:	03397563          	bgeu	s2,s3,80001298 <uvmunmap+0x76>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    80001272:	4601                	li	a2,0
    80001274:	85ca                	mv	a1,s2
    80001276:	8552                	mv	a0,s4
    80001278:	d15ff0ef          	jal	80000f8c <walk>
    8000127c:	84aa                	mv	s1,a0
    8000127e:	d57d                	beqz	a0,8000126c <uvmunmap+0x4a>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    80001280:	611c                	ld	a5,0(a0)
    80001282:	0017f713          	andi	a4,a5,1
    80001286:	d37d                	beqz	a4,8000126c <uvmunmap+0x4a>
    if(do_free){
    80001288:	fe0a80e3          	beqz	s5,80001268 <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    8000128c:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    8000128e:	00c79513          	slli	a0,a5,0xc
    80001292:	fdaff0ef          	jal	80000a6c <kfree>
    80001296:	bfc9                	j	80001268 <uvmunmap+0x46>
    80001298:	74a2                	ld	s1,40(sp)
    8000129a:	7902                	ld	s2,32(sp)
    8000129c:	69e2                	ld	s3,24(sp)
    8000129e:	6a42                	ld	s4,16(sp)
    800012a0:	6aa2                	ld	s5,8(sp)
    800012a2:	6b02                	ld	s6,0(sp)
  }
}
    800012a4:	70e2                	ld	ra,56(sp)
    800012a6:	7442                	ld	s0,48(sp)
    800012a8:	6121                	addi	sp,sp,64
    800012aa:	8082                	ret

00000000800012ac <uvmdealloc>:
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
  if(newsz >= oldsz)
    800012ac:	04b67163          	bgeu	a2,a1,800012ee <uvmdealloc+0x42>
{
    800012b0:	1101                	addi	sp,sp,-32
    800012b2:	ec06                	sd	ra,24(sp)
    800012b4:	e822                	sd	s0,16(sp)
    800012b6:	e426                	sd	s1,8(sp)
    800012b8:	1000                	addi	s0,sp,32
    800012ba:	84b2                	mv	s1,a2
    return oldsz;

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800012bc:	6785                	lui	a5,0x1
    800012be:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012c0:	00f60733          	add	a4,a2,a5
    800012c4:	76fd                	lui	a3,0xfffff
    800012c6:	8f75                	and	a4,a4,a3
    800012c8:	97ae                	add	a5,a5,a1
    800012ca:	8ff5                	and	a5,a5,a3
    800012cc:	00f76863          	bltu	a4,a5,800012dc <uvmdealloc+0x30>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
    800012d0:	8526                	mv	a0,s1
}
    800012d2:	60e2                	ld	ra,24(sp)
    800012d4:	6442                	ld	s0,16(sp)
    800012d6:	64a2                	ld	s1,8(sp)
    800012d8:	6105                	addi	sp,sp,32
    800012da:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800012dc:	8f99                	sub	a5,a5,a4
    800012de:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800012e0:	4685                	li	a3,1
    800012e2:	0007861b          	sext.w	a2,a5
    800012e6:	85ba                	mv	a1,a4
    800012e8:	f3bff0ef          	jal	80001222 <uvmunmap>
    800012ec:	b7d5                	j	800012d0 <uvmdealloc+0x24>
    return oldsz;
    800012ee:	852e                	mv	a0,a1
}
    800012f0:	8082                	ret

00000000800012f2 <uvmalloc>:
  if(newsz < oldsz)
    800012f2:	08b66e63          	bltu	a2,a1,8000138e <uvmalloc+0x9c>
{
    800012f6:	715d                	addi	sp,sp,-80
    800012f8:	e486                	sd	ra,72(sp)
    800012fa:	e0a2                	sd	s0,64(sp)
    800012fc:	f052                	sd	s4,32(sp)
    800012fe:	ec56                	sd	s5,24(sp)
    80001300:	e45e                	sd	s7,8(sp)
    80001302:	0880                	addi	s0,sp,80
    80001304:	8aaa                	mv	s5,a0
    80001306:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001308:	6785                	lui	a5,0x1
    8000130a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000130c:	95be                	add	a1,a1,a5
    8000130e:	77fd                	lui	a5,0xfffff
    80001310:	8fed                	and	a5,a5,a1
    80001312:	8bbe                	mv	s7,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001314:	04c7f163          	bgeu	a5,a2,80001356 <uvmalloc+0x64>
    80001318:	fc26                	sd	s1,56(sp)
    8000131a:	f84a                	sd	s2,48(sp)
    8000131c:	f44e                	sd	s3,40(sp)
    8000131e:	e85a                	sd	s6,16(sp)
    80001320:	893e                	mv	s2,a5
    memset(mem, 0, PGSIZE);
    80001322:	6985                	lui	s3,0x1
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001324:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001328:	82dff0ef          	jal	80000b54 <kalloc>
    8000132c:	84aa                	mv	s1,a0
    if(mem == 0){
    8000132e:	c515                	beqz	a0,8000135a <uvmalloc+0x68>
    memset(mem, 0, PGSIZE);
    80001330:	864e                	mv	a2,s3
    80001332:	4581                	li	a1,0
    80001334:	9d1ff0ef          	jal	80000d04 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001338:	875a                	mv	a4,s6
    8000133a:	86a6                	mv	a3,s1
    8000133c:	864e                	mv	a2,s3
    8000133e:	85ca                	mv	a1,s2
    80001340:	8556                	mv	a0,s5
    80001342:	d1bff0ef          	jal	8000105c <mappages>
    80001346:	e91d                	bnez	a0,8000137c <uvmalloc+0x8a>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001348:	994e                	add	s2,s2,s3
    8000134a:	fd496fe3          	bltu	s2,s4,80001328 <uvmalloc+0x36>
    8000134e:	74e2                	ld	s1,56(sp)
    80001350:	7942                	ld	s2,48(sp)
    80001352:	79a2                	ld	s3,40(sp)
    80001354:	6b42                	ld	s6,16(sp)
  return newsz;
    80001356:	8552                	mv	a0,s4
    80001358:	a819                	j	8000136e <uvmalloc+0x7c>
      uvmdealloc(pagetable, a, oldsz);
    8000135a:	865e                	mv	a2,s7
    8000135c:	85ca                	mv	a1,s2
    8000135e:	8556                	mv	a0,s5
    80001360:	f4dff0ef          	jal	800012ac <uvmdealloc>
      return 0;
    80001364:	4501                	li	a0,0
    80001366:	74e2                	ld	s1,56(sp)
    80001368:	7942                	ld	s2,48(sp)
    8000136a:	79a2                	ld	s3,40(sp)
    8000136c:	6b42                	ld	s6,16(sp)
}
    8000136e:	60a6                	ld	ra,72(sp)
    80001370:	6406                	ld	s0,64(sp)
    80001372:	7a02                	ld	s4,32(sp)
    80001374:	6ae2                	ld	s5,24(sp)
    80001376:	6ba2                	ld	s7,8(sp)
    80001378:	6161                	addi	sp,sp,80
    8000137a:	8082                	ret
      kfree(mem);
    8000137c:	8526                	mv	a0,s1
    8000137e:	eeeff0ef          	jal	80000a6c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001382:	865e                	mv	a2,s7
    80001384:	85ca                	mv	a1,s2
    80001386:	8556                	mv	a0,s5
    80001388:	f25ff0ef          	jal	800012ac <uvmdealloc>
      return 0;
    8000138c:	bfe1                	j	80001364 <uvmalloc+0x72>
    return oldsz;
    8000138e:	852e                	mv	a0,a1
}
    80001390:	8082                	ret

0000000080001392 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001392:	7179                	addi	sp,sp,-48
    80001394:	f406                	sd	ra,40(sp)
    80001396:	f022                	sd	s0,32(sp)
    80001398:	ec26                	sd	s1,24(sp)
    8000139a:	e84a                	sd	s2,16(sp)
    8000139c:	e44e                	sd	s3,8(sp)
    8000139e:	1800                	addi	s0,sp,48
    800013a0:	89aa                	mv	s3,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800013a2:	84aa                	mv	s1,a0
    800013a4:	6905                	lui	s2,0x1
    800013a6:	992a                	add	s2,s2,a0
    800013a8:	a811                	j	800013bc <freewalk+0x2a>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if(pte & PTE_V){
      panic("freewalk: leaf");
    800013aa:	00006517          	auipc	a0,0x6
    800013ae:	d8e50513          	addi	a0,a0,-626 # 80007138 <etext+0x138>
    800013b2:	c86ff0ef          	jal	80000838 <panic>
  for(int i = 0; i < 512; i++){
    800013b6:	04a1                	addi	s1,s1,8
    800013b8:	03248163          	beq	s1,s2,800013da <freewalk+0x48>
    pte_t pte = pagetable[i];
    800013bc:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013be:	0017f713          	andi	a4,a5,1
    800013c2:	db75                	beqz	a4,800013b6 <freewalk+0x24>
    800013c4:	00e7f713          	andi	a4,a5,14
    800013c8:	f36d                	bnez	a4,800013aa <freewalk+0x18>
      uint64 child = PTE2PA(pte);
    800013ca:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800013cc:	00c79513          	slli	a0,a5,0xc
    800013d0:	fc3ff0ef          	jal	80001392 <freewalk>
      pagetable[i] = 0;
    800013d4:	0004b023          	sd	zero,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013d8:	bff9                	j	800013b6 <freewalk+0x24>
    }
  }
  kfree((void*)pagetable);
    800013da:	854e                	mv	a0,s3
    800013dc:	e90ff0ef          	jal	80000a6c <kfree>
}
    800013e0:	70a2                	ld	ra,40(sp)
    800013e2:	7402                	ld	s0,32(sp)
    800013e4:	64e2                	ld	s1,24(sp)
    800013e6:	6942                	ld	s2,16(sp)
    800013e8:	69a2                	ld	s3,8(sp)
    800013ea:	6145                	addi	sp,sp,48
    800013ec:	8082                	ret

00000000800013ee <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800013ee:	1101                	addi	sp,sp,-32
    800013f0:	ec06                	sd	ra,24(sp)
    800013f2:	e822                	sd	s0,16(sp)
    800013f4:	e426                	sd	s1,8(sp)
    800013f6:	1000                	addi	s0,sp,32
    800013f8:	84aa                	mv	s1,a0
  if(sz > 0)
    800013fa:	e989                	bnez	a1,8000140c <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800013fc:	8526                	mv	a0,s1
    800013fe:	f95ff0ef          	jal	80001392 <freewalk>
}
    80001402:	60e2                	ld	ra,24(sp)
    80001404:	6442                	ld	s0,16(sp)
    80001406:	64a2                	ld	s1,8(sp)
    80001408:	6105                	addi	sp,sp,32
    8000140a:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000140c:	6785                	lui	a5,0x1
    8000140e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001410:	95be                	add	a1,a1,a5
    80001412:	4685                	li	a3,1
    80001414:	00c5d613          	srli	a2,a1,0xc
    80001418:	4581                	li	a1,0
    8000141a:	e09ff0ef          	jal	80001222 <uvmunmap>
    8000141e:	bff9                	j	800013fc <uvmfree+0xe>

0000000080001420 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001420:	ca59                	beqz	a2,800014b6 <uvmcopy+0x96>
{
    80001422:	715d                	addi	sp,sp,-80
    80001424:	e486                	sd	ra,72(sp)
    80001426:	e0a2                	sd	s0,64(sp)
    80001428:	fc26                	sd	s1,56(sp)
    8000142a:	f84a                	sd	s2,48(sp)
    8000142c:	f44e                	sd	s3,40(sp)
    8000142e:	f052                	sd	s4,32(sp)
    80001430:	ec56                	sd	s5,24(sp)
    80001432:	e85a                	sd	s6,16(sp)
    80001434:	e45e                	sd	s7,8(sp)
    80001436:	0880                	addi	s0,sp,80
    80001438:	8b2a                	mv	s6,a0
    8000143a:	8bae                	mv	s7,a1
    8000143c:	8ab2                	mv	s5,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000143e:	4481                	li	s1,0
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001440:	6a05                	lui	s4,0x1
    80001442:	a021                	j	8000144a <uvmcopy+0x2a>
  for(i = 0; i < sz; i += PGSIZE){
    80001444:	94d2                	add	s1,s1,s4
    80001446:	0554fc63          	bgeu	s1,s5,8000149e <uvmcopy+0x7e>
    if((pte = walk(old, i, 0)) == 0)
    8000144a:	4601                	li	a2,0
    8000144c:	85a6                	mv	a1,s1
    8000144e:	855a                	mv	a0,s6
    80001450:	b3dff0ef          	jal	80000f8c <walk>
    80001454:	d965                	beqz	a0,80001444 <uvmcopy+0x24>
    if((*pte & PTE_V) == 0)
    80001456:	00053983          	ld	s3,0(a0)
    8000145a:	0019f793          	andi	a5,s3,1
    8000145e:	d3fd                	beqz	a5,80001444 <uvmcopy+0x24>
    if((mem = kalloc()) == 0)
    80001460:	ef4ff0ef          	jal	80000b54 <kalloc>
    80001464:	892a                	mv	s2,a0
    80001466:	c11d                	beqz	a0,8000148c <uvmcopy+0x6c>
    pa = PTE2PA(*pte);
    80001468:	00a9d593          	srli	a1,s3,0xa
    memmove(mem, (char*)pa, PGSIZE);
    8000146c:	8652                	mv	a2,s4
    8000146e:	05b2                	slli	a1,a1,0xc
    80001470:	8f1ff0ef          	jal	80000d60 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001474:	3ff9f713          	andi	a4,s3,1023
    80001478:	86ca                	mv	a3,s2
    8000147a:	8652                	mv	a2,s4
    8000147c:	85a6                	mv	a1,s1
    8000147e:	855e                	mv	a0,s7
    80001480:	bddff0ef          	jal	8000105c <mappages>
    80001484:	d161                	beqz	a0,80001444 <uvmcopy+0x24>
      kfree(mem);
    80001486:	854a                	mv	a0,s2
    80001488:	de4ff0ef          	jal	80000a6c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000148c:	4685                	li	a3,1
    8000148e:	00c4d613          	srli	a2,s1,0xc
    80001492:	4581                	li	a1,0
    80001494:	855e                	mv	a0,s7
    80001496:	d8dff0ef          	jal	80001222 <uvmunmap>
  return -1;
    8000149a:	557d                	li	a0,-1
    8000149c:	a011                	j	800014a0 <uvmcopy+0x80>
  return 0;
    8000149e:	4501                	li	a0,0
}
    800014a0:	60a6                	ld	ra,72(sp)
    800014a2:	6406                	ld	s0,64(sp)
    800014a4:	74e2                	ld	s1,56(sp)
    800014a6:	7942                	ld	s2,48(sp)
    800014a8:	79a2                	ld	s3,40(sp)
    800014aa:	7a02                	ld	s4,32(sp)
    800014ac:	6ae2                	ld	s5,24(sp)
    800014ae:	6b42                	ld	s6,16(sp)
    800014b0:	6ba2                	ld	s7,8(sp)
    800014b2:	6161                	addi	sp,sp,80
    800014b4:	8082                	ret
  return 0;
    800014b6:	4501                	li	a0,0
}
    800014b8:	8082                	ret

00000000800014ba <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800014ba:	1141                	addi	sp,sp,-16
    800014bc:	e406                	sd	ra,8(sp)
    800014be:	e022                	sd	s0,0(sp)
    800014c0:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800014c2:	4601                	li	a2,0
    800014c4:	ac9ff0ef          	jal	80000f8c <walk>
  if(pte == 0)
    800014c8:	c901                	beqz	a0,800014d8 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800014ca:	611c                	ld	a5,0(a0)
    800014cc:	9bbd                	andi	a5,a5,-17
    800014ce:	e11c                	sd	a5,0(a0)
}
    800014d0:	60a2                	ld	ra,8(sp)
    800014d2:	6402                	ld	s0,0(sp)
    800014d4:	0141                	addi	sp,sp,16
    800014d6:	8082                	ret
    panic("uvmclear");
    800014d8:	00006517          	auipc	a0,0x6
    800014dc:	c7050513          	addi	a0,a0,-912 # 80007148 <etext+0x148>
    800014e0:	b58ff0ef          	jal	80000838 <panic>

00000000800014e4 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800014e4:	cac5                	beqz	a3,80001594 <copyinstr+0xb0>
{
    800014e6:	715d                	addi	sp,sp,-80
    800014e8:	e486                	sd	ra,72(sp)
    800014ea:	e0a2                	sd	s0,64(sp)
    800014ec:	fc26                	sd	s1,56(sp)
    800014ee:	f84a                	sd	s2,48(sp)
    800014f0:	f44e                	sd	s3,40(sp)
    800014f2:	f052                	sd	s4,32(sp)
    800014f4:	ec56                	sd	s5,24(sp)
    800014f6:	e85a                	sd	s6,16(sp)
    800014f8:	e45e                	sd	s7,8(sp)
    800014fa:	0880                	addi	s0,sp,80
    800014fc:	8aaa                	mv	s5,a0
    800014fe:	84ae                	mv	s1,a1
    80001500:	8bb2                	mv	s7,a2
    80001502:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001504:	7b7d                	lui	s6,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001506:	6a05                	lui	s4,0x1
    80001508:	a82d                	j	80001542 <copyinstr+0x5e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000150a:	00078023          	sb	zero,0(a5)
        got_null = 1;
    8000150e:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001510:	0017c793          	xori	a5,a5,1
    80001514:	40f0053b          	negw	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001518:	60a6                	ld	ra,72(sp)
    8000151a:	6406                	ld	s0,64(sp)
    8000151c:	74e2                	ld	s1,56(sp)
    8000151e:	7942                	ld	s2,48(sp)
    80001520:	79a2                	ld	s3,40(sp)
    80001522:	7a02                	ld	s4,32(sp)
    80001524:	6ae2                	ld	s5,24(sp)
    80001526:	6b42                	ld	s6,16(sp)
    80001528:	6ba2                	ld	s7,8(sp)
    8000152a:	6161                	addi	sp,sp,80
    8000152c:	8082                	ret
    8000152e:	fff98713          	addi	a4,s3,-1 # fff <_entry-0x7ffff001>
    80001532:	9726                	add	a4,a4,s1
      --max;
    80001534:	40b709b3          	sub	s3,a4,a1
    srcva = va0 + PGSIZE;
    80001538:	01490bb3          	add	s7,s2,s4
  while(got_null == 0 && max > 0){
    8000153c:	04e58463          	beq	a1,a4,80001584 <copyinstr+0xa0>
{
    80001540:	84be                	mv	s1,a5
    va0 = PGROUNDDOWN(srcva);
    80001542:	016bf933          	and	s2,s7,s6
    pa0 = walkaddr(pagetable, va0);
    80001546:	85ca                	mv	a1,s2
    80001548:	8556                	mv	a0,s5
    8000154a:	adbff0ef          	jal	80001024 <walkaddr>
    if(pa0 == 0)
    8000154e:	cd0d                	beqz	a0,80001588 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001550:	41790633          	sub	a2,s2,s7
    80001554:	9652                	add	a2,a2,s4
    if(n > max)
    80001556:	00c9f363          	bgeu	s3,a2,8000155c <copyinstr+0x78>
    8000155a:	864e                	mv	a2,s3
    while(n > 0){
    8000155c:	ca05                	beqz	a2,8000158c <copyinstr+0xa8>
    char *p = (char *) (pa0 + (srcva - va0));
    8000155e:	034b9693          	slli	a3,s7,0x34
    80001562:	92d1                	srli	a3,a3,0x34
    80001564:	96aa                	add	a3,a3,a0
    80001566:	87a6                	mv	a5,s1
      if(*p == '\0'){
    80001568:	8e85                	sub	a3,a3,s1
    while(n > 0){
    8000156a:	9626                	add	a2,a2,s1
    8000156c:	85be                	mv	a1,a5
      if(*p == '\0'){
    8000156e:	00f68733          	add	a4,a3,a5
    80001572:	00074703          	lbu	a4,0(a4)
    80001576:	db51                	beqz	a4,8000150a <copyinstr+0x26>
        *dst = *p;
    80001578:	00e78023          	sb	a4,0(a5)
      dst++;
    8000157c:	0785                	addi	a5,a5,1
    while(n > 0){
    8000157e:	fec797e3          	bne	a5,a2,8000156c <copyinstr+0x88>
    80001582:	b775                	j	8000152e <copyinstr+0x4a>
    srcva = va0 + PGSIZE;
    80001584:	4781                	li	a5,0
    80001586:	b769                	j	80001510 <copyinstr+0x2c>
      return -1;
    80001588:	557d                	li	a0,-1
    8000158a:	b779                	j	80001518 <copyinstr+0x34>
    srcva = va0 + PGSIZE;
    8000158c:	6b85                	lui	s7,0x1
    8000158e:	9bca                	add	s7,s7,s2
    80001590:	87a6                	mv	a5,s1
    80001592:	b77d                	j	80001540 <copyinstr+0x5c>
    80001594:	4781                	li	a5,0
  if(got_null){
    80001596:	0017c793          	xori	a5,a5,1
    8000159a:	40f0053b          	negw	a0,a5
}
    8000159e:	8082                	ret

00000000800015a0 <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    800015a0:	1141                	addi	sp,sp,-16
    800015a2:	e406                	sd	ra,8(sp)
    800015a4:	e022                	sd	s0,0(sp)
    800015a6:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800015a8:	4601                	li	a2,0
    800015aa:	9e3ff0ef          	jal	80000f8c <walk>
  if (pte == 0) {
    800015ae:	c119                	beqz	a0,800015b4 <ismapped+0x14>
    return 0;
  }
  if (*pte & PTE_V){
    800015b0:	6108                	ld	a0,0(a0)
    800015b2:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    800015b4:	60a2                	ld	ra,8(sp)
    800015b6:	6402                	ld	s0,0(sp)
    800015b8:	0141                	addi	sp,sp,16
    800015ba:	8082                	ret

00000000800015bc <vmfault>:
{
    800015bc:	7179                	addi	sp,sp,-48
    800015be:	f406                	sd	ra,40(sp)
    800015c0:	f022                	sd	s0,32(sp)
    800015c2:	e84a                	sd	s2,16(sp)
    800015c4:	e052                	sd	s4,0(sp)
    800015c6:	1800                	addi	s0,sp,48
    800015c8:	8a2a                	mv	s4,a0
    800015ca:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800015cc:	338000ef          	jal	80001904 <myproc>
  if (va >= p->sz)
    800015d0:	653c                	ld	a5,72(a0)
    800015d2:	00f96d63          	bltu	s2,a5,800015ec <vmfault+0x30>
    return 0;
    800015d6:	4a01                	li	s4,0
}
    800015d8:	8552                	mv	a0,s4
    800015da:	70a2                	ld	ra,40(sp)
    800015dc:	7402                	ld	s0,32(sp)
    800015de:	6942                	ld	s2,16(sp)
    800015e0:	6a02                	ld	s4,0(sp)
    800015e2:	6145                	addi	sp,sp,48
    800015e4:	8082                	ret
    800015e6:	64e2                	ld	s1,24(sp)
    800015e8:	69a2                	ld	s3,8(sp)
    800015ea:	b7f5                	j	800015d6 <vmfault+0x1a>
    800015ec:	ec26                	sd	s1,24(sp)
    800015ee:	e44e                	sd	s3,8(sp)
    800015f0:	84aa                	mv	s1,a0
  va = PGROUNDDOWN(va);
    800015f2:	77fd                	lui	a5,0xfffff
    800015f4:	00f979b3          	and	s3,s2,a5
  if(ismapped(pagetable, va)) {
    800015f8:	85ce                	mv	a1,s3
    800015fa:	8552                	mv	a0,s4
    800015fc:	fa5ff0ef          	jal	800015a0 <ismapped>
    80001600:	c501                	beqz	a0,80001608 <vmfault+0x4c>
    80001602:	64e2                	ld	s1,24(sp)
    80001604:	69a2                	ld	s3,8(sp)
    80001606:	bfc1                	j	800015d6 <vmfault+0x1a>
  mem = (uint64) kalloc();
    80001608:	d4cff0ef          	jal	80000b54 <kalloc>
    8000160c:	892a                	mv	s2,a0
  if(mem == 0)
    8000160e:	dd61                	beqz	a0,800015e6 <vmfault+0x2a>
  mem = (uint64) kalloc();
    80001610:	8a2a                	mv	s4,a0
  memset((void *) mem, 0, PGSIZE);
    80001612:	6605                	lui	a2,0x1
    80001614:	4581                	li	a1,0
    80001616:	eeeff0ef          	jal	80000d04 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    8000161a:	4759                	li	a4,22
    8000161c:	86ca                	mv	a3,s2
    8000161e:	6605                	lui	a2,0x1
    80001620:	85ce                	mv	a1,s3
    80001622:	68a8                	ld	a0,80(s1)
    80001624:	a39ff0ef          	jal	8000105c <mappages>
    80001628:	e501                	bnez	a0,80001630 <vmfault+0x74>
    8000162a:	64e2                	ld	s1,24(sp)
    8000162c:	69a2                	ld	s3,8(sp)
    8000162e:	b76d                	j	800015d8 <vmfault+0x1c>
    kfree((void *)mem);
    80001630:	854a                	mv	a0,s2
    80001632:	c3aff0ef          	jal	80000a6c <kfree>
    return 0;
    80001636:	64e2                	ld	s1,24(sp)
    80001638:	69a2                	ld	s3,8(sp)
    8000163a:	bf71                	j	800015d6 <vmfault+0x1a>

000000008000163c <copyout>:
  while(len > 0){
    8000163c:	cad5                	beqz	a3,800016f0 <copyout+0xb4>
{
    8000163e:	711d                	addi	sp,sp,-96
    80001640:	ec86                	sd	ra,88(sp)
    80001642:	e8a2                	sd	s0,80(sp)
    80001644:	e4a6                	sd	s1,72(sp)
    80001646:	e0ca                	sd	s2,64(sp)
    80001648:	fc4e                	sd	s3,56(sp)
    8000164a:	f852                	sd	s4,48(sp)
    8000164c:	f456                	sd	s5,40(sp)
    8000164e:	f05a                	sd	s6,32(sp)
    80001650:	ec5e                	sd	s7,24(sp)
    80001652:	e862                	sd	s8,16(sp)
    80001654:	e466                	sd	s9,8(sp)
    80001656:	e06a                	sd	s10,0(sp)
    80001658:	1080                	addi	s0,sp,96
    8000165a:	8baa                	mv	s7,a0
    8000165c:	84ae                	mv	s1,a1
    8000165e:	8b32                	mv	s6,a2
    80001660:	8ab6                	mv	s5,a3
    va0 = PGROUNDDOWN(dstva);
    80001662:	7d7d                	lui	s10,0xfffff
    if(va0 >= MAXVA)
    80001664:	5cfd                	li	s9,-1
    80001666:	01acdc93          	srli	s9,s9,0x1a
    n = PGSIZE - (dstva - va0);
    8000166a:	6c05                	lui	s8,0x1
    8000166c:	a081                	j	800016ac <copyout+0x70>
      return -1;
    8000166e:	557d                	li	a0,-1
}
    80001670:	60e6                	ld	ra,88(sp)
    80001672:	6446                	ld	s0,80(sp)
    80001674:	64a6                	ld	s1,72(sp)
    80001676:	6906                	ld	s2,64(sp)
    80001678:	79e2                	ld	s3,56(sp)
    8000167a:	7a42                	ld	s4,48(sp)
    8000167c:	7aa2                	ld	s5,40(sp)
    8000167e:	7b02                	ld	s6,32(sp)
    80001680:	6be2                	ld	s7,24(sp)
    80001682:	6c42                	ld	s8,16(sp)
    80001684:	6ca2                	ld	s9,8(sp)
    80001686:	6d02                	ld	s10,0(sp)
    80001688:	6125                	addi	sp,sp,96
    8000168a:	8082                	ret
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000168c:	03449513          	slli	a0,s1,0x34
    80001690:	9151                	srli	a0,a0,0x34
    80001692:	0009061b          	sext.w	a2,s2
    80001696:	85da                	mv	a1,s6
    80001698:	954e                	add	a0,a0,s3
    8000169a:	ec6ff0ef          	jal	80000d60 <memmove>
    len -= n;
    8000169e:	412a8ab3          	sub	s5,s5,s2
    src += n;
    800016a2:	9b4a                	add	s6,s6,s2
    dstva = va0 + PGSIZE;
    800016a4:	018a04b3          	add	s1,s4,s8
  while(len > 0){
    800016a8:	040a8263          	beqz	s5,800016ec <copyout+0xb0>
    va0 = PGROUNDDOWN(dstva);
    800016ac:	01a4fa33          	and	s4,s1,s10
    if(va0 >= MAXVA)
    800016b0:	fb4cefe3          	bltu	s9,s4,8000166e <copyout+0x32>
    pa0 = walkaddr(pagetable, va0);
    800016b4:	85d2                	mv	a1,s4
    800016b6:	855e                	mv	a0,s7
    800016b8:	96dff0ef          	jal	80001024 <walkaddr>
    800016bc:	89aa                	mv	s3,a0
    if(pa0 == 0) {
    800016be:	e901                	bnez	a0,800016ce <copyout+0x92>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800016c0:	4601                	li	a2,0
    800016c2:	85d2                	mv	a1,s4
    800016c4:	855e                	mv	a0,s7
    800016c6:	ef7ff0ef          	jal	800015bc <vmfault>
    800016ca:	89aa                	mv	s3,a0
    800016cc:	d14d                	beqz	a0,8000166e <copyout+0x32>
    pte = walk(pagetable, va0, 0);
    800016ce:	4601                	li	a2,0
    800016d0:	85d2                	mv	a1,s4
    800016d2:	855e                	mv	a0,s7
    800016d4:	8b9ff0ef          	jal	80000f8c <walk>
    if((*pte & PTE_W) == 0)
    800016d8:	611c                	ld	a5,0(a0)
    800016da:	8b91                	andi	a5,a5,4
    800016dc:	dbc9                	beqz	a5,8000166e <copyout+0x32>
    n = PGSIZE - (dstva - va0);
    800016de:	409a0933          	sub	s2,s4,s1
    800016e2:	9962                	add	s2,s2,s8
    if(n > len)
    800016e4:	fb2af4e3          	bgeu	s5,s2,8000168c <copyout+0x50>
    800016e8:	8956                	mv	s2,s5
    800016ea:	b74d                	j	8000168c <copyout+0x50>
  return 0;
    800016ec:	4501                	li	a0,0
    800016ee:	b749                	j	80001670 <copyout+0x34>
    800016f0:	4501                	li	a0,0
}
    800016f2:	8082                	ret

00000000800016f4 <copyin>:
  while(len > 0){
    800016f4:	c6d1                	beqz	a3,80001780 <copyin+0x8c>
{
    800016f6:	715d                	addi	sp,sp,-80
    800016f8:	e486                	sd	ra,72(sp)
    800016fa:	e0a2                	sd	s0,64(sp)
    800016fc:	fc26                	sd	s1,56(sp)
    800016fe:	f84a                	sd	s2,48(sp)
    80001700:	f44e                	sd	s3,40(sp)
    80001702:	f052                	sd	s4,32(sp)
    80001704:	ec56                	sd	s5,24(sp)
    80001706:	e85a                	sd	s6,16(sp)
    80001708:	e45e                	sd	s7,8(sp)
    8000170a:	e062                	sd	s8,0(sp)
    8000170c:	0880                	addi	s0,sp,80
    8000170e:	8baa                	mv	s7,a0
    80001710:	8aae                	mv	s5,a1
    80001712:	84b2                	mv	s1,a2
    80001714:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001716:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    80001718:	6b05                	lui	s6,0x1
    8000171a:	a03d                	j	80001748 <copyin+0x54>
    8000171c:	409a0933          	sub	s2,s4,s1
    80001720:	995a                	add	s2,s2,s6
    if(n > len)
    80001722:	0129f363          	bgeu	s3,s2,80001728 <copyin+0x34>
    80001726:	894e                	mv	s2,s3
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001728:	03449593          	slli	a1,s1,0x34
    8000172c:	91d1                	srli	a1,a1,0x34
    8000172e:	0009061b          	sext.w	a2,s2
    80001732:	95aa                	add	a1,a1,a0
    80001734:	8556                	mv	a0,s5
    80001736:	e2aff0ef          	jal	80000d60 <memmove>
    len -= n;
    8000173a:	412989b3          	sub	s3,s3,s2
    dst += n;
    8000173e:	9aca                	add	s5,s5,s2
    srcva = va0 + PGSIZE;
    80001740:	016a04b3          	add	s1,s4,s6
  while(len > 0){
    80001744:	02098163          	beqz	s3,80001766 <copyin+0x72>
    va0 = PGROUNDDOWN(srcva);
    80001748:	0184fa33          	and	s4,s1,s8
    pa0 = walkaddr(pagetable, va0);
    8000174c:	85d2                	mv	a1,s4
    8000174e:	855e                	mv	a0,s7
    80001750:	8d5ff0ef          	jal	80001024 <walkaddr>
    if(pa0 == 0) {
    80001754:	f561                	bnez	a0,8000171c <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001756:	4601                	li	a2,0
    80001758:	85d2                	mv	a1,s4
    8000175a:	855e                	mv	a0,s7
    8000175c:	e61ff0ef          	jal	800015bc <vmfault>
    80001760:	fd55                	bnez	a0,8000171c <copyin+0x28>
        return -1;
    80001762:	557d                	li	a0,-1
    80001764:	a011                	j	80001768 <copyin+0x74>
  return 0;
    80001766:	4501                	li	a0,0
}
    80001768:	60a6                	ld	ra,72(sp)
    8000176a:	6406                	ld	s0,64(sp)
    8000176c:	74e2                	ld	s1,56(sp)
    8000176e:	7942                	ld	s2,48(sp)
    80001770:	79a2                	ld	s3,40(sp)
    80001772:	7a02                	ld	s4,32(sp)
    80001774:	6ae2                	ld	s5,24(sp)
    80001776:	6b42                	ld	s6,16(sp)
    80001778:	6ba2                	ld	s7,8(sp)
    8000177a:	6c02                	ld	s8,0(sp)
    8000177c:	6161                	addi	sp,sp,80
    8000177e:	8082                	ret
  return 0;
    80001780:	4501                	li	a0,0
}
    80001782:	8082                	ret

0000000080001784 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001784:	715d                	addi	sp,sp,-80
    80001786:	e486                	sd	ra,72(sp)
    80001788:	e0a2                	sd	s0,64(sp)
    8000178a:	fc26                	sd	s1,56(sp)
    8000178c:	f84a                	sd	s2,48(sp)
    8000178e:	f44e                	sd	s3,40(sp)
    80001790:	f052                	sd	s4,32(sp)
    80001792:	ec56                	sd	s5,24(sp)
    80001794:	e85a                	sd	s6,16(sp)
    80001796:	e45e                	sd	s7,8(sp)
    80001798:	0880                	addi	s0,sp,80
    8000179a:	8aaa                	mv	s5,a0
    8000179c:	4481                	li	s1,0
  
  for(p = proc; p < &proc[NPROC]; p++) {
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000179e:	000a57b7          	lui	a5,0xa5
    800017a2:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    800017a6:	07b2                	slli	a5,a5,0xc
    800017a8:	fa578793          	addi	a5,a5,-91
    800017ac:	4fa50937          	lui	s2,0x4fa50
    800017b0:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    800017b4:	1902                	slli	s2,s2,0x20
    800017b6:	993e                	add	s2,s2,a5
    800017b8:	040009b7          	lui	s3,0x4000
    800017bc:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017be:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017c0:	4b99                	li	s7,6
    800017c2:	6b05                	lui	s6,0x1
  for(p = proc; p < &proc[NPROC]; p++) {
    800017c4:	6a19                	lui	s4,0x6
    800017c6:	a00a0a13          	addi	s4,s4,-1536 # 5a00 <_entry-0x7fffa600>
    char *pa = kalloc();
    800017ca:	b8aff0ef          	jal	80000b54 <kalloc>
    800017ce:	862a                	mv	a2,a0
    if(pa == 0)
    800017d0:	cd15                	beqz	a0,8000180c <proc_mapstacks+0x88>
    uint64 va = KSTACK((int) (p - proc));
    800017d2:	4034d593          	srai	a1,s1,0x3
    800017d6:	032585b3          	mul	a1,a1,s2
    800017da:	05b6                	slli	a1,a1,0xd
    800017dc:	6789                	lui	a5,0x2
    800017de:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017e0:	875e                	mv	a4,s7
    800017e2:	86da                	mv	a3,s6
    800017e4:	40b985b3          	sub	a1,s3,a1
    800017e8:	8556                	mv	a0,s5
    800017ea:	925ff0ef          	jal	8000110e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800017ee:	16848493          	addi	s1,s1,360
    800017f2:	fd449ce3          	bne	s1,s4,800017ca <proc_mapstacks+0x46>
  }
}
    800017f6:	60a6                	ld	ra,72(sp)
    800017f8:	6406                	ld	s0,64(sp)
    800017fa:	74e2                	ld	s1,56(sp)
    800017fc:	7942                	ld	s2,48(sp)
    800017fe:	79a2                	ld	s3,40(sp)
    80001800:	7a02                	ld	s4,32(sp)
    80001802:	6ae2                	ld	s5,24(sp)
    80001804:	6b42                	ld	s6,16(sp)
    80001806:	6ba2                	ld	s7,8(sp)
    80001808:	6161                	addi	sp,sp,80
    8000180a:	8082                	ret
      panic("kalloc");
    8000180c:	00006517          	auipc	a0,0x6
    80001810:	94c50513          	addi	a0,a0,-1716 # 80007158 <etext+0x158>
    80001814:	824ff0ef          	jal	80000838 <panic>

0000000080001818 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001818:	7139                	addi	sp,sp,-64
    8000181a:	fc06                	sd	ra,56(sp)
    8000181c:	f822                	sd	s0,48(sp)
    8000181e:	f426                	sd	s1,40(sp)
    80001820:	f04a                	sd	s2,32(sp)
    80001822:	ec4e                	sd	s3,24(sp)
    80001824:	e852                	sd	s4,16(sp)
    80001826:	e456                	sd	s5,8(sp)
    80001828:	e05a                	sd	s6,0(sp)
    8000182a:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    8000182c:	00006597          	auipc	a1,0x6
    80001830:	93458593          	addi	a1,a1,-1740 # 80007160 <etext+0x160>
    80001834:	0000e517          	auipc	a0,0xe
    80001838:	13450513          	addi	a0,a0,308 # 8000f968 <pid_lock>
    8000183c:	b72ff0ef          	jal	80000bae <initlock>
  initlock(&wait_lock, "wait_lock");
    80001840:	00006597          	auipc	a1,0x6
    80001844:	92858593          	addi	a1,a1,-1752 # 80007168 <etext+0x168>
    80001848:	0000e517          	auipc	a0,0xe
    8000184c:	13850513          	addi	a0,a0,312 # 8000f980 <wait_lock>
    80001850:	b5eff0ef          	jal	80000bae <initlock>
    80001854:	4901                	li	s2,0
  for(p = proc; p < &proc[NPROC]; p++) {
    80001856:	0000e497          	auipc	s1,0xe
    8000185a:	54248493          	addi	s1,s1,1346 # 8000fd98 <proc>
      initlock(&p->lock, "proc");
    8000185e:	00006a97          	auipc	s5,0x6
    80001862:	91aa8a93          	addi	s5,s5,-1766 # 80007178 <etext+0x178>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001866:	000a57b7          	lui	a5,0xa5
    8000186a:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    8000186e:	07b2                	slli	a5,a5,0xc
    80001870:	fa578793          	addi	a5,a5,-91
    80001874:	4fa509b7          	lui	s3,0x4fa50
    80001878:	a4f98993          	addi	s3,s3,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    8000187c:	1982                	slli	s3,s3,0x20
    8000187e:	99be                	add	s3,s3,a5
    80001880:	04000a37          	lui	s4,0x4000
    80001884:	1a7d                	addi	s4,s4,-1 # 3ffffff <_entry-0x7c000001>
    80001886:	0a32                	slli	s4,s4,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001888:	00014b17          	auipc	s6,0x14
    8000188c:	f10b0b13          	addi	s6,s6,-240 # 80015798 <tickslock>
      initlock(&p->lock, "proc");
    80001890:	85d6                	mv	a1,s5
    80001892:	8526                	mv	a0,s1
    80001894:	b1aff0ef          	jal	80000bae <initlock>
      p->state = UNUSED;
    80001898:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    8000189c:	40395793          	srai	a5,s2,0x3
    800018a0:	033787b3          	mul	a5,a5,s3
    800018a4:	07b6                	slli	a5,a5,0xd
    800018a6:	6709                	lui	a4,0x2
    800018a8:	9fb9                	addw	a5,a5,a4
    800018aa:	40fa07b3          	sub	a5,s4,a5
    800018ae:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800018b0:	16848493          	addi	s1,s1,360
    800018b4:	16890913          	addi	s2,s2,360
    800018b8:	fd649ce3          	bne	s1,s6,80001890 <procinit+0x78>
  }
}
    800018bc:	70e2                	ld	ra,56(sp)
    800018be:	7442                	ld	s0,48(sp)
    800018c0:	74a2                	ld	s1,40(sp)
    800018c2:	7902                	ld	s2,32(sp)
    800018c4:	69e2                	ld	s3,24(sp)
    800018c6:	6a42                	ld	s4,16(sp)
    800018c8:	6aa2                	ld	s5,8(sp)
    800018ca:	6b02                	ld	s6,0(sp)
    800018cc:	6121                	addi	sp,sp,64
    800018ce:	8082                	ret

00000000800018d0 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018d0:	1141                	addi	sp,sp,-16
    800018d2:	e406                	sd	ra,8(sp)
    800018d4:	e022                	sd	s0,0(sp)
    800018d6:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800018d8:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018da:	2501                	sext.w	a0,a0
    800018dc:	60a2                	ld	ra,8(sp)
    800018de:	6402                	ld	s0,0(sp)
    800018e0:	0141                	addi	sp,sp,16
    800018e2:	8082                	ret

00000000800018e4 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800018e4:	1141                	addi	sp,sp,-16
    800018e6:	e406                	sd	ra,8(sp)
    800018e8:	e022                	sd	s0,0(sp)
    800018ea:	0800                	addi	s0,sp,16
    800018ec:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018ee:	2781                	sext.w	a5,a5
    800018f0:	079e                	slli	a5,a5,0x7
  return c;
}
    800018f2:	0000e517          	auipc	a0,0xe
    800018f6:	0a650513          	addi	a0,a0,166 # 8000f998 <cpus>
    800018fa:	953e                	add	a0,a0,a5
    800018fc:	60a2                	ld	ra,8(sp)
    800018fe:	6402                	ld	s0,0(sp)
    80001900:	0141                	addi	sp,sp,16
    80001902:	8082                	ret

0000000080001904 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001904:	1101                	addi	sp,sp,-32
    80001906:	ec06                	sd	ra,24(sp)
    80001908:	e822                	sd	s0,16(sp)
    8000190a:	e426                	sd	s1,8(sp)
    8000190c:	1000                	addi	s0,sp,32
  push_off();
    8000190e:	ae6ff0ef          	jal	80000bf4 <push_off>
    80001912:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001914:	2781                	sext.w	a5,a5
    80001916:	079e                	slli	a5,a5,0x7
    80001918:	0000e717          	auipc	a4,0xe
    8000191c:	05070713          	addi	a4,a4,80 # 8000f968 <pid_lock>
    80001920:	97ba                	add	a5,a5,a4
    80001922:	7b9c                	ld	a5,48(a5)
    80001924:	84be                	mv	s1,a5
  pop_off();
    80001926:	b52ff0ef          	jal	80000c78 <pop_off>
  return p;
}
    8000192a:	8526                	mv	a0,s1
    8000192c:	60e2                	ld	ra,24(sp)
    8000192e:	6442                	ld	s0,16(sp)
    80001930:	64a2                	ld	s1,8(sp)
    80001932:	6105                	addi	sp,sp,32
    80001934:	8082                	ret

0000000080001936 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001936:	7179                	addi	sp,sp,-48
    80001938:	f406                	sd	ra,40(sp)
    8000193a:	f022                	sd	s0,32(sp)
    8000193c:	ec26                	sd	s1,24(sp)
    8000193e:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001940:	fc5ff0ef          	jal	80001904 <myproc>
    80001944:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001946:	b82ff0ef          	jal	80000cc8 <release>

  if (first) {
    8000194a:	00006797          	auipc	a5,0x6
    8000194e:	ee67a783          	lw	a5,-282(a5) # 80007830 <first.1>
    80001952:	cf95                	beqz	a5,8000198e <forkret+0x58>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001954:	4505                	li	a0,1
    80001956:	37f010ef          	jal	800034d4 <fsinit>

    first = 0;
    8000195a:	00006797          	auipc	a5,0x6
    8000195e:	ec07ab23          	sw	zero,-298(a5) # 80007830 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001962:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001966:	00006797          	auipc	a5,0x6
    8000196a:	81a78793          	addi	a5,a5,-2022 # 80007180 <etext+0x180>
    8000196e:	fcf43823          	sd	a5,-48(s0)
    80001972:	fc043c23          	sd	zero,-40(s0)
    80001976:	fd040593          	addi	a1,s0,-48
    8000197a:	853e                	mv	a0,a5
    8000197c:	4db020ef          	jal	80004656 <kexec>
    80001980:	6cbc                	ld	a5,88(s1)
    80001982:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001984:	6cbc                	ld	a5,88(s1)
    80001986:	7bb8                	ld	a4,112(a5)
    80001988:	57fd                	li	a5,-1
    8000198a:	02f70d63          	beq	a4,a5,800019c4 <forkret+0x8e>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    8000198e:	2a5000ef          	jal	80002432 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001992:	68a8                	ld	a0,80(s1)
    80001994:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001996:	04000737          	lui	a4,0x4000
    8000199a:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    8000199c:	0732                	slli	a4,a4,0xc
    8000199e:	00004797          	auipc	a5,0x4
    800019a2:	6fe78793          	addi	a5,a5,1790 # 8000609c <userret>
    800019a6:	00004697          	auipc	a3,0x4
    800019aa:	65a68693          	addi	a3,a3,1626 # 80006000 <_trampoline>
    800019ae:	8f95                	sub	a5,a5,a3
    800019b0:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800019b2:	577d                	li	a4,-1
    800019b4:	177e                	slli	a4,a4,0x3f
    800019b6:	8d59                	or	a0,a0,a4
    800019b8:	9782                	jalr	a5
}
    800019ba:	70a2                	ld	ra,40(sp)
    800019bc:	7402                	ld	s0,32(sp)
    800019be:	64e2                	ld	s1,24(sp)
    800019c0:	6145                	addi	sp,sp,48
    800019c2:	8082                	ret
      panic("exec");
    800019c4:	00005517          	auipc	a0,0x5
    800019c8:	7c450513          	addi	a0,a0,1988 # 80007188 <etext+0x188>
    800019cc:	e6dfe0ef          	jal	80000838 <panic>

00000000800019d0 <allocpid>:
{
    800019d0:	1101                	addi	sp,sp,-32
    800019d2:	ec06                	sd	ra,24(sp)
    800019d4:	e822                	sd	s0,16(sp)
    800019d6:	e426                	sd	s1,8(sp)
    800019d8:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800019da:	0000e517          	auipc	a0,0xe
    800019de:	f8e50513          	addi	a0,a0,-114 # 8000f968 <pid_lock>
    800019e2:	a56ff0ef          	jal	80000c38 <acquire>
  pid = nextpid;
    800019e6:	00006797          	auipc	a5,0x6
    800019ea:	e4e78793          	addi	a5,a5,-434 # 80007834 <nextpid>
    800019ee:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800019f0:	0014871b          	addiw	a4,s1,1
    800019f4:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800019f6:	0000e517          	auipc	a0,0xe
    800019fa:	f7250513          	addi	a0,a0,-142 # 8000f968 <pid_lock>
    800019fe:	acaff0ef          	jal	80000cc8 <release>
}
    80001a02:	8526                	mv	a0,s1
    80001a04:	60e2                	ld	ra,24(sp)
    80001a06:	6442                	ld	s0,16(sp)
    80001a08:	64a2                	ld	s1,8(sp)
    80001a0a:	6105                	addi	sp,sp,32
    80001a0c:	8082                	ret

0000000080001a0e <proc_pagetable>:
{
    80001a0e:	1101                	addi	sp,sp,-32
    80001a10:	ec06                	sd	ra,24(sp)
    80001a12:	e822                	sd	s0,16(sp)
    80001a14:	e426                	sd	s1,8(sp)
    80001a16:	e04a                	sd	s2,0(sp)
    80001a18:	1000                	addi	s0,sp,32
    80001a1a:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a1c:	fe0ff0ef          	jal	800011fc <uvmcreate>
    80001a20:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a22:	cd05                	beqz	a0,80001a5a <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a24:	4729                	li	a4,10
    80001a26:	00004697          	auipc	a3,0x4
    80001a2a:	5da68693          	addi	a3,a3,1498 # 80006000 <_trampoline>
    80001a2e:	6605                	lui	a2,0x1
    80001a30:	040005b7          	lui	a1,0x4000
    80001a34:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a36:	05b2                	slli	a1,a1,0xc
    80001a38:	e24ff0ef          	jal	8000105c <mappages>
    80001a3c:	02054663          	bltz	a0,80001a68 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001a40:	4719                	li	a4,6
    80001a42:	05893683          	ld	a3,88(s2)
    80001a46:	6605                	lui	a2,0x1
    80001a48:	020005b7          	lui	a1,0x2000
    80001a4c:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a4e:	05b6                	slli	a1,a1,0xd
    80001a50:	8526                	mv	a0,s1
    80001a52:	e0aff0ef          	jal	8000105c <mappages>
    80001a56:	00054f63          	bltz	a0,80001a74 <proc_pagetable+0x66>
}
    80001a5a:	8526                	mv	a0,s1
    80001a5c:	60e2                	ld	ra,24(sp)
    80001a5e:	6442                	ld	s0,16(sp)
    80001a60:	64a2                	ld	s1,8(sp)
    80001a62:	6902                	ld	s2,0(sp)
    80001a64:	6105                	addi	sp,sp,32
    80001a66:	8082                	ret
    uvmfree(pagetable, 0);
    80001a68:	4581                	li	a1,0
    80001a6a:	8526                	mv	a0,s1
    80001a6c:	983ff0ef          	jal	800013ee <uvmfree>
    return 0;
    80001a70:	4481                	li	s1,0
    80001a72:	b7e5                	j	80001a5a <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a74:	4681                	li	a3,0
    80001a76:	4605                	li	a2,1
    80001a78:	040005b7          	lui	a1,0x4000
    80001a7c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a7e:	05b2                	slli	a1,a1,0xc
    80001a80:	8526                	mv	a0,s1
    80001a82:	fa0ff0ef          	jal	80001222 <uvmunmap>
    uvmfree(pagetable, 0);
    80001a86:	4581                	li	a1,0
    80001a88:	8526                	mv	a0,s1
    80001a8a:	965ff0ef          	jal	800013ee <uvmfree>
    return 0;
    80001a8e:	b7cd                	j	80001a70 <proc_pagetable+0x62>

0000000080001a90 <proc_freepagetable>:
{
    80001a90:	1101                	addi	sp,sp,-32
    80001a92:	ec06                	sd	ra,24(sp)
    80001a94:	e822                	sd	s0,16(sp)
    80001a96:	e426                	sd	s1,8(sp)
    80001a98:	e04a                	sd	s2,0(sp)
    80001a9a:	1000                	addi	s0,sp,32
    80001a9c:	84aa                	mv	s1,a0
    80001a9e:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001aa0:	4681                	li	a3,0
    80001aa2:	4605                	li	a2,1
    80001aa4:	040005b7          	lui	a1,0x4000
    80001aa8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001aaa:	05b2                	slli	a1,a1,0xc
    80001aac:	f76ff0ef          	jal	80001222 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001ab0:	4681                	li	a3,0
    80001ab2:	4605                	li	a2,1
    80001ab4:	020005b7          	lui	a1,0x2000
    80001ab8:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001aba:	05b6                	slli	a1,a1,0xd
    80001abc:	8526                	mv	a0,s1
    80001abe:	f64ff0ef          	jal	80001222 <uvmunmap>
  uvmfree(pagetable, sz);
    80001ac2:	85ca                	mv	a1,s2
    80001ac4:	8526                	mv	a0,s1
    80001ac6:	929ff0ef          	jal	800013ee <uvmfree>
}
    80001aca:	60e2                	ld	ra,24(sp)
    80001acc:	6442                	ld	s0,16(sp)
    80001ace:	64a2                	ld	s1,8(sp)
    80001ad0:	6902                	ld	s2,0(sp)
    80001ad2:	6105                	addi	sp,sp,32
    80001ad4:	8082                	ret

0000000080001ad6 <freeproc>:
{
    80001ad6:	1101                	addi	sp,sp,-32
    80001ad8:	ec06                	sd	ra,24(sp)
    80001ada:	e822                	sd	s0,16(sp)
    80001adc:	e426                	sd	s1,8(sp)
    80001ade:	1000                	addi	s0,sp,32
    80001ae0:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001ae2:	6d28                	ld	a0,88(a0)
    80001ae4:	c119                	beqz	a0,80001aea <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001ae6:	f87fe0ef          	jal	80000a6c <kfree>
  p->trapframe = 0;
    80001aea:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001aee:	68a8                	ld	a0,80(s1)
    80001af0:	c501                	beqz	a0,80001af8 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001af2:	64ac                	ld	a1,72(s1)
    80001af4:	f9dff0ef          	jal	80001a90 <proc_freepagetable>
  p->pagetable = 0;
    80001af8:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001afc:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b00:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b04:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b08:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b0c:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b10:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b14:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b18:	0004ac23          	sw	zero,24(s1)
}
    80001b1c:	60e2                	ld	ra,24(sp)
    80001b1e:	6442                	ld	s0,16(sp)
    80001b20:	64a2                	ld	s1,8(sp)
    80001b22:	6105                	addi	sp,sp,32
    80001b24:	8082                	ret

0000000080001b26 <allocproc>:
{
    80001b26:	1101                	addi	sp,sp,-32
    80001b28:	ec06                	sd	ra,24(sp)
    80001b2a:	e822                	sd	s0,16(sp)
    80001b2c:	e426                	sd	s1,8(sp)
    80001b2e:	e04a                	sd	s2,0(sp)
    80001b30:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b32:	0000e497          	auipc	s1,0xe
    80001b36:	26648493          	addi	s1,s1,614 # 8000fd98 <proc>
    80001b3a:	00014917          	auipc	s2,0x14
    80001b3e:	c5e90913          	addi	s2,s2,-930 # 80015798 <tickslock>
    acquire(&p->lock);
    80001b42:	8526                	mv	a0,s1
    80001b44:	8f4ff0ef          	jal	80000c38 <acquire>
    if(p->state == UNUSED) {
    80001b48:	4c9c                	lw	a5,24(s1)
    80001b4a:	cb91                	beqz	a5,80001b5e <allocproc+0x38>
      release(&p->lock);
    80001b4c:	8526                	mv	a0,s1
    80001b4e:	97aff0ef          	jal	80000cc8 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b52:	16848493          	addi	s1,s1,360
    80001b56:	ff2496e3          	bne	s1,s2,80001b42 <allocproc+0x1c>
  return 0;
    80001b5a:	4481                	li	s1,0
    80001b5c:	a089                	j	80001b9e <allocproc+0x78>
  p->pid = allocpid();
    80001b5e:	e73ff0ef          	jal	800019d0 <allocpid>
    80001b62:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001b64:	4785                	li	a5,1
    80001b66:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001b68:	fedfe0ef          	jal	80000b54 <kalloc>
    80001b6c:	892a                	mv	s2,a0
    80001b6e:	eca8                	sd	a0,88(s1)
    80001b70:	cd15                	beqz	a0,80001bac <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001b72:	8526                	mv	a0,s1
    80001b74:	e9bff0ef          	jal	80001a0e <proc_pagetable>
    80001b78:	892a                	mv	s2,a0
    80001b7a:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001b7c:	c121                	beqz	a0,80001bbc <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001b7e:	07000613          	li	a2,112
    80001b82:	4581                	li	a1,0
    80001b84:	06048513          	addi	a0,s1,96
    80001b88:	97cff0ef          	jal	80000d04 <memset>
  p->context.ra = (uint64)forkret;
    80001b8c:	00000797          	auipc	a5,0x0
    80001b90:	daa78793          	addi	a5,a5,-598 # 80001936 <forkret>
    80001b94:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b96:	60bc                	ld	a5,64(s1)
    80001b98:	6705                	lui	a4,0x1
    80001b9a:	97ba                	add	a5,a5,a4
    80001b9c:	f4bc                	sd	a5,104(s1)
}
    80001b9e:	8526                	mv	a0,s1
    80001ba0:	60e2                	ld	ra,24(sp)
    80001ba2:	6442                	ld	s0,16(sp)
    80001ba4:	64a2                	ld	s1,8(sp)
    80001ba6:	6902                	ld	s2,0(sp)
    80001ba8:	6105                	addi	sp,sp,32
    80001baa:	8082                	ret
    freeproc(p);
    80001bac:	8526                	mv	a0,s1
    80001bae:	f29ff0ef          	jal	80001ad6 <freeproc>
    release(&p->lock);
    80001bb2:	8526                	mv	a0,s1
    80001bb4:	914ff0ef          	jal	80000cc8 <release>
    return 0;
    80001bb8:	84ca                	mv	s1,s2
    80001bba:	b7d5                	j	80001b9e <allocproc+0x78>
    freeproc(p);
    80001bbc:	8526                	mv	a0,s1
    80001bbe:	f19ff0ef          	jal	80001ad6 <freeproc>
    release(&p->lock);
    80001bc2:	8526                	mv	a0,s1
    80001bc4:	904ff0ef          	jal	80000cc8 <release>
    return 0;
    80001bc8:	84ca                	mv	s1,s2
    80001bca:	bfd1                	j	80001b9e <allocproc+0x78>

0000000080001bcc <userinit>:
{
    80001bcc:	1101                	addi	sp,sp,-32
    80001bce:	ec06                	sd	ra,24(sp)
    80001bd0:	e822                	sd	s0,16(sp)
    80001bd2:	e426                	sd	s1,8(sp)
    80001bd4:	1000                	addi	s0,sp,32
  p = allocproc();
    80001bd6:	f51ff0ef          	jal	80001b26 <allocproc>
    80001bda:	84aa                	mv	s1,a0
  initproc = p;
    80001bdc:	00006797          	auipc	a5,0x6
    80001be0:	c8a7b223          	sd	a0,-892(a5) # 80007860 <initproc>
  p->cwd = namei("/");
    80001be4:	00005517          	auipc	a0,0x5
    80001be8:	5ac50513          	addi	a0,a0,1452 # 80007190 <etext+0x190>
    80001bec:	62d010ef          	jal	80003a18 <namei>
    80001bf0:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001bf4:	478d                	li	a5,3
    80001bf6:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001bf8:	8526                	mv	a0,s1
    80001bfa:	8ceff0ef          	jal	80000cc8 <release>
}
    80001bfe:	60e2                	ld	ra,24(sp)
    80001c00:	6442                	ld	s0,16(sp)
    80001c02:	64a2                	ld	s1,8(sp)
    80001c04:	6105                	addi	sp,sp,32
    80001c06:	8082                	ret

0000000080001c08 <growproc>:
{
    80001c08:	1101                	addi	sp,sp,-32
    80001c0a:	ec06                	sd	ra,24(sp)
    80001c0c:	e822                	sd	s0,16(sp)
    80001c0e:	e426                	sd	s1,8(sp)
    80001c10:	e04a                	sd	s2,0(sp)
    80001c12:	1000                	addi	s0,sp,32
    80001c14:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c16:	cefff0ef          	jal	80001904 <myproc>
    80001c1a:	892a                	mv	s2,a0
  sz = p->sz;
    80001c1c:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001c1e:	02905b63          	blez	s1,80001c54 <growproc+0x4c>
    if(sz + n > TRAPFRAME) {
    80001c22:	00b48633          	add	a2,s1,a1
    80001c26:	020007b7          	lui	a5,0x2000
    80001c2a:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c2c:	07b6                	slli	a5,a5,0xd
    80001c2e:	02c7e163          	bltu	a5,a2,80001c50 <growproc+0x48>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c32:	4691                	li	a3,4
    80001c34:	6928                	ld	a0,80(a0)
    80001c36:	ebcff0ef          	jal	800012f2 <uvmalloc>
    80001c3a:	85aa                	mv	a1,a0
    80001c3c:	c911                	beqz	a0,80001c50 <growproc+0x48>
  p->sz = sz;
    80001c3e:	04b93423          	sd	a1,72(s2)
  return 0;
    80001c42:	4501                	li	a0,0
}
    80001c44:	60e2                	ld	ra,24(sp)
    80001c46:	6442                	ld	s0,16(sp)
    80001c48:	64a2                	ld	s1,8(sp)
    80001c4a:	6902                	ld	s2,0(sp)
    80001c4c:	6105                	addi	sp,sp,32
    80001c4e:	8082                	ret
      return -1;
    80001c50:	557d                	li	a0,-1
    80001c52:	bfcd                	j	80001c44 <growproc+0x3c>
  } else if(n < 0){
    80001c54:	fe04d5e3          	bgez	s1,80001c3e <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c58:	00b48633          	add	a2,s1,a1
    80001c5c:	6928                	ld	a0,80(a0)
    80001c5e:	e4eff0ef          	jal	800012ac <uvmdealloc>
    80001c62:	85aa                	mv	a1,a0
    80001c64:	bfe9                	j	80001c3e <growproc+0x36>

0000000080001c66 <kfork>:
{
    80001c66:	7139                	addi	sp,sp,-64
    80001c68:	fc06                	sd	ra,56(sp)
    80001c6a:	f822                	sd	s0,48(sp)
    80001c6c:	f426                	sd	s1,40(sp)
    80001c6e:	e456                	sd	s5,8(sp)
    80001c70:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c72:	c93ff0ef          	jal	80001904 <myproc>
    80001c76:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001c78:	eafff0ef          	jal	80001b26 <allocproc>
    80001c7c:	c92d                	beqz	a0,80001cee <kfork+0x88>
    80001c7e:	e852                	sd	s4,16(sp)
    80001c80:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c82:	048ab603          	ld	a2,72(s5)
    80001c86:	692c                	ld	a1,80(a0)
    80001c88:	050ab503          	ld	a0,80(s5)
    80001c8c:	f94ff0ef          	jal	80001420 <uvmcopy>
    80001c90:	04054863          	bltz	a0,80001ce0 <kfork+0x7a>
    80001c94:	f04a                	sd	s2,32(sp)
    80001c96:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001c98:	048ab783          	ld	a5,72(s5)
    80001c9c:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001ca0:	058ab683          	ld	a3,88(s5)
    80001ca4:	87b6                	mv	a5,a3
    80001ca6:	058a3703          	ld	a4,88(s4)
    80001caa:	12068693          	addi	a3,a3,288
    80001cae:	6388                	ld	a0,0(a5)
    80001cb0:	678c                	ld	a1,8(a5)
    80001cb2:	6b90                	ld	a2,16(a5)
    80001cb4:	e308                	sd	a0,0(a4)
    80001cb6:	e70c                	sd	a1,8(a4)
    80001cb8:	eb10                	sd	a2,16(a4)
    80001cba:	6f90                	ld	a2,24(a5)
    80001cbc:	ef10                	sd	a2,24(a4)
    80001cbe:	02078793          	addi	a5,a5,32
    80001cc2:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001cc6:	fed794e3          	bne	a5,a3,80001cae <kfork+0x48>
  np->trapframe->a0 = 0;
    80001cca:	058a3783          	ld	a5,88(s4)
    80001cce:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001cd2:	0d0a8493          	addi	s1,s5,208
    80001cd6:	0d0a0913          	addi	s2,s4,208
    80001cda:	150a8993          	addi	s3,s5,336
    80001cde:	a831                	j	80001cfa <kfork+0x94>
    freeproc(np);
    80001ce0:	8552                	mv	a0,s4
    80001ce2:	df5ff0ef          	jal	80001ad6 <freeproc>
    release(&np->lock);
    80001ce6:	8552                	mv	a0,s4
    80001ce8:	fe1fe0ef          	jal	80000cc8 <release>
    return -1;
    80001cec:	6a42                	ld	s4,16(sp)
    return -1;
    80001cee:	54fd                	li	s1,-1
    80001cf0:	a885                	j	80001d60 <kfork+0xfa>
  for(i = 0; i < NOFILE; i++)
    80001cf2:	04a1                	addi	s1,s1,8
    80001cf4:	0921                	addi	s2,s2,8
    80001cf6:	01348963          	beq	s1,s3,80001d08 <kfork+0xa2>
    if(p->ofile[i])
    80001cfa:	6088                	ld	a0,0(s1)
    80001cfc:	d97d                	beqz	a0,80001cf2 <kfork+0x8c>
      np->ofile[i] = filedup(p->ofile[i]);
    80001cfe:	2d2020ef          	jal	80003fd0 <filedup>
    80001d02:	00a93023          	sd	a0,0(s2)
    80001d06:	b7f5                	j	80001cf2 <kfork+0x8c>
  np->cwd = idup(p->cwd);
    80001d08:	150ab503          	ld	a0,336(s5)
    80001d0c:	49e010ef          	jal	800031aa <idup>
    80001d10:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d14:	4641                	li	a2,16
    80001d16:	158a8593          	addi	a1,s5,344
    80001d1a:	158a0513          	addi	a0,s4,344
    80001d1e:	930ff0ef          	jal	80000e4e <safestrcpy>
  pid = np->pid;
    80001d22:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001d26:	8552                	mv	a0,s4
    80001d28:	fa1fe0ef          	jal	80000cc8 <release>
  acquire(&wait_lock);
    80001d2c:	0000e517          	auipc	a0,0xe
    80001d30:	c5450513          	addi	a0,a0,-940 # 8000f980 <wait_lock>
    80001d34:	f05fe0ef          	jal	80000c38 <acquire>
  np->parent = p;
    80001d38:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001d3c:	0000e517          	auipc	a0,0xe
    80001d40:	c4450513          	addi	a0,a0,-956 # 8000f980 <wait_lock>
    80001d44:	f85fe0ef          	jal	80000cc8 <release>
  acquire(&np->lock);
    80001d48:	8552                	mv	a0,s4
    80001d4a:	eeffe0ef          	jal	80000c38 <acquire>
  np->state = RUNNABLE;
    80001d4e:	478d                	li	a5,3
    80001d50:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001d54:	8552                	mv	a0,s4
    80001d56:	f73fe0ef          	jal	80000cc8 <release>
    80001d5a:	7902                	ld	s2,32(sp)
    80001d5c:	69e2                	ld	s3,24(sp)
    80001d5e:	6a42                	ld	s4,16(sp)
}
    80001d60:	8526                	mv	a0,s1
    80001d62:	70e2                	ld	ra,56(sp)
    80001d64:	7442                	ld	s0,48(sp)
    80001d66:	74a2                	ld	s1,40(sp)
    80001d68:	6aa2                	ld	s5,8(sp)
    80001d6a:	6121                	addi	sp,sp,64
    80001d6c:	8082                	ret

0000000080001d6e <scheduler>:
{
    80001d6e:	715d                	addi	sp,sp,-80
    80001d70:	e486                	sd	ra,72(sp)
    80001d72:	e0a2                	sd	s0,64(sp)
    80001d74:	fc26                	sd	s1,56(sp)
    80001d76:	f84a                	sd	s2,48(sp)
    80001d78:	f44e                	sd	s3,40(sp)
    80001d7a:	f052                	sd	s4,32(sp)
    80001d7c:	ec56                	sd	s5,24(sp)
    80001d7e:	e85a                	sd	s6,16(sp)
    80001d80:	e45e                	sd	s7,8(sp)
    80001d82:	e062                	sd	s8,0(sp)
    80001d84:	0880                	addi	s0,sp,80
    80001d86:	8792                	mv	a5,tp
  int id = r_tp();
    80001d88:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d8a:	00779693          	slli	a3,a5,0x7
    80001d8e:	0000e717          	auipc	a4,0xe
    80001d92:	bda70713          	addi	a4,a4,-1062 # 8000f968 <pid_lock>
    80001d96:	9736                	add	a4,a4,a3
    80001d98:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d9c:	0000eb17          	auipc	s6,0xe
    80001da0:	c04b0b13          	addi	s6,s6,-1020 # 8000f9a0 <cpus+0x8>
    80001da4:	9b36                	add	s6,s6,a3
        p->state = RUNNING;
    80001da6:	4c11                	li	s8,4
        c->proc = p;
    80001da8:	8a3a                	mv	s4,a4
        found = 1;
    80001daa:	4b85                	li	s7,1
    80001dac:	a83d                	j	80001dea <scheduler+0x7c>
      release(&p->lock);
    80001dae:	8526                	mv	a0,s1
    80001db0:	f19fe0ef          	jal	80000cc8 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001db4:	16848493          	addi	s1,s1,360
    80001db8:	03248563          	beq	s1,s2,80001de2 <scheduler+0x74>
      acquire(&p->lock);
    80001dbc:	8526                	mv	a0,s1
    80001dbe:	e7bfe0ef          	jal	80000c38 <acquire>
      if(p->state == RUNNABLE) {
    80001dc2:	4c9c                	lw	a5,24(s1)
    80001dc4:	ff3795e3          	bne	a5,s3,80001dae <scheduler+0x40>
        p->state = RUNNING;
    80001dc8:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001dcc:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001dd0:	06048593          	addi	a1,s1,96
    80001dd4:	855a                	mv	a0,s6
    80001dd6:	5b2000ef          	jal	80002388 <swtch>
        c->proc = 0;
    80001dda:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001dde:	8ade                	mv	s5,s7
    80001de0:	b7f9                	j	80001dae <scheduler+0x40>
    if(found == 0) {
    80001de2:	000a9463          	bnez	s5,80001dea <scheduler+0x7c>
      asm volatile("wfi");
    80001de6:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dea:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001dee:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001df2:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001df6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001dfa:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001dfc:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001e00:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001e02:	0000e497          	auipc	s1,0xe
    80001e06:	f9648493          	addi	s1,s1,-106 # 8000fd98 <proc>
      if(p->state == RUNNABLE) {
    80001e0a:	498d                	li	s3,3
    for(p = proc; p < &proc[NPROC]; p++) {
    80001e0c:	00014917          	auipc	s2,0x14
    80001e10:	98c90913          	addi	s2,s2,-1652 # 80015798 <tickslock>
    80001e14:	b765                	j	80001dbc <scheduler+0x4e>

0000000080001e16 <sched>:
{
    80001e16:	7179                	addi	sp,sp,-48
    80001e18:	f406                	sd	ra,40(sp)
    80001e1a:	f022                	sd	s0,32(sp)
    80001e1c:	ec26                	sd	s1,24(sp)
    80001e1e:	e84a                	sd	s2,16(sp)
    80001e20:	e44e                	sd	s3,8(sp)
    80001e22:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e24:	ae1ff0ef          	jal	80001904 <myproc>
    80001e28:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001e2a:	d9ffe0ef          	jal	80000bc8 <holding>
    80001e2e:	c92d                	beqz	a0,80001ea0 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e30:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001e32:	2781                	sext.w	a5,a5
    80001e34:	079e                	slli	a5,a5,0x7
    80001e36:	0000e717          	auipc	a4,0xe
    80001e3a:	b3270713          	addi	a4,a4,-1230 # 8000f968 <pid_lock>
    80001e3e:	97ba                	add	a5,a5,a4
    80001e40:	0a87a703          	lw	a4,168(a5)
    80001e44:	4785                	li	a5,1
    80001e46:	06f71363          	bne	a4,a5,80001eac <sched+0x96>
  if(p->state == RUNNING)
    80001e4a:	4c98                	lw	a4,24(s1)
    80001e4c:	4791                	li	a5,4
    80001e4e:	06f70563          	beq	a4,a5,80001eb8 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e52:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e56:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e58:	e7b5                	bnez	a5,80001ec4 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e5a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e5c:	0000e917          	auipc	s2,0xe
    80001e60:	b0c90913          	addi	s2,s2,-1268 # 8000f968 <pid_lock>
    80001e64:	2781                	sext.w	a5,a5
    80001e66:	079e                	slli	a5,a5,0x7
    80001e68:	97ca                	add	a5,a5,s2
    80001e6a:	0ac7a983          	lw	s3,172(a5)
    80001e6e:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e70:	2781                	sext.w	a5,a5
    80001e72:	079e                	slli	a5,a5,0x7
    80001e74:	0000e597          	auipc	a1,0xe
    80001e78:	b2c58593          	addi	a1,a1,-1236 # 8000f9a0 <cpus+0x8>
    80001e7c:	95be                	add	a1,a1,a5
    80001e7e:	06048513          	addi	a0,s1,96
    80001e82:	506000ef          	jal	80002388 <swtch>
    80001e86:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e88:	2781                	sext.w	a5,a5
    80001e8a:	079e                	slli	a5,a5,0x7
    80001e8c:	993e                	add	s2,s2,a5
    80001e8e:	0b392623          	sw	s3,172(s2)
}
    80001e92:	70a2                	ld	ra,40(sp)
    80001e94:	7402                	ld	s0,32(sp)
    80001e96:	64e2                	ld	s1,24(sp)
    80001e98:	6942                	ld	s2,16(sp)
    80001e9a:	69a2                	ld	s3,8(sp)
    80001e9c:	6145                	addi	sp,sp,48
    80001e9e:	8082                	ret
    panic("sched p->lock");
    80001ea0:	00005517          	auipc	a0,0x5
    80001ea4:	2f850513          	addi	a0,a0,760 # 80007198 <etext+0x198>
    80001ea8:	991fe0ef          	jal	80000838 <panic>
    panic("sched locks");
    80001eac:	00005517          	auipc	a0,0x5
    80001eb0:	2fc50513          	addi	a0,a0,764 # 800071a8 <etext+0x1a8>
    80001eb4:	985fe0ef          	jal	80000838 <panic>
    panic("sched RUNNING");
    80001eb8:	00005517          	auipc	a0,0x5
    80001ebc:	30050513          	addi	a0,a0,768 # 800071b8 <etext+0x1b8>
    80001ec0:	979fe0ef          	jal	80000838 <panic>
    panic("sched interruptible");
    80001ec4:	00005517          	auipc	a0,0x5
    80001ec8:	30450513          	addi	a0,a0,772 # 800071c8 <etext+0x1c8>
    80001ecc:	96dfe0ef          	jal	80000838 <panic>

0000000080001ed0 <yield>:
{
    80001ed0:	1101                	addi	sp,sp,-32
    80001ed2:	ec06                	sd	ra,24(sp)
    80001ed4:	e822                	sd	s0,16(sp)
    80001ed6:	e426                	sd	s1,8(sp)
    80001ed8:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001eda:	a2bff0ef          	jal	80001904 <myproc>
    80001ede:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001ee0:	d59fe0ef          	jal	80000c38 <acquire>
  p->state = RUNNABLE;
    80001ee4:	478d                	li	a5,3
    80001ee6:	cc9c                	sw	a5,24(s1)
  sched();
    80001ee8:	f2fff0ef          	jal	80001e16 <sched>
  release(&p->lock);
    80001eec:	8526                	mv	a0,s1
    80001eee:	ddbfe0ef          	jal	80000cc8 <release>
}
    80001ef2:	60e2                	ld	ra,24(sp)
    80001ef4:	6442                	ld	s0,16(sp)
    80001ef6:	64a2                	ld	s1,8(sp)
    80001ef8:	6105                	addi	sp,sp,32
    80001efa:	8082                	ret

0000000080001efc <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001efc:	7179                	addi	sp,sp,-48
    80001efe:	f406                	sd	ra,40(sp)
    80001f00:	f022                	sd	s0,32(sp)
    80001f02:	ec26                	sd	s1,24(sp)
    80001f04:	e84a                	sd	s2,16(sp)
    80001f06:	e44e                	sd	s3,8(sp)
    80001f08:	1800                	addi	s0,sp,48
    80001f0a:	89aa                	mv	s3,a0
    80001f0c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001f0e:	9f7ff0ef          	jal	80001904 <myproc>
    80001f12:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001f14:	d25fe0ef          	jal	80000c38 <acquire>
  release(lk);
    80001f18:	854a                	mv	a0,s2
    80001f1a:	daffe0ef          	jal	80000cc8 <release>

  // Go to sleep.
  p->chan = chan;
    80001f1e:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001f22:	4789                	li	a5,2
    80001f24:	cc9c                	sw	a5,24(s1)

  sched();
    80001f26:	ef1ff0ef          	jal	80001e16 <sched>

  // Tidy up.
  p->chan = 0;
    80001f2a:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001f2e:	8526                	mv	a0,s1
    80001f30:	d99fe0ef          	jal	80000cc8 <release>
  acquire(lk);
    80001f34:	854a                	mv	a0,s2
    80001f36:	d03fe0ef          	jal	80000c38 <acquire>
}
    80001f3a:	70a2                	ld	ra,40(sp)
    80001f3c:	7402                	ld	s0,32(sp)
    80001f3e:	64e2                	ld	s1,24(sp)
    80001f40:	6942                	ld	s2,16(sp)
    80001f42:	69a2                	ld	s3,8(sp)
    80001f44:	6145                	addi	sp,sp,48
    80001f46:	8082                	ret

0000000080001f48 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80001f48:	7139                	addi	sp,sp,-64
    80001f4a:	fc06                	sd	ra,56(sp)
    80001f4c:	f822                	sd	s0,48(sp)
    80001f4e:	f426                	sd	s1,40(sp)
    80001f50:	f04a                	sd	s2,32(sp)
    80001f52:	ec4e                	sd	s3,24(sp)
    80001f54:	e852                	sd	s4,16(sp)
    80001f56:	e456                	sd	s5,8(sp)
    80001f58:	0080                	addi	s0,sp,64
    80001f5a:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f5c:	0000e497          	auipc	s1,0xe
    80001f60:	e3c48493          	addi	s1,s1,-452 # 8000fd98 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f64:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f66:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f68:	00014917          	auipc	s2,0x14
    80001f6c:	83090913          	addi	s2,s2,-2000 # 80015798 <tickslock>
    80001f70:	a801                	j	80001f80 <wakeup+0x38>
      }
      release(&p->lock);
    80001f72:	8526                	mv	a0,s1
    80001f74:	d55fe0ef          	jal	80000cc8 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f78:	16848493          	addi	s1,s1,360
    80001f7c:	03248263          	beq	s1,s2,80001fa0 <wakeup+0x58>
    if(p != myproc()){
    80001f80:	985ff0ef          	jal	80001904 <myproc>
    80001f84:	fe950ae3          	beq	a0,s1,80001f78 <wakeup+0x30>
      acquire(&p->lock);
    80001f88:	8526                	mv	a0,s1
    80001f8a:	caffe0ef          	jal	80000c38 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001f8e:	4c9c                	lw	a5,24(s1)
    80001f90:	ff3791e3          	bne	a5,s3,80001f72 <wakeup+0x2a>
    80001f94:	709c                	ld	a5,32(s1)
    80001f96:	fd479ee3          	bne	a5,s4,80001f72 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001f9a:	0154ac23          	sw	s5,24(s1)
    80001f9e:	bfd1                	j	80001f72 <wakeup+0x2a>
    }
  }
}
    80001fa0:	70e2                	ld	ra,56(sp)
    80001fa2:	7442                	ld	s0,48(sp)
    80001fa4:	74a2                	ld	s1,40(sp)
    80001fa6:	7902                	ld	s2,32(sp)
    80001fa8:	69e2                	ld	s3,24(sp)
    80001faa:	6a42                	ld	s4,16(sp)
    80001fac:	6aa2                	ld	s5,8(sp)
    80001fae:	6121                	addi	sp,sp,64
    80001fb0:	8082                	ret

0000000080001fb2 <reparent>:
{
    80001fb2:	7179                	addi	sp,sp,-48
    80001fb4:	f406                	sd	ra,40(sp)
    80001fb6:	f022                	sd	s0,32(sp)
    80001fb8:	ec26                	sd	s1,24(sp)
    80001fba:	e84a                	sd	s2,16(sp)
    80001fbc:	e44e                	sd	s3,8(sp)
    80001fbe:	e052                	sd	s4,0(sp)
    80001fc0:	1800                	addi	s0,sp,48
    80001fc2:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fc4:	0000e497          	auipc	s1,0xe
    80001fc8:	dd448493          	addi	s1,s1,-556 # 8000fd98 <proc>
      pp->parent = initproc;
    80001fcc:	00006a17          	auipc	s4,0x6
    80001fd0:	894a0a13          	addi	s4,s4,-1900 # 80007860 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fd4:	00013997          	auipc	s3,0x13
    80001fd8:	7c498993          	addi	s3,s3,1988 # 80015798 <tickslock>
    80001fdc:	a029                	j	80001fe6 <reparent+0x34>
    80001fde:	16848493          	addi	s1,s1,360
    80001fe2:	01348b63          	beq	s1,s3,80001ff8 <reparent+0x46>
    if(pp->parent == p){
    80001fe6:	7c9c                	ld	a5,56(s1)
    80001fe8:	ff279be3          	bne	a5,s2,80001fde <reparent+0x2c>
      pp->parent = initproc;
    80001fec:	000a3503          	ld	a0,0(s4)
    80001ff0:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001ff2:	f57ff0ef          	jal	80001f48 <wakeup>
    80001ff6:	b7e5                	j	80001fde <reparent+0x2c>
}
    80001ff8:	70a2                	ld	ra,40(sp)
    80001ffa:	7402                	ld	s0,32(sp)
    80001ffc:	64e2                	ld	s1,24(sp)
    80001ffe:	6942                	ld	s2,16(sp)
    80002000:	69a2                	ld	s3,8(sp)
    80002002:	6a02                	ld	s4,0(sp)
    80002004:	6145                	addi	sp,sp,48
    80002006:	8082                	ret

0000000080002008 <kexit>:
{
    80002008:	7179                	addi	sp,sp,-48
    8000200a:	f406                	sd	ra,40(sp)
    8000200c:	f022                	sd	s0,32(sp)
    8000200e:	ec26                	sd	s1,24(sp)
    80002010:	e84a                	sd	s2,16(sp)
    80002012:	e44e                	sd	s3,8(sp)
    80002014:	e052                	sd	s4,0(sp)
    80002016:	1800                	addi	s0,sp,48
    80002018:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000201a:	8ebff0ef          	jal	80001904 <myproc>
    8000201e:	89aa                	mv	s3,a0
  if(p == initproc)
    80002020:	00006797          	auipc	a5,0x6
    80002024:	8407b783          	ld	a5,-1984(a5) # 80007860 <initproc>
    80002028:	0d050493          	addi	s1,a0,208
    8000202c:	15050913          	addi	s2,a0,336
    80002030:	00a79b63          	bne	a5,a0,80002046 <kexit+0x3e>
    panic("init exiting");
    80002034:	00005517          	auipc	a0,0x5
    80002038:	1ac50513          	addi	a0,a0,428 # 800071e0 <etext+0x1e0>
    8000203c:	ffcfe0ef          	jal	80000838 <panic>
  for(int fd = 0; fd < NOFILE; fd++){
    80002040:	04a1                	addi	s1,s1,8
    80002042:	01248963          	beq	s1,s2,80002054 <kexit+0x4c>
    if(p->ofile[fd]){
    80002046:	6088                	ld	a0,0(s1)
    80002048:	dd65                	beqz	a0,80002040 <kexit+0x38>
      fileclose(f);
    8000204a:	7cd010ef          	jal	80004016 <fileclose>
      p->ofile[fd] = 0;
    8000204e:	0004b023          	sd	zero,0(s1)
    80002052:	b7fd                	j	80002040 <kexit+0x38>
  begin_op();
    80002054:	3a3010ef          	jal	80003bf6 <begin_op>
  iput(p->cwd);
    80002058:	1509b503          	ld	a0,336(s3)
    8000205c:	306010ef          	jal	80003362 <iput>
  end_op();
    80002060:	407010ef          	jal	80003c66 <end_op>
  p->cwd = 0;
    80002064:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002068:	0000e517          	auipc	a0,0xe
    8000206c:	91850513          	addi	a0,a0,-1768 # 8000f980 <wait_lock>
    80002070:	bc9fe0ef          	jal	80000c38 <acquire>
  reparent(p);
    80002074:	854e                	mv	a0,s3
    80002076:	f3dff0ef          	jal	80001fb2 <reparent>
  wakeup(p->parent);
    8000207a:	0389b503          	ld	a0,56(s3)
    8000207e:	ecbff0ef          	jal	80001f48 <wakeup>
  acquire(&p->lock);
    80002082:	854e                	mv	a0,s3
    80002084:	bb5fe0ef          	jal	80000c38 <acquire>
  p->xstate = status;
    80002088:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000208c:	4795                	li	a5,5
    8000208e:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002092:	0000e517          	auipc	a0,0xe
    80002096:	8ee50513          	addi	a0,a0,-1810 # 8000f980 <wait_lock>
    8000209a:	c2ffe0ef          	jal	80000cc8 <release>
  sched();
    8000209e:	d79ff0ef          	jal	80001e16 <sched>
  panic("zombie exit");
    800020a2:	00005517          	auipc	a0,0x5
    800020a6:	14e50513          	addi	a0,a0,334 # 800071f0 <etext+0x1f0>
    800020aa:	f8efe0ef          	jal	80000838 <panic>

00000000800020ae <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    800020ae:	7179                	addi	sp,sp,-48
    800020b0:	f406                	sd	ra,40(sp)
    800020b2:	f022                	sd	s0,32(sp)
    800020b4:	ec26                	sd	s1,24(sp)
    800020b6:	e84a                	sd	s2,16(sp)
    800020b8:	e44e                	sd	s3,8(sp)
    800020ba:	1800                	addi	s0,sp,48
    800020bc:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800020be:	0000e497          	auipc	s1,0xe
    800020c2:	cda48493          	addi	s1,s1,-806 # 8000fd98 <proc>
    800020c6:	00013997          	auipc	s3,0x13
    800020ca:	6d298993          	addi	s3,s3,1746 # 80015798 <tickslock>
    acquire(&p->lock);
    800020ce:	8526                	mv	a0,s1
    800020d0:	b69fe0ef          	jal	80000c38 <acquire>
    if(p->pid == pid){
    800020d4:	589c                	lw	a5,48(s1)
    800020d6:	01278b63          	beq	a5,s2,800020ec <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800020da:	8526                	mv	a0,s1
    800020dc:	bedfe0ef          	jal	80000cc8 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800020e0:	16848493          	addi	s1,s1,360
    800020e4:	ff3495e3          	bne	s1,s3,800020ce <kkill+0x20>
  }
  return -1;
    800020e8:	557d                	li	a0,-1
    800020ea:	a819                	j	80002100 <kkill+0x52>
      p->killed = 1;
    800020ec:	4785                	li	a5,1
    800020ee:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800020f0:	4c98                	lw	a4,24(s1)
    800020f2:	4789                	li	a5,2
    800020f4:	00f70d63          	beq	a4,a5,8000210e <kkill+0x60>
      release(&p->lock);
    800020f8:	8526                	mv	a0,s1
    800020fa:	bcffe0ef          	jal	80000cc8 <release>
      return 0;
    800020fe:	4501                	li	a0,0
}
    80002100:	70a2                	ld	ra,40(sp)
    80002102:	7402                	ld	s0,32(sp)
    80002104:	64e2                	ld	s1,24(sp)
    80002106:	6942                	ld	s2,16(sp)
    80002108:	69a2                	ld	s3,8(sp)
    8000210a:	6145                	addi	sp,sp,48
    8000210c:	8082                	ret
        p->state = RUNNABLE;
    8000210e:	478d                	li	a5,3
    80002110:	cc9c                	sw	a5,24(s1)
    80002112:	b7dd                	j	800020f8 <kkill+0x4a>

0000000080002114 <setkilled>:

void
setkilled(struct proc *p)
{
    80002114:	1101                	addi	sp,sp,-32
    80002116:	ec06                	sd	ra,24(sp)
    80002118:	e822                	sd	s0,16(sp)
    8000211a:	e426                	sd	s1,8(sp)
    8000211c:	1000                	addi	s0,sp,32
    8000211e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002120:	b19fe0ef          	jal	80000c38 <acquire>
  p->killed = 1;
    80002124:	4785                	li	a5,1
    80002126:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002128:	8526                	mv	a0,s1
    8000212a:	b9ffe0ef          	jal	80000cc8 <release>
}
    8000212e:	60e2                	ld	ra,24(sp)
    80002130:	6442                	ld	s0,16(sp)
    80002132:	64a2                	ld	s1,8(sp)
    80002134:	6105                	addi	sp,sp,32
    80002136:	8082                	ret

0000000080002138 <killed>:

int
killed(struct proc *p)
{
    80002138:	1101                	addi	sp,sp,-32
    8000213a:	ec06                	sd	ra,24(sp)
    8000213c:	e822                	sd	s0,16(sp)
    8000213e:	e426                	sd	s1,8(sp)
    80002140:	e04a                	sd	s2,0(sp)
    80002142:	1000                	addi	s0,sp,32
    80002144:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002146:	af3fe0ef          	jal	80000c38 <acquire>
  k = p->killed;
    8000214a:	549c                	lw	a5,40(s1)
    8000214c:	893e                	mv	s2,a5
  release(&p->lock);
    8000214e:	8526                	mv	a0,s1
    80002150:	b79fe0ef          	jal	80000cc8 <release>
  return k;
}
    80002154:	854a                	mv	a0,s2
    80002156:	60e2                	ld	ra,24(sp)
    80002158:	6442                	ld	s0,16(sp)
    8000215a:	64a2                	ld	s1,8(sp)
    8000215c:	6902                	ld	s2,0(sp)
    8000215e:	6105                	addi	sp,sp,32
    80002160:	8082                	ret

0000000080002162 <kwait>:
{
    80002162:	715d                	addi	sp,sp,-80
    80002164:	e486                	sd	ra,72(sp)
    80002166:	e0a2                	sd	s0,64(sp)
    80002168:	fc26                	sd	s1,56(sp)
    8000216a:	f84a                	sd	s2,48(sp)
    8000216c:	f44e                	sd	s3,40(sp)
    8000216e:	f052                	sd	s4,32(sp)
    80002170:	ec56                	sd	s5,24(sp)
    80002172:	e85a                	sd	s6,16(sp)
    80002174:	e45e                	sd	s7,8(sp)
    80002176:	0880                	addi	s0,sp,80
    80002178:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    8000217a:	f8aff0ef          	jal	80001904 <myproc>
    8000217e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002180:	0000e517          	auipc	a0,0xe
    80002184:	80050513          	addi	a0,a0,-2048 # 8000f980 <wait_lock>
    80002188:	ab1fe0ef          	jal	80000c38 <acquire>
        if(pp->state == ZOMBIE){
    8000218c:	4a15                	li	s4,5
        havekids = 1;
    8000218e:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002190:	00013997          	auipc	s3,0x13
    80002194:	60898993          	addi	s3,s3,1544 # 80015798 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002198:	0000db17          	auipc	s6,0xd
    8000219c:	7e8b0b13          	addi	s6,s6,2024 # 8000f980 <wait_lock>
    800021a0:	a861                	j	80002238 <kwait+0xd6>
          pid = pp->pid;
    800021a2:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800021a6:	000b8c63          	beqz	s7,800021be <kwait+0x5c>
    800021aa:	4691                	li	a3,4
    800021ac:	02c48613          	addi	a2,s1,44
    800021b0:	85de                	mv	a1,s7
    800021b2:	05093503          	ld	a0,80(s2)
    800021b6:	c86ff0ef          	jal	8000163c <copyout>
    800021ba:	02054a63          	bltz	a0,800021ee <kwait+0x8c>
          freeproc(pp);
    800021be:	8526                	mv	a0,s1
    800021c0:	917ff0ef          	jal	80001ad6 <freeproc>
          release(&pp->lock);
    800021c4:	8526                	mv	a0,s1
    800021c6:	b03fe0ef          	jal	80000cc8 <release>
          release(&wait_lock);
    800021ca:	0000d517          	auipc	a0,0xd
    800021ce:	7b650513          	addi	a0,a0,1974 # 8000f980 <wait_lock>
    800021d2:	af7fe0ef          	jal	80000cc8 <release>
}
    800021d6:	854e                	mv	a0,s3
    800021d8:	60a6                	ld	ra,72(sp)
    800021da:	6406                	ld	s0,64(sp)
    800021dc:	74e2                	ld	s1,56(sp)
    800021de:	7942                	ld	s2,48(sp)
    800021e0:	79a2                	ld	s3,40(sp)
    800021e2:	7a02                	ld	s4,32(sp)
    800021e4:	6ae2                	ld	s5,24(sp)
    800021e6:	6b42                	ld	s6,16(sp)
    800021e8:	6ba2                	ld	s7,8(sp)
    800021ea:	6161                	addi	sp,sp,80
    800021ec:	8082                	ret
            release(&pp->lock);
    800021ee:	8526                	mv	a0,s1
    800021f0:	ad9fe0ef          	jal	80000cc8 <release>
            release(&wait_lock);
    800021f4:	0000d517          	auipc	a0,0xd
    800021f8:	78c50513          	addi	a0,a0,1932 # 8000f980 <wait_lock>
    800021fc:	acdfe0ef          	jal	80000cc8 <release>
            return -1;
    80002200:	a881                	j	80002250 <kwait+0xee>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002202:	16848493          	addi	s1,s1,360
    80002206:	03348063          	beq	s1,s3,80002226 <kwait+0xc4>
      if(pp->parent == p){
    8000220a:	7c9c                	ld	a5,56(s1)
    8000220c:	ff279be3          	bne	a5,s2,80002202 <kwait+0xa0>
        acquire(&pp->lock);
    80002210:	8526                	mv	a0,s1
    80002212:	a27fe0ef          	jal	80000c38 <acquire>
        if(pp->state == ZOMBIE){
    80002216:	4c9c                	lw	a5,24(s1)
    80002218:	f94785e3          	beq	a5,s4,800021a2 <kwait+0x40>
        release(&pp->lock);
    8000221c:	8526                	mv	a0,s1
    8000221e:	aabfe0ef          	jal	80000cc8 <release>
        havekids = 1;
    80002222:	8756                	mv	a4,s5
    80002224:	bff9                	j	80002202 <kwait+0xa0>
    if(!havekids || killed(p)){
    80002226:	cf19                	beqz	a4,80002244 <kwait+0xe2>
    80002228:	854a                	mv	a0,s2
    8000222a:	f0fff0ef          	jal	80002138 <killed>
    8000222e:	e919                	bnez	a0,80002244 <kwait+0xe2>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002230:	85da                	mv	a1,s6
    80002232:	854a                	mv	a0,s2
    80002234:	cc9ff0ef          	jal	80001efc <sleep>
    havekids = 0;
    80002238:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000223a:	0000e497          	auipc	s1,0xe
    8000223e:	b5e48493          	addi	s1,s1,-1186 # 8000fd98 <proc>
    80002242:	b7e1                	j	8000220a <kwait+0xa8>
      release(&wait_lock);
    80002244:	0000d517          	auipc	a0,0xd
    80002248:	73c50513          	addi	a0,a0,1852 # 8000f980 <wait_lock>
    8000224c:	a7dfe0ef          	jal	80000cc8 <release>
            return -1;
    80002250:	59fd                	li	s3,-1
    80002252:	b751                	j	800021d6 <kwait+0x74>

0000000080002254 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002254:	7179                	addi	sp,sp,-48
    80002256:	f406                	sd	ra,40(sp)
    80002258:	f022                	sd	s0,32(sp)
    8000225a:	ec26                	sd	s1,24(sp)
    8000225c:	e84a                	sd	s2,16(sp)
    8000225e:	e44e                	sd	s3,8(sp)
    80002260:	e052                	sd	s4,0(sp)
    80002262:	1800                	addi	s0,sp,48
    80002264:	84aa                	mv	s1,a0
    80002266:	8a2e                	mv	s4,a1
    80002268:	89b2                	mv	s3,a2
    8000226a:	8936                	mv	s2,a3
  struct proc *p = myproc();
    8000226c:	e98ff0ef          	jal	80001904 <myproc>
  if(user_dst){
    80002270:	cc99                	beqz	s1,8000228e <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002272:	86ca                	mv	a3,s2
    80002274:	864e                	mv	a2,s3
    80002276:	85d2                	mv	a1,s4
    80002278:	6928                	ld	a0,80(a0)
    8000227a:	bc2ff0ef          	jal	8000163c <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000227e:	70a2                	ld	ra,40(sp)
    80002280:	7402                	ld	s0,32(sp)
    80002282:	64e2                	ld	s1,24(sp)
    80002284:	6942                	ld	s2,16(sp)
    80002286:	69a2                	ld	s3,8(sp)
    80002288:	6a02                	ld	s4,0(sp)
    8000228a:	6145                	addi	sp,sp,48
    8000228c:	8082                	ret
    memmove((char *)dst, src, len);
    8000228e:	0009061b          	sext.w	a2,s2
    80002292:	85ce                	mv	a1,s3
    80002294:	8552                	mv	a0,s4
    80002296:	acbfe0ef          	jal	80000d60 <memmove>
    return 0;
    8000229a:	8526                	mv	a0,s1
    8000229c:	b7cd                	j	8000227e <either_copyout+0x2a>

000000008000229e <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000229e:	7179                	addi	sp,sp,-48
    800022a0:	f406                	sd	ra,40(sp)
    800022a2:	f022                	sd	s0,32(sp)
    800022a4:	ec26                	sd	s1,24(sp)
    800022a6:	e84a                	sd	s2,16(sp)
    800022a8:	e44e                	sd	s3,8(sp)
    800022aa:	e052                	sd	s4,0(sp)
    800022ac:	1800                	addi	s0,sp,48
    800022ae:	8a2a                	mv	s4,a0
    800022b0:	84ae                	mv	s1,a1
    800022b2:	89b2                	mv	s3,a2
    800022b4:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800022b6:	e4eff0ef          	jal	80001904 <myproc>
  if(user_src){
    800022ba:	cc99                	beqz	s1,800022d8 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800022bc:	86ca                	mv	a3,s2
    800022be:	864e                	mv	a2,s3
    800022c0:	85d2                	mv	a1,s4
    800022c2:	6928                	ld	a0,80(a0)
    800022c4:	c30ff0ef          	jal	800016f4 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800022c8:	70a2                	ld	ra,40(sp)
    800022ca:	7402                	ld	s0,32(sp)
    800022cc:	64e2                	ld	s1,24(sp)
    800022ce:	6942                	ld	s2,16(sp)
    800022d0:	69a2                	ld	s3,8(sp)
    800022d2:	6a02                	ld	s4,0(sp)
    800022d4:	6145                	addi	sp,sp,48
    800022d6:	8082                	ret
    memmove(dst, (char*)src, len);
    800022d8:	0009061b          	sext.w	a2,s2
    800022dc:	85ce                	mv	a1,s3
    800022de:	8552                	mv	a0,s4
    800022e0:	a81fe0ef          	jal	80000d60 <memmove>
    return 0;
    800022e4:	8526                	mv	a0,s1
    800022e6:	b7cd                	j	800022c8 <either_copyin+0x2a>

00000000800022e8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800022e8:	715d                	addi	sp,sp,-80
    800022ea:	e486                	sd	ra,72(sp)
    800022ec:	e0a2                	sd	s0,64(sp)
    800022ee:	fc26                	sd	s1,56(sp)
    800022f0:	f84a                	sd	s2,48(sp)
    800022f2:	f44e                	sd	s3,40(sp)
    800022f4:	f052                	sd	s4,32(sp)
    800022f6:	ec56                	sd	s5,24(sp)
    800022f8:	e85a                	sd	s6,16(sp)
    800022fa:	e45e                	sd	s7,8(sp)
    800022fc:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800022fe:	00005517          	auipc	a0,0x5
    80002302:	d7a50513          	addi	a0,a0,-646 # 80007078 <etext+0x78>
    80002306:	9fafe0ef          	jal	80000500 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000230a:	0000e497          	auipc	s1,0xe
    8000230e:	be648493          	addi	s1,s1,-1050 # 8000fef0 <proc+0x158>
    80002312:	00013917          	auipc	s2,0x13
    80002316:	5de90913          	addi	s2,s2,1502 # 800158f0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000231a:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000231c:	00005a97          	auipc	s5,0x5
    80002320:	ee4a8a93          	addi	s5,s5,-284 # 80007200 <etext+0x200>
    printf("%d %s %s", p->pid, state, p->name);
    80002324:	00005a17          	auipc	s4,0x5
    80002328:	ee4a0a13          	addi	s4,s4,-284 # 80007208 <etext+0x208>
    printf("\n");
    8000232c:	00005997          	auipc	s3,0x5
    80002330:	d4c98993          	addi	s3,s3,-692 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002334:	00005b97          	auipc	s7,0x5
    80002338:	3f4b8b93          	addi	s7,s7,1012 # 80007728 <states.0>
    8000233c:	a829                	j	80002356 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    8000233e:	ed86a583          	lw	a1,-296(a3)
    80002342:	8552                	mv	a0,s4
    80002344:	9bcfe0ef          	jal	80000500 <printf>
    printf("\n");
    80002348:	854e                	mv	a0,s3
    8000234a:	9b6fe0ef          	jal	80000500 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000234e:	16848493          	addi	s1,s1,360
    80002352:	03248063          	beq	s1,s2,80002372 <procdump+0x8a>
    if(p->state == UNUSED)
    80002356:	86a6                	mv	a3,s1
    80002358:	ec04a783          	lw	a5,-320(s1)
    8000235c:	dbed                	beqz	a5,8000234e <procdump+0x66>
      state = "???";
    8000235e:	8656                	mv	a2,s5
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002360:	fcfb6fe3          	bltu	s6,a5,8000233e <procdump+0x56>
    80002364:	02079713          	slli	a4,a5,0x20
    80002368:	01d75793          	srli	a5,a4,0x1d
    8000236c:	97de                	add	a5,a5,s7
    8000236e:	6390                	ld	a2,0(a5)
      state = states[p->state];
    80002370:	b7f9                	j	8000233e <procdump+0x56>
  }
}
    80002372:	60a6                	ld	ra,72(sp)
    80002374:	6406                	ld	s0,64(sp)
    80002376:	74e2                	ld	s1,56(sp)
    80002378:	7942                	ld	s2,48(sp)
    8000237a:	79a2                	ld	s3,40(sp)
    8000237c:	7a02                	ld	s4,32(sp)
    8000237e:	6ae2                	ld	s5,24(sp)
    80002380:	6b42                	ld	s6,16(sp)
    80002382:	6ba2                	ld	s7,8(sp)
    80002384:	6161                	addi	sp,sp,80
    80002386:	8082                	ret

0000000080002388 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002388:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    8000238c:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002390:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002392:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002394:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002398:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    8000239c:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800023a0:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800023a4:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800023a8:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800023ac:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800023b0:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800023b4:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800023b8:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800023bc:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800023c0:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800023c4:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800023c6:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800023c8:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800023cc:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800023d0:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800023d4:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800023d8:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800023dc:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800023e0:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800023e4:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800023e8:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800023ec:	0685bd83          	ld	s11,104(a1)
        
        ret
    800023f0:	8082                	ret

00000000800023f2 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800023f2:	1141                	addi	sp,sp,-16
    800023f4:	e406                	sd	ra,8(sp)
    800023f6:	e022                	sd	s0,0(sp)
    800023f8:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800023fa:	00005597          	auipc	a1,0x5
    800023fe:	e4e58593          	addi	a1,a1,-434 # 80007248 <etext+0x248>
    80002402:	00013517          	auipc	a0,0x13
    80002406:	39650513          	addi	a0,a0,918 # 80015798 <tickslock>
    8000240a:	fa4fe0ef          	jal	80000bae <initlock>
}
    8000240e:	60a2                	ld	ra,8(sp)
    80002410:	6402                	ld	s0,0(sp)
    80002412:	0141                	addi	sp,sp,16
    80002414:	8082                	ret

0000000080002416 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002416:	1141                	addi	sp,sp,-16
    80002418:	e406                	sd	ra,8(sp)
    8000241a:	e022                	sd	s0,0(sp)
    8000241c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000241e:	00003797          	auipc	a5,0x3
    80002422:	f3278793          	addi	a5,a5,-206 # 80005350 <kernelvec>
    80002426:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000242a:	60a2                	ld	ra,8(sp)
    8000242c:	6402                	ld	s0,0(sp)
    8000242e:	0141                	addi	sp,sp,16
    80002430:	8082                	ret

0000000080002432 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002432:	1141                	addi	sp,sp,-16
    80002434:	e406                	sd	ra,8(sp)
    80002436:	e022                	sd	s0,0(sp)
    80002438:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000243a:	ccaff0ef          	jal	80001904 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000243e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002442:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002444:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002448:	04000737          	lui	a4,0x4000
    8000244c:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    8000244e:	0732                	slli	a4,a4,0xc
    80002450:	00004797          	auipc	a5,0x4
    80002454:	bb078793          	addi	a5,a5,-1104 # 80006000 <_trampoline>
    80002458:	00004697          	auipc	a3,0x4
    8000245c:	ba868693          	addi	a3,a3,-1112 # 80006000 <_trampoline>
    80002460:	8f95                	sub	a5,a5,a3
    80002462:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002464:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002468:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000246a:	18002773          	csrr	a4,satp
    8000246e:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002470:	6d38                	ld	a4,88(a0)
    80002472:	613c                	ld	a5,64(a0)
    80002474:	6685                	lui	a3,0x1
    80002476:	97b6                	add	a5,a5,a3
    80002478:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000247a:	6d3c                	ld	a5,88(a0)
    8000247c:	00000717          	auipc	a4,0x0
    80002480:	0f470713          	addi	a4,a4,244 # 80002570 <usertrap>
    80002484:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002486:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002488:	8712                	mv	a4,tp
    8000248a:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000248c:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002490:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002494:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002498:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000249c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000249e:	6f9c                	ld	a5,24(a5)
    800024a0:	14179073          	csrw	sepc,a5
}
    800024a4:	60a2                	ld	ra,8(sp)
    800024a6:	6402                	ld	s0,0(sp)
    800024a8:	0141                	addi	sp,sp,16
    800024aa:	8082                	ret

00000000800024ac <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800024ac:	1141                	addi	sp,sp,-16
    800024ae:	e406                	sd	ra,8(sp)
    800024b0:	e022                	sd	s0,0(sp)
    800024b2:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    800024b4:	c1cff0ef          	jal	800018d0 <cpuid>
    800024b8:	cd11                	beqz	a0,800024d4 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    800024ba:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800024be:	000f4737          	lui	a4,0xf4
    800024c2:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800024c6:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800024c8:	14d79073          	csrw	stimecmp,a5
}
    800024cc:	60a2                	ld	ra,8(sp)
    800024ce:	6402                	ld	s0,0(sp)
    800024d0:	0141                	addi	sp,sp,16
    800024d2:	8082                	ret
    acquire(&tickslock);
    800024d4:	00013517          	auipc	a0,0x13
    800024d8:	2c450513          	addi	a0,a0,708 # 80015798 <tickslock>
    800024dc:	f5cfe0ef          	jal	80000c38 <acquire>
    ticks++;
    800024e0:	00005717          	auipc	a4,0x5
    800024e4:	38870713          	addi	a4,a4,904 # 80007868 <ticks>
    800024e8:	431c                	lw	a5,0(a4)
    800024ea:	2785                	addiw	a5,a5,1
    800024ec:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    800024ee:	853a                	mv	a0,a4
    800024f0:	a59ff0ef          	jal	80001f48 <wakeup>
    release(&tickslock);
    800024f4:	00013517          	auipc	a0,0x13
    800024f8:	2a450513          	addi	a0,a0,676 # 80015798 <tickslock>
    800024fc:	fccfe0ef          	jal	80000cc8 <release>
    80002500:	bf6d                	j	800024ba <clockintr+0xe>

0000000080002502 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002502:	1101                	addi	sp,sp,-32
    80002504:	ec06                	sd	ra,24(sp)
    80002506:	e822                	sd	s0,16(sp)
    80002508:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000250a:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    8000250e:	57fd                	li	a5,-1
    80002510:	17fe                	slli	a5,a5,0x3f
    80002512:	07a5                	addi	a5,a5,9
    80002514:	00f70c63          	beq	a4,a5,8000252c <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002518:	57fd                	li	a5,-1
    8000251a:	17fe                	slli	a5,a5,0x3f
    8000251c:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    8000251e:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002520:	04f70463          	beq	a4,a5,80002568 <devintr+0x66>
  }
}
    80002524:	60e2                	ld	ra,24(sp)
    80002526:	6442                	ld	s0,16(sp)
    80002528:	6105                	addi	sp,sp,32
    8000252a:	8082                	ret
    8000252c:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    8000252e:	6cf020ef          	jal	800053fc <plic_claim>
    80002532:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002534:	47a9                	li	a5,10
    80002536:	02f50363          	beq	a0,a5,8000255c <devintr+0x5a>
    } else if(irq == VIRTIO0_IRQ){
    8000253a:	4785                	li	a5,1
    8000253c:	02f50363          	beq	a0,a5,80002562 <devintr+0x60>
    } else if(irq){
    80002540:	c919                	beqz	a0,80002556 <devintr+0x54>
      printf("unexpected interrupt irq=%d\n", irq);
    80002542:	85aa                	mv	a1,a0
    80002544:	00005517          	auipc	a0,0x5
    80002548:	d0c50513          	addi	a0,a0,-756 # 80007250 <etext+0x250>
    8000254c:	fb5fd0ef          	jal	80000500 <printf>
      plic_complete(irq);
    80002550:	8526                	mv	a0,s1
    80002552:	6cb020ef          	jal	8000541c <plic_complete>
    return 1;
    80002556:	4505                	li	a0,1
    80002558:	64a2                	ld	s1,8(sp)
    8000255a:	b7e9                	j	80002524 <devintr+0x22>
      uartintr();
    8000255c:	ca8fe0ef          	jal	80000a04 <uartintr>
    if(irq)
    80002560:	bfc5                	j	80002550 <devintr+0x4e>
      virtio_disk_intr();
    80002562:	31e030ef          	jal	80005880 <virtio_disk_intr>
    if(irq)
    80002566:	b7ed                	j	80002550 <devintr+0x4e>
    clockintr();
    80002568:	f45ff0ef          	jal	800024ac <clockintr>
    return 2;
    8000256c:	4509                	li	a0,2
    8000256e:	bf5d                	j	80002524 <devintr+0x22>

0000000080002570 <usertrap>:
{
    80002570:	1101                	addi	sp,sp,-32
    80002572:	ec06                	sd	ra,24(sp)
    80002574:	e822                	sd	s0,16(sp)
    80002576:	e426                	sd	s1,8(sp)
    80002578:	e04a                	sd	s2,0(sp)
    8000257a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000257c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002580:	1007f793          	andi	a5,a5,256
    80002584:	eba5                	bnez	a5,800025f4 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002586:	00003797          	auipc	a5,0x3
    8000258a:	dca78793          	addi	a5,a5,-566 # 80005350 <kernelvec>
    8000258e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002592:	b72ff0ef          	jal	80001904 <myproc>
    80002596:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002598:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000259a:	14102773          	csrr	a4,sepc
    8000259e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800025a0:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800025a4:	47a1                	li	a5,8
    800025a6:	04f70d63          	beq	a4,a5,80002600 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    800025aa:	f59ff0ef          	jal	80002502 <devintr>
    800025ae:	892a                	mv	s2,a0
    800025b0:	e945                	bnez	a0,80002660 <usertrap+0xf0>
    800025b2:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    800025b6:	47bd                	li	a5,15
    800025b8:	08f70863          	beq	a4,a5,80002648 <usertrap+0xd8>
    800025bc:	14202773          	csrr	a4,scause
    800025c0:	47b5                	li	a5,13
    800025c2:	08f70363          	beq	a4,a5,80002648 <usertrap+0xd8>
    800025c6:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800025ca:	5890                	lw	a2,48(s1)
    800025cc:	00005517          	auipc	a0,0x5
    800025d0:	cc450513          	addi	a0,a0,-828 # 80007290 <etext+0x290>
    800025d4:	f2dfd0ef          	jal	80000500 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800025d8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800025dc:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800025e0:	00005517          	auipc	a0,0x5
    800025e4:	ce050513          	addi	a0,a0,-800 # 800072c0 <etext+0x2c0>
    800025e8:	f19fd0ef          	jal	80000500 <printf>
    setkilled(p);
    800025ec:	8526                	mv	a0,s1
    800025ee:	b27ff0ef          	jal	80002114 <setkilled>
    800025f2:	a035                	j	8000261e <usertrap+0xae>
    panic("usertrap: not from user mode");
    800025f4:	00005517          	auipc	a0,0x5
    800025f8:	c7c50513          	addi	a0,a0,-900 # 80007270 <etext+0x270>
    800025fc:	a3cfe0ef          	jal	80000838 <panic>
    if(killed(p))
    80002600:	b39ff0ef          	jal	80002138 <killed>
    80002604:	ed15                	bnez	a0,80002640 <usertrap+0xd0>
    p->trapframe->epc += 4;
    80002606:	6cb8                	ld	a4,88(s1)
    80002608:	6f1c                	ld	a5,24(a4)
    8000260a:	0791                	addi	a5,a5,4
    8000260c:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000260e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002612:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002616:	10079073          	csrw	sstatus,a5
    syscall();
    8000261a:	23c000ef          	jal	80002856 <syscall>
  if(killed(p))
    8000261e:	8526                	mv	a0,s1
    80002620:	b19ff0ef          	jal	80002138 <killed>
    80002624:	e139                	bnez	a0,8000266a <usertrap+0xfa>
  prepare_return();
    80002626:	e0dff0ef          	jal	80002432 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000262a:	68a8                	ld	a0,80(s1)
    8000262c:	8131                	srli	a0,a0,0xc
    8000262e:	57fd                	li	a5,-1
    80002630:	17fe                	slli	a5,a5,0x3f
    80002632:	8d5d                	or	a0,a0,a5
}
    80002634:	60e2                	ld	ra,24(sp)
    80002636:	6442                	ld	s0,16(sp)
    80002638:	64a2                	ld	s1,8(sp)
    8000263a:	6902                	ld	s2,0(sp)
    8000263c:	6105                	addi	sp,sp,32
    8000263e:	8082                	ret
      kexit(-1);
    80002640:	557d                	li	a0,-1
    80002642:	9c7ff0ef          	jal	80002008 <kexit>
    80002646:	b7c1                	j	80002606 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002648:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000264c:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80002650:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    80002652:	00163613          	seqz	a2,a2
    80002656:	68a8                	ld	a0,80(s1)
    80002658:	f65fe0ef          	jal	800015bc <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    8000265c:	f169                	bnez	a0,8000261e <usertrap+0xae>
    8000265e:	b7a5                	j	800025c6 <usertrap+0x56>
  if(killed(p))
    80002660:	8526                	mv	a0,s1
    80002662:	ad7ff0ef          	jal	80002138 <killed>
    80002666:	c511                	beqz	a0,80002672 <usertrap+0x102>
    80002668:	a011                	j	8000266c <usertrap+0xfc>
    8000266a:	4901                	li	s2,0
    kexit(-1);
    8000266c:	557d                	li	a0,-1
    8000266e:	99bff0ef          	jal	80002008 <kexit>
  if(which_dev == 2)
    80002672:	4789                	li	a5,2
    80002674:	faf919e3          	bne	s2,a5,80002626 <usertrap+0xb6>
    yield();
    80002678:	859ff0ef          	jal	80001ed0 <yield>
    8000267c:	b76d                	j	80002626 <usertrap+0xb6>

000000008000267e <kerneltrap>:
{
    8000267e:	7179                	addi	sp,sp,-48
    80002680:	f406                	sd	ra,40(sp)
    80002682:	f022                	sd	s0,32(sp)
    80002684:	ec26                	sd	s1,24(sp)
    80002686:	e84a                	sd	s2,16(sp)
    80002688:	e44e                	sd	s3,8(sp)
    8000268a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000268c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002690:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002694:	142027f3          	csrr	a5,scause
    80002698:	89be                	mv	s3,a5
  if((sstatus & SSTATUS_SPP) == 0)
    8000269a:	1004f793          	andi	a5,s1,256
    8000269e:	c795                	beqz	a5,800026ca <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026a0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800026a4:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800026a6:	eb85                	bnez	a5,800026d6 <kerneltrap+0x58>
  if((which_dev = devintr()) == 0){
    800026a8:	e5bff0ef          	jal	80002502 <devintr>
    800026ac:	c91d                	beqz	a0,800026e2 <kerneltrap+0x64>
  if(which_dev == 2 && myproc() != 0)
    800026ae:	4789                	li	a5,2
    800026b0:	04f50a63          	beq	a0,a5,80002704 <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026b4:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026b8:	10049073          	csrw	sstatus,s1
}
    800026bc:	70a2                	ld	ra,40(sp)
    800026be:	7402                	ld	s0,32(sp)
    800026c0:	64e2                	ld	s1,24(sp)
    800026c2:	6942                	ld	s2,16(sp)
    800026c4:	69a2                	ld	s3,8(sp)
    800026c6:	6145                	addi	sp,sp,48
    800026c8:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800026ca:	00005517          	auipc	a0,0x5
    800026ce:	c1e50513          	addi	a0,a0,-994 # 800072e8 <etext+0x2e8>
    800026d2:	966fe0ef          	jal	80000838 <panic>
    panic("kerneltrap: interrupts enabled");
    800026d6:	00005517          	auipc	a0,0x5
    800026da:	c3a50513          	addi	a0,a0,-966 # 80007310 <etext+0x310>
    800026de:	95afe0ef          	jal	80000838 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026e2:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800026e6:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800026ea:	85ce                	mv	a1,s3
    800026ec:	00005517          	auipc	a0,0x5
    800026f0:	c4450513          	addi	a0,a0,-956 # 80007330 <etext+0x330>
    800026f4:	e0dfd0ef          	jal	80000500 <printf>
    panic("kerneltrap");
    800026f8:	00005517          	auipc	a0,0x5
    800026fc:	c6050513          	addi	a0,a0,-928 # 80007358 <etext+0x358>
    80002700:	938fe0ef          	jal	80000838 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002704:	a00ff0ef          	jal	80001904 <myproc>
    80002708:	d555                	beqz	a0,800026b4 <kerneltrap+0x36>
    yield();
    8000270a:	fc6ff0ef          	jal	80001ed0 <yield>
    8000270e:	b75d                	j	800026b4 <kerneltrap+0x36>

0000000080002710 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002710:	1101                	addi	sp,sp,-32
    80002712:	ec06                	sd	ra,24(sp)
    80002714:	e822                	sd	s0,16(sp)
    80002716:	e426                	sd	s1,8(sp)
    80002718:	1000                	addi	s0,sp,32
    8000271a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000271c:	9e8ff0ef          	jal	80001904 <myproc>
  switch (n) {
    80002720:	4795                	li	a5,5
    80002722:	0497e163          	bltu	a5,s1,80002764 <argraw+0x54>
    80002726:	048a                	slli	s1,s1,0x2
    80002728:	00005717          	auipc	a4,0x5
    8000272c:	03070713          	addi	a4,a4,48 # 80007758 <states.0+0x30>
    80002730:	94ba                	add	s1,s1,a4
    80002732:	409c                	lw	a5,0(s1)
    80002734:	97ba                	add	a5,a5,a4
    80002736:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002738:	6d3c                	ld	a5,88(a0)
    8000273a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000273c:	60e2                	ld	ra,24(sp)
    8000273e:	6442                	ld	s0,16(sp)
    80002740:	64a2                	ld	s1,8(sp)
    80002742:	6105                	addi	sp,sp,32
    80002744:	8082                	ret
    return p->trapframe->a1;
    80002746:	6d3c                	ld	a5,88(a0)
    80002748:	7fa8                	ld	a0,120(a5)
    8000274a:	bfcd                	j	8000273c <argraw+0x2c>
    return p->trapframe->a2;
    8000274c:	6d3c                	ld	a5,88(a0)
    8000274e:	63c8                	ld	a0,128(a5)
    80002750:	b7f5                	j	8000273c <argraw+0x2c>
    return p->trapframe->a3;
    80002752:	6d3c                	ld	a5,88(a0)
    80002754:	67c8                	ld	a0,136(a5)
    80002756:	b7dd                	j	8000273c <argraw+0x2c>
    return p->trapframe->a4;
    80002758:	6d3c                	ld	a5,88(a0)
    8000275a:	6bc8                	ld	a0,144(a5)
    8000275c:	b7c5                	j	8000273c <argraw+0x2c>
    return p->trapframe->a5;
    8000275e:	6d3c                	ld	a5,88(a0)
    80002760:	6fc8                	ld	a0,152(a5)
    80002762:	bfe9                	j	8000273c <argraw+0x2c>
  panic("argraw");
    80002764:	00005517          	auipc	a0,0x5
    80002768:	c0450513          	addi	a0,a0,-1020 # 80007368 <etext+0x368>
    8000276c:	8ccfe0ef          	jal	80000838 <panic>

0000000080002770 <fetchaddr>:
{
    80002770:	1101                	addi	sp,sp,-32
    80002772:	ec06                	sd	ra,24(sp)
    80002774:	e822                	sd	s0,16(sp)
    80002776:	e426                	sd	s1,8(sp)
    80002778:	e04a                	sd	s2,0(sp)
    8000277a:	1000                	addi	s0,sp,32
    8000277c:	84aa                	mv	s1,a0
    8000277e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002780:	984ff0ef          	jal	80001904 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002784:	653c                	ld	a5,72(a0)
    80002786:	02f4f663          	bgeu	s1,a5,800027b2 <fetchaddr+0x42>
    8000278a:	00848713          	addi	a4,s1,8
    8000278e:	02e7e263          	bltu	a5,a4,800027b2 <fetchaddr+0x42>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002792:	46a1                	li	a3,8
    80002794:	8626                	mv	a2,s1
    80002796:	85ca                	mv	a1,s2
    80002798:	6928                	ld	a0,80(a0)
    8000279a:	f5bfe0ef          	jal	800016f4 <copyin>
    8000279e:	00a03533          	snez	a0,a0
    800027a2:	40a0053b          	negw	a0,a0
}
    800027a6:	60e2                	ld	ra,24(sp)
    800027a8:	6442                	ld	s0,16(sp)
    800027aa:	64a2                	ld	s1,8(sp)
    800027ac:	6902                	ld	s2,0(sp)
    800027ae:	6105                	addi	sp,sp,32
    800027b0:	8082                	ret
    return -1;
    800027b2:	557d                	li	a0,-1
    800027b4:	bfcd                	j	800027a6 <fetchaddr+0x36>

00000000800027b6 <fetchstr>:
{
    800027b6:	7179                	addi	sp,sp,-48
    800027b8:	f406                	sd	ra,40(sp)
    800027ba:	f022                	sd	s0,32(sp)
    800027bc:	ec26                	sd	s1,24(sp)
    800027be:	e84a                	sd	s2,16(sp)
    800027c0:	e44e                	sd	s3,8(sp)
    800027c2:	1800                	addi	s0,sp,48
    800027c4:	89aa                	mv	s3,a0
    800027c6:	84ae                	mv	s1,a1
    800027c8:	8932                	mv	s2,a2
  struct proc *p = myproc();
    800027ca:	93aff0ef          	jal	80001904 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800027ce:	86ca                	mv	a3,s2
    800027d0:	864e                	mv	a2,s3
    800027d2:	85a6                	mv	a1,s1
    800027d4:	6928                	ld	a0,80(a0)
    800027d6:	d0ffe0ef          	jal	800014e4 <copyinstr>
    800027da:	00054c63          	bltz	a0,800027f2 <fetchstr+0x3c>
  return strlen(buf);
    800027de:	8526                	mv	a0,s1
    800027e0:	ea4fe0ef          	jal	80000e84 <strlen>
}
    800027e4:	70a2                	ld	ra,40(sp)
    800027e6:	7402                	ld	s0,32(sp)
    800027e8:	64e2                	ld	s1,24(sp)
    800027ea:	6942                	ld	s2,16(sp)
    800027ec:	69a2                	ld	s3,8(sp)
    800027ee:	6145                	addi	sp,sp,48
    800027f0:	8082                	ret
    return -1;
    800027f2:	557d                	li	a0,-1
    800027f4:	bfc5                	j	800027e4 <fetchstr+0x2e>

00000000800027f6 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800027f6:	1101                	addi	sp,sp,-32
    800027f8:	ec06                	sd	ra,24(sp)
    800027fa:	e822                	sd	s0,16(sp)
    800027fc:	e426                	sd	s1,8(sp)
    800027fe:	1000                	addi	s0,sp,32
    80002800:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002802:	f0fff0ef          	jal	80002710 <argraw>
    80002806:	c088                	sw	a0,0(s1)
}
    80002808:	60e2                	ld	ra,24(sp)
    8000280a:	6442                	ld	s0,16(sp)
    8000280c:	64a2                	ld	s1,8(sp)
    8000280e:	6105                	addi	sp,sp,32
    80002810:	8082                	ret

0000000080002812 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002812:	1101                	addi	sp,sp,-32
    80002814:	ec06                	sd	ra,24(sp)
    80002816:	e822                	sd	s0,16(sp)
    80002818:	e426                	sd	s1,8(sp)
    8000281a:	1000                	addi	s0,sp,32
    8000281c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000281e:	ef3ff0ef          	jal	80002710 <argraw>
    80002822:	e088                	sd	a0,0(s1)
}
    80002824:	60e2                	ld	ra,24(sp)
    80002826:	6442                	ld	s0,16(sp)
    80002828:	64a2                	ld	s1,8(sp)
    8000282a:	6105                	addi	sp,sp,32
    8000282c:	8082                	ret

000000008000282e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000282e:	1101                	addi	sp,sp,-32
    80002830:	ec06                	sd	ra,24(sp)
    80002832:	e822                	sd	s0,16(sp)
    80002834:	e426                	sd	s1,8(sp)
    80002836:	e04a                	sd	s2,0(sp)
    80002838:	1000                	addi	s0,sp,32
    8000283a:	892e                	mv	s2,a1
    8000283c:	84b2                	mv	s1,a2
  *ip = argraw(n);
    8000283e:	ed3ff0ef          	jal	80002710 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002842:	8626                	mv	a2,s1
    80002844:	85ca                	mv	a1,s2
    80002846:	f71ff0ef          	jal	800027b6 <fetchstr>
}
    8000284a:	60e2                	ld	ra,24(sp)
    8000284c:	6442                	ld	s0,16(sp)
    8000284e:	64a2                	ld	s1,8(sp)
    80002850:	6902                	ld	s2,0(sp)
    80002852:	6105                	addi	sp,sp,32
    80002854:	8082                	ret

0000000080002856 <syscall>:
[SYS_hello] sys_hello,
};

void
syscall(void)
{
    80002856:	1101                	addi	sp,sp,-32
    80002858:	ec06                	sd	ra,24(sp)
    8000285a:	e822                	sd	s0,16(sp)
    8000285c:	e426                	sd	s1,8(sp)
    8000285e:	e04a                	sd	s2,0(sp)
    80002860:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002862:	8a2ff0ef          	jal	80001904 <myproc>
    80002866:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002868:	05853903          	ld	s2,88(a0)
    8000286c:	0a893783          	ld	a5,168(s2)
    80002870:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002874:	37fd                	addiw	a5,a5,-1
    80002876:	4755                	li	a4,21
    80002878:	00f76f63          	bltu	a4,a5,80002896 <syscall+0x40>
    8000287c:	00369713          	slli	a4,a3,0x3
    80002880:	00005797          	auipc	a5,0x5
    80002884:	ef078793          	addi	a5,a5,-272 # 80007770 <syscalls>
    80002888:	97ba                	add	a5,a5,a4
    8000288a:	639c                	ld	a5,0(a5)
    8000288c:	c789                	beqz	a5,80002896 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    8000288e:	9782                	jalr	a5
    80002890:	06a93823          	sd	a0,112(s2)
    80002894:	a829                	j	800028ae <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002896:	15848613          	addi	a2,s1,344
    8000289a:	588c                	lw	a1,48(s1)
    8000289c:	00005517          	auipc	a0,0x5
    800028a0:	ad450513          	addi	a0,a0,-1324 # 80007370 <etext+0x370>
    800028a4:	c5dfd0ef          	jal	80000500 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800028a8:	6cbc                	ld	a5,88(s1)
    800028aa:	577d                	li	a4,-1
    800028ac:	fbb8                	sd	a4,112(a5)
  }
}
    800028ae:	60e2                	ld	ra,24(sp)
    800028b0:	6442                	ld	s0,16(sp)
    800028b2:	64a2                	ld	s1,8(sp)
    800028b4:	6902                	ld	s2,0(sp)
    800028b6:	6105                	addi	sp,sp,32
    800028b8:	8082                	ret

00000000800028ba <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    800028ba:	1101                	addi	sp,sp,-32
    800028bc:	ec06                	sd	ra,24(sp)
    800028be:	e822                	sd	s0,16(sp)
    800028c0:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800028c2:	fec40593          	addi	a1,s0,-20
    800028c6:	4501                	li	a0,0
    800028c8:	f2fff0ef          	jal	800027f6 <argint>
  kexit(n);
    800028cc:	fec42503          	lw	a0,-20(s0)
    800028d0:	f38ff0ef          	jal	80002008 <kexit>
  return 0;  // not reached
}
    800028d4:	4501                	li	a0,0
    800028d6:	60e2                	ld	ra,24(sp)
    800028d8:	6442                	ld	s0,16(sp)
    800028da:	6105                	addi	sp,sp,32
    800028dc:	8082                	ret

00000000800028de <sys_getpid>:

uint64
sys_getpid(void)
{
    800028de:	1141                	addi	sp,sp,-16
    800028e0:	e406                	sd	ra,8(sp)
    800028e2:	e022                	sd	s0,0(sp)
    800028e4:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800028e6:	81eff0ef          	jal	80001904 <myproc>
}
    800028ea:	5908                	lw	a0,48(a0)
    800028ec:	60a2                	ld	ra,8(sp)
    800028ee:	6402                	ld	s0,0(sp)
    800028f0:	0141                	addi	sp,sp,16
    800028f2:	8082                	ret

00000000800028f4 <sys_fork>:

uint64
sys_fork(void)
{
    800028f4:	1141                	addi	sp,sp,-16
    800028f6:	e406                	sd	ra,8(sp)
    800028f8:	e022                	sd	s0,0(sp)
    800028fa:	0800                	addi	s0,sp,16
  return kfork();
    800028fc:	b6aff0ef          	jal	80001c66 <kfork>
}
    80002900:	60a2                	ld	ra,8(sp)
    80002902:	6402                	ld	s0,0(sp)
    80002904:	0141                	addi	sp,sp,16
    80002906:	8082                	ret

0000000080002908 <sys_wait>:

uint64
sys_wait(void)
{
    80002908:	1101                	addi	sp,sp,-32
    8000290a:	ec06                	sd	ra,24(sp)
    8000290c:	e822                	sd	s0,16(sp)
    8000290e:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002910:	fe840593          	addi	a1,s0,-24
    80002914:	4501                	li	a0,0
    80002916:	efdff0ef          	jal	80002812 <argaddr>
  return kwait(p);
    8000291a:	fe843503          	ld	a0,-24(s0)
    8000291e:	845ff0ef          	jal	80002162 <kwait>
}
    80002922:	60e2                	ld	ra,24(sp)
    80002924:	6442                	ld	s0,16(sp)
    80002926:	6105                	addi	sp,sp,32
    80002928:	8082                	ret

000000008000292a <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000292a:	7179                	addi	sp,sp,-48
    8000292c:	f406                	sd	ra,40(sp)
    8000292e:	f022                	sd	s0,32(sp)
    80002930:	ec26                	sd	s1,24(sp)
    80002932:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002934:	fd840593          	addi	a1,s0,-40
    80002938:	4501                	li	a0,0
    8000293a:	ebdff0ef          	jal	800027f6 <argint>
  argint(1, &t);
    8000293e:	fdc40593          	addi	a1,s0,-36
    80002942:	4505                	li	a0,1
    80002944:	eb3ff0ef          	jal	800027f6 <argint>
  addr = myproc()->sz;
    80002948:	fbdfe0ef          	jal	80001904 <myproc>
    8000294c:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    8000294e:	fdc42703          	lw	a4,-36(s0)
    80002952:	4785                	li	a5,1
    80002954:	02f70a63          	beq	a4,a5,80002988 <sys_sbrk+0x5e>
    80002958:	fd842783          	lw	a5,-40(s0)
    8000295c:	0207c663          	bltz	a5,80002988 <sys_sbrk+0x5e>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002960:	00978733          	add	a4,a5,s1
      return -1;
    if(addr + n > TRAPFRAME)
    80002964:	020007b7          	lui	a5,0x2000
    80002968:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    8000296a:	07b6                	slli	a5,a5,0xd
    8000296c:	00e7b7b3          	sltu	a5,a5,a4
    if(addr + n < addr)
    80002970:	00973733          	sltu	a4,a4,s1
    if(addr + n > TRAPFRAME)
    80002974:	8fd9                	or	a5,a5,a4
    80002976:	e79d                	bnez	a5,800029a4 <sys_sbrk+0x7a>
      return -1;
    myproc()->sz += n;
    80002978:	f8dfe0ef          	jal	80001904 <myproc>
    8000297c:	fd842703          	lw	a4,-40(s0)
    80002980:	653c                	ld	a5,72(a0)
    80002982:	97ba                	add	a5,a5,a4
    80002984:	e53c                	sd	a5,72(a0)
    80002986:	a039                	j	80002994 <sys_sbrk+0x6a>
    if(growproc(n) < 0) {
    80002988:	fd842503          	lw	a0,-40(s0)
    8000298c:	a7cff0ef          	jal	80001c08 <growproc>
    80002990:	00054863          	bltz	a0,800029a0 <sys_sbrk+0x76>
  }
  return addr;
}
    80002994:	8526                	mv	a0,s1
    80002996:	70a2                	ld	ra,40(sp)
    80002998:	7402                	ld	s0,32(sp)
    8000299a:	64e2                	ld	s1,24(sp)
    8000299c:	6145                	addi	sp,sp,48
    8000299e:	8082                	ret
      return -1;
    800029a0:	54fd                	li	s1,-1
    800029a2:	bfcd                	j	80002994 <sys_sbrk+0x6a>
      return -1;
    800029a4:	54fd                	li	s1,-1
    800029a6:	b7fd                	j	80002994 <sys_sbrk+0x6a>

00000000800029a8 <sys_pause>:

uint64
sys_pause(void)
{
    800029a8:	7139                	addi	sp,sp,-64
    800029aa:	fc06                	sd	ra,56(sp)
    800029ac:	f822                	sd	s0,48(sp)
    800029ae:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800029b0:	fcc40593          	addi	a1,s0,-52
    800029b4:	4501                	li	a0,0
    800029b6:	e41ff0ef          	jal	800027f6 <argint>
  if(n < 0)
    800029ba:	fcc42783          	lw	a5,-52(s0)
    800029be:	0607c863          	bltz	a5,80002a2e <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    800029c2:	00013517          	auipc	a0,0x13
    800029c6:	dd650513          	addi	a0,a0,-554 # 80015798 <tickslock>
    800029ca:	a6efe0ef          	jal	80000c38 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    800029ce:	fcc42783          	lw	a5,-52(s0)
    800029d2:	c3b9                	beqz	a5,80002a18 <sys_pause+0x70>
    800029d4:	f426                	sd	s1,40(sp)
    800029d6:	f04a                	sd	s2,32(sp)
    800029d8:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    800029da:	00005997          	auipc	s3,0x5
    800029de:	e8e9a983          	lw	s3,-370(s3) # 80007868 <ticks>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800029e2:	00013917          	auipc	s2,0x13
    800029e6:	db690913          	addi	s2,s2,-586 # 80015798 <tickslock>
    800029ea:	00005497          	auipc	s1,0x5
    800029ee:	e7e48493          	addi	s1,s1,-386 # 80007868 <ticks>
    if(killed(myproc())){
    800029f2:	f13fe0ef          	jal	80001904 <myproc>
    800029f6:	f42ff0ef          	jal	80002138 <killed>
    800029fa:	ed0d                	bnez	a0,80002a34 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    800029fc:	85ca                	mv	a1,s2
    800029fe:	8526                	mv	a0,s1
    80002a00:	cfcff0ef          	jal	80001efc <sleep>
  while(ticks - ticks0 < n){
    80002a04:	409c                	lw	a5,0(s1)
    80002a06:	413787bb          	subw	a5,a5,s3
    80002a0a:	fcc42703          	lw	a4,-52(s0)
    80002a0e:	fee7e2e3          	bltu	a5,a4,800029f2 <sys_pause+0x4a>
    80002a12:	74a2                	ld	s1,40(sp)
    80002a14:	7902                	ld	s2,32(sp)
    80002a16:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002a18:	00013517          	auipc	a0,0x13
    80002a1c:	d8050513          	addi	a0,a0,-640 # 80015798 <tickslock>
    80002a20:	aa8fe0ef          	jal	80000cc8 <release>
  return 0;
    80002a24:	4501                	li	a0,0
}
    80002a26:	70e2                	ld	ra,56(sp)
    80002a28:	7442                	ld	s0,48(sp)
    80002a2a:	6121                	addi	sp,sp,64
    80002a2c:	8082                	ret
    n = 0;
    80002a2e:	fc042623          	sw	zero,-52(s0)
    80002a32:	bf41                	j	800029c2 <sys_pause+0x1a>
      release(&tickslock);
    80002a34:	00013517          	auipc	a0,0x13
    80002a38:	d6450513          	addi	a0,a0,-668 # 80015798 <tickslock>
    80002a3c:	a8cfe0ef          	jal	80000cc8 <release>
      return -1;
    80002a40:	557d                	li	a0,-1
    80002a42:	74a2                	ld	s1,40(sp)
    80002a44:	7902                	ld	s2,32(sp)
    80002a46:	69e2                	ld	s3,24(sp)
    80002a48:	bff9                	j	80002a26 <sys_pause+0x7e>

0000000080002a4a <sys_kill>:

uint64
sys_kill(void)
{
    80002a4a:	1101                	addi	sp,sp,-32
    80002a4c:	ec06                	sd	ra,24(sp)
    80002a4e:	e822                	sd	s0,16(sp)
    80002a50:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002a52:	fec40593          	addi	a1,s0,-20
    80002a56:	4501                	li	a0,0
    80002a58:	d9fff0ef          	jal	800027f6 <argint>
  return kkill(pid);
    80002a5c:	fec42503          	lw	a0,-20(s0)
    80002a60:	e4eff0ef          	jal	800020ae <kkill>
}
    80002a64:	60e2                	ld	ra,24(sp)
    80002a66:	6442                	ld	s0,16(sp)
    80002a68:	6105                	addi	sp,sp,32
    80002a6a:	8082                	ret

0000000080002a6c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002a6c:	1101                	addi	sp,sp,-32
    80002a6e:	ec06                	sd	ra,24(sp)
    80002a70:	e822                	sd	s0,16(sp)
    80002a72:	e426                	sd	s1,8(sp)
    80002a74:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002a76:	00013517          	auipc	a0,0x13
    80002a7a:	d2250513          	addi	a0,a0,-734 # 80015798 <tickslock>
    80002a7e:	9bafe0ef          	jal	80000c38 <acquire>
  xticks = ticks;
    80002a82:	00005797          	auipc	a5,0x5
    80002a86:	de67a783          	lw	a5,-538(a5) # 80007868 <ticks>
    80002a8a:	84be                	mv	s1,a5
  release(&tickslock);
    80002a8c:	00013517          	auipc	a0,0x13
    80002a90:	d0c50513          	addi	a0,a0,-756 # 80015798 <tickslock>
    80002a94:	a34fe0ef          	jal	80000cc8 <release>
  return xticks;
}
    80002a98:	02049513          	slli	a0,s1,0x20
    80002a9c:	9101                	srli	a0,a0,0x20
    80002a9e:	60e2                	ld	ra,24(sp)
    80002aa0:	6442                	ld	s0,16(sp)
    80002aa2:	64a2                	ld	s1,8(sp)
    80002aa4:	6105                	addi	sp,sp,32
    80002aa6:	8082                	ret

0000000080002aa8 <sys_hello>:
uint64
sys_hello(void)
{
    80002aa8:	1141                	addi	sp,sp,-16
    80002aaa:	e406                	sd	ra,8(sp)
    80002aac:	e022                	sd	s0,0(sp)
    80002aae:	0800                	addi	s0,sp,16
  return 0;
}
    80002ab0:	4501                	li	a0,0
    80002ab2:	60a2                	ld	ra,8(sp)
    80002ab4:	6402                	ld	s0,0(sp)
    80002ab6:	0141                	addi	sp,sp,16
    80002ab8:	8082                	ret

0000000080002aba <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002aba:	7179                	addi	sp,sp,-48
    80002abc:	f406                	sd	ra,40(sp)
    80002abe:	f022                	sd	s0,32(sp)
    80002ac0:	ec26                	sd	s1,24(sp)
    80002ac2:	e84a                	sd	s2,16(sp)
    80002ac4:	e44e                	sd	s3,8(sp)
    80002ac6:	e052                	sd	s4,0(sp)
    80002ac8:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002aca:	00005597          	auipc	a1,0x5
    80002ace:	8c658593          	addi	a1,a1,-1850 # 80007390 <etext+0x390>
    80002ad2:	00013517          	auipc	a0,0x13
    80002ad6:	cde50513          	addi	a0,a0,-802 # 800157b0 <bcache>
    80002ada:	8d4fe0ef          	jal	80000bae <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002ade:	0001b797          	auipc	a5,0x1b
    80002ae2:	cd278793          	addi	a5,a5,-814 # 8001d7b0 <bcache+0x8000>
    80002ae6:	0001b717          	auipc	a4,0x1b
    80002aea:	f3270713          	addi	a4,a4,-206 # 8001da18 <bcache+0x8268>
    80002aee:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002af2:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002af6:	00013497          	auipc	s1,0x13
    80002afa:	cd248493          	addi	s1,s1,-814 # 800157c8 <bcache+0x18>
    b->next = bcache.head.next;
    80002afe:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002b00:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002b02:	00005a17          	auipc	s4,0x5
    80002b06:	896a0a13          	addi	s4,s4,-1898 # 80007398 <etext+0x398>
    b->next = bcache.head.next;
    80002b0a:	2b893783          	ld	a5,696(s2)
    80002b0e:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002b10:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002b14:	85d2                	mv	a1,s4
    80002b16:	01048513          	addi	a0,s1,16
    80002b1a:	336010ef          	jal	80003e50 <initsleeplock>
    bcache.head.next->prev = b;
    80002b1e:	2b893783          	ld	a5,696(s2)
    80002b22:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002b24:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002b28:	45848493          	addi	s1,s1,1112
    80002b2c:	fd349fe3          	bne	s1,s3,80002b0a <binit+0x50>
  }
}
    80002b30:	70a2                	ld	ra,40(sp)
    80002b32:	7402                	ld	s0,32(sp)
    80002b34:	64e2                	ld	s1,24(sp)
    80002b36:	6942                	ld	s2,16(sp)
    80002b38:	69a2                	ld	s3,8(sp)
    80002b3a:	6a02                	ld	s4,0(sp)
    80002b3c:	6145                	addi	sp,sp,48
    80002b3e:	8082                	ret

0000000080002b40 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002b40:	7179                	addi	sp,sp,-48
    80002b42:	f406                	sd	ra,40(sp)
    80002b44:	f022                	sd	s0,32(sp)
    80002b46:	ec26                	sd	s1,24(sp)
    80002b48:	e84a                	sd	s2,16(sp)
    80002b4a:	e44e                	sd	s3,8(sp)
    80002b4c:	1800                	addi	s0,sp,48
    80002b4e:	892a                	mv	s2,a0
    80002b50:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002b52:	00013517          	auipc	a0,0x13
    80002b56:	c5e50513          	addi	a0,a0,-930 # 800157b0 <bcache>
    80002b5a:	8defe0ef          	jal	80000c38 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002b5e:	0001b497          	auipc	s1,0x1b
    80002b62:	f0a4b483          	ld	s1,-246(s1) # 8001da68 <bcache+0x82b8>
    80002b66:	0001b797          	auipc	a5,0x1b
    80002b6a:	eb278793          	addi	a5,a5,-334 # 8001da18 <bcache+0x8268>
    80002b6e:	02f48b63          	beq	s1,a5,80002ba4 <bread+0x64>
    80002b72:	873e                	mv	a4,a5
    80002b74:	a021                	j	80002b7c <bread+0x3c>
    80002b76:	68a4                	ld	s1,80(s1)
    80002b78:	02e48663          	beq	s1,a4,80002ba4 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002b7c:	449c                	lw	a5,8(s1)
    80002b7e:	ff279ce3          	bne	a5,s2,80002b76 <bread+0x36>
    80002b82:	44dc                	lw	a5,12(s1)
    80002b84:	ff3799e3          	bne	a5,s3,80002b76 <bread+0x36>
      b->refcnt++;
    80002b88:	40bc                	lw	a5,64(s1)
    80002b8a:	2785                	addiw	a5,a5,1
    80002b8c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002b8e:	00013517          	auipc	a0,0x13
    80002b92:	c2250513          	addi	a0,a0,-990 # 800157b0 <bcache>
    80002b96:	932fe0ef          	jal	80000cc8 <release>
      acquiresleep(&b->lock);
    80002b9a:	01048513          	addi	a0,s1,16
    80002b9e:	2e8010ef          	jal	80003e86 <acquiresleep>
      return b;
    80002ba2:	a889                	j	80002bf4 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002ba4:	0001b497          	auipc	s1,0x1b
    80002ba8:	ebc4b483          	ld	s1,-324(s1) # 8001da60 <bcache+0x82b0>
    80002bac:	0001b797          	auipc	a5,0x1b
    80002bb0:	e6c78793          	addi	a5,a5,-404 # 8001da18 <bcache+0x8268>
    80002bb4:	00f48863          	beq	s1,a5,80002bc4 <bread+0x84>
    80002bb8:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002bba:	40bc                	lw	a5,64(s1)
    80002bbc:	cb91                	beqz	a5,80002bd0 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002bbe:	64a4                	ld	s1,72(s1)
    80002bc0:	fee49de3          	bne	s1,a4,80002bba <bread+0x7a>
  panic("bget: no buffers");
    80002bc4:	00004517          	auipc	a0,0x4
    80002bc8:	7dc50513          	addi	a0,a0,2012 # 800073a0 <etext+0x3a0>
    80002bcc:	c6dfd0ef          	jal	80000838 <panic>
      b->dev = dev;
    80002bd0:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002bd4:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002bd8:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002bdc:	4785                	li	a5,1
    80002bde:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002be0:	00013517          	auipc	a0,0x13
    80002be4:	bd050513          	addi	a0,a0,-1072 # 800157b0 <bcache>
    80002be8:	8e0fe0ef          	jal	80000cc8 <release>
      acquiresleep(&b->lock);
    80002bec:	01048513          	addi	a0,s1,16
    80002bf0:	296010ef          	jal	80003e86 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002bf4:	409c                	lw	a5,0(s1)
    80002bf6:	cb89                	beqz	a5,80002c08 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002bf8:	8526                	mv	a0,s1
    80002bfa:	70a2                	ld	ra,40(sp)
    80002bfc:	7402                	ld	s0,32(sp)
    80002bfe:	64e2                	ld	s1,24(sp)
    80002c00:	6942                	ld	s2,16(sp)
    80002c02:	69a2                	ld	s3,8(sp)
    80002c04:	6145                	addi	sp,sp,48
    80002c06:	8082                	ret
    virtio_disk_rw(b, 0);
    80002c08:	4581                	li	a1,0
    80002c0a:	8526                	mv	a0,s1
    80002c0c:	267020ef          	jal	80005672 <virtio_disk_rw>
    b->valid = 1;
    80002c10:	4785                	li	a5,1
    80002c12:	c09c                	sw	a5,0(s1)
  return b;
    80002c14:	b7d5                	j	80002bf8 <bread+0xb8>

0000000080002c16 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002c16:	1101                	addi	sp,sp,-32
    80002c18:	ec06                	sd	ra,24(sp)
    80002c1a:	e822                	sd	s0,16(sp)
    80002c1c:	e426                	sd	s1,8(sp)
    80002c1e:	1000                	addi	s0,sp,32
    80002c20:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002c22:	0541                	addi	a0,a0,16
    80002c24:	2e0010ef          	jal	80003f04 <holdingsleep>
    80002c28:	c911                	beqz	a0,80002c3c <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002c2a:	4585                	li	a1,1
    80002c2c:	8526                	mv	a0,s1
    80002c2e:	245020ef          	jal	80005672 <virtio_disk_rw>
}
    80002c32:	60e2                	ld	ra,24(sp)
    80002c34:	6442                	ld	s0,16(sp)
    80002c36:	64a2                	ld	s1,8(sp)
    80002c38:	6105                	addi	sp,sp,32
    80002c3a:	8082                	ret
    panic("bwrite");
    80002c3c:	00004517          	auipc	a0,0x4
    80002c40:	77c50513          	addi	a0,a0,1916 # 800073b8 <etext+0x3b8>
    80002c44:	bf5fd0ef          	jal	80000838 <panic>

0000000080002c48 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002c48:	1101                	addi	sp,sp,-32
    80002c4a:	ec06                	sd	ra,24(sp)
    80002c4c:	e822                	sd	s0,16(sp)
    80002c4e:	e426                	sd	s1,8(sp)
    80002c50:	e04a                	sd	s2,0(sp)
    80002c52:	1000                	addi	s0,sp,32
    80002c54:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002c56:	01050913          	addi	s2,a0,16
    80002c5a:	854a                	mv	a0,s2
    80002c5c:	2a8010ef          	jal	80003f04 <holdingsleep>
    80002c60:	c125                	beqz	a0,80002cc0 <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002c62:	854a                	mv	a0,s2
    80002c64:	268010ef          	jal	80003ecc <releasesleep>

  acquire(&bcache.lock);
    80002c68:	00013517          	auipc	a0,0x13
    80002c6c:	b4850513          	addi	a0,a0,-1208 # 800157b0 <bcache>
    80002c70:	fc9fd0ef          	jal	80000c38 <acquire>
  b->refcnt--;
    80002c74:	40bc                	lw	a5,64(s1)
    80002c76:	37fd                	addiw	a5,a5,-1
    80002c78:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002c7a:	e79d                	bnez	a5,80002ca8 <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002c7c:	68b8                	ld	a4,80(s1)
    80002c7e:	64bc                	ld	a5,72(s1)
    80002c80:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002c82:	68b8                	ld	a4,80(s1)
    80002c84:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002c86:	0001b797          	auipc	a5,0x1b
    80002c8a:	b2a78793          	addi	a5,a5,-1238 # 8001d7b0 <bcache+0x8000>
    80002c8e:	2b87b703          	ld	a4,696(a5)
    80002c92:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002c94:	0001b717          	auipc	a4,0x1b
    80002c98:	d8470713          	addi	a4,a4,-636 # 8001da18 <bcache+0x8268>
    80002c9c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002c9e:	2b87b703          	ld	a4,696(a5)
    80002ca2:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002ca4:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002ca8:	00013517          	auipc	a0,0x13
    80002cac:	b0850513          	addi	a0,a0,-1272 # 800157b0 <bcache>
    80002cb0:	818fe0ef          	jal	80000cc8 <release>
}
    80002cb4:	60e2                	ld	ra,24(sp)
    80002cb6:	6442                	ld	s0,16(sp)
    80002cb8:	64a2                	ld	s1,8(sp)
    80002cba:	6902                	ld	s2,0(sp)
    80002cbc:	6105                	addi	sp,sp,32
    80002cbe:	8082                	ret
    panic("brelse");
    80002cc0:	00004517          	auipc	a0,0x4
    80002cc4:	70050513          	addi	a0,a0,1792 # 800073c0 <etext+0x3c0>
    80002cc8:	b71fd0ef          	jal	80000838 <panic>

0000000080002ccc <bpin>:

void
bpin(struct buf *b) {
    80002ccc:	1101                	addi	sp,sp,-32
    80002cce:	ec06                	sd	ra,24(sp)
    80002cd0:	e822                	sd	s0,16(sp)
    80002cd2:	e426                	sd	s1,8(sp)
    80002cd4:	1000                	addi	s0,sp,32
    80002cd6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002cd8:	00013517          	auipc	a0,0x13
    80002cdc:	ad850513          	addi	a0,a0,-1320 # 800157b0 <bcache>
    80002ce0:	f59fd0ef          	jal	80000c38 <acquire>
  b->refcnt++;
    80002ce4:	40bc                	lw	a5,64(s1)
    80002ce6:	2785                	addiw	a5,a5,1
    80002ce8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002cea:	00013517          	auipc	a0,0x13
    80002cee:	ac650513          	addi	a0,a0,-1338 # 800157b0 <bcache>
    80002cf2:	fd7fd0ef          	jal	80000cc8 <release>
}
    80002cf6:	60e2                	ld	ra,24(sp)
    80002cf8:	6442                	ld	s0,16(sp)
    80002cfa:	64a2                	ld	s1,8(sp)
    80002cfc:	6105                	addi	sp,sp,32
    80002cfe:	8082                	ret

0000000080002d00 <bunpin>:

void
bunpin(struct buf *b) {
    80002d00:	1101                	addi	sp,sp,-32
    80002d02:	ec06                	sd	ra,24(sp)
    80002d04:	e822                	sd	s0,16(sp)
    80002d06:	e426                	sd	s1,8(sp)
    80002d08:	1000                	addi	s0,sp,32
    80002d0a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d0c:	00013517          	auipc	a0,0x13
    80002d10:	aa450513          	addi	a0,a0,-1372 # 800157b0 <bcache>
    80002d14:	f25fd0ef          	jal	80000c38 <acquire>
  b->refcnt--;
    80002d18:	40bc                	lw	a5,64(s1)
    80002d1a:	37fd                	addiw	a5,a5,-1
    80002d1c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d1e:	00013517          	auipc	a0,0x13
    80002d22:	a9250513          	addi	a0,a0,-1390 # 800157b0 <bcache>
    80002d26:	fa3fd0ef          	jal	80000cc8 <release>
}
    80002d2a:	60e2                	ld	ra,24(sp)
    80002d2c:	6442                	ld	s0,16(sp)
    80002d2e:	64a2                	ld	s1,8(sp)
    80002d30:	6105                	addi	sp,sp,32
    80002d32:	8082                	ret

0000000080002d34 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002d34:	1101                	addi	sp,sp,-32
    80002d36:	ec06                	sd	ra,24(sp)
    80002d38:	e822                	sd	s0,16(sp)
    80002d3a:	e426                	sd	s1,8(sp)
    80002d3c:	e04a                	sd	s2,0(sp)
    80002d3e:	1000                	addi	s0,sp,32
    80002d40:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002d42:	00d5d79b          	srliw	a5,a1,0xd
    80002d46:	0001b597          	auipc	a1,0x1b
    80002d4a:	1465a583          	lw	a1,326(a1) # 8001de8c <sb+0x1c>
    80002d4e:	9dbd                	addw	a1,a1,a5
    80002d50:	df1ff0ef          	jal	80002b40 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002d54:	0074f713          	andi	a4,s1,7
    80002d58:	4785                	li	a5,1
    80002d5a:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002d5e:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    80002d60:	90d9                	srli	s1,s1,0x36
    80002d62:	00950733          	add	a4,a0,s1
    80002d66:	05874703          	lbu	a4,88(a4)
    80002d6a:	00e7f6b3          	and	a3,a5,a4
    80002d6e:	c29d                	beqz	a3,80002d94 <bfree+0x60>
    80002d70:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002d72:	94aa                	add	s1,s1,a0
    80002d74:	fff7c793          	not	a5,a5
    80002d78:	8f7d                	and	a4,a4,a5
    80002d7a:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002d7e:	012010ef          	jal	80003d90 <log_write>
  brelse(bp);
    80002d82:	854a                	mv	a0,s2
    80002d84:	ec5ff0ef          	jal	80002c48 <brelse>
}
    80002d88:	60e2                	ld	ra,24(sp)
    80002d8a:	6442                	ld	s0,16(sp)
    80002d8c:	64a2                	ld	s1,8(sp)
    80002d8e:	6902                	ld	s2,0(sp)
    80002d90:	6105                	addi	sp,sp,32
    80002d92:	8082                	ret
    panic("freeing free block");
    80002d94:	00004517          	auipc	a0,0x4
    80002d98:	63450513          	addi	a0,a0,1588 # 800073c8 <etext+0x3c8>
    80002d9c:	a9dfd0ef          	jal	80000838 <panic>

0000000080002da0 <balloc>:
{
    80002da0:	715d                	addi	sp,sp,-80
    80002da2:	e486                	sd	ra,72(sp)
    80002da4:	e0a2                	sd	s0,64(sp)
    80002da6:	fc26                	sd	s1,56(sp)
    80002da8:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80002daa:	0001b797          	auipc	a5,0x1b
    80002dae:	0ca7a783          	lw	a5,202(a5) # 8001de74 <sb+0x4>
    80002db2:	0e078263          	beqz	a5,80002e96 <balloc+0xf6>
    80002db6:	f84a                	sd	s2,48(sp)
    80002db8:	f44e                	sd	s3,40(sp)
    80002dba:	f052                	sd	s4,32(sp)
    80002dbc:	ec56                	sd	s5,24(sp)
    80002dbe:	e85a                	sd	s6,16(sp)
    80002dc0:	e45e                	sd	s7,8(sp)
    80002dc2:	e062                	sd	s8,0(sp)
    80002dc4:	8baa                	mv	s7,a0
    80002dc6:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002dc8:	0001bb17          	auipc	s6,0x1b
    80002dcc:	0a8b0b13          	addi	s6,s6,168 # 8001de70 <sb>
      m = 1 << (bi % 8);
    80002dd0:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002dd2:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002dd4:	6c09                	lui	s8,0x2
    80002dd6:	a09d                	j	80002e3c <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002dd8:	97ca                	add	a5,a5,s2
    80002dda:	8e55                	or	a2,a2,a3
    80002ddc:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002de0:	854a                	mv	a0,s2
    80002de2:	7af000ef          	jal	80003d90 <log_write>
        brelse(bp);
    80002de6:	854a                	mv	a0,s2
    80002de8:	e61ff0ef          	jal	80002c48 <brelse>
  bp = bread(dev, bno);
    80002dec:	85a6                	mv	a1,s1
    80002dee:	855e                	mv	a0,s7
    80002df0:	d51ff0ef          	jal	80002b40 <bread>
    80002df4:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002df6:	40000613          	li	a2,1024
    80002dfa:	4581                	li	a1,0
    80002dfc:	05850513          	addi	a0,a0,88
    80002e00:	f05fd0ef          	jal	80000d04 <memset>
  log_write(bp);
    80002e04:	854a                	mv	a0,s2
    80002e06:	78b000ef          	jal	80003d90 <log_write>
  brelse(bp);
    80002e0a:	854a                	mv	a0,s2
    80002e0c:	e3dff0ef          	jal	80002c48 <brelse>
        return b + bi;
    80002e10:	7942                	ld	s2,48(sp)
    80002e12:	79a2                	ld	s3,40(sp)
    80002e14:	7a02                	ld	s4,32(sp)
    80002e16:	6ae2                	ld	s5,24(sp)
    80002e18:	6b42                	ld	s6,16(sp)
    80002e1a:	6ba2                	ld	s7,8(sp)
    80002e1c:	6c02                	ld	s8,0(sp)
}
    80002e1e:	8526                	mv	a0,s1
    80002e20:	60a6                	ld	ra,72(sp)
    80002e22:	6406                	ld	s0,64(sp)
    80002e24:	74e2                	ld	s1,56(sp)
    80002e26:	6161                	addi	sp,sp,80
    80002e28:	8082                	ret
    brelse(bp);
    80002e2a:	854a                	mv	a0,s2
    80002e2c:	e1dff0ef          	jal	80002c48 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002e30:	015c0abb          	addw	s5,s8,s5
    80002e34:	004b2783          	lw	a5,4(s6)
    80002e38:	04faf863          	bgeu	s5,a5,80002e88 <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    80002e3c:	40dad59b          	sraiw	a1,s5,0xd
    80002e40:	01cb2783          	lw	a5,28(s6)
    80002e44:	9dbd                	addw	a1,a1,a5
    80002e46:	855e                	mv	a0,s7
    80002e48:	cf9ff0ef          	jal	80002b40 <bread>
    80002e4c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e4e:	004b2503          	lw	a0,4(s6)
    80002e52:	84d6                	mv	s1,s5
    80002e54:	4701                	li	a4,0
    80002e56:	fca4fae3          	bgeu	s1,a0,80002e2a <balloc+0x8a>
      m = 1 << (bi % 8);
    80002e5a:	00777693          	andi	a3,a4,7
    80002e5e:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002e62:	41f7579b          	sraiw	a5,a4,0x1f
    80002e66:	01d7d79b          	srliw	a5,a5,0x1d
    80002e6a:	9fb9                	addw	a5,a5,a4
    80002e6c:	4037d79b          	sraiw	a5,a5,0x3
    80002e70:	00f90633          	add	a2,s2,a5
    80002e74:	05864603          	lbu	a2,88(a2)
    80002e78:	00c6f5b3          	and	a1,a3,a2
    80002e7c:	ddb1                	beqz	a1,80002dd8 <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e7e:	2705                	addiw	a4,a4,1
    80002e80:	2485                	addiw	s1,s1,1
    80002e82:	fd471ae3          	bne	a4,s4,80002e56 <balloc+0xb6>
    80002e86:	b755                	j	80002e2a <balloc+0x8a>
    80002e88:	7942                	ld	s2,48(sp)
    80002e8a:	79a2                	ld	s3,40(sp)
    80002e8c:	7a02                	ld	s4,32(sp)
    80002e8e:	6ae2                	ld	s5,24(sp)
    80002e90:	6b42                	ld	s6,16(sp)
    80002e92:	6ba2                	ld	s7,8(sp)
    80002e94:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    80002e96:	00004517          	auipc	a0,0x4
    80002e9a:	54a50513          	addi	a0,a0,1354 # 800073e0 <etext+0x3e0>
    80002e9e:	e62fd0ef          	jal	80000500 <printf>
  return 0;
    80002ea2:	4481                	li	s1,0
    80002ea4:	bfad                	j	80002e1e <balloc+0x7e>

0000000080002ea6 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002ea6:	7179                	addi	sp,sp,-48
    80002ea8:	f406                	sd	ra,40(sp)
    80002eaa:	f022                	sd	s0,32(sp)
    80002eac:	ec26                	sd	s1,24(sp)
    80002eae:	e84a                	sd	s2,16(sp)
    80002eb0:	e44e                	sd	s3,8(sp)
    80002eb2:	1800                	addi	s0,sp,48
    80002eb4:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002eb6:	47ad                	li	a5,11
    80002eb8:	02b7e363          	bltu	a5,a1,80002ede <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    80002ebc:	02059793          	slli	a5,a1,0x20
    80002ec0:	01e7d593          	srli	a1,a5,0x1e
    80002ec4:	00b509b3          	add	s3,a0,a1
    80002ec8:	0509a483          	lw	s1,80(s3)
    80002ecc:	e0b5                	bnez	s1,80002f30 <bmap+0x8a>
      addr = balloc(ip->dev);
    80002ece:	4108                	lw	a0,0(a0)
    80002ed0:	ed1ff0ef          	jal	80002da0 <balloc>
    80002ed4:	84aa                	mv	s1,a0
      if(addr == 0)
    80002ed6:	cd29                	beqz	a0,80002f30 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    80002ed8:	04a9a823          	sw	a0,80(s3)
    80002edc:	a891                	j	80002f30 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002ede:	ff45879b          	addiw	a5,a1,-12
    80002ee2:	873e                	mv	a4,a5
    80002ee4:	89be                	mv	s3,a5

  if(bn < NINDIRECT){
    80002ee6:	0ff00793          	li	a5,255
    80002eea:	06e7e763          	bltu	a5,a4,80002f58 <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002eee:	08052483          	lw	s1,128(a0)
    80002ef2:	e891                	bnez	s1,80002f06 <bmap+0x60>
      addr = balloc(ip->dev);
    80002ef4:	4108                	lw	a0,0(a0)
    80002ef6:	eabff0ef          	jal	80002da0 <balloc>
    80002efa:	84aa                	mv	s1,a0
      if(addr == 0)
    80002efc:	c915                	beqz	a0,80002f30 <bmap+0x8a>
    80002efe:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002f00:	08a92023          	sw	a0,128(s2)
    80002f04:	a011                	j	80002f08 <bmap+0x62>
    80002f06:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002f08:	85a6                	mv	a1,s1
    80002f0a:	00092503          	lw	a0,0(s2)
    80002f0e:	c33ff0ef          	jal	80002b40 <bread>
    80002f12:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002f14:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002f18:	02099713          	slli	a4,s3,0x20
    80002f1c:	01e75593          	srli	a1,a4,0x1e
    80002f20:	97ae                	add	a5,a5,a1
    80002f22:	89be                	mv	s3,a5
    80002f24:	4384                	lw	s1,0(a5)
    80002f26:	cc89                	beqz	s1,80002f40 <bmap+0x9a>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002f28:	8552                	mv	a0,s4
    80002f2a:	d1fff0ef          	jal	80002c48 <brelse>
    return addr;
    80002f2e:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002f30:	8526                	mv	a0,s1
    80002f32:	70a2                	ld	ra,40(sp)
    80002f34:	7402                	ld	s0,32(sp)
    80002f36:	64e2                	ld	s1,24(sp)
    80002f38:	6942                	ld	s2,16(sp)
    80002f3a:	69a2                	ld	s3,8(sp)
    80002f3c:	6145                	addi	sp,sp,48
    80002f3e:	8082                	ret
      addr = balloc(ip->dev);
    80002f40:	00092503          	lw	a0,0(s2)
    80002f44:	e5dff0ef          	jal	80002da0 <balloc>
    80002f48:	84aa                	mv	s1,a0
      if(addr){
    80002f4a:	dd79                	beqz	a0,80002f28 <bmap+0x82>
        a[bn] = addr;
    80002f4c:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    80002f50:	8552                	mv	a0,s4
    80002f52:	63f000ef          	jal	80003d90 <log_write>
    80002f56:	bfc9                	j	80002f28 <bmap+0x82>
    80002f58:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80002f5a:	00004517          	auipc	a0,0x4
    80002f5e:	49e50513          	addi	a0,a0,1182 # 800073f8 <etext+0x3f8>
    80002f62:	8d7fd0ef          	jal	80000838 <panic>

0000000080002f66 <iget>:
{
    80002f66:	7179                	addi	sp,sp,-48
    80002f68:	f406                	sd	ra,40(sp)
    80002f6a:	f022                	sd	s0,32(sp)
    80002f6c:	ec26                	sd	s1,24(sp)
    80002f6e:	e84a                	sd	s2,16(sp)
    80002f70:	e44e                	sd	s3,8(sp)
    80002f72:	e052                	sd	s4,0(sp)
    80002f74:	1800                	addi	s0,sp,48
    80002f76:	89aa                	mv	s3,a0
    80002f78:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002f7a:	0001b517          	auipc	a0,0x1b
    80002f7e:	f1650513          	addi	a0,a0,-234 # 8001de90 <itable>
    80002f82:	cb7fd0ef          	jal	80000c38 <acquire>
  empty = 0;
    80002f86:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002f88:	0001b497          	auipc	s1,0x1b
    80002f8c:	f2048493          	addi	s1,s1,-224 # 8001dea8 <itable+0x18>
    80002f90:	0001d697          	auipc	a3,0x1d
    80002f94:	9a868693          	addi	a3,a3,-1624 # 8001f938 <log>
    80002f98:	a819                	j	80002fae <iget+0x48>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002f9a:	0017b793          	seqz	a5,a5
    80002f9e:	00193713          	seqz	a4,s2
    80002fa2:	8ff9                	and	a5,a5,a4
    80002fa4:	eb85                	bnez	a5,80002fd4 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002fa6:	08848493          	addi	s1,s1,136
    80002faa:	02d48763          	beq	s1,a3,80002fd8 <iget+0x72>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002fae:	449c                	lw	a5,8(s1)
    80002fb0:	fef055e3          	blez	a5,80002f9a <iget+0x34>
    80002fb4:	4098                	lw	a4,0(s1)
    80002fb6:	ff3718e3          	bne	a4,s3,80002fa6 <iget+0x40>
    80002fba:	40d8                	lw	a4,4(s1)
    80002fbc:	ff4715e3          	bne	a4,s4,80002fa6 <iget+0x40>
      ip->ref++;
    80002fc0:	2785                	addiw	a5,a5,1
    80002fc2:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002fc4:	0001b517          	auipc	a0,0x1b
    80002fc8:	ecc50513          	addi	a0,a0,-308 # 8001de90 <itable>
    80002fcc:	cfdfd0ef          	jal	80000cc8 <release>
      return ip;
    80002fd0:	8926                	mv	s2,s1
    80002fd2:	a025                	j	80002ffa <iget+0x94>
      empty = ip;
    80002fd4:	8926                	mv	s2,s1
    80002fd6:	bfc1                	j	80002fa6 <iget+0x40>
  if(empty == 0)
    80002fd8:	02090a63          	beqz	s2,8000300c <iget+0xa6>
  ip->dev = dev;
    80002fdc:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002fe0:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80002fe4:	4785                	li	a5,1
    80002fe6:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002fea:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80002fee:	0001b517          	auipc	a0,0x1b
    80002ff2:	ea250513          	addi	a0,a0,-350 # 8001de90 <itable>
    80002ff6:	cd3fd0ef          	jal	80000cc8 <release>
}
    80002ffa:	854a                	mv	a0,s2
    80002ffc:	70a2                	ld	ra,40(sp)
    80002ffe:	7402                	ld	s0,32(sp)
    80003000:	64e2                	ld	s1,24(sp)
    80003002:	6942                	ld	s2,16(sp)
    80003004:	69a2                	ld	s3,8(sp)
    80003006:	6a02                	ld	s4,0(sp)
    80003008:	6145                	addi	sp,sp,48
    8000300a:	8082                	ret
    panic("iget: no inodes");
    8000300c:	00004517          	auipc	a0,0x4
    80003010:	40450513          	addi	a0,a0,1028 # 80007410 <etext+0x410>
    80003014:	825fd0ef          	jal	80000838 <panic>

0000000080003018 <iinit>:
{
    80003018:	7179                	addi	sp,sp,-48
    8000301a:	f406                	sd	ra,40(sp)
    8000301c:	f022                	sd	s0,32(sp)
    8000301e:	ec26                	sd	s1,24(sp)
    80003020:	e84a                	sd	s2,16(sp)
    80003022:	e44e                	sd	s3,8(sp)
    80003024:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003026:	00004597          	auipc	a1,0x4
    8000302a:	3fa58593          	addi	a1,a1,1018 # 80007420 <etext+0x420>
    8000302e:	0001b517          	auipc	a0,0x1b
    80003032:	e6250513          	addi	a0,a0,-414 # 8001de90 <itable>
    80003036:	b79fd0ef          	jal	80000bae <initlock>
  for(i = 0; i < NINODE; i++) {
    8000303a:	0001b497          	auipc	s1,0x1b
    8000303e:	e7e48493          	addi	s1,s1,-386 # 8001deb8 <itable+0x28>
    80003042:	0001d997          	auipc	s3,0x1d
    80003046:	90698993          	addi	s3,s3,-1786 # 8001f948 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000304a:	00004917          	auipc	s2,0x4
    8000304e:	3de90913          	addi	s2,s2,990 # 80007428 <etext+0x428>
    80003052:	85ca                	mv	a1,s2
    80003054:	8526                	mv	a0,s1
    80003056:	5fb000ef          	jal	80003e50 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000305a:	08848493          	addi	s1,s1,136
    8000305e:	ff349ae3          	bne	s1,s3,80003052 <iinit+0x3a>
}
    80003062:	70a2                	ld	ra,40(sp)
    80003064:	7402                	ld	s0,32(sp)
    80003066:	64e2                	ld	s1,24(sp)
    80003068:	6942                	ld	s2,16(sp)
    8000306a:	69a2                	ld	s3,8(sp)
    8000306c:	6145                	addi	sp,sp,48
    8000306e:	8082                	ret

0000000080003070 <ialloc>:
{
    80003070:	7139                	addi	sp,sp,-64
    80003072:	fc06                	sd	ra,56(sp)
    80003074:	f822                	sd	s0,48(sp)
    80003076:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003078:	0001b717          	auipc	a4,0x1b
    8000307c:	e0472703          	lw	a4,-508(a4) # 8001de7c <sb+0xc>
    80003080:	4785                	li	a5,1
    80003082:	06e7f063          	bgeu	a5,a4,800030e2 <ialloc+0x72>
    80003086:	f426                	sd	s1,40(sp)
    80003088:	f04a                	sd	s2,32(sp)
    8000308a:	ec4e                	sd	s3,24(sp)
    8000308c:	e852                	sd	s4,16(sp)
    8000308e:	e456                	sd	s5,8(sp)
    80003090:	e05a                	sd	s6,0(sp)
    80003092:	8aaa                	mv	s5,a0
    80003094:	8b2e                	mv	s6,a1
    80003096:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80003098:	0001ba17          	auipc	s4,0x1b
    8000309c:	dd8a0a13          	addi	s4,s4,-552 # 8001de70 <sb>
    800030a0:	00495593          	srli	a1,s2,0x4
    800030a4:	018a2783          	lw	a5,24(s4)
    800030a8:	9dbd                	addw	a1,a1,a5
    800030aa:	8556                	mv	a0,s5
    800030ac:	a95ff0ef          	jal	80002b40 <bread>
    800030b0:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800030b2:	05850993          	addi	s3,a0,88
    800030b6:	00f97793          	andi	a5,s2,15
    800030ba:	079a                	slli	a5,a5,0x6
    800030bc:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800030be:	00099783          	lh	a5,0(s3)
    800030c2:	cb9d                	beqz	a5,800030f8 <ialloc+0x88>
    brelse(bp);
    800030c4:	b85ff0ef          	jal	80002c48 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800030c8:	0905                	addi	s2,s2,1
    800030ca:	00ca2703          	lw	a4,12(s4)
    800030ce:	0009079b          	sext.w	a5,s2
    800030d2:	fce7e7e3          	bltu	a5,a4,800030a0 <ialloc+0x30>
    800030d6:	74a2                	ld	s1,40(sp)
    800030d8:	7902                	ld	s2,32(sp)
    800030da:	69e2                	ld	s3,24(sp)
    800030dc:	6a42                	ld	s4,16(sp)
    800030de:	6aa2                	ld	s5,8(sp)
    800030e0:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800030e2:	00004517          	auipc	a0,0x4
    800030e6:	34e50513          	addi	a0,a0,846 # 80007430 <etext+0x430>
    800030ea:	c16fd0ef          	jal	80000500 <printf>
  return 0;
    800030ee:	4501                	li	a0,0
}
    800030f0:	70e2                	ld	ra,56(sp)
    800030f2:	7442                	ld	s0,48(sp)
    800030f4:	6121                	addi	sp,sp,64
    800030f6:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800030f8:	04000613          	li	a2,64
    800030fc:	4581                	li	a1,0
    800030fe:	854e                	mv	a0,s3
    80003100:	c05fd0ef          	jal	80000d04 <memset>
      dip->type = type;
    80003104:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003108:	8526                	mv	a0,s1
    8000310a:	487000ef          	jal	80003d90 <log_write>
      brelse(bp);
    8000310e:	8526                	mv	a0,s1
    80003110:	b39ff0ef          	jal	80002c48 <brelse>
      return iget(dev, inum);
    80003114:	0009059b          	sext.w	a1,s2
    80003118:	8556                	mv	a0,s5
    8000311a:	e4dff0ef          	jal	80002f66 <iget>
    8000311e:	74a2                	ld	s1,40(sp)
    80003120:	7902                	ld	s2,32(sp)
    80003122:	69e2                	ld	s3,24(sp)
    80003124:	6a42                	ld	s4,16(sp)
    80003126:	6aa2                	ld	s5,8(sp)
    80003128:	6b02                	ld	s6,0(sp)
    8000312a:	b7d9                	j	800030f0 <ialloc+0x80>

000000008000312c <iupdate>:
{
    8000312c:	1101                	addi	sp,sp,-32
    8000312e:	ec06                	sd	ra,24(sp)
    80003130:	e822                	sd	s0,16(sp)
    80003132:	e426                	sd	s1,8(sp)
    80003134:	e04a                	sd	s2,0(sp)
    80003136:	1000                	addi	s0,sp,32
    80003138:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000313a:	415c                	lw	a5,4(a0)
    8000313c:	0047d79b          	srliw	a5,a5,0x4
    80003140:	0001b597          	auipc	a1,0x1b
    80003144:	d485a583          	lw	a1,-696(a1) # 8001de88 <sb+0x18>
    80003148:	9dbd                	addw	a1,a1,a5
    8000314a:	4108                	lw	a0,0(a0)
    8000314c:	9f5ff0ef          	jal	80002b40 <bread>
    80003150:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003152:	05850793          	addi	a5,a0,88
    80003156:	40d8                	lw	a4,4(s1)
    80003158:	8b3d                	andi	a4,a4,15
    8000315a:	071a                	slli	a4,a4,0x6
    8000315c:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000315e:	04449703          	lh	a4,68(s1)
    80003162:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003166:	04649703          	lh	a4,70(s1)
    8000316a:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000316e:	04849703          	lh	a4,72(s1)
    80003172:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003176:	04a49703          	lh	a4,74(s1)
    8000317a:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000317e:	44f8                	lw	a4,76(s1)
    80003180:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003182:	03400613          	li	a2,52
    80003186:	05048593          	addi	a1,s1,80
    8000318a:	00c78513          	addi	a0,a5,12
    8000318e:	bd3fd0ef          	jal	80000d60 <memmove>
  log_write(bp);
    80003192:	854a                	mv	a0,s2
    80003194:	3fd000ef          	jal	80003d90 <log_write>
  brelse(bp);
    80003198:	854a                	mv	a0,s2
    8000319a:	aafff0ef          	jal	80002c48 <brelse>
}
    8000319e:	60e2                	ld	ra,24(sp)
    800031a0:	6442                	ld	s0,16(sp)
    800031a2:	64a2                	ld	s1,8(sp)
    800031a4:	6902                	ld	s2,0(sp)
    800031a6:	6105                	addi	sp,sp,32
    800031a8:	8082                	ret

00000000800031aa <idup>:
{
    800031aa:	1101                	addi	sp,sp,-32
    800031ac:	ec06                	sd	ra,24(sp)
    800031ae:	e822                	sd	s0,16(sp)
    800031b0:	e426                	sd	s1,8(sp)
    800031b2:	1000                	addi	s0,sp,32
    800031b4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800031b6:	0001b517          	auipc	a0,0x1b
    800031ba:	cda50513          	addi	a0,a0,-806 # 8001de90 <itable>
    800031be:	a7bfd0ef          	jal	80000c38 <acquire>
  ip->ref++;
    800031c2:	449c                	lw	a5,8(s1)
    800031c4:	2785                	addiw	a5,a5,1
    800031c6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800031c8:	0001b517          	auipc	a0,0x1b
    800031cc:	cc850513          	addi	a0,a0,-824 # 8001de90 <itable>
    800031d0:	af9fd0ef          	jal	80000cc8 <release>
}
    800031d4:	8526                	mv	a0,s1
    800031d6:	60e2                	ld	ra,24(sp)
    800031d8:	6442                	ld	s0,16(sp)
    800031da:	64a2                	ld	s1,8(sp)
    800031dc:	6105                	addi	sp,sp,32
    800031de:	8082                	ret

00000000800031e0 <ilock>:
{
    800031e0:	1101                	addi	sp,sp,-32
    800031e2:	ec06                	sd	ra,24(sp)
    800031e4:	e822                	sd	s0,16(sp)
    800031e6:	e426                	sd	s1,8(sp)
    800031e8:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800031ea:	cd19                	beqz	a0,80003208 <ilock+0x28>
    800031ec:	84aa                	mv	s1,a0
    800031ee:	451c                	lw	a5,8(a0)
    800031f0:	00f05c63          	blez	a5,80003208 <ilock+0x28>
  acquiresleep(&ip->lock);
    800031f4:	0541                	addi	a0,a0,16
    800031f6:	491000ef          	jal	80003e86 <acquiresleep>
  if(ip->valid == 0){
    800031fa:	40bc                	lw	a5,64(s1)
    800031fc:	cf89                	beqz	a5,80003216 <ilock+0x36>
}
    800031fe:	60e2                	ld	ra,24(sp)
    80003200:	6442                	ld	s0,16(sp)
    80003202:	64a2                	ld	s1,8(sp)
    80003204:	6105                	addi	sp,sp,32
    80003206:	8082                	ret
    80003208:	e04a                	sd	s2,0(sp)
    panic("ilock");
    8000320a:	00004517          	auipc	a0,0x4
    8000320e:	23e50513          	addi	a0,a0,574 # 80007448 <etext+0x448>
    80003212:	e26fd0ef          	jal	80000838 <panic>
    80003216:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003218:	40dc                	lw	a5,4(s1)
    8000321a:	0047d79b          	srliw	a5,a5,0x4
    8000321e:	0001b597          	auipc	a1,0x1b
    80003222:	c6a5a583          	lw	a1,-918(a1) # 8001de88 <sb+0x18>
    80003226:	9dbd                	addw	a1,a1,a5
    80003228:	4088                	lw	a0,0(s1)
    8000322a:	917ff0ef          	jal	80002b40 <bread>
    8000322e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003230:	05850593          	addi	a1,a0,88
    80003234:	40dc                	lw	a5,4(s1)
    80003236:	8bbd                	andi	a5,a5,15
    80003238:	079a                	slli	a5,a5,0x6
    8000323a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000323c:	00059783          	lh	a5,0(a1)
    80003240:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003244:	00259783          	lh	a5,2(a1)
    80003248:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000324c:	00459783          	lh	a5,4(a1)
    80003250:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003254:	00659783          	lh	a5,6(a1)
    80003258:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000325c:	459c                	lw	a5,8(a1)
    8000325e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003260:	03400613          	li	a2,52
    80003264:	05b1                	addi	a1,a1,12
    80003266:	05048513          	addi	a0,s1,80
    8000326a:	af7fd0ef          	jal	80000d60 <memmove>
    brelse(bp);
    8000326e:	854a                	mv	a0,s2
    80003270:	9d9ff0ef          	jal	80002c48 <brelse>
    ip->valid = 1;
    80003274:	4785                	li	a5,1
    80003276:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003278:	04449783          	lh	a5,68(s1)
    8000327c:	c399                	beqz	a5,80003282 <ilock+0xa2>
    8000327e:	6902                	ld	s2,0(sp)
    80003280:	bfbd                	j	800031fe <ilock+0x1e>
      panic("ilock: no type");
    80003282:	00004517          	auipc	a0,0x4
    80003286:	1ce50513          	addi	a0,a0,462 # 80007450 <etext+0x450>
    8000328a:	daefd0ef          	jal	80000838 <panic>

000000008000328e <iunlock>:
{
    8000328e:	1101                	addi	sp,sp,-32
    80003290:	ec06                	sd	ra,24(sp)
    80003292:	e822                	sd	s0,16(sp)
    80003294:	e426                	sd	s1,8(sp)
    80003296:	e04a                	sd	s2,0(sp)
    80003298:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000329a:	c505                	beqz	a0,800032c2 <iunlock+0x34>
    8000329c:	84aa                	mv	s1,a0
    8000329e:	01050913          	addi	s2,a0,16
    800032a2:	854a                	mv	a0,s2
    800032a4:	461000ef          	jal	80003f04 <holdingsleep>
    800032a8:	cd09                	beqz	a0,800032c2 <iunlock+0x34>
    800032aa:	449c                	lw	a5,8(s1)
    800032ac:	00f05b63          	blez	a5,800032c2 <iunlock+0x34>
  releasesleep(&ip->lock);
    800032b0:	854a                	mv	a0,s2
    800032b2:	41b000ef          	jal	80003ecc <releasesleep>
}
    800032b6:	60e2                	ld	ra,24(sp)
    800032b8:	6442                	ld	s0,16(sp)
    800032ba:	64a2                	ld	s1,8(sp)
    800032bc:	6902                	ld	s2,0(sp)
    800032be:	6105                	addi	sp,sp,32
    800032c0:	8082                	ret
    panic("iunlock");
    800032c2:	00004517          	auipc	a0,0x4
    800032c6:	19e50513          	addi	a0,a0,414 # 80007460 <etext+0x460>
    800032ca:	d6efd0ef          	jal	80000838 <panic>

00000000800032ce <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800032ce:	7179                	addi	sp,sp,-48
    800032d0:	f406                	sd	ra,40(sp)
    800032d2:	f022                	sd	s0,32(sp)
    800032d4:	ec26                	sd	s1,24(sp)
    800032d6:	e84a                	sd	s2,16(sp)
    800032d8:	e44e                	sd	s3,8(sp)
    800032da:	1800                	addi	s0,sp,48
    800032dc:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800032de:	05050493          	addi	s1,a0,80
    800032e2:	08050913          	addi	s2,a0,128
    800032e6:	a021                	j	800032ee <itrunc+0x20>
    800032e8:	0491                	addi	s1,s1,4
    800032ea:	01248b63          	beq	s1,s2,80003300 <itrunc+0x32>
    if(ip->addrs[i]){
    800032ee:	408c                	lw	a1,0(s1)
    800032f0:	dde5                	beqz	a1,800032e8 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800032f2:	0009a503          	lw	a0,0(s3)
    800032f6:	a3fff0ef          	jal	80002d34 <bfree>
      ip->addrs[i] = 0;
    800032fa:	0004a023          	sw	zero,0(s1)
    800032fe:	b7ed                	j	800032e8 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003300:	0809a583          	lw	a1,128(s3)
    80003304:	ed89                	bnez	a1,8000331e <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003306:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000330a:	854e                	mv	a0,s3
    8000330c:	e21ff0ef          	jal	8000312c <iupdate>
}
    80003310:	70a2                	ld	ra,40(sp)
    80003312:	7402                	ld	s0,32(sp)
    80003314:	64e2                	ld	s1,24(sp)
    80003316:	6942                	ld	s2,16(sp)
    80003318:	69a2                	ld	s3,8(sp)
    8000331a:	6145                	addi	sp,sp,48
    8000331c:	8082                	ret
    8000331e:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003320:	0009a503          	lw	a0,0(s3)
    80003324:	81dff0ef          	jal	80002b40 <bread>
    80003328:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000332a:	05850493          	addi	s1,a0,88
    8000332e:	45850913          	addi	s2,a0,1112
    80003332:	a021                	j	8000333a <itrunc+0x6c>
    80003334:	0491                	addi	s1,s1,4
    80003336:	01248963          	beq	s1,s2,80003348 <itrunc+0x7a>
      if(a[j])
    8000333a:	408c                	lw	a1,0(s1)
    8000333c:	dde5                	beqz	a1,80003334 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000333e:	0009a503          	lw	a0,0(s3)
    80003342:	9f3ff0ef          	jal	80002d34 <bfree>
    80003346:	b7fd                	j	80003334 <itrunc+0x66>
    brelse(bp);
    80003348:	8552                	mv	a0,s4
    8000334a:	8ffff0ef          	jal	80002c48 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000334e:	0809a583          	lw	a1,128(s3)
    80003352:	0009a503          	lw	a0,0(s3)
    80003356:	9dfff0ef          	jal	80002d34 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000335a:	0809a023          	sw	zero,128(s3)
    8000335e:	6a02                	ld	s4,0(sp)
    80003360:	b75d                	j	80003306 <itrunc+0x38>

0000000080003362 <iput>:
{
    80003362:	1101                	addi	sp,sp,-32
    80003364:	ec06                	sd	ra,24(sp)
    80003366:	e822                	sd	s0,16(sp)
    80003368:	e426                	sd	s1,8(sp)
    8000336a:	1000                	addi	s0,sp,32
    8000336c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000336e:	0001b517          	auipc	a0,0x1b
    80003372:	b2250513          	addi	a0,a0,-1246 # 8001de90 <itable>
    80003376:	8c3fd0ef          	jal	80000c38 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000337a:	4498                	lw	a4,8(s1)
    8000337c:	4785                	li	a5,1
    8000337e:	02f70063          	beq	a4,a5,8000339e <iput+0x3c>
  ip->ref--;
    80003382:	449c                	lw	a5,8(s1)
    80003384:	37fd                	addiw	a5,a5,-1
    80003386:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003388:	0001b517          	auipc	a0,0x1b
    8000338c:	b0850513          	addi	a0,a0,-1272 # 8001de90 <itable>
    80003390:	939fd0ef          	jal	80000cc8 <release>
}
    80003394:	60e2                	ld	ra,24(sp)
    80003396:	6442                	ld	s0,16(sp)
    80003398:	64a2                	ld	s1,8(sp)
    8000339a:	6105                	addi	sp,sp,32
    8000339c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000339e:	40bc                	lw	a5,64(s1)
    800033a0:	d3ed                	beqz	a5,80003382 <iput+0x20>
    800033a2:	04a49783          	lh	a5,74(s1)
    800033a6:	fff1                	bnez	a5,80003382 <iput+0x20>
    800033a8:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800033aa:	01048793          	addi	a5,s1,16
    800033ae:	893e                	mv	s2,a5
    800033b0:	853e                	mv	a0,a5
    800033b2:	2d5000ef          	jal	80003e86 <acquiresleep>
    release(&itable.lock);
    800033b6:	0001b517          	auipc	a0,0x1b
    800033ba:	ada50513          	addi	a0,a0,-1318 # 8001de90 <itable>
    800033be:	90bfd0ef          	jal	80000cc8 <release>
    itrunc(ip);
    800033c2:	8526                	mv	a0,s1
    800033c4:	f0bff0ef          	jal	800032ce <itrunc>
    ip->type = 0;
    800033c8:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800033cc:	8526                	mv	a0,s1
    800033ce:	d5fff0ef          	jal	8000312c <iupdate>
    ip->valid = 0;
    800033d2:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800033d6:	854a                	mv	a0,s2
    800033d8:	2f5000ef          	jal	80003ecc <releasesleep>
    acquire(&itable.lock);
    800033dc:	0001b517          	auipc	a0,0x1b
    800033e0:	ab450513          	addi	a0,a0,-1356 # 8001de90 <itable>
    800033e4:	855fd0ef          	jal	80000c38 <acquire>
    800033e8:	6902                	ld	s2,0(sp)
    800033ea:	bf61                	j	80003382 <iput+0x20>

00000000800033ec <iunlockput>:
{
    800033ec:	1101                	addi	sp,sp,-32
    800033ee:	ec06                	sd	ra,24(sp)
    800033f0:	e822                	sd	s0,16(sp)
    800033f2:	e426                	sd	s1,8(sp)
    800033f4:	1000                	addi	s0,sp,32
    800033f6:	84aa                	mv	s1,a0
  iunlock(ip);
    800033f8:	e97ff0ef          	jal	8000328e <iunlock>
  iput(ip);
    800033fc:	8526                	mv	a0,s1
    800033fe:	f65ff0ef          	jal	80003362 <iput>
}
    80003402:	60e2                	ld	ra,24(sp)
    80003404:	6442                	ld	s0,16(sp)
    80003406:	64a2                	ld	s1,8(sp)
    80003408:	6105                	addi	sp,sp,32
    8000340a:	8082                	ret

000000008000340c <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000340c:	0001b717          	auipc	a4,0x1b
    80003410:	a7072703          	lw	a4,-1424(a4) # 8001de7c <sb+0xc>
    80003414:	4785                	li	a5,1
    80003416:	0ae7fe63          	bgeu	a5,a4,800034d2 <ireclaim+0xc6>
{
    8000341a:	7139                	addi	sp,sp,-64
    8000341c:	fc06                	sd	ra,56(sp)
    8000341e:	f822                	sd	s0,48(sp)
    80003420:	f426                	sd	s1,40(sp)
    80003422:	f04a                	sd	s2,32(sp)
    80003424:	ec4e                	sd	s3,24(sp)
    80003426:	e852                	sd	s4,16(sp)
    80003428:	e456                	sd	s5,8(sp)
    8000342a:	e05a                	sd	s6,0(sp)
    8000342c:	0080                	addi	s0,sp,64
    8000342e:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003430:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003432:	0001ba17          	auipc	s4,0x1b
    80003436:	a3ea0a13          	addi	s4,s4,-1474 # 8001de70 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    8000343a:	00004b17          	auipc	s6,0x4
    8000343e:	02eb0b13          	addi	s6,s6,46 # 80007468 <etext+0x468>
    80003442:	a099                	j	80003488 <ireclaim+0x7c>
    80003444:	85ce                	mv	a1,s3
    80003446:	855a                	mv	a0,s6
    80003448:	8b8fd0ef          	jal	80000500 <printf>
      ip = iget(dev, inum);
    8000344c:	85ce                	mv	a1,s3
    8000344e:	8556                	mv	a0,s5
    80003450:	b17ff0ef          	jal	80002f66 <iget>
    80003454:	89aa                	mv	s3,a0
    brelse(bp);
    80003456:	854a                	mv	a0,s2
    80003458:	ff0ff0ef          	jal	80002c48 <brelse>
    if (ip) {
    8000345c:	00098f63          	beqz	s3,8000347a <ireclaim+0x6e>
      begin_op();
    80003460:	796000ef          	jal	80003bf6 <begin_op>
      ilock(ip);
    80003464:	854e                	mv	a0,s3
    80003466:	d7bff0ef          	jal	800031e0 <ilock>
      iunlock(ip);
    8000346a:	854e                	mv	a0,s3
    8000346c:	e23ff0ef          	jal	8000328e <iunlock>
      iput(ip);
    80003470:	854e                	mv	a0,s3
    80003472:	ef1ff0ef          	jal	80003362 <iput>
      end_op();
    80003476:	7f0000ef          	jal	80003c66 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000347a:	0485                	addi	s1,s1,1
    8000347c:	00ca2703          	lw	a4,12(s4)
    80003480:	0004879b          	sext.w	a5,s1
    80003484:	02e7fd63          	bgeu	a5,a4,800034be <ireclaim+0xb2>
    80003488:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000348c:	0044d593          	srli	a1,s1,0x4
    80003490:	018a2783          	lw	a5,24(s4)
    80003494:	9dbd                	addw	a1,a1,a5
    80003496:	8556                	mv	a0,s5
    80003498:	ea8ff0ef          	jal	80002b40 <bread>
    8000349c:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    8000349e:	05850793          	addi	a5,a0,88
    800034a2:	00f9f713          	andi	a4,s3,15
    800034a6:	071a                	slli	a4,a4,0x6
    800034a8:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    800034aa:	00079703          	lh	a4,0(a5)
    800034ae:	c701                	beqz	a4,800034b6 <ireclaim+0xaa>
    800034b0:	00679783          	lh	a5,6(a5)
    800034b4:	dbc1                	beqz	a5,80003444 <ireclaim+0x38>
    brelse(bp);
    800034b6:	854a                	mv	a0,s2
    800034b8:	f90ff0ef          	jal	80002c48 <brelse>
    if (ip) {
    800034bc:	bf7d                	j	8000347a <ireclaim+0x6e>
}
    800034be:	70e2                	ld	ra,56(sp)
    800034c0:	7442                	ld	s0,48(sp)
    800034c2:	74a2                	ld	s1,40(sp)
    800034c4:	7902                	ld	s2,32(sp)
    800034c6:	69e2                	ld	s3,24(sp)
    800034c8:	6a42                	ld	s4,16(sp)
    800034ca:	6aa2                	ld	s5,8(sp)
    800034cc:	6b02                	ld	s6,0(sp)
    800034ce:	6121                	addi	sp,sp,64
    800034d0:	8082                	ret
    800034d2:	8082                	ret

00000000800034d4 <fsinit>:
fsinit(int dev) {
    800034d4:	1101                	addi	sp,sp,-32
    800034d6:	ec06                	sd	ra,24(sp)
    800034d8:	e822                	sd	s0,16(sp)
    800034da:	e426                	sd	s1,8(sp)
    800034dc:	e04a                	sd	s2,0(sp)
    800034de:	1000                	addi	s0,sp,32
    800034e0:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800034e2:	4585                	li	a1,1
    800034e4:	e5cff0ef          	jal	80002b40 <bread>
    800034e8:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800034ea:	02000613          	li	a2,32
    800034ee:	05850593          	addi	a1,a0,88
    800034f2:	0001b517          	auipc	a0,0x1b
    800034f6:	97e50513          	addi	a0,a0,-1666 # 8001de70 <sb>
    800034fa:	867fd0ef          	jal	80000d60 <memmove>
  brelse(bp);
    800034fe:	8526                	mv	a0,s1
    80003500:	f48ff0ef          	jal	80002c48 <brelse>
  if(sb.magic != FSMAGIC)
    80003504:	0001b717          	auipc	a4,0x1b
    80003508:	96c72703          	lw	a4,-1684(a4) # 8001de70 <sb>
    8000350c:	102037b7          	lui	a5,0x10203
    80003510:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003514:	02f71263          	bne	a4,a5,80003538 <fsinit+0x64>
  initlog(dev, &sb);
    80003518:	0001b597          	auipc	a1,0x1b
    8000351c:	95858593          	addi	a1,a1,-1704 # 8001de70 <sb>
    80003520:	854a                	mv	a0,s2
    80003522:	652000ef          	jal	80003b74 <initlog>
  ireclaim(dev);
    80003526:	854a                	mv	a0,s2
    80003528:	ee5ff0ef          	jal	8000340c <ireclaim>
}
    8000352c:	60e2                	ld	ra,24(sp)
    8000352e:	6442                	ld	s0,16(sp)
    80003530:	64a2                	ld	s1,8(sp)
    80003532:	6902                	ld	s2,0(sp)
    80003534:	6105                	addi	sp,sp,32
    80003536:	8082                	ret
    panic("invalid file system");
    80003538:	00004517          	auipc	a0,0x4
    8000353c:	f5050513          	addi	a0,a0,-176 # 80007488 <etext+0x488>
    80003540:	af8fd0ef          	jal	80000838 <panic>

0000000080003544 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003544:	1141                	addi	sp,sp,-16
    80003546:	e406                	sd	ra,8(sp)
    80003548:	e022                	sd	s0,0(sp)
    8000354a:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000354c:	411c                	lw	a5,0(a0)
    8000354e:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003550:	415c                	lw	a5,4(a0)
    80003552:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003554:	04451783          	lh	a5,68(a0)
    80003558:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000355c:	04a51783          	lh	a5,74(a0)
    80003560:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003564:	04c56783          	lwu	a5,76(a0)
    80003568:	e99c                	sd	a5,16(a1)
}
    8000356a:	60a2                	ld	ra,8(sp)
    8000356c:	6402                	ld	s0,0(sp)
    8000356e:	0141                	addi	sp,sp,16
    80003570:	8082                	ret

0000000080003572 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003572:	457c                	lw	a5,76(a0)
    80003574:	0ed7e663          	bltu	a5,a3,80003660 <readi+0xee>
{
    80003578:	7159                	addi	sp,sp,-112
    8000357a:	f486                	sd	ra,104(sp)
    8000357c:	f0a2                	sd	s0,96(sp)
    8000357e:	eca6                	sd	s1,88(sp)
    80003580:	e0d2                	sd	s4,64(sp)
    80003582:	fc56                	sd	s5,56(sp)
    80003584:	f85a                	sd	s6,48(sp)
    80003586:	f45e                	sd	s7,40(sp)
    80003588:	1880                	addi	s0,sp,112
    8000358a:	8b2a                	mv	s6,a0
    8000358c:	8bae                	mv	s7,a1
    8000358e:	8a32                	mv	s4,a2
    80003590:	84b6                	mv	s1,a3
    80003592:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003594:	9f35                	addw	a4,a4,a3
    return 0;
    80003596:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003598:	0ad76b63          	bltu	a4,a3,8000364e <readi+0xdc>
    8000359c:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    8000359e:	00e7f463          	bgeu	a5,a4,800035a6 <readi+0x34>
    n = ip->size - off;
    800035a2:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800035a6:	080a8b63          	beqz	s5,8000363c <readi+0xca>
    800035aa:	e8ca                	sd	s2,80(sp)
    800035ac:	f062                	sd	s8,32(sp)
    800035ae:	ec66                	sd	s9,24(sp)
    800035b0:	e86a                	sd	s10,16(sp)
    800035b2:	e46e                	sd	s11,8(sp)
    800035b4:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800035b6:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800035ba:	5c7d                	li	s8,-1
    800035bc:	a80d                	j	800035ee <readi+0x7c>
    800035be:	020d1d93          	slli	s11,s10,0x20
    800035c2:	020ddd93          	srli	s11,s11,0x20
    800035c6:	05890613          	addi	a2,s2,88
    800035ca:	86ee                	mv	a3,s11
    800035cc:	963e                	add	a2,a2,a5
    800035ce:	85d2                	mv	a1,s4
    800035d0:	855e                	mv	a0,s7
    800035d2:	c83fe0ef          	jal	80002254 <either_copyout>
    800035d6:	05850363          	beq	a0,s8,8000361c <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800035da:	854a                	mv	a0,s2
    800035dc:	e6cff0ef          	jal	80002c48 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800035e0:	013d09bb          	addw	s3,s10,s3
    800035e4:	009d04bb          	addw	s1,s10,s1
    800035e8:	9a6e                	add	s4,s4,s11
    800035ea:	0559f363          	bgeu	s3,s5,80003630 <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800035ee:	00a4d59b          	srliw	a1,s1,0xa
    800035f2:	855a                	mv	a0,s6
    800035f4:	8b3ff0ef          	jal	80002ea6 <bmap>
    800035f8:	85aa                	mv	a1,a0
    if(addr == 0)
    800035fa:	c139                	beqz	a0,80003640 <readi+0xce>
    bp = bread(ip->dev, addr);
    800035fc:	000b2503          	lw	a0,0(s6)
    80003600:	d40ff0ef          	jal	80002b40 <bread>
    80003604:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003606:	3ff4f793          	andi	a5,s1,1023
    8000360a:	40fc873b          	subw	a4,s9,a5
    8000360e:	413a86bb          	subw	a3,s5,s3
    80003612:	8d3a                	mv	s10,a4
    80003614:	fae6f5e3          	bgeu	a3,a4,800035be <readi+0x4c>
    80003618:	8d36                	mv	s10,a3
    8000361a:	b755                	j	800035be <readi+0x4c>
      brelse(bp);
    8000361c:	854a                	mv	a0,s2
    8000361e:	e2aff0ef          	jal	80002c48 <brelse>
      tot = -1;
    80003622:	59fd                	li	s3,-1
      break;
    80003624:	6946                	ld	s2,80(sp)
    80003626:	7c02                	ld	s8,32(sp)
    80003628:	6ce2                	ld	s9,24(sp)
    8000362a:	6d42                	ld	s10,16(sp)
    8000362c:	6da2                	ld	s11,8(sp)
    8000362e:	a831                	j	8000364a <readi+0xd8>
    80003630:	6946                	ld	s2,80(sp)
    80003632:	7c02                	ld	s8,32(sp)
    80003634:	6ce2                	ld	s9,24(sp)
    80003636:	6d42                	ld	s10,16(sp)
    80003638:	6da2                	ld	s11,8(sp)
    8000363a:	a801                	j	8000364a <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000363c:	89d6                	mv	s3,s5
    8000363e:	a031                	j	8000364a <readi+0xd8>
    80003640:	6946                	ld	s2,80(sp)
    80003642:	7c02                	ld	s8,32(sp)
    80003644:	6ce2                	ld	s9,24(sp)
    80003646:	6d42                	ld	s10,16(sp)
    80003648:	6da2                	ld	s11,8(sp)
  }
  return tot;
    8000364a:	854e                	mv	a0,s3
    8000364c:	69a6                	ld	s3,72(sp)
}
    8000364e:	70a6                	ld	ra,104(sp)
    80003650:	7406                	ld	s0,96(sp)
    80003652:	64e6                	ld	s1,88(sp)
    80003654:	6a06                	ld	s4,64(sp)
    80003656:	7ae2                	ld	s5,56(sp)
    80003658:	7b42                	ld	s6,48(sp)
    8000365a:	7ba2                	ld	s7,40(sp)
    8000365c:	6165                	addi	sp,sp,112
    8000365e:	8082                	ret
    return 0;
    80003660:	4501                	li	a0,0
}
    80003662:	8082                	ret

0000000080003664 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003664:	457c                	lw	a5,76(a0)
    80003666:	0ed7ee63          	bltu	a5,a3,80003762 <writei+0xfe>
{
    8000366a:	7159                	addi	sp,sp,-112
    8000366c:	f486                	sd	ra,104(sp)
    8000366e:	f0a2                	sd	s0,96(sp)
    80003670:	e8ca                	sd	s2,80(sp)
    80003672:	e0d2                	sd	s4,64(sp)
    80003674:	fc56                	sd	s5,56(sp)
    80003676:	f85a                	sd	s6,48(sp)
    80003678:	f45e                	sd	s7,40(sp)
    8000367a:	1880                	addi	s0,sp,112
    8000367c:	8aaa                	mv	s5,a0
    8000367e:	8bae                	mv	s7,a1
    80003680:	8a32                	mv	s4,a2
    80003682:	8936                	mv	s2,a3
    80003684:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003686:	9f35                	addw	a4,a4,a3
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003688:	000437b7          	lui	a5,0x43
    8000368c:	00e7b7b3          	sltu	a5,a5,a4
  if(off > ip->size || off + n < off)
    80003690:	00d73733          	sltu	a4,a4,a3
  if(off + n > MAXFILE*BSIZE)
    80003694:	8fd9                	or	a5,a5,a4
    80003696:	ef91                	bnez	a5,800036b2 <writei+0x4e>
    80003698:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000369a:	0a0b0c63          	beqz	s6,80003752 <writei+0xee>
    8000369e:	eca6                	sd	s1,88(sp)
    800036a0:	f062                	sd	s8,32(sp)
    800036a2:	ec66                	sd	s9,24(sp)
    800036a4:	e86a                	sd	s10,16(sp)
    800036a6:	e46e                	sd	s11,8(sp)
    800036a8:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800036aa:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800036ae:	5c7d                	li	s8,-1
    800036b0:	a835                	j	800036ec <writei+0x88>
    return -1;
    800036b2:	557d                	li	a0,-1
    800036b4:	a071                	j	80003740 <writei+0xdc>
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800036b6:	020d1d93          	slli	s11,s10,0x20
    800036ba:	020ddd93          	srli	s11,s11,0x20
    800036be:	05848513          	addi	a0,s1,88
    800036c2:	86ee                	mv	a3,s11
    800036c4:	8652                	mv	a2,s4
    800036c6:	85de                	mv	a1,s7
    800036c8:	953e                	add	a0,a0,a5
    800036ca:	bd5fe0ef          	jal	8000229e <either_copyin>
    800036ce:	05850663          	beq	a0,s8,8000371a <writei+0xb6>
      brelse(bp);
      break;
    }
    log_write(bp);
    800036d2:	8526                	mv	a0,s1
    800036d4:	6bc000ef          	jal	80003d90 <log_write>
    brelse(bp);
    800036d8:	8526                	mv	a0,s1
    800036da:	d6eff0ef          	jal	80002c48 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800036de:	013d09bb          	addw	s3,s10,s3
    800036e2:	012d093b          	addw	s2,s10,s2
    800036e6:	9a6e                	add	s4,s4,s11
    800036e8:	0369fc63          	bgeu	s3,s6,80003720 <writei+0xbc>
    uint addr = bmap(ip, off/BSIZE);
    800036ec:	00a9559b          	srliw	a1,s2,0xa
    800036f0:	8556                	mv	a0,s5
    800036f2:	fb4ff0ef          	jal	80002ea6 <bmap>
    800036f6:	85aa                	mv	a1,a0
    if(addr == 0)
    800036f8:	c505                	beqz	a0,80003720 <writei+0xbc>
    bp = bread(ip->dev, addr);
    800036fa:	000aa503          	lw	a0,0(s5)
    800036fe:	c42ff0ef          	jal	80002b40 <bread>
    80003702:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003704:	3ff97793          	andi	a5,s2,1023
    80003708:	40fc873b          	subw	a4,s9,a5
    8000370c:	413b06bb          	subw	a3,s6,s3
    80003710:	8d3a                	mv	s10,a4
    80003712:	fae6f2e3          	bgeu	a3,a4,800036b6 <writei+0x52>
    80003716:	8d36                	mv	s10,a3
    80003718:	bf79                	j	800036b6 <writei+0x52>
      brelse(bp);
    8000371a:	8526                	mv	a0,s1
    8000371c:	d2cff0ef          	jal	80002c48 <brelse>
  }

  if(off > ip->size)
    80003720:	04caa783          	lw	a5,76(s5)
    80003724:	0327f963          	bgeu	a5,s2,80003756 <writei+0xf2>
    ip->size = off;
    80003728:	052aa623          	sw	s2,76(s5)
    8000372c:	64e6                	ld	s1,88(sp)
    8000372e:	7c02                	ld	s8,32(sp)
    80003730:	6ce2                	ld	s9,24(sp)
    80003732:	6d42                	ld	s10,16(sp)
    80003734:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003736:	8556                	mv	a0,s5
    80003738:	9f5ff0ef          	jal	8000312c <iupdate>

  return tot;
    8000373c:	854e                	mv	a0,s3
    8000373e:	69a6                	ld	s3,72(sp)
}
    80003740:	70a6                	ld	ra,104(sp)
    80003742:	7406                	ld	s0,96(sp)
    80003744:	6946                	ld	s2,80(sp)
    80003746:	6a06                	ld	s4,64(sp)
    80003748:	7ae2                	ld	s5,56(sp)
    8000374a:	7b42                	ld	s6,48(sp)
    8000374c:	7ba2                	ld	s7,40(sp)
    8000374e:	6165                	addi	sp,sp,112
    80003750:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003752:	89da                	mv	s3,s6
    80003754:	b7cd                	j	80003736 <writei+0xd2>
    80003756:	64e6                	ld	s1,88(sp)
    80003758:	7c02                	ld	s8,32(sp)
    8000375a:	6ce2                	ld	s9,24(sp)
    8000375c:	6d42                	ld	s10,16(sp)
    8000375e:	6da2                	ld	s11,8(sp)
    80003760:	bfd9                	j	80003736 <writei+0xd2>
    return -1;
    80003762:	557d                	li	a0,-1
}
    80003764:	8082                	ret

0000000080003766 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003766:	1141                	addi	sp,sp,-16
    80003768:	e406                	sd	ra,8(sp)
    8000376a:	e022                	sd	s0,0(sp)
    8000376c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000376e:	4639                	li	a2,14
    80003770:	e64fd0ef          	jal	80000dd4 <strncmp>
}
    80003774:	60a2                	ld	ra,8(sp)
    80003776:	6402                	ld	s0,0(sp)
    80003778:	0141                	addi	sp,sp,16
    8000377a:	8082                	ret

000000008000377c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000377c:	711d                	addi	sp,sp,-96
    8000377e:	ec86                	sd	ra,88(sp)
    80003780:	e8a2                	sd	s0,80(sp)
    80003782:	e4a6                	sd	s1,72(sp)
    80003784:	e0ca                	sd	s2,64(sp)
    80003786:	fc4e                	sd	s3,56(sp)
    80003788:	f852                	sd	s4,48(sp)
    8000378a:	f456                	sd	s5,40(sp)
    8000378c:	f05a                	sd	s6,32(sp)
    8000378e:	ec5e                	sd	s7,24(sp)
    80003790:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003792:	04451703          	lh	a4,68(a0)
    80003796:	4785                	li	a5,1
    80003798:	02f71963          	bne	a4,a5,800037ca <dirlookup+0x4e>
    8000379c:	892a                	mv	s2,a0
    8000379e:	8aae                	mv	s5,a1
    800037a0:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800037a2:	457c                	lw	a5,76(a0)
    800037a4:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800037a6:	fa040a13          	addi	s4,s0,-96
    800037aa:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    800037ac:	fa240b13          	addi	s6,s0,-94
  for(off = 0; off < dp->size; off += sizeof(de)){
    800037b0:	ef95                	bnez	a5,800037ec <dirlookup+0x70>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800037b2:	4501                	li	a0,0
}
    800037b4:	60e6                	ld	ra,88(sp)
    800037b6:	6446                	ld	s0,80(sp)
    800037b8:	64a6                	ld	s1,72(sp)
    800037ba:	6906                	ld	s2,64(sp)
    800037bc:	79e2                	ld	s3,56(sp)
    800037be:	7a42                	ld	s4,48(sp)
    800037c0:	7aa2                	ld	s5,40(sp)
    800037c2:	7b02                	ld	s6,32(sp)
    800037c4:	6be2                	ld	s7,24(sp)
    800037c6:	6125                	addi	sp,sp,96
    800037c8:	8082                	ret
    panic("dirlookup not DIR");
    800037ca:	00004517          	auipc	a0,0x4
    800037ce:	cd650513          	addi	a0,a0,-810 # 800074a0 <etext+0x4a0>
    800037d2:	866fd0ef          	jal	80000838 <panic>
      panic("dirlookup read");
    800037d6:	00004517          	auipc	a0,0x4
    800037da:	ce250513          	addi	a0,a0,-798 # 800074b8 <etext+0x4b8>
    800037de:	85afd0ef          	jal	80000838 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800037e2:	24c1                	addiw	s1,s1,16
    800037e4:	04c92783          	lw	a5,76(s2)
    800037e8:	fcf4f5e3          	bgeu	s1,a5,800037b2 <dirlookup+0x36>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800037ec:	874e                	mv	a4,s3
    800037ee:	86a6                	mv	a3,s1
    800037f0:	8652                	mv	a2,s4
    800037f2:	4581                	li	a1,0
    800037f4:	854a                	mv	a0,s2
    800037f6:	d7dff0ef          	jal	80003572 <readi>
    800037fa:	fd351ee3          	bne	a0,s3,800037d6 <dirlookup+0x5a>
    if(de.inum == 0)
    800037fe:	fa045783          	lhu	a5,-96(s0)
    80003802:	d3e5                	beqz	a5,800037e2 <dirlookup+0x66>
    if(namecmp(name, de.name) == 0){
    80003804:	85da                	mv	a1,s6
    80003806:	8556                	mv	a0,s5
    80003808:	f5fff0ef          	jal	80003766 <namecmp>
    8000380c:	f979                	bnez	a0,800037e2 <dirlookup+0x66>
      if(poff)
    8000380e:	000b8463          	beqz	s7,80003816 <dirlookup+0x9a>
        *poff = off;
    80003812:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003816:	fa045583          	lhu	a1,-96(s0)
    8000381a:	00092503          	lw	a0,0(s2)
    8000381e:	f48ff0ef          	jal	80002f66 <iget>
    80003822:	bf49                	j	800037b4 <dirlookup+0x38>

0000000080003824 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003824:	711d                	addi	sp,sp,-96
    80003826:	ec86                	sd	ra,88(sp)
    80003828:	e8a2                	sd	s0,80(sp)
    8000382a:	e4a6                	sd	s1,72(sp)
    8000382c:	e0ca                	sd	s2,64(sp)
    8000382e:	fc4e                	sd	s3,56(sp)
    80003830:	f852                	sd	s4,48(sp)
    80003832:	f456                	sd	s5,40(sp)
    80003834:	f05a                	sd	s6,32(sp)
    80003836:	ec5e                	sd	s7,24(sp)
    80003838:	e862                	sd	s8,16(sp)
    8000383a:	e466                	sd	s9,8(sp)
    8000383c:	e06a                	sd	s10,0(sp)
    8000383e:	1080                	addi	s0,sp,96
    80003840:	84aa                	mv	s1,a0
    80003842:	8b2e                	mv	s6,a1
    80003844:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003846:	00054703          	lbu	a4,0(a0)
    8000384a:	02f00793          	li	a5,47
    8000384e:	00f70f63          	beq	a4,a5,8000386c <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003852:	8b2fe0ef          	jal	80001904 <myproc>
    80003856:	15053503          	ld	a0,336(a0)
    8000385a:	951ff0ef          	jal	800031aa <idup>
    8000385e:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003860:	02f00993          	li	s3,47
  if(len >= DIRSIZ)
    80003864:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003866:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003868:	4b85                	li	s7,1
    8000386a:	a879                	j	80003908 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    8000386c:	4585                	li	a1,1
    8000386e:	852e                	mv	a0,a1
    80003870:	ef6ff0ef          	jal	80002f66 <iget>
    80003874:	8a2a                	mv	s4,a0
    80003876:	b7ed                	j	80003860 <namex+0x3c>
      iunlockput(ip);
    80003878:	8552                	mv	a0,s4
    8000387a:	b73ff0ef          	jal	800033ec <iunlockput>
      return 0;
    8000387e:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003880:	8552                	mv	a0,s4
    80003882:	60e6                	ld	ra,88(sp)
    80003884:	6446                	ld	s0,80(sp)
    80003886:	64a6                	ld	s1,72(sp)
    80003888:	6906                	ld	s2,64(sp)
    8000388a:	79e2                	ld	s3,56(sp)
    8000388c:	7a42                	ld	s4,48(sp)
    8000388e:	7aa2                	ld	s5,40(sp)
    80003890:	7b02                	ld	s6,32(sp)
    80003892:	6be2                	ld	s7,24(sp)
    80003894:	6c42                	ld	s8,16(sp)
    80003896:	6ca2                	ld	s9,8(sp)
    80003898:	6d02                	ld	s10,0(sp)
    8000389a:	6125                	addi	sp,sp,96
    8000389c:	8082                	ret
      iunlock(ip);
    8000389e:	8552                	mv	a0,s4
    800038a0:	9efff0ef          	jal	8000328e <iunlock>
      return ip;
    800038a4:	bff1                	j	80003880 <namex+0x5c>
      iunlockput(ip);
    800038a6:	8552                	mv	a0,s4
    800038a8:	b45ff0ef          	jal	800033ec <iunlockput>
      return 0;
    800038ac:	8a4a                	mv	s4,s2
    800038ae:	bfc9                	j	80003880 <namex+0x5c>
  while(*path != '/' && *path != 0)
    800038b0:	8926                	mv	s2,s1
  len = path - s;
    800038b2:	4d01                	li	s10,0
    800038b4:	4601                	li	a2,0
    memmove(name, s, len);
    800038b6:	2601                	sext.w	a2,a2
    800038b8:	85a6                	mv	a1,s1
    800038ba:	8556                	mv	a0,s5
    800038bc:	ca4fd0ef          	jal	80000d60 <memmove>
    name[len] = 0;
    800038c0:	9d56                	add	s10,s10,s5
    800038c2:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffde488>
    800038c6:	84ca                	mv	s1,s2
  while(*path == '/')
    800038c8:	0004c783          	lbu	a5,0(s1)
    800038cc:	01379763          	bne	a5,s3,800038da <namex+0xb6>
    path++;
    800038d0:	0485                	addi	s1,s1,1
  while(*path == '/')
    800038d2:	0004c783          	lbu	a5,0(s1)
    800038d6:	ff378de3          	beq	a5,s3,800038d0 <namex+0xac>
    ilock(ip);
    800038da:	8552                	mv	a0,s4
    800038dc:	905ff0ef          	jal	800031e0 <ilock>
    if(ip->type != T_DIR){
    800038e0:	044a1783          	lh	a5,68(s4)
    800038e4:	f9779ae3          	bne	a5,s7,80003878 <namex+0x54>
    if(nameiparent && *path == '\0'){
    800038e8:	000b0563          	beqz	s6,800038f2 <namex+0xce>
    800038ec:	0004c783          	lbu	a5,0(s1)
    800038f0:	d7dd                	beqz	a5,8000389e <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    800038f2:	4601                	li	a2,0
    800038f4:	85d6                	mv	a1,s5
    800038f6:	8552                	mv	a0,s4
    800038f8:	e85ff0ef          	jal	8000377c <dirlookup>
    800038fc:	892a                	mv	s2,a0
    800038fe:	d545                	beqz	a0,800038a6 <namex+0x82>
    iunlockput(ip);
    80003900:	8552                	mv	a0,s4
    80003902:	aebff0ef          	jal	800033ec <iunlockput>
    ip = next;
    80003906:	8a4a                	mv	s4,s2
  while(*path == '/')
    80003908:	0004c783          	lbu	a5,0(s1)
    8000390c:	01379763          	bne	a5,s3,8000391a <namex+0xf6>
    path++;
    80003910:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003912:	0004c783          	lbu	a5,0(s1)
    80003916:	ff378de3          	beq	a5,s3,80003910 <namex+0xec>
  if(*path == 0)
    8000391a:	c7a1                	beqz	a5,80003962 <namex+0x13e>
  while(*path != '/' && *path != 0)
    8000391c:	0004c703          	lbu	a4,0(s1)
    80003920:	fd170793          	addi	a5,a4,-47
    80003924:	00f037b3          	snez	a5,a5
    80003928:	00e03733          	snez	a4,a4
    8000392c:	8ff9                	and	a5,a5,a4
    8000392e:	d3c9                	beqz	a5,800038b0 <namex+0x8c>
    80003930:	8926                	mv	s2,s1
    path++;
    80003932:	0905                	addi	s2,s2,1
  while(*path != '/' && *path != 0)
    80003934:	00094703          	lbu	a4,0(s2)
    80003938:	fd170793          	addi	a5,a4,-47
    8000393c:	00f037b3          	snez	a5,a5
    80003940:	00e03733          	snez	a4,a4
    80003944:	8ff9                	and	a5,a5,a4
    80003946:	f7f5                	bnez	a5,80003932 <namex+0x10e>
  len = path - s;
    80003948:	40990633          	sub	a2,s2,s1
    8000394c:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003950:	f7ac53e3          	bge	s8,s10,800038b6 <namex+0x92>
    memmove(name, s, DIRSIZ);
    80003954:	8666                	mv	a2,s9
    80003956:	85a6                	mv	a1,s1
    80003958:	8556                	mv	a0,s5
    8000395a:	c06fd0ef          	jal	80000d60 <memmove>
    8000395e:	84ca                	mv	s1,s2
    80003960:	b7a5                	j	800038c8 <namex+0xa4>
  if(nameiparent){
    80003962:	f00b0fe3          	beqz	s6,80003880 <namex+0x5c>
    iput(ip);
    80003966:	8552                	mv	a0,s4
    80003968:	9fbff0ef          	jal	80003362 <iput>
    return 0;
    8000396c:	bf09                	j	8000387e <namex+0x5a>

000000008000396e <dirlink>:
{
    8000396e:	715d                	addi	sp,sp,-80
    80003970:	e486                	sd	ra,72(sp)
    80003972:	e0a2                	sd	s0,64(sp)
    80003974:	f84a                	sd	s2,48(sp)
    80003976:	ec56                	sd	s5,24(sp)
    80003978:	e85a                	sd	s6,16(sp)
    8000397a:	0880                	addi	s0,sp,80
    8000397c:	892a                	mv	s2,a0
    8000397e:	8aae                	mv	s5,a1
    80003980:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003982:	4601                	li	a2,0
    80003984:	df9ff0ef          	jal	8000377c <dirlookup>
    80003988:	ed1d                	bnez	a0,800039c6 <dirlink+0x58>
    8000398a:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000398c:	04c92483          	lw	s1,76(s2)
    80003990:	c4b9                	beqz	s1,800039de <dirlink+0x70>
    80003992:	f44e                	sd	s3,40(sp)
    80003994:	f052                	sd	s4,32(sp)
    80003996:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003998:	fb040a13          	addi	s4,s0,-80
    8000399c:	49c1                	li	s3,16
    8000399e:	874e                	mv	a4,s3
    800039a0:	86a6                	mv	a3,s1
    800039a2:	8652                	mv	a2,s4
    800039a4:	4581                	li	a1,0
    800039a6:	854a                	mv	a0,s2
    800039a8:	bcbff0ef          	jal	80003572 <readi>
    800039ac:	03351163          	bne	a0,s3,800039ce <dirlink+0x60>
    if(de.inum == 0)
    800039b0:	fb045783          	lhu	a5,-80(s0)
    800039b4:	c39d                	beqz	a5,800039da <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800039b6:	24c1                	addiw	s1,s1,16
    800039b8:	04c92783          	lw	a5,76(s2)
    800039bc:	fef4e1e3          	bltu	s1,a5,8000399e <dirlink+0x30>
    800039c0:	79a2                	ld	s3,40(sp)
    800039c2:	7a02                	ld	s4,32(sp)
    800039c4:	a829                	j	800039de <dirlink+0x70>
    iput(ip);
    800039c6:	99dff0ef          	jal	80003362 <iput>
    return -1;
    800039ca:	557d                	li	a0,-1
    800039cc:	a83d                	j	80003a0a <dirlink+0x9c>
      panic("dirlink read");
    800039ce:	00004517          	auipc	a0,0x4
    800039d2:	afa50513          	addi	a0,a0,-1286 # 800074c8 <etext+0x4c8>
    800039d6:	e63fc0ef          	jal	80000838 <panic>
    800039da:	79a2                	ld	s3,40(sp)
    800039dc:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    800039de:	4639                	li	a2,14
    800039e0:	85d6                	mv	a1,s5
    800039e2:	fb240513          	addi	a0,s0,-78
    800039e6:	c24fd0ef          	jal	80000e0a <strncpy>
  de.inum = inum;
    800039ea:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800039ee:	4741                	li	a4,16
    800039f0:	86a6                	mv	a3,s1
    800039f2:	fb040613          	addi	a2,s0,-80
    800039f6:	4581                	li	a1,0
    800039f8:	854a                	mv	a0,s2
    800039fa:	c6bff0ef          	jal	80003664 <writei>
    800039fe:	1541                	addi	a0,a0,-16
    80003a00:	00a03533          	snez	a0,a0
    80003a04:	40a0053b          	negw	a0,a0
    80003a08:	74e2                	ld	s1,56(sp)
}
    80003a0a:	60a6                	ld	ra,72(sp)
    80003a0c:	6406                	ld	s0,64(sp)
    80003a0e:	7942                	ld	s2,48(sp)
    80003a10:	6ae2                	ld	s5,24(sp)
    80003a12:	6b42                	ld	s6,16(sp)
    80003a14:	6161                	addi	sp,sp,80
    80003a16:	8082                	ret

0000000080003a18 <namei>:

struct inode*
namei(char *path)
{
    80003a18:	1101                	addi	sp,sp,-32
    80003a1a:	ec06                	sd	ra,24(sp)
    80003a1c:	e822                	sd	s0,16(sp)
    80003a1e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003a20:	fe040613          	addi	a2,s0,-32
    80003a24:	4581                	li	a1,0
    80003a26:	dffff0ef          	jal	80003824 <namex>
}
    80003a2a:	60e2                	ld	ra,24(sp)
    80003a2c:	6442                	ld	s0,16(sp)
    80003a2e:	6105                	addi	sp,sp,32
    80003a30:	8082                	ret

0000000080003a32 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003a32:	1141                	addi	sp,sp,-16
    80003a34:	e406                	sd	ra,8(sp)
    80003a36:	e022                	sd	s0,0(sp)
    80003a38:	0800                	addi	s0,sp,16
    80003a3a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003a3c:	4585                	li	a1,1
    80003a3e:	de7ff0ef          	jal	80003824 <namex>
}
    80003a42:	60a2                	ld	ra,8(sp)
    80003a44:	6402                	ld	s0,0(sp)
    80003a46:	0141                	addi	sp,sp,16
    80003a48:	8082                	ret

0000000080003a4a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003a4a:	1101                	addi	sp,sp,-32
    80003a4c:	ec06                	sd	ra,24(sp)
    80003a4e:	e822                	sd	s0,16(sp)
    80003a50:	e426                	sd	s1,8(sp)
    80003a52:	e04a                	sd	s2,0(sp)
    80003a54:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003a56:	0001c917          	auipc	s2,0x1c
    80003a5a:	ee290913          	addi	s2,s2,-286 # 8001f938 <log>
    80003a5e:	01892583          	lw	a1,24(s2)
    80003a62:	02492503          	lw	a0,36(s2)
    80003a66:	8daff0ef          	jal	80002b40 <bread>
    80003a6a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003a6c:	02892603          	lw	a2,40(s2)
    80003a70:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003a72:	00c05f63          	blez	a2,80003a90 <write_head+0x46>
    80003a76:	0001c717          	auipc	a4,0x1c
    80003a7a:	eee70713          	addi	a4,a4,-274 # 8001f964 <log+0x2c>
    80003a7e:	87aa                	mv	a5,a0
    80003a80:	060a                	slli	a2,a2,0x2
    80003a82:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003a84:	4314                	lw	a3,0(a4)
    80003a86:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003a88:	0711                	addi	a4,a4,4
    80003a8a:	0791                	addi	a5,a5,4 # 43004 <_entry-0x7ffbcffc>
    80003a8c:	fec79ce3          	bne	a5,a2,80003a84 <write_head+0x3a>
  }
  bwrite(buf);
    80003a90:	8526                	mv	a0,s1
    80003a92:	984ff0ef          	jal	80002c16 <bwrite>
  brelse(buf);
    80003a96:	8526                	mv	a0,s1
    80003a98:	9b0ff0ef          	jal	80002c48 <brelse>
}
    80003a9c:	60e2                	ld	ra,24(sp)
    80003a9e:	6442                	ld	s0,16(sp)
    80003aa0:	64a2                	ld	s1,8(sp)
    80003aa2:	6902                	ld	s2,0(sp)
    80003aa4:	6105                	addi	sp,sp,32
    80003aa6:	8082                	ret

0000000080003aa8 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003aa8:	0001c797          	auipc	a5,0x1c
    80003aac:	eb87a783          	lw	a5,-328(a5) # 8001f960 <log+0x28>
    80003ab0:	0cf05163          	blez	a5,80003b72 <install_trans+0xca>
{
    80003ab4:	715d                	addi	sp,sp,-80
    80003ab6:	e486                	sd	ra,72(sp)
    80003ab8:	e0a2                	sd	s0,64(sp)
    80003aba:	fc26                	sd	s1,56(sp)
    80003abc:	f84a                	sd	s2,48(sp)
    80003abe:	f44e                	sd	s3,40(sp)
    80003ac0:	f052                	sd	s4,32(sp)
    80003ac2:	ec56                	sd	s5,24(sp)
    80003ac4:	e85a                	sd	s6,16(sp)
    80003ac6:	e45e                	sd	s7,8(sp)
    80003ac8:	e062                	sd	s8,0(sp)
    80003aca:	0880                	addi	s0,sp,80
    80003acc:	8b2a                	mv	s6,a0
    80003ace:	0001ca97          	auipc	s5,0x1c
    80003ad2:	e96a8a93          	addi	s5,s5,-362 # 8001f964 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ad6:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003ad8:	00004c17          	auipc	s8,0x4
    80003adc:	a00c0c13          	addi	s8,s8,-1536 # 800074d8 <etext+0x4d8>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003ae0:	0001ca17          	auipc	s4,0x1c
    80003ae4:	e58a0a13          	addi	s4,s4,-424 # 8001f938 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003ae8:	40000b93          	li	s7,1024
    80003aec:	a025                	j	80003b14 <install_trans+0x6c>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003aee:	000aa603          	lw	a2,0(s5)
    80003af2:	85ce                	mv	a1,s3
    80003af4:	8562                	mv	a0,s8
    80003af6:	a0bfc0ef          	jal	80000500 <printf>
    80003afa:	a839                	j	80003b18 <install_trans+0x70>
    brelse(lbuf);
    80003afc:	854a                	mv	a0,s2
    80003afe:	94aff0ef          	jal	80002c48 <brelse>
    brelse(dbuf);
    80003b02:	8526                	mv	a0,s1
    80003b04:	944ff0ef          	jal	80002c48 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b08:	2985                	addiw	s3,s3,1
    80003b0a:	0a91                	addi	s5,s5,4
    80003b0c:	028a2783          	lw	a5,40(s4)
    80003b10:	04f9d563          	bge	s3,a5,80003b5a <install_trans+0xb2>
    if(recovering) {
    80003b14:	fc0b1de3          	bnez	s6,80003aee <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003b18:	018a2583          	lw	a1,24(s4)
    80003b1c:	013585bb          	addw	a1,a1,s3
    80003b20:	2585                	addiw	a1,a1,1
    80003b22:	024a2503          	lw	a0,36(s4)
    80003b26:	81aff0ef          	jal	80002b40 <bread>
    80003b2a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003b2c:	000aa583          	lw	a1,0(s5)
    80003b30:	024a2503          	lw	a0,36(s4)
    80003b34:	80cff0ef          	jal	80002b40 <bread>
    80003b38:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003b3a:	865e                	mv	a2,s7
    80003b3c:	05890593          	addi	a1,s2,88
    80003b40:	05850513          	addi	a0,a0,88
    80003b44:	a1cfd0ef          	jal	80000d60 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003b48:	8526                	mv	a0,s1
    80003b4a:	8ccff0ef          	jal	80002c16 <bwrite>
    if(recovering == 0)
    80003b4e:	fa0b17e3          	bnez	s6,80003afc <install_trans+0x54>
      bunpin(dbuf);
    80003b52:	8526                	mv	a0,s1
    80003b54:	9acff0ef          	jal	80002d00 <bunpin>
    80003b58:	b755                	j	80003afc <install_trans+0x54>
}
    80003b5a:	60a6                	ld	ra,72(sp)
    80003b5c:	6406                	ld	s0,64(sp)
    80003b5e:	74e2                	ld	s1,56(sp)
    80003b60:	7942                	ld	s2,48(sp)
    80003b62:	79a2                	ld	s3,40(sp)
    80003b64:	7a02                	ld	s4,32(sp)
    80003b66:	6ae2                	ld	s5,24(sp)
    80003b68:	6b42                	ld	s6,16(sp)
    80003b6a:	6ba2                	ld	s7,8(sp)
    80003b6c:	6c02                	ld	s8,0(sp)
    80003b6e:	6161                	addi	sp,sp,80
    80003b70:	8082                	ret
    80003b72:	8082                	ret

0000000080003b74 <initlog>:
{
    80003b74:	7179                	addi	sp,sp,-48
    80003b76:	f406                	sd	ra,40(sp)
    80003b78:	f022                	sd	s0,32(sp)
    80003b7a:	ec26                	sd	s1,24(sp)
    80003b7c:	e84a                	sd	s2,16(sp)
    80003b7e:	e44e                	sd	s3,8(sp)
    80003b80:	1800                	addi	s0,sp,48
    80003b82:	84aa                	mv	s1,a0
    80003b84:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003b86:	0001c917          	auipc	s2,0x1c
    80003b8a:	db290913          	addi	s2,s2,-590 # 8001f938 <log>
    80003b8e:	00004597          	auipc	a1,0x4
    80003b92:	96a58593          	addi	a1,a1,-1686 # 800074f8 <etext+0x4f8>
    80003b96:	854a                	mv	a0,s2
    80003b98:	816fd0ef          	jal	80000bae <initlock>
  log.start = sb->logstart;
    80003b9c:	0149a583          	lw	a1,20(s3)
    80003ba0:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003ba4:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003ba8:	8526                	mv	a0,s1
    80003baa:	f97fe0ef          	jal	80002b40 <bread>
  log.lh.n = lh->n;
    80003bae:	4d30                	lw	a2,88(a0)
    80003bb0:	02c92423          	sw	a2,40(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003bb4:	00c05f63          	blez	a2,80003bd2 <initlog+0x5e>
    80003bb8:	87aa                	mv	a5,a0
    80003bba:	0001c717          	auipc	a4,0x1c
    80003bbe:	daa70713          	addi	a4,a4,-598 # 8001f964 <log+0x2c>
    80003bc2:	060a                	slli	a2,a2,0x2
    80003bc4:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003bc6:	4ff4                	lw	a3,92(a5)
    80003bc8:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003bca:	0791                	addi	a5,a5,4
    80003bcc:	0711                	addi	a4,a4,4
    80003bce:	fec79ce3          	bne	a5,a2,80003bc6 <initlog+0x52>
  brelse(buf);
    80003bd2:	876ff0ef          	jal	80002c48 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003bd6:	4505                	li	a0,1
    80003bd8:	ed1ff0ef          	jal	80003aa8 <install_trans>
  log.lh.n = 0;
    80003bdc:	0001c797          	auipc	a5,0x1c
    80003be0:	d807a223          	sw	zero,-636(a5) # 8001f960 <log+0x28>
  write_head(); // clear the log
    80003be4:	e67ff0ef          	jal	80003a4a <write_head>
}
    80003be8:	70a2                	ld	ra,40(sp)
    80003bea:	7402                	ld	s0,32(sp)
    80003bec:	64e2                	ld	s1,24(sp)
    80003bee:	6942                	ld	s2,16(sp)
    80003bf0:	69a2                	ld	s3,8(sp)
    80003bf2:	6145                	addi	sp,sp,48
    80003bf4:	8082                	ret

0000000080003bf6 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003bf6:	1101                	addi	sp,sp,-32
    80003bf8:	ec06                	sd	ra,24(sp)
    80003bfa:	e822                	sd	s0,16(sp)
    80003bfc:	e426                	sd	s1,8(sp)
    80003bfe:	e04a                	sd	s2,0(sp)
    80003c00:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003c02:	0001c517          	auipc	a0,0x1c
    80003c06:	d3650513          	addi	a0,a0,-714 # 8001f938 <log>
    80003c0a:	82efd0ef          	jal	80000c38 <acquire>
  while(1){
    if(log.committing){
    80003c0e:	0001c497          	auipc	s1,0x1c
    80003c12:	d2a48493          	addi	s1,s1,-726 # 8001f938 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003c16:	4979                	li	s2,30
    80003c18:	a029                	j	80003c22 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003c1a:	85a6                	mv	a1,s1
    80003c1c:	8526                	mv	a0,s1
    80003c1e:	adefe0ef          	jal	80001efc <sleep>
    if(log.committing){
    80003c22:	509c                	lw	a5,32(s1)
    80003c24:	fbfd                	bnez	a5,80003c1a <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003c26:	4cd8                	lw	a4,28(s1)
    80003c28:	2705                	addiw	a4,a4,1
    80003c2a:	0027179b          	slliw	a5,a4,0x2
    80003c2e:	9fb9                	addw	a5,a5,a4
    80003c30:	0017979b          	slliw	a5,a5,0x1
    80003c34:	5494                	lw	a3,40(s1)
    80003c36:	9fb5                	addw	a5,a5,a3
    80003c38:	00f95763          	bge	s2,a5,80003c46 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003c3c:	85a6                	mv	a1,s1
    80003c3e:	8526                	mv	a0,s1
    80003c40:	abcfe0ef          	jal	80001efc <sleep>
    80003c44:	bff9                	j	80003c22 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003c46:	0001c797          	auipc	a5,0x1c
    80003c4a:	d0e7a723          	sw	a4,-754(a5) # 8001f954 <log+0x1c>
      release(&log.lock);
    80003c4e:	0001c517          	auipc	a0,0x1c
    80003c52:	cea50513          	addi	a0,a0,-790 # 8001f938 <log>
    80003c56:	872fd0ef          	jal	80000cc8 <release>
      break;
    }
  }
}
    80003c5a:	60e2                	ld	ra,24(sp)
    80003c5c:	6442                	ld	s0,16(sp)
    80003c5e:	64a2                	ld	s1,8(sp)
    80003c60:	6902                	ld	s2,0(sp)
    80003c62:	6105                	addi	sp,sp,32
    80003c64:	8082                	ret

0000000080003c66 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003c66:	7139                	addi	sp,sp,-64
    80003c68:	fc06                	sd	ra,56(sp)
    80003c6a:	f822                	sd	s0,48(sp)
    80003c6c:	f426                	sd	s1,40(sp)
    80003c6e:	f04a                	sd	s2,32(sp)
    80003c70:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003c72:	0001c497          	auipc	s1,0x1c
    80003c76:	cc648493          	addi	s1,s1,-826 # 8001f938 <log>
    80003c7a:	8526                	mv	a0,s1
    80003c7c:	fbdfc0ef          	jal	80000c38 <acquire>
  log.outstanding -= 1;
    80003c80:	4cdc                	lw	a5,28(s1)
    80003c82:	37fd                	addiw	a5,a5,-1
    80003c84:	893e                	mv	s2,a5
    80003c86:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003c88:	509c                	lw	a5,32(s1)
    80003c8a:	ebb9                	bnez	a5,80003ce0 <end_op+0x7a>
    panic("log.committing");
  if(log.outstanding == 0){
    80003c8c:	06091363          	bnez	s2,80003cf2 <end_op+0x8c>
    do_commit = 1;
    log.committing = 1;
    80003c90:	0001c497          	auipc	s1,0x1c
    80003c94:	ca848493          	addi	s1,s1,-856 # 8001f938 <log>
    80003c98:	4785                	li	a5,1
    80003c9a:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003c9c:	8526                	mv	a0,s1
    80003c9e:	82afd0ef          	jal	80000cc8 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003ca2:	549c                	lw	a5,40(s1)
    80003ca4:	06f04463          	bgtz	a5,80003d0c <end_op+0xa6>
    acquire(&log.lock);
    80003ca8:	0001c517          	auipc	a0,0x1c
    80003cac:	c9050513          	addi	a0,a0,-880 # 8001f938 <log>
    80003cb0:	f89fc0ef          	jal	80000c38 <acquire>
    log.committing = 0;
    80003cb4:	0001c797          	auipc	a5,0x1c
    80003cb8:	ca07a223          	sw	zero,-860(a5) # 8001f958 <log+0x20>
    wakeup(&log);
    80003cbc:	0001c517          	auipc	a0,0x1c
    80003cc0:	c7c50513          	addi	a0,a0,-900 # 8001f938 <log>
    80003cc4:	a84fe0ef          	jal	80001f48 <wakeup>
    release(&log.lock);
    80003cc8:	0001c517          	auipc	a0,0x1c
    80003ccc:	c7050513          	addi	a0,a0,-912 # 8001f938 <log>
    80003cd0:	ff9fc0ef          	jal	80000cc8 <release>
}
    80003cd4:	70e2                	ld	ra,56(sp)
    80003cd6:	7442                	ld	s0,48(sp)
    80003cd8:	74a2                	ld	s1,40(sp)
    80003cda:	7902                	ld	s2,32(sp)
    80003cdc:	6121                	addi	sp,sp,64
    80003cde:	8082                	ret
    80003ce0:	ec4e                	sd	s3,24(sp)
    80003ce2:	e852                	sd	s4,16(sp)
    80003ce4:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003ce6:	00004517          	auipc	a0,0x4
    80003cea:	81a50513          	addi	a0,a0,-2022 # 80007500 <etext+0x500>
    80003cee:	b4bfc0ef          	jal	80000838 <panic>
    wakeup(&log);
    80003cf2:	0001c517          	auipc	a0,0x1c
    80003cf6:	c4650513          	addi	a0,a0,-954 # 8001f938 <log>
    80003cfa:	a4efe0ef          	jal	80001f48 <wakeup>
  release(&log.lock);
    80003cfe:	0001c517          	auipc	a0,0x1c
    80003d02:	c3a50513          	addi	a0,a0,-966 # 8001f938 <log>
    80003d06:	fc3fc0ef          	jal	80000cc8 <release>
  if(do_commit){
    80003d0a:	b7e9                	j	80003cd4 <end_op+0x6e>
    80003d0c:	ec4e                	sd	s3,24(sp)
    80003d0e:	e852                	sd	s4,16(sp)
    80003d10:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d12:	0001ca97          	auipc	s5,0x1c
    80003d16:	c52a8a93          	addi	s5,s5,-942 # 8001f964 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003d1a:	0001ca17          	auipc	s4,0x1c
    80003d1e:	c1ea0a13          	addi	s4,s4,-994 # 8001f938 <log>
    80003d22:	018a2583          	lw	a1,24(s4)
    80003d26:	012585bb          	addw	a1,a1,s2
    80003d2a:	2585                	addiw	a1,a1,1
    80003d2c:	024a2503          	lw	a0,36(s4)
    80003d30:	e11fe0ef          	jal	80002b40 <bread>
    80003d34:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003d36:	000aa583          	lw	a1,0(s5)
    80003d3a:	024a2503          	lw	a0,36(s4)
    80003d3e:	e03fe0ef          	jal	80002b40 <bread>
    80003d42:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003d44:	40000613          	li	a2,1024
    80003d48:	05850593          	addi	a1,a0,88
    80003d4c:	05848513          	addi	a0,s1,88
    80003d50:	810fd0ef          	jal	80000d60 <memmove>
    bwrite(to);  // write the log
    80003d54:	8526                	mv	a0,s1
    80003d56:	ec1fe0ef          	jal	80002c16 <bwrite>
    brelse(from);
    80003d5a:	854e                	mv	a0,s3
    80003d5c:	eedfe0ef          	jal	80002c48 <brelse>
    brelse(to);
    80003d60:	8526                	mv	a0,s1
    80003d62:	ee7fe0ef          	jal	80002c48 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d66:	2905                	addiw	s2,s2,1
    80003d68:	0a91                	addi	s5,s5,4
    80003d6a:	028a2783          	lw	a5,40(s4)
    80003d6e:	faf94ae3          	blt	s2,a5,80003d22 <end_op+0xbc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003d72:	cd9ff0ef          	jal	80003a4a <write_head>
    install_trans(0); // Now install writes to home locations
    80003d76:	4501                	li	a0,0
    80003d78:	d31ff0ef          	jal	80003aa8 <install_trans>
    log.lh.n = 0;
    80003d7c:	0001c797          	auipc	a5,0x1c
    80003d80:	be07a223          	sw	zero,-1052(a5) # 8001f960 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003d84:	cc7ff0ef          	jal	80003a4a <write_head>
    80003d88:	69e2                	ld	s3,24(sp)
    80003d8a:	6a42                	ld	s4,16(sp)
    80003d8c:	6aa2                	ld	s5,8(sp)
    80003d8e:	bf29                	j	80003ca8 <end_op+0x42>

0000000080003d90 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003d90:	1101                	addi	sp,sp,-32
    80003d92:	ec06                	sd	ra,24(sp)
    80003d94:	e822                	sd	s0,16(sp)
    80003d96:	e426                	sd	s1,8(sp)
    80003d98:	1000                	addi	s0,sp,32
    80003d9a:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003d9c:	0001c517          	auipc	a0,0x1c
    80003da0:	b9c50513          	addi	a0,a0,-1124 # 8001f938 <log>
    80003da4:	e95fc0ef          	jal	80000c38 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003da8:	0001c617          	auipc	a2,0x1c
    80003dac:	bb862603          	lw	a2,-1096(a2) # 8001f960 <log+0x28>
    80003db0:	47f5                	li	a5,29
    80003db2:	04c7cc63          	blt	a5,a2,80003e0a <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003db6:	0001c797          	auipc	a5,0x1c
    80003dba:	b9e7a783          	lw	a5,-1122(a5) # 8001f954 <log+0x1c>
    80003dbe:	04f05c63          	blez	a5,80003e16 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003dc2:	4781                	li	a5,0
    80003dc4:	04c05f63          	blez	a2,80003e22 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003dc8:	44cc                	lw	a1,12(s1)
    80003dca:	0001c717          	auipc	a4,0x1c
    80003dce:	b9a70713          	addi	a4,a4,-1126 # 8001f964 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003dd2:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003dd4:	4314                	lw	a3,0(a4)
    80003dd6:	04b68663          	beq	a3,a1,80003e22 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80003dda:	2785                	addiw	a5,a5,1
    80003ddc:	0711                	addi	a4,a4,4
    80003dde:	fef61be3          	bne	a2,a5,80003dd4 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003de2:	0621                	addi	a2,a2,8
    80003de4:	060a                	slli	a2,a2,0x2
    80003de6:	0001c797          	auipc	a5,0x1c
    80003dea:	b5278793          	addi	a5,a5,-1198 # 8001f938 <log>
    80003dee:	97b2                	add	a5,a5,a2
    80003df0:	44d8                	lw	a4,12(s1)
    80003df2:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003df4:	8526                	mv	a0,s1
    80003df6:	ed7fe0ef          	jal	80002ccc <bpin>
    log.lh.n++;
    80003dfa:	0001c717          	auipc	a4,0x1c
    80003dfe:	b3e70713          	addi	a4,a4,-1218 # 8001f938 <log>
    80003e02:	571c                	lw	a5,40(a4)
    80003e04:	2785                	addiw	a5,a5,1
    80003e06:	d71c                	sw	a5,40(a4)
    80003e08:	a80d                	j	80003e3a <log_write+0xaa>
    panic("too big a transaction");
    80003e0a:	00003517          	auipc	a0,0x3
    80003e0e:	70650513          	addi	a0,a0,1798 # 80007510 <etext+0x510>
    80003e12:	a27fc0ef          	jal	80000838 <panic>
    panic("log_write outside of trans");
    80003e16:	00003517          	auipc	a0,0x3
    80003e1a:	71250513          	addi	a0,a0,1810 # 80007528 <etext+0x528>
    80003e1e:	a1bfc0ef          	jal	80000838 <panic>
  log.lh.block[i] = b->blockno;
    80003e22:	00878693          	addi	a3,a5,8
    80003e26:	068a                	slli	a3,a3,0x2
    80003e28:	0001c717          	auipc	a4,0x1c
    80003e2c:	b1070713          	addi	a4,a4,-1264 # 8001f938 <log>
    80003e30:	9736                	add	a4,a4,a3
    80003e32:	44d4                	lw	a3,12(s1)
    80003e34:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003e36:	faf60fe3          	beq	a2,a5,80003df4 <log_write+0x64>
  }
  release(&log.lock);
    80003e3a:	0001c517          	auipc	a0,0x1c
    80003e3e:	afe50513          	addi	a0,a0,-1282 # 8001f938 <log>
    80003e42:	e87fc0ef          	jal	80000cc8 <release>
}
    80003e46:	60e2                	ld	ra,24(sp)
    80003e48:	6442                	ld	s0,16(sp)
    80003e4a:	64a2                	ld	s1,8(sp)
    80003e4c:	6105                	addi	sp,sp,32
    80003e4e:	8082                	ret

0000000080003e50 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003e50:	1101                	addi	sp,sp,-32
    80003e52:	ec06                	sd	ra,24(sp)
    80003e54:	e822                	sd	s0,16(sp)
    80003e56:	e426                	sd	s1,8(sp)
    80003e58:	e04a                	sd	s2,0(sp)
    80003e5a:	1000                	addi	s0,sp,32
    80003e5c:	84aa                	mv	s1,a0
    80003e5e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003e60:	00003597          	auipc	a1,0x3
    80003e64:	6e858593          	addi	a1,a1,1768 # 80007548 <etext+0x548>
    80003e68:	0521                	addi	a0,a0,8
    80003e6a:	d45fc0ef          	jal	80000bae <initlock>
  lk->name = name;
    80003e6e:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003e72:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003e76:	0204a423          	sw	zero,40(s1)
}
    80003e7a:	60e2                	ld	ra,24(sp)
    80003e7c:	6442                	ld	s0,16(sp)
    80003e7e:	64a2                	ld	s1,8(sp)
    80003e80:	6902                	ld	s2,0(sp)
    80003e82:	6105                	addi	sp,sp,32
    80003e84:	8082                	ret

0000000080003e86 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003e86:	1101                	addi	sp,sp,-32
    80003e88:	ec06                	sd	ra,24(sp)
    80003e8a:	e822                	sd	s0,16(sp)
    80003e8c:	e426                	sd	s1,8(sp)
    80003e8e:	e04a                	sd	s2,0(sp)
    80003e90:	1000                	addi	s0,sp,32
    80003e92:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003e94:	00850913          	addi	s2,a0,8
    80003e98:	854a                	mv	a0,s2
    80003e9a:	d9ffc0ef          	jal	80000c38 <acquire>
  while (lk->locked) {
    80003e9e:	409c                	lw	a5,0(s1)
    80003ea0:	c799                	beqz	a5,80003eae <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003ea2:	85ca                	mv	a1,s2
    80003ea4:	8526                	mv	a0,s1
    80003ea6:	856fe0ef          	jal	80001efc <sleep>
  while (lk->locked) {
    80003eaa:	409c                	lw	a5,0(s1)
    80003eac:	fbfd                	bnez	a5,80003ea2 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003eae:	4785                	li	a5,1
    80003eb0:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003eb2:	a53fd0ef          	jal	80001904 <myproc>
    80003eb6:	591c                	lw	a5,48(a0)
    80003eb8:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003eba:	854a                	mv	a0,s2
    80003ebc:	e0dfc0ef          	jal	80000cc8 <release>
}
    80003ec0:	60e2                	ld	ra,24(sp)
    80003ec2:	6442                	ld	s0,16(sp)
    80003ec4:	64a2                	ld	s1,8(sp)
    80003ec6:	6902                	ld	s2,0(sp)
    80003ec8:	6105                	addi	sp,sp,32
    80003eca:	8082                	ret

0000000080003ecc <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003ecc:	1101                	addi	sp,sp,-32
    80003ece:	ec06                	sd	ra,24(sp)
    80003ed0:	e822                	sd	s0,16(sp)
    80003ed2:	e426                	sd	s1,8(sp)
    80003ed4:	e04a                	sd	s2,0(sp)
    80003ed6:	1000                	addi	s0,sp,32
    80003ed8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003eda:	00850913          	addi	s2,a0,8
    80003ede:	854a                	mv	a0,s2
    80003ee0:	d59fc0ef          	jal	80000c38 <acquire>
  lk->locked = 0;
    80003ee4:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003ee8:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003eec:	8526                	mv	a0,s1
    80003eee:	85afe0ef          	jal	80001f48 <wakeup>
  release(&lk->lk);
    80003ef2:	854a                	mv	a0,s2
    80003ef4:	dd5fc0ef          	jal	80000cc8 <release>
}
    80003ef8:	60e2                	ld	ra,24(sp)
    80003efa:	6442                	ld	s0,16(sp)
    80003efc:	64a2                	ld	s1,8(sp)
    80003efe:	6902                	ld	s2,0(sp)
    80003f00:	6105                	addi	sp,sp,32
    80003f02:	8082                	ret

0000000080003f04 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003f04:	7179                	addi	sp,sp,-48
    80003f06:	f406                	sd	ra,40(sp)
    80003f08:	f022                	sd	s0,32(sp)
    80003f0a:	ec26                	sd	s1,24(sp)
    80003f0c:	e84a                	sd	s2,16(sp)
    80003f0e:	1800                	addi	s0,sp,48
    80003f10:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003f12:	00850913          	addi	s2,a0,8
    80003f16:	854a                	mv	a0,s2
    80003f18:	d21fc0ef          	jal	80000c38 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003f1c:	409c                	lw	a5,0(s1)
    80003f1e:	ef81                	bnez	a5,80003f36 <holdingsleep+0x32>
    80003f20:	4481                	li	s1,0
  release(&lk->lk);
    80003f22:	854a                	mv	a0,s2
    80003f24:	da5fc0ef          	jal	80000cc8 <release>
  return r;
}
    80003f28:	8526                	mv	a0,s1
    80003f2a:	70a2                	ld	ra,40(sp)
    80003f2c:	7402                	ld	s0,32(sp)
    80003f2e:	64e2                	ld	s1,24(sp)
    80003f30:	6942                	ld	s2,16(sp)
    80003f32:	6145                	addi	sp,sp,48
    80003f34:	8082                	ret
    80003f36:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80003f38:	0284a983          	lw	s3,40(s1)
    80003f3c:	9c9fd0ef          	jal	80001904 <myproc>
    80003f40:	5904                	lw	s1,48(a0)
    80003f42:	413484b3          	sub	s1,s1,s3
    80003f46:	0014b493          	seqz	s1,s1
    80003f4a:	69a2                	ld	s3,8(sp)
    80003f4c:	bfd9                	j	80003f22 <holdingsleep+0x1e>

0000000080003f4e <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003f4e:	1141                	addi	sp,sp,-16
    80003f50:	e406                	sd	ra,8(sp)
    80003f52:	e022                	sd	s0,0(sp)
    80003f54:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003f56:	00003597          	auipc	a1,0x3
    80003f5a:	60258593          	addi	a1,a1,1538 # 80007558 <etext+0x558>
    80003f5e:	0001c517          	auipc	a0,0x1c
    80003f62:	b2250513          	addi	a0,a0,-1246 # 8001fa80 <ftable>
    80003f66:	c49fc0ef          	jal	80000bae <initlock>
}
    80003f6a:	60a2                	ld	ra,8(sp)
    80003f6c:	6402                	ld	s0,0(sp)
    80003f6e:	0141                	addi	sp,sp,16
    80003f70:	8082                	ret

0000000080003f72 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003f72:	1101                	addi	sp,sp,-32
    80003f74:	ec06                	sd	ra,24(sp)
    80003f76:	e822                	sd	s0,16(sp)
    80003f78:	e426                	sd	s1,8(sp)
    80003f7a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003f7c:	0001c517          	auipc	a0,0x1c
    80003f80:	b0450513          	addi	a0,a0,-1276 # 8001fa80 <ftable>
    80003f84:	cb5fc0ef          	jal	80000c38 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003f88:	0001c497          	auipc	s1,0x1c
    80003f8c:	b1048493          	addi	s1,s1,-1264 # 8001fa98 <ftable+0x18>
    80003f90:	0001d717          	auipc	a4,0x1d
    80003f94:	aa870713          	addi	a4,a4,-1368 # 80020a38 <disk>
    if(f->ref == 0){
    80003f98:	40dc                	lw	a5,4(s1)
    80003f9a:	cf89                	beqz	a5,80003fb4 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003f9c:	02848493          	addi	s1,s1,40
    80003fa0:	fee49ce3          	bne	s1,a4,80003f98 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003fa4:	0001c517          	auipc	a0,0x1c
    80003fa8:	adc50513          	addi	a0,a0,-1316 # 8001fa80 <ftable>
    80003fac:	d1dfc0ef          	jal	80000cc8 <release>
  return 0;
    80003fb0:	4481                	li	s1,0
    80003fb2:	a809                	j	80003fc4 <filealloc+0x52>
      f->ref = 1;
    80003fb4:	4785                	li	a5,1
    80003fb6:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003fb8:	0001c517          	auipc	a0,0x1c
    80003fbc:	ac850513          	addi	a0,a0,-1336 # 8001fa80 <ftable>
    80003fc0:	d09fc0ef          	jal	80000cc8 <release>
}
    80003fc4:	8526                	mv	a0,s1
    80003fc6:	60e2                	ld	ra,24(sp)
    80003fc8:	6442                	ld	s0,16(sp)
    80003fca:	64a2                	ld	s1,8(sp)
    80003fcc:	6105                	addi	sp,sp,32
    80003fce:	8082                	ret

0000000080003fd0 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003fd0:	1101                	addi	sp,sp,-32
    80003fd2:	ec06                	sd	ra,24(sp)
    80003fd4:	e822                	sd	s0,16(sp)
    80003fd6:	e426                	sd	s1,8(sp)
    80003fd8:	1000                	addi	s0,sp,32
    80003fda:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003fdc:	0001c517          	auipc	a0,0x1c
    80003fe0:	aa450513          	addi	a0,a0,-1372 # 8001fa80 <ftable>
    80003fe4:	c55fc0ef          	jal	80000c38 <acquire>
  if(f->ref < 1)
    80003fe8:	40dc                	lw	a5,4(s1)
    80003fea:	02f05063          	blez	a5,8000400a <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003fee:	2785                	addiw	a5,a5,1
    80003ff0:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003ff2:	0001c517          	auipc	a0,0x1c
    80003ff6:	a8e50513          	addi	a0,a0,-1394 # 8001fa80 <ftable>
    80003ffa:	ccffc0ef          	jal	80000cc8 <release>
  return f;
}
    80003ffe:	8526                	mv	a0,s1
    80004000:	60e2                	ld	ra,24(sp)
    80004002:	6442                	ld	s0,16(sp)
    80004004:	64a2                	ld	s1,8(sp)
    80004006:	6105                	addi	sp,sp,32
    80004008:	8082                	ret
    panic("filedup");
    8000400a:	00003517          	auipc	a0,0x3
    8000400e:	55650513          	addi	a0,a0,1366 # 80007560 <etext+0x560>
    80004012:	827fc0ef          	jal	80000838 <panic>

0000000080004016 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004016:	7139                	addi	sp,sp,-64
    80004018:	fc06                	sd	ra,56(sp)
    8000401a:	f822                	sd	s0,48(sp)
    8000401c:	f426                	sd	s1,40(sp)
    8000401e:	0080                	addi	s0,sp,64
    80004020:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004022:	0001c517          	auipc	a0,0x1c
    80004026:	a5e50513          	addi	a0,a0,-1442 # 8001fa80 <ftable>
    8000402a:	c0ffc0ef          	jal	80000c38 <acquire>
  if(f->ref < 1)
    8000402e:	40dc                	lw	a5,4(s1)
    80004030:	04f05a63          	blez	a5,80004084 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80004034:	37fd                	addiw	a5,a5,-1
    80004036:	c0dc                	sw	a5,4(s1)
    80004038:	06f04063          	bgtz	a5,80004098 <fileclose+0x82>
    8000403c:	f04a                	sd	s2,32(sp)
    8000403e:	ec4e                	sd	s3,24(sp)
    80004040:	e852                	sd	s4,16(sp)
    80004042:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004044:	0004a903          	lw	s2,0(s1)
    80004048:	0094c783          	lbu	a5,9(s1)
    8000404c:	89be                	mv	s3,a5
    8000404e:	689c                	ld	a5,16(s1)
    80004050:	8a3e                	mv	s4,a5
    80004052:	6c9c                	ld	a5,24(s1)
    80004054:	8abe                	mv	s5,a5
  f->ref = 0;
    80004056:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000405a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000405e:	0001c517          	auipc	a0,0x1c
    80004062:	a2250513          	addi	a0,a0,-1502 # 8001fa80 <ftable>
    80004066:	c63fc0ef          	jal	80000cc8 <release>

  if(ff.type == FD_PIPE){
    8000406a:	4785                	li	a5,1
    8000406c:	04f90163          	beq	s2,a5,800040ae <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004070:	ffe9079b          	addiw	a5,s2,-2
    80004074:	4705                	li	a4,1
    80004076:	04f77563          	bgeu	a4,a5,800040c0 <fileclose+0xaa>
    8000407a:	7902                	ld	s2,32(sp)
    8000407c:	69e2                	ld	s3,24(sp)
    8000407e:	6a42                	ld	s4,16(sp)
    80004080:	6aa2                	ld	s5,8(sp)
    80004082:	a00d                	j	800040a4 <fileclose+0x8e>
    80004084:	f04a                	sd	s2,32(sp)
    80004086:	ec4e                	sd	s3,24(sp)
    80004088:	e852                	sd	s4,16(sp)
    8000408a:	e456                	sd	s5,8(sp)
    panic("fileclose");
    8000408c:	00003517          	auipc	a0,0x3
    80004090:	4dc50513          	addi	a0,a0,1244 # 80007568 <etext+0x568>
    80004094:	fa4fc0ef          	jal	80000838 <panic>
    release(&ftable.lock);
    80004098:	0001c517          	auipc	a0,0x1c
    8000409c:	9e850513          	addi	a0,a0,-1560 # 8001fa80 <ftable>
    800040a0:	c29fc0ef          	jal	80000cc8 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800040a4:	70e2                	ld	ra,56(sp)
    800040a6:	7442                	ld	s0,48(sp)
    800040a8:	74a2                	ld	s1,40(sp)
    800040aa:	6121                	addi	sp,sp,64
    800040ac:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800040ae:	85ce                	mv	a1,s3
    800040b0:	8552                	mv	a0,s4
    800040b2:	332000ef          	jal	800043e4 <pipeclose>
    800040b6:	7902                	ld	s2,32(sp)
    800040b8:	69e2                	ld	s3,24(sp)
    800040ba:	6a42                	ld	s4,16(sp)
    800040bc:	6aa2                	ld	s5,8(sp)
    800040be:	b7dd                	j	800040a4 <fileclose+0x8e>
    begin_op();
    800040c0:	b37ff0ef          	jal	80003bf6 <begin_op>
    iput(ff.ip);
    800040c4:	8556                	mv	a0,s5
    800040c6:	a9cff0ef          	jal	80003362 <iput>
    end_op();
    800040ca:	b9dff0ef          	jal	80003c66 <end_op>
    800040ce:	7902                	ld	s2,32(sp)
    800040d0:	69e2                	ld	s3,24(sp)
    800040d2:	6a42                	ld	s4,16(sp)
    800040d4:	6aa2                	ld	s5,8(sp)
    800040d6:	b7f9                	j	800040a4 <fileclose+0x8e>

00000000800040d8 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800040d8:	715d                	addi	sp,sp,-80
    800040da:	e486                	sd	ra,72(sp)
    800040dc:	e0a2                	sd	s0,64(sp)
    800040de:	fc26                	sd	s1,56(sp)
    800040e0:	f052                	sd	s4,32(sp)
    800040e2:	0880                	addi	s0,sp,80
    800040e4:	84aa                	mv	s1,a0
    800040e6:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    800040e8:	81dfd0ef          	jal	80001904 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800040ec:	409c                	lw	a5,0(s1)
    800040ee:	37f9                	addiw	a5,a5,-2
    800040f0:	4705                	li	a4,1
    800040f2:	04f76263          	bltu	a4,a5,80004136 <filestat+0x5e>
    800040f6:	f84a                	sd	s2,48(sp)
    800040f8:	f44e                	sd	s3,40(sp)
    800040fa:	89aa                	mv	s3,a0
    ilock(f->ip);
    800040fc:	6c88                	ld	a0,24(s1)
    800040fe:	8e2ff0ef          	jal	800031e0 <ilock>
    stati(f->ip, &st);
    80004102:	fb840913          	addi	s2,s0,-72
    80004106:	85ca                	mv	a1,s2
    80004108:	6c88                	ld	a0,24(s1)
    8000410a:	c3aff0ef          	jal	80003544 <stati>
    iunlock(f->ip);
    8000410e:	6c88                	ld	a0,24(s1)
    80004110:	97eff0ef          	jal	8000328e <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004114:	46e1                	li	a3,24
    80004116:	864a                	mv	a2,s2
    80004118:	85d2                	mv	a1,s4
    8000411a:	0509b503          	ld	a0,80(s3)
    8000411e:	d1efd0ef          	jal	8000163c <copyout>
    80004122:	41f5551b          	sraiw	a0,a0,0x1f
    80004126:	7942                	ld	s2,48(sp)
    80004128:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    8000412a:	60a6                	ld	ra,72(sp)
    8000412c:	6406                	ld	s0,64(sp)
    8000412e:	74e2                	ld	s1,56(sp)
    80004130:	7a02                	ld	s4,32(sp)
    80004132:	6161                	addi	sp,sp,80
    80004134:	8082                	ret
  return -1;
    80004136:	557d                	li	a0,-1
    80004138:	bfcd                	j	8000412a <filestat+0x52>

000000008000413a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000413a:	7179                	addi	sp,sp,-48
    8000413c:	f406                	sd	ra,40(sp)
    8000413e:	f022                	sd	s0,32(sp)
    80004140:	e84a                	sd	s2,16(sp)
    80004142:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004144:	00854783          	lbu	a5,8(a0)
    80004148:	c3c5                	beqz	a5,800041e8 <fileread+0xae>
    8000414a:	ec26                	sd	s1,24(sp)
    8000414c:	e44e                	sd	s3,8(sp)
    8000414e:	84aa                	mv	s1,a0
    80004150:	892e                	mv	s2,a1
    80004152:	89b2                	mv	s3,a2
    return -1;

  if(f->type == FD_PIPE){
    80004154:	411c                	lw	a5,0(a0)
    80004156:	4705                	li	a4,1
    80004158:	04e78363          	beq	a5,a4,8000419e <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000415c:	470d                	li	a4,3
    8000415e:	04e78763          	beq	a5,a4,800041ac <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004162:	4709                	li	a4,2
    80004164:	06e79a63          	bne	a5,a4,800041d8 <fileread+0x9e>
    ilock(f->ip);
    80004168:	6d08                	ld	a0,24(a0)
    8000416a:	876ff0ef          	jal	800031e0 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000416e:	874e                	mv	a4,s3
    80004170:	5094                	lw	a3,32(s1)
    80004172:	864a                	mv	a2,s2
    80004174:	4585                	li	a1,1
    80004176:	6c88                	ld	a0,24(s1)
    80004178:	bfaff0ef          	jal	80003572 <readi>
    8000417c:	892a                	mv	s2,a0
    8000417e:	00a05563          	blez	a0,80004188 <fileread+0x4e>
      f->off += r;
    80004182:	509c                	lw	a5,32(s1)
    80004184:	9fa9                	addw	a5,a5,a0
    80004186:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004188:	6c88                	ld	a0,24(s1)
    8000418a:	904ff0ef          	jal	8000328e <iunlock>
    8000418e:	64e2                	ld	s1,24(sp)
    80004190:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004192:	854a                	mv	a0,s2
    80004194:	70a2                	ld	ra,40(sp)
    80004196:	7402                	ld	s0,32(sp)
    80004198:	6942                	ld	s2,16(sp)
    8000419a:	6145                	addi	sp,sp,48
    8000419c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000419e:	6908                	ld	a0,16(a0)
    800041a0:	39a000ef          	jal	8000453a <piperead>
    800041a4:	892a                	mv	s2,a0
    800041a6:	64e2                	ld	s1,24(sp)
    800041a8:	69a2                	ld	s3,8(sp)
    800041aa:	b7e5                	j	80004192 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800041ac:	02451783          	lh	a5,36(a0)
    800041b0:	03079693          	slli	a3,a5,0x30
    800041b4:	92c1                	srli	a3,a3,0x30
    800041b6:	4725                	li	a4,9
    800041b8:	02d76663          	bltu	a4,a3,800041e4 <fileread+0xaa>
    800041bc:	0792                	slli	a5,a5,0x4
    800041be:	0001c717          	auipc	a4,0x1c
    800041c2:	82270713          	addi	a4,a4,-2014 # 8001f9e0 <devsw>
    800041c6:	97ba                	add	a5,a5,a4
    800041c8:	639c                	ld	a5,0(a5)
    800041ca:	c395                	beqz	a5,800041ee <fileread+0xb4>
    r = devsw[f->major].read(1, addr, n);
    800041cc:	4505                	li	a0,1
    800041ce:	9782                	jalr	a5
    800041d0:	892a                	mv	s2,a0
    800041d2:	64e2                	ld	s1,24(sp)
    800041d4:	69a2                	ld	s3,8(sp)
    800041d6:	bf75                	j	80004192 <fileread+0x58>
    panic("fileread");
    800041d8:	00003517          	auipc	a0,0x3
    800041dc:	3a050513          	addi	a0,a0,928 # 80007578 <etext+0x578>
    800041e0:	e58fc0ef          	jal	80000838 <panic>
    800041e4:	64e2                	ld	s1,24(sp)
    800041e6:	69a2                	ld	s3,8(sp)
    return -1;
    800041e8:	57fd                	li	a5,-1
    800041ea:	893e                	mv	s2,a5
    800041ec:	b75d                	j	80004192 <fileread+0x58>
    800041ee:	64e2                	ld	s1,24(sp)
    800041f0:	69a2                	ld	s3,8(sp)
    800041f2:	bfdd                	j	800041e8 <fileread+0xae>

00000000800041f4 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800041f4:	00954783          	lbu	a5,9(a0)
    800041f8:	12078463          	beqz	a5,80004320 <filewrite+0x12c>
{
    800041fc:	711d                	addi	sp,sp,-96
    800041fe:	ec86                	sd	ra,88(sp)
    80004200:	e8a2                	sd	s0,80(sp)
    80004202:	e0ca                	sd	s2,64(sp)
    80004204:	f456                	sd	s5,40(sp)
    80004206:	f05a                	sd	s6,32(sp)
    80004208:	1080                	addi	s0,sp,96
    8000420a:	892a                	mv	s2,a0
    8000420c:	8b2e                	mv	s6,a1
    8000420e:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    80004210:	411c                	lw	a5,0(a0)
    80004212:	4705                	li	a4,1
    80004214:	02e78a63          	beq	a5,a4,80004248 <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004218:	470d                	li	a4,3
    8000421a:	02e78b63          	beq	a5,a4,80004250 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000421e:	4709                	li	a4,2
    80004220:	0ce79f63          	bne	a5,a4,800042fe <filewrite+0x10a>
    80004224:	f852                	sd	s4,48(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004226:	0ac05a63          	blez	a2,800042da <filewrite+0xe6>
    8000422a:	e4a6                	sd	s1,72(sp)
    8000422c:	fc4e                	sd	s3,56(sp)
    8000422e:	ec5e                	sd	s7,24(sp)
    80004230:	e862                	sd	s8,16(sp)
    80004232:	e466                	sd	s9,8(sp)
    int i = 0;
    80004234:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    80004236:	6b85                	lui	s7,0x1
    80004238:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000423c:	6785                	lui	a5,0x1
    8000423e:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    80004242:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004244:	4c05                	li	s8,1
    80004246:	a8ad                	j	800042c0 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80004248:	6908                	ld	a0,16(a0)
    8000424a:	1f8000ef          	jal	80004442 <pipewrite>
    8000424e:	a04d                	j	800042f0 <filewrite+0xfc>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004250:	02451783          	lh	a5,36(a0)
    80004254:	03079693          	slli	a3,a5,0x30
    80004258:	92c1                	srli	a3,a3,0x30
    8000425a:	4725                	li	a4,9
    8000425c:	0ad76d63          	bltu	a4,a3,80004316 <filewrite+0x122>
    80004260:	0792                	slli	a5,a5,0x4
    80004262:	0001b717          	auipc	a4,0x1b
    80004266:	77e70713          	addi	a4,a4,1918 # 8001f9e0 <devsw>
    8000426a:	97ba                	add	a5,a5,a4
    8000426c:	679c                	ld	a5,8(a5)
    8000426e:	c7c5                	beqz	a5,80004316 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80004270:	4505                	li	a0,1
    80004272:	9782                	jalr	a5
    80004274:	a8b5                	j	800042f0 <filewrite+0xfc>
      if(n1 > max)
    80004276:	2981                	sext.w	s3,s3
      begin_op();
    80004278:	97fff0ef          	jal	80003bf6 <begin_op>
      ilock(f->ip);
    8000427c:	01893503          	ld	a0,24(s2)
    80004280:	f61fe0ef          	jal	800031e0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004284:	874e                	mv	a4,s3
    80004286:	02092683          	lw	a3,32(s2)
    8000428a:	016a0633          	add	a2,s4,s6
    8000428e:	85e2                	mv	a1,s8
    80004290:	01893503          	ld	a0,24(s2)
    80004294:	bd0ff0ef          	jal	80003664 <writei>
    80004298:	84aa                	mv	s1,a0
    8000429a:	00a05763          	blez	a0,800042a8 <filewrite+0xb4>
        f->off += r;
    8000429e:	02092783          	lw	a5,32(s2)
    800042a2:	9fa9                	addw	a5,a5,a0
    800042a4:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800042a8:	01893503          	ld	a0,24(s2)
    800042ac:	fe3fe0ef          	jal	8000328e <iunlock>
      end_op();
    800042b0:	9b7ff0ef          	jal	80003c66 <end_op>

      if(r != n1){
    800042b4:	02999563          	bne	s3,s1,800042de <filewrite+0xea>
        // error from writei
        break;
      }
      i += r;
    800042b8:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    800042bc:	015a5963          	bge	s4,s5,800042ce <filewrite+0xda>
      int n1 = n - i;
    800042c0:	414a87bb          	subw	a5,s5,s4
    800042c4:	89be                	mv	s3,a5
      if(n1 > max)
    800042c6:	fafbd8e3          	bge	s7,a5,80004276 <filewrite+0x82>
    800042ca:	89e6                	mv	s3,s9
    800042cc:	b76d                	j	80004276 <filewrite+0x82>
    800042ce:	64a6                	ld	s1,72(sp)
    800042d0:	79e2                	ld	s3,56(sp)
    800042d2:	6be2                	ld	s7,24(sp)
    800042d4:	6c42                	ld	s8,16(sp)
    800042d6:	6ca2                	ld	s9,8(sp)
    800042d8:	a801                	j	800042e8 <filewrite+0xf4>
    int i = 0;
    800042da:	4a01                	li	s4,0
    800042dc:	a031                	j	800042e8 <filewrite+0xf4>
    800042de:	64a6                	ld	s1,72(sp)
    800042e0:	79e2                	ld	s3,56(sp)
    800042e2:	6be2                	ld	s7,24(sp)
    800042e4:	6c42                	ld	s8,16(sp)
    800042e6:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    800042e8:	034a9963          	bne	s5,s4,8000431a <filewrite+0x126>
    800042ec:	8556                	mv	a0,s5
    800042ee:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800042f0:	60e6                	ld	ra,88(sp)
    800042f2:	6446                	ld	s0,80(sp)
    800042f4:	6906                	ld	s2,64(sp)
    800042f6:	7aa2                	ld	s5,40(sp)
    800042f8:	7b02                	ld	s6,32(sp)
    800042fa:	6125                	addi	sp,sp,96
    800042fc:	8082                	ret
    800042fe:	e4a6                	sd	s1,72(sp)
    80004300:	fc4e                	sd	s3,56(sp)
    80004302:	f852                	sd	s4,48(sp)
    80004304:	ec5e                	sd	s7,24(sp)
    80004306:	e862                	sd	s8,16(sp)
    80004308:	e466                	sd	s9,8(sp)
    panic("filewrite");
    8000430a:	00003517          	auipc	a0,0x3
    8000430e:	27e50513          	addi	a0,a0,638 # 80007588 <etext+0x588>
    80004312:	d26fc0ef          	jal	80000838 <panic>
    return -1;
    80004316:	557d                	li	a0,-1
    80004318:	bfe1                	j	800042f0 <filewrite+0xfc>
    ret = (i == n ? n : -1);
    8000431a:	557d                	li	a0,-1
    8000431c:	7a42                	ld	s4,48(sp)
    8000431e:	bfc9                	j	800042f0 <filewrite+0xfc>
    return -1;
    80004320:	557d                	li	a0,-1
}
    80004322:	8082                	ret

0000000080004324 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004324:	7179                	addi	sp,sp,-48
    80004326:	f406                	sd	ra,40(sp)
    80004328:	f022                	sd	s0,32(sp)
    8000432a:	ec26                	sd	s1,24(sp)
    8000432c:	e052                	sd	s4,0(sp)
    8000432e:	1800                	addi	s0,sp,48
    80004330:	84aa                	mv	s1,a0
    80004332:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004334:	0005b023          	sd	zero,0(a1)
    80004338:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000433c:	c37ff0ef          	jal	80003f72 <filealloc>
    80004340:	e088                	sd	a0,0(s1)
    80004342:	c549                	beqz	a0,800043cc <pipealloc+0xa8>
    80004344:	c2fff0ef          	jal	80003f72 <filealloc>
    80004348:	00aa3023          	sd	a0,0(s4)
    8000434c:	cd25                	beqz	a0,800043c4 <pipealloc+0xa0>
    8000434e:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004350:	805fc0ef          	jal	80000b54 <kalloc>
    80004354:	892a                	mv	s2,a0
    80004356:	c12d                	beqz	a0,800043b8 <pipealloc+0x94>
    80004358:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    8000435a:	4985                	li	s3,1
    8000435c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004360:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004364:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004368:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000436c:	00003597          	auipc	a1,0x3
    80004370:	22c58593          	addi	a1,a1,556 # 80007598 <etext+0x598>
    80004374:	83bfc0ef          	jal	80000bae <initlock>
  (*f0)->type = FD_PIPE;
    80004378:	609c                	ld	a5,0(s1)
    8000437a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000437e:	609c                	ld	a5,0(s1)
    80004380:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004384:	609c                	ld	a5,0(s1)
    80004386:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000438a:	609c                	ld	a5,0(s1)
    8000438c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004390:	000a3783          	ld	a5,0(s4)
    80004394:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004398:	000a3783          	ld	a5,0(s4)
    8000439c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800043a0:	000a3783          	ld	a5,0(s4)
    800043a4:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800043a8:	000a3783          	ld	a5,0(s4)
    800043ac:	0127b823          	sd	s2,16(a5)
  return 0;
    800043b0:	4501                	li	a0,0
    800043b2:	6942                	ld	s2,16(sp)
    800043b4:	69a2                	ld	s3,8(sp)
    800043b6:	a00d                	j	800043d8 <pipealloc+0xb4>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800043b8:	6088                	ld	a0,0(s1)
    800043ba:	c119                	beqz	a0,800043c0 <pipealloc+0x9c>
    800043bc:	6942                	ld	s2,16(sp)
    800043be:	a029                	j	800043c8 <pipealloc+0xa4>
    800043c0:	6942                	ld	s2,16(sp)
    800043c2:	a029                	j	800043cc <pipealloc+0xa8>
    800043c4:	6088                	ld	a0,0(s1)
    800043c6:	c901                	beqz	a0,800043d6 <pipealloc+0xb2>
    fileclose(*f0);
    800043c8:	c4fff0ef          	jal	80004016 <fileclose>
  if(*f1)
    800043cc:	000a3503          	ld	a0,0(s4)
    800043d0:	c119                	beqz	a0,800043d6 <pipealloc+0xb2>
    fileclose(*f1);
    800043d2:	c45ff0ef          	jal	80004016 <fileclose>
  return -1;
    800043d6:	557d                	li	a0,-1
}
    800043d8:	70a2                	ld	ra,40(sp)
    800043da:	7402                	ld	s0,32(sp)
    800043dc:	64e2                	ld	s1,24(sp)
    800043de:	6a02                	ld	s4,0(sp)
    800043e0:	6145                	addi	sp,sp,48
    800043e2:	8082                	ret

00000000800043e4 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800043e4:	1101                	addi	sp,sp,-32
    800043e6:	ec06                	sd	ra,24(sp)
    800043e8:	e822                	sd	s0,16(sp)
    800043ea:	e426                	sd	s1,8(sp)
    800043ec:	e04a                	sd	s2,0(sp)
    800043ee:	1000                	addi	s0,sp,32
    800043f0:	84aa                	mv	s1,a0
    800043f2:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800043f4:	845fc0ef          	jal	80000c38 <acquire>
  if(writable){
    800043f8:	02090763          	beqz	s2,80004426 <pipeclose+0x42>
    pi->writeopen = 0;
    800043fc:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004400:	21848513          	addi	a0,s1,536
    80004404:	b45fd0ef          	jal	80001f48 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004408:	2204a783          	lw	a5,544(s1)
    8000440c:	e781                	bnez	a5,80004414 <pipeclose+0x30>
    8000440e:	2244a783          	lw	a5,548(s1)
    80004412:	c38d                	beqz	a5,80004434 <pipeclose+0x50>
    release(&pi->lock);
    kfree((char*)pi);
  } else
    release(&pi->lock);
    80004414:	8526                	mv	a0,s1
    80004416:	8b3fc0ef          	jal	80000cc8 <release>
}
    8000441a:	60e2                	ld	ra,24(sp)
    8000441c:	6442                	ld	s0,16(sp)
    8000441e:	64a2                	ld	s1,8(sp)
    80004420:	6902                	ld	s2,0(sp)
    80004422:	6105                	addi	sp,sp,32
    80004424:	8082                	ret
    pi->readopen = 0;
    80004426:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000442a:	21c48513          	addi	a0,s1,540
    8000442e:	b1bfd0ef          	jal	80001f48 <wakeup>
    80004432:	bfd9                	j	80004408 <pipeclose+0x24>
    release(&pi->lock);
    80004434:	8526                	mv	a0,s1
    80004436:	893fc0ef          	jal	80000cc8 <release>
    kfree((char*)pi);
    8000443a:	8526                	mv	a0,s1
    8000443c:	e30fc0ef          	jal	80000a6c <kfree>
    80004440:	bfe9                	j	8000441a <pipeclose+0x36>

0000000080004442 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004442:	7159                	addi	sp,sp,-112
    80004444:	f486                	sd	ra,104(sp)
    80004446:	f0a2                	sd	s0,96(sp)
    80004448:	eca6                	sd	s1,88(sp)
    8000444a:	e8ca                	sd	s2,80(sp)
    8000444c:	e4ce                	sd	s3,72(sp)
    8000444e:	e0d2                	sd	s4,64(sp)
    80004450:	fc56                	sd	s5,56(sp)
    80004452:	1880                	addi	s0,sp,112
    80004454:	84aa                	mv	s1,a0
    80004456:	8aae                	mv	s5,a1
    80004458:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000445a:	caafd0ef          	jal	80001904 <myproc>
    8000445e:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004460:	8526                	mv	a0,s1
    80004462:	fd6fc0ef          	jal	80000c38 <acquire>
  while(i < n){
    80004466:	0d405263          	blez	s4,8000452a <pipewrite+0xe8>
    8000446a:	f85a                	sd	s6,48(sp)
    8000446c:	f45e                	sd	s7,40(sp)
    8000446e:	f062                	sd	s8,32(sp)
    80004470:	ec66                	sd	s9,24(sp)
    80004472:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004474:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004476:	f9f40c13          	addi	s8,s0,-97
    8000447a:	4b85                	li	s7,1
    8000447c:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000447e:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004482:	21c48c93          	addi	s9,s1,540
    80004486:	a82d                	j	800044c0 <pipewrite+0x7e>
      release(&pi->lock);
    80004488:	8526                	mv	a0,s1
    8000448a:	83ffc0ef          	jal	80000cc8 <release>
      return -1;
    8000448e:	597d                	li	s2,-1
    80004490:	7b42                	ld	s6,48(sp)
    80004492:	7ba2                	ld	s7,40(sp)
    80004494:	7c02                	ld	s8,32(sp)
    80004496:	6ce2                	ld	s9,24(sp)
    80004498:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000449a:	854a                	mv	a0,s2
    8000449c:	70a6                	ld	ra,104(sp)
    8000449e:	7406                	ld	s0,96(sp)
    800044a0:	64e6                	ld	s1,88(sp)
    800044a2:	6946                	ld	s2,80(sp)
    800044a4:	69a6                	ld	s3,72(sp)
    800044a6:	6a06                	ld	s4,64(sp)
    800044a8:	7ae2                	ld	s5,56(sp)
    800044aa:	6165                	addi	sp,sp,112
    800044ac:	8082                	ret
      wakeup(&pi->nread);
    800044ae:	856a                	mv	a0,s10
    800044b0:	a99fd0ef          	jal	80001f48 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800044b4:	85a6                	mv	a1,s1
    800044b6:	8566                	mv	a0,s9
    800044b8:	a45fd0ef          	jal	80001efc <sleep>
  while(i < n){
    800044bc:	05495a63          	bge	s2,s4,80004510 <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    800044c0:	2204a783          	lw	a5,544(s1)
    800044c4:	d3f1                	beqz	a5,80004488 <pipewrite+0x46>
    800044c6:	854e                	mv	a0,s3
    800044c8:	c71fd0ef          	jal	80002138 <killed>
    800044cc:	fd55                	bnez	a0,80004488 <pipewrite+0x46>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800044ce:	2184a783          	lw	a5,536(s1)
    800044d2:	21c4a703          	lw	a4,540(s1)
    800044d6:	2007879b          	addiw	a5,a5,512
    800044da:	fcf70ae3          	beq	a4,a5,800044ae <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800044de:	86de                	mv	a3,s7
    800044e0:	01590633          	add	a2,s2,s5
    800044e4:	85e2                	mv	a1,s8
    800044e6:	0509b503          	ld	a0,80(s3)
    800044ea:	a0afd0ef          	jal	800016f4 <copyin>
    800044ee:	05650063          	beq	a0,s6,8000452e <pipewrite+0xec>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800044f2:	21c4a783          	lw	a5,540(s1)
    800044f6:	0017871b          	addiw	a4,a5,1
    800044fa:	20e4ae23          	sw	a4,540(s1)
    800044fe:	1ff7f793          	andi	a5,a5,511
    80004502:	97a6                	add	a5,a5,s1
    80004504:	f9f44703          	lbu	a4,-97(s0)
    80004508:	00e78c23          	sb	a4,24(a5)
      i++;
    8000450c:	2905                	addiw	s2,s2,1
    8000450e:	b77d                	j	800044bc <pipewrite+0x7a>
    80004510:	7b42                	ld	s6,48(sp)
    80004512:	7ba2                	ld	s7,40(sp)
    80004514:	7c02                	ld	s8,32(sp)
    80004516:	6ce2                	ld	s9,24(sp)
    80004518:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    8000451a:	21848513          	addi	a0,s1,536
    8000451e:	a2bfd0ef          	jal	80001f48 <wakeup>
  release(&pi->lock);
    80004522:	8526                	mv	a0,s1
    80004524:	fa4fc0ef          	jal	80000cc8 <release>
  return i;
    80004528:	bf8d                	j	8000449a <pipewrite+0x58>
  int i = 0;
    8000452a:	4901                	li	s2,0
    8000452c:	b7fd                	j	8000451a <pipewrite+0xd8>
    8000452e:	7b42                	ld	s6,48(sp)
    80004530:	7ba2                	ld	s7,40(sp)
    80004532:	7c02                	ld	s8,32(sp)
    80004534:	6ce2                	ld	s9,24(sp)
    80004536:	6d42                	ld	s10,16(sp)
    80004538:	b7cd                	j	8000451a <pipewrite+0xd8>

000000008000453a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000453a:	711d                	addi	sp,sp,-96
    8000453c:	ec86                	sd	ra,88(sp)
    8000453e:	e8a2                	sd	s0,80(sp)
    80004540:	e4a6                	sd	s1,72(sp)
    80004542:	e0ca                	sd	s2,64(sp)
    80004544:	fc4e                	sd	s3,56(sp)
    80004546:	f852                	sd	s4,48(sp)
    80004548:	f456                	sd	s5,40(sp)
    8000454a:	1080                	addi	s0,sp,96
    8000454c:	84aa                	mv	s1,a0
    8000454e:	892e                	mv	s2,a1
    80004550:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004552:	bb2fd0ef          	jal	80001904 <myproc>
    80004556:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004558:	8526                	mv	a0,s1
    8000455a:	edefc0ef          	jal	80000c38 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000455e:	2184a703          	lw	a4,536(s1)
    80004562:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004566:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000456a:	02f71363          	bne	a4,a5,80004590 <piperead+0x56>
    8000456e:	2244a783          	lw	a5,548(s1)
    80004572:	cf99                	beqz	a5,80004590 <piperead+0x56>
    if(killed(pr)){
    80004574:	8552                	mv	a0,s4
    80004576:	bc3fd0ef          	jal	80002138 <killed>
    8000457a:	e925                	bnez	a0,800045ea <piperead+0xb0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000457c:	85a6                	mv	a1,s1
    8000457e:	854e                	mv	a0,s3
    80004580:	97dfd0ef          	jal	80001efc <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004584:	2184a703          	lw	a4,536(s1)
    80004588:	21c4a783          	lw	a5,540(s1)
    8000458c:	fef701e3          	beq	a4,a5,8000456e <piperead+0x34>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004590:	07505863          	blez	s5,80004600 <piperead+0xc6>
    80004594:	f05a                	sd	s6,32(sp)
    80004596:	ec5e                	sd	s7,24(sp)
    80004598:	e862                	sd	s8,16(sp)
    8000459a:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    8000459c:	faf40c13          	addi	s8,s0,-81
    800045a0:	4b85                	li	s7,1
    800045a2:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    800045a4:	2184a783          	lw	a5,536(s1)
    800045a8:	21c4a703          	lw	a4,540(s1)
    800045ac:	06f70163          	beq	a4,a5,8000460e <piperead+0xd4>
    ch = pi->data[pi->nread % PIPESIZE];
    800045b0:	1ff7f793          	andi	a5,a5,511
    800045b4:	97a6                	add	a5,a5,s1
    800045b6:	0187c783          	lbu	a5,24(a5)
    800045ba:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800045be:	86de                	mv	a3,s7
    800045c0:	8662                	mv	a2,s8
    800045c2:	85ca                	mv	a1,s2
    800045c4:	050a3503          	ld	a0,80(s4)
    800045c8:	874fd0ef          	jal	8000163c <copyout>
    800045cc:	03650463          	beq	a0,s6,800045f4 <piperead+0xba>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    800045d0:	2184a783          	lw	a5,536(s1)
    800045d4:	2785                	addiw	a5,a5,1
    800045d6:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800045da:	2985                	addiw	s3,s3,1
    800045dc:	0905                	addi	s2,s2,1
    800045de:	fd3a93e3          	bne	s5,s3,800045a4 <piperead+0x6a>
    800045e2:	7b02                	ld	s6,32(sp)
    800045e4:	6be2                	ld	s7,24(sp)
    800045e6:	6c42                	ld	s8,16(sp)
    800045e8:	a035                	j	80004614 <piperead+0xda>
      release(&pi->lock);
    800045ea:	8526                	mv	a0,s1
    800045ec:	edcfc0ef          	jal	80000cc8 <release>
      return -1;
    800045f0:	59fd                	li	s3,-1
    800045f2:	a805                	j	80004622 <piperead+0xe8>
      if(i == 0)
    800045f4:	00098863          	beqz	s3,80004604 <piperead+0xca>
    800045f8:	7b02                	ld	s6,32(sp)
    800045fa:	6be2                	ld	s7,24(sp)
    800045fc:	6c42                	ld	s8,16(sp)
    800045fe:	a819                	j	80004614 <piperead+0xda>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004600:	4981                	li	s3,0
    80004602:	a809                	j	80004614 <piperead+0xda>
        i = -1;
    80004604:	89aa                	mv	s3,a0
    80004606:	7b02                	ld	s6,32(sp)
    80004608:	6be2                	ld	s7,24(sp)
    8000460a:	6c42                	ld	s8,16(sp)
    8000460c:	a021                	j	80004614 <piperead+0xda>
    8000460e:	7b02                	ld	s6,32(sp)
    80004610:	6be2                	ld	s7,24(sp)
    80004612:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004614:	21c48513          	addi	a0,s1,540
    80004618:	931fd0ef          	jal	80001f48 <wakeup>
  release(&pi->lock);
    8000461c:	8526                	mv	a0,s1
    8000461e:	eaafc0ef          	jal	80000cc8 <release>
  return i;
}
    80004622:	854e                	mv	a0,s3
    80004624:	60e6                	ld	ra,88(sp)
    80004626:	6446                	ld	s0,80(sp)
    80004628:	64a6                	ld	s1,72(sp)
    8000462a:	6906                	ld	s2,64(sp)
    8000462c:	79e2                	ld	s3,56(sp)
    8000462e:	7a42                	ld	s4,48(sp)
    80004630:	7aa2                	ld	s5,40(sp)
    80004632:	6125                	addi	sp,sp,96
    80004634:	8082                	ret

0000000080004636 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004636:	1141                	addi	sp,sp,-16
    80004638:	e406                	sd	ra,8(sp)
    8000463a:	e022                	sd	s0,0(sp)
    8000463c:	0800                	addi	s0,sp,16
    8000463e:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004640:	0035151b          	slliw	a0,a0,0x3
    80004644:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    80004646:	8b89                	andi	a5,a5,2
    80004648:	c399                	beqz	a5,8000464e <flags2perm+0x18>
      perm |= PTE_W;
    8000464a:	00456513          	ori	a0,a0,4
    return perm;
}
    8000464e:	60a2                	ld	ra,8(sp)
    80004650:	6402                	ld	s0,0(sp)
    80004652:	0141                	addi	sp,sp,16
    80004654:	8082                	ret

0000000080004656 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004656:	df010113          	addi	sp,sp,-528
    8000465a:	20113423          	sd	ra,520(sp)
    8000465e:	20813023          	sd	s0,512(sp)
    80004662:	ffa6                	sd	s1,504(sp)
    80004664:	fbca                	sd	s2,496(sp)
    80004666:	0c00                	addi	s0,sp,528
    80004668:	892a                	mv	s2,a0
    8000466a:	e0a43023          	sd	a0,-512(s0)
    8000466e:	deb43c23          	sd	a1,-520(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004672:	a92fd0ef          	jal	80001904 <myproc>
    80004676:	84aa                	mv	s1,a0

  begin_op();
    80004678:	d7eff0ef          	jal	80003bf6 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    8000467c:	854a                	mv	a0,s2
    8000467e:	b9aff0ef          	jal	80003a18 <namei>
    80004682:	c931                	beqz	a0,800046d6 <kexec+0x80>
    80004684:	f3d2                	sd	s4,480(sp)
    80004686:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004688:	b59fe0ef          	jal	800031e0 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000468c:	04000713          	li	a4,64
    80004690:	4681                	li	a3,0
    80004692:	e5040613          	addi	a2,s0,-432
    80004696:	4581                	li	a1,0
    80004698:	8552                	mv	a0,s4
    8000469a:	ed9fe0ef          	jal	80003572 <readi>
    8000469e:	04000793          	li	a5,64
    800046a2:	00f51a63          	bne	a0,a5,800046b6 <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    800046a6:	e5042703          	lw	a4,-432(s0)
    800046aa:	464c47b7          	lui	a5,0x464c4
    800046ae:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800046b2:	02f70563          	beq	a4,a5,800046dc <kexec+0x86>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800046b6:	8552                	mv	a0,s4
    800046b8:	d35fe0ef          	jal	800033ec <iunlockput>
    end_op();
    800046bc:	daaff0ef          	jal	80003c66 <end_op>
    800046c0:	7a1e                	ld	s4,480(sp)
    return -1;
    800046c2:	557d                	li	a0,-1
  }
  return -1;
}
    800046c4:	20813083          	ld	ra,520(sp)
    800046c8:	20013403          	ld	s0,512(sp)
    800046cc:	74fe                	ld	s1,504(sp)
    800046ce:	795e                	ld	s2,496(sp)
    800046d0:	21010113          	addi	sp,sp,528
    800046d4:	8082                	ret
    end_op();
    800046d6:	d90ff0ef          	jal	80003c66 <end_op>
    return -1;
    800046da:	b7e5                	j	800046c2 <kexec+0x6c>
    800046dc:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    800046de:	8526                	mv	a0,s1
    800046e0:	b2efd0ef          	jal	80001a0e <proc_pagetable>
    800046e4:	8b2a                	mv	s6,a0
    800046e6:	26050063          	beqz	a0,80004946 <kexec+0x2f0>
    800046ea:	f7ce                	sd	s3,488(sp)
    800046ec:	efd6                	sd	s5,472(sp)
    800046ee:	e7de                	sd	s7,456(sp)
    800046f0:	e3e2                	sd	s8,448(sp)
    800046f2:	ff66                	sd	s9,440(sp)
    800046f4:	fb6a                	sd	s10,432(sp)
    800046f6:	f76e                	sd	s11,424(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800046f8:	e8845783          	lhu	a5,-376(s0)
    800046fc:	cff9                	beqz	a5,800047da <kexec+0x184>
    800046fe:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004702:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004704:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004706:	03800d93          	li	s11,56

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    8000470a:	6c85                	lui	s9,0x1
    8000470c:	6a85                	lui	s5,0x1
    8000470e:	a085                	j	8000476e <kexec+0x118>
      panic("loadseg: address should exist");
    80004710:	00003517          	auipc	a0,0x3
    80004714:	e9050513          	addi	a0,a0,-368 # 800075a0 <etext+0x5a0>
    80004718:	920fc0ef          	jal	80000838 <panic>
    if(sz - i < PGSIZE)
    8000471c:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000471e:	874a                	mv	a4,s2
    80004720:	009b86bb          	addw	a3,s7,s1
    80004724:	4581                	li	a1,0
    80004726:	8552                	mv	a0,s4
    80004728:	e4bfe0ef          	jal	80003572 <readi>
    8000472c:	22a91163          	bne	s2,a0,8000494e <kexec+0x2f8>
  for(i = 0; i < sz; i += PGSIZE){
    80004730:	009a84bb          	addw	s1,s5,s1
    80004734:	0334f263          	bgeu	s1,s3,80004758 <kexec+0x102>
    pa = walkaddr(pagetable, va + i);
    80004738:	02049593          	slli	a1,s1,0x20
    8000473c:	9181                	srli	a1,a1,0x20
    8000473e:	95e2                	add	a1,a1,s8
    80004740:	855a                	mv	a0,s6
    80004742:	8e3fc0ef          	jal	80001024 <walkaddr>
    80004746:	862a                	mv	a2,a0
    if(pa == 0)
    80004748:	d561                	beqz	a0,80004710 <kexec+0xba>
    if(sz - i < PGSIZE)
    8000474a:	409987bb          	subw	a5,s3,s1
    8000474e:	893e                	mv	s2,a5
    80004750:	fcfcf6e3          	bgeu	s9,a5,8000471c <kexec+0xc6>
    80004754:	8956                	mv	s2,s5
    80004756:	b7d9                	j	8000471c <kexec+0xc6>
    sz = sz1;
    80004758:	df043903          	ld	s2,-528(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000475c:	2d05                	addiw	s10,s10,1
    8000475e:	e0843783          	ld	a5,-504(s0)
    80004762:	0387869b          	addiw	a3,a5,56
    80004766:	e8845783          	lhu	a5,-376(s0)
    8000476a:	06fd5963          	bge	s10,a5,800047dc <kexec+0x186>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000476e:	e0d43423          	sd	a3,-504(s0)
    80004772:	876e                	mv	a4,s11
    80004774:	e1840613          	addi	a2,s0,-488
    80004778:	4581                	li	a1,0
    8000477a:	8552                	mv	a0,s4
    8000477c:	df7fe0ef          	jal	80003572 <readi>
    80004780:	1db51563          	bne	a0,s11,8000494a <kexec+0x2f4>
    if(ph.type != ELF_PROG_LOAD)
    80004784:	e1842783          	lw	a5,-488(s0)
    80004788:	4705                	li	a4,1
    8000478a:	fce799e3          	bne	a5,a4,8000475c <kexec+0x106>
    if(ph.memsz < ph.filesz)
    8000478e:	e4043483          	ld	s1,-448(s0)
    80004792:	e3843783          	ld	a5,-456(s0)
    80004796:	1af4ea63          	bltu	s1,a5,8000494a <kexec+0x2f4>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000479a:	e2843783          	ld	a5,-472(s0)
    8000479e:	94be                	add	s1,s1,a5
    800047a0:	1af4e563          	bltu	s1,a5,8000494a <kexec+0x2f4>
    if(ph.vaddr % PGSIZE != 0)
    800047a4:	17d2                	slli	a5,a5,0x34
    800047a6:	1a079263          	bnez	a5,8000494a <kexec+0x2f4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800047aa:	e1c42503          	lw	a0,-484(s0)
    800047ae:	e89ff0ef          	jal	80004636 <flags2perm>
    800047b2:	86aa                	mv	a3,a0
    800047b4:	8626                	mv	a2,s1
    800047b6:	85ca                	mv	a1,s2
    800047b8:	855a                	mv	a0,s6
    800047ba:	b39fc0ef          	jal	800012f2 <uvmalloc>
    800047be:	dea43823          	sd	a0,-528(s0)
    800047c2:	18050463          	beqz	a0,8000494a <kexec+0x2f4>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800047c6:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800047ca:	f80987e3          	beqz	s3,80004758 <kexec+0x102>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800047ce:	e2843c03          	ld	s8,-472(s0)
    800047d2:	e2042b83          	lw	s7,-480(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800047d6:	4481                	li	s1,0
    800047d8:	b785                	j	80004738 <kexec+0xe2>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800047da:	4901                	li	s2,0
  iunlockput(ip);
    800047dc:	8552                	mv	a0,s4
    800047de:	c0ffe0ef          	jal	800033ec <iunlockput>
  end_op();
    800047e2:	c84ff0ef          	jal	80003c66 <end_op>
  p = myproc();
    800047e6:	91efd0ef          	jal	80001904 <myproc>
    800047ea:	89aa                	mv	s3,a0
  uint64 oldsz = p->sz;
    800047ec:	04853a83          	ld	s5,72(a0)
  sz = PGROUNDUP(sz);
    800047f0:	6485                	lui	s1,0x1
    800047f2:	14fd                	addi	s1,s1,-1 # fff <_entry-0x7ffff001>
    800047f4:	94ca                	add	s1,s1,s2
    800047f6:	77fd                	lui	a5,0xfffff
    800047f8:	8cfd                	and	s1,s1,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800047fa:	4691                	li	a3,4
    800047fc:	6609                	lui	a2,0x2
    800047fe:	9626                	add	a2,a2,s1
    80004800:	85a6                	mv	a1,s1
    80004802:	855a                	mv	a0,s6
    80004804:	aeffc0ef          	jal	800012f2 <uvmalloc>
    80004808:	8a2a                	mv	s4,a0
    8000480a:	ed19                	bnez	a0,80004828 <kexec+0x1d2>
    proc_freepagetable(pagetable, sz);
    8000480c:	85a6                	mv	a1,s1
    8000480e:	855a                	mv	a0,s6
    80004810:	a80fd0ef          	jal	80001a90 <proc_freepagetable>
  if(ip){
    80004814:	79be                	ld	s3,488(sp)
    80004816:	7a1e                	ld	s4,480(sp)
    80004818:	6afe                	ld	s5,472(sp)
    8000481a:	6b5e                	ld	s6,464(sp)
    8000481c:	6bbe                	ld	s7,456(sp)
    8000481e:	6c1e                	ld	s8,448(sp)
    80004820:	7cfa                	ld	s9,440(sp)
    80004822:	7d5a                	ld	s10,432(sp)
    80004824:	7dba                	ld	s11,424(sp)
    80004826:	bd71                	j	800046c2 <kexec+0x6c>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004828:	75f9                	lui	a1,0xffffe
    8000482a:	95aa                	add	a1,a1,a0
    8000482c:	855a                	mv	a0,s6
    8000482e:	c8dfc0ef          	jal	800014ba <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004832:	7c7d                	lui	s8,0xfffff
    80004834:	9c52                	add	s8,s8,s4
  for(argc = 0; argv[argc]; argc++) {
    80004836:	df843783          	ld	a5,-520(s0)
    8000483a:	6388                	ld	a0,0(a5)
  sp = sz;
    8000483c:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    8000483e:	4481                	li	s1,0
    ustack[argc] = sp;
    80004840:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    80004844:	02000d13          	li	s10,32
  for(argc = 0; argv[argc]; argc++) {
    80004848:	cd21                	beqz	a0,800048a0 <kexec+0x24a>
    sp -= strlen(argv[argc]) + 1;
    8000484a:	e3afc0ef          	jal	80000e84 <strlen>
    8000484e:	0015079b          	addiw	a5,a0,1
    80004852:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004856:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    8000485a:	05896163          	bltu	s2,s8,8000489c <kexec+0x246>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000485e:	df843d83          	ld	s11,-520(s0)
    80004862:	000dbb83          	ld	s7,0(s11)
    80004866:	855e                	mv	a0,s7
    80004868:	e1cfc0ef          	jal	80000e84 <strlen>
    8000486c:	0015069b          	addiw	a3,a0,1
    80004870:	865e                	mv	a2,s7
    80004872:	85ca                	mv	a1,s2
    80004874:	855a                	mv	a0,s6
    80004876:	dc7fc0ef          	jal	8000163c <copyout>
    8000487a:	02054163          	bltz	a0,8000489c <kexec+0x246>
    ustack[argc] = sp;
    8000487e:	00349793          	slli	a5,s1,0x3
    80004882:	97e6                	add	a5,a5,s9
    80004884:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffde488>
  for(argc = 0; argv[argc]; argc++) {
    80004888:	0485                	addi	s1,s1,1
    8000488a:	008d8793          	addi	a5,s11,8
    8000488e:	def43c23          	sd	a5,-520(s0)
    80004892:	008db503          	ld	a0,8(s11)
    80004896:	c509                	beqz	a0,800048a0 <kexec+0x24a>
    if(argc >= MAXARG)
    80004898:	fba499e3          	bne	s1,s10,8000484a <kexec+0x1f4>
  sz = sz1;
    8000489c:	84d2                	mv	s1,s4
    8000489e:	b7bd                	j	8000480c <kexec+0x1b6>
  ustack[argc] = 0;
    800048a0:	00349793          	slli	a5,s1,0x3
    800048a4:	f9040713          	addi	a4,s0,-112
    800048a8:	97ba                	add	a5,a5,a4
    800048aa:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800048ae:	00148693          	addi	a3,s1,1
    800048b2:	068e                	slli	a3,a3,0x3
    800048b4:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800048b8:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800048bc:	ff8960e3          	bltu	s2,s8,8000489c <kexec+0x246>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800048c0:	e9040613          	addi	a2,s0,-368
    800048c4:	85ca                	mv	a1,s2
    800048c6:	855a                	mv	a0,s6
    800048c8:	d75fc0ef          	jal	8000163c <copyout>
    800048cc:	fc0548e3          	bltz	a0,8000489c <kexec+0x246>
  p->trapframe->a1 = sp;
    800048d0:	0589b783          	ld	a5,88(s3)
    800048d4:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800048d8:	e0043783          	ld	a5,-512(s0)
    800048dc:	0007c703          	lbu	a4,0(a5)
    800048e0:	cf11                	beqz	a4,800048fc <kexec+0x2a6>
    800048e2:	0785                	addi	a5,a5,1
    if(*s == '/')
    800048e4:	02f00693          	li	a3,47
    800048e8:	a029                	j	800048f2 <kexec+0x29c>
  for(last=s=path; *s; s++)
    800048ea:	0785                	addi	a5,a5,1
    800048ec:	fff7c703          	lbu	a4,-1(a5)
    800048f0:	c711                	beqz	a4,800048fc <kexec+0x2a6>
    if(*s == '/')
    800048f2:	fed71ce3          	bne	a4,a3,800048ea <kexec+0x294>
      last = s+1;
    800048f6:	e0f43023          	sd	a5,-512(s0)
    800048fa:	bfc5                	j	800048ea <kexec+0x294>
  safestrcpy(p->name, last, sizeof(p->name));
    800048fc:	4641                	li	a2,16
    800048fe:	e0043583          	ld	a1,-512(s0)
    80004902:	15898513          	addi	a0,s3,344
    80004906:	d48fc0ef          	jal	80000e4e <safestrcpy>
  oldpagetable = p->pagetable;
    8000490a:	0509b503          	ld	a0,80(s3)
  p->pagetable = pagetable;
    8000490e:	0569b823          	sd	s6,80(s3)
  p->sz = sz;
    80004912:	0549b423          	sd	s4,72(s3)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80004916:	0589b783          	ld	a5,88(s3)
    8000491a:	e6843703          	ld	a4,-408(s0)
    8000491e:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004920:	0589b783          	ld	a5,88(s3)
    80004924:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004928:	85d6                	mv	a1,s5
    8000492a:	966fd0ef          	jal	80001a90 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000492e:	0004851b          	sext.w	a0,s1
    80004932:	79be                	ld	s3,488(sp)
    80004934:	7a1e                	ld	s4,480(sp)
    80004936:	6afe                	ld	s5,472(sp)
    80004938:	6b5e                	ld	s6,464(sp)
    8000493a:	6bbe                	ld	s7,456(sp)
    8000493c:	6c1e                	ld	s8,448(sp)
    8000493e:	7cfa                	ld	s9,440(sp)
    80004940:	7d5a                	ld	s10,432(sp)
    80004942:	7dba                	ld	s11,424(sp)
    80004944:	b341                	j	800046c4 <kexec+0x6e>
    80004946:	6b5e                	ld	s6,464(sp)
    80004948:	b3bd                	j	800046b6 <kexec+0x60>
    return -1;
    8000494a:	df243823          	sd	s2,-528(s0)
    proc_freepagetable(pagetable, sz);
    8000494e:	df043583          	ld	a1,-528(s0)
    80004952:	855a                	mv	a0,s6
    80004954:	93cfd0ef          	jal	80001a90 <proc_freepagetable>
  if(ip){
    80004958:	79be                	ld	s3,488(sp)
    8000495a:	6afe                	ld	s5,472(sp)
    8000495c:	6b5e                	ld	s6,464(sp)
    8000495e:	6bbe                	ld	s7,456(sp)
    80004960:	6c1e                	ld	s8,448(sp)
    80004962:	7cfa                	ld	s9,440(sp)
    80004964:	7d5a                	ld	s10,432(sp)
    80004966:	7dba                	ld	s11,424(sp)
    80004968:	b3b9                	j	800046b6 <kexec+0x60>

000000008000496a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000496a:	7179                	addi	sp,sp,-48
    8000496c:	f406                	sd	ra,40(sp)
    8000496e:	f022                	sd	s0,32(sp)
    80004970:	ec26                	sd	s1,24(sp)
    80004972:	e84a                	sd	s2,16(sp)
    80004974:	1800                	addi	s0,sp,48
    80004976:	892e                	mv	s2,a1
    80004978:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000497a:	fdc40593          	addi	a1,s0,-36
    8000497e:	e79fd0ef          	jal	800027f6 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004982:	fdc42703          	lw	a4,-36(s0)
    80004986:	47bd                	li	a5,15
    80004988:	02e7e963          	bltu	a5,a4,800049ba <argfd+0x50>
    8000498c:	f79fc0ef          	jal	80001904 <myproc>
    80004990:	fdc42703          	lw	a4,-36(s0)
    80004994:	01a70793          	addi	a5,a4,26
    80004998:	078e                	slli	a5,a5,0x3
    8000499a:	953e                	add	a0,a0,a5
    8000499c:	611c                	ld	a5,0(a0)
    8000499e:	cf91                	beqz	a5,800049ba <argfd+0x50>
    return -1;
  if(pfd)
    800049a0:	00090463          	beqz	s2,800049a8 <argfd+0x3e>
    *pfd = fd;
    800049a4:	00e92023          	sw	a4,0(s2)
  if(pf)
    800049a8:	c091                	beqz	s1,800049ac <argfd+0x42>
    *pf = f;
    800049aa:	e09c                	sd	a5,0(s1)
  return 0;
    800049ac:	4501                	li	a0,0
}
    800049ae:	70a2                	ld	ra,40(sp)
    800049b0:	7402                	ld	s0,32(sp)
    800049b2:	64e2                	ld	s1,24(sp)
    800049b4:	6942                	ld	s2,16(sp)
    800049b6:	6145                	addi	sp,sp,48
    800049b8:	8082                	ret
    return -1;
    800049ba:	557d                	li	a0,-1
    800049bc:	bfcd                	j	800049ae <argfd+0x44>

00000000800049be <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800049be:	1101                	addi	sp,sp,-32
    800049c0:	ec06                	sd	ra,24(sp)
    800049c2:	e822                	sd	s0,16(sp)
    800049c4:	e426                	sd	s1,8(sp)
    800049c6:	1000                	addi	s0,sp,32
    800049c8:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800049ca:	f3bfc0ef          	jal	80001904 <myproc>
    800049ce:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800049d0:	0d050793          	addi	a5,a0,208
    800049d4:	4501                	li	a0,0
    800049d6:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800049d8:	6398                	ld	a4,0(a5)
    800049da:	cb19                	beqz	a4,800049f0 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    800049dc:	2505                	addiw	a0,a0,1
    800049de:	07a1                	addi	a5,a5,8
    800049e0:	fed51ce3          	bne	a0,a3,800049d8 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800049e4:	557d                	li	a0,-1
}
    800049e6:	60e2                	ld	ra,24(sp)
    800049e8:	6442                	ld	s0,16(sp)
    800049ea:	64a2                	ld	s1,8(sp)
    800049ec:	6105                	addi	sp,sp,32
    800049ee:	8082                	ret
      p->ofile[fd] = f;
    800049f0:	01a50793          	addi	a5,a0,26
    800049f4:	078e                	slli	a5,a5,0x3
    800049f6:	963e                	add	a2,a2,a5
    800049f8:	e204                	sd	s1,0(a2)
      return fd;
    800049fa:	b7f5                	j	800049e6 <fdalloc+0x28>

00000000800049fc <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800049fc:	715d                	addi	sp,sp,-80
    800049fe:	e486                	sd	ra,72(sp)
    80004a00:	e0a2                	sd	s0,64(sp)
    80004a02:	fc26                	sd	s1,56(sp)
    80004a04:	f84a                	sd	s2,48(sp)
    80004a06:	f44e                	sd	s3,40(sp)
    80004a08:	f052                	sd	s4,32(sp)
    80004a0a:	ec56                	sd	s5,24(sp)
    80004a0c:	e85a                	sd	s6,16(sp)
    80004a0e:	0880                	addi	s0,sp,80
    80004a10:	892e                	mv	s2,a1
    80004a12:	8a2e                	mv	s4,a1
    80004a14:	8ab2                	mv	s5,a2
    80004a16:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004a18:	fb040593          	addi	a1,s0,-80
    80004a1c:	816ff0ef          	jal	80003a32 <nameiparent>
    80004a20:	84aa                	mv	s1,a0
    return 0;
    80004a22:	89aa                	mv	s3,a0
  if((dp = nameiparent(path, name)) == 0)
    80004a24:	cd05                	beqz	a0,80004a5c <create+0x60>

  ilock(dp);
    80004a26:	fbafe0ef          	jal	800031e0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004a2a:	4601                	li	a2,0
    80004a2c:	fb040593          	addi	a1,s0,-80
    80004a30:	8526                	mv	a0,s1
    80004a32:	d4bfe0ef          	jal	8000377c <dirlookup>
    80004a36:	89aa                	mv	s3,a0
    80004a38:	c131                	beqz	a0,80004a7c <create+0x80>
    iunlockput(dp);
    80004a3a:	8526                	mv	a0,s1
    80004a3c:	9b1fe0ef          	jal	800033ec <iunlockput>
    ilock(ip);
    80004a40:	854e                	mv	a0,s3
    80004a42:	f9efe0ef          	jal	800031e0 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004a46:	4789                	li	a5,2
    80004a48:	02f91563          	bne	s2,a5,80004a72 <create+0x76>
    80004a4c:	0449d783          	lhu	a5,68(s3)
    80004a50:	37f9                	addiw	a5,a5,-2
    80004a52:	17c2                	slli	a5,a5,0x30
    80004a54:	93c1                	srli	a5,a5,0x30
    80004a56:	4705                	li	a4,1
    80004a58:	00f76d63          	bltu	a4,a5,80004a72 <create+0x76>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004a5c:	854e                	mv	a0,s3
    80004a5e:	60a6                	ld	ra,72(sp)
    80004a60:	6406                	ld	s0,64(sp)
    80004a62:	74e2                	ld	s1,56(sp)
    80004a64:	7942                	ld	s2,48(sp)
    80004a66:	79a2                	ld	s3,40(sp)
    80004a68:	7a02                	ld	s4,32(sp)
    80004a6a:	6ae2                	ld	s5,24(sp)
    80004a6c:	6b42                	ld	s6,16(sp)
    80004a6e:	6161                	addi	sp,sp,80
    80004a70:	8082                	ret
    iunlockput(ip);
    80004a72:	854e                	mv	a0,s3
    80004a74:	979fe0ef          	jal	800033ec <iunlockput>
    return 0;
    80004a78:	4981                	li	s3,0
    80004a7a:	b7cd                	j	80004a5c <create+0x60>
  if((ip = ialloc(dp->dev, type)) == 0){
    80004a7c:	85ca                	mv	a1,s2
    80004a7e:	4088                	lw	a0,0(s1)
    80004a80:	df0fe0ef          	jal	80003070 <ialloc>
    80004a84:	892a                	mv	s2,a0
    80004a86:	cd15                	beqz	a0,80004ac2 <create+0xc6>
  ilock(ip);
    80004a88:	f58fe0ef          	jal	800031e0 <ilock>
  ip->major = major;
    80004a8c:	05591323          	sh	s5,70(s2)
  ip->minor = minor;
    80004a90:	05691423          	sh	s6,72(s2)
  ip->nlink = 1;
    80004a94:	4785                	li	a5,1
    80004a96:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004a9a:	854a                	mv	a0,s2
    80004a9c:	e90fe0ef          	jal	8000312c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004aa0:	4705                	li	a4,1
    80004aa2:	02ea0463          	beq	s4,a4,80004aca <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004aa6:	00492603          	lw	a2,4(s2)
    80004aaa:	fb040593          	addi	a1,s0,-80
    80004aae:	8526                	mv	a0,s1
    80004ab0:	ebffe0ef          	jal	8000396e <dirlink>
    80004ab4:	06054263          	bltz	a0,80004b18 <create+0x11c>
  iunlockput(dp);
    80004ab8:	8526                	mv	a0,s1
    80004aba:	933fe0ef          	jal	800033ec <iunlockput>
    return 0;
    80004abe:	89ca                	mv	s3,s2
    80004ac0:	bf71                	j	80004a5c <create+0x60>
    iunlockput(dp);
    80004ac2:	8526                	mv	a0,s1
    80004ac4:	929fe0ef          	jal	800033ec <iunlockput>
    return 0;
    80004ac8:	bfdd                	j	80004abe <create+0xc2>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004aca:	00492603          	lw	a2,4(s2)
    80004ace:	00003597          	auipc	a1,0x3
    80004ad2:	af258593          	addi	a1,a1,-1294 # 800075c0 <etext+0x5c0>
    80004ad6:	854a                	mv	a0,s2
    80004ad8:	e97fe0ef          	jal	8000396e <dirlink>
    80004adc:	02054e63          	bltz	a0,80004b18 <create+0x11c>
    80004ae0:	40d0                	lw	a2,4(s1)
    80004ae2:	00003597          	auipc	a1,0x3
    80004ae6:	ae658593          	addi	a1,a1,-1306 # 800075c8 <etext+0x5c8>
    80004aea:	854a                	mv	a0,s2
    80004aec:	e83fe0ef          	jal	8000396e <dirlink>
    80004af0:	02054463          	bltz	a0,80004b18 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004af4:	00492603          	lw	a2,4(s2)
    80004af8:	fb040593          	addi	a1,s0,-80
    80004afc:	8526                	mv	a0,s1
    80004afe:	e71fe0ef          	jal	8000396e <dirlink>
    80004b02:	00054b63          	bltz	a0,80004b18 <create+0x11c>
    dp->nlink++;  // for ".."
    80004b06:	04a4d783          	lhu	a5,74(s1)
    80004b0a:	2785                	addiw	a5,a5,1
    80004b0c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004b10:	8526                	mv	a0,s1
    80004b12:	e1afe0ef          	jal	8000312c <iupdate>
    80004b16:	b74d                	j	80004ab8 <create+0xbc>
  ip->nlink = 0;
    80004b18:	04091523          	sh	zero,74(s2)
  iupdate(ip);
    80004b1c:	854a                	mv	a0,s2
    80004b1e:	e0efe0ef          	jal	8000312c <iupdate>
  iunlockput(ip);
    80004b22:	854a                	mv	a0,s2
    80004b24:	8c9fe0ef          	jal	800033ec <iunlockput>
  iunlockput(dp);
    80004b28:	8526                	mv	a0,s1
    80004b2a:	8c3fe0ef          	jal	800033ec <iunlockput>
  return 0;
    80004b2e:	b73d                	j	80004a5c <create+0x60>

0000000080004b30 <sys_dup>:
{
    80004b30:	7179                	addi	sp,sp,-48
    80004b32:	f406                	sd	ra,40(sp)
    80004b34:	f022                	sd	s0,32(sp)
    80004b36:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004b38:	fd840613          	addi	a2,s0,-40
    80004b3c:	4581                	li	a1,0
    80004b3e:	4501                	li	a0,0
    80004b40:	e2bff0ef          	jal	8000496a <argfd>
    80004b44:	02054863          	bltz	a0,80004b74 <sys_dup+0x44>
    80004b48:	ec26                	sd	s1,24(sp)
    80004b4a:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004b4c:	fd843483          	ld	s1,-40(s0)
    80004b50:	8526                	mv	a0,s1
    80004b52:	e6dff0ef          	jal	800049be <fdalloc>
    80004b56:	892a                	mv	s2,a0
    80004b58:	00054c63          	bltz	a0,80004b70 <sys_dup+0x40>
  filedup(f);
    80004b5c:	8526                	mv	a0,s1
    80004b5e:	c72ff0ef          	jal	80003fd0 <filedup>
  return fd;
    80004b62:	854a                	mv	a0,s2
    80004b64:	64e2                	ld	s1,24(sp)
    80004b66:	6942                	ld	s2,16(sp)
}
    80004b68:	70a2                	ld	ra,40(sp)
    80004b6a:	7402                	ld	s0,32(sp)
    80004b6c:	6145                	addi	sp,sp,48
    80004b6e:	8082                	ret
    80004b70:	64e2                	ld	s1,24(sp)
    80004b72:	6942                	ld	s2,16(sp)
    return -1;
    80004b74:	557d                	li	a0,-1
    80004b76:	bfcd                	j	80004b68 <sys_dup+0x38>

0000000080004b78 <sys_read>:
{
    80004b78:	7179                	addi	sp,sp,-48
    80004b7a:	f406                	sd	ra,40(sp)
    80004b7c:	f022                	sd	s0,32(sp)
    80004b7e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004b80:	fd840593          	addi	a1,s0,-40
    80004b84:	4505                	li	a0,1
    80004b86:	c8dfd0ef          	jal	80002812 <argaddr>
  argint(2, &n);
    80004b8a:	fe440593          	addi	a1,s0,-28
    80004b8e:	4509                	li	a0,2
    80004b90:	c67fd0ef          	jal	800027f6 <argint>
  if(argfd(0, 0, &f) < 0)
    80004b94:	fe840613          	addi	a2,s0,-24
    80004b98:	4581                	li	a1,0
    80004b9a:	4501                	li	a0,0
    80004b9c:	dcfff0ef          	jal	8000496a <argfd>
    80004ba0:	87aa                	mv	a5,a0
    return -1;
    80004ba2:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004ba4:	0007ca63          	bltz	a5,80004bb8 <sys_read+0x40>
  return fileread(f, p, n);
    80004ba8:	fe442603          	lw	a2,-28(s0)
    80004bac:	fd843583          	ld	a1,-40(s0)
    80004bb0:	fe843503          	ld	a0,-24(s0)
    80004bb4:	d86ff0ef          	jal	8000413a <fileread>
}
    80004bb8:	70a2                	ld	ra,40(sp)
    80004bba:	7402                	ld	s0,32(sp)
    80004bbc:	6145                	addi	sp,sp,48
    80004bbe:	8082                	ret

0000000080004bc0 <sys_write>:
{
    80004bc0:	7179                	addi	sp,sp,-48
    80004bc2:	f406                	sd	ra,40(sp)
    80004bc4:	f022                	sd	s0,32(sp)
    80004bc6:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004bc8:	fd840593          	addi	a1,s0,-40
    80004bcc:	4505                	li	a0,1
    80004bce:	c45fd0ef          	jal	80002812 <argaddr>
  argint(2, &n);
    80004bd2:	fe440593          	addi	a1,s0,-28
    80004bd6:	4509                	li	a0,2
    80004bd8:	c1ffd0ef          	jal	800027f6 <argint>
  if(argfd(0, 0, &f) < 0)
    80004bdc:	fe840613          	addi	a2,s0,-24
    80004be0:	4581                	li	a1,0
    80004be2:	4501                	li	a0,0
    80004be4:	d87ff0ef          	jal	8000496a <argfd>
    80004be8:	87aa                	mv	a5,a0
    return -1;
    80004bea:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004bec:	0007ca63          	bltz	a5,80004c00 <sys_write+0x40>
  return filewrite(f, p, n);
    80004bf0:	fe442603          	lw	a2,-28(s0)
    80004bf4:	fd843583          	ld	a1,-40(s0)
    80004bf8:	fe843503          	ld	a0,-24(s0)
    80004bfc:	df8ff0ef          	jal	800041f4 <filewrite>
}
    80004c00:	70a2                	ld	ra,40(sp)
    80004c02:	7402                	ld	s0,32(sp)
    80004c04:	6145                	addi	sp,sp,48
    80004c06:	8082                	ret

0000000080004c08 <sys_close>:
{
    80004c08:	1101                	addi	sp,sp,-32
    80004c0a:	ec06                	sd	ra,24(sp)
    80004c0c:	e822                	sd	s0,16(sp)
    80004c0e:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004c10:	fe040613          	addi	a2,s0,-32
    80004c14:	fec40593          	addi	a1,s0,-20
    80004c18:	4501                	li	a0,0
    80004c1a:	d51ff0ef          	jal	8000496a <argfd>
    return -1;
    80004c1e:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004c20:	02054063          	bltz	a0,80004c40 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004c24:	ce1fc0ef          	jal	80001904 <myproc>
    80004c28:	fec42783          	lw	a5,-20(s0)
    80004c2c:	07e9                	addi	a5,a5,26
    80004c2e:	078e                	slli	a5,a5,0x3
    80004c30:	953e                	add	a0,a0,a5
    80004c32:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004c36:	fe043503          	ld	a0,-32(s0)
    80004c3a:	bdcff0ef          	jal	80004016 <fileclose>
  return 0;
    80004c3e:	4781                	li	a5,0
}
    80004c40:	853e                	mv	a0,a5
    80004c42:	60e2                	ld	ra,24(sp)
    80004c44:	6442                	ld	s0,16(sp)
    80004c46:	6105                	addi	sp,sp,32
    80004c48:	8082                	ret

0000000080004c4a <sys_fstat>:
{
    80004c4a:	1101                	addi	sp,sp,-32
    80004c4c:	ec06                	sd	ra,24(sp)
    80004c4e:	e822                	sd	s0,16(sp)
    80004c50:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004c52:	fe040593          	addi	a1,s0,-32
    80004c56:	4505                	li	a0,1
    80004c58:	bbbfd0ef          	jal	80002812 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004c5c:	fe840613          	addi	a2,s0,-24
    80004c60:	4581                	li	a1,0
    80004c62:	4501                	li	a0,0
    80004c64:	d07ff0ef          	jal	8000496a <argfd>
    80004c68:	87aa                	mv	a5,a0
    return -1;
    80004c6a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004c6c:	0007c863          	bltz	a5,80004c7c <sys_fstat+0x32>
  return filestat(f, st);
    80004c70:	fe043583          	ld	a1,-32(s0)
    80004c74:	fe843503          	ld	a0,-24(s0)
    80004c78:	c60ff0ef          	jal	800040d8 <filestat>
}
    80004c7c:	60e2                	ld	ra,24(sp)
    80004c7e:	6442                	ld	s0,16(sp)
    80004c80:	6105                	addi	sp,sp,32
    80004c82:	8082                	ret

0000000080004c84 <sys_link>:
{
    80004c84:	7169                	addi	sp,sp,-304
    80004c86:	f606                	sd	ra,296(sp)
    80004c88:	f222                	sd	s0,288(sp)
    80004c8a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004c8c:	08000613          	li	a2,128
    80004c90:	ed040593          	addi	a1,s0,-304
    80004c94:	4501                	li	a0,0
    80004c96:	b99fd0ef          	jal	8000282e <argstr>
    80004c9a:	0c054a63          	bltz	a0,80004d6e <sys_link+0xea>
    80004c9e:	08000613          	li	a2,128
    80004ca2:	f5040593          	addi	a1,s0,-176
    80004ca6:	4505                	li	a0,1
    80004ca8:	b87fd0ef          	jal	8000282e <argstr>
    80004cac:	0c054163          	bltz	a0,80004d6e <sys_link+0xea>
    80004cb0:	ee26                	sd	s1,280(sp)
  begin_op();
    80004cb2:	f45fe0ef          	jal	80003bf6 <begin_op>
  if((ip = namei(old)) == 0){
    80004cb6:	ed040513          	addi	a0,s0,-304
    80004cba:	d5ffe0ef          	jal	80003a18 <namei>
    80004cbe:	84aa                	mv	s1,a0
    80004cc0:	c53d                	beqz	a0,80004d2e <sys_link+0xaa>
  ilock(ip);
    80004cc2:	d1efe0ef          	jal	800031e0 <ilock>
  if(ip->type == T_DIR){
    80004cc6:	04449703          	lh	a4,68(s1)
    80004cca:	4785                	li	a5,1
    80004ccc:	06f70563          	beq	a4,a5,80004d36 <sys_link+0xb2>
    80004cd0:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004cd2:	04a4d783          	lhu	a5,74(s1)
    80004cd6:	2785                	addiw	a5,a5,1
    80004cd8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004cdc:	8526                	mv	a0,s1
    80004cde:	c4efe0ef          	jal	8000312c <iupdate>
  iunlock(ip);
    80004ce2:	8526                	mv	a0,s1
    80004ce4:	daafe0ef          	jal	8000328e <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004ce8:	fd040593          	addi	a1,s0,-48
    80004cec:	f5040513          	addi	a0,s0,-176
    80004cf0:	d43fe0ef          	jal	80003a32 <nameiparent>
    80004cf4:	892a                	mv	s2,a0
    80004cf6:	c931                	beqz	a0,80004d4a <sys_link+0xc6>
  ilock(dp);
    80004cf8:	ce8fe0ef          	jal	800031e0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004cfc:	854a                	mv	a0,s2
    80004cfe:	00092703          	lw	a4,0(s2)
    80004d02:	409c                	lw	a5,0(s1)
    80004d04:	04f71063          	bne	a4,a5,80004d44 <sys_link+0xc0>
    80004d08:	40d0                	lw	a2,4(s1)
    80004d0a:	fd040593          	addi	a1,s0,-48
    80004d0e:	c61fe0ef          	jal	8000396e <dirlink>
    80004d12:	02054963          	bltz	a0,80004d44 <sys_link+0xc0>
  iunlockput(dp);
    80004d16:	854a                	mv	a0,s2
    80004d18:	ed4fe0ef          	jal	800033ec <iunlockput>
  iput(ip);
    80004d1c:	8526                	mv	a0,s1
    80004d1e:	e44fe0ef          	jal	80003362 <iput>
  end_op();
    80004d22:	f45fe0ef          	jal	80003c66 <end_op>
  return 0;
    80004d26:	4501                	li	a0,0
    80004d28:	64f2                	ld	s1,280(sp)
    80004d2a:	6952                	ld	s2,272(sp)
    80004d2c:	a091                	j	80004d70 <sys_link+0xec>
    end_op();
    80004d2e:	f39fe0ef          	jal	80003c66 <end_op>
    return -1;
    80004d32:	64f2                	ld	s1,280(sp)
    80004d34:	a82d                	j	80004d6e <sys_link+0xea>
    iunlockput(ip);
    80004d36:	8526                	mv	a0,s1
    80004d38:	eb4fe0ef          	jal	800033ec <iunlockput>
    end_op();
    80004d3c:	f2bfe0ef          	jal	80003c66 <end_op>
    return -1;
    80004d40:	64f2                	ld	s1,280(sp)
    80004d42:	a035                	j	80004d6e <sys_link+0xea>
    iunlockput(dp);
    80004d44:	854a                	mv	a0,s2
    80004d46:	ea6fe0ef          	jal	800033ec <iunlockput>
  ilock(ip);
    80004d4a:	8526                	mv	a0,s1
    80004d4c:	c94fe0ef          	jal	800031e0 <ilock>
  ip->nlink--;
    80004d50:	04a4d783          	lhu	a5,74(s1)
    80004d54:	37fd                	addiw	a5,a5,-1
    80004d56:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004d5a:	8526                	mv	a0,s1
    80004d5c:	bd0fe0ef          	jal	8000312c <iupdate>
  iunlockput(ip);
    80004d60:	8526                	mv	a0,s1
    80004d62:	e8afe0ef          	jal	800033ec <iunlockput>
  end_op();
    80004d66:	f01fe0ef          	jal	80003c66 <end_op>
  return -1;
    80004d6a:	64f2                	ld	s1,280(sp)
    80004d6c:	6952                	ld	s2,272(sp)
    return -1;
    80004d6e:	557d                	li	a0,-1
}
    80004d70:	70b2                	ld	ra,296(sp)
    80004d72:	7412                	ld	s0,288(sp)
    80004d74:	6155                	addi	sp,sp,304
    80004d76:	8082                	ret

0000000080004d78 <sys_unlink>:
{
    80004d78:	7151                	addi	sp,sp,-240
    80004d7a:	f586                	sd	ra,232(sp)
    80004d7c:	f1a2                	sd	s0,224(sp)
    80004d7e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004d80:	08000613          	li	a2,128
    80004d84:	f3040593          	addi	a1,s0,-208
    80004d88:	4501                	li	a0,0
    80004d8a:	aa5fd0ef          	jal	8000282e <argstr>
    80004d8e:	14054763          	bltz	a0,80004edc <sys_unlink+0x164>
    80004d92:	eda6                	sd	s1,216(sp)
  begin_op();
    80004d94:	e63fe0ef          	jal	80003bf6 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004d98:	fb040593          	addi	a1,s0,-80
    80004d9c:	f3040513          	addi	a0,s0,-208
    80004da0:	c93fe0ef          	jal	80003a32 <nameiparent>
    80004da4:	84aa                	mv	s1,a0
    80004da6:	c955                	beqz	a0,80004e5a <sys_unlink+0xe2>
  ilock(dp);
    80004da8:	c38fe0ef          	jal	800031e0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004dac:	00003597          	auipc	a1,0x3
    80004db0:	81458593          	addi	a1,a1,-2028 # 800075c0 <etext+0x5c0>
    80004db4:	fb040513          	addi	a0,s0,-80
    80004db8:	9affe0ef          	jal	80003766 <namecmp>
    80004dbc:	10050a63          	beqz	a0,80004ed0 <sys_unlink+0x158>
    80004dc0:	00003597          	auipc	a1,0x3
    80004dc4:	80858593          	addi	a1,a1,-2040 # 800075c8 <etext+0x5c8>
    80004dc8:	fb040513          	addi	a0,s0,-80
    80004dcc:	99bfe0ef          	jal	80003766 <namecmp>
    80004dd0:	10050063          	beqz	a0,80004ed0 <sys_unlink+0x158>
    80004dd4:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004dd6:	f2c40613          	addi	a2,s0,-212
    80004dda:	fb040593          	addi	a1,s0,-80
    80004dde:	8526                	mv	a0,s1
    80004de0:	99dfe0ef          	jal	8000377c <dirlookup>
    80004de4:	892a                	mv	s2,a0
    80004de6:	0e050463          	beqz	a0,80004ece <sys_unlink+0x156>
    80004dea:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    80004dec:	bf4fe0ef          	jal	800031e0 <ilock>
  if(ip->nlink < 1)
    80004df0:	04a91783          	lh	a5,74(s2)
    80004df4:	06f05763          	blez	a5,80004e62 <sys_unlink+0xea>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004df8:	04491703          	lh	a4,68(s2)
    80004dfc:	4785                	li	a5,1
    80004dfe:	06f70863          	beq	a4,a5,80004e6e <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80004e02:	fc040993          	addi	s3,s0,-64
    80004e06:	4641                	li	a2,16
    80004e08:	4581                	li	a1,0
    80004e0a:	854e                	mv	a0,s3
    80004e0c:	ef9fb0ef          	jal	80000d04 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004e10:	4741                	li	a4,16
    80004e12:	f2c42683          	lw	a3,-212(s0)
    80004e16:	864e                	mv	a2,s3
    80004e18:	4581                	li	a1,0
    80004e1a:	8526                	mv	a0,s1
    80004e1c:	849fe0ef          	jal	80003664 <writei>
    80004e20:	47c1                	li	a5,16
    80004e22:	08f51763          	bne	a0,a5,80004eb0 <sys_unlink+0x138>
  if(ip->type == T_DIR){
    80004e26:	04491703          	lh	a4,68(s2)
    80004e2a:	4785                	li	a5,1
    80004e2c:	08f70863          	beq	a4,a5,80004ebc <sys_unlink+0x144>
  iunlockput(dp);
    80004e30:	8526                	mv	a0,s1
    80004e32:	dbafe0ef          	jal	800033ec <iunlockput>
  ip->nlink--;
    80004e36:	04a95783          	lhu	a5,74(s2)
    80004e3a:	37fd                	addiw	a5,a5,-1
    80004e3c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004e40:	854a                	mv	a0,s2
    80004e42:	aeafe0ef          	jal	8000312c <iupdate>
  iunlockput(ip);
    80004e46:	854a                	mv	a0,s2
    80004e48:	da4fe0ef          	jal	800033ec <iunlockput>
  end_op();
    80004e4c:	e1bfe0ef          	jal	80003c66 <end_op>
  return 0;
    80004e50:	4501                	li	a0,0
    80004e52:	64ee                	ld	s1,216(sp)
    80004e54:	694e                	ld	s2,208(sp)
    80004e56:	69ae                	ld	s3,200(sp)
    80004e58:	a059                	j	80004ede <sys_unlink+0x166>
    end_op();
    80004e5a:	e0dfe0ef          	jal	80003c66 <end_op>
    return -1;
    80004e5e:	64ee                	ld	s1,216(sp)
    80004e60:	a8b5                	j	80004edc <sys_unlink+0x164>
    panic("unlink: nlink < 1");
    80004e62:	00002517          	auipc	a0,0x2
    80004e66:	76e50513          	addi	a0,a0,1902 # 800075d0 <etext+0x5d0>
    80004e6a:	9cffb0ef          	jal	80000838 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004e6e:	04c92703          	lw	a4,76(s2)
    80004e72:	02000793          	li	a5,32
    80004e76:	f8e7f6e3          	bgeu	a5,a4,80004e02 <sys_unlink+0x8a>
    80004e7a:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004e7c:	4741                	li	a4,16
    80004e7e:	86ce                	mv	a3,s3
    80004e80:	f1840613          	addi	a2,s0,-232
    80004e84:	4581                	li	a1,0
    80004e86:	854a                	mv	a0,s2
    80004e88:	eeafe0ef          	jal	80003572 <readi>
    80004e8c:	47c1                	li	a5,16
    80004e8e:	00f51b63          	bne	a0,a5,80004ea4 <sys_unlink+0x12c>
    if(de.inum != 0)
    80004e92:	f1845783          	lhu	a5,-232(s0)
    80004e96:	eba1                	bnez	a5,80004ee6 <sys_unlink+0x16e>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004e98:	29c1                	addiw	s3,s3,16
    80004e9a:	04c92783          	lw	a5,76(s2)
    80004e9e:	fcf9efe3          	bltu	s3,a5,80004e7c <sys_unlink+0x104>
    80004ea2:	b785                	j	80004e02 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80004ea4:	00002517          	auipc	a0,0x2
    80004ea8:	74450513          	addi	a0,a0,1860 # 800075e8 <etext+0x5e8>
    80004eac:	98dfb0ef          	jal	80000838 <panic>
    panic("unlink: writei");
    80004eb0:	00002517          	auipc	a0,0x2
    80004eb4:	75050513          	addi	a0,a0,1872 # 80007600 <etext+0x600>
    80004eb8:	981fb0ef          	jal	80000838 <panic>
    dp->nlink--;
    80004ebc:	04a4d783          	lhu	a5,74(s1)
    80004ec0:	37fd                	addiw	a5,a5,-1
    80004ec2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004ec6:	8526                	mv	a0,s1
    80004ec8:	a64fe0ef          	jal	8000312c <iupdate>
    80004ecc:	b795                	j	80004e30 <sys_unlink+0xb8>
    80004ece:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80004ed0:	8526                	mv	a0,s1
    80004ed2:	d1afe0ef          	jal	800033ec <iunlockput>
  end_op();
    80004ed6:	d91fe0ef          	jal	80003c66 <end_op>
  return -1;
    80004eda:	64ee                	ld	s1,216(sp)
    return -1;
    80004edc:	557d                	li	a0,-1
}
    80004ede:	70ae                	ld	ra,232(sp)
    80004ee0:	740e                	ld	s0,224(sp)
    80004ee2:	616d                	addi	sp,sp,240
    80004ee4:	8082                	ret
    iunlockput(ip);
    80004ee6:	854a                	mv	a0,s2
    80004ee8:	d04fe0ef          	jal	800033ec <iunlockput>
    goto bad;
    80004eec:	694e                	ld	s2,208(sp)
    80004eee:	69ae                	ld	s3,200(sp)
    80004ef0:	b7c5                	j	80004ed0 <sys_unlink+0x158>

0000000080004ef2 <sys_open>:

uint64
sys_open(void)
{
    80004ef2:	7131                	addi	sp,sp,-192
    80004ef4:	fd06                	sd	ra,184(sp)
    80004ef6:	f922                	sd	s0,176(sp)
    80004ef8:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004efa:	f4c40593          	addi	a1,s0,-180
    80004efe:	4505                	li	a0,1
    80004f00:	8f7fd0ef          	jal	800027f6 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004f04:	08000613          	li	a2,128
    80004f08:	f5040593          	addi	a1,s0,-176
    80004f0c:	4501                	li	a0,0
    80004f0e:	921fd0ef          	jal	8000282e <argstr>
    80004f12:	10054563          	bltz	a0,8000501c <sys_open+0x12a>
    80004f16:	f526                	sd	s1,168(sp)
    return -1;

  begin_op();
    80004f18:	cdffe0ef          	jal	80003bf6 <begin_op>

  if(omode & O_CREATE){
    80004f1c:	f4c42783          	lw	a5,-180(s0)
    80004f20:	2007f793          	andi	a5,a5,512
    80004f24:	cfd9                	beqz	a5,80004fc2 <sys_open+0xd0>
    ip = create(path, T_FILE, 0, 0);
    80004f26:	4681                	li	a3,0
    80004f28:	4601                	li	a2,0
    80004f2a:	4589                	li	a1,2
    80004f2c:	f5040513          	addi	a0,s0,-176
    80004f30:	acdff0ef          	jal	800049fc <create>
    80004f34:	84aa                	mv	s1,a0
    if(ip == 0){
    80004f36:	c151                	beqz	a0,80004fba <sys_open+0xc8>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004f38:	04449703          	lh	a4,68(s1)
    80004f3c:	478d                	li	a5,3
    80004f3e:	00f71763          	bne	a4,a5,80004f4c <sys_open+0x5a>
    80004f42:	0464d703          	lhu	a4,70(s1)
    80004f46:	47a5                	li	a5,9
    80004f48:	0ae7e863          	bltu	a5,a4,80004ff8 <sys_open+0x106>
    80004f4c:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004f4e:	824ff0ef          	jal	80003f72 <filealloc>
    80004f52:	892a                	mv	s2,a0
    80004f54:	cd4d                	beqz	a0,8000500e <sys_open+0x11c>
    80004f56:	ed4e                	sd	s3,152(sp)
    80004f58:	a67ff0ef          	jal	800049be <fdalloc>
    80004f5c:	89aa                	mv	s3,a0
    80004f5e:	0a054463          	bltz	a0,80005006 <sys_open+0x114>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004f62:	04449703          	lh	a4,68(s1)
    80004f66:	478d                	li	a5,3
    80004f68:	0af70f63          	beq	a4,a5,80005026 <sys_open+0x134>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004f6c:	4789                	li	a5,2
    80004f6e:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80004f72:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80004f76:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004f7a:	f4c42783          	lw	a5,-180(s0)
    80004f7e:	0017f713          	andi	a4,a5,1
    80004f82:	00174713          	xori	a4,a4,1
    80004f86:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004f8a:	0037f713          	andi	a4,a5,3
    80004f8e:	00e03733          	snez	a4,a4
    80004f92:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004f96:	4007f793          	andi	a5,a5,1024
    80004f9a:	c791                	beqz	a5,80004fa6 <sys_open+0xb4>
    80004f9c:	04449703          	lh	a4,68(s1)
    80004fa0:	4789                	li	a5,2
    80004fa2:	08f70963          	beq	a4,a5,80005034 <sys_open+0x142>
    itrunc(ip);
  }

  iunlock(ip);
    80004fa6:	8526                	mv	a0,s1
    80004fa8:	ae6fe0ef          	jal	8000328e <iunlock>
  end_op();
    80004fac:	cbbfe0ef          	jal	80003c66 <end_op>

  return fd;
    80004fb0:	854e                	mv	a0,s3
    80004fb2:	74aa                	ld	s1,168(sp)
    80004fb4:	790a                	ld	s2,160(sp)
    80004fb6:	69ea                	ld	s3,152(sp)
    80004fb8:	a09d                	j	8000501e <sys_open+0x12c>
      end_op();
    80004fba:	cadfe0ef          	jal	80003c66 <end_op>
      return -1;
    80004fbe:	74aa                	ld	s1,168(sp)
    80004fc0:	a8b1                	j	8000501c <sys_open+0x12a>
    if((ip = namei(path)) == 0){
    80004fc2:	f5040513          	addi	a0,s0,-176
    80004fc6:	a53fe0ef          	jal	80003a18 <namei>
    80004fca:	84aa                	mv	s1,a0
    80004fcc:	c115                	beqz	a0,80004ff0 <sys_open+0xfe>
    ilock(ip);
    80004fce:	a12fe0ef          	jal	800031e0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004fd2:	04449703          	lh	a4,68(s1)
    80004fd6:	4785                	li	a5,1
    80004fd8:	f6f710e3          	bne	a4,a5,80004f38 <sys_open+0x46>
    80004fdc:	f4c42783          	lw	a5,-180(s0)
    80004fe0:	d7b5                	beqz	a5,80004f4c <sys_open+0x5a>
      iunlockput(ip);
    80004fe2:	8526                	mv	a0,s1
    80004fe4:	c08fe0ef          	jal	800033ec <iunlockput>
      end_op();
    80004fe8:	c7ffe0ef          	jal	80003c66 <end_op>
      return -1;
    80004fec:	74aa                	ld	s1,168(sp)
    80004fee:	a03d                	j	8000501c <sys_open+0x12a>
      end_op();
    80004ff0:	c77fe0ef          	jal	80003c66 <end_op>
      return -1;
    80004ff4:	74aa                	ld	s1,168(sp)
    80004ff6:	a01d                	j	8000501c <sys_open+0x12a>
    iunlockput(ip);
    80004ff8:	8526                	mv	a0,s1
    80004ffa:	bf2fe0ef          	jal	800033ec <iunlockput>
    end_op();
    80004ffe:	c69fe0ef          	jal	80003c66 <end_op>
    return -1;
    80005002:	74aa                	ld	s1,168(sp)
    80005004:	a821                	j	8000501c <sys_open+0x12a>
      fileclose(f);
    80005006:	854a                	mv	a0,s2
    80005008:	80eff0ef          	jal	80004016 <fileclose>
    8000500c:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000500e:	8526                	mv	a0,s1
    80005010:	bdcfe0ef          	jal	800033ec <iunlockput>
    end_op();
    80005014:	c53fe0ef          	jal	80003c66 <end_op>
    return -1;
    80005018:	74aa                	ld	s1,168(sp)
    8000501a:	790a                	ld	s2,160(sp)
    return -1;
    8000501c:	557d                	li	a0,-1
}
    8000501e:	70ea                	ld	ra,184(sp)
    80005020:	744a                	ld	s0,176(sp)
    80005022:	6129                	addi	sp,sp,192
    80005024:	8082                	ret
    f->type = FD_DEVICE;
    80005026:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    8000502a:	04649783          	lh	a5,70(s1)
    8000502e:	02f91223          	sh	a5,36(s2)
    80005032:	b791                	j	80004f76 <sys_open+0x84>
    itrunc(ip);
    80005034:	8526                	mv	a0,s1
    80005036:	a98fe0ef          	jal	800032ce <itrunc>
    8000503a:	b7b5                	j	80004fa6 <sys_open+0xb4>

000000008000503c <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000503c:	7175                	addi	sp,sp,-144
    8000503e:	e506                	sd	ra,136(sp)
    80005040:	e122                	sd	s0,128(sp)
    80005042:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005044:	bb3fe0ef          	jal	80003bf6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005048:	08000613          	li	a2,128
    8000504c:	f7040593          	addi	a1,s0,-144
    80005050:	4501                	li	a0,0
    80005052:	fdcfd0ef          	jal	8000282e <argstr>
    80005056:	02054363          	bltz	a0,8000507c <sys_mkdir+0x40>
    8000505a:	4681                	li	a3,0
    8000505c:	4601                	li	a2,0
    8000505e:	4585                	li	a1,1
    80005060:	f7040513          	addi	a0,s0,-144
    80005064:	999ff0ef          	jal	800049fc <create>
    80005068:	c911                	beqz	a0,8000507c <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000506a:	b82fe0ef          	jal	800033ec <iunlockput>
  end_op();
    8000506e:	bf9fe0ef          	jal	80003c66 <end_op>
  return 0;
    80005072:	4501                	li	a0,0
}
    80005074:	60aa                	ld	ra,136(sp)
    80005076:	640a                	ld	s0,128(sp)
    80005078:	6149                	addi	sp,sp,144
    8000507a:	8082                	ret
    end_op();
    8000507c:	bebfe0ef          	jal	80003c66 <end_op>
    return -1;
    80005080:	557d                	li	a0,-1
    80005082:	bfcd                	j	80005074 <sys_mkdir+0x38>

0000000080005084 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005084:	7135                	addi	sp,sp,-160
    80005086:	ed06                	sd	ra,152(sp)
    80005088:	e922                	sd	s0,144(sp)
    8000508a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000508c:	b6bfe0ef          	jal	80003bf6 <begin_op>
  argint(1, &major);
    80005090:	f6c40593          	addi	a1,s0,-148
    80005094:	4505                	li	a0,1
    80005096:	f60fd0ef          	jal	800027f6 <argint>
  argint(2, &minor);
    8000509a:	f6840593          	addi	a1,s0,-152
    8000509e:	4509                	li	a0,2
    800050a0:	f56fd0ef          	jal	800027f6 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800050a4:	08000613          	li	a2,128
    800050a8:	f7040593          	addi	a1,s0,-144
    800050ac:	4501                	li	a0,0
    800050ae:	f80fd0ef          	jal	8000282e <argstr>
    800050b2:	02054563          	bltz	a0,800050dc <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800050b6:	f6841683          	lh	a3,-152(s0)
    800050ba:	f6c41603          	lh	a2,-148(s0)
    800050be:	458d                	li	a1,3
    800050c0:	f7040513          	addi	a0,s0,-144
    800050c4:	939ff0ef          	jal	800049fc <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800050c8:	c911                	beqz	a0,800050dc <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800050ca:	b22fe0ef          	jal	800033ec <iunlockput>
  end_op();
    800050ce:	b99fe0ef          	jal	80003c66 <end_op>
  return 0;
    800050d2:	4501                	li	a0,0
}
    800050d4:	60ea                	ld	ra,152(sp)
    800050d6:	644a                	ld	s0,144(sp)
    800050d8:	610d                	addi	sp,sp,160
    800050da:	8082                	ret
    end_op();
    800050dc:	b8bfe0ef          	jal	80003c66 <end_op>
    return -1;
    800050e0:	557d                	li	a0,-1
    800050e2:	bfcd                	j	800050d4 <sys_mknod+0x50>

00000000800050e4 <sys_chdir>:

uint64
sys_chdir(void)
{
    800050e4:	7135                	addi	sp,sp,-160
    800050e6:	ed06                	sd	ra,152(sp)
    800050e8:	e922                	sd	s0,144(sp)
    800050ea:	e14a                	sd	s2,128(sp)
    800050ec:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800050ee:	817fc0ef          	jal	80001904 <myproc>
    800050f2:	892a                	mv	s2,a0
  
  begin_op();
    800050f4:	b03fe0ef          	jal	80003bf6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800050f8:	08000613          	li	a2,128
    800050fc:	f6040593          	addi	a1,s0,-160
    80005100:	4501                	li	a0,0
    80005102:	f2cfd0ef          	jal	8000282e <argstr>
    80005106:	02054f63          	bltz	a0,80005144 <sys_chdir+0x60>
    8000510a:	e526                	sd	s1,136(sp)
    8000510c:	f6040513          	addi	a0,s0,-160
    80005110:	909fe0ef          	jal	80003a18 <namei>
    80005114:	84aa                	mv	s1,a0
    80005116:	c515                	beqz	a0,80005142 <sys_chdir+0x5e>
    end_op();
    return -1;
  }
  ilock(ip);
    80005118:	8c8fe0ef          	jal	800031e0 <ilock>
  if(ip->type != T_DIR){
    8000511c:	04449703          	lh	a4,68(s1)
    80005120:	4785                	li	a5,1
    80005122:	02f71963          	bne	a4,a5,80005154 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005126:	8526                	mv	a0,s1
    80005128:	966fe0ef          	jal	8000328e <iunlock>
  iput(p->cwd);
    8000512c:	15093503          	ld	a0,336(s2)
    80005130:	a32fe0ef          	jal	80003362 <iput>
  end_op();
    80005134:	b33fe0ef          	jal	80003c66 <end_op>
  p->cwd = ip;
    80005138:	14993823          	sd	s1,336(s2)
  return 0;
    8000513c:	4501                	li	a0,0
    8000513e:	64aa                	ld	s1,136(sp)
    80005140:	a029                	j	8000514a <sys_chdir+0x66>
    80005142:	64aa                	ld	s1,136(sp)
    end_op();
    80005144:	b23fe0ef          	jal	80003c66 <end_op>
    return -1;
    80005148:	557d                	li	a0,-1
}
    8000514a:	60ea                	ld	ra,152(sp)
    8000514c:	644a                	ld	s0,144(sp)
    8000514e:	690a                	ld	s2,128(sp)
    80005150:	610d                	addi	sp,sp,160
    80005152:	8082                	ret
    iunlockput(ip);
    80005154:	8526                	mv	a0,s1
    80005156:	a96fe0ef          	jal	800033ec <iunlockput>
    end_op();
    8000515a:	b0dfe0ef          	jal	80003c66 <end_op>
    return -1;
    8000515e:	64aa                	ld	s1,136(sp)
    80005160:	b7e5                	j	80005148 <sys_chdir+0x64>

0000000080005162 <sys_exec>:

uint64
sys_exec(void)
{
    80005162:	7105                	addi	sp,sp,-480
    80005164:	ef86                	sd	ra,472(sp)
    80005166:	eba2                	sd	s0,464(sp)
    80005168:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000516a:	e2840593          	addi	a1,s0,-472
    8000516e:	4505                	li	a0,1
    80005170:	ea2fd0ef          	jal	80002812 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005174:	08000613          	li	a2,128
    80005178:	f3040593          	addi	a1,s0,-208
    8000517c:	4501                	li	a0,0
    8000517e:	eb0fd0ef          	jal	8000282e <argstr>
    80005182:	0c054e63          	bltz	a0,8000525e <sys_exec+0xfc>
    80005186:	e7a6                	sd	s1,456(sp)
    80005188:	e3ca                	sd	s2,448(sp)
    8000518a:	ff4e                	sd	s3,440(sp)
    8000518c:	fb52                	sd	s4,432(sp)
    8000518e:	f756                	sd	s5,424(sp)
    80005190:	f35a                	sd	s6,416(sp)
    80005192:	ef5e                	sd	s7,408(sp)
    return -1;
  }
  memset(argv, 0, sizeof(argv));
    80005194:	e3040a13          	addi	s4,s0,-464
    80005198:	10000613          	li	a2,256
    8000519c:	4581                	li	a1,0
    8000519e:	8552                	mv	a0,s4
    800051a0:	b65fb0ef          	jal	80000d04 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800051a4:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    800051a6:	89d2                	mv	s3,s4
    800051a8:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800051aa:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800051ae:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    800051b0:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800051b4:	00391513          	slli	a0,s2,0x3
    800051b8:	85d6                	mv	a1,s5
    800051ba:	e2843783          	ld	a5,-472(s0)
    800051be:	953e                	add	a0,a0,a5
    800051c0:	db0fd0ef          	jal	80002770 <fetchaddr>
    800051c4:	02054663          	bltz	a0,800051f0 <sys_exec+0x8e>
    if(uarg == 0){
    800051c8:	e2043783          	ld	a5,-480(s0)
    800051cc:	c3b9                	beqz	a5,80005212 <sys_exec+0xb0>
    argv[i] = kalloc();
    800051ce:	987fb0ef          	jal	80000b54 <kalloc>
    800051d2:	85aa                	mv	a1,a0
    800051d4:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800051d8:	cd01                	beqz	a0,800051f0 <sys_exec+0x8e>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800051da:	865a                	mv	a2,s6
    800051dc:	e2043503          	ld	a0,-480(s0)
    800051e0:	dd6fd0ef          	jal	800027b6 <fetchstr>
    800051e4:	00054663          	bltz	a0,800051f0 <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    800051e8:	0905                	addi	s2,s2,1
    800051ea:	09a1                	addi	s3,s3,8
    800051ec:	fd7914e3          	bne	s2,s7,800051b4 <sys_exec+0x52>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800051f0:	100a0a13          	addi	s4,s4,256
    800051f4:	6088                	ld	a0,0(s1)
    800051f6:	cd29                	beqz	a0,80005250 <sys_exec+0xee>
    kfree(argv[i]);
    800051f8:	875fb0ef          	jal	80000a6c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800051fc:	04a1                	addi	s1,s1,8
    800051fe:	ff449be3          	bne	s1,s4,800051f4 <sys_exec+0x92>
    80005202:	64be                	ld	s1,456(sp)
    80005204:	691e                	ld	s2,448(sp)
    80005206:	79fa                	ld	s3,440(sp)
    80005208:	7a5a                	ld	s4,432(sp)
    8000520a:	7aba                	ld	s5,424(sp)
    8000520c:	7b1a                	ld	s6,416(sp)
    8000520e:	6bfa                	ld	s7,408(sp)
    80005210:	a0b9                	j	8000525e <sys_exec+0xfc>
      argv[i] = 0;
    80005212:	0009079b          	sext.w	a5,s2
    80005216:	e3040593          	addi	a1,s0,-464
    8000521a:	078e                	slli	a5,a5,0x3
    8000521c:	97ae                	add	a5,a5,a1
    8000521e:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    80005222:	f3040513          	addi	a0,s0,-208
    80005226:	c30ff0ef          	jal	80004656 <kexec>
    8000522a:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000522c:	100a0a13          	addi	s4,s4,256
    80005230:	6088                	ld	a0,0(s1)
    80005232:	c511                	beqz	a0,8000523e <sys_exec+0xdc>
    kfree(argv[i]);
    80005234:	839fb0ef          	jal	80000a6c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005238:	04a1                	addi	s1,s1,8
    8000523a:	ff449be3          	bne	s1,s4,80005230 <sys_exec+0xce>
  return ret;
    8000523e:	854a                	mv	a0,s2
    80005240:	64be                	ld	s1,456(sp)
    80005242:	691e                	ld	s2,448(sp)
    80005244:	79fa                	ld	s3,440(sp)
    80005246:	7a5a                	ld	s4,432(sp)
    80005248:	7aba                	ld	s5,424(sp)
    8000524a:	7b1a                	ld	s6,416(sp)
    8000524c:	6bfa                	ld	s7,408(sp)
    8000524e:	a809                	j	80005260 <sys_exec+0xfe>
    80005250:	64be                	ld	s1,456(sp)
    80005252:	691e                	ld	s2,448(sp)
    80005254:	79fa                	ld	s3,440(sp)
    80005256:	7a5a                	ld	s4,432(sp)
    80005258:	7aba                	ld	s5,424(sp)
    8000525a:	7b1a                	ld	s6,416(sp)
    8000525c:	6bfa                	ld	s7,408(sp)
    return -1;
    8000525e:	557d                	li	a0,-1
  return -1;
}
    80005260:	60fe                	ld	ra,472(sp)
    80005262:	645e                	ld	s0,464(sp)
    80005264:	613d                	addi	sp,sp,480
    80005266:	8082                	ret

0000000080005268 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005268:	7139                	addi	sp,sp,-64
    8000526a:	fc06                	sd	ra,56(sp)
    8000526c:	f822                	sd	s0,48(sp)
    8000526e:	f426                	sd	s1,40(sp)
    80005270:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005272:	e92fc0ef          	jal	80001904 <myproc>
    80005276:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005278:	fd840593          	addi	a1,s0,-40
    8000527c:	4501                	li	a0,0
    8000527e:	d94fd0ef          	jal	80002812 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005282:	fc840593          	addi	a1,s0,-56
    80005286:	fd040513          	addi	a0,s0,-48
    8000528a:	89aff0ef          	jal	80004324 <pipealloc>
    8000528e:	0a054463          	bltz	a0,80005336 <sys_pipe+0xce>
    return -1;
  fd0 = -1;
    80005292:	57fd                	li	a5,-1
    80005294:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005298:	fd043503          	ld	a0,-48(s0)
    8000529c:	f22ff0ef          	jal	800049be <fdalloc>
    800052a0:	fca42223          	sw	a0,-60(s0)
    800052a4:	08054163          	bltz	a0,80005326 <sys_pipe+0xbe>
    800052a8:	fc843503          	ld	a0,-56(s0)
    800052ac:	f12ff0ef          	jal	800049be <fdalloc>
    800052b0:	fca42023          	sw	a0,-64(s0)
    800052b4:	06054063          	bltz	a0,80005314 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800052b8:	4691                	li	a3,4
    800052ba:	fc440613          	addi	a2,s0,-60
    800052be:	fd843583          	ld	a1,-40(s0)
    800052c2:	68a8                	ld	a0,80(s1)
    800052c4:	b78fc0ef          	jal	8000163c <copyout>
    800052c8:	00054f63          	bltz	a0,800052e6 <sys_pipe+0x7e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800052cc:	4691                	li	a3,4
    800052ce:	fc040613          	addi	a2,s0,-64
    800052d2:	fd843583          	ld	a1,-40(s0)
    800052d6:	95b6                	add	a1,a1,a3
    800052d8:	68a8                	ld	a0,80(s1)
    800052da:	b62fc0ef          	jal	8000163c <copyout>
    800052de:	87aa                	mv	a5,a0
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800052e0:	4501                	li	a0,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800052e2:	0407db63          	bgez	a5,80005338 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800052e6:	fc442783          	lw	a5,-60(s0)
    800052ea:	07e9                	addi	a5,a5,26
    800052ec:	078e                	slli	a5,a5,0x3
    800052ee:	97a6                	add	a5,a5,s1
    800052f0:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800052f4:	fc042783          	lw	a5,-64(s0)
    800052f8:	07e9                	addi	a5,a5,26
    800052fa:	078e                	slli	a5,a5,0x3
    800052fc:	97a6                	add	a5,a5,s1
    800052fe:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005302:	fd043503          	ld	a0,-48(s0)
    80005306:	d11fe0ef          	jal	80004016 <fileclose>
    fileclose(wf);
    8000530a:	fc843503          	ld	a0,-56(s0)
    8000530e:	d09fe0ef          	jal	80004016 <fileclose>
    return -1;
    80005312:	a015                	j	80005336 <sys_pipe+0xce>
    if(fd0 >= 0)
    80005314:	fc442783          	lw	a5,-60(s0)
    80005318:	0007c763          	bltz	a5,80005326 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    8000531c:	07e9                	addi	a5,a5,26
    8000531e:	078e                	slli	a5,a5,0x3
    80005320:	97a6                	add	a5,a5,s1
    80005322:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005326:	fd043503          	ld	a0,-48(s0)
    8000532a:	cedfe0ef          	jal	80004016 <fileclose>
    fileclose(wf);
    8000532e:	fc843503          	ld	a0,-56(s0)
    80005332:	ce5fe0ef          	jal	80004016 <fileclose>
    return -1;
    80005336:	557d                	li	a0,-1
}
    80005338:	70e2                	ld	ra,56(sp)
    8000533a:	7442                	ld	s0,48(sp)
    8000533c:	74a2                	ld	s1,40(sp)
    8000533e:	6121                	addi	sp,sp,64
    80005340:	8082                	ret
	...

0000000080005350 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005350:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005352:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005354:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005356:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005358:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000535a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000535c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000535e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005360:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005362:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005364:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005366:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005368:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000536a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000536c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000536e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005370:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005372:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005374:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005376:	b08fd0ef          	jal	8000267e <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000537a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000537c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000537e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005380:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005382:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005384:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005386:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005388:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000538a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000538c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000538e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005390:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005392:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005394:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005396:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005398:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000539a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000539c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000539e:	10200073          	sret
    800053a2:	00000013          	nop
    800053a6:	00000013          	nop
    800053aa:	00000013          	nop

00000000800053ae <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800053ae:	1141                	addi	sp,sp,-16
    800053b0:	e406                	sd	ra,8(sp)
    800053b2:	e022                	sd	s0,0(sp)
    800053b4:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800053b6:	0c000737          	lui	a4,0xc000
    800053ba:	4785                	li	a5,1
    800053bc:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800053be:	c35c                	sw	a5,4(a4)
}
    800053c0:	60a2                	ld	ra,8(sp)
    800053c2:	6402                	ld	s0,0(sp)
    800053c4:	0141                	addi	sp,sp,16
    800053c6:	8082                	ret

00000000800053c8 <plicinithart>:

void
plicinithart(void)
{
    800053c8:	1141                	addi	sp,sp,-16
    800053ca:	e406                	sd	ra,8(sp)
    800053cc:	e022                	sd	s0,0(sp)
    800053ce:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800053d0:	d00fc0ef          	jal	800018d0 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800053d4:	0085171b          	slliw	a4,a0,0x8
    800053d8:	0c0027b7          	lui	a5,0xc002
    800053dc:	97ba                	add	a5,a5,a4
    800053de:	40200713          	li	a4,1026
    800053e2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800053e6:	00d5151b          	slliw	a0,a0,0xd
    800053ea:	0c2017b7          	lui	a5,0xc201
    800053ee:	97aa                	add	a5,a5,a0
    800053f0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800053f4:	60a2                	ld	ra,8(sp)
    800053f6:	6402                	ld	s0,0(sp)
    800053f8:	0141                	addi	sp,sp,16
    800053fa:	8082                	ret

00000000800053fc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800053fc:	1141                	addi	sp,sp,-16
    800053fe:	e406                	sd	ra,8(sp)
    80005400:	e022                	sd	s0,0(sp)
    80005402:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005404:	cccfc0ef          	jal	800018d0 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005408:	00d5151b          	slliw	a0,a0,0xd
    8000540c:	0c2017b7          	lui	a5,0xc201
    80005410:	97aa                	add	a5,a5,a0
  return irq;
}
    80005412:	43c8                	lw	a0,4(a5)
    80005414:	60a2                	ld	ra,8(sp)
    80005416:	6402                	ld	s0,0(sp)
    80005418:	0141                	addi	sp,sp,16
    8000541a:	8082                	ret

000000008000541c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000541c:	1101                	addi	sp,sp,-32
    8000541e:	ec06                	sd	ra,24(sp)
    80005420:	e822                	sd	s0,16(sp)
    80005422:	e426                	sd	s1,8(sp)
    80005424:	1000                	addi	s0,sp,32
    80005426:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005428:	ca8fc0ef          	jal	800018d0 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000542c:	00d5179b          	slliw	a5,a0,0xd
    80005430:	0c201737          	lui	a4,0xc201
    80005434:	97ba                	add	a5,a5,a4
    80005436:	c3c4                	sw	s1,4(a5)
}
    80005438:	60e2                	ld	ra,24(sp)
    8000543a:	6442                	ld	s0,16(sp)
    8000543c:	64a2                	ld	s1,8(sp)
    8000543e:	6105                	addi	sp,sp,32
    80005440:	8082                	ret

0000000080005442 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005442:	1141                	addi	sp,sp,-16
    80005444:	e406                	sd	ra,8(sp)
    80005446:	e022                	sd	s0,0(sp)
    80005448:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000544a:	479d                	li	a5,7
    8000544c:	04a7ca63          	blt	a5,a0,800054a0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005450:	0001b797          	auipc	a5,0x1b
    80005454:	5e878793          	addi	a5,a5,1512 # 80020a38 <disk>
    80005458:	97aa                	add	a5,a5,a0
    8000545a:	0187c783          	lbu	a5,24(a5)
    8000545e:	e7b9                	bnez	a5,800054ac <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005460:	00451693          	slli	a3,a0,0x4
    80005464:	0001b797          	auipc	a5,0x1b
    80005468:	5d478793          	addi	a5,a5,1492 # 80020a38 <disk>
    8000546c:	6398                	ld	a4,0(a5)
    8000546e:	9736                	add	a4,a4,a3
    80005470:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    80005474:	6398                	ld	a4,0(a5)
    80005476:	9736                	add	a4,a4,a3
    80005478:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000547c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005480:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005484:	97aa                	add	a5,a5,a0
    80005486:	4705                	li	a4,1
    80005488:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000548c:	0001b517          	auipc	a0,0x1b
    80005490:	5c450513          	addi	a0,a0,1476 # 80020a50 <disk+0x18>
    80005494:	ab5fc0ef          	jal	80001f48 <wakeup>
}
    80005498:	60a2                	ld	ra,8(sp)
    8000549a:	6402                	ld	s0,0(sp)
    8000549c:	0141                	addi	sp,sp,16
    8000549e:	8082                	ret
    panic("free_desc 1");
    800054a0:	00002517          	auipc	a0,0x2
    800054a4:	17050513          	addi	a0,a0,368 # 80007610 <etext+0x610>
    800054a8:	b90fb0ef          	jal	80000838 <panic>
    panic("free_desc 2");
    800054ac:	00002517          	auipc	a0,0x2
    800054b0:	17450513          	addi	a0,a0,372 # 80007620 <etext+0x620>
    800054b4:	b84fb0ef          	jal	80000838 <panic>

00000000800054b8 <virtio_disk_init>:
{
    800054b8:	1101                	addi	sp,sp,-32
    800054ba:	ec06                	sd	ra,24(sp)
    800054bc:	e822                	sd	s0,16(sp)
    800054be:	e426                	sd	s1,8(sp)
    800054c0:	e04a                	sd	s2,0(sp)
    800054c2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800054c4:	00002597          	auipc	a1,0x2
    800054c8:	16c58593          	addi	a1,a1,364 # 80007630 <etext+0x630>
    800054cc:	0001b517          	auipc	a0,0x1b
    800054d0:	69450513          	addi	a0,a0,1684 # 80020b60 <disk+0x128>
    800054d4:	edafb0ef          	jal	80000bae <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800054d8:	100017b7          	lui	a5,0x10001
    800054dc:	4398                	lw	a4,0(a5)
    800054de:	747277b7          	lui	a5,0x74727
    800054e2:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800054e6:	14f71263          	bne	a4,a5,8000562a <virtio_disk_init+0x172>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800054ea:	100017b7          	lui	a5,0x10001
    800054ee:	43d8                	lw	a4,4(a5)
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800054f0:	4789                	li	a5,2
    800054f2:	12f71c63          	bne	a4,a5,8000562a <virtio_disk_init+0x172>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800054f6:	100017b7          	lui	a5,0x10001
    800054fa:	4798                	lw	a4,8(a5)
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800054fc:	4789                	li	a5,2
    800054fe:	12f71663          	bne	a4,a5,8000562a <virtio_disk_init+0x172>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005502:	100017b7          	lui	a5,0x10001
    80005506:	47d8                	lw	a4,12(a5)
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005508:	554d47b7          	lui	a5,0x554d4
    8000550c:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005510:	10f71d63          	bne	a4,a5,8000562a <virtio_disk_init+0x172>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005514:	100017b7          	lui	a5,0x10001
    80005518:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000551c:	4705                	li	a4,1
    8000551e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005520:	470d                	li	a4,3
    80005522:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005524:	10001737          	lui	a4,0x10001
    80005528:	4b18                	lw	a4,16(a4)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000552a:	c7ffe6b7          	lui	a3,0xc7ffe
    8000552e:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fddbe7>
    80005532:	8f75                	and	a4,a4,a3
    80005534:	100016b7          	lui	a3,0x10001
    80005538:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000553a:	472d                	li	a4,11
    8000553c:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    8000553e:	0707a903          	lw	s2,112(a5)
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005542:	00897793          	andi	a5,s2,8
    80005546:	0e078863          	beqz	a5,80005636 <virtio_disk_init+0x17e>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000554a:	100017b7          	lui	a5,0x10001
    8000554e:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005552:	43fc                	lw	a5,68(a5)
    80005554:	0e079763          	bnez	a5,80005642 <virtio_disk_init+0x18a>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005558:	100017b7          	lui	a5,0x10001
    8000555c:	5bdc                	lw	a5,52(a5)
  if(max == 0)
    8000555e:	0e078863          	beqz	a5,8000564e <virtio_disk_init+0x196>
  if(max < NUM)
    80005562:	471d                	li	a4,7
    80005564:	0ef77b63          	bgeu	a4,a5,8000565a <virtio_disk_init+0x1a2>
  disk.desc = kalloc();
    80005568:	decfb0ef          	jal	80000b54 <kalloc>
    8000556c:	0001b497          	auipc	s1,0x1b
    80005570:	4cc48493          	addi	s1,s1,1228 # 80020a38 <disk>
    80005574:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005576:	ddefb0ef          	jal	80000b54 <kalloc>
    8000557a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000557c:	dd8fb0ef          	jal	80000b54 <kalloc>
    80005580:	87aa                	mv	a5,a0
    80005582:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005584:	6088                	ld	a0,0(s1)
    80005586:	0e050063          	beqz	a0,80005666 <virtio_disk_init+0x1ae>
    8000558a:	0001b717          	auipc	a4,0x1b
    8000558e:	4b673703          	ld	a4,1206(a4) # 80020a40 <disk+0x8>
    80005592:	00173713          	seqz	a4,a4
    80005596:	0017b793          	seqz	a5,a5
    8000559a:	8fd9                	or	a5,a5,a4
    8000559c:	e7e9                	bnez	a5,80005666 <virtio_disk_init+0x1ae>
  memset(disk.desc, 0, PGSIZE);
    8000559e:	6605                	lui	a2,0x1
    800055a0:	4581                	li	a1,0
    800055a2:	f62fb0ef          	jal	80000d04 <memset>
  memset(disk.avail, 0, PGSIZE);
    800055a6:	0001b497          	auipc	s1,0x1b
    800055aa:	49248493          	addi	s1,s1,1170 # 80020a38 <disk>
    800055ae:	6605                	lui	a2,0x1
    800055b0:	4581                	li	a1,0
    800055b2:	6488                	ld	a0,8(s1)
    800055b4:	f50fb0ef          	jal	80000d04 <memset>
  memset(disk.used, 0, PGSIZE);
    800055b8:	6605                	lui	a2,0x1
    800055ba:	4581                	li	a1,0
    800055bc:	6888                	ld	a0,16(s1)
    800055be:	f46fb0ef          	jal	80000d04 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800055c2:	100017b7          	lui	a5,0x10001
    800055c6:	4721                	li	a4,8
    800055c8:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800055ca:	4098                	lw	a4,0(s1)
    800055cc:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800055d0:	40d8                	lw	a4,4(s1)
    800055d2:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800055d6:	649c                	ld	a5,8(s1)
    800055d8:	10001737          	lui	a4,0x10001
    800055dc:	08f72823          	sw	a5,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800055e0:	9781                	srai	a5,a5,0x20
    800055e2:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800055e6:	689c                	ld	a5,16(s1)
    800055e8:	0af72023          	sw	a5,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800055ec:	9781                	srai	a5,a5,0x20
    800055ee:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800055f2:	4785                	li	a5,1
    800055f4:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800055f6:	00f48c23          	sb	a5,24(s1)
    800055fa:	00f48ca3          	sb	a5,25(s1)
    800055fe:	00f48d23          	sb	a5,26(s1)
    80005602:	00f48da3          	sb	a5,27(s1)
    80005606:	00f48e23          	sb	a5,28(s1)
    8000560a:	00f48ea3          	sb	a5,29(s1)
    8000560e:	00f48f23          	sb	a5,30(s1)
    80005612:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005616:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    8000561a:	07272823          	sw	s2,112(a4)
}
    8000561e:	60e2                	ld	ra,24(sp)
    80005620:	6442                	ld	s0,16(sp)
    80005622:	64a2                	ld	s1,8(sp)
    80005624:	6902                	ld	s2,0(sp)
    80005626:	6105                	addi	sp,sp,32
    80005628:	8082                	ret
    panic("could not find virtio disk");
    8000562a:	00002517          	auipc	a0,0x2
    8000562e:	01650513          	addi	a0,a0,22 # 80007640 <etext+0x640>
    80005632:	a06fb0ef          	jal	80000838 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005636:	00002517          	auipc	a0,0x2
    8000563a:	02a50513          	addi	a0,a0,42 # 80007660 <etext+0x660>
    8000563e:	9fafb0ef          	jal	80000838 <panic>
    panic("virtio disk should not be ready");
    80005642:	00002517          	auipc	a0,0x2
    80005646:	03e50513          	addi	a0,a0,62 # 80007680 <etext+0x680>
    8000564a:	9eefb0ef          	jal	80000838 <panic>
    panic("virtio disk has no queue 0");
    8000564e:	00002517          	auipc	a0,0x2
    80005652:	05250513          	addi	a0,a0,82 # 800076a0 <etext+0x6a0>
    80005656:	9e2fb0ef          	jal	80000838 <panic>
    panic("virtio disk max queue too short");
    8000565a:	00002517          	auipc	a0,0x2
    8000565e:	06650513          	addi	a0,a0,102 # 800076c0 <etext+0x6c0>
    80005662:	9d6fb0ef          	jal	80000838 <panic>
    panic("virtio disk kalloc");
    80005666:	00002517          	auipc	a0,0x2
    8000566a:	07a50513          	addi	a0,a0,122 # 800076e0 <etext+0x6e0>
    8000566e:	9cafb0ef          	jal	80000838 <panic>

0000000080005672 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005672:	711d                	addi	sp,sp,-96
    80005674:	ec86                	sd	ra,88(sp)
    80005676:	e8a2                	sd	s0,80(sp)
    80005678:	e4a6                	sd	s1,72(sp)
    8000567a:	e0ca                	sd	s2,64(sp)
    8000567c:	fc4e                	sd	s3,56(sp)
    8000567e:	f852                	sd	s4,48(sp)
    80005680:	f456                	sd	s5,40(sp)
    80005682:	f05a                	sd	s6,32(sp)
    80005684:	ec5e                	sd	s7,24(sp)
    80005686:	e862                	sd	s8,16(sp)
    80005688:	1080                	addi	s0,sp,96
    8000568a:	89aa                	mv	s3,a0
    8000568c:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000568e:	00c52b83          	lw	s7,12(a0)
    80005692:	001b9b9b          	slliw	s7,s7,0x1
    80005696:	1b82                	slli	s7,s7,0x20
    80005698:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    8000569c:	0001b517          	auipc	a0,0x1b
    800056a0:	4c450513          	addi	a0,a0,1220 # 80020b60 <disk+0x128>
    800056a4:	d94fb0ef          	jal	80000c38 <acquire>
  for(int i = 0; i < NUM; i++){
    800056a8:	44a1                	li	s1,8
      disk.free[i] = 0;
    800056aa:	0001ba97          	auipc	s5,0x1b
    800056ae:	38ea8a93          	addi	s5,s5,910 # 80020a38 <disk>
  for(int i = 0; i < 3; i++){
    800056b2:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    800056b4:	5c7d                	li	s8,-1
    800056b6:	a095                	j	8000571a <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    800056b8:	00fa8733          	add	a4,s5,a5
    800056bc:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800056c0:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800056c2:	0207c563          	bltz	a5,800056ec <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    800056c6:	2905                	addiw	s2,s2,1
    800056c8:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800056ca:	05490c63          	beq	s2,s4,80005722 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    800056ce:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800056d0:	0001b717          	auipc	a4,0x1b
    800056d4:	36870713          	addi	a4,a4,872 # 80020a38 <disk>
    800056d8:	4781                	li	a5,0
    if(disk.free[i]){
    800056da:	01874683          	lbu	a3,24(a4)
    800056de:	fee9                	bnez	a3,800056b8 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    800056e0:	2785                	addiw	a5,a5,1
    800056e2:	0705                	addi	a4,a4,1
    800056e4:	fe979be3          	bne	a5,s1,800056da <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    800056e8:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    800056ec:	01205d63          	blez	s2,80005706 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    800056f0:	fa042503          	lw	a0,-96(s0)
    800056f4:	d4fff0ef          	jal	80005442 <free_desc>
      for(int j = 0; j < i; j++)
    800056f8:	4785                	li	a5,1
    800056fa:	0127d663          	bge	a5,s2,80005706 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    800056fe:	fa442503          	lw	a0,-92(s0)
    80005702:	d41ff0ef          	jal	80005442 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005706:	0001b597          	auipc	a1,0x1b
    8000570a:	45a58593          	addi	a1,a1,1114 # 80020b60 <disk+0x128>
    8000570e:	0001b517          	auipc	a0,0x1b
    80005712:	34250513          	addi	a0,a0,834 # 80020a50 <disk+0x18>
    80005716:	fe6fc0ef          	jal	80001efc <sleep>
  for(int i = 0; i < 3; i++){
    8000571a:	fa040613          	addi	a2,s0,-96
    8000571e:	4901                	li	s2,0
    80005720:	b77d                	j	800056ce <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005722:	fa042503          	lw	a0,-96(s0)
    80005726:	00451693          	slli	a3,a0,0x4

  if(write)
    8000572a:	0001b797          	auipc	a5,0x1b
    8000572e:	30e78793          	addi	a5,a5,782 # 80020a38 <disk>
    80005732:	00451713          	slli	a4,a0,0x4
    80005736:	0a070713          	addi	a4,a4,160
    8000573a:	973e                	add	a4,a4,a5
    8000573c:	01603633          	snez	a2,s6
    80005740:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005742:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005746:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000574a:	6398                	ld	a4,0(a5)
    8000574c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000574e:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005752:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005754:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005756:	6390                	ld	a2,0(a5)
    80005758:	00d605b3          	add	a1,a2,a3
    8000575c:	4741                	li	a4,16
    8000575e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005760:	4805                	li	a6,1
    80005762:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005766:	fa442703          	lw	a4,-92(s0)
    8000576a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000576e:	0712                	slli	a4,a4,0x4
    80005770:	963a                	add	a2,a2,a4
    80005772:	05898593          	addi	a1,s3,88
    80005776:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005778:	0007b883          	ld	a7,0(a5)
    8000577c:	9746                	add	a4,a4,a7
    8000577e:	40000613          	li	a2,1024
    80005782:	c710                	sw	a2,8(a4)
  if(write)
    80005784:	001b3613          	seqz	a2,s6
    80005788:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000578c:	01066633          	or	a2,a2,a6
    80005790:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005794:	fa842583          	lw	a1,-88(s0)
    80005798:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000579c:	00250613          	addi	a2,a0,2
    800057a0:	0612                	slli	a2,a2,0x4
    800057a2:	963e                	add	a2,a2,a5
    800057a4:	577d                	li	a4,-1
    800057a6:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800057aa:	0592                	slli	a1,a1,0x4
    800057ac:	98ae                	add	a7,a7,a1
    800057ae:	03068713          	addi	a4,a3,48
    800057b2:	973e                	add	a4,a4,a5
    800057b4:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800057b8:	6398                	ld	a4,0(a5)
    800057ba:	972e                	add	a4,a4,a1
    800057bc:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800057c0:	4689                	li	a3,2
    800057c2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800057c6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800057ca:	0109a223          	sw	a6,4(s3)
  disk.info[idx[0]].b = b;
    800057ce:	01363423          	sd	s3,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800057d2:	6794                	ld	a3,8(a5)
    800057d4:	0026d703          	lhu	a4,2(a3)
    800057d8:	8b1d                	andi	a4,a4,7
    800057da:	0706                	slli	a4,a4,0x1
    800057dc:	96ba                	add	a3,a3,a4
    800057de:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800057e2:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800057e6:	6798                	ld	a4,8(a5)
    800057e8:	00275783          	lhu	a5,2(a4)
    800057ec:	2785                	addiw	a5,a5,1
    800057ee:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800057f2:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800057f6:	100017b7          	lui	a5,0x10001
    800057fa:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800057fe:	0049a783          	lw	a5,4(s3)
    80005802:	01079f63          	bne	a5,a6,80005820 <virtio_disk_rw+0x1ae>
    sleep(b, &disk.vdisk_lock);
    80005806:	0001b917          	auipc	s2,0x1b
    8000580a:	35a90913          	addi	s2,s2,858 # 80020b60 <disk+0x128>
  while(b->disk == 1) {
    8000580e:	84be                	mv	s1,a5
    sleep(b, &disk.vdisk_lock);
    80005810:	85ca                	mv	a1,s2
    80005812:	854e                	mv	a0,s3
    80005814:	ee8fc0ef          	jal	80001efc <sleep>
  while(b->disk == 1) {
    80005818:	0049a783          	lw	a5,4(s3)
    8000581c:	fe978ae3          	beq	a5,s1,80005810 <virtio_disk_rw+0x19e>
  }

  disk.info[idx[0]].b = 0;
    80005820:	fa042903          	lw	s2,-96(s0)
    80005824:	00290713          	addi	a4,s2,2
    80005828:	0712                	slli	a4,a4,0x4
    8000582a:	0001b797          	auipc	a5,0x1b
    8000582e:	20e78793          	addi	a5,a5,526 # 80020a38 <disk>
    80005832:	97ba                	add	a5,a5,a4
    80005834:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005838:	0001b997          	auipc	s3,0x1b
    8000583c:	20098993          	addi	s3,s3,512 # 80020a38 <disk>
    80005840:	00491713          	slli	a4,s2,0x4
    80005844:	0009b783          	ld	a5,0(s3)
    80005848:	97ba                	add	a5,a5,a4
    8000584a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000584e:	854a                	mv	a0,s2
    80005850:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005854:	befff0ef          	jal	80005442 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005858:	8885                	andi	s1,s1,1
    8000585a:	f0fd                	bnez	s1,80005840 <virtio_disk_rw+0x1ce>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000585c:	0001b517          	auipc	a0,0x1b
    80005860:	30450513          	addi	a0,a0,772 # 80020b60 <disk+0x128>
    80005864:	c64fb0ef          	jal	80000cc8 <release>
}
    80005868:	60e6                	ld	ra,88(sp)
    8000586a:	6446                	ld	s0,80(sp)
    8000586c:	64a6                	ld	s1,72(sp)
    8000586e:	6906                	ld	s2,64(sp)
    80005870:	79e2                	ld	s3,56(sp)
    80005872:	7a42                	ld	s4,48(sp)
    80005874:	7aa2                	ld	s5,40(sp)
    80005876:	7b02                	ld	s6,32(sp)
    80005878:	6be2                	ld	s7,24(sp)
    8000587a:	6c42                	ld	s8,16(sp)
    8000587c:	6125                	addi	sp,sp,96
    8000587e:	8082                	ret

0000000080005880 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005880:	1101                	addi	sp,sp,-32
    80005882:	ec06                	sd	ra,24(sp)
    80005884:	e822                	sd	s0,16(sp)
    80005886:	e426                	sd	s1,8(sp)
    80005888:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000588a:	0001b497          	auipc	s1,0x1b
    8000588e:	1ae48493          	addi	s1,s1,430 # 80020a38 <disk>
    80005892:	0001b517          	auipc	a0,0x1b
    80005896:	2ce50513          	addi	a0,a0,718 # 80020b60 <disk+0x128>
    8000589a:	b9efb0ef          	jal	80000c38 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000589e:	100017b7          	lui	a5,0x10001
    800058a2:	53bc                	lw	a5,96(a5)
    800058a4:	8b8d                	andi	a5,a5,3
    800058a6:	10001737          	lui	a4,0x10001
    800058aa:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800058ac:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800058b0:	689c                	ld	a5,16(s1)
    800058b2:	0204d703          	lhu	a4,32(s1)
    800058b6:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    800058ba:	04f70663          	beq	a4,a5,80005906 <virtio_disk_intr+0x86>
    __sync_synchronize();
    800058be:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800058c2:	6898                	ld	a4,16(s1)
    800058c4:	0204d783          	lhu	a5,32(s1)
    800058c8:	8b9d                	andi	a5,a5,7
    800058ca:	078e                	slli	a5,a5,0x3
    800058cc:	97ba                	add	a5,a5,a4
    800058ce:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800058d0:	00278713          	addi	a4,a5,2
    800058d4:	0712                	slli	a4,a4,0x4
    800058d6:	9726                	add	a4,a4,s1
    800058d8:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800058dc:	e321                	bnez	a4,8000591c <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800058de:	0789                	addi	a5,a5,2
    800058e0:	0792                	slli	a5,a5,0x4
    800058e2:	97a6                	add	a5,a5,s1
    800058e4:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800058e6:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800058ea:	e5efc0ef          	jal	80001f48 <wakeup>

    disk.used_idx += 1;
    800058ee:	0204d783          	lhu	a5,32(s1)
    800058f2:	2785                	addiw	a5,a5,1
    800058f4:	17c2                	slli	a5,a5,0x30
    800058f6:	93c1                	srli	a5,a5,0x30
    800058f8:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800058fc:	6898                	ld	a4,16(s1)
    800058fe:	00275703          	lhu	a4,2(a4)
    80005902:	faf71ee3          	bne	a4,a5,800058be <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005906:	0001b517          	auipc	a0,0x1b
    8000590a:	25a50513          	addi	a0,a0,602 # 80020b60 <disk+0x128>
    8000590e:	bbafb0ef          	jal	80000cc8 <release>
}
    80005912:	60e2                	ld	ra,24(sp)
    80005914:	6442                	ld	s0,16(sp)
    80005916:	64a2                	ld	s1,8(sp)
    80005918:	6105                	addi	sp,sp,32
    8000591a:	8082                	ret
      panic("virtio_disk_intr status");
    8000591c:	00002517          	auipc	a0,0x2
    80005920:	ddc50513          	addi	a0,a0,-548 # 800076f8 <etext+0x6f8>
    80005924:	f15fa0ef          	jal	80000838 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
