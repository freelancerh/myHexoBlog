---
title: java对象序列化
date: 2015-05-16 11:27:31
categories: java
tags: [java,java io, 对象序列化]
photos: 
- http://7xlbns.com1.z0.glb.clouddn.com/%40%2Fhihuaning%2Fimage%2Flb%2Flb2.jpg
---

关于Java序列化的文章早已是汗牛充栋了，本文是对我个人过往学习，理解及应用Java序列化的一个总结。此文内容涉及Java序列化的基本原理，以及多种方法对序列化形式进行定制。在撰写本文时，既参考了Thinking in Java, Effective Java，JavaWorld，developerWorks中的相关文章和其它网络资料，也加入了自己的实践经验与理解，文、码并茂，希望对大家有所帮助。

**1. 什么是Java对象序列化**

Java平台允许我们在内存中创建可复用的Java对象，但一般情况下，只有当JVM处于运行时，这些对象才可能存在，即，这些对象的生命周期不会比JVM的生命周期更长。但在现实应用中，就可能要求在JVM停止运行之后能够保存(持久化)指定的对象，并在将来重新读取被保存的对象。Java对象序列化就能够帮助我们实现该功能。    使用Java对象序列化，在保存对象时，会把其状态保存为一组字节，在未来，再将这些字节组装成对象。必须注意地是，对象序列化保存的是对象的"状态"，即它的成员变量。由此可知，对象序列化不会关注类中的静态变量。    除了在持久化对象时会用到对象序列化之外，当使用RMI(远程方法调用)，或在网络中传递对象时，都会用到对象序列化。Java序列化API为处理对象序列化提供了一个标准机制，该API简单易用，在本文的后续章节中将会陆续讲到。

**2. 简单示例**

在Java中，只要一个类实现了java.io.Serializable接口，那么它就可以被序列化。此处将创建一个可序列化的类Person，本文中的所有示例将围绕着该类或其修改版。    Gender类，是一个枚举类型，表示性别

    public enum Gender {MALE, FEMALE}

如果熟悉Java枚举类型的话，应该知道每个枚举类型都会默认继承类java.lang.Enum，而该类实现了Serializable接口，所以枚举类型对象都是默认可以被序列化的。    Person类，实现了Serializable接口，它包含三个字段：name，String类型；age，Integer类型；gender，Gender类型。另外，还重写该类的toString()方法，以方便打印Person实例中的内容。

    public class Person implements Serializable {
      private String name = null;
      private Integer age = null;
      private Gender gender = null;

      public Person() {
        System.out.println("none-arg constructor");
     }

    public Person(String name, Integer age, Gender gender) {
        System.out.println("arg constructor");
        this.name = name; 
        this.age = age;
        this.gender = gender;
    }
     
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
    
    public Integer getAge() {
        return age;
    }

    public void setAge(Integer age) {
        this.age = age;
    }
    
    public Gender getGender() {
        return gender;
    }
    
    public void setGender(Gender gender) {
        this.gender = gender;
    }
    
    @Override
    public String toString() {
        return "[" + name + ", " + age + ", " + gender + "]";
    }
    }


 SimpleSerial，是一个简单的序列化程序，它先将一个Person对象保存到文件person.out中，然后再从该文件中读出被存储的Person对象，并打印该对象。

    public class SimpleSerial {
    public static void main(String[] args) throws Exception {
        File file = new File("person.out");
        ObjectOutputStream oout = new ObjectOutputStream(new FileOutputStream(file));
        Person person = new Person("John", 101, Gender.MALE);
        oout.writeObject(person);
        oout.close();
        ObjectInputStream oin = new ObjectInputStream(new FileInputStream(file));
        Object newPerson = oin.readObject(); // 没有强制转换到Person类型
        oin.close(); 
       System.out.println(newPerson);
    }
    }

上述程序的输出的结果为：

    arg constructor[John, 31, MALE]

此时必须注意的是，当重新读取被保存的Person对象时，并没有调用Person的任何构造器，看起来就像是直接使用字节将Person对象还原出来的。当Person对象被保存到person.out文件中之后，我们可以在其它地方去读取该文件以还原对象，但必须确保该读取程序的CLASSPATH中包含有Person.class(哪怕在读取Person对象时并没有显示地使用Person类，如上例所示)，否则会抛出ClassNotFoundException。

**3. Serializable的作用**
为什么一个类实现了Serializable接口，它就可以被序列化呢？在上节的示例中，使用ObjectOutputStream来持久化对象，在该类中有如下代码：

     private void writeObject0(Object obj, boolean unshared) throws IOException {
        if (obj instanceof String) {
        writeString((String) obj, unshared);
        } else if (cl.isArray()) {
        writeArray(obj, desc, unshared);
        } else if (obj instanceof Enum) {
        writeEnum((Enum) obj, desc, unshared);
        } else if (obj instanceof Serializable) {
        writeOrdinaryObject(obj, desc, unshared);
        } else {
            if (extendedDebugInfo) {
                throw new NotSerializableException(cl.getName() + "\n" 
                       + debugInfoStack.toString());
            } else {
                throw new NotSerializableException(cl.getName());
            }
        }
    }

从上述代码可知，如果被写对象的类型是String，或数组，或Enum，或Serializable，那么就可以对该对象进行序列化，否则将抛出NotSerializableException。

**4. 默认序列化机制**
 如果仅仅只是让某个类实现Serializable接口，而没有其它任何处理的话，则就是使用默认序列化机制。使用默认机制，在序列化对象时，不仅会序列化当前对象本身，还会对该对象引用的其它对象也进行序列化，同样地，这些其它对象引用的另外对象也将被序列化，以此类推。所以，如果一个对象包含的成员变量是容器类对象，而这些容器所含有的元素也是容器类对象，那么这个序列化的过程就会较复杂，开销也较大。

**5. 影响序列化**

  在现实应用中，有些时候不能使用默认序列化机制。比如，希望在序列化过程中忽略掉敏感数据，或者简化序列化过程。下面将介绍若干影响序列化的方法。

**5.1 transient关键字**

当某个字段被声明为transient后，默认序列化机制就会忽略该字段。此处将Person类中的age字段声明为transient，如下所示，

    public class Person implements Serializable {   
      ...
      transient private Integer age = null;
      ...
    }

再执行SimpleSerial应用程序，会有如下输出：

    arg constructor
    [John, null, MALE]
可见，age字段未被序列化。

**5.2 writeObject()方法与readObject()方法**

对于上述已被声明为transitive的字段age，除了将transitive关键字去掉之外，是否还有其它方法能使它再次可被序列化？方法之一就是在Person类中添加两个方法：writeObject()与readObject()，如下所示：

    public class Person implements Serializable {
      ...
      transient private Integer age = null;
        private void writeObject(ObjectOutputStream out) throws IOException {
        out.defaultWriteObject();
        out.writeInt(age);
    }
    private void readObject(ObjectInputStream in) throws IOException, ClassNotFoundException {
        in.defaultReadObject();
        age = in.readInt();
    }
    ...
    }
在writeObject()方法中会先调用ObjectOutputStream中的defaultWriteObject()方法，该方法会执行默认的序列化机制，如5.1节所述，此时会忽略掉age字段。然后再调用writeInt()方法显示地将age字段写入到ObjectOutputStream中。readObject()的作用则是针对对象的读取，其原理与writeObject()方法相同。    再次执行SimpleSerial应用程序，则又会有如下输出：

arg constructor
[John, 31, MALE]

必须注意地是，writeObject()与readObject()都是private方法，那么它们是如何被调用的呢？毫无疑问，是使用反射。详情可见ObjectOutputStream中的writeSerialData方法，以及ObjectInputStream中的readSerialData方法。

**5.3 Externalizable接口**

无论是使用transient关键字，还是使用writeObject()和readObject()方法，其实都是基于Serializable接口的序列化。JDK中提供了另一个序列化接口--Externalizable，使用该接口之后，之前基于Serializable接口的序列化机制就将失效。此时将Person类修改成如下，


    public class Person implements Externalizable {
    private String name = null;
    transient private Integer age = null;
    private Gender gender = null;
    public Person() {
        System.out.println("none-arg constructor");
    }
    public Person(String name, Integer age, Gender gender) {
        System.out.println("arg constructor");
        this.name = name;
        this.age = age;
        this.gender = gender;
    }
    private void writeObject(ObjectOutputStream out) throws IOException {
        out.defaultWriteObject();
        out.writeInt(age);
    }
    private void readObject(ObjectInputStream in) throws IOException, ClassNotFoundException {
        in.defaultReadObject();
        age = in.readInt();
    }
    @Override
    public void writeExternal(ObjectOutput out) throws IOException {
    }
    @Override
    public void readExternal(ObjectInput in) throws IOException, ClassNotFoundException {
    }
    ...
    }

此时再执行SimpleSerial程序之后会得到如下结果：

    arg constructor
    none-arg constructor
    [null, null, null]

从该结果，一方面可以看出Person对象中任何一个字段都没有被序列化。另一方面，如果细心的话，还可以发现这此次序列化过程调用了Person类的无参构造器。    Externalizable继承于Serializable，当使用该接口时，序列化的细节需要由程序员去完成。如上所示的代码，由于writeExternal()与readExternal()方法未作任何处理，那么该序列化行为将不会保存/读取任何一个字段。这也就是为什么输出结果中所有字段的值均为空。    另外，若使用Externalizable进行序列化，当读取对象时，会调用被序列化类的无参构造器去创建一个新的对象，然后再将被保存对象的字段的值分别填充到新对象中。这就是为什么在此次序列化过程中Person类的无参构造器会被调用。由于这个原因，实现Externalizable接口的类必须要提供一个无参的构造器，且它的访问权限为public。    对上述Person类作进一步的修改，使其能够对name与age字段进行序列化，但要忽略掉gender字段，如下代码所示：


    public class Person implements Externalizable {
    private String name = null;
    transient private Integer age = null;
    private Gender gender = null;
    public Person() {
        System.out.println("none-arg constructor");
    }
    public Person(String name, Integer age, Gender gender) {
        System.out.println("arg constructor");
        this.name = name;
        this.age = age;
        this.gender = gender;
    }
    private void writeObject(ObjectOutputStream out) throws IOException {
        out.defaultWriteObject();
        out.writeInt(age);
    }
    private void readObject(ObjectInputStream in) throws IOException, ClassNotFoundException {
        in.defaultReadObject();
        age = in.readInt();
    }
    @Override
    public void writeExternal(ObjectOutput out) throws IOException {
        out.writeObject(name);
        out.writeInt(age);
    }
    @Override
    public void readExternal(ObjectInput in) throws IOException, ClassNotFoundException {
        name = (String) in.readObject();
        age = in.readInt();
    }
    ...
    }
执行SimpleSerial之后会有如下结果：
    arg constructor
    none-arg constructor
    [John, 31, null]

**5.4 readResolve()方法**
    当我们使用Singleton模式时，应该是期望某个类的实例应该是唯一的，但如果该类是可序列化的，那么情况可能会略有不同。此时对第2节使用的Person类进行修改，使其实现Singleton模式，如下所示：

    public class Person implements Serializable {
    private static class InstanceHolder {
        private static final Person instatnce = new Person("John", 31, Gender.MALE);
    }
    public static Person getInstance() {
        return InstanceHolder.instatnce;
    }
    private String name = null;
    private Integer age = null;
    private Gender gender = null;
    private Person() {
        System.out.println("none-arg constructor");
    }
    private Person(String name, Integer age, Gender gender) {
        System.out.println("arg constructor");
        this.name = name;
        this.age = age;
        this.gender = gender;
    } 
    }


同时要修改SimpleSerial应用，使得能够保存/获取上述单例对象，并进行对象相等性比较，如下代码所示：

    public class SimpleSerial {
    public static void main(String[] args) throws Exception {
        File file = new File("person.out");
        ObjectOutputStream oout = new ObjectOutputStream(new FileOutputStream(file));
        oout.writeObject(Person.getInstance()); // 保存单例对象
        oout.close();
        ObjectInputStream oin = new ObjectInputStream(new FileInputStream(file));
        Object newPerson = oin.readObject();
        oin.close();
        System.out.println(newPerson);
        System.out.println(Person.getInstance() == newPerson); // 将获取的对象与Person类中的单例对象进行相等性比较
    }
    }

执行上述应用程序后会得到如下结果：
    arg constructor
    [John, 31, MALE]
    false

值得注意的是，从文件person.out中获取的Person对象与Person类中的单例对象并不相等。为了能在序列化过程仍能保持单例的特性，可以在Person类中添加一个readResolve()方法，在该方法中直接返回Person的单例对象，如下所示：

    public class Person implements Serializable {
    private static class InstanceHolder {
        private static final Person instatnce = new Person("John", 31, Gender.MALE);
    }
    public static Person getInstance() {
        return InstanceHolder.instatnce;
    }
    private String name = null;
    private Integer age = null;
    private Gender gender = null;
    private Person() {
        System.out.println("none-arg constructor");
    }
    private Person(String name, Integer age, Gender gender) {
        System.out.println("arg constructor");
        this.name = name;
        this.age = age;
        this.gender = gender;
    }
    private Object readResolve() throws ObjectStreamException {
        return InstanceHolder.instatnce;
    }
    }

再次执行本节的SimpleSerial应用后将有如下输出：

    arg constructor
    [John, 31, MALE]
    true
无论是实现Serializable接口，或是Externalizable接口，当从I/O流中读取对象时，readResolve()方法都会被调用到。实际上就是用readResolve()中返回的对象直接替换在反序列化过程中创建的对象，而被创建的对象则会被垃圾回收掉。

**6.serialVersionUID的作用**

　s​e​r​i​a​l​V​e​r​s​i​o​n​U​I​D​:​ ​字​面​意​思​上​是​序​列​化​的​版​本​号​，凡是实现Serializable接口的类都有一个表示序列化版本标识符的静态变量

    private static final long serialVersionUID

实现Serializable接口的类如果类中没有添加serialVersionUID，那么就会出现如下的警告提示
　　![](http://upload-images.jianshu.io/upload_images/1703251-2ec1b131c7d4d93b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
　　用鼠标点击![](http://upload-images.jianshu.io/upload_images/1703251-b470612cc02c170d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)就会弹出生成serialVersionUID的对话框，如下图所示：
　　![](http://upload-images.jianshu.io/upload_images/1703251-4f4f2270980f0390.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
　　serialVersionUID有两种生成方式：
　　采用![](http://upload-images.jianshu.io/upload_images/1703251-7a0ecf109239af8b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)这种方式生成的serialVersionUID是1L，例如：

    private static final long serialVersionUID = 1L;

采用![](http://upload-images.jianshu.io/upload_images/1703251-f370faa2a6fd8331.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)这种方式生成的serialVersionUID是根据类名，接口名，方法和属性等来生成的，例如：

     private static final long serialVersionUID = 4603642343377807741L;

添加了之后就不会出现那个警告提示了，如下所示：

　![](http://upload-images.jianshu.io/upload_images/1703251-96014999618e9f55.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
扯了那么多，那么serialVersionUID(序列化版本号)到底有什么用呢，我们用如下的例子来说明一下serialVersionUID的作用，看下面的代码：


    import java.io.File;
    import java.io.FileInputStream;
    import java.io.FileNotFoundException;
    import java.io.FileOutputStream;
    import java.io.IOException;
    import java.io.ObjectInputStream;
    import java.io.ObjectOutputStream;
    import java.io.Serializable;

    public class TestSerialversionUID {

    public static void main(String[] args) throws Exception {
        SerializeCustomer();// 序列化Customer对象
        Customer customer = DeserializeCustomer();// 反序列Customer对象
        System.out.println(customer);
    }

    /**
     * MethodName: SerializeCustomer 
     * Description: 序列化Customer对象
     * @author xudp
     * @throws FileNotFoundException
     * @throws IOException
     */
    private static void SerializeCustomer() throws FileNotFoundException,
            IOException {
        Customer customer = new Customer("gacl",25);
        // ObjectOutputStream 对象输出流
        ObjectOutputStream oo = new ObjectOutputStream(new FileOutputStream(
                new File("E:/Customer.txt")));
        oo.writeObject(customer);
        System.out.println("Customer对象序列化成功！");
        oo.close();
    }

    /**
     * MethodName: DeserializeCustomer 
     * Description: 反序列Customer对象
     * @author xudp
     * @return
     * @throws Exception
     * @throws IOException
     */
    private static Customer DeserializeCustomer() throws Exception, IOException {
        ObjectInputStream ois = new ObjectInputStream(new FileInputStream(
                new File("E:/Customer.txt")));
        Customer customer = (Customer) ois.readObject();
        System.out.println("Customer对象反序列化成功！");
        return customer;
    }
    }

    /**
     * <p>ClassName: Customer<p>
     * <p>Description: Customer实现了Serializable接口，可以被序列化<p>
     * @author xudp
     * @version 1.0 V
     * @createTime 2014-6-9 下午04:20:17
     */
    class Customer implements Serializable {
    //Customer类中没有定义serialVersionUID
    private String name;
    private int age;

    public Customer(String name, int age) {
        this.name = name;
        this.age = age;
    }

    /*
     * @MethodName toString
     * @Description 重写Object类的toString()方法
     * @author xudp
     * @return string
     * @see java.lang.Object#toString()
     */
    @Override
    public String toString() {
        return "name=" + name + ", age=" + age;
    }
    }

运行结果：
![](http://upload-images.jianshu.io/upload_images/1703251-e9918b5191d8e526.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)![](http://upload-images.jianshu.io/upload_images/1703251-0310fae4423e2d8c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
序列化和反序列化都成功了。
下面我们修改一下Customer类，添加多一个sex属性，如下：

    class Customer implements Serializable {
        //Customer类中没有定义serialVersionUID
        private String name;
        private int age;

        //新添加的sex属性
        private String sex;
    
    public Customer(String name, int age) {
        this.name = name;
        this.age = age;
    }
    
    public Customer(String name, int age,String sex) {
        this.name = name;
        this.age = age;
        this.sex = sex;
    }

    /*
     * @MethodName toString
     * @Description 重写Object类的toString()方法
     * @author xudp
     * @return string
     * @see java.lang.Object#toString()
     */
    @Override
    public String toString() {
        return "name=" + name + ", age=" + age;
    }
    }

然后执行反序列操作，此时就会抛出如下的异常信息：

     Exception in thread "main" java.io.InvalidClassException: Customer;
     local class incompatible: 
     stream classdesc serialVersionUID = -88175599799432325,
     local class serialVersionUID = -5182532647273106745

意思就是说，文件流中的class和classpath中的class，也就是修改过后的class，不兼容了，处于安全机制考虑，程序抛出了错误，并且拒绝载入。那么如果我们真的有需求要在序列化后添加一个字段或者方法呢？应该怎么办？那就是自己去指定serialVersionUID。在TestSerialversionUID例子中，没有指定Customer类的serialVersionUID的，那么java编译器会自动给这个class进行一个摘要算法，类似于指纹算法，只要这个文件 多一个空格，得到的UID就会截然不同的，可以保证在这么多类中，这个编号是唯一的。所以，添加了一个字段后，由于没有显指定 serialVersionUID，编译器又为我们生成了一个UID，当然和前面保存在文件中的那个不会一样了，于是就出现了2个序列化版本号不一致的错误。因此，只要我们自己指定了serialVersionUID，就可以在序列化后，去添加一个字段，或者方法，而不会影响到后期的还原，还原后的对象照样可以使用，而且还多了方法或者属性可以用。

下面继续修改Customer类，给Customer指定一个serialVersionUID，修改后的代码如下：

    class Customer implements Serializable {
    /**
     * Customer类中定义的serialVersionUID(序列化版本号)
     */
    private static final long serialVersionUID = -5182532647273106745L;
    private String name;
    private int age;

    //新添加的sex属性
    //private String sex;
    
    public Customer(String name, int age) {
        this.name = name;
        this.age = age;
    }
    
    /*public Customer(String name, int age,String sex) {
        this.name = name;
        this.age = age;
        this.sex = sex;
    }*/

    /*
     * @MethodName toString
     * @Description 重写Object类的toString()方法
     * @author xudp
     * @return string
     * @see java.lang.Object#toString()
     */
    @Override
    public String toString() {
        return "name=" + name + ", age=" + age;
    }
    }

重新执行序列化操作，将Customer对象序列化到本地硬盘的Customer.txt文件存储，然后修改Customer类，添加sex属性，修改后的Customer类代码如下：

    class Customer implements Serializable {
    /**
     * Customer类中定义的serialVersionUID(序列化版本号)
     */
    private static final long serialVersionUID = -5182532647273106745L;
    private String name;
    private int age;

    //新添加的sex属性
    private String sex;
    
    public Customer(String name, int age) {
        this.name = name;
        this.age = age;
    }
    
    public Customer(String name, int age,String sex) {
        this.name = name;
        this.age = age;
        this.sex = sex;
    }

    /*
     * @MethodName toString
     * @Description 重写Object类的toString()方法
     * @author xudp
     * @return string
     * @see java.lang.Object#toString()
     */
    @Override
    public String toString() {
        return "name=" + name + ", age=" + age;
    }
    }

执行反序列操作，这次就可以反序列成功了，如下所示：
　　![](http://upload-images.jianshu.io/upload_images/1703251-4d3bdea8b1206f6e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

**7.serialVersionUID的取值**

serialVersionUID的取值是Java运行时环境根据类的内部细节自动生成的。如果对类的源代码作了修改，再重新编译，新生成的类文件的serialVersionUID的取值有可能也会发生变化。

类的serialVersionUID的默认值完全依赖于Java编译器的实现，对于同一个类，用不同的Java编译器编译，有可能会导致不同的 serialVersionUID，也有可能相同。**为了提高serialVersionUID的独立性和确定性，强烈建议在一个可序列化类中显示的定义serialVersionUID，为它赋予明确的值**。

显式地定义serialVersionUID有两种用途：
　　1、 在某些场合，希望类的不同版本对序列化兼容，因此需要确保类的不同版本具有相同的serialVersionUID；
　　2、 在某些场合，不希望类的不同版本对序列化兼容，因此需要确保类的不同版本具有不同的serialVersionUID。


----
#### 转载自：
[理解Java对象序列化](http://www.blogjava.net/jiangshachina/archive/2012/02/13/369898.html)
[Java基础学习总结——Java对象的序列化和反序列化](http://www.cnblogs.com/xdp-gacl/p/3777987.html)
