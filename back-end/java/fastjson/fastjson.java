// https://www.w3cschool.cn/fastjson/fastjson-tojsonstring.html
// http://mvnrepository.com/artifact/com.alibaba/fastjson/1.2.45

<!-- https://mvnrepository.com/artifact/com.alibaba/fastjson -->
<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>fastjson</artifactId>
    <version>1.2.45</version>
</dependency>
// https://mvnrepository.com/artifact/com.alibaba/fastjson
compile group: 'com.alibaba', name: 'fastjson', version: '1.2.45'


Fastjson toJSONString

Fastjson将java对象序列化为JSON字符串，fastjson提供了一个最简单的入口

package com.alibaba.fastjson;

public abstract class JSON {
    public static String toJSONString(Object object);
}
Sample

import com.alibaba.fastjson.JSON;

Model model = new Model();
model.id = 1001;

String json = JSON.toJSONString(model);