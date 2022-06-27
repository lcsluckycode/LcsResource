# Linux驱动

## platform总线

platform维护的所有驱动都必须使用该结构体定义（**platform_driver**）

```c
struct platform_driver {
    int (*probe)(struct platform_device *);  //当驱动和硬件信息匹配成功后会调用；驱动所有的资源的注册和初始化全部在这个函数里面
    int (*remove)(struct platform_device *); //硬件信息被移除，或者驱动被卸载，要释放资源的操作在该函数
    void (*shutdown)(struct platform_device *);
    int (*suspend)(struct platform_device *, pm_message_t state);
    int (*resume)(struct platform_device*);
    struct device_driver driver;  //内核维护的所有的驱动必须包含该成员，通常driver->name用于和设备进行匹配
    const struct platform_device_id *id_table; //往往一个驱动能够同事支持多个硬件，这些硬件的名字都放在该结构体数组中
    bool prevent_deferred_probe;
};
```

platform总线用于描述设备硬件信息的结构体，包括硬件的所有资源（io, memory, 中断, DMA等等）（**platform_device**）

```c
struct platform_device {
    const char *name;  // 设备的名字,用于和驱动进行匹配
    int id;
    bool id_auto;
    struct device dev; // 内核维护的所有设备必须包含该成员
    u32 num_resources;  // 资源个数
    struct resource *resource; // 描述资源
    const struct platform_device_id *id_entry;
    
    struct mfd_cell *mfd_cell; /* MFD cell pointer */
    
    struct pdev_archdata archdata;  /* arch specific additions */
}
```

struct device dev->release()必须实现

其中描述硬件信息的成员**struct resource**

```c
struct resource {
	resource_size_t start; // 表示资源的起始值
    resource_size_t end;   // 表示资源的最后一个字节地址,如果是中断,end和start相同
    const char *name;   // 可不写
    unsigned long flags; // 资源的类型
    struct resource *parent, *sibling, *child;
}
```

**struct device_driver**

```c
struct device_driver {
    const char *name; // 用于与硬件进行匹配
    struct bus_type *bus;
    
    struct module *owner;
    const char *mod_name; /* used for built-in modules */
    
    bool suppress_bind_attrs; /* disables bind/unbind via sysfs */
    
    const struct of_device_id *of_match_table;
    const struct acpi_device_id *acpi_match_table;
    
    int (*prove)(struct device *dev);
    int (*remove)(struct device *dev);
    int (*shutdown)(struct device *dev);
    int (*suspend)(struct device *dev, pm_message_t state);
    int (*resume)(struct device *dev);
    
    const struct attribute_group **groups;
    const struct dev_pm_ops *pm;
    struct driver_private *p;
}
```

**struct device**

```c
struct device {
    struct device *parant;
    struct device_private *p;
    
    struct kobject kobj;
    const char *init_name; // initial name of the device
    const struct device_type *type;
    
    struct mutex mutex; // mutex to synchronize calls to its driver
    
    struct bus_type *bus; // type of bus device is on
    struct device_driver *driver; // which driver has allocated this device
    
    void *platform_data; //platform specific data, device core doesn't touch it
    
    struct dev_pm_info power;
    struct dev_pm_domain *pm_domain;
    
#ifdef CONFIG_PINCTRL
    struct dev_pin_info *pins;
#endif
#ifdef CONFIG_NUMA
    int numa_node; // NUMA node this device is close to
#endif
    u64 *dma_mask; //dma mask (if dma'able device)
    u64 coherent_dma_mask; // like dma_mask, but for alloc_coherent mappings as not all hardware supports 64 bit addresses for consistent allocations such descriptors
    
    struct device_dma_parameters *dma_parms;
    
    struct list_head dma_pools; // dma pools (is dma'able)
    
    struct dma_coherent_mem *dma_mem; // internal for coherent mem override
    
#ifdef CONFIG_DMA_CMA
    struct cma *cma_area;  // contiguous memory area for dma allocations 
#endif
    /* arch specific additions */
    struct dev_archdata archdata;

    struct device_node *of_node; /* associated device tree node */
    struct acpi_dev_node acpi_node; /* associated ACPI device node */

    dev_t   devt; /* dev_t, creates the sysfs "dev" */
    u32   id; /* device instance */

    spinlock_t  devres_lock;
    struct list_head devres_head;

    struct klist_node knode_class;
    struct class  *class;
    const struct attribute_group **groups; /* optional groups */

    void (*release)(struct device *dev);  // 不能为空
    struct iommu_group *iommu_group;

    bool   offline_disabled:1;
    bool   offline:1;
}
```

### 注册步骤

1. 注册设备platform_device_register

   ```c
   int platform_device_register(struct platform_device *pdev) {
   	device_initalize(&pdev->dev);
   	arch_setup_pdev_archdata(pdev);
   	return platform_device_add(pdev);
   }
   ```

2. 注册驱动platform_driver_register

   ```c
   #define platporm_driver_register(drv) \
   	__platform_driver_register(drv, THIS_MODULE)
   ```

### 开发步骤

1. 设备
   - 需要实现的结构体 `platform_device`
     - 初始化 `resource` 机构变量
     - 初始化 `platform_device` 结构变量
     - 像系统注册设备 `platform_device_register`
   - `platform_driver_register()` 中添加device到内核最终调用的还是 `device_add` 函数
   - `platform_device_add` 和 `device_add` 最主要的区别就是多了一步 `insert_resource(p, r)`, 即将platform资源添加到内核, 由内核统一管理
2. 驱动
   - 实现结构体 `platform_driver`
   - 调用 `platform_driver_register`注册
   - `platform_driver` 和 `platform_device` 中的name变量值比u下相同(不考虑设备树的情况下)
   - 注册时,会将当前注册的`platform_driver`中的name变量的值和已经注册的所有`platform_device`的name值进行匹配, 只有找到相同的名称才能注册成功.
   - 当注册成功的时候, 会调用 `platform_driver` 结构体元素的 `probe` 指针函数

platform总线变量的定义**struct bus_type platform_bus_type**定义如下:

```c
struct bus_type platform_bus_type = {
    .name  = "platform",
    .dev_groups = platform_dev_groups,
    .match  = platform_match,
    .uevent  = platform_uevent,
    .pm  = &platform_dev_pm_ops,
};
```

其中最重要的成员是**.match**。

当有设备的硬件信息注册到`platform_bus_type` 总线的时候，会遍历所有`platform`总线维护的驱动， 通过名字来匹配，如果相同，就说明硬件信息和驱动匹配，就会调用驱动的`platform_driver ->probe`函数,初始化驱动的所有资源，让该驱动生效。

## Linux设备驱动统一模型

[手把手教linux驱动11-linux设备驱动统一模型 (qq.com)](https://mp.weixin.qq.com/s?__biz=MzUxMjEyNDgyNw==&mid=2247493443&idx=1&sn=34528c556b57f7d8b6c610de0e82707d&chksm=f96b95b7ce1c1ca183f21c0b8fc143c7c7e6594f4275fc0846ac152b9d2fd533c44703285e1b&scene=21&token=783266413&lang=zh_CN#wechat_redirect)

### 设备树

设备树(Device Tree)，将这个词分开就是“设备”和“树”，描述设备树的文件叫做DTS(Device Tree Source)，这个DTS 文件采用树形结构描述板级设备，比如CPU 数量、 内存基地址、IIC 接口上接了哪些设备、SPI 接口上接了哪些设备等等。设备树是树形数据结构，具有描述系统中设备的节点。每个节点都有描述所代表设备特征的键值对。每个节点只有一个父节点，而根节点则没有父节点。

![图片](E:\lcsprogram\study_doc\Linux\images\设备树)