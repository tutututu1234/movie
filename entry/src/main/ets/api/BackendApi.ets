import { http } from '@kit.NetworkKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AuthManager } from '../utils/AuthManager';

const DOMAIN = 0x0000;
const TAG = 'BackendApi';

// 后端服务地址 — 模拟器用 10.0.2.2 访问宿主机 localhost
const BASE_URL: string = 'http://10.0.2.2:3000/api';

// ========== 数据类型定义 ==========

export interface LoginResult {
  token: string;
  userId: number;
  username: string;
  phone: string;
  avatar: string;
}

interface ApiResponseData {
  code: number;
  message: string;
  data: Object | null;
}

export interface FavoriteData {
  id: number;
  user_id: number;
  movie_id: number;
  movie_title: string;
  poster_path: string;
  media_type: string;
  current_episode: number;
  current_season: number;
  total_episodes: number;
  watch_progress: number;
  is_watching: number;
  add_time: number;
}

export interface ReviewData {
  id: number;
  user_id: number;
  movie_id: number;
  movie_title: string;
  rating: number;
  review: string;
  create_time: number;
  update_time: number;
}

export interface HistoryData {
  id: number;
  user_id: number;
  movie_id: number;
  movie_title: string;
  poster_path: string;
  media_type: string;
  episode_id: number;
  episode_name: string;
  season_number: number;
  episode_number: number;
  watch_time: number;
  duration: number;
  progress: number;
  last_watch_time: number;
}

// ========== 请求体类（ArkTS 要求显式类型） ==========

class RegisterBody {
  username: string;
  phone: string;
  password: string;

  constructor(username: string, phone: string, password: string) {
    this.username = username;
    this.phone = phone;
    this.password = password;
  }
}

class LoginBody {
  phone: string;
  password: string;

  constructor(phone: string, password: string) {
    this.phone = phone;
    this.password = password;
  }
}

class AddFavoriteBody {
  movieId: number;
  movieTitle: string;
  posterPath: string;
  mediaType: string;

  constructor(movieId: number, movieTitle: string, posterPath: string, mediaType: string) {
    this.movieId = movieId;
    this.movieTitle = movieTitle;
    this.posterPath = posterPath;
    this.mediaType = mediaType;
  }
}

class AddWatchingBody {
  movieId: number;
  movieTitle: string;
  posterPath: string;
  mediaType: string;
  totalEpisodes: number;

  constructor(movieId: number, movieTitle: string, posterPath: string, mediaType: string, totalEpisodes: number) {
    this.movieId = movieId;
    this.movieTitle = movieTitle;
    this.posterPath = posterPath;
    this.mediaType = mediaType;
    this.totalEpisodes = totalEpisodes;
  }
}

class UpdateProgressBody {
  currentEpisode: number;
  currentSeason: number;
  watchProgress: number;

  constructor(currentEpisode: number, currentSeason: number, watchProgress: number) {
    this.currentEpisode = currentEpisode;
    this.currentSeason = currentSeason;
    this.watchProgress = watchProgress;
  }
}

class SaveReviewBody {
  movieId: number;
  movieTitle: string;
  rating: number;
  review: string;

  constructor(movieId: number, movieTitle: string, rating: number, review: string) {
    this.movieId = movieId;
    this.movieTitle = movieTitle;
    this.rating = rating;
    this.review = review;
  }
}

class AddHistoryBody {
  movieId: number;
  movieTitle: string;
  posterPath: string;
  mediaType: string;
  episodeId: number;
  episodeName: string;
  seasonNumber: number;
  episodeNumber: number;
  watchTime: number;
  duration: number;
  progress: number;

  constructor(
    movieId: number, movieTitle: string, posterPath: string,
    mediaType: string, episodeId: number, episodeName: string,
    seasonNumber: number, episodeNumber: number,
    watchTime: number, duration: number, progress: number
  ) {
    this.movieId = movieId;
    this.movieTitle = movieTitle;
    this.posterPath = posterPath;
    this.mediaType = mediaType;
    this.episodeId = episodeId;
    this.episodeName = episodeName;
    this.seasonNumber = seasonNumber;
    this.episodeNumber = episodeNumber;
    this.watchTime = watchTime;
    this.duration = duration;
    this.progress = progress;
  }
}

// ========== BackendApi ==========

export class BackendApi {
  private static instance: BackendApi;

  private constructor() {}

  static getInstance(): BackendApi {
    if (!BackendApi.instance) {
      BackendApi.instance = new BackendApi();
    }
    return BackendApi.instance;
  }

  private getAuthHeaders(): Record<string, string> {
    const token: string = AuthManager.getInstance().getToken();
    const headers: Record<string, string> = {};
    headers['Content-Type'] = 'application/json';
    if (token.length > 0) {
      headers['Authorization'] = 'Bearer ' + token;
    }
    return headers;
  }

  private async request(method: http.RequestMethod, path: string, body: Object | null): Promise<ApiResponseData> {
    const httpRequest = http.createHttp();
    try {
      const url: string = BASE_URL + path;
      const reqOpt: Record<string, Object> = {};
      reqOpt['method'] = method;
      reqOpt['header'] = this.getAuthHeaders();
      reqOpt['connectTimeout'] = 5000;
      reqOpt['readTimeout'] = 5000;
      if (body) { reqOpt['extraData'] = JSON.stringify(body); }
      const response = await httpRequest.request(url, reqOpt);
      httpRequest.destroy();

      if (response.responseCode === 200 || response.responseCode === 201) {
        const result: ApiResponseData = JSON.parse(response.result as string) as ApiResponseData;
        if (result.code !== 0) {
          throw new Error(result.message || '请求失败');
        }
        return result;
      } else {
        const errorResult: ApiResponseData = JSON.parse(response.result as string) as ApiResponseData;
        throw new Error(errorResult.message || '服务器错误(' + String(response.responseCode) + ')');
      }
    } catch (err) {
      httpRequest.destroy();
      const errMsg: string = err instanceof Error ? err.message : '网络请求失败';
      hilog.error(DOMAIN, TAG, 'Request failed: %{public}s', errMsg);
      throw new Error(errMsg);
    }
  }

  // ========== 认证 ==========

  async register(username: string, phone: string, password: string): Promise<LoginResult> {
    const body: RegisterBody = new RegisterBody(username, phone, password);
    const result = await this.request(http.RequestMethod.POST, '/auth/register', body);
    return result.data as LoginResult;
  }

  async login(phone: string, password: string): Promise<LoginResult> {
    const body: LoginBody = new LoginBody(phone, password);
    const result = await this.request(http.RequestMethod.POST, '/auth/login', body);
    return result.data as LoginResult;
  }

  // ========== 收藏 ==========

  async getFavorites(): Promise<FavoriteData[]> {
    const result = await this.request(http.RequestMethod.GET, '/favorites', null);
    return (result.data || []) as FavoriteData[];
  }

  async addFavorite(movieId: number, movieTitle: string, posterPath: string,
    mediaType: string): Promise<boolean> {
    const body: AddFavoriteBody = new AddFavoriteBody(movieId, movieTitle, posterPath, mediaType);
    await this.request(http.RequestMethod.POST, '/favorites', body);
    return true;
  }

  async removeFavorite(movieId: number): Promise<boolean> {
    await this.request(http.RequestMethod.DELETE, '/favorites/' + String(movieId), null);
    return true;
  }

  // ========== 追剧 ==========

  async getWatchingList(): Promise<FavoriteData[]> {
    const result = await this.request(http.RequestMethod.GET, '/watching', null);
    return (result.data || []) as FavoriteData[];
  }

  async addWatching(movieId: number, movieTitle: string, posterPath: string,
    mediaType: string, totalEpisodes: number): Promise<boolean> {
    const body: AddWatchingBody = new AddWatchingBody(movieId, movieTitle, posterPath, mediaType, totalEpisodes);
    await this.request(http.RequestMethod.POST, '/watching', body);
    return true;
  }

  async removeWatching(movieId: number): Promise<boolean> {
    await this.request(http.RequestMethod.DELETE, '/watching/' + String(movieId), null);
    return true;
  }

  async updateWatchingProgress(movieId: number, currentEpisode: number,
    currentSeason: number, watchProgress: number): Promise<boolean> {
    const body: UpdateProgressBody = new UpdateProgressBody(currentEpisode, currentSeason, watchProgress);
    await this.request(http.RequestMethod.PUT, '/watching/' + String(movieId), body);
    return true;
  }

  // ========== 评分 ==========

  async getReviews(): Promise<ReviewData[]> {
    const result = await this.request(http.RequestMethod.GET, '/reviews', null);
    return (result.data || []) as ReviewData[];
  }

  async getReview(movieId: number): Promise<ReviewData | null> {
    const result = await this.request(http.RequestMethod.GET, '/reviews/' + String(movieId), null);
    return result.data as ReviewData | null;
  }

  async saveReview(movieId: number, movieTitle: string, rating: number, review: string): Promise<boolean> {
    const body: SaveReviewBody = new SaveReviewBody(movieId, movieTitle, rating, review);
    await this.request(http.RequestMethod.POST, '/reviews', body);
    return true;
  }

  async deleteReview(movieId: number): Promise<boolean> {
    await this.request(http.RequestMethod.DELETE, '/reviews/' + String(movieId), null);
    return true;
  }

  // ========== 观看历史 ==========

  async getHistory(): Promise<HistoryData[]> {
    const result = await this.request(http.RequestMethod.GET, '/history', null);
    return (result.data || []) as HistoryData[];
  }

  async getLastHistory(): Promise<HistoryData | null> {
    const result = await this.request(http.RequestMethod.GET, '/history/last/record', null);
    return result.data as HistoryData | null;
  }

  async addHistory(
    movieId: number, movieTitle: string, posterPath: string,
    mediaType: string, episodeId: number, episodeName: string,
    seasonNumber: number, episodeNumber: number,
    watchTime: number, duration: number, progress: number
  ): Promise<boolean> {
    const body: AddHistoryBody = new AddHistoryBody(
      movieId, movieTitle, posterPath, mediaType,
      episodeId, episodeName, seasonNumber, episodeNumber,
      watchTime, duration, progress
    );
    await this.request(http.RequestMethod.POST, '/history', body);
    return true;
  }

  async clearHistory(): Promise<boolean> {
    await this.request(http.RequestMethod.DELETE, '/history', null);
    return true;
  }
}
