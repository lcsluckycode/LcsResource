# Java反射机制

反射主要是指程序可以访问、检测和修改它自身状态或行为的一种能力。通过反射可以调用私有方法和私有属性。

反射机制主要提供的功能：

- 在运行时判断任意一个对象所属的类；
- 在运行时构造任意一个类的对象；
- 在运行是判断任意一个类所具有的成员变量和方法；
- 在运行时调用任意一个对象的方法；
- 生成动态代理。

java反射机制包含的类：

> java.lang.Class
>
> java.lang.reflect.Constructor;
>
> java.lang.reflect.Field;
>
> java.lang.reflect.Method;
>
> java.lang.reflect.Modifier;