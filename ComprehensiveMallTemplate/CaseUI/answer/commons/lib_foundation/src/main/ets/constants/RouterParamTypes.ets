/** ========================== 页面路由参数 ============================ */

/** 商品详情页 */
export interface ProductInfoPageParam {
  productId: string
  slotId?: string
}

/** 商品搜索页 */
export interface ProductSearchPageParam {
  defaultSearch?: string
  slotId?: string
  longTakeTransitionParam?: Object
}

/** 商品搜索结果页 */
export interface ProductSearchResultsPageParam {
  /** 搜索关键字 */
  keywords?: string
  /** 识图图源 */
  searchImg?: PixelMap
  /** 秒杀场次ID */
  slotId?: string
}
