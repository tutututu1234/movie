import { MovieInfo, MovieType, TVDetail, UserReview } from '../model/MovieModel';
import { MovieApi } from '../api/MovieApi';
import { BackendApi } from '../api/BackendApi';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const TAG = 'MovieDetailViewModel';

export class MovieDetailViewModel {
  private movieApi: MovieApi;
  private backend: BackendApi;

  movieDetail: MovieInfo | null = null;
  tvDetail: TVDetail | null = null;
  isFavorite: boolean = false;
  userReview: UserReview | null = null;
  trailerUrl: string = '';

  onDetailLoaded: (detail: MovieInfo | TVDetail) => void = () => {};
  onFavoriteChanged: (isFavorite: boolean) => void = () => {};
  onReviewLoaded: (review: UserReview | null) => void = () => {};
  onTrailerLoaded: (url: string) => void = () => {};
  onError: (msg: string) => void = () => {};

  constructor() {
    this.movieApi = MovieApi.getInstance();
    this.backend = BackendApi.getInstance();
  }

  async loadMovieDetail(movieId: number, mediaType: MovieType): Promise<void> {
    try {
      if (mediaType === MovieType.TV) {
        const detail = await this.movieApi.getTVDetail(movieId);
        this.tvDetail = detail; this.movieDetail = detail;
        this.onDetailLoaded(detail);
      } else {
        const detail = await this.movieApi.getMovieDetail(movieId);
        this.movieDetail = detail;
        this.onDetailLoaded(detail);
      }
      await this.loadFavoriteStatus(movieId);
      await this.loadUserReview(movieId);
      await this.loadTrailer(movieId, mediaType);
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Load detail failed');
      this.onError('加载详情失败');
    }
  }

  async loadFavoriteStatus(movieId: number): Promise<void> {
    try {
      const list = await this.backend.getFavorites();
      this.isFavorite = false;
      for (let i = 0; i < list.length; i++) {
        if (list[i].movie_id === movieId) { this.isFavorite = true; break; }
      }
    } catch (_e) { this.isFavorite = false; }
    this.onFavoriteChanged(this.isFavorite);
  }

  async toggleFavorite(): Promise<void> {
    if (!this.movieDetail) return;
    try {
      if (this.isFavorite) {
        await this.backend.removeFavorite(this.movieDetail.id);
        this.isFavorite = false;
      } else {
        await this.backend.addFavorite(
          this.movieDetail.id, this.movieDetail.title,
          this.movieDetail.posterPath, this.movieDetail.mediaType
        );
        this.isFavorite = true;
      }
    } catch (e) {
      const msg: string = e instanceof Error ? e.message : '操作失败';
      this.onError(msg);
    }
    this.onFavoriteChanged(this.isFavorite);
  }

  async setWatchingStatus(isWatching: boolean): Promise<boolean> {
    if (!this.movieDetail) return false;
    if (!isWatching) {
      try { await this.backend.removeWatching(this.movieDetail.id); return true; }
      catch (_e) { return false; }
    }
    // 获取完整信息：从 API 缓存取真正集数
    let totalEps = this.tvDetail?.numberOfEpisodes || 0;
    if (totalEps === 0 && this.movieDetail.mediaType === MovieType.TV) {
      const tvs = await this.movieApi.getAllTVs();
      for (let i = 0; i < tvs.length; i++) {
        if (tvs[i].id === this.movieDetail.id) {
          totalEps = 24; break; // 默认24集
        }
      }
    }
    if (totalEps === 0) totalEps = 24;
    try {
      await this.backend.addWatching(
        this.movieDetail.id, this.movieDetail.title,
        this.movieDetail.posterPath, this.movieDetail.mediaType,
        totalEps
      );
      return true;
    } catch (_e) { return false; }
  }

  async loadUserReview(movieId: number): Promise<void> {
    try {
      const r = await this.backend.getReview(movieId);
      if (r) {
        this.userReview = new UserReview();
        this.userReview.movieId = r.movie_id; this.userReview.movieTitle = r.movie_title;
        this.userReview.rating = r.rating; this.userReview.review = r.review;
      } else {
        this.userReview = null;
      }
    } catch (_e) { this.userReview = null; }
    this.onReviewLoaded(this.userReview);
  }

  async submitReview(rating: number, reviewText: string): Promise<boolean> {
    if (!this.movieDetail) return false;
    try {
      await this.backend.saveReview(this.movieDetail.id, this.movieDetail.title, rating, reviewText);
      this.userReview = new UserReview();
      this.userReview.rating = rating; this.userReview.review = reviewText;
      this.onReviewLoaded(this.userReview);
      return true;
    } catch (_e) { return false; }
  }

  async deleteReview(): Promise<boolean> {
    if (!this.movieDetail) return false;
    try {
      await this.backend.deleteReview(this.movieDetail.id);
      this.userReview = null;
      this.onReviewLoaded(null);
      return true;
    } catch (_e) { return false; }
  }

  async loadTrailer(movieId: number, mediaType: MovieType): Promise<void> {
    try {
      const url = await this.movieApi.getTrailerUrl(movieId, mediaType);
      this.trailerUrl = url;
      this.onTrailerLoaded(url);
    } catch (err) { hilog.warn(DOMAIN, TAG, 'Load trailer failed'); }
  }

  async recordWatchHistory(episodeId: number, episodeName: string,
    seasonNumber: number, episodeNumber: number,
    progress: number, duration: number): Promise<boolean> {
    if (!this.movieDetail) return false;
    try {
      await this.backend.addHistory(
        this.movieDetail.id, this.movieDetail.title, this.movieDetail.posterPath,
        this.movieDetail.mediaType, episodeId, episodeName,
        seasonNumber, episodeNumber, 0, duration, progress
      );
      hilog.info(DOMAIN, TAG, 'History recorded: id=%{public}d, progress=%{public}d',
        this.movieDetail.id, progress);
      return true;
    } catch (e) {
      const msg: string = e instanceof Error ? e.message : 'unknown';
      hilog.error(DOMAIN, TAG, 'Record history failed: %{public}s', msg);
      return false;
    }
  }
}
