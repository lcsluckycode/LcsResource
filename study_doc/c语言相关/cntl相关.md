# fcntl函数相关
## fcntl
根据文件的描述词来操作文件的特征
`#include<unistd.h>`
`#include<fcntl.h>`
函数原型
```
int fcntl(int fd, int cmd);
int fcntl(int fd, int cmd, long arg);
int fcntl(int fd, int cmd, struct flock *lock);
```
功能描述：fcntl真滴文件描述符提供控制。参数fd是被参数cmd操作的描述符。针对cmd的值，fcntl能够接受第三个参数。
五种功能：
-  复制一个现有的描述符，F_DUPFD
-  获得/设置文件描述符标记，F_GETFL或F_SETFD
-  获得/设置文件状态标记，F_GETFL或F_SETFL
-  获得/设置异步I/O所有权，F_GETOWN或F_SETOWN
-  获得/设置记录锁，F_GETLK，F_SETLK或F_SETLKW

fcntl的返回值：与命令有关。如果出错，所有的命令返回-1，如果成功则返回某个其他值。下列三个命令特有返回值：F_DUPFD,F_GETFD,F_GETFL以及F_GETOWN。第一个返回新的文件描述符，第二个返回相应标志，最后一个返回一个正的进程ID或负的进程组ID。