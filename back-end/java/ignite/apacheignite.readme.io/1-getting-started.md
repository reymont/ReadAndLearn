* https://apacheignite.readme.io/docs/getting-started

Prerequisites
Installation
Building from Source
Get It With Maven
Start from Command Line
With Default Configuration
Passing Configuration File
First Ignite SQL Application
First Ignite Compute Application
First Ignite Data Grid Application
First Ignite Service Grid Application
Cluster Management and Monitoring
Apache Ignite Essentials Series
Once you are finished with this getting started guide, watch the recordings of Apache Ignite Essentials webinars to gain a deeper understanding of how the product works:
In-memory computing essentials: Part 1
In-memory computing essentials: Part 2
Prerequisites
Apache Ignite was officially tested on:

Name	Value
JDK
Oracle JDK 7 and above
Open JDK 7 and above
IBM JDK 7 and above
OS
Linux (any flavor),
Mac OSX (10.6 and up)
Windows (XP and up),
Windows Server (2008 and up)
Oracle Solaris
ISA
x86, x64, SPARC, PowerPC
Network
No restrictions (10G recommended)
Installation
To get started with Apache Ignite:

Download Apache Ignite as ZIP archive from https://ignite.apache.org/
Unzip ZIP archive into the installation folder in your system
(Optional) Set IGNITE_HOME environment variable to point to the installation folder and make sure there is no trailing / on the path
Building From Source
If you downloaded the source package, you can build the binary using the following commands:

Shell
 # Unpack the source package
$ unzip -q apache-ignite-{version}-src.zip
$ cd apache-ignite-{version}-src
 
# Build In-Memory Data Fabric release (without LGPL dependencies)
$ mvn clean package -DskipTests
 
# Build In-Memory Data Fabric release (with LGPL dependencies)
$ mvn clean package -DskipTests -Prelease,lgpl
 
# Build In-Memory Hadoop Accelerator release
# (optionally specify version of hadoop to use)
$ mvn clean package -DskipTests -Dignite.edition=hadoop [-Dhadoop.version=X.X.X]
Refer to DEVNOTES.txt from the source package for more details.

Get It With Maven
Another easy way to get started with Apache Ignite in your project is to use Maven 2 dependency management.

Ignite requires only one ignite-core mandatory dependency. Usually you will also need to add ignite-spring for spring-based XML configuration and ignite-indexing for SQL querying.

Replace ${ignite-version} with actual Ignite version.

XML
 <dependency>
    <groupId>org.apache.ignite</groupId>
    <artifactId>ignite-core</artifactId>
    <version>${ignite.version}</version>
</dependency>
<dependency>
    <groupId>org.apache.ignite</groupId>
    <artifactId>ignite-spring</artifactId>
    <version>${ignite.version}</version>
</dependency>
<dependency>
    <groupId>org.apache.ignite</groupId>
    <artifactId>ignite-indexing</artifactId>
    <version>${ignite.version}</version>
</dependency>
Maven Setup
See Maven Setup for more information on how to include individual Ignite maven artifacts.
Start From Command Line
An Ignite node can be started from command line either with default configuration or by passing a configuration file. You can start as many nodes as you like and they will all automatically discover each other.

With Default Configuration
To start a grid node with default configuration, open the command shell and, assuming you are in IGNITE_HOME (Ignite installation folder), just type this:

Unix
 
Windows
 $ bin/ignite.sh
and you will see the output similar to this:

Text
 [02:49:12] Ignite node started OK (id=ab5d18a6)
[02:49:12] Topology snapshot [ver=1, nodes=1, CPUs=8, heap=1.0GB]
By default ignite.sh starts Ignite node with the default configuration: config/default-config.xml.

Passing Configuration File
To pass configuration file explicitly, from command line, you can type ignite.sh <path to configuration file> from within your Ignite installation folder. For example:

Unix
 
Window
 $ bin/ignite.sh examples/config/example-ignite.xml
Path to configuration file can be absolute, or relative to either IGNITE_HOME (Ignite installation folder) or META-INF folder in your classpath.

Interactive Mode
To pick a configuration file in interactive mode just pass -i flag, like so: ignite.sh -i.
First Ignite SQL Application
Let's begin by creating two tables and two indexes on these tables. We will use the examples from the Ignite SQL Getting Started guide. We have a City table and a Person table. People live in a City and a City can have many people. We can collocate Person objects with City objects for where a person lives. To achieve this, we use the WITH clause and specify affinityKey=city_id as follows:

Start Ignite cluster's nodes from command line or as a part of your application. Create the SQL schema using the statements below:

SQL
 
JDBC
 
ODBC
 CREATE TABLE City (
  id LONG PRIMARY KEY, name VARCHAR)
  WITH "template=replicated"

CREATE TABLE Person (
  id LONG, name VARCHAR, city_id LONG, PRIMARY KEY (id, city_id))
  WITH "backups=1, affinityKey=city_id"

CREATE INDEX idx_city_name ON City (name)

CREATE INDEX idx_person_name ON Person (name)
Next, we will populate the two tables with some example data, as follows:

SQL
 
JDBC
 
ODBC
 
Java API
 INSERT INTO City (id, name) VALUES (1, 'Forest Hill');
INSERT INTO City (id, name) VALUES (2, 'Denver');
INSERT INTO City (id, name) VALUES (3, 'St. Petersburg');

INSERT INTO Person (id, name, city_id) VALUES (1, 'John Doe', 3);
INSERT INTO Person (id, name, city_id) VALUES (2, 'Jane Roe', 2);
INSERT INTO Person (id, name, city_id) VALUES (3, 'Mary Major', 1);
INSERT INTO Person (id, name, city_id) VALUES (4, 'Richard Miles', 2);
Now we are ready to query the data. An example query would be to find people and the cities that they live in. This would involve a join across the two tables, as follows:

SQL
 
JDBC
 
ODBC
 
Java API
 SELECT p.name, c.name
FROM Person p, City c
WHERE p.city_id = c.id
This would produce the following output:

Output
 Mary Major, Forest Hill
Jane Roe, Denver
Richard Miles, Denver
John Doe, St. Petersburg
First Ignite Compute Application
Let's write our first compute grid application which will count the number of non-white-space characters in a sentence. As an example, we will take a sentence, split it into multiple words, and have every compute job count number of characters in each word. In the end, we simply add up results received from individual jobs to get our total count.

compute
 
java7 compute
 try (Ignite ignite = Ignition.start("examples/config/example-ignite.xml")) {
  Collection<IgniteCallable<Integer>> calls = new ArrayList<>();

  // Iterate through all the words in the sentence and create Callable jobs.
  for (final String word : "Count characters using callable".split(" "))
    calls.add(word::length);

  // Execute collection of Callables on the grid.
  Collection<Integer> res = ignite.compute().call(calls);

  // Add up all the results.
  int sum = res.stream().mapToInt(Integer::intValue).sum();
 
	System.out.println("Total number of characters is '" + sum + "'.");
}
Zero Deployment
Note that because of the Zero Deployment feature, when running the above application from your IDE, remote nodes will execute received jobs without explicit deployment.
For another example, let's create an application that will retrieve the objects that we had previously saved using our first SQL application, and perform some additional processing on those objects.

We will create a weather warning application. Let's assume that Denver has a weather warning and we need to alert Denver residents to prepare for the inclement weather. Previously, we used an affinityKey and we'll make use of that in our example application.

Here is the code snippet:

Java
 Ignite ignite = Ignition.start();

long cityId = 2; // Id for Denver

// Sending the logic to a cluster node that stores Denver and its residents.
ignite.compute().affinityRun("SQL_PUBLIC_CITY", cityId, new IgniteRunnable() {
  
  @IgniteInstanceResource
  Ignite ignite;
  
  @Override
  public void run() {
    // Getting an access to Persons cache.
    IgniteCache<BinaryObject, BinaryObject> people = ignite.cache(
        "Person").withKeepBinary();
 
    ScanQuery<BinaryObject, BinaryObject> query = 
        new ScanQuery <BinaryObject, BinaryObject>();
 
    try (QueryCursor<Cache.Entry<BinaryObject, BinaryObject>> cursor =
           people.query(query)) {
      
      // Iteration over the local cluster node data using the scan query.
      for (Cache.Entry<BinaryObject, BinaryObject> entry : cursor) {
        BinaryObject personKey = entry.getKey();
 
        // Picking Denver residents only only.
        if (personKey.<Long>field("CITY_ID") == cityId) {
            person = entry.getValue();
 
            // Sending the warning message to the person.
        }
      }
    }
  }
}
In the above example we use affinityRun() method, and specify the SQL_PUBLIC_CITY cache, cityId and a new IgniteRunnable(). This ensures that the computation is sent to the node that stores records of Denver and its residents. This approach allows us to execute advanced logic exactly where the data is stored avoiding expensive serialization and network trips.

First Ignite Data Grid Application
Now let's write a simple set of mini-examples which will put and get values to/from distributed cache, and perform basic transactions.

Since we are using cache in this example, we should make sure that it is configured. Let's use example configuration shipped with Ignite that already has several caches configured:

Shell
 $ bin/ignite.sh examples/config/example-cache.xml
Put and Get
 
Atomic Operations
 
Transactions
 
Distributed Locks
 try (Ignite ignite = Ignition.start("examples/config/example-ignite.xml")) {
    IgniteCache<Integer, String> cache = ignite.getOrCreateCache("myCacheName");
 
    // Store keys in cache (values will end up on different cache nodes).
    for (int i = 0; i < 10; i++)
        cache.put(i, Integer.toString(i));
 
    for (int i = 0; i < 10; i++)
        System.out.println("Got [key=" + i + ", val=" + cache.get(i) + ']');
}
First Ignite Service Grid Application
Ignite Service Grid is useful for deployment of microservices in the cluster. Ignite handles lifecycle related tasks of a service deployment, providing a simple way to call the service from an application.

As an example, let's develop a service that will return the current weather forecast for a specific city. First, we will create a service interface with a single API method. The interface has to extend org.apache.ignite.services.Service.

Weather Service Interface
 import org.apache.ignite.services.Service;

public interface WeatherService extends Service {
    /**
     * Get a current temperature for a specific city in the world.
     *
     * @param countryCode Country code (ISO 3166 country codes).
     * @param cityName City name.
     * @return Current temperature in the city in JSON format.
     * @throws Exception if an exception happened.
     */
    String getCurrentTemperature(String countryCode, String cityName)
        throws Exception;
}
An implementation of the service will connect to the weather channel to retrieve the latest weather information. Our weather service implementation will be as follows:

Weather Service Impl
 import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import org.apache.ignite.services.ServiceContext;


public class WeatherServiceImpl implements WeatherService {
    /** Weather service URL. */
    private static final String WEATHER_URL = "http://samples.openweathermap.org/data/2.5/weather?";

    /** Sample app ID. */
    private static final String appId = "ca7345b4a1ef8c037f7749c09fcbf808";

    /** {@inheritDoc}. */
    @Override public void init(ServiceContext ctx) throws Exception {
        System.out.println("Weather Service is initialized!");
    }

    /** {@inheritDoc}. */
    @Override public void execute(ServiceContext ctx) throws Exception {
        System.out.println("Weather Service is started!");
    }

    /** {@inheritDoc}. */
    @Override public void cancel(ServiceContext ctx) {
        System.out.println("Weather Service is stopped!");
    }

    /** {@inheritDoc}. */
    @Override public String getCurrentTemperature(String cityName,
        String countryCode) throws Exception {
        
        System.out.println(">>> Requested weather forecast [city=" 
            + cityName + ", countryCode=" + countryCode + "]");

        String connStr = WEATHER_URL + "q=" + cityName + ","
            + countryCode + "&appid=" + appId;

        URL url = new URL(connStr);

        HttpURLConnection conn = null;

        try {
            // Connecting to the weather service.
            conn = (HttpURLConnection) url.openConnection();

            conn.setRequestMethod("GET");

            conn.connect();

            // Read data from the weather server.
            try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(conn.getInputStream()))) {

                String line;
                StringBuilder builder = new StringBuilder();

                while ((line = reader.readLine()) != null)
                    builder.append(line);

                return builder.toString();
            }
        } finally {
            if (conn != null)
                conn.disconnect();
        }
    }
}
Finally, the service needs to be deployed in the cluster and can be called from the application side. For the sake of simplicity, the service will be deployed and called from the same application, as follows:

Service Deployment and Usage
 import org.apache.ignite.Ignite;
import org.apache.ignite.Ignition;

public class ServiceGridExample {

    public static void main(String[] args) throws Exception {
        try (Ignite ignite = Ignition.start()) {

            // Deploying a single instance of the Weather Service 
            // in the whole cluster.
            ignite.services().deployClusterSingleton("WeatherService",
               new WeatherServiceImpl());

            // Requesting current weather for London.
            WeatherService service = ignite.services().service("WeatherService");

            String forecast = service.getCurrentTemperature("London", "UK");

            System.out.println("Weather forecast in London:" + forecast);
        }
    }
}
Zero Deployment and Service Grid
Zero Deployment feature is not supported for Ignite Service Grid. If you decide to deploy the service from the example above on the nodes started with ignite.sh or ignite.bat file, include the service implementation into a custom JAR file and add it to {apache_ignite_version}/libs folder.
Cluster Management and Monitoring
The easiest way to examine the content of the data grid as well as perform other management and monitoring operations is to use the Ignite Web Console and Ignite Visor Command Line utility.