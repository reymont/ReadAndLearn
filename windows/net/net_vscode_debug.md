


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