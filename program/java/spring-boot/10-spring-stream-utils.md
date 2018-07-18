Introduction to Spring's StreamUtils | Baeldung http://www.baeldung.com/spring-stream-utils
tutorials/spring-core at master · eugenp/tutorials https://github.com/eugenp/tutorials/tree/master/spring-core

1. Overview

In this article, we’ll have a look at StreamUtils class and how we can use it.

Simply put, StreamUtils is a Spring’s class that contains some utility methods for dealing with stream – InputStream and OutputStream which reside in the package java.io and not related to the Java 8’s Stream API.

2. Maven Dependency

StreamUtils class is available in the spring-core module so let’s add it to our pom.xml:

1
2
3
4
5
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-core</artifactId>
    <version>4.3.10.RELEASE</version>
</dependency>
You can find the latest version of the library at the Maven Central Repository.

3. Copying Streams

The StreamUtils class contains several overloaded methods named copy() as well as some other variations:

copyRange()
copyToByteArray()
copyString()
We can copy streams without using any libraries. However, the code is going to be cumbersome and much harder to read and understand.

Note that we’re omitting closing of streams for the sake of simplicity. 

Let’s see how we can copy the content of an InputStream to a given OutputStream:

```java
@Test
public void whenCopyInputStreamToOutputStream_thenCorrect() throws IOException {
    String inputFileName = "src/test/resources/input.txt";
    String outputFileName = "src/test/resources/output.txt";
    File outputFile = new File(outputFileName);
    InputStream in = new FileInputStream(inputFileName);
    OutputStream out = new FileOutputStream(outputFile);
     
    StreamUtils.copy(in, out);
     
    assertTrue(outputFile.exists());
    String inputFileContent = getStringFromInputStream(new FileInputStream(inputFileName));
    String outputFileContent = getStringFromInputStream(new FileInputStream(outputFileName));
    assertEquals(inputFileContent, outputFileContent);
}
```
The created file contains the content of the InputStream.

Note that getStringFromInputStream() is a method that takes an InputStream and returns its content as a String. The implementation of the method is available in the full version of the code.

We don’t have to copy the whole content of the InputStream, we can copy a range of the content to a given OutputStream using the copyRange() method:

```java
@Test
public void whenCopyRangeOfInputStreamToOutputStream_thenCorrect() throws IOException {
    String inputFileName = "src/test/resources/input.txt";
    String outputFileName = "src/test/resources/output.txt";
    File outputFile = new File(outputFileName);
    InputStream in = new FileInputStream(inputFileName);
    OutputStream out = new FileOutputStream(outputFileName);
     
    StreamUtils.copyRange(in, out, 1, 10);
     
    assertTrue(outputFile.exists());
    String inputFileContent = getStringFromInputStream(new FileInputStream(inputFileName));
    String outputFileContent = getStringFromInputStream(new FileInputStream(outputFileName));
  
    assertEquals(inputFileContent.substring(1, 11), outputFileContent);
}
```
As we can see here, the copyRange() takes four parameters, the InputStream, the OutputStream, the position to start copying from, and the position to end copying. But what if the specified range exceeds the length of the InputStream? The method copyRange() then copies up to the end of the stream.

Let’s see how we can copy the content of a String to a given OutputStream:

```java
@Test
public void whenCopyStringToOutputStream_thenCorrect() throws IOException {
    String string = "Should be copied to OutputStream.";
    String outputFileName = "src/test/resources/output.txt";
    File outputFile = new File(outputFileName);
    OutputStream out = new FileOutputStream("src/test/resources/output.txt");
     
    StreamUtils.copy(string, StandardCharsets.UTF_8, out);
     
    assertTrue(outputFile.exists());
  
    String outputFileContent = getStringFromInputStream(new FileInputStream(outputFileName));
  
    assertEquals(outputFileContent, string);
}
```
The method copy() takes three parameters – the String to be copied, the Charset that we want to use to write to the file, and the OutputStream that we want to copy the content of the String to.

Here is how we can copy the content of a given InputStream to a new String:

```java
@Test
public void whenCopyInputStreamToString_thenCorrect() throws IOException {
    String inputFileName = "src/test/resources/input.txt";
    InputStream is = new FileInputStream(inputFileName);
    String content = StreamUtils.copyToString(is, StandardCharsets.UTF_8);
     
    String inputFileContent = getStringFromInputStream(new FileInputStream(inputFileName));
    assertEquals(inputFileContent, content);
}
```
We can also copy the content of a given byte array to an OutputStream:

```java
public void whenCopyByteArrayToOutputStream_thenCorrect() throws IOException {
    String outputFileName = "src/test/resources/output.txt";
    String string = "Should be copied to OutputStream.";
    byte[] byteArray = string.getBytes();
    OutputStream out = new FileOutputStream("src/test/resources/output.txt");
     
    StreamUtils.copy(byteArray, out);
     
    String outputFileContent = getStringFromInputStream(new FileInputStream(outputFileName));
  
    assertEquals(outputFileContent, string);
}
```
Or, we can copy the content of a given InputStream into a new byte array:

```java
public void whenCopyInputStreamToByteArray_thenCorrect() throws IOException {
    String inputFileName = "src/test/resources/input.txt";
    InputStream is = new FileInputStream(inputFileName);
    byte[] out = StreamUtils.copyToByteArray(is);
     
    String content = new String(out);
    String inputFileContent = getStringFromInputStream(new FileInputStream(inputFileName));
  
    assertEquals(inputFileContent, content);
}
```
# 4. Other Functionality

An InputStream can be passed as an argument to the method drain() to remove all the remaining data in the stream:

1
StreamUtils.drain(in);
We can also use the method emptyInput() to get an efficient empty InputStream:

public InputStream getInputStream() {
    return StreamUtils.emptyInput();
}

There are two overloaded methods named nonClosing(). `An InputStream or an OutputStream can be passed as an argument to these methods to get a variant of InputStream or OutputStream that ignores calls to the close() method`:

```java
public InputStream getNonClosingInputStream() throws IOException {
    InputStream in = new FileInputStream("src/test/resources/input.txt");
    return StreamUtils.nonClosing(in);
}
```

# 5. Conclusion

In this quick tutorial, we have seen what StreamUtils are. We’ve also covered all of the methods of the StreamUtils class, and we’ve seen how we can use them.

The full implementation of this tutorial can be found over on GitHub.