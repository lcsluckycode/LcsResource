# Socket 非阻塞模式

阻塞、非阻塞、异步

**阻塞** ：阻塞调用是指调用结果未返回之前，当前的线程会被挂起。该线程会被标记为睡眠状态并被调度出去。函数只有在得到结果之后才会返回。当socket工作模式在阻塞模式的时候，如果没有数据，当前线程会被挂起

**非阻塞** ：非阻塞与阻塞相对应，在不能立刻得到结果的时候，先返回，

三种操作IO方式

- blocking IO ：发起IO操作后阻塞直到IO结束，标准的同步IO，如默认行为的posix write 和 read
- non-blocking IO ：发起IO操作后不阻塞，用户可阻塞等待多个IO操作同时结束。non-blocking也是一种同步IO：“批量同步”。如linux下的poll，select，epoll
- asynchronous IO ：发起IO操作不阻塞，用户得传递一个回调函数等待IO结束后被调用。

## 非阻塞Socket

正常情况下，socket工作在阻塞模式下，在调用accept，connect，read，write等函数的时候，都是阻塞方式。

**设置非阻塞socket的方法**

```c
int SetNonBlock(int iSock)
{
    int iFlags;
 
    iFlags = fcntl(iSock, F_GETFL, 0);
    iFlags |= O_NONBLOCK;
    iFlags |= O_NDELAY;
    int ret = fcntl(iSock, F_SETFL, iFlags);
    return ret;
}
```

## 非阻塞accept

tcp的socket一旦通过listen（）设置为server后，就只能通过accept（）函数，被动的接受来自客户端的connect请求。进程对accept都是阻塞的。

`int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen);`

非阻塞模式下调用accept函数，如果没有新连接，将会直接返回EWOULDBLOCK（11）错误。

## 非阻塞connect

非阻塞工作模式下，调用connect函数会立刻返回EINPOCESS错误，但TCP通信的三次握手过程正在进行，可以使用select函数检查这个链接是否成功

处理非阻塞connect的步骤

- 创建socket设置为非阻塞模式
- 调用connect函数，如果返回0表示连接建立，如果返回-1，检查errno，若值为EINPOCESS，则表示连接正在建立
- 为了控制连接建立的时间，将该socket文件描述符加入select的可写集合中，采用select函数设定超时
- 如果规定时间内成功建立连接，描述符变为可写

example

```C++
int RouterNode::Connect()
{
	sockaddr_in servaddr = {0};
    servaddr.sin_family = AF_INET;
    inet_pton(AF_INET, ip_.c_str(), &servaddr.sin_addr);
    servaddr.sin_port = htons(port_);
 
	int ret = ::connect(fd_, (struct sockaddr *)&servaddr, sizeof(servaddr));
	
	if(ret == 0)
	{
		is_connected_ = true;
		return 0;
	}
	
	int error = 0;
	socklen_t len = sizeof (error);
	
	if(errno != EINPROGRESS)
	{
		goto __fail;
	}
	
	fd_set wset;//写集合
	FD_ZERO(&wset);
	FD_SET(fd_, &wset);
 
	struct timeval tval;
	tval.tv_sec = 3;//3s
	tval.tv_usec = 0; 
 
	if (select(fd_ + 1, NULL, &wset, NULL, &tval) == -1) //出错、超时，连接失败
	{
		goto __fail; 
	}
	
	if(!FD_ISSET(fd_, &wset))//不可写
	{
		goto __fail;
	}
 
	if (getsockopt(fd_, SOL_SOCKET, SO_ERROR, &error, &len) == -1)
	{
		goto __fail;
	}
 
	if(error)
	{
		goto __fail;
	}
	
	is_connected_ = true;
	return 0;
 
__fail:
	close(fd_);
	return -1;
}
```

## 非阻塞write

对于写操作write,非阻塞socket在发送缓冲区没有空间时会直接返回-1，错误号EWOULDBLOCK或EAGAIN,表示没有空间可写数据，如果错误号是别的值，则表明发送失败。

如果发送缓冲区中有足够空间或者是不足以拷贝所有待发送数据的空间的话，则拷贝前面N个能够容纳的数据，返回实际拷贝的字节数。

而对于阻塞Socket而言，如果发送缓冲区没有空间或者空间不足的话，write操作会直接阻塞住，如果有足够空间，则拷贝所有数据到发送缓冲区，然后返回。

## 非阻塞read

对于阻塞的socket,当socket的接收缓冲区中没有数据时，read调用会一直阻塞住，直到有数据到来才返回。
当socket缓冲区中的数据量小于期望读取的数据量时，返回实际读取的字节数。

当sockt的接收缓冲区中的数据大于期望读取的字节数时，读取期望读取的字节数，返回实际读取的长度。

对于非阻塞socket而言，socket的接收缓冲区中有没有数据，read调用都会立刻返回。

接收缓冲区中有数据时，与阻塞socket有数据的情况是一样的，如果接收缓冲区中没有数据，则返回-1，错误号为EWOULDBLOCK或EAGAIN,表示该操作本来应该阻塞的，但是由于本socket为非阻塞的socket，因此立刻返回，遇到这样的情况，可以在下次接着去尝试读取。如果返回值是其它负值，则表明读取错误。