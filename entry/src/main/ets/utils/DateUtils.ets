import { systemDateTime } from '@kit.BasicServicesKit';

/**
 * 日期工具类
 */
export class DateUtils {
  static formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    const year: number = date.getFullYear();
    const month: string = String(date.getMonth() + 1).padStart(2, '0');
    const day: string = String(date.getDate()).padStart(2, '0');
    return year + '-' + month + '-' + day;
  }

  static formatDateTime(timestamp: number): string {
    const date = new Date(timestamp);
    const year: number = date.getFullYear();
    const month: string = String(date.getMonth() + 1).padStart(2, '0');
    const day: string = String(date.getDate()).padStart(2, '0');
    const hour: string = String(date.getHours()).padStart(2, '0');
    const minute: string = String(date.getMinutes()).padStart(2, '0');
    return year + '-' + month + '-' + day + ' ' + hour + ':' + minute;
  }

  static getRelativeTime(timestamp: number): string {
    const now: number = systemDateTime.getTime();
    const diff: number = now - timestamp;
    const minute: number = 60 * 1000;
    const hour: number = 60 * minute;
    const day: number = 24 * hour;

    if (diff < minute) {
      return '刚刚';
    } else if (diff < hour) {
      return String(Math.floor(diff / minute)) + '分钟前';
    } else if (diff < day) {
      return String(Math.floor(diff / hour)) + '小时前';
    } else if (diff < 7 * day) {
      return String(Math.floor(diff / day)) + '天前';
    } else {
      return DateUtils.formatDate(timestamp);
    }
  }
}
