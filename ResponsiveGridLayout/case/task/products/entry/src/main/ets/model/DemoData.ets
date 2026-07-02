import { PrimaryCategory } from './Types';

export const PRIMARY_CATEGORIES: PrimaryCategory[] = [
  {
    label: '耳机音箱',
    sections: [
      {
        label: '蓝牙耳机',
        title: '蓝牙耳机',
        products: [
          {
            name: 'HUAWEI FreeClip 2',
            detail: '耳夹耳机 无线充 玫瑰金',
            image: $r('app.media.product_freeclip'),
          },
          {
            name: 'FreeBuds Pro',
            detail: '旗舰降噪耳机',
            image: $r('app.media.product_freeclip'),
          },
          {
            name: 'FreeBuds SE',
            detail: '舒适半入耳',
            image: $r('app.media.product_freeclip'),
          },
          {
            name: '运动耳机',
            detail: '轻盈防汗',
            image: $r('app.media.product_freeclip'),
          },
        ],
      },
      {
        label: '音频配件',
        title: '音频配件',
        products: [
          {
            name: '音频保护套',
            detail: '耳机随行保护',
            image: $r('app.media.product_case'),
          },
          {
            name: '充电收纳盒',
            detail: '便携续航',
            image: $r('app.media.product_data_cable'),
          },
        ],
      },
    ],
  },
  {
    label: '智能眼镜',
    sections: [
      {
        label: '智慧穿戴',
        title: '智慧穿戴',
        products: [
          {
            name: 'HUAWEI WATCH FIT 5',
            detail: '韵律黑 氟橡胶表带',
            image: $r('app.media.product_watch_fit5'),
          },
          {
            name: '穿戴配件',
            detail: '表带与充电底座',
            image: $r('app.media.product_watch_fit5'),
          },
          {
            name: '智能眼镜配件',
            detail: '镜盒与鼻托',
            image: $r('app.media.product_case'),
          },
        ],
      },
    ],
  },
  {
    label: '路由存储',
    sections: [
      {
        label: '网络配件',
        title: '网络配件',
        products: [
          {
            name: 'USB-C 网口线',
            detail: '办公扩展连接',
            image: $r('app.media.product_data_cable'),
          },
          {
            name: '无线鼠标 3',
            detail: '黑色 搭载鸿蒙 AI',
            image: $r('app.media.product_mouse'),
          },
          {
            name: '移动存储盒',
            detail: '轻薄随身',
            image: $r('app.media.product_case'),
          },
        ],
      },
    ],
  },
  {
    label: '配件中心',
    sections: [
      {
        label: '通用配件',
        title: '通用配件',
        products: [
          {
            name: '华为 6A 数据线',
            detail: 'USB Type-A 转 USB Type-C 1m',
            image: $r('app.media.product_data_cable'),
          },
          {
            name: '华为无线鼠标 3',
            detail: '标准版 黑色 搭载鸿蒙 AI',
            image: $r('app.media.product_mouse'),
          },
          {
            name: '透明保护壳',
            detail: 'HUAWEI Mate 80 系列',
            image: $r('app.media.product_case'),
          },
          {
            name: 'HUAWEI FreeClip 2',
            detail: '耳夹耳机 无线充',
            image: $r('app.media.product_freeclip'),
          },
          {
            name: 'WATCH FIT 5',
            detail: '韵律黑 氟橡胶表带',
            image: $r('app.media.product_watch_fit5'),
          },
          {
            name: '移动电源线',
            detail: '多设备充电',
            image: $r('app.media.product_data_cable'),
          },
        ],
      },
      {
        label: '专属配件',
        title: '专属配件',
        products: [
          {
            name: '手机配件',
            detail: '保护壳与贴膜',
            image: $r('app.media.product_case'),
          },
          {
            name: '电脑配件',
            detail: '鼠标与扩展坞',
            image: $r('app.media.product_mouse'),
          },
          {
            name: '平板配件',
            detail: '键盘与手写笔',
            image: $r('app.media.product_case'),
          },
          {
            name: '穿戴配件',
            detail: '表带与充电器',
            image: $r('app.media.product_watch_fit5'),
          },
          {
            name: '音频配件',
            detail: '耳机保护套',
            image: $r('app.media.product_freeclip'),
          },
          {
            name: '智慧屏配件',
            detail: '遥控器与支架',
            image: $r('app.media.product_mouse'),
          },
        ],
      },
    ],
  },
  {
    label: '全屋智能',
    sections: [
      {
        label: '智能控制',
        title: '智能控制',
        products: [
          {
            name: '智慧中控屏',
            detail: '全屋设备入口',
            image: $r('app.media.product_mouse'),
          },
          {
            name: '场景遥控器',
            detail: '一键联动',
            image: $r('app.media.product_watch_fit5'),
          },
        ],
      },
    ],
  },
];
