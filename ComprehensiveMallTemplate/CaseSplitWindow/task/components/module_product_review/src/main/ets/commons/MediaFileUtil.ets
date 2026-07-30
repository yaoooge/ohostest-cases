import { common } from '@kit.AbilityKit';
import { dataSharePredicates } from '@kit.ArkData';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { Logger, SafeJson } from 'module_ui_base';
import { Constants } from './Constants';
import { ReviewMediaType } from './Enums';
import { SkuReviewModel } from './Models';

const TAG: string = '[MediaFileUtil]';

export class MediaFileUtil {
  private static _context: Context;

  public static getMediaFromAlbum(model: SkuReviewModel, uiContext: UIContext) {
    MediaFileUtil._context = uiContext.getHostContext() as Context;
    let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    photoSelectOptions.maxSelectNumber = Constants.MAX_MEDIA_LENGTH - model.mediaList.length;
    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    return photoPicker.select(photoSelectOptions).then((photoSelectResult) => {
      if (photoSelectResult !== null && photoSelectResult !== undefined) {
        photoSelectResult.photoUris.forEach(async (uri) => {
          await MediaFileUtil.handlePhotoSource(model, uri);
        });
      }
      Logger.info(TAG, 'PhotoViewPicker.select successfully, PhotoSelectResult uri: ' +
      JSON.stringify(model.mediaList));
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `PhotoViewPicker select failed, code is ${err.code}, message is ${err.message}.`);
    });
  }

  public static async handlePhotoSource(model: SkuReviewModel, uri: string) {
    let context: Context = MediaFileUtil._context as common.UIAbilityContext;
    let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
    let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    predicates.equalTo(photoAccessHelper.PhotoKeys.URI, uri);
    let fetchOption: photoAccessHelper.FetchOptions = {
      fetchColumns: [],
      predicates: predicates,
    };
    try {
      let fetchResult: photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset> =
        await phAccessHelper.getAssets(fetchOption);
      let photoAsset: photoAccessHelper.PhotoAsset = await fetchResult.getFirstObject();
      await photoAccessHelper.MediaAssetManager.requestMovingPhoto(context, photoAsset, {
        deliveryMode: photoAccessHelper.DeliveryMode.FAST_MODE,
      }, {
        async onDataPrepared(movingPhoto: photoAccessHelper.MovingPhoto) {
          if (movingPhoto !== undefined) {
            Logger.info('request moving photo successfully, uri: ' + movingPhoto.getUri());
            try {
              const srcPath = 'file://' + MediaFileUtil._context.filesDir + '/moving_photo_' + new Date().getTime();
              let imageUri = srcPath + '.jpg';
              let videoUri = srcPath + '.mp4';
              await movingPhoto.requestContent(imageUri, videoUri); // 将动态照片导出到应用沙箱。
              model.mediaList.push({
                type: ReviewMediaType.MOVING_PHOTO,
                uri,
                movingPhotoUri: {
                  imageUri,
                  videoUri,
                },
              });
            } catch (err) {
              console.error(`request content of moving photo failed with error: ${err.code}, ${err.message}`);
            }
          }
        },
      });
    } catch (error) {
      model.mediaList.push({
        type: ReviewMediaType.IMAGE,
        uri,
      });
      Logger.error(TAG, 'request moving photo failed. error:' + SafeJson.jsonStringify(error));
    }
  }
}