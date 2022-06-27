# Ubuntu20.04安装教程

[TOC]

# 前期准备

VirtualBox，请前往[官网下载](https://www.virtualbox.org/wiki/Downloads);

Ubuntu20.04，请前往[官网下载](https://ubuntu.com/download/desktop);

假如只是想单纯的体验linux系统，可以尝试安装windows下的[linux子系统WSL](https://docs.microsoft.com/en-us/windows/wsl/install)

# 正式安装

## 创建虚拟机安装空间

这里下载的是ubuntu20.04 LTS桌面版，配置模式选择专家模式，也可以选择向导模式，两者并没有本质区别，所有的步骤基本一致，这里为了虚拟机的更好的性能体验，选择给虚拟机分配4G内存和20G空间存储，推荐最低配置（2G/12G）。

![image-20220112175815199](E:\lcsprogram\study_doc\Linux\images\步骤1.png)

![image-20220112180048421](E:\lcsprogram\study_doc\Linux\images\步骤2.png)

## 配置虚拟机属性

执行完上面的步骤后，这个ubuntu的虚拟机还只是一个空壳，相当于一个还没有填充操作系统的设备，但是我们还得给这个设备提升一下配置或者增添一些功能，打开刚刚配置好的虚拟机的设置，给虚拟机多加一个处理器。

![image-20220112180147723](E:\lcsprogram\study_doc\Linux\images\步骤3.png)

给虚拟机添加我们需要安装的系统光盘文件（iso），有两种方式，第一种是直接选中没有盘片在右侧属性查找到。第二种是直接重新添加一个盘片。

![image-20220112180308942](E:\lcsprogram\study_doc\Linux\images\步骤4.png)

接下来是最重要的**网络配置**，通常来说，虚拟机的网络一般两种配置：**桥接网卡** 和 **NAT网络**，两者的主要区别是能否通过外界访问到虚拟机。

**桥接网卡**，相当于虚拟机与pc机使用同一个网络，在逻辑上虚拟机与pc机在同一个局域网内，两者共用一个网关，处于同一个网段，外界可以通过网关访问到虚拟机。

**NAT网卡**，虚拟机与pc机不在同一个网段，相当于pc机虚拟了一个网段，而虚拟机则在这个网段下面，通俗的来说，pc机是虚拟机的上层，而外界只能看到pc机而看不到虚拟机，外界的消息也只能访问到pc机而无法访问虚拟机，但是虚拟机可以访问外界网络。

![image-20220112180350584](E:\lcsprogram\study_doc\Linux\images\步骤5.png)

## 安装ubuntu系统

这里选用English语言，主要是在进行某些开发或者某些环境配置的时候，中文的语言环境会有稍许影响，假如没有这方面的需求，可以选择 **中文**

![image-20220112180646300](E:\lcsprogram\study_doc\Linux\images\步骤6.png)

![image-20220112180846063](E:\lcsprogram\study_doc\Linux\images\步骤7.png)

这里选择最小安装，主要是虚拟机也不需要这些额外的配置和软件，只需要一个系统而已（狗头.jpg）。同时也取消下载更新，加速安装的速度。

![image-20220112181339828](E:\lcsprogram\study_doc\Linux\images\步骤8.png)

### 安装分支（一）自动分区

傻瓜式安装，直接选择对整个空间进行格式化处理并由系统自动划分分区和挂载点。通常虚拟机安装都选这个。

![image-20220112185525701](E:\lcsprogram\study_doc\Linux\images\步骤9.png)

### 安装分支（二）手动分区

主要是服务器重装、装双系统或者需要一些特殊分区配置才会采用，选第二个选项 `something else`，接下来可以配置自己的分区和挂载点，主要目的是保留磁盘上面存储的资料。具体的划分可参考其他文章。

通常情况需要配置 `\` ，` \boot`， ` \home` 以及 `swap area`

### 统一的安装步骤

![image-20220112192304151](E:\lcsprogram\study_doc\Linux\images\步骤10.png)

![image-20220112192338892](E:\lcsprogram\study_doc\Linux\images\步骤11.png)

![image-20220113082005794](E:\lcsprogram\study_doc\Linux\images\步骤12.png)

![image-20220113090227523](E:\lcsprogram\study_doc\Linux\images\步骤13.png)

# 安装后的系统配置

## 配置root密码，激活root用户

打开终端输入

```bash
sudo passwd
#然后根据提示输入当前用户的密码
#然后根据提示输入你想设置的root的用户的密码

#验证
su
#输入刚输入的root密码，成功登录root用户
```

## 配置静态ip和dns服务

建议使用桌面通过更改网络连接属性修改。

首先查看当前的网卡信息

```bash
ifconfig
#会提示找不到该命令，请使用下面的命令进行安装 sudo apt install net-tools

sudo apt install net-tools
```

后续步骤建议参考 [ubuntu20.04配置静态ip,ubuntu设置静态ip方法 - ubuntu安装配置教程 - 博客园 (cnblogs.com)](https://www.cnblogs.com/ubuntuanzhuang/p/13131138.html)

## 配置ssh服务，提供远程连接服务

```bash
sudo apt-get install openssh-server
```

## 其他配置

### 关闭图形界面

```bash
#ctop
sudo systemctl set-default multi-user.target

#start
sudo systemctl set-default graphical.target
```

### 配置国内更新源

`sudo vim /etc/apt/sources.list`

添加或者替换以下信息：

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