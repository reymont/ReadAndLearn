用Python如何获取XML中的CDATA数据？ - SegmentFault 思否 https://segmentfault.com/q/1010000000164974

```py
#! /usr/bin/env python
#-*- coding: UTF-8 -*-

import re

s = u"<![CDATA[ apache配置flask出现错误 ]]>";

rgx = re.compile("\<\!\[CDATA\[(.*?)\]\]\>")
m = rgx.search(s)
print m.group(1)
```