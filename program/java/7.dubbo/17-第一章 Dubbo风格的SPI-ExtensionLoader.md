第一章 Dubbo风格的SPI-ExtensionLoader - yzx2015fd的博客 - CSDN博客 http://blog.csdn.net/yzx2015fd/article/details/54619938

java原生SPI

1、原生SPI的使用方式

1、路径 META-INF/services

2、文件名 interface 完整限定名

3、文件内容 implement 完整限定名

4、使用方式，通过迭代器迭代实现类型。

2、原生API的优缺点。

优点1、不需要引入第三方包，util包中既有api使用，实现方便，功能简单。 
缺点2、不能指定想要的实现类，需要迭代获取；迭代的时候会加载用不到的实现类型，对资源造成浪费。

2 Motan ExtensionLoader实现服务发现。

Motan SPI的使用方式

1、路径 META-INF/services/

2、文件名@Spi注解的接口的完整限定名。

3、文件内容 每行一个实现类型。可以使用 #注释（注释内容在#右侧）

4、使用方式，通过name获取，或者通过关键字过滤获取拓展点集合

3 Dubbo ExtensionLoader实现服务发现。

Dubbo SPI的使用方式

1、路径 META-INF/services/；META-INF/dubbo/；META-INF/dubbo/internal/。

2、文件名@SPI注解的接口的完整限定名。

3、文件内容，name=implemts（完整限定名）。

4、使用方式，通过名称获取实现，或者通过URL获取可激活实现类型

4 Dubbo服务发现的特性。

1默认实现

通过SPI注解的value值来设置该接口所拥有的默认实现

public @interface SPI {
    /**
     * 缺省扩展点名。
     */
    String value() default "";
}
1
2
3
4
5
6
2扩展点实例属性自动注入

在创建拓展点实例后会自动注入实例中所包含的属性通过ExtensionFactory注入拓展点实现。

private T injectExtension(T instance) {
        try {
                for (Method method : instance.getClass().getMethods()) {
                    /**
                    *如果是set方法，设置值到实例中
                    **/
                           Object object = objectFactory.getExtension(pt, property);
                            if (object != null) {
                                method.invoke(instance, object);
                            }
                        } 
        return instance;
    }
1
2
3
4
5
6
7
8
9
10
11
12
13
3 Adaptive拓展点，通过Adaptive注解标识一个类型为适配类型，或者通过Compiler的Adaptive实现（通过application标签的Compiler属性可以设置为jdk或者javasist）动态生成Adaptive类型

1、具体生成规则。

①、针对具有Adaptive注解的方法生成方法，如果没有Adaptive注解，该方法跑出运行时异常

②、根据URL属性，Adaptive注解方法中必须有URL参数，或者带URL属性的参数。或者Invocation属性获取拓展点名称（获取属性）

③、通过ExtensionLoader根据名称获取拓展点实例，然后调用方法。

④、将拼成的code生成CLass并返回。

private String createAdaptiveExtensionClassCode() {
        /**
        *省略部分
        **/
        //遍历接口中的方法，检查是否存在Adaptive注解的方法
        for(Method m : methods) {
            if(m.isAnnotationPresent(Adaptive.class)) {
                hasAdaptiveAnnotation = true;
                break;
            }
        }
        // 完全没有Adaptive方法，则不需要生成Adaptive类
        if(! hasAdaptiveAnnotation)
            throw new IllegalStateException("No adaptive method on extension " + type.getName() + ", refuse to create the adaptive class!");

        /**
        *准备生成类型，生成，包名，引用，类型名（interfaceName+$+Adaptive），实现接口
        **/

       /**
       *遍历方法，根据Adaptive注解决定生成方式等。
        **/
      for (Method method : methods) {
            Class<?> rt = method.getReturnType();
            Class<?>[] pts = method.getParameterTypes();
            Class<?>[] ets = method.getExceptionTypes();

            Adaptive adaptiveAnnotation = method.getAnnotation(Adaptive.class);
            StringBuilder code = new StringBuilder(512);

            //没有注解，那这个方法有问题，不清真，没法用Adaptive方式调用
            if (adaptiveAnnotation == null) {
                code.append("throw new UnsupportedOperationException(\"method ")
                        .append(method.toString()).append(" of interface ")
                        .append(type.getName()).append(" is not adaptive method!\");");
            } else {
                int urlTypeIndex = -1;
                for (int i = 0; i < pts.length; ++i) {
                    if (pts[i].equals(URL.class)) {
                        urlTypeIndex = i;
                        break;
                    }
                }
                // 有类型为URL的参数
                if (urlTypeIndex != -1) {
                    // Null Point check
                    String s = String.format("\nif (arg%d == null) throw new IllegalArgumentException(\"url == null\");",
                                    urlTypeIndex);
                    code.append(s);

                    s = String.format("\n%s url = arg%d;", URL.class.getName(), urlTypeIndex); 
                    code.append(s);
                }

                // 参数没有URL类型，那从参数的属性中找，找不到就别玩了，抛异常，这个类型不清真，不能生成Adaptive类型
                else {
                    String attribMethod = null;

                    // 找到参数的URL属性
                    LBL_PTS:
                    for (int i = 0; i < pts.length; ++i) {
                        Method[] ms = pts[i].getMethods();
                        for (Method m : ms) {
                            String name = m.getName();
                            if ((name.startsWith("get") || name.length() > 3)
                                    && Modifier.isPublic(m.getModifiers())
                                    && !Modifier.isStatic(m.getModifiers())
                                    && m.getParameterTypes().length == 0
                                    && m.getReturnType() == URL.class) {
                                urlTypeIndex = i;
                                attribMethod = name;
                                break LBL_PTS;
                            }
                        }
                    }
                    if(attribMethod == null) {
                        throw new IllegalStateException("fail to create adative class for interface " + type.getName()
                                + ": not found url parameter or url attribute in parameters of method " + method.getName());
                    }

                    // Null point check
                    String s = String.format("\nif (arg%d == null) throw new IllegalArgumentException(\"%s argument == null\");",
                                    urlTypeIndex, pts[urlTypeIndex].getName());
                    code.append(s);
                    s = String.format("\nif (arg%d.%s() == null) throw new IllegalArgumentException(\"%s argument %s() == null\");",
                                    urlTypeIndex, attribMethod, pts[urlTypeIndex].getName(), attribMethod);
                    code.append(s);

                    s = String.format("%s url = arg%d.%s();",URL.class.getName(), urlTypeIndex, attribMethod); 
                    code.append(s);
                }

                /**
                 * 获取注解的值
                 */
                String[] value = adaptiveAnnotation.value();

                // 没有设置Key，则使用拓展点的名字
                if(value.length == 0) {
                    char[] charArray = type.getSimpleName().toCharArray();
                    StringBuilder sb = new StringBuilder(128);
                    for (int i = 0; i < charArray.length; i++) {
                        if(Character.isUpperCase(charArray[i])) {
                            if(i != 0) {
                                sb.append(".");
                            }
                            sb.append(Character.toLowerCase(charArray[i]));
                        }
                        else {
                            sb.append(charArray[i]);
                        }
                    }
                    value = new String[] {sb.toString()};
                }


                //如果有Invocation参数，那么从方法参数中去获取扩展点名称
                boolean hasInvocation = false;
                for (int i = 0; i < pts.length; ++i) {
                    if (pts[i].getName().equals("com.alibaba.dubbo.rpc.Invocation")) {
                        // Null Point check
                        String s = String.format("\nif (arg%d == null) throw new IllegalArgumentException(\"invocation == null\");", i);
                        code.append(s);
                        s = String.format("\nString methodName = arg%d.getMethodName();", i); 
                        code.append(s);
                        hasInvocation = true;
                        break;
                    }
                }


                //从方法参数中获取扩展点名称，或者从URL参数中获取拓展点名称，如果是协议拓展，那么从url中获取协议即可
                String defaultExtName = cachedDefaultName;
                String getNameCode = null;
                for (int i = value.length - 1; i >= 0; --i) {
                    if(i == value.length - 1) {
                        if(null != defaultExtName) {
                            if(!"protocol".equals(value[i]))
                                if (hasInvocation) 
                                    getNameCode = String.format("url.getMethodParameter(methodName, \"%s\", \"%s\")", value[i], defaultExtName);
                                else
                                    getNameCode = String.format("url.getParameter(\"%s\", \"%s\")", value[i], defaultExtName);
                            else
                                getNameCode = String.format("( url.getProtocol() == null ? \"%s\" : url.getProtocol() )", defaultExtName);
                        }
                        else {
                            if(!"protocol".equals(value[i]))
                                if (hasInvocation) 
                                    getNameCode = String.format("url.getMethodParameter(methodName, \"%s\", \"%s\")", value[i], defaultExtName);
                                else
                                    getNameCode = String.format("url.getParameter(\"%s\")", value[i]);
                            else
                                getNameCode = "url.getProtocol()";
                        }
                    }
                    else {
                        if(!"protocol".equals(value[i]))
                            if (hasInvocation) 
                                getNameCode = String.format("url.getMethodParameter(methodName, \"%s\", \"%s\")", value[i], defaultExtName);
                            else
                                getNameCode = String.format("url.getParameter(\"%s\", %s)", value[i], getNameCode);
                        else
                            getNameCode = String.format("url.getProtocol() == null ? (%s) : url.getProtocol()", getNameCode);
                    }
                }
                code.append("\nString extName = ").append(getNameCode).append(";");
                // check extName == null?
                String s = String.format("\nif(extName == null) " +
                        "throw new IllegalStateException(\"Fail to get extension(%s) name from url(\" + url.toString() + \") use keys(%s)\");",
                        type.getName(), Arrays.toString(value));
                code.append(s);

                s = String.format("\n%s extension = (%<s)%s.getExtensionLoader(%s.class).getExtension(extName);",
                        type.getName(), ExtensionLoader.class.getSimpleName(), type.getName());
                code.append(s);

                // return statement
                if (!rt.equals(void.class)) {
                    code.append("\nreturn ");
                }

                s = String.format("extension.%s(", method.getName());
                code.append(s);
                for (int i = 0; i < pts.length; i++) {
                    if (i != 0)
                        code.append(", ");
                    code.append("arg").append(i);
                }
                code.append(");");
            }


            //实现接口中定义的方法，将上面拼好的方法放进去。
            codeBuidler.append("\npublic " + rt.getCanonicalName() + " " + method.getName() + "(");
            for (int i = 0; i < pts.length; i ++) {
                if (i > 0) {
                    codeBuidler.append(", ");
                }
                codeBuidler.append(pts[i].getCanonicalName());
                codeBuidler.append(" ");
                codeBuidler.append("arg" + i);
            }
            codeBuidler.append(")");
            if (ets.length > 0) {
                codeBuidler.append(" throws ");
                for (int i = 0; i < ets.length; i ++) {
                    if (i > 0) {
                        codeBuidler.append(", ");
                    }
                    codeBuidler.append(ets[i].getCanonicalName());
                }
            }
            codeBuidler.append(" {");
            codeBuidler.append(code.toString());
            codeBuidler.append("\n}");
        }
        codeBuidler.append("\n}");
        if (logger.isDebugEnabled()) {
            logger.debug(codeBuidler.toString());
        }
        return codeBuidler.toString();
    }
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
63
64
65
66
67
68
69
70
71
72
73
74
75
76
77
78
79
80
81
82
83
84
85
86
87
88
89
90
91
92
93
94
95
96
97
98
99
100
101
102
103
104
105
106
107
108
109
110
111
112
113
114
115
116
117
118
119
120
121
122
123
124
125
126
127
128
129
130
131
132
133
134
135
136
137
138
139
140
141
142
143
144
145
146
147
148
149
150
151
152
153
154
155
156
157
158
159
160
161
162
163
164
165
166
167
168
169
170
171
172
173
174
175
176
177
178
179
180
181
182
183
184
185
186
187
188
189
190
191
192
193
194
195
196
197
198
199
200
201
202
203
204
205
206
207
208
209
210
211
212
213
214
215
216
217
218
219
220
221
222
4 Activate拓展点，通过Activate注解标识一个类型为可激活类型，

public List getActivateExtension(URL url, String[] values, String group) { 
List exts = new ArrayList(); 
List names = values == null ? new ArrayList(0) : Arrays.asList(values); 
if (! names.contains(Constants.REMOVE_VALUE_PREFIX + Constants.DEFAULT_KEY)) { 
getExtensionClasses(); 
for (Map.Entry

wrapper类型增强扩展点类型

1.wapper类型判断条件

一、在SPI接口的拓展点中，如果存在以接口类型作为唯一参数的拓展点类型，那就是一个拓展点类型

//如果有以接口类型作为入参的构造，那这就是个wrapper
                                                try {
                                                    clazz.getConstructor(type);
                                                    Set<Class<?>> wrappers = cachedWrapperClasses;
                                                    if (wrappers == null) {
                                                        cachedWrapperClasses = new ConcurrentHashSet<Class<?>>();
                                                        wrappers = cachedWrapperClasses;
                                                    }
                                                    wrappers.add(clazz);
                                                }
1
2
3
4
5
6
7
8
9
10
二、warpper类型被载入的时机

在创建Extension实例的时候，将wrapper类型包装在实例之外。以达到功能增强目的。

 private T createExtension(String name) {
        Class<?> clazz = getExtensionClasses().get(name);
        if (clazz == null) {
            throw findException(name);
        }
        try {
            T instance = (T) EXTENSION_INSTANCES.get(clazz);
            if (instance == null) {
                EXTENSION_INSTANCES.putIfAbsent(clazz, (T) clazz.newInstance());
                instance = (T) EXTENSION_INSTANCES.get(clazz);
            }
            injectExtension(instance);
            Set<Class<?>> wrapperClasses = cachedWrapperClasses;
            if (wrapperClasses != null && wrapperClasses.size() > 0) {
                for (Class<?> wrapperClass : wrapperClasses) {
                    instance = injectExtension((T) wrapperClass.getConstructor(type).newInstance(instance));
                }
            }
            return instance;
        } catch (Throwable t) {
            throw new IllegalStateException("Extension instance(name: " + name + ", class: " +
                    type + ")  could not be instantiated: " + t.getMessage(), t);
        }
    }
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
5 三种SPI的比较

name	获取方式	默认实现	有无wrapper增强	根据条件激活拓展点	拓展点名字配置	适配类型拓展点	单例与原型支持	拓展点属性注入支持
java	迭代器	无	无	无	无	无	单例	不支持
motan	1、根据名字获取拓展点；2、根据key获取关键字拓展，结果被排序	无	无	通过Activation注解支持通过key过滤拓展点，并且可以设置排序输出	通过spiMeta注解配置，默认为实现类型名称	无	支持原型和单例，通过Spi注解配置	不支持
dubbo	1、根据名字获取单例。2、通过getActivateExtension方法获取对应Active注解过滤后的拓展列表	有，通过getDefault获取	在扩展点实例生成时应用wrapper	通过Activate与URL参数来达到条件激活（group与key）	在类路径文件中的key中指明，默认为类上Extension注解value值，或扩展点名字去掉接口名	通过Adaptive注解申明适配类型拓展点，如果没有，则通过拼接字节码生成适配类型拓展点	只支持单例	对于拓展点类型实例，默认从ExtensionFactory中获取该类型的拓展类型