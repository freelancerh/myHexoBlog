---
title: InputStreamReader源码分析
date: 2015-05-12 11:27:31
categories: java
tags: [java,java io,java源码]
photos: 
- /uploads/image/cover/wz12.jpg
---
我们的机器只会读字节码，而我们人却很难读懂字节码，所以人与机器交流过程中需要编码解码。
InputStreamReader及其子类FileReader：（从字节到字符）是个解码过程；
OutputStreamWrite及其子类FileWriter：（从字符到字节）是个编码过程。
InputStreamReader这个解码过程中，最主要的就是StreamDecoder类
<center>
![](/uploads/image/reference/InputStreamReader%E6%9E%B6%E6%9E%84.jpg)
</center>

InputStream到Reader的过程要指定编码字符集，否则将采用操作系统默认字符集，很可能会出现乱码问题。（查看JDK中的InputStreamReader类的构造函数，除了第一个构造函数没有制定外，其他几个都需要指定）


     public class InputStreamReader extends Reader {
     /**
      InputStreamReader的方法主要依靠StreamDecoder 来实现*/
    private final StreamDecoder sd;

    /**
     *用默认的字符集
     */
    public InputStreamReader(InputStream in) {
        super(in);
        try {
            sd = StreamDecoder.forInputStreamReader(in, this, (String)null); // ## check lock object
        } catch (UnsupportedEncodingException e) {
            // The default encoding should always be available
            throw new Error(e);
        }
    }

    /**
     * 用字符集的名字构造InputStreamReader
     */
    public InputStreamReader(InputStream in, String charsetName)
        throws UnsupportedEncodingException
    {
        super(in);
        if (charsetName == null)
            throw new NullPointerException("charsetName");
        sd = StreamDecoder.forInputStreamReader(in, this, charsetName);
    }

    /**
     *用给定字符集的对象来构造
     */
    public InputStreamReader(InputStream in, Charset cs) {
        super(in);
        if (cs == null)
            throw new NullPointerException("charset");
        sd = StreamDecoder.forInputStreamReader(in, this, cs);
    }

    /**
     * 用给定的字符集解码器来构造
     */
    public InputStreamReader(InputStream in, CharsetDecoder dec) {
        super(in);
        if (dec == null)
            throw new NullPointerException("charset decoder");
        sd = StreamDecoder.forInputStreamReader(in, this, dec);
    }

    /**
     * 返回字符集的名字，通过StreamDecoder对象
     */
    public String getEncoding() {
        return sd.getEncoding();
    }

    /**
     * 读取当个字符
     */
    public int read() throws IOException {
        return sd.read();
    }

    /**
     * 读取多个字符到字符数组
     */
    public int read(char cbuf[], int offset, int length) throws IOException {
        return sd.read(cbuf, offset, length);
    }

    /**
     * 判断流是否准备好读取
     * 如果保证下一个 read() 不阻塞输入，则返回 True，否则返回 false。注意，返回 false 并不保证阻塞下一次读取。
     */
    public boolean ready() throws IOException {
        return sd.ready();
    }
    /**
      *关闭流
      */
    public void close() throws IOException {
        sd.close();
    }
    }
