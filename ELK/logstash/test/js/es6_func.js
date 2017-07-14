//扩展运算符
let value1 = 25,
    value2 = 50;

console.log(Math.max(value1, value2)); // 50


let values = [25, 50, 75, 100]

console.log(Math.max.apply(Math, values)); // 100


// equivalent to
// console.log(Math.max(25, 50, 75, 100));
console.log(Math.max(...values)); // 100


values = [-25, -50, -75, -100]

console.log(Math.max(...values, 0)); // 0

//name 属性
function doSomething() {
    // ...
}

var doAnotherThing = function () {
    // ...
};

console.log(doSomething.name); // "doSomething"
console.log(doAnotherThing.name); // "doAnotherThing"

doSomething = function doSomethingElse() {
    // ...
};

var person = {
    get firstName() {
        return "Nicholas"
    },
    sayName: function () {
        console.log(this.name);
    }
}

console.log(doSomething.name); // "doSomethingElse"
console.log(person.sayName.name); // "sayName"
console.log(person.firstName.name); // "get firstName"

doSomething = function () {
    // ...
};

console.log(doSomething.bind().name); // "bound doSomething"

console.log((new Function()).name); // "anonymous"

function Person(name) {
    if (this instanceof Person) {
        this.name = name; // using new
    } else {
        throw new Error("You must use new with Person.")
    }
}

var person = new Person("Nicholas");
var notAPerson = Person.call(person, "Michael"); // works!

console.log(person); // "[Object object]"
console.log(notAPerson); // "undefined"

var moment = require('moment');
//let start = req.query.start == null ? moment().subtract(7, 'days').valueOf() : 11111111111;
//let end = req.query.end == null ? moment().endOf('day').valueOf() : 2222222222222;

console.log(moment().subtract(7, 'days').valueOf())
console.log(moment().endOf('day').valueOf())

// bind way
var PageHandler = {

    id: "123456",

    init: function() {
        document.addEventListener("click", (function(event) {
            this.doSomething(event.type);     // no error
        }).bind(this), false);
    },

    doSomething: function(type) {
        console.log("Handling " + type  + " for " + this.id);
    }
};

function createArrowFunctionReturningFirstArg() {
    return () => arguments[0];
}

var arrowFunction = createArrowFunctionReturningFirstArg(5);

console.log(arrowFunction());

var comparator = (a, b) => a - b;

console.log(typeof comparator);                 // "function"
console.log(comparator instanceof Function);    // true

var moment = require('moment')

var getStart = (start) => {
    if(start)return start;
    else return moment().subtract(7, 'days').valueOf();
};
var ss = getStart()
console.log(ss)
var ss = getStart(12121)
console.log(ss)

let variable1;
let variable2 = variable1  || '';
console.log(variable2 === ''); // prints true

variable1 = 'foo';
variable2 = variable1  || '';
console.log(variable2); // prints foo

var getEnd = (end) => end||moment().endOf('day').valueOf();
getStart = (start) => start||moment().subtract(7, 'days').valueOf();
var ss = getStart()
console.log(ss)
var ss = getStart(12121)
console.log(ss)

