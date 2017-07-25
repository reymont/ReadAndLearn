
# 目录

* [Directory.CreateDirectory Method (String) (System.IO) ](https://msdn.microsoft.com/en-us/library/54a0at6s(v=vs.110).aspx)

```cs
using System;
using System.IO;

class Test 
{
    public static void Main() 
    {
        // Specify the directory you want to manipulate.
        string path = @"c:\MyDir";

        try 
        {
            // Determine whether the directory exists.
            if (Directory.Exists(path)) 
            {
                Console.WriteLine("That path exists already.");
                return;
            }

            // Try to create the directory.
            DirectoryInfo di = Directory.CreateDirectory(path);
            Console.WriteLine("The directory was created successfully at {0}.", Directory.GetCreationTime(path));

            // Delete the directory.
            di.Delete();
            Console.WriteLine("The directory was deleted successfully.");
        } 
        catch (Exception e) 
        {
            Console.WriteLine("The process failed: {0}", e.ToString());
        } 
        finally {}
    }
}

    Directory.CreateDirectory("Public\\Html");
    Directory.CreateDirectory("\\Users\\User1\\Public\\Html");
    Directory.CreateDirectory("c:\\Users\\User1\\Public\\Html");
```


* [Directory Class (System.IO) ](https://msdn.microsoft.com/en-us/library/system.io.directory(v=vs.110).aspx)

The following example shows how to retrieve all the text files from a directory and move them to a new directory. After the files are moved, they no longer exist in the original directory.
下面的示例演示如何从一个目录中检索所有文本文件并将它们移动到一个新目录中。文件被移动后，它们不再存在于原始目录中。

```cs
using System;
using System.IO;

namespace ConsoleApplication
{
    class Program
    {
        static void Main(string[] args)
        {
            string sourceDirectory = @"C:\current";
            string archiveDirectory = @"C:\archive";

            try
            {
                var txtFiles = Directory.EnumerateFiles(sourceDirectory, "*.txt");

                foreach (string currentFile in txtFiles)
                {
                    string fileName = currentFile.Substring(sourceDirectory.Length + 1);
                    Directory.Move(currentFile, Path.Combine(archiveDirectory, fileName));
                }
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
            }
        }
    }
}
```

# 文件

* [File Class (System.IO) ](https://msdn.microsoft.com/en-us/library/system.io.file(v=vs.110).aspx)


```cs
using System;
using System.IO;

class Test
{
    public static void Main()
    {
        string path = @"c:\temp\MyTest.txt";
        if (!File.Exists(path))
        {
            // Create a file to write to.
            using (StreamWriter sw = File.CreateText(path))
            {
                sw.WriteLine("Hello");
                sw.WriteLine("And");
                sw.WriteLine("Welcome");
            }
        }

        // Open the file to read from.
        using (StreamReader sr = File.OpenText(path))
        {
            string s = "";
            while ((s = sr.ReadLine()) != null)
            {
                Console.WriteLine(s);
            }
        }
    }
}
```