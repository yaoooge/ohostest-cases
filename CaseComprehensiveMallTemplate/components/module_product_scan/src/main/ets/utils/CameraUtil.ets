/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { common } from '@kit.AbilityKit';
import { JSON } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { camera } from '@kit.CameraKit';
import { image } from '@kit.ImageKit';
import { Logger, SafeJson } from 'module_ui_base';

const TAG: string = '[CameraUtil]';

class CameraUtil {
  private cameraManager: camera.CameraManager | undefined = undefined;
  private cameras: Array<camera.CameraDevice> | Array<camera.CameraDevice> = [];
  private cameraInput: camera.CameraInput | undefined = undefined;
  private previewOutput: camera.PreviewOutput | undefined = undefined;
  private photoOutput: camera.PhotoOutput | undefined = undefined;
  private session: camera.PhotoSession | undefined = undefined;
  private curCameraDevice: camera.CameraDevice | undefined = undefined;
  // One of the recommended camera resolutions.
  private photoProfileObj: camera.Profile = {
    format: 2000,
    size: {
      width: 1920,
      height: 1080,
    },
  };
  // One of the recommended preview resolutions.
  private previewProfileObj: camera.Profile = {
    format: 1003,
    size: {
      width: 1920,
      height: 1080,
    },
  };
  private curSceneMode: camera.SceneMode = camera.SceneMode.NORMAL_PHOTO;

  setSceneMode(sceneMode: camera.SceneMode): void {
    this.curSceneMode = sceneMode;
  }

  getSceneMode(): camera.SceneMode {
    return this.curSceneMode;
  }

  getPreviewProfile(
    cameraOutputCapability: camera.CameraOutputCapability,
  ): camera.Profile | undefined {
    let previewProfiles = cameraOutputCapability.previewProfiles;
    if (previewProfiles.length < 1) {
      return undefined;
    }
    let index = previewProfiles.findIndex((previewProfile: camera.Profile) => {
      return (
        previewProfile.size.width === this.previewProfileObj.size.width &&
          previewProfile.size.height === this.previewProfileObj.size.height &&
          previewProfile.format === this.previewProfileObj.format
      );
    });
    if (index === -1) {
      return undefined;
    }
    return previewProfiles[index];
  }

  getPhotoProfile(
    cameraOutputCapability: camera.CameraOutputCapability,
  ): camera.Profile | undefined {
    let photoProfiles = cameraOutputCapability.photoProfiles;
    if (photoProfiles.length < 1) {
      return undefined;
    }
    let index = photoProfiles.findIndex((photoProfile: camera.Profile) => {
      return (
        photoProfile.size.width === this.photoProfileObj.size.width &&
          photoProfile.size.height === this.photoProfileObj.size.height &&
          photoProfile.format === this.photoProfileObj.format
      );
    });
    if (index === -1) {
      return undefined;
    }
    return photoProfiles[index];
  }

  isSupportedSceneMode(
    cameraManager: camera.CameraManager,
    cameraDevice: camera.CameraDevice,
  ): boolean {
    let sceneModes = cameraManager.getSupportedSceneModes(cameraDevice);
    if (sceneModes === undefined) {
      return false;
    }
    let index = sceneModes.findIndex((sceneMode: camera.SceneMode) => {
      return sceneMode === this.curSceneMode;
    });
    if (index === -1) {
      return false;
    }
    return true;
  }

  /**
   * Initialize camera function
   * @param surfaceId - Surface ID
   * @param cameraDeviceIndex - Camera device index
   * @returns No return value
   */
  async initCamera(
    surfaceId: string,
    baseContext: common.BaseContext,
    callback?: Function,
  ): Promise<void> {
    try {
      await this.releaseCamera();
      // Get Camera Manager instance.
      this.cameraManager = this.getCameraManagerFn(baseContext);
      if (this.cameraManager === undefined) {
        Logger.error(TAG, 'cameraManager is undefined');
        return;
      }
      // Get support for specified camera device objects.
      this.cameras = this.getSupportedCamerasFn(this.cameraManager);
      if (this.cameras.length < 1) {
        return;
      }
      this.curCameraDevice = this.cameras[0];
      let isSupported = this.isSupportedSceneMode(
        this.cameraManager,
        this.curCameraDevice,
      );
      if (!isSupported) {
        Logger.error(TAG, 'The current scene mode is not supported.');
        return;
      }
      let cameraOutputCapability =
        this.cameraManager.getSupportedOutputCapability(
          this.curCameraDevice,
          this.curSceneMode,
        );
      let previewProfile = this.getPreviewProfile(cameraOutputCapability);
      if (previewProfile === undefined) {
        Logger.error(
          TAG,
          'The resolution of the current preview stream is not supported.',
        );
        return;
      }
      this.previewProfileObj = previewProfile;
      // Create previewOutput output object.
      this.previewOutput = this.createPreviewOutputFn(
        this.cameraManager,
        this.previewProfileObj,
        surfaceId,
      );
      if (this.previewOutput === undefined) {
        Logger.error(TAG, 'Failed to create the preview stream.');
        return;
      }
      // Monitor preview events.
      this.previewOutputCallBack(this.previewOutput);
      if (this.curSceneMode === camera.SceneMode.NORMAL_PHOTO) {
        let photoProfile = this.getPhotoProfile(cameraOutputCapability);
        if (photoProfile === undefined) {
          Logger.error(
            TAG,
            'The resolution of the current photo stream is not supported.',
          );
          return;
        }
        this.photoProfileObj = photoProfile;
        // Create photoOutput output object.
        this.photoOutput = this.createPhotoOutputFn(
          this.cameraManager,
          this.photoProfileObj,
        );
        if (this.photoOutput === undefined) {
          Logger.error(TAG, 'Failed to create the photo stream.');
          return;
        }
      }
      // Create cameraInput output object.
      this.cameraInput = this.createCameraInputFn(
        this.cameraManager,
        this.curCameraDevice,
      );
      if (this.cameraInput === undefined) {
        Logger.error(TAG, 'Failed to create the camera input.');
        return;
      }
      // Open the camera.
      let isOpenSuccess = await this.cameraInputOpenFn(this.cameraInput);
      if (!isOpenSuccess) {
        Logger.error(TAG, 'Failed to open the camera.');
        return;
      }
      // Camera status callback.
      this.onCameraStatusChange(this.cameraManager);
      // Monitor error events from CameraInput.
      this.onCameraInputChange(this.cameraInput, this.curCameraDevice);
      // Conversation process.
      await this.sessionFlowFn(
        this.cameraManager,
        this.cameraInput,
        this.previewOutput,
        this.photoOutput,
        callback,
      );
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `initCamera fail: ${SafeJson.jsonStringify(err)}`);
    }
  }

  /**
   * Trigger a photo with specified parameters.
   */
  async takePicture(): Promise<void> {
    try {
      Logger.info(TAG, 'takePicture start');
      let photoSettings: camera.PhotoCaptureSetting = {
        quality: camera.QualityLevel.QUALITY_LEVEL_HIGH,
        mirror: false,
      };
      await this.photoOutput?.capture(photoSettings);
    } catch (err) {
      Logger.error(TAG, 'take picture failed. error:' + SafeJson.jsonStringify(err));
    }
    Logger.info(TAG, 'takePicture end');
  }

  /**
   * Release the session and its related parameters.
   */
  async releaseCamera(): Promise<void> {
    Logger.info(TAG, 'releaseCamera is called');
    try {
      await this.previewOutput?.release();
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(
        TAG,
        `previewOutput release fail: error: ${SafeJson.jsonStringify(err)}`,
      );
    } finally {
      this.previewOutput = undefined;
    }
    try {
      await this.photoOutput?.release();
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(
        TAG,
        `photoOutput release fail: error: ${SafeJson.jsonStringify(err)}`,
      );
    } finally {
      this.photoOutput = undefined;
    }

    try {
      await this.session?.release();
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(
        TAG,
        `captureSession release fail: error: ${SafeJson.jsonStringify(err)}`,
      );
    } finally {
      this.session = undefined;
    }
    try {
      await this.cameraInput?.close();
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(
        TAG,
        `cameraInput close fail: error: ${SafeJson.jsonStringify(err)}`,
      );
    } finally {
      this.cameraInput = undefined;
    }
    this.offCameraStatusChange();
    Logger.info(TAG, 'releaseCamera success');
  }

  /**
   * Get Camera Manager instance.
   */
  getCameraManagerFn(
    baseContext: common.BaseContext,
  ): camera.CameraManager | undefined {
    if (this.cameraManager) {
      return this.cameraManager;
    }
    let cameraManager: camera.CameraManager | undefined = undefined;
    try {
      cameraManager = camera.getCameraManager(baseContext);
      Logger.info(TAG, `getCameraManager success: ${cameraManager}`);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `getCameraManager failed: ${SafeJson.jsonStringify(err)}`);
    }
    return cameraManager;
  }

  /**
   * Get support for specified camera device objects.
   */
  getSupportedCamerasFn(
    cameraManager: camera.CameraManager,
  ): Array<camera.CameraDevice> {
    let supportedCameras: Array<camera.CameraDevice> = [];
    try {
      supportedCameras = cameraManager.getSupportedCameras();
      Logger.info(
        TAG,
        `getSupportedCameras success: ${this.cameras}, length: ${this.cameras?.length}`,
      );
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `getSupportedCameras failed: ${SafeJson.jsonStringify(err)}`);
    }
    return supportedCameras;
  }

  /**
   * Create previewOutput output object.
   */
  createPreviewOutputFn(
    cameraManager: camera.CameraManager,
    previewProfileObj: camera.Profile,
    surfaceId: string,
  ): camera.PreviewOutput | undefined {
    let previewOutput: camera.PreviewOutput | undefined = undefined;
    try {
      previewOutput = cameraManager.createPreviewOutput(
        previewProfileObj,
        surfaceId,
      );
      Logger.info(TAG, `createPreviewOutput success: ${previewOutput}`);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `createPreviewOutput failed: ${SafeJson.jsonStringify(err)}`);
    }
    return previewOutput;
  }

  /**
   * Create photoOutPut output object.
   */
  createPhotoOutputFn(
    cameraManager: camera.CameraManager,
    photoProfileObj: camera.Profile,
  ): camera.PhotoOutput | undefined {
    let photoOutput: camera.PhotoOutput | undefined = undefined;
    try {
      photoOutput = cameraManager.createPhotoOutput(photoProfileObj);
      Logger.info(TAG, `createPhotoOutputFn success: ${photoOutput}`);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `createPhotoOutputFn failed: ${SafeJson.jsonStringify(err)}`);
    }
    return photoOutput;
  }

  /**
   * Create cameraInput output object.
   */
  createCameraInputFn(
    cameraManager: camera.CameraManager,
    cameraDevice: camera.CameraDevice,
  ): camera.CameraInput | undefined {
    Logger.info(TAG, 'createCameraInputFn is called.');
    let cameraInput: camera.CameraInput | undefined = undefined;
    try {
      cameraInput = cameraManager.createCameraInput(cameraDevice);
      Logger.info(TAG, 'createCameraInputFn success');
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `createCameraInputFn failed: ${SafeJson.jsonStringify(err)}`);
    }
    return cameraInput;
  }

  /**
   * Open the camera.
   */
  async cameraInputOpenFn(cameraInput: camera.CameraInput): Promise<boolean> {
    let isOpenSuccess = false;
    try {
      await cameraInput.open();
      isOpenSuccess = true;
      Logger.info(TAG, 'cameraInput open success');
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `createCameraInput failed : ${SafeJson.jsonStringify(err)}`);
    }
    return isOpenSuccess;
  }

  /**
   * Conversation process.
   */
  async sessionFlowFn(
    cameraManager: camera.CameraManager,
    cameraInput: camera.CameraInput,
    previewOutput: camera.PreviewOutput,
    photoOutput: camera.PhotoOutput | undefined,
    callback?: Function,
  ): Promise<void> {
    try {
      if (this.curSceneMode === camera.SceneMode.NORMAL_PHOTO) {
        this.session = cameraManager.createSession(
          this.curSceneMode,
        ) as camera.PhotoSession;
      }
      if (this.session === undefined) {
        return;
      }
      this.onSessionErrorChange(this.session);
      this.session.beginConfig();
      this.session.addInput(cameraInput);
      this.session.addOutput(previewOutput);
      if (this.curSceneMode === camera.SceneMode.NORMAL_PHOTO) {
        if (photoOutput === undefined) {
          return;
        }
        this.photoOutputCallBack(photoOutput, callback);
        this.session.addOutput(photoOutput);
      }
      await this.session.commitConfig();

      this.setFocusMode(camera.FocusMode.FOCUS_MODE_AUTO);
      await this.session.start();
      Logger.info(TAG, 'sessionFlowFn success');
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `sessionFlowFn fail : ${SafeJson.jsonStringify(err)}`);
    }
  }

  /**
   * Monitoring and photography events.
   */
  photoOutputCallBack(
    photoOutput: camera.PhotoOutput,
    callback?: Function,
  ): void {
    try {
      photoOutput.on(
        'captureStartWithInfo',
        (
          _err: BusinessError,
          captureStartInfo: camera.CaptureStartInfo,
        ): void => {
          Logger.info(
            TAG,
            `photoOutputCallBack captureStartWithInfo success: ${JSON.stringify(captureStartInfo)}`,
          );
        },
      );
      photoOutput.on(
        'frameShutter',
        (
          _err: BusinessError,
          frameShutterInfo: camera.FrameShutterInfo,
        ): void => {
          Logger.info(
            TAG,
            `photoOutputCallBack frameShutter captureId:
          ${frameShutterInfo.captureId}, timestamp: ${frameShutterInfo.timestamp}`,
          );
        },
      );
      photoOutput.on(
        'captureEnd',
        (_err: BusinessError, captureEndInfo: camera.CaptureEndInfo): void => {
          Logger.info(
            TAG,
            `photoOutputCallBack captureEnd captureId:
          ${captureEndInfo.captureId}, frameCount: ${captureEndInfo.frameCount}`,
          );
        },
      );
      photoOutput.on('error', (data: BusinessError): void => {
        Logger.info(TAG, `photoOutPut data: ${JSON.stringify(data)}`);
      });
      photoOutput.on(
        'photoAvailable',
        async (errCode: BusinessError, photo: camera.Photo): Promise<void> => {
          Logger.info(TAG, 'photoAvailable begin');
          if (errCode || photo === undefined) {
            console.error('getPhoto failed');
            return;
          }
          let imageObj = photo.main;
          imageObj.getComponent(
            image.ComponentType.JPEG,
            async (
              errCode: BusinessError,
              component: image.Component,
            ): Promise<void> => {
              console.info('getComponent start');
              if (errCode || component === undefined || !component.byteBuffer) {
                Logger.error(TAG, 'getComponent buffer failed');
                return;
              }

              const imageSource: image.ImageSource = image.createImageSource(
                component.byteBuffer,
              );

              class SizeTmp {
                height: number = 100;
                width: number = 100;
              }

              let options: Record<string, number | boolean | SizeTmp> = {
                'alphaType': 0,
                'editable': false,
                'pixelFormat': 3,
                'scaleMode': 1,
                'size': { height: 100, width: 100 },
              };
              imageSource
                .createPixelMap(options)
                .then((pixelMap: PixelMap) => {
                  Logger.info(TAG, 'image createPixelMap success');
                  AppStorage.setOrCreate('imageMap', pixelMap);
                  callback?.(); // 跳转识图结果页面
                })
                .catch((error: BusinessError) => {
                  Logger.error(
                    TAG,
                    `Failed to create pixelmap. code is ${error.code}, message is ${error.message}`,
                  );
                });
              // buffer处理结束后需要释放该资源，如果未正确释放资源会导致后续拍照获取不到buffer
              imageObj.release();
            },
          );
          this.releaseCamera();
        },
      );
    } catch (err) {
      Logger.error(TAG, 'photoOutputCallBack error');
    }
  }

  /**
   * Monitor preview events.
   */
  previewOutputCallBack(previewOutput: camera.PreviewOutput): void {
    Logger.info(TAG, 'previewOutputCallBack is called');
    try {
      previewOutput.on('frameStart', (): void => {
        Logger.debug(TAG, 'Preview frame started');
      });
      previewOutput.on('frameEnd', (): void => {
        Logger.debug(TAG, 'Preview frame ended');
      });
      previewOutput.on('error', (previewOutputError: BusinessError): void => {
        Logger.info(
          TAG,
          `Preview output previewOutputError: ${JSON.stringify(previewOutputError)}`,
        );
      });
    } catch (err) {
      Logger.error(TAG, 'previewOutputCallBack error');
    }
  }

  /**
   * Callback function for registering camera status changes.
   * @param err
   * @param cameraStatusInfo
   * @returns
   */
  registerCameraStatusChange(
    _err: BusinessError,
    cameraStatusInfo: camera.CameraStatusInfo,
  ): void {
    Logger.info(
      TAG,
      `cameraId: ${cameraStatusInfo.camera.cameraId},status: ${cameraStatusInfo.status}`,
    );
  }

  /**
   * Monitor camera status changes.
   * @param cameraManager
   * @returns
   */
  onCameraStatusChange(cameraManager: camera.CameraManager): void {
    Logger.info(TAG, 'onCameraStatusChange is called');
    try {
      cameraManager.on('cameraStatus', this.registerCameraStatusChange);
    } catch (error) {
      Logger.error(TAG, 'onCameraStatusChange error');
    }
  }

  /**
   * Stop monitoring camera status changes.
   * @returns
   */
  offCameraStatusChange(): void {
    Logger.info(TAG, 'offCameraStatusChange is called');
    this.cameraManager?.off('cameraStatus', this.registerCameraStatusChange);
  }

  /**
   * Monitor camera input changes.
   * @param cameraInput
   * @param cameraDevice
   * @returns
   */
  onCameraInputChange(
    cameraInput: camera.CameraInput,
    cameraDevice: camera.CameraDevice,
  ): void {
    Logger.info(TAG, `onCameraInputChange is called`);
    try {
      cameraInput.on(
        'error',
        cameraDevice,
        (cameraInputError: BusinessError): void => {
          Logger.info(
            TAG,
            `onCameraInputChange cameraInput error code: ${cameraInputError.code}`,
          );
        },
      );
    } catch (error) {
      Logger.error(TAG, 'onCameraInputChange error');
    }
  }

  /**
   * @param session
   * @returns
   */
  onSessionErrorChange(session: camera.PhotoSession): void {
    try {
      session.on('error', (captureSessionError: BusinessError): void => {
        Logger.info(
          TAG,
          'onCaptureSessionErrorChange captureSession fail: ' +
          JSON.stringify(captureSessionError.code),
        );
      });
    } catch (error) {
      Logger.error(TAG, 'onCaptureSessionErrorChange error');
    }
  }

  setFocusMode(focusMode: camera.FocusMode): void {
    Logger.info(TAG, `setFocusMode is called`);
    try {
      let isSupported = this.session?.isFocusModeSupported(focusMode);
      Logger.info(TAG, `setFocusMode isSupported: ${isSupported}`);
      if (!isSupported) {
        return;
      }
      this.session?.setFocusMode(focusMode);
    } catch (err) {
      Logger.error(TAG, 'set focus mode failed. error:' + SafeJson.jsonStringify(err));
    }
  }
}

const util = new CameraUtil();

export { util as CameraUtil };
