
* git修改提交的用户名和Email - Fybon的专栏 - CSDN博客 
http://m.blog.csdn.net/Fybon/article/details/51210438

有时候在执行repo upload上传代码的时候会出现
To ssh://username@code.address.com:29442/kernel/msm
 ! [remote rejected] ltr558 -> refs/for/JB8X25_FC/IHV-LITEON-LTR-558ALS (you are not committer username@email.com)
error: failed to push some refs to 'ssh://username@code.address.com:29442/kernel/msm'

----------------------------------------------------------------------
[FAILED] kernel/         ltr558          (Upload failed)

这是因为之前git commit已提交的Email和现在正要提交的Email冲突，把它改成一致就OK了。
git commit已提交的Author信息可以通过git log查看
$git log
commit 6554439743d91d424e006734cfe7fca758b21b81
Author: username 
Date:   Wed Sep 19 16:14:20 2012 +0800

    add driver of ltr558 to jb-8x25-fc
    
    Change-Id: Ic81c54f91874be3b4366a2af9729a0251f44f40c


git config --global user.name "Your Name"
git config --global user.email you@example.com
全局的通过vim ~/.gitconfig来查看

git config user.name "Your Name"
git config user.email you@example.com
局部的通过当前路径下的 .git/config文件来查看

也可以修改提交的用户名和Email：
git commit --amend --author='Your Name '


［转载］git config的运用
本文中所演示的git操作都是在v1.7.5.4版本下进行的，不同的版本会有差异，更老的版本有些选项未必支持。

当我们安装好git软件包，或者着手在一个新的机子上使用git的时候，我们首先需要进行一些基本的配置工作，这个就要用到git config。

git config是用于进行一些配置设置，有三种不同的方式来指定这些配置适用的范围：
1) git config 
            针对一个git仓库
2) git config --global    针对一个用户
3) sudo git config --system    针对一个系统，因为是针对整个系统的，所以必须使用sudo


1) 第一种默认当前目录是一个git仓库，假设我们有一个仓库叫git_test，它所修改配置保存在git_test/.git/config文件，如果当前目录不是一个有效的git仓库，在执行‪一些命令时会报错，例如：
$git config -e
fatal: not in a git directory

我们来看一个简单的例子，一般我们clone一个git仓库，默认都是一个工作目录，那么对应的配置变量 bare = false。来看一个很简单的仓库的config文件，cat git_test/.git/config

[core]
        repositoryformatversion = 0
        filemode = true
        bare = false
        logallrefupdates = true

如果我们想修改bare为false，最简单的办法就是直接用vim打开git_test/.git/config文件进行修改，另一种办法就是使用git config来修改

$git config core.bare true
$cat .git/config
[core]
        repositoryformatversion = 0
        filemode = true
        bare = true
        logallrefupdates = true

命令的格式就是 git config. 。需要注意的是我们没有加--system和--global，那么这个修改只针对于当前git仓库，其它目录的仓库不受影响。

2) 第2种是适用于当前用户，也就是说只要是这个用户操作任何git仓库，那么这个配置都会生效，这种配置保存在~/.gitconfig当中，那什么样的配置需要放到用户的配置文件里呢，git里一个最为重要的信息就是提交者的个人信息，包括提交者的名字，还有邮箱。当我们在用git提交代码前，这个是必须要设置的。显而易见，这个配置需要放在用户一级的配置文件里。
$git config --global user.name "I Love You"
$git config --global user.email "i.love.you@gmail.com"
$cat ~/.gitconfig
[user]
        name = I Love You
        email = i.love.you@gmail.com

3) 第3种是适用于一个系统中所有的用户，也就是说这里的配置对所有用户都生效，那什么样的配置需要放在这里呢，比如我们在执行git commit会弹出一个默认的编辑器，一般是vim，那作为系统的管理员，可以将vim设置为所有用户默认使用的编辑器，我们来看设置的过程
$sudo git config --system core.editor vim
$cat /etc/gitconfig
[core]                                                                                                                                                                       
        editor = vim

我们可以看到它修改的是全局的配置文件/etc/gitconfig。

总结：

现在我们就会有一个问题，当我们在不同的配置文件中，对同一个变量进行了设置，最终哪个会生效呢？或者说谁到底覆盖谁呢？先来排除一种情况，就是分属不同的两个git仓库的config文件中的配置是互不影响的， 这个很好理解。那么要讨论是如果一个配置出即出现在/etc/gitconfig，~/.gitconfig以及git_test/.git /config这三个位置时，我们又恰巧要操作git仓库git_test，那么生效的优先级顺序是(1)git_test/.git/config，(2)~/.gitconfig，(3)/etc/gitconfig，也就是说如果同一个配置同时出现在三个文件中时，(1)有效。


那么为什么会有这样的情况发生呢，比如我们前面的有关编辑器设置，系统管理员为所有用户设置了默认的编辑器是vim，但是并不是每个用户都习惯用vim， 有些人更青睐于功能更炫的emacs(I hate it，我刚刚接触linux的时候上来就是用的emacs，让我这个新手不知所措，但是后来使了vim，觉得更容易上手，而且用的时间长了，对vim了解 更深，发现它功能一样强大，而且它可以算是类unix系统中默认的编辑器)，言归正传，如果你想用emacs，你就可以将这个配置加入到你 的~/.gitconfig中，这样它就会覆盖系统/etc/gitconfig的配置，当然这只针对于你，其他用户如果不设置还是会用vim。

$git config --global core.editor emacs
$cat ~/.gitconfig
[core]
        editor = emacs


对于git config只介绍到这，其实除了以上讲解的部分，它还有很多功能。本文中主要是针对介绍不同范围内设置的配置的有效范围，了解它之后，当以后需要对 git进行环境配置时，你就明白根据当前配置的性质，明白是该放在git_test/.git/config，还是在~/.gitconfig，又或是在 /etc/gitconfig中，作为一个资深的版本管理者来说，必须要了解以上的区别。

                                                                                                                                         tenyears2022
                                                                                                                                           2012-01-16