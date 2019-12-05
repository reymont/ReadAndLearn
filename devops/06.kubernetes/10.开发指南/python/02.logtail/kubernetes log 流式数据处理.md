https://blog.51cto.com/cwtea/2329270?source=dra


PS： 最近在重构公司的业务容器化平台，记录一块。关于容器日志的， kubernetes python API本身提供了日志流式数据，在以前的版本是不会输出新数据的，后续版本进行了改进。

直接上代码
Flask 前端路由块
```py
# Router
"""获取项目pod的日志"""
@api_cluster_pod.route('/<env>/<cluster_name>/pod/<pod_name>/log')
@env_rules
def api_cluster_pod_log(env, cluster_name, pod_name):
    """查看pod的log"""

    tail_lines = request.values.get("tail_lines", 1000)
    namespace = request.values.get("namespace", "")

    # 生成Config Object
    try:
        cluster_config = ClusterConfig(
            env=env,
            cluster_name=cluster_name,
            namespace=namespace
        )
    except Exception as e:
        return jsonify(dict(
            code=5000,
            message='获取集群接口时未找到对应条目, 信息：{0}'.format(str(e))
        ))

    try:
        poder = Pod( cluster_config)
        resp = Response(stream_with_context(poder.get_pod_log(pod_name, tail_lines)), mimetype="text/plain")
        return resp

    except Exception as e:
        return jsonify(dict(
            code=7000,
            message=str(e)
        ))
Flask 后端代码块
# 后台功能
class Pod:
    ...
       def get_pod_log(self, pod_name, tail_lines=100):
        """
        获取pod的日志
        :param tail_lines: # 显示最后多少行
        :return:
        """
        try:
            # stream pod log
            streams = self.cluster.api.read_namespaced_pod_log(
                pod_name,
                self.cluster_config.namespace,
                follow=True,
                _preload_content=False,
                tail_lines=tail_lines).stream()
            return streams

        except ApiException as e:
            if e.status == 404:
                logger.exception("Get Log not fund Podname: {0}".format(pod_name))
                raise PodNotFund("获取日志时，未找到此pod: {0}".format(pod_name))
            if e.status == 400:
                raise PodNotFund("容器并未创建成功，请联系运维人员进行排查。")
            raise e
        except Exception as e:
            logger.exception("Get Log Fail: {0}".format(str(e)))
            raise e
HTML
<!DOCTYPE>
<html>
<head>
    <title>Flushed ajax test</title>
    <meta charset="UTF-8" />
    <script type="text/javascript" src="https://cdn.bootcss.com/jquery/3.0.0/jquery.min.js"></script>

    <style>
        #log-container {
            height: 800px;
            /*width: 800px;*/
            overflow-x: scroll;
            padding: 10px;
        }
        .logs {
            background-color: black;
            color: aliceblue;
            font-size: 18px;
        }
    </style>
</head>
<body>
<div id="log-container">
    <pre class="logs">
    </pre>
</div>

<script type="text/javascript">
    var last_response_len = false;
    var logs = $("#log-container");
    $.ajax('http://localhost/api/pre/ops-test/pod/ops-test-1211763235-jfbst/log?tail_lines=100', {
        xhrFields: {
            onprogress: function(e)
            {
                var this_response, response = e.currentTarget.response;
                if(last_response_len === false)
                {
                    this_response = response;
                    last_response_len = response.length;
                }
                else
                {
                    this_response = response.substring(last_response_len);
                    last_response_len = response.length;
                }
                // console.log(this_response);
                // 接收服务端的实时日志并添加到HTML页面中
                $("#log-container pre").append(this_response);
                // 滚动条滚动到最低部
                $("#log-container").scrollTop($("#log-container pre").height() - $("#log-container").height() + 10);
            }
        }
    })
        .done(function(data)
        {

            console.log('Complete response = ' + data);
        })
        .fail(function(data)
        {
            console.log('Error: ', data);
        });
    console.log('Request Sent');
</script>
</body>
</html>
```
其它
我们应用是前后端分离的，把html里面的核心代码放置VUE里面就可以了。

效果图
日志是流式的，如果Container有日志，则窗口会运态更新。