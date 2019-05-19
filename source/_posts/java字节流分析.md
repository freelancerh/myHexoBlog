---
title: java字节流分析
date: 2015-05-07 11:27:31
categories: java
tags: [java,java io]
photos: 
- /uploads/image/cover/wz5.jpg
---
<center> 
![](/uploads/image/reference/InputStream%E5%B8%B8%E7%94%A8%E7%B1%BB%E7%BB%A7%E6%89%BF%E6%9E%B6%E6%9E%84.jpg)
</center>

<center> InputStream 常用类继承框架  </center>

<center> 
![](/uploads/image/reference/OutputStream%E5%B8%B8%E7%94%A8%E7%B1%BB%E7%BB%A7%E6%89%BF%E6%9E%B6%E6%9E%84.jpg)
</center>

<center> OutputStream 常用类继承框架  </center>


_想活用输入 / 输出 API ，一定要先了解 Java 中如何以串流 (Stream) 抽象化输入 / 输出概念，以及 InputStream 、 OutputStream 继承架构。如此一来，无论标准输入 / 输出、文档输入/ 输出、网络输入 / 输出、数据库输入 / 输出等都可用一致的操作进行处理。_

### 串流设计的概念
从应用程序角度来看，如果要将数据从来源取出，可以使用 输入串流 ，如果要将数据写入目的地，可以使用 输出串流 。在 Java 中，输入串流代表对象为 java.io.InputStream 实例，输出串流代表对象为 java.io.OutputStream 实例。无论数据源或目的地为何，只要设法取得 InputStream 或 OutputStream 的实例， 接下来操作输入 / 输出的方式都是一致， 无须理会来源或目的地的真正形式
### 串流处理装饰器
这里用到了设计模式里的装饰模式，其中InputStream 是抽象组件，FileInputStream，ByteArrayInputStream是具体组件，而FilterInputStream，ObjectInputStream是装饰。

* #### BufferedInputStream 与 BufferedOutputStream
 每次调用 InputStream 的 read() 方法， 都会直接向来源要求数据，每次调用 OutputStream 的 write() 方法时，都会直接将数据写到目的地，这并不是个有效率的方式。以文档存取为例，如果传入 IO.dump() 的是 FileInputStream 、 FileOutputStream 实例，每次 read() 时都会要求读取硬盘，每次 write() 时 都会要求写入硬盘，这会花费许多时间在硬
盘定位上。
如果 InputStream 第一次 read() 时 可以尽量读取足够的数据至内存的缓冲区，后续调用read() 时先看看缓冲区是不是还有数据，如果有就从缓冲区读取，没有再从来源读取数据至缓冲区，这样减少从来源直接读取数据的次数，对读取效率将会有帮助 ( 毕竟内存的访问
速度较快 ) 。
如果 OutputStream 每次 write() 时可将数据写入内存中的缓冲区，缓冲区满了再将缓冲区的数据写入目的地，这样可减少对目的地的写入次数，对写入效率将会有帮助。
BufferedInputStream 与 BufferedOutputStream 提供的就是前面描述的缓冲区功能，创建
BufferedInputStream 、 BufferedOutputStream 必须提供 InputStream 、 OutputStream 进行打包，可以使用默认或自定义缓冲区大小。

* #### DataInputStream 与 DataOutputStream
DataInputStream 、 DataOutputStream 用来装饰 InputStream 、 OutputStream ， DataInputStream 、
DataOutputStream 提供读取、 写入 Java 基本数据类型的方法， 像是读写 int 、 double 、 boolean等的方法。这些方法会自动在指定的类型与字节间转换，不用你亲自做字节与类型转换的动作。

* #### ObjectInputStream 与 ObjectOutputStream
可以将内存中的对象整个储存下来，之后再读入还原为对象。可以使用 ObjectInputStream 、 ObjectOutputStream 装饰 InputStream 、OutputStream 来完成这项工作。
ObjectInputStream 提供 readObject() 方法将数据读入为对象，而 ObjectOutputStream 提
供writeObject() 方法将对象写至目的地，可以被这两个方法处理的对象，必须实现java.io.Serializable 接口，这个接口并没有定义任何方法，只是作为标示之用，表示这个对象是可以串行化的 (Serializable) 。
如果在做对象串行化时，对象中某些数据成员不希望被写出，则可以标上**transient**关键字。

----
### 参考资料
[Java JDK 7学习笔记](https://book.douban.com/subject/10569595/)
