# 商品识别组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [使用](#使用)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件支持扫描商品条码/二维码，拍摄商品图片并获取返回结果。

<img src="snapshots/display.jpg" width="300">

## 约束与限制

### 环境

- DevEco Studio版本：DevEco Studio 5.0.1 Release及以上
- HarmonyOS SDK版本：HarmonyOS 5.0.1 Release SDK及以上
- 设备类型：华为手机（包括双折叠和阔折叠）
- 系统版本：HarmonyOS 5.0.1(13)及以上

### 权限

- 相机权限：ohos.permission.CAMERA

## 使用

1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加module_ui_base和module_product_scan模块。

   ```
   // 项目根目录下build-profile.json5填写module_ui_base和module_product_scan路径。其中XXX为组件存放的目录名
   "modules": [
     {
       "name": "module_ui_base",
       "srcPath": "./XXX/module_ui_base"
     },
     {
       "name": "module_product_scan",
       "srcPath": "./XXX/module_product_scan"
     }
   ]
   ```

   ```
   // 在项目根目录oh-package.json5中添加依赖
   "dependencies": {
     "module_product_scan": "file:./XXX/module_product_scan"
   }
   ```

2. 使用组件，详见[示例代码](#示例代码)。

   

## API参考

#### CustomScanOptions对象说明

使用Navigation路由跳转商品识别页面时，作为param参数传入。

| 名称              | 类型                                                    | 是否必填 | 说明                         |
| ----------------- |-------------------------------------------------------| -------- | ---------------------------- |
| enableMultiMode   | boolean                                               | 否       | 是否支持多码识别，默认为true |
| enableAlbum       | boolean                                               | 否       | 是否支持相册选择，默认为true |
| handleScanResult  | (code: string) => void                                | 否       | 处理扫码结果的回调           |
| handlePhotoResult | (image: image.PixelMap \| Resource \| string) => void | 否       | 处理拍照结果的回调           |

## 示例代码

```ts
import { CustomScanOptions, ScanRouterMap } from 'module_product_scan';

@Builder
export function buildScanPage() {
  CustomScanPage()
}

@Entry
@ComponentV2
struct CustomScanPage {
  @Local stack: NavPathStack = new NavPathStack()
  @Local isStr: boolean = true
  @Local msg: string = ''
  @Local image: PixelMap | string | undefined

  toast(message: string) {
    try {
      this.getUIContext().getPromptAction().showToast({ message })
    } catch (err) {
      console.log(JSON.stringify(err))
    }
  }

  build() {
    Navigation(this.stack) {
      Column({ space: 16 }) {
        Button('进入扫码')
          .onClick(() => {
            this.stack.pushPath({
              name: ScanRouterMap.CUSTOM_SCAN_PAGE,
              param: {
                enableMultiMode: true,
                enableAlbum: true,
                handleScanResult: (url: string) => {
                  this.isStr = true
                  this.msg = '识别到商品条码：' + url;
                  this.stack.pop()
                },
                handlePhotoResult: (uri: string | PixelMap) => {
                  this.isStr = false;
                  this.image = uri
                  this.stack.pop()
                },
              } as CustomScanOptions,
            });
          })

        Text('识别信息：')
        if (this.isStr) {
          Text(this.msg)
        } else {
          Image(this.image).width(200)
        }
      }
      .height('100%')
      .justifyContent(FlexAlign.Center)
    }
  }
}
```

