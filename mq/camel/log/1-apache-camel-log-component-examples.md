Apache Camel Log Component Examples | Java Code Geeks - 2018 https://www.javacodegeeks.com/2015/05/apache-camel-log-component-examples.html?utm_source=tuicool&utm_medium=referral

Apache Camel Log Component Examples
You want to log messages to the underlying logging mechanism, use camel’s log: component. Camel uses sfl4j as the logger API and then allows you to configure the logger implementation. In this article, we will use Log4j as the actual logger mechanism. Let’s start with our examples.
Dependencies
You need to add:
slf4j-api – SLF4J Logger API
slf4j-log4j12 – Log4j as the Logger Implementation
pom.xml:
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<groupId>com.javarticles.camel</groupId>
	<artifactId>camelHelloWorld</artifactId>
	<version>0.0.1-SNAPSHOT</version>
	<dependencies>
		<dependency>
			<groupId>org.apache.camel</groupId>
			<artifactId>camel-core</artifactId>
			<version>2.15.1</version>
		</dependency>
		<dependency>
			<groupId>org.apache.camel</groupId>
			<artifactId>camel-stream</artifactId>
			<version>2.15.1</version>
		</dependency>
		<dependency>
			<groupId>org.apache.camel</groupId>
			<artifactId>camel-jms</artifactId>
			<version>2.15.1</version>
		</dependency>
		<dependency>
			<groupId>org.apache.activemq</groupId>
			<artifactId>activemq-camel</artifactId>
			<version>5.6.0</version>
		</dependency>
		<dependency>
			<groupId>org.springframework</groupId>
			<artifactId>spring-context</artifactId>
			<version>4.1.5.RELEASE</version>
		</dependency>
		<dependency>
			<groupId>org.apache.camel</groupId>
			<artifactId>camel-spring</artifactId>
			<version>2.15.1</version>
		</dependency>
		<dependency>
			<groupId>org.slf4j</groupId>
			<artifactId>slf4j-api</artifactId>
			<version>1.7.12</version>
		</dependency>
		<dependency>
			<groupId>org.slf4j</groupId>
			<artifactId>slf4j-log4j12</artifactId>
			<version>1.7.12</version>
		</dependency>

	</dependencies>
</project>
Log Component URI Format
log’s uri format:
log:loggingCategory[?options]
You can use options to set the level or formatting options. For example:
log:com.javarticles?level=INFO
In my log4.properties, the root logger logs to file as well as console whereas it logs only to file for category com.javarticles. log4j.properties:
# Root logger option
log4j.rootLogger=INFO, file, console

log4j.logger.com.javarticles=INFO, file

# Direct log messages to a log file
log4j.appender.file=org.apache.log4j.FileAppender
log4j.appender.file.File=javarticles.log
log4j.appender.file.layout=org.apache.log4j.PatternLayout
log4j.appender.file.layout.ConversionPattern=%d | %p | %F %L | %m%n
 
# Direct log messages to stdout
log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.Target=System.out
log4j.appender.console.layout=org.apache.log4j.PatternLayout
log4j.appender.console.layout.ConversionPattern=%d{HH:mm}| %p | %F %L | %m%n
Camel Log Component Examples
CamelLogExample:
package com.javarticles.camel.components;

import org.apache.camel.CamelContext;
import org.apache.camel.ProducerTemplate;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.impl.DefaultCamelContext;
import org.apache.camel.util.jndi.JndiContext;

public class CamelLogExample {
	public static final void main(String[] args) throws Exception {
		JndiContext jndiContext = new JndiContext();
		jndiContext.bind("stringUtils", new StringUtils());
		CamelContext camelContext = new DefaultCamelContext(jndiContext);
		try {
			camelContext.addRoutes(new RouteBuilder() {
				public void configure() {
					from("direct:logExample")
					        .log("Before converting to uppercase")
					        .to("log:?level=INFO&showBody=true")
							.to("bean:stringUtils?method=upperCase")
							.log("After converting to uppercase")
							.to("log:com.javarticles?level=INFO&showAll=true");
				}
			});
			ProducerTemplate template = camelContext.createProducerTemplate();
			camelContext.start();
			template.sendBody("direct:logExample", "Log me!");
		} finally {
			camelContext.stop();
		}
	}
}
Output:
12:09| INFO | DefaultCamelContext.java 2454 | Apache Camel 2.15.1 (CamelContext: camel-1) started in 0.307 seconds
12:09| INFO | MarkerIgnoringBase.java 95 | Before converting to uppercase
12:09| INFO | MarkerIgnoringBase.java 95 | Exchange[ExchangePattern: InOnly, BodyType: String, Body: Log me!]
12:09| INFO | MarkerIgnoringBase.java 95 | After converting to uppercase
12:09| INFO | MarkerIgnoringBase.java 95 | Exchange[Id: ID-INMAA1-L1005-54363-1431153589693-0-2, ExchangePattern: InOnly, Properties: {CamelCreatedTimestamp=Sat May 09 12:09:50 IST 2015, CamelMessageHistory=[DefaultMessageHistory[routeId=route1, node=log1], DefaultMessageHistory[routeId=route1, node=to1], DefaultMessageHistory[routeId=route1, node=to2], DefaultMessageHistory[routeId=route1, node=log2], DefaultMessageHistory[routeId=route1, node=to3]], CamelToEndpoint=log://com.javarticles?level=INFO&showAll=true}, Headers: {breadcrumbId=ID-INMAA1-L1005-54363-1431153589693-0-1}, BodyType: String, Body: LOG ME!, Out: null: ]
12:09| INFO | DefaultCamelContext.java 2660 | Apache Camel 2.15.1 (CamelContext: camel-1) is shutting down
Custom Exchange Formatter
If you notice in the above log that even for the showBody=true case, it prints the payload as well as the exchange related properties like ExchangePattern and BodyType. We can customize what we want to see in the log. Let’s see how we can achieve it. Implement a custom formatter class by implementing ExchangeFormatter interface. Chose from the Exchange object what elements we want to log. In our custom exchange formatter, we just want to see the payload text so format(Exchange) returns is the inbound request message. MyExchangeFormatter:
package com.javarticles.camel.components;

import org.apache.camel.Exchange;
import org.apache.camel.spi.ExchangeFormatter;

public class MyExchangeFormatter implements ExchangeFormatter {

    public String format(Exchange exchange) {
        return exchange.getIn().getBody(String.class);
    }

}
You need to bind the foamtter object against key logFormatter.
jndiContext.bind("logFormatter", new MyExchangeFormatter());
CamelLogExchangeFormatterExample:
package com.javarticles.camel.components;

import org.apache.camel.CamelContext;
import org.apache.camel.ProducerTemplate;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.impl.DefaultCamelContext;
import org.apache.camel.util.jndi.JndiContext;

public class CamelLogExchangeFormatterExample {
	public static final void main(String[] args) throws Exception {
		JndiContext jndiContext = new JndiContext();
		jndiContext.bind("stringUtils", new StringUtils());
		jndiContext.bind("logFormatter", new MyExchangeFormatter());
		CamelContext camelContext = new DefaultCamelContext(jndiContext);
		try {
			camelContext.addRoutes(new RouteBuilder() {
				public void configure() {
					from("direct:logExample")
					        .log("Before converting to uppercase")
					        .to("log:?level=INFO")
							.to("bean:stringUtils?method=upperCase")
							.log("After converting to uppercase")
							.to("log:com.javarticles?level=INFO");
				}
			});
			ProducerTemplate template = camelContext.createProducerTemplate();
			camelContext.start();
			template.sendBody("direct:logExample", "Log me!");
		} finally {
			camelContext.stop();
		}
	}
}
StringUtils:
package com.javarticles.camel.components;


public class StringUtils {
	public String upperCase(String msg) {
		return msg.toUpperCase();
	}
}
Output:
14:28| INFO | MarkerIgnoringBase.java 95 | Before converting to uppercase
14:28| INFO | MarkerIgnoringBase.java 95 | Log me!
14:28| INFO | MarkerIgnoringBase.java 95 | After converting to uppercase
14:28| INFO | MarkerIgnoringBase.java 95 | LOG ME!
Throughput logger Example
Messages (numbers in our case) are sent to the activemq queue numbers, the next destination in the route will log the message statistics every 10s. The interval is configured using groupInterval=10000 option.
<route>
    <from uri="activemq:queue:numbers" />
    <to uri="log:com.javarticles?level=INFO&groupInterval=10000" />
</route>
applicationContext.xml:
<?xml version="1.0" encoding="UTF-8"?>

<beans xmlns="http://www.springframework.org/schema/beans"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="
        http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
        http://camel.apache.org/schema/spring http://camel.apache.org/schema/spring/camel-spring.xsd
       ">
	<bean id="connectionFactory" class="org.apache.activemq.ActiveMQConnectionFactory">
		<property name="brokerURL" value="vm://localhost?broker.persistent=false" />
	</bean>
	<bean id="activemq" class="org.apache.activemq.camel.component.ActiveMQComponent">
		<property name="connectionFactory" ref="connectionFactory" />
	</bean>
	<camelContext xmlns="http://camel.apache.org/schema/spring">
		<route>
			<from uri="activemq:queue:numbers" />
			<to uri="log:com.javarticles?level=INFO&groupInterval=10000" />
		</route>
	</camelContext>	
</beans>
CamelThroughputLoggerExample:
package com.javarticles.camel.components;

import org.apache.camel.CamelContext;
import org.apache.camel.ProducerTemplate;
import org.apache.camel.spring.SpringCamelContext;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

public class CamelThroughputLoggerExample {
	public static final void main(String[] args) throws Exception {
		ApplicationContext appContext = new ClassPathXmlApplicationContext(
				"applicationContext.xml");
		CamelContext camelContext = SpringCamelContext.springCamelContext(
				appContext, false);
		try {
			ProducerTemplate template = camelContext.createProducerTemplate();
			camelContext.start();			
			for (int i = 0; i <18000; i++) {
			    template.sendBody("activemq:queue:numbers", i);
			}
			Thread.sleep(10000);
		} finally {
			camelContext.stop();
		}
	}
}
Output:
19:04| INFO | MarkerIgnoringBase.java 95 | Received: 281 new messages, with total 281 so far. Last group took: 470 millis which is: 597.872 messages per second. average: 597.872
19:04| INFO | MarkerIgnoringBase.java 95 | Received: 14802 new messages, with total 15083 so far. Last group took: 10001 millis which is: 1,480.052 messages per second. average: 1,440.455
19:05| INFO | MarkerIgnoringBase.java 95 | Received: 2917 new messages, with total 18000 so far. Last group took: 10000 millis which is: 291.7 messages per second. average: 879.293
Download the source code
This was an example about Camel log component. You can download the source code here: camelLogComponentExamples.zip
Reference:	Apache Camel Log Component Examples from our JCG partner Ram Mokkapaty at the Java Articles blog.
Tagged with: APACHE CAMEL