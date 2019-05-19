layout: photo
title: hexo炫酷建站&防坑指南
date: 2015-04-25 12:22:38
categories: hexo
tags: [hexo,建站]
photos: /uploads/wz1.jpg
---
捣鼓了几天博客，先是使用jekyll，感觉有些麻烦，不够酷，无意中发现有个hexo这个东西，便投入了进来，第一次使用坑还是比较多的，现在简要谈谈建博历程及防坑指南。
***
## github
    - 建立与用户名对应的仓库，仓库名必须为：yourname.github.com

## 环境准备
    - 到Node.js官网下载最新版本，安装过程中一直点击确定即可
    - 安装git客户端 ps:安装git客户端后，自动添加了ssh-key,所以你不需要手动添加咯 

## Hexo安装及部署
    - 安装hexo  `npm install -g hexo`
    - 创建项目  `hexo init + 项目文件夹`
    - 进入目录 `cd + 项目文件夹`
    - 安装依赖包 `npm install `  ps:解决 hexo server , hexo generate 命令错误问题，解决出现cannot get/问题
    - 启动服务 `hexo server`

## 防坑指南
    - 创建分类页面时，使用命令 hexo new page "categories" 后，还要在自动生成的文件里，添加type: categorie，。创建标签页面类似
    - ERROR Deployer not found: git  **解决方法：**`npm install hexo-deployer-git --save`
    - ERROR: spawn git ENOENT  **解决方法：**`利用 git shell 来输入命令`
    - Error: fatal: Not a git repository (or any of the parent directories): .git   **解决方法：** `git init`
    -  nothing added to commit but untracked files present  error: src refspec master does not match any.  **解决方法：**   `解决：删了 .deploy文件重试` ps：费好大劲才找到这个问题的答案
    - 绑定域名时，CNAME文件放在source文件夹里
    - GitHub “Failed connect to github” No Error **解决方法：** `将站点配置文件的deploy下的repository改为：git@github.com:yourname/yourrepository.git`

    <iframe frameborder="no" border="0" marginwidth="0" marginheight="0" width=330 height=86 src="http://music.163.com/outchain/player?type=2&id=379785&auto=1&height=66"></iframe>