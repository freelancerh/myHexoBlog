---
title: java字符流分析
date: 2015-05-08 11:27:31
categories: java
tags: [java,java io]
photos: 
- /uploads/image/cover/wz7.jpg
---
<center>
![](/uploads/image/reference/java%E5%AD%97%E7%AC%A6%E6%B5%81%E5%B8%B8%E7%94%A8%E7%B1%BB%E7%BB%A7%E6%89%BF%E6%9E%B6%E6%9E%84.jpg) </center>

_ InputStream，OutputStream是用来读入与写出字节数据，若实际上处理的是字符数据，使用InputStream，OutputStream就得对照编码表，在字符与字节之间进行转换。所需Java SE API已经提供了相关的输入/输出字符处理类，这就是Reader和Writer。 _

### 字符处理装饰器
就像InputStream，OutputSterm 有一些装饰器类，可以对InputStream，OutputStream装饰增加额外功能，Reader，Writer也有一些装饰器类可供使用。

* ####  InputStreamReader 与 OutputStreamWriter
如果如果串流处理的字节数据，实际上代表某些字符的编码数据，而你想要将这些字节数据转换为对应的编码字符， 可以使用 InputStreamReader 、 OutputStreamWriter 对串流数据打包。
在建立 InputStreamReader 与 OutputStreamWriter 时， 可以指定编码， 如果没有指定编码，则以 JVM 启动时所获取的默认编码来做字符转换。 

* #### BufferedReader 与 BufferedWriter
正如 BufferedInputStream 、 BufferedOutputStream 为 InputStream 、 OutputStream 提供缓冲区作用，以改进输入 / 输出的效率， BufferedReader 、 BufferedWriter 可对 Reader 、 Writer 提供缓冲区作用，在处理字符输入 / 输出时，对效率也会有所帮助。
* #### PrintWriter
PrintWriter 与 PrintStream 使用上极为类似，不过除了可以对 OutputStream 打包之外，PrintWriter 还可以Writer 进行打包，提供 print() 、 println() 、 format() 等方法。

----
### 参考资料
[Java JDK 7学习笔记](https://book.douban.com/subject/10569595/)