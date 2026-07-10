import { router } from '@kit.ArkUI';
import { BackendApi } from '../api/BackendApi';
import { media } from '@kit.MediaKit';
import { promptAction } from '@kit.ArkUI';

const VIDEO_URL = 'http://10.0.2.2:3000/video/demo.mp4';

@Entry
@Component
struct PlayerPage {
  @State movieTitle: string = '正在播放';
  @State isPlaying: boolean = true;
  @State progressValue: number = 0;
  @State currentTimeStr: string = '00:00';
  @State durationStr: string = '00:00';
  private currentTime: number = 0;
  private videoDuration: number = 0;
  private movieId: number = 0;
  private posterPath: string = '';
  private mediaType: string = 'movie';
  private seasonNumber: number = 1;
  private episodeNumber: number = 1;
  private historySaved: boolean = false;
  private avPlayer: media.AVPlayer | null = null;

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
    this.initAVPlayer();
  }

  aboutToDisappear(): void {
    this.releasePlayer();
  }

  private async initAVPlayer(): Promise<void> {
    try {
      this.avPlayer = await media.createAVPlayer();
      if (!this.avPlayer) return;
      this.avPlayer.on('stateChange', (state: media.AVPlayerState) => {
        if (state === 'prepared') {
          this.videoDuration = this.avPlayer!.duration;
          this.durationStr = this.formatTime(this.videoDuration);
          this.avPlayer!.play();
          this.isPlaying = true;
        }
      });
      this.avPlayer.on('timeUpdate', (time: number) => {
        this.currentTime = time;
        this.currentTimeStr = this.formatTime(time);
        if (this.videoDuration > 0) {
          this.progressValue = Math.floor(time / this.videoDuration * 100);
        }
      });
      this.avPlayer.url = VIDEO_URL;
    } catch (e) {
      promptAction.showToast({ message: '播放器初始化失败' });
    }
  }

  private togglePlay(): void {
    if (!this.avPlayer) return;
    if (this.isPlaying) { this.avPlayer.pause(); this.isPlaying = false; }
    else { this.avPlayer.play(); this.isPlaying = true; }
  }

  private onSliderChange(value: number): void {
    if (!this.avPlayer || this.videoDuration <= 0) return;
    this.avPlayer.seek(Math.floor(value / 100 * this.videoDuration));
  }

  private releasePlayer(): void {
    if (this.avPlayer) { this.avPlayer.release(); this.avPlayer = null; }
  }

  private formatTime(ms: number): string {
    const s = Math.floor(ms / 1000);
    return String(Math.floor(s / 60)).padStart(2, '0') + ':' + String(s % 60).padStart(2, '0');
  }

  onBackPress(): boolean {
    if (this.historySaved) return false;
    this.saveHistoryAndBack();
    return true;
  }

  private async saveHistoryAndBack(): Promise<void> {
    if (this.historySaved) return;
    this.historySaved = true;
    this.releasePlayer();

    const dur = this.videoDuration > 0 ? this.videoDuration : 600000;
    let progress = this.currentTime > 0 ? Math.floor(this.currentTime / dur * 100) : 5;
    if (progress < 1) progress = 1;
    if (progress > 100) progress = 100;

    try {
      const isTV = this.mediaType === 'tv';
      await BackendApi.getInstance().addHistory(
        this.movieId, this.movieTitle, this.posterPath,
        this.mediaType, isTV ? (this.movieId * 100 + this.episodeNumber) : 0,
        isTV ? ('第' + String(this.episodeNumber) + '集') : '',
        this.seasonNumber, this.episodeNumber,
        Math.floor(this.currentTime / 1000), Math.floor(dur / 1000), progress
      );
      if (isTV) {
        await BackendApi.getInstance().updateWatchingProgress(
          this.movieId, this.episodeNumber, this.seasonNumber, progress
        );
      }
      promptAction.showToast({ message: '已保存进度 ' + String(progress) + '%' });
    } catch (e) {
      promptAction.showToast({ message: e instanceof Error ? e.message : '网络异常' });
    }
    router.back();
  }

  build() {
    Stack() {
      XComponent({ id: 'surfaceId', type: 'surface', libraryname: '' })
        .width('100%').height('100%')
        .onLoad(() => {})
      Row() {
        Button() { Text('‹').fontSize(32).fontColor('#FFFFFF') }
          .type(ButtonType.Circle).backgroundColor('rgba(0,0,0,0.4)')
          .onClick(() => { this.saveHistoryAndBack(); })
        Text(this.movieTitle).fontSize(16).fontColor('#FFFFFF').fontWeight(FontWeight.Bold)
          .maxLines(1).layoutWeight(1).margin({ left: 12 })
      }.width('100%').padding(16).alignItems(VerticalAlign.Top)
      Column() {
        Row({ space: 8 }) {
          Text(this.currentTimeStr).fontSize(12).fontColor('#FFFFFF')
          Slider({ value: this.progressValue, min: 0, max: 100, step: 1 })
            .layoutWeight(1).onChange((v) => { this.onSliderChange(v); })
          Text(this.durationStr).fontSize(12).fontColor('#FFFFFF')
        }.width('100%')
        Row({ space: 24 }) {
          Button() { Text(this.isPlaying ? '⏸' : '▶').fontSize(28).fontColor('#FFFFFF') }
            .type(ButtonType.Circle).width(56).height(56)
            .onClick(() => { this.togglePlay(); })
        }.width('100%').justifyContent(FlexAlign.Center).padding({ top: 8 })
      }.width('100%').padding(16).position({ x: 0, y: '80%' })
    }.width('100%').height('100%').backgroundColor('#000000')
  }
}
