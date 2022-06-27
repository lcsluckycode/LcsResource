



# RDK components

1. IARM-Bus

2. WiFi

3. Bluetooth

4. bluetooth-MGR

5. audiocapturemgr

6. Crashupload

7. DCA

8. DTCP

9. HDMI CEC

10. IARM Manager

11. libusbctrl

12. Media Player

13. Network Service Manager

14. rdkbrowser

15. rdkbrowser2

16. RDK Diagnostics

17. RMF_Tools

18. sys_mon_tools

19. TR-069 Hostif

20. TRM

21. XFINITY-Universal Plug and Play (XUPnP)

22. Device Settings

23. RDK Logger

24. Westeros
25. Component: RDKShell

# 修改和构建组件（components）

列出yocto组件

```shell
bitbake-layers show-recipes
bitbake -s
```

## 应用补丁和构建组件

1. 在需要修改的配方文件中添加补丁

   ```shell
   SRC_URI += "file://<name>.patch"                              
   #eg:  SRC_URI += "file://temp.patch" in  meta-rdk-video/recipes-extended/devicesettings/devicesettings_git.bb
   ```

2. 在同一个配方文件的文件夹中创建 `files`文件夹

   ```shell
   #eg: In meta-rdk-video/recipes-extended/devicesettings/
   ```

3. 创建一个与配方中给出的名称相同的空白文件

   ```shell
   touch files/<name>.patch 
   #eg: touch files/temp.patch 
   ```

4. `bitbake <recipe> -c devshell`

   ```shell
   # eg: bitbake devicesettings -c devshell 
   ```

5. 执行 `quilt top` 并校验补丁文件是否存在

   ```shell
   eg:
   	# quilt top
   	patches/temp.patch
   ```

6. `quilt` 添加所有需要修改的文件名

   ```shell
    eg: quilt add Makefile.am configure.ac
   ```

7. 修改这些的文件

8. `quilt refresh`

9. 验证修改是否在对应的补丁文件中

10. 用补丁文件替换原来文件夹中的补丁文件

    ```shell
    eg: cp patches/temp.patch ~/.../meta-rdk-video/recipes-extended/devicesettings/files/temp.patch
    ```

11. 退出

12. 清理并重新构建

    ```shell
    bitbake -cleanall devicesettings 
    bitbake devicesettings 
    ```

# Thunder Plugins

目录结构

![img](E:\lcsprogram\study_doc\RDK\images\thunderplugins.png)

**plugin配置文件存放位置：**`/etc/WPEFramework`

**lib文件存放位置：**`/usr/lib`(core libraries)  `/usr/lib/wpeframework`(shared libs)

## example（build the sample service）

RDKServices github repo will get checked out under /tmp/work folder and changes can be made there. 

tmp/work/mips32el-rdk-linux/rdkservices/3.0+gitAUTOINC+fa49ddedd1-r1/git

1. 创建一个service的目录结构（根据一个service改编并保持一致的扩展）

2. 重构每一个插件的方法

   1. getQuirks，描述任何低级错误或可能已经在特定的API版本中修复的更改机制
   2. API方法
   3. API事件
   4. 不要重构任何不属于API的方法（getQuirks例外），Javascript 相关方法旨在通过 QtWebkit 与 Javascript 客户端一起使用，不需要包含在 Thunder 服务中。getJavaScriptObject 和 <servicename>JavaScriptObject 就是这些示例。

3. Legacy服务使用 Qt 库，thunder 插件不应使用它。因此可以使用 std::vector 或 std::list 代替 QList，使用 std::thread 代替 QThread，使用 WPEFramework::Core::TimerType 代替 QTimer。

4. build the new plugin

   `bitbake rdkservices`

   `bitbake thunder-plugins`

5. Copy files on stb: etc/WPEFramework/plugins/SimpleService.json and usr/lib/wpeframework/plugins/[libWPEFrameworkSimpleService.so](http://libwpeframeworksimpleservice.so/)

6. 重启thunder和测试新的插件

   1. `systemctl restart wpeframework`
   2. `curl -d '{"jsonrpc":"2.0","id":"3","method": "SimpleService.1.getQuirks"}' http://127.0.0.1:9998/jsonrpc`

7. 第6步骤的结果是

   ` {"jsonrpc":"2.0","id":3,"result":{"quirks":["XRE-7389","DELIA-16415","RDK-16024","DELIA-18552"],"success":true}}`

## 添加新版本服务

1. 服务的版本在不同的 `JSONRPC` 处理程序中维护
2. 我们需要将版本列表指定为每个处理程序的数组
3. 假设我们正在为 `DisplaySettings` 插件添加一个新的 `API setFoo()` 到版本 2。我们需要为此版本创建一个新的 `JSONRPC` 处理程序。这基本上需要此处理程序支持的一系列版本。

```c++
DisplaySettings::DisplaySettings()
: AbstractPlugin()
{...// Create JSONRPC handler for version 2. 最后一个参数确保所有处理程序都从基本版本复制到这个新版本...
Core::JSONRPC::Handler& Version_2 = JSONRPC::CreateHandler({ 2 }, *this);
 
// Register the new method in version 2 to this handler.
Version_2.Register<Core::JSON::String>(_T("setFoo"), &DisplaySettings::setFoo, this);
}
 
//version 2 APIs
void DisplaySettings::setFoo(Core::JSON::String)
{
}
```

## Make a Thunder Navo Service

Plugins 种类

- `in-process `，我们可以从 WPEFramework 线程池共享工作池（它将使用一个轻量级的进程，不需要自己的进程空间：很多插件都在进程中：（Device Info, RemoteControl, FirmwareControl, TraceControl etc）

- `Out-of-process `，用于运行需要在单独的进程上下文中处理的插件（如果任何操作可能影响 WPEFramework 进程，则必须在进程外运行），例如 BrowserPlugin（cobalt、webkit、spark、Netflix）。

  它将提供自己的线程池，然后它也可以使用 COMRPC 与 WPEFramework 通信

- `Out-of-Host `，可以在设备外运行，并在外部与 WPEFramework 连接。 COMRPC 用于进程之间的通信，如果有大数据应该使用它。目前没有现有的插件，只有示例插件：https://github.com/rdkcentral/ThunderNanoServices/tree/master/examples/RemoteHostExample

- `COMRPC `，用于在插件之间进行通信（进程外）或为更大的数据进行通信（https://github.com/rdkcentral/ThunderNanoServices/tree/master/examples/COMRPCClient）

- `JSONRPC `，用于从外部插件获取/更新信息（大多数插件在接口中提供此信息，类似于 ReST API）

  它可以从应用程序中使用（ https://github.com/rdkcentral/ThunderNanoServices/tree/master/examples/JSONRPCClient）只能用于小数据量

- `Message-pack`，类似于 JSONRPC，（https://github.com/rdkcentral/ThunderNanoServices/tree/master/examples/JSONRPCClient）

  但是这个特性并没有通过 WPEFramework Process 暴露在外面。它可以通过使用另一个应用程序来实现（https://github.com/rdkcentral/ThunderNanoServices/blob/master/examples/JSONRPCPlugin/JSONRPCPlugin.h#L149）



1. **wpeframework接口规范**

   `<PluginName>.json`(https://github.com/rdkcentral/Thunder/tree/master/Source/WPEFramework/json)

2. **wpeframe-plugins 开发**

   1. `git clone https://github.com/rdkcentral/ThunderNanoServices/`

   2. `mkdir PluginName && cd PluginName`

      1. `touch CmakeList.txt` 编译插件代码并生成共享库（“.so”）(这也将生成处理所有依赖库)

         ```cmake
         set(PLUGIN_NAME PluginTemplate)                          # 设置环境变量 set(<variable> <value>)
         set(MODULE_NAME ${NAMESPACE}${PLUGIN_NAME})
         find_package(${NAMESPACE}Plugins REQUIRED)               # to从外部项目中查找和加载设置。
          
         #添加一个名为 <name> 的库目标，从命令调用中列出的源文件构建。 <name> 对应于逻辑目标名称，并且在项目中必须是全局唯一的
         add_library(${MODULE_NAME} SHARED
                 PluginTemplate.cpp
                 Module.cpp
                 ../helpers/utils.cpp)
         ```
   
         
   
      2. `touch Module.h` ，此头文件包含对JSON请求、响应、日志记录等的支持，基本所有的都一致
   
         ```c++
         #pragma once
         
         #ifndef MODULE_NAME
         #define MODULE_NAME Plugin_xxxxxx
         #endif
         
         #include <plugins/plugins.h>
         #include <tracing/tracing.h>
         
         #undef EXTERNAL
         #define EXTERNAL
         ```
   
      3. `touch Module.cpp`，此文件用于声明插件的模块名，所有的基本都一致
   
         ```c++
         #include "Module.h"
         
         MODULE_NAME_DECLARATION(BUILD_REFERENCE)
         ```
   
      4. `<PluginName>Plugin.json`，此文件包含插件的信息，如架构、信息和接口json文件（之前定义的）
   
         ```json
         {
           "$schema": "plugin.schema.json",
           "info": {
             "title": "Plugin Name Plugin",
             "callsign": "PluginName",
             "locator": "libWPEFrameworkPluginName.so",
             "status": "production",
             "description": "The PluginName plugin allows retrieving of various plugin-related information.",
             "version": "1.0"
           },
           "interface": {
             "$ref": "{interfacedir}/PluginName.json#"
           }
         }
         ```

      5. `<PluginName>.config`，设置插件的配置
   
         用于使插件与 wpeframework 守护进程一起自动启动
   
         可以根据需要设置一些其他参数
   
         ```c++
         set (autostart false)                       #we are setting autostart condition disable
         set (preconditions Platform)
         set (callsign "org.rdk.PluginTemplate")     #The callsign name was given to an instance of a plugin.
          
         #一个插件可以被实例化多次。但每个实例，实例名称“呼号”必须是唯一的。这里使用 org.rdk.PluginTemplate。
         ```
   
         
   
      6. `<PluginName>.h`，在此声明插件类，该类应包含插件实现所需的所有结构、变量和方法
   
         使用构造函数和析构函数在以下命名空间中声明类：
   
         ```cpp
         
         namespace WPEFfamework {
             namespace Plugin {
              
                 class PluginName : public PluginHost::IPlugin, public PluginHost::IWeb, public PluginHost::JSONRPC {
                 public:
                         PluginName()
                             : _skipURL(0)
                             , _service(nullptr)
                             , _subSystem(nullptr)
                         {
                             RegisterAll();
                         }
          
                         virtual ~PluginName()
                         {
                             UnregisterAll();
                         }
                 }
                 {
                     ----------------
                     ----------------
                 }
                 }
         }
         ```
   
         声明实现插件功能所需的方法
   
         ```cpp
         //这些方法用于放置插件 JSON 接口方法的集合，以使用 JSON RPC API 进行注册和注销
         void RegisterAll();
         void UnregisterAll(); 
         
         //这些方法用于初始化和取消初始化插件服务的处理程序
         virtual const string Initialize(PluginHost::IShell* service);
         virtual void Deinitialize(PluginHost::IShell* service); 
         
         //这些是与插件通信的 JSON 接口（get/set）方法
         uint32_t get_method(JsonData::Plugin::ClassName& response) const;
         uint32_t set_method(JsonData::Plugin::ClassName& response) const; 
         
         //该方法用于处理GET/POST/SET等REST APIs请求并返回响应
         virtual Core::ProxyType<Web::Response> Process(const Web::Request& request) override;
         ```
   
      7. `<PluginName>.cpp`此类包含 Plugin.h 中声明的方法的所有实现，并且这些定义应在以下命名空间中定义。
   
         该插件应使用服务注册 MACRO 进行注册，如下所示：
   
         ```cpp
         namespace WPEFramework {
             namespace Plugin {  
                 SERVICE_REGISTRATION(Plugin, 1, 0);
                 //所有在Plugin.h中声明的方法都应该在这里定义（实现）
             }
         }
         ```
   
      8. `<PluginName>JsonRpc.cpp`该类用于注册JSON RPC接口的方法
   
         ```cpp
         namespace WPEFramework { 
          
         namespace Plugin {
          
             using namespace JsonData::PluginName; 
              
             void Plugin::RegisterAll()
             {
                 //Can register any number of methods in this way
                 Property<className>(_T("parameter1"), &PluginName::get_method, nullptr, this);
                 Property<className>(_T("parameter2"), &PluginName::set_method, nullptr, this);
             }
          
             void Plugin::UnregisterAll()
             {
                 Unregister(_T("parameter1"));
                 Unregister(_T("parameter2"));
             }
         }
         }
         
         
         //注册的 (get / set ) 方法定义在同一个文件中
         uint32_t Plugin::get_method(ClassName& response) const
         {
             //body of the method
         }
          
         uint32_t Plugin::set_method(ClassName& response) const
         {
             //body of the method
         }   
         ```
   
      9. `<PluginName>HAL.cpp`，用于与驱动层通信以获取一些信息或设置一些属性。
   
   3. **编译和install**
   
      1. 在 wpeframework-plugins 的主 CMakeLists.txt 中启用插件
      2. `bitbake wpeframework-plugins`，会产生`<PluginName>.json`和 `libWPEFrameworkPlugin.so`
      3. Copy the plugin library (libWPEFrameworkPlugin.so) to `/usr/lib/wpeframework/plugins`
      4. Copy the Plugin.json file to `/etc/WPEFramework/plugins` so that the controller plugin identify it and list it in the WebUI (controller UI ) 
   
   4. **验证**
   
      1. rest api
   
         ```shell
         # Request:
         $ curl --request GET http://127.0.0.1:9998/Service/<pluginName>/<function>
         eg: $ curl --request GET http://127.0.0.1:9998/Service/Picture/Brightness
         
         # Response:
         {"brightness":100}
         ```
   
      2. json rpc
   
         ```shell
         #Request:
         $ curl --data-binary '{"jsonrpc": "2.0", "id": 3, "method": "Picture.1.brightness"}' http://127.0.0.1:9998/jsonrpc
         
         #Response:
         {"jsonrpc":"2.0","id":3,"result":{"brightness":100},"success"}
         ```
   

## RDKServices Plugin Template

要在构建序列中包含 plugintemplate 插件，请打开 rdkservices 配方文件并添加以下行。默认情况下;它被配置为在构建 rdkservices 时被禁用

`vi meta-rdk-video/recipes-extended/rdkservices/rdkservices_git.bb`

```
PACKAGECONFIG[plugintemplate]      = " -DPLUGIN_PLUGINTEMPLATE=OFF,-DPLUGIN_PLUGINTEMPLATE=ON, "
```

将插件包含在 rdkservises 构建中；在 rdkservices 配方的 packageconfig 中添加相同的内容：

```
PACKAGECONFIG += " plugintemplate"
```

编译和安装

`bitbake -c compile -f rdkservices  `

当编译完成后会将 json和so文件复制到 raspberrypi

以便控制UI识别

## OUT OF PROCESS Plugin

这里的插件是作为进程外开发的，它作为独立于 WPEFramework 的线程运行。服务彼此或特定服务可以是 COMRPC（用于插件之间的通信）或 JSONRPC（用于外部通信）。它有一个基于 Web 的控制器 UI。

![image-20220110143221256](E:\lcsprogram\study_doc\RDK\images\目录结构.png)

`<PluginName>.json` 该文件包含插件的信息，如模式、信息和接口 json 文件。这里的 outofprocess 将为 true，这表明插件作为单独的进程运行。

```json
{
 "locator":"libWPEFrameworkOutOfProcessPlugin.so",
 "classname":"OutOfProcessPlugin",
 "precondition":[
  "Platform"
 ],

 "autostart":true,
 "configuration":{
  "root":{
   "outofprocess":true
  }
 }
}
```

`<PluginName>.config` .config 文件是用于配置某些计算机程序的参数和初始设置的文件。

这里 outofprocess 设置为 true，使插件成为进程外插件。

```config
set (autostart true)
set (preconditions Platform)
map()
    kv(outofprocess true)
end()
ans(rootobject)
```

`<PluginName>.h` 

```cpp
namespace WPEFramework {
  namespace Plugin {
   class PluginName : public PluginHost::IPlugin, public PluginHost::IWeb, public PluginHost::JSONRPC {
   public:
     PluginName()
      : _skipURL(0)
      , _service(nullptr)
      , _subSystem(nullptr)
     {
      RegisterAll();
     }

     virtual ~PluginName()
     {
      UnregisterAll();
     }
   }
   ---------------------------------------
   ---------------------------------------
  }
}
```

`<PluginName>.cpp` 

`<PluginNameJsonRpc>.cpp`

# yocto bitbake编译过程

[4 Yocto Project Concepts — The Yocto Project ® dev documentation](https://docs.yoctoproject.org/overview-manual/concepts.html)

![../_images/user-configuration.png](E:\lcsprogram\study_doc\RDK\images\user-configuration.png)

![../_images/source-fetching.png](E:\lcsprogram\study_doc\RDK\images\source-fetching.png)

![../_images/patching.png](E:\lcsprogram\study_doc\RDK\images\patching.png)

![../_images/configuration-compile-autoreconf.png](E:\lcsprogram\study_doc\RDK\images\configuration-compile-autoreconf.png)

![../_images/analysis-for-package-splitting.png](E:\lcsprogram\study_doc\RDK\images\analysis-for-package-splitting.png)

![../_images/image-generation.png](E:\lcsprogram\study_doc\RDK\images\image-generation.png)