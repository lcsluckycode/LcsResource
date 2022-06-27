# RDK编译

## 代码下载

RDK采用repo进行代码管理，代码的释放流程。但由于RDK合入厂商的修改工作量大，所以第二环节会
卡比较久，通常我们合入修改与RDK是并行的。

对于所以在本地开发调试一个问题是下好代码后就固化版本，尽量不要动了。避免代码更新引入其他问
题，使得当前任务复杂化。

rdk下载代码前配置，以amlogic为例。

服务器配置好RDK编译环境；

- 添加密钥，分别添加进RDKcenter的git， UK的git， 以及amlogic的git；
- 配置.netrc
  - code.rdkcentral.com
  - artifactory.rdkcentral.com
  - github.com
- 配置.ssh/conﬁg
  - dev.caldero.com

确保开通这些网址的权限，配置好这些网站的账号密码。 将这些密钥文件的权限改为只读。开始拉取工程

```bash
repo init --no-clone-bundle -u

https://code.rdkcentral.com/r/collaboration/oem/skyworth/skyworth-aml905X2-

manifests -b rdk-next -m sc2-rdkservices-restricted.xml

repo sync -j 32
```

RDK采取的方式是编译中下载拉取代码，此时下载的工程只是各个layer及一些配置。

此时参考说明，检查文档是否有需要打补丁的layer。打完补丁可以开始依照说明选择对应的环境变量设

置文件，及编译。

```bash
source meta-rdk-skyworth-hsetup-environment --hp44h-rdk --read-write

bitbake skyworth-generic-mediaclient-image
```

注：第一编译 记得加 -k 命令，第一次编译耗时长，强制执行确保所有git包能下载下来。

所有的包存放在downloads里，清空工程时如非必要，不要删除downloads，否则编译会再去拉取代码

近20G的代码非常浪费时间。另外可以用软连接将相似工程使用同一个downloads，编译时回去校验包

的版本，无需担心用错包。

## 编译流程

RDK的编译大致分为两部分，recipe解析，及task执行。

- recipe解析

每一个模块都是一个recipe，其中包含了一些系列任务，大致基本有fetch, upack, compile, install。等

recipe解析就会解释*.bb文件,确定里面每个任务执行环境，执行参数，执行顺序(会转化成shell脚本或

python脚本位于每个问题的temp目录下)。然后添加进队列。

- task执行

task执行会将队列里的任务依照依赖关系检查执行，

## 常见问题定位

bitbake提供了一系列命令帮助调试



```bash
#编译单个食谱 例如:u-boot
bitbake u-boot #名字为各个layer下的bb文件
bitbake u-boot -f -c compile # -f 为强制编译， -c 可以指定具体任务名。
#列出某食谱的所有任务 一般包含 fetch upack patch compile install 等等
bitbake u-boot -f -c listtasks
#bitbake的一些构建参数
-k 忽略报错，执行所有任务。 一般第一次构建时，防止被错误卡住停止编译，可以加-k先下代码解压编
译，再检查问题。
-v 显示执行过程，放开编译打印。
-e 显示当前执行环境，一般可用于查找变量定义等。
-g 生成依赖关系等，执行后当前目录会生成
	task-depends.dot（任务之间的依赖关系）
	package-depends.dot（运行时的目标依赖）
	pn-depends.dot（构建时的依赖）
	pn-buildlist（包含需要构建的任务列表）
```

注：一般recipe解析过程报错，是因为环境设置有误，缺少文件，及食谱语法错误。 先确定报错模块的

功能，在根据提示检查相应设置。

- fetch相关，fetch相关的报错

  - 权限报错 ssh -T + 报错网址检查是否有权限访问。

  - fetch路径报错在temp中找到相应的下载命令，询问相关方人，包的位置。
  - fetch 版本冲突报错， 包的管理方变更了分支，或者bitbake里变更了下载源。

- compile相关， 一般每个模块都是比较完整的，编译报错出现较少。

  - 通常为前置任务未执行，导致编译时缺少文件。-g 查看依赖。确保前置任务执行成功。
  - 修改导致，检查自己的修改。

- install 及 packagedata 报错

  - install的文件重复。 添加配置进行选择使用。
  - install路径，文件缺失。检查编译生成文件，或所需拷贝文件。

# RDK调试

systemd

## 日志查看

查看某个模块的日志，先查找模块名，再使用 journalctl 查看该模块日志。

```bash
systemctl list-units
systemctl list-units --all
journalctl -u <unit> -f &
```

使用这个前先确保再 control UI里tracing设置项里该模块已经打开追踪。
在 `/opt/logs` 中也可以看到各服务的日志文件。
也可以不指定模块，打印出全部消息。
对于在盒子上调试js应用，使用 `console.log` 并不能将日志输出到终端。调用 `Log.info("")` 的方法才
能将日志输出到终端。除了 `info` 应用还支持 `debug, error, warn` 共四个等级的日志的。

## 服务调试

```bash
systemd status <unit>
查看启动的日志；
systemd start/stop <unit>
服务启动与终止；
systemd-analyze [<unit>]
查看服务的启动耗时；
systemd-analyze critical-chain
查看各个服务的启动瀑布流
```

通过上述命令我们可以查看某个服务的启动过程，日志，耗时，及前置服务等等。
`systemd`的服务位于 `/lib/systemd/system/` 下, 但实际使用是要再 `/etc/systemd/system/` 下生成链
接文件。
而调用的启动脚本一般放置于 `/lib/rdk/` 目录下。

## gdb调试

用GDB查看crash的堆栈：
调整coredump的生成位置,在coredump生成后拷贝到pc机。用gdb工具查看。

```bash
echo "/mnt/memory/corefiles/coredump.%e.%p" > /proc/sys/kernel/core_pattern
##cp to pc
arm-linux-gnueabihf-gdb appName -c coredumpFile
```

一些简单的GDB命令

```bash
bt：显示所有栈帧。
bt full：显示栈帧以及局部变量。
frame <栈帧编号>：进入指定的栈帧中，然后可以栈帧内容等信息。(源码放在core目录下关联查看更清晰)
info frame <栈帧编号>：可以查看指定栈帧的详细信息(函数参数、寄存器信息、先前栈的sp)。
up：进入上层栈帧。
down：进入下层栈帧。
p <变量名> 查看变量名。
info reg：显示所有寄存器
i $ebx：查看具体的寄存器
p $eax：显示eax寄存器内容。
```

## 其他

RDK另外提供了两个调试工具，rmfapp,breakpad。rmfapp用于调试一些音视频的播放录制

BreakPad是一个库和工具套件，当应用程序崩溃时，它会产生“miniDump”文件。这些miniDumps将
发送回服务器并生成堆栈的调用记录。

具体的使用方法是在程序内添加异常发生的Handler并指明回调。
编译时链上exception的库。

```bash
#include"stdio.h"
#include"client/linux/handler/exception_handler.h"
static bool breakpadDumpCallback(const
google_breakpad::MinidumpDescriptor&descriptor, void* context, bool succeeded)
{
printf("Crash occurred, Callback function called.\n");
return succeeded;
}
int main()
{
google_breakpad::MinidumpDescriptor descriptor("/mnt");
google_breakpad::ExceptionHandler eh(descriptor, NULL,
breakpadDumpCallback, NULL, true, -1);
. . .
```
拿到程序崩溃时，便会生成minicoredump。使用breakpad的相关工具

```bash
dump_syms testBreakdump > testBreakdump.sym
head -n1 testBreakdump.sym ##得到符号文件的
mkdir -p symbols/testBreakdump/73DC1FFAD46D0ECDC4988DB
cp testBreakdump.sym symbols/breakpad_exercise/73DC1FFAD46D0ECDC4988DB
minidump_stackwalk 40e9abf8-19cc-4b55.dmp symbols/ > tracefile
```

分析后即可得到栈调用信息。
