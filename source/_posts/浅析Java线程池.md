---
title: 浅析Java线程池
date: 2015-08-05 11:27:31
categories: java
tags: [java, java多线程, 线程池]
photos: 
- http://7xlbns.com1.z0.glb.clouddn.com/%40%2Fhihuaning%2Fimage%2Flb%2Flb17.jpg
---

合理利用线程池能够带来三个好处。第一：降低资源消耗。通过重复利用已创建的线程降低线程创建和销毁造成的消耗。第二：提高响应速度。当任务到达时，任务可以不需要的等到线程创建就能立即执行。第三：提高线程的可管理性。线程是稀缺资源，如果无限制的创建，不仅会消耗系统资源，还会降低系统的稳定性，使用线程池可以进行统一的分配，调优和监控。但是要做到合理的利用线程池，必须对其原理了如指掌。

 ### 1.  线程池的使用
   #### 线程池的创建
 我们可以通过ThreadPoolExecutor来创建一个线程池。

     new ThreadPoolExecutor(corePoolSize, maximumPoolSize, keepAliveTime, milliseconds, runnableTaskQueue, threadFactory,handler);

创建一个线程池需要输入几个参数：
* **corePoolSize**：核心池的大小，这个参数跟后面讲述的线程池的实现原理有非常大的关系。在创建了线程池后，默认情况下，线程池中并没有任何线程，而是等待有任务到来才创建线程去执行任务，除非调用了prestartAllCoreThreads()或者prestartCoreThread()方法，从这2个方法的名字就可以看出，是预创建线程的意思，即在没有任务到来之前就创建corePoolSize个线程或者一个线程。默认情况下，在创建了线程池后，线程池中的线程数为0，当有任务来之后，就会创建一个线程去执行任务，当线程池中的线程数目达到corePoolSize后，就会把到达的任务放到缓存队列当中；
* **maximumPoolSize**：线程池最大线程数，这个参数也是一个非常重要的参数，它表示在线程池中最多能创建多少个线程；
* **keepAliveTime**：表示线程没有任务执行时最多保持多久时间会终止。默认情况下，只有当线程池中的线程数大于corePoolSize时，keepAliveTime才会起作用，直到线程池中的线程数不大于corePoolSize，即当线程池中的线程数大于corePoolSize时，如果一个线程空闲的时间达到keepAliveTime，则会终止，直到线程池中的线程数不超过corePoolSize。但是如果调用了allowCoreThreadTimeOut(boolean)方法，在线程池中的线程数不大于corePoolSize时，keepAliveTime参数也会起作用，直到线程池中的线程数为0；
* **unit**：参数keepAliveTime的时间单位，有7种取值，在TimeUnit类中有7种静态属性：
       TimeUnit.DAYS;               //天
       TimeUnit.HOURS;             //小时
       TimeUnit.MINUTES;           //分钟
       TimeUnit.SECONDS;           //秒
       TimeUnit.MILLISECONDS;      //毫秒
       TimeUnit.MICROSECONDS;      //微妙
       TimeUnit.NANOSECONDS;       //纳秒
* **workQueue**：一个阻塞队列，用来存储等待执行的任务，这个参数的选择也很重要，会对线程池的运行过程产生重大影响，一般来说，这里的阻塞队列有以下几种选择：
      ArrayBlockingQueue;
      LinkedBlockingQueue;
      SynchronousQueue;
ArrayBlockingQueue和PriorityBlockingQueue使用较少，一般使用LinkedBlockingQueue和Synchronous。线程池的排队策略与BlockingQueue有关。
* **threadFactory**：线程工厂，主要用来创建线程；
* **handler**：表示当拒绝处理任务时的策略，有以下四种取值：
        ThreadPoolExecutor.AbortPolicy:丢弃任务并抛出RejectedExecutionException异常。 
        ThreadPoolExecutor.DiscardPolicy：也是丢弃任务，但是不抛出异常。
        ThreadPoolExecutor.DiscardOldestPolicy：丢弃队列最前面的任务，然后重新尝试执行任务（重复此过程）
        ThreadPoolExecutor.CallerRunsPolicy：由调用线程处理该任务 

   #### 向线程池提交任务
我们可以使用execute提交的任务，但是execute方法没有返回值，所以无法判断任务知否被线程池执行成功。通过以下代码可知execute方法输入的任务是一个Runnable类的实例。
       threadsPool.execute(new Runnable() {
        @Override
        public void run() {

        // TODO Auto-generated method stub

        }

        });
我们也可以使用submit 方法来提交任务，它会返回一个future,那么我们可以通过这个future来判断任务是否执行成功，通过future的get方法来获取返回值，get方法会阻塞住直到任务完成，而使用get(long timeout, TimeUnit unit)方法则会阻塞一段时间后立即返回，这时有可能任务没有执行完。
        try {

        Object s = future.get();

        } catch (InterruptedException e) {

        // 处理中断异常

        } catch (ExecutionException e) {

        // 处理无法执行任务异常

        } finally {

        // 关闭线程池

        executor.shutdown();

        }

   #### 线程池的关闭
我们可以通过调用线程池的shutdown或shutdownNow方法来关闭线程池，但是它们的实现原理不同，shutdown的原理是只是将线程池的状态设置成SHUTDOWN状态，然后中断所有没有正在执行任务的线程。shutdownNow的原理是遍历线程池中的工作线程，然后逐个调用线程的interrupt方法来中断线程，所以无法响应中断的任务可能永远无法终止。shutdownNow会首先将线程池的状态设置成STOP，然后尝试停止所有的正在执行或暂停任务的线程，并返回等待执行任务的列表。

    只要调用了这两个关闭方法的其中一个，isShutdown方法就会返回true。当所有的任务都已关闭后,才表示线程池关闭成功，这时调用isTerminaed方法会返回true。至于我们应该调用哪一种方法来关闭线程池，应该由提交到线程池的任务特性决定，通常调用shutdown来关闭线程池，如果任务不一定要执行完，则可以调用shutdownNow。

 ### 2.  线程池的分析
**流程分析**：线程池的主要工作流程如下图：
<center>
![](http://7xlbns.com1.z0.glb.clouddn.com/%40%2Fhihuaning%2Freference%2FJava%E7%BA%BF%E7%A8%8B%E6%B1%A0%E4%B8%BB%E8%A6%81%E5%B7%A5%E4%BD%9C%E6%B5%81%E7%A8%8B.jpg)
</center>
从上图我们可以看出，当提交一个新任务到线程池时，线程池的处理流程如下：
1.首先线程池判断**基本线程池**是否已满？没满，创建一个工作线程来执行任务。满了，则进入下个流程。
2.其次线程池判断**工作队列**是否已满？没满，则将新提交的任务存储在工作队列里。满了，则进入下个流程。
3.最后线程池判断**整个线程池**是否已满？没满，则创建一个新的工作线程来执行任务，满了，则交给饱和策略来处理这个任务。
**源码分析。**上面的流程分析让我们很直观的了解的线程池的工作原理，让我们再通过源代码来看看是如何实现的。线程池执行任务的方法如下：
        public void execute(Runnable command) {

        if (command == null)

        throw new NullPointerException();

        //如果线程数小于基本线程数，则创建线程并执行当前任务

        if (poolSize >= corePoolSize || !addIfUnderCorePoolSize(command)) {

        //如线程数大于等于基本线程数或线程创建失败，则将当前任务放到工作队列中。

        if (runState == RUNNING && workQueue.offer(command)) {

        if (runState != RUNNING || poolSize == 0)

        ensureQueuedTaskHandled(command);

        }

        //如果线程池不处于运行中或任务无法放入队列，并且当前线程数量小于最大允许的线程数量，则创建一个线程执行任务。

        else if (!addIfUnderMaximumPoolSize(command))

        //抛出RejectedExecutionException异常

        reject(command); // is shutdown or saturated

        }

        }

    **工作线程**。线程池创建线程时，会将线程封装成工作线程Worker，Worker在执行完任务后，还会无限循环获取工作队列里的任务来执行。我们可以从Worker的run方法里看到这点：
      public void run() {

      try {

           Runnable task = firstTask;

           firstTask = null;

            while (task != null || (task = getTask()) != null) {

                    runTask(task);

                    task = null;

            }

      } finally {

             workerDone(this);

      }

      }
 ### 3.  合理的配置线程池
要想合理的配置线程池，就必须首先分析任务特性，可以从以下几个角度来进行分析：
1.任务的性质：CPU密集型任务，IO密集型任务和混合型任务。
2.任务的优先级：高，中和低。
3.任务的执行时间：长，中和短。
4.任务的依赖性：是否依赖其他系统资源，如数据库连接。

  任务性质不同的任务可以用不同规模的线程池分开处理。CPU密集型任务配置尽可能少的线程数量，如配置Ncpu+1个线程的线程池。IO密集型任务则由于需要等待IO操作，线程并不是一直在执行任务，则配置尽可能多的线程，如2*Ncpu。混合型的任务，如果可以拆分，则将其拆分成一个CPU密集型任务和一个IO密集型任务，只要这两个任务执行的时间相差不是太大，那么分解后执行的吞吐率要高于串行执行的吞吐率，如果这两个任务执行时间相差太大，则没必要进行分解。我们可以通过Runtime.getRuntime().availableProcessors()方法获得当前设备的CPU个数。

  优先级不同的任务可以使用优先级队列PriorityBlockingQueue来处理。它可以让优先级高的任务先得到执行，需要注意的是如果一直有优先级高的任务提交到队列里，那么优先级低的任务可能永远不能执行。

  执行时间不同的任务可以交给不同规模的线程池来处理，或者也可以使用优先级队列，让执行时间短的任务先执行。

  依赖数据库连接池的任务，因为线程提交SQL后需要等待数据库返回结果，如果等待的时间越长CPU空闲时间就越长，那么线程数应该设置越大，这样才能更好的利用CPU。

  **建议使用有界队列**，有界队列能增加系统的稳定性和预警能力，可以根据需要设大一点，比如几千。有一次我们组使用的后台任务线程池的队列和线程池全满了，不断的抛出抛弃任务的异常，通过排查发现是数据库出现了问题，导致执行SQL变得非常缓慢，因为后台任务线程池里的任务全是需要向数据库查询和插入数据的，所以导致线程池里的工作线程全部阻塞住，任务积压在线程池里。如果当时我们设置成无界队列，线程池的队列就会越来越多，有可能会撑满内存，导致整个系统不可用，而不只是后台任务出现问题。当然我们的系统所有的任务是用的单独的服务器部署的，而我们使用不同规模的线程池跑不同类型的任务，但是出现这样问题时也会影响到其他任务。

 ### 4.  线程池的监控
**通过线程池提供的参数进行监控**。线程池里有一些属性在监控线程池的时候可以使用
  * **taskCount**：线程池需要执行的任务数量。
  * **completedTaskCount**：线程池在运行过程中已完成的任务数量。小于或等于taskCount。
  * **largestPoolSize**：线程池曾经创建过的最大线程数量。通过这个数据可以知道线程池是否满过。如等于线程池的最大大小，则表示线程池曾经满了。
  * **getPoolSize**:线程池的线程数量。如果线程池不销毁的话，池里的线程不会自动销毁，所以这个大小只增不减。
  * **getActiveCount**：获取活动的线程数。

  **通过扩展线程池进行监控**。通过继承线程池并重写线程池的beforeExecute，afterExecute和terminated方法，我们可以在任务执行前，执行后和线程池关闭前干一些事情。如监控任务的平均执行时间，最大执行时间和最小执行时间等。这几个方法在线程池里是空方法。如：
      protected  void beforeExecute(Thread t, Runnable r) { }

----
#### 转载自：
[聊聊并发（三）Java线程池的分析和使用](http://ifeve.com/java-threadpool/)
[Java并发编程：线程池的使用](http://www.cnblogs.com/dolphin0520/p/3932921.html)