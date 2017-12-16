

Fluentd从tag字段分割提取新字段 - CSDN博客 http://blog.csdn.net/ptmozhu/article/details/52932357


"_index": "logstash-2016.10.19",
"_type": "fluentd",
"_id": "AVfcB42cEKo1rP0QdbCf",
"_version": 1,
"_score": 1,
"_source": {
"message": "test31",
"pod_name": "test",
"namespace_name": "default",
"container_name": "test",
"container_id": "286ca6a92d26b46342860b19cbba3406f7e9d3d8df41e3497d7f09d055495424",
"logdir": "3.log",
"tag":"k8s.applog.test_default.test.286ca6a92d26b46342860b19cbba3406f7e9d3d8df41e3497d7f09d055495424.log.3.log",
"@timestamp": "2016-10-19T16:21:03+08:00"
}

<source>  type tail
  format none
  path /var/log/containers/applog*/*
  pos_file /var/log/es-containers-app.log.pos
  time_format %Y-%m-%dT%H:%M:%S.%NZ
  tag reform.*
  read_from_head true
</source>


<match reform.**>
  type record_reformer
  renew_record false
  enable_ruby true
  tag k8s.${tag_suffix[4]}
  <record>
    pod_name ${tag_suffix[5].split('_')[0]}
    namespace_name ${tag_suffix[5].split('_')[1].split('.')[0]}
    container_name ${tag_suffix[6].split('.')[0]}
    container_id ${tag_suffix[7].split('.')[0]}
    logdir ${tag_suffix[9]}
  </record>
</match>
    //软链接/var/lib/kubelet/pods 获取容器的pod名，用于Elasticsearch日志搜集服务
    // /var/lib/kubelet/pods/+podUID+/volumes/kubernetes.io~empty-dir/logdir ->/var/log/containers/applog_podName_containerName_id.log
    //glog.Errorf("pod.Spec.Volumes[0] :%s", len(pod.Spec.Volumes))
    for i := 0; i < len(pod.Spec.Volumes); i++ {
        if pod.Spec.Volumes[i].EmptyDir != nil {
            emptydirname := pod.Spec.Volumes[i].Name
            cname := container.Name
            str := "logdir" + cname
            if emptydirname == str && cname != "POD" {
                podUID := kubecontainer.GetPodUID(pod)
                containerLogFile_emptdir := path.Join("/var/lib/kubelet/pods", podUID, "volumes/kubernetes.io~empty-dir", emptydirname)
                symlinkFile_emptdir := LogSymlink_emptdir(dm.containerLogsDir, kubecontainer.GetPodFullName(pod), container.Name, id.ID)
                if err = dm.os.Symlink(containerLogFile_emptdir, symlinkFile_emptdir); err != nil {
                    glog.Errorf("Failed to create symbolic link to the application's log file of pod %q container %q: %v", format.Pod(pod), container.Name, err)
                }
            }
        }
    }