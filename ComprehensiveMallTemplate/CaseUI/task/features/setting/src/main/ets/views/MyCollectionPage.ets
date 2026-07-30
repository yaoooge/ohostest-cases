import { WindowUtil } from 'lib_foundation'
import { ProductApis, ProductCardItem } from 'lib_network'
import { CommonConfirmDialog, NavTitleBar } from 'lib_widget'
import { ProductList } from '../components/ProductList'

@Builder
export function buildMyCollectionPage() {
  MyCollectionPage()
}

@ComponentV2
export struct MyCollectionPage {
  @Local
  productList: ProductCardItem[] = []
  @Local
  curPage: number = 1
  @Local
  isFinal: boolean = false;
  @Local
  isEdit: boolean = false
  @Local
  isLoading: boolean = false;

  build() {
    NavDestination() {
      NavTitleBar({
        title: '我的收藏',
      }) {
        Blank()
        Button(this.isEdit ? '退出编辑' : '编辑')
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .fontColor($r('sys.color.font_primary'))
          .onClick(() => {
            this.isEdit = !this.isEdit
          })
      }

      ProductList({
        productList: this.productList,
        isEdit: this.isEdit,
        isLoading: this.isLoading,
        onReachEnd: async () => {
          await this.getCollectionList()
        },
        handleDelete: (list: string[]) => {
          CommonConfirmDialog.show({
            content: '是否确认取消收藏？',
            confirm: () => {
              ProductApis.cancelCollectProduct(list).then((res) => {
                if (res.code === 0) {
                  WindowUtil.toast('取消收藏成功！')
                  this.isEdit = false;
                  this.refresh()
                }
              })
            },
          })
        },
      })
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background_color_grey'))
    .onShown(() => {
      this.refresh()
    })
  }

  async refresh() {
    this.productList = []
    this.curPage = 1;
    this.isFinal = false;
    this.getCollectionList()
  }

  async getCollectionList() {
    if (this.isFinal || this.isLoading) {
      return;
    }
    this.isLoading = true
    const res = await ProductApis.getCollectedProductList({ curPage: this.curPage })
    if (res.code === 0) {
      this.productList.push(...res.list)
      this.isFinal = res.isFinal;
    }
    if (!this.isFinal) {
      this.curPage++;
    }
    this.isLoading = false;
  }
}