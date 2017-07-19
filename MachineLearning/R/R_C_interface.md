
#R的C接口

<!-- @import "[TOC]" {cmd:"toc", depthFrom:1, depthTo:6, orderedList:false} -->
<!-- code_chunk_output -->

* [R的C接口](#r的c接口)
* [概述](#概述)
* [相关文章](#相关文章)

<!-- /code_chunk_output -->

原文：[R's C interface · Advanced R. ](http://adv-r.had.co.nz/C-interface.html)

#概述

阅读R源代码是提高编程技能的一种直接有效的方式。但是，许多基本的R函数，以及旧包中的许多函数，都是用C编写的。能够指出这些函数的工作方式是很有用的，因此本章将介绍R的C API。你需要一些基本的C知识，可以从C语言标准文档中获得(比如[The C Programming Language](http://amzn.com/0131101633?tag=devtools-20))，或者从[Rcpp](http://adv-r.had.co.nz/Rcpp.html#rcpp)。你需要一点耐心。阅读R的C源代码后，你将会学到很多东西。

这一章的内容大篇幅的抽取[Writing R extensions](http://cran.r-project.org/doc/manuals/R-exts.html)第5节的内容，然而，那篇文章主要关注最佳实践和现代开发工具。这意味着它不包含旧、或者很少使用C接口这一语言特性。旧API在`Rdefines.h`中定义。从R中找到并显示这个文件是很容易的事情：

```R
rinternals <- file.path(R.home("include"), "Rinternals.h")
file.show(rinternals)
```

所有的函数都是用前缀`Rf_`或`R_`定义的，而导出的时候并没有前缀(exported without it)(除非使用了`#define R_NO_REMAP`)

我并不推荐使用C来编写新的高性能代码，可以使用Rcpp写C++来代替。Rcpp API不受R API的许多历史特性的限制，处理内存管理，并提供许多有用的辅助方法。

#相关文章
- [Advanced R ](http://adv-r.hadley.nz/)
- [R for Data Science ](http://r4ds.had.co.nz/)
- [Welcome · R packages ](http://r-pkgs.had.co.nz/)
- [hadley/devtools: Tools to make an R developer's life easier ](https://github.com/hadley/devtools)
- [hadley/r4ds: R for data science ](https://github.com/hadley/r4ds)
- [R与C的接口：从R调用C的共享库 – 不周山 ](http://www.wentrue.net/blog/?p=72)
- [R调用C（Windows） - 娱悦的日志 - 网易博客 ](http://lichune88.blog.163.com/blog/static/630270682012112763746987/##1)
- [R语言-R调用C++程序 - 渡辺麻友 - CSDN博客 ](http://blog.csdn.net/ACHelloWorld/article/details/42264729)