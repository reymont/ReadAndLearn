Maven plugin中的lifecycle、phase、goal、mojo概念及作用的理解

http://blog.sina.com.cn/s/blog_53baf41b0100phux.html

首先，说些题外话，maven的plugin真的很容易写，很多时候，我们只是被plugin这个词吓倒了，总以为插件这玩意，是专家才能写的，我maven都没精通，怎么写得出自己的plugin呢，其实不然，起码在maven中，写一个自己的plugin还是非常简单的，其它软件的插件，要看情况，有些的确是要天才级人物才写得出，有一些呢，也无非是用别人做的傻瓜程序，可以轻松做出来，但是，有决心做，绝大数事情我们是做得到的！
      要写自己的maven plugin的话，lifecycle与phase与goal与mojo的概念是一定要理解的，下面是我自己的一些见解
lifecycle：生命周期，这是maven最高级别的的控制单元，它是一系列的phase组成，也就是说，一个生命周期，就是一个大任务的总称，不管它里面分成多少个子任务，反正就是运行一个lifecycle，就是交待了一个任务，运行完后，就得到了一个结果，中间的过程，是phase完成的，自己可以定义自己的lifecycle，包含自己想要的phase
常见的lifecycle有 | clean | package ear | pageage jar | package war | site等等
phase：可以理解为任务单元，lifecycle是总任务，phase就是总任务分出来的一个个子任务，但是这些子任务是被规格化的，它可以同时被多个lifecycle所包含，一个lifecycle可以包含任意个phase，phase的执行是按顺序的，一个phase可以绑定很多个goal，至少为一个，没有goal的phase是没有意义的
下面就是一些default lifecycle的phase
validate
initialize
generate-sources
process-sources
generate-resources
process-resources
compile compile
process-classes
generate-test-sources
process-test-sources
generate-test-resources
process-test-resources
test-compile
process-test-classes
test
prepare-package
package
pre-integration-test
integration-test
post-integration-test
verify
install
deploy
goal: 这是执行任务的最小单元，它可以绑定到任意个phase中，一个phase有一个或多个goal，goal也是按顺序执行的，一个phase被执行时，绑定到phase里的goal会按绑定的时间被顺序执行，不管phase己经绑定了多少个goal，你自己定义的goal都可以继续绑到phase中
mojo: lifecycle与phase与goal都是概念上的东西，mojo才是做具体事情的，可以简单理解mojo为goal的实现类，它继承于AbstractMojo，有一个execute方法，goal等的定义都是通过在mojo里定义一些注释的anotation来实现的，maven会在打包时，自动根据这些anotation生成一些xml文件，放在plugin的jar包里
      抛开mojo不讲，lifecycle与phase与goal就是级别的大小问题，引用必须是从高级引用下级（goal绑定到phase，也可理间为phase引用goal，只是在具体绑定时，不会phase定义引用哪些goal，但是执行是，却是phase调用绑定到它那的goal），也不能跨级引用，如lifecycle可以引用任意的phase，不同lifecycle可以同时引用相同的phase，lifecycle不能跨级引用goal。goal会绑定到任意的phase中，也就是说不同的phase可以同时引用相同的goal，所以goal可以在一个lifecycle里被重复执行哦，goal自然也不能说绑定到lifecycle中，它们三者的关系可以用公司里的 总领导，组领导，与职员的关系来解释




创建项目 2012/10/11

创建普通项目

D:\workspace>mvn archetype:create -DgroupId=org.sonatype.mavenbook.ch04 -Dartifa
ctId=simple-weather -DpackageName=org.sonatype.mavenbook -Dversion=1.0

创建web项目

D:\workspace\simple-webapp>mvn archetype:create -DgroupId=org.sonatype.mavenbook.ch05 -DartifactId=simple-webapp -DpackageName=org.sonatype.mavenbook -DarchetypeArtifactId=maven-archetype-webapp





Maven plugin中的lifecycle、phase、goal、mojo概念及作用的理解 


首先，说些题外话，maven的plugin真的很容易写，很多时候，我们只是被plugin这个词吓倒了，总以为插件这玩意，是专家才能写的，我maven都没精通，怎么写得出自己的plugin呢，其实不然，起码在maven中，写一个自己的plugin还是非常简单的，其它软件的插件，要看情况，有些的确是要天才级人物才写得出，有一些呢，也无非是用别人做的傻瓜程序，可以轻松做出来，但是，有决心做，绝大数事情我们是做得到的！
 
      要写自己的maven plugin的话，lifecycle与phase与goal与mojo的概念是一定要理解的，下面是我自己的一些见解
 
lifecycle：生命周期，这是maven最高级别的的控制单元，它是一系列的phase组成，也就是说，一个生命周期，就是一个大任务的总称，不管它里面分成多少个子任务，反正就是运行一个lifecycle，就是交待了一个任务，运行完后，就得到了一个结果，中间的过程，是phase完成的，自己可以定义自己的lifecycle，包含自己想要的phase
 
常见的lifecycle有 | clean | package ear | pageage jar | package war | site等等
 
phase：可以理解为任务单元，lifecycle是总任务，phase就是总任务分出来的一个个子任务，但是这些子任务是被规格化的，它可以同时被多个lifecycle所包含，一个lifecycle可以包含任意个phase，phase的执行是按顺序的，一个phase可以绑定很多个goal，至少为一个，没有goal的phase是没有意义的
 
下面就是一些default lifecycle的phase
validate
initialize
generate-sources
process-sources
generate-resources
process-resources
compile compile
process-classes
generate-test-sources
process-test-sources
generate-test-resources
process-test-resources
test-compile
process-test-classes
test
prepare-package
package
pre-integration-test
integration-test
post-integration-test
verify
install
deploy
 
goal: 这是执行任务的最小单元，它可以绑定到任意个phase中，一个phase有一个或多个goal，goal也是按顺序执行的，一个phase被执行时，绑定到phase里的goal会按绑定的时间被顺序执行，不管phase己经绑定了多少个goal，你自己定义的goal都可以继续绑到phase中
 
mojo: lifecycle与phase与goal都是概念上的东西，mojo才是做具体事情的，可以简单理解mojo为goal的实现类，它继承于AbstractMojo，有一个execute方法，goal等的定义都是通过在mojo里定义一些注释的anotation来实现的，maven会在打包时，自动根据这些anotation生成一些xml文件，放在plugin的jar包里
 
 
      抛开mojo不讲，lifecycle与phase与goal就是级别的大小问题，引用必须是从高级引用下级（goal绑定到phase，也可理间为phase引用goal，只是在具体绑定时，不会phase定义引用哪些goal，但是执行是，却是phase调用绑定到它那的goal），也不能跨级引用，如lifecycle可以引用任意的phase，不同lifecycle可以同时引用相同的phase，lifecycle不能跨级引用goal。goal会绑定到任意的phase中，也就是说不同的phase可以同时引用相同的goal，所以goal可以在一个lifecycle里被重复执行哦，goal自然也不能说绑定到lifecycle中，它们三者的关系可以用公司里的 总领导，组领导，与职员的关系来解释
