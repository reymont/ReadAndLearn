# https://stackoverflow.com/questions/52353/in-java-what-is-the-best-way-to-determine-the-size-of-an-object

For example, let's say I have an application that can read in a CSV file with piles of data rows. I give the user a summary of the number of rows based on types of data, but I want to make sure that I don't read in too many rows of data and cause OutOfMemoryErrors. Each row translates into an object. Is there an easy way to find out the size of that object programmatically? Is there a reference that defines how large primitive types and object references are for a VM?

Right now, I have code that says read up to 32,000 rows, but I'd also like to have code that says read as many rows as possible until I've used 32MB of memory. Maybe that is a different question, but I'd still like to know.

You can use the java.lang.instrument package

Compile and put this class in a JAR:

import java.lang.instrument.Instrumentation;

public class ObjectSizeFetcher {
    private static Instrumentation instrumentation;

    public static void premain(String args, Instrumentation inst) {
        instrumentation = inst;
    }

    public static long getObjectSize(Object o) {
        return instrumentation.getObjectSize(o);
    }
}
Add the following to your MANIFEST.MF:

Premain-Class: ObjectSizeFetcher
Use getObjectSize:

public class C {
    private int x;
    private int y;

    public static void main(String [] args) {
        System.out.println(ObjectSizeFetcher.getObjectSize(new C()));
    }
}
Invoke with:

java -javaagent:ObjectSizeFetcherAgent.jar C


## ByteArrayOutputStream

Firstly "the size of an object" isn't a well-defined concept in Java. You could mean the object itself, with just its members, the Object and all objects it refers to (the reference graph). You could mean the size in memory or the size on disk. And the JVM is allowed to optimise things like Strings.

So the only correct way is to ask the JVM, with a good profiler (I use YourKit), which probably isn't what you want.

* http://www.yourkit.com/

However, from the description above it sounds like each row will be self-contained, and not have a big dependency tree, so the serialization method will probably be a good approximation on most JVMs. The easiest way to do this is as follows:

```java
 Serializable ser;
 ByteArrayOutputStream baos = new ByteArrayOutputStream();
 ObjectOutputStream oos = new ObjectOutputStream(baos);
 oos.writeObject(ser);
 oos.close();
 return baos.size();
``` 
Remember that if you have objects with common references this will not give the correct result, and size of serialization will not always match size in memory, but it is a good approximation. The code will be a bit more efficient if you initialise the ByteArrayOutputStream size to a sensible value.