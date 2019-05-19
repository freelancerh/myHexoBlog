---
title: MySQL基础教程
date: 2015-08-15 11:27:31
categories: MySQL
tags: [MySQL, 数据库]
photos: 
- /uploads/image/cover/lb18.jpg
---

### MySQL 介绍
 MySQL是最流行的关系型数据库管理系统（关联数据库：将数据保存在不同的表中，而不是将所有数据放在一个大仓库内，这样就增加了速度并提高了灵活性。）。由于其体积小、速度快、总体拥有成本低，尤其是开放源码这一特点，一般中小型网站的开发都选择MySQL作为网站数据库。MySQL使用SQL语言进行操作。

### 尝试MySQL
      sudo service mysql start #打开MySQL服务

      mysql -u root            #使用root用户登录

      show databases;          #查看数据库

      use information_schema   #连接数据库

      show tables;             #查看表 

### 创建数据库并插入语句
      CREATE DATABASE mysql_shiyan;   #新建数据库

      CREATE TABLE 表的名字            #新建数据表
      (
        列名a 数据类型(数据长度),
        列名b 数据类型(数据长度)，
        列名c 数据类型(数据长度)
      );
      eg:CREATE TABLE employee (id int(10),name char(20),phone int(12));
   MySQL常用数据类型：
    ![](/uploads/image/reference/MySQL%E5%B8%B8%E7%94%A8%E6%95%B0%E6%8D%AE%E7%B1%BB%E5%9E%8B.jpg)
**CHAR和VARCHAR的区别:** CHAR的长度是固定的，而VARCHAR的长度是可以变化的，比如，存储字符串“abc"，对于CHAR (10)，表示存储的字符将占10个字节(包括7个空字符)，而同样的VARCHAR(12)则只占用3个字节的长度，12只是最大值，当你存储的字符小于12时，按实际长度存储。
**ENUM和SET的区别:** ENUM类型的数据的值，必须是定义时枚举的值的其中之一，即单选，而SET类型的值则可以多选。

      INSERT INTO 表的名字(列名a,列名b,列名c) VALUES(值1,值2,值3);  #插入数据

有的数据需要用单引号括起来，比如Tom、Jack、Rose的名字，这是由于它们的数据类型是CHAR型。此外**VARCHAR,TEXT,DATE,TIME,ENUM**等类型的数据也需要单引号修饰，而**INT,FLOAT,DOUBLE**等则不需要。

### 约束
约束是一种限制，它通过对表的行或列的数据做出限制，来确保表的数据的完整性、唯一性。
在MySQL中，通常有这几种约束：
![](/uploads/image/reference/MySQL%E7%BA%A6%E6%9D%9F.jpg)
* 主键
  主键(PRIMARY KEY)是用于约束表中的一行，作为这一行的标识符，在一张表中通过主键就能准确定位到一行，因此主键十分重要。行中的主键不能有重复且不能为空。
![](/uploads/image/reference/MySQL%E4%B8%BB%E9%94%AE.jpg)
* 默认值约束
DEFAULT约束只会在使用INSERT语句时体现出来，INSERT语句中，如果被DEFAULT约束的位置没有值，那么这个位置将会被DEFAULT的值填充。
* 唯一约束
唯一约束(UNIQUE)比较简单，它规定一张表中指定的一列的值必须不能有重复值，即这一列每个值都是唯一的。
当INSERT语句新插入的数据和已有数据重复的时候，如果有UNIQUE约束，则INSERT失败
* 外键约束
外键(FOREIGN KEY)既能确保数据完整性，也能表现表之间的关系。
一个表可以有多个外键，每个外键必须REFERENCES(参考)另一个表的主键，被外键约束的列，取值必须在它参考的列中有对应值。
![](/uploads/image/reference/MySQL%E5%A4%96%E9%94%AE%E7%BA%A6%E6%9D%9F.jpg)
在INSERT时，如果被外键约束的值没有在参考列中有对应，则INSERT失败。
* 非空约束
非空约束(NOT NULL),听名字就能理解，被非空约束的列，在插入值时必须非空。
![](/uploads/image/reference/MySQL%E9%9D%9E%E7%A9%BA%E7%BA%A6%E6%9D%9F.jpg)
在MySQL中违反非空约束，不会报错，只会有警告。

### 查询操作
* 基本查询操作
      SELECT 要查询的列名 FROM 表名字 WHERE 限制条件;
* 数学符号条件
SELECT语句常常会有WHERE限制条件，用于达到更加精确的查询。WHERE限制条件可以有数学符号 (**=,<,>,>=,<=**) 
      SELECT name,age FROM employee WHERE age>25;
* “AND”与“OR”
从这两个单词就能够理解它们的作用。WHERE后面可以有不止一条限制，而根据条件之间的逻辑关系，可以用**OR(或)**和**AND(且)**连接：
      SELECT name,age FROM employee WHERE age<25 OR age>30;  #筛选出age小于25，或age大于30
      SELECT name,age FROM employee WHERE age>25 AND age<30; #筛选出age大于25，且age小于30
限制条件 **age>25 AND age<30** ，如果需要包含25和30的话，可以替换为 **age BETWEEN 25 AND 30**

*  IN和NOT IN
关键词**IN**和**NOT IN**的作用和它们的名字一样明显，用于筛选**“在”**或**“不在”**某个范围内的结果
      SELECT name,age,phone,in_dpt FROM employee WHERE in_dpt IN ('dpt3','dpt4');
      SELECT name,age,phone,in_dpt FROM employee WHERE in_dpt NOT IN ('dpt1','dpt3');
* 通配符
关键字 **LIKE** 在SQL语句中和通配符一起使用，通配符代表未知字符。SQL中的通配符是 _ 和 % 。其中 _ 代表一个未指定字符，% 代表**不定个**未指定字符。
      SELECT name,age,phone FROM employee WHERE phone LIKE '1101__';
      SELECT name,age,phone FROM employee WHERE name LIKE 'J%';
* 对结果排序
为了使查询结果看起来更顺眼，我们可能需要对结果按某一列来排序，这就要用到 **ORDER BY** 排序关键词。默认情况下，**ORDER BY**的结果是**升序**排列，而使用关键词**ASC**和**DESC**可指定**升序**或**降序**排序。 
      SELECT name,age,salary,phone FROM employee ORDER BY salary DESC;
* SQL内置函数和计算
SQL允许对表中的数据进行计算。
![](/uploads/image/reference/MySQL%E5%86%85%E7%BD%AE%E5%87%BD%E6%95%B0.jpg)
      SELECT MAX(salary) AS max_salary,MIN(salary) FROM employee;
**使用AS关键词可以给值重命名**
* 子查询
上面讨论的SELECT语句都仅涉及一个表中的数据，然而有时必须处理多个表才能获得所需的信息。例如：想要知道名为"Tom"的员工所在部门做了几个工程。员工信息储存在employee表中，但工程信息储存在project表中。 对于这样的情况，我们可以用子查询：
      SELECT of_dpt,COUNT(proj_name) AS count_project FROM project
      WHERE of_dpt IN
      (SELECT in_dpt FROM employee WHERE name='Tom');
子查询还可以扩展到3层、4层或更多层。
* 连接查询
在处理多个表时，子查询只有在结果来自一个表时才有用。但如果需要显示两个表或多个表中的数据，这时就必须使用连接**(join)**操作。 连接的基本思想是把两个或多个表当作一个新的表来操作，如下：
      SELECT id,name,people_num
      FROM employee,department
      WHERE employee.in_dpt = department.dpt_name
      ORDER BY id;
这条语句查询出的是，各员工所在部门的人数，其中员工的id和name来自employee表，people_num来自department表

  另一个连接语句格式是使用JOIN ON语法，刚才的语句等同于：
      SELECT id,name,people_num
      FROM employee JOIN department
      ON employee.in_dpt = department.dpt_name
      ORDER BY id;
  
### 修改和删除
* 对数据库的修改
      DROP DATABASE test_01;    #删除名为test_01的数据库
* 对一张表的修改
   * 重命名一张表
       重命名一张表的语句有多种形式，以下3种格式效果是一样的：
           RENAME TABLE 原名 TO 新名字;
           ALTER TABLE 原名 RENAME 新名;
           ALTER TABLE 原名 RENAME TO 新名;
   * 删除一张表
            DROP TABLE 表名字;

  * 对一列的修改(即对表结构的修改)
     * 增加一列
            ALTER TABLE 表名字 ADD COLUMN 列名字 数据类型 约束;
            或： ALTER TABLE 表名字 ADD 列名字 数据类型 约束;
     * 删除一列
           ALTER TABLE 表名字 DROP COLUMN 列名字;
           或： ALTER TABLE 表名字 DROP 列名字;
     * 重命名一列
           ALTER TABLE 表名字 CHANGE 原列名 新列名 数据类型 约束;
      **注意：这条重命名语句后面的 “数据类型” 不能省略，否则重命名失败。**
      当**原列名**和**新列名**相同的时候，指定新的**数据类型**或**约束**，就可以用于修改数据类型或约束。需要注意的是，修改数据类型可能会导致数据丢失，所以要慎重使用。
     * 改变数据类型
        要修改一列的数据类型，除了使用刚才的**CHANGE**语句外，还可以用这样的**MODIFY**语句：
           ALTER TABLE 表名字 MODIFY 列名字 新数据类型;
* 对表的内容修改
  * 修改表中某个值
        UPDATE 表名字 SET 列1=值1,列2=值2 WHERE 条件;
  * 删除一行记录
        DELETE FROM 表名字 WHERE 条件;

### 其他
* 索引
索引是一种与表有关的结构，它的作用相当于书的目录，可以根据目录中的页码快速找到所需的内容。 当表中有大量记录时，若要对表进行查询，没有索引的情况是全表搜索：将所有记录一一取出，和查询条件进行一一对比，然后返回满足条件的记录。这样做会消耗大量数据库系统时间，并造成大量磁盘I/O操作。 而如果在表中已建立索引，在索引中找到符合查询条件的索引值，通过索引值就可以快速找到表中的数据，可以**大大加快查询速度**。
对一张表中的某个列建立索引，有以下两种语句格式：
      ALTER TABLE 表名字 ADD INDEX 索引名 (列名);
      CREATE INDEX 索引名 ON 表名字 (列名);

      ALTER TABLE employee ADD INDEX idx_id (id); #在employee表的id列上建立名为idx_id的索引
      CREATE INDEX idx_name ON employee (name); #在employee表的name列上建立名为idx_name的索引
查看表的索引：
       SHOW INDEX FROM 表名字;
在使用SELECT语句查询的时候，语句中WHERE里面的条件，会**自动判断有没有可用的索引**。

* 视图
 视图是从一个或多个表中导出来的表，是一种**虚拟存在的表**。它就像一个窗口，通过这个窗口可以看到系统专门提供的数据，这样，用户可以不用看到整个数据库中的数据，而只关心对自己有用的数据。
注意理解视图是虚拟的表：

  1.数据库中只存放了视图的定义，而没有存放视图中的数据，这些数据存放在原来的表中；
  2.使用视图查询数据时，数据库系统会从原来的表中取出对应的数据；
  3.视图中的数据依赖于原来表中的数据，一旦表中数据发生改变，显示在视图中的数据也会发生改变；
  4.在使用视图的时候，可以把它当作一张表。

  创建视图的语句格式为： 
      CREATE VIEW 视图名(列a,列b,列c) AS SELECT 列1,列2,列3 FROM 表名字;
  可见创建视图的语句，后半句是一个SELECT查询语句，所以**视图也可以建立在多张表上**，只需在SELECT语句中使用**子查询**或**连接查询**

---
### 参考资料
[实验楼--MySQL基础教程](https://www.shiyanlou.com/courses/9)