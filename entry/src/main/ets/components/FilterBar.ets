import { getGenreEntries, GenreEntry, REGION_LIST, YEAR_LIST, SORT_OPTIONS, SortOption } from '../model/MovieModel';

@Component
export struct FilterBar {
  @State selectedGenre: string = 'all';
  @State selectedRegion: string = 'all';
  @State selectedYear: string = 'all';
  @State selectedSort: string = 'popularity';
  @State showFilterPanel: boolean = false;
  @State activeFilterType: string = '';

  onFilterChange: (genre: string, region: string, year: string, sort: string) => void =
    (_genre: string, _region: string, _year: string, _sort: string) => {};

  private genreEntries: GenreEntry[] = getGenreEntries();
  private sortEntries: SortOption[] = SORT_OPTIONS;

  // 判断某个筛选是否有非默认值（决定是否高亮）
  private isActive(type: string): boolean {
    if (type === 'genre') return this.selectedGenre !== 'all';
    if (type === 'region') return this.selectedRegion !== 'all';
    if (type === 'year') return this.selectedYear !== 'all';
    if (type === 'sort') return this.selectedSort !== 'popularity';
    return false;
  }

  private getGenreLabel(): string {
    if (this.selectedGenre === 'all') return '类型';
    const id: number = parseInt(this.selectedGenre);
    for (let i = 0; i < this.genreEntries.length; i++) {
      if (this.genreEntries[i].key === id) return this.genreEntries[i].label;
    }
    return '类型';
  }

  private getSortLabel(): string {
    for (let i = 0; i < this.sortEntries.length; i++) {
      if (this.sortEntries[i].key === this.selectedSort) return this.sortEntries[i].label;
    }
    return '排序';
  }

  // 按钮标签：有筛选值用值，否则用默认
  private btnLabel(type: string): string {
    if (type === 'genre') return this.getGenreLabel();
    if (type === 'region') return this.selectedRegion === 'all' ? '地区' : this.selectedRegion;
    if (type === 'year') return this.selectedYear === 'all' ? '年份' : this.selectedYear;
    if (type === 'sort') return this.getSortLabel();
    return '';
  }

  // 按钮是否高亮：面板展开中 || 已有筛选值
  private btnHighlighted(type: string): boolean {
    return this.activeFilterType === type || this.isActive(type);
  }

  @Builder
  FilterButton(type: string) {
    Row() {
      Text(this.btnLabel(type))
        .fontSize(13)
        .fontColor(this.btnHighlighted(type) ? '#4A90D9' : '#666666')
        .fontWeight(this.btnHighlighted(type) ? FontWeight.Bold : FontWeight.Normal)

      Text('▼').fontSize(10)
        .fontColor(this.btnHighlighted(type) ? '#4A90D9' : '#999999')
        .margin({ left: 2 })
    }
    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
    .backgroundColor(this.btnHighlighted(type) ? '#E8F4FD' : '#F5F5F5')
    .borderRadius(16)
    .border({ width: this.isActive(type) ? 1 : 0, color: '#4A90D9' })
    .onClick(() => {
      if (this.activeFilterType === type) {
        this.activeFilterType = '';
        this.showFilterPanel = false;
      } else {
        this.activeFilterType = type;
        this.showFilterPanel = true;
      }
    })
  }

  @Builder
  GenreList() {
    Scroll() {
      Column() {
        Row() {
          Text('全部').fontSize(14)
            .fontColor(this.selectedGenre === 'all' ? '#4A90D9' : '#333333')
            .fontWeight(this.selectedGenre === 'all' ? FontWeight.Bold : FontWeight.Normal)
        }.width('100%').padding(12)
        .onClick(() => { this.selectedGenre = 'all'; this.closePanelAndNotify(); })

        ForEach(this.genreEntries, (entry: GenreEntry) => {
          Row() {
            Text(entry.label).fontSize(14)
              .fontColor(this.selectedGenre === String(entry.key) ? '#4A90D9' : '#333333')
              .fontWeight(this.selectedGenre === String(entry.key) ? FontWeight.Bold : FontWeight.Normal)
          }.width('100%').padding(12)
          .onClick(() => { this.selectedGenre = String(entry.key); this.closePanelAndNotify(); })
        }, (entry: GenreEntry) => String(entry.key))
      }.width('100%')
    }
    .height(280).backgroundColor('#FFFFFF').borderRadius(8).padding(8)
  }

  @Builder
  RegionList() {
    Scroll() {
      Column() {
        Row() {
          Text('全部').fontSize(14)
            .fontColor(this.selectedRegion === 'all' ? '#4A90D9' : '#333333')
            .fontWeight(this.selectedRegion === 'all' ? FontWeight.Bold : FontWeight.Normal)
        }.width('100%').padding(12)
        .onClick(() => { this.selectedRegion = 'all'; this.closePanelAndNotify(); })

        ForEach(REGION_LIST, (region: string) => {
          Row() {
            Text(region).fontSize(14)
              .fontColor(this.selectedRegion === region ? '#4A90D9' : '#333333')
              .fontWeight(this.selectedRegion === region ? FontWeight.Bold : FontWeight.Normal)
          }.width('100%').padding(12)
          .onClick(() => { this.selectedRegion = region; this.closePanelAndNotify(); })
        }, (region: string) => region)
      }.width('100%')
    }
    .height(280).backgroundColor('#FFFFFF').borderRadius(8).padding(8)
  }

  @Builder
  YearList() {
    Scroll() {
      Column() {
        Row() {
          Text('全部').fontSize(14)
            .fontColor(this.selectedYear === 'all' ? '#4A90D9' : '#333333')
            .fontWeight(this.selectedYear === 'all' ? FontWeight.Bold : FontWeight.Normal)
        }.width('100%').padding(12)
        .onClick(() => { this.selectedYear = 'all'; this.closePanelAndNotify(); })

        ForEach(YEAR_LIST, (year: string) => {
          Row() {
            Text(year).fontSize(14)
              .fontColor(this.selectedYear === year ? '#4A90D9' : '#333333')
              .fontWeight(this.selectedYear === year ? FontWeight.Bold : FontWeight.Normal)
          }.width('100%').padding(12)
          .onClick(() => { this.selectedYear = year; this.closePanelAndNotify(); })
        }, (year: string) => year)
      }.width('100%')
    }
    .height(280).backgroundColor('#FFFFFF').borderRadius(8).padding(8)
  }

  @Builder
  SortList() {
    Scroll() {
      Column() {
        ForEach(this.sortEntries, (entry: SortOption) => {
          Row() {
            Text(entry.label).fontSize(14)
              .fontColor(this.selectedSort === entry.key ? '#4A90D9' : '#333333')
              .fontWeight(this.selectedSort === entry.key ? FontWeight.Bold : FontWeight.Normal)
          }.width('100%').padding(12)
          .onClick(() => { this.selectedSort = entry.key; this.closePanelAndNotify(); })
        }, (entry: SortOption) => entry.key)
      }.width('100%')
    }
    .height(200).backgroundColor('#FFFFFF').borderRadius(8).padding(8)
  }

  build() {
    Column() {
      Row({ space: 8 }) {
        this.FilterButton('genre')
        this.FilterButton('region')
        this.FilterButton('year')
        this.FilterButton('sort')
      }.width('100%').padding(12)

      if (this.showFilterPanel) {
        if (this.activeFilterType === 'genre') { this.GenreList() }
        else if (this.activeFilterType === 'region') { this.RegionList() }
        else if (this.activeFilterType === 'year') { this.YearList() }
        else if (this.activeFilterType === 'sort') { this.SortList() }
      }
    }
    .width('100%').backgroundColor('#FFFFFF')
  }

  private closePanelAndNotify(): void {
    this.showFilterPanel = false;
    this.activeFilterType = '';
    this.notifyFilterChange();
  }

  private notifyFilterChange(): void {
    this.onFilterChange(this.selectedGenre, this.selectedRegion, this.selectedYear, this.selectedSort);
  }
}
