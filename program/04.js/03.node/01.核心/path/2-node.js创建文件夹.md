node.js创建文件夹 - CSDN博客 http://blog.csdn.net/a6383277/article/details/11927175

node.js没有提供直接创建嵌套文件夹的方法，如果需要创建嵌套的文件夹 则要用到 回调函数或者递归来完成。如下为递归的实现。
```js
var fs = require('fs');  
var path = require('path');  
//使用时第二个参数可以忽略  
function mkdir(dirpath,dirname){  
        //判断是否是第一次调用  
        if(typeof dirname === "undefined"){   
            if(fs.existsSync(dirpath)){  
                return;  
            }else{  
                mkdir(dirpath,path.dirname(dirpath));  
            }  
        }else{  
            //判断第二个参数是否正常，避免调用时传入错误参数  
            if(dirname !== path.dirname(dirpath)){   
                mkdir(dirpath);  
                return;  
            }  
            if(fs.existsSync(dirname)){  
                fs.mkdirSync(dirpath)  
            }else{  
                mkdir(dirname,path.dirname(dirname));  
                fs.mkdirSync(dirpath);  
            }  
        }  
}  
mkdir('/home/ec/a/b/c/d');  
```