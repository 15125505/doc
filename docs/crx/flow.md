# 流程图

> crx
> 
> 自动连接服务器，并按照服务器的指示进行操作。
> 
>> 根据roomId获取msg并告知服务器。
> 
>> 使用user身份进入room并按照服务器需求发言。
> 
> 
> 
 

> client
> 
> 自动连接服务器，并获取服务器数据。

> control
> 
> 要求用户使用user身份在room发言。

> server
> 
> 调度crx和client

tr

```mermaid
graph LR

D[定时检查]-->A(空闲)-->E[尝试获取任务]-->B(正在获取任务)
B--获取成功-->C(正在执行任务)
B--获取失败-->A
D-->C1("正在执行任务")-->获取成功


```


```mermaid
stateDiagram-v2


    
    [*] --> A
    A: 空闲
    A --> B: 检查定时器
    B: 正在获取任务

    B --> Working: 获取成功
    B --> A: 获取失败
    Working --> A: 任务结束

    Working: 正在执行任务
    state Working {
        [*] --> W1
        W1: 打开tab
        W1 --> [*]: 失败
        W1 --> W2: 成功
        W2: 侦听数据
        W2 --> [*] : 内容结束
        W2 --> W3 : 发现msg
        W3 --> W2
        W3: 发送到服务器
    }



    note left of B
        获取需要当前需要侦听的roomId
    end note


```


```mermaid
stateDiagram

A: 空闲
[*] --> A
B: 正在连接服务器
A --> B: 自动进入
B --> A: 连接失败
C: 连接成功
B --> C: 连接成功
D: 获取任务
C --> D: 当前没有任务
E: 当前正在任务工作中
C--> E: 当前有任务
F: 开始侦听任务消息
E --> F
F --> Working
D --> F: 获取任务成功
D --> D: 获取任务失败
D --> A: 连接断开

Working: 任务工作流程
state Working {
    [*] --> start
}

```


background

```mermaid
graph
A(开始) --> B(启动消息侦听) --> C(启动socket连接)

```


socket

```mermaid
stateDiagram

A: 正在连接

[*] --> A
A --> A : 连接失败
B: 收发数据
A --> B: 连接成功
B --> A: 连接中断
C: 服务器数据处理
B --> C: 收到服务器数据
C --> B: 数据处理完毕
D: 发送数据到服务器
B --> D: 有数据需要发送
D --> B: 数据发送完毕

```


tab管理

```mermaid
stateDiagram


A: 消息处理
[*] --> A
B: 打开tab
A --> B : socket通知有新任务
B --> A
C: 处理来自tab的消息
A --> C: 收到来自tab的消息
C --> A


```


时序图
```mermaid
sequenceDiagram

    participant crx as 插件
    participant game as 游戏
    participant server as 服务器

    crx->>server: 我是插件，我空闲
    crx->>server: 我是插件，我在房间2048
    game->>server: 我是游戏，我在房间2048
    server-->>crx: 给我房间2048的聊天信息
    loop 不停侦听房间消息
        crx->>server: 这是2048的聊天内容
        server-->>game: 这是房间2048的聊天信息
    end


```


