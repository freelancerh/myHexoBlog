---
title: 多线程打印abc问题
date: 2015-05-21 11:27:31
categories: java
tags: [java, java多线程]
photos: 
- http://7xlbns.com1.z0.glb.clouddn.com/%40%2Fhihuaning%2Fimage%2Flb%2Flb4.jpg
---

   这道题让我想到了操作系统中学的pv操作，下面我先写出这道题pv操作的伪代码。
  
    main(){
	int s1 = 1;
	int s2 = 0;
	int s3 = 0;
	cobegin
		methoda();
		methodb();
		methodc();
	coend
    }

    methoda(){
	p(s1);
	print("a");
	v(s2);
    }

    methodb(){
	p(s2);
	print("b");
	v(s3);
    }

    methodc(){
	p(s3);
	print("c");
	v(s1);
    }

下面是java写的代码，可以看到两者之间的原理还是相似的。

    package ThreadTest;

    public class ThreadPrinter extends Thread{

	Object pre;
	Object self;
	String name;
	
	public ThreadPrinter(String name,Object pre, Object self){
		this.name = name;
		this.pre = pre;
		this.self = self;
	}
	
	public void run(){
		int count = 10;
		while(count > 0){
			synchronized(pre){
				synchronized(self){
					System.out.println(name);
					self.notify();
				}
				try {
					pre.wait();
				} catch (InterruptedException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				count--;
			}
		}
	}
	
	public static void main(String[] args) throws InterruptedException{
		Object a = new Object();
		Object b = new Object();
		Object c = new Object();
		Thread thread1 = new ThreadPrinter("a", a, b);
		thread1.start();
		Thread.currentThread().sleep(1000);
		Thread thread2 = new ThreadPrinter("b", b, c);
		thread2.start();
		Thread.currentThread().sleep(1000);
		Thread thread3 = new ThreadPrinter("c", c, a);
		thread3.start();
		
	}

    }

对于多线程打印abc问题还可以参考这里
[面试题--三个线程循环打印ABC10次的几种解决方法](http://www.tuicool.com/articles/2mqI7n)
[三线程顺序打印N次ABC](http://freejvm.iteye.com/blog/604245)

---
#### 参考自：
[Java多线程学习（吐血超详细总结）](http://blog.csdn.net/evankaka/article/details/44153709)