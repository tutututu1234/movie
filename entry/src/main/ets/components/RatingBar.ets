 * 评分组件 — 5星制，每星2分，总分10分
 */
@Component
export struct RatingBar {
  @Prop rating: number = 0;
  @Prop maxStars: number = 5;
  @Prop starSize: number = 28;
  onRatingChange: (rating: number) => void = (_rating: number) => {};

  build() {
    Row({ space: 2 }) {
      ForEach([1, 2, 3, 4, 5], (index: number) => {
        Text(index <= Math.ceil(this.rating / 2) ? '★' : '☆')
          .fontSize(this.starSize)
          .fontColor(index <= Math.ceil(this.rating / 2) ? '#FFB800' : '#CCCCCC')
          .onClick(() => {
            this.onRatingChange(index * 2);
          })
      }, (index: number) => String(index))

      if (this.rating > 0) {
        Text(String(Number(this.rating).toFixed(0)) + '分')
          .fontSize(15)
          .fontColor('#FFB800')
          .fontWeight(FontWeight.Bold)
          .margin({ left: 8 })
      }
    }
  }
}
