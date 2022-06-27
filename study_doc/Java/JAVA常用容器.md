# JAVA多线程

[转载摘抄](https://www.cnblogs.com/13roky/p/14707360.html)

Java语言允许程序运行多个线程，多线程可以通过Java中的java.lang.Thread类实现

Thread类的特性

- 每个线程都是通过特定的Thread对象的run()方法完成操作, 把 run() 方法的主体称为线程体
- 通过Thread方法的 **start() 方法来启动这个线程**,而非直接调用 run() 

# 1. 线程的创建与启动

## 1.1 继承Thread类

1. 创建一个继承于Thread类的子类
2. 重写Thread类的run()方法
3. 创建Thread类子类的对象
4. 通过此对象调用start()启动线程

```java
package learn.thread;

public class ThreadTest extends Thread{
    @Override
    public void run() {
        System.out.println("Thread test running.");
        for (int i = 0; i < 10; i++) {
            System.out.println(Thread.currentThread().getName()+":\t"+i);
        }
    }

    public static void main(String[] args) {
        Thread thread1 = new ThreadTest();
        thread1.start();

        Thread thread2 = new ThreadTest();
        thread2.start();

        new ThreadTest().start(); 
    }
}
```

**创建Thread匿名子类**

```java
package learn.thread;

public class ThreadNoknowTest {
    public static void main(String[] args) {
        new Thread() {
            @Override
            public void run() {
                System.out.println("Thread " +Thread.currentThread().getName()+ " is running");
            }
        }.start();
    }
}
/* Thread Thread-0 is running */
```

## 1.2 实现Runnable接口

1. 创建一个实现Runnable接口的类
2. 实现类去实现Runnable接口中的抽象方法run()
3. 创建实现类的对象
4. 将此对象作为参数传到Thread类的构造器中, 创建Thread类对象
5. 通过Thread类的对象调用start()方法

```java
package learn.thread;

public class ThreadRunnableTest{
    public static void main(String[] args) {
        ThreadRunnable threadRunnable = new ThreadRunnable();
        Thread thread1 = new Thread(threadRunnable);
        thread1.start();

        Thread thread2 = new Thread(threadRunnable);
        thread2.start();
    }
}

class ThreadRunnable implements Runnable {

    @Override
    public void run() {
        System.out.println("Thread " + Thread.currentThread().getName() + " is running.");
    }
}
/* Thread Thread-1 is running.
Thread Thread-0 is running. */
```

**上述两种方式的异同**

- Java中只允许单继承但是可以实现多接口，当一个类已经继承了某一个父类，就不能采用继承Thread类的方式试下线程，而可以通过实现Runnable接口完成多线程
- 实现Runnable接口的方式天然具有数据共享的特性（不用static变量）。因为继承Thread的实现方式，需要创建多个子类的对象进行多线程，如果子类中由变量A，而不采用static约束变量，每个子类的对象都有自己独立的变量A。而是先Runnable接口的方式，只需要创建一个实现类对象，将这个对象传入Thread类并创建多个线程，这个多线程实际就调用了一个实现类对象而已。
- Thread类中也是实现了Runnable接口
- 相同点两种方式都需要重写run()方法，线程的执行逻辑都在run()方法中

## 1.3 实现Callable接口

**与Runnable相比，Callable更强大**

1. 相比run()方法，可有返回值
2. 方法可抛出异常
3. 支持泛型的返回值
4. 需要借助FutureTask类，比如获取返回结果

```java
package learn.thread;

import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.FutureTask;

public class ThreadCallableTest {
    public static void main(String[] args) {
        // 创建Callable接口实现类对象
        ThreadCallable threadCallable = new ThreadCallable();

        // 将Callable实现类对象作为FutureTask参数, 构造FutureTask对象
        FutureTask<Integer> futureTask = new FutureTask<>(threadCallable);

        // 将FutureTask对象作为Thread类的对象参数,钩爪Thread对象并调用start()方法
        new Thread(futureTask).start();

        try {
            // 获取Callable中Call返回的值
            Integer sum = futureTask.get();
            System.out.println("Sum: " + sum);
        } catch (ExecutionException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}

class ThreadCallable implements Callable<Integer> {
    @Override
    public Integer call() throws Exception {
        int sum = 0;
        for (int i = 0; i < 100; i++) {
            sum += i;
        }
        return sum;
    }
}
/* sum: 4950 */
// beacuse just 1 + ... + 99
```

## 1.4 线程池创建

提前准备号线程池，使用时直接获取，用完后将其放回池中

1. 创建指定线程数的线程池
2. 执行指定的线程操作。需要提供实现Runnable接口或者Callable接口实现类的对象

```java
package learn.thread;

import javax.swing.plaf.TableHeaderUI;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.ThreadPoolExecutor;

public class ThreadPool {
    public static void main(String[] args) {
        // 1.提供指定线程数量的线程池
        ExecutorService service = Executors.newFixedThreadPool(10);
        ThreadPoolExecutor service1 = (ThreadPoolExecutor) service;
		
        // 2.执行指定的线程的操作。需要提供实现Runnable接口或Callable接口实现类的对象。
        service.execute(new ThreadN()); // 适用于实现Runnable接口的对象
        // service.submit(new ThreadCallable); // 适用于实现Callable接口的对象

        // 关闭线程池
        service.shutdown();
    }
}

class ThreadN implements Runnable {

    @Override
    public void run() {
        for (int i = 0; i < 10; i++) {
            System.out.println(Thread.currentThread().getName() + ":\t" + i);
        }
    }
}

/* 执行2步骤时,在线程池内选择一个合适的线程执行该操作 */
```

# 2. 线程的常用方法

- `start()` 启动当前线程，调用当前的run方法
- `run()`通常需要重写Thread类中的此方法，将创建的线程要执行的操作在此声明
- `currentThread()`**静态方法**，返回当前执行的线程
- `getName()`获取当前线程的名字
- `setName()`设置当前线程的名字
- `yield()`释放当前CPU的执行权
- `join()`在线程a中调用线程b的join，此时线程a进入阻塞状态，知道线程b执行完后，线程a才结束阻塞状态
- `stop()`已过时，当执行此方法时，强制结束当前的线程
- `sleet(long militime)`线程睡眠指定的毫秒数
- `isAlive()`判断当前线程是否存活

### 3. 线程的生命周期

在Java中通常

1. 新建：当一个Thread类或其子类的对象被声明创建时，信的线程处于新建状态
2. 就绪：处于新建的状态的线程被start后，将进入线程队列等待CPU时间片，此时具备运行的条件，但是还没分配资源
3. 运行：当就绪的线程被调用并获得CPU资源时，便进入运行状态，run方法定义的线程操作被执行
4. 阻塞：在某种特殊情况下，被认为挂起或执行输入输出操作时，让出CPU并临时中止自己的执行，进入阻塞状态
5. 死亡：线程完成了全部工作或线程被提前强制性中止或踹下你异常导致结束

![线程生命周期流程图](E:\lcsprogram\study_doc\设计模式\image\线程生命周期流程图.png)

# 4. 多线程安全性问题



# 5. 线程的通讯