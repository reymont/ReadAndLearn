package com.atguigu.gmall;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.hystrix.EnableHystrix;

import com.alibaba.dubbo.config.spring.context.annotation.EnableDubbo;

@EnableDubbo
@EnableHystrix
@SpringBootApplication
public class BootOrderServiceConsumerApplication {

	public static void main(String[] args) {
		SpringApplication.run(BootOrderServiceConsumerApplication.class, args);
	}
}
