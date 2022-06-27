# Git 使用教程

## git config配置

1. `/etc/gitconfig`文件：包含系统上每一个用户及他们仓库的通用配置。`git config --system`则会读取该文件的变量。
2. `~/.gitconfig` or `~/.config/git/config`：只针对当前用户，通过 `git config --global`选项传递，对所有仓库生效
3. 当前使用仓库的Git目录中的 `.git/config`：针对该仓库，`git config --local`

```bash
# 查看配置信息及配置文件所在位置
git config --list --show-origin
```

## 获取Git仓库

### 本地目录转化为Git仓库

```bash
# 打开所在目录
cd /home/user/project

# 初始化git, add .git directory
git init

# 添加指定的文件，* 表示 all
git add *
git add LICENSE
git commit -m 'initial project version'
```

### clone现有的仓库

```bash
git clone <url> [local_path]
```

## 记录更新到仓库

git文件状态变化周期

![lifecycle](E:\lcsprogram\study_doc\others\images\lifecycle.png)

**检查当前文件状态**

```bash
git status
# On branch master
# Your branch is up-to-date with 'origin/master'.
# nothing to commit, working directory clean
```

**状态简览**

`git status` 命令的输出十分详细，但其用语有些繁琐。 Git 有一个选项可以帮你缩短状态命令的输出，这样可以以简洁的方式查看更改。 如果你使用 `git status -s` 命令或 `git status --short` 命令，你将得到一种格式更为紧凑的输出。

```bash
$ git status -s
 M README
MM Rakefile
A  lib/git.rb
M  lib/simplegit.rb
?? LICENSE.txt
```

新添加的未跟踪文件前面有 `??` 标记，新添加到暂存区中的文件前面有 `A` 标记，修改过的文件前面有 `M` 标记。 输出中有两栏，左栏指明了暂存区的状态，右栏指明了工作区的状态。例如，上面的状态报告显示： `README` 文件在工作区已修改但尚未暂存，而 `lib/simplegit.rb` 文件已修改且已暂存。 `Rakefile` 文件已修，暂存后又作了修改，因此该文件的修改中既有已暂存的部分，又有未暂存的部分。

**忽略文件**

一般我们总会有些文件无需纳入 Git 的管理，也不希望它们总出现在未跟踪文件列表。 通常都是些自动生成的文件，比如日志文件，或者编译过程中创建的临时文件等。 在这种情况下，我们可以创建一个名为 `.gitignore` 的文件，列出要忽略的文件的模式。 来看一个实际的 `.gitignore` 例子：

```bash
$ cat .gitignore
*.[oa]
*~
```

第一行告诉 Git 忽略所有以 `.o` 或 `.a` 结尾的文件。一般这类对象文件和存档文件都是编译过程中出现的。 第二行告诉 Git 忽略所有名字以波浪符（~）结尾的文件，许多文本编辑软件（比如 Emacs）都用这样的文件名保存副本。 此外，你可能还需要忽略 `log`，`tmp` 或者 `pid` 目录，以及自动生成的文档等等。 要养成一开始就为你的新仓库设置好 `.gitignore` 文件的习惯，以免将来误提交这类无用的文件。

文件 `.gitignore` 的格式规范如下：

- 所有空行或者以 `#` 开头的行都会被 Git 忽略。
- 可以使用标准的 glob 模式匹配，它会递归地应用在整个工作区中。
- 匹配模式可以以（`/`）开头防止递归。
- 匹配模式可以以（`/`）结尾指定目录。
- 要忽略指定模式以外的文件或目录，可以在模式前加上叹号（`!`）取反。

所谓的 glob 模式是指 shell 所使用的简化了的正则表达式。 星号（`*`）匹配零个或多个任意字符；`[abc]` 匹配任何一个列在方括号中的字符 （这个例子要么匹配一个 a，要么匹配一个 b，要么匹配一个 c）； 问号（`?`）只匹配一个任意字符；如果在方括号中使用短划线分隔两个字符， 表示所有在这两个字符范围内的都可以匹配（比如 `[0-9]` 表示匹配所有 0 到 9 的数字）。 使用两个星号（`**`）表示匹配任意中间目录，比如 `a/**/z` 可以匹配 `a/z` 、 `a/b/z` 或 `a/b/c/z` 等。

**提交更新**

`git commit`，然后启动文本编辑器输入提交说明

**other**

删除，移动等操作，使用对应的`shell`命令进行操作后，需要再次采用`git rm(mv)`进行操作。

## 查看提交历史

`git log` 详见 `git --help log`

## 撤销操作

**撤销提交**

`git commit --amend` 最新的一次提交会替换上一次提交，且上一次提交不会被记录

**取消暂存**

`git reset HEAD filename`

**撤销修改**

`git checkout -- filename`

## 远程仓库使用

查看远程仓库 `git remote`

**添加远程仓库**

`git remote add <shortname> <url>`

拉取仓库中本地没有的信息 `git fetch <shortname>`，`clone`会自动将远程仓库命名为`origin`。

推送 `git push <shortname> <branch>`

## 打标签

**列出标签**

在 Git 中列出已有的标签非常简单，只需要输入 `git tag` （可带上可选的 `-l` 选项 `--list`）：

```console
$ git tag
v1.0
v2.0
```

这个命令以字母顺序列出标签，但是它们显示的顺序并不重要。

你也可以按照特定的模式查找标签。 例如，Git 自身的源代码仓库包含标签的数量超过 500 个。 如果只对 1.8.5 系列感兴趣，可以运行：

```console
$ git tag -l "v1.8.5*"
v1.8.5
v1.8.5-rc0
v1.8.5-rc1
v1.8.5-rc2
v1.8.5-rc3
v1.8.5.1
v1.8.5.2
v1.8.5.3
v1.8.5.4
v1.8.5.5
```

**创建标签**

在 Git 中创建附注标签十分简单。 最简单的方式是当你在运行 `tag` 命令时指定 `-a` 选项：

```console
$ git tag -a v1.4 -m "my version 1.4"
$ git tag
v0.1
v1.3
v1.4
```

`-m` 选项指定了一条将会存储在标签中的信息。 如果没有为附注标签指定一条信息，Git 会启动编辑器要求你输入信息。

通过使用 `git show` 命令可以看到标签信息和与之对应的提交信息：

```console
$ git show v1.4
tag v1.4
Tagger: Ben Straub <ben@straub.cc>
Date:   Sat May 3 20:19:12 2014 -0700

my version 1.4

commit ca82a6dff817ec66f44342007202690a93763949
Author: Scott Chacon <schacon@gee-mail.com>
Date:   Mon Mar 17 21:52:11 2008 -0700

    changed the version number
```

输出显示了打标签者的信息、打标签的日期时间、附注信息，然后显示具体的提交信息。

**轻量标签**

另一种给提交打标签的方式是使用轻量标签。 轻量标签本质上是将提交校验和存储到一个文件中——没有保存任何其他信息。 创建轻量标签，不需要使用 `-a`、`-s` 或 `-m` 选项，只需要提供标签名字：

```console
$ git tag v1.4-lw
$ git tag
v0.1
v1.3
v1.4
v1.4-lw
v1.5
```

# repo  常用命令

`repo <COMMAND> <OPTIONS>`

## XML文件详解

```xml
<?xml version="1.0" encoding="UTF-8"?>  

<manifest>  
    <remote name="origin" fetch=".." review="review.source.android.com" />  
    <default revision="master" remote="origin" />
    <project name="project/build" path="build" >  
        <copyfile src="makefile" dest="makefile.mk" />
    </project>
    <project name="project/test" path="test" />
    <project name="project/apps/hello" path="apps/hello"/> 
</manifest>
```

- `manifest` ，配置文件的顶层元素，根标志

- `remote` 

  - `name`：在每一个 `.git/config` 文件中 `remote` 都必须用到这个 `name` ，表示每一个 `git`远程服务器的名字（这个名字很关键，如果多个`remote`属性的话，`default`属性中需要指定`default remote`）。`git pull`、`get fetch`的时候会用到这个`remote name`。
  - `alias` ：可以覆盖之前定义的`remote name，name`必须是固定的，但是`alias`可以不同，可以用来指向不同的`remote url`
  - `fetch` ：所有`git url`真正路径的前缀，所有`git` 的`project name`加上这个前缀，就是`git url`的真正路径
  - `review` ：指定`Gerrit`的服务器名，用于`repo upload`操作。如果没有指定，则`repo upload`没有效果

- `default`

  设定所有projects的默认属性值，如果在project元素里没有指定一个属性，则使用default元素的属性值。

  - `remote` ：远程服务器的名字（上面remote属性中提到过，多个remote的时候需要指定default remote，就是这里设置了）
  - `revision` ：所有git的默认branch，后面project没有特殊指出revision的话，就用这个branch
  - `sync_j` ： 在repo sync中默认并行的数目
  - `sync_c` ：如果设置为true，则只同步指定的分支(revision 属性指定)，而不是所有的ref内容
  - `sync_s` ： 如果设置为true，则会同步git的子项目

- `manifest-server`

  它的url属性用于指定manifest服务的URL，通常是一个XML RPC 服务

  它要支持一下RPC方法：

  - `GetApprovedManifest(branch, target)` ：返回一个manifest用于指示所有projects的分支和编译目标。
  - target参数来自环境变量`TARGET_PRODUCT`和`TARGET_BUILD_VARIANT`，组成`TARGET_PRODUCT-TARGET_BUILD_VARIANT`
  - `GetManifest(tag)` ：返回指定tag的manifest

- `project`

  需要clone的单独git

  - `name` ：git 的名称，用于生成git url。URL格式是：`{remote fetch}/{project name}.git` 其中的 fetch就是上面提到的remote 中的fetch元素，name 就是此处的name
  - `path` ：clone到本地的git的工作目录，如果没有配置的话，跟name一样
  - `remote` ：定义remote name，如果没有定义的话就用default中定义的remote name
  - `revision` ：指定需要获取的git提交点，可以定义成固定的branch，或者是明确的commit 哈希值
  - `groups` ：列出project所属的组，以空格或者逗号分隔多个组名。所有的project都自动属于"all"组。每一个project自动属于一个`name`：'name' 和`path`：'path'组。例如，它自动属于default, name:monkeys, and path:barrel-of组。如果一个project属于notdefault组，则，repo sync时不会下载
  - `sync_c` ：如果设置为true，则只同步指定的分支(revision 属性指定)，而不是所有的ref内容。
  - `sync_s` ： 如果设置为true，则会同步git的子项目
  - `upstream` ：在哪个git分支可以找到一个SHA1。用于同步revision锁定的manifest(-c 模式)。该模式可以避免同步整个ref空间
  - `annotation` ：可以有0个或多个annotation，格式是name-value，repo forall命令是会用来定义环境变量

- `include`

  通过name属性可以引入另外一个manifest文件(路径相对与当前的manifest.xml 的路径)

  - `name` ：另一个需要导入的manifest文件名字
  - 可以在当前的路径下添加一个another_manifest.xml，这样可以在另一个xml中添加或删除project

- `remove-project`

  从内部的manifest表中删除指定的project。经常用于本地的manifest文件，用户可以替换一个project的定义

## init

`repo init -u <URL> [<OPTIONS>]`

在当前目录中安装 Repo。这会创建一个 `.repo/` 目录，其中包含用于 Repo 源代码和标准 Android 清单文件的 Git 代码库。该 `.repo/` 目录中还包含 `manifest.xml`，这是一个指向 `.repo/manifests/` 目录中所选清单的符号链接。

选项：

- `-u`：指定要从中检索清单代码库的网址。您可以在 `https://android.googlesource.com/platform/manifest` 中找到常见清单
- `-m`：在代码库中选择清单文件。如果未选择任何清单名称，则会默认选择 default.xml。
- `-b`：指定修订版本，即特定的清单分支。

> **注意**：对于其余的所有 Repo 命令，当前工作目录必须是 `.repo/` 的父目录或相应父目录的子目录。

## sync

`repo sync [<PROJECT_LIST>]`

下载新的更改并更新本地环境中的工作文件。如果在未使用任何参数的情况下运行 `repo sync`，则该操作会同步所有项目的文件。

运行 `repo sync` 后，将出现以下情况：

- 如果目标项目从未同步过，则 `repo sync` 相当于 `git clone`。远程代码库中的所有分支都会复制到本地项目目录中。

- 如果目标项目已同步过，则 `repo sync` 相当于以下命令：

  ```bash
  git remote update
  git rebase origin/<BRANCH>
  ```

  其中 **`<BRANCH>`** 是本地项目目录中当前已检出的分支。如果本地分支没有在跟踪远程代码库中的分支，则相应项目不会发生任何同步。

- 如果 `git rebase` 操作导致合并冲突，那么您需要使用普通 Git 命令（例如 `git rebase --continue`）来解决冲突。

`repo sync` 运行成功后，指定项目中的代码会与远程代码库中的代码保持同步。

选项：

- `-d`：将指定项目切换回清单修订版本。如果项目当前属于某个主题分支，但只是临时需要清单修订版本，则此选项会有所帮助。
- `-s`：同步到当前清单中清单服务器元素指定的一个已知的良好版本。
- `-f`：即使某个项目同步失败，系统也会继续同步其他项目。

## forall

`repo forall [<PROJECT_LIST>] -c <COMMAND>`

在每个项目中运行指定的 shell 命令。通过 `repo forall` 可使用下列额外的环境变量：

- `REPO_PROJECT` 可设为项目的具有唯一性的名称。
- `REPO_PATH` 是客户端根目录的相对路径。
- `REPO_REMOTE` 是清单中远程系统的名称。
- `REPO_LREV` 是清单中修订版本的名称，已转换为本地跟踪分支。如果您需要将清单修订版本传递到某个本地运行的 Git 命令，则可使用此变量。
- `REPO_RREV` 是清单中修订版本的名称，与清单中显示的名称完全一致。

选项：

- `-c`：要运行的命令和参数。此命令会通过 `/bin/sh` 进行求值，它之后的任何参数都将作为 shell 位置参数传递。
- `-p`：在指定命令输出结果之前显示项目标头。这通过以下方式实现：将管道绑定到命令的 stdin、stdout 和 sterr 流，然后通过管道将所有输出结果传输到一个页面调度会话中显示的连续流中。
- `-v`：显示该命令向 stderr 写入的消息。

# 疑难杂症

```bash
error: RPC failed; curl 56 GnuTLS recv error (-54): Error in the pull function.
fetch-pack: unexpected disconnect while reading sideband packet
fatal: early EOF
fatal: fetch-pack: invalid index-pack output
```

1. 方案1

   增加缓存，单位是b

   `git config --global http.postBuffer 524288000`

2. 方案2

   修改下载速度和时间限制

   `git config --global http.postBuffer 524288000`

   `git config --global http.lowSpeedTime 999999`

3. 方案3

   尝试浅层clone，然后再深层进行

   `git clone --depth=1 http://xxx.git`

   `git fetch --unshallow`