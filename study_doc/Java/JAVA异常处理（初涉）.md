# JAVA异常处理（初涉）

Java程序经常会出现两种问题，一种是 `java.lang.Exception` 和 `java.lang.Error`，这两者可以说是java的两种分支 `错误（errors）` 和 `异常（exceptions）`  （两者继承于 `Throwable` 这一父类），

对于`Exception`，又可以分为 `RuntimeException` 和 `CheckedException` 。

![image-20220124172900663](E:\lcsprogram\study_doc\Java\images\throws.png)

- `Error`：是程序中无法处理的错误，此类错误一般表示代码运行时在JVM出现的问题。
- `Exception`：程序本身可以捕获的异常。
  - `RuntimeException`：运行时可能会出现的错误，编译器在编译的时候不会检查该错误，也不要求处理改错误，错误本身可以被捕获。
  - `CheckedException`：编译器在编译的时候会检查该错误，必须对此类错误进行处理。

# 常见的Exception

**RuntimeException**

| 序号 | 异常名称                       | 异常描述     |
| :--: | ------------------------------ | ------------ |
|  1   | ArrayIndexOutOfBoundsException | 数组越界异常 |
|  2   | NullPointerException           | 空指针异常   |
|  3   | IllegalArgumentException       | 非法参数异常 |
|  4   | NegativeArraySizeException     | 数组长度异常 |
|  5   | IllegalStateException          | 非法状态异常 |
|  6   | ClassCastException             | 类型转换异常 |

**CheckedException**

| 序号 | 异常名称               | 异常描述                     |
| ---- | ---------------------- | ---------------------------- |
| 1    | NoSuchFiledException   | 表示该类没有指定名称抛出异常 |
| 2    | NoSuchMethodException  | 表示该类没有指定方法抛出异常 |
| 3    | IllegalAccessException | 不允许访问某个类             |
| 4    | ClassNotFoundException | 类没有找到抛出异常           |

# 异常处理机制

异常情形（exception condition）：指阻止当前方法或作用域继续执行的问题。

**抛出异常**和**捕获异常**

- **抛出异常**，当遇到异常时，程序已经无法执行下去了，因为在当前环境已经五福获得必要的信息来解决问题，所以必须要从当前的环境跳出来，把问题交给上一级环境进行处理，这就是抛出异常。异常抛出后，会触发以下时间：
  - 堆上会被 `new` 创建一个异常对象
  - 当前的执行路径被终止，并且从当前环境中弹出对异常的引用
  - 异常处理机制接管程序，并开始寻找一个恰当的地方（异常处理程序或者异常处理器）继续执行程序
  - 异常处理程序或者异常处理器将程序从错误状态中恢复，使程序要么换一种方式运行或者继续运行
- **捕获异常**，在方法抛出异常之后，运行时系统将转为寻找合适的异常处理器。潜在的异常处理器是异常发生时依次存留在调用栈中的方法集合。当异常处理器能处理的异常类型与方法抛出的异常类型相符合时，成为合适的异常处理器。运行时系统性发生异常的方法开始，依次回查调用栈中的方法，直至找到合适异常处理器的方法并执行。当运行时系统遍历调用栈没有找到合适的异常处理器，则程序终止。

## throws 和 throw

异常也是一个对象，能够被自定义抛出或者应用程序抛出，但是必须借助 `throws` 和 `throw` 语句定义抛出异常。

throws和throw通常是成对出现的

```java
class Cat extends Animal {
    @Override
    public void talk() {
        System.out.println("Cat talk");
    }

    public void testException() throws Exception {
        System.out.println("Throws Exceptions");
        throw new Exception();
    }
}

public class Test {
    public static void main(String[] args) {
        Cat cat = new Cat();
        try {
            cat.testException();
        }catch (Exception e) {
            System.out.println(e); 
        }
        System.out.println("Out of the throws");
    }
}
//Throws Exceptions
//java.lang.Exception  //catched
//Out of the throws
```

throw 语句再方法体内，表示抛出异常，由方法体内处理。throws语句用在方法声明后面，表示再抛出异常，由该方法调用者来处理。

throws 主要是声明这个方法会抛出这种类型的异常，使它的调用者知道要捕获这个异常。throw是具体向外抛出异常的动作，所以它抛出的是一个异常实例。

上述实例可以看出，通过thow抛出的异常可以在上层调用的时候被捕获，假如产生干扰程序正常运行的错误或异常，程序不会退出，会正常执行。

## try、catch 和 finally

这三种关键字有几种不同的组合方式 `try...catch`、`try...finally`、`try...catch...finally`。

try...catch表示对某一段代码可能抛出异常进行捕获

```java
static void cacheException() throws Exception {
    try {
        System.out.println("test");
    }catch (Exception e){
        e.printStackTrace();
    }
}
```

try...finally表示对一段代码不管执行情况如何，都会走finally中的代码

```java
static void cacheException() throws Exception {
    for (int i = 0; i < 3; i++) {
        System.out.println("enter: i = " + i);
        try {
            System.out.println("execute: i = " + i);
            continue;
        }finally {
            System.out.println("leave: i = "+i);
        }
    }
}

// enter: i = 0
// execute: i = 0
// leave: i = 0
// enter: i = 1
// execute: i = 1
// leave: i = 1
// enter: i = 2
// execute: i = 2
// leave: i = 2
```

从上面的代码可以看到，虽然在try里面执行了 `continue`，但是并没有直接进行下一次循环，而是执行了 finally里面的代码才进行下一次循环。假如在外面添加其他代码，IDEA提示报错，语句不可达。如下图。

![image-20220125092912171](E:\lcsprogram\study_doc\Java\images\finally.png)

# 自定义异常类

步骤：

1. 继承现有的异常结构：`RuntimeException`（不用处理）、`Exception`（需要处理）
2. 提供重载的构造器

```java
class MyException extends RuntimeException{
    private final long serialVersionUID = -1234719074324978L;

    public MyException(){

    }

    public MyException(String message){
        super(message);
    }
}

public class Test {
    public static void main(String[] args) {
        throw new MyException("MyException of RuntimeException");
    }
}

/* Exception in thread "main" com.test.MyException: MyException of RuntimeException
	at com.test.Test.main(Test.java:5) */
```

全局常量：`serialVersionUID`（用于在序列化和反序列化过程中进行核验的一个版本号）