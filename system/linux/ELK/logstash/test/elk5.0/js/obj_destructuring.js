let a, b, rest;

/* array 解构赋值 */
[a, b] = [1, 2];
console.log(a); // 1
console.log(b); // 2

[a, b, ...rest] = [1, 2, 3, 4, 5];
console.log(a); // 1
console.log(b); // 2
console.log(rest); // [3, 4, 5]

/* object 解构赋值 */
({a, b} = {a:1, b:2});
console.log(a); // 1
console.log(b); // 2

// ES7 - 试验性 (尚未标准化)
// Uncaught SyntaxError: Unexpected token ...
//({a, b, ...rest} = {a:1, b:2, c:3, d:4});

var options = {
  aa: 'a',
  ab: 'b',
  c: {
    d: 'd'
  }
};

var {aa, ab, c: {d}} = options;

console.log(aa);
console.log(ab);
console.log(d);
console.log(options);

