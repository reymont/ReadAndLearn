契约测试框架-Pact实践 - 不负春光，努力生长 - 博客园 https://www.cnblogs.com/Wolfmanlq/p/7966408.html

契约测试框架-Pact实践

在前一篇博客中我们讲到契约测试是什么，以及它能给我们软件交付带来什么价值，本次将介绍一个开源的契约测试框架Pact，它最初是用ruby语言实现的，后来被js，C#，java，go，python 等语言重写，此文将介绍Pact框架的相关知识并结合示例代码讲解在实际项目中应该怎么使用。

Pact是什么？

Pact是一个开源框架，最早是由澳洲最大的房地产信息提供商REA Group的开发者及咨询师们共同创造。REA Group的开发团队很早便在项目中使用了微服务架构，并在团队中对于敏捷和测试的重要性早已形成共识，因此设计出这样的优秀框架并应用于日常工作中也是十分自然。

Pact工具于2013年开始开源，发展到今天已然形成了一个小的生态圈，包括各种语言（Ruby/Java/.NET/JavaScript/Go/Scala/Groovy...）下的Pact实现，契约文件共享工具Pact Broker等。Pact的用户已经遍及包括RedHat、IBM、Accenture等在内的若干知名公司，Pact已经是事实上的契约测试方面的业界标准。

Pact可以用来做什么？

Pact是支持消费者驱动的契约测试框架，针对微服务的模式下多个单独服务的接口契约测试以及前后端分离的模式提供了很好的支持。

Pact的工作原理

消费者端作为数据的最终使用者非常清楚，明确的知道需要的什么样格式，类型的数据，它将负责创建契约文档（包含结构和格式的json文件），服务提供端将根据消费者端创建的契约文档提供对应格式的数据并返回给消费者，通过契约检查判断如果服务端提供的数据和消费者生成的契约不匹配，将抛出异常并提示给服务端。总结如下：

在消费者项目代码中编写单元测试，期望响应设置于模拟的服务提供者上。
在测试运行时，模拟的服务将返回所期望的响应。请求和所期望的响应将会被写入到一个“pact”文件中。
pact文件中的请求随后在提供者上进行重放，并检查实际响应以确保其与所期望响应相匹配。


 

Pact相关的术语

   服务消费者

　　服务消费者是指向另一组件（服务提供者）发起HTTP请求的组件。注意这并不依赖于数据的发送方式——无论是GET还是PUT / POST / PATCH，消费者都是HTTP请求的发起者。

　服务提供者

　　服务提供者是指向另一组件（服务消费者）的HTTP请求提供响应的服务器。

    模拟服务提供者
　　模拟服务提供者用于在消费者项目中的单元测试里模拟真实的服务提供者，意味着不必需要真实的服务提供者就绪，就可以将类集成测试运行起来。

    Pact文件

　　Pact文件是指一个含有消费者测试中所定义的请求和响应被序列化后的JSON的文件，即契约。

    Pact验证（契约验证）
　　要对一个Pact进行验证，就要对Pact文件中所包含的请求基于提供者代码进行重放，然后检查返回的响应，确保其与Pact文件中所期望响应相匹配。

    提供者状态

　　在对提供者重放某个给定的请求时，一个用于描述此时提供者应具有的“状态”（类似于夹具）的名字——比如“when user ken does not exists”或“when user ken has a bank account”。

　　提供者状态的名字是在写消费者测试时被指定的，之后当运行提供者的pact验证时，这个名字将被用于唯一标识在请求执行前应运行的代码块。

Pact适用的场景

       当你的团队同时负责开发服务消费者与服务提供者，并且服务消费者的需求被用来驱动服务提供者的功能时，Pact对于在服务集成方面进行设计和测试是最具价值 的。它是组织内部                 开发和测试微服务，前后端分离项目的绝佳工具。

Pact不适用的场景

性能和压力测试。
服务提供者的功能测试——这是服务提供者自己的测试应该做的。Pact是用来检查请求和响应的内容及格式。
当你在必须使用实际测试的API才能将数据载入服务提供者的情况下，因为你的服务提供者中存在了无法mock的第三方的依赖
“透传”API的测试，是指服务提供者仅将请求内容传递到下游服务而不做任何验证。
Pact使用实例

　　下面将展示代码示例，这是一个前后端分离的项目，前端使用javascript访问后端api获取数据，后端使用.net WebApi 提供数据的返回

   后端代码：

 　　新建BookingController，返回一个预定对象的信息，访问地址： http://localhost:51502/api/booking 

复制代码
public class BookingController : ApiController
    {
        // GET: Booking
        [HttpGet]
        public BookingModel Get()
        {
            return new BookingModel()
            {
                Id = 12,
                FirstName = "Ken",
                LastName = "Wang",
                Users = new List<User>()
                {
                    new User()
                    {
                        Name = "asd",
                        Age = "1"
                    },
                     new User()
                    {
                        Name = "asd",
                        Age = "1"
                    },
                    new User()
                    {
                        Name = "kenwang",
                        Age = "223",
                        Address = "shangxi road"
                    }
                }
            };
        }
    }
复制代码
BookingModel 实体定义如下：

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
public class BookingModel
    {
        public int Id { get; set; }
 
        public string FirstName { get; set; }
 
        public string LastName { get; set; }
 
        public List<User> Users { get; set; }
    }
 
    public class User
    {
        public string Name { get; set; }
 
        public string Age { get; set; }
 
        public string Address { get; set; }
    }
返回对象格式如下：

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
{
    "Id": 12,
    "FirstName": "Ken",
    "LastName": "Wang",
    "Users": [
        {
            "Name": "asd",
            "Age": "1",
            "Address": 0
        },
        {
            "Name": "asd",
            "Age": "1",
            "Address": 0
        },
        {
            "Name": "kenwang",
            "Age": "223",
            "Address": "shanxi road"
        }
    ]
}
服务端就好了，下面看消费端实现

 client.js 负责发起调用请求来获取数据：

复制代码
const request = require('superagent')
const API_HOST = process.env.API_HOST || 'http://localhost'
const API_PORT = 51502
const moment = require('moment')
const API_ENDPOINT = `${API_HOST}:${API_PORT}`

// Fetch provider data
const fetchProviderData = () => {
  return request
    .get(`${API_ENDPOINT}/api/booking`)
    .then((res) => {
        var Users = [];
        Users.push({
          Name: 'user1',
          Age : '11'
        });
      
        Users.push({
          Name: 'asd',
          Age : '1'
        });

        return {
          Id: 12,
          FirstName: 'ken',
          LastName: 'wang',
          Users: Users
        }
    }, (err) => {
      throw new Error(`Error from response: ${err.body}`)
    })
}

module.exports = {
  fetchProviderData
}
复制代码
 

consumer.js负责调用client.js的方法获取数据，拿到数据之后记录日志

复制代码
const client = require('./client')

client.fetchProviderData().then(response => {
  console.log(response)
}, error => {
  console.error(error)
})
复制代码
添加client.js的测试代码，前面的工作原理部分讲到契约的生成是依赖于消费者端的测试代码而生成，也就是说消费者端通过单元测试既覆盖了代码逻辑，又帮助我们生成了契约文件。

consumerPact.spec.js文件是对client的测试：

复制代码
const chai = require('chai')
const path = require('path')
const chaiAsPromised = require('chai-as-promised')
const pact = require('pact')
const expect = chai.expect
const API_PORT = process.env.API_PORT || 51502
const {
  fetchProviderData
} = require('../client')
chai.use(chaiAsPromised)

// Configure and import consumer API
// Note that we update the API endpoint to point at the Mock Service
const LOG_LEVEL = process.env.LOG_LEVEL || 'WARN'

const provider = pact({
  consumer: 'Consumer Demo',
  provider: 'Provider Demo',
  port: API_PORT,
  log: path.resolve(process.cwd(), 'logs', 'pact.log'),
  dir: path.resolve(process.cwd(), 'pacts'),
  logLevel: LOG_LEVEL,
  spec: 2
})
// Alias flexible matchers for simplicity
const { somethingLike: like,eachLike: eachLike, term } = pact.Matchers

describe('Pact with Our Provider', () => {
  before(() => {
    return provider.setup()
  })

  describe('given data count > 0', () => {
    describe('when a call to the Provider is made', () => {
      describe('and a valid date is provided', () => {
        before(() => {
          return provider.addInteraction({
            uponReceiving: 'a request for JSON data',
            withRequest: {
              method: 'GET',
              path: '/api/booking'
            },
            willRespondWith: {
              status: 200,
              headers: {
                'Content-Type': 'application/json; charset=utf-8'
              },
              body: {
                Id: like(10),
                FirstName: like('ken'),
                LastName: like('wang'),
                Users: eachLike({
                  "Name": like('test'),
                  "Age": like('10')
              },{min:1})
              }
            }
          })
        })

        it('can process the JSON payload from the provider', done => {
          const response = fetchProviderData()

          expect(response).to.eventually.have.property('Id', 10)
        })

        it('should validate the interactions and create a contract', () => {
          return provider.verify()
        })
      })

      

      
    })
  })

  

  // Write pact files to file
  after(() => {
    return provider.finalize()
  })
})
复制代码
okay，消费者端的代码已经完成，我们来执行一下consumer.js,成功之后便会生成对应的contract文件，如下：

复制代码
{
  "consumer": {
    "name": "Consumer Demo"
  },
  "provider": {
    "name": "Provider Demo"
  },
  "interactions": [
    {
      "description": "a request for JSON data",
      "providerState": "data count > 0",
      "request": {
        "method": "GET",
        "path": "/api/booking"
      },
      "response": {
        "status": 200,
        "headers": {
          "Content-Type": "application/json; charset=utf-8"
        },
        "body": {
          "Id": 10,
          "FirstName": "ken",
          "LastName": "wang",
          "Users": [
            {
              "Name": "test",
              "Age": "10"
            }
          ]
        },
        "matchingRules": {
          "$.body.Id": {
            "match": "type"
          },
          "$.body.FirstName": {
            "match": "type"
          },
          "$.body.LastName": {
            "match": "type"
          },
          "$.body.Users": {
            "min": 1
          },
          "$.body.Users[*].*": {
            "match": "type"
          },
          "$.body.Users[*].Name": {
            "match": "type"
          },
          "$.body.Users[*].Age": {
            "match": "type"
          }
        }
      }
    }
  ],
  "metadata": {
    "pactSpecification": {
      "version": "2.0.0"
    }
  }
}
复制代码
这就是需要消费端需要的数据格式，而作为服务提供者提供给消费者的数据必须满足这样的约束，否则就是测试失败的，下面我们建立一个C# 的contract test的工程，然后测试消费端和提供端是否匹配统一的契约。测试工程需要引用xUnit 和 PactNet的Nuget包，直接从Nuget server下载安装就可以了，会把所有的依赖都添加进来。

新建BookingContractApiTesting 的class：

复制代码
private readonly ITestOutputHelper _output;

      
        public RetriveBookingApiContractTesting(ITestOutputHelper output)
        {
            _output = output;
        }

        [Fact]
        public void EnsureEventApiHonoursPactWithConsumer()
        {
            const string serviceUri = "http://localhost:51502";

            var config = new PactVerifierConfig
             {
                 Outputters = new List<IOutput>
                                  {
                                      new XUnitOutput(_output)
                                  },
                 Verbose = false
             };

            IPactVerifier pactVerifier = new PactVerifier(config);
            pactVerifier
                .ServiceProvider("Event API", serviceUri)
                .HonoursPactWith("Event API Consumer")
                .PactUri("userclient-userservice.json")
                .Verify();
        }
复制代码
写完之后我们来运行一下，结果显示通过：

 

 从上面的Api返回的字段来看我们其实是多给消费端返回了一个Address字段，但是契约检查并没有报错，这说明契约检查时是按照最小原则检查的，即使是api多返回数据依然是可以的，但是如果api返回的字段中少了契约中的字段，那会怎样呢，我们来试着删除掉api返回的Id字段。重启api之后我们再跑一遍测试，结果显示如下：



运行结果会显示实际返回的和期望的差异，这就达到了契约测试的目的。

Pact 匹配规则

我们可以看到生成的contract文件中有matchingRules 的节点，这个节点下面就是为了添加匹配规则的，目前支持四种匹配方式：

 正则匹配：

      将执行正则表达式匹配值的字符串表示

 类型匹配：

　  将根据值执行一个类型的匹配，也就是说，如果它们是相同的类型，则它们是相等的

 元素最小长度匹配：

　　根据值执行一个类型的匹配，也就是说，如果它们是相同的类型，则它们是相等的。此外，如果值表示集合，则实际值的长度与最小值进行比较。

 集合最大长度匹配：

　　根据值执行一个类型的匹配，也就是说，如果它们是相同的类型，则它们是相等的。此外，如果值表示集合，则实际值的长度与最大值进行比较。

 

类型匹配只适用于一些简单类型的匹配，负责类型，如邮箱等需要用正则来匹配。

 

写在最后

　　内容就介绍到这里，如果大家有更好的经验，欢迎分享交流。

　　学习参考：

　　　　https://docs.pact.io/ 

　　　　https://github.com/pact-foundation/pact-net.git

　　　　https://github.com/cwilcox-fl/Pact-Net-Core.git

　　　　https://github.com/pact-foundation/pact-js.git

 

如果您觉得本文对你有用，不妨帮忙点个赞，或者在评论里给我一句赞美，小小成就都是今后继续为大家编写优质文章的动力！ 欢迎您持续关注我的博客：)
作者：Ken Wang
出处：http://www.cnblogs.com/Wolfmanlq/
版权所有，欢迎保留原文链接进行转载：)