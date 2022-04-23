import { indexedDbReader } from "./indexed_db_reader";
export class archetypeIndexedDb extends indexedDbReader {

  initialize = async () => await super.initialize()

  openDatabase = async () => await super.openDatabase('archetypeDB', 1)

  itemById = async id => await super.itemById(id, 'archetypes')

  itemsInRange = async (id1, id2, index) => await super.itemsInRange(id1, id2, 'archetypes', index)

  allItems = async () => await super.allItems('archetypes')

  requestRequiredData = async() => await super.requestRequiredData('/archetypes')


  upgradeData(event) {
    const db = event.target.result;
    const archStore = db.createObjectStore('archetypes', { keyPath: 'id' });
    archStore.transaction.oncomplete = async () => {
      const archData = await this.requestRequiredData();
      const archObjectStore = db.transaction('archetypes', 'readwrite').objectStore('archetypes');
      archData.forEach((arch) => {
        archObjectStore.add(arch);
      });
    };
  }
}
