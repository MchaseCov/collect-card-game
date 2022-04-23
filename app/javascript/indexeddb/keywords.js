import { indexedDbReader } from "./indexed_db_reader";
export class keywordIndexedDb extends indexedDbReader {

  initialize = async () => await super.initialize()

  openDatabase = async () => await super.openDatabase('keywordDB', 1)

  itemById = async id => await super.itemById(id, 'keywords')

  itemsInRange = async (id1, id2, index) => await super.itemsInRange(id1, id2, 'keywords', index)

  allItems = async () => await super.allItems('keywords')

  requestRequiredData = async() => await super.requestRequiredData('/keywords')


  upgradeData(event) {
    const db = event.target.result;
    const keywordStore = db.createObjectStore('keywords', { keyPath: 'id' });
    keywordStore.createIndex('type', 'type', { unique: false });
    keywordStore.createIndex('player_choice', 'player_choice', { unique: false });
    keywordStore.createIndex('card_constant_id', 'card_constant_id', { unique: false });
    keywordStore.transaction.oncomplete = async () => {
      const keywordData = await this.requestRequiredData();
      const keywordObjectStore = db.transaction('keywords', 'readwrite').objectStore('keywords');
      keywordData.forEach((keyword) => {
        keywordObjectStore.add(keyword);
      });
    };
  }
}
