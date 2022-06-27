# Clipping Lightning

## stage Configuration

```javascript
const options = {stage: {w: 1920, h: 1080, clearColor: 0xFF000000}} 
const app = new MyApp(options);
```

options主要有两个配置选项

- Application configuration options

  | Name    | Type    | Default | Description                                                  |
  | ------- | ------- | ------- | ------------------------------------------------------------ |
  | `debug` | Boolean | false   | Shows changes to the focus path for debug purposes           |
  | `keys`  | Object  | Object  | A custom [key map](https://rdkcentral.github.io/Lightning/docs/focus/keyhandler) |

- Stage configuration options

  |       Name        |       Type        |   Default    | Description                                                  |
  | :---------------: | :---------------: | :----------: | ------------------------------------------------------------ |
  |     `canvas`      | HTMLCanvasElement |     null     | 重新加载这个页面而不是新创建一个                             |
  |     `context`     |      Object       |     null     | 用来指定 webgl/canvas2d 上下文                               |
  |        `w`        |      Number       |     1920     | Stage width in pixels                                        |
  |        `h`        |      Number       |     1080     | Stage height in pixels                                       |
  |    `precision`    |       Float       |      1       | 相对于原本的w/h，缩放倍数                                    |
  | `memoryPressure`  |      Number       |     24e6     | 最大GPU内存使用量（以像素为单位）                            |
  |   `clearColor`    |      Float[]      |  [0,0,0,0]   | Background color. ARGB values (0 to 1)                       |
  | `defaultFontFace` |      String       | 'sans-serif' | 渲染文本时使用的默认字体                                     |
  |     `fixedDt`     |      Number       |   0 (auto)   | 每帧固定时长 (ms)                                            |
  | `useImageWorker`  |      Boolean      |     true     | Attempt to use a web worker that parsers images off-thread (web only) |
  |    `autostart`    |      Boolean      |     true     | 如果设置为false，则不会自动绑定到 requestAnimationFrame automatically |
  |    `canvas2d`     |      Boolean      |    false     | 如果设置，渲染引擎使用 canvas2d 而不是 webgl (has some limitations) |


## setup Lighting

please fllow this way  [Setup Lightning · Lightning (rdkcentral.github.io)](https://rdkcentral.github.io/Lightning/docs/gettingStarted/setup-lightning)

## Render Engine

- `Template` 程序初始化时调用的模板

  ```js
  class LiveDemo extends lng.Application {
      static _template() {
          return {
              Header: {
                  rect: true, w: 1920, h: 50, color: 0xff005500,
                  Title: {
                      x: 50, y: 30, mountY: 0.5, text: { text: 'Header' }
                  }
              },
          }
      };
  }
  ```

- `Positioning` 元素定位，直接在对象里面设置

  ![image-20211213160505214](E:\lcsprogram\study_doc\RDK\images\positioning.png)

- `Rendering` 渲染方式，直接在对象里面设置

  | Name                 | Type    | Default    | Description                                                  |
  | -------------------- | ------- | ---------- | ------------------------------------------------------------ |
  | `alpha`              | Float   | 1          | 透明度                                                       |
  | `visible`            | Boolean | true       | Enable / disable rendering                                   |
  | `color`              | Hex     | 0xFFFFFFFF | Color (ARGB)                                                 |
  | `colorTop`           | Hex     | 0xFFFFFFFF | Top color of a color gradient.                               |
  | `colorBottom`        | Hex     | 0xFFFFFFFF | Bottom color of a color gradient.                            |
  | `colorLeft`          | Hex     | 0xFFFFFFFF | Left color of a color gradient. (overwrites: `colorUl`, `colorBl`) |
  | `colorRight`         | Hex     | 0xFFFFFFFF | Right color of a color gradient. (overwrites: `colorUr`, `colorBr`) |
  | `colorUl`            | Hex     | 0xFFFFFFFF | Top-left color of a color gradient.                          |
  | `colorUr`            | Hex     | 0xFFFFFFFF | Top-right color of a color gradient.                         |
  | `colorBl`            | Hex     | 0xFFFFFFFF | Bottom-left color of a color gradient.                       |
  | `colorBr`            | Hex     | 0xFFFFFFFF | Bottom-right color of a color gradient.                      |
  | `clipping`           | Boolean | false      | 裁剪                                                         |
  | `zIndex`             | Integer | 0          | z-Index 设置渲染优先级                                       |
  | `forceZIndexContext` | Boolean | false      | Enables a z-index context                                    |
  | `shader`             | Object  | {}         | Sets a non-default 着色器                                    |

  ![image-20211213160941103](E:\lcsprogram\study_doc\RDK\images\rendering.png)

- `Transforms` 变换，在action里面添加

  | Name       | Type  | Default | Description                                               |
  | ---------- | ----- | ------- | --------------------------------------------------------- |
  | `scale`    | Float | 1       | 缩放. (1 = 1:1)                                           |
  | `scaleX`   | Float | 1       | Scale width. (1 = 1:1)                                    |
  | `scaleY`   | Float | 1       | Scale height. (1 = 1:1)                                   |
  | `rotation` | Float | 0       | 圆弧旋转                                                  |
  | `pivot`    | Float | 0.5     | 旋转中心点: 0 = top-left, 0.5 = center, 1 = bottom-right. |
  | `pivotX`   | Float | 0.5     | Pivot position (horizontal axis)                          |
  | `pivotY`   | Float | 0.5     | Pivot position (vertical axis)                            |

  ![image-20211213161401197](E:\lcsprogram\study_doc\RDK\images\transforms.png)

- `Children` 每一个节点都有一个子节点

- `Tags` tags 用来引用template里面的对象

  ```js
  static _template(){
      return {
          MyObject:{ x: 0, y: 0, w: 50, h: 50, rect: true }
      }
  }
  
  const myObject = this.tag('MyObject');
  ```

- `Patch` 为对象补充渲染的设置

  ```js
  this.patch({
      Parent: {
          x: 150, alpha: 0.5,
          Child: {
              x: 100, y: 100
          }
      }
  });
  
  //or this way
  this.tag("Parent").patch(
      x: 150, alpha: 0.5,
      Child: {
          x: 100, y: 100
      }
  });
  ```

## 函数

|       Name       | Event                                              |
| :--------------: | -------------------------------------------------- |
|  `_construct()`  | 在生成 `template` 之前创建实例                     |
|    `_build()`    | 创建实例，生成 `template`                          |
|    `_setup()`    | 附加到渲染树，自顶向下（第一次）                   |
|    `_init()`     | 附加，第一次                                       |
|   `_attach()`    | 附加到渲染树，自下而上                             |
|   `_detach()`    | Detached, bottom-up[自下而上]                      |
| `_firstEnable()` | Enabled (for the first time)                       |
|   `_enable()`    | Enabled (全部添加而且 visible: true and alpha > 0) |
|   `_disable()`   | Disabled (分离或隐形或两者兼而有之)                |
| `_firstActive()` | Activated (for the first time)                     |
|   `_active()`    | Activated (在屏幕上启用)                           |
|  `_inactive()`   | Inactive (分离的、不可见的或屏幕外的)              |



## Communication

### Signal

signal方法通知组件的父组件发生了事件。（通俗的讲，就是子组件调用父组件的方法）

`this.signal('signalName',arg1,...)`

父组件通过 `signals` 标签定义方法

```js
// 父组件 
class SignalDemo extends lng.Application {
    static _template() {
        return {
            x: 20, y: 20,
            Button: {
                type: ExampleButton,
                buttonText: 'Toggle',
                //indicates the signals that your child component will send
                signals: {
                    toggleText: true,
                }
            },
            Message: {
                y: 80, alpha: 0, text: { text: 'Message' }
            }
        }
    }
    toggleText(alpha, color) {
        this.tag('Message').patch({color, smooth: { alpha }})
    }
    _getFocused() {
        return this.tag('Button')
    }
}


// 子组件
class ExampleButton extends lng.component {
    static _template() {
        return {
            color: 0xffffffff,
            texture: lng.Tools.getRoundRect(200, 40, 4),
            Label: {
                x: 100, y: 22, mount: .5, color: 0xff1f1f1f, text: { fontSize: 20 }
            }
        }
    }
    _init() {
        this.tag('Label').patch({ text: { text: this.buttonText }})
        this.toggle = false
        this.buttonColor = 0xffff00ff
    }
    _handleEnter() {
        this.toggle = !this.toggle
        if(this.toggle) {
            this.buttonColor = this.buttonColor === 0xffff00ff ? 0xff00ffff : 0xffff00ff
        }
        this.signal('toggleText', this.toggle, this.buttonColor)
    }
}
```



### FireAncestors

方法向远处的父组件发送信号，而不会将其传播到所有父组件，父节点的函数必须带有符号 `$`

`this.fireAncestors('$signalName', arg1, arg2... argx)`

```js
class FireAncestorDemo extends lng.Application {
    static _template() {
        return {
            x: 20, y: 20,
            ButtonList: {
                type: ExampleButtonList,
            },
            Message: {
                y: 80,
                text: { text: 'Left / right to select a button\nEnter to press it' }
            }
        }
    }
    $changeMessage(buttonNumber, color) {
        this.tag('Message').patch({
            text: { text: 'Button ' + buttonNumber + ' pressed!' },
            smooth: { color }
            
        })
    }
    _getFocused() {
        return this.tag('ButtonList')
    }
}

class ExampleButtonList extends lng.component {
    static _template() {
        return {
            Button1: {
                type: ExampleButton,
                buttonColor: 0xffff00ff,
                buttonText: 'Button 1',
                buttonNumber: '1'
            },
            Button2: {
                x: 250,
                type: ExampleButton,
                buttonColor: 0xff00ffff,
                buttonText: 'Button 2',
                buttonNumber: '2'
            }
        }
    }
    _init() {
        this.index = 0
    }
    _handleLeft() {
        this.index = 0
    }
    _handleRight() {
        this.index = 1
    }
    _getFocused() {
        return this.children[this.index]
    }
}


class ExampleButton extends lng.component {
    static _template() {
        return {
            color: 0xff1f1f1f,
            texture: lng.Tools.getRoundRect(200, 40, 4),
            Label: {
                x: 100, y: 22, mount: .5, color: 0xffffffff, text: { fontSize: 20 }
            }
        }
    }
    _init() {
        this.tag('Label').patch({ text: { text: this.buttonText }})
    }
    _focus() {
        this.color = 0xffffffff
        this.tag('Label').color = 0xff1f1f1f
    }
    _unfocus() {
        this.color = 0xff1f1f1f
        this.tag('Label').color = 0xffffffff
    }
    _handleEnter() {
        this.fireAncestors('$changeMessage', this.buttonNumber, this.buttonColor)
    }
}
```



# Lightning SDK 

## 插件（Plugins）

调用方式（all）

```js
import { xxxx } from '@lighntingjs/sdk'
```

### Utils

1. asset

   根据setting.json中`PlatformSettings`配置的path下寻找images等【*值得注意的是，并不是相对路径，而是在指定的配置中寻找*】

   `Utils.asset('images/logo.png')`

2. proxyUrl

   `Utils.proxyUrl(url,options)`

   仅用于没有跨域资源公共享的环境

### Storage

以独立平台的方式存储数据

1. set `Storage.set(key,value)`
2. get `Storage.get(key)`
3. remove `Storage.remove(key)`
4. clear `Storage.clear()` 清空所有

### Settings

1. get `Settings.get(type,key,[fallback])`
   1. `Type` can be either `app`, `platform` or `user`.
   2. `Key` can be any of the existing settings.
   3. `fallback` 假如并没有相关的key，可以指定对应的返回值
2. set `Settigns.set(key,value)`
3. has `Setting.has(type,key)`, return true or false
4. subscribe `Settings.subscribe(key,callback)`，当`user`下面的键值发生变化时，触发回调函数，可以对同一个键值设置多个回调
5. unsubscribe `Settings.unsubscribe(key,[callback])` 与上面的方法相反，删除绑定的回调函数
6. clearSubscribers `Settings.clearSbuscribers()` ，清除所有的监听

### Log

设置对应的日志并打印 `.info  .debug  .error  .warn`

### Metadat

name, version, icon 可以在metadata.json中找到

1. Get `Metadata.get(key,[fallback])` 获取指定的值，若没有，则返回fallback
2. AppId `Metadata.appId()` 获取appid
3. SafeAppId `Metadata.safeAppId()` 返回一个安全的appid
4. `appVersion  appIcon  appFullVersion`

### Metrics

收集用户行为发送到后端

1. `Metrics.App.loaded()` `Metrics.App.ready()` `Metrics.App.close()`
2. `Metrics.App.error(message, code, params)` 发送错误码
3. `Metrics.App.event(name, params)` 发送与应用事件相关的自定义指标
4. `Metrics.page.view(name, params)   Metrics.page.leave(name, params)   Metrics.page.error(message, code, params)   Metrics.page.event(name, params)  `
5. ​    `Metrics.user.click(name, params)    Metrics.user.input(name, params)  Metrics.user.error(message, code, params)   Metrics.user.event(name, params) `
6. Media

### Profile

配置文件插件

对应下面的profile.json

```json
{
  "platformSettings": {
      "profile": {
         "ageRating": "adult",
         "city": "New York",
         "zipCode": "27505",
         "countryCode": "US",
         "ip": "127.0.0.1",
         "household": "b2244e9d4c04826ccd5a7b2c2a50e7d4",
         "language": "en",
         "latlon": [40.7128, 74.006],
         "locale": "en-US",
         "mac": "00:00:00:00:00:00",
         "operator": "metrological",
         "platform": "metrological",
         "packages": [],
         "uid": "ee6723b8-7ab3-462c-8d93-dbf61227998e",
         "stbType": "metrological"
      }
   }
}
```

## Router

在 `src/routes.js`中配置

1. 配置

   - `root` 根目录

   ```js
   import { Splash } from './pages';
   
   export default {
     root: 'splash',
     routes: [
       {
         path: 'splash',
         component: Splash
       },
     ]
   }
   
   //或者指定函数
   
   export default {
     root: () => {
       return new Promise((resolve) => {
           if(authenticated) {
               resolve('browse')
           }else{
               resolve('login')
           }
       })
     }
   }
   
   ```

   -  `boot` 

   ```js
   export default {
       boot: () => {
           return new Promise(resolve => {
               Api.getToken().then(() => {
                   resolve()
               })
           })
       },
       routes: [...]
   }
   ```

   - `routes`

   ```js
   // file: src/routes.js
   import { Home, Browse } from './pages';
   
   export default {
     routes: [
       {
         path: 'home',
         component: Home
       },
       {
         path: 'home/browse/adventure',
         component: Browse
       }
     ]
   }
   ```

   - 动态路径

     通过添加 `:` 实现

     ```js
     {
       path: 'player/:assetId/:playlistId',
       component: Player
     }
     ```

     例如现在通过特定的路线提供数据 (i.e., and ).`localhost:8080#player/27/286``assetId``playlistId`

   - 解析动态路径

   ```js
   class Player extends Lightning.Component {
       static _template(){
           return {...}
       }
       set params(args){
           // args.assetId === 27 && args.playlistId === 286
       }
   }
   ```

2. 导航

   - `Router.navigate(path,params,store)`
     - `path`：跳转的路劲
     - `param`：附带的参数，obj
     - `store`：是否保留历史记录，bool
   - 可以使用别名来跳转，需要在 `router` 配置中使用 `name` 参数
   - `Router.isNavigating()`，检查是否有页面正在跳转

3. 回调函数（提供数据）

   - `on`

     显示新页面替换加载页面

     ```js
     {
         path: 'player/:playlistId/:assetId',
         // page instance and dynamic url data
         // will be available in the callback
         on: (page, {playlistId, assetId}) => {
             return new Promise((resolve, reject)=>{
                 // do a request
                 doRequest.then((lists)=>{
                     // set property on the page
                     page.lists = list
                     resolve()
                 }).catch((e)=>{
                     reject(e)
                 })
             })
         },
         // time in seconds
         cache: 60 * 10 // 10 minutes
     }
     ```

   - `before`


### navigate

传递数据的时候，需要采用 `set persist(args)` 接收

### KeyMapping

可以通过修改`setting.json`改变

```json
{
  "appSettings": {
    "stage": {
      "clearColor": "0xff000000",
      "useImageWorker": true,
      "precision": 1
    },
    "debug": false,
    "keys" :{
      "8":"Back"
    }
  }
}
```

## Animation

```js
const myAnimation = this.tag('MyAnimationObject').animation({
    duration: 1,                //duration of 1 second
    repeat: 0,                  //Plays only once
    stopMethod: 'immediate',    //Stops the animation immediately
    actions: [
        {p: 'alpha', v: {0: 0, 1: 1}},
        {p: 'y', v: {0: 0, 0.25: 50, 0.75: -50, 1: 0}}
    ]
});
```

### Methods

| Name                     | Description                                                  |
| :----------------------- | :----------------------------------------------------------- |
| `start()`                | 启动                                                         |
| `play()`                 | 如果暂停则继续                                               |
| `pause()`                | 暂停                                                         |
| `replay()`               | 重新播放                                                     |
| `skipDelay()`            | 如果在等待，则跳过等待时间                                   |
| `finish()`               | 快进到停止                                                   |
| `stop()`                 | 停止动画                                                     |
| `stopNow()`              | 立即停止                                                     |
| `isPaused() : Boolean`   | Return ‘true’ if the current state is ‘paused’               |
| `isPlaying() : Boolean`  | Return ‘true’ if the current state is ‘playing’              |
| `isStopping() : Boolean` | Return ‘true’ if the current state is ‘stopping’             |
| `isActive() : Boolean`   | Return ‘true’ if currently progressing (playing or stopping) |
| `progress(dt : Float)`   | 推进 `dt` 秒                                                 |

## VideoPlayer

**注意**：在使用Video Player的时候一定要保证setting.json中的背景颜色是透明的，不然视频会被背景颜色遮住

相当于使用视频填充背景

1. consumer
   1. `VideoPlayer.consumer(this)`
2. position 设置定位（x，y）
   1. `VideoPlayer.position(100, 200)`
3. size （w，h）
4. area 屏幕边缘到视频播放器的编剧
   1. `VideoPlayer.area(top, right, bottom, left)`
5. open
   1. `VideoPlayer.open(videoUrl)`
6. loader 修改调用顺序
7. unloader
8. reload
9. close
10. clear
11. pause
12. play
13. playPause
14. mute
15. loop
16. seek
17. skip
18. show
19. hide
20. duration
21. currentTime
22. muted
23. looped
24. src
25. playing
26. 

## 工具框

| Texture       | Function                                                     |
| :------------ | :----------------------------------------------------------- |
| 圆角矩形      | `Lightning.Tools.getRoundRect(w, h, radius, strokeWidth, strokeColor, fill, fillColor)` |
| 投影矩形      | `Lightning.Tools.getShadowRect(w, h, radius = 0, blur = 5, margin = blur * 2)` |
| SVG rendering | `Lightning.Tools.createSvg(cb, stage, url, w, h)`            |