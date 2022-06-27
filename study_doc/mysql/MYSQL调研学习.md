# MYSQL调研学习

# 1. SQL基础

```sql
use database;  //使用database数据库
set names utf8; //设置字符集为utf8
select * from table; //查询table表
```

SQL不区分大小写，即大小写不敏感

## 1.1 SELECT

最基本的用法

`SELECT column_name,column_name FROM table_name;` 

**扩展用法**（可以组合一起使用）

- `DISTINCT(distinct)`返回值不重复

  `SELECT DISTINCT column_name,column_name FROM table_name;`

- `WHERE` 提取后面满足条件的语句

  `SELECT column_name,column_name FROM table_name WHERE column_name operator value;`

  - `AND & OR` 与或运算

    `SELECT column_name,column_name FROM table_name WHERE column_name operator value AND[OR] column_name operator value;`

- `ORDER BY` `ASC`升序，`DESC`降序

  `SELECT column_name,column_name FROM table_name ORDER BY column_name,column_name ASC[DESC];`

- `TOP`

## 1.2 INSERT  INTO

不指定列名，但需要插入数据与列数保持一致

`INSERT INTO table_name VALUES (value1,value2,...)`

指定列名

`INSERT INTO table_name (column_name1,column_name2,...) VALUES (value1,value2,...)`

## 1.3 UPDATE

更新特定行，必须指定

`UPDATE table_name SET column_name1=value1,column_name2=value2,... WHERE some_column=some_value;`

## 1.4 DELETE

删除指定的行，假如没有指定，则删除全表数据

`DELETE REOM table_name WHERE some_column=some_value;`