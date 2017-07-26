# .NET Core 1.0.4 命令行最简示例

- [Get Started with .NET Core ](https://www.microsoft.com/net/core#windowscmd)

安装[.NET Core](https://www.microsoft.com/net/download/core)

如果选择[dotnet-dev-win-x64.1.0.4.exe](https://download.microsoft.com/download/B/9/F/B9F1AF57-C14A-4670-9973-CDF47209B5BF/dotnet-dev-win-x64.1.0.4.exe)

```bat
dotnet new console -o hwapp
cd hwapp
dotnet restore
dotnet run
```

如果执行错误，请指定net版本4.6.1和指定编译环境windows10 64位
hwapp.csproj文件
```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net461</TargetFramework>
    <RuntimeIdentifier>win10-x64</RuntimeIdentifier>
  </PropertyGroup>

</Project>
```