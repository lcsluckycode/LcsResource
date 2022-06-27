# C语言常用（易错）扩展

## 字符串操作

```c
//字符串复制，n表示限制长度
strncpy(a,b,5)
a[5]='\0'

//String len
strlen(a)  // length didn'n include '\0' 

//String compare
strcmp(str1,str2)
strncmp(str1,str2,n)  // compare the pre n lengths

//在使用追加，复制等操作时，注意需要对src目标分配内存空间，同时注意操作是否导致越界
//追加
strcat(str1,str2)  //注意溢出
strncat(str1,str2,n)  // n表示把str2前n个追加给str1，但是末尾不加'\0'

//替换，复制
strcpy(str1,str2) //注意溢出
strncpy(str1,str2,n)   // n表示把str2前n个复制给str1，在最后面加'\0'
    
// memset初始化
char a[10]
memset(a,'#',sizeof(a));
a[10]='\0'
 
//bzone
bzero(a,sizeof(a));  //bzero表示把整一块空间用0填充
```

memset(a,0,sizeof(a));

bzero(a,sizeof(a);

通常情况，两者相同，当文件中包含了两次“string.h”文件的时候，使用memset会报警

##   类型转换 

```c
#整形转化为字符串类型
itoa(int,str,10)  -- 10表示10进制转化，该函数只在windows下有，linux下并没有
sprintf(char *s,const char,...)
ex.  sprint(str,"%d %d",123,456);
str = "123 456";

#字符串转整形
atoi(str) -- 将str转化为int
```

## 内存操作函数

- 内存复制

  - **`memcpy(void* dest,const void* src, size_t num)`**  --内存拷贝，不考虑'\0'

    -- 函数在遇到'\0'不会停止

    -- 如果src与dest有内存空间重叠，则复制结果都是未定义

  - **`memset(str, value, num)`**  --按字节设置，进行赋值

    -- 以str的起始位置开始的前n个字节的内存空间用整数value填充

    -- return str address

    -- memset用来对一段内存空间全部设置为某个字符，一般用在对定义的字符串进行初始化为‘ ’或‘/0’

    -- 如果用malloc分配的内存，一般只能使用memset来初始化

    -- memset可以方便的清空一个结构类型的变量或数组,它可以一字节一字节地把整个数组设置为一个指定的值
  
  - **`memcmp(buf1,buf2,num)`** --比较内存区域buf1和buf2的前num个字节

    -- buf1<buf2 return <0; = return =0 ;> return >0

  - **`memchr(buf,ch,num)`** --从buf指向的内存区域的前num个字节查找字符ch

    --return the first one adress ，if has none， return NULL

  - **`memmove(dest, src, num)`** -- 内存移动，内存空间可重叠

- 静态开辟地址空间
  - 数组定义   -- 开辟的内存是在栈中开辟的固定大小的

- 动态开辟空间  -- 分配失败皆返回NULL，建议使用前对指针判空

  - **`malloc(size)`** 

    -- 向堆空间申请一片连续可用的内存空间

    -- return 指向该空间的地址，需要用户指定该地址存储的数据类型，一般对返回指针进行强制类型转换

  - **`calloc(num,size)`**

    -- 与malloc()函数的区别只在于, calloc()函数会在返回地址之前将所申请的内存空间中的每个字节都初始化为num

  - **`realloc(ptr,size)`** -- 调整ptr指向的内存空间的大小

    -- ptr为需要调整的内存地址

    -- size为调整后需要的大小(字节数)

- 释放内存空间

  - **`free(ptr)`**

    -- 只能用来释放动态开辟的空间，但是并不改变ptr的值，需要用户手动ptr=NULL，否则后续程序依旧可以通过ptr访问之前的空间

    -- 不能重复释放同一块内存空间

### 内存分区

![img](E:\lcsprogram\study_doc\c语言相关\images\内存分区.png)

1. 代码分区

   所有的 **可执行代码（程序代码指令、常量字符串等）** 都加载到代码区（函数都放在代码区）

2. 静态区

   存放 **全局变量和静态变量**

3. 栈区

   存放所有的 **自动变量、函数形参**

4. 堆区

   一般比较复杂的数据类型放在堆中

## 回调函数与函数指针

### 回调函数

**什么是回调函数？**
回调函数就是一种函数指针的用法，当在实现某一个具体模块的时候，并没一个具体的实现接口和使用方法，这个时候就可以将函数的指针作为参数传递进去，当有数据抵达或者使用者使用该模块用于实现自定义功能时，可以将自己写的函数传递进去进而完成具体方法实现。
**回调函数用法**
[借用该博主的博客进行简单演示](https://blog.csdn.net/callmeback/article/details/4242260)

```
#include <stdio.h>

 
void printWelcome(int len)
{
       printf("欢迎欢迎 -- %d/n", len);
}

 
void printGoodbye(int len)
{
       printf("送客送客 -- %d/n", len);
}


void callback(int times, void (* print)(int))
{
       int i;

       for (i = 0; i < times; ++i)
       {
              print(i);
       }
       printf("/n我不知道你是迎客还是送客!/n/n");
}


void main(void)

{
       callback(10, printWelcome);
       callback(10, printGoodbye);
       printWelcome(5);
}
```

就上面的程序来说，你只要函数格式符合cllback第二个参数的格式不论你给别人做饭、铺床叠被都可以正常工作。这就是回调的作用，把回调实现留给别人。
回调机制：***callback函数**为B层，**main函数**和**print\*函数**为A层，A层调用了B层的**回调函数callmeback**，而B层的**回调函数**调用了A层的**实现函数print\****。说白了B层就是一个接口。

### 函数指针

函数指针的本质是一个指针，该指针指向了一个函数，即指向函数的指针。函数的定义是存在于代码段，因此，每个函数在代码段中，也有着自己的入口地址，函数指针就是指向代码段中函数入口地址的指针。
声明形式：
`ret (*pname)(args,...);`
其中，`ret`表示返回值类型，`*pname`作为一个整体，代表指向该函数的指针，`args`表示形参列表（一般是函数传入形参的类型）；`pname`为函数指针变量。

```bash
int (*p)(int,int);  #函数指针定义
int sum(int a,int b); #函数定义
p = sum;   #函数指针引用sum函数
p(a,b);   #函数指针使用
```

## 预定义符号

- `__FILE__ `，进行编译的源文件名
- `__LINE__ `，文件当前的行号
- `__DATE__ `，文件被编译的日期
- `__TIME__ `，文件被编译的时间
- `__STDC__`，如果编译器遵循ANSI C ，值为1，否则未定义

## 其他指令

- `#error `，允许你生成错误的信息。`#error text of error message`
- `#line number "string"` ，通知预处理器number是下一行输入的行号。如果给出了可选部分“string”，预处理器就把它做为当前那的文件名
- `#progma`

## 输入/输出函数

1. perror

2. exit

3. 缓冲流 

   > `printf`函数输出到缓冲区，最好调用 `fflush( stdout )`讲缓冲区数据立即写入

## 运算符优先级

- 任何一个逻辑运算符的优先级低于任何一个关系运算符
- 移位运算符的优先级比算术运算符要低，但是比关系运算符要高

# 结构体

**定义**

`struct tag { member-list } variable-list;`

结构体的自引用必须是指针类型

**错误**：

```c
typedef struct{
    int a;
    SELF_REF3 *b;
}SELF_REF3;  //因为结构体类型名在引用的时候未定义
```

**正确**：

```c
typedef struct SELF_REF3_TAG{
    int a;
    struct SELF_REF3_TAG *b;
}SELF_REF3;  //使用结构体标签来声明，因为标签（tag）在引用前已经声明了
```

## 位段用法

位段的声明和结构类似，但它的成员是一个或多个位的字段。这些不同的字段实际存储于一个或者多个整型变量中。首先声明为int、signed int、unsigned int。其次，在成员名后面是一个冒号和一个整数，这个整数指定该位段所占的位的数目。

**注意**：用signed或unsigned整数显示地声明位段是一个好主意。如果把位段声明为int类型，解析具体的情形由编译器决定。注意在可移植性的程序应该避免使用位段。

![image-20211224134017995](images\位段用法.png)

在许多16整数机器的编译会报错。因为最后一个参数的长度超过了一个整型的长度

# 注意事项

1. **空间释放**

   c语言与JAVA等高级语言不同，并不存在内存回收机制，当我们对某一空间的利用价值榨干的时候，需要考虑是否需要释放该空间。

2. **返回空间**

   当一个函数返回值为一个指针类型的时候，需要考虑返回的指针**指向对象的空间**是否为`NULL`，或者是否为**公共空间**

   ```c
   //localtime and localtime_r
   struct tm *localtime(const time_t *timep);
   struct tm *localtime_r(const time_t *timep, struct tm *result);
   
   time_t old_time,new_time;
   struct tm* old_time_lo,new_time_lo,old_time_lo_r,new_time_lo_r;
   memset(old_time_lo_r,0,sizeof(struct tm));
   memset(new_time_lo_r,0,sizeof(struct tm));
   
   old_time = gettimeofday();
   old_time_lo = localtime(&old_time);
   old_time_lo_r = localtime_r(&old_time,old_time_lo_r);
   selep(10);
   new_time = gettimeofday();
   new_time_lo = localtime(&new_time);
   new_time_lo_r = localtime_r(&new_time,new_time_lo_r);
   
   //there is the funny thing
   //old_time_lo == new_time_lo is true
   //old_time_lo_r != new_time_lo_r is true
   ```

3. **extern**

   extern 的使用，通常情况下尽量避免使用extern，因为extern传递的时候不会检查参数的数量，当模块进行变化的时候，不易发现问题。通常使用头文件传递的形式，使用extern的时候一般是依赖链过长或者常用模块函数且基本不会更改。
   
4. **`int* f,g;`**

   虽然*与f中间有一个空格，但是当前语句还是生命力一个指向整数的指针 `*f`和一个整型变量 `g`

5. `int (*f[])();`

   函数指针数组，其中元素指向的函数返回值是一个整型

6. `int *(*f[])();`

   函数指针数组，其中元素指向的函数返回值是一个整型指针
   
7. `main(int argc,char* argv)` 

   ![image-20211227093418351](E:\lcsprogram\study_doc\c语言相关\images\命令行参数.png)

8. 字符串常量是指一个指针。el：`"xyz"+ 2`表示的是字符 `y`

# 提高运行效率的方法

1. 少用或者不用动态内存分配

2. 改进调用多的函数，适当使用register声明

   > register关键之字是将C程序中最常用的变量放进寄存器中
   >
   > - 如果对寄存器变量使用取值运算符，则编译器可能会给出错误或警告（取决于您使用的编译器），因为当我们说变量是寄存器时，它可能存储在寄存器中而不是内存中，并且寄存器的访问地址无效
   > - register关键字可以与指针变量一起使用。必须是一个单个变量值，并且长度小于或等于整型长度
   > - 寄存器只能在一个块内使用（局部），而不能在全局范围内（在主外部）使用。

3. 寻找合适的算法

4. 对单个函数用汇编重新编译
