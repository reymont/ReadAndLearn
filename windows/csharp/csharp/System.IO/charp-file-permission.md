

* [FileIOPermission Class (System.Security.Permissions) ](https://msdn.microsoft.com/en-us/library/system.security.permissions.fileiopermission(v=vs.110).aspx)

The following examples illustrate code that uses FileIOPermission. After the following two lines of code, the object f represents permission to read all files on the client computer's local disks. The code example then demands the permission to determine whether the application has permission to read the files.

```cs
FileIOPermission f = new FileIOPermission(PermissionState.None);
f.AllLocalFiles = FileIOPermissionAccess.Read;
try
{
    f.Demand();
}
catch (SecurityException s)
{
    Console.WriteLine(s.Message);
}
```

After the following two lines of code, the object f2 represents permissions to read C:\test_r and read and write to C:\example\out.txt. Read and Write represent the file/folder permissions as previously described. After creating the permission, the code demands the permission to determine whether the application has the right to read and write to the file.

```cs
FileIOPermission f2 = new FileIOPermission(FileIOPermissionAccess.Read, "C:\\test_r");
f2.AddPathList(FileIOPermissionAccess.Write | FileIOPermissionAccess.Read, "C:\\example\\out.txt");
try
{
    f2.Demand();
}
catch (SecurityException s)
{
    Console.WriteLine(s.Message);
}
```


* [c# - System.IO.Directory.CreateDirectory with permissions for only this current user? - Stack Overflow ](https://stackoverflow.com/questions/1006684/system-io-directory-createdirectory-with-permissions-for-only-this-current-user)

There is an example of creating a DirectorySecurity instance and adding an ACE for a named user here (but use the default constructor to start with an empty ACL).

To get the SID of the account there are two possibilities (these need testing):

The first approach is to rely on the owner of the process being the owner of the directory. This is likely to break if doing impersonation (e.g. under Windows Authentication to have the client's identity used for access control to filesystem content):

```cs
var ds = new DirectorySecurity();
var sid = new SecurityIdentifier(WellKnownSidType.CreatorOwnerSid, null)
var ace = new FileSystemAccessRule(sid,
                                   FileSystemRights.FullControl,
                                   AccessControlType.Allow);
ds.AddAccessRule(ace);
```

The second approach to to get the process owner from the process Token, this will require P/Invoke. This includes an example: http://www.codeproject.com/KB/cs/processownersid.aspx, once you have the SID create a SecurityIdentifier instance for it and follow the above to create the ACL.


# DirectorySecurity

* [DirectorySecurity Class (System.Security.AccessControl) ](https://msdn.microsoft.com/en-us/library/system.security.accesscontrol.directorysecurity(v=vs.110).aspx
* [c# - Get domain name - Stack Overflow ](https://stackoverflow.com/questions/4161246/get-domain-name)

```cs
System.Environment.UserDomainName
```


The following code example uses the DirectorySecurity class to add and then remove an access control list (ACL) entry from a directory. You must supply a valid user or group account to run this example.

```cs
using System;
using System.IO;
using System.Security.AccessControl;

namespace FileSystemExample
{
    class DirectoryExample
    {
        public static void Main()
        {
            try
            {
                string DirectoryName = "TestDirectory";

                Console.WriteLine("Adding access control entry for " + DirectoryName);

                // Add the access control entry to the directory.
                AddDirectorySecurity(DirectoryName, @"MYDOMAIN\MyAccount", FileSystemRights.ReadData, AccessControlType.Allow);

                Console.WriteLine("Removing access control entry from " + DirectoryName);

                // Remove the access control entry from the directory.
                RemoveDirectorySecurity(DirectoryName, @"MYDOMAIN\MyAccount", FileSystemRights.ReadData, AccessControlType.Allow);

                Console.WriteLine("Done.");
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
            }

            Console.ReadLine();
        }

        // Adds an ACL entry on the specified directory for the specified account.
        public static void AddDirectorySecurity(string FileName, string Account, FileSystemRights Rights, AccessControlType ControlType)
        {
            // Create a new DirectoryInfo object.
            DirectoryInfo dInfo = new DirectoryInfo(FileName);

            // Get a DirectorySecurity object that represents the 
            // current security settings.
            DirectorySecurity dSecurity = dInfo.GetAccessControl();

            // Add the FileSystemAccessRule to the security settings. 
            dSecurity.AddAccessRule(new FileSystemAccessRule(Account,
                                                            Rights,
                                                            ControlType));

            // Set the new access settings.
            dInfo.SetAccessControl(dSecurity);

        }

        // Removes an ACL entry on the specified directory for the specified account.
        public static void RemoveDirectorySecurity(string FileName, string Account, FileSystemRights Rights, AccessControlType ControlType)
        {
            // Create a new DirectoryInfo object.
            DirectoryInfo dInfo = new DirectoryInfo(FileName);

            // Get a DirectorySecurity object that represents the 
            // current security settings.
            DirectorySecurity dSecurity = dInfo.GetAccessControl();

            // Add the FileSystemAccessRule to the security settings. 
            dSecurity.RemoveAccessRule(new FileSystemAccessRule(Account,
                                                            Rights,
                                                            ControlType));

            // Set the new access settings.
            dInfo.SetAccessControl(dSecurity);

        }
    }
}
```


* [access rights - Add "Everyone" privilege to folder using C#.NET - Stack Overflow ](https://stackoverflow.com/questions/5298905/add-everyone-privilege-to-folder-using-c-net)


102
down vote
accepted
First thing I want to tell you is how I found this solution. This is probably more important than the answer because file permissions are hard to get correct.

First thing I did was set the permissions I wanted using the Windows dialogs and checkboxes. I added a rule for "Everyone" and ticked all boxes except "Full Control".

Then I wrote this C# code to tell me exactly what parameters I need to duplicate the Windows settings:
```cs
string path = @"C:\Users\you\Desktop\perms"; // path to directory whose settings you have already correctly configured
DirectorySecurity sec = Directory.GetAccessControl(path);
foreach (FileSystemAccessRule acr in sec.GetAccessRules(true, true, typeof(System.Security.Principal.NTAccount))) {
    Console.WriteLine("{0} | {1} | {2} | {3} | {4}", acr.IdentityReference.Value, acr.FileSystemRights, acr.InheritanceFlags, acr.PropagationFlags, acr.AccessControlType);
}
```
This gave me this line of output:

Everyone | Modify, Synchronize | ContainerInherit, ObjectInherit | None | Allow
So the solution is simple (yet hard to get right if you don't know what to look for!):
```cs
DirectorySecurity sec = Directory.GetAccessControl(path);
// Using this instead of the "Everyone" string means we work on non-English systems.
SecurityIdentifier everyone = new SecurityIdentifier(WellKnownSidType.WorldSid, null);
sec.AddAccessRule(new FileSystemAccessRule(everyone, FileSystemRights.Modify | FileSystemRights.Synchronize, InheritanceFlags.ContainerInherit | InheritanceFlags.ObjectInherit, PropagationFlags.None, AccessControlType.Allow));
Directory.SetAccessControl(path, sec);
```
This will make the checkboxes on the Windows security dialog match what you have already set for your test directory.

