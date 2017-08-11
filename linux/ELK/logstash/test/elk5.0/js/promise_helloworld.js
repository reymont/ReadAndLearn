var xhr = new Promise((resolve, reject) => {
    setTimeout(() => {
        resolve({
            id: 1
        });
    }, 1000);
});
xhr.then((data) => console.log(data));

var Request = (i) => {
    return new Promise((resolve, reject) => {
        setTimeout(() => {
           console.log(i)
           resolve(i+"完成")
        }, 1000)
    })
}
Request(1)
.then((s) => Request(2))
.then((s) => Request(3))
.then((s) => Request(4))