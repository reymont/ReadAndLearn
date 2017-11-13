With maven - clean package, xml source files are not included in classpath

By default maven does not include any files from "src/main/java" (${sourceDirectory} variable). You have two possibilities (choose one of them):
•	put all your resource files (different than java files) to "src/main/resources" - recomended
•	Add to your pom (example from gwt plugin):
•	<build>
•	    <resources>
•	        <resource>
•	            <directory>src/main/java</directory>
•	            <includes>                      
•	                <include>**/*.xml</include>
•	            </includes>
•	        </resource>
•	        <resource>
•	            <directory>src/main/resources</directory>
•	        </resource>
•	    </resources>
</build>
