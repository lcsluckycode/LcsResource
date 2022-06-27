# 常用linux操作系统盘点

## 1. 商业版划分

商业版：`RedHat Enterprise Linux`

免费发行版：`Ubuntu 、CentOS 、Debain`

## 2. 包管理器划分

包管理器理解为，用来为`Linux`系统上的软件`安装`、`卸载`、`升级`、`查询`提供支持的组件，所以对于用户使用来说，一般是一组工具命令集。

目前`Linux`世界里的包管理种类繁荣，选几个最主流的，可以大致梳理成如下表格所示，每一种都有对应的Linux发行版代表：

| 包管理器名称 | 常用标志性指令 |   代表系统举例   |
| :----------: | :------------: | :--------------: |
|     DPKG     |   dpkg、apt    | Debain、Ubuntu等 |
|     RPM      |    rpm、yum    | RedHat、CentOS等 |
|    Pacman    |     pacman     | Arch、Manjaro等  |
|     DNF      |      dnf       |      Fedora      |
|    Zypper    |     zypper     |       SUSE       |
|   Portage    |     emerge     |      Gentoo      |

![图片](E:\lcsprogram\study_doc\Linux\images\packages.jpg)

# 常用Linux

## Debian

`Debian`和`Ubuntu`是一个派系的，但界面可能没有`Ubuntu`那么华丽，但是比较稳定，也适合用作服务器操作系统。`Debian`在开源圈子用得十分广泛，也有一大批开源爱好者活跃于其中。

![图片](E:\lcsprogram\study_doc\Linux\images\Debian.jpg)

------

## Ubuntu

`Ubuntu`界面比较华丽，包管理器很完善，社区也非常活跃，个人用户确实很多，所以从市面上看的确比较大众化。

![图片](E:\lcsprogram\study_doc\Linux\images\Ubuntu.jpg)

------

## RedHat

`RHEL（Red Hat Enterprise Linux）`毕竟是商业版`Linux`系统，一般多用于企业生产环境，提供完善的商业支持，在性能、稳定性方面也有很大的保障。

![图片](E:\lcsprogram\study_doc\Linux\images\Redhat.jpg)

------

## CentOS

`CentOS`可以理解为是基于`RedHat`商业版系统的社区编译重发布版，完全开源免费，因此相较于其他一些免费的`Linux`发行版会更加稳定，也因此一般企业里常用作服务器操作系统。

![图片](E:\lcsprogram\study_doc\Linux\images\centos.jpg)

------

## Fedora

`Fedora`其实和`RedHat`也同属一个派系，背后的支撑企业也是红帽子公司。但是`Fedora`是免费发行版，而且更加侧重于新技术的试验和加持，因此稳定性方面的考量较`CentOS`会稍微次要一些。

![图片](E:\lcsprogram\study_doc\Linux\images\Fedora.jpg)

------

## SUSE

`SUSE`背后也算是有大公司的支持了，目前主要也还是多用于企业用户。

![图片](E:\lcsprogram\study_doc\Linux\images\SUSE.jpg)

------

## Arch

`Arch`的确比较适合好奇心强的人尝鲜，它的官方`Wiki`做得好，`AUR`仓库很繁荣，适合`DIY`玩家去折腾，确实也吸引了不少粉丝。

![图片](E:\lcsprogram\study_doc\Linux\images\Arch.jpg)

------

## Manjaro

`Manjaro`可以看成是`Arch Linux`的衍生分支，既包含了`Arch`的常见优点，但也对用户友好，注重体验和稳定性。`Manjaro`的安装和使用都比较方便，目前使用用户非常多。

![图片](E:\lcsprogram\study_doc\Linux\images\Manjaro.jpg)

------

## Gentoo

`Gentoo`适合极客范化的折腾，也比较适合有特殊需要和特殊化定制的需求，总体来说比较小众。但是用得很6的大佬们都说好，因为这些大佬们大多有系统洁癖，控制欲很强，什么都需要自己编译、自己定制，这个对他们来说简直就是天堂了。

![图片](E:\lcsprogram\study_doc\Linux\images\Gentoo.jpg)

------

# 选用建议

- 如果是完全0基础的新手，只是想入门`Linux`的生态，体验`Linux`界面，那`Ubuntu`就非常合适
- 如果喜欢折腾和DIY，好奇心满满，可以试试`Arch`、`Manjaro`、`Gentoo`这些
- 如果想用来部署服务，考虑稳定性，那`CentOS`、`Debian`都是不错的选择