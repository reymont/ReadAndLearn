

On Windows, `No $HOME environment variable found` shows up in the console · Issue #167 · fabric8io/gofabric8 https://github.com/fabric8io/gofabric8/issues/167

https://github.com/fabric8io/gofabric8/blob/master/gofabric8.go#L81

I had the same problem installing fabric8 on Windows. A look into the sourcecode reveals, you need to define a HOME environment variable. In windows CMD try

set HOME=C:\Users\yourHome
That worked for me

`set HOME=c:\fabric8`

set HOME = %USERPROFILE%

