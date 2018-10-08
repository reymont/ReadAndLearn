

* [Java 8 Streams map() 例子 - - CSDN博客 ](http://blog.csdn.net/wangmuming/article/details/72630570)

在java 8，stream().map()允许您将对象转换为别的。复习下面的例子：
1. String类型的List集合转大写 
1.1 简单的java例子把字符串列表转换为大写的情况.

TestJava8.java
package com.mkyong.java8;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

public class TestJava8 {

    public static void main(String[] args) {

        List<String> alpha = Arrays.asList("a", "b", "c", "d");

        //Before Java8
        List<String> alphaUpper = new ArrayList<>();
        for (String s : alpha) {
            alphaUpper.add(s.toUpperCase());
        }

        System.out.println(alpha); //[a, b, c, d]
        System.out.println(alphaUpper); //[A, B, C, D]

        // Java 8
        List<String> collect = alpha.stream().map(String::toUpperCase).collect(Collectors.toList());
        System.out.println(collect); //[A, B, C, D]

        // Extra, streams apply to any data type.
        List<Integer> num = Arrays.asList(1,2,3,4,5);
        List<Integer> collect1 = num.stream().map(n -> n * 2).collect(Collectors.toList());
        System.out.println(collect1); //[2, 4, 6, 8, 10]

    }

}
2. List of objects -> List of String
2.1 从 staff 对象集合中获取所有的 name 值.

Staff.java
package com.mkyong.java8;

import java.math.BigDecimal;

public class Staff {

    private String name;
    private int age;
    private BigDecimal salary;
	//...
}
TestJava8.java
package com.mkyong.java8;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

public class TestJava8 {

    public static void main(String[] args) {

        List<Staff> staff = Arrays.asList(
                new Staff("mkyong", 30, new BigDecimal(10000)),
                new Staff("jack", 27, new BigDecimal(20000)),
                new Staff("lawrence", 33, new BigDecimal(30000))
        );

        //Before Java 8
        List<String> result = new ArrayList<>();
        for (Staff x : staff) {
            result.add(x.getName());
        }
        System.out.println(result); //[mkyong, jack, lawrence]

        //Java 8
        List<String> collect = staff.stream().map(x -> x.getName()).collect(Collectors.toList());
        System.out.println(collect); //[mkyong, jack, lawrence]

    }

}
3. List of objects -> List of other objects
3.1  这个例子展示如何将 staff  对象的集合转为 StaffPublic 对象的集合.

Staff.java
package com.mkyong.java8;

import java.math.BigDecimal;

public class Staff {

    private String name;
    private int age;
    private BigDecimal salary;
	//...
}
StaffPublic.java
package com.mkyong.java8;

public class StaffPublic {

    private String name;
    private int age;
    private String extra;
    //...
}
3.2 Before Java 8.

BeforeJava8.java
package com.mkyong.java8;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class BeforeJava8 {

    public static void main(String[] args) {

        List<Staff> staff = Arrays.asList(
                new Staff("mkyong", 30, new BigDecimal(10000)),
                new Staff("jack", 27, new BigDecimal(20000)),
                new Staff("lawrence", 33, new BigDecimal(30000))
        );

        List<StaffPublic> result = convertToStaffPublic(staff);
        System.out.println(result);

    }

    private static List<StaffPublic> convertToStaffPublic(List<Staff> staff) {

        List<StaffPublic> result = new ArrayList<>();

        for (Staff temp : staff) {

            StaffPublic obj = new StaffPublic();
            obj.setName(temp.getName());
            obj.setAge(temp.getAge());
            if ("mkyong".equals(temp.getName())) {
                obj.setExtra("this field is for mkyong only!");
            }

            result.add(obj);
        }

        return result;

    }

}
Output

[
	StaffPublic{name='mkyong', age=30, extra='this field is for mkyong only!'},
	StaffPublic{name='jack', age=27, extra='null'},
	StaffPublic{name='lawrence', age=33, extra='null'}
]
3.3 Java 8 例子.

NowJava8.java
package com.mkyong.java8;

package com.hostingcompass.web.java8;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

public class NowJava8 {

    public static void main(String[] args) {

        List<Staff> staff = Arrays.asList(
                new Staff("mkyong", 30, new BigDecimal(10000)),
                new Staff("jack", 27, new BigDecimal(20000)),
                new Staff("lawrence", 33, new BigDecimal(30000))
        );

		// convert inside the map() method directly.
        List<StaffPublic> result = staff.stream().map(temp -> {
            StaffPublic obj = new StaffPublic();
            obj.setName(temp.getName());
            obj.setAge(temp.getAge());
            if ("mkyong".equals(temp.getName())) {
                obj.setExtra("this field is for mkyong only!");
            }
            return obj;
        }).collect(Collectors.toList());

        System.out.println(result);

    }

}
Output

[
	StaffPublic{name='mkyong', age=30, extra='this field is for mkyong only!'},
	StaffPublic{name='jack', age=27, extra='null'},
	StaffPublic{name='lawrence', age=33, extra='null'}
]
References
Processing Data with Java SE 8 Streams, Part 1
Java 8 – Filter a Map examples
Java 8 flatMap example
Collectors JavaDoc