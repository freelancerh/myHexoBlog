---
title: ClassLoader原理
date: 2015-08-29 22:26:07
categories: java
tags: [java,jvm]
photos:
- http://7xlbns.com1.z0.glb.clouddn.com//hihuaning/image/kn/kn2.jpeg
---

### 什么是ClassLoader?
大家都知道，当我们写好一个Java程序之后，不是管是CS还是BS应用，都是由若干个.class文件组织而成的一个完整的Java应用程序，当程序在运行时，即会调用该程序的一个入口函数来调用系统的相关功能，而这些功能都被封装在不同的class文件当中，所以经常要从这个class文件中要调用另外一个class文件中的方法，如果另外一个文件不存在的，则会引发系统异常。而程序在启动的时候，并不会一次性加载程序所要用的所有class文件，而是根据程序的需要，通过Java的类加载机制（ClassLoader）来动态加载某个class文件到内存当中的，从而只有class文件被载入到了内存之后，才能被其它class所引用。所以ClassLoader就是用来动态加载class文件到内存当中用的。

### Java默认提供的三个ClassLoader
####  1. ***Bootstrap ClassLoader***：称为启动类加载器，是Java类加载层次中最顶层的类加载器，**负责加载JDK中的核心类库，如：rt.jar、resources.jar、charsets.jar等**，可通过如下程序获得该类加载器从哪些地方加载了相关的jar或class文件：

           URL[] urls = sun.misc.Launcher.getBootstrapClassPath().getURLs();  
           for (int i = 0; i < urls.length; i++) {  
            System.out.println(urls[i].toExternalForm());  
           }

    以下内容是上述程序从本机JDK环境所获得的结果：
          file:/C:/Program%20Files/Java/jdk1.6.0_22/jre/lib/resources.jar
          file:/C:/Program%20Files/Java/jdk1.6.0_22/jre/lib/rt.jar
          file:/C:/Program%20Files/Java/jdk1.6.0_22/jre/lib/sunrsasign.jar
          file:/C:/Program%20Files/Java/jdk1.6.0_22/jre/lib/jsse.jar
          file:/C:/Program%20Files/Java/jdk1.6.0_22/jre/lib/jce.jar
          file:/C:/Program%20Files/Java/jdk1.6.0_22/jre/lib/charsets.jar
          file:/C:/Program%20Files/Java/jdk1.6.0_22/jre/classes/
其实上述结果也是通过查找**sun.boot.class.path**这个系统属性所得知的。

           System.out.println(System.getProperty("sun.boot.class.path"));

    **打印结果：**

          C:\Program Files\Java\jdk1.6.0_22\jre\lib\resources.jar;C:\Program Files\Java\jdk1.6.0_22\jre\lib\rt.jar;C:\Program Files\Java\jdk1.6.0_22\jre\lib\sunrsasign.jar;C:\Program Files\Java\jdk1.6.0_22\jre\lib\jsse.jar;C:\Program Files\Java\jdk1.6.0_22\jre\lib\jce.jar;C:\Program Files\Java\jdk1.6.0_22\jre\lib\charsets.jar;C:\Program Files\Java\jdk1.6.0_22\jre\classes

####   2.  ***Extension ClassLoader***：称为扩展类加载器，负责加载Java的扩展类库，默认加载JAVA_HOME/jre/lib/ext/目下的所有jar。

####   3.  ***App ClassLoader***：称为系统类加载器，负责加载应用程序classpath目录下的所有jar和class文件。

**注意：** 除了Java默认提供的三个ClassLoader之外，用户还可以根据需要定义自已的ClassLoader，而这些自定义的ClassLoader都必须继承自java.lang.ClassLoader类，也包括Java提供的另外二个ClassLoader（Extension ClassLoader和App ClassLoader）在内，但是Bootstrap ClassLoader不继承自ClassLoader，因为它不是一个普通的Java类，底层由C++编写，已嵌入到了JVM内核当中，当JVM启动后，Bootstrap ClassLoader也随着启动，负责加载完核心类库后，并构造Extension ClassLoader和App ClassLoader类加载器。

### ClassLoader加载类的原理
#### 1. 原理介绍
  ClassLoader使用的是**双亲委托模型**来搜索类的，每个ClassLoader实例都有一个父类加载器的引用（不是继承的关系，是一个包含的关系），虚拟机内置的类加载器（Bootstrap ClassLoader）本身没有父类加载器，但可以用作其它ClassLoader实例的的父类加载器。当一个ClassLoader实例需要加载某个类时，它会试图亲自搜索某个类之前，先把这个任务委托给它的父类加载器，这个过程是由上至下依次检查的，首先由最顶层的类加载器Bootstrap ClassLoader试图加载，如果没加载到，则把任务转交给Extension ClassLoader试图加载，如果也没加载到，则转交给App ClassLoader 进行加载，如果它也没有加载得到的话，则返回给委托的发起者，由它到指定的文件系统或网络等URL中加载该类。如果它们都没有加载到这个类时，则抛出ClassNotFoundException异常。否则将这个找到的类生成一个类的定义，并将它加载到内存当中，最后返回这个类在内存中的Class实例对象。

#### 2. 为什么要使用双亲委托这种模型呢？
因为这样可以避免重复加载，当父亲已经加载了该类的时候，就没有必要子ClassLoader再加载一次。考虑到安全因素，我们试想一下，如果不使用这种委托模式，那我们就可以随时使用自定义的String来动态替代java核心api中定义的类型，这样会存在非常大的安全隐患，而双亲委托的方式，就可以避免这种情况，因为String已经在启动时就被引导类加载器（Bootstrcp ClassLoader）加载，所以用户自定义的ClassLoader永远也无法加载一个自己写的String，除非你改变JDK中ClassLoader搜索类的默认算法。

#### 3. 但是JVM在搜索类的时候，又是如何判定两个class是相同的呢？
JVM在判定两个class是否相同时，不仅要判断两个类名是否相同，而且要判断是否由同一个类加载器实例加载的。只有两者同时满足的情况下，JVM才认为这两个class是相同的。就算两个class是同一份class字节码，如果被两个不同的ClassLoader实例所加载，JVM也会认为它们是两个不同class。比如网络上的一个Java类org.classloader.simple.NetClassLoaderSimple，javac编译之后生成字节码文件NetClassLoaderSimple.class，ClassLoaderA和ClassLoaderB这两个类加载器并读取了NetClassLoaderSimple.class文件，并分别定义出了java.lang.Class实例来表示这个类，对于JVM来说，它们是两个不同的实例对象，但它们确实是同一份字节码文件，如果试图将这个Class实例生成具体的对象进行转换时，就会抛运行时异常java.lang.ClassCaseException，提示这是两个不同的类型。现在通过实例来验证上述所描述的是否正确：
##### 1， 在web服务器上建一个org.classloader.simple.NetClassLoaderSimple.java类

        package org.classloader.simple;  
           public class NetClassLoaderSimple {  
              private NetClassLoaderSimple instance;  
              public void setNetClassLoaderSimple(Object obj) {  
              this.instance = (NetClassLoaderSimple)obj;  
            }  
        }

    org.classloader.simple.NetClassLoaderSimple类的setNetClassLoaderSimple方法接收一个Object类型参数，并将它强制转换成org.classloader.simple.NetClassLoaderSimple类型。

##### 2， 测试两个class是否相同
          package classloader;  
            public class NewworkClassLoaderTest {  
              public static void main(String[] args) {  
                  try {  
                  //测试加载网络中的class文件  
                  String rootUrl = "http://localhost:8080/httpweb/classes";  
                  String className = "org.classloader.simple.NetClassLoaderSimple";  
                  NetworkClassLoader ncl1 = new NetworkClassLoader(rootUrl);  
                  NetworkClassLoader ncl2 = new NetworkClassLoader(rootUrl);  
                  Class<?> clazz1 = ncl1.loadClass(className);  
                  Class<?> clazz2 = ncl2.loadClass(className);  
                  Object obj1 = clazz1.newInstance();  
                  Object obj2 = clazz2.newInstance();  
                  clazz1.getMethod("setNetClassLoaderSimple", Object.class).invoke(obj1, obj2);  
                  } catch (Exception e) {  
                  e.printStackTrace();  
                  }  
          }  
        }
    首先获得网络上一个class文件的二进制名称，然后通过自定义的类加载器NetworkClassLoader创建两个实例，并根据网络地址分别加载这份class，并得到这两个ClassLoader实例加载后生成的Class实例clazz1和clazz2，最后将这两个Class实例分别生成具体的实例对象obj1和obj2，再通过反射调用clazz1中的setNetClassLoaderSimple方法。

##### 3， 查看测试结果
![](http://7xlbns.com1.z0.glb.clouddn.com/%40%2Fhihuaning%2Freference%2FClassLoadTestResult1.jpg)
**结论：从结果中可以看出，虽然是同一份class字节码文件，但是由于被两个不同的ClassLoader实例所加载，所以JVM认为它们就是两个不同的类。**

##### 4.ClassLoader的体系架构：
<center>
![](http://7xlbns.com1.z0.glb.clouddn.com/%40%2Fhihuaning%2Freference%2FClassLoader.png)
</center>


### 定义自已的ClassLoader
***既然JVM已经提供了默认的类加载器，为什么还要定义自已的类加载器呢？***
因为Java中提供的默认ClassLoader，只加载指定目录下的jar和class，如果我们想加载其它位置的类或jar时，比如：我要加载网络上的一个class文件，通过动态加载到内存之后，要调用这个类中的方法实现我的业务逻辑。在这样的情况下，默认的ClassLoader就不能满足我们的需求了，所以需要定义自己的ClassLoader。
***定义自已的类加载器分为两步：***
1、继承java.lang.ClassLoader
2、重写父类的findClass方法

父类有那么多方法，为什么偏偏只重写findClass方法？

因为JDK已经在loadClass方法中帮我们实现了ClassLoader搜索类的算法，当在loadClass方法中搜索不到类时，loadClass方法就会调用findClass方法来搜索类，所以我们只需重写该方法即可。如没有特殊的要求，一般不建议重写loadClass搜索类的算法。

** 示例：自定义一个NetworkClassLoader，用于加载网络上的class文件 **
<pre><code>
package classloader;  

import java.io.ByteArrayOutputStream;  
import java.io.InputStream;  
import java.net.URL;  

/** 
 * 加载网络class的ClassLoader 
 */  
public class NetworkClassLoader extends ClassLoader {  

    private String rootUrl;  

    public NetworkClassLoader(String rootUrl) {  
        this.rootUrl = rootUrl;  
    }  

    @Override  
    protected Class<?> findClass(String name) throws ClassNotFoundException {  
        Class clazz = null;//this.findLoadedClass(name); // 父类已加载     
        //if (clazz == null) {  //检查该类是否已被加载过  
            byte[] classData = getClassData(name);  //根据类的二进制名称,获得该class文件的字节码数组  
            if (classData == null) {  
                throw new ClassNotFoundException();  
            }  
            clazz = defineClass(name, classData, 0, classData.length);  //将class的字节码数组转换成Class类的实例  
        //}   
        return clazz;  
    }  

    private byte[] getClassData(String name) {  
        InputStream is = null;  
        try {  
            String path = classNameToPath(name);  
            URL url = new URL(path);  
            byte[] buff = new byte[1024*4];  
            int len = -1;  
            is = url.openStream();  
            ByteArrayOutputStream baos = new ByteArrayOutputStream();  
            while((len = is.read(buff)) != -1) {  
                baos.write(buff,0,len);  
            }  
            return baos.toByteArray();  
        } catch (Exception e) {  
            e.printStackTrace();  
        } finally {  
            if (is != null) {  
               try {  
                  is.close();  
               } catch(IOException e) {  
                  e.printStackTrace();  
               }  
            }  
        }  
        return null;  
    }  

    private String classNameToPath(String name) {  
        return rootUrl + "/" + name.replace(".", "/") + ".class";  
    }  

}
</code></pre>

**测试类：**
<pre><code>
package classloader;  

public class ClassLoaderTest {  

    public static void main(String[] args) {  
        try {  
            /*ClassLoader loader = ClassLoaderTest.class.getClassLoader();  //获得ClassLoaderTest这个类的类加载器 
            while(loader != null) { 
                System.out.println(loader); 
                loader = loader.getParent();    //获得父加载器的引用 
            } 
            System.out.println(loader);*/  

            String rootUrl = "http://localhost:8080/httpweb/classes";  
            NetworkClassLoader networkClassLoader = new NetworkClassLoader(rootUrl);  
            String classname = "org.classloader.simple.NetClassLoaderTest";  
            Class clazz = networkClassLoader.loadClass(classname);  
            System.out.println(clazz.getClassLoader());  

        } catch (Exception e) {  
            e.printStackTrace();  
        }  
    }  

}
</code></pre>

***打印结果：***
![](http://7xlbns.com1.z0.glb.clouddn.com/%40%2Fhihuaning%2Freference%2FClassLoaderResult2.jpg)

下图是web服务器的目录结构：
![](http://7xlbns.com1.z0.glb.clouddn.com/%40%2Fhihuaning%2Freference%2FClassLoaderTestResult3.jpg)

目前常用web服务器中都定义了自己的类加载器，用于加载web应用指定目录下的类库（jar或class），如：Weblogic、Jboss、tomcat等，下面以Tomcat为例，展示该web容器都定义了哪些个类加载器：

1、新建一个web工程httpweb

2、新建一个ClassLoaderServletTest，用于打印web容器中的ClassLoader层次结构

<pre><code>
import java.io.IOException;  
import java.io.PrintWriter;  

import javax.servlet.ServletException;  
import javax.servlet.http.HttpServlet;  
import javax.servlet.http.HttpServletRequest;  
import javax.servlet.http.HttpServletResponse;  

public class ClassLoaderServletTest extends HttpServlet {  

    public void doGet(HttpServletRequest request, HttpServletResponse response)  
            throws ServletException, IOException {  

        response.setContentType("text/html");  
        PrintWriter out = response.getWriter();  
        ClassLoader loader = this.getClass().getClassLoader();  
        while(loader != null) {  
            out.write(loader.getClass().getName()+"<br/>");  
            loader = loader.getParent();  
        }  
        out.write(String.valueOf(loader));  
        out.flush();  
        out.close();  
    }  

    public void doPost(HttpServletRequest request, HttpServletResponse response)  
            throws ServletException, IOException {  
        this.doGet(request, response);  
    }  

}
</code></pre>

3、配置Servlet，并启动服务
<pre><code>
<?xml version="1.0" encoding="UTF-8"?>  
<web-app version="2.4"   
    xmlns="http://java.sun.com/xml/ns/j2ee"   
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"   
    xsi:schemaLocation="http://java.sun.com/xml/ns/j2ee   

http://java.sun.com/xml/ns/j2ee/web-app_2_4.xsd">

  <servlet>  
    <servlet-name>ClassLoaderServletTest</servlet-name>  
    <servlet-class>ClassLoaderServletTest</servlet-class>  
  </servlet>  

  <servlet-mapping>  
    <servlet-name>ClassLoaderServletTest</servlet-name>  
    <url-pattern>/servlet/ClassLoaderServletTest</url-pattern>  
  </servlet-mapping>  
  <welcome-file-list>  
    <welcome-file>index.jsp</welcome-file>  
  </welcome-file-list>  
</web-app>
</code></pre>

4、访问Servlet，获得显示结果
![](http://7xlbns.com1.z0.glb.clouddn.com/%40%2Fhihuaning%2Freference%2FClassLoaderTestResult4.jpg)

---
### 参考资料
[Java ClassLoader 原理详细分析](http://www.codeceo.com/article/java-classloader.html)