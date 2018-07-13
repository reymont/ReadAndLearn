Git设置忽略排除和重新添加已经被忽略过文件（夹）的方法 - CSDN博客 http://blog.csdn.net/cyxlzzs/article/details/61422214

场景描述

在使用git的时候，项目开始我们设置了一些需要忽略的文件和文件夹，比如一些工程文件和项目依赖库，以免多个开发者本地环境不一样和工程文件过大的问题。但后期发现那些已经被我们忽略掉的文件需要重新添加或者忽略的文件夹里面有某个文件（夹）是需要大家一致的，需要设置一下排除，下面我们针对这两种场景讲一下解决办法

设置忽略排除

设置忽略我们通常是在.gitignore文件中设置，比如在laravel框架中我们设置忽略整个vendor文件夹，则在.gitignore中添加如下路径

/vendor/*
1
路径中的星号表示所有，如果需要这是后续的排除，这里的星号很重要

接下来我们设置忽略的文件夹中有一个文件夹里面的内容不需要忽略

!/vendor/laravel/framework/src/Illuminate/Auth/
1
!表示排除的意思，当然如果忽略某个文件就直接指定就行了，比如

!/vendor/laravel/framework/src/Illuminate/Auth/TokenGuard.php
1
好，设置忽略和设置忽略排除，这里就基本行了

重新添加已经被忽略过的文件（夹）

重新添加已经被忽略过的文件时，我们仅仅使用git add是不行的，因为git仓库中根本没有那个文件，这时候我们需要加上-f参数来强制添加到仓库中，然后在提交。比如上面设置了忽略排除的文件TokenGuard.php我们需要重新加入

git add -f /vendor/laravel/framework/src/Illuminate/Auth/TokenGuard.php
1
然后在commit和push就行了

# 忽略已经提交过的文件

这里说点题外话，有的时候我们需要忽略掉以前提交过的文件，因为git已经索引了该文件所以我们先要删除掉该文件的缓存，如文件User.php已经提交过了，现在我们想忽略，这是我们先在.gitignore中设置该文件为忽略，然后我们执行如下命令删除缓存

`git rm --cached User.php`
然后我们在commit和push就好了