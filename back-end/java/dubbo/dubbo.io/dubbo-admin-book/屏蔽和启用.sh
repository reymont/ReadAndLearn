

# 采用代码
# https://github.com/JeffLi1993/springboot-learning-example
# springboot-learning-example\springboot-dubbo-client
# springboot-learning-example\springboot-dubbo-server

# 屏蔽
http://localhost:8080/governance/applications/consumer/services/0/shield?service=org.spring.springboot.dubbo.CityDubboService:1.0.0
# 恢复
http://localhost:8080/governance/applications/consumer/services/0/recover?service=org.spring.springboot.dubbo.CityDubboService:1.0.0