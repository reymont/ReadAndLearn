
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [Stream Collectors groupingBy 例子](#stream-collectors-groupingby-例子)
	* [1. Group By, Count and Sort](#1-group-by-count-and-sort)
		* [1.1 Group by a List and display the total count of it.（按列表分组，并显示其总数）](#11-group-by-a-list-and-display-the-total-count-of-it按列表分组并显示其总数)
		* [1.2 Add sorting.（增加排序实现）](#12-add-sorting增加排序实现)
	* [2. List Objects](#2-list-objects)
		* [2.1 A Pojo.](#21-a-pojo)
		* [2.2 Group by the name + Count or Sum the Qty. （name + Count分组或者 对 Qty求和分组）](#22-group-by-the-name-count-or-sum-the-qty-name-count分组或者-对-qty求和分组)
		* [2.2  Price 分组 – Collectors.groupingBy and Collectors.mapping例子.](#22-price-分组-collectorsgroupingby-and-collectorsmapping例子)
	* [References](#references)
* [Java 8 – Stream Collectors groupingBy examples](#java-8-stream-collectors-groupingby-examples)
		* [2.2 Group by Price – Collectors.groupingBy and Collectors.mapping example.](#22-group-by-price-collectorsgroupingby-and-collectorsmapping-example)
* [java 8 - Can we convert List<Map<String, Object>> to Map<Object, Map<String, Object>> using groupby of Stream API - Stack Overflow](#java-8-can-we-convert-listmapstring-object-to-mapobject-mapstring-object-using-groupby-of-stream-api-stack-overflow)
* [java - Group by counting in Java8 stream API - Stack Overflow](#java-group-by-counting-in-java8-stream-api-stack-overflow)
* [Spring 4支持的Java 8新特性一览](#spring-4支持的java-8新特性一览)
* [2@Spring 4 支持的 Java 8 特性-爱编程](#2spring-4-支持的-java-8-特性-爱编程)
* [Java 8 – Convert List to Map](#java-8-convert-list-to-map)

<!-- /code_chunk_output -->

---


```java
Map<String, List<String>> graphLastMap = raphLastList.stream()
		.collect(Collectors.groupingBy(p -> p.getEndpoint(), Collectors.mapping(
				(FalconVo p) -> p.getValue().get("value").toString(), Collectors.toList())));
```

# Stream Collectors groupingBy 例子

* [Stream Collectors groupingBy 例子 - - CSDN博客 ](http://blog.csdn.net/wangmuming/article/details/72743790)

在这篇文章中，我们将向您展示如何使用java 8  Stream Collectors 对列表分组，计数，求和和排序。

## 1. Group By, Count and Sort
### 1.1 Group by a List and display the total count of it.（按列表分组，并显示其总数）

Java8Example1.java
```java
package com.mkyong.java8;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

public class Java8Example1 {

    public static void main(String[] args) {

        //3 apple, 2 banana, others 1
        List<String> items =
                Arrays.asList("apple", "apple", "banana",
                        "apple", "orange", "banana", "papaya");

        Map<String, Long> result =
                items.stream().collect(
                        Collectors.groupingBy(
                                Function.identity(), Collectors.counting()
                        )
                );

        System.out.println(result);


    }
}
```
output

{
	papaya=1, orange=1, banana=2, apple=3
}
### 1.2 Add sorting.（增加排序实现）

Java8Example2.java
```java
package com.mkyong.java8;

import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

public class Java8Example2 {

    public static void main(String[] args) {

        //3 apple, 2 banana, others 1
        List<String> items =
                Arrays.asList("apple", "apple", "banana",
                        "apple", "orange", "banana", "papaya");

        Map<String, Long> result =
                items.stream().collect(
                        Collectors.groupingBy(
                                Function.identity(), Collectors.counting()
                        )
                );

        Map<String, Long> finalMap = new LinkedHashMap<>();

        //Sort a map and add to finalMap
        result.entrySet().stream()
                .sorted(Map.Entry.<String, Long>comparingByValue()
                        .reversed()).forEachOrdered(e -> finalMap.put(e.getKey(), e.getValue()));

        System.out.println(finalMap);


    }
}
```
output

{
	apple=3, banana=2, papaya=1, orange=1
}

## 2. List Objects
Examples to ‘group by’ a list of user defined Objects.（通过“用户定义的对象”列表进行分组的示例。）

### 2.1 A Pojo.

Item.java
```java
package com.mkyong.java8;

import java.math.BigDecimal;

public class Item {

    private String name;
    private int qty;
    private BigDecimal price;

    //constructors, getter/setters
}
```

### 2.2 Group by the name + Count or Sum the Qty. （name + Count分组或者 对 Qty求和分组）

Java8Examples3.java
```java
package com.mkyong.java8;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class Java8Examples3 {

    public static void main(String[] args) {

        //3 apple, 2 banana, others 1
        List<Item> items = Arrays.asList(
                new Item("apple", 10, new BigDecimal("9.99")),
                new Item("banana", 20, new BigDecimal("19.99")),
                new Item("orang", 10, new BigDecimal("29.99")),
                new Item("watermelon", 10, new BigDecimal("29.99")),
                new Item("papaya", 20, new BigDecimal("9.99")),
                new Item("apple", 10, new BigDecimal("9.99")),
                new Item("banana", 10, new BigDecimal("19.99")),
                new Item("apple", 20, new BigDecimal("9.99"))
        );

        Map<String, Long> counting = items.stream().collect(
                Collectors.groupingBy(Item::getName, Collectors.counting()));

        System.out.println(counting);

        Map<String, Integer> sum = items.stream().collect(
                Collectors.groupingBy(Item::getName, Collectors.summingInt(Item::getQty)));

        System.out.println(sum);

    }
}
```
output

//Group by + Count
{
	papaya=1, banana=2, apple=3, orang=1, watermelon=1
}

//Group by + Sum qty
{
	papaya=20, banana=30, apple=40, orang=10, watermelon=10
}
### 2.2  Price 分组 – Collectors.groupingBy and Collectors.mapping例子.

Java8Examples4.java
```java
package com.mkyong.java8;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

public class Java8Examples4 {

    public static void main(String[] args) {

        //3 apple, 2 banana, others 1
        List<Item> items = Arrays.asList(
                new Item("apple", 10, new BigDecimal("9.99")),
                new Item("banana", 20, new BigDecimal("19.99")),
                new Item("orang", 10, new BigDecimal("29.99")),
                new Item("watermelon", 10, new BigDecimal("29.99")),
                new Item("papaya", 20, new BigDecimal("9.99")),
                new Item("apple", 10, new BigDecimal("9.99")),
                new Item("banana", 10, new BigDecimal("19.99")),
                new Item("apple", 20, new BigDecimal("9.99"))
                );

		//group by price
        Map<BigDecimal, List<Item>> groupByPriceMap =
			items.stream().collect(Collectors.groupingBy(Item::getPrice));

        System.out.println(groupByPriceMap);

		// group by price, uses 'mapping' to convert List<Item> to Set<String>
        Map<BigDecimal, Set<String>> result =
                items.stream().collect(
                        Collectors.groupingBy(Item::getPrice,
                                Collectors.mapping(Item::getName, Collectors.toSet())
                        )
                );

        System.out.println(result);

    }
}
```
output

{
	19.99=[
			Item{name='banana', qty=20, price=19.99}, 
			Item{name='banana', qty=10, price=19.99}
		], 
	29.99=[
			Item{name='orang', qty=10, price=29.99}, 
			Item{name='watermelon', qty=10, price=29.99}
		], 
	9.99=[
			Item{name='apple', qty=10, price=9.99}, 
			Item{name='papaya', qty=20, price=9.99}, 
			Item{name='apple', qty=10, price=9.99}, 
			Item{name='apple', qty=20, price=9.99}
		]
}

//group by + mapping to Set
{
	19.99=[banana], 
	29.99=[orang, watermelon], 
	9.99=[papaya, apple]
}
## References
* [Java 8 Stream Collectors JavaDoc](https://docs.oracle.com/javase/8/docs/api/java/util/stream/Collectors.html)
* [Java – How to sort a Map](https://www.mkyong.com/java/how-to-sort-a-map-in-java/)
* Stackoverflow – Sort a Map by values (Java)

# Java 8 – Stream Collectors groupingBy examples
 https://www.mkyong.com/java8/java-8-collectors-groupingby-and-mapping-example/

In this article, we will show you how to use Java 8 Stream Collectors to group by, count, sum and sort a List.
1. Group By, Count and Sort
1.1 Group by a List and display the total count of it.
Java8Example1.java
package com.mkyong.java8;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

public class Java8Example1 {

    public static void main(String[] args) {

        //3 apple, 2 banana, others 1
        List<String> items =
                Arrays.asList("apple", "apple", "banana",
                        "apple", "orange", "banana", "papaya");

        Map<String, Long> result =
                items.stream().collect(
                        Collectors.groupingBy(
                                Function.identity(), Collectors.counting()
                        )
                );

        System.out.println(result);


    }
}
output
{
	papaya=1, orange=1, banana=2, apple=3
}
1.2 Add sorting.
Java8Example2.java
package com.mkyong.java8;

import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

public class Java8Example2 {

    public static void main(String[] args) {

        //3 apple, 2 banana, others 1
        List<String> items =
                Arrays.asList("apple", "apple", "banana",
                        "apple", "orange", "banana", "papaya");

        Map<String, Long> result =
                items.stream().collect(
                        Collectors.groupingBy(
                                Function.identity(), Collectors.counting()
                        )
                );

        Map<String, Long> finalMap = new LinkedHashMap<>();

        //Sort a map and add to finalMap
        result.entrySet().stream()
                .sorted(Map.Entry.<String, Long>comparingByValue()
                        .reversed()).forEachOrdered(e -> finalMap.put(e.getKey(), e.getValue()));

        System.out.println(finalMap);


    }
}
output
{
	apple=3, banana=2, papaya=1, orange=1
}
2. List Objects
Examples to ‘group by’ a list of user defined Objects.
2.1 A Pojo.
Item.java
package com.mkyong.java8;

import java.math.BigDecimal;

public class Item {

    private String name;
    private int qty;
    private BigDecimal price;

    //constructors, getter/setters
}
2.2 Group by the name + Count or Sum the Qty.
Java8Examples3.java
package com.mkyong.java8;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class Java8Examples3 {

    public static void main(String[] args) {

        //3 apple, 2 banana, others 1
        List<Item> items = Arrays.asList(
                new Item("apple", 10, new BigDecimal("9.99")),
                new Item("banana", 20, new BigDecimal("19.99")),
                new Item("orang", 10, new BigDecimal("29.99")),
                new Item("watermelon", 10, new BigDecimal("29.99")),
                new Item("papaya", 20, new BigDecimal("9.99")),
                new Item("apple", 10, new BigDecimal("9.99")),
                new Item("banana", 10, new BigDecimal("19.99")),
                new Item("apple", 20, new BigDecimal("9.99"))
        );

        Map<String, Long> counting = items.stream().collect(
                Collectors.groupingBy(Item::getName, Collectors.counting()));

        System.out.println(counting);

        Map<String, Integer> sum = items.stream().collect(
                Collectors.groupingBy(Item::getName, Collectors.summingInt(Item::getQty)));

        System.out.println(sum);

    }
}
output
//Group by + Count
{
	papaya=1, banana=2, apple=3, orang=1, watermelon=1
}

//Group by + Sum qty
{
	papaya=20, banana=30, apple=40, orang=10, watermelon=10
}
### 2.2 Group by Price – Collectors.groupingBy and Collectors.mapping example.
Java8Examples4.java
```java
package com.mkyong.java8;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

public class Java8Examples4 {

    public static void main(String[] args) {

        //3 apple, 2 banana, others 1
        List<Item> items = Arrays.asList(
                new Item("apple", 10, new BigDecimal("9.99")),
                new Item("banana", 20, new BigDecimal("19.99")),
                new Item("orang", 10, new BigDecimal("29.99")),
                new Item("watermelon", 10, new BigDecimal("29.99")),
                new Item("papaya", 20, new BigDecimal("9.99")),
                new Item("apple", 10, new BigDecimal("9.99")),
                new Item("banana", 10, new BigDecimal("19.99")),
                new Item("apple", 20, new BigDecimal("9.99"))
                );

		//group by price
        Map<BigDecimal, List<Item>> groupByPriceMap =
			items.stream().collect(Collectors.groupingBy(Item::getPrice));

        System.out.println(groupByPriceMap);

		// group by price, uses 'mapping' to convert List<Item> to Set<String>
        Map<BigDecimal, Set<String>> result =
                items.stream().collect(
                        Collectors.groupingBy(Item::getPrice,
                                Collectors.mapping(Item::getName, Collectors.toSet())
                        )
                );

        System.out.println(result);

    }
}
```
output
{
	19.99=[
			Item{name='banana', qty=20, price=19.99}, 
			Item{name='banana', qty=10, price=19.99}
		], 
	29.99=[
			Item{name='orang', qty=10, price=29.99}, 
			Item{name='watermelon', qty=10, price=29.99}
		], 
	9.99=[
			Item{name='apple', qty=10, price=9.99}, 
			Item{name='papaya', qty=20, price=9.99}, 
			Item{name='apple', qty=10, price=9.99}, 
			Item{name='apple', qty=20, price=9.99}
		]
}

//group by + mapping to Set
{
	19.99=[banana], 
	29.99=[orang, watermelon], 
	9.99=[papaya, apple]
}
References
1.	Java 8 Stream Collectors JavaDoc
2.	Java – How to sort a Map
3.	Stackoverflow – Sort a Map by values (Java)


How to sum a list of integers with java streams? - Stack Overflow

 http://stackoverflow.com/questions/30125296/how-to-sum-a-list-of-integers-with-java-streams

This will work, but the i -> i is doing some automatic unboxing which is why it "feels" strange. Either of the following will work and better explain what the compiler is doing under the hood with your original syntax:
integers.values().stream().mapToInt(i -> i.intValue()).sum();
integers.values().stream().mapToInt(Integer::intValue).sum();




# java 8 - Can we convert List<Map<String, Object>> to Map<Object, Map<String, Object>> using groupby of Stream API - Stack Overflow 
http://stackoverflow.com/questions/35158781/can-we-convert-listmapstring-object-to-mapobject-mapstring-object-usi

I have a List of List<Map<String, Object>> like this
[{"A": 2616100,
      "B": 2616100,
      "C": 31,
      "D": "Sold Promissory Buyer"
    },
    {
      "A": 101322143.24,
      "B": 50243301.2,
      "C": 569,
      "D": "Auction"
    },
    {
      "A": 72000,
      "B": 93900,
      "C": 1,
      "D": "Sold Third Party"
    }]
Using Stream API with groupBy method salesReportForSoldProperty.stream().collect(Collectors.groupingBy(tags -> tags.get("D"))), I am able to get collection Map<Object, List<Map<String, Object>>> 
But when I am trying to create JSON of this collection, I am getting Json like this
```json
  {
  "Sold Promissory Buyer": [
    {
      "A": 2616100,
      "B": 2616100,
      "C": 31,
      "D": "Sold Promissory Buyer"
    }
  ],
  "Auction": [
    {
      "A": 101322143.24,
      "B": 50243301.2,
      "C": 569,
      "D": "Auction"
    }
  ],
  "Sold Third Party": [
    {
      "A": 72000,
      "B": 93900,
      "C": 1,
      "D": "Sold Third Party"
    }
  ]
}
```
Here every value is JSONArray, because I am getting Map<Object, List<Map<String, Object>>>. Is there any way to get Map<Object, Map<String, Object>>collection using Stream API, So I can get a proper JSON (without JSONArray value)



You should use Collectors.toMap instead:
salesReportForSoldProperty.stream().collect(
    Collectors.toMap(tags -> tags.get("D"), Function.identity()));
Note that in this case if your input contains two elements with the same "D" value, you will got an IllegalStateException as you cannot put two values into the same map key. If you want to ignore duplicates, you may specify the merge function as third argument:
salesReportForSoldProperty.stream().collect(
    Collectors.toMap(tags -> tags.get("D"), Function.identity(), (a, b) -> a));



# java - Group by counting in Java8 stream API - Stack Overflow 
http://stackoverflow.com/questions/25441088/group-by-counting-in-java8-stream-api


I think you're just looking for the overload which takes another Collector to specify what to do with each group... and then Collectors.counting() to do the counting:
import java.util.*;
import java.util.stream.*;

class Test {
    public static void main(String[] args) {
        List<String> list = new ArrayList<>();

        list.add("Hello");
        list.add("Hello");
        list.add("World");

        Map<String, Long> counted = list.stream()
            .collect(Collectors.groupingBy(Function.identity(), Collectors.counting()));

        System.out.println(counted);
    }
}
Result:
{Hello=2, World=1}
(There's also the possibility of using groupingByConcurrent for more efficiency. Something to bear in mind for your real code, if it would be safe in your context.)


# Spring 4支持的Java 8新特性一览 

Spring 4支持的Java 8新特性一览 
http://www.infoq.com/cn/articles/spring-4-java-8

| 作者 Adib Saikali ，译者 段珊珊 发布于 2015年3月31日. 估计阅读时间: 3 分钟 | 欲知区块链、VR、TensorFlow等潮流技术和框架，请锁定QCon北京站！讨论
•	分享到：微博微信FacebookTwitter有道云笔记邮件分享
•	   已保存    
•	我的阅读清单
有众多新特性和函数库的Java 8发布之后，Spring 4.x已经支持其中的大部分。有些Java 8的新特性对Spring无影响，可以直接使用，但另有些新特性需要Spring的支持。本文将带您浏览Spring 4.0和4.1已经支持的Java 8新特性。
Spring 4支持Java 6、7和8
Java 8编译器编译过的代码生成的.class文件需要在Java 8或以上的Java虚拟机上运行。由于Spring对反射机制和ASM、CGLIB等字节码操作函数库的重度使用，必须确保这些函数库能理解Java 8生成的新class文件。因此Spring将ASM、CGLIB等函数库通过jar jar(https://code.google.com/p/jarjar/)嵌入Spring框架中，这样Spring就可以同时支持Java6、7和8的字节码代码而不会触发运行时错误。
Spring框架本身是由Java 8编译器编译的，编译时使用的是生成Java 6字节码的编译命令选项。因此你可以Java6、7或者8来编译运行Spring 4.x的应用。
Spring和Java 8的Lambda表达式
相关厂商内容
免费报名：阿里云栖大会—深圳峰会
不可错过的智能时代的大前端
Native动态化最新技术解析
解析微信朋友圈的lookalike算法
中国技术开放日之电商后端技术大揭秘（免费报名）
Java 8的设计者想保证它是向下兼容的，以使其lambda表达式能在旧版本的代码编译器中使用。向下兼容通过定义函数式接口概念实现。
基本上，Java 8的设计者分析了现有的Java代码体系，注意到很多Java程序员用只有一个方法的接口来表示方法的思想。以下就是JDK和Spring中只有一个方法的接口的例子，也就是所谓的“函数式接口”。
JDK里的函数式接口：
public interface Runnable {
    public abstract void run();}

public interface Comparable<T> {
    public int compareTo(T o);}
Spring框架里的函数式接口：
public interface ConnectionCallback<T> {
  T doInConnection(Connection con) throws SQLException, DataAccessException;}

public interface RowMapper<T>{
  T mapRow(ResultSet rs, int rowNum) throws SQLException;}
在Java 8里，任何函数式接口作为方法的参数传入或者作为方法返回值的场合，都可以用lambda表达式代替。例如，Spring的JdbcTemplate类里有一个方法定义如下：
public <T> List<T> query(String sql, RowMapper<T> rowMapper)
  throws DataAccessException
这个查询方法的第二个参数需要RowMapper接口的一个实例。在Java 8中我们可以写一个lambda表达式作为第二个参数的值传进去。
别把代码写成这样：
jdbcTemplate.query("SELECT * from products", new RowMapper<Product>(){
  @Override
  public Product mapRow(ResultSet rs, int rowNum) throws SQLException {
    Integer id = rs.getInt("id");
    String description = rs.getString("description");
    Integer quantity = rs.getInt("quantity");
    BigDecimal price = rs.getBigDecimal("price");
    Date availability = rs.getDate("available_date");

    Product product = new Product();
    product.setId(id);
    product.setDescription(description);
    product.setQuantity(quantity);
    product.setPrice(price);
    product.setAvailability(availability);

    return product;
  }});
我们这么写：
jdbcTemplate.query("SELECT * from queries.products", (rs, rowNum) -> {
    Integer id = rs.getInt("id");
    String description = rs.getString("description");
    Integer quantity = rs.getInt("quantity");
    BigDecimal price = rs.getBigDecimal("price");
    Date availability = rs.getDate("available_date");

    Product product = new Product();
    product.setId(id);
    product.setDescription(description);
    product.setQuantity(quantity);
    product.setPrice(price);
    product.setAvailability(availability);

    return product;});
我们注意到Java 8中这段代码使用了lambda表达式，这比之前的版本中使用匿名内部类的方式紧凑、简洁得多。
涵盖Java 8中函数式接口的所有细节超出了本文的范畴，我们强烈建议您从别处详细学习函数式接口。本文想要传达的关键点在于Java 8的lambda表达式能传到那些用Java 7或更早的JDK编译的、接受函数式接口作为参数的方法中。
Spring的代码里有很多函数式接口，因此lambda表达式很容易与Spring结合使用。即便Spring框架本身被编译成Java 6的.class文件格式，你仍然可以用Java 8的lambda表达式编写应用代码、用Java 8编译器编译、并且在Java 8虚拟机上运行，你的应用可以正常工作。
总之，因为Spring框架早在Java 8正式给函数式接口下定义之前就已经实际使用了函数式接口，因此在Spring里使用lambda表达式非常容易。
Spring 4和Java 8的时间与日期API
Java开发者们一直痛恨java.util.Date类的设计缺陷，终于，Java 8带来了全新的日期与时间API，解决了那些久被诟病的问题。这个新的日期与时间API值得用一整篇文章的篇幅来讲述，因此我们在本文不会详述其细节，而是重点关注新的java.time包中引入的众多新类，如LocalDate、LocalTime和 LocalDateTime。
Spring有一个数据转换框架，它可以使字符串和Java数据类型相互转换。Spring 4升级了这个转换框架以支持Java 8日期与时间API里的那些类。因此你的代码可以这样写：
@RestController
public class ExampleController {

  @RequestMapping("/date/{localDate}")
  public String get(@DateTimeFormat(iso = ISO.DATE) LocalDate localDate)
  {
    return localDate.toString();
  }}
上面的例子中，get方法的参数是Java 8的LocalDate类型，Spring 4能接受一个字符串参数例如2014-02-01并将它转换成Java 8 LocalDate的实例。
要注意的是Spring通常会与其它一些库一起使用实现特定功能，比如与Hibernate一起实现数据持久化，与Jackson一起实现Java对象和JSON的互相转换。
虽然Spring 4支持Java 8的日期与时间库，这并不表示第三方框架如Hibernate和Jackson等也能支持它。到本文发表时，Hibernate JIRA里仍有一个开放状态的请求HHH-8844要求在Hibernate里支持Java 8日期与时间API。
Spring 4与重复注解
Java 8增加了对重复注解的支持，Spring 4也同样支持。特殊的是，Spring 4支持对注解@Scheduled和@PropertySource的重复。例如，请注意如下代码片段中对@PropertySource注解的重复使用：
@Configuration
@ComponentScan
@EnableAutoConfiguration
@PropertySource("classpath:/example1.properties")
@PropertySource("classpath:/example2.properties")public class Application {

        @Autowired
        private Environment env;

        @Bean
        public JdbcTemplate template(DataSource datasource) {
                System.out.println(env.getProperty("test.prop1"));
                System.out.println(env.getProperty("test.prop2"));
                return new JdbcTemplate(datasource);
        }

        public static void main(String[] args) {
                SpringApplication.run(Application.class, args);
        }}
Java 8的Optional<>与Spring 4.1
忘记检查空值引用是应用代码中一类常见的bug来源。消除NullPointerExceptions的方式之一是确保方法总是返回一个非空值。例如如下方法：
public interface CustomerRepository extends CrudRepository<Customer, Long> {
   /**
    * returns the customer for the specified id or
    * null if the value is not found
   */
   public Customer findCustomerById(String id);}
用如下有缺陷的代码来调用CustomerRepository ：
Customer customer = customerRepository.findCustomerById(“123”);
customer.getName(); // 得到空指针错误
这段代码的正确写法应该是：
Customer customer = customerRepository.findCustomerById(“123”);if(customer != null) {
  customer.getName(); // 避免空指针错误
}
理想状态下，如果我们没有检查某个值能否为空，我们希望编译器及时发现。java.util.Optional类让我们可以像这样写接口：
public interface CustomerRepository extends CrudRepository<Customer, Long> {
  public Optional<Customer> findCustomerById(String id);}
这样一来，这段代码的有缺陷版本不会被编译，开发者必须显式地检查这个Optional类型对象是否有值，代码如下：
Optional<Customer> optional = 
customerRepository.findCustomerById(“123”);if(optional.isPresent()) {
   Customer customer = optional.get();
   customer.getName();}
所以Optional的关键点在于确保开发者不用查阅Javadoc就能知道某个方法可以返回null，或者可以把一个null值传给某方法。编译器和方法签名有助于开发者明确知道某个值是Optional类型。关于Optional类思想的详细描述请参考这里。
Spring 4.1有两种方式支持Java Optional。Spring的@Autowired注解有一个属性"required"，使用之后我们可以把如下代码：
@Service
public class MyService {

    @Autowired(required=false)
    OtherService otherService;

    public doSomething() {
      if(otherService != null) {
        // use other service
      }
   }}
替换成：
public class MyService {

    @Autowired
    Optional<OtherService> otherService;

    public doSomething() {
      otherService.ifPresent( s ->  {
        // use s to do something
      });
    }}
另一个能用Optional的地方是Spring MVC框架，可以用于表示某个处理方法的参数是可选的。例如：
@RequestMapping(“/accounts/{accountId}”,requestMethod=RequestMethod.POST)
void update(Optional<String> accountId, @RequestBody Account account)
这段代码会告诉Spring其accountId是可选参数。
总之，Java 8的Optional类通过减少空指针错误相关的缺陷简化了代码编写，同时Spring能很好地支持Java 8的Optional类。
参数名发现机制
Java 8支持在编译后的代码中保留方法的参数名。这意味着Spring 4可以从方法中提取参数名，从而使SpringMVC代码更为简洁。例如：
@RequestMapping("/accounts/{id}")public Account getAccount(@PathVariable("id") String id)
可以改写为：
@RequestMapping("/accounts/{id}")public Account getAccount(@PathVariable String id)
可以看到我们把@PathVariable(“id”) 替换成@PathVariable，因为Spring 4能从编译后的Java 8代码中获取参数名——id。只要在编译时指定了–parameters标记，Java 8编译器就会把参数名写入.class文件中。在Java 8发布之前，Spring也可以从使用-debug选项编译之后的代码中提取出参数名。
在Java 7及之前的版本中，-debug选项不会保留抽象方法的参数名。这会导致Spring Data这类基于Java接口自动生成其资源库实现的工程就会出现问题。比如接口如下：
interface CustomerRepository extends CrudRepository<Customer, Long> {
  @Query("select c from Customer c where c.lastname = :lastname")
  List<Customer> findByLastname(@Param("lastname") String lastname);}
我们能看到findByLastname仍然需要@Param(“lastname”)，这是因为findByLastname是个抽象方法，而在Java 7及之前的版本里就算用了-debug选项也不会保留其参数名。而在Java 8中，使用–parameters选项后，Spring Data就能自动找到抽象方法的参数名，我们可以把上例中的接口改写成：
interface CustomerRepository extends CrudRepository<Customer, Long> {
  @Query("select c from Customer c where c.lastname = :lastname")
  List<Customer> findByLastname(String lastname);}
这里我们已经不再需要@Param(“lastname”)，让代码更简洁且易于阅读。所以使用Java 8编译代码时加上–parameters标记是个好方法。
总结
Spring 4支持Java 6、7和8，开发者可以随意使用Java 6、7或8来编写自己的应用代码。如果使用的是Java 8，那么只要有函数式接口的地方就可以使用lambda表达式，使代码更为简洁易读。
Java 8对某些库做了改进，比如新的java.time包和Optional类，Optional类使得用Spring编写的代码更加简单明了。
最后，用–parameters选项编译Java 8代码会在编译时保留方法的参数名，使得开发者得以编写更为紧凑的Spring MVC方法和Spring Data查询方法。
如果你已经准备在项目中使用Java 8，你会发现Spring 4是个很好地利用了Java 8新特性的出色框架。
查看英文原文：Spring 4 and Java 8
________________________________________
感谢崔康对本文的审校。
给InfoQ中文站投稿或者参与内容翻译工作，请邮件至editors@cn.infoq.com。也欢迎大家通过新浪微博（@InfoQ，@丁晓昀），微信（微信号：InfoQChina）关注我们，并与我们的编辑和其他读者朋友交流。
【架构师的小目标和大事件】ArchSummit全球架构师峰会将于7月7-8日深圳举行，目前Facebook、AppDynamics、Linkedin、腾讯、百度、欢聚时代等诸多技术专家受邀担任出品人和讲师，华南地区即将开启技术大事件，现在报名更享8折优惠 >>详情点击





# 2@Spring 4 支持的 Java 8 特性-爱编程 
http://www.w2bc.com/article/225507


Spring 框架 4 支持 Java 8 语言和 API 功能。在本文中，我们将重点放在 Spring 4 支持新的 Java 8 的功能。最重要的是 Lambda 表达式，方法引用，JSR-310的日期和时间，和可重复注释。
Lambda 表达式
Spring 的代码库使用了 Java 8 大量的函数式接口，Lambda 表达式可以用来编写更干净和紧凑的代码。每当出现函数式接口的对象的预期时我们便可以提供一个 Lambda 表达式。让我们进一步继续之前首先学习函数式接口。
函数式接口
有单一抽象方法的接口被称为函数式接口。下面是 JDK 中函数式接口的一些例子：
   
Comparator 是仅具有一个抽象的非对象方法的函数。尽管声明了两个抽象方法，因为 equals 是对应于对象的公共方法所以从计数里排除了。其中有一个对象类方法且没有非对象方法的接口并不是函数式接口。
 
一个接口如果有一个抽象的非对象类方法并且扩展自具有唯一对象类方法的非函数式接口，则称为函数式接口。
 
Spring 框架的函数式接口的例子：
  
@FunctionalInterface 注解可以在接口声明的顶部声明中被使用，但这并不是必需的。此注解用于由编译器来检测该接口是不是有效的函数式接口。如果我们试图在接口里定义多个单一抽象方法，编译器将抛出一个错误。
 
 
函数描述符
接口的函数描述符是该接口的一个抽象方法的方法的类型。该方法类型包括参数类型，返回类型和 throws 子句。
例：
 
如何编写 Lambda 表达式
Lambda 表达式的语法可以拆分成三部分：
•	一个箭头 (–>)
•	参数列表: 一个 Lambda 表达式可以包含0个或多个参数 例: () → { System.out.println(“ No arguments”); } (String arg) → { System.out.println(“ One argument : ”+arg); } (String arg1, Integer arg2) → { System.out.println(“Two arguments : ”+arg1+” and ”+arg2); }
•	表达式体: 可以是单个表达式或代码块。单个表达式将被简单地求值并返回。 例: (String arg) → { System.out.println(“ One argument : ”+arg); } 如果表达式体（Body）中存在语句块，那么它将被判定为方法体，并且在块执行后隐藏的返回语句将控制权交给调用者。
现在我们看一下如何使用 Lambda 表达式：
例1：
 
// 使用 Lambda 表达式
 
例2：
 
//使用 Lambda 表达式
 
你可以通过 Spring 的回调函数使用 Lambda 表达式。例如，用一个 ConnectionCallback 检索给定 JDBC 连接的列表，可写成如下语句： jdbcTemplate.execute(connection -> connection.getCatalog())
方法引用
函数式接口也可以使用方法引用来实现，引用方法或构造函数但并不调用它们。方法引用和 Lambda 表达式是类似的，但方法引用是指现有类的方法，而 Lambda 定义了一个匿名方法，并将其作为函数式接口的实例。
在 Java 8 中一个新增包中包含了常用于 Lambda 表达式和方法引用的函数式接口：java.util.function。
Date Time API
在 Java 中现有的 Date 和 Time 类存在多个问题。Date 和 Calendar 类的最大问题之一是它们不是线程安全的。在编写日期处理代码时开发人员不得不特别小心并发问题。Date 类也不支持国际化，因此不支持时区。开发人员必须编写大量的代码来支持不同的时区。
Date 和 Time 类也显现出不佳的 API 设计。java.util.Date 中的月从0，日从1，年从1900开始。缺少一致性。现在这些与 Date 和 Time 类的其它几个问题在 Java 8 中的新 Date 和 Time API 中已解决。
在 java.time 包下新的 Date 和 Time API 的重要的类是 LocalDate，LocalTime 和 ZonedDateTime。
LocalDate 和 LocalTime
LocalDate 表示日期时的默认格式为 YYYY-MM-DD，并没有时间。这是一个不可变类。我们可以使用now() 方法获得的当前日期。
新建 LocalDate 实例的例子：
//获取当前日期
 
我们也可以通过对年，月，日的输入参数来新建 LocalDate 实例。
// 2016年4月1日
 
LocalTime 表示无日期的时间，是不变的。时间的默认格式为 hh:mm:ss.zzz。
新建 LocalTime 实例的例子：
//获取当前时间
 
// 18:30:30
 
默认情况下，LocalDate 和 LocalTime 类使用默认时区的系统时钟。这些类还提供了通过重载 new() 方法对修改时区的支持。可以通过传递 zoneid 来获得一个特定时区中的日期。
例子：
// 当前本地日期加尔各答（印度）
 
此外，还有一个类，LocalDateTime 组合了日期和时间，默认格式为 yyyy-MM-ddTHH:MM:ss.zzz•。
//当前日期和时间
 
// 2016-04-01 13:30
 
ZonedDateTime
这是一个不可变的类，用于表示包括时区信息的日期和时间。我们可以使用这个类的一个实例来表示特定事件，如在世界的某些地区一个会议。
// 当前时间使用系统的时间和默认区域
 
// 当前时间使用特定时区的系统时钟
 
Spring 4 提供了一个转换框架，支持做为 Java 8 日期和时间 API 一部分的所有类。Spring 4 可以使用一个 2016-9-10 的字符串，并把它转换成 Java 8 LocalDate 的一个实例。Spring 4 还支持通过 @DateTimeFormat注解格式化 Java 8 Date-Time 字段。@DateTimeFormat 声明一个字段应该格式化为日期时间。
 
重复注解
在 Java 8 之前，将相同类型的多个注释加到声明或类型（例如一个类或方法）中是不允许的。作为一种变通方法，开发人员不得不将它们组合在一起成为单个容器注解。
例：
 
重复注解允许我们重写相同的代码并不需显式地使用容器注解。虽然容器注解没有在这里使用的，Java 编译器负责将两个注解封装成一个容器：
例：
 
定义重复注解
定义一个重复注解，通过可重复使用的 @Repeatable 注解来进行标注，或创建一个具有重复注解类型系列属性的注解。
第1步：声明重复注解类型：
 
第2步：声明容器注解类型。
 
全部的实现如下所示：
 
为了获得在运行时的注解信息，通过 @Retention(RetentionPolicy.RUNTIME) 注释即可。
检索注解
getAnnotationsByType() 或 getDeclaredAnnotationsByType() 是用于访问注解反射 API 中的新方法。
注解还可以通过它们的容器注解用 getAnnotation() 或 getDeclaredAnnotation() 进行访问。
结论
Spring 4 还可运行在 Java 6 和 Java 7 中。由于 Spring 使用了很多的函数式接口，用 Java 8 和 Spring 4，你将能够使用 Lambda 表达式和函数式接口，并可写出更干净、紧凑的代码。



# Java 8 – Convert List to Map 
https://www.mkyong.com/java8/java-8-convert-list-to-map/


A Java 8 example to convert a List<?> of objects into a Map<k, v>
1. POJO example
Hosting.java
package com.mkyong.java8

import java.util.Date;

public class Hosting {

    private int Id;
    private String name;
    private Date createdDate;

    public Hosting(int id, String name, Date createdDate) {
        Id = id;
        this.name = name;
        this.createdDate = createdDate;
    }

    //getters and setters
}
2. Java 8 – Collectors.toMap()
Example to convert a List into a stream, then collect it with Collectors.toMap
TestJava8.java
package com.mkyong.java8

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class TestJava8 {

    public static void main(String[] args) {

        List<Hosting> list = new ArrayList<>();
        list.add(new Hosting(1, "liquidweb.com", new Date()));
        list.add(new Hosting(2, "linode.com", new Date()));
        list.add(new Hosting(3, "digitalocean.com", new Date()));

        //example 1
        Map<Integer, String> result1 = list.stream().collect(
                Collectors.toMap(Hosting::getId, Hosting::getName));

        System.out.println("Result 1 : " + result1);

        //example 2
        Map<Integer, String> result2 = list.stream().collect(
                Collectors.toMap(x -> x.getId(), x -> x.getName()));

        System.out.println("Result 2 : " + result2);

    }

}
Output
Result 1 : {1=liquidweb.com, 2=linode.com, 3=digitalocean.com}
Result 2 : {1=liquidweb.com, 2=linode.com, 3=digitalocean.com}


