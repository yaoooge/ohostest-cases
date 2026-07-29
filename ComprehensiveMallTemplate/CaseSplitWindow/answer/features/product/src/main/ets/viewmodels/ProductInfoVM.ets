import { calendarManager } from '@kit.CalendarKit';
import { AbilityConstant, StartOptions, Want } from '@kit.AbilityKit';
import {
  CalendarUtil,
  CountdownModel,
  iData,
  ProductInfoPageParam,
  RouterMap,
  routerStack,
  SafeJson,
  WindowUtil,
} from 'lib_foundation';
import {
  ProductApis,
  ProductInfo,
  ProductReviewItem,
  SeckillApis,
  SeckillProductInfo,
  SeckillReserveReq,
  SeckillTimeSlot,
} from 'lib_network';
import { CommonConfirmDialog, CustomServiceSheet } from 'lib_widget';
import { UtilLog } from '@hw-agconnect/util-log';
import { window } from '@kit.ArkUI';

const TAG: string = '[ProductInfoVM]'

@ObservedV2
export class ProductInfoVM {
  @Trace
  productId: string = '';
  @Trace
  slotId?: string = undefined;
  @Trace
  productInfo?: ProductInfo;
  @Trace
  collectedStatus: boolean = false;
  @Trace
  reviewList: ProductReviewItem[] = [];
  @Trace
  reviewNum: number = 0;
  @Trace
  isLoading: boolean = false;
  @Trace
  isReserved: boolean = false;
  @Trace
  countdown?: CountdownModel;
  @Trace
  currentEventId?: number;
  curWindow?: window.Window
  abilityName: string = '';
  private _windowActiveCallback?: (type: WindowStatusType) => void

  @Computed
  get isSplitScreen(): boolean {
    return routerStack.isSplitActive;
  }

  @Computed
  get isLogin() {
    return iData.global.isLogin;
  }

  @Computed
  get cartNum() {
    return iData.global.cartTotal;
  }

  @Computed
  get reserveButtonLabel() {
    if (this.isReserved) {
      return '已预约';
    }
    if (this.productInfo?.seckillInfo && this.productInfo.timeSlot) {
      let str = '';
      if (this.productInfo.seckillInfo.slotId.includes('tomorrow')) {
        str += '明日';
      }
      return '预约' + str + this.productInfo.timeSlot.startTime + '开抢';
    }
    return '';
  }


  public async initData(param: ProductInfoPageParam, abilityName: string = 'EntryAbility') {
    this.abilityName = abilityName;
    this.productId = param.productId;
    this.slotId = param.slotId;
    this.isLoading = true;
    try {
      await this.getProductInfo();
      await this._getReviewList();
      this._getCollectedStatus();
      ProductApis.addProductViewHistory({
        productId: this.productId,
        slotId: this.slotId,
      });
    } catch (err) {
      UtilLog.error('init product info failed. error: ' + JSON.stringify(err))
    } finally {
      this.isLoading = false;
    }
  }

  public handleClickCustomService() {
    CustomServiceSheet.show();
  }

  public handleClickCart() {
    routerStack.pushPath({ name: RouterMap.PRODUCT_CART });
  }

  public handleClickReview() {
    routerStack.pushPath({ name: RouterMap.PRODUCT_REVIEW, param: this.productId });
  }

  public async changeCollectStatus() {
    if (!this.collectedStatus) {
      const res = await ProductApis.collectProduct({
        productId: this.productId,
        slotId: this.slotId,
      });
      if (res.code === 0) {
        WindowUtil.toast('收藏商品成功！');
        this.collectedStatus = true;
      }
    } else {
      CommonConfirmDialog.show({
        content: '是否确认取消收藏该商品？',
        confirm: async () => {
          const res = await ProductApis.cancelCollectProduct([this.productId]);
          if (res.code === 0) {
            WindowUtil.toast('取消收藏成功！');
            this.collectedStatus = false;
          }
        },
      });
    }
  }

  public async startSplitScreen(): Promise<void> {
    const context = WindowUtil.globalUIAbilityContext;
    const want: Want = {
      bundleName: context.abilityInfo.bundleName,
      abilityName: 'SecondAbility',
    };
    const option: StartOptions = {
      windowMode: AbilityConstant.WindowMode.WINDOW_MODE_SPLIT_SECONDARY,
    };
    try {
      await context.startAbility(want, option);
      routerStack.isSplitActive = true;
    } catch (err) {
      UtilLog.error(TAG, 'split window failed. error: ' + SafeJson.jsonStringify(err))
    }
  }

  public async mergeSplitScreen(): Promise<void> {
    if (!this.isSplitScreen) {
      return;
    }
    if (this.abilityName === 'EntryAbility') {
      routerStack.migrateStack('SecondAbility', 'EntryAbility');
      routerStack.isSplitActive = false;
      const secondCtx = WindowUtil.getUIAbilityContext('SecondAbility');
      try {
        await secondCtx?.terminateSelf();
      } catch (err) {
        UtilLog.error(TAG, 'terminate SecondAbility failed. error: ' + SafeJson.jsonStringify(err));
      }
    } else {
      const secondCtx = WindowUtil.getUIAbilityContext('SecondAbility');
      try {
        await secondCtx?.terminateSelf();
      } catch (err) {
        UtilLog.error(TAG, 'terminate self failed. error: ' + SafeJson.jsonStringify(err));
      }
    }
  }

  public handleClickReserveButton() {
    if (!this.productInfo?.seckillInfo || !this.productInfo.timeSlot) {
      return;
    }
    if (this.isReserved) {
      this._removeCalendarEvent();
    } else {
      this._addCalendarEvent(this.productInfo.seckillInfo, this.productInfo.timeSlot);
    }
  }

  /**
   * 添加日程
   * @param product
   * @param timeslot
   */
  private async _addCalendarEvent(product: SeckillProductInfo, timeslot: SeckillTimeSlot) {
    const event: calendarManager.Event = {
      title: '您预约的限时秒杀即将开抢！' + product.title,
      type: calendarManager.EventType.NORMAL,
      startTime: timeslot.startTimestamp,
      endTime: timeslot.endTimestamp,
      reminderTime: [5],
      description: `限时秒杀即将开抢！`,
    };

    const eventId = await CalendarUtil.addEvent(event);
    if (eventId && typeof eventId === 'number') {
      this.currentEventId = eventId;
      WindowUtil.toast('商品预约成功！可以在日历中查看预约详情~');
      const param: SeckillReserveReq = {
        productId: product.productId,
        slotId: product.slotId,
        eventId,
      };
      SeckillApis.reserveSeckill(param).then(() => {
        this._getReservedStatus();
      });
    }

  }

  /**
   * 移除日程
   * @param product
   * @param timeslot
   */
  private async _removeCalendarEvent() {
    if (!this.currentEventId) {
      return;
    }
    const res = await CalendarUtil.deleteEvent(this.currentEventId);
    if (res) {
      WindowUtil.toast('取消预约成功！');
      await SeckillApis.cancelReservation(this.currentEventId);
      this._getReservedStatus();
    }
  }


  private async _getReviewList() {
    const res = await ProductApis.getProductReviewList(this.productId, 1);
    this.reviewList = res.list.slice(0, 2);
    this.reviewNum = res.total;
  }

  public async getProductInfo() {
    const res = await ProductApis.getProductDetail(this.productId, this.slotId);
    if (res.code === 0) {
      this.productInfo = res.data;
      this._getReservedStatus();
    }
  }

  private async _getReservedStatus() {
    if (this.productInfo?.seckillInfo && this.productInfo.timeSlot) {
      const res = await SeckillApis.getReservationStatus({
        productId: this.productInfo.seckillInfo.productId,
        slotId: this.productInfo.seckillInfo.slotId,
      });
      if (res.code === 0) {
        this.isReserved = res.isReserved;
        this.currentEventId = res.eventId;
      }
      if (this.isReserved) {
        this.countdown = new CountdownModel(this.productInfo.timeSlot.startTimestamp);
        this.countdown.startCountdownTimer();
      }
    }
  }

  private async _getCollectedStatus() {
    const res = await ProductApis.getProductCollectStatus(this.productId);
    if (res.code === 0 && res.status) {
      this.collectedStatus = true;
    }
  }

  public registerWindowActiveListener(): void {
    if (this.abilityName !== 'EntryAbility') {
      return;
    }
    this._windowActiveCallback = (statusType: window.WindowStatusType) => {
      if (statusType === window.WindowStatusType.FULL_SCREEN) {
        routerStack.isSplitActive = false;
      }
    };
    window.getLastWindow(WindowUtil.globalContext).then((win) => {
      this.curWindow = win;
      try {
        win.on('windowStatusChange', this._windowActiveCallback!)
      } catch (err) {
        UtilLog.error(TAG, 'set window status change listener failed. error:' + SafeJson.jsonStringify(err))
      }
    }).catch((err: BusinessError) => {
      UtilLog.error(TAG, 'get last window failed. error:' + SafeJson.jsonStringify(err))
    })
  }

  public unregisterWindowActiveListener(): void {
    if (this.curWindow && this._windowActiveCallback) {
      try {
        this.curWindow.off('windowStatusChange', this._windowActiveCallback);
      } catch (err) {
        UtilLog.error(TAG, 'remove window status change listener. error:' + SafeJson.jsonStringify(err))
      }
      this._windowActiveCallback = undefined;
    }
  }
}
