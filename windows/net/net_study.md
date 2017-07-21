

- [Get started with .NET Core | Microsoft Docs ](https://docs.microsoft.com/en-us/dotnet/core/get-started)
- [.NET Core 1.0 RC2 历险之旅 - 江大渔 - 博客园 ](http://www.cnblogs.com/jzywh/p/dotnetcorerc2.html)

- [instructions-for-setting-up-the-net-core-debugger---experimental-preview · OmniSharp/omnisharp-vscode ](https://github.com/OmniSharp/omnisharp-vscode/blob/master/debugger.md#instructions-for-setting-up-the-net-core-debugger---experimental-preview)


- [dotnet-build command - .NET Core CLI | Microsoft Docs ](https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-build)

- [dotnet/core: Home repository for .NET Core ](https://github.com/dotnet/core)
- [Get started with Visual Studio Code - C# Guide | Microsoft Docs ](https://docs.microsoft.com/en-us/dotnet/csharp/getting-started/with-visual-studio-code)

dotnet new console
dotnet restore

- [vscode - .NET Core debugging with VS Code - "Only 64-bit processes can be debugged" - Stack Overflow ](https://stackoverflow.com/questions/43343721/net-core-debugging-with-vs-code-only-64-bit-processes-can-be-debugged)

Version 1.9.0 of the ms-vscode.csharp extension added desktop CLR support.

Modify your launch.json file:

"type" : "clr",
"program" : "path to x64 version of the executable.exe"
To target x64, modify your .csproj file like so:

<PropertyGroup>
  <TargetFramework>net461</TargetFramework>
  <RuntimeIdentifier>win7-x64</RuntimeIdentifier>
</PropertyGroup>
An example program path after specifying the runtime id:

"program" : ${workspaceRoot}/src/bin/Debug/net461/win7-x64/example.exe

- [Visual Code的调试 - ChuckLu - 博客园 ](http://www.cnblogs.com/chucklu/p/7096088.html)

- [dotnet-build command - .NET Core CLI | Microsoft Docs ](https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-build)
dotnet build --runtime win10-armx64

- [.NET Core Runtime IDentifier (RID) catalog | Microsoft Docs ](https://docs.microsoft.com/en-us/dotnet/core/rid-catalog)

Windows RIDs
Windows 7 / Windows Server 2008 R2
win7-x64
win7-x86
Windows 8 / Windows Server 2012
win8-x64
win8-x86
win8-arm
Windows 8.1 / Windows Server 2012 R2
win81-x64
win81-x86
win81-arm
Windows 10 / Windows Server 2016
win10-x64
win10-x86
win10-arm
win10-arm64

- [C# programming with Visual Studio Code ](https://code.visualstudio.com/docs/languages/csharp)
