

http://www.runoob.com/ruby/ruby-json.html

Ruby JSON
本章节我们将为大家介绍如何使用 Ruby 语言来编码和解码 JSON 对象。
环境配置
在使用 Ruby 编码或解码 JSON 数据前，我们需要先安装 Ruby JSON 模块。在安装该模块前你需要先安装 Ruby gem，我们使用 Ruby gem 安装 JSON 模块。 但是，如果你使用的是最新版本的 Ruby，可能已经安装了 gem，解析来我们就可以使用以下命令来安装Ruby JSON 模块：
$gem install json
使用 Ruby 解析 JSON
以下为JSON数据，将该数据存储在 input.json 文件中：
input.json 文件
{
  "President": "Alan Isaac",
  "CEO": "David Richardson",
  
  "India": [
    "Sachin Tendulkar",
    "Virender Sehwag",
    "Gautam Gambhir",
  ],
 
  "Srilanka": [
    "Lasith Malinga",
    "Angelo Mathews",
    "Kumar Sangakkara"
  ],
 
  "England": [
    "Alastair Cook",
    "Jonathan Trott",
    "Kevin Pietersen"
  ]
}
以下的 Ruby 程序用于解析以上 JSON 文件；
实例
#!/usr/bin/ruby
require 'rubygems'
require 'json'
require 'pp'
 
json = File.read('input.json')
obj = JSON.parse(json)
 
pp obj
以上实例执行结果为：
{"President"=>"Alan Isaac",
 "CEO"=>"David Richardson",

 "India"=>
  ["Sachin Tendulkar", "Virender Sehwag", "Gautam Gambhir"],

"Srilanka"=>
  ["Lasith Malinga ", "Angelo Mathews", "Kumar Sangakkara"],

 "England"=>
  ["Alastair Cook", "Jonathan Trott", "Kevin Pietersen"]
}