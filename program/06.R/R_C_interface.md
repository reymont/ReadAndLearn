
#R的C接口

<!-- @import "[TOC]" {cmd:"toc", depthFrom:1, depthTo:6, orderedList:false} -->
<!-- code_chunk_output -->

* [R的C接口](#r的c接口)
* [概述](#概述)
	* [大纲](#大纲)
	* [预备知识](#预备知识)
* [找到函数的C源代码](#找到函数的c源代码)
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

##大纲

- `调用C`介绍使用内联包来创建和调用C函数的基础知识。
- `C数据结构`说明怎样将R转化为C的数据结构。
- `创建和修改向量`告诉你如何在C中创建、修改和强制转型向量
- `配对列表`展示如何使用配对列表。你需要知道这一点，因为对配对列表和列表的区分在C语言中比R更重要
- `输入验证`讲的是输入验证的重要性，用来最大程度的保证C函数不会崩溃。
- `找到函数的C源代码`展示如何查找原始R函数的C源代码，从而结束了这篇文章。

##预备知识
要理解现有的C代码，生成自己可以进行实验的简单示例，是很有帮助的。为此，本篇文章中的所有示例都使用内联包，这使得编译和链接C代码到当前的R会话非常容易。通过运行`install.packages("inline")`来获取。要找到与R函数相关联的C代码，需要从pryr包。运行`install.packages("pryr")`来获取。

还需要一个C编译器。Windows用户可以使用[Rtools](http://cran.r-project.org/bin/windows/Rtools/)。 Mac用户需要[Xcode命令行工具](http://developer.apple.com/)。大多数Linux发行版都附带必要的编译器。

在Windows中，Rtools可执行目录(通常是C:\Rtools\bin)和C编译器可执行目录(通常是C:\Rtools\gcc-4.6.3\bin)都包含在Windows PATH环境变量中。在R能够识别这些值之前可能需要重新启动Windows。

#找到函数的C源代码

- [R: Tabulation for Vectors ](https://stat.ethz.ch/R-manual/R-devel/library/base/html/tabulate.html)简化版的`table`函数

在基本包中，R不使用`.call()`来调用C函数。相反，R使用两个特殊的函数:`.Internal()`和`.Primitive()`。查找这些函数的源代码是很困难的：首先需要在`src/main/name.c`中查找C函数名，然后搜索R源代码。`pryr::show_c_source()`使用GitHub代码搜索自动完成这个任务。

```R
tabulate
## function (bin, nbins = max(1L, bin, na.rm = TRUE)) 
## {
##     if (!is.numeric(bin) && !is.factor(bin)) 
##         stop("'bin' must be numeric or a factor")
##     if (typeof(bin) != "integer") 
##         bin <- as.integer(bin)
##     if (nbins > .Machine$integer.max) 
##         stop("attempt to make a table with >= 2^31 elements")
##     nbins <- as.integer(nbins)
##     if (is.na(nbins)) 
##         stop("invalid value of 'nbins'")
##     .Internal(tabulate(bin, nbins))
## }
## <bytecode: 0x50dc4b8>
## <environment: namespace:base>
pryr::show_c_source(.Internal(tabulate(bin, nbins)))
#> tabulate is implemented by do_tabulate with op = 0
```
下面显示了C的源代码（为了清晰起见，稍微编辑了一下）：
```R
SEXP attribute_hidden do_tabulate(SEXP call, SEXP op, SEXP args, 
                                  SEXP rho) {
  checkArity(op, args);
  SEXP in = CAR(args), nbin = CADR(args);
  if (TYPEOF(in) != INTSXP)  error("invalid input");

  R_xlen_t n = XLENGTH(in);
  /* FIXME: could in principle be a long vector */
  int nb = asInteger(nbin);
  if (nb == NA_INTEGER || nb < 0)
    error(_("invalid '%s' argument"), "nbin");
  
  SEXP ans = allocVector(INTSXP, nb);
  int *x = INTEGER(in), *y = INTEGER(ans);
  memset(y, 0, nb * sizeof(int));
  for(R_xlen_t i = 0 ; i < n ; i++) {
    if (x[i] != NA_INTEGER && x[i] > 0 && x[i] <= nb) {
      y[x[i] - 1]++;
    }
  }
     
  return ans;
}
```
`.Internal()`和`.Primitive()`与`.call()`函数稍稍不同。它们都有四个参数:

- SEXP call: the complete call to the function. CAR(call) gives the name of the function (as a symbol); CDR(call) gives the arguments.
- SEXP op: an “offset pointer”. This is used when multiple R functions use the same C function. For example do_logic() implements &, |, and !. show_c_source() prints this out for you.
- SEXP args: a pairlist containing the unevaluated arguments to the function.
- SEXP rho: the environment in which the call was executed.

This gives internal functions an incredible amount of flexibility as to how and when the arguments are evaluated. For example, internal S3 generics call DispatchOrEval() which either calls the appropriate S3 method or evaluates all the arguments in place. This flexibility come at a price, because it makes the code harder to understand. However, evaluating the arguments is usually the first step and the rest of the function is straightforward.

The following code shows do_tabulate() converted into standard a .Call() interface:

```R
tabulate2 <- cfunction(c(bin = "SEXP", nbins = "SEXP"), '
  if (TYPEOF(bin) != INTSXP)  error("invalid input");
  
  R_xlen_t n = XLENGTH(bin);
  /* FIXME: could in principle be a long vector */
  int nb = asInteger(nbins);
  if (nb == NA_INTEGER || nb < 0)
    error("invalid \'%s\' argument", "nbin");

  SEXP ans = allocVector(INTSXP, nb);
  int *x = INTEGER(bin), *y = INTEGER(ans);
  memset(y, 0, nb * sizeof(int));
  for(R_xlen_t i = 0 ; i < n ; i++) {
    if (x[i] != NA_INTEGER && x[i] > 0 && x[i] <= nb) {
      y[x[i] - 1]++;
    }
  }
     
  return ans;
')
tabulate2(c(1L, 1L, 1L, 2L, 2L), 3)
## [1] 3 2 0
```
To get this to compile, I also removed the call to _() which is an internal R function used to translate error messages between different languages.

The final version below moves more of the coercion logic into an accompanying R function, and does some minor restructuring to make the code a little easier to understand. I also added a PROTECT(); this is probably missing in the original because the author knew that it would be safe.
```R
tabulate_ <- cfunction(c(bin = "SEXP", nbins = "SEXP"), '  
  int nb = asInteger(nbins);

  // Allocate vector for output - assumes that there are 
  // less than 2^32 bins, and that each bin has less than 
  // 2^32 elements in it.
  SEXP out = PROTECT(allocVector(INTSXP, nb));
  int *pbin = INTEGER(bin), *pout = INTEGER(out);
  memset(pout, 0, nb * sizeof(int));

  R_xlen_t n = xlength(bin);
  for(R_xlen_t i = 0; i < n; i++) {
    int val = pbin[i];
    if (val != NA_INTEGER && val > 0 && val <= nb) {
      pout[val - 1]++; // C is zero-indexed
    }
  }
  UNPROTECT(1);   
  
  return out;
')

tabulate3 <- function(bin, nbins) {
  bin <- as.integer(bin)
  if (length(nbins) != 1 || nbins <= 0 || is.na(nbins)) {
    stop("nbins must be a positive integer", call. = FALSE)
  }
  tabulate_(bin, nbins)
}
tabulate3(c(1, 1, 1, 2, 2), 3)
## [1] 3 2 0
```

#相关文章
- [Advanced R ](http://adv-r.hadley.nz/)
- [R for Data Science ](http://r4ds.had.co.nz/)
- [Welcome · R packages ](http://r-pkgs.had.co.nz/)
- [hadley/devtools: Tools to make an R developer's life easier ](https://github.com/hadley/devtools)
- [hadley/r4ds: R for data science ](https://github.com/hadley/r4ds)
- [R与C的接口：从R调用C的共享库 – 不周山 ](http://www.wentrue.net/blog/?p=72)
- [R调用C（Windows） - 娱悦的日志 - 网易博客 ](http://lichune88.blog.163.com/blog/static/630270682012112763746987/##1)
- [R语言-R调用C++程序 - 渡辺麻友 - CSDN博客 ](http://blog.csdn.net/ACHelloWorld/article/details/42264729)