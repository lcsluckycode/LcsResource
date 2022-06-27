# c++ 基础

## 1. 四种类型转换

1. `static_cast`

   - 基本类型转换

   ```c++
   int i = 1;
   double j = static_cast<double> (i);
   ```

   - 父类和子类的指针转换。 如果父类指针指向一个对象，此时将父类指针转换为子类指针是不安全的，子类指针转换为父类指针是安全的

   ```c++
   class Base() {};
   class Child() : public Base {};
   
   Base *b = new Base();
   Child *c = new Child();
   
   Child *p1 = static_cast<Child*> (b); //不安全
   Base *p2 = static_cast<Base*> (c); //安全
   ```

   - 将任何类型转换为 void 类型。

   ```c++
   void *p = static_cast<void*> (c);
   ```

   static_cast 不能去除类型的 const 或者 volatile 属性； 不能进行无关类型转换 （如非基类和子类）

2. `dynamic_cast`

   只能用于对象指针之间的转换，转换结果亦可以时引用。在类层次间进行转换时， dynamic_cast 和 static_cast 的效果一致；在进行下行转换的时候，dynamic_cast具有类型检测功能，比 static_cast 更安全

   ```c++
   class Base() {};
   class Child() : public Base {};
   
   Base *b = new Base();
   Child *c = new Child();
   
   Child *p1 = dynamic_cast<Child*> (b); //转换失败，返回 NULL
   Child *p2 = dynamic_cast<Child*> (c); //转换成功
   
   Child *p1 = dynamic_cast<Child&> (b); //转换失败，抛出异常
   Child *p2 = dynamic_cast<Child&> (c); //转换成功
   ```

   父子类指针转换时，该父类种必须包含一个虚函数

3. `const_cast`

   用于取出 const 属性，去掉类型的 const 或者 volatile 属性，将 const 类型的指针变为非 const 类型的指针。

   ```c++
   const int *fun(int x, int y) { return 3};
   
   int *ptr = const_cast<int *> (dun(2, 3));
   ```

4. `reinterpret_cast`

   只是重新解释类型，没有二进制的转换：

   - 转换的类型必须是一个指针、引用、算术类型、函数指针或者成员指针。
   - 一般用在函数指针类型之间进行转换。
   - 不能保证可移植性

## 2. 异常处理

处理关键字 ：**try、catch、throw**。 任何需要检测异常的语句，都必须在 try 语句块中执行，异常必须由紧跟着 try 语句后面的 catch 语句来捕获并处理，因此 try 与 catch 总是集合使用。

语法：

```c++
#include <exception>
using namespace std;

// 抛出异常
throw [表达式];

// 捕获异常
try {
	// try语句块
} catch(type e) {
	// 异常处理语句
}
```

### 2.1 <a id="异常类型">异常类型</a>

- 基本类型： int、char、float等
- 聚合类型：指针、数组、字符串、结构体、对象

c++ 语言本身以及标准库中的函数抛出的异常，都是 exception 类或者其子类的异常。抛出异常的时候会创建一个 exception 类或其子类的对象

```c++
try {
	// try语句块
} catch(exception &e) {
	// 异常处理语句
}
```

### 2.2 throw

throw 关键字表示抛出异常，当程序执行到这个关键字的位置，会立即返回，知道找到 try 的位置，并匹配与之对应类型的 catch 

throw [[2.1异常类型](#异常类型)]

```c++
#include<iostream>
#include<exception>
using namespace std;

int fun() {
    throw 9;
    cout << "There is in fun()" << endl;
}

int main() {
	try {
        fun();
        cout << "There is in try { }" << endl;
    } catch (int e) {
        cout << "Throw int " << e << endl;
        cout << "There is in catch { }" << endl;
    } cache (char e) {
        cout << "Throw char " << e << endl;
        cout << "There is in catch { }" << endl;
    }
    return 0;
}
```

输出如下：

```bash
Throw int 9
There is in catch { }
```

```c++
#include<iostream>
#include<exception>
using namespace std;

int fun() {
    throw 'a';
    cout << "There is in fun()" << endl;
}

int main() {
	try {
        fun();
        cout << "There is in try { }" << endl;
    } catch (int e) {
        cout << "Throw int " << e << endl;
        cout << "There is in catch { }" << endl;
    } catch (char e) {
        cout << "Throw char " << e << endl;
        cout << "There is in catch { }" << endl;
    }
    return 0;
}
```

输出如下：

```bash
Throw char a
There is in catch { }
```

由上面两个例子可以看出。try 捕获的异常实际是 throw 抛出的异常，throw 抛出的异常类型会在catch中自动适配，选择对应类型的位置进行执行。

同时，throw 抛出异常的时候，程序并不会继续执行下去，`cout << "There is in fun()" << endl;`，没有执行，当 try 中执行的语句出现异常时，也会以及交由catch处理，也不会继续执行（`cout << "There is in try { }" << endl;`）没有执行。

### 2.3 exception类

C++标准异常的基类，位于 \<exception\> 头文件中。

继承层次如下：

![C++ exception类层次图](E:\lcsprogram\study_doc\C++\images\exception类继承图谱.jpg)

异常处理基类

```c++
class exception{
public:
    exception () throw();  //构造函数
    exception (const exception&) throw();  //拷贝构造函数
    exception& operator= (const exception&) throw();  //运算符重载
    virtual ~exception() throw();  //虚析构函数
    virtual const char* what() const throw();  //虚函数
}
```

## 参考：

[C++中的4种类型转换](https://blog.csdn.net/weixin_42482896/article/details/88939439)

[c++异常处理](http://c.biancheng.net/view/2330.html)