# Bitbake 入门

[摘抄转载乐享文章]([快速入门bitbake v3.0 (lexiangla.com)](https://lexiangla.com/teams/k100010/docs/8c96e228219f11ecb9b8c235040366a4?company_from=1e51afc2a7a011e8945c5254002f1020))

# 1. 概述

BitBake 解析 recipe 中的 metadata 描述的数据来源，然后执行 recipe 中的任务(函数)，通过这些任务(函数)来构建出我们需要的工程。

> *小贴士：metadata 就是*描述数据的数据*（data about data），描述数据属性（property）的信息，用来支持如指示存储位置、历史数据、资源查找、文件记录等功能。*

# 2.基本组成

## 2.1 recipe

后缀为bb的文件。BitBake操作对象，用来描述bitbake如何构工程。包含以下信息

1. 关于package的描述信息（作者、主页、许可证等）
2. recipe版本
3. 现有依赖项（构建和运行时依赖项），依赖关系
4. 源代码所处的位置以及如何获取它
5. 源代码是否需要任何补丁，在哪里可以找到它们，以及如何应用它们
6. 如何配置和编译源代码
7. 将生产的工作组装成一个或者多个可安装的包
8. 在目标机器上安装一个或者多创建的包的位置

## 2.2 task函数

`bitbake -c listtasks todorecipe` 查看 `todorecipe` 可执行的`task`

`bitbake -c do_clean(或者clean) todorecipe`删除构建的todorecipe的功能

## 2.3 Configuration Files

后缀为.conf的文件，描述哪里可以找到recipe文件，定义各种项目构建过程中的变量和配置。

需要关注的conf文件：

**build目录下的bblayers.conf**

```bb
# LAYER_CONF_VERSION is increased each time build/conf/bblayers.conf
# changes incompatibly
LCONF_VERSION = "6"

# BitBake 使用它来定位类 (.bbclass) 和配置 (.conf) 文件，
# 这里将BBPATH 设置为构建目录(TOPDIR), 可以使我们在构建目录之外的目录运行bitbake
BBPATH = "${TOPDIR}" 

# 指向 .bb 文件的位置，bb 文件一般由 bblayers 中的 conf 文件指定，所以这里为空
BBFILES ?= ""

RDKROOT := "${@os.path.abspath(os.path.dirname(d.getVar('FILE', True)) + '/../..')}"

# 指向 bblayers 的位置
BBLAYERS ?= " \
  ${RDKROOT}/meta-rdk \

......
BBLAYERS += "${RDKROOT}/meta-rdk-rtk"
BBLAYERS += "${RDKROOT}/meta-rdk-skyworth-rtd-restricted"
```

**bblayers下的layer.conf**

```bb
vi meta-rdk-rtk/conf/layer.conf

# bitbake 将在 LAYERDIR 搜索类 (.bbclass) 和配置 (.conf) 文件
# BBPATH 一般指向当前 layer 所在目录，参考后面的 debug 方法可以打印该目录
BBPATH .= ":${LAYERDIR}"

# bitbake 将在这些目录下搜索 bb 文件
BBFILES += "\
            ${LAYERDIR}/recipes-*/*/*.bb \
            ${LAYERDIR}/recipes-*/*/*/*.bb \
            ${LAYERDIR}/recipes-*/*/*.bbappend \
            ${LAYERDIR}/recipes-*/*/*/*.bbappend \
           "
# 创建一个标识符，个人理解为给这个 layer 整个名字
BBFILE_COLLECTIONS += "rdk-rtk"

# 为 bitbake 指定解析的 layer 目录
BBFILE_PATTERN_rdk-rtk = "^${LAYERDIR}/"

# 当出现同名 layer 时的构建优先级
BBFILE_PRIORITY_rdk-rtk = "29"
```

## 2.4 Classes

后缀为bbclass的文件。用来实现**信息共享**。在bitbake根目录下面存在一个`base.bbclass`，它会 **自动被包含进所有的recipes和classes中**。其他的bbclass文件需要手动引用。这些class一般用于定义标准的基本任务（获取、解包、配置[默认为空]、编译[ 运行任何存在的Makefile ]、安装[ 默认为空 ]和打包[ 默认为空 ]）

## 2.5 Append Files

后缀为bbappend的文件，表示recipe文件的追加内容，对于同名变量，函数进行覆盖。假如bbappend文件找不到对应的bb文件会报错。

## 2.6 Layers

Layers可以将metadata模块化，为提高代码利用效率。基本原则，对于不常改变的代码放到一个layer，对于要修改的部分放到另一个layer。最小的layer架构如下

```bb
mylayer
├── conf
│   └── layer.conf
├── COPYING.MIT
├── README
└── recipes-example
    └── example
        └── example_0.1.bb
```

# 3. bitbake流程

## 3.1 下载和解压

![../_images/source-fetching.png](E:\lcsprogram\study_doc\RDK\images\source-fetching.png)

bitbake最先执行的两个步骤，下载 `do_fetch` 和解压 `do_unpack`。

- **TMPDIR**

  整个工程构建的根目录，默认为tmp

  ```bash
  sdt16445@sky17127:~/hpr0a/build-hpr0a$ bitbake -e skyworth-generic-mediaclient-image | grep ^TMPDIR
  TMPDIR="/home/DIGITAL/sdt16445/hpr0a/build-hpr0a/tmp"
  ```

- **PACKAGE_ARCH**

  定义的工程目录名

  ```bash
  sdt16445@sky17127:~/hpr0a/build-hpr0a$ bitbake -e skyworth-generic-mediaclient-image | grep ^PACKAGE_ARCH
  PACKAGE_ARCH="hpr0a"
  ```

- **TARGET_OS**

  表示目标操作系统和 **HOST_OS** 相同

  ```bash
  sdt16445@sky17127:~/hpr0a/build-hpr0a$ bitbake -e skyworth-generic-mediaclient-image | grep ^TARGET_OS
  TARGET_OS="linux-gnueabi"
  ```

- **PN/BPN**

  当前repice的名称

  ```bash
  sdt16445@sky17127:~/hpr0a/build-hpr0a$ bitbake -e skyworth-generic-mediaclient-image | grep ^PN
  PN="skyworth-generic-mediaclient-image"
  ```

- **PV**

  用于构建repice版本![image-20220301160722620](E:\lcsprogram\study_doc\RDK\images\PV.png)

  ```bash
  sdt16445@sky17127:~/hpr0a/build-hpr0a$ bitbake -e skyworth-generic-mediaclient-image | grep ^PV
  PV="1.0"
  ```

- **PR**

  用于表示repice的修订版本，默认值为 r0，如果有repice版本更新只需要依次修改为r1，r2 ...

  ```bash
  sdt16445@sky17127:~/hpr0a/build-hpr0a$ bitbake -e skyworth-generic-mediaclient-image | grep ^PR
  PR="r0"
  ```

### 3.1.1 创建目录

bitbake在这个阶段会创建下面的目录

```bash
|->tmp
    |->work
    |->${PACKAGE_ARCH}-poky-${TARGET_OS}
        |-> ${PV}-${PR} ------------> recipe 默认工作目录 WORKDIR
            |->${BPN}-${PV} ---------> bitbake 默认工作目录 S 
    |->${MACHINE}-poky-${TARGET_OS}
        |-> ${PV}-${PR}
            |->${BPN}-${PV}
```

通过变量替换就可以得到以下目录

```bash
|->tmp
    |->work
    |->hpr0a-rdk-linux-gnueabi
        |-> 1.0-r0 
            |->skyworth-generic-mediaclient-image-1.0
```

- **WORKDIR**

  repice的工作目录，每个repice都会创建属于自己的工作目录，源文件最终会被拷贝到这个目录

- **S**

  bitbake的工作目录，bitbake会在这个目录运行oe_runmake，这个工作目录可以修改

### 3.1.2 do_fetch获取源文件

bitbake支持各种类型的源文件，其中包括压缩文件tar.bz2、tar.gz，本地文件，远程仓库文件等。

![watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3NvbmJhaQ==,size_16,color_FFFFFF,t_70](E:\lcsprogram\study_doc\RDK\images\do_petch.png)

- **FILESEXTRAPATHS_prepend**

  当从本地获取源文件时用于指定源文件所在的目录，配合 **SRC_URI**确认源文件的绝对路径

- **SRC_URI**

  这个变量指定源文件，可以通过不同的参数表示不同类型的源文件

  ```vim
  file:// -----> 从本机获取源文件，该路径是相对于 FILESPATH 变量的。因此它的默认搜索路径为 .bb 文件 或 .bbappend 文件所在目录的子目录
  bzr://   -----> 从 Bazaar 版本控制存储库中获取文件。 
  git://   -----> 从 Git 版本控制存储库中获取文件。 
  osc://   -----> 从 OSC（openSUSE 构建服务）版本控制存储库获取文件。 
  repo://  -----> 从 repo (Git) 存储库中获取文件。
  ccrc://  -----> 从 ClearCase 存储库中获取文件。
  http://  -----> 使用 http 从 Internet 获取文件。
  https:// -----> 使用 https 从 Internet 获取文件。
  ftp://   -----> 使用 ftp 从 Internet 获取文件。
  cvs://   -----> 从 CVS 版本控制存储库中获取文件。
  hg://    -----> 从 Mercurial (hg) 版本控制存储库中获取文件。
  p4://    -----> 从 Perforce (p4) 版本控制存储库中获取文件。
  ssh://   -----> 通过 ssh 获取源文件
  svn://   -----> 从 Subversion (svn) 版本控制存储库获取文件。
  npm://   -----> 从注册表中获取 JavaScript 模块。
  az://    -----> 从 Azure 存储帐户获取文件。 
  ```

  其中使用 `http://`、`https://`、 `ftp://` 等方式指定的时候，下载的源文件将被保存到 **DL_DIR** 指向的目录，一般在 `build/conf/local.conf`指定

  ```bash
  vim build-hx4x.lib32-hy44g-rdk/conf/local.conf
  
  DL_DIR ?= "${TOPDIR}/../downloads"
  ```

  如果时 `git://` 指定的源文件，则会保存到 `${DL_DIR}/git2/` 目录

  ### 3.1.3 do_updack解压缩

  如果时本地的源文件则直接将其拷贝到**WORKDIR**，如果时 **DL_DIR**下面的压缩文件则将其解压到 **WORKDIR**。

## 3.2 打补丁

当我们获取源码并将其放到指定工作目录之后，接下来做的就是打补丁 `do_patch`。

![../_images/patching.png](E:\lcsprogram\study_doc\RDK\images\patching.png)

bitbake处理的补丁有两种 `*.patch` 和 `*.diff`，打补丁的操作比较简单，默认情况就是在S目录执行 `patch -p1 < *.patch/*.diff`

除了打补丁还会创建出 `recipe-sysroot` 和 `recipe-sysroot-native`目录，并将本地的依赖和库文件放入该目录

```bash
sdt16445@sky17127:~/hpr0a1/build-hpr0a/tmp/work/armv7ahf-neon-rdk-linux-gnueabi/nano-app/1.0-r0/recipe-sysroot-native$ tree -L 1
.
├── bin
├── etc
├── installeddeps
├── sysroot-providers
└── usr
```

## 3.3 配置编译

![../_images/configuration-compile-autoreconf.png](E:\lcsprogram\study_doc\RDK\images\configuration-compile-autoreconf.png)

do_configure也就是对我们的编译环境进行一些初始化配置，然后就是do_compile编译，对于使用makefile的repice就是在 **S** 目录执行 oe_make的过程。最后就是do_install对我们的编译文件做进一步操作。

### 3.3.1 do_configure

对于使用autotools项目，这个阶段的任务就是设置环境变量，并执行.configure --prefiex=xxx的过程。这个阶段可以通过**EXTRA_OECONF**设置相关配置选项

```bash
EXTRA_OECONF += " --enable-wifihal"
EXTRA_OECONF += " --enable-powermgrhal"
EXTRA_OECONF += " --enable-bluetoothhal"
EXTRA_OECONF += " --enable-mfrhal"
```

对于cmake的项目，可以通过**EXTRA_OECMAKE**设置相关的配置选项

```bash
EXTRA_OECMAKE += "-DBUILD_WITH_WAYLAND=ON "
EXTRA_OECMAKE += "-DBUILD_WITH_WESTEROS=ON "
EXTRA_OECMAKE += "-DBUILD_WITH_TEXTURE_USAGE_MONITORING=ON "
EXTRA_OECMAKE += "-DPXCORE_COMPILE_WARNINGS_AS_ERRORS=OFF "
```

对于makefile项目，可以通过 **EXTRA_OEMAKE** 设置相关环境变量

```bash
EXTRA_OEMAKE = "'CC=${CC}' 'CFLAGS=${CFLAGS}'"
EXTRA_OEMAKE_append = " 'CFLAGS += -I $(DIR_INC) -lasound'"
EXTRA_OEMAKE_append = " 'LDFLAGS=${LDFLAGS}'"
EXTRA_OEMAKE_append = " 'DESTDIR=${D}'"
```

除此之外流程还会创建出`repice-sysroot`中的依赖文件，这些依赖文件就是编译的时候会调用的文件。

```bash
sdt16445@sky17127:~/hpr0a1/build-hpr0a/tmp/work/armv7ahf-neon-rdk-linux-gnueabi/nano-app/1.0-r0/recipe-sysroot$ tree -L 1
.
├── lib
├── sysroot-providers
└── usr
```

### 3.3.2 do_compile

编译由**B**变量指向的编译目录中的源代码。**B**变量指向的源码就是**S**变量指向的源码。本质就是在 **S** 变量指向的路经执行make

### 3.3.3 do_install

在**D**变量定义的保存区域创建我们需要的目录，将文件从由B变量定义的编译目录复制到我们创建的目录。

```bash
do_install () {
    install -d ${D}${systemd_unitdir}/system # 创建 ${D}/lib/systemd/systrm 目录
    install -m 0644 ${WORKDIR}/nanoapp.service ${D}${systemd_unitdir}/system # 将 nanoapp.service 复制到这个目录

    install -d ${D}/usr/bin # 创建 ${D}/usr/bin 目录
    install -m 0755 ${WORKDIR}/nanosic_app_V8 ${D}/usr/bin/nanosic_app_V8 # 将 nanosic_app_V8 复制到这个目录

    install -d ${D}/etc # 创建 ${D}/etc/ 目录
    install -m 0755 ${WORKDIR}/nanosic.conf ${D}/etc/nanosic.conf # 将 nanosic.conf 复制到这个目录
}
```

## 3.4 包的拆解

![../_images/analysis-for-package-splitting.png](E:\lcsprogram\study_doc\RDK\images\analysis-for-package-splitting.png)

### 3.4.1 do_populate_sysroot

将 do_install 任务安装的文件子集复制到 sysroot 中，以便于他们可以用于其他配方。创建出 sstate-install-populate_sysroot 和 sysroot-destdir。

### 3.4.2 do_package

分析保存区域的内容，并根据可用的包和文件将其拆分为子集。该任务会创建 pkgdata、packages-split、pkgdata_sysroot、sstate-install-package四个目录。其中 packages-split 中的内容就是 bb 文件配置的

```bash
FILES_${PN} += "${systemd_unitdir}/system/nanoapp.service"
FILES_${PN} += "/usr/bin/nanosic_app_V8"
FILES_${PN} += "/etc/nanosic.conf"
```

包中的内容来自 do_install 时安装到暂存区 image 中的内容。

```bash
packages-split/
├── nano-app
│   ├── etc
│   │   └── nanosic.conf
│   ├── lib
│   │   └── systemd
│   │       ├── system
│   │       │   └── nanoapp.service
│   │       └── system-preset
│   │           └── 98-nano-app.preset
│   └── usr
│       └── bin
│           └── nanosic_app_V8
├── nano-app-dbg
│   └── usr
│       └── bin
├── nano-app-dev
├── nano-app-doc
├── nano-app-locale
├── nano-app-src
└── nano-app-staticdev
```

### 3.4.3 do_packagedata

 生成最终包 pkgdata-pdata-input

```bash
sdt16445@sky17127:~/hpr0a1/build-hpr0a/tmp/work/armv7ahf-neon-rdk-linux-gnueabi/nano-app/1.0-r0$ tree pkgdata-pdata-input
pkgdata-pdata-input
├── nano-app
├── runtime
│   ├── nano-app
│   ├── nano-app-dbg
│   ├── nano-app-dbg.packaged
│   ├── nano-app-dev
│   ├── nano-app-dev.packaged
│   ├── nano-app-doc
│   ├── nano-app-locale
│   ├── nano-app.packaged
│   ├── nano-app-src
│   └── nano-app-staticdev
├── runtime-reverse
│   ├── nano-app -> ../runtime/nano-app
│   ├── nano-app-dbg -> ../runtime/nano-app-dbg
│   └── nano-app-dev -> ../runtime/nano-app-dev
├── runtime-rprovides
└── shlibs2
```

### 3.4.4 镜像文件的制作

![../_images/image-generation.png](E:\lcsprogram\study_doc\RDK\images\image-generation.png)

# 4. 实际操作 

直接动手实验是上手最快的方式，当我们拉完代码，在经过第一次漫长的编译过程之后的目录如下

```javascript
sdt16445@sky17127:~/hpr0a$ ls
build-hpr0a   meta-cmf             meta-cmf-video-restricted  meta-mylayer       meta-raspberrypi    meta-rdk-oem-skyworth-rtd         meta-rdk-soc-realtek  meta-virtualization
docs          meta-cmf-qt5         meta-dvb                   meta-openembedded  meta-rdk            meta-rdk-restricted               meta-rdk-video        openembedded-core
downloads     meta-cmf-restricted  meta-gplv2                 meta-python2       meta-rdk-ext        meta-rdk-rtk                      meta-rdk-voice-sdk    sstate-cache
meta-browser  meta-cmf-video       meta-mcg                   meta-qt5           meta-rdk-mcg-hpr0a  meta-rdk-skyworth-rtd-restricted  meta-rtlwifi          test.sh
```

  bitbake 对于 layer 的操作也提供了特别的脚本，也就是 bitbake-layers ，我们可以使用 -h 查看这个脚本默认支持的功能

```javascript
sdt16445@sky17127:~/hpr0a$ bitbake-layers -h
NOTE: Starting bitbake server...
    ......
subcommands:
  <subcommand>
    add-layer           Add one or more layers to bblayers.conf.
    remove-layer        Remove one or more layers from bblayers.conf.
    show-layers         show current configured layers.
    create-layer        Create a basic layer
    ......
Use bitbake-layers <subcommand> --help to get help on a specific command
```

  其中我们实验会用到的主要有四个 `create-layer`、`add-layer`、`show-layers` 和 `remove-layer`，进入到 build-hpr0a 目录运行 `bitbake-layers show-layers` 查看当前有哪些 layers

```javascript
sdt16445@sky17127:~/hpr0a$ bitbake-layers show-layers
NOTE: Starting bitbake server...
layer                 path                                      priority
==========================================================================
meta-rdk-voice-sdk    /home/DIGITAL/sdt16445/hpr0a/meta-rdk-voice-sdk  8
...
meta-rdk-skyworth-rtd-restricted  /home/DIGITAL/sdt16445/hpr0a/meta-rdk-skyworth-rtd-restricted  35
```

  我们要在这个基础上创建一个我们自己的 meta-mylayer

```javascript
# meta-mylayer 是相对路径，这里为当前路径下创建
sdt16445@sky17127:~/hpr0a$ bitbake-layers create-layer meta-mylayer
NOTE: Starting bitbake server...
Add your new layer with 'bitbake-layers add-layer meta-mylayer'
```

  查看我们创建的 layer

```javascript
sdt16445@sky17127:~/hpr0a$ tree meta-mylayer/
meta-mylayer/
├── conf
│   └── layer.conf
├── COPYING.MIT
├── README
└── recipes-example
    └── example
        └── example_0.1.bb

3 directories, 4 files
```

  这也是最小 layer 的结构，一个 layer 可以包含很多 recipes ，而每一个 recipes 表示 repcipe 集合，如下

```javascript
sdt16445@sky17127:~/hpr0a$ tree meta-rdk-skyworth-rtd-restricted/ -L 2
meta-rdk-skyworth-rtd-restricted/
├── conf
│   ├── layer.conf
│   └── sk_common.inc
├── recipes-core
│   ├── images
│   ├── packagegroups
│   ├── sk-audio-ddp
│   └── tee-agent
├── recipes-extended
│   ├── bluetooth
│   ├── widevine
│   └── wpe-framework
├── recipes-kernel
│   ├── bt-ap6275s
│   ├── bt-rtl8822cs
│   ├── sk-wifi-detect
│   ├── wifi-ap6275s
│   └── wifi-rtl8822cs
└── setup-environment
```

  对于`meta-rdk-skyworth-rtd-restricted`这个 layer ，将内核模块(recipes-kernel) 作为一个 recipes ，而具体的功能模块，像蓝牙、WiFi等就是一个个 recipe 他们由 bb 文件描述，作为 bitbke 执行的对象。

现在我们已经创建了一个 meta-mylayer ,我们需要使用 `bitbake-layers add-layer ../meta-mylayer` 将其添加到 bitbake 的环境中

```javascript
sdt16445@sky17127:~/hpr0a/build-hpr0a$ bitbake-layers add-layer ../meta-mylayer
NOTE: Starting bitbake server...
```

  来查看一下我们创建的 layer 是否已经添加成功

```javascript
sdt16445@sky17127:~/hpr0a/build-hpr0a$ bitbake-layers show-layers
NOTE: Starting bitbake server...
layer                 path                                      priority
...
meta-mylayer          /home/DIGITAL/sdt16445/hpr0a/meta-mylayer  6
```

  可以在最后看到我们的 layer 已经被添加到 bitbake 中了。打开这个 meta-mylayer 的 bb 文件

```c
vi ../meta-mylayer/recipes-example/example/example_0.1.bb

SUMMARY = "bitbake-layers recipe"
DESCRIPTION = "Recipe created by bitbake-layers"
LICENSE = "MIT"

python do_display_banner() {
    bb.plain("***********************************************");
    bb.plain("*                                             *");
    bb.plain("*  Example recipe created by bitbake-layers   *");
    bb.plain("*                                             *");
    bb.plain("***********************************************");
}

addtask display_banner before do_build
```

  可以看到内容其实很简单就是打印了一句 log ，我们来运行这个任务 `bitbake -c do_display_banner example` 可以看到 log 成功的出现在了我们的屏幕

```javascript
bitbake -c do_display_banner example

Initialising tasks: 100% |
***********************************************
*                                             *
*  Example recipe created by bitbake-layers   *
*                                             *
***********************************************
Summary: There were 7 WARNING messages shown.
```

  对于 yocto 来说，我们在运行 bitbake 前要对他做一个初始化，其实就是设置相关环境变量。对于我们的项目，我们需要执行以下 source 命令

```javascript
source meta-rdk-skyworth-rtd-restricted/setup-environment --hpr0a  --restricted --drm-restricted  -w 
```

  这条命令会将我们的 bitbake 导出到环境变量中，之后我们就可以直接 bitbake -h 查看 bitbake 的用法。

# 5. debug

recipe 中有很多变量，有些事 bitbke 提供的默认值，有时候我们想知道这些变量在运行时候的值是多少。bitbake 为我们提供了两个 debug 的参数 `-s`、`-e`和 `-v` 个参数。

  `bitbake -s` 用于显示有哪些 recipe ，可以使用 grep 过滤查找，`bitbake -s | grep example` 用于查找 example 相关的 recipe。

  `-e` 参数可以显示当前的执行环境，`bitbake -e recipe | grep ^变量名` 这条命就可以打印出对应 recipe 中的某个变量名。如下所示打印出 example 中 WORKDIR 这个变量的值。

```javascript
sdt16445@sky17127:~/hpr0a/build-hpr0a$ bitbake -e example | grep ^WORKDIR
WORKDIR="/home/DIGITAL/sdt16445/hpr0a/build-hpr0a/tmp/work/armv7ahf-neon-rdk-linux-gnueabi/example/0.1-r0"
```

  `-v`用于显示执行过程，我们可以通过 `bitbake -v myRecipe > ./myRecipe.log` 将执行过程的 log 到导入 myRecipe.log 文件。

# 6. 编译应用程序

在我们的项目中编译应用程序，新增的应用程序如下目录如下,可以放到任意 recipes 目录下，可根据项目功能的划分选择对应的模块。

```javascript
sdt16445@sky17127:~/hpr0a1/meta-rdk-oem-skyworth-rtd/recipes-multimedia/helloworld$ tree
.
├── helloworld.bb
└── src
    ├── inc
    │   └── hello.h
    ├── main.c
    └── Makefile
```

**hello.c**:

```c
#include <stdio.h>
#include <hello.h>

int main(void)
{

    printf(HELLO);
    return 0;
}
```

**hello.h**:

```c
#ifndef _HELLO_H_
#define _HELLO_H_

#define HELLO "hello world\n"

#endif /* _HELLO_H_ */
```

**Makefile**:

```javascript
.PHONY : all clean

RM := rm -rf

APP := hello

SRCS := main.c

DIR_INC := inc
DIR_SRC := src

vpath %.h $(DIR_INC)  # 在 inc 中搜索 .h 文件

all : $(APP)
    @echo "target ==> $(APP)"

$(APP) : $(SRCS)
    $(CC) $^ -o $@ $(CFLAGS) $(LDFLAGS)

clean :
    $(RM) *.o *.out $(APP)
```

**helloworld.bb**:

```javascript
DESCRIPTION = "my helloworld app"
LICENSE = "CLOSED"

FILESEXTRAPATHS_prepend := "${THISDIR}/src:"
SRC_URI += "file://inc"
SRC_URI += "file://Makefile"
SRC_URI += "file://main.c"

# 由于是由 Makefile 指定的项目，
# 因此需要使用 EXTRA_OEMAKE 指定交叉编译的编译器 CC 以及命令行参数 CFLAGS 和 LDFLAGS
EXTRA_OEMAKE = "'CC=${CC}' 'CFLAGS=${CFLAGS}'"
EXTRA_OEMAKE_append = " 'CFLAGS += -I $(DIR_INC)'"
EXTRA_OEMAKE_append = " 'LDFLAGS=${LDFLAGS}'"

S = "${WORKDIR}"
```

运行`bitbake helloworld`,运行完之后可以通过 `bitbake -e | grep ^S=` 查看编译路径。

```javascript
sdt16445@sky17127:~/hpr0a1/meta-rdk-oem-skyworth-rtd/recipes-multimedia/helloworld$ bitbake -e  helloworld | grep ^S=
S="/home/DIGITAL/sdt16445/hpr0a1/build-hpr0a/tmp/work/armv7ahf-neon-rdk-linux-gnueabi/helloworld/1.0-r0"

sdt16445@sky17127:~/hpr0a1/meta-rdk-oem-skyworth-rtd/recipes-multimedia/helloworld$ ls /home/DIGITAL/sdt16445/hpr0a1/build-hpr0a/tmp/work/armv7ahf-neon-rdk-linux-gnueabi/helloworld/1.0-r0
configure.sstate  image            main.c    packages-split  pkgdata-pdata-input  recipe-sysroot          sstate-install-packagedata        sstate-install-populate_lic      temp
deploy-ipks       inc              Makefile  patches         pkgdata-sysroot      recipe-sysroot-native   sstate-install-package_qa         sstate-install-populate_sysroot
hello             license-destdir  package   pkgdata         pseudo               sstate-install-package  sstate-install-package_write_ipk  sysroot-destdir
```

  可以看见 hello app 已经编译生成，可以用 U 盘将其拷贝到开发板运行。

```javascript
root@hpr0a:~# chmod 777 hello
root@hpr0a:~# ./hello
hello world
```

# 7. 编译内核

 将驱动放入对应的 layers 下的 recipes ，这里新增一个声卡驱动。

```c
sdt16445@sky17127:~/hpr0a1/meta-rdk-oem-skyworth-rtd/recipes-kernel/audio-driver$ tree
.
├── audio-driver.bb
└── files
    ├── Makefile
    ├── vaudio_card.c
    ├── vaudio_card_dev.c
    ├── vaudio_card_dev.h
    └── vaudio_card.h
```

**audio-driver.bb**:

```javascript
SUMMARY = "Realtek 8822 HCI (H5) Linux kernel module"
LICENSE = "CLOSED"
require conf/sk_common.inc

# 编译内核需要继续 module 这个类
inherit module

MODULE_NAME := "vaudio"

S = "${WORKDIR}"

# 指定源码位置
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI += "file://Makefile"
SRC_URI += "file://vaudio_card.c"
SRC_URI += "file://vaudio_card_dev.c"
SRC_URI += "file://vaudio_card_dev.h"
SRC_URI += "file://vaudio_card.h"

# 安装模块到内核
do_install() {
    RTLDIR=${D}/lib/modules/${KERNEL_VERSION}/kernel/realtek
    unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS
    install -d ${RTLDIR}
    install -m 0666 ${S}/${MODULE_NAME}.ko ${RTLDIR}/
}

# 自动安装内核模块
KERNEL_MODULE_AUTOLOAD += "${MODULE_NAME}"
```

**Makefile:**

```javascript
obj-m := vaudio.o
vaudio-objs :=  vaudio_card.o vaudio_card_dev.o

SRC := $(shell pwd)

all:
    $(MAKE) -C $(KERNEL_SRC) M=$(SRC)

modules_install:
    $(MAKE) -C $(KERNEL_SRC) M=$(SRC) modules_install

clean:
    rm -f *.o *~ core .depend .*.cmd *.ko *.mod.c
    rm -f Module.markers Module.symvers modules.order
    rm -rf .tmp_versions Modules.symvers
```

  编译完成后可以在 S 目录查看编译结果

```javascript
sdt16445@sky17127:~/hpr0a1$ bitbake -e  audio-driver | grep ^S=
S="/home/DIGITAL/sdt16445/hpr0a1/build-hpr0a/tmp/work/hpr0a-rdk-linux-gnueabi/audio-driver/1.0-r0"
sdt16445@sky17127:~/hpr0a1$ ls /home/DIGITAL/sdt16445/hpr0a1/build-hpr0a/tmp/work/hpr0a-rdk-linux-gnueabi/audio-driver/1.0-r0/
built-in.o        license-destdir  package         pkgdata-pdata-input  recipe-sysroot-native       sstate-install-package_write_ipk  temp               vaudio_card_dev.o  vaudio.mod.c
configure.sstate  Makefile         packages-split  pkgdata-sysroot      sstate-install-package      sstate-install-populate_lic       vaudio_card.c      vaudio_card.h      vaudio.mod.o
deploy-ipks       modules.order    patches         pseudo               sstate-install-packagedata  sstate-install-populate_sysroot   vaudio_card_dev.c  vaudio_card.o      vaudio.o
image             Module.symvers   pkgdata         recipe-sysroot       sstate-install-package_qa   sysroot-destdir                   vaudio_card_dev.h  vaudio.ko
```

  写固件到机器，可以看到我们增加的声卡驱动

```javascript
root@hpr0a:~# cat /proc/asound/cards
 0 [sndalsartk     ]: snd_alsa_rtk - snd_alsa_rtk
                      snd_alsa_rtk
 1 [NANOSICVAUDIO  ]:  - # 我们增加的声卡驱动 NANOSICVAUDIO
```

# 8. 添加服务

 新增一个服务，系统在开机时运行一个应用程序 nanosic_app_V7，其中 nanosic.conf 是 nanosic_app_V7 需要的配置文件。

```javascript
sdt16445@sky17127:~/hpr0a1/meta-rdk-oem-skyworth-rtd/recipes-multimedia/nano-app$ tree
.
├── files
│   ├── nanoapp.service
│   ├── nanosic_app_V7
│   └── nanosic.conf
└── nano-app.bb
```

**nano-app.bb**：

```javascript
LICENSE = "CLOSED"

# 编译服务需要继承这个类
inherit  systemd

# 指定源码路径
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI = " \
            file://nanoapp.service \
            file://nanosic_app_V7 \
            file://nanosic.conf \
          "

S = "${WORKDIR}/git"

# 指定服务以及 app 和配置文件所在系统路径
FILES_${PN} += "${systemd_unitdir}/system/nanoapp.service"
FILES_${PN} += "/usr/bin/nanosic_app_V7"
FILES_${PN} += "/etc/nanosic.conf"

# 将服务装到执行的系统路径
do_install () {
    install -d ${D}${systemd_unitdir}/system
    install -m 0644 ${WORKDIR}/nanoapp.service ${D}${systemd_unitdir}/system

    install -d ${D}/usr/bin
    install -m 0755 ${WORKDIR}/nanosic_app_V7 ${D}/usr/bin/nanosic_app_V7

    install -d ${D}/etc
    install -m 0755 ${WORKDIR}/nanosic.conf ${D}/etc/nanosic.conf
}

# 指定要运行的服务
SYSTEMD_SERVICE_${PN} = "nanoapp.service"
```

**nanoapp.service**:

```javascript
[Unit]
Description=service for run nano-app
After=nanoapp.service
Requires=nanoapp.service

[Service]
Type=simple
ExecStart=/usr/bin/nanosic_app_V7 &

[Install]
WantedBy=multi-user.target
```

  编译完成后烧写固件，可以用命令 systemctl status 查看我们的服务是否运行

```javascript
root@hpr0a:~# systemctl status
* hpr0a
    State: starting
     Jobs: 3 queued
   Failed: 10 units
    Since: Mon 2018-01-01 00:00:00 UTC; 3 years 10 months ago
   CGroup: /
             | `-2098 /usr/bin/nanosic_app_V7 &
    ......
```

  也可以用 top 命令查看是否在后台运行

```javascript
KiB Mem :  1856308 total,  1199692 free,   462240 used,   194376 buff/cache
KiB Swap:        0 total,        0 free,        0 used.  1219892 avail Mem

  PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
 3494 root      20   0  498740 204544 151816 S  15.8 11.0   1:56.82 WPEWebProcess
 3163 root      20   0  340904  50804  40092 S  14.0  2.7   1:03.43 WPEFramework
27186 root      20   0    6268   3064   2560 R  14.0  0.2   0:01.66 top
    7 root      20   0       0      0      0 S   1.8  0.0   0:01.91 rcu_preempt
 2098 root      20   0   61856    980    892 S   1.8  0.1   0:00.45 nanosic_app_V7
```