

<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [Java深度历险（八）——Java I/O](#java深度历险八java-io)
* [2@JNI探秘-----FileInputStream的read方法详解](#2jni探秘-fileinputstream的read方法详解)
* [2@JAVA-FileInputStream之read方法](#2java-fileinputstream之read方法)
* [Java IO详解（二)------流的分类](#java-io详解二-流的分类)
* [2@Java IO详解（三)------字节输入输出流](#2java-io详解三-字节输入输出流)
* [2@eclipse报错：Error: A JNI error has occurred_](#2eclipse报错error-a-jni-error-has-occurred_)
* [Java IO详解（四)------字符输入输出流](#java-io详解四-字符输入输出流)
* [Java IO详解（五)------包装流](#java-io详解五-包装流)
* [Java IO详解（六)------序列化与反序列化（对象流）](#java-io详解六-序列化与反序列化对象流)
* [Java IO详解（七)------随机访问文件流](#java-io详解七-随机访问文件流)

<!-- /code_chunk_output -->




18.4 Reader和Writer

# Java深度历险（八）——Java I/O 

* [Java深度历险（八）——Java I/O ](http://www.infoq.com/cn/articles/cf-java-i-o/)



在应用程序中，通常会涉及到两种类型的计算：CPU计算和I/O计算。对于大多数应用来说，花费在等待I/O上的时间是占较大比重的。通常需要等待速度较慢的磁盘或是网络连接完成I/O请求，才能继续后面的CPU计算任务。因此提高I/O操作的效率对应用的性能有较大的帮助。本文将介绍Java语言中与I/O操作相关的内容，包括基本的Java I/O和Java NIO，着重于基本概念和最佳实践。
流
Java语言提供了多个层次不同的概念来对I/O操作进行抽象。Java I/O中最早的概念是流，包括输入流和输出流，早在JDK 1.0中就存在了。简单的来说，流是一个连续的字节的序列。输入流是用来读取这个序列，而输出流则构建这个序列。InputStream和OutputStream所操纵的基本单元就是字节。每次读取和写入单个字节或是字节数组。如果从字节的层次来处理数据类型的话，操作会非常繁琐。可以用更易使用的流实现来包装基本的字节流。如果想读取或输出Java的基本数据类型，可以使用DataInputStream和DataOutputStream。它们所提供的类似readFloat和writeDouble这样的方法，会让处理基本数据类型变得很简单。如果希望读取或写入的是Java中的对象的话，可以使用ObjectInputStream和ObjectOutputStream。它们与对象的序列化机制一起，可以实现Java对象状态的持久化和数据传递。基本流所提供的对于输入和输出的控制比较弱。InputStream只提供了顺序读取、跳过部分字节和标记/重置的支持，而OutputStream则只能顺序输出。
流的使用
由于I/O操作所对应的实体在系统中都是有限的资源，需要妥善的进行管理。每个打开的流都需要被正确的关闭以释放资源。所遵循的原则是谁打开谁释放。如果一个流只在某个方法体内使用，则通过finally语句或是JDK 7中的try-with-resources语句来确保在方法返回之前，流被正确的关闭。如果一个方法只是作为流的使用者，就不需要考虑流的关闭问题。典型的情况是在servlet实现中并不需要关闭HttpServletResponse中的输出流。如果你的代码需要负责打开一个流，并且需要在不同的对象之间进行传递的话，可以考虑使用Execute Around Method模式。如下面的代码所示：
public void use(StreamUser user) {
    InputStream input = null;
    try {
        input = open();
        user.use(input);
    } catch(IOException e) {
        user.onError(e);
    } finally {
        if (input != null) {
            try { 
                input.close();
            } catch (IOException e) {
                user.onError(e);
            }
        }
    }
 } 
如上述代码中所看到的一样，由专门的类负责流的打开和关闭。流的使用者StreamUser并不需要关心资源释放的细节，只需要对流进行操作即可。
在使用输入流的过程中，经常会遇到需要复用一个输入流的情况，即多次读取一个输入流中的内容。比如通过URL.openConnection方法打开了一个远端站点连接的输入流，希望对其中的内容进行多次处理。这就需要把一个InputStream对象在多个对象中传递。为了保证每个使用流的对象都能获取到正确的内容，需要对流进行一定的处理。通常有两种解决的办法，一种是利用InputStream的标记支持。如果一个流支持标记的话（通过markSupported方法判断），就可以在流开始的地方通过mark方法添加一个标记，当完成一次对流的使用之后，通过reset方法就可以把流的读取位置重置到上次标记的位置，即流开始的地方。如此反复，就可以复用这个输入流。大部分输入流的实现是不支持标记的。可以通过BufferedInputStream进行包装来支持标记。
private InputStream prepareStream(InputStream ins) {
    BufferedInputStream buffered = new BufferedInputStream(ins);
    buffered.mark(Integer.MAX_VALUE);
    return buffered;
} 
private void resetStream(InputStream ins) throws IOException {
    ins.reset();
    ins.mark(Integer.MAX_VALUE);
}  
如上面的代码所示，通过prepareStream方法可以用一个BufferedInputStream来包装基本的InputStream。通过 mark方法在流开始的时候添加一个标记，允许读入Integer.MAX_VALUE个字节。每次流使用完成之后，通过resetStream方法重置即可。
另外一种做法是把输入流的内容转换成字节数组，进而转换成输入流的另外一个实现ByteArrayInputStream。这样做的好处是使用字节数组作为参数传递的格式要比输入流简单很多，可以不需要考虑资源相关的问题。另外也可以尽早的关闭原始的输入流，而无需等待所有使用流的操作完成。这两种做法的思路其实是相似的。BufferedInputStream在内部也创建了一个字节数组来保存从原始输入流中读入的内容。
private byte[] saveStream(InputStream input) throws IOException {
    ByteBuffer buffer = ByteBuffer.allocate(1024);
    ReadableByteChannel readChannel = Channels.newChannel(input);
    ByteArrayOutputStream output = new ByteArrayOutputStream(32 * 1024);
    WritableByteChannel writeChannel = Channels.newChannel(output);
    while ((readChannel.read(buffer)) > 0 || buffer.position() != 0) {
        buffer.flip();
        writeChannel.write(buffer);
        buffer.compact();
    }
    return output.toByteArray();
}   
上面的代码中saveStream方法把一个InputStream保存为字节数组。
缓冲区
由于流背后的数据有可能比较大，在实际的操作中，通常会使用缓冲区来提高性能。传统的缓冲区的实现是使用数组来完成。比如经典的从InputStream到OutputStream的复制的实现，就是使用一个字节数组作为中间的缓冲区。NIO中引入的Buffer类及其子类，可以很方便的用来创建各种基本数据类型的缓冲区。相对于数组而言，Buffer类及其子类提供了更加丰富的方法来对其中的数据进行操作。后面会提到的通道也使用Buffer类进行数据传递。
在Buffer上进行的元素添加和删除操作，都围绕3个属性position、limit和capacity展开，分别表示Buffer当前的读写位置、可用的读写范围和容量限制。容量限制是在创建的时候指定的。Buffer提供的get/put方法都有相对和绝对两种形式。相对读写时的位置是相对于position的值，而绝对读写则需要指定起始的序号。在使用Buffer的常见错误就是在读写操作时没有考虑到这3个元素的值，因为大多数时候都是使用的是相对读写操作，而position的值可能早就发生了变化。一些应该注意的地方包括：将数据读入缓冲区之前，需要调用clear方法；将缓冲区中的数据输出之前，需要调用flip方法。
ByteBuffer buffer = ByteBuffer.allocate(32);
CharBuffer charBuffer = buffer.asCharBuffer();
String content = charBuffer.put("Hello ").put("World").flip().toString();
System.out.println(content);  
上面的代码展示了Buffer子类的使用。首先可以在已有的ByteBuffer上面创建出其它数据类型的缓冲区视图，其次Buffer子类的很多方法是可以级联的，最后是要注意flip方法的使用。
字符与编码
在程序中，总是免不了与字符打交道，毕竟字符是用户直接可见的信息。而与字符处理直接相关的就是编码。相信不少人都曾经为了程序中的乱码问题而困扰。要弄清楚这个问题，就需要理解字符集和编码的概念。字符集，顾名思义，就是字符的集合。一个字符集中所包含的字符通常与地区和语言有关。字符集中的每个字符通常会有一个整数编码与其对应。常见的字符集有ASCII、ISO-8859-1和Unicode等。对于字符集中的每个字符，为了在计算机中表示，都需要转换某种字节的序列，即该字符的编码。同一个字符集可以有不同的编码方式。如果某种编码格式产生的字节序列，用另外一种编码格式来解码的话，就可能会得到错误的字符，从而产生乱码的情况。所以将一个字节序列转换成字符串的时候，需要知道正确的编码格式。
NIO中的java.nio.charset包提供了与字符集相关的类，可以用来进行编码和解码。其中的CharsetEncoder和CharsetDecoder允许对编码和解码过程进行精细的控制，如处理非法的输入以及字符集中无法识别的字符等。通过这两个类可以实现字符内容的过滤。比如应用程序在设计的时候就只支持某种字符集，如果用户输入了其它字符集中的内容，在界面显示的时候就是乱码。对于这种情况，可以在解码的时候忽略掉无法识别的内容。
String input = "你123好";
Charset charset = Charset.forName("ISO-8859-1");
CharsetEncoder encoder = charset.newEncoder();
encoder.onUnmappableCharacter(CodingErrorAction.IGNORE);
CharsetDecoder decoder = charset.newDecoder();
CharBuffer buffer = CharBuffer.allocate(32);
buffer.put(input);
buffer.flip();
try {
    ByteBuffer byteBuffer = encoder.encode(buffer);
    CharBuffer cbuf = decoder.decode(byteBuffer);
    System.out.println(cbuf);  //输出123
} catch (CharacterCodingException e) {
    e.printStackTrace();
}  
 
上面的代码中，通过使用ISO-8859-1字符集的编码和解码器，就可以过滤掉字符串中不在此字符集中的字符。
Java I/O在处理字节流字之外，还提供了处理字符流的类，即Reader/Writer类及其子类，它们所操纵的基本单位是char类型。在字节和字符之间的桥梁就是编码格式。通过编码器来完成这两者之间的转换。在创建Reader/Writer子类实例的时候，总是应该使用两个参数的构造方法，即显式指定使用的字符集或编码解码器。如果不显式指定，使用的是JVM的默认字符集，有可能在其它平台上产生错误。
通道
通道作为NIO中的核心概念，在设计上比之前的流要好不少。通道相关的很多实现都是接口而不是抽象类。通道本身的抽象层次也更加合理。通道表示的是对支持I/O操作的实体的一个连接。一旦通道被打开之后，就可以执行读取和写入操作，而不需要像流那样由输入流或输出流来分别进行处理。与流相比，通道的操作使用的是Buffer而不是数组，使用更加方便灵活。通道的引入提升了I/O操作的灵活性和性能，主要体现在文件操作和网络操作上。
文件通道
对文件操作方面，文件通道FileChannel提供了与其它通道之间高效传输数据的能力，比传统的基于流和字节数组作为缓冲区的做法，要来得简单和快速。比如下面的把一个网页的内容保存到本地文件的实现。
FileOutputStream output = new FileOutputStream("baidu.txt");
FileChannel channel = output.getChannel();
URL url = new URL("http://www.baidu.com");
InputStream input = url.openStream();
ReadableByteChannel readChannel = Channels.newChannel(input);
channel.transferFrom(readChannel, 0, Integer.MAX_VALUE);   
文件通道的另外一个功能是对文件的部分片段进行加锁。当在一个文件上的某个片段加上了排它锁之后，其它进程必须等待这个锁释放之后，才能访问该文件的这个片段。文件通道上的锁是由JVM所持有的，因此适合于与其它应用程序协同时使用。比如当多个应用程序共享某个配置文件的时候，如果Java程序需要更新此文件，则可以首先获取该文件上的一个排它锁，接着进行更新操作，再释放锁即可。这样可以保证文件更新过程中不会受到其它程序的影响。
另外一个在性能方面有很大提升的功能是内存映射文件的支持。通过FileChannel的map方法可以创建出一个MappedByteBuffer对象，对这个缓冲区的操作都会直接反映到文件内容上。这点尤其适合对大文件进行读写操作。
套接字通道
在套接字通道方面的改进是提供了对非阻塞I/O和多路复用I/O的支持。传统的流的I/O操作是阻塞式的。在进行I/O操作的时候，线程会处于阻塞状态等待操作完成。NIO中引入了非阻塞I/O的支持，不过只限于套接字I/O操作。所有继承自SelectableChannel的通道类都可以通过configureBlocking方法来设置是否采用非阻塞模式。在非阻塞模式下，程序可以在适当的时候查询是否有数据可供读取。一般是通过定期的轮询来实现的。
多路复用I/O是一种新的I/O编程模型。传统的套接字服务器的处理方式是对于每一个客户端套接字连接，都新创建一个线程来进行处理。创建线程是很耗时的操作，而有的实现会采用线程池。不过一个请求一个线程的处理模型并不是很理想。原因在于耗费时间创建的线程，在大部分时间可能处于等待的状态。而多路复用I/O的基本做法是由一个线程来管理多个套接字连接。该线程会负责根据连接的状态，来进行相应的处理。多路复用I/O依靠操作系统提供的select或相似系统调用的支持，选择那些已经就绪的套接字连接来处理。可以把多个非阻塞I/O通道注册在某个Selector上，并声明所感兴趣的操作类型。每次调用Selector的select方法，就可以选择到某些感兴趣的操作已经就绪的通道的集合，从而可以进行相应的处理。如果要执行的处理比较复杂，可以把处理转发给其它的线程来执行。
下面是一个简单的使用多路复用I/O的服务器实现。当有客户端连接上的时候，服务器会返回一个Hello World作为响应。
private static class IOWorker implements Runnable {
    public void run() {
        try {
            Selector selector = Selector.open();
            ServerSocketChannel channel = ServerSocketChannel.open();
            channel.configureBlocking(false);
            ServerSocket socket = channel.socket();
            socket.bind(new InetSocketAddress("localhost", 10800));
            channel.register(selector, channel.validOps());
            while (true) {
                selector.select();
                Iterator iterator = selector.selectedKeys().iterator();
                while (iterator.hasNext()) {
                    SelectionKey key = iterator.next();
                    iterator.remove();
                    if (!key.isValid()) {
                        continue;
                    }
                    if (key.isAcceptable()) {
                        ServerSocketChannel ssc = (ServerSocketChannel) key.channel();
                        SocketChannel sc = ssc.accept();
                        sc.configureBlocking(false);
                        sc.register(selector, sc.validOps()); 
                    }
                    if (key.isWritable()) {
                        SocketChannel client = (SocketChannel) key.channel();
                        Charset charset = Charset.forName("UTF-8");
                        CharsetEncoder encoder = charset.newEncoder();
                        CharBuffer charBuffer = CharBuffer.allocate(32);
                        charBuffer.put("Hello World");
                        charBuffer.flip();
                        ByteBuffer content = encoder.encode(charBuffer);
                        client.write(content);
                        key.cancel();
                    }
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}

上面的代码给出的只是非常简单的示例程序，只是展示了多路复用I/O的基本使用方式。在开发复杂网络应用程序的时候，使用一些Java NIO网络应用框架会让你事半功倍。目前来说最流行的两个框架是Apache MINA和Netty。在使用了Netty之后，Twitter的搜索功能速度提升达到了3倍之多。网络应用开发人员都可以使用这两个开源的优秀框架。
参考资料
•	Java 6 I/O-related APIs & Developer Guides
•	Top Ten New Things You Can Do with NIO
•	Building Highly Scalable Servers with Java NIO
________________________________________
感谢张凯峰对本文的策划和审校。
给InfoQ中文站投稿或者参与内容翻译工作，请邮件至editors@cn.infoq.com。也欢迎大家加入到InfoQ中文站用户讨论组中与我们的编辑和其他读者朋友交流。




# 2@JNI探秘-----FileInputStream的read方法详解

2@JNI探秘-----FileInputStream的read方法详解
 - Java's paradise - 博客频道 - CSDN.NET 
http://blog.csdn.net/zuoxiaolong8810/article/details/9974525



 作者：zuoxiaolong8810（左潇龙），转载请注明出处。
             上一章我们已经分析过FileInputStream的构建过程，接下来我们就来看一下read方法的读取过程。
             我们先来看下FileInputStream中的四个有关read的方法的源码，如下。
[java] view plain copy
1.	   public native int read() throws IOException;  
2.	  
3.	   private native int readBytes(byte b[], int off, int len) throws IOException;  
4.	  
5.	   public int read(byte b[]) throws IOException {  
6.	return readBytes(b, 0, b.length);  
7.	   }  
8.	  
9.	   public int read(byte b[], int off, int len) throws IOException {  
10.	return readBytes(b, off, len);  
11.	   }  
             可以看到，其中有两个本地方法，两个不是本地方法，但是还是内部还是调用的本地方法，那么我们研究的重点就是这两个本地方法到底是如何实现的。
             下面是这两个本地方法的源码，非常简单，各位请看。
[cpp] view plain copy
1.	JNIEXPORT jint JNICALL  
2.	Java_java_io_FileInputStream_read(JNIEnv *env, jobject this) {  
3.	    return readSingle(env, this, fis_fd);//每一个本地的实例方法默认的两个参数，JNI环境与对象的实例  
4.	}  
5.	  
6.	JNIEXPORT jint JNICALL  
7.	Java_java_io_FileInputStream_readBytes(JNIEnv *env, jobject this,  
8.	        jbyteArray bytes, jint off, jint len) {//除了前两个参数，后三个就是readBytes方法传递进来的，字节数组、起始位置、长度三个参数  
9.	    return readBytes(env, this, bytes, off, len, fis_fd);  
10.	}  
             可以看到，这两个本地方法的实现只是将任务又转给了两个方法，readSingle和ReadBytes，请注意，在调用这两个方法时，除了常用的env和this对象，以及从JAVA环境传过来的参数之外，还多了一个参数fis_fd，这个对象就是上一章中FileInputStream类中的fd属性的内存地址偏移量了。
             那么下面我们首先来看readSingle方法的实现，如下。
[cpp] view plain copy
1.	/* 
2.	    env和this参数就不再解释了 
3.	    fid就是FileInputStream类中fd属性的内存地址偏移量 
4.	    通过fid和this实例可以获取FileInputStream类中fd属性的内存地址 
5.	*/  
6.	jint  
7.	readSingle(JNIEnv *env, jobject this, jfieldID fid) {  
8.	    jint nread;//存储读取后返回的结果值  
9.	    char ret;//存储读取出来的字符  
10.	    FD fd = GET_FD(this, fid);//这个获取到的FD其实就是之前handle属性的值，也就是文件的句柄  
11.	    if (fd == -1) {  
12.	        JNU_ThrowIOException(env, "Stream Closed");  
13.	        return -1;//如果文件句柄等于-1，说明文件流已关闭  
14.	    }  
15.	    nread = (jint)IO_Read(fd, &ret, 1);//读取一个字符，并且赋给ret变量  
16.	    //以下根据返回的int值判断读取的结果  
17.	    if (nread == 0) { /* EOF */  
18.	        return -1;//代表流已到末尾，返回-1  
19.	    } else if (nread == JVM_IO_ERR) { /* error */  
20.	        JNU_ThrowIOExceptionWithLastError(env, "Read error");//IO错误  
21.	    } else if (nread == JVM_IO_INTR) {  
22.	        JNU_ThrowByName(env, "java/io/InterruptedIOException", NULL);//被打断  
23.	    }  
24.	    return ret & 0xFF;//与0xFF做按位的与运算，去除高于8位bit的位  
25.	}  
         可以看到，这个方法其实最关键的就是IO_Read这个宏定义的处理，而IO_Read其实只是代表了一个方法名称叫handleRead，我们去看一下handleRead的源码。
[cpp] view plain copy
1.	/* 
2.	    fd就是handle属性的值 
3.	    buf是收取读取内容的数组 
4.	    len是读取的长度，可以看到，这个参数传进来的是1 
5.	    函数返回的值代表的是实际读取的字符长度 
6.	*/  
7.	JNIEXPORT  
8.	size_t  
9.	handleRead(jlong fd, void *buf, jint len)  
10.	{  
11.	    DWORD read = 0;  
12.	    BOOL result = 0;  
13.	    HANDLE h = (HANDLE)fd;  
14.	    if (h == INVALID_HANDLE_VALUE) {//如果句柄是无效的，则返回-1  
15.	        return -1;  
16.	    }  
17.	    //这里ReadFile又是一个现有的函数，和上一章的CreateFile是一样的  
18.	    //都是WIN API的函数，可以百度搜索它的作用与参数详解，理解它并不难  
19.	    result = ReadFile(h,          /* File handle to read */  //文件句柄  
20.	                      buf,        /* address to put data */  //存放数据的地址  
21.	                      len,        /* number of bytes to read */  //要读取的长度  
22.	                      &read,      /* number of bytes read */  //实际读取的长度  
23.	                      NULL);      /* no overlapped struct */  //只有对文件进行重叠操作时才需要传值  
24.	    if (result == 0) {//如果没读取出来东西，则判断是到了文件末尾返回0，还是报错了返回-1  
25.	        int error = GetLastError();  
26.	        if (error == ERROR_BROKEN_PIPE) {  
27.	            return 0; /* EOF */  
28.	        }  
29.	        return -1;  
30.	    }  
31.	    return read;  
32.	}  
         到此，基本上就完全看完了无参数的read方法的源码，它的原理其实很简单，就是利用handle这个句柄，使用ReadFile的WIN API函数读取了一个字符，不过值得注意的是，这些都是windows系统下的实现方式，所以不可认为这些源码代表了所有系统下的情况。
         然而对于带有参数的read方法，其原理与无参read方法是一样的，而且最终也是调用的handleRead这个方法，只是读取的长度不再是1而已。
         由此可以看出，文件输入流只是已只读方式打开了一个文件流，而且这个文件流只能依次向后读取，因为在之前的设计模式系列装饰器模式一文中，LZ已经提到过，对于FileInputStream进行包装而支持回退，标记重置等操作的输入流，都只是在内存里创建缓冲区造成的假象，我们真正的文件输入流是不支持这些操作的。
         好了，有关FileInputstream的源码内容就分享到此了，如果有兴趣的猿友，可以继续看一下其它的本地方法是如何实现的。
         感谢各位的收看。



# 2@JAVA-FileInputStream之read方法 

2@JAVA-FileInputStream之read方法 
http://www.360doc.com/content/15/0826/09/10504424_494788720.shtml


JAVA-FileInputStream之read方法 - 绿翼 - 博客园 http://www.cnblogs.com/Hfly/p/4759132.html


今天一个友询问FileInputStrem方法的read()和read(byte b) 方法为什么都用-1来判断读文件结束的问题，在此和大家一起学习下。
关于FileInputStream
它用于读取本地文件中的字节数据，继承自InputStream类，由于所有的文件都是以字节为向导，因此它适用于操作于任何形式的文件。
      关于其最重要的两个方法Read()和Read(byte b) 怎么使用呢？首先我们来查看API文档：
read（）
public int read() throws IOException
从此输入流中读取一个数据字节。如果没有输入可用，则此方法将阻塞。 
指定者：
类 InputStream 中的 read
返回：
下一个数据字节；如果已到达文件末尾，则返回 -1。 
 解读:
1、此方法是从输入流中读取一个数据的字节，通俗点讲，即每调用一次read方法，从FileInputStream中读取一个字节。
2、返回下一个数据字节，如果已达到文件末尾，返回-1,这点除看难以理解，通过代码测试理解不难。
      3、如果没有输入可用，则此方法将阻塞。这不用多解释，大家在学习的时候，用到的Scannner sc = new Scanner(System.in);其中System.in就是InputStream(为什么？不明白的,请到System.class查阅in是个什么东西！！),大家都深有体会,执行到此句代码时，将等待用户输入。
既然说可以测试任意形式的文件，那么用两种不同格式的，测试文件data1.txt和data2.txt，里面均放入1个数字"1"，两文件的格式分别为：ANSI和Unicode。
编写一下代码测试：
 
package com.gxlee;

import java.io.FileInputStream;
import java.io.IOException;

 

public class Test {
    public static void main(String[] args) throws IOException {
       
     FileInputStream fis = new FileInputStream("data1.txt");//ANSI格式
     for (int i = 0; i < 5; i++) {
         System.out.println(fis.read());    
     }
     
     fis.close();    
     System.out.println("------------------");
     fis = new FileInputStream("data2.txt");//Unicode格式
     for (int i = 0; i < 5; i++) {
         System.out.println(fis.read());    
     }
     fis.close();
    }
}
 
 
49
-1
-1
-1
-1
------------------
255
254
49
0
-1
 
结果怎么会是这样呢？
1.因为ANSI编码没有文件头,因此数字字符1只占一个字节,并且1的Ascii码为49因此输出49,而Unicode格式有2个字节的文件头，并且以2个字节表示一个字符,对于Ascii字符对应的字符则是第2位补0,因此1的Unicode码的两位十进制分别为49和0;
附:文本文件各格式文件头:ANSI类型:什么都没有,UTF-8类型：EF  BB  BF,UNICODE类型:FF FE,UNICODE BIG ENDIAN类型:FE FF
2.从返回的结果来看，返回的是当前的字节数据，API文档中原文为:"下一个数据字节，如果已到达文件末尾，则返回 -1。"(英文原文为:the next byte of data, or -1 if the end of the file is reached)，应该理解成:此时的指针在下一个数据字节的开始位置。如下图示意:
  
因此对于未知长度的文件即可通过读取到的内容是否为-1来确定读取是否结束，以下是代码片段：
int b;
 while(-1!=(b=fis.read())){
    System.err.println(b);
}
read(byte b)
同样看API：
 
public int read(byte[] b) throws IOException
从此输入流中将最多 b.length 个字节的数据读入一个 byte 数组中。在某些输入可用之前，此方法将阻塞。 
覆盖：
类 InputStream 中的 read
参数：
b - 存储读取数据的缓冲区。 
返回：
读入缓冲区的字节总数，如果因为已经到达文件末尾而没有更多的数据，则返回 -1。 
 

解读:
1、最多b.length个字节的数据读入一个byte数据组中，即，最多将byte数组b填满;
2、返回读入缓冲的字节总数，如果因为已经到达文件末尾而没有更多的数据，则返回-1。这里即这为朋友的问题点，为什么用-1来判断文件的结束。他的理由为,假设3个字节源数据，用2个字节的数组来缓存，当第2次读取的时候到达了文件的结尾，此时应该返回-1了,岂不是只读取到了2个字节？
同样，我们来测试：
测试文件，data.txt,文件格式ANSI,文件内容123,测试代码：
 
package com.gxlee;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.Arrays;

 

public class Test {
    public static void main(String[] args) throws IOException {
     FileInputStream fis = new FileInputStream("data.txt");//ANSI格式
     byte[] b = new byte[2];
     for (int i = 0; i < 3; i++) {
         System.out.print("第"+(i+1)+"次读取返回的结果:"+fis.read(b));
         System.out.println(",读取后数组b的内容为:"+Arrays.toString(b));
    }
     fis.close();
    }
}
 
输出结果：
第1次读取返回的结果:2,读取后数组b的内容为:[49, 50]
第2次读取返回的结果:1,读取后数组b的内容为:[51, 50]
第3次读取返回的结果:-1,读取后数组b的内容为:[51, 50]
测试数据文件采用的是ANSI格式，放入3个数字，因此为3个字节，这里测试读3次，从代码中可以看出，b为一个byte数组,大小为2，即每次可以存放2个字节。那么问题来了，第一次读取的时候读到2个字节返回很好理解，而第2次的时候,由于只剩下一个字节，此处到了文件的结尾，按照朋友对API文档的理解,应该返回-1才对？
 API文档只是对源代码的一种文字说明，具体的意思视阅读者的理解能力有偏差，那么我们来看源代码吧？
 public int read(byte b[]) throws IOException {
    return readBytes(b, 0, b.length);
 }
又调用了 readBytes方法，继续看该方法的源码:
private native int readBytes(byte b[], int off, int len) throws IOException;
晴天霹雳，是个被native修饰的方法,因此没办法继续一步看代码了。没啥好说的，用个代码类继承FileInputStream,覆盖read(byte b)方法，看代码即能理解：
 
package com.gxlee;


import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;

public class MyFileInputStream extends FileInputStream{

    public MyFileInputStream(String name) throws FileNotFoundException {
        super(name);
    }

    @Override
    public int read(byte[] b) throws IOException {
        int getData = read();
        if (getData==-1) {
            return -1;
        }else{
            b[0] = (byte)getData;
            for (int i = 1; i < b.length; i++) {
                getData = read();
                if(-1==getData)
                    return i;
                b[i] = (byte)getData;
            }
        }
        return b.length;
    }
}
 
原测试代码做小小的改动：
 
package com.gxlee;

 
import java.io.FileInputStream;
import java.util.Arrays;

public class Test {
    public static void main(String[] args) throws Exception {
        FileInputStream fis = new MyFileInputStream("data.txt");//ANSI格式
         byte[] b = new byte[2];
         for (int i = 0; i < 3; i++) {
             System.out.print("第"+(i+1)+"次读取返回的结果:"+fis.read(b));
             System.out.println(",读取后数组b的内容为:"+Arrays.toString(b));
        }
         fis.close();
        }
}
 
输出结果与原结果一致：
第1次读取返回的结果:2,读取后数组b的内容为:[49, 50]
第2次读取返回的结果:1,读取后数组b的内容为:[51, 50]
第3次读取返回的结果:-1,读取后数组b的内容为:[51, 50]
图示： 
 
大家对指针的理解，各自把握。
测试读取文本内容:
 
package com.gxlee;

 
import java.io.FileInputStream;

public class Test {
    public static void main(String[] args) throws Exception {
        FileInputStream fis = new MyFileInputStream("data.txt");//ANSI格式
         byte[] b = new byte[2];
         int len ;
         while (-1!=(len = fis.read(b))) {
             System.out.println(new String(b,0,len));
        }
         
         
         fis.close();
     }
}
 
准确输出文件内容：
12
3
原创内容，欢迎指点！




# Java IO详解（二)------流的分类

Java IO详解（二)------流的分类 - YSOcean - 博客园 
http://www.cnblogs.com/ysocean/p/6854098.html



Java IO详解（二)------流的分类
一、根据流向分为输入流和输出流：
注意输入流和输出流是相对于程序而言的。
输出：把程序(内存)中的内容输出到磁盘、光盘等存储设备中
 
 
     输入：读取外部数据（磁盘、光盘等存储设备的数据）到程序（内存）中
 
综合起来：
 
 
二、根据传输数据单位分为字节流和字符流
 
上面的也是 Java IO流中的四大基流。这四大基流都是抽象类，其他流都是继承于这四大基流的。
 
三、根据功能分为节点流和包装流
节点流：可以从或向一个特定的地方(节点)读写数据。如FileReader.
处理流：是对一个已存在的流的连接和封装，通过所封装的流的功能调用实现数据读写。如BufferedReader.处理流的构造方法总是要带一个其他的流对象做参数。一个流对象经过其他流的多次包装，称为流的链接。
 
 操作 IO 流的模板：
①、创建源或目标对象
输入：把文件中的数据流向到程序中，此时文件是 源，程序是目标
输出：把程序中的数据流向到文件中，此时文件是目标，程序是源
 
②、创建 IO 流对象
输入：创建输入流对象
输出：创建输出流对象
 
③、具体的 IO 操作
 
④、关闭资源
输入：输入流的 close() 方法
输出：输出流的 close() 方法
 
 
注意：1、程序中打开的文件 IO 资源不属于内存里的资源，垃圾回收机制无法回收该资源。如果不关闭该资源，那么磁盘的文件将一直被程序引用着，不能删除也不能更改。所以应该手动调用 close() 方法关闭流资源
 
最后这是 Java IO 流的整体架构图，下面几篇博客将会详细讲解这些流：
 
 
 
 
 
 
分类: Java SE



# 2@Java IO详解（三)------字节输入输出流

2@Java IO详解（三)------字节输入输出流
 - YSOcean - 博客园 
http://www.cnblogs.com/ysocean/p/6854541.html

File 类的介绍：http://www.cnblogs.com/ysocean/p/6851878.html
Java IO 流的分类介绍：http://www.cnblogs.com/ysocean/p/6854098.html
那么这篇博客我们讲的是字节输入输出流：InputStream、OutputSteam(下图红色长方形框内)，红色椭圆框内是其典型实现（FileInputSteam、FileOutStream）
 
 
1、字节输出流：OutputStream
1
2
3	public abstract class OutputStream
extends Object
implements Closeable, Flushable
这个抽象类是表示字节输出流的所有类的超类。 输出流接收输出字节并将其发送到某个接收器。
方法摘要：
 
 
下面我们用 字节输出流 OutputStream 的典型实现 FileOutputStream 来介绍：

  
2、字节输入流：InputStream
1
2
3	public abstract class InputStream
extends Object
implements Closeable
这个抽象类是表示输入字节流的所有类的超类。
方法摘要：
 
下面我们用 字节输出流 InputStream 的典型实现 FileInputStream 来介绍：

 



In.read(buffer, 0, 3)有问题


In.read(buffer)

 


调换in.read()和in.read(buffer, 0, 3)


 

 



 
3、用字节流完成文件的复制

 

 
分类: Java SE
标签: 字节输入输出流



# 2@eclipse报错：Error: A JNI error has occurred_

2@eclipse报错：Error: A JNI error has occurred_
百度知道 https://zhidao.baidu.com/question/938420195720630812



我的电脑上打开eclipse，在运行java源文件后直接报错了 ，这个怎么回事呢，把JDK重新安装一次还是如此，请问有什么解决方案吗
•	 
 
•	 
whyzc | 浏览 11482 次
推荐于2017-04-17 17:25:16
最佳答案
包命名问题。你自己定义的包路径以java开头造成。
java的类加载器在加载文件时，之前已经加载了以java开头的包路径，也就是rt.jar里面的内容。为了安全，会阻止自定义的包名以java开头。

# Java IO详解（四)------字符输入输出流

Java IO详解（四)------字符输入输出流
 - YSOcean - 博客园 http://www.cnblogs.com/ysocean/p/6859242.html



Java IO详解（四)------字符输入输出流
File 类的介绍：http://www.cnblogs.com/ysocean/p/6851878.html
Java IO 流的分类介绍：http://www.cnblogs.com/ysocean/p/6854098.html
Java IO 字节输入输出流：http://www.cnblogs.com/ysocean/p/6854541.html
那么这篇博客我们讲的是字节输入输出流：Reader、Writer(下图红色长方形框内)，红色椭圆框内是其典型实现（FileReader、FileWriter）
 
①、为什么要使用字符流？
因为使用字节流操作汉字或特殊符号语言的时候容易乱码，因为汉字不止一个字节，为了解决这个问题，建议使用字符流。
②、什么情况下使用字符流？
一般可以用记事本打开的文件，我们可以看到内容不乱码的。就是文本文件，可以使用字符流。而操作二进制文件（比如图片、音频、视频）必须使用字节流
 
 1、字符输出流：FileWriter
1
2
3	public abstract class Writer
extends Object
implements Appendable, Closeable, Flushable
用于写入字符流的抽象类
方法摘要：
 
下面我们用 字符输出流 Writer  的典型实现 FileWriter 来介绍这个类的用法：
 
	//1、创建源
        File srcFile = new File("io"+File.separator+"a.txt");
        //2、创建字符输出流对象
        Writer out = new FileWriter(srcFile);
        //3、具体的 IO 操作
            /***
             * void write(int c):向外写出一个字符
             * void write(char[] buffer):向外写出多个字符 buffer
             * void write(char[] buffer,int off,int len):把 buffer 数组中从索引 off 开始到 len个长度的数据写出去
             * void write(String str):向外写出一个字符串
             */
        //void write(int c):向外写出一个字符
        out.write(65);//将 A 写入 a.txt 文件中
        //void write(char[] buffer):向外写出多个字符 buffer
        out.write("Aa帅锅".toCharArray());//将 Aa帅锅 写入 a.txt 文件中
        //void write(char[] buffer,int off,int len)
        out.write("Aa帅锅".toCharArray(),0,2);//将 Aa 写入a.txt文件中
        //void write(String str):向外写出一个字符串
        out.write("Aa帅锅");//将 Aa帅锅 写入 a.txt 文件中
         
        //4、关闭流资源
        /***
         * 注意如果这里有一个 缓冲的概念，如果写入文件的数据没有达到缓冲的数组长度，那么数据是不会写入到文件中的
         * 解决办法：手动刷新缓冲区 flush()
         * 或者直接调用 close() 方法，这个方法会默认刷新缓冲区
         */
        out.flush();
        out.close();

 
 2、字符输入流：Reader
1
2
3	public abstract class Reader
extends Object
implements Readable, Closeable
用于读取字符流的抽象类。
方法摘要：
 
下面我们用 字符输入流 Reader  的典型实现 FileReader 来介绍这个类的用法：
 
	//1、创建源
        File srcFile = new File("io"+File.separator+"a.txt");
        //2、创建字符输出流对象
        Reader in = new FileReader(srcFile);
        //3、具体的 IO 操作
            /***
             * int read():每次读取一个字符，读到最后返回 -1
             * int read(char[] buffer):将字符读进字符数组,返回结果为读取的字符数
             * int read(char[] buffer,int off,int len):将读取的字符存储进字符数组 buffer，返回结果为读取的字符数，从索引 off 开始，长度为 len
             *
             */
        //int read():每次读取一个字符，读到最后返回 -1
        int len = -1;//定义当前读取字符的数量
        while((len = in.read())!=-1){
            //打印 a.txt 文件中所有内容
            System.out.print((char)len);
        }
         
        //int read(char[] buffer):将字符读进字符数组
        char[] buffer = new char[10]; //每次读取 10 个字符
        while((len=in.read(buffer))!=-1){
            System.out.println(new String(buffer,0,len));
        }
         
        //int read(char[] buffer,int off,int len)
        while((len=in.read(buffer,0,10))!=-1){
            System.out.println(new String(buffer,0,len));
        }
        //4、关闭流资源
        in.close();

 
 3、用字符流完成文件的复制
 
	/**
         * 将 a.txt 文件 复制到 b.txt 中
         */
        //1、创建源和目标
        File srcFile = new File("io"+File.separator+"a.txt");
        File descFile = new File("io"+File.separator+"b.txt");
        //2、创建字符输入输出流对象
        Reader in = new FileReader(srcFile);
        Writer out = new FileWriter(descFile);
        //3、读取和写入操作
        char[] buffer = new char[10];//创建一个容量为 10 的字符数组，存储已经读取的数据
        int len = -1;//表示已经读取了多少个字节，如果是 -1，表示已经读取到文件的末尾
        while((len=in.read(buffer))!=-1){
            out.write(buffer, 0, len);
        }
         
        //4、关闭流资源
        out.close();
        in.close();

 
分类: Java SE
标签: Reader, Writer




# Java IO详解（五)------包装流
 - YSOcean - 博客园 http://www.cnblogs.com/ysocean/p/6864080.html


File 类的介绍：http://www.cnblogs.com/ysocean/p/6851878.html
Java IO 流的分类介绍：http://www.cnblogs.com/ysocean/p/6854098.html
Java IO 字节输入输出流：http://www.cnblogs.com/ysocean/p/6854541.html
Java IO 字符输入输出流：https://i.cnblogs.com/EditPosts.aspx?postid=6859242
 
我们在 Java IO 流的分类介绍  这篇博客中介绍知道：
根据功能分为节点流和包装流（处理流）
节点流：可以从或向一个特定的地方(节点)读写数据。如FileReader.
处理流：是对一个已存在的流的连接和封装，通过所封装的流的功能调用实现数据读写。如BufferedReader.处理流的构造方法总是要带一个其他的流对象做参数。一个流对象经过其他流的多次包装，称为流的链接。
 
1、前面讲的字符输入输出流，字节输入输出流都是字节流。那么什么是包装流呢？
①、包装流隐藏了底层节点流的差异，并对外提供了更方便的输入\输出功能，让我们只关心这个高级流的操作
②、使用包装流包装了节点流，程序直接操作包装流，而底层还是节点流和IO设备操作
③、关闭包装流的时候，只需要关闭包装流即可
 
 
 
2、缓冲流
 
缓冲流：是一个包装流，目的是缓存作用，加快读取和写入数据的速度。
字节缓冲流：BufferedInputStream、BufferedOutputStream
字符缓冲流：BufferedReader、BufferedWriter
案情回放：我们在将字符输入输出流、字节输入输出流的时候，读取操作，通常都会定义一个字节或字符数组，将读取/写入的数据先存放到这个数组里面，然后在取数组里面的数据。这比我们一个一个的读取/写入数据要快很多，而这也就是缓冲流的由来。只不过缓冲流里面定义了一个 数组用来存储我们读取/写入的数据，当内部定义的数组满了（注意：我们操作的时候外部还是会定义一个小的数组，小数组放入到内部数组中），就会进行下一步操作。
 
下面是没有用缓冲流的操作：
	//1、创建目标对象，输入流表示那个文件的数据保存到程序中。不写盘符，默认该文件是在该项目的根目录下
            //a.txt 保存的文件内容为：AAaBCDEF
        File target = new File("io"+File.separator+"a.txt");
        //2、创建输入流对象
        InputStream in = new FileInputStream(target);
        //3、具体的 IO 操作（读取 a.txt 文件中的数据到程序中）
            /**
             * 注意：读取文件中的数据，读到最后没有数据时，返回-1
             *  int read():读取一个字节，返回读取的字节
             *  int read(byte[] b):读取多个字节,并保存到数组 b 中，从数组 b 的索引为 0 的位置开始存储，返回读取了几个字节
             *  int read(byte[] b,int off,int len):读取多个字节，并存储到数组 b 中，从数组b 的索引为 0 的位置开始，长度为len个字节
             */
        //int read():读取一个字节，返回读取的字节
        int data1 = in.read();//获取 a.txt 文件中的数据的第一个字节
        System.out.println((char)data1); //A
        //int read(byte[] b):读取多个字节保存到数组b 中
        byte[] buffer  = new byte[10];//这里我们定义了一个 长度为 10 的字节数组，用来存储读取的数据
        in.read(buffer);//获取 a.txt 文件中的前10 个字节，并存储到 buffer 数组中
        System.out.println(Arrays.toString(buffer)); //[65, 97, 66, 67, 68, 69, 70, 0, 0, 0]
        System.out.println(new String(buffer)); //AaBCDEF[][][]
         
        //int read(byte[] b,int off,int len):读取多个字节，并存储到数组 b 中,从索引 off 开始到 len
        in.read(buffer, 0, 3);
        System.out.println(Arrays.toString(buffer)); //[65, 97, 66, 0, 0, 0, 0, 0, 0, 0]
        System.out.println(new String(buffer)); //AaB[][][][][][][]
        //4、关闭流资源
        in.close();
我们查看 缓冲流的 JDK 底层源码，可以看到，程序中定义了这样的 缓存数组,大小为 8192
BufferedInputStream:
 
 
 
BufferedOutputStream:
 
	//字节缓冲输入流
        BufferedInputStream bis = new BufferedInputStream(
                new FileInputStream("io"+File.separator+"a.txt"));
        //定义一个字节数组，用来存储数据
        byte[] buffer = new byte[1024];
        int len = -1;//定义一个整数，表示读取的字节数
        while((len=bis.read(buffer))!=-1){
            System.out.println(new String(buffer,0,len));
        }
        //关闭流资源
        bis.close();<br><br>
         
        //字节缓冲输出流
        BufferedOutputStream bos = new BufferedOutputStream(
                new FileOutputStream("io"+File.separator+"a.txt"));
        bos.write("ABCD".getBytes());
        bos.close();
 
	//字符缓冲输入流
        BufferedReader br = new BufferedReader(
                new FileReader("io"+File.separator+"a.txt"));
        char[] buffer = new char[10];
        int len = -1;
        while((len=br.read(buffer))!=-1){
            System.out.println(new String(buffer,0,len));
        }
        br.close();
         
        //字符缓冲输出流
        BufferedWriter bw = new BufferedWriter(
                new FileWriter("io"+File.separator+"a.txt"));
        bw.write("ABCD");
        bw.close();

 
 
 3、转换流：把字节流转换为字符流
InputStreamReader:把字节输入流转换为字符输入流
OutputStreamWriter:把字节输出流转换为字符输出流
  
 
 用转换流进行文件的复制：
	/**
         * 将 a.txt 文件 复制到 b.txt 中
         */
        //1、创建源和目标
        File srcFile = new File("io"+File.separator+"a.txt");
        File descFile = new File("io"+File.separator+"b.txt");
        //2、创建字节输入输出流对象
        InputStream in = new FileInputStream(srcFile);
        OutputStream out = new FileOutputStream(descFile);
        //3、创建转换输入输出对象
        Reader rd = new InputStreamReader(in);
        Writer wt = new OutputStreamWriter(out);
        //3、读取和写入操作
        char[] buffer = new char[10];//创建一个容量为 10 的字符数组，存储已经读取的数据
        int len = -1;//表示已经读取了多少个字符，如果是 -1，表示已经读取到文件的末尾
        while((len=rd.read(buffer))!=-1){
            wt.write(buffer, 0, len);
        }
        //4、关闭流资源
        rd.close();
        wt.close();

 
 4、内存流（数组流）：
把数据先临时存在数组中，也就是内存中。所以关闭 内存流是无效的，关闭后还是可以调用这个类的方法。底层源码的 close()是一个空方法
 
 
①、字节内存流：ByteArrayOutputStream 、ByteArrayInputStream
	//字节数组输出流：程序---》内存
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        //将数据写入到内存中
        bos.write("ABCD".getBytes());
        //创建一个新分配的字节数组。 其大小是此输出流的当前大小，缓冲区的有效内容已被复制到其中。
        byte[] temp = bos.toByteArray();
        System.out.println(new String(temp,0,temp.length));
         
        byte[] buffer = new byte[10];
        ///字节数组输入流：内存---》程序
        ByteArrayInputStream bis = new ByteArrayInputStream(temp);
        int len = -1;
        while((len=bis.read(buffer))!=-1){
            System.out.println(new String(buffer,0,len));
        }
         
        //这里不写也没事，因为源码中的 close()是一个空的方法体
        bos.close();
        bis.close();

②、字符内存流：CharArrayReader、CharArrayWriter

	//字符数组输出流
        CharArrayWriter caw = new CharArrayWriter();
        caw.write("ABCD");
        //返回内存数据的副本
        char[] temp = caw.toCharArray();
        System.out.println(new String(temp));
         
        //字符数组输入流
        CharArrayReader car = new CharArrayReader(temp);
        char[] buffer = new char[10];
        int len = -1;
        while((len=car.read(buffer))!=-1){
            System.out.println(new String(buffer,0,len));
        }

③、字符串流：StringReader,StringWriter（把数据临时存储到字符串中）
 
	//字符串输出流,底层采用 StringBuffer 进行拼接
        StringWriter sw = new StringWriter();
        sw.write("ABCD");
        sw.write("帅锅");
        System.out.println(sw.toString());//ABCD帅锅
 
        //字符串输入流
        StringReader sr = new StringReader(sw.toString());
        char[] buffer = new char[10];
        int len = -1;
        while((len=sr.read(buffer))!=-1){
            System.out.println(new String(buffer,0,len));//ABCD帅锅
        }

 
 
5、合并流：把多个输入流合并为一个流，也叫顺序流，因为在读取的时候是先读第一个，读完了在读下面一个流。
  
	//定义字节输入合并流
        SequenceInputStream seinput = new SequenceInputStream(
                new FileInputStream("io/a.txt"), new FileInputStream("io/b.txt"));
        byte[] buffer = new byte[10];
        int len = -1;
        while((len=seinput.read(buffer))!=-1){
            System.out.println(new String(buffer,0,len));
        }
         
        seinput.close();

 
分类: Java SE




# Java IO详解（六)------序列化与反序列化（对象流）
 - YSOcean - 博客园 http://www.cnblogs.com/ysocean/p/6870069.html

File 类的介绍：http://www.cnblogs.com/ysocean/p/6851878.html
Java IO 流的分类介绍：http://www.cnblogs.com/ysocean/p/6854098.html
Java IO 字节输入输出流：http://www.cnblogs.com/ysocean/p/6854541.html
Java IO 字符输入输出流：https://i.cnblogs.com/EditPosts.aspx?postid=6859242
Java IO 包装流：http://www.cnblogs.com/ysocean/p/6864080.html
 
1、什么是序列化与反序列化？
序列化：指把堆内存中的 Java 对象数据，通过某种方式把对象存储到磁盘文件中或者传递给其他网络节点（在网络上传输）。这个过程称为序列化。通俗来说就是将数据结构或对象转换成二进制串的过程
反序列化：把磁盘文件中的对象数据或者把网络节点上的对象数据，恢复成Java对象模型的过程。也就是将在序列化过程中所生成的二进制串转换成数据结构或者对象的过程
 
2、为什么要做序列化？
①、在分布式系统中，此时需要把对象在网络上传输，就得把对象数据转换为二进制形式，需要共享的数据的 JavaBean 对象，都得做序列化。
②、服务器钝化：如果服务器发现某些对象好久没活动了，那么服务器就会把这些内存中的对象持久化在本地磁盘文件中（Java对象转换为二进制文件）；如果服务器发现某些对象需要活动时，先去内存中寻找，找不到再去磁盘文件中反序列化我们的对象数据，恢复成 Java 对象。这样能节省服务器内存。
 
3、Java 怎么进行序列化？
①、需要做序列化的对象的类，必须实现序列化接口：Java.lang.Serializable 接口（这是一个标志接口，没有任何抽象方法），Java 中大多数类都实现了该接口，比如：String，Integer
②、底层会判断，如果当前对象是 Serializable 的实例，才允许做序列化，Java对象 instanceof Serializable 来判断。
③、在 Java 中使用对象流来完成序列化和反序列化
ObjectOutputStream:通过 writeObject()方法做序列化操作
ObjectInputStream:通过 readObject() 方法做反序列化操作
 
 
 
 第一步：创建一个 JavaBean 对象
	public class Person implements Serializable{
    private String name;
    private int age;
     
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
    public int getAge() {
        return age;
    }
    public void setAge(int age) {
        this.age = age;
    }
    @Override
    public String toString() {
        return "Person [name=" + name + ", age=" + age + "]";
    }
    public Person(String name, int age) {
        super();
        this.name = name;
        this.age = age;
    }
}
 
 第二步：使用 ObjectOutputStream 对象实现序列化
1
2
3
4
5
6	//在根目录下新建一个 io 的文件夹
        OutputStream op = new FileOutputStream("io"+File.separator+"a.txt");
        ObjectOutputStream ops = new ObjectOutputStream(op);
        ops.writeObject(new Person("vae",1));
         
        ops.close();
我们打开 a.txt 文件，发现里面的内容乱码，注意这不需要我们来看懂，这是二进制文件，计算机能读懂就行了。
错误一：如果新建的 Person 对象没有实现 Serializable 接口，那么上面的操作会报错：
 
第三步：使用ObjectInputStream 对象实现反序列化
反序列化的对象必须要提供该对象的字节码文件.class
1
2
3
4
5
6
7	InputStream in = new FileInputStream("io"+File.separator+"a.txt");
        ObjectInputStream os = new ObjectInputStream(in);
        byte[] buffer = new byte[10];
        int len = -1;
        Person p = (Person) os.readObject();
        System.out.println(p);  //Person [name=vae, age=1]
        os.close();

问题1：如果某些数据不需要做序列化，比如密码，比如上面的年龄？
解决办法：在字段面前加上 transient
1
2	private String name;//需要序列化
    transient private int age;//不需要序列化
那么我们在反序列化的时候，打印出来的就是Person [name=vae, age=0]，整型数据默认值为 0 
 
问题2：序列化版本问题，在完成序列化操作后，由于项目的升级或修改，可能我们会对序列化对象进行修改，比如增加某个字段，那么我们在进行反序列化就会报错：
 
 
  
解决办法：在 JavaBean 对象中增加一个 serialVersionUID 字段，用来固定这个版本，无论我们怎么修改，版本都是一致的，就能进行反序列化了
1	private static final long serialVersionUID = 8656128222714547171L;

 
分类: Java SE
标签: 序列化, 反序列化




# Java IO详解（七)------随机访问文件流 
- YSOcean - 博客园 http://www.cnblogs.com/ysocean/p/6870250.html

File 类的介绍：http://www.cnblogs.com/ysocean/p/6851878.html
Java IO 流的分类介绍：http://www.cnblogs.com/ysocean/p/6854098.html
Java IO 字节输入输出流：http://www.cnblogs.com/ysocean/p/6854541.html
Java IO 字符输入输出流：https://i.cnblogs.com/EditPosts.aspx?postid=6859242
Java IO 包装流：http://www.cnblogs.com/ysocean/p/6864080.html
Java IO 对象流（序列化与反序列化）：http://www.cnblogs.com/ysocean/p/6870069.html
 
1、什么是 随机访问文件流 RandomAccessFile?
该类的实例支持读取和写入随机访问文件。 随机访问文件的行为类似于存储在文件系统中的大量字节。 有一种游标，或索引到隐含的数组，称为文件指针 ; 输入操作读取从文件指针开始的字节，并使文件指针超过读取的字节。 如果在读/写模式下创建随机访问文件，则输出操作也可用; 输出操作从文件指针开始写入字节，并将文件指针提前到写入的字节。 写入隐式数组的当前端的输出操作会导致扩展数组。 文件指针可以通过读取getFilePointer方法和由设置seek方法。
通俗来讲：我们以前讲的 IO 字节流，包装流等都是按照文件内容的顺序来读取和写入的。而这个随机访问文件流我们可以再文件的任意地方写入数据，也可以读取任意地方的字节。
 
我们查看 底层源码，可以看到：
1	public class RandomAccessFile implements DataOutput, DataInput, Closeable {
实现了 DataOutput类，DataInput类，那么这两个类是什么呢？
 
2、数据流：DataOutput,DataInput
①、DataOutput:提供将数据从任何Java基本类型转换为一系列字节，并将这些字节写入二进制流。 还有一种将String转换为modified UTF-8格式(这种格式会在写入的数据之前默认增加两个字节的长度)并编写结果字节系列的功能。
②、DataInput:提供从二进制流读取字节并从其中重建任何Java原语类型的数据。 还有，为了重建设施String从数据modified UTF-8格式。 
下面我们以其典型实现：DataOutputSteam、DataInputStream 来看看它的用法：
	//数据输出流
        File file = new File("io"+File.separator+"a.txt");
        DataOutputStream dop = new DataOutputStream(new FileOutputStream(file));
        //写入三种类型的数据
        dop.write(65);
        dop.writeChar('哥');
        dop.writeUTF("帅锅");
        dop.close();
         
        //数据输入流
        DataInputStream dis = new DataInputStream(new FileInputStream(file));
        System.out.println(dis.read());  //65
        System.out.println(dis.readChar()); //哥
        System.out.println(dis.readUTF());  //帅锅
        dis.close();

 
3、通过上面的例子，我们可以看到因为 RandomAccessFile 实现了数据输入输出流，那么 RandomAccessFile 这一个类就可以完成 输入输出的功能了。
 
这里面第二个参数：String mode 有以下几种形式：（ps：为什么这里的值是固定的而不弄成枚举形式，不然很容易写错，这是因为随机访问流出现在枚举类型之前，属于Java 历史遗留问题）
 
 
 第一种：用 随机流顺序读取数据
	public class RandomAccessFileTest {
    public static void main(String[] args) throws Exception {
        File file = new File("io"+File.separator+"a.txt");
        write(file);
        read(file);
    }
     
    /**
     * 随机流读数据
     */
    private static void read(File file) throws Exception {
        //以 r 即只读的方法读取数据
        RandomAccessFile ras = new RandomAccessFile(file, "r");
        byte b = ras.readByte();
        System.out.println(b); //65
         
        int i = ras.readInt();
        System.out.println(i); //97
         
        String str = ras.readUTF(); //帅锅
        System.out.println(str);
        ras.close();
    }
 
    /**
     * 随机流写数据
     */
    private static void write(File file) throws Exception{
        //以 rw 即读写的方式写入数据
        RandomAccessFile ras = new RandomAccessFile(file, "rw");
        ras.writeByte(65);
        ras.writeInt(97);
        ras.writeUTF("帅锅");
         
        ras.close();
    }
 
}

第二种：随机读取，那么我们先介绍这两个方法
 
 
这里所说的偏移量，也就是字节数。一个文件是有N个字节数组成，那么我们可以通过设置读取或者写入的偏移量，来达到随机读取或写入的目的。
我们先看看Java 各数据类型所占字节数：
 
下面是 随机读取数据例子：
	/**
     * 随机流读数据
     */
    private static void read(File file) throws Exception {
        //以 r 即只读的方法读取数据
        RandomAccessFile ras = new RandomAccessFile(file, "r");
         
        byte b = ras.readByte();
        System.out.println(b); //65
        //我们已经读取了一个字节的数据，那么当前偏移量为 1
        System.out.println(ras.getFilePointer());  //1
        //这时候我们设置 偏移量为 5，那么可以直接读取后面的字符串（前面是一个字节+一个整型数据=5个字节）
        ras.seek(5);
        String str = ras.readUTF(); //帅锅
        System.out.println(str);
         
        //这时我们设置 偏移量为 0，那么从头开始
        ras.seek(0);
        System.out.println(ras.readByte()); //65
         
        //需要注意的是：UTF 写入的数据默认会在前面增加两个字节的长度
         
        ras.close();
    }

 随机流复制文件：
	/**
     * 随机流复制文件
     * @param fileA
     * @param B
     * @throws Exception
     */
    private static void copyFile(File fileA,File fileB) throws Exception{
         
        RandomAccessFile srcRA = new RandomAccessFile(fileA, "rw");
        RandomAccessFile descRA = new RandomAccessFile(fileB, "rw");
         
        //向 文件 a.txt 中写入数据
        srcRA.writeByte(65);
        srcRA.writeInt(97);
        srcRA.writeUTF("帅锅");
        //获取 a.txt 文件的字节长度
        int len = (int) srcRA.length();
        srcRA.seek(0);
        System.out.println(srcRA.readByte()+srcRA.readInt()+srcRA.readUTF());
         
        //开始复制
        srcRA.seek(0);
        //定义一个数组，用来存放 a.txt 文件的数据
        byte[] buffer = new byte[len];
        //将 a.txt 文件的内容读到 buffer 中
        srcRA.readFully(buffer);
        //再将 buffer 写入到 b.txt文件中
        descRA.write(buffer);
         
        //读取 b.txt 文件中的数据
        descRA.seek(0);
        System.out.println(descRA.readByte()+descRA.readInt()+descRA.readUTF());
        //关闭流资源
        srcRA.close();
        descRA.close();
    }

ps：一般多线程下载、断点下载都可以运用此随机流
 
分类: Java SE
标签: RandomAccessFile






