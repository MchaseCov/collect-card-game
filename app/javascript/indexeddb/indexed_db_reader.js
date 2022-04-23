export class indexedDbReader {

  async initialize() {
    try {
      this.indexedDb = await this.openDatabase();
    } catch (exception) { console.error(exception); } finally { return this.indexedDb; }
  }

  
  openDatabase(database, version) {
    return new Promise((resolve, reject) => {
      const cardConstantRequest = indexedDB.open(database, version);
      cardConstantRequest.onupgradeneeded = (event) => { this.upgradeData(event); };
      cardConstantRequest.onerror = (event) => reject(`Database error: ${event.target.errorCode}`);
      cardConstantRequest.onsuccess = () => resolve(cardConstantRequest.result);
    });
  }


  itemById(id, database) {
    return new Promise((resolve, reject) => {
      const request = this.indexedDb.transaction(database).objectStore(database).get(id);
      request.onsuccess = () => resolve(request.result);
      request.onerror = () => reject(request.error);
    });
  }

  itemsInRange(id1, id2, database, index) {
    const a = [];
    return new Promise((resolve, reject) => {
      let objectStore = this.indexedDb.transaction(database).objectStore(database);
      if (index) objectStore = objectStore.index(index);
      const keyRange = IDBKeyRange.bound(id1, id2);
      objectStore.openCursor(keyRange).onsuccess = (event) => {
        const cursor = event.target.result;
        if (cursor) {
          a.push(cursor.value);
          cursor.continue();
        } else resolve(a);
      };
    });
  }

  allItems(database) {
    return new Promise((resolve, reject) => {
      const objectStore = this.indexedDb.transaction(database).objectStore(database);
      objectStore.getAll().onsuccess = (event) => resolve(event.target.result)  
      }
    );
  }

  async requestRequiredData(route) {
    const response = await fetch(route, {
      method: 'GET',
      credentials: 'same-origin',
      headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.head.querySelector("[name='csrf-token']").content,
      },
    });
    if (response.ok) return await response.json();
  }
}