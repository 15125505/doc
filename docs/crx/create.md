# 创建chrome插件

## 一、创建插件需要的相关文件

### 1. 创建`manifest.json`

``` json
{
  "name": "Dy Extensions",
  "description": "Base Level Extension",
  "version": "1.0",
  "manifest_version": 2,
  "background": {
    "scripts": [
      "js/background.js"
    ]
  },
  "content_scripts": [
    {
      "matches": [
        "*://*/*"
      ],
      "js": [
        "js/content.js"
      ],
      "run_at": "document_start"
    }
  ],
  "permissions": [
    "cookies",
    "webRequest",
    "webRequestBlocking",
    "storage",
    "browsingData",
    "tabs",
    "*://*/*"
  ],
  "icons": {
    "16": "/images/get_started16.png",
    "32": "/images/get_started32.png",
    "48": "/images/get_started48.png",
    "128": "/images/get_started128.png"
  }
}
```

**重要说明**

* `manifest_version`必须为2，这个会在浏览器中报警告，未来会被弃用，到时候，我们不用最新版本浏览器即可。
* `background/scripts`中是`background`
  的js，如果有多个文件，那么按照被引用者在前的顺序进行添加。（这个js文件中不能用es6的import语法，所以多个文件的这种引入方式很有意义，以后可以考虑使用打包工具来完成这些工作）
* `permissions`中的内容说明：
    * `cookies`是用于操作用户cookie
    * `browsingData`可以用来清除用户缓存、历史记录、cookie等各种浏览数据
    * `webRequest`和`webRequestBlocking`用来控制网络访问
    * `tabs`用于控制标签页的打开关闭等
    * `*://*/*`确定访问权限

### 2. 添加必要的文件

* 在manifest文件目录下，创建`js/background.js`和`js/content.js`文件；
* 在manifest文件目录下，创建`images`文件夹，并加入对应的图标文件；

## 二、启动插件

打开浏览器，进入插件设置，打开开发者模式，然后选择`加载已解压的扩展程序`即可。

## 三、常见操作

### 1. 替换网站所使用的js文件

background.js中加入如下代码即可。

```js
chrome.webRequest.onBeforeRequest.addListener(
    details => ({redirectUrl: `http://127.0.0.1/t.js`}),
    {"urls": ["https://abc.com/mainJs/123.456.js"]},
    ["blocking", "requestBody"]
);
```

### 2. 去除网页头中，对脚本来源的限制

background.js中加入如下代码即可。

```js
chrome.webRequest.onHeadersReceived.addListener(details => {
        const ret = {};
        const found = details.responseHeaders.find(v => v.name === "content-security-policy");
        if (!found) {
            return;
        }
        found.value = found.value.replace(/\s*script-src 'self' [^;]*;?/, '');
        ret.responseHeaders = details.responseHeaders;
        return ret;
    },
    {
        "urls": ["https://live.douyin.com/*"]      // 我们只对需要的文件进行修改，语法格式请参考 https://developer.mozilla.org/zh-CN/docs/Mozilla/Add-ons/WebExtensions/Match_patterns
    },
    ["blocking", "responseHeaders"]
);
```

### 3.在网页js中向content发送消息

只能用window的消息传递。
发送方示例代码（这个代码应该放在刚刚被替换的用户脚本中）。

```js
window.postMessage({someMessage: '这儿可以是任意的内容'}, '*');
```

接收方示例代码，这个代码应该在content.js中。

```js
window.addEventListener("message", () => console.log(e.data), false);
```

### 4.content发送消息到background

发送方代码，content.js中。

```js
chrome.runtime.sendMessage({greeting: '你好，我是content-script呀，我主动发消息给后台！'}, response => console.log('收到来自后台的回复：' + response));
```

background中的接收代码：

```js
chrome.runtime.onMessage.addListener(function(request, sender, sendResponse)
{
    console.log('收到来自content-script的消息：', request, sender, sendResponse);
    sendResponse('我是后台，我已收到你的消息：' + JSON.stringify(request));
});
```

### 5.background发送消息到content

background发送消息之前得先找到这个tab。

```js
chrome.tabs.sendMessage(
    80, // 注意，需要先获得对应的tabId
    {cmd: 'test', value: '你好，我是background！'},
    response => console.log('来自content的回复：', response)
);
```

content接收代码：

```js
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
    console.log("收到了来自background的消息：", request, sender);
    sendResponse('我收到了你的消息！');
});
```

