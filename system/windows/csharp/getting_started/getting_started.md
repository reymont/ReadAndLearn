
#Creating a Hello World Program

by Steve Smith

The Hello World Project

In this lesson, you're going to learn about the different parts of a very simple program that displays the message, "Hello World!" You'll also learn what happens when you build and run the application, and you'll learn about some common errors you may encounter and how to correct them.
你们会学到一些常见的错误以及如何纠正它们

A C# program begins with a Main method, usually found in a file called Program.cs, like this one:

Show me ❯
```csharp
using System;

namespace ConsoleApplication
{
    public class Program
    {
        public static void Main()
        {
            Console.WriteLine("Hello World!");
        }
    }
}
```

#Program.cs
Program.cs是一个文本文件，通常很小。文件扩展名是“cs”，包含着C#源代码。从命令行中构建程序时，**dotnet**构建工具将构建所有以“.cs”结尾的文件。虽然这是一个小程序，但它有很多你需要明白的重要语法。首先，C#区分大小写，关键字必须是小写的，并且源代码中的其他命名元素必须完全匹配被引用的元素的大小写。

##程序的第一行

```csharp
using System;
```
**using**语句为方便程序员使用。它允许我们引用元素而不必申明前缀(以**System**为例)。什么是**命名空间(namespace)**？名称空间是组织编程结构的一种方式。它们类似于文件系统中的文件夹或目录。不是必须使用它们，但它们让你更容易找到并组织代码。这个程序包含System名称空间的原因是控制台类型（用来打印"Hello World!"）。如果删除了**using**语句，**Console.WriteLine**语句则需要包含命名空间，语句变为**System.Console.WriteLine**，**using**语句必须以分号(;)结尾。在C#中，大多数没有定义范围的语句以分号结尾。

##声明命名空间
在**using**声明之后，接着声明名称空间:

```csharp
namespace ConsoleApplication
```
Again, it's a good idea to use namespaces to keep larger codebases organized. namespace is a language keyword; ConsoleApplication is an identifier. In this case, the ConsoleApplication namespace has only one element in it (the Program class), but this would grow as the program grew in complexity. Namespaces use curly braces ({ and }) to denote which types belong within the namespace. Namespaces are optional; you'll frequently see they're omitted from the small samples shown in this tutorial.
同样，使用名称空间来保持更大的代码库是一个好主意

Inside the namespace's scope (defined by its curly braces), a class called "Program" is created:

public class Program
This line includes two keywords and one identifier. The public keyword describes the class's accessibility level. This defines how the class may be accessed by other parts of the program, and public means there are no restrictions to its access. The class keyword is used to define classes in C#, one of the primary constructs used to define types you will work with. C# is a strongly typed language, meaning that most of the time you'll need to explicitly define a type in your source code before it can be referenced from a program.

Inside the class's scope, a method called "Main" is defined:
```csharp
public static void Main()
```
Main方法是程序的入口 - 运行应用程序时运行的第一个代码。与类一样，方法也可以有访问修饰符。public意味着无限制的访问这个方法。

Next, the static keyword marks this method as global and associated with the type it's defined on, not a particular instance of that type. You'll learn more about this distinction in later lessons.

The void keyword indicates that this method doesn't return a value. The method is named Main.

Finally, inside of parentheses (( and )), the method defines any parameters it requires. In this case, the method has no parameters, but a command line program might accept arguments by specifying a parameter of type string array. This parameter is typically defined as string[] args, where args in this case is short for arguments. Arguments correspond to parameters. A method defines the parameters it requires; when calling a method, the values passed to its parameters are referred to as arguments. Like namespaces and classes, methods have scope defined by curly braces.

A class can contain many methods, which are one kind of member of that class.

Within the method's scope, there is one line:
```csharp
Console.WriteLine("Hello World!");
```
You've already learned that Console is a type inside of the System namespace. It's worth noting that this code does not create an instance of the Console type - it is simply calling the WriteLine method on the type directly. This tells you that WriteLine, like the Main method in this program, is declared as a static method. This means that any part of the application that calls this method will be calling the same method, doing the same thing. The program won't, for instance, open several different console windows and write to them separately. Every call to Console.WriteLine is going to write to the same console window.

Inside of the parentheses, the program is passing in "Hello World!" to the method. This is an argument, and will be used by the WriteLine method internally. C# defines a number of built-in types, one of which is a string. A string is a series of text characters. In this case, the program is passing the string "Hello World!" as an argument to the WriteLine method, which has defined a string parameter type. At the end of the line, the statement ends with a semicolon.

After the Console.WriteLine statement, there are three closing curly braces (}). These close the scopes for the Main method, the Program class, and the ConsoleApplication namespace, respectively. Note that the program uses indentation to make it easy to see which elements of the code belong to which scope. This is a good practice to follow, and will make it much easier for you (or others) to quickly read and understand the code you write.

#Troubleshooting

Especially if you create the initial program by hand, rather than from a template, it can be easy to make small mistakes that result in errors when you compile the application. You'll find a list of common errors in the troubleshooting lesson.

#Next Steps

Modify your console application to display a different message. Go ahead and intentionally add some mistakes to your program, so you can see what kinds of error messages you get from the compiler. The more familiar you are with these messages, and what causes them, the better you'll be at diagnosing problems in your programs that you didn't intend to add!


#参考

1. [.NET Tutorials - Creating a Hello World Program ](https://www.microsoft.com/net/tutorials/csharp/getting-started/hello-world)


