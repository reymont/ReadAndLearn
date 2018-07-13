【Akka】Akka中actor的生命周期与DeathWatch监控 - 简书 https://www.jianshu.com/p/16de393ec5b4


Actor的生命周期

在Actor系统中的路径代表一个“地方”，这可能被一个存活着的的actor占用着。最初，路径（除了系统初始化角色）是空的。当actorOf()被调用时，指定一个由通过Props描述给定的路径角色的化身。一个actor化身由路径和一个UID确定。重新启动仅仅交换Props定义的Actor 实例，但化身与UID依然是相同的。
当该actor停止时，化身的生命周期也相应结束了。在这一刻时间上相对应的生命周期事件也将被调用和监管角色也被通知终止结束。化身被停止之后，路径也可以重复被通过actorOf()方法创建的角色使用。在这种情况下，新的化身的名称跟与前一个将是相同的而是UIDs将会有所不同。

一个ActorRef总是代表一个化身（路径和UID）而不只是一个给定的路径。因此，如果一个角色停止，一个新的具有相同名称创建的旧化身的ActorRef不会指向新的。

在另一方面ActorSelection指向该路径（或多个路径在使用通配符时），并且是完全不知道其化身当前占用着它。由于这个原因导致ActorSelection不能被监视到。通过发送识别信息到将被回复包含正确地引用（见通过角色选择集识别角色）的ActorIdentity的ActorSelection来解决当前化身ActorRef存在该路径之下。这也可以用ActorSelection类的resolveOne方法来解决，这将返回一个匹配ActorRef的Future。



启动Hook

启动策略，调用preStart Hook,一般用于初始化资源.在创建一个Actor的时候，会调用构造函数，之后调用preStart。
preStart的默认形式：

def preStart(): Unit = ()
重启Hook

所有的Actor都是被监管的，i.e.以某种失败处理策略与另一个actor链接在一起。如果在处理一个消息的时候抛出的异常，Actor将被重启。这个重启过程包括上面提到的Hook:

要被重启的actor的preRestart被调用，携带着导致重启的异常以及触发异常的消息； 如果重启并不是因为消息的处理而发生的，所携带的消息为None，例如，当一个监管者没有处理某个异常继而被它自己的监管者重启时。 这个方法是用来完成清理、准备移交给新的actor实例的最佳位置。它的缺省实现是终止所有的子actor并调用postStop。
最初actorOf调用的工厂方法将被用来创建新的实例。
新的actor的postRestart方法被调用，携带着导致重启的异常信息。
actor的重启会替换掉原来的actor对象；重启不影响邮箱的内容, 所以对消息的处理将在postRestart hook返回后继续。触发异常的消息不会被重新接收。在actor重启过程中所有发送到该actor的消息将象平常一样被放进邮箱队列中。

preRestart和postRestart的默认形式：

def preRestart(reason: Throwable, message: Option[Any]): Unit = {
  context.children foreach { child ⇒
    context.unwatch(child)
    context.stop(child)
  }
  postStop()
}

def postRestart(reason: Throwable): Unit = {
  preStart()
}
解释一下重启策略的详细内容：

actor被挂起
调用旧实例的 supervisionStrategy.handleSupervisorFailing 方法 (缺省实现为挂起所有的子actor)
调用preRestart方法，从上面的源码可以看出来，preRestart方法将所有的children Stop掉了，并调用postStop回收资源
调用旧实例的supervisionStrategy.handleSupervisorRestarted方法(缺省实现为向所有剩下的子actor发送重启请求)
等待所有子actor终止直到 preRestart 最终结束
再次调用之前提供的actor工厂创建新的actor实例
对新实例调用 postRestart
恢复运行新的actor
终止Hook

postStop hook一般用于回收资源。Actor在被调用postStop之前，会将邮箱中剩下的message处理掉（新的消息变成死信了）。Actor是由UID和Path来唯一标识的，也就是说ActorRef也是通过UID和Path来定位。在Actor被Stop之后，新的Actor是可以用这个Path的，但是旧的ActorRef是不能用的，因为UID不一样。
这个hook保证在该actor的消息队列被禁止后才运行，i.e.之后发给该actor的消息将被重定向到ActorSystem的deadLetters中。
postStop的默认形式：

def postStop(): Unit = ()
各种Hook的顺序关系图解


Akka的actor生命周期示例代码

下面用Kenny类演示生命周期函数的调用顺序：

import akka.actor._

class Kenny extends Actor {
  println("entered the Kenny constructor")
  override def preStart: Unit = {
    println("kenny: preStart")
  }
  override def postStop: Unit ={
    println("kenny: postStop")
  }
  override def preRestart(reason: Throwable, message: Option[Any]): Unit = {
    println("kenny: preRestart")
    println(s" MESSAGE: ${message.getOrElse("")}")
    println(s" REASON: ${reason.getMessage}")
    super.preRestart(reason, message)
  }
  override def postRestart(reason: Throwable): Unit = {
    println("kenny: postRetart")
    println(s" REASON: ${reason.getMessage}")
    super.postRestart(reason)
  }
  def receive = {
    case ForceRestart => throw new Exception("Boom!")
    case _            => println("Kenny received a message")
  }
}

case object ForceRestart

object LifecycleDemo extends App{
  val system = ActorSystem("LifecycleDemo")
  val kenny = system.actorOf(Props[Kenny], name="Kenny")

  println("sending kenny a simple String message")
  kenny ! "hello"
  Thread.sleep(1000)

  println("make kenny restart")
  kenny ! ForceRestart
  Thread.sleep(1000)

  println("stopping kenny")
  system.stop(kenny)

  println("shutting down system")
  system.shutdown
}
pre*和post*方法和actor的构造函数一样，都是用来初始化或关闭actor所需的资源的。
上面的代码中，preRestart和postRestart调用了父类的函数实现，其中postRestart的默认实现中，调用了preStart方法。

打印信息：

sending kenny a simple String message
entered the Kenny constructor
kenny: preStart
Kenny received a message
make kenny restart
kenny: preRestart
 MESSAGE: ForceRestart
 REASON: Boom!
kenny: postStop
[ERROR] [01/16/2016 21:51:46.584] [LifecycleDemo-akka.actor.default-dispatcher-4] [akka://LifecycleDemo/user/Kenny] Boom!
java.lang.Exception: Boom!
    at Examples.Tutorials.Kenny$$anonfun$receive$1.applyOrElse(Test4_LifecycleDemo.scala:24)
    at akka.actor.Actor$class.aroundReceive(Actor.scala:480)
    at Examples.Tutorials.Kenny.aroundReceive(Test4_LifecycleDemo.scala:4)
    at akka.actor.ActorCell.receiveMessage(ActorCell.scala:526)
    at akka.actor.ActorCell.invoke(ActorCell.scala:495)
    at akka.dispatch.Mailbox.processMailbox(Mailbox.scala:257)
    at akka.dispatch.Mailbox.run(Mailbox.scala:224)
    at akka.dispatch.Mailbox.exec(Mailbox.scala:234)
    at scala.concurrent.forkjoin.ForkJoinTask.doExec(ForkJoinTask.java:260)
    at scala.concurrent.forkjoin.ForkJoinPool$WorkQueue.runTask(ForkJoinPool.java:1339)
    at scala.concurrent.forkjoin.ForkJoinPool.runWorker(ForkJoinPool.java:1979)
    at scala.concurrent.forkjoin.ForkJoinWorkerThread.run(ForkJoinWorkerThread.java:107)

entered the Kenny constructor
kenny: postRetart
 REASON: Boom!
kenny: preStart
stopping kenny
shutting down system
kenny: postStop
Actor系统中的监管

在Actor系统中说过，监管描述的是actor之间的关系：监管者将任务委托给下属并对下属的失败状况进行响应。 当一个下属出现了失败（i.e.抛出一个异常），它自己会将自己和自己所有的下属挂起然后向自己的监管者发送一个提示失败的消息。取决于所监管的工作的性质和失败的性质，监管者可以有4种基本选择：

让下属继续执行，保持下属当前的内部状态
重启下属，清除下属的内部状态
永久地终止下属
将失败沿监管树向上传递
重要的是始终要把一个actor视为整个监管树形体系中的一部分，这解释了第4种选择存在的意义（因为一个监管者同时也是其上方监管者的下属），并且隐含在前3种选择中：让actor继续执行同时也会继续执行它的下属，重启一个actor也必须重启它的下属，相似地终止一个actor会终止它所有的下属。被强调的是一个actor的缺省行为是在重启前终止它的所有下属，但这种行为可以用Actor类的preRestart hook来重写；对所有子actor的递归重启操作在这个hook之后执行。

每个监管者都配置了一个函数，它将所有可能的失败原因（i.e.Exception）翻译成以上四种选择之一；注意，这个函数并不将失败actor本身作为输入。我们很快会发现在有些结构中这种方式看起来不够灵活，会希望对不同的下属采取不同的策略。在这一点上我们一定要理解监管是为了组建一个递归的失败处理结构。如果你试图在某一个层次做太多事情，这个层次会变得复杂难以理解，这时我们推荐的方法是增加一个监管层次。

Akka实现的是一种叫“父监管”的形式。Actor只能由其它的actor创建，而顶部的actor是由库来提供的——每一个创建出来的actor都是由它的父亲所监管。这种限制使得actor的树形层次拥有明确的形式，并提倡合理的设计方法。必须强调的是这也同时保证了actor们不会成为孤儿或者拥有在系统外界的监管者（被外界意外捕获）。还有，这样就产生了一种对actor应用(或其中子树)自然又干净的关闭过程。

生命周期监控（临终看护DeathWatch）

在Akka中生命周期监控通常指的是DeathWatch。
除了父actor和子actor的关系的监控关系，每个actor可能还监视着其它任意的actor。因为actor创建后，它活着的期间以及重启在它的监管者之外是看不到的，所以对监视者来说它能看到的状态变化就是从活着变到死亡。所以监视的目的是当一个actor终止时可以有另一个相关actor做出响应，而监管者的目的是对actor的失败做出响应。

监视actor通过接收Terminated消息来实现生命周期监控。如果没有其它的处理方式，默认的行为是抛出一个DeathPactException异常。为了能够监听Terminated消息，你需要调用ActorContext.watch(targetActorRef)。调用ActorContext.unwatch(targetActorRed)来取消对目标角色的监听。需要注意的是，Terminated消息的发送与监视actor注册的时间和被监视角色终止的时间顺序无关。例如，即使在你注册的时候目标actor已经死了，你仍然能够收到Terminated消息。 当监管者不能简单的重启子actor而必须终止它们时，监视将显得非常重要。例如，actor在初始化的时候报错。在这种情况下，它应该监视这些子actor并且重启它们或者稍后再做尝试。
另一个常见的应用案例是，一个actor或者它的子actor在无法获得需要的外部资源时需要失败。如果是第三方通过调用system.stop(child)方法或者发送PoisonPill消息来终止子actor时，监管者也将会受到影响。

说明

为了在其它actor结束时(i.e.永久终止,而不是临时的失败和重启)收到通知，actor可以将自己注册为其它actor在终止时所发布的 Terminated消息的接收者。这个服务是由actor系统的DeathWatch组件提供的。

注册一个监控器的代码：

import akka.actor.{ Actor, Props, Terminated }

class WatchActor extends Actor {
  val child = context.actorOf(Props.empty, "child")
  context.watch(child) // <-- 这是注册所需要的唯一调用
  var lastSender = system.deadLetters

  def receive = {
    case "kill"              ⇒ context.stop(child); lastSender = sender
    case Terminated(`child`) ⇒ lastSender ! "finished"
  }
}
要注意Terminated消息的产生与注册和终止行为所发生的顺序无关。多次注册并不表示会有多个消息产生，也不保证有且只有一个这样的消息被接收到：如果被监控的actor已经生成了消息并且已经进入了队列，在这个消息被处理之前又发生了另一次注册，则会有第二个消息进入队列，因为一个已经终止的actor注册监控器会立刻导致Terminated消息的发生。
可以使用context.unwatch(target)来停止对另一个actor的生存状态的监控，但很明显这不能保证不会接收到Terminated消息因为该消息可能已经进入了队列。

DeathWatch代码示例：

DeathWatch的作用是，当一个actor终止时，你希望另一个actor收到通知。
使用context.watch()方法来声明对一个actor的监控。
下面是示例代码：

import akka.actor._

class Jason extends Actor {
  def receive = {
    case _ => println("jason got a message")
  }
}

class Parent extends Actor {
  // start Jason as a child, then keep an eye on it
  val jason = context.actorOf(Props[Jason], name="Jason")
  context.watch(jason)

  def receive = {
    case Terminated(jason) => println("OMG, they killed jason")
    case _ => println("parent received a message")
  }

}

object DeathWatchDemo extends App{
  val system = ActorSystem("DeathWatchDemo")
  val parentActor = system.actorOf(Props[Parent], name="Parent")

  // look up jason, then kill it
  println("kill the child actor")
  val jasonActor = system.actorSelection("/user/Parent/Jason")
  jasonActor ! PoisonPill

  Thread.sleep(5000)
  println("calling system.shutdown")
  system.shutdown
}
当Jason被杀死后，Parent actor收到Terminated(jason)消息。

转载请注明作者Jason Ding及其出处
Github博客主页(http://jasonding1354.github.io/)
GitCafe博客主页(http://jasonding1354.gitcafe.io/)
CSDN博客(http://blog.csdn.net/jasonding1354)
简书主页(http://www.jianshu.com/users/2bd9b48f6ea8/latest_articles)
Google搜索jasonding1354进入我的博客主页

作者：JasonDing
链接：https://www.jianshu.com/p/16de393ec5b4
來源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。