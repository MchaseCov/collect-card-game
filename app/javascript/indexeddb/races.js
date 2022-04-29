import { indexedDbReader } from "./indexed_db_reader";
export class raceIndexedDb extends indexedDbReader {

  initialize = async () => await super.initialize()

  openDatabase = async () => await super.openDatabase('raceDB', 1)

  itemById = async id => await super.itemById(id, 'races')

  itemsInRange = async (id1, id2, index) => await super.itemsInRange(id1, id2, 'races', index)

  allItems = async () => await super.allItems('races')

  requestRequiredData = async() => await super.requestRequiredData('/races')


  upgradeData(event) {
    const db = event.target.result;
    const raceStore = db.createObjectStore('races', { keyPath: 'id' });
    raceStore.transaction.oncomplete = async () => {
      const raceData = await this.requestRequiredData();
      const raceObjectStore = db.transaction('races', 'readwrite').objectStore('races');
      raceData.forEach((race) => {
        raceObjectStore.add(race);
      });
    };
  }
}
