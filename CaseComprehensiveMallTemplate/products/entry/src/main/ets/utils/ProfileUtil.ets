import { RouterMap, routerStack } from 'lib_foundation';
import { CustomServiceSheet } from 'lib_widget';
import { NoticeRouterMap } from 'module_notice_center';
import { MainMenuOption, SubMenuOption } from '../commons/Enums';
import { MainMenuItem, SubMenuItem } from '../commons/Types';

export class ProfileUtil {
  public static readonly MAIN_MENU_LIST: MainMenuItem[] = [
    {
      type: MainMenuOption.COLLECTION,
      icon: $r('app.media.ic_mine_collection'),
      label: '我的收藏',
    },
    {
      type: MainMenuOption.MESSAGE,
      icon: $r('app.media.ic_mine_message'),
      label: '我的消息',
    },
  ];
  public static readonly SUB_MENU_LIST: SubMenuItem[] = [
    {
      type: SubMenuOption.VIEW_HISTORY,
      icon: $r('sys.symbol.arrow_counterclockwise_clock'),
      label: '浏览历史',
    },
    {
      type: SubMenuOption.CUSTOM_SERVICE,
      icon: $r('sys.symbol.service'),
      label: '联系客服',
    },
  ];

  public static handleMainMenuClick(menu: MainMenuOption) {
    switch (menu) {
      case MainMenuOption.COLLECTION:
        routerStack.pushPath({ name: RouterMap.USER_COLLECTION });
        break;
      case MainMenuOption.MESSAGE:
        routerStack.pushPath({ name: NoticeRouterMap.NOTICE_CENTER });
        break;
      default:
        break;
    }
  }

  public static handleSubMenuClick(menu: SubMenuOption) {
    switch (menu) {
      case SubMenuOption.VIEW_HISTORY:
        routerStack.pushPath({ name: RouterMap.USER_VIEW_HISTORY });
        break;
      case SubMenuOption.CUSTOM_SERVICE:
        CustomServiceSheet.show();
        break;
      default:
        break;
    }
  }
}
