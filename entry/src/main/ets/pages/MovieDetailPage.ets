import { MovieInfo, MovieType, TVDetail, UserReview, SeasonData } from '../model/MovieModel';
import { MovieDetailViewModel } from '../viewmodel/MovieDetailViewModel';
import { RatingBar } from '../components/RatingBar';
import { promptAction } from '@kit.ArkUI';
import { router } from '@kit.ArkUI';
import { media } from '@kit.MediaKit';

const VIDEO_URL = 'http://10.0.2.2:3000/video/demo.mp4';

@Entry
@Component
struct MovieDetailPage {
  @State movieDetail: MovieInfo | null = null;
  @State tvDetail: TVDetail | null = null;
  @State isFavorite: boolean = false;
  @State userRating: number = 0;
  @State reviewText: string = '';
  @State showReviewDialog: boolean = false;
  @State selectedSeason: number = 1;
  @State selectedEpisode: number = 1;
  @State isLoading: boolean = true;
  @State showTrailer: boolean = false;

  private movieId: number = 0;
  private mediaType: MovieType = MovieType.MOVIE;
  private viewModel: MovieDetailViewModel = new MovieDetailViewModel();
  private vc: VideoController = new VideoController();

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    if (params) {
      this.movieId = Number(params['movieId']) || 0;
      const mt: string = String(params['mediaType'] || 'movie');
      this.mediaType = mt === MovieType.TV ? MovieType.TV : MovieType.MOVIE;
      const sn: number = Number(params['seasonNumber']) || 0;
      if (sn > 0) this.selectedSeason = sn;
      const en: number = Number(params['episodeNumber']) || 0;
      if (en > 0) this.selectedEpisode = en;
    }
    this.viewModel.onDetailLoaded = (detail: MovieInfo | TVDetail) => {
      if (detail instanceof TVDetail) { this.tvDetail = detail; this.movieDetail = detail; }
      else { this.movieDetail = detail; }
      this.isLoading = false;
    };
    this.viewModel.onFavoriteChanged = (isFav: boolean) => { this.isFavorite = isFav; };
    this.viewModel.onReviewLoaded = (review: UserReview | null) => {
      if (review) { this.userRating = review.rating; this.reviewText = review.review; }
    };
    this.viewModel.onError = (msg: string) => { promptAction.showToast({ message: msg }); };
    this.viewModel.loadMovieDetail(this.movieId, this.mediaType);
  }

  @Builder
  VideoHeader() {
    Stack({ alignContent: Alignment.Bottom }) {
      Video({ src: VIDEO_URL, controller: this.vc })
        .width('100%').height(220)
        .objectFit(ImageFit.Cover)
        .backgroundColor('#000000')
        .autoPlay(true).loop(true).muted(true)

      Column().width('100%').height(80)
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.8)', 1]]
        })

      Column({ space: 4 }) {
        Text(this.movieDetail?.title || '')
          .fontSize(22).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
        Text(this.movieDetail?.originalTitle || '')
          .fontSize(13).fontColor('#CCCCCC')
      }
      .alignItems(HorizontalAlign.Start).width('100%').padding({ left: 16, bottom: 12 })
    }
    .width('100%').height(220)
  }

  @Builder
  ActionButtons() {
    Row({ space: 12 }) {
      Button() {
        Column({ space: 2 }) {
          Text('🔖').fontSize(20)
            .fontColor(this.isFavorite ? '#FF6B35' : '#666666')
          Text(this.isFavorite ? '已收藏' : '收藏').fontSize(11)
            .fontColor(this.isFavorite ? '#FF6B35' : '#666666')
        }
      }
      .type(ButtonType.Capsule).backgroundColor('#FFFFFF').layoutWeight(1).height(56)
      .onClick(() => { this.viewModel.toggleFavorite(); })

      if (this.movieDetail?.mediaType === MovieType.TV) {
        Button() {
          Column({ space: 2 }) {
            Text('📺').fontSize(20).fontColor('#4CAF50')
            Text('追剧').fontSize(11).fontColor('#4CAF50')
          }
        }
        .type(ButtonType.Capsule).backgroundColor('#FFFFFF').layoutWeight(1).height(56)
        .onClick(() => { this.handleWatching(); })
      }

      Button() {
        Column({ space: 2 }) {
          Text('★').fontSize(20).fontColor('#FFB800')
          Text('评分').fontSize(11).fontColor('#FFB800')
        }
      }
      .type(ButtonType.Capsule).backgroundColor('#FFFFFF').layoutWeight(1).height(56)
      .onClick(() => { this.showReviewDialog = true; })
    }
    .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 }).backgroundColor('#FFFFFF')
  }

  @Builder
  InfoSection() {
    Column({ space: 12 }) {
      Row() {
        Column({ space: 2 }) {
          Text(String(Number(this.movieDetail?.voteAverage || 0).toFixed(1)))
            .fontSize(32).fontWeight(FontWeight.Bold).fontColor('#FFB800')
          Text('评分').fontSize(11).fontColor('#999999')
        }
        Column().layoutWeight(1)
        Column({ space: 4 }) {
          Text(this.movieDetail?.releaseDate?.substring(0, 4) || '').fontSize(14).fontColor('#666666')
          if (this.movieDetail?.runtime) Text(String(this.movieDetail.runtime) + '分钟').fontSize(12).fontColor('#999999')
        }
      }.width('100%')

      if (this.movieDetail?.genres && this.movieDetail.genres.length > 0) {
        Row({ space: 6 }) {
          ForEach(this.movieDetail.genres.slice(0, 5), (g: string) => {
            Text(g).fontSize(12).fontColor('#4A90D9').backgroundColor('#E8F4FD')
              .padding({ left: 8, right: 8, top: 3, bottom: 3 }).borderRadius(4)
          }, (g: string) => g)
        }
      }

      Text('剧情简介').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333').margin({ top: 8 })
      Text(this.movieDetail?.overview || '暂无简介').fontSize(14).fontColor('#666666').lineHeight(22)

      if (this.tvDetail?.seasons && this.tvDetail.seasons.length > 0) {
        Text('剧集选择').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333').margin({ top: 8 })
        // 季标签
        Scroll() {
          Row({ space: 8 }) {
            ForEach(this.tvDetail.seasons, (s: SeasonData) => {
              Text(s.name).fontSize(13)
                .fontColor(this.selectedSeason === s.seasonNumber ? '#FFFFFF' : '#666666')
                .backgroundColor(this.selectedSeason === s.seasonNumber ? '#4A90D9' : '#F0F0F0')
                .padding({ left: 12, right: 12, top: 6, bottom: 6 }).borderRadius(16)
                .onClick(() => { this.selectedSeason = s.seasonNumber; })
            }, (s: SeasonData) => String(s.id))
          }
        }.scrollable(ScrollDirection.Horizontal)
        // 集数网格
        Text('第' + String(this.selectedSeason) + '季 · 共' + String(this.getCurrentSeasonEpisodes()) + '集')
          .fontSize(13).fontColor('#999999').margin({ top: 8 })
        Grid() {
          ForEach(this.getEpisodeList(), (ep: number) => {
            GridItem() {
              Text(String(ep))
                .fontSize(14)
                .fontColor(this.selectedEpisode === ep ? '#FFFFFF' : '#333333')
                .width('100%').height(36).textAlign(TextAlign.Center)
                .backgroundColor(this.selectedEpisode === ep ? '#4A90D9' : '#F5F5F5').borderRadius(4)
                .onClick(() => {
                  this.selectedEpisode = ep;
                  promptAction.showToast({ message: '已选第' + String(ep) + '集' });
                })
            }
          }, (ep: number) => String(ep))
        }
        .columnsTemplate('1fr 1fr 1fr 1fr 1fr').columnsGap(6).rowsGap(6)
        .margin({ top: 4, bottom: 12 })
      }
    }
    .width('100%').padding(16).backgroundColor('#FFFFFF')
  }

  @Builder
  ReviewDialog() {
    Column({ space: 16 }) {
      Text('评分与短评').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333333')
      RatingBar({ rating: this.userRating, onRatingChange: (r: number) => { this.userRating = r; } })
      TextArea({ placeholder: '短评...', text: this.reviewText }).height(100).backgroundColor('#F5F5F5')
        .onChange((v: string) => { this.reviewText = v; })
      Row({ space: 12 }) {
        Button('取消').type(ButtonType.Capsule).backgroundColor('#999999').layoutWeight(1)
          .onClick(() => { this.showReviewDialog = false; })
        Button('提交').type(ButtonType.Capsule).backgroundColor('#4A90D9').layoutWeight(1)
          .onClick(() => { this.submitReview(); })
      }.width('100%')
    }
    .width('90%').padding(20).backgroundColor('#FFFFFF').borderRadius(12)
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      if (this.isLoading) {
        LoadingProgress().width(48).height(48).color('#4A90D9')
      } else {
        Column() {
          Scroll() {
            Column() {
              this.VideoHeader()
              this.ActionButtons()
              this.InfoSection()
              Button() {
                Row({ space: 8 }) {
                  Text('🎬 预告片').fontSize(16).fontColor('#FFFFFF')
                }
              }
              .width('100%').height(44).backgroundColor('#FF6B35').borderRadius(8)
              .margin({ left: 16, right: 16, top: 8 })
              .onClick(() => { this.showTrailer = !this.showTrailer; })

              if (this.showTrailer) {
                Video({ src: VIDEO_URL, controller: new VideoController() })
                  .width('100%').height(200)
                  .objectFit(ImageFit.Contain).backgroundColor('#000000')
                  .autoPlay(true).controls(true)
                  .margin({ left: 16, right: 16, top: 8 })
              }

              Button() {
                Row({ space: 8 }) {
                  Text('▶ 播放正片').fontSize(18).fontColor('#FFFFFF').fontWeight(FontWeight.Bold)
                }
              }
              .width('100%').height(52).backgroundColor('#4A90D9').borderRadius(8)
              .margin({ left: 16, right: 16, top: 16, bottom: 24 })
              .onClick(() => { this.doPlay(); })
            }
          }
          .scrollable(ScrollDirection.Vertical).edgeEffect(EdgeEffect.Spring)
          .width('100%').layoutWeight(1)
        }
        .width('100%').height('100%')
      }
      if (this.showReviewDialog) {
        Stack({ alignContent: Alignment.Center }) {
          Column().width('100%').height('100%').backgroundColor('rgba(0,0,0,0.5)')
            .onClick(() => { this.showReviewDialog = false; })
          this.ReviewDialog()
        }.width('100%').height('100%')
      }
    }
    .width('100%').height('100%').backgroundColor('#F5F5F5')
  }

  private getCurrentSeasonEpisodes(): number {
    if (this.tvDetail?.seasons) {
      for (let i = 0; i < this.tvDetail.seasons.length; i++) {
        if (this.tvDetail.seasons[i].seasonNumber === this.selectedSeason) {
          return this.tvDetail.seasons[i].episodeCount;
        }
      }
    }
    return 0;
  }

  private getEpisodeList(): number[] {
    const count = this.getCurrentSeasonEpisodes();
    const list: number[] = [];
    for (let i = 1; i <= count; i++) list.push(i);
    return list;
  }

  private async handleWatching(): Promise<void> {
    const ok = await this.viewModel.setWatchingStatus(true);
    promptAction.showToast({ message: ok ? '已添加追剧' : '追剧失败' });
  }

  private doPlay(): void {
    const isTV = this.movieDetail?.mediaType === MovieType.TV;
    router.pushUrl({
      url: 'pages/PlayerPage',
      params: {
        movieTitle: this.movieDetail?.title || '',
        posterPath: this.movieDetail?.posterPath || '',
        movieId: this.movieDetail?.id || 0,
        mediaType: this.movieDetail?.mediaType || MovieType.MOVIE,
        seasonNumber: isTV ? this.selectedSeason : 1,
        episodeNumber: isTV ? this.selectedEpisode : 1
      }
    });
  }

  private async submitReview(): Promise<void> {
    if (this.userRating === 0) { promptAction.showToast({ message: '请先评分' }); return; }
    const ok = await this.viewModel.submitReview(this.userRating, this.reviewText);
    promptAction.showToast({ message: ok ? '提交成功' : '失败' });
    if (ok) this.showReviewDialog = false;
  }
}
