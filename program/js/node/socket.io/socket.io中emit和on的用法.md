https://blog.csdn.net/h330531987/article/details/78257517

socket.emit('action');表示发送了一个action命令，命令是字符串的，在另一端接收时，可以这么写： socket.on('action',function(){...});
socket.emit('action',data);表示发送了一个action命令，还有data数据，在另一端接收时，可以这么写： socket.on('action',function(data){...});
socket.emit(action,arg1,arg2); 表示发送了一个action命令，还有两个数据，在另一端接收时，可以这么写： socket.on('action',function(arg1,arg2){...});
在emit方法中包含回调函数，例如：
socket.emit('action',data, function(arg1,arg2){...} );那么这里面有一个回调函数可以在另一端调用，另一端可以这么写：socket.on('action',function(data,fn){   fn('a','b') ;  });
上面的data数据可以有0个或者多个，相应的在另一端改变function中参数的个数即可，function中的参数个数和顺序应该和发送时一致
上面的fn表示另一个端传递过来的参数，是个函数，写fn('a','b') ;会回调函数执行。一次发送不应该写多个回调，否则只有最后一个起效，回调应作为最后一个参数。