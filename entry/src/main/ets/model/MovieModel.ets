
// 影视类型枚举
export enum MovieType {
  MOVIE = 'movie',
  TV = 'tv'
}

// 影视基础信息接口
export interface MovieInfoData {
  id: number;
  title: string;
  originalTitle: string;
  overview: string;
  posterPath: string;
  backdropPath: string;
  genreIds: number[];
  genres: string[];
  releaseDate: string;
  voteAverage: number;
  voteCount: number;
  popularity: number;
  mediaType: MovieType;
  language: string;
  runtime: number;
  status: string;
  tagline: string;
  homepage: string;
  imdbId: string;
  originCountry: string[];
}

// 影视基础信息类
export class MovieInfo implements MovieInfoData {
  id: number = 0;
  title: string = '';
  originalTitle: string = '';
  overview: string = '';
  posterPath: string = '';
  backdropPath: string = '';
  genreIds: number[] = [];
  genres: string[] = [];
  releaseDate: string = '';
  voteAverage: number = 0;
  voteCount: number = 0;
  popularity: number = 0;
  mediaType: MovieType = MovieType.MOVIE;
  language: string = '';
  runtime: number = 0;
  status: string = '';
  tagline: string = '';
  homepage: string = '';
  imdbId: string = '';
  originCountry: string[] = [];
}

// 剧集信息接口
export interface EpisodeData {
  id: number;
  name: string;
  overview: string;
  airDate: string;
  episodeNumber: number;
  seasonNumber: number;
  stillPath: string;
  voteAverage: number;
  runtime: number;
}

// 季信息接口
export interface SeasonData {
  id: number;
  name: string;
  overview: string;
  airDate: string;
  seasonNumber: number;
  episodeCount: number;
  posterPath: string;
}

// 电视剧详情接口
export interface TVDetailData extends MovieInfoData {
  numberOfSeasons: number;
  numberOfEpisodes: number;
  seasons: SeasonData[];
  lastAirDate: string;
  inProduction: boolean;
  nextEpisodeToAir: EpisodeData | null;
  lastEpisodeToAir: EpisodeData | null;
}

// 电视剧详情
export class TVDetail extends MovieInfo implements TVDetailData {
  numberOfSeasons: number = 0;
  numberOfEpisodes: number = 0;
  seasons: SeasonData[] = [];
  lastAirDate: string = '';
  inProduction: boolean = false;
  nextEpisodeToAir: EpisodeData | null = null;
  lastEpisodeToAir: EpisodeData | null = null;

  constructor() {
    super();
    this.mediaType = MovieType.TV;
  }
}

// 用户评分与短评接口
export interface UserReviewData {
  id: number;
  movieId: number;
  movieTitle: string;
  rating: number;
  review: string;
  createTime: number;
  updateTime: number;
}

// 用户评分与短评
export class UserReview implements UserReviewData {
  id: number = 0;
  movieId: number = 0;
  movieTitle: string = '';
  rating: number = 0;
  review: string = '';
  createTime: number = 0;
  updateTime: number = 0;
}

// 用户收藏接口
export interface UserFavoriteData {
  id: number;
  movieId: number;
  movieTitle: string;
  posterPath: string;
  mediaType: MovieType;
  addTime: number;
  currentEpisode: number;
  currentSeason: number;
  totalEpisodes: number;
  watchProgress: number;
  isWatching: boolean;
}

// 用户收藏
export class UserFavorite implements UserFavoriteData {
  id: number = 0;
  movieId: number = 0;
  movieTitle: string = '';
  posterPath: string = '';
  mediaType: MovieType = MovieType.MOVIE;
  addTime: number = 0;
  currentEpisode: number = 0;
  currentSeason: number = 0;
  totalEpisodes: number = 0;
  watchProgress: number = 0;
  isWatching: boolean = false;
}

// 观看历史接口
export interface WatchHistoryData {
  id: number;
  movieId: number;
  movieTitle: string;
  posterPath: string;
  mediaType: MovieType;
  episodeId: number;
  episodeName: string;
  seasonNumber: number;
  episodeNumber: number;
  watchTime: number;
  duration: number;
  progress: number;
  lastWatchTime: number;
}

// 观看历史
export class WatchHistory implements WatchHistoryData {
  id: number = 0;
  movieId: number = 0;
  movieTitle: string = '';
  posterPath: string = '';
  mediaType: MovieType = MovieType.MOVIE;
  episodeId: number = 0;
  episodeName: string = '';
  seasonNumber: number = 0;
  episodeNumber: number = 0;
  watchTime: number = 0;
  duration: number = 0;
  progress: number = 0;
  lastWatchTime: number = 0;
}

// 分类数据 - 使用string类型的key
export interface GenreEntry {
  key: number;
  label: string;
}

export function getGenreEntries(): GenreEntry[] {
  return [
    { key: 28, label: '动作' }, { key: 12, label: '冒险' },
    { key: 16, label: '动画' }, { key: 35, label: '喜剧' },
    { key: 80, label: '犯罪' }, { key: 99, label: '纪录' },
    { key: 18, label: '剧情' }, { key: 10751, label: '家庭' },
    { key: 14, label: '奇幻' }, { key: 36, label: '历史' },
    { key: 27, label: '恐怖' }, { key: 10402, label: '音乐' },
    { key: 9648, label: '悬疑' }, { key: 10749, label: '爱情' },
    { key: 878, label: '科幻' }, { key: 10770, label: '电视电影' },
    { key: 53, label: '惊悚' }, { key: 10752, label: '战争' },
    { key: 37, label: '西部' }
  ];
}

export function getGenreLabel(key: number): string {
  const entries = getGenreEntries();
  for (let i = 0; i < entries.length; i++) {
    if (entries[i].key === key) {
      return entries[i].label;
    }
  }
  return String(key);
}

export const REGION_LIST: string[] = ['中国大陆', '中国香港', '中国台湾', '美国', '日本', '韩国', '英国', '法国', '德国', '泰国'];

export const YEAR_LIST: string[] = ['2026', '2025', '2024', '2023', '2022', '2021', '2020', '2019', '2018', '2017', '2016', '2015'];

export interface SortOption {
  key: string;
  label: string;
}

export const SORT_OPTIONS: SortOption[] = [
  { key: 'popularity', label: '热度' },
  { key: 'vote_average', label: '评分' },
  { key: 'release_date', label: '上映时间' }
];
