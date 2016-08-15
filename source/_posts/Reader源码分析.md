---
title: Reader源码分析
date: 2015-05-10 11:27:31
categories: java
tags: [java,java io,java源码]
photos: 
- http://7xlbns.com1.z0.glb.clouddn.com/%40%2Fhihuaning%2Fimage%2Fwz10.jpg
---
针对字符数据的读取， Java SE 提供了 java.io.Reader 类，其抽象化了字符数据读入的来源。 

Reader的子类只需重写read(char[], int, int) 和 close()方法，但是一般子类为了提高效率会将其他非抽象的方法重写。

     public abstract class Reader implements Readable, Closeable {

    /**
     用来在流上同步操作的对象。为了提高效率，字符流对象可以使用其自身以外的对象来保护关键部分。
     因此，子类应使用此字段中的对象，而不是 this 或者同步的方法。
     */
    protected Object lock;

    /**
     其重要部分将同步其自身的reader
     */
    protected Reader() {
        this.lock = this;
    }

    /**
     *暂时有点不懂
     * Creates a new character-stream reader whose critical sections will
     * synchronize on the given object.
     */
    protected Reader(Object lock) {
        if (lock == null) {
            throw new NullPointerException();
        }
        this.lock = lock;
    }

    /**
      *试图将字符读入指定的字符缓冲区。缓冲区可照原样用作字符的存储库：所做的唯一改变是 put操作的结果。
      *不对缓冲区执行翻转或重绕操作。
      */
    public int read(java.nio.CharBuffer target) throws IOException {
        int len = target.remaining();
        char[] cbuf = new char[len];
        int n = read(cbuf, 0, len);
        if (n > 0)
            target.put(cbuf, 0, n);
        return n;
    }

    /**
     * 读取一个字符，这里的重载Read方法都基于read(char[], int, int)
     */
    public int read() throws IOException {
        char cb[] = new char[1];
        if (read(cb, 0, 1) == -1)
            return -1;
        else
            return cb[0];
    }

    public int read(char cbuf[]) throws IOException {
        return read(cbuf, 0, cbuf.length);
    }


    abstract public int read(char cbuf[], int off, int len) throws IOException;

    /*当执行skip时，表示能跳过的最大的字节个数*/
    private static final int maxSkipBufferSize = 8192;

    private char skipBuffer[] = null;

    /*skip方法使用了一个byte型的数组当做缓冲区，
     *重复地读取数据，直到读取了n个字节或者已经到了数据流的尾部。
     *鼓励用子类来重写这个方法以获得更高的效率。*/

    public long skip(long n) throws IOException {
        if (n < 0L)
            throw new IllegalArgumentException("skip value is negative");
        int nn = (int) Math.min(n, maxSkipBufferSize);
        synchronized (lock) {
            if ((skipBuffer == null) || (skipBuffer.length < nn))
                skipBuffer = new char[nn];
            long r = n;
            while (r > 0) {
                int nc = read(skipBuffer, 0, (int)Math.min(r, nn));
                if (nc == -1)
                    break;
                r -= nc;
            }
            return n - r;
        }
    }

    /**
     * 判断该字符流是否已经准备好读取。
     */
    public boolean ready() throws IOException {
        return false;
    }

    public boolean markSupported() {
        return false;
    }


    public void mark(int readAheadLimit) throws IOException {
        throw new IOException("mark() not supported");
    }


    public void reset() throws IOException {
        throw new IOException("reset() not supported");
    }

     abstract public void close() throws IOException;
    }