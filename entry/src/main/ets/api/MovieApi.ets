import { http } from '@kit.NetworkKit';
import { MovieInfo, MovieType, TVDetail, EpisodeData, SeasonData } from '../model/MovieModel';

const PAGE = 10;
const IQIYI = 'https://pcw-api.iqiyi.com/search/recommend/list?data_type=1&mode=11&ret_num=50';

// iQiyi 响应
interface IAlbum {
  albumId: number; name: string; imageUrl: string; description: string;
  channelId: number; score: number;
  videoCount: number; latestOrder: number;
  categories: string[]; period: string;
}
interface IData { list: IAlbum[]; has_next: number; }
interface IResp { code: string; data: IData; }

export interface PageResult { items: MovieInfo[]; hasMore: boolean; }

// 类型映射
const GENRE_MAP: Record<string, number> = {
  '动作':28,'冒险':12,'动画':16,'喜剧':35,'犯罪':80,'纪录片':99,'剧情':18,
  '家庭':10751,'奇幻':14,'历史':36,'恐怖':27,'音乐':10402,'悬疑':9648,
  '爱情':10749,'科幻':878,'惊悚':53,'战争':10752,'武侠':28,'都市':18,'古装':36
};
function mapGenres(gs: string[]): number[] {
  const ids: number[] = [];
  for (let i = 0; i < gs.length; i++) {
    const id = GENRE_MAP[gs[i]]; if (id) ids.push(id);
  }
  return ids.length > 0 ? ids : [18];
}

function mapMovie(a: IAlbum, isTV: boolean): MovieInfo {
  const m = new MovieInfo();
  m.id = a.albumId;
  m.title = a.name; m.originalTitle = a.name;
  m.overview = a.description || '';
  m.posterPath = a.imageUrl || 'https://picsum.photos/seed/i' + String(a.albumId % 1000) + '/300/450';
  m.backdropPath = 'https://picsum.photos/seed/ib' + String(a.albumId % 1000) + '/1280/720';
  m.genreIds = mapGenres(a.categories || []);
  m.genres = a.categories || [];
  m.releaseDate = (a.period || '2026') + '-01-01';
  m.voteAverage = a.score || 7.0; m.voteCount = 10000;
  m.popularity = 500;
  m.language = 'zh'; m.runtime = isTV ? 45 : 120;
  m.mediaType = isTV ? MovieType.TV : MovieType.MOVIE;
  m.originCountry = ['CN'];
  return m;
}

async function get(url: string): Promise<Object | null> {
  const req = http.createHttp();
  try {
    const rsp = await req.request(url, { method: http.RequestMethod.GET, connectTimeout: 8000, readTimeout: 8000 });
    req.destroy();
    if (rsp.responseCode === 200) return JSON.parse(rsp.result as string) as Object;
    return null;
  } catch (_e) { req.destroy(); return null; }
}

export class MovieApi {
  private static instance: MovieApi;
  private movies: MovieInfo[] = [];
  private tvs: MovieInfo[] = [];
  private rawTVs: IAlbum[] = [];

  static getInstance(): MovieApi {
    if (!MovieApi.instance) MovieApi.instance = new MovieApi();
    return MovieApi.instance;
  }

  private paginate(data: MovieInfo[], pg: number): PageResult {
    const s = (pg - 1) * PAGE; const e = Math.min(s + PAGE, data.length);
    const items: MovieInfo[] = [];
    for (let i = s; i < e; i++) items.push(data[i]);
    return { items: items, hasMore: e < data.length };
  }

  private async loadChannel(channelId: number, isTV: boolean): Promise<MovieInfo[]> {
    const results: MovieInfo[] = [];
    for (let pg = 1; pg <= 2; pg++) {
      const url = IQIYI + '&channel_id=' + String(channelId) + '&page_id=' + String(pg);
      const obj = await get(url);
      if (!obj) break;
      const r = obj as IResp;
      if (!r.data || !r.data.list) break;
      for (let i = 0; i < r.data.list.length; i++) {
        const album = r.data.list[i];
        results.push(mapMovie(album, isTV));
        if (isTV) { this.rawTVs.push(album); }
      }
      if (r.data.has_next !== 1) break;
    }
    return results;
  }

  private async loadMovies(): Promise<void> {
    if (this.movies.length > 0) return;
    this.movies = await this.loadChannel(1, false);
  }

  private async loadTVs(): Promise<void> {
    if (this.tvs.length > 0) return;
    this.tvs = await this.loadChannel(2, true);
  }

  async getPopularMovies(page: number): Promise<PageResult> {
    await this.loadMovies();
    return this.paginate(this.movies, page);
  }

  async getPopularTVs(page: number): Promise<PageResult> {
    await this.loadTVs();
    return this.paginate(this.tvs, page);
  }

  async getMovieDetail(movieId: number): Promise<MovieInfo> {
    await this.loadMovies();
    for (let i = 0; i < this.movies.length; i++) {
      if (this.movies[i].id === movieId) return this.movies[i];
    }
    return new MovieInfo();
  }

  async getTVDetail(tvId: number): Promise<TVDetail> {
    await this.loadTVs();
    let base: MovieInfo | null = null;
    for (let i = 0; i < this.tvs.length; i++) {
      if (this.tvs[i].id === tvId) { base = this.tvs[i]; break; }
    }
    if (!base) return new TVDetail();

    // 从缓存的原始数据中取 videoCount/latestOrder
    let totalEps = 24; let latestEp = 10;
    for (let i = 0; i < this.rawTVs.length; i++) {
      if (this.rawTVs[i].albumId === tvId) {
        totalEps = this.rawTVs[i].videoCount || 24;
        latestEp = this.rawTVs[i].latestOrder || totalEps;
        break;
      }
    }

    const d = new TVDetail();
    d.id = base.id; d.title = base.title; d.originalTitle = base.originalTitle;
    d.overview = base.overview; d.posterPath = base.posterPath; d.backdropPath = base.backdropPath;
    d.genreIds = base.genreIds; d.genres = base.genres;
    d.voteAverage = base.voteAverage; d.popularity = base.popularity;
    d.language = base.language; d.runtime = 45;
    d.mediaType = MovieType.TV; d.originCountry = base.originCountry;
    d.numberOfEpisodes = totalEps;
    d.inProduction = latestEp < totalEps; d.numberOfSeasons = 1;

    // 全部集数放一个季
    const allSeasons: SeasonData[] = [];
    allSeasons.push({ id: 1, name: '全' + String(totalEps) + '集', overview: '', airDate: '2026-01-01', seasonNumber: 1, episodeCount: totalEps, posterPath: '' });
    d.seasons = allSeasons;
    // 下一集
    const nextEp = latestEp < totalEps ? latestEp + 1 : totalEps;
    const ep: EpisodeData = { id: tvId * 100 + nextEp, name: '第' + String(nextEp) + '集', overview: '即将播出', airDate: '2026-07-10', episodeNumber: nextEp, seasonNumber: 1, stillPath: '', voteAverage: 7, runtime: 45 };
    d.nextEpisodeToAir = ep;
    return d;
  }

  async searchMovies(query: string): Promise<MovieInfo[]> {
    await this.loadMovies();
    await this.loadTVs();
    const all: MovieInfo[] = [];
    for (let i = 0; i < this.movies.length; i++) all.push(this.movies[i]);
    for (let i = 0; i < this.tvs.length; i++) all.push(this.tvs[i]);
    const q = query.toLowerCase().trim();
    const result: MovieInfo[] = [];
    for (let i = 0; i < all.length; i++) {
      if (all[i].title.toLowerCase().indexOf(q) >= 0) result.push(all[i]);
    }
    return result;
  }

  async getAllMovies(): Promise<MovieInfo[]> { await this.loadMovies(); return this.movies; }
  async getAllTVs(): Promise<MovieInfo[]> { await this.loadTVs(); return this.tvs; }

  async getTrailerUrl(_id?: number, _type?: MovieType): Promise<string> {
    return 'http://10.0.2.2:3000/video/demo.mp4';
  }

  async getTodayUpdates(): Promise<MovieInfo[]> {
    await this.loadTVs();
    return this.tvs.slice(0, 6);
  }
}
