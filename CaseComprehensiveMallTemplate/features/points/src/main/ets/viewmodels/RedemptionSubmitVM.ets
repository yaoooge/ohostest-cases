import { routerStack, WindowUtil } from 'lib_foundation'
import { AddressInfo, PointsApis, UserPointRedemptionSku } from 'lib_network'

@ObservedV2
export class RedemptionSubmitVM {
  @Trace
  customerAddress: string = '广东省深圳市南山区科技园'
  @Trace
  customerName: string = '华为用户'
  @Trace
  customerPhone: string = '12300000000'
  @Trace
  product: UserPointRedemptionSku | undefined = undefined

  @Computed
  get displayAddress() {
    return this.customerAddress ? this.customerAddress : ''
  }

  @Computed
  get displayCustomerInfo() {
    if (!this.customerName && !this.customerPhone) {
      return '请填写收件人信息'
    }
    return this.customerName + ' ' + this.customerPhone
  }

  async onSubmit() {
    if (!this.product) {
      return
    }
    if (!this.customerAddress || !this.customerName || !this.customerPhone) {
      WindowUtil.toast('请填写正确的收件信息')
      return
    }
    const addressInfo: AddressInfo = {
      name: this.customerName,
      cellphone: this.customerPhone,
      address: this.customerAddress,
    }
    const res = await PointsApis.redeemPointsForProducts(this.product, addressInfo)
    if (res.code === 0) {
      WindowUtil.toast('兑换成功！')
      routerStack.pop(1)
    }
  }
}
