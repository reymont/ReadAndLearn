

* [igraph R manual pages ](http://igraph.org/r/doc/path.html)

```r
# Create a (directed) wheel
g <- make_star(11, center = 1) + path(2:11, 2)
plot(g)

g <- make_empty_graph(directed = FALSE, n = 10) %>%
  set_vertex_attr("name", value = letters[1:10])

g2 <- g + path("a", "b", "c", "d")
plot(g2)

g3 <- g2 + path("e", "f", "g", weight=1:2, color="red")
E(g3)[[]]

g4 <- g3 + path(c("f", "c", "j", "d"), width=1:3, color="green")
E(g4)[[]]
```