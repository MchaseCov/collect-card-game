export default class TargetDataFetcher {
  constructor(targettingElements, targetType, parentElement) {
    this.targettingElements = targettingElements;
    this.targetType = targetType;
    this.parentElement = parentElement;
    this.uniqueTargetEffectIds = [];
    this.dataWithTarget = {};
  }

  async updateLocalStorageForTargets() {
    this.targettingElements.forEach((e) => !this.uniqueTargetEffectIds.includes(e.dataset[this.targetType]) && this.uniqueTargetEffectIds.push(e.dataset[this.targetType]));
    await Promise.all(this.uniqueTargetEffectIds.map((id) => this.requestTargets(id)));
    localStorage.setItem(`${this.targetType}Data`, JSON.stringify(this.dataWithTarget)); // Stores target data in localstorage to reduce request spam
    localStorage.setItem(`${this.targetType}DataTimestamp`, +new Date(this.parentElement.dataset.updated)); // Timestamp for comparison
  }

  async requestTargets(id) {
    const response = await fetch(`/${this.targetType}/${id}/targets?game=${this.parentElement.dataset.game}`, {
      method: 'GET',
      credentials: 'same-origin',
      headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.head.querySelector("[name='csrf-token']").content,
      },
    });
    if (response.ok) {
      const json = await response.json();
      if (json.ids.length > 0) {
        this.dataWithTarget[id] = json.ids;
      }
    }
  }
}
