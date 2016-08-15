---
title: 浅析java多线程
date: 2015-05-20 11:27:31
categories: java
tags: [java, java多线程]
photos: 
- http://7xlbns.com1.z0.glb.clouddn.com/%40%2Fhihuaning%2Fimage%2Flb%2Flb3.jpg
---

首先讲一下进程和线程的区别：
　　进程：每个进程都有独立的代码和数据空间（进程上下文），进程间的切换会有较大的开销，一个进程包含1~n个线程。
　　线程：同一类线程共享代码和数据空间，每个线程有独立的运行栈和程序计数器(PC)，线程切换开销小。
　　线程和进程一样分为五个阶段：创建、就绪、运行、阻塞、终止。
　　多进程是指操作系统能同时运行多个任务（程序）。
　　多线程是指在同一程序中有多个顺序流在执行。

## 1. 线程状态转换
 <br/>
![](http://7xlbns.com1.z0.glb.clouddn.com/%40%2Fhihuaning%2Freference%2F%E7%BA%BF%E7%A8%8B%E7%8A%B6%E6%80%81%E8%BD%AC%E6%8D%A2%E5%9B%BE.jpg)

　　线程从创建到最终的消亡，要经历若干个状态。一般来说，线程包括以下这几个状态：创建(new)、就绪(runnable)、运行(running)、阻塞(blocked)、等待队列、锁池状态、消亡（dead）。

　　当需要新起一个线程来执行某个子任务时，就创建了一个线程。但是线程创建之后，不会立即进入就绪状态，因为线程的运行需要一些条件（比如内存资源，在JVM内存区域划分中知道程序计数器、Java栈、本地方法栈都是线程私有的，所以需要为线程分配一定的内存空间），只有线程运行需要的所有条件满足了，才进入就绪状态。

　　当线程进入就绪状态后，不代表立刻就能获取CPU执行时间，也许此时CPU正在执行其他的事情，因此它要等待。当得到CPU执行时间之后，线程便真正进入运行状态。

　　线程在运行状态过程中，可能有多个原因导致当前线程不继续运行下去，比如用户主动让线程睡眠（睡眠一定的时间之后再重新执行）、用户主动让线程等待，或者被同步块给阻塞，此时就对应着多个状态：等待队列（睡眠或等待一定的事件）、锁池状态（等待被唤醒）、blocked（阻塞）。

　　当由于突然中断或者子任务执行完毕，线程就会被消亡。

#### 1.1 初始状态
　　实现Runnable接口和继承Thread可以得到一个线程类，new一个实例出来，线程就进入了初始状态

#### 1.2 可运行状态
　　1，可运行状态只是说你资格运行，调度程序没有挑选到你，你就永远是可运行状态。
　　2，调用线程的start()方法，此线程进入可运行状态。
　　3，当前线程sleep()方法结束，其他线程join()结束，等待用户输入完毕，某个线程拿到对象锁，这些线程也将进入可运行状态。
　　4，当前线程时间片用完了，调用当前线程的yield()方法，当前线程进入可运行状态。
　　5，锁池里的线程拿到对象锁后，进入可运行状态。

#### 1.3 运行状态
　　1，线程调度程序从可运行池中选择一个线程作为当前线程时线程所处的状态。这也是线程进入运行状态的唯一一种方式。

### 1.4 死亡状态
　　1，当线程的run()方法完成时，或者主线程的main()方法完成时，我们就认为它死去。这个线程对象也许是活的，但是，它已经不是一个单独执行的线程。线程一旦死亡，就不能复生。
　　2，在一个死去的线程上调用start()方法，会抛出java.lang.IllegalThreadStateException异常。

#### 1.5 阻塞状态
　　1，当前线程T调用Thread.sleep()方法，当前线程进入阻塞状态。
　　2，运行在当前线程里的其它线程t2调用join()方法，当前线程进入阻塞状态。
　　3，等待用户输入的时候，当前线程进入阻塞状态。
#### 1.6 等待队列(本是Object里的方法，但影响了线程)
　　1，调用obj的wait(), notify()方法前，必须获得obj锁，也就是必须写在synchronized(obj) 代码段内。后面会详细讲到wait和notify方法。

#### 1.7 锁池状态
　　1，当前线程想调用对象A的同步方法时，发现对象A的锁被别的线程占有，此时当前线程进入锁池状态。简言之，锁池里面放的都是想争夺对象锁的线程。
　　2，当一个线程1被另外一个线程2唤醒时，1线程进入锁池状态，去争夺对象锁。
　　3，锁池是在同步的环境下才有的概念，一个对象对应一个锁池。

## 2. 上下文切换


　　对于单核CPU来说（对于多核CPU，此处就理解为一个核），CPU在一个时刻只能运行一个线程，当在运行一个线程的过程中转去运行另外一个线程，这个叫做线程上下文切换（对于进程也是类似）。
　　由于可能当前线程的任务并没有执行完毕，所以在切换时需要保存线程的运行状态，以便下次重新切换回来时能够继续切换之前的状态运行。举个简单的例子：比如一个线程A正在读取一个文件的内容，正读到文件的一半，此时需要暂停线程A，转去执行线程B，当再次切换回来执行线程A的时候，我们不希望线程A又从文件的开头来读取。
　　因此需要记录线程A的运行状态，那么会记录哪些数据呢？因为下次恢复时需要知道在这之前当前线程已经执行到哪条指令了，所以需要记录程序计数器的值，另外比如说线程正在进行某个计算的时候被挂起了，那么下次继续执行的时候需要知道之前挂起时变量的值时多少，因此需要记录CPU寄存器的状态。所以一般来说，线程上下文切换过程中会记录程序计数器、CPU寄存器状态等数据。
　　说简单点的：对于线程的上下文切换实际上就是 存储和恢复CPU状态的过程，它使得线程执行能够从中断点恢复执行。
　　虽然多线程可以使得任务执行的效率得到提升，但是由于在线程切换时同样会带来一定的开销代价，并且多个线程会导致系统资源占用的增加，所以在进行多线程编程时要注意这些因素。

## 3. wait()、notify()和notifyAll()

wait()、notify()和notifyAll()是Object类中的方法：

    /**
     * Wakes up a single thread that is waiting on this object's
     * monitor. If any threads are waiting on this object, one of them
     * is chosen to be awakened. The choice is arbitrary and occurs at
     * the discretion of the implementation. A thread waits on an object's
     * monitor by calling one of the wait methods
     */
    public final native void notify();
 
    /**
     * Wakes up all threads that are waiting on this object's monitor. A
     * thread waits on an object's monitor by calling one of the
     * wait methods.
     */
    public final native void notifyAll();
 
    /**
     * Causes the current thread to wait until either another thread invokes the
     * {@link java.lang.Object#notify()} method or the
     * {@link java.lang.Object#notifyAll()} method for this object, or a
     * specified amount of time has elapsed.
     * <p>
     * The current thread must own this object's monitor.
     */
    public final native void wait(long timeout) throws InterruptedException;

　从这三个方法的文字描述可以知道以下几点信息：

　　1）wait()、notify()和notifyAll()方法是本地方法，并且为final方法，无法被重写。

　　2）调用某个对象的wait()方法能让当前线程阻塞，并且当前线程必须拥有此对象的monitor（即锁）

　　3）调用某个对象的notify()方法能够唤醒一个正在等待这个对象的monitor的线程，如果有多个线程都在等待这个对象的monitor，则只能唤醒其中一个线程；

　　4）调用notifyAll()方法能够唤醒所有正在等待这个对象的monitor的线程；

　　有朋友可能会有疑问：为何这三个不是Thread类声明中的方法，而是Object类中声明的方法（当然由于Thread类继承了Object类，所以Thread也可以调用者三个方法）？其实这个问题很简单，由于每个对象都拥有monitor（即锁），所以让当前线程等待某个对象的锁，当然应该通过这个对象来操作了。而不是用当前线程来操作，因为当前线程可能会等待多个线程的锁，如果通过线程来操作，就非常复杂了。

　　上面已经提到，如果调用某个对象的wait()方法，当前线程必须拥有这个对象的monitor（即锁），因此调用wait()方法必须在同步块或者同步方法中进行（synchronized块或者synchronized方法）。

　　调用某个对象的wait()方法，相当于让当前线程交出此对象的monitor，然后进入等待状态，等待后续再次获得此对象的锁（Thread类中的sleep方法使当前线程暂停执行一段时间，从而让其他线程有机会继续执行，但它并不释放对象锁）；

　　notify()方法能够唤醒一个正在等待该对象的monitor的线程，当有多个线程都在等待该对象的monitor的话，则只能唤醒其中一个线程，具体唤醒哪个线程则不得而知。

　　同样地，调用某个对象的notify()方法，当前线程也必须拥有这个对象的monitor，因此调用notify()方法必须在同步块或者同步方法中进行（synchronized块或者synchronized方法）。

　　nofityAll()方法能够唤醒所有正在等待该对象的monitor的线程，这一点与notify()方法是不同的。

　　这里要注意一点：notify()和notifyAll()方法只是唤醒等待该对象的monitor的线程，并不决定哪个线程能够获取到monitor。

　　举个简单的例子：假如有三个线程Thread1、Thread2和Thread3都在等待对象objectA的monitor，此时Thread4拥有对象objectA的monitor，当在Thread4中调用objectA.notify()方法之后，Thread1、Thread2和Thread3只有一个能被唤醒。注意，被唤醒不等于立刻就获取了objectA的monitor。假若在Thread4中调用objectA.notifyAll()方法，则Thread1、Thread2和Thread3三个线程都会被唤醒，至于哪个线程接下来能够获取到objectA的monitor就具体依赖于操作系统的调度了。

　　上面尤其要注意一点，一个线程被唤醒不代表立即获取了对象的monitor，只有等调用完notify()或者notifyAll()并退出synchronized块，释放对象锁后，其余线程才可获得锁执行。

下面看一个例子就明白了：

    public class Test {
    public static Object object = new Object();
      public static void main(String[] args) {
        Thread1 thread1 = new Thread1();
        Thread2 thread2 = new Thread2();  
        thread1.start();
        try {
            Thread.sleep(200);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
         
        thread2.start();
    }
     
    static class Thread1 extends Thread{
        @Override
        public void run() {
            synchronized (object) {
                try {
                    object.wait();
                } catch (InterruptedException e) {
                }
                System.out.println("线程"+Thread.currentThread().getName()+"获取到了锁");
            }
        }
    }
     
    static class Thread2 extends Thread{
        @Override
        public void run() {
            synchronized (object) {
                object.notify();
                System.out.println("线程"+Thread.currentThread().getName()+"调用了object.notify()");
                System.out.println("线程"+Thread.currentThread().getName()+"释放了锁");
            }
            
        }
    }
    }

无论运行多少次，运行结果必定是：

    线程Thread-1调用了object.notify()线程
    Thread-1释放了锁线程
    Thread-0获取到了锁

----
#### 转载自：
[多线程总结二：线程的状态转换](http://zy19982004.iteye.com/blog/1626916)
[Java并发编程：线程间协作的两种方式：wait、notify、notifyAll和Condition](http://www.cnblogs.com/dolphin0520/p/3920385.html)