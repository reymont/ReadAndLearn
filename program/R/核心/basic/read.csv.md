 [Attribute Plots ](https://cran.r-project.org/web/packages/UpSetR/vignettes/attribute.plots.html)

```r
library(UpSetR)
library(ggplot2)
library(grid)
library(plyr)
movies <- read.csv(system.file("extdata", "movies.csv", package = "UpSetR"), 
    header = T, sep = ";")
```
