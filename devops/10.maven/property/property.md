property 2012/11/12

实际上，maven支持6大类property

1.上面说所的自定义属性
2.Maven内置属性，如${basedir}表示项目根目录
3.POM属性，如${project.artifactId}, ${project.build.sourceDirectory}
4.Settings属性，如${settings.localRepository}
5.Java系统属性，如${user.home}
6.环境变量属性，如${env.JAVA_HOME}
