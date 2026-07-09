import { UserReview } from '../model/MovieModel';
import { ProfileViewModel } from '../viewmodel/ProfileViewModel';
import { DateUtils } from '../utils/DateUtils';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct ReviewsPage {
  @State list: UserReview[] = [];
  @State isLoading: boolean = true;
  private vm: ProfileViewModel = new ProfileViewModel();

  aboutToAppear(): void {
    this.vm.onReviewsUpdated = (r: UserReview[]) => { this.list = r; this.isLoading = false; };
    this.vm.loadReviews();
  }

  build() {
    Column() {
      Row() {
        Button() { Text('‹').fontSize(28).fontColor('#333333') }
          .type(ButtonType.Circle).backgroundColor('transparent').onClick(() => router.back())
        Text('我的评分').fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1).margin({ left: 12 })
      }.width('100%').padding(12).backgroundColor('#FFFFFF')

      if (this.isLoading) {
        Column() { LoadingProgress().width(40).height(40).color('#4A90D9') }.layoutWeight(1).justifyContent(FlexAlign.Center)
      } else if (this.list.length === 0) {
        Column() { Text('暂无评分').fontSize(16).fontColor('#999999') }.layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        List({ space: 8 }) {
          ForEach(this.list, (r: UserReview) => {
            ListItem() {
              Column({ space: 10 }) {
                Row() {
                  Text(r.movieTitle).fontSize(16).fontWeight(FontWeight.Medium).layoutWeight(1)
                  Row({ space: 2 }) {
                    Text(String(r.rating) + '分').fontSize(14).fontColor('#FFB800').fontWeight(FontWeight.Bold).margin({ right: 4 })
                    ForEach([1, 2, 3, 4, 5], (star: number) => {
                      Text(star <= Math.ceil(r.rating / 2) ? '★' : '☆')
                        .fontSize(16)
                        .fontColor(star <= Math.ceil(r.rating / 2) ? '#FFB800' : '#CCCCCC')
                    }, (s: number) => String(s))
                  }
                }.width('100%')
                if (r.review) Text(r.review).fontSize(14).fontColor('#666666').lineHeight(20).width('100%')
                Text(DateUtils.formatDateTime(r.updateTime)).fontSize(12).fontColor('#999999')
              }.width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(8)
              .onClick(() => router.pushUrl({ url: 'pages/MovieDetailPage', params: { movieId: r.movieId } }))
            }
          }, (r: UserReview) => String(r.id))
        }.width('100%').layoutWeight(1).padding(12).backgroundColor('#F5F5F5')
      }
    }.width('100%').height('100%').backgroundColor('#F5F5F5')
  }
}
