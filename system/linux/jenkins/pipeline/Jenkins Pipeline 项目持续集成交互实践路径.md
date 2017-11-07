

Jenkins Pipeline 项目持续集成交互实践路径 - CSDN博客 
http://blog.csdn.net/boonya/article/details/77941975

# basic

* stage
  * stage 'build'
  * stage concurrency: 3, name: 'test'
* node
  * node('ubuntu'){}
* ws
  * allocate a workspace
  * ws('sub-workspace'){}
* batch
  * bat 'dir'
* sh
  * sh 'mvn -B verify'