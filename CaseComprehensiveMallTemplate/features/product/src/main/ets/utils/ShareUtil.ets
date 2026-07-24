import { Context } from '@kit.AbilityKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { harmonyShare, systemShare } from '@kit.ShareKit';
import { FileUtil, SafeJson } from 'lib_foundation';
import { ProductDetailInfo } from 'lib_network';
import { UtilLog } from '@hw-agconnect/util-log';

const TAG: string = '[ShareUtil]';

export class ShareUtil {
  private static _context: Context;
  private static _shareData: systemShare.SharedData;

  public static registerGestureShare(uiContext: UIContext) {
    ShareUtil._context = uiContext.getHostContext() as Context;
    ShareUtil._immersiveListening();
    ShareUtil._context.eventHub.on('onBackground', ShareUtil._onBackGround);
  }

  public static unregisterGestureShare() {
    ShareUtil._immersiveDisablingListening();
    ShareUtil._context.eventHub.off('onBackGround', ShareUtil._onBackGround);
  }

  public static async initShareData(data: ProductDetailInfo) {
    const thumbnailUri: string = await ShareUtil._getThumbnail(data.banners[0] as string);
    ShareUtil._shareData = new systemShare.SharedData({
      utd: utd.UniformDataType.HYPERLINK,
      content: ShareUtil.getShareLink(data.productId),
      thumbnailUri,
      title: data.title,
    });
  }

  public static getShareLink(id: string) {
    return `https://linking.xiaobingtang.cn/comprehensive-mall/productId=${id}`;
  }

  private static async _getThumbnail(url: string): Promise<string> {
    let thumbUri: string = '';
    try {
      const buffer = await FileUtil.downloadImage(url);
      thumbUri = await FileUtil.saveToSandbox(buffer);
    } catch (err) {
      UtilLog.error(TAG, 'get thumbUri failed. error:' + SafeJson.jsonStringify(err));
    }

    return thumbUri;
  }

  private static _immersiveCallback = (sharableTarget: harmonyShare.SharableTarget) => {
    sharableTarget.share(ShareUtil._shareData);
  };

  private static _immersiveListening() {
    harmonyShare.on('gesturesShare', ShareUtil._immersiveCallback);
  }

  private static _immersiveDisablingListening() {
    harmonyShare.off('gesturesShare', ShareUtil._immersiveCallback);
  }

  private static _onBackGround = () => {
    ShareUtil._immersiveDisablingListening();
  };
}