

Jenkins 2.0 里使用 Jenkinsfile 设计更好的 Pipeline - Phodal | Phodal - A Growth Engineer https://www.phodal.com/blog/use-jenkinsfile-blue-ocean-visualization-pipeline/
https://github.com/phodal/growth-code

Posted by: Phodal Huang Dec. 1, 2016, 7:04 p.m.
在编写《Growth：全栈 Web 开发思想》的时候，发现了Jenkins 2.0 发现了一个很帅的插件，叫Blue Ocean。

提供了一个高大上的可视化界面，如下：

Blue Ocean

超级直观，有木有，构建流程一目了然。于是，我也做了一个玩玩：

Pipeline

简单的来说，就是编写 Jenkinsfile，即 Pipeline as Code。

Jenkinsfile

Jenkinsfile 是一种基于 Groovy 的 DSL，和 Gradle 的设计思想是一样的，我们也可以编写 Groovy 插件作为扩展。

而一个 Jenkinsfile 也相当的直观，如下是我在书中编写的代码示例：

node {

  stage ('Checkout') {
    git 'https://github.com/phodal/growth-studio'
  }

  stage ('Create Virtualenv') {
    sh './ci/setup.sh'
  }

  stage ('Install') {
    sh './ci/install.sh'
  }

  stage ('Unit Test') {
    sh './ci/unit_test.sh'
  }

  stage ('E2E Test') {
    sh './ci/e2e.sh'
  }

  stage ('Deploy') {
    sh './ci/deploy.sh'
  }
}
上面的每一步里，都是由一个简单的脚本来构成的。在运行的时候，我们可以做到下面的效果：

Jenkinsfile Stage View Example

各个阶段的运行时间一目了然。

而我们所做的只需要在创建项目的时候，选择 Pipeline，并选择 Jenkinsfile 的来源即可：

示例代码：https://github.com/phodal/growth-code