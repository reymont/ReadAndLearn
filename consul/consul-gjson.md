

## gjson



```go
        "github.com/tidwall/gjson"

		hosts , _ := consul.GetValue("/runtime/prometheus/exporters/hosts")
		values := gjson.Parse(hosts).Array()
		var addData []string
		var allData []string

		for key := range service {
			s := consul.GetService(key)
			allData = append(allData,s.ServiceAddress+":9100")
			if !strings.Contains(hosts,s.ServiceAddress){
				addData = append(addData,s.ServiceAddress+":9100")
			}
		}

		//如果consul hosts中的值比service的值要大，表示可能发生ServiceDeregister
		//重新生成kv hosts
		logger.Info("len(values) %v > len(service) %v ", len(values),len(service))
		if len(values) > len(service) {
			values = make([]gjson.Result,0)
			for _,e := range allData {
				values = append(values,gjson.Result{Type:gjson.String,Str:e})
			}
			syncService(values)
		} else if len(addData) > 0 {
			for _, e := range addData {
				values = append(values, gjson.Result{Type: gjson.String, Str: e})
			}
			syncService(values)
		}
```