# http://blog.csdn.net/v2810769/article/details/78292615
# https://www.jianshu.com/p/7af7a7cc30e4

# 版本号
gradle -v
# 生成wrapper
gradle wrapper
./gradlew --refresh-dependencies
# 查看可执行的task
gradlew tasks
# 强制刷新依赖
gradlew –refresh-dependencies
./gradlew -v

./gradlew clean # 清除build文件夹
./gradlew build # 检查依赖并打包
./gradlew assembleDebug # 编译打包Debug包
./gradlew assembleRelease # 编译打包Release包
./gradlew installRelease # 打包并安装Release包
./gradlew unstallRelease # 卸载Release包