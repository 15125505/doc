## 1. 安装go

```
yum install -y go
```

## 2. 安装git

```
yum install -y git
```

## 3. 配置GOPATH

* 可以生成一个configPath.sh文件，来配置一下这些参数，文件中的内容可以如下书写。

```
export GOPATH=~/work                #此处设置将要使用的开发目录
export PATH=$PATH:$GOPATH/bin       #这样设置之后方便直接使用开发目录下bin中的命令
```
* 使用source指令可以执行该sh命令（如果直接执行，那么效果是在子shell中，在当前shell中是没有效果的）

```
source configPath.sh
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
