import { MovieInfo, MovieType, UserFavorite, UserReview, WatchHistory } from '../model/MovieModel';
import { ProfileViewModel } from '../viewmodel/ProfileViewModel';
import { MovieApi } from '../api/MovieApi';
import { AuthManager } from '../utils/AuthManager';
import { DateUtils } from '../utils/DateUtils';
import { router } from '@kit.ArkUI';

// ==================== 首页 Tab ====================
@Component
struct HomeTab {
  @State searchQuery: string = '';
  @State recMovies: MovieInfo[] = [];
  @State recTVs: MovieInfo[] = [];
  private api: MovieApi = MovieApi.getInstance();

  aboutToAppear(): void {
    this.loadRecommendations();
  }

  private async loadRecommendations(): Promise<void> {
    const m = await this.api.getPopularMovies(1);
    this.recMovies = m.items.slice(0, 10);
    const t = await this.api.getPopularTVs(1);
    this.recTVs = t.items.slice(0, 10);
  }

  private navToMovieList(): void {
    router.pushUrl({ url: 'pages/MovieListPage', params: { type: 'movie' } });
  }

  private navToTVList(): void {
    router.pushUrl({ url: 'pages/MovieListPage', params: { type: 'tv' } });
  }

  @Builder
  SearchBox() {
    Row({ space: 8 }) {
      TextInput({ placeholder: '搜索影视...', text: this.searchQuery })
        .layoutWeight(1).height(42).backgroundColor('#F0F0F0').borderRadius(21)
        .padding({ left: 16, right: 16 })
        .onChange((v: string) => { this.searchQuery = v; })
      Button('搜索').height(42).fontSize(14).fontColor('#FFFFFF')
        .backgroundColor('#4A90D9').borderRadius(21)
        .padding({ left: 20, right: 20 })
        .onClick(() => {
          if (this.searchQuery.trim()) {
            router.pushUrl({ url: 'pages/MovieListPage', params: { type: 'search', keyword: this.searchQuery.trim() } });
          }
        })
    }.width('100%').padding(12)
  }

  @Builder
  CategoryButtons() {
    Row({ space: 12 }) {
      Button() {
        Column({ space: 4 }) {
          Text('🎬').fontSize(32)
          Text('全部影片').fontSize(14).fontWeight(FontWeight.Bold).fontColor('#333333')
          Text('热门电影').fontSize(11).fontColor('#999999')
        }
      }
      .layoutWeight(1).height(100).backgroundColor('#FFFFFF').borderRadius(12)
      .onClick(() => { this.navToMovieList(); })

      Button() {
        Column({ space: 4 }) {
          Text('📺').fontSize(32)
          Text('全部电视剧').fontSize(14).fontWeight(FontWeight.Bold).fontColor('#333333')
          Text('热门剧集').fontSize(11).fontColor('#999999')
        }
      }
      .layoutWeight(1).height(100).backgroundColor('#FFFFFF').borderRadius(12)
      .onClick(() => { this.navToTVList(); })
    }.width('100%').padding({ left: 12, right: 12, bottom: 4 })
  }

  build() {
    Column() {
      Row() {
        Text('观影追剧助手').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#333333')
      }.width('100%').padding(12)

      this.SearchBox()
      this.CategoryButtons()
      Scroll() {
        Column() {
          // 推荐电影行
          Column({ space: 8 }) {
            Row() {
              Text('🎬 推荐电影').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333')
            }.width('100%').padding({ left: 12, right: 12 })
            if (this.recMovies.length === 0) {
              Row() { LoadingProgress().width(24).height(24).color('#4A90D9') }.width('100%').justifyContent(FlexAlign.Center).padding(20)
            } else {
              Scroll() {
                Row({ space: 8 }) {
                  ForEach(this.recMovies, (m: MovieInfo) => {
                    Column() {
                      Image(m.posterPath).width(100).height(140).objectFit(ImageFit.Cover).borderRadius(8)
                      Text(m.title).fontSize(12).maxLines(1).width(100)
                      Row() {
                      Text('★').fontSize(11).fontColor('#FFB800')
                        Text(String(Number(m.voteAverage).toFixed(1))).fontSize(11).fontColor('#FFB800')
                      }
                    }.onClick(() => {
                      router.pushUrl({ url: 'pages/MovieDetailPage', params: { movieId: m.id, mediaType: m.mediaType } });
                    })
                  }, (m: MovieInfo) => String(m.id))
                }.padding({ left: 12, right: 12 })
              }.scrollable(ScrollDirection.Horizontal)
            }
          }.width('100%').margin({ bottom: 12 })

          // 推荐电视剧行
          Column({ space: 8 }) {
            Row() {
              Text('📺 推荐电视剧').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333')
            }.width('100%').padding({ left: 12, right: 12 })
            if (this.recTVs.length === 0) {
              Row() { LoadingProgress().width(24).height(24).color('#4A90D9') }.width('100%').justifyContent(FlexAlign.Center).padding(20)
            } else {
              Scroll() {
                Row({ space: 8 }) {
                  ForEach(this.recTVs, (m: MovieInfo) => {
                    Column() {
                      Image(m.posterPath).width(100).height(140).objectFit(ImageFit.Cover).borderRadius(8)
                      Text(m.title).fontSize(12).maxLines(1).width(100)
                      Row() {
                      Text('★').fontSize(11).fontColor('#FFB800')
                        Text(String(Number(m.voteAverage).toFixed(1))).fontSize(11).fontColor('#FFB800')
                      }
                    }.onClick(() => {
                      router.pushUrl({ url: 'pages/MovieDetailPage', params: { movieId: m.id, mediaType: m.mediaType } });
                    })
                  }, (m: MovieInfo) => String(m.id))
                }.padding({ left: 12, right: 12 })
              }.scrollable(ScrollDirection.Horizontal)
            }
          }.width('100%').margin({ bottom: 12 })
        }
      }
      .scrollable(ScrollDirection.Vertical).layoutWeight(1)
    }
    .width('100%').height('100%').backgroundColor('#F5F5F5')
  }
}

// ==================== 收藏 Tab ====================
@Component
struct FavoritesTab {
  @State favorites: UserFavorite[] = [];
  @State watchingList: UserFavorite[] = [];
  @State activeTab: number = 0;
  @State isLoading: boolean = true;
  @Watch('onRefreshFlagChange') @Prop refreshFlag: number = 0;
  private viewModel: ProfileViewModel = new ProfileViewModel();

  aboutToAppear(): void {
    this.viewModel.onFavoritesUpdated = (f: UserFavorite[]) => { this.favorites = f; this.isLoading = false; };
    this.viewModel.onWatchingUpdated = (w: UserFavorite[]) => { this.watchingList = w; };
    this.viewModel.loadAllData();
  }

  onRefreshFlagChange(): void {
    this.isLoading = true;
    this.viewModel.loadAllData();
  }

  @Builder
  FavItem(fav: UserFavorite, onDel: () => void) {
    Row({ space: 12 }) {
      Image(fav.posterPath).width(80).height(110).objectFit(ImageFit.Cover).borderRadius(6)
      Column({ space: 6 }) {
        Text(fav.movieTitle).fontSize(16).fontWeight(FontWeight.Medium).fontColor('#333333').maxLines(1).width('100%')
        if (fav.isWatching) {
          Text('进度: ' + String(fav.currentEpisode) + '/' + String(fav.totalEpisodes) + '集').fontSize(13).fontColor('#666666')
        }
      }.layoutWeight(1).alignItems(HorizontalAlign.Start)
      Button() {
        Text('✕').fontSize(20).fontColor('#FF4444')
      }.type(ButtonType.Circle).backgroundColor('transparent')
      .onClick(() => { onDel(); })
    }.width('100%').padding(12).backgroundColor('#FFFFFF').borderRadius(8)
    .onClick(() => {
      router.pushUrl({ url: 'pages/MovieDetailPage', params: { movieId: fav.movieId, mediaType: fav.mediaType } });
    })
  }

  build() {
    Column() {
      Row() { Text('我的收藏').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#333333') }.width('100%').padding(12).backgroundColor('#FFFFFF')
      Row() {
        Text('全部收藏').fontSize(15).fontColor(this.activeTab === 0 ? '#4A90D9' : '#666666').layoutWeight(1).textAlign(TextAlign.Center)
          .onClick(() => { this.activeTab = 0; })
        Text('正在追剧').fontSize(15).fontColor(this.activeTab === 1 ? '#4A90D9' : '#666666').layoutWeight(1).textAlign(TextAlign.Center)
          .onClick(() => { this.activeTab = 1; this.viewModel.getWatchingList().then(l => this.watchingList = l); })
      }.width('100%').padding(12).backgroundColor('#FFFFFF')
      if (this.isLoading) {
        Column() { LoadingProgress().width(40).height(40).color('#4A90D9') }.layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        List({ space: 8 }) {
          ForEach(this.activeTab === 0 ? this.favorites : this.watchingList, (f: UserFavorite) => {
            ListItem() {
              this.FavItem(f, () => {
                const delItem = f;
                if (this.activeTab === 0) {
                  this.viewModel.removeFavorite(delItem.movieId);
                  this.favorites = this.favorites.filter(x => x.movieId !== delItem.movieId);
                } else {
                  this.viewModel.removeWatching(delItem.movieId);
                  this.watchingList = this.watchingList.filter(x => x.movieId !== delItem.movieId);
                }
              })
            }
          }, (f: UserFavorite) => String(f.movieId))
        }.width('100%').layoutWeight(1).padding(12).backgroundColor('#F5F5F5')
      }
    }.width('100%').height('100%').backgroundColor('#FFFFFF')
  }
}

// ==================== 我的 Tab ====================
@Component
struct ProfileTab {
  @State watchHistory: WatchHistory[] = [];
  @State reviews: UserReview[] = [];
  @State lastHistory: WatchHistory | null = null;
  @Watch('onRefreshFlagChange') @Prop refreshFlag: number = 0;
  private viewModel: ProfileViewModel = new ProfileViewModel();

  onRefreshFlagChange(): void {
    this.viewModel.loadAllData();
  }

  aboutToAppear(): void {
    this.viewModel.onHistoryUpdated = (h: WatchHistory[]) => { this.watchHistory = h; };
    this.viewModel.onReviewsUpdated = (r: UserReview[]) => { this.reviews = r; };
    this.viewModel.onLastHistoryUpdated = (h: WatchHistory | null) => { this.lastHistory = h; };
    this.refreshProfile();
  }

  refreshProfile(): void {
    this.viewModel.loadAllData();
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 8 }) {
          // 用户头
          Column({ space: 12 }) {
            Row({ space: 16 }) {
              Column() { Text('👤').fontSize(28) }.width(64).height(64).backgroundColor('#E8F4FD').borderRadius(32).justifyContent(FlexAlign.Center)
              Column({ space: 4 }) {
                Text(AuthManager.getInstance().getUsername() || '影视爱好者').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333333')
                Text('记录每一部好片').fontSize(13).fontColor('#999999')
              }.alignItems(HorizontalAlign.Start)
            }.width('100%').padding(16)
            Row() {
              Column({ space: 4 }) { Text(String(this.watchHistory.length)).fontSize(20).fontWeight(FontWeight.Bold); Text('观影').fontSize(13).fontColor('#999999') }.layoutWeight(1)
              Column().width(1).height(30).backgroundColor('#E8E8E8')
              Column({ space: 4 }) { Text(String(this.reviews.length)).fontSize(20).fontWeight(FontWeight.Bold); Text('评分').fontSize(13).fontColor('#999999') }.layoutWeight(1)
            }.width('100%').padding({ top: 12, bottom: 12 })
          }.width('100%').backgroundColor('#FFFFFF')

          // 继续观看 — 一键续看
          if (this.lastHistory) {
            Column({ space: 12 }) {
              Row({ space: 12 }) {
                Image(this.lastHistory.posterPath).width(80).height(110).objectFit(ImageFit.Cover).borderRadius(6)
                Column({ space: 8 }) {
                  Text(this.lastHistory.movieTitle).fontSize(16).fontWeight(FontWeight.Medium)
                  if (this.lastHistory.episodeName) {
                    Text(this.lastHistory.episodeName).fontSize(13).fontColor('#4A90D9')
                  }
                  Row({ space: 8 }) {
                    Text('已看 ' + String(Math.floor(this.lastHistory.progress)) + '%').fontSize(12).fontColor('#999999')
                    Text('·').fontSize(12).fontColor('#DDDDDD')
                    Text(DateUtils.getRelativeTime(this.lastHistory.lastWatchTime)).fontSize(12).fontColor('#999999')
                  }
                  Button('一键续看').type(ButtonType.Capsule).backgroundColor('#FF6B35').fontSize(13)
                    .onClick(() => {
                      if (this.lastHistory) {
                        if (this.lastHistory.mediaType === MovieType.TV || this.lastHistory.episodeName) {
                          router.pushUrl({
                            url: 'pages/MovieDetailPage',
                            params: {
                              movieId: this.lastHistory.movieId,
                              mediaType: this.lastHistory.mediaType,
                              seasonNumber: this.lastHistory.seasonNumber,
                              episodeNumber: this.lastHistory.episodeNumber
                            }
                          });
                        } else {
                          router.pushUrl({
                            url: 'pages/PlayerPage',
                            params: {
                              movieTitle: this.lastHistory.movieTitle,
                              posterPath: this.lastHistory.posterPath,
                              movieId: this.lastHistory.movieId,
                              mediaType: this.lastHistory.mediaType
                            }
                          });
                        }
                      }
                    })
                }.alignItems(HorizontalAlign.Start).layoutWeight(1)
              }
            }.padding(16).backgroundColor('#FFFFFF').borderRadius(8).margin({ left: 12, right: 12 })
          }

          // 入口按钮
          Column({ space: 12 }) {
            Button() {
              Row() {
                Text('📺 观看历史').fontSize(16).fontColor('#333333')
                Column().layoutWeight(1)
                Text(String(this.watchHistory.length) + '条').fontSize(14).fontColor('#999999')
                Text('›').fontSize(18).fontColor('#CCCCCC').margin({ left: 8 })
              }.width('100%')
            }
            .type(ButtonType.Normal).backgroundColor('#FFFFFF').borderRadius(8).padding(16)
            .onClick(() => router.pushUrl({ url: 'pages/HistoryPage' }))

            Button() {
              Row() {
                Text('⭐ 我的评分').fontSize(16).fontColor('#333333')
                Column().layoutWeight(1)
                Text(String(this.reviews.length) + '条').fontSize(14).fontColor('#999999')
                Text('›').fontSize(18).fontColor('#CCCCCC').margin({ left: 8 })
              }.width('100%')
            }
            .type(ButtonType.Normal).backgroundColor('#FFFFFF').borderRadius(8).padding(16)
            .onClick(() => router.pushUrl({ url: 'pages/ReviewsPage' }))

            Text('退出登录').fontSize(14).fontColor('#FF4444').width('100%').textAlign(TextAlign.Center)
              .padding(16).backgroundColor('#FFFFFF').borderRadius(8)
              .onClick(async () => {
                await AuthManager.getInstance().logout();
                router.replaceUrl({ url: 'pages/LoginPage' });
              })
          }.width('100%').padding({ left: 12, right: 12 })
        }
      }.scrollable(ScrollDirection.Vertical).layoutWeight(1)
    }.width('100%').height('100%').backgroundColor('#F5F5F5')
  }
}

// ==================== 主入口 ====================
@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  @State profileRefreshFlag: number = 0;
  @State favoritesRefreshFlag: number = 0;

  @Builder
  TabB(title: string, icon: string, idx: number) {
    Column({ space: 2 }) {
      Text(icon).fontSize(22).fontColor(this.currentIndex === idx ? '#4A90D9' : '#999999')
      Text(title).fontSize(11).fontColor(this.currentIndex === idx ? '#4A90D9' : '#999999')
    }.width('100%').height(56).justifyContent(FlexAlign.Center)
  }

  build() {
    Tabs({ barPosition: BarPosition.End }) {
      TabContent() { HomeTab() }.tabBar(this.TabB('首页', '🏠', 0))
      TabContent() { FavoritesTab({ refreshFlag: this.favoritesRefreshFlag }) }.tabBar(this.TabB('收藏', '⭐', 1))
      TabContent() { ProfileTab({ refreshFlag: this.profileRefreshFlag }) }.tabBar(this.TabB('我的', '👤', 2))
    }
    .vertical(false).barMode(BarMode.Fixed).barHeight(56)
    .onChange((i: number) => {
      this.currentIndex = i;
      if (i === 1) { this.favoritesRefreshFlag++; }
      if (i === 2) { this.profileRefreshFlag++; }
    })
    .width('100%').height('100%').backgroundColor('#F5F5F5')
  }
}
