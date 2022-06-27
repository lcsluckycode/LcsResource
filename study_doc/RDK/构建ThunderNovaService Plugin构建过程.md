# 构建ThunderNovaService Plugin构建过程

# 1. 步骤

1. 在**ThunderNavoService文件夹**下面创建对应的Plugin文件夹，例如插件名为DemoService（后续的Plugin名称均由此为例），创建 **DemoService文件夹**

2. 在 **DemoService文件夹** 下面创建通用的文件，如下图。（除下图的文件目录外，假如需要与硬件进行交互，话可以创建 `DemoServiceHAL.cpp`）

   ![image-20220126101115275](E:\lcsprogram\study_doc\RDK\images\DemoService目录架构.png)

3. 需要在  **Thunder'Interfaces文件夹** 下面的 **jsonrpc文件夹** 下面创建 `DemoService.json` 文件，该文件主要作用是声明接口和必要的数据类型。规范可参考（https://github.com/rdkcentral/Thunder/tree/master/Source/WPEFramework/json）

4. 代码编辑完成后，在 **ThunderNavoService文件夹** 下面的 `CmakeLists.txt`文件追加加上

   ```cmake
   option(PLUGIN_DEMOSERVICE "Include DemoService plugin" OFF)
   
   if(PLUGIN_DEMOSERVICE)
       add_subdirectory(DemoService)
   endif()
   ```

5. （pc模拟环境）先编译执行构建 `ThunderInterfaces` 生成 `JsonData_Demoservice.h` 文件

   ```shell
   # set the building and installing environment
   export THUNDER_ROOT=/home/lics/thunder
   export THUNDER_INSTALL_DIR=${THUNDER_ROOT}/install
   mkdir -p ${THUNDER_INSTALL_DIR}
   cd ${THUNDER_ROOT}
   
   cmake -Hgithub.com.rdkcentral.ThunderInterfaces -Bbuild/ThunderInterfaces \
         -DCMAKE_INSTALL_PREFIX=${THUNDER_INSTALL_DIR}/usr \
         -DCMAKE_MODULE_PATH=${THUNDER_INSTALL_DIR}/tools/cmake
         
   make -C build/ThunderInterfaces && make -C build/ThunderInterfaces install
   
   # generate ./install/usr/include/WPEFramework/interfaces/json/JsonData_DemoService.h
   ```

6. （pc模拟环境）编译执行构建 `ThunderNanoService`生成 `libWPEFrameworkDemoService.so` 和 `DemoService.json` 文件

   ```shell
   cmake -Hgithub.com.rdkcentral.ThunderNanoServices -Bbuild/ThunderNanoServices \
         -DCMAKE_INSTALL_PREFIX=${THUNDER_INSTALL_DIR}/usr \
         -DCMAKE_MODULE_PATH=${THUNDER_INSTALL_DIR}/tools/cmake \
   	  -DPLUGIN_DEMOSERVICE=ON  #add the plugin which our build
   
   make -C build/ThunderNanoServices && make -C build/ThunderNanoServices install
   
   # generate ./install/usr/lib/wpeframework/plugins/libWPEFrameworkDemoService.so and
   # ./install/etc/WPEFramework/plugins/DemoService.json
   ```

7. 执行调试

   ```shell
   export THUNDER_ROOT=/home/lics/thunder
   export THUNDER_INSTALL_DIR=${THUNDER_ROOT}/install
   PATH=${THUNDER_INSTALL_DIR}/usr/bin:${PATH} \
   LD_LIBRARY_PATH=${THUNDER_INSTALL_DIR}/usr/lib:${LD_LIBRARY_PATH} \
   WPEFramework -c ${THUNDER_INSTALL_DIR}/etc/WPEFramework/config.json
   ```

# 2. 各个文件的含义及必要内容

## 2.1 Module.h

头文件包含对JSON请求、响应、日志记录等的支持，基本所有的plugin定义的内容一致

```cpp
#pragma once

#ifndef MODULE_NAME
#define MODULE_NAME Plugin_DemoService //Plugin_YourPluginName
#endif

#include <plugins/plugins.h>
#include <tracing/tracing.h>

#undef EXTERNAL
#define EXTERNAL
```

## 2.2 Module.cpp

此文件声明插件的模块名，所有的 plugin 一致

```cpp
#include "Module.h"

MODULE_NAME_DECLARATION(BUILD_REFERENCE)
```

## 2.3 DemoServicePlugin.json (<PluginName\>Plugin.json)

此文件包含插件的信息，框架、信息介绍和接口DemoService.json文件所处位置（详见第1节的第3点）等

```json
{
    "$schema": "plugin.schema.json",
    "info": {
      "title": "DemoService Plugin",
      "callsign": "DemoService",
      "locator": "libWPEFrameworkDemoService.so",
      "status": "production",
      "description": "Demo test service",
      "version": "1.0"
    },
    "interface": {
      "$ref": "{interfacedir}/DemoService.json"
    }
  }
```

## 2.4 DemoService.config (\<PluginName\>.config)

此文件设置插件的配置（以下是普通配置）

```config
set (autostart ${PLUGIN_DICTIONARY_AUTOSTART})
map()
end()
ans(configuration)
```

## 2.5  DemoService.h  (\<PluginName\>.h)

此文件声明plugin class，该类包含插件实现所需要的所有数据结构、变量和方法。example：

```cpp
#ifndef __DEMOSERVICE_H
#define __DEMOSERVICE_H

#include "Module.h"
#include <interfaces/json/JsonData_DemoService.h> //1.3 build it

namespace WPEFamework{
namespace Plugin {
    class DemoService : public PluginHost::IPlugin, public PluginHost::IWeb, public PluginHost::JSONRPC {  //those class have to inherited
        private:   //Plugin parameter (those have to define)
        uint8_t _skipURL;
        PluginHost::IShell* _service;
        PluginHost::ISubSystem* _subSystem;

        
        public:
        DemoService(const DemoService&) = delete;  //Plugin didn't accecpt the default constructor
        DemoService& operator=(const DemoService&) = delete; //Plugin didn't accecpt copy constructor
        
        DemoService(): _skipURL(0), _service(nullptr), _subSystem(nullptr) { 
            RegisterAll();
        }

        virtual ~DemoService() {
            UnregisterAll();
        }

        BEGIN_INTERFACE_MAP(DemoService)      // those add the plugin interface;
        INTERFACE_ENTRY(PluginHost::IPlugin)  // have to write
        INTERFACE_ENTRY(PluginHost::IDispatcher)
        INTERFACE_ENTRY(PluginHost::IWeb)
        END_INTERFACE_MAP
        
        public:
        // IPlugin methods
        // those function define the programe init or deinit service, have to define and overrite it
        const string Initialize(PluginHost::IShell* service) override;
        void Deinitialize(PluginHost::IShell* service) override;
        string Information() const override;
        
        // IWeb methods
        // Web HTTP handle function
        void Inbound(Web::Request& request) override;
        Core::ProxyType<Web::Response> Process(const Web::Request& request) override;
            
        private:
        // those function register or unregister JSON RPC API, if use JsonRpc, have to define it
        void RegisterAll();
        void UnregisterAll();

        // JSON RPC get and set methon
        // Datatype define in JsonData_DemoService.h (made in DemoService.json)
        uint32_t get_test(Core::JSON::DecUInt32& response);
        uint32_t set_test(const JsonData::DemoService::DemoserviceData& params);
        
    }
} // namespace Plugin
} // namespace WPEFramework

#endif
```

## 2.6 DemoService.cpp (\<PluginName\>.cpp)

该文件实现在<>.h定义中**除JSONRPC和HAL外**的**所有方法**。并且在与<>.h下相同的命名空间下实现定义

```cpp
#include "DemoService.h"

namespace WPEFramework {
namespace Plugin {
    SERVICE_REGISTRATION(DemoService, 1, 0);

    // Web HTTP request or response DataType
    static Core::ProxyPoolType<Web::JSONBodyType<DemoService::Data>> jsonResponseFactory(4);

    .....
} // namespace Plugin
} // namespace WPEFramework
```

## 2.7 DemoServiceJsonRpc.cpp (\<PluginName>JsonRpc.cpp)

该文件用于注册实现JSONRPC接口方法

```c++
#include "Module.h"
#include "DemoService.h"
#include <interfaces/json/JsonData_DemoService.h>

namespace WPEFramework {
namespace Plugin {
    using namespace JsonData::DemoService; // using this namespace then using type with no namespace
    
    void DemoService::RegisterALL() {
        // Register<srcDateType,dstDataType> method name define in DemoService.json 
        Register<DemoserviceData, void>(_T("set"),&DemoService::set_test, this);
        
        // Property<dstDataType> property name define in DemoService.json
        Property<Core::JSON::DecUInt32>(_T("state"),&DemoService::get_test, nullptr, this);
    }
    
    void DemoService::UnregisterAll() {
        Unregister(_T("set"));
        Unregister(_T("get"));
    }
    
    uint32_t DemoService::set_test(const DemoserviceData &params) {
        .....
    }
    
    uint32_t DemoService::get_test(Core::JSON::DecUInt32& response) {
        .....
    }
    
} // namespace Plugin
} // namespace WPEFramework
```

## 2.8 DemoServiceHAL.cpp (\<PluginName\>HAL.cpp) 

暂无参考

## 2.9 CmakeLists.txt

定义编译依赖关系和源文件所在位置

```cmake
project(DemoService)

cmake_minimum_required(VERSION 3.3)

project_version(1.0.0)
set(PLUGIN_NAME DemoService)
find_package(${NAMESPACE}Definitions REQUIRED)
set(MODULE_NAME ${NAMESPACE}${PROJECT_NAME})

find_package(${NAMESPACE}Plugins REQUIRED)
find_package(CompileSettingsDebug CONFIG REQUIRED)

add_library(${MODULE_NAME} SHARED
        DemoService.cpp
        DemoServiceJsonRpc
        Module.cpp)

set_target_properties(${MODULE_NAME} PROPERTIES
        CXX_STANDARD 11
        CXX_STANDARD_REQUIRED YES)

target_link_libraries(${MODULE_NAME}
        PRIVATE
            ${NAMESPACE}Plugins::${NAMESPACE}Plugins)

target_include_directories( ${MODULE_NAME}
        PUBLIC
            $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}>)

target_link_libraries(${MODULE_NAME}
    PRIVATE
        CompileSettingsDebug::CompileSettingsDebug
        ${NAMESPACE}Plugins::${NAMESPACE}Plugins
        ${NAMESPACE}Definitions::${NAMESPACE}Definitions)

install(TARGETS ${MODULE_NAME}
        DESTINATION lib/${STORAGE_DIRECTORY}/plugins)

write_config()
```

# 3. inteface json 文件（example）

DemoService.json

```json
{
  "$schema": "interface.schema.json",
  "jsonrpc": "2.0",
  "info": {
    "title": "DemoService API",
    "class": "DemoService",
    "description": "DemoService JSON-RPC interface"
  },
  "common": {
    "$ref": "common.json"
  },
  "definitions": {
    "state":{
        "type": "string",
        "enum": [
          "first",
          "second",
          "third"
        ],
        "enumvalues": [
          1,
          2,
          3
        ],
        "enumtyped": false,
        "description": "DemoService state",
        "example": "first"
    },
    "demoservice":{
        "type": "object",
        "properties": {
            "demoservicestate": {
              "$ref": "#/definitions/state"
            },
            "timeout": {
              "description": "Time to wait for power state change",
              "type": "number",
              "size": 32,
              "example": 0
            }
      },
      "required": [
        "demoservicestate",
        "timeout"
      ]    
    }   
  },
  "properties": {
    "state": {
      "summary": "DemoService state",
      "readonly": true,
      "params": {
        "$ref": "#/definitions/state"
      }
    }
  },
  "methods": {
    "set": {
      "summary": "Sets Demoservice state",
      "params": {
        "$ref": "#/definitions/demoservice"
      },
      "result": {
        "$ref": "#/common/results/void"
      },
      "errors": [
        {
          "description": "General failure",
          "$ref": "#/common/errors/general"
        },
        {
          "description": "Trying to set the same power mode",
          "$ref": "#/common/errors/duplicatekey"
        },
        {
          "description": "Power state is not supported",
          "$ref": "#/common/errors/illegalstate"
        },
        {
          "description": "Invalid Power state or Bad JSON param data format",
          "$ref": "#/common/errors/badrequest"
        }
      ]
    }
  }
}
```

对应生成的头文件（JsonData_DemoService.h）

```cpp
// C++ classes for DemoService API JSON-RPC API.
// Generated automatically from 'DemoService.json'. DO NOT EDIT.

// Note: This code is inherently not thread safe. If required, proper synchronisation must be added.

#pragma once

#include <core/JSON.h>
#include <core/Enumerate.h>

namespace WPEFramework {

namespace JsonData {

    namespace DemoService {

        // Common enums
        //

        // DemoService state
        enum StateType {
            FIRST = 1,
            SECOND = 2,
            THIRD = 3
        };

        // Method params/result classes
        //

        class DemoserviceData : public Core::JSON::Container {
        public:
            DemoserviceData()
                : Core::JSON::Container()
            {
                Add(_T("demoservicestate"), &Demoservicestate);
                Add(_T("timeout"), &Timeout);
            }

            DemoserviceData(const DemoserviceData&) = delete;
            DemoserviceData& operator=(const DemoserviceData&) = delete;

        public:
            Core::JSON::EnumType<StateType> Demoservicestate; // DemoService state
            Core::JSON::DecUInt32 Timeout; // Time to wait for power state change
        }; // class DemoserviceData

    } // namespace DemoService

} // namespace JsonData

// Enum conversion handlers
ENUM_CONVERSION_HANDLER(JsonData::DemoService::StateType);

}
```

生成的 cpp 文件（JsonEnum_DemoService.cpp）

```cpp
// Enumeration code for DemoService API JSON-RPC API.
// Generated automatically from 'DemoService.json'.

#include "definitions.h"
#include <core/Enumerate.h>
#include "JsonData_DemoService.h"

namespace WPEFramework {

ENUM_CONVERSION_BEGIN(JsonData::DemoService::StateType)
    { JsonData::DemoService::StateType::FIRST, _TXT("first") },
    { JsonData::DemoService::StateType::SECOND, _TXT("second") },
    { JsonData::DemoService::StateType::THIRD, _TXT("third") },
ENUM_CONVERSION_END(JsonData::DemoService::StateType);

}
```

## 3.1 json 模块拆解

相关模块用途说明

```josn
{
  "$schema": "interface.schema.json",
  "jsonrpc": "2.0",
  "info": {  //JsonData_Plugin 主要说明
    "title": "DemoService API",
    "class": "DemoService",  // namespace name
    "description": "DemoService JSON-RPC interface"  // 这个参数都是注释
  },
  "common": {
    "$ref": "common.json"  // 内含各种公共信息，如返回错误码等
  },
  "definitions":{}, // 数据类型、结构定义，假如后续模块没有引用该模块的数据类型，则不会生成 
  "properties":{}, // 属性声明，这里声明Plugin的属性
  "methods":{}  // 注册方法接口，假如这里使用的数据会默认在头文件中生成，object 类型的数据假如在definition内定义则会对应生成 NameInfo class（假如没有Data class，优先会命名为NameData class）；若没有在definition内定义，则会生成 MethodParamsInfo class 
}
```

如例子json文件的definitions模块，定义了两中数据类型，一种为 state，一种为demoservice，在propertries声明了state数据，属性为definitions内定义的state，所以在头文件中生成了 enum StateType 数据。

为什么头文件内生成了class DemoserviceData？

因为在 method 模块引用了definitions定义的demoservice，自动生成了。同理假如在propertries没有使用state，但是在demoservice内引用，则也会生成enum StateType类型，但是会在 class DemoserviceData 内生成。如下：

```cpp
class DemoserviceData : public Core::JSON::Container {
        public:
            // DemoService state
            enum StateType {
                FIRST = 1,
                SECOND = 2,
                THIRD = 3
            };
            
            DemoserviceData()
                : Core::JSON::Container()
            {
                Add(_T("demoservicestate"), &Demoservicestate);
                Add(_T("timeout"), &Timeout);
            }

            DemoserviceData(const DemoserviceData&) = delete;
            DemoserviceData& operator=(const DemoserviceData&) = delete;

        public:
            Core::JSON::EnumType<StateType> Demoservicestate; // DemoService state
            Core::JSON::DecUInt32 Timeout; // Time to wait for power state change
        }; // class DemoserviceData
```

method模块内的 `param` 参数，表示request的数据类型， `result` 表示结果返回的 response内的数据内容。

method定义的方法，在DemoServiceJsonRpc.cpp内使用 `Register`函数进行绑定。

properties内定义的方法，在DemoServiceJsonRpc.cpp内使用 `Property` 函数进行绑定。

events内定义的方法，在JsonRpc.cpp内使用，`Notify`函数进行调用。