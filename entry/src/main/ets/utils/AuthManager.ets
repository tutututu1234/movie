import { preferences } from '@kit.ArkData';

const STORE_NAME = 'auth_store';
const KEY_TOKEN = 'auth_token';
const KEY_USER_ID = 'user_id';
const KEY_USERNAME = 'username';
const KEY_PHONE = 'phone';

export class AuthManager {
  private static instance: AuthManager;
  private dataStore: preferences.Preferences | null = null;

  private token: string = '';
  private userId: number = 0;
  private username: string = '';
  private phone: string = '';

  private constructor() {}

  static getInstance(): AuthManager {
    if (!AuthManager.instance) {
      AuthManager.instance = new AuthManager();
    }
    return AuthManager.instance;
  }

  async init(context: Context): Promise<void> {
    this.dataStore = await preferences.getPreferences(context, STORE_NAME);
    this.token = await this.dataStore.get(KEY_TOKEN, '') as string;
    this.userId = await this.dataStore.get(KEY_USER_ID, 0) as number;
    this.username = await this.dataStore.get(KEY_USERNAME, '') as string;
    this.phone = await this.dataStore.get(KEY_PHONE, '') as string;
  }

  getToken(): string { return this.token; }
  getUserId(): number { return this.userId; }
  getUsername(): string { return this.username; }
  getPhone(): string { return this.phone; }
  isLoggedIn(): boolean { return this.token.length > 0; }

  async saveLogin(token: string, userId: number, username: string, phone: string): Promise<void> {
    this.token = token;
    this.userId = userId;
    this.username = username;
    this.phone = phone;
    if (this.dataStore) {
      await this.dataStore.put(KEY_TOKEN, token);
      await this.dataStore.put(KEY_USER_ID, userId);
      await this.dataStore.put(KEY_USERNAME, username);
      await this.dataStore.put(KEY_PHONE, phone);
      await this.dataStore.flush();
    }
  }

  async logout(): Promise<void> {
    this.token = '';
    this.userId = 0;
    this.username = '';
    this.phone = '';
    if (this.dataStore) {
      await this.dataStore.delete(KEY_TOKEN);
      await this.dataStore.delete(KEY_USER_ID);
      await this.dataStore.delete(KEY_USERNAME);
      await this.dataStore.delete(KEY_PHONE);
      await this.dataStore.flush();
    }
  }
}
