# bitbake 

# 简单介绍

[bitbake English 手册](https://blog.csdn.net/aaaLG/article/details/107881303)

[(19条消息) Bitbake中文手册--1(概述)_hubbybob1专栏-CSDN博客_bitbake中文手册](https://blog.csdn.net/hubbybob1/article/details/118093430)

[(19条消息) BitBake用户手册_aaaLG的博客-CSDN博客_bitbake中文手册](https://blog.csdn.net/aaaLG/article/details/107881303)

OE BI他Bake是一个软件组建自动化工具程序。bitbake不是基于吧依赖写死的makefile，而是收集和管理大量没有依赖关系的描述文件，然后自动按照正确的顺序进行构建。

OpenEmbeedded是一些脚本（shell和python脚本）和数据构成的自动构建系统。脚本实现构建过程，包括下载（fetch）、解包（unpack）、打补丁（patch）、配置（configure）、编译（compile）、安装（install）、打包（package）、staging、做安装包（package_write_ipk）、构建文件系统等

**OE编译顺序**

```txt
1 do_setscene
2 do_fetch 
3 do_unpack 
4 do_path 
5 do_configure
6 do_qa_configure
7 do_compile
8 do_stage
9 do_install
10 do_package
11 do_populate_staging
12 do_package_write_deb
13 do_package_write
14 do_distribute_sources
15 do_qa_staging
16 do_build
17 do_rebuild
```

|       TASK       | DESCRIPTION                                                  | FUNCTION             |
| :--------------: | :----------------------------------------------------------- | :------------------- |
|      Build       | Default task for a recipe - depends on all other normal tasks required to 'build' a recipe | do_build             |
|    Init RAMFS    | Combines an initial ramdisk image and kernel together to form a single image | do_bundle_initramfs  |
|    Check URI     | Validates the SRC_URI value                                  | do_checkuri          |
|      Clean       | Removes all output files for a target                        | do_clean             |
|    Clean all     | Removes all output files, shared state cache, and downloaded source files for a target | do_cleanall          |
|   Clean SSTATE   | Removes all output files and shared state cache for a target | do_cleansstate       |
|     Compile      | Compiles the source in the compilation directory             | do_compile           |
|    Configure     | Configures the source by enabling and disabling any build-time and configuration options for the software being built | do_configure         |
|    Dev Shell     | Starts a shell with the environment set up for development/debugging | do_devshell          |
|      Fetch       | Fetches the source code                                      | do_fetch             |
|     Install      | Copies files from the compilation directory to a holding area | do_install           |
|    List Tasks    | Lists all defined tasks for a target                         | do_listtasks         |
|     Package      | Analyzes the content of the holding area and splits it into subsets based on available packages and files | do_package           |
|    Package QA    | Runs QA checks on packaged files                             | do_package_qa        |
|    Write IPK     | Creates the actual IPK packages and places them in the Package Feed area | do_package_write_ipk |
|      Patch       | Locates patch files and applies them to the source code      | do_patch             |
| Populate License | Writes license information for the recipe that is collected later when the image is constructed | do_populate_lic      |
|   Populate SDK   | Creates the file and directory structure for an installable SDK | do_populate_sdk      |
| Populate SYSROOT | Copies a subset of files installed by do_install into the sysroot in order to make them available to other recipes | do_populate_sysroot  |
|     Root FS      | Creates the root filesystem (file and directory structure) for an image | do_rootfs            |
|      Unpack      | Unpacks the source code into a working directory             | do_unpack            |

值得注意的是：do_complile这些函数都是在OpenEmbeeded的classes中定义的，而bitbake中并没有对这些进行相关的定义。bitbake只是OE更底层的一个工具，也就是说，OE是基于bitbake架构来完成的。

# 文件系统里面的 OpenEmbedded

OE环境中最重要的目录（３）：

- 放工具的bitbake目录
- 放元数据的目录
- 执行构建的build目录

## bitbake目录

这个目录存放 的是我们的bitbake，可以使用它，但是通常不能访问修改它

## 元数据目录

在poky中元数据目录是meta，Openmoko中元数据目录是openembedded。在元数据目录中，有3个目录是真正的元数据，他们是：`classes、conf、packages`

### package目录

所有的配方（recipes）文件（后缀为.bb）都放在package目录，每个相对独立的软件包或构建任务在package目录下都有自己的子目录。在子目录中可以有多个配方文件，他们可以是同一个软件包的不同版本，也可以是描述了基于同一个软件包的不同构建目标。packages目录的images子目录下就是这些要求构建文件系统的配方（recipes）。

### classes目录

这个目录放的是配方的类文件（后缀为.bbclass）。类文件包含了一些bitbake任务的定义，例如怎么配置、怎么安装。配方文件继承类文件，也就继承了这些任务的定义。例如：我们如果增加一个使用 autotool 的软件包，只要在配方文件中继承 autotools.bbclass：

```txt
1  inherit autotools
```

bitbake 就知道怎样使用 autotool 工具配置、编译、安装了。所有的配方文件都自动继承了 base.bbclass。base.bbclass 提供了大部分 bitbake 任务的默认实现。
 一个配方文件可以继承多个类文件。以后的文章会介绍 bitbake 的任务，届时会更详细地讨论 bitbake 的继承。目前，我们只要知道继承类文件是一种构建过程的复用方式就可以了。

### conf目录

conf 目录包含编译系统的配置文件（后缀为 .conf）。bitbake 在启动时会执行 bitbake.conf，bitbake.conf 会装载用户提供的 local.conf，然后根据用户在 local.conf 中定义的硬件平台（MACHINE）和发布目标（DISTRO）装载 machine 子目录和 distro 子目录的配置文件。machine 子目录里是与硬件平台相关的配置文件，distro 子目录里是与发布目标相关的配置文件。配置文件负责设置 bitbake 内部使用的环境变量，这些变量会影响整个构建过程。

# bitbake执行过程

### 解析基础配置元数据

BitBake要做的第一件事是解析基本配置元数据。 基本配置元数据由项目的bblayers.conf文件（确定BitBake需要识别的层），所有必需的layer.conf文件（每一层一个）和bitbake.conf组成。

### 查找并解析recipes

### 

# bitbake中的参数含义

- **BBPATH**，used by BiBake to locate class(.bbclass) and configuration(.conf) files. 此变量类似于PATH变量，标志build的path
- **BBMASK**，屏蔽某些配方文件
- **BBFILES**，BitBake 用于构建软件的配方文件列表
- **BBFILE_COLLECTIONS**，Lists the names of configured layers. These names are used to find the other `BBFILE_*` variables. Typically, each layer appends its name to this variable in its `conf/layer.conf` file.
- **BBFILE_PATTERN**，Variable that expands to match files from  `BBFILES` in a particular layer. This variable is used in the `conf/layer.conf` file and must be suffixed with the name of the specific layer (e.g. `BBFILE_PATTERN_emenlow`).
- **BBFILE_PRIOTY**,Assigns the priority for recipe files in each layer.
- **LAYERDEPENDS**，列出此配方所依赖的层
- **PREFERRED_PROVIDER**，确定当多个配方提供相同项目时应优先考虑哪个配方。您应该始终使用所提供项目的名称作为变量的后缀，并且您应该将其设置为您想要优先考虑的配方的 PN
- **PREFERRED_VERSION**，如果有多个可用的配方版本，则此变量确定应优先考虑哪个配方。您必须始终为变量添加要选择的 PN 后缀，并且您应该相应地设置 PV 以获得优先级。您可以使用“%”字符作为通配符来匹配任意数量的字符，这在指定包含可能会更改的长修订号的版本时非常有用。