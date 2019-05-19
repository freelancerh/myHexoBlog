---
title: SSH基本用法
date: 2015-08-19 22:07:30
categories: Linux
tags: [SSH, Linux]
photos: 
- /uploads/image/cover/lb19.jpg
---

### 序言
说到SSH，我想一般的人首先想到的就是java web的SSH三大框架吧。我刚开始也是如此，在玩github时也用过SSH，但是不知其所以然，在学习了Linux后，我认识到了SSH还有另种含义--[Secure Shell](http://baike.baidu.com/link?url=EThriZvfnEk2o_seoXpmG2Hwi63rhmo6aIWvUJ1mvJWnVS62Vf5qTom1nkaiBUVdz3GdoadVafh_3I9S3PWCo5aWahseHzL1hCKD4UvQOtW)。通过SSH我们可以远程登录到Linux服务器，因为在传输过程中进行了加密处理，其安全性比Telnet和Pop要高。
本文默认你在本地机器上安装了SSH client，在远程机器上安装了SSH server。行首local$提示符代表client端，remote$代表server端。

### 简单用法
      ssh user@remote -p port
* user 是你在远程机器上的用户名，如果不指定的话默认为当前用户
* remote 是远程机器的地址，可以是 IP，域名，或者是后面会提到的别名
* port 是 SSH Server 监听的端口，如果不指定的话就为默认值 22

执行完这条指令后，ssh会要求你输入密码，输入密码后即会登录到远程服务器

### 使用 SSH 钥匙登录
如果我们经常需要登录到远程服务器，然而每次都要输入密码，这样会比较烦。在这里我们可以配置SSH钥匙来实现免密码登录。

        ssh-keygen
在客户端执行这条命令可生成SSH钥匙，一路按回车。在`~/.ssh/id_rsa.pub`文件里存放了公匙，在`~/.ssh/id_rsa`文件里存放了密匙。现在我们可以把公匙文件里的代码追加到远程服务器里的`.ssh/authorized_keys`文件里。完成后ssh登录远程服务器就不需要密码了。
生成密匙后，我们也可以用`ssh-copy-id user@remote -p port`命令来放置公匙到远程服务器中，原理和上面是一个意思。
**PS：**想想我们用git时不也经常是用SSH钥匙来登录github的吗。

### 配置别名
虽然我们配置了密匙不要输入密码了，但是我还是要输入`ssh user@remote -p port`命令的啊，毕竟服务器多了不容易记啊。幸好我们可以配置别名，在`~/.ssh/config`文件里追加一下内容

    Host centos
        HostName remote
        User user
        Port port
保存之后，我们就可以直接使用`ssh centos`来登录。如果没有config文件的话，我们可以新建一个。

### SCP命令

不同的Linux之间copy文件常用有3种方法：

* ftp，也就是其中一台Linux安装ftp Server，这样可以另外一台使用ftp的client程序来进行文件的copy。
* 采用samba服务，类似Windows文件copy 的方式来操作，比较简洁方便。
* 利用scp命令来进行文件复制。

scp是有Security的文件copy，基于ssh登录。操作起来比较方便，比如要把当前一个文件copy到远程另外一台主机上，可以如下命令：

	scp /home/daisy/full.tar.gz   user@remote:/home/root

然后会提示你输入另外那台远程主机的user的登录密码，接着就开始copy了。
如果想反过来操作，把文件从远程主机copy到当前系统，也很简单：
  
    scp user@remote:/home/root/full.tar.gz  home/daisy/full.tar.gz

如果是复制的文件夹的话添加一个-r选项。
几个用的参数 :
 -v 和大多数 linux 命令中的 -v 意思一样 , 用来显示进度 . 可以用来查看连接 , 认证 , 或是配置错误 .
 -C 使能压缩选项 . 
-P 选择端口 . 注意 -p 已经被 rcp 使用 . 
-4 强行使用 IPV4 地址 .
 -6 强行使用 IPV6 地址 .

### 使程序在后台运行
如果我们退出了SSH程序，Linux会马上kill掉我们的程序。如果我们有长时间运行的程序，而我们的SSH程序又要关掉怎么办呢，如何保持我们的程序一直进行下去呢。tmux解决了我们这个问题，tmux是一个会话管理程序，他会保持程序一直运行着。安装完tmux后执行

    remote$ tmux
这样我们就进入到了 tmux管理的会话中，之后你再运行任何东西都不会因为你退出 ssh而被杀死。要暂时离开这个会话，可以先按下 ctrl+b再按下 d。要恢复之前的会话，只需要执行

    remote$ tmux attach

tmux还能管理多个窗口、水平竖直切分、复制粘贴等等，我们可以看看[tmux速成教程](http://blog.jobbole.com/87584/)来入门。

### putty
在windows系统上，我们可以用[putty](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html)作为SSH client。putty配套的工具都很有用。

---
### 参考资料
[SSH 基本用法](https://abcdabcd987.com/ssh/)
[scp命令](http://www.cnblogs.com/hitwtx/archive/2011/11/16/2251254.html)
[SSH 的详细使用方法](http://blog.csdn.net/zi_jin/article/details/3722239)




