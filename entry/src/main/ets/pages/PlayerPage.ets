import { router } from '@kit.ArkUI';
import { BackendApi } from '../api/BackendApi';
import { promptAction } from '@kit.ArkUI';

const VIDEO_URL = 'http://10.0.2.2:3000/video/demo.mp4';

interface PlaybackInfo {
  time: number;
}

@Entry
@Component
struct PlayerPage {
  @State movieTitle: string = '正在播放';
  private currentTime: number = 0;
  private videoDuration: number = 0;
  private movieId: number = 0;
  private posterPath: string = '';
  private mediaType: string = 'movie';
  private seasonNumber: number = 1;
  private episodeNumber: number = 1;
  private vc: VideoController = new VideoController();
  private historySaved: boolean = false;

  aboutToAppear(): void {
    const p = router.getParams() as Record<string, Object>;
    if (p) {
      if (p['movieTitle']) this.movieTitle = String(p['movieTitle']);
      this.movieId = Number(p['movieId']) || 0;
      this.posterPath = String(p['posterPath'] || '');
      this.mediaType = String(p['mediaType'] || 'movie');
      this.seasonNumber = Number(p['seasonNumber']) || 1;
      this.episodeNumber = Number(p['episodeNumber']) || 1;
    }
  }

  onBackPress(): boolean {
    if (this.historySaved) {
      return false;
    }
    this.saveHistoryAndBack();
    return true;
  }

  private async saveHistoryAndBack(): Promise<void> {
    if (this.historySaved) {
      return;
    }
    this.historySaved = true;

    const dur: number = this.videoDuration > 0 ? this.videoDuration : 600;
    let progress: number = 5;
    if (this.currentTime > 0) {
      progress = Math.floor(this.currentTime / dur * 100);
    }
    if (progress < 1) progress = 1;
    if (progress > 100) progress = 100;

    try {
      const isTV: boolean = this.mediaType === 'tv';
      const epId: number = isTV ? (this.movieId * 100 + this.episodeNumber) : 0;
      const epName: string = isTV ? ('第' + String(this.episodeNumber) + '集') : '';
      await BackendApi.getInstance().addHistory(
        this.movieId, this.movieTitle, this.posterPath,
        this.mediaType, epId, epName,
        this.seasonNumber, this.episodeNumber,
        Math.floor(this.currentTime), Math.floor(dur), progress
      );
      if (isTV) {
        await BackendApi.getInstance().updateWatchingProgress(
          this.movieId, this.episodeNumber, this.seasonNumber, progress
        );
      }
      promptAction.showToast({ message: '已保存进度 ' + String(progress) + '%' });
    } catch (e) {
      const msg: string = e instanceof Error ? e.message : '网络异常';
      promptAction.showToast({ message: msg });
    }
    router.back();
  }

  build() {
    Stack() {
      Video({ src: VIDEO_URL, controller: this.vc })
        .width('100%').height('100%')
        .objectFit(ImageFit.Contain)
        .backgroundColor('#000000')
        .controls(true)
        .autoPlay(true)
        .onUpdate((info: PlaybackInfo) => {
          this.currentTime = info.time;
        })
        .onPrepared((info) => {
          this.videoDuration = info.duration;
        })

      Row() {
        Button() {
          Text('‹').fontSize(32).fontColor('#FFFFFF')
        }
        .type(ButtonType.Circle).backgroundColor('rgba(0,0,0,0.4)')
        .onClick(() => { this.saveHistoryAndBack(); })

        Text(this.movieTitle)
          .fontSize(16).fontColor('#FFFFFF').fontWeight(FontWeight.Bold)
          .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis }).layoutWeight(1)
          .margin({ left: 12 })
      }
      .width('100%').padding(16)
      .alignItems(VerticalAlign.Top)
    }
    .width('100%').height('100%')
  }
}
