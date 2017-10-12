

* [confd/docs at master · kelseyhightower/confd ](https://github.com/kelseyhightower/confd/tree/master/docs)


cat /etc/confd/templates/prom-hosts.tmpl


* [template - The Go Programming Language ](https://golang.org/pkg/text/template/)
* [Hugo | Introduction to Hugo Templating ](http://gohugo.io/templates/introduction/)

{{if pipeline}} T1 {{else}} T0 {{end}}
	If the value of the pipeline is empty, T0 is executed;
	otherwise, T1 is executed.  Dot is unaffected.

{{if pipeline}} T1 {{else if pipeline}} T0 {{end}}
	To simplify the appearance of if-else chains, the else action
	of an if may include another if directly; the effect is exactly
	the same as writing
		{{if pipeline}} T1 {{else}}{{if pipeline}} T0 {{end}}{{end}}