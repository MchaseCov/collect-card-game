const sharedPlayerDataAttrubutes = { animationsTarget: 'player', styleCardsTarget: 'player' };

const opInfoContainer = document.getElementById('op-info');
const fpInfoContainer = document.getElementById('fp-info');

const opponentPlayerAttributes = { id: 'op-player-info', classList: 'absolute bottom-0 left-0 right-0 w-40 h-48 mx-auto bg-red-200 rounded-t-full enemy-card' };
const friendlyPlayerAttributes = { id: 'fp-player-info', classList: 'absolute top-0 left-0 right-0 w-40 h-48 mx-auto bg-blue-200 rounded-t-full' };

const opponentPlayerDataAttributes = { gameplayDragTarget: 'recievesPlayerInput enemyActor', action: 'drop->gameplay-drag#drop dragenter->gameplay-drag#dragEnter dragover->gameplay-drag#dragOver dragend->gameplay-drag#dragEnd' };

const playerHealthClasslist = 'absolute w-12 h-12 pb-1 mt-1 text-4xl text-center border-2 rounded-full pointer-events-none select-none health-current border-lime-600 bg-lime-500 -bottom-2 -right-2';
const playerAttackClassList = 'absolute w-12 h-12 pb-1 mt-1 text-4xl text-center border-2 rounded-full pointer-events-none select-none text-white border-red-600 bg-red-500 -bottom-2 -left-2';

export default function createPlayers(playerData, opponentData) {
  const dataAndParent = [{
    player: playerData, parent: fpInfoContainer, attributes: friendlyPlayerAttributes, dataset: null,
  }, {
    player: opponentData, parent: opInfoContainer, attributes: opponentPlayerAttributes, dataset: opponentPlayerDataAttributes,
  }];
  dataAndParent.forEach((data) => {
    const portrait = createAndAppendPlayerPortrait(data);
    createHealthIndicator(portrait, data.player);
    createAttackIndicator(portrait, data.player);
  });
}

function createAndAppendPlayerPortrait(data) {
  const playerPortrait = document.createElement('div');
  playerPortrait.dataset.status = data.player.status;
  playerPortrait.dataset.playerId = data.player.id;
  Object.keys(data.attributes).forEach((key) => playerPortrait[key] = data.attributes[key]);
  Object.keys(sharedPlayerDataAttrubutes).forEach((key) => playerPortrait.dataset[key] = sharedPlayerDataAttrubutes[key]);
  if (data.dataset) Object.keys(data.dataset).forEach((key) => playerPortrait.dataset[key] = data.dataset[key]);
  data.parent.append(playerPortrait);
  return playerPortrait;
}

function createHealthIndicator(portrait, data) {
  const textColor = data.health_cap > data.health_current ? 'text-red-500' : 'text-white';
  const playerHealth = document.createElement('div');
  playerHealth.id = 'health';
  playerHealth.classList = playerHealthClasslist;
  playerHealth.classList.add(textColor);
  playerHealth.innerText = data.health_current;
  portrait.append(playerHealth);
}

function createAttackIndicator(portrait, data) {
  const playerAttack = document.createElement('div');
  playerAttack.classList = playerAttackClassList;
  if (data.attack <= 0) playerAttack.classList.add('hidden');
  playerAttack.innerText = data.attack;
  portrait.append(playerAttack);
}
