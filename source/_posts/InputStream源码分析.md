---
title: InputStream源码分析(jdk1.8)
date: 2015-05-08 11:27:31
categories: java
tags: [java,java源码,java io]
photos: /uploads/wz3.jpg
---
InputStream类是所有字节输入流类的超类，它是一个抽象类。

    package java.io;
    public abstract class InputStream implements Closeable {
    /*当执行skip时，表示能跳过的最大的字节个数*/
    private static final int MAX_SKIP_BUFFER_SIZE = 2048;

    public abstract int read() throws IOException;

    public int read(byte b[]) throws IOException {
        return read(b, 0, b.length);
    }

    /*这里所有的重载的read方法都基于read()这个方法，而read()是个抽象方法，依赖具体的子类来实现，
    这里典型的使用到了设计模式里的模板方法模式*/

    public int read(byte b[], int off, int len) throws IOException {
        if (b == null) {
            throw new NullPointerException();
        } else if (off < 0 || len < 0 || len > b.length - off) {
            throw new IndexOutOfBoundsException();
        } else if (len == 0) {
            return 0;
        }

        int c = read();
        if (c == -1) {
            return -1;
        }
        b[off] = (byte)c;

        int i = 1;
        try {
            for (; i < len ; i++) {
                c = read();
                if (c == -1) {
                    break;
                }
                b[off + i] = (byte)c;
            }
        } catch (IOException ee) {
        }
        return i;
    }

    /*skip方法使用了一个byte型的数组当做缓冲区，
    重复地读取数据，直到读取了n个字节或者已经到了数据流的尾部。
    鼓励用子类来重写这个方法以获得更高的效率。*/

    public long skip(long n) throws IOException {

        long remaining = n;
        int nr;

        if (n <= 0) {
            return 0;
        }

        int size = (int)Math.min(MAX_SKIP_BUFFER_SIZE, remaining);
        byte[] skipBuffer = new byte[size];
        while (remaining > 0) {
            nr = read(skipBuffer, 0, (int)Math.min(size, remaining));
            if (nr < 0) {
                break;
            }
            remaining -= nr;
        }

        return n - remaining;
    }

    /* 返回下一次对此输入流调用的方法可以不受阻塞地从此输入流读取（或跳过）的估计剩余字节数。    
     某些子类会返回流的所有字节数，有些不会。根据这个返回值来分配一个缓冲区来存取流中的所有数据是不对的。  
     子类需要重写该方法。    
    */
    public int available() throws IOException {
        return 0;
    }

    
    public void close() throws IOException {}

    //标记这个输入流的当前位置
    public synchronized void mark(int readlimit) {}

    //最后一次调用这个输入流上的mark方法时复位这个流
    public synchronized void reset() throws IOException {
        throw new IOException("mark/reset not supported");
    }

    // 查看输入流是否支持mark和reset方法。对于某个特定的流实例来说，是否支持mark和reset方法是不变的属性。  
    public boolean markSupported() {
        return false;
      }
    }