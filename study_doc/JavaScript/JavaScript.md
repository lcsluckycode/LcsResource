# JavaScript

## 显示数据

- `windows.alert()`弹出警告框
- `document.write()`将内容写到HTML文档中
  - `document.getElementById("demo").innerHTML = "段落已修改";` 替换id为demo的文本内容。
- `innerHTML`写入HTML元素
- `console.log()`写入浏览器控制台

## 语法

- 数字，可以是小数证书或者科学计数法

- 字符串，用`''` 或者`""`引用

- 数组，直接`[40,100,10]` ，也可以采用 `new Array();`声明，或者采用`var cars=new Array("Saab","Volvo","BMW");`给初始值
- 对象`{firstName:"John", lastName:"Doe"}`，寻址方式`persion.name;` `persion['name'];`，数组长度`array.length`
- 函数`function myFuction(a,b){ return a+b; }`
- 变量定义`var`关键字修饰， 

在文本字符串中可以使用 `\` 换行

对象可以声明函数，数据采用`this`关键字引用

```javascript
var person = {
    firstName: "John",
    lastName : "Doe",
    id : 5566,
    fullName : function() 
	{
       return this.firstName + " " + this.lastName;
    }
};
//调用
persion.fullName();
```

## 语句

__if__ ，__swich__ , __for__ , __while__ 与C一致

__constructor__ 属性，返回所有javascript的构造函数

__正则表达式__ 采用`/正则表达式主体/修饰符（可选）`

# WebSocket

WebSocket是html5提供的一种在单个TCP连接上进行双向通信的协议，解决了客户端和服务端之间的实时通信问题。浏览器和服务器只需完成一次握手，两者之间就可以创建一个持久性的TCP连接，此后服务器和客户端通过此TCP连接进行双向实时通信。

**属性**：

- `Socket.readyState` ，只读属性，表示连接状态
  - 0 - 表示尚未建立连接
  - 1 - 表示已经建立连接，可以进行通讯
  - 2 - 表示连接正在关闭
  - 3 - 表示连接已经关闭或者连接不能打开
- `Socket.bufferedAmount `， 只读属性，在等待传输但是还没有发送的UTF-8文本字节数

## WebSocket Server and Client

- `Server`

  ```js
  const WebSocket = require('ws');
  
  const wss = new WebSocket.Server({
      port:xxxx
  });
  ```

- `Client`

  ```js
  const ws = new WebSocket('ws://localhost:xxxx');
  ```

## WebSocket方法

- `Socket.send()` 传输数据
- `Socket.close()` 关闭连接

## web Socket事件

- `Socket.onopen()`
- `Socket.onmessage()`
- `Socket.onclose()`
- `Socket.onerror()`

**example:**

```js
var ws = new WebSocket("ws://localhost:8080"); 
//申请一个WebSocket对象，参数是服务端地址，同http协议使用http://开头一样，WebSocket协议的url使用ws://开头，另外安全的WebSocket协议使用wss://开头
ws.onopen = function(){
　　//当WebSocket创建成功时，触发onopen事件
   console.log("open");
　　ws.send("hello"); //将消息发送到服务端
}
ws.onmessage = function(e){
　　//当客户端收到服务端发来的消息时，触发onmessage事件，参数e.data包含server传递过来的数据
　　console.log(e.data);
}
ws.onclose = function(e){
　　//当客户端收到服务端发送的关闭连接请求时，触发onclose事件
　　console.log("close");
}
ws.onerror = function(e){
　　//如果出现连接、处理、接收、发送数据失败的时候触发onerror事件
　　console.log(error);
}
```

## Json解析

1. `JSON.stringify()`，将JSON封装为字符串
2. `JSON.parse()`，将字符串解析为JSON

# 常用函数

## Array常用对象方法

## ws6箭头函数

`var f = () => function_contect `

 可以用于定义回调函数，使用定义时的 `this` 指向指代表调用时候的 `this` 的指向值。

### map

通过指定函数处理数组的每个元素，并返回处理后的数组。

返回一个 **新数组** ，数组中的元素为原始数组调用函数处理后的值。按照原始数组顺序依次处理元素

> ```js
> array.map(function(currentValue, index, arr), thisValue)
> ```
>
> ```js
> var numbers = [4, 9, 16, 25];
> 
> function myFunction() {
>     x = document.getElementById("demo")
>     x.innerHTML = numbers.map(Math.sqrt);
> }
> ```
>
> `输出：2，3，4，5`

## forEach

调用数组的每个元素，并将元素传递给回调函数

> ```js
> array.forEach(function(currentValue, index, arr), thisValue)
> ```
>
> ```html
> <button onclick="numbers.forEach(myFunction)">点我</button>
>  
> <p>数组元素总和：<span id="demo"></span></p>
>  
> <script>
> var sum = 0;
> var numbers = [65, 44, 12, 4];
>  
> function myFunction(item) {
>     sum += item;
>     demo.innerHTML = sum;
> }
> </script>
> ```
>
> `返回：数组元素总和：125`

### filter

创建一个新的数组，新数组中的元素是通过检查指定数组中符合条件的所有元素。

> ```js
> array.filter(function(currentValue,index,arr), thisValue)
> ```
>
> ```js
> var ages = [32, 33, 16, 40];
> 
> function checkAdult(age) {
>     return age >= 18;
> }
> 
> function myFunction() {
>     document.getElementById("demo").innerHTML = ages.filter(checkAdult);
> }
> ```
>
> `32，33，40`

# 正则表达式

`/正则表达式/修饰符（可选）`

1. search  查找起止位置

   ```js
   var str = "Visit Runoob!"; 
   var n = str.search(/Runoob/i); //i表示不论大小写
   
   //6
   ```

2. replace  替换字符串

   ```js
   var str = document.getElementById("demo").innerHTML; 
   var txt = str.replace(/microsoft/i,"Runoob");
   
   //Visit Runoob!
   ```

3. test 检测一个字符串是否匹配某个模式

   ```js
   var patt = /e/;
   patt.test("The best things in life are free!");
   ```

4. exec 检索字符串中的正则表达式的匹配，返回一个数组

   ```js
   /e/.exec("The best things in life are free!");
   
   //e
   ```

   



表达式修饰符（i，g全局，m（数字）多行）

# 对象方法

- Object.is() 比较两个值是否相等 ，等同于 `==，===`

  ```js
  Object.is('foo', 'foo')
  // true
  Object.is({}, {})
  // false
  
  //唯一不同之处
  +0 === -0 //true
  NaN === NaN // false
  
  Object.is(+0, -0) // false
  Object.is(NaN, NaN) // true
  ```

- Object.assign（） 合并对象，将源对象的所有可枚举属性复制到目标对象

  ```js
  const target = { a: 1 };
  
  const source1 = { b: 2 };
  const source2 = { c: 3 };
  
  Object.assign(target, source1, source2);
  target // {a:1, b:2, c:3}
  ```

  浅拷贝，假如拷贝的对象的某个属性值是一个对象，那对于该值的拷贝得到的该属性对应对象的引用

  同名属性替换而不是添加

## Set和Map

**set**

类似于数组，当成员的值都是唯一的，没有重复的值 `const s = new Set()`

通过 `add()` 方法添加数据，但不会添加重复数据

**weakset**

与 set 类似，但是其成员只能时对象 `const ws = new WeakSet()`

**map**

键值对集合

```js
const m = new Map();
const o = {p: 'Hello World'};

m.set(o, 'content')
m.get(o) // "content"

m.has(o) // true
m.delete(o) // true
m.has(o) // false
```

## 类

```js
class Point {
  constructor(x, y) {  //构造函数
    this.x = x;
    this.y = y;
  }

  toString() {
    return '(' + this.x + ', ' + this.y + ')';
  }
}
```

## 继承

通过 `extends` 关键字实现继承。

```js
class ColorPoint extends Point {
  constructor(x, y, color) {
    super(x, y); // 调用父类的constructor(x, y)
    this.color = color;
  }
  toString() {
    return this.color + ' ' + super.toString(); // 调用父类的toString()
  }
}
```

任何一个子类都有构造函数，而且在写析构函数的时候，必须调用super（）函数，假如子类未声明构造函数，则解析器会自动构建默认构造函数。

# 模型（models）

## 导出（export）

可以到处函数名，变量

形式

到处多变量 `export {**, ** }`或者分多次导出 `export var ** = 9；export function **() {}；`     

导出的变量必须使用 `{}`

## export default

