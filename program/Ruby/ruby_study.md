#Ruby Study

##国内社区
- [Ruby 程序设计语言官方网站 ](https://www.ruby-lang.org/zh_cn/)

##官方手册
- [Class: String (Ruby 2.2.0)](https://ruby-doc.org/core-2.2.0/String.html) 
- [中文文档](https://www.ruby-lang.org/zh_cn/documentation/)


##安装
- [安装 Ruby | rubyinstaller](https://www.ruby-lang.org/zh_cn/documentation/installation/#rubyinstaller)
- [RailsInstaller ](http://railsinstaller.org/en)

#入门
- [Getting started with Ruby on Windows 10 and Visual Studio Code | ARossignoli's dev blog ](https://arossignoli.wordpress.com/2016/01/10/getting-started-with-ruby-on-windows-10-and-visual-studio-code/)
ruby windows 开发还是用**cygwin**靠谱


#手册
手册
- [Programming Ruby](http://www.ruby-doc.org/docs/ProgrammingRuby/)
最有影响的 Ruby 英文教材，Pragmatic Programmers 出版的第一版可以在网上免费阅读。
- [Ruby 用户指南](http://www.rubyist.net/~slagell/ruby/)
译自松本行弘（Ruby 的发明者）的日文版原作，Goto Kentaro 和 Mark Slagell 在这部教材里介绍了 Ruby 各个方面的功能。
- [Ruby 编程百科全书](http://en.wikibooks.org/wiki/Ruby_programming_language)
免费的在线语言参考资料，内容从 Ruby 初级到中级。

##字符串

###字符串拆分

- [Class: String (Ruby 2.2.0) | method-i-split](https://ruby-doc.org/core-2.2.0/String.html#method-i-split)


#类
- [A Beginner's Guide to Ruby Getters and Setters ](https://blog.metova.com/a-beginners-guide-to-ruby-getters-and-setters/)
```ruby
class Foo
  attr_accessor :bar, :baz
end

foo = Foo.new #=> #<Foo:0x007fada99c2d00>
foo.bar #=> nil
foo.bar = 'jelly' #=> "jelly"
foo.bar #=> "jelly"
foo.baz #=> nil
foo.baz = 'time' #=> "time"
foo.baz #=> "time"
```

