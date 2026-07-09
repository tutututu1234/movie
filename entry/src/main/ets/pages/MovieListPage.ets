import { MovieInfo } from '../model/MovieModel';
import { MovieApi } from '../api/MovieApi';
import { FilterBar } from '../components/FilterBar';
import { promptAction, router } from '@kit.ArkUI';

@Entry
@Component
struct MovieListPage {
  @State list: MovieInfo[] = [];
  @State isLoading: boolean = true;
  @State title: string = '';
  @State currPage: number = 1;
  @State totalPages: number = 1;
  @State allCache: MovieInfo[] = [];

  private api: MovieApi = MovieApi.getInstance();
  private listType: string = 'movie';

  aboutToAppear(): void {
    const p = router.getParams() as Record<string, Object>;
    if (p) {
      const t: string = String(p['type'] || 'movie');
      this.listType = t;
      if (t === 'search') {
        this.title = '搜索: ' + String(p['keyword'] || '');
        this.doSearch(String(p['keyword'] || ''));
        return;
      }
      this.title = t === 'movie' ? '全部影片' : '全部电视剧';
    }
    this.init();
  }

  private async init(): Promise<void> {
    this.isLoading = true;
    // 加载全量
    if (this.listType === 'movie') {
      this.allCache = await this.api.getAllMovies();
    } else {
      this.allCache = await this.api.getAllTVs();
    }
    this.totalPages = Math.ceil(this.allCache.length / 10);
    if (this.totalPages < 1) this.totalPages = 1;
    this.gotoPage(1);
  }

  private gotoPage(pg: number): void {
    this.currPage = pg;
    const s = (pg - 1) * 10;
    const e = Math.min(s + 10, this.allCache.length);
    const items: MovieInfo[] = [];
    for (let i = s; i < e; i++) items.push(this.allCache[i]);
    this.list = items;
    this.isLoading = false;
  }

  private async doSearch(keyword: string): Promise<void> {
    this.isLoading = true;
    this.list = await this.api.searchMovies(keyword);
    this.allCache = this.list;
    this.totalPages = 1;
    this.isLoading = false;
  }

  private applyFilter(genre: string, region: string, year: string, sort: string): void {
    let filtered: MovieInfo[] = [];
    const src = this.allCache;
    if (genre !== 'all') {
      const gid = parseInt(genre);
      for (let i = 0; i < src.length; i++) {
        if (src[i].genreIds.indexOf(gid) >= 0) filtered.push(src[i]);
      }
    } else {
      for (let i = 0; i < src.length; i++) filtered.push(src[i]);
    }
    if (region !== 'all') {
      const rm: Record<string, string> = { '中国大陆': 'CN', '中国香港': 'HK', '中国台湾': 'TW', '美国': 'US', '日本': 'JP', '韩国': 'KR' };
      const code = rm[region] || '';
      const rf: MovieInfo[] = [];
      for (let i = 0; i < filtered.length; i++) {
        if (filtered[i].originCountry.indexOf(code) >= 0) rf.push(filtered[i]);
      }
      filtered = rf;
    }
    if (year !== 'all') {
      const yf: MovieInfo[] = [];
      for (let i = 0; i < filtered.length; i++) {
        if (filtered[i].releaseDate.indexOf(year) === 0) yf.push(filtered[i]);
      }
      filtered = yf;
    }
    if (sort === 'vote_average') {
      for (let i = 0; i < filtered.length; i++) {
        for (let j = 0; j < filtered.length - 1 - i; j++) {
          if (filtered[j].voteAverage < filtered[j + 1].voteAverage) { const t = filtered[j]; filtered[j] = filtered[j + 1]; filtered[j + 1] = t; }
        }
      }
    } else if (sort === 'release_date') {
      for (let i = 0; i < filtered.length; i++) {
        for (let j = 0; j < filtered.length - 1 - i; j++) {
          if (filtered[j].releaseDate < filtered[j + 1].releaseDate) { const t = filtered[j]; filtered[j] = filtered[j + 1]; filtered[j + 1] = t; }
        }
      }
    }
    this.allCache = filtered;
    this.totalPages = Math.ceil(filtered.length / 10);
    if (this.totalPages < 1) this.totalPages = 1;
    this.gotoPage(1);
    promptAction.showToast({ message: '共' + String(filtered.length) + '部' });
  }

  @Builder
  PageBar() {
    Row({ space: 4 }) {
      Button('上一页').fontSize(12).height(32).backgroundColor('#E8F4FD')
        .enabled(this.currPage > 1)
        .onClick(() => { if (this.currPage > 1) this.gotoPage(this.currPage - 1); })

      ForEach(this.getPageNumbers(), (pg: number) => {
        Text(String(pg))
          .fontSize(14).fontColor(pg === this.currPage ? '#FFFFFF' : '#666666')
          .backgroundColor(pg === this.currPage ? '#4A90D9' : '#F0F0F0')
          .borderRadius(16).width(32).height(32).textAlign(TextAlign.Center)
          .onClick(() => { this.gotoPage(pg); })
      }, (pg: number) => String(pg))

      Button('下一页').fontSize(12).height(32).backgroundColor('#E8F4FD')
        .enabled(this.currPage < this.totalPages)
        .onClick(() => { if (this.currPage < this.totalPages) this.gotoPage(this.currPage + 1); })
    }
    .width('100%').justifyContent(FlexAlign.Center).padding({ top: 8, bottom: 16 })
  }

  private getPageNumbers(): number[] {
    const pages: number[] = [];
    const start = Math.max(1, this.currPage - 2);
    const end = Math.min(this.totalPages, start + 4);
    for (let i = start; i <= end; i++) pages.push(i);
    return pages;
  }

  build() {
    Column() {
      Row() {
        Button() { Text('‹').fontSize(28).fontColor('#333333') }
          .type(ButtonType.Circle).backgroundColor('transparent').onClick(() => { router.back(); })
        Text(this.title).fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1).margin({ left: 12 })
      }.width('100%').padding(12).backgroundColor('#FFFFFF')

      if (this.listType !== 'search') {
        FilterBar({ onFilterChange: (g: string, r: string, y: string, s: string) => { this.applyFilter(g, r, y, s); } })
      }

      if (this.isLoading) {
        Column() { LoadingProgress().width(40).height(40).color('#4A90D9') }.layoutWeight(1).justifyContent(FlexAlign.Center)
      } else if (this.list.length === 0) {
        Column() { Text('暂无内容').fontSize(16).fontColor('#999999') }.layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        Column() {
          Scroll() {
            Grid() {
              ForEach(this.list, (m: MovieInfo) => {
                GridItem() {
                  Column() {
                    Image(m.posterPath).width('100%').aspectRatio(3 / 4).objectFit(ImageFit.Cover).borderRadius(8)
                    Text(m.title).fontSize(13).maxLines(1).width('100%').margin({ top: 4 })
                    Row() {
                      Text('★').fontSize(11).fontColor('#FFB800')
                      Text(String(Number(m.voteAverage).toFixed(1))).fontSize(11).fontColor('#FFB800')
                    }
                  }.onClick(() => { router.pushUrl({ url: 'pages/MovieDetailPage', params: { movieId: m.id, mediaType: m.mediaType } }); })
                }
              }, (m: MovieInfo) => String(m.id))
            }
            .columnsTemplate('1fr 1fr 1fr').columnsGap(8).rowsGap(12).padding(12)
          }
          .scrollable(ScrollDirection.Vertical).edgeEffect(EdgeEffect.Spring).layoutWeight(1)

          this.PageBar()
        }
        .width('100%').layoutWeight(1)
      }
    }
    .width('100%').height('100%').backgroundColor('#F5F5F5')
  }
}
