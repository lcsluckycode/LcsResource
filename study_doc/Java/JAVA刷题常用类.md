# JAVA刷题常用类

# 1. 常用包

```java
import java.util.Scanner;
import java.util.Map;
import java.util.Collection;
import java.lang.Math;
```

# 2. 输入输出

```java
//输入字符串
import java.util.Scanner; 
Scanner input=new Scanner(System.in);
String s1=input.next();

//输入数字
int contents=input.nextInt();
if(input.hasNext()){
	int a=input.nextInt();
}
```

# 3. 字符串

```java
a.length();
//输出strs[]个数
strs.length;
//数组是a.length（没有括号）
```

```java
for(int i=0;i<s.length();i++){
	s.charAt(i);
}
```

```java
//st->int
int a = Integer.parseInt(str);

//other -> str
String s = String.valueOf(value);

//Substring
s1 = s.substring(0,5); //[0,5)

//matcher
String pattern ="^(\\d{17}([0-9]|x))$";
if(s.matcher.(pattern)){}

//find str
String s="adsff gdgs";
int a2 = s.indexOf("asdf"); //false return -1

//just equals
if(a.equals(b)){}

//split return String[]
String[] b = a.split(" ");

//replace
a.replace("1","a");

//remove head and tail " "
a = a.trim();
```

![img](E:\lcsprogram\study_doc\Java\images\v2-3c825cbb777ce60f3e1493babfec7b6e_720w.jpg)

# 4. 数组

## 4.1  固定数组

```java
//init
int[] a = new int[10];
int[][] a = new int[10][10];
fill(a,100);
Arrays.fill(a,100);

//sort
Arrays.sort(a); //low to hight
```

## 4.2 动态数组

- ArrayList：底层使用数组实现的，查找快，插入数据和删除数据慢（常用）
- LinkedList：底层使用链表实现的，查找慢，插入数据和删除数据快(常用)

```java
//init
ArrayList<Integer> a = new ArrayList<>();
Collections.fill(a1,100);

//add and remove
a1.add(1);
a1.add(3,4); //4 insert the 3rd
a1.remove(3); //remove the (3+1)rd

//下标
for(int i=0;i<a.size();i++){
	a.get(i);//访问下标为i的
}
//循环
for(int item:a){
	;
}

//sort
Collections.sort(a1);
Collections.max(a1);
Collections.min(a1);

//翻转
Collections.reverse(a1);
```

# 5. Map

HashMap：用于快速访问,常用与哈希有关的(常用)
TreeMap：键处于排序状态
LinkedHashMap：保持元素插入的顺序

```java
//init
import java.util.HashMap;
HashMap<Integer,Integer> map=new HashMap<>();

//put
map.put(k,v);

//find
if(map.containsKey(k));
if(map.containsValue(v));

//get
int a = map.get(k);

//foreach
Iterator<Integer> it = map.keySet().iterator();
while(it.hasNext()){
    Integer key = it.next();
    Integer value = map.get(key);
}

//keySet
for(Integer key:map.keySet()){}
```

# 6. Set

- HashSet:使用散列函数查找快速（也就是常说的哈希查找）(常用)
- TreeSet:排序默认从小到大
- LinkedHashSet：使用链表维护元素的插入顺序

```java
//init
Set<Character> s = new HashSet<>();

//add remove
s.add(a);
s.remove(a);

//find
s.contains(a);

//clear
s.clear();
```

# 7. Stack

```java
//init
Stack<Integer> s = new Stack<Integer>();

//push pop
s.push(a);
s.pop();  //return top value and remove it
s.empty();  //return stack is empty or not
s.peek(); //return top value but didn't remove it
```

# 8. Queue

- PriorityQueue:优先队列(常用)
- LinkedList:普通队列(常用)

不允许添加空元素

```java
//init
Queue<Integer> q = new LinkedList<>();

//offer poll
q.offer(a);  //add a in tail
q.poll();  //return head value and remove it
q.peek();  //return head value but didn't remove it
```

# 9. 注意事项

Java的判断条件类型必须时 `bool` 类型

Java字符串判断是否相等不能用 `==`

Java中的char是16位，采用Unicode编码