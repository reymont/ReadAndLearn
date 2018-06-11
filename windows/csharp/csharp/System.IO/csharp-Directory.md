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