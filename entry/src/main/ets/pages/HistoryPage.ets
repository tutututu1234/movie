import { WatchHistory } from '../model/MovieModel';
import { ProfileViewModel } from '../viewmodel/ProfileViewModel';
import { DateUtils } from '../utils/DateUtils';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct HistoryPage {
  @State list: WatchHistory[] = [];
  @State isLoading: boolean = true;
  private vm: ProfileViewModel = new ProfileViewModel();

  aboutToAppear(): void {
    this.vm.onHistoryUpdated = (h: WatchHistory[]) => { this.list = h; this.isLoading = false; };
    this.vm.loadWatchHistory();
  }

  build() {
    Column() {
      Row() {
        Button() { Text('‹').fontSize(28).fontColor('#333333') }
          .type(ButtonType.Circle).backgroundColor('transparent').onClick(() => router.back())
        Text('观看历史').fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1).margin({ left: 12 })
        if (this.list.length > 0) {
          Text('清除').fontSize(14).fontColor('#FF4444').onClick(async () => {
            await this.vm.clearHistory();
            this.list = [];
          })
        }
      }.width('100%').padding(12).backgroundColor('#FFFFFF')

      if (this.isLoading) {
        Column() { LoadingProgress().width(40).height(40).color('#4A90D9') }.layoutWeight(1).justifyContent(FlexAlign.Center)
      } else if (this.list.length === 0) {
        Column() { Text('暂无观看记录').fontSize(16).fontColor('#999999') }.layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        List({ space: 8 }) {
          ForEach(this.list, (h: WatchHistory) => {
            ListItem() {
              Row({ space: 12 }) {
                Image(h.posterPath).width(70).height(100).objectFit(ImageFit.Cover).borderRadius(6)
                Column({ space: 6 }) {
                  Text(h.movieTitle).fontSize(16).fontWeight(FontWeight.Medium).fontColor('#333333')
                  if (h.episodeName) Text(h.episodeName).fontSize(13).fontColor('#666666')
                  Row() {
                    Text(DateUtils.getRelativeTime(h.lastWatchTime)).fontSize(12).fontColor('#999999')
                    if (h.progress > 0) Text(' · 已看' + String(Math.floor(h.progress)) + '%').fontSize(12).fontColor('#4A90D9')
                  }
                }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                Text('›').fontSize(18).fontColor('#CCCCCC')
              }.width('100%').padding(12).backgroundColor('#FFFFFF').borderRadius(8)
              .onClick(() => router.pushUrl({ url: 'pages/MovieDetailPage', params: { movieId: h.movieId, mediaType: h.mediaType, seasonNumber: h.seasonNumber, episodeNumber: h.episodeNumber } }))
            }
          }, (h: WatchHistory) => String(h.id))
        }.width('100%').layoutWeight(1).padding(12).backgroundColor('#F5F5F5')
      }
    }.width('100%').height('100%').backgroundColor('#F5F5F5')
  }
}
