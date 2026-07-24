import { image } from '@kit.ImageKit';

export interface CustomScanOptions {
  /** 是否支持多码识别 */
  enableMultiMode?: boolean;
  /**  是否支持相册 */
  enableAlbum?: boolean;
  /**  处理扫码结果 */
  handleScanResult?: (code: string) => void;
  /**  处理拍照结果 */
  handlePhotoResult?: (image: image.PixelMap | Resource | string) => void;
}
