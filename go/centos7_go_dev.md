# Centos7下面go(beego)开发环境搭建

## 1. 安装go

```
yum install -y go
```

## 2. 安装git

```
yum install -y git
```

## 3. 配置GOPATH

* GOPATH环境变量设置有两种方法

    * 方法一: 在/etc/profile文件中添加变量【对所有用户生效（永久的）】
    * 方法二: 在用户目录下的.bash_profile文件中增加变量【对单一用户生效（永久的）】

* 添加的内容可以如下书写：

```
export GOPATH=~/work                #此处设置将要使用的开发目录
export PATH=$PATH:$GOPATH/bin       #这样设置之后方便直接使用开发目录下bin中的命令
```

* 使用source指令可以执行该sh命令（如果直接执行，那么效果是在子shell中，在当前shell中是没有效果的）

```
source .bash_profile
```

* 当然，你也可以直接手动执行上面的两条指令，而不使用一个shell脚本。

## 4. 下载beego

```
go get github.com/astaxie/beego
go get github.com/beego/bee
```

## 5. 建立一个工程，测试一下beego

```
$ cd $GOPATH/src
$ bee new hello
$ cd hello
$ bee run hello
```

* 在浏览器中打开[http://localhost:8080](http://localhost:8080)进行访问。

## 6. 实际使用

1. 首先，你将自己的工程代码通过git复制到GOPATH的src目录下。
2. 进入你的个人工程目录，然后使用bee run指令运行项目。(nohup的目的是为了让这个指令后台运行，而且不随着shell的关闭而关闭)
```
nohup bee run > run.log 2>&1 &
```
3. 如果想减少输入的麻烦，也可以将这个指令，保存为一个sh指令，然后使用source执行。
4. 屏幕输出日志可以通过```tailf run.log```进行查看。
5. 以后每次使用git更新源码，go会自动进行重新编译，如果编译成功，会重新启动编译之后的新程序。如果编译失败，则会保留之前的进程。


## 7. 一些小技巧

* 查看进程是否执行中(如果只看到一行，那么说明进程没启动)
```
ps -ef|grep myexe
```

* 杀掉指定名称的所有进程
```
killall myexe
```

* 查询指定端口对应的执行文件，比如要查看80端口的占用情况，可以用如下指令
```
lsof -i tcp:80
```