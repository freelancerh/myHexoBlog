---
title: StringReader源码分析
date: 2015-05-09 11:27:31
categories: java
tags: [java,java io,java源码]
photos: 
- /uploads/image/cover/wz8.jpg
---
 StringReader 可以将字符串打包，当作读取来源， StringWriter 则可以作为写入目的地，最后用 toString() 取得所有写入的字符组成的字符串。 CharArrayReader 、 CharArrayWriter 则类似，将 char 数组当作读取来源以及写入目的地。这几个类的结构和实现差不多，所以我以StringReader为例分析了这些常用的Reader，Writer子类。

     /*StringReader类是一个以String数据源的字符流*/
     public class StringReader extends Reader {

    private String str;
    private int length;
    private int next = 0;
    private int mark = 0;


    public StringReader(String s) {
        this.str = s;
        this.length = s.length();
    }

    /**确保Stream没有被关闭 */
    private void ensureOpen() throws IOException {
        if (str == null)
            throw new IOException("Stream closed");
    }

    /**读取当个字符*/
    public int read() throws IOException {
        synchronized (lock) {
            ensureOpen();
            if (next >= length)
                return -1;
            return str.charAt(next++);
        }
    }

    /**读取多个字符到cbuf[]里，返回读取的字符个数*/
    public int read(char cbuf[], int off, int len) throws IOException {
        synchronized (lock) {
            ensureOpen();
            if ((off < 0) || (off > cbuf.length) || (len < 0) ||
                ((off + len) > cbuf.length) || ((off + len) < 0)) {
                throw new IndexOutOfBoundsException();
            } else if (len == 0) {
                return 0;
            }
            if (next >= length)
                return -1;
            int n = Math.min(length - next, len);
            str.getChars(next, next + n, cbuf, off);
            next += n;
            return n;
        }
    }

    /**跳过ns个字符，这个方法比较特别，因为ns可以为负数，即它可以向前跳过ns个字符，
    如何实现的呢？原因就在 n = Math.max(-next, n);这条语句里*/
    public long skip(long ns) throws IOException {
        synchronized (lock) {
            ensureOpen();
            if (next >= length)
                return 0;
            // Bound skip by beginning and end of the source
            long n = Math.min(length - next, ns);
            n = Math.max(-next, n);
            next += n;
            return n;
        }
    }

    public boolean ready() throws IOException {
        synchronized (lock) {
        ensureOpen();
        return true;
        }
    }

    /**支持mark方法*/
    public boolean markSupported() {
        return true;
    }

    public void mark(int readAheadLimit) throws IOException {
        if (readAheadLimit < 0){
            throw new IllegalArgumentException("Read-ahead limit < 0");
        }
        synchronized (lock) {
            ensureOpen();
            mark = next;
        }
    }

    public void reset() throws IOException {
        synchronized (lock) {
            ensureOpen();
            next = mark;
        }
    }

    /**实现了Closeable接口，而其父接口有事AutoCloseable接口，故它可以自动关闭数据流，不过这是JDK7以后才有的*/
    public void close() {
        str = null;
    }
    }