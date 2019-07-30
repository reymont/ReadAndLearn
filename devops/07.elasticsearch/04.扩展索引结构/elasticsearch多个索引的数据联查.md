elasticsearch多个索引的数据联查 - 柳牧之的博客 - CSDN博客 https://blog.csdn.net/u012976879/article/details/86507292

1.数据入库
```json
PUT /my_index/user/1     
{
  "name":     "John Smith",
  "email":    "john@smith.com",
  "dob":      "1970/10/24"
}

PUT /your_index/blogpost/2 
{
  "title":    "Relationships",
  "body":     "It's complicated...",
  "user":     1         
}
```
2.my_index库和your_index库一句查询语句查出

 GET /my_index,your_index/_search