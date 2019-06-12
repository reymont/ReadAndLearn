property timestamp： 2012/11/12
Xml代码    
<properties> 
<maven.build.timestamp.format>yyyy-MM-dd HH:mm:ss</maven.build.timestamp.format> 
<timestamp>${maven.build.timestamp}</timestamp> 
</properties> 

http://stackoverflow.com/questions/802677/adding-the-current-date-with-maven2-filtering

But you could create a custom property in the parent pom:
<properties>
    <maven.build.timestamp.format>yyMMdd_HHmm</maven.build.timestamp.format>
    <buildNumber>${maven.build.timestamp}</buildNumber>
</properties>
Where buildNumber is the new property that can be filtered into the resources.



	<version>${timestamp}</version>

	<properties>
		<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
		<spring.version>3.0.5.RELEASE</spring.version>
		<cxf.version>2.2.3</cxf.version>
		<maven.build.timestamp.format>yyyyMMdd</maven.build.timestamp.format>  
        <timestamp>${maven.build.timestamp}</timestamp>  
	</properties>
