import { LengthMetrics } from '@kit.ArkUI';
import {
  iData, routerStack, RouterMap, BreakpointSystem, BreakpointTypeEnum,
} from 'lib_foundation';
import { ContainerColumn, NavTitleBar } from 'lib_widget';
import { MainMenuOption, SubMenuOption } from '../commons/Enums';
import { MainMenuItem, SubMenuItem } from '../commons/Types';
import { ProfileUtil } from '../utils/ProfileUtil';

@Builder
export function buildProfilePage() {
  ProfilePage();
}

@ComponentV2
export struct ProfilePage {
  build() {
    Column() {
      NavTitleBar({
        title: '我的',
      })

      Scroll() {
        Column({ space: 12 }) {
          if (BreakpointSystem.currentBreakpoint.value === BreakpointTypeEnum.LG) {
            Flex({ space: { main: LengthMetrics.vp(16) } }) {
              Column() {
                buildUserInfoArea()
              }
              .tabletContainerStyle()

              Column() {
                buildCheckInArea()
                buildMainMenuArea()
              }
              .id('mall-profile-checkin-menu-area')
              .height(128)
              .justifyContent(FlexAlign.SpaceBetween)
            }
          } else {
            buildUserInfoArea()
            buildCheckInArea()
            buildMainMenuArea()
          }

          buildOrderInfoArea()
          buildSubMenuArea()
        }
        .margin({ bottom: 100 })
      }
      .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .layoutWeight(1)
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
      .padding({ left: $r('app.float.space_l'), right: $r('app.float.space_l') })
    }
    .height('100%')
    .width('100%')
    .linearGradient({
      colors: [['#33e64566', 0], ['#00E64566', 0.4]],
    })
    .backgroundColor($r('app.color.background_color_grey'))
    .alignItems(HorizontalAlign.Start)
    .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .transition(TransitionEffect.OPACITY.animation({ duration: 600 }))
  }
}

@Builder
function buildUserInfoArea() {
  ContainerColumn({ bottomGap: false }) {
    Row() {
      Image(iData.global.userInfo.avatar ? iData.global.userInfo.avatar : $r('app.media.default_avatar'))
        .width(48)
        .height(48)
        .backgroundColor(Color.White)
        .borderRadius(48)
        .draggable(false)
        .margin({ right: 16 });
      Column() {
        Row() {
          Text(iData.global.userInfo.nickname ? iData.global.userInfo.nickname : '华为用户')
            .fontWeight(FontWeight.Medium)
            .fontSize(18)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .textAlign(TextAlign.Start)
            .fontColor($r('app.color.font_color_level1'))
            .margin({ right: 8 })
        }.alignItems(VerticalAlign.Top)

        Row() {
          Image($r('app.media.ic_mobile_phone'))
            .commonIconStyle()
            .margin({ right: 8 });
          Text(iData.global.userInfo.anonymousPhone).commonLabelStyle();
        }
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center);
      }
      .layoutWeight(1)
      .height(48)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceAround);
    }
    .id('mall-profile-user-area')
  }
}

@Builder
function buildCheckInArea() {
  ContainerColumn({ bottomGap: false }) {
    Row() {
      Image($r('app.media.ic_checkmark_calendar_fill'))
        .margin({ right: $r('app.float.space_xs') })
        .width(16)
        .height(16)
        .fillColor($r('app.color.font_color_level2'))
      Text('签到可领取积分兑换好物')
        .id('mall-points-entry')
        .fontSize($r('app.float.font_size_14'))
        .fontColor($r('app.color.font_color_level1'))
        .layoutWeight(1)
      Image($r('app.media.ic_arrow_right')).commonIconStyle()
    }
    .width($r('app.string.size_percent_full'))
    .onClick(() => {
      routerStack.pushPath({ name: RouterMap.POINTS_MALL })
    })
    .id('mall-profile-checkin-area')
  }
}

@Builder
function buildMainMenuArea() {
  Row() {
    ForEach(ProfileUtil.MAIN_MENU_LIST, (item: MainMenuItem) => {
      Column() {
        Image(item.icon)
          .width(40)
          .height(40)
        Text(item.label).commonLabelStyle()
      }
      .id(item.type === MainMenuOption.COLLECTION ? 'mall-collection-entry' : 'mall-profile-main-menu-item')
      .onClick(() => {
        ProfileUtil.handleMainMenuClick(item.type)
      })
    }, (item: MainMenuItem) => item.label)
  }
  .id('mall-profile-main-menu-area')
  .containerStyle()
  .justifyContent(BreakpointSystem.currentBreakpoint.value === BreakpointTypeEnum.SM ?
    FlexAlign.SpaceBetween :
    FlexAlign.SpaceAround)
}

@Builder
function buildOrderInfoArea() {
  Column() {
    Row() {
      Text('我的订单')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.font_color_level1'));
      Blank();
      Text('全部').commonLabelStyle().margin({ right: 4 }).fontColor($r('app.color.font_color_level2'))
      Image($r('app.media.ic_arrow_right')).commonIconStyle();
    }
    .id('mall-order-entry')
    .onClick(() => {
      routerStack.pushPathByName(RouterMap.ORDER_LIST, 0);
    })
    .width('100%')
    .margin({ bottom: 16 });

    Row() {
      buildOrderTab($r('app.media.ic_order_pending_payment'), '待付款', 1);
      buildOrderTab($r('app.media.ic_order_pending_shipment'), '待发货', 2);
      buildOrderTab($r('app.media.ic_order_pending_receipt'), '待收货', 3);
      buildOrderTab($r('app.media.ic_order_pending_review'), '待评价', 4);
      buildOrderTab($r('app.media.ic_order_refund_after_sale'), '退款/售后', 5);
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .justifyContent(BreakpointSystem.currentBreakpoint.value === BreakpointTypeEnum.SM ?
      FlexAlign.SpaceBetween :
      FlexAlign.SpaceAround);
  }
  .containerStyle();
}

@Builder
function buildSubMenuArea() {
  List({ space: 24 }) {
    ForEach(ProfileUtil.SUB_MENU_LIST, (item: SubMenuItem) => {
      ListItem() {
        Row() {
          SymbolGlyph(item.icon)
            .fontSize(24)
            .width(24)
            .height(24)
            .fontColor([$r('app.color.font_color_level1')])
            .margin({ right: 8 });

          Text(item.label).formLabelStyle();
          Blank();
          Image($r('app.media.ic_arrow_right')).commonIconStyle();
        }
        .id(item.type === SubMenuOption.VIEW_HISTORY ? 'mall-history-entry' : 'mall-profile-submenu-content')
        .width('100%')
        .onClick(() => {
          ProfileUtil.handleSubMenuClick(item.type)
        });
      }
      .id('mall-profile-submenu-item')
    }, (item: SubMenuItem) => item.label)
  }
  .containerStyle()
  .divider({
    strokeWidth: 1,
    startMargin: 32,
  })
  .lanes(BreakpointSystem.currentBreakpoint.value === BreakpointTypeEnum.LG ? 2 : 1, 16)
}

@Builder
function buildOrderTab(icon: ResourceStr, label: string, type: number) {
  Column() {
    Image(icon).commonIconStyle()
      .width(24)
      .height(24)
      .margin({ bottom: 4 });
    Text(label)
      .commonLabelStyle()
  }
  .alignItems(HorizontalAlign.Center)
  .justifyContent(FlexAlign.Start)
  .onClick(() => {
    routerStack.pushPathByName(RouterMap.ORDER_LIST, type);
  });
}

@Styles
function containerStyle() {
  .width('100%')
  .backgroundColor($r('app.color.background_color_primary'))
  .borderRadius(16)
  .padding(12);
}

@Extend(Text)
function commonLabelStyle() {
  .fontSize(12)
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
  .fontColor($r('app.color.font_color_level1'));
}

@Extend(Text)
function formLabelStyle() {
  .fontWeight(FontWeight.Medium)
  .fontSize(14)
  .fontColor($r('app.color.font_color_level1'))
}

@Extend(Image)
function commonIconStyle() {
  .draggable(false)
  .height(16)
  .width(16)
  .fillColor($r('app.color.font_color_level2'));
}

@Extend(Column)
function tabletContainerStyle() {
  .backgroundColor($r('app.color.background_color_primary'))
  .borderRadius(16)
  .height(78)
  .justifyContent(FlexAlign.Center)
}
