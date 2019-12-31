string https://www.npmjs.com/package/string
https://github.com/jprichardson/string.js


string.js, or simply S is a lightweight (< 5 kb minified and gzipped) JavaScript library for the browser or for Node.js that provides extra String methods. Originally, it modified the String prototype. But I quickly learned that in JavaScript, this is considered poor practice.

Why?

Personally, I prefer the cleanliness of the way code looks when it appears to be native methods. i.e. when you modify native JavaScript prototypes. However, if any app dependency required string.js, then the app's string prototype would be modified in every module. This could be troublesome. So I settled on creating a wrapper a la jQuery style. For those of you prototype hatin' fools, there is the method extendPrototype().

Here's a list of alternative frameworks:

Prototype Framework's String library
Uize.String
Google Closure's String
Underscore.string
Sugar.js
php.js
Why wasn't I happy with any of them? They are all static methods that don't seem to support chaining in a clean way 'OR' they have an odd dependency. Sugar is the notable exception.

Installation

If you want to use this library, you first need to install the [Node.js] (https://nodejs.org/en/).

When you install node.js, will also be installed [npm] (https://www.npmjs.com/).

Please run the following command.

npm install --save string
Experiment with String.js Now

Assuming you're on http://stringjs.com, just simply open up the Webkit inspector in either Chrome or Safari, or the web console in Firefox and you'll notice that string.js is included in this page so that you can start experimenting with it right away.

Usage

Node.js
var S = require('string');
Originally, I was using $s but glancing over the code, it was easy to confuse $s for string.js with $ for jQuery. Feel free to use the most convenient variable for you.

Rails
Checkout this gem to easily use string.js on the asset pipeline: https://github.com/jesjos/stringjs-rails

Browsers
<!-- HTML5 -->
<script src="https://cdn.rawgit.com/jprichardson/string.js/master/dist/string.min.js"></script>
 
<!-- Note that in the mime type for Javascript is now officially 'application/javascript'. If you
set the type to application/javascript in IE browsers, your Javacript will fail. Just don't set a
type via the script tag and set the mime type from your server. Most browsers look at the server mime
type anyway -->
 
<!-- For HTML4/IE -->
<script type="text/javascript" src="https://cdn.rawgit.com/jprichardson/string.js/master/dist/string.min.js"></script>
A global variable window.S or simply S is created.

AMD Support
It now has AMD support. See require.js on how to use with AMD modules.

Both
var doesIt = S('my cool string').left(2).endsWith('y'); //true 
Access the wrapped string using s variable or toString()

var name = S('Your name is JP').right(2).s; //'JP' 
is the same as…

var name = S('Your name is JP').right(2).toString(); //'JP' 
Still like the clean look of calling these methods directly on native Strings? No problem. Call extendPrototype(). Make sure to not call this at the module level, at it'll effect the entire application lifecycle. You should really only use this at the method level. The one exception being if your application will not be a dependency of another application.

S.extendPrototype();
var name = 'Your name is JP'.right(2); //'JP' 
S.restorePrototype(); //be a good citizen and clean up 
Browser Compatibility
string.js has been designed to be compatible with Node.js and with IE6+, Firefox 3+, Safari 2+, Chrome 3+. Please click here to run the tests in your browser. Report any browser issues here: https://github.com/jprichardson/string.js/issues

Extending string.js
See: https://github.com/jprichardson/string.js/pull/57

Native JavaScript Methods

string.js imports all of the native JavaScript methods. This is for convenience. The only difference is that the imported methods return string.js objects instead of native JavaScript strings. The one exception to this is the method charAt(index). This is because charAt() only returns a string of length one. This is typically done for comparisons and a string.js object will have little to no value here.

All of the native methods support chaining with the string.js methods.

Example:

var S = require('string');
 
var phrase = S('JavaScript is the best scripting language ever!');
var sub = 'best scripting';
var pos = phrase.indexOf(sub);
console.log(phrase.substr(pos, sub.length).truncate(8)); //best... 
Methods

See test file for more details.

I use the same nomenclature as Objective-C regarding methods. + means static or class method. - means non-static or instance method.

- constructor(nativeJsString)
This creates a new string.js object. The parameter can be anything. The toString() method will be called on any objects. Some native objects are used in some functions such as toCSV().

Example:

S('hello').s //"hello" 
S(['a,b']).s //"a,b" 
S({hi: 'jp'}).s //"[object Object]"" 
- between(left, right)
Extracts a string between left and right strings.

Example:

S('<a>foo</a>').between('<a>', '</a>').s // => 'foo' 
S('<a>foo</a></a>').between('<a>', '</a>').s // => 'foo' 
S('<a><a>foo</a></a>').between('<a>', '</a>').s // => '<a>foo' 
S('<a>foo').between('<a>', '</a>').s // => '' 
S('Some strings } are very {weird}, dont you think?').between('{', '}').s // => 'weird' 
S('This is a test string').between('test').s // => ' string' 
S('This is a test string').between('', 'test').s // => 'This is a ' 
- camelize()
Remove any underscores or dashes and convert a string into camel casing.

Example:

S('data_rate').camelize().s; //'dataRate' 
S('background-color').camelize().s; //'backgroundColor' 
S('-moz-something').camelize().s; //'MozSomething' 
S('_car_speed_').camelize().s; //'CarSpeed' 
S('yes_we_can').camelize().s; //'yesWeCan' 
- capitalize()
Capitalizes the first character of a string.

Example:

S('jon').capitalize().s; //'Jon' 
S('JP').capitalize().s; //'Jp' 
- chompLeft(prefix)
Removes prefix from start of string.

Example:

S('foobar').chompLeft('foo').s; //'bar' 
S('foobar').chompLeft('bar').s; //'foobar' 
- chompRight(suffix)
Removes suffix from end of string.

Example:

S('foobar').chompRight('bar').s; //'foo' 
S('foobar').chompRight('foo').s; //'foobar' 
- collapseWhitespace()
Converts all adjacent whitespace characters to a single space.

Example:

var str = S('  String   \t libraries are   \n\n\t fun\n!  ').collapseWhitespace().s; //'String libraries are fun !' 
- contains(ss)
Returns true if the string contains ss.

Alias: include()

Example:

S('JavaScript is one of the best languages!').contains('one'); //true 
- count(substring)
Returns the count of the number of occurrences of the substring.

Example:

S('JP likes to program. JP does not play in the NBA.').count("JP")// 2 
S('Does not exist.').count("Flying Spaghetti Monster") //0 
S('Does not exist.').count("Bigfoot") //0 
S('JavaScript is fun, therefore Node.js is fun').count("fun") //2 
S('funfunfun').count("fun") //3 
- dasherize()
Returns a converted camel cased string into a string delimited by dashes.

Examples:

S('dataRate').dasherize().s; //'data-rate' 
S('CarSpeed').dasherize().s; //'-car-speed' 
S('yesWeCan').dasherize().s; //'yes-we-can' 
S('backgroundColor').dasherize().s; //'background-color' 
- decodeHTMLEntities()
Decodes HTML entities into their string representation.

S('Ken Thompson &amp; Dennis Ritchie').decodeHTMLEntities().s; //'Ken Thompson & Dennis Ritchie' 
S('3 &lt; 4').decodeHTMLEntities().s; //'3 < 4' 
- endsWith(ss)
Returns true if the string ends with ss.

Example:

S("hello jon").endsWith('jon'); //true 
- escapeHTML()
Escapes the html.

Example:

S('<div>hi</div>').escapeHTML().s; //&lt;div&gt;hi&lt;/div&gt; 
+ extendPrototype()
Modifies String.prototype to have all of the methods found in string.js.

Example:

S.extendPrototype();
- ensureLeft(prefix)
Ensures string starts with prefix.

Example:

S('subdir').ensureLeft('/').s; //'/subdir' 
S('/subdir').ensureLeft('/').s; //'/subdir' 
- ensureRight(suffix)
Ensures string ends with suffix.

Example:

S('dir').ensureRight('/').s; //'dir/' 
S('dir/').ensureRight('/').s; //'dir/' 
- humanize()
Transforms the input into a human friendly form.

Example:

S('the_humanize_string_method').humanize().s  //'The humanize string method' 
S('ThehumanizeStringMethod').humanize().s //'Thehumanize string method' 
S('the humanize string method').humanize().s  //'The humanize string method' 
S('the humanize_id string method_id').humanize().s //'The humanize id string method' 
S('the  humanize string method  ').humanize().s //'The humanize string method' 
S('   capitalize dash-CamelCase_underscore trim  ').humanize().s //'Capitalize dash camel case underscore trim' 
- include(ss)
Returns true if the string contains the ss.

Alias: contains()

Example:

S('JavaScript is one of the best languages!').include('one'); //true 
- isAlpha()
Return true if the string contains only letters.

Example:

S("afaf").isAlpha(); //true 
S('fdafaf3').isAlpha(); //false 
S('dfdf--dfd').isAlpha(); //false 
- isAlphaNumeric()
Return true if the string contains only letters and numbers

Example:

S("afaf35353afaf").isAlphaNumeric(); //true 
S("FFFF99fff").isAlphaNumeric(); //true 
S("99").isAlphaNumeric(); //true 
S("afff").isAlphaNumeric(); //true 
S("Infinity").isAlphaNumeric(); //true 
S("-Infinity").isAlphaNumeric(); //false 
S("-33").isAlphaNumeric(); //false 
S("aaff..").isAlphaNumeric(); //false 
- isEmpty()
Return true if the string is solely composed of whitespace or is null/undefined.

Example:

S(' ').isEmpty(); //true 
S('\t\t\t    ').isEmpty(); //true 
S('\n\n ').isEmpty(); //true 
S('helo').isEmpty(); //false 
S(null).isEmpty(); //true 
S(undefined).isEmpty(); //true 
- isLower()
Return true if the character or string is lowercase

Example:

S('a').isLower(); //true 
S('z').isLower(); //true 
S('B').isLower(); //false 
S('hijp').isLower(); //true 
S('hi jp').isLower(); //false 
S('HelLO').isLower(); //false 
- isNumeric()
Return true if the string only contains digits

Example:

S("3").isNumeric(); //true 
S("34.22").isNumeric(); //false 
S("-22.33").isNumeric(); //false 
S("NaN").isNumeric(); //false 
S("Infinity").isNumeric(); //false 
S("-Infinity").isNumeric(); //false 
S("JP").isNumeric(); //false 
S("-5").isNumeric(); //false 
S("000992424242").isNumeric(); //true 
- isUpper()
Returns true if the character or string is uppercase

Example:

S('a').isUpper() //false 
S('z').isUpper()  //false 
S('B').isUpper() //true 
S('HIJP').isUpper() //true 
S('HI JP').isUpper() //false 
S('HelLO').isUpper() //true 
- latinise()
Removes accents from Latin characters.

S('crème brûlée').latinise().s // 'creme brulee' 
- left(n)
Return the substring denoted by n positive left-most characters.

Example:

S('My name is JP').left(2).s; //'My' 
S('Hi').left(0).s; //'' 
S('My name is JP').left(-2).s; //'JP', same as right(2) 
- length
Property to return the length of the string object.

Example:

S('hi').length; //2 
- lines()
Returns an array with the lines. Cross-platform compatible.

Example:

var stuff = "My name is JP\nJavaScript is my fav language\r\nWhat is your fav language?"
var lines = S(stuff).lines()
 
console.dir(lines)
/*
[ 'My name is JP',
  'JavaScript is my fav language',
  'What is your fav language?' ]
*/
- pad(len, [char])
Pads the string in the center with specified character. char may be a string or a number, defaults is a space.

Example:

S('hello').pad(5).s //'hello' 
S('hello').pad(10).s //'   hello  ' 
S('hey').pad(7).s //'  hey  ' 
S('hey').pad(5).s //' hey ' 
S('hey').pad(4).s //' hey' 
S('hey').pad(7, '-').s//'--hey--' 
- padLeft(len, [char])
Left pads the string.

Example:

S('hello').padLeft(5).s //'hello' 
S('hello').padLeft(10).s //'     hello' 
S('hello').padLeft(7).s //'  hello' 
S('hello').padLeft(6).s //' hello' 
S('hello').padLeft(10, '.').s //'.....hello' 
- padRight(len, [char])
Right pads the string.

Example:

S('hello').padRight(5).s //'hello' 
S('hello').padRight(10).s //'hello     ' 
S('hello').padRight(7).s //'hello  ' 
S('hello').padRight(6).s //'hello ' 
S('hello').padRight(10, '.').s //'hello.....' 
- parseCSV()
Parses a CSV line into an array.

Arguments:

delimiter: The character that is separates or delimits fields. Default: ,
qualifier: The character that encloses fields. Default: "
escape: The character that represents the escape character. Default: \
lineDelimiter: The character that represents the end of a line. When a lineDelimiter is passed the result will be a multidimensional array. Default: undefined
Example:

S("'a','b','c'").parseCSV(',', "'") //['a', 'b', 'c']) 
S('"a","b","c"').parseCSV() // ['a', 'b', 'c']) 
S('a,b,c').parseCSV(',', null)  //['a', 'b', 'c']) 
S("'a,','b','c'").parseCSV(',', "'") //['a,', 'b', 'c']) 
S('"a","b",4,"c"').parseCSV(',', null) //['"a"', '"b"', '4', '"c"']) 
S('"a","b","4","c"').parseCSV() //['a', 'b', '4', 'c']) 
S('"a","b",       "4","c"').parseCSV() //['a', 'b', '4', 'c']) 
S('"a","b",       4,"c"').parseCSV(",", null) //[ '"a"', '"b"', '       4', '"c"' ]) 
S('"a","b\\"","d","c"').parseCSV() //['a', 'b"', 'd', 'c']) 
S('"a","b\\"","d","c"').parseCSV() //['a', 'b"', 'd', 'c']) 
S('"a\na","b","c"\n"a", """b\nb", "a"').parseCSV(',', '"', '"', '\n')) // [ [ 'a\na', 'b', 'c' ], [ 'a', '"b\nb', 'a' ] ] 
- repeat(n)
Returns a string repeated n times.

Alias: times()

Example:

S(' ').repeat(5).s; //'     ' 
S('*').repeat(3).s; //'***' 
- replaceAll(ss, newstr)
Return the new string with all occurrences of ss replaced with newstr.

Example:

S(' does IT work? ').replaceAll(' ', '_').s; //'_does_IT_work?_' 
S('Yes it does!').replaceAll(' ', '').s; //'Yesitdoes!' 
+ restorePrototype()
Restore the original String prototype. Typically used in conjunction with extendPrototype().

Example:

S.restorePrototype();
- right(n)
Return the substring denoted by n positive right-most characters.

Example:

S('I AM CRAZY').right(2).s; //'ZY' 
S('Does it work?  ').right(4).s; //'k?  ' 
S('Hi').right(0).s; //'' 
S('My name is JP').right(-2).s; //'My', same as left(2) 
- s
Alias: toString()

The encapsulated native string representation of an S object.

Example:

S('my name is JP.').capitalize().s; //My name is JP. 
var a = "Hello " + S('joe!'); //a = "Hello joe!" 
S("Hello").toString() === S("Hello").s; //true 
- setValue(value)
Sets the string to a value.

var myString = S('War');
myString.setValue('Peace').s; // 'Peace' 
- slugify()
Converts the text into a valid url slug. Removes accents from Latin characters.

S('Global Thermonuclear Warfare').slugify().s // 'global-thermonuclear-warfare' 
S('Crème brûlée').slugify().s // 'creme-brulee' 
- splitLeft(sep, [maxSplit = -1, [limit]])
Returns an array of strings, split from the left at sep. Performs at most maxSplit splits, and slices the result into an array with at most limit elements.

Example:

S('We built this city').splitLeft(' '); // ['We', 'built', 'this', 'city']; 
S('We built this city').splitLeft(' ', 1); // ['We', 'built this city']; 
S('On Rock N Roll and other Stuff').splitLeft(' ', -1, 4); // ['On', 'Rock', 'N', 'Roll']; 
S('On Rock N Roll and other Stuff').splitLeft(' ', 5, -2); // ['and', 'other Stuff']; 
- splitRight(sep, [maxSplit = -1, [limit]])
Returns an array of strings, split from the left at sep. Performs at most maxSplit splits, and slices the result into an array with at most limit elements.

Example:

S('This is all very fun').splitRight(' '); // ['This', 'is', 'all', 'very', 'fun']; 
S('and I could do it forever').splitRight(' ', 1); // ['and I could do it', 'forever']; 
S('but nothing matters in the end.').splitRight(' ', -1, 2); // ['the', 'end.']; 
S('but nothing matters in the end.').splitRight(' ', 4, -2); // ['but nothing', 'matters']; 
- startsWith(prefix)
Return true if the string starts with prefix.

Example:

S('JP is a software engineer').startsWith('JP'); //true 
S('wants to change the world').startsWith('politicians'); //false 
- strip([string1],[string2],...)
Returns a new string with all occurrences of [string1],[string2],... removed.

Example:

S(' 1 2 3--__--4 5 6-7__8__9--0').strip(' ', '_', '-').s; //'1234567890' 
S('can words also be stripped out?').strip('words', 'also', 'be').s; //'can    stripped out?' 
- stripLeft([chars])
Returns a new string in which all chars have been stripped from the beginning of the string (default whitespace characters).

Example:

S('  hello ').stripLeft().s; //'hello ' 
S('abcz').stripLeft('a-z').s; //'bcz' 
S('www.example.com').stripLeft('w.').s; //'example.com' 
- stripRight([chars])
Returns a new string in which all chars have been stripped from the end of the string (default whitespace characters).

Example:

S('  hello ').stripRight().s; //'  hello' 
S('abcz').stripRight('a-z').s; //'abc' 
- stripPunctuation()
Strip all of the punctuation.

Example:

S('My, st[ring] *full* of %punct)').stripPunctuation().s; //My string full of punct 
- stripTags([tag1],[tag2],...)
Strip all of the HTML tags or tags specified by the parameters.

Example:

S('<p>just <b>some</b> text</p>').stripTags().s //'just some text' 
S('<p>just <b>some</b> text</p>').stripTags('p').s //'just <b>some</b> text' 
- template(values, [open], [close])
Takes a string and interpolates the values. Defaults to {{ and }} for Mustache compatible templates. However, you can change this default by modifying S.TMPL_OPEN and S.TMPL_CLOSE.

Example:

var str = "Hello {{name}}! How are you doing during the year of {{date-year}}?"
var values = {name: 'JP', 'date-year': 2013}
console.log(S(str).template(values).s) //'Hello JP! How are you doing during the year of 2013?' 
 
str = "Hello #{name}! How are you doing during the year of #{date-year}?"
console.log(S(str).template(values, '#{', '}').s) //'Hello JP! How are you doing during the year of 2013?' 
 
S.TMPL_OPEN = '{'
S.TMPL_CLOSE = '}'
str = "Hello {name}! How are you doing during the year of {date-year}?"
console.log(S(str).template(values).s) //'Hello JP! How are you doing during the year of 2013?' 
- times(n)
Returns a string repeated n times.

Alias: repeat()

Example:

S(' ').times(5).s //'     ' 
S('*').times(3).s //'***' 
- titleCase()
Returns a string with the first letter of each word uppercased, including hyphenated words

Example:

S('Like ice in the sunshine').titleCase().s // 'Like Ice In The Sunshine' 
S('data_rate').titleCase().s // 'Data_Rate' 
S('background-color').titleCase().s // 'Background-Color' 
S('-moz-something').titleCase().s // '-Moz-Something' 
S('_car_speed_').titleCase().s // '_Car_Speed_' 
S('yes_we_can').titleCase().s // 'Yes_We_Can 
 
S('   capitalize dash-CamelCase_underscore trim  ').humanize().titleCase().s // 'Capitalize Dash Camel Case Underscore Trim' 
- toBoolean() / toBool()
Converts a a logical truth string to boolean. That is: true, 1, 'true', 'on', or 'yes'.

JavaScript Note: You can easily convert truthy values to booleans by prefixing them with !!. e.g. !!'hi' === true or !!'' === false or !!{} === true.

Example:

S('true').toBoolean() //true 
S('false').toBoolean() //false 
S('hello').toBoolean() //false 
S(true).toBoolean() //true 
S('on').toBoolean() //true 
S('yes').toBoolean() //true 
S('TRUE').toBoolean() //true 
S('TrUe').toBoolean() //true 
S('YES').toBoolean() //true 
S('ON').toBoolean() //true 
S('').toBoolean() //false 
S(undefined).toBoolean() //false 
S('undefined').toBoolean() //false 
S(null).toBoolean() //false 
S(false).toBoolean() //false 
S({}).toBoolean() //false 
S(1).toBoolean() //true 
S(-1).toBoolean() //false 
S(0).toBoolean() //false 
- toCSV(options)
Converts an array or object to a CSV line.

You can either optionally pass in two string arguments or pass in a configuration object.

String Arguments:

delimiter: The character that is separates or delimits fields. Default: ,
qualifier: The character that encloses fields. Default: "
Object Configuration:

delimiter: The character that is separates or delimits fields. Default: ,
qualifier: The character that encloses fields. Default: "
escape: The character that escapes any incline qualifier characters. Default: \, in JS this is \\
encloseNumbers: Enclose number objects with the qualifier character. Default: true
keys: If the input isn't an array, but an object, then if this is set to true, the keys will be output to the CSV line, otherwise it's the object's values. Default: false.
Example:

S(['a', 'b', 'c']).toCSV().s //'"a","b","c"' 
S(['a', 'b', 'c']).toCSV(':').s //'"a":"b":"c"' 
S(['a', 'b', 'c']).toCSV(':', null).s //'a:b:c') 
S(['a', 'b', 'c']).toCSV('*', "'").s //"'a'*'b'*'c'" 
S(['a"', 'b', 4, 'c']).toCSV({delimiter: ',', qualifier: '"', escape: '\\',  encloseNumbers: false}).s //'"a\\"","b",4,"c"' 
S({firstName: 'JP', lastName: 'Richardson'}).toCSV({keys: true}).s //'"firstName","lastName"' 
S({firstName: 'JP', lastName: 'Richardson'}).toCSV().s //'"JP","Richardson"' 
- toFloat([precision])
Return the float value, wraps parseFloat.

Example:

S('5').toFloat() // 5 
S('5.3').toFloat()  //5.3 
S(5.3).toFloat()  //5.3 
S('-10').toFloat()  //-10 
S('55.3 adfafaf').toFloat() // 55.3 
S('afff 44').toFloat()  //NaN 
S(3.45522222333232).toFloat(2) // 3.46 
- toInt() / toInteger()
Return the number value in integer form. Wrapper for parseInt(). Can also parse hex values.

Example:

S('5').toInt(); //5 
S('5.3').toInt(); //5; 
S(5.3).toInt(); //5; 
S('-10').toInt(); //-10 
S('55 adfafaf').toInt(); //55 
S('afff 44').toInt(); //NaN 
S('0xff').toInt() //255 
- toString()
Alias: s

Return the string representation of an S object. Not really necessary to use. However, JS engines will look at an object and display its toString() result.

Example:

S('my name is JP.').capitalize().toString(); //My name is JP. 
var a = "Hello " + S('joe!'); //a = "Hello joe!" 
S("Hello").toString() === S("Hello").s; //true 
- trim()
Return the string with leading and trailing whitespace removed. Reverts to native trim() if it exists.

Example:

S('hello ').trim().s; //'hello' 
S(' hello ').trim().s; //'hello' 
S('\nhello').trim().s; //'hello' 
S('\nhello\r\n').trim().s; //'hello' 
S('\thello\t').trim().s; //'hello' 
- trimLeft()
Return the string with leading and whitespace removed

Example:

S('  How are you?').trimLeft().s; //'How are you?'; 
- trimRight()
Return the string with trailing whitespace removed.

Example:

S('How are you?   ').trimRight().s; //'How are you?'; 
- truncate(length, [chars])
Truncates the string, accounting for word placement and character count.

Example:

S('this is some long text').truncate(3).s //'...' 
S('this is some long text').truncate(7).s //'this is...' 
S('this is some long text').truncate(11).s //'this is...' 
S('this is some long text').truncate(12).s //'this is some...' 
S('this is some long text').truncate(11).s //'this is...' 
S('this is some long text').truncate(14, ' read more').s //'this is some read more' 
- underscore()
Returns converted camel cased string into a string delimited by underscores.

Example:

S('dataRate').underscore().s; //'data_rate' 
S('CarSpeed').underscore().s; //'car_speed' 
S('yesWeCan').underscore().s; //'yes_we_can' 
- unescapeHTML()
Unescapes the html.

Example:

S('&lt;div&gt;hi&lt;/div&gt;').unescapeHTML().s; //<div>hi</div> 
- wrapHTML()
wrapHTML helps to avoid concatenation of element with string. the string will be wrapped with HTML Element and their attributes.

Example:

S('Venkat').wrapHTML().s //<span>Venkat</span> 
S('Venkat').wrapHTML('div').s //<div>Venkat</div> 
S('Venkat').wrapHTML('div', {
    "class": "left bullet"
}).s //<div class="left bullet">Venkat</div> 
S('Venkat').wrapHTML('div', {
    "id": "content",
    "class": "left bullet"
}).s // <div id="content" class="left bullet">Venkat</div> 
+ VERSION
Returns native JavaScript string containing the version of string.js.

Example:

S.VERSION; //1.0.0 
Quirks

decodeHtmlEntities() converts &nbsp; to 0xa0 (160) and not 0x10 (20). Most browsers consider 0xa0 to be whitespace characters, Internet Explorer does not despite it being part of the ECMA standard. Google Closure does a good job of normalizing this behavior. This may need to be fixed in string.js at some point in time.

Testing

Node.js
Install the dev dependencies:

$ npm install string --development
Install mocha globally:

$ npm install -g mocha
Then navigate to the installed directory:

$ cd node_modules/string/
Run test package:

$ mocha test
Browser
Click here to run the tests in your web browser.

Credits

I have looked at the code by the creators in the libraries mentioned in Motivation. As noted in the source code, I've specifically used code from Google Closure (Google Inc), Underscore String Esa-Matti Suuronen, and php.js (http://phpjs.org/authors/index), Substack and TJ Holowaychuk.

Contributions

If you contribute to this library, just modify string.js, string.test.js, and update README.md. I'll update the website docs and generate the new string.min.js, changelog and version.

Contributors
(You can add your name, or I'll add it if you forget)

[*] JP Richardson
[4] Azharul Islam
[3] Sergio Muriel
[1] Venkatraman.R
[1] r3Fuze
[1] Matt Hickford
[1] Petr Brzek
[1] Alex Zinchenko
[1] Guy Ellis
[*] Leonardo Otero
[*] Jordan Scales
[*] Eduardo de Matos
[*] Christian Maughan Tegnér
[*] Mario Gutierrez
[*] Sean O'Dell
[*] Tim de Koning
[*] David Volm
[*] Jeff Grann
[*] Vlad GURDIGA
[*] Jon Principe
[*] James Manning
[*] Nathan Friedly
[*] Alison Rowland
[*] Pascal Bihler
[*] Daniel Diekmeier
Roadmap to v2.0

break up this module into smaller logically grouped modules. The Node.js version would probably always include most of the functions. https://github.com/jprichardson/string.js/issues/10
allow a more functional style similar to Underscore and Lodash. This may introduce a chain function though. https://github.com/jprichardson/string.js/issues/49
language specific plugins i.e. https://github.com/jprichardson/string.js/pull/46
move this repo over to https://github.com/stringjs
License

Licensed under MIT.

Copyright (C) 2012-2016 JP Richardson jprichardson@gmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.