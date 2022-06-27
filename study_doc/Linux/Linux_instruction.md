# Linux常用指令
## rpm 指令
rpm命令是RPM软件包的管理工具。rpm原本是Red Hat Linux发行版专门用来管理Linux各项套件的程序，由于它遵循GPL规则且功能强大方便，因而广受欢迎。逐渐受到其他发行版的采用。RPM套件管理方式的出现，让Linux易于安装，升级，间接提升了Linux的适用度。
### 常见命令参数
可以通过管道与grep等指令结合使用
- 用法: rpm [选项...]
- -a：查询所有套件；
- -b<完成阶段><套件档>+或-t <完成阶段><套件档>+：设置包装套件的完成阶>段，并指定套- 件档的文件名称；
- -c：只列出组态配置文件，本参数需配合"-l"参数使用；
- -d：只列出文本文件，本参数需配合"-l"参数使用；
- -e<套件档>或--erase<套件档>：删除指定的套件；
- -f<文件>+：查询拥有指定文件的套件；
- -h或--hash：套件安装时列出标记；
- -i：显示套件的相关信息；
- -i<套件档>或--install<套件档>：安装指定的套件档；
- -l：显示套件的文件列表；
- -p<套件档>+：查询指定的RPM套件档；
- -q：使用询问模式，当遇到任何问题时，rpm指令会先询问用户；
- -R：显示套件的关联性信息；
- -s：显示文件状态，本参数需配合"-l"参数使用；
- -U<套件档>或--upgrade<套件档>：升级指定的套件档；
- -v：显示指令执行过程；
- -vv：详细显示指令执行过程，便于排错。
### 常见命令展示
安装rpm软件安装包
```bash
rpm -ivh package.rpm            #直接安装
rpm --force -ivh package.rpm    #忽略报错，强制安装
```
常见其他命令
```bash
rpm -qa         #查询所有安装过的包
rpm -q packname   #查询软件包全名
rpm -ql appname   #查询
rpm -e appname    #卸载

#查询哪个软件包包含这个程序
rpm -qf `which 程序名`    #返回软件包的全名
rpm -qif `which 程序名`   #返回软件包的有关信息
rpm -qlf `which 程序名`   #返回软件包的文件列表
```

## mount 挂载命令
命令格式：`mount [-t vfstype] [-o options] device dir`
### -t vfstype
指定文件系统的类型，通常不直接指定，mount会自动选择正确的类型
- 光盘或光盘镜像：iso9660
- DOS fat16文件系统：msdos
- Windows 9x fat32文件系统：vfat
- Windows NT ntfs文件系统：ntfs
- Mount Windows文件网络共享：smbfs
- UNIX(LINUX) 文件网络共享：nfs
### -o options
主要是描述设备或文件的连接方式
- loop：用来把一个文件当成硬盘分区挂接上系统
- ro：采用只读的方式挂接设备
- rw：采用读写方式挂接设备
- iocharset：指定访问文件系统所用字符集

`device`表示要挂载的设备；`dir`表示设备在系统上要挂载的节点

## minicom
`minicom -s`进入配置界面，具体配置看选项
>minicom基本操作：
>>需要使用Ctrl+a进入设置状态
>>进入设置状态后，按z进入设置菜单
>>>o键：打开配置选项
>>>w键：自动卷屏。当显示的内容超过一行后，自动将后面的内容换行
>>>c键：清除屏幕显示内容
>>>b键：浏览minicom的历史显示
>>>x键：退出minicom，会提示确认退出
## dd
dd用来指定大小快拷贝文件，并在拷贝的同时进行指定的转换
参考博客: [linux命令总结dd命令详解](https://www.cnblogs.com/ginvip/p/6370836.html)
### dd常用参数表
- if=输入文件名，缺省为标准输入
- of=输出文件名，缺省为标准输出
- ibs=bytes：一次性读入bytes个字节，即指定一个块大小为bytes个字节
- obs=bytes：一次输出bytes个字节，即指定一个块大小为bytes个字节。
- bs=bytes：同时设置读入/输出的块大小为bytes个字节。
- cbs=bytes：一次转换bytes个字节，即指定转换缓冲区大小。
- skip=blocks：从输入文件开头跳过blocks个块后再开始复制。
- seek=blocks：从输出文件开头跳过blocks个块后再开始复制。
注意：通常只用当输出文件是磁盘或磁带时才有效，即备份到磁盘或磁带时才有效。
- count=blocks：仅拷贝blocks个块，块大小等于ibs指定的字节数。
- conv=conversion：用指定的参数转换文件。
  - ascii：转换ebcdic为ascii
  - ebcdic：转换ascii为ebcdic
  - ibm：转换ascii为alternate ebcdic
  - block：把每一行转换为长度为cbs，不足部分用空格填充
  - unblock：使每一行的长度都为cbs，不足部分用空格填充
  - lcase：把大写字符转换为小写字符
  - ucase：把小写字符转换为大写字符
  - swab：交换输入的每对字节
  - noerror：出错时不停止
  - notrunc：不截短输出文件
  - sync：将每个输入块填充到ibs个字节，不足部分用空（NUL）字符补齐。
### dd常见操作
```bash
#将本地的/dev/hdb整盘备份到/dev/hdd
dd if=/dev/hdb of=/dev/hdd
#将/dev/hdb全盘数据备份到指定路径的image文件
dd if=/dev/hdb of=/root/image
#将备份文件恢复到指定盘
dd if=/root/image of=/dev/hdb
#备份/dev/hdb全盘数据，并利用gzip工具进行压缩，保存到指定路径
dd if=/dev/hdb | gzip > /root/image.gz
#将压缩的备份文件恢复到指定盘
gzip -dc /root/image.gz | dd of=/dev/hdb
#备份磁盘开始的512个字节大小的MBR信息到指定文件
dd if=/dev/hda of=/root/image count=1 bs=512
#将备份的MBR信息写到磁盘开始部分
dd if=/root/image of=/dev/had

status=progress #查看进度
```
## find 
find命令，根据文件的属性进行查找，如文件名，文件大小，所有者等等。
基本命令格式：`find [path] [-option] [expression]`
常用：`find ./ -name '*name*'` 表示在当前目录下查找一个包含name字符的文件。
### 按照文件特征进行查找
- find ./ -amin -10  #查找最后10分钟访问的文件
- find ./ -atime -2  #查找最后48小时访问的文件
- find ./ -mmin -5   #查找在5分钟内修改过的文件
- find ./ -mtime -1  #查找在24小时内修改过的文件
- find ./ -empty     #查找空的文件夹或者文件
- find ./ -group gname #查找属于group为gname的文件
- find ./ -user uname  #查找属于uname用户的文件
- find ./ -size +1000c #查找出大于1000个字节的文件（c：字节，w：双字节，k：KB，M：MB，G：GB）
- find ./ -size -1000k #查找出小于1000K的文件
**使用混合方式**
参数：`!, -and(-a), -or(-o)`*与或非*
example:`find ./ -size +1000c -a -mtime -2`
## grep
grep命令，根据文件的内容进行查找，会对文件的每一行按照给定的模式(patter)进行匹配查找。
基本命令格式：`grep [-option] [expression]`

```
LANG=C grep --only-matching --byte-offset --binary --text --perl-regexp "<\x-hex pattern>" <file>

short form:
LANG=C grep -obUaP "<\x-hex pattern>" <file>
```

查找二进制文件某个bin所在的位置

```
LANG=C grep -obUaP "\x01\x02" /bin/grep
```



### option主要参数
- -c：只输出匹配行的计数。
- -i：不区分大小写
- -r：搜索子目录
- -h：查询多文件时不显示文件名。
- -l：查询多文件时只输出包含匹配字符的文件名。
- -n：显示匹配行及行号。
- -s：不显示不存在或无匹配文本的错误信息。
- -v：显示不包含匹配文本的所有行。
- --color查询结果显示颜色
### pattern正则表达式主要参数
- \： 忽略正则表达式中特殊字符的原有含义。
- ^：匹配正则表达式的开始行。
- $: 匹配正则表达式的结束行。
- \<：从匹配正则表达式的行开始。
- \>：到匹配正则表达式的行结束。
- [ ]：单个字符，如[A]即A符合要求 。
- [ - ]：范围，如[A-Z]，即A、B、C一直到Z都符合要求 。
- .：所有的单个字符。
- *：有字符，长度可以为0
  **常见实例**
- grep 'test' d*　　#显示所有以d开头的文件中包含 test的行
- grep ‘test’ aa bb cc 　　 #显示在aa，bb，cc文件中包含test的行
- grep ‘[a-z]\{5\}’ aa 　　#显示所有包含每行字符串至少有5个连续小写字符的字符串的行
- grep magic /usr/src　　#显示/usr/src目录下的文件(不含子目录)包含magic的行
- grep -r magic /usr/src　　#显示/usr/src目录下的文件(包含子目录)包含magic的行
- grep -w 'magic' files ：只匹配整个单词，而不是字符串的一部分(如匹配’magic’，而不是’magical’)

## 压缩与解压

**压缩**

`tar -zcvf package.tar.gz dirname`

`gzip -r package.zip dirname`

**解压**

`tar -zxvf package.tar.gz`

`unzip pakeage.zip [-d dirname]`

## scp

**本地复制到远端**

```bash
scp local_file remote_username@remote_ip:remote_folder 
#或者 
scp local_file remote_username@remote_ip:remote_file 
#或者 
scp local_file remote_ip:remote_folder 
#或者 
scp local_file remote_ip:remote_file 

#复制目录
scp -r local_folder remote_username@remote_ip:remote_folder 
#或者 
scp -r local_folder remote_ip:remote_folder 
```

**远端复制带本地**

```bash
scp [option] remote_username@remote_ip:remote_folder local_file

#scp 命令使用端口号 4588
scp -P 4588 remote_username@remote_ip:remote_folder local_file
```

## wget

- `wget -c <url>` 断点续传

# npm 与 nodejs

安装通过官网下载`node.js`

解压然后将`bin`下面的`node`与`npm`，创建软连接到`/usr/local/bin/`下面。

改变node全局下载的位置

```bash
# 查看全局位置
npm config get prefix

# 更改全局安装位置
npm config set prefix path
```

[windows 安装Nodejs](https://blog.csdn.net/qq_39749527/article/details/109557569)

# 常见的虚拟机

当使用yum或者apt-get安装软件不成功的时候，可以先查看源是否有该软件的其他版本或者其他命名

`yum search app-name`，` apt-cache search app-name`

### core dump

`ulimit -c unlimited`开启生产coredump

可以通过修改编辑 `/proc/sys/kernel/core_pattern`文件修改coredump文件生成的位置，ex，`echo "/emp/corefile-%e-%p-%t" > /proc/sys/kernel/core_pattern` ，（文件命名格式为：`corefile-cmd-pid-time`）

然后就可以通过调用gdb调试

**程序卡住了怎么办**

使用 `kill -ABRT pid` 结束该进程，生产coredump文件，然后通过gdb调试确认出错位置。

## WSL

### 文件权限管理

WSL (Win­dows Sub­sys­tem for Linux) 通过 /mnt 目录下的 c、d、e 等目录可分别访问本地的 C、D、E 等盘，虽然可以直接访问 Win­dows 下的文件内容，但输入 ls -al 查看文件你会发现文件权限全都是 777。这会导致一些问题出现，比如 Git会保留这些文件的执行权限，如果你之前在 Win­dows 下使用过 Git Bash ，那么在 WSL 中使用 `git status`查看本地仓库的文件状态时你会发现它们全部被标记成了 modified。

首先要了解 WSL 中的两种文件系统：

#### VolFs

着力于在 Win­dows 文件系统上提供完整的 Linux 文件系统特性，通过各种手段实现了对 In­odes、Di­rec­tory en­tries、File ob­jects、File de­scrip­tors、Spe­cial file types 的支持。比如为了支持 Win­dows 上没有的 In­odes，VolFs 会把文件权限等信息保存在文件的 NTFS Ex­tended At­trib­utes 中。

WSL 中的 / 使用的就是 VolFs 文件系统。

#### DrvFs

着力于提供与 Win­dows 文件系统的互操作性。与 VolFs 不同，为了提供最大的互操作性，DrvFs 不会在文件的 NTFS Ex­tended At­trib­utes 中储存附加信息，而是从 Win­dows 的文件权限（Ac­cess Con­trol Lists，就是你右键文件 > 属性 > 安全选项卡中的那些权限配置）推断出该文件对应的的 Linux 文件权限。

所有 Win­dows 盘符挂载至 WSL 下的 /mnt 时都是使用的 DrvFs 文件系统。

简单来说就是 WSL 对 / 目录下的文件拥有完整的控制权，而 /mnt 目录中的文件无法被 WSL 完全控制（可修改数据，无法真实的修改权限）。WSL 对 /mnt 目录中权限的修改不会直接记录到文件本身，而在 Win­dows 下对文件权限的修改直接可作用到 WSL 。

#### 解决方案

这只是让文件在 WSL 中的权限看起来正常（目录 755，文件 644），实际并不会作用到 Win­dows 文件系统下的文件本身。

```vim
[automount]
enabled = true
root = /mnt/
options = "metadata,umask=22,fmask=111"
mountFsTab = true
```

在 /etc/wsl.conf 中添加以下配置：

```bash
C:\ /mnt/c drvfs rw,noatime,uid=1000,gid=1000,metadata,umask=22,fmask=11 0 0
```

上面的方法对所有盘符都有效，如果你想在 WSL 中调用 Win­dows 下的应用程序（比如 explorer.exe . 调用资源管理器打开当前路径）就需要对 C 盘进行单独设置，否则会提示没有权限。首先确认 wsl.conf 中的 mountFsTab 没有被设置为 false，然后编辑 /etc/fstab，添加如下内容：

此时执行`mkdir`等命令的时候，会发现新建的目录权限依然是 777。

目前民间解决方案是在.profile、.bashrc、.zshrc 或者其他 shell 配置文件中添加如下命令，重新设置 umask

```vim
[filesystem]
umask = 022
```

然后重新启动wsl

### WSL 重新启动

采用管理员身份打开cmd，运行

```cmd
net stop LxssManager
net start LxssManager
```

## centos8

###  修改IP地址

```bash
vim /etc/sysconfig/network-scripts/ifcfg-xxxx

# 重新加载和启动网络服务（xxxx与上xxxx相同）
nmcli c reload xxxx
nmcli c up xxxx
```

### 设置时钟同步 chronyd

```bash
sudo chronyc sources -v
#-bash chronyc 未找到命令
#install chronyc
sudo dnf install chronyc -y

#修改时间同步服务配置
vim /etc/chrony.conf
#注释掉
#pool 2.centos.pool.ntp.org iburst
#加入新的时间服务器（设置为网关）
pool gateway iburst

#重新启动chronyd
systemctl start chronyd.service
systemctl enable chronyd.service
```



## ubuntu

可以在windows下安装WSL

### 安装ssh

```bash
sudo apt-get install openssh-server

#/etc/init.d/ssh restart
#ssh长时间不响应的解决方案：
#服务端修改/etc/ssh/sshd_config
ClientAliveInterval 30
ClientAliveCountMax 3
```

### 修改ip与设置DNS

```bash
#修改ip
#vim /etc/network/interfacse
auto enp0s3
iface enp0s3 inet static
address 192.168.1.103
netmask 255.255.255.0
gateway 192.168.1.1
dns-nameserver 114.114.114.114

#重启服务
/etc/init.d/networking restart

#配置DNS（centos与之一致，但需要reboot重新加载）
#vim /etc/resolv.conf
nameserver 8.8.8.8

#重新加载
sudo systemctl restart systemd-resolved.service
```



### 图形界面

```shell
#ct
systemctl set-default multi-user.target

#start
systemctl set-default graphical.target
```

### 更换apt源

`sudo vim /etc/apt/sources.list`

```bash
#阿里云
deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse

#中科大
deb https://mirrors.ustc.edu.cn/ubuntu/ bionic main restricted universe multiverse
deb-src https://mirrors.ustc.edu.cn/ubuntu/ bionic main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
deb-src https://mirrors.ustc.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
deb-src https://mirrors.ustc.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ bionic-security main restricted universe multiverse
deb-src https://mirrors.ustc.edu.cn/ubuntu/ bionic-security main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ bionic-proposed main restricted universe multiverse
deb-src https://mirrors.ustc.edu.cn/ubuntu/ bionic-proposed main restricted universe multiverse

#清华
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-proposed main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-proposed main restricted universe multiverse
```

`sudo apt-get update`

## Common

### screen

开辟新的窗口（相当于后台）

```bash
screen -R subname  # your subbash name

# 在screen窗口下面，使用 ctrl + a d键返回

screen -r subname  # return subbash which name is subname
```

