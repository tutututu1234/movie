import { UserFavorite, UserReview, WatchHistory, MovieType } from '../model/MovieModel';
import { BackendApi } from '../api/BackendApi';

export class ProfileViewModel {
  private backend: BackendApi;

  favorites: UserFavorite[] = [];
  reviews: UserReview[] = [];
  watchHistory: WatchHistory[] = [];
  lastWatchHistory: WatchHistory | null = null;

  onFavoritesUpdated: (favorites: UserFavorite[]) => void = () => {};
  onWatchingUpdated: (watching: UserFavorite[]) => void = () => {};
  onReviewsUpdated: (reviews: UserReview[]) => void = () => {};
  onHistoryUpdated: (history: WatchHistory[]) => void = () => {};
  onLastHistoryUpdated: (history: WatchHistory | null) => void = () => {};

  constructor() {
    this.backend = BackendApi.getInstance();
  }

  async loadAllData(): Promise<void> {
    await this.loadFavorites();
    await this.loadReviews();
    await this.loadWatchHistory();
    await this.loadLastWatchHistory();
  }

  async loadFavorites(): Promise<void> {
    try {
      const list = await this.backend.getFavorites();
      this.favorites = [];
      for (let i = 0; i < list.length; i++) {
        const f = new UserFavorite();
        f.id = list[i].id; f.movieId = list[i].movie_id;
        f.movieTitle = list[i].movie_title; f.posterPath = list[i].poster_path;
        f.mediaType = list[i].media_type as MovieType;
        f.currentEpisode = list[i].current_episode;
        f.totalEpisodes = list[i].total_episodes;
        f.watchProgress = list[i].watch_progress;
        f.isWatching = list[i].is_watching === 1;
        f.addTime = list[i].add_time;
        this.favorites.push(f);
      }
    } catch (_e) { this.favorites = []; }
    this.onFavoritesUpdated(this.favorites);
  }

  async loadReviews(): Promise<void> {
    try {
      const list = await this.backend.getReviews();
      this.reviews = [];
      for (let i = 0; i < list.length; i++) {
        const r = new UserReview();
        r.id = list[i].id; r.movieId = list[i].movie_id;
        r.movieTitle = list[i].movie_title; r.rating = list[i].rating;
        r.review = list[i].review; r.createTime = list[i].create_time;
        r.updateTime = list[i].update_time;
        this.reviews.push(r);
      }
    } catch (_e) { this.reviews = []; }
    this.onReviewsUpdated(this.reviews);
  }

  async loadWatchHistory(): Promise<void> {
    try {
      const list = await this.backend.getHistory();
      this.watchHistory = [];
      for (let i = 0; i < list.length; i++) {
        const h = new WatchHistory();
        h.id = list[i].id; h.movieId = list[i].movie_id;
        h.movieTitle = list[i].movie_title; h.posterPath = list[i].poster_path;
        h.mediaType = list[i].media_type as MovieType;
        h.seasonNumber = list[i].season_number;
        h.episodeNumber = list[i].episode_number;
        h.progress = list[i].progress; h.lastWatchTime = list[i].last_watch_time;
        this.watchHistory.push(h);
      }
    } catch (_e) { this.watchHistory = []; }
    this.onHistoryUpdated(this.watchHistory);
  }

  async loadLastWatchHistory(): Promise<void> {
    try {
      const h = await this.backend.getLastHistory();
      if (h) {
        const wh = new WatchHistory();
        wh.id = h.id; wh.movieId = h.movie_id;
        wh.movieTitle = h.movie_title; wh.posterPath = h.poster_path;
        wh.mediaType = h.media_type as MovieType;
        wh.seasonNumber = h.season_number;
        wh.episodeNumber = h.episode_number;
        wh.progress = h.progress; wh.lastWatchTime = h.last_watch_time;
        this.lastWatchHistory = wh;
      } else { this.lastWatchHistory = null; }
    } catch (_e) { this.lastWatchHistory = null; }
    this.onLastHistoryUpdated(this.lastWatchHistory);
  }

  async removeFavorite(movieId: number): Promise<void> {
    try { await this.backend.removeFavorite(movieId); } catch (_e) { }
    await this.loadFavorites();
  }

  async removeWatching(movieId: number): Promise<void> {
    try { await this.backend.removeWatching(movieId); } catch (_e) { }
    const list = await this.getWatchingList();
    this.onWatchingUpdated(list);
  }

  async clearHistory(): Promise<void> {
    try { await this.backend.clearHistory(); } catch (_e) { }
    await this.loadWatchHistory();
    await this.loadLastWatchHistory();
  }

  async getWatchingList(): Promise<UserFavorite[]> {
    try {
      const list = await this.backend.getWatchingList();
      const result: UserFavorite[] = [];
      for (let i = 0; i < list.length; i++) {
        const f = new UserFavorite();
        f.id = list[i].id; f.movieId = list[i].movie_id;
        f.movieTitle = list[i].movie_title; f.posterPath = list[i].poster_path;
        f.isWatching = true; f.mediaType = list[i].media_type as MovieType;
        f.totalEpisodes = list[i].total_episodes;
        f.currentEpisode = list[i].current_episode;
        f.watchProgress = list[i].watch_progress;
        result.push(f);
      }
      return result;
    } catch (_e) { return []; }
  }
}
