# C++关键字用法说明

# 1. const

常类型修饰符

## 1.1 作用

- 定义常量

- 类型检查

  - const常量与 `#define` 宏定义常量的区别：

    > const常量具有类型，编译器可以进行安全检查； #define宏定义没有数据类型，只是简单的字符串替换，不进行安全检查

  - const定义的变量只有类型为整数或枚举，且常量表达式初始化时才能作为常量表达式
  - 其他情况下只是const限定的变量，不是常量。

- 防止修改
- 节省空间
  - const定义的常量从汇编的角度来看，只是给出了对应的内存地址，而不是向 `#define` 一样给出的立即数
  - const定义的常量在程序运行过程中只有一份拷贝，而 `#define` 定义的常量在内存中有若干拷贝

## 1.2 const对象默认为文件局部变量

非const变量默认为extern。要使const变量能够在其他文件夹访问，必须在文件中显式地指定为extern。

- 未被const修饰的变量在不同文件的访问

  ```c++
  // file1
  int ext;
  
  //file2
  #include<iostream>
  
  extern int ext;
  int main() {
  	std::cout<<(ext+10)<<std::endl;
  }
  ```

- const常量在不同文件的访问

  ```c++
  // file1
  extern const int ext = 12;
  
  // file2
  #include<iostream>
  extern const int ext;
  int main() {
      std::cout << ext << std::endl;
  }
  ```

## 1.3 指针与const

**const位于 * 左侧，则表示const修饰指针所指向的变量**，指针指向的值不能修改

**const位于 * 右侧，则表示const修饰指针本身**，指针指向的方向不能修改

1. 指向常量的指针

   ```c++
   const int *ptr;
   *ptr = 10;  // error
   
   // 不能用void*指针保存const对象的地址，必须使用const void*
   const int val = 10;
   const void *vp = &val;  //true
   void *vp = &val;  //error
   ```

   **运行把非const对象的地址赋值给指向const对象的指针**

2. 常指针

   const指针必须初始化

   ```c++
   #include<iostream>
   using namespace std;
   int main(){
   
       int num=0;
       int * const ptr=&num; //const指针必须初始化！且const指针的值不能修改
       int * t = &num;
       *t = 1;
       cout<<*ptr<<endl;
   }
   ```

   不能直接指向常量

   ```c++
   const int val = 10；
   int * const ptr = &val;  //error! const int* -> int *
   ```

3. 指向常量的常指针

   ```c++
   const int val = 10;
   const int* const ptr = &val;  //true
   ```

## 1.4 函数与const

### 1.4.1 const修饰函数返回值

表示返回值的类型与const定义的变量性质一致

### 1.4.2 const修饰函数参数

- 传递的参数不可变

  ```c++
  void func(const int var); // 传递过来的参数不可变
  void func(int *const var); // 指针本身不可变
  ```

- 参数指针指向的内存不可变

  ```c++
  void func(char *dst, const char *src);
  ```

  函数体不能改变原来src的内容。

- 参数为引用，为了提高效率同时防止修改

  ```c++
  void func(const A &a);
  ```

  对于非内部数据类型的参数而言，象void func(A a) 这样声明的函数注定效率比较低。因为函数体内将产生A 类型的临时对象用于复制参数a，而临时对象的构造、复制、析构过程都将消耗时间。

## 1.5 类与const

使用const关键字修饰的成员函数称为常成员函数。只有常成员函数才有资格操作 **常量或常对象** ，没有关键字const进行说明的成员函数不能用来操作**常对象**。

对于类中的const成员变量必须通过初始化参数列表进行初始化

```c++
class Apple{
private:
    int people[100];
public:
    Apple(int i); 
    const int apple_number;
};

Apple::Apple(int i):apple_number(i)
{

}
```

const对象只能访问const成员函数，而非const对象可以访问任意的成员函数，包括const成员函数。

```c++
//apple.cpp
class Apple
{
private:
    int people[100];
public:
    Apple(int i); 
    const int apple_number;
    void take(int num) const;
    void add(int num);
	void add(int num) const;
    int getCount() const;

};
//main.cpp
#include<iostream>
#include"apple.cpp"
using namespace std;

Apple::Apple(int i):apple_number(i)
{

}
void Apple::add(int num){
    take(num);
}
void Apple::add(int num) const{
    cout << "const add" << endl;
    take(num);
}
void Apple::take(int num) const
{
    cout<<"take func "<<num<<endl;
}
int Apple::getCount() const
{
    take(1);
//    add(); //error
    return apple_number;
}
int main(){
    Apple a(2);
    cout<<a.getCount()<<endl;
    a.add(10);
    const Apple b(3);
    b.add(100);
    return 0;
}

// take func 1
// 2
// take func 10
// const add
// take func 100

```

# 2. static

当与不同类型一起使用的时候，static关键字具有不同的含义。

**静态变量**：函数中的变量，类的变量

**静态类的成员**：类对象和类中的函数

## 2.1 静态变量

- 函数中的静态变量

  当变量声明为static时，空间 **将在程序的生命周期内分配** 。即使多次调用该函数，静态变量的空间也是 **只分配一次** ，前一次调用的变量通过下一次函数调用传递。

  ```cpp
  #include <iostream>
  #include <string>
  using namespace std;
  
  void demo() {
      static int count = 0;
      cout << count << " ";
  
      count++;
  }
  
  int main() {
      int count = 100;
      cout << count << endl;
      for (int i = 0; i < 5; i++) {
          demo();
      }
      return 0;
  }
  //100
  //0 1 2 3 4
  ```

- 类中的静态变量

  声明的静态变量只被**初始化一次**，在单独的**静态存储空间**中分配空间。静态变量**不能使用构造函数初始化**。

  ```cpp
  class Test {
  public:
      static int val;
      Test () {}
  };
  
  int Test::val = 0;  // 必须要初始化
  
  int main() {
      Test test1;
      Test test2;
      test1.val = 1;
      test2.val = 2;
      cout << test1.val << " " << test2.val << endl;
      return 0;
  }
  
  // 2 2
  ```

## 2.2 静态成员

- 类对象为静态

  就像变量一样，对象也
