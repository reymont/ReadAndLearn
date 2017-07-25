
#Dictionary

- [C#之泛型集合类(Ilist,IDictionary)的使用 - ForrestWoo - 博客园 ](http://www.cnblogs.com/salam/archive/2010/05/30/1747518.html)


#using

- [c# using 关键字 - nygfcn - 博客园 ](http://www.cnblogs.com/nygfcn1234/archive/2013/10/17/3373718.html)

一、using作为指令，有如下两个作用
二、using作为语句，用于定义一个范围，在此范围的末尾将释放对象。


# 官方文档
- [C# Guide | Microsoft Docs ](https://docs.microsoft.com/en-us/dotnet/csharp/index)
- [Creates a REST client using .NET Core | Microsoft Docs ](https://docs.microsoft.com/en-us/dotnet/csharp/tutorials/console-webapiclient)


# GUID

* [Guid.ToString Method (String) (System) ](https://msdn.microsoft.com/en-us/library/97af8hh4.aspx)
* [在C#中GUID生成的四种格式 - 马会东 - 博客园 ](http://www.cnblogs.com/duanweishi/p/7043407.html)

```cs
var uuid = Guid.NewGuid().ToString(); // 9af7f46a-ea52-4aa3-b8c3-9fd484c2af12  
  
var uuidN = Guid.NewGuid().ToString("N"); // e0a953c3ee6040eaa9fae2b667060e09   
  
var uuidD = Guid.NewGuid().ToString("D"); // 9af7f46a-ea52-4aa3-b8c3-9fd484c2af12  
  
var uuidB = Guid.NewGuid().ToString("B"); // {734fd453-a4f8-4c5d-9c98-3fe2d7079760}  
  
var uuidP = Guid.NewGuid().ToString("P"); //  (ade24d16-db0f-40af-8794-1e08e2040df3)  
  
var uuidX = Guid.NewGuid().ToString("X"); // {0x3fa412e3,0x8356,0x428f,{0xaa,0x34,0xb7,0x40,0xda,0xaf,0x45,0x6f}}  
```