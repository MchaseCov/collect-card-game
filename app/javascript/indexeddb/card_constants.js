import { indexedDbReader } from "./indexed_db_reader";
export class cardConstantIndexedDb extends indexedDbReader {

  initialize = async () => await super.initialize()

  openDatabase = async () => await super.openDatabase('cardConstantDB', 1)

  itemById = async id => await super.itemById(id, 'cardConstants')

  itemsInRange = async (id1, id2) => await super.itemsInRange(id1, id2, 'cardConstants')

  allItems = async () => await super.allItems()

  requestRequiredData = async() => await super.requestRequiredData('/card_constants')


  upgradeData(event) {
    const db = event.target.result;
    const cardStore = db.createObjectStore('cardConstants', { keyPath: 'id' });
    cardStore.createIndex('name', 'name', { unique: true });
    cardStore.createIndex('tribe', 'tribe', { unique: false });
    cardStore.transaction.oncomplete = async () => {
      const cardData = await this.requestRequiredData();
      const cardObjectStore = db.transaction('cardConstants', 'readwrite').objectStore('cardConstants');
      cardData.forEach((card) => {
        cardObjectStore.add(card);
      });
    };
  }
}
