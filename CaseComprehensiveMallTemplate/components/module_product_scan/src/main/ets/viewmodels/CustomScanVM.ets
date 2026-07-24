import { display } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { customScan, detectBarcode, scanBarcode, scanCore } from '@kit.ScanKit';
import { Logger } from 'module_ui_base';
import { TabIndexMap } from '../commons/Constants';
import { CustomScanOptions } from '../commons/Types';
import { AlbumUtil } from '../utils/AlbumUtil';
import { CameraUtil } from '../utils/CameraUtil';

const TAG: string = '[CustomScanVM]';

@ObservedV2
export class CustomScanVM {
  @Trace scanOptions?: scanBarcode.ScanOptions;
  @Trace surfaceId: string = ''; // XComponent组件生成id
  @Trace isShowBack: boolean = false; // 是否已经返回扫码结果
  @Trace isFlashLightEnable: boolean = false; // 是否开启了闪光灯
  @Trace isSensorLight: boolean = false; // 记录当前环境亮暗状态
  @Trace cameraHeight: number = 640; // 设置预览流高度，默认单位：vp
  @Trace cameraWidth: number = 360; // 设置预览流宽度，默认单位：vp
  @Trace zoomValue: number = 1; // 预览流缩放比例
  @Trace setZoomValue: number = 1; // 已设置的预览流缩放比例
  @Trace scaleValue: number = 1; // 屏幕缩放比
  @Trace pinchValue: number = 1; // 双指缩放比例
  @Trace displayHeight: number = 0; // 屏幕高度，单位vp
  @Trace displayWidth: number = 0; // 屏幕宽度，单位vp
  @Trace scanResult: Array<scanBarcode.ScanResult> = []; // 扫码结果
  @Trace cameraResult: image.PixelMap | Resource | string | undefined =
    undefined;
  handleScanResult: (code: string) => void = () => {};
  handlePhotoResult: (uri: string) => void = () => {};
  private _uiContext: UIContext;
  mXComponentController: XComponentController = new XComponentController();

  constructor(uiContext: UIContext) {
    this._uiContext = uiContext;
  }

  public init(options?: CustomScanOptions) {
    this.scanOptions = {
      scanTypes: [scanCore.ScanType.ALL],
      enableMultiMode: options?.enableMultiMode ?? false,
      enableAlbum: options?.enableAlbum ?? false,
    };
    if (options?.handleScanResult) {
      this.handleScanResult = options.handleScanResult;
    }
    if (options?.handlePhotoResult) {
      this.handlePhotoResult = options.handlePhotoResult;
    }
    // 设置预览流布局尺寸
    this.setDisplay();
    try {
      customScan.init(options);
    } catch (error) {
      Logger.error(
        TAG,
        `Failed to init customScan. Code: ${error.code}, message: ${error.message}`,
      );
    }
  }

  public async releaseScan() {
    // 页面消失或隐藏时，停止并释放相机流
    this.isFlashLightEnable = false;
    this.isSensorLight = false;
    try {
      customScan.off('lightingFlash');
    } catch (error) {
      Logger.error(
        TAG,
        `Failed to off lightingFlash. Code: ${error.code}, message: ${error.message}`,
      );
    }
    await this.stopScan();
    try {
      // 自定义相机流释放接口
      await customScan.release();
    } catch (error) {
      Logger.error(
        TAG,
        `Failed to release customScan. Code: ${error.code}, message: ${error.message}`,
      );
    }
  }

  public setDisplay() {
    try {
      // 默认竖屏
      let displayClass = display.getDefaultDisplaySync();
      this.displayHeight = this._uiContext.px2vp(displayClass.height);
      this.displayWidth = this._uiContext.px2vp(displayClass.width);
      this.cameraHeight = this.displayHeight;
      this.cameraWidth = this.displayWidth;
    } catch (error) {
      Logger.error(
        TAG,
        `Failed to getDefaultDisplaySync. Code: ${error.code}, message: ${error.message}`,
      );
    }
  }

  async stopScan() {
    try {
      await customScan.stop();
    } catch (error) {
      Logger.error(
        TAG,
        `Failed to stop customScan. Code: ${error.code}, message: ${error.message}`,
      );
    }
  }

  async initScan() {
    await this.releaseScan();
    this.isShowBack = false;
    this.scanResult = [];
    let viewControl: customScan.ViewControl = {
      width: this.cameraWidth,
      height: this.cameraHeight,
      surfaceId: this.surfaceId,
    };
    try {
      // 请求扫码接口
      const result = await customScan.start(viewControl);
      Logger.info(TAG, `result: ${JSON.stringify(result)}`);
      if (result.length) {
        // 解析码值结果跳转应用服务页
        this.scanResult = result;
        if (result.length === 1) {
          this.handleScanResult(this.scanResult[0].originalValue);
        }
        this.isShowBack = true;
        // 获取到扫描结果后暂停相机流
        this.stopScan();
      }
    } catch (error) {
      Logger.error(
        TAG,
        `Failed to start customScan. Code: ${error.code}, message: ${error.message}`,
      );
    }
  }

  async initCamera() {
    this.cameraResult = undefined;
    await CameraUtil.releaseCamera();
    const context = this._uiContext.getHostContext();
    if (context) {
      CameraUtil.initCamera(this.surfaceId, context, () => {
        const result = AppStorage.get('imageMap') as string;
        if (result) {
          this.cameraResult = result;
          this.handlePhotoResult(result);
        }
      });
    }
  }

  public customGetZoom(): number {
    let zoom = 1;
    try {
      zoom = customScan.getZoom();
      Logger.info(TAG, `Succeeded in getting zoom, zoom: ${zoom}`);
    } catch (error) {
      Logger.error(
        TAG,
        `Failed to get zoom. Code: ${error.code}, message: ${error?.message}`,
      );
    }
    return zoom;
  }

  public customSetZoom(pinchValue: number): void {
    try {
      customScan.setZoom(pinchValue);
      Logger.info(TAG, `Succeeded in setting zoom.`);
    } catch (error) {
      Logger.error(
        TAG,
        `Failed to set zoom. Code: ${error.code}, message: ${error?.message}`,
      );
    }
  }

  public loadXComponentData() {
    Logger.info(TAG, 'Succeeded in loading, onLoad is called.');
    // 获取XComponent组件的surfaceId
    this.surfaceId = this.mXComponentController.getXComponentSurfaceId();
    Logger.info(TAG, `Succeeded in getting surfaceId: ${this.surfaceId}`);
    this.initScan();
    // 闪光灯监听接口
    customScan.on('lightingFlash', (error, isLightingFlash) => {
      if (error) {
        Logger.error(
          TAG,
          `Failed to on lightingFlash. Code: ${error.code}, message: ${error.message}`,
        );
        return;
      }
      if (isLightingFlash) {
        this.isFlashLightEnable = true;
      } else {
        try {
          if (!customScan.getFlashLightStatus()) {
            this.isFlashLightEnable = false;
          }
        } catch (error) {
          Logger.error(
            TAG,
            `Failed to get flashLightStatus. Code: ${error.code}, message: ${error.message}`,
          );
        }
      }
      this.isSensorLight = isLightingFlash;
    });
  }

  public handleFlashLightChange() {
    let lightStatus: boolean = false;
    try {
      lightStatus = customScan.getFlashLightStatus();
    } catch (error) {
      Logger.error(
        TAG,
        `Failed to get flashLightStatus. Code: ${error.code}, message: ${error.message}`,
      );
    }

    // 根据当前闪光灯状态，选打开或关闭闪光灯
    if (lightStatus) {
      try {
        customScan.closeFlashLight();
        setTimeout(() => {
          this.isFlashLightEnable = this.isSensorLight;
        }, 200);
      } catch (error) {
        Logger.error(
          TAG,
          `Failed to close flashLight. Code: ${error.code}, message: ${error.message}`,
        );
      }
    } else {
      try {
        customScan.openFlashLight();
      } catch (error) {
        Logger.error(
          TAG,
          `Failed to open flashLight. Code: ${error.code}, message: ${error.message}`,
        );
      }
    }
  }

  public handleZoomChange() {
    // 设置相机缩放比例
    if (!this.isShowBack) {
      if (!this.zoomValue || this.zoomValue === this.setZoomValue) {
        this.setZoomValue = this.customGetZoom();
      } else {
        this.zoomValue = this.zoomValue;
        this.customSetZoom(this.zoomValue);
        setTimeout(() => {
          if (!this.isShowBack) {
            this.setZoomValue = this.customGetZoom();
          }
        }, 1000);
      }
    }
  }

  public handleMultiScanStart(event: ClickEvent) {
    // 是否已扫描到结果
    if (this.isShowBack) {
      return;
    }
    // 点击屏幕位置，获取点击位置(x,y)，设置相机焦点
    let x1 = this._uiContext.vp2px(event.displayY) / (this.displayHeight + 0.0);
    let y1 =
      1.0 - this._uiContext.vp2px(event.displayX) / (this.displayWidth + 0.0);
    try {
      customScan.setFocusPoint({ x: x1, y: y1 });
      Logger.info(TAG, `Succeeded in setting focusPoint x1: ${x1}, y1: ${y1}`);
    } catch (error) {
      Logger.error(
        TAG,
        `Failed to set focusPoint. Code: ${error.code}, message: ${error.message}`,
      );
    }
    Logger.info(TAG, `Succeeded in setting focusPoint x1: ${x1}, y1: ${y1}`);
    // 设置连续自动对焦模式
    setTimeout(() => {
      try {
        customScan.resetFocus();
      } catch (error) {
        Logger.error(
          TAG,
          `Failed to reset focus. Code: ${error.code}, message: ${error.message}`,
        );
      }
    }, 200);
  }

  public handleMultiScanResult() {
    // 是否已扫描到结果
    if (this.isShowBack) {
      return;
    }
    // 获取双指缩放比例，设置变焦比
    try {
      let zoom = this.customGetZoom();
      this.pinchValue = this.scaleValue * zoom;
      this.customSetZoom(this.pinchValue);
      Logger.info(TAG, 'Pinch end');
    } catch (error) {
      Logger.error(
        TAG,
        `Failed to set zoom. Code: ${error.code}, message: ${error.message}`,
      );
    }
  }

  public getPicFromAlbum(tabIndex: TabIndexMap.SCAN) {
    if (!this.scanOptions?.enableAlbum) {
      return;
    }
    if (tabIndex === TabIndexMap.SCAN) {
      this.handleScanFromAlbum();
    } else {
      this.handlePhotoFromAlbum();
    }
  }

  public handleScanFromAlbum() {
    AlbumUtil.selectPicture((result: photoAccessHelper.PhotoSelectResult) => {
      // 定义识码参数inputImage，其中uri为picker选择图片
      let inputImage: detectBarcode.InputImage = { uri: result.photoUris[0] };
      try {
        // 调用图片识码接口
        detectBarcode.decode(
          inputImage,
          this.scanOptions,
          (error: BusinessError, result: Array<scanBarcode.ScanResult>) => {
            if (error && error.code) {
              Logger.error(
                TAG,
                `Failed to get ScanResult by callback with options. Code: ${error.code}, message: ${error.message}`,
              );
              return;
            }
            Logger.info(
              TAG,
              `Succeeded in getting ScanResult by callback with options, result is ${JSON.stringify(result)}`,
            );
            if (result.length) {
              this.scanResult = result;
              this.handleScanResult(result[0].originalValue);
            } else {
              this.toast('未识别到有效码图，请重新扫描');
              this.initScan();
            }
          },
        );
      } catch (error) {
        Logger.error(
          TAG,
          `Failed to detectBarcode. Code: ${error.code}, message: ${error.message}`,
        );
      }
    });
  }

  public handlePhotoFromAlbum() {
    AlbumUtil.selectPicture((result: photoAccessHelper.PhotoSelectResult) => {
      this.cameraResult = result.photoUris[0];
      this.handlePhotoResult(this.cameraResult);
    });
  }

  toast(message: string) {
    try {
      this._uiContext.getPromptAction().showToast({ message });
    } catch (error) {
      Logger.error(TAG, 'show toast failed. error: ' + JSON.stringify(error));
    }
  }
}
