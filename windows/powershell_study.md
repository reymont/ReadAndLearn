# 入门

- [PowerShell 在线教程 - PowerShell 中文博客](http://www.pstips.net/powershell-online-tutorials/)

# 快捷键

- [Powershell 快捷键 - PowerShell 中文博客](http://www.pstips.net/powershell-keyboard-shortcuts.html)

# 管理员方式

- [怎么windows10下设置始终以管理员身份运行_百度经验 ](http://jingyan.baidu.com/article/e2284b2b6e6df8e2e7118d7a.html)

- [PowerShell中以管理员权限启动应用程序的方法 - 新客网 ](http://www.xker.com/page/e2015/06/196718.html)

```powershell
Start-Process notepad -Verb runas
Start-Process "$PSHOME\powershell.exe" -Verb runas
```

- [如何使用Powershell创建运行方式管理员快捷方式 - IT屋-程序员软件开发技术分享社区 ](http://www.it1352.com/536818.html)

创建一个.exe的快捷方式
```powershell
 $ WshShell = New-Object -comObject WScript.Shell 
 $ Shortcut = $ WshShell.CreateShortcut（“$ Home\Desktop\ColorPix.lnk”）
 $ Shortcut.TargetPath =“C：\Program Files（x86）\\ \\ ColorPix\ColorPix.exe“
 $ Shortcut.Save（）
```

```powershell
 $ WshShell = New-Object -comObject WScript.Shell 
 $ Shortcut = $ WshShell.CreateShortcut（“$ Home\Desktop\ColorPix.lnk”）
 $ Shortcut.TargetPath =“C：\Program Files（x86）\ColorPix\ColorPix.exe”
 $ Shortcut.Save（）
 
 $ bytes = [System.IO File] :: ReadAllBytes（“$ Home \Desktop\ColorPix.lnk”）
 $ bytes [0x15] = $ bytes [0x15] -bor 0x20 #set byte 21（0x15）bit 6（0x20） ON 
 [System.IO.File] :: WriteAllBytes（“$ Home\Desktop\ColorPix.lnk”，$ bytes）
```