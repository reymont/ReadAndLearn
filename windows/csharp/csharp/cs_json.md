

* [c# 解析JSON的几种办法 - 拓 - CSDN博客 ](http://blog.csdn.net/gaofang2009/article/details/6073029)

欲成为海洋大师，必知晓海中每一滴水的真名。
刚开始只是想找一个转换JSON数组的方法，结果在MSDN翻到一大把。
搜索过程中免不了碰到一大堆名词：WCF => DataContract => DataMember => DataContractJsonSerializer，然后就是不停的引入命名空间。
这一段经历，立即让我就联想到了上面引用的这句存在于某小说里面巫师的话语。静态语言真有点令人抓狂，不停的做准备，然后才可能开始工作。
对比
.NET下几种常见的解析JSON方法
主要类	命名空间	限制	内建LINQ支持
DataContractJsonSerializer	System.Runtime.Serialization.Json	通用	否
JavaScriptSerializer	System.Web.Script.Serialization	只能在Web环境使用	否
JsonArray 、JsonObject 、JsonValue	System.Json	只能在Silverlight中使用	是
JsonConvert 、JArray 、JObject 、JValue 、JProperty	Newtonsoft.Json	通用	是
准备数据
实体类：
    [DataContract] 
    public class Person 
    { 
        [DataMember(Order = 0, IsRequired = true)] 
        public string Name { get; set; } 
 
        [DataMember(Order = 1)] 
        public int Age { get; set; } 
 
        [DataMember(Order = 2)] 
        public bool Alive { get; set; } 
 
        [DataMember(Order = 3)] 
        public string[] FavoriteFilms { get; set; } 
 
        [DataMember(Order = 4)] 
        public Person Child { get; set; } 
    } 
定义：
Action<object> log = o => Console.WriteLine(o); 
Func<int, int, int> add = (x, y) => x + y; 
 
var p1 = new Person { 
    Age = 12, 
    Alive = true, 
    Name = "lj", 
    FavoriteFilms = new[] { "Up", "Avatar" } 
}; 
var p2 = new Person() { Age = 28, Name = "cy", Child = p1 }; 
             
使用DataContractJsonSerializer
帮助类：
    // using System.Runtime.Serialization.Json; 
     
    /// <summary> 
    /// 解析JSON，仿Javascript风格 
    /// </summary> 
    public static class JSON 
    { 
 
        public static T parse<T>(string jsonString) 
        { 
            using (var ms = new MemoryStream(Encoding.UTF8.GetBytes(jsonString))) 
            { 
                return (T)new DataContractJsonSerializer(typeof(T)).ReadObject(ms); 
            } 
        } 
 
        public static string stringify(object jsonObject) 
        { 
            using (var ms = new MemoryStream()) 
            { 
                new DataContractJsonSerializer(jsonObject.GetType()).WriteObject(ms, jsonObject); 
                return Encoding.UTF8.GetString(ms.ToArray()); 
            } 
        } 
    } 
用法：
    // 序列化 
    var jsonString = JSON.stringify(new[] { p1, p2 }); 
    log(jsonString == JSON.stringify(new List<Person>() { p1, p2 }));   //true 
    log(jsonString); 
    // 反序列化，泛型集合 
    JSON.parse<List<Person>>(jsonString); 
    // 数组转换             
    JSON.parse<Person[]>(jsonString); 
输出：
[{"Name":"lj","Age":12,"Alive":true,"FavoriteFilms":["Up","Avatar"],"Child":null 
},{"Name":"cy","Age":28,"Alive":false,"FavoriteFilms":null,"Child":{"Name":"lj", 
"Age":12,"Alive":true,"FavoriteFilms":["Up","Avatar"],"Child":null}}] 
使用JavaScriptSerializer
    // using System.Web.Script.Serialization; 
     
    var jser    = new JavaScriptSerializer(); 
    var json    = jser.Serialize(new List<Person>() { p1, p2 }); 
    var persons = jser.Deserialize<List<Person>>(json); 
使用Silverlight
    // using System.Json 
     
    var css = "{ /"#header/" : {background:/"red/"}, layout : [5,4,1],color:/"cyan/" }"; 
     
    var style = JsonObject.Parse(css) as JsonObject;     
     
    ( 
    from s in style 
    where s.Key == "color" 
    select (string)s.Value 
    ).First().ToString();     
    // "cyan" 
     
     
    // 更多操作 
    style["layout"][0] = 22; 
     
    var hd = style["#header"]; 
    style["body>div+p"] = hd; 
    style.Remove("#header"); 
     
    var bd = new JsonObject(); 
    bd["border"] = "1px solid cyan"; 
    style["body>div+p"]["#meta"] = bd; 
    style.ToString();     
    // {"layout":[22,4,1],"color":"cyan","body>div+p":{"background":"red","#meta":{"border":"1px solid cyan"}}} 
使用JSON.NET
    // using Newtonsoft.Json; 
     
    var json = JsonConvert.SerializeObject(new[] { p1, p2 }); 
    var persons = JsonConvert.DeserializeObject<List<Person>>(json); 
    var ja = JArray.Parse(jsonString);             
    log(ja);    //注意，格式化过的输出 
输出：
[ 
  { 
    "Name": "lj", 
    "Age": 12, 
    "Alive": true, 
    "FavoriteFilms": [ 
      "Up", 
      "Avatar" 
    ], 
    "Child": null 
  }, 
  { 
    "Name": "cy", 
    "Age": 28, 
    "Alive": false, 
    "FavoriteFilms": null, 
    "Child": { 
      "Name": "lj", 
      "Age": 12, 
      "Alive": true, 
      "FavoriteFilms": [ 
        "Up", 
        "Avatar" 
      ], 
      "Child": null 
    } 
  } 
] 
LINQ：
    var ageCount = ja.Select(j => (int)j["Age"]).Aggregate(add);     
    var q = from j in ja 
            where !j["Name"].Value<string>().Equals("lj") 
            select (int)j["Age"]; 
     
    log(q.Aggregate(add) == ageCount);  //false 
其他：
    // 与Linq to XML 相似的嵌套构造函数： 
    var jo = new JObject( 
                    new JProperty("age", persons.Select( p => p.Age)), 
                    new JProperty("funny", true), 
                    new JProperty("array", new JArray(new[] { 2, 4, 1 })) 
                    ); 
    log(jo); 
     
    // JObject 操作 
    var css = "{ /"#header/" : {background:/"red/"}, layout : [5,4,1] }"; 
    var style = JObject.Parse(css); 
 
    var bd = new JObject(); 
    bd["color"] = "1px solid cyan"; 
 
    style["border"] = bd; 
 
    var hd = style["#header"]; 
    style["body>div+p"] = hd; 
 
    hd.Parent.Remove(); 
 
    style["layout"][0] = 22; 
    log(style); 
输出：
    { 
      "age": [ 
        12, 
        28 
      ], 
      "funny": true, 
      "array": [ 
        2, 
        4, 
        1 
      ] 
    } 
    { 
      "layout": [ 
        22, 
        4, 
        1 
      ], 
      "border": { 
        "color": "1px solid cyan" 
      }, 
      "body>div+p": { 
        "background": "red" 
      } 
    } 
 
 
来自：http://www.mzwu.com/article.asp?id=1913
 
实体类Student：
复制内容到剪贴板程序代码
/// <summary>
/// 学生实体类
/// </summary>
[System.Runtime.Serialization.DataContract(Namespace="http://www.mzwu.com/")]
public class Student
{
    private string _Name;
    private int _Age;

    public Student(string name, int age)
    {
        _Name = name;
        _Age = age;
    }

    /// <summary>
    /// 姓名
    /// </summary>
    [System.Runtime.Serialization.DataMember]
    public string Name
    {
        set {_Name = value;}
        get { return _Name; }
    }

    /// <summary>
    /// 年龄
    /// </summary>
    [System.Runtime.Serialization.DataMember]
    public int Age
    {
        set { _Age = value; }
        get { return _Age; }
    }
}

注意：必须使用DataContractAttribute对类进行标记，使用DataMemberAttribute类成员进行标记，否则该类无法被序列化。

对象转为JSON字符串
复制内容到剪贴板程序代码
Student stu = new Student("张三", 20);

System.Runtime.Serialization.Json.DataContractJsonSerializer json = new System.Runtime.Serialization.Json.DataContractJsonSerializer(stu.GetType());
using (MemoryStream stream = new MemoryStream())
{
    json.WriteObject(stream, stu);
    Response.Write(System.Text.Encoding.UTF8.GetString(stream.ToArray()));
}

JSON字符串转为对象
复制内容到剪贴板程序代码
System.Runtime.Serialization.Json.DataContractJsonSerializer json = new System.Runtime.Serialization.Json.DataContractJsonSerializer(typeof(Student));
using (MemoryStream stream = new MemoryStream(System.Text.Encoding.UTF8.GetBytes("{/"Age/":20,/"Name/":/"张三/"} ")))
{
    Student stu = (Student)json.ReadObject(stream);
    Response.Write(string.Format("name:{0},age:{1}", stu.Name, stu.Age));
}