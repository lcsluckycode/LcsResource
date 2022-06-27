# Linux电源管理子系统（PM）

## 1. 电源管理的组成

电源管理（Power Management）在linux kernel中，是一个比较庞大的子系统，涉及到供电（Power Supply），充电（Charge）、时钟（Clock）、频率（Frequency）、电压（Voltage）、睡眠/唤醒（Suspend/Resume）等等。

![整体架构](E:\lcsprogram\study_doc\Linux\images\电源管理示意图.gif)

图中的组件可以被称为Framework。（Framework是一个中间层软件，提供如见开发的框架。）

- Power Supply，一个提供用户空间程序监控系统的供电状态的class，它是一个Battery&Charger驱动的Framework
- Clock framework，Clock驱动的Framework，统一管理系统的时钟资源
- Regulator Framework，Voltage/Current Regulator驱动的Framework。该驱动用于调节CPU等模块的电压和电流值
- Dynamic Tick/Clock Event，在传统的Linux Kernel中，系统Tick是固定周期（如10ms）的，因此每隔一个Tick，就会产生一个Timer中断。这会唤醒处于Idle或者Sleep状态的CPU，而很多时候这种唤醒是没有意义的。因此新的Kernel就提出了Dynamic Tick的概念，Tick不再是周期性的，而是根据系统中定时器的情况，不规律的产生，这样可以减少很多无用的Timer中断
- CPU Idle，用于控制CPU Idle状态的Framework
- Generic PM，传统意义上的Power Management，如Power Off、Suspend to RAM、Suspend to Disk、Hibernate等
- Runtime PM and Wakelock，运行时的Power Management，不再需要用户程序的干涉，由Kernel统一调度，实时的关闭或打开设备，以便在使用性能和省电性能之间找到最佳的平衡
  注3：Runtime PM是Linux Kernel亲生的运行时电源管理机制，Wakelock是由Android提出的机制。这两种机制的目的是一样的，因此只需要支持一种即可。另外，由于Wakelock机制路子太野了，饱受Linux社区的鄙视，因此我们不会对该机制进行太多的描述。
- CPU Freq/Device Freq，用于实现CPU以及Device频率调整的Framework
- OPP（Operating Performance Point），是指可以使SOCs或者Devices正常工作的电压和频率组合。内核提供这一个Layer，是为了在众多的电压和频率组合中，筛选出一些相对固定的组合，从而使事情变得更为简单一些
- PM QOS，所谓的PM QOS，是指系统在指定的运行状态下（不同电压、频率，不同模式之间切换，等等）的工作质量，包括latency、timeout、throughput三个参数，单位分别为us、us和kb/s。通过QOS参数，可以分析、改善系统的性能

## 2. PM软件架构

![Generic PM Architecture](E:\lcsprogram\study_doc\Linux\images\PM软件架构.gif)

> API Layer，用于向用户空间提供接口，其中的关机和重启的接口形式是系统调用。Hibernate和Suspend的接口形式是sysfs。
>
> PM code，位于kernel/power/目录下面，主要处理和硬件无关的核心逻辑
>
> PM Driver，分为两部分，一是体系机构无关的Driver，提供Driver框架（Framework）。另一部分是具体的体系结构相关的Driver，这也是电源管理驱动开发需要涉及到的内容。

### 2.1 reboot

内核根据不同的表现形式，将reboot分为以下几种形式

```c
/*      
* Commands accepted by the _reboot() system call.
*
* RESTART     Restart system using default command and mode.
* HALT        Stop OS and give system control to ROM monitor, if any.
* CAD_ON      Ctrl-Alt-Del sequence causes RESTART command.
* CAD_OFF     Ctrl-Alt-Del sequence sends SIGINT to init task.
* POWER_OFF   Stop OS and remove all power from system, if possible.
* RESTART2    Restart system using given command string.
* SW_SUSPEND  Suspend system using software suspend if compiled in.
* KEXEC       Restart system using a previously loaded Linux kernel
*/
#define LINUX_REBOOT_CMD_RESTART        0x01234567
#define LINUX_REBOOT_CMD_HALT           0xCDEF0123
#define LINUX_REBOOT_CMD_CAD_ON         0x89ABCDEF
#define LINUX_REBOOT_CMD_CAD_OFF        0x00000000
#define LINUX_REBOOT_CMD_POWER_OFF      0x4321FEDC
#define LINUX_REBOOT_CMD_RESTART2       0xA1B2C3D4
#define LINUX_REBOOT_CMD_SW_SUSPEND     0xD000FCE2
#define LINUX_REBOOT_CMD_KEXEC          0x4558454
```

![Reboot相关的操作流程](E:\lcsprogram\study_doc\Linux\images\reboot流程.gif)