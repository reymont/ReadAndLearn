使用Python解析JSON数据的基本方法_python_脚本之家 http://www.jb51.net/article/73450.htm

Python的json模块提供了一种很简单的方式来编码和解码JSON数据。 其中两个主要的函数是 json.dumps() 和 json.loads() ， 要比其他序列化函数库如pickle的接口少得多。 下面演示如何将一个Python数据结构转换为JSON：
import json
 
data = {
'name' : 'ACME',
'shares' : 100,
'price' : 542.23
}
 
json_str = json.dumps(data)

下面演示如何将一个JSON编码的字符串转换回一个Python数据结构：
?
1
data = json.loads(json_str)

如果你要处理的是文件而不是字符串，你可以使用 json.dump() 和 json.load() 来编码和解码JSON数据。例如：
# Writing JSON data
with open('data.json', 'w') as f:
 json.dump(data, f)
 
# Reading data back
with open('data.json', 'r') as f:
 data = json.load(f)
用法示例：
相对于python解析XML来说，我还是比较喜欢json的格式返回，现在一般的api返回都会有json与XML格式的选择，json的解析起来个人觉得相对简单些
先看一个简单的豆瓣的图书查询的api返回
http://api.douban.com/v2/book/isbn/9787218087351
{"rating":{"max":10,"numRaters":79,"average":"9.1","min":0},"subtitle":"","author":["野夫"],"pubdate":"2013-9","tags":[{"count":313,"name":"野夫","title":"野夫"},{"count":151,"name":"散文随笔","title":"散文随笔"},{"count":83,"name":"身边的江湖","title":"身边的江湖"},{"count":82,"name":"土家野夫","title":"土家野夫"},{"count":70,"name":"散文","title":"散文"},{"count":44,"name":"中国文学","title":"中国文学"},{"count":43,"name":"随笔","title":"随笔"},{"count":38,"name":"中国现当代文学","title":"中国现当代文学"}],"origin_title":"","image":"http://img5.douban.com/mpic/s27008269.jpg","binding":"","translator":[],"catalog":"自序 让记忆抵抗n001 掌瓢黎爷n024 遗民老谭n039 乱世游击：表哥的故事n058 绑赴刑场的青春n076 风住尘香花已尽n083 “酷客”李斯n100 散材毛喻原n113 颓世华筵忆黄门n122 球球外传：n一个时代和一只小狗的际遇n141 童年的恐惧与仇恨n151 残忍教育n167 湖山一梦系平生n174 香格里拉散记n208 民国屐痕","pages":"256","images":{"small":"http://img5.douban.com/spic/s27008269.jpg","large":"http://img5.douban.com/lpic/s27008269.jpg","medium":"http://img5.douban.com/mpic/s27008269.jpg"},"alt":"http://book.douban.com/subject/25639223/","id":"25639223","publisher":"广东人民出版社","isbn10":"7218087353","isbn13":"9787218087351","title":"身边的江湖","url":"http://api.douban.com/v2/book/25639223","alt_title":"","author_intro":"郑世平，笔名野夫，网名土家野夫。毕业于武汉大学，曾当过警察、囚徒、书商。曾出版历史小说《父亲的战争》、散文集《江上的母亲》（获台北2010国际书展非虚构类图书大奖，是该奖项第一个大陆得主）、散文集《乡关何处》（被新浪网、凤凰网、新华网分别评为2012年年度好书）。","summary":"1.野夫书稿中被删减最少，最能体现作者观点、情感的作品。n2.文字凝练，具有极强的感染力。以一枝孤笔书写那些就在你我身边的大历史背景下普通人的生活变迁。n3. 柴静口中“一半像警察，一半像土匪”的野夫，以其特有的韵律表达世间的欢笑和悲苦。","price":"32元"}
看起来别提多乱了，现在我们将其格式进行简单的整理
{
rating: {
 max: 10,
 numRaters: 79,
 average: "9.1",
 min: 0
},
subtitle: "",
author: [
 "野夫"
],
pubdate: "2013-9",
tags: [
 {
 count: 313,
 name: "野夫",
 title: "野夫"
 },
 {
 count: 151,
 name: "散文随笔",
 title: "散文随笔"
 },
 {
 count: 83,
 name: "身边的江湖",
 title: "身边的江湖"
 },
 {
 count: 82,
 name: "土家野夫",
 title: "土家野夫"
 },
 {
 count: 70,
 name: "散文",
 title: "散文"
 },
 {
 count: 44,
 name: "中国文学",
 title: "中国文学"
 },
 {
 count: 43,
 name: "随笔",
 title: "随笔"
 },
 {
 count: 38,
 name: "中国现当代文学",
 title: "中国现当代文学"
 }
],
origin_title: "",
image: "http://img5.douban.com/mpic/s27008269.jpg",
binding: "",
translator: [ ],
catalog: "自序 让记忆抵抗 001 掌瓢黎爷 024 遗民老谭 039 乱世游击：表哥的故事 058 绑赴刑场的青春 076 风住尘香花已尽 083 “酷客”李斯 100 散材毛喻原 113 颓世华筵忆黄门 122 球球外传： 一个时代和一只小狗的际遇 141 童年的恐惧与仇恨 151 残忍教育 167 湖山一梦系平生 174 香格里拉散记 208 民国屐痕",
pages: "256",
images: {
 small: "http://img5.douban.com/spic/s27008269.jpg",
 large: "http://img5.douban.com/lpic/s27008269.jpg",
 medium: "http://img5.douban.com/mpic/s27008269.jpg"
},
alt: "http://book.douban.com/subject/25639223/",
id: "25639223",
publisher: "广东人民出版社",
isbn10: "7218087353",
isbn13: "9787218087351",
title: "身边的江湖",
url: "http://api.douban.com/v2/book/25639223",
alt_title: "",
author_intro: "郑世平，笔名野夫，网名土家野夫。毕业于武汉大学，曾当过警察、囚徒、书商。曾出版历史小说《父亲的战争》、散文集《江上的母亲》（获台北2010国际书展非虚构类图书大奖，是该奖项第一个大陆得主）、散文集《乡关何处》（被新浪网、凤凰网、新华网分别评为2012年年度好书）。",
summary: "1.野夫书稿中被删减最少，最能体现作者观点、情感的作品。 2.文字凝练，具有极强的感染力。以一枝孤笔书写那些就在你我身边的大历史背景下普通人的生活变迁。 3. 柴静口中“一半像警察，一半像土匪”的野夫，以其特有的韵律表达世间的欢笑和悲苦。",
price: "32元"
}
下面我们通过python来取出想要的信息，比如我们想要rating,images里的large和summary
import urllib2
import json
 
html = urllib2.urlopen(r'http://api.douban.com/v2/book/isbn/9787218087351')
 
hjson = json.loads(heml.read())
 
print hjson['rating']
print hjson['images']['large']
print hjson['summary']
是不是很简单，其实只要把返回的json格式嵌套搞清楚，json还是比较简单的