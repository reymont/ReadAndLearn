

Handlebars 模板引擎之前后端用法 - 茄果 - 博客园
 https://www.cnblogs.com/qieguo/p/5811988.html

 不知不觉间，居然已经这么久没有写博客了，坚持还真是世界上最难的事情啊。

不过我最近也没闲着，辞工换工、恋爱失恋、深圳北京都经历了一番，这有起有落的生活实在是太刺激了，就如拿着两把菜刀剁洋葱一样，想想就泪流满面。

弃我去者、昨日之日不可留，乱我心者、今日之日多烦忧，还是说说最近接触到的模板引擎 Handlebars 吧。

Handlebars 简介

先引用下百科的说法：

Handlebars 是 JavaScript 一个语义模板库，通过对view和data的分离来快速构建Web模板。它采用"Logic-less template"（无逻辑模版）的思路，在加载时被预编译，而不是到了客户端执行到代码时再去编译， 这样可以保证模板加载和运行的速度。

好吧，看了有点懵闭。这里关键词就是两个：无逻辑、预加载。所有的模板引擎都是view和data分离，这点不用说。无逻辑准确点来说应该是弱逻辑，毕竟里面还是有一些if、each逻辑在的。你可能看过很多这样写的模板语言：

复制代码
1 <% if (names.length) { %>
2   <ul>
3     <% names.forEach(function(name){ %>
4       <li><%= name %></li>
5     <% }) %>
6   </ul>
7 <% } %>
复制代码
注：闭合的大括号一定不要忘了写哦。

看这种 js 与 HTML 的杂交写法我觉得很眼疼，我的眼里代码的可读性是非常重要的，这种写法真不是我的那杯茶！不过这种模板技术的实现方式倒是值得一探，推荐看看这个20行代码的模板引擎实现：http://blog.jobbole.com/56689/，挺有意思的做法，当然用eval也可以做。

而 Handlebar 的语法就简单精练了许多，比如上面的可以写成：

复制代码
1 {{#if names.length}}
2   <ul>
3     {{#each names}}
4       <li>{{this}}</li>
5     {{/each}}
6   </ul>
7 {{/if}}
复制代码
就喜欢这种一目了然的感觉，当然还有其他的swig、tx出的art-template之类的模板引擎，萝卜青菜各有所爱，就不多说了。

语法基础

语法很简单，就是用大括号将 data 包裹起来。其中两个 {{}} 会将内容做HTML编码转换，这里你输入的HTML标签代码什么的都会按你输入的字符输出；而三个 {{{}}} 的时候则不做转换，你在里面输入<h1>最后是真的能得到一个h1标签的。其他一些规则要素分别有：

1）块级

在 Handlebars里面，每个#就代表了一个局部块，每个块都有自身的作用域范围。举例来说：

1 // 数据
2 hehe: { words: 'hehehehe' }
3 yoyo: { words: 'yoyoyoyo'}
对应的模板：

1 {{#hehe}}
2   <p>{{words}}</p>
3 {{/hehe}}
4 {{#yoyo}}
5   <p>{{words}}</p>
6 {{/yoyo}}
这个例子很好理解，words属性都是根据自身的对象来输出的。这里还是按照块级作用域去理解会比较简单（虽然js并没有块级作用域。。。），也可以用this来指代当前对象。注意，即使是#if、#each也是有作用域的，不要跟js中的作用范围混为一谈。

2）路径

对于对象来说，你可以按照上文的例子一样直接使用 name 的 length 属性，还可以使用使用路径的表达方式去访问对象的其他层级。举个栗子：

复制代码
 1 var post = {
 2   title: "Blog Post!",
 3   author: [{
 4     id: 47,
 5     name: "Jack"
 6   },{
 7     id: 20,
 8     name: "Mark"
 9   }]
10 };
复制代码
模板要这么写：

复制代码
 1 {{#post}}
 2   {{#if author.length}}
 3     <h3>{{title}}</h3>
 4     <ul>
 5       {{#each author}}
 6         <li>{{../title}}'s author is {{name}}</li>
 7       {{/each}}
 8     </ul>
 9   {{/if}}
10 {{/post}}
复制代码
li标签里面已经是在 author 字段之内了，所以要使用 '../' 来转到上层的 title。

3）helper

上面其实已经用过helper了，内置的helper有if、each、unless、with等，当然你也可以自己去写helper。由于Handlebar的弱逻辑属性，如果要实现复杂一点的逻辑就需要去自定义helper。举个栗子：

复制代码
 1 //判断是否是偶数
 2 Handlebars.registerHelper('if_even', function(value, options) {
 3   console.log('value:', value); // value: 2
 4   console.log('this:', this); // this: Object {num: 2}
 5   console.log('fn(this):', options.fn(this)); // fn(this): 2是偶数
 6   if((value % 2) == 0) {
 7     return options.fn(this);
 8   } else {
 9     return options.inverse(this);
10   }
11 });
复制代码
helper是这样用的：

1 {{#if_even num}}
2       {{this.num}}是偶数
3 {{else}}
4       {{this.num}}是奇数
5 {{/if_even}}
当然输出你也能想到，就是根据奇数偶数输出相应信息。我们看看定义的一个function（value, options）{}，这个items就是我们使用模板时候的num，options是一些配置项，这里我们用到的是fn函数，这个函数执行的结果就是编译的结果（这里结果是“2是偶数”这一句话）。另外一个options.inverse就是取反，对应的就是模板里面的else语句了。

but：在模板中过度使用逻辑，实际上就是模糊了模板的专注点，这有违原本数据和表现分离的出发点。我还是认为模板应该专注数据绑定，逻辑应该在数据层做预处理，然后将结果返回给模板，而不是让模板去做各种数据的运算。

4）partial

使用模板引擎最重要的一点就是使用其partial功能，Handlebars里面是按照注册再使用的方式来管理partial的。举个栗子：

1 Handlebars.registerPartial('userMessage',
2   '<{{tagName}}>By {{author.firstName}} {{author.lastName}}</{{tagName}}>'
3   + '<div class="body">{{body}}</div>'
4 );
使用的时候就可以直接使用{{> userMessage}}将这个小块引入到页面中了。这里就是简单的局部替换，所以partial里面的data跟当前页面的data是在同一级的作用域内，也就是说你只要定义好author、body传进去就行了。tagName这个属于表现层的变量，应该在hbs文件里面进行声明，也即是{{> userMessage tagName="h1" }}这样使用。

在前端使用hbs

直接引入js的方式就不多说了，这里我是使用webpack来统一管理各种资源的。Handlebars对应的webpack插件为handlebars-loader，loader的配置非常简单：

1 { 
2   test: /\.hbs$/,
3   loader: "handlebars"
4 }
Handlebars的后缀有两种，全称的handlebars以及简称的hbs，也可以直接用html，但还是跟普通html文件区分开来好一点。

使用模板的好处当然就是可以组件化开发了。我这里采用的目录是这样的：



其中页面组件指的是应用中的页面单元，页面是由各种控件组件组成的，这些都已经是共识了，就不再赘述了。引用的方法有几种：

（1）因为Handlebar编译出来的只是一个字符串，所以我们可以用js作为入口去管理组件，每个组件的js文件引入相应的css和模板，输出为dom字符串。页面引用组件的时候就直接引用js模块得到dom字符串，然后将dom字符串渲染到相应的{{{}}}中去。这种js大一统的方式跟现在主流框架的做法是一样的，可以将逻辑、样式、内容和资源统一起来管理，组件也得内聚性比较强。

复制代码
 1 // header.js
 2 require('./header.scss');
 3 var headerTpl = require('./header.hbs');
 4 var data = {words: "This is header!"}; //data可以用参数传入
 5 var header = headerTpl(data);
 6 module.exports = header;
 7 
 8 // home.hbs
 9 <div class="home">
10   {{{ header }}}
11 <h2>This is {{name}} page.</h2>
12 {{{ footer }}}
13 </div>
14 
15 // home.js
16 require('./home.scss');
17 var header = require('../../component/header/header.js');
18 var footer = require('../../component/footer/footer.js');
19 var homeTpl = require('./home.hbs');
20 var data = {
21   header: header,
22   footer: footer,
23   name: 'home'
24 };
25 var home = homeTpl(data);
26 module.exports = home;
复制代码
（2） 另外的方案就是使用局部模板的方式了，这种方式对一些不带js逻辑的组件非常合适，比如页头页尾这些纯内容的组件。在hbs里面可以直接按照路径去引用particle，然后把引入组件的时候提供partial所需的数据，例如home页面就是这样的：

<div class="home">
  {{> ../../component/header/header}}
  <h2>this is {{}} page</h2>
  {{> ../../component/footer/footer}}
</div>
既然我们已经用了webpack来管理，当然也可以让webpack来处理引用路径了，这里只需要在配置里面声明partial的路径即可直接引用，loader配置：

复制代码
 1 {
 2   test: /\.hbs$/,
 3   loader: "handlebars",
 4   query: {
 5     partialDirs: [
 6       path.join(SRC_PATH, 'component', 'header'),
 7       path.join(SRC_PATH, 'component', 'footer'),
 8       path.join(SRC_PATH, 'page', 'home')
 9     ]
10   }
11 }
复制代码
模板文件：

<div class="home">
  {{> header }}
    <h2>This is {{name}} page.</h2>
  {{> footer }}
</div>
上面列出的几种方式各有优劣，使用partial的方式可以将相应的模板文件集中放到一个view文件夹里面，partialDirs就不用写一大堆路径了。个人还是更偏向于使用第一种方式，每个组件的css、html、js文件做成一个整体的方式，遵循就近管理原则。

Nodejs后端使用hbs

Node后端使用hbs也非常方便，这里我用的是express框架，直接后端渲染。当然更精细的做法就是首屏渲染、仅移动端后端渲染了，在这种混搭的场合模板是可以通用的，这样就减少了一定的开发工作量。目前express中自带4种模板引擎，jade、esj、hogan与hbs，我是使用express-generator来生成项目脚手架的，输入命令为： express --hbs 项目名。

express-generator中的hbs用的是hbs库（https://github.com/donpark/hbs），而并非很多资料介绍的express-handlebars。hbs默认使用layout模板，实际上就是将你的模板文件替换掉{{{body}}}。layout是可配置的，可以在渲染选项中通过layout项来配置。

1 res.render('index', {
2   title: 'Express',
3   head: '<h1>head part</h1>',
4   layout: true  //默认为true，设为false则不启用layout模板
5 });
目前我所接触到的hbs项目都是express+hbs+zepto/jq这一套，如果有用其他前端框架的话，一般也不会用到hbs了，所以只说说这种情况。后端渲染跟前端渲染的开发模式略有差异，但思路还是一样的要做组件化开发。上文说过前端使用hbs的时候是以js为入口，而在后端使用hbs的话个人认为更适合使用局部模板的方式。

我的目录是这样的：



页面统一放入views中，局部模板放入views/partial里面。js和css还是按照官方默认的方式集中管理。使用局部模板要先注册，需要在app.js这个服务器脚本里面加入以下代码：

1 var hbs = require('hbs');
2 hbs.registerPartials(__dirname + '/views/partials');
模板文件中引入小模板：

复制代码
 1 <!DOCTYPE html>
 2 <html>
 3 <head>
 4   <title>{{title}}</title>
 5   <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0">
 6   <link rel="stylesheet" href="/css/main.css"/>
 7   {{> resource}}
 8 </head>
 9 <body>
10 {{> header}}
11 <div class="container">
12   {{{body}}}
13 </div>
14 {{> footer}}
15 </body>
16 </html>
复制代码
resource模板主要是控制不同页面引入的不同资源：

1 {{#each css}}
2   <link rel='stylesheet' href={{this}} />
3 {{/each}}
4 {{#each js}}
5   <script src={{this}}></script>
6 {{/each}}
页面渲染的时候就是这样的：

1 res.render('index', {
2   title: 'Express',
3   css: ['/css/home.css', '/css/home_add.css'],
4   js: ['/js/home.js'],
5   name: "茄果" //这个是页面中用到的数据，与title同一性质
6 });
这种方式的一个问题就是css、js这些资源的写法跟我们平常直接在html引用的方式不一样。比如我想资源引用写在页面中，比如home.hbs里面，如果直接写入home.hbs里面的话，内容是直接插入到{{{body}}}的位置，但我们想要的是在head的位置啊。这个如何实现呢？之前我们定义partial只是为了简单的替换，这一次除了替换还要做一个插入dom的操作，这个就要用到helper来帮我们完成了。很多时候我们要把css放入头部，而把js放在页面尾部，所以layout文件要改造成：

复制代码
 1 <!DOCTYPE html>
 2 <html>
 3 <head>
 4   <title>{{title}}</title>
 5   <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=0">
 6   <link rel="stylesheet" href="/css/main.css"/>
 7   {{#each cssList}}
 8     <link rel='stylesheet' href={{this}} />
 9   {{/each}}
10 </head>
11 <body>
12 {{> header}}
13 <div class="container">
14   {{{body}}}
15 </div>
16 {{> footer}}
17 {{#each jsList}}
18   <script src={{this}}></script>
19 {{/each}}
20 </body>
21 </html>
复制代码
现在只要注册helper把hbs文件中定义的值传入cssList、jsList中即可。另外还要考虑到页面组件引用的时候可能会出现重复依赖的情况，所以要做一个去重的工作。注册helper与注册partial一样，都要写在app.js文件中，下面给出css的写法，js也类似：

复制代码
 1 hbs.registerHelper('css', function(str, option) {
 2   var cssList = this.cssList || [];
 3   str = str.split(/[,，;；]/);
 4   console.log('css: ',str);
 5   str.forEach(function (item) {
 6     if(cssList.indexOf(item)<0) {
 7       cssList.push(item);
 8     }
 9   });
10   this.cssList = cssList.concat();
11 });
复制代码
页面中引入css、js就应该是这样：

{{css "/css/home_add.css"}}
{{js "/js/home.js"}}
{{> p}}
<p>This is home page!</p>
上面例子中的局部模板p作为一个组件，也引用了相应的css和js，写法跟页面的写法是一样的。

总结

handlebars作为一个非常轻量级的模板引擎，单纯从模板这个功能上看，他的前后端通用性强，命令简单明了，代码可读性强。但他是一个单纯的模板引擎，在前端框架满天飞的年代感觉是有点弱了。无论是前端还是后端，各种大框架都有渲染模块。当然不喜欢大框架的全家桶倒是可以考虑使用handlebars，所以主要还是要看项目吧。青菜萝卜，各有所好。