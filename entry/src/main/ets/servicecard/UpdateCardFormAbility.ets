import { FormExtensionAbility, formBindingData, FormInfo } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'UpdateCardFormAbility';
const DOMAIN = 0x0000;

export default class UpdateCardFormAbility extends FormExtensionAbility {
  onAddForm(want: Want): formBindingData.FormBindingData {
    hilog.info(DOMAIN, TAG, 'onAddForm');
    const data: Record<string, string | number> = {
      'title': '今日追剧更新',
      'updateCount': 4,
      'shows': '庆余年3, 鱿鱼游戏3, 狂飙2, 漫长的季节2'
    };
    return formBindingData.createFormBindingData(data);
  }

  onUpdateForm(formId: string): void {
    hilog.info(DOMAIN, TAG, 'onUpdateForm formId: ' + formId);
  }

  onFormEvent(formId: string, message: string): void {
    hilog.info(DOMAIN, TAG, 'onFormEvent formId: ' + formId + ' message: ' + message);
  }

  onRemoveForm(formId: string): void {
    hilog.info(DOMAIN, TAG, 'onRemoveForm formId: ' + formId);
  }

  onCastToNormalForm(formId: string): void {
    hilog.info(DOMAIN, TAG, 'onCastToNormalForm formId: ' + formId);
  }

  onVisibilityChange(newStatus: Record<string, number>): void {
    hilog.info(DOMAIN, TAG, 'onVisibilityChange');
  }
}
