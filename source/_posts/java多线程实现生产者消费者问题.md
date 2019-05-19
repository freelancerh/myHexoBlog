---
title: java多线程实现生产者消费者问题
date: 2015-05-22 11:27:31
categories: java
tags: [java, java多线程]
photos: 
- /uploads/image/cover/lb5.jpg
---

思想可以参考操作系统里的pv操作实现生产者消费者问题
    package ThreadTest;

    import java.util.PriorityQueue;

    public class ProducerAndComsumer {
	static int queueSize = 20;
	static PriorityQueue<Integer> queue = new PriorityQueue<Integer>(queueSize);
	
	public static void main(String[] args){
		Thread thread1 = new Producer();
		Thread thread2 = new Comsumer();
		thread1.start();
		thread2.start();
	}
	
	static class Producer extends Thread{
		public void run(){
			produce();
		}
		
		public void produce(){
			while(true){
				synchronized(queue){
					while(queue.size() == queueSize){
						try {
							System.out.println("队列已满");
							queue.wait();
						} catch (InterruptedException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
					}
					queue.offer((int)Math.floor(Math.random()*100));
					queue.notify();
					System.out.println("加入一个元素至队列，剩余空间为" + (queueSize- queue.size()));
				}
			}
			
		}
	}
	
	static class Comsumer extends Thread{
		public void run(){
			comsume();
		}
		
		public void comsume(){
			while(true){
				synchronized(queue){
					while(queue.size() == 0){
						System.out.println("队列元素为空，等待读取");
						try {
							queue.wait();
						} catch (InterruptedException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
					}
					
					int value = queue.poll();
					queue.notify();
					System.out.println("读出一个值"+value);
				}
			}
		}
	}
}
