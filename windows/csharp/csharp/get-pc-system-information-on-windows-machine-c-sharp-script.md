


* [Get pc (system) information on windows machine - C# script - Stack Overflow ](https://stackoverflow.com/questions/4742389/get-pc-system-information-on-windows-machine-c-sharp-script)
* [Win32_OperatingSystem class (Windows) ](https://msdn.microsoft.com/en-us/library/aa394239(v=vs.85).aspx)
* [Win32_Processor class (Windows) ](https://msdn.microsoft.com/en-us/library/aa394373(v=vs.85).aspx)
* [C#取硬盘、CPU、主板、网卡的序号 ManagementObjectSearcher - 快乐家++ - 博客园 ](http://www.cnblogs.com/chengulv/archive/2012/12/29/2839303.html)


NuGet Gallery | System.Management 4.0.0 https://www.nuget.org/packages/System.Management/
PM> Install-Package System.Management
```cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Management;   //This namespace is used to work with WMI classes. For using this namespace add reference of System.Management.dll .
using Microsoft.Win32;     //This namespace is used to work with Registry editor.

namespace OperatingSystemInfo1
{
    class TestProgram
    {
        static void Main(string[] args)
        {
            SystemInfo si = new SystemInfo();       //Create an object of SystemInfo class.
            si.getOperatingSystemInfo();            //Call get operating system info method which will display operating system information.
            si.getProcessorInfo();                  //Call get  processor info method which will display processor info.
            Console.ReadLine();                     //Wait for user to accept input key.
        }
    }
    public class SystemInfo
    {
        public void getOperatingSystemInfo()
        {
            Console.WriteLine("Displaying operating system info....\n");
            //Create an object of ManagementObjectSearcher class and pass query as parameter.
            ManagementObjectSearcher mos = new ManagementObjectSearcher("select * from Win32_OperatingSystem");
            foreach (ManagementObject managementObject in mos.Get())
            {
                if (managementObject["Caption"] != null)
                {
                    Console.WriteLine("Operating System Name  :  " + managementObject["Caption"].ToString());   //Display operating system caption
                }
                if (managementObject["OSArchitecture"] != null)
                {
                    Console.WriteLine("Operating System Architecture  :  " + managementObject["OSArchitecture"].ToString());   //Display operating system architecture.
                }
                if (managementObject["CSDVersion"] != null)
                {
                    Console.WriteLine("Operating System Service Pack   :  " + managementObject["CSDVersion"].ToString());     //Display operating system version.
                }
            }
        }

        public void getProcessorInfo()
        {
            Console.WriteLine("\n\nDisplaying Processor Name....");
            RegistryKey processor_name = Registry.LocalMachine.OpenSubKey(@"Hardware\Description\System\CentralProcessor\0", RegistryKeyPermissionCheck.ReadSubTree);   //This registry entry contains entry for processor info.

            if (processor_name != null)
            {
                if (processor_name.GetValue("ProcessorNameString") != null)
                {
                    Console.WriteLine(processor_name.GetValue("ProcessorNameString"));   //Display processor ingo.
                }
            }
        }
    }
}
```