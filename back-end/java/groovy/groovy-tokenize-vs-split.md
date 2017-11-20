

Groovy : tokenize() vs split() - 推酷 https://www.tuicool.com/articles/IV3I7r

Groovy : tokenize() vs split()
时间 2013-03-14 20:35:35  Intelligrape Groovy & Grails Blogs
原文  http://www.intelligrape.com/blog/2013/03/14/groovy-tokenize-vs-split/
主题 Groovy
The split() method returns a string [] instance and the  tokenize() method returns a List instance
 tokenize() ,which returns a List ,will ignore empty string (when a delimeter appears twice in  succession) where as split() keeps such string.
String testString = 'hello brother'
assert testString.split() instanceof String[]
assert ['hello','brother']==testString.split() //split with no arguments
assert['he','','o brother']==testString.split('l')
// split keeps empty string
assert testString.tokenize() instanceof List
assert ['hello','brother']==testString.tokenize() //tokenize with no arguments
assert ['he','o brother']==testString.tokenize('l')
//tokenize ignore empty string
The tokenize() method uses each character of a String as delimeter where as split()  takes the entire string as  delimeter
String  testString='hello world'
assert ['hel',' world']==testString.split('lo')
assert ['he',' w','r','d']==testString.tokenize('lo')
The split()  can take regex as delimeter  where as  tokenize does not.
String testString='hello world 123 herload'
assert['hello world ',' herload']==testString.split(/\d{3}/)
I hope it helps, feel free to ask if you have any queries

This entry was posted on March 14th, 2013 at 6:05 pm and is filed under Grails . You can follow any responses to this entry through the RSS 2.0 feed. You can leave a response , or trackback from your own site.