import { BusinessError } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { Logger } from 'module_ui_base';
import { LOG_TAG } from '../commons/Constants';

class AlbumUtil {
  public static selectPicture(callback: Function) {
    // 通过选择模式拉起photoPicker界面，用户可以选择一个图片
    let photoOption = new photoAccessHelper.PhotoSelectOptions();
    photoOption.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    photoOption.maxSelectNumber = 1;
    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    photoPicker.select(photoOption)
      .then((result) => {
        callback(result);
      }).catch((err: BusinessError) => {
      Logger.error(LOG_TAG, 'select photo failed. error:' + JSON.stringify(err));
    });
  }
}

export { AlbumUtil };
