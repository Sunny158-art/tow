# XV6 Kernel Mechanism Practice & System Call Extension

### 🌟 任务完成情况总结
#### 第一层任务：机制观察与追踪
* 成功在 QEMU 中运行 xv6
* 输出系统运行关键日志
* 跟踪系统调用路径
#### 第二层任务：系统调用扩展
* 成功新增系统调用 `hello()`
* 完成：
  * 用户态接口注册
  * 内核态 syscall 注册
  * 内核函数实现
* 修改 Makefile 并成功编译
* 用户程序调用验证成功

---

## 📚 项目简介

本项目基于 xv6-riscv，完成了操作系统实践周的前两层任务：

### ✅ 第一层（必做）

* 系统调用路径追踪
* 调度过程观察
* 内存分配观察

### ✅ 第二层（选做）

* 新增系统调用 `hello()`

---

## ⚙️ 环境要求

* 操作系统：Linux / macOS
* 编译工具：

  ```bash
  riscv64-unknown-elf-gcc
  ```

  或

  ```bash
  riscv64-linux-gnu-gcc
  ```
* 模拟器：

  ```bash
  QEMU (riscv64)
  ```

---

## 🔍 第一层任务：机制观察

### 1️⃣ 系统调用路径跟踪（write）

在以下位置添加日志：

#### 用户态（user 程序）

```c
printf("[USER] calling write\n");
```

#### kernel/syscall.c

```c
printf("[KERNEL] enter syscall\n");
```

#### sys_write()

```c
printf("[KERNEL] sys_write invoked\n");
```

---

### 2️⃣ 调度过程观察

在 `scheduler()` 中：

```c
printf("[SCHED] switch to pid=%d\n", p->pid);
```

观察现象：

* 进程交替执行
* 时间片轮转

---

### 3️⃣ 内存分配观察

在 `kalloc.c`：

```c
printf("[MEM] alloc page at %p\n", pa);
```

观察：

* 是否连续分配
* 是否复用

---

## 🚀 第二层任务：新增系统调用 hello()

### 📌 实现流程

---

### 1️⃣ 用户态声明

#### user/user.h

```c
int hello(void);
```

#### user/usys.pl

```perl
entry("hello");
```

---

### 2️⃣ 内核态注册

#### kernel/syscall.h

```c
#define SYS_hello 22
```

#### kernel/syscall.c

```c
extern uint64 sys_hello(void);

[SYS_hello] sys_hello,
```

---

### 3️⃣ 内核实现

#### kernel/sysproc.c

```c
uint64
sys_hello(void)
{
  return 0;
}
```

---

### 4️⃣ 用户测试程序

#### user/hello.c

```c
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  printf("Calling the new system call hello():\n");
  hello();
  printf("Hello, xv6!\n");
  exit(0);
}
```

---

### 5️⃣ 修改 Makefile

```makefile
$U/_hello\
```

---

## 🖥️ 编译与运行

```bash
make clean && make qemu
```

进入 xv6：

```bash
$ hello
```

---

## 📊 实验结果

```text
Calling the new system call hello():
Hello, xv6!
```

---

## ⚠️ 遇到的问题与解决

### ❌ 问题 1：系统调用未注册

* 原因：未在 syscall.c 添加映射
* 解决：补充 `[SYS_hello] sys_hello`

### ❌ 问题 2：用户程序无法运行

* 原因：Makefile 未添加
* 解决：加入 `$U/_hello`

---

## 💡 实践心得（示例，可自行扩展）

通过本次 xv6 实践，我对操作系统从“能运行”到“如何运行”有了更加深入的理解。尤其是在系统调用部分，我第一次完整打通了用户态到内核态的执行路径，从接口声明、系统调用号分配，到内核函数实现和最终返回结果，这一过程让我清晰认识到操作系统的分层设计思想。

在第一层任务中，通过添加日志，我观察到了调度器如何在多个进程之间切换，以及内存分配的基本行为。这种“可视化操作系统”的方式，比单纯阅读代码更加直观，也更容易理解底层机制。

在第二层任务中，实现 hello() 系统调用让我体会到操作系统扩展的基本方法。虽然功能简单，但涉及多个文件协同修改，这对代码结构理解要求较高。

总体来说，本次实践不仅提升了我对操作系统原理的理解，也增强了我阅读和修改大型系统代码的能力，为后续学习打下了坚实基础。

---

## 📌 仓库说明

* ✅ xv6 可正常运行
* ✅ 已完成第一层 + 第二层任务
* ✅ 包含 README.md
* ✅ 多次 commit 记录实验过程

---
