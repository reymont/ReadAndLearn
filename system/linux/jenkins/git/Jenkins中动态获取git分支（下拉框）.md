

Jenkins中动态获取git分支（下拉框） - CSDN博客
 http://blog.csdn.net/heboblog/article/details/49364363

 def gettags = ("git ls-remote -h https://ip:port/xxx/xxx.git").execute()
gettags.text.readLines().collect { it.split()[1].replaceAll('refs/heads/', '')  }.unique()