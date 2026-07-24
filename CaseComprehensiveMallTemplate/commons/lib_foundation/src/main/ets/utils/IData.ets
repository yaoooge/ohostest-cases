import { util } from '@kit.ArkTS';
import { PersistenceV2 } from '@kit.ArkUI';
import { UserInfoModel } from '../models/UserInfoModel';

@ObservedV2
export class GlobalStateMgr {
  @Trace
  public rootPageActiveTabId: string = '';
  @Trace
  public isNavPathStackEmpty: boolean = true;
  @Trace
  public cartVersion: string = util.generateRandomUUID(false);
  @Trace
  public cartTotal: number = 0;
  @Trace
  public isLogin: boolean = false;
  @Trace
  public userInfo: UserInfoModel = new UserInfoModel();
}

class IData {
  public get global() {
    return PersistenceV2.connect(
      GlobalStateMgr,
      'GlobalStateMgr',
      () => new GlobalStateMgr(),
    )!;
  }
}

const iData = new IData();

export function ensureDefaultUserState(): void {
  iData.global.isLogin = true;
  if (!iData.global.userInfo.phone) {
    iData.global.userInfo.nickname = '华为用户';
    iData.global.userInfo.phone = '12345678900';
    iData.global.userInfo.anonymousPhone = '123****8900';
    iData.global.userInfo.avatar = '';
    iData.global.userInfo.isMember = false;
  }
}

export { iData };
